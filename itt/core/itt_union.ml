doc <:doc<
   @spelling{handedness}
   @module[Itt_union]

   The union type $T_1 + T_2$ defines a union space containing the
   elements of both $T_1$ and $T_2$.  The union is @emph{disjoint}: the
   elements are @emph{tagged} with the @hrefterm[inl] and @hrefterm[inr]
   tags as belonging to the ``left'' type $T_1$ or the ``right'' type
   $T_2$.

   The union type is the first primitive type that can have more than one
   element.  The tag makes the handedness of membership decidable, and
   the union type $@unit + @unit$ contains two elements: <<inl{it}>> and
   <<inr{it}>>.  The @hrefmodule[Itt_bool] module uses this definition to
   define the Boolean values, where @emph{false} is <<inl{it}>> and
   @emph{true} is <<inr{it}>>.

   @docoff
   ----------------------------------------------------------------

   @begin[license]

   This file is part of MetaPRL, a modular, higher order
   logical framework that provides a logical programming
   environment for OCaml and other languages.

   See the file doc/htmlman/default.html or visit http://metaprl.org/
   for more information.

   Copyright (C) 1997-2006 MetaPRL Group, Cornell University and
   California Institute of Technology

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

   Author: Jason Hickey @email{jyh@cs.cornell.edu}
   Modified by: Aleksey Nogin @email{nogin@cs.caltech.edu}

   @end[license]
>>

doc <:doc< @parents >>
extends Itt_void
extends Itt_equal
extends Itt_struct
extends Itt_subtype
doc docoff

open Unify_mm

open Basic_tactics

open Itt_equal
open Itt_subtype

(************************************************************************
 * TERMS                                                                *
 ************************************************************************)

doc <:doc<
   @terms

   The @tt{union} type is the binary union of two types $A$ and $B$.
   The elements are $@inl{a}$ for $a @in A$ and $@inr{b}$ for $b @in B$.
   The @tt{decide} term @emph{decides} the handedness of the term $x @in A + B$.
