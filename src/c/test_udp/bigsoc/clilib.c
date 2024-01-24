/*****************************************************************************

File name   : Clilib.C

Description : Command line interpreter


*****************************************************************************/
/* Includes --------------------------------------------------------------- */
#include <stdio.h>              /* standard inputs                          */
#include <stdlib.h>             /* */
#include <string.h>             /* for string manipulations                 */
#include <stdarg.h>             /* for argv argc                            */
#include <ctype.h>              /* */
/* --- Device specific Includes ------------------------------------------- */

typedef double DOUBLE;
#include "clilib.h"             /* local API                                */



/* for gcc only ----------------------------------------------------------- */
#ifndef FILENAME_MAX
#define FILENAME_MAX 64
#endif

/* Local defines ---------------------------------------------------------- */
static symtab_t **symtab_p;     /* symbol table pointer             */
static int      max_symbol_cnt; /* maximum number of symbols        */
static int      symbol_cnt;     /* number of symbols declared       */
static short      macro_depth;    /* macro invocation depth           */
static short      number_base;    /* default inp/output base for ints */
static char    *cur_stream_p;   /* current file ip stream           */
static macro_t *cur_macro_p;    /* current macro position           */
static char    *prompt_p;       /* input prompt                     */
static int     cur_echo;       /* status of input echo             */
//static char     format_buf[256];    /* limited output length        */

int            is_delim (char character, char *delim_p);
int            is_control (char *token_p, short * construct_p);
int             conv_int (char *token_p, short default_base);
int            conv_flt (char *token_p, double * value_p);
symtab_t       *look_for (char *token_p, short type);
void            tag_current_line (parse_t * pars_p, char *message_p);
void            pars_debug (parse_t * pars_p);
void            init_pars (parse_t * pars_p, char *new_line_p);
void            cp_pars (parse_t * dest_p, parse_t * source_p);
short             get_tok (parse_t * pars_p, char *delim_p);

static char     delim_set[] = " ,\\";

int  define_macro(char * tok,char *m2){
  return 0;
}

/* ========================================================================
   indirect print method using variable arg format to invoke formatting
   ======================================================================== */
void            print (const char *format,...)
{

    va_list         list;
    char format_buf[200];
    va_start (list, format);
    vsprintf (format_buf, format, list);
    io_write (format_buf);
    va_end (list);

}


#if 0
/* ========================================================================
   indirect 'scanf' function from uart or console
   ======================================================================== */
int             scan (const char *format, void *Variable)
{
    int             i;
    char            ip_char[256];

    for (i = 0; i < 256; i++)
        ip_char[i] = 0;
    read_input (ip_char, "?> ");
    sscanf (ip_char, format, Variable);
    return (1);
}

#endif

/* ========================================================================
   tests the character for equality with a set of delimiter characters
   ======================================================================== */
int            is_delim (char character, char *delim_p)
{
    short             delim_count = 0;

    while ((delim_p[delim_count] != '\0') &&
           (character != delim_p[delim_count]))
        delim_count++;
    return ((character == delim_p[delim_count]) ||
            (character == NL_CHAR) ||
            (character == CR_CHAR) ||
            (character == '\0'));
}
/* ========================================================================
   tests strings for equality, but not in an exact way. Trailing space is OK
   Comparison will succeed if the tested string matches the definition string
   but is shorter (i.e is an abbreviation). It will not match if the tested
   string is longer or less than minlen chars are present in the tested
   string. Comparison is also case insensitive.
   ======================================================================== */
int            is_matched (char *tested_p, char *definition_p, short minlen)
{
    int            match = 1;
    short             cnt = 0;

    while (((tested_p[cnt] == definition_p[cnt]) ||
            ((tested_p[cnt] & 0xdf) == (definition_p[cnt] & 0xdf))) &&
           (tested_p[cnt] != '\0') &&
           (definition_p[cnt] != '\0'))
        cnt++;

    /* if we found the end of the tested string before we found a mis-match
       then strings are matched. If the definition string is shorter than
       minumum length requirements, then match can succeed. */
    if ((tested_p[cnt] != '\0') ||
        ((cnt < minlen) && (definition_p[cnt] != '\0')))
        match = 0;

    return (match);
}

/* ========================================================================
   tests a token against a set of control redirection primitives
   and returns an identifier for the construct found
   ======================================================================== */
int            is_control (char *token_p, short * construct_p)
{
    int            found = 1;

    if (is_matched (token_p, "DEFINE", 2))
        *construct_p = DEFINE_CONST;
    else if (is_matched (token_p, "IF", 2))
        *construct_p = IF_CONST;
    else if (is_matched (token_p, "ELSE", 2))
        *construct_p = ELSE_CONST;
    else if (is_matched (token_p, "WHILE", 2))
        *construct_p = WHILE_CONST;
    else if (is_matched (token_p, "FOR", 2))
        *construct_p = FOR_CONST;
    else
        found = 0;
    return (found);
}
/* ========================================================================
   returns, if possible, an integer value. The default base
   is used for conversion in the absence of other information.
   If a '#' character preceeds the number hex base is assumed
   If a '$' is used as a prefix, then a binary representation is assumed
   If an 'o' or 'O' character is used then octal is assumed.
   Any sign makes the number a decimal representation
   ======================================================================== */
int             conv_int (char *token_p, short default_base)
{
    int             value;
    short             base, cnt;
    int            negative;
    static char    *conv = "0123456789ABCDEF";

    negative = 0;
    if (token_p[0] == '#')
    {
        token_p++;
        base = 16;
    }
    else if (token_p[0] == '$')
    {
        token_p++;
        base = 2;
    }
    else if (token_p[0] == 'o')
    {
        token_p++;
        base = 8;
    }
    else if (token_p[0] == 'O')
    {
        token_p++;
        base = 8;
    }
    else if (token_p[0] == '-')
    {
        token_p++;
        negative = 1;
        base = 10;
    }
    else if (token_p[0] == '+')
    {
        token_p++;
        base = 10;
    }
    else
        base = default_base;

    /* convert by comparison to ordered string array of numeric characters */
    value = 0;
    cnt = 0;
/*    while ((token_p[cnt] != '\0') && (value > BAD_INT_VAL)) */
    while ((token_p[cnt] != '\0') && ( value != BAD_INT_VAL) )
    {
        short             i = 0;

        while ((conv[i] != (char) toupper (token_p[cnt])) && (i < base))
            i++;
/*        if ((i >= base) || (value >= (int) 0x7fffffff) ||
            ((value >= 214748364) && (i >= 8))) */
            if ( i >= base )
            value = BAD_INT_VAL;
        else
            value = (value * base) + i;
        cnt++;
    }
/*    if (negative && (value > BAD_INT_VAL)) */
      if (( negative ) && ( value != BAD_INT_VAL) )
        value = -value;

    return (value);
}
/* ========================================================================
   returns, if possible, an floating point value. Scanf seems not to
   detect any errors in its input format, and so we have to do a check
   on number validity prior to calling it. This is rather complicated
   to try and reject float expressions, but validate pure float numbers
   ======================================================================== */
int            conv_flt (char *token_p, double * value_p)
{
    short             cnt = 0;
    int            error = 0;
    int            seen_dp = 0;

    while ((token_p[cnt] != '\0') && !error)
    {
        /* check for silly characters */
        if ((token_p[cnt] != '-') &&
            (token_p[cnt] != '+') &&
            (token_p[cnt] != '.') &&
            (token_p[cnt] != 'E') &&
            (token_p[cnt] != 'e') &&
            ((token_p[cnt] > '9') || (token_p[cnt] < '0')))
            error = 1;
        /* check for more than one decimal point */
        if (token_p[cnt] == '.')
        {
            if (seen_dp)
                error = 1;
            else
                seen_dp = 1;
        }
        /* check for sign after decimal point not associated with exponent */
        if (((token_p[cnt] == '+') || (token_p[cnt] == '-')) && seen_dp)
        {
            if ((token_p[cnt - 1] != 'E') && (token_p[cnt - 1] != 'e'))
                error = 1;
        }
        /* check for sign before a decimal point but not at start of token */
        if (((token_p[cnt] == '+') || (token_p[cnt] == '-')) && !seen_dp)
        {
            if (cnt > 0)
                error = 1;
        }
        cnt++;
    }
    if (error || (sscanf (token_p, "%lg", value_p) == 0))
        *value_p = BAD_INT_VAL;

    return (error);
}
/* ========================================================================
   looks for a symbol type/name within the table. We look from
   most recent to oldest symbol to accomodate scope.
   We also scan for the shortest defined symbol that matches
   the input token - this resolves order dependent declaration problems
   ======================================================================== */
symtab_t       *look_for (char *token_p, short type)
{
    short             cnt;
    int            found = 0;
    symtab_t       *symbol_p;
    symtab_t       *shortest_p;
    short             short_len;

    short_len = MAX_TOK_LEN;
    shortest_p = (symtab_t *) NULL;

    /* point to last symbol in the table */
    if (symbol_cnt != 0)
    {
        cnt = 1;
        while (cnt <= symbol_cnt)
        {
            symbol_p = symtab_p[symbol_cnt - cnt];
            /* protect against deleted symbols */
            if (symbol_p->name_p != NULL)
            {
                /* look for a name match of at least two characters and
                   shortest matching definition of search type */
                found = ((is_matched (token_p, symbol_p->name_p, 2) &&
                          ((symbol_p->type & type) > 0)));
                if (found && (symbol_p->name_len < short_len))
                {
                    shortest_p = symbol_p;
                    short_len = symbol_p->name_len;
                }
            }
            cnt++;
        }
    }
    return (shortest_p);
}
/* ========================================================================
   displays current tokeniser string and tags the position of last token.
   An optional message is displayed
   ======================================================================== */
