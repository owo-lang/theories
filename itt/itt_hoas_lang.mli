doc <:doc<
   @module[Itt_hoas_lang]
   The @tt[Itt_hoas_lang] module defines the type of a language over
   a list of operators.

   ----------------------------------------------------------------

   @begin[license]
   This file is part of MetaPRL, a modular, higher order
   logical framework that provides a logical programming
   environment for OCaml and other languages.

   See the file doc/htmlman/default.html or visit http://metaprl.org/
   for more information.

   Copyright (C) 2005, MetaPRL Group

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

   Authors: Xin Yu @email{xiny@cs.caltech.edu}

   @end[license]
>>

extends Itt_hoas_bterm

open Tactic_type.Tactic

define iform unfold_SubOp : SubOp{'ops} <--> {op:Operator | find{'ops; 'op; x,y.is_same_op{'x; 'y}} <> length{'ops} }

declare Lang{'ops}

topval fold_Lang : conv