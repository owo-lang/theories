(*
 * Functional Intermediate Representation formalized in MetaPRL.
 * Brian Emre Aydemir, emre@its.caltech.edu
 *
 * Contains test theorems and programs.
 *)

include Mc_theory

(*
 * The term to represent I don't know what should go in a spot,
 * but it doesn't really matter anyways.
 *)
declare darb
dform darb_df : except_mode[src] :: darb = `"Darb"

(*************************************************************************
 * Simple program tests.
 * Should be provable with rw reduceC 0 thenT autoT.
 *************************************************************************)

(* Alloc tests. *)
interactive alloc1 'H :
   sequent ['ext] { 'H >- ref{1} } -->
   sequent ['ext] { 'H >-
      letAlloc{ empty; allocTuple{tyInt; cons{2;nil}}; s1, v.
      letAlloc{ 's1; allocArray{tyInt; cons{3;nil}}; s, e. 'e } } }
interactive alloc2 'H :
   sequent ['ext] { 'H >-
      pair{ 4; cons{ block{0;cons{2;nil}};
               cons{ block{0;cons{3;nil}};
               cons{ block{0;cons{4;nil}};
               cons{ block{0;cons{5;nil}}; nil }}}}} } -->
   sequent ['ext] { 'H >-
      letAlloc{ empty; allocTuple{tyInt; cons{5;nil}}; s1, a1.
      letAlloc{ 's1; allocArray{tyInt; cons{4;nil}}; s2, a2.
      letAlloc{ 's2; allocTuple{tyInt; cons{3;nil}}; s3, a3.
      letAlloc{ 's3; allocArray{tyInt; cons{2;nil}}; s4, a4. 's4 }}}}}

(* Match tests. *)
interactive match1 'H :
   sequent ['ext] { 'H >- 512 } -->
   sequent ['ext] { 'H >- match_int{ empty; 32;
      cons{matchCase{int_set{1;31};s. 2};
      cons{matchCase{int_set{25;35};s. 512};nil}}}}
interactive match2 'H :
   sequent ['ext] { 'H >- 317 } -->
   sequent ['ext] { 'H >- match_block{ empty; block{ 2; nil };
      cons{matchCase{int_set{1;31};s. 317};
      cons{matchCase{int_set{25;35};s. 512};nil}}}}
interactive match3 'H :
   sequent ['ext] { 'H >- match_int{ empty; 3; nil } } -->
   sequent ['ext] { 'H >- match_int{ empty; 3;
      cons{matchCase{true_set;s. 1}; cons{matchCase{false_set;s. 0}; nil}}}}

(* Subscripting tests. *)
interactive sub1 'H :
   sequent ['ext] { 'H >- 1 } -->
   sequent ['ext] { 'H >-
      letAlloc{ empty; allocTuple{tyInt; cons{1; nil}}; s1, v.
         letSubscript{ 's1; 'darb; 'darb; 'v; 0; s, w. 'w } } }
interactive sub2 'H :
   sequent ['ext] { 'H >- 2 } -->
   sequent ['ext] { 'H >-
      letAlloc{ empty; allocTuple{tyInt; cons{1; nil}}; s1, v.
         setSubscript{ 's1; 'darb; 'darb; 'v; 0; 2; s2.
         letSubscript{ 's2; 'darb; 'darb; 'v; 0; s, w. 'w} } } }
interactive sub3 'H :
   sequent ['ext] { 'H >- 6 } -->
   sequent ['ext] { 'H >-
      letAlloc{ empty; allocTuple{tyInt; cons{1; cons{2; cons{3; nil}}}};
         s1, a1.
      letAlloc{ 's1; allocArray{tyInt; cons{4; cons{5; nil}}}; s2, a2.
      letAlloc{ 's2; allocTuple{tyInt; cons{6; nil}}; s3, a3.
      setSubscript{ 's3; 'darb; 'darb; 'a2; 1; 6; s4.
      letSubscript{ 's4; 'darb; 'darb; 'a2; 1; s, v. 'v }}}}}}

(*************************************************************************
 * Complex program tests.
 * Should be provable with rw reduceC 0 thenT autoT.
 *************************************************************************)

interactive complex1 'H :
   sequent ['ext] { 'H >- 128 } -->
   sequent ['ext] { 'H >-
         letAlloc{ empty; allocArray{tyInt; cons{1;cons{2;cons{3;nil}}}};
            s1, a1.
         letAlloc{ 's1; allocTuple{tyInt; cons{4;cons{5;cons{6;nil}}}}; s2, a2.
         letAlloc{ 's2; allocTuple{tyInt; cons{0;cons{9;cons{0;nil}}}}; s3, a3.
         letAlloc{ 's3; allocTuple{tyInt; cons{8;cons{8;cons{8;nil}}}}; s4, a4.
         setSubscript{ 's4; 'darb; 'darb; 'a1; 1; 20; s5.
         setSubscript{ 's5; 'darb; 'darb; 'a2; 0; (-40); s6.
         setSubscript{ 's6; 'darb; 'darb; 'a4; 2; 80; s7.
         letSubscript{ 's7; 'darb; 'darb; 'a1; 1; s8, v1.
         letSubscript{ 's8; 'darb; 'darb; 'a2; 0; s9, v2.
         letSubscript{ 's9; 'darb; 'darb; 'a3; 2; s10, v3.
         letSubscript{ 's10; 'darb; 'darb; 'a4; 2; s11, v4.
         letBinop{ 's11; plusIntOp; tyInt; 'v1; 'v2; s12, e1.
         letBinop{ 's12; mulIntOp; tyInt; 'v3; 'v4; s13, e2.
         letBinop{ 's13; gtIntOp; tyInt; 'e1; 'e2; s14, c.
         match_int{ 's14; 'c;
            cons{ matchCase{true_set; s15. 512};
               cons{ matchCase{false_set; s16. 128}; nil}}}}}}}}}}}}}}}}}}

interactive complex2 'H :
   sequent ['ext] { 'H >- 6 } -->
   sequent ['ext] { 'H >-
      letAlloc{ empty; allocArray{tyInt; cons{0;nil}}; s1, a1.
      setSubscript{ 's1; 'darb; 'darb; 'a1; 0; 1; s2.
      letSubscript{ 's2; 'darb; 'darb; 'a1; 0; s3, v.
      letBinop{ 's3; plusIntOp; tyInt; 'v; 2; s4, e.
      setSubscript{ 's4; 'darb; 'darb; 'a1; 0; 'e; s5.
      letSubscript{ 's5; 'darb; 'darb; 'a1; 0; s6, v2.
      letBinop{ 's6; plusIntOp; tyInt; 'v2; 3; s, e. 'e }}}}}}}}

(*************************************************************************
 * Type checking tests.
 *************************************************************************)

interactive type1 'H :
   sequent ['ext] { 'H >- letUnop{ empty; idOp; tyInt; 1; s, v. 'v} IN tyInt }

interactive type3 'H :
   sequent ['ext] { 'H >-
      letBinop{ empty; remIntOp; tyInt; 7; 4; s, v. 'v } IN tyInt }

interactive type4 'H :
   sequent ['ext] { 'H >- 'a IN tyInt } -->
   sequent ['ext] { 'H >- 'b IN tyInt } -->
   sequent ['ext] { 'H >-
      letBinop{ empty; minusIntOp; tyInt; 'a; 'b; s, v. 'v } IN tyInt }

interactive type6 'H :
   sequent ['ext] { 'H >-
      match_int{ empty; 2;
         cons{matchCase{int_set{2;3};s. 45};
         cons{matchCase{int_set{4;5};s. 56};nil}}} IN tyInt }

interactive type7 'H :
   sequent ['ext] { 'H >-
      match_int{ empty; 5;
         cons{matchCase{int_set{2;3};s. 45};
         cons{matchCase{int_set{4;5};s. 56};nil}}} IN tyInt }

interactive type8 'H :
   sequent ['ext] { 'H >-
      match_block{ empty; block{2; cons{1;cons{2;nil}}};
         cons{matchCase{int_set{2;3};s. 45};
         cons{matchCase{int_set{4;5};s. 56};nil}}} IN tyInt }

interactive type9 'H :
   sequent ['ext] { 'H >-
      letAlloc{ empty; allocTuple{tyInt; cons{1; nil}}; s, v.
         letSubscript{ 's; 'darb; tyInt; 'v; 0; s2, w. 'w } } IN tyInt }

interactive tc1 'H :
   sequent ['ext] { 'H >-
         letAlloc{ empty; allocArray{tyInt; cons{1;cons{2;cons{3;nil}}}};
            s1, a1.
         letAlloc{ 's1; allocTuple{tyInt; cons{4;cons{5;cons{6;nil}}}}; s2, a2.
         letAlloc{ 's2; allocTuple{tyInt; cons{0;cons{9;cons{0;nil}}}}; s3, a3.
         letAlloc{ 's3; allocTuple{tyInt; cons{8;cons{8;cons{8;nil}}}}; s4, a4.
         setSubscript{ 's4; 'darb; tyInt; 'a1; 1; 20; s5.
         setSubscript{ 's5; 'darb; tyInt; 'a2; 0; (-40); s6.
         setSubscript{ 's6; 'darb; tyInt; 'a4; 2; 80; s7.
         letSubscript{ 's7; 'darb; tyInt; 'a1; 1; s8, v1.
         letSubscript{ 's8; 'darb; tyInt; 'a2; 0; s9, v2.
         letSubscript{ 's9; 'darb; tyInt; 'a3; 2; s10, v3.
         letSubscript{ 's10; 'darb; tyInt; 'a4; 2; s11, v4.
         letBinop{ 's11; plusIntOp; tyInt; 'v1; 'v2; s12, e1.
         letBinop{ 's12; mulIntOp; tyInt; 'v3; 'v4; s13, e2.
         letBinop{ 's13; gtIntOp; tyInt; 'e1; 'e2; s14, c.
         match_int{ 's14; 'c;
            cons{ matchCase{true_set; s15. 512};
               cons{ matchCase{false_set; s16. 128}; nil}}}}}}}}}}}}}}}}}
         IN tyInt }

interactive tc2 'H :
   sequent ['ext] { 'H >-
      letAlloc{ empty; allocArray{tyInt; cons{0;nil}}; s1, a1.
      setSubscript{ 's1; darb; tyInt; 'a1; 0; 1; s2.
      letSubscript{ 's2; darb; tyInt; 'a1; 0; s3, v.
      letBinop{ 's3; plusIntOp; tyInt; 'v; 2; s4, e.
      setSubscript{ 's4; darb; tyInt; 'a1; 0; 'e; s5.
      letSubscript{ 's5; darb; tyInt; 'a1; 0; s6, v2.
      letBinop{ 's6; plusIntOp; tyInt; 'v2; 3; s, e. 'e }}}}}}}
      IN tyInt }
