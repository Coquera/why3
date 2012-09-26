(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.
Require int.MinMax.
Require set.Set.

(* Why3 assumption *)
Inductive list (a:Type) {a_WT:WhyType a} :=
  | Nil : list a
  | Cons : a -> (list a) -> list a.
Axiom list_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (list a).
Existing Instance list_WhyType.
Implicit Arguments Nil [[a] [a_WT]].
Implicit Arguments Cons [[a] [a_WT]].

(* Why3 assumption *)
Fixpoint infix_plpl {a:Type} {a_WT:WhyType a}(l1:(list a)) (l2:(list
  a)) {struct l1}: (list a) :=
  match l1 with
  | Nil => l2
  | (Cons x1 r1) => (Cons x1 (infix_plpl r1 l2))
  end.

Axiom Append_assoc : forall {a:Type} {a_WT:WhyType a}, forall (l1:(list a))
  (l2:(list a)) (l3:(list a)), ((infix_plpl l1 (infix_plpl l2
  l3)) = (infix_plpl (infix_plpl l1 l2) l3)).

Axiom Append_l_nil : forall {a:Type} {a_WT:WhyType a}, forall (l:(list a)),
  ((infix_plpl l (Nil :(list a))) = l).

(* Why3 assumption *)
Fixpoint length {a:Type} {a_WT:WhyType a}(l:(list a)) {struct l}: Z :=
  match l with
  | Nil => 0%Z
  | (Cons _ r) => (1%Z + (length r))%Z
  end.

Axiom Length_nonnegative : forall {a:Type} {a_WT:WhyType a}, forall (l:(list
  a)), (0%Z <= (length l))%Z.

Axiom Length_nil : forall {a:Type} {a_WT:WhyType a}, forall (l:(list a)),
  ((length l) = 0%Z) <-> (l = (Nil :(list a))).

Axiom Append_length : forall {a:Type} {a_WT:WhyType a}, forall (l1:(list a))
  (l2:(list a)), ((length (infix_plpl l1
  l2)) = ((length l1) + (length l2))%Z).

(* Why3 assumption *)
Fixpoint mem {a:Type} {a_WT:WhyType a}(x:a) (l:(list a)) {struct l}: Prop :=
  match l with
  | Nil => False
  | (Cons y r) => (x = y) \/ (mem x r)
  end.

Axiom mem_append : forall {a:Type} {a_WT:WhyType a}, forall (x:a) (l1:(list
  a)) (l2:(list a)), (mem x (infix_plpl l1 l2)) <-> ((mem x l1) \/ (mem x
  l2)).

Axiom mem_decomp : forall {a:Type} {a_WT:WhyType a}, forall (x:a) (l:(list
  a)), (mem x l) -> exists l1:(list a), exists l2:(list a),
  (l = (infix_plpl l1 (Cons x l2))).

Axiom map : forall (a:Type) {a_WT:WhyType a} (b:Type) {b_WT:WhyType b}, Type.
Parameter map_WhyType : forall (a:Type) {a_WT:WhyType a}
  (b:Type) {b_WT:WhyType b}, WhyType (map a b).
Existing Instance map_WhyType.

Parameter get: forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  (map a b) -> a -> b.

Parameter set: forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  (map a b) -> a -> b -> (map a b).

Axiom Select_eq : forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  forall (m:(map a b)), forall (a1:a) (a2:a), forall (b1:b), (a1 = a2) ->
  ((get (set m a1 b1) a2) = b1).

Axiom Select_neq : forall {a:Type} {a_WT:WhyType a}
  {b:Type} {b_WT:WhyType b}, forall (m:(map a b)), forall (a1:a) (a2:a),
  forall (b1:b), (~ (a1 = a2)) -> ((get (set m a1 b1) a2) = (get m a2)).

Parameter const: forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  b -> (map a b).

Axiom Const : forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  forall (b1:b) (a1:a), ((get (const b1:(map a b)) a1) = b1).

(* Why3 assumption *)
Inductive datatype  :=
  | TYunit : datatype 
  | TYint : datatype 
  | TYbool : datatype .
Axiom datatype_WhyType : WhyType datatype.
Existing Instance datatype_WhyType.

(* Why3 assumption *)
Inductive value  :=
  | Vvoid : value 
  | Vint : Z -> value 
  | Vbool : bool -> value .
Axiom value_WhyType : WhyType value.
Existing Instance value_WhyType.

(* Why3 assumption *)
Inductive operator  :=
  | Oplus : operator 
  | Ominus : operator 
  | Omult : operator 
  | Ole : operator .
Axiom operator_WhyType : WhyType operator.
Existing Instance operator_WhyType.

Axiom mident : Type.
Parameter mident_WhyType : WhyType mident.
Existing Instance mident_WhyType.

Axiom mident_decide : forall (m1:mident) (m2:mident), (m1 = m2) \/
  ~ (m1 = m2).

(* Why3 assumption *)
Inductive ident  :=
  | mk_ident : Z -> ident .
Axiom ident_WhyType : WhyType ident.
Existing Instance ident_WhyType.

(* Why3 assumption *)
Definition ident_index(v:ident): Z := match v with
  | (mk_ident x) => x
  end.

Parameter result: ident.

Axiom ident_decide : forall (m1:ident) (m2:ident), (m1 = m2) \/ ~ (m1 = m2).

(* Why3 assumption *)
Inductive term  :=
  | Tvalue : value -> term 
  | Tvar : ident -> term 
  | Tderef : mident -> term 
  | Tbin : term -> operator -> term -> term .
Axiom term_WhyType : WhyType term.
Existing Instance term_WhyType.

(* Why3 assumption *)
Fixpoint var_occurs_in_term(x:ident) (t:term) {struct t}: Prop :=
  match t with
  | (Tvalue _) => False
  | (Tvar i) => (x = i)
  | (Tderef _) => False
  | (Tbin t1 _ t2) => (var_occurs_in_term x t1) \/ (var_occurs_in_term x t2)
  end.

(* Why3 assumption *)
Inductive fmla  :=
  | Fterm : term -> fmla 
  | Fand : fmla -> fmla -> fmla 
  | Fnot : fmla -> fmla 
  | Fimplies : fmla -> fmla -> fmla 
  | Flet : ident -> term -> fmla -> fmla 
  | Fforall : ident -> datatype -> fmla -> fmla .
Axiom fmla_WhyType : WhyType fmla.
Existing Instance fmla_WhyType.

(* Why3 assumption *)
Inductive expr  :=
  | Evalue : value -> expr 
  | Ebin : expr -> operator -> expr -> expr 
  | Evar : ident -> expr 
  | Ederef : mident -> expr 
  | Eassign : mident -> expr -> expr 
  | Eseq : expr -> expr -> expr 
  | Elet : ident -> expr -> expr -> expr 
  | Eif : expr -> expr -> expr -> expr 
  | Eassert : fmla -> expr 
  | Ewhile : expr -> fmla -> expr -> expr .
Axiom expr_WhyType : WhyType expr.
Existing Instance expr_WhyType.

(* Why3 assumption *)
Definition type_value(v:value): datatype :=
  match v with
  | Vvoid => TYunit
  | (Vint int) => TYint
  | (Vbool bool1) => TYbool
  end.

(* Why3 assumption *)
Inductive type_operator : operator -> datatype -> datatype
  -> datatype -> Prop :=
  | Type_plus : (type_operator Oplus TYint TYint TYint)
  | Type_minus : (type_operator Ominus TYint TYint TYint)
  | Type_mult : (type_operator Omult TYint TYint TYint)
  | Type_le : (type_operator Ole TYint TYint TYbool).

(* Why3 assumption *)
Definition type_stack  := (list (ident* datatype)%type).

Parameter get_vartype: ident -> (list (ident* datatype)%type) -> datatype.

Axiom get_vartype_def : forall (i:ident) (pi:(list (ident* datatype)%type)),
  match pi with
  | Nil => ((get_vartype i pi) = TYunit)
  | (Cons (x, ty) r) => ((x = i) -> ((get_vartype i pi) = ty)) /\
      ((~ (x = i)) -> ((get_vartype i pi) = (get_vartype i r)))
  end.

(* Why3 assumption *)
Definition type_env  := (map mident datatype).

(* Why3 assumption *)
Inductive type_term : (map mident datatype) -> (list (ident* datatype)%type)
  -> term -> datatype -> Prop :=
  | Type_value : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (v:value), (type_term sigma pi (Tvalue v)
      (type_value v))
  | Type_var : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (v:ident) (ty:datatype), ((get_vartype v pi) = ty) ->
      (type_term sigma pi (Tvar v) ty)
  | Type_deref : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (v:mident) (ty:datatype), ((get sigma v) = ty) ->
      (type_term sigma pi (Tderef v) ty)
  | Type_bin : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (t1:term) (t2:term) (op:operator) (ty1:datatype)
      (ty2:datatype) (ty:datatype), (type_term sigma pi t1 ty1) ->
      ((type_term sigma pi t2 ty2) -> ((type_operator op ty1 ty2 ty) ->
      (type_term sigma pi (Tbin t1 op t2) ty))).

(* Why3 assumption *)
Inductive type_fmla : (map mident datatype) -> (list (ident* datatype)%type)
  -> fmla -> Prop :=
  | Type_term : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (t:term), (type_term sigma pi t TYbool) ->
      (type_fmla sigma pi (Fterm t))
  | Type_conj : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (f1:fmla) (f2:fmla), (type_fmla sigma pi f1) ->
      ((type_fmla sigma pi f2) -> (type_fmla sigma pi (Fand f1 f2)))
  | Type_neg : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (f:fmla), (type_fmla sigma pi f) -> (type_fmla sigma
      pi (Fnot f))
  | Type_implies : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (f1:fmla) (f2:fmla), (type_fmla sigma pi f1) ->
      ((type_fmla sigma pi f2) -> (type_fmla sigma pi (Fimplies f1 f2)))
  | Type_let : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:ident) (t:term) (f:fmla) (ty:datatype),
      (type_term sigma pi t ty) -> ((type_fmla sigma (Cons (x, ty) pi) f) ->
      (type_fmla sigma pi (Flet x t f)))
  | Type_forall1 : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:ident) (f:fmla), (type_fmla sigma (Cons (x, TYint)
      pi) f) -> (type_fmla sigma pi (Fforall x TYint f))
  | Type_forall2 : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:ident) (f:fmla), (type_fmla sigma (Cons (x, TYbool)
      pi) f) -> (type_fmla sigma pi (Fforall x TYbool f))
  | Type_forall3 : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:ident) (f:fmla), (type_fmla sigma (Cons (x, TYunit)
      pi) f) -> (type_fmla sigma pi (Fforall x TYunit f)).

