README

Nutshell Project
by Antonio Romero and Matina Mahasantipiya

Features we DIDN’T implement:
        IO Redirection
        Piping Commands
        Wildcard Matching
        Execute Command in Background (&)


Features we DID implement:
        Built-In Commands
                setenv
                printenv
                cd
                alias
                unalias
                bye
        Bison Recursive Rules
        Command Table
        Non-Built-In Commands by Searching PATH Variable and using execv


Declaration of what each team member did:
        Antonio Romero:
                Bison recursion
                Command Table
                Non Built-In commands (searching PATH variable)
        Matina Mahasantipiya:
                Built-In Commands
                Non Built-In commands (creating argv array and using execv)
