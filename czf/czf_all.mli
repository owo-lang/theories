(*
 * Universal quantification.
 *
 * ----------------------------------------------------------------
 *
 * This file is part of Nuprl-Light, a modular, higher order
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
 *)

include Czf_wf;;
include Czf_set;;
include Czf_implies;;
include Czf_member;;

declare "all"{x. 'P};;
define bounded_all_abs : "all"{'y; x. 'P['x]} <--> "all"{x. member{'x; 'y} => 'P['x]};;

(*
 * Bounded intro form.
 *
 * H >> all x: A. B[x]
 * by bounded_all_intro
 * H, x: A >> B[x]
 * H >> A wf
 *)
axiom bounded_all_intro 'y :
   sequent { 'H; y: 'A >> 'B['y] } -->
   sequent { 'H >> wf{'A} } -->
   sequent { 'H >> all x: 'A. 'B['x] };;

(*
 * Bounded elim form.
 *
 * H, y: (all x: A. B[x]), J >> T
 * by bounded_all_elim a
 * H, y: (all x: A. B[x]), J, z: B[a] >> T
 * H, y: (all x: A. B[x]), J >> member{'a; 'A}
 *)
axiom bounded_all_elim 'H 'J 'z 'a :
   sequent { 'H; y: (all x: 'A. 'B['y]); 'J; z: 'B['a] >> 'T } -->
   sequent { 'H; y: (all x: 'A. 'B['y]); 'J >> member{'a; 'A} } -->
   sequent { 'H; y: (all x: 'A. 'B['y]); 'J >> 'T };;

(*
 * Unbounded intro form.
 *
 * H >> all x. B[x]
 * by all_intro
 * H, x: Set >> B[x]
 *)
axiom all_intro 'y :
   sequent { 'H; y: set >> 'B['y] } -->
   sequent { 'H >> "all"{x. 'B['x]} };;

(*
 * Elim form.
 *
 * H, y: (all x. B[x]), J >> T
 * by all_elim z w
 * H, y: (all x. B[x]), J, w: B[z] >> T
 * H, y: (all x. B[x]), J >> member{z; set}
 *)
axiom all_elim 'H 'J 'w 'z :
   sequent { 'H; y: "all"{x. 'B['x]}; 'J; w: 'B['z] >> 'T } -->
   sequent { 'H; y: "all"{x. 'B['x]}; 'J >> member{'z; set} };;

(*
 * Wellformedness.
 *)
axiom bounded_all_wf :
   sequent { 'H >> wf{'A} } --> (* should be a different judgment? *)
   sequent { 'H; x: set >> wf{'B['x]} } -->
   sequent { 'H >> wf{all x: 'A. 'B['x] } };;

axiom all_wf :
   sequent { 'H; x: set >> wf{'B['x]} } -->
   sequent { 'H >> wf{"all"{x. 'B['x]}} };;

(*
 * Bounded formula is restricted.
 *)
axiom bounded_all_res :
   sequent { 'H >> restricted{'A} } -->
   sequent { 'H; x: set; y: restricted{x} >> restricted{'B['x]} } -->
   sequent { 'H >> restricted{all x: 'A. 'B['x]} };;
