extends Kat_terms

open Top_conversionals
open Base_select
open Dtactic

prim _leqintro :
     [wf] sequent{ <H> >- 'y in kleene} -->
     [wf] sequent{ <H> >- 'x in kleene} -->
     sequent{ <H> >- ('x + 'y) ~ 'y } -->
     sequent{ <H> >- 'x <= 'y } = it

prim _leqelim :
     [wf] sequent{ <H> >- 'y in kleene} -->
     [wf] sequent{ <H> >- 'x in kleene} -->
     sequent{ <H> >- 'x <= 'y } -->
     sequent{ <H> >- ('x + 'y) ~ 'y } = it

interactive_rw _leqelim_l :
     ('y in kleene) -->
     ('x in kleene) -->
     ('x <= 'y) -->
     ('x + 'y) <--> 'y

interactive_rw _leqelim_r 'x :
     ('y in kleene) -->
     ('x in kleene) -->
     ('x <= 'y) -->
     'y <--> ('x + 'y)

prim commut_plus {| intro[] |}:
     [wf] sequent{ <H> >- 'y in kleene} -->
     [wf] sequent{ <H> >- 'x in kleene} -->
     sequent{ <H> >- ('x + 'y) ~ ('y + 'x) } = it

interactive_rw commut_plus_l :
     ('y in kleene) -->
     ('x in kleene) -->
     ('x + 'y) <--> ('y + 'x)

interactive_rw commut_plus_r :
     ('y in kleene) -->
     ('x in kleene) -->
     ('y + 'x) <--> ('x + 'y)

prim id_plusr {| intro[] |}:
     [wf] sequent{ <H> >- 'x in kleene} -->
     sequent{ <H> >- ('x + 0) ~ 'x } = it

interactive_rw id_plusr_l :
     ('x in kleene) -->
     ('x + 0) <--> 'x

interactive_rw id_plusr_r :
     ('x in kleene) -->
     'x <--> ('x + 0)

prim idemp_plus {| intro[] |}:
     [wf] sequent{ <H> >- 'x in kleene} -->
     sequent{ <H> >- ('x + 'x) ~ 'x } = it

interactive_rw idemp_plus_l :
     ('x in kleene) -->
     ('x + 'x) <--> 'x

interactive_rw idemp_plus_r :
     ('x in kleene) -->
     'x <--> ('x + 'x)

prim id_timesl {| intro[] |}:
     [wf] sequent{ <H> >- 'x in kleene} -->
     sequent{ <H> >- (1 * 'x) ~ 'x } = it

interactive_rw id_timesl_l :
     ('x in kleene) -->
     (1 * 'x) <--> 'x

interactive_rw id_timesl_r :
     ('x in kleene) -->
     'x <--> (1 * 'x)

prim id_timesr {| intro[] |}:
     [wf] sequent{ <H> >- 'x in kleene} -->
     sequent{ <H> >- ('x * 1) ~ 'x } = it

interactive_rw id_timesr_l :
     ('x in kleene) -->
     ('x * 1) <--> 'x

interactive_rw id_timesr_r :
     ('x in kleene) -->
     'x <--> ('x * 1)

prim annihl {| intro[] |}:
     [wf] sequent{ <H> >- 'x in kleene} -->
     sequent{ <H> >- (0 * 'x) ~ 0 } = it

interactive_rw annihl_l :
     ('x in kleene) -->
     (0 * 'x) <--> 0

interactive_rw annihl_r 'x :
     ('x in kleene) -->
     0 <--> (0 * 'x)

prim annihr {| intro[] |}:
     [wf] sequent{ <H> >- 'x in kleene} -->
     sequent{ <H> >- ('x * 0) ~ 0 } = it

interactive_rw annihr_l :
     ('x in kleene) -->
     ('x * 0) <--> 0

interactive_rw annihr_r 'x :
     ('x in kleene) -->
     0 <--> ('x * 0)

prim distrl {| intro[] |}:
     [wf] sequent{ <H> >- 'z in kleene} -->
     [wf] sequent{ <H> >- 'y in kleene} -->
     [wf] sequent{ <H> >- 'x in kleene} -->
     sequent{ <H> >- ('x * ('y + 'z)) ~ (('x * 'y) + ('x * 'z)) } = it

interactive_rw distrl_l :
     ('z in kleene) -->
     ('y in kleene) -->
     ('x in kleene) -->
     ('x * ('y + 'z)) <--> (('x * 'y) + ('x * 'z))

interactive_rw distrl_r :
     ('z in kleene) -->
     ('y in kleene) -->
     ('x in kleene) -->
     (('x * 'y) + ('x * 'z)) <--> ('x * ('y + 'z))

prim distrr {| intro[] |}:
     [wf] sequent{ <H> >- 'z in kleene} -->
     [wf] sequent{ <H> >- 'y in kleene} -->
     [wf] sequent{ <H> >- 'x in kleene} -->
     sequent{ <H> >- (('x + 'y) * 'z) ~ (('x * 'z) + ('y * 'z)) } = it

interactive_rw distrr_l :
     ('z in kleene) -->
     ('y in kleene) -->
     ('x in kleene) -->
     (('x + 'y) * 'z) <--> (('x * 'z) + ('y * 'z))

interactive_rw distrr_r :
     ('z in kleene) -->
     ('y in kleene) -->
     ('x in kleene) -->
     (('x * 'z) + ('y * 'z)) <--> (('x + 'y) * 'z)

prim unwindl {| intro[] |}:
     [wf] sequent{ <H> >- 'x in kleene} -->
     sequent{ <H> >- (1 + ('x * (star{'x}))) ~ (star{'x}) } = it

interactive_rw unwindl_l :
     ('x in kleene) -->
     (1 + ('x * (star{'x}))) <--> (star{'x})

interactive_rw unwindl_r :
     ('x in kleene) -->
     (star{'x}) <--> (1 + ('x * (star{'x})))

prim unwindr {| intro[] |}:
     [wf] sequent{ <H> >- 'x in kleene} -->
     sequent{ <H> >- (1 + ((star{'x}) * 'x)) ~ (star{'x}) } = it

interactive_rw unwindr_l :
     ('x in kleene) -->
     (1 + ((star{'x}) * 'x)) <--> (star{'x})

interactive_rw unwindr_r :
     ('x in kleene) -->
     (star{'x}) <--> (1 + ((star{'x}) * 'x))

prim _starl :
     [wf] sequent{ <H> >- 'x in kleene} -->
     [wf] sequent{ <H> >- 'y in kleene} -->
     [wf] sequent{ <H> >- 'z in kleene} -->
     sequent{ <H> >- (('z * 'y) + 'x) <= 'z } -->
     sequent{ <H> >- ('x * (star{'y})) <= 'z } = it

prim _starr :
     [wf] sequent{ <H> >- 'y in kleene} -->
     [wf] sequent{ <H> >- 'z in kleene} -->
     [wf] sequent{ <H> >- 'x in kleene} -->
     sequent{ <H> >- (('x * 'z) + 'y) <= 'z } -->
     sequent{ <H> >- ((star{'x}) * 'y) <= 'z } = it
