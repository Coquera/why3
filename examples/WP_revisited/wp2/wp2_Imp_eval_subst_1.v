(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.
Require map.Map.

(* Why3 assumption *)
Inductive datatype  :=
  | Tint : datatype 
  | Tbool : datatype .
Axiom datatype_WhyType : WhyType datatype.
Existing Instance datatype_WhyType.

(* Why3 assumption *)
Inductive operator  :=
  | Oplus : operator 
  | Ominus : operator 
  | Omult : operator 
  | Ole : operator .
Axiom operator_WhyType : WhyType operator.
Existing Instance operator_WhyType.

(* Why3 assumption *)
Definition ident  := Z.

(* Why3 assumption *)
Inductive term  :=
  | Tconst : Z -> term 
  | Tvar : Z -> term 
  | Tderef : Z -> term 
  | Tbin : term -> operator -> term -> term .
Axiom term_WhyType : WhyType term.
Existing Instance term_WhyType.

(* Why3 assumption *)
Inductive fmla  :=
  | Fterm : term -> fmla 
  | Fand : fmla -> fmla -> fmla 
  | Fnot : fmla -> fmla 
  | Fimplies : fmla -> fmla -> fmla 
  | Flet : Z -> term -> fmla -> fmla 
  | Fforall : Z -> datatype -> fmla -> fmla .
Axiom fmla_WhyType : WhyType fmla.
Existing Instance fmla_WhyType.

(* Why3 assumption *)
Inductive value  :=
  | Vint : Z -> value 
  | Vbool : bool -> value .
Axiom value_WhyType : WhyType value.
Existing Instance value_WhyType.

(* Why3 assumption *)
Definition env  := (map.Map.map Z value).

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

(* Why3 assumption *)
Fixpoint eval_term(sigma:(map.Map.map Z value)) (pi:(map.Map.map Z value))
  (t:term) {struct t}: value :=
  match t with
  | (Tconst n) => (Vint n)
  | (Tvar id) => (map.Map.get pi id)
  | (Tderef id) => (map.Map.get sigma id)
  | (Tbin t1 op t2) => (eval_bin (eval_term sigma pi t1) op (eval_term sigma
      pi t2))
  end.

(* Why3 assumption *)
Fixpoint eval_fmla(sigma:(map.Map.map Z value)) (pi:(map.Map.map Z value))
  (f:fmla) {struct f}: Prop :=
  match f with
  | (Fterm t) => ((eval_term sigma pi t) = (Vbool true))
  | (Fand f1 f2) => (eval_fmla sigma pi f1) /\ (eval_fmla sigma pi f2)
  | (Fnot f1) => ~ (eval_fmla sigma pi f1)
  | (Fimplies f1 f2) => (eval_fmla sigma pi f1) -> (eval_fmla sigma pi f2)
  | (Flet x t f1) => (eval_fmla sigma (map.Map.set pi x (eval_term sigma pi
      t)) f1)
  | (Fforall x Tint f1) => forall (n:Z), (eval_fmla sigma (map.Map.set pi x
      (Vint n)) f1)
  | (Fforall x Tbool f1) => forall (b:bool), (eval_fmla sigma (map.Map.set pi
      x (Vbool b)) f1)
  end.

Parameter subst_term: term -> Z -> Z -> term.

Axiom subst_term_def : forall (e:term) (r:Z) (v:Z),
  match e with
  | (Tconst _) => ((subst_term e r v) = e)
  | (Tvar _) => ((subst_term e r v) = e)
  | (Tderef x) => ((r = x) -> ((subst_term e r v) = (Tvar v))) /\
      ((~ (r = x)) -> ((subst_term e r v) = e))
  | (Tbin e1 op e2) => ((subst_term e r v) = (Tbin (subst_term e1 r v) op
      (subst_term e2 r v)))
  end.

(* Why3 assumption *)
Fixpoint fresh_in_term(id:Z) (t:term) {struct t}: Prop :=
  match t with
  | (Tconst _) => True
  | (Tvar v) => ~ (id = v)
  | (Tderef _) => True
  | (Tbin t1 _ t2) => (fresh_in_term id t1) /\ (fresh_in_term id t2)
  end.

Axiom eval_subst_term : forall (sigma:(map.Map.map Z value)) (pi:(map.Map.map
  Z value)) (e:term) (x:Z) (v:Z), (fresh_in_term v e) -> ((eval_term sigma pi
  (subst_term e x v)) = (eval_term (map.Map.set sigma x (map.Map.get pi v))
  pi e)).

Axiom eval_term_change_free : forall (t:term) (sigma:(map.Map.map Z value))
  (pi:(map.Map.map Z value)) (id:Z) (v:value), (fresh_in_term id t) ->
  ((eval_term sigma (map.Map.set pi id v) t) = (eval_term sigma pi t)).

(* Why3 assumption *)
Fixpoint fresh_in_fmla(id:Z) (f:fmla) {struct f}: Prop :=
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
Fixpoint subst(f:fmla) (x:Z) (v:Z) {struct f}: fmla :=
  match f with
  | (Fterm e) => (Fterm (subst_term e x v))
  | (Fand f1 f2) => (Fand (subst f1 x v) (subst f2 x v))
  | (Fnot f1) => (Fnot (subst f1 x v))
  | (Fimplies f1 f2) => (Fimplies (subst f1 x v) (subst f2 x v))
  | (Flet y t f1) => (Flet y (subst_term t x v) (subst f1 x v))
  | (Fforall y ty f1) => (Fforall y ty (subst f1 x v))
  end.

(* Why3 goal *)
Theorem eval_subst : forall (f:fmla) (sigma:(map.Map.map Z value))
  (pi:(map.Map.map Z value)) (x:Z) (v:Z), (fresh_in_fmla v f) ->
  ((eval_fmla sigma pi (subst f x v)) <-> (eval_fmla (map.Map.set sigma x
  (map.Map.get pi v)) pi f)).
induction f; intros sigma pi x v.
simpl; intro Fresh.
rewrite eval_subst_term; tauto.

simpl; intros (F1, F2).
rewrite IHf1; auto.
rewrite IHf2; tauto.

simpl; intros F.
rewrite IHf; tauto.

simpl; intros (F1,F2).
rewrite IHf1; auto.
rewrite IHf2; tauto.

simpl; intros (F1&F2&F3).
rewrite IHf; auto.
rewrite Map.Select_neq; auto.
rewrite eval_subst_term; tauto.

simpl; intros (F1&F2).
destruct d; simpl.
split; intros.
generalize (H n).
intro h.
rewrite IHf in h; auto.
rewrite Map.Select_neq in h; auto.
rewrite IHf; auto.
rewrite Map.Select_neq; auto.
split; intros.
generalize (H b).
intro h.
rewrite IHf in h; auto.
rewrite Map.Select_neq in h; auto.
rewrite IHf; auto.
rewrite Map.Select_neq; auto.

Qed.

