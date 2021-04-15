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

struct pipeline {
   struct command cmdList[20];
   bool background;
};
struct command {
   char *name;
   char args[128][100];
   char *input;
   char *output;
};

char cwd[PATH_MAX];

struct evTable varTable;

struct aTable aliasTable;

struct pipeline cmdTable;

int aliasIndex, varIndex, cmdListIndex;

char* subAliases(char* name);