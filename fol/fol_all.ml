(*
 * Universal quantifier.
 *)

extends Fol_implies
extends Fol_struct
extends Fol_pred

open Basic_tactics
open Fol_struct

(************************************************************************
 * TERMS                                                                *
 ************************************************************************)

declare "all"{x. 'B['x]}

(************************************************************************
 * DISPLAY                                                              *
 ************************************************************************)

prec prec_all

dform all_df : parens :: "prec"["prec_all"] :: "all"{x. 'B} =
   szone pushm[3] forall slot{'x} `"." hspace slot{'B} popm ezone

(************************************************************************
 * RULES                                                                *
 ************************************************************************)

prim all_type {| intro [] |} :
   [wf] sequent { <H>; x: pred >- "type"{'B['x]} } -->
   sequent { <H> >- "type"{."all"{y. 'B['y]}} } = trivial

prim all_intro {| intro [] |} :
   [main] ('b['x] : sequent { <H>; x: pred >- 'B['x] }) -->
   [wf] sequent { <H>; x: pred >- "type"{'B['x]} } -->
   sequent { <H> >- "all"{y. 'B['y]} } =
   lambda{y. 'b['y]}

prim all_elim {| elim [ThinOption thinT] |} 'H 'a :
   [wf] sequent { <H>; x: "all"{y. 'B['y]}; <J['x]> >- "type"{'a} } -->
   [wf] sequent { <H>; x: "all"{y. 'B['y]}; <J['x]>; z: pred >- "type"{'B['z]} } -->
   [main] ('b['x; 'z] : sequent { <H>; x: "all"{y. 'B['y]}; <J['x]>; z: 'B['a] >- 'C['x] }) -->
   sequent { <H>; x: "all"{y. 'B['y]}; <J['x]> >- 'C['x] } =
   'b['x; 'x 'a]

(*
 * -*-
 * Local Variables:
 * Caml-master: "pousse"
 * End:
 * -*-
 *)
