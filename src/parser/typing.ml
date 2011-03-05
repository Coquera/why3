(**************************************************************************)
(*                                                                        *)
(*  Copyright (C) 2010-                                                   *)
(*    François Bobot                                                     *)
(*    Jean-Christophe Filliâtre                                          *)
(*    Claude Marché                                                      *)
(*    Andrei Paskevich                                                    *)
(*                                                                        *)
(*  This software is free software; you can redistribute it and/or        *)
(*  modify it under the terms of the GNU Library General Public           *)
(*  License version 2.1, with the special exception on linking            *)
(*  described in file LICENSE.                                            *)
(*                                                                        *)
(*  This software is distributed in the hope that it will be useful,      *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                  *)
(*                                                                        *)
(**************************************************************************)

open Util
open Format
open Pp
open Ptree
open Ident
open Ty
open Term
open Decl
open Theory
open Env
open Denv

(** errors *)

exception Message of string
exception DuplicateTypeVar of string
exception TypeArity of qualid * int * int
exception Clash of string
exception PredicateExpected
exception TermExpected
exception BadNumberOfArguments of Ident.ident * int * int
exception ClashTheory of string
exception UnboundTheory of qualid
exception CyclicTypeDef
exception UnboundTypeVar of string
exception UnboundType of string list
exception UnboundSymbol of string list

let error ?loc e = match loc with
  | None -> raise e
  | Some loc -> raise (Loc.Located (loc,e))

let errorm ?loc f =
  let buf = Buffer.create 512 in
  let fmt = Format.formatter_of_buffer buf in
  Format.kfprintf
    (fun _ ->
       Format.pp_print_flush fmt ();
       let s = Buffer.contents buf in
       Buffer.clear buf;
       error ?loc (Message s))
    fmt f

let rec print_qualid fmt = function
  | Qident s -> fprintf fmt "%s" s.id
  | Qdot (m, s) -> fprintf fmt "%a.%s" print_qualid m s.id

let () = Exn_printer.register (fun fmt e -> match e with
  | Message s ->
      fprintf fmt "%s" s
  | DuplicateTypeVar s ->
      fprintf fmt "duplicate type parameter %s" s
  | TypeArity (id, a, n) ->
      fprintf fmt "@[The type %a expects %d argument(s),@ " print_qualid id a;
      fprintf fmt "but is applied to %d argument(s)@]" n
  | Clash id ->
      fprintf fmt "Clash with previous symbol %s" id
  | PredicateExpected ->
      fprintf fmt "syntax error: predicate expected"
  | TermExpected ->
      fprintf fmt "syntax error: term expected"
  | BadNumberOfArguments (s, n, m) ->
      fprintf fmt "@[Symbol `%s' is applied to %d terms,@ " s.id_string n;
      fprintf fmt "but is expecting %d arguments@]" m
  | ClashTheory s ->
      fprintf fmt "clash with previous theory %s" s
  | UnboundTheory q ->
      fprintf fmt "unbound theory %a" print_qualid q
  | CyclicTypeDef ->
      fprintf fmt "cyclic type definition"
  | UnboundTypeVar s ->
      fprintf fmt "unbound type variable '%s" s
  | UnboundType sl ->
       fprintf fmt "Unbound type '%a'" (print_list dot pp_print_string) sl
  | UnboundSymbol sl ->
       fprintf fmt "Unbound symbol '%a'" (print_list dot pp_print_string) sl
  | _ -> raise e)

let debug_parse_only = Debug.register_flag "parse_only"
let debug_type_only  = Debug.register_flag "type_only"

(** Environments *)

(** typing using destructive type variables

    parsed trees        intermediate trees       typed trees
      (Ptree)               (D below)               (Term)
   -----------------------------------------------------------
     ppure_type  ---dty--->   dty       ---ty--->    ty
      lexpr      --dterm-->   dterm     --term-->    term
      lexpr      --dfmla-->   dfmla     --fmla-->    fmla

*)

let term_expected_type ~loc ty1 ty2 =
  errorm ~loc
    "@[This term has type %a@ but is expected to have type@ %a@]"
    print_dty ty1 print_dty ty2

let unify_raise ~loc ty1 ty2 =
  if not (unify ty1 ty2) then term_expected_type ~loc ty1 ty2

(** Destructive typing environment, that is
    environment + local variables.
    It is only local to this module and created with [create_denv] below. *)

type denv = {
  uc : theory_uc; (* the theory under construction *)
  utyvars : (string, type_var) Hashtbl.t; (* user type variables *)
  dvars : dty Mstr.t; (* local variables, to be bound later *)
}

let create_denv uc = {
  uc = uc;
  utyvars = Hashtbl.create 17;
  dvars = Mstr.empty;
}

