doc <:doc<
   @module[Czf_itt_group_power]

   The @tt[Czf_itt_group_power] module defines the power operation
   in a group, i.e., it describes $x^n = x * x * ... * x$.

   $x^n$ is defined by induction on $n$ as
   $$
   @begin[array, l]
   @line{@item{@power{g; z; n} @equiv}}
   @line{@item{@space @space @space
     @ind{n; i; j; @op{g; @inv{g; z}; @power{g; z; (n + 1)}}; @id{g}; k; l; @op{g; z; @power{g; z; (n - 1)}}}}}
   @end[array]
   $$

   @docoff
   ----------------------------------------------------------------

   @begin[license]
   This file is part of MetaPRL, a modular, higher order
   logical framework that provides a logical programming
   environment for OCaml and other languages.

   See the file doc/htmlman/default.html or visit http://metaprl.org/
   for more information.

   Copyright (C) 2002 Xin Yu, Caltech

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

   Author: Xin Yu
   @email{xiny@cs.caltech.edu}
   @end[license]
>>

doc <:doc< @parents >>
extends Czf_itt_group
extends Itt_int_base
doc docoff

open Tactic_type.Conversionals

open Dtactic

(************************************************************************
 * TERMS                                                                *
 ************************************************************************)

doc terms
declare power{'g; 'z; 'n}
doc docoff

(************************************************************************
 * REWRITES                                                             *
 ************************************************************************)

doc <:doc<
   @rewrites

   The @tt{power} is defined by induction.
>>
prim_rw unfold_power : power{'g; 'z; 'n} <-->
   ind{'n; i, j. op{'g; inv{'g; 'z}; power{'g; 'z; ('n +@ 1)}}; id{'g}; k, l. op{'g; 'z; power{'g; 'z; ('n -@ 1)}}}
doc docoff

let fold_power = makeFoldC << power{'g; 'z; 'n} >> unfold_power

(************************************************************************
 * DISPLAY FORMS                                                        *
 ************************************************************************)

dform power_df : parens :: except_mode[src] :: power{'g; 'z; 'n} =
   `"power(" slot{'g} `"; " slot{'z}  `"; " slot{'n} `")"

(************************************************************************
 * RULES                                                                *
 ************************************************************************)

doc <:doc<
   @rules
   @modsubsection{Well-formedness}

   The $@power{g; z; n}$ is well-formed if $g$ is a label,
   $z$ is a set, and $n$ is an integer in ITT.
>>
interactive power_wf {| intro [] |} :
   sequent { <H> >- 'g IN label } -->
   sequent { <H> >- isset{'z} } -->
   sequent { <H> >- 'n IN int } -->
   sequent { <H> >- isset{power{'g; 'z; 'n}} }

doc <:doc<
   @modsubsection{Membership}

   If $z$ is a member of $@car{g}$, then $@power{g; z; n}$
   is also in $@car{g}$ for any integer $n$.
>>
interactive power_mem {| intro [] |} :
   sequent { <H> >- 'g IN label } -->
   sequent { <H> >- group{'g} } -->
   sequent { <H> >- 'n IN int } -->
   sequent { <H> >- isset{'z} } -->
   sequent { <H> >- mem{'z; car{'g}} } -->
   sequent { <H> >- mem{power{'g; 'z; 'n}; car{'g}} }

doc <:doc<
   @modsubsection{Functionality}

   The @tt{power} is functional in its set argument.
>>
interactive power_fun {| intro [] |} :
   sequent { <H> >- 'g IN label } -->
   sequent { <H> >- group{'g} } -->
   sequent { <H> >- 'n IN int } -->
   sequent { <H> >- fun_set{z. 'f['z]} } -->
   sequent { <H>; z: set >- mem{'f['z]; car{'g}} } -->
   sequent { <H> >- fun_set{z. power{'g; 'f['z]; 'n}} }
doc docoff

(* x ^ (n + 1) * x ^ (-1) = x ^ n *)
interactive power_less {| intro [] |} :
   sequent { <H> >- 'g IN label } -->
   sequent { <H> >- group{'g} } -->
   sequent { <H> >- 'n IN int } -->
   sequent { <H> >- isset{'x} } -->
   sequent { <H> >- mem{'x; car{'g}} } -->
   sequent { <H> >- eq{op{'g; power{'g; 'x; ('n +@ 1)}; inv{'g; 'x}}; power{'g; 'x; 'n}} }

(* x ^ n * x = x ^ (n + 1) *)
interactive power_more {| intro [] |} :
   sequent { <H> >- 'g IN label } -->
   sequent { <H> >- group{'g} } -->
   sequent { <H> >- 'n IN int } -->
   sequent { <H> >- isset{'x} } -->
   sequent { <H> >- mem{'x; car{'g}} } -->
   sequent { <H> >- eq{op{'g; power{'g; 'x; 'n}; 'x}; power{'g; 'x; ('n +@ 1)}} }

doc <:doc<
   @modsubsection{Power reduction}

   $x^m * x^n = x^{m + n}$
>>
interactive power_reduce1 {| intro [] |} :
   sequent { <H> >- 'g IN label } -->
   sequent { <H> >- group{'g} } -->
   sequent { <H> >- 'm IN int } -->
   sequent { <H> >- 'n IN int } -->
   sequent { <H> >- isset{'x} } -->
   sequent { <H> >- mem{'x; car{'g}} } -->
   sequent { <H> >- eq{op{'g; power{'g; 'x; 'm}; power{'g; 'x; 'n}}; power{'g; 'x; ('m +@ 'n)}} }

doc docoff
(*
 * -*-
 * Local Variables:
 * Caml-master: "editor.run"
 * End:
 * -*-
 *)
