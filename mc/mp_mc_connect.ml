(*
 * Functional Intermediate Representation formalized in MetaPRL.
 *
 * Define and implement the connection to the Mojave compiler FIR.
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

(* Open MC ML namespaces. *)

open Fir

(* Open MetaPRL ML namespaces. *)

open Fir_ty
open Fir_exp
open Mp_mc_connect_base
open Mp_mc_connect_ty
open Mp_mc_connect_exp

(*************************************************************************
 * Convert between Fir.prog and MetaPRL terms.
 *************************************************************************)

let fir_prog_to_term fir_prog =
   ()

let term_to_fir_prog term_exp =
   ()
