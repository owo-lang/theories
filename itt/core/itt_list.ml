doc <:doc<
   @spelling{cons}
   @module[Itt_list]

   The @tt[Itt_list] module defines the type of finite
   lists of elements.  The lists can be defined using the
   simple recursive type in module @hrefmodule[Itt_srec].
   However, the lists have a simpler semantics, and they are defined
   as primitive, so that lists can be used without including
   the recursive type.

   @docoff
   ----------------------------------------------------------------

   @begin[license]
   This file is part of MetaPRL, a modular, higher order
   logical framework that provides a logical programming
   environment for OCaml and other languages.

   See the file doc/htmlman/default.html or visit http://metaprl.org/
   for more information.

   Copyright (C) 1998 Jason Hickey, Cornell University

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
   @email{jyh@cs.cornell.edu}
   @end[license]
>>

doc <:doc< @parents >>
extends Itt_equal
extends Itt_rfun
extends Itt_struct
extends Itt_logic
doc docoff

open Basic_tactics

open Itt_equal
open Itt_subtype
open Itt_struct

(************************************************************************
 * TERMS                                                                *
 ************************************************************************)

doc <:doc<
   @terms

   The @tt[nil] term is the empty list, the @tt[cons] term
   adds an element $a$ to list $b$.
>>
declare nil
declare cons{'a; 'b}

doc <:doc<
   The @tt[list] term defines the list type.  The @tt[list_ind]
   term defines the induction combinator.
>>
declare list{'a}
declare list_ind{'e; 'base; h, t, f. 'step['h; 't; 'f]}

(************************************************************************
 * REWRITES                                                             *
 ************************************************************************)

doc <:doc<
   @rewrites

   The @hrefterm[list_ind] term computes values on lists.
   The combinator has two bodies; the @i{base} term
   defines the value on empty lists, and the $@i{step}[h, t, f]$
   term defines values on $@cons{h; t}$, where $f$ represents
   the value computed on the tail $t$ of the list.
