(*
 * Set type.
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
 * Copyright (C) 1998 Jason Hickey, Cornell University
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
 * jyh@cs.cornell.edu
 *
 *)

extends Itt_equal
extends Itt_squash
extends Itt_subtype
extends Itt_unit
extends Itt_struct

open Refiner.Refiner.Term

open Tactic_type.Tacticals

declare set{'A; x. 'B['x]}

(************************************************************************
 * RULES                                                                *
 ************************************************************************)

(*
 * H >- Ui ext { a:A | B }
 * by setFormation A
 *
 * H >- A = A in Ui
 * H, a: A >- Ui ext B
 *)
rule setFormation 'A :
   sequent [squash] { <H> >- 'A = 'A in univ[i:l] } -->
   sequent ['ext] { <H>; 'A >- univ[i:l] } -->
   sequent ['ext] { <H> >- univ[i:l] }

(*
 * H >- { a1:A1 | B1[a1] } = { a2:A2 | B2[a2] } in Ui
 * by setEquality
 *
 * H >- A1 = A2 in Ui
 * H, x: A1 >- B1[x] = B2[x] in Ui
 *)
rule setEquality :
   sequent [squash] { <H> >- 'A1 = 'A2 in univ[i:l] } -->
   sequent [squash] { <H>; x: 'A1 >- 'B1['x] = 'B2['x] in univ[i:l] } -->
   sequent ['ext] { <H> >- { a1:'A1 | 'B1['a1] } = { a2:'A2 | 'B2['a2] } in univ[i:l] }

(*
 * H >- { a:A | B[a] } ext a
 * by setMemberFormation Ui a
 *
 * H >- a = a in A
 * H >- B[a]
 * H, z: A >- B[z] = B[z] in Ui
 *)
rule setMemberFormation 'a :
   sequent [squash] { <H> >- 'a = 'a in 'A } -->
   sequent [squash]   { <H> >- squash{'B['a]} } -->
   sequent [squash] { <H>; z: 'A >- "type"{'B['z]} } -->
   sequent ['ext]   { <H> >- { x:'A | 'B['x] } }

(*
 * H >- a1 = a2 in { a:A | B }
 * by setMemberEquality Ui
 *
 * H >- a1 = a2 in A
 * H >- B[a1]
 * H, x: A >- B[x] = B[x] in Ui
 *)
rule setMemberEquality :
   sequent [squash] { <H> >- 'a1 = 'a2 in 'A } -->
   sequent [squash] { <H> >- squash{'B['a1]} } -->
   sequent [squash] { <H>; x: 'A >- "type"{'B['x]} } -->
   sequent ['ext]   { <H> >- 'a1 = 'a2 in { a:'A | 'B['a] } }

(*
 * H, u: { x:A | B }, J[u] >- T[u] ext t[y]
 * by setElimination
 *
 * H, u: { x:A | B }, y: A; v: squash{B[y]}; J[y] >- T[y]
 *)
rule setElimination 'H :
   sequent ['ext] { <H>; u: 'A; squash{'B['u]}; <J['u]> >- 'T['u] } -->
   sequent ['ext] { <H>; u: { x:'A | 'B['x] }; <J['u]> >- 'T['u] }

(*
 * Subtyping.
 *)
rule set_subtype :
   sequent [squash] { <H> >- "type"{ { a: 'A | 'B['a] } } } -->
   sequent ['ext] { <H> >- \subtype{ { a: 'A | 'B['a] }; 'A } }

(************************************************************************
 * TACTICS                                                              *
 ************************************************************************)


(* Primitives *)
val is_set_term : term -> bool
val dest_set : term -> string * term * term
val mk_set_term : string -> term -> term -> term


(*
 * -*-
 * Local Variables:
 * Caml-master: "prlcomp.run"
 * End:
 * -*-
 *)
