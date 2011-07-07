(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Definition unit  := unit.

Parameter mark : Type.

Parameter at1: forall (a:Type), a -> mark  -> a.

Implicit Arguments at1.

Parameter old: forall (a:Type), a  -> a.

Implicit Arguments old.

Parameter map : forall (a:Type) (b:Type), Type.

Parameter get: forall (a:Type) (b:Type), (map a b) -> a  -> b.

Implicit Arguments get.

Parameter set: forall (a:Type) (b:Type), (map a b) -> a -> b  -> (map a b).

Implicit Arguments set.

Axiom Select_eq : forall (a:Type) (b:Type), forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (a1 = a2) -> ((get (set m a1 b1)
  a2) = b1).

Axiom Select_neq : forall (a:Type) (b:Type), forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (~ (a1 = a2)) -> ((get (set m a1 b1)
  a2) = (get m a2)).

Parameter const: forall (b:Type) (a:Type), b  -> (map a b).

Set Contextual Implicit.
Implicit Arguments const.
Unset Contextual Implicit.

Axiom Const : forall (b:Type) (a:Type), forall (b1:b) (a1:a), ((get (const(
  b1):(map a b)) a1) = b1).

Inductive array (a:Type) :=
  | mk_array : Z -> (map Z a) -> array a.
Implicit Arguments mk_array.

Definition elts (a:Type)(u:(array a)): (map Z a) :=
  match u with
  | mk_array _ elts1 => elts1
  end.
Implicit Arguments elts.

Definition length (a:Type)(u:(array a)): Z :=
  match u with
  | mk_array length1 _ => length1
  end.
Implicit Arguments length.

Definition get1 (a:Type)(a1:(array a)) (i:Z): a := (get (elts a1) i).
Implicit Arguments get1.

Definition set1 (a:Type)(a1:(array a)) (i:Z) (v:a): (array a) :=
  match a1 with
  | mk_array xcl0 _ => (mk_array xcl0 (set (elts a1) i v))
  end.
Implicit Arguments set1.

Definition injective(a:(array Z)) (n:Z): Prop := forall (i:Z) (j:Z),
  ((0%Z <= i)%Z /\ (i <  n)%Z) -> (((0%Z <= j)%Z /\ (j <  n)%Z) ->
  ((~ (i = j)) -> ~ ((get1 a i) = (get1 a j)))).

Definition surjective(a:(array Z)) (n:Z): Prop := forall (i:Z),
  ((0%Z <= i)%Z /\ (i <  n)%Z) -> exists j:Z, ((0%Z <= j)%Z /\ (j <  n)%Z) /\
  ((get1 a j) = i).

Definition range(a:(array Z)) (n:Z): Prop := forall (i:Z), ((0%Z <= i)%Z /\
  (i <  n)%Z) -> ((0%Z <= (get1 a i))%Z /\ ((get1 a i) <  n)%Z).

Axiom injective_surjective : forall (a:(array Z)) (n:Z), (injective a n) ->
  ((range a n) -> (surjective a n)).

Theorem WP_parameter_inverting : forall (a:Z), forall (b:Z), forall (n:Z),
  forall (a1:(map Z Z)), let a2 := (mk_array a a1) in (((((0%Z <= n)%Z /\
  (n = a)) /\ (a = b)) /\ ((injective a2 n) /\ (range a2 n))) ->
  ((0%Z <= (n - 1%Z)%Z)%Z -> forall (b1:(map Z Z)), (forall (j:Z),
  ((0%Z <= j)%Z /\ (j <  ((n - 1%Z)%Z + 1%Z)%Z)%Z) -> ((get b1 (get a1
  j)) = j)) -> (injective (mk_array b b1) n))).
(* YOU MAY EDIT THE PROOF BELOW *)
intuition.
intuition.
red; intros.
unfold get1; simpl.
assert (surjective (mk_array a a1) n).
apply injective_surjective; assumption.
generalize (H9 i H6); unfold get1; simpl; intros (i1, (Hi1,Hi2)).
generalize (H9 j H7); unfold get1; simpl; intros (j1, (Hj1,Hj2)).
rewrite <- Hi2.
rewrite <- Hj2.
rewrite H; try omega.
rewrite H; try omega.
intro.
apply H8.
subst.
auto.
Qed.
(* DO NOT EDIT BELOW *)


