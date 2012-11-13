(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require Import ZOdiv.
Require BuiltIn.
Require int.Int.
Require int.Abs.
Require int.EuclideanDivision.
Require int.ComputerDivision.
Require number.Parity.
Require number.Divisibility.
Require number.Prime.

(* Why3 assumption *)
Definition unit  := unit.

(* Why3 assumption *)
Definition lt_nat(x:Z) (y:Z): Prop := (0%Z <= y)%Z /\ (x < y)%Z.

(* Why3 assumption *)
Inductive lex : (Z* Z)%type -> (Z* Z)%type -> Prop :=
  | Lex_1 : forall (x1:Z) (x2:Z) (y1:Z) (y2:Z), (lt_nat x1 x2) -> (lex (x1,
      y1) (x2, y2))
  | Lex_2 : forall (x:Z) (y1:Z) (y2:Z), (lt_nat y1 y2) -> (lex (x, y1) (x,
      y2)).

(* Why3 assumption *)
Inductive ref (a:Type) {a_WT:WhyType a} :=
  | mk_ref : a -> ref a.
Axiom ref_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (ref a).
Existing Instance ref_WhyType.
Implicit Arguments mk_ref [[a] [a_WT]].

(* Why3 assumption *)
Definition contents {a:Type} {a_WT:WhyType a}(v:(ref a)): a :=
  match v with
  | (mk_ref x) => x
  end.

Axiom map : forall (a:Type) {a_WT:WhyType a} (b:Type) {b_WT:WhyType b}, Type.
Parameter map_WhyType : forall (a:Type) {a_WT:WhyType a}
  (b:Type) {b_WT:WhyType b}, WhyType (map a b).
Existing Instance map_WhyType.

Parameter get: forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  (map a b) -> a -> b.

Parameter set: forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  (map a b) -> a -> b -> (map a b).

Axiom Select_eq : forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  forall (m:(map a b)), forall (a1:a) (a2:a), forall (b1:b), (a1 = a2) ->
  ((get (set m a1 b1) a2) = b1).

Axiom Select_neq : forall {a:Type} {a_WT:WhyType a}
  {b:Type} {b_WT:WhyType b}, forall (m:(map a b)), forall (a1:a) (a2:a),
  forall (b1:b), (~ (a1 = a2)) -> ((get (set m a1 b1) a2) = (get m a2)).

Parameter const: forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  b -> (map a b).

Axiom Const : forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  forall (b1:b) (a1:a), ((get (const b1:(map a b)) a1) = b1).

(* Why3 assumption *)
Inductive array (a:Type) {a_WT:WhyType a} :=
  | mk_array : Z -> (map Z a) -> array a.
Axiom array_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (array a).
Existing Instance array_WhyType.
Implicit Arguments mk_array [[a] [a_WT]].

(* Why3 assumption *)
Definition elts {a:Type} {a_WT:WhyType a}(v:(array a)): (map Z a) :=
  match v with
  | (mk_array x x1) => x1
  end.

(* Why3 assumption *)
Definition length {a:Type} {a_WT:WhyType a}(v:(array a)): Z :=
  match v with
  | (mk_array x x1) => x
  end.

(* Why3 assumption *)
Definition get1 {a:Type} {a_WT:WhyType a}(a1:(array a)) (i:Z): a :=
  (get (elts a1) i).

(* Why3 assumption *)
Definition set1 {a:Type} {a_WT:WhyType a}(a1:(array a)) (i:Z) (v:a): (array
  a) := (mk_array (length a1) (set (elts a1) i v)).

(* Why3 assumption *)
Definition make {a:Type} {a_WT:WhyType a}(n:Z) (v:a): (array a) :=
  (mk_array n (const v:(map Z a))).

(* Why3 assumption *)
Definition no_prime_in(l:Z) (u:Z): Prop := forall (x:Z), ((l < x)%Z /\
  (x < u)%Z) -> ~ (number.Prime.prime x).

(* Why3 assumption *)
Definition first_primes(p:(array Z)) (u:Z): Prop := ((get1 p 0%Z) = 2%Z) /\
  ((forall (i:Z) (j:Z), (((0%Z <= i)%Z /\ (i < j)%Z) /\ (j < u)%Z) ->
  ((get1 p i) < (get1 p j))%Z) /\ ((forall (i:Z), ((0%Z <= i)%Z /\
  (i < u)%Z) -> (number.Prime.prime (get1 p i))) /\ forall (i:Z),
  ((0%Z <= i)%Z /\ (i < (u - 1%Z)%Z)%Z) -> (no_prime_in (get1 p i) (get1 p
  (i + 1%Z)%Z)))).

Axiom exists_prime : forall (p:(array Z)) (u:Z), (1%Z <= u)%Z ->
  ((first_primes p u) -> forall (d:Z), ((2%Z <= d)%Z /\ (d <= (get1 p
  (u - 1%Z)%Z))%Z) -> ((number.Prime.prime d) -> exists i:Z, ((0%Z <= i)%Z /\
  (i < u)%Z) /\ (d = (get1 p i)))).

Axiom Bertrand_postulate : forall (p:Z), (number.Prime.prime p) ->
  ~ (no_prime_in p (2%Z * p)%Z).

(* Why3 goal *)
Theorem WP_parameter_prime_numbers : forall (m:Z), (2%Z <= m)%Z ->
  ((0%Z <= m)%Z -> (((0%Z <= 0%Z)%Z /\ (0%Z < m)%Z) -> forall (p:(map Z Z)),
  (p = (set (const 0%Z:(map Z Z)) 0%Z 2%Z)) -> (((0%Z <= 1%Z)%Z /\
  (1%Z < m)%Z) -> forall (p1:(map Z Z)), (p1 = (set p 1%Z 3%Z)) ->
  ((2%Z <= (m - 1%Z)%Z)%Z -> forall (n:Z) (p2:(map Z Z)), forall (j:Z),
  ((2%Z <= j)%Z /\ (j <= (m - 1%Z)%Z)%Z) -> (((((first_primes (mk_array m p2)
  j) /\ (((get p2 (j - 1%Z)%Z) < n)%Z /\ (n < (2%Z * (get p2
  (j - 1%Z)%Z))%Z)%Z)) /\ (number.Parity.odd n)) /\ (no_prime_in (get p2
  (j - 1%Z)%Z) n)) -> forall (k:Z), forall (n1:Z) (p3:(map Z Z)),
  (((((((1%Z <= k)%Z /\ (k < j)%Z) /\ (first_primes (mk_array m p3) j)) /\
  (((get p3 (j - 1%Z)%Z) < n1)%Z /\ (n1 < (2%Z * (get p3
  (j - 1%Z)%Z))%Z)%Z)) /\ (number.Parity.odd n1)) /\ (no_prime_in (get p3
  (j - 1%Z)%Z) n1)) /\ forall (i:Z), ((0%Z <= i)%Z /\ (i < k)%Z) ->
  ~ (number.Divisibility.divides (get p3 i) n1)) -> (((0%Z <= k)%Z /\
  (k < m)%Z) -> (((ZOmod n1 (get p3 k)) = 0%Z) ->
  ~ (number.Prime.prime n1)))))))).
Proof.
intuition.
intuition.
red in H18. destruct H18.
red in H25; decompose  [and] H25; clear H25.
apply H19 with (get p3 k).
assert (2 < get p3 k)%Z.
rewrite <- H28.
apply H30; omega.
split. omega.
assert (case: (k<j-1 \/ k=j-1)%Z) by omega. destruct case.
apply Zlt_trans with (get p3 (j-1))%Z; try omega.
apply H30; omega.
subst k; auto.
apply Divisibility.mod_divides_computer; auto.
assert (2 < get p3 k)%Z.
rewrite <- H28.
apply H30; omega.
omega.
Qed.


