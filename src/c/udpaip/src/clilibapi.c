 /*****************************************************************************

File name   : testtool.c

Description : testtool IOs




*****************************************************************************/
/* Includes --------------------------------------------------------------- */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#ifdef WIN32_CONSOLE
#include <windows.h>
void startConsoleWin(int width, int height, char* fname);
int WINAPI ConsoleHandlerRoutine( DWORD dwCtrlType  );

    FILE* __fStdOut = NULL;
    HANDLE __hStdOut = NULL;
	HANDLE __hStdIn = NULL;

int dprintf(char *fmt, ...);
int dfgets(char* Buffer, int BuffLen);

#endif


#define UART_ID 2

/* --- Device specific Includes ------------------------------------------- */
#include "clilib.h"
/* Local defines : command history and mode of output --------------------- */
/* #define ALLOW_UART_DEBUG */
#define NLINES             20
#define IO_CONSOLE         0x2
#define IO_UART            0x1
#define ST_NO_ERROR         0

    #define        WORD_LANES      1
    #define        WORD_SHIFT      1
    #define        FLASH_BASE      0x7FFC0000 /* base address of current sector */
    #define        NUM_SECTORS     38     /* number of sectors allowed in flash */
    #define        NUM_CHAR        40     /* number of characters per file name */
    #define        NLINES          20     /* number of lines into command histor*/
    #define        DIF_SECTORS      4     /* number of different kind of sectors*/
    #define        FAT_SECTOR      16     /* sector where the fat is            */

struct fat_t 
{
    char mode;                             /* mode must be 2 3 4 Megabytes  */
    char filename  [NUM_CHAR][NUM_SECTORS];/* table of filenames            */
    int  size      [NUM_SECTORS];          /* size for each file            */
    char ident     [NUM_SECTORS];          /* identificator for each file   */
    char fat_table [NUM_SECTORS];          /* summarizes where sectors are  */
    char drivename [NUM_CHAR];
    int            write_pointer;
    int            read_pointer ;
    unsigned char  command_history [80][NLINES];
};



static struct fat_t the_fat;


int UartRead(int CommID,char *msg,int count);
int UartWrite(int CommID,char *msg,int count);


/* Config data for the uart stuff ----------------------------------------- */
/* static semaphore_t io_sem; */
static int      UnStarted = 1;
//static int      io_mode;
static int      overwrite_mode = 0;     /* controls in uart mode the char

                                               overwrite function */
static unsigned char       each_line[200];
//static STUART_Handle_t      IOUart;
//extern partition_t          *file_partition;
/* ========================================================================
   local function to define a low level write to uart
   =========================================================================== */
int loc_uart_write ( unsigned char* Buffer, unsigned int ToWrite )
{
   // unsigned int Dummy;
    //STUART_Write ( IOUart , Buffer, ToWrite, &Dummy, 0 );
   // UartWrite(UART_ID,Buffer,ToWrite);
    fwrite(Buffer, 1, ToWrite,stdout);
    return ( 0 );
}
/* ========================================================================
   local function to define a low level read from uart
   =========================================================================== */
int loc_uart_read ( unsigned char * Buffer , unsigned int ToRead )
{
   // unsigned int Read=0;
    //STUART_Read ( IOUart , Buffer, ToRead, &Read , 0 );
   // UartRead(UART_ID, Buffer,ToRead);
   //fgets(stdio,Buffer);
   fread(Buffer, 1, ToRead,stdin);
   return ( ST_NO_ERROR );
}

/* ========================================================================
   iowrite to uart
   =========================================================================== */
int             io_write_uart (char *buffer)
{
    /* incorporates logic to add CR/LF to C like strings */
    unsigned int             i, j;

    /* exits but causes no error if the uart has not been configured */
   // if (UnStarted)
    //    return 0;
    /* semaphore_wait (&io_sem); */
    i = 0;
    j = 0;
    while (buffer[i] != 0)
    {
        while ((buffer[i] != '\n') && (buffer[i] != 0) && (i < 197))
        {
            each_line[j++] = buffer[i++];
        }
        if (buffer[i] == '\n')
        {
            each_line[j++] = '\r';
            each_line[j++] = '\n';
            each_line[j++] = 0;
            i++;
        }
        else
            each_line[j++] = 0;
        loc_uart_write ( each_line, j );
        j = 0;
    }
    /* semaphore_signal (&io_sem); */
    return (0);
}



/* ========================================================================
   ioread from uart. Emulates also some stuff to look like "doskey"
   character : any typable character
   Up        : repeat previous line in command history
   Down      : repeat forward
   Left      : go left if possible
   right     : go right if possible
   backspace : go back and erase current character
   Suppr     : suppression of one character forward
   Tab       : toggle insert/overwrite mode
   ======================================================================== */
