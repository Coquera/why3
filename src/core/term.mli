(**************************************************************************)
(*                                                                        *)
(*  Copyright (C) 2010-                                                   *)
(*    Francois Bobot                                                      *)
(*    Jean-Christophe Filliatre                                           *)
(*    Johannes Kanig                                                      *)
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

open Stdlib

(** Terms and Formulas *)

open Ident
open Ty

(** {2 Variable symbols} *)

type vsymbol = private {
  vs_name : ident;
  vs_ty : ty;
}

module Mvs : Map.S with type key = vsymbol
module Svs : Mvs.Set
module Hvs : Hashtbl.S with type key = vsymbol

val vs_equal : vsymbol -> vsymbol -> bool
val vs_hash : vsymbol -> int

val create_vsymbol : preid -> ty -> vsymbol

(** {2 Function and predicate symbols} *)

type lsymbol = private {
  ls_name   : ident;
  ls_args   : ty list;
  ls_value  : ty option;
}

module Mls : Map.S with type key = lsymbol
module Sls : Mls.Set
module Hls : Hashtbl.S with type key = lsymbol
module Wls : Hashweak.S with type key = lsymbol

val ls_equal : lsymbol -> lsymbol -> bool
  (** equality of function and predicate symbols *)
val ls_hash : lsymbol -> int

val create_lsymbol : preid -> ty list -> ty option -> lsymbol
val create_fsymbol : preid -> ty list -> ty -> lsymbol
val create_psymbol : preid -> ty list -> lsymbol

val ls_ty_freevars : lsymbol -> Stv.t

(** {2 Exceptions} *)

exception EmptyCase
exception DuplicateVar of vsymbol
exception UncoveredVar of vsymbol
exception BadArity of lsymbol * int * int
exception FunctionSymbolExpected of lsymbol
exception PredicateSymbolExpected of lsymbol

(** {2 Patterns} *)

type pattern = private {
  pat_node : pattern_node;
  pat_vars : Svs.t;
  pat_ty   : ty;
  pat_tag  : int;
}

and pattern_node = private
  | Pwild
  | Pvar of vsymbol
  | Papp of lsymbol * pattern list
  | Por  of pattern * pattern
  | Pas  of pattern * vsymbol

val pat_equal : pattern -> pattern -> bool
val pat_hash : pattern -> int

(** Smart constructors for patterns *)

val pat_wild : ty -> pattern
val pat_var : vsymbol -> pattern
val pat_app : lsymbol -> pattern list -> ty -> pattern
val pat_or  : pattern -> pattern -> pattern
val pat_as  : pattern -> vsymbol -> pattern

(** Generic traversal functions *)

val pat_map : (pattern -> pattern) -> pattern -> pattern
val pat_fold : ('a -> pattern -> 'a) -> 'a -> pattern -> 'a
val pat_all : (pattern -> bool) -> pattern -> bool
val pat_any : (pattern -> bool) -> pattern -> bool

(** {2 Terms and Formulas} *)

type quant =
  | Fforall
  | Fexists

type binop =
  | Fand
  | For
  | Fimplies
  | Fiff

type real_constant =
  | RConstDecimal of string * string * string option (* int / frac / exp *)
  | RConstHexa of string * string * string

type constant =
  | ConstInt of string
  | ConstReal of real_constant

type term = private {
  t_node : term_node;
  t_label : label list;
  t_ty : ty;
  t_tag : int;
}

and fmla = private {
  f_node : fmla_node;
  f_label : label list;
  f_tag : int;
}

and term_node = private
  | Tbvar of int
  | Tvar of vsymbol
  | Tconst of constant
  | Tapp of lsymbol * term list
  | Tif of fmla * term * term
  | Tlet of term * term_bound
  | Tcase of term * term_branch list
  | Teps of fmla_bound

and fmla_node = private
  | Fapp of lsymbol * term list
  | Fquant of quant * fmla_quant
  | Fbinop of binop * fmla * fmla
  | Fnot of fmla
  | Ftrue
  | Ffalse
  | Fif of fmla * fmla * fmla
  | Flet of term * fmla_bound
  | Fcase of term * fmla_branch list

and term_bound

and fmla_bound

and fmla_quant

and term_branch

and fmla_branch

and expr =
  | Term of term
  | Fmla of fmla

and trigger = expr list

module Mterm : Map.S with type key = term
module Sterm : Mterm.Set
module Hterm : Hashtbl.S with type key = term

module Mfmla : Map.S with type key = fmla
module Sfmla : Mfmla.Set
module Hfmla : Hashtbl.S with type key = fmla