void            tag_current_line (parse_t * pars_p, char *message_p)
{
    char            tag[120];
    short             i;

    print ("%s\n", message_p);
    return ;
    print ("%s\n", pars_p->line_p);
    for (i = 0; i < pars_p->par_pos; i++)
        tag[i] = SPACE_CHAR;
    tag[pars_p->par_pos] = '^';
    tag[pars_p->par_sta] = '^';
    tag[(pars_p->par_pos) + 1] = '\0';
    print ("%s\n%s\n", tag, message_p);
}
/* ========================================================================
   included for tokeniser testing
   ======================================================================== */
void            pars_debug (parse_t * pars_p)
{
    tag_current_line (pars_p, "debug");
    print ("Tok = \"%s\", delim = %x, toklen = %d \n",
           pars_p->token,
           pars_p->tok_del,
           pars_p->tok_len);
}
/* ========================================================================
   start up a new environment
   ======================================================================== */
void            init_pars (parse_t * pars_p, char *new_line_p)
{
    pars_p->line_p = new_line_p;
    pars_p->par_pos = 0;
    pars_p->par_sta = 0;
    pars_p->tok_del = '\0';
    pars_p->token[0] = '\0';
    pars_p->tok_len = 0;
}
/* ========================================================================
   copies parsing status
   ======================================================================== */
void            cp_pars (parse_t * dest_p, parse_t * source_p)
{
    *dest_p = *source_p;
}
/* ========================================================================
   implements a tokeniser with a 'soft' approach to end of line conditions
   repeated calls will eventually leave parse position at the null
   terminating the input string.
   ======================================================================== */
short             get_tok (parse_t * pars_p, char *delim_p)
{
    short             par_sta = pars_p->par_pos;
    short             par_pos = par_sta;
    short             tok_len = 0;
    short             quotes = 0;

    /* check that we are not already at the end of a line due to a previous
       call (or a null input) - if so return a null token  End of line now
       includes finding comment character! */

    if ((pars_p->line_p[par_pos] == '\0') ||
        (pars_p->line_p[par_pos] == COMMENT_CHAR))
    {
        pars_p->token[0] = '\0';
        pars_p->tok_del = '\0';
    }
    else
    {
        /* attempt to find start of a token, noting special case of first
           call, incrementing past last delimiter and checking for end of
           line on the way */
        if (par_pos != 0)
            par_pos++;
        while (((pars_p->line_p[par_pos] == SPACE_CHAR) ||
                (pars_p->line_p[par_pos] == TAB_CHAR)) &&
               (pars_p->line_p[par_pos] != '\0') &&
               (pars_p->line_p[par_pos] != COMMENT_CHAR))
            par_pos++;

        /* if we find a delimiter before anything else, return a null token
           also deal with special case of a comment character ending a line */
        if (is_delim (pars_p->line_p[par_pos], delim_p) ||
            (pars_p->line_p[par_pos] == COMMENT_CHAR))
        {
            pars_p->token[0] = '\0';
            if (pars_p->line_p[par_pos] != COMMENT_CHAR)
                pars_p->tok_del = pars_p->line_p[par_pos];
            else
                pars_p->tok_del = '\0';
        }
        else
        {
            /* copy token from line into token string until next delimiter
               found. Note that delimiters found within pairs of DOUBLE
               quotes will not be considered significant. Quotes can be
               embedded within strings using '\' however. Note also that we
               have to copy the '\' escape char where it is used, it can be
               taken out when the string is evaluated */
            while ((!is_delim (pars_p->line_p[par_pos], delim_p) || (quotes > 0)) &&
                   (tok_len < MAX_TOK_LEN) && (pars_p->line_p[par_pos] != '\0'))
            {
                pars_p->token[tok_len] = pars_p->line_p[par_pos++];
                if ((pars_p->token[tok_len] == '"') && (tok_len == 0))
                    quotes++;
                if ((pars_p->token[tok_len] == '"') && (tok_len > 0))
                {
                    if (pars_p->token[tok_len - 1] != ESCAPE_CHAR)
                    {
                        if (quotes > 0)
                            quotes--;
                        else
                            quotes++;
                    }
                }
                tok_len++;
            }
            /* if we ran out of token space before copy ended, move up to
               delimiter */
            while (!is_delim (pars_p->line_p[par_pos], delim_p))
                par_pos++;

            /* tidy up the rest of the data */
            pars_p->tok_del = pars_p->line_p[par_pos];
            pars_p->token[tok_len] = '\0';
        }
    }
    pars_p->par_pos = par_pos;
    pars_p->par_sta = par_sta;
    pars_p->tok_len = tok_len;
    return (tok_len);
}
/* ========================================================================
   sets up a simple symbol table as an array of elements, ordered by
   declaration, of different types. symbol_cnt will index the next free slot
   ======================================================================== */
void            init_sym_table (int elements)
{
    symbol_cnt = 0;
    max_symbol_cnt = elements;  /* based on mimimum size required */
    symtab_p = (symtab_t **) malloc ((size_t) (sizeof (symtab_t *) *
                                               max_symbol_cnt));
}
/* ========================================================================
   deletes all symbol entries in table created above a given nest level.
   if the last entry is deleted, the table store is deallocated.
   ======================================================================== */
void            purge_symbols (short level)
{
    int             cnt;
    symtab_t       *symbol_p;
    int            exit = 0;

    cnt = 1;
    while (!exit && (cnt <= symbol_cnt))
    {
        symbol_p = symtab_p[symbol_cnt - cnt];
/*        if (!(exit = (symbol_p->depth <= level))) */
        if ((exit = (symbol_p->depth <= level)) == 0)
        {
            if (symbol_p->name_p != NULL)
                free (symbol_p->name_p);
            if (symbol_p->type == STR_SYMBOL)
                free (symbol_p->value.str_val);
            if (symbol_p->type == MAC_SYMBOL)
            {
                macro_t        *l_p, *nl_p;

                l_p = symbol_p->value.mac_val;
                while (l_p != (macro_t *) NULL)
                {
                    nl_p = l_p->line_p;
                    free ((char *) l_p);
                    l_p = nl_p;
                }
            }
            free ((char *) symbol_p);
            cnt++;
        }
    }
    symbol_cnt = symbol_cnt - (cnt - 1);
    if (symbol_cnt == 0)
        free ((char *) symtab_p);
}
/* ========================================================================
   adds symbol structure to table and checks for name clashes, scope
   clashes, invalid identifiers and lack of table space. A valid name
   must contain alphanumerics only, plus '_', with
   the first character alphabetic.
   ======================================================================== */
symtab_t       *insert_symbol (char *token_p, short type)
{
    symtab_t       *symbol_p;
    symtab_t       *oldsym_p;
    short             cnt;
    int            valid;

    /* check that symbol table has a spare slot and issue a warning if close */
    symbol_p = (symtab_t *) NULL;
    if (symbol_cnt >= (max_symbol_cnt - 1))
        print ("Cannot insert \"%s\" in symbol table - table is full!\n", token_p);
    else
    {
        valid = 1;
        cnt = 0;
        while (token_p[cnt] != '\0')
        {
            if (((token_p[cnt] < 'A') || (token_p[cnt] > 'Z')) &&
                ((token_p[cnt] < 'a') || (token_p[cnt] > 'z')) &&
                ((token_p[cnt] < '0') || (token_p[cnt] > '9') || (cnt == 0)) &&
                ((token_p[cnt] != '_') || (cnt == 0)))
                valid = 0;
            cnt++;
        }
        if (!valid)
            print ("Cannot insert \"%s\" in symbol table - invalid symbol name\n",
                   token_p);
        else
        {
            /* carry on with insertion process, checking for scoped name
               clashes */
            /* look for a symbol of the same type and matching name. This can
               be ok if it was declared in a macro level less than the current

               one */
            oldsym_p = look_for (token_p, ANY_SYMBOL);
            if ((oldsym_p != (symtab_t *) NULL) && (oldsym_p->depth >= macro_depth))
                print ("Cannot insert \"%s\" in symbol table - name clash within current scope\n",
                       token_p);
            else
            {
                symbol_p = (symtab_t *) malloc (sizeof (symtab_t));
                symbol_p->name_p = (char*)malloc (MAX_TOK_LEN);
                if ((symbol_p == NULL) || (symbol_p->name_p == NULL))
                {
                    print ("Cannot insert \"%s\" in symbol table - no memory available\n", token_p);
                    symbol_p = NULL;
                }
                else
                {
                    /* print("Inserted symbol \"%s\" using space at %x\n",
                       token_p, symbol_p); */
                    strcpy (symbol_p->name_p, token_p);
                    symbol_p->name_len = strlen (token_p);
                    symbol_p->type = type;
                    symbol_p->depth = macro_depth;

                    /* insert new structure in table and warn if near full */
                    symtab_p[symbol_cnt] = symbol_p;
                    /* print("Inserted symbol \"%s\" at slot %d\n", token_p,
                       symbol_cnt); */
                    symbol_cnt++;
                    if (symbol_cnt >= (max_symbol_cnt - 10))
                        print ("Warning: Symbol table nearly full - (%ld of %ld entries)\n",
                               symbol_cnt, max_symbol_cnt);

                }
            }
        }
    }
    return (symbol_p);
}
/* ========================================================================
   allows deletion of a symbol from table, providing its been declared
   at the current macro_depth
   ======================================================================== */
