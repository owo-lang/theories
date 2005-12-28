doc <:doc<
   @module[Itt_hoas_normalize]

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

doc docoff

open Lm_printf
open Basic_tactics
open Itt_hoas_lof
open Itt_hoas_vector
open Itt_hoas_debruijn

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
   @docoff
>>

(*
 * Prepare the term by eliminating some of the simpler terms.
 *)
let pre_normalize_term =
   sweepUpC fold_mk_term
   thenC sweepUpC bind_to_lof_bind
   thenC sweepUpC bindn_to_lof_bind
   thenC sweepUpC subst_to_substl

(*
 * Push a bind through a term.
 *)
let push_lof_bind_mk_bterm =
   reduce_lof_bind_mk_bterm
   thenC addrC [Subterm 3] pushLofBindC

let normalizeBTermAuxC =
   pre_normalize_term
   thenC sweepUpC coalesce_bindC
   thenC normalizeLofC
   thenC sweepDnC push_lof_bind_mk_bterm
   thenC sweepUpC substl_substl_lof2

let normalizeBTermC =
   normalizeBTermAuxC
   thenC reduceLofC
   thenC sweepDnC lofBindElimC

(*!
 * @docoff
 *
 * -*-
 * Local Variables:
 * Caml-master: "compile"
 * End:
 * -*-
 *)
