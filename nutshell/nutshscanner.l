%{
// This is ONLY a demo micro-shell whose purpose is to illustrate the need for and how to handle nested alias substitutions and how to use Flex start conditions.
// This is to help students learn these specific capabilities, the code is by far not a complete nutshell by any means.
// Only "alias name word", "cd word", and "bye" run.
#include "nutshparser.tab.h"
#include <string.h>
#include "global.h"

bool isUnalias = false;

char* subAliases(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return aliasTable.word[i];
        }
    }
    return name;
}

void setUnAlias() {
    if(isUnalias) {
        isUnalias = false;
    } else {
        isUnalias = true;
    }
}

bool ifAlias(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return true;
        }
    }
    return false;
}


bool ifVarName(char* name) {
    for (int i = 0; i < varIndex; i++) {
        if(strcmp(varTable.var[i], name) == 0) {
            return true;
        }
    }
    return false;
}

char* getVarTableWord(char* name) {
    for (int i = 0; i < varIndex; i++) {
        if (strcmp(varTable.var[i], name) == 0) {
            return varTable.word[i];
        }
    }
    return name;
}
%}
%array
%option noyywrap
%x string_condition
%x expansion_condition
                
CHAR                [.A-Za-z0-9!\/_-][.A-Za-z0-9!\/_-]*
ANYCHAR             [)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -][)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -]*

%%

<string_condition>{ANYCHAR}+     { yylval.string = strdup(yytext); return STRING;}
<string_condition>[\"]           {BEGIN(INITIAL);}

<expansion_condition>{ANYCHAR}+    {   
                                    yylval.string = strdup(yytext); 
                                    
                                    if(ifVarName(yytext)) {
                                        char *yycopy = strdup(getVarTableWord(yytext) );
                                        for ( int i = strlen(getVarTableWord(yytext)) - 1; i >= 0; --i )
                                            unput( yycopy[i] );
                                        free( yycopy );
                                    } else {
                                        yylval.string = strdup(yytext);
                                        return STRING;
                                    };
                                
                                    }
<expansion_condition>[\}]         {BEGIN(INITIAL);}

[ ]		                { }
bye                     { return BYE; }
printenv                { return PRINTENV; }
setenv                  { return SETENV; }
unsetenv                { return UNSETENV; }
cd		                { return CD; }
alias		            { return ALIAS; }
unalias                 { setUnAlias(); 
                            return UNALIAS; }
touch                   { return TOUCH; }
mkdir                   { return MKDIR; }
rm                      { return RM; }
rmdir                   { return RMDIR; }
echo                    { return ECHO; }
date                    { return DATE; }
ls                      { return LS; }
\&                      { return RUNSILENTLY; }
\|                      { return PIPE; }
\>|\<|\>\>|2\>|2\>&1    { return REDIRECT; }
"\n"		            { return END; }
\|                      { return PIPE; }
\>                      { return IOREDIRECT; }
[$\{]                   { BEGIN(expansion_condition); }
[\"]                    { BEGIN(string_condition); }
{CHAR}+                 {   if(isUnalias) {
                                setUnAlias();
                                yylval.string = strdup(yytext);
                                return STRING;
                            }

                            if(ifAlias(yytext)) {
                                printf("yytext: %s\n", yytext);
                                //source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
                                char *yycopy = strdup( subAliases(yytext) );
                                for ( int i = strlen(subAliases(yytext)) - 1; i >= 0; --i )
                                    unput( yycopy[i] );
                                free( yycopy );
                            } else {
                                printf("yytext: %s\n", yytext);
                                yylval.string = strdup(yytext);
                                return STRING;
                            };
                        }
%%