(*
 * Functional Intermediate Representation formalized in MetaPRL.
 *
 * Define terms to represent Rawint sets.
 *
 * ----------------------------------------------------------------
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

include Base_theory

(*************************************************************************
 * Declarations.
 *************************************************************************)

(*
 * Bounds.
 * Here for completeness.
 *)
declare raw_open_bound{ 'num }
declare raw_inf_bound

(*
 * Intervals.
 * Represents a closed interval in the integers.
 * 'left and 'right should be numbers with 'left <= 'right.
 *)
declare raw_interval{ 'left; 'right }

(*
 * The set.
 * 'intervals should be a list of intervals, or nil in order to
 *    represent the empty set.
 *)
declare rawint_set{ 'intervals }