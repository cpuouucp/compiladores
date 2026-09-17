all:
	flex lexer.l
	g++ lex.yy.c -o analisador_tonto

run: all
	./analisador_tonto exemplo.tonto

clean:
	rm -f lex.yy.c analisador_tonto
