(*!
 * @begin[spelling]
 * cutEq cutMem cutSquash
 * assertEqT letT assertSquashT
 * assertAtT assertSquashAtT assertT
 * hypSubstitution substT struct th
 * @end[spelling]
 *
 * @begin[doc]
 * @module[Itt_struct2]
 *
 * The @tt{Itt_struct2} module contains some @emph{derived} rules similar
 * to @hrefrule[cut] and @hrefrule[substitution] in the @hrefmodule[Itt_struct] theory.
 * @end[doc]
 *
 * ----------------------------------------------------------------
 *
 * @begin[license]
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
 * Author: Alexei Kopylov
 * @email{kopylov@cs.caltech.edu}
 *
 * @end[license]
 *)

(*!
 * @begin[doc]
 * @parents
 * @end[doc]
 *)
extends Itt_equal
extends Itt_struct
extends Itt_squiggle
extends Itt_squash
extends Itt_set
extends Itt_logic
(*! @docoff *)

open Printf
open Mp_debug
open Refiner.Refiner
open Refiner.Refiner.Term
open Refiner.Refiner.TermOp
open Refiner.Refiner.TermMan
open Refiner.Refiner.TermSubst
open Refiner.Refiner.Refine
open Refiner.Refiner.RefineError
open Mp_resource

open Tactic_type
open Tactic_type.Tacticals
open Var
open Mptop

open Base_auto_tactic

open Itt_equal
open Itt_struct
open Itt_squiggle

(*
 * Show that the file is loading.
 *)
let _ =
   show_loading "Loading Itt_struct2%t"

(* debug_string DebugLoad "Loading itt_struct2..." *)

(************************************************************************
 * RULES                                                                *
 ************************************************************************)

(*!
 * @begin[doc]
 * @rules
 * @modsubsection{Substitution}
 *
 * Using @hrefterm[set] type we can derive more stronger version of the @hrefrule[substitution]
 * and @hrefrule[hypSubstitution] rules.
 * Suppose we have that $t_1=t_2 @in T$.
 * To prove that the substitution $A[t_2]$ for $A[t_1]$ is valid it is necessary to prove that
 * the type $A$ is
 * functional only for such $x$ @emph{that equals to $t_1$ and $t_2$ in $T$} (not @emph{for all} $x$ as in
 * original substitution rules).
 * @end[doc]
 *)

interactive substitution2 'H ('t1 = 't2 in 'T) bind{x. 'C['x]} 'v 'w:
   [equality] sequent [squash] { 'H >- 't1 = 't2 in 'T } -->
   [main]  sequent ['ext] { 'H >- 'C['t2] } -->
   [wf] sequent [squash] { 'H; x: 'T; v: 't1='x in 'T; w: 't2='x in 'T
                           >- "type"{'C['x]} } -->
   sequent ['ext] { 'H >- 'C['t1] }

interactive hypSubstitution2 'H 'J ('t1 = 't2 in 'T) bind{y. 'A['y]} 'z 'v 'w:
   [equality] sequent [squash] { 'H; x: 'A['t1]; 'J['x] >- 't1 = 't2 in 'T } -->
   [main] sequent ['ext] { 'H; x: 'A['t2]; 'J['x] >- 'C['x] } -->
   [wf] sequent [squash] { 'H; x: 'A['t1]; 'J['x]; z: 'T; v: 't1='z in 'T; w: 't2='z in 'T
                           >- "type"{'A['z]} } -->
   sequent ['ext] { 'H; x: 'A['t1]; 'J['x] >- 'C['x] }



(*!
 * @begin[doc]
 *
 * The @tt{Itt_struct2} module redefines tactic @hreftactic[substT].
 * From now @tt{substT} uses the above version of substitution
 * instead of original one.
 *
 * @end[doc]
 *)



(*!
 * @begin[doc]
 * @modsubsection{Cut rules}
 *
 * There are three advanced versions of the @hrefrule[cut] rule.
 * The @tt[cutMem] states that if $s @in S$,
 * and $T[x]$ is true for any $x$ from $S$ such that $x=s @in S$,
 * then $T[s]$ is certainly true.
 *
 * @end[doc]
 *)


interactive cutMem 'H 'x 'v 's 'S bind{x.'T['x]} :
  [assertion] sequent[squash]{ 'H >- 's IN 'S } -->
   [main]      sequent ['ext] { 'H; x: 'S; v: 'x='s in 'S >- 'T['x] } -->
   sequent ['ext] { 'H >- 'T['s]}




