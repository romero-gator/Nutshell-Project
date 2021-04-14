%{
// This is ONLY a demo micro-shell whose purpose is to illustrate the need for and how to handle nested alias substitutions and how to use Flex start conditions.
// This is to help students learn these specific capabilities, the code is by far not a complete nutshell by any means.
// Only "alias name word", "cd word", and "bye" run.
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"
#include <dirent.h>
#include <time.h>

int yylex(void);
int yyerror(char *s);
int runCD(char* arg);
int runSetAlias(char *name, char *word);
int printEnv();
int alias();
int setEnv(char *var, char *word);
int unSetEnv(char *var);
int unAlias(char *var);
int echo(char *word);
int list();
int date();
int expansion(char *word);
%}

%union {char *string;}

%start cmd_line
%token <string> BYE PRINTENV UNSETENV CD STRING ALIAS UNALIAS SETENV ECHO LS DATE EXPANSION END 

%%
cmd_line    :
	BYE END 		            	{exit(1); return 1; }
	| PRINTENV END					{printEnv(); return 1;}
	| CD STRING END        			{runCD($2); return 1;}
	| ALIAS END						{alias(); return 1;}
	| ALIAS STRING STRING END		{runSetAlias($2, $3); return 1;}
	| DATE 							{date(); return 1;}
	| UNALIAS STRING END			{unAlias($2); return 1;}
	| ECHO STRING END				{echo($2); return 1;}
	| SETENV STRING STRING END		{setEnv($2, $3); return 1;}
	| UNSETENV STRING END			{unSetEnv($2); return 1;}
	| LS END						{list(); return 1;}
	| EXPANSION END					{expansion($1); return 1;}

%%

int yyerror(char *s) {
  printf("%s\n",s);
  return 0;
  }

int runCD(char* arg) {
	if (arg[0] != '/') { // arg is relative path
		strcat(varTable.word[0], "/");
		strcat(varTable.word[0], arg);

		if(chdir(varTable.word[0]) == 0) {
			return 1;
		}
		else {
			getcwd(cwd, sizeof(cwd));
			strcpy(varTable.word[0], cwd);
			printf("Directory not found\n");
			return 1;
		}
	}
	else { // arg is absolute path
		if(chdir(arg) == 0){
			strcpy(varTable.word[0], arg);
			return 1;
		}
		else {
			printf("Directory not found\n");
                       	return 1;
		}
	}
}

int runSetAlias(char *name, char *word) {
	printf("\n");
	for (int i = 0; i < aliasIndex; i++) {
		if(strcmp(name, word) == 0){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0)){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if(strcmp(aliasTable.name[i], name) == 0) {
			strcpy(aliasTable.word[i], word);
			return 1;
		}
	}
	strcpy(aliasTable.name[aliasIndex], name);
	strcpy(aliasTable.word[aliasIndex], word);
	aliasIndex++;

	return 1;
}

int printEnv() {

	for (int i = 0; i < varIndex; i++) {
		printf(varTable.var[i]);
		printf(" = ");
		printf(varTable.word[i]);
		printf(" \n");
	}

	return 1;
}

int setEnv(char *var, char *word) {

	if(strcmp(var, "PATH") == 0 || strcmp(var, "HOME") == 0) {
		printf("Error: cannot reset/unset PATH or HOME \n");
		return 1;
	}

	for (int i = 0; i < varIndex; i++) { //for each entry already in varTable

		if(strcmp(varTable.var[i], var) == 0) { //check if its the same as name, if same, then update it
			strcpy(varTable.word[i], word);
			return 1;
		}
	}

	//else add new entry to varTable
	strcpy(varTable.var[varIndex], var);
	strcpy(varTable.word[varIndex], word);
	varIndex++;

	return 1;
}

int unSetEnv(char *var) {

	if(strcmp(var, "PATH") == 0 || strcmp(var, "HOME") == 0) {
		printf("Error: cannot reset/unset PATH or HOME \n");
		return 1;
	}

	int unset = 0; //location of index of var to unset
	bool bound = false;

	for (int i = 0; i < varIndex; i++) { //for each entry already in varTable

		if(strcmp(varTable.var[i], var) == 0) { //check if its the same as var, if same, then mark index, check that its bound
			unset = i;
			bound = true;
		}
	}

	if(!bound) { //if not bound, exit
		return 1;
	}

	if(unset == varIndex - 1){ //if we're unbinding last variable in table, just decrement varindex
		varIndex--;
		return 1;
	} else {

		//else starting moving everything after the character forward

		for(int i = unset; i<varIndex-1; i++) {
			strcpy(varTable.var[i], varTable.var[i+1]);
			strcpy(varTable.word[i], varTable.word[i+1]);
		}

		varIndex--;

	}

	return 1;
}

int alias() {

	for (int i = 0; i < aliasIndex; i++) {
		printf(aliasTable.name[i]);
		printf(" = ");
		printf(aliasTable.word[i]);
		printf(" \n");
	}

	return 1;
}

int unAlias(char *name) {

	int unset = 0;
	bool bound = false;

	printf(name); 
	printf("\n");

	for (int i = 0; i < aliasIndex; i++) {

		if(strcmp(aliasTable.name[i], name) == 0) {
			unset = i;
			bound = true;
		}
	}

	if(!bound) {
		return 1;
	}

	if(unset == aliasIndex-1){
		aliasIndex--;
		return 1;
	} else {

		for(int i = unset; i < aliasIndex-1; i++){
			strcpy(aliasTable.name[i], aliasTable.name[i+1]);
			strcpy(aliasTable.word[i], aliasTable.word[i+1]);
		}
		aliasIndex--;
	}
	return 1;

}

int echo(char* word) {
	printf(word);
	printf("\n");
	return 1;
}

int list() {
	DIR *dir;
    struct dirent *de;

    dir = opendir(".");
    while(dir)
    {
        de = readdir(dir);
        if (!de) break;
        printf("%s\n", de->d_name);
    }

    closedir(dir);
	return 1;
}

int date() {
	time_t rawtime;
  	struct tm * timeinfo;

  	time( &rawtime );
  	timeinfo = localtime ( &rawtime );
  	printf("Time and date: %s", asctime(timeinfo));
	return 1;
}

int expansion(char *word) {
	
	printf("bison expansion call: %s\n");

	return 1;
}
