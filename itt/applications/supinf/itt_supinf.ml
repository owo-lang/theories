extends Itt_equal
extends Itt_dfun
extends Itt_logic
extends Itt_bool
extends Itt_int_ext
extends Itt_rat
extends Itt_rat2

open Lm_debug
open Lm_printf

open Supinf

open Basic_tactics

open Itt_struct
open Itt_bool

open Itt_int_base
open Itt_int_ext
open Itt_int_arith
open Itt_rat

module Term = Refiner.Refiner.Term
module TermMan = Refiner.Refiner.TermMan

let debug_supinf_trace =
   create_debug (**)
      { debug_name = "supinf_trace";
        debug_description = "Print out (low-level) trace of supinf execution";
        debug_value = false
      }

let debug_supinf_steps =
   create_debug (**)
      { debug_name = "supinf_steps";
        debug_description = "Itt_supinf.supinfT: print out (high-level) steps to be proved";
        debug_value = false
      }

let debug_supinf_post =
   create_debug (**)
      { debug_name = "supinf_post";
        debug_description = "Itt_supinf.supinfT: post-supinf processing";
        debug_value = false
      }

module RationalBoundField =
struct
   open Lm_num

   type bfield = Num of (num * num) | MinusInfinity | PlusInfinity

   let num0 = zero_num
   let num1 = one_num
   let fieldUnit = Num (num1, num1)
   let fieldZero = Num (num0, num1)
   let plusInfinity = PlusInfinity
   let minusInfinity = MinusInfinity

   let isInfinite = function
      Num _ -> false
    | _ -> true

	let isNegative = function
		Num (a,b) ->
			((compare_num a num0) * (compare_num b num0)) < 0
	 | PlusInfinity -> false
	 | MinusInfinity -> true

(* unused
	let isPositive = function
		Num (a,b) ->
			((compare_num a num0) * (compare_num b num0)) > 0
	 | PlusInfinity -> true
	 | MinusInfinity -> false
*)

   let mul a b =
      match a with
       |	Num (a1,a2) ->
            begin
               match b with
                  Num (b1,b2) -> Num(mult_num a1 b1, mult_num a2 b2)
                | PlusInfinity ->
                     if isNegative a then MinusInfinity
                     else b
                | MinusInfinity ->
                     if isNegative a then PlusInfinity
                     else b
            end
       | _ -> raise (Invalid_argument "Multiplications by infinities are not defined")

   let add a b =
      match a,b with
         MinusInfinity, MinusInfinity -> a
       | MinusInfinity, PlusInfinity -> raise (Invalid_argument "MinusInfinity+PlusInfinity is not supported")
       | PlusInfinity, MinusInfinity -> raise (Invalid_argument "PlusInfinity+MinusInfinity is not supported")
       | PlusInfinity, PlusInfinity -> a
       | PlusInfinity, _ -> a
       | _, PlusInfinity -> b
       | MinusInfinity, _ -> a
       | _, MinusInfinity -> b
       | Num (a1,a2), Num (b1,b2) -> Num(add_num (mult_num a1 b2) (mult_num a2 b1), mult_num a2 b2)

   let sub a b =
      match a,b with
         Num (a1,a2), Num (b1,b2) -> Num(sub_num (mult_num a1 b2) (mult_num b1 a2), mult_num a2 b2)
       | _,_ -> raise (Invalid_argument "Subtraction defined only on proper numbers")

   let neg a =
      match a with
         Num (a1,a2) -> Num(neg_num a1,a2)
       | PlusInfinity -> MinusInfinity
       | MinusInfinity -> PlusInfinity

   let inv a =
      match a with
         Num (a1,a2) ->
            if is_zero a2 then raise (Invalid_argument "Division by zero")
            else Num(a2,a1)
       | _ -> raise (Invalid_argument "Division defined only on proper numbers")

   let div a b =
      match a,b with
         Num (a1,a2), Num (b1,b2) ->
            if is_zero b1 then raise (Invalid_argument "Division by zero")
            else Num(mult_num a1 b2, mult_num a2 b1)
       | _,_ -> raise (Invalid_argument "Division defined only on proper numbers")

   let floor r =
      match r with
         Num (a,b) -> fdiv_num a b
       | _ -> raise (Invalid_argument "RationalBoundField.floor: undefined on infinities")

   let compare a b =
      match a,b with
         MinusInfinity, MinusInfinity -> 0
       | MinusInfinity, _ -> -1
       | _, MinusInfinity -> 1
       | PlusInfinity, PlusInfinity -> 0
       | PlusInfinity, _ -> 1
       | _, PlusInfinity -> -1
       | Num (a1,a2), Num (b1,b2) ->
            compare_num (mult_num (mult_num a1 (sign_num a2)) (abs_num b2)) (mult_num (abs_num a2) (mult_num b1 (sign_num b2)))

   let print out r =
      match r with
(*       Num (a,b) -> fprintf out "rat(%s,%s)" (string_of_num a) (string_of_num b) *)
         Num (a,b) ->
            if is_zero a then fprintf out "0*"
            else if eq_num b num1 then fprintf out "(%s)" (string_of_num a)
            else fprintf out "(%s/%s)" (string_of_num a) (string_of_num b)
       | MinusInfinity -> fprintf out "(-oo)"
       | PlusInfinity -> fprintf out "(+oo)"

   let term_of = function
      Num (a,b) -> mk_rat_term (mk_number_term a) (mk_number_term b)
(*    | _ -> raise (Invalid_argument "Infinities have no projections to terms")*)
    | PlusInfinity -> mk_rat_term (mk_number_term num1) (mk_number_term num0)
    | MinusInfinity -> mk_rat_term (mk_number_term (sub_num num0 num1)) (mk_number_term num0)


   let add_term = mk_add_rat_term
   let mul_term = mk_mul_rat_term
   let neg_term = mk_neg_rat_term
   let sub_term a b = mk_add_rat_term a (mk_neg_rat_term b)
   let inv_term = mk_inv_rat_term
   let div_term a b = mk_mul_rat_term a (mk_inv_rat_term b)
   let ge_term a b = mk_assert_term (mk_ge_bool_rat_term a b)
   let max_term a b = mk_max_rat_term a b
   let min_term a b = mk_min_rat_term a b
