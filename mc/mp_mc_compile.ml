(*
 * Functional Intermediate Representation formalized in MetaPRL.
 *
 * Provides the primary interface to the MCC compiler.
 *
 * ----------------------------------------------------------------
 *
 * Copyright (C) 2002 Brian Emre Aydemir, Caltech
 *
 * This file is part of MetaPRL, a modular, higher order
 * logical framework that provides a logical programming
 * environment for OCaml and other languages.
 *
 * See the file doc/index.html for information on Nuprl,
 * OCaml, and more information about this system.
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
 * Email:  emre@its.caltech.edu
 *)

include Mp_mc_theory
include Mp_mc_fir_phobos
include Mp_mc_inline

open Symbol
open Fir

open Top_conversionals

open Mp_mc_base
open Mp_mc_fir_phobos
open Mp_mc_fir_eval
open Mp_mc_deadcode
open Mp_mc_connect_prog
open Mp_mc_inline

(*
 * These are the rewriters we want to use to rewrite terms.
 *)

let apply_rw_post =
   apply_rewrite (Mp_resource.theory_bookmark "Mp_mc_fir_phobos")

let apply_rw_inline =
   apply_rewrite (Mp_resource.theory_bookmark "Mp_mc_inline")

let apply_rw_top =
   apply_rewrite (Mp_resource.theory_bookmark "Mp_mc_theory")


(*************************************************************************
 * Taking input from Phobos.
 *************************************************************************)

(*
 * Takes a FIR term generated by Phobos, a list of post processing
 * rewrites, and a list of inline targets.  Performs the specified
 * post processing, inlining, and general optimizations, and returns
 * the new program.
 *)

let compile_phobos_fir program post_rewrites inline_targets =

   (* Print out initial input. *)
   debug_string "\n\nInitial program / Before PhoFIR -> FIR:\n\n";
   debug_string "\n\nProgram:\n\n";
   debug_term program;

   (* General reductions and simplifications. *)
   let program = apply_rw_top reduceC program in
   debug_string "\n\nAfter general reductions:\n\n";
   debug_term program;

   (* We apply each set of post-parsing rewrites one after another. *)
   let program = List.fold_left
      (fun term post_rewrites ->
         apply_rw_post (applyIFormsC post_rewrites) term)
      program
      post_rewrites
   in
   debug_string "\n\nAfter PhoFIR -> FIR\n\n";
   debug_term program;

   (* Inlining. *)
   let program =
      apply_rw_inline (firInlineC program inline_targets) program
   in
   debug_string "\n\nAfter inlining\n\n";
   debug_term program;

   (* Apply optimizations. *)
   let program = apply_rw_top firDeadcodeC program in
   let program = apply_rw_top firExpEvalC program in
   debug_string "\n\nFinal term (i.e. after remaining optimizations) =\n\n";
   debug_term program;
   debug_string "\n\nfirProg -> Fir.prog not implemented yet\n"


(*************************************************************************
 * Taking input from an MCC Fir.prog.
 *************************************************************************)

(*
 * Takes a MCC Fir.prog structure and applies some rewrites to it,
 * and then returns a new Fir.prog struct to MCC for further compilation.
 *)

let compile_mc_fir prog =
   debug_string "Entering Mp_mc_compile.compile_mc_fir.";

   let table = SymbolTable.map term_of_fundef prog.prog_funs in

   debug_string "Printing initial term structure.";
   let _ = SymbolTable.map debug_term table in

   let table = SymbolTable.map (apply_rw_top firDeadcodeC) table in
   let table = SymbolTable.map (apply_rw_top firExpEvalC) table in

   debug_string "Printing optimized term structure.";
   let _ = SymbolTable.map debug_term table in

   debug_string "Performing term -> Fir.prog conversion and returning.";
   let new_prog_funs = SymbolTable.map fundef_of_term table in
      { prog with prog_funs = new_prog_funs }