(* Why3 assumption *)
Inductive type_expr : (map mident datatype) -> (list (ident* datatype)%type)
  -> expr -> datatype -> Prop :=
  | Type_Evalue : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (v:value), (type_expr sigma pi (Evalue v)
      (type_value v))
  | Type_Evar : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (v:ident) (ty:datatype), ((get_vartype v pi) = ty) ->
      (type_expr sigma pi (Evar v) ty)
  | Type_Ederef : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (v:mident) (ty:datatype), ((get sigma v) = ty) ->
      (type_expr sigma pi (Ederef v) ty)
  | Type_Ebinop : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (e1:expr) (e2:expr) (op:operator) (ty1:datatype)
      (ty2:datatype) (ty:datatype), (type_expr sigma pi e1 ty1) ->
      ((type_expr sigma pi e2 ty2) -> ((type_operator op ty1 ty2 ty) ->
      (type_expr sigma pi (Ebin e1 op e2) ty)))
  | Type_seq : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (e1:expr) (e2:expr) (ty:datatype), (type_expr sigma pi
      e1 TYunit) -> ((type_expr sigma pi e2 ty) -> (type_expr sigma pi
      (Eseq e1 e2) ty))
  | Type_assigns : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:mident) (e:expr) (ty:datatype), ((get sigma
      x) = ty) -> ((type_expr sigma pi e ty) -> (type_expr sigma pi
      (Eassign x e) TYunit))
  | Type_if : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (t:expr) (e1:expr) (e2:expr) (ty:datatype),
      (type_expr sigma pi t TYbool) -> ((type_expr sigma pi e1 ty) ->
      ((type_expr sigma pi e2 ty) -> (type_expr sigma pi (Eif t e1 e2) ty)))
  | Type_assert : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (p:fmla), (type_fmla sigma pi p) -> (type_expr sigma
      pi (Eassert p) TYbool)
  | Type_while : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (guard:expr) (body:expr) (inv:fmla) (ty:datatype),
      (type_fmla sigma pi inv) -> ((type_expr sigma pi guard TYbool) ->
      ((type_expr sigma pi body ty) -> (type_expr sigma pi (Ewhile guard inv
      body) ty)))
  | Type_Elet : forall (sigma:(map mident datatype)) (pi:(list (ident*
      datatype)%type)) (x:ident) (e1:expr) (e2:expr) (ty1:datatype)
      (ty2:datatype), (type_expr sigma pi e1 ty1) -> ((type_expr sigma
      (Cons (x, ty1) pi) e2 ty2) -> (type_expr sigma pi (Elet x e1 e2) ty2)).