int            delete_symbol (char *token_p)
{
    symtab_t       *symbol_p;
    int            error = 0;

    symbol_p = look_for (token_p, 0xff);    /* look for any type */
    if (symbol_p == (symtab_t *) NULL)
        error = 1;
    else
    {
        if ((symbol_p->fixed) || (symbol_p->depth != macro_depth))
            error = 1;
        else
        {
            /* free symbol name storage */
            free (symbol_p->name_p);
            symbol_p->name_p = NULL;

            /* delete string storage */
            if (symbol_p->type == STR_SYMBOL)
                free (symbol_p->value.str_val);

            /* delete any macro line buffers */
            if (symbol_p->type == MAC_SYMBOL)
            {
                macro_t        *l_p, *nl_p;

                l_p = symbol_p->value.mac_val;
                while (l_p != (macro_t *) NULL)
                {
                    nl_p = l_p->line_p;
                    free ((char *) l_p);
                    l_p = nl_p;
                }
            }
            /* mark symbol as unused, ready for purge when nest level is
               stripped */
            symbol_p->type = 0;
        }
    }
    return (error);
}
/* ========================================================================
   creates or updates an integer symbol table entry
   ======================================================================== */
int            assign_integer (char *token_p, int value, int constant)
{
    symtab_t       *symbol_p;
    int            error = 0;

    if (strlen (token_p) != 0)
    {
        symbol_p = look_for (token_p, INT_SYMBOL);
        if ((symbol_p == (symtab_t *) NULL) && (token_p[0] != '\0'))
        {
            symbol_p = insert_symbol (token_p, INT_SYMBOL);
            if (symbol_p == (symtab_t *) NULL)
                error = 1;
            else
            {
                symbol_p->fixed = constant;
                if (symbol_p->fixed)
                    symbol_p->info_p = "integer constant";
                else
                    symbol_p->info_p = "integer variable";
                symbol_p->value.int_val = value;
            }
        }
        else
        {
            if (symbol_p->fixed)
                error = 1;
            else
                symbol_p->value.int_val = value;
        }
    }
    return (error);
}
/* ========================================================================
   creates an integer symbol table entry without looking for existing symbol
   with a name match
   ======================================================================== */
int            create_integer (char *token_p, int value, int constant)
{
    symtab_t       *symbol_p;
    int            error = 0;

    if (strlen (token_p) != 0)
    {
        symbol_p = insert_symbol (token_p, INT_SYMBOL);
        if (symbol_p == (symtab_t *) NULL)
            error = 1;
        else
        {
            symbol_p->fixed = constant;
            if (symbol_p->fixed)
                symbol_p->info_p = "integer constant";
            else
                symbol_p->info_p = "integer variable";
            symbol_p->value.int_val = value;
        }
    }
    return (error);
}
/* ========================================================================
   creates or updates a floating point symbol table entry
   ======================================================================== */
int            assign_float (char *token_p, double value, int constant)
{
    symtab_t       *symbol_p;
    int            error = 0;

    if (strlen (token_p) != 0)
    {
        symbol_p = look_for (token_p, FLT_SYMBOL);
        if ((symbol_p == (symtab_t *) NULL) && (token_p[0] != '\0'))
        {
            symbol_p = insert_symbol (token_p, FLT_SYMBOL);
            if (symbol_p == (symtab_t *) NULL)
                error = 1;
            else
            {
                symbol_p->fixed = constant;
                if (symbol_p->fixed)
                    symbol_p->info_p = "floating point constant";
                else
                    symbol_p->info_p = "floating point variable";
                symbol_p->value.flt_val = value;
            }
        }
        else
        {
            if (symbol_p->fixed)
                error = 1;
            else
                symbol_p->value.flt_val = value;
        }
    }
    return (error);
}
/* ========================================================================
   creates a floating point symbol table entry
   ======================================================================== */
int            create_float (char *token_p, double value, int constant)
{
    symtab_t       *symbol_p;
    int            error = 0;

    if (strlen (token_p) != 0)
    {
        symbol_p = insert_symbol (token_p, FLT_SYMBOL);
        if (symbol_p == (symtab_t *) NULL)
            error = 1;
        else
        {
            symbol_p->fixed = constant;
            if (symbol_p->fixed)
                symbol_p->info_p = "floating point constant";
            else
                symbol_p->info_p = "floating point variable";
            symbol_p->value.flt_val = value;
        }
    }
    return (error);
}
/* ========================================================================
   creates or updates a string symbol table entry
   ======================================================================== */
int            assign_string (char *token_p, char *value, int constant)
{
    symtab_t       *symbol_p;
    int            error = 0;

    if (strlen (token_p) != 0)
    {
        symbol_p = look_for (token_p, STR_SYMBOL);
        if (symbol_p == (symtab_t *) NULL)
        {
            symbol_p = insert_symbol (token_p, STR_SYMBOL);
            if (symbol_p == (symtab_t *) NULL)
                error = 1;
            else
            {
                symbol_p->fixed = constant;
                if (symbol_p->fixed)
                    symbol_p->info_p = "string constant";
                else
                    symbol_p->info_p = "string variable";
                symbol_p->value.str_val = (char*)malloc (MAX_TOK_LEN);
                if (symbol_p->value.str_val == NULL)
                    error = 1;
                else
                    strcpy (symbol_p->value.str_val, value);
            }
        }
        else
        {
            if (symbol_p->fixed)
                error = 1;
            else
                strcpy (symbol_p->value.str_val, value);
        }
    }
    return (error);
}
/* ========================================================================
   creates a string symbol table entry
   ======================================================================== */
int            create_string (char *token_p, char *value, int constant)
{
    symtab_t       *symbol_p;
    int            error = 0;

    if (strlen (token_p) != 0)
    {
        symbol_p = insert_symbol (token_p, STR_SYMBOL);
        if (symbol_p == (symtab_t *) NULL)
            error = 1;
        else
        {
            symbol_p->fixed = constant;
            if (symbol_p->fixed)
                symbol_p->info_p = "string constant";
            else
                symbol_p->info_p = "string variable";
            symbol_p->value.str_val = (char*)malloc (MAX_TOK_LEN);
            if (symbol_p->value.str_val == NULL)
                error = 1;
            else
                strcpy (symbol_p->value.str_val, value);
        }
    }
    return (error);
}
/* ========================================================================
   establishes the existence of a command procedure
   ======================================================================== */
int            register_command (char *token_p, int (*action) (parse_t *, char *),
                                  char *help_p)
{
    symtab_t       *symbol_p;
    int            error = 0;

    symbol_p = look_for (token_p, (COM_SYMBOL | MAC_SYMBOL));
    if (symbol_p != (symtab_t *) NULL)
    {
        error = 1;
        print ("Name clash when registering command \"%s\"\n", token_p);
    }
    else
    {
        symbol_p = insert_symbol (token_p, COM_SYMBOL);
        if (symbol_p == (symtab_t *) NULL)
            error = 1;
        else
        {
            symbol_p->fixed = 1;
            symbol_p->info_p = help_p;
            symbol_p->value.com_val = action;
        }
    }
    return (error);
}
int            evaluate_integer_expr (parse_t *, int *, short);

/* ========================================================================
   attempts a series of operations to extract an integer value from a token
   ======================================================================== */
int            evaluate_integer (char *token_p, int * value_p, short default_base)
{
    parse_t         pars;
    symtab_t       *symbol_p;
    int            error = 0;

    if (token_p[0] == '\0')
        error = 1;
    else if (token_p[0] == '-')
    {                           /* unary negative */
        token_p++;
        error = evaluate_integer (token_p, value_p, default_base);
        if (!error)
            *value_p = -(*value_p);
    }
    else if (token_p[0] == '~')
    {                           /* unary bitflip */
        token_p++;
        error = evaluate_integer (token_p, value_p, default_base);
        if (!error)
            *value_p = ~(*value_p);
    }
    else if (token_p[0] == '!')
    {                           /* unary NOT */
        token_p++;
        error = evaluate_integer (token_p, value_p, default_base);
        if (!error)
            *value_p = !(*value_p);
    }
    else
    {
        /* First look for a simple number, then try a symbol reference. If
           this all fails, the value may be due to an expression, so try and
           evaluate it */
        *value_p = conv_int (token_p, default_base);
        if (*value_p == BAD_INT_VAL)
        {
            symbol_p = look_for (token_p, INT_SYMBOL);
            if (symbol_p == (symtab_t *) NULL)
            {
                init_pars (&pars, token_p);
                error = evaluate_integer_expr (&pars, value_p, default_base);
            }
            else
            {
                error = 0;
                *value_p = symbol_p->value.int_val;
            }
        }
    }
    return (error);
}
/* ========================================================================
   generalised recursive evaluate of a possibly bracketed integer expression.
   No leading spaces are allowed in the passed string, and the parsing
   structure is assumed to be initialised but not yet used
   ======================================================================== */
