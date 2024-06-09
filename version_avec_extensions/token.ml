type token = 
  (*data*)
  | ENTIER of int
  | CHAINE of string
  (*built-in functions*)
  | IMPRIMER
  | ENTREE
  | NL

  (*keywords*)
  | SI
  | ALORS
  | VAVERS
  | REM of string
  | FIN
  | SOUSROUTINE
  | RETOURNE
  (*arithmetic operators*)
  | ADD
  | SOU
  | MUL
  | DIV

  (*comparison operator*)
  | EG
  | SUP
  | INF
  | SUPE
  | INFE
  | DIFF

  (*seperators*)
  | PARG
  | PARD
  | VIRG
  | SAUT
  (*spaces are ignored*)
  
  (*variables*)
  | VAR of char
  (*end of file*)
  | EOF

  let print_token tok = 
  match tok with
    (*data*)
    | ENTIER(v) -> print_string ("ENTIER("^(string_of_int v)^")")
    | CHAINE(v) -> print_string ("CHAINE("^v^")")
    (*built-in functions*)
    | IMPRIMER -> print_string ("IMPRIMER")
    | ENTREE -> print_string ("ENTREE")
    | NL -> print_string ("NL")
  
    (*keywords*)
    | SI -> print_string ("SI")
    | ALORS -> print_string ("ALORS")
    | VAVERS -> print_string ("VAVERS")
    | REM(s) -> print_string ("REM("^s^")") (*comments are ignored*)
    | FIN -> print_string ("FIN")
    | SOUSROUTINE -> print_string ("SOUSROUTINE")
    | RETOURNE -> print_string ("RETOURNE")

    (*arithmetic operators*)
    | ADD -> print_string ("ADD")
    | SOU -> print_string ("SOU")
    | MUL -> print_string ("MUL")
    | DIV -> print_string ("DIV")
  
    (*comparison operator*)
    | EG -> print_string "EG"
    | SUP -> print_string "SUP"
    | INF -> print_string "INF"
    | SUPE -> print_string "SUPE"
    | INFE -> print_string "INFE"
    | DIFF -> print_string "DIFF"
    
    (*seperators*)
    | PARG -> print_string ("PARG")
    | PARD -> print_string ("PARD")
    | VIRG -> print_string ("VIRG")
    | SAUT -> print_string ("SAUT")
    (*spaces are ignored*)
    
    (*variables*)
    | VAR(v) -> print_string ("VAR("^(String.make 1 v)^")")
    | EOF -> print_string "EOF"
    