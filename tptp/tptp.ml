(*
 * These are the basic terms and axioms of TPTP.
 *)

include Itt_theory

open Printf
open Nl_debug

open Refiner.Refiner.Term
open Refiner.Refiner.TermOp
open Refiner.Refiner.RefineError
open Resource

open Tacticals
open Conversionals
open Var

open Base_auto_tactic

open Itt_equal
open Itt_rfun
open Itt_logic
open Itt_derive

(************************************************************************
 * TERMS                                                                *
 ************************************************************************)

(* All and exists are always bound over atom *)
declare "all"{v. 'b['v]}
declare "exists"{v. 'b['v]}
declare atomic{'b}

declare "atom0"
declare "atom1"
declare "atom2"
declare "atom3"
declare "atom4"
declare "atom5"
declare "prop0"
declare "prop1"
declare "prop2"
declare "prop3"
declare "prop4"
declare "prop5"

primrw unfold_atomic : "atomic"{'x} <--> ('x = 'x in atom)
primrw unfold_all : "all"{v. 'b['v]} <--> Itt_logic!"all"{atom; v. 'b['v]}
primrw unfold_exists : "exists"{v. 'b['v]} <--> Itt_logic!"exists"{atom; v. 'b['v]}

primrw unfold_atom0 : atom0 <-->
                          atom
primrw unfold_atom1 : atom1 <-->
                          atom -> atom
primrw unfold_atom2 : atom2 <-->
                          atom -> atom -> atom
primrw unfold_atom3 : atom3 <-->
                          atom -> atom -> atom -> atom
primrw unfold_atom4 : atom4 <-->
                          atom -> atom -> atom -> atom -> atom
primrw unfold_atom5 : atom5 <-->
                          atom -> atom -> atom -> atom -> atom -> atom

primrw unfold_prop0 : prop0 <-->
                          univ[1:l]
primrw unfold_prop1 : prop1 <-->
                          atom -> univ[1:l]
primrw unfold_prop2 : prop2 <-->
                          atom -> atom -> univ[1:l]
primrw unfold_prop3 : prop3 <-->
                          atom -> atom -> atom -> univ[1:l]
primrw unfold_prop4 : prop4 <-->
                          atom -> atom -> atom -> atom -> univ[1:l]
primrw unfold_prop5 : prop5 <-->
                          atom -> atom -> atom -> atom -> atom -> univ[1:l]

primrw unfold_apply2 : "apply"{'f1; 'x1; 'x2} <--> ('f1 'x1 'x2)
primrw unfold_apply3 : "apply"{'f1; 'x1; 'x2; 'x3} <--> ('f1 'x1 'x2 'x3)
primrw unfold_apply4 : "apply"{'f1; 'x1; 'x2; 'x3; 'x4} <--> ('f1 'x1 'x2 'x3 'x4)
primrw unfold_apply5 : "apply"{'f1; 'x1; 'x2; 'x3; 'x4; 'x5} <--> ('f1 'x1 'x2 'x3 'x4 'x5)

let fold_atomic = makeFoldC << atomic{'x} >> unfold_atomic
let fold_all    = makeFoldC << "all"{v. 'b['v]} >> unfold_all
let fold_exists = makeFoldC << "exists"{v. 'b['v]} >> unfold_exists

let fold_atom0  = makeFoldC << atom0 >> unfold_atom0
let fold_atom1  = makeFoldC << atom1 >> unfold_atom1
let fold_atom2  = makeFoldC << atom2 >> unfold_atom2
let fold_atom3  = makeFoldC << atom3 >> unfold_atom3
let fold_atom4  = makeFoldC << atom4 >> unfold_atom4
let fold_atom5  = makeFoldC << atom5 >> unfold_atom5