end

(* unused
module R = RationalBoundField
 *)

module Var =
struct
   type t = term
   let equal = alpha_equal
   let hash = Hashtbl.hash
end

module Var2Index(BField : BoundFieldSig) =
struct
   module Table=Hashtbl.Make(Var)

   type t=int ref * int Table.t

   let create n = (ref 0, Table.create n)

   let length (r,_) = !r

   let lookup (info:t) v =
      let (count,table)=info in
      if Table.mem table v then
         Table.find table v
      else
         let index=(!count)+1 in
         begin
            Table.add table v index;
            count:=index;
            index
         end

   let print out info =
      let count,table=info in
      let aux k d = fprintf out "%a ->v%i%t" print_term k d eflush in
      (*printf "count=%i%t" !count eflush;*)
      Table.iter aux table

   let invert ((count,table) : t) =
      let ar=Array.make !count (BField.term_of BField.fieldZero) in
      let aux key data = (ar.(data-1)<-key) in
      Table.iter aux table;
      ar

   let restore inverted index =
      if index=0 then
         BField.term_of (BField.fieldUnit)
      else
         inverted.(index-1)
end

(* unused
module MakeMonom(BField : BoundFieldSig) =
struct
   type elt = VarType.t
   type data = BField.bfield

   let compare = VarType.compare

   let print out (v:elt) (kl: data list) =
      match kl with
         [k] -> BField.print out k; (*printf"*";*) VarType.print out v
       | _ -> raise (Invalid_argument "More than one coefficient is associated with one variable")

   let append l1 l2 =
      match l1,l2 with
         [],[] -> [BField.fieldZero]
       | [],[a] -> [a]
       | [a],[] -> [a]
       | [a],[b] -> [BField.add a b]
       | _,_ -> raise (Invalid_argument "Addition non-trivial lists are not supported")

end
*)
(*
let divideAuxC t =
   let left,right=dest_ge_rat in
   let first,rest=dest_add_rat left in
   if is_mul_rat_term first then
      let k,v=dest_mul_rat first in

   else
      idC


let stdC t =
   let left,right=dest_ge_rat t in
   let t' = mk_neg_rat t in
   ge_addMono_rw t' thenC normalizeC thenC divideC
*)
module type SACS_Sig =
sig
   type vars
   type bfield
   type af
   type saf
   type source
   type sacs

   val empty: int -> sacs
   val addConstr: sacs -> af -> sacs

   val upper: (term array) -> sacs -> vars -> saf
   val lower: (term array) -> sacs -> vars -> saf

   val addUpperBound : sacs -> vars -> bfield -> sacs
   val addLowerBound : sacs -> vars -> bfield -> sacs

   val print: out_channel -> sacs -> unit
   val print_bounds: (term array) -> sacs -> out_channel -> unit
end

let ge_normC = (addrC [Subterm 1] normalizeC) thenC (addrC [Subterm 2] normalizeC)

