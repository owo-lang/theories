(*!
 * @spelling{arithT tactic implementation}
 *
 * @begin[doc]
 * @module[Itt_int_arith]
 *
 * Prove simple systems of inequalities
 * @end[doc]
 *
 * ----------------------------------------------------------------
 *
 * @begin[license]
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
 * Author: Yegor Bryukhov
 * @email{ynb@mail.ru}
 * @end[license]
 *)

extends Itt_equal
extends Itt_rfun
extends Itt_logic
extends Itt_bool
extends Itt_int_ext
(*! @docoff *)

open Printf
open Mp_debug
open Opname
open Refiner.Refiner.Term
open Refiner.Refiner.TermOp
open Refiner.Refiner.TermMan
open Refiner.Refiner.TermSubst
open Refiner.Refiner.TermType
open Refiner.Refiner.RefineError
open Rformat
open Mp_resource

open Var
open Tactic_type
open Tactic_type.Tacticals
open Tactic_type.Conversionals

open Base_meta
open Base_dtactic

open Top_conversionals

open Itt_equal
open Itt_struct
open Itt_bool

open Itt_int_base
open Itt_int_ext

let _ = show_loading "Loading Itt_int_ext%t"

let debug_int_arith =
   create_debug (**)
      { debug_name = "debug_int_arith";
        debug_description = "Print out some debug info as tactics proceed";
        debug_value = false
      }

(*******************************************************
 * ARITH
 *******************************************************)

(*
 * thenMT_prefix with locality-principle behaviour
 *)

