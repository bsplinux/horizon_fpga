/*****************************************************************************

File name   : clilib.h

Description : command line interpreter



*****************************************************************************/
#ifndef __CLILIB_H
#define __CLILIB_H

#ifdef __cplusplus
extern "C" {
#endif


#define SPACE_CHAR  0x20
#define TAB_CHAR    0x09
#define ESCAPE_CHAR '\\'
#define NL_CHAR     '\n'
#define CR_CHAR     '\r'
#define COMMENT_CHAR ';'        /* semi-colon equals a comment */
#define BAD_INT_VAL  (int) 0x98738216
#define NO_CONST     0
#define DEFINE_CONST 1
#define IF_CONST     2
#define ELSE_CONST   3
#define WHILE_CONST  4
#define FOR_CONST    5

#define MAX_TOK_LEN 80
#define MAX_LINE_LEN 255
#define NO_TOKEN    0

/* tokeniser data structure ----------------------------------------------- */
struct parse
{
    char           *line_p;     /* string under examination  */
	short             par_pos;    /* index of cur position,  delimiter or EOL */
    short             par_sta;    /* index start position for last operation  */
    short             tok_len;    /* length of identified token */
    char            tok_del;    /* delimit of current token */
    char            token[MAX_TOK_LEN];     /* actual token found,uppercase */
};
typedef struct parse parse_t;

/* macro store structure -------------------------------------------------- */
struct macro
{
    struct macro   *line_p;
    char            line[MAX_LINE_LEN];
};
typedef struct macro macro_t;

/* symbol table data structure and types ---------------------------------- */
#define NO_SYMBOL  0
#define INT_SYMBOL 1            /* integer symbol                           */
#define FLT_SYMBOL 2            /* floating point symbol                    */
#define STR_SYMBOL 4            /* string symbol                            */
#define COM_SYMBOL 8            /* command symbol                           */
#define MAC_SYMBOL 16           /* macro symbol                             */
#define ANY_SYMBOL 0xff         /* matches all symbol types                 */

struct symtab
{
    char           *name_p;     /* symbol id                                */
    short             type;       /* type of symbol                           */
    short             name_len;   /* length of symbol name                    */
    union
    {
        int             int_val;
        double          flt_val;
        char           *str_val;
                        int (*com_val) (parse_t *, char *);
        macro_t        *mac_val;
    }
    value;                      /* value of symbol                          */
    int            fixed;      /* flag for symbol                          */
    short             depth;      /* nesting depth at which declaration made  */
    char           *info_p;     /* informational string                     */
};
typedef struct symtab symtab_t;

/* --- Private Types ------------------------------------------------------ */
int            read_input (char *line_p, char *ip_prompt_p);
int            is_matched (char *tested_p, char *definition_p, short minlen);
int             conv_int (char *token_p, short default_base);
int            conv_flt (char *token_p, double * value_p);
void            init_pars (parse_t * pars_p, char *new_line_p);
void            cp_pars (parse_t * dest_p, parse_t * source_p);
short             get_tok (parse_t * pars_p, char *delim_p);
//void            cli_init (int (*setup_r) (), int max_symbols, short default_base);
void            cli_run (char *ip_prompt_p, char *file_p);
int             io_write (char *buffer);
int             io_write_uart (char *buffer);
int             io_write_console (char *buffer);
int             pollkey_uart (void);
int             pollkey_console (void);
int             io_read (char *prompt, char *buffer, int buflen);
int             io_read_uart (char *prompt, char *buffer, int buflen);
int             io_read_console (char *prompt, char *buffer, int buflen);
void            io_setup (void);
int             readkey (void);

int            cget_integer (parse_t * pars_p, int def_int, int * result_p);
int            cget_string (parse_t * pars_p, char *default_p, char *result_p,short max_len);
int            cget_float (parse_t * pars_p, double def_flt, double * result_p);
int            execute_command_line (char *line_p, char *target_p, int * result_p);
int            register_command (char *token_p, int (*action) (parse_t *, char *),char *help_p);
void           cli_init (int (*setup_r) (), int max_symbols, short default_base);

int            TesttoolInit (void);
int            TesttoolRun (void);
void           print(const char *format,...);

#ifdef __cplusplus
}
#endif
#endif
