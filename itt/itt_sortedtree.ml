(*!
 * @begin[doc]
 * @module[Itt_sortedtree]
 *
 * This is a theory of sorted binary trees.
 * @end[doc]
 *)

extends Itt_datatree
extends Itt_bintree
extends Itt_relation_str
extends Itt_record
extends Itt_logic

(*! @docoff *)

open Printf
open Mp_debug
open Refiner.Refiner
open Refiner.Refiner.Term
open Refiner.Refiner.TermOp
open Refiner.Refiner.TermMan
open Refiner.Refiner.TermSubst
open Refiner.Refiner.RefineError
open Mp_resource

open Var
open Tactic_type
open Tactic_type.Tacticals
open Base_dtactic
open Tactic_type.Conversionals
open Top_conversionals
open Base_auto_tactic

open Itt_bintree



let dByDefT unfold n = rwh unfold n thenT dT n
let dByRecDefT term unfold n = dByDefT unfold n thenT rwhAll (makeFoldC term unfold)

let soft_elim term unfold = term, (dByDefT unfold)
let soft_intro term unfold = term, wrap_intro (dByDefT unfold 0)
let softrec_elim term unfold = term, (dByRecDefT term unfold)
let softrec_intro term unfold = term, wrap_intro (dByRecDefT term unfold 0)



let reduceByDefC unfold =   unfold thenC reduceTopC
let reduceByRecDefC term unfold = reduceByDefC unfold thenC higherC (makeFoldC term unfold)

let soft_reduce term unfold  = term, (reduceByDefC unfold)
let softrec_reduce term unfold  = term, (reduceByRecDefC term unfold)




(*
 * Show that the file is loading.
 *)
let _ =
   show_loading "Loading Itt_binatatree%t"


(*!
 * @begin[doc]
 * @terms
 * @end[doc]
 *)


define dataNode: DataNode{'D;data.'N['data]} <--> record["data":t]{'D;data.'N['data]}

dform dn_df : except_mode[src] ::   DataNode{'D;data.'N} = `"DataNode{" 'data ":" 'D `". " 'N `"}"


