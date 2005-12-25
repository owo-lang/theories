doc <:doc<
   @module[Itt_hoas_vbind]
   The @tt[Itt_hoas_vbind] module defines a ``vector binding''
   using context notation.  We define a conversion to Itt_vec_bind.mk_vbind.

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

extends Itt_vec_bind
extends Itt_hoas_base
extends Meta_extensions_theory

doc docoff

open Basic_tactics
open Itt_squiggle
open Itt_struct

doc <:doc<
   @terms

   The << vbind{| <J> >- 'C |} >> is a ``vector binding'' with binders
   @code{<J>} and body << 'C >>.  The actual values of the hypotheses
   do not matter.
>>
declare sequent [vbind] { Term : Term >- Term } : Term

prim_rw unfold_vbind : vbind{| <J> >- 'C |} <-->
   sequent_ind{u, v. bind{x. happly{'v; 'x}}; TermSequent{| <J> >- 'C |}}

interactive_rw reduce_vbind_nil {| reduce |} :
   vbind{| >- 'C |}
   <-->
   'C

interactive_rw reduce_vbind_left :
   vbind{| x: 'A; <J['x]> >- 'C['x] |}
   <-->
   bind{x. vbind{| <J['x]> >- 'C['x] |}}

interactive_rw reduce_vbind_right :
   vbind{| <J>; x: 'A >- 'C['x] |}
   <-->
   vbind{| <J> >- bind{x. 'C['x]} |}

(*
 * VBind wrapping (for induction).
 *)
let mk_empty_vbind_term t =
   <:con< sequent [vbind] { >- $t$ } >>

let wrap_vbind p =
   let t = concl p in
   let t1, t2 = dest_squiggle t in
   let t1 = mk_empty_vbind_term t1 in
   let t2 = mk_empty_vbind_term t2 in
   let t = mk_squiggle_term t1 t2 in
      assertT t
      thenLT [idT; rw (addrC [Subterm 1] reduceTopC thenC addrC [Subterm 2] reduceTopC) (-1) thenT nthHypT (-1)]

let wrapVBindT = funT wrap_vbind

(*!
 * @docoff
 *
 * -*-
 * Local Variables:
 * Caml-master: "compile"
 * End:
 * -*-
 *)