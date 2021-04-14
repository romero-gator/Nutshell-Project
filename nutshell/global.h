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

struct cTable {
   char cmd[128][100];
   char arg[128][100];
};

char cwd[PATH_MAX];

struct evTable varTable;

struct aTable aliasTable;

struct cTable cmdTable;

int aliasIndex, varIndex, cmdIndex;

char* subAliases(char* name);