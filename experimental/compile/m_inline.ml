(*!
 * @begin[spelling]
 * inlining
 * @end[spelling]
 *
 * @begin[doc]
 * @module[Inline]
 *
 * Constant-folding and function inlining.
 * @end[doc]
 *
 * ----------------------------------------------------------------
 *
 * @begin[license]
 * Copyright (C) 2003 Jason Hickey, Caltech
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

(*!
 * @begin[doc]
 * @parents
 * @end[doc]
 *)
extends M_ir
(*! @docoff *)

open Base_meta

open Tactic_type.Tacticals
open Tactic_type.Conversionals

open Top_conversionals

(*!
 * @begin[doc]
 * We use the @MetaPRL builtin meta-arithmetic.
 * Arithmetic is performed using meta-terms, and we need a
 * way to convert back to a number.
 * @end[doc]
 *)
declare MetaInt{'e}

prim_rw meta_int_elim : MetaInt{meta_num[i:n]} <--> AtomInt[i:n]

(*! @doc{@rewrites} *)

(*!
 * @doc{Simple constant folding.}
 *)
prim_rw reduce_add :
   AtomBinop{AddOp; AtomInt[i:n]; AtomInt[j:n]} <--> MetaInt{meta_sum[i:n, j:n]}

prim_rw reduce_sub :
   AtomBinop{SubOp; AtomInt[i:n]; AtomInt[j:n]} <--> MetaInt{meta_diff[i:n, j:n]}

prim_rw reduce_mul :
   AtomBinop{MulOp; AtomInt[i:n]; AtomInt[j:n]} <--> MetaInt{meta_prod[i:n, j:n]}

prim_rw reduce_div :
   AtomBinop{DivOp; AtomInt[i:n]; AtomInt[j:n]} <--> MetaInt{meta_quot[i:n, j:n]}

(*!
 * @doc{Constant inlining.}
 *)
prim_rw reduce_let_atom_true :
   LetAtom{AtomTrue; v. 'e['v]} <--> 'e[AtomTrue]

prim_rw reduce_let_atom_false :
   LetAtom{AtomFalse; v. 'e['v]} <--> 'e[AtomFalse]

prim_rw reduce_let_atom_int :
   LetAtom{AtomInt[i:n]; v. 'e['v]} <--> 'e[AtomInt[i:n]]

prim_rw reduce_let_atom_var :
   LetAtom{AtomVar{'v1}; v2. 'e['v2]} <--> 'e['v1]

prim_rw reduce_if_true :
   If{AtomTrue; 'e1; 'e2} <--> 'e1

prim_rw reduce_if_false :
   If{AtomFalse; 'e1; 'e2} <--> 'e2

prim_rw unfold_atom_var_true :
   AtomVar{AtomTrue} <--> AtomTrue

prim_rw unfold_atom_var_false :
   AtomVar{AtomFalse} <--> AtomFalse

prim_rw unfold_atom_var_int :
   AtomVar{AtomInt[i:n]} <--> AtomInt[i:n]

(*! @docoff *)

(*
 * Add all these rules to the reduce resource.
 *)
let resource reduce +=
    [<< MetaInt{meta_num[i:n]} >>, meta_int_elim;

     << AtomBinop{AddOp; AtomInt[i:n]; AtomInt[j:n]} >>, (reduce_add thenC addrC [0] reduce_meta_sum);
     << AtomBinop{SubOp; AtomInt[i:n]; AtomInt[j:n]} >>, (reduce_sub thenC addrC [0] reduce_meta_diff);
     << AtomBinop{MulOp; AtomInt[i:n]; AtomInt[j:n]} >>, (reduce_mul thenC addrC [0] reduce_meta_prod);
     << AtomBinop{DivOp; AtomInt[i:n]; AtomInt[j:n]} >>, (reduce_div thenC addrC [0] reduce_meta_quot);

     << LetAtom{AtomTrue; v. 'e['v]} >>, reduce_let_atom_true;
     << LetAtom{AtomFalse; v. 'e['v]} >>, reduce_let_atom_false;
     << LetAtom{AtomInt[i:n]; v. 'e['v]} >>, reduce_let_atom_int;
     << LetAtom{AtomVar{'v1}; v2. 'e['v2]} >>, reduce_let_atom_var;
     << If{AtomTrue; 'e1; 'e2} >>, reduce_if_true;
     << If{AtomFalse; 'e1; 'e2} >>, reduce_if_false;

     << AtomVar{AtomTrue} >>, unfold_atom_var_true;
     << AtomVar{AtomFalse} >>, unfold_atom_var_false;
     << AtomVar{AtomInt[i:n]} >>, unfold_atom_var_int]

(*
 * Inlining.
 *)
let inlineT =
   onAllHypsT (fun i -> tryT (rw reduceC i)) thenT rw reduceC 0

(*
 * -*-
 * Local Variables:
 * Caml-master: "compile"
 * End:
 * -*-
 *)