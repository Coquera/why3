(********************************************************************)
(*                                                                  *)
(*  The Why3 Verification Platform   /   The Why3 Development Team  *)
(*  Copyright 2010-2017   --   INRIA - CNRS - Paris-Sud University  *)
(*                                                                  *)
(*  This software is distributed under the terms of the GNU Lesser  *)
(*  General Public License version 2.1, with the special exception  *)
(*  on linking described in file LICENSE.                           *)
(*                                                                  *)
(********************************************************************)

%{
%}

%start <Smt2_model_defs.correspondance_table> output
%token <string> SPACE
%token <string> ATOM
%token MODEL
%token STORE
%token CONST
%token AS
%token DEFINE_FUN
%token DECLARE_FUN
%token DECLARE_SORT
%token DECLARE_DATATYPES
%token FORALL
%token UNDERSCORE
%token AS_ARRAY
%token EQUAL
%token ITE
%token LAMBDA
%token ARRAY_LAMBDA
%token TRUE FALSE
%token LET
%token <string> COMMENT
%token <string> BITVECTOR_VALUE
%token BITVECTOR_TYPE
%token <string> INT_STR
%token <string> MINUS_INT_STR
%token <string * string> DEC_STR
%token <string * string> MINUS_DEC_STR
%token LPAREN RPAREN
%token <string * int> MK_REP
%token <string * int> MK_SPLIT_FIELD
%token <string * int> MK_T
%token <string * int> MK_SPLIT_DISCRS
%token EOF
%%


output:
| EOF { Stdlib.Mstr.empty }
| LPAREN ps MODEL ps list_decls RPAREN { $5 }

list_decls:
| LPAREN decl RPAREN ps { Smt2_model_defs.add_element $2 Stdlib.Mstr.empty false}
| LPAREN decl RPAREN ps list_decls { Smt2_model_defs.add_element $2 $5 false }
| COMMENT ps list_decls  { $3 } (* Lines beginning with ';' are ignored *)

(* Examples:
"(define-fun to_rep ((_ufmt_1 enum_t)) Int 0)"
"(declare-sort enum_t 0)"
"(declare-datatypes () ((tuple0 (Tuple0))
))"
*)
decl:
| DEFINE_FUN SPACE tname ps LPAREN ps args_lists RPAREN
    ps ireturn_type SPACE smt_term
    { let t = Smt2_model_defs.make_local $7 $12 in
        Some ($3, (Smt2_model_defs.Function ($7, t))) }
| DECLARE_SORT SPACE isort_def { None }
| DECLARE_DATATYPES SPACE idata_def ps { None }
| DECLARE_FUN SPACE tname ps LPAREN ps args_lists RPAREN
    ps ireturn_type { None } (* z3 declare function *)
| FORALL SPACE LPAREN ps args_lists RPAREN ps smt_term { None } (* z3 cardinality *)

(* Names. For atoms that are used to recognize different types of values,
   we return the string the lexer detected (as expected). These names
   are not used. *)
tname:
| name { $1 }
| MK_REP { fst $1 }
| MK_SPLIT_FIELD { fst $1 }
| MK_T { fst $1 }
| MK_SPLIT_DISCRS { fst $1 }


smt_term:
| name      { Smt2_model_defs.Variable $1  }
| integer   { Smt2_model_defs.Integer $1   }
| decimal   { Smt2_model_defs.Decimal $1   }
| array     { Smt2_model_defs.Array $1     }
| bitvector { Smt2_model_defs.Bitvector $1 }
| boolean   { Smt2_model_defs.Boolean $1   }
(* ite (= ?a ?b) ?c ?d *)
| LPAREN ITE ps pair_equal ps smt_term ps smt_term RPAREN
    {  match $4 with
    | None -> Smt2_model_defs.Other ""
    | Some (t1, t2) -> Smt2_model_defs.Ite (t1, t2, $6, $8) }
(* No parsable value are applications. *)
| application { Smt2_model_defs.Other "" }
(* This is SPARK-specific stuff. It is used to parse records, discriminants
   and stuff generated by SPARK with specific "keywords" :
   mk___rep(num), mk___split_field(num) etc *)
