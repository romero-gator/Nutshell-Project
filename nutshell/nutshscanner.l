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
    printf("checking varTable for %s\n", name);
    for (int i = 0; i < varIndex; i++) {
        if(strcmp(varTable.var[i], name) == 0) {
            printf("found %s in varTable\n", name);
            return true;
        }
    }
    printf("%s not found in varTable\n", name);
    return false;
}

char* getVarTableWord(char* name) {
    printf("searching for word associated with: %s\n", name);
    for (int i = 0; i < varIndex; i++) {
        if (strcmp(varTable.var[i], name) == 0) {
            printf("word is: %s\n", varTable.word[i]);
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

CHAR            [.A-Za-z0-9!\/_-][.A-Za-z0-9!\/_-]*
ANYCHAR            [)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -][)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -]*

%%

<string_condition>{ANYCHAR}+     { yylval.string = strdup(yytext); return STRING;}
<string_condition>[\"]           {BEGIN(INITIAL);}

<expansion_condition>{CHAR}+    {   
                                    if (ifVarName(yytext)) {
                                        char *yycopy = strdup( getVarTableWord(yytext) );
                                        for ( int i = strlen(getVarTableWord(yytext)) - 1; i >= 0; --i )
                                            unput( yycopy[i] );
                                        free( yycopy );
                                    }
                                    
                                    return EXPANSION;
                                }
<expansion_condition>\}         {BEGIN(INITIAL);}

[ ]		            { }
$\{                 { BEGIN(expansion_condition); }
bye                 { return BYE; }
printenv            { return PRINTENV; }
setenv              { return SETENV; }
unsetenv            { return UNSETENV; }
cd		            { return CD; }
alias		        { return ALIAS; }
unalias             { setUnAlias(); 
                      return UNALIAS; }
echo                { return ECHO; }
date                { return DATE; }
ls                  { return LS; }
"\n"		        { return END; }
[\"]                { BEGIN(string_condition); }
{CHAR}+             {   if(isUnalias) {
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