let find_user_type_var x env =
  try
    Hashtbl.find env.utyvars x
  with Not_found ->
    (* TODO: shouldn't we localize this ident? *)
    let v = create_tvsymbol (id_fresh x) in
    let v = create_ty_decl_var ~user:true v in
    Hashtbl.add env.utyvars x v;
    v

let mem_var x denv = Mstr.mem x denv.dvars
let find_var x denv = Mstr.find x denv.dvars
let add_var x ty denv = { denv with dvars = Mstr.add x ty denv.dvars }

let print_denv fmt denv =
  Mstr.iter (fun x ty -> fprintf fmt "%s:%a,@ " x print_dty ty) denv.dvars

(* parsed types -> intermediate types *)

let rec qloc = function
  | Qident x -> x.id_loc
  | Qdot (m, x) -> Loc.join (qloc m) x.id_loc

let rec string_list_of_qualid acc = function
  | Qident id -> id.id :: acc
  | Qdot (p, id) -> string_list_of_qualid (id.id :: acc) p

let specialize_tysymbol loc p uc =
  let sl = string_list_of_qualid [] p in
  let ts =
    try ns_find_ts (get_namespace uc) sl
    with Not_found -> error ~loc (UnboundType sl)
  in
  ts, List.length ts.ts_args

(* lazy declaration of tuples *)

let tuples_needed = Hashtbl.create 17

let ts_tuple n = Hashtbl.replace tuples_needed n (); ts_tuple n
let fs_tuple n = Hashtbl.replace tuples_needed n (); fs_tuple n

let add_tuple_decls uc =
  Hashtbl.fold (fun n _ uc -> Theory.use_export uc (tuple_theory n))
    tuples_needed uc

let with_tuples ?(reset=false) f uc x =
  let uc = f (add_tuple_decls uc) x in
  if reset then Hashtbl.clear tuples_needed;
  uc

let add_ty_decl  = with_tuples add_ty_decl
let add_ty_decls = with_tuples ~reset:true add_ty_decl

let add_logic_decl  = with_tuples add_logic_decl
let add_logic_decls = with_tuples ~reset:true add_logic_decl

let add_ind_decl  = with_tuples add_ind_decl
let add_ind_decls = with_tuples ~reset:true add_ind_decl

let add_prop_decl = with_tuples ~reset:true add_prop_decl

let rec type_inst s ty = match ty.ty_node with
  | Ty.Tyvar n -> Mtv.find n s
  | Ty.Tyapp (ts, tyl) -> tyapp (ts, List.map (type_inst s) tyl)

let rec dty env = function
  | PPTtyvar {id=x} ->
      tyvar (find_user_type_var x env)
  | PPTtyapp (p, x) ->
      let loc = qloc x in
      let ts, a = specialize_tysymbol loc x env.uc in
      let np = List.length p in
      if np <> a then error ~loc (TypeArity (x, a, np));
      let tyl = List.map (dty env) p in
      begin match ts.ts_def with
	| None ->
	    tyapp (ts, tyl)
	| Some ty ->
	    let add m v t = Mtv.add v t m in
            let s = List.fold_left2 add Mtv.empty ts.ts_args tyl in
	    type_inst s ty
      end
  | PPTtuple tyl ->
      let ts = ts_tuple (List.length tyl) in
      tyapp (ts, List.map (dty env) tyl)

let find_ns find p ns =
  let loc = qloc p in
  let sl = string_list_of_qualid [] p in
  try find ns sl
  with Not_found -> error ~loc (UnboundSymbol sl)

let find_prop_ns = find_ns ns_find_pr
let find_prop p uc = find_prop_ns p (get_namespace uc)

let find_tysymbol_ns = find_ns ns_find_ts
let find_tysymbol q uc = find_tysymbol_ns q (get_namespace uc)

let find_lsymbol_ns = find_ns ns_find_ls
let find_lsymbol q uc = find_lsymbol_ns q (get_namespace uc)

let find_namespace_ns = find_ns ns_find_ns
let find_namespace q uc = find_namespace_ns q (get_namespace uc)

let specialize_lsymbol p uc =
  let s = find_lsymbol p uc in
  let tl,ty = specialize_lsymbol ~loc:(qloc p) s in
  s,tl,ty

let specialize_fsymbol p uc =
  let s,tl,ty = specialize_lsymbol p uc in
  match ty with
    | None -> let loc = qloc p in error ~loc TermExpected
    | Some ty -> s, tl, ty

let specialize_psymbol p uc =
  let s,tl,ty = specialize_lsymbol p uc in
  match ty with
    | None -> s, tl
    | Some _ -> let loc = qloc p in error ~loc PredicateExpected

let is_psymbol p uc =
  let s = find_lsymbol p uc in
  s.ls_value = None

(* [is_projection uc ls] returns
   - [Some (ts, lsc, i)] if [ls] is the i-th projection of an
     algebraic datatype [ts] with only one constructor [lcs]
   - [None] otherwise
 *)
let is_projection uc ls =
  try
    let ts,tl = match ls.ls_args, ls.ls_value with
      | [{ty_node = Ty.Tyapp (ts, tl)}], Some _ -> ts,tl
      | _ -> (* not a function with 1 argument *) raise Exit
    in
    ignore (List.fold_left (fun tvs t -> match t.ty_node with
      | Ty.Tyvar tv -> Stv.add_new tv Exit tvs
      | _ -> (* not a generic type *) raise Exit) Stv.empty tl);
    let kn = get_known uc in
    let lsc = match Decl.find_constructors kn ts with
      | [lsc] -> lsc
      | _ -> (* 0 or several constructors *) raise Exit
    in
    let def = match Decl.find_logic_definition kn ls with
      | Some def -> def
      | None -> (* no definition *) raise Exit
    in
    let v, t = match Decl.open_fs_defn def with
      | [v], t -> v, t
      | _ -> assert false
    in
    let b = match t.t_node with
      | Tcase ({t_node=Term.Tvar v'}, [b]) when vs_equal v' v -> b
      | _ -> raise Exit
    in
    let p, t = t_open_branch b in
    let pl = match p with
      | { pat_node = Term.Papp (lsc', pl) } when ls_equal lsc lsc' -> pl
      | _ -> raise Exit
    in
    let i = match t.t_node with
      | Term.Tvar xi ->
	  let rec index i = function
	    | [] -> raise Exit
	    | { pat_node = Term.Pvar v} :: _ when vs_equal v xi -> i
	    | _ :: l -> index (i+1) l
	  in
	  index 0 pl
      | _ ->
	  raise Exit
    in
    Some (ts, lsc, i)
  with Exit ->
    None

let list_fields uc fl =
  let type_field (q, e) =
    let loc = qloc q in
    let ls = find_lsymbol q uc in
    match is_projection uc ls with
      | None -> errorm ~loc "this is not a record field"
      | Some pr -> pr, loc, e
  in
  let fl = List.map type_field fl in
  let (ts,cs,_),_,_ = List.hd fl in
  let n = List.length cs.ls_args in
  let args = Array.create n None in
  let check_field ((ts',_,i),loc,e) =
    if not (ts_equal ts' ts) then
      errorm ~loc "this should be a field for type %a" Pretty.print_ts ts;
    assert (0 <= i && i < n);
    if args.(i) <> None then
      errorm ~loc "this record field is defined several times";
    args.(i) <- Some (loc,e);
  in
  List.iter check_field fl;
  ts,cs,Array.to_list args


(** Typing types *)

let split_qualid = function
  | Qident id -> [], id.id
  | Qdot (p, id) -> string_list_of_qualid [] p, id.id

(** Typing terms and formulas *)

let binop = function
  | PPand -> Fand
  | PPor -> For
  | PPimplies -> Fimplies
  | PPiff -> Fiff

let check_pat_linearity p =
  let s = ref Sstr.empty in
  let add id =
    if Sstr.mem id.id !s then
      errorm ~loc:id.id_loc "duplicate variable %s" id.id;
    s := Sstr.add id.id !s
  in
  let rec check p = match p.pat_desc with
    | PPpwild -> ()
    | PPpvar id -> add id
    | PPpapp (_, pl) | PPptuple pl -> List.iter check pl
    | PPprec pfl -> List.iter (fun (_,p) -> check p) pfl
    | PPpas (p, id) -> check p; add id
    | PPpor (p, _) -> check p
  in
  check p

let fresh_type_var loc =
  let tv = create_tvsymbol (id_user "a" loc) in
  tyvar (create_ty_decl_var ~loc ~user:false tv)

let rec dpat env pat =
  let env, n, ty = dpat_node pat.pat_loc env pat.pat_desc in
  env, { dp_node = n; dp_ty = ty }

and dpat_node loc env = function
  | PPpwild ->
      let ty = fresh_type_var loc in
      env, Pwild, ty
  | PPpvar x ->
      let ty = fresh_type_var loc in
      let env = { env with dvars = Mstr.add x.id ty env.dvars } in
      env, Pvar x, ty
  | PPpapp (x, pl) ->
      let s, tyl, ty = specialize_fsymbol x env.uc in
      let env, pl = dpat_args s.ls_name loc env tyl pl in
      env, Papp (s, pl), ty
  | PPprec fl ->
      let renv = ref env in
      let _,cs,fl = list_fields env.uc fl in
      let tyl,ty = Denv.specialize_lsymbol ~loc cs in
      let al = List.map2 (fun f ty -> match f with
        | Some (_,e) ->
            let loc = e.pat_loc in
            let env,e = dpat !renv e in
            unify_raise ~loc e.dp_ty ty;
            renv := env;
            e
        | None -> { dp_node = Pwild; dp_ty = ty }) fl tyl
      in
      !renv, Papp (cs,al), Util.of_option ty
  | PPptuple pl ->
      let n = List.length pl in
      let s = fs_tuple n in
      let tyl = List.map (fun _ -> fresh_type_var loc) pl in
      let env, pl = dpat_args s.ls_name loc env tyl pl in
      let ty = tyapp (ts_tuple n, tyl) in
      env, Papp (s, pl), ty
  | PPpas (p, x) ->
      let env, p = dpat env p in
      let env = { env with dvars = Mstr.add x.id p.dp_ty env.dvars } in
      env, Pas (p,x), p.dp_ty
  | PPpor (p, q) ->
      let env, p = dpat env p in
      let env, q = dpat env q in
      unify_raise ~loc p.dp_ty q.dp_ty;
      env, Por (p,q), p.dp_ty

and dpat_args s loc env el pl =
  let n = List.length el and m = List.length pl in
  if n <> m then error ~loc (BadNumberOfArguments (s, m, n));
  let rec check_arg env = function
    | [], [] ->
	env, []
    | a :: al, p :: pl ->
	let loc = p.pat_loc in
	let env, p = dpat env p in
	unify_raise ~loc p.dp_ty a;
	let env, pl = check_arg env (al, pl) in
	env, p :: pl
    | _ ->
	assert false
  in
  check_arg env (el, pl)

let rec trigger_not_a_term_exn = function
  | TermExpected -> true
  | Loc.Located (_, exn) -> trigger_not_a_term_exn exn
  | _ -> false

let check_quant_linearity uqu =
  let s = ref Sstr.empty in
  let check id =
    if Sstr.mem id.id !s then errorm ~loc:id.id_loc "duplicate variable %s" id.id;
    s := Sstr.add id.id !s
  in
  List.iter (fun (idl, _) -> Util.option_iter check idl) uqu

let check_highord env x tl = match x with
  | Qident { id = x } when Mstr.mem x env.dvars -> true
  | _ -> List.length tl > List.length ((find_lsymbol x env.uc).ls_args)

let apply_highord loc x tl = match List.rev tl with
  | a::[] -> [{pp_loc = loc; pp_desc = PPvar x}; a]
  | a::tl -> [{pp_loc = loc; pp_desc = PPapp (x, List.rev tl)}; a]
  | [] -> assert false

let rec dterm ?(localize=false) env { pp_loc = loc; pp_desc = t } =
  let n, ty = dterm_node ~localize loc env t in
  let t = { dt_node = n; dt_ty = ty } in
  let rec down e = match e.dt_node with
    | Tnamed (Lstr _, e) -> down e
    | Tnamed (Lpos _, _) -> t
    | _ -> { dt_node = Tnamed (Lpos loc, t); dt_ty = ty }
  in
  if localize then down t else t

and dterm_node ~localize loc env = function
  | PPvar (Qident {id=x}) when Mstr.mem x env.dvars ->
      (* local variable *)
      let ty = Mstr.find x env.dvars in
      Tvar x, ty
  | PPvar x ->
      (* 0-arity symbol (constant) *)
      let s, tyl, ty = specialize_fsymbol x env.uc in
      let n = List.length tyl in
      if n > 0 then error ~loc (BadNumberOfArguments (s.ls_name, 0, n));
      Tapp (s, []), ty
  | PPapp (x, tl) when check_highord env x tl ->
      let tl = apply_highord loc x tl in
      let atyl, aty = Denv.specialize_lsymbol ~loc fs_func_app in
      let tl = dtype_args fs_func_app.ls_name loc env atyl tl in
      Tapp (fs_func_app, tl), Util.of_option aty
  | PPapp (x, tl) ->
      let s, tyl, ty = specialize_fsymbol x env.uc in
      let tl = dtype_args s.ls_name loc env tyl tl in
      Tapp (s, tl), ty
  | PPtuple tl ->
      let n = List.length tl in
      let s = fs_tuple n in
      let tyl = List.map (fun _ -> fresh_type_var loc) tl in
      let tl = dtype_args s.ls_name loc env tyl tl in
      let ty = tyapp (ts_tuple n, tyl) in
      Tapp (s, tl), ty
  | PPinfix (e1, x, e2) ->
      let s, tyl, ty = specialize_fsymbol (Qident x) env.uc in
      let tl = dtype_args s.ls_name loc env tyl [e1; e2] in
      Tapp (s, tl), ty
  | PPconst (ConstInt _ as c) ->
      Tconst c, tyapp (Ty.ts_int, [])
  | PPconst (ConstReal _ as c) ->
      Tconst c, tyapp (Ty.ts_real, [])
  | PPlet (x, e1, e2) ->
      let e1 = dterm ~localize env e1 in
      let ty = e1.dt_ty in
      let env = { env with dvars = Mstr.add x.id ty env.dvars } in
      let e2 = dterm ~localize env e2 in
      Tlet (e1, x, e2), e2.dt_ty
  | PPmatch (e1, bl) ->
      let t1 = dterm ~localize env e1 in
      let ty1 = t1.dt_ty in
      let tb = fresh_type_var loc in (* the type of all branches *)
      let branch (p, e) =
        let env, p = dpat_list env ty1 p in
        let loc = e.pp_loc in
	let e = dterm ~localize env e in
	unify_raise ~loc e.dt_ty tb;
        p, e
      in
      let bl = List.map branch bl in
      Tmatch (t1, bl), tb
  | PPnamed (x, e1) ->
      let localize = match x with
        | Lpos _ -> false
        | Lstr _ -> true
      in
      let e1 = dterm ~localize env e1 in
      Tnamed (x, e1), e1.dt_ty
  | PPcast (e1, ty) ->
      let loc = e1.pp_loc in
      let e1 = dterm ~localize env e1 in
      let ty = dty env ty in
      unify_raise ~loc e1.dt_ty ty;
      e1.dt_node, ty
  | PPif (e1, e2, e3) ->
      let loc = e3.pp_loc in
      let e2 = dterm ~localize env e2 in
      let e3 = dterm ~localize env e3 in
      unify_raise ~loc e3.dt_ty e2.dt_ty;
      Tif (dfmla ~localize env e1, e2, e3), e2.dt_ty
  | PPeps (x, ty, e1) ->
      let ty = dty env ty in
      let env = { env with dvars = Mstr.add x.id ty env.dvars } in
      let e1 = dfmla ~localize env e1 in
      Teps (x, ty, e1), ty
  | PPquant ((PPlambda|PPfunc|PPpred) as q, uqu, trl, a) ->
      check_quant_linearity uqu;
      let uquant env (idl,ty) =
        let ty = dty env ty in
        let id = match idl with
          | Some id -> id
          | None -> assert false
        in
        { env with dvars = Mstr.add id.id ty env.dvars }, (id,ty)
      in
      let env, uqu = map_fold_left uquant env uqu in
      let trigger e =
	try
	  TRterm (dterm ~localize env e)
	with exn when trigger_not_a_term_exn exn ->
	  TRfmla (dfmla ~localize env e)
      in
      let trl = List.map (List.map trigger) trl in
      let e = match q with
        | PPfunc -> TRterm (dterm ~localize env a)
        | PPpred -> TRfmla (dfmla ~localize env a)
        | PPlambda -> trigger a
        | _ -> assert false
      in
      let id, ty, f = match e with
        | TRterm t ->
            let id = { id = "fc"; id_lab = []; id_loc = loc } in
            let tyl,ty = List.fold_right (fun (_,uty) (tyl,ty) ->
              let nty = tyapp (ts_func, [uty;ty]) in ty :: tyl, nty)
              uqu ([],t.dt_ty)
            in
            let h = { dt_node = Tvar id.id ; dt_ty = ty } in
            let h = List.fold_left2 (fun h (uid,uty) ty ->
              let u = { dt_node = Tvar uid.id ; dt_ty = uty } in
              { dt_node = Tapp (fs_func_app, [h;u]) ; dt_ty = ty })
              h uqu tyl
            in
            id, ty, Fapp (ps_equ, [h;t])
        | TRfmla f ->
            let id = { id = "pc"; id_lab = []; id_loc = loc } in
            let (uid,uty),uqu = match List.rev uqu with
              | uq :: uqu -> uq, List.rev uqu
              | [] -> assert false
            in
            let tyl,ty = List.fold_right (fun (_,uty) (tyl,ty) ->
              let nty = tyapp (ts_func, [uty;ty]) in ty :: tyl, nty)
              uqu ([],tyapp (ts_pred, [uty]))
            in
            let h = { dt_node = Tvar id.id ; dt_ty = ty } in
            let h = List.fold_left2 (fun h (uid,uty) ty ->
              let u = { dt_node = Tvar uid.id ; dt_ty = uty } in
              { dt_node = Tapp (fs_func_app, [h;u]) ; dt_ty = ty })
              h uqu tyl
            in
            let u = { dt_node = Tvar uid.id ; dt_ty = uty } in
            id, ty, Fbinop (Fiff, Fapp (ps_pred_app, [h;u]), f)
      in
      Teps (id, ty, Fquant (Fforall, uqu, trl, f)), ty
  | PPrecord fl ->
      let _,cs,fl = list_fields env.uc fl in
      let tyl,ty = Denv.specialize_lsymbol ~loc cs in
      let al = List.map2 (fun f ty -> match f with
        | Some (_,e) ->
            let loc = e.pp_loc in
            let e = dterm ~localize env e in
            unify_raise ~loc e.dt_ty ty;
            e
        | None -> errorm ~loc "some record fields are missing") fl tyl
      in
      Tapp (cs,al), Util.of_option ty
  | PPupdate (e,fl) ->
      let n = ref (-1) in
      let q = Queue.create () in
      let e = dterm ~localize env e in
      let _,cs,fl = list_fields env.uc fl in
      (* prepare the pattern *)
      let tyl,ty = Denv.specialize_lsymbol ~loc cs in
      unify_raise ~loc e.dt_ty (Util.of_option ty);
      let pl = List.map2 (fun f ty -> match f with
        | Some _ ->
            { dp_node = Pwild ; dp_ty = ty }
        | None ->
            let x = (incr n; "x:" ^ string_of_int !n) in
            let i = { id = x ; id_lab = []; id_loc = loc } in
            Queue.add (x,ty) q;
            { dp_node = Pvar i ; dp_ty = ty }) fl tyl
      in
      let p = { dp_node = Papp (cs,pl) ; dp_ty = e.dt_ty } in
      (* prepare the result *)
      let tyl,ty = Denv.specialize_lsymbol ~loc cs in
      let al = List.map2 (fun f ty -> match f with
        | Some (_,e) ->
            let loc = e.pp_loc in
            let e = dterm ~localize env e in
            unify_raise ~loc:loc e.dt_ty ty;
            e
        | None ->
            let (x,xty) = Queue.take q in
            unify_raise ~loc xty ty;
            { dt_node = Tvar x ; dt_ty = ty }) fl tyl
      in
      let t = { dt_node = Tapp (cs,al) ; dt_ty = Util.of_option ty } in
      Tmatch (e,[p,t]), t.dt_ty
  | PPquant _ | PPbinop _ | PPunop _ | PPfalse | PPtrue ->
      error ~loc TermExpected

and dfmla ?(localize=false) env { pp_loc = loc; pp_desc = f } =
  let f = dfmla_node ~localize loc env f in
  let rec down e = match e with
    | Fnamed (Lstr _, e) -> down e
    | Fnamed (Lpos _, _) -> f
    | _ -> Fnamed (Lpos loc, f)
  in
  if localize then down f else f

and dfmla_node ~localize loc env = function
  | PPtrue ->
      Ftrue
  | PPfalse ->
      Ffalse
  | PPunop (PPnot, a) ->
      Fnot (dfmla ~localize env a)
  | PPbinop (a, (PPand | PPor | PPimplies | PPiff as op), b) ->
      Fbinop (binop op, dfmla ~localize env a, dfmla ~localize env b)
  | PPif (a, b, c) ->
      Fif (dfmla ~localize env a, dfmla ~localize env b, dfmla ~localize env c)
  | PPquant (q, uqu, trl, a) ->
      check_quant_linearity uqu;
      let uquant env (idl,ty) =
        let ty = dty env ty in
        let id = match idl with
          | Some id -> id
          | None -> assert false
        in
        { env with dvars = Mstr.add id.id ty env.dvars }, (id,ty)
      in
      let env, uqu = map_fold_left uquant env uqu in
      let trigger e =
	try
	  TRterm (dterm ~localize env e)
	with exn when trigger_not_a_term_exn exn ->
	  TRfmla (dfmla ~localize env e)
      in
      let trl = List.map (List.map trigger) trl in
      let q = match q with
        | PPforall -> Fforall
        | PPexists -> Fexists
        | _ -> error ~loc PredicateExpected
      in
      Fquant (q, uqu, trl, dfmla ~localize env a)
  | PPapp (x, tl) when check_highord env x tl ->
      let tl = apply_highord loc x tl in
      let atyl, _ = Denv.specialize_lsymbol ~loc ps_pred_app in
      let tl = dtype_args ps_pred_app.ls_name loc env atyl tl in
      Fapp (ps_pred_app, tl)
  | PPapp (x, tl) ->
      let s, tyl = specialize_psymbol x env.uc in
      let tl = dtype_args s.ls_name loc env tyl tl in
      Fapp (s, tl)
  | PPinfix (e12, op2, e3) ->
      begin match e12.pp_desc with
	| PPinfix (_, op1, e2) when is_psymbol (Qident op1) env.uc ->
	    let e23 = { pp_desc = PPinfix (e2, op2, e3); pp_loc = loc } in
	    Fbinop (Fand, dfmla ~localize env e12, dfmla ~localize env e23)
	| _ ->
	    let s, tyl = specialize_psymbol (Qident op2) env.uc in
	    let tl = dtype_args s.ls_name loc env tyl [e12; e3] in
	    Fapp (s, tl)
      end
  | PPlet (x, e1, e2) ->
      let e1 = dterm ~localize env e1 in
      let ty = e1.dt_ty in
      let env = { env with dvars = Mstr.add x.id ty env.dvars } in
      let e2 = dfmla ~localize env e2 in
      Flet (e1, x, e2)
  | PPmatch (e1, bl) ->
      let t1 = dterm ~localize env e1 in
      let ty1 = t1.dt_ty in
      let branch (p, e) =
        let env, p = dpat_list env ty1 p in
        p, dfmla ~localize env e
      in
      Fmatch (t1, List.map branch bl)
  | PPnamed (x, f1) ->
      let localize = match x with
        | Lpos _ -> false
        | Lstr _ -> true
      in
      let f1 = dfmla ~localize env f1 in
      Fnamed (x, f1)
  | PPvar (Qident s | Qdot (_,s) as x) when is_uppercase s.id.[0] ->
      let pr = find_prop x env.uc in
      Fvar (Decl.find_prop (Theory.get_known env.uc) pr)
  | PPvar x ->
      let s, tyl = specialize_psymbol x env.uc in
      let tl = dtype_args s.ls_name loc env tyl [] in
      Fapp (s, tl)
  | PPeps _ | PPconst _ | PPcast _ | PPtuple _ | PPrecord _ | PPupdate _ ->
      error ~loc PredicateExpected

and dpat_list env ty p =
  check_pat_linearity p;
  let loc = p.pat_loc in
  let env, p = dpat env p in
  unify_raise ~loc p.dp_ty ty;
  env, p

and dtype_args s loc env el tl =
  let n = List.length el and m = List.length tl in
  if n <> m then error ~loc (BadNumberOfArguments (s, m, n));
  let rec check_arg = function
    | [], [] ->
	[]
    | a :: al, t :: bl ->
	let loc = t.pp_loc in
	let t = dterm env t in
	unify_raise ~loc t.dt_ty a;
	t :: check_arg (al, bl)
    | _ ->
	assert false
  in
  check_arg (el, tl)

(** Add projection functions for the algebraic types *)

let add_projection cl p (fs,tyarg,tyval) th =
  let vs = create_vsymbol (id_fresh p) tyval in
  let per_cs (_,id,pl) =
    let cs = find_lsymbol (Qident id) th in
    let tc = match cs.ls_value with
      | None -> assert false
      | Some t -> t
    in
    let m = ty_match Mtv.empty tc tyarg in
    let per_param ty (n,_) = match n with
      | Some id when id.id = p -> pat_var vs
      | _ -> pat_wild (ty_inst m ty)
    in
    let al = List.map2 per_param cs.ls_args pl in
    t_close_branch (pat_app cs al tyarg) (t_var vs)
  in
  let vs = create_vsymbol (id_fresh "u") tyarg in
  let t = t_case (t_var vs) (List.map per_cs cl) in
  let d = make_fs_defn fs [vs] t in
  add_logic_decl th [d]

let add_projections th d = match d.td_def with
  | TDabstract | TDalias _ -> th
  | TDrecord _ -> assert false
  | TDalgebraic cl ->
      let per_cs acc (_,id,pl) =
        let cs = find_lsymbol (Qident id) th in
        let tc = match cs.ls_value with
          | None -> assert false
          | Some t -> t
        in
        let per_param acc ty (n,_) = match n with
          | Some id when not (Mstr.mem id.id acc) ->
              let fn = create_user_id id in
              let fs = create_fsymbol fn [tc] ty in
              Mstr.add id.id (fs,tc,ty) acc
          | _ -> acc
        in
        List.fold_left2 per_param acc cs.ls_args pl
      in
      let ps = List.fold_left per_cs Mstr.empty cl in
      try Mstr.fold (add_projection cl) ps th
      with e -> raise (Loc.Located (d.td_loc, e))

(** Typing declarations, that is building environments. *)

open Ptree

let add_types dl th =
  let def = List.fold_left
    (fun def d ->
      let id = d.td_ident.id in
      if Mstr.mem id def then error ~loc:d.td_loc (Clash id);
      Mstr.add id d def)
    Mstr.empty dl
  in
  let tysymbols = Hashtbl.create 17 in
  let rec visit x =
    try
      match Hashtbl.find tysymbols x with
	| None -> error CyclicTypeDef
	| Some ts -> ts
    with Not_found ->
      Hashtbl.add tysymbols x None;
      let d = Mstr.find x def in
      let vars = Hashtbl.create 17 in
      let vl = List.map (fun id ->
        if Hashtbl.mem vars id.id then
          error ~loc:id.id_loc (DuplicateTypeVar id.id);
        let i = create_tvsymbol (create_user_id id) in
        Hashtbl.add vars id.id i;
        i) d.td_params
      in
      let id = create_user_id d.td_ident in
      let ts = match d.td_def with
	| TDalias ty ->
	    let rec apply = function
	      | PPTtyvar v ->
		  begin
		    try ty_var (Hashtbl.find vars v.id)
		    with Not_found -> error ~loc:v.id_loc (UnboundTypeVar v.id)
		  end
	      | PPTtyapp (tyl, q) ->
		  let ts = match q with
		    | Qident x when Mstr.mem x.id def ->
			visit x.id
		    | Qident _ | Qdot _ ->
			find_tysymbol q th
		  in
		  begin try
		    ty_app ts (List.map apply tyl)
		  with Ty.BadTypeArity (_, tsal, tyll) ->
		    error ~loc:(qloc q) (TypeArity (q, tsal, tyll))
		  end
	      | PPTtuple tyl ->
		  let ts = ts_tuple (List.length tyl) in
		  ty_app ts (List.map apply tyl)
	    in
	    create_tysymbol id vl (Some (apply ty))
	| TDabstract | TDalgebraic _ ->
	    create_tysymbol id vl None
	| TDrecord _ ->
	    assert false
      in
      Hashtbl.add tysymbols x (Some ts);
      ts
  in
  let tsl = List.rev_map (fun d -> visit d.td_ident.id, Tabstract) dl in
  let th' = try add_ty_decl th tsl
    with ClashSymbol s -> error ~loc:(Mstr.find s def).td_loc (Clash s)
  in
  let csymbols = Hashtbl.create 17 in
  let decl d =
    let ts, th' = match Hashtbl.find tysymbols d.td_ident.id with
      | None ->
	  assert false
      | Some ts ->
	  let th' = create_denv th' in
	  let vars = th'.utyvars in
	  List.iter
	    (fun v ->
	       Hashtbl.add vars v.tv_name.id_string
                  (create_ty_decl_var ~user:true v))
	    ts.ts_args;
	  ts, th'
    in
    let d = match d.td_def with
      | TDabstract | TDalias _ ->
	  Tabstract
      | TDalgebraic cl ->
	  let ty = ty_app ts (List.map ty_var ts.ts_args) in
	  let constructor (loc, id, pl) =
	    let param (_,t) = ty_of_dty (dty th' t) in
	    let tyl = List.map param pl in
	    Hashtbl.replace csymbols id.id loc;
	    create_fsymbol (create_user_id id) tyl ty
	  in
	  Talgebraic (List.map constructor cl)
      | TDrecord _ ->
	  assert false
    in
    ts, d
  in
  let th = try add_ty_decls th (List.map decl dl)
    with ClashSymbol s -> error ~loc:(Hashtbl.find csymbols s) (Clash s)
  in
  List.fold_left add_projections th dl

let record_typedef td = match td.td_def with
  | TDabstract | TDalgebraic _ | TDalias _ ->
      td
  | TDrecord fl ->
      let field (loc, mut, id, ty) =
	if mut then errorm ~loc "a logic record field cannot be mutable";
	Some id, ty
      in
      (* constructor for type t is "mk t" (and not String.capitalize t) *)
      let id = { td.td_ident with id = "mk " ^ td.td_ident.id } in
      { td with td_def = TDalgebraic [td.td_loc, id, List.map field fl] }

let add_types dl th =
  add_types (List.map record_typedef dl) th

let env_of_vsymbol_list vl =
  List.fold_left (fun env v -> Mstr.add v.vs_name.id_string v env) Mstr.empty vl

let add_logics dl th =
  let fsymbols = Hashtbl.create 17 in
  let psymbols = Hashtbl.create 17 in
  let denvs = Hashtbl.create 17 in
  (* 1. create all symbols and make an environment with these symbols *)
  let create_symbol th d =
    let id = d.ld_ident.id in
    let v = create_user_id d.ld_ident in
    let denv = create_denv th in
    Hashtbl.add denvs id denv;
    let type_ty (_,t) = ty_of_dty (dty denv t) in
    let pl = List.map type_ty d.ld_params in
    try match d.ld_type with
      | None -> (* predicate *)
	  let ps = create_psymbol v pl in
	  Hashtbl.add psymbols id ps;
	  add_logic_decl th [ps, None]
      | Some t -> (* function *)
	  let t = type_ty (None, t) in
	  let fs = create_fsymbol v pl t in
	  Hashtbl.add fsymbols id fs;
	  add_logic_decl th [fs, None]
    with ClashSymbol s -> error ~loc:d.ld_loc (Clash s)
  in
  let th' = List.fold_left create_symbol th dl in
  (* 2. then type-check all definitions *)
  let type_decl d =
    let id = d.ld_ident.id in
    let dadd_var denv (x, ty) = match x with
      | None -> denv
      | Some id -> { denv with dvars = Mstr.add id.id (dty denv ty) denv.dvars }
    in
    let denv = Hashtbl.find denvs id in
    let denv = { denv with uc = th' } in
    let denv = List.fold_left dadd_var denv d.ld_params in
    let create_var (x, _) ty =
      let id = match x with
	| None -> id_fresh "%x"
	| Some id -> create_user_id id
      in
      create_vsymbol id ty
    in
    let mk_vlist = List.map2 create_var d.ld_params in
    match d.ld_type with
    | None -> (* predicate *)
	let ps = Hashtbl.find psymbols id in
        begin match d.ld_def with
	  | None -> ps,None
	  | Some f ->
	      let f = dfmla denv f in
              let vl = match ps.ls_value with
                | None -> mk_vlist ps.ls_args
                | _ -> assert false
              in
	      let env = env_of_vsymbol_list vl in
              make_ps_defn ps vl (fmla env f)
        end
    | Some ty -> (* function *)
	let fs = Hashtbl.find fsymbols id in
        begin match d.ld_def with
	  | None -> fs,None
	  | Some t ->
	      let loc = t.pp_loc in
	      let ty = dty denv ty in
	      let t = dterm denv t in
	      unify_raise ~loc t.dt_ty ty;
              let vl = match fs.ls_value with
                | Some _ -> mk_vlist fs.ls_args
                | _ -> assert false
              in
	      let env = env_of_vsymbol_list vl in
	      make_fs_defn fs vl (term env t)
        end
  in
  add_logic_decls th (List.map type_decl dl)

let type_term denv env t =
  let t = dterm denv t in
  term env t

let type_fmla denv env f =
  let f = dfmla denv f in
  fmla env f

let add_prop k loc s f th =
  let pr = create_prsymbol (create_user_id s) in
  try add_prop_decl th k pr (type_fmla (create_denv th) Mstr.empty f)
  with ClashSymbol s -> error ~loc (Clash s)

let loc_of_id id = match id.id_origin with
  | User loc -> loc
  | _ -> assert false

let add_inductives dl th =
  (* 1. create all symbols and make an environment with these symbols *)
  let denv = create_denv th in
  let psymbols = Hashtbl.create 17 in
  let create_symbol th d =
    let id = d.in_ident.id in
    let v = create_user_id d.in_ident in
    let type_ty (_,t) = ty_of_dty (dty denv t) in
    let pl = List.map type_ty d.in_params in
    let ps = create_psymbol v pl in
    Hashtbl.add psymbols id ps;
    try add_logic_decl th [ps, None]
    with ClashSymbol s -> error ~loc:d.in_loc (Clash s)
  in
  let th' = List.fold_left create_symbol th dl in
  let denv = { denv with uc = th' } in
  (* 2. then type-check all definitions *)
  let propsyms = Hashtbl.create 17 in
  let type_decl d =
    let id = d.in_ident.id in
    let ps = Hashtbl.find psymbols id in
    let clause (loc, id, f) =
      Hashtbl.replace propsyms id.id loc;
      let f = type_fmla denv Mstr.empty f in
      create_prsymbol (create_user_id id), f
    in
    ps, List.map clause d.in_def
  in
  try add_ind_decls th (List.map type_decl dl)
  with
  | ClashSymbol s -> error ~loc:(Hashtbl.find propsyms s) (Clash s)
  | InvalidIndDecl (_,pr) -> errorm ~loc:(loc_of_id pr.pr_name)
      "not a clausal form"
  | NonPositiveIndDecl (_,pr,s) -> errorm ~loc:(loc_of_id pr.pr_name)
      "non-positive occurrence of %a" Pretty.print_ls s

(* parse declarations *)

let prop_kind = function
  | Kaxiom -> Paxiom
  | Kgoal -> Pgoal
  | Klemma -> Plemma

let find_theory env lenv q id = match q with
  | [] ->
      (* local theory *)
      begin try Mnm.find id lenv
      with Not_found -> find_theory env [] id end
  | _ :: _ ->
      (* theory in file f *)
      find_theory env q id

let rec clone_ns loc sl ns2 ns1 s =
  let clash id = error ~loc (Clash id.id_string) in
  let s = Mnm.fold (fun nm ns1 acc ->
    if not (Mnm.mem nm ns2.ns_ns) then acc else
    let ns2 = Mnm.find nm ns2.ns_ns in
    clone_ns loc sl ns2 ns1 acc) ns1.ns_ns s
  in
  let inst_ts = Mnm.fold (fun nm ts1 acc ->
    if not (Mnm.mem nm ns2.ns_ts) then acc else
    if not (Sid.mem ts1.ts_name sl) then acc else
    if Mts.mem ts1 acc then clash ts1.ts_name else
    let ts2 = Mnm.find nm ns2.ns_ts in
    Mts.add ts1 ts2 acc) ns1.ns_ts s.inst_ts
  in
  let inst_ls = Mnm.fold (fun nm ls1 acc ->
    if not (Mnm.mem nm ns2.ns_ls) then acc else
    if not (Sid.mem ls1.ls_name sl) then acc else
    if Mls.mem ls1 acc then clash ls1.ls_name else
    let ls2 = Mnm.find nm ns2.ns_ls in
    Mls.add ls1 ls2 acc) ns1.ns_ls s.inst_ls
  in
  { s with inst_ts = inst_ts; inst_ls = inst_ls }

let add_decl env lenv th = function
  | TypeDecl dl ->
      add_types dl th
  | LogicDecl dl ->
      add_logics dl th
  | IndDecl dl ->
      add_inductives dl th
  | PropDecl (loc, k, s, f) ->
      add_prop (prop_kind k) loc s f th
  | UseClone (loc, use, subst) ->
      let q, id = split_qualid use.use_theory in
      let t =
	try
	  find_theory env lenv q id
	with
	  | TheoryNotFound _ -> error ~loc (UnboundTheory use.use_theory)
      in
      let use_or_clone th = match subst with
	| None ->
	    use_export th t
	| Some s ->
            let add_inst s = function
              | CSns (p,q) ->
                  let find ns x = find_namespace_ns x ns in
                  let ns1 = option_fold find t.th_export p in
                  let ns2 = option_fold find (get_namespace th) q in
                  clone_ns loc t.th_local ns2 ns1 s
              | CStsym (p,q) ->
                  let ts1 = find_tysymbol_ns p t.th_export in
                  let ts2 = find_tysymbol q th in
                  if Mts.mem ts1 s.inst_ts
                  then error ~loc (Clash ts1.ts_name.id_string);
                  { s with inst_ts = Mts.add ts1 ts2 s.inst_ts }
              | CSlsym (p,q) ->
                  let ls1 = find_lsymbol_ns p t.th_export in
                  let ls2 = find_lsymbol q th in
                  if Mls.mem ls1 s.inst_ls
                  then error ~loc (Clash ls1.ls_name.id_string);
                  { s with inst_ls = Mls.add ls1 ls2 s.inst_ls }
              | CSlemma p ->
                  let pr = find_prop_ns p t.th_export in
                  if Spr.mem pr s.inst_lemma || Spr.mem pr s.inst_goal
                  then error ~loc (Clash pr.pr_name.id_string);
                  { s with inst_lemma = Spr.add pr s.inst_lemma }
              | CSgoal p ->
                  let pr = find_prop_ns p t.th_export in
                  if Spr.mem pr s.inst_lemma || Spr.mem pr s.inst_goal
                  then error ~loc (Clash pr.pr_name.id_string);
                  { s with inst_goal = Spr.add pr s.inst_goal }
	    in
            let s = List.fold_left add_inst empty_inst s in
	    clone_export th t s
      in
      let n = match use.use_as with
	| None -> Some t.th_name.id_string
	| Some (Some x) -> Some x.id
	| Some None -> None
      in
      begin try match use.use_imp_exp with
	| Nothing ->
	    (* use T = namespace T use_export T end *)
	    let th = open_namespace th in
	    let th = use_or_clone th in
	    close_namespace th false n
	| Import ->
	    (* use import T = namespace T use_export T end import T *)
	    let th = open_namespace th in
	    let th = use_or_clone th in
	    close_namespace th true n
	| Export ->
	    use_or_clone th
      with ClashSymbol s -> error ~loc (Clash s)
      end
  | Meta (loc, id, al) ->
      let s = id.id in
      let convert = function
        | PMAts q  -> MAts (find_tysymbol q th)
        | PMAls q  -> MAls (find_lsymbol q th)
        | PMApr q  -> MApr (find_prop q th)
        | PMAstr s -> MAstr s
        | PMAint i -> MAint (int_of_string i)
      in
      let al = List.map convert al in
      begin try add_meta th (lookup_meta s) al
      with e -> raise (Loc.Located (loc,e)) end

let add_decl env lenv th d =
  if Debug.test_flag debug_parse_only then th else
  add_decl env lenv th d

let close_theory lenv { id = id ; id_loc = loc } th =
  if Mnm.mem id lenv then error ~loc (ClashTheory id);
  if Debug.test_flag debug_parse_only then lenv else
  Mnm.add id (close_theory th) lenv

let close_namespace loc import name th =
  let id = option_map (fun id -> id.id) name in
  try close_namespace th import id
  with ClashSymbol s -> error ~loc (Clash s)

(*
Local Variables:
compile-command: "unset LANG; make -C ../.. test"
End:
*)
