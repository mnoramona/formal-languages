/* Mitran Ramona Luminita 333CC - Varianta A*/

%option stack

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int word_count = 0;

int itemize_level = 0;

int *item_count; // vector de itemi pentru fiecare nivel de imbricare
int item_count_size = 0; // dimensiunea vectorului de itemi

%}

 // Declarare stari

 // titlul documentului
%x TITLE 

 // orice titlu de sectiune
%x SECTION

 // comenzile \textbf, \textit, \emph, \texttt
 // bold
%x TEXTBF

 // italic
%x TEXTIT

 // emphasized
%x EMPH

 // code
%x TEXTTT

 // mediul quotation se converteste la un blockquote
%x QUOTATION

 // continutul dintr-un mediul verbatim se converteste intr-un bloc de cod
%x VERBATIM

 // o lista de tip itemize se converteste intr-o lista neordonata
%x ITEMIZE
%x ITEM

 // o lista de tip enumerate se converteste intr-o lista ordonata
%x ENUMERATE

 // pentru liste, se vor suporta oricate nivele de imbricare
%x LIST

 // un link obtinut prin comanda \href se converteste intr-un link
%x HREF

 // orice alta comanda nu va afisa nimic
%x COMMAND

 // comentariile LATEX nu vor aparea la iesire
%x COMMENT

 // textul continut intre acolade (in afara de comenzile de mai sus) nu se va afisa
%x HREFNAME

 // pentru orice alt mediu, directivele de inceput si de sfarsit vor fi ignorate si continutul lor se va afisa 
 // prelucrat conform regulilor enuntate.
%x OTHER

Section \\[a-zA-Z0-9]*section
Word [a-zA-Z0-9ăâîșțĂÂÎȘȚ]+
 // Declarare reguli

%%
 // Reguli pentru starea initiala
<INITIAL>"\\title" { yy_push_state(TITLE); }
<INITIAL>{Section} { yy_push_state(SECTION); }


<INITIAL>"\\textbf" { yy_push_state(TEXTBF); }
<INITIAL>"\\textit" { yy_push_state(TEXTIT); }
<INITIAL>"\\emph" { yy_push_state(EMPH); }
<INITIAL>"\\texttt" { yy_push_state(TEXTTT); }
<INITIAL>"\\href" { yy_push_state(HREF); }

<INITIAL,ITEMIZE,ENUMERATE,SECTION>"\\textbf" { yy_push_state(TEXTBF); }
<INITIAL,ITEMIZE,ENUMERATE>"\\textit" { yy_push_state(TEXTIT); }
<INITIAL,ITEMIZE,ENUMERATE>"\\emph" { yy_push_state(EMPH); }
<INITIAL,ITEMIZE,ENUMERATE>"\\texttt" { yy_push_state(TEXTTT); }
<INITIAL,ITEMIZE,ENUMERATE>"\\href" { yy_push_state(HREF); }
<INITIAL,ITEMIZE,ENUMERATE>"% " { yy_push_state(COMMENT); }


<INITIAL>"\\begin{quotation}" {
    word_count = 0;
    yy_push_state(QUOTATION);
} 

<INITIAL>"\\begin{verbatim}" {
    yy_push_state(VERBATIM);
}

<INITIAL>"\\begin{itemize}" {
    printf("\n");
    yy_push_state(ITEMIZE);
}

<INITIAL>"\\begin{enumerate}" {
    if (item_count_size == 0) {
        item_count = (int*)malloc(sizeof(int));
    }
    item_count_size = 1;
    item_count[0] = 0;
    itemize_level = 0;
    yy_push_state(ENUMERATE);
}

<INITIAL>"%" { 
    yy_push_state(COMMENT);
}


<INITIAL>.|\n {
    printf("%s", yytext);
}

<TITLE>"{" { }
<TITLE>[a-zA-Z0-9ăâîșțĂÂÎȘȚ -.,:;?!&*()]* { printf("%s\n==========\n", yytext); }
<TITLE>"}" { yy_pop_state(); }

<SECTION>"{" { }
<SECTION>[a-zA-Z0-9ăâîșțĂÂÎȘȚ -.,:;?!&*()]* { printf("\n%s\n----------\n", yytext); }
<SECTION>"}" { yy_pop_state(); }



