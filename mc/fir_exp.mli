(*
 * Functional Intermediate Representation formalized in MetaPRL.
 * Brian Emre Aydemir, emre@its.caltech.edu
 *
 * Define and implement the basic expression forms in the FIR.
 *)

include Base_theory
include Itt_theory
include Fir_state
include Fir_int_set
include Fir_ty

(*************************************************************************
 * Declarations.
 *************************************************************************)

(*
 * Program.
 * Encapsulates an expression and the state in which the expression
 *    should be evaluated.
 *)
declare prog{ 'state; 'exp }

(*
 * Program value.
 * Declares that 'v is a value and that when the program evaluates,
 *    we can now drop the state from future consideration.
 *)
declare value{ 'v }

(* Identity (polymorphic). *)
declare idOp

(* Subscripts. *)
declare plusSubIntOp
declare minusSubIntOp
declare minusSubSubOp
declare composeSubOp

(* Pointer equality. *)
declare eqEqOp

(*
 * Allocation operators.
 * copy makes a list with 'len copies of 'init.
 * 'len should be a positive number.
 *)
declare allocTuple{ 'ty; 'atom_list }
declare allocArray{ 'ty; 'atom_list }
declare allocUnion{ 'ty; 'ty_var; 'num; 'atom_list }
define unfold_copy : copy{ 'len; 'init } <-->
   ind{'len; i, j. nil; nil; i, j. cons{'init; 'j}}

(*
 * Normal values.
 *)

(* Subscript atoms. *)
declare atomSubType{ 'ty }
declare atomSubIndex{ 'sub; 'int }
declare atomSubOffset{ 'sub; 'int }
declare atomSubscript{ 'sub }

(* Subscript ops. *)
declare aggrSubscript
declare intSubscript

(*
 * Normal atoms.
 * 'int in atomInt is the integer itself (a number).
 * 'bound and 'num in atomEnum are numbers satisfying 0 <= 'num < 'bound.
 * 'var in atomVar is the variable itself.
 *)
declare atomInt{ 'int }
declare atomEnum{ 'bound; 'num }
declare atomConst{ 'ty; 'ty_var; 'num }
declare atomVar{ 'var }

(*
 * Expressions.
 *)

(* Function application. *)
declare unOp{ 'op; 'a1; v. 'exp['v] }
declare binOp{ 'op; 'a1; 'a2; v. 'exp['v] }
declare tailCall{ 'var; 'atom_list }

(* Control. *)
declare matchCase{ 'set; 'exp }
declare "match"{ 'key; 'cases }

(* Allocation. *)
declare letAlloc{ 'alloc_op; v. 'exp['v] }

(* Subscripting. *)
declare letSubscript{ 'ref; 'index; v. 'exp['v] }
declare setSubscript{ 'ref; 'index; 'new_val; 'exp }