int            evaluate_integer_expr (parse_t * pars_p, int * value_p,
                                       short default_base)
{
    int            error = 0;
    short             brackets = 0;
    int             value1, value2;
    short             index, i;
    char            sub_expr[MAX_TOK_LEN];
    char            operation;

    static char    *delim = "*/+-|&^%";     /* recognised arithmetic

                                               operators */

    /* pair up a leading bracket */
    if (pars_p->line_p[0] == '(')
    {
        brackets = 1;
        index = 1;
        while ((pars_p->line_p[index] != '\0') && (brackets > 0))
        {
            if (pars_p->line_p[index] == ')')
                brackets--;
            if (pars_p->line_p[index] == '(')
                brackets++;
            index++;
        }
        if (brackets != 0)
            error = 1;
        else
        {
            /* copy substring without enclosing brackets and evaluate it. if
               this is ok, then update parsing start position */
            for (i = 1; i < index; i++)
                sub_expr[i - 1] = pars_p->line_p[i];
            sub_expr[index - 2] = '\0';
            error = evaluate_integer (sub_expr, &value1, default_base);
            if (!error)
                pars_p->par_pos = index - 1;
        }
    }
    if (!error)
    {
        /* look for a token and check for significance */
        get_tok (pars_p, delim);
        if (pars_p->tok_del == '\0')
        {                       /* no operator seen */
            if (pars_p->par_sta > 0)    /* bracket removal code used */
                *value_p = value1;
            else
                error = 1;   /* not a valid expression! */
        }
        else
        {
            /* have found an operator. If we stripped brackets in the first
               half of this code, then the interesting part of the line is
               now after the operator. If we did not, then evaluate both
               sides of operator */
            operation = pars_p->tok_del;
            if (pars_p->par_sta == 0)
                error = evaluate_integer (pars_p->token, &value1, default_base);
            if (!error)
            {
                get_tok (pars_p, "");   /* all the way to the end of this
                                           line */
                error = evaluate_integer (pars_p->token, &value2, default_base);
            }
            if (!error)
            {
                switch (operation)
                {
                    case '+':
                        *value_p = value1 + value2;
                        break;
                    case '-':
                        *value_p = value1 - value2;
                        break;
                    case '*':
                        *value_p = value1 * value2;
                        break;
                    case '/':
                        *value_p = value1 / value2;
                        break;
                    case '&':
                        *value_p = value1 & value2;
                        break;
                    case '|':
                        *value_p = value1 | value2;
                        break;
                    case '^':
                        *value_p = value1 ^ value2;
                        break;
                    case '%':
                        *value_p = value1 % value2;
                        break;
                    default:
                        error = 1;
                        break;
                }
            }
        }
    }
    return (error);
}
int            evaluate_float_expr (parse_t *, double *);

/* ========================================================================
   attempts a series of operations to extract a floating pt value from a tok
   ======================================================================== */
int            evaluate_float (char *token_p, DOUBLE * value_p)
{
    parse_t         pars;
    symtab_t       *symbol_p;
    int            error = 0;

    /* this will only be relevant for non null strings w/o leading white
       space. First look for a simple number, then try a symbol reference. If

       this all fails, the value may be due to an expression, so try and
       evaluate it */
    /* print("float evaluation of %s \n",token_p); */
    if (token_p[0] == '\0')
        error = 1;
    else
    {
        error = conv_flt (token_p, value_p);
        if (error)
        {
            /* a symbol would be legal if it were an integer, but have to
               float it */
            symbol_p = look_for (token_p, FLT_SYMBOL | INT_SYMBOL);
            if (symbol_p == (symtab_t *) NULL)
            {
                init_pars (&pars, token_p);
                error = evaluate_float_expr (&pars, value_p);
            }
            else
            {
                error = 0;
                if (symbol_p->type == FLT_SYMBOL)
                    *value_p = symbol_p->value.flt_val;
                else
                    *value_p = (DOUBLE) symbol_p->value.int_val;
            }
        }
    }
    return (error);
}
/* ========================================================================
   generalised recursive evaluate of a, possibly bracketed, float expression
   No leading spaces are allowed in the passed string, and the parsing
   structure is assumed to be initialised but not yet used
   ======================================================================== */
int            evaluate_float_expr (parse_t * pars_p, DOUBLE * value_p)
{
    int            error = 0;
    short             brackets = 0;
    DOUBLE          value1, value2;
    short             index, i;
    char            sub_expr[MAX_TOK_LEN];
    char            operation;

    static char    *delim = "*/+-";     /* recognised arithmetic operators */

    if (pars_p->line_p[0] == '(')
    {
        brackets = 1;
        index = 1;
        while ((pars_p->line_p[index] != '\0') && (brackets > 0))
        {
            if (pars_p->line_p[index] == ')')
                brackets--;
            if (pars_p->line_p[index] == '(')
                brackets++;
            index++;
        }
        if (brackets != 0)
            error = 1;
        else
        {
            /* copy substring without enclosing brackets and evaluate it. if
               this is ok, then update parsing start position */
            for (i = 1; i < index; i++)
                sub_expr[i - 1] = pars_p->line_p[i];
            sub_expr[index - 2] = '\0';
            error = evaluate_float (sub_expr, &value1);
            if (!error)
                pars_p->par_pos = index - 1;
        }
    }
    if (!error)
    {
        /* look for a token and check for significance */
        get_tok (pars_p, delim);
        if (pars_p->tok_del == '\0')
        {                       /* no operator seen */
            if (pars_p->par_sta > 0)    /* bracket removal code used */
                *value_p = value1;
            else
                error = 1;   /* not a valid expression! */
        }
        else
        {
            /* have found an operator. If we stripped brackets in the first
               half of this code, then the interesting part of the line is
               now after the operator. If we did not, then evaluate both
               sides of operator */
            operation = pars_p->tok_del;
            if (pars_p->par_sta == 0)
                error = evaluate_float (pars_p->token, &value1);
            if (!error)
            {
                get_tok (pars_p, "");   /* all the way to the end of this
                                           line */
                error = evaluate_float (pars_p->token, &value2);
            }
            if (!error)
            {
                switch (operation)
                {
                    case '+':
                        *value_p = value1 + value2;
                        break;
                    case '-':
                        *value_p = value1 - value2;
                        break;
                    case '*':
                        *value_p = value1 * value2;
                        break;
                    case '/':
                        *value_p = value1 / value2;
                        break;
                    default:
                        error = 1;
                }
            }
        }
    }
    return (error);
}
/* ========================================================================
   specific evaluation of comparison between two numeric expressions.
   No leading spaces are allowed in the passed string.
   A single expression will yield a result of 0 if equal to zero.
   Although real expressions are allowed, comparison is done in integers.
   A default result of 1 is returned in the case of an error
   ======================================================================== */
int            evaluate_comparison (char *token_p, int * result_p,
                                     short default_base)
{
    int            error = 0;
    parse_t         pars;
    int             value1, value2;
    DOUBLE          real_val;
    char            op1, op2 = 0;

    static char    *delim = "><=!";     /* recognised logical operators */

    /* evaluate first arithmetic expression in line */
    *result_p = 1;
    init_pars (&pars, token_p);
    get_tok (&pars, delim);
    error = evaluate_integer (pars.token, &value1, default_base);
    if (error)
    {
        error = evaluate_float (pars.token, &real_val);
        if (!error)
            value1 = (int) real_val;
    }
    if (!error)
    {

        /* deal with the case of a single expression value */
        if (pars.tok_del == '\0')
            *result_p = !(value1 == 0);
        else
        {

            /* look for valid single or pair of operators and move posn
               accordingly */
            op1 = pars.line_p[pars.par_pos];
            op2 = pars.line_p[pars.par_pos + 1];
            if ((op2 != '>') && (op2 != '<') && (op2 != '='))
                op2 = 0;
            else
                pars.par_pos++;

            /* get token for rest of line and extract a value in a similar
               way */
            get_tok (&pars, "");
            error = evaluate_integer (pars.token, &value2, default_base);
            if (error)
            {
                error = evaluate_float (pars.token, &real_val);
                if (!error)
                    value2 = (int) real_val;
            }
            if (!error)
            {

                /* deal with the combination of two expression values */
                switch (op1)
                {
                    case '=':
                        switch (op2)
                        {
                            case '=':
                                *result_p = (value1 == value2);
                                break;
                            case '!':
                                *result_p = (value1 != value2);
                                break;
                            case '<':
                                *result_p = (value1 <= value2);
                                break;
                            case '>':
                                *result_p = (value1 >= value2);
                                break;
                            default:
                                error = 1;
                                break;
                        }
                        break;
                    case '!':
                        switch (op2)
                        {
                            case '=':
                                *result_p = (value1 != value2);
                                break;
                            default:
                                error = 1;
                                break;
                        }
                        break;
                    case '>':
                        switch (op2)
                        {
                            case '=':
                                *result_p = (value1 >= value2);
                                break;
                            case 0:
                                *result_p = (value1 > value2);
                                break;
                            default:
                                error = 1;
                                break;
                        }
                        break;
                    case '<':
                        switch (op2)
                        {
                            case '=':
                                *result_p = (value1 <= value2);
                                break;
                            case '>':
                                *result_p = (value1 != value2);
                                break;
                            case 0:
                                *result_p = (value1 < value2);
                                break;
                            default:
                                error = 1;
                                break;
                        }
                        break;

                }
            }
        }
    }
    return (error);
}
/* ========================================================================
   attempts a series of operations to extract a string value from a token
   ======================================================================== */
