all: calc

calc.tab.c: calc.y
	bison -d $?

lex.yy.c: lex.l
	flex lex.l

calc: lex.yy.c calc.tab.c
	@gcc calc.tab.c lex.yy.c -lfl -o calc
