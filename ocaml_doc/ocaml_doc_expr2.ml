(*!
 * @begin[spelling]
 * adhoc cons deconstructed destructed doesn fst int
 * ll namespace obfuscation snd
 * @end[spelling]
 *
 * @begin[doc]
 * @chapter[tuples]{Tuples, Lists, and Polymorphism}
 * @end[doc]
 *
 * ----------------------------------------------------------------
 *
 * @begin[license]
 * Copyright (C) 2000 Jason Hickey, Caltech
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
 * @docoff
 *)

include Base_theory

(*!
@begin[doc]

In the chapters leading up to this one, we have seen simple
expressions involving numbers, characters, strings, functions and
variables.  This language is already Turing complete---we can code
arbitrary data types using numbers and functions.  Of course, in
practice, this would not only be inefficient, it would also make it
very hard to understand our programs.  For efficient, and readable,
data structure implementation we need @emph{aggregate types}.

OCaml provides a rich set of aggregate types, including tuples, lists,
disjoint union (also called tagged unions, or variant records),
records, and arrays.  In this chapter, we'll look at the simplest
part: tuples and lists.  We'll discuss unions in Chapter
@refchapter[unions], and we'll leave the remaining types for Chapter
@refchapter[records], when we introduce side-effects.

@section[polymorphism]{Polymorphism}

At this point, it is also appropriate to introduce
@emph{polymorphism}.  The ML languages provide @emph{parametric
polymorphism}.  That is, types may be parameterized by type
variables.  For example, the identity function in ML can be expressed
with a single function.

@begin[verbatim]
# let identity x = x;;
val identity : 'a -> 'a = <fun>
# identity 1;;
- : int = 1
# identity "Hello";;
- : string = "Hello"
@end[verbatim]

@emph{Type variables} are lowercase identifiers preceded by a single
quote (@code{'}).  A type variable represents an @emph{arbitrary}
type.  The typing @code{identity : 'a -> 'a} says that the
@tt{identity} function takes an argument of some arbitrary type
@code{'a} and returns a value of the same type @code{'a}.  If the
@tt{identity} function is applied to a @tt{int}, then it returns and
@tt{int}; if it is applied to a @tt{string}, then it returns a
@tt{string}.  The @tt{identity} function can even be applied to
function arguments.

@begin[verbatim]
# let succ i = i + 1;;
val succ : int -> int = <fun>
# identity succ;;
- : int -> int = <fun>
# (identity succ) 2;;
- : int = 3
@end[verbatim]

In this case, the @code{(identity succ)} expression returns the
@code{succ} function itself, which can be applied to @code{2} to
return @code{3}.

@subsection[value_restriction]{Value restriction}

What happens if the apply the @tt{identity} to a @emph{polymorphic}
function type?

@begin[verbatim]
# let identity' = identity identity;;
val identity' : '_a -> '_a = <fun>
# identity' 1;;
- : int = 1
# identity';;
- : int -> int = <fun>
# identity' "Hello";;
Characters 10-17:
This expression has type string but is here used with type int
@end[verbatim]

This doesn't quite work as we expect.  Note the type assignment
@code{identity' : '_a -> '_a}.  The type variables @code{'_a} are now
preceded by an underscore.  These type variables specify that the
@code{identity'} function takes an argument of @emph{some} type, and
returns a value of the same type.  This is a form of delayed
polymorphism.  When we apply the @tt{identity'} function to a number,
the type @code{'_a} is assigned to be @code{int}; the @tt{identity'}
function can no longer be applied to a string.

This behavior is due to the @emph{value restriction}: for an
expression to be truly polymorphic, it must be a value.  Values are
expressions that evaluate to themselves.  For example, all numbers,
characters, and string constants are values.  Functions are also
values.  Function applications, like @code{identity identity} are
@emph{not} values, because they can be simplified (the @code{identity
identity} expression evaluates to @code{identity}).

the normal way to get around the value restriction is to use
``eta-expansion,'' which is the technical term for adding extra
arguments to the function.  We know that @code{identity'} is a
function; we can add its argument explicitly.

@begin[verbatim]
# let identity' x = (identity identity) x;;
val identity' : 'a -> 'a = <fun>
# identity' 1;;
- : int = 1
# identity' "Hello";;
- : string = "Hello"
@end[verbatim]

The new version of @code{identity'} computes the same value, but now
it is properly polymorphic.  Why does OCaml have this restriction?  It
probably seems silly, but the value restriction is a simple way to
maintain correct typing in the presence of side-effects; it would not
be necessary in a purely functional language.  We'll revisit this in
Chapter @refchapter[records].

@subsection[poly_comparison]{Comparison with other languages}

Polymorphism can be a powerful tool.  In ML, a single identity
function can be defined that works on all types.  In a non-polymorphic
language, like C, a separate identity function would have to be
defined for each type.

@begin[verbatim]
int int_identity(int i)
{
   return i;
}

char *string_identity(char *s)
{
   return s;
}
@end[verbatim]

Another kind of polymorphism is @emph{overloading} (also called
@emph{adhoc} polymorphism).  Overloading allows several functions to
have the same name, but different types.  When that function is
applied, the compiler selects the appropriate function by checking the
type of the arguments.  For example, in Java we could define a class
that includes several definitions of addition for different types
(note that the @code{+} expression is already overloaded).

@begin[verbatim]
class Adder {
    int Add(int i, int j) {
       return i + j;
    }
    float Add(float x, float y) {
       return x + y;
    }
    String Add(String s1, String s2) {
       return s1.concat(s2);
    }
}
@end[verbatim]

The expression @code{Add(5, 7)} would evaluate to @code{12}, while the
expression @code{Add("Hello ", "world")} would evaluate to the string
@code{"Hello world"}.

OCaml does @emph{not} provide overloading.  There are probably two
main reasons.  One is technical: it is hard to provide both type
inference @emph{and} overloading at the same time.  For example,
suppose the @code{+} function were overloaded to work both on integers
and floating-point values.  What would be the type of the following
@code{add} function?  Would it be @code{int -> int -> int}, or
@code{float -> float -> float}?

@begin[verbatim]
let add x y =
   x + y;;
@end[verbatim]

The best solution would probably to have the compiler produce
@emph{two} instances of the @tt{add} function, one for integers and
another for floating point values.  This complicates the compiler, and
with a sufficiently rich type system, type inference may become
undecidable.  @emph{That} would be a problem.

The second reason for the omission is that overloading can make it
more difficult to understand programs.  It may not be obvious by
looking at the program text @emph{which} one of a function's instances
is being called, and there is no way for a compiler to check if all
the function's instances do ``similar'' things.

I'm not sure I buy this argument.  Properly used, overloading reduces
``namespace clutter'' by grouping similar functions under the same
name.  True, overloading is grounds for obfuscation, but OCaml is
already ripe for obfuscation by allowing arithmetic functions like
@code{(+)} to be redefined!

@section[tuples]{Tuples}

Tuples are the simplest aggregate type.  They correspond to the
@emph{ordered} tuples you have seen in mathematics, or set theory.  A
tuple is a collection of values of arbitrary type.  The syntax for a
tuple is a sequence of expression separated by commas.  for example,
the following tuple is a pair containing a number and a string.

@begin[verbatim]
# let p = 1, "Hello";;
val p : int * string = 1, "Hello"
@end[verbatim]

The syntax for the @emph{type} of a tuple is the type of the
components, separated by a @code{*}.  In this case, the type of the
pair is @code{int * string}.

Tuples can be ``deconstructed'' using pattern matching, with any of
the pattern matching constructs like @tt{let}, @tt{match}, @tt{fun},
or @tt{function}.  For example, to recover the parts of the pair in
the variables @tt{x} and @tt{y}, we might use a @tt{let} form.

@begin[verbatim]
# let x, y = p;;
val x : int = 1
val y : string = "Hello"
@end[verbatim]

The built-in function @tt{fst} and @tt{snd} return the components of
a pair, defined as follows.

@begin[verbatim]
# let fst (x, _) = x;;
val fst : 'a * 'b -> 'a = <fun>
# let snd (_, y) = y;;
val snd : 'a * 'b -> 'b = <fun>
# fst p;;
- : int = 1
# snd p;;
- : string = "Hello"
@end[verbatim]

Note that these functions are polymorphic.  The @tt{fst} and @tt{snd}
functions can be applied to a pair of any type @code{'a * 'b};
@tt{fst} returns a value of type @code{'a}, and @tt{snd} returns a
value of type @code{'b}.

There are no similar built-in functions for tuples with more than two
elements, but they can be defined.

@begin[verbatim]
# let t = 1, "Hello", 2.7;;
val t : int * string * float = 1, "Hello", 2.7
# let fst3 (x, _, _) = x;;
val fst3 : 'a * 'b * 'c -> 'a = <fun>
# fst3 t;;
- : int = 1
@end[verbatim]

Note also that the pattern assignment is @emph{simultaneous}.  The
following expression swaps the values of @tt{x} and @tt{y}.

@begin[verbatim]
# let x = 1;;
val x : int = 1
# let y = "Hello";;
val y : string = "Hello"
# let x, y = y, x;;
val x : string = "Hello"
val y : int = 1
@end[verbatim]

Since the components of a tuple are unnamed, tuples are most
appropriate if they have a small number of well-defined components.
For example, tuples would be an appropriate way of defining Cartesian
coordinates.

@begin[verbatim]
# type coord = int * int;;
type coord = int * int
# let make_coord x y = x, y;;
val make_coord : 'a -> 'b -> 'a * 'b = <fun>
# let x_of_coord = fst;;
val x_of_coord : 'a * 'b -> 'a = <fun>
# let y_of_coord = snd;;
val y_of_coord : 'a * 'b -> 'b = <fun>
@end[verbatim]

However, it would be awkward to use tuples for defining database
entries, like the following.  For that purpose, records would be more
appropriate.  Records are defined in Chapter @refchapter[records].

@begin[verbatim]
# (* Name, Height, Phone, Salary *)
  type db_entry = string * float * string * float;;
type db_entry = string * float * string * float
# let name_of_entry (name, _, _, _) = name;;
val name_of_entry : 'a * 'b * 'c * 'd -> 'a = <fun>
# let jason = ("Jason", 6.25, "626-395-6568", 50.0);;
val jason : string * float * string * float =
  "Jason", 6.25, "626-395-6568", 50
# name_of_entry jason;;
- : string = "Jason"
@end[verbatim]

@section[lists]{Lists}

Lists are also used extensively in OCaml programs.  A list contains a
sequence of values of the same type.  There are are two constructors:
the @code{[]} expression is the empty list, and the $e_1 @tt{::} e_2$
expression is the ``cons'' of expression $e_1$ onto the list $e_2$.

@begin[verbatim]
# let l = "Hello" :: "World" :: [];;
val l : string list = ["Hello"; "World"]
@end[verbatim]

The bracket syntax $[ e_1; @ldots; e_n ]$ is an alternate syntax for
the list containing the values computed by $e_1, @ldots, e_n$.

The syntax for a list with elements of type @tt{t} is @code{t list}.
The @tt{list} type is an instance of a @emph{parameterized} type.  A
@code{int list} is a list containing integers, a @code{string list} is
a list containing strings, and a @code{'a list} is a list containing
elements of some type @code{'a} (but all the elements have to have the
same type).

Lists can be destructed using pattern matching.  For example, here is
a function that adds up all the numbers in an @code{int list}.

@begin[verbatim]
# let rec sum = function
     [] -> 0
   | i :: l -> i + sum l;;
val sum : int list -> int = <fun>
# sum [1; 2; 3; 4];;
- : int = 10
@end[verbatim]

These functions can also be polymorphic.  The function to check if a
value @tt{x} is in a list @tt{l} could be defined as follows.

@begin[verbatim]
# let rec mem x l =
     match l with
        [] -> false
      | y :: l -> x = y || mem x l;;
val mem : 'a -> 'a list -> bool = <fun>
# mem "Jason" ["Hello"; "World"];;
- : bool = false
# mem "Dave" ["I'm"; "afraid"; "Dave"; "I"; "can't"; "do"; "that"];;
- : bool = true
@end[verbatim]

This function takes an argument of any type @code{'a}, and checks if
the element is in the @code{'a list}.

The standard ``map'' function, like @code{List.map}, is defined as
follows.

@begin[verbatim]
# let rec map f = function
   [] -> []
 | x :: l -> f x :: map f l;;
val map : ('a -> 'b) -> 'a list -> 'b list = <fun>
# map succ [1; 2; 3; 4];;
- : int list = [2; 3; 4; 5]
@end[verbatim]

The @tt{map} function takes a @emph{function} of type @code{'a -> 'b}
(this argument function takes a value of type @code{'a} and returns a
value of type @code{'b}), and a list containing elements of type
@code{'a}.  It returns a @code{'b list}.  Equivalently,

$$@tt{map}@space f@space[] [v_1; @ldots; v_n] = [f@space v_1; @ldots;
f@space v_n].$$

Lists are commonly used to represent sets of values, or key-value relationships.
The @tt{List} library contains many list functions.  The
@code{List.assoc} function returns the value for a key in a list.

@begin[verbatim]
# let entry =
     ["name", "Jason";
      "height", "6' 3''";
      "phone", "626-345-9692";
      "salary", "$50"];;
val entry : (string * string) list =
  ["name", "Jason"; "height", "6' 3''"; "phone", "626-345-9692";
   "salary", "$50"]
# List.assoc "phone" entry;;
- : string = "626-345-9692"
@end[verbatim]

Note that the comma separates the elements of the pairs in the list,
and the semicolon separates the items of the list.

@end[doc]
@docoff
*)

(*
 * -*-
 * Local Variables:
 * Caml-master: "compile"
 * End:
 * -*-
 *)