(*
 * Int is the type of tokens (strings)
 *
 * ----------------------------------------------------------------
 *
 * This file is part of MetaPRL, a modular, higher order
 * logical framework that provides a logical programming
 * environment for OCaml and other languages.
 *
 * See the file doc/index.html for information on Nuprl,
 * OCaml, and more information about this system.
 *
 * Copyright (C) 1998 Jason Hickey, Cornell University
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
 * jyh@cs.cornell.edu
 *
 *)

include Tacticals

include Itt_equal
include Itt_rfun
include Itt_bool
include Itt_logic

open Printf
open Mp_debug
open Refiner.Refiner.Term
open Refiner.Refiner.TermOp
open Refiner.Refiner.RefineError
open Rformat
open Mp_resource

open Var
open Sequent
open Tacticals
open Conversionals
open Itt_equal

(*
 * Show that the file is loading.
 *)
let _ =
   if !debug_load then
      eprintf "Loading Itt_int%t" eflush

(* debug_string DebugLoad "Loading itt_int..." *)

(************************************************************************
 * TERMS                                                                *
 ************************************************************************)

declare int
declare natural_number[@n:n]
declare ind{'i; m, z. 'down; 'base; m, z. 'up}

declare "add"{'a; 'b}
declare "sub"{'a; 'b}
declare "mul"{'a; 'b}
declare "div"{'a; 'b}
declare "rem"{'a; 'b}
declare lt{'a; 'b}
declare le{'a; 'b}
declare ge{'a; 'b}
declare gt{'a; 'b}

(************************************************************************
 * DISPLAY FORMS                                                        *
 ************************************************************************)

prec prec_compare
prec prec_add
prec prec_mul

(*
prec prec_mul < prec_apply
prec prec_add < prec_mul
prec prec_compare < prec_add
*)

dform int_prl_df1 : mode[prl] :: int = mathbbZ

dform natural_number_df : natural_number[@n:n] =
   slot[@n:s]

dform add_df1 :  mode[prl] :: parens :: "prec"[prec_add] :: "add"{'a; 'b} =
   slot[le]{'a} `" + " slot[lt]{'b}
dform add_df2 : mode[src] :: parens :: "prec"[prec_add] :: "add"{'a; 'b} =
   slot[le]{'a} `" add " slot[lt]{'b}

dform sub_df1 : mode[prl] :: parens :: "prec"[prec_add] :: "sub"{'a; 'b} =
   slot[lt]{'a} `" - " slot[le]{'b}
dform sub_df2 : mode[src] :: parens :: "prec"[prec_add] :: "sub"{'a; 'b} =
   slot[lt]{'a} `" sub " slot[le]{'b}

dform mul_df1 : mode[prl] :: parens :: "prec"[prec_mul] :: "mul"{'a; 'b} =
   slot[lt]{'a} `" * " slot[le]{'b}
dform mul_df2 : mode[src] :: parens :: "prec"[prec_mul] :: "mul"{'a; 'b} =
   slot[lt]{'a} `" mul " slot[le]{'b}

dform div_df1 : mode[prl] :: parens :: "prec"[prec_mul] :: "div"{'a; 'b} =
   slot[lt]{'a} Nuprl_font!"div" slot[le]{'b}
dform div_df2 : mode[src] :: parens :: "prec"[prec_mul] :: "div"{'a; 'b} =
   slot[lt]{'a} `" div " slot[le]{'b}

dform rem_df1 : mode[prl] :: parens :: "prec"[prec_mul] :: "rem"{'a; 'b} =
   slot[lt]{'a} `" % " slot[le]{'b}
dform rem_df2 : mode[src] :: parens :: "prec"[prec_mul] :: "rem"{'a; 'b} =
   slot[lt]{'a} `" rem " slot[le]{'b}

dform lt_df1 : parens :: "prec"[prec_compare] :: lt{'a; 'b} =
   slot[lt]{'a} `" < " slot[le]{'b}

dform le_df1 : mode[prl] :: parens :: "prec"[prec_compare] :: le{'a; 'b} =
   slot[lt]{'a} Nuprl_font!le slot[le]{'b}
