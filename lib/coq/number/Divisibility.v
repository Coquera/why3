(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require Import ZOdiv.
Require int.Int.
Require int.Abs.
Require int.EuclideanDivision.
Require int.ComputerDivision.
Require number.Parity.

(* Hack so that Why3 does not override the notation below.

(* Why3 assumption *)
Definition divides(d:Z) (n:Z): Prop := exists q:Z, (n = (q * d)%Z).

*)

Require Import Znumtheory.
Notation divides := Zdivide (only parsing).

(* Why3 goal *)
Lemma divides_refl : forall (n:Z), (divides n n).
Proof.
exact Zdivide_refl.
Qed.

(* Why3 goal *)
Lemma divides_1_n : forall (n:Z), (divides 1%Z n).
Proof.
exact Zone_divide.
Qed.

(* Why3 goal *)
Lemma divides_0 : forall (n:Z), (divides n 0%Z).
Proof.
exact Zdivide_0.
Qed.

(* Why3 goal *)
Lemma divides_left : forall (a:Z) (b:Z) (c:Z), (divides a b) ->
  (divides (c * a)%Z (c * b)%Z).
Proof.
exact Zmult_divide_compat_l.
Qed.

(* Why3 goal *)
Lemma divides_right : forall (a:Z) (b:Z) (c:Z), (divides a b) ->
  (divides (a * c)%Z (b * c)%Z).
Proof.
exact Zmult_divide_compat_r.
Qed.

(* Why3 goal *)
Lemma divides_oppr : forall (a:Z) (b:Z), (divides a b) -> (divides a (-b)%Z).
Proof.
exact Zdivide_opp_r.
Qed.

(* Why3 goal *)
Lemma divides_oppl : forall (a:Z) (b:Z), (divides a b) -> (divides (-a)%Z b).
Proof.
exact Zdivide_opp_l.
Qed.

(* Why3 goal *)
Lemma divides_oppr_rev : forall (a:Z) (b:Z), (divides (-a)%Z b) -> (divides a
  b).
Proof.
exact Zdivide_opp_l_rev.
Qed.

(* Why3 goal *)
Lemma divides_oppl_rev : forall (a:Z) (b:Z), (divides a (-b)%Z) -> (divides a
  b).
Proof.
exact Zdivide_opp_r_rev.
Qed.

(* Why3 goal *)
Lemma divides_plusr : forall (a:Z) (b:Z) (c:Z), (divides a b) -> ((divides a
  c) -> (divides a (b + c)%Z)).
Proof.
exact Zdivide_plus_r.
Qed.

(* Why3 goal *)
Lemma divides_minusr : forall (a:Z) (b:Z) (c:Z), (divides a b) -> ((divides a
  c) -> (divides a (b - c)%Z)).
Proof.
exact Zdivide_minus_l.
Qed.

(* Why3 goal *)
Lemma divides_multl : forall (a:Z) (b:Z) (c:Z), (divides a b) -> (divides a
  (c * b)%Z).
Proof.
intros a b c.
apply Zdivide_mult_r.
Qed.

(* Why3 goal *)
Lemma divides_multr : forall (a:Z) (b:Z) (c:Z), (divides a b) -> (divides a
  (b * c)%Z).
Proof.
exact Zdivide_mult_l.
Qed.

(* Why3 goal *)
Lemma divides_factorl : forall (a:Z) (b:Z), (divides a (b * a)%Z).
Proof.
exact Zdivide_factor_l.
Qed.

(* Why3 goal *)
Lemma divides_factorr : forall (a:Z) (b:Z), (divides a (a * b)%Z).
Proof.
exact Zdivide_factor_r.
Qed.

(* Why3 goal *)
Lemma divides_n_1 : forall (n:Z), (divides n 1%Z) -> ((n = 1%Z) \/
  (n = (-1%Z)%Z)).
Proof.
exact Zdivide_1.
Qed.

(* Why3 goal *)
Lemma divides_antisym : forall (a:Z) (b:Z), (divides a b) -> ((divides b
  a) -> ((a = b) \/ (a = (-b)%Z))).
Proof.
exact Zdivide_antisym.
Qed.

(* Why3 goal *)
Lemma divides_trans : forall (a:Z) (b:Z) (c:Z), (divides a b) -> ((divides b
  c) -> (divides a c)).
Proof.
exact Zdivide_trans.
Qed.

(* Why3 goal *)
Lemma divides_bounds : forall (a:Z) (b:Z), (divides a b) -> ((~ (b = 0%Z)) ->
  ((Zabs a) <= (Zabs b))%Z).
Proof.
exact Zdivide_bounds.
Qed.

Import EuclideanDivision.

(* Why3 goal *)
Lemma mod_divides_euclidean : forall (a:Z) (b:Z), (~ (b = 0%Z)) ->
  (((int.EuclideanDivision.mod1 a b) = 0%Z) -> (divides b a)).
Proof.
intros a b Zb H.
exists (div a b).
rewrite (Div_mod a b Zb) at 1.
rewrite H.
ring.
Qed.

(* Why3 goal *)
Lemma divides_mod_euclidean : forall (a:Z) (b:Z), (~ (b = 0%Z)) ->
  ((divides b a) -> ((int.EuclideanDivision.mod1 a b) = 0%Z)).
Proof.
intros a b Zb H.
assert (Zmod a b = Z0).
now apply Zdivide_mod.
unfold mod1, div.
rewrite H0.
case Z_le_dec ; intros H1.
rewrite (Z_div_exact_full_2 a b Zb H0) at 1.
apply Zminus_diag.
now elim H1.
Qed.

(* Why3 goal *)
Lemma mod_divides_computer : forall (a:Z) (b:Z), (~ (b = 0%Z)) ->
  (((ZOmod a b) = 0%Z) -> (divides b a)).
Proof.
intros a b Zb H.
exists (ZOdiv a b).
rewrite Zmult_comm.
now apply ZO_div_exact_full_2.
Qed.

(* Why3 goal *)
Lemma divides_mod_computer : forall (a:Z) (b:Z), (~ (b = 0%Z)) -> ((divides b
  a) -> ((ZOmod a b) = 0%Z)).
Proof.
intros a b Zb (q,H).
rewrite H.
apply ZO_mod_mult.
Qed.

(* Why3 goal *)
Lemma even_divides : forall (a:Z), (number.Parity.even a) <-> (divides 2%Z
  a).
Proof.
split ;
  intros (q,H) ; exists q ; now rewrite Zmult_comm.
Qed.

(* Why3 goal *)
Lemma odd_divides : forall (a:Z), (number.Parity.odd a) <-> ~ (divides 2%Z
  a).
Proof.
split.
intros H.
contradict H.
apply Parity.even_not_odd.
now apply <- even_divides.
intros H.
destruct (Parity.even_or_odd a).
elim H.
now apply -> even_divides.
exact H0.
Qed.


