(*
 * A type of finite sets.
 * The sets are represented as lists of elements,
 * quotiented over all permutations.
 *
 * Each set must have a computable equality.
 * We provide an enumeration function.
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

include Itt_bool
include Itt_fun
include Itt_quotient
include Itt_list
include Itt_list2

open Refiner.Refiner.TermType
open Refiner.Refiner.Term
open Refiner.Refiner.TermOp
open Refiner.Refiner.RefineError
open Mp_resource
open Mp_debug
open Printf

open Tactic_type
open Tactic_type.Tacticals
open Tactic_type.Conversionals
open Var

open Base_dtactic
open Base_auto_tactic
open Typeinf

open Itt_equal
open Itt_bool
open Itt_rfun
open Itt_list
open Itt_struct
open Itt_logic
open Itt_quotient

(************************************************************************
 * DEFINITIONS                                                          *
 ************************************************************************)

define unfold_fcompare : fcompare{'eq; 'x; 'y} <--> ('eq 'x 'y)

define unfold_fmember : fmember{'eq; 'x; 's1} <-->
   list_ind{'s1; bfalse; h, t, g. bor{.fcompare{'eq; 'x; 'h}; 'g}}

define unfold_fsubseteq : fsubseteq{'eq; 's1; 's2} <-->
   list_ind{'s1; btrue; h, t, g. band{fmember{'eq; 'h; 's2}; 'g}}

define unfold_fequal : fequal{'eq; 's1; 's2} <-->
   band{fsubseteq{'eq; 's1; 's2}; fsubseteq{'eq; 's2; 's1}}

define unfold_fequalp : fequalp{'eq; 'T} <-->
   ((((('eq IN ('T -> 'T -> bool))
      & (all x: 'T. "assert"{.fcompare{'eq; 'x; 'x}}))
      & (all x: 'T. all y: 'T. ("assert"{fcompare{'eq; 'x; 'y}} => "assert"{fcompare{'eq; 'y; 'x}})))
      & (all x: 'T. all y: 'T. all z: 'T. ("assert"{fcompare{'eq; 'x; 'y}} => ("assert"{fcompare{'eq; 'y; 'z}} => "assert"{fcompare{'eq; 'x; 'z}})))))

define unfold_fset : fset{'eq; 'T} <--> (quot x, y : list{'T} // "assert"{fequal{'eq; 'x; 'y}})

define unfold_fempty : fempty <--> nil

define unfold_fsingleton : fsingleton{'x} <--> cons{'x; nil}

