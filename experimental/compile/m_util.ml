(*
 * Generic utilities for the @emph{M} language.
 *
 * ----------------------------------------------------------------
 *
 * @begin[license]
 * Copyright (C) 2003-2006 Mojave Group, Caltech
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
 * Author: Jason Hickey
 * @email{jyh@cs.caltech.edu}
 * @end[license]
 *)

open Lm_debug
open Lm_printf

open Term_sig
open Refiner.Refiner.Term
open Refiner.Refiner.RefineError

open Tactic_type.Conversionals

(*
 * Display reductions.
 *)
let debug_reduce =
   create_debug (**)
      { debug_name = "m_reduce";
        debug_description = "display reductions during M conversion";
        debug_value = false
      }

(*
 * Helper functions for resources like reduceC.
 *)
let extract_data tbl =
   let rw e =
      let t = env_term e in
         (* Find and apply the right tactic *)
         if !debug_reduce then
            eprintf "M_util: lookup %a%t" debug_print t eflush;
         match Term_match_table.lookup tbl Term_match_table.select_all t with
            Some conv ->
               if !debug_reduce then
                  eprintf "M_util: applying %a%t" debug_print t eflush;
               conv
          | None ->
               raise (RefineError ("M_util.extract_data", StringTermError ("no reduction for", t)))
   in
      funC rw

let process_resource_annotation name cvars vars args params mterm conv =
   match mterm with
      MetaIff (MetaTheorem t, _) ->
         (t, conv)
    | _ ->
         raise (RefineError ("M_cps.improve_resource_arg", StringError "not a simple rewrite"))

(*
 * -*-
 * Local Variables:
 * Caml-master: "compile"
 * End:
 * -*-
 *)
