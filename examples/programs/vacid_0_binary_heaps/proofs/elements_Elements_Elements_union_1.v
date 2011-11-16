(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Parameter bag : forall (a:Type), Type.

Parameter nb_occ: forall (a:Type), a -> (bag a) -> Z.

Implicit Arguments nb_occ.

Axiom occ_non_negative : forall (a:Type), forall (b:(bag a)) (x:a),
  (0%Z <= (nb_occ x b))%Z.

Definition eq_bag (a:Type)(a1:(bag a)) (b:(bag a)): Prop := forall (x:a),
  ((nb_occ x a1) = (nb_occ x b)).
Implicit Arguments eq_bag.

Axiom bag_extensionality : forall (a:Type), forall (a1:(bag a)) (b:(bag a)),
  (eq_bag a1 b) -> (a1 = b).

Parameter empty_bag: forall (a:Type), (bag a).

Set Contextual Implicit.
Implicit Arguments empty_bag.
Unset Contextual Implicit.

Axiom occ_empty : forall (a:Type), forall (x:a), ((nb_occ x (empty_bag:(bag
  a))) = 0%Z).

Axiom is_empty : forall (a:Type), forall (b:(bag a)), (forall (x:a),
  ((nb_occ x b) = 0%Z)) -> (b = (empty_bag:(bag a))).

Parameter singleton: forall (a:Type), a -> (bag a).

Implicit Arguments singleton.

Axiom occ_singleton : forall (a:Type), forall (x:a) (y:a), ((x = y) /\
  ((nb_occ y (singleton x)) = 1%Z)) \/ ((~ (x = y)) /\ ((nb_occ y
  (singleton x)) = 0%Z)).

Axiom occ_singleton_eq : forall (a:Type), forall (x:a) (y:a), (x = y) ->
  ((nb_occ y (singleton x)) = 1%Z).

Axiom occ_singleton_neq : forall (a:Type), forall (x:a) (y:a), (~ (x = y)) ->
  ((nb_occ y (singleton x)) = 0%Z).

Parameter union: forall (a:Type), (bag a) -> (bag a) -> (bag a).

Implicit Arguments union.

Axiom occ_union : forall (a:Type), forall (x:a) (a1:(bag a)) (b:(bag a)),
  ((nb_occ x (union a1 b)) = ((nb_occ x a1) + (nb_occ x b))%Z).

Axiom Union_comm : forall (a:Type), forall (a1:(bag a)) (b:(bag a)),
  ((union a1 b) = (union b a1)).

Axiom Union_identity : forall (a:Type), forall (a1:(bag a)), ((union a1
  (empty_bag:(bag a))) = a1).

Axiom Union_assoc : forall (a:Type), forall (a1:(bag a)) (b:(bag a)) (c:(bag
  a)), ((union a1 (union b c)) = (union (union a1 b) c)).

Axiom bag_simpl : forall (a:Type), forall (a1:(bag a)) (b:(bag a)) (c:(bag
  a)), ((union a1 b) = (union c b)) -> (a1 = c).

Axiom bag_simpl_left : forall (a:Type), forall (a1:(bag a)) (b:(bag a))
  (c:(bag a)), ((union a1 b) = (union a1 c)) -> (b = c).

Definition add (a:Type)(x:a) (b:(bag a)): (bag a) := (union (singleton x) b).
Implicit Arguments add.

Axiom occ_add_eq : forall (a:Type), forall (b:(bag a)) (x:a) (y:a),
  (x = y) -> ((nb_occ x (add x b)) = ((nb_occ x b) + 1%Z)%Z).

Axiom occ_add_neq : forall (a:Type), forall (b:(bag a)) (x:a) (y:a),
  (~ (x = y)) -> ((nb_occ y (add x b)) = (nb_occ y b)).

Parameter card: forall (a:Type), (bag a) -> Z.

Implicit Arguments card.

Axiom Card_empty : forall (a:Type), ((card (empty_bag:(bag a))) = 0%Z).

Axiom Card_singleton : forall (a:Type), forall (x:a),
  ((card (singleton x)) = 1%Z).

Axiom Card_union : forall (a:Type), forall (x:(bag a)) (y:(bag a)),
  ((card (union x y)) = ((card x) + (card y))%Z).

Axiom Card_zero_empty : forall (a:Type), forall (x:(bag a)),
  ((card x) = 0%Z) -> (x = (empty_bag:(bag a))).

Axiom Max_is_ge : forall (x:Z) (y:Z), (x <= (Zmax x y))%Z /\
  (y <= (Zmax x y))%Z.

Axiom Max_is_some : forall (x:Z) (y:Z), ((Zmax x y) = x) \/ ((Zmax x y) = y).

Axiom Min_is_le : forall (x:Z) (y:Z), ((Zmin x y) <= x)%Z /\
  ((Zmin x y) <= y)%Z.

Axiom Min_is_some : forall (x:Z) (y:Z), ((Zmin x y) = x) \/ ((Zmin x y) = y).

Axiom Max_x : forall (x:Z) (y:Z), (y <= x)%Z -> ((Zmax x y) = x).

Axiom Max_y : forall (x:Z) (y:Z), (x <= y)%Z -> ((Zmax x y) = y).

Axiom Min_x : forall (x:Z) (y:Z), (x <= y)%Z -> ((Zmin x y) = x).

Axiom Min_y : forall (x:Z) (y:Z), (y <= x)%Z -> ((Zmin x y) = y).

Axiom Max_sym : forall (x:Z) (y:Z), (y <= x)%Z -> ((Zmax x y) = (Zmax y x)).

Axiom Min_sym : forall (x:Z) (y:Z), (y <= x)%Z -> ((Zmin x y) = (Zmin y x)).

Parameter diff: forall (a:Type), (bag a) -> (bag a) -> (bag a).

Implicit Arguments diff.

Axiom Diff_occ : forall (a:Type), forall (b1:(bag a)) (b2:(bag a)) (x:a),
  ((nb_occ x (diff b1 b2)) = (Zmax 0%Z ((nb_occ x b1) - (nb_occ x b2))%Z)).

Axiom Diff_empty_right : forall (a:Type), forall (b:(bag a)), ((diff b
  (empty_bag:(bag a))) = b).

Axiom Diff_empty_left : forall (a:Type), forall (b:(bag a)),
  ((diff (empty_bag:(bag a)) b) = (empty_bag:(bag a))).

Axiom Diff_add : forall (a:Type), forall (b:(bag a)) (x:a), ((diff (add x b)
  (singleton x)) = b).

Axiom Diff_comm : forall (a:Type), forall (b:(bag a)) (b1:(bag a)) (b2:(bag
  a)), ((diff (diff b b1) b2) = (diff (diff b b2) b1)).

Axiom Add_diff : forall (a:Type), forall (b:(bag a)) (x:a), (0%Z <  (nb_occ x
  b))%Z -> ((add x (diff b (singleton x))) = b).

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

Definition array (a:Type) := (map Z a).

Parameter elements: forall (a:Type), (map Z a) -> Z -> Z -> (bag a).

Implicit Arguments elements.

Axiom Elements_empty : forall (a:Type), forall (a1:(map Z a)) (i:Z) (j:Z),
  (j <= i)%Z -> ((elements a1 i j) = (empty_bag:(bag a))).

Axiom Elements_add : forall (a:Type), forall (a1:(map Z a)) (i:Z) (j:Z),
  (i <  j)%Z -> ((elements a1 i j) = (add (get a1 (j - 1%Z)%Z) (elements a1 i
  (j - 1%Z)%Z))).

Axiom Elements_singleton : forall (a:Type), forall (a1:(map Z a)) (i:Z)
  (j:Z), (j = (i + 1%Z)%Z) -> ((elements a1 i j) = (singleton (get a1 i))).

(* YOU MAY EDIT THE CONTEXT BELOW *)

(* DO NOT EDIT BELOW *)

Theorem Elements_union : forall (a:Type), forall (a1:(map Z a)) (i:Z) (j:Z)
  (k:Z), ((i <= j)%Z /\ (j <= k)%Z) -> ((elements a1 i
  k) = (union (elements a1 i j) (elements a1 j k))).
(* YOU MAY EDIT THE PROOF BELOW *)
intros X a i j k (H0, H1).
apply Zlt_lower_bound_ind with (z := j)
     (P := fun k => elements a i k = union (elements a i j) (elements a j k)); auto.
intros x H_ind H.
assert (h: (j = x \/ j < x)%Z) by omega.
  destruct h.
  (*  j = x *)
  subst x.
   rewrite Elements_empty with (i := j); auto.
   rewrite Union_identity; auto.
   (* j < x *)
   rewrite Elements_add with (i := j); auto.
   rewrite Elements_add with (i := i); auto with zarith.
   unfold add.
   rewrite H_ind with (y := (x - 1)%Z); auto with zarith.
   apply bag_extensionality.
   intro z.
   repeat rewrite occ_union; auto with zarith.
Qed.
(* DO NOT EDIT BELOW *)


