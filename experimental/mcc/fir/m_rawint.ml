(*
 * Raw integers.
 *
 * ----------------------------------------------------------------
 *
 * @begin[license]
 * Copyright (C) 2003 Jason Hickey, Caltech
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 * Author: Jason Hickey
 * @email{jyh@cs.caltech.edu}
 * @end[license]
 *)
extends Base_theory

open Refiner.Refiner.TermType
open Refiner.Refiner.Term
open Refiner.Refiner.TermOp
open Refiner.Refiner.RefineError

(*
 * For now, use the string representation.
 *)
declare rawint[precision:n, signed:t, value:s]

(*
 * Arithmetic.
 *)
declare rawint_uminus{'i}
declare rawint_lnot{'i}
declare rawint_bitfield[off:n, len:n]{'i}

declare rawint_of_rawint[p:n, s:t]{'i}
declare rawint_of_int[p:n, s:t]{'i}

declare rawint_plus{'i1; 'i2}
declare rawint_minus{'i1; 'i2}
declare rawint_mul{'i1; 'i2}
declare rawint_div{'i1; 'i2}
declare rawint_rem{'i1; 'i2}
declare rawint_max{'i1; 'i2}
declare rawint_min{'i1; 'i2}

declare rawint_sl{'i1; 'i2}
declare rawint_sr{'i1; 'i2}
declare rawint_and{'i1; 'i2}
declare rawint_or{'i1; 'i2}
declare rawint_xor{'i1; 'i2}

declare rawint_if_eq{'i1; 'i2; 'e1; 'e2}
declare rawint_if_lt{'i1; 'i2; 'e1; 'e2}

(*
 * Precedences.
 *)
prec prec_if
prec prec_shift
prec prec_and
prec prec_add
prec prec_mul
prec prec_uminus
prec prec_coerce
prec prec_apply

prec prec_shift > prec_if
prec prec_and > prec_shift
prec prec_add > prec_and
prec prec_mul > prec_add
prec prec_uminus > prec_mul
prec prec_coerce > prec_uminus
prec prec_apply > prec_coerce

(*
 * Display.
 *)
declare precision[p:n, s:t]

dform precision_true_df : precision[p:n, "true":t] =
   slot[p:n] `"S"

dform precision_false_df : precision[p:n, "false":t] =
   slot[p:n] `"U"

dform rawint_df : rawint[p:n, s:t, v:s] =
   slot[v:s] `":" precision[p:n, s:t]

dform rawint_uminus_df : parens :: "prec"[prec_uminus] :: rawint_uminus{'i} =
   `"-" slot{'i}

dform rawint_lnot_df : parens :: "prec"[prec_uminus] :: rawint_lnot{'i} =
   `"~" slot{'i}

dform rawint_bitfield_df : parens :: "prec"[prec_apply] :: rawint_bitfield[off:n, len:n]{'i} =
   bf["field"] `"(" slot{'i} `", " slot[off:n] `", " slot[len:n] `")"

dform rawint_of_rawint_df : parens :: "prec"[prec_coerce] :: rawint_of_rawint[p:n, s:t]{'i} =
   `"(rawint-of-rawint " precision[p:n, s:t] `") " slot{'i}

dform rawint_of_int_df : parens :: "prec"[prec_coerce] :: rawint_of_int[p:n, s:t]{'i} =
   `"(rawint-of-int " precision[p:n, s:t] `") " slot{'i}

dform rawint_plus_df : parens :: "prec"[prec_add] :: rawint_plus{'i1; 'i2} =
   slot{'i1} hspace `"+ " slot{'i2}

dform rawint_minus_df : parens :: "prec"[prec_add] :: rawint_minus{'i1; 'i2} =
   slot{'i1} hspace `"- " slot{'i2}

dform rawint_mul_df : parens :: "prec"[prec_mul] :: rawint_mul{'i1; 'i2} =
   slot{'i1} hspace `"* " slot{'i2}

dform rawint_div_df : parens :: "prec"[prec_mul] :: rawint_div{'i1; 'i2} =
   slot{'i1} hspace `"/ " slot{'i2}

dform rawint_rem_df : parens :: "prec"[prec_mul] :: rawint_rem{'i1; 'i2} =
   slot{'i1} hspace bf["rem "] slot{'i2}

dform rawint_max_df : parens :: "prec"[prec_apply] :: rawint_max{'i1; 'i2} =
   bf["max"] `"(" slot{'i1} `", " slot{'i2} `")"

dform rawint_min_df : parens :: "prec"[prec_apply] :: rawint_min{'i1; 'i2} =
   bf["min"] `"(" slot{'i1} `", " slot{'i2} `")"

dform rawint_sl_df : parens :: "prec"[prec_shift] :: rawint_sl{'i1; 'i2} =
   slot{'i1} hspace `"<< " slot{'i2}

dform rawint_sr_df : parens :: "prec"[prec_shift] :: rawint_sr{'i1; 'i2} =
   slot{'i1} hspace `">> " slot{'i2}

dform rawint_and_df : parens :: "prec"[prec_and] :: rawint_and{'i1; 'i2} =
   slot{'i1} hspace `"& " slot{'i2}

dform rawint_or_df : parens :: "prec"[prec_and] :: rawint_or{'i1; 'i2} =
   slot{'i1} hspace `"| " slot{'i2}

dform rawint_xor_df : parens :: "prec"[prec_and] :: rawint_xor{'i1; 'i2} =
   slot{'i1} hspace `"^ " slot{'i2}

dform rawint_if_eq_df : parens :: "prec"[prec_if] :: rawint_if_eq{'i1; 'i2; 'e1; 'e2} =
   szone pushm[0] pushm[3] bf["if "] slot{'i1} bf[" = "] slot{'i2} bf["then"]
   hspace slot{'e1}
   popm hspace pushm[3] bf["else"]
   hspace slot{'e2}
   popm popm ezone

dform rawint_if_lt_df : parens :: "prec"[prec_if] :: rawint_if_lt{'i1; 'i2; 'e1; 'e2} =
   szone pushm[0] pushm[3] bf["if "] slot{'i1} bf[" < "] slot{'i2} bf["then"]
   hspace slot{'e1}
   popm hspace pushm[3] bf["else"]
   hspace slot{'e2}
   popm popm ezone

(*
 * Conversion to terms.
 *)
let rawint_term = << rawint[32:n, "true":t, "0":s] >>
let rawint_opname = opname_of_term rawint_term

let mk_rawint_term i =
   let p =
      match Lm_rawint.precision i with
         Lm_rawint.Int8 -> 8
       | Lm_rawint.Int16 -> 16
       | Lm_rawint.Int32 -> 32
       | Lm_rawint.Int64 -> 64
   in
   let s = Lm_rawint.signed i in
   let v = Lm_rawint.to_string i in
   let params = [Number (Mp_num.num_of_int p); Token (if s then "true" else "false"); String v] in
   let params = List.map make_param params in
   let op = mk_op rawint_opname params in
      mk_term op []

let dest_rawint_term t =
   let { term_op = op;
         term_terms = terms
       } = dest_term t
   in
   let _ =
      if terms <> [] then
         raise (RefineError ("dest_rawint_term", StringTermError ("not a rawint", t)))
   in
   let { op_name = opname;
         op_params = params
       } = dest_op op
   in
   let _ =
      if not (Opname.eq opname rawint_opname) then
         raise (RefineError ("dest_rawint_term", StringTermError ("not a rawint", t)))
   in
      match List.map dest_param params with
         [Number p; Token s; String v] ->
            let p =
               match Mp_num.int_of_num p with
                  8  -> Lm_rawint.Int8
                | 16 -> Lm_rawint.Int16
                | 32 -> Lm_rawint.Int32
                | 64 -> Lm_rawint.Int64
                | _ ->
                     raise (RefineError ("dest_rawint_term", StringTermError ("not a rawint", t)))
            in
            let s =
               match s with
                  "true" -> true
                | "false" -> false
                | _ ->
                     raise (RefineError ("dest_rawint_term", StringTermError ("not a rawint", t)))
            in
               Lm_rawint.of_string p s v
       | _ ->
            raise (RefineError ("dest_rawint_term", StringTermError ("not a rawint", t)))

(*
 * Arithmetic operations.
 *)
let unary_arith op goal =
   let i = one_subterm goal in
      mk_rawint_term (op (dest_rawint_term i))

let binary_arith op goal =
   let i1, i2 = two_subterms goal in
      mk_rawint_term (op (dest_rawint_term i1) (dest_rawint_term i2))

let check_zero op a b =
   if Lm_rawint.is_zero b then
      raise (RefineError ("M_rawint.arith", StringError "division by zero"))
   else
      op a b

(*
 * Actual reductions.
 *)
ml_rw reduce_rawint_uminus : ('goal : rawint_uminus{'i}) =
   unary_arith Lm_rawint.uminus goal

ml_rw reduce_rawint_lnot : ('goal : rawint_lnot{'i}) =
   unary_arith Lm_rawint.lognot goal

ml_rw reduce_rawint_bitfield : ('goal : rawint_bitfield[off:n, len:n]{'i}) =
   let { term_op = op;
         term_terms = bterms
       } = dest_term goal
   in
   let { op_params = params } = dest_op op in
   let params = List.map dest_param params in
   let bterms = List.map dest_bterm bterms in
      match params, bterms with
         [Number off; Number len], [{ bvars = []; bterm = t }] ->
            let i = dest_rawint_term t in
            let off = Mp_num.int_of_num off in
            let len = Mp_num.int_of_num len in
               mk_rawint_term (Lm_rawint.field i off len)
       | _ ->
            raise (RefineError ("reduce_rawint_bitfield", StringTermError ("illegal operation", goal)))

ml_rw reduce_rawint_plus : ('goal : rawint_plus{'i1; 'i2}) =
   binary_arith Lm_rawint.add goal

ml_rw reduce_rawint_minus : ('goal : rawint_minus{'i1; 'i2}) =
   binary_arith Lm_rawint.sub goal

ml_rw reduce_rawint_mul : ('goal : rawint_mul{'i1; 'i2}) =
   binary_arith Lm_rawint.mul goal

ml_rw reduce_rawint_div : ('goal : rawint_div{'i1; 'i2}) =
   binary_arith (check_zero Lm_rawint.div) goal

ml_rw reduce_rawint_rem  : ('goal : rawint_rem{'i1; 'i2}) =
   binary_arith (check_zero Lm_rawint.rem) goal

ml_rw reduce_rawint_min  : ('goal : rawint_min{'i1; 'i2}) =
   binary_arith Lm_rawint.min goal

ml_rw reduce_rawint_max  : ('goal : rawint_max{'i1; 'i2}) =
   binary_arith Lm_rawint.max goal

ml_rw reduce_rawint_sl  : ('goal : rawint_sl{'i1; 'i2}) =
   binary_arith Lm_rawint.shift_left goal

ml_rw reduce_rawint_sr  : ('goal : rawint_sr{'i1; 'i2}) =
   binary_arith Lm_rawint.shift_right goal

ml_rw reduce_rawint_and  : ('goal : rawint_and{'i1; 'i2}) =
   binary_arith Lm_rawint.logand goal

ml_rw reduce_rawint_max  : ('goal : rawint_or{'i1; 'i2}) =
   binary_arith Lm_rawint.logor goal

ml_rw reduce_rawint_max  : ('goal : rawint_xor{'i1; 'i2}) =
   binary_arith Lm_rawint.logxor goal

(*!
 * @docoff
 *
 * -*-
 * Local Variables:
 * Caml-master: "compile"
 * End:
 * -*-
 *)