val t_equal : term -> term -> bool
val f_equal : fmla -> fmla -> bool
val e_equal : expr -> expr -> bool

val tr_equal : trigger list -> trigger list -> bool

val t_hash : term -> int
val f_hash : fmla -> int

(** close bindings *)

val t_close_bound : vsymbol -> term -> term_bound
val f_close_bound : vsymbol -> fmla -> fmla_bound

val t_close_branch : pattern -> term -> term_branch
val f_close_branch : pattern -> fmla -> fmla_branch

val f_close_quant : vsymbol list -> trigger list -> fmla -> fmla_quant

(** open bindings *)

val t_open_bound : term_bound -> vsymbol * term
val f_open_bound : fmla_bound -> vsymbol * fmla

val t_open_branch : term_branch -> pattern * term
val f_open_branch : fmla_branch -> pattern * fmla

val f_open_quant : fmla_quant -> vsymbol list * trigger list * fmla

val f_open_forall : fmla -> vsymbol list * fmla
val f_open_exists : fmla -> vsymbol list * fmla

(** open bindings with optimized closing callbacks *)

val t_open_bound_cb :
  term_bound -> vsymbol * term * (vsymbol -> term -> term_bound)

val f_open_bound_cb :
  fmla_bound -> vsymbol * fmla * (vsymbol -> fmla -> fmla_bound)

val t_open_branch_cb :
  term_branch -> pattern * term * (pattern -> term -> term_branch)

val f_open_branch_cb :
  fmla_branch -> pattern * fmla * (pattern -> fmla -> fmla_branch)

val f_open_quant_cb :
  fmla_quant -> vsymbol list * trigger list * fmla *
              (vsymbol list -> trigger list -> fmla -> fmla_quant)

(** compute type instance *)

val ls_app_inst : lsymbol -> term list -> ty option -> ty Mtv.t
val fs_app_inst : lsymbol -> term list -> ty -> ty Mtv.t
val ps_app_inst : lsymbol -> term list -> ty Mtv.t

(** Smart constructors for term *)

val t_var : vsymbol -> term
val t_const : constant -> term
val t_int_const : string -> term
val t_real_const : real_constant -> term
val t_app : lsymbol -> term list -> ty -> term
val t_if : fmla -> term -> term -> term
val t_let : term -> term_bound -> term
val t_case : term -> term_branch list -> term
val t_eps : fmla_bound -> term

val t_let_close : vsymbol -> term -> term -> term
val t_eps_close : vsymbol -> fmla -> term

val t_app_infer : lsymbol -> term list -> term

val t_label : label list -> term -> term
val t_label_add : label -> term -> term
val t_label_copy : term -> term -> term

(** Smart constructors for fmla *)

val f_app : lsymbol -> term list -> fmla
val f_quant : quant -> fmla_quant -> fmla
val f_forall : fmla_quant -> fmla
val f_exists : fmla_quant -> fmla
val f_binary : binop -> fmla -> fmla -> fmla
val f_and : fmla -> fmla -> fmla
val f_or : fmla -> fmla -> fmla
val f_implies : fmla -> fmla -> fmla
val f_iff : fmla -> fmla -> fmla
val f_not : fmla -> fmla
val f_true : fmla
val f_false : fmla
val f_if : fmla -> fmla -> fmla -> fmla
val f_let : term -> fmla_bound -> fmla
val f_case : term -> fmla_branch list -> fmla

val f_let_close : vsymbol -> term -> fmla -> fmla
val f_quant_close : quant -> vsymbol list -> trigger list -> fmla -> fmla
val f_forall_close : vsymbol list -> trigger list -> fmla -> fmla
val f_exists_close : vsymbol list -> trigger list -> fmla -> fmla

val f_label : label list -> fmla -> fmla
val f_label_add : label -> fmla -> fmla
val f_label_copy : fmla -> fmla -> fmla

(** Constructors with propositional simplification *)

val f_quant_simp : quant -> fmla_quant -> fmla
val f_forall_simp : fmla_quant -> fmla
val f_exists_simp : fmla_quant -> fmla
val f_binary_simp : binop -> fmla -> fmla -> fmla
val f_and_simp : fmla -> fmla -> fmla
val f_and_simp_l : fmla list -> fmla
val f_or_simp : fmla -> fmla -> fmla
val f_or_simp_l : fmla list -> fmla
val f_implies_simp : fmla -> fmla -> fmla
val f_iff_simp : fmla -> fmla -> fmla
val f_not_simp : fmla -> fmla
val t_if_simp : fmla -> term -> term -> term
val f_if_simp : fmla -> fmla -> fmla -> fmla
val f_let_simp : term -> fmla_bound -> fmla

