(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require Import ZOdiv.
(*Add Rec LoadPath "/home/guillaume/bin/why3/share/why3/theories".*)
(*Add Rec LoadPath "/home/guillaume/bin/why3/share/why3/modules".*)
Require int.Int.
Require int.Abs.

Notation div := ZOdiv (only parsing).

Notation mod1 := ZOmod (only parsing).

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Div_mod : forall (x:Z) (y:Z), (~ (y = 0%Z)) -> (x = ((y * (div x
  y))%Z + (mod1 x y))%Z).
(* YOU MAY EDIT THE PROOF BELOW *)
intros x y _.
apply ZO_div_mod_eq.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Div_bound : forall (x:Z) (y:Z), ((0%Z <= x)%Z /\ (0%Z <  y)%Z) ->
  ((0%Z <= (div x y))%Z /\ ((div x y) <= x)%Z).
(* YOU MAY EDIT THE PROOF BELOW *)
intros x y (Hx,Hy).
split.
apply ZO_div_pos with (1 := Hx).
now apply Zlt_le_weak.
destruct (Z_eq_dec y 1) as [H|H].
rewrite H, ZOdiv_1_r.
apply Zle_refl.
destruct (Zle_lt_or_eq 0 x Hx) as [H'|H'].
apply Zlt_le_weak.
apply ZO_div_lt with (1 := H').
omega.
now rewrite <- H', ZOdiv_0_l.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Mod_bound : forall (x:Z) (y:Z), (~ (y = 0%Z)) ->
  (((-(Zabs y))%Z <  (mod1 x y))%Z /\ ((mod1 x y) <  (Zabs y))%Z).
(* YOU MAY EDIT THE PROOF BELOW *)
intros x y Zy.
destruct (Zle_or_lt 0 x) as [Hx|Hx].
refine ((fun H => conj (Zlt_le_trans _ 0 _ _ (proj1 H)) (proj2 H)) _).
clear -Zy ; zify ; omega.
now apply ZOmod_lt_pos.
refine ((fun H => conj (proj1 H) (Zle_lt_trans _ 0 _ (proj2 H) _)) _).
clear -Zy ; zify ; omega.
apply ZOmod_lt_neg with (2 := Zy).
now apply Zlt_le_weak.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Div_sign_pos : forall (x:Z) (y:Z), ((0%Z <= x)%Z /\ (0%Z <  y)%Z) ->
  (0%Z <= (div x y))%Z.
(* YOU MAY EDIT THE PROOF BELOW *)
intros x y (Hx, Hy).
apply ZO_div_pos with (1 := Hx).
now apply Zlt_le_weak.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Div_sign_neg : forall (x:Z) (y:Z), ((x <= 0%Z)%Z /\ (0%Z <  y)%Z) ->
  ((div x y) <= 0%Z)%Z.
(* YOU MAY EDIT THE PROOF BELOW *)
intros x y (Hx, Hy).
generalize (ZO_div_pos (-x) y).
rewrite ZOdiv_opp_l.
omega.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Mod_sign_pos : forall (x:Z) (y:Z), ((0%Z <= x)%Z /\ ~ (y = 0%Z)) ->
  (0%Z <= (mod1 x y))%Z.
(* YOU MAY EDIT THE PROOF BELOW *)
intros x y (Hx, Zy).
now apply ZOmod_lt_pos.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Mod_sign_neg : forall (x:Z) (y:Z), ((x <= 0%Z)%Z /\ ~ (y = 0%Z)) ->
  ((mod1 x y) <= 0%Z)%Z.
(* YOU MAY EDIT THE PROOF BELOW *)
intros x y (Hx, Zy).
now apply ZOmod_lt_neg.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Rounds_toward_zero : forall (x:Z) (y:Z), (~ (y = 0%Z)) ->
  ((Zabs ((div x y) * y)%Z) <= (Zabs x))%Z.
(* YOU MAY EDIT THE PROOF BELOW *)
intros x y Zy.
rewrite Zmult_comm.
zify.
generalize (ZO_mult_div_le x y).
generalize (ZO_mult_div_ge x y).
omega.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Div_1 : forall (x:Z), ((div x 1%Z) = x).
(* YOU MAY EDIT THE PROOF BELOW *)
exact ZOdiv_1_r.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Mod_1 : forall (x:Z), ((mod1 x 1%Z) = 0%Z).
(* YOU MAY EDIT THE PROOF BELOW *)
exact ZOmod_1_r.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Div_inf : forall (x:Z) (y:Z), ((0%Z <= x)%Z /\ (x <  y)%Z) -> ((div x
  y) = 0%Z).
(* YOU MAY EDIT THE PROOF BELOW *)
exact ZOdiv_small.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Mod_inf : forall (x:Z) (y:Z), ((0%Z <= x)%Z /\ (x <  y)%Z) -> ((mod1 x
  y) = x).
(* YOU MAY EDIT THE PROOF BELOW *)
exact ZOmod_small.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Div_mult : forall (x:Z) (y:Z) (z:Z), ((0%Z <  x)%Z /\ ((0%Z <= y)%Z /\
  (0%Z <= z)%Z)) -> ((div ((x * y)%Z + z)%Z x) = (y + (div z x))%Z).
(* YOU MAY EDIT THE PROOF BELOW *)
intros x y z (Hx&Hy&Hz).
rewrite (Zplus_comm y).
rewrite <- ZO_div_plus.
now rewrite Zplus_comm, Zmult_comm.
apply Zmult_le_0_compat with (2 := Hz).
apply Zplus_le_0_compat with (1 := Hz).
apply Zmult_le_0_compat with (1 := Hy).
now apply Zlt_le_weak.
intros H.
now rewrite H in Hx.
Qed.
(* DO NOT EDIT BELOW *)

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Lemma Mod_mult : forall (x:Z) (y:Z) (z:Z), ((0%Z <  x)%Z /\ ((0%Z <= y)%Z /\
  (0%Z <= z)%Z)) -> ((mod1 ((x * y)%Z + z)%Z x) = (mod1 z x)).
(* YOU MAY EDIT THE PROOF BELOW *)
intros x y z (Hx&Hy&Hz).
rewrite Zplus_comm, Zmult_comm.
apply ZO_mod_plus.
apply Zmult_le_0_compat with (2 := Hz).
apply Zplus_le_0_compat with (1 := Hz).
apply Zmult_le_0_compat with (1 := Hy).
now apply Zlt_le_weak.
Qed.
(* DO NOT EDIT BELOW *)


