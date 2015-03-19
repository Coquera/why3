(********************************************************************)
(*                                                                  *)
(*  The Why3 Verification Platform   /   The Why3 Development Team  *)
(*  Copyright 2010-2015   --   INRIA - CNRS - Paris-Sud University  *)
(*                                                                  *)
(*  This software is distributed under the terms of the GNU Lesser  *)
(*  General Public License version 2.1, with the special exception  *)
(*  on linking described in file LICENSE.                           *)
(********************************************************************)

(* This file is generated by Why3's Coq-realize driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.

Require Import int.EuclideanDivision.

(* Why3 goal *)
Lemma div2 : forall (x:Z), exists y:Z, (x = (2%Z * y)%Z) \/
  (x = ((2%Z * y)%Z + 1%Z)%Z).
Proof.
intros x.
exists (div x 2).
refine (_ (Mod_bound x 2 _) (Div_mod x 2 _)) ; try easy.
intros H1 H2.
simpl in H1.
omega.
Qed.

