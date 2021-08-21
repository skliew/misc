%{
#include "calc.tab.h"

int yylval;
%}

%%

"+" { return PLUS; }
"-" { return MINUS; }
"*" { return TIMES; }
"/" { return DIVIDE; }
[ \t] { }
"\n" { return EOL; }
[0-9]+ { yylval = atoi(yytext); return NUMBER; }
.   { printf("Unknown character %s\n", yytext); }

%%
