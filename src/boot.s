/*
here we're declaring constants for the multiboot header 
*/

.set ALIGN,	1<<0	/*  align loaded modules on page boundried  */
.set MEMINFO,	1<<1	/*  provide memory map  */
.set FLAGS,	ALIGN|MEMINFO	/* this is Multiboot 'flag' field */
.set MAGIC, 	0x1BADB002	/* magic number lets bootloader */
.set CHECKSUM, -(MAGIC + FLAGS) /*


/*
here we're declaring a miltiboot header that marks the program as a kernel.
these are magic values that are documented in the multiboot standard, the obotloader will search for this signature in the first 8 KiB of the kernel file, aligned at a 32-bit boundry. this signature is in its own section so the header can be forced to be within the first 8 KiB of the kernel file. 
*/

.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

/*
the multiboot standard does not define the value of the stack pointer register (esp) and it is up to the kernel to provide a stack. this allocates room for a small stack by creating a symbol at bottom of it.
*/

.section .bss
.align 16
stack_bottom:
.skip 16384 # 16 KiB (1024 * 8 bytes)
stack_top:

/* 
the linker script specifies _start sa the entry point of the kernel.
*/

.section .text
.global _start
.type _start, @function
_start:
	/*
	the bootloader has loaded us into 32-bit protected mode on a x86 machine.text
	interrupts are disabled, paging is disabled, the processor state is defined as a multiboot standard.

	to set up the stack, we set the esp register to point to the top of the stack.
	languages such as C cannot operate without a stack
	*/
	mov $stack_top, %esp
	
	/* 
	this is a good place to initialize crutial processor  state before the high level kernel is entered.
	it's best to minimize the early enviroment where crucial features are offline. note that the processor is not fully initialized yet.
	
	features such as floating point instructions and instruction set extensions are not initialized yet. the GDT should be loaded here paging should be enabled here..
	C++ features such as global constructors and exceptions will require runtime support to work as well
	*/

	
	/*
	Enter a high level kernel. the ABI requires the stack is 16-byte aligned at the time of the call instruction (which afterwards pushes the return pointer of size of 4 bytes)
	the stack was originally 16-byte aligned above but we've pushed a multiple of 16 bytes to the stack since (pushed 0 bytes so far) so the aignment has thus been preserved and the call is well defined
	*/
	call kernel_main

	/*
	If the computer has nothing to do, put the computer into an infinite loop to do that we need to do a few things:

	1. disable interrupts with cli (clear interrupt enable in eflags). they are already disable by the bootloader so this is not needed.
	2. wait for the next interrupt to arrive with hlt (halt instruction) since they are disabled this will lock the computer.
	3. jump to the hlt instruction if it ever wakes up due to a non maskable interrupt occuring or due to system management
	*/

	cli
1:	hlt
	jmp 1b

/* 
set the size of the start symbol to the current location '.' minus its start.
this is useful when debugging or when you implement call tracing
*/

.size _start, .-_start
