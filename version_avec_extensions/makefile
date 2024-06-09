main: clean lexer.cmo parser.cmo interpreter.cmo
	ocamlc token.cmo lexer.cmo syntax.cmo parser.cmo interpreter.cmo main.ml -o main

interpreter.cmo: syntax.cmo
	ocamlc -c syntax.cmo interpreter.ml

lexer.cmo: token.cmo
	ocamllex lexer.mll
	ocamlc -c token.cmo lexer.ml

parser.cmo: syntax.cmo
	menhir parser.mly --external-tokens Token --dump --explain --automaton-graph --cmly
	ocamlc -c parser.mli
	ocamlc -c syntax.cmo parser.ml

syntax.cmo:
	ocamlc -c syntax.ml

token.cmo:
	ocamlc -c token.ml

clean:
	rm -rf *.tmp *.cmo *.mli *.cmi a.out main lexer.ml results parser.ml *.automaton *.cmly *.conflicts *.dot
