(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require int.Int.

(* Why3 assumption *)
Definition unit  := unit.

Parameter qtmark : Type.

Parameter at1: forall (a:Type), a -> qtmark -> a.
Implicit Arguments at1.

Parameter old: forall (a:Type), a -> a.
Implicit Arguments old.

(* Why3 assumption *)
Definition implb(x:bool) (y:bool): bool := match (x,
  y) with
  | (true, false) => false
  | (_, _) => true
  end.

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
Inductive ref (a:Type) :=
  | mk_ref : a -> ref a.
Implicit Arguments mk_ref.

(* Why3 assumption *)
Definition contents (a:Type)(v:(ref a)): a :=
  match v with
  | (mk_ref x) => x
  end.
Implicit Arguments contents.

(* Why3 assumption *)
Inductive color  :=
  | Blue : color 
  | White : color 
  | Red : color .

(* Why3 assumption *)
Definition monochrome(a:(map Z color)) (i:Z) (j:Z) (c:color): Prop :=
  forall (k:Z), ((i <= k)%Z /\ (k < j)%Z) -> ((get a k) = c).

Parameter nb_occ: (map Z color) -> Z -> Z -> color -> Z.

Axiom nb_occ_null : forall (a:(map Z color)) (i:Z) (j:Z) (c:color),
  (j <= i)%Z -> ((nb_occ a i j c) = 0%Z).

Axiom nb_occ_add_eq : forall (a:(map Z color)) (i:Z) (j:Z) (c:color),
  ((i < j)%Z /\ ((get a (j - 1%Z)%Z) = c)) -> ((nb_occ a i j c) = ((nb_occ a
  i (j - 1%Z)%Z c) + 1%Z)%Z).

Axiom nb_occ_add_neq : forall (a:(map Z color)) (i:Z) (j:Z) (c:color),
  ((i < j)%Z /\ ~ ((get a (j - 1%Z)%Z) = c)) -> ((nb_occ a i j c) = (nb_occ a
  i (j - 1%Z)%Z c)).

Axiom nb_occ_split : forall (a:(map Z color)) (i:Z) (j:Z) (k:Z) (c:color),
  ((i <= j)%Z /\ (j <= k)%Z) -> ((nb_occ a i k c) = ((nb_occ a i j
  c) + (nb_occ a j k c))%Z).

Axiom nb_occ_store_outside_up : forall (a:(map Z color)) (i:Z) (j:Z) (k:Z)
  (c:color), ((i <= j)%Z /\ (j <= k)%Z) -> ((nb_occ (set a k c) i j
  c) = (nb_occ a i j c)).


Open Scope Z_scope.
Require Import Why3.
Ltac ae := why3 "alt-ergo" timelimit 3.

(* Why3 goal *)
Theorem nb_occ_store_outside_down : forall (a:(map Z color)) (i:Z) (j:Z)
  (k:Z) (c:color), ((k < i)%Z /\ (i <= j)%Z) -> ((nb_occ (set a k c) i j
  c) = (nb_occ a i j c)).
intros a i j k c (h1 & h2).
generalize h2.
pattern j; apply Zlt_lower_bound_ind with (z:=i); auto.
ae.
Qed.


