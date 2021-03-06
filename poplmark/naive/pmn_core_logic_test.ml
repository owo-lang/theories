(*
 * Tests.
 *
 * ----------------------------------------------------------------
 *
 * @begin[license]
 * Copyright (C) 2003-2005 Mojave Group, Caltech
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
 * @end[license]
 *)
extends Itt_hoas_theory
extends Pmn_core_logic

open Basic_tactics
open Itt_equal
open Itt_dfun
open Itt_logic

interactive test_ref : <:xrule<
   fsub{| <H> >- fsub_subtype{T; T} |}
>>

(*
 * -*-
 * Local Variables:
 * End:
 * -*-
 *)
