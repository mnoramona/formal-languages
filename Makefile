# Mitran Ramona Luminita 333CC

main: lex.yy.c
	gcc -Wall lex.yy.c -o main -lfl

lex.yy.c: main.l
	flex main.l

run: main
	./main 0.tex > 0_out.md
	./main 1.tex > 1_out.md
	./main 2.tex > 2_out.md
	./main 3.tex > 3_out.md
	./main README.tex > README.md

clean:
	rm -f main lex.yy.c
	rm -f 0_out.md 1_out.md 2_out.md 3_out.md README.md

.PHONY: clean run