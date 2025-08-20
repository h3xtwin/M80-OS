#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "vga.h"
#include "terminal.h"
#include "art/art.h"


#if defined(__linux__)
#error "You are not using a cross-compiler idiot"
#endif

#if !defined(__i386__)
#error "this needs to be compiled with a ix86-elf compiler"
#endif

extern size_t terminal_row;
extern size_t terminal_column;

void kernel_main(void) 
{
	terminal_initialize();
	
	for (size_t i = 0; i < sizeof(art)/sizeof(art[0]); i++) {
		terminal_writestring(art[i]);
		terminal_putchar('\n');
	    }
	terminal_row = 6;
	terminal_column = 40;
	terminal_writestring("PRESS ENTER TO OPEN COMMAND LINE ^_^");
	
	terminal_row = 23;
	terminal_column = 0;
	terminal_writestring("https://www.twitch.tv/mateymarc");


}

