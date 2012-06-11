(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require int.Int.

(* Why3 assumption *)
Inductive list (a:Type) :=
  | Nil : list a
  | Cons : a -> (list a) -> list a.
Set Contextual Implicit.
Implicit Arguments Nil.
Unset Contextual Implicit.
Implicit Arguments Cons.

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint length (a:Type)(l:(list a)) {struct l}: Z :=
  match l with
  | Nil => 0%Z
  | (Cons _ r) => (1%Z + (length r))%Z
  end.
Unset Implicit Arguments.

Axiom Length_nonnegative : forall (a:Type), forall (l:(list a)),
  (0%Z <= (length l))%Z.

Axiom Length_nil : forall (a:Type), forall (l:(list a)),
  ((length l) = 0%Z) <-> (l = (Nil :(list a))).

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint infix_plpl (a:Type)(l1:(list a)) (l2:(list a)) {struct l1}: (list
  a) :=
  match l1 with
  | Nil => l2
  | (Cons x1 r1) => (Cons x1 (infix_plpl r1 l2))
  end.
Unset Implicit Arguments.

Axiom Append_assoc : forall (a:Type), forall (l1:(list a)) (l2:(list a))
  (l3:(list a)), ((infix_plpl l1 (infix_plpl l2
  l3)) = (infix_plpl (infix_plpl l1 l2) l3)).

Axiom Append_l_nil : forall (a:Type), forall (l:(list a)), ((infix_plpl l
  (Nil :(list a))) = l).

Axiom Append_length : forall (a:Type), forall (l1:(list a)) (l2:(list a)),
  ((length (infix_plpl l1 l2)) = ((length l1) + (length l2))%Z).

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint mem (a:Type)(x:a) (l:(list a)) {struct l}: Prop :=
  match l with
  | Nil => False
  | (Cons y r) => (x = y) \/ (mem x r)
  end.
Unset Implicit Arguments.

Axiom mem_append : forall (a:Type), forall (x:a) (l1:(list a)) (l2:(list a)),
  (mem x (infix_plpl l1 l2)) <-> ((mem x l1) \/ (mem x l2)).

Axiom mem_decomp : forall (a:Type), forall (x:a) (l:(list a)), (mem x l) ->
  exists l1:(list a), exists l2:(list a), (l = (infix_plpl l1 (Cons x l2))).

Parameter set : forall (a:Type), Type.

Parameter mem1: forall (a:Type), a -> (set a) -> Prop.
Implicit Arguments mem1.

(* Why3 assumption *)
Definition infix_eqeq (a:Type)(s1:(set a)) (s2:(set a)): Prop :=
  forall (x:a), (mem1 x s1) <-> (mem1 x s2).
Implicit Arguments infix_eqeq.

Axiom extensionality : forall (a:Type), forall (s1:(set a)) (s2:(set a)),
  (infix_eqeq s1 s2) -> (s1 = s2).

(* Why3 assumption *)
Definition subset (a:Type)(s1:(set a)) (s2:(set a)): Prop := forall (x:a),
  (mem1 x s1) -> (mem1 x s2).
Implicit Arguments subset.

Axiom subset_trans : forall (a:Type), forall (s1:(set a)) (s2:(set a))
  (s3:(set a)), (subset s1 s2) -> ((subset s2 s3) -> (subset s1 s3)).

Parameter empty: forall (a:Type), (set a).
Set Contextual Implicit.
Implicit Arguments empty.
Unset Contextual Implicit.

(* Why3 assumption *)
Definition is_empty (a:Type)(s:(set a)): Prop := forall (x:a), ~ (mem1 x s).
Implicit Arguments is_empty.

Axiom empty_def1 : forall (a:Type), (is_empty (empty :(set a))).

Parameter add: forall (a:Type), a -> (set a) -> (set a).
Implicit Arguments add.

Axiom add_def1 : forall (a:Type), forall (x:a) (y:a), forall (s:(set a)),
  (mem1 x (add y s)) <-> ((x = y) \/ (mem1 x s)).

Parameter remove: forall (a:Type), a -> (set a) -> (set a).
Implicit Arguments remove.

Axiom remove_def1 : forall (a:Type), forall (x:a) (y:a) (s:(set a)), (mem1 x
  (remove y s)) <-> ((~ (x = y)) /\ (mem1 x s)).

Axiom subset_remove : forall (a:Type), forall (x:a) (s:(set a)),
  (subset (remove x s) s).

Parameter union: forall (a:Type), (set a) -> (set a) -> (set a).
Implicit Arguments union.

Axiom union_def1 : forall (a:Type), forall (s1:(set a)) (s2:(set a)) (x:a),
  (mem1 x (union s1 s2)) <-> ((mem1 x s1) \/ (mem1 x s2)).

Parameter inter: forall (a:Type), (set a) -> (set a) -> (set a).
Implicit Arguments inter.

Axiom inter_def1 : forall (a:Type), forall (s1:(set a)) (s2:(set a)) (x:a),
  (mem1 x (inter s1 s2)) <-> ((mem1 x s1) /\ (mem1 x s2)).

Parameter diff: forall (a:Type), (set a) -> (set a) -> (set a).
Implicit Arguments diff.

Axiom diff_def1 : forall (a:Type), forall (s1:(set a)) (s2:(set a)) (x:a),
  (mem1 x (diff s1 s2)) <-> ((mem1 x s1) /\ ~ (mem1 x s2)).

Axiom subset_diff : forall (a:Type), forall (s1:(set a)) (s2:(set a)),
  (subset (diff s1 s2) s1).

Parameter choose: forall (a:Type), (set a) -> a.
Implicit Arguments choose.

Axiom choose_def : forall (a:Type), forall (s:(set a)), (~ (is_empty s)) ->
  (mem1 (choose s) s).

Parameter all: forall (a:Type), (set a).
Set Contextual Implicit.
Implicit Arguments all.
Unset Contextual Implicit.

Axiom all_def : forall (a:Type), forall (x:a), (mem1 x (all :(set a))).

Parameter cardinal: forall (a:Type), (set a) -> Z.
Implicit Arguments cardinal.

Axiom cardinal_nonneg : forall (a:Type), forall (s:(set a)),
  (0%Z <= (cardinal s))%Z.

Axiom cardinal_empty : forall (a:Type), forall (s:(set a)),
  ((cardinal s) = 0%Z) <-> (is_empty s).

Axiom cardinal_add : forall (a:Type), forall (x:a), forall (s:(set a)),
  (~ (mem1 x s)) -> ((cardinal (add x s)) = (1%Z + (cardinal s))%Z).

Axiom cardinal_remove : forall (a:Type), forall (x:a), forall (s:(set a)),
  (mem1 x s) -> ((cardinal s) = (1%Z + (cardinal (remove x s)))%Z).

Axiom cardinal_subset : forall (a:Type), forall (s1:(set a)) (s2:(set a)),
  (subset s1 s2) -> ((cardinal s1) <= (cardinal s2))%Z.

Axiom cardinal1 : forall (a:Type), forall (s:(set a)),
  ((cardinal s) = 1%Z) -> forall (x:a), (mem1 x s) -> (x = (choose s)).

Parameter nth: forall (a:Type), Z -> (set a) -> a.
Implicit Arguments nth.

Axiom nth_injective : forall (a:Type), forall (s:(set a)) (i:Z) (j:Z),
  ((0%Z <= i)%Z /\ (i <  (cardinal s))%Z) -> (((0%Z <= j)%Z /\
  (j <  (cardinal s))%Z) -> (((nth i s) = (nth j s)) -> (i = j))).

Axiom nth_surjective : forall (a:Type), forall (s:(set a)) (x:a), (mem1 x
  s) -> exists i:Z, ((0%Z <= i)%Z /\ (i <  (cardinal s))%Z) -> (x = (nth i
  s)).

Parameter t : Type.

(* Why3 assumption *)
Definition pigeon_set(s:(set t)): Prop := forall (l:(list t)), (forall (e:t),
  (mem e l) -> (mem1 e s)) -> (((cardinal s) <  (length l))%Z -> exists e:t,
  exists l1:(list t), exists l2:(list t), exists l3:(list t),
  (l = (infix_plpl l1 (Cons e (infix_plpl l2 (Cons e l3)))))).

Parameter infix_eqeq1: t -> t -> Prop.

Axiom Induction : (forall (s:(set t)), (is_empty s) -> (pigeon_set s)) ->
  ((forall (s:(set t)), (pigeon_set s) -> forall (t1:t), (~ (mem1 t1 s)) ->
  (pigeon_set (add t1 s))) -> forall (s:(set t)), (pigeon_set s)).

Axiom listMem : forall (e:t) (l:(list t)), (mem e l) -> exists l1:(list t),
  exists l2:(list t), (l = (infix_plpl l1 (Cons e l2))).

(* Why3 goal *)
Theorem corner : forall (s:(set t)) (l:(list t)),
  ((length l) = (cardinal s)) -> ((forall (e:t), (mem e l) -> (mem1 e s)) ->
  ((exists e:t, (exists l1:(list t), (exists l2:(list t), (exists l3:(list
  t), (l = (infix_plpl l1 (Cons e (infix_plpl l2 (Cons e l3))))))))) \/
  forall (e:t), (mem1 e s) -> (mem e l))).

Require Why3.
Ltac ae := why3 "alt-ergo".
Ltac cvc := why3 "cvc3-2.4".

intros s l.
revert s.
induction l.
intros H1 H2.
right.
ae.

intro s.

Require Import Classical.
destruct (classic (mem a l)).
intros H1 H2.
left.
exists a.
exists Nil.
assert (exists l2 : list t,
  exists l3 : list t,
    l = infix_plpl l2 (Cons a l3)).
ae.

destruct H0 as (l2 & l3 & H0).
exists l2.
exists l3.
ae.

generalize (IHl (remove a s)).
clear IHl.
intros IHl H1 H2.
destruct IHl.
ae.
ae.

left.
destruct H0 as (e & l1 & l2 & l3 & H0).
exists e.
exists (Cons a l1).
exists l2.
exists l3.
ae.

assert (mem1 a s).
ae.
right.
clear H1.
ae.

Qed.


