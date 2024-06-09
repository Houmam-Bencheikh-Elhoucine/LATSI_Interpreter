{
    open Token
    let nline = ref 0;
    exception LEXING_ERROR of string
}
let digit = ['0'-'9']
(*data*)
let entier = digit+
(*let chaine = '"' [' ' '\''',' '('')' '_' ';' ':' '.' 'a'-'z' 'A'-'Z' '0'-'9']*'"'*)
let chaine = [^'"']*
(*built-in functions*)
let imprimer = "IMPRIME"
let entree = "ENTREE"
let nl = "NL"
let rem = "REM"

(*keywords*)
let si = "SI"
let alors = "ALORS"
let vavers = "VAVERS"
let fin = "FIN"

(*arithmetic operators*)
let add = '+'
let sou = '-'
let mul = '*'
let div = '/'

(*comparison operators*)
let eg = '='
let sup = '>'
let inf = '<'
let supe = ">="
let infe = "<="
let diff = "<>"|"><"

(*seperators*)
let parg = '('
let pard = ')'
let virg = ','
let saut = '\n'+
let space = [' ''\t']

(*variables*)
let var = ['A'-'Z']

rule get_token = parse
    | entier as v {ENTIER(int_of_string v)}
    | '"' (chaine as v)'"'{CHAINE(v)}

    (*built-in functions*)
    | imprimer {IMPRIMER}
    | entree {ENTREE}
    | nl {NL}

    (*keywords*)
    | si {SI}
    | alors {ALORS}
    | vavers {VAVERS}
    | fin {FIN}
    | rem space* '"'(chaine as c)'"'{REM(c)}

    | var as v {VAR(v)}
    (*arithmetic operators*)
    | add {ADD}
    | sou {SOU}
    | mul {MUL}
    | div {DIV}

    (*comparison operators*)
    | eg {EG}
    | sup {SUP}
    | inf {INF}
    | supe {SUPE}
    | infe {INFE}
    | diff {DIFF}

    (*seperators*)
    | parg {PARG}  
    | pard {PARD} 
    | virg {VIRG} 
    | saut {nline:=!nline+1;SAUT}
    | space {get_token lexbuf}

    (*variables*)
    | eof {EOF}
    | _ as v {raise (LEXING_ERROR ("Error at line "^(string_of_int !nline)^": unknown character code: "^(string_of_int (int_of_char v))^": "^(String.make 1 v)))}
