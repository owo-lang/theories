doc <:doc<
   Native sequent representation, based on Itt_vec_sequent_term.fsequent.

   ----------------------------------------------------------------

   @begin[license]
   Copyright (C) 2005 Mojave Group, Caltech

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

   Author: Jason Hickey
   @email{jyh@cs.caltech.edu}
   @end[license]

   @parents
>>
extends Itt_vec_bind
extends Itt_vec_list1
extends Itt_vec_sequent_term
extends Itt_hoas_vbind
extends Itt_hoas_sequent
extends Itt_hoas_proof
extends Itt_theory
extends Itt_match

doc docoff

open Basic_tactics
open Itt_list2
open Itt_vec_sequent_term

(************************************************************************
 * Itt_vec_bind --> Itt_hoas_vbind conversion.
 *)
doc <:doc<
   Define a conversion from @tt[Itt_vec_bind] terms to BTerms.
>>
define unfold_bterm_of_vterm :
   bterm_of_vterm{'e}
   <-->
   fix{f. lambda{e. dest_bind{'e; bind{x. 'f bind_subst{'e; 'x}}; e. 'e}}} 'e

interactive_rw reduce_bterm_of_mk_bind {| reduce |} :
   bterm_of_vterm{mk_bind{x. 'e['x]}}
   <-->
   bind{x. bterm_of_vterm{'e['x]}}

interactive_rw reduce_bterm_of_mk_core {| reduce |} :
   bterm_of_vterm{mk_core{'e}}
   <-->
   'e

interactive_rw reduce_bterm_of_mk_vbind {| reduce |} :
   bterm_of_vterm{mk_vbind{| <J> >- 'C |}}
   <-->
   vbind{| <J> >- bterm_of_vterm{'C} |}

interactive_rw reduce_bterm_of_mk_vbind_mk_core {| reduce |} :
   bterm_of_vterm{mk_vbind{| <J> >- mk_core{'C} |}}
   <-->
   vbind{| <J> >- 'C |}

(************************************************************************
 * hyps_bterms.
 *)
doc <:doc<
   Convert all the hypotheses in a list to their BTerm equivalents.
>>
define unfold_hyps_bterms : hyps_bterms{'l} <--> <:xterm<
   map{t. bterm_of_vterm{t}; l}
>>

interactive_rw reduce_hyps_bterms_nil {| reduce |} : <:xrewrite<
   hyps_bterms{[]}
   <-->
   []
>>

interactive_rw reduce_hyps_bterms_cons {| reduce |} : <:xrewrite<
   hyps_bterms{u::v}
   <-->
   bterm_of_vterm{u} :: hyps_bterms{v}
>>

interactive_rw reduce_hyps_bterms_append {| reduce |} : <:xrewrite<
   l1 IN "list" -->
   hyps_bterms{append{l1; l2}}
   <-->
   append{hyps_bterms{l1}; hyps_bterms{l2}}
>>

doc <:doc<
   The << hyp_term{| <J> >- 'A |} >> term represents a single
   BTerm hypothesis.  The << hyp_context{| <J> >- hyplist{| <K> |} |} >>
   term represents a context in the scope of @code{<J>} binders.
>>
declare sequent [hyp_term] { Term : Term >- Term } : Term

prim_rw unfold_hyp_term : hyp_term{| <J> >- 'A |} <--> <:xterm<
   ["vbind"{| <J> >- A |}]
>>

declare sequent [hyp_context] { Term : Term >- Term } : Term

prim_rw unfold_hyp_context : hyp_context{| <J> >- 'A |} <--> <:xterm<
   hyps_bterms{hyps_flatten{"mk_vbind"{| <J> >- mk_core{A} |}}}
>>

interactive_rw reduce_hyps_bterms_hyplist_simple {| reduce |} : <:xrewrite<
   hyps_bterms{"hyplist"{| <K> |}}
   <-->
   "hyp_context"{| >- "hyplist"{| <K> |} |}
>>

interactive_rw reduce_hyps_bterms_hyplist {| reduce |} : <:xrewrite<
   hyps_bterms{hyps_flatten{"mk_vbind"{| <J> >- mk_core{"hyplist"{| <K> |}} |}}}
   <-->
   "hyp_context"{| <J> >- "hyplist"{| <K> |} |}
>>

doc <:doc<
   Conversions from the original representation to the BTerm
   representation.
>>
interactive_rw reduce_hyps_bterms_mk_vbind {| reduce |} : <:xrewrite<
   hyps_bterms{["mk_vbind"{| <J> >- mk_core{A} |}]}
   <-->
   "hyp_term"{| <J> >- A |}
>>

(************************************************************************
 * Flattened form of the sequent.
 *)
doc <:doc<
   Form the flattened vector form of the sequent from the original triple.
>>
declare sequent [vsequent{'arg}] { Term : Term >- Term } : Term

prim_rw unfold_vsequent : vsequent{'arg}{| <J> >- 'C |} <--> <:xterm<
   "sequent"{arg; "vflatten"{| <J> |}; "vsubst_dummy"{| <J> >- C |}}
>>

define unfold_vsequent_of_triple : vsequent_of_triple{'e} <--> <:xterm<
   let arg, hyps, concl = e in
      vsequent{arg}{| hyps_bterms{hyps} >- bterm_of_vterm{concl} |}
>>

interactive_rw reduce_vsequent_of_triple {| reduce |} : <:xrewrite<
   vsequent_of_triple{(a, (b, c))}
   <-->
   vsequent{a}{| hyps_bterms{b} >- bterm_of_vterm{c} |}
>>

(*
 * Flattening append.
 *)
interactive_rw reduce_vsequent_append 'J : <:xrewrite<
   l1 IN "list" -->
   l2 IN "list" -->
   vsequent{arg}{| <J>; append{l1<||>; l2<||>}; <K> >- C |}
   <-->
   vsequent{arg}{| <J>; l1; l2; <K> >- C |}
>>

(************************************************************************
 * Bsequent.
 *)
doc <:doc<
   The << bsequent{'arg}{| <J> >- 'C |} >> is a << Sequent >> interpretation
   of the original sequent.
>>
prim_rw unfold_bsequent : <:xrewrite<
   "bsequent"{arg}{| <J> >- C |}
   <-->
   vsequent_of_triple{"fsequent"{arg}{| <J> >- C |}}
>>

(************************************************************************
 * Provable.
 *)
doc <:doc<
   The << provable_sequent{'ty; 'logic; 'arg}{| <J> >- 'C |} >> term specifies
   that the sequent is provable in the logic.

   This is the flattened form.
>>
declare sequent [provable_sequent{'syntax; 'logic; 'arg}] { Term : Term >- Term } : Term

prim_rw unfold_provable_sequent : <:xrewrite<
   provable_sequent{syntax; logic; arg}{| <J> >- C |}
   <-->
      Provable{"Sequent"; syntax; vsequent{arg}{| <J> >- C |}}
   && Provable{"Sequent"; logic; vsequent{arg}{| <J> >- C |}}
>>

doc <:doc<
   The << ProvableSequent{'ty; 'logic; 'arg}{| <J> >- 'C |} >> term specifies
   that the sequent is provable in the logic.

   This is the original dependent form.
>>
declare sequent [ProvableSequent{'syntax; 'logic; 'arg}] { Term : Term >- Term } : Term

prim_rw unfold_ProvableSequent : <:xrewrite<
   ProvableSequent{syntax; logic; arg}{| <J> >- C |}
   <-->
      Provable{"Sequent"; syntax; bsequent{arg}{| <J> >- C |}}
   && Provable{"Sequent"; logic; bsequent{arg}{| <J> >- C |}}
>>

(************************************************************************
 * Well-formedness.
 *)
doc <:doc<
   Well-formedness reasoning.
>>
interactive hyp_term_wf {| intro [] |} : <:xrule<
   <H> >- "hyp_term"{| <J> >- A |} IN "list"
>>

interactive hyps_bterms_wf {| intro [] |} : <:xrule<
   "wf" : <H> >- l IN "list" -->
   <H> >- hyps_bterms{l} IN "list"
>>

interactive hyp_context_wf {| intro [] |} : <:xrule<
   <H> >- "hyp_context"{| <J> >- "hyplist"{| <K> |} |} IN "list"
>>

(************************************************************************
 * Well-formedness of vsequents.
 *)
doc <:doc<
   Well-formedness of sequent terms.
>>
interactive vsequent_wf {| intro [] |} : <:xrule<
   "wf" : <H> >- arg IN BTerm{0} -->
   "wf" : <H> >- "vflatten"{| <J> |} IN CVar{length{"vflatten"{| |}}} -->
   "wf" : <H> >- C IN BTerm{length{"vflatten"{| <J> |}}} -->
   <H> >- vsequent{arg}{| <J> >- C<|H|> |} IN Itt_hoas_sequent!Sequent
>>

interactive vflatten_hyp_concl_wf {| intro [] |} : <:xrule<
   "wf" : <H> >- d IN "nat" -->
   <H> >- "vflatten"{| |} IN CVar{d}
>>

interactive vflatten_hyp_left_wf {| intro [] |} : <:xrule<
   "wf" : <H> >- "vlist"{| <K> |} IN list{"list"} -->
   "wf" : <H> >- A IN CVar{length{"vflatten"{| <K> |}}} -->
   "wf" : <H> >- "vflatten"{| <J["it"]> |} IN CVar{length{"vflatten"{| <K>; x: A |}}} -->
   <H> >- "vflatten"{| x: A; <J[x]> |} IN CVar{length{"vflatten"{| <K> |}}}
>>

(************************************************************************
 * Tactics.
 *)
let fold_bterm_of_vterm = makeFoldC << bterm_of_vterm{'e} >> unfold_bterm_of_vterm
let fold_provable_sequent = makeFoldC << provable_sequent{'ty; 'logic; 'arg}{| <J> >- 'C |} >> unfold_provable_sequent
let fold_hyp_term = makeFoldC << hyp_term{| <J> >- 'A |} >> unfold_hyp_term
let fold_hyp_context = makeFoldC << hyp_context{| <J> >- 'A |} >> unfold_hyp_context

let hyps_bterms_term = << hyps_bterms{'e} >>
let hyps_bterms_opname = opname_of_term hyps_bterms_term
let dest_hyps_bterms_term = dest_dep0_term hyps_bterms_opname

(*
 * Reduce the bsequent.
 *)
let rec reduce_hyps t =
   let a = dest_hyps_bterms_term t in
      if is_append_term a then
         reduce_hyps_bterms_append
         thenC (addrC [Subterm 1] (termC reduce_hyps))
         thenC (addrC [Subterm 2] (termC reduce_hyps))
      else
         reduce_hyps_bterms_hyplist_simple
         orelseC reduce_hyps_bterms_mk_vbind
         orelseC reduce_hyps_bterms_hyplist

let reduce_bsequent =
   unfold_bsequent
   thenC (addrC [Subterm 1] reduce_fsequent)
   thenC reduce_vsequent_of_triple
   thenC (addrC [ClauseAddr 1] (termC reduce_hyps))
   thenC (addrC [ClauseAddr 0] reduce_bterm_of_mk_vbind_mk_core)
   thenC (repeatC (reduce_vsequent_append 1))

let reduce_ProvableSequent =
   unfold_ProvableSequent
   thenC (addrC [Subterm 3] reduce_bsequent)
   thenC fold_provable_sequent

(************************************************************************
 * Tests.
 *)
interactive bsequent_test_intro1 : <:xrule<
   <H> >- bsequent{it}{| <J> >- 1 +@ 2 |} IN "top"
>>

interactive bsequent_test_elim1 'J : <:xrule<
   <H> >- bsequent{it}{| <J>; x: A; <K[x]> >- 1 +@ 2 |} IN "top"
>>

interactive provable_sequent_test_elim1 'J : <:xrule<
   <H> >- ProvableSequent{syntax; logic; it}{| <J>; x: A; <K[x]> >- 1 +@ 2 |}
>>

(*!
 * @docoff
 *
 * -*-
 * Local Variables:
 * Caml-master: "compile"
 * End:
 * -*-
 *)