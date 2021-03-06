doc <:doc<
   @module[Itt_reflection]


   @docoff
   ----------------------------------------------------------------

   @begin[license]
   This file is part of MetaPRL, a modular, higher order
   logical framework that provides a logical programming
   environment for OCaml and other languages.

   See the file doc/htmlman/default.html or visit http://metaprl.org/
   for more information.

   Copyright (C) 2004 MetaPRL Group

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

   Author: Xin Yu @email{xiny@cs.caltech.edu}
   @end[license]
>>

doc <:doc<
   @parents
>>
extends Itt_theory
extends Base_reflection
extends Itt_nat
doc docoff

open Dtactic

open Base_reflection
open Basic_tactics
open Itt_nat
open Itt_equal
open Itt_struct
open Itt_squash

(************************************************************************
 * The BTerm type                                                       *
 ************************************************************************)

define unfold_is_bterm: is_bterm{'bt} <--> Base_reflection!if_bterm{'bt;"true"}

dform isbterm_df : except_mode[src] :: is_bterm{'bt} =
   `"is_bterm(" slot{'bt} `")"

dform ifbterm_df : except_mode[src] :: if_bterm{'bt; 'P} =
   `"ifbterm(" slot{'bt} `";" slot{'P} `")"

let resource reduce +=
   (<<is_bterm{ bterm{| <H> >- 't |} }>>, wrap_reduce (unfold_is_bterm thenC reduce_ifbterm))

prim_rw ifbterm_reduce {| reduce |} :
   ( is_bterm{'b} ) -->
   if_bterm{'b; 'P} <--> 'P

interactive ifbterm_type {| intro [] |} :
   sequent { <H> >- 'P Type} -->
   sequent { <H> >- is_bterm{'b} } -->
   sequent { <H> >- if_bterm{'b; 'P} Type }

interactive ifbterm_intro {| intro [] |} :
   sequent { <H> >- is_bterm{'b} } -->
   sequent { <H> >- 'P } -->
   sequent { <H> >- if_bterm{'b; 'P} }


declare BTerm

dform bterm_df : except_mode[src] :: BTerm =
   `"BTerm"

prim btermEquality {| intro [] |} :
   sequent { <H> >- BTerm in univ[i:l] } =
   it

interactive btermType {| intro [] |} :
   sequent { <H> >- BTerm Type }

prim bterm_memberEquality {| intro [AutoMustComplete]; nth_hyp |} :
   sequent { <H> >- is_bterm{'x<||>} } -->
   sequent { <H> >- 'x<||> in BTerm } =
   it

(* ???
interactive bterm_memberEquality2 {| intro [AutoMustComplete] |} :
   sequent { <H> >- is_bterm{'x<||>} } -->
   sequent { <H> >- is_bterm{'y<||>} } -->
   sequent { <H> >- ? } -->
   sequent { <H> >- 'x<||> = 'y<||> in BTerm }
*)

prim btermSquiggle {| nth_hyp |} :
   sequent { <H> >- 'b1 = 'b2 in BTerm } -->
   sequent { <H> >- 'b1 ~ 'b2 } =
   it

interactive btermlistSquiggle {| nth_hyp |} :
   sequent { <H> >- 'b1 = 'b2 in list{BTerm} } -->
   sequent { <H> >- 'b1 ~ 'b2 }

(************************************************************************
 * The Simplest bterm                                                   *
 ************************************************************************)

define unfold_itbterm : itbterm <--> bterm{| >- it[@] |}

dform itbterm_df : except_mode[src] :: itbterm =
   `"itbterm"

let fold_itbterm = makeFoldC << itbterm >> unfold_itbterm

interactive itbterm_is_bterm {| intro [] |} :
   sequent { <H> >- itbterm in BTerm }

interactive btermFormation {| intro [] |} :
   sequent { <H> >- BTerm }

(************************************************************************
 * Var_bterm                                                            *
 ************************************************************************)

define unfold_is_var_bterm: is_var_bterm{'bt} <-->  Base_reflection!if_var_bterm{'bt; btrue; bfalse}
define unfold_var_bterm: var_bterm{'bt} <--> "assert"{is_var_bterm{'bt}}

dform is_var_bterm_df : except_mode[src] :: is_var_bterm{'bt} =
   `"is_var_bterm(" slot{'bt} `")"
dform var_bterm_df : except_mode[src] :: var_bterm{'bt} =
   `"var_bterm(" slot{'bt} `")"

let fold_var_bterm = makeFoldC << var_bterm{'bt} >> unfold_var_bterm

let is_var_bterm_reduce = unfold_is_var_bterm thenC Base_reflection.reduce_if_var_bterm
let var_bterm_reduce = unfold_var_bterm thenC addrC [Subterm 1] is_var_bterm_reduce
let resource reduce +=
   [ << is_var_bterm{ bterm{| <H1> >- 't1 |} } >>, wrap_reduce is_var_bterm_reduce;
     << var_bterm{ bterm{| <H1> >- 't1 |} } >>, wrap_reduce var_bterm_reduce ]

prim is_var_bterm_wf {| intro [] |} :
   sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- is_var_bterm{'bt} in bool } =
   it

interactive_rw varbterm_is_varbterm :
   (var_bterm{ 'bt}) -->
   is_var_bterm{'bt} <--> btrue

interactive_rw notvarbterm_is_not_varbterm :
   ('bt in BTerm ) -->
   (not{var_bterm{ 'bt}} ) -->
   is_var_bterm{'bt} <--> bfalse

interactive var_bterm_wf {| intro [] |} :
   sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- var_bterm{'bt} Type }

interactive var_bterm_univ {| intro [] |} :
   [wf] sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- var_bterm{'bt} in univ[i:l] }

interactive var_bterm_decidable {| intro [] |} :
   [wf] sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- decidable{var_bterm{'bt}} }

interactive itbterm_is_not_varbterm {| intro [] |} :
   sequent { <H> >- not{ var_bterm{ itbterm } } }

(************************************************************************
 * Var                                                                  *
 ************************************************************************)

define unfold_var: Var <--> { bt:BTerm | var_bterm{'bt} }

dform var_df : except_mode[src] :: Var =
   `"Var"

interactive var_univ {| intro [] |} :
   sequent { <H> >- Var in univ[i:l] }

interactive var_wf {| intro [] |} :
   sequent { <H> >- Var Type }

interactive var_subtype {| intro [] |} :
   sequent { <H> >- Var subtype BTerm }

interactive var_intro {| intro [] |} :
   sequent { <H> >- 'b1 = 'b2 in BTerm } -->
   sequent { <H> >- var_bterm{'b1} } -->
   sequent { <H> >- 'b1 = 'b2 in Var }

interactive var_elim {| elim [] |} 'H :
   sequent { <H>; u: BTerm; v: var_bterm{'u}; <J['u]> >- 'T['u] } -->
   sequent { <H>; u: Var; <J['u]> >- 'T['u] }

interactive_rw var_is_var:
   ('v in Var) -->
   is_var_bterm{'v} <--> btrue

(************************************************************************
 * OpBTerm                                                              *
 ************************************************************************)

define unfold_opbterm:
   OpBTerm <--> { bt: BTerm |  not{ var_bterm{'bt} } }

dform opbterm_df : except_mode[src] :: OpBTerm =
   `"OpBTerm"

interactive opbterm_univ {| intro [] |} :
   sequent { <H> >- OpBTerm in univ[i:l] }

interactive opbterm_wf {| intro [] |} :
   sequent { <H> >- OpBTerm Type }

interactive opbterm_subtype {| intro [] |} :
   sequent { <H> >- OpBTerm subtype BTerm }

interactive opbterm_intro {| intro [] |} :
   sequent { <H> >- 'b1 = 'b2 in BTerm } -->
   sequent { <H>; var_bterm{'b1} >- "false" } -->
   sequent { <H> >- 'b1 = 'b2 in OpBTerm }

interactive opbterm_elim {| elim [] |} 'H :
   sequent { <H>; u: BTerm; v: not{ var_bterm{'u} }; <J['u]> >- 'T['u] } -->
   sequent { <H>; u: OpBTerm; <J['u]> >- 'T['u] }

interactive_rw opbterm_is_not_var:
   ('v in OpBTerm) -->
   is_var_bterm{'v} <--> bfalse

interactive itbterm_is_opbterm {| intro [] |} :
   sequent { <H> >- itbterm in OpBTerm }

interactive var_or_opbterm_concl bind{x. 'C['x]} 'b :
   [wf] sequent { <H> >- 'b in BTerm } -->
   [main] sequent { <H>; b: Var >- 'C['b] } -->
   [main] sequent { <H>; b: OpBTerm >- 'C['b] } -->
   sequent { <H> >- 'C['b] }

interactive var_or_opbterm_hyp 'H bind{x. 'A['x]} 'b :
   [wf] sequent { <H>; x: 'A['b]; <J['x]> >- 'b in BTerm } -->
   [main] sequent { <H>; x: 'A['b]; <J['x]>; 'b in Var >- 'C['x] } -->
   [main] sequent { <H>; x: 'A['b]; <J['x]>; 'b in OpBTerm >- 'C['x] } -->
   sequent { <H>; x: 'A['b]; <J['x]> >- 'C['x] }

(************************************************************************
 * Subterms                                                             *
 ************************************************************************)

declare list_of_rlist{'l}

prim_rw reduce_rlist_cons :
   list_of_rlist{rcons{'hd; 'tl}} <--> ('hd :: list_of_rlist{'tl})

prim_rw reduce_rlist_nil :
   list_of_rlist{rnil} <--> nil

let rec reduce_rlist t =
   if is_rnil_term (one_subterm t) then
      reduce_rlist_nil
   else
      reduce_rlist_cons thenC addrC [Subterm 2] (termC reduce_rlist)

define unfold_subterms:
   subterms{'t} <--> list_of_rlist{ (Base_reflection!subterms{'t}) }

dform list_of_rlist_df : except_mode[src] :: list_of_rlist{'l} =
   `"list_of_rlist(" slot{'l} `")"

dform subterms_df : except_mode[src] :: subterms{'bt} =
   `"subterms(" slot{'bt} `")"

let reduce_subterms =
   unfold_subterms thenC addrC [Subterm 1] Base_reflection.reduce_subterms thenC termC reduce_rlist

let resource reduce +=
   ( << subterms{ bterm{| <H> >- 't |} } >>, wrap_reduce reduce_subterms )

prim subterms_wf {| intro [] |} :
   sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- subterms{'bt} in list{BTerm} } =
   it

prim subterms_var :
   sequent { <H> >- 'bt in Var } -->
   sequent { <H> >- subterms{'bt} = nil in list{BTerm} } =
   it

interactive subterms_expl1 {| intro [] |} :
   sequent { <H> >- subterms{bterm{| x: term >- it[@] |}} ~ nil }

interactive bterm_expl0 {| intro [] |} :
   sequent { <H> >- bterm{| x: term >- it[@] |} in BTerm }

(*???
interactive bterm_expl1 {| intro [] |} :
   sequent { <H> >- bterm{| x: term >- it[@] |} ~ itbterm }
*)

(************************************************************************
 * TYPE INFERENCE                                                       *
 ************************************************************************)

(*
 * Type of bterm and subterms of bterms.
 *)
let resource typeinf += (<< BTerm >>, infer_univ1)
let resource typeinf += (<< subterms{'bt} >>, infer_const << list{BTerm} >>)


(************************************************************************
 * Same_op                                                              *
 ************************************************************************)

define unfold_is_same_op: is_same_op{'b1; 'b2} <--> if_same_op{'b1; 'b2; btrue; bfalse}

define unfold_same_op: same_op{'b1; 'b2} <--> "assert"{is_same_op{'b1; 'b2}}

dform is_sameop_df : except_mode[src] :: is_same_op{'b1; 'b2} =
   `"is_same_op(" slot{'b1} `"; " slot{'b2} `")"
dform sameop_df : except_mode[src] :: same_op{'b1; 'b2} =
   `"same_op(" slot{'b1} `"; " slot{'b2} `")"

let is_same_op_reduce = unfold_is_same_op thenC Base_reflection.reduce_if_same_op
let same_op_reduce = unfold_same_op thenC addrC [Subterm 1] is_same_op_reduce
let resource reduce +=
   [ << is_same_op{ bterm{| <H1> >- 't1 |}; bterm{| <H2> >- 't2 |} } >>, wrap_reduce is_same_op_reduce;
     << same_op{ bterm{| <H1> >- 't1 |}; bterm{| <H2> >- 't2 |} } >>, wrap_reduce same_op_reduce ]

prim is_same_op_wf {| intro [] |} :
   sequent { <H> >- 'b1 in OpBTerm } -->
   sequent { <H> >- 'b2 in OpBTerm } -->
   sequent { <H> >- is_same_op{'b1; 'b2} in bool } =
   it

interactive_rw sameop_is_sameop :
   (same_op{'b1; 'b2}) -->
   is_same_op{'b1; 'b2} <--> btrue

interactive_rw notsameop_is_not_sameop :
   ('b1 in OpBTerm ) -->
   ('b2 in OpBTerm ) -->
   (not{same_op{'b1; 'b2}} ) -->
   is_same_op{'b1; 'b2} <--> bfalse

interactive same_op_wf {| intro [] |} :
   sequent { <H> >- 'b1 in OpBTerm } -->
   sequent { <H> >- 'b2 in OpBTerm } -->
   sequent { <H> >- same_op{'b1; 'b2} Type }

interactive same_op_decidable {| intro [] |} :
   [wf] sequent { <H> >- 'b1 in OpBTerm } -->
   [wf] sequent { <H> >- 'b2 in OpBTerm } -->
   sequent { <H> >- decidable{same_op{'b1; 'b2}} }

prim is_same_op_id {| intro [] |} :
   sequent { <H> >- 'b in OpBTerm } -->
   sequent { <H> >- is_same_op{'b; 'b} = btrue in bool} =
   it

interactive same_op_id {| intro [] |} :
   sequent { <H> >- 'b in OpBTerm } -->
   sequent { <H> >- same_op{'b; 'b} }

interactive same_op_id2 {| intro [AutoMustComplete]; nth_hyp |} :
   sequent { <H> >- 'b1 = 'b2 in OpBTerm } -->
   sequent { <H> >- same_op{'b1; 'b2} }

prim same_op_sym :
   sequent { <H> >- 'b1 in OpBTerm } -->
   sequent { <H> >- 'b2 in OpBTerm } -->
   sequent { <H> >- same_op{'b1; 'b2} } -->
   sequent { <H> >- same_op{'b2; 'b1} } =
   it

prim same_op_trans 'b2:
   sequent { <H> >- 'b1 in OpBTerm } -->
   sequent { <H> >- 'b2 in OpBTerm } -->
   sequent { <H> >- 'b3 in OpBTerm } -->
   sequent { <H> >- same_op{'b1; 'b2} } -->
   sequent { <H> >- same_op{'b2; 'b3} } -->
   sequent { <H> >- same_op{'b1; 'b3} } =
   it

let sameOpSymT = same_op_sym
let sameOpTransT = same_op_trans

(************************************************************************
 * Simple_bterm                                                         *
 ************************************************************************)

define unfold_is_simple_bterm: is_simple_bterm{'bt} <--> if_simple_bterm{'bt; btrue; bfalse}
define unfold_simple_bterm: simple_bterm{'bt} <--> "assert"{is_simple_bterm{'bt}}

dform is_simple_bterm_df : except_mode[src] :: is_simple_bterm{'bt} =
   `"is_simple_bterm(" slot{'bt} `")"
dform simple_bterm_df : except_mode[src] :: simple_bterm{'bt} =
   `"simple_bterm(" slot{'bt} `")"

let is_simple_reduce = unfold_is_simple_bterm thenC Base_reflection.reduce_if_simple_bterm
let simple_reduce = unfold_simple_bterm thenC addrC [Subterm 1] is_simple_reduce

let resource reduce +=
   [ << is_simple_bterm{ bterm{| <H1> >- 't1 |} } >>, wrap_reduce is_simple_reduce;
     << simple_bterm{ bterm{| <H1> >- 't1 |} } >>, wrap_reduce simple_reduce ]


prim is_simple_bterm_bool {| intro [] |} :
   [wf] sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- is_simple_bterm{'bt} in bool } =
   it

interactive_rw simple_is_simple :
   (simple_bterm{ 'bt}) -->
   is_simple_bterm{'bt} <--> btrue

interactive_rw notsimple_is_not_simple :
   ('bt in BTerm ) -->
   (not{simple_bterm{ 'bt}} ) -->
   is_simple_bterm{'bt} <--> bfalse

interactive simple_bterm_univ {| intro [] |} :
   [wf] sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- simple_bterm{'bt} in univ[i:l] }

interactive simple_bterm_type {| intro [] |} :
   [wf] sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- simple_bterm{'bt} Type }

interactive simple_bterm_decidable {| intro [] |} :
   [wf] sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- decidable{simple_bterm{'bt}} }

interactive itbterm_is_simplebterm {| intro [] |} :
   sequent { <H> >- simple_bterm{ itbterm } }

interactive simple_bterm_expl1 {| intro [] |} :
   sequent { <H> >- not{simple_bterm{bterm{| x: term >- it[@] |}}} }

interactive same_op_expl1 {| intro [] |} :
   sequent { <H> >- same_op{bterm{| x: term >- it[@] |}; itbterm} }

(************************************************************************
 * The Term type.                                                       *
 ************************************************************************)

define unfold_term: Term <--> { b: BTerm | simple_bterm{'b} }

dform term_df : except_mode[src] :: Term =
   `"Term"

interactive termEquality {| intro [] |} :
   sequent { <H> >- Term in univ[i:l] }

interactive termType {| intro [] |} :
   sequent { <H> >- Term Type }

interactive term_subtype {| intro [] |} :
   sequent { <H> >- Term subtype BTerm }

interactive term_memberEquality {| intro [] |} :
   sequent { <H> >- 'x = 'y in BTerm } -->
   sequent { <H> >- simple_bterm{'x} } -->
   sequent { <H> >- 'x = 'y in Term }

interactive termElimination {| elim [] |} 'H :
   sequent { <H>; b: BTerm; u: simple_bterm{'b}; <J['b]> >- 'C['b] } -->
   sequent { <H>; b: Term; <J['b]> >- 'C['b] }

interactive_rw term_is_simple:
   ('v in Term) -->
   is_simple_bterm{'v} <--> btrue

interactive itbterm_in_term {| intro [] |} :
   sequent { <H> >- itbterm in Term }

(************************************************************************
 * Bound BTerms                                                         *
 ************************************************************************)

define unfold_bbterm: BBTerm <--> { bt: BTerm |  not{ simple_bterm{'bt} } }

dform bbterm_df : except_mode[src] :: BBTerm =
   `"BBTerm"

interactive bbterm_univ {| intro [] |} :
   sequent { <H> >- BBTerm in univ[i:l] }

interactive bbterm_wf {| intro [] |} :
   sequent { <H> >- BBTerm Type }

interactive bbterm_subtype {| intro [] |} :
   sequent { <H> >- BBTerm subtype BTerm }

interactive bbterm_intro {| intro [] |} :
   sequent { <H> >- 'b1 = 'b2 in BTerm } -->
   sequent { <H>; simple_bterm{'b1} >- "false" } -->
   sequent { <H> >- 'b1 = 'b2 in BBTerm }

interactive bbterm_elim {| elim [] |} 'H :
   sequent { <H>; u: BTerm; v: not{ simple_bterm{'u} }; <J['u]> >- 'T['u] } -->
   sequent { <H>; u: BBTerm; <J['u]> >- 'T['u] }

interactive_rw bbterm_is_not_simple:
   ('v in BBTerm) -->
   is_simple_bterm{'v} <--> bfalse

interactive term_or_bbterm_concl bind{x. 'C['x]} 'b :
   [wf] sequent { <H> >- 'b in BTerm } -->
   [main] sequent { <H>; b: Term >- 'C['b] } -->
   [main] sequent { <H>; b: BBTerm >- 'C['b] } -->
   sequent { <H> >- 'C['b] }

interactive term_or_bbterm_hyp 'H bind{x. 'A['x]} 'b :
   [wf] sequent { <H>; x: 'A['b]; <J['x]> >- 'b in BTerm } -->
   [main] sequent { <H>; x: 'A['b]; <J['x]>; 'b in Term >- 'C['x] } -->
   [main] sequent { <H>; x: 'A['b]; <J['x]>; 'b in BBTerm >- 'C['x] } -->
   sequent { <H>; x: 'A['b]; <J['x]> >- 'C['x] }

(************************************************************************
 * Subst                                                                *
 ************************************************************************)

define unfold_subst: subst{'bt; 't} <--> Base_reflection!subst{'bt; 't}

dform subst_df : except_mode[src] :: subst{'bt; 't} =
   `"subst(" slot{'bt} `"; " slot{'t} `")"

let resource reduce +=
   (<< subst{ bterm{| <H1> >- 't1 |}; bterm{| >- 't2 |} } >>, wrap_reduce (unfold_subst thenC Base_reflection.reduce_subst))

prim subst_wf1 {| intro [AutoMustComplete] |} :
   sequent { <H> >- 'bt1 = 'bt2 in BBTerm } -->
   sequent { <H> >- 't1 ='t2 in Term } -->
   sequent { <H> >- subst{'bt1; 't1} = subst{'bt2; 't2} in BTerm } =
   it

prim subst_wf2 {| intro [] |} :
   sequent { <H> >- 'bt1 = 'bt2 in BBTerm } -->
   sequent { <H> >- 'bt1 in OpBTerm } -->
   sequent { <H> >- 't1 ='t2 in Term } -->
   sequent { <H> >- subst{'bt1; 't1} = subst{'bt2; 't2} in OpBTerm } =
   it

prim_rw subst_nilsubterms :
   'bt in BBTerm -->
   't in Term -->
   'bt in OpBTerm -->
   subterms{'bt} = nil in list{BTerm} -->
   subst{'bt; 't} <--> 'bt

(************************************************************************
 * Var_arity                                                            *
 ************************************************************************)

define unfold_var_arity: var_arity{'t} <-->
   fix{ f. lambda{ b.
             if is_simple_bterm{'b}
               then 0
               else 1 +@ ('f subst{'b; itbterm})
        } } 't

dform var_arity_df : except_mode[src] :: var_arity{'t} =
   `"var_arity(" slot{'t} `")"

let fold_var_arity = makeFoldC << var_arity{'t} >> unfold_var_arity

interactive_rw var_arity_not_simple :
   ( 'b in BBTerm ) -->
   var_arity{'b} <--> 1 +@ var_arity{subst{'b; itbterm}}

interactive_rw var_arity_simple :
  (simple_bterm{'b}) -->
   var_arity{'b} <--> 0

(* XXX: TODO: We need to decide if we want bterm{| >- ... |} to be a no-op instead *)
interactive_rw var_arity_reduce_simple :
   var_arity{bterm{| >- 'b |}} <--> 0

interactive_rw var_arity_reduce_not_simple {| reduce |}:
   var_arity{bterm{| x:term; <H> >- 'b['x] |}} <-->
       1 +@ var_arity{ bterm{| <H> >- 'b[ it[@] ] |} }

prim var_arity_wf {| intro [] |} :
   sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- var_arity{'bt} in nat } =
   it

prim var_arity_subst {| intro [] |} :
   sequent { <H> >- 'b in BBTerm } -->
   sequent { <H> >- 'a1 in Term } -->
   sequent { <H> >- 'a2 in Term } -->
   sequent { <H> >- var_arity{subst{'b; 'a1}} ~ var_arity{subst{'b; 'a2}} } =
   it

interactive var_arity_wf2 {| intro [] |} :
   sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- var_arity{'bt} in int }

interactive var_arity_subst1 {| intro [] |} :
   sequent { <H> >- 'b in BBTerm } -->
   sequent { <H> >- 'a in Term } -->
   sequent { <H> >- var_arity{'b} = 1 +@ var_arity{subst{'b; 'a}} in nat }

interactive_rw var_arity_subst_rw {| reduce |} :
   'b in BBTerm  -->
   'a in Term  -->
    var_arity{subst{'b; 'a}} <-->  var_arity{'b} -@ 1

interactive var_arity_subst2 {| intro [] |} :
   sequent { <H> >- 'b in BBTerm } -->
   sequent { <H> >- 'a in Term } -->
   sequent { <H> >- var_arity{subst{'b; 'a}} < var_arity{'b} }

interactive var_arity_bbterm :
   sequent { <H> >- 'b in BTerm } -->
   sequent { <H> >- var_arity{'b} > 0 } -->
   sequent { <H> >- 'b in BBTerm }

interactive var_arity_bbterm2 :
   sequent { <H> >- 'b in BBTerm } -->
   sequent { <H> >- var_arity{'b} > 0 }

(************************************************************************
 * Subterms_arity                                                       *
 ************************************************************************)

define unfold_subterms_arity: subterms_arity{'bt} <--> length{subterms{'bt}}

dform subterms_arity_df : except_mode[src] :: subterms_arity{'bt} =
   `"subterms_arity(" slot{'bt} `")"

let fold_subterms_arity = makeFoldC << subterms_arity{'bt} >> unfold_subterms_arity

interactive subterms_arity_wf {| intro [] |} :
   sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- subterms_arity{'bt} in nat }

interactive subterms_arity_wf1 {| intro [] |} :
   sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- subterms_arity{'bt} in int }

interactive subterms_lengthzero {| elim [] |} 'H :
   sequent { <H>; x: subterms_arity{'bt} = 0 in int; <J[it]> >- 'bt in BTerm } -->
   sequent { <H>; x: subterms_arity{'bt} = 0 in int; <J[it]>; y: subterms{'bt} = nil in list{BTerm} >- 'C[it] } -->
   sequent { <H>; x: subterms_arity{'bt} = 0 in int; <J['x]> >- 'C['x] }

(************************************************************************
 * Depth                                                                *
 ************************************************************************)

define unfold_depth: depth{'t} <-->
   fix{ f. lambda{ b.
             if beq_int{subterms_arity{'b}; 0}
               then 0
               else (1 +@ list_max{ map{lambda{x. 'f 'x}; subterms{'b}} })
        } } 't

(*
  interactive_rw unroll_depth:
   depth{'t} <--> 1 +@ list_max{ map{lambda{x.depth{'x}}; subterms{'t}}}
*)
interactive_rw depth_not_zero :
   't in BTerm -->
   subterms_arity{'t} <> 0 -->
   depth{'t} <--> 1 +@ list_max{ map{lambda{x.depth{'x}}; subterms{'t}}}

interactive_rw depth_0 :
   subterms_arity{'t} = 0 in int -->
   depth{'t} <--> 0

dform depth_df : except_mode[src] :: depth{'t} =
   `"depth(" slot{'t} `")"

let fold_depth = makeFoldC << depth{'t} >> unfold_depth

prim depth_wf {| intro [] |} :
   sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- depth{'bt} in nat } =
   it

interactive depth_wf2 {| intro [] |} :
   sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- depth{'bt} in int }

interactive depth_subterms {| intro [] |} :
   sequent { <H> >- 'a in BTerm } -->
   sequent { <H> >- 'b in BTerm } -->
   sequent { <H> >- subterms_arity{'b} <> 0 } -->
   sequent { <H> >- mem{'a; subterms{'b}; BTerm} } -->
   sequent { <H> >- depth {'a} < depth {'b} }

(************************************************************************
 * Make_bterm                                                           *
 ************************************************************************)

declare rlist_of_list{'l}

prim_rw rlist_list_cons {| reduce |} :
   rlist_of_list{ 'hd :: 'tl } <--> rcons{'hd; rlist_of_list{'tl}}

prim_rw rlist_list_nil {| reduce |} :
   rlist_of_list{ nil } <--> rnil

define unfold_make_bterm : make_bterm{'bt; 'bt_list} <--> Base_reflection!make_bterm{'bt; rlist_of_list{'bt_list}}

dform make_bterm_df : except_mode[src] :: make_bterm{'bt; 'btl} =
   `"make_bterm(" slot{'bt} `"; " slot{'btl} `")"

let resource reduce +=
   ( << make_bterm{ bterm{| <H> >- 't |}; 'btl } >>, wrap_reduce (unfold_make_bterm thenC reduceC) )

interactive make_bterm_itbterm {| intro [] |} :
   sequent { <H> >- make_bterm{itbterm; nil} = itbterm in BTerm }

interactive make_bterm_var_expl {| intro [] |} :
   sequent { <H> >- make_bterm{bterm{| x: term >- 'x |}; nil} = bterm{| x: term >- 'x |} in BTerm }


define unfold_are_compatible_shapes_aux: are_compatible_shapes_aux{'diff; 'l1; 'l2} <-->
   fix{ f. lambda{ diff. lambda{ l1. lambda{ l2.
      list_ind{ 'l1; is_nil{'l2}; h1,t1,g.
         list_ind{ 'l2; bfalse; h2,t2,g.
            band{ beq_int{(var_arity{'h2} -@ var_arity{'h1}); 'diff};
               'f (var_arity{'h2} -@ var_arity{'h1}) 't1 't2 } } }
      } } } } 'diff 'l1 'l2

define unfold_are_compatible_shapes: are_compatible_shapes{'bt; 'l} <-->
   are_compatible_shapes_aux{var_arity{'bt};subterms{'bt};'l}

define unfold_compatible_shapes:
   compatible_shapes{'bt; 'l} <--> "assert"{ are_compatible_shapes{'bt; 'l} }

let fold_are_compatible_shapes_aux = makeFoldC << are_compatible_shapes_aux{'diff; 'l1; 'l2} >> unfold_are_compatible_shapes_aux

interactive are_compatible_shapes_aux_wf {| intro [] |} :
   sequent { <H> >- 'diff in int } -->
   sequent { <H> >- 'l1 in list{BTerm} } -->
   sequent { <H> >- 'l2 in list{BTerm} } -->
   sequent { <H> >- are_compatible_shapes_aux{'diff; 'l1; 'l2} in bool }

interactive are_compatible_shapes_wf {| intro [] |} :
   sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- 'l in list{BTerm} } -->
   sequent { <H> >- are_compatible_shapes{'bt; 'l} in bool }

interactive compatible_shapes_wf {| intro [] |} :
   sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- 'l in list{BTerm} } -->
   sequent { <H> >- compatible_shapes{'bt; 'l} Type }

prim_rw makebterm_var :
   'b in Var -->
   make_bterm{'b; nil} <--> 'b

prim makebterm_wf {| intro [] |} :
   sequent { <H> >- 'bt in OpBTerm } -->
   sequent { <H> >- 'btl in list{BTerm} } -->
   sequent { <H> >- compatible_shapes{'bt; 'btl} } -->
   sequent { <H> >- make_bterm{'bt; 'btl} in OpBTerm } =
   it

(* ??? *)
prim_rw makebterm_same_op :
   'b1 in BTerm -->
   'b2 in BTerm -->
   same_op{'b1; 'b2} -->
   var_arity{'b1} = var_arity{'b2} in int -->
   make_bterm{'b1; subterms{'b2}} <--> 'b2

(* ??? *)
interactive_rw makebterm_reduce {| reduce |} :
   'b in BTerm -->
    make_bterm{'b; subterms{'b}} <--> 'b

(* ??? *)
interactive_rw make_bterm_nilsubterms :
   'bt in BTerm -->
   subterms{'bt} = nil in list{BTerm} -->
   make_bterm{'bt; nil} <--> 'bt

interactive_rw compatible_shapes_var 'bt ('btl :> Perv!Term) :
   'bt in Var -->
   'btl in list{BTerm} -->
   compatible_shapes{'bt; 'btl} -->
   'btl <--> nil

let compatible_shapes_varC bt = termC (compatible_shapes_var bt)

interactive compatible_shapes_var1 'bt:
   sequent { <H> >- 'bt in Var } -->
   sequent { <H> >- 'btl in list{BTerm} } -->
   sequent { <H> >- compatible_shapes{'bt; 'btl} } -->
   sequent { <H> >- 'btl ~ nil }

interactive makebterm_wf1 {| intro [] |} :
   sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- 'btl in list{BTerm} } -->
   sequent { <H> >- compatible_shapes{'bt; 'btl} } -->
   sequent { <H> >- make_bterm{'bt; 'btl} in BTerm }

interactive make_bterm_is_not_varbterm {| intro [] |} :
   sequent { <H> >- 'bt in OpBTerm } -->
   sequent { <H> >- 'btl in list{BTerm} } -->
   sequent { <H> >- compatible_shapes{'bt; 'btl} } -->
   sequent { <H> >-  not{var_bterm{ make_bterm{'bt; 'btl} }} }

prim makebterm_wf_elim {| elim [] |} 'H :
   sequent { <H>; x: make_bterm{'bt; 'btl} in BTerm; <J[it]> >- 'bt in BTerm } -->
   sequent { <H>; x: make_bterm{'bt; 'btl} in BTerm; <J[it]> >- 'btl in list{BTerm} } -->
   ('t['x; 'y] : sequent { <H>; x: make_bterm{'bt; 'btl} in BTerm; <J[it]>; y: compatible_shapes{'bt; 'btl} >- 'C[it] }) -->
   sequent { <H>; x: make_bterm{'bt; 'btl} in BTerm; <J['x]> >- 'C['x] } =
   't[it; it]

interactive_rw var_arity_make_bterm_rw {| reduce |} :
   'bt in BTerm  -->
   'btl in list{BTerm}  -->
    compatible_shapes{'bt; 'btl}  -->
    var_arity{make_bterm{'bt; 'btl}} <-->  var_arity{'bt}


(************************************************************************
 * Bterm elimination rules                                              *
 ************************************************************************)

interactive bterm_elim1 {| elim [ThinOption thinT] |} 'H bind{x.'f['x]} :
   sequent { <H>; b: BTerm; <J['b]>; a: BTerm >- 'f['a] in nat } -->
   sequent { <H>; b: BTerm; <J['b]>; c: BTerm; all a: BTerm. ('f['a] < 'f['c] => 'C['a]) >- 'C['c] } -->
   sequent { <H>; b: BTerm; <J['b]> >- 'C['b] }

interactive bterm_elim2 {| elim [] |} 'H :
   sequent { <H>; b: BTerm; <J['b]>; c: BTerm; bl: list{BTerm};
      all a: BTerm. (mem{'a; 'bl; BTerm} => 'C['a] & depth{'a} < depth{'c}) >- 'C[make_bterm{'c; 'bl}] } -->
   sequent { <H>; b: BTerm; <J['b]> >- 'C['b] }

interactive bterm_elim3 {| elim [] |} 'H :
   sequent { <H>; b: BTerm; <J['b]>; c: BTerm; simple_bterm{'c} >- 'C['c] } -->
   sequent { <H>; b: BTerm; <J['b]>; c: BTerm; not{simple_bterm{'c}}; all a: Term. 'C[subst{'c; 'a}] >- 'C['c] } -->
   sequent { <H>; b: BTerm; <J['b]> >- 'C['b] }

interactive bterm_elim4 {| elim [] |} 'H :
   sequent { <H>; b: BTerm; <J['b]>; c: Term >- 'C['c] } -->
   sequent { <H>; b: BTerm; <J['b]>; c: BBTerm; all a: Term. 'C[subst{'c; 'a}] >- 'C['c] } -->
   sequent { <H>; b: BTerm; <J['b]> >- 'C['b] }

(************************************************************************
 * Properties                                                           *
 ************************************************************************)

(* may need other well-formedness assumptions for the 4 rules below *)
prim subterms_make_bterm {| intro [] |} :
   sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- 'btl in list{BTerm} } -->
   sequent { <H> >- compatible_shapes{'bt; 'btl} } -->
   sequent { <H> >- subterms{make_bterm{'bt; 'btl}} ~ 'btl } = it

prim same_op_make_bterm {| intro [] |} :
   sequent { <H> >- 'bt in BTerm } -->
   sequent { <H> >- 'btl in list{BTerm} } -->
   sequent { <H> >- compatible_shapes{'bt; 'btl} } -->
   sequent { <H> >- same_op{make_bterm{'bt; 'btl}; 'bt} }  = it

prim same_op_subst {| intro [] |} :
   sequent { <H> >- 'bt in BBTerm } -->
   sequent { <H> >- 't in Term } -->
   sequent { <H> >- same_op{subst{'bt; 't}; 'bt} } = it

prim subterms_subst {| intro [] |} :
   sequent { <H> >- 'bt in BBTerm } -->
   sequent { <H> >- 't in Term } -->
   sequent { <H> >- subterms{subst{'bt; 't}} ~ map{lambda{x.subst{'x; 't}}; subterms{'bt}} }  = it


interactive subst_make_bterm {| intro [] |} :
   sequent { <H> >- 't in Term } -->
   sequent { <H> >- 'bt in OpBTerm } -->
   sequent { <H> >- 'btl in list{BBTerm} } -->
   sequent { <H> >- make_bterm{'bt; 'btl} in BBTerm } -->
   sequent { <H> >- subst{make_bterm{'bt; 'btl}; 't} ~ make_bterm{subst{'bt;'t}; map{lambda{x.subst{'x; 't}}; 'btl}} }



(************************************************************************
 * Tactics                                                              *
 ************************************************************************)
(*
 * Split a bterm into var and opbterm in the conclusion.
 *)
let splitBTermVCT = argfunT (fun a p ->
   let bind = get_bind_from_arg_or_concl_subst p a in
      var_or_opbterm_concl bind a)

(*
 * Split a bterm into var and opbterm in a hyp.
 *)
let splitBTermVHT i a = funT (fun p ->
   let bind = get_bind_from_arg_or_hyp_subst p i a in
      var_or_opbterm_hyp (Sequent.get_pos_hyp_num p i) bind a)

let splitBTermVT t i =
   if i = 0 then
      splitBTermVCT t
   else
      splitBTermVHT i t

(*
 * Split a bterm into term and bbterm in the conclusion.
 *)
let splitBTermTCT = argfunT (fun a p ->
   let bind = get_bind_from_arg_or_concl_subst p a in
      term_or_bbterm_concl bind a)

(*
 * Split a bterm into term and bbterm in a hyp.
 *)
let splitBTermTHT i a = funT (fun p ->
   let bind = get_bind_from_arg_or_hyp_subst p i a in
      term_or_bbterm_hyp (Sequent.get_pos_hyp_num p i) bind a)

let splitBTermTT t i =
   if i = 0 then
      splitBTermTCT t
   else
      splitBTermTHT i t
