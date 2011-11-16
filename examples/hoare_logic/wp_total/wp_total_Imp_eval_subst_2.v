(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Inductive datatype  :=
  | Tint : datatype 
  | Tbool : datatype .

Inductive operator  :=
  | Oplus : operator 
  | Ominus : operator 
  | Omult : operator 
  | Ole : operator .

Definition ident  := Z.

Inductive term  :=
  | Tconst : Z -> term 
  | Tvar : Z -> term 
  | Tderef : Z -> term 
  | Tbin : term -> operator -> term -> term .

Inductive fmla  :=
  | Fterm : term -> fmla 
  | Fand : fmla -> fmla -> fmla 
  | Fnot : fmla -> fmla 
  | Fimplies : fmla -> fmla -> fmla .

Definition implb(x:bool) (y:bool): bool := match (x,
  y) with
  | (true, false) => false
  | (_, _) => true
  end.

Inductive value  :=
  | Vint : Z -> value 
  | Vbool : bool -> value .

Parameter map : forall (a:Type) (b:Type), Type.

Parameter get: forall (a:Type) (b:Type), (map a b) -> a -> b.

Implicit Arguments get.

Parameter set: forall (a:Type) (b:Type), (map a b) -> a -> b -> (map a b).

Implicit Arguments set.

Axiom Select_eq : forall (a:Type) (b:Type), forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (a1 = a2) -> ((get (set m a1 b1)
  a2) = b1).

Axiom Select_neq : forall (a:Type) (b:Type), forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (~ (a1 = a2)) -> ((get (set m a1 b1)
  a2) = (get m a2)).

Parameter const: forall (b:Type) (a:Type), b -> (map a b).

Set Contextual Implicit.
Implicit Arguments const.
Unset Contextual Implicit.

Axiom Const : forall (b:Type) (a:Type), forall (b1:b) (a1:a), ((get (const(
  b1):(map a b)) a1) = b1).

Definition env  := (map Z value).

Definition var_env  := (map Z value).

Definition ref_env  := (map Z value).

Inductive state  :=
  | mk_state : (map Z value) -> (map Z value) -> state .

Definition ref_env1(u:state): (map Z value) :=
  match u with
  | (mk_state _ ref_env2) => ref_env2
  end.

Definition var_env1(u:state): (map Z value) :=
  match u with
  | (mk_state var_env2 _) => var_env2
  end.

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
  | (_, _) => ((eval_bin x op y) = (Vbool false))
  end.

Set Implicit Arguments.
Fixpoint eval_term(s:state) (t:term) {struct t}: value :=
  match t with
  | (Tconst n) => (Vint n)
  | (Tvar id) => (get (var_env1 s) id)
  | (Tderef id) => (get (ref_env1 s) id)
  | (Tbin t1 op t2) => (eval_bin (eval_term s t1) op (eval_term s t2))
  end.
Unset Implicit Arguments.

Set Implicit Arguments.
Fixpoint eval_fmla(s:state) (f:fmla) {struct f}: Prop :=
  match f with
  | (Fterm t) => ((eval_term s t) = (Vbool true))
  | (Fand f1 f2) => (eval_fmla s f1) /\ (eval_fmla s f2)
  | (Fnot f1) => ~ (eval_fmla s f1)
  | (Fimplies f1 f2) => (~ (eval_fmla s f1)) \/ (eval_fmla s f2)
  end.
Unset Implicit Arguments.

Parameter subst_term: term -> Z -> term -> term.


Axiom subst_term_def : forall (e:term) (x:Z) (t:term),
  match e with
  | (Tconst _) => ((subst_term e x t) = e)
  | (Tvar _) => ((subst_term e x t) = e)
  | (Tderef y) => ((x = y) -> ((subst_term e x t) = t)) /\ ((~ (x = y)) ->
      ((subst_term e x t) = e))
  | (Tbin e1 op e2) => ((subst_term e x t) = (Tbin (subst_term e1 x t) op
      (subst_term e2 x t)))
  end.

Axiom eval_subst_term : forall (s:state) (e:term) (x:Z) (t:term),
  ((eval_term s (subst_term e x t)) = (eval_term (mk_state (var_env1 s)
  (set (ref_env1 s) x (eval_term s t))) e)).

Set Implicit Arguments.
Fixpoint subst(f:fmla) (x:Z) (t:term) {struct f}: fmla :=
  match f with
  | (Fterm e) => (Fterm (subst_term e x t))
  | (Fand f1 f2) => (Fand (subst f1 x t) (subst f2 x t))
  | (Fnot f1) => (Fnot (subst f1 x t))
  | (Fimplies f1 f2) => (Fimplies (subst f1 x t) (subst f2 x t))
  end.
Unset Implicit Arguments.

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Theorem eval_subst : forall (f:fmla) (s:state) (x:Z) (t:term), (eval_fmla s
  (subst f x t)) <-> (eval_fmla (mk_state (var_env1 s) (set (ref_env1 s) x
  (eval_term s t))) f).
(* YOU MAY EDIT THE PROOF BELOW *)
induction f.
unfold eval_fmla, subst in *.
intros s x t0.
rewrite eval_subst_term; tauto.

simpl.
intros s x t.
rewrite IHf1.
rewrite IHf2.
tauto.

simpl.
intros s x t.
rewrite IHf.
tauto.

simpl.
intros s x t.
rewrite IHf1.
rewrite IHf2.
tauto.


Qed.
(* DO NOT EDIT BELOW *)


