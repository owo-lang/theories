(*!
 * @begin[doc]
 * @module[Mfir_tr_atom]
 *
 * The @tt[Mfir_tr_atom] module defines the typing rules for atoms.
 * @end[doc]
 *
 * ------------------------------------------------------------------------
 *
 * @begin[license]
 * This file is part of MetaPRL, a modular, higher order
 * logical framework that provides a logical programming
 * environment for OCaml and other languages.  Additional
 * information about the system is available at
 * http://www.metaprl.org/
 *
 * Copyright (C) 2002 Brian Emre Aydemir, Caltech
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
 * @email{emre@cs.caltech.edu}
 * @end[license]
 *)

(*!
 * @begin[doc]
 * @parents
 * @end[doc]
 *)

extends Base_theory
extends Mfir_basic
extends Mfir_ty
extends Mfir_exp
extends Mfir_sequent
extends Mfir_tr_base
extends Mfir_tr_types

(*!
 * @docoff
 *)

open Tactic_type
open Tactic_type.Tacticals
open Base_auto_tactic
open Base_dtactic
open Mfir_auto

(**************************************************************************
 * Rules.
 **************************************************************************)

(*!
 * @begin[doc]
 * @rules
 * @modsubsection{Normal atoms}
 *
 * The atom $<< atomInt{'i} >>$ has type $<< tyInt >>$ if $<< 'i >>$ is in the
 * set of 31-bit, signed integers.
 * @end[doc]
 *)

prim ty_atomInt {| intro [] |} 'H :
   sequent [mfir] { 'H >- type_eq{ tyInt; large_type } } -->
   sequent [mfir] { 'H >- member{ 'i; intset_max } } -->
   sequent [mfir] { 'H >- has_type["atom"]{ atomInt{'i}; tyInt } }
   = it

(*!
 * @begin[doc]
 *
 * An enumeration atom $<< atomEnum[i:n]{'n} >>$ has type $<< tyEnum[i:n] >>$
 * if $ 0 <<le>> n < i $, and if $<< tyEnum[i:n] >>$ is a well-formed type.
 * @end[doc]
 *)

prim ty_atomEnum {| intro [] |} 'H :
   sequent [mfir] { 'H >- type_eq{ tyEnum[i:n]; large_type } } -->
   sequent [mfir] { 'H >- "and"{int_le{0; 'n}; int_lt{'n; number[i:n]}} } -->
   sequent [mfir] { 'H >- has_type["atom"]{atomEnum[i:n]{'n}; tyEnum[i:n]} }
   = it

(*!
 * @begin[doc]
 *
 * The atom $<< atomRawInt[p:n, sign:s]{'i} >>$ has type
 * $<< tyRawInt[p:n, sign:s] >>$, if $i$ is in the appropriate set of
 * integers, and if $<< tyRawInt[p:n, sign:s] >>$ is a well-formed type.
 * @end[doc]
 *)

prim ty_atomRawInt 'H :
   sequent [mfir] { 'H >- type_eq{ tyRawInt[p:n, sign:s]; large_type } } -->
   sequent [mfir] { 'H >- member{ 'i; rawintset_max[p:n, sign:s] } } -->
   sequent [mfir] { 'H >-
      has_type["atom"]{ atomRawInt[p:n, sign:s]{'i}; tyRawInt[p:n, sign:s] } }
   = it

(*!
 * @begin[doc]
 *
 * A variable $<< atomVar{'v} >>$ has type $<< 'ty >>$ if it is declared in
 * the context to have type $<< 'ty >>$.
 * @end[doc]
 *)

prim ty_atomVar 'H 'J :
   sequent [mfir] { 'H; v: var_def{ 'ty; no_def }; 'J['v] >-
      has_type["atom"]{ atomVar{'v}; 'ty } }
   = it

(*!
 * @docoff
 *)

let d_ty_atomVar i p =
   let j, k = Sequent.hyp_indices p i in
      ty_atomVar j k p

let resource auto += {
   auto_name = "d_ty_atomVar";
   auto_prec = fir_auto_prec;
   auto_tac = onSomeHypT d_ty_atomVar;
   auto_type = AutoNormal
}

(*!
 * @begin[doc]
 * @modsubsection{Polymorphism}
 *
 * ...
 * @end[doc]
 *)

(* XXX enter in the poly atom type rules. *)

(*!
 * @begin[doc]
 * @modsubsection{Unary and binary operators}
 *
 * For the atoms $<< atomUnop{ 'unop; 'a } >>$ and
 * $<< atomBinop{ 'binop; 'a1; 'a2 } >>$, there is a typing rule for each
 * possible operator.  The rules are straightforward, and we will illustrate
 * their basic form with two examples.
 * @end[doc]
 *)

prim ty_uminusIntOp {| intro [] |} 'H :
   sequent [mfir] { 'H >- has_type["atom"]{ 'a ; tyInt } } -->
   sequent [mfir] { 'H >- has_type["atom"]{atomUnop{uminusIntOp; 'a}; tyInt} }
   = it

prim ty_plusIntOp {| intro [] |} 'H :
   sequent [mfir] { 'H >- has_type["atom"]{ 'a1; tyInt } } -->
   sequent [mfir] { 'H >- has_type["atom"]{ 'a2; tyInt } } -->
   sequent [mfir] { 'H >-
      has_type["atom"]{ atomBinop{plusIntOp; 'a1; 'a2}; tyInt } }
   = it

(*!
 * @docoff
 *)

(* TODO: write up the remaining unop/binop rules. *)
