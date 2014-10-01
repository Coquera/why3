(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require map.Map.
Require int.Int.
Require bool.Bool.

Axiom map : forall (a:Type) (b:Type), Type.
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
  forall (b1:b) (a1:a), ((get (const b1: (map a b)) a1) = b1).

(* Why3 assumption *)
Inductive id :=
  | Id : Z -> id.
Axiom id_WhyType : WhyType id.
Existing Instance id_WhyType.

(* Why3 assumption *)
Definition state := (map id Z).

(* Why3 assumption *)
Inductive aexpr :=
  | Anum : Z -> aexpr
  | Avar : id -> aexpr
  | Aadd : aexpr -> aexpr -> aexpr
  | Asub : aexpr -> aexpr -> aexpr
  | Amul : aexpr -> aexpr -> aexpr.
Axiom aexpr_WhyType : WhyType aexpr.
Existing Instance aexpr_WhyType.

(* Why3 assumption *)
Inductive bexpr :=
  | Btrue : bexpr
  | Bfalse : bexpr
  | Band : bexpr -> bexpr -> bexpr
  | Bnot : bexpr -> bexpr
  | Beq : aexpr -> aexpr -> bexpr
  | Ble : aexpr -> aexpr -> bexpr.
Axiom bexpr_WhyType : WhyType bexpr.
Existing Instance bexpr_WhyType.

(* Why3 assumption *)
Inductive com :=
  | Cskip : com
  | Cassign : id -> aexpr -> com
  | Cseq : com -> com -> com
  | Cif : bexpr -> com -> com -> com
  | Cwhile : bexpr -> com -> com.
Axiom com_WhyType : WhyType com.
Existing Instance com_WhyType.

(* Why3 assumption *)
Fixpoint aeval (st:(map id Z)) (e:aexpr) {struct e}: Z :=
  match e with
  | (Anum n) => n
  | (Avar x) => (get st x)
  | (Aadd e1 e2) => ((aeval st e1) + (aeval st e2))%Z
  | (Asub e1 e2) => ((aeval st e1) - (aeval st e2))%Z
  | (Amul e1 e2) => ((aeval st e1) * (aeval st e2))%Z
  end.

Parameter beval: (map id Z) -> bexpr -> bool.

Axiom beval_def : forall (st:(map id Z)) (b:bexpr),
  match b with
  | Btrue => ((beval st b) = true)
  | Bfalse => ((beval st b) = false)
  | (Bnot b') => ((beval st b) = (Init.Datatypes.negb (beval st b')))
  | (Band b1 b2) => ((beval st b) = (Init.Datatypes.andb (beval st
      b1) (beval st b2)))
  | (Beq a1 a2) => (((aeval st a1) = (aeval st a2)) -> ((beval st
      b) = true)) /\ ((~ ((aeval st a1) = (aeval st a2))) -> ((beval st
      b) = false))
  | (Ble a1 a2) => (((aeval st a1) <= (aeval st a2))%Z -> ((beval st
      b) = true)) /\ ((~ ((aeval st a1) <= (aeval st a2))%Z) -> ((beval st
      b) = false))
  end.

Axiom inversion_beval_t : forall (a1:aexpr) (a2:aexpr) (m:(map id Z)),
  ((beval m (Beq a1 a2)) = true) -> ((aeval m a1) = (aeval m a2)).

Axiom inversion_beval_f : forall (a1:aexpr) (a2:aexpr) (m:(map id Z)),
  ((beval m (Beq a1 a2)) = false) -> ~ ((aeval m a1) = (aeval m a2)).

(* Why3 assumption *)
Inductive ceval: (map id Z) -> com -> (map id Z) -> Prop :=
  | E_Skip : forall (m:(map id Z)), (ceval m Cskip m)
  | E_Ass : forall (m:(map id Z)) (a:aexpr) (n:Z) (x:id), ((aeval m
      a) = n) -> (ceval m (Cassign x a) (set m x n))
  | E_Seq : forall (cmd1:com) (cmd2:com) (m0:(map id Z)) (m1:(map id Z))
      (m2:(map id Z)), (ceval m0 cmd1 m1) -> ((ceval m1 cmd2 m2) -> (ceval m0
      (Cseq cmd1 cmd2) m2))
  | E_IfTrue : forall (m0:(map id Z)) (m1:(map id Z)) (cond:bexpr) (cmd1:com)
      (cmd2:com), ((beval m0 cond) = true) -> ((ceval m0 cmd1 m1) -> (ceval
      m0 (Cif cond cmd1 cmd2) m1))
  | E_IfFalse : forall (m0:(map id Z)) (m1:(map id Z)) (cond:bexpr)
      (cmd1:com) (cmd2:com), ((beval m0 cond) = false) -> ((ceval m0 cmd2
      m1) -> (ceval m0 (Cif cond cmd1 cmd2) m1))
  | E_WhileEnd : forall (cond:bexpr) (m:(map id Z)) (body:com), ((beval m
      cond) = false) -> (ceval m (Cwhile cond body) m)
  | E_WhileLoop : forall (mi:(map id Z)) (mj:(map id Z)) (mf:(map id Z))
      (cond:bexpr) (body:com), ((beval mi cond) = true) -> ((ceval mi body
      mj) -> ((ceval mj (Cwhile cond body) mf) -> (ceval mi (Cwhile cond
      body) mf))).

Require Import Why3.
Ltac cvc := why3 "CVC4,1.4,".

(* Why3 goal *)
Theorem ceval_deterministic : forall (c:com) (mi:(map id Z)) (mf1:(map id Z))
  (mf2:(map id Z)), (ceval mi c mf1) -> ((ceval mi c mf2) -> (mf1 = mf2)).
intros c mi mf1 mf2 h1 h2.
generalize dependent mf2.
induction h1;intros mf2 h2; inversion h2; cvc.
Qed.
