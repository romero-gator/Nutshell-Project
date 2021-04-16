#include "stdbool.h"
#include <limits.h>

struct evTable {
   char var[128][100];
   char word[128][100];
};

struct aTable {
	char name[128][100];
	char word[128][100];
};

struct command {
   char name[15];
   char args[10][10];
   int argIndex;
};
struct pipeline {
   struct command cmdList[5];
   bool background;
};


char cwd[PATH_MAX];

struct evTable varTable;

struct aTable aliasTable;

struct pipeline cmdTable;

int aliasIndex, varIndex, cmdListIndex;

char* subAliases(char* name);