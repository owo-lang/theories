doc <:doc<
   @module[Itt_hoas_normalize]x

   The @tt[Itt_hoas_normalize] module defines a normalization procedure
   for BTerms.

   @docoff
   ----------------------------------------------------------------

   @begin[license]
   This file is part of MetaPRL, a modular, higher order
   logical framework that provides a logical programming
   environment for OCaml and other languages.

   See the file doc/htmlman/default.html or visit http://metaprl.org/
   for more information.

   Copyright (C) 2005, MetaPRL Group

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

   Author: Jason Hickey @email{jyh@cs.caltech.edu}

   @end[license]
   @parents
>>
extends Itt_hoas_lof
extends Itt_hoas_lof_vec

doc docoff

open Lm_printf
open Basic_tactics
open Itt_hoas_base
open Itt_hoas_lof
open Itt_hoas_lof_vec
open Itt_hoas_vbind
open Itt_hoas_vector
open Itt_hoas_debruijn

(************************************************************************
 * Test whether a term has already been normalized.
 * The normalizer is expensive, so this is used to prevent
 * it from running when nothing will happen.
 *
 * Non-normal terms:
 *    1. Nested binds, nested substitutions
 *    2. A mk_term, subst, bind1
 *    3. A mk_bterm within a bind or subst
 *)
type norm_info =
   { norm_bind : bool;
     norm_subst : bool
   }

let empty_info =
   { norm_bind = false;
     norm_subst = false
   }

let rec is_normal_term info t =
   if is_mk_term_term t || is_subst_term t || is_bind_term t then
      false
   else if is_bindn_term t then
      is_normal_bindn_term info t
   else if is_vbind_term t then
      is_normal_vbind_term info t
   else if is_substl_term t then
      is_normal_substl_term info t
   else if is_mk_bterm_term t then
      is_normal_mk_bterm_term info t
   else if is_var_term t then
      false
   else if is_so_var_term t then
      is_normal_so_var_term info t
   else if is_context_term t then
      is_normal_context_term info t
   else if is_sequent_term t then
      is_normal_sequent_term info t
   else
      is_normal_bterm_list info (dest_term t).term_terms

and is_normal_term_list info tl =
   List.for_all (is_normal_term info) tl

and is_normal_bterm info bt =
   is_normal_term info (dest_bterm bt).bterm

and is_normal_bterm_list info btl =
   List.for_all (is_normal_bterm info) btl

and is_normal_bindn_term info t =
   if info.norm_bind then
      false
   else
      let info = { info with norm_bind = true } in
      let _, _, t = dest_bindn_term t in
         is_normal_term info t

and is_normal_vbind_term info t =
   if info.norm_bind then
      false
   else
      let _, t = dest_vbind_term t in
         is_normal_term info t

and is_normal_substl_term info t =
   if info.norm_subst then
      false
   else
      let info = { info with norm_subst = true } in
      let t1, t2 = dest_substl_term t in
         is_normal_term info t1 && is_normal_term info t2

and is_normal_mk_bterm_term info t =
   if info.norm_bind then
      false
   else
      let _, _, t = dest_mk_bterm_term t in
         is_normal_term info t

and is_normal_so_var_term info t =
   let _, _, tl = dest_so_var t in
      is_normal_term_list info tl

and is_normal_context_term info t =
   let _, t, _, tl = dest_context t in
      is_normal_term info t && is_normal_term_list info tl

and is_normal_sequent_term info t =
   let { sequent_args = arg;
         sequent_hyps = hyps;
         sequent_concl = concl
       } = explode_sequent t
   in
      if is_normal_term info arg && is_normal_term info concl then
         SeqHyp.for_all (fun h ->
               match h with
                  Hypothesis (_, t) ->
                     is_normal_term info t
                | Context (_, _, tl) ->
                     is_normal_term_list info tl) hyps
      else
         false

let normalizeCheckC =
   termC (fun t -> (**)
      if is_normal_term empty_info t then
         idC
      else
         raise (RefineError ("Itt_hoas_normalize.normalizeCheckC", StringTermError ("already normalized", t))))

(************************************************************************
 * Tactics.
 *)
doc <:doc<
   The normalization conversion performs the following steps:

   @begin[enumerate]
   @item{{Eliminate all << mk_term{'op; 'subterms} >>.}}
   @item{{Eliminate all << bind{x. 'e['x]} >>.}}
   @item{{Coalesce binds.}}
   @item{{Push binds down.}}
   @item{{Coalesce substitutions.}}
   @end[enumerate]

   The @tt[preNormalizeLofC] conversion performs the first two steps.
   The @tt[reduceLofC] conversion coalesces binds and pushes them down.
   The @tt[reduceLofC] conversion must be run with all @tt[lof] terms
   hoisted as much as possible---it should be run after @tt[normalizeLofC].
   Similarly, the @tt[substl_substl_lof2] conversion should be run after
   @tt[normalizeLofC].
   @docoff
>>
let normalizeBTermAuxC =
   preNormalizeLofC
   thenC normalizeLofC
   thenC reduceLofC
   thenC normalizeLofC
   thenC sweepUpC substl_substl_lof2

doc <:doc<
   Once the binds have all been pushed, use the @tt[rippleLofC] conversion
   to optimize the term.  Afterwards, remove all temporary terms using the
   @tt[lofBindElimC] conversion.
>>
let normalizeBTermForceC =
   normalizeBTermAuxC
   thenC rippleLofC
   thenC reduceC
   thenC sweepUpC lofBindElimC
   thenC sweepUpC lofVBindElimC

let normalizeBTermC =
(*
   normalizeCheckC
   orelseC *) normalizeBTermForceC

(*!
 * @docoff
 *
 * -*-
 * Local Variables:
 * Caml-master: "compile"
 * End:
 * -*-
 *)
