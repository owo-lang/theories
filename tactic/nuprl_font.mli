(*
 * Characters in the nuprl font.
 *
 * ----------------------------------------------------------------
 *
 * This file is part of MetaPRL, a modular, higher order
 * logical framework that provides a logical programming
 * environment for OCaml and other languages.
 *
 * See the file doc/index.html for information on Nuprl,
 * OCaml, and more information about this system.
 *
 * Copyright (C) 1998 Jason Hickey, Cornell University
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 * Author: Jason Hickey
 * jyh@cs.cornell.edu
 *)

(*
 * Display control.
 *)
declare pagebreak

(*
 * Fonts.
 * Each of these can be used with a string, with a term,
 * or unbalanced.
 *
 * For example, all of these are the same:
 *    bold["["]
 *    bold{"["}
 *    bold_begin "[" bold_end
 *)
declare info[name:s]
declare info_begin
declare info_end
declare keyword[name:s]
declare keyword_begin
declare keyword_end
declare bf[name:s]
declare bf{'t}
declare bf_begin
declare bf_end
declare i[name:s]
declare i{'t}
declare it[name:s]
declare it{'t}
declare it_begin
declare it_end
declare em[s:s]
declare em{'s}
declare em_begin
declare em_end
declare emph{'t}
declare tt[name:s]
declare tt{'t}
declare tt_begin
declare tt_end
declare sub{'t}
declare sub[name:s]
declare sub_begin
declare sub_end
declare sup{'t}
declare sup[name:s]
declare sup_begin
declare sup_end
declare small[name:s]
declare small_begin
declare small_end

(*
 * HTML control.
 *)
declare cd_begin[command:s]
declare cd_end

(*
 * TeX control.
 *)
declare mathBB[name:s]
declare ensuremath[name:s]
declare ensuremath{'t}
declare mathmacro[name:s]

(* Displays *)
declare mathbbA
declare mathbbB
declare mathbbC
declare mathbbD
declare mathbbE
declare mathbbF
declare mathbbG
declare mathbbH
declare mathbbI
declare mathbbJ
declare mathbbK
declare mathbbL
declare mathbbM
declare mathbbN
declare mathbbO
declare mathbbP
declare mathbbQ
declare mathbbR
declare mathbbS
declare mathbbT
declare mathbbU
declare mathbbV
declare mathbbW
declare mathbbX
declare mathbbY
declare mathbbZ

declare shortLeftarrow
declare Leftarrow
declare Middlearrow
declare shortRightarrow
declare Rightarrow
declare Leftrightarrow
declare ulcorner
declare urcorner
declare mid
declare vdash
declare integral
declare cdot
declare downarrow
declare uparrow
declare alpha
declare beta
declare pi
declare lambda
declare gamma
declare delta
declare rho
declare sigma
declare epsilon
declare eta
declare theta
declare iota
declare kappa
declare mu
declare nu
declare omicron
declare tau
declare phi
declare xi
declare omega
declare wedge
declare tneg
declare member
declare plusminus
declare oplus
declare infty
declare partial
declare subset
declare supset
declare cap
declare cup
declare forall
declare "exists"
declare oinfty
declare shortleftrightarrow
declare shortleftarrow
declare shortrightarrow
declare longleftrightarrow
declare longleftarrow
declare longrightarrow
declare neq
declare sim
declare le
declare ge
declare equiv
declare vee
declare perp
declare leftarrow
declare middlearrow
declare rightarrow
declare Sigma
declare Delta
declare Pi
declare times
declare "div"
declare supplus
declare supminus
declare supcirc
declare subseteq
declare supseteq
declare subzero
declare subone
declare subtwo
declare subthree
declare suba
declare subb
declare subc
declare subq
declare subz

declare math_div

(*
 * -*-
 * Local Variables:
 * Caml-master: "prlcomp.run"
 * End:
 * -*-
 *)
