extends Cic_lambda

rule collapse_base :
	sequent { <H> >- 'C } -->
	sequent { <H> >- sequent { >- 'C } }

rule collapse_step :
	sequent { <H>; x:'T >- sequent { <J['x]> >- 'C['x] } } -->
	sequent { <H> >- sequent { x: 'T; <J['x]> >- 'C['x] } }

(*********************************************
 *         INDUCTIVE DEFINITIONS PART        *
**********************************************)

(* Coq's Ind(H)[Hp](Hi:=Hc) - inductive definition *)
declare Ind       (* *)
declare IndTypes    (* for ind.defenitions, Hi - new types, defenitions of new types *)
declare IndParams (* for ind. defenirions, Hp - parameters of ind. defenition *)
declare IndConstrs (* for ind. defenitions, Hc - constructors *)

(* declaration of a multiple product, i.e. (p1:P1)(p2:P2)...(pr:Pr)T *)
declare prodH     (*{ <H> >- 'T }*)


(* inductive definition of multiple product *)
rewrite prodH_base :
   sequent [prodH] { x:'T >- 'S['x] } <--> product{'T; x.'S['x]}

rewrite prodH_step :
   sequent [prodH] { <H>; x:'T >- 'S['x] } <-->
	sequent [prodH] { <H> >- product{'T;x.'S['x]} }


(* base axioms about Ind and IndTypes *)
(* for new types *)
rewrite indSubstDef 'Hi1 :
   sequent [IndParams] { <Hp> >-
	   (sequent [IndTypes] { <Hi1>; x:'T<|Hp|>; <Hi2<|Hp|> > >-
		   (sequent [IndConstrs] { <Hc['x]> >- 't['x]})})} <-->
   sequent [IndParams] { <Hp> >-
	   (sequent [IndTypes] { <Hi1>; x1:'T<|Hp|>; <Hi2<|Hp|> > >-
		   (sequent [IndConstrs] { <Hc['x1]> >-
			   't[sequent [IndParams] { <Hp> >-
				   (sequent [IndTypes] { <Hi1>; x:'T<|Hp|>; <Hi2<|Hp|> > >-
				      sequent [IndConstrs] { <Hc['x]> >- 'x}})}] })})}

(* for constructors (names, types) *)
rewrite indSubstConstr 'Hc1 :
   sequent [IndParams] { <Hp> >-
	   sequent [IndTypes] { <Hi> >-
		   sequent [IndConstrs] { <Hc1>; c:'C<|Hi;Hp|>; < Hc2<|Hi;Hp|> > >- 't['c]}}} <-->
   sequent [IndParams] { <Hp> >-
	   sequent [IndTypes] { <Hi> >-
		   sequent { <Hc1>; c1:'C<|Hi; Hp|>; < Hc2<|Hi; Hp|> > >-
				't[ sequent [IndParams] { <Hp> >-
				   sequent [IndTypes] { <Hi> >-
				      sequent [IndConstrs] { <Hc1>; c:'C<|Hi; Hp|>; < Hc2<|Hi; Hp|> > >- 'c}}}]}}}

(* carry out ground terms from the Ind *)
rewrite indCarryOut :
   sequent [IndParams] { <Hp> >-
	   sequent [IndTypes] { <Hi> >-
	      sequent [IndConstrs] { <Hc> >- 't<||> } } } <-->
	't<||>


(* implementation of the first part of the Coq's Ind-Const rule *)
rule ind_ConstDef 'Hi1 :
   sequent { <H> >-
	   WF{
		   sequent [IndParams] { <Hp> >-
		      sequent [IndTypes] { <Hi1>; I:'A<|Hp;H|>; <Hi2<|Hp;H|> > >-
		         sequent [IndConstrs] { <Hc['I]> >- it }}} } } -->
	sequent { <H> >-
		sequent [IndParams] { <Hp> >-
			sequent [IndTypes] { <Hi1>; I:'A<|Hp;H|>; <Hi2<|Hp;H|> > >-
				sequent { <Hc['I]> >- 'I } } }
		in	sequent [prodH] { <Hp> >- 'A} }

(* declaration of a multiple application, i.e. (...((Ip1)p2)p3...)pr *)
declare applH (* { <H> >- 'T } *)

(*inductive definition of multiple application *)
rewrite applH_base :
   sequent [applH] { x:'T >- sequent { <H> >- 'S} } <-->
	sequent { <H>; x:'T >- app{'S;'x} }

rewrite applH_step :
   sequent [applH] { x:'T; <H> >- sequent { <J> >- 'S} } <-->
	sequent [applH] { <H> >- sequent { <J>; x:'T >- app{'S;'x} } }

(* Product + Application + Substitution (p1:P1)...(pn:Pn)C{I/Ip1...pn} *)
declare prodapp

rewrite prodapp_base :
   sequent [prodapp] { >- bind{i.'C['i]} } <-->
	bind{ i.'C['i] }

rewrite prodapp_step :
   sequent [prodapp] { <Hp>; p:'P >- bind{i.'C['i]} } <-->
	sequent [prodapp] { <Hp> >- bind{ i.product{ 'P; p.'C[app{'i;'p}] } } }


(* declaration of multiple substitution *)
declare substH (* {<Hp> >- ( <Hi> >- 'T ) } *)

(* inductive definition of multiple substitution with multiple application applied*)
(*
rewrite substH_base :
   sequent [substH] { <Hp> >- sequent { >- 'C<|'Hp|> } } <-->  'C<|'Hp|>

rewrite substH_step :
   sequent [substH] { <Hp> >- sequent { <Hi>; x:'T >- 'C['x] } } <-->
	sequent [substH] { <Hp> >- sequent { <Hi> >-
	   'C[ sequent [applH] { <Hp> >- 'x }] } }
*)
rewrite substH_base :
   sequent { <Hp> >- sequent [substH] { >- 'C } } <-->
	sequent { <Hp> >- 'C }

rewrite substH_step :
   sequent { <Hp> >- sequent [substH] { <Hi>; I:'A >- 'C['I] } } <-->
	sequent { <Hp> >- sequent [substH] { <Hi> >-
	   sequent [prodapp] { <Hp> >- bind{i.'C['i]} } } }

(* implementation of the second part of the Coq's Ind-Const rule *)
rule ind_ConstConstrs 'Hc1 :
   sequent { <H> >-
	   WF {
		   sequent [IndParams] { <Hp> >-
			   sequent [IndTypes] { <Hi> >-
	            sequent [IndConstrs] { <Hc1>; c:'C<|Hi;Hp;H|>; <Hc2<|Hi;Hp;H|>['c]> >- it }}} }}  -->
	sequent { <H> >-
	   sequent [IndParams] { <Hp> >-
		   sequent [IndTypes] { <Hi> >-
	         sequent [IndConstrs] { <Hc1>; c:'C<|Hi;Hp;H|>; <Hc2<|Hi;Hp;H|>['c]> >-
				   'c in sequent [prodH] { <Hp> >- 'C } } } } }


(*******************************************************************************************
 *  in the next part the conditions for the W-Ind rule and the W-Ind rule are implemented  *
 *******************************************************************************************)

declare of_some_sort (* { <T> } *) (* any element of T is a type of some sort (Set, Prop or Type[i]) *)

declare has_type_m (* { <I> >- ( <T> >- has_type_m ) } *) (* multiple has_type, i.e. I={I1,...,Ik}, T={T1,...,Tk},
                                         member{Ij;Tj}, j=1,..,k *)
(* declaration of 'arity of sort' notion *)
declare arity_of_some_sort_m (* (<Hi> >- <S>)*) (* Hi={I1:A1,...,Ik:Ak}, S={s1,...,sk},
                                            Aj is an arity of sort sj, j=1,...,k*)
declare arity_of_some_sort{'T} (* type T is an arity of some sort *)

rule arity_of_some_sort_Set :
   sequent { <H> >- arity_of_some_sort{Set} }

rule arity_of_some_sort_Prop :
	sequent { <H> >- arity_of_some_sort{Prop} }

rule arity_of_some_sort_Type :
   sequent { <H> >- arity_of_some_sort{"type"[i:l]} }

rule arity_of_some_sort_prod bind{x.'U['x]} :
   sequent { <H>; x:'T1 >- arity_of_some_sort{'U['x]} } -->
	sequent { <H> >- arity_of_some_sort{product{'T1;x.'U['x]}} }

rule arity_of_some_sort_m_base :
   sequent { <H> >- arity_of_some_sort{'T} } -->
	sequent { <H> >- sequent [arity_of_some_sort_m] { t:'T >- arity_of_some_sort_m } }

rule arity_of_some_sort_m_step :
   sequent { <H> >- arity_of_some_sort{'T} } -->
	sequent { <H> >- sequent [arity_of_some_sort_m] { <T1> >- arity_of_some_sort_m} } -->
   sequent { <H> >- sequent [arity_of_some_sort_m] { <T1>; t:'T<||> >- arity_of_some_sort_m } }

declare arity_of_sort{'T;'s} (* type T is an arity of sort 's *)

rule arity_of_sort_Set :
   sequent { <H> >- arity_of_sort{Set;Set} }

rule arity_of_sort_Prop :
   sequent { <H> >- arity_of_sort{Prop;Prop} }

rule arity_of_sort_Type :
   sequent { <H> >- arity_of_sort{"type"[i:l];"type"[i:l]} }

rule arity_of_sort_prod bind{x.'U['x]} :
   sequent { <H>; x:'T1 >- arity_of_sort{'U['x]; 's} } -->
	sequent { <H> >- arity_of_sort{product{'T1;x.'U['x]}; 's} }

(* declaration of 'type of constructor' notion *)
declare type_of_constructor{'T;'I} (* 'T is a type of constructor of 'I *)

rule type_of_constructor_app :
   sequent { <H> >- type_of_constructor{ (sequent [applH]{ <T1> >- 'I}); 'I } }

rule type_of_constructor_prod 'T1 bind{x.'C['x]} :
   sequent { <H>; x:'T1 >- type_of_constructor{'C['x];'I} } -->
	sequent { <H> >- type_of_constructor{ product{'T1;x.'C['x]}; 'I } }

declare imbr_pos_cond_m (* { <Hc> >-( 'I >- 'x ) } *)
(* Hc={c1:C1,...,cn:Cn}, the types constructor Ci (each of them) of 'I
satisfies the imbricated positivity condition for a constant 'x *)

declare imbr_pos_cond{'T;'I;'x} (* the type constructor 'T of 'I satisfies the imbricated positivity
                                   condition of 'x *)

declare strictly_pos{'x;'T} (* constant 'x occurs strictly positively in 'T *)

declare positivity_cond{ 'T; 'x } (* the type of constructor 'T satisfies the positivity
												condition for a constant 'x *)

(* declaration of 'positivity condition' notion *)
rule positivity_cond_1 'H :
   sequent { <H>; x:'T; <J['x]> >- sequent [applH] { <T1> >- 'x} } -->
	sequent { <H>; x:'T; <J['x]> >-
	   positivity_cond{ sequent [applH] { <T1> >- 'x} ;'x } }

rule positivity_cond_2 'H bind{x.'T['x]} bind{y,x.'U['y;'x]}:
   sequent { <H>; x:'S; <J['x]> >- strictly_pos{'x;'T['x]}} -->
	sequent { <H>; x:'S; <J['x]>; y:'T['x] >- positivity_cond{'U['y;'x];'x} } -->
	sequent { <H>; x:'S; <J['x]> >- positivity_cond{product{'T['x];y.'U['y;'x]};'x} }

(* declaration of multiple positivity condition *)
declare positivity_cond_m

rule positivity_cond_m_base :
   sequent { <H>; I:'A >- positivity_cond{'C['I];'I} } -->
	sequent { <H> >- sequent [positivity_cond_m] { I:'A >- 'C['I] } }

rule positivity_cond_m_step :
   sequent { <H>; I:'A >- sequent { <Hi> >- positivity_cond{'C['I];'I} } } -->
	sequent { <H>; I:'A >- sequent [positivity_cond_m] { <Hi > >- 'C['I] } } -->
	sequent { <H> >- sequent [positivity_cond_m] { <Hi>; I:'A<|H|> >- 'C['I] } }

(* declaration of 'strictly positive' notion *)
rule strictly_pos_1 'H :
   sequent { <H>; x:'T1; <J['x]>  >- strictly_pos{'x;'T} }

rule strictly_pos_2 'H :
	sequent { <H>; x:'T1; <J['x]> >- strictly_pos{'x;sequent [applH] { <T2> >- 'x}} }

rule strictly_pos_3 'H 'U bind{x,y.'V['x;'y]} :
   sequent { <H>; x:'T2; <J['x]>; x1:'U >- strictly_pos{'x;'V['x1;'x]} } -->
	sequent { <H>; x:'T2; <J['x]> >-
	   strictly_pos{'x ; product{ 'U;x1.'V['x1;'x]}} }

(*
rule strictly_pos_4 'H :
   sequent { <H>; x:'T2; <J['x]>; <A1['x]> >-
	   sequent [imbr_pos_cond_m] { <Hc<|A1;H;J|>['I;'x]> >-
		   sequent { 'I >- 'x } } } -->
	sequent { <H>; x:'T2; <J['x]> >-
	   strictly_pos{
		   'x;
			sequent [applH] { <T1>; <A1['x]> >-
				sequent [IndParams] { <Hp> >-
					sequent [IndTypes] { I:'A<|Hp;H;J|>['x] >-
						sequent [IndConstrs] { <Hc<|Hp;H;J|>['I;'x]> >- 'I } } } }} }
*)



(* declaration of 'imbricated positivity condition' notion *)

rule imbr_pos_cond_1 'H :
   sequent { <H>; x:'T; <J['x]> >-
	   type_of_constructor{ sequent [applH] { <T1> >- 'I<|J;H|>['x]} ;'I<|J;H|>['x]} } -->
	sequent { <H>; x:'T; <J['x]> >-
	   imbr_pos_cond{ sequent [applH] { <T1> >- 'I<|J;H|>['x]};'I<|J;H|>['x];'x} }

rule imbr_pos_cond_2 'H bind{x,y.'U['x;'y]} :
   sequent { <H>; x:'T2; <J['x]> >- type_of_constructor{ product{'T['x];x1.'U['x1;'x]} ;'I} } -->
   sequent { <H>; x:'T2; <J['x]> >- strictly_pos{'x;'T['x]} } -->
	sequent { <H>; x:'T2; <J['x]>; x1:'T['x] >- imbr_pos_cond{'U['x1;'x];'I;'x} } -->
	sequent { <H>; x:'T2; <J['x]> >- imbr_pos_cond{product{'T['x];x1.'U['x1;'x]};'I;'x} }

(* inductive definition of multiple imbricated positivity condition, i.e.
   of imbr_pos_cond_m *)
declare imbr_params{'I;'x}

rule imbr_pos_cond_m_base 'H :
   sequent { <H>; x:'T; <J['x]> >- imbr_pos_cond{'C['x];'I['x];'x} } -->
	sequent { <H>; x:'T; <J['x]> >-
		sequent [imbr_pos_cond_m] { c:'C['x] >- imbr_params{'I['x];'x} } }

rule imbr_pos_cond_m_step 'H :
   sequent { <H>; x:'T; <J['x]> >- imbr_pos_cond{'C['x];'I['x];'x} } -->
	sequent { <H>; x:'T; <J['x]> >-
		sequent [imbr_pos_cond_m] { <Hc['x]> >-
			imbr_params{'I<|H;J|>['x];'x} } } -->
	sequent { <H>; x:'T; <J['x]> >- sequent [imbr_pos_cond_m] { <Hc['x]>; c:'C<|H;J|>['x] >-
	   imbr_params{'I<|H;J|>['x];'x} } }


(* declaration of 'of some sort' notion *)
declare of_some_sort_m (* { <T> } *) (* any element of T is a type of some sort (Set, Prop or Type[i]) *)

(* inductive defenition of multiple of_come_sort_m *)
rule of_some_sort_m_base :
   sequent { <H> >- of_some_sort{'T} } -->
	sequent { <H> >- sequent [of_some_sort_m] { t:'T >- of_some_sort_m } }

rule of_some_sort_m_step :
   sequent { <H> >- of_some_sort{'T2} } -->
	sequent { <H> >- sequent [of_some_sort_m] { <T1> >- of_some_sort_m } } -->
	sequent { <H> >- sequent [of_some_sort_m] { <T1>; t:'T2<|H|> >- of_some_sort_m } }


(* description-defenition of the third condition in the declaration of w_Ind rule*)
declare req3{'C}
declare req3_m

rule req3_intro 'Hi 's :
   sequent { <H> >- sequent { <Hi>; I:'A<|H|>; <Ji<|H|> > >- type_of_constructor{'C['I];'I} } } -->
   sequent { <H> >- sequent [positivity_cond_m] { <Hi>; I:'A<|H|>; <Ji<|H|> > >- 'I } } -->
	sequent { <H> >- arity_of_sort{'A<|H|>;'s<||>} } -->
	sequent { <H> >- sequent { <Hi>; I:'A<|H|>; <Ji<|H|> > >- 'C['I] in 's<||> } } -->
   sequent { <H> >- sequent { <Hi>; I:'A<|H|>; <Ji<|H|> > >- req3{'C['I]} } }

rule req3_m_base :
   sequent { <Hi> >- req3{'C} } -->
	sequent { <Hi> >- sequent [req3_m] { c:'C >- it } }

rule req3_m_step :
	sequent { <H> >- sequent [req3_m] { <Hi> >- sequent { <Hc> >- it } } } -->
	sequent { <H> >- sequent { <Hi> >- req3{'C<|Hi;H|>} } } -->
	sequent { <H> >- sequent [req3_m] { <Hi> >- sequent { <Hc>; c:'C<|Hi;H|> >- it } } }


(* implementation of the Coq's W-Ind rule *)
rule w_Ind :
   sequent { <H> >- sequent { <Hp> >-
		sequent [of_some_sort_m] { <Hi> >- of_some_sort_m } } } -->
	sequent { <H> >- sequent { <Hp> >-
		sequent [arity_of_some_sort_m] { <Hi> >- arity_of_some_sort_m } } } -->
	sequent { <H> >- sequent { <Hp> >- sequent [req3_m] { <Hi> >- sequent { <Hc> >- it } } } } -->
	sequent { <H> >-
	   WF{
			sequent [IndParams] { <Hp> >-
				sequent [IndTypes] { <Hi> >-
					sequent [IndConstrs] { <Hc> >- it } } } } }


(****************************************************************
 * *
 ****************************************************************)