int            evaluate_string (char *token_p, char *string_p, short max_len)
{
    symtab_t       *symbol_p;
    int            error = 0;
    short             index, i, len;
    parse_t         pars;

    string_p[0] = '\0';
    /* print("string evaluation of %s \n",token_p); */
    if (token_p[0] == '\0')
        error = 1;
    else
    {
        /* look for concatenation function */
        init_pars (&pars, token_p);
        get_tok (&pars, "+");
        if (pars.tok_del == '+')
        {
            /* call routine on halves of passed token */
            error = evaluate_string (pars.token, string_p, max_len);
            if (!error)
            {
                get_tok (&pars, "");    /* rest of line */
                len = strlen (string_p);
                error = evaluate_string (pars.token, &string_p[len], max_len - len);
            }
        }
        else
        {
            symbol_p = look_for (token_p, STR_SYMBOL);
            if (symbol_p != (symtab_t *) NULL)
                strcpy (string_p, symbol_p->value.str_val);
            else
            {
                /* we assume since this is already been passed through the
                   tokeniser that this is a valid string - starting with a
                   quote mark and ending with a quote mark only containing
                   escaped quote marks within its body. All that is needed
                   for evaluation is to strip out the escapes */
                len = strlen (token_p);
                if ((token_p[0] == '"') && (token_p[len - 1] == '"'))
                {
                    /* copy substring without enclosing quotes, preserving
                       case */
                    index = 1;
                    i = 0;
                    while ((token_p[index] != '\0') && (index < (len - 1)))
                    {
                        if ((token_p[index + 1] == '"') && (token_p[index] == ESCAPE_CHAR))
                        {
                            string_p[i++] = token_p[index + 1];
                            index++;
                        }
                        else
                            string_p[i++] = token_p[index];
                        index++;
                    }
                    string_p[i] = '\0';
                    len = i;
                }
                else
                    error = 1;
            }
        }
    }
    return (error);
}
/* ========================================================================
   attempts multiple evaluations of a token. If successful, assigns a
   symbol of appropriate type to the resultant value . Two retuns are
   provided. 'error' signififies that the token was in itself
   correct, but the assignment to the target symbol failed. 'not_done'
   is used to flag an unsuccessful evaluation. The force parameter can
   be used to force creation of the variable to hold the result without
   looking for possible match in symbol table
   ======================================================================== */
int            evaluate_assign (char *target_p, char *token_p, int * error_p, int force)
{
    int            not_done = 0;
    int             int_val;
    DOUBLE          real_val;
    char            string_val[MAX_TOK_LEN];

    *error_p = 0;
    if (strlen (target_p) != 0)
    {
        not_done = evaluate_integer (token_p, &int_val, number_base);
        if (!not_done)
        {
            if (force)
                *error_p = create_integer (target_p, int_val, 0);
            else
                *error_p = assign_integer (target_p, int_val, 0);
        }
        else
        {
            not_done = evaluate_float (token_p, &real_val);
            if (!not_done)
            {
                if (force)
                    *error_p = create_float (target_p, real_val, 0);
                else
                    *error_p = assign_float (target_p, real_val, 0);
            }
            else
            {
                not_done = evaluate_string (token_p, string_val, MAX_TOK_LEN);
                if (!not_done)
                {
                    if (force)
                        *error_p = create_string (target_p, string_val, 0);
                    else
                        *error_p = assign_string (target_p, string_val, 0);
                }
            }
        }
    }
    return (not_done);
}
/* ========================================================================
   a high level parsing routine which forms part of a set. The general
   specification is the incremental reading of an input string via the
   parsing structure, detecting a parameter refernce of the right type and
   passing back a result. If the input line at this point is blank, a default
   value is substituted for a result. If the next token on the input line
   does not have the right characteristics for a parameter of this type, then
   the routine returns 1 to signify an error. The default parameter is
   passed back in this case as well as an error.
   ======================================================================== */
int            cget_string (parse_t * pars_p, char *default_p, char *result_p,
                             short max_len)
{
    int            error = 0;

    get_tok (pars_p, delim_set);
    if (pars_p->tok_len == 0)
        strncpy (result_p, default_p, max_len);
    else
    {
        error = evaluate_string (pars_p->token, result_p, max_len);
        if (error)
            strncpy (result_p, default_p, max_len);
    }
    return (error);
}
/* ========================================================================
   a high level parsing routine which forms part of a set. The general
   specification is the incremental reading of an input string via the
   parsing structure, detecting a parameter refernce of the right type and
   passing back a result. If the input line at this point is blank, a default
   value is substituted for a result. If the next token on the input line
   does not have the right characteristics for a parameter of this type, then
   the routine returns 1 to signify an error. The default parameter is
   passed back in this case as well.
   ======================================================================== */
int            cget_integer (parse_t * pars_p, int def_int, int * result_p)

{
    int            error = 0;

    get_tok (pars_p, delim_set);
    if (pars_p->tok_len == 0)
        *result_p = def_int;
    else
    {
        error = evaluate_integer (pars_p->token, result_p, number_base);
        if (error)
        {
            pars_p->par_pos = pars_p->par_sta;
            *result_p = def_int;
        }
        
    }
    return (error);
}
/* ========================================================================
   a high level parsing routine which forms part of a set. The general
   specification is the incremental reading of an input string via the
   parsing structure, detecting a parameter refernce of the right type and
   passing back a result. If the input line at this point is blank, a default
   value is substituted for a result. If the next token on the input line
   does not have the right characteristics for a parameter of this type, then
   the routine returns 1 to signify an error. The default parameter is
   passed back in this case as well.
   ======================================================================== */
int            cget_float (parse_t * pars_p, DOUBLE def_flt, DOUBLE * result_p)
{
    int            error = 0;

    get_tok (pars_p, delim_set);
    if (pars_p->tok_len == 0)
        *result_p = def_flt;
    else
    {
        error = evaluate_float (pars_p->token, result_p);
        if (error)
            *result_p = def_flt;
    }
    return (error);
}
/* ========================================================================
   a high level parsing routine which forms part of a set. The general
   specification is the incremental reading of an input string via the
   parsing structure, detecting a parameter refernce of the right type and
   passing back a result. If the input line at this point is blank, a default
   value is substituted for a result. If the next token on the input line
   does not have the right characteristics for a parameter of this type, then
   the routine returns 1 to signify an error. The default parameter is
   passed back in this case as well.
   ======================================================================== */
int            cget_item (parse_t * pars_p, char *default_p, char *result_p, short max_len)
{
    int            error = 0;

    /* simply returns next token on line or the default string */
    get_tok (pars_p, delim_set);
    if (pars_p->tok_len == 0)
        strncpy (result_p, default_p, max_len);
    else
        strncpy (result_p, pars_p->token, max_len);

    return (error);
}
/* ========================================================================
   obtains input line from current active source, returns 0 if OK
   SHould this routine do echo of input lines?
   should this routine issue a prompt for interactive input?
   ======================================================================== */


/* ========================================================================
   this routine assumes a string is passed which contains only a
   potential command name followed by a set of parameters. If the first
   token on the line is not a valid command, the routine returns 1. If
   it is, then the defined action routine for that command is invoked and the
   result of the execution passed back to the caller
   ======================================================================== */
int            execute_command_line (char *line_p, char *target_p, int * result_p)
{
    symtab_t       *command_p;
    parse_t         pars;
    int            error;

    error = 0;
    init_pars (&pars, line_p);
    get_tok (&pars, delim_set);
    command_p = look_for (pars.token, COM_SYMBOL);
    if (command_p != (symtab_t *) NULL)
        *result_p = command_p->value.com_val (&pars, target_p);
    else
        error = 1;
    return (error);
}
int            command_loop (macro_t *, char *, char *, int);     /* forward

                                                                       definition

                                                                     */
/* ========================================================================
   this routine assumes a string is passed which contains only a
   potential macro name followed by a set of actual parameters.
   If the first token on the line is not a current macro, the routine returns
   1. If it is, then the body of the macro is executed and the
   result of the execution passed back to the caller. If the macro attempts
   to pass back a value, the expression is evaluated into the target symbol
   name
   ======================================================================== */
int            execute_macro (char *line_p, char *target_p, int * result_p)
{
    symtab_t       *macro_p;
    parse_t         formal_pars, actual_pars;
    int            error = 0;
    int            not_done = 0;
    char            rtn_expression[MAX_TOK_LEN];
    int             int_val;
    DOUBLE          real_val;
    char            string_val[MAX_TOK_LEN];
    short             type = 0;

    rtn_expression[0] = '\0';
    init_pars (&actual_pars, line_p);
    get_tok (&actual_pars, delim_set);
    macro_p = look_for (actual_pars.token, MAC_SYMBOL);
    if (macro_p != (symtab_t *) NULL)
    {
        /* define the formal parameters with values of actuals. look over the

           length of the invocation line and pick up the actual parameters
           determine their type and create an equivalent symbolic variable
           under the name of the formal parameter at the same position.
           formal parameters with no actual values are given default types
           and values. */

        macro_depth++;
        if (cur_echo)
            print ("Executing macro \"%s\"\n", macro_p->name_p);
        init_pars (&formal_pars, macro_p->value.mac_val->line);
        get_tok (&formal_pars, delim_set);
        while ((formal_pars.tok_len > 0) && !error)
        {
            get_tok (&actual_pars, delim_set);
            if (actual_pars.tok_len > 0)
            {
                not_done = evaluate_assign (formal_pars.token, actual_pars.token, &error, 1);
            }
            else
                not_done = evaluate_assign (formal_pars.token, "0", &error, 1);
            get_tok (&formal_pars, delim_set);
        }
        if (error || not_done)
            tag_current_line (&actual_pars,
                              "Failed to assign actual value to formal parameter");
        else
        {
            /* if all this parameterisation worked out OK, then actually
               execute the macro code and return the result. If an an
               expression was found at the end of the macro we must evaluate
               it into a temporary variable in the scope of the macro and
               then reassign it to the target variable in the enclosing scope

             */

            *result_p = command_loop (macro_p->value.mac_val->line_p,
                                      (char*) 0, rtn_expression, cur_echo);
            if (strlen (rtn_expression) != 0)
            {
                *result_p = evaluate_integer (rtn_expression, &int_val, number_base);
                if (!*result_p)
                    type = INT_SYMBOL;
                else
                {
                    *result_p = evaluate_float (rtn_expression, &real_val);
                    if (!*result_p)
                        type = FLT_SYMBOL;
                    else
                    {
                        *result_p = evaluate_string (rtn_expression, string_val, MAX_TOK_LEN);
                        if (!*result_p)
                            type = STR_SYMBOL;
                        else
                            type = 0;
                    }
                }
            }
        }
        macro_depth--;
        purge_symbols (macro_depth);
        /* now we are back within original scope, try to evaluate and assign
           return expression, using temporary variable to give value */
        if ((strlen (rtn_expression) != 0) && (type != 0))
        {
            switch (type)
            {
                case INT_SYMBOL:
                    *result_p = assign_integer (target_p, int_val, 0);
                    break;
                case FLT_SYMBOL:
                    *result_p = assign_float (target_p, real_val, 0);
                    break;
                case STR_SYMBOL:
                    *result_p = assign_string (target_p, string_val, 0);
                    break;
            }
        }
    }
    else
        error = 1;
    return (error);
}
/* ========================================================================
   performs the actions of displaying constants and symbols. If a
   line of parameters is present, each is interpreted and displayed. Other
   the whole current list of symbols is displayed.
   ======================================================================== */
