%{
    #include "y.tab.h"
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    void yyerror(char* s);
    void tokenform(char* token);
    void printnum(int num);
    int yylex();
    int i=0;
    int tabflag=0;
    int tabcount=0;
    int a=1; //before/after flag
    int taballow=1;
%}
%option yylineno
DIGIT1to9 [1-9]
DIGIT [0-9]
DIGITS {DIGIT}+
INT {DIGIT}|{DIGIT1to9}{DIGITS}|-{DIGIT}|-{DIGIT1to9}{DIGITS}
FRAC [.]{DIGITS}
EXP {E}{DIGITS}
E [eE][+-]?
HEX_DIGIT [0-9a-f]
NUMBER {INT}|{INT}{FRAC}|{INT}{EXP}|{INT}{FRAC}{EXP}
UNESCAPEDCHAR [ -!#-\[\]-~]
ESCAPEDCHAR \\["\\bfnrt/]
UNICODECHAR \\u{HEX_DIGIT}{HEX_DIGIT}{HEX_DIGIT}{HEX_DIGIT}
CHAR {UNESCAPEDCHAR}|{ESCAPEDCHAR}|{UNICODECHAR}
CHARS {CHAR}+
DBL_QUOTE ["]

%%

{DBL_QUOTE}created_at{DBL_QUOTE} {
    taballow=0;
    tokenform(yytext);
    taballow=1;
    return CREATED_AT;
}

{DBL_QUOTE}id_str{DBL_QUOTE} {
    taballow=0;
    tokenform(yytext);
    taballow=1;
    return ID_STR;
}

{DBL_QUOTE}user{DBL_QUOTE} {
    taballow=0;
    tokenform(yytext);
    taballow=1;
    return USER_INIT;
}

{DBL_QUOTE}text{DBL_QUOTE} {
    taballow=0;
    tokenform(yytext);
    taballow=1;
    return TEXT_INIT;
}

{DBL_QUOTE}tweet{DBL_QUOTE} {
    taballow=0;
    tokenform(yytext);
    taballow=1;
    return TWEET;
}

{DBL_QUOTE}retweeted_status{DBL_QUOTE} {
    taballow=0;
    tokenform(yytext);
    taballow=1;
    return RETWEET;
}

{DBL_QUOTE}extended_tweet{DBL_QUOTE} {
    taballow=0;
    tokenform(yytext);
    taballow=1;
    return EXTWEET;
}

{DBL_QUOTE}truncated{DBL_QUOTE} {
    taballow=0;
    tokenform(yytext);
    taballow=1;
    return TRUNC;
}

{DBL_QUOTE}{CHARS}{DBL_QUOTE} {
    yylval.str=strdup(yytext);
    taballow=0;
    tokenform(yytext);
    taballow=1;
    return STRING;
}

{NUMBER} {
    yylval.intval=atoi(strdup(yytext));
    printnum(yylval.intval);
    return NUMBER;
}

true {
    return true;
}

false {
    return false;
}

null {
    return null;
}

\{ {
    tabflag=1;
    tabcount++;
    tokenform(yytext);
    tabflag=0;
    return O_BEGIN;
}

\} {
    tabflag=1;
    a=0;
    tabcount--;
    tokenform(yytext);
    tabflag=0;
    a=1;
    return O_END;
}

\[ {
    tabflag=1;
    tabcount++;
    tokenform(yytext);
    tabflag=0;
    return A_BEGIN;
}

\] {
    tabflag=1;
    a=0;
    tabcount--;
    tokenform(yytext);
    tabflag=0;
    a=1;
    return A_END;
}

, {
    tabflag=1;
    tokenform(strdup(yytext));
    tabflag=0;
    return COMMA;
}
: {
    taballow=0;
    tokenform(yytext);
    taballow=1;
    return COLON;
}

[ \t\n]+ /* ignore whitespace */;

. {
    printf("Unexpected: %c\nExiting...\n",*yytext);
    exit(0);
}

%%

/* helper functions */
int yywrap(void)
{
    return 1;
}

/* print tokens with the respective tabs */
void tokenform(char* token){
/* terminal char == {}[],: */
/* found terminal char, newline and print tabs *before* a token*/

    if(tabflag==1 && a==0)
    {
        printf("\n");
        for(i=0;i<tabcount;i++){
            if(taballow==1){
                 printf("\t");
            }
        }
    }
/* print token*/
    printf("%s", token);

/* found terminal char, newline and print tabs *after* a token*/

    if(tabflag==1 && a==1)
    {
        printf("\n");
        for(i=0;i<tabcount;i++){
            if(taballow==1){
                 printf("\t");
            }
        }
    }
}

/* print integers */
void printnum(int num){
     printf("%d", num);
}