(*!
 * @begin[doc]
 * The corresponding tactic is the @tt{letT} tactic.
 * This tactic takes a term $x=s @in S$ as an argument
 * and a term $<<bind{x.'T['x]}>>$ as an optional with-argument.
 * If this argument is omitted then the tactic finds all occurrences of $s$
 * in the conclusion and replace them with $x$.
 *
 * This tactic is usually used when we have an assumption $s @in S$,
 * and want to use the elimination rule corresponding to $S$.
 *
 * @end[doc]
 *)

(*
interactive cutEqWeak 'H ('s_1='s_2 in 'S) bind{x.'t['x]} 'v 'u :
   [assertion] sequent[squash]{ 'H >- 's_1='s_2 in 'S } -->
   [main]      sequent ['ext] { 'H; x: 'S; v: 's_1='x in 'S; u: 's_2='x in 'S >- 't['x] IN 'T } -->
   sequent ['ext] { 'H >- 't['s_1] = 't['s_2] in 'T}
*)

interactive cutEq0 'H ('s_1='s_2 in 'S) bind{x.'t_1['x]  't_2['x]} 'v 'u :
   [assertion] sequent[squash]{ 'H >- 's_1='s_2 in 'S } -->
   [main]      sequent ['ext] { 'H; x: 'S; v: 's_1='x in 'S; u: 's_2='x in 'S >- 't_1['x] = 't_2['x] in 'T } -->
   sequent ['ext] { 'H >- 't_1['s_1] = 't_2['s_2] in 'T}


(*!
 * @begin[doc]
 * @modsubsection{Substitution in a type}
 *
 * @end[doc]
 *)

interactive substitutionInType 'H ('t_1 = 't_2 in 'T) bind{x. 'c_1='c_2 in 'C['x]} 'v 'w:
   [equality] sequent [squash] { 'H >- 't_1 = 't_2 in 'T } -->
   [main]  sequent ['ext] { 'H >-  'c_1 = 'c_2 in 'C['t_2] } -->
   [wf] sequent [squash] { 'H; x: 'T; v: 't_1='x in 'T; w: 't_2='x in 'T
                           >- "type"{'C['x]} } -->
   sequent ['ext] { 'H >- 'c_1 = 'c_2 in 'C['t_1] }



(*!
 * @begin[doc]
 *
 * The sequent $@sequent{ext; {H; x@colon S; J[x]}; t[x] @in T}$
 * actually means not only that $t[x] @in T$ for any $x @in S$, but also
 * it means @emph{functionality}, i.e. for any two equal elements $s_1$, $s_2$ of $S$
 * $t[s_1]$ and $t[s_2]$ should be equal in $T$.
 *
 * The following rule states this explicitly.
 * @end[doc]
 *)


interactive cutEq 'H ('s_1='s_2 in 'S) bind{x.'t_1['x] = 't_2['x] in 'T['x] } 'v 'u :
   [assertion] sequent[squash]{ 'H >- 's_1='s_2 in 'S } -->
   [main]      sequent ['ext] { 'H; x: 'S; v: 's_1='x in 'S; u: 's_2='x in 'S >- 't_1['x] = 't_2['x] in 'T['x] } -->
   sequent ['ext] { 'H >- 't_1['s_1] = 't_2['s_2] in 'T['s_1]}



(*!
 * @begin[doc]
 *
 * The @tt{assertEqT} tactic applies this rule.
 * This tactic takes a term $s1=s2 @in S$ as an argument
 * and a term $<<bind{x.'t['x]}>>$ as an optional with-argument.
 * This tactic helps us to prove an equality from a membership.
 *
 * @end[doc]
 *)


(*!
 * @begin[doc]
 *
 * The @tt{cutSquash} rule is similar to the @hrefrule[cut] rule.
 * If we prove $S$, but do not show the extract term, then we can assert
 * $S$ as a @emph{squashed} hypothesis, that is we are not allow to use its extract
 * (see @hrefmodule[Itt_squash]).
 * @end[doc]
 *)