int            do_show (parse_t * pars_p, char *result_p)
{
    int            error = 0;
    symtab_t       *symbol_p;
    short             cnt = 0;
    macro_t        *line_p;

    if (get_tok (pars_p, delim_set) == 0)
    {                           /* no items on a line */
        print ("Currently defined symbols:\n\n");
        /* print symbol table info */
        while (cnt < symbol_cnt)
        {
            symbol_p = symtab_p[cnt++];
            switch (symbol_p->type)
            {
                case INT_SYMBOL:
                    print ("%2d: %s: ", symbol_p->depth, symbol_p->name_p);
                    print ("%ld - %s\n", symbol_p->value.int_val,
                           symbol_p->info_p);
                    break;
                case FLT_SYMBOL:
                    print ("%2d: %s: ", symbol_p->depth, symbol_p->name_p);
                    print ("%G - %s\n", symbol_p->value.flt_val,
                           symbol_p->info_p);
                    break;
                case STR_SYMBOL:
                    print ("%2d: %s: ", symbol_p->depth, symbol_p->name_p);
                    print ("\"%s\" - %s\n", symbol_p->value.str_val,
                           symbol_p->info_p);
                    break;
                case MAC_SYMBOL:
                    print ("%2d: %s: ", symbol_p->depth, symbol_p->name_p);
                    print ("(%s) - %s\n", symbol_p->value.mac_val->line,
                           symbol_p->info_p);
                    break;
            }
        }
    }
    else
    {
        symbol_p = look_for (pars_p->token, ANY_SYMBOL);
        if (symbol_p == NULL)
            tag_current_line (pars_p, "unrecognised symbol name");
        else
        {
            switch (symbol_p->type)
            {
                case INT_SYMBOL:
                    print ("%d: %s: ", symbol_p->depth, symbol_p->name_p);
                    print ("%ld (#%x) - %s\n", symbol_p->value.int_val,
                           symbol_p->value.int_val,
                           symbol_p->info_p);
                    break;
                case FLT_SYMBOL:
                    print ("%d: %s: ", symbol_p->depth, symbol_p->name_p);
                    print ("%G - %s\n", symbol_p->value.flt_val,
                           symbol_p->info_p);
                    break;
                case STR_SYMBOL:
                    print ("%d: %s: ", symbol_p->depth, symbol_p->name_p);
                    print ("\"%s\" - %s\n", symbol_p->value.str_val,
                           symbol_p->info_p);
                    break;
                case COM_SYMBOL:
                    print ("%d: %s: ", symbol_p->depth, symbol_p->name_p);
                    print ("is a command\n");
                    break;
                case MAC_SYMBOL:
                    print ("%d: %s ", symbol_p->depth, symbol_p->name_p);
                    print ("(%s) - %s\n", symbol_p->value.mac_val->line,
                           symbol_p->info_p);
                    /* print macro contents */
                    line_p = symbol_p->value.mac_val->line_p;
                    while (line_p != NULL)
                    {
                        print (">   %s\n", line_p->line);
                        line_p = line_p->line_p;
                    }
                    break;
                default:
                    print ("%d: %s has been deleted\n", symbol_p->depth,
                           symbol_p->name_p);
                    break;
            }
        }
    }
    return (error);
}
/* ========================================================================
   perform a fomatting action on a list of variables or values by
   invoking the sprintf routine
   ======================================================================== */
int            do_print (parse_t * pars_p, char *result_p)
{
    int            error = 0;
    short             cnt;
    int             int_val;
    DOUBLE          real_val;
    char            str_val[MAX_TOK_LEN];
    char            str_buf[MAX_LINE_LEN];

    str_buf[0] = '\0';
    cnt = 0;
    while ((pars_p->tok_del != '\0') && (strlen (str_buf) < 200))
    {
        get_tok (pars_p, delim_set);
        error = evaluate_integer (pars_p->token, &int_val, number_base);
        if (!error)
        {
            switch (number_base)
            {
                case 2:
                    {
                        int             i;

                        str_val[0] = '$';
                        str_val[33] = '\0';
                        for (i = 31; i >= 0; i--)
                            if (((int_val >> i) & 0x1) > 0)
                                str_val[32 - i] = '1';
                            else
                                str_val[32 - i] = '0';
                    }
                    break;
                case 8:
                    sprintf (str_val, "O%o", int_val);
                    break;
                case 10:
                    sprintf (str_val, "%d", int_val);
                    break;
                case 16:
                    sprintf (str_val, "#%x", int_val);
                    break;
                default:
                    error = 1;
                    sprintf (str_val, "Invalid number base");
                    break;
            }
            strcat (str_buf, str_val);
        }
        else
        {
            error = evaluate_float (pars_p->token, &real_val);
            if (!error)
            {
                sprintf (str_val, "%G", real_val);
                strcat (str_buf, str_val);
            }
            else
            {
                error = evaluate_string (pars_p->token, str_val, MAX_TOK_LEN);
                if (!error)
                    strcat (str_buf, str_val);
                else
                {
                    if (pars_p->tok_len > 0)
                        strcat (str_buf, "******");
                    else
                        error = 0;
                }
            }
        }
        cnt++;
    }
    //print ("%s\n", str_buf);
    return (error || assign_string (result_p, str_buf, 0));
}
/* ========================================================================
   Allows display of help information attached to each command or macro
   currently defined. If a parameter is present, the display is limited to
   help for that command. Otherwise a list is printed.
   ======================================================================== */
int            do_help (parse_t * pars_p, char *result_p)
{
    int            error = 0;
    symtab_t       *symbol_p;
    int             cnt = 0;

    if (get_tok (pars_p, delim_set) == 0)
    {                           /* no items on a line */
        print ("The following commands and macros are defined:\n\n");
        while (cnt < symbol_cnt)
        {
            symbol_p = symtab_p[cnt++];
            switch (symbol_p->type)
            {
                case COM_SYMBOL:
                    print ("%-12s - %s\n", symbol_p->name_p, symbol_p->info_p);
                    break;
                case MAC_SYMBOL:
                    print ("%s ", symbol_p->name_p);
                    print ("(%s) - %s\n", symbol_p->value.mac_val->line, symbol_p->info_p);
                    break;
                default:
                    break;
            }
        }
        print ("\n");
       
    }
    else
    {                           /* help XXX */
        symbol_p = look_for (pars_p->token, (MAC_SYMBOL | COM_SYMBOL));
        if (symbol_p != (symtab_t *) NULL)
        {
            switch (symbol_p->type)
            {
                case COM_SYMBOL:
                    print ("%-12s - %s\n", symbol_p->name_p, symbol_p->info_p);
                    break;
                case MAC_SYMBOL:
                    print ("%s ", symbol_p->name_p);
                    print ("(%s) - %s\n", symbol_p->value.mac_val->line, symbol_p->info_p);
                    break;
                default:
                    break;
            }                   /* end of switch */
        }                       /* end of if found one */
        else
        {
            tag_current_line (pars_p, "unrecognised command or macro");
            error = 1;
        }
    }                           /* end of help XXX */
    return (error || assign_string (result_p, "", 0));
}
/* ========================================================================
   alternate version of help : lists all the function and macros that
   are matching
   ======================================================================== */
