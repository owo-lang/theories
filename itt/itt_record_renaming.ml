doc <:doc<
   @begin[doc]
   @module[Itt_record_renaming]

   This theory defines the function for renaming record fields.
   @end[doc]
>>

doc <:doc< @doc{@parents} >>

extends Itt_record

doc <:doc< @docoff >>

open Tactic_type.Tacticals
open Dtactic
open Auto_tactic
open Top_conversionals
open Itt_record_label

doc <:doc<
   @begin[doc]
   @modsection{Definition}

   If we have a record $r$ then  <<rename[a:t, b:t]{'r}>> is the same record
   where fields with the names <<label[a:t]>> and <<label[b:t]>> are interchanged.
   @end[doc]
>>

define rename: rename[a:t, b:t]{'r} <--> rcrd[a:t]{ field[b:t]{'r}; rcrd[b:t]{ field[a:t]{'r}; 'r} }

doc <:doc< @docoff>>

declare over{'a;'b}

dform over_df1 : except_mode[src] :: except_mode[tex] :: over{'a;'b} =
   slot{'a}  `"/" slot{'b}

dform over_df2 : mode[tex] :: over{'a;'b} =
   izone `"{" ezone slot{'a}   izone `"\\over" ezone slot{'b}  izone `"}" ezone

dform rename_df : except_mode[src] ::  rename[a:t, b:t]{'r} = slot{'r} `"[" over{label[a:t]; label[b:t]} `"]"

doc <:doc<
   @begin[doc]
     For example, <<rename[ "x":t, "y":t]{.{x=1;y=2;z=3}} ~ {y=1;x=2;z=3}>>.
     In general the following reduction rules describe how renaming works on records.
   @end[doc]
>>

interactive_rw rename_rcrd_reduce1 :
   rename[a:t, b:t]{rcrd[a:t]{'x;'r}} <--> rcrd[b:t]{'x;rename[a:t, b:t]{'r}}

interactive_rw rename_rcrd_reduce2 :
   rename[a:t, b:t]{rcrd[b:t]{'x;'r}} <--> rcrd[a:t]{'x;rename[a:t, b:t]{'r}}

interactive_rw rename_rcrd_reduce3 :
   (not{.label[a:t] = label[c:t] in label}) -->
   (not{.label[b:t] = label[c:t] in label}) -->
   rename[a:t, b:t]{rcrd[c:t]{'x;'r}} <--> rcrd[c:t]{'x;rename[a:t, b:t]{'r}}

interactive_rw rename_empty_rcrd {| reduce |}:
   rename[a:t, b:t]{ rcrd } <--> rcrd

doc <:doc<
   @begin[doc]
     These reductions with constant labels are in the @hrefresource[reduce_resource] resource.
     Thus, the @hrefconv[reduceC] does such reduction whenever <<label[a:t]>>,  <<label[b:t]>>, and  <<label[c:t]>> are concrete labels.
   @end[doc]
   @docoff
>>

interactive_rw rename_rcrd_reduce :
   rename[a:t, b:t]{rcrd[c:t]{'x;'r}} <-->
      eq_label[b:t,c:t]{   rcrd[a:t]{'x;rename[a:t, b:t]{'r}};  (* if b=c *)
        eq_label[a:t,c:t]{   rcrd[b:t]{'x;rename[a:t, b:t]{'r}};  (* else if a=c *)
            rcrd[c:t]{'x;rename[a:t, b:t]{'r}} }}                    (* else *)


let rename_rcrd_reduceC = rename_rcrd_reduce  thenC reduce_eq_label thenC tryC reduce_eq_label

(* BUG: rename_rcrd_reduceC does not suppose to work when labels are not constants. However it is not always a case *)

let resource reduce +=
   << rename[a:t, b:t]{rcrd[c:t]{'x;'r}} >>, rename_rcrd_reduceC



doc <:doc<
   @begin[doc]
     @modsection{Properies}
     The main properties of the renaming are the following reductions:
   @end[doc]