| LPAREN MK_REP SPACE list_smt_term RPAREN
    { Smt2_model_defs.build_record_discr (List.rev $4) }
(* Specifically for mk___t, we are only interested in the first value *)
| LPAREN MK_T SPACE list_smt_term RPAREN { List.hd (List.rev $4) }
| LPAREN MK_SPLIT_FIELD SPACE list_smt_term RPAREN
    { Smt2_model_defs.Record (snd $2, List.rev $4) }
| LPAREN MK_SPLIT_DISCRS SPACE list_smt_term RPAREN
    { Smt2_model_defs.Discr (snd $2, List.rev $4) }
(* Particular case for functions that are defined as an equality:
   define-fun f ((a int) (b int)) (= a b) *)
| LPAREN EQUAL ps list_smt_term RPAREN { Smt2_model_defs.Other "" }
| LPAREN LET ps LPAREN list_let RPAREN SPACE smt_term RPAREN
    { Smt2_model_defs.substitute $5 $8 }
(* z3 specific constructor *)
| LPAREN UNDERSCORE ps AS_ARRAY ps tname RPAREN
    { Smt2_model_defs.To_array (Smt2_model_defs.Variable $6) }


(* value of let are not used *)
list_let:
| { [] }
| LPAREN tname SPACE smt_term RPAREN ps list_let { ($2, $4) :: $7 }
(* TODO not efficient *)

(* Condition of an if-then-else. We are only interested in equality case *)
pair_equal:
| LPAREN EQUAL ps smt_term ps smt_term RPAREN { Some ($4, $6) }
| application { None }
| name { None }

list_smt_term:
| smt_term { [$1] }
| list_smt_term SPACE smt_term { $3 :: $1}

application:
| LPAREN ps name SPACE list_smt_term RPAREN { $3 }

array:
| LPAREN ps
    LPAREN AS SPACE CONST ps ireturn_type
    RPAREN ps smt_term
  RPAREN{ Smt2_model_defs.Const $11 }
| LPAREN ps
    STORE ps array SPACE smt_term SPACE smt_term ps
  RPAREN { Smt2_model_defs.Store ($5, $7, $9) }
(* When array is of type int -> bool, Cvc4 returns something that looks like:
   (ARRAY_LAMBDA (LAMBDA ((BOUND_VARIABLE_1162 Int)) false)) *)
| LPAREN
    ARRAY_LAMBDA ps
    LPAREN LAMBDA ps LPAREN args_lists RPAREN ps smt_term
  RPAREN ps RPAREN
    { Smt2_model_defs.Const $11 }

(* Possible space *)
ps:
| { }
| SPACE { }

args_lists:
| { [] }
| LPAREN args RPAREN ps args_lists { $2 :: $5 }
(* TODO This is inefficient and should be done in a left recursive way *)

args:
| name SPACE ireturn_type { $1 }

name:
| ATOM { $1 }
(* Should not happen in relevant part of the model (ad hoc) *)
| BITVECTOR_TYPE { "" }

integer:
| INT_STR { $1 }
| LPAREN ps MINUS_INT_STR ps RPAREN
    { $3 }

decimal:
| DEC_STR { $1 }
| LPAREN ps MINUS_DEC_STR ps RPAREN
    { $3 }

(* Example:
   (_ bv2048 16) *)
bitvector:
| BITVECTOR_VALUE
    { $1 }

boolean:
| TRUE  { true  }
| FALSE { false }

(* BEGIN IGNORED TYPES *)
(* Types are badly parsed (for future use) but never saved *)
ireturn_type:
| tname {}
| LPAREN idata_type RPAREN {}

isort_def:
| tname SPACE integer { }

idata_def:
| LPAREN ps RPAREN ps LPAREN ps LPAREN idata_type RPAREN ps RPAREN { }
| LPAREN ps RPAREN ps LPAREN ps LPAREN RPAREN ps RPAREN { }

ilist_app:
| tname { }
| tname SPACE ilist_app { }
| LPAREN idata_type RPAREN { }
| LPAREN idata_type RPAREN SPACE ilist_app { }

idata_type:
| tname { }
| tname SPACE ilist_app { }
(* END IGNORED TYPES *)