(* Why3 assumption *)
Definition env  := (map mident value).

(* Why3 assumption *)
Definition stack  := (list (ident* value)%type).

Parameter get_stack: ident -> (list (ident* value)%type) -> value.

Axiom get_stack_def : forall (i:ident) (pi:(list (ident* value)%type)),
  match pi with
  | Nil => ((get_stack i pi) = Vvoid)
  | (Cons (x, v) r) => ((x = i) -> ((get_stack i pi) = v)) /\ ((~ (x = i)) ->
      ((get_stack i pi) = (get_stack i r)))
  end.

Axiom get_stack_eq : forall (x:ident) (v:value) (r:(list (ident*
  value)%type)), ((get_stack x (Cons (x, v) r)) = v).

Axiom get_stack_neq : forall (x:ident) (i:ident) (v:value) (r:(list (ident*
  value)%type)), (~ (x = i)) -> ((get_stack i (Cons (x, v) r)) = (get_stack i
  r)).

Parameter eval_bin: value -> operator -> value -> value.

Axiom eval_bin_def : forall (x:value) (op:operator) (y:value), match (x,
  y) with
  | ((Vint x1), (Vint y1)) =>
      match op with
      | Oplus => ((eval_bin x op y) = (Vint (x1 + y1)%Z))
      | Ominus => ((eval_bin x op y) = (Vint (x1 - y1)%Z))
      | Omult => ((eval_bin x op y) = (Vint (x1 * y1)%Z))
      | Ole => ((x1 <= y1)%Z -> ((eval_bin x op y) = (Vbool true))) /\
          ((~ (x1 <= y1)%Z) -> ((eval_bin x op y) = (Vbool false)))
      end
  | (_, _) => ((eval_bin x op y) = Vvoid)
  end.

