target:
	bison -y -d json.y
	flex json.l
	gcc -c y.tab.c lex.yy.c
	gcc y.tab.o lex.yy.o -o parser
