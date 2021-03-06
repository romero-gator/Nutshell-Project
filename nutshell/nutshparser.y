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
#include <sys/stat.h>
#include <sys/wait.h>

int yylex(void);
int yyerror(char *s);
char* breakUpPathAndSearch(char *cmdName);
char* searchPath(char *basePath, const int root, char *cmdName);
int pipeCommands(char *cmd1, char *cmd2);
int putCmdInTable(char *name);
int putArgsInTable(char *name);
int runCmds();
int checkBuiltIn(char* name);
int seeCmd();
int runCD(char* arg);
int runSetAlias(char *name, char *word);
int printEnv();
int alias();
int setEnv(char *var, char *word);
int unSetEnv(char *var);
int unAlias(char *var);
%}

%union {
	char *string;
}
%type <string> line word stmt
%token <string> STRING PIPE ALIAS UNALIAS SETENV REDIRECT RUNSILENTLY LSCMD PRINTENV UNSETENV RUN CD BYE END

%%
input    :
	/* empty */
	| input line	
	;

line	:
	LSCMD END						{seeCmd(); return 1;}
	| RUN END						{runCmds(); return 1;}
	| SETENV STRING STRING END		{setEnv($2, $3); return 1;}
	| PRINTENV END					{printEnv(); return 1;}
	| UNSETENV STRING END			{unSetEnv($2); return 1;}
	| ALIAS END						{alias(); return 1;}
	| ALIAS STRING STRING END		{runSetAlias($2, $3); return 1;}
	| UNALIAS STRING END			{unAlias($2); return 1;}
	| BYE END     					{exit(1); return 1;}
	| CD STRING END        			{runCD($2); return 1;}
	| END							{ return 1;}				
	| stmt END						{ runCmds(); return 1;}	
	;

stmt	:
	word
	| stmt RUNSILENTLY				{printf("RUN IN BACKGROUND\n")}
	| stmt PIPE stmt				{printf("PIPE COMMANDS\n");}
	| stmt REDIRECT stmt			{printf("REDIRECT IO\n");}

word	:
	STRING 							{ putCmdInTable($1); }
	| word STRING 					{ putArgsInTable($2); }
	;

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

// This function probably needs to be implemented in nutshell.c once the command table
// is filled with cmds args flags pipes etc. and ready to be executed using execve()
int pipeCommands(char *cmd1, char *cmd2) {
	int fd[2];
	if (pipe(fd) == -1) {
		printf("ERROR 1\n");
		return 1;
	}

	int pid1 = fork();
	if (pid1 < 0) {
		printf("ERROR 2\n");
		return 1;
	}

	if (pid1 == 0) {
		dup2(fd[1], STDOUT_FILENO);
		close(fd[0]);
		close(fd[1]);
		execv(cmd1, NULL);
	}

	int pid2 = fork();
	if (pid2 < 0) {
		printf("ERROR 3\n");
		return 1;
	}

	if (pid2 == 0) {
		dup2(fd[0], STDIN_FILENO);
		close(fd[0]);
		close(fd[1]);
		execv(cmd2, NULL);
	}

	close(fd[0]);
	close(fd[1]);

	waitpid(pid1, NULL, 0);
	waitpid(pid2, NULL, 0);
	return 1;
}

char* breakUpPathAndSearch(char *cmdName) {
	char *ret = cmdName;
	char *pathVar;
	strcpy(pathVar, varTable.word[3]);
	pathVar = strtok(pathVar, ":");
	while (pathVar != NULL) {
		ret = searchPath(pathVar, 0, cmdName);
		if (ret != cmdName)
			break;
		pathVar = strtok(NULL, ":");
	}
	
	return ret;
}

char* searchPath(char *basePath, const int root, char *cmdName)
{
	char *ret = cmdName;
    char path[1000];
    struct dirent *dp;
    DIR *dir = opendir(basePath);

    if (!dir) {
		return ret;
	}

    while ((dp = readdir(dir)) != NULL)
    {
        if (strcmp(dp->d_name, ".") != 0 && strcmp(dp->d_name, "..") != 0)
        {
            strcpy(path, basePath);
            strcat(path, "/");
            strcat(path, dp->d_name);
			if (strcmp(dp->d_name, cmdName) == 0) {
				ret = path;
				break;
			}

            ret = searchPath(path, root + 2, cmdName);
        }
    }

    closedir(dir);
	return ret;
}

int putArgsInTable(char* name) {
	strcpy(cmdTable.cmdList[cmdListIndex - 1].args[cmdTable.cmdList[cmdListIndex - 1].argIndex], name);
	cmdTable.cmdList[cmdListIndex - 1].argIndex++;
	return 1;
}

int putCmdInTable(char *name) {
	strcpy(cmdTable.cmdList[cmdListIndex].name, name);

	// Clear the args that may be there from cmds run before it and reset argindex
	for (int i = 0; i < cmdTable.cmdList[cmdListIndex].argIndex; i++) {
		cmdTable.cmdList[cmdListIndex].args[i][0] = '\0';
	}
	cmdTable.cmdList[cmdListIndex].argIndex = 0;

	cmdListIndex++;
	return 1;
}

int runCmds() {
	
	for (int i = 0; i < cmdListIndex; i++) {
		printf(""); 
		char* pathVar = breakUpPathAndSearch(cmdTable.cmdList[i].name);
		if (strcmp(pathVar, cmdTable.cmdList[i].name) != 0) {
			int pid1 = fork();
			//printf("PID: %d \n", pid1);
			if (pid1 < 0) {
				printf("ERROR\n");
				return 1;
			}
			if (pid1 == 0) {
				char* path = malloc(strlen("/bin/") + strlen(cmdTable.cmdList[i].name) + 1);

				//MAKE PATH NAME
				strcpy(path, "/bin/");
				strcat(path, cmdTable.cmdList[i].name);



				//MAKE CHARACTER ARRAY
				char* arg[cmdTable.cmdList[i].argIndex+2]; //array of args
				arg[0] = cmdTable.cmdList[i].name; //first arg is function name 
				for(int j = 1; j< cmdTable.cmdList[i].argIndex+1; j++){
					arg[j] = cmdTable.cmdList[i].args[j-1]; 			
				}

				//SET LAST ONE TO NULL
				arg[cmdTable.cmdList[i].argIndex+1] = NULL;

				//RUN EXECV
				int status = execv(path, arg);
				free(path);			
			}
			waitpid(pid1, NULL, 0);

		}
		
	}

	cmdListIndex = 0;	//reset once everything run
	
	return 1;
}

int checkBuiltIn(char* name) {
	return 1;
}

int seeCmd(){

	for(int i = 0; i<cmdListIndex; i++){
        printf("Command: %s  Args: ", cmdTable.cmdList[i].name);
        for(int j = 0; j<cmdTable.cmdList[i].argIndex; j++){
            printf("  %s  ", cmdTable.cmdList[i].args[j]);
        }
        printf("\n");
    }

    return 1;
}
