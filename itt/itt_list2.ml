doc <:doc<
   @begin[doc]
   @module[Itt_list2]

   The @tt{Itt_list2} module defines a ``library'' of
   additional operations on the lists defined in
   the @hrefmodule[Itt_list] module.
   @end[doc]

   ----------------------------------------------------------------

   @begin[license]
   This file is part of MetaPRL, a modular, higher order
   logical framework that provides a logical programming
   environment for OCaml and other languages.

   See the file doc/index.html for information on Nuprl,
   OCaml, and more information about this system.

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

   Author: Jason Hickey @email{jyh@cs.cornell.edu}
   Modified By: Aleksey Nogin @email{nogin@cs.cornell.edu}
   @end[license]
>>

doc <:doc< @doc{@parents} >>
extends Itt_list
extends Itt_logic
extends Itt_bool
extends Itt_nat
extends Itt_isect
extends Itt_struct2
extends Itt_int_base
extends Itt_int_ext
extends Itt_int_arith
extends Itt_pairwise
extends Itt_omega
doc <:doc< @docoff >>

open Basic_tactics

open Itt_equal
open Itt_rfun
open Itt_logic
open Itt_squash


(************************************************************************
 * SYNTAX                                                               *
 ************************************************************************)

doc <:doc<
   @begin[doc]
   @terms

   The @tt[all_list] and @tt[exists_list] term define quantifiers for lists.
   @end[doc]
