(*
 * Functional Intermediate Representation formalized in MetaPRL.
 *
 * Operations for converting between MC Fir expressions and MetaPRL terms.
 *
 * ----------------------------------------------------------------
 *
 * Copyright (C) 2002 Brian Emre Aydemir, Caltech
 *
 * This file is part of MetaPRL, a modular, higher order
 * logical framework that provides a logical programming
 * environment for OCaml and other languages.
 *
 * See the file doc/index.html for information on Nuprl,
 * OCaml, and more information about this system.
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
 * Author: Brian Emre Aydemir
 * Email:  emre@its.caltech.edu
 *)

(* Open MC ML namespaces. *)

open Fir

(* Open MetaPRL ML namespaces. *)

open Refiner.Refiner.Term

(*
 * Convert to and from unop.
 *)

val term_of_unop : unop -> term
val unop_of_term : term -> unop

(*
 * Convert to and from binop.
 *)

val term_of_binop : binop -> term
val binop_of_term : term -> binop

(*
 * Convert to and from subscripting terms.
 *)

val term_of_sub_block : sub_block -> term
val sub_block_of_term : term -> sub_block

val term_of_sub_value : sub_value -> term
val sub_value_of_term : term -> sub_value

val term_of_sub_index : sub_index -> term
val sub_index_of_term : term -> sub_index

val term_of_sub_script : sub_script -> term
val sub_script_of_term : term -> sub_script

val term_of_subop : subop -> term
val subop_of_term : term -> subop

(*
 * Convert to and from atom.
 *)

val term_of_atom : atom -> term
val atom_of_term : term -> atom

(*
 * Convert to and from alloc_op.
 *)

val term_of_alloc_op : alloc_op -> term
val alloc_op_of_term : term -> alloc_op

(*
 * Convert to and from tailop.
 *)

val term_of_tailop : tailop -> term
val tailop_of_term : term -> tailop

(*
 * Convert to and from predicate / assertion terms.
 *)

val term_of_pred_nop : pred_nop -> term
val pred_nop_of_term : term -> pred_nop

val term_of_pred_unop : pred_unop -> term
val pred_unop_of_term : term -> pred_unop

val term_of_pred_binop : pred_binop -> term
val pred_binop_of_term : term -> pred_binop

val term_of_pred : pred -> term
val pred_of_term : term -> pred

(*
 * Convert debugging info to and from terms.
 *)

val term_of_debug_line : debug_line -> term
val debug_line_of_term : term -> debug_line

val term_of_debug_vars : debug_vars -> term
val debug_vars_of_term : term -> debug_vars

val term_of_debug_info : debug_info -> term
val debug_info_of_term : term -> debug_info

(*
 * Convert to and from exp.
 *)

val term_of_exp : exp -> term
val exp_of_term : term -> exp