>>


interactive_rw rename_rw1 :
   field[a:t]{rename[a:t, b:t]{'r}} <--> field[b:t]{'r}

interactive_rw rename_rw2 :
   field[b:t]{rename[a:t, b:t]{'r}} <--> field[a:t]{'r}

interactive_rw rename_rw3:
   (not{.label[a:t] = label[c:t] in label}) -->
   (not{.label[b:t] = label[c:t] in label}) -->
   field[c:t]{rename[a:t, b:t]{'r}} <--> field[c:t]{'r}

doc <:doc<
   @begin[doc]
     These reductions with constant labels are also added to the @hrefresource[reduce_resource] resource.
   @end[doc]
   @docoff
>>

interactive_rw rename_rw:
   field[c:t]{rename[a:t, b:t]{'r}} <-->
      eq_label[a:t,c:t]{  field[b:t]{'r};  (* if a=c *)
        eq_label[b:t,c:t]{  field[a:t]{'r};  (* else if b=c *)
           field[c:t]{'r} }}                    (* else *)

let rename_reduceC = rename_rw thenC reduce_eq_label thenC tryC reduce_eq_label

(* BUG:  rename_reduceC does not suppose to work when labels are not constants. However it is not always a case, e.g.,  field["c":t]{rename["a":t, b:t]{'r}}  *)

let resource reduce +=
   << field[c:t]{rename[a:t, b:t]{'r}} >>, rename_reduceC

doc <:doc<
   @begin[doc]
     The trivial renaming is identity:
   @end[doc]
>>

interactive_rw rename_id {| reduce |}:
   ('r in recordTop ) -->
   rename[a:t, a:t]{'r} <--> 'r

doc <:doc<
   @begin[doc]
   Two opposite renamings could be canceled:
   @end[doc]
>>


interactive_rw rename_cancel1 {| reduce |}:
   ('r in recordTop ) -->
   rename[a:t, b:t]{rename[b:t, a:t]{'r}} <-->   'r




doc <:doc<
   @begin[doc]
   Our definition of the renaming is symmetrical. Therefore,
   @end[doc]
>>

interactive_rw rename_sym :
   rename[a:t, b:t]{'r} <--> rename[b:t, a:t]{'r}

doc <:doc<
   @begin[doc]
   @begin[small]
   Usually we will consider this property as side effect and will not use it.
   But sometimes this property could be useful. See for example Section @refsection[Inverse_order].
   @end[small]
   @end[doc]
   @docoff
>>


interactive_rw rename_cancel2 {| reduce |}:
   ('r in recordTop ) -->
   rename[a:t, b:t]{rename[a:t, b:t]{'r}} <-->   'r

doc <:doc<
   @begin[doc]
   The order of renamings does not matter as soon as the renamed fields are different:
   @end[doc]
>>

interactive_rw rename_exchange :
   (not{.label[a:t] = label[c:t] in label}) -->
   (not{.label[b:t] = label[c:t] in label}) -->
   (not{.label[a:t] = label[d:t] in label}) -->
   (not{.label[b:t] = label[d:t] in label}) -->
   rename[a:t, b:t]{rename[c:t, d:t]{'r}} <-->
   rename[c:t, d:t]{rename[a:t, b:t]{'r}}

doc <:doc<
   @begin[doc]
   @modsection{Tactics}
   @modsubsection{Reductions}
     Most of the above reductions are added to the @hrefresource[reduce_resource] resource.
     Thus @hrefconv[reduceC] reduces the following terms:

      <<field[c:t]{rename[a:t, b:t]{'r}} >> whenever  <<label[a:t]>>,  <<label[b:t]>>, and  <<label[c:t]>> are constant labels;

      <<rename[a:t, b:t]{rcrd[c:t]{'x;'r}} >> whenever  <<label[a:t]>>,  <<label[b:t]>>, and  <<label[c:t]>> are constant labels;

      << rename[a:t, b:t]{rename[b:t, a:t]{'r}} >>

      << rename[a:t, a:t]{'r} >>

   @modsubsection{Renaming}
     The main tools for renaming a field name are the following tactics and conversions.
     The conversion @conv[renameFieldC] <<rename[a:t,b:t]{'r}>>  do the following rewrites:

           <<field[a:t]{'r}>> $@longrightarrow$ <<field[b:t]{rename[a:t,b:t]{'r}}>>

           <<field[c:t]{'r}>> $@longrightarrow$ <<field[c:t]{rename[a:t,b:t]{'r}}>> if $c @neq a,b$

     (<<label[a:t]>>,  <<label[b:t]>>, <<label[c:t]>> should be constant labels).

     @begin[small]
           This conversion works as follows.
           First, it replaces $r$ by <<rename[b:t,a:t]{ rename[a:t,b:t]{'r} }>> in the immediate subterms of the term and then do @em{exactly one} reduction on the term.
           (It fails if it can not do the reduction).
     @end[small]
   @end[doc]
   @docoff
>>


interactive_rw rename_fields rename[a:t,b:t]{'r}:  'r <-->  rename[b:t,a:t]{ rename[a:t,b:t]{'r} }


let renameFieldC term = allSubThenC (rename_fields term) (reduceTopC)

doc <:doc<
   @begin[doc]
     The tactic @tactic[renameFieldT]  @tt["= rwhAll  renameFieldC"] applies the above conversion to all subterms of the goal sequence.
   @end[doc]
>>

let renameFieldT term = rwhAll  (renameFieldC term)



(******************* additive **********************)

doc <:doc<
   @begin[doc]
   @modsection{Renaming of Additive Operations}
   One of the application of the renaming is in the theory of algebraic structures such as @hrefmodule[groups] and @hrefmodule[rings].
   Suppose we have a field. We want to consider it as a multiplicative group as well as an additive group.
   We need the following renamings that renames additive operations to their multiplicative analogs and visa versa:
   @end[doc]
>>

define unfold_rename_add_mul: rename_add_mul{'add} <-->
   rename["+":t,"*":t]{
   rename["0":t,"1":t]{
   rename["neg":t,"inv":t]{ 'add }}}

define unfold_rename_mul_add: rename_mul_add{'mul} <-->
   rename["inv":t,"neg":t]{
   rename["1":t,"0":t]{
   rename["*":t,"+":t]{ 'mul }}}

dform rename_mul_add_df : except_mode[src] ::  rename_mul_add{'mul} = rename["<mul>":t, "<add>" :t]{'mul}
dform rename_add_mul_df : except_mode[src] :: rename_add_mul{'add} = rename["<add>":t, "<mul>" :t]{'add}

doc <:doc<
   @begin[doc]
     @begin[small]
     Of course since the renaming is symmetrical (rule @hrefrule[rename_sym]) the above definitions are essentially the same.
     But the theory is intuitively clearer if we forget about symmetry and consider <<rename[a:t,b:t]{'r}>> as replacement <<label[a:t]>> by <<label[b:t]>>.
     @end[small]

     In the @hrefmodule[group] theory we define the standard group type with the @em{multiplicative operations}: <<label["*":t]>>,  <<label["1":t]>>,  <<label["inv":t]>>.
     Formally additive groups are not groups according to this definition. If we want to consider it as a @em{standard} group, then we need to do renaming.
     We introduce an operation <<as_additive{'r}>> that consider structure $r$ as an additive structure (such as group).
     This operation is defined just as renaming <<rename_add_mul{'r}>>:
   @end[doc]
>>

define unfold_as_additive: as_additive{'r} <-->  rename_add_mul{'r}

dform as_additive_df : except_mode[src] :: parens :: as_additive{'add} = slot{'add} bf[" as additive"]

doc <:doc<
   @begin[doc]
     but this operation has a different meaning behind it and has different reduction rules in the @hrefresource[reduce_resource] resource (see the next section).

     Example. If $r$ is a ring then <<as_additive{'r}>> is a group (the additive group of the ring $r$).
   @end[doc]
>>


doc <:doc<
   @begin[doc]
   @modsubsection{Reductions}
     The following reductions  immediately follow from the definitions:
   @end[doc]
>>

interactive_rw mul_add_cancel {| reduce |}:  rename_mul_add{ rename_add_mul{'add} } <--> 'add

interactive_rw add_mul_cancel {| reduce |}:  rename_add_mul{ rename_mul_add{ 'mul }} <--> 'mul

doc <:doc<
   @begin[doc]
     This reductions are added to the @hrefresource[reduce_resource] resource, as well as the reductions of the terms of the form
    <<field[c:t]{rename_mul_add{'r}}>>, <<field[c:t]{rename_add_mul{'r}}>>.
   @end[doc]
>>

let resource reduce +=
  [ << field[c:t]{rename_mul_add{'r}} >>, (addrC [0] unfold_rename_mul_add thenC repeatForC 3 rename_reduceC);
    << field[c:t]{rename_add_mul{'r}} >>, (addrC [0] unfold_rename_add_mul thenC repeatForC 3 rename_reduceC);
    << rename_add_mul{rcrd[c:t]{'a;'r}} >>, unfold_rename_add_mul;
    << rename_mul_add{rcrd[c:t]{'a;'r}} >>, unfold_rename_mul_add
  ]

doc <:doc<
   @begin[doc]
    We do not include reduction for  <<field[c:t]{as_additive{'r}}>> because we do not want to reduce it immediately.
    (To reduce such term use the @hrefconv[unfoldAdditiveC] $r$ conversion).
   @end[doc]
   @docoff
>>


interactive_rw additive_reduce (* {| reduce |} *):
   as_additive{  rename_mul_add{ 'mul }} <--> 'mul


doc <:doc<
   @begin[doc]
   @modsubsection{Tactics}

     The following tools are used to apply theorems for multiplicative structures (e.g. groups) to additive ones.

     The conversion @conv[foldAdditiveC] <<'r>>  consider $r$ as an additive structure.
     For example, it replaces <<'r^"+">> by  <<as_additive{'r}^"*">> and <<'r^car>> by  <<as_additive{'r}^car>>.

     @begin[small]
           This conversion works similar to @hrefconv[renameFieldC].
           It replaces $r$ by <<rename_mul_add{ as_additive{'r} }>> in the immediate subterms and then do @em{exactly one} reduction.
     @end[small]

     The conversion @conv[unfoldAdditiveC] <<'r>>  is opposite to  @conv[foldAdditiveC] <<'r>>.
     For example, it replaces  <<as_additive{'r}^"*">> by  <<'r^"+">> .

     The @tactic[foldAdditiveT] $r$ and  @tactic[unfoldAdditiveT] $r$ tactics apply the above conversions to all subterms of the goal sequent (using @hreftactic[rwhAll]).

     The @tactic[useAdditiveWithT] $r$ $tac$ tactic applies @tt[foldAdditiveT] then $tac$ and then  @tt[unfoldAdditiveT].

     The @tactic[useAdditiveWithAutoT] $r$ $tac$ tactic applies @tt[useAdditiveWithT] $r$ @tt[autoT] and then runs @tt[autoT] again.
   @end[doc]
   @docoff
>>



interactive_rw use_as_additive 'add:  'add <-->  rename_mul_add{ as_additive{'add} }


let foldAdditiveC term = allSubThenC (use_as_additive term) (reduceTopC)
let unfoldAdditiveC term =allSubThenC unfold_as_additive (reduceTopC)

let foldAdditiveT term  = rwhAll (foldAdditiveC term)
let unfoldAdditiveT term  = rwhAll (unfoldAdditiveC term)

let useAdditiveWithT term tac  = foldAdditiveT term thenT tac thenT unfoldAdditiveT term

let useAdditiveWithAutoT term  = useAdditiveWithT term autoT thenT autoT


doc <:doc<
   @begin[doc]
   @modsubsection{Examples}
   Let $F$ be a filed. Suppose we want to prove that <<'a +['F] 'F^"0" = 'a in 'F^car>>.
   If we run tactic  @tt[foldAdditiveT] <<'F>>


   $$
   @rulebox{foldAdditiveT <<'F>>; ;
     <<sequent(nil){ <H> >- 'a +['F] 'F^"0" = 'a in 'F^car }>>;
     <<sequent(nil){ <H> >- 'a *[as_additive{'F}] as_additive{'F}^"1" = 'a in as_additive{'F}^car }>>}
   $$

   Assuming that @hrefresource[auto_resource] knows the corresponding rule for the groups and
   @hrefresource[typeinf_resource] knows that <<as_additive{'F}>> is a group, we can apply the @tt[autoT] tactic:
     <<sequent(nil){ <H> >- 'a in as_additive{'F}^car }>>

      Then
   $$
   @rulebox{unfoldAdditiveT <<'F>>; ;
     <<sequent(nil){ <H> >- 'a in as_additive{'F}^car }>>;
     <<sequent(nil){ <H> >- 'a in 'F^car }>>}
   $$

   The @hreftactic[useAdditiveWithT] tactic allows us to use the three above steps in one.
   And the @hreftactic[useAdditiveWithAutoT] tactic also use @tt[autoT] on the final goal.
   @end[doc]
>>


doc <:doc<
   @begin[doc]
   Now consider another example.
   If we have a group $G$, an element of this group $a$ and  a  number $n$ then we can define the $n$-th power of $a$ in $G$: <<group_power{'G; 'a; 'n}>>
   @end[doc]
>>

declare group_power{'g; 'a; 'n}

dform group_power_df : except_mode[src] :: group_power{'G; 'a; 'n} =
   slot{'a} sup{'n} sub{'G}

doc <:doc<
   @begin[doc]
      Then we can define the analog of this operation for additive groups:
   @end[doc]
>>

define group_mult: group_mult{'g; 'a; 'n} <--> group_power{as_additive{'g}; 'a; 'n}

dform group_mult_df : except_mode[src] :: group_mult{'G; 'a; 'n} =
   slot{'n} times sub{'G} slot{'a}

doc <:doc<
   @begin[doc]
         We also need two reductions to be added to @hrefresource[reduce_resource]:
   @end[doc]
>>

interactive_rw mult_is_power {| reduce |}:
   group_mult{rename_mul_add{ 'g }; 'a; 'n} <-->   group_power{'g; 'a; 'n}

interactive_rw power_is_mult {| reduce |}:
   group_power{rename_add_mul{ 'g }; 'a; 'n} <-->   group_mult{'g; 'a; 'n}

doc <:doc<
   @begin[doc]
         Then @hrefconv[foldAdditiveC] and @hrefconv[unfoldAdditiveC] would replace
         <<group_mult{'R;'a;'n}>> by <<group_power{as_additive{'R}; 'a; 'n}>>
        and visa versa:
   $$
   @rulebox{foldAdditiveT <<'R>>; ;
     <<sequent(nil){ <H> >- group_mult{'R; 'a; 0} = 'R^"0" in 'R^car}>>;
     <<sequent(nil){ <H> >- group_power{as_additive{'R}; 'a; 0} = as_additive{'R}^"1" in as_additive{'R}^car}>>}
   $$

   $$
   @rulebox{unfoldAdditiveT <<'R>>; ;
     <<sequent(nil){ <H> >- group_power{as_additive{'R}; 'a; 0} = as_additive{'R}^"1" in as_additive{'R}^car}>>;
     <<sequent(nil){ <H> >- group_mult{'R; 'a; 0} = 'R^"0" in 'R^car}>>}
   $$

   @end[doc]
   @docoff
>>