let fold_prop0  = makeFoldC << prop0 >> unfold_prop0
let fold_prop1  = makeFoldC << prop1 >> unfold_prop1
let fold_prop2  = makeFoldC << prop2 >> unfold_prop2
let fold_prop3  = makeFoldC << prop3 >> unfold_prop3
let fold_prop4  = makeFoldC << prop4 >> unfold_prop4
let fold_prop5  = makeFoldC << prop5 >> unfold_prop5

let fold_apply2 = makeFoldC << apply{'f; 'x1; 'x2} >> unfold_apply2
let fold_apply3 = makeFoldC << apply{'f; 'x1; 'x2; 'x3} >> unfold_apply3
let fold_apply4 = makeFoldC << apply{'f; 'x1; 'x2; 'x3; 'x4} >> unfold_apply4
let fold_apply5 = makeFoldC << apply{'f; 'x1; 'x2; 'x3; 'x4; 'x5} >> unfold_apply5

(************************************************************************
 * DISPLAY FORMS                                                        *
 ************************************************************************)

declare all_df{'b}
declare exists_df{'b}

dform all_df1 : "all"{v. 'b} =
   Nuprl_font!"forall" slot{'v} all_df{'b}

dform all_df2 : all_df{."all"{v. 'b}} =
   `"," slot{'v} all_df{'b}

dform all_df3 : all_df{'b} =
   `"." " " slot{'b}

dform exists_df1 : "exists"{v. 'b} =
   Nuprl_font!"exists" slot{'v} exists_df{'b}

dform exists_df2 : exists_df{."exists"{v. 'b}} =
   `"," slot{'v} exists_df{'b}

dform exists_df3 : exists_df{'b} =
   `"." " " slot{'b}

dform atomic_df : mode[prl] :: parens :: "prec"[prec_apply] :: atomic{'x} =
   slot{'x} `" atomic"

dform atom0_df : mode[prl] :: atom0 = `"atom0"
dform atom1_df : mode[prl] :: atom1 = `"atom1"
dform atom2_df : mode[prl] :: atom2 = `"atom2"
dform atom3_df : mode[prl] :: atom3 = `"atom3"
dform atom4_df : mode[prl] :: atom4 = `"atom4"
dform atom5_df : mode[prl] :: atom5 = `"atom5"

dform prop0_df : mode[prl] :: prop0 = `"prop0"
dform prop1_df : mode[prl] :: prop1 = `"prop1"
dform prop2_df : mode[prl] :: prop2 = `"prop2"
dform prop3_df : mode[prl] :: prop3 = `"prop3"
dform prop4_df : mode[prl] :: prop4 = `"prop4"
dform prop5_df : mode[prl] :: prop5 = `"prop5"

dform apply2_df : mode[prl] :: parens :: "prec"[prec_apply] :: apply{'f; 'x1; 'x2} =
   szone pushm[0] slot{'f} hspace slot{'x1} hspace slot{'x2} popm ezone

dform apply3_df : mode[prl] :: parens :: "prec"[prec_apply] :: apply{'f; 'x1; 'x2; 'x3} =
   szone pushm[0] slot{'f} hspace slot{'x1} hspace slot{'x2} hspace slot{'x3} popm ezone

dform apply4_df : mode[prl] :: parens :: "prec"[prec_apply] :: apply{'f; 'x1; 'x2; 'x3; 'x4} =
   szone pushm[0] slot{'f} hspace slot{'x1} hspace slot{'x2} hspace slot{'x3} hspace slot{'x4} popm ezone

dform apply5_df : mode[prl] :: parens :: "prec"[prec_apply] :: apply{'f; 'x1; 'x2; 'x3; 'x4; 'x5} =
   szone pushm[0] slot{'f} hspace slot{'x1} hspace slot{'x2} hspace slot{'x4} hspace slot{'x5} popm ezone

(************************************************************************
 * RULES                                                                *
 ************************************************************************)

(*
 * Intro and elimination forms.
 *)
interactive tptp_all_type 'H 'x :
   sequent [squash] { 'H; x: atom >- "type"{'b['x]} } -->
   sequent ['ext] { 'H >- "type"{."all"{v. 'b['v]}} }

interactive tptp_all_intro 'H 'v :
   sequent ['ext] { 'H; v: atom >- 'b['v] } -->
   sequent ['ext] { 'H >- "all"{x. 'b['x]} }

interactive tptp_all_elim 'H 'J 'z 'y :
   sequent [squash] { 'H; x: "all"{v. 'b['v]}; 'J['x] >- atomic{'z} } -->
   sequent ['ext] { 'H; x: "all"{v. 'b['v]}; 'J['x]; y: 'b['z] >- 'C['x] } -->
   sequent ['ext] { 'H; x: "all"{v. 'b['v]}; 'J['x] >- 'C['x] }

interactive tptp_exists_type 'H 'x :
   sequent [squash] { 'H; x: atom >- "type"{'b['x]} } -->
   sequent ['ext] { 'H >- "type"{."exists"{v. 'b['v]}} }

interactive tptp_exists_intro 'H 'x 'z :
   sequent [squash] { 'H >- atomic{'z} } -->
   sequent ['ext] { 'H >- 'b['z] } -->
   sequent [squash] { 'H; x: atom >- "type"{'b['x]} } -->
   sequent ['ext] { 'H >- "exists"{v. 'b['v]} }

interactive tptp_exists_elim 'H 'J 'y 'z :
   sequent ['ext] { 'H; y: atom; z: 'b['y]; 'J['y, 'z] >- 'C['y, 'z] } -->
   sequent ['ext] { 'H; x: "exists"{v. 'b['v]}; 'J['x] >- 'C['x] }

(*
 * Simplified rule for atomicity.
 *)
interactive tptp_atomic_type 'H :
   sequent [squash] { 'H >- atomic{'x} } -->
   sequent ['ext] { 'H >- "type"{atomic{'x}} }

interactive tptp2_atomic_intro0 'H 'J : :
   sequent ['ext] { 'H; x: atom0; 'J['x] >- atomic{'x} }

interactive tptp2_atomic_intro1 'H 'J :
   sequent [squash] { 'H; f: atom1; 'J['f] >- atomic{'x1} } -->
   sequent ['ext] { 'H; f: atom1; 'J['f] >- atomic{.'f 'x1} }

interactive tptp2_atomic_intro2 'H 'J :
   sequent [squash] { 'H; f: atom2; 'J['f] >- atomic{'x1} } -->
   sequent [squash] { 'H; f: atom2; 'J['f] >- atomic{'x2} } -->
   sequent ['ext] { 'H; f: atom2; 'J['f] >- atomic{.apply{'f; 'x1; 'x2}} }

interactive tptp2_atomic_intro3 'H 'J :
   sequent [squash] { 'H; f: atom3; 'J['f] >- atomic{'x1} } -->
   sequent [squash] { 'H; f: atom3; 'J['f] >- atomic{'x2} } -->
   sequent [squash] { 'H; f: atom3; 'J['f] >- atomic{'x3} } -->
   sequent ['ext] { 'H; f: atom3; 'J['f] >- atomic{.apply{'f; 'x1; 'x2; 'x3}} }

interactive tptp2_atomic_intro4 'H 'J :
   sequent [squash] { 'H; f: atom4; 'J['f] >- atomic{'x1} } -->
   sequent [squash] { 'H; f: atom4; 'J['f] >- atomic{'x2} } -->
   sequent [squash] { 'H; f: atom4; 'J['f] >- atomic{'x3} } -->
   sequent [squash] { 'H; f: atom4; 'J['f] >- atomic{'x4} } -->
   sequent ['ext] { 'H; f: atom4; 'J['f] >- atomic{.apply{'f; 'x1; 'x2; 'x3; 'x4}} }

interactive tptp2_atomic_intro5 'H 'J :
   sequent [squash] { 'H; f: atom5; 'J['f] >- atomic{'x1} } -->
   sequent [squash] { 'H; f: atom5; 'J['f] >- atomic{'x2} } -->
   sequent [squash] { 'H; f: atom5; 'J['f] >- atomic{'x3} } -->
   sequent [squash] { 'H; f: atom5; 'J['f] >- atomic{'x4} } -->
   sequent [squash] { 'H; f: atom5; 'J['f] >- atomic{'x5} } -->
   sequent ['ext] { 'H; f: atom5; 'J['f] >- atomic{.apply{'f; 'x1; 'x2; 'x3; 'x4; 'x5}} }

(*
 * Simplified rules for typing.
 *)
interactive tptp2_type_intro0 'H 'J : :
   sequent ['ext] { 'H; x: prop0; 'J['x] >- "type"{'x} }

interactive tptp2_type_intro1 'H 'J :
   sequent [squash] { 'H; f: prop1; 'J['f] >- atomic{'x1} } -->
   sequent ['ext] { 'H; f: prop1; 'J['f] >- "type"{.'f 'x1} }

interactive tptp2_type_intro2 'H 'J :
   sequent [squash] { 'H; f: prop2; 'J['f] >- atomic{'x1} } -->
   sequent [squash] { 'H; f: prop2; 'J['f] >- atomic{'x2} } -->
   sequent ['ext] { 'H; f: prop2; 'J['f] >- "type"{.apply{'f; 'x1; 'x2}} }

interactive tptp2_type_intro3 'H 'J :
   sequent [squash] { 'H; f: prop3; 'J['f] >- atomic{'x1} } -->
   sequent [squash] { 'H; f: prop3; 'J['f] >- atomic{'x2} } -->
   sequent [squash] { 'H; f: prop3; 'J['f] >- atomic{'x3} } -->
   sequent ['ext] { 'H; f: prop3; 'J['f] >- "type"{.apply{'f; 'x1; 'x2; 'x3}} }

interactive tptp2_type_intro4 'H 'J :
   sequent [squash] { 'H; f: prop4; 'J['f] >- atomic{'x1} } -->
   sequent [squash] { 'H; f: prop4; 'J['f] >- atomic{'x2} } -->
   sequent [squash] { 'H; f: prop4; 'J['f] >- atomic{'x3} } -->
   sequent [squash] { 'H; f: prop4; 'J['f] >- atomic{'x4} } -->
   sequent ['ext] { 'H; f: prop4; 'J['f] >- "type"{.apply{'f; 'x1; 'x2; 'x3; 'x4}} }

interactive tptp2_type_intro5 'H 'J :
   sequent [squash] { 'H; f: prop5; 'J['f] >- atomic{'x1} } -->
   sequent [squash] { 'H; f: prop5; 'J['f] >- atomic{'x2} } -->
   sequent [squash] { 'H; f: prop5; 'J['f] >- atomic{'x3} } -->
   sequent [squash] { 'H; f: prop5; 'J['f] >- atomic{'x4} } -->
   sequent [squash] { 'H; f: prop5; 'J['f] >- atomic{'x5} } -->
   sequent ['ext] { 'H; f: prop5; 'J['f] >- "type"{.apply{'f; 'x1; 'x2; 'x3; 'x4; 'x5}} }

(************************************************************************
 * OPERATIONS                                                           *
 ************************************************************************)

(*
 * Applications.
 *)
let apply_term = << 'f 'x >>
let apply_opname = opname_of_term apply_term

let rec mk_apply_term = function
   [] ->
      raise (Failure "mk_apply_term")
 | [f] ->
      f
 | args ->
      mk_simple_term apply_opname args

let is_apply_term t =
   let opname = opname_of_term t in
      Opname.eq opname apply_opname

let dest_apply t =
   if is_apply_term t then
      dest_simple_term_opname apply_opname t
   else
      [t]

let arity_of_apply t =
   if is_apply_term t then
      (List.length (subterms_of_term t)) - 1
   else
      0

let head_of_apply t =
   List.hd (dest_apply t)

(*
 * Disjunction.
 *)
let rec mk_or_term = function
   [t] ->
      t
 | h::t ->
      Itt_logic.mk_or_term h (mk_or_term t)
 | [] ->
      raise (RefineError ("mk_or_term", StringError "no terms"))

let rec dest_or t =
   if Itt_logic.is_or_term t then
      let t1, t2 = Itt_logic.dest_or t in
         t1 :: dest_or t2
   else
      [t]

let rec mk_and_term = function
   [t] ->
      t
 | h::t ->
      Itt_logic.mk_and_term h (mk_and_term t)
 | [] ->
      raise (RefineError ("mk_and_term", StringError "no terms"))

let rec dest_and t =
   if Itt_logic.is_and_term t then
      let t1, t2 = Itt_logic.dest_and t in
         t1 :: dest_and t2
   else
      [t]

let all_term = << "all"{v. 'b['v]} >>
let all_opname = opname_of_term all_term
let is_all_term = is_dep1_term all_opname

let rec mk_all_term vars t =
   match vars with
      [] ->
         t
    | v :: vars ->
         mk_dep1_term all_opname v (mk_all_term vars t)

let rec dest_all t =
   if is_all_term t then
      let v, t = dest_dep1_term all_opname t in
      let vars, t = dest_all t in
         v :: vars, t
   else
      [], t

let var_of_all t =
   fst (dest_dep1_term all_opname t)

let exists_term = << "exists"{v. 'b['v]} >>
let exists_opname = opname_of_term exists_term
let is_exists_term = is_dep1_term exists_opname

let rec mk_exists_term vars t =
   match vars with
      [] ->
         t
    | v :: vars ->
         mk_dep1_term exists_opname v (mk_exists_term vars t)

let rec dest_exists t =
   if is_exists_term t then
      let v, t = dest_dep1_term exists_opname t in
      let vars, t = dest_exists t in
         v :: vars, t
   else
      [], t

let var_of_exists t =
   fst (dest_dep1_term exists_opname t)

(*
 * Atomic proposition.
 *)
let atomic_term = << atomic{'x} >>
let atomic_opname = opname_of_term atomic_term
let is_atomic_term = is_dep0_term atomic_opname
let mk_atomic_term = mk_dep0_term atomic_opname
let dest_atomic = dest_dep0_term atomic_opname

(************************************************************************
 * TACTICS                                                              *
 ************************************************************************)

(*
 * All decomposition.
 *)
let d_allT i p =
   if i = 0 then
      let v = maybe_new_vars1 p (var_of_all (Sequent.concl p)) in
         tptp_all_intro (Sequent.hyp_count_addr p) v p
   else
      let t = get_with_arg p in
      let v = maybe_new_vars1 p "v" in
      let j, k = Sequent.hyp_indices p i in
         (tptp_all_elim j k t v
          thenLT [addHiddenLabelT "wf";
                  addHiddenLabelT "main"]) p

let d_resource = d_resource.resource_improve d_resource (all_term, d_allT)

let d_all_typeT i p =
   if i = 0 then
      let v = maybe_new_vars1 p "v" in
         tptp_all_type (Sequent.hyp_count_addr p) v p
   else
      raise (RefineError ("d_all_typeT", StringError "no elimination form"))

let all_type_term = << "type"{."all"{v. 'b['v]}} >>

let d_resource = d_resource.resource_improve d_resource (all_type_term, d_all_typeT)

(*
 * Exists decomposition.
 *)
let d_existsT i p =
   if i = 0 then
      let t = get_with_arg p in
      let v = maybe_new_vars1 p (var_of_exists (Sequent.concl p)) in
         (tptp_exists_intro (Sequent.hyp_count_addr p) v t
          thenLT [addHiddenLabelT "wf";
                  addHiddenLabelT "main";
                  addHiddenLabelT "wf"]) p
   else
      let _, hyp = Sequent.nth_hyp p i in
      let u, v = maybe_new_vars2 p (var_of_exists hyp) "v" in
      let j, k = Sequent.hyp_indices p i in
         tptp_exists_elim j k u v p

let d_resource = d_resource.resource_improve d_resource (exists_term, d_existsT)

let d_exists_typeT i p =
   if i = 0 then
      let v = maybe_new_vars1 p "v" in
         tptp_exists_type (Sequent.hyp_count_addr p) v p
   else
      raise (RefineError ("d_exists_typeT", StringError "no elimination form"))

let exists_type_term = << "type"{."exists"{v. 'b['v]}} >>

let d_resource = d_resource.resource_improve d_resource (exists_type_term, d_exists_typeT)

let d_atomic_typeT i p =
   if i = 0 then
      tptp_atomic_type (Sequent.hyp_count_addr p) p
   else
      raise (RefineError ("d_atomic_typeT", StringError "no elimination form"))

let atomic_type_term = << "type"{atomic{'x}} >>

let d_resource = d_resource.resource_improve d_resource (atomic_type_term, d_atomic_typeT)

(*
 * Atomic formulas.
 *)
let atomic_intro_rules =
   [|tptp2_atomic_intro0;
     tptp2_atomic_intro1;
     tptp2_atomic_intro2;
     tptp2_atomic_intro3;
     tptp2_atomic_intro4;
     tptp2_atomic_intro5
   |]

let atomicT i p =
   let arity = arity_of_apply (dest_atomic (Sequent.concl p)) in
   let j, k = Sequent.hyp_indices p i in
      if arity < Array.length atomic_intro_rules then
         (atomic_intro_rules.(arity) j k
          thenT addHiddenLabelT "wf") p
      else
         raise (RefineError ("atomicT", StringIntError ("no rule for arity", arity)))

let d_atomicT i p =
   if i = 0 then
      onSomeHypT atomicT p
   else
      raise (RefineError ("atomicT", StringError "no elimination form"))

let d_resource = d_resource.resource_improve d_resource (atomic_term, d_atomicT)

let type_intro_rules =
   [|tptp2_type_intro0;
     tptp2_type_intro1;
     tptp2_type_intro2;
     tptp2_type_intro3;
     tptp2_type_intro4;
     tptp2_type_intro5
   |]

let typeT i p =
   let arity = arity_of_apply (dest_type_term (Sequent.concl p)) in
   let j, k = Sequent.hyp_indices p i in
      if arity < Array.length type_intro_rules then
         (type_intro_rules.(arity) j k
          thenT addHiddenLabelT "wf") p
      else
         raise (RefineError ("typeT", StringIntError ("no rule for arity", arity)))

(*
 * Custom tactic for proving tptp2_*_intro goals.
 *)
let tptp_foldC =
   firstC [fold_atom0;
           fold_atom1;
           fold_atom2;
           fold_atom3;
           fold_atom4;
           fold_atom5;
           fold_prop0;
           fold_prop1;
           fold_prop2;
           fold_prop3;
           fold_prop4;
           fold_prop5]

let tptp_foldT =
   tryOnAllHypsT (rwh tptp_foldC)

let tptp_autoT =
   repeatT (firstT [progressT autoT;
                    autoApplyT 0;
                    tptp_foldT])

(*
 * Automation.
 *)
let auto_tac =
   firstT [rw fold_atomic 0;
           onSomeHypT atomicT;
           onSomeHypT typeT]

let auto_resource =
   auto_resource.resource_improve auto_resource (**)
      { auto_name = "tptp_autoT";
        auto_prec = logic_prec;
        auto_tac = auto_wrap auto_tac
      }

(*
 * -*-
 * Local Variables:
 * Caml-master: "refiner"
 * End:
 * -*-
 *)
