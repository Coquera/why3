(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require int.Int.
Require real.Real.
Require real.RealInfix.

Parameter pow2: Z -> R.

Axiom Power_0 : ((pow2 0%Z) = 1%R).

Axiom Power_s : forall (n:Z), (0%Z <= n)%Z ->
  ((pow2 (n + 1%Z)%Z) = (2%R * (pow2 n))%R).

Axiom Power_p : forall (n:Z), (n <= 0%Z)%Z ->
  ((pow2 (n - 1%Z)%Z) = ((05 / 10)%R * (pow2 n))%R).

Axiom Power_s_all : forall (n:Z), ((pow2 (n + 1%Z)%Z) = (2%R * (pow2 n))%R).

Axiom Power_p_all : forall (n:Z),
  ((pow2 (n - 1%Z)%Z) = ((05 / 10)%R * (pow2 n))%R).

Axiom Power_1_2 : ((05 / 10)%R = (Rdiv 1%R 2%R)%R).

Axiom Power_1 : ((pow2 1%Z) = 2%R).

Axiom Power_neg1 : ((pow2 (-1%Z)%Z) = (05 / 10)%R).

Require Import Why3.
Ltac ae := why3 "alt-ergo" timelimit 2.

(* Why3 goal *)
Theorem Power_non_null_aux : forall (n:Z), (0%Z <= n)%Z ->
  ~ ((pow2 n) = 0%R).
intros n Hn. 
generalize Hn.
pattern n; apply Z_lt_induction; auto.
ae.
Qed.