(* Why3 assumption *)
Fixpoint eval_term(sigma:(map mident value)) (pi:(list (ident* value)%type))
  (t:term) {struct t}: value :=
  match t with
  | (Tvalue v) => v
  | (Tvar id) => (get_stack id pi)
  | (Tderef id) => (get sigma id)
  | (Tbin t1 op t2) => (eval_bin (eval_term sigma pi t1) op (eval_term sigma
      pi t2))
  end.

Axiom eval_bool_term : forall (sigma:(map mident value)) (pi:(list (ident*
  value)%type)) (sigmat:(map mident datatype)) (pit:(list (ident*
  datatype)%type)) (t:term), (type_term sigmat pit t TYbool) ->
  exists b:bool, ((eval_term sigma pi t) = (Vbool b)).

(* Why3 assumption *)
Fixpoint eval_fmla(sigma:(map mident value)) (pi:(list (ident* value)%type))
  (f:fmla) {struct f}: Prop :=
  match f with
  | (Fterm t) => ((eval_term sigma pi t) = (Vbool true))
  | (Fand f1 f2) => (eval_fmla sigma pi f1) /\ (eval_fmla sigma pi f2)
  | (Fnot f1) => ~ (eval_fmla sigma pi f1)
  | (Fimplies f1 f2) => (eval_fmla sigma pi f1) -> (eval_fmla sigma pi f2)
  | (Flet x t f1) => (eval_fmla sigma (Cons (x, (eval_term sigma pi t)) pi)
      f1)
  | (Fforall x TYint f1) => forall (n:Z), (eval_fmla sigma (Cons (x,
      (Vint n)) pi) f1)
  | (Fforall x TYbool f1) => forall (b:bool), (eval_fmla sigma (Cons (x,
      (Vbool b)) pi) f1)
  | (Fforall x TYunit f1) => (eval_fmla sigma (Cons (x, Vvoid) pi) f1)
  end.

Parameter msubst_term: term -> mident -> ident -> term.

Axiom msubst_term_def : forall (t:term) (r:mident) (v:ident),
  match t with
  | ((Tvalue _)|(Tvar _)) => ((msubst_term t r v) = t)
  | (Tderef x) => ((r = x) -> ((msubst_term t r v) = (Tvar v))) /\
      ((~ (r = x)) -> ((msubst_term t r v) = t))
  | (Tbin t1 op t2) => ((msubst_term t r v) = (Tbin (msubst_term t1 r v) op
      (msubst_term t2 r v)))
  end.

Parameter subst_term: term -> ident -> ident -> term.

Axiom subst_term_def : forall (t:term) (r:ident) (v:ident),
  match t with
  | ((Tvalue _)|(Tderef _)) => ((subst_term t r v) = t)
  | (Tvar x) => ((r = x) -> ((subst_term t r v) = (Tvar v))) /\
      ((~ (r = x)) -> ((subst_term t r v) = t))
  | (Tbin t1 op t2) => ((subst_term t r v) = (Tbin (subst_term t1 r v) op
      (subst_term t2 r v)))
  end.

(* Why3 assumption *)
Definition fresh_in_term(id:ident) (t:term): Prop := ~ (var_occurs_in_term id
  t).