<TEXTBF>"{" { printf("**"); }
<TEXTBF>[^{}]* { printf("%s", yytext); }
<TEXTBF>"}" { printf("**"); yy_pop_state(); }

<TEXTIT>"{" { printf("_"); }
<TEXTIT>[^{}]* { printf("%s", yytext); }
<TEXTIT>"}" { printf("_"); yy_pop_state(); }

<EMPH>"{" { printf("*"); }
<EMPH>[^{}]* { printf("%s", yytext); }
<EMPH>"}" { printf("*"); yy_pop_state(); }

<TEXTTT>"{" { printf("`"); }
<TEXTTT>[A-Za-z0-9 ]* { printf("%s", yytext); }
<TEXTTT>"}" { printf("`"); yy_pop_state(); }

<HREF>"{" { printf("["); }
<HREF>[^{}]* {
    char* token = strtok(yytext, "}{");
    while (token != NULL) {
        printf("%s", token);
        token = strtok(NULL, "}{");
    }
}
<HREF>"}" { printf("]"); BEGIN(HREFNAME); }

<HREFNAME>"{}" { }
<HREFNAME>"{" { printf("("); }
<HREFNAME>[a-zA-Z0-9]* { printf("%s", yytext); }
<HREFNAME>"}" { printf(")"); yy_pop_state(); }
<HREFNAME>. { yymore(); }

<TITLE,SECTION,TEXTBF,TEXTIT,EMPH,TEXTTT>. { yymore(); }

<QUOTATION>"\\end{quotation}" {
    yy_pop_state();
}

<QUOTATION>[^\\\n]+ {
    word_count = 0;
    char* token = strtok(yytext, " \t\n");
    
    while (token != NULL) {
        if (word_count == 0) {
            printf("> ");
        }
        word_count++;
        if (word_count > 10) {
            printf("\n");
            word_count = 0;
        } else {
            printf("%s ", token);
            token = strtok(NULL, " \t\n");
        }
    }
}

<QUOTATION>"\n" {
    printf("\n");
    word_count = 0;
}

<QUOTATION>. {
    yymore();
}

<VERBATIM>"\\end{verbatim}" {
    yy_pop_state();
}

<VERBATIM>\n {
    printf("\t%s", yytext);
}

<VERBATIM>. {
    yymore();
}

<ITEMIZE>"\\begin{itemize}" {
    itemize_level++;
    yy_push_state(ITEMIZE);
}

<ITEMIZE>"\\end{itemize}" {
    itemize_level--;
    yy_pop_state();
}

<ITEMIZE>"\\item[ ]*\\begin{itemize}" {
    itemize_level++;
    yy_push_state(ITEMIZE);
}

<ITEMIZE>"\\item" {
    for (int i = 0; i < itemize_level; i++) {
        printf("\t");
    }
    printf("- ");
}

<ITEMIZE>. {
    printf("%s", yytext);
}

<ENUMERATE>"\\begin{enumerate}" {
    itemize_level++;
    yy_push_state(ENUMERATE);
}

<ENUMERATE>"\\end{enumerate}" {
    itemize_level--;
    yy_pop_state();
}

<ENUMERATE>"\\item[ ]*\\begin{enumerate}" {
    itemize_level++;
    if (item_count_size < itemize_level) {
        item_count = (int*)realloc(item_count, itemize_level * sizeof(int));
        item_count_size = itemize_level;
    }
    item_count[itemize_level] = 0;
}

<ENUMERATE>"\\item" {
    for (int i = 0; i < itemize_level; i++) {
        printf("\t");
    }
    item_count[itemize_level]++;
    printf("%d. ", item_count[itemize_level]);
}

<ENUMERATE>\n {
    printf("%s", yytext);
}

<ENUMERATE>. {
    yymore();
}

<COMMENT>\n {
    yy_pop_state();
}

<COMMENT>. {
    // do nothing
}

.|\n { }


%%

main (int arqc, char **argv)
{
    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        printf("Eroare la deschiderea fisierului de intrare!\n");
        exit(1);
    }
    yylex();
}