>>
declare \union{'A; 'B}
declare inl{'x}
declare inr{'x}
declare decide{'x; y. 'a['y]; z. 'b['z]}

declare undefined

define unfold_outl: outl{'x} <--> decide{'x; y. 'y; z. undefined}
define unfold_outr: outr{'x} <--> decide{'x; y. undefined; z. 'z}
define unfold_out: out{'x} <--> decide{'x; y. 'y; z. 'z}

(************************************************************************
 * REWRITES                                                             *
 ************************************************************************)

doc <:doc<
   @rewrites

   The following two rules define the computational behavior of the
   @hrefterm[decide] term.  There are two reductions, the @tt{reduceDecideInl}
   rewrite describes reduction of @tt{decide} on the @hrefterm[inl] term,
   and @tt{reduceDecideInr} describes reduction on the @hrefterm[inr] term.
   The rewrites are added to the @hrefconv[reduceC] resource.

>>

prim_rw reduceDecideInl {| reduce |} : decide{inl{'x}; u. 'l['u]; v. 'r['v]} <--> 'l['x]
prim_rw reduceDecideInr {| reduce |} : decide{inr{'x}; u. 'l['u]; v. 'r['v]} <--> 'r['x]


interactive_rw reduce_outl_inl {| reduce |} :  outl{inl{'x}} <--> 'x

interactive_rw reduce_outr_inr {| reduce |} :  outr{inr{'x}} <--> 'x

interactive_rw reduce_out_inl {| reduce |} :  out{inl{'x}} <--> 'x

interactive_rw reduce_out_inr {| reduce |} :  out{inr{'x}} <--> 'x

doc docoff

(************************************************************************
 * DISPLAY FORMS                                                        *
 ************************************************************************)

prec prec_inl
prec prec_union

dform union_df : except_mode[src] :: parens :: "prec"[prec_union] :: \union{'A; 'B} =
   slot{'A} " " `"+" " " slot{'B}

dform inl_df : except_mode[src] :: parens :: "prec"[prec_inl] :: inl{'a} =
   `"inl" " " slot{'a}

dform inr_df : except_mode[src] :: parens :: "prec"[prec_inl] :: inr{'a} =
   `"inr" " " slot{'a}

dform decide_df : except_mode[src] :: decide{'x; y. 'a; z. 'b} =
   pushm[1] szone pushm[3] keyword["match"] " " slot{'x} " " keyword["with"] hspace
   pushm[3] `"inl " 'y `" -> " slot{'a} popm popm hspace
   `"| " pushm[3] `"inr " 'z `" -> " slot{'b} popm ezone popm

(************************************************************************
 * RULES                                                                *
 ************************************************************************)

doc <:doc<
   @rules
   @modsubsection{Typehood and equality}

   The equality of the @hrefterm[union] type is intensional; the
   union $A + B$ is a type if both $A$ and $B$ are types.
>>
prim unionEquality {| intro [] |} :
   [wf] sequent { <H> >- 'A1 = 'A2 in univ[i:l] } -->
   [wf] sequent { <H> >- 'B1 = 'B2 in univ[i:l] } -->
   sequent { <H> >- 'A1 + 'B1 = 'A2 + 'B2 in univ[i:l] } =
   it

(*
 * Typehood.
 *)
prim unionType {| intro [] |} :
   [wf] sequent { <H> >- "type"{'A} } -->
   [wf] sequent { <H> >- "type"{'B} } -->
   sequent { <H> >- "type"{'A + 'B} } =
   it

doc <:doc<
   @modsubsection{Membership}

   The following two rules define membership, $@inl{a} @in A + B$
   if $a @in A$ and $@inr{b} @in A + B$ if $b @in B$.  Both
   $A$ and $B$ must be types.
>>
prim inlEquality {| intro [] |} :
   [wf] sequent { <H> >- 'a1 = 'a2 in 'A } -->
   [wf] sequent { <H> >- "type"{'B} } -->
   sequent { <H> >- inl{'a1} = inl{'a2} in 'A + 'B } =
   it

(*
 * H >- inr b1 = inr b2 in A + B
 * by inrEquality
 * H >- b1 = b2 in B
 * H >- A = A in Ui
 *)
prim inrEquality {| intro [] |} :
   [wf] sequent { <H> >- 'b1 = 'b2 in 'B } -->
   [wf] sequent { <H> >- "type"{'A} } -->
   sequent { <H> >- inr{'b1} = inr{'b2} in 'A + 'B } =
   it

doc <:doc<
   @modsubsection{Introduction}

   The union type $A + B$ is true if both $A$ and $B$ are types,
   and either 1) $A$ is provable, or 2) $B$ is provable.  The following
   two rules are added to the @hreftactic[dT] tactic.  The application
   uses the @hreftactic[selT] tactic to choose the handedness; the
   @tt{inlFormation} rule is applied with the tactic @tt{selT 1 (dT 0)}
   and the @tt{inrFormation} is applied with @tt{selT 2 (dT 0)}.
>>
interactive inlFormation {| intro [SelectOption 1] |} :
   [main] sequent { <H> >- 'A } -->
   [wf] sequent { <H> >- "type"{'B} } -->
   sequent { <H> >- 'A + 'B }

(*
 * H >- A + B ext inl a
 * by inrFormation
 * H >- B
 * H >- A = A in Ui
 *)
interactive inrFormation {| intro [SelectOption 2] |} :
   [main] ('b : sequent { <H> >- 'B }) -->
   [wf] sequent { <H> >- "type"{'A} } -->
   sequent { <H> >- 'A + 'B }

doc <:doc<
   @modsubsection{Elimination}

   The handedness of the union membership is @emph{decidable}.  The
   elimination rule performs a case analysis in the assumption $x@colon A + B$;
   the first for the @tt{inl} case, and the second for the @tt{inr}.  The proof
   extract term is the @tt{decide} combinator (which performs a decision
   on element membership).
>>
prim unionElimination {| elim |} 'H :
   [left] ('left['u] : sequent { <H>; u: 'A; <J[inl{'u}]> >- 'T[inl{'u}] }) -->
   [right] ('right['v] : sequent { <H>; v: 'B; <J[inr{'v}]> >- 'T[inr{'v}] }) -->
   sequent { <H>; x: 'A + 'B; <J['x]> >- 'T['x] } =
   decide{'x; u. 'left['u]; v. 'right['v]}

doc <:doc<
   @modsubsection{Combinator equality}

   The @tt{decide} term equality is true if there is @emph{some} type
   $A + B$ for which all the subterms are equal.
>>
prim decideEquality {| intro [] |} bind{z. 'T['z]} ('A + 'B) :
   [wf] sequent { <H> >- 'e1 = 'e2 in 'A + 'B } -->
   [wf] sequent { <H>; u: 'A; 'e1 = inl{'u} in 'A + 'B >- 'l1['u] = 'l2['u] in 'T[inl{'u}] } -->
   [wf] sequent { <H>; v: 'B; 'e1 = inr{'v} in 'A + 'B >- 'r1['v] = 'r2['v] in 'T[inr{'v}] } -->
   sequent { <H> >- decide{'e1; u1. 'l1['u1]; v1. 'r1['v1]} =
                    decide{'e2; u2. 'l2['u2]; v2. 'r2['v2]} in
                    'T['e1] } =
   it

doc <:doc<
   @modsubsection{Subtyping}

   The union type $A_1 + A_2$ is a subtype of type $A_2 + B_2$ if
   $A_1 @subseteq A_2$ and $B_1 @subseteq B_2$.  This rule is added
   to the @hrefresource[subtype_resource].
>>
interactive unionSubtype {| intro [] |} :
   ["subtype"] sequent { <H> >- 'A1 subtype 'A2 } -->
   ["subtype"] sequent { <H> >- 'B1 subtype 'B2 } -->
   sequent { <H> >- 'A1 + 'B1 subtype 'A2 + 'B2  }

doc <:doc<
   @modsubsection{Contradiction lemmas}

   An @tt[inl] can not be equal to @tt[inr].
>>
interactive unionContradiction1 {| elim []; nth_hyp |} 'H :
   sequent { <H>; x: inl{'y} = inr{'z} in 'A+'B; <J['x]> >- 'C['x] }

interactive unionContradiction2 {| elim []; nth_hyp |} 'H :
   sequent { <H>; x: inr{'y} = inl{'z} in 'A+'B; <J['x]> >- 'C['x] }

doc docoff
(*
 * H >- Ui ext A + B
 * by unionFormation
 * H >- Ui ext A
 * H >- Ui ext B
 *)
interactive unionFormation :
   sequent { <H> >- univ[i:l] } -->
   sequent { <H> >- univ[i:l] } -->
   sequent { <H> >- univ[i:l] }

(************************************************************************
 * PRIMITIVES                                                           *
 ************************************************************************)

let union_term = << 'A + 'B >>
let union_opname = opname_of_term union_term
let is_union_term = is_dep0_dep0_term union_opname
let dest_union = dest_dep0_dep0_term union_opname
let mk_union_term = mk_dep0_dep0_term union_opname

let inl_term = << inl{'x} >>
let inl_opname = opname_of_term inl_term
let is_inl_term = is_dep0_term inl_opname
let dest_inl = dest_dep0_term inl_opname
let mk_inl_term = mk_dep0_term inl_opname

let inr_term = << inr{'x} >>
let inr_opname = opname_of_term inr_term
let is_inr_term = is_dep0_term inr_opname
let dest_inr = dest_dep0_term inr_opname
let mk_inr_term = mk_dep0_term inr_opname

let decide_term = << decide{'x; y. 'a['y]; z. 'b['z]} >>
let decide_opname = opname_of_term decide_term
let is_decide_term = is_dep0_dep1_dep1_term decide_opname
let dest_decide = dest_dep0_dep1_dep1_term decide_opname
let mk_decide_term = mk_dep0_dep1_dep1_term decide_opname

(************************************************************************
 * TYPE INFERENCE                                                       *
 ************************************************************************)

let resource typeinf += (union_term, infer_univ_dep0_dep0 dest_union)

let tr_var = Lm_symbol.add "T-r"
let tl_var = Lm_symbol.add "T-l"

(*
 * Type of inl.
 *)
let inf_inl inf consts decls eqs opt_eqs defs t =
   let a = dest_inl t in
   let eqs', opt_eqs', defs', a' = inf consts decls eqs opt_eqs defs a in
   let b = Typeinf.vnewname consts defs' tr_var in
       eqs', opt_eqs', ((b,<<void>>)::defs') , mk_union_term a' (mk_var_term b)

let resource typeinf += (inl_term, inf_inl)

(*
 * Type of inr.
 *)
let inf_inr inf consts decls eqs opt_eqs defs t =
   let a = dest_inl t in
   let eqs', opt_eqs', defs', a' = inf consts decls eqs opt_eqs defs a in
   let b = Typeinf.vnewname consts defs' tl_var in
       eqs', opt_eqs', ((b,<<void>>)::defs') , mk_union_term (mk_var_term b) a'

let resource typeinf += (inr_term, inf_inr)

(*
 * Type of decide.
 *)
let inf_decide inf consts decls eqs opt_eqs defs t =
   let e, x, a, y, b = dest_decide t in
   let eqs', opt_eqs', defs', e' = inf consts decls eqs opt_eqs defs e in
   let consts = SymbolSet.add (SymbolSet.add consts x) y in
   let l = Typeinf.vnewname consts defs' tl_var in
   let l' = mk_var_term l in
   let r = Typeinf.vnewname consts defs' tr_var in
   let r' = mk_var_term r in
   let eqs'', opt_eqs'', defs'', a' =
      inf consts ((x, l')::decls)
          (eqnlist_append_eqn eqs' e' (mk_union_term l' r')) opt_eqs'
          ((l,Itt_void.top_term)::(r,Itt_void.top_term)::defs') a
   in
   let eqs''', opt_eqs''', defs''', b' =
      inf consts ((y, r')::decls) eqs'' opt_eqs'' defs'' b
   in eqs''', ((a',b')::opt_eqs'''), defs''', a'

let resource typeinf += (decide_term, inf_decide)

(************************************************************************
 * SUBTYPING                                                            *
 ************************************************************************)

(*
 * Subtyping of two union types.
 *)
let resource sub +=
   (DSubtype ([<< 'A1 + 'B1 >>, << 'A2 + 'B2 >>;
               << 'A1 >>, << 'A2 >>;
               << 'B1 >>, << 'B2 >>],
              unionSubtype))

(*
 * -*-
 * Local Variables:
 * End:
 * -*-
 *)
