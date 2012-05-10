(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require int.Int.

(* Why3 assumption *)
Inductive datatype  :=
  | Tint : datatype 
  | Tbool : datatype .

(* Why3 assumption *)
Inductive operator  :=
  | Oplus : operator 
  | Ominus : operator 
  | Omult : operator 
  | Ole : operator .

(* Why3 assumption *)
Definition ident  := Z.

(* Why3 assumption *)
Inductive term  :=
  | Tconst : Z -> term 
  | Tvar : Z -> term 
  | Tderef : Z -> term 
  | Tbin : term -> operator -> term -> term .

(* Why3 assumption *)
Inductive fmla  :=
  | Fterm : term -> fmla 
  | Fand : fmla -> fmla -> fmla 
  | Fnot : fmla -> fmla 
  | Fimplies : fmla -> fmla -> fmla 
  | Flet : Z -> term -> fmla -> fmla 
  | Fforall : Z -> datatype -> fmla -> fmla .

(* Why3 assumption *)
Definition implb(x:bool) (y:bool): bool := match (x,
  y) with
  | (true, false) => false
  | (_, _) => true
  end.

(* Why3 assumption *)
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

Axiom Const : forall (b:Type) (a:Type), forall (b1:b) (a1:a),
  ((get (const b1:(map a b)) a1) = b1).

(* Why3 assumption *)
Definition env  := (map Z value).

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
Set Implicit Arguments.
Fixpoint eval_term(sigma:(map Z value)) (pi:(map Z value))
  (t:term) {struct t}: value :=
  match t with
  | (Tconst n) => (Vint n)
  | (Tvar id) => (get pi id)
  | (Tderef id) => (get sigma id)
  | (Tbin t1 op t2) => (eval_bin (eval_term sigma pi t1) op (eval_term sigma
      pi t2))
  end.
Unset Implicit Arguments.

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint eval_fmla(sigma:(map Z value)) (pi:(map Z value))
  (f:fmla) {struct f}: Prop :=
  match f with
  | (Fterm t) => ((eval_term sigma pi t) = (Vbool true))
  | (Fand f1 f2) => (eval_fmla sigma pi f1) /\ (eval_fmla sigma pi f2)
  | (Fnot f1) => ~ (eval_fmla sigma pi f1)
  | (Fimplies f1 f2) => (eval_fmla sigma pi f1) -> (eval_fmla sigma pi f2)
  | (Flet x t f1) => (eval_fmla sigma (set pi x (eval_term sigma pi t)) f1)
  | (Fforall x Tint f1) => forall (n:Z), (eval_fmla sigma (set pi x (Vint n))
      f1)
  | (Fforall x Tbool f1) => forall (b:bool), (eval_fmla sigma (set pi x
      (Vbool b)) f1)
  end.
Unset Implicit Arguments.

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
Set Implicit Arguments.
Fixpoint fresh_in_term(id:Z) (t:term) {struct t}: Prop :=
  match t with
  | (Tconst _) => True
  | (Tvar v) => ~ (id = v)
  | (Tderef _) => True
  | (Tbin t1 _ t2) => (fresh_in_term id t1) /\ (fresh_in_term id t2)
  end.
Unset Implicit Arguments.

Axiom eval_subst_term : forall (sigma:(map Z value)) (pi:(map Z value))
  (e:term) (x:Z) (v:Z), (fresh_in_term v e) -> ((eval_term sigma pi
  (subst_term e x v)) = (eval_term (set sigma x (get pi v)) pi e)).

Axiom eval_term_change_free : forall (t:term) (sigma:(map Z value)) (pi:(map
  Z value)) (id:Z) (v:value), (fresh_in_term id t) -> ((eval_term sigma
  (set pi id v) t) = (eval_term sigma pi t)).

(* Why3 assumption *)
Set Implicit Arguments.
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
Unset Implicit Arguments.

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint subst(f:fmla) (x:Z) (v:Z) {struct f}: fmla :=
  match f with
  | (Fterm e) => (Fterm (subst_term e x v))
  | (Fand f1 f2) => (Fand (subst f1 x v) (subst f2 x v))
  | (Fnot f1) => (Fnot (subst f1 x v))
  | (Fimplies f1 f2) => (Fimplies (subst f1 x v) (subst f2 x v))
  | (Flet y t f1) => (Flet y (subst_term t x v) (subst f1 x v))
  | (Fforall y ty f1) => (Fforall y ty (subst f1 x v))
  end.
Unset Implicit Arguments.

Axiom eval_subst : forall (f:fmla) (sigma:(map Z value)) (pi:(map Z value))
  (x:Z) (v:Z), (fresh_in_fmla v f) -> ((eval_fmla sigma pi (subst f x v)) <->
  (eval_fmla (set sigma x (get pi v)) pi f)).

Axiom eval_swap : forall (f:fmla) (sigma:(map Z value)) (pi:(map Z value))
  (id1:Z) (id2:Z) (v1:value) (v2:value), (~ (id1 = id2)) -> ((eval_fmla sigma
  (set (set pi id1 v1) id2 v2) f) <-> (eval_fmla sigma (set (set pi id2 v2)
  id1 v1) f)).

Axiom eval_change_free : forall (f:fmla) (sigma:(map Z value)) (pi:(map Z
  value)) (id:Z) (v:value), (fresh_in_fmla id f) -> ((eval_fmla sigma (set pi
  id v) f) <-> (eval_fmla sigma pi f)).

(* Why3 assumption *)
Inductive stmt  :=
  | Sskip : stmt 
  | Sassign : Z -> term -> stmt 
  | Sseq : stmt -> stmt -> stmt 
  | Sif : term -> stmt -> stmt -> stmt 
  | Sassert : fmla -> stmt 
  | Swhile : term -> fmla -> stmt -> stmt .

Axiom check_skip : forall (s:stmt), (s = Sskip) \/ ~ (s = Sskip).

(* Why3 assumption *)
Inductive one_step : (map Z value) -> (map Z value) -> stmt -> (map Z value)
  -> (map Z value) -> stmt -> Prop :=
  | one_step_assign : forall (sigma:(map Z value)) (pi:(map Z value)) (x:Z)
      (e:term), (one_step sigma pi (Sassign x e) (set sigma x
      (eval_term sigma pi e)) pi Sskip)
  | one_step_seq : forall (sigma:(map Z value)) (pi:(map Z value))
      (sigmaqt:(map Z value)) (piqt:(map Z value)) (i1:stmt) (i1qt:stmt)
      (i2:stmt), (one_step sigma pi i1 sigmaqt piqt i1qt) -> (one_step sigma
      pi (Sseq i1 i2) sigmaqt piqt (Sseq i1qt i2))
  | one_step_seq_skip : forall (sigma:(map Z value)) (pi:(map Z value))
      (i:stmt), (one_step sigma pi (Sseq Sskip i) sigma pi i)
  | one_step_if_true : forall (sigma:(map Z value)) (pi:(map Z value))
      (e:term) (i1:stmt) (i2:stmt), ((eval_term sigma pi
      e) = (Vbool true)) -> (one_step sigma pi (Sif e i1 i2) sigma pi i1)
  | one_step_if_false : forall (sigma:(map Z value)) (pi:(map Z value))
      (e:term) (i1:stmt) (i2:stmt), ((eval_term sigma pi
      e) = (Vbool false)) -> (one_step sigma pi (Sif e i1 i2) sigma pi i2)
  | one_step_assert : forall (sigma:(map Z value)) (pi:(map Z value))
      (f:fmla), (eval_fmla sigma pi f) -> (one_step sigma pi (Sassert f)
      sigma pi Sskip)
  | one_step_while_true : forall (sigma:(map Z value)) (pi:(map Z value))
      (e:term) (inv:fmla) (i:stmt), (eval_fmla sigma pi inv) ->
      (((eval_term sigma pi e) = (Vbool true)) -> (one_step sigma pi
      (Swhile e inv i) sigma pi (Sseq i (Swhile e inv i))))
  | one_step_while_false : forall (sigma:(map Z value)) (pi:(map Z value))
      (e:term) (inv:fmla) (i:stmt), (eval_fmla sigma pi inv) ->
      (((eval_term sigma pi e) = (Vbool false)) -> (one_step sigma pi
      (Swhile e inv i) sigma pi Sskip)).

(* Why3 assumption *)
Inductive many_steps : (map Z value) -> (map Z value) -> stmt -> (map Z
  value) -> (map Z value) -> stmt -> Z -> Prop :=
  | many_steps_refl : forall (sigma:(map Z value)) (pi:(map Z value))
      (i:stmt), (many_steps sigma pi i sigma pi i 0%Z)
  | many_steps_trans : forall (sigma1:(map Z value)) (pi1:(map Z value))
      (sigma2:(map Z value)) (pi2:(map Z value)) (sigma3:(map Z value))
      (pi3:(map Z value)) (i1:stmt) (i2:stmt) (i3:stmt) (n:Z),
      (one_step sigma1 pi1 i1 sigma2 pi2 i2) -> ((many_steps sigma2 pi2 i2
      sigma3 pi3 i3 n) -> (many_steps sigma1 pi1 i1 sigma3 pi3 i3
      (n + 1%Z)%Z)).

Axiom steps_non_neg : forall (sigma1:(map Z value)) (pi1:(map Z value))
  (sigma2:(map Z value)) (pi2:(map Z value)) (i1:stmt) (i2:stmt) (n:Z),
  (many_steps sigma1 pi1 i1 sigma2 pi2 i2 n) -> (0%Z <= n)%Z.

Axiom many_steps_seq : forall (sigma1:(map Z value)) (pi1:(map Z value))
  (sigma3:(map Z value)) (pi3:(map Z value)) (i1:stmt) (i2:stmt) (n:Z),
  (many_steps sigma1 pi1 (Sseq i1 i2) sigma3 pi3 Sskip n) ->
  exists sigma2:(map Z value), exists pi2:(map Z value), exists n1:Z,
  exists n2:Z, (many_steps sigma1 pi1 i1 sigma2 pi2 Sskip n1) /\
  ((many_steps sigma2 pi2 i2 sigma3 pi3 Sskip n2) /\
  (n = ((1%Z + n1)%Z + n2)%Z)).

(* Why3 assumption *)
Definition valid_fmla(p:fmla): Prop := forall (sigma:(map Z value)) (pi:(map
  Z value)), (eval_fmla sigma pi p).

(* Why3 assumption *)
Definition valid_triple(p:fmla) (i:stmt) (q:fmla): Prop := forall (sigma:(map
  Z value)) (pi:(map Z value)), (eval_fmla sigma pi p) ->
  forall (sigmaqt:(map Z value)) (piqt:(map Z value)) (n:Z),
  (many_steps sigma pi i sigmaqt piqt Sskip n) -> (eval_fmla sigmaqt piqt q).

(* Why3 goal *)
Theorem Test42 : ((eval_term (const (Vint 42%Z):(map Z value))
  (const (Vint 0%Z):(map Z value)) (Tvar 0%Z)) = (Vint 42%Z)).
simpl.
rewrite Const.
Qed.


