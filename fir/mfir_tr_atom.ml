doc <:doc<
   @module[Mfir_tr_atom]

   The @tt[Mfir_tr_atom] module defines the typing rules for FIR atoms.

   @docoff
   ------------------------------------------------------------------------

   @begin[license]
   This file is part of MetaPRL, a modular, higher order
   logical framework that provides a logical programming
   environment for OCaml and other languages.  Additional
   information about the system is available at
   http://www.metaprl.org/

   Copyright (C) 2002 Brian Emre Aydemir, Caltech

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

   Author: Brian Emre Aydemir
   @email{emre@cs.caltech.edu}
   @end[license]
>>

doc <:doc<
   @parents
>>

extends Mfir_list
extends Mfir_int_set
extends Mfir_ty
extends Mfir_exp
extends Mfir_sequent
extends Mfir_tr_base
extends Mfir_tr_types
extends Mfir_tr_atom_base

(**************************************************************************
 * Rules.
 **************************************************************************)

doc <:doc<
   @rules
   @modsubsection{Normal atoms}

   The type of the nil-value of a type is simply that type.
>>

prim ty_atomNil :
   sequent { <H> >- type_eq{ 'ty; 'ty; large_type } } -->
   sequent { <H> >- has_type["atom"]{ atomNil{ 'ty }; 'ty } }


doc <:doc<

   The atom <<atomInt{'i}>> has type <<tyInt>> if <<'i>> is in the
   set of 31-bit, signed integers.
>>

prim ty_atomInt :
   sequent { <H> >- member{ 'i; intset_max[31, "signed"] } } -->
   sequent { <H> >- has_type["atom"]{ atomInt{'i}; tyInt } }

doc <:doc<

   An enumeration atom <<atomEnum[i:n]{'n}>> has type <<tyEnum[i:n]>>
   if $ 0 <<le>> n < i $, and if <<tyEnum[i:n]>> is a well-formed type.
>>

prim ty_atomEnum :
   sequent { <H> >- type_eq{ tyEnum[i:n]; tyEnum[i:n]; small_type } } -->
   sequent { <H> >- "and"{int_le{0; 'n}; int_lt{'n; number[i:n]}} } -->
   sequent { <H> >- has_type["atom"]{atomEnum[i:n]{'n}; tyEnum[i:n]} }


doc <:doc<

   The atom << atomRawInt[p:n, sign:s]{'i} >> has type
   << tyRawInt[p:n, sign:s] >>, if $i$ is in the appropriate set of
   integers, and if << tyRawInt[p:n, sign:s] >> is a well-formed type.
>>

prim ty_atomRawInt :
   sequent { <H> >- type_eq{ tyRawInt[p:n, sign:s];
                                  tyRawInt[p:n, sign:s];
                                  large_type } } -->
   sequent { <H> >- member{ 'i; intset_max[p:n, sign:s] } } -->
   sequent { <H> >-
      has_type["atom"]{ atomRawInt[p:n, sign:s]{'i}; tyRawInt[p:n, sign:s] } }


doc <:doc<

   Due to the representation of floating-point values in the FIR theory,
   the typing rule for << atomFloat[p:n, value:s] >> reduces to
   checking if << tyFloat[p:n] >> is a well-formed type.
>>

prim ty_atomFloat :
   sequent { <H> >-
      type_eq{ tyFloat[p:n]; tyFloat[p:n]; large_type } } -->
   sequent { <H> >-
      has_type["atom"]{ atomFloat[p:n, value:s]; tyFloat[p:n] } }


doc <:doc<

   A variable << atomVar{'v} >> has type << 'ty >> if it is declared in
   the context to have type << 'ty >>.
>>

prim ty_atomVar 'H :
   sequent { <H>; a: var_def{ 'v; 'ty; 'd }; <J> >-
      has_type["atom"]{ atomVar{'v}; 'ty } }


doc <:doc<
   @modsubsection{Frames and constant constructors}

   The atom << atomLabel[field:s, subfield:s]{ 'frame; 'num } >>
   is used to index subfields of frame objects.  They are unsafe and
   treated as 32-bit, signed integers.  To be well-formed, the frame
   named must have the specified field and subfield, and << 'num >>
   should be a 32-bit, signed integer.
>>

prim ty_atomLabel 'H :
   sequent { <H>; a: ty_def{ 'frame; polyKind{ 'i; 'k }; 'd }; <J> >-
      field_mem[subfield:s]{ field[field:s]{ get_core{ 'i; 'd } } } } -->
   sequent { <H>; a: ty_def{ 'frame; polyKind{ 'i; 'k }; 'd }; <J> >-
      member{ 'num; intset_max[32, "signed"] } } -->
   sequent { <H>; a: ty_def{ 'frame; polyKind{ 'i; 'k }; 'd }; <J> >-
      has_type["atom"]{ atomLabel[field:s, subfield:s]{ 'frame; 'num };
                        tyRawInt[32, "signed"] } }


doc <:doc<

   The atom << atomSizeof{ 'tvl; 'num } >> is a constant representing
   the size of the frames named in the list << 'tvl >> plus some constant
   << 'num >>.  To be well-formed, each element of << 'tvl >> should
   be a type variable << tyVar{'tv} >> that names a frame definition,
   and << 'num >> should be a 32-bit, signed integer.
>>

prim ty_atomSizeof :
   sequent { <H> >- member{'num; intset_max[32, "signed"]} } -->
   sequent { <H> >- has_type["atomSizeof"]{ 'tvl; frame_type } } -->
   sequent { <H> >-
      has_type["atom"]{ atomSizeof{ 'tvl; 'num }; tyRawInt[32, "signed"] } }

prim ty_atomSizeof_aux_base :
   sequent { <H> >- has_type["atomSizeof"]{ nil; frame_type }}

prim ty_atomSizeof_aux_ind 'H :
   sequent { <H>; a: ty_def{ 'tv; polyKind{'i; frame_type}; 'd }; <J> >-
      has_type["atomSizeof"]{ 'rest; frame_type } } -->
   sequent { <H>; a: ty_def{ 'tv; polyKind{'i; frame_type}; 'd }; <J> >-
      has_type["atomSizeof"]{ (tyVar{'tv} :: 'rest); frame_type } }


doc <:doc<

   The atom << atomConst{ 'ty; 'tv; 'n } >> is a constant constructor
   for case << 'n >> of a union.  It is well-formed if it references
   a constant case of a union type and if the union type is well-formed.
>>

prim ty_atomConst 'H :
   sequent { <H>; a: ty_def{ 'tv; 'k; 'd }; <J> >-
      type_eq{ 'ty; tyUnion{ 'tv; 'tyl; intset[31, "signed"]{
         (interval{ 'n; 'n } :: nil) } }; small_type } } -->
   sequent { <H>; a: ty_def{ 'tv; 'k; 'd }; <J> >-
      type_eq_list{ nil; nth_elt{ 'n; apply_types{ 'd; 'tyl } };
         small_type } } -->
   sequent { <H>; a: ty_def{ 'tv; 'k; 'd }; <J> >-
      has_type["atom"]{ atomConst{ 'ty; 'tv; 'n }; tyUnion{ 'tv; 'tyl;
         intset[31, "signed"]{ (interval{ 'n; 'n } :: nil) } } } }


doc <:doc<
   @modsubsection{Polymorphism}

   The atom << atomTyApply{ atomVar{'v}; 'u1; 'types } >> instantiates
   << atomVar{'v} >> at a list of types, where << atomVar{'v} >> should
   have a universal type.
>>

prim ty_atomTyApply 'H :
   (* The type of the atom must agree with what it thinks its own type is. *)
   sequent { <H>;
                    a: var_def{ 'v; tyAll{ t. 'ty['t] }; 'd };
                    <J> >-
      type_eq{ 'u1; 'u2;  small_type } } -->

   (* The types being applied should be small. *)
   sequent { <H>;
                    a: var_def{ 'v; tyAll{ t. 'ty['t] }; 'd };
                    <J> >-
      type_eq_list{ 'types; 'types; small_type } } -->

   (* The type should correspond to the tyAll applied to the given types. *)
   sequent { <H>;
                    a: var_def{ 'v; tyAll{ t. 'ty['t] }; 'd };
                    <J> >-
      type_eq{ 'u1;
               apply_types{ tyAll{ t. 'ty['t] }; 'types };
               small_type } } -->

   (* Then the atom is well-typed. *)
   sequent { <H>;
                    a: var_def{ 'v; tyAll{ t. 'ty['t] }; 'd };
                    <J> >-
      has_type["atom"]{ atomTyApply{ atomVar{'v}; 'u1; 'types };
                        'u2 } }

doc <:doc<

   The atom << atomTyPack{ 'var; 'u; 'types } >> is the introduction
   form for type packing.  A value is packaged with a list of types
   to form a value with an existential type.
>>

prim ty_atomTyPack :
   sequent { <H> >-
      type_eq_list{ 'types; 'types; small_type } } -->
   sequent { <H> >-
      type_eq{ 'u; tyExists{ t. 'ty['t] }; small_type } } -->
   sequent { <H> >-
      has_type["atom"]{ 'var; apply_types{tyExists{t. 'ty['t]}; 'types} } } -->
   sequent { <H> >-
      has_type["atom"]{ atomTyPack{ 'var; 'u; 'types };
                        tyExists{ t. 'ty['t] } } }

doc <:doc<

   The atom << atomTyUnpack{ atomVar{'v} } >> is the elimination
   form for type packing.  If << atomVar{'v} >> has an existential type
   $t$, then the type unpacking has a type equal to $t$ instantiated
   at the types from the original packing.
>>

prim ty_atomTyUnpack 'H :
   sequent { <H>;
                    a: var_def{ 'v; tyExists{ t. 'ty['t] }; 'd };
                    <J> >-
      type_eq{ 'u;
               unpack_exists{ tyExists{ t. 'ty['t] }; 'v; 0 };
               large_type } } -->
   sequent { <H>;
                    a: var_def{ 'v; tyExists{ t. 'ty['t] }; 'd };
                    <J> >-
      has_type["atom"]{ atomTyUnpack{ atomVar{'v} }; 'u } }

doc <:doc<
   @modsubsection{Unary and binary operators}

   For the atoms << atomUnop{ 'unop; 'a } >> and
   << atomBinop{ 'binop; 'a1; 'a2 } >>, the typing rules are
   straightforward.  The arguments should have the correct type, and
   the result type of the operator should be equal to << 'ty >>.
>>

prim ty_atomUnop :
   sequent { <H> >- type_eq{ 'ty; res_type{ 'op }; large_type } } -->
   sequent { <H> >- has_type["atom"]{ 'a; arg1_type{ 'op } } } -->
   sequent { <H> >- has_type["atom"]{ atomUnop{ 'op; 'a }; 'ty } }

prim ty_atomBinop :
   sequent { <H> >- type_eq{ 'ty; res_type{ 'op }; large_type } } -->
   sequent { <H> >- has_type["atom"]{ 'a1; arg1_type{ 'op } } } -->
   sequent { <H> >- has_type["atom"]{ 'a2; arg2_type{ 'op } } } -->
   sequent { <H> >- has_type["atom"]{ atomBinop{ 'op; 'a1; 'a2 }; 'ty } }
