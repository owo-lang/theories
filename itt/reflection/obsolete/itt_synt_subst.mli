doc <:doc<
   @module[Itt_synt_bterm]


   ----------------------------------------------------------------

   @begin[license]
   This file is part of MetaPRL, a modular, higher order
   logical framework that provides a logical programming
   environment for OCaml and other languages.

   See the file doc/htmlman/default.html or visit http://metaprl.org/
   for more information.

   Copyright (C) 2005 MetaPRL Group

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

   Authors: Alexei Kopylov @email{kopylov@cs.caltech.edu}
            Aleksey Nogin @email{nogin@cs.caltech.edu}
            Xin Yu @email{xiny@cs.caltech.edu}
   @end[license]
>>

open Basic_tactics

declare new_var{'bt}
declare last_var{'bt}
declare add_var{'bt;'v}
declare add_var{'bt}
declare make_depth{'s;'n}
declare add_vars_upto{'s;'t}
declare not_free{'v;'t}

declare subst{'t;'v;'s}

topval fold_add_var : conv
topval fold_subst : conv
topval fold_add_vars_upto : conv
topval fold_not_free : conv
topval fold_make_depth : conv
