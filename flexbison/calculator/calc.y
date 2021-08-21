%{
#include <stdio.h>
int yyerror(char * s);
%}

%token NUMBER
%token PLUS MINUS TIMES DIVIDE
%token EOL

%left PLUS MINUS
%left TIMES DIVIDE

%%

calclist : /* nothing */
         | calclist exp EOL { printf("= %d\n", $2); }

exp : NUMBER { $$ = $1; }
    | exp PLUS exp { $$ = $1 + $3; }
    | exp MINUS exp { $$ = $1 - $3; }
    | exp TIMES exp { $$ = $1 * $3; }
    | exp DIVIDE exp { $$ = $1 / $3; }

%%

int main(void) {
  while (1) {
    yyparse();
  }
}

int yyerror(char * s) {
  fprintf(stderr, "error: %s\n", s);
}
