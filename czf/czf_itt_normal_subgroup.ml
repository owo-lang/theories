(*!
 * @spelling{normal_subg abelNormalSubgT}
 *
 * @begin[doc]
 * @theory[Czf_itt_normal_subgroup]
 *
 * The @tt{Czf_itt_normal_subgroup} module defines normal subgroups.
 * A subgroup $h$ of a group $g$ is @emph{normal} if its left and
 * right cosets coincide, that is, if
 * $$@forall a @in @car{g}. @equal{@lcoset{h; g; a}; @rcoset{h; g; a}}$$
 *
 * @end[doc]
 *
 * ----------------------------------------------------------------
 *
 * @begin[license]
 * This file is part of MetaPRL, a modular, higher order
 * logical framework that provides a logical programming
 * environment for OCaml and other languages.
 *
 * See the file doc/index.html for information on Nuprl,
 * OCaml, and more information about this system.
 *
 * Copyright (C) 2002 Xin Yu, Caltech
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 * Author: Xin Yu
 * @email{xiny@cs.caltech.edu}
 * @end[license]
 *)

(*! @doc{@parents} *)
include Czf_itt_subgroup
include Czf_itt_abel_group
include Czf_itt_coset
(*! @docoff *)

open Printf
open Mp_debug
open Refiner.Refiner
open Refiner.Refiner.Term
open Refiner.Refiner.TermOp
open Refiner.Refiner.TermMan
open Refiner.Refiner.TermSubst
open Refiner.Refiner.RefineError
open Mp_resource

open Tactic_type
open Tactic_type.Sequent
open Tactic_type.Tacticals
open Var
open Mptop

open Base_dtactic
open Base_auto_tactic

let _ =
   show_loading "Loading Czf_itt_normal_subgroup%t"

(************************************************************************
 * TERMS                                                                *
 ************************************************************************)

(*! @doc{@terms} *)
declare normal_subg{'s; 'g}
(*! @docoff *)

(************************************************************************
 * REWRITES                                                             *
 ************************************************************************)

(*!
 * @begin[doc]
 * @rewrites
 *
 * A subgroup $s$ of $g$ is normal if its left and right cosets coincides.
 * @end[doc]
 *)
prim_rw unfold_normal_subg : normal_subg{'s; 'g} <-->
   (subgroup{'s; 'g} & (all a: set. (mem{'a; car{'g}} => equal{lcoset{'s; 'g; 'a}; rcoset{'s; 'g; 'a}})))
(*! @docoff *)

(************************************************************************
 * DISPLAY FORMS                                                        *
 ************************************************************************)

dform normal_subg_df : except_mode[src] :: normal_subg{'s; 'g} =
   `"normal_subgroup(" slot{'s} `"; " slot{'g} `")"

(************************************************************************
 * RULES                                                                *
 ************************************************************************)

(*!
 * @begin[doc]
 * @rules
 * @thysubsection{Typehood}
 *
 * The @tt{normalsubg} judgment is well-formed if its
 * arguments are labels.
 * @end[doc]
 *)
interactive normalSubg_wf {| intro [] |} 'H :
   sequent [squash] { 'H >- 's IN label } -->
   sequent [squash] { 'H >- 'g IN label } -->
   sequent ['ext] { 'H >- group{'g} } -->
   sequent ['ext] { 'H >- "type"{normal_subg{'s; 'g}} }

(*!
 * @begin[doc]
 * @thysubsection{Introduction}
 *
 * The proposition $@normalsubg{s; g}$ is true if it is well-formed,
 * $s$ is a subgroup of $g$, and for any $a$ in $@car{g}$,
 * $@equal{@lcoset{s; g; a}; @rcoset{s; g; a}}$.
 * @end[doc]
 *)
interactive normalSubg_intro {| intro [] |} 'H :
   sequent [squash] { 'H >- 's IN label } -->
   sequent [squash] { 'H >- 'g IN label } -->
   sequent ['ext] { 'H >- subgroup{'s; 'g} } -->
   sequent ['ext] { 'H; a: set; x: mem{'a; car{'g}} >- equal{lcoset{'s; 'g; 'a}; rcoset{'s; 'g; 'a}} } -->
   sequent ['ext] { 'H >- normal_subg{'s; 'g} }

(*!
 * @begin[doc]
 * @thysubsection{Theorems}
 *
 * All subgroups of abelian groups are normal.
 * @end[doc]
 *)
interactive abel_subg_normal 'H 'J 's :
   sequent [squash] { 'H; x: abel{'g}; 'J['x] >- 's IN label } -->
   sequent [squash] { 'H; x: abel{'g}; 'J['x] >- 'g IN label } -->
   sequent ['ext] { 'H; x: abel{'g}; 'J['x] >- subgroup{'s; 'g} } -->
   sequent ['ext] { 'H; x: abel{'g}; 'J['x]; y: normal_subg{'s; 'g} >- 'C['x] } -->
   sequent ['ext] { 'H; x: abel{'g}; 'J['x] >- 'C['x] }

(*! @docoff *)
let abelNormalSubgT t i p =
   let j, k = Sequent.hyp_indices p i in
      abel_subg_normal j k t p

(*
 * -*-
 * Local Variables:
 * Caml-master: "editor.run"
 * End:
 * -*-
 *)