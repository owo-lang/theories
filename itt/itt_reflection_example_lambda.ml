extends Itt_functions
extends Itt_reflection
extends Itt_nat
extends Itt_bisect
extends Itt_list
extends Itt_srec
extends Itt_pairwise
extends Itt_pairwise2

open Basic_tactics

define app_term: app_term <--> apply[@]{term[@];term[@]}
define lambda_term: lambda_term <--> lambda[@]{x.term[@]}

define mk_app: mk_app <--> lambda {p. spread{'p; t1,t2. make_bterm{app_term; 't1::'t2::nil}}}

interactive_rw mk_app2 {| reduce |}: mk_app ('f,'a) <-->  make_bterm{app_term; 'f::'a::nil}

define dom_app: dom_app{'T;'S} <-->
   {p:(BTerm isect 'T)*(BTerm isect 'S) |
       var_arity{fst{'p}} =  var_arity{snd{'p}} in nat}

interactive mk_app_wf  {| intro[] |}:
   sequent { <H> >- "type"{'T} } -->
   sequent { <H> >- "type"{'S} } -->
   sequent { <H> >- mk_app in dom_app{'T;'S} -> BTerm }

define mk_lambda: mk_lambda <--> lambda {t. make_bterm{lambda_term; 't::nil}}

interactive_rw mk_lambda2 {| reduce |}: mk_lambda 'f <-->  make_bterm{lambda_term; 'f::nil}

define dom_lambda: dom_lambda{'T} <--> {t:BTerm isect 'T | var_arity{'t} >= 1}


interactive mk_lambda_wf  {| intro[] |}:
   sequent { <H> >- "type"{'T} } -->
   sequent { <H> >- mk_lambda: dom_lambda{'T} -> BTerm }


define dom: dom{'T} <--> Var + dom_app{'T;'T} + dom_lambda{'T}

define mk: mk <-->
   lambda{d.
    decide{'d;
      (* var v *)  v.'v;
      orelse.decide{'orelse;
      (* app a *) a.mk_app 'a;
      (* lam l *) l.mk_lambda 'l}}}

interactive dom_wf  {| intro[] |}:
   sequent { <H> >- "type"{'T} } -->
   sequent { <H> >- "type"{dom{'T}} }

interactive mk_wf  {| intro[] |}:
   sequent { <H> >- "type"{'T} } -->
   sequent { <H> >- mk in dom{'T} -> BTerm }

interactive dom_monotone  {| intro[] |}:
   sequent { <H> >- 'S subtype 'T } -->
   sequent { <H> >- dom{'S} subtype dom{'T} }

define dest_lambda: dest_lambda{'bt; body.'match_case['body]; 'orelse} <-->
   if is_same_op{lambda_term;'bt} then
       list_ind{subterms{'bt}; it; h,t,"_". 'match_case['h]}
   else
      'orelse

define dest_app: dest_app{'bt; f,a.'match_case['f;'a]; 'orelse} <-->
   if is_same_op{app_term;'bt} then
      list_ind{subterms{'bt}; it; h1,t,"_".
         list_ind{'t;        it; h2,t,"_". 'match_case['h1;'h2]}}
   else
      'orelse

interactive_rw dest_app_reduce {| reduce |}:
   dest_app{mk_app ('t,'s); x,y.'a['x;'y]; 'b} <--> 'a['t;'s]

interactive_rw dest_lambda_reduce {| reduce |}:
   dest_lambda{mk_lambda 't; x.'a['x]; 'b} <--> 'a['t]

interactive_rw dest_app_reduce2 {| reduce |}:
   dest_lambda{mk_app ('t,'s); x.'a['x]; 'b} <--> 'b

interactive_rw app_is_not_var {| reduce |}:
   't in dom_app{BTerm;BTerm} -->
   is_var_bterm{mk_app 't} <--> bfalse

interactive_rw lam_is_not_var {| reduce |}:
   't in dom_lambda{BTerm} -->
   is_var_bterm{mk_lambda 't} <--> bfalse

define dest: dest <-->
   lambda{t.
      if is_var_bterm{'t}
        then inl{ 't }
        else inr{
            dest_lambda {'t ;  a. inl{'a};
            dest_app {'t; a,b. inr{('a,'b)};
            it }}}}

interactive mk_reverse {| intro[] |} :
   sequent { <H> >- 'T subtype BTerm } -->
   sequent { <H> >- dest in RReverse{mk; dom{'T}; BTerm} }


define lambdaTerm: LambdaTerm <--> srec{X. Img{mk; dom{'X}; BTerm}}

interactive lambda_term_induction  {| elim[] |} 'H:
   sequent { <H>; <J>; v:Var >- 'P[ 'v ] } -->
   sequent { <H>; <J>; t: LambdaTerm; s:LambdaTerm; var_arity{'t} = var_arity{'s} in nat;
                            'P['t]; 'P['s]   >- 'P[ make_bterm{app_term; 't::'s::nil} ] } -->
   sequent { <H>; <J>; t: LambdaTerm; var_arity{'t} >= 1;
                            'P['t] >- 'P[ make_bterm{lambda_term; 't::nil} ] } -->
   sequent { <H>; x: LambdaTerm; <J> >- 'P['x] }

interactive lambda_intro  {| intro[] |} :
   sequent { <H> >- 't in LambdaTerm } -->
   sequent { <H> >- var_arity {'t} >= 1  } -->
   sequent { <H> >- make_bterm{lambda_term; 't::nil} in LambdaTerm }

interactive lambda_intro2  {| intro[] |} :
   sequent { <H> >- bterm{| <K>; x:term >- 't['x] |} in LambdaTerm } -->
   sequent { <H> >- bterm{| <K> >- lambda[@]{x.'t['x]} |} in LambdaTerm }

