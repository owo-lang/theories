(*!
 * @begin[doc]
 * @module[Itt_pairwise]
 * @parents
 * @end[doc]
 *)

extends Itt_subtype
extends Itt_pairwise

open Basic_tactics

(*! @docoff *)

interactive supertype 'H 'B:  (* Can't prove it because of the BUG #3.14 *)
   sequent  { <H>; x:'A; <J['x]> >- 'A subtype 'B} -->
   sequent  { <H>; x:'B; <J['x]> >- 'T['x]} -->
   sequent  { <H>; x:'A; <J['x]> >- 'T['x]}

interactive supertypeHyp 'H 'K:
   sequent  { <H>; 'A subtype 'B; <K>; x:'B; <J['x]> >- 'T['x]} -->
   sequent  { <H>; 'A subtype 'B; <K>; x:'A; <J['x]> >- 'T['x]}

