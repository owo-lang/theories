(*
 * Lists.
 *
 *)

include Tactic_type

include Itt_equal
include Itt_rfun

open Printf
open Debug
open Refiner.Refiner
open Refiner.Refiner.Term
open Refiner.Refiner.TermOp
open Refiner.Refiner.TermSubst
open Refiner.Refiner.RefineErrors
open Options
open Resource

open Var
open Sequent
open Tacticals
open Itt_subtype

(*
 * Show that the file is loading.
 *)
let _ =
   if !debug_load then
      eprintf "Loading Itt_list%t" eflush

(* debug_string DebugLoad "Loading itt_list..." *)

(************************************************************************
 * TERMS                                                                *
 ************************************************************************)

declare nil
declare cons{'a; 'b}

declare list{'a}
declare list_ind{'e; 'base; h, t, f. 'step['h; 't; 'f]}

(************************************************************************
 * REWRITES                                                             *
 ************************************************************************)

(*
 * Reduction.
 *)
primrw reduce_listindNil :
   list_ind{nil; 'base; h, t, f. 'step['h; 't; 'f]} <--> 'base

primrw reduce_listindCons :
   list_ind{('u :: 'v); 'base; h, t, f. 'step['h; 't; 'f]} <-->
      'step['u; 'v; list_ind{'v; 'base; h, t, f. 'step['h; 't; 'f]}]

(************************************************************************
 * DISPLAY FORMS                                                        *
 ************************************************************************)

prec prec_cons

dform nil_df1 : nil = "[" "]"
dform cons_df1 : parens :: "prec"[prec_cons] :: cons{'a; 'b} = slot{'a} `"::" slot{'b}

dform list_df1 : mode[prl] :: list{'a} = slot{'a} `"List"
dform list_ind_df1 : mode[prl] :: list_ind{'e; 'base; h, t, f. 'step['h; 't; 'f]} =
   pushm[1] pushm[3]
   `"case " slot{'e} `" of" space
      nil `" -> " slot{'base} space popm
   `"|" pushm[0]
      slot{'h} `"::" slot{'t} `"." slot{'f} `"->" slot{'step['h; 't; 'f]} popm popm

(************************************************************************
 * RULES                                                                *
 ************************************************************************)

(*
 * H >- Ui ext list(A)
 * by listFormation
 *
 * H >- Ui ext A
 *)
prim listFormation 'H :
   ('A : sequent ['ext] { 'H >- univ[@i:l] }) -->
   sequent ['ext] { 'H >- univ[@i:l] } =
   'A

(*
 * H >- list(A) = list(B) in Ui
 * by listEquality
 *
 * H >- A = B in Ui
 *)
prim listEquality 'H :
   sequent [squash] { 'H >- 'A = 'B in univ[@i:l] } -->
   sequent ['ext] { 'H >- list{'A} = list{'B} in univ[@i:l] } =
   it

(*
 * H >- list(A) ext nil
 * by nilFormation
 *
 * H >- A = A in Ui
 *)
prim nilFormation 'H :
   sequent [squash] { 'H >- "type"{'A} } -->
   sequent ['ext] { 'H >- 'A list } =
   nil

(*
 * H >- nil = nil in list(A)
 * by nilEquality
 *
 * H >- A = A in Ui
 *)
prim nilEquality 'H :
   sequent [squash] { 'H >- "type"{'A} } -->
   sequent ['ext] { 'H >- nil = nil in list{'A} } =
   it

(*
 * H >- list(A) ext cons(h; t)
 * by consFormation
 *
 * H >- A ext h
 * H >- list(A) ext t
 *)
prim consFormation 'H :
   ('h : sequent ['ext] { 'H >- 'A }) -->
   ('t : sequent ['ext] { 'H >- list{'A} }) -->
   sequent ['ext] { 'H >- list{'A} } =
   'h :: 't

(*
 * H >- u1::v1 = u2::v2 in list(A)
 * consEquality
 *
 * H >- u1 = u2 in A
 * H >- v1 = v2 in list(A)
 *)
prim consEquality 'H :
   sequent [squash] { 'H >- 'u1 = 'u2 in 'A } -->
   sequent [squash] { 'H >- 'v1 = 'v2 in list{'A} } -->
   sequent ['ext] { 'H >- cons{'u1; 'v1} = cons{'u2; 'v2} in list{'A} } =
   it

(*
 * H; l: list(A); J[l] >- C[l]
 * by listElimination w u v
 *
 * H; l: list(A); J[l] >- C[nil]
 * H; l: list(A); J[l]; u: A; v: list(A); w: C[v] >- C[u::v]
 *)
prim listElimination 'H 'J 'l 'w 'u 'v :
   ('base['l] : sequent ['ext] { 'H; l: list{'A}; 'J['l] >- 'C[nil] }) -->
   ('step['l; 'u; 'v; 'w] : sequent ['ext] { 'H; l: list{'A}; 'J['l]; u: 'A; v: list{'A}; w: 'C['v] >- 'C['u::'v] }) -->
   sequent ['ext] { 'H; l: list{'A}; 'J['l] >- 'C['l] } =
   list_ind{'l; 'base['l]; u, v, w. 'step['l; 'u; 'v; 'w]}

(*
 * H >- rec_case(e1; base1; u1, v1, z1. step1[u1; v1]
 *      = rec_case(e2; base2; u2, v2, z2. step2[u2; v2]
 *      in T[e1]
 *
 * by list_indEquality lambda(r. T[r]) list(A) u v w
 *
 * H >- e1 = e2 in list(A)
 * H >- base1 = base2 in T[nil]
 * H, u: A; v: list(A); w: T[v] >- step1[u; v; w] = step2[u; v; w] in T[u::v]
 *)
prim list_indEquality 'H lambda{l. 'T['l]} list{'A} 'u 'v 'w :
   sequent [squash] { 'H >- 'e1 = 'e2 in list{'A} } -->
   sequent [squash] { 'H >- 'base1 = 'base2 in 'T[nil] } -->
   sequent [squash] { 'H; u: 'A; v: list{'A}; w: 'T['v] >-
             'step1['u; 'v; 'w] = 'step2['u; 'v; 'w] in 'T['u::'v]
           } -->
   sequent ['ext] { 'H >- list_ind{'e1; 'base1; u1, v1, z1. 'step1['u1; 'v1; 'z1]}
                   = list_ind{'e2; 'base2; u2, v2, z2. 'step2['u2; 'v2; 'z2]}
                   in 'T['e1]
           } =
   it

(*
 * H >- list(A1) <= list(A2)
 * by listSubtype
 *
 * H >- A1 <= A2
 *)
prim listSubtype 'H :
   sequent [squash] { 'H >- subtype{'A1; 'A2} } -->
   sequent ['ext] { 'H >- subtype{list{'A1}; list{'A2}}} =
   it

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

(************************************************************************
 * D TACTIC                                                             *
 ************************************************************************)

let d_concl_list p =
   nilFormation (hyp_count p) p

let d_hyp_list i p =
   let i, j = hyp_indices p i in
   let n, _ = Sequent.nth_hyp p i in
      (match maybe_new_vars ["w"; "u"; "v"] (declared_vars p) with
          [w; u; v] ->
             listElimination i j n w u v
             thenLT [addHiddenLabelT "base case";
                     addHiddenLabelT "induction step"]
        | _ ->
             failT) p

let d_listT i =
   if i = 0 then
      d_concl_list
   else
      d_hyp_list i

let d_resource = d_resource.resource_improve d_resource (list_term, d_listT)

(************************************************************************
 * EQCD TACTICS                                                         *
 ************************************************************************)

(*
 * EqCD list.
 *)
let eqcd_listT p = listEquality (hyp_count p) p

let eqcd_resource = eqcd_resource.resource_improve eqcd_resource (list_term, eqcd_listT)

(*
 * EqCD nil.
 *)
let eqcd_nilT p = nilEquality (hyp_count p) p

let eqcd_resource = eqcd_resource.resource_improve eqcd_resource (nil_term, eqcd_nilT)

(*
 * EqCD nil.
 *)
let eqcd_consT p = consEquality (hyp_count p) p

let eqcd_resource = eqcd_resource.resource_improve eqcd_resource (cons_term, eqcd_consT)

(*
 * EQCD listind.
 *)
let eqcd_list_indT p =
   raise (RefineError ("eqcd_list_indT", StringError "not implemented"))

let eqcd_resource = eqcd_resource.resource_improve eqcd_resource (list_ind_term, eqcd_list_indT)

(************************************************************************
 * TYPE INFERENCE                                                       *
 ************************************************************************)

(*
 * Type of list.
 *)
let inf_list f decl t =
   let a = dest_list t in
      f decl a

let typeinf_resource = typeinf_resource.resource_improve typeinf_resource (list_term, inf_list)

(*
 * Type of nil.
 *)
let inf_nil f decl t =
   decl, mk_var_term (new_var "T" (List.map fst decl))

let typeinf_resource = typeinf_resource.resource_improve typeinf_resource (nil_term, inf_nil)

(*
 * Type of cons.
 *)
let inf_cons inf decl t =
   let hd, tl = dest_cons t in
   let decl', hd' = inf decl hd in
   let decl'', tl' = inf decl' tl in
      try unify decl'' (mk_list_term hd') tl', tl' with
         Term.BadMatch _ -> raise (RefineError ("typeinf", StringTermError ("can't infer type for", t)))

let typeinf_resource = typeinf_resource.resource_improve typeinf_resource (cons_term, inf_cons)

(*
 * Type of list_ind.
 *)
let inf_list_ind inf decl t =
   let e, base, hd, tl, f, step = dest_list_ind t in
   let decl', e' = inf decl e in
      if is_list_term e' then
         let decl'', base' = inf decl' base in
         let a = dest_list e' in
         let decl''', step' = inf ((hd, a)::(tl, e')::(f, base')::decl'') step in
            unify decl''' base' step', base'
      else
         raise (RefineError ("typeinf", StringTermError ("can't infer type for", t)))

let typeinf_resource = typeinf_resource.resource_improve typeinf_resource (list_ind_term, inf_list_ind)

(************************************************************************
 * SUBTYPING                                                            *
 ************************************************************************)

(*
 * Subtyping of two list types.
 *)
let list_subtypeT p =
   (listSubtype (hyp_count p)
    thenT addHiddenLabelT "subtype") p

let sub_resource =
   sub_resource.resource_improve
   sub_resource
   (DSubtype ([<< list{'A1} >>, << list{'A2} >>;
               << 'A2 >>, << 'A1 >>],
              list_subtypeT))

(*
 * $Log$
 * Revision 1.13  1998/07/01 04:37:42  nogin
 * Moved Refiner exceptions into a separate module RefineErrors
 *
 * Revision 1.12  1998/06/22 19:46:17  jyh
 * Rewriting in contexts.  This required a change in addressing,
 * and the body of the context is the _last_ subterm, not the first.
 *
 * Revision 1.11  1998/06/15 22:33:23  jyh
 * Added CZF.
 *
 * Revision 1.10  1998/06/12 13:47:31  jyh
 * D tactic works, added itt_bool.
 *
 * Revision 1.9  1998/06/09 20:52:38  jyh
 * Propagated refinement changes.
 * New tacticals module.
 *
 * Revision 1.8  1998/06/01 13:55:57  jyh
 * Proving twice one is two.
 *
 * Revision 1.7  1998/05/28 13:47:43  jyh
 * Updated the editor to use new Refiner structure.
 * ITT needs dform names.
 *
 * Revision 1.6  1998/04/24 02:43:33  jyh
 * Added more extensive debugging capabilities.
 *
 * Revision 1.5  1998/04/22 22:44:53  jyh
 * *** empty log message ***
 *
 * Revision 1.4  1998/04/09 18:26:07  jyh
 * Working compiler once again.
 *
 * Revision 1.3  1997/08/07 19:43:52  jyh
 * Updated and added Lori's term modifications.
 * Need to update all pattern matchings.
 *
 * Revision 1.2  1997/08/06 16:18:33  jyh
 * This is an ocaml version with subtyping, type inference,
 * d and eqcd tactics.  It is a basic system, but not debugged.
 *
 * Revision 1.1  1997/04/28 15:52:16  jyh
 * This is the initial checkin of Nuprl-Light.
 * I am porting the editor, so it is not included
 * in this checkin.
 *
 * Directories:
 *     refiner: logic engine
 *     filter: front end to the Ocaml compiler
 *     editor: Emacs proof editor
 *     util: utilities
 *     mk: Makefile templates
 *
 * Revision 1.4  1996/10/23 15:18:09  jyh
 * First working version of dT tactic.
 *
 * Revision 1.3  1996/05/21 02:16:54  jyh
 * This is a semi-working version before Wisconsin vacation.
 *
 * Revision 1.2  1996/04/11 13:34:04  jyh
 * This is the final version with the old syntax for terms.
 *
 * Revision 1.1  1996/03/30 01:37:15  jyh
 * Initial version of ITT.
 *
 * -*-
 * Local Variables:
 * Caml-master: "prlcomp.run"
 * End:
 * -*-
 *)
