(*!
 * @begin[spelling]
 * acts Fibonacci inexhaustive ll patt wildcard
 * aren expr
 * @end[spelling]
 *
 * @begin[doc]
 * @chapter[ocaml_doc_patt1]{Basic Pattern Matching}
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
 *)

(*! @docoff *)
include Base_theory

(*!
 * @begin[doc]

One of the more powerful features of ML is that is uses @emph{pattern
matching} to define functions by case analysis.  Pattern matching is
performed by the @bf{match} expression, which has the following
general form.

@begin[center]
@begin[tabular, l]
@line{{@bf{match} @emph{expr} @bf{with}}}
@line{{@phantom{$$@space$$ |} $@emph{patt}_1$ @code{->} $@emph{expr}_1$}}
@line{{$@space$ | $@emph{patt}_2$ @code{->} $@emph{expr}_2$}}
@line{$@cdots$}
@line{{$@space$ | $@emph{patt}_n$ @code{->} $@emph{expr}_n$}}
@end[tabular]
@end[center]

A @emph{pattern} is an expression made of constants and variables.
When the pattern matches the argument, the variables are given the
values that match.

For example, Fibonacci numbers can be defined succinctly using pattern
matching.  Fibonacci numbers are defined inductively: $@tt{fib}@space
1 = 1$, $@emph{fib}@space 2 = 1$, for all other natural numbers $i$,
$@emph{fib}@space i = @emph{fib}(i - 1) + @emph{fib}(i - 2)$.

@begin[verbatim]
# let rec fib i =
     match i with
        0 -> 1
      | 1 -> 1
      | j -> fib (j - 2) + fib (j - 1);;
val fib : int -> int = <fun>
# fib 1;;
- : int = 1
# fib 2;;
- : int = 2
# fib 3;;
- : int = 3
# fib 6;;
- : int = 13
@end[verbatim]

In this code, the argument $i$ is compared against the constants 1 and
2.  If either of these cases match, the return value is 1.  The final
pattern is the variable $j$, which matches any argument.  When this
pattern is reached, $j$ takes on the value of the argument, and the
body @code{fib (j - 2) + fib (j - 1)} computes the returned value.

This form of matching, where the function body is a @bf{match}
expression applied to the function argument, is quite common in ML
programs.  OCaml defines an equivalent syntactic form to handle this
case, using the @bf{function} keyword (instead of @bf{fun}).  A
@bf{function} definition is just like a @bf{fun}, except that multiple
patterns are allowed.  The @tt{fib} definition using @bf{function} is
as follows.

@begin[verbatim]
# let rec fib = function
     0 -> 1
   | 1 -> 1
   | i -> fib (i - 1) + fib (i - 2);;
val fib : int -> int = <fun>
# fib 1;;
- : int = 1
# fib 6;;
- : int = 13
@end[verbatim]

Patterns can also be used the other basic types, like characters, strings,
and Boolean values.  In addition, multiple patterns @emph{without
variables} can be used for a single body.  For example, one way to
check for capital letters is the following function definition.

@begin[verbatim]
# let is_uppercase = function
   'A' | 'B' | 'C' | 'D' | 'E' | 'F' | 'G' | 'H'
 | 'I' | 'J' | 'K' | 'L' | 'M' | 'N' | 'O' | 'P'
 | 'Q' | 'R' | 'S' | 'T' | 'U' | 'V' | 'W' | 'X'
 | 'Y' | 'Z' ->
    true
 | c ->
    false;;
val is_uppercase : char -> bool = <fun>
# is_uppercase 'M';;
- : bool = true
# is_uppercase 'm';;
- : bool = false
@end[verbatim]

It is rather tedious to specify @emph{all} the letters one at a time.
OCaml also allows pattern @emph{ranges} $c_1 .. c_2$,
where $c_1$ and $c_2$ are character constants.

@begin[verbatim]
# let is_uppercase = function
     'A' .. 'Z' -> true
   | c -> false;;
val is_uppercase : char -> bool = <fun>
# is_uppercase 'M';;
- : bool = true
# is_uppercase 'm';;
- : bool = false
@end[verbatim]

Note that the pattern variable $c$ in these functions acts as a
``wildcard'' pattern to handle all non-uppercase characters.  The
variable itself is not used in the body @tt{false}.  This is another
commonly occurring structure, and OCaml provides a special pattern for
cases like these.  The @tt{_} pattern (a single underscore character)
is a pattern that matches anything.  It is not a variable (so it can't
be used in an expression).  By convention, the @tt{is_uppercase}
function would more appropriately be written using the wildcard
pattern.

@begin[verbatim]
# let is_uppercase = function
     'A' .. 'Z' -> true
   | _ -> false;;
val is_uppercase : char -> bool = <fun>
# is_uppercase 'M';;
- : bool = true
# is_uppercase 'm';;
- : bool = false
@end[verbatim]

@section[patt1_incomplete_match]{Incomplete matches}

You might wonder about what happens if all the cases are not
considered.  For example, what happens if we leave off the default
case in the @tt{is_uppercase} function?

@begin[verbatim]
# let is_uppercase = function
     'A' .. 'Z' -> true;;
Characters 19-49:
Warning: this pattern-matching is not exhaustive.
Here is an example of a value that is not matched:
'a'
val is_uppercase : char -> bool = <fun>
@end[verbatim]

The OCaml compiler (and toploop) is verbose about inexhaustive
patterns.  It warns that the pattern is non-exhaustive, and it even
suggests a case that is not matched.  An inexhaustive set of patterns
is usually an error---what would happen if we applied the
@tt{is_uppercase} function to a non-uppercase character?

@begin[verbatim]
# is_uppercase 'M';;
- : bool = true
# is_uppercase 'm';;
Uncaught exception: Match_failure("", 19, 49)
@end[verbatim]

Again. OCaml is fairly strict.  In the case where the pattern does not
match, it raises an @emph{exception} (we'll see more about exceptions
in Chapter @refchapter[exceptions]).  In this case, the exception
means that an error occurred during evaluation (a pattern matching
failure).

A word to the wise, @emph{heed the compiler warnings!}  The compiler
generates warnings for possible program errors.  As you build and
modify a program, these warnings will help you find places in the
program text that need work.  In some cases, you may be tempted to
ignore the compiler.  For example, in the following function, we know
that a complete match is not needed if the @tt{is_odd} function is
always applied to nonnegative numbers.

@begin[verbatim]
# let is_odd i =
     match i mod 2 with
        0 -> false
      | 1 -> true;;
Characters 18-69:
Warning: this pattern-matching is not exhaustive.
Here is an example of a value that is not matched:
2
val is_odd : int -> bool = <fun>
# is_odd 3;;
- : bool = true
# is_odd 12;;
- : bool = false
@end[verbatim]

However, @emph{do not} ignore the warning!  If you do, you will find
that you begin to ignore @emph{all} the compiler warnings---both real
and bogus.  Eventually, you will overlook real problems, and your
program will become hard to maintain.  For now, you should add the
default case that raises an exception manually.  The
@tt{Invalid_argument} exception is designed for this purpose.  It
takes a string argument that identifies the name of the place where
the failure occurred.  You can generate an exception with the
@emph{raise} construction.

@begin[verbatim]
# let is_odd i =
     match i mod 2 with
        0 -> false
      | 1 -> true
      | _ -> raise (Invalid_argument "is_odd");;
val is_odd : int -> bool = <fun>
# is_odd 3;;
- : bool = true
# is_odd (-1);;
Uncaught exception: Invalid_argument("is_odd")
@end[verbatim]

@section[patt1_everywhere]{Patterns are everywhere}

It may not be obvious at this point, but patterns are used in
@emph{all} the binding mechanisms, including the @tt{let} and @tt{fun}
constructions.  The general forms are as follows.

@begin[center]
@begin[tabular, l]
@line{@tt{let @emph{patt} = @emph{expr}}}
@line{@tt{fun @emph{patt} -> @emph{expr}}}
@end[tabular]
@end[center]

These aren't much use with constants because the pattern match will
always be non-exhaustive (except for the @tt{()} pattern).  However,
they will be handy when we introduce tuples and records in the next
Chapter.

@begin[verbatim]
# let is_one = fun 1 -> true;;
Characters 13-26:
Warning: this pattern-matching is not exhaustive.
Here is an example of a value that is not matched:
0
val is_one : int -> bool = <fun>
# let is_one 1 = true;;
Characters 11-19:
Warning: this pattern-matching is not exhaustive.
Here is an example of a value that is not matched:
0
val is_one : int -> bool = <fun>
# is_one 1;;
- : bool = true
# is_one 2;;
Uncaught exception: Match_failure("", 11, 19)
# let is_unit () = true;;
val is_unit : unit -> bool = <fun>
# is_unit ();;
- : bool = true
@end[verbatim]

 * @end[doc]
 *)

(*!
 * @docoff
 * -*-
 * Local Variables:
 * Caml-master: "compile"
 * End:
 * -*-
 *)