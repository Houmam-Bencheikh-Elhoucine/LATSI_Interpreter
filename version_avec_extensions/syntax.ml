type programme = 
| PROGRAMME of liste_ligne

and liste_ligne= ligne list

and ligne = 
| LIGNE of int * instruction

and instruction = 
| IMPRIMER of expr_sortie list
| SI of cond * instruction
| VAVERS of expr
| SOUSROUTINE of expr
| RETOURNE
| ENTREE of char list
| AFF of ((char list) * (expr list)) list
| FIN
| REM of string
| NL

and facteur = 
| CONST of int
| VAR of char
| EXPR of expr

and cond = 
|EG of expr * expr
|SUP of expr * expr
|INF of expr * expr
|SUPE of expr * expr
|INFE of expr * expr
|DIFF of expr * expr

and expr = 
| POS of term
| NEG of term
| ADD of expr * expr
| SOU of expr * expr

and expr_sortie = 
| CHAINE of string  
| EXPR of expr

and term = 
| FACT of facteur
| MUL of term * term
| DIV of term * term

let rec print_var_list l = 
  match l with
  | [] -> ()
  | a::r -> print_string ("VAR("^(String.make 1 a)^")");print_var_list r
and print_cond cond = 
  match cond with
  |EG(e1, e2) -> print_string "EG(";print_exp e1;print_string ", ";print_exp e2;print_string ")"
  |SUP(e1, e2) -> print_string "SUP(";print_exp e1;print_string ", ";print_exp e2;print_string ")"
  |INF(e1, e2) -> print_string "INF(";print_exp e1;print_string ", ";print_exp e2;print_string ")"
  |SUPE(e1, e2) -> print_string "SUPE(";print_exp e1;print_string ", ";print_exp e2;print_string ")"
  |INFE(e1, e2) -> print_string "INFE(";print_exp e1;print_string ", ";print_exp e2;print_string ")"
  |DIFF(e1, e2) -> print_string "DIFF(";print_exp e1;print_string ", ";print_exp e2;print_string ")"
and print_facteur f = 
  match f with
  | CONST(i) -> print_string ("CONST("^(string_of_int i)^")")
  | VAR(v) -> print_string ("VAR("^(String.make 1 v)^")")
  | EXPR(e) -> print_string "EXPR(";print_exp e; print_string ")"
and print_term t = 
  match t with
  | FACT(f) -> print_string "FACT(";print_facteur f;print_string ")"
  | MUL(t1, t2) -> print_string "MUL(";print_term t1;print_string ", ";print_term t2; print_string ")"
  | DIV(t1, t2) ->print_string "MUL(";print_term t1;print_string ", ";print_term t2; print_string ")"

and print_exp (e: expr) = 
  match e with 
  | POS(t) -> print_string "POS(";print_term t; print_string ")"
  | NEG(t) -> print_string "NEG(";print_term t; print_string ")"
  | ADD(t1, t2) -> print_string "ADD(";print_exp t1;print_string ", ";print_exp t2; print_string ")"
  | SOU(t1, t2) -> print_string "SOU(";print_exp t1;print_string ", ";print_exp t2; print_string ")"
and print_exp_sortie e = 
  match e with 
  | CHAINE(e) -> print_string ("CHAINE("^e^")")
  | EXPR(e) -> print_exp e

and print_ligne l = 
  let rec print_expr_list l = 
    match l with
    | [] -> ()
    | a::r -> print_exp_sortie a;print_string", "; print_expr_list r
  and print_instruction instr = 
    match instr with
    | IMPRIMER(l) -> print_string "IMPRIMER(";print_expr_list l;print_string ")"
    | SI (cond, i) -> print_string "SI(";print_cond cond;print_instruction i;print_string ")"
    | VAVERS(i) -> print_string "VAVERS("; print_exp i;print_string ")"
    | ENTREE (l) -> print_string "ENTREE(";print_var_list l;print_string ")"
    | AFF(_) -> print_string ("AFF("^")")
    | FIN -> print_string "FIN"
    | REM(s) -> print_string ("REM("^s^")")
    | NL -> print_string "NL"
    | SOUSROUTINE(i) -> print_string ("SOUSROUTINE(");print_exp i;print_string ")"
    | RETOURNE -> print_string "RETOURNE" 
  in
  match l with
  | LIGNE(cnt, instr) -> print_string ("LIGNE("^(string_of_int cnt)^", ");print_instruction instr;print_string ")\n"

let ajouter_ligne l (liste) = 
  let rec ajouter_ligne_liste ln ls = 
    match ls with
    | [] -> [ln]
    | a::r -> match ln, a with
              | (LIGNE(x, _), LIGNE(y, _)) when x=y -> ls
              | (LIGNE(x, _), LIGNE(y, _)) when x<y -> ln::ls
              | (LIGNE(x, _), LIGNE(y, _)) when x>y -> a::(ajouter_ligne_liste ln r)
              | _, _ -> failwith "Cas impossible"
  in
  liste := (ajouter_ligne_liste l !liste);
  (!liste)

and creer_programme liste =
  PROGRAMME(liste)
