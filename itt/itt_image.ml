doc <:doc<
   @module[Itt_image]

   The @tt{Itt_image} adds a new type constructor <<Img{'A; x.'f['x]}>> with the
   following semantics:

   If $A$ is a type with a PER $P_a$, then <<Img{'A; x.'f['x]}>> is a type with the
   the PER Transitive closure$(@iff{<<'f['a]='f['b] in Img{'A; x.'f['x]}>>; <<'a='b in 'A>>})$

   @docoff
   ----------------------------------------------------------------

   @begin[license]

   This file is part of MetaPRL, a modular, higher order
   logical framework that provides a logical programming
   environment for OCaml and other languages.

   See the file doc/htmlman/default.html or visit http://metaprl.org/
   for more information.

   Copyright (C) 2005 MetaPRL Group

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

   Author: Aleksey Nogin
   @email{nogin@cs.caltech.edu}

   @end[license]
>>

doc <:doc<
   @parents
>>
extends Base_theory
extends Itt_equal
extends Itt_squash
extends Itt_subset
doc docoff
extends Itt_comment

open Basic_tactics
open Itt_equal
open Itt_struct

doc terms

declare Img{'A; x.'f['x]}

doc <:doc<
   @rules
   <<Img{'A; x.'f['x]}>> is a type when $A$ is a type and $f$ is closed,
>>

prim img_type {| intro [] |}:
   sequent { <H> >- 'A Type } -->
   sequent { <H> >- Img{'A; x.'f<||>['x]} Type } = it

prim img_univ {| intro [] |}:
   sequent { <H> >- 'A in univ[i:l] } -->
   sequent { <H> >- Img{'A; x.'f<||>['x]} in univ[i:l] } = it

interactive img_univ_eq {| intro [] |}:
   sequent { <H> >- 'A = 'B in univ[i:l] } -->
   sequent { <H> >- Img{'A; x.'f<||>['x]} = Img{'B; x.'f<||>['x]} in univ[i:l] }

doc <:doc<
   The elements of <<Img{'A; x.'f['x]}>> are $f[a]$ for <<'a in 'A>>.
>>
prim img_mem 'a :
   sequent { <H> >- 'a in 'A } -->
   sequent { <H> >- 'f['a] in Img{'A; x.'f<||>['x]} } = it

interactive img_eq 'a 'b :
   sequent { <H> >- 'a = 'b in 'A } -->
   sequent { <H> >- 'f['a] = 'f['b] in Img{'A; x.'f<||>['x]} }

doc docoff

let img_opname = opname_of_term <<Img{'A; x.'f['x]}>>
let dest_img_term = dest_dep0_dep1_term img_opname

let img_introT = funT (fun p ->
   let t = concl p in
   let img, fa, fb = dest_equal t in
   let x, _, fx = dest_img_term img in
      match find_subterm fx (fun t _ -> is_var_term t && Lm_symbol.eq (dest_var t) x) with
         [] -> raise (RefineError("Itt_image.img_introT: not applicable", TermError img))
       | addr :: _ ->
             img_eq (term_subterm fa addr) (term_subterm fb addr))

let resource intro += (<< 'a = 'b in Img{'A; x.'f<||>['x]} >>, wrap_intro img_introT)

doc <:doc<   >>

prim img_elim {| elim [ThinOption thinT] |} 'H :
   sequent { <H>; y: Img{'A; x.'f<||>['x]}; <J['y]>; a: 'A >- squash{'C['f['a]]} } -->
   sequent { <H>; y: Img{'A; x.'f<||>['x]}; <J['y]> >- squash{'C['y]} } = it

interactive img_elim2 {| elim [ThinOption thinT] |} 'H :
   sequent { <H>; y: Img{'A; x.'f<||>['x]}; <J['y]>; a: 'A >- 't1['f['a]] = 't2['f['a]] in 'T['f['a]] } -->
   sequent { <H>; y: Img{'A; x.'f<||>['x]}; <J['y]> >- 't1['y] = 't2['y] in 'T['y] }

doc <:doc<
   When $f$ is squiggle-reversible, we can have elimination for non-squash-stable goals.
>>
extends Itt_squiggle
extends Itt_dfun
extends Itt_struct2

interactive img_elim3 {| elim [ThinOption thinT] |} 'H 'g :
   sequent { <H>; y: Img{'A; x.'f<||>['x]}; <J['y]>; a: 'A >- 'g 'f['a] ~ 'a } -->
   sequent { <H>; y: Img{'A; x.'f<||>['x]}; <J['y]>; a: 'A >- 'C['f['a]] } -->
   sequent { <H>; y: Img{'A; x.'f<||>['x]}; <J['y]> >- 'C['y] }

interactive img_monotone {| intro[] |} :
   sequent { <H> >-  'A_1 subtype 'A_2 } -->
   sequent { <H> >-  Img{'A_1; x.'f<||>['x]} subtype  Img{'A_2; x.'f<||>['x]} }

interactive img_monotone_subset {| intro[] |} bind{x.'g['x]}:
   sequent { <H>; x:'A_2 >- 'g['f<||>['x]]='x in 'A_2 } -->
   sequent { <H> >-  'A_1 subset 'A_2 } -->
   sequent { <H> >-  Img{'A_1; x.'f<||>['x]} subset  Img{'A_2; x.'f<||>['x]} }

doc docoff

dform img_df : Img{'A; x.'f} =
   pushm[0] szone pushm[3] `"Img(" 'x `":" slot{'A} `"." slot{'f} popm `")" ezone popm