let debug_subgoals =
   create_debug (**)
      { debug_name = "subgoals";
        debug_description = "Report subgoals observed with may be some additional info";
        debug_value = false
      }

   let emptyLabel=""

   let thenIfLabelPredT pred tac1 tac2 tac3 p =
      let prefer l1 l2 =
         if l2=emptyLabel then l1
         else l2 in
      let label = Sequent.label p in
      let restoreHiddenLabelT l p' =
         addHiddenLabelT (prefer l (Sequent.label p')) p'
      in
      let ifLabelPredT pred tac1' tac2' p' =
         (let lab=Sequent.label p' in
         if pred lab then
            tac1'
         else
            tac2'
         ) p'
      in
      (addHiddenLabelT emptyLabel thenT
      tac1 thenT
      ifLabelPredT pred tac2 tac3 thenT
      restoreHiddenLabelT label) p

(*
   let ifMextendedT tac p =
      let lab=Sequent.label p in
      (if (List.mem lab main_labels) or Left(lab,5)="main_" then
          tac
       else
          idT) p

   let thenMextendedT tac1 tac2 =
      prefix_thenT tac1 (ifMT tac2)
*)

   let isEmptyOrMainLabel l =
      (l=emptyLabel) or (List.mem l main_labels)

   let isEmptyOrAuxLabel l =
      (l=emptyLabel) or not (List.mem l main_labels)

   let thenLocalMT tac1 tac2 p =
      thenIfLabelPredT isEmptyOrMainLabel tac1 tac2 idT p

   let thenLocalMElseT tac1 tac2 tac3 p =
      let tac2' p'=
            if !debug_subgoals then
               eprintf "\nPositive:\n%a%t" print_term (Sequent.goal p') eflush;
            tac2 p'
      in
      let tac3' p'=
            if !debug_subgoals then
               eprintf "\nNegative:\n%a%t" print_term (Sequent.goal p') eflush;
            tac3 p'
      in
      thenIfLabelPredT isEmptyOrMainLabel tac1 tac2' tac3' p

   let thenLocalAT tac1 tac2 p =
      thenIfLabelPredT isEmptyOrAuxLabel tac1 tac2 idT p

   let onAllLocalMHypsT tac p =
      let rec aux i =
         if i = 1 then
            tac i
         else if i > 1 then
            thenLocalMT (tac i) (aux (pred i))
         else
            idT
      in
         aux (Sequent.hyp_count p) p

(*
 * end of thenMT_prefix part
 *)


let get_term i p =
(* We skip first item because it is a context *)
   if i<>1 then Sequent.nth_hyp p i else mk_simple_term xperv []

let le2geT t p =
   let (left,right)=dest_le t in
   let newt=mk_ge_term right left in
   thenLocalAT (assertT newt) (thenLocalMT (rwh unfold_ge 0) (onSomeHypT
 nthHypT)) p

interactive lt2ge :
   [wf] sequent [squash] { 'H >- 'a in int } -->
   [wf] sequent [squash] { 'H >- 'b in int } -->
   sequent [squash] { 'H >- 'a < 'b } -->
   sequent ['ext] { 'H >- 'b >= ('a +@ 1) }

let lt2geT t p =
   let (left,right)=dest_lt t in
   let newt=mk_ge_term right
                      (mk_add_term left
                                  (mk_number_term (Mp_num.num_of_int 1))) in
      (thenLocalAT (assertT newt) lt2ge) p

interactive gt2ge :
   [wf] sequent [squash] { 'H >- 'a in int } -->
   [wf] sequent [squash] { 'H >- 'b in int } -->
   sequent [squash] { 'H >- 'a > 'b } -->
   sequent ['ext] { 'H >- 'a >= ('b +@ 1) }

let gt2geT t p =
   let (left,right)=dest_gt t in
   let newt=mk_ge_term left
                      (mk_add_term right
                                  (mk_number_term (Mp_num.num_of_int 1))) in
      (thenLocalAT (assertT newt) gt2ge ) p

interactive eq2ge1 :
   sequent [squash] { 'H >- 'a = 'b in int } -->
   sequent ['ext] { 'H >- 'a >= 'b }

let eq2ge1T = eq2ge1

interactive eq2ge2 :
   sequent [squash] { 'H >- 'a = 'b in int } -->
   sequent ['ext] { 'H >- 'b >= 'a }

let eq2ge2T = eq2ge2

let eq2geT t =
   let (_,l,r)=dest_equal t in
   thenLocalMT
   (thenLocalAT (assertT (mk_ge_term l r)) (eq2ge1T thenT (onSomeHypT nthHypT)))
   (thenLocalAT (assertT (mk_ge_term r l)) (eq2ge2T thenT (onSomeHypT nthHypT)))

interactive notle2ge :
   [wf] sequent [squash] { 'H >- 'a in int } -->
   [wf] sequent [squash] { 'H >- 'b in int } -->
   [aux] sequent [squash] { 'H >- "not"{('a <= 'b)} } -->
   sequent ['ext] { 'H >- 'a >= ('b +@ 1) }

(*
let notle2geT t =
   let (l,r)=dest_le t in
   let newt = mk_ge_term l (mk_add_term r (Mp_num.num_of_int 1)) in
*)

let anyArithRel2geT i p =
(* We skip first item because it is a context *)
   let t=get_term i p in
   if is_le_term t then le2geT t p
   else if is_lt_term t then lt2geT t p
   else if is_gt_term t then gt2geT t p
   else if is_equal_term t then
      let (tt,l,r)=dest_equal t in
         if tt=int_term then
            (eq2geT t p)
         else
            idT p
   else idT p (*if is_not_term t then
      let t1=dest_not t in
         if is_ge_term t1 then notge2geT t1
         else if is_le_term t1 then notle2geT t1
         else if is_lt_term t1 then notlt2geT t1
         else if is_gt_term t1 then notgt2geT t1 *)

interactive_rw bnot_lt2ge_rw :
   ('a in int) -->
   ('b in int) -->
   "assert"{bnot{lt_bool{'a; 'b}}} <--> ('a >= 'b)

let bnot_lt2geC = bnot_lt2ge_rw

let lt2ConclT p = (magicT thenLT [(addHiddenLabelT "wf"); rwh bnot_lt2geC (-1)]
 ) p

let ltInConcl2HypT =
   thenLocalMT (rwh unfold_lt 0) lt2ConclT

let gtInConcl2HypT =
   thenLocalMT (rwh unfold_gt 0) ltInConcl2HypT

interactive_rw bnot_le2gt_rw :
   ('a in int) -->
   ('b in int) -->
   "assert"{bnot{le_bool{'a; 'b}}} <--> ('a > 'b)

let bnot_le2gtC = bnot_le2gt_rw

let leInConcl2HypT =
   thenLocalMT (rwh unfold_le 0) (magicT thenLT [idT;rwh bnot_le2gtC (-1)])

let geInConcl2HypT =
   thenLocalMT (rwh unfold_ge 0) leInConcl2HypT

let arithRelInConcl2HypT p =
   let g=Sequent.goal p in
   let t=Refiner.Refiner.TermMan.nth_concl g 1 in
(*      print_term stdout t; *)
   if is_lt_term t then ltInConcl2HypT p
   else if is_gt_term t then gtInConcl2HypT p
   else if is_le_term t then leInConcl2HypT p
   else if is_ge_term t then geInConcl2HypT p
   else idT p

interactive ge_addMono :
   sequent [squash] { 'H >- 'a in int } -->
   sequent [squash] { 'H >- 'b in int } -->
   sequent [squash] { 'H >- 'c in int } -->
   sequent [squash] { 'H >- 'd in int } -->
   sequent [squash] { 'H >- 'a >= 'b } -->
   sequent [squash] { 'H >- 'c >= 'd } -->
   sequent ['ext] { 'H >- ('a +@ 'c) >= ('b +@ 'd) }

type comparison = Less | Equal | Greater

let rec compare_terms t1 t2 =
   if t1==t2 then
      Equal
   else
     let {term_op=op1; term_terms=subt1} = dest_term t1 in
     let {term_op=op2; term_terms=subt2} = dest_term t2 in
       match compare_ops op1 op2 with
         Less -> Less
       | Greater -> Greater
       | Equal -> compare_btlists subt1 subt2

and compare_ops op1 op2 =
   if op1==op2 then
      Equal
   else
     let {op_name = opn1; op_params = par1} = dest_op op1 in
     let {op_name = opn2; op_params = par2} = dest_op op2 in
     let str1 = string_of_opname opn1 in
     let str2 = string_of_opname opn2 in
        if str1 < str2 then
          Less
        else if str1 > str2 then
          Greater
        else
          compare_plists par1 par2

and compare_btlists subt1 subt2 =
   if subt1==subt2 then
      Equal
   else
      match subt1 with
        [] ->
          (
          match subt2 with
            [] -> Equal
          | hd2::tail2 -> Less
          )
      | hd1::tail1 ->
          (
          match subt2 with
            [] -> Greater
          | hd2::tail2 ->
            match compare_bterms hd1 hd2 with
              Less -> Less
          | Greater -> Greater
          | Equal -> compare_btlists tail1 tail2
          )

and compare_bterms b1 b2 =
   if b1==b2 then
      Equal
   else
      let {bvars = bv1; bterm = t1} = dest_bterm b1 in
      let {bvars = bv2; bterm = t2} = dest_bterm b2 in
      compare_terms t1 t2

and compare_plists p1 p2 =
   if p1==p2 then
      Equal
   else
      match p1 with
        [] ->
          (
          match p2 with
            [] -> Equal
          | hd2::tail2 -> Less
          )
      | hd1::tail1 ->
          (
          match p2 with
            [] -> Greater
          | hd2::tail2 ->
            match compare_params hd1 hd2 with
              Less -> Less
            | Greater -> Greater
            | Equal -> compare_plists tail1 tail2
          )

and compare_params par1 par2 =
   if par1==par2 then
      Equal
   else
      let p1 = dest_param par1 in
      let p2 = dest_param par2 in
      match p1 with
        Number(n1) ->
         (
          match p2 with
            Number(n2) ->
              if n1<n2 then Less
              else if n1>n2 then Greater
              else Equal
          | _ -> Less
         )
      | String(s1) ->
         (
          match p2 with
            Number(_) -> Greater
          | String(s2) ->
             if s1<s2 then Less
             else if s1>s2 then Greater
             else Equal
          | _ -> Less
         )
      | Token(s1) ->
         (
          match p2 with
            Number(_) -> Greater
          | String(_) -> Greater
          | Token(s2) ->
             if s1<s2 then Less
             else if s1>s2 then Greater
             else Equal
          | _ -> Less
         )
      | Var(s1) ->
         (
          match p2 with
            Number(_) -> Greater
          | String(_) -> Greater
          | Token(_) -> Greater
          | Var(s2) ->
             if s1<s2 then Less
             else if s1>s2 then Greater
             else Equal
          | _ -> Less
         )
      | MNumber(s1) ->
         (
          match p2 with
            Number(_) -> Greater
          | String(_) -> Greater
          | Token(_) -> Greater
          | Var(_) -> Greater
          | MNumber(s2) ->
             if s1<s2 then Less
             else if s1>s2 then Greater
             else Equal
          | _ -> Less
         )
      | MString(s1) ->
         (
          match p2 with
            Number(_) -> Greater
          | String(_) -> Greater
          | Token(_) -> Greater
          | Var(_) -> Greater
          | MNumber(_) -> Greater
          | MString(s2) ->
             if s1<s2 then Less
             else if s1>s2 then Greater
             else Equal
          | _ -> Less
         )
      | MToken(s1) ->
         (
          match p2 with
            Number(_) -> Greater
          | String(_) -> Greater
          | Token(_) -> Greater
          | Var(_) -> Greater
          | MNumber(_) -> Greater
          | MString(_) -> Greater
          | MToken(s2) ->
             if s1<s2 then Less
             else if s1>s2 then Greater
             else Equal
          | _ -> Less
         )
      | MLevel(l1) ->
         (
          match p2 with
            Number(_) -> Greater
          | String(_) -> Greater
          | Token(_) -> Greater
          | Var(_) -> Greater
          | MNumber(_) -> Greater
          | MString(_) -> Greater
          | MToken(_) -> Greater
          | MLevel(l2) -> compare_levels l1 l2
          | _ -> Less
         )
      | MVar(s1) ->
         (
          match p2 with
            Number(_) -> Greater
          | String(_) -> Greater
          | Token(_) -> Greater
          | Var(_) -> Greater
          | MNumber(_) -> Greater
          | MString(_) -> Greater
          | MToken(_) -> Greater
          | MLevel(_) -> Greater
          | MVar(s2) ->
             if s1<s2 then Less
             else if s1>s2 then Greater
             else Equal
          | _ -> Less
         )
      | ObId(id1) ->
         (
          match p2 with
            Number(_) -> Greater
          | String(_) -> Greater
          | Token(_) -> Greater
          | Var(_) -> Greater
          | MNumber(_) -> Greater
          | MString(_) -> Greater
          | MToken(_) -> Greater
          | MLevel(_) -> Greater
          | MVar(_) -> Greater
          | ObId(id2) -> compare_plists id1 id2
          | _ -> Less
        )
      | ParamList(pl1) ->
         (
          match p2 with
            Number(_) -> Greater
          | String(_) -> Greater
          | Token(_) -> Greater
          | Var(_) -> Greater
          | MNumber(_) -> Greater
          | MString(_) -> Greater
          | MToken(_) -> Greater
          | MLevel(_) -> Greater
          | MVar(_) -> Greater
          | ObId(_) -> Greater
          | ParamList(pl2) -> compare_plists pl1 pl2
         )

and compare_levels l1 l2 =
   if l1==l2 then
      Equal
   else
      let {le_const = c1; le_vars = v1} = dest_level l1 in
      let {le_const = c2; le_vars = v2} = dest_level l2 in
        if c1<c2 then Less
        else if c1>c2 then Greater
        else compare_lvlists v1 v2

and compare_lvlists lv1 lv2 =
   if lv1==lv2 then
      Equal
   else
      match lv1 with
        [] ->
          (
          match lv2 with
            [] -> Equal
          | hd2::tail2 -> Less
          )
      | hd1::tail1 ->
          (
          match lv2 with
            [] -> Greater
          | hd2::tail2 ->
            match compare_lvars hd1 hd2 with
              Less -> Less
            | Greater -> Greater
            | Equal -> compare_lvlists tail1 tail2
          )

and compare_lvars v1 v2 =
   if v1==v2 then
      Equal
   else
      let {le_var=s1; le_offset=o1}=dest_level_var v1 in
      let {le_var=s2; le_offset=o2}=dest_level_var v2 in
        if s1<s2 then Less
        else if s1>s2 then Greater
        else
          if o1<o2 then Less
          else if o1>o2 then Greater
          else Equal

let ct a b =
  match compare_terms a b with
    Less -> -1
  | Equal -> 0
  | Greater -> 1

interactive_rw mul_BubblePrimitive_rw :
   ( 'a in int ) -->
   ( 'b in int ) -->
   ( 'c in int ) -->
   ('a *@ ('b *@ 'c)) <--> ('b *@ ('a *@ 'c))

let mul_BubblePrimitiveC = mul_BubblePrimitive_rw

(* One step of sorting of production of some terms with simultenious
   contraction of product of integers
 *)
let mul_BubbleStepC tm =
   if is_mul_term tm then
      let (a,s) = dest_mul tm in
         if is_mul_term s then
            let (b,c) = dest_mul s in
	       if (is_number_term a) & (is_number_term b) then
	          (mul_AssocC thenC (addrC [0] reduceC))
	       else
                  if (compare_terms b a)=Less or
                   (is_number_term b) then
                     mul_BubblePrimitiveC
                  else
                     idC
         else
            if (is_number_term a) & (is_number_term s) then
	       		reduceC
	    		else
               if ((compare_terms s a)=Less & not (is_number_term a)) or
                	(is_number_term s) then
	          		mul_CommutC
	       		else
	          		idC
   else
      failC

(* here we apply mul_BubbleStepC as many times as possible thus
   finally we have all mul subterms positioned in order
 *)
let mul_BubbleSortC = repeatC (sweepDnC (termC mul_BubbleStepC))

let inject_coefC t =
	if not (is_add_term t) then
   	mul_Id3C thenC
      (repeatC (sweepDnC mul_uni_AssocC)) thenC
      (addrC [0] reduceC)
   else
   	failC
(*
   if is_mul_term t then
      mul_Id3C
   else
      failC
*)

let inject_coef2C t =
	if is_add_term t then
   	let (a,b)=dest_add t in
      begin
      	if !debug_int_arith then
         	eprintf "\ninject_coefC: %a %a%t" print_term a print_term b eflush
         else
         	();
      	let aC=if not (is_add_term a) then
      				addrC [0] (mul_Id3C thenC
      								(repeatC (sweepDnC mul_uni_AssocC)) thenC
      								(addrC [0] reduceC))
       			 else
             		idC
      	in
      	let bC=if not (is_add_term b) then
      				addrC [1] (mul_Id3C thenC
      								(repeatC (sweepDnC mul_uni_AssocC)) thenC
      								(addrC [0] reduceC))
       			 else
             		idC
      	in
      	aC thenC bC
      end
	else
   	idC


let checkArithTermC conv =
	let auxC t = if (is_mul_term t) or
   					 (is_add_term t) or
                   (is_minus_term t) then
                   conv
         		 else
                	 idC
	in
   termC auxC

               (* (higherC (termC inject_coefC)) thenC *)
let injectCoefC = checkArithTermC (higherC (termC inject_coefC))
let injectCoef2C = sweepUpC (termC inject_coef2C)

(* Before terms sorting we have to put parentheses in the rightmost-first
manner
 *)
let mul_normalizeC = (* (repeatC (higherC mul_Assoc2C)) thenC *)
                     injectCoef2C thenC mul_BubbleSortC

interactive_rw sum_same_products1_rw :
   ('a in int) -->
   ((number[i:n] *@ 'a) +@ (number[j:n] *@ 'a)) <--> ((number[i:n] +@
 number[j:n]) *@ 'a)

let sum_same_products1C = sum_same_products1_rw

(*
interactive_rw sum_same_products2_rw :
   ('a in int) -->
   ((number[i:n] *@ 'a) +@ 'a) <--> ((number[i:n] +@ 1) *@ 'a)

let sum_same_products2C = sum_same_products2_rw

interactive_rw sum_same_products3_rw :
   ('a in int) -->
   ('a +@ (number[j:n] *@ 'a)) <--> ((number[j:n] +@ 1) *@ 'a)

let sum_same_products3C = sum_same_products3_rw

interactive_rw sum_same_products4_rw :
   ('a in int) -->
   ('a +@ 'a) <--> (2 *@ 'a)

let sum_same_products4C = sum_same_products4_rw
*)

let same_product_aux a b =
   if (is_mul_term a) & (is_mul_term b) then
      let (a1,a2)=dest_mul a in
      let (b1,b2)=dest_mul b in
      if (compare_terms a2 b2)=Equal then
         (true, sum_same_products1C)
      else
         (false, idC)
   else
	  	(false, idC)

let same_productC t =
   if (is_add_term t) then
      let (a,b)=dest_add t in
      if is_add_term b then
         let (b1,b2)=dest_add b in
         let (same, conv)=same_product_aux a b1 in
         if same then
           (add_AssocC thenC (addrC [0] (conv thenC (addrC [0] reduceC))))
         else
           idC
      else
         let (same, conv)=same_product_aux a b in
         if same then
            conv thenC reduceC
         else
            idC
   else
      idC

interactive_rw add_BubblePrimitive_rw :
   ( 'a in int ) -->
   ( 'b in int ) -->
   ( 'c in int ) -->
   ('a +@ ('b +@ 'c)) <--> ('b +@ ('a +@ 'c))

let add_BubblePrimitiveC = add_BubblePrimitive_rw

let stripCoef t =
   if is_mul_term t then
      let (c,t')=dest_mul t in
      if (is_number_term c) then
         t'
      else
         t
   else
      t

(* One step of sorting of sum of some terms with simultenious
   contraction of sum of integers
 *)
let add_BubbleStepC tm =
  (if !debug_int_arith then
		eprintf "\nadd_BubbleStepC: %a%t" print_term tm eflush
   else
      ();
   if is_add_term tm then
      let (a,s) = dest_add tm in
         if is_add_term s then
            let (b,c) = dest_add s in
	       	if (is_number_term a) & (is_number_term b) then
               begin
               	if !debug_int_arith then
							eprintf "add_BubbleStepC: adding numbers a b%t" eflush
                  else
                  	();
	        			(add_AssocC thenC (addrC [0] reduceC)) thenC (tryC add_Id2C)
               end
	       	else
                  let a'=stripCoef a in
                  let b'=stripCoef b in
                  if (compare_terms b' a')=Less then
                     add_BubblePrimitiveC
                  else
                     failC
         else
            if (is_number_term a) & (is_number_term s) then
               begin
               	if !debug_int_arith then
							eprintf "add_BubbleStepC: adding numbers a s%t" eflush
                  else
                  	();
		       		reduceC
               end
	    		else
     				if (compare_terms s a)=Less then
	          		add_CommutC
	       		else
	          		failC
   else
      begin
        	if !debug_int_arith then
				eprintf "add_BubbleStepC: wrong term%t" eflush
         else
         	();
	      failC
      end
  )

(* here we apply add_BubbleStepC as many times as possible thus
   finally we have all sum subterms positioned in order
 *)
let add_BubbleSortC = (repeatC (sweepDnC (termC add_BubbleStepC))) thenC
                      (repeatC (sweepDnC (termC same_productC)))

interactive_rw sub_elim_rw :
   ( 'a in int ) -->
   ( 'b in int ) -->
   ('a -@ 'b ) <--> ('a +@ ((-1) *@ 'b))

let sub_elimC = repeatC (higherC sub_elim_rw)

(* Before terms sorting we have to put parentheses in the rightmost-first
manner
 *)
let add_normalizeC = (* (repeatC (higherC add_Assoc2C)) thenC *)
                     add_BubbleSortC

let open_parenthesesC = repeatC (higherC mul_add_DistribC)

let normalizeC = (repeatC (sweepDnC sub_elimC)) thenC
                 reduceC thenC
                 (* open_parenthesesC thenC *)
                 mul_normalizeC thenC
                 add_normalizeC thenC
                 reduceC

interactive_rw ge_addContract_rw :
   ( 'a in int ) -->
   ( 'b in int ) -->
   ('a >= ('b +@ 'a)) <--> (0 >= 'b)

let ge_addContractC = ge_addContract_rw

(*
   Reduce contradictory relation a>=a+b where b>0.
 *)
let reduceContradRelT i p = (rw ((addrC [0] normalizeC) thenC
                                 (addrC [1] normalizeC) thenC
						               (tryC ge_addContractC) thenC
					   			      reduceC)
                                i) p

let provideConstantC t =
   if is_number_term t then
      add_Id4C (*idC*)
   else if is_add_term t then
      let (a,b)=dest_add t in
      if is_number_term a then
         idC
      else
         add_Id3C
   else
      add_Id3C

interactive ge_addMono2 'c :
   [wf] sequent [squash] { 'H >- 'a in int } -->
   [wf] sequent [squash] { 'H >- 'b in int } -->
   [wf] sequent [squash] { 'H >- 'c in int } -->
   sequent ['ext] { 'H >- ('a >= 'b) ~ (('c +@ 'a) >= ('c +@ 'b)) }

interactive_rw ge_addMono2_rw 'c :
   ( 'a in int ) -->
   ( 'b in int ) -->
   ( 'c in int ) -->
   ('a >= 'b) <--> (('c +@ 'a) >= ('c +@ 'b))

let ge_addMono2C = ge_addMono2_rw

let reduce_geLeftC = (addrC [0] normalizeC)
let reduce_geRightC = (addrC [1] (normalizeC thenC (termC provideConstantC)))

let reduce_geCommonConstT i p =
   let t=get_term i p in
   let (left,right)=dest_ge t in
   if is_add_term left then
      let (a,b)=dest_add left in
      if is_number_term a then
         thenLocalMT (rw (ge_addMono2_rw (mk_minus_term a)) i)
                     (rw reduce_geLeftC i) p
      else
         idT p
   else
      idT p

let tryReduce_geT i p =
   let t=get_term i p in
      if is_ge_term t then
         thenLocalMT (rw reduce_geLeftC i)
         (thenLocalMT (reduce_geCommonConstT i)
                     (rw reduce_geRightC i)) p
      else
         idT p

(* Generate sum of ge-relations
 *)
let sumList tl g =
   match tl with
   h::t ->
      let aux a (l,r) =
         let tm = nth_hyp g a in
         let (al,ar) = dest_ge tm in
         (mk_add_term al l, mk_add_term ar r) in
      let h_tm = nth_hyp g h in
      let (sl, sr)=List.fold_right aux t (dest_ge h_tm) in
      mk_ge_term sl sr
   | [] ->
      let zero = << 0 >> in
         mk_ge_term zero zero

(* autoT should be removed to permit incorporation
of this tactic into autoT
 *)
let proveSumT = ge_addMono

(* Asserts sum of ge-relations and grounds it
 *)
let sumListT l p =
   let s = sumList l (Sequent.goal p) in
   (if !debug_int_arith then
   	eprintf "Contradictory term:%a%t" print_term s eflush
    else ();
   thenLocalAT (assertT s) (tryT (progressT proveSumT)) p)

(* Test if term has a form of a>=b+i where i is a number
 *)
let good_term t =
(*
   print_term stdout t;
   eprintf "\n %s \n" (Opname.string_of_opname (opname_of_term t));
*)
   if is_ge_term t then
     let (_,b)=dest_ge t in
        if is_add_term b then
           let (d,_)=dest_add b in
              (is_number_term d)
        else
           false
   else
     ((*print_term stdout t;
      eprintf "%s %s\n" (Opname.string_of_opname (opname_of_term t))
                        (Opname.string_of_opname (opname_of_term ge_term));*)
      false
     )

(* Searches for contradiction among ge-relations
 *)
let findContradRelT p =
   let g=Sequent.goal p in
   let l = Arith.collect good_term g in
   let ar=Array.of_list l in
   match Arith.TG.solve (g,ar) with
      Arith.TG.Int (_,r),_ ->
         let aux3 i al = (ar.(i))::al in
         let rl = List.fold_right aux3 r [] in
         (if !debug_int_arith then
            let rec lprint ch ll =match ll with
               h::t -> (fprintf ch "%u " h; lprint ch t)
             | [] -> fprintf ch "."
            in
            eprintf "Hyps to sum:%a%t" lprint rl eflush
          else ();
         sumListT rl p)
    | Arith.TG.Disconnected,_ ->
         raise (RefineError("arithT", StringError "Proof by contradiction - No contradiction found"))

(* Finds and proves contradiction among ge-relations
 *)
let arithT =
   thenLocalMT arithRelInConcl2HypT
   (thenLocalMT (onAllLocalMHypsT anyArithRel2geT)
   (thenLocalMT (onAllLocalMHypsT tryReduce_geT)
   (thenLocalMT findContradRelT (reduceContradRelT (-1)))))

interactive test 'H 'a 'b 'c :
sequent [squash] { 'H >- 'a in int } -->
sequent [squash] { 'H >- 'b in int } -->
sequent [squash] { 'H >- 'c in int } -->
sequent ['ext] { 'H; x: ('a >= ('b +@ 1));
                     t: ('c >= ('b +@ 3));
                     u: ('b >= ('a +@ 0))
                >- "assert"{bfalse} }

interactive test2 'H 'a 'b 'c :
sequent [squash] { 'H >- 'a in int } -->
sequent [squash] { 'H >- 'b in int } -->
sequent [squash] { 'H >- 'c in int } -->
sequent ['ext] { 'H; x: (('b +@ 1) <= 'a);
                     t: ('c > ('b +@ 2));
                     u: ('b >= ('a +@ 0))
                >- "assert"{bfalse} }

interactive test3 'H 'a 'b 'c :
sequent [squash] { 'H >- 'a in int } -->
sequent [squash] { 'H >- 'b in int } -->
sequent [squash] { 'H >- 'c in int } -->
sequent ['ext] { 'H; x: (('b +@ 1) <= 'a);
                     t: ('c > ('b +@ 2))
                >- ('b < ('a +@ 0))  }

interactive test4 'H 'a 'b :
sequent [squash] { 'H >- 'a in int } -->
sequent [squash] { 'H >- 'b in int } -->
sequent ['ext] { 'H; x: ('a >= 'b);
                     t: ('a < 'b)
                >- "assert"{bfalse} }

interactive test5 'H 'a 'b :
sequent [squash] { 'H >- 'a in int } -->
sequent [squash] { 'H >- 'b in int } -->
sequent ['ext] { 'H; x: ('a >= 'b +@ 0);
                     t: ('a < 'b)
                >- "assert"{bfalse} }

interactive test6 'H 'b 'c :
sequent [squash] { 'H >- 'a in int } -->
sequent [squash] { 'H >- 'b in int } -->
sequent [squash] { 'H >- 'c in int } -->
sequent ['ext] { 'H; x: (('c *@ ('b +@ ('a *@ 'c)) +@ ('b *@ 'c)) >= 'b +@ 0);
                     t: (((((('c *@ 'b) *@ 1) +@ (2 *@ ('a *@ ('c *@ 'c)))) +@
 (('c *@ ((-1) *@ 'a)) *@ 'c)) +@ ('b *@ 'c)) < 'b)
                >- "assert"{bfalse} }