dform le_df2 : mode[src] :: parens :: "prec"[prec_compare] :: le{'a; 'b} =
   slot[lt]{'a} `" <= " slot[le]{'b}

dform ge_df1 : mode[prl] :: parens :: "prec"[prec_compare] :: ge{'a; 'b} =
   slot[lt]{'a} Nuprl_font!ge slot[le]{'b}
dform ge_df2 : mode[src] :: parens :: "prec"[prec_compare] :: ge{'a; 'b} =
   slot[lt]{'a} `" >= " slot[le]{'b}

dform gt_df1 : parens :: "prec"[prec_compare] :: gt{'a; 'b} =
   slot[lt]{'a} `" > " slot[le]{'b}

(************************************************************************
 * REWRITES                                                             *
 ************************************************************************)

prim_rw unfoldLE : le{'a; 'b} <--> ('a < 'b or 'a = 'b in int)
prim_rw unfoldGT : gt{'a; 'b} <--> 'b < 'a
prim_rw unfoldGE : ge{'a; 'b} <--> ('b < 'a or 'a = 'b in int)

prim_rw reduceAdd : "add"{natural_number[@i:n]; natural_number[@j:n]} <--> natural_number[@i + @j]
prim_rw reduceSub : "sub"{natural_number[@i:n]; natural_number[@j:n]} <--> natural_number[@i - @j]
prim_rw reduceMul : "mul"{natural_number[@i:n]; natural_number[@j:n]} <--> natural_number[@i * @j]
prim_rw reduceDiv : "div"{natural_number[@i:n]; natural_number[@j:n]} <--> natural_number[@i / @j]
prim_rw reduceRem : "rem"{natural_number[@i:n]; natural_number[@j:n]} <--> natural_number[@i % @j]

prim_rw reduceLT : "lt"{natural_number[@i:n]; natural_number[@j:n]} <--> "prop"[@i < @j]
prim_rw reduceEQ : (natural_number[@i:n] = natural_number[@j:n] in int) <--> "prop"[@i = @j]

