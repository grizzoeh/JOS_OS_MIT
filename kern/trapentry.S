/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(F_DIVIDE_G, T_DIVIDE);
TRAPHANDLER_NOEC(F_DEBUG_G, T_DEBUG);
TRAPHANDLER_NOEC(F_NMI_G, T_NMI);
TRAPHANDLER_NOEC(F_BRKPT_G, T_BRKPT);
TRAPHANDLER_NOEC(F_OFLOW_G, T_OFLOW);
TRAPHANDLER_NOEC(F_BOUND_G, T_BOUND);
TRAPHANDLER_NOEC(F_ILLOP_G, T_ILLOP);
TRAPHANDLER_NOEC(F_DEVICE_G, T_DEVICE);
TRAPHANDLER(F_DBLFLT_G, T_DBLFLT)
TRAPHANDLER(F_COPROC_G, T_COPROC);
TRAPHANDLER_NOEC(F_RES_G, T_RES);
TRAPHANDLER_NOEC(F_FPERR_G, T_FPERR);
TRAPHANDLER(F_GPFLT_G, T_GPFLT);
TRAPHANDLER(F_TSS_G, T_TSS);
TRAPHANDLER_NOEC(F_MCHK_G, T_MCHK);
TRAPHANDLER(F_SEGNP_G, T_SEGNP);
TRAPHANDLER(F_ALIGN_G, T_ALIGN);
TRAPHANDLER(F_PGFLT_G, T_PGFLT);
TRAPHANDLER(F_STACK_G, T_STACK);
TRAPHANDLER_NOEC(F_SIMDERR_G, T_SIMDERR);
TRAPHANDLER_NOEC(F_SYSCALL_G, T_SYSCALL)
TRAPHANDLER_NOEC(F_DEFAULT_G, T_DEFAULT)
TRAPHANDLER_NOEC(IRQ_NUMBER_1, IRQ_OFFSET)
TRAPHANDLER_NOEC(IRQ_NUMBER_2, IRQ_OFFSET + IRQ_KBD)
TRAPHANDLER_NOEC(IRQ_NUMBER_3, IRQ_OFFSET + IRQ_SERIAL)


/*
 * Lab 3: Your code here for _alltraps
 */

 _alltraps:
	pushl %ds
	pushl %es
	pushal

	movw $GD_KD, %ax
	movw %ax, %ds
	movw %ax, %es

	pushl %esp
	call trap