>>
define unfold_all_list : all_list{'l; x. 'P['x]} <-->
   list_ind{'l; "true"; x, t, g. 'P['x] and 'g}

define unfold_all_list_witness : all_list_witness{'l; x. 'f['x]} <-->
   list_ind{'l; it; x, t, g. ('f['x],'g)}

define unfold_exists_list : exists_list{'l; x. 'P['x]} <-->
   list_ind{'l; "false"; x, t, g. 'P['x] or 'g}

declare undefined

define unfold_hd :
   hd{'l} <--> list_ind{'l; undefined; h, t, g. 'h}

define unfold_tl :
   tl{'l} <--> list_ind{'l; undefined; h, t, g. 't}


doc <:doc<
   @begin[doc]
   @terms

   The @tt{is_nil} term defines a Boolean value that is true
   @emph{iff} the argument list $l$ is empty.
   @end[doc]
>>
define unfold_is_nil :
   is_nil{'l} <--> list_ind{'l; btrue; h, t, g. bfalse}

doc <:doc<
   @begin[doc]
   @terms

   The @tt[mem] term defines list membership.
   @end[doc]
>>
define unfold_mem :
   mem{'x; 'l; 'T} <-->
      list_ind{'l; "false"; h, t, g. "or"{('x = 'h in 'T); 'g}}

doc <:doc<
   @begin[doc]
   @terms

   The @tt{subset} term determines whether the elements in $l_1$ are also
   in $l_2$.
   @end[doc]
>>
define unfold_subset :
   \subset{'l1; 'l2; 'T} <-->
      list_ind{'l1; "true"; h, t, g. "and"{mem{'h; 'l2; 'T}; 'g}}

doc <:doc<
   @begin[doc]
   @terms

   The @tt[sameset] term determines whether the two lists contain the same
   set of elements.
   @end[doc]
>>
define unfold_sameset :
   sameset{'l1; 'l2; 'T} <-->
      "and"{\subset{'l1; 'l2; 'T}; \subset{'l2; 'l1; 'T}}

doc <:doc<
   @begin[doc]
   @noindent
   The @tt{append} term takes two lists and concatenates them.
   @end[doc]
>>
define unfold_append :
   append{'l1; 'l2} <-->
      list_ind{'l1; 'l2; h, t, g. 'h :: 'g}

doc <:doc<
   @begin[doc]
   @noindent
   The @tt{ball2} term defines a Boolean universal quantification
   over two lists.  The test $b[x, y]$ must compute a Boolean value
   given elements of the two lists, and the test is $@bfalse$ if
   the lists have different lengths.
   @end[doc]
>>
define unfold_ball2 :
   ball2{'l1; 'l2; x, y. 'b['x; 'y]} <-->
      (list_ind{'l1; lambda{z. list_ind{'z; btrue; h, t, g. bfalse}};
                     h1, t1, g1. lambda{z. list_ind{'z; bfalse;
                     h2, t2, g2. band{'b['h1; 'h2]; .'g1 't2}}}} 'l2)

doc <:doc<
   @begin[doc]
   @noindent
   The @tt[assoc] term defines an associative lookup on
   the list $l$.  The list $l$ should be a list of pairs.
   The @tt[assoc] term searches for the element $x$ as
   the first element of one of the pairs.  On the first
   occurrence of a pair $(x, y)$, the value $b[y]$ is returned.
   The $z$ term is returned if a pair is not found.
   @end[doc]
>>
define unfold_assoc :
   assoc{'eq; 'x; 'l; y. 'b['y]; 'z} <-->
      list_ind{'l; 'z; h, t, g.
         spread{'h; u, v.
            ifthenelse{'eq 'u 'x; 'b['v]; 'g}}}

doc <:doc<
   @begin[doc]
   @noindent
   The @tt[rev_assoc] term also performs an associative search,
   but it keys on the second element of each pair.
   @end[doc]
>>
define unfold_rev_assoc :
   rev_assoc{'eq; 'x; 'l; y. 'b['y]; 'z} <-->
      list_ind{'l; 'z; h, t, g.
         spread{'h; u, v.
            ifthenelse{'eq 'v 'x; 'b['u]; 'g}}}

doc <:doc<
   @begin[doc]
   @noindent
   The @tt{map} term applies the function $f$ to each element
   of the list $l$, and returns the list of the results (in
   the same order).
   @end[doc]
>>
define unfold_map : map{'f; 'l} <-->
   list_ind{'l; nil; h, t, g. cons{'f 'h; 'g}}

define unfold_map2 : map{x.'f['x]; 'l} <--> map{lambda{x.'f['x]};'l}


doc <:doc<
   @begin[doc]
   @noindent
   The @tt{fold_left} term applies the function $f$ to each element
   of the list $l$, together with an extra argument $v$.  The result
   of each computation is passed as the argument $v$ to the
   next stage of the computation.
   @end[doc]
>>
define unfold_fold_left :
   fold_left{'f; 'v; 'l} <-->
      (list_ind{'l; lambda{x. 'x}; h, t, g. lambda{x. 'g ('f 'h 'x)}} 'v)

doc <:doc<
   @begin[doc]
   @noindent
   The @tt[nth] term returns element $i$ of list $l$.
   The argument $i$ must be within the bounds of the list.
   @end[doc]
>>
define unfold_nth :
   nth{'l; 'i} <-->
      (list_ind{'l; undefined; u, v, g. lambda{j. if 'j =@  0 then  'u else ('g ('j -@ 1))}} 'i)

doc <:doc<
   @begin[doc]
   @noindent
   The @tt[replace_nth] term replace element $i$ of list $l$
   with the term $v$.
   @end[doc]
>>
define unfold_replace_nth :
   replace_nth{'l; 'i; 't} <-->
      (list_ind{'l; nil; u, v, g. lambda{j. if 'j =@ 0 then  cons{'t; 'v} else cons{'u; .'g ('j -@ 1)}}} 'i)

doc <:doc<
   @begin[doc]
   @noindent
   The @tt{length} term returns the total number of elements in
   the list $l$.
   @end[doc]
>>
define unfold_length :
   length{'l} <--> list_ind{'l; 0; u, v, g. 'g +@ 1}

define unfold_index :
   Index{'l} <--> nat{length{'l}}

doc <:doc<
   @begin[doc]
   @noindent
   The @tt[rev] function returns a list with the same elements as
   list $l$, but in reverse order.
   @end[doc]
>>
define unfold_rev : rev{'l} <-->
   list_ind{'l; nil; u, v, g. append{'g; cons{'u; nil} }}


define unfold_mklist: mklist{'n;'f} <-->
   ind{'n; nil; x,l.('f ('n-@ 'x)) :: 'l}

doc <:doc< @docoff >>

let length_term = << length{'l} >>
let length_opname = opname_of_term length_term
let is_length_term = is_dep0_term length_opname
let mk_length_term = mk_dep0_term length_opname
let dest_length = dest_dep0_term length_opname

(************************************************************************
 * DISPLAY                                                              *
 ************************************************************************)

prec prec_append
prec prec_ball
prec prec_assoc

iform unfold_list: list <--> list{top}

dform list_df : list = `"List"

dform all_df : except_mode[src] :: parens :: "prec"[prec_quant] :: "all_list"{'A; x. 'B} =
   szone pushm[3] Nuprl_font!forall slot{'x} Nuprl_font!member slot{'A} sbreak["",". "] slot{'B} popm ezone

dform exists_df : except_mode[src] :: parens :: "prec"[prec_quant] :: "exists_list"{'A; x. 'B} =
   szone pushm[3] Nuprl_font!"exists" slot{'x} Nuprl_font!member slot{'A} sbreak["",". "] slot{'B} popm ezone

dform is_nil_df : except_mode[src] :: parens :: "prec"[prec_equal] :: is_nil{'l} =
   slot{'l} `" =" subb `" []"

dform mem_df : except_mode[src] :: mem{'x; 'l; 'T} =
   `"(" slot{'x} " " Nuprl_font!member `" " slot{'l} `" in " slot{list{'T}} `")"

dform index_df : except_mode[src] :: Index{'l} =
   `"Index(" slot{'l} `")"

dform subset_df : except_mode[src] :: \subset{'l1; 'l2; 'T} =
   `"(" slot{'l1} " " Nuprl_font!subseteq `"[" slot{'T} `"] " slot{'l2} `")"

dform sameset_df : except_mode[src] :: sameset{'l1; 'l2; 'T} =
   pushm[3] szone
   keyword["sameset"] `"{" 'l1 `";" hspace 'l2 `";" hspace 'T `"}"
   ezone popm

dform append_df : except_mode[src] :: parens :: "prec"[prec_append] :: append{'l1; 'l2} =
   slot["le"]{'l1} `" @" space slot{'l2}

dform ball2_df : except_mode[src] :: parens :: "prec"[prec_ball] :: ball2{'l1; 'l2; x, y. 'b} =
   pushm[3] Nuprl_font!forall subb slot{'x} `", " slot{'y} space
      Nuprl_font!member space slot{'l1} `", " slot{'l2} sbreak["",". "]
      slot{'b} popm

dform assoc_df : except_mode[src] :: parens :: "prec"[prec_assoc] :: assoc{'eq; 'x; 'l; v. 'b; 'z} =
   szone pushm[0] pushm[3]
   `"try" hspace
      pushm[3]
      `"let " slot{'v} `" = assoc " slot{'x} space Nuprl_font!member slot{'eq} space slot{'l} popm hspace
      pushm[3] `"in" hspace
      slot{'b} popm popm hspace
   pushm[3] `"with Not_found ->" hspace
   slot{'z} popm popm ezone

dform rev_assoc_df : except_mode[src] :: parens :: "prec"[prec_assoc] :: rev_assoc{'eq; 'x; 'l; v. 'b; 'z} =
   szone pushm[0] pushm[3]
   `"try" hspace
      pushm[3]
      `"let " slot{'v} `" = rev_assoc " slot{'x} space Nuprl_font!member slot{'eq} space slot{'l} popm hspace
      pushm[3] `"in" hspace
      slot{'b} popm popm hspace
   pushm[3] `"with Not_found ->" hspace
   slot{'z} popm popm ezone

dform map_df : except_mode[src] :: parens :: "prec"[prec_apply] :: map{'f; 'l} =
   `"map" space slot{'f} space slot{'l}

dform map_df : except_mode[src] :: parens :: "prec"[prec_apply] :: map{x.'f; 'l} =
   `"map("slot{'x} `"." slot{'f} `";" slot{'l} `")"

dform fold_left_df : except_mode[src] :: fold_left{'f; 'v; 'l} =
   `"fold_left(" slot{'f} `", " slot{'v} `", " slot{'l} `")"

dform length_df : except_mode[src] :: length{'l} =
   `"|" slot{'l} `"|"

dform nth_df : except_mode[src] :: nth{'l; 'i} =
    slot{'l} sub{'i}

dform replace_nth_df : except_mode[src] :: replace_nth{'l; 'i; 'v} =
   szone `"replace_nth(" pushm[0] slot{'l} `"," hspace slot{'i} `"," hspace slot{'v} `")" popm ezone

dform rev_df : except_mode[src] :: rev{'l} =
   `"rev(" slot{'l} `")"


interactive listelim {| elim [] |} 'H :
   sequent { <H>; l: list; <J['l]> >- 'C[nil] } -->
   sequent { <H>; l: list; <J['l]>; u: top; v: list; w: 'C['v] >- 'C['u::'v] } -->
   sequent { <H>; l: list; <J['l]> >- 'C['l] }

(************************************************************************
 * REWRITES                                                             *
 ************************************************************************)

interactive_rw reduce_hd {| reduce |} : hd{cons{'h; 't}} <--> 'h

interactive_rw reduce_tl {| reduce |} : tl{cons{'h; 't}} <--> 't


doc <:doc<
   @begin[doc]
   The @hrefterm[all_list] term performs induction over the list.
   @end[doc]
>>

interactive_rw reduce_all_list_nil {| reduce |} : all_list{nil; x. 'P['x]} <--> "true"

interactive_rw reduce_all_list_cons {| reduce |} :
   all_list{cons{'u; 'v}; x. 'P['x]} <--> 'P['u] and all_list{'v; x.'P['x]}
doc docoff

interactive_rw reduce_all_list_witness_nil {| reduce |} : all_list_witness{nil; x. 'P['x]} <--> it

interactive_rw reduce_all_list_witness_cons {| reduce |} :
   all_list_witness{cons{'u; 'v}; x. 'P['x]} <--> ('P['u], all_list_witness{'v; x.'P['x]})


doc <:doc<
   @begin[doc]
   @rewrites

   The @hrefterm[is_nil] term is defined with the
   @hrefterm[list_ind] term, with a base case $@btrue$,
   and step case $@bfalse$.
   @end[doc]
>>
interactive_rw reduce_is_nil_nil {| reduce |} : is_nil{nil} <--> btrue

interactive_rw reduce_is_nil_cons {| reduce |} : is_nil{cons{'h; 't}} <--> bfalse
doc docoff

let fold_is_nil = makeFoldC << is_nil{'l} >> unfold_is_nil

doc <:doc<
   @begin[doc]
   The @hrefterm[mem] term performs induction over the list.
   @end[doc]
>>

interactive_rw reduce_mem_nil {| reduce |} : mem{'x; nil; 'T} <--> "false"

interactive_rw reduce_mem_cons {| reduce |} :
   mem{'x; cons{'u; 'v}; 'T} <--> "or"{('x = 'u in 'T); mem{'x; 'v; 'T}}
doc docoff

let fold_mem = makeFoldC << mem{'x; 'l; 'T} >> unfold_mem

doc <:doc<
   @begin[doc]
   The @hrefterm[subset] term performs induction over the first list.
   @end[doc]
>>
interactive_rw reduce_subset_nil {| reduce |} : \subset{nil; 'l; 'T} <--> "true"

interactive_rw reduce_subset_cons {| reduce |} :
   \subset{cons{'u; 'v}; 'l; 'T} <--> "and"{mem{'u; 'l; 'T}; \subset{'v; 'l; 'T}}

doc docoff

let fold_subset = makeFoldC << \subset{'l1; 'l2; 'T} >> unfold_subset

let fold_sameset = makeFoldC << sameset{'l1; 'l2; 'T} >> unfold_sameset

doc <:doc<
   @begin[doc]
   The @hrefterm[append] term performs induction over the
   first list.
   @end[doc]
>>
interactive_rw reduce_append_nil {| reduce |} : append{nil; 'l2} <--> 'l2

interactive_rw reduce_append_cons {| reduce |} :
   append{cons{'x; 'l1}; 'l2} <--> cons{'x; append{'l1; 'l2}}

interactive_rw append_nil 'A :
   ('l in list{'A}) -->
   append{'l;nil} <--> 'l

interactive_rw append_assoc 'A:
   ('l1 in list{'A}) -->
   append{append{'l1;'l2};'l3} <-->
   append{'l1;append{'l2;'l3}}

doc docoff

let fold_append = makeFoldC << append{'l1; 'l2} >> unfold_append

doc <:doc<
   @begin[doc]
   The @hrefterm[ball2] term performs simultaneous induction
   over both lists, comparing the elements of the lists with
   the comparison $b[x, y]$.
   @end[doc]
>>
interactive_rw reduce_ball2_nil_nil {| reduce |} :
   ball2{nil; nil; x, y. 'b['x; 'y]} <--> btrue

interactive_rw reduce_ball2_nil_cons {| reduce |} :
   ball2{nil; cons{'h; 't}; x, y.'b['x; 'y]} <--> bfalse

interactive_rw reduce_ball2_cons_nil {| reduce |} :
   ball2{cons{'h; 't}; nil; x, y. 'b['x; 'y]} <--> bfalse

interactive_rw reduce_ball2_cons_cons {| reduce |} :
   ball2{cons{'h1; 't1}; cons{'h2; 't2}; x, y. 'b['x; 'y]} <-->
      band{'b['h1; 'h2]; ball2{'t1; 't2; x, y. 'b['x; 'y]}}

doc docoff

let fold_ball2 = makeFoldC << ball2{'l1; 'l2; x, y. 'b['x; 'y]} >> unfold_ball2

doc <:doc<
   @begin[doc]
   The @hrefterm[assoc] term performs induction over the list,
   splitting each pair and comparing it with the key.
   @end[doc]
>>
interactive_rw reduce_assoc_nil {| reduce |} :
   assoc{'eq; 'x; nil; y. 'b['y]; 'z} <--> 'z

interactive_rw reduce_assoc_cons {| reduce |} :
   assoc{'eq; 'x; cons{pair{'u; 'v}; 'l}; y. 'b['y]; 'z} <-->
      ifthenelse{'eq 'u 'x; 'b['v]; assoc{'eq; 'x; 'l; y. 'b['y]; 'z}}

doc docoff

let fold_assoc = makeFoldC << assoc{'eq; 'x; 'l; v. 'b['v]; 'z} >> unfold_assoc

doc <:doc<
   @begin[doc]
   The @hrefterm[rev_assoc] term also performs induction over the list,
   but it keys on the second element of each pair.
   @end[doc]
>>
interactive_rw reduce_rev_assoc_nil {| reduce |} :
   rev_assoc{'eq; 'x; nil; y. 'b['y]; 'z} <--> 'z

interactive_rw reduce_rev_assoc_cons {| reduce |} :
   rev_assoc{'eq; 'x; cons{pair{'u; 'v}; 'l}; y. 'b['y]; 'z} <-->
      ifthenelse{'eq 'v 'x; 'b['u]; rev_assoc{'eq; 'x; 'l; y. 'b['y]; 'z}}

doc docoff

let fold_rev_assoc = makeFoldC << rev_assoc{'eq; 'x; 'l; v. 'b['v]; 'z} >> unfold_rev_assoc

doc <:doc<
   @begin[doc]
   The @hrefterm[fold_left] term performs induction over the
   list argument, applying the function to the head element
   and the argument computed by the previous stage of the computation.
   @end[doc]
>>
interactive_rw reduce_fold_left_nil {| reduce |} :
   fold_left{'f; 'v; nil} <--> 'v

interactive_rw reduce_fold_left_cons {| reduce |} :
   fold_left{'f; 'v; cons{'h; 't}} <-->
   fold_left{'f; .'f 'h 'v; 't}

doc docoff

let fold_fold_left = makeFoldC << fold_left{'f; 'v; 'l} >> unfold_fold_left

doc <:doc<
   @begin[doc]
   The @hrefterm[length] function counts the total number of elements in the
   list.
   @end[doc]
>>
interactive_rw reduce_length_nil {| reduce |} : length{nil} <--> 0

interactive_rw reduce_length_cons {| reduce |} : length{cons{'u; 'v}} <--> (length{'v} +@ 1)

doc docoff

let fold_length = makeFoldC << length{'l} >> unfold_length

doc <:doc<
   @begin[doc]
   The @hrefterm[nth] term performs induction over the
   list, comparing the index to 0 at each step and returning the head element
   if it reaches 0.  The $@it$ term is returned if the index never reaches 0.
   @end[doc]
>>
interactive_rw reduce_nth_cons {| reduce |} :
   nth{cons{'u; 'v}; 'i} <--> ifthenelse{beq_int{'i; 0}; 'u; nth{'v; .'i -@ 1}}

doc docoff

let fold_nth = makeFoldC << nth{'l; 'i} >> unfold_nth

doc <:doc<
   @begin[doc]
   The @hrefterm[replace_nth] term is similar to the @hrefterm[nth]
   term, but it collects the list, and replaces the head element
   when the index reaches 0.
   @end[doc]
>>
interactive_rw reduce_replace_nth_cons {| reduce |} :
   replace_nth{cons{'u; 'v}; 'i; 't} <-->
      ifthenelse{beq_int{'i; 0}; cons{'t; 'v}; cons{'u; replace_nth{'v; .'i -@ 1; 't}}}

doc docoff

let fold_replace_nth = makeFoldC << replace_nth{'l; 'i; 't} >> unfold_replace_nth

doc <:doc<
   @begin[doc]
   The @hrefterm[rev] term reverses the list.
   This particular computation is rather inefficient;
   it appends the head of the list to the reversed tail.
   @end[doc]
>>
interactive_rw reduce_rev_nil {| reduce |} : rev{nil} <--> nil

interactive_rw reduce_rev_cons {| reduce |} : rev{cons{'u;'v}} <--> append{rev{'v};cons{'u;nil}}

doc docoff

let fold_rev = makeFoldC << rev{'l} >> unfold_rev

doc <:doc<
   @begin[doc]
   The @hrefterm[map] term performs induction over the list $l$,
   applying the function to each element, and collecting the results.
   @end[doc]
>>
interactive_rw reduce_map_nil {| reduce |} :
   map{'f; nil} <--> nil

interactive_rw reduce_map_cons {| reduce |} :
   map{'f; cons{'h; 't}} <--> cons{'f 'h; map{'f; 't}}

interactive_rw reduce_map2_nil {| reduce |} :
   map{x.'f['x]; nil} <--> nil

interactive_rw reduce_map2_cons {| reduce |} :
   map{x.'f['x]; cons{'h; 't}} <--> cons{'f['h]; map{x.'f['x]; 't}}

interactive_rw length_map {| reduce |} :
   ('l in list) -->
   length{map{'f; 'l}} <--> length{'l}

interactive_rw length_map2 {| reduce |} :
   ('l in list) -->
   length{map{x.'f['x]; 'l}} <--> length{'l}

interactive_rw index_map {| reduce |} :
   ('l in list) -->
   Index{map{'f; 'l}} <--> Index{'l}

interactive_rw index_map2 {| reduce |} :
   ('l in list) -->
   Index{map{x.'f['x]; 'l}} <--> Index{'l}

doc docoff

let fold_map = makeFoldC << map{'f; 'l} >> unfold_map

(************************************************************************
 * RULES                                                                *
 ************************************************************************)


interactive hd_wf {| intro [] |} :
   [wf] sequent  { <H> >- 'l in list{'T} } -->
   sequent  { <H> >- not{'l = nil in list{'T}} } -->
   sequent  { <H> >- hd{'l} in 'T }

interactive hd_wf1 {| intro [] |} :
   [wf] sequent  { <H> >- 'l1 = 'l2 in list{'T} } -->
   sequent  { <H> >- not{'l1 = nil in list{'T}} } -->
   sequent  { <H> >- hd{'l1} = hd{'l2} in 'T }

interactive tl_wf {| intro [] |} :
   [wf] sequent { <H> >- 'l in list{'T} } -->
   sequent  { <H> >- not{'l = nil in list{'T}} } -->
   sequent  { <H> >- tl{'l} in list{'T} }

interactive tl_wf1 {| intro [] |} :
   [wf] sequent  { <H> >- 'l1 = 'l2 in list{'T} } -->
   sequent  { <H> >- not{'l1 = nil in list{'T}} } -->
   sequent  { <H> >- tl{'l1} = tl{'l2} in list{'T} }

interactive_rw tl_hd_rw list{'T} :
   ('l in list{'T})  -->
   (not{'l = nil in list{'T}}) -->
     cons{hd{'l};tl{'l}} <--> 'l



doc <:doc<
   @begin[doc]
   @rules

   The rules in the @hrefmodule[Itt_list2] are limited to
   well-formedness of each of the constructions.
   @end[doc]
>>

interactive is_nil_wf {| intro [] |} :
   [wf] sequent { <H> >- 'l in list } -->
   sequent { <H> >- is_nil{'l} in bool }

(*
 * Membership.
 *)
interactive mem_wf {| intro [] |} :
   [wf] sequent { <H> >- "type"{'T} } -->
   [wf] sequent { <H> >- 'x in 'T } -->
   [wf] sequent { <H> >- 'l in list{'T} } -->
   sequent { <H> >- "type"{mem{'x; 'l; 'T}} }

(*
 * Subset.
 *)
interactive subset_wf {| intro [] |} :
   [wf] sequent { <H> >- "type"{'T} } -->
   [wf] sequent { <H> >- 'l1 in list{'T} } -->
   [wf] sequent { <H> >- 'l2 in list{'T} } -->
   sequent { <H> >- "type"{\subset{'l1; 'l2; 'T}} }

(*
 * Sameset.
 *)
interactive sameset_wf {| intro [] |} :
   [wf] sequent { <H> >- "type"{'T} } -->
   [wf] sequent { <H> >- 'l1 in list{'T} } -->
   [wf] sequent { <H> >- 'l2 in list{'T} } -->
   sequent { <H> >- "type"{sameset{'l1; 'l2; 'T}} }

(*
 * Append.
 *)
interactive append_wf2 {| intro [] |} :
   [wf] sequent { <H> >- 'l1 in list{'T} } -->
   [wf] sequent { <H> >- 'l2 in list{'T} } -->
   sequent { <H> >- append{'l1; 'l2} in list{'T} }

(*
 * Ball2.
 *)
interactive ball2_wf2 {| intro [] |} 'T1 'T2 :
   [wf] sequent { <H> >- "type"{'T1} } -->
   [wf] sequent { <H> >- "type"{'T2} } -->
   [wf] sequent { <H> >- 'l1 in list{'T1} } -->
   [wf] sequent { <H> >- 'l2 in list{'T2} } -->
   [wf] sequent { <H>; u: 'T1; v: 'T2 >- 'b['u; 'v] in bool } -->
   sequent { <H> >- ball2{'l1; 'l2; x, y. 'b['x; 'y]} in bool }

(*
 * assoc2.
 *)
interactive assoc_wf {| intro [intro_typeinf <<'l>>] |} 'z list{'T1 * 'T2} :
   [wf] sequent { <H> >- "type"{'T2} } -->
   [wf] sequent { <H> >- 'eq in 'T1 -> 'T1 -> bool } -->
   [wf] sequent { <H> >- 'x in 'T1 } -->
   [wf] sequent { <H> >- 'l in list{'T1 * 'T2} } -->
   [wf] sequent { <H>; z: 'T2 >- 'b['z] in 'T } -->
   [wf] sequent { <H> >- 'z in 'T } -->
   sequent { <H> >- assoc{'eq; 'x; 'l; v. 'b['v]; 'z} in 'T }

interactive rev_assoc_wf {| intro [intro_typeinf <<'l>>] |} 'z list{'T1 * 'T2} :
   [wf] sequent { <H> >- "type"{'T1} } -->
   [wf] sequent { <H> >- 'eq in 'T2 -> 'T2 -> bool } -->
   [wf] sequent { <H> >- 'x in 'T2 } -->
   [wf] sequent { <H> >- 'l in list{'T1 * 'T2} } -->
   [wf] sequent { <H>; z: 'T1 >- 'b['z] in 'T } -->
   [wf] sequent { <H> >- 'z in 'T } -->
   sequent { <H> >- rev_assoc{'eq; 'x; 'l; v. 'b['v]; 'z} in 'T }

(*
 * Fold_left.
 *)
interactive fold_left_wf {| intro [intro_typeinf <<'l>>] |} list{'T1} :
   [wf] sequent { <H> >- "type"{'T1} } -->
   [wf] sequent { <H> >- "type"{'T2} } -->
   [wf] sequent { <H> >- 'f in 'T1 -> 'T2 -> 'T2 } -->
   [wf] sequent { <H> >- 'v in 'T2 } -->
   [wf] sequent { <H> >- 'l in list{'T1} } -->
   sequent { <H> >- fold_left{'f; 'v; 'l} in 'T2 }

(*
 * Length.
 *)
interactive length_wf {| intro [] |} :
   [wf] sequent { <H> >- 'l in list } -->
   sequent { <H> >- length{'l} in int }

interactive length_nonneg {| intro [] |}  :
   [wf] sequent { <H> >- 'l in list } -->
   sequent { <H> >- 0 <= length{'l} }

interactive length_wf2 {| intro [] |} :
   [wf] sequent { <H> >- 't in list } -->
   sequent { <H> >- length{cons{'h;'t}} in nat }

interactive length_wf1 {| intro [] |} :
   [wf] sequent { <H> >- 'l in list } -->
   sequent { <H> >- length{'l} in nat }

interactive length_cons_pos {| intro [] |} :
   [wf] sequent { <H> >- 't in list } -->
   sequent { <H> >- 0 < length{cons{'h;'t}} }

interactive listTop {| nth_hyp |} 'H :
   sequent { <H>; l : list{'A}; <J['l]> >- 'l in list }

interactive listTop2 {| intro[AutoMustComplete; intro_typeinf <<'l>>] |} list{'A} :
   sequent { <H> >- 'l in list{'A} } -->
   sequent { <H> >- 'l in list }

interactive index_wf {| intro [] |}  :
   [wf] sequent { <H> >- 'l in list } -->
   sequent { <H> >- Index{'l} Type }

interactive index_mem {| intro [AutoMustComplete] |} :
    sequent { <H> >- 'i in nat } -->
    sequent { <H> >- 'i < length{'l} } -->
    sequent { <H> >- 'l in list } -->
    sequent { <H> >- 'i in Index{'l} }

interactive index_nil_elim {| elim []; squash; nth_hyp |} 'H :
   sequent { <H>; i:Index{nil}; <J['i]> >-  'P['i] }

interactive index_elim {| elim [] |} 'H :
   sequent { <H>; i:nat; 'i<length{'l}; <J['i]> >-  'P['i] } -->
   sequent { <H>; i:Index{'l}; <J['i]> >-  'P['i] }

interactive index_is_int {| nth_hyp |} 'H :
    sequent { <H>; i:Index{'l}; <J['i]> >- 'i in int }

interactive nth_wf {| intro [] |} :
   [wf] sequent { <H> >- "type"{'T} } -->
   [wf] sequent { <H> >- 'l in list{'T} } -->
   [wf] sequent { <H> >- 'i in Index{'l} } -->
   sequent { <H> >- nth{'l; 'i} in 'T }

interactive index_rev_wf {| intro[] |} :
   [wf] sequent { <H> >- 'l in list } -->
   sequent { <H> >-  'i in Index{'l} } -->
   sequent { <H> >-  length{'l} -@ ('i +@ 1) in Index{'l} }

interactive replace_nth_wf {| intro [] |} :
   [wf] sequent { <H> >- "type"{'T} } -->
   [wf] sequent { <H> >- 'l in list{'T} } -->
   [wf] sequent { <H> >- 'i in Index{'l} } -->
   [wf] sequent { <H> >- 't in 'T } -->
   sequent { <H> >- replace_nth{'l; 'i; 't} in list{'T} }

interactive list_lengthzero {| elim [] |} 'H 'A :
   sequent { <H>; x: (length{'l} = 0 in int); <J[it]> >- 'A Type } -->
   sequent { <H>; x: (length{'l} = 0 in int); <J[it]> >- 'l in list{'A} } -->
   sequent { <H>; x: (length{'l} = 0 in int); <J[it]>; y: 'l = nil in list{'A} >- 'C[it] } -->
   sequent { <H>; x: (length{'l} = 0 in int); <J['x]> >- 'C['x] }

interactive_rw nth_map {| reduce |} :
   ('l in list) -->
   ('i in Index{'l}) -->
   nth{map{'f; 'l};'i} <--> 'f(nth{'l;'i})

interactive_rw nth_map2 {| reduce |} :
   ('l in list) -->
   ('i in Index{'l}) -->
   nth{map{x.'f['x]; 'l};'i} <--> 'f[nth{'l;'i}]

interactive nth_eq {| intro [] |} :
   [wf] sequent { <H> >- "type"{'T} } -->
   [wf] sequent { <H> >- 'l1 = 'l2 in list{'T} } -->
   [wf] sequent { <H> >- 'i in Index{'l1} } -->
   sequent { <H> >- nth{'l1; 'i} = nth{'l2; 'i} in 'T }

(*
 * Reverse.
 *)
interactive rev_wf {| intro [] |} :
   [wf] sequent { <H> >- 'l in list{'A} } -->
   sequent { <H> >- rev{'l} in list{'A} }

interactive_rw rev_append 'A :
   ('a in list{'A}) -->
   ('b in list{'A}) -->
   rev{append{'a;'b}} <--> append{rev{'b};rev{'a}}

doc <:doc< @doc{Double-reverse is identity.} >>

interactive_rw rev2 'A :
   ('l in list{'A}) -->
   rev{rev{'l}} <--> 'l


doc <:doc<
   @begin[doc]
   @rules
   Rules for mem.
   @end[doc]
>>
interactive mem_nil {| intro[] |} :
   sequent { <H> >- "false" } -->
   sequent { <H> >- mem{'x; nil; 'T} }

interactive mem_cons2 {| intro[AutoMustComplete] |} :
   [wf] sequent { <H> >- 'x in 'T } -->
   [wf] sequent { <H> >- 'h in 'T } -->
   sequent { <H> >- mem{'x; 't; 'T}  } -->
   sequent { <H> >- mem{'x; 'h::'t; 'T} }

interactive mem_cons1 {| intro[] |} :
   [wf] sequent { <H> >- 'x in 'T } -->
   [wf] sequent { <H> >- 't in list{'T} } -->
   sequent { <H> >- mem{'x; 'x::'t; 'T} }

interactive restrict_list {| intro[] |} :
   sequent { <H> >- 'A Type } -->
   sequent { <H> >- 'l in list{'A} } -->
   sequent { <H> >- 'l in list{{x:'A | mem{'x;'l;'A}}} }

doc <:doc<
   @begin[doc]
    The following induction principle is used for simultaneous induction on two lists.
   @end[doc]
>>

interactive list_induction2 :
   sequent { <H> >- 'P[nil; nil] } -->
   sequent { <H>; h2:'B; t2:list{'B} >- 'P[nil; 'h2::'t2] } -->
   sequent { <H>; h1:'A; t1:list{'A} >- 'P['h1::'t1; nil] } -->
   sequent { <H>; h1:'A; t1:list{'A}; h2:'B; t2:list{'B};  'P['t1;'t2] >- 'P['h1::'t1;'h2::'t2] } -->
   sequent { <H>; l1:list{'A}; l2:list{'B} >- 'P['l1; 'l2] }

(*

l
define list_of_fun{k.'f[k];'n} <--> ind{'n; nil; k,l. 'f[0]:: list_of_fun{k.'f[k+1]} }


interactive list_elements_id {| intro [] |} :
   [wf] sequent { <H> >- 'l in list } -->
   sequent { <H> >- 'l ~ list_of_fun{k.nth{'l;'k}; length{l}} }

h::t <-->
t ~ lof {k.t@k}
h::t
   l@0 :: lof{k. h::t @ k+1}
   append{l_o_f [nth[h::t;k]
   if k = 0 then

*)



define unfold_tail: tail{'l;'n} <--> ind{'n; nil;   k,r. cons{nth{'l;length{'l} -@ 'k}; 'r} }

interactive_rw tail_reduce1 {| reduce |}:
   tail{'l;0} <--> nil
interactive_rw tail_reduce2 {| reduce |}: ('n in nat) -->
   tail{'l;'n+@1} <-->  cons{nth{'l;length{'l} -@ ('n +@ 1)};  tail{'l;'n} }

interactive tail_wf {| intro[] |}:
   sequent { <H> >-  'l in list{'A} } -->
   sequent { <H> >-  'n in nat } -->
   sequent { <H> >- 'n <= length{'l} } -->
   sequent { <H> >- tail{'l;'n} in list{'A} }

interactive tail_does_not_depend_on_the_head {| intro[] |}:
   sequent { <H> >-  'l in list } -->
   sequent { <H> >-  'n in nat } -->
   sequent { <H> >- 'n <= length{'l} } -->
   sequent { <H> >- tail{'l;'n} ~ tail{cons{'h;'l};'n}  }

interactive list_is_its_own_tail {| intro[] |}:
   sequent { <H> >-  'l in list } -->
   sequent { <H> >- 'l ~ tail{'l;length{'l}} }

interactive tail_squiggle {| intro[] |}:
   sequent { <H> >-  'n in nat } -->
   sequent { <H>; i:nat; 'i<'n >-  nth{'l_1;length{'l_1}-@('i+@1)} ~ nth{'l_2;length{'l_2}-@('i+@1)} } -->
   sequent { <H> >-  tail{'l_1;'n} ~ tail{'l_2;'n} }

interactive listSquiggle :
   [wf] sequent { <H> >- 'l1 in list } -->
   [wf] sequent { <H> >- 'l2 in list } -->
   [wf] sequent { <H> >- length{'l1} = length{'l2} in nat } -->
   sequent { <H>; i: Index{'l1} >- nth{'l1; 'i} ~ nth{'l2; 'i} } -->
   sequent { <H> >- 'l1 ~ 'l2 }

interactive tail_induction 'H :
   sequent { <H>; l:list{'A}; <J['l]> >-  'P[nil] } -->
   sequent { <H>; l:list{'A}; <J['l]>; n:Index{'l}; 'P[tail{'l;'n}] >- 'P[ cons{nth{'l;length{'l} -@ ('n +@ 1)};  tail{'l;'n}}] } -->
   sequent { <H>; l:list{'A}; <J['l]> >-  'P['l] }

doc <:doc<
   @begin[doc]
   @rules
   Rules for quantifiers are the following:
   @end[doc]
>>
interactive all_list_wf  {| intro[] |} :
   sequent { <H> >- 'l in list  } -->
   sequent { <H>; i:Index{'l}  >- 'P[nth{'l;'i}] Type } -->
   sequent { <H> >- all_list{'l;  x. 'P['x]} Type }

interactive all_list_intro_nil  {| intro[] |} :
   sequent { <H> >- all_list{nil;  x. 'P['x]} }

interactive all_list_intro_cons  {| intro[] |} :
   sequent { <H> >-  'P['a] } -->
   sequent { <H> >-  all_list{'l; x. 'P['x]} } -->
   sequent { <H> >- all_list{cons{'a; 'l};  x. 'P['x]} }

interactive all_list_intro  {| intro[] |} :
   sequent { <H> >- 'l in list  } -->
   sequent { <H>; i:Index{'l}  >- 'P[nth{'l;'i}]  } -->
   sequent { <H> >- all_list{'l;  x. 'P['x]} }

interactive all_list_intro1  {| intro[SelectOption 1;  intro_typeinf <<'l>>] |} list{'A} :
   sequent { <H> >- 'A Type  } -->
   sequent { <H> >- 'l in list{'A}  } -->
   sequent { <H>; x:'A; mem{'x; 'l; 'A}  >- 'P['x]  } -->
   sequent { <H> >- all_list{'l;  x. 'P['x]} }

interactive all_list_elim {| elim[] |} 'H  'i :
   sequent { <H>; u: all_list{'l;  x. 'P['x]}; <J['u]> >- 'l in list  } -->
   sequent { <H>; u: all_list{'l;  x. 'P['x]}; <J['u]> >- 'i in Index{'l}  } -->
   sequent { <H>; u: all_list{'l;  x. 'P['x]}; <J['u]>; 'P[nth{'l;'i}] >- 'C['u] } -->
   sequent { <H>; u: all_list{'l;  x. 'P['x]}; <J['u]> >- 'C['u] }

interactive all_list_map  {| intro[] |} :
   [wf] sequent { <H> >- 'l in list  } -->
   sequent { <H> >-  all_list{'l; x. 'P['f('x)]} } -->
   sequent { <H> >- all_list{map{'f;'l};  y. 'P['y]} }

interactive all_list_witness_wf  {| intro[intro_typeinf <<'l>>] |} list{'A} :
   sequent { <H> >- 'A Type  } -->
   sequent { <H> >- 'l in list{'A}  } -->
   sequent { <H>; x:'A; mem{'x; 'l; 'A} >- 'p['x] in 'P['x]  } -->
   sequent { <H> >- all_list_witness{'l;  x. 'p['x]} in all_list{'l;  x. 'P['x]} }

interactive all_list_witness_wf2  {| intro[] |} :
   sequent { <H> >- 'l in list } -->
   sequent { <H> >- all_list{'l;  x. 'p['x] in 'P['x]}  } -->
   sequent { <H> >- all_list_witness{'l;  x. 'p['x]} in all_list{'l;  x. 'P['x]} }

(*
 * map.
 *)
interactive map_wf {| intro [intro_typeinf <<'l>>] |} list{'T1} :
   [wf] sequent { <H> >- "type"{'T1} } -->
   [wf] sequent { <H> >- "type"{'T2} } -->
   [wf] sequent { <H> >- 'f in 'T1 -> 'T2 } -->
   [wf] sequent { <H> >- 'l in list{'T1} } -->
   sequent { <H> >- map{'f; 'l} in list{'T2} }

interactive map_wf2 {| intro [] |} :
   [wf] sequent { <H> >- "type"{'T2} } -->
   [wf] sequent { <H> >- 'l in list } -->
   [wf] sequent { <H> >- all_list{'l;x.'f['x] in 'T2} } -->
   sequent { <H> >- map{x.'f['x]; 'l} in list{'T2} }

interactive map_wf3 {| intro [] |} :
   [wf] sequent { <H> >- 'l in list } -->
   sequent { <H> >- map{x.'f['x]; 'l} in list }

doc <:doc<
   @begin[doc]
   A list $v$ is a subset of the list <<cons{'u; 'v}>>.
   @end[doc]
>>
interactive subset_cons {| intro [AutoMustComplete] |} :
   [wf] sequent { <H> >- "type"{'A} } -->
   [wf] sequent { <H> >- 'u in 'A } -->
   [wf] sequent { <H> >- 'v in list{'A} } -->
   [wf] sequent { <H> >- 'l in list{'A} } -->
   sequent { <H> >- \subset{'v; 'l; 'A} } -->
   sequent { <H> >- \subset{'v; cons{'u; 'l}; 'A} }

doc <:doc<
   @begin[doc]
   @rules

   @tt[subset] is reflexive and transitive.
   @end[doc]
>>
interactive subset_ref {| intro [] |} :
   [wf] sequent { <H> >- "type"{'A} } -->
   [wf] sequent { <H> >- 'l in list{'A} } -->
   sequent { <H> >- \subset{'l; 'l; 'A} }

interactive subset_trans 'l2 :
   [wf] sequent { <H> >- "type"{'A} } -->
   [wf] sequent { <H> >- 'l1 in list{'A} } -->
   [wf] sequent { <H> >- 'l2 in list{'A} } -->
   [wf] sequent { <H> >- 'l3 in list{'A} } -->
   sequent { <H> >- \subset{'l1; 'l2; 'A} } -->
   sequent { <H> >- \subset{'l2; 'l3; 'A} } -->
   sequent { <H> >- \subset{'l1; 'l3; 'A} }

doc <:doc<
   @begin[doc]
   @rules

   @tt[sameset] is reflexive, symmetric, and transitive.
   @end[doc]
>>
interactive sameset_ref {| intro [] |} :
   [wf] sequent { <H> >- "type"{'A} } -->
   [wf] sequent { <H> >- 'l in list{'A} } -->
   sequent { <H> >- sameset{'l; 'l; 'A} }

interactive sameset_sym :
   [wf] sequent { <H> >- "type"{'A} } -->
   [wf] sequent { <H> >- 'l1 in list{'A} } -->
   [wf] sequent { <H> >- 'l2 in list{'A} } -->
   sequent { <H> >- sameset{'l1; 'l2; 'A} } -->
   sequent { <H> >- sameset{'l2; 'l1; 'A} }

interactive sameset_trans 'l2 :
   [wf] sequent { <H> >- "type"{'A} } -->
   [wf] sequent { <H> >- 'l1 in list{'A} } -->
   [wf] sequent { <H> >- 'l2 in list{'A} } -->
   [wf] sequent { <H> >- 'l3 in list{'A} } -->
   sequent { <H> >- sameset{'l1; 'l2; 'A} } -->
   sequent { <H> >- sameset{'l2; 'l3; 'A} } -->
   sequent { <H> >- sameset{'l1; 'l3; 'A} }
doc <:doc< @docoff >>

(************************************************************************
 * TACTICS                                                              *
 ************************************************************************)

let samesetSymT = sameset_sym
let samesetTransT = sameset_trans

(*
 * -*-
 * Local Variables:
 * Caml-master: "nl"
 * End:
 * -*-
 *)