(*
 * Reduction on induction combinator:
 * Three cases:
 *    let ind[x] = ind(x; i, j. down[i, j]; base; k, l. up[k, l]
 *    x < 0 => (ind[x] -> down[x, ind[x + 1]]
 *    x = 0 => (ind[x] -> base)
 *    x > 0 => (ind[x] -> up[x, ind[x - 1]]
 *)
prim_rw indReduceDown :
   'x < 0 -->
   ((ind{'x; i, j. 'down['i; 'j]; 'base; k, l. 'up['k; 'l]}) <-->
    'down['x; ind{('x +@ 1); i, j. 'down['i; 'j]; 'base; k, l. 'up['k; 'l]}])

prim_rw indReduceUp :
   ('x > 0) -->
   (ind{'x; i, j. 'down['i; 'j]; 'base; k, l. 'up['k; 'l]} <-->
    'up['x; ind{('x -@ 1); i, j. 'down['i; 'j]; 'base; k, l. 'up['k; 'l]}])

prim_rw indReduceBase :
   (ind{0; i, j. 'down['i; 'j]; 'base; k, l. 'up['k; 'l]}) <-->
   'base

mlterm indReduce{ind{'x; i, j. 'down['i; 'j]; 'base; k, l. 'up['k; 'l]}} =
   raise (RefineError ("indReduce", StringError "not implemented"))
 | fun _ _ ->
      raise (RefineError ("indReduce", StringError "not implemented"))

prim_rw indReduce : ind{'x; i, j. 'down['i; 'j]; 'base; k, l. 'up['k; 'l]} <-->
   indReduce{ind{'x; i, j. 'down['i; 'j]; 'base; k, l. 'up['k; 'l]}}

let reduce_info =
   [<< "add"{natural_number[@i:n]; natural_number[@j:n]} >>, reduceAdd;
    << "sub"{natural_number[@i:n]; natural_number[@j:n]} >>, reduceSub;
    << "mul"{natural_number[@i:n]; natural_number[@j:n]} >>, reduceMul;
    << "div"{natural_number[@i:n]; natural_number[@j:n]} >>, reduceDiv;
    << "rem"{natural_number[@i:n]; natural_number[@j:n]} >>, reduceRem]

let reduce_resource = add_reduce_info reduce_resource reduce_info

(************************************************************************
 * RULES                                                                *
 ************************************************************************)

(*
 * Reduction on induction combinator:
 * Three cases:
 *    let ind[x] = ind(x; i, j. down[i, j]; base; k, l. up[k, l]
 *    x < 0 => (ind[x] -> down[x, ind[x + 1]]
 *    x = 0 => (ind[x] -> base)
 *    x > 0 => (ind[x] -> up[x, ind[x - 1]]
 *)
(*
thm_rw indReduce ind('x; i, j. 'down['i; 'j]; 'base; k, l. 'up['k; 'l]) =
   let n = dest_natural_number x in
      if n > 0 then
         << 'down['x; 'redex] >>
      else if n < 0 then
         << 'up['x; 'redex] >>
      else
         << 'base >>
   mlend
*)

(************************************************************************
 * INTEGER RULES                                                        *
 ************************************************************************)

(*
 * H >- Ui ext Z
 * by intFormation
 *)
prim intFormation 'H : : sequent ['ext] { 'H >- univ[@i:l] } = int

(*
 * H >- int Type
 *)
prim intType 'H : : sequent ['ext] { 'H >- "type"{int} } = it

(*
 * H >- Z = Z in Ui ext Ax
 * by intEquality
 *)
prim intEquality 'H : : sequent ['ext] { 'H >- int = int in univ[@i:l] } = it

(*
 * H >- Z ext n
 * by numberFormation n
 *)
prim numberFormation 'H natural_number[@n:n] : : sequent ['ext] { 'H >- int } = natural_number[@n:n]

(*
 * H >- i = i in int
 * by numberEquality
 *)
prim numberEquality 'H : : sequent ['ext] { 'H >- natural_number[@n:n] = natural_number[@n:n] in int } = it

(*
 * Induction:
 * H, n:Z, J[n] >- C[n] ext ind(n; m, z. down[n, m, it, z]; base[n]; m, z. up[n, m, it, z])
 * by intElimination [m; v; z]
 *
 * H, n:Z, J[n], m:Z, v: m < 0, z: C[m + 1] >- C[m] ext down[n, m, v, z]
 * H, n:Z, J[n] >- C[0] ext base[n]
 * H, n:Z, J[n], m:Z, v: 0 < m, z: C[m - 1] >- C[m] ext up[n, m, v, z]
 *)
prim intElimination 'H 'J 'n 'm 'v 'z :
   ('down['n; 'm; 'v; 'z] : sequent ['ext] { 'H; n: int; 'J['n]; m: int; v: 'm < 0; z: 'C['m add 1] >- 'C['m] }) -->
   ('base['n] : sequent ['ext] { 'H; n: int; 'J['n] >- 'C[0] }) -->
   ('up['n; 'm; 'v; 'z] : sequent ['ext] { 'H; n: int; 'J['n]; m: int; v: 0 < 'm; z: 'C['m sub 1] >- 'C['m] }) -->
   sequent ['ext] { 'H; n: int; 'J['n] >- 'C['n] } =
   ind{'n; m, z. 'down['n; 'm; it; 'z]; 'base['n]; m, z. 'up['n; 'm; it; 'z]}

(*
 * Equality on induction combinator:
 * let a = ind(x1; i1, j1. down1[i1, j1]; base1; k1, l1. up1[k1, l1])
 * let b = ind(x2; i2, j2. down2[i2, j2]; base2; k2, l2. up2[k2, l2])
 *
 * H >- a = b in T[x1]
 * by indEquality [z. T[z]; x; y; w]
 *
 * H >- x1 = y1 in Z
 * H, x: Z, w: x < 0, y: T[x + 1] >- down1[x, y] = down2[x, y] in T[x]
 * H >- base1 = base2 in T[0]
 * H, x: Z, w: 0 < x, y: T[x - 1] >- up1[x, y] = up2[x, y] in T[x]
 *)
prim indEquality 'H lambda{z. 'T['z]} 'x 'y 'w :
   sequent [squash] { 'H >- 'x1 = 'x2 in int } -->
   sequent [squash] { 'H; x: int; w: 'x < 0; y: 'T['x add 1] >- 'down1['x; 'y] = 'down2['x; 'y] in 'T['x] } -->
   sequent [squash] { 'H >- 'base1 = 'base2 in 'T[0] } -->
   sequent [squash] { 'H; x: int; w: 'x > 0; y: 'T['x sub 1] >- 'up1['x; 'y] = 'up2['x; 'y] in 'T['x] } -->
   sequent ['ext] { 'H >- ind{'x1; i1, j1. 'down1['i1; 'j1]; 'base1; k1, l1. 'up1['k1; 'l1]}
                   = ind{'x2; i2, j2. 'down2['i2; 'j2]; 'base2; k2, l2. 'up2['k2; 'l2]}
                   in 'T['x1] } =
   it

(*
 * less_thanFormation:
 * H >- Ui ext a < b
 * by less_thanFormation
 *
 * H >- Z ext a
 * H >- Z ext b
 *)
prim less_thanFormation 'H :
   ('a : sequent ['ext] { 'H >- int }) -->
   ('b : sequent ['ext] { 'H >- int }) -->
   sequent ['ext] { 'H >- univ[@i:l] } =
   'a < 'b

(*
 * H >- i1 < j1 = i2 < j2 in Ui
 * by less_thanEquality
 *
 * H >- i1 = j1 in int
 * H >- i2 = j2 in int
 *)
prim less_thanEquality 'H :
   sequent [squash] { 'H >- 'i1 = 'j1 in int } -->
   sequent [squash] { 'H >- 'i2 = 'j2 in int } -->
   sequent ['ext] { 'H >- 'i1 < 'j1 = 'i2 < 'j2 in univ[@i:l] } =
   it

(*
 * H >- it = it in (a < b)
 * by less_than_memberEquality
 *
 * H >- a < b
 *)
prim less_than_memberEquality 'H :
   sequent [squash] { 'H >- 'a < 'b } -->
   sequent ['ext] { 'H >- it = it in ('a < 'b) } =
   it

(*
 * H, x: a < b, J[x] >- C[x]
 * by less_than_Elimination i
 *
 * H, x: a < b; J[it] >- C[it]
 *)
prim less_thanElimination 'H 'J :
   ('t : sequent ['ext] { 'H; x: 'a < 'b; 'J[it] >- 'C[it] }) -->
   sequent ['ext] { 'H; x: 'a < 'b; 'J['x] >- 'C['x] } =
   't

(*
 * Integers are canonical.
 *)
prim int_sqequal 'H :
   sequent [squash] { 'H >- 'i = 'j in int } -->
   sequent ['ext] { 'H >- Perv!"rewrite"{'i; 'j} } =
   it

(************************************************************************
 * TACTICS                                                              *
 ************************************************************************)

let int_term = << int >>
let int_opname = opname_of_term int_term
let is_int_term = is_no_subterms_term int_opname

let lt_term = << 'x < 'y >>
let lt_opname = opname_of_term lt_term
let is_lt_term = is_dep0_dep0_term lt_opname
let mk_lt_term = mk_dep0_dep0_term lt_opname
let dest_lt = dest_dep0_dep0_term lt_opname

let le_term = << 'x <= 'y >>
let le_opname = opname_of_term le_term
let is_le_term = is_dep0_dep0_term le_opname
let mk_le_term = mk_dep0_dep0_term le_opname
let dest_le = dest_dep0_dep0_term le_opname

let ge_term = << 'x >= 'y >>
let ge_opname = opname_of_term ge_term
let is_ge_term = is_dep0_dep0_term ge_opname
let mk_ge_term = mk_dep0_dep0_term ge_opname
let dest_ge = dest_dep0_dep0_term ge_opname

let gt_term = << 'x > 'y >>
let gt_opname = opname_of_term gt_term
let is_gt_term = is_dep0_dep0_term gt_opname
let mk_gt_term = mk_dep0_dep0_term gt_opname
let dest_gt = dest_dep0_dep0_term gt_opname

let add_term = << 'x +@ 'y >>
let add_opname = opname_of_term add_term
let is_add_term = is_dep0_dep0_term add_opname
let mk_add_term = mk_dep0_dep0_term add_opname
let dest_add = dest_dep0_dep0_term add_opname

let sub_term = << 'x -@ 'y >>
let sub_opname = opname_of_term sub_term
let is_sub_term = is_dep0_dep0_term sub_opname
let mk_sub_term = mk_dep0_dep0_term sub_opname
let dest_sub = dest_dep0_dep0_term sub_opname

let mul_term = << 'x *@ 'y >>
let mul_opname = opname_of_term mul_term
let is_mul_term = is_dep0_dep0_term mul_opname
let mk_mul_term = mk_dep0_dep0_term mul_opname
let dest_mul = dest_dep0_dep0_term mul_opname

let div_term = << 'x /@ 'y >>
let div_opname = opname_of_term div_term
let is_div_term = is_dep0_dep0_term div_opname
let mk_div_term = mk_dep0_dep0_term div_opname
let dest_div = dest_dep0_dep0_term div_opname

let rem_term = << "rem"{'x; 'y} >>
let rem_opname = opname_of_term rem_term
let is_rem_term = is_dep0_dep0_term rem_opname
let mk_rem_term = mk_dep0_dep0_term rem_opname
let dest_rem = dest_dep0_dep0_term rem_opname

let natural_number_term = << natural_number[@n:n] >>
let natural_number_opname = opname_of_term natural_number_term
let is_natural_number_term = is_number_term natural_number_opname
let dest_natural_number = dest_number_term natural_number_opname
let mk_natural_number_term = mk_number_term natural_number_opname

let ind_term = << ind{'i; m, z. 'down; 'base; m, z. 'up} >>
let ind_opname = opname_of_term ind_term
let is_ind_term = is_dep0_dep2_dep0_dep2_term ind_opname
let dest_ind = dest_dep0_dep2_dep0_dep2_term ind_opname
let mk_ind_term = mk_dep0_dep2_dep0_dep2_term ind_opname

(************************************************************************
 * D TACTIC                                                             *
 ************************************************************************)

(*
 * D
 *)
let zero = << 0 >>

let d_intT i p =
   if i = 0 then
      numberFormation (hyp_count_addr p) zero p
   else
      let n, _ = Sequent.nth_hyp p i in
      let j, k = hyp_indices p i in
      let m, v, z = maybe_new_vars3 p "m" "v" "z" in
         intElimination j k n m v z p

let d_resource = Mp_resource.improve d_resource (int_term, d_intT)

let d_int_typeT i p =
   if i = 0 then
      intType (hyp_count_addr p) p
   else
      raise (RefineError ("d_int_type", StringError "no elimination form"))

let int_type_term = << "type"{int} >>

let d_resource = Mp_resource.improve d_resource (int_type_term, d_int_typeT)

(*
 * Squiggle.
 *)
let intSqequalT p =
   int_sqequal (Sequent.hyp_count_addr p) p

(************************************************************************
 * EQCD TACTIC                                                          *
 ************************************************************************)

(*
 * EqCD int.
 *)
let eqcd_intT p = intEquality (hyp_count_addr p) p

let eqcd_numberT p = numberEquality (hyp_count_addr p) p

let eqcd_resource = Mp_resource.improve eqcd_resource (int_term, eqcd_intT)
let eqcd_resource = Mp_resource.improve eqcd_resource (natural_number_term, eqcd_numberT)

(************************************************************************
 * TYPE INFERENCE                                                       *
 ************************************************************************)

(*
 * Type of int.
 *)
let inf_int _ decl _ = decl, univ1_term

let typeinf_resource = Mp_resource.improve typeinf_resource (int_term, inf_int)

(*
 * Type of natural_number.
 *)
let inf_natural_number _ decl _ = decl, int_term

let typeinf_resource = Mp_resource.improve typeinf_resource (natural_number_term, inf_natural_number)

(*
 * Type of ind.
 *)
let inf_ind inf decl t =
   let i, a, b, down, base, c, d, up = dest_ind t in
      inf decl base

let typeinf_resource = Mp_resource.improve typeinf_resource (ind_term, inf_ind)

(*
 * -*-
 * Local Variables:
 * Caml-master: "prlcomp.run"
 * End:
 * -*-
 *)