int            do_list (parse_t * pars_p, char *result_p)
{
    int            error = 0;
    symtab_t       *symbol_p;
    short             cnt = 0;
	char          tmp[100];

    if (get_tok (pars_p, delim_set) != 0)
    {
        sprintf(tmp,"The following commands and macros are defined:\n");
		strcat(result_p,tmp);
        while (cnt < symbol_cnt)
        {
            symbol_p = symtab_p[cnt++];
            /* protect against deleted symbols */
            if (symbol_p->name_p != NULL)
            {
                if (is_matched (pars_p->token, symbol_p->name_p, 1) &&
                    ((symbol_p->type | (MAC_SYMBOL | COM_SYMBOL)) != 0))
                    switch (symbol_p->type)
                    {
                        case COM_SYMBOL:
							sprintf(tmp,"%-12s - %s\n", symbol_p->name_p, symbol_p->info_p);
							strcat(result_p,tmp);
                            break;
                        case MAC_SYMBOL:
							sprintf(tmp,"%s ", symbol_p->name_p);
							strcat(result_p,tmp);
							sprintf (tmp,"(%s) - %s\n", symbol_p->value.mac_val->line, symbol_p->info_p);
							strcat(result_p,tmp);
                            break;
                        default:
                            break;
                    }           /* end of switch case */
            }                   /* end of symbol was not deleted */
        }                       /* end of while all list */
    }                           /* end of there was one */
    return (error );
}

/* ========================================================================
   performs the action of deleting symbols and macros. If
   line of parameters is present, each is interpreted
   and, if possible, deleted.
   ======================================================================== */
int            do_delete (parse_t * pars_p, char *result_p)
{
    int            error = 0;
    symtab_t       *symbol_p;

    if (get_tok (pars_p, delim_set) == 0)
    {                           /* no items on a line */
        tag_current_line (pars_p, "Expected symbol or macro name");
        error = 1;
    }
    else
        while ((pars_p->tok_len > 0) && !error)
        {
            symbol_p = look_for (pars_p->token, 0xff);
            if (symbol_p == (symtab_t *) NULL)
            {
                tag_current_line (pars_p, "Unrecognised symbol");
                error = 1;
            }
            else if (symbol_p->fixed || (symbol_p->type == COM_SYMBOL))
            {
                tag_current_line (pars_p, "Cannot delete fixed symbol or command");
                error = 1;
            }
            else
            {
                error = delete_symbol (pars_p->token);
                if (error)
                    tag_current_line (pars_p, "Cannot delete symbol out of current scope");
                get_tok (pars_p, delim_set);
            }
        }
    return (error || assign_string (result_p, "", 0));
}
/* ========================================================================
   toggles the echo of input lines
   ======================================================================== */
int            do_verify (parse_t * pars_p, char *result_p)
{
    int            error;
    int             echo;

    error = cget_integer (pars_p, cur_echo, &echo);
    if (error)
        tag_current_line (pars_p, "expected command echo flag");
    else
    {
        cur_echo = (int) echo;
        if (cur_echo)
            print ("Command echo is enabled\n");
        else
            print ("Command echo is disabled\n");
    }
    return (error || assign_integer (result_p, echo, 0));
}
/* ========================================================================
   performs the action of defining the default number base
   ======================================================================== */
int            do_base (parse_t * pars_p, char *result_p)
{
    int            error;
    int             base;
    int             old_base;

    old_base = number_base;
    error = cget_integer (pars_p, number_base, &base);
    if (error ||
        ((base != 16) && (base != 10) && (base != 8) && (base != 2)))
    {
        tag_current_line (pars_p, "Illegal number base");
        error = 1;
    }
    else
    {
        number_base = (short) base;
        print ("Number base = %d\n", number_base);
    }
    return (error || assign_integer (result_p, old_base, 0));
}
/* ========================================================================
   controls the logging of input and output to a journal file
   ======================================================================== */
int            do_log (parse_t * pars_p, char *result_p)
{
    return 0;
}
/* ========================================================================
   performs the execution of a command input file
   ======================================================================== */
int            do_source (parse_t * pars_p, char *result_p)
{
 return 0;
}

/* ========================================================================
   Allows user to save state of play, in terms of macros and variables
   by placing definitions in a file such that they can be 'sourced'
   during a future run of the tool
   ======================================================================== */
int            do_save (parse_t * pars_p, char *result_p)
{
   return 0;
}

/* ========================================================================
   allows definition of command macros as a control command in itself
   ======================================================================== */
int            do_define (parse_t * pars_p)
{
    int            error = 0;
    char            name[MAX_TOK_LEN];

    if (get_tok (pars_p, delim_set) == 0)
    {                           /* attempt to find macro name */
        tag_current_line (pars_p, "macro name expected");
        error = 1;
    }
    else
    {
        strcpy (name, pars_p->token);
        get_tok (pars_p, "");   /* get the rest of the line */
        error = define_macro ((char*)pars_p->token, name);
    }
    return (error);
}
/* ========================================================================
   allows definition of flexible command repetition loop
   ======================================================================== */
int            do_for (parse_t * pars_p)
{
    int            error = 0;
    int             first = 0;
    int             second = 0;
    int             step;
    int             i;
    char            variable[MAX_TOK_LEN];
    char            name[MAX_TOK_LEN];

    if (get_tok (pars_p, delim_set) == 0)
    {                           /* attempt to find parameters */
        tag_current_line (pars_p, "for loop variable name expected");
        error = 1;
    }
    else
    {
        strcpy (variable, pars_p->token);
        error = assign_integer (variable, 0, 0);
        if (error)
            tag_current_line (pars_p, "expected integer loop variable name");
        else
        {
            error = cget_integer (pars_p, 1, &first);
            if (error)
                tag_current_line (pars_p, "invalid loop start value");
            else
            {
                error = cget_integer (pars_p, 1, &second);
                if (error)
                    tag_current_line (pars_p, "invalid loop end value");
                else
                {
                    error = (cget_integer (pars_p, 1, &step) ||
                             ((first > second) && (step > 0)) ||
                             ((first < second) && (step < 0)) ||
                             (step == 0));
                    if (error)
                        tag_current_line (pars_p, "invalid or inconsistent loop step value");
                    else
                    {
                        sprintf (name, "FOR%d", macro_depth);
                        error = define_macro ("", name);
                        if (!error)
                        {
                            if (first <= second)
                            {
                                for (i = first; (i <= second) && !error; i = i + step)
                                {
                                    assign_integer (variable, i, 0);
                                    execute_macro (name, "", &error);
                                }
                            }
                            else
                            {
                                for (i = first; (i >= second) && !error; i = i + step)
                                {
                                    assign_integer (variable, i, 0);
                                    execute_macro (name, "", &error);
                                }
                            }
                        }
                        delete_symbol (name);
                    }
                }
            }
        }
    }
    return (error);
}
/* ========================================================================
   allows definition of conditional command repetition loop
   ======================================================================== */
int            do_while (parse_t * pars_p)
{
    int            error = 0;
    int            result = 0;
    char            name[MAX_TOK_LEN];
    char            condition[MAX_TOK_LEN];

    if (get_tok (pars_p, delim_set) == 0)
    {                           /* attempt to find parameters */
        tag_current_line (pars_p, "comparison expression expected");
        error = 1;
    }
    else
    {
        error = evaluate_comparison (pars_p->token, &result, number_base);
        if (error)
            tag_current_line (pars_p, "illegal comparison");
        else
        {
            sprintf (name, "WHILE%d", macro_depth);
            strcpy (condition, pars_p->token);
            error = define_macro ("", name);
            if (!error)
            {
                while (result && !error)
                {
                    execute_macro (name, "", &error);
                    evaluate_comparison (condition, &result, number_base);
                }
                delete_symbol (name);
            }
        }
    }
    return (error);
}
/* ========================================================================
   allows definition of conditional command execution, passing the result
   of the condition evaluation back to a caller for use by the 'else' clause
   ======================================================================== */
int            do_if (parse_t * pars_p, int * if_taken_p)
{
    int            error = 0;
    char            name[MAX_TOK_LEN];
    char            condition[MAX_TOK_LEN];

    if (get_tok (pars_p, delim_set) == 0)
    {                           /* attempt to find parameters */
        tag_current_line (pars_p, "comparison expression expected");
        error = 1;
    }
    else
    {
        error = evaluate_comparison (pars_p->token, if_taken_p, number_base);
        if (error)
            tag_current_line (pars_p, "illegal comparison");
        else
        {
            sprintf (name, "IF%d", macro_depth);
            strcpy (condition, pars_p->token);
            error = define_macro ("", name);
            if (!error)
            {
                if (*if_taken_p)
                    execute_macro (name, "", &error);
                delete_symbol (name);
            }
        }
    }
    return (error);
}
/* ========================================================================
   allows definition of conditional command execution after
   evaluation of the 'if condition
   ======================================================================== */
int            do_else (int if_taken)
{
    int            error = 0;
    char            name[MAX_TOK_LEN];

    sprintf (name, "ELSE%d", macro_depth);
    error = define_macro ("", name);
    if (!error)
    {
        if (!if_taken)
            execute_macro (name, "", &error);
        delete_symbol (name);
    }
    return (error);
}
/* ========================================================================
   fundamental command execution loop. Commands come either from
   a supplied string or from an input stream (file or TTY). The loop
   identifies the type of input statement and determines the action to take
   as a result of this. A range of simple execution control primitives have
   been supplied. Block structure is implemented using temporary macro-like
   structures.
   ======================================================================== */