int             io_read_uart (char *prompt, char *buffer, int buflen)
{
    unsigned char              c;
    unsigned char              capture[3];
    unsigned char              cc[3];
    int             cnt, cnt_pos;
    int             i;
    int            eol;
    int             double_key;

    /* semaphore_wait (&io_sem); */
    loc_uart_write ( (unsigned char *) prompt, strlen ((char *) prompt) );

    cnt = 0;
    cnt_pos = 0;
    eol = 0;
    buffer[0] = '\0';
    c = ' ';
    double_key = 0;

    /* read characters one by one and perform line editing functions before
       putting them in the read buffer. Characters are echoed as accepted. */
    while ((c != '\0') && (!eol) && (cnt < buflen))
    {
        loc_uart_read ( capture , 1 );
        c = capture[0];
        
        /* 1- Printable character */
        if (isprint (c) && (double_key == 0) && (cnt < 79))
        {
            if (cnt_pos == cnt)
            {
                /* add one character at end of line */
                buffer[cnt_pos] = c;
                cnt_pos++;
                cnt = cnt_pos;
                loc_uart_write ( &c , 1 );

            }
            else
            {
                /* we are in the middle of the chain */
                /* first case is we are in overwrite mode, just change the
                   character */
                if (overwrite_mode == 1)
                {
                    buffer[cnt_pos] = c;
                    cnt_pos++;
                    loc_uart_write ( &c , 1 );
                }
                else
                {               /* we have characters forward, we shift the
                                   buffer */
                    for (i = cnt; i > (cnt_pos - 1); i--)
                        buffer[i + 1] = buffer[i];
                    buffer[cnt_pos] = c;
                    /* now write the end of buffer and go back to cursor */
                    loc_uart_write ( (unsigned char *) (buffer + cnt_pos),cnt - cnt_pos + 1 );
                    cc[0] = '\b';
                    for (i = cnt_pos; i < cnt; i++)
                        loc_uart_write (cc,1 );
                    cnt_pos++;
                    cnt++;
                }               /* end of we are not in overwrite mode */
            }
        }                       /* end of printable character */

        /* 2- Return or end of line update the command history */
        if ((c == '\r') || (c == '\n'))
        {
            buffer[cnt++] = '\0';
            cc[0] = '\r';
            cc[1] = '\n';
            loc_uart_write ( cc,2);
            eol = 1;
            if (cnt != 1)
            {                   /* if chain was not empty */
                for (i = 0; i < cnt + 1; i++)
                    the_fat.command_history[i][the_fat.write_pointer] = buffer[i];
                the_fat.write_pointer++;
                if (the_fat.write_pointer == NLINES)
                    the_fat.write_pointer = 0;
                the_fat.read_pointer = the_fat.write_pointer;
            }
        }
        /* 3- back_space when possible, note that we may have to adapt the
           buffer if there are some data behind the cursor */
        if ((c == '\b') && (cnt > 0))
        {
            if (cnt_pos < cnt)
            {
                for (i = cnt_pos; i < cnt; i++)
                    buffer[i - 1] = buffer[i];
                buffer[cnt - 1] = ' ';
                cc[0] = '\b';
                loc_uart_write ( cc, 1 );
                loc_uart_write ( (unsigned char *) (buffer + cnt_pos - 1), cnt - cnt_pos + 1 );
                for (i = cnt_pos; i < (cnt + 1); i++)
                    loc_uart_write ( cc , 1 );
                cnt--;
                cnt_pos--;
            }
            else
            {                   /* end of line just remove the character */
                cnt--;
                cnt_pos--;
                cc[0] = '\b';
                cc[1] = ' ';
                cc[2] = '\b';
                loc_uart_write ( cc , 3 );
            }
        }
        /* 3b- suppression : remove one character from forward chain ( if
           there are some characters of course */
        if ((c == 127) && (cnt_pos != cnt))
        {
            for (i = cnt_pos + 1; i < cnt; i++)
                buffer[i - 1] = buffer[i];
            buffer[cnt - 1] = ' ';
            loc_uart_write ( (unsigned char *) (buffer + cnt_pos) , cnt - cnt_pos );
            for (i = cnt_pos; i < cnt; i++)
                loc_uart_write ( cc , 1 );
            cnt--;
        }
        /* 3a- tabulation : toggles the overwrite mode */
        if (c == 9)
        {
            if (overwrite_mode == 0)
                overwrite_mode = 1;
            else
                overwrite_mode = 0;
        }

        /* 4- significant character of DOUBLE key : down up right left */
        if (double_key == 2)
        {
            double_key = 0;
            /* 5- down key : get from command line history */
            if (c == 65)
            {
                if (the_fat.read_pointer == 0)
                    the_fat.read_pointer = NLINES - 1;
                else
                    the_fat.read_pointer--;
            }
            /* 6- up key : get from command line history */
            if (c == 66)
            {
                the_fat.read_pointer++;
                if (the_fat.read_pointer == NLINES)
                    the_fat.read_pointer = 0;
            }
            /* erase current line, display previous one */
            if ((c == 65) || (c == 66))
            {
                cc[0] = '\b';
                cc[1] = ' ';
                cc[2] = '\b';
                /* go forward to delete further text */
                while (cnt_pos < cnt)
                {
                    loc_uart_write ( cc+1 , 1 );
                    cnt_pos++;
                }
                /* go backward to remove existing text */
                while (cnt > 0)
                {
                    loc_uart_write ( cc , 3 );
                    cnt--;
                }
                cnt = 0;
                while ((the_fat.command_history[cnt][the_fat.read_pointer] != '\0')
                       && (cnt < 78))
                    cnt++;
                cnt_pos = cnt;
                for (i = 0; i < cnt; i++)
                    buffer[i] = the_fat.command_history[i][the_fat.read_pointer];
                for (i = cnt; i < 80; i++)
                    buffer[i] = '\0';
                loc_uart_write ( (unsigned char*) buffer , cnt );
            }                   /* end of rewrite the line */
            /* 7- left : go backward */
            if ((c == 68) && (cnt_pos > 0))
            {
                cnt_pos--;
                cc[0] = '\b';
                loc_uart_write ( cc, 1 );
            }
            /* 7- right : go forward */
            if ((c == 67) && (cnt_pos < cnt))
            {
                cc[0] = buffer[cnt_pos];
                loc_uart_write ( cc , 1 );
                cnt_pos++;
            }
        }                       /* end of case for doubled key */
        /* 8- if  suspicious DOUBLE key has been pressed, check it */
        if (double_key == 1)
        {
            if (c == 91)
                double_key = 2;
            else
                double_key = 0;
        }
        /* 9- escape : suspicious doubled key */
        if (c == 0x1b)
            double_key = 1;
    }
    /* semaphore_signal (&io_sem); */
    return (cnt);
}