val f_let_close_simp : vsymbol -> term -> fmla -> fmla
val f_quant_close_simp : quant -> vsymbol list -> trigger list -> fmla -> fmla
val f_forall_close_simp : vsymbol list -> trigger list -> fmla -> fmla
val f_exists_close_simp : vsymbol list -> trigger list -> fmla -> fmla


val f_forall_close_merge : vsymbol list -> fmla -> fmla
(** [forall_close_merge vs f] - put a universal quantifier on top of [f]; merge
  variable lists if [f] is already a universally quantified formula; reuse
  triggers of [f], if any, otherwise the quantifier has no triggers. *)


(** Expr and trigger traversal *)

val e_map : (term -> term) -> (fmla -> fmla) -> expr -> expr
val e_fold : ('a -> term -> 'a) -> ('a -> fmla -> 'a) -> 'a -> expr -> 'a
val e_apply : (term -> 'a) -> (fmla -> 'a) -> expr -> 'a

val e_map_fold : ('a -> term -> 'a * term) ->
                 ('a -> fmla -> 'a * fmla) -> 'a -> expr -> 'a * expr

val tr_map : (term -> term) ->
             (fmla -> fmla) -> trigger list -> trigger list

val tr_fold : ('a -> term -> 'a) ->
              ('a -> fmla -> 'a) -> 'a -> trigger list -> 'a

val tr_map_fold : ('a -> term -> 'a * term) -> ('a -> fmla -> 'a * fmla) ->
                   'a -> trigger list -> 'a * trigger list

(** map/fold over symbols *)

val t_s_map : (tysymbol -> tysymbol) -> (lsymbol -> lsymbol) -> term -> term
val f_s_map : (tysymbol -> tysymbol) -> (lsymbol -> lsymbol) -> fmla -> fmla

val t_s_fold :
  ('a -> tysymbol -> 'a) -> ('a -> lsymbol -> 'a) -> 'a -> term -> 'a

val f_s_fold :
  ('a -> tysymbol -> 'a) -> ('a -> lsymbol -> 'a) -> 'a -> fmla -> 'a

val t_s_all : (tysymbol -> bool) -> (lsymbol -> bool) -> term -> bool
val f_s_all : (tysymbol -> bool) -> (lsymbol -> bool) -> fmla -> bool
val t_s_any : (tysymbol -> bool) -> (lsymbol -> bool) -> term -> bool
val f_s_any : (tysymbol -> bool) -> (lsymbol -> bool) -> fmla -> bool

(** built-in symbols *)

(* equality predicate *)
val ps_equ : lsymbol

val f_equ : term -> term -> fmla
val f_neq : term -> term -> fmla

val f_equ_simp : term -> term -> fmla
val f_neq_simp : term -> term -> fmla

val fs_func_app : lsymbol
val ps_pred_app : lsymbol

val t_func_app : term -> term -> term
val f_pred_app : term -> term -> fmla

val t_func_app_l : term -> term list -> term
val f_pred_app_l : term -> term list -> fmla

val fs_tuple : int -> lsymbol
val t_tuple : term list -> term

val is_fs_tuple : lsymbol -> bool

(** {2 Term library} *)

(** generic term/fmla traversal *)

val t_map : (term -> term) -> (fmla -> fmla) -> term -> term
  (** [t_map fnT fnF t] applies function fnT, resp. fnF, to
      each immediate subterms, resp. sub-formula, of [t] *)
val f_map : (term -> term) -> (fmla -> fmla) -> fmla -> fmla
  (** [f_map fnT fnF f] applies function fnT, resp. fnF, to
      each immediate subterms, resp. sub-formula, of [t] *)

val f_map_sign : (term -> term) -> (bool -> fmla -> fmla) ->
                                    bool -> fmla -> fmla
(** give the sign of the subformula:
    - true positive
    - false negative

    nb: if-then-else and iff are translated if needed *)

val t_fold : ('a -> term -> 'a) -> ('a -> fmla -> 'a) -> 'a -> term -> 'a
val f_fold : ('a -> term -> 'a) -> ('a -> fmla -> 'a) -> 'a -> fmla -> 'a

val t_all : (term -> bool) -> (fmla -> bool) -> term -> bool
val f_all : (term -> bool) -> (fmla -> bool) -> fmla -> bool
val t_any : (term -> bool) -> (fmla -> bool) -> term -> bool
val f_any : (term -> bool) -> (fmla -> bool) -> fmla -> bool

val t_map_fold : ('a -> term -> 'a * term) ->
                 ('a -> fmla -> 'a * fmla) -> 'a -> term -> 'a * term

