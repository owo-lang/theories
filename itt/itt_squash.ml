(*
 * We also define a resource to prove squash stability.
 * Terms are "squash stable" if their proof can be inferred from the
 * fact that they are true.  The general form is a squash
 * proof is just:
 *     sequent [it; squash] { H >> T } -->
 *     sequent [it; it] { H >> T }
 *
 * $Log$
 * Revision 1.2  1998/04/21 19:54:56  jyh
 * Upgraded refiner for program extraction.
 *
 * Revision 1.1  1997/08/06 16:18:42  jyh
 * This is an ocaml version with subtyping, type inference,
 * d and eqcd tactics.  It is a basic system, but not debugged.
 *
 *)

open Term
open Term_stable
open Refine_sig
open Resource

include Tactic_type
include Sequent

(************************************************************************
 * TERMS                                                                *
 ************************************************************************)

declare ext
declare squash

(************************************************************************
 * TYPES                                                                *
 ************************************************************************)        

(*
 * Keep a table of tactics to prove squash stability.
 *)
type squash_data = tactic term_stable

(*
 * The resource itself.
 *)
resource (term * tactic, tactic, squash_data) squash_resource

(************************************************************************
 * PRIMITIVES                                                           *
 ************************************************************************)

let squash_term = << squash >>
let squash_opname = opname_of_term squash_term

(*
 * Is a goal squashed?
 *)
let is_squash_goal { tac_goal = s } =
   match dest_sequent s with
      [_; _; flag] ->
         opname_of_term flag == squash_opname
    | _ ->
         false

(************************************************************************
 * IMPLEMENTATION                                                       *
 ************************************************************************)
     
(*
 * Extract an SQUASH tactic from the data.
 * The tactic checks for an optable.
 *)
let extract_data base =
   let tbl = sextract base in
   let squash p =
      let t = concl p in
         try (slookup tbl t) p with
            Not_found ->
               raise (RefineError (StringTermError ("SQUASH tactic doesn't know about ", t)))
   in
      squash

(*
 * Wrap up the joiner.
 *)
let rec join_resource { resource_data = data1 } { resource_data = data2 } =
   { resource_data = join_stables data1 data2;
     resource_join = join_resource;
     resource_extract = extract_resource;
     resource_improve = improve_resource
   }
      
and extract_resource { resource_data = data } =
   extract_data data
   
and improve_resource { resource_data = data } (t, tac) =
   { resource_data = sinsert data t tac;
     resource_join = join_resource;
     resource_extract = extract_resource;
     resource_improve = improve_resource
   }

(*
 * Resource.
 *)
let squash_resource =
   { resource_data = new_stable ();
     resource_join = join_resource;
     resource_extract = extract_resource;
     resource_improve = improve_resource
   }

(*
 * Resource argument.
 *)
let squash_of_proof { tac_arg = { ref_rsrc = { ref_squash = squash } } } = squash

(*
 * -*-
 * Local Variables:
 * Caml-master: "editor.run"
 * End:
 * -*-
 *)