define sortedTree: SortedTree {'O;data.'A['data]} <-->
                     BinTree{ DataNode{.'O^car; data.'A['data]} ; self.
                                        (all x: set_from_tree{.^left; .'O^car}.  less{'O; 'x; (^data)}) &
                                        (all y: set_from_tree{.^right; .'O^car}. less{'O; (^data); 'y})
                            }

dform dn_df : except_mode[src] ::   SortedTree{'O;data.'A} = `"SortedTree{" 'data ":" ('O^car) `". " 'A `"}"

let resource elim += [ softrec_elim <<SortedTree{'O; data.'A['data]}>> sortedTree;
                       soft_elim  <<DataNode{'D;data.'N['data]}>> dataNode
                     ]

let resource intro += [ <<tree{'nd} in SortedTree{'O; data.'A['data]}>>,  wrap_intro (dByRecDefT <<SortedTree{'O; data.'A['data]}>> sortedTree 0);
                       soft_intro  <<'t in DataNode{'D;data.'N['data]}>> (higherC dataNode)
                     ]


interactive sortedtree_wf {| intro[] |} univ[i:l] :
   sequent[squash] { 'H >- 'O in order[i:l] } -->
   sequent[squash] { 'H; d:'O^car >- "type"{'A['d]}  } -->
   sequent['ext]   { 'H >- "type"{SortedTree{'O; d.'A['d]}} }

interactive emptytree_is_sorted {| intro[] |} univ[i:l] :
   sequent[squash] { 'H >- 'O in order[i:l] } -->
   sequent[squash] { 'H; d:'O^car >- "type"{'A['d]}  } -->
   sequent['ext]   { 'H >- emptytree in SortedTree{'O; d.'A['d]} }


interactive sortedtree_subtype {| intro[] |}  univ[i:l]:
   sequent[squash] { 'H >- 'O in order[i:l] } -->
   sequent['ext]   { 'H >- SortedTree{'O; d.'A['d]}  subtype  DataTree{.'O^car} }


(* find an element a in the tree, return a subtree with the root a if find one, or empty tree otherwise *)
define find: find{'a; 't; 'O} <-->
      tree_ind{'t;
        (* if t=empty *)       .emptytree;
        (* if t=tree{self} *)  L,R,self. compare{'O;'a;.^data;
                                (*if a<data *) 'L;
                                (*if a=data *) 'self;
                                (*if a>data *) 'R}}

interactive find_wf {| intro[] |}  univ[i:l]:
   sequent[squash] { 'H >- 'O in order[i:l] } -->
   sequent[squash] { 'H >- 'a in 'O^car } -->
   sequent[squash] { 'H >- 't in SortedTree{'O; d.'A['d]} } -->
   sequent[squash] { 'H; d:'O^car >- "type"{'A['d]}  } -->
   sequent['ext]   { 'H >- find{'a; 't; 'O} in  SortedTree{'O; d.'A['d]} }

(* interactive find_correct  univ[i:l]: ????*)

(* define is_in_tree: is_in_tree{'a; 't; 'O} <--> tree_ind{find{'a; 't; 'O}; bfalse; L,R,s.btrue}
*)

define is_in_tree: is_in_tree{'a; 't; 'O} <-->
      tree_ind{'t;
        (* if t=empty *)       .bfalse;
        (* if t=tree{self} *)  L,R,self. compare{'O;'a;.^data;
                                (*if a<data *) 'L;
                                (*if a=data *) btrue;
                                (*if a>data *) 'R}}

dform is_in_tree_df : except_mode[src] ::  in_tree{'a;'t; 'O} = tt["is_it_tree("]  'a tt["; "] 't  tt["; "] 'O  tt[")"]

let resource reduce += [softrec_reduce  <<is_in_tree{'a; 't; 'O}>> is_in_tree]



interactive is_in_tree_wf {| intro[] |}  univ[i:l]:
   sequent[squash] { 'H >- 'O in order[i:l] } -->
   sequent[squash] { 'H >- 'a in 'O^car } -->
   sequent[squash] { 'H >- 't in SortedTree{'O; d.top} }  -->
   sequent['ext]   { 'H >- is_in_tree {'a; 't; 'O} in bool }

interactive is_in_tree_correct  univ[i:l]:
   sequent[squash] { 'H >- 'O in order[i:l] } -->
   sequent[squash] { 'H >- 'a in 'O^car } -->
   sequent[squash] { 'H >- 't in SortedTree{'O; d.top} } -->
   sequent['ext]   { 'H >- iff{"assert"{is_in_tree {'a; 't; 'O}};  in_tree {'a; 't; .'O^car}} }



define insert: insert{'nd; 't; 'O} <-->
      tree_ind{'t;
        (* if t=empty *)       tree{.(('nd^left:=emptytree) ^right:=emptytree)};
        (* if t=tree{self} *)  L,R,self. compare{'O;.'nd^data;.^data;
                                (*if a<data *) .^left:='L;
                                (*if a=data *) tree{.(('nd^left:=^left) ^right:=^right)};
                                (*if a>data *) .^right:='R}}

dform is_in_tree_df : except_mode[src] ::  insert{'a;'t; 'O} = tt["insert("]  'a tt["; "] 't  tt["; "] 'O  tt[")"]

let resource reduce += [softrec_reduce  <<insert{'a; 't; 'O}>> insert]

interactive insert_wf {| intro[] |}  univ[i:l]:
   sequent[squash] { 'H >- 'O in order[i:l] } -->
   sequent[squash] { 'H; d:'O^car >- "type"{'A['d]}  } -->
   sequent[squash] { 'H >- 'nd in  DataNode{.'O^car;data.'A['data]}  } -->
   sequent[squash] { 'H >- 't in SortedTree{'O; d.'A['d]} } -->
   sequent['ext]   { 'H >- insert{'nd;'t;'O} in SortedTree{'O; d.'A['d]}  }



(*! @docoff *)