interactive cutSquash 'H 'J 'S 'x :
   [assertion] sequent [squash] { 'H; 'J >- 'S } -->
   [main]      sequent ['ext] { 'H; x: squash{'S}; 'J >- 'T } -->
   sequent ['ext] { 'H; 'J >- 'T}

(*!
 * @begin[doc]
 * There are two tactics that used this rule: @tt{assertSquashT} and
 * @tt{assertSquashAtT}.
 * They are similar to @hreftactic[assertT] and  @hreftactic[assertAtT].
 * The @tt{assertSquashAtT n S} introduces the lemma $S$ after $n$th hypothesis.
 * The @tt{assertSquashT S} introduces the lemma $S$ at the end
 * of the hypothesis list.
 *
 * @docoff
 * @end[doc]
 *)




(************************************************************************
 * TACTICS                                                              *
 ************************************************************************)

(* substitution *)

let substConclT t p =
   let n = Sequent.hyp_count_addr p in
   let v,w = maybe_new_vars2 p "v" "w" in
   let _, a, _ = dest_equal t in
   let bind =
      try
         let t1 = get_with_arg p in
            if is_xbind_term t1 then
               t1
            else
               raise (RefineError ("substT", StringTermError ("need a \"bind\" term: ", t)))
      with
         RefineError _ ->
            let x = get_opt_var_arg "z" p in
               mk_xbind_term x (var_subst (Sequent.concl p) a x)
   in
   let tac =
      (substitutionInType n t bind v w orelseT substitution2 n t bind v w) thenWT thinIfThinningT [-1;-1]
   in tac p

(*
 * Hyp substitution requires a replacement.
 *)
let substHypT i t p =
   let v,w = maybe_new_vars2 p "v" "w" in
   let _, a, _ = dest_equal t in
   let _, t1 = Sequent.nth_hyp p i in
   let z = get_opt_var_arg "z" p in
   let bind =
      try
         let b = get_with_arg p in
            if is_xbind_term b then
               b
            else
               raise (RefineError ("substT", StringTermError ("need a \"bind\" term: ", b)))
      with
         RefineError _ ->
            mk_xbind_term z (var_subst t1 a z)
   in
   let i, j = Sequent.hyp_indices p i in
     if get_thinning_arg p
       then hypSubstitution i j t bind z p
       else hypSubstitution2  i j t bind z v w p

(*
 * General substition.
 *)


let eqSubstT t i =
   if i = 0 then
      substConclT t
   else
      substHypT i t

let substT t =
   if is_squiggle_term t then
      sqSubstT t
   else
      eqSubstT t


(*
 * Derived versions.
 *)

let hypSubstT i j p =
   let _, h = Sequent.nth_hyp p i in
      (substT h j thenET nthHypT i) p

let revHypSubstT i j p =
   let trm = snd (Sequent.nth_hyp p i) in
   if is_squiggle_term trm then
      let a, b = dest_squiggle trm in
      let h' = mk_squiggle_term  b a in
         (substT h' j thenET (sqSymT thenT nthHypT i)) p
   else
      let t, a, b = dest_equal trm in
      let h' = mk_equal_term t b a in
         (substT h' j thenET (equalSymT thenT nthHypT i)) p



(* cutMem *)

let letT x_is_s_in_S p =
   let v = maybe_new_vars1 p "v"  in
   let i = Sequent.hyp_count_addr p in
   let _S, x, s = dest_equal x_is_s_in_S in
   let xname = dest_var x in
   let bind =
      try
         get_with_arg p
      with
         RefineError _ ->
            let z = get_opt_var_arg xname p in
               mk_xbind_term z (var_subst (Sequent.concl p) s z)
   in
      if is_xbind_term bind then
           (cutMem i xname v s _S bind thenMT thinIfThinningT [-1]) p
      else
           raise (RefineError ("letT", StringTermError ("need a \"bind\" term: ", bind)))


(* cutEq *)

let assertEqT eq p =
   let v,u = maybe_new_vars2 p "v" "u" in
   let _, s1, s2 = dest_equal eq in
   let bind =
      try
         get_with_arg p
      with
         RefineError _ ->
            let x = get_opt_var_arg "z" p in
            let t, t1,  t2 = dest_equal (Sequent.concl p) in
            let t' = var_subst t s1 x in
            let t1' = var_subst t1 s1 x in
            let t2' = var_subst t2 s2 x in
               mk_xbind_term x (mk_equal_term t' t1' t2')
   in
      if is_xbind_term bind then
         (try
            (cutEq  (Sequent.hyp_count_addr p) eq bind v u thenMT thinIfThinningT [-2;-1]) p
          with
                 RefineError _ ->
                    raise (RefineError ("assertEqT", StringTermError (" \"bind\" term: ", bind))))
      else
         raise (RefineError ("assertEqT", StringTermError ("need a \"bind\" term: ", bind)))

(* cutSquash *)

let assertSquashT s p =
   let j, k = Sequent.hyp_split_addr p (Sequent.hyp_count p) in
   let v = maybe_new_vars1 p "v" in
      cutSquash j k s v p

let assertSquashAtT i s p =
   let i, j = Sequent.hyp_split_addr p i in
   let v = get_opt_var_arg "v" p in
      cutSquash i j s v p


