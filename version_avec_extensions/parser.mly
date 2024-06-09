%{
    open Syntax;;
    let lignes = ref [];;
%}
(*data types*)
%token <int> ENTIER
%token <string> CHAINE
(*INSTRUCTIONS*)
%token IMPRIMER ENTREE NL FIN SI ALORS SOUSROUTINE RETOURNE
%token VAVERS
%token <string> REM
%token ADD SOU MUL DIV
%token PARG PARD VIRG SAUT SUP INF SUPE INFE EG DIFF
%token EOF
(*variable*)
%token <char> VAR

%start programme
%type <Syntax.programme> programme
%type <Syntax.ligne> ligne
%type <Syntax.instruction> instruction
%type <Syntax.expr_sortie list> expr_sortie_list
%type <Syntax.expr_sortie> expr_sortie
%type <Syntax.expr list> expr_list
%type <Syntax.expr> expr
%type <Syntax.term> term
%type <((char list) * (expr list)) list> aff_seq
%type <(char list) * (expr list)> aff
%type <Syntax.facteur> facteur
%type <Syntax.cond> cond
%type <char list> var_list
%left ADD
%left SOU
%right MUL
%right DIV
%%
programme:
| l=ligne SAUT programme EOF{(*PROGRAMME(ajouter_ligne l p)*)creer_programme (ajouter_ligne l lignes)}
| l=ligne SAUT EOF{(*PROGRAMME(ajouter_ligne l p)*)(creer_programme (ajouter_ligne l lignes))}

| l=ligne EOF{(*PROGRAMME(ajouter_ligne l p)*)(creer_programme (ajouter_ligne l lignes))}

ligne:
| cnt=ENTIER i=instruction {LIGNE(cnt, i)}

instruction:
| IMPRIMER el=expr_sortie_list {IMPRIMER(el)}
| SI c=cond ALORS i=instruction {SI(c, i)}
| VAVERS l=expr {VAVERS(l)}
| SOUSROUTINE l=expr {SOUSROUTINE(l)}
| RETOURNE {RETOURNE}
| ENTREE vl=var_list {ENTREE(vl)}
| FIN {FIN}
| REM {REM($1)}
| NL {NL}
| aff=aff_seq {AFF(aff)}

aff_seq:
| a_seq=aff_seq VIRG a=aff {a::a_seq}
| a=aff {[a]}

aff:
| PARG v=var_list PARD EG PARG e=expr_list PARD {(v, e)}
| v=VAR EG e=expr {([v], [e])}
expr_sortie_list:
| e=expr_sortie VIRG el=expr_sortie_list {e::el}
| e=expr_sortie {[e]}

expr_sortie:
| s=CHAINE {CHAINE(s)}
| e=expr {EXPR(e)}

expr_list:
| e=expr {[e]}
| e=expr VIRG ex=expr_list {e::ex}

expr:
| t=term {POS(t)}
| ADD t=term {POS(t)}
| SOU t=term {NEG(t)}
| e1=expr ADD e2=expr{ADD(e1, e2)}
| e1=expr SOU e2=expr{SOU(e1, e2)}

term:
| f=facteur {FACT(f)}
| t1=term MUL t2=term {MUL(t1, t2)}
| t1=term DIV t2=term {DIV(t1, t2)}

facteur:
| e=ENTIER {CONST(e)}
| v=VAR {VAR(v)}
| PARG e=expr PARD {EXPR(e)}


var_list:
| v=VAR {[v]}
| v=VAR VIRG vl=var_list {v::vl}

cond:
| e1=expr SUP e2=expr {SUP(e1, e2)}
| e1=expr INF e2=expr {INF(e1, e2)}
| e1=expr SUPE e2=expr {SUPE(e1, e2)}
| e1=expr INFE e2=expr {INFE(e1, e2)}
| e1=expr EG e2=expr {EG(e1, e2)}
| e1=expr DIFF e2=expr {DIFF(e1, e2)}