interactive_rw extract2left 't :
   ('a in rationals) -->
   ('b in rationals) -->
   ('t in rationals) -->
   ge_rat{'a; 'b} <-->
   ge_rat{'t; add_rat{'t; sub_rat{'b; 'a}}}

let extract2leftC t = extract2left t thenC ge_normC

interactive_rw extract2right 't :
   ('a in rationals) -->
   ('b in rationals) -->
   ('t in rationals) -->
   ge_rat{'a; 'b} <-->
   ge_rat{add_rat{'t; sub_rat{'a; 'b}}; 't}

let extract2rightC t = extract2right t thenC ge_normC

interactive_rw positive_multiply_ge 'c :
   ('a in rationals) -->
   ('b in rationals) -->
   (gt_rat{'c; rat{0;1}}) -->
   ge_rat{'a; 'b} <--> ge_rat{mul_rat{'c; 'a}; mul_rat{'c; 'b}}

interactive_rw negative_multiply_ge 'c :
   ('a in rationals) -->
   ('b in rationals) -->
   (lt_rat{'c; rat{0;1}}) -->
   ge_rat{'a; 'b} <--> ge_rat{mul_rat{'c; 'b}; mul_rat{'c; 'a}}

interactive_rw ge_addMono_rw 'c :
   ('a in rationals) -->
   ('b in rationals) -->
   ('c in rationals) -->
   ge_rat{'a; 'b} <--> ge_rat{add_rat{'c; 'a}; add_rat{'c; 'b}}

interactive ge_addMono2 'H 'J :
   [wf] sequent { <H>; ge_rat{'a; 'b}; <J>; ge_rat{'c; 'd}; <K> >- 'a in rationals } -->
   [wf] sequent { <H>; ge_rat{'a; 'b}; <J>; ge_rat{'c; 'd}; <K> >- 'b in rationals } -->
   [wf] sequent { <H>; ge_rat{'a; 'b}; <J>; ge_rat{'c; 'd}; <K> >- 'c in rationals } -->
   [wf] sequent { <H>; ge_rat{'a; 'b}; <J>; ge_rat{'c; 'd}; <K> >- 'd in rationals } -->
   sequent { <H>; ge_rat{'a; 'b}; <J>; ge_rat{'c; 'd}; <K>; ge_rat{add_rat{'a; 'c}; add_rat{'b; 'd}} >- 'C } -->
   sequent { <H>; ge_rat{'a; 'b}; <J>; ge_rat{'c; 'd}; <K> >- 'C }

let ge_addMono2T i j = funT (fun p ->
   let i=Sequent.get_pos_hyp_num p i in
   let j=Sequent.get_pos_hyp_num p j in
   begin
      if !debug_supinf_steps then
         let h1=Sequent.nth_hyp p i in
         let h2=Sequent.nth_hyp p j in
         eprintf "ge_addMono2T %i %i on %s %s@." i j
            (SimplePrint.short_string_of_term h1)
            (SimplePrint.short_string_of_term h2)
   end;
   ge_addMono2 i (j-i)
)

module MakeSACS(BField : BoundFieldSig)
(Source: SourceSig with type bfield=BField.bfield and type vars=VarType.t)
(AF : AF_Sig  with type bfield=BField.bfield and type vars=VarType.t and type source=Source.source)
(SAF : SAF_Sig  with type bfield=BField.bfield and type vars=VarType.t and type source=Source.source and type af=AF.af)
: SACS_Sig with
    type vars=VarType.t and
   type bfield=BField.bfield and
     type source=Source.source and
    type af=AF.af and
     type saf=SAF.saf =
struct
   type vars   = VarType.t
   type bfield = BField.bfield
   type af     = AF.af
   type saf    = SAF.saf
   type source = Source.source
   type sacs   = (af list) * (saf option array) * (saf option array)

   module VI=Var2Index(BField)

   let empty n =
      let n'= succ n in
      ([], Array.make n' None, Array.make n' None)

   let addConstr ((s,l,u) as original) f =
      if AF.isNumber f then
         original
      else
         (f::s,l,u)

   let print out (s,l,u) =
      List.iter (fun x -> begin fprintf out "%a>=0\n" AF.print x end) s

   let rec upper' info s v =
      match s with
         [] -> SAF.affine AF.plusInfinity
       | f::tl ->
            let v_coef = AF.coef f v in
            if BField.compare v_coef BField.fieldZero >=0 then
               upper' info tl v
            else
               let k=BField.neg (BField.inv v_coef) in
               let rest=AF.remove f v in
               let u0=AF.scale k rest in
               let u1=AF.extract2rightSource v u0 in
               let r0=upper' info tl v in
               SAF.min r0 (SAF.affine u1)

   let upper info (s,l,u) v =
      let result =
         match u.(v) with
            Some b -> b
          | None ->
               upper' info s v
      in
      if !debug_supinf_steps then
         eprintf "upper: %a <= %a@." AF.print_var v SAF.print result;
      result

   let rec lower' info s v =
      match s with
         [] -> SAF.affine AF.minusInfinity
       | f::tl ->
            let v_coef = AF.coef f v in
            if BField.compare v_coef BField.fieldZero <=0 then
               lower' info tl v
            else
               let k=BField.neg (BField.inv v_coef) in
               let rest=AF.remove f v in
               let u0=AF.scale k rest in
               let u1=AF.extract2leftSource v u0 in
               let r0=lower' info tl v in
               SAF.max r0 (SAF.affine u1)

   let lower info (s,l,u) v =
      let result =
         match l.(v) with
            Some b -> b
          | None ->
               lower' info s v
      in
      if !debug_supinf_steps then
         eprintf "lower: %a <= %a@." SAF.print result AF.print_var v;
      result

   let addUpperBound constrs v b =
      let (s,l,u)=constrs in
      if BField.compare b BField.plusInfinity < 0 then
         u.(v) <- Some (SAF.affine (AF.mk_number b));
      constrs

   let addLowerBound constrs v b =
      let (s,l,u)=constrs in
      if BField.compare b BField.minusInfinity > 0 then
         l.(v) <- Some (SAF.affine (AF.mk_number b));
      constrs

   let print_bounds info (s,l,u) out =
      for i=1 to (Array.length l -1) do
         match l.(i), u.(i) with
            None, None -> ()
          | Some lv, None ->
               fprintf out "%s >= %s@." (SimplePrint.short_string_of_term (VI.restore info i)) (SimplePrint.short_string_of_term (SAF.term_of info lv))
          | None, Some uv ->
               fprintf out "%s >= %s@." (SimplePrint.short_string_of_term (SAF.term_of info uv)) (SimplePrint.short_string_of_term (VI.restore info i))
          |Some lv, Some uv ->
               fprintf out "%s >= %s >= %s@." (SimplePrint.short_string_of_term (SAF.term_of info uv)) (SimplePrint.short_string_of_term (VI.restore info i)) (SimplePrint.short_string_of_term (SAF.term_of info lv))
      done;

end

module type CS_Sig =
sig
(* unused
   type t
   type elt

   val empty: t
   val add: t -> elt -> t

   val mem: t -> elt -> bool
 *)
end

module S=MakeSource(RationalBoundField)
module AF=MakeAF(RationalBoundField)(S)
module SAF=MakeSAF(RationalBoundField)(S)(AF)
module SACS=MakeSACS(RationalBoundField)(S)(AF)(SAF)
module CS=Lm_set.LmMakeDebug(VarType)
module VI=Var2Index(RationalBoundField)

open RationalBoundField
open S

let suppa' info (x:AF.vars) (f:AF.af) =
   if !debug_supinf_trace then
      eprintf "suppa: %a <= %a@." AF.print_var x AF.print f;
   let b = AF.coef f x in
   let c = AF.remove f x in
   let af_x=AF.mk_var x in
      if compare b fieldUnit < 0 then
         let result0=AF.scale (inv (sub fieldUnit b)) c in
         AF.extract2rightSource x result0
      else
      if (compare b fieldUnit = 0) && (AF.isNumber c) then
         let cmp=compare (AF.coef c AF.constvar) fieldZero in
            if cmp<0 then
               AF.contrSource f AF.minusInfinity
            else
            if cmp=0 then
               af_x
            else
               AF.plusInfinity
      else
         AF.plusInfinity

let suppa info x f =
   let result = suppa' info x f in
      if !debug_supinf_steps then
         begin
            eprintf "suppa<: %a <= %a@." AF.print_var x AF.print f;
            eprintf "suppa>: %a <= %a@." AF.print_var x AF.print result
         end;
      result

let rec supp' info (x:AF.vars) (saf:SAF.saf) =
   let src,s=saf in
   match s with
      SAF.Affine f ->
         let r=suppa info x (AF.setSource src f) in
         SAF.affine r
    | SAF.Min (a,b) ->
         let f1 = supp' info x (SAF.setSource (Sleft src) a) in
         let f2 = supp' info x (SAF.setSource (Sright src) b) in
         (match SAF.getSource f1, SAF.getSource f2 with
            Scontradiction s, _ ->
               f1
          | _, Scontradiction s ->
               f2
          | _, _ ->
               SAF.min f1 f2
         )
    | SAF.Max _ -> raise (Invalid_argument "Itt_supinf.supp applied to max(...,...)")

let supp info x s =
   let result = supp' info x s in
      if !debug_supinf_steps then
         begin
            eprintf"supp<: %a <= %a@." AF.print_var x SAF.print s;
            eprintf"supp>: %a <= %a@." AF.print_var x SAF.print result
         end;
      result

let inffa' info (x:AF.vars) (f:AF.af) =
   if !debug_supinf_trace then
      eprintf"inffa: %a >= %a@." AF.print_var x AF.print f;
   let b = AF.coef f x in
   let c = AF.remove f x in
   let af_x=AF.mk_var x in
      if compare b fieldUnit < 0 then
         let result0=AF.scale (inv (sub fieldUnit b)) c in
         AF.extract2leftSource x result0
      else
      if (compare b fieldUnit = 0) && (AF.isNumber c) then
         let cmp=compare (AF.coef c AF.constvar) fieldZero in
            if cmp>0 then
               AF.contrSource f AF.plusInfinity
            else
            if cmp=0 then
               af_x
            else
               AF.minusInfinity
      else
         AF.minusInfinity

let inffa info x f =
   let result = inffa' info x f in
      if !debug_supinf_steps then
         begin
            eprintf"inffa<: %a <= %a@." AF.print f AF.print_var x;
            eprintf"inffa>: %a <= %a@." AF.print result AF.print_var x
         end;
      result

let rec inff' info (x:AF.vars) (saf:SAF.saf) =
   let src,s=saf in
   match s with
      SAF.Affine f ->
         let r = inffa info x (AF.setSource src f) in
         SAF.affine r
    | SAF.Max (a,b) ->
         let f1 = inff' info x (SAF.setSource (Sleft src) a) in
         let f2 = inff' info x (SAF.setSource (Sright src) b) in
         (match SAF.getSource f1, SAF.getSource f2 with
            Scontradiction s, _ ->
               f1
          | _, Scontradiction s ->
               f2
          | _, _ ->
               SAF.max f1 f2
         )
    | SAF.Min _ -> raise (Invalid_argument "Itt_supinf.inff applied to min(...,...)")

let inff info x s =
   let result = inff' info x s in
      if !debug_supinf_steps then
         begin
            eprintf"inff<: %a <= %a@." SAF.print s AF.print_var x;
            eprintf"inff>: %a <= %a@." SAF.print result AF.print_var x
         end;
      result

let rec supa info (c:SACS.sacs) (f:AF.af) (h:CS.t) =
   if !debug_supinf_trace then
      begin
         eprintf"supa:\n%a@.%a@.%a@."   (**)
            SACS.print c
            AF.print f
            CS.print h
      end;
   let (r,v,b) = AF.split f in
      if v=AF.constvar then
         begin
            if !debug_supinf_trace then
               (eprintf "supa case 0@.");
            SAF.affine (AF.mk_number r)
         end
      else
         begin
            if !debug_supinf_trace then
               (eprintf "supa case 1 var:%i@." v);
            let af_v=AF.mk_var v in
               if (AF.isNumber b) && (compare (AF.coef b AF.constvar) fieldZero =0) then
                  begin
                     if !debug_supinf_trace then
                        (eprintf "supa case 10@.");
                     if compare r fieldUnit = 0 then
                        begin
                           if !debug_supinf_trace then
                              (eprintf "supa case 100@.");
                           if CS.mem h v then
                              begin
                                 if !debug_supinf_trace then
                                    (eprintf "supa case 1000@.");
                                 let af_v = AF.mk_var v in
                                 SAF.affine af_v
                              end
                           else
                              begin
                                 if !debug_supinf_trace then
                                    (eprintf "supa case 1001@.");
                                 let r0 = SACS.upper info c v in
                                 let r1 = sup info c r0 (CS.add h v) in
                                 let r1'=SAF.transitiveLeftSource r1 r0 v in
                                 supp info v r1'
                              end
                        end
                     else
                        begin
                           if !debug_supinf_trace then
                              (eprintf "supa case 101@.");
                           let saf_v=SAF.affine af_v in
                           if compare r fieldZero < 0 then
                              begin
                                 if !debug_supinf_trace then
                                    (eprintf "supa case 1010@.");
                                 let r0 = inf info c saf_v h in
                                 SAF.scale r r0
                              end
                           else
                              begin
                                 if !debug_supinf_trace then
                                    (eprintf "supa case 1011@.");
                                 let r0 = sup info c saf_v h in
                                 SAF.scale r r0
                              end
                        end
                  end
               else
                  begin
                     if !debug_supinf_trace then
                        (eprintf "supa case 11@.");
                     let b' = sup info c (SAF.affine b) (CS.add h v) in
                     let scaled_av=AF.scale r af_v in
                     let scaled_v=SAF.affine scaled_av in
                     let f'=SAF.add scaled_v b' in
                     (*let f''=SAF.addVarSource r v f' in*)
                        if SAF.occurs v b' then
                           begin
                              if !debug_supinf_trace then
                                 (eprintf "supa case 110 var:%a@." SAF.print scaled_v);
                              let r1=sup info c f' h in
                              SAF.transitiveLeftSource r1 f' 0
                           end
                        else
                           begin
                              if !debug_supinf_trace then
                                 (eprintf "supa case 111 var:%a@." SAF.print scaled_v);
                              let r1=sup info c scaled_v h in
                              SAF.add r1 b'
                           end
                  end
         end

and sup' info (c:SACS.sacs) (saf:SAF.saf) (h:CS.t) =
   let (src,s)=saf in
   match s with
      SAF.Affine f -> supa info c (AF.setSource src f) h
    | SAF.Min (a,b) ->
         let f1 = sup' info c (SAF.setSource (Sleft src) a) h in
         let f2 = sup' info c (SAF.setSource (Sright src) b) h in
         SAF.min f1 f2
    | SAF.Max _ -> raise (Invalid_argument "Itt_supinf.sup applied to max(...,...)")

and sup info (c:SACS.sacs) (s:SAF.saf) (h:CS.t) =
   let result = sup' info c s h in
      if !debug_supinf_steps then
         begin
            eprintf"sup: %a <= %a@." SAF.print s SAF.print result
         end;
      result

and infa info (c:SACS.sacs) (f:AF.af) (h:CS.t) =
   if !debug_supinf_trace then
      begin
         eprintf"infa:\n%a@.%a@.%a@." (**)
            SACS.print c
            AF.print f
            CS.print h
      end;
   let (r,v,b) = AF.split f in
      if v=AF.constvar then
         begin
            if !debug_supinf_trace then
               (eprintf "infa case 0@.");
            SAF.affine (AF.mk_number r)
         end
      else
         begin
            if !debug_supinf_trace then
               (eprintf "infa case 1 var:%i@." v);
            let af_v=AF.mk_var v in
            let saf_v = SAF.affine af_v in
               if (AF.isNumber b) && (compare (AF.coef b AF.constvar) fieldZero =0) then
                  begin
                     if !debug_supinf_trace then
                        (eprintf "infa case 10@.");
                     if compare r fieldUnit = 0 then
                        begin
                           if !debug_supinf_trace then
                              (eprintf "infa case 100@.");
                           if CS.mem h v then
                              begin
                                 if !debug_supinf_trace then
                                    (eprintf "infa case 1000@.");
                                 let af_v = AF.mk_var v in
                                 SAF.affine af_v
                              end
                           else
                              begin
                                 if !debug_supinf_trace then
                                    (eprintf "infa case 1001@.");
                                 let r0=SACS.lower info c v in
                                 let r1=inf info c r0 (CS.add h v) in
                                 let r1'=SAF.transitiveRightSource v r0 r1 in
                                 inff info v r1'
                              end
                        end
                     else
                        begin
                           if !debug_supinf_trace then
                              (eprintf "infa case 101@.");
                           if compare r fieldZero < 0 then
                              begin
                                 if !debug_supinf_trace then
                                    (eprintf "infa case 1010@.");
                                 let r0=sup info c saf_v h in
                                 SAF.scale r r0
                              end
                           else
                              begin
                                 if !debug_supinf_trace then
                                    (eprintf "infa case 1011@.");
                                 let r0=inf info c saf_v h in
                                 SAF.scale r r0
                              end
                        end
                  end
               else
                  begin
                     if !debug_supinf_trace then
                        (eprintf "infa case 11@.");
                     let b' = inf info c (SAF.affine b) (CS.add h v) in
                     let scaled_v=SAF.affine (AF.scale r af_v) in
                     let f'=SAF.add scaled_v b' in
                     (*let f''=SAF.addVarSource r v f' in*)
                        if SAF.occurs v b' then
                           begin
                              if !debug_supinf_trace then
                                 (eprintf "infa case 110 var:%a@." SAF.print scaled_v);
                              let r1=inf info c f' h in
                              SAF.transitiveRightSource 0 f' r1
                           end
                        else
                           begin
                              if !debug_supinf_trace then
                                 (eprintf "infa case 111 var:%a@." SAF.print scaled_v);
                              let r1=inf info c scaled_v h in
                              SAF.add r1 b'
                           end
                  end
         end

and inf' info (c:SACS.sacs) (saf:SAF.saf) (h:CS.t) =
   let (src,s)=saf in
   match s with
      SAF.Affine f -> infa info c (AF.setSource src f) h
    | SAF.Max (a,b) ->
         let f1 = inf' info c (SAF.setSource (Sleft src) a) h in
         let f2 = inf' info c (SAF.setSource (Sright src) b) h in
         SAF.max f1 f2
    | SAF.Min _ -> raise (Invalid_argument "Itt_supinf.inf applied to min(...,...)")

and inf info (c:SACS.sacs) (s:SAF.saf) (h:CS.t) =
   let result = inf' info c s h in
      if !debug_supinf_steps then
         begin
            eprintf"inf: %a <= %a@." SAF.print result SAF.print s
         end;
      result

let monom2af var2index t =
   match explode_term t with
      <<mul_rat{'t1;'t2}>> ->
         if is_rat_term t1 then
            let k1,k2=dest_rat t1 in
            let i=VI.lookup var2index t2 in
            let f=AF.mk_var i in
               AF.scale (Num (dest_number k1, dest_number k2)) f
         else
            let i=VI.lookup var2index t in
               AF.mk_var i
    | <<rat{'k1;'k2}>> ->
         AF.mk_number (Num (dest_number k1, dest_number k2))
    | _ ->
         let i=VI.lookup var2index t in
            AF.mk_var i

let rec linear2af var2index t =
   match explode_term t with
      <<add_rat{'t1;'t2}>> ->
         let f1=linear2af var2index t1 in
         let f2=linear2af var2index t2 in
            AF.add f1 f2
    | _ ->
         monom2af var2index t

let ge2af var2index (i,t) =
   let left,right=dest_ge_rat t in
   let f1=linear2af var2index left in
   let f2=linear2af var2index right in
   let f=AF.sub f1 f2 in
   AF.hypSource i f

let apply_rewrite p conv t =
   let es={sequent_args= <<sequent_arg>>; sequent_hyps=(SeqHyp.of_list []); sequent_concl=t} in
   let s=mk_sequent_term es in
   let s'=Top_conversionals.apply_rewrite p (addrC concl_addr conv) s in
   TermMan.concl s'

let rec make_sacs_aux p i l = function
   [] -> l
 | hd::tl ->
      let i' = succ i in
      match hd with
         Hypothesis (_, t) ->
            (match explode_term t with
               <<ge_rat{'left; 'right}>> when not (alpha_equal left right) ->
                  let t'=apply_rewrite p ge_normC t in
                  make_sacs_aux p i' ((i,t')::l) tl
             | <<ge{'left; 'right}>> when not (alpha_equal left right) ->
                  let t'=apply_rewrite p (int2ratC thenC ge_normC) t in
                  make_sacs_aux p i' ((i,t')::l) tl
             | _ ->
                  make_sacs_aux p i' l tl
            )
       | Context _ -> make_sacs_aux p i' l tl

type sacs' = Constraints of SACS.sacs | Contradiction of source

let is_neg_number f =
   if AF.isNumber f then
      isNegative (AF.coef f AF.constvar)
   else
      false

let make_sacs var2index p =
   let hyps = Term.SeqHyp.to_list (Sequent.explode_sequent_arg p).sequent_hyps in
   let ihyps = make_sacs_aux p 1 [] hyps in
   let afs=List.map (ge2af var2index) ihyps in
   try
       let f = List.find is_neg_number afs in
       Contradiction (AF.getSource f)
   with Not_found ->
      let s = List.fold_left SACS.addConstr (SACS.empty (VI.length var2index)) afs in
      Constraints s

(*
module TermPos=
struct
   type data = int
   let append l1 l2 = l1 @ l2
end

module TTable=Term_eq_table.MakeTermTable(TermPos)

let mem h t = TTable.mem !h t
let add h t d = h:=(TTable.add !h t d)
let empty _ = ref (TTable.empty)
*)

let resource intro += [
   <<ge_rat{rat{number[i:n];number[j:n]}; rat{number[k:n];number[l:n]}}>>, wrap_intro (rw reduceC 0);
   <<lt_rat{rat{number[i:n];number[j:n]}; rat{number[k:n];number[l:n]}}>>, wrap_intro (rw reduceC 0);
   <<gt_rat{rat{number[i:n];number[j:n]}; rat{number[k:n];number[l:n]}}>>, wrap_intro (rw reduceC 0);
   <<le_rat{rat{number[i:n];number[j:n]}; rat{number[k:n];number[l:n]}}>>, wrap_intro (rw reduceC 0);
]

(*
interactive ge2leftMin 'H 'J :
   [wf] sequent { <H>; ge_rat{'a; 'c}; <J>; ge_rat{'b; 'c}; <K> >- 'a in rationals } -->
   [wf] sequent { <H>; ge_rat{'a; 'c}; <J>; ge_rat{'b; 'c}; <K> >- 'b in rationals } -->
   [wf] sequent { <H>; ge_rat{'a; 'c}; <J>; ge_rat{'b; 'c}; <K> >- 'c in rationals } -->
   sequent { <H>; ge_rat{'a; 'c}; <J>; ge_rat{'b; 'c}; <K>; ge_rat{min_rat{'a;'b}; 'c} >- 'C } -->
   sequent { <H>; ge_rat{'a; 'c}; <J>; ge_rat{'b; 'c}; <K> >- 'C }

let ge2leftMinT i j = funT (fun p ->
   let i=Sequent.get_pos_hyp_num p i in
   let j=Sequent.get_pos_hyp_num p j in
   begin
      if !debug_supinf_steps then
         let h1=Sequent.nth_hyp p i in
         let h2=Sequent.nth_hyp p j in
         eprintf "ge2leftMinT %i %i on %s %s@." i j
            (SimplePrint.short_string_of_term h1)
            (SimplePrint.short_string_of_term h2)
   end;
   ge2leftMin i (j-i)
)

interactive ge2rightMax 'H 'J :
   [wf] sequent { <H>; ge_rat{'a; 'b}; <J>; ge_rat{'a; 'c}; <K> >- 'a in rationals } -->
   [wf] sequent { <H>; ge_rat{'a; 'b}; <J>; ge_rat{'a; 'c}; <K> >- 'b in rationals } -->
   [wf] sequent { <H>; ge_rat{'a; 'b}; <J>; ge_rat{'a; 'c}; <K> >- 'c in rationals } -->
   sequent { <H>; ge_rat{'a; 'b}; <J>; ge_rat{'a; 'c}; <K>; ge_rat{'a; max_rat{'b;'c}} >- 'C } -->
   sequent { <H>; ge_rat{'a; 'b}; <J>; ge_rat{'a; 'c}; <K> >- 'C }

let ge2rightMaxT i j = funT (fun p ->
   let i=Sequent.get_pos_hyp_num p i in
   let j=Sequent.get_pos_hyp_num p j in
   begin
      if !debug_supinf_steps then
         let h1=Sequent.nth_hyp p i in
         let h2=Sequent.nth_hyp p j in
         eprintf "ge2rightMaxT %i %i on %s %s@." i j
            (SimplePrint.short_string_of_term h1)
            (SimplePrint.short_string_of_term h2)
   end;
   ge2rightMax i (j-i)
)
*)

interactive ge2transitive 'H 'J :
   [wf] sequent { <H>; ge_rat{'a; 'b}; <J>; ge_rat{'b; 'c}; <K> >- 'a in rationals } -->
   [wf] sequent { <H>; ge_rat{'a; 'b}; <J>; ge_rat{'b; 'c}; <K> >- 'b in rationals } -->
   [wf] sequent { <H>; ge_rat{'a; 'b}; <J>; ge_rat{'b; 'c}; <K> >- 'c in rationals } -->
   sequent { <H>; ge_rat{'a; 'b}; <J>; ge_rat{'b; 'c}; <K>; ge_rat{'a; 'c} >- 'C } -->
   sequent { <H>; ge_rat{'a; 'b}; <J>; ge_rat{'b; 'c}; <K> >- 'C }

let ge2transitiveT i j = funT (fun p ->
   let i=Sequent.get_pos_hyp_num p i in
   let j=Sequent.get_pos_hyp_num p j in
   begin
      if !debug_supinf_steps then
         let h1=Sequent.nth_hyp p i in
         let h2=Sequent.nth_hyp p j in
         eprintf "ge2transitiveT %i %i on %s %s@." i j
            (SimplePrint.short_string_of_term h1)
            (SimplePrint.short_string_of_term h2)
   end;
   ge2transitive i (j-i)
)

open Tree

let treeMapHelper n2 tac2 (n1,tac1) = n1+n2, (tac1 thenMT tac2)

let treeProductHelper (n1,tac1) (n2,tac2) =
   n1+n2+1, (tac1 thenMT tac2 thenMT ge_addMono2T (-n2-1) (-1) thenMT rw ge_normC (-1))

let treeMergeHelper (n1,tac1) (n2,tac2) =
   n1+n2+1, (tac1 thenMT tac2 thenMT ge2transitiveT (-n2-1) (-1))

let rec source2hyp info = function
   Signore ->
      if !debug_supinf_trace then
         eprintf "Signore reached source2hyp@.";
      Ignore
 | Shypothesis i ->
      if !debug_supinf_trace then
         eprintf "hyp %i@." i;
      Leaf(1, ((rw (tryC (progressC (int2ratC thenC ge_normC))) i) thenMT copyHypT i (-1)))
 | Smin(Signore,s2) ->
      let result = source2hyp info s2 in
      if !debug_supinf_trace then
         eprintf "minRight %s@." (string_of_tree result);
      Right result
 | Smin(s1,Signore) ->
      let result = source2hyp info s1 in
      if !debug_supinf_trace then
         eprintf "minLeft %s@." (string_of_tree result);
      Left result
 | Smin(s1,s2) ->
      let result1 = source2hyp info s1 in
      let result2 = source2hyp info s2 in
      if !debug_supinf_trace then
         eprintf "min %s %s@." (string_of_tree result1) (string_of_tree result2);
      Pair(result1, result2)
 | Smax(Signore,s2) ->
      let result = source2hyp info s2 in
      if !debug_supinf_trace then
         eprintf "maxRight %s@." (string_of_tree result);
      Right result
 | Smax(s1,Signore) ->
      let result = source2hyp info s1 in
      if !debug_supinf_trace then
         eprintf "maxLeft %s@." (string_of_tree result);
      Left result
 | Smax(s1,s2) ->
      let result1 = source2hyp info s1 in
      let result2 = source2hyp info s2 in
      if !debug_supinf_trace then
         eprintf "max %s %s@." (string_of_tree result1) (string_of_tree result2);
      Pair(result1, result2)
 | Sleft(s) ->
      let result = source2hyp info s in
      if !debug_supinf_trace then
         eprintf "left %s@." (string_of_tree result);
      leftBranch result
 | Sright(s) ->
      let result = source2hyp info s in
      if !debug_supinf_trace then
         eprintf "right %s@." (string_of_tree result);
      rightBranch result
 | Sextract2left(vi,s) ->
      let result = source2hyp info s in
      let v = VI.restore info vi in
      if !debug_supinf_trace then
         eprintf "extrLeft %i %s %s@." vi (SimplePrint.short_string_of_term v) (string_of_tree result);
      treeMap (treeMapHelper 0 (rw (extract2leftC v) (-1))) result
 | Sextract2right(vi,s) ->
      let result = source2hyp info s in
      let v = VI.restore info vi in
      if !debug_supinf_trace then
         eprintf "extrRight %i %s %s@." vi (SimplePrint.short_string_of_term v) (string_of_tree result);
      treeMap (treeMapHelper 0 (rw (extract2rightC v) (-1))) result
 | StrivialConst c ->
      let ctm = term_of c in
      let tm = mk_ge_rat_term ctm ctm in
      if !debug_supinf_trace then
         eprintf "trivConst %s@." (SimplePrint.short_string_of_term ctm);
      Leaf(1, (assertT tm thenAT geReflexive))
 | StrivialVar vi ->
      let v = VI.restore info vi in
      let tm = mk_ge_rat_term v v in
      if !debug_supinf_trace then
         eprintf "trivVar %i %s@." vi (SimplePrint.short_string_of_term v);
      Leaf(1, (assertT tm thenAT geReflexive))
 | Sscale(c,s) ->
      let result = source2hyp info s in
      let tm = term_of c in
      if !debug_supinf_trace then
         eprintf "scale %a %s@." RationalBoundField.print c (string_of_tree result);
      if compare c fieldZero >0 then
         treeMap (treeMapHelper 0 (rw ((positive_multiply_ge tm) thenC ge_normC) (-1))) result
      else
         treeMap (treeMapHelper 0 (rw ((negative_multiply_ge tm) thenC ge_normC) (-1))) result
 | SaddVar(c,vi,s) ->
      let result = source2hyp info s in
      let v = VI.restore info vi in
      let tm = mk_mul_rat_term (term_of c) v in
      if !debug_supinf_trace then
         eprintf "addV %i %s %s@." vi (SimplePrint.short_string_of_term v) (string_of_tree result);
      treeMap (treeMapHelper 0 (rw ((ge_addMono_rw tm) thenC ge_normC) (-1))) result
 | Ssum(s1,s2) ->
      (* this case computes a product of two trees
       * it should be consistent with SAF.add
       *)
      let result1 = source2hyp info s1 in
      let result2 = source2hyp info s2 in
      if !debug_supinf_trace then
         eprintf "sum %s %s@." (string_of_tree result1) (string_of_tree result2);
      treeProduct treeProductHelper result1 result2
 | StransitiveLeft(s1,s2,vi) ->
      let result1 = source2hyp info s1 in
      let result2 = source2hyp info s2 in
      let v = VI.restore info vi in
      if !debug_supinf_trace then
         eprintf "tranL %i %s >= %s >= %s@." vi (string_of_tree result1) (string_of_tree result2) (SimplePrint.short_string_of_term v);
      treeMergeLeft treeMergeHelper result1 result2
 | StransitiveRight(vi,s1,s2) ->
      let result1 = source2hyp info s1 in
      let result2 = source2hyp info s2 in
      let v = VI.restore info vi in
      if !debug_supinf_trace then
         eprintf "tranR %i %s >= %s >= %s@." vi (SimplePrint.short_string_of_term v) (string_of_tree result1) (string_of_tree result2);
      treeMergeRight treeMergeHelper result1 result2
 | Scontradiction s ->
      let result = source2hyp info s in
      if !debug_supinf_trace then
         eprintf "contrad %s@." (string_of_tree result);
      result

let rec proj2 = function
   [] -> []
 | (a,b)::tail -> b::(proj2 tail)

let source2hypT info s = funT (fun p ->
   if !debug_supinf_trace then
      eprintf "%a@." print s;
   let result = source2hyp info s in
   let taclist = proj2 (treeFlatten result) in
   seqOnMT taclist thenMT rw normalizeC (-1)
)

interactive inseparable_rat 'H 'n :
   [wf] sequent { <H>; ge_rat{'a; 'b}; <J> >- 'a in rationals } -->
   [wf] sequent { <H>; ge_rat{'a; 'b}; <J> >- 'b in rationals } -->
   [wf] sequent { <H>; ge_rat{'a; 'b}; <J> >- 'n in int } -->
   sequent { <H>; ge_rat{'a; 'b}; <J> >- gt_rat{'a; rat_of_int{'n}} } -->
   sequent { <H>; ge_rat{'a; 'b}; <J> >- gt_rat{rat_of_int{'n +@ 1}; 'b} } -->
   sequent { <H>; ge_rat{'a; 'b}; <J> >- 'C }

let use_both info v sup' inf' supsrc infsrc =
   let supsrc=SAF.getSource sup' in
   let sup_tm=SAF.term_of info sup' in
   let inf_tm=SAF.term_of info inf' in
   let tm=mk_ge_rat_term sup_tm inf_tm in
   source2hypT info supsrc thenMT
   source2hypT info infsrc thenMT
   (assertT tm thenAT geTransitive (VI.restore info v))

let isIntegral t = is_rat_of_int_term t

let rec iter p info constrs v =
   if !debug_supinf_post then
      eprintf "Iteration %i@." v;
   if v > (Array.length info) then
      begin
         printf "No contradiction found:\n%t@." (SACS.print_bounds info constrs);
         failT
      end
   else
      let saf'=SAF.affine (AF.mk_var v) in
      let sup' = sup info constrs saf' CS.empty in
      let supsrc=SAF.getSource sup' in
      if SAF.isMinusInfinity sup' then
         begin
            if !debug_supinf_steps then
               begin
                  eprintf "start=%a@." SAF.print saf';
                  eprintf"sup=%a@." SAF.print sup';
                  eprintf "%a <= %a@." (**)
                     SAF.print saf'
                     SAF.print sup';
               end;
            source2hypT info supsrc
         end
      else
         let inf' = inf info constrs saf' CS.empty in
         let infsrc=SAF.getSource inf' in
         begin
            if !debug_supinf_steps then
               begin
                  eprintf "start=%a@." SAF.print saf';
                  eprintf"sup=%a@." SAF.print sup';
                  eprintf"inf=%a@." SAF.print inf';
                  eprintf "%a <= %a <= %a@." (**)
                     SAF.print inf'
                     SAF.print saf'
                     SAF.print sup';
               end;
            if (SAF.isPlusInfinity inf') then
               source2hypT info infsrc
            else
               begin
                  if !debug_supinf_post then
                     eprintf "%a >= %a >= %a@."
                        SAF.print sup'
                        VarType.print v
                        SAF.print inf';
                  let sup_val=SAF.value_of sup' in
                  let inf_val=SAF.value_of inf' in
                  if compare sup_val inf_val >= 0 then
                     if    SAF.isInfinite sup' ||
                           SAF.isInfinite inf' ||
                           not (isIntegral (VI.restore info v)) then
                        let constrs' = SACS.addUpperBound constrs v sup_val in
                        let constrs'' = SACS.addLowerBound constrs' v inf_val in
                        iter p info constrs'' (succ v)
                     else
                        let floor_inf = floor inf_val in
                        let floor_sup = floor sup_val in
                        let floor_inf' = RationalBoundField.Num(floor_inf, num1) in
                        let floor_sup' = RationalBoundField.Num(floor_sup, num1) in
                        if compare floor_inf' floor_sup' = 0 then
                           use_both info v sup' inf' supsrc infsrc thenMT
                           inseparable_rat (-1) (mk_number_term floor_inf) thenMT
                           rw normalizeC 0
                        else
                           let constrs' = SACS.addUpperBound constrs v sup_val in
                           let constrs'' = SACS.addLowerBound constrs' v inf_val in
                           iter p info constrs'' (succ v)
                  else
                     use_both info v sup' inf' supsrc infsrc thenMT
                     rw normalizeC (-1)
               end
         end

let coreT = funT (fun p ->
   let var2index = VI.create 13 in
   let s = make_sacs var2index p in
   let info=VI.invert var2index in
   if !debug_supinf_steps || !debug_supinf_post then
      eprintf "Vars:\n%a@." VI.print var2index;
   match s with
      Constraints constrs ->
         if !debug_supinf_steps || !debug_supinf_post then
            eprintf "SACS:\n%a@." SACS.print constrs;
         iter p info constrs 1
    | Contradiction s ->
         if !debug_supinf_steps || !debug_supinf_post then
            eprintf "Contradiction at %a@." S.print s;
          source2hypT info (Scontradiction s)
)

let ge_int2ratT = argfunT (fun i p ->
   if is_ge_term (Sequent.nth_hyp p i) then
      rw (int2ratC thenC ge_normC) i
   else
      idT
)

let core2T = coreT
let supinfT = preT thenMT coreT

interactive test 'a 'b 'c :
sequent { <H> >- 'a in rationals } -->
sequent { <H> >- 'b in rationals } -->
sequent { <H> >- 'c in rationals } -->
sequent { <H>; ge_rat{'a; add_rat{'b; rat{1;1}}};
               ge_rat{'c; add_rat{'b; rat{3;1}}};
               ge_rat{'b; add_rat{'a; rat{0;1}}}
               >- "assert"{bfalse} }

interactive test2 'a 'b 'c :
sequent { <H> >- 'a in rationals } -->
sequent { <H> >- 'b in rationals } -->
sequent { <H> >- 'c in rationals } -->
sequent { <H>; ge_rat{'a; rat{0;1}};
               ge_rat{'b; rat{0;1}};
               ge_rat{rat{-1;1}; add_rat{'a; 'b}}
               >- "assert"{bfalse} }

interactive test3 'a 'b 'c :
sequent { <H> >- 'x in rationals } -->
sequent { <H> >- 'y in rationals } -->
sequent { <H>;
               ge_rat{mul_rat{rat{-1;1};'x}; mul_rat{rat{-1;1};'y}};
               ge_rat{'y; rat{0;1}};
               ge_rat{add_rat{rat{-1;1}; mul_rat{rat{-1;1};'y}};neg_rat{'x}}
               >- "assert"{bfalse} }

interactive test4 'a 'b 'c :
sequent { <H> >- 'a in rationals } -->
sequent { <H> >- 'b in rationals } -->
sequent { <H> >- 'c in rationals } -->
sequent { <H>; ge_rat{'a; add_rat{'b;rat{3;1}}};
               ge_rat{'a; add_rat{rat{3;1};mul_rat{rat{-1;1};'b}}};
               ge_rat{add_rat{'b;rat{2;1}}; 'a}
               >- "assert"{bfalse} }
