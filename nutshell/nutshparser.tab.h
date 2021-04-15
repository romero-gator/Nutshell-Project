/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     BYE = 258,
     PRINTENV = 259,
     UNSETENV = 260,
     CD = 261,
     STRING = 262,
     ALIAS = 263,
     UNALIAS = 264,
     SETENV = 265,
     ECHO = 266,
     LS = 267,
     DATE = 268,
     TOUCH = 269,
     MKDIR = 270,
     RM = 271,
     RMDIR = 272,
<<<<<<< HEAD
     PIPE = 273,
     IOREDIRECT = 274,
     END = 275
=======
     CAT = 273,
     END = 274
>>>>>>> b06c78e87c6e51b9f382123c3a50b848e8ddc89f
   };
#endif
/* Tokens.  */
#define BYE 258
#define PRINTENV 259
#define UNSETENV 260
#define CD 261
#define STRING 262
#define ALIAS 263
#define UNALIAS 264
#define SETENV 265
#define ECHO 266
#define LS 267
#define DATE 268
#define TOUCH 269
#define MKDIR 270
#define RM 271
#define RMDIR 272
<<<<<<< HEAD
#define PIPE 273
#define IOREDIRECT 274
#define END 275
=======
#define CAT 273
#define END 274
>>>>>>> b06c78e87c6e51b9f382123c3a50b848e8ddc89f




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
<<<<<<< HEAD
#line 34 "nutshparser.y"
{char *string;}
/* Line 1529 of yacc.c.  */
#line 91 "nutshparser.tab.h"
=======
#line 33 "nutshparser.y"
{char *string;}
/* Line 1529 of yacc.c.  */
#line 89 "nutshparser.tab.h"
>>>>>>> b06c78e87c6e51b9f382123c3a50b848e8ddc89f
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

