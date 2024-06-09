open Syntax;;
type state = (*présente l'état de l'interpreteur pour la prochaine instruction*)
| SEQ (*sequenciel, prochaine instruction est la suivante*)
| BRC of int (*branchement, prochaine instruction (si elle se trouve), est indiquée par le paramètre*)
| FCT of int (*appel d'une fonction (sousroutine)*)
| RET (*retour d'une fonction*)
;;
let create_variables () = 
  let cnt = ref 0 (*A*)
  and ret = Hashtbl.create 0
in while !cnt < 26 do
    Hashtbl.add ret (char_of_int (!cnt+65)) 0;
    cnt := !cnt + 1
  done;
ret;;

let rec imprimer_expr_list exp_lst variables = 
  match exp_lst with
  | [] -> ()
  | CHAINE(s)::r -> print_string s; imprimer_expr_list r variables
  | EXPR(exp)::r -> print_int (evaluate_expression exp variables); imprimer_expr_list r variables

and entree_vars var_lst variables =
  match var_lst with
  | [] -> ()
  | a::r -> Hashtbl.replace variables a (read_int ()); entree_vars r variables

and evaluate_cond cond variables = 
  match cond with
  | EG(e1, e2) ->   (evaluate_expression e1 variables) == (evaluate_expression e2 variables)
  | SUP(e1, e2) ->  (evaluate_expression e1 variables) > (evaluate_expression e2 variables)
  | INF(e1, e2) ->  (evaluate_expression e1 variables) < (evaluate_expression e2 variables)
  | SUPE(e1, e2) -> (evaluate_expression e1 variables) >= (evaluate_expression e2 variables)
  | INFE(e1, e2) -> (evaluate_expression e1 variables) <= (evaluate_expression e2 variables)
  | DIFF(e1, e2) -> (evaluate_expression e1 variables) <> (evaluate_expression e2 variables)
and evaluate_expression expr variables = 
  match expr with
  | POS(t) -> (evaluate_term t variables)
  | NEG(t) -> -(evaluate_term t variables)
  | ADD(t1, t2) -> (evaluate_expression t1 variables) + (evaluate_expression t2 variables)
  | SOU(t1, t2) -> (evaluate_expression t1 variables) - (evaluate_expression t2 variables)
and evaluate_term t variables = 
  match t with 
  | FACT(f) -> (evaluate_facteur f variables)
  | MUL(t1, t2) -> (evaluate_term t1 variables) * (evaluate_term t2 variables)
  | DIV(t1, t2) -> (evaluate_term t1 variables) / (evaluate_term t2 variables)
and evaluate_facteur f variables = 
  match f with
  | CONST(i) -> i
  | VAR(c) -> Hashtbl.find variables c
  | EXPR(exp) -> (evaluate_expression exp variables)
and assign v value variables = 
  let rec copy_vars = (Hashtbl.copy variables) and
  assign_vals vars vals env =
  match vars,vals with
  |[],[] -> ()
  |a::rv, b::re -> Hashtbl.replace variables a (evaluate_expression b env);assign_vals rv re env;
  |_, _ -> failwith "Cas interdit"
  in assign_vals v value copy_vars
let rec execute_instruction instr variables = 
  match instr with
  | IMPRIMER(exp_lst) -> imprimer_expr_list exp_lst variables; SEQ
  | SI(cond, i) -> if (evaluate_cond cond variables) then (execute_instruction i variables) else SEQ
  | ENTREE (var_lst) -> entree_vars var_lst variables; SEQ
  | AFF(l) -> (List.iter (fun (v,exp) -> assign v exp variables) l); SEQ
  | FIN -> exit 0
  | REM(_) -> SEQ
  | NL -> print_newline (); SEQ
  | VAVERS(i) -> BRC (evaluate_expression i variables)
  | SOUSROUTINE(i) -> FCT (evaluate_expression i variables)
  | RETOURNE -> RET
;;
let rec chercher_ligne x code = 
  match code with
  | LIGNE(a, instr)::r when a = x -> code
  | LIGNE(a, instr)::r when a < x -> chercher_ligne x r
  | LIGNE(a, instr)::r when a > x -> failwith "Ligne non trouvée"
  | [] -> failwith "Ligne non trouvée"
  | _ -> failwith "Cas impossible"

let empiler x pile_appel = 
  match x with
  | [] -> pile_appel := (-1::(!pile_appel))
  | LIGNE(a, _)::r -> pile_appel := (a::(!pile_appel))

let depiler pile_appel =
  match !pile_appel with
  | [] -> failwith "empty call stack"
  | -1::r -> exit 0
  | a::r -> pile_appel := r;a

  let execute_code code variables pile_appel = 
  let rec run to_run = 
  match to_run with
  | [] -> ()
  | LIGNE(x, instr)::r -> match (execute_instruction instr variables) with
                        | SEQ -> run r
                        | BRC x -> run (chercher_ligne x code)
                        | FCT x -> (empiler r pile_appel); run (chercher_ligne x code)
                        | RET -> run (chercher_ligne (depiler pile_appel) code)
  in run code