Axiom fresh_in_binop : forall (t:term) (t':term) (op:operator) (v:ident),
  (fresh_in_term v (Tbin t op t')) -> ((fresh_in_term v t) /\
  (fresh_in_term v t')).

(* Why3 assumption *)
Fixpoint fresh_in_fmla(id:ident) (f:fmla) {struct f}: Prop :=
  match f with
  | (Fterm e) => (fresh_in_term id e)
  | ((Fand f1 f2)|(Fimplies f1 f2)) => (fresh_in_fmla id f1) /\
      (fresh_in_fmla id f2)
  | (Fnot f1) => (fresh_in_fmla id f1)
  | (Flet y t f1) => (~ (id = y)) /\ ((fresh_in_term id t) /\
      (fresh_in_fmla id f1))
  | (Fforall y ty f1) => (~ (id = y)) /\ (fresh_in_fmla id f1)
  end.

(* Why3 assumption *)
Fixpoint subst(f:fmla) (x:ident) (v:ident) {struct f}: fmla :=
  match f with
  | (Fterm e) => (Fterm (subst_term e x v))
  | (Fand f1 f2) => (Fand (subst f1 x v) (subst f2 x v))
  | (Fnot f1) => (Fnot (subst f1 x v))
  | (Fimplies f1 f2) => (Fimplies (subst f1 x v) (subst f2 x v))
  | (Flet y t f1) => (Flet y (subst_term t x v) (subst f1 x v))
  | (Fforall y ty f1) => (Fforall y ty (subst f1 x v))
  end.

(* Why3 assumption *)
Fixpoint msubst(f:fmla) (x:mident) (v:ident) {struct f}: fmla :=
  match f with
  | (Fterm e) => (Fterm (msubst_term e x v))
  | (Fand f1 f2) => (Fand (msubst f1 x v) (msubst f2 x v))
  | (Fnot f1) => (Fnot (msubst f1 x v))
  | (Fimplies f1 f2) => (Fimplies (msubst f1 x v) (msubst f2 x v))
  | (Flet y t f1) => (Flet y (msubst_term t x v) (msubst f1 x v))
  | (Fforall y ty f1) => (Fforall y ty (msubst f1 x v))
  end.

Axiom subst_fresh_term : forall (t:term) (x:ident) (v:ident),
  (fresh_in_term x t) -> ((subst_term t x v) = t).

Axiom subst_fresh : forall (f:fmla) (x:ident) (v:ident), (fresh_in_fmla x
  f) -> ((subst f x v) = f).

Axiom eval_msubst_term : forall (e:term) (sigma:(map mident value)) (pi:(list
  (ident* value)%type)) (x:mident) (v:ident), (fresh_in_term v e) ->
  ((eval_term sigma pi (msubst_term e x v)) = (eval_term (set sigma x
  (get_stack v pi)) pi e)).

Axiom eval_msubst : forall (f:fmla) (sigma:(map mident value)) (pi:(list
  (ident* value)%type)) (x:mident) (v:ident), (fresh_in_fmla v f) ->
  ((eval_fmla sigma pi (msubst f x v)) <-> (eval_fmla (set sigma x
  (get_stack v pi)) pi f)).

Axiom eval_swap_term : forall (t:term) (sigma:(map mident value)) (pi:(list
  (ident* value)%type)) (l:(list (ident* value)%type)) (id1:ident)
  (id2:ident) (v1:value) (v2:value), (~ (id1 = id2)) -> ((eval_term sigma
  (infix_plpl l (Cons (id1, v1) (Cons (id2, v2) pi))) t) = (eval_term sigma
  (infix_plpl l (Cons (id2, v2) (Cons (id1, v1) pi))) t)).

Axiom eval_swap_term_2 : forall (t:term) (sigma:(map mident value)) (pi:(list
  (ident* value)%type)) (id1:ident) (id2:ident) (v1:value) (v2:value),
  (~ (id1 = id2)) -> ((eval_term sigma (Cons (id1, v1) (Cons (id2, v2) pi))
  t) = (eval_term sigma (Cons (id2, v2) (Cons (id1, v1) pi)) t)).

Axiom eval_swap : forall (f:fmla) (sigma:(map mident value)) (pi:(list
  (ident* value)%type)) (l:(list (ident* value)%type)) (id1:ident)
  (id2:ident) (v1:value) (v2:value), (~ (id1 = id2)) -> ((eval_fmla sigma
  (infix_plpl l (Cons (id1, v1) (Cons (id2, v2) pi))) f) <-> (eval_fmla sigma
  (infix_plpl l (Cons (id2, v2) (Cons (id1, v1) pi))) f)).

Axiom eval_swap_2 : forall (f:fmla) (id1:ident) (id2:ident) (v1:value)
  (v2:value), (~ (id1 = id2)) -> forall (sigma:(map mident value)) (pi:(list
  (ident* value)%type)), (eval_fmla sigma (Cons (id1, v1) (Cons (id2, v2)
  pi)) f) <-> (eval_fmla sigma (Cons (id2, v2) (Cons (id1, v1) pi)) f).

Axiom eval_term_change_free : forall (t:term) (sigma:(map mident value))
  (pi:(list (ident* value)%type)) (id:ident) (v:value), (fresh_in_term id
  t) -> ((eval_term sigma (Cons (id, v) pi) t) = (eval_term sigma pi t)).

Axiom eval_change_free : forall (f:fmla) (id:ident) (v:value),
  (fresh_in_fmla id f) -> forall (sigma:(map mident value)) (pi:(list (ident*
  value)%type)), (eval_fmla sigma (Cons (id, v) pi) f) <-> (eval_fmla sigma
  pi f).

(* Why3 assumption *)
Definition valid_fmla(p:fmla): Prop := forall (sigma:(map mident value))
  (pi:(list (ident* value)%type)), (eval_fmla sigma pi p).

(* Why3 assumption *)
Fixpoint fresh_in_expr(id:ident) (e:expr) {struct e}: Prop :=
  match e with
  | (Evalue _) => True
  | (Ebin e1 op e2) => (fresh_in_expr id e1) /\ (fresh_in_expr id e2)
  | (Evar v) => ~ (id = v)
  | (Ederef _) => True
  | (Eassign x e1) => (fresh_in_expr id e1)
  | (Eseq e1 e2) => (fresh_in_expr id e1) /\ (fresh_in_expr id e2)
  | (Elet v e1 e2) => (~ (id = v)) /\ ((fresh_in_expr id e1) /\
      (fresh_in_expr id e2))
  | (Eif e1 e2 e3) => (fresh_in_expr id e1) /\ ((fresh_in_expr id e2) /\
      (fresh_in_expr id e3))
  | (Eassert f) => (fresh_in_fmla id f)
  | (Ewhile cond inv body) => (fresh_in_expr id cond) /\ ((fresh_in_fmla id
      inv) /\ (fresh_in_expr id body))
  end.

(* Why3 assumption *)
Inductive one_step : (map mident value) -> (list (ident* value)%type) -> expr
  -> (map mident value) -> (list (ident* value)%type) -> expr -> Prop :=
  | one_step_var : forall (sigma:(map mident value)) (pi:(list (ident*
      value)%type)) (v:ident), (one_step sigma pi (Evar v) sigma pi
      (Evalue (get_stack v pi)))
  | one_step_deref : forall (sigma:(map mident value)) (pi:(list (ident*
      value)%type)) (v:mident), (one_step sigma pi (Ederef v) sigma pi
      (Evalue (get sigma v)))
  | one_step_bin_ctxt1 : forall (sigma:(map mident value)) (sigma':(map
      mident value)) (pi:(list (ident* value)%type)) (pi':(list (ident*
      value)%type)) (op:operator) (e1:expr) (e1':expr) (e2:expr),
      (one_step sigma pi e1 sigma' pi' e1') -> (one_step sigma pi (Ebin e1 op
      e2) sigma' pi' (Ebin e1' op e2))
  | one_step_bin_ctxt2 : forall (sigma:(map mident value)) (sigma':(map
      mident value)) (pi:(list (ident* value)%type)) (pi':(list (ident*
      value)%type)) (op:operator) (v1:value) (e2:expr) (e2':expr),
      (one_step sigma pi e2 sigma' pi' e2') -> (one_step sigma pi
      (Ebin (Evalue v1) op e2) sigma' pi' (Ebin (Evalue v1) op e2'))
  | one_step_bin_value : forall (sigma:(map mident value)) (pi:(list (ident*
      value)%type)) (op:operator) (v1:value) (v2:value), (one_step sigma pi
      (Ebin (Evalue v1) op (Evalue v2)) sigma pi (Evalue (eval_bin v1 op
      v2)))
  | one_step_assign_ctxt : forall (sigma:(map mident value)) (sigma':(map
      mident value)) (pi:(list (ident* value)%type)) (pi':(list (ident*
      value)%type)) (x:mident) (e:expr) (e':expr), (one_step sigma pi e
      sigma' pi' e') -> (one_step sigma pi (Eassign x e) sigma' pi'
      (Eassign x e'))
  | one_step_assign_value : forall (sigma:(map mident value)) (sigma':(map
      mident value)) (pi:(list (ident* value)%type)) (x:mident) (v:value),
      (sigma' = (set sigma x v)) -> (one_step sigma pi (Eassign x (Evalue v))
      sigma' pi (Evalue Vvoid))
  | one_step_seq_ctxt : forall (sigma:(map mident value)) (sigma':(map mident
      value)) (pi:(list (ident* value)%type)) (pi':(list (ident*
      value)%type)) (e1:expr) (e1':expr) (e2:expr), (one_step sigma pi e1
      sigma' pi' e1') -> (one_step sigma pi (Eseq e1 e2) sigma' pi' (Eseq e1'
      e2))
  | one_step_seq_value : forall (sigma:(map mident value)) (pi:(list (ident*
      value)%type)) (e:expr), (one_step sigma pi (Eseq (Evalue Vvoid) e)
      sigma pi e)
  | one_step_let_ctxt : forall (sigma:(map mident value)) (sigma':(map mident
      value)) (pi:(list (ident* value)%type)) (pi':(list (ident*
      value)%type)) (id:ident) (e1:expr) (e1':expr) (e2:expr),
      (one_step sigma pi e1 sigma' pi' e1') -> (one_step sigma pi (Elet id e1
      e2) sigma' pi' (Elet id e1' e2))
  | one_step_let_value : forall (sigma:(map mident value)) (pi:(list (ident*
      value)%type)) (id:ident) (v:value) (e:expr), (one_step sigma pi
      (Elet id (Evalue v) e) sigma (Cons (id, v) pi) e)
  | one_step_if_ctxt : forall (sigma:(map mident value)) (sigma':(map mident
      value)) (pi:(list (ident* value)%type)) (pi':(list (ident*
      value)%type)) (e1:expr) (e1':expr) (e2:expr) (e3:expr), (one_step sigma
      pi e1 sigma' pi' e1') -> (one_step sigma pi (Eif e1 e2 e3) sigma' pi'
      (Eif e1' e2 e3))
  | one_step_if_true : forall (sigma:(map mident value)) (pi:(list (ident*
      value)%type)) (e1:expr) (e2:expr), (one_step sigma pi
      (Eif (Evalue (Vbool true)) e1 e2) sigma pi e1)
  | one_step_if_false : forall (sigma:(map mident value)) (pi:(list (ident*
      value)%type)) (e1:expr) (e2:expr), (one_step sigma pi
      (Eif (Evalue (Vbool false)) e1 e2) sigma pi e2)
  | one_step_assert : forall (sigma:(map mident value)) (pi:(list (ident*
      value)%type)) (f:fmla), (eval_fmla sigma pi f) -> (one_step sigma pi
      (Eassert f) sigma pi (Evalue Vvoid))
  | one_step_while_true : forall (sigma:(map mident value)) (pi:(list (ident*
      value)%type)) (cond:expr) (body:expr) (inv:fmla), (eval_fmla sigma pi
      inv) -> (one_step sigma pi (Ewhile (Evalue (Vbool true)) inv body)
      sigma pi (Eseq body (Ewhile cond inv body)))
  | one_step_while_false : forall (sigma:(map mident value)) (pi:(list
      (ident* value)%type)) (inv:fmla) (body:expr), (eval_fmla sigma pi
      inv) -> (one_step sigma pi (Ewhile (Evalue (Vbool false)) inv body)
      sigma pi (Evalue Vvoid)).

(* Why3 assumption *)
Inductive many_steps : (map mident value) -> (list (ident* value)%type)
  -> expr -> (map mident value) -> (list (ident* value)%type) -> expr
  -> Z -> Prop :=
  | many_steps_refl : forall (sigma:(map mident value)) (pi:(list (ident*
      value)%type)) (s:expr), (many_steps sigma pi s sigma pi s 0%Z)
  | many_steps_trans : forall (sigma1:(map mident value)) (sigma2:(map mident
      value)) (sigma3:(map mident value)) (pi1:(list (ident* value)%type))
      (pi2:(list (ident* value)%type)) (pi3:(list (ident* value)%type))
      (s1:expr) (s2:expr) (s3:expr) (n:Z), (one_step sigma1 pi1 s1 sigma2 pi2
      s2) -> ((many_steps sigma2 pi2 s2 sigma3 pi3 s3 n) ->
      (many_steps sigma1 pi1 s1 sigma3 pi3 s3 (n + 1%Z)%Z)).

Axiom steps_non_neg : forall (sigma1:(map mident value)) (sigma2:(map mident
  value)) (pi1:(list (ident* value)%type)) (pi2:(list (ident* value)%type))
  (s1:expr) (s2:expr) (n:Z), (many_steps sigma1 pi1 s1 sigma2 pi2 s2 n) ->
  (0%Z <= n)%Z.

Axiom many_steps_seq : forall (sigma1:(map mident value)) (sigma3:(map mident
  value)) (pi1:(list (ident* value)%type)) (pi3:(list (ident* value)%type))
  (e1:expr) (e2:expr) (n:Z), (many_steps sigma1 pi1 (Eseq e1 e2) sigma3 pi3
  (Evalue Vvoid) n) -> exists sigma2:(map mident value), exists pi2:(list
  (ident* value)%type), exists n1:Z, exists n2:Z, (many_steps sigma1 pi1 e1
  sigma2 pi2 (Evalue Vvoid) n1) /\ ((many_steps sigma2 pi2 e2 sigma3 pi3
  (Evalue Vvoid) n2) /\ (n = ((1%Z + n1)%Z + n2)%Z)).

(* Why3 assumption *)
Definition valid_triple(p:fmla) (e:expr) (q:fmla): Prop := forall (sigma:(map
  mident value)) (pi:(list (ident* value)%type)), (eval_fmla sigma pi p) ->
  forall (sigma':(map mident value)) (pi':(list (ident* value)%type)) (n:Z),
  (many_steps sigma pi e sigma' pi' (Evalue Vvoid) n) -> (eval_fmla sigma'
  pi' q).

(* Why3 assumption *)
Definition total_valid_triple(p:fmla) (e:expr) (q:fmla): Prop :=
  forall (sigma:(map mident value)) (pi:(list (ident* value)%type)),
  (eval_fmla sigma pi p) -> exists sigma':(map mident value),
  exists pi':(list (ident* value)%type), exists n:Z, (many_steps sigma pi e
  sigma' pi' (Evalue Vvoid) n) /\ (eval_fmla sigma' pi' q).

(* Why3 assumption *)
Definition assigns(sigma:(map mident value)) (a:(set.Set.set mident))
  (sigma':(map mident value)): Prop := forall (i:mident), (~ (set.Set.mem i
  a)) -> ((get sigma i) = (get sigma' i)).

Axiom assigns_refl : forall (sigma:(map mident value)) (a:(set.Set.set
  mident)), (assigns sigma a sigma).

Axiom assigns_trans : forall (sigma1:(map mident value)) (sigma2:(map mident
  value)) (sigma3:(map mident value)) (a:(set.Set.set mident)),
  ((assigns sigma1 a sigma2) /\ (assigns sigma2 a sigma3)) -> (assigns sigma1
  a sigma3).

Axiom assigns_union_left : forall (sigma:(map mident value)) (sigma':(map
  mident value)) (s1:(set.Set.set mident)) (s2:(set.Set.set mident)),
  (assigns sigma s1 sigma') -> (assigns sigma (set.Set.union s1 s2) sigma').

Axiom assigns_union_right : forall (sigma:(map mident value)) (sigma':(map
  mident value)) (s1:(set.Set.set mident)) (s2:(set.Set.set mident)),
  (assigns sigma s2 sigma') -> (assigns sigma (set.Set.union s1 s2) sigma').

(* Why3 assumption *)
Fixpoint expr_writes(s:expr) (w:(set.Set.set mident)) {struct s}: Prop :=
  match s with
  | ((Evalue _)|((Evar _)|((Ederef _)|(Eassert _)))) => True
  | (Eassign id _) => (set.Set.mem id w)
  | (Eseq e1 e2) => (expr_writes e1 w) /\ (expr_writes e2 w)
  | (Eif e1 e2 e3) => (expr_writes e1 w) /\ ((expr_writes e2 w) /\
      (expr_writes e3 w))
  | (Ewhile cond _ body) => (expr_writes cond w) /\ (expr_writes body w)
  | (Ebin e1 o e2) => (expr_writes e1 w) /\ (expr_writes e2 w)
  | (Elet id e1 e2) => (expr_writes e1 w) /\ (expr_writes e2 w)
  end.

Parameter fresh_from: fmla -> expr -> ident.

Axiom fresh_from_fmla : forall (s:expr) (f:fmla),
  (fresh_in_fmla (fresh_from f s) f).

Axiom fresh_from_expr : forall (s:expr) (f:fmla),
  (fresh_in_expr (fresh_from f s) s).

Parameter abstract_effects: expr -> fmla -> fmla.

Axiom abstract_effects_generalize : forall (sigma:(map mident value))
  (pi:(list (ident* value)%type)) (s:expr) (f:fmla), (eval_fmla sigma pi
  (abstract_effects s f)) -> (eval_fmla sigma pi f).

Axiom abstract_effects_monotonic : forall (s:expr) (f:fmla),
  forall (sigma:(map mident value)) (pi:(list (ident* value)%type)),
  (eval_fmla sigma pi f) -> forall (sigma1:(map mident value)) (pi1:(list
  (ident* value)%type)), (eval_fmla sigma1 pi1 (abstract_effects s f)).

(* Why3 assumption *)
Fixpoint wp(e:expr) (q:fmla) {struct e}: fmla :=
  match e with
  | (Evalue v) => (Flet result (Tvalue v) q)
  | (Evar v) => (Flet result (Tvar v) q)
  | (Ederef v) => (Flet result (Tderef v) q)
  | (Eassert f) => (Fand f (Fimplies f q))
  | (Eseq e1 e2) => (wp e1 (wp e2 q))
  | (Elet id e1 e2) => (wp e1 (Flet id (Tvar result) (wp e2 q)))
  | (Ebin e1 op e2) => let t1 := (fresh_from q e) in let t2 :=
      (fresh_from (Fand (Fterm (Tvar t1)) q) e) in let q' := (Flet result
      (Tbin (Tvar t1) op (Tvar t2)) q) in let f := (wp e2 (Flet t2
      (Tvar result) q')) in (wp e1 (Flet t1 (Tvar result) f))
  | (Eassign x e1) => let id := (fresh_from q e1) in let q' := (Flet result
      (Tvalue Vvoid) q) in (wp e1 (Flet id (Tvar result) (msubst q' x id)))
  | (Eif e1 e2 e3) => let f := (Fand (Fimplies (Fterm (Tvar result)) (wp e2
      q)) (Fimplies (Fnot (Fterm (Tvar result))) (wp e3 q))) in (wp e1 f)
  | (Ewhile cond inv body) => (Fand inv (abstract_effects body (wp cond
      (Fand (Fimplies (Fand (Fterm (Tvar result)) inv) (wp body inv))
      (Fimplies (Fand (Fnot (Fterm (Tvar result))) inv) q)))))
  end.

Axiom abstract_effects_writes : forall (sigma:(map mident value)) (pi:(list
  (ident* value)%type)) (s:expr) (q:fmla), (eval_fmla sigma pi
  (abstract_effects s q)) -> (eval_fmla sigma pi (wp s (abstract_effects s
  q))).

Require Import Why3.

Ltac ae := why3 "alt-ergo" timelimit 3.

(* Why3 goal *)
Theorem monotonicity : forall (s:expr),
  match s with
  | (Evalue v) => forall (p:fmla) (q:fmla), (valid_fmla (Fimplies p q)) ->
      (valid_fmla (Fimplies (wp s p) (wp s q)))
  | (Ebin e o e1) => True
  | (Evar i) => True
  | (Ederef m) => True
  | (Eassign m e) => True
  | (Eseq e e1) => True
  | (Elet i e e1) => True
  | (Eif e e1 e2) => True
  | (Eassert f) => True
  | (Ewhile e f e1) => True
  end.
destruct s; auto.
unfold valid_fmla.
simpl.
intros p q H_induc sigma pi.
apply H_induc. 
Qed.


