doc <:doc<
   @begin[doc]
   @module[Base_reflection]

   @end[doc]

   ----------------------------------------------------------------

   @begin[license]
   This file is part of MetaPRL, a modular, higher order
   logical framework that provides a logical programming
   environment for OCaml and other languages.

   See the file doc/index.html for information on Nuprl,
   OCaml, and more information about this system.

   Copyright (C) 2004 MetaPRL Group

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

   Author: Xin Yu @email{xiny@cs.caltech.edu}
   @end[license]
>>

doc <:doc<
   @begin[doc]
   @parents
   @end[doc]
>>
extends Shell_theory
extends Top_conversionals
doc docoff

open Basic_tactics

open Lm_debug
open Lm_symbol
open Lm_printf

open Term_sig
open Refiner.Refiner.Term
open Refiner.Refiner.TermOp
open Refiner.Refiner.TermType
open Refiner.Refiner.TermMan
open Refiner.Refiner.Rewrite
open Refiner.Refiner.RefineError
open Dform
open Lm_rformat

declare bterm
declare sequent_arg{'t}
declare term

let bterm_arg = <<sequent_arg{bterm}>>

let hyp_of_var v =
   Hypothesis(v, <<term>>)

let get_var = function
   Hypothesis (v, term) -> v
 | Context (v, conts, subterms) ->
      raise (Invalid_argument "Base_reflection.get_bterm_var: bterm cannot have contexts as hypotheses")

let make_bterm_sequent hyps goal =
   mk_sequent_term {
      sequent_args = bterm_arg;
      sequent_hyps = SeqHyp.of_list hyps;
      sequent_goals = SeqGoal.of_list [goal]
   }

let dest_bterm_sequent term =
   let seq = TermMan.explode_sequent term in
      if (SeqGoal.length seq.sequent_goals = 1) && alpha_equal seq.sequent_args bterm_arg then
         SeqHyp.to_list seq.sequent_hyps, (SeqGoal.get seq.sequent_goals 0)
      else raise (RefineError ("dest_bterm_sequent", StringTermError ("not a bterm sequent", term)))

let dest_bterm_sequent_and_rename term vars =
   let seq = TermMan.explode_sequent_and_rename term vars in
      if (SeqGoal.length seq.sequent_goals = 1) && alpha_equal seq.sequent_args bterm_arg then
         SeqHyp.to_list seq.sequent_hyps, (SeqGoal.get seq.sequent_goals 0)
      else raise (RefineError ("dest_bterm_sequent_and_rename", StringTermError ("not a bterm sequent", term)))

(*************************************************************************
 * if_bterm{'bt; 'tt} evaluates to 'tt when 'bt is a well-formed bterm
 * operator and must fail to evaluate otherwise.
 *
 * rewrite axiom: if_bterm{bterm{<H>; x:_; <J> >- x}; 'tt} <--> 'tt
 * ML rewrite axiom:
 *    if_bterm{bterm{<H> >- _op_{<J1>.t1, ..., <Jn>.tn}}; 'tt}
 *       <-->
 *    if_bterm{bterm{<H>; <J1> >- 't1};
 *       if_bterm{bterm{<H>; <J2> >- 't2};
 *          ...
 *            if_bterm{bterm{<H>; <Jn> >- 'tn}; 'tt}...}}
 *)

declare if_bterm{'bt; 'tt}

prim_rw reduce_ifbterm1 'H :
   if_bterm{ bterm{| <H>; x: term; <J> >- 'x |}; 'tt } <--> 'tt

ml_rw reduce_ifbterm2 : ('goal :  if_bterm{ bterm{| <H> >- 't |}; 'tt }) =
   let bt, tt = two_subterms goal in
   let hyps, t = dest_bterm_sequent bt in
   let t' = dest_term (unquote_term t) in
   let rec wrap_if = function
      [] -> tt
    | s :: subterms ->
         let bt = dest_bterm s in
         let new_bterm = make_bterm_sequent (hyps @ (List.map hyp_of_var bt.bvars)) bt.bterm in
            <:con<if_bterm{$new_bterm$;$wrap_if subterms$}>>
   in wrap_if t'.term_terms

let rec onSomeHypC rw = function
   1 -> rw 1
 | i when i > 0 -> rw i orelseC (onSomeHypC rw (i - 1))
 | _ -> failC

let reduce_ifbterm =
   termC (fun goal ->
      let t,tt =  two_subterms goal in
      let seq = TermMan.explode_sequent  t in
      let goal = SeqGoal.get seq.sequent_goals 0 in
         if is_quoted_term goal then reduce_ifbterm2
         else if is_var_term goal then onSomeHypC reduce_ifbterm1 (SeqHyp.length seq.sequent_hyps)
         else failC)

let resource reduce +=
   (<< if_bterm{ bterm{| <H> >- 't |}; 'tt } >>, reduce_ifbterm)

(***************************************************************************
 * subterms{'bt} returns a list of sub-bterms of 'bt, undefined if 'bt
 * is not a well-formed bterm
 *
 * rewrite axiom: subterms{bterm{<H>; x:_; <J> >- x}} <--> []
 * ML rewrite_axiom:
 *    subterms{bterm{<H> >- _op_{<J1>.t1, ..., <Jn>.tn}}}
 *       <-->
 *    [ bterm{<H>; <J1> >- t1}; ...; bterm{<H>; <Jn> >- tn} ]
 *)

declare subterms{'bt}

prim_rw reduce_subterms1 'H :
   subterms{ bterm{| <H>; x: term; <J> >- 'x |} } <--> Perv!nil

ml_rw reduce_subterms2 {| reduce |} : ('goal :  subterms{ bterm{| <H> >- 't |} }) =
   let bt = one_subterm goal in
   let hyps, t = dest_bterm_sequent bt in
   let t' = dest_term (unquote_term t) in
   let wrap s =
      let bt = dest_bterm s in
      	make_bterm_sequent (hyps @ (List.map hyp_of_var bt.bvars)) bt.bterm
   in mk_xlist_term (List.map wrap t'.term_terms)

let reduce_subterms =
   termC (fun goal ->
      let bt =  one_subterm goal in
      let seq = TermMan.explode_sequent bt in
      let goal = SeqGoal.get seq.sequent_goals 0 in
         if is_quoted_term goal then reduce_subterms2
         else if is_var_term goal then onSomeHypC reduce_subterms1 (SeqHyp.length seq.sequent_hyps)
         else failC)

let resource reduce +=
   (<< subterms{ bterm{| <H> >- 't |} } >>, reduce_subterms)

(************************************************************************
 * make_bterm{'bt; 'btl} takes the top-level operator of 'bt and
 * replaces the subterms with the ones in 'btl (provided they have a
 * correct arity).
 *
 * ML rewrite_axiom:
 *     make_bterm{bterm{<K> >- _op_{<J1>.r1, ..., <Jn>.rn}}};
 *        [bterm{<H>; <J1> >- t1}; ...; bterm{<H>; <Jn> >- tn}] }
 *     <-->
 *     bterm{<H> >- _op_{<J1>.t1, ..., <Jn>.tn}}
 *
 * (<K> and ri are ignored).
 *)

declare make_bterm{'bt; 'bt1}

let rec make_bterm_aux lista listb fvars hvar lenh =
   match lista, listb with
      [], [] -> []
    | a1 :: a, b1:: b ->
         let b1h, b1g = dest_bterm_sequent_and_rename b1 fvars in
            if (List.length b1h - a1 = lenh) then
               let hvar', j1' = Lm_list_util.split lenh (List.map get_var b1h) in
               let b1g' = subst b1g hvar' (List.map mk_var_term hvar) in
                  (mk_bterm j1' b1g') :: (make_bterm_aux a b fvars hvar lenh)
            else raise (Invalid_argument "Base_reflection.make_bterm_aux: unmatched arity.")
    | _, _ -> raise (Invalid_argument "Base_reflection.make_bterm_aux: unmatched arity.")


ml_rw reduce_make_bterm {| reduce |} : ('goal :  make_bterm{ 'bt; 'bt1 }) =
   let bt, bt1 = two_subterms goal in
   let hyps1, t = dest_bterm_sequent bt in
   let t' = dest_term (unquote_term t) in
   let bt1' = dest_xlist bt1 in
      if (List.length t'.term_terms = (List.length bt1')) then
         match bt1' with
            [] -> make_bterm_sequent [] t
          | b1 :: b ->
               let fvars = free_vars_set bt1 in
               let b1h, b1g = dest_bterm_sequent_and_rename b1 fvars in
               let lenJr_list = List.map (fun tmp -> List.length (dest_bterm tmp).bvars) t'.term_terms in
               let lenJr_list' = List.tl lenJr_list in
               let lenh = List.length b1h - (List.hd lenJr_list) in
                  if lenh >= 0 then
                     let hvar' = List.map get_var b1h in
                     let hvar, j1 = Lm_list_util.split lenh hvar' in
                     let fvars = SymbolSet.add_list fvars hvar in
                     let terms = (mk_bterm j1 b1g) :: make_bterm_aux lenJr_list' b fvars hvar lenh in
                        make_bterm_sequent (List.map hyp_of_var hvar) (quote_term (mk_term t'.term_op terms))
                  else raise (RefineError ("reduce_make_bterm", StringTermError ("not a qualified bterm for replacement", b1)))
      else  raise (RefineError ("reduce_make_bterm", StringError "unmatched arities"))

(**************************************************************************
 * if_same_op{'bt1; 'bt2; 'tt; 'ff} evaluates to 'tt if 'bt1 and 'bt2
 * are two well-formed bterms with the same top-level operator (including
 * all the params and all the arities) and to 'ff when operators are
 * distinct. Undefined if either 'bt1 or 'bt2 is ill-formed.
 *)

declare if_same_op{'bt1; 'bt2; 'tt; 'ff}

ml_rw reduce_if_same_op {| reduce |} : ('goal :  if_same_op{ 'bt1; 'bt2; 'tt; 'ff } ) =
   let bt1, bt2, tt, ff = four_subterms goal in
   let hyps1, g1 = dest_bterm_sequent bt1 in
   let hyps2, g2 = dest_bterm_sequent bt2 in
   let t1 = dest_term (unquote_term g1) in
   let t2 = dest_term (unquote_term g2) in
   let bvar_len t = List.length (dest_bterm t).bvars in
      if    ops_eq t1.term_op t2.term_op
         && List.length t1.term_terms = List.length t2.term_terms
         && List.map bvar_len t1.term_terms = List.map bvar_len t1.term_terms
      then  tt
      else  ff

(**************************************************************************
 * if_simple_bterm{'bt; 'tt; 'ff} evaluates to 'tt when 'bt is a bterm
 * with 0 bound variables, to 'ff when it is a bterm with non-0 bound
 * variables and is undefined otherwise.
 *
 * rewrite axiom: if_simple_bterm{bterm{x:_; <H> >- 't}; 'tt; 'ff} <--> 'ff
 * ML rewrite axiom:
 *     if_simple_bterm{bterm{ >- _op_{...}}; 'tt; 'ff} <--> 'tt
 *)

declare if_simple_bterm{'bt; 'tt; 'ff}

prim_rw reduce_if_simple_bterm1 {| reduce |} :
   if_simple_bterm{ bterm {| x: term; <H> >- 't |}; 'tt; 'ff } <--> 'ff

ml_rw reduce_if_simple_bterm2 {| reduce |} : ('goal :  if_simple_bterm{ bterm{| >- 't |}; 'tt; 'ff }) =
   let bt, tt, ff = three_subterms goal in
   let hyps, t = dest_bterm_sequent bt in
      if hyps = [] && is_quoted_term t  then tt
      else raise (RefineError ("reduce_if_simple_bterm2", StringTermError ("not a quoted term", t)))

let reduce_if_simple_bterm =
   termC (fun goal ->
      let t, tt, ff =  three_subterms goal in
      let seq = TermMan.explode_sequent  t in
         if SeqHyp.length seq.sequent_hyps = 0 then reduce_if_simple_bterm2
         else reduce_if_simple_bterm1)

let resource reduce +=
   (<< if_simple_bterm{ bterm{| <H> >- 't|}; 'tt; 'ff } >>, reduce_if_simple_bterm)

(*************************************************************************
 * if_var_bterm{'bt; 'tt; 'ff} evaluates to 'tt when 'bt is a
 * well-formed bterm with a bound variable body, to 'ff when it is a bterm
 * with a non-variable top-level operator.
 *
 * rewrite axiom:
 *     if_var_bterm{bterm{<H>; x:_; <J> >- 'x}; 'tt; 'ff} <--> 'tt
 * ML rewrite axiom:
 *     if_var_bterm{bterm{<H> >- _op_{...}}; 'tt; 'ff} <--> 'ff
 *)

declare if_var_bterm{'bt; 'tt; 'ff}

prim_rw reduce_if_var_bterm1 'H :
   if_var_bterm{ bterm{| <H>; x: term; <J> >- 'x |}; 'tt; 'ff } <--> 'tt

ml_rw reduce_if_var_bterm2 : ('goal :  if_var_bterm{ bterm{| <H> >- 't |}; 'tt; 'ff }) =
   let bt, tt, ff = three_subterms goal in
   let hyps, t = dest_bterm_sequent bt in
      if is_quoted_term t  then ff
      else raise (RefineError ("reduce_if_var_bterm2", StringTermError ("not a quoted term", t)))

let reduce_if_var_bterm =
   termC (fun goal ->
      let t, tt, ff =  three_subterms goal in
      let seq = TermMan.explode_sequent  t in
      let goal = SeqGoal.get seq.sequent_goals 0 in
         if is_quoted_term goal then reduce_if_var_bterm2
         else if is_var_term goal then onSomeHypC reduce_if_var_bterm1 (SeqHyp.length seq.sequent_hyps)
         else failC)

let resource reduce +=
   (<< if_var_bterm{ bterm{| <H> >- 't|}; 'tt; 'ff } >>, reduce_if_var_bterm)

(************************************************************************
 * subst{'bt; 't} substitutes 't for the first bound variable of 'bt.
 *
 * rewrite_axiom:
 * subst{bterm{x:_; <H> >- 't1['x]}; bterm{ >- 't2}} <-->
 * bterm{<H> >- 't1['t2] }
 *)

declare subst{'bt; 't}

prim_rw reduce_subst {| reduce |} :
   subst{ bterm{| x: term; <H> >- 't1['x] |}; bterm{| >- 't2 |} } <-->
      bterm{| <H> >- 't1['t2] |}

doc docoff

(************************************************************************
 * DISPLAY FORMS                                                        *
 ************************************************************************)

dform term_df : except_mode[src] :: term =
   `"_"

declare df_bconts{'conts}

let rec fmt_term_lst format_term buf = function
   [] ->
      raise(Invalid_argument("fmt_term_lst"))
 | [t] ->
      format_term buf NOParens t
 | t::tl ->
      format_term buf NOParens t;
      format_string buf "; ";
      fmt_term_lst format_term buf tl

let format_term_list format_term buf = function
   [] -> ()
 | ts ->
      format_szone buf;
      format_string buf "[";
      format_pushm buf 0;
      fmt_term_lst format_term buf ts;
      format_popm buf;
      format_string buf "]";
      format_ezone buf

let make_cont v = <:con< df_context_var[$v$:v] >>

let format_bconts format_term buf v = function
   [v'] when Lm_symbol.eq v v' -> ()
 | conts -> format_term buf NOParens <:con< df_bconts{$mk_xlist_term (List.map make_cont conts)$} >>

let format_context format_term buf v conts values =
   format_term buf NOParens <:con< df_context_var[$v$:v] >>;
   format_bconts format_term buf v conts;
   format_term_list format_term buf values


let format_bterm_prl format_term buf =
   let rec format_hyp hyps i len =
      if i <> len then
         let _ =
            format_szone buf;
            format_pushm buf 0;
            match SeqHyp.get hyps i with
               Context (v, conts, values) ->
                  (* This is a context hypothesis *)
                  format_string buf "<"; (* note: U27E8 is much nicer, but not all fonts have it *)
                  format_context format_term buf v conts values;
                  format_string buf ">"; (* note: U27E9 is much nicer, but not all fonts have it *)
                  format_string buf ".";
                  format_space buf;
             | Hypothesis (v, a) ->
                  if Lm_symbol.to_string v <> "" then begin
                     format_term buf NOParens (mk_var_term v);
                     format_string buf ".";
                     format_space buf;
                  end;
         in
            format_popm buf;
            format_ezone buf;
            format_hyp hyps (succ i) len
   in
   let rec format_goal goals i len =
      if i < len then
         let a = SeqGoal.get goals i in
            if i > 0 then format_hbreak buf "; " "";
            format_term buf NOParens a;
            format_goal goals (succ i) len
   in
   let format term =
      let { sequent_args = args;
            sequent_hyps = hyps;
            sequent_goals = goals
          } = explode_sequent term
      in
         format_szone buf;
         format_pushm buf 0;
         let hlen = SeqHyp.length hyps in
         if (hlen>0) then
            format_hyp hyps 0 hlen;
         format_pushm buf 0;
         format_goal goals 0 (SeqGoal.length goals);
         format_popm buf;
         format_popm buf;
         format_ezone buf
   in
      format

ml_dform bterm_prl_df : mode["prl"] :: sequent[bterm]{ <H> >- 'concl } format_term buf =
   format_bterm_prl format_term buf

ml_dform bterm_prl_df : mode["prl"] :: sequent[bterm]{ <H> >- } format_term buf =
   format_bterm_prl format_term buf



let mk_tslot t = <:con< slot{$t$} >>

let format_bterm_html format_term buf =
   let rec format_hyp hyps i len =
      if i <> len then
         let _ =
            format_szone buf;
            match SeqHyp.get hyps i with
               Context (v, conts, values) ->
                  (* This is a context hypothesis *)
                  format_string buf "<";
                  format_context format_term buf v conts values;
                  format_string buf ">";
                  format_string buf ".";
                  format_space buf;
              | Hypothesis (v, a) ->
                  if Lm_symbol.to_string v <> "" then begin
                     format_term buf NOParens (mk_var_term v);
                     format_string buf ".";
                     format_space buf;
                  end;
         in
            format_ezone buf;
            format_hyp hyps (succ i) len
   in
   let rec format_goal goals i len =
      if i <> len then
         let a = SeqGoal.get goals i in
            if i > 0 then
               format_hbreak buf "; " "  ";
            format_term buf NOParens (mk_tslot a);
            format_goal goals (succ i) len
   in
   let format term =
      let { sequent_args = arg;
            sequent_hyps = hyps;
            sequent_goals = goals
          } = explode_sequent term
      in
         format_szone buf;
         format_pushm buf 0;
         let hlen = SeqHyp.length hyps in
         if (hlen>0) then
            format_hyp hyps 0 hlen;
         format_pushm buf 0;
         format_goal goals 0 (SeqGoal.length goals);
         format_popm buf;
         format_popm buf;
         format_ezone buf
   in
      format

ml_dform bterm_html_df : mode["html"] :: sequent[bterm]{ <H> >- 'concl } format_term buf =
   format_bterm_html format_term buf

ml_dform bterm_html_df : mode["html"] :: sequent[bterm]{ <H> >- } format_term buf =
   format_bterm_html format_term buf



let format_bterm_tex format_term buf =
   let rec format_hyp hyps i len =
      if i <> len then
         let _ =
            format_szone buf;
            match SeqHyp.get hyps i with
               Context (v, conts, values) ->
                  format_term buf NOParens <<mathmacro["left<"]>>;
                  format_context format_term buf v conts values;
                  format_term buf NOParens <<mathmacro["right>"]>>;
                  format_string buf ".";
                  format_space buf;
             | Hypothesis (v, a) ->
                  if Lm_symbol.to_string v <> "" then begin
                     format_term buf NOParens (mk_var_term v);
                     format_string buf ".";
                     format_space buf;
                  end;
         in
            format_ezone buf;
            format_hyp hyps (succ i) len
   in
   let rec format_goal goals i len =
      if i <> len then
         let a = SeqGoal.get goals i in
            if i > 0 then
               format_hbreak buf "; " "";
            format_term buf NOParens a;
            format_goal goals (succ i) len
   in
   let format term =
      let { sequent_args = arg;
            sequent_hyps = hyps;
            sequent_goals = goals
          } = explode_sequent term
      in
         format_szone buf;
         format_pushm buf 0;
         let hlen = SeqHyp.length hyps in
         if (hlen>0) then
            format_hyp hyps 0 hlen;
         format_pushm buf 0;
         format_goal goals 0 (SeqGoal.length goals);
         format_popm buf;
         format_popm buf;
         format_ezone buf
   in
      format

ml_dform bterm_tex_df : mode["tex"] :: sequent[bterm]{ <H> >- 'concl } format_term buf =
   format_bterm_tex format_term buf

ml_dform bterm_tex_df : mode["tex"] :: sequent[bterm]{ <H> >- } format_term buf =
   format_bterm_tex format_term buf