open Syntax;;
let create_variables () = 
  let cnt = ref 0 (*A*)
  and ret = Hashtbl.create 0
in while !cnt < 26 do
    Hashtbl.add ret (char_of_int (!cnt+65)) 0;
    cnt := !cnt + 1
  done;
ret;;

let rec imprimer_expr_list exp_lst env = 
  match exp_lst with
  | [] -> ()
  | CHAINE(s)::r -> print_string s; imprimer_expr_list r env
  | EXPR(exp)::r -> print_int (evaluate_expression exp env); imprimer_expr_list r env

and entree_vars var_lst env = 
  match var_lst with
  | [] -> ()
  | a::r -> Hashtbl.replace env a (read_int ()); entree_vars r env

and evaluate_cond cond env = 
  match cond with
  | EG(e1, e2) ->   (evaluate_expression e1 env) == (evaluate_expression e2 env)
  | SUP(e1, e2) ->  (evaluate_expression e1 env) > (evaluate_expression e2 env)
  | INF(e1, e2) ->  (evaluate_expression e1 env) < (evaluate_expression e2 env)
  | SUPE(e1, e2) -> (evaluate_expression e1 env) >= (evaluate_expression e2 env)
  | INFE(e1, e2) -> (evaluate_expression e1 env) <= (evaluate_expression e2 env)
  | DIFF(e1, e2) -> (evaluate_expression e1 env) <> (evaluate_expression e2 env)
and evaluate_expression expr env = 
  match expr with
  | POS(t) -> (evaluate_term t env)
  | NEG(t) -> -(evaluate_term t env)
  | ADD(t1, t2) -> (evaluate_expression t1 env) + (evaluate_expression t2 env)
  | SOU(t1, t2) -> (evaluate_expression t1 env) - (evaluate_expression t2 env)
and evaluate_term t env = 
  match t with 
  | FACT(f) -> (evaluate_facteur f env)
  | MUL(t1, t2) -> (evaluate_term t1 env) * (evaluate_term t2 env)
  | DIV(t1, t2) -> (evaluate_term t1 env) / (evaluate_term t2 env)
and evaluate_facteur f env = 
  match f with
  | CONST(i) -> i
  | VAR(c) -> Hashtbl.find env c
  | EXPR(exp) -> (evaluate_expression exp env)
and assign v value env = Hashtbl.replace env v value
  


let rec execute_instruction instr env = 
  match instr with
  | IMPRIMER(exp_lst) -> imprimer_expr_list exp_lst env; None
  | SI(cond, i) -> if (evaluate_cond cond env) then (execute_instruction i env) else None
  | ENTREE (var_lst) -> entree_vars var_lst env; None
  | AFF(v, exp) -> assign v (evaluate_expression exp env) env; None
  | FIN -> exit 0
  | REM(_) -> None
  | NL -> print_newline (); None
  | VAVERS(i) -> Some (evaluate_expression i env)
;;
let rec chercher_ligne x code = 
  match code with
  | LIGNE(a, instr)::r when a = x -> code
  | LIGNE(a, instr)::r when a < x -> chercher_ligne x r
  | LIGNE(a, instr)::r when a > x -> failwith "Ligne non trouvée"
  | [] -> failwith "Ligne non trouvée"
  | _ -> failwith "Cas impossible"

let execute_code code env = 
  let rec run to_run = 
  match to_run with
  | [] -> ()
  | LIGNE(x, instr)::r -> match (execute_instruction instr env) with
                        | None -> run r
                        | Some x -> run (chercher_ligne x code)
  in run code
(*
  let print_op = function
  | ADD -> print_string " + "
  | SOU -> print_string " - "
  | MUL -> print_string " * "
  | DIV -> print_string " / "

(* pour obtenir la valeur d'une variable *)
let rec get_var_value var =
  match List.assoc_opt var !environnement with
  | Some value -> value
  | None -> failwith ("Variable non initialisée : " ^ Char.escaped var)

(* pour définir la valeur d'une variable *)
let set_var_value var value =
  environnement := (var, value) :: List.remove_assoc var !environnement

(* Évaluer une expression *)
let rec eval_expr = function
  | CONST n -> n
  | VAR v -> get_var_value v
  | EXPR (left, op, right) ->
      let lval = eval_expr left in
      let rval = eval_expr right in
      begin match op with
      | ADD -> lval + rval
      | SOU -> lval - rval
      | MUL -> lval * rval
      | DIV -> lval / rval  
      end

(* Exécuter une instruction *)
let rec execute_instruction = function
  | IMPRIMER expr_list -> List.iter (fun expr -> print_int (eval_expr expr); print_char ' ') expr_list; print_newline ()
  | ENTREE var_list -> List.iter (fun var -> let value = read_int () in set_var_value var value) var_list
  | NL -> print_newline ()
  | SI (COMP (left, op_logique, right), then_instr) ->
      if eval_comp left op_logique right
      then execute_instruction then_instr
  | VAVERS line_number -> failwith "Instruction VAVERS non implémentée"
  | FIN -> ()
  | _ -> failwith "Instruction non reconnue"

(* Évaluer une comparaison *)
and eval_comp left op right =
  let lval = eval_expr left in
  let rval = eval_expr right in
  match op with
  | CMP "=" -> lval = rval
  | CMP "<" -> lval < rval
  | CMP ">" -> lval > rval
  | CMP "<=" -> lval <= rval
  | CMP ">=" -> lval >= rval
  | _ -> failwith "Opérateur de comparaison non reconnu"

(* Exécuter le programme *)
let rec execute_program = function
  | PROGRAMME arbre -> execute_tree arbre
  | _ -> failwith "Erreur de programme"

(* Fonction pour exécuter l'arbre de lignes *)
and execute_tree = function
  | NIL -> ()
  | ARBRE (num, inst, gauche, droit) -> execute_instruction inst; execute_tree gauche; execute_tree droit

let _ =
  let ast = initialiser_programme () in
  execute_program ast

(* Afficher l'arbre syntaxique *)
let rec print_ast = function
  | Syntax.PROGRAMME arbre -> print_string "PROGRAMME "; print_tree arbre
  | Syntax.NIL -> print_string "NIL"
  | Syntax.ARBRE (num, inst, gauche, droit) ->
      Printf.printf "ARBRE (Ligne %d) : " num;
      print_instruction inst;
      print_ast gauche;
      print_ast droit

and print_instruction = function
  | Syntax.IMPRIMER expr_list ->
      print_string "IMPRIMER ";
      List.iter print_expr expr_list;
      print_newline ()
  | Syntax.ENTREE var_list ->
      print_string "ENTREE ";
      List.iter (fun var -> Printf.printf "%c " var) var_list;
      print_newline ()
      | _ -> print_string "Autre instruction"
    
and print_expr = function
  | Syntax.CONST n -> Printf.printf "CONST %d " n
  | Syntax.VAR v -> Printf.printf "VAR %c " v
  | Syntax.EXPR (left, op, right) ->
      print_string "EXPR (";
      print_expr left;
      print_op op;  
      print_expr right;
      print_string ") "
    
let print_expr_list expr_list =
    List.iter (fun expr -> print_expr expr) expr_list
      
let _ =
 let in_channel = open_in "test1.latsi" in
 let lexbuf = Lexing.from_channel in_channel in
    try
      let ast = Parser.programme Lexer.read lexbuf in
      print_ast ast; (* Afficher l'AST *)
      execute_program ast; (* Exécuter le programme *)
      close_in in_channel
    with
    | e ->
    close_in_noerr in_channel;
    raise e
*)