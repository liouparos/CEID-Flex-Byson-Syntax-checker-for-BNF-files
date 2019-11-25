%{
  /* libs and functions */
  extern int yylineno;
  void checkRequirements(int textField, int idStrField, int createdAtField);
  int checkUser(int idField, int nameField, int screenNameField, int locationField);
  void yyerror (char *s);
  /* void truncc(int x, char *totru); */
  int yylex();
  int userID[50]; //unique user IDs
  char *strUnique[1]; //unique str_IDs
  char *strings;
  /* char *tru;
  char *lefttru; */

  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <ctype.h>

  FILE *yyin;

  /* Required fields counters */
  int endOfArray=1;
  int endOfArray1=1;
  int textField = 0;
  int idStrField = 0;
  int createdAtField = 0;
  int idField = 0;
  int nameField = 0;
  int screenNameField = 0;
  int locationField = 0;
  /* int truncated = 0; */

%}
%union {
  int intval;
  double val;
  char* str;
}
%start            JSON
%token            true false null CREATED_AT TRUNC
%left             O_BEGIN O_END A_BEGIN A_END
%left             COMMA
%left             COLON
%token            <intval> NUMBER
%token            <str> STRING TEXT_INIT USER_INIT ID_STR TWEET RETWEET EXTWEET
%type             <str> JSON ARRAY
%%
/* json def */
JSON: O_BEGIN O_END
{
  $$ = "{}";
}
| O_BEGIN MEMBERS O_END{;};

/* json def */
MEMBERS: PAIR
| PAIR COMMA MEMBERS{;};

/* json def */
PAIR: STRING COLON VALUE{;}
| TEXT_INIT COLON STRING
{
  /* tru = (char*)malloc(strlen($3)+1);
  strcpy(tru , $3); */
  if(strlen($3) <= 140){
    textField++;
  }else{

    printf("\ntext field exceeded 140 chars in length\n");
    exit(1);
    /* truncated = 1;
    truncc(truncated, tru);
    truncated = 0; */
  }
}
| USER_INIT COLON O_BEGIN REQUIRED_VALUES O_END{;}
| ID_STR COLON STRING
{
  int isDigitCounter = 0;
  for(int i = 0; i < strlen($3); i++){
    if($3[i] == *"\"")
      continue;
    if(isdigit($3[i]))
      isDigitCounter++;

  }

  if(isDigitCounter == (strlen($3) - 2)){         /*adjusting for the double quotes the string is supposed to have*/

    int uniqueExist=0;
    strUnique[0] = malloc(strlen($3)+1);
    strings = (char*)malloc(strlen($3)+1);
    strcpy(strings , $3);
    for(int i = 0; i < endOfArray1; i++){
            if( !strcmp(strUnique[i], strings) ){
              uniqueExist=1;
              yyerror("\nDuplicate id_strs\n");
              exit(1);
           }
     }
     if(uniqueExist==0){
       strUnique[endOfArray1]=$3;
       endOfArray1++;
     }
    idStrField++;
  }else if(isDigitCounter == 0){
    yyerror("\nid_str field expected alphanumerical integer,alphanumerical string given\n");
    exit(1);
  }else{
    yyerror("\nid_str field contains characters\n");
    exit(1);
  }
}
|CREATED_AT COLON STRING
{
  createdAtField++;
}
|TWET{;}
|RETWET{;}
|EXTWET{;}
|TRUNC COLON true{;};

/* extweet def */
EXTWET: EXTWEET COLON O_BEGIN BODYEX O_END{;};

/* retweet def */
RETWET: RETWEET COLON O_BEGIN BODY O_END{;};

/* tweet def */
TWET: TWEET COLON O_BEGIN BODY O_END{;};

BODY: PAIR COMMA MEMBERS | PAIR{;};

BODYEX: PAIR COMMA MEMBERS | PAIR{;};

/* req val def */
REQUIRED_VALUES: REQUIRED_VALUE{;} | REQUIRED_VALUE COMMA REQUIRED_VALUES{;};

/* req val def */
REQUIRED_VALUE: STRING COLON NUMBER{;}
{
  if(!strcmp($1,"\"id\"") && $3 >= 0){

    int uniqueExist=0;
    for(int i = 0; i < endOfArray; i++){
        if(userID[i] == $3){
          uniqueExist=1;
          yyerror("\nDuplicate ids\n");
          exit(1);
        }
    }
    if(uniqueExist==0){
        userID[endOfArray] = $3;
        endOfArray++;
    }

    idField++;
  }
}
| STRING COLON STRING
{
  if(!strcmp($1,"\"name\"")){
    nameField++;
  }
  if(!strcmp($1,"\"screen_name\"")){
    screenNameField++;
  }
  if(!strcmp($1,"\"location\"")){
    locationField++;
  }
};

/* array def */
ARRAY: A_BEGIN A_END
{
  $$ = "[]";
}
| A_BEGIN ELEMENTS A_END{;};

/* elem def */
ELEMENTS: VALUE{;} | VALUE COMMA ELEMENTS{;};

/* value def */
VALUE: STRING{;} | NUMBER{;} | ARRAY{;} | JSON{;};

%%

/* helper functions */
int main ( int argc, char *argv[] ) {
  if(!(argc == 2)){
    printf("Cannot open %d files!\nExiting...\n",(--argc));
    return 1;
  }
  yyin = fopen(argv[1],"r");
  yyparse();
  fclose(yyin);
  checkRequirements(textField, idStrField, createdAtField);
  return 0;
}

void checkRequirements(int textField, int idStrField, int createdAtField){
  if(textField){
    printf("\ntext field ok!\n");
  }
  else{
    printf("ERROR:text field missing\n");
    exit(1);
  }
  if(idStrField){
    printf("id_str field ok!\n");
  }else{
    printf("ERROR:id_str field missing\n");
    exit(1);
  }
  if(createdAtField){
    printf("created_at field ok!\n");
  }else{
    printf("ERROR:created_at field missing\n");
    exit(1);
  }

  int userField = checkUser(idField, nameField, screenNameField, locationField);

  if(userField == 4){
    printf("user field ok!\n");
  }
  else if(userField == 0){
    printf("ERROR:user field missing\n");
    exit(1);
  }
  else{
    printf("user field bad\n");
  }
}

int checkUser(int idField, int nameField, int screenNameField, int locationField){
  int userChecks = 0;

  if(idField){
    printf("\tuser id field ok!\n");
    userChecks++;
  }
  if(nameField){
    printf("\tuser name field ok!\n");
    userChecks++;
  }
  if(screenNameField){
    printf("\tuser screen name field ok!\n");
    userChecks++;
  }
  if(locationField){
    printf("\tuser location field ok!\n");
    userChecks++;
  }

  return userChecks;
}

void yyerror(char *s) {
    fprintf(stderr, "LINE %d: %s\n", yylineno, s);
    printf("\n");
}

/* void truncc(int x, char *totru) {
    if(x==1){
        char *lefttru;
        lefttru = (char*)malloc(142);
        strncpy(lefttru, totru, 141);
        strcat(lefttru, """);
        printf("%s", lefttru);
    }else{
        printf("%s", totru);
    }
} */
