include Czf_itt_set
include Czf_itt_member
include Czf_itt_empty
include Czf_itt_nat
include Czf_itt_sep
include Itt_bool

open Printf
open Mp_debug

open Refiner.Refiner
open Refiner.Refiner.Term
open Refiner.Refiner.TermOp
open Refiner.Refiner.TermSubst
open Refiner.Refiner.TermMan
open Refiner.Refiner.Refine
open Refiner.Refiner.RefineError
open Mp_resource
open Term_stable

open Tactic_type
open Tactic_type.Tacticals
open Tactic_type.Conversionals
open Tactic_type.Sequent
open Var
open Mptop

open Base_dtactic
open Base_auto_tactic

open Itt_rfun
open Itt_logic

let _ =
   show_loading "Loading Czf_itt_setdiff%t"


declare setdiff{'s1; 's2}

(*!
 * @begin[doc]
 * @rewrites
 *
 * The setdiff is defined using restricted separation.
 * @end[doc]
 *)
prim_rw unfold_setdiff : setdiff{'s1; 's2} <-->
   sep{'s1; x. "implies"{mem{'x; 's2}; ."false"}}
(*   set_ind{'s1; T1, f1, g1.
         collect{'T1; x. ifthenelse{mem{.'f1 'x; 's2}; empty; .'f1 'x}}} *)

(*! @docoff *)
let fold_setdiff = makeFoldC << setdiff{'s1; 's2} >> unfold_setdiff

prec prec_setdiff

dform setdiff_df : parens :: "prec"[prec_setdiff] :: setdiff{'s1; 's2} =
   slot{'s1} `" - " slot{'s2}

(*!
 * @begin[doc]
 * @rules
 * @thysubsection{Well-formedness}
 *
 * The setdiff well-formed if their arguments are both sets.
 * @end[doc]
 *)
interactive setdiff_isset {| intro [] |} 'H :
   ["wf"] sequent [squash] { 'H >- isset{'s1} } -->
   ["wf"] sequent [squash] { 'H >- isset{'s2} } -->
   sequent ['ext] { 'H >- isset{setdiff{'s1; 's2}} }

(*!
 * @begin[doc]
 * @thysubsection{Introduction}
 *
 * A set $x$ is in the difference set $setdiff{s1; s2}$ if $x$ is a
 * member of $s_1$ and $x$ is not a member of $s_2$.
 * @end[doc]
 *)
interactive setdiff_intro {| intro [] |} 'H 'x :
   ["wf"] sequent [squash] { 'H >- isset{'x} } -->
   ["wf"] sequent [squash] { 'H >- isset{'s1} } -->
   ["wf"] sequent [squash] { 'H >- isset{'s2} } -->
   sequent ['ext] { 'H >- mem{'x; 's1} } -->
   sequent ['ext] { 'H >- "implies"{mem{'x; 's2}; ."false"} } -->
   sequent ['ext] { 'H >- mem{'x; setdiff{'s1; 's2}} }

(*!
 * @begin[doc]
 * @thysubsection{Elimination}
 *
 * The elimination form of $setdiff{s_1; s_2}$ produces a proof that
 * $@mem{x; s_2}$ is wrong for which $@mem{x; s_1}$.
 * @end[doc]
 *)
interactive setdiff_elim {| elim [] |} 'H 'J :
   ["wf"] sequent [squash] { 'H; x: mem{'y; setdiff{'s1; 's2}}; 'J['x] >- isset{'y} } -->
   ["wf"] sequent [squash] { 'H; x: mem{'y; setdiff{'s1; 's2}}; 'J['x] >- isset{'s1} } -->
   ["wf"] sequent [squash] { 'H; x: mem{'y; setdiff{'s1; 's2}}; 'J['x] >- isset{'s2} } -->
   sequent ['ext] { 'H; x: mem{'y; setdiff{'s1; 's2}}; 'J['x]; u: mem{'y; 's1}; v: "implies"{mem{'y; 's2}; ."false"} >- 'T['x] } -->
   sequent ['ext] { 'H; x: mem{'y; setdiff{'s1; 's2}}; 'J['x] >- 'T['x] }

(*!
 * @begin[doc]
 * @thysubsection{Functionality}
 *
 * The setdiff type is functional in both set arguments.
 * @end[doc]
 *)
interactive setdiff_fun {| intro [] |} 'H :
   sequent ['ext] { 'H >- fun_set{z. 's1['z]} } -->
   sequent ['ext] { 'H >- fun_set{z. 's2['z]} } -->
   sequent ['ext] { 'H >- fun_set{z. setdiff{'s1['z]; 's2['z]}} }

(*
 * -*-
 * Local Variables:
 * Caml-master: "editor.run"
 * End:
 * -*-
 *)

(* interactive setdiff1 'H :
   sequent ['ext] {'H >- eq{setdiff{succ{empty}; empty}; succ{empty}} }

interactive setdiff2 'H :
   sequent ['ext] {'H >- eq{setdiff{succ{empty}; succ{empty}}; empty} }
*)