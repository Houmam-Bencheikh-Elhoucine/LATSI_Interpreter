open Token;;
open Syntax;;
open Lexer;;

(*Environement du programme*)
let code = ref []
and variables = Interpreter.create_variables ()
and pile_appel = ref []
and ch = open_in  (Sys.argv.(1)) in

match (Parser.programme Lexer.get_token (Lexing.from_channel ch)) with
  |PROGRAMME(l) -> code := l;close_in ch;(*List.iter (fun x -> print_ligne x) l;*)

Interpreter.execute_code !code variables pile_appel;