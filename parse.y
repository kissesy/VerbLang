%{
#define YYDEBUG 1
#define YYERROR_VERBOSE 1
%}

%{
#include <stdio.h>
#include <stdlib.h>

typedef struct parser_state{
    int nerr;
    void *lval;
    const char *fname;
    int lineno;
    int tline;
} parser_state;    

#define YYDEBUG 1
#define YYERROR_VERBOSE 1
%}

/*
YYSTYPE 부분 
*/
%union{
    double d; 
    char *str;
}

%pure-parser
%parse-param {parser_state *p}
%lex-param {p}

%{
void yyerror(parser_state* ,const char *);
int yylex(YYSTYPE *yylval, parser_state *p);
%}

%token  
    declare
    assign 
    operate
    call
    iterate
    compare
    otherwise
    keyword_else
    keyword_destory 
    allow
    escape
    keyword_return
    construct

%token
    variable 
    function
    class
    with 
    then
    to 
    of
    as

%token
    begin 
    end 

%token
    plus
    mul 
    minus
    keyword_div 
    remainder 
    ampersand 
    ampersands 
    vbar 
    vbars
    reverse
    less
    eless
    more
    emore
    same
    nsame

%token
    import
    export 
    
%token 
    identity 

%token
    None
    number
    string 
    keyword_true
    keyword_false

%token 
    newline

%left vbar vbars 
%left ampersand ampersands
%left same nsame 
%left less eless more emore
%left plus minus
%left mul keyword_div remainder

/*then of to as 순위 안정해도 되겠지?*/
%right reverse

%%
/*
함수랑 클래스 정의된거를 호이스팅 작업이나 정의문을 따로 정리해야할듯 
*/
program : compstmt
        ;

compstmt : /* EPSILON */
         | opt_terms stmts opt_terms
         ;

stmts : stmt 
      | stmts terms stmt 
      ;

/* then 이전의 command은 반드시 값을 emit할 수 있는 command이여야 함 */

stmt : emit_stmt
     | no_emit_stmt
     ;

/*
클래스 내에서만 사용가능한 stmts
*/

class_compstmt : /* EPSILON */
               | opt_terms class_stmts opt_terms
               ;

class_stmts : class_stmt 
            | class_stmts terms class_stmt 
            ;
class_stmt : emit_stmt 
           | no_emit_stmt 
           | keyword_destory begin compstmt end
           | construct begin compstmt end
           | allow allow_command
           ;

/* emit 가능 stmt들 */
emit_stmt : emit_command 
          | emit_command then keyword_return
          | keyword_return operator
          | emit_command then emit_reduce_stmts
          ;

/* emit이 불가능한 stmt */
no_emit_stmt : no_emit_command
             ;

/* 끝에 then 지시어 사용이 불가능하다. 받는 것 또한 불가능하다. */
no_emit_command : compare operator begin compstmt end opt_else
                | iterate operator begin compstmt end
                | declare function identity with_opt_args begin compstmt end
                | declare class identity with_opt_args begin class_compstmt end
                | escape
                ;
/*
아래 command들은 then 다음 command로 값을 넘길 수 있는 emit속성을 지닌다.
*/
emit_command : operate operator
             | declare variable identity
             | assign operator to identity with_opt_args/* 클래스 인스턴스 할당 또는 함수를 인자로 전달할때 사용할 수 있음 */
             | call identity with_opt_args 
             | call identity of identity with_opt_args
             ;

emit_reduce_stmts : emit_reduce_stmts then emit_reduce_command 
                  | emit_reduce_command
                  ;

/*
내장 함수와 내장 메소드, 속성에 대해서 따로 처리하는 과정이 있어야 할듯 
*/
/* 축약 지시어 이전의 then으로부터 값을 받아 와야함 */
emit_reduce_command : assign to identity /* then이전의 emit대상을 바로 assign한다. */
                    | call identity  /* then이전의 emit대상을 바로 Call할 때 인자로 박아버림 */
                    | call identity of identity 
                    | assign as object /* to는 그 다음 값에 then이전의 emit을 할당하는 거지만 as는 emit되는 값에 as 다음 값을 할당한다.  */

/* ALLOW 가능한 command */
allow_command : call identity with_opt_args
              | call identity of identity with_opt_args
              | declare variable identity
              | declare function identity with_opt_args begin compstmt end

operator : operator plus operator 
         | operator minus operator 
         | operator mul operator
         | operator keyword_div operator
         | operator remainder operator 
         | operator ampersand operator 
         | operator ampersands operator 
         | operator vbar operator 
         | operator vbars operator
         | reverse operator
         | operator less operator 
         | operator eless operator 
         | operator more operator 
         | operator emore operator 
         | operator same operator 
         | operator nsame operator
         | object  /* 특정 값을 바로 emit 가능 */
         | '(' operator ')'
         ;   

opt_else : opt_elsif 
         | opt_elsif keyword_else begin stmts end
         ;

opt_elsif : /* EPSILON */
          | opt_elsif otherwise compare operator begin stmts end
          ;

/* with를 포함한 opt_args */
with_opt_args : /* EPSILON */
              | with args

opt_args : /* EPSILON */
         | args 

args : object
     | args ',' object
     ;

/* expr에는 객체가 들어간다. */
/*
expr : object
     ;
*/
object : number 
       | string
       | identity /* 사용자 선언 객체 */
       | keyword_true 
       | keyword_false
       | None 
       | list
       | dict
       ;

list : '[' opt_args ']'
     ;

dict : '{' obj_elems '}'
     | '{' '}'
     ;

obj_elems : object ':' object
          | obj_elems ',' object ':' object
          ;

opt_terms : term
          | /* EPSILON */
          ;

terms : term 
      | terms term 

term : newline 
     ;

%%

int yyparse(parser_state *p);

void yyerror(parser_state *p, const char *s){
    printf("ERROR : %s\n", s);
    return;
}

int main(void){
    parser_state state = {0, NULL, "test", 1, 1};
    yyparse(&state);
    return 0;
}