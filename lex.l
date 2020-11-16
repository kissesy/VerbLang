%{
#include <stdio.h>
#include <string.h> 

#include "parse.tab.h" 
#define YY_DECL int yylex(YYSTYPE *yylval, parser_state* p)



%}

%option noyywrap 
%option yylineno

TRAIL  ([\t \n]|"#"[^\n]*"\n")*
CHAR   [a-zA-Z_]
CHNUM  ({CHAR}|[0-9])
WORD {CHAR}{CHNUM}*



%%
Declare {
    return declare;
    };
Assign {
    return assign;
    };
Operate {
    return operate;
    };
Call {
    return call;
    };
Iterate {
    return iterate;
    };
Compare {
    return compare;
    };
Otherwise {
    return otherwise;
    };
else {
    return keyword_else;
    };
Destroy {
    return keyword_destory;
    };
Allow {
    return allow;
    };

Escape {
    return escape;
};

Return {
    return keyword_return;
};

Construct {
    return construct;
};

variable {
    return variable;
    };
function {
    return function;
    };
class {
    return class;
    };

with {
    return with;
    };

then {
    return then;
    };

to {
    return to;
    };

as {
    return as;
}

of {
    return of;
};

begin:{TRAIL} {
    return begin;
    };

{TRAIL}end {
    return end;
    };

plus {
    return plus;
    };

mul {
    return mul;
    };

minus {
    return minus;
    };

div {
    return keyword_div;
    };

remainder {
    return remainder;
    };

ampersand {
    return ampersand;
    };

ampersands {
    return ampersands;
    };
    
vbar {
    return vbar;
    };

vbars {
    return vbars;
    };

reverse {
    return reverse;
    };

less {
    return less;
    };

eless {
    return eless;
    };

more {
    return more;
    };

emore {
    return emore;
    };

same {
    return same;
    };

nsame {
    return nsame;
};

Import {
    return import;
    };

Export {
    return export;
    };

None {
    return None;
};

{WORD} {
    return identity;
};

(([1-9][0-9]*)|0) {
    return number;
};

(([1-9][0-9]*)|0)(\.[0-9][0-9]*)? {
    return number;
};

0o[0-7]+ {
    return number;
};

\"([^\\\"]|\\.)*\" {
    return string;
};

\"([^\\\"]|\\.)*\": {
    yylval->str = strdup(yytext);
    return string;
};


0x[0-9a-fA-F]+ {
    return number;
};

true {
    return keyword_true;
};

false {
    return keyword_false;
};

"/*"([^*]|\*+[^*/])*\*+"/" {
};

[(\[,:\{]{TRAIL} { 
    return yytext[0];
};

[)\]\}]{TRAIL} {
    return yytext[0];
};


"\n" {
    return newline;
};

[ \t]+ ; 

. {
    fprintf(stderr, "lexical error ('%s').\n", yytext); 
    exit(1);
};
%%
