(*!
 * @begin[doc]
 * @theory[Mp_mc_deadcode]
 *
 * The @tt{Mp_mc_inline} module defines rewrites for
 * inlining of tailCall's in FIR programs.
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
 * Copyright (C) 2002 Brian Emre Aydemir, Caltech
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
 * Author: Brian Emre Aydemir
 * @email{emre@its.caltech.edu}
 * @end[license]
 *)

(*!
 * @begin[doc]
 * @parents
 * @end[doc]
 *)
include Mp_mc_theory
include Mp_mc_inline_aux
(*! @docoff *)

open Refiner.Refiner.Term
open Refiner.Refiner.TermOp
open Top_conversionals
open Mp_mc_base
open Mp_mc_fir_eval
open Mp_mc_inline_aux

(* This is the rewriter we want to use in applying rewrites. *)

let apply_rewrite =
    apply_rewrite (Mp_resource.theory_bookmark "Mp_mc_inline_aux")

(*************************************************************************
 * Automation.
 *************************************************************************)

let firInlineTargetsC program inline_forms =
   let rewrites = List.map
      (fun (target, _) ->

         (* Build the contractum for this target. *)
         let get_func_body = mk_get_func_body_term target program in
         let body = apply_rewrite firInlineGetFuncBodyC get_func_body in
         let contractum = mk_inline_tailCall_term body target in

         (* Debugging output. *)
         debug_string "\n\ncontractum and redex\n\n";
         debug_term target;
         debug_string " <--> ";
         debug_term contractum;

         (* Build the rewrite. *)
         create_iform "inliner" true target contractum;
         debug_string "\n\nmade it this far\n\n";
         create_iform "inliner" true target contractum;

      ) inline_forms
   in
      (higherC (applyAllC rewrites))

let firInlineC program inline_forms =

   repeatC (

      (* Make one pass at inlining targets. *)
      (firInlineTargetsC program inline_forms) thenC

      (* Remvoe the inline_tailCall_prep term. *)
      firInlineInlineTailCallC thenC

      (* Normalize the program. *)
      reduceC thenC firExpEvalC

   )
