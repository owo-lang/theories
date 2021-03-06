(*
 * Lexer for TPTP files.
 *)
{
open Lm_printf
(* open Lm_debug *)

open Tptp_parse
}

rule main = parse
    [' ' '\010' '\013' '\009' '\012'] +
    { main lexbuf }
  | ['A'-'Z' '\192'-'\214' '\216'-'\222' ]
    (['A'-'Z' 'a'-'z' '_' '\192'-'\214' '\216'-'\246' '\248'-'\255'
      '\'' '0'-'9' ]) *
      { Uid (Lexing.lexeme lexbuf) }

  | ['a'-'z']
    (['A'-'Z' 'a'-'z' '_' '\192'-'\214' '\216'-'\246' '\248'-'\255'
      '\'' '0'-'9' ]) *
      { match Lexing.lexeme lexbuf with
           "include" -> Include
         | "input_clause" -> Input_clause
         | name -> Lid name
      }
  | '('
    { LeftParen }
  | ')'
    { RightParen }
  | '['
    { LeftBrack }
  | ']'
    { RightBrack }
  | '\''  [^ '\''] * '\''
    { let s = Lexing.lexeme lexbuf in
	let s' = Bytes.create (String.length s - 2) in
	   Bytes.blit_string s 1 s' 0 (Bytes.length s');
	   String (Bytes.to_string s')
    }
  | "--"
    { Negative }
  | "++"
    { Positive }
  | ','
    { Comma }
  | '.'
    { Dot }
  | '%' [^'\n'] *
    { main lexbuf }
  | eof
      { Eof }
  | _
      { eprintf "Undefined token '%s'%t" (Lexing.lexeme lexbuf) eflush;
	main lexbuf
      }

(*
 *
 *)