>>
prim_rw reduce_listindNil {| reduce |} :
   list_ind{nil; 'base; h, t, f. 'step['h; 't; 'f]} <--> 'base

prim_rw reduce_listindCons {| reduce |} :
   list_ind{('u :: 'v); 'base; h, t, f. 'step['h; 't; 'f]} <-->
      'step['u; 'v; list_ind{'v; 'base; h, t, f. 'step['h; 't; 'f]}]

(************************************************************************
 * RULES                                                                *
 ************************************************************************)

doc <:doc<
   @rules
   @modsubsection{Typehood and equality}

   The $@list{T}$ term is a well-formed type if
   $T$ is a type.
>>
prim listType {| intro [] |} :
   [wf] sequent { <H> >- "type"{'A} } -->
   sequent { <H> >- "type"{list{'A}} } =
   it

prim listEquality {| intro [] |} :
   [wf] sequent { <H> >- 'A = 'B in univ[i:l] } -->
   sequent { <H> >- list{'A} = list{'B} in univ[i:l] } =
   it

doc <:doc<
   @modsubsection{Membership}

   The @hrefterm[nil] term is a member of every list type $@list{A}$.
>>
prim nilEquality {| intro [] |} :
   [wf] sequent { <H> >- "type"{list{'A}} } -->
   sequent { <H> >- nil in list{'A} } =
   it

interactive nilFormation {| intro [] |} :
   [wf] sequent { <H> >- "type"{'A} } -->
   sequent { <H> >- list{'A} }

doc <:doc<
   The @hrefterm[cons] term $@cons{h; t}$ is a member of the list
   type $@list{A}$ if $h$ is an element of $A$, and $t$ is an element
   of $@list{A}$.
>>
prim consEquality {| intro [] |} :
   [wf] sequent { <H> >- 'u1 = 'u2 in 'A } -->
   [wf] sequent { <H> >- 'v1 = 'v2 in list{'A} } -->
   sequent { <H> >- cons{'u1; 'v1} = cons{'u2; 'v2} in list{'A} } =
   it

interactive consSquiggleEq {| intro [] |} :
   sequent  { <H> >- 'h1 ~ 'h2 } -->
   sequent  { <H> >- 't1 ~ 't2 } -->
   sequent  { <H> >- 'h1 :: 't1 ~ 'h2 :: 't2 }

doc <:doc<
   @modsubsection{Combinator equality}

   The @hrefterm[list_ind] term $@listind{l; u; v; z; @i{base}; @i{step}[u, v, z]}$
   computes a value of type $T$ if 1) the argument $l$ is a list of type $@list{A}$,
   2) the @i{base} term has type $T$, and 3) the @i{step} term computes a value
   of type $T$ for any elements $u @in A$, $v @in @list{A}$, and $z @in T$.
>>
prim list_indEquality {| intro [] |} bind{l. 'T['l]} list{'A} :
   [wf] sequent { <H> >- 'e1 = 'e2 in list{'A} } -->
   [wf] sequent { <H> >- 'base1 = 'base2 in 'T[nil] } -->
   [wf] sequent { <H>; u: 'A; v: list{'A}; w: 'T['v] >-
             'step1['u; 'v; 'w] = 'step2['u; 'v; 'w] in 'T['u::'v]
           } -->
   sequent { <H> >- list_ind{'e1; 'base1; u1, v1, z1. 'step1['u1; 'v1; 'z1]}
                   = list_ind{'e2; 'base2; u2, v2, z2. 'step2['u2; 'v2; 'z2]}
                   in 'T['e1]
           } =
   it

doc <:doc<
   @modsubsection{Elimination}

   The elimination for performs induction over the assumption
   $l@colon @list{A}$.  The rule produces two cases for a conclusion
   $C[l]$.  In the base case, $C$ must hold on the empty list, and
   in the induction step, $C[@cons{h; t}]$ must hold for any elements
   $h @in A$ and $t @in @list{A}$, where the induction hypothesis
   $C[t]$ holds on $t$.
>>
prim listElimination {| elim [ThinOption thinT] |} 'H :
   [main] ('base['l] : sequent { <H>; l: list{'A}; <J['l]> >- 'C[nil] }) -->
   [main] ('step['l; 'u; 'v; 'w] : sequent { <H>; l: list{'A}; <J['l]>; u: 'A; v: list{'A}; w: 'C['v] >- 'C['u::'v] }) -->
   sequent { <H>; l: list{'A}; <J['l]> >- 'C['l] } =
   list_ind{'l; 'base['l]; u, v, w. 'step['l; 'u; 'v; 'w]}

doc <:doc<
   @modsubsection{Contradiction}

   The terms @hrefterm[nil] and @hrefterm[cons] are distinct in
   every list type.
>>
interactive nil_neq_cons {| elim [] |} 'H :
   sequent { <H>; x: nil = cons{'h; 't} in list{'T}; <J['x]> >- 'C['x] }

interactive cons_neq_nil {| elim [] |} 'H :
   sequent { <H>; x: cons{'h; 't} = nil in list{'T}; <J['x]> >- 'C['x] }

(*
 * @modsubsection{Equality elimination}
 *)
interactive consEqElimination {| elim [ThinOption thinT] |} 'H :
   sequent { <H>; u: cons{'h1; 't1} = cons{'h2; 't2} in list{'A};
                       v: 'h1 = 'h2 in 'A; w: 't1 = 't2 in list{'A};   <J['u]> >- 'C['u] } -->
   sequent { <H>; u: cons{'h1; 't1} = cons{'h2; 't2} in list{'A}; <J['u]> >- 'C['u] }

doc <:doc<
   @modsubsection{Computation}

   The @emph{only} representative on the empty list is the
   @hrefterm[nil] term.
>>
prim nilSqequal {| nth_hyp |} 'T :
   sequent { <H> >- 'u = nil in list{'T} } -->
   sequent { <H> >- 'u ~ nil } =
   it

doc <:doc<
   @modsubsection{Subtyping}

   The list type $@list{A}$ is covariant in the type argument $A$.
>>
interactive listSubtype {| intro [] |} :
   ["subtype"] sequent { <H> >- \subtype{'A1; 'A2} } -->
   sequent { <H> >- \subtype{list{'A1}; list{'A2}}}
doc docoff

(* Formation rules *)

interactive listFormation :
   sequent { <H> >- univ[i:l] } -->
   sequent { <H> >- univ[i:l] }

(*
   H >- list(A) ext cons(h; t)
   by consFormation

   H >- A ext h
   H >- list(A) ext t
*)
interactive consFormation :
   sequent { <H> >- 'A } -->
   sequent { <H> >- list{'A} } -->
   sequent { <H> >- list{'A} }

(************************************************************************
 * DISPLAY FORMS                                                        *
 ************************************************************************)

prec prec_cons
prec prec_list

declare df_search{'a : Dform; 'b : Dform} : Dform
declare df_semicolons{'a : Dform} : Dform
declare df_colons{'a : Dform} : Dform

(* Empty list *)
dform nil_df : except_mode[src] :: nil = `"[]"

(* Search for nil entry *)
dform cons_df : except_mode[src] :: cons{'a; 'b} =
   df_search{xcons{'a; xnil}; 'b}

(* Keep searching down the list *)
dform search_df1 : df_search{'a; cons{'b; 'c}} =
   df_search{xcons{'b; 'a}; 'c}

(* Found a nil terminator: use bracket notation *)
dform search_df2 : df_search{'a; nil} =
   `"[" df_semicolons{'a} `"]"

(* No nil terminator, so use :: notation *)
dform search_df3 : df_search{'a; 'b} =
   df_colons{'a} `"::" slot{'b}

(* Reverse entries and separate with ; *)
dform semicolons_df1 : df_semicolons{xcons{'a; xnil}} =
   slot{'a}

dform semicolons_df2 : df_semicolons{xcons{'a; 'b}} =
   df_semicolons{'b} `";" slot{'a}

(* Reverse entries and separate with :: *)
dform colons_df1 : df_colons{xcons{'a; xnil}} =
   slot{'a}

dform colons_df2 : df_colons{xcons{'a; 'b}} =
   df_colons{'b} `"::" slot{'a}

dform list_df1 : except_mode[src] :: parens :: "prec"[prec_list] :: list{'a} =
   slot{'a} `" List"

dform list_ind_df1 : except_mode[src] :: parens :: "prec"[prec_list] :: list_ind{'e; 'base; h, t, f. 'step} =
   szone pushm[1] pushm[3]
   `"match " slot{'e} `" with" hspace
   pushm[3] `"[] ->" hspace slot{'base} popm popm hspace
   `"| " pushm[3] slot{'h} `"::" slot{'t} `"." slot{'f} `" ->" hspace slot{'step} popm popm ezone
(************************************************************************
 * PRIMITIVES                                                           *
 ************************************************************************)

let list_term = << list{'A} >>
let list_opname = opname_of_term list_term
let is_list_term = is_dep0_term list_opname
let dest_list = dest_dep0_term list_opname
let mk_list_term = mk_dep0_term list_opname

let nil_term = << nil >>

let cons_term = << cons{'a; 'b} >>
let cons_opname = opname_of_term cons_term
let is_cons_term = is_dep0_dep0_term cons_opname
let dest_cons = dest_dep0_dep0_term cons_opname
let mk_cons_term = mk_dep0_dep0_term cons_opname

let list_ind_term = << list_ind{'e; 'base; h, t, f. 'step['h; 't; 'f]} >>
let list_ind_opname = opname_of_term list_ind_term
let is_list_ind_term = is_dep0_dep0_dep3_term list_ind_opname
let dest_list_ind = dest_dep0_dep0_dep3_term list_ind_opname
let mk_list_ind_term = mk_dep0_dep0_dep3_term list_ind_opname

let rec mk_list_of_list = function
	h::t -> mk_cons_term h (mk_list_of_list t)
 | [] -> nil_term

(************************************************************************
 * TYPE INFERENCE                                                       *
 ************************************************************************)

(*
 * Type of list.
 *)
let resource typeinf += (list_term, Typeinf.infer_map dest_list)

let t_var = Lm_symbol.add "T"

(*
 * Type of nil.
 *)
let inf_nil _ consts _ eqs opt_eqs defs _ =
   let t = Typeinf.vnewname consts defs t_var in
   eqs, opt_eqs, ((t, <<void>>)::defs), <:con< list{'$t$} >>

let resource typeinf += (nil_term, inf_nil)

(*
 * Type of cons.
 *)
let inf_cons inf consts decls eqs opt_eqs defs t =
   let hd, tl = dest_cons t in
   let eqs', opt_eqs', defs', hd' = inf consts decls eqs opt_eqs defs hd in
   let eqs'', opt_eqs'', defs'', tl' = inf consts decls eqs' opt_eqs' defs' tl in
   let t = Typeinf.vnewname consts defs'' t_var in
   let tt = mk_var_term t in
      eqs'', ((mk_list_term tt,tl')::(tt,hd')::opt_eqs''), ((t,<<void>>)::defs''), mk_list_term hd'

let resource typeinf += (cons_term, inf_cons)

(*
 * Type of list_ind.
 *)
let inf_list_ind inf consts decls eqs opt_eqs defs t =
   let e, base, hd, tl, f, step = dest_list_ind t in
   let eqs', opt_eqs', defs', e' = inf consts decls eqs opt_eqs defs e in
   let t = Typeinf.vnewname consts defs' t_var in
      inf consts decls eqs'
          ((mk_list_term (mk_var_term t),e)::opt_eqs') ((t,<<void>>)::defs') base

let resource typeinf += (list_ind_term, inf_list_ind)

(************************************************************************
 * SUBTYPING                                                            *
 ************************************************************************)

(*
 * Subtyping of two list types.
 *)
let resource sub +=
   (DSubtype ([<< list{'A1} >>, << list{'A2} >>;
               << 'A2 >>, << 'A1 >>],
              dT 0))

(*
 * -*-
 * Local Variables:
 * Caml-master: "prlcomp.run"
 * End:
 * -*-
 *)