/* ========================================================================
   iowrite on console
   ======================================================================== */
int             io_write_console (char *buffer)
{
#if WIN32_CONSOLE
	dprintf ("%s", buffer);
#else
    printf ("%s", buffer);
#endif
    return (0);
}
/* ========================================================================
   io_read from console
   ======================================================================== */






/* ========================================================================
   standard io_read from console or uart
   ======================================================================== */
int             io_read (char *prompt, char *buffer, int buflen)
{
   
  return (io_read_uart (prompt, buffer, buflen));
    
}
/* ========================================================================
   standard io_write to uart and/or console
   ======================================================================== */
int             io_write (char *buffer)
{
    
    io_write_uart (buffer);
    
    return 0;
}

/* ========================================================================
   testtool command that allows to prompt for one character entry :
   result : character returned
   filter : chain of char allowed
   caps   : 1, will return the key as typed ( example y or Y )
   0, will return all characters in lower case ( Y -> y )
   ======================================================================== */
char            io_getchar (char *filter, int case_sensitive)
{
    char            char_got;
    unsigned char              char_uart;
    unsigned int               actlen, i;
    int            has_matched = 0;

    

    while (1)
    {
        
            loc_uart_read ( &char_uart , 1 );
            char_got = (char) char_uart;
      
        
/* now check that char_got matches the filter */
        actlen = strlen (filter);
        for (i = 0; i < actlen; i++)
            if (filter[i] == char_got)
                has_matched = 1;
        if (has_matched == 1)
            break;
    }
/* now check if we have to change the case of the character */
    if ((case_sensitive == 0) &&
        (char_got >= 'A') &&
        (char_got <= 'Z'))
        char_got += 32;         /* switch to lower case */
    return (char_got);
}



/* ========================================================================
   cli_setup : register default routines
   ======================================================================== */
static int     cli_setup ()
{
    return (0);
}

/* ========================================================================
   initialize the command line interpreter
   =========================================================================== */

int            TesttoolInit (void)
{
    cli_init (cli_setup, 1000, 16);
    return 0;
}

/* ========================================================================
   run the command line interpreter
   =========================================================================== */
int            TesttoolRun (void)
{
  //  char           *file_name;
   memset(&the_fat,0,sizeof(the_fat));
	
 //   file_name = NULL;
    cli_run ("imx > ", "fff.ttm" );
    return 0;
}



//#error define WIN32_CONSOLE to run testtool!!
//int dprintf(char *fmt, ...)
//{
//	return 0;
//}