define unfold_funion : funion{'eq; 's1; 's2} <--> append{'s1; 's2}

define unfold_fisect : fisect{'eq; 's1; 's2} <-->
   list_ind{'s1; nil; h, t, g. ifthenelse{fmember{'eq; 'h; 's2}; cons{'h; 'g}; 'g}}

define unfold_fsub : fsub{'eq; 's1; 's2} <-->
   list_ind{'s1; nil; h, t, g. ifthenelse{fmember{'eq; 'h; 's2}; 'g; cons{'h; 'g}}}

define unfold_fisempty : fisempty{'s} <-->
   list_ind{'s; btrue; h, t, g. bfalse}

define unfold_fsquash : fsquash{'eq; 's} <-->
   list_ind{'s; nil; h, t, g. ifthenelse{fmember{'eq; 'h; 't}; 'g; cons{it; 'g}}}

define unfold_fball : fball{'s; x. 'b['x]} <-->
   list_ind{'s; btrue; x, t, g. band{'b['x]; 'g}}

define unfold_fbexists : fbexists{'s; x. 'b['x]} <-->
   list_ind{'s; bfalse; x, t, g. bor{'b['x]; 'g}}

define unfold_fall : fall{'eq; 'T; 's; x. 'b['x]} <-->
   (all x: { y: 'T | "assert"{fmember{'eq; 'y; 's}} }. 'b['x])

define unfold_fexists : fexists{'eq; 'T; 's; x. 'b['x]} <-->
   (exst x: { y: 'T | "assert"{fmember{'eq; 'y; 's}} }. 'b['x])

define unfold_feset : feset{'eq; 'T} <--> (quot x, y: 'T // "assert"{fcompare{'eq; 'x; 'y}})

define unfold_foflist : foflist{'l} <--> 'l

let fold_fequalp = makeFoldC << fequalp{'eq; 'T} >> unfold_fequalp
let fold_fset = makeFoldC << fset{'eq; 'T} >> unfold_fset
let fold_fempty = makeFoldC << fempty >> unfold_fempty
let fold_fsingleton = makeFoldC << fsingleton{'x} >> unfold_fsingleton
let fold_fisect = makeFoldC << fisect{'eq; 's1; 's2} >> unfold_fisect
let fold_fsub = makeFoldC << fsub{'eq; 's1; 's2} >> unfold_fsub
let fold_fmember = makeFoldC << fmember{'eq; 'x; 's1} >> unfold_fmember
let fold_fisempty = makeFoldC << fisempty{'s1} >> unfold_fisempty
let fold_fsubseteq = makeFoldC << fsubseteq{'e1; 's1; 's2} >> unfold_fsubseteq
let fold_fequal = makeFoldC << fequal{'eq; 's1; 's2} >> unfold_fequal
let fold_fsquash = makeFoldC << fsquash{'eq; 's1} >> unfold_fsquash
let fold_fball = makeFoldC << fball{'s; x. 'b['x]} >> unfold_fball
let fold_fbexists = makeFoldC << fbexists{'s; x. 'b['x]} >> unfold_fbexists
let fold_fall = makeFoldC << fall{'eq; 'T; 's; x. 'b['x]} >> unfold_fall
let fold_fexists = makeFoldC << fexists{'eq; 'T; 's; x. 'b['x]} >> unfold_fexists
let fold_feset = makeFoldC << feset{'eq; 'T} >> unfold_feset
let fold_foflist = makeFoldC << foflist{'l} >> unfold_foflist

(************************************************************************
 * TERMS                                                                *
 ************************************************************************)

let fempty_term = << fempty >>
let fsingleton_term = << fsingleton{'x} >>
let funion_term = << funion{'eq; 's1; 's2} >>
let fisect_term = << fisect{'eq; 's1; 's2} >>
let fsub_term = << fsub{'eq; 's1; 's2} >>
let fisempty_term = << fisempty{'s1} >>
let fmember_term = << fmember{'eq; 'x; 's1} >>
let fsubseteq_term = << fsubseteq{'eq; 's1; 's2} >>
let fequal_term = << fequal{'eq; 's1; 's2} >>
let fcompare_term = << fcompare{'eq; 'x1; 'x2} >>
let fequalp_term = << fequalp{'eq; 'T} >>
let fset_term = << fset{'eq; 'T} >>

let fempty_opname = opname_of_term fempty_term
let fsingleton_opname = opname_of_term fsingleton_term
let funion_opname = opname_of_term funion_term
let fisect_opname = opname_of_term fisect_term
let fsub_opname = opname_of_term fsub_term
let fisempty_opname = opname_of_term fisempty_term
let fmember_opname = opname_of_term fmember_term
let fsubseteq_opname = opname_of_term fsubseteq_term
let fequal_opname = opname_of_term fequal_term
let fcompare_opname = opname_of_term fcompare_term
let fequalp_opname = opname_of_term fequalp_term
let fset_opname = opname_of_term fset_term

let dest_fsingleton = dest_dep0_term fsingleton_opname
let dest_funion = dest_dep0_dep0_dep0_term funion_opname
let dest_fisect = dest_dep0_dep0_dep0_term fisect_opname
let dest_fsub = dest_dep0_dep0_dep0_term fsub_opname
let dest_fisempty = dest_dep0_term fisempty_opname
let dest_fmember = dest_dep0_dep0_dep0_term fmember_opname
let dest_fsubseteq = dest_dep0_dep0_dep0_term fsubseteq_opname
let dest_fequal = dest_dep0_dep0_dep0_term fequal_opname
let dest_fcompare = dest_dep0_dep0_dep0_term fcompare_opname
let dest_fequalp = dest_dep0_dep0_term fequalp_opname
let dest_fset = dest_dep0_dep0_term fset_opname

let is_fset_term = is_dep0_dep0_term fset_opname

let mk_fset_term = mk_dep0_dep0_term fset_opname

(************************************************************************
 * DISPLAY                                                              *
 ************************************************************************)

prec prec_fsubseteq
prec prec_fmember
prec prec_funion
prec prec_fisect
prec prec_fexists
prec prec_fall
prec prec_feset
prec prec_foflist

(*
 * fall < fexists < funion < fisect < fmember
 *      fsubseteq <
 *)
prec prec_fsubseteq < prec_funion
prec prec_fall < prec_fexists
prec prec_fexists < prec_funion
prec prec_funion < prec_fisect
prec prec_fisect < prec_fmember
prec prec_fmember < prec_foflist
prec prec_foflist < prec_bimplies

dform fequalp_df : except_mode[src] :: fequalp{'eq; 'T} =
   `"fequalp(" slot{'eq} `"; " slot{'T} `")"

dform fcompare_df : parens :: "prec"[prec_fsubseteq] :: except_mode[src] :: fcompare{'eq; 'x1; 'x2} =
   slot{'x1} `" =" slot{'eq} space slot{'x2}

dform fsubseteq_df1 : parens :: "prec"[prec_fsubseteq] :: except_mode[src] :: fsubseteq{'eq; 'A; 'B} =
   slot{'A} `" " subseteq slot{'eq} space slot{'B}

dform fequal_df1 : parens :: "prec"[prec_fsubseteq] :: except_mode[src] :: fequal{'eq; 'A; 'B} =
   slot{'A} `" =" slot{'eq} space slot{'B}

dform fmember_df : parens :: "prec"[prec_fmember] :: except_mode[src] :: fmember{'eq; 'x; 's} =
   slot{'x} space Nuprl_font!member slot{'eq} space slot{'s}

dform fset_df : except_mode[src] :: fset{'eq; 'T} =
   `"FSet(" slot{'eq} `"; " slot{'T} `")"

dform fempty_df : except_mode[src] :: fempty =
   `"{}"

dform fsingleton_df : except_mode[src] :: fsingleton{'x} =
   `"{" slot{'x} `"}"

dform funion_df : parens :: "prec"[prec_funion] :: except_mode[src] :: funion{'eq; 's1; 's2} =
   slot{'s1} space cup slot{'eq} space slot{'s2}

dform fisect_df : parens :: "prec"[prec_fisect] :: except_mode[src] :: fisect{'eq; 's1; 's2} =
   slot["le"]{'s1} space cap slot{'eq} space slot{'s2}

dform fsub_df : parens :: "prec"[prec_fisect] :: except_mode[src] :: fsub{'eq; 's1; 's2} =
   slot["le"]{'s1} space `"-" slot{'eq} space slot{'s2}

dform fsquash_df : fsquash{'eq; 's1} =
   `"|" slot{'s1} `"|" slot{'eq}

dform fball_df : parens :: "prec"[prec_fall] :: except_mode[src] :: fball{'s; x. 'b} =
   pushm[3] Nuprl_font!"forall" subb slot{'x} space Nuprl_font!member space slot{'s} sbreak["",". "]
      slot{'b} popm

dform fbexists_df : parens :: "prec"[prec_fexists] :: except_mode[src] :: fbexists{'s; x. 'b} =
   pushm[3] Nuprl_font!"exists" subb slot{'x} space Nuprl_font!member space slot{'s} sbreak["",". "]
      slot{'b} popm

dform fall_df : parens :: "prec"[prec_fall] :: except_mode[src] :: fall{'eq; 'T; 's; x. 'b} =
   pushm[3] Nuprl_font!"forall" slot{'x} space Nuprl_font!member slot{'eq} space slot{'s}
   Nuprl_font!member space slot{'T} sbreak["",". "]
      slot{'b} popm

dform fexists_df : parens :: "prec"[prec_fexists] :: except_mode[src] :: fexists{'eq; 'T; 's; x. 'b} =
   pushm[3] Nuprl_font!"exists" slot{'x} space Nuprl_font!member slot{'eq} space slot{'s}
   Nuprl_font!member space slot{'T} sbreak["",". "]
      slot{'b} popm

dform feset_df : parens :: "prec"[prec_feset] :: except_mode[src] :: feset{'eq; 'T} =
   slot{'T} `"//" slot{'eq}

dform foflist_df : parens :: "prec"[prec_foflist] :: except_mode[src] :: foflist{'l} =
   `"of_list " slot{'l}

(************************************************************************
 * REDUCTIONS                                                           *
 ************************************************************************)

(*
 * Fmember on lists.
 *)
interactive_rw reduce_fmember_nil : fmember{'eq; 'x; nil} <--> bfalse

interactive_rw reduce_fmember_cons : fmember{'eq; 'x; cons{'h; 't}} <-->
   bor{.fcompare{'eq; 'x; 'h}; fmember{'eq; 'x; 't}}

let resource reduce +=
   [<< fmember{'eq; 'x; nil} >>, reduce_fmember_nil;
    << fmember{'eq; 'x; cons{'h; 't}} >>, reduce_fmember_cons]

(*
 * Singleton.
 *)
interactive_rw reduce_fmember_fsingleton : fmember{'eq; 'x; fsingleton{'y}} <-->
   bor{fcompare{'eq; 'x; 'y}; bfalse}

let resource reduce +=
   << fmember{'eq; 'x; fsingleton{'y}} >>, reduce_fmember_fsingleton

(*
 * Subset.
 *)
interactive_rw reduce_fsubseteq_nil : fsubseteq{'eq; nil; 's} <--> btrue

interactive_rw reduce_fsubseteq_cons :
   fsubseteq{'eq; cons{'h; 't}; 's} <-->
   band{fmember{'eq; 'h; 's}; fsubseteq{'eq; 't; 's}}

let resource reduce +=
   [<< fsubseteq{'eq; nil; 'l} >>, reduce_fsubseteq_nil;
    << fsubseteq{'eq; cons{'h; 't}; 'l} >>, reduce_fsubseteq_cons]

(*
 * Union.
 *)
interactive_rw reduce_funion_nil :
   funion{'eq; nil; 's} <--> 's

interactive_rw reduce_funion_cons :
   funion{'eq; cons{'h; 't}; 's} <--> cons{'h; funion{'eq; 't; 's}}

let resource reduce +=
   [<< funion{'eq; nil; 's} >>, reduce_funion_nil;
    << funion{'eq; cons{'h; 't}; 's} >>, reduce_funion_cons]

(*
 * Intersection.
 *)
interactive_rw reduce_fisect_nil :
   fisect{'eq; nil; 's2} <--> nil

interactive_rw reduce_fisect_cons :
   fisect{'eq; cons{'h; 't}; 's} <-->
      ifthenelse{fmember{'eq; 'h; 's}; cons{'h; fisect{'eq; 't; 's}}; fisect{'eq; 't; 's}}

let resource reduce +=
   [<< fisect{'eq; nil; 's} >>, reduce_fisect_nil;
    << fisect{'eq; cons{'h; 't}; 's} >>, reduce_fisect_cons]

(*
 * Set subtraction.
 *)
interactive_rw reduce_fsub_nil :
   fsub{'eq; nil; 's2} <--> nil

interactive_rw reduce_fsub_cons :
   fsub{'eq; cons{'h; 't}; 's} <-->
      ifthenelse{fmember{'eq; 'h; 's}; fsub{'eq; 't; 's}; cons{'h; fsub{'eq; 't; 's}}}

let resource reduce +=
   [<< fsub{'eq; nil; 's} >>, reduce_fsub_nil;
    << fsub{'eq; cons{'h; 't}; 's} >>, reduce_fsub_cons]

(*
 * Membership squashing.
 *)
interactive_rw reduce_fsquash_nil1 :
   fsquash{'eq; nil} <--> nil

interactive_rw reduce_fsquash_cons1 :
   fsquash{'eq; cons{'h; 't}} <-->
      ifthenelse{fmember{'eq; 'h; 't}; fsquash{'eq; 't}; cons{it; fsquash{'eq; 't}}}

let resource reduce +=
   [<< fsquash{'eq; nil} >>, reduce_fsquash_nil1;
    << fsquash{'eq; cons{'h; 't}} >>, reduce_fsquash_cons1]

(*
 * Universal quantification.
 *)
interactive_rw reduce_fball_nil :
   fball{nil; x. 'b['x]} <--> btrue

interactive_rw reduce_fball_cons :
   fball{cons{'h; 't}; x. 'b['x]} <-->
      band{'b['h]; fball{'t; x. 'b['x]}}

let resource reduce +=
   [<< fball{nil; x. 'b['x]} >>, reduce_fball_nil;
    << fball{cons{'h; 't}; x. 'b['x]} >>, reduce_fball_cons]

(*
 * Existential quantification.
 *)
interactive_rw reduce_fbexists_nil :
   fbexists{nil; x. 'b['x]} <--> bfalse

interactive_rw reduce_fbexists_cons :
   fbexists{cons{'h; 't}; x. 'b['x]} <-->
      bor{'b['h]; fbexists{'t; x. 'b['x]}}

let resource reduce +=
   [<< fbexists{nil; x. 'b['x]} >>, reduce_fbexists_nil;
    << fbexists{cons{'h; 't}; x. 'b['x]} >>, reduce_fbexists_cons]

(************************************************************************
 * TYPE INFERENCE                                                       *
 ************************************************************************)

(*
 * Fequalp gives more info.
 *)
let infer_fequalp subst (so, t) =
   let eq, t = dest_fequalp t in
      if is_var_term eq then
         (dest_var eq, mk_fun_term t (mk_fun_term t bool_term)) :: subst
      else
         subst

let resource typeinf_subst += (fequalp_term, infer_fequalp)

(*
(*
 * Type of pair.
 *)
let inf_funion f decl t =
   let eq, s1, s2 = dest_funion t in
   let decl, s1 = f decl s1 in
      decl, s1

let inf_fisect f decl t =
   let eq, s1, s2 = dest_fisect t in
   let decl, s1 = f decl s1 in
      decl, s1

let inf_fsub f decl t =
   let eq, s1, s2 = dest_fsub t in
   let decl, s1 = f decl s1 in
      decl, s1

let inf_fisempty f decl t =
   decl, bool_term

let inf_fmember f decl t =
   decl, bool_term

let inf_fsubseteq f decl t =
   decl, bool_term

let inf_fequal f decl t =
   decl, bool_term

let inf_fcompare f decl t =
   decl, bool_term

let inf_fsingleton f decl t =
   let t = one_subterm t in
   let decl, t = f decl t in
      decl, mk_list_term t

let resource typeinf +=
   [<< funion{'eq; 's1; 's2} >>, inf_funion;
    << fisect{'eq; 's1; 's2} >>, inf_fisect;
    << fsub{'eq; 's1; 's2} >>, inf_fsub;
    << fisempty{'x} >>, inf_fisempty;
    << fmember{'eq; 'x; 's1} >>, inf_fmember;
    << fsubseteq{'eq; 's1; 's2} >>, inf_fsubseteq;
    << fequal{'eq; 's1; 's2} >>, inf_fequal;
    << fcompare{'eq; 'x1; 'x2} >>, inf_fcompare;
    << fsingleton{'x} >>, inf_fsingleton]
*)

let dest_fset_type t =
   if !(load_debug "auto") then eprintf "\ttype is %a%t" print_term t eflush;
   if is_list_term t then
      dest_list t
   else if is_fset_term t then
      snd (dest_fset t)
   else (* if is_quotient_term t then *)
      let _, _, tlist, _ = dest_quotient t in
      dest_list tlist

let typeinf_fset_arg p t =
   let t =
      try get_with_arg p with
         RefineError _ ->
            if !(load_debug "auto") then eprintf "Type of: %a%t" print_term t eflush;
            dest_fset_type (infer_type p t)
   in
      [t]

let intro_typeinf_fset t = IntroArgsOption (typeinf_fset_arg, Some t)
let elim_typeinf_fset t = ElimArgsOption (typeinf_fset_arg, Some t)

(************************************************************************
 * RULES                                                                *
 ************************************************************************)

interactive fcompare_wf {| intro [intro_typeinf <<'x>>] |} 'H 'T :
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 'x IN 'T } -->
   sequent [squash] { 'H >- 'y IN 'T } -->
   sequent ['ext] { 'H >- fcompare{'eq; 'x; 'y} IN bool }

interactive fcompare_ref {| intro [intro_typeinf <<'x>>] |} 'H 'T :
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 'x IN 'T } -->
   sequent ['ext] { 'H >- "assert"{fcompare{'eq; 'x; 'x}} }

interactive fcompare_sym 'H 'T :
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 'x IN 'T } -->
   sequent [squash] { 'H >- 'y IN 'T } -->
   sequent [squash] { 'H >- "assert"{fcompare{'eq; 'y; 'x}} } -->
   sequent ['ext] { 'H >- "assert"{fcompare{'eq; 'x; 'y}} }

interactive fcompare_trans 'H 'T 'z :
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 'x IN 'T } -->
   sequent [squash] { 'H >- 'y IN 'T } -->
   sequent [squash] { 'H >- 'z IN 'T } -->
   sequent [squash] { 'H >- "assert"{fcompare{'eq; 'x; 'z}} } -->
   sequent [squash] { 'H >- "assert"{fcompare{'eq; 'z; 'y}} } -->
   sequent ['ext] { 'H >- "assert"{fcompare{'eq; 'x; 'y}} }

interactive fmember_wf1 {| intro [intro_typeinf << 'x >>] |} 'H 'T :
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 'x IN 'T } -->
   sequent [squash] { 'H >- 's IN list{'T} } -->
   sequent ['ext] { 'H >- fmember{'eq; 'x; 's} IN bool }

interactive fmember_fun 'H 'T 'y :
   ["wf"] sequent [squash] { 'H >- 'x IN 'T } -->
   ["wf"] sequent [squash] { 'H >- 'y IN 'T } -->
   ["wf"] sequent [squash] { 'H >- 'l IN list{'T} } -->
   ["wf"] sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- "assert"{fcompare{'eq; 'x; 'y}} } -->
   sequent [squash] { 'H >- "assert"{fmember{'eq; 'y; 'l}} } -->
   sequent ['ext] { 'H >- "assert"{fmember{'eq; 'x; 'l}} }

interactive fsubseteq_wf1 {| intro [intro_typeinf_fset <<'s2>>] |} 'H 'T :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's1 IN list{'T} } -->
   sequent [squash] { 'H >- 's2 IN list{'T} } -->
   sequent ['ext] { 'H >- fsubseteq{'eq; 's1; 's2} IN bool }

interactive fsubseteq_elim2 {| elim [] |} 'H 'J 'T 'a 'y :
   ["wf"] sequent [squash] { 'H; x: "assert"{fsubseteq{'eq; 'l1; 'l2}}; 'J['x] >- fequalp{'eq; 'T} } -->
   ["wf"] sequent [squash] { 'H; x: "assert"{fsubseteq{'eq; 'l1; 'l2}}; 'J['x] >- 'a IN 'T } -->
   ["wf"] sequent [squash] { 'H; x: "assert"{fsubseteq{'eq; 'l1; 'l2}}; 'J['x] >- 'l1 IN list{'T} } -->
   ["wf"] sequent [squash] { 'H; x: "assert"{fsubseteq{'eq; 'l1; 'l2}}; 'J['x] >- 'l2 IN list{'T} } -->
   sequent [squash] { 'H; x: "assert"{fsubseteq{'eq; 'l1; 'l2}}; 'J['x] >- "assert"{fmember{'eq; 'a; 'l1}} } -->
   sequent ['ext] { 'H; x: "assert"{fsubseteq{'eq; 'l1; 'l2}}; 'J['x]; y: "assert"{fmember{'eq; 'a; 'l2}} >- 'C['x] } -->
   sequent ['ext] { 'H; x: "assert"{fsubseteq{'eq; 'l1; 'l2}}; 'J['x] >- 'C['x] }

interactive fsubseteq_intro1 {| intro [AutoMustComplete; intro_typeinf_fset <<'s2>>] |} 'H 'T 'x 'y :
   ["wf"] sequent [squash] { 'H >- "type"{'T} } -->
   ["wf"] sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   ["wf"] sequent [squash] { 'H >- 's1 IN list{'T} } -->
   ["wf"] sequent [squash] { 'H >- 's2 IN list{'T} } -->
   sequent [squash] { 'H; x: 'T; y: "assert"{fmember{'eq; 'x; 's1}} >- "assert"{fmember{'eq; 'x; 's2}} } -->
   sequent ['ext] { 'H >- "assert"{fsubseteq{'eq; 's1; 's2}} }

interactive fsubseteq_cons2 {| intro [intro_typeinf <<'u>>] |} 'H 'T :
   ["wf"] sequent [squash] { 'H >- 'l1 IN list{'T} } -->
   ["wf"] sequent [squash] { 'H >- 'l2 IN list{'T} } -->
   ["wf"] sequent [squash] { 'H >- 'u IN 'T } -->
   ["wf"] sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- "assert"{fsubseteq{'eq; 'l1; 'l2}} } -->
   sequent ['ext] { 'H >- "assert"{fsubseteq{'eq; 'l1; cons{'u; 'l2}}} }

interactive fsubseteq_ref {| intro [intro_typeinf_fset <<'l>>] |} 'H 'T :
   ["wf"] sequent [squash] { 'H >- "type"{'T} } -->
   ["wf"] sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   ["wf"] sequent [squash] { 'H >- 'l IN list{'T} } -->
   sequent ['ext] { 'H >- "assert"{fsubseteq{'eq; 'l; 'l}} }

interactive fsubseteq_trans 'H 'T 'l2 :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 'l1 IN list{'T} } -->
   sequent [squash] { 'H >- 'l2 IN list{'T} } -->
   sequent [squash] { 'H >- 'l3 IN list{'T} } -->
   sequent [squash] { 'H >- "assert"{fsubseteq{'eq; 'l1; 'l2}} } -->
   sequent [squash] { 'H >- "assert"{fsubseteq{'eq; 'l2; 'l3}} } -->
   sequent ['ext] { 'H >- "assert"{fsubseteq{'eq; 'l1; 'l3}} }

interactive fequal_wf1 {| intro [intro_typeinf_fset <<'s1>>] |} 'H 'T :
   [wf] sequent [squash] { 'H >- "type"{'T} } -->
   [wf] sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   [wf] sequent [squash] { 'H >- 's1 IN list{'T} } -->
   [wf] sequent [squash] { 'H >- 's2 IN list{'T} } -->
   sequent ['ext] { 'H >- fequal{'eq; 's1; 's2} IN bool }

interactive fequal_elim1 'H 'J 'T 'a 'y :
   sequent [squash] { 'H; x: "assert"{fequal{'eq; 's1; 's2}}; 'J['x] >- 'a IN 'T } -->
   sequent [squash] { 'H; x: "assert"{fequal{'eq; 's1; 's2}}; 'J['x] >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H; x: "assert"{fequal{'eq; 's1; 's2}}; 'J['x] >- 's1 IN list{'T} } -->
   sequent [squash] { 'H; x: "assert"{fequal{'eq; 's1; 's2}}; 'J['x] >- 's2 IN list{'T} } -->
   sequent [squash] { 'H; x: "assert"{fequal{'eq; 's1; 's2}}; 'J['x] >- "assert"{fmember{'eq; 'a; 's1}} } -->
   sequent ['ext] { 'H; x: "assert"{fequal{'eq; 's1; 's2}}; 'J['x]; y: "assert"{fmember{'eq; 'a; 's2}} >- 'C['x] } -->
   sequent ['ext] { 'H; x: "assert"{fequal{'eq; 's1; 's2}}; 'J['x] >- 'C['x] }

interactive fequal_intro1 {| intro [intro_typeinf_fset <<'s1>>] |} 'H 'T 'x 'y :
   [wf] sequent [squash] { 'H >- "type"{'T} } -->
   [wf] sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   [wf] sequent [squash] { 'H >- 's1 IN list{'T} } -->
   [wf] sequent [squash] { 'H >- 's2 IN list{'T} } -->
   sequent [squash] { 'H; x: 'T; y: "assert"{fmember{'eq; 'x; 's1}} >- "assert"{fmember{'eq; 'x; 's2}} } -->
   sequent [squash] { 'H; x: 'T; y: "assert"{fmember{'eq; 'x; 's2}} >- "assert"{fmember{'eq; 'x; 's1}} } -->
   sequent ['ext] { 'H >- "assert"{fequal{'eq; 's1; 's2}} }

interactive fset_type {| intro [] |} 'H :
   [wf] sequent [squash] { 'H >- "type"{'T} } -->
   [wf] sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent ['ext] { 'H >- "type"{fset{'eq; 'T}} }

interactive fset_list {| intro [AutoMustComplete] |} 'H :
   [wf] sequent [squash] { 'H >- "type"{'T} } -->
   [wf] sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   [wf] sequent [squash] { 'H >- 'x IN list{'T} } -->
   sequent ['ext] { 'H >- 'x IN fset{'eq; 'T} }

(*
 * Membership.
 *)
interactive fmember_wf2 {| intro [intro_typeinf <<'x>>] |} 'H 'T :
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 'x IN 'T } -->
   sequent [squash] { 'H >- 's IN fset{'eq; 'T} } -->
   sequent ['ext] { 'H >- fmember{'eq; 'x; 's} IN bool }

(*
 * Subset.
 *)
interactive fsubseteq_wf2 {| intro [intro_typeinf_fset <<'s2>>] |} 'H 'T :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's1 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H >- 's2 IN fset{'eq; 'T} } -->
   sequent ['ext] { 'H >- fsubseteq{'eq; 's1; 's2} IN bool }

(*
 * Equality.
 *)
interactive fequal_wf2 {| intro [intro_typeinf_fset <<'s1>>] |} 'H 'T :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's1 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H >- 's2 IN fset{'eq; 'T} } -->
   sequent ['ext] { 'H >- fequal{'eq; 's1; 's2} IN bool }

interactive fequal_intro2 {| intro [intro_typeinf_fset <<'s1>>] |} 'H 'T 'x 'y :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's1 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H >- 's2 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H; x: 'T; y: "assert"{fmember{'eq; 'x; 's1}} >- "assert"{fmember{'eq; 'x; 's2}} } -->
   sequent [squash] { 'H; x: 'T; y: "assert"{fmember{'eq; 'x; 's2}} >- "assert"{fmember{'eq; 'x; 's1}} } -->
   sequent ['ext] { 'H >- "assert"{fequal{'eq; 's1; 's2}} }

interactive fempty_wf {| intro [] |} 'H :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- "type"{fset{'eq; 'T}} } -->
   sequent ['ext] { 'H >- fempty IN fset{'eq; 'T} }

interactive fsingleton_wf {| intro [] |} 'H :
   sequent [squash] { 'H >- 'x IN 'T } -->
   sequent [squash] { 'H >- "type"{fset{'eq; 'T}} } -->
   sequent ['ext] { 'H >- fsingleton{'x} IN fset{'eq; 'T} }

(*
 * Union.
 *)
interactive funion_wf1 {| intro [] |} 'H :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's1 IN list{'T} } -->
   sequent [squash] { 'H >- 's2 IN list{'T} } -->
   sequent ['ext] { 'H >- funion{'eq; 's1; 's2} IN list{'T} }

interactive funion_member_intro_left2 'H 'T :
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 'x IN 'T } -->
   sequent [squash] { 'H >- 's1 IN list{'T} } -->
   sequent [squash] { 'H >- 's2 IN list{'T} } -->
   sequent [squash] { 'H >- "assert"{fmember{'eq; 'x; 's1}} } -->
   sequent ['ext] { 'H >- "assert"{fmember{'eq; 'x; funion{'eq; 's1; 's2}}} }

interactive funion_member_intro_right2 'H 'T :
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 'x IN 'T } -->
   sequent [squash] { 'H >- 's1 IN list{'T} } -->
   sequent [squash] { 'H >- 's2 IN list{'T} } -->
   sequent [squash] { 'H >- "assert"{fmember{'eq; 'x; 's2}} } -->
   sequent ['ext] { 'H >- "assert"{fmember{'eq; 'x; funion{'eq; 's1; 's2}}} }

interactive funion_member_elim2 'H 'J 'T :
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; funion{'eq; 's1; 's2}}}; 'J[it] >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; funion{'eq; 's1; 's2}}}; 'J[it] >- 'x IN 'T } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; funion{'eq; 's1; 's2}}}; 'J[it] >- 's1 IN list{'T} } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; funion{'eq; 's1; 's2}}}; 'J[it] >- 's2 IN list{'T} } -->
   sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; 's1}}; 'J[it] >- 'C[it] } -->
   sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; 's2}}; 'J[it] >- 'C[it] } -->
   sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; funion{'eq; 's1; 's2}}}; 'J['z] >- 'C['z] }

interactive funion_wf2 {| intro [] |} 'H :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's1 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H >- 's2 IN fset{'eq; 'T} } -->
   sequent ['ext] { 'H >- funion{'eq; 's1; 's2} IN fset{'eq; 'T} }

(*
 * Intersection.
 *)
interactive fisect_wf1 {| intro [] |} 'H :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's1 IN list{'T} } -->
   sequent [squash] { 'H >- 's2 IN list{'T} } -->
   sequent ['ext] { 'H >- fisect{'eq; 's1; 's2} IN list{'T} }

interactive fisect_member_intro 'H 'T :
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 'x IN 'T } -->
   sequent [squash] { 'H >- 's1 IN list{'T} } -->
   sequent [squash] { 'H >- 's2 IN list{'T} } -->
   sequent [squash] { 'H >- "assert"{fmember{'eq; 'x; 's1}} } -->
   sequent [squash] { 'H >- "assert"{fmember{'eq; 'x; 's2}} } -->
   sequent ['ext] { 'H >- "assert"{fmember{'eq; 'x; fisect{'eq; 's1; 's2}}} }

interactive fisect_member_elim2 'H 'J 'T :
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; fisect{'eq; 's1; 's2}}}; 'J['z] >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; fisect{'eq; 's1; 's2}}}; 'J['z] >- 'x IN 'T } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; fisect{'eq; 's1; 's2}}}; 'J['z] >- 's1 IN list{'T} } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; fisect{'eq; 's1; 's2}}}; 'J['z] >- 's2 IN list{'T} } -->
   sequent ['ext] { 'H; u: "assert"{fmember{'eq; 'x; 's1}}; v: "assert"{fmember{'eq; 'x; 's2}}; 'J[it] >- 'C[it] } -->
   sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; fisect{'eq; 's1; 's2}}}; 'J['z] >- 'C['z] }

interactive fisect_wf2 {| intro [] |} 'H :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's1 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H >- 's2 IN fset{'eq; 'T} } -->
   sequent ['ext] { 'H >- fisect{'eq; 's1; 's2} IN fset{'eq; 'T} }

(*
 * Subtraction.
 *)
interactive fsub_wf1 {| intro [] |} 'H :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's1 IN list{'T} } -->
   sequent [squash] { 'H >- 's2 IN list{'T} } -->
   sequent ['ext] { 'H >- fsub{'eq; 's1; 's2} IN list{'T} }

interactive fsub_member_intro 'H 'T :
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 'x IN 'T } -->
   sequent [squash] { 'H >- 's1 IN list{'T} } -->
   sequent [squash] { 'H >- 's2 IN list{'T} } -->
   sequent [squash] { 'H >- "assert"{fmember{'eq; 'x; 's1}} } -->
   sequent [squash] { 'H >- "assert"{bnot{fmember{'eq; 'x; 's2}}} } -->
   sequent ['ext] { 'H >- "assert"{fmember{'eq; 'x; fsub{'eq; 's1; 's2}}} }

interactive fsub_member_elim2 'H 'J 'T :
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; fsub{'eq; 's1; 's2}}}; 'J['z] >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; fsub{'eq; 's1; 's2}}}; 'J['z] >- 'x IN 'T } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; fsub{'eq; 's1; 's2}}}; 'J['z] >- 's1 IN list{'T} } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; fsub{'eq; 's1; 's2}}}; 'J['z] >- 's2 IN list{'T} } -->
   sequent ['ext] { 'H; u: "assert"{fmember{'eq; 'x; 's1}}; v: "assert"{bnot{fmember{'eq; 'x; 's2}}}; 'J[it] >- 'C[it] } -->
   sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; fsub{'eq; 's1; 's2}}}; 'J['z] >- 'C['z] }

interactive fsub_wf2 {| intro [] |} 'H :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's1 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H >- 's2 IN fset{'eq; 'T} } -->
   sequent ['ext] { 'H >- fsub{'eq; 's1; 's2} IN fset{'eq; 'T} }

(*
 * Singleton.
 *)
interactive fsingleton_wf1 {| intro [] |} 'H :
   sequent [squash] { 'H >- 'x IN 'T } -->
   sequent ['ext] { 'H >- fsingleton{'x} IN list{'T} }

interactive fsingleton_member_intro {| intro [intro_typeinf <<'x>>] |} 'H 'T :
   [wf] sequent [squash] { 'H >- "type"{'T} } -->
   [wf] sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- "assert"{fcompare{'eq; 'x; 'y}} } -->
   sequent ['ext] { 'H >- "assert"{fmember{'eq; 'x; fsingleton{'y}}} }

interactive fsingleton_member_elim {| elim [elim_typeinf <<'y>>] |} 'H 'J 'T :
   [wf] sequent [squash] { 'H; x: "assert"{fmember{'eq; 'y; fsingleton{'z}}}; 'J['x] >- "type"{'T} } -->
   [wf] sequent [squash] { 'H; x: "assert"{fmember{'eq; 'y; fsingleton{'z}}}; 'J['x] >- fequalp{'eq; 'T} } -->
   [wf] sequent [squash] { 'H; x: "assert"{fmember{'eq; 'y; fsingleton{'z}}}; 'J['x] >- 'y IN 'T } -->
   [wf] sequent [squash] { 'H; x: "assert"{fmember{'eq; 'y; fsingleton{'z}}}; 'J['x] >- 'z IN 'T } -->
   sequent ['ext] { 'H; x: "assert"{fcompare{'eq; 'y; 'z}}; 'J[it] >- 'C[it] } -->
   sequent ['ext] { 'H; x: "assert"{fmember{'eq; 'y; fsingleton{'z}}}; 'J['x] >- 'C['x] }

interactive fsingleton_wf2 {| intro [] |} 'H :
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 'x IN 'T } -->
   sequent ['ext] { 'H >- fsingleton{'x} IN fset{'eq; 'T} }

(*
 * Empty.
 *)
interactive fempty_wf1 {| intro [] |} 'H :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent ['ext] { 'H >- fempty IN list{'T} }

interactive fempty_member_elim {| elim [] |} 'H 'J :
   sequent ['ext] { 'H; x: "assert"{fmember{'eq; 'y; fempty}}; 'J['x] >- 'C['x] }

interactive fempty_wf2 {| intro [] |} 'H :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent ['ext] { 'H >- fempty IN fset{'eq; 'T} }

interactive fequal_assert_elim2 {| elim [elim_typeinf_fset <<'s1>>] |} 'H 'J 'T :
   [wf] sequent [squash] { 'H; x: "assert"{fequal{'eq; 's1; 's2}}; 'J['x] >- "type"{'T} } -->
   [wf] sequent [squash] { 'H; x: "assert"{fequal{'eq; 's1; 's2}}; 'J['x] >- fequalp{'eq; 'T} } -->
   [wf] sequent [squash] { 'H; x: "assert"{fequal{'eq; 's1; 's2}}; 'J['x] >- 's1 IN fset{'eq; 'T} } -->
   [wf] sequent [squash] { 'H; x: "assert"{fequal{'eq; 's1; 's2}}; 'J['x] >- 's2 IN fset{'eq; 'T} } -->
   sequent ['ext] { 'H; x: 's1 = 's2 in fset{'eq; 'T}; 'J[it] >- 'C[it] } -->
   sequent ['ext] { 'H; x: "assert"{fequal{'eq; 's1; 's2}}; 'J['x] >- 'C['x] }

interactive fequal_intro3 {| intro [] |} 'H 'T :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's1 = 's2 in fset{'eq; 'T} } -->
   sequent ['ext] { 'H >- "assert"{fequal{'eq; 's1; 's2}} }

(*
 * Induction principle.
 *)
interactive fsquash_wf1 {| intro [intro_typeinf_fset <<'s>>] |} 'H 'T :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's IN list{'T} } -->
   sequent ['ext] { 'H >- fsquash{'eq; 's} IN list{unit} }

interactive fsub_null 'H 'T :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's IN list{'T} } -->
   sequent [squash] { 'H >- 'u IN 'T } -->
   sequent [squash] { 'H >- "assert"{bnot{fmember{'eq; 'u; 's}}} } -->
   sequent ['ext] { 'H >- 's = fsub{'eq; 's; fsingleton{'u}} in list{'T} }

interactive fsquash_fsub1 'H 'T :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's IN list{'T} } -->
   sequent [squash] { 'H >- 'u IN 'T } -->
   sequent [squash] { 'H >- "assert"{fmember{'eq; 'u; 's}} } -->
   sequent ['ext] { 'H >- fsquash{'eq; 's} = cons{it; fsquash{'eq; fsub{'eq; 's; fsingleton{'u}}}} in list{unit} }

interactive fsquash_wf2 {| intro [] |} 'H 'T :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's IN fset{'eq; 'T} } -->
   sequent ['ext] { 'H >- fsquash{'eq; 's} IN list{unit} }

interactive fset_elim1 {| elim [] |} 'H 'J 'u 'z 'w :
   [wf] sequent [squash] { 'H; x: fset{'eq; 'T}; 'J['x] >- "type"{'T} } -->
   [wf] sequent [squash] { 'H; x: fset{'eq; 'T}; 'J['x] >- fequalp{'eq; 'T} } -->
   sequent ['ext] { 'H; x: fset{'eq; 'T}; 'J['x];
      u: fset{'eq; 'T};
      w: all z: 'T. ("assert"{fmember{'eq; 'z; 'u}} => 'C[fsub{'eq; 'u; fsingleton{'z}}]) >-
      'C['u] } -->
   sequent ['ext] { 'H; x: fset{'eq; 'T}; 'J['x] >- 'C['x] }

(*
 * Quotiented type.
 *)
interactive feset_wf {| intro [] |} 'H :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent ['ext] { 'H >- "type"{feset{'eq; 'T}} }

(*
 * Boolean universal.
 *)
interactive fball_wf1 {| intro [] |} 'H fset{'eq; 'T} 'z :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's IN list{'T} } -->
   sequent [squash] { 'H; z: 'T >- 'b['z] IN bool } -->
   sequent ['ext] { 'H >- fball{'s; x. 'b['x]} IN bool }

interactive fball_assert_intro1 'H fset{'eq; 'T} 'z 'w :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's IN list{'T} } -->
   sequent [squash] { 'H; z: 'T >- 'b['z] IN bool } -->
   sequent [squash] { 'H; z: 'T; w: "assert"{fmember{'eq; 'z; 's}} >- "assert"{'b['z]} } -->
   sequent ['ext] { 'H >- "assert"{fball{'s; x. 'b['x]}} }

interactive fball_assert_elim1 'H 'J fset{'eq; 'T} 'a 'y 'u 'v 'w :
   sequent [squash] { 'H; x: "assert"{fball{'s; x. 'b['x]}}; 'J['x] >- "type"{'T} } -->
   sequent [squash] { 'H; x: "assert"{fball{'s; x. 'b['x]}}; 'J['x] >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H; x: "assert"{fball{'s; x. 'b['x]}}; 'J['x] >- 's IN list{'T} } -->
   sequent [squash] { 'H; x: "assert"{fball{'s; x. 'b['x]}}; 'J['x]; u: 'T; v: 'T; w: "assert"{fcompare{'eq; 'u; 'v}} >- 'b['u] = 'b['v] in bool } -->
   sequent [squash] { 'H; x: "assert"{fball{'s; x. 'b['x]}}; 'J['x] >- 'a IN 'T } -->
   sequent [squash] { 'H; x: "assert"{fball{'s; x. 'b['x]}}; 'J['x] >- "assert"{fmember{'eq; 'a; 's}} } -->
   sequent ['ext] { 'H; x: "assert"{fball{'s; x. 'b['x]}}; 'J['x]; y: "assert"{'b['a]} >- 'C['x] } -->
   sequent ['ext] { 'H; x: "assert"{fball{'s; x. 'b['x]}}; 'J['x] >- 'C['x] }

interactive fball_wf2 {| intro [] |} 'H fset{'eq; 'T} 'u 'v 'w :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's IN fset{'eq; 'T} } -->
   sequent [squash] { 'H; u: 'T; v: 'T; w: "assert"{fcompare{'eq; 'u; 'v}} >- 'b['u] = 'b['v] in bool } -->
   sequent ['ext] { 'H >- fball{'s; x. 'b['x]} IN bool }

interactive fball_assert_intro2 'H fset{'eq; 'T} 'z 'w :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's IN fset{'eq; 'T} } -->
   sequent [squash] { 'H; z: 'T >- 'b['z] IN bool } -->
   sequent [squash] { 'H; z: 'T; w: "assert"{fmember{'eq; 'z; 's}} >- "assert"{'b['z]} } -->
   sequent ['ext] { 'H >- "assert"{fball{'s; x. 'b['x]}} }

interactive fball_assert_elim2 'H 'J fset{'eq; 'T} 'a 'y 'u 'v 'w :
   sequent [squash] { 'H; x: "assert"{fball{'s; x. 'b['x]}}; 'J['x] >- "type"{'T} } -->
   sequent [squash] { 'H; x: "assert"{fball{'s; x. 'b['x]}}; 'J['x] >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H; x: "assert"{fball{'s; x. 'b['x]}}; 'J['x] >- 's IN fset{'eq; 'T} } -->
   sequent [squash] { 'H; x: "assert"{fball{'s; x. 'b['x]}}; 'J['x]; u: 'T; v: 'T; w: "assert"{fcompare{'eq; 'u; 'v}} >- 'b['u] = 'b['v] in bool } -->
   sequent [squash] { 'H; x: "assert"{fball{'s; x. 'b['x]}}; 'J['x] >- 'a IN 'T } -->
   sequent [squash] { 'H; x: "assert"{fball{'s; x. 'b['x]}}; 'J['x] >- "assert"{fmember{'eq; 'a; 's}} } -->
   sequent ['ext] { 'H; x: "assert"{fball{'s; x. 'b['x]}}; 'J['x]; y: "assert"{'b['a]} >- 'C['x] } -->
   sequent ['ext] { 'H; x: "assert"{fball{'s; x. 'b['x]}}; 'J['x] >- 'C['x] }

(*
 * Boolean existential.
 *)
interactive fbexists_wf1 {| intro [] |} 'H fset{'eq; 'T} 'z :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's IN list{'T} } -->
   sequent [squash] { 'H; z: 'T >- 'b['z] IN bool } -->
   sequent ['ext] { 'H >- fbexists{'s; x. 'b['x]} IN bool }

interactive fbexists_assert_intro1 'H fset{'eq; 'T} 'a 'u 'v 'w :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's IN list{'T} } -->
   sequent [squash] { 'H >- 'a IN 'T } -->
   sequent [squash] { 'H; u: 'T; v: 'T; w: "assert"{fcompare{'eq; 'u; 'v}} >- 'b['u] = 'b['v] in bool } -->
   sequent [squash] { 'H >- "assert"{fmember{'eq; 'a; 's}} } -->
   sequent [squash] { 'H >- "assert"{'b['a]} } -->
   sequent ['ext] { 'H >- "assert"{fbexists{'s; x. 'b['x]}} }

interactive fbexists_assert_elim1 'H 'J fset{'eq; 'T} 'u 'v 'w :
   [wf] sequent [squash] { 'H; x: "assert"{fbexists{'s; x. 'b['x]}}; 'J['x] >- "type"{'T} } -->
   [wf] sequent [squash] { 'H; x: "assert"{fbexists{'s; x. 'b['x]}}; 'J['x] >- fequalp{'eq; 'T} } -->
   [wf] sequent [squash] { 'H; x: "assert"{fbexists{'s; x. 'b['x]}}; 'J['x] >- 's IN list{'T} } -->
   [wf] sequent [squash] { 'H; x: "assert"{fbexists{'s; x. 'b['x]}}; 'J['x]; u: 'T >- 'b['u] IN bool } -->
   sequent ['ext] { 'H; u: 'T; v: "assert"{fmember{'eq; 'u; 's}}; w: "assert"{'b['u]}; 'J[it] >- 'C[it] } -->
   sequent ['ext] { 'H; x: "assert"{fbexists{'s; x. 'b['x]}}; 'J['x] >- 'C['x] }

interactive fbexists_wf2 {| intro [] |} 'H fset{'eq; 'T} 'u 'v 'w :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's IN fset{'eq; 'T} } -->
   sequent [squash] { 'H; u: 'T; v: 'T; w: "assert"{fcompare{'eq; 'u; 'v}} >- 'b['u] = 'b['v] in bool } -->
   sequent ['ext] { 'H >- fbexists{'s; x. 'b['x]} IN bool }

interactive fbexists_assert_intro2 'H fset{'eq; 'T} 'a 'u 'v 'w :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's IN fset{'eq; 'T} } -->
   sequent [squash] { 'H >- 'a IN 'T } -->
   sequent [squash] { 'H; u: 'T; v: 'T; w: "assert"{fcompare{'eq; 'u; 'v}} >- 'b['u] = 'b['v] in bool } -->
   sequent [squash] { 'H >- "assert"{fmember{'eq; 'a; 's}} } -->
   sequent [squash] { 'H >- "assert"{'b['a]} } -->
   sequent ['ext] { 'H >- "assert"{fbexists{'s; x. 'b['x]}} }

interactive fbexists_assert_elim3 'H 'J fset{'eq; 'T} 'u 'v 'w :
   sequent [squash] { 'H; x: "assert"{fbexists{'s; x. 'b['x]}}; 'J['x] >- "type"{'T} } -->
   sequent [squash] { 'H; x: "assert"{fbexists{'s; x. 'b['x]}}; 'J['x] >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H; x: "assert"{fbexists{'s; x. 'b['x]}}; 'J['x] >- 's IN fset{'eq; 'T} } -->
   sequent [squash] { 'H; x: "assert"{fbexists{'s; x. 'b['x]}}; 'J['x]; u: 'T; v: 'T; w: "assert"{fcompare{'eq; 'u; 'v}} >- 'b['u] = 'b['v] in bool } -->
   sequent ['ext] { 'H; x: "assert"{bnot{fball{'s; x. bnot{'b['x]}}}}; 'J[it] >- 'C[it] } -->
   sequent ['ext] { 'H; x: "assert"{fbexists{'s; x. 'b['x]}}; 'J['x] >- 'C['x] }

(*
 * Conversion to a list.
 *)
interactive foflist_wf {| intro [] |} 'H :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 'l IN list{'T} } -->
   sequent ['ext] { 'H >- foflist{'l} IN fset{'eq; 'T} }

interactive foflist_member_intro_left {| intro [SelectOption 1; intro_typeinf <<'x>>] |} 'H 'T :
   [wf] sequent [squash] { 'H >- "type"{'T} } -->
   [wf] sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   [wf] sequent [squash] { 'H >- 'x IN 'T } -->
   [wf] sequent [squash] { 'H >- 'y IN 'T } -->
   [wf] sequent [squash] { 'H >- 't IN list{'T} } -->
   sequent [squash] { 'H >- "assert"{fcompare{'eq; 'x; 'y}} } -->
   sequent ['ext] { 'H >- "assert"{fmember{'eq; 'x; foflist{cons{'y; 't}}}} }

interactive foflist_member_intro_right {| intro [SelectOption 2; intro_typeinf <<'x>>] |} 'H 'T :
   [wf] sequent [squash] { 'H >- "type"{'T} } -->
   [wf] sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   [wf] sequent [squash] { 'H >- 'x IN 'T } -->
   [wf] sequent [squash] { 'H >- 'y IN 'T } -->
   [wf] sequent [squash] { 'H >- 't IN list{'T} } -->
   sequent [squash] { 'H >- "assert"{fmember{'eq; 'x; 't}} } -->
   sequent ['ext] { 'H >- "assert"{fmember{'eq; 'x; foflist{cons{'y; 't}}}} }

interactive foflist_member_elim_nil 'H 'J :
   sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; foflist{nil}}}; 'J['z] >- 'C['z] }

interactive foflist_member_elim_cons3 {| elim [elim_typeinf <<'x>>] |} 'H 'J 'T :
   [wf] sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; foflist{cons{'y; 't}}}}; 'J['z] >- "type"{'T} } -->
   [wf] sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; foflist{cons{'y; 't}}}}; 'J['z] >- fequalp{'eq; 'T} } -->
   [wf] sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; foflist{cons{'y; 't}}}}; 'J['z] >- 'x IN 'T } -->
   [wf] sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; foflist{cons{'y; 't}}}}; 'J['z] >- 'y IN 'T } -->
   [wf] sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; foflist{cons{'y; 't}}}}; 'J['z] >- 't IN list{'T} } -->
   sequent ['ext] { 'H; z: "assert"{fcompare{'eq; 'x; 'y}}; 'J[it] >- 'C[it] } -->
   sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; foflist{'t}}}; 'J[it] >- 'C[it] } -->
   sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; foflist{cons{'y; 't}}}}; 'J['z] >- 'C['z] }

(*
 * Union.
 *)
interactive funion_member_intro_left3 'H 'T :
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 'x IN 'T } -->
   sequent [squash] { 'H >- 's1 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H >- 's2 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H >- "assert"{fmember{'eq; 'x; 's1}} } -->
   sequent ['ext] { 'H >- "assert"{fmember{'eq; 'x; funion{'eq; 's1; 's2}}} }

interactive funion_member_intro_right3 'H 'T :
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 'x IN 'T } -->
   sequent [squash] { 'H >- 's1 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H >- 's2 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H >- "assert"{fmember{'eq; 'x; 's2}} } -->
   sequent ['ext] { 'H >- "assert"{fmember{'eq; 'x; funion{'eq; 's1; 's2}}} }

interactive funion_member_elim3 'H 'J 'T :
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; funion{'eq; 's1; 's2}}}; 'J['z] >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; funion{'eq; 's1; 's2}}}; 'J['z] >- 'x IN 'T } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; funion{'eq; 's1; 's2}}}; 'J['z] >- 's1 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; funion{'eq; 's1; 's2}}}; 'J['z] >- 's2 IN fset{'eq; 'T} } -->
   sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; 's1}}; 'J[it] >- 'C[it] } -->
   sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; 's2}}; 'J[it] >- 'C[it] } -->
   sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; funion{'eq; 's1; 's2}}}; 'J['z] >- 'C['z] }

(*
 * Intersection.
 *)
interactive fisect_member_intro3 'H 'T :
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 'x IN 'T } -->
   sequent [squash] { 'H >- 's1 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H >- 's2 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H >- "assert"{fmember{'eq; 'x; 's1}} } -->
   sequent [squash] { 'H >- "assert"{fmember{'eq; 'x; 's2}} } -->
   sequent ['ext] { 'H >- "assert"{fmember{'eq; 'x; fisect{'eq; 's1; 's2}}} }

interactive fisect_member_elim3 'H 'J 'T :
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; fisect{'eq; 's1; 's2}}}; 'J['z] >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; fisect{'eq; 's1; 's2}}}; 'J['z] >- 'x IN 'T } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; fisect{'eq; 's1; 's2}}}; 'J['z] >- 's1 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; fisect{'eq; 's1; 's2}}}; 'J['z] >- 's2 IN fset{'eq; 'T} } -->
   sequent ['ext] { 'H; u: "assert"{fmember{'eq; 'x; 's1}}; v: "assert"{fmember{'eq; 'x; 's2}}; 'J[it] >- 'C[it] } -->
   sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; fisect{'eq; 's1; 's2}}}; 'J['z] >- 'C['z] }

(*
 * Subtraction.
 *)
interactive fsub_member_intro3 'H 'T :
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 'x IN 'T } -->
   sequent [squash] { 'H >- 's1 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H >- 's2 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H >- "assert"{fmember{'eq; 'x; 's1}} } -->
   sequent [squash] { 'H >- "assert"{bnot{fmember{'eq; 'x; 's2}}} } -->
   sequent ['ext] { 'H >- "assert"{fmember{'eq; 'x; fsub{'eq; 's1; 's2}}} }

interactive fsub_member_elim3 'H 'J 'T :
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; fsub{'eq; 's1; 's2}}}; 'J['z] >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; fsub{'eq; 's1; 's2}}}; 'J['z] >- 'x IN 'T } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; fsub{'eq; 's1; 's2}}}; 'J['z] >- 's1 IN fset{'eq; 'T} } -->
   sequent [squash] { 'H; z: "assert"{fmember{'eq; 'x; fsub{'eq; 's1; 's2}}}; 'J['z] >- 's2 IN fset{'eq; 'T} } -->
   sequent ['ext] { 'H; u: "assert"{fmember{'eq; 'x; 's1}}; v: "assert"{bnot{fmember{'eq; 'x; 's2}}}; 'J[it] >- 'C[it] } -->
   sequent ['ext] { 'H; z: "assert"{fmember{'eq; 'x; fsub{'eq; 's1; 's2}}}; 'J['z] >- 'C['z] }

(*
 * Universal quaintifier.
interactive fall_wf2 {| intro [] |} 'H :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's IN fset{'eq; 'T} } -->
   sequent [squash] { 'H; u: feset{'eq; 'T} >- "type"{'b['x]} } -->
   sequent ['ext] { 'H >- "type"{fall{'eq; 'T; 's; x. 'b['x]}} }

interactive fall_intro 'H 'u 'w :
   sequent [squash] { 'H >- "type"{'T} } -->
   sequent [squash] { 'H >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H >- 's IN fset{'eq; 'T} } -->
   sequent ['ext] { 'H; u: feset{'eq; 'T}; w: fmember{'eq; 'u; 's} >- 'b['u] } -->
   sequent ['ext] { 'H >- fall{'eq; 'T; 's; x. 'b['x]} }

interactive fall_elim 'H 'J 'a 'w :
   sequent [squash] { 'H; x: fall{'eq; 'T; 's; y. 'b['y]}; 'J['x] >- "type"{'T} } -->
   sequent [squash] { 'H; x: fall{'eq; 'T; 's; y. 'b['y]}; 'J['x] >- fequalp{'eq; 'T} } -->
   sequent [squash] { 'H; x: fall{'eq; 'T; 's; y. 'b['y]}; 'J['x] >- 's IN fset{'eq; 'T} } -->
   sequent [squash] { 'H; x: fall{'eq; 'T; 's; y. 'b['y]}; 'J['x] >- 'a IN 'T } -->
   sequent [squash] { 'H; x: fall{'eq; 'T; 's; y. 'b['y]}; 'J['x] >- "assert"{fmember{'eq; 'a; 's}} } -->
   sequent ['ext] { 'H; x: fall{'eq; 'T; 's; y. 'b['y]}; 'J['x]; w: 'b['a] >- 'C['x] }
   sequent ['ext] { 'H; x: fall{'eq; 'T; 's; y. 'b['y]}; 'J['x] >- 'C['x] }
 *)

(************************************************************************
 * TACTICS                                                              *
 ************************************************************************)

(*
let get_clause p i =
   if i = 0 then
      Sequent.concl p
   else
      let _, t = Sequent.nth_hyp p i in
         t

(*
 * Infer the 'T type of a term.
 *)
let infer_three_subterms_type p t =
   try get_univ_arg p with
      RefineError _ ->
         let _, s1, s2 = three_subterms t in begin
            try infer_type p s2 with
               RefineError _ ->
                  infer_type p s1
         end

let infer_one_subterm_type p t =
   try get_univ_arg p with
      RefineError _ ->
         let s1 = one_subterm t in
         infer_type p s1

let infer_three_subterms_set_type p t tac1 tac2 =
   let t = infer_three_subterms_type p t in
      if is_list_term t then
         tac1, dest_list t
      else if is_fset_term t then
         let _, t = dest_fset t in
            tac2, t
      else
         raise (RefineError ("Itt_fset.infer_type", StringTermError ("unknown type", t)))

let infer_one_subterm_set_type p t tac1 tac2 =
   let t = infer_one_subterm_type p t in
      if is_list_term t then
         tac1, dest_list t
      else if is_fset_term t then
         let _, t = dest_fset t in
            tac2, t
      else
         raise (RefineError ("Itt_fset.infer_type", StringTermError ("unknown type", t)))

let infer_quant_type p t =
   let t =
      try get_univ_arg p with
         RefineError _ ->
            let _, s, _ = dest_dep0_dep1_any_term t in
            infer_type p s
   in
      if is_list_term t then
         false, mk_fset_term (Sequent.get_term_arg p "eq") (dest_list t)
      else if is_fset_term t then
         true, t
      else
         raise (RefineError ("infer_quant_type", StringTermError ("unknown type", t)))

let d_ball_memberT p =
   let t = Sequent.concl p in
   let _, t = dest_member t in
   let altp, t = infer_quant_type p t in
   let tac =
      if altp then
         let u, v, w = maybe_new_vars3 p "u" "v" "w" in
            fball_wf2 (Sequent.hyp_count_addr p) t u v w
      else
         let z = maybe_new_vars1 p "z" in
            fball_wf1 (Sequent.hyp_count_addr p) t z
   in
      (tac thenT addHiddenLabelT "wf") p

let ball_member_term = << fball{'s; x.'b['x]} IN bool >>

let resource d += (ball_member_term, wrap_intro d_ball_memberT)

let d_bexists_memberT p =
   let t = Sequent.concl p in
   let _, t = dest_member t in
   let altp, t = infer_quant_type p t in
   let tac =
      if altp then
         let u, v, w = maybe_new_vars3 p "u" "v" "w" in
            fbexists_wf2 (Sequent.hyp_count_addr p) t u v w
      else
         let z = maybe_new_vars1 p "z" in
            fbexists_wf1 (Sequent.hyp_count_addr p) t z
   in
      (tac thenT addHiddenLabelT "wf") p

let bexists_member_term = << fbexists{'s; x.'b['x]} IN bool >>

let resource d += (bexists_member_term, wrap_intro d_bexists_memberT)

(*
 * Well-formedness of fsquash.
 *)
let d_fsquash_memberT p =
   let t =
      let concl = Sequent.concl p in
      let _, t = dest_member concl in
      let _, t = two_subterms t in
         try get_univ_arg p with
            RefineError _ ->
               infer_type p t
   in
   let tac, t =
      if is_list_term t then
         fsquash_wf1, dest_list t
      else if is_fset_term t then
         let _, t = dest_fset t in
            fsquash_wf2, t
      else
         raise (RefineError ("d_squash_memberT", StringTermError ("bad type inference", t)))
   in
      (tac (Sequent.hyp_count_addr p) t
       thenT addHiddenLabelT "wf") p

let fsquash_member_term = << fsquash{'eq; 's} IN list{unit} >>

let resource d += (fsquash_member_term, wrap_intro d_fsquash_memberT)

(*
 * Membership tactics for set expressions.
 *)
let member_info =
   [<< funion{'eq; 's1; 's2} IN list{'T} >>, funion_wf1;
    << fisect{'eq; 's1; 's2} IN list{'T} >>, fisect_wf1;
    << fsub{'eq; 's1; 's2} IN list{'T} >>, fsub_wf1;
    << fsingleton{'x} IN list{'T} >>, fsingleton_wf1;
    << fempty IN list{'T} >>, fempty_wf1;
    << funion{'eq; 's1; 's2} IN fset{'eq, 'T} >>, funion_wf2;
    << fisect{'eq; 's1; 's2} IN fset{'eq, 'T} >>, fisect_wf2;
    << fsub{'eq; 's1; 's2} IN fset{'eq, 'T} >>, fsub_wf2;
    << fsingleton{'x} IN fset{'eq, 'T} >>, fsingleton_wf2;
    << fempty IN fset{'eq, 'T} >>, fempty_wf2;
    << foflist{'l} IN fset{'eq, 'T} >>, foflist_wf]

let d_resource =
   let wrap tac i p =
      wrap_intro (tac (Sequent.hyp_count_addr p)) i p
   in
   let rec add_info dr = function
      (t, tac) :: tl ->
         add_info (Mp_resource.improve dr (t, wrap tac)) tl
    | [] ->
         dr
   in
      add_info d_resource member_info

(*
 * More D tactics.
 *)
let d_fequal_assertT i p =
   if i = 0 then
      let t = dest_assert (Sequent.concl p) in
      let tac, t = infer_three_subterms_set_type p t fequal_intro1 fequal_intro2 in
         if get_alt_arg p then
            let u, v = maybe_new_vars2 p "u" "v" in
               (tac (Sequent.hyp_count_addr p) t u v
                thenLT [addHiddenLabelT "wf";
                        addHiddenLabelT "wf";
                        addHiddenLabelT "wf";
                        addHiddenLabelT "wf";
                        addHiddenLabelT "main";
                        addHiddenLabelT "main"]) p
         else
            (fequal_intro3 (Sequent.hyp_count_addr p) t
             thenLT [addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     idT]) p
   else
      let _, t = Sequent.nth_hyp p i in
      let _, t = infer_three_subterms_set_type p (dest_assert t) () () in
      let j, k = Sequent.hyp_indices p i in
         (fequal_assert_elim2 j k t
          thenLT [addHiddenLabelT "wf";
                  addHiddenLabelT "wf";
                  addHiddenLabelT "wf";
                  addHiddenLabelT "wf";
                  addHiddenLabelT "main"]) p

let d_fmember_funion_assertT i p =
   let t = dest_assert (get_clause p i) in
   let simple, t = infer_three_subterms_set_type p t true false in
      if i = 0 then
         let tac =
            if simple then
               if get_sel_arg p = 1 then
                  funion_member_intro_left2
               else
                  funion_member_intro_right2
            else
               if get_sel_arg p = 1 then
                  funion_member_intro_left3
               else
                  funion_member_intro_right3
         in
            (tac (Sequent.hyp_count_addr p) t
             thenLT [addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "main"]) p
      else
         let j, k = Sequent.hyp_indices p i in
         let tac =
            if simple then
               funion_member_elim2
            else
               funion_member_elim3
         in
            (tac j k t
             thenLT [addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "main";
                     addHiddenLabelT "main"]) p

let d_fmember_fisect_assertT i p =
   let t = dest_assert (get_clause p i) in
   let simple, t = infer_three_subterms_set_type p t true false in
      if i = 0 then
         let tac =
            if simple then
               fisect_member_intro
            else
               fisect_member_intro3
         in
            (tac (Sequent.hyp_count_addr p) t
             thenLT [addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "main";
                     addHiddenLabelT "main"]) p
      else
         let j, k = Sequent.hyp_indices p i in
         let tac =
            if simple then
               fisect_member_elim2
            else
               fisect_member_elim3
         in
            (tac j k t
             thenLT [addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "main"]) p

let d_fmember_fsub_assertT i p =
   let t = dest_assert (get_clause p i) in
   let simple, t = infer_three_subterms_set_type p t true false in
      if i = 0 then
         let tac =
            if simple then
               fsub_member_intro
            else
               fsub_member_intro3
         in
            (tac (Sequent.hyp_count_addr p) t
             thenLT [addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "main";
                     addHiddenLabelT "main"]) p
      else
         let j, k = Sequent.hyp_indices p i in
         let tac =
            if simple then
               fsub_member_elim2
            else
               fsub_member_elim3
         in
            (tac j k t
             thenLT [addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "main"]) p

let d_fball_assertT i p =
   let t = dest_assert (get_clause p i) in
   let altp, t = infer_quant_type p t in
      if i = 0 then
         let z, w = maybe_new_vars2 p "u" "v" in
         let tac =
            if altp then
               fball_assert_intro2
            else
               fball_assert_intro1
         in
            (tac (Sequent.hyp_count_addr p) t z w
             thenLT [addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "main"]) p
      else
         let j, k = Sequent.hyp_indices p i in
         let a = get_with_arg p in
         let y, u, v, w = maybe_new_vars4 p "y" "u" "v" "w" in
         let tac =
            if altp then
               fball_assert_elim2
            else
               fball_assert_elim1
         in
            (fball_assert_elim1 j k t a y u v w
             thenLT [addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "main"]) p

let d_fbexists_assertT i p =
   let t = dest_assert (get_clause p i) in
   let altp, t = infer_quant_type p t in
   let u, v, w = maybe_new_vars3 p "u" "v" "w" in
      if i = 0 then
         let a = get_with_arg p in
         let tac =
            if altp then
               fbexists_assert_intro1
            else
               fbexists_assert_intro1
         in
            (tac (Sequent.hyp_count_addr p) t a u v w
             thenLT [addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "main"]) p
      else
         let j, k = Sequent.hyp_indices p i in
         let tac =
            if altp then
               fbexists_assert_elim1
            else
               fbexists_assert_elim1
         in
            (fbexists_assert_elim1 j k t u v w
             thenLT [addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "wf";
                     addHiddenLabelT "main"]) p
*)

(*
 * Other tactics.
 *)
let fmember_subst_elementT x p =
   let t =
      try get_univ_arg p with
         RefineError _ ->
            let t = Sequent.concl p in
            let t = dest_assert t in
            let _, x, _ = dest_fmember t in
            infer_type p x
   in
      fmember_fun (Sequent.hyp_count_addr p) t x p

(*
let fsub_nonmemberT p =
   let t =
      try get_univ_arg p with
         RefineError _ ->
            let t = Sequent.concl p in
            let _, s, _ = dest_equal t in
            let t = infer_type p s in
               if is_list_term t then
                  dest_list t
               else
                  raise (RefineError ("fsub_nonmemberT", StringTermError ("type must be a list", t)))
   in
      (fsub_null (Sequent.hyp_count_addr p) t
       thenLT [addHiddenLabelT "wf";
               addHiddenLabelT "wf";
               addHiddenLabelT "wf";
               addHiddenLabelT "wf";
               addHiddenLabelT "main"]) p

let fsquash_memberT p =
   let t =
      try get_univ_arg p with
         RefineError _ ->
            let t = Sequent.concl p in
            let _, s, _ = dest_equal t in
            let _, s = two_subterms s in
            let t = infer_type p s in
               if is_list_term t then
                  dest_list t
               else
                  raise (RefineError ("fsub_nonmemberT", StringTermError ("type must be a list", t)))
   in
      (fsquash_fsub1 (Sequent.hyp_count_addr p) t
       thenLT [addHiddenLabelT "wf";
               addHiddenLabelT "wf";
               addHiddenLabelT "wf";
               addHiddenLabelT "wf";
               addHiddenLabelT "main"]) p

*)

let assert_2of3_type p t =
   try get_with_arg p with
      RefineError _ ->
         let t = dest_assert t in
         let _, x, y = three_subterms t in begin
            try infer_type p x with
               RefineError _ ->
                  infer_type p y
         end

let fcompareSymT p =
   fcompare_sym (Sequent.hyp_count_addr p) (assert_2of3_type p (Sequent.concl p)) p

let fcompareTransT z p =
   fcompare_trans (Sequent.hyp_count_addr p) (assert_2of3_type p (Sequent.concl p)) z p

let assert_2of3_fset_type p t =
   dest_fset_type (assert_2of3_type p t)

let fsubseteqTransT t p =
   fsubseteq_trans (Sequent.hyp_count_addr p) (assert_2of3_fset_type p (Sequent.concl p)) t p

(*
 * -*-
 * Local Variables:
 * Caml-master: "mp.run"
 * End:
 * -*-
 *)