int            command_loop (macro_t * macro_p, char * file_p, char *rtn_exp_p,
                              int echo)
{
    int            error = 0;
    int            exit = 0;
    int            not_done = 1;
    char            input_line[MAX_LINE_LEN];
    int            sav_echo;
    macro_t        *sav_macro_p;
    char            target[MAX_TOK_LEN];    
    parse_t         pars;
    short             control_const;
    int            if_flag;    /* set if seen in the last line examined */
    int            if_taken;

    static char     cmd_delim[] = "= \\";   /* normal command line delimiters

                                             */
    sav_echo = cur_echo;
    sav_macro_p = cur_macro_p;
    

    cur_echo = echo;
    cur_macro_p = macro_p;
    cur_stream_p = file_p;

    if_flag = 0;

    /* exit from loop on all command errors except when interactive */
    while ((exit==0) && (!error || ((macro_depth <= 1) && (cur_stream_p == 0))))
    {
        /* read an input line and start parsing process. This nesting level
           will terminate if the end of the stream is reached or an error is
           detected. The outermost loop, generally interactive, will not
           terminate on error. */
    
        io_read (prompt_p, input_line, MAX_LINE_LEN);
		
        init_pars (&pars, input_line);
        get_tok (&pars, cmd_delim);
		//fprintf(stderr,"%s.%d [%s]\n\r",__func__,__LINE__,input_line);
        if (is_matched (pars.token, "EXIT", 2) || is_matched (pars.token, "exit", 2)){
            exit = 1;
        }
        else if (pars.tok_len > 0)
        {
            /* proceed with examination of an input line. Broadly speaking
               these come in three flavours - assignment, statement and
               control. The key distiguishing features are a leading '='
               separator or the first token being a member of a small set of
               reserved control words. In each executable case, an attempt is
               made to  execute the line in various forms before declaring an
               error. */
            if (pars.tok_del == ' ')
            {
                /* allow any amount of white space before '=' in assignment */
                int             i;

                i = pars.par_pos;
                while (input_line[i] == ' ')
                    i++;
                if (input_line[i] == '=')
                {
                    pars.tok_del = '=';
                    pars.par_pos = i;
                }
            }
            if (pars.tok_del == '=')
            {
                /* try and make an assignment work out */


                if_flag = 0;
                strcpy (target, pars.token);
                get_tok (&pars, "");    /* tokenise rest of line */
                not_done = evaluate_assign (target, pars.token, &error, 0);
                if (not_done)
                    /* attempt to execute a command or macro assignment */
                    not_done = execute_command_line (pars.token, target, &error);
                if (not_done)
                    not_done = execute_macro (pars.token, target, &error);
                if (not_done)
                    tag_current_line (&pars, "Unrecognised assignment statement");
                /* Report an error in a separate fashion */
                if (error)
                    print ("Assignment of \"%s\" failed\n", target);
            }
            else if (is_control (pars.token, &control_const))
            {
                switch (control_const)
                {
                    case DEFINE_CONST:
                        error = do_define (&pars);
                        if_flag = 0;
                        break;
                    case IF_CONST:
                        error = do_if (&pars, &if_taken);
                        if (!error)
                            if_flag = 1;
                        break;
                    case ELSE_CONST:
                        if (!if_flag)
                        {
                            error = 1;
                            tag_current_line (&pars, "ELSE not allowed without IF");
                        }
                        else
                        {
                            error = do_else (if_taken);
                            if_flag = 0;
                        }
                        break;
                    case WHILE_CONST:
                        error = do_while (&pars);
                        if_flag = 0;
                        break;
                    case FOR_CONST:
                        error = do_for (&pars);
                        if_flag = 0;
                        break;
                    default:
                        tag_current_line (&pars, "Unable to understand control construct");
                        error = 1;
                        break;
                }
            }
            else
            {
                if_flag = 0;
				target[0] =0;
                not_done = execute_command_line (input_line,target, &error);
				//fprintf(stderr,"%s.%d traget[%s] not_done(%d) error(%d) \n\r",__func__,__LINE__,target,not_done,error);	

                if (not_done)
                    not_done = execute_macro (input_line, target, &error);
                if (not_done)
                {
                    tag_current_line (&pars, "Unrecognised command statement");
                    error = 1;
                }
            }
        }
    }

    /* if this is a normal termination of the loop via an END statement, look

       for an expression to use as a result. As usual, the type depends on
       the context of the expression, and this is evaluated in the scope of
       the enclosing macro invocation */
    if (!error)
    {
        if ((get_tok (&pars, delim_set) != 0) && (rtn_exp_p != (char *) NULL))
        {
            strcpy (rtn_exp_p, pars.token);
        }
    }
    /* restore original input information */
    cur_echo = sav_echo;
    cur_macro_p = sav_macro_p;
   

    return (exit);
}
/* ========================================================================
   top level of the cli code, invokes intialisation and top level shell
   ======================================================================== */
void            cli_init (int (*setup_r) (), int max_symbols, short default_base)
{
    macro_depth = 0;
    number_base = default_base;
    init_sym_table (100 + max_symbols);
    /* set up of all internal commands and constant values */
    register_command ("HELP", do_help, "<commandname> Displays help string for named commands and macros");

#if 0
    register_command ("LIST", do_list, "<commandname or partial> Lists all strings of command and macro");
    register_command ("SHOW", do_show, "<symbolname> Displays symbol values and macro contents");
    register_command ("DELETE", do_delete, "<symbolnames> Removes named symbols or macros");
    register_command ("IOBASE", do_base, "<hex/decimal> Sets default I/O radix for input and output");
    register_command ("VERIFY", do_verify, "<flag> Sets echo of commands for macro execution");
    register_command ("PRINT", do_print, "Formats and prints variables");
    register_command ("SOURCE", do_source, "<filestring><echoflag> Executes commands from named file");
    register_command ("SAVE", do_save, "<filestring><constflag> Saves macros, var, consts to file");
    register_command ("LOG", do_log, "<filestring><outputflag> Logs all command I/O to named file");
    assign_integer ("HEXADECIMAL", 16, 1);
    assign_integer ("DECIMAL", 10, 1);
    assign_integer ("OCTAL", 8, 1);
    assign_integer ("BINARY", 2, 1);
    assign_integer ("1", 1, 1);
    assign_integer ("0", 0, 1);
    assign_float ("PI", 3.14156, 1);
#endif

//    assign_string ("COMMAND_FILE", "default.com", 0);
//    assign_string ("LOG_FILE", "default.log", 0);
    /* call user defined setup for commands and symbols */
	if(setup_r)
		(*setup_r) ();
    macro_depth++;              /* increase nesting depth for initial input */
    
}

int cli_comand_line(char *input_line,char *target){
//	io_read (prompt_p, input_line, MAX_LINE_LEN);

    int            error = 0;
    int            exit = 0;
    int            not_done = 1;
    int            sav_echo=0;
    macro_t        *sav_macro_p;
    parse_t         pars={0};
    short           control_const=0;
    int            if_flag=0;    /* set if seen in the last line examined */
    int            if_taken=0;
	
    static char     cmd_delim[] = "= \\";  


	init_pars (&pars, input_line);
	get_tok (&pars, cmd_delim);
	
	//fprintf(stderr,"%s.%d [%s]\n\r",__func__,__LINE__,input_line);
	if(pars.tok_len ==0){
		return -1;
	}
	

		if (pars.tok_del == ' ')
		{
			/* allow any amount of white space before '=' in assignment */
			int 			i;
	
			i = pars.par_pos;
			while (input_line[i] == ' ')
				i++;
			if (input_line[i] == '=')
			{
				pars.tok_del = '=';
				pars.par_pos = i;
			}
		}
		if (pars.tok_del == '=')
		{
			/* try and make an assignment work out */
	
	
			if_flag = 0;
			strcpy (target, pars.token);
			get_tok (&pars, "");	/* tokenise rest of line */
			not_done = evaluate_assign (target, pars.token, &error, 0);
			if (not_done)
				/* attempt to execute a command or macro assignment */
				not_done = execute_command_line (pars.token, target, &error);
			if (not_done)
				not_done = execute_macro (pars.token, target, &error);
			if (not_done)
				tag_current_line (&pars, "Unrecognised assignment statement");
			/* Report an error in a separate fashion */
			if (error)
				print ("Assignment of \"%s\" failed\n", target);
		}
		else if (is_control (pars.token, &control_const))
		{
			switch (control_const)
			{
				case DEFINE_CONST:
					error = do_define (&pars);
					if_flag = 0;
					break;
				case IF_CONST:
					error = do_if (&pars, &if_taken);
					if (!error)
						if_flag = 1;
					break;
				case ELSE_CONST:
					if (!if_flag)
					{
						error = 1;
						tag_current_line (&pars, "ELSE not allowed without IF");
					}
					else
					{
						error = do_else (if_taken);
						if_flag = 0;
					}
					break;
				case WHILE_CONST:
					error = do_while (&pars);
					if_flag = 0;
					break;
				case FOR_CONST:
					error = do_for (&pars);
					if_flag = 0;
					break;
				default:
					tag_current_line (&pars, "Unable to understand control construct");
					error = 1;
					break;
			}
		}
		else
		{
			if_flag = 0;
			target[0] =0;
			not_done = execute_command_line (input_line,target, &error);
			//fprintf(stderr,"%s.%d traget[%s] not_done(%d) error(%d) \n\r",__func__,__LINE__,target,not_done,error);	
	
			if (not_done)
				not_done = execute_macro (input_line, target, &error);
			if (not_done)
			{
				tag_current_line (&pars, "Unrecognised command statement");
				error = 1;
			}
		}
	
	return error;
}


/* ========================================================================
   top level of the cli code, invokes top level shell
   ======================================================================== */
void            cli_run (char *ip_prompt_p, char *file_p)
{
  prompt_p = ip_prompt_p;
  int exit=0;
  while(exit==0){
     exit = command_loop ((macro_t *) NULL, 0, (char *) NULL, 0);
	 
  }
}
