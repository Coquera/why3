(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.
Require int.MinMax.
Require list.List.
Require list.Length.
Require list.Mem.
Require list.Append.

Axiom char : Type.
Parameter char_WhyType : WhyType char.
Existing Instance char_WhyType.

(* Why3 assumption *)
Definition word := (list char).

(* Why3 assumption *)
Inductive dist : (list char) -> (list char) -> Z -> Prop :=
  | dist_eps : (dist nil nil 0%Z)
  | dist_add_left : forall (w1:(list char)) (w2:(list char)) (n:Z), (dist w1
      w2 n) -> forall (a:char), (dist (cons a w1) w2 (n + 1%Z)%Z)
  | dist_add_right : forall (w1:(list char)) (w2:(list char)) (n:Z), (dist w1
      w2 n) -> forall (a:char), (dist w1 (cons a w2) (n + 1%Z)%Z)
  | dist_context : forall (w1:(list char)) (w2:(list char)) (n:Z), (dist w1
      w2 n) -> forall (a:char), (dist (cons a w1) (cons a w2) n).

(* Why3 assumption *)
Definition min_dist (w1:(list char)) (w2:(list char)) (n:Z): Prop := (dist w1
  w2 n) /\ forall (m:Z), (dist w1 w2 m) -> (n <= m)%Z.

(* Why3 assumption *)
Fixpoint last_char (a:char) (u:(list char)) {struct u}: char :=
  match u with
  | nil => a
  | (cons c u') => (last_char c u')
  end.

(* Why3 assumption *)
Fixpoint but_last (a:char) (u:(list char)) {struct u}: (list char) :=
  match u with
  | nil => nil
  | (cons c u') => (cons a (but_last c u'))
  end.

Axiom first_last_explicit : forall (u:(list char)) (a:char),
  ((List.app (but_last a u) (cons (last_char a u) nil)) = (cons a u)).

Axiom first_last : forall (a:char) (u:(list char)), exists v:(list char),
  exists b:char, ((List.app v (cons b nil)) = (cons a u)) /\
  ((list.Length.length v) = (list.Length.length u)).

Axiom key_lemma_right : forall (w1:(list char)) (w'2:(list char)) (m:Z)
  (a:char), (dist w1 w'2 m) -> forall (w2:(list char)),
  (w'2 = (cons a w2)) -> exists u1:(list char), exists v1:(list char),
  exists k:Z, (w1 = (List.app u1 v1)) /\ ((dist v1 w2 k) /\
  ((k + (list.Length.length u1))%Z <= (m + 1%Z)%Z)%Z).

Axiom dist_symetry : forall (w1:(list char)) (w2:(list char)) (n:Z), (dist w1
  w2 n) -> (dist w2 w1 n).

Axiom key_lemma_left : forall (w1:(list char)) (w2:(list char)) (m:Z)
  (a:char), (dist (cons a w1) w2 m) -> exists u2:(list char),
  exists v2:(list char), exists k:Z, (w2 = (List.app u2 v2)) /\ ((dist w1 v2
  k) /\ ((k + (list.Length.length u2))%Z <= (m + 1%Z)%Z)%Z).

Axiom dist_concat_left : forall (u:(list char)) (v:(list char))
  (w:(list char)) (n:Z), (dist v w n) -> (dist (List.app u v) w
  ((list.Length.length u) + n)%Z).

Axiom dist_concat_right : forall (u:(list char)) (v:(list char))
  (w:(list char)) (n:Z), (dist v w n) -> (dist v (List.app u w)
  ((list.Length.length u) + n)%Z).


(* Why3 goal *)
Theorem min_dist_equal : forall (w1:(list char)) (w2:(list char)) (a:char)
  (n:Z), (min_dist w1 w2 n) -> (min_dist (cons a w1) (cons a w2) n).
(* Why3 intros w1 w2 a n h1. *)
intros w1 w2 a n.
unfold min_dist.
generalize dist_context; intuition.

inversion H0.

elim (key_lemma_right w1 (cons a w2) n0 a H7 w2);
 [ idtac | reflexivity ].
intros u1 Hex; elim Hex; clear Hex.
intros v1 Hex; elim Hex; clear Hex.
intros k Hex.
 decompose [and] Hex; clear Hex.
generalize (dist_concat_left u1 v1 w2 k H10); intro.
apply Zle_trans with (Length.length u1 + k)%Z.
apply H2.
rewrite H8; assumption.
omega.
elim (key_lemma_left w1 w2 n0 a H7).
intros u2 Hex; elim Hex; clear Hex.
intros v2 Hex; elim Hex; clear Hex.
intros k Hex.
 decompose [and] Hex; clear Hex.
generalize (dist_concat_right u2 w1 v2 k H10); intro.
apply Zle_trans with (Length.length u2 + k)%Z.
apply H2.
rewrite H8; assumption.
omega.
auto.
Qed.