val f_map_fold : ('a -> term -> 'a * term) ->
                 ('a -> fmla -> 'a * fmla) -> 'a -> fmla -> 'a * fmla

(** continuation-passing map *)

val t_map_cont : ((term -> 'a) -> term -> 'a) ->
                 ((fmla -> 'a) -> fmla -> 'a) -> (term -> 'a) -> term -> 'a

val f_map_cont : ((term -> 'a) -> term -> 'a) ->
                 ((fmla -> 'a) -> fmla -> 'a) -> (fmla -> 'a) -> fmla -> 'a

val e_map_cont : ((term -> 'a) -> term -> 'b) ->
                 ((fmla -> 'a) -> fmla -> 'b) -> (expr -> 'a) -> expr -> 'b

val list_map_cont : (('a -> 'b) -> 'c -> 'b) ->
                    ('a list -> 'b) -> 'c list -> 'b

(** simplification map *)

val f_map_simp : (term -> term) -> (fmla -> fmla) -> fmla -> fmla

(** map/fold over free variables *)

val t_v_map : (vsymbol -> term) -> term -> term
val f_v_map : (vsymbol -> term) -> fmla -> fmla

val t_v_fold : ('a -> vsymbol -> 'a) -> 'a -> term -> 'a
val f_v_fold : ('a -> vsymbol -> 'a) -> 'a -> fmla -> 'a

val t_v_all : (vsymbol -> bool) -> term -> bool
val f_v_all : (vsymbol -> bool) -> fmla -> bool
val t_v_any : (vsymbol -> bool) -> term -> bool
val f_v_any : (vsymbol -> bool) -> fmla -> bool

(** variable occurrence check *)

val t_occurs : Svs.t -> term -> bool
val f_occurs : Svs.t -> fmla -> bool

val t_occurs_single : vsymbol -> term -> bool
val f_occurs_single : vsymbol -> fmla -> bool

(** substitution for variables *)

val t_subst : term Mvs.t -> term -> term
val f_subst : term Mvs.t -> fmla -> fmla

val t_subst_single : vsymbol -> term -> term -> term
val f_subst_single : vsymbol -> term -> fmla -> fmla

val t_ty_subst : ty Mtv.t -> term Mvs.t -> term -> term
val f_ty_subst : ty Mtv.t -> term Mvs.t -> fmla -> fmla

(** set of free variables *)

val t_freevars : Svs.t -> term -> Svs.t
val f_freevars : Svs.t -> fmla -> Svs.t

(** set of free type variables *)

val t_ty_freevars : Stv.t -> term -> Stv.t
val f_ty_freevars : Stv.t -> fmla -> Stv.t

(** equality modulo alpha *)

val t_equal_alpha : term -> term -> bool
val f_equal_alpha : fmla -> fmla -> bool

module Hterm_alpha : Hashtbl.S with type key = term
module Hfmla_alpha : Hashtbl.S with type key = fmla

(** occurrence check *)

val t_occurs_term : term -> term -> bool
val f_occurs_term : term -> fmla -> bool
val t_occurs_fmla : fmla -> term -> bool
val f_occurs_fmla : fmla -> fmla -> bool

val t_occurs_term_alpha : term -> term -> bool
val f_occurs_term_alpha : term -> fmla -> bool
val t_occurs_fmla_alpha : fmla -> term -> bool
val f_occurs_fmla_alpha : fmla -> fmla -> bool

(** term/fmla replacement *)

val t_subst_term : term -> term -> term -> term
val f_subst_term : term -> term -> fmla -> fmla
val t_subst_fmla : fmla -> fmla -> term -> term
val f_subst_fmla : fmla -> fmla -> fmla -> fmla

val t_subst_term_alpha : term -> term -> term -> term
val f_subst_term_alpha : term -> term -> fmla -> fmla
val t_subst_fmla_alpha : fmla -> fmla -> term -> term
val f_subst_fmla_alpha : fmla -> fmla -> fmla -> fmla

(** binder-free term/fmla matching *)

exception NoMatch

val t_match : term Mvs.t -> term -> term -> term Mvs.t
val f_match : term Mvs.t -> fmla -> fmla -> term Mvs.t

(** fold over types in terms and formulas *)

val t_fold_ty : ('a -> ty -> 'a) -> 'a -> term -> 'a
val f_fold_ty : ('a -> ty -> 'a) -> 'a -> fmla -> 'a

val t_fold_sig : ('a -> lsymbol -> ty list -> 'a) -> 'a -> term -> 'a
val f_fold_sig : ('a -> lsymbol -> ty list -> 'a) -> 'a -> fmla -> 'a
