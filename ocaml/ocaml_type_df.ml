(*
 * Display forms for types.
 *)

include Ocaml
include Ocaml_base_df

(*
 * Projection.
 *)
dform parens :: "prec"[prec_proj] :: type_proj{'t1; 't2} =
   slot{'t1} "." slot{'t2}

(*
 * "As" type.
 *)
dform parens :: "prec"[prec_as] :: type_as{'t1; 't2} =
   slot{'t1} space "as" space slot{'t2}

(*
 * Wildcard type.
 *)
dform type_wildcard = "_"

(*
 * Application.
 *)
dform parens :: "prec"[prec_apply] :: type_apply{'t1; 't2} =
   slot{'t1} space slot{'t2}

(*
 * Function type.
 *)
dform parens :: "prec"[prec_arrow] :: type_fun{'t1; 't2} =
   slot{'t1} space arrow space slot{'t2}

(*
 * Class identifier.
 *)
dform parens :: "prec"[prec_not] :: type_class_id{'t1} =
   "#" space slot{'t1}

(*
 * Identifiers.
 *)
dform type_lid[$v:v] = slot[$v:v]
dform type_uid[$v:v] = slot[$v:v]

(*
 * Type parameter.
 *)
dform type_param[$s:s] = `"'" slot[$s:s]

(*
 * Type equivalence.
 *)
dform parens :: "prec"[prec_equal] :: type_equal{'t1; 't2} =
   slot{'t1} space "==" space slot{'t2}

(*
 * Record type.
 * I'm not sure what the boolean is for.
 *)
dform type_record{'sbtl} =
   "{" szone pushm slot{type_record; 'sbtl} popm ezone "}"

dform slot{type_record; cons{'t1; 'tl}} =
   slot{type_record; 't1; 'tl}
      
dform slot{type_record; 't1; nil} =
   slot{'t1}

dform slot{type_record; 't1; cons{'t2; 'tl}} =
   slot{'t1} ";" sbreak slot{type_record; 't2; 'tl}
         
type_record_elem[$s:s; $b:s]{'t} =
   slot[$s:s] space ":" space slot{'t}

(*
 * Product types.
 *)
dform parens :: "prec"[prec_star] :: type_proc{'tl} =
   szone pushm slot{type_prod; 'tl} popm ezone

dform slot{type_prod; nil} =
   "()"

dform slot{type_prod; cons{'t1; 'tl}} =
   slot{type_prod; 't1; 'tl}

dform slot{type_prod; 't1; cons{'t2; 'tl}} =
   slot{'t1} space "*" space slot{type_prod; 't2; 'tl}

dform slot{type_prod; 't1; nil} =
   slot{'t1}

(*
 * $Log$
 * Revision 1.1  1998/02/13 16:02:26  jyh
 * Partially implemented semantics for caml.
 *
 *
 * -*-
 * Local Variables:
 * Caml-master: "refiner"
 * End:
 * -*-
 *)
