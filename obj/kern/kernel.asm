
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
_start = RELOC(entry)

.globl entry
.func entry
entry:
	movw	$0x1234,0x472			# warm boot
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3

	# Turn on large pages using register %cr4 and flag CR4_PSE
    movl    %cr4, %eax
f010001d:	0f 20 e0             	mov    %cr4,%eax
    orl    $(CR4_PSE), %eax
f0100020:	83 c8 10             	or     $0x10,%eax
    movl    %eax, %cr4
f0100023:	0f 22 e0             	mov    %eax,%cr4

	# Turn on paging.
	movl	%cr0, %eax
f0100026:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100029:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f010002e:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100031:	b8 38 00 10 f0       	mov    $0xf0100038,%eax
	jmp	*%eax
f0100036:	ff e0                	jmp    *%eax

f0100038 <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f0100038:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f010003d:	bc 00 10 12 f0       	mov    $0xf0121000,%esp

	# now to C code
	call	i386_init
f0100042:	e8 83 01 00 00       	call   f01001ca <i386_init>

f0100047 <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f0100047:	eb fe                	jmp    f0100047 <spin>

f0100049 <lcr3>:
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0100049:	0f 22 d8             	mov    %eax,%cr3
}
f010004c:	c3                   	ret    

f010004d <xchg>:
	return tsc;
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
f010004d:	89 c1                	mov    %eax,%ecx
f010004f:	89 d0                	mov    %edx,%eax
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100051:	f0 87 01             	lock xchg %eax,(%ecx)
		     : "+m" (*addr), "=a" (result)
		     : "1" (newval)
		     : "cc");
	return result;
}
f0100054:	c3                   	ret    

f0100055 <lock_kernel>:

extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
f0100055:	55                   	push   %ebp
f0100056:	89 e5                	mov    %esp,%ebp
f0100058:	83 ec 14             	sub    $0x14,%esp
	spin_lock(&kernel_lock);
f010005b:	68 c0 23 12 f0       	push   $0xf01223c0
f0100060:	e8 90 61 00 00       	call   f01061f5 <spin_lock>
}
f0100065:	83 c4 10             	add    $0x10,%esp
f0100068:	c9                   	leave  
f0100069:	c3                   	ret    

f010006a <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
f010006a:	f3 0f 1e fb          	endbr32 
f010006e:	55                   	push   %ebp
f010006f:	89 e5                	mov    %esp,%ebp
f0100071:	56                   	push   %esi
f0100072:	53                   	push   %ebx
f0100073:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100076:	83 3d 80 2e 22 f0 00 	cmpl   $0x0,0xf0222e80
f010007d:	74 0f                	je     f010008e <_panic+0x24>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010007f:	83 ec 0c             	sub    $0xc,%esp
f0100082:	6a 00                	push   $0x0
f0100084:	e8 ea 0a 00 00       	call   f0100b73 <monitor>
f0100089:	83 c4 10             	add    $0x10,%esp
f010008c:	eb f1                	jmp    f010007f <_panic+0x15>
	panicstr = fmt;
f010008e:	89 35 80 2e 22 f0    	mov    %esi,0xf0222e80
	asm volatile("cli; cld");
f0100094:	fa                   	cli    
f0100095:	fc                   	cld    
	va_start(ap, fmt);
f0100096:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf(">>>\n>>> kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f0100099:	e8 52 5e 00 00       	call   f0105ef0 <cpunum>
f010009e:	ff 75 0c             	pushl  0xc(%ebp)
f01000a1:	ff 75 08             	pushl  0x8(%ebp)
f01000a4:	50                   	push   %eax
f01000a5:	68 a0 65 10 f0       	push   $0xf01065a0
f01000aa:	e8 61 38 00 00       	call   f0103910 <cprintf>
	vcprintf(fmt, ap);
f01000af:	83 c4 08             	add    $0x8,%esp
f01000b2:	53                   	push   %ebx
f01000b3:	56                   	push   %esi
f01000b4:	e8 2d 38 00 00       	call   f01038e6 <vcprintf>
	cprintf("\n>>>\n");
f01000b9:	c7 04 24 14 66 10 f0 	movl   $0xf0106614,(%esp)
f01000c0:	e8 4b 38 00 00       	call   f0103910 <cprintf>
f01000c5:	83 c4 10             	add    $0x10,%esp
f01000c8:	eb b5                	jmp    f010007f <_panic+0x15>

f01000ca <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f01000ca:	55                   	push   %ebp
f01000cb:	89 e5                	mov    %esp,%ebp
f01000cd:	53                   	push   %ebx
f01000ce:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f01000d1:	89 cb                	mov    %ecx,%ebx
f01000d3:	c1 eb 0c             	shr    $0xc,%ebx
f01000d6:	3b 1d 88 2e 22 f0    	cmp    0xf0222e88,%ebx
f01000dc:	73 0b                	jae    f01000e9 <_kaddr+0x1f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f01000de:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f01000e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01000e7:	c9                   	leave  
f01000e8:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000e9:	51                   	push   %ecx
f01000ea:	68 cc 65 10 f0       	push   $0xf01065cc
f01000ef:	52                   	push   %edx
f01000f0:	50                   	push   %eax
f01000f1:	e8 74 ff ff ff       	call   f010006a <_panic>

f01000f6 <_paddr>:
	if ((uint32_t)kva < KERNBASE)
f01000f6:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f01000fc:	76 07                	jbe    f0100105 <_paddr+0xf>
	return (physaddr_t)kva - KERNBASE;
f01000fe:	8d 81 00 00 00 10    	lea    0x10000000(%ecx),%eax
}
f0100104:	c3                   	ret    
{
f0100105:	55                   	push   %ebp
f0100106:	89 e5                	mov    %esp,%ebp
f0100108:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010010b:	51                   	push   %ecx
f010010c:	68 f0 65 10 f0       	push   $0xf01065f0
f0100111:	52                   	push   %edx
f0100112:	50                   	push   %eax
f0100113:	e8 52 ff ff ff       	call   f010006a <_panic>

f0100118 <boot_aps>:
{
f0100118:	55                   	push   %ebp
f0100119:	89 e5                	mov    %esp,%ebp
f010011b:	56                   	push   %esi
f010011c:	53                   	push   %ebx
	code = KADDR(MPENTRY_PADDR);
f010011d:	b9 00 70 00 00       	mov    $0x7000,%ecx
f0100122:	ba 62 00 00 00       	mov    $0x62,%edx
f0100127:	b8 1a 66 10 f0       	mov    $0xf010661a,%eax
f010012c:	e8 99 ff ff ff       	call   f01000ca <_kaddr>
f0100131:	89 c6                	mov    %eax,%esi
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100133:	83 ec 04             	sub    $0x4,%esp
f0100136:	b8 ee 5a 10 f0       	mov    $0xf0105aee,%eax
f010013b:	2d 6c 5a 10 f0       	sub    $0xf0105a6c,%eax
f0100140:	50                   	push   %eax
f0100141:	68 6c 5a 10 f0       	push   $0xf0105a6c
f0100146:	56                   	push   %esi
f0100147:	e8 61 57 00 00       	call   f01058ad <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f010014c:	83 c4 10             	add    $0x10,%esp
f010014f:	bb 20 30 22 f0       	mov    $0xf0223020,%ebx
f0100154:	eb 4a                	jmp    f01001a0 <boot_aps+0x88>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100156:	89 d8                	mov    %ebx,%eax
f0100158:	2d 20 30 22 f0       	sub    $0xf0223020,%eax
f010015d:	c1 f8 02             	sar    $0x2,%eax
f0100160:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100166:	c1 e0 0f             	shl    $0xf,%eax
f0100169:	8d 80 00 c0 22 f0    	lea    -0xfdd4000(%eax),%eax
f010016f:	a3 84 2e 22 f0       	mov    %eax,0xf0222e84
		lapic_startap(c->cpu_id, PADDR(code));
f0100174:	89 f1                	mov    %esi,%ecx
f0100176:	ba 6d 00 00 00       	mov    $0x6d,%edx
f010017b:	b8 1a 66 10 f0       	mov    $0xf010661a,%eax
f0100180:	e8 71 ff ff ff       	call   f01000f6 <_paddr>
f0100185:	83 ec 08             	sub    $0x8,%esp
f0100188:	50                   	push   %eax
f0100189:	0f b6 03             	movzbl (%ebx),%eax
f010018c:	50                   	push   %eax
f010018d:	e8 d2 5e 00 00       	call   f0106064 <lapic_startap>
		while (c->cpu_status != CPU_STARTED)
f0100192:	83 c4 10             	add    $0x10,%esp
f0100195:	8b 43 04             	mov    0x4(%ebx),%eax
f0100198:	83 f8 01             	cmp    $0x1,%eax
f010019b:	75 f8                	jne    f0100195 <boot_aps+0x7d>
	for (c = cpus; c < cpus + ncpu; c++) {
f010019d:	83 c3 74             	add    $0x74,%ebx
f01001a0:	6b 05 c4 33 22 f0 74 	imul   $0x74,0xf02233c4,%eax
f01001a7:	05 20 30 22 f0       	add    $0xf0223020,%eax
f01001ac:	39 c3                	cmp    %eax,%ebx
f01001ae:	73 13                	jae    f01001c3 <boot_aps+0xab>
		if (c == cpus + cpunum())  // We've started already.
f01001b0:	e8 3b 5d 00 00       	call   f0105ef0 <cpunum>
f01001b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01001b8:	05 20 30 22 f0       	add    $0xf0223020,%eax
f01001bd:	39 c3                	cmp    %eax,%ebx
f01001bf:	74 dc                	je     f010019d <boot_aps+0x85>
f01001c1:	eb 93                	jmp    f0100156 <boot_aps+0x3e>
}
f01001c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001c6:	5b                   	pop    %ebx
f01001c7:	5e                   	pop    %esi
f01001c8:	5d                   	pop    %ebp
f01001c9:	c3                   	ret    

f01001ca <i386_init>:
{
f01001ca:	f3 0f 1e fb          	endbr32 
f01001ce:	55                   	push   %ebp
f01001cf:	89 e5                	mov    %esp,%ebp
f01001d1:	83 ec 0c             	sub    $0xc,%esp
	memset(__bss_start, 0, end - __bss_start);
f01001d4:	b8 08 40 26 f0       	mov    $0xf0264008,%eax
f01001d9:	2d 00 10 22 f0       	sub    $0xf0221000,%eax
f01001de:	50                   	push   %eax
f01001df:	6a 00                	push   $0x0
f01001e1:	68 00 10 22 f0       	push   $0xf0221000
f01001e6:	e8 74 56 00 00       	call   f010585f <memset>
	cons_init();
f01001eb:	e8 1a 07 00 00       	call   f010090a <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01001f0:	83 c4 08             	add    $0x8,%esp
f01001f3:	68 ac 1a 00 00       	push   $0x1aac
f01001f8:	68 26 66 10 f0       	push   $0xf0106626
f01001fd:	e8 0e 37 00 00       	call   f0103910 <cprintf>
	mem_init();
f0100202:	e8 76 2a 00 00       	call   f0102c7d <mem_init>
	env_init();
f0100207:	e8 59 30 00 00       	call   f0103265 <env_init>
	trap_init();
f010020c:	e8 1a 38 00 00       	call   f0103a2b <trap_init>
	mp_init();
f0100211:	e8 1d 5b 00 00       	call   f0105d33 <mp_init>
	lapic_init();
f0100216:	e8 ef 5c 00 00       	call   f0105f0a <lapic_init>
	pic_init();
f010021b:	e8 a2 35 00 00       	call   f01037c2 <pic_init>
	lock_kernel();
f0100220:	e8 30 fe ff ff       	call   f0100055 <lock_kernel>
	boot_aps();
f0100225:	e8 ee fe ff ff       	call   f0100118 <boot_aps>
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010022a:	83 c4 08             	add    $0x8,%esp
f010022d:	6a 01                	push   $0x1
f010022f:	68 cc d2 1d f0       	push   $0xf01dd2cc
f0100234:	e8 7d 31 00 00       	call   f01033b6 <env_create>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100239:	83 c4 08             	add    $0x8,%esp
f010023c:	6a 00                	push   $0x0
f010023e:	68 38 07 21 f0       	push   $0xf0210738
f0100243:	e8 6e 31 00 00       	call   f01033b6 <env_create>
	kbd_intr();
f0100248:	e8 3c 06 00 00       	call   f0100889 <kbd_intr>
	sched_yield();
f010024d:	e8 dd 42 00 00       	call   f010452f <sched_yield>

f0100252 <mp_main>:
{
f0100252:	f3 0f 1e fb          	endbr32 
f0100256:	55                   	push   %ebp
f0100257:	89 e5                	mov    %esp,%ebp
f0100259:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f010025c:	8b 0d 8c 2e 22 f0    	mov    0xf0222e8c,%ecx
f0100262:	ba 79 00 00 00       	mov    $0x79,%edx
f0100267:	b8 1a 66 10 f0       	mov    $0xf010661a,%eax
f010026c:	e8 85 fe ff ff       	call   f01000f6 <_paddr>
f0100271:	e8 d3 fd ff ff       	call   f0100049 <lcr3>
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100276:	e8 75 5c 00 00       	call   f0105ef0 <cpunum>
f010027b:	83 ec 08             	sub    $0x8,%esp
f010027e:	50                   	push   %eax
f010027f:	68 41 66 10 f0       	push   $0xf0106641
f0100284:	e8 87 36 00 00       	call   f0103910 <cprintf>
	lapic_init();
f0100289:	e8 7c 5c 00 00       	call   f0105f0a <lapic_init>
	env_init_percpu();
f010028e:	e8 97 2f 00 00       	call   f010322a <env_init_percpu>
	trap_init_percpu();
f0100293:	e8 ea 36 00 00       	call   f0103982 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED);  // tell boot_aps() we're up
f0100298:	e8 53 5c 00 00       	call   f0105ef0 <cpunum>
f010029d:	6b c0 74             	imul   $0x74,%eax,%eax
f01002a0:	05 24 30 22 f0       	add    $0xf0223024,%eax
f01002a5:	ba 01 00 00 00       	mov    $0x1,%edx
f01002aa:	e8 9e fd ff ff       	call   f010004d <xchg>
	lock_kernel();
f01002af:	e8 a1 fd ff ff       	call   f0100055 <lock_kernel>
	sched_yield();
f01002b4:	e8 76 42 00 00       	call   f010452f <sched_yield>

f01002b9 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt, ...)
{
f01002b9:	f3 0f 1e fb          	endbr32 
f01002bd:	55                   	push   %ebp
f01002be:	89 e5                	mov    %esp,%ebp
f01002c0:	53                   	push   %ebx
f01002c1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01002c4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002c7:	ff 75 0c             	pushl  0xc(%ebp)
f01002ca:	ff 75 08             	pushl  0x8(%ebp)
f01002cd:	68 57 66 10 f0       	push   $0xf0106657
f01002d2:	e8 39 36 00 00       	call   f0103910 <cprintf>
	vcprintf(fmt, ap);
f01002d7:	83 c4 08             	add    $0x8,%esp
f01002da:	53                   	push   %ebx
f01002db:	ff 75 10             	pushl  0x10(%ebp)
f01002de:	e8 03 36 00 00       	call   f01038e6 <vcprintf>
	cprintf("\n");
f01002e3:	c7 04 24 bf 77 10 f0 	movl   $0xf01077bf,(%esp)
f01002ea:	e8 21 36 00 00       	call   f0103910 <cprintf>
	va_end(ap);
}
f01002ef:	83 c4 10             	add    $0x10,%esp
f01002f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002f5:	c9                   	leave  
f01002f6:	c3                   	ret    

f01002f7 <inb>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f7:	89 c2                	mov    %eax,%edx
f01002f9:	ec                   	in     (%dx),%al
}
f01002fa:	c3                   	ret    

f01002fb <outb>:
{
f01002fb:	89 c1                	mov    %eax,%ecx
f01002fd:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ff:	89 ca                	mov    %ecx,%edx
f0100301:	ee                   	out    %al,(%dx)
}
f0100302:	c3                   	ret    

f0100303 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100303:	55                   	push   %ebp
f0100304:	89 e5                	mov    %esp,%ebp
f0100306:	83 ec 08             	sub    $0x8,%esp
	inb(0x84);
f0100309:	b8 84 00 00 00       	mov    $0x84,%eax
f010030e:	e8 e4 ff ff ff       	call   f01002f7 <inb>
	inb(0x84);
f0100313:	b8 84 00 00 00       	mov    $0x84,%eax
f0100318:	e8 da ff ff ff       	call   f01002f7 <inb>
	inb(0x84);
f010031d:	b8 84 00 00 00       	mov    $0x84,%eax
f0100322:	e8 d0 ff ff ff       	call   f01002f7 <inb>
	inb(0x84);
f0100327:	b8 84 00 00 00       	mov    $0x84,%eax
f010032c:	e8 c6 ff ff ff       	call   f01002f7 <inb>
}
f0100331:	c9                   	leave  
f0100332:	c3                   	ret    

f0100333 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100333:	f3 0f 1e fb          	endbr32 
f0100337:	55                   	push   %ebp
f0100338:	89 e5                	mov    %esp,%ebp
f010033a:	83 ec 08             	sub    $0x8,%esp
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010033d:	b8 fd 03 00 00       	mov    $0x3fd,%eax
f0100342:	e8 b0 ff ff ff       	call   f01002f7 <inb>
f0100347:	a8 01                	test   $0x1,%al
f0100349:	74 0f                	je     f010035a <serial_proc_data+0x27>
		return -1;
	return inb(COM1+COM_RX);
f010034b:	b8 f8 03 00 00       	mov    $0x3f8,%eax
f0100350:	e8 a2 ff ff ff       	call   f01002f7 <inb>
f0100355:	0f b6 c0             	movzbl %al,%eax
}
f0100358:	c9                   	leave  
f0100359:	c3                   	ret    
		return -1;
f010035a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010035f:	eb f7                	jmp    f0100358 <serial_proc_data+0x25>

f0100361 <serial_putc>:
		cons_intr(serial_proc_data);
}

static void
serial_putc(int c)
{
f0100361:	55                   	push   %ebp
f0100362:	89 e5                	mov    %esp,%ebp
f0100364:	56                   	push   %esi
f0100365:	53                   	push   %ebx
f0100366:	89 c6                	mov    %eax,%esi
	int i;

	for (i = 0;
f0100368:	bb 00 00 00 00       	mov    $0x0,%ebx
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010036d:	b8 fd 03 00 00       	mov    $0x3fd,%eax
f0100372:	e8 80 ff ff ff       	call   f01002f7 <inb>
f0100377:	a8 20                	test   $0x20,%al
f0100379:	75 12                	jne    f010038d <serial_putc+0x2c>
f010037b:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100381:	7f 0a                	jg     f010038d <serial_putc+0x2c>
	     i++)
		delay();
f0100383:	e8 7b ff ff ff       	call   f0100303 <delay>
	     i++)
f0100388:	83 c3 01             	add    $0x1,%ebx
f010038b:	eb e0                	jmp    f010036d <serial_putc+0xc>

	outb(COM1 + COM_TX, c);
f010038d:	89 f0                	mov    %esi,%eax
f010038f:	0f b6 d0             	movzbl %al,%edx
f0100392:	b8 f8 03 00 00       	mov    $0x3f8,%eax
f0100397:	e8 5f ff ff ff       	call   f01002fb <outb>
}
f010039c:	5b                   	pop    %ebx
f010039d:	5e                   	pop    %esi
f010039e:	5d                   	pop    %ebp
f010039f:	c3                   	ret    

f01003a0 <lpt_putc>:
// For information on PC parallel port programming, see the class References
// page.

static void
lpt_putc(int c)
{
f01003a0:	55                   	push   %ebp
f01003a1:	89 e5                	mov    %esp,%ebp
f01003a3:	56                   	push   %esi
f01003a4:	53                   	push   %ebx
f01003a5:	89 c6                	mov    %eax,%esi
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003a7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003ac:	b8 79 03 00 00       	mov    $0x379,%eax
f01003b1:	e8 41 ff ff ff       	call   f01002f7 <inb>
f01003b6:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01003bc:	7f 0e                	jg     f01003cc <lpt_putc+0x2c>
f01003be:	84 c0                	test   %al,%al
f01003c0:	78 0a                	js     f01003cc <lpt_putc+0x2c>
		delay();
f01003c2:	e8 3c ff ff ff       	call   f0100303 <delay>
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003c7:	83 c3 01             	add    $0x1,%ebx
f01003ca:	eb e0                	jmp    f01003ac <lpt_putc+0xc>
	outb(0x378+0, c);
f01003cc:	89 f0                	mov    %esi,%eax
f01003ce:	0f b6 d0             	movzbl %al,%edx
f01003d1:	b8 78 03 00 00       	mov    $0x378,%eax
f01003d6:	e8 20 ff ff ff       	call   f01002fb <outb>
	outb(0x378+2, 0x08|0x04|0x01);
f01003db:	ba 0d 00 00 00       	mov    $0xd,%edx
f01003e0:	b8 7a 03 00 00       	mov    $0x37a,%eax
f01003e5:	e8 11 ff ff ff       	call   f01002fb <outb>
	outb(0x378+2, 0x08);
f01003ea:	ba 08 00 00 00       	mov    $0x8,%edx
f01003ef:	b8 7a 03 00 00       	mov    $0x37a,%eax
f01003f4:	e8 02 ff ff ff       	call   f01002fb <outb>
}
f01003f9:	5b                   	pop    %ebx
f01003fa:	5e                   	pop    %esi
f01003fb:	5d                   	pop    %ebp
f01003fc:	c3                   	ret    

f01003fd <cga_init>:
static uint16_t *crt_buf;
static uint16_t crt_pos;

static void
cga_init(void)
{
f01003fd:	55                   	push   %ebp
f01003fe:	89 e5                	mov    %esp,%ebp
f0100400:	57                   	push   %edi
f0100401:	56                   	push   %esi
f0100402:	53                   	push   %ebx
f0100403:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100406:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010040d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100414:	5a a5 
	if (*cp != 0xA55A) {
f0100416:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010041d:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100421:	74 63                	je     f0100486 <cga_init+0x89>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100423:	c7 05 30 12 22 f0 b4 	movl   $0x3b4,0xf0221230
f010042a:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010042d:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100434:	8b 35 30 12 22 f0    	mov    0xf0221230,%esi
f010043a:	ba 0e 00 00 00       	mov    $0xe,%edx
f010043f:	89 f0                	mov    %esi,%eax
f0100441:	e8 b5 fe ff ff       	call   f01002fb <outb>
	pos = inb(addr_6845 + 1) << 8;
f0100446:	8d 7e 01             	lea    0x1(%esi),%edi
f0100449:	89 f8                	mov    %edi,%eax
f010044b:	e8 a7 fe ff ff       	call   f01002f7 <inb>
f0100450:	0f b6 d8             	movzbl %al,%ebx
f0100453:	c1 e3 08             	shl    $0x8,%ebx
	outb(addr_6845, 15);
f0100456:	ba 0f 00 00 00       	mov    $0xf,%edx
f010045b:	89 f0                	mov    %esi,%eax
f010045d:	e8 99 fe ff ff       	call   f01002fb <outb>
	pos |= inb(addr_6845 + 1);
f0100462:	89 f8                	mov    %edi,%eax
f0100464:	e8 8e fe ff ff       	call   f01002f7 <inb>

	crt_buf = (uint16_t*) cp;
f0100469:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010046c:	89 0d 2c 12 22 f0    	mov    %ecx,0xf022122c
	pos |= inb(addr_6845 + 1);
f0100472:	0f b6 c0             	movzbl %al,%eax
f0100475:	09 c3                	or     %eax,%ebx
	crt_pos = pos;
f0100477:	66 89 1d 28 12 22 f0 	mov    %bx,0xf0221228
}
f010047e:	83 c4 1c             	add    $0x1c,%esp
f0100481:	5b                   	pop    %ebx
f0100482:	5e                   	pop    %esi
f0100483:	5f                   	pop    %edi
f0100484:	5d                   	pop    %ebp
f0100485:	c3                   	ret    
		*cp = was;
f0100486:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010048d:	c7 05 30 12 22 f0 d4 	movl   $0x3d4,0xf0221230
f0100494:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100497:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f010049e:	eb 94                	jmp    f0100434 <cga_init+0x37>

f01004a0 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01004a0:	55                   	push   %ebp
f01004a1:	89 e5                	mov    %esp,%ebp
f01004a3:	53                   	push   %ebx
f01004a4:	83 ec 04             	sub    $0x4,%esp
f01004a7:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01004a9:	ff d3                	call   *%ebx
f01004ab:	83 f8 ff             	cmp    $0xffffffff,%eax
f01004ae:	74 29                	je     f01004d9 <cons_intr+0x39>
		if (c == 0)
f01004b0:	85 c0                	test   %eax,%eax
f01004b2:	74 f5                	je     f01004a9 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f01004b4:	8b 0d 24 12 22 f0    	mov    0xf0221224,%ecx
f01004ba:	8d 51 01             	lea    0x1(%ecx),%edx
f01004bd:	88 81 20 10 22 f0    	mov    %al,-0xfddefe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01004c3:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01004c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01004ce:	0f 44 d0             	cmove  %eax,%edx
f01004d1:	89 15 24 12 22 f0    	mov    %edx,0xf0221224
f01004d7:	eb d0                	jmp    f01004a9 <cons_intr+0x9>
	}
}
f01004d9:	83 c4 04             	add    $0x4,%esp
f01004dc:	5b                   	pop    %ebx
f01004dd:	5d                   	pop    %ebp
f01004de:	c3                   	ret    

f01004df <kbd_proc_data>:
{
f01004df:	f3 0f 1e fb          	endbr32 
f01004e3:	55                   	push   %ebp
f01004e4:	89 e5                	mov    %esp,%ebp
f01004e6:	53                   	push   %ebx
f01004e7:	83 ec 04             	sub    $0x4,%esp
	stat = inb(KBSTATP);
f01004ea:	b8 64 00 00 00       	mov    $0x64,%eax
f01004ef:	e8 03 fe ff ff       	call   f01002f7 <inb>
	if ((stat & KBS_DIB) == 0)
f01004f4:	a8 01                	test   $0x1,%al
f01004f6:	0f 84 f7 00 00 00    	je     f01005f3 <kbd_proc_data+0x114>
	if (stat & KBS_TERR)
f01004fc:	a8 20                	test   $0x20,%al
f01004fe:	0f 85 f6 00 00 00    	jne    f01005fa <kbd_proc_data+0x11b>
	data = inb(KBDATAP);
f0100504:	b8 60 00 00 00       	mov    $0x60,%eax
f0100509:	e8 e9 fd ff ff       	call   f01002f7 <inb>
	if (data == 0xE0) {
f010050e:	3c e0                	cmp    $0xe0,%al
f0100510:	74 61                	je     f0100573 <kbd_proc_data+0x94>
	} else if (data & 0x80) {
f0100512:	84 c0                	test   %al,%al
f0100514:	78 70                	js     f0100586 <kbd_proc_data+0xa7>
	} else if (shift & E0ESC) {
f0100516:	8b 15 00 10 22 f0    	mov    0xf0221000,%edx
f010051c:	f6 c2 40             	test   $0x40,%dl
f010051f:	74 0c                	je     f010052d <kbd_proc_data+0x4e>
		data |= 0x80;
f0100521:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f0100524:	83 e2 bf             	and    $0xffffffbf,%edx
f0100527:	89 15 00 10 22 f0    	mov    %edx,0xf0221000
	shift |= shiftcode[data];
f010052d:	0f b6 c0             	movzbl %al,%eax
f0100530:	0f b6 90 c0 67 10 f0 	movzbl -0xfef9840(%eax),%edx
f0100537:	0b 15 00 10 22 f0    	or     0xf0221000,%edx
	shift ^= togglecode[data];
f010053d:	0f b6 88 c0 66 10 f0 	movzbl -0xfef9940(%eax),%ecx
f0100544:	31 ca                	xor    %ecx,%edx
f0100546:	89 15 00 10 22 f0    	mov    %edx,0xf0221000
	c = charcode[shift & (CTL | SHIFT)][data];
f010054c:	89 d1                	mov    %edx,%ecx
f010054e:	83 e1 03             	and    $0x3,%ecx
f0100551:	8b 0c 8d a0 66 10 f0 	mov    -0xfef9960(,%ecx,4),%ecx
f0100558:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
f010055c:	0f b6 d8             	movzbl %al,%ebx
	if (shift & CAPSLOCK) {
f010055f:	f6 c2 08             	test   $0x8,%dl
f0100562:	74 5f                	je     f01005c3 <kbd_proc_data+0xe4>
		if ('a' <= c && c <= 'z')
f0100564:	89 d8                	mov    %ebx,%eax
f0100566:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100569:	83 f9 19             	cmp    $0x19,%ecx
f010056c:	77 49                	ja     f01005b7 <kbd_proc_data+0xd8>
			c += 'A' - 'a';
f010056e:	83 eb 20             	sub    $0x20,%ebx
f0100571:	eb 0c                	jmp    f010057f <kbd_proc_data+0xa0>
		shift |= E0ESC;
f0100573:	83 0d 00 10 22 f0 40 	orl    $0x40,0xf0221000
		return 0;
f010057a:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010057f:	89 d8                	mov    %ebx,%eax
f0100581:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100584:	c9                   	leave  
f0100585:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100586:	8b 15 00 10 22 f0    	mov    0xf0221000,%edx
f010058c:	89 c1                	mov    %eax,%ecx
f010058e:	83 e1 7f             	and    $0x7f,%ecx
f0100591:	f6 c2 40             	test   $0x40,%dl
f0100594:	0f 44 c1             	cmove  %ecx,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f0100597:	0f b6 c0             	movzbl %al,%eax
f010059a:	0f b6 80 c0 67 10 f0 	movzbl -0xfef9840(%eax),%eax
f01005a1:	83 c8 40             	or     $0x40,%eax
f01005a4:	0f b6 c0             	movzbl %al,%eax
f01005a7:	f7 d0                	not    %eax
f01005a9:	21 d0                	and    %edx,%eax
f01005ab:	a3 00 10 22 f0       	mov    %eax,0xf0221000
		return 0;
f01005b0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01005b5:	eb c8                	jmp    f010057f <kbd_proc_data+0xa0>
		else if ('A' <= c && c <= 'Z')
f01005b7:	83 e8 41             	sub    $0x41,%eax
			c += 'a' - 'A';
f01005ba:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01005bd:	83 f8 1a             	cmp    $0x1a,%eax
f01005c0:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005c3:	f7 d2                	not    %edx
f01005c5:	f6 c2 06             	test   $0x6,%dl
f01005c8:	75 b5                	jne    f010057f <kbd_proc_data+0xa0>
f01005ca:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005d0:	75 ad                	jne    f010057f <kbd_proc_data+0xa0>
		cprintf("Rebooting!\n");
f01005d2:	83 ec 0c             	sub    $0xc,%esp
f01005d5:	68 71 66 10 f0       	push   $0xf0106671
f01005da:	e8 31 33 00 00       	call   f0103910 <cprintf>
		outb(0x92, 0x3); // courtesy of Chris Frost
f01005df:	ba 03 00 00 00       	mov    $0x3,%edx
f01005e4:	b8 92 00 00 00       	mov    $0x92,%eax
f01005e9:	e8 0d fd ff ff       	call   f01002fb <outb>
f01005ee:	83 c4 10             	add    $0x10,%esp
f01005f1:	eb 8c                	jmp    f010057f <kbd_proc_data+0xa0>
		return -1;
f01005f3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01005f8:	eb 85                	jmp    f010057f <kbd_proc_data+0xa0>
		return -1;
f01005fa:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01005ff:	e9 7b ff ff ff       	jmp    f010057f <kbd_proc_data+0xa0>

f0100604 <serial_init>:
{
f0100604:	55                   	push   %ebp
f0100605:	89 e5                	mov    %esp,%ebp
f0100607:	53                   	push   %ebx
f0100608:	83 ec 04             	sub    $0x4,%esp
	outb(COM1+COM_FCR, 0);
f010060b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100610:	b8 fa 03 00 00       	mov    $0x3fa,%eax
f0100615:	e8 e1 fc ff ff       	call   f01002fb <outb>
	outb(COM1+COM_LCR, COM_LCR_DLAB);
f010061a:	ba 80 00 00 00       	mov    $0x80,%edx
f010061f:	b8 fb 03 00 00       	mov    $0x3fb,%eax
f0100624:	e8 d2 fc ff ff       	call   f01002fb <outb>
	outb(COM1+COM_DLL, (uint8_t) (115200 / 9600));
f0100629:	ba 0c 00 00 00       	mov    $0xc,%edx
f010062e:	b8 f8 03 00 00       	mov    $0x3f8,%eax
f0100633:	e8 c3 fc ff ff       	call   f01002fb <outb>
	outb(COM1+COM_DLM, 0);
f0100638:	ba 00 00 00 00       	mov    $0x0,%edx
f010063d:	b8 f9 03 00 00       	mov    $0x3f9,%eax
f0100642:	e8 b4 fc ff ff       	call   f01002fb <outb>
	outb(COM1+COM_LCR, COM_LCR_WLEN8 & ~COM_LCR_DLAB);
f0100647:	ba 03 00 00 00       	mov    $0x3,%edx
f010064c:	b8 fb 03 00 00       	mov    $0x3fb,%eax
f0100651:	e8 a5 fc ff ff       	call   f01002fb <outb>
	outb(COM1+COM_MCR, 0);
f0100656:	ba 00 00 00 00       	mov    $0x0,%edx
f010065b:	b8 fc 03 00 00       	mov    $0x3fc,%eax
f0100660:	e8 96 fc ff ff       	call   f01002fb <outb>
	outb(COM1+COM_IER, COM_IER_RDI);
f0100665:	ba 01 00 00 00       	mov    $0x1,%edx
f010066a:	b8 f9 03 00 00       	mov    $0x3f9,%eax
f010066f:	e8 87 fc ff ff       	call   f01002fb <outb>
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100674:	b8 fd 03 00 00       	mov    $0x3fd,%eax
f0100679:	e8 79 fc ff ff       	call   f01002f7 <inb>
f010067e:	89 c3                	mov    %eax,%ebx
f0100680:	3c ff                	cmp    $0xff,%al
f0100682:	0f 95 05 34 12 22 f0 	setne  0xf0221234
	(void) inb(COM1+COM_IIR);
f0100689:	b8 fa 03 00 00       	mov    $0x3fa,%eax
f010068e:	e8 64 fc ff ff       	call   f01002f7 <inb>
	(void) inb(COM1+COM_RX);
f0100693:	b8 f8 03 00 00       	mov    $0x3f8,%eax
f0100698:	e8 5a fc ff ff       	call   f01002f7 <inb>
	if (serial_exists)
f010069d:	80 fb ff             	cmp    $0xff,%bl
f01006a0:	75 05                	jne    f01006a7 <serial_init+0xa3>
}
f01006a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01006a5:	c9                   	leave  
f01006a6:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f01006a7:	83 ec 0c             	sub    $0xc,%esp
f01006aa:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01006b1:	25 ef ff 00 00       	and    $0xffef,%eax
f01006b6:	50                   	push   %eax
f01006b7:	e8 79 30 00 00       	call   f0103735 <irq_setmask_8259A>
f01006bc:	83 c4 10             	add    $0x10,%esp
}
f01006bf:	eb e1                	jmp    f01006a2 <serial_init+0x9e>

f01006c1 <cga_putc>:
{
f01006c1:	55                   	push   %ebp
f01006c2:	89 e5                	mov    %esp,%ebp
f01006c4:	57                   	push   %edi
f01006c5:	56                   	push   %esi
f01006c6:	53                   	push   %ebx
f01006c7:	83 ec 0c             	sub    $0xc,%esp
		c |= 0x0700;
f01006ca:	89 c2                	mov    %eax,%edx
f01006cc:	80 ce 07             	or     $0x7,%dh
f01006cf:	a9 00 ff ff ff       	test   $0xffffff00,%eax
f01006d4:	0f 44 c2             	cmove  %edx,%eax
	switch (c & 0xff) {
f01006d7:	3c 0a                	cmp    $0xa,%al
f01006d9:	0f 84 f0 00 00 00    	je     f01007cf <cga_putc+0x10e>
f01006df:	0f b6 d0             	movzbl %al,%edx
f01006e2:	83 fa 0a             	cmp    $0xa,%edx
f01006e5:	7f 46                	jg     f010072d <cga_putc+0x6c>
f01006e7:	83 fa 08             	cmp    $0x8,%edx
f01006ea:	0f 84 b5 00 00 00    	je     f01007a5 <cga_putc+0xe4>
f01006f0:	83 fa 09             	cmp    $0x9,%edx
f01006f3:	0f 85 e3 00 00 00    	jne    f01007dc <cga_putc+0x11b>
		cons_putc(' ');
f01006f9:	b8 20 00 00 00       	mov    $0x20,%eax
f01006fe:	e8 44 01 00 00       	call   f0100847 <cons_putc>
		cons_putc(' ');
f0100703:	b8 20 00 00 00       	mov    $0x20,%eax
f0100708:	e8 3a 01 00 00       	call   f0100847 <cons_putc>
		cons_putc(' ');
f010070d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100712:	e8 30 01 00 00       	call   f0100847 <cons_putc>
		cons_putc(' ');
f0100717:	b8 20 00 00 00       	mov    $0x20,%eax
f010071c:	e8 26 01 00 00       	call   f0100847 <cons_putc>
		cons_putc(' ');
f0100721:	b8 20 00 00 00       	mov    $0x20,%eax
f0100726:	e8 1c 01 00 00       	call   f0100847 <cons_putc>
		break;
f010072b:	eb 25                	jmp    f0100752 <cga_putc+0x91>
	switch (c & 0xff) {
f010072d:	83 fa 0d             	cmp    $0xd,%edx
f0100730:	0f 85 a6 00 00 00    	jne    f01007dc <cga_putc+0x11b>
		crt_pos -= (crt_pos % CRT_COLS);
f0100736:	0f b7 05 28 12 22 f0 	movzwl 0xf0221228,%eax
f010073d:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100743:	c1 e8 16             	shr    $0x16,%eax
f0100746:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100749:	c1 e0 04             	shl    $0x4,%eax
f010074c:	66 a3 28 12 22 f0    	mov    %ax,0xf0221228
	if (crt_pos >= CRT_SIZE) {
f0100752:	66 81 3d 28 12 22 f0 	cmpw   $0x7cf,0xf0221228
f0100759:	cf 07 
f010075b:	0f 87 9e 00 00 00    	ja     f01007ff <cga_putc+0x13e>
	outb(addr_6845, 14);
f0100761:	8b 3d 30 12 22 f0    	mov    0xf0221230,%edi
f0100767:	ba 0e 00 00 00       	mov    $0xe,%edx
f010076c:	89 f8                	mov    %edi,%eax
f010076e:	e8 88 fb ff ff       	call   f01002fb <outb>
	outb(addr_6845 + 1, crt_pos >> 8);
f0100773:	0f b7 1d 28 12 22 f0 	movzwl 0xf0221228,%ebx
f010077a:	8d 77 01             	lea    0x1(%edi),%esi
f010077d:	0f b6 d7             	movzbl %bh,%edx
f0100780:	89 f0                	mov    %esi,%eax
f0100782:	e8 74 fb ff ff       	call   f01002fb <outb>
	outb(addr_6845, 15);
f0100787:	ba 0f 00 00 00       	mov    $0xf,%edx
f010078c:	89 f8                	mov    %edi,%eax
f010078e:	e8 68 fb ff ff       	call   f01002fb <outb>
	outb(addr_6845 + 1, crt_pos);
f0100793:	0f b6 d3             	movzbl %bl,%edx
f0100796:	89 f0                	mov    %esi,%eax
f0100798:	e8 5e fb ff ff       	call   f01002fb <outb>
}
f010079d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007a0:	5b                   	pop    %ebx
f01007a1:	5e                   	pop    %esi
f01007a2:	5f                   	pop    %edi
f01007a3:	5d                   	pop    %ebp
f01007a4:	c3                   	ret    
		if (crt_pos > 0) {
f01007a5:	0f b7 15 28 12 22 f0 	movzwl 0xf0221228,%edx
f01007ac:	66 85 d2             	test   %dx,%dx
f01007af:	74 b0                	je     f0100761 <cga_putc+0xa0>
			crt_pos--;
f01007b1:	83 ea 01             	sub    $0x1,%edx
f01007b4:	66 89 15 28 12 22 f0 	mov    %dx,0xf0221228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01007bb:	0f b7 d2             	movzwl %dx,%edx
f01007be:	b0 00                	mov    $0x0,%al
f01007c0:	83 c8 20             	or     $0x20,%eax
f01007c3:	8b 0d 2c 12 22 f0    	mov    0xf022122c,%ecx
f01007c9:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
f01007cd:	eb 83                	jmp    f0100752 <cga_putc+0x91>
		crt_pos += CRT_COLS;
f01007cf:	66 83 05 28 12 22 f0 	addw   $0x50,0xf0221228
f01007d6:	50 
f01007d7:	e9 5a ff ff ff       	jmp    f0100736 <cga_putc+0x75>
		crt_buf[crt_pos++] = c;		/* write the character */
f01007dc:	0f b7 15 28 12 22 f0 	movzwl 0xf0221228,%edx
f01007e3:	8d 4a 01             	lea    0x1(%edx),%ecx
f01007e6:	66 89 0d 28 12 22 f0 	mov    %cx,0xf0221228
f01007ed:	0f b7 d2             	movzwl %dx,%edx
f01007f0:	8b 0d 2c 12 22 f0    	mov    0xf022122c,%ecx
f01007f6:	66 89 04 51          	mov    %ax,(%ecx,%edx,2)
		break;
f01007fa:	e9 53 ff ff ff       	jmp    f0100752 <cga_putc+0x91>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01007ff:	a1 2c 12 22 f0       	mov    0xf022122c,%eax
f0100804:	83 ec 04             	sub    $0x4,%esp
f0100807:	68 00 0f 00 00       	push   $0xf00
f010080c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100812:	52                   	push   %edx
f0100813:	50                   	push   %eax
f0100814:	e8 94 50 00 00       	call   f01058ad <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100819:	8b 15 2c 12 22 f0    	mov    0xf022122c,%edx
f010081f:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100825:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010082b:	83 c4 10             	add    $0x10,%esp
f010082e:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100833:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100836:	39 d0                	cmp    %edx,%eax
f0100838:	75 f4                	jne    f010082e <cga_putc+0x16d>
		crt_pos -= CRT_COLS;
f010083a:	66 83 2d 28 12 22 f0 	subw   $0x50,0xf0221228
f0100841:	50 
f0100842:	e9 1a ff ff ff       	jmp    f0100761 <cga_putc+0xa0>

f0100847 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100847:	55                   	push   %ebp
f0100848:	89 e5                	mov    %esp,%ebp
f010084a:	53                   	push   %ebx
f010084b:	83 ec 04             	sub    $0x4,%esp
f010084e:	89 c3                	mov    %eax,%ebx
	serial_putc(c);
f0100850:	e8 0c fb ff ff       	call   f0100361 <serial_putc>
	lpt_putc(c);
f0100855:	89 d8                	mov    %ebx,%eax
f0100857:	e8 44 fb ff ff       	call   f01003a0 <lpt_putc>
	cga_putc(c);
f010085c:	89 d8                	mov    %ebx,%eax
f010085e:	e8 5e fe ff ff       	call   f01006c1 <cga_putc>
}
f0100863:	83 c4 04             	add    $0x4,%esp
f0100866:	5b                   	pop    %ebx
f0100867:	5d                   	pop    %ebp
f0100868:	c3                   	ret    

f0100869 <serial_intr>:
{
f0100869:	f3 0f 1e fb          	endbr32 
	if (serial_exists)
f010086d:	80 3d 34 12 22 f0 00 	cmpb   $0x0,0xf0221234
f0100874:	75 01                	jne    f0100877 <serial_intr+0xe>
f0100876:	c3                   	ret    
{
f0100877:	55                   	push   %ebp
f0100878:	89 e5                	mov    %esp,%ebp
f010087a:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010087d:	b8 33 03 10 f0       	mov    $0xf0100333,%eax
f0100882:	e8 19 fc ff ff       	call   f01004a0 <cons_intr>
}
f0100887:	c9                   	leave  
f0100888:	c3                   	ret    

f0100889 <kbd_intr>:
{
f0100889:	f3 0f 1e fb          	endbr32 
f010088d:	55                   	push   %ebp
f010088e:	89 e5                	mov    %esp,%ebp
f0100890:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100893:	b8 df 04 10 f0       	mov    $0xf01004df,%eax
f0100898:	e8 03 fc ff ff       	call   f01004a0 <cons_intr>
}
f010089d:	c9                   	leave  
f010089e:	c3                   	ret    

f010089f <kbd_init>:
{
f010089f:	55                   	push   %ebp
f01008a0:	89 e5                	mov    %esp,%ebp
f01008a2:	83 ec 08             	sub    $0x8,%esp
	kbd_intr();
f01008a5:	e8 df ff ff ff       	call   f0100889 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01008aa:	83 ec 0c             	sub    $0xc,%esp
f01008ad:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01008b4:	25 fd ff 00 00       	and    $0xfffd,%eax
f01008b9:	50                   	push   %eax
f01008ba:	e8 76 2e 00 00       	call   f0103735 <irq_setmask_8259A>
}
f01008bf:	83 c4 10             	add    $0x10,%esp
f01008c2:	c9                   	leave  
f01008c3:	c3                   	ret    

f01008c4 <cons_getc>:
{
f01008c4:	f3 0f 1e fb          	endbr32 
f01008c8:	55                   	push   %ebp
f01008c9:	89 e5                	mov    %esp,%ebp
f01008cb:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01008ce:	e8 96 ff ff ff       	call   f0100869 <serial_intr>
	kbd_intr();
f01008d3:	e8 b1 ff ff ff       	call   f0100889 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01008d8:	a1 20 12 22 f0       	mov    0xf0221220,%eax
	return 0;
f01008dd:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01008e2:	3b 05 24 12 22 f0    	cmp    0xf0221224,%eax
f01008e8:	74 1c                	je     f0100906 <cons_getc+0x42>
		c = cons.buf[cons.rpos++];
f01008ea:	8d 48 01             	lea    0x1(%eax),%ecx
f01008ed:	0f b6 90 20 10 22 f0 	movzbl -0xfddefe0(%eax),%edx
			cons.rpos = 0;
f01008f4:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01008f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01008fe:	0f 45 c1             	cmovne %ecx,%eax
f0100901:	a3 20 12 22 f0       	mov    %eax,0xf0221220
}
f0100906:	89 d0                	mov    %edx,%eax
f0100908:	c9                   	leave  
f0100909:	c3                   	ret    

f010090a <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010090a:	f3 0f 1e fb          	endbr32 
f010090e:	55                   	push   %ebp
f010090f:	89 e5                	mov    %esp,%ebp
f0100911:	83 ec 08             	sub    $0x8,%esp
	cga_init();
f0100914:	e8 e4 fa ff ff       	call   f01003fd <cga_init>
	kbd_init();
f0100919:	e8 81 ff ff ff       	call   f010089f <kbd_init>
	serial_init();
f010091e:	e8 e1 fc ff ff       	call   f0100604 <serial_init>

	if (!serial_exists)
f0100923:	80 3d 34 12 22 f0 00 	cmpb   $0x0,0xf0221234
f010092a:	74 02                	je     f010092e <cons_init+0x24>
		cprintf("Serial port does not exist!\n");
}
f010092c:	c9                   	leave  
f010092d:	c3                   	ret    
		cprintf("Serial port does not exist!\n");
f010092e:	83 ec 0c             	sub    $0xc,%esp
f0100931:	68 7d 66 10 f0       	push   $0xf010667d
f0100936:	e8 d5 2f 00 00       	call   f0103910 <cprintf>
f010093b:	83 c4 10             	add    $0x10,%esp
}
f010093e:	eb ec                	jmp    f010092c <cons_init+0x22>

f0100940 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100940:	f3 0f 1e fb          	endbr32 
f0100944:	55                   	push   %ebp
f0100945:	89 e5                	mov    %esp,%ebp
f0100947:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010094a:	8b 45 08             	mov    0x8(%ebp),%eax
f010094d:	e8 f5 fe ff ff       	call   f0100847 <cons_putc>
}
f0100952:	c9                   	leave  
f0100953:	c3                   	ret    

f0100954 <getchar>:

int
getchar(void)
{
f0100954:	f3 0f 1e fb          	endbr32 
f0100958:	55                   	push   %ebp
f0100959:	89 e5                	mov    %esp,%ebp
f010095b:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010095e:	e8 61 ff ff ff       	call   f01008c4 <cons_getc>
f0100963:	85 c0                	test   %eax,%eax
f0100965:	74 f7                	je     f010095e <getchar+0xa>
		/* do nothing */;
	return c;
}
f0100967:	c9                   	leave  
f0100968:	c3                   	ret    

f0100969 <iscons>:

int
iscons(int fdnum)
{
f0100969:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f010096d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100972:	c3                   	ret    

f0100973 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100973:	f3 0f 1e fb          	endbr32 
f0100977:	55                   	push   %ebp
f0100978:	89 e5                	mov    %esp,%ebp
f010097a:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010097d:	68 c0 68 10 f0       	push   $0xf01068c0
f0100982:	68 de 68 10 f0       	push   $0xf01068de
f0100987:	68 e3 68 10 f0       	push   $0xf01068e3
f010098c:	e8 7f 2f 00 00       	call   f0103910 <cprintf>
f0100991:	83 c4 0c             	add    $0xc,%esp
f0100994:	68 4c 69 10 f0       	push   $0xf010694c
f0100999:	68 ec 68 10 f0       	push   $0xf01068ec
f010099e:	68 e3 68 10 f0       	push   $0xf01068e3
f01009a3:	e8 68 2f 00 00       	call   f0103910 <cprintf>
	return 0;
}
f01009a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01009ad:	c9                   	leave  
f01009ae:	c3                   	ret    

f01009af <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01009af:	f3 0f 1e fb          	endbr32 
f01009b3:	55                   	push   %ebp
f01009b4:	89 e5                	mov    %esp,%ebp
f01009b6:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01009b9:	68 f5 68 10 f0       	push   $0xf01068f5
f01009be:	e8 4d 2f 00 00       	call   f0103910 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01009c3:	83 c4 08             	add    $0x8,%esp
f01009c6:	68 0c 00 10 00       	push   $0x10000c
f01009cb:	68 74 69 10 f0       	push   $0xf0106974
f01009d0:	e8 3b 2f 00 00       	call   f0103910 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01009d5:	83 c4 0c             	add    $0xc,%esp
f01009d8:	68 0c 00 10 00       	push   $0x10000c
f01009dd:	68 0c 00 10 f0       	push   $0xf010000c
f01009e2:	68 9c 69 10 f0       	push   $0xf010699c
f01009e7:	e8 24 2f 00 00       	call   f0103910 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01009ec:	83 c4 0c             	add    $0xc,%esp
f01009ef:	68 9d 65 10 00       	push   $0x10659d
f01009f4:	68 9d 65 10 f0       	push   $0xf010659d
f01009f9:	68 c0 69 10 f0       	push   $0xf01069c0
f01009fe:	e8 0d 2f 00 00       	call   f0103910 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100a03:	83 c4 0c             	add    $0xc,%esp
f0100a06:	68 0c 06 22 00       	push   $0x22060c
f0100a0b:	68 0c 06 22 f0       	push   $0xf022060c
f0100a10:	68 e4 69 10 f0       	push   $0xf01069e4
f0100a15:	e8 f6 2e 00 00       	call   f0103910 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100a1a:	83 c4 0c             	add    $0xc,%esp
f0100a1d:	68 08 40 26 00       	push   $0x264008
f0100a22:	68 08 40 26 f0       	push   $0xf0264008
f0100a27:	68 08 6a 10 f0       	push   $0xf0106a08
f0100a2c:	e8 df 2e 00 00       	call   f0103910 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100a31:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100a34:	b8 08 40 26 f0       	mov    $0xf0264008,%eax
f0100a39:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100a3e:	c1 f8 0a             	sar    $0xa,%eax
f0100a41:	50                   	push   %eax
f0100a42:	68 2c 6a 10 f0       	push   $0xf0106a2c
f0100a47:	e8 c4 2e 00 00       	call   f0103910 <cprintf>
	return 0;
}
f0100a4c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a51:	c9                   	leave  
f0100a52:	c3                   	ret    

f0100a53 <runcmd>:
#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
f0100a53:	55                   	push   %ebp
f0100a54:	89 e5                	mov    %esp,%ebp
f0100a56:	57                   	push   %edi
f0100a57:	56                   	push   %esi
f0100a58:	53                   	push   %ebx
f0100a59:	83 ec 5c             	sub    $0x5c,%esp
f0100a5c:	89 c3                	mov    %eax,%ebx
f0100a5e:	89 55 a4             	mov    %edx,-0x5c(%ebp)
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100a61:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a68:	be 00 00 00 00       	mov    $0x0,%esi
f0100a6d:	eb 5d                	jmp    f0100acc <runcmd+0x79>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a6f:	83 ec 08             	sub    $0x8,%esp
f0100a72:	0f be c0             	movsbl %al,%eax
f0100a75:	50                   	push   %eax
f0100a76:	68 0e 69 10 f0       	push   $0xf010690e
f0100a7b:	e8 9a 4d 00 00       	call   f010581a <strchr>
f0100a80:	83 c4 10             	add    $0x10,%esp
f0100a83:	85 c0                	test   %eax,%eax
f0100a85:	74 0a                	je     f0100a91 <runcmd+0x3e>
			*buf++ = 0;
f0100a87:	c6 03 00             	movb   $0x0,(%ebx)
f0100a8a:	89 f7                	mov    %esi,%edi
f0100a8c:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a8f:	eb 39                	jmp    f0100aca <runcmd+0x77>
		if (*buf == 0)
f0100a91:	0f b6 03             	movzbl (%ebx),%eax
f0100a94:	84 c0                	test   %al,%al
f0100a96:	74 3b                	je     f0100ad3 <runcmd+0x80>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a98:	83 fe 0f             	cmp    $0xf,%esi
f0100a9b:	0f 84 86 00 00 00    	je     f0100b27 <runcmd+0xd4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
f0100aa1:	8d 7e 01             	lea    0x1(%esi),%edi
f0100aa4:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100aa8:	83 ec 08             	sub    $0x8,%esp
f0100aab:	0f be c0             	movsbl %al,%eax
f0100aae:	50                   	push   %eax
f0100aaf:	68 0e 69 10 f0       	push   $0xf010690e
f0100ab4:	e8 61 4d 00 00       	call   f010581a <strchr>
f0100ab9:	83 c4 10             	add    $0x10,%esp
f0100abc:	85 c0                	test   %eax,%eax
f0100abe:	75 0a                	jne    f0100aca <runcmd+0x77>
			buf++;
f0100ac0:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100ac3:	0f b6 03             	movzbl (%ebx),%eax
f0100ac6:	84 c0                	test   %al,%al
f0100ac8:	75 de                	jne    f0100aa8 <runcmd+0x55>
			*buf++ = 0;
f0100aca:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100acc:	0f b6 03             	movzbl (%ebx),%eax
f0100acf:	84 c0                	test   %al,%al
f0100ad1:	75 9c                	jne    f0100a6f <runcmd+0x1c>
	}
	argv[argc] = 0;
f0100ad3:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100ada:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100adb:	85 f6                	test   %esi,%esi
f0100add:	74 5f                	je     f0100b3e <runcmd+0xeb>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100adf:	83 ec 08             	sub    $0x8,%esp
f0100ae2:	68 de 68 10 f0       	push   $0xf01068de
f0100ae7:	ff 75 a8             	pushl  -0x58(%ebp)
f0100aea:	e8 c5 4c 00 00       	call   f01057b4 <strcmp>
f0100aef:	83 c4 10             	add    $0x10,%esp
f0100af2:	85 c0                	test   %eax,%eax
f0100af4:	74 57                	je     f0100b4d <runcmd+0xfa>
f0100af6:	83 ec 08             	sub    $0x8,%esp
f0100af9:	68 ec 68 10 f0       	push   $0xf01068ec
f0100afe:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b01:	e8 ae 4c 00 00       	call   f01057b4 <strcmp>
f0100b06:	83 c4 10             	add    $0x10,%esp
f0100b09:	85 c0                	test   %eax,%eax
f0100b0b:	74 3b                	je     f0100b48 <runcmd+0xf5>
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100b0d:	83 ec 08             	sub    $0x8,%esp
f0100b10:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b13:	68 30 69 10 f0       	push   $0xf0106930
f0100b18:	e8 f3 2d 00 00       	call   f0103910 <cprintf>
	return 0;
f0100b1d:	83 c4 10             	add    $0x10,%esp
f0100b20:	be 00 00 00 00       	mov    $0x0,%esi
f0100b25:	eb 17                	jmp    f0100b3e <runcmd+0xeb>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100b27:	83 ec 08             	sub    $0x8,%esp
f0100b2a:	6a 10                	push   $0x10
f0100b2c:	68 13 69 10 f0       	push   $0xf0106913
f0100b31:	e8 da 2d 00 00       	call   f0103910 <cprintf>
			return 0;
f0100b36:	83 c4 10             	add    $0x10,%esp
f0100b39:	be 00 00 00 00       	mov    $0x0,%esi
}
f0100b3e:	89 f0                	mov    %esi,%eax
f0100b40:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b43:	5b                   	pop    %ebx
f0100b44:	5e                   	pop    %esi
f0100b45:	5f                   	pop    %edi
f0100b46:	5d                   	pop    %ebp
f0100b47:	c3                   	ret    
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100b48:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100b4d:	83 ec 04             	sub    $0x4,%esp
f0100b50:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100b53:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100b56:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100b59:	52                   	push   %edx
f0100b5a:	56                   	push   %esi
f0100b5b:	ff 14 85 ac 6a 10 f0 	call   *-0xfef9554(,%eax,4)
f0100b62:	89 c6                	mov    %eax,%esi
f0100b64:	83 c4 10             	add    $0x10,%esp
f0100b67:	eb d5                	jmp    f0100b3e <runcmd+0xeb>

f0100b69 <mon_backtrace>:
{
f0100b69:	f3 0f 1e fb          	endbr32 
}
f0100b6d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b72:	c3                   	ret    

f0100b73 <monitor>:

void
monitor(struct Trapframe *tf)
{
f0100b73:	f3 0f 1e fb          	endbr32 
f0100b77:	55                   	push   %ebp
f0100b78:	89 e5                	mov    %esp,%ebp
f0100b7a:	53                   	push   %ebx
f0100b7b:	83 ec 10             	sub    $0x10,%esp
f0100b7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100b81:	68 58 6a 10 f0       	push   $0xf0106a58
f0100b86:	e8 85 2d 00 00       	call   f0103910 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100b8b:	c7 04 24 7c 6a 10 f0 	movl   $0xf0106a7c,(%esp)
f0100b92:	e8 79 2d 00 00       	call   f0103910 <cprintf>

	if (tf != NULL)
f0100b97:	83 c4 10             	add    $0x10,%esp
f0100b9a:	85 db                	test   %ebx,%ebx
f0100b9c:	74 0c                	je     f0100baa <monitor+0x37>
		print_trapframe(tf);
f0100b9e:	83 ec 0c             	sub    $0xc,%esp
f0100ba1:	53                   	push   %ebx
f0100ba2:	e8 04 33 00 00       	call   f0103eab <print_trapframe>
f0100ba7:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100baa:	83 ec 0c             	sub    $0xc,%esp
f0100bad:	68 46 69 10 f0       	push   $0xf0106946
f0100bb2:	e8 09 4a 00 00       	call   f01055c0 <readline>
		if (buf != NULL)
f0100bb7:	83 c4 10             	add    $0x10,%esp
f0100bba:	85 c0                	test   %eax,%eax
f0100bbc:	74 ec                	je     f0100baa <monitor+0x37>
			if (runcmd(buf, tf) < 0)
f0100bbe:	89 da                	mov    %ebx,%edx
f0100bc0:	e8 8e fe ff ff       	call   f0100a53 <runcmd>
f0100bc5:	85 c0                	test   %eax,%eax
f0100bc7:	79 e1                	jns    f0100baa <monitor+0x37>
				break;
	}
}
f0100bc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100bcc:	c9                   	leave  
f0100bcd:	c3                   	ret    

f0100bce <invlpg>:
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100bce:	0f 01 38             	invlpg (%eax)
}
f0100bd1:	c3                   	ret    

f0100bd2 <lcr0>:
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0100bd2:	0f 22 c0             	mov    %eax,%cr0
}
f0100bd5:	c3                   	ret    

f0100bd6 <rcr0>:
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0100bd6:	0f 20 c0             	mov    %cr0,%eax
}
f0100bd9:	c3                   	ret    

f0100bda <lcr3>:
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0100bda:	0f 22 d8             	mov    %eax,%cr3
}
f0100bdd:	c3                   	ret    

f0100bde <page2pa>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bde:	2b 05 90 2e 22 f0    	sub    0xf0222e90,%eax
f0100be4:	c1 f8 03             	sar    $0x3,%eax
f0100be7:	c1 e0 0c             	shl    $0xc,%eax
}
f0100bea:	c3                   	ret    

f0100beb <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100beb:	55                   	push   %ebp
f0100bec:	89 e5                	mov    %esp,%ebp
f0100bee:	56                   	push   %esi
f0100bef:	53                   	push   %ebx
f0100bf0:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100bf2:	83 ec 0c             	sub    $0xc,%esp
f0100bf5:	50                   	push   %eax
f0100bf6:	e8 e3 2a 00 00       	call   f01036de <mc146818_read>
f0100bfb:	89 c6                	mov    %eax,%esi
f0100bfd:	83 c3 01             	add    $0x1,%ebx
f0100c00:	89 1c 24             	mov    %ebx,(%esp)
f0100c03:	e8 d6 2a 00 00       	call   f01036de <mc146818_read>
f0100c08:	c1 e0 08             	shl    $0x8,%eax
f0100c0b:	09 f0                	or     %esi,%eax
}
f0100c0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100c10:	5b                   	pop    %ebx
f0100c11:	5e                   	pop    %esi
f0100c12:	5d                   	pop    %ebp
f0100c13:	c3                   	ret    

f0100c14 <i386_detect_memory>:

static void
i386_detect_memory(void)
{
f0100c14:	55                   	push   %ebp
f0100c15:	89 e5                	mov    %esp,%ebp
f0100c17:	56                   	push   %esi
f0100c18:	53                   	push   %ebx
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0100c19:	b8 15 00 00 00       	mov    $0x15,%eax
f0100c1e:	e8 c8 ff ff ff       	call   f0100beb <nvram_read>
f0100c23:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100c25:	b8 17 00 00 00       	mov    $0x17,%eax
f0100c2a:	e8 bc ff ff ff       	call   f0100beb <nvram_read>
f0100c2f:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100c31:	b8 34 00 00 00       	mov    $0x34,%eax
f0100c36:	e8 b0 ff ff ff       	call   f0100beb <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0100c3b:	c1 e0 06             	shl    $0x6,%eax
f0100c3e:	74 2b                	je     f0100c6b <i386_detect_memory+0x57>
		totalmem = 16 * 1024 + ext16mem;
f0100c40:	05 00 40 00 00       	add    $0x4000,%eax
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0100c45:	89 c2                	mov    %eax,%edx
f0100c47:	c1 ea 02             	shr    $0x2,%edx
f0100c4a:	89 15 88 2e 22 f0    	mov    %edx,0xf0222e88
	npages_basemem = basemem / (PGSIZE / 1024);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100c50:	89 c2                	mov    %eax,%edx
f0100c52:	29 da                	sub    %ebx,%edx
f0100c54:	52                   	push   %edx
f0100c55:	53                   	push   %ebx
f0100c56:	50                   	push   %eax
f0100c57:	68 bc 6a 10 f0       	push   $0xf0106abc
f0100c5c:	e8 af 2c 00 00       	call   f0103910 <cprintf>
	        totalmem,
	        basemem,
	        totalmem - basemem);
}
f0100c61:	83 c4 10             	add    $0x10,%esp
f0100c64:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100c67:	5b                   	pop    %ebx
f0100c68:	5e                   	pop    %esi
f0100c69:	5d                   	pop    %ebp
f0100c6a:	c3                   	ret    
		totalmem = 1 * 1024 + extmem;
f0100c6b:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0100c71:	85 f6                	test   %esi,%esi
f0100c73:	0f 44 c3             	cmove  %ebx,%eax
f0100c76:	eb cd                	jmp    f0100c45 <i386_detect_memory+0x31>

f0100c78 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100c78:	55                   	push   %ebp
f0100c79:	89 e5                	mov    %esp,%ebp
f0100c7b:	83 ec 08             	sub    $0x8,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100c7e:	8b 15 38 12 22 f0    	mov    0xf0221238,%edx
f0100c84:	85 d2                	test   %edx,%edx
f0100c86:	74 29                	je     f0100cb1 <boot_alloc+0x39>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//

	if (n == 0) {
f0100c88:	85 c0                	test   %eax,%eax
f0100c8a:	74 21                	je     f0100cad <boot_alloc+0x35>
		return nextfree;
	}

	if (npages < n % PGSIZE) {
f0100c8c:	89 c1                	mov    %eax,%ecx
f0100c8e:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
f0100c94:	3b 0d 88 2e 22 f0    	cmp    0xf0222e88,%ecx
f0100c9a:	77 3e                	ja     f0100cda <boot_alloc+0x62>
		panic("ERROR BOOT ALLOC");
	}

	result = nextfree;
	nextfree = ROUNDUP(n + result, PGSIZE);
f0100c9c:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100ca3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ca8:	a3 38 12 22 f0       	mov    %eax,0xf0221238

	return result;
}
f0100cad:	89 d0                	mov    %edx,%eax
f0100caf:	c9                   	leave  
f0100cb0:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100cb1:	b9 07 50 26 f0       	mov    $0xf0265007,%ecx
f0100cb6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100cbc:	89 ca                	mov    %ecx,%edx
f0100cbe:	89 0d 38 12 22 f0    	mov    %ecx,0xf0221238
	if (!nextfree) {
f0100cc4:	75 c2                	jne    f0100c88 <boot_alloc+0x10>
		panic("THERE IS NOT ENOUGH MEMORY");
f0100cc6:	83 ec 04             	sub    $0x4,%esp
f0100cc9:	68 a9 74 10 f0       	push   $0xf01074a9
f0100cce:	6a 6b                	push   $0x6b
f0100cd0:	68 c4 74 10 f0       	push   $0xf01074c4
f0100cd5:	e8 90 f3 ff ff       	call   f010006a <_panic>
		panic("ERROR BOOT ALLOC");
f0100cda:	83 ec 04             	sub    $0x4,%esp
f0100cdd:	68 d0 74 10 f0       	push   $0xf01074d0
f0100ce2:	6a 78                	push   $0x78
f0100ce4:	68 c4 74 10 f0       	push   $0xf01074c4
f0100ce9:	e8 7c f3 ff ff       	call   f010006a <_panic>

f0100cee <_kaddr>:
{
f0100cee:	55                   	push   %ebp
f0100cef:	89 e5                	mov    %esp,%ebp
f0100cf1:	53                   	push   %ebx
f0100cf2:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f0100cf5:	89 cb                	mov    %ecx,%ebx
f0100cf7:	c1 eb 0c             	shr    $0xc,%ebx
f0100cfa:	3b 1d 88 2e 22 f0    	cmp    0xf0222e88,%ebx
f0100d00:	73 0b                	jae    f0100d0d <_kaddr+0x1f>
	return (void *)(pa + KERNBASE);
f0100d02:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f0100d08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100d0b:	c9                   	leave  
f0100d0c:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d0d:	51                   	push   %ecx
f0100d0e:	68 cc 65 10 f0       	push   $0xf01065cc
f0100d13:	52                   	push   %edx
f0100d14:	50                   	push   %eax
f0100d15:	e8 50 f3 ff ff       	call   f010006a <_panic>

f0100d1a <page2kva>:
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100d1a:	55                   	push   %ebp
f0100d1b:	89 e5                	mov    %esp,%ebp
f0100d1d:	83 ec 08             	sub    $0x8,%esp
	return KADDR(page2pa(pp));
f0100d20:	e8 b9 fe ff ff       	call   f0100bde <page2pa>
f0100d25:	89 c1                	mov    %eax,%ecx
f0100d27:	ba 58 00 00 00       	mov    $0x58,%edx
f0100d2c:	b8 e1 74 10 f0       	mov    $0xf01074e1,%eax
f0100d31:	e8 b8 ff ff ff       	call   f0100cee <_kaddr>
}
f0100d36:	c9                   	leave  
f0100d37:	c3                   	ret    

f0100d38 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100d38:	55                   	push   %ebp
f0100d39:	89 e5                	mov    %esp,%ebp
f0100d3b:	53                   	push   %ebx
f0100d3c:	83 ec 04             	sub    $0x4,%esp
f0100d3f:	89 d3                	mov    %edx,%ebx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100d41:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P))
f0100d44:	8b 0c 90             	mov    (%eax,%edx,4),%ecx
		return ~0;
f0100d47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	if (!(*pgdir & PTE_P))
f0100d4c:	f6 c1 01             	test   $0x1,%cl
f0100d4f:	74 14                	je     f0100d65 <check_va2pa+0x2d>
	if (*pgdir & PTE_PS)
f0100d51:	f6 c1 80             	test   $0x80,%cl
f0100d54:	74 15                	je     f0100d6b <check_va2pa+0x33>
		return (physaddr_t) PGADDR(PDX(*pgdir), PTX(va), PGOFF(va));
f0100d56:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
f0100d5c:	89 d8                	mov    %ebx,%eax
f0100d5e:	25 ff ff 3f 00       	and    $0x3fffff,%eax
f0100d63:	09 c8                	or     %ecx,%eax
	p = (pte_t *) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100d65:	83 c4 04             	add    $0x4,%esp
f0100d68:	5b                   	pop    %ebx
f0100d69:	5d                   	pop    %ebp
f0100d6a:	c3                   	ret    
	p = (pte_t *) KADDR(PTE_ADDR(*pgdir));
f0100d6b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100d71:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100d76:	b8 c4 74 10 f0       	mov    $0xf01074c4,%eax
f0100d7b:	e8 6e ff ff ff       	call   f0100cee <_kaddr>
	if (!(p[PTX(va)] & PTE_P))
f0100d80:	c1 eb 0c             	shr    $0xc,%ebx
f0100d83:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0100d89:	8b 14 98             	mov    (%eax,%ebx,4),%edx
	return PTE_ADDR(p[PTX(va)]);
f0100d8c:	89 d0                	mov    %edx,%eax
f0100d8e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d93:	f6 c2 01             	test   $0x1,%dl
f0100d96:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f0100d9b:	0f 44 c1             	cmove  %ecx,%eax
f0100d9e:	eb c5                	jmp    f0100d65 <check_va2pa+0x2d>

f0100da0 <_paddr>:
	if ((uint32_t)kva < KERNBASE)
f0100da0:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0100da6:	76 07                	jbe    f0100daf <_paddr+0xf>
	return (physaddr_t)kva - KERNBASE;
f0100da8:	8d 81 00 00 00 10    	lea    0x10000000(%ecx),%eax
}
f0100dae:	c3                   	ret    
{
f0100daf:	55                   	push   %ebp
f0100db0:	89 e5                	mov    %esp,%ebp
f0100db2:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100db5:	51                   	push   %ecx
f0100db6:	68 f0 65 10 f0       	push   $0xf01065f0
f0100dbb:	52                   	push   %edx
f0100dbc:	50                   	push   %eax
f0100dbd:	e8 a8 f2 ff ff       	call   f010006a <_panic>

f0100dc2 <check_page_free_list>:
{
f0100dc2:	55                   	push   %ebp
f0100dc3:	89 e5                	mov    %esp,%ebp
f0100dc5:	57                   	push   %edi
f0100dc6:	56                   	push   %esi
f0100dc7:	53                   	push   %ebx
f0100dc8:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100dcb:	84 c0                	test   %al,%al
f0100dcd:	0f 85 3f 02 00 00    	jne    f0101012 <check_page_free_list+0x250>
	if (!page_free_list)
f0100dd3:	83 3d 40 12 22 f0 00 	cmpl   $0x0,0xf0221240
f0100dda:	74 0a                	je     f0100de6 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ddc:	be 00 04 00 00       	mov    $0x400,%esi
f0100de1:	e9 84 02 00 00       	jmp    f010106a <check_page_free_list+0x2a8>
		panic("'page_free_list' is a null pointer!");
f0100de6:	83 ec 04             	sub    $0x4,%esp
f0100de9:	68 f8 6a 10 f0       	push   $0xf0106af8
f0100dee:	68 17 03 00 00       	push   $0x317
f0100df3:	68 c4 74 10 f0       	push   $0xf01074c4
f0100df8:	e8 6d f2 ff ff       	call   f010006a <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100dfd:	8b 1b                	mov    (%ebx),%ebx
f0100dff:	85 db                	test   %ebx,%ebx
f0100e01:	74 2d                	je     f0100e30 <check_page_free_list+0x6e>
		if (PDX(page2pa(pp)) < pdx_limit)
f0100e03:	89 d8                	mov    %ebx,%eax
f0100e05:	e8 d4 fd ff ff       	call   f0100bde <page2pa>
f0100e0a:	c1 e8 16             	shr    $0x16,%eax
f0100e0d:	39 f0                	cmp    %esi,%eax
f0100e0f:	73 ec                	jae    f0100dfd <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100e11:	89 d8                	mov    %ebx,%eax
f0100e13:	e8 02 ff ff ff       	call   f0100d1a <page2kva>
f0100e18:	83 ec 04             	sub    $0x4,%esp
f0100e1b:	68 80 00 00 00       	push   $0x80
f0100e20:	68 97 00 00 00       	push   $0x97
f0100e25:	50                   	push   %eax
f0100e26:	e8 34 4a 00 00       	call   f010585f <memset>
f0100e2b:	83 c4 10             	add    $0x10,%esp
f0100e2e:	eb cd                	jmp    f0100dfd <check_page_free_list+0x3b>
	first_free_page = (char *) boot_alloc(0);
f0100e30:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e35:	e8 3e fe ff ff       	call   f0100c78 <boot_alloc>
f0100e3a:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e3d:	8b 1d 40 12 22 f0    	mov    0xf0221240,%ebx
		assert(pp >= pages);
f0100e43:	8b 35 90 2e 22 f0    	mov    0xf0222e90,%esi
		assert(pp < pages + npages);
f0100e49:	a1 88 2e 22 f0       	mov    0xf0222e88,%eax
f0100e4e:	8d 3c c6             	lea    (%esi,%eax,8),%edi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100e51:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0100e58:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e5f:	e9 e0 00 00 00       	jmp    f0100f44 <check_page_free_list+0x182>
		assert(pp >= pages);
f0100e64:	68 ef 74 10 f0       	push   $0xf01074ef
f0100e69:	68 fb 74 10 f0       	push   $0xf01074fb
f0100e6e:	68 31 03 00 00       	push   $0x331
f0100e73:	68 c4 74 10 f0       	push   $0xf01074c4
f0100e78:	e8 ed f1 ff ff       	call   f010006a <_panic>
		assert(pp < pages + npages);
f0100e7d:	68 10 75 10 f0       	push   $0xf0107510
f0100e82:	68 fb 74 10 f0       	push   $0xf01074fb
f0100e87:	68 32 03 00 00       	push   $0x332
f0100e8c:	68 c4 74 10 f0       	push   $0xf01074c4
f0100e91:	e8 d4 f1 ff ff       	call   f010006a <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e96:	68 1c 6b 10 f0       	push   $0xf0106b1c
f0100e9b:	68 fb 74 10 f0       	push   $0xf01074fb
f0100ea0:	68 33 03 00 00       	push   $0x333
f0100ea5:	68 c4 74 10 f0       	push   $0xf01074c4
f0100eaa:	e8 bb f1 ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) != 0);
f0100eaf:	68 24 75 10 f0       	push   $0xf0107524
f0100eb4:	68 fb 74 10 f0       	push   $0xf01074fb
f0100eb9:	68 36 03 00 00       	push   $0x336
f0100ebe:	68 c4 74 10 f0       	push   $0xf01074c4
f0100ec3:	e8 a2 f1 ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ec8:	68 35 75 10 f0       	push   $0xf0107535
f0100ecd:	68 fb 74 10 f0       	push   $0xf01074fb
f0100ed2:	68 37 03 00 00       	push   $0x337
f0100ed7:	68 c4 74 10 f0       	push   $0xf01074c4
f0100edc:	e8 89 f1 ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ee1:	68 50 6b 10 f0       	push   $0xf0106b50
f0100ee6:	68 fb 74 10 f0       	push   $0xf01074fb
f0100eeb:	68 38 03 00 00       	push   $0x338
f0100ef0:	68 c4 74 10 f0       	push   $0xf01074c4
f0100ef5:	e8 70 f1 ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100efa:	68 4e 75 10 f0       	push   $0xf010754e
f0100eff:	68 fb 74 10 f0       	push   $0xf01074fb
f0100f04:	68 39 03 00 00       	push   $0x339
f0100f09:	68 c4 74 10 f0       	push   $0xf01074c4
f0100f0e:	e8 57 f1 ff ff       	call   f010006a <_panic>
		assert(page2pa(pp) < EXTPHYSMEM ||
f0100f13:	89 d8                	mov    %ebx,%eax
f0100f15:	e8 00 fe ff ff       	call   f0100d1a <page2kva>
f0100f1a:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100f1d:	77 06                	ja     f0100f25 <check_page_free_list+0x163>
			++nfree_extmem;
f0100f1f:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
f0100f23:	eb 1d                	jmp    f0100f42 <check_page_free_list+0x180>
		assert(page2pa(pp) < EXTPHYSMEM ||
f0100f25:	68 74 6b 10 f0       	push   $0xf0106b74
f0100f2a:	68 fb 74 10 f0       	push   $0xf01074fb
f0100f2f:	68 3a 03 00 00       	push   $0x33a
f0100f34:	68 c4 74 10 f0       	push   $0xf01074c4
f0100f39:	e8 2c f1 ff ff       	call   f010006a <_panic>
			++nfree_basemem;
f0100f3e:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f42:	8b 1b                	mov    (%ebx),%ebx
f0100f44:	85 db                	test   %ebx,%ebx
f0100f46:	74 77                	je     f0100fbf <check_page_free_list+0x1fd>
		assert(pp >= pages);
f0100f48:	39 de                	cmp    %ebx,%esi
f0100f4a:	0f 87 14 ff ff ff    	ja     f0100e64 <check_page_free_list+0xa2>
		assert(pp < pages + npages);
f0100f50:	39 df                	cmp    %ebx,%edi
f0100f52:	0f 86 25 ff ff ff    	jbe    f0100e7d <check_page_free_list+0xbb>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f58:	89 d8                	mov    %ebx,%eax
f0100f5a:	29 f0                	sub    %esi,%eax
f0100f5c:	a8 07                	test   $0x7,%al
f0100f5e:	0f 85 32 ff ff ff    	jne    f0100e96 <check_page_free_list+0xd4>
		assert(page2pa(pp) != 0);
f0100f64:	89 d8                	mov    %ebx,%eax
f0100f66:	e8 73 fc ff ff       	call   f0100bde <page2pa>
f0100f6b:	85 c0                	test   %eax,%eax
f0100f6d:	0f 84 3c ff ff ff    	je     f0100eaf <check_page_free_list+0xed>
		assert(page2pa(pp) != IOPHYSMEM);
f0100f73:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100f78:	0f 84 4a ff ff ff    	je     f0100ec8 <check_page_free_list+0x106>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100f7e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100f83:	0f 84 58 ff ff ff    	je     f0100ee1 <check_page_free_list+0x11f>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100f89:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100f8e:	0f 84 66 ff ff ff    	je     f0100efa <check_page_free_list+0x138>
		assert(page2pa(pp) < EXTPHYSMEM ||
f0100f94:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100f99:	0f 87 74 ff ff ff    	ja     f0100f13 <check_page_free_list+0x151>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100f9f:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100fa4:	75 98                	jne    f0100f3e <check_page_free_list+0x17c>
f0100fa6:	68 68 75 10 f0       	push   $0xf0107568
f0100fab:	68 fb 74 10 f0       	push   $0xf01074fb
f0100fb0:	68 3d 03 00 00       	push   $0x33d
f0100fb5:	68 c4 74 10 f0       	push   $0xf01074c4
f0100fba:	e8 ab f0 ff ff       	call   f010006a <_panic>
	assert(nfree_basemem > 0);
f0100fbf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100fc3:	7e 1b                	jle    f0100fe0 <check_page_free_list+0x21e>
	assert(nfree_extmem > 0);
f0100fc5:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100fc9:	7e 2e                	jle    f0100ff9 <check_page_free_list+0x237>
	cprintf("check_page_free_list() succeeded!\n");
f0100fcb:	83 ec 0c             	sub    $0xc,%esp
f0100fce:	68 bc 6b 10 f0       	push   $0xf0106bbc
f0100fd3:	e8 38 29 00 00       	call   f0103910 <cprintf>
}
f0100fd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fdb:	5b                   	pop    %ebx
f0100fdc:	5e                   	pop    %esi
f0100fdd:	5f                   	pop    %edi
f0100fde:	5d                   	pop    %ebp
f0100fdf:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100fe0:	68 85 75 10 f0       	push   $0xf0107585
f0100fe5:	68 fb 74 10 f0       	push   $0xf01074fb
f0100fea:	68 45 03 00 00       	push   $0x345
f0100fef:	68 c4 74 10 f0       	push   $0xf01074c4
f0100ff4:	e8 71 f0 ff ff       	call   f010006a <_panic>
	assert(nfree_extmem > 0);
f0100ff9:	68 97 75 10 f0       	push   $0xf0107597
f0100ffe:	68 fb 74 10 f0       	push   $0xf01074fb
f0101003:	68 46 03 00 00       	push   $0x346
f0101008:	68 c4 74 10 f0       	push   $0xf01074c4
f010100d:	e8 58 f0 ff ff       	call   f010006a <_panic>
	if (!page_free_list)
f0101012:	8b 1d 40 12 22 f0    	mov    0xf0221240,%ebx
f0101018:	85 db                	test   %ebx,%ebx
f010101a:	0f 84 c6 fd ff ff    	je     f0100de6 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101020:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0101023:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101026:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0101029:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f010102c:	89 d8                	mov    %ebx,%eax
f010102e:	e8 ab fb ff ff       	call   f0100bde <page2pa>
f0101033:	c1 e8 16             	shr    $0x16,%eax
f0101036:	0f 95 c0             	setne  %al
f0101039:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f010103c:	8b 54 85 e0          	mov    -0x20(%ebp,%eax,4),%edx
f0101040:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0101042:	89 5c 85 e0          	mov    %ebx,-0x20(%ebp,%eax,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101046:	8b 1b                	mov    (%ebx),%ebx
f0101048:	85 db                	test   %ebx,%ebx
f010104a:	75 e0                	jne    f010102c <check_page_free_list+0x26a>
		*tp[1] = 0;
f010104c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010104f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101055:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101058:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010105b:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f010105d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101060:	a3 40 12 22 f0       	mov    %eax,0xf0221240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101065:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010106a:	8b 1d 40 12 22 f0    	mov    0xf0221240,%ebx
f0101070:	e9 8a fd ff ff       	jmp    f0100dff <check_page_free_list+0x3d>

f0101075 <pa2page>:
	if (PGNUM(pa) >= npages)
f0101075:	c1 e8 0c             	shr    $0xc,%eax
f0101078:	3b 05 88 2e 22 f0    	cmp    0xf0222e88,%eax
f010107e:	73 0a                	jae    f010108a <pa2page+0x15>
	return &pages[PGNUM(pa)];
f0101080:	8b 15 90 2e 22 f0    	mov    0xf0222e90,%edx
f0101086:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101089:	c3                   	ret    
{
f010108a:	55                   	push   %ebp
f010108b:	89 e5                	mov    %esp,%ebp
f010108d:	83 ec 0c             	sub    $0xc,%esp
		panic("pa2page called with invalid pa");
f0101090:	68 e0 6b 10 f0       	push   $0xf0106be0
f0101095:	6a 51                	push   $0x51
f0101097:	68 e1 74 10 f0       	push   $0xf01074e1
f010109c:	e8 c9 ef ff ff       	call   f010006a <_panic>

f01010a1 <page_init>:
{
f01010a1:	f3 0f 1e fb          	endbr32 
f01010a5:	55                   	push   %ebp
f01010a6:	89 e5                	mov    %esp,%ebp
f01010a8:	57                   	push   %edi
f01010a9:	56                   	push   %esi
f01010aa:	53                   	push   %ebx
f01010ab:	83 ec 0c             	sub    $0xc,%esp
	for (size_t i = 0; i < npages; i++) {
f01010ae:	be 00 00 00 00       	mov    $0x0,%esi
f01010b3:	eb 22                	jmp    f01010d7 <page_init+0x36>
		if (i == (MPENTRY_PADDR / PGSIZE)) {
f01010b5:	83 fe 07             	cmp    $0x7,%esi
f01010b8:	74 67                	je     f0101121 <page_init+0x80>
		pages[i].pp_link = page_free_list;
f01010ba:	a1 90 2e 22 f0       	mov    0xf0222e90,%eax
f01010bf:	8b 15 40 12 22 f0    	mov    0xf0221240,%edx
f01010c5:	89 14 38             	mov    %edx,(%eax,%edi,1)
		page_free_list = &pages[i];
f01010c8:	03 3d 90 2e 22 f0    	add    0xf0222e90,%edi
f01010ce:	89 3d 40 12 22 f0    	mov    %edi,0xf0221240
	for (size_t i = 0; i < npages; i++) {
f01010d4:	83 c6 01             	add    $0x1,%esi
f01010d7:	39 35 88 2e 22 f0    	cmp    %esi,0xf0222e88
f01010dd:	76 56                	jbe    f0101135 <page_init+0x94>
f01010df:	8d 3c f5 00 00 00 00 	lea    0x0(,%esi,8),%edi
		physaddr_t current = page2pa(&pages[i]);
f01010e6:	89 f8                	mov    %edi,%eax
f01010e8:	03 05 90 2e 22 f0    	add    0xf0222e90,%eax
f01010ee:	e8 eb fa ff ff       	call   f0100bde <page2pa>
f01010f3:	89 c3                	mov    %eax,%ebx
		if ((current == 0) ||
f01010f5:	85 c0                	test   %eax,%eax
f01010f7:	74 db                	je     f01010d4 <page_init+0x33>
f01010f9:	3d ff ff 09 00       	cmp    $0x9ffff,%eax
f01010fe:	76 b5                	jbe    f01010b5 <page_init+0x14>
		    (current >= IOPHYSMEM && current < PADDR(boot_alloc(0)))) {
f0101100:	b8 00 00 00 00       	mov    $0x0,%eax
f0101105:	e8 6e fb ff ff       	call   f0100c78 <boot_alloc>
f010110a:	89 c1                	mov    %eax,%ecx
f010110c:	ba 68 01 00 00       	mov    $0x168,%edx
f0101111:	b8 c4 74 10 f0       	mov    $0xf01074c4,%eax
f0101116:	e8 85 fc ff ff       	call   f0100da0 <_paddr>
f010111b:	39 d8                	cmp    %ebx,%eax
f010111d:	76 96                	jbe    f01010b5 <page_init+0x14>
f010111f:	eb b3                	jmp    f01010d4 <page_init+0x33>
			pages[i].pp_ref = 1;
f0101121:	a1 90 2e 22 f0       	mov    0xf0222e90,%eax
f0101126:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
			pages[i].pp_link = NULL;
f010112c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
			continue;
f0101133:	eb 9f                	jmp    f01010d4 <page_init+0x33>
}
f0101135:	83 c4 0c             	add    $0xc,%esp
f0101138:	5b                   	pop    %ebx
f0101139:	5e                   	pop    %esi
f010113a:	5f                   	pop    %edi
f010113b:	5d                   	pop    %ebp
f010113c:	c3                   	ret    

f010113d <page_alloc>:
{
f010113d:	f3 0f 1e fb          	endbr32 
f0101141:	55                   	push   %ebp
f0101142:	89 e5                	mov    %esp,%ebp
f0101144:	53                   	push   %ebx
f0101145:	83 ec 04             	sub    $0x4,%esp
	if (page_free_list == NULL) {
f0101148:	8b 1d 40 12 22 f0    	mov    0xf0221240,%ebx
f010114e:	85 db                	test   %ebx,%ebx
f0101150:	74 13                	je     f0101165 <page_alloc+0x28>
	page_free_list = page_free_list->pp_link;
f0101152:	8b 03                	mov    (%ebx),%eax
f0101154:	a3 40 12 22 f0       	mov    %eax,0xf0221240
	result->pp_link = NULL;
f0101159:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags && ALLOC_ZERO) {
f010115f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101163:	75 07                	jne    f010116c <page_alloc+0x2f>
}
f0101165:	89 d8                	mov    %ebx,%eax
f0101167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010116a:	c9                   	leave  
f010116b:	c3                   	ret    
		memset(page2kva(result), 0, PGSIZE);
f010116c:	89 d8                	mov    %ebx,%eax
f010116e:	e8 a7 fb ff ff       	call   f0100d1a <page2kva>
f0101173:	83 ec 04             	sub    $0x4,%esp
f0101176:	68 00 10 00 00       	push   $0x1000
f010117b:	6a 00                	push   $0x0
f010117d:	50                   	push   %eax
f010117e:	e8 dc 46 00 00       	call   f010585f <memset>
f0101183:	83 c4 10             	add    $0x10,%esp
f0101186:	eb dd                	jmp    f0101165 <page_alloc+0x28>

f0101188 <page_free>:
{
f0101188:	f3 0f 1e fb          	endbr32 
f010118c:	55                   	push   %ebp
f010118d:	89 e5                	mov    %esp,%ebp
f010118f:	83 ec 08             	sub    $0x8,%esp
f0101192:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0 || pp->pp_link != NULL) {
f0101195:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010119a:	75 14                	jne    f01011b0 <page_free+0x28>
f010119c:	83 38 00             	cmpl   $0x0,(%eax)
f010119f:	75 0f                	jne    f01011b0 <page_free+0x28>
	pp->pp_link =
f01011a1:	8b 15 40 12 22 f0    	mov    0xf0221240,%edx
f01011a7:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;     // Update initial page
f01011a9:	a3 40 12 22 f0       	mov    %eax,0xf0221240
}
f01011ae:	c9                   	leave  
f01011af:	c3                   	ret    
		panic("ERROR AT FREE, PP_REF MUST BE 0 AND PP_LINK "
f01011b0:	83 ec 04             	sub    $0x4,%esp
f01011b3:	68 00 6c 10 f0       	push   $0xf0106c00
f01011b8:	68 a3 01 00 00       	push   $0x1a3
f01011bd:	68 c4 74 10 f0       	push   $0xf01074c4
f01011c2:	e8 a3 ee ff ff       	call   f010006a <_panic>

f01011c7 <check_page_alloc>:
{
f01011c7:	55                   	push   %ebp
f01011c8:	89 e5                	mov    %esp,%ebp
f01011ca:	57                   	push   %edi
f01011cb:	56                   	push   %esi
f01011cc:	53                   	push   %ebx
f01011cd:	83 ec 1c             	sub    $0x1c,%esp
	if (!pages)
f01011d0:	83 3d 90 2e 22 f0 00 	cmpl   $0x0,0xf0222e90
f01011d7:	74 0c                	je     f01011e5 <check_page_alloc+0x1e>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01011d9:	a1 40 12 22 f0       	mov    0xf0221240,%eax
f01011de:	be 00 00 00 00       	mov    $0x0,%esi
f01011e3:	eb 1c                	jmp    f0101201 <check_page_alloc+0x3a>
		panic("'pages' is a null pointer!");
f01011e5:	83 ec 04             	sub    $0x4,%esp
f01011e8:	68 a8 75 10 f0       	push   $0xf01075a8
f01011ed:	68 59 03 00 00       	push   $0x359
f01011f2:	68 c4 74 10 f0       	push   $0xf01074c4
f01011f7:	e8 6e ee ff ff       	call   f010006a <_panic>
		++nfree;
f01011fc:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01011ff:	8b 00                	mov    (%eax),%eax
f0101201:	85 c0                	test   %eax,%eax
f0101203:	75 f7                	jne    f01011fc <check_page_alloc+0x35>
	assert((pp0 = page_alloc(0)));
f0101205:	83 ec 0c             	sub    $0xc,%esp
f0101208:	6a 00                	push   $0x0
f010120a:	e8 2e ff ff ff       	call   f010113d <page_alloc>
f010120f:	89 c7                	mov    %eax,%edi
f0101211:	83 c4 10             	add    $0x10,%esp
f0101214:	85 c0                	test   %eax,%eax
f0101216:	0f 84 d3 01 00 00    	je     f01013ef <check_page_alloc+0x228>
	assert((pp1 = page_alloc(0)));
f010121c:	83 ec 0c             	sub    $0xc,%esp
f010121f:	6a 00                	push   $0x0
f0101221:	e8 17 ff ff ff       	call   f010113d <page_alloc>
f0101226:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101229:	83 c4 10             	add    $0x10,%esp
f010122c:	85 c0                	test   %eax,%eax
f010122e:	0f 84 d4 01 00 00    	je     f0101408 <check_page_alloc+0x241>
	assert((pp2 = page_alloc(0)));
f0101234:	83 ec 0c             	sub    $0xc,%esp
f0101237:	6a 00                	push   $0x0
f0101239:	e8 ff fe ff ff       	call   f010113d <page_alloc>
f010123e:	89 c3                	mov    %eax,%ebx
f0101240:	83 c4 10             	add    $0x10,%esp
f0101243:	85 c0                	test   %eax,%eax
f0101245:	0f 84 d6 01 00 00    	je     f0101421 <check_page_alloc+0x25a>
	assert(pp1 && pp1 != pp0);
f010124b:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f010124e:	0f 84 e6 01 00 00    	je     f010143a <check_page_alloc+0x273>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101254:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0101257:	0f 84 f6 01 00 00    	je     f0101453 <check_page_alloc+0x28c>
f010125d:	39 c7                	cmp    %eax,%edi
f010125f:	0f 84 ee 01 00 00    	je     f0101453 <check_page_alloc+0x28c>
	assert(page2pa(pp0) < npages * PGSIZE);
f0101265:	89 f8                	mov    %edi,%eax
f0101267:	e8 72 f9 ff ff       	call   f0100bde <page2pa>
f010126c:	8b 0d 88 2e 22 f0    	mov    0xf0222e88,%ecx
f0101272:	c1 e1 0c             	shl    $0xc,%ecx
f0101275:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0101278:	39 c8                	cmp    %ecx,%eax
f010127a:	0f 83 ec 01 00 00    	jae    f010146c <check_page_alloc+0x2a5>
	assert(page2pa(pp1) < npages * PGSIZE);
f0101280:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101283:	e8 56 f9 ff ff       	call   f0100bde <page2pa>
f0101288:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f010128b:	0f 86 f4 01 00 00    	jbe    f0101485 <check_page_alloc+0x2be>
	assert(page2pa(pp2) < npages * PGSIZE);
f0101291:	89 d8                	mov    %ebx,%eax
f0101293:	e8 46 f9 ff ff       	call   f0100bde <page2pa>
f0101298:	39 45 e0             	cmp    %eax,-0x20(%ebp)
f010129b:	0f 86 fd 01 00 00    	jbe    f010149e <check_page_alloc+0x2d7>
	fl = page_free_list;
f01012a1:	a1 40 12 22 f0       	mov    0xf0221240,%eax
f01012a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	page_free_list = 0;
f01012a9:	c7 05 40 12 22 f0 00 	movl   $0x0,0xf0221240
f01012b0:	00 00 00 
	assert(!page_alloc(0));
f01012b3:	83 ec 0c             	sub    $0xc,%esp
f01012b6:	6a 00                	push   $0x0
f01012b8:	e8 80 fe ff ff       	call   f010113d <page_alloc>
f01012bd:	83 c4 10             	add    $0x10,%esp
f01012c0:	85 c0                	test   %eax,%eax
f01012c2:	0f 85 ef 01 00 00    	jne    f01014b7 <check_page_alloc+0x2f0>
	page_free(pp0);
f01012c8:	83 ec 0c             	sub    $0xc,%esp
f01012cb:	57                   	push   %edi
f01012cc:	e8 b7 fe ff ff       	call   f0101188 <page_free>
	page_free(pp1);
f01012d1:	83 c4 04             	add    $0x4,%esp
f01012d4:	ff 75 e4             	pushl  -0x1c(%ebp)
f01012d7:	e8 ac fe ff ff       	call   f0101188 <page_free>
	page_free(pp2);
f01012dc:	89 1c 24             	mov    %ebx,(%esp)
f01012df:	e8 a4 fe ff ff       	call   f0101188 <page_free>
	assert((pp0 = page_alloc(0)));
f01012e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012eb:	e8 4d fe ff ff       	call   f010113d <page_alloc>
f01012f0:	89 c3                	mov    %eax,%ebx
f01012f2:	83 c4 10             	add    $0x10,%esp
f01012f5:	85 c0                	test   %eax,%eax
f01012f7:	0f 84 d3 01 00 00    	je     f01014d0 <check_page_alloc+0x309>
	assert((pp1 = page_alloc(0)));
f01012fd:	83 ec 0c             	sub    $0xc,%esp
f0101300:	6a 00                	push   $0x0
f0101302:	e8 36 fe ff ff       	call   f010113d <page_alloc>
f0101307:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010130a:	83 c4 10             	add    $0x10,%esp
f010130d:	85 c0                	test   %eax,%eax
f010130f:	0f 84 d4 01 00 00    	je     f01014e9 <check_page_alloc+0x322>
	assert((pp2 = page_alloc(0)));
f0101315:	83 ec 0c             	sub    $0xc,%esp
f0101318:	6a 00                	push   $0x0
f010131a:	e8 1e fe ff ff       	call   f010113d <page_alloc>
f010131f:	89 c7                	mov    %eax,%edi
f0101321:	83 c4 10             	add    $0x10,%esp
f0101324:	85 c0                	test   %eax,%eax
f0101326:	0f 84 d6 01 00 00    	je     f0101502 <check_page_alloc+0x33b>
	assert(pp1 && pp1 != pp0);
f010132c:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010132f:	0f 84 e6 01 00 00    	je     f010151b <check_page_alloc+0x354>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101335:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0101338:	0f 84 f6 01 00 00    	je     f0101534 <check_page_alloc+0x36d>
f010133e:	39 c3                	cmp    %eax,%ebx
f0101340:	0f 84 ee 01 00 00    	je     f0101534 <check_page_alloc+0x36d>
	assert(!page_alloc(0));
f0101346:	83 ec 0c             	sub    $0xc,%esp
f0101349:	6a 00                	push   $0x0
f010134b:	e8 ed fd ff ff       	call   f010113d <page_alloc>
f0101350:	83 c4 10             	add    $0x10,%esp
f0101353:	85 c0                	test   %eax,%eax
f0101355:	0f 85 f2 01 00 00    	jne    f010154d <check_page_alloc+0x386>
	memset(page2kva(pp0), 1, PGSIZE);
f010135b:	89 d8                	mov    %ebx,%eax
f010135d:	e8 b8 f9 ff ff       	call   f0100d1a <page2kva>
f0101362:	83 ec 04             	sub    $0x4,%esp
f0101365:	68 00 10 00 00       	push   $0x1000
f010136a:	6a 01                	push   $0x1
f010136c:	50                   	push   %eax
f010136d:	e8 ed 44 00 00       	call   f010585f <memset>
	page_free(pp0);
f0101372:	89 1c 24             	mov    %ebx,(%esp)
f0101375:	e8 0e fe ff ff       	call   f0101188 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010137a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101381:	e8 b7 fd ff ff       	call   f010113d <page_alloc>
f0101386:	83 c4 10             	add    $0x10,%esp
f0101389:	85 c0                	test   %eax,%eax
f010138b:	0f 84 d5 01 00 00    	je     f0101566 <check_page_alloc+0x39f>
	assert(pp && pp0 == pp);
f0101391:	39 c3                	cmp    %eax,%ebx
f0101393:	0f 85 e6 01 00 00    	jne    f010157f <check_page_alloc+0x3b8>
	c = page2kva(pp);
f0101399:	e8 7c f9 ff ff       	call   f0100d1a <page2kva>
f010139e:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		assert(c[i] == 0);
f01013a4:	80 38 00             	cmpb   $0x0,(%eax)
f01013a7:	0f 85 eb 01 00 00    	jne    f0101598 <check_page_alloc+0x3d1>
f01013ad:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f01013b0:	39 d0                	cmp    %edx,%eax
f01013b2:	75 f0                	jne    f01013a4 <check_page_alloc+0x1dd>
	page_free_list = fl;
f01013b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01013b7:	a3 40 12 22 f0       	mov    %eax,0xf0221240
	page_free(pp0);
f01013bc:	83 ec 0c             	sub    $0xc,%esp
f01013bf:	53                   	push   %ebx
f01013c0:	e8 c3 fd ff ff       	call   f0101188 <page_free>
	page_free(pp1);
f01013c5:	83 c4 04             	add    $0x4,%esp
f01013c8:	ff 75 e4             	pushl  -0x1c(%ebp)
f01013cb:	e8 b8 fd ff ff       	call   f0101188 <page_free>
	page_free(pp2);
f01013d0:	89 3c 24             	mov    %edi,(%esp)
f01013d3:	e8 b0 fd ff ff       	call   f0101188 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01013d8:	a1 40 12 22 f0       	mov    0xf0221240,%eax
f01013dd:	83 c4 10             	add    $0x10,%esp
f01013e0:	85 c0                	test   %eax,%eax
f01013e2:	0f 84 c9 01 00 00    	je     f01015b1 <check_page_alloc+0x3ea>
		--nfree;
f01013e8:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01013eb:	8b 00                	mov    (%eax),%eax
f01013ed:	eb f1                	jmp    f01013e0 <check_page_alloc+0x219>
	assert((pp0 = page_alloc(0)));
f01013ef:	68 c3 75 10 f0       	push   $0xf01075c3
f01013f4:	68 fb 74 10 f0       	push   $0xf01074fb
f01013f9:	68 61 03 00 00       	push   $0x361
f01013fe:	68 c4 74 10 f0       	push   $0xf01074c4
f0101403:	e8 62 ec ff ff       	call   f010006a <_panic>
	assert((pp1 = page_alloc(0)));
f0101408:	68 d9 75 10 f0       	push   $0xf01075d9
f010140d:	68 fb 74 10 f0       	push   $0xf01074fb
f0101412:	68 62 03 00 00       	push   $0x362
f0101417:	68 c4 74 10 f0       	push   $0xf01074c4
f010141c:	e8 49 ec ff ff       	call   f010006a <_panic>
	assert((pp2 = page_alloc(0)));
f0101421:	68 ef 75 10 f0       	push   $0xf01075ef
f0101426:	68 fb 74 10 f0       	push   $0xf01074fb
f010142b:	68 63 03 00 00       	push   $0x363
f0101430:	68 c4 74 10 f0       	push   $0xf01074c4
f0101435:	e8 30 ec ff ff       	call   f010006a <_panic>
	assert(pp1 && pp1 != pp0);
f010143a:	68 05 76 10 f0       	push   $0xf0107605
f010143f:	68 fb 74 10 f0       	push   $0xf01074fb
f0101444:	68 66 03 00 00       	push   $0x366
f0101449:	68 c4 74 10 f0       	push   $0xf01074c4
f010144e:	e8 17 ec ff ff       	call   f010006a <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101453:	68 3c 6c 10 f0       	push   $0xf0106c3c
f0101458:	68 fb 74 10 f0       	push   $0xf01074fb
f010145d:	68 67 03 00 00       	push   $0x367
f0101462:	68 c4 74 10 f0       	push   $0xf01074c4
f0101467:	e8 fe eb ff ff       	call   f010006a <_panic>
	assert(page2pa(pp0) < npages * PGSIZE);
f010146c:	68 5c 6c 10 f0       	push   $0xf0106c5c
f0101471:	68 fb 74 10 f0       	push   $0xf01074fb
f0101476:	68 68 03 00 00       	push   $0x368
f010147b:	68 c4 74 10 f0       	push   $0xf01074c4
f0101480:	e8 e5 eb ff ff       	call   f010006a <_panic>
	assert(page2pa(pp1) < npages * PGSIZE);
f0101485:	68 7c 6c 10 f0       	push   $0xf0106c7c
f010148a:	68 fb 74 10 f0       	push   $0xf01074fb
f010148f:	68 69 03 00 00       	push   $0x369
f0101494:	68 c4 74 10 f0       	push   $0xf01074c4
f0101499:	e8 cc eb ff ff       	call   f010006a <_panic>
	assert(page2pa(pp2) < npages * PGSIZE);
f010149e:	68 9c 6c 10 f0       	push   $0xf0106c9c
f01014a3:	68 fb 74 10 f0       	push   $0xf01074fb
f01014a8:	68 6a 03 00 00       	push   $0x36a
f01014ad:	68 c4 74 10 f0       	push   $0xf01074c4
f01014b2:	e8 b3 eb ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f01014b7:	68 17 76 10 f0       	push   $0xf0107617
f01014bc:	68 fb 74 10 f0       	push   $0xf01074fb
f01014c1:	68 71 03 00 00       	push   $0x371
f01014c6:	68 c4 74 10 f0       	push   $0xf01074c4
f01014cb:	e8 9a eb ff ff       	call   f010006a <_panic>
	assert((pp0 = page_alloc(0)));
f01014d0:	68 c3 75 10 f0       	push   $0xf01075c3
f01014d5:	68 fb 74 10 f0       	push   $0xf01074fb
f01014da:	68 78 03 00 00       	push   $0x378
f01014df:	68 c4 74 10 f0       	push   $0xf01074c4
f01014e4:	e8 81 eb ff ff       	call   f010006a <_panic>
	assert((pp1 = page_alloc(0)));
f01014e9:	68 d9 75 10 f0       	push   $0xf01075d9
f01014ee:	68 fb 74 10 f0       	push   $0xf01074fb
f01014f3:	68 79 03 00 00       	push   $0x379
f01014f8:	68 c4 74 10 f0       	push   $0xf01074c4
f01014fd:	e8 68 eb ff ff       	call   f010006a <_panic>
	assert((pp2 = page_alloc(0)));
f0101502:	68 ef 75 10 f0       	push   $0xf01075ef
f0101507:	68 fb 74 10 f0       	push   $0xf01074fb
f010150c:	68 7a 03 00 00       	push   $0x37a
f0101511:	68 c4 74 10 f0       	push   $0xf01074c4
f0101516:	e8 4f eb ff ff       	call   f010006a <_panic>
	assert(pp1 && pp1 != pp0);
f010151b:	68 05 76 10 f0       	push   $0xf0107605
f0101520:	68 fb 74 10 f0       	push   $0xf01074fb
f0101525:	68 7c 03 00 00       	push   $0x37c
f010152a:	68 c4 74 10 f0       	push   $0xf01074c4
f010152f:	e8 36 eb ff ff       	call   f010006a <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101534:	68 3c 6c 10 f0       	push   $0xf0106c3c
f0101539:	68 fb 74 10 f0       	push   $0xf01074fb
f010153e:	68 7d 03 00 00       	push   $0x37d
f0101543:	68 c4 74 10 f0       	push   $0xf01074c4
f0101548:	e8 1d eb ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f010154d:	68 17 76 10 f0       	push   $0xf0107617
f0101552:	68 fb 74 10 f0       	push   $0xf01074fb
f0101557:	68 7e 03 00 00       	push   $0x37e
f010155c:	68 c4 74 10 f0       	push   $0xf01074c4
f0101561:	e8 04 eb ff ff       	call   f010006a <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101566:	68 26 76 10 f0       	push   $0xf0107626
f010156b:	68 fb 74 10 f0       	push   $0xf01074fb
f0101570:	68 83 03 00 00       	push   $0x383
f0101575:	68 c4 74 10 f0       	push   $0xf01074c4
f010157a:	e8 eb ea ff ff       	call   f010006a <_panic>
	assert(pp && pp0 == pp);
f010157f:	68 44 76 10 f0       	push   $0xf0107644
f0101584:	68 fb 74 10 f0       	push   $0xf01074fb
f0101589:	68 84 03 00 00       	push   $0x384
f010158e:	68 c4 74 10 f0       	push   $0xf01074c4
f0101593:	e8 d2 ea ff ff       	call   f010006a <_panic>
		assert(c[i] == 0);
f0101598:	68 54 76 10 f0       	push   $0xf0107654
f010159d:	68 fb 74 10 f0       	push   $0xf01074fb
f01015a2:	68 87 03 00 00       	push   $0x387
f01015a7:	68 c4 74 10 f0       	push   $0xf01074c4
f01015ac:	e8 b9 ea ff ff       	call   f010006a <_panic>
	assert(nfree == 0);
f01015b1:	85 f6                	test   %esi,%esi
f01015b3:	75 18                	jne    f01015cd <check_page_alloc+0x406>
	cprintf("check_page_alloc() succeeded!\n");
f01015b5:	83 ec 0c             	sub    $0xc,%esp
f01015b8:	68 bc 6c 10 f0       	push   $0xf0106cbc
f01015bd:	e8 4e 23 00 00       	call   f0103910 <cprintf>
}
f01015c2:	83 c4 10             	add    $0x10,%esp
f01015c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01015c8:	5b                   	pop    %ebx
f01015c9:	5e                   	pop    %esi
f01015ca:	5f                   	pop    %edi
f01015cb:	5d                   	pop    %ebp
f01015cc:	c3                   	ret    
	assert(nfree == 0);
f01015cd:	68 5e 76 10 f0       	push   $0xf010765e
f01015d2:	68 fb 74 10 f0       	push   $0xf01074fb
f01015d7:	68 94 03 00 00       	push   $0x394
f01015dc:	68 c4 74 10 f0       	push   $0xf01074c4
f01015e1:	e8 84 ea ff ff       	call   f010006a <_panic>

f01015e6 <page_decref>:
{
f01015e6:	f3 0f 1e fb          	endbr32 
f01015ea:	55                   	push   %ebp
f01015eb:	89 e5                	mov    %esp,%ebp
f01015ed:	83 ec 08             	sub    $0x8,%esp
f01015f0:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01015f3:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01015f7:	83 e8 01             	sub    $0x1,%eax
f01015fa:	66 89 42 04          	mov    %ax,0x4(%edx)
f01015fe:	66 85 c0             	test   %ax,%ax
f0101601:	74 02                	je     f0101605 <page_decref+0x1f>
}
f0101603:	c9                   	leave  
f0101604:	c3                   	ret    
		page_free(pp);
f0101605:	83 ec 0c             	sub    $0xc,%esp
f0101608:	52                   	push   %edx
f0101609:	e8 7a fb ff ff       	call   f0101188 <page_free>
f010160e:	83 c4 10             	add    $0x10,%esp
}
f0101611:	eb f0                	jmp    f0101603 <page_decref+0x1d>

f0101613 <pgdir_walk>:
{
f0101613:	f3 0f 1e fb          	endbr32 
f0101617:	55                   	push   %ebp
f0101618:	89 e5                	mov    %esp,%ebp
f010161a:	56                   	push   %esi
f010161b:	53                   	push   %ebx
f010161c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	physaddr_t page_table_index = PTX(va);
f010161f:	89 de                	mov    %ebx,%esi
f0101621:	c1 ee 0c             	shr    $0xc,%esi
f0101624:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	physaddr_t pg_dir_index = PDX(va);
f010162a:	c1 eb 16             	shr    $0x16,%ebx
	if (!(pgdir[pg_dir_index] && PTE_P)) {  // If the directory does not exist
f010162d:	c1 e3 02             	shl    $0x2,%ebx
f0101630:	03 5d 08             	add    0x8(%ebp),%ebx
f0101633:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101636:	75 2b                	jne    f0101663 <pgdir_walk+0x50>
			return NULL;
f0101638:	b8 00 00 00 00       	mov    $0x0,%eax
		if (create) {
f010163d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101641:	74 3a                	je     f010167d <pgdir_walk+0x6a>
			        page_alloc(ALLOC_ZERO);  // Alloc new page
f0101643:	83 ec 0c             	sub    $0xc,%esp
f0101646:	6a 01                	push   $0x1
f0101648:	e8 f0 fa ff ff       	call   f010113d <page_alloc>
			if (!new_page) {  // If page_alloc() fails
f010164d:	83 c4 10             	add    $0x10,%esp
f0101650:	85 c0                	test   %eax,%eax
f0101652:	74 29                	je     f010167d <pgdir_walk+0x6a>
			new_page->pp_ref++;  // I have to increment the number of pointers to this page
f0101654:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			        page2pa(new_page) | PTE_P | PTE_U |
f0101659:	e8 80 f5 ff ff       	call   f0100bde <page2pa>
f010165e:	83 c8 07             	or     $0x7,%eax
f0101661:	89 03                	mov    %eax,(%ebx)
	pte_t *virtual_dir = KADDR(PTE_ADDR(pgdir[pg_dir_index]));
f0101663:	8b 0b                	mov    (%ebx),%ecx
f0101665:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010166b:	ba e7 01 00 00       	mov    $0x1e7,%edx
f0101670:	b8 c4 74 10 f0       	mov    $0xf01074c4,%eax
f0101675:	e8 74 f6 ff ff       	call   f0100cee <_kaddr>
	return virtual_dir + page_table_index;
f010167a:	8d 04 b0             	lea    (%eax,%esi,4),%eax
}
f010167d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101680:	5b                   	pop    %ebx
f0101681:	5e                   	pop    %esi
f0101682:	5d                   	pop    %ebp
f0101683:	c3                   	ret    

f0101684 <boot_map_region>:
{
f0101684:	55                   	push   %ebp
f0101685:	89 e5                	mov    %esp,%ebp
f0101687:	57                   	push   %edi
f0101688:	56                   	push   %esi
f0101689:	53                   	push   %ebx
f010168a:	83 ec 1c             	sub    $0x1c,%esp
f010168d:	89 c7                	mov    %eax,%edi
	while (size > 0) {
f010168f:	89 ce                	mov    %ecx,%esi
f0101691:	89 c8                	mov    %ecx,%eax
f0101693:	03 45 08             	add    0x8(%ebp),%eax
f0101696:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		pte_t *v_addr = pgdir_walk(pgdir, (void *) va, true);
f0101699:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
f010169c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010169f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01016a2:	29 f3                	sub    %esi,%ebx
	while (size > 0) {
f01016a4:	85 f6                	test   %esi,%esi
f01016a6:	74 3f                	je     f01016e7 <boot_map_region+0x63>
		pte_t *v_addr = pgdir_walk(pgdir, (void *) va, true);
f01016a8:	83 ec 04             	sub    $0x4,%esp
f01016ab:	6a 01                	push   $0x1
f01016ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01016b0:	29 f0                	sub    %esi,%eax
f01016b2:	50                   	push   %eax
f01016b3:	57                   	push   %edi
f01016b4:	e8 5a ff ff ff       	call   f0101613 <pgdir_walk>
		if (v_addr == NULL) {
f01016b9:	83 c4 10             	add    $0x10,%esp
f01016bc:	85 c0                	test   %eax,%eax
f01016be:	74 10                	je     f01016d0 <boot_map_region+0x4c>
		*v_addr = pa | perm | PTE_P;
f01016c0:	0b 5d 0c             	or     0xc(%ebp),%ebx
f01016c3:	83 cb 01             	or     $0x1,%ebx
f01016c6:	89 18                	mov    %ebx,(%eax)
		size -= aux;
f01016c8:	81 ee 00 10 00 00    	sub    $0x1000,%esi
f01016ce:	eb cf                	jmp    f010169f <boot_map_region+0x1b>
			panic("Boot map region error");
f01016d0:	83 ec 04             	sub    $0x4,%esp
f01016d3:	68 69 76 10 f0       	push   $0xf0107669
f01016d8:	68 05 02 00 00       	push   $0x205
f01016dd:	68 c4 74 10 f0       	push   $0xf01074c4
f01016e2:	e8 83 e9 ff ff       	call   f010006a <_panic>
}
f01016e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01016ea:	5b                   	pop    %ebx
f01016eb:	5e                   	pop    %esi
f01016ec:	5f                   	pop    %edi
f01016ed:	5d                   	pop    %ebp
f01016ee:	c3                   	ret    

f01016ef <mem_init_mp>:
{
f01016ef:	55                   	push   %ebp
f01016f0:	89 e5                	mov    %esp,%ebp
f01016f2:	57                   	push   %edi
f01016f3:	56                   	push   %esi
f01016f4:	53                   	push   %ebx
f01016f5:	83 ec 0c             	sub    $0xc,%esp
f01016f8:	bb 00 40 22 f0       	mov    $0xf0224000,%ebx
f01016fd:	bf 00 40 26 f0       	mov    $0xf0264000,%edi
f0101702:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		boot_map_region(kern_pgdir,
f0101707:	89 d9                	mov    %ebx,%ecx
f0101709:	ba 31 01 00 00       	mov    $0x131,%edx
f010170e:	b8 c4 74 10 f0       	mov    $0xf01074c4,%eax
f0101713:	e8 88 f6 ff ff       	call   f0100da0 <_paddr>
f0101718:	83 ec 08             	sub    $0x8,%esp
f010171b:	6a 03                	push   $0x3
f010171d:	50                   	push   %eax
f010171e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101723:	89 f2                	mov    %esi,%edx
f0101725:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f010172a:	e8 55 ff ff ff       	call   f0101684 <boot_map_region>
f010172f:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0101735:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for (int i = 0; i < NCPU; i++) {
f010173b:	83 c4 10             	add    $0x10,%esp
f010173e:	39 fb                	cmp    %edi,%ebx
f0101740:	75 c5                	jne    f0101707 <mem_init_mp+0x18>
}
f0101742:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101745:	5b                   	pop    %ebx
f0101746:	5e                   	pop    %esi
f0101747:	5f                   	pop    %edi
f0101748:	5d                   	pop    %ebp
f0101749:	c3                   	ret    

f010174a <check_kern_pgdir>:
{
f010174a:	55                   	push   %ebp
f010174b:	89 e5                	mov    %esp,%ebp
f010174d:	57                   	push   %edi
f010174e:	56                   	push   %esi
f010174f:	53                   	push   %ebx
f0101750:	83 ec 1c             	sub    $0x1c,%esp
	pgdir = kern_pgdir;
f0101753:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
	n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f0101759:	a1 88 2e 22 f0       	mov    0xf0222e88,%eax
f010175e:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0101765:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010176a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0; i < n; i += PGSIZE) {
f010176d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101772:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0101775:	0f 83 83 00 00 00    	jae    f01017fe <check_kern_pgdir+0xb4>
f010177b:	8d b3 00 00 00 ef    	lea    -0x11000000(%ebx),%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101781:	89 f2                	mov    %esi,%edx
f0101783:	89 f8                	mov    %edi,%eax
f0101785:	e8 ae f5 ff ff       	call   f0100d38 <check_va2pa>
f010178a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010178d:	8b 0d 90 2e 22 f0    	mov    0xf0222e90,%ecx
f0101793:	ba ad 03 00 00       	mov    $0x3ad,%edx
f0101798:	b8 c4 74 10 f0       	mov    $0xf01074c4,%eax
f010179d:	e8 fe f5 ff ff       	call   f0100da0 <_paddr>
f01017a2:	01 d8                	add    %ebx,%eax
f01017a4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f01017a7:	75 23                	jne    f01017cc <check_kern_pgdir+0x82>
		pte = pgdir_walk(pgdir, (void *) (UPAGES + i), 0);
f01017a9:	83 ec 04             	sub    $0x4,%esp
f01017ac:	6a 00                	push   $0x0
f01017ae:	56                   	push   %esi
f01017af:	57                   	push   %edi
f01017b0:	e8 5e fe ff ff       	call   f0101613 <pgdir_walk>
		assert(PGOFF(*pte) == (PTE_U | PTE_P));
f01017b5:	8b 00                	mov    (%eax),%eax
f01017b7:	25 ff 0f 00 00       	and    $0xfff,%eax
f01017bc:	83 c4 10             	add    $0x10,%esp
f01017bf:	83 f8 05             	cmp    $0x5,%eax
f01017c2:	75 21                	jne    f01017e5 <check_kern_pgdir+0x9b>
	for (i = 0; i < n; i += PGSIZE) {
f01017c4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01017ca:	eb a6                	jmp    f0101772 <check_kern_pgdir+0x28>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01017cc:	68 dc 6c 10 f0       	push   $0xf0106cdc
f01017d1:	68 fb 74 10 f0       	push   $0xf01074fb
f01017d6:	68 ad 03 00 00       	push   $0x3ad
f01017db:	68 c4 74 10 f0       	push   $0xf01074c4
f01017e0:	e8 85 e8 ff ff       	call   f010006a <_panic>
		assert(PGOFF(*pte) == (PTE_U | PTE_P));
f01017e5:	68 10 6d 10 f0       	push   $0xf0106d10
f01017ea:	68 fb 74 10 f0       	push   $0xf01074fb
f01017ef:	68 b0 03 00 00       	push   $0x3b0
f01017f4:	68 c4 74 10 f0       	push   $0xf01074c4
f01017f9:	e8 6c e8 ff ff       	call   f010006a <_panic>
f01017fe:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0101803:	89 da                	mov    %ebx,%edx
f0101805:	89 f8                	mov    %edi,%eax
f0101807:	e8 2c f5 ff ff       	call   f0100d38 <check_va2pa>
f010180c:	89 c6                	mov    %eax,%esi
f010180e:	8b 0d 44 12 22 f0    	mov    0xf0221244,%ecx
f0101814:	ba b6 03 00 00       	mov    $0x3b6,%edx
f0101819:	b8 c4 74 10 f0       	mov    $0xf01074c4,%eax
f010181e:	e8 7d f5 ff ff       	call   f0100da0 <_paddr>
f0101823:	8d 84 03 00 00 40 11 	lea    0x11400000(%ebx,%eax,1),%eax
f010182a:	39 c6                	cmp    %eax,%esi
f010182c:	75 54                	jne    f0101882 <check_kern_pgdir+0x138>
		pte = pgdir_walk(pgdir, (void *) (UENVS + i), 0);
f010182e:	83 ec 04             	sub    $0x4,%esp
f0101831:	6a 00                	push   $0x0
f0101833:	53                   	push   %ebx
f0101834:	57                   	push   %edi
f0101835:	e8 d9 fd ff ff       	call   f0101613 <pgdir_walk>
		assert(PGOFF(*pte) == (PTE_U | PTE_P));
f010183a:	8b 00                	mov    (%eax),%eax
f010183c:	25 ff 0f 00 00       	and    $0xfff,%eax
f0101841:	83 c4 10             	add    $0x10,%esp
f0101844:	83 f8 05             	cmp    $0x5,%eax
f0101847:	75 52                	jne    f010189b <check_kern_pgdir+0x151>
f0101849:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE) {
f010184f:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0101855:	75 ac                	jne    f0101803 <check_kern_pgdir+0xb9>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0101857:	8b 35 88 2e 22 f0    	mov    0xf0222e88,%esi
f010185d:	c1 e6 0c             	shl    $0xc,%esi
f0101860:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101865:	39 de                	cmp    %ebx,%esi
f0101867:	76 64                	jbe    f01018cd <check_kern_pgdir+0x183>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0101869:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010186f:	89 f8                	mov    %edi,%eax
f0101871:	e8 c2 f4 ff ff       	call   f0100d38 <check_va2pa>
f0101876:	39 d8                	cmp    %ebx,%eax
f0101878:	75 3a                	jne    f01018b4 <check_kern_pgdir+0x16a>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010187a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101880:	eb e3                	jmp    f0101865 <check_kern_pgdir+0x11b>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0101882:	68 30 6d 10 f0       	push   $0xf0106d30
f0101887:	68 fb 74 10 f0       	push   $0xf01074fb
f010188c:	68 b6 03 00 00       	push   $0x3b6
f0101891:	68 c4 74 10 f0       	push   $0xf01074c4
f0101896:	e8 cf e7 ff ff       	call   f010006a <_panic>
		assert(PGOFF(*pte) == (PTE_U | PTE_P));
f010189b:	68 10 6d 10 f0       	push   $0xf0106d10
f01018a0:	68 fb 74 10 f0       	push   $0xf01074fb
f01018a5:	68 b9 03 00 00       	push   $0x3b9
f01018aa:	68 c4 74 10 f0       	push   $0xf01074c4
f01018af:	e8 b6 e7 ff ff       	call   f010006a <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01018b4:	68 64 6d 10 f0       	push   $0xf0106d64
f01018b9:	68 fb 74 10 f0       	push   $0xf01074fb
f01018be:	68 be 03 00 00       	push   $0x3be
f01018c3:	68 c4 74 10 f0       	push   $0xf01074c4
f01018c8:	e8 9d e7 ff ff       	call   f010006a <_panic>
f01018cd:	c7 45 dc 00 40 22 f0 	movl   $0xf0224000,-0x24(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01018d4:	b8 00 80 ff ef       	mov    $0xefff8000,%eax
f01018d9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01018dc:	89 c7                	mov    %eax,%edi
f01018de:	8d b7 00 80 ff ff    	lea    -0x8000(%edi),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i) ==
f01018e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01018e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01018ea:	bb 00 00 00 00       	mov    $0x0,%ebx
f01018ef:	89 75 d8             	mov    %esi,-0x28(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i) ==
f01018f2:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f01018f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01018f8:	e8 3b f4 ff ff       	call   f0100d38 <check_va2pa>
f01018fd:	89 c6                	mov    %eax,%esi
f01018ff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101902:	ba c6 03 00 00       	mov    $0x3c6,%edx
f0101907:	b8 c4 74 10 f0       	mov    $0xf01074c4,%eax
f010190c:	e8 8f f4 ff ff       	call   f0100da0 <_paddr>
f0101911:	01 d8                	add    %ebx,%eax
f0101913:	39 c6                	cmp    %eax,%esi
f0101915:	75 4d                	jne    f0101964 <check_kern_pgdir+0x21a>
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0101917:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010191d:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0101923:	75 cd                	jne    f01018f2 <check_kern_pgdir+0x1a8>
f0101925:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0101928:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f010192b:	89 f2                	mov    %esi,%edx
f010192d:	89 d8                	mov    %ebx,%eax
f010192f:	e8 04 f4 ff ff       	call   f0100d38 <check_va2pa>
f0101934:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101937:	75 44                	jne    f010197d <check_kern_pgdir+0x233>
f0101939:	81 c6 00 10 00 00    	add    $0x1000,%esi
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010193f:	39 fe                	cmp    %edi,%esi
f0101941:	75 e8                	jne    f010192b <check_kern_pgdir+0x1e1>
f0101943:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0101946:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f010194c:	81 45 dc 00 80 00 00 	addl   $0x8000,-0x24(%ebp)
	for (n = 0; n < NCPU; n++) {
f0101953:	81 ff 00 80 f7 ef    	cmp    $0xeff78000,%edi
f0101959:	75 83                	jne    f01018de <check_kern_pgdir+0x194>
f010195b:	89 df                	mov    %ebx,%edi
	for (i = 0; i < NPDENTRIES; i++) {
f010195d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101962:	eb 68                	jmp    f01019cc <check_kern_pgdir+0x282>
			assert(check_va2pa(pgdir, base + KSTKGAP + i) ==
f0101964:	68 8c 6d 10 f0       	push   $0xf0106d8c
f0101969:	68 fb 74 10 f0       	push   $0xf01074fb
f010196e:	68 c5 03 00 00       	push   $0x3c5
f0101973:	68 c4 74 10 f0       	push   $0xf01074c4
f0101978:	e8 ed e6 ff ff       	call   f010006a <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f010197d:	68 d4 6d 10 f0       	push   $0xf0106dd4
f0101982:	68 fb 74 10 f0       	push   $0xf01074fb
f0101987:	68 c8 03 00 00       	push   $0x3c8
f010198c:	68 c4 74 10 f0       	push   $0xf01074c4
f0101991:	e8 d4 e6 ff ff       	call   f010006a <_panic>
			assert(pgdir[i] & PTE_P);
f0101996:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f010199a:	75 48                	jne    f01019e4 <check_kern_pgdir+0x29a>
f010199c:	68 7f 76 10 f0       	push   $0xf010767f
f01019a1:	68 fb 74 10 f0       	push   $0xf01074fb
f01019a6:	68 d3 03 00 00       	push   $0x3d3
f01019ab:	68 c4 74 10 f0       	push   $0xf01074c4
f01019b0:	e8 b5 e6 ff ff       	call   f010006a <_panic>
				assert(pgdir[i] & PTE_P);
f01019b5:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01019b8:	f6 c2 01             	test   $0x1,%dl
f01019bb:	74 2c                	je     f01019e9 <check_kern_pgdir+0x29f>
				assert(pgdir[i] & PTE_W);
f01019bd:	f6 c2 02             	test   $0x2,%dl
f01019c0:	74 40                	je     f0101a02 <check_kern_pgdir+0x2b8>
	for (i = 0; i < NPDENTRIES; i++) {
f01019c2:	83 c0 01             	add    $0x1,%eax
f01019c5:	3d 00 04 00 00       	cmp    $0x400,%eax
f01019ca:	74 68                	je     f0101a34 <check_kern_pgdir+0x2ea>
		switch (i) {
f01019cc:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01019d2:	83 fa 04             	cmp    $0x4,%edx
f01019d5:	76 bf                	jbe    f0101996 <check_kern_pgdir+0x24c>
			if (i >= PDX(KERNBASE)) {
f01019d7:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01019dc:	77 d7                	ja     f01019b5 <check_kern_pgdir+0x26b>
				assert(pgdir[i] == 0);
f01019de:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01019e2:	75 37                	jne    f0101a1b <check_kern_pgdir+0x2d1>
	for (i = 0; i < NPDENTRIES; i++) {
f01019e4:	83 c0 01             	add    $0x1,%eax
f01019e7:	eb e3                	jmp    f01019cc <check_kern_pgdir+0x282>
				assert(pgdir[i] & PTE_P);
f01019e9:	68 7f 76 10 f0       	push   $0xf010767f
f01019ee:	68 fb 74 10 f0       	push   $0xf01074fb
f01019f3:	68 d7 03 00 00       	push   $0x3d7
f01019f8:	68 c4 74 10 f0       	push   $0xf01074c4
f01019fd:	e8 68 e6 ff ff       	call   f010006a <_panic>
				assert(pgdir[i] & PTE_W);
f0101a02:	68 90 76 10 f0       	push   $0xf0107690
f0101a07:	68 fb 74 10 f0       	push   $0xf01074fb
f0101a0c:	68 d8 03 00 00       	push   $0x3d8
f0101a11:	68 c4 74 10 f0       	push   $0xf01074c4
f0101a16:	e8 4f e6 ff ff       	call   f010006a <_panic>
				assert(pgdir[i] == 0);
f0101a1b:	68 a1 76 10 f0       	push   $0xf01076a1
f0101a20:	68 fb 74 10 f0       	push   $0xf01074fb
f0101a25:	68 da 03 00 00       	push   $0x3da
f0101a2a:	68 c4 74 10 f0       	push   $0xf01074c4
f0101a2f:	e8 36 e6 ff ff       	call   f010006a <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0101a34:	83 ec 0c             	sub    $0xc,%esp
f0101a37:	68 f8 6d 10 f0       	push   $0xf0106df8
f0101a3c:	e8 cf 1e 00 00       	call   f0103910 <cprintf>
}
f0101a41:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101a44:	5b                   	pop    %ebx
f0101a45:	5e                   	pop    %esi
f0101a46:	5f                   	pop    %edi
f0101a47:	5d                   	pop    %ebp
f0101a48:	c3                   	ret    

f0101a49 <page_lookup>:
{
f0101a49:	f3 0f 1e fb          	endbr32 
f0101a4d:	55                   	push   %ebp
f0101a4e:	89 e5                	mov    %esp,%ebp
f0101a50:	53                   	push   %ebx
f0101a51:	83 ec 08             	sub    $0x8,%esp
f0101a54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *v_addr = pgdir_walk(pgdir, va, false);
f0101a57:	6a 00                	push   $0x0
f0101a59:	ff 75 0c             	pushl  0xc(%ebp)
f0101a5c:	ff 75 08             	pushl  0x8(%ebp)
f0101a5f:	e8 af fb ff ff       	call   f0101613 <pgdir_walk>
	if (v_addr == NULL ||
f0101a64:	83 c4 10             	add    $0x10,%esp
f0101a67:	85 c0                	test   %eax,%eax
f0101a69:	74 17                	je     f0101a82 <page_lookup+0x39>
f0101a6b:	83 38 00             	cmpl   $0x0,(%eax)
f0101a6e:	74 17                	je     f0101a87 <page_lookup+0x3e>
	if (pte_store) {
f0101a70:	85 db                	test   %ebx,%ebx
f0101a72:	74 02                	je     f0101a76 <page_lookup+0x2d>
		*pte_store = v_addr;
f0101a74:	89 03                	mov    %eax,(%ebx)
	return pa2page(PTE_ADDR(
f0101a76:	8b 00                	mov    (%eax),%eax
f0101a78:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101a7d:	e8 f3 f5 ff ff       	call   f0101075 <pa2page>
}
f0101a82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101a85:	c9                   	leave  
f0101a86:	c3                   	ret    
		return NULL;
f0101a87:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a8c:	eb f4                	jmp    f0101a82 <page_lookup+0x39>

f0101a8e <tlb_invalidate>:
{
f0101a8e:	f3 0f 1e fb          	endbr32 
f0101a92:	55                   	push   %ebp
f0101a93:	89 e5                	mov    %esp,%ebp
f0101a95:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f0101a98:	e8 53 44 00 00       	call   f0105ef0 <cpunum>
f0101a9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0101aa0:	83 b8 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%eax)
f0101aa7:	74 16                	je     f0101abf <tlb_invalidate+0x31>
f0101aa9:	e8 42 44 00 00       	call   f0105ef0 <cpunum>
f0101aae:	6b c0 74             	imul   $0x74,%eax,%eax
f0101ab1:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0101ab7:	8b 55 08             	mov    0x8(%ebp),%edx
f0101aba:	39 50 60             	cmp    %edx,0x60(%eax)
f0101abd:	75 08                	jne    f0101ac7 <tlb_invalidate+0x39>
		invlpg(va);
f0101abf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101ac2:	e8 07 f1 ff ff       	call   f0100bce <invlpg>
}
f0101ac7:	c9                   	leave  
f0101ac8:	c3                   	ret    

f0101ac9 <page_remove>:
{
f0101ac9:	f3 0f 1e fb          	endbr32 
f0101acd:	55                   	push   %ebp
f0101ace:	89 e5                	mov    %esp,%ebp
f0101ad0:	56                   	push   %esi
f0101ad1:	53                   	push   %ebx
f0101ad2:	83 ec 14             	sub    $0x14,%esp
f0101ad5:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101ad8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo *page = page_lookup(pgdir, va, &buf);
f0101adb:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101ade:	50                   	push   %eax
f0101adf:	56                   	push   %esi
f0101ae0:	53                   	push   %ebx
f0101ae1:	e8 63 ff ff ff       	call   f0101a49 <page_lookup>
	if (!(*buf && PTE_P) ||
f0101ae6:	83 c4 10             	add    $0x10,%esp
f0101ae9:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101aec:	83 3a 00             	cmpl   $0x0,(%edx)
f0101aef:	74 23                	je     f0101b14 <page_remove+0x4b>
f0101af1:	85 c0                	test   %eax,%eax
f0101af3:	74 1f                	je     f0101b14 <page_remove+0x4b>
	page_decref(page);          // First two conditions
f0101af5:	83 ec 0c             	sub    $0xc,%esp
f0101af8:	50                   	push   %eax
f0101af9:	e8 e8 fa ff ff       	call   f01015e6 <page_decref>
	*buf = 0;                   // Third condition
f0101afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101b01:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);  // Last condition
f0101b07:	83 c4 08             	add    $0x8,%esp
f0101b0a:	56                   	push   %esi
f0101b0b:	53                   	push   %ebx
f0101b0c:	e8 7d ff ff ff       	call   f0101a8e <tlb_invalidate>
f0101b11:	83 c4 10             	add    $0x10,%esp
}
f0101b14:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101b17:	5b                   	pop    %ebx
f0101b18:	5e                   	pop    %esi
f0101b19:	5d                   	pop    %ebp
f0101b1a:	c3                   	ret    

f0101b1b <page_insert>:
{
f0101b1b:	f3 0f 1e fb          	endbr32 
f0101b1f:	55                   	push   %ebp
f0101b20:	89 e5                	mov    %esp,%ebp
f0101b22:	57                   	push   %edi
f0101b23:	56                   	push   %esi
f0101b24:	53                   	push   %ebx
f0101b25:	83 ec 10             	sub    $0x10,%esp
f0101b28:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101b2b:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *v_addr = pgdir_walk(pgdir, va, true);
f0101b2e:	6a 01                	push   $0x1
f0101b30:	57                   	push   %edi
f0101b31:	ff 75 08             	pushl  0x8(%ebp)
f0101b34:	e8 da fa ff ff       	call   f0101613 <pgdir_walk>
	if (v_addr == NULL) {  // Fail case
f0101b39:	83 c4 10             	add    $0x10,%esp
f0101b3c:	85 c0                	test   %eax,%eax
f0101b3e:	74 39                	je     f0101b79 <page_insert+0x5e>
f0101b40:	89 c3                	mov    %eax,%ebx
	pp->pp_ref++;
f0101b42:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if (*v_addr && PTE_P) {  // If the page already exists and it is readable
f0101b47:	83 38 00             	cmpl   $0x0,(%eax)
f0101b4a:	75 1c                	jne    f0101b68 <page_insert+0x4d>
	*v_addr = page2pa(pp) | perm | PTE_P;  // Insert new page (pp)
f0101b4c:	89 f0                	mov    %esi,%eax
f0101b4e:	e8 8b f0 ff ff       	call   f0100bde <page2pa>
f0101b53:	0b 45 14             	or     0x14(%ebp),%eax
f0101b56:	83 c8 01             	or     $0x1,%eax
f0101b59:	89 03                	mov    %eax,(%ebx)
	return 0;
f0101b5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101b60:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101b63:	5b                   	pop    %ebx
f0101b64:	5e                   	pop    %esi
f0101b65:	5f                   	pop    %edi
f0101b66:	5d                   	pop    %ebp
f0101b67:	c3                   	ret    
		page_remove(pgdir, va);
f0101b68:	83 ec 08             	sub    $0x8,%esp
f0101b6b:	57                   	push   %edi
f0101b6c:	ff 75 08             	pushl  0x8(%ebp)
f0101b6f:	e8 55 ff ff ff       	call   f0101ac9 <page_remove>
f0101b74:	83 c4 10             	add    $0x10,%esp
f0101b77:	eb d3                	jmp    f0101b4c <page_insert+0x31>
		return -E_NO_MEM;
f0101b79:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101b7e:	eb e0                	jmp    f0101b60 <page_insert+0x45>

f0101b80 <check_page_installed_pgdir>:
}

// check page_insert, page_remove, &c, with an installed kern_pgdir
static void
check_page_installed_pgdir(void)
{
f0101b80:	55                   	push   %ebp
f0101b81:	89 e5                	mov    %esp,%ebp
f0101b83:	57                   	push   %edi
f0101b84:	56                   	push   %esi
f0101b85:	53                   	push   %ebx
f0101b86:	83 ec 18             	sub    $0x18,%esp
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b89:	6a 00                	push   $0x0
f0101b8b:	e8 ad f5 ff ff       	call   f010113d <page_alloc>
f0101b90:	83 c4 10             	add    $0x10,%esp
f0101b93:	85 c0                	test   %eax,%eax
f0101b95:	0f 84 67 01 00 00    	je     f0101d02 <check_page_installed_pgdir+0x182>
f0101b9b:	89 c6                	mov    %eax,%esi
	assert((pp1 = page_alloc(0)));
f0101b9d:	83 ec 0c             	sub    $0xc,%esp
f0101ba0:	6a 00                	push   $0x0
f0101ba2:	e8 96 f5 ff ff       	call   f010113d <page_alloc>
f0101ba7:	89 c7                	mov    %eax,%edi
f0101ba9:	83 c4 10             	add    $0x10,%esp
f0101bac:	85 c0                	test   %eax,%eax
f0101bae:	0f 84 67 01 00 00    	je     f0101d1b <check_page_installed_pgdir+0x19b>
	assert((pp2 = page_alloc(0)));
f0101bb4:	83 ec 0c             	sub    $0xc,%esp
f0101bb7:	6a 00                	push   $0x0
f0101bb9:	e8 7f f5 ff ff       	call   f010113d <page_alloc>
f0101bbe:	89 c3                	mov    %eax,%ebx
f0101bc0:	83 c4 10             	add    $0x10,%esp
f0101bc3:	85 c0                	test   %eax,%eax
f0101bc5:	0f 84 69 01 00 00    	je     f0101d34 <check_page_installed_pgdir+0x1b4>
	page_free(pp0);
f0101bcb:	83 ec 0c             	sub    $0xc,%esp
f0101bce:	56                   	push   %esi
f0101bcf:	e8 b4 f5 ff ff       	call   f0101188 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0101bd4:	89 f8                	mov    %edi,%eax
f0101bd6:	e8 3f f1 ff ff       	call   f0100d1a <page2kva>
f0101bdb:	83 c4 0c             	add    $0xc,%esp
f0101bde:	68 00 10 00 00       	push   $0x1000
f0101be3:	6a 01                	push   $0x1
f0101be5:	50                   	push   %eax
f0101be6:	e8 74 3c 00 00       	call   f010585f <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0101beb:	89 d8                	mov    %ebx,%eax
f0101bed:	e8 28 f1 ff ff       	call   f0100d1a <page2kva>
f0101bf2:	83 c4 0c             	add    $0xc,%esp
f0101bf5:	68 00 10 00 00       	push   $0x1000
f0101bfa:	6a 02                	push   $0x2
f0101bfc:	50                   	push   %eax
f0101bfd:	e8 5d 3c 00 00       	call   f010585f <memset>
	page_insert(kern_pgdir, pp1, (void *) PGSIZE, PTE_W);
f0101c02:	6a 02                	push   $0x2
f0101c04:	68 00 10 00 00       	push   $0x1000
f0101c09:	57                   	push   %edi
f0101c0a:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0101c10:	e8 06 ff ff ff       	call   f0101b1b <page_insert>
	assert(pp1->pp_ref == 1);
f0101c15:	83 c4 20             	add    $0x20,%esp
f0101c18:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c1d:	0f 85 2a 01 00 00    	jne    f0101d4d <check_page_installed_pgdir+0x1cd>
	assert(*(uint32_t *) PGSIZE == 0x01010101U);
f0101c23:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0101c2a:	01 01 01 
f0101c2d:	0f 85 33 01 00 00    	jne    f0101d66 <check_page_installed_pgdir+0x1e6>
	page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W);
f0101c33:	6a 02                	push   $0x2
f0101c35:	68 00 10 00 00       	push   $0x1000
f0101c3a:	53                   	push   %ebx
f0101c3b:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0101c41:	e8 d5 fe ff ff       	call   f0101b1b <page_insert>
	assert(*(uint32_t *) PGSIZE == 0x02020202U);
f0101c46:	83 c4 10             	add    $0x10,%esp
f0101c49:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0101c50:	02 02 02 
f0101c53:	0f 85 26 01 00 00    	jne    f0101d7f <check_page_installed_pgdir+0x1ff>
	assert(pp2->pp_ref == 1);
f0101c59:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101c5e:	0f 85 34 01 00 00    	jne    f0101d98 <check_page_installed_pgdir+0x218>
	assert(pp1->pp_ref == 0);
f0101c64:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101c69:	0f 85 42 01 00 00    	jne    f0101db1 <check_page_installed_pgdir+0x231>
	*(uint32_t *) PGSIZE = 0x03030303U;
f0101c6f:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0101c76:	03 03 03 
	assert(*(uint32_t *) page2kva(pp2) == 0x03030303U);
f0101c79:	89 d8                	mov    %ebx,%eax
f0101c7b:	e8 9a f0 ff ff       	call   f0100d1a <page2kva>
f0101c80:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0101c86:	0f 85 3e 01 00 00    	jne    f0101dca <check_page_installed_pgdir+0x24a>
	page_remove(kern_pgdir, (void *) PGSIZE);
f0101c8c:	83 ec 08             	sub    $0x8,%esp
f0101c8f:	68 00 10 00 00       	push   $0x1000
f0101c94:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0101c9a:	e8 2a fe ff ff       	call   f0101ac9 <page_remove>
	assert(pp2->pp_ref == 0);
f0101c9f:	83 c4 10             	add    $0x10,%esp
f0101ca2:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101ca7:	0f 85 36 01 00 00    	jne    f0101de3 <check_page_installed_pgdir+0x263>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101cad:	8b 1d 8c 2e 22 f0    	mov    0xf0222e8c,%ebx
f0101cb3:	89 f0                	mov    %esi,%eax
f0101cb5:	e8 24 ef ff ff       	call   f0100bde <page2pa>
f0101cba:	89 c2                	mov    %eax,%edx
f0101cbc:	8b 03                	mov    (%ebx),%eax
f0101cbe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101cc3:	39 d0                	cmp    %edx,%eax
f0101cc5:	0f 85 31 01 00 00    	jne    f0101dfc <check_page_installed_pgdir+0x27c>
	kern_pgdir[0] = 0;
f0101ccb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	assert(pp0->pp_ref == 1);
f0101cd1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101cd6:	0f 85 39 01 00 00    	jne    f0101e15 <check_page_installed_pgdir+0x295>
	pp0->pp_ref = 0;
f0101cdc:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0101ce2:	83 ec 0c             	sub    $0xc,%esp
f0101ce5:	56                   	push   %esi
f0101ce6:	e8 9d f4 ff ff       	call   f0101188 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0101ceb:	c7 04 24 b4 6e 10 f0 	movl   $0xf0106eb4,(%esp)
f0101cf2:	e8 19 1c 00 00       	call   f0103910 <cprintf>
}
f0101cf7:	83 c4 10             	add    $0x10,%esp
f0101cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101cfd:	5b                   	pop    %ebx
f0101cfe:	5e                   	pop    %esi
f0101cff:	5f                   	pop    %edi
f0101d00:	5d                   	pop    %ebp
f0101d01:	c3                   	ret    
	assert((pp0 = page_alloc(0)));
f0101d02:	68 c3 75 10 f0       	push   $0xf01075c3
f0101d07:	68 fb 74 10 f0       	push   $0xf01074fb
f0101d0c:	68 c0 04 00 00       	push   $0x4c0
f0101d11:	68 c4 74 10 f0       	push   $0xf01074c4
f0101d16:	e8 4f e3 ff ff       	call   f010006a <_panic>
	assert((pp1 = page_alloc(0)));
f0101d1b:	68 d9 75 10 f0       	push   $0xf01075d9
f0101d20:	68 fb 74 10 f0       	push   $0xf01074fb
f0101d25:	68 c1 04 00 00       	push   $0x4c1
f0101d2a:	68 c4 74 10 f0       	push   $0xf01074c4
f0101d2f:	e8 36 e3 ff ff       	call   f010006a <_panic>
	assert((pp2 = page_alloc(0)));
f0101d34:	68 ef 75 10 f0       	push   $0xf01075ef
f0101d39:	68 fb 74 10 f0       	push   $0xf01074fb
f0101d3e:	68 c2 04 00 00       	push   $0x4c2
f0101d43:	68 c4 74 10 f0       	push   $0xf01074c4
f0101d48:	e8 1d e3 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 1);
f0101d4d:	68 af 76 10 f0       	push   $0xf01076af
f0101d52:	68 fb 74 10 f0       	push   $0xf01074fb
f0101d57:	68 c7 04 00 00       	push   $0x4c7
f0101d5c:	68 c4 74 10 f0       	push   $0xf01074c4
f0101d61:	e8 04 e3 ff ff       	call   f010006a <_panic>
	assert(*(uint32_t *) PGSIZE == 0x01010101U);
f0101d66:	68 18 6e 10 f0       	push   $0xf0106e18
f0101d6b:	68 fb 74 10 f0       	push   $0xf01074fb
f0101d70:	68 c8 04 00 00       	push   $0x4c8
f0101d75:	68 c4 74 10 f0       	push   $0xf01074c4
f0101d7a:	e8 eb e2 ff ff       	call   f010006a <_panic>
	assert(*(uint32_t *) PGSIZE == 0x02020202U);
f0101d7f:	68 3c 6e 10 f0       	push   $0xf0106e3c
f0101d84:	68 fb 74 10 f0       	push   $0xf01074fb
f0101d89:	68 ca 04 00 00       	push   $0x4ca
f0101d8e:	68 c4 74 10 f0       	push   $0xf01074c4
f0101d93:	e8 d2 e2 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 1);
f0101d98:	68 c0 76 10 f0       	push   $0xf01076c0
f0101d9d:	68 fb 74 10 f0       	push   $0xf01074fb
f0101da2:	68 cb 04 00 00       	push   $0x4cb
f0101da7:	68 c4 74 10 f0       	push   $0xf01074c4
f0101dac:	e8 b9 e2 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 0);
f0101db1:	68 d1 76 10 f0       	push   $0xf01076d1
f0101db6:	68 fb 74 10 f0       	push   $0xf01074fb
f0101dbb:	68 cc 04 00 00       	push   $0x4cc
f0101dc0:	68 c4 74 10 f0       	push   $0xf01074c4
f0101dc5:	e8 a0 e2 ff ff       	call   f010006a <_panic>
	assert(*(uint32_t *) page2kva(pp2) == 0x03030303U);
f0101dca:	68 60 6e 10 f0       	push   $0xf0106e60
f0101dcf:	68 fb 74 10 f0       	push   $0xf01074fb
f0101dd4:	68 ce 04 00 00       	push   $0x4ce
f0101dd9:	68 c4 74 10 f0       	push   $0xf01074c4
f0101dde:	e8 87 e2 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 0);
f0101de3:	68 e2 76 10 f0       	push   $0xf01076e2
f0101de8:	68 fb 74 10 f0       	push   $0xf01074fb
f0101ded:	68 d0 04 00 00       	push   $0x4d0
f0101df2:	68 c4 74 10 f0       	push   $0xf01074c4
f0101df7:	e8 6e e2 ff ff       	call   f010006a <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101dfc:	68 8c 6e 10 f0       	push   $0xf0106e8c
f0101e01:	68 fb 74 10 f0       	push   $0xf01074fb
f0101e06:	68 d3 04 00 00       	push   $0x4d3
f0101e0b:	68 c4 74 10 f0       	push   $0xf01074c4
f0101e10:	e8 55 e2 ff ff       	call   f010006a <_panic>
	assert(pp0->pp_ref == 1);
f0101e15:	68 f3 76 10 f0       	push   $0xf01076f3
f0101e1a:	68 fb 74 10 f0       	push   $0xf01074fb
f0101e1f:	68 d5 04 00 00       	push   $0x4d5
f0101e24:	68 c4 74 10 f0       	push   $0xf01074c4
f0101e29:	e8 3c e2 ff ff       	call   f010006a <_panic>

f0101e2e <mmio_map_region>:
{
f0101e2e:	f3 0f 1e fb          	endbr32 
f0101e32:	55                   	push   %ebp
f0101e33:	89 e5                	mov    %esp,%ebp
f0101e35:	53                   	push   %ebx
f0101e36:	83 ec 04             	sub    $0x4,%esp
	size = ROUNDUP(size, PGSIZE);
f0101e39:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101e3c:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101e42:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((base + size) > MMIOLIM) {
f0101e48:	8b 15 00 23 12 f0    	mov    0xf0122300,%edx
f0101e4e:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f0101e51:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101e56:	77 26                	ja     f0101e7e <mmio_map_region+0x50>
	boot_map_region(kern_pgdir, base, size, pa, PTE_W | PTE_PCD | PTE_PWT);
f0101e58:	83 ec 08             	sub    $0x8,%esp
f0101e5b:	6a 1a                	push   $0x1a
f0101e5d:	ff 75 08             	pushl  0x8(%ebp)
f0101e60:	89 d9                	mov    %ebx,%ecx
f0101e62:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0101e67:	e8 18 f8 ff ff       	call   f0101684 <boot_map_region>
	uintptr_t base_addr = base;
f0101e6c:	a1 00 23 12 f0       	mov    0xf0122300,%eax
	base += size;
f0101e71:	01 c3                	add    %eax,%ebx
f0101e73:	89 1d 00 23 12 f0    	mov    %ebx,0xf0122300
}
f0101e79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101e7c:	c9                   	leave  
f0101e7d:	c3                   	ret    
		panic("mmio_map_region overflows!");
f0101e7e:	83 ec 04             	sub    $0x4,%esp
f0101e81:	68 04 77 10 f0       	push   $0xf0107704
f0101e86:	68 bb 02 00 00       	push   $0x2bb
f0101e8b:	68 c4 74 10 f0       	push   $0xf01074c4
f0101e90:	e8 d5 e1 ff ff       	call   f010006a <_panic>

f0101e95 <check_page>:
{
f0101e95:	55                   	push   %ebp
f0101e96:	89 e5                	mov    %esp,%ebp
f0101e98:	57                   	push   %edi
f0101e99:	56                   	push   %esi
f0101e9a:	53                   	push   %ebx
f0101e9b:	83 ec 38             	sub    $0x38,%esp
	assert((pp0 = page_alloc(0)));
f0101e9e:	6a 00                	push   $0x0
f0101ea0:	e8 98 f2 ff ff       	call   f010113d <page_alloc>
f0101ea5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ea8:	83 c4 10             	add    $0x10,%esp
f0101eab:	85 c0                	test   %eax,%eax
f0101ead:	0f 84 71 07 00 00    	je     f0102624 <check_page+0x78f>
	assert((pp1 = page_alloc(0)));
f0101eb3:	83 ec 0c             	sub    $0xc,%esp
f0101eb6:	6a 00                	push   $0x0
f0101eb8:	e8 80 f2 ff ff       	call   f010113d <page_alloc>
f0101ebd:	89 c6                	mov    %eax,%esi
f0101ebf:	83 c4 10             	add    $0x10,%esp
f0101ec2:	85 c0                	test   %eax,%eax
f0101ec4:	0f 84 73 07 00 00    	je     f010263d <check_page+0x7a8>
	assert((pp2 = page_alloc(0)));
f0101eca:	83 ec 0c             	sub    $0xc,%esp
f0101ecd:	6a 00                	push   $0x0
f0101ecf:	e8 69 f2 ff ff       	call   f010113d <page_alloc>
f0101ed4:	89 c3                	mov    %eax,%ebx
f0101ed6:	83 c4 10             	add    $0x10,%esp
f0101ed9:	85 c0                	test   %eax,%eax
f0101edb:	0f 84 75 07 00 00    	je     f0102656 <check_page+0x7c1>
	assert(pp1 && pp1 != pp0);
f0101ee1:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0101ee4:	0f 84 85 07 00 00    	je     f010266f <check_page+0x7da>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101eea:	39 c6                	cmp    %eax,%esi
f0101eec:	0f 84 96 07 00 00    	je     f0102688 <check_page+0x7f3>
f0101ef2:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101ef5:	0f 84 8d 07 00 00    	je     f0102688 <check_page+0x7f3>
	fl = page_free_list;
f0101efb:	a1 40 12 22 f0       	mov    0xf0221240,%eax
f0101f00:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101f03:	c7 05 40 12 22 f0 00 	movl   $0x0,0xf0221240
f0101f0a:	00 00 00 
	assert(!page_alloc(0));
f0101f0d:	83 ec 0c             	sub    $0xc,%esp
f0101f10:	6a 00                	push   $0x0
f0101f12:	e8 26 f2 ff ff       	call   f010113d <page_alloc>
f0101f17:	83 c4 10             	add    $0x10,%esp
f0101f1a:	85 c0                	test   %eax,%eax
f0101f1c:	0f 85 7f 07 00 00    	jne    f01026a1 <check_page+0x80c>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101f22:	83 ec 04             	sub    $0x4,%esp
f0101f25:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101f28:	50                   	push   %eax
f0101f29:	6a 00                	push   $0x0
f0101f2b:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0101f31:	e8 13 fb ff ff       	call   f0101a49 <page_lookup>
f0101f36:	83 c4 10             	add    $0x10,%esp
f0101f39:	85 c0                	test   %eax,%eax
f0101f3b:	0f 85 79 07 00 00    	jne    f01026ba <check_page+0x825>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101f41:	6a 02                	push   $0x2
f0101f43:	6a 00                	push   $0x0
f0101f45:	56                   	push   %esi
f0101f46:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0101f4c:	e8 ca fb ff ff       	call   f0101b1b <page_insert>
f0101f51:	83 c4 10             	add    $0x10,%esp
f0101f54:	85 c0                	test   %eax,%eax
f0101f56:	0f 89 77 07 00 00    	jns    f01026d3 <check_page+0x83e>
	page_free(pp0);
f0101f5c:	83 ec 0c             	sub    $0xc,%esp
f0101f5f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f62:	e8 21 f2 ff ff       	call   f0101188 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101f67:	6a 02                	push   $0x2
f0101f69:	6a 00                	push   $0x0
f0101f6b:	56                   	push   %esi
f0101f6c:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0101f72:	e8 a4 fb ff ff       	call   f0101b1b <page_insert>
f0101f77:	83 c4 20             	add    $0x20,%esp
f0101f7a:	85 c0                	test   %eax,%eax
f0101f7c:	0f 85 6a 07 00 00    	jne    f01026ec <check_page+0x857>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f82:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f0101f88:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f8b:	e8 4e ec ff ff       	call   f0100bde <page2pa>
f0101f90:	89 c2                	mov    %eax,%edx
f0101f92:	8b 07                	mov    (%edi),%eax
f0101f94:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101f99:	39 d0                	cmp    %edx,%eax
f0101f9b:	0f 85 64 07 00 00    	jne    f0102705 <check_page+0x870>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101fa1:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fa6:	89 f8                	mov    %edi,%eax
f0101fa8:	e8 8b ed ff ff       	call   f0100d38 <check_va2pa>
f0101fad:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101fb0:	89 f0                	mov    %esi,%eax
f0101fb2:	e8 27 ec ff ff       	call   f0100bde <page2pa>
f0101fb7:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101fba:	0f 85 5e 07 00 00    	jne    f010271e <check_page+0x889>
	assert(pp1->pp_ref == 1);
f0101fc0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101fc5:	0f 85 6c 07 00 00    	jne    f0102737 <check_page+0x8a2>
	assert(pp0->pp_ref == 1);
f0101fcb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fce:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101fd3:	0f 85 77 07 00 00    	jne    f0102750 <check_page+0x8bb>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f0101fd9:	6a 02                	push   $0x2
f0101fdb:	68 00 10 00 00       	push   $0x1000
f0101fe0:	53                   	push   %ebx
f0101fe1:	57                   	push   %edi
f0101fe2:	e8 34 fb ff ff       	call   f0101b1b <page_insert>
f0101fe7:	83 c4 10             	add    $0x10,%esp
f0101fea:	85 c0                	test   %eax,%eax
f0101fec:	0f 85 77 07 00 00    	jne    f0102769 <check_page+0x8d4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ff2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ff7:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0101ffc:	e8 37 ed ff ff       	call   f0100d38 <check_va2pa>
f0102001:	89 c7                	mov    %eax,%edi
f0102003:	89 d8                	mov    %ebx,%eax
f0102005:	e8 d4 eb ff ff       	call   f0100bde <page2pa>
f010200a:	39 c7                	cmp    %eax,%edi
f010200c:	0f 85 70 07 00 00    	jne    f0102782 <check_page+0x8ed>
	assert(pp2->pp_ref == 1);
f0102012:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102017:	0f 85 7e 07 00 00    	jne    f010279b <check_page+0x906>
	assert(!page_alloc(0));
f010201d:	83 ec 0c             	sub    $0xc,%esp
f0102020:	6a 00                	push   $0x0
f0102022:	e8 16 f1 ff ff       	call   f010113d <page_alloc>
f0102027:	83 c4 10             	add    $0x10,%esp
f010202a:	85 c0                	test   %eax,%eax
f010202c:	0f 85 82 07 00 00    	jne    f01027b4 <check_page+0x91f>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f0102032:	6a 02                	push   $0x2
f0102034:	68 00 10 00 00       	push   $0x1000
f0102039:	53                   	push   %ebx
f010203a:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0102040:	e8 d6 fa ff ff       	call   f0101b1b <page_insert>
f0102045:	83 c4 10             	add    $0x10,%esp
f0102048:	85 c0                	test   %eax,%eax
f010204a:	0f 85 7d 07 00 00    	jne    f01027cd <check_page+0x938>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102050:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102055:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f010205a:	e8 d9 ec ff ff       	call   f0100d38 <check_va2pa>
f010205f:	89 c7                	mov    %eax,%edi
f0102061:	89 d8                	mov    %ebx,%eax
f0102063:	e8 76 eb ff ff       	call   f0100bde <page2pa>
f0102068:	39 c7                	cmp    %eax,%edi
f010206a:	0f 85 76 07 00 00    	jne    f01027e6 <check_page+0x951>
	assert(pp2->pp_ref == 1);
f0102070:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102075:	0f 85 84 07 00 00    	jne    f01027ff <check_page+0x96a>
	assert(!page_alloc(0));
f010207b:	83 ec 0c             	sub    $0xc,%esp
f010207e:	6a 00                	push   $0x0
f0102080:	e8 b8 f0 ff ff       	call   f010113d <page_alloc>
f0102085:	83 c4 10             	add    $0x10,%esp
f0102088:	85 c0                	test   %eax,%eax
f010208a:	0f 85 88 07 00 00    	jne    f0102818 <check_page+0x983>
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102090:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f0102096:	8b 0f                	mov    (%edi),%ecx
f0102098:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010209e:	ba 3e 04 00 00       	mov    $0x43e,%edx
f01020a3:	b8 c4 74 10 f0       	mov    $0xf01074c4,%eax
f01020a8:	e8 41 ec ff ff       	call   f0100cee <_kaddr>
f01020ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) == ptep + PTX(PGSIZE));
f01020b0:	83 ec 04             	sub    $0x4,%esp
f01020b3:	6a 00                	push   $0x0
f01020b5:	68 00 10 00 00       	push   $0x1000
f01020ba:	57                   	push   %edi
f01020bb:	e8 53 f5 ff ff       	call   f0101613 <pgdir_walk>
f01020c0:	89 c2                	mov    %eax,%edx
f01020c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01020c5:	83 c0 04             	add    $0x4,%eax
f01020c8:	83 c4 10             	add    $0x10,%esp
f01020cb:	39 d0                	cmp    %edx,%eax
f01020cd:	0f 85 5e 07 00 00    	jne    f0102831 <check_page+0x99c>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W | PTE_U) == 0);
f01020d3:	6a 06                	push   $0x6
f01020d5:	68 00 10 00 00       	push   $0x1000
f01020da:	53                   	push   %ebx
f01020db:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f01020e1:	e8 35 fa ff ff       	call   f0101b1b <page_insert>
f01020e6:	83 c4 10             	add    $0x10,%esp
f01020e9:	85 c0                	test   %eax,%eax
f01020eb:	0f 85 59 07 00 00    	jne    f010284a <check_page+0x9b5>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020f1:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f01020f7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020fc:	89 f8                	mov    %edi,%eax
f01020fe:	e8 35 ec ff ff       	call   f0100d38 <check_va2pa>
f0102103:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102106:	89 d8                	mov    %ebx,%eax
f0102108:	e8 d1 ea ff ff       	call   f0100bde <page2pa>
f010210d:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102110:	0f 85 4d 07 00 00    	jne    f0102863 <check_page+0x9ce>
	assert(pp2->pp_ref == 1);
f0102116:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010211b:	0f 85 5b 07 00 00    	jne    f010287c <check_page+0x9e7>
	assert(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U);
f0102121:	83 ec 04             	sub    $0x4,%esp
f0102124:	6a 00                	push   $0x0
f0102126:	68 00 10 00 00       	push   $0x1000
f010212b:	57                   	push   %edi
f010212c:	e8 e2 f4 ff ff       	call   f0101613 <pgdir_walk>
f0102131:	83 c4 10             	add    $0x10,%esp
f0102134:	f6 00 04             	testb  $0x4,(%eax)
f0102137:	0f 84 58 07 00 00    	je     f0102895 <check_page+0xa00>
	assert(kern_pgdir[0] & PTE_U);
f010213d:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102142:	f6 00 04             	testb  $0x4,(%eax)
f0102145:	0f 84 63 07 00 00    	je     f01028ae <check_page+0xa19>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f010214b:	6a 02                	push   $0x2
f010214d:	68 00 10 00 00       	push   $0x1000
f0102152:	53                   	push   %ebx
f0102153:	50                   	push   %eax
f0102154:	e8 c2 f9 ff ff       	call   f0101b1b <page_insert>
f0102159:	83 c4 10             	add    $0x10,%esp
f010215c:	85 c0                	test   %eax,%eax
f010215e:	0f 85 63 07 00 00    	jne    f01028c7 <check_page+0xa32>
	assert(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_W);
f0102164:	83 ec 04             	sub    $0x4,%esp
f0102167:	6a 00                	push   $0x0
f0102169:	68 00 10 00 00       	push   $0x1000
f010216e:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0102174:	e8 9a f4 ff ff       	call   f0101613 <pgdir_walk>
f0102179:	83 c4 10             	add    $0x10,%esp
f010217c:	f6 00 02             	testb  $0x2,(%eax)
f010217f:	0f 84 5b 07 00 00    	je     f01028e0 <check_page+0xa4b>
	assert(!(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U));
f0102185:	83 ec 04             	sub    $0x4,%esp
f0102188:	6a 00                	push   $0x0
f010218a:	68 00 10 00 00       	push   $0x1000
f010218f:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0102195:	e8 79 f4 ff ff       	call   f0101613 <pgdir_walk>
f010219a:	83 c4 10             	add    $0x10,%esp
f010219d:	f6 00 04             	testb  $0x4,(%eax)
f01021a0:	0f 85 53 07 00 00    	jne    f01028f9 <check_page+0xa64>
	assert(page_insert(kern_pgdir, pp0, (void *) PTSIZE, PTE_W) < 0);
f01021a6:	6a 02                	push   $0x2
f01021a8:	68 00 00 40 00       	push   $0x400000
f01021ad:	ff 75 d4             	pushl  -0x2c(%ebp)
f01021b0:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f01021b6:	e8 60 f9 ff ff       	call   f0101b1b <page_insert>
f01021bb:	83 c4 10             	add    $0x10,%esp
f01021be:	85 c0                	test   %eax,%eax
f01021c0:	0f 89 4c 07 00 00    	jns    f0102912 <check_page+0xa7d>
	assert(page_insert(kern_pgdir, pp1, (void *) PGSIZE, PTE_W) == 0);
f01021c6:	6a 02                	push   $0x2
f01021c8:	68 00 10 00 00       	push   $0x1000
f01021cd:	56                   	push   %esi
f01021ce:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f01021d4:	e8 42 f9 ff ff       	call   f0101b1b <page_insert>
f01021d9:	83 c4 10             	add    $0x10,%esp
f01021dc:	85 c0                	test   %eax,%eax
f01021de:	0f 85 47 07 00 00    	jne    f010292b <check_page+0xa96>
	assert(!(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U));
f01021e4:	83 ec 04             	sub    $0x4,%esp
f01021e7:	6a 00                	push   $0x0
f01021e9:	68 00 10 00 00       	push   $0x1000
f01021ee:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f01021f4:	e8 1a f4 ff ff       	call   f0101613 <pgdir_walk>
f01021f9:	83 c4 10             	add    $0x10,%esp
f01021fc:	f6 00 04             	testb  $0x4,(%eax)
f01021ff:	0f 85 3f 07 00 00    	jne    f0102944 <check_page+0xaaf>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102205:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f010220b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102210:	89 f8                	mov    %edi,%eax
f0102212:	e8 21 eb ff ff       	call   f0100d38 <check_va2pa>
f0102217:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010221a:	89 f0                	mov    %esi,%eax
f010221c:	e8 bd e9 ff ff       	call   f0100bde <page2pa>
f0102221:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102224:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102227:	0f 85 30 07 00 00    	jne    f010295d <check_page+0xac8>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010222d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102232:	89 f8                	mov    %edi,%eax
f0102234:	e8 ff ea ff ff       	call   f0100d38 <check_va2pa>
f0102239:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010223c:	0f 85 34 07 00 00    	jne    f0102976 <check_page+0xae1>
	assert(pp1->pp_ref == 2);
f0102242:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102247:	0f 85 42 07 00 00    	jne    f010298f <check_page+0xafa>
	assert(pp2->pp_ref == 0);
f010224d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102252:	0f 85 50 07 00 00    	jne    f01029a8 <check_page+0xb13>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102258:	83 ec 0c             	sub    $0xc,%esp
f010225b:	6a 00                	push   $0x0
f010225d:	e8 db ee ff ff       	call   f010113d <page_alloc>
f0102262:	83 c4 10             	add    $0x10,%esp
f0102265:	39 c3                	cmp    %eax,%ebx
f0102267:	0f 85 54 07 00 00    	jne    f01029c1 <check_page+0xb2c>
f010226d:	85 c0                	test   %eax,%eax
f010226f:	0f 84 4c 07 00 00    	je     f01029c1 <check_page+0xb2c>
	page_remove(kern_pgdir, 0x0);
f0102275:	83 ec 08             	sub    $0x8,%esp
f0102278:	6a 00                	push   $0x0
f010227a:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0102280:	e8 44 f8 ff ff       	call   f0101ac9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102285:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f010228b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102290:	89 f8                	mov    %edi,%eax
f0102292:	e8 a1 ea ff ff       	call   f0100d38 <check_va2pa>
f0102297:	83 c4 10             	add    $0x10,%esp
f010229a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010229d:	0f 85 37 07 00 00    	jne    f01029da <check_page+0xb45>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022a3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022a8:	89 f8                	mov    %edi,%eax
f01022aa:	e8 89 ea ff ff       	call   f0100d38 <check_va2pa>
f01022af:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01022b2:	89 f0                	mov    %esi,%eax
f01022b4:	e8 25 e9 ff ff       	call   f0100bde <page2pa>
f01022b9:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01022bc:	0f 85 31 07 00 00    	jne    f01029f3 <check_page+0xb5e>
	assert(pp1->pp_ref == 1);
f01022c2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01022c7:	0f 85 3f 07 00 00    	jne    f0102a0c <check_page+0xb77>
	assert(pp2->pp_ref == 0);
f01022cd:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022d2:	0f 85 4d 07 00 00    	jne    f0102a25 <check_page+0xb90>
	assert(page_insert(kern_pgdir, pp1, (void *) PGSIZE, 0) == 0);
f01022d8:	6a 00                	push   $0x0
f01022da:	68 00 10 00 00       	push   $0x1000
f01022df:	56                   	push   %esi
f01022e0:	57                   	push   %edi
f01022e1:	e8 35 f8 ff ff       	call   f0101b1b <page_insert>
f01022e6:	83 c4 10             	add    $0x10,%esp
f01022e9:	85 c0                	test   %eax,%eax
f01022eb:	0f 85 4d 07 00 00    	jne    f0102a3e <check_page+0xba9>
	assert(pp1->pp_ref);
f01022f1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022f6:	0f 84 5b 07 00 00    	je     f0102a57 <check_page+0xbc2>
	assert(pp1->pp_link == NULL);
f01022fc:	83 3e 00             	cmpl   $0x0,(%esi)
f01022ff:	0f 85 6b 07 00 00    	jne    f0102a70 <check_page+0xbdb>
	page_remove(kern_pgdir, (void *) PGSIZE);
f0102305:	83 ec 08             	sub    $0x8,%esp
f0102308:	68 00 10 00 00       	push   $0x1000
f010230d:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0102313:	e8 b1 f7 ff ff       	call   f0101ac9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102318:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f010231e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102323:	89 f8                	mov    %edi,%eax
f0102325:	e8 0e ea ff ff       	call   f0100d38 <check_va2pa>
f010232a:	83 c4 10             	add    $0x10,%esp
f010232d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102330:	0f 85 53 07 00 00    	jne    f0102a89 <check_page+0xbf4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102336:	ba 00 10 00 00       	mov    $0x1000,%edx
f010233b:	89 f8                	mov    %edi,%eax
f010233d:	e8 f6 e9 ff ff       	call   f0100d38 <check_va2pa>
f0102342:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102345:	0f 85 57 07 00 00    	jne    f0102aa2 <check_page+0xc0d>
	assert(pp1->pp_ref == 0);
f010234b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102350:	0f 85 65 07 00 00    	jne    f0102abb <check_page+0xc26>
	assert(pp2->pp_ref == 0);
f0102356:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010235b:	0f 85 73 07 00 00    	jne    f0102ad4 <check_page+0xc3f>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102361:	83 ec 0c             	sub    $0xc,%esp
f0102364:	6a 00                	push   $0x0
f0102366:	e8 d2 ed ff ff       	call   f010113d <page_alloc>
f010236b:	83 c4 10             	add    $0x10,%esp
f010236e:	39 c6                	cmp    %eax,%esi
f0102370:	0f 85 77 07 00 00    	jne    f0102aed <check_page+0xc58>
f0102376:	85 c0                	test   %eax,%eax
f0102378:	0f 84 6f 07 00 00    	je     f0102aed <check_page+0xc58>
	assert(!page_alloc(0));
f010237e:	83 ec 0c             	sub    $0xc,%esp
f0102381:	6a 00                	push   $0x0
f0102383:	e8 b5 ed ff ff       	call   f010113d <page_alloc>
f0102388:	83 c4 10             	add    $0x10,%esp
f010238b:	85 c0                	test   %eax,%eax
f010238d:	0f 85 73 07 00 00    	jne    f0102b06 <check_page+0xc71>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102393:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f0102399:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010239c:	e8 3d e8 ff ff       	call   f0100bde <page2pa>
f01023a1:	89 c2                	mov    %eax,%edx
f01023a3:	8b 07                	mov    (%edi),%eax
f01023a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01023aa:	39 d0                	cmp    %edx,%eax
f01023ac:	0f 85 6d 07 00 00    	jne    f0102b1f <check_page+0xc8a>
	kern_pgdir[0] = 0;
f01023b2:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	assert(pp0->pp_ref == 1);
f01023b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023bb:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01023c0:	0f 85 72 07 00 00    	jne    f0102b38 <check_page+0xca3>
	pp0->pp_ref = 0;
f01023c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023c9:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	page_free(pp0);
f01023cf:	83 ec 0c             	sub    $0xc,%esp
f01023d2:	50                   	push   %eax
f01023d3:	e8 b0 ed ff ff       	call   f0101188 <page_free>
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01023d8:	83 c4 0c             	add    $0xc,%esp
f01023db:	6a 01                	push   $0x1
f01023dd:	68 00 10 40 00       	push   $0x401000
f01023e2:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f01023e8:	e8 26 f2 ff ff       	call   f0101613 <pgdir_walk>
f01023ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01023f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01023f3:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f01023f9:	8b 4f 04             	mov    0x4(%edi),%ecx
f01023fc:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102402:	ba 82 04 00 00       	mov    $0x482,%edx
f0102407:	b8 c4 74 10 f0       	mov    $0xf01074c4,%eax
f010240c:	e8 dd e8 ff ff       	call   f0100cee <_kaddr>
	assert(ptep == ptep1 + PTX(va));
f0102411:	83 c0 04             	add    $0x4,%eax
f0102414:	83 c4 10             	add    $0x10,%esp
f0102417:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010241a:	0f 85 31 07 00 00    	jne    f0102b51 <check_page+0xcbc>
	kern_pgdir[PDX(va)] = 0;
f0102420:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	pp0->pp_ref = 0;
f0102427:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010242a:	89 f8                	mov    %edi,%eax
f010242c:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102432:	e8 e3 e8 ff ff       	call   f0100d1a <page2kva>
f0102437:	83 ec 04             	sub    $0x4,%esp
f010243a:	68 00 10 00 00       	push   $0x1000
f010243f:	68 ff 00 00 00       	push   $0xff
f0102444:	50                   	push   %eax
f0102445:	e8 15 34 00 00       	call   f010585f <memset>
	page_free(pp0);
f010244a:	89 3c 24             	mov    %edi,(%esp)
f010244d:	e8 36 ed ff ff       	call   f0101188 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102452:	83 c4 0c             	add    $0xc,%esp
f0102455:	6a 01                	push   $0x1
f0102457:	6a 00                	push   $0x0
f0102459:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f010245f:	e8 af f1 ff ff       	call   f0101613 <pgdir_walk>
	ptep = (pte_t *) page2kva(pp0);
f0102464:	89 f8                	mov    %edi,%eax
f0102466:	e8 af e8 ff ff       	call   f0100d1a <page2kva>
f010246b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010246e:	89 c2                	mov    %eax,%edx
f0102470:	05 00 10 00 00       	add    $0x1000,%eax
f0102475:	83 c4 10             	add    $0x10,%esp
		assert((ptep[i] & PTE_P) == 0);
f0102478:	f6 02 01             	testb  $0x1,(%edx)
f010247b:	0f 85 e9 06 00 00    	jne    f0102b6a <check_page+0xcd5>
f0102481:	83 c2 04             	add    $0x4,%edx
	for (i = 0; i < NPTENTRIES; i++)
f0102484:	39 c2                	cmp    %eax,%edx
f0102486:	75 f0                	jne    f0102478 <check_page+0x5e3>
	kern_pgdir[0] = 0;
f0102488:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f010248d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102493:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102496:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	page_free_list = fl;
f010249c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010249f:	89 0d 40 12 22 f0    	mov    %ecx,0xf0221240
	page_free(pp0);
f01024a5:	83 ec 0c             	sub    $0xc,%esp
f01024a8:	50                   	push   %eax
f01024a9:	e8 da ec ff ff       	call   f0101188 <page_free>
	page_free(pp1);
f01024ae:	89 34 24             	mov    %esi,(%esp)
f01024b1:	e8 d2 ec ff ff       	call   f0101188 <page_free>
	page_free(pp2);
f01024b6:	89 1c 24             	mov    %ebx,(%esp)
f01024b9:	e8 ca ec ff ff       	call   f0101188 <page_free>
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01024be:	83 c4 08             	add    $0x8,%esp
f01024c1:	68 01 10 00 00       	push   $0x1001
f01024c6:	6a 00                	push   $0x0
f01024c8:	e8 61 f9 ff ff       	call   f0101e2e <mmio_map_region>
f01024cd:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01024cf:	83 c4 08             	add    $0x8,%esp
f01024d2:	68 00 10 00 00       	push   $0x1000
f01024d7:	6a 00                	push   $0x0
f01024d9:	e8 50 f9 ff ff       	call   f0101e2e <mmio_map_region>
f01024de:	89 c6                	mov    %eax,%esi
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01024e0:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01024e6:	83 c4 10             	add    $0x10,%esp
f01024e9:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01024ef:	0f 86 8e 06 00 00    	jbe    f0102b83 <check_page+0xcee>
f01024f5:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01024fa:	0f 87 83 06 00 00    	ja     f0102b83 <check_page+0xcee>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102500:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102506:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010250c:	0f 87 8a 06 00 00    	ja     f0102b9c <check_page+0xd07>
f0102512:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102518:	0f 86 7e 06 00 00    	jbe    f0102b9c <check_page+0xd07>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010251e:	89 da                	mov    %ebx,%edx
f0102520:	09 f2                	or     %esi,%edx
f0102522:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102528:	0f 85 87 06 00 00    	jne    f0102bb5 <check_page+0xd20>
	assert(mm1 + 8096 <= mm2);
f010252e:	39 f0                	cmp    %esi,%eax
f0102530:	0f 87 98 06 00 00    	ja     f0102bce <check_page+0xd39>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102536:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f010253c:	89 da                	mov    %ebx,%edx
f010253e:	89 f8                	mov    %edi,%eax
f0102540:	e8 f3 e7 ff ff       	call   f0100d38 <check_va2pa>
f0102545:	85 c0                	test   %eax,%eax
f0102547:	0f 85 9a 06 00 00    	jne    f0102be7 <check_page+0xd52>
	assert(check_va2pa(kern_pgdir, mm1 + PGSIZE) == PGSIZE);
f010254d:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102553:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102556:	89 c2                	mov    %eax,%edx
f0102558:	89 f8                	mov    %edi,%eax
f010255a:	e8 d9 e7 ff ff       	call   f0100d38 <check_va2pa>
f010255f:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102564:	0f 85 96 06 00 00    	jne    f0102c00 <check_page+0xd6b>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010256a:	89 f2                	mov    %esi,%edx
f010256c:	89 f8                	mov    %edi,%eax
f010256e:	e8 c5 e7 ff ff       	call   f0100d38 <check_va2pa>
f0102573:	85 c0                	test   %eax,%eax
f0102575:	0f 85 9e 06 00 00    	jne    f0102c19 <check_page+0xd84>
	assert(check_va2pa(kern_pgdir, mm2 + PGSIZE) == ~0);
f010257b:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102581:	89 f8                	mov    %edi,%eax
f0102583:	e8 b0 e7 ff ff       	call   f0100d38 <check_va2pa>
f0102588:	83 f8 ff             	cmp    $0xffffffff,%eax
f010258b:	0f 85 a1 06 00 00    	jne    f0102c32 <check_page+0xd9d>
	assert(*pgdir_walk(kern_pgdir, (void *) mm1, 0) &
f0102591:	83 ec 04             	sub    $0x4,%esp
f0102594:	6a 00                	push   $0x0
f0102596:	53                   	push   %ebx
f0102597:	57                   	push   %edi
f0102598:	e8 76 f0 ff ff       	call   f0101613 <pgdir_walk>
f010259d:	83 c4 10             	add    $0x10,%esp
f01025a0:	f6 00 1a             	testb  $0x1a,(%eax)
f01025a3:	0f 84 a2 06 00 00    	je     f0102c4b <check_page+0xdb6>
	assert(!(*pgdir_walk(kern_pgdir, (void *) mm1, 0) & PTE_U));
f01025a9:	83 ec 04             	sub    $0x4,%esp
f01025ac:	6a 00                	push   $0x0
f01025ae:	53                   	push   %ebx
f01025af:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f01025b5:	e8 59 f0 ff ff       	call   f0101613 <pgdir_walk>
f01025ba:	83 c4 10             	add    $0x10,%esp
f01025bd:	f6 00 04             	testb  $0x4,(%eax)
f01025c0:	0f 85 9e 06 00 00    	jne    f0102c64 <check_page+0xdcf>
	*pgdir_walk(kern_pgdir, (void *) mm1, 0) = 0;
f01025c6:	83 ec 04             	sub    $0x4,%esp
f01025c9:	6a 00                	push   $0x0
f01025cb:	53                   	push   %ebx
f01025cc:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f01025d2:	e8 3c f0 ff ff       	call   f0101613 <pgdir_walk>
f01025d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *) mm1 + PGSIZE, 0) = 0;
f01025dd:	83 c4 0c             	add    $0xc,%esp
f01025e0:	6a 00                	push   $0x0
f01025e2:	ff 75 d4             	pushl  -0x2c(%ebp)
f01025e5:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f01025eb:	e8 23 f0 ff ff       	call   f0101613 <pgdir_walk>
f01025f0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *) mm2, 0) = 0;
f01025f6:	83 c4 0c             	add    $0xc,%esp
f01025f9:	6a 00                	push   $0x0
f01025fb:	56                   	push   %esi
f01025fc:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0102602:	e8 0c f0 ff ff       	call   f0101613 <pgdir_walk>
f0102607:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	cprintf("check_page() succeeded!\n");
f010260d:	c7 04 24 a8 77 10 f0 	movl   $0xf01077a8,(%esp)
f0102614:	e8 f7 12 00 00       	call   f0103910 <cprintf>
}
f0102619:	83 c4 10             	add    $0x10,%esp
f010261c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010261f:	5b                   	pop    %ebx
f0102620:	5e                   	pop    %esi
f0102621:	5f                   	pop    %edi
f0102622:	5d                   	pop    %ebp
f0102623:	c3                   	ret    
	assert((pp0 = page_alloc(0)));
f0102624:	68 c3 75 10 f0       	push   $0xf01075c3
f0102629:	68 fb 74 10 f0       	push   $0xf01074fb
f010262e:	68 0e 04 00 00       	push   $0x40e
f0102633:	68 c4 74 10 f0       	push   $0xf01074c4
f0102638:	e8 2d da ff ff       	call   f010006a <_panic>
	assert((pp1 = page_alloc(0)));
f010263d:	68 d9 75 10 f0       	push   $0xf01075d9
f0102642:	68 fb 74 10 f0       	push   $0xf01074fb
f0102647:	68 0f 04 00 00       	push   $0x40f
f010264c:	68 c4 74 10 f0       	push   $0xf01074c4
f0102651:	e8 14 da ff ff       	call   f010006a <_panic>
	assert((pp2 = page_alloc(0)));
f0102656:	68 ef 75 10 f0       	push   $0xf01075ef
f010265b:	68 fb 74 10 f0       	push   $0xf01074fb
f0102660:	68 10 04 00 00       	push   $0x410
f0102665:	68 c4 74 10 f0       	push   $0xf01074c4
f010266a:	e8 fb d9 ff ff       	call   f010006a <_panic>
	assert(pp1 && pp1 != pp0);
f010266f:	68 05 76 10 f0       	push   $0xf0107605
f0102674:	68 fb 74 10 f0       	push   $0xf01074fb
f0102679:	68 13 04 00 00       	push   $0x413
f010267e:	68 c4 74 10 f0       	push   $0xf01074c4
f0102683:	e8 e2 d9 ff ff       	call   f010006a <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102688:	68 3c 6c 10 f0       	push   $0xf0106c3c
f010268d:	68 fb 74 10 f0       	push   $0xf01074fb
f0102692:	68 14 04 00 00       	push   $0x414
f0102697:	68 c4 74 10 f0       	push   $0xf01074c4
f010269c:	e8 c9 d9 ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f01026a1:	68 17 76 10 f0       	push   $0xf0107617
f01026a6:	68 fb 74 10 f0       	push   $0xf01074fb
f01026ab:	68 1b 04 00 00       	push   $0x41b
f01026b0:	68 c4 74 10 f0       	push   $0xf01074c4
f01026b5:	e8 b0 d9 ff ff       	call   f010006a <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01026ba:	68 e0 6e 10 f0       	push   $0xf0106ee0
f01026bf:	68 fb 74 10 f0       	push   $0xf01074fb
f01026c4:	68 1e 04 00 00       	push   $0x41e
f01026c9:	68 c4 74 10 f0       	push   $0xf01074c4
f01026ce:	e8 97 d9 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01026d3:	68 18 6f 10 f0       	push   $0xf0106f18
f01026d8:	68 fb 74 10 f0       	push   $0xf01074fb
f01026dd:	68 21 04 00 00       	push   $0x421
f01026e2:	68 c4 74 10 f0       	push   $0xf01074c4
f01026e7:	e8 7e d9 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01026ec:	68 48 6f 10 f0       	push   $0xf0106f48
f01026f1:	68 fb 74 10 f0       	push   $0xf01074fb
f01026f6:	68 25 04 00 00       	push   $0x425
f01026fb:	68 c4 74 10 f0       	push   $0xf01074c4
f0102700:	e8 65 d9 ff ff       	call   f010006a <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102705:	68 8c 6e 10 f0       	push   $0xf0106e8c
f010270a:	68 fb 74 10 f0       	push   $0xf01074fb
f010270f:	68 26 04 00 00       	push   $0x426
f0102714:	68 c4 74 10 f0       	push   $0xf01074c4
f0102719:	e8 4c d9 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010271e:	68 78 6f 10 f0       	push   $0xf0106f78
f0102723:	68 fb 74 10 f0       	push   $0xf01074fb
f0102728:	68 27 04 00 00       	push   $0x427
f010272d:	68 c4 74 10 f0       	push   $0xf01074c4
f0102732:	e8 33 d9 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 1);
f0102737:	68 af 76 10 f0       	push   $0xf01076af
f010273c:	68 fb 74 10 f0       	push   $0xf01074fb
f0102741:	68 28 04 00 00       	push   $0x428
f0102746:	68 c4 74 10 f0       	push   $0xf01074c4
f010274b:	e8 1a d9 ff ff       	call   f010006a <_panic>
	assert(pp0->pp_ref == 1);
f0102750:	68 f3 76 10 f0       	push   $0xf01076f3
f0102755:	68 fb 74 10 f0       	push   $0xf01074fb
f010275a:	68 29 04 00 00       	push   $0x429
f010275f:	68 c4 74 10 f0       	push   $0xf01074c4
f0102764:	e8 01 d9 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f0102769:	68 a8 6f 10 f0       	push   $0xf0106fa8
f010276e:	68 fb 74 10 f0       	push   $0xf01074fb
f0102773:	68 2d 04 00 00       	push   $0x42d
f0102778:	68 c4 74 10 f0       	push   $0xf01074c4
f010277d:	e8 e8 d8 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102782:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0102787:	68 fb 74 10 f0       	push   $0xf01074fb
f010278c:	68 2e 04 00 00       	push   $0x42e
f0102791:	68 c4 74 10 f0       	push   $0xf01074c4
f0102796:	e8 cf d8 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 1);
f010279b:	68 c0 76 10 f0       	push   $0xf01076c0
f01027a0:	68 fb 74 10 f0       	push   $0xf01074fb
f01027a5:	68 2f 04 00 00       	push   $0x42f
f01027aa:	68 c4 74 10 f0       	push   $0xf01074c4
f01027af:	e8 b6 d8 ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f01027b4:	68 17 76 10 f0       	push   $0xf0107617
f01027b9:	68 fb 74 10 f0       	push   $0xf01074fb
f01027be:	68 32 04 00 00       	push   $0x432
f01027c3:	68 c4 74 10 f0       	push   $0xf01074c4
f01027c8:	e8 9d d8 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f01027cd:	68 a8 6f 10 f0       	push   $0xf0106fa8
f01027d2:	68 fb 74 10 f0       	push   $0xf01074fb
f01027d7:	68 35 04 00 00       	push   $0x435
f01027dc:	68 c4 74 10 f0       	push   $0xf01074c4
f01027e1:	e8 84 d8 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01027e6:	68 e4 6f 10 f0       	push   $0xf0106fe4
f01027eb:	68 fb 74 10 f0       	push   $0xf01074fb
f01027f0:	68 36 04 00 00       	push   $0x436
f01027f5:	68 c4 74 10 f0       	push   $0xf01074c4
f01027fa:	e8 6b d8 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 1);
f01027ff:	68 c0 76 10 f0       	push   $0xf01076c0
f0102804:	68 fb 74 10 f0       	push   $0xf01074fb
f0102809:	68 37 04 00 00       	push   $0x437
f010280e:	68 c4 74 10 f0       	push   $0xf01074c4
f0102813:	e8 52 d8 ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f0102818:	68 17 76 10 f0       	push   $0xf0107617
f010281d:	68 fb 74 10 f0       	push   $0xf01074fb
f0102822:	68 3b 04 00 00       	push   $0x43b
f0102827:	68 c4 74 10 f0       	push   $0xf01074c4
f010282c:	e8 39 d8 ff ff       	call   f010006a <_panic>
	assert(pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) == ptep + PTX(PGSIZE));
f0102831:	68 14 70 10 f0       	push   $0xf0107014
f0102836:	68 fb 74 10 f0       	push   $0xf01074fb
f010283b:	68 3f 04 00 00       	push   $0x43f
f0102840:	68 c4 74 10 f0       	push   $0xf01074c4
f0102845:	e8 20 d8 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W | PTE_U) == 0);
f010284a:	68 58 70 10 f0       	push   $0xf0107058
f010284f:	68 fb 74 10 f0       	push   $0xf01074fb
f0102854:	68 42 04 00 00       	push   $0x442
f0102859:	68 c4 74 10 f0       	push   $0xf01074c4
f010285e:	e8 07 d8 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102863:	68 e4 6f 10 f0       	push   $0xf0106fe4
f0102868:	68 fb 74 10 f0       	push   $0xf01074fb
f010286d:	68 43 04 00 00       	push   $0x443
f0102872:	68 c4 74 10 f0       	push   $0xf01074c4
f0102877:	e8 ee d7 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 1);
f010287c:	68 c0 76 10 f0       	push   $0xf01076c0
f0102881:	68 fb 74 10 f0       	push   $0xf01074fb
f0102886:	68 44 04 00 00       	push   $0x444
f010288b:	68 c4 74 10 f0       	push   $0xf01074c4
f0102890:	e8 d5 d7 ff ff       	call   f010006a <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U);
f0102895:	68 9c 70 10 f0       	push   $0xf010709c
f010289a:	68 fb 74 10 f0       	push   $0xf01074fb
f010289f:	68 45 04 00 00       	push   $0x445
f01028a4:	68 c4 74 10 f0       	push   $0xf01074c4
f01028a9:	e8 bc d7 ff ff       	call   f010006a <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01028ae:	68 1f 77 10 f0       	push   $0xf010771f
f01028b3:	68 fb 74 10 f0       	push   $0xf01074fb
f01028b8:	68 46 04 00 00       	push   $0x446
f01028bd:	68 c4 74 10 f0       	push   $0xf01074c4
f01028c2:	e8 a3 d7 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *) PGSIZE, PTE_W) == 0);
f01028c7:	68 a8 6f 10 f0       	push   $0xf0106fa8
f01028cc:	68 fb 74 10 f0       	push   $0xf01074fb
f01028d1:	68 49 04 00 00       	push   $0x449
f01028d6:	68 c4 74 10 f0       	push   $0xf01074c4
f01028db:	e8 8a d7 ff ff       	call   f010006a <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_W);
f01028e0:	68 d0 70 10 f0       	push   $0xf01070d0
f01028e5:	68 fb 74 10 f0       	push   $0xf01074fb
f01028ea:	68 4a 04 00 00       	push   $0x44a
f01028ef:	68 c4 74 10 f0       	push   $0xf01074c4
f01028f4:	e8 71 d7 ff ff       	call   f010006a <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U));
f01028f9:	68 04 71 10 f0       	push   $0xf0107104
f01028fe:	68 fb 74 10 f0       	push   $0xf01074fb
f0102903:	68 4b 04 00 00       	push   $0x44b
f0102908:	68 c4 74 10 f0       	push   $0xf01074c4
f010290d:	e8 58 d7 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp0, (void *) PTSIZE, PTE_W) < 0);
f0102912:	68 3c 71 10 f0       	push   $0xf010713c
f0102917:	68 fb 74 10 f0       	push   $0xf01074fb
f010291c:	68 4f 04 00 00       	push   $0x44f
f0102921:	68 c4 74 10 f0       	push   $0xf01074c4
f0102926:	e8 3f d7 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp1, (void *) PGSIZE, PTE_W) == 0);
f010292b:	68 78 71 10 f0       	push   $0xf0107178
f0102930:	68 fb 74 10 f0       	push   $0xf01074fb
f0102935:	68 52 04 00 00       	push   $0x452
f010293a:	68 c4 74 10 f0       	push   $0xf01074c4
f010293f:	e8 26 d7 ff ff       	call   f010006a <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *) PGSIZE, 0) & PTE_U));
f0102944:	68 04 71 10 f0       	push   $0xf0107104
f0102949:	68 fb 74 10 f0       	push   $0xf01074fb
f010294e:	68 53 04 00 00       	push   $0x453
f0102953:	68 c4 74 10 f0       	push   $0xf01074c4
f0102958:	e8 0d d7 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010295d:	68 b4 71 10 f0       	push   $0xf01071b4
f0102962:	68 fb 74 10 f0       	push   $0xf01074fb
f0102967:	68 56 04 00 00       	push   $0x456
f010296c:	68 c4 74 10 f0       	push   $0xf01074c4
f0102971:	e8 f4 d6 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102976:	68 e0 71 10 f0       	push   $0xf01071e0
f010297b:	68 fb 74 10 f0       	push   $0xf01074fb
f0102980:	68 57 04 00 00       	push   $0x457
f0102985:	68 c4 74 10 f0       	push   $0xf01074c4
f010298a:	e8 db d6 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 2);
f010298f:	68 35 77 10 f0       	push   $0xf0107735
f0102994:	68 fb 74 10 f0       	push   $0xf01074fb
f0102999:	68 59 04 00 00       	push   $0x459
f010299e:	68 c4 74 10 f0       	push   $0xf01074c4
f01029a3:	e8 c2 d6 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 0);
f01029a8:	68 e2 76 10 f0       	push   $0xf01076e2
f01029ad:	68 fb 74 10 f0       	push   $0xf01074fb
f01029b2:	68 5a 04 00 00       	push   $0x45a
f01029b7:	68 c4 74 10 f0       	push   $0xf01074c4
f01029bc:	e8 a9 d6 ff ff       	call   f010006a <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01029c1:	68 10 72 10 f0       	push   $0xf0107210
f01029c6:	68 fb 74 10 f0       	push   $0xf01074fb
f01029cb:	68 5d 04 00 00       	push   $0x45d
f01029d0:	68 c4 74 10 f0       	push   $0xf01074c4
f01029d5:	e8 90 d6 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01029da:	68 34 72 10 f0       	push   $0xf0107234
f01029df:	68 fb 74 10 f0       	push   $0xf01074fb
f01029e4:	68 61 04 00 00       	push   $0x461
f01029e9:	68 c4 74 10 f0       	push   $0xf01074c4
f01029ee:	e8 77 d6 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01029f3:	68 e0 71 10 f0       	push   $0xf01071e0
f01029f8:	68 fb 74 10 f0       	push   $0xf01074fb
f01029fd:	68 62 04 00 00       	push   $0x462
f0102a02:	68 c4 74 10 f0       	push   $0xf01074c4
f0102a07:	e8 5e d6 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 1);
f0102a0c:	68 af 76 10 f0       	push   $0xf01076af
f0102a11:	68 fb 74 10 f0       	push   $0xf01074fb
f0102a16:	68 63 04 00 00       	push   $0x463
f0102a1b:	68 c4 74 10 f0       	push   $0xf01074c4
f0102a20:	e8 45 d6 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 0);
f0102a25:	68 e2 76 10 f0       	push   $0xf01076e2
f0102a2a:	68 fb 74 10 f0       	push   $0xf01074fb
f0102a2f:	68 64 04 00 00       	push   $0x464
f0102a34:	68 c4 74 10 f0       	push   $0xf01074c4
f0102a39:	e8 2c d6 ff ff       	call   f010006a <_panic>
	assert(page_insert(kern_pgdir, pp1, (void *) PGSIZE, 0) == 0);
f0102a3e:	68 58 72 10 f0       	push   $0xf0107258
f0102a43:	68 fb 74 10 f0       	push   $0xf01074fb
f0102a48:	68 67 04 00 00       	push   $0x467
f0102a4d:	68 c4 74 10 f0       	push   $0xf01074c4
f0102a52:	e8 13 d6 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref);
f0102a57:	68 46 77 10 f0       	push   $0xf0107746
f0102a5c:	68 fb 74 10 f0       	push   $0xf01074fb
f0102a61:	68 68 04 00 00       	push   $0x468
f0102a66:	68 c4 74 10 f0       	push   $0xf01074c4
f0102a6b:	e8 fa d5 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_link == NULL);
f0102a70:	68 52 77 10 f0       	push   $0xf0107752
f0102a75:	68 fb 74 10 f0       	push   $0xf01074fb
f0102a7a:	68 69 04 00 00       	push   $0x469
f0102a7f:	68 c4 74 10 f0       	push   $0xf01074c4
f0102a84:	e8 e1 d5 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102a89:	68 34 72 10 f0       	push   $0xf0107234
f0102a8e:	68 fb 74 10 f0       	push   $0xf01074fb
f0102a93:	68 6d 04 00 00       	push   $0x46d
f0102a98:	68 c4 74 10 f0       	push   $0xf01074c4
f0102a9d:	e8 c8 d5 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102aa2:	68 90 72 10 f0       	push   $0xf0107290
f0102aa7:	68 fb 74 10 f0       	push   $0xf01074fb
f0102aac:	68 6e 04 00 00       	push   $0x46e
f0102ab1:	68 c4 74 10 f0       	push   $0xf01074c4
f0102ab6:	e8 af d5 ff ff       	call   f010006a <_panic>
	assert(pp1->pp_ref == 0);
f0102abb:	68 d1 76 10 f0       	push   $0xf01076d1
f0102ac0:	68 fb 74 10 f0       	push   $0xf01074fb
f0102ac5:	68 6f 04 00 00       	push   $0x46f
f0102aca:	68 c4 74 10 f0       	push   $0xf01074c4
f0102acf:	e8 96 d5 ff ff       	call   f010006a <_panic>
	assert(pp2->pp_ref == 0);
f0102ad4:	68 e2 76 10 f0       	push   $0xf01076e2
f0102ad9:	68 fb 74 10 f0       	push   $0xf01074fb
f0102ade:	68 70 04 00 00       	push   $0x470
f0102ae3:	68 c4 74 10 f0       	push   $0xf01074c4
f0102ae8:	e8 7d d5 ff ff       	call   f010006a <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102aed:	68 b8 72 10 f0       	push   $0xf01072b8
f0102af2:	68 fb 74 10 f0       	push   $0xf01074fb
f0102af7:	68 73 04 00 00       	push   $0x473
f0102afc:	68 c4 74 10 f0       	push   $0xf01074c4
f0102b01:	e8 64 d5 ff ff       	call   f010006a <_panic>
	assert(!page_alloc(0));
f0102b06:	68 17 76 10 f0       	push   $0xf0107617
f0102b0b:	68 fb 74 10 f0       	push   $0xf01074fb
f0102b10:	68 76 04 00 00       	push   $0x476
f0102b15:	68 c4 74 10 f0       	push   $0xf01074c4
f0102b1a:	e8 4b d5 ff ff       	call   f010006a <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b1f:	68 8c 6e 10 f0       	push   $0xf0106e8c
f0102b24:	68 fb 74 10 f0       	push   $0xf01074fb
f0102b29:	68 79 04 00 00       	push   $0x479
f0102b2e:	68 c4 74 10 f0       	push   $0xf01074c4
f0102b33:	e8 32 d5 ff ff       	call   f010006a <_panic>
	assert(pp0->pp_ref == 1);
f0102b38:	68 f3 76 10 f0       	push   $0xf01076f3
f0102b3d:	68 fb 74 10 f0       	push   $0xf01074fb
f0102b42:	68 7b 04 00 00       	push   $0x47b
f0102b47:	68 c4 74 10 f0       	push   $0xf01074c4
f0102b4c:	e8 19 d5 ff ff       	call   f010006a <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102b51:	68 67 77 10 f0       	push   $0xf0107767
f0102b56:	68 fb 74 10 f0       	push   $0xf01074fb
f0102b5b:	68 83 04 00 00       	push   $0x483
f0102b60:	68 c4 74 10 f0       	push   $0xf01074c4
f0102b65:	e8 00 d5 ff ff       	call   f010006a <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102b6a:	68 7f 77 10 f0       	push   $0xf010777f
f0102b6f:	68 fb 74 10 f0       	push   $0xf01074fb
f0102b74:	68 8d 04 00 00       	push   $0x48d
f0102b79:	68 c4 74 10 f0       	push   $0xf01074c4
f0102b7e:	e8 e7 d4 ff ff       	call   f010006a <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102b83:	68 dc 72 10 f0       	push   $0xf01072dc
f0102b88:	68 fb 74 10 f0       	push   $0xf01074fb
f0102b8d:	68 9d 04 00 00       	push   $0x49d
f0102b92:	68 c4 74 10 f0       	push   $0xf01074c4
f0102b97:	e8 ce d4 ff ff       	call   f010006a <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102b9c:	68 04 73 10 f0       	push   $0xf0107304
f0102ba1:	68 fb 74 10 f0       	push   $0xf01074fb
f0102ba6:	68 9e 04 00 00       	push   $0x49e
f0102bab:	68 c4 74 10 f0       	push   $0xf01074c4
f0102bb0:	e8 b5 d4 ff ff       	call   f010006a <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102bb5:	68 2c 73 10 f0       	push   $0xf010732c
f0102bba:	68 fb 74 10 f0       	push   $0xf01074fb
f0102bbf:	68 a0 04 00 00       	push   $0x4a0
f0102bc4:	68 c4 74 10 f0       	push   $0xf01074c4
f0102bc9:	e8 9c d4 ff ff       	call   f010006a <_panic>
	assert(mm1 + 8096 <= mm2);
f0102bce:	68 96 77 10 f0       	push   $0xf0107796
f0102bd3:	68 fb 74 10 f0       	push   $0xf01074fb
f0102bd8:	68 a2 04 00 00       	push   $0x4a2
f0102bdd:	68 c4 74 10 f0       	push   $0xf01074c4
f0102be2:	e8 83 d4 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102be7:	68 54 73 10 f0       	push   $0xf0107354
f0102bec:	68 fb 74 10 f0       	push   $0xf01074fb
f0102bf1:	68 a4 04 00 00       	push   $0x4a4
f0102bf6:	68 c4 74 10 f0       	push   $0xf01074c4
f0102bfb:	e8 6a d4 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, mm1 + PGSIZE) == PGSIZE);
f0102c00:	68 78 73 10 f0       	push   $0xf0107378
f0102c05:	68 fb 74 10 f0       	push   $0xf01074fb
f0102c0a:	68 a5 04 00 00       	push   $0x4a5
f0102c0f:	68 c4 74 10 f0       	push   $0xf01074c4
f0102c14:	e8 51 d4 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102c19:	68 a8 73 10 f0       	push   $0xf01073a8
f0102c1e:	68 fb 74 10 f0       	push   $0xf01074fb
f0102c23:	68 a6 04 00 00       	push   $0x4a6
f0102c28:	68 c4 74 10 f0       	push   $0xf01074c4
f0102c2d:	e8 38 d4 ff ff       	call   f010006a <_panic>
	assert(check_va2pa(kern_pgdir, mm2 + PGSIZE) == ~0);
f0102c32:	68 cc 73 10 f0       	push   $0xf01073cc
f0102c37:	68 fb 74 10 f0       	push   $0xf01074fb
f0102c3c:	68 a7 04 00 00       	push   $0x4a7
f0102c41:	68 c4 74 10 f0       	push   $0xf01074c4
f0102c46:	e8 1f d4 ff ff       	call   f010006a <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *) mm1, 0) &
f0102c4b:	68 f8 73 10 f0       	push   $0xf01073f8
f0102c50:	68 fb 74 10 f0       	push   $0xf01074fb
f0102c55:	68 a9 04 00 00       	push   $0x4a9
f0102c5a:	68 c4 74 10 f0       	push   $0xf01074c4
f0102c5f:	e8 06 d4 ff ff       	call   f010006a <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *) mm1, 0) & PTE_U));
f0102c64:	68 40 74 10 f0       	push   $0xf0107440
f0102c69:	68 fb 74 10 f0       	push   $0xf01074fb
f0102c6e:	68 ab 04 00 00       	push   $0x4ab
f0102c73:	68 c4 74 10 f0       	push   $0xf01074c4
f0102c78:	e8 ed d3 ff ff       	call   f010006a <_panic>

f0102c7d <mem_init>:
{
f0102c7d:	f3 0f 1e fb          	endbr32 
f0102c81:	55                   	push   %ebp
f0102c82:	89 e5                	mov    %esp,%ebp
f0102c84:	53                   	push   %ebx
f0102c85:	83 ec 04             	sub    $0x4,%esp
	i386_detect_memory();
f0102c88:	e8 87 df ff ff       	call   f0100c14 <i386_detect_memory>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0102c8d:	b8 00 10 00 00       	mov    $0x1000,%eax
f0102c92:	e8 e1 df ff ff       	call   f0100c78 <boot_alloc>
f0102c97:	a3 8c 2e 22 f0       	mov    %eax,0xf0222e8c
	memset(kern_pgdir, 0, PGSIZE);
f0102c9c:	83 ec 04             	sub    $0x4,%esp
f0102c9f:	68 00 10 00 00       	push   $0x1000
f0102ca4:	6a 00                	push   $0x0
f0102ca6:	50                   	push   %eax
f0102ca7:	e8 b3 2b 00 00       	call   f010585f <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0102cac:	8b 1d 8c 2e 22 f0    	mov    0xf0222e8c,%ebx
f0102cb2:	89 d9                	mov    %ebx,%ecx
f0102cb4:	ba a1 00 00 00       	mov    $0xa1,%edx
f0102cb9:	b8 c4 74 10 f0       	mov    $0xf01074c4,%eax
f0102cbe:	e8 dd e0 ff ff       	call   f0100da0 <_paddr>
f0102cc3:	83 c8 05             	or     $0x5,%eax
f0102cc6:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
	pages = boot_alloc(sizeof(struct PageInfo) * npages);
f0102ccc:	a1 88 2e 22 f0       	mov    0xf0222e88,%eax
f0102cd1:	c1 e0 03             	shl    $0x3,%eax
f0102cd4:	e8 9f df ff ff       	call   f0100c78 <boot_alloc>
f0102cd9:	a3 90 2e 22 f0       	mov    %eax,0xf0222e90
	memset(pages, 0, (sizeof(struct PageInfo) * npages));
f0102cde:	83 c4 0c             	add    $0xc,%esp
f0102ce1:	8b 1d 88 2e 22 f0    	mov    0xf0222e88,%ebx
f0102ce7:	8d 14 dd 00 00 00 00 	lea    0x0(,%ebx,8),%edx
f0102cee:	52                   	push   %edx
f0102cef:	6a 00                	push   $0x0
f0102cf1:	50                   	push   %eax
f0102cf2:	e8 68 2b 00 00       	call   f010585f <memset>
	envs = boot_alloc(sizeof(struct Env) * NENV);
f0102cf7:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0102cfc:	e8 77 df ff ff       	call   f0100c78 <boot_alloc>
f0102d01:	a3 44 12 22 f0       	mov    %eax,0xf0221244
	memset(envs, 0, (sizeof(struct Env) * NENV));
f0102d06:	83 c4 0c             	add    $0xc,%esp
f0102d09:	68 00 f0 01 00       	push   $0x1f000
f0102d0e:	6a 00                	push   $0x0
f0102d10:	50                   	push   %eax
f0102d11:	e8 49 2b 00 00       	call   f010585f <memset>
	page_init();
f0102d16:	e8 86 e3 ff ff       	call   f01010a1 <page_init>
	check_page_free_list(1);
f0102d1b:	b8 01 00 00 00       	mov    $0x1,%eax
f0102d20:	e8 9d e0 ff ff       	call   f0100dc2 <check_page_free_list>
	check_page_alloc();
f0102d25:	e8 9d e4 ff ff       	call   f01011c7 <check_page_alloc>
	check_page();
f0102d2a:	e8 66 f1 ff ff       	call   f0101e95 <check_page>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f0102d2f:	8b 0d 90 2e 22 f0    	mov    0xf0222e90,%ecx
f0102d35:	ba cc 00 00 00       	mov    $0xcc,%edx
f0102d3a:	b8 c4 74 10 f0       	mov    $0xf01074c4,%eax
f0102d3f:	e8 5c e0 ff ff       	call   f0100da0 <_paddr>
f0102d44:	83 c4 08             	add    $0x8,%esp
f0102d47:	6a 05                	push   $0x5
f0102d49:	50                   	push   %eax
f0102d4a:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102d4f:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102d54:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102d59:	e8 26 e9 ff ff       	call   f0101684 <boot_map_region>
	boot_map_region(kern_pgdir,
f0102d5e:	8b 0d 44 12 22 f0    	mov    0xf0221244,%ecx
f0102d64:	ba d8 00 00 00       	mov    $0xd8,%edx
f0102d69:	b8 c4 74 10 f0       	mov    $0xf01074c4,%eax
f0102d6e:	e8 2d e0 ff ff       	call   f0100da0 <_paddr>
f0102d73:	83 c4 08             	add    $0x8,%esp
f0102d76:	6a 05                	push   $0x5
f0102d78:	50                   	push   %eax
f0102d79:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102d7e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102d83:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102d88:	e8 f7 e8 ff ff       	call   f0101684 <boot_map_region>
	boot_map_region(kern_pgdir,
f0102d8d:	b9 00 90 11 f0       	mov    $0xf0119000,%ecx
f0102d92:	ba ea 00 00 00       	mov    $0xea,%edx
f0102d97:	b8 c4 74 10 f0       	mov    $0xf01074c4,%eax
f0102d9c:	e8 ff df ff ff       	call   f0100da0 <_paddr>
f0102da1:	83 c4 08             	add    $0x8,%esp
f0102da4:	6a 02                	push   $0x2
f0102da6:	50                   	push   %eax
f0102da7:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102dac:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102db1:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102db6:	e8 c9 e8 ff ff       	call   f0101684 <boot_map_region>
	boot_map_region(kern_pgdir,
f0102dbb:	83 c4 08             	add    $0x8,%esp
f0102dbe:	6a 02                	push   $0x2
f0102dc0:	6a 00                	push   $0x0
f0102dc2:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102dc7:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102dcc:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102dd1:	e8 ae e8 ff ff       	call   f0101684 <boot_map_region>
	mem_init_mp();
f0102dd6:	e8 14 e9 ff ff       	call   f01016ef <mem_init_mp>
	check_kern_pgdir();
f0102ddb:	e8 6a e9 ff ff       	call   f010174a <check_kern_pgdir>
	lcr3(PADDR(kern_pgdir));
f0102de0:	8b 0d 8c 2e 22 f0    	mov    0xf0222e8c,%ecx
f0102de6:	ba 08 01 00 00       	mov    $0x108,%edx
f0102deb:	b8 c4 74 10 f0       	mov    $0xf01074c4,%eax
f0102df0:	e8 ab df ff ff       	call   f0100da0 <_paddr>
f0102df5:	e8 e0 dd ff ff       	call   f0100bda <lcr3>
	check_page_free_list(0);
f0102dfa:	b8 00 00 00 00       	mov    $0x0,%eax
f0102dff:	e8 be df ff ff       	call   f0100dc2 <check_page_free_list>
	cr0 = rcr0();
f0102e04:	e8 cd dd ff ff       	call   f0100bd6 <rcr0>
f0102e09:	83 e0 f3             	and    $0xfffffff3,%eax
	cr0 &= ~(CR0_TS | CR0_EM);
f0102e0c:	0d 23 00 05 80       	or     $0x80050023,%eax
	lcr0(cr0);
f0102e11:	e8 bc dd ff ff       	call   f0100bd2 <lcr0>
	check_page_installed_pgdir();
f0102e16:	e8 65 ed ff ff       	call   f0101b80 <check_page_installed_pgdir>
}
f0102e1b:	83 c4 10             	add    $0x10,%esp
f0102e1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102e21:	c9                   	leave  
f0102e22:	c3                   	ret    

f0102e23 <user_mem_check>:
{
f0102e23:	f3 0f 1e fb          	endbr32 
f0102e27:	55                   	push   %ebp
f0102e28:	89 e5                	mov    %esp,%ebp
f0102e2a:	57                   	push   %edi
f0102e2b:	56                   	push   %esi
f0102e2c:	53                   	push   %ebx
f0102e2d:	83 ec 0c             	sub    $0xc,%esp
f0102e30:	8b 75 14             	mov    0x14(%ebp),%esi
	uintptr_t begin = ROUNDDOWN((uintptr_t) va, PGSIZE);
f0102e33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e36:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t end = ROUNDUP((uintptr_t) va + len, PGSIZE);
f0102e3c:	8b 45 10             	mov    0x10(%ebp),%eax
f0102e3f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102e42:	8d bc 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%edi
f0102e49:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	while (begin < end) {
f0102e4f:	eb 06                	jmp    f0102e57 <user_mem_check+0x34>
		begin += PGSIZE;
f0102e51:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	while (begin < end) {
f0102e57:	39 fb                	cmp    %edi,%ebx
f0102e59:	73 46                	jae    f0102ea1 <user_mem_check+0x7e>
		pte_t *page = pgdir_walk(env->env_pgdir, (void *) begin, 0);
f0102e5b:	83 ec 04             	sub    $0x4,%esp
f0102e5e:	6a 00                	push   $0x0
f0102e60:	53                   	push   %ebx
f0102e61:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e64:	ff 70 60             	pushl  0x60(%eax)
f0102e67:	e8 a7 e7 ff ff       	call   f0101613 <pgdir_walk>
		if (page == NULL || (*page & PTE_P) == 0 ||
f0102e6c:	83 c4 10             	add    $0x10,%esp
f0102e6f:	85 c0                	test   %eax,%eax
f0102e71:	74 14                	je     f0102e87 <user_mem_check+0x64>
f0102e73:	8b 00                	mov    (%eax),%eax
f0102e75:	a8 01                	test   $0x1,%al
f0102e77:	74 0e                	je     f0102e87 <user_mem_check+0x64>
		    (*page & perm) != perm || begin >= ULIM) {
f0102e79:	21 f0                	and    %esi,%eax
f0102e7b:	39 f0                	cmp    %esi,%eax
f0102e7d:	75 08                	jne    f0102e87 <user_mem_check+0x64>
f0102e7f:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102e85:	76 ca                	jbe    f0102e51 <user_mem_check+0x2e>
			user_mem_check_addr =
f0102e87:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102e8a:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102e8e:	89 1d 3c 12 22 f0    	mov    %ebx,0xf022123c
			return -E_FAULT;
f0102e94:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102e99:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e9c:	5b                   	pop    %ebx
f0102e9d:	5e                   	pop    %esi
f0102e9e:	5f                   	pop    %edi
f0102e9f:	5d                   	pop    %ebp
f0102ea0:	c3                   	ret    
	return 0;
f0102ea1:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ea6:	eb f1                	jmp    f0102e99 <user_mem_check+0x76>

f0102ea8 <user_mem_assert>:
{
f0102ea8:	f3 0f 1e fb          	endbr32 
f0102eac:	55                   	push   %ebp
f0102ead:	89 e5                	mov    %esp,%ebp
f0102eaf:	53                   	push   %ebx
f0102eb0:	83 ec 04             	sub    $0x4,%esp
f0102eb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102eb6:	8b 45 14             	mov    0x14(%ebp),%eax
f0102eb9:	83 c8 04             	or     $0x4,%eax
f0102ebc:	50                   	push   %eax
f0102ebd:	ff 75 10             	pushl  0x10(%ebp)
f0102ec0:	ff 75 0c             	pushl  0xc(%ebp)
f0102ec3:	53                   	push   %ebx
f0102ec4:	e8 5a ff ff ff       	call   f0102e23 <user_mem_check>
f0102ec9:	83 c4 10             	add    $0x10,%esp
f0102ecc:	85 c0                	test   %eax,%eax
f0102ece:	78 05                	js     f0102ed5 <user_mem_assert+0x2d>
}
f0102ed0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102ed3:	c9                   	leave  
f0102ed4:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0102ed5:	83 ec 04             	sub    $0x4,%esp
f0102ed8:	ff 35 3c 12 22 f0    	pushl  0xf022123c
f0102ede:	ff 73 48             	pushl  0x48(%ebx)
f0102ee1:	68 74 74 10 f0       	push   $0xf0107474
f0102ee6:	e8 25 0a 00 00       	call   f0103910 <cprintf>
		env_destroy(env);  // may not return
f0102eeb:	89 1c 24             	mov    %ebx,(%esp)
f0102eee:	e8 77 06 00 00       	call   f010356a <env_destroy>
f0102ef3:	83 c4 10             	add    $0x10,%esp
}
f0102ef6:	eb d8                	jmp    f0102ed0 <user_mem_assert+0x28>

f0102ef8 <lgdt>:
	asm volatile("lgdt (%0)" : : "r" (p));
f0102ef8:	0f 01 10             	lgdtl  (%eax)
}
f0102efb:	c3                   	ret    

f0102efc <lldt>:
	asm volatile("lldt %0" : : "r" (sel));
f0102efc:	0f 00 d0             	lldt   %ax
}
f0102eff:	c3                   	ret    

f0102f00 <lcr3>:
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102f00:	0f 22 d8             	mov    %eax,%cr3
}
f0102f03:	c3                   	ret    

f0102f04 <page2pa>:
	return (pp - pages) << PGSHIFT;
f0102f04:	2b 05 90 2e 22 f0    	sub    0xf0222e90,%eax
f0102f0a:	c1 f8 03             	sar    $0x3,%eax
f0102f0d:	c1 e0 0c             	shl    $0xc,%eax
}
f0102f10:	c3                   	ret    

f0102f11 <_kaddr>:
{
f0102f11:	55                   	push   %ebp
f0102f12:	89 e5                	mov    %esp,%ebp
f0102f14:	53                   	push   %ebx
f0102f15:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f0102f18:	89 cb                	mov    %ecx,%ebx
f0102f1a:	c1 eb 0c             	shr    $0xc,%ebx
f0102f1d:	3b 1d 88 2e 22 f0    	cmp    0xf0222e88,%ebx
f0102f23:	73 0b                	jae    f0102f30 <_kaddr+0x1f>
	return (void *)(pa + KERNBASE);
f0102f25:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f0102f2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f2e:	c9                   	leave  
f0102f2f:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f30:	51                   	push   %ecx
f0102f31:	68 cc 65 10 f0       	push   $0xf01065cc
f0102f36:	52                   	push   %edx
f0102f37:	50                   	push   %eax
f0102f38:	e8 2d d1 ff ff       	call   f010006a <_panic>

f0102f3d <page2kva>:
{
f0102f3d:	55                   	push   %ebp
f0102f3e:	89 e5                	mov    %esp,%ebp
f0102f40:	83 ec 08             	sub    $0x8,%esp
	return KADDR(page2pa(pp));
f0102f43:	e8 bc ff ff ff       	call   f0102f04 <page2pa>
f0102f48:	89 c1                	mov    %eax,%ecx
f0102f4a:	ba 58 00 00 00       	mov    $0x58,%edx
f0102f4f:	b8 e1 74 10 f0       	mov    $0xf01074e1,%eax
f0102f54:	e8 b8 ff ff ff       	call   f0102f11 <_kaddr>
}
f0102f59:	c9                   	leave  
f0102f5a:	c3                   	ret    

f0102f5b <_paddr>:
	if ((uint32_t)kva < KERNBASE)
f0102f5b:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0102f61:	76 07                	jbe    f0102f6a <_paddr+0xf>
	return (physaddr_t)kva - KERNBASE;
f0102f63:	8d 81 00 00 00 10    	lea    0x10000000(%ecx),%eax
}
f0102f69:	c3                   	ret    
{
f0102f6a:	55                   	push   %ebp
f0102f6b:	89 e5                	mov    %esp,%ebp
f0102f6d:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f70:	51                   	push   %ecx
f0102f71:	68 f0 65 10 f0       	push   $0xf01065f0
f0102f76:	52                   	push   %edx
f0102f77:	50                   	push   %eax
f0102f78:	e8 ed d0 ff ff       	call   f010006a <_panic>

f0102f7d <env_setup_vm>:
// Returns 0 on success, < 0 on error.  Errors include:
//	-E_NO_MEM if page directory or table could not be allocated.
//
static int
env_setup_vm(struct Env *e)
{
f0102f7d:	55                   	push   %ebp
f0102f7e:	89 e5                	mov    %esp,%ebp
f0102f80:	56                   	push   %esi
f0102f81:	53                   	push   %ebx
f0102f82:	89 c6                	mov    %eax,%esi
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102f84:	83 ec 0c             	sub    $0xc,%esp
f0102f87:	6a 01                	push   $0x1
f0102f89:	e8 af e1 ff ff       	call   f010113d <page_alloc>
f0102f8e:	83 c4 10             	add    $0x10,%esp
f0102f91:	85 c0                	test   %eax,%eax
f0102f93:	74 51                	je     f0102fe6 <env_setup_vm+0x69>
f0102f95:	89 c3                	mov    %eax,%ebx
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.

	e->env_pgdir = page2kva(p);
f0102f97:	e8 a1 ff ff ff       	call   f0102f3d <page2kva>
f0102f9c:	89 46 60             	mov    %eax,0x60(%esi)
	p->pp_ref++;
f0102f9f:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102fa4:	83 ec 04             	sub    $0x4,%esp
f0102fa7:	68 00 10 00 00       	push   $0x1000
f0102fac:	ff 35 8c 2e 22 f0    	pushl  0xf0222e8c
f0102fb2:	ff 76 60             	pushl  0x60(%esi)
f0102fb5:	e8 59 29 00 00       	call   f0105913 <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102fba:	8b 5e 60             	mov    0x60(%esi),%ebx
f0102fbd:	89 d9                	mov    %ebx,%ecx
f0102fbf:	ba c3 00 00 00       	mov    $0xc3,%edx
f0102fc4:	b8 e6 77 10 f0       	mov    $0xf01077e6,%eax
f0102fc9:	e8 8d ff ff ff       	call   f0102f5b <_paddr>
f0102fce:	83 c8 05             	or     $0x5,%eax
f0102fd1:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)

	return 0;
f0102fd7:	83 c4 10             	add    $0x10,%esp
f0102fda:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102fdf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102fe2:	5b                   	pop    %ebx
f0102fe3:	5e                   	pop    %esi
f0102fe4:	5d                   	pop    %ebp
f0102fe5:	c3                   	ret    
		return -E_NO_MEM;
f0102fe6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0102feb:	eb f2                	jmp    f0102fdf <env_setup_vm+0x62>

f0102fed <pa2page>:
	if (PGNUM(pa) >= npages)
f0102fed:	c1 e8 0c             	shr    $0xc,%eax
f0102ff0:	3b 05 88 2e 22 f0    	cmp    0xf0222e88,%eax
f0102ff6:	73 0a                	jae    f0103002 <pa2page+0x15>
	return &pages[PGNUM(pa)];
f0102ff8:	8b 15 90 2e 22 f0    	mov    0xf0222e90,%edx
f0102ffe:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0103001:	c3                   	ret    
{
f0103002:	55                   	push   %ebp
f0103003:	89 e5                	mov    %esp,%ebp
f0103005:	83 ec 0c             	sub    $0xc,%esp
		panic("pa2page called with invalid pa");
f0103008:	68 e0 6b 10 f0       	push   $0xf0106be0
f010300d:	6a 51                	push   $0x51
f010300f:	68 e1 74 10 f0       	push   $0xf01074e1
f0103014:	e8 51 d0 ff ff       	call   f010006a <_panic>

f0103019 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103019:	55                   	push   %ebp
f010301a:	89 e5                	mov    %esp,%ebp
f010301c:	57                   	push   %edi
f010301d:	56                   	push   %esi
f010301e:	53                   	push   %ebx
f010301f:	83 ec 0c             	sub    $0xc,%esp
f0103022:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	void *begin = ROUNDDOWN(va, PGSIZE);
f0103024:	89 d3                	mov    %edx,%ebx
f0103026:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void *end = ROUNDUP(va + len, PGSIZE);
f010302c:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0103033:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

	while (begin < end) {
f0103039:	39 f3                	cmp    %esi,%ebx
f010303b:	73 5a                	jae    f0103097 <region_alloc+0x7e>
		struct PageInfo *p;

		if (!(p = page_alloc(ALLOC_ZERO))) {
f010303d:	83 ec 0c             	sub    $0xc,%esp
f0103040:	6a 01                	push   $0x1
f0103042:	e8 f6 e0 ff ff       	call   f010113d <page_alloc>
f0103047:	83 c4 10             	add    $0x10,%esp
f010304a:	85 c0                	test   %eax,%eax
f010304c:	74 1b                	je     f0103069 <region_alloc+0x50>
			panic("ERROR REGION ALLOC");
		}
		if (page_insert(e->env_pgdir, p, begin, PTE_W | PTE_U) != 0) {
f010304e:	6a 06                	push   $0x6
f0103050:	53                   	push   %ebx
f0103051:	50                   	push   %eax
f0103052:	ff 77 60             	pushl  0x60(%edi)
f0103055:	e8 c1 ea ff ff       	call   f0101b1b <page_insert>
f010305a:	83 c4 10             	add    $0x10,%esp
f010305d:	85 c0                	test   %eax,%eax
f010305f:	75 1f                	jne    f0103080 <region_alloc+0x67>
			panic("ERROR REGINON ALLOC - PAGE INSERT");
		}

		begin += PGSIZE;  // New page address
f0103061:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103067:	eb d0                	jmp    f0103039 <region_alloc+0x20>
			panic("ERROR REGION ALLOC");
f0103069:	83 ec 04             	sub    $0x4,%esp
f010306c:	68 f1 77 10 f0       	push   $0xf01077f1
f0103071:	68 2b 01 00 00       	push   $0x12b
f0103076:	68 e6 77 10 f0       	push   $0xf01077e6
f010307b:	e8 ea cf ff ff       	call   f010006a <_panic>
			panic("ERROR REGINON ALLOC - PAGE INSERT");
f0103080:	83 ec 04             	sub    $0x4,%esp
f0103083:	68 c4 77 10 f0       	push   $0xf01077c4
f0103088:	68 2e 01 00 00       	push   $0x12e
f010308d:	68 e6 77 10 f0       	push   $0xf01077e6
f0103092:	e8 d3 cf ff ff       	call   f010006a <_panic>
	}
}
f0103097:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010309a:	5b                   	pop    %ebx
f010309b:	5e                   	pop    %esi
f010309c:	5f                   	pop    %edi
f010309d:	5d                   	pop    %ebp
f010309e:	c3                   	ret    

f010309f <load_icode>:
// load_icode panics if it encounters problems.
//  - How might load_icode fail?  What might be wrong with the given input?
//
static void
load_icode(struct Env *e, uint8_t *binary)
{
f010309f:	55                   	push   %ebp
f01030a0:	89 e5                	mov    %esp,%ebp
f01030a2:	57                   	push   %edi
f01030a3:	56                   	push   %esi
f01030a4:	53                   	push   %ebx
f01030a5:	83 ec 1c             	sub    $0x1c,%esp
f01030a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 3: Your code here.

	struct Elf *elf = (struct Elf *) binary;

	if (elf->e_magic != ELF_MAGIC) {  // Check if it is a valid ELF
f01030ab:	81 3a 7f 45 4c 46    	cmpl   $0x464c457f,(%edx)
f01030b1:	75 2c                	jne    f01030df <load_icode+0x40>
f01030b3:	89 d7                	mov    %edx,%edi
		panic("ERROR, INVALID ELF");
	}

	// Program header
	struct Proghdr *ph = (struct Proghdr *) (binary + elf->e_phoff);  // Begin
f01030b5:	89 d3                	mov    %edx,%ebx
f01030b7:	03 5a 1c             	add    0x1c(%edx),%ebx
	struct Proghdr *ph_end = ph + elf->e_phnum;                       // End
f01030ba:	0f b7 72 2c          	movzwl 0x2c(%edx),%esi
f01030be:	c1 e6 05             	shl    $0x5,%esi
f01030c1:	01 de                	add    %ebx,%esi

	lcr3(PADDR(e->env_pgdir));  // Change to user addresses
f01030c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01030c6:	8b 48 60             	mov    0x60(%eax),%ecx
f01030c9:	ba 76 01 00 00       	mov    $0x176,%edx
f01030ce:	b8 e6 77 10 f0       	mov    $0xf01077e6,%eax
f01030d3:	e8 83 fe ff ff       	call   f0102f5b <_paddr>
f01030d8:	e8 23 fe ff ff       	call   f0102f00 <lcr3>

	while (ph < ph_end) {
f01030dd:	eb 4f                	jmp    f010312e <load_icode+0x8f>
		panic("ERROR, INVALID ELF");
f01030df:	83 ec 04             	sub    $0x4,%esp
f01030e2:	68 04 78 10 f0       	push   $0xf0107804
f01030e7:	68 6f 01 00 00       	push   $0x16f
f01030ec:	68 e6 77 10 f0       	push   $0xf01077e6
f01030f1:	e8 74 cf ff ff       	call   f010006a <_panic>
		if (ph->p_type == ELF_PROG_LOAD) {
			region_alloc(e, (void *) ph->p_va, ph->p_memsz);
f01030f6:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01030f9:	8b 53 08             	mov    0x8(%ebx),%edx
f01030fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01030ff:	e8 15 ff ff ff       	call   f0103019 <region_alloc>

			// Initialize all addresses with 0
			memset((void *) ph->p_va, 0, ph->p_memsz);
f0103104:	83 ec 04             	sub    $0x4,%esp
f0103107:	ff 73 14             	pushl  0x14(%ebx)
f010310a:	6a 00                	push   $0x0
f010310c:	ff 73 08             	pushl  0x8(%ebx)
f010310f:	e8 4b 27 00 00       	call   f010585f <memset>

			memcpy((void *) ph->p_va,
f0103114:	83 c4 0c             	add    $0xc,%esp
f0103117:	ff 73 10             	pushl  0x10(%ebx)
			       binary + ph->p_offset,
f010311a:	89 f8                	mov    %edi,%eax
f010311c:	03 43 04             	add    0x4(%ebx),%eax
			memcpy((void *) ph->p_va,
f010311f:	50                   	push   %eax
f0103120:	ff 73 08             	pushl  0x8(%ebx)
f0103123:	e8 eb 27 00 00       	call   f0105913 <memcpy>
f0103128:	83 c4 10             	add    $0x10,%esp
			       ph->p_filesz);
		}

		ph++;
f010312b:	83 c3 20             	add    $0x20,%ebx
	while (ph < ph_end) {
f010312e:	39 f3                	cmp    %esi,%ebx
f0103130:	73 07                	jae    f0103139 <load_icode+0x9a>
		if (ph->p_type == ELF_PROG_LOAD) {
f0103132:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103135:	75 f4                	jne    f010312b <load_icode+0x8c>
f0103137:	eb bd                	jmp    f01030f6 <load_icode+0x57>
	}

	lcr3(PADDR(kern_pgdir));  // Change back to kernel addresses
f0103139:	8b 0d 8c 2e 22 f0    	mov    0xf0222e8c,%ecx
f010313f:	ba 87 01 00 00       	mov    $0x187,%edx
f0103144:	b8 e6 77 10 f0       	mov    $0xf01077e6,%eax
f0103149:	e8 0d fe ff ff       	call   f0102f5b <_paddr>
f010314e:	e8 ad fd ff ff       	call   f0102f00 <lcr3>

	region_alloc(e, (void *) USTACKTOP - PGSIZE, PGSIZE);
f0103153:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103158:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010315d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103160:	89 f0                	mov    %esi,%eax
f0103162:	e8 b2 fe ff ff       	call   f0103019 <region_alloc>
	e->env_tf.tf_eip = elf->e_entry;
f0103167:	8b 47 18             	mov    0x18(%edi),%eax
f010316a:	89 46 30             	mov    %eax,0x30(%esi)
}
f010316d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103170:	5b                   	pop    %ebx
f0103171:	5e                   	pop    %esi
f0103172:	5f                   	pop    %edi
f0103173:	5d                   	pop    %ebp
f0103174:	c3                   	ret    

f0103175 <unlock_kernel>:

static inline void
unlock_kernel(void)
{
f0103175:	55                   	push   %ebp
f0103176:	89 e5                	mov    %esp,%ebp
f0103178:	83 ec 14             	sub    $0x14,%esp
	spin_unlock(&kernel_lock);
f010317b:	68 c0 23 12 f0       	push   $0xf01223c0
f0103180:	e8 d6 30 00 00       	call   f010625b <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103185:	f3 90                	pause  
}
f0103187:	83 c4 10             	add    $0x10,%esp
f010318a:	c9                   	leave  
f010318b:	c3                   	ret    

f010318c <envid2env>:
{
f010318c:	f3 0f 1e fb          	endbr32 
f0103190:	55                   	push   %ebp
f0103191:	89 e5                	mov    %esp,%ebp
f0103193:	56                   	push   %esi
f0103194:	53                   	push   %ebx
f0103195:	8b 75 08             	mov    0x8(%ebp),%esi
f0103198:	8b 45 10             	mov    0x10(%ebp),%eax
	if (envid == 0) {
f010319b:	85 f6                	test   %esi,%esi
f010319d:	74 2e                	je     f01031cd <envid2env+0x41>
	e = &envs[ENVX(envid)];
f010319f:	89 f3                	mov    %esi,%ebx
f01031a1:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01031a7:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01031aa:	03 1d 44 12 22 f0    	add    0xf0221244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01031b0:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01031b4:	74 2e                	je     f01031e4 <envid2env+0x58>
f01031b6:	39 73 48             	cmp    %esi,0x48(%ebx)
f01031b9:	75 29                	jne    f01031e4 <envid2env+0x58>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01031bb:	84 c0                	test   %al,%al
f01031bd:	75 35                	jne    f01031f4 <envid2env+0x68>
	*env_store = e;
f01031bf:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031c2:	89 18                	mov    %ebx,(%eax)
	return 0;
f01031c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01031c9:	5b                   	pop    %ebx
f01031ca:	5e                   	pop    %esi
f01031cb:	5d                   	pop    %ebp
f01031cc:	c3                   	ret    
		*env_store = curenv;
f01031cd:	e8 1e 2d 00 00       	call   f0105ef0 <cpunum>
f01031d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01031d5:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f01031db:	8b 55 0c             	mov    0xc(%ebp),%edx
f01031de:	89 02                	mov    %eax,(%edx)
		return 0;
f01031e0:	89 f0                	mov    %esi,%eax
f01031e2:	eb e5                	jmp    f01031c9 <envid2env+0x3d>
		*env_store = 0;
f01031e4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01031ed:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01031f2:	eb d5                	jmp    f01031c9 <envid2env+0x3d>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01031f4:	e8 f7 2c 00 00       	call   f0105ef0 <cpunum>
f01031f9:	6b c0 74             	imul   $0x74,%eax,%eax
f01031fc:	39 98 28 30 22 f0    	cmp    %ebx,-0xfddcfd8(%eax)
f0103202:	74 bb                	je     f01031bf <envid2env+0x33>
f0103204:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103207:	e8 e4 2c 00 00       	call   f0105ef0 <cpunum>
f010320c:	6b c0 74             	imul   $0x74,%eax,%eax
f010320f:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0103215:	3b 70 48             	cmp    0x48(%eax),%esi
f0103218:	74 a5                	je     f01031bf <envid2env+0x33>
		*env_store = 0;
f010321a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010321d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103223:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103228:	eb 9f                	jmp    f01031c9 <envid2env+0x3d>

f010322a <env_init_percpu>:
{
f010322a:	f3 0f 1e fb          	endbr32 
f010322e:	55                   	push   %ebp
f010322f:	89 e5                	mov    %esp,%ebp
f0103231:	83 ec 08             	sub    $0x8,%esp
	lgdt(&gdt_pd);
f0103234:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f0103239:	e8 ba fc ff ff       	call   f0102ef8 <lgdt>
	asm volatile("movw %%ax,%%gs" : : "a"(GD_UD | 3));
f010323e:	b8 23 00 00 00       	mov    $0x23,%eax
f0103243:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a"(GD_UD | 3));
f0103245:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a"(GD_KD));
f0103247:	b8 10 00 00 00       	mov    $0x10,%eax
f010324c:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a"(GD_KD));
f010324e:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a"(GD_KD));
f0103250:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i"(GD_KT));
f0103252:	ea 59 32 10 f0 08 00 	ljmp   $0x8,$0xf0103259
	lldt(0);
f0103259:	b8 00 00 00 00       	mov    $0x0,%eax
f010325e:	e8 99 fc ff ff       	call   f0102efc <lldt>
}
f0103263:	c9                   	leave  
f0103264:	c3                   	ret    

f0103265 <env_init>:
{
f0103265:	f3 0f 1e fb          	endbr32 
f0103269:	55                   	push   %ebp
f010326a:	89 e5                	mov    %esp,%ebp
f010326c:	56                   	push   %esi
f010326d:	53                   	push   %ebx
		envs[i].env_id = 0;
f010326e:	8b 35 44 12 22 f0    	mov    0xf0221244,%esi
f0103274:	8b 15 48 12 22 f0    	mov    0xf0221248,%edx
f010327a:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103280:	89 f3                	mov    %esi,%ebx
f0103282:	89 d1                	mov    %edx,%ecx
f0103284:	89 c2                	mov    %eax,%edx
f0103286:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f010328d:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f0103294:	89 48 44             	mov    %ecx,0x44(%eax)
f0103297:	83 e8 7c             	sub    $0x7c,%eax
	for (int i = NENV - 1; i >= 0; i--) {
f010329a:	39 da                	cmp    %ebx,%edx
f010329c:	75 e4                	jne    f0103282 <env_init+0x1d>
f010329e:	89 35 48 12 22 f0    	mov    %esi,0xf0221248
	env_init_percpu();
f01032a4:	e8 81 ff ff ff       	call   f010322a <env_init_percpu>
}
f01032a9:	5b                   	pop    %ebx
f01032aa:	5e                   	pop    %esi
f01032ab:	5d                   	pop    %ebp
f01032ac:	c3                   	ret    

f01032ad <env_alloc>:
{
f01032ad:	f3 0f 1e fb          	endbr32 
f01032b1:	55                   	push   %ebp
f01032b2:	89 e5                	mov    %esp,%ebp
f01032b4:	53                   	push   %ebx
f01032b5:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f01032b8:	8b 1d 48 12 22 f0    	mov    0xf0221248,%ebx
f01032be:	85 db                	test   %ebx,%ebx
f01032c0:	0f 84 e9 00 00 00    	je     f01033af <env_alloc+0x102>
	if ((r = env_setup_vm(e)) < 0)
f01032c6:	89 d8                	mov    %ebx,%eax
f01032c8:	e8 b0 fc ff ff       	call   f0102f7d <env_setup_vm>
f01032cd:	85 c0                	test   %eax,%eax
f01032cf:	0f 88 d5 00 00 00    	js     f01033aa <env_alloc+0xfd>
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01032d5:	8b 43 48             	mov    0x48(%ebx),%eax
f01032d8:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f01032dd:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01032e2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01032e7:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01032ea:	89 da                	mov    %ebx,%edx
f01032ec:	2b 15 44 12 22 f0    	sub    0xf0221244,%edx
f01032f2:	c1 fa 02             	sar    $0x2,%edx
f01032f5:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01032fb:	09 d0                	or     %edx,%eax
f01032fd:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103300:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103303:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103306:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010330d:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103314:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010331b:	83 ec 04             	sub    $0x4,%esp
f010331e:	6a 44                	push   $0x44
f0103320:	6a 00                	push   $0x0
f0103322:	53                   	push   %ebx
f0103323:	e8 37 25 00 00       	call   f010585f <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103328:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010332e:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103334:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010333a:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103341:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |=
f0103347:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f010334e:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f0103355:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f0103359:	8b 43 44             	mov    0x44(%ebx),%eax
f010335c:	a3 48 12 22 f0       	mov    %eax,0xf0221248
	*newenv_store = e;
f0103361:	8b 45 08             	mov    0x8(%ebp),%eax
f0103364:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103366:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103369:	e8 82 2b 00 00       	call   f0105ef0 <cpunum>
f010336e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103371:	83 c4 10             	add    $0x10,%esp
f0103374:	ba 00 00 00 00       	mov    $0x0,%edx
f0103379:	83 b8 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%eax)
f0103380:	74 11                	je     f0103393 <env_alloc+0xe6>
f0103382:	e8 69 2b 00 00       	call   f0105ef0 <cpunum>
f0103387:	6b c0 74             	imul   $0x74,%eax,%eax
f010338a:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0103390:	8b 50 48             	mov    0x48(%eax),%edx
f0103393:	83 ec 04             	sub    $0x4,%esp
f0103396:	53                   	push   %ebx
f0103397:	52                   	push   %edx
f0103398:	68 17 78 10 f0       	push   $0xf0107817
f010339d:	e8 6e 05 00 00       	call   f0103910 <cprintf>
	return 0;
f01033a2:	83 c4 10             	add    $0x10,%esp
f01033a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033ad:	c9                   	leave  
f01033ae:	c3                   	ret    
		return -E_NO_FREE_ENV;
f01033af:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01033b4:	eb f4                	jmp    f01033aa <env_alloc+0xfd>

f01033b6 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01033b6:	f3 0f 1e fb          	endbr32 
f01033ba:	55                   	push   %ebp
f01033bb:	89 e5                	mov    %esp,%ebp
f01033bd:	53                   	push   %ebx
f01033be:	83 ec 1c             	sub    $0x1c,%esp
f01033c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 3: Your code here.
	struct Env *new_env;

	if (env_alloc(&new_env, 0) != 0) {
f01033c4:	6a 00                	push   $0x0
f01033c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01033c9:	50                   	push   %eax
f01033ca:	e8 de fe ff ff       	call   f01032ad <env_alloc>
f01033cf:	83 c4 10             	add    $0x10,%esp
f01033d2:	85 c0                	test   %eax,%eax
f01033d4:	75 1b                	jne    f01033f1 <env_create+0x3b>
		panic("ERROR CREATING ENV");
	}
	load_icode(new_env, binary);
f01033d6:	8b 55 08             	mov    0x8(%ebp),%edx
f01033d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01033dc:	e8 be fc ff ff       	call   f010309f <load_icode>
	new_env->env_type = type;
f01033e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01033e4:	89 58 50             	mov    %ebx,0x50(%eax)

	// If this is the file server (type == ENV_TYPE_FS) give it I/O
	// privileges.
	// LAB 5: Your code here.
	if (type == ENV_TYPE_FS) {
f01033e7:	83 fb 01             	cmp    $0x1,%ebx
f01033ea:	74 1c                	je     f0103408 <env_create+0x52>
		new_env->env_tf.tf_eflags |= FL_IOPL_3;
	}
}
f01033ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033ef:	c9                   	leave  
f01033f0:	c3                   	ret    
		panic("ERROR CREATING ENV");
f01033f1:	83 ec 04             	sub    $0x4,%esp
f01033f4:	68 2c 78 10 f0       	push   $0xf010782c
f01033f9:	68 9b 01 00 00       	push   $0x19b
f01033fe:	68 e6 77 10 f0       	push   $0xf01077e6
f0103403:	e8 62 cc ff ff       	call   f010006a <_panic>
		new_env->env_tf.tf_eflags |= FL_IOPL_3;
f0103408:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
}
f010340f:	eb db                	jmp    f01033ec <env_create+0x36>

f0103411 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103411:	f3 0f 1e fb          	endbr32 
f0103415:	55                   	push   %ebp
f0103416:	89 e5                	mov    %esp,%ebp
f0103418:	57                   	push   %edi
f0103419:	56                   	push   %esi
f010341a:	53                   	push   %ebx
f010341b:	83 ec 1c             	sub    $0x1c,%esp
f010341e:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103421:	e8 ca 2a 00 00       	call   f0105ef0 <cpunum>
f0103426:	6b c0 74             	imul   $0x74,%eax,%eax
f0103429:	39 b8 28 30 22 f0    	cmp    %edi,-0xfddcfd8(%eax)
f010342f:	74 45                	je     f0103476 <env_free+0x65>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103431:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103434:	e8 b7 2a 00 00       	call   f0105ef0 <cpunum>
f0103439:	6b c0 74             	imul   $0x74,%eax,%eax
f010343c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103441:	83 b8 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%eax)
f0103448:	74 11                	je     f010345b <env_free+0x4a>
f010344a:	e8 a1 2a 00 00       	call   f0105ef0 <cpunum>
f010344f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103452:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0103458:	8b 50 48             	mov    0x48(%eax),%edx
f010345b:	83 ec 04             	sub    $0x4,%esp
f010345e:	53                   	push   %ebx
f010345f:	52                   	push   %edx
f0103460:	68 3f 78 10 f0       	push   $0xf010783f
f0103465:	e8 a6 04 00 00       	call   f0103910 <cprintf>
f010346a:	83 c4 10             	add    $0x10,%esp
f010346d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103474:	eb 75                	jmp    f01034eb <env_free+0xda>
		lcr3(PADDR(kern_pgdir));
f0103476:	8b 0d 8c 2e 22 f0    	mov    0xf0222e8c,%ecx
f010347c:	ba b6 01 00 00       	mov    $0x1b6,%edx
f0103481:	b8 e6 77 10 f0       	mov    $0xf01077e6,%eax
f0103486:	e8 d0 fa ff ff       	call   f0102f5b <_paddr>
f010348b:	e8 70 fa ff ff       	call   f0102f00 <lcr3>
f0103490:	eb 9f                	jmp    f0103431 <env_free+0x20>
		pt = (pte_t *) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103492:	83 ec 08             	sub    $0x8,%esp
f0103495:	89 d8                	mov    %ebx,%eax
f0103497:	c1 e0 0c             	shl    $0xc,%eax
f010349a:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010349d:	50                   	push   %eax
f010349e:	ff 77 60             	pushl  0x60(%edi)
f01034a1:	e8 23 e6 ff ff       	call   f0101ac9 <page_remove>
f01034a6:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034a9:	83 c3 01             	add    $0x1,%ebx
f01034ac:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034b2:	74 08                	je     f01034bc <env_free+0xab>
			if (pt[pteno] & PTE_P)
f01034b4:	f6 04 9e 01          	testb  $0x1,(%esi,%ebx,4)
f01034b8:	74 ef                	je     f01034a9 <env_free+0x98>
f01034ba:	eb d6                	jmp    f0103492 <env_free+0x81>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034bc:	8b 47 60             	mov    0x60(%edi),%eax
f01034bf:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01034c2:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
		page_decref(pa2page(pa));
f01034c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01034cc:	e8 1c fb ff ff       	call   f0102fed <pa2page>
f01034d1:	83 ec 0c             	sub    $0xc,%esp
f01034d4:	50                   	push   %eax
f01034d5:	e8 0c e1 ff ff       	call   f01015e6 <page_decref>
f01034da:	83 c4 10             	add    $0x10,%esp
f01034dd:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f01034e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01034e4:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01034e9:	74 38                	je     f0103523 <env_free+0x112>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01034eb:	8b 47 60             	mov    0x60(%edi),%eax
f01034ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01034f1:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01034f4:	a8 01                	test   $0x1,%al
f01034f6:	74 e5                	je     f01034dd <env_free+0xcc>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01034f8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01034fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
		pt = (pte_t *) KADDR(pa);
f0103500:	89 c1                	mov    %eax,%ecx
f0103502:	ba c4 01 00 00       	mov    $0x1c4,%edx
f0103507:	b8 e6 77 10 f0       	mov    $0xf01077e6,%eax
f010350c:	e8 00 fa ff ff       	call   f0102f11 <_kaddr>
f0103511:	89 c6                	mov    %eax,%esi
f0103513:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103516:	c1 e0 14             	shl    $0x14,%eax
f0103519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010351c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103521:	eb 91                	jmp    f01034b4 <env_free+0xa3>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103523:	8b 4f 60             	mov    0x60(%edi),%ecx
f0103526:	ba d2 01 00 00       	mov    $0x1d2,%edx
f010352b:	b8 e6 77 10 f0       	mov    $0xf01077e6,%eax
f0103530:	e8 26 fa ff ff       	call   f0102f5b <_paddr>
	e->env_pgdir = 0;
f0103535:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	page_decref(pa2page(pa));
f010353c:	e8 ac fa ff ff       	call   f0102fed <pa2page>
f0103541:	83 ec 0c             	sub    $0xc,%esp
f0103544:	50                   	push   %eax
f0103545:	e8 9c e0 ff ff       	call   f01015e6 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010354a:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103551:	a1 48 12 22 f0       	mov    0xf0221248,%eax
f0103556:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103559:	89 3d 48 12 22 f0    	mov    %edi,0xf0221248
}
f010355f:	83 c4 10             	add    $0x10,%esp
f0103562:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103565:	5b                   	pop    %ebx
f0103566:	5e                   	pop    %esi
f0103567:	5f                   	pop    %edi
f0103568:	5d                   	pop    %ebp
f0103569:	c3                   	ret    

f010356a <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010356a:	f3 0f 1e fb          	endbr32 
f010356e:	55                   	push   %ebp
f010356f:	89 e5                	mov    %esp,%ebp
f0103571:	53                   	push   %ebx
f0103572:	83 ec 04             	sub    $0x4,%esp
f0103575:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103578:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010357c:	74 21                	je     f010359f <env_destroy+0x35>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f010357e:	83 ec 0c             	sub    $0xc,%esp
f0103581:	53                   	push   %ebx
f0103582:	e8 8a fe ff ff       	call   f0103411 <env_free>

	if (curenv == e) {
f0103587:	e8 64 29 00 00       	call   f0105ef0 <cpunum>
f010358c:	6b c0 74             	imul   $0x74,%eax,%eax
f010358f:	83 c4 10             	add    $0x10,%esp
f0103592:	39 98 28 30 22 f0    	cmp    %ebx,-0xfddcfd8(%eax)
f0103598:	74 1e                	je     f01035b8 <env_destroy+0x4e>
		curenv = NULL;
		sched_yield();
	}
}
f010359a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010359d:	c9                   	leave  
f010359e:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010359f:	e8 4c 29 00 00       	call   f0105ef0 <cpunum>
f01035a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01035a7:	39 98 28 30 22 f0    	cmp    %ebx,-0xfddcfd8(%eax)
f01035ad:	74 cf                	je     f010357e <env_destroy+0x14>
		e->env_status = ENV_DYING;
f01035af:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01035b6:	eb e2                	jmp    f010359a <env_destroy+0x30>
		curenv = NULL;
f01035b8:	e8 33 29 00 00       	call   f0105ef0 <cpunum>
f01035bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01035c0:	c7 80 28 30 22 f0 00 	movl   $0x0,-0xfddcfd8(%eax)
f01035c7:	00 00 00 
		sched_yield();
f01035ca:	e8 60 0f 00 00       	call   f010452f <sched_yield>

f01035cf <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01035cf:	f3 0f 1e fb          	endbr32 
f01035d3:	55                   	push   %ebp
f01035d4:	89 e5                	mov    %esp,%ebp
f01035d6:	53                   	push   %ebx
f01035d7:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01035da:	e8 11 29 00 00       	call   f0105ef0 <cpunum>
f01035df:	6b c0 74             	imul   $0x74,%eax,%eax
f01035e2:	8b 98 28 30 22 f0    	mov    -0xfddcfd8(%eax),%ebx
f01035e8:	e8 03 29 00 00       	call   f0105ef0 <cpunum>
f01035ed:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile("\tmovl %0,%%esp\n"
f01035f0:	8b 65 08             	mov    0x8(%ebp),%esp
f01035f3:	61                   	popa   
f01035f4:	07                   	pop    %es
f01035f5:	1f                   	pop    %ds
f01035f6:	83 c4 08             	add    $0x8,%esp
f01035f9:	cf                   	iret   
	             "\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
	             "\tiret\n"
	             :
	             : "g"(tf)
	             : "memory");
	panic("iret failed"); /* mostly to placate the compiler */
f01035fa:	83 ec 04             	sub    $0x4,%esp
f01035fd:	68 55 78 10 f0       	push   $0xf0107855
f0103602:	68 0a 02 00 00       	push   $0x20a
f0103607:	68 e6 77 10 f0       	push   $0xf01077e6
f010360c:	e8 59 ca ff ff       	call   f010006a <_panic>

f0103611 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *new_env)
{
f0103611:	f3 0f 1e fb          	endbr32 
f0103615:	55                   	push   %ebp
f0103616:	89 e5                	mov    %esp,%ebp
f0103618:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv != NULL && curenv->env_status == ENV_RUNNING) {
f010361b:	e8 d0 28 00 00       	call   f0105ef0 <cpunum>
f0103620:	6b c0 74             	imul   $0x74,%eax,%eax
f0103623:	83 b8 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%eax)
f010362a:	74 14                	je     f0103640 <env_run+0x2f>
f010362c:	e8 bf 28 00 00       	call   f0105ef0 <cpunum>
f0103631:	6b c0 74             	imul   $0x74,%eax,%eax
f0103634:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010363a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010363e:	74 78                	je     f01036b8 <env_run+0xa7>
		curenv->env_status = ENV_RUNNABLE;
	}

	curenv = new_env;
f0103640:	e8 ab 28 00 00       	call   f0105ef0 <cpunum>
f0103645:	6b c0 74             	imul   $0x74,%eax,%eax
f0103648:	8b 55 08             	mov    0x8(%ebp),%edx
f010364b:	89 90 28 30 22 f0    	mov    %edx,-0xfddcfd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103651:	e8 9a 28 00 00       	call   f0105ef0 <cpunum>
f0103656:	6b c0 74             	imul   $0x74,%eax,%eax
f0103659:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010365f:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103666:	e8 85 28 00 00       	call   f0105ef0 <cpunum>
f010366b:	6b c0 74             	imul   $0x74,%eax,%eax
f010366e:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0103674:	83 40 58 01          	addl   $0x1,0x58(%eax)

	lcr3(PADDR(curenv->env_pgdir));
f0103678:	e8 73 28 00 00       	call   f0105ef0 <cpunum>
f010367d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103680:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0103686:	8b 48 60             	mov    0x60(%eax),%ecx
f0103689:	ba 30 02 00 00       	mov    $0x230,%edx
f010368e:	b8 e6 77 10 f0       	mov    $0xf01077e6,%eax
f0103693:	e8 c3 f8 ff ff       	call   f0102f5b <_paddr>
f0103698:	e8 63 f8 ff ff       	call   f0102f00 <lcr3>

	unlock_kernel();
f010369d:	e8 d3 fa ff ff       	call   f0103175 <unlock_kernel>

	env_pop_tf(&(curenv->env_tf));
f01036a2:	e8 49 28 00 00       	call   f0105ef0 <cpunum>
f01036a7:	83 ec 0c             	sub    $0xc,%esp
f01036aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ad:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f01036b3:	e8 17 ff ff ff       	call   f01035cf <env_pop_tf>
		curenv->env_status = ENV_RUNNABLE;
f01036b8:	e8 33 28 00 00       	call   f0105ef0 <cpunum>
f01036bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01036c0:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f01036c6:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f01036cd:	e9 6e ff ff ff       	jmp    f0103640 <env_run+0x2f>

f01036d2 <inb>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01036d2:	89 c2                	mov    %eax,%edx
f01036d4:	ec                   	in     (%dx),%al
}
f01036d5:	c3                   	ret    

f01036d6 <outb>:
{
f01036d6:	89 c1                	mov    %eax,%ecx
f01036d8:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036da:	89 ca                	mov    %ecx,%edx
f01036dc:	ee                   	out    %al,(%dx)
}
f01036dd:	c3                   	ret    

f01036de <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01036de:	f3 0f 1e fb          	endbr32 
f01036e2:	55                   	push   %ebp
f01036e3:	89 e5                	mov    %esp,%ebp
f01036e5:	83 ec 08             	sub    $0x8,%esp
	outb(IO_RTC, reg);
f01036e8:	0f b6 55 08          	movzbl 0x8(%ebp),%edx
f01036ec:	b8 70 00 00 00       	mov    $0x70,%eax
f01036f1:	e8 e0 ff ff ff       	call   f01036d6 <outb>
	return inb(IO_RTC+1);
f01036f6:	b8 71 00 00 00       	mov    $0x71,%eax
f01036fb:	e8 d2 ff ff ff       	call   f01036d2 <inb>
f0103700:	0f b6 c0             	movzbl %al,%eax
}
f0103703:	c9                   	leave  
f0103704:	c3                   	ret    

f0103705 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103705:	f3 0f 1e fb          	endbr32 
f0103709:	55                   	push   %ebp
f010370a:	89 e5                	mov    %esp,%ebp
f010370c:	83 ec 08             	sub    $0x8,%esp
	outb(IO_RTC, reg);
f010370f:	0f b6 55 08          	movzbl 0x8(%ebp),%edx
f0103713:	b8 70 00 00 00       	mov    $0x70,%eax
f0103718:	e8 b9 ff ff ff       	call   f01036d6 <outb>
	outb(IO_RTC+1, datum);
f010371d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
f0103721:	b8 71 00 00 00       	mov    $0x71,%eax
f0103726:	e8 ab ff ff ff       	call   f01036d6 <outb>
}
f010372b:	c9                   	leave  
f010372c:	c3                   	ret    

f010372d <outb>:
{
f010372d:	89 c1                	mov    %eax,%ecx
f010372f:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103731:	89 ca                	mov    %ecx,%edx
f0103733:	ee                   	out    %al,(%dx)
}
f0103734:	c3                   	ret    

f0103735 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103735:	f3 0f 1e fb          	endbr32 
f0103739:	55                   	push   %ebp
f010373a:	89 e5                	mov    %esp,%ebp
f010373c:	56                   	push   %esi
f010373d:	53                   	push   %ebx
f010373e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	irq_mask_8259A = mask;
f0103741:	66 89 1d a8 23 12 f0 	mov    %bx,0xf01223a8
	if (!didinit)
f0103748:	80 3d 4c 12 22 f0 00 	cmpb   $0x0,0xf022124c
f010374f:	75 07                	jne    f0103758 <irq_setmask_8259A+0x23>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103751:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103754:	5b                   	pop    %ebx
f0103755:	5e                   	pop    %esi
f0103756:	5d                   	pop    %ebp
f0103757:	c3                   	ret    
f0103758:	89 de                	mov    %ebx,%esi
	outb(IO_PIC1+1, (char)mask);
f010375a:	0f b6 d3             	movzbl %bl,%edx
f010375d:	b8 21 00 00 00       	mov    $0x21,%eax
f0103762:	e8 c6 ff ff ff       	call   f010372d <outb>
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103767:	0f b6 d7             	movzbl %bh,%edx
f010376a:	b8 a1 00 00 00       	mov    $0xa1,%eax
f010376f:	e8 b9 ff ff ff       	call   f010372d <outb>
	cprintf("enabled interrupts:");
f0103774:	83 ec 0c             	sub    $0xc,%esp
f0103777:	68 61 78 10 f0       	push   $0xf0107861
f010377c:	e8 8f 01 00 00       	call   f0103910 <cprintf>
f0103781:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103784:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103789:	0f b7 f6             	movzwl %si,%esi
f010378c:	f7 d6                	not    %esi
f010378e:	eb 19                	jmp    f01037a9 <irq_setmask_8259A+0x74>
			cprintf(" %d", i);
f0103790:	83 ec 08             	sub    $0x8,%esp
f0103793:	53                   	push   %ebx
f0103794:	68 1f 7d 10 f0       	push   $0xf0107d1f
f0103799:	e8 72 01 00 00       	call   f0103910 <cprintf>
f010379e:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01037a1:	83 c3 01             	add    $0x1,%ebx
f01037a4:	83 fb 10             	cmp    $0x10,%ebx
f01037a7:	74 07                	je     f01037b0 <irq_setmask_8259A+0x7b>
		if (~mask & (1<<i))
f01037a9:	0f a3 de             	bt     %ebx,%esi
f01037ac:	73 f3                	jae    f01037a1 <irq_setmask_8259A+0x6c>
f01037ae:	eb e0                	jmp    f0103790 <irq_setmask_8259A+0x5b>
	cprintf("\n");
f01037b0:	83 ec 0c             	sub    $0xc,%esp
f01037b3:	68 bf 77 10 f0       	push   $0xf01077bf
f01037b8:	e8 53 01 00 00       	call   f0103910 <cprintf>
f01037bd:	83 c4 10             	add    $0x10,%esp
f01037c0:	eb 8f                	jmp    f0103751 <irq_setmask_8259A+0x1c>

f01037c2 <pic_init>:
{
f01037c2:	f3 0f 1e fb          	endbr32 
f01037c6:	55                   	push   %ebp
f01037c7:	89 e5                	mov    %esp,%ebp
f01037c9:	83 ec 08             	sub    $0x8,%esp
	didinit = 1;
f01037cc:	c6 05 4c 12 22 f0 01 	movb   $0x1,0xf022124c
	outb(IO_PIC1+1, 0xFF);
f01037d3:	ba ff 00 00 00       	mov    $0xff,%edx
f01037d8:	b8 21 00 00 00       	mov    $0x21,%eax
f01037dd:	e8 4b ff ff ff       	call   f010372d <outb>
	outb(IO_PIC2+1, 0xFF);
f01037e2:	ba ff 00 00 00       	mov    $0xff,%edx
f01037e7:	b8 a1 00 00 00       	mov    $0xa1,%eax
f01037ec:	e8 3c ff ff ff       	call   f010372d <outb>
	outb(IO_PIC1, 0x11);
f01037f1:	ba 11 00 00 00       	mov    $0x11,%edx
f01037f6:	b8 20 00 00 00       	mov    $0x20,%eax
f01037fb:	e8 2d ff ff ff       	call   f010372d <outb>
	outb(IO_PIC1+1, IRQ_OFFSET);
f0103800:	ba 20 00 00 00       	mov    $0x20,%edx
f0103805:	b8 21 00 00 00       	mov    $0x21,%eax
f010380a:	e8 1e ff ff ff       	call   f010372d <outb>
	outb(IO_PIC1+1, 1<<IRQ_SLAVE);
f010380f:	ba 04 00 00 00       	mov    $0x4,%edx
f0103814:	b8 21 00 00 00       	mov    $0x21,%eax
f0103819:	e8 0f ff ff ff       	call   f010372d <outb>
	outb(IO_PIC1+1, 0x3);
f010381e:	ba 03 00 00 00       	mov    $0x3,%edx
f0103823:	b8 21 00 00 00       	mov    $0x21,%eax
f0103828:	e8 00 ff ff ff       	call   f010372d <outb>
	outb(IO_PIC2, 0x11);			// ICW1
f010382d:	ba 11 00 00 00       	mov    $0x11,%edx
f0103832:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0103837:	e8 f1 fe ff ff       	call   f010372d <outb>
	outb(IO_PIC2+1, IRQ_OFFSET + 8);	// ICW2
f010383c:	ba 28 00 00 00       	mov    $0x28,%edx
f0103841:	b8 a1 00 00 00       	mov    $0xa1,%eax
f0103846:	e8 e2 fe ff ff       	call   f010372d <outb>
	outb(IO_PIC2+1, IRQ_SLAVE);		// ICW3
f010384b:	ba 02 00 00 00       	mov    $0x2,%edx
f0103850:	b8 a1 00 00 00       	mov    $0xa1,%eax
f0103855:	e8 d3 fe ff ff       	call   f010372d <outb>
	outb(IO_PIC2+1, 0x01);			// ICW4
f010385a:	ba 01 00 00 00       	mov    $0x1,%edx
f010385f:	b8 a1 00 00 00       	mov    $0xa1,%eax
f0103864:	e8 c4 fe ff ff       	call   f010372d <outb>
	outb(IO_PIC1, 0x68);             /* clear specific mask */
f0103869:	ba 68 00 00 00       	mov    $0x68,%edx
f010386e:	b8 20 00 00 00       	mov    $0x20,%eax
f0103873:	e8 b5 fe ff ff       	call   f010372d <outb>
	outb(IO_PIC1, 0x0a);             /* read IRR by default */
f0103878:	ba 0a 00 00 00       	mov    $0xa,%edx
f010387d:	b8 20 00 00 00       	mov    $0x20,%eax
f0103882:	e8 a6 fe ff ff       	call   f010372d <outb>
	outb(IO_PIC2, 0x68);               /* OCW3 */
f0103887:	ba 68 00 00 00       	mov    $0x68,%edx
f010388c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0103891:	e8 97 fe ff ff       	call   f010372d <outb>
	outb(IO_PIC2, 0x0a);               /* OCW3 */
f0103896:	ba 0a 00 00 00       	mov    $0xa,%edx
f010389b:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01038a0:	e8 88 fe ff ff       	call   f010372d <outb>
	if (irq_mask_8259A != 0xFFFF)
f01038a5:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01038ac:	66 83 f8 ff          	cmp    $0xffff,%ax
f01038b0:	75 02                	jne    f01038b4 <pic_init+0xf2>
}
f01038b2:	c9                   	leave  
f01038b3:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f01038b4:	83 ec 0c             	sub    $0xc,%esp
f01038b7:	0f b7 c0             	movzwl %ax,%eax
f01038ba:	50                   	push   %eax
f01038bb:	e8 75 fe ff ff       	call   f0103735 <irq_setmask_8259A>
f01038c0:	83 c4 10             	add    $0x10,%esp
}
f01038c3:	eb ed                	jmp    f01038b2 <pic_init+0xf0>

f01038c5 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01038c5:	f3 0f 1e fb          	endbr32 
f01038c9:	55                   	push   %ebp
f01038ca:	89 e5                	mov    %esp,%ebp
f01038cc:	53                   	push   %ebx
f01038cd:	83 ec 10             	sub    $0x10,%esp
f01038d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f01038d3:	ff 75 08             	pushl  0x8(%ebp)
f01038d6:	e8 65 d0 ff ff       	call   f0100940 <cputchar>
	(*cnt)++;
f01038db:	83 03 01             	addl   $0x1,(%ebx)
}
f01038de:	83 c4 10             	add    $0x10,%esp
f01038e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01038e4:	c9                   	leave  
f01038e5:	c3                   	ret    

f01038e6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01038e6:	f3 0f 1e fb          	endbr32 
f01038ea:	55                   	push   %ebp
f01038eb:	89 e5                	mov    %esp,%ebp
f01038ed:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01038f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01038f7:	ff 75 0c             	pushl  0xc(%ebp)
f01038fa:	ff 75 08             	pushl  0x8(%ebp)
f01038fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103900:	50                   	push   %eax
f0103901:	68 c5 38 10 f0       	push   $0xf01038c5
f0103906:	e8 f1 18 00 00       	call   f01051fc <vprintfmt>
	return cnt;
}
f010390b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010390e:	c9                   	leave  
f010390f:	c3                   	ret    

f0103910 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103910:	f3 0f 1e fb          	endbr32 
f0103914:	55                   	push   %ebp
f0103915:	89 e5                	mov    %esp,%ebp
f0103917:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010391a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010391d:	50                   	push   %eax
f010391e:	ff 75 08             	pushl  0x8(%ebp)
f0103921:	e8 c0 ff ff ff       	call   f01038e6 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103926:	c9                   	leave  
f0103927:	c3                   	ret    

f0103928 <lidt>:
	asm volatile("lidt (%0)" : : "r" (p));
f0103928:	0f 01 18             	lidtl  (%eax)
}
f010392b:	c3                   	ret    

f010392c <ltr>:
	asm volatile("ltr %0" : : "r" (sel));
f010392c:	0f 00 d8             	ltr    %ax
}
f010392f:	c3                   	ret    

f0103930 <rcr2>:
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103930:	0f 20 d0             	mov    %cr2,%eax
}
f0103933:	c3                   	ret    

f0103934 <read_eflags>:
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103934:	9c                   	pushf  
f0103935:	58                   	pop    %eax
}
f0103936:	c3                   	ret    

f0103937 <xchg>:
{
f0103937:	89 c1                	mov    %eax,%ecx
f0103939:	89 d0                	mov    %edx,%eax
	asm volatile("lock; xchgl %0, %1"
f010393b:	f0 87 01             	lock xchg %eax,(%ecx)
}
f010393e:	c3                   	ret    

f010393f <trapname>:
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f010393f:	83 f8 13             	cmp    $0x13,%eax
f0103942:	76 20                	jbe    f0103964 <trapname+0x25>
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103944:	ba 84 78 10 f0       	mov    $0xf0107884,%edx
	if (trapno == T_SYSCALL)
f0103949:	83 f8 30             	cmp    $0x30,%eax
f010394c:	74 13                	je     f0103961 <trapname+0x22>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010394e:	83 e8 20             	sub    $0x20,%eax
		return "Hardware Interrupt";
f0103951:	83 f8 0f             	cmp    $0xf,%eax
f0103954:	ba 75 78 10 f0       	mov    $0xf0107875,%edx
f0103959:	b8 90 78 10 f0       	mov    $0xf0107890,%eax
f010395e:	0f 46 d0             	cmovbe %eax,%edx
	return "(unknown trap)";
}
f0103961:	89 d0                	mov    %edx,%eax
f0103963:	c3                   	ret    
		return excnames[trapno];
f0103964:	8b 14 85 00 7c 10 f0 	mov    -0xfef8400(,%eax,4),%edx
f010396b:	eb f4                	jmp    f0103961 <trapname+0x22>

f010396d <lock_kernel>:
{
f010396d:	55                   	push   %ebp
f010396e:	89 e5                	mov    %esp,%ebp
f0103970:	83 ec 14             	sub    $0x14,%esp
	spin_lock(&kernel_lock);
f0103973:	68 c0 23 12 f0       	push   $0xf01223c0
f0103978:	e8 78 28 00 00       	call   f01061f5 <spin_lock>
}
f010397d:	83 c4 10             	add    $0x10,%esp
f0103980:	c9                   	leave  
f0103981:	c3                   	ret    

f0103982 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103982:	f3 0f 1e fb          	endbr32 
f0103986:	55                   	push   %ebp
f0103987:	89 e5                	mov    %esp,%ebp
f0103989:	56                   	push   %esi
f010398a:	53                   	push   %ebx
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int id = thiscpu->cpu_id;
f010398b:	e8 60 25 00 00       	call   f0105ef0 <cpunum>
f0103990:	6b c0 74             	imul   $0x74,%eax,%eax
f0103993:	0f b6 98 20 30 22 f0 	movzbl -0xfddcfe0(%eax),%ebx
	struct Taskstate *ts = &thiscpu->cpu_ts;
f010399a:	e8 51 25 00 00       	call   f0105ef0 <cpunum>
f010399f:	6b c0 74             	imul   $0x74,%eax,%eax
f01039a2:	8d 90 2c 30 22 f0    	lea    -0xfddcfd4(%eax),%edx
	int id = thiscpu->cpu_id;
f01039a8:	0f b6 f3             	movzbl %bl,%esi

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts->ts_esp0 = KSTACKTOP - id * (KSTKSIZE + KSTKGAP);
f01039ab:	c1 e6 10             	shl    $0x10,%esi
f01039ae:	b9 00 00 00 f0       	mov    $0xf0000000,%ecx
f01039b3:	29 f1                	sub    %esi,%ecx
f01039b5:	89 88 30 30 22 f0    	mov    %ecx,-0xfddcfd0(%eax)
	ts->ts_ss0 = GD_KD;
f01039bb:	66 c7 80 34 30 22 f0 	movw   $0x10,-0xfddcfcc(%eax)
f01039c2:	10 00 
	ts->ts_iomb = sizeof(struct Taskstate);
f01039c4:	66 c7 80 92 30 22 f0 	movw   $0x68,-0xfddcf6e(%eax)
f01039cb:	68 00 

	uint16_t idx = (GD_TSS0 >> 3) + id;
f01039cd:	0f b6 db             	movzbl %bl,%ebx
f01039d0:	8d 43 05             	lea    0x5(%ebx),%eax
	uint16_t seg = idx << 3;

	// Initialize the TSS slot of the gdt.
	gdt[idx] =
f01039d3:	0f b7 c0             	movzwl %ax,%eax
f01039d6:	66 c7 04 c5 40 23 12 	movw   $0x67,-0xfeddcc0(,%eax,8)
f01039dd:	f0 67 00 
f01039e0:	66 89 14 c5 42 23 12 	mov    %dx,-0xfeddcbe(,%eax,8)
f01039e7:	f0 
	        SEG16(STS_T32A, (uint32_t)(ts), sizeof(struct Taskstate) - 1, 0);
f01039e8:	89 d1                	mov    %edx,%ecx
f01039ea:	c1 e9 10             	shr    $0x10,%ecx
	gdt[idx] =
f01039ed:	88 0c c5 44 23 12 f0 	mov    %cl,-0xfeddcbc(,%eax,8)
f01039f4:	c6 04 c5 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%eax,8)
f01039fb:	40 
	        SEG16(STS_T32A, (uint32_t)(ts), sizeof(struct Taskstate) - 1, 0);
f01039fc:	c1 ea 18             	shr    $0x18,%edx
	gdt[idx] =
f01039ff:	88 14 c5 47 23 12 f0 	mov    %dl,-0xfeddcb9(,%eax,8)
	gdt[idx].sd_s = 0;
f0103a06:	c6 04 c5 45 23 12 f0 	movb   $0x89,-0xfeddcbb(,%eax,8)
f0103a0d:	89 


	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (id << 3));
f0103a0e:	8d 1c dd 28 00 00 00 	lea    0x28(,%ebx,8),%ebx
f0103a15:	0f b7 c3             	movzwl %bx,%eax
f0103a18:	e8 0f ff ff ff       	call   f010392c <ltr>

	// Load the IDT
	lidt(&idt_pd);
f0103a1d:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f0103a22:	e8 01 ff ff ff       	call   f0103928 <lidt>
}
f0103a27:	5b                   	pop    %ebx
f0103a28:	5e                   	pop    %esi
f0103a29:	5d                   	pop    %ebp
f0103a2a:	c3                   	ret    

f0103a2b <trap_init>:
{
f0103a2b:	f3 0f 1e fb          	endbr32 
f0103a2f:	55                   	push   %ebp
f0103a30:	89 e5                	mov    %esp,%ebp
f0103a32:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, F_DIVIDE_G, 0);
f0103a35:	b8 96 43 10 f0       	mov    $0xf0104396,%eax
f0103a3a:	66 a3 60 12 22 f0    	mov    %ax,0xf0221260
f0103a40:	66 c7 05 62 12 22 f0 	movw   $0x8,0xf0221262
f0103a47:	08 00 
f0103a49:	c6 05 64 12 22 f0 00 	movb   $0x0,0xf0221264
f0103a50:	c6 05 65 12 22 f0 8e 	movb   $0x8e,0xf0221265
f0103a57:	c1 e8 10             	shr    $0x10,%eax
f0103a5a:	66 a3 66 12 22 f0    	mov    %ax,0xf0221266
	SETGATE(idt[T_DEBUG], 0, GD_KT, F_DEBUG_G, 0);
f0103a60:	b8 a0 43 10 f0       	mov    $0xf01043a0,%eax
f0103a65:	66 a3 68 12 22 f0    	mov    %ax,0xf0221268
f0103a6b:	66 c7 05 6a 12 22 f0 	movw   $0x8,0xf022126a
f0103a72:	08 00 
f0103a74:	c6 05 6c 12 22 f0 00 	movb   $0x0,0xf022126c
f0103a7b:	c6 05 6d 12 22 f0 8e 	movb   $0x8e,0xf022126d
f0103a82:	c1 e8 10             	shr    $0x10,%eax
f0103a85:	66 a3 6e 12 22 f0    	mov    %ax,0xf022126e
	SETGATE(idt[T_NMI], 0, GD_KT, F_NMI_G, 0);
f0103a8b:	b8 a6 43 10 f0       	mov    $0xf01043a6,%eax
f0103a90:	66 a3 70 12 22 f0    	mov    %ax,0xf0221270
f0103a96:	66 c7 05 72 12 22 f0 	movw   $0x8,0xf0221272
f0103a9d:	08 00 
f0103a9f:	c6 05 74 12 22 f0 00 	movb   $0x0,0xf0221274
f0103aa6:	c6 05 75 12 22 f0 8e 	movb   $0x8e,0xf0221275
f0103aad:	c1 e8 10             	shr    $0x10,%eax
f0103ab0:	66 a3 76 12 22 f0    	mov    %ax,0xf0221276
	SETGATE(idt[T_BRKPT], 0, GD_KT, F_BRKPT_G, 3);
f0103ab6:	b8 ac 43 10 f0       	mov    $0xf01043ac,%eax
f0103abb:	66 a3 78 12 22 f0    	mov    %ax,0xf0221278
f0103ac1:	66 c7 05 7a 12 22 f0 	movw   $0x8,0xf022127a
f0103ac8:	08 00 
f0103aca:	c6 05 7c 12 22 f0 00 	movb   $0x0,0xf022127c
f0103ad1:	c6 05 7d 12 22 f0 ee 	movb   $0xee,0xf022127d
f0103ad8:	c1 e8 10             	shr    $0x10,%eax
f0103adb:	66 a3 7e 12 22 f0    	mov    %ax,0xf022127e
	SETGATE(idt[T_OFLOW], 0, GD_KT, F_OFLOW_G, 0);
f0103ae1:	b8 b2 43 10 f0       	mov    $0xf01043b2,%eax
f0103ae6:	66 a3 80 12 22 f0    	mov    %ax,0xf0221280
f0103aec:	66 c7 05 82 12 22 f0 	movw   $0x8,0xf0221282
f0103af3:	08 00 
f0103af5:	c6 05 84 12 22 f0 00 	movb   $0x0,0xf0221284
f0103afc:	c6 05 85 12 22 f0 8e 	movb   $0x8e,0xf0221285
f0103b03:	c1 e8 10             	shr    $0x10,%eax
f0103b06:	66 a3 86 12 22 f0    	mov    %ax,0xf0221286
	SETGATE(idt[T_BOUND], 0, GD_KT, F_BOUND_G, 0);
f0103b0c:	b8 b8 43 10 f0       	mov    $0xf01043b8,%eax
f0103b11:	66 a3 88 12 22 f0    	mov    %ax,0xf0221288
f0103b17:	66 c7 05 8a 12 22 f0 	movw   $0x8,0xf022128a
f0103b1e:	08 00 
f0103b20:	c6 05 8c 12 22 f0 00 	movb   $0x0,0xf022128c
f0103b27:	c6 05 8d 12 22 f0 8e 	movb   $0x8e,0xf022128d
f0103b2e:	c1 e8 10             	shr    $0x10,%eax
f0103b31:	66 a3 8e 12 22 f0    	mov    %ax,0xf022128e
	SETGATE(idt[T_ILLOP], 0, GD_KT, F_ILLOP_G, 0);
f0103b37:	b8 be 43 10 f0       	mov    $0xf01043be,%eax
f0103b3c:	66 a3 90 12 22 f0    	mov    %ax,0xf0221290
f0103b42:	66 c7 05 92 12 22 f0 	movw   $0x8,0xf0221292
f0103b49:	08 00 
f0103b4b:	c6 05 94 12 22 f0 00 	movb   $0x0,0xf0221294
f0103b52:	c6 05 95 12 22 f0 8e 	movb   $0x8e,0xf0221295
f0103b59:	c1 e8 10             	shr    $0x10,%eax
f0103b5c:	66 a3 96 12 22 f0    	mov    %ax,0xf0221296
	SETGATE(idt[T_DEVICE], 0, GD_KT, F_DEVICE_G, 0);
f0103b62:	b8 c4 43 10 f0       	mov    $0xf01043c4,%eax
f0103b67:	66 a3 98 12 22 f0    	mov    %ax,0xf0221298
f0103b6d:	66 c7 05 9a 12 22 f0 	movw   $0x8,0xf022129a
f0103b74:	08 00 
f0103b76:	c6 05 9c 12 22 f0 00 	movb   $0x0,0xf022129c
f0103b7d:	c6 05 9d 12 22 f0 8e 	movb   $0x8e,0xf022129d
f0103b84:	c1 e8 10             	shr    $0x10,%eax
f0103b87:	66 a3 9e 12 22 f0    	mov    %ax,0xf022129e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, F_DBLFLT_G, 0);
f0103b8d:	b8 ca 43 10 f0       	mov    $0xf01043ca,%eax
f0103b92:	66 a3 a0 12 22 f0    	mov    %ax,0xf02212a0
f0103b98:	66 c7 05 a2 12 22 f0 	movw   $0x8,0xf02212a2
f0103b9f:	08 00 
f0103ba1:	c6 05 a4 12 22 f0 00 	movb   $0x0,0xf02212a4
f0103ba8:	c6 05 a5 12 22 f0 8e 	movb   $0x8e,0xf02212a5
f0103baf:	c1 e8 10             	shr    $0x10,%eax
f0103bb2:	66 a3 a6 12 22 f0    	mov    %ax,0xf02212a6
	SETGATE(idt[T_TSS], 0, GD_KT, F_TSS_G, 0);
f0103bb8:	b8 e2 43 10 f0       	mov    $0xf01043e2,%eax
f0103bbd:	66 a3 b0 12 22 f0    	mov    %ax,0xf02212b0
f0103bc3:	66 c7 05 b2 12 22 f0 	movw   $0x8,0xf02212b2
f0103bca:	08 00 
f0103bcc:	c6 05 b4 12 22 f0 00 	movb   $0x0,0xf02212b4
f0103bd3:	c6 05 b5 12 22 f0 8e 	movb   $0x8e,0xf02212b5
f0103bda:	c1 e8 10             	shr    $0x10,%eax
f0103bdd:	66 a3 b6 12 22 f0    	mov    %ax,0xf02212b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, F_SEGNP_G, 0);
f0103be3:	b8 ec 43 10 f0       	mov    $0xf01043ec,%eax
f0103be8:	66 a3 b8 12 22 f0    	mov    %ax,0xf02212b8
f0103bee:	66 c7 05 ba 12 22 f0 	movw   $0x8,0xf02212ba
f0103bf5:	08 00 
f0103bf7:	c6 05 bc 12 22 f0 00 	movb   $0x0,0xf02212bc
f0103bfe:	c6 05 bd 12 22 f0 8e 	movb   $0x8e,0xf02212bd
f0103c05:	c1 e8 10             	shr    $0x10,%eax
f0103c08:	66 a3 be 12 22 f0    	mov    %ax,0xf02212be
	SETGATE(idt[T_STACK], 0, GD_KT, F_STACK_G, 0);
f0103c0e:	b8 f8 43 10 f0       	mov    $0xf01043f8,%eax
f0103c13:	66 a3 c0 12 22 f0    	mov    %ax,0xf02212c0
f0103c19:	66 c7 05 c2 12 22 f0 	movw   $0x8,0xf02212c2
f0103c20:	08 00 
f0103c22:	c6 05 c4 12 22 f0 00 	movb   $0x0,0xf02212c4
f0103c29:	c6 05 c5 12 22 f0 8e 	movb   $0x8e,0xf02212c5
f0103c30:	c1 e8 10             	shr    $0x10,%eax
f0103c33:	66 a3 c6 12 22 f0    	mov    %ax,0xf02212c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, F_GPFLT_G, 0);
f0103c39:	b8 de 43 10 f0       	mov    $0xf01043de,%eax
f0103c3e:	66 a3 c8 12 22 f0    	mov    %ax,0xf02212c8
f0103c44:	66 c7 05 ca 12 22 f0 	movw   $0x8,0xf02212ca
f0103c4b:	08 00 
f0103c4d:	c6 05 cc 12 22 f0 00 	movb   $0x0,0xf02212cc
f0103c54:	c6 05 cd 12 22 f0 8e 	movb   $0x8e,0xf02212cd
f0103c5b:	c1 e8 10             	shr    $0x10,%eax
f0103c5e:	66 a3 ce 12 22 f0    	mov    %ax,0xf02212ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, F_PGFLT_G, 0);
f0103c64:	b8 f4 43 10 f0       	mov    $0xf01043f4,%eax
f0103c69:	66 a3 d0 12 22 f0    	mov    %ax,0xf02212d0
f0103c6f:	66 c7 05 d2 12 22 f0 	movw   $0x8,0xf02212d2
f0103c76:	08 00 
f0103c78:	c6 05 d4 12 22 f0 00 	movb   $0x0,0xf02212d4
f0103c7f:	c6 05 d5 12 22 f0 8e 	movb   $0x8e,0xf02212d5
f0103c86:	c1 e8 10             	shr    $0x10,%eax
f0103c89:	66 a3 d6 12 22 f0    	mov    %ax,0xf02212d6
	SETGATE(idt[T_FPERR], 0, GD_KT, F_FPERR_G, 0);
f0103c8f:	b8 d8 43 10 f0       	mov    $0xf01043d8,%eax
f0103c94:	66 a3 e0 12 22 f0    	mov    %ax,0xf02212e0
f0103c9a:	66 c7 05 e2 12 22 f0 	movw   $0x8,0xf02212e2
f0103ca1:	08 00 
f0103ca3:	c6 05 e4 12 22 f0 00 	movb   $0x0,0xf02212e4
f0103caa:	c6 05 e5 12 22 f0 8e 	movb   $0x8e,0xf02212e5
f0103cb1:	c1 e8 10             	shr    $0x10,%eax
f0103cb4:	66 a3 e6 12 22 f0    	mov    %ax,0xf02212e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, F_ALIGN_G, 0);
f0103cba:	b8 f0 43 10 f0       	mov    $0xf01043f0,%eax
f0103cbf:	66 a3 e8 12 22 f0    	mov    %ax,0xf02212e8
f0103cc5:	66 c7 05 ea 12 22 f0 	movw   $0x8,0xf02212ea
f0103ccc:	08 00 
f0103cce:	c6 05 ec 12 22 f0 00 	movb   $0x0,0xf02212ec
f0103cd5:	c6 05 ed 12 22 f0 8e 	movb   $0x8e,0xf02212ed
f0103cdc:	c1 e8 10             	shr    $0x10,%eax
f0103cdf:	66 a3 ee 12 22 f0    	mov    %ax,0xf02212ee
	SETGATE(idt[T_MCHK], 0, GD_KT, F_MCHK_G, 0);
f0103ce5:	b8 e6 43 10 f0       	mov    $0xf01043e6,%eax
f0103cea:	66 a3 f0 12 22 f0    	mov    %ax,0xf02212f0
f0103cf0:	66 c7 05 f2 12 22 f0 	movw   $0x8,0xf02212f2
f0103cf7:	08 00 
f0103cf9:	c6 05 f4 12 22 f0 00 	movb   $0x0,0xf02212f4
f0103d00:	c6 05 f5 12 22 f0 8e 	movb   $0x8e,0xf02212f5
f0103d07:	c1 e8 10             	shr    $0x10,%eax
f0103d0a:	66 a3 f6 12 22 f0    	mov    %ax,0xf02212f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, F_SIMDERR_G, 0);
f0103d10:	b8 fc 43 10 f0       	mov    $0xf01043fc,%eax
f0103d15:	66 a3 f8 12 22 f0    	mov    %ax,0xf02212f8
f0103d1b:	66 c7 05 fa 12 22 f0 	movw   $0x8,0xf02212fa
f0103d22:	08 00 
f0103d24:	c6 05 fc 12 22 f0 00 	movb   $0x0,0xf02212fc
f0103d2b:	c6 05 fd 12 22 f0 8e 	movb   $0x8e,0xf02212fd
f0103d32:	c1 e8 10             	shr    $0x10,%eax
f0103d35:	66 a3 fe 12 22 f0    	mov    %ax,0xf02212fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, F_SYSCALL_G, 3);
f0103d3b:	b8 02 44 10 f0       	mov    $0xf0104402,%eax
f0103d40:	66 a3 e0 13 22 f0    	mov    %ax,0xf02213e0
f0103d46:	66 c7 05 e2 13 22 f0 	movw   $0x8,0xf02213e2
f0103d4d:	08 00 
f0103d4f:	c6 05 e4 13 22 f0 00 	movb   $0x0,0xf02213e4
f0103d56:	c6 05 e5 13 22 f0 ee 	movb   $0xee,0xf02213e5
f0103d5d:	c1 e8 10             	shr    $0x10,%eax
f0103d60:	66 a3 e6 13 22 f0    	mov    %ax,0xf02213e6
	SETGATE(idt[T_DEFAULT], 0, GD_KT, F_DEFAULT_G, 0);
f0103d66:	b8 08 44 10 f0       	mov    $0xf0104408,%eax
f0103d6b:	66 a3 00 22 22 f0    	mov    %ax,0xf0222200
f0103d71:	66 c7 05 02 22 22 f0 	movw   $0x8,0xf0222202
f0103d78:	08 00 
f0103d7a:	c6 05 04 22 22 f0 00 	movb   $0x0,0xf0222204
f0103d81:	c6 05 05 22 22 f0 8e 	movb   $0x8e,0xf0222205
f0103d88:	c1 e8 10             	shr    $0x10,%eax
f0103d8b:	66 a3 06 22 22 f0    	mov    %ax,0xf0222206
	SETGATE(idt[IRQ_OFFSET], 0, GD_KT, IRQ_NUMBER_1, 0);
f0103d91:	b8 12 44 10 f0       	mov    $0xf0104412,%eax
f0103d96:	66 a3 60 13 22 f0    	mov    %ax,0xf0221360
f0103d9c:	66 c7 05 62 13 22 f0 	movw   $0x8,0xf0221362
f0103da3:	08 00 
f0103da5:	c6 05 64 13 22 f0 00 	movb   $0x0,0xf0221364
f0103dac:	c6 05 65 13 22 f0 8e 	movb   $0x8e,0xf0221365
f0103db3:	c1 e8 10             	shr    $0x10,%eax
f0103db6:	66 a3 66 13 22 f0    	mov    %ax,0xf0221366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, IRQ_NUMBER_2, 0);
f0103dbc:	b8 18 44 10 f0       	mov    $0xf0104418,%eax
f0103dc1:	66 a3 68 13 22 f0    	mov    %ax,0xf0221368
f0103dc7:	66 c7 05 6a 13 22 f0 	movw   $0x8,0xf022136a
f0103dce:	08 00 
f0103dd0:	c6 05 6c 13 22 f0 00 	movb   $0x0,0xf022136c
f0103dd7:	c6 05 6d 13 22 f0 8e 	movb   $0x8e,0xf022136d
f0103dde:	c1 e8 10             	shr    $0x10,%eax
f0103de1:	66 a3 6e 13 22 f0    	mov    %ax,0xf022136e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, IRQ_NUMBER_3, 0);
f0103de7:	b8 1e 44 10 f0       	mov    $0xf010441e,%eax
f0103dec:	66 a3 80 13 22 f0    	mov    %ax,0xf0221380
f0103df2:	66 c7 05 82 13 22 f0 	movw   $0x8,0xf0221382
f0103df9:	08 00 
f0103dfb:	c6 05 84 13 22 f0 00 	movb   $0x0,0xf0221384
f0103e02:	c6 05 85 13 22 f0 8e 	movb   $0x8e,0xf0221385
f0103e09:	c1 e8 10             	shr    $0x10,%eax
f0103e0c:	66 a3 86 13 22 f0    	mov    %ax,0xf0221386
	trap_init_percpu();
f0103e12:	e8 6b fb ff ff       	call   f0103982 <trap_init_percpu>
}
f0103e17:	c9                   	leave  
f0103e18:	c3                   	ret    

f0103e19 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103e19:	f3 0f 1e fb          	endbr32 
f0103e1d:	55                   	push   %ebp
f0103e1e:	89 e5                	mov    %esp,%ebp
f0103e20:	53                   	push   %ebx
f0103e21:	83 ec 0c             	sub    $0xc,%esp
f0103e24:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e27:	ff 33                	pushl  (%ebx)
f0103e29:	68 a3 78 10 f0       	push   $0xf01078a3
f0103e2e:	e8 dd fa ff ff       	call   f0103910 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e33:	83 c4 08             	add    $0x8,%esp
f0103e36:	ff 73 04             	pushl  0x4(%ebx)
f0103e39:	68 b2 78 10 f0       	push   $0xf01078b2
f0103e3e:	e8 cd fa ff ff       	call   f0103910 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e43:	83 c4 08             	add    $0x8,%esp
f0103e46:	ff 73 08             	pushl  0x8(%ebx)
f0103e49:	68 c1 78 10 f0       	push   $0xf01078c1
f0103e4e:	e8 bd fa ff ff       	call   f0103910 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e53:	83 c4 08             	add    $0x8,%esp
f0103e56:	ff 73 0c             	pushl  0xc(%ebx)
f0103e59:	68 d0 78 10 f0       	push   $0xf01078d0
f0103e5e:	e8 ad fa ff ff       	call   f0103910 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e63:	83 c4 08             	add    $0x8,%esp
f0103e66:	ff 73 10             	pushl  0x10(%ebx)
f0103e69:	68 df 78 10 f0       	push   $0xf01078df
f0103e6e:	e8 9d fa ff ff       	call   f0103910 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e73:	83 c4 08             	add    $0x8,%esp
f0103e76:	ff 73 14             	pushl  0x14(%ebx)
f0103e79:	68 ee 78 10 f0       	push   $0xf01078ee
f0103e7e:	e8 8d fa ff ff       	call   f0103910 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e83:	83 c4 08             	add    $0x8,%esp
f0103e86:	ff 73 18             	pushl  0x18(%ebx)
f0103e89:	68 fd 78 10 f0       	push   $0xf01078fd
f0103e8e:	e8 7d fa ff ff       	call   f0103910 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103e93:	83 c4 08             	add    $0x8,%esp
f0103e96:	ff 73 1c             	pushl  0x1c(%ebx)
f0103e99:	68 0c 79 10 f0       	push   $0xf010790c
f0103e9e:	e8 6d fa ff ff       	call   f0103910 <cprintf>
}
f0103ea3:	83 c4 10             	add    $0x10,%esp
f0103ea6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103ea9:	c9                   	leave  
f0103eaa:	c3                   	ret    

f0103eab <print_trapframe>:
{
f0103eab:	f3 0f 1e fb          	endbr32 
f0103eaf:	55                   	push   %ebp
f0103eb0:	89 e5                	mov    %esp,%ebp
f0103eb2:	56                   	push   %esi
f0103eb3:	53                   	push   %ebx
f0103eb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103eb7:	e8 34 20 00 00       	call   f0105ef0 <cpunum>
f0103ebc:	83 ec 04             	sub    $0x4,%esp
f0103ebf:	50                   	push   %eax
f0103ec0:	53                   	push   %ebx
f0103ec1:	68 42 79 10 f0       	push   $0xf0107942
f0103ec6:	e8 45 fa ff ff       	call   f0103910 <cprintf>
	print_regs(&tf->tf_regs);
f0103ecb:	89 1c 24             	mov    %ebx,(%esp)
f0103ece:	e8 46 ff ff ff       	call   f0103e19 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103ed3:	83 c4 08             	add    $0x8,%esp
f0103ed6:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103eda:	50                   	push   %eax
f0103edb:	68 60 79 10 f0       	push   $0xf0107960
f0103ee0:	e8 2b fa ff ff       	call   f0103910 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ee5:	83 c4 08             	add    $0x8,%esp
f0103ee8:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103eec:	50                   	push   %eax
f0103eed:	68 73 79 10 f0       	push   $0xf0107973
f0103ef2:	e8 19 fa ff ff       	call   f0103910 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ef7:	8b 73 28             	mov    0x28(%ebx),%esi
f0103efa:	89 f0                	mov    %esi,%eax
f0103efc:	e8 3e fa ff ff       	call   f010393f <trapname>
f0103f01:	83 c4 0c             	add    $0xc,%esp
f0103f04:	50                   	push   %eax
f0103f05:	56                   	push   %esi
f0103f06:	68 86 79 10 f0       	push   $0xf0107986
f0103f0b:	e8 00 fa ff ff       	call   f0103910 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f10:	83 c4 10             	add    $0x10,%esp
f0103f13:	39 1d 60 1a 22 f0    	cmp    %ebx,0xf0221a60
f0103f19:	0f 84 9f 00 00 00    	je     f0103fbe <print_trapframe+0x113>
	cprintf("  err  0x%08x", tf->tf_err);
f0103f1f:	83 ec 08             	sub    $0x8,%esp
f0103f22:	ff 73 2c             	pushl  0x2c(%ebx)
f0103f25:	68 a7 79 10 f0       	push   $0xf01079a7
f0103f2a:	e8 e1 f9 ff ff       	call   f0103910 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103f2f:	83 c4 10             	add    $0x10,%esp
f0103f32:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f36:	0f 85 a7 00 00 00    	jne    f0103fe3 <print_trapframe+0x138>
		        tf->tf_err & 1 ? "protection" : "not-present");
f0103f3c:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103f3f:	a8 01                	test   $0x1,%al
f0103f41:	b9 1b 79 10 f0       	mov    $0xf010791b,%ecx
f0103f46:	ba 26 79 10 f0       	mov    $0xf0107926,%edx
f0103f4b:	0f 44 ca             	cmove  %edx,%ecx
f0103f4e:	a8 02                	test   $0x2,%al
f0103f50:	be 32 79 10 f0       	mov    $0xf0107932,%esi
f0103f55:	ba 38 79 10 f0       	mov    $0xf0107938,%edx
f0103f5a:	0f 45 d6             	cmovne %esi,%edx
f0103f5d:	a8 04                	test   $0x4,%al
f0103f5f:	b8 3d 79 10 f0       	mov    $0xf010793d,%eax
f0103f64:	be 6c 7a 10 f0       	mov    $0xf0107a6c,%esi
f0103f69:	0f 44 c6             	cmove  %esi,%eax
f0103f6c:	51                   	push   %ecx
f0103f6d:	52                   	push   %edx
f0103f6e:	50                   	push   %eax
f0103f6f:	68 b5 79 10 f0       	push   $0xf01079b5
f0103f74:	e8 97 f9 ff ff       	call   f0103910 <cprintf>
f0103f79:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103f7c:	83 ec 08             	sub    $0x8,%esp
f0103f7f:	ff 73 30             	pushl  0x30(%ebx)
f0103f82:	68 c4 79 10 f0       	push   $0xf01079c4
f0103f87:	e8 84 f9 ff ff       	call   f0103910 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103f8c:	83 c4 08             	add    $0x8,%esp
f0103f8f:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103f93:	50                   	push   %eax
f0103f94:	68 d3 79 10 f0       	push   $0xf01079d3
f0103f99:	e8 72 f9 ff ff       	call   f0103910 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103f9e:	83 c4 08             	add    $0x8,%esp
f0103fa1:	ff 73 38             	pushl  0x38(%ebx)
f0103fa4:	68 e6 79 10 f0       	push   $0xf01079e6
f0103fa9:	e8 62 f9 ff ff       	call   f0103910 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103fae:	83 c4 10             	add    $0x10,%esp
f0103fb1:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103fb5:	75 3e                	jne    f0103ff5 <print_trapframe+0x14a>
}
f0103fb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103fba:	5b                   	pop    %ebx
f0103fbb:	5e                   	pop    %esi
f0103fbc:	5d                   	pop    %ebp
f0103fbd:	c3                   	ret    
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103fbe:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103fc2:	0f 85 57 ff ff ff    	jne    f0103f1f <print_trapframe+0x74>
		cprintf("  cr2  0x%08x\n", rcr2());
f0103fc8:	e8 63 f9 ff ff       	call   f0103930 <rcr2>
f0103fcd:	83 ec 08             	sub    $0x8,%esp
f0103fd0:	50                   	push   %eax
f0103fd1:	68 98 79 10 f0       	push   $0xf0107998
f0103fd6:	e8 35 f9 ff ff       	call   f0103910 <cprintf>
f0103fdb:	83 c4 10             	add    $0x10,%esp
f0103fde:	e9 3c ff ff ff       	jmp    f0103f1f <print_trapframe+0x74>
		cprintf("\n");
f0103fe3:	83 ec 0c             	sub    $0xc,%esp
f0103fe6:	68 bf 77 10 f0       	push   $0xf01077bf
f0103feb:	e8 20 f9 ff ff       	call   f0103910 <cprintf>
f0103ff0:	83 c4 10             	add    $0x10,%esp
f0103ff3:	eb 87                	jmp    f0103f7c <print_trapframe+0xd1>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103ff5:	83 ec 08             	sub    $0x8,%esp
f0103ff8:	ff 73 3c             	pushl  0x3c(%ebx)
f0103ffb:	68 f5 79 10 f0       	push   $0xf01079f5
f0104000:	e8 0b f9 ff ff       	call   f0103910 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104005:	83 c4 08             	add    $0x8,%esp
f0104008:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010400c:	50                   	push   %eax
f010400d:	68 04 7a 10 f0       	push   $0xf0107a04
f0104012:	e8 f9 f8 ff ff       	call   f0103910 <cprintf>
f0104017:	83 c4 10             	add    $0x10,%esp
}
f010401a:	eb 9b                	jmp    f0103fb7 <print_trapframe+0x10c>

f010401c <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010401c:	f3 0f 1e fb          	endbr32 
f0104020:	55                   	push   %ebp
f0104021:	89 e5                	mov    %esp,%ebp
f0104023:	57                   	push   %edi
f0104024:	56                   	push   %esi
f0104025:	53                   	push   %ebx
f0104026:	83 ec 0c             	sub    $0xc,%esp
f0104029:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
f010402c:	e8 ff f8 ff ff       	call   f0103930 <rcr2>

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs) == 0) {
f0104031:	66 83 7b 34 00       	cmpw   $0x0,0x34(%ebx)
f0104036:	75 17                	jne    f010404f <page_fault_handler+0x33>
		panic("Page fault in Kernel Mode");
f0104038:	83 ec 04             	sub    $0x4,%esp
f010403b:	68 17 7a 10 f0       	push   $0xf0107a17
f0104040:	68 6b 01 00 00       	push   $0x16b
f0104045:	68 31 7a 10 f0       	push   $0xf0107a31
f010404a:	e8 1b c0 ff ff       	call   f010006a <_panic>
f010404f:	89 c6                	mov    %eax,%esi
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if (curenv->env_pgfault_upcall == NULL) {
f0104051:	e8 9a 1e 00 00       	call   f0105ef0 <cpunum>
f0104056:	6b c0 74             	imul   $0x74,%eax,%eax
f0104059:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010405f:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104063:	0f 84 9d 00 00 00    	je     f0104106 <page_fault_handler+0xea>
		print_trapframe(tf);
		env_destroy(curenv);
	}

	struct UTrapframe *utf = NULL;
	uint32_t cur_esp = tf->tf_esp;
f0104069:	8b 43 3c             	mov    0x3c(%ebx),%eax

	if (cur_esp < USTACKTOP && cur_esp >= USTACKTOP - PGSIZE) {
f010406c:	8d 90 00 30 40 11    	lea    0x11403000(%eax),%edx
		utf = (struct UTrapframe *) (UXSTACKTOP -
f0104072:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
	if (cur_esp < USTACKTOP && cur_esp >= USTACKTOP - PGSIZE) {
f0104077:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010407d:	76 18                	jbe    f0104097 <page_fault_handler+0x7b>
		                             sizeof(struct UTrapframe));
	} else if (cur_esp >= (UXSTACKTOP - PGSIZE) && cur_esp < UXSTACKTOP) {
f010407f:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
	struct UTrapframe *utf = NULL;
f0104085:	bf 00 00 00 00       	mov    $0x0,%edi
	} else if (cur_esp >= (UXSTACKTOP - PGSIZE) && cur_esp < UXSTACKTOP) {
f010408a:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104090:	77 05                	ja     f0104097 <page_fault_handler+0x7b>
		utf = (struct UTrapframe *) (cur_esp - 4 -
f0104092:	83 e8 38             	sub    $0x38,%eax
f0104095:	89 c7                	mov    %eax,%edi
		                             sizeof(struct UTrapframe));
	}

	user_mem_assert(
	        curenv, (void *) utf, sizeof(struct UTrapframe), PTE_U | PTE_W);
f0104097:	e8 54 1e 00 00       	call   f0105ef0 <cpunum>
	user_mem_assert(
f010409c:	6a 06                	push   $0x6
f010409e:	6a 34                	push   $0x34
f01040a0:	57                   	push   %edi
f01040a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01040a4:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f01040aa:	e8 f9 ed ff ff       	call   f0102ea8 <user_mem_assert>

	utf->utf_fault_va = fault_va;
f01040af:	89 fa                	mov    %edi,%edx
f01040b1:	89 37                	mov    %esi,(%edi)
	utf->utf_err = tf->tf_err;
f01040b3:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01040b6:	89 47 04             	mov    %eax,0x4(%edi)
	utf->utf_regs = tf->tf_regs;
f01040b9:	8d 7f 08             	lea    0x8(%edi),%edi
f01040bc:	b9 08 00 00 00       	mov    $0x8,%ecx
f01040c1:	89 de                	mov    %ebx,%esi
f01040c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	utf->utf_eip = tf->tf_eip;
f01040c5:	8b 43 30             	mov    0x30(%ebx),%eax
f01040c8:	89 d7                	mov    %edx,%edi
f01040ca:	89 42 28             	mov    %eax,0x28(%edx)
	utf->utf_eflags = tf->tf_eflags;
f01040cd:	8b 43 38             	mov    0x38(%ebx),%eax
f01040d0:	89 42 2c             	mov    %eax,0x2c(%edx)
	utf->utf_esp = tf->tf_esp;
f01040d3:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01040d6:	89 42 30             	mov    %eax,0x30(%edx)

	tf->tf_eip = (uint32_t) curenv->env_pgfault_upcall;
f01040d9:	e8 12 1e 00 00       	call   f0105ef0 <cpunum>
f01040de:	6b c0 74             	imul   $0x74,%eax,%eax
f01040e1:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f01040e7:	8b 40 64             	mov    0x64(%eax),%eax
f01040ea:	89 43 30             	mov    %eax,0x30(%ebx)
	tf->tf_esp = (uint32_t) utf;
f01040ed:	89 7b 3c             	mov    %edi,0x3c(%ebx)
	env_run(curenv);
f01040f0:	e8 fb 1d 00 00       	call   f0105ef0 <cpunum>
f01040f5:	83 c4 04             	add    $0x4,%esp
f01040f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01040fb:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f0104101:	e8 0b f5 ff ff       	call   f0103611 <env_run>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104106:	8b 7b 30             	mov    0x30(%ebx),%edi
		        curenv->env_id,
f0104109:	e8 e2 1d 00 00       	call   f0105ef0 <cpunum>
		cprintf("[%08x] user fault va %08x ip %08x\n",
f010410e:	57                   	push   %edi
f010410f:	56                   	push   %esi
		        curenv->env_id,
f0104110:	6b c0 74             	imul   $0x74,%eax,%eax
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0104113:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104119:	ff 70 48             	pushl  0x48(%eax)
f010411c:	68 d8 7b 10 f0       	push   $0xf0107bd8
f0104121:	e8 ea f7 ff ff       	call   f0103910 <cprintf>
		print_trapframe(tf);
f0104126:	89 1c 24             	mov    %ebx,(%esp)
f0104129:	e8 7d fd ff ff       	call   f0103eab <print_trapframe>
		env_destroy(curenv);
f010412e:	e8 bd 1d 00 00       	call   f0105ef0 <cpunum>
f0104133:	83 c4 04             	add    $0x4,%esp
f0104136:	6b c0 74             	imul   $0x74,%eax,%eax
f0104139:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f010413f:	e8 26 f4 ff ff       	call   f010356a <env_destroy>
f0104144:	83 c4 10             	add    $0x10,%esp
f0104147:	e9 1d ff ff ff       	jmp    f0104069 <page_fault_handler+0x4d>

f010414c <trap_dispatch>:
{
f010414c:	55                   	push   %ebp
f010414d:	89 e5                	mov    %esp,%ebp
f010414f:	53                   	push   %ebx
f0104150:	83 ec 04             	sub    $0x4,%esp
f0104153:	89 c3                	mov    %eax,%ebx
	switch (tf->tf_trapno) {
f0104155:	8b 40 28             	mov    0x28(%eax),%eax
f0104158:	83 f8 0e             	cmp    $0xe,%eax
f010415b:	74 71                	je     f01041ce <trap_dispatch+0x82>
f010415d:	83 f8 30             	cmp    $0x30,%eax
f0104160:	74 75                	je     f01041d7 <trap_dispatch+0x8b>
f0104162:	83 f8 03             	cmp    $0x3,%eax
f0104165:	74 56                	je     f01041bd <trap_dispatch+0x71>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104167:	83 f8 27             	cmp    $0x27,%eax
f010416a:	0f 84 88 00 00 00    	je     f01041f8 <trap_dispatch+0xac>
	if (tf->tf_trapno == IRQ_OFFSET) {
f0104170:	83 f8 20             	cmp    $0x20,%eax
f0104173:	0f 84 99 00 00 00    	je     f0104212 <trap_dispatch+0xc6>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
f0104179:	83 f8 21             	cmp    $0x21,%eax
f010417c:	0f 84 9a 00 00 00    	je     f010421c <trap_dispatch+0xd0>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
f0104182:	83 f8 24             	cmp    $0x24,%eax
f0104185:	0f 84 98 00 00 00    	je     f0104223 <trap_dispatch+0xd7>
	print_trapframe(tf);
f010418b:	83 ec 0c             	sub    $0xc,%esp
f010418e:	53                   	push   %ebx
f010418f:	e8 17 fd ff ff       	call   f0103eab <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104194:	83 c4 10             	add    $0x10,%esp
f0104197:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f010419c:	0f 84 88 00 00 00    	je     f010422a <trap_dispatch+0xde>
		env_destroy(curenv);
f01041a2:	e8 49 1d 00 00       	call   f0105ef0 <cpunum>
f01041a7:	83 ec 0c             	sub    $0xc,%esp
f01041aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01041ad:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f01041b3:	e8 b2 f3 ff ff       	call   f010356a <env_destroy>
		return;
f01041b8:	83 c4 10             	add    $0x10,%esp
f01041bb:	eb 0c                	jmp    f01041c9 <trap_dispatch+0x7d>
		monitor(tf);
f01041bd:	83 ec 0c             	sub    $0xc,%esp
f01041c0:	53                   	push   %ebx
f01041c1:	e8 ad c9 ff ff       	call   f0100b73 <monitor>
		return;
f01041c6:	83 c4 10             	add    $0x10,%esp
}
f01041c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01041cc:	c9                   	leave  
f01041cd:	c3                   	ret    
		page_fault_handler(tf);
f01041ce:	83 ec 0c             	sub    $0xc,%esp
f01041d1:	53                   	push   %ebx
f01041d2:	e8 45 fe ff ff       	call   f010401c <page_fault_handler>
		tf->tf_regs.reg_eax = syscall(
f01041d7:	83 ec 08             	sub    $0x8,%esp
f01041da:	ff 73 04             	pushl  0x4(%ebx)
f01041dd:	ff 33                	pushl  (%ebx)
f01041df:	ff 73 10             	pushl  0x10(%ebx)
f01041e2:	ff 73 18             	pushl  0x18(%ebx)
f01041e5:	ff 73 14             	pushl  0x14(%ebx)
f01041e8:	ff 73 1c             	pushl  0x1c(%ebx)
f01041eb:	e8 f2 09 00 00       	call   f0104be2 <syscall>
f01041f0:	89 43 1c             	mov    %eax,0x1c(%ebx)
		return;
f01041f3:	83 c4 20             	add    $0x20,%esp
f01041f6:	eb d1                	jmp    f01041c9 <trap_dispatch+0x7d>
		cprintf("Spurious interrupt on irq 7\n");
f01041f8:	83 ec 0c             	sub    $0xc,%esp
f01041fb:	68 3d 7a 10 f0       	push   $0xf0107a3d
f0104200:	e8 0b f7 ff ff       	call   f0103910 <cprintf>
		print_trapframe(tf);
f0104205:	89 1c 24             	mov    %ebx,(%esp)
f0104208:	e8 9e fc ff ff       	call   f0103eab <print_trapframe>
		return;
f010420d:	83 c4 10             	add    $0x10,%esp
f0104210:	eb b7                	jmp    f01041c9 <trap_dispatch+0x7d>
		lapic_eoi();
f0104212:	e8 28 1e 00 00       	call   f010603f <lapic_eoi>
		sched_yield();
f0104217:	e8 13 03 00 00       	call   f010452f <sched_yield>
		kbd_intr();
f010421c:	e8 68 c6 ff ff       	call   f0100889 <kbd_intr>
		return;
f0104221:	eb a6                	jmp    f01041c9 <trap_dispatch+0x7d>
		serial_intr();
f0104223:	e8 41 c6 ff ff       	call   f0100869 <serial_intr>
		return;
f0104228:	eb 9f                	jmp    f01041c9 <trap_dispatch+0x7d>
		panic("unhandled trap in kernel");
f010422a:	83 ec 04             	sub    $0x4,%esp
f010422d:	68 5a 7a 10 f0       	push   $0xf0107a5a
f0104232:	68 1b 01 00 00       	push   $0x11b
f0104237:	68 31 7a 10 f0       	push   $0xf0107a31
f010423c:	e8 29 be ff ff       	call   f010006a <_panic>

f0104241 <trap>:
{
f0104241:	f3 0f 1e fb          	endbr32 
f0104245:	55                   	push   %ebp
f0104246:	89 e5                	mov    %esp,%ebp
f0104248:	57                   	push   %edi
f0104249:	56                   	push   %esi
f010424a:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f010424d:	fc                   	cld    
	if (panicstr)
f010424e:	83 3d 80 2e 22 f0 00 	cmpl   $0x0,0xf0222e80
f0104255:	74 01                	je     f0104258 <trap+0x17>
		asm volatile("hlt");
f0104257:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104258:	e8 93 1c 00 00       	call   f0105ef0 <cpunum>
f010425d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104260:	05 24 30 22 f0       	add    $0xf0223024,%eax
f0104265:	ba 01 00 00 00       	mov    $0x1,%edx
f010426a:	e8 c8 f6 ff ff       	call   f0103937 <xchg>
f010426f:	83 f8 02             	cmp    $0x2,%eax
f0104272:	74 52                	je     f01042c6 <trap+0x85>
	assert(!(read_eflags() & FL_IF));
f0104274:	e8 bb f6 ff ff       	call   f0103934 <read_eflags>
f0104279:	f6 c4 02             	test   $0x2,%ah
f010427c:	75 4f                	jne    f01042cd <trap+0x8c>
	if ((tf->tf_cs & 3) == 3) {
f010427e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104282:	83 e0 03             	and    $0x3,%eax
f0104285:	66 83 f8 03          	cmp    $0x3,%ax
f0104289:	74 5b                	je     f01042e6 <trap+0xa5>
	last_tf = tf;
f010428b:	89 35 60 1a 22 f0    	mov    %esi,0xf0221a60
	trap_dispatch(tf);
f0104291:	89 f0                	mov    %esi,%eax
f0104293:	e8 b4 fe ff ff       	call   f010414c <trap_dispatch>
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104298:	e8 53 1c 00 00       	call   f0105ef0 <cpunum>
f010429d:	6b c0 74             	imul   $0x74,%eax,%eax
f01042a0:	83 b8 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%eax)
f01042a7:	74 18                	je     f01042c1 <trap+0x80>
f01042a9:	e8 42 1c 00 00       	call   f0105ef0 <cpunum>
f01042ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01042b1:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f01042b7:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01042bb:	0f 84 bf 00 00 00    	je     f0104380 <trap+0x13f>
		sched_yield();
f01042c1:	e8 69 02 00 00       	call   f010452f <sched_yield>
		lock_kernel();
f01042c6:	e8 a2 f6 ff ff       	call   f010396d <lock_kernel>
f01042cb:	eb a7                	jmp    f0104274 <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f01042cd:	68 73 7a 10 f0       	push   $0xf0107a73
f01042d2:	68 fb 74 10 f0       	push   $0xf01074fb
f01042d7:	68 35 01 00 00       	push   $0x135
f01042dc:	68 31 7a 10 f0       	push   $0xf0107a31
f01042e1:	e8 84 bd ff ff       	call   f010006a <_panic>
		lock_kernel();
f01042e6:	e8 82 f6 ff ff       	call   f010396d <lock_kernel>
		assert(curenv);
f01042eb:	e8 00 1c 00 00       	call   f0105ef0 <cpunum>
f01042f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01042f3:	83 b8 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%eax)
f01042fa:	74 3e                	je     f010433a <trap+0xf9>
		if (curenv->env_status == ENV_DYING) {
f01042fc:	e8 ef 1b 00 00       	call   f0105ef0 <cpunum>
f0104301:	6b c0 74             	imul   $0x74,%eax,%eax
f0104304:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010430a:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010430e:	74 43                	je     f0104353 <trap+0x112>
		curenv->env_tf = *tf;
f0104310:	e8 db 1b 00 00       	call   f0105ef0 <cpunum>
f0104315:	6b c0 74             	imul   $0x74,%eax,%eax
f0104318:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010431e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104323:	89 c7                	mov    %eax,%edi
f0104325:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104327:	e8 c4 1b 00 00       	call   f0105ef0 <cpunum>
f010432c:	6b c0 74             	imul   $0x74,%eax,%eax
f010432f:	8b b0 28 30 22 f0    	mov    -0xfddcfd8(%eax),%esi
f0104335:	e9 51 ff ff ff       	jmp    f010428b <trap+0x4a>
		assert(curenv);
f010433a:	68 8c 7a 10 f0       	push   $0xf0107a8c
f010433f:	68 fb 74 10 f0       	push   $0xf01074fb
f0104344:	68 3d 01 00 00       	push   $0x13d
f0104349:	68 31 7a 10 f0       	push   $0xf0107a31
f010434e:	e8 17 bd ff ff       	call   f010006a <_panic>
			env_free(curenv);
f0104353:	e8 98 1b 00 00       	call   f0105ef0 <cpunum>
f0104358:	83 ec 0c             	sub    $0xc,%esp
f010435b:	6b c0 74             	imul   $0x74,%eax,%eax
f010435e:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f0104364:	e8 a8 f0 ff ff       	call   f0103411 <env_free>
			curenv = NULL;
f0104369:	e8 82 1b 00 00       	call   f0105ef0 <cpunum>
f010436e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104371:	c7 80 28 30 22 f0 00 	movl   $0x0,-0xfddcfd8(%eax)
f0104378:	00 00 00 
			sched_yield();
f010437b:	e8 af 01 00 00       	call   f010452f <sched_yield>
		env_run(curenv);
f0104380:	e8 6b 1b 00 00       	call   f0105ef0 <cpunum>
f0104385:	83 ec 0c             	sub    $0xc,%esp
f0104388:	6b c0 74             	imul   $0x74,%eax,%eax
f010438b:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f0104391:	e8 7b f2 ff ff       	call   f0103611 <env_run>

f0104396 <F_DIVIDE_G>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(F_DIVIDE_G, T_DIVIDE);
f0104396:	6a 00                	push   $0x0
f0104398:	6a 00                	push   $0x0
f010439a:	e9 85 00 00 00       	jmp    f0104424 <_alltraps>
f010439f:	90                   	nop

f01043a0 <F_DEBUG_G>:
TRAPHANDLER_NOEC(F_DEBUG_G, T_DEBUG);
f01043a0:	6a 00                	push   $0x0
f01043a2:	6a 01                	push   $0x1
f01043a4:	eb 7e                	jmp    f0104424 <_alltraps>

f01043a6 <F_NMI_G>:
TRAPHANDLER_NOEC(F_NMI_G, T_NMI);
f01043a6:	6a 00                	push   $0x0
f01043a8:	6a 02                	push   $0x2
f01043aa:	eb 78                	jmp    f0104424 <_alltraps>

f01043ac <F_BRKPT_G>:
TRAPHANDLER_NOEC(F_BRKPT_G, T_BRKPT);
f01043ac:	6a 00                	push   $0x0
f01043ae:	6a 03                	push   $0x3
f01043b0:	eb 72                	jmp    f0104424 <_alltraps>

f01043b2 <F_OFLOW_G>:
TRAPHANDLER_NOEC(F_OFLOW_G, T_OFLOW);
f01043b2:	6a 00                	push   $0x0
f01043b4:	6a 04                	push   $0x4
f01043b6:	eb 6c                	jmp    f0104424 <_alltraps>

f01043b8 <F_BOUND_G>:
TRAPHANDLER_NOEC(F_BOUND_G, T_BOUND);
f01043b8:	6a 00                	push   $0x0
f01043ba:	6a 05                	push   $0x5
f01043bc:	eb 66                	jmp    f0104424 <_alltraps>

f01043be <F_ILLOP_G>:
TRAPHANDLER_NOEC(F_ILLOP_G, T_ILLOP);
f01043be:	6a 00                	push   $0x0
f01043c0:	6a 06                	push   $0x6
f01043c2:	eb 60                	jmp    f0104424 <_alltraps>

f01043c4 <F_DEVICE_G>:
TRAPHANDLER_NOEC(F_DEVICE_G, T_DEVICE);
f01043c4:	6a 00                	push   $0x0
f01043c6:	6a 07                	push   $0x7
f01043c8:	eb 5a                	jmp    f0104424 <_alltraps>

f01043ca <F_DBLFLT_G>:
TRAPHANDLER(F_DBLFLT_G, T_DBLFLT)
f01043ca:	6a 08                	push   $0x8
f01043cc:	eb 56                	jmp    f0104424 <_alltraps>

f01043ce <F_COPROC_G>:
TRAPHANDLER(F_COPROC_G, T_COPROC);
f01043ce:	6a 09                	push   $0x9
f01043d0:	eb 52                	jmp    f0104424 <_alltraps>

f01043d2 <F_RES_G>:
TRAPHANDLER_NOEC(F_RES_G, T_RES);
f01043d2:	6a 00                	push   $0x0
f01043d4:	6a 0f                	push   $0xf
f01043d6:	eb 4c                	jmp    f0104424 <_alltraps>

f01043d8 <F_FPERR_G>:
TRAPHANDLER_NOEC(F_FPERR_G, T_FPERR);
f01043d8:	6a 00                	push   $0x0
f01043da:	6a 10                	push   $0x10
f01043dc:	eb 46                	jmp    f0104424 <_alltraps>

f01043de <F_GPFLT_G>:
TRAPHANDLER(F_GPFLT_G, T_GPFLT);
f01043de:	6a 0d                	push   $0xd
f01043e0:	eb 42                	jmp    f0104424 <_alltraps>

f01043e2 <F_TSS_G>:
TRAPHANDLER(F_TSS_G, T_TSS);
f01043e2:	6a 0a                	push   $0xa
f01043e4:	eb 3e                	jmp    f0104424 <_alltraps>

f01043e6 <F_MCHK_G>:
TRAPHANDLER_NOEC(F_MCHK_G, T_MCHK);
f01043e6:	6a 00                	push   $0x0
f01043e8:	6a 12                	push   $0x12
f01043ea:	eb 38                	jmp    f0104424 <_alltraps>

f01043ec <F_SEGNP_G>:
TRAPHANDLER(F_SEGNP_G, T_SEGNP);
f01043ec:	6a 0b                	push   $0xb
f01043ee:	eb 34                	jmp    f0104424 <_alltraps>

f01043f0 <F_ALIGN_G>:
TRAPHANDLER(F_ALIGN_G, T_ALIGN);
f01043f0:	6a 11                	push   $0x11
f01043f2:	eb 30                	jmp    f0104424 <_alltraps>

f01043f4 <F_PGFLT_G>:
TRAPHANDLER(F_PGFLT_G, T_PGFLT);
f01043f4:	6a 0e                	push   $0xe
f01043f6:	eb 2c                	jmp    f0104424 <_alltraps>

f01043f8 <F_STACK_G>:
TRAPHANDLER(F_STACK_G, T_STACK);
f01043f8:	6a 0c                	push   $0xc
f01043fa:	eb 28                	jmp    f0104424 <_alltraps>

f01043fc <F_SIMDERR_G>:
TRAPHANDLER_NOEC(F_SIMDERR_G, T_SIMDERR);
f01043fc:	6a 00                	push   $0x0
f01043fe:	6a 13                	push   $0x13
f0104400:	eb 22                	jmp    f0104424 <_alltraps>

f0104402 <F_SYSCALL_G>:
TRAPHANDLER_NOEC(F_SYSCALL_G, T_SYSCALL)
f0104402:	6a 00                	push   $0x0
f0104404:	6a 30                	push   $0x30
f0104406:	eb 1c                	jmp    f0104424 <_alltraps>

f0104408 <F_DEFAULT_G>:
TRAPHANDLER_NOEC(F_DEFAULT_G, T_DEFAULT)
f0104408:	6a 00                	push   $0x0
f010440a:	68 f4 01 00 00       	push   $0x1f4
f010440f:	eb 13                	jmp    f0104424 <_alltraps>
f0104411:	90                   	nop

f0104412 <IRQ_NUMBER_1>:
TRAPHANDLER_NOEC(IRQ_NUMBER_1, IRQ_OFFSET)
f0104412:	6a 00                	push   $0x0
f0104414:	6a 20                	push   $0x20
f0104416:	eb 0c                	jmp    f0104424 <_alltraps>

f0104418 <IRQ_NUMBER_2>:
TRAPHANDLER_NOEC(IRQ_NUMBER_2, IRQ_OFFSET + IRQ_KBD)
f0104418:	6a 00                	push   $0x0
f010441a:	6a 21                	push   $0x21
f010441c:	eb 06                	jmp    f0104424 <_alltraps>

f010441e <IRQ_NUMBER_3>:
TRAPHANDLER_NOEC(IRQ_NUMBER_3, IRQ_OFFSET + IRQ_SERIAL)
f010441e:	6a 00                	push   $0x0
f0104420:	6a 24                	push   $0x24
f0104422:	eb 00                	jmp    f0104424 <_alltraps>

f0104424 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

 _alltraps:
	pushl %ds
f0104424:	1e                   	push   %ds
	pushl %es
f0104425:	06                   	push   %es
	pushal
f0104426:	60                   	pusha  

	movw $GD_KD, %ax
f0104427:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f010442b:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f010442d:	8e c0                	mov    %eax,%es

	pushl %esp
f010442f:	54                   	push   %esp
f0104430:	e8 0c fe ff ff       	call   f0104241 <trap>

f0104435 <lcr3>:
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104435:	0f 22 d8             	mov    %eax,%cr3
}
f0104438:	c3                   	ret    

f0104439 <xchg>:
{
f0104439:	89 c1                	mov    %eax,%ecx
f010443b:	89 d0                	mov    %edx,%eax
	asm volatile("lock; xchgl %0, %1"
f010443d:	f0 87 01             	lock xchg %eax,(%ecx)
}
f0104440:	c3                   	ret    

f0104441 <_paddr>:
	if ((uint32_t)kva < KERNBASE)
f0104441:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0104447:	76 07                	jbe    f0104450 <_paddr+0xf>
	return (physaddr_t)kva - KERNBASE;
f0104449:	8d 81 00 00 00 10    	lea    0x10000000(%ecx),%eax
}
f010444f:	c3                   	ret    
{
f0104450:	55                   	push   %ebp
f0104451:	89 e5                	mov    %esp,%ebp
f0104453:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104456:	51                   	push   %ecx
f0104457:	68 f0 65 10 f0       	push   $0xf01065f0
f010445c:	52                   	push   %edx
f010445d:	50                   	push   %eax
f010445e:	e8 07 bc ff ff       	call   f010006a <_panic>

f0104463 <unlock_kernel>:
{
f0104463:	55                   	push   %ebp
f0104464:	89 e5                	mov    %esp,%ebp
f0104466:	83 ec 14             	sub    $0x14,%esp
	spin_unlock(&kernel_lock);
f0104469:	68 c0 23 12 f0       	push   $0xf01223c0
f010446e:	e8 e8 1d 00 00       	call   f010625b <spin_unlock>
	asm volatile("pause");
f0104473:	f3 90                	pause  
}
f0104475:	83 c4 10             	add    $0x10,%esp
f0104478:	c9                   	leave  
f0104479:	c3                   	ret    

f010447a <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010447a:	f3 0f 1e fb          	endbr32 
f010447e:	55                   	push   %ebp
f010447f:	89 e5                	mov    %esp,%ebp
f0104481:	83 ec 08             	sub    $0x8,%esp
f0104484:	a1 44 12 22 f0       	mov    0xf0221244,%eax
f0104489:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010448c:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104491:	8b 02                	mov    (%edx),%eax
f0104493:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104496:	83 f8 02             	cmp    $0x2,%eax
f0104499:	76 2d                	jbe    f01044c8 <sched_halt+0x4e>
	for (i = 0; i < NENV; i++) {
f010449b:	83 c1 01             	add    $0x1,%ecx
f010449e:	83 c2 7c             	add    $0x7c,%edx
f01044a1:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01044a7:	75 e8                	jne    f0104491 <sched_halt+0x17>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f01044a9:	83 ec 0c             	sub    $0xc,%esp
f01044ac:	68 50 7c 10 f0       	push   $0xf0107c50
f01044b1:	e8 5a f4 ff ff       	call   f0103910 <cprintf>
f01044b6:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01044b9:	83 ec 0c             	sub    $0xc,%esp
f01044bc:	6a 00                	push   $0x0
f01044be:	e8 b0 c6 ff ff       	call   f0100b73 <monitor>
f01044c3:	83 c4 10             	add    $0x10,%esp
f01044c6:	eb f1                	jmp    f01044b9 <sched_halt+0x3f>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01044c8:	e8 23 1a 00 00       	call   f0105ef0 <cpunum>
f01044cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01044d0:	c7 80 28 30 22 f0 00 	movl   $0x0,-0xfddcfd8(%eax)
f01044d7:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01044da:	8b 0d 8c 2e 22 f0    	mov    0xf0222e8c,%ecx
f01044e0:	ba 49 00 00 00       	mov    $0x49,%edx
f01044e5:	b8 79 7c 10 f0       	mov    $0xf0107c79,%eax
f01044ea:	e8 52 ff ff ff       	call   f0104441 <_paddr>
f01044ef:	e8 41 ff ff ff       	call   f0104435 <lcr3>

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01044f4:	e8 f7 19 00 00       	call   f0105ef0 <cpunum>
f01044f9:	6b c0 74             	imul   $0x74,%eax,%eax
f01044fc:	05 24 30 22 f0       	add    $0xf0223024,%eax
f0104501:	ba 02 00 00 00       	mov    $0x2,%edx
f0104506:	e8 2e ff ff ff       	call   f0104439 <xchg>

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();
f010450b:	e8 53 ff ff ff       	call   f0104463 <unlock_kernel>
	             "sti\n"
	             "1:\n"
	             "hlt\n"
	             "jmp 1b\n"
	             :
	             : "a"(thiscpu->cpu_ts.ts_esp0));
f0104510:	e8 db 19 00 00       	call   f0105ef0 <cpunum>
f0104515:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile("movl $0, %%ebp\n"
f0104518:	8b 80 30 30 22 f0    	mov    -0xfddcfd0(%eax),%eax
f010451e:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104523:	89 c4                	mov    %eax,%esp
f0104525:	6a 00                	push   $0x0
f0104527:	6a 00                	push   $0x0
f0104529:	fb                   	sti    
f010452a:	f4                   	hlt    
f010452b:	eb fd                	jmp    f010452a <sched_halt+0xb0>
}
f010452d:	c9                   	leave  
f010452e:	c3                   	ret    

f010452f <sched_yield>:
{
f010452f:	f3 0f 1e fb          	endbr32 
f0104533:	55                   	push   %ebp
f0104534:	89 e5                	mov    %esp,%ebp
f0104536:	53                   	push   %ebx
f0104537:	83 ec 04             	sub    $0x4,%esp
	int index = (curenv != NULL) ? (curenv - envs + 1) % NENV : 0;
f010453a:	e8 b1 19 00 00       	call   f0105ef0 <cpunum>
f010453f:	6b d0 74             	imul   $0x74,%eax,%edx
f0104542:	b8 00 00 00 00       	mov    $0x0,%eax
f0104547:	83 ba 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%edx)
f010454e:	74 2d                	je     f010457d <sched_yield+0x4e>
f0104550:	e8 9b 19 00 00       	call   f0105ef0 <cpunum>
f0104555:	6b c0 74             	imul   $0x74,%eax,%eax
f0104558:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010455e:	2b 05 44 12 22 f0    	sub    0xf0221244,%eax
f0104564:	c1 f8 02             	sar    $0x2,%eax
f0104567:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
f010456d:	83 c0 01             	add    $0x1,%eax
f0104570:	99                   	cltd   
f0104571:	c1 ea 16             	shr    $0x16,%edx
f0104574:	01 d0                	add    %edx,%eax
f0104576:	25 ff 03 00 00       	and    $0x3ff,%eax
f010457b:	29 d0                	sub    %edx,%eax
		if (envs[index].env_status == ENV_RUNNABLE) {
f010457d:	8b 0d 44 12 22 f0    	mov    0xf0221244,%ecx
f0104583:	ba 00 04 00 00       	mov    $0x400,%edx
f0104588:	6b d8 7c             	imul   $0x7c,%eax,%ebx
f010458b:	01 cb                	add    %ecx,%ebx
f010458d:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0104591:	74 48                	je     f01045db <sched_yield+0xac>
		index = (index + 1) % NENV;
f0104593:	83 c0 01             	add    $0x1,%eax
f0104596:	89 c3                	mov    %eax,%ebx
f0104598:	c1 fb 1f             	sar    $0x1f,%ebx
f010459b:	c1 eb 16             	shr    $0x16,%ebx
f010459e:	01 d8                	add    %ebx,%eax
f01045a0:	25 ff 03 00 00       	and    $0x3ff,%eax
f01045a5:	29 d8                	sub    %ebx,%eax
	for (int j = 0; j < NENV; j++) {
f01045a7:	83 ea 01             	sub    $0x1,%edx
f01045aa:	75 dc                	jne    f0104588 <sched_yield+0x59>
	if (curenv != NULL && curenv->env_status == ENV_RUNNING) {
f01045ac:	e8 3f 19 00 00       	call   f0105ef0 <cpunum>
f01045b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01045b4:	83 b8 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%eax)
f01045bb:	74 14                	je     f01045d1 <sched_yield+0xa2>
f01045bd:	e8 2e 19 00 00       	call   f0105ef0 <cpunum>
f01045c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01045c5:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f01045cb:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01045cf:	74 13                	je     f01045e4 <sched_yield+0xb5>
	sched_halt();
f01045d1:	e8 a4 fe ff ff       	call   f010447a <sched_halt>
}
f01045d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01045d9:	c9                   	leave  
f01045da:	c3                   	ret    
			env_run(&envs[index]);
f01045db:	83 ec 0c             	sub    $0xc,%esp
f01045de:	53                   	push   %ebx
f01045df:	e8 2d f0 ff ff       	call   f0103611 <env_run>
		env_run(curenv);
f01045e4:	e8 07 19 00 00       	call   f0105ef0 <cpunum>
f01045e9:	83 ec 0c             	sub    $0xc,%esp
f01045ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01045ef:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f01045f5:	e8 17 f0 ff ff       	call   f0103611 <env_run>

f01045fa <sys_getenvid>:
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f01045fa:	55                   	push   %ebp
f01045fb:	89 e5                	mov    %esp,%ebp
f01045fd:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f0104600:	e8 eb 18 00 00       	call   f0105ef0 <cpunum>
f0104605:	6b c0 74             	imul   $0x74,%eax,%eax
f0104608:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010460e:	8b 40 48             	mov    0x48(%eax),%eax
}
f0104611:	c9                   	leave  
f0104612:	c3                   	ret    

f0104613 <sys_ipc_recv>:
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
f0104613:	55                   	push   %ebp
f0104614:	89 e5                	mov    %esp,%ebp
f0104616:	53                   	push   %ebx
f0104617:	83 ec 04             	sub    $0x4,%esp
f010461a:	89 c3                	mov    %eax,%ebx
	// LAB 4: Your code here.
	if ((uintptr_t) dstva < UTOP && (((uintptr_t) dstva) % PGSIZE != 0)) {
f010461c:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f0104621:	77 07                	ja     f010462a <sys_ipc_recv+0x17>
f0104623:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0104628:	75 43                	jne    f010466d <sys_ipc_recv+0x5a>
		return -E_INVAL;
	}

	curenv->env_ipc_recving = 1;
f010462a:	e8 c1 18 00 00       	call   f0105ef0 <cpunum>
f010462f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104632:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104638:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f010463c:	e8 af 18 00 00       	call   f0105ef0 <cpunum>
f0104641:	6b c0 74             	imul   $0x74,%eax,%eax
f0104644:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010464a:	89 58 6c             	mov    %ebx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f010464d:	e8 9e 18 00 00       	call   f0105ef0 <cpunum>
f0104652:	6b c0 74             	imul   $0x74,%eax,%eax
f0104655:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010465b:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

	return 0;
f0104662:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104667:	83 c4 04             	add    $0x4,%esp
f010466a:	5b                   	pop    %ebx
f010466b:	5d                   	pop    %ebp
f010466c:	c3                   	ret    
		return -E_INVAL;
f010466d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104672:	eb f3                	jmp    f0104667 <sys_ipc_recv+0x54>

f0104674 <sys_cputs>:
{
f0104674:	55                   	push   %ebp
f0104675:	89 e5                	mov    %esp,%ebp
f0104677:	56                   	push   %esi
f0104678:	53                   	push   %ebx
f0104679:	89 c6                	mov    %eax,%esi
f010467b:	89 d3                	mov    %edx,%ebx
	user_mem_assert(curenv, s, len, PTE_U);
f010467d:	e8 6e 18 00 00       	call   f0105ef0 <cpunum>
f0104682:	6a 04                	push   $0x4
f0104684:	53                   	push   %ebx
f0104685:	56                   	push   %esi
f0104686:	6b c0 74             	imul   $0x74,%eax,%eax
f0104689:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f010468f:	e8 14 e8 ff ff       	call   f0102ea8 <user_mem_assert>
	cprintf("%.*s", len, s);
f0104694:	83 c4 0c             	add    $0xc,%esp
f0104697:	56                   	push   %esi
f0104698:	53                   	push   %ebx
f0104699:	68 86 7c 10 f0       	push   $0xf0107c86
f010469e:	e8 6d f2 ff ff       	call   f0103910 <cprintf>
}
f01046a3:	83 c4 10             	add    $0x10,%esp
f01046a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01046a9:	5b                   	pop    %ebx
f01046aa:	5e                   	pop    %esi
f01046ab:	5d                   	pop    %ebp
f01046ac:	c3                   	ret    

f01046ad <sys_cgetc>:
{
f01046ad:	55                   	push   %ebp
f01046ae:	89 e5                	mov    %esp,%ebp
f01046b0:	83 ec 08             	sub    $0x8,%esp
	return cons_getc();
f01046b3:	e8 0c c2 ff ff       	call   f01008c4 <cons_getc>
}
f01046b8:	c9                   	leave  
f01046b9:	c3                   	ret    

f01046ba <sys_env_set_status>:
{
f01046ba:	55                   	push   %ebp
f01046bb:	89 e5                	mov    %esp,%ebp
f01046bd:	53                   	push   %ebx
f01046be:	83 ec 14             	sub    $0x14,%esp
f01046c1:	89 d3                	mov    %edx,%ebx
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) {
f01046c3:	8d 52 fe             	lea    -0x2(%edx),%edx
f01046c6:	f7 c2 fd ff ff ff    	test   $0xfffffffd,%edx
f01046cc:	75 26                	jne    f01046f4 <sys_env_set_status+0x3a>
	if (envid2env(envid, &env, 1) < 0) {
f01046ce:	83 ec 04             	sub    $0x4,%esp
f01046d1:	6a 01                	push   $0x1
f01046d3:	8d 55 f4             	lea    -0xc(%ebp),%edx
f01046d6:	52                   	push   %edx
f01046d7:	50                   	push   %eax
f01046d8:	e8 af ea ff ff       	call   f010318c <envid2env>
f01046dd:	83 c4 10             	add    $0x10,%esp
f01046e0:	85 c0                	test   %eax,%eax
f01046e2:	78 17                	js     f01046fb <sys_env_set_status+0x41>
	env->env_status = status;
f01046e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01046e7:	89 58 54             	mov    %ebx,0x54(%eax)
	return 0;
f01046ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01046ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01046f2:	c9                   	leave  
f01046f3:	c3                   	ret    
		return -E_INVAL;
f01046f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01046f9:	eb f4                	jmp    f01046ef <sys_env_set_status+0x35>
		return -E_BAD_ENV;
f01046fb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104700:	eb ed                	jmp    f01046ef <sys_env_set_status+0x35>

f0104702 <sys_env_set_pgfault_upcall>:
{
f0104702:	55                   	push   %ebp
f0104703:	89 e5                	mov    %esp,%ebp
f0104705:	53                   	push   %ebx
f0104706:	83 ec 18             	sub    $0x18,%esp
f0104709:	89 d3                	mov    %edx,%ebx
	if (envid2env(envid, &env, 1) < 0) {
f010470b:	6a 01                	push   $0x1
f010470d:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0104710:	52                   	push   %edx
f0104711:	50                   	push   %eax
f0104712:	e8 75 ea ff ff       	call   f010318c <envid2env>
f0104717:	83 c4 10             	add    $0x10,%esp
f010471a:	85 c0                	test   %eax,%eax
f010471c:	78 10                	js     f010472e <sys_env_set_pgfault_upcall+0x2c>
	env->env_pgfault_upcall = func;
f010471e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104721:	89 58 64             	mov    %ebx,0x64(%eax)
	return 0;
f0104724:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104729:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010472c:	c9                   	leave  
f010472d:	c3                   	ret    
		return -E_BAD_ENV;
f010472e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104733:	eb f4                	jmp    f0104729 <sys_env_set_pgfault_upcall+0x27>

f0104735 <sys_env_set_trapframe>:
{
f0104735:	55                   	push   %ebp
f0104736:	89 e5                	mov    %esp,%ebp
f0104738:	57                   	push   %edi
f0104739:	56                   	push   %esi
f010473a:	83 ec 14             	sub    $0x14,%esp
f010473d:	89 d6                	mov    %edx,%esi
	if (envid2env(envid, &env, 1) < 0) {
f010473f:	6a 01                	push   $0x1
f0104741:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0104744:	52                   	push   %edx
f0104745:	50                   	push   %eax
f0104746:	e8 41 ea ff ff       	call   f010318c <envid2env>
f010474b:	83 c4 10             	add    $0x10,%esp
f010474e:	85 c0                	test   %eax,%eax
f0104750:	78 32                	js     f0104784 <sys_env_set_trapframe+0x4f>
	env->env_tf = *tf;
f0104752:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104757:	8b 7d f4             	mov    -0xc(%ebp),%edi
f010475a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	env->env_tf.tf_regs.reg_eax = 0;
f010475c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010475f:	c7 42 1c 00 00 00 00 	movl   $0x0,0x1c(%edx)
	env->env_tf.tf_cs = GD_UT | 3;
f0104766:	66 c7 42 34 1b 00    	movw   $0x1b,0x34(%edx)
	env->env_tf.tf_eflags &= ~FL_IOPL_MASK;
f010476c:	8b 42 38             	mov    0x38(%edx),%eax
f010476f:	80 e4 cf             	and    $0xcf,%ah
f0104772:	80 cc 02             	or     $0x2,%ah
f0104775:	89 42 38             	mov    %eax,0x38(%edx)
	return 0;
f0104778:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010477d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104780:	5e                   	pop    %esi
f0104781:	5f                   	pop    %edi
f0104782:	5d                   	pop    %ebp
f0104783:	c3                   	ret    
		return -E_BAD_ENV;
f0104784:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104789:	eb f2                	jmp    f010477d <sys_env_set_trapframe+0x48>

f010478b <sys_env_destroy>:
{
f010478b:	55                   	push   %ebp
f010478c:	89 e5                	mov    %esp,%ebp
f010478e:	53                   	push   %ebx
f010478f:	83 ec 18             	sub    $0x18,%esp
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104792:	6a 01                	push   $0x1
f0104794:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0104797:	52                   	push   %edx
f0104798:	50                   	push   %eax
f0104799:	e8 ee e9 ff ff       	call   f010318c <envid2env>
f010479e:	83 c4 10             	add    $0x10,%esp
f01047a1:	85 c0                	test   %eax,%eax
f01047a3:	78 4b                	js     f01047f0 <sys_env_destroy+0x65>
	if (e == curenv)
f01047a5:	e8 46 17 00 00       	call   f0105ef0 <cpunum>
f01047aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01047ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01047b0:	39 90 28 30 22 f0    	cmp    %edx,-0xfddcfd8(%eax)
f01047b6:	74 3d                	je     f01047f5 <sys_env_destroy+0x6a>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01047b8:	8b 5a 48             	mov    0x48(%edx),%ebx
f01047bb:	e8 30 17 00 00       	call   f0105ef0 <cpunum>
f01047c0:	83 ec 04             	sub    $0x4,%esp
f01047c3:	53                   	push   %ebx
f01047c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01047c7:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f01047cd:	ff 70 48             	pushl  0x48(%eax)
f01047d0:	68 a6 7c 10 f0       	push   $0xf0107ca6
f01047d5:	e8 36 f1 ff ff       	call   f0103910 <cprintf>
f01047da:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01047dd:	83 ec 0c             	sub    $0xc,%esp
f01047e0:	ff 75 f4             	pushl  -0xc(%ebp)
f01047e3:	e8 82 ed ff ff       	call   f010356a <env_destroy>
	return 0;
f01047e8:	83 c4 10             	add    $0x10,%esp
f01047eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01047f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01047f3:	c9                   	leave  
f01047f4:	c3                   	ret    
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01047f5:	e8 f6 16 00 00       	call   f0105ef0 <cpunum>
f01047fa:	83 ec 08             	sub    $0x8,%esp
f01047fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104800:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104806:	ff 70 48             	pushl  0x48(%eax)
f0104809:	68 8b 7c 10 f0       	push   $0xf0107c8b
f010480e:	e8 fd f0 ff ff       	call   f0103910 <cprintf>
f0104813:	83 c4 10             	add    $0x10,%esp
f0104816:	eb c5                	jmp    f01047dd <sys_env_destroy+0x52>

f0104818 <sys_yield>:
{
f0104818:	55                   	push   %ebp
f0104819:	89 e5                	mov    %esp,%ebp
f010481b:	83 ec 08             	sub    $0x8,%esp
	sched_yield();
f010481e:	e8 0c fd ff ff       	call   f010452f <sched_yield>

f0104823 <sys_exofork>:
{
f0104823:	55                   	push   %ebp
f0104824:	89 e5                	mov    %esp,%ebp
f0104826:	57                   	push   %edi
f0104827:	56                   	push   %esi
f0104828:	83 ec 10             	sub    $0x10,%esp
	int aux = env_alloc(&new_env, curenv->env_id);
f010482b:	e8 c0 16 00 00       	call   f0105ef0 <cpunum>
f0104830:	83 ec 08             	sub    $0x8,%esp
f0104833:	6b c0 74             	imul   $0x74,%eax,%eax
f0104836:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010483c:	ff 70 48             	pushl  0x48(%eax)
f010483f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104842:	50                   	push   %eax
f0104843:	e8 65 ea ff ff       	call   f01032ad <env_alloc>
	if (aux < 0) {
f0104848:	83 c4 10             	add    $0x10,%esp
f010484b:	85 c0                	test   %eax,%eax
f010484d:	78 2f                	js     f010487e <sys_exofork+0x5b>
	new_env->env_status = ENV_NOT_RUNNABLE;
f010484f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104852:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	new_env->env_tf = curenv->env_tf;
f0104859:	e8 92 16 00 00       	call   f0105ef0 <cpunum>
f010485e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104861:	8b b0 28 30 22 f0    	mov    -0xfddcfd8(%eax),%esi
f0104867:	b9 11 00 00 00       	mov    $0x11,%ecx
f010486c:	8b 7d f4             	mov    -0xc(%ebp),%edi
f010486f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	new_env->env_tf.tf_regs.reg_eax = 0;
f0104871:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104874:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return new_env->env_id;
f010487b:	8b 40 48             	mov    0x48(%eax),%eax
}
f010487e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104881:	5e                   	pop    %esi
f0104882:	5f                   	pop    %edi
f0104883:	5d                   	pop    %ebp
f0104884:	c3                   	ret    

f0104885 <sys_page_alloc>:
{
f0104885:	55                   	push   %ebp
f0104886:	89 e5                	mov    %esp,%ebp
f0104888:	57                   	push   %edi
f0104889:	56                   	push   %esi
f010488a:	53                   	push   %ebx
f010488b:	83 ec 30             	sub    $0x30,%esp
f010488e:	89 d3                	mov    %edx,%ebx
f0104890:	89 ce                	mov    %ecx,%esi
	if (envid2env(envid, &env, 1) < 0) {
f0104892:	6a 01                	push   $0x1
f0104894:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104897:	52                   	push   %edx
f0104898:	50                   	push   %eax
f0104899:	e8 ee e8 ff ff       	call   f010318c <envid2env>
f010489e:	83 c4 10             	add    $0x10,%esp
f01048a1:	85 c0                	test   %eax,%eax
f01048a3:	78 69                	js     f010490e <sys_page_alloc+0x89>
	if ((uintptr_t) va >= UTOP || ((uintptr_t) va % PGSIZE) != 0) {
f01048a5:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01048ab:	77 6a                	ja     f0104917 <sys_page_alloc+0x92>
f01048ad:	89 f0                	mov    %esi,%eax
f01048af:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01048b4:	83 f0 05             	xor    $0x5,%eax
f01048b7:	89 da                	mov    %ebx,%edx
f01048b9:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
	if ((perm & ~(PTE_U | PTE_P | PTE_AVAIL | PTE_W)) != 0 ||
f01048bf:	09 d0                	or     %edx,%eax
f01048c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01048c4:	75 5a                	jne    f0104920 <sys_page_alloc+0x9b>
	struct PageInfo *page = page_alloc(ALLOC_ZERO);
f01048c6:	83 ec 0c             	sub    $0xc,%esp
f01048c9:	6a 01                	push   $0x1
f01048cb:	e8 6d c8 ff ff       	call   f010113d <page_alloc>
f01048d0:	89 c7                	mov    %eax,%edi
	if (page == NULL) {
f01048d2:	83 c4 10             	add    $0x10,%esp
f01048d5:	85 c0                	test   %eax,%eax
f01048d7:	74 50                	je     f0104929 <sys_page_alloc+0xa4>
	if (page_insert(env->env_pgdir, page, va, perm) < 0) {
f01048d9:	56                   	push   %esi
f01048da:	53                   	push   %ebx
f01048db:	50                   	push   %eax
f01048dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048df:	ff 70 60             	pushl  0x60(%eax)
f01048e2:	e8 34 d2 ff ff       	call   f0101b1b <page_insert>
f01048e7:	83 c4 10             	add    $0x10,%esp
f01048ea:	85 c0                	test   %eax,%eax
f01048ec:	78 0b                	js     f01048f9 <sys_page_alloc+0x74>
}
f01048ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01048f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01048f4:	5b                   	pop    %ebx
f01048f5:	5e                   	pop    %esi
f01048f6:	5f                   	pop    %edi
f01048f7:	5d                   	pop    %ebp
f01048f8:	c3                   	ret    
		page_free(page);
f01048f9:	83 ec 0c             	sub    $0xc,%esp
f01048fc:	57                   	push   %edi
f01048fd:	e8 86 c8 ff ff       	call   f0101188 <page_free>
		return -E_NO_MEM;
f0104902:	83 c4 10             	add    $0x10,%esp
f0104905:	c7 45 d4 fc ff ff ff 	movl   $0xfffffffc,-0x2c(%ebp)
f010490c:	eb e0                	jmp    f01048ee <sys_page_alloc+0x69>
		return -E_BAD_ENV;
f010490e:	c7 45 d4 fe ff ff ff 	movl   $0xfffffffe,-0x2c(%ebp)
f0104915:	eb d7                	jmp    f01048ee <sys_page_alloc+0x69>
		return -E_INVAL;
f0104917:	c7 45 d4 fd ff ff ff 	movl   $0xfffffffd,-0x2c(%ebp)
f010491e:	eb ce                	jmp    f01048ee <sys_page_alloc+0x69>
		return -E_INVAL;
f0104920:	c7 45 d4 fd ff ff ff 	movl   $0xfffffffd,-0x2c(%ebp)
f0104927:	eb c5                	jmp    f01048ee <sys_page_alloc+0x69>
		return -E_NO_MEM;
f0104929:	c7 45 d4 fc ff ff ff 	movl   $0xfffffffc,-0x2c(%ebp)
f0104930:	eb bc                	jmp    f01048ee <sys_page_alloc+0x69>

f0104932 <sys_page_map>:
{
f0104932:	55                   	push   %ebp
f0104933:	89 e5                	mov    %esp,%ebp
f0104935:	57                   	push   %edi
f0104936:	56                   	push   %esi
f0104937:	53                   	push   %ebx
f0104938:	83 ec 20             	sub    $0x20,%esp
f010493b:	89 d3                	mov    %edx,%ebx
f010493d:	89 ce                	mov    %ecx,%esi
f010493f:	8b 7d 08             	mov    0x8(%ebp),%edi
	if (envid2env(srcenvid, &srcenv, 1) < 0 ||
f0104942:	6a 01                	push   $0x1
f0104944:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104947:	52                   	push   %edx
f0104948:	50                   	push   %eax
f0104949:	e8 3e e8 ff ff       	call   f010318c <envid2env>
f010494e:	83 c4 10             	add    $0x10,%esp
f0104951:	85 c0                	test   %eax,%eax
f0104953:	0f 88 b7 00 00 00    	js     f0104a10 <sys_page_map+0xde>
	    envid2env(dstenvid, &dstenv, 1)) {
f0104959:	83 ec 04             	sub    $0x4,%esp
f010495c:	6a 01                	push   $0x1
f010495e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104961:	50                   	push   %eax
f0104962:	56                   	push   %esi
f0104963:	e8 24 e8 ff ff       	call   f010318c <envid2env>
f0104968:	89 c6                	mov    %eax,%esi
	if (envid2env(srcenvid, &srcenv, 1) < 0 ||
f010496a:	83 c4 10             	add    $0x10,%esp
f010496d:	85 c0                	test   %eax,%eax
f010496f:	0f 85 a2 00 00 00    	jne    f0104a17 <sys_page_map+0xe5>
	if ((uintptr_t) srcva >= UTOP || ((uintptr_t) srcva) % PGSIZE != 0 ||
f0104975:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f010497b:	0f 87 9d 00 00 00    	ja     f0104a1e <sys_page_map+0xec>
f0104981:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0104987:	0f 85 98 00 00 00    	jne    f0104a25 <sys_page_map+0xf3>
f010498d:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104993:	0f 87 93 00 00 00    	ja     f0104a2c <sys_page_map+0xfa>
	    (uintptr_t) dstva >= UTOP || ((uintptr_t) dstva) % PGSIZE != 0) {
f0104999:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f010499f:	0f 85 8e 00 00 00    	jne    f0104a33 <sys_page_map+0x101>
	struct PageInfo *page = page_lookup(srcenv->env_pgdir, srcva, &pte);
f01049a5:	83 ec 04             	sub    $0x4,%esp
f01049a8:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01049ab:	50                   	push   %eax
f01049ac:	53                   	push   %ebx
f01049ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049b0:	ff 70 60             	pushl  0x60(%eax)
f01049b3:	e8 91 d0 ff ff       	call   f0101a49 <page_lookup>
f01049b8:	89 c3                	mov    %eax,%ebx
	if (page == NULL) {
f01049ba:	83 c4 10             	add    $0x10,%esp
f01049bd:	85 c0                	test   %eax,%eax
f01049bf:	74 79                	je     f0104a3a <sys_page_map+0x108>
	if ((~perm & (PTE_U | PTE_P)) != 0 ||
f01049c1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01049c4:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01049c9:	83 f8 05             	cmp    $0x5,%eax
f01049cc:	75 73                	jne    f0104a41 <sys_page_map+0x10f>
	if (perm & PTE_W) {
f01049ce:	f6 45 0c 02          	testb  $0x2,0xc(%ebp)
f01049d2:	74 08                	je     f01049dc <sys_page_map+0xaa>
		if ((*pte & PTE_W) == 0) {
f01049d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01049d7:	f6 00 02             	testb  $0x2,(%eax)
f01049da:	74 6c                	je     f0104a48 <sys_page_map+0x116>
	if (page_insert(dstenv->env_pgdir, page, dstva, perm) < 0) {
f01049dc:	ff 75 0c             	pushl  0xc(%ebp)
f01049df:	57                   	push   %edi
f01049e0:	53                   	push   %ebx
f01049e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049e4:	ff 70 60             	pushl  0x60(%eax)
f01049e7:	e8 2f d1 ff ff       	call   f0101b1b <page_insert>
f01049ec:	83 c4 10             	add    $0x10,%esp
f01049ef:	85 c0                	test   %eax,%eax
f01049f1:	78 0a                	js     f01049fd <sys_page_map+0xcb>
}
f01049f3:	89 f0                	mov    %esi,%eax
f01049f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01049f8:	5b                   	pop    %ebx
f01049f9:	5e                   	pop    %esi
f01049fa:	5f                   	pop    %edi
f01049fb:	5d                   	pop    %ebp
f01049fc:	c3                   	ret    
		page_free(page);
f01049fd:	83 ec 0c             	sub    $0xc,%esp
f0104a00:	53                   	push   %ebx
f0104a01:	e8 82 c7 ff ff       	call   f0101188 <page_free>
		return -E_NO_MEM;
f0104a06:	83 c4 10             	add    $0x10,%esp
f0104a09:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f0104a0e:	eb e3                	jmp    f01049f3 <sys_page_map+0xc1>
		return -E_BAD_ENV;
f0104a10:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f0104a15:	eb dc                	jmp    f01049f3 <sys_page_map+0xc1>
f0104a17:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f0104a1c:	eb d5                	jmp    f01049f3 <sys_page_map+0xc1>
		return -E_INVAL;
f0104a1e:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104a23:	eb ce                	jmp    f01049f3 <sys_page_map+0xc1>
f0104a25:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104a2a:	eb c7                	jmp    f01049f3 <sys_page_map+0xc1>
f0104a2c:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104a31:	eb c0                	jmp    f01049f3 <sys_page_map+0xc1>
f0104a33:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104a38:	eb b9                	jmp    f01049f3 <sys_page_map+0xc1>
		return -E_INVAL;
f0104a3a:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104a3f:	eb b2                	jmp    f01049f3 <sys_page_map+0xc1>
		return -E_INVAL;
f0104a41:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104a46:	eb ab                	jmp    f01049f3 <sys_page_map+0xc1>
			return -E_INVAL;
f0104a48:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0104a4d:	eb a4                	jmp    f01049f3 <sys_page_map+0xc1>

f0104a4f <sys_ipc_try_send>:
{
f0104a4f:	55                   	push   %ebp
f0104a50:	89 e5                	mov    %esp,%ebp
f0104a52:	57                   	push   %edi
f0104a53:	56                   	push   %esi
f0104a54:	53                   	push   %ebx
f0104a55:	83 ec 30             	sub    $0x30,%esp
f0104a58:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104a5b:	89 cb                	mov    %ecx,%ebx
f0104a5d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (envid2env(envid, &env, 0) < 0) {
f0104a60:	6a 00                	push   $0x0
f0104a62:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104a65:	52                   	push   %edx
f0104a66:	50                   	push   %eax
f0104a67:	e8 20 e7 ff ff       	call   f010318c <envid2env>
f0104a6c:	83 c4 10             	add    $0x10,%esp
f0104a6f:	85 c0                	test   %eax,%eax
f0104a71:	0f 88 e4 00 00 00    	js     f0104b5b <sys_ipc_try_send+0x10c>
	if (env->env_ipc_recving != 1) {
f0104a77:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a7a:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104a7e:	0f 84 de 00 00 00    	je     f0104b62 <sys_ipc_try_send+0x113>
	if ((int) srcva < UTOP) {
f0104a84:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104a8a:	0f 87 90 00 00 00    	ja     f0104b20 <sys_ipc_try_send+0xd1>
		if ((~perm & (PTE_U | PTE_P)) != 0 ||
f0104a90:	89 f0                	mov    %esi,%eax
f0104a92:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0104a97:	83 f0 05             	xor    $0x5,%eax
		if (((int) srcva) % PGSIZE != 0) {
f0104a9a:	89 da                	mov    %ebx,%edx
f0104a9c:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
		if ((~perm & (PTE_U | PTE_P)) != 0 ||
f0104aa2:	09 d0                	or     %edx,%eax
f0104aa4:	0f 85 bf 00 00 00    	jne    f0104b69 <sys_ipc_try_send+0x11a>
		if ((page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL) {
f0104aaa:	e8 41 14 00 00       	call   f0105ef0 <cpunum>
f0104aaf:	83 ec 04             	sub    $0x4,%esp
f0104ab2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104ab5:	52                   	push   %edx
f0104ab6:	53                   	push   %ebx
f0104ab7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aba:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104ac0:	ff 70 60             	pushl  0x60(%eax)
f0104ac3:	e8 81 cf ff ff       	call   f0101a49 <page_lookup>
f0104ac8:	83 c4 10             	add    $0x10,%esp
f0104acb:	85 c0                	test   %eax,%eax
f0104acd:	0f 84 9d 00 00 00    	je     f0104b70 <sys_ipc_try_send+0x121>
		if (perm & PTE_W) {
f0104ad3:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0104ad9:	74 0c                	je     f0104ae7 <sys_ipc_try_send+0x98>
			if ((*pte & PTE_W) == 0) {
f0104adb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ade:	f6 00 02             	testb  $0x2,(%eax)
f0104ae1:	0f 84 90 00 00 00    	je     f0104b77 <sys_ipc_try_send+0x128>
		if ((page_insert(env->env_pgdir,
f0104ae7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104aea:	8b 78 6c             	mov    0x6c(%eax),%edi
		                 page_lookup(curenv->env_pgdir, srcva, &pte),
f0104aed:	e8 fe 13 00 00       	call   f0105ef0 <cpunum>
		if ((page_insert(env->env_pgdir,
f0104af2:	83 ec 04             	sub    $0x4,%esp
f0104af5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104af8:	52                   	push   %edx
f0104af9:	53                   	push   %ebx
		                 page_lookup(curenv->env_pgdir, srcva, &pte),
f0104afa:	6b c0 74             	imul   $0x74,%eax,%eax
		if ((page_insert(env->env_pgdir,
f0104afd:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104b03:	ff 70 60             	pushl  0x60(%eax)
f0104b06:	e8 3e cf ff ff       	call   f0101a49 <page_lookup>
f0104b0b:	56                   	push   %esi
f0104b0c:	57                   	push   %edi
f0104b0d:	50                   	push   %eax
f0104b0e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b11:	ff 70 60             	pushl  0x60(%eax)
f0104b14:	e8 02 d0 ff ff       	call   f0101b1b <page_insert>
f0104b19:	83 c4 20             	add    $0x20,%esp
f0104b1c:	85 c0                	test   %eax,%eax
f0104b1e:	78 5e                	js     f0104b7e <sys_ipc_try_send+0x12f>
	env->env_ipc_recving = 0;
f0104b20:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b23:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	env->env_ipc_from = curenv->env_id;
f0104b27:	e8 c4 13 00 00       	call   f0105ef0 <cpunum>
f0104b2c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b2f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b32:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104b38:	8b 40 48             	mov    0x48(%eax),%eax
f0104b3b:	89 42 74             	mov    %eax,0x74(%edx)
	env->env_ipc_value = value;
f0104b3e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104b41:	89 42 70             	mov    %eax,0x70(%edx)
	env->env_ipc_perm = perm;
f0104b44:	89 72 78             	mov    %esi,0x78(%edx)
	env->env_status = ENV_RUNNABLE;
f0104b47:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	return 0;
f0104b4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104b53:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104b56:	5b                   	pop    %ebx
f0104b57:	5e                   	pop    %esi
f0104b58:	5f                   	pop    %edi
f0104b59:	5d                   	pop    %ebp
f0104b5a:	c3                   	ret    
		return -E_BAD_ENV;
f0104b5b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104b60:	eb f1                	jmp    f0104b53 <sys_ipc_try_send+0x104>
		return -E_IPC_NOT_RECV;
f0104b62:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f0104b67:	eb ea                	jmp    f0104b53 <sys_ipc_try_send+0x104>
			return -E_INVAL;
f0104b69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b6e:	eb e3                	jmp    f0104b53 <sys_ipc_try_send+0x104>
			return -E_INVAL;
f0104b70:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b75:	eb dc                	jmp    f0104b53 <sys_ipc_try_send+0x104>
				return -E_INVAL;
f0104b77:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104b7c:	eb d5                	jmp    f0104b53 <sys_ipc_try_send+0x104>
			return -E_NO_MEM;
f0104b7e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104b83:	eb ce                	jmp    f0104b53 <sys_ipc_try_send+0x104>

f0104b85 <sys_page_unmap>:
{
f0104b85:	55                   	push   %ebp
f0104b86:	89 e5                	mov    %esp,%ebp
f0104b88:	53                   	push   %ebx
f0104b89:	83 ec 18             	sub    $0x18,%esp
f0104b8c:	89 d3                	mov    %edx,%ebx
	if (envid2env(envid, &env, 1) < 0) {
f0104b8e:	6a 01                	push   $0x1
f0104b90:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0104b93:	52                   	push   %edx
f0104b94:	50                   	push   %eax
f0104b95:	e8 f2 e5 ff ff       	call   f010318c <envid2env>
f0104b9a:	83 c4 10             	add    $0x10,%esp
f0104b9d:	85 c0                	test   %eax,%eax
f0104b9f:	78 2c                	js     f0104bcd <sys_page_unmap+0x48>
	if ((uintptr_t) va >= UTOP || ((uintptr_t) va % PGSIZE) != 0) {
f0104ba1:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104ba7:	77 2b                	ja     f0104bd4 <sys_page_unmap+0x4f>
f0104ba9:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0104baf:	75 2a                	jne    f0104bdb <sys_page_unmap+0x56>
	page_remove(env->env_pgdir, va);
f0104bb1:	83 ec 08             	sub    $0x8,%esp
f0104bb4:	53                   	push   %ebx
f0104bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104bb8:	ff 70 60             	pushl  0x60(%eax)
f0104bbb:	e8 09 cf ff ff       	call   f0101ac9 <page_remove>
	return 0;
f0104bc0:	83 c4 10             	add    $0x10,%esp
f0104bc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104bc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104bcb:	c9                   	leave  
f0104bcc:	c3                   	ret    
		return -E_BAD_ENV;
f0104bcd:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104bd2:	eb f4                	jmp    f0104bc8 <sys_page_unmap+0x43>
		return -E_INVAL;
f0104bd4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104bd9:	eb ed                	jmp    f0104bc8 <sys_page_unmap+0x43>
f0104bdb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104be0:	eb e6                	jmp    f0104bc8 <sys_page_unmap+0x43>

f0104be2 <syscall>:

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104be2:	f3 0f 1e fb          	endbr32 
f0104be6:	55                   	push   %ebp
f0104be7:	89 e5                	mov    %esp,%ebp
f0104be9:	83 ec 08             	sub    $0x8,%esp
f0104bec:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bef:	83 f8 0d             	cmp    $0xd,%eax
f0104bf2:	0f 87 ca 00 00 00    	ja     f0104cc2 <syscall+0xe0>
f0104bf8:	3e ff 24 85 c0 7c 10 	notrack jmp *-0xfef8340(,%eax,4)
f0104bff:	f0 
	// Return any appropriate return value.
	// LAB 3: Your code here.

	switch (syscallno) {
	case SYS_cputs: {
		sys_cputs((const char *) a1, a2);
f0104c00:	8b 55 10             	mov    0x10(%ebp),%edx
f0104c03:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c06:	e8 69 fa ff ff       	call   f0104674 <sys_cputs>
		return 0;
f0104c0b:	b8 00 00 00 00       	mov    $0x0,%eax
		                             (struct Trapframe *) a2);

	default:
		return -E_INVAL;
	}
}
f0104c10:	c9                   	leave  
f0104c11:	c3                   	ret    
		return sys_cgetc();
f0104c12:	e8 96 fa ff ff       	call   f01046ad <sys_cgetc>
f0104c17:	eb f7                	jmp    f0104c10 <syscall+0x2e>
		return sys_getenvid();
f0104c19:	e8 dc f9 ff ff       	call   f01045fa <sys_getenvid>
f0104c1e:	eb f0                	jmp    f0104c10 <syscall+0x2e>
		return sys_env_destroy(a1);
f0104c20:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c23:	e8 63 fb ff ff       	call   f010478b <sys_env_destroy>
f0104c28:	eb e6                	jmp    f0104c10 <syscall+0x2e>
		sys_yield();
f0104c2a:	e8 e9 fb ff ff       	call   f0104818 <sys_yield>
		return sys_exofork();
f0104c2f:	e8 ef fb ff ff       	call   f0104823 <sys_exofork>
f0104c34:	eb da                	jmp    f0104c10 <syscall+0x2e>
		return sys_env_set_status((envid_t) a1, (int) a2);
f0104c36:	8b 55 10             	mov    0x10(%ebp),%edx
f0104c39:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c3c:	e8 79 fa ff ff       	call   f01046ba <sys_env_set_status>
f0104c41:	eb cd                	jmp    f0104c10 <syscall+0x2e>
		return sys_page_alloc((envid_t) a1, (void *) a2, (int) a3);
f0104c43:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104c46:	8b 55 10             	mov    0x10(%ebp),%edx
f0104c49:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c4c:	e8 34 fc ff ff       	call   f0104885 <sys_page_alloc>
f0104c51:	eb bd                	jmp    f0104c10 <syscall+0x2e>
		return sys_page_map((envid_t) a1,
f0104c53:	83 ec 08             	sub    $0x8,%esp
f0104c56:	ff 75 1c             	pushl  0x1c(%ebp)
f0104c59:	ff 75 18             	pushl  0x18(%ebp)
f0104c5c:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104c5f:	8b 55 10             	mov    0x10(%ebp),%edx
f0104c62:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c65:	e8 c8 fc ff ff       	call   f0104932 <sys_page_map>
f0104c6a:	83 c4 10             	add    $0x10,%esp
f0104c6d:	eb a1                	jmp    f0104c10 <syscall+0x2e>
		return sys_page_unmap((envid_t) a1, (void *) a2);
f0104c6f:	8b 55 10             	mov    0x10(%ebp),%edx
f0104c72:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c75:	e8 0b ff ff ff       	call   f0104b85 <sys_page_unmap>
f0104c7a:	eb 94                	jmp    f0104c10 <syscall+0x2e>
		return sys_env_set_pgfault_upcall((envid_t) a1, (void *) a2);
f0104c7c:	8b 55 10             	mov    0x10(%ebp),%edx
f0104c7f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c82:	e8 7b fa ff ff       	call   f0104702 <sys_env_set_pgfault_upcall>
f0104c87:	eb 87                	jmp    f0104c10 <syscall+0x2e>
		return sys_ipc_recv((void *) a1);
f0104c89:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c8c:	e8 82 f9 ff ff       	call   f0104613 <sys_ipc_recv>
f0104c91:	e9 7a ff ff ff       	jmp    f0104c10 <syscall+0x2e>
		return sys_ipc_try_send(
f0104c96:	83 ec 0c             	sub    $0xc,%esp
f0104c99:	ff 75 18             	pushl  0x18(%ebp)
f0104c9c:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104c9f:	8b 55 10             	mov    0x10(%ebp),%edx
f0104ca2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104ca5:	e8 a5 fd ff ff       	call   f0104a4f <sys_ipc_try_send>
f0104caa:	83 c4 10             	add    $0x10,%esp
f0104cad:	e9 5e ff ff ff       	jmp    f0104c10 <syscall+0x2e>
		return sys_env_set_trapframe((envid_t) a1,
f0104cb2:	8b 55 10             	mov    0x10(%ebp),%edx
f0104cb5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104cb8:	e8 78 fa ff ff       	call   f0104735 <sys_env_set_trapframe>
f0104cbd:	e9 4e ff ff ff       	jmp    f0104c10 <syscall+0x2e>
		return 0;
f0104cc2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104cc7:	e9 44 ff ff ff       	jmp    f0104c10 <syscall+0x2e>

f0104ccc <stab_binsearch>:
stab_binsearch(const struct Stab *stabs,
               int *region_left,
               int *region_right,
               int type,
               uintptr_t addr)
{
f0104ccc:	55                   	push   %ebp
f0104ccd:	89 e5                	mov    %esp,%ebp
f0104ccf:	57                   	push   %edi
f0104cd0:	56                   	push   %esi
f0104cd1:	53                   	push   %ebx
f0104cd2:	83 ec 14             	sub    $0x14,%esp
f0104cd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104cd8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104cdb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104cde:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104ce1:	8b 1a                	mov    (%edx),%ebx
f0104ce3:	8b 01                	mov    (%ecx),%eax
f0104ce5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104ce8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104cef:	eb 23                	jmp    f0104d14 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {  // no match in [l, m]
			l = true_m + 1;
f0104cf1:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104cf4:	eb 1e                	jmp    f0104d14 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104cf6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cf9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104cfc:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104d00:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104d03:	73 46                	jae    f0104d4b <stab_binsearch+0x7f>
			*region_left = m;
f0104d05:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104d08:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104d0a:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0104d0d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104d14:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104d17:	7f 5f                	jg     f0104d78 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0104d19:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104d1c:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0104d1f:	89 d0                	mov    %edx,%eax
f0104d21:	c1 e8 1f             	shr    $0x1f,%eax
f0104d24:	01 d0                	add    %edx,%eax
f0104d26:	89 c7                	mov    %eax,%edi
f0104d28:	d1 ff                	sar    %edi
f0104d2a:	83 e0 fe             	and    $0xfffffffe,%eax
f0104d2d:	01 f8                	add    %edi,%eax
f0104d2f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104d32:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104d36:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0104d38:	39 c3                	cmp    %eax,%ebx
f0104d3a:	7f b5                	jg     f0104cf1 <stab_binsearch+0x25>
f0104d3c:	0f b6 0a             	movzbl (%edx),%ecx
f0104d3f:	83 ea 0c             	sub    $0xc,%edx
f0104d42:	39 f1                	cmp    %esi,%ecx
f0104d44:	74 b0                	je     f0104cf6 <stab_binsearch+0x2a>
			m--;
f0104d46:	83 e8 01             	sub    $0x1,%eax
f0104d49:	eb ed                	jmp    f0104d38 <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0104d4b:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104d4e:	76 14                	jbe    f0104d64 <stab_binsearch+0x98>
			*region_right = m - 1;
f0104d50:	83 e8 01             	sub    $0x1,%eax
f0104d53:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104d56:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104d59:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104d5b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104d62:	eb b0                	jmp    f0104d14 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104d64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d67:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104d69:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104d6d:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0104d6f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104d76:	eb 9c                	jmp    f0104d14 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0104d78:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104d7c:	75 15                	jne    f0104d93 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0104d7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d81:	8b 00                	mov    (%eax),%eax
f0104d83:	83 e8 01             	sub    $0x1,%eax
f0104d86:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104d89:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104d8b:	83 c4 14             	add    $0x14,%esp
f0104d8e:	5b                   	pop    %ebx
f0104d8f:	5e                   	pop    %esi
f0104d90:	5f                   	pop    %edi
f0104d91:	5d                   	pop    %ebp
f0104d92:	c3                   	ret    
		for (l = *region_right;
f0104d93:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d96:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104d98:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d9b:	8b 0f                	mov    (%edi),%ecx
f0104d9d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104da0:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104da3:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0104da7:	eb 03                	jmp    f0104dac <stab_binsearch+0xe0>
		     l--)
f0104da9:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0104dac:	39 c1                	cmp    %eax,%ecx
f0104dae:	7d 0a                	jge    f0104dba <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0104db0:	0f b6 1a             	movzbl (%edx),%ebx
f0104db3:	83 ea 0c             	sub    $0xc,%edx
f0104db6:	39 f3                	cmp    %esi,%ebx
f0104db8:	75 ef                	jne    f0104da9 <stab_binsearch+0xdd>
		*region_left = l;
f0104dba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104dbd:	89 07                	mov    %eax,(%edi)
}
f0104dbf:	eb ca                	jmp    f0104d8b <stab_binsearch+0xbf>

f0104dc1 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104dc1:	f3 0f 1e fb          	endbr32 
f0104dc5:	55                   	push   %ebp
f0104dc6:	89 e5                	mov    %esp,%ebp
f0104dc8:	57                   	push   %edi
f0104dc9:	56                   	push   %esi
f0104dca:	53                   	push   %ebx
f0104dcb:	83 ec 4c             	sub    $0x4c,%esp
f0104dce:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104dd1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104dd4:	c7 03 f8 7c 10 f0    	movl   $0xf0107cf8,(%ebx)
	info->eip_line = 0;
f0104dda:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104de1:	c7 43 08 f8 7c 10 f0 	movl   $0xf0107cf8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104de8:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104def:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104df2:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104df9:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104dff:	0f 86 21 01 00 00    	jbe    f0104f26 <debuginfo_eip+0x165>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104e05:	c7 45 b8 e0 8c 11 f0 	movl   $0xf0118ce0,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104e0c:	c7 45 b4 f1 4b 11 f0 	movl   $0xf0114bf1,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104e13:	be f0 4b 11 f0       	mov    $0xf0114bf0,%esi
		stabs = __STAB_BEGIN__;
f0104e18:	c7 45 bc 90 82 10 f0 	movl   $0xf0108290,-0x44(%ebp)
		    user_mem_check(curenv, stabstr, stabstr_end - stabstr, 0))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104e1f:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104e22:	39 4d b4             	cmp    %ecx,-0x4c(%ebp)
f0104e25:	0f 83 62 02 00 00    	jae    f010508d <debuginfo_eip+0x2cc>
f0104e2b:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104e2f:	0f 85 5f 02 00 00    	jne    f0105094 <debuginfo_eip+0x2d3>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104e35:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104e3c:	2b 75 bc             	sub    -0x44(%ebp),%esi
f0104e3f:	c1 fe 02             	sar    $0x2,%esi
f0104e42:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104e48:	83 e8 01             	sub    $0x1,%eax
f0104e4b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104e4e:	83 ec 08             	sub    $0x8,%esp
f0104e51:	57                   	push   %edi
f0104e52:	6a 64                	push   $0x64
f0104e54:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104e57:	89 d1                	mov    %edx,%ecx
f0104e59:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e5c:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0104e5f:	89 f0                	mov    %esi,%eax
f0104e61:	e8 66 fe ff ff       	call   f0104ccc <stab_binsearch>
	if (lfile == 0)
f0104e66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e69:	83 c4 10             	add    $0x10,%esp
f0104e6c:	85 c0                	test   %eax,%eax
f0104e6e:	0f 84 27 02 00 00    	je     f010509b <debuginfo_eip+0x2da>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104e74:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104e77:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e7a:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104e7d:	83 ec 08             	sub    $0x8,%esp
f0104e80:	57                   	push   %edi
f0104e81:	6a 24                	push   $0x24
f0104e83:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104e86:	89 d1                	mov    %edx,%ecx
f0104e88:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104e8b:	89 f0                	mov    %esi,%eax
f0104e8d:	e8 3a fe ff ff       	call   f0104ccc <stab_binsearch>

	if (lfun <= rfun) {
f0104e92:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e95:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104e98:	83 c4 10             	add    $0x10,%esp
f0104e9b:	39 d0                	cmp    %edx,%eax
f0104e9d:	0f 8f 32 01 00 00    	jg     f0104fd5 <debuginfo_eip+0x214>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104ea3:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104ea6:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104ea9:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104eac:	8b 36                	mov    (%esi),%esi
f0104eae:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104eb1:	2b 4d b4             	sub    -0x4c(%ebp),%ecx
f0104eb4:	39 ce                	cmp    %ecx,%esi
f0104eb6:	73 06                	jae    f0104ebe <debuginfo_eip+0xfd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104eb8:	03 75 b4             	add    -0x4c(%ebp),%esi
f0104ebb:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104ebe:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104ec1:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104ec4:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104ec7:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104ec9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104ecc:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104ecf:	83 ec 08             	sub    $0x8,%esp
f0104ed2:	6a 3a                	push   $0x3a
f0104ed4:	ff 73 08             	pushl  0x8(%ebx)
f0104ed7:	e8 63 09 00 00       	call   f010583f <strfind>
f0104edc:	2b 43 08             	sub    0x8(%ebx),%eax
f0104edf:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104ee2:	83 c4 08             	add    $0x8,%esp
f0104ee5:	57                   	push   %edi
f0104ee6:	6a 44                	push   $0x44
f0104ee8:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104eeb:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104eee:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104ef1:	89 f8                	mov    %edi,%eax
f0104ef3:	e8 d4 fd ff ff       	call   f0104ccc <stab_binsearch>
	if (lline <= rline) {
f0104ef8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104efb:	83 c4 10             	add    $0x10,%esp
f0104efe:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0104f01:	7f 0b                	jg     f0104f0e <debuginfo_eip+0x14d>
		info->eip_line = stabs[lline].n_desc;
f0104f03:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104f06:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f0104f0b:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile && stabs[lline].n_type != N_SOL &&
f0104f0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f11:	89 d0                	mov    %edx,%eax
f0104f13:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104f16:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0104f19:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
f0104f1d:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104f21:	e9 cd 00 00 00       	jmp    f0104ff3 <debuginfo_eip+0x232>
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), 0))
f0104f26:	e8 c5 0f 00 00       	call   f0105ef0 <cpunum>
f0104f2b:	6a 00                	push   $0x0
f0104f2d:	6a 10                	push   $0x10
f0104f2f:	68 00 00 20 00       	push   $0x200000
f0104f34:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f37:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f0104f3d:	e8 e1 de ff ff       	call   f0102e23 <user_mem_check>
f0104f42:	83 c4 10             	add    $0x10,%esp
f0104f45:	85 c0                	test   %eax,%eax
f0104f47:	0f 85 32 01 00 00    	jne    f010507f <debuginfo_eip+0x2be>
		stabs = usd->stabs;
f0104f4d:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f0104f53:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stab_end = usd->stab_end;
f0104f56:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104f5c:	a1 08 00 20 00       	mov    0x200008,%eax
f0104f61:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0104f64:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104f6a:	89 55 b8             	mov    %edx,-0x48(%ebp)
		if (user_mem_check(curenv, stabs, stab_end - stabs, 0) ||
f0104f6d:	e8 7e 0f 00 00       	call   f0105ef0 <cpunum>
f0104f72:	89 c2                	mov    %eax,%edx
f0104f74:	6a 00                	push   $0x0
f0104f76:	89 f0                	mov    %esi,%eax
f0104f78:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104f7b:	29 c8                	sub    %ecx,%eax
f0104f7d:	c1 f8 02             	sar    $0x2,%eax
f0104f80:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104f86:	50                   	push   %eax
f0104f87:	51                   	push   %ecx
f0104f88:	6b d2 74             	imul   $0x74,%edx,%edx
f0104f8b:	ff b2 28 30 22 f0    	pushl  -0xfddcfd8(%edx)
f0104f91:	e8 8d de ff ff       	call   f0102e23 <user_mem_check>
f0104f96:	83 c4 10             	add    $0x10,%esp
f0104f99:	85 c0                	test   %eax,%eax
f0104f9b:	0f 85 e5 00 00 00    	jne    f0105086 <debuginfo_eip+0x2c5>
		    user_mem_check(curenv, stabstr, stabstr_end - stabstr, 0))
f0104fa1:	e8 4a 0f 00 00       	call   f0105ef0 <cpunum>
f0104fa6:	6a 00                	push   $0x0
f0104fa8:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0104fab:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f0104fae:	29 ca                	sub    %ecx,%edx
f0104fb0:	52                   	push   %edx
f0104fb1:	51                   	push   %ecx
f0104fb2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fb5:	ff b0 28 30 22 f0    	pushl  -0xfddcfd8(%eax)
f0104fbb:	e8 63 de ff ff       	call   f0102e23 <user_mem_check>
		if (user_mem_check(curenv, stabs, stab_end - stabs, 0) ||
f0104fc0:	83 c4 10             	add    $0x10,%esp
f0104fc3:	85 c0                	test   %eax,%eax
f0104fc5:	0f 84 54 fe ff ff    	je     f0104e1f <debuginfo_eip+0x5e>
			return -1;
f0104fcb:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0104fd0:	e9 d2 00 00 00       	jmp    f01050a7 <debuginfo_eip+0x2e6>
		info->eip_fn_addr = addr;
f0104fd5:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104fd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104fdb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104fde:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104fe1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104fe4:	e9 e6 fe ff ff       	jmp    f0104ecf <debuginfo_eip+0x10e>
f0104fe9:	83 e8 01             	sub    $0x1,%eax
f0104fec:	83 ea 0c             	sub    $0xc,%edx
	while (lline >= lfile && stabs[lline].n_type != N_SOL &&
f0104fef:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104ff3:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0104ff6:	39 c7                	cmp    %eax,%edi
f0104ff8:	7f 45                	jg     f010503f <debuginfo_eip+0x27e>
f0104ffa:	0f b6 0a             	movzbl (%edx),%ecx
f0104ffd:	80 f9 84             	cmp    $0x84,%cl
f0105000:	74 19                	je     f010501b <debuginfo_eip+0x25a>
f0105002:	80 f9 64             	cmp    $0x64,%cl
f0105005:	75 e2                	jne    f0104fe9 <debuginfo_eip+0x228>
	       (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105007:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f010500b:	74 dc                	je     f0104fe9 <debuginfo_eip+0x228>
f010500d:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105011:	74 11                	je     f0105024 <debuginfo_eip+0x263>
f0105013:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105016:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105019:	eb 09                	jmp    f0105024 <debuginfo_eip+0x263>
f010501b:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010501f:	74 03                	je     f0105024 <debuginfo_eip+0x263>
f0105021:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105024:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105027:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010502a:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010502d:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0105030:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105033:	29 f8                	sub    %edi,%eax
f0105035:	39 c2                	cmp    %eax,%edx
f0105037:	73 06                	jae    f010503f <debuginfo_eip+0x27e>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105039:	89 f8                	mov    %edi,%eax
f010503b:	01 d0                	add    %edx,%eax
f010503d:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010503f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105042:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105045:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f010504a:	39 f0                	cmp    %esi,%eax
f010504c:	7d 59                	jge    f01050a7 <debuginfo_eip+0x2e6>
		for (lline = lfun + 1;
f010504e:	8d 50 01             	lea    0x1(%eax),%edx
f0105051:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105054:	89 d0                	mov    %edx,%eax
f0105056:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105059:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010505c:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0105060:	eb 04                	jmp    f0105066 <debuginfo_eip+0x2a5>
			info->eip_fn_narg++;
f0105062:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f0105066:	39 c6                	cmp    %eax,%esi
f0105068:	7e 38                	jle    f01050a2 <debuginfo_eip+0x2e1>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010506a:	0f b6 0a             	movzbl (%edx),%ecx
f010506d:	83 c0 01             	add    $0x1,%eax
f0105070:	83 c2 0c             	add    $0xc,%edx
f0105073:	80 f9 a0             	cmp    $0xa0,%cl
f0105076:	74 ea                	je     f0105062 <debuginfo_eip+0x2a1>
	return 0;
f0105078:	ba 00 00 00 00       	mov    $0x0,%edx
f010507d:	eb 28                	jmp    f01050a7 <debuginfo_eip+0x2e6>
			return -1;
f010507f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105084:	eb 21                	jmp    f01050a7 <debuginfo_eip+0x2e6>
			return -1;
f0105086:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010508b:	eb 1a                	jmp    f01050a7 <debuginfo_eip+0x2e6>
		return -1;
f010508d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105092:	eb 13                	jmp    f01050a7 <debuginfo_eip+0x2e6>
f0105094:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105099:	eb 0c                	jmp    f01050a7 <debuginfo_eip+0x2e6>
		return -1;
f010509b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01050a0:	eb 05                	jmp    f01050a7 <debuginfo_eip+0x2e6>
	return 0;
f01050a2:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01050a7:	89 d0                	mov    %edx,%eax
f01050a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01050ac:	5b                   	pop    %ebx
f01050ad:	5e                   	pop    %esi
f01050ae:	5f                   	pop    %edi
f01050af:	5d                   	pop    %ebp
f01050b0:	c3                   	ret    

f01050b1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01050b1:	55                   	push   %ebp
f01050b2:	89 e5                	mov    %esp,%ebp
f01050b4:	57                   	push   %edi
f01050b5:	56                   	push   %esi
f01050b6:	53                   	push   %ebx
f01050b7:	83 ec 1c             	sub    $0x1c,%esp
f01050ba:	89 c7                	mov    %eax,%edi
f01050bc:	89 d6                	mov    %edx,%esi
f01050be:	8b 45 08             	mov    0x8(%ebp),%eax
f01050c1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01050c4:	89 d1                	mov    %edx,%ecx
f01050c6:	89 c2                	mov    %eax,%edx
f01050c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01050cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01050ce:	8b 45 10             	mov    0x10(%ebp),%eax
f01050d1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01050d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01050d7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01050de:	39 c2                	cmp    %eax,%edx
f01050e0:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f01050e3:	72 3e                	jb     f0105123 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01050e5:	83 ec 0c             	sub    $0xc,%esp
f01050e8:	ff 75 18             	pushl  0x18(%ebp)
f01050eb:	83 eb 01             	sub    $0x1,%ebx
f01050ee:	53                   	push   %ebx
f01050ef:	50                   	push   %eax
f01050f0:	83 ec 08             	sub    $0x8,%esp
f01050f3:	ff 75 e4             	pushl  -0x1c(%ebp)
f01050f6:	ff 75 e0             	pushl  -0x20(%ebp)
f01050f9:	ff 75 dc             	pushl  -0x24(%ebp)
f01050fc:	ff 75 d8             	pushl  -0x28(%ebp)
f01050ff:	e8 3c 12 00 00       	call   f0106340 <__udivdi3>
f0105104:	83 c4 18             	add    $0x18,%esp
f0105107:	52                   	push   %edx
f0105108:	50                   	push   %eax
f0105109:	89 f2                	mov    %esi,%edx
f010510b:	89 f8                	mov    %edi,%eax
f010510d:	e8 9f ff ff ff       	call   f01050b1 <printnum>
f0105112:	83 c4 20             	add    $0x20,%esp
f0105115:	eb 13                	jmp    f010512a <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105117:	83 ec 08             	sub    $0x8,%esp
f010511a:	56                   	push   %esi
f010511b:	ff 75 18             	pushl  0x18(%ebp)
f010511e:	ff d7                	call   *%edi
f0105120:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0105123:	83 eb 01             	sub    $0x1,%ebx
f0105126:	85 db                	test   %ebx,%ebx
f0105128:	7f ed                	jg     f0105117 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010512a:	83 ec 08             	sub    $0x8,%esp
f010512d:	56                   	push   %esi
f010512e:	83 ec 04             	sub    $0x4,%esp
f0105131:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105134:	ff 75 e0             	pushl  -0x20(%ebp)
f0105137:	ff 75 dc             	pushl  -0x24(%ebp)
f010513a:	ff 75 d8             	pushl  -0x28(%ebp)
f010513d:	e8 0e 13 00 00       	call   f0106450 <__umoddi3>
f0105142:	83 c4 14             	add    $0x14,%esp
f0105145:	0f be 80 02 7d 10 f0 	movsbl -0xfef82fe(%eax),%eax
f010514c:	50                   	push   %eax
f010514d:	ff d7                	call   *%edi
}
f010514f:	83 c4 10             	add    $0x10,%esp
f0105152:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105155:	5b                   	pop    %ebx
f0105156:	5e                   	pop    %esi
f0105157:	5f                   	pop    %edi
f0105158:	5d                   	pop    %ebp
f0105159:	c3                   	ret    

f010515a <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010515a:	83 fa 01             	cmp    $0x1,%edx
f010515d:	7f 13                	jg     f0105172 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f010515f:	85 d2                	test   %edx,%edx
f0105161:	74 1c                	je     f010517f <getuint+0x25>
		return va_arg(*ap, unsigned long);
f0105163:	8b 10                	mov    (%eax),%edx
f0105165:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105168:	89 08                	mov    %ecx,(%eax)
f010516a:	8b 02                	mov    (%edx),%eax
f010516c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105171:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
f0105172:	8b 10                	mov    (%eax),%edx
f0105174:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105177:	89 08                	mov    %ecx,(%eax)
f0105179:	8b 02                	mov    (%edx),%eax
f010517b:	8b 52 04             	mov    0x4(%edx),%edx
f010517e:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
f010517f:	8b 10                	mov    (%eax),%edx
f0105181:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105184:	89 08                	mov    %ecx,(%eax)
f0105186:	8b 02                	mov    (%edx),%eax
f0105188:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010518d:	c3                   	ret    

f010518e <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010518e:	83 fa 01             	cmp    $0x1,%edx
f0105191:	7f 0f                	jg     f01051a2 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
f0105193:	85 d2                	test   %edx,%edx
f0105195:	74 18                	je     f01051af <getint+0x21>
		return va_arg(*ap, long);
f0105197:	8b 10                	mov    (%eax),%edx
f0105199:	8d 4a 04             	lea    0x4(%edx),%ecx
f010519c:	89 08                	mov    %ecx,(%eax)
f010519e:	8b 02                	mov    (%edx),%eax
f01051a0:	99                   	cltd   
f01051a1:	c3                   	ret    
		return va_arg(*ap, long long);
f01051a2:	8b 10                	mov    (%eax),%edx
f01051a4:	8d 4a 08             	lea    0x8(%edx),%ecx
f01051a7:	89 08                	mov    %ecx,(%eax)
f01051a9:	8b 02                	mov    (%edx),%eax
f01051ab:	8b 52 04             	mov    0x4(%edx),%edx
f01051ae:	c3                   	ret    
	else
		return va_arg(*ap, int);
f01051af:	8b 10                	mov    (%eax),%edx
f01051b1:	8d 4a 04             	lea    0x4(%edx),%ecx
f01051b4:	89 08                	mov    %ecx,(%eax)
f01051b6:	8b 02                	mov    (%edx),%eax
f01051b8:	99                   	cltd   
}
f01051b9:	c3                   	ret    

f01051ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01051ba:	f3 0f 1e fb          	endbr32 
f01051be:	55                   	push   %ebp
f01051bf:	89 e5                	mov    %esp,%ebp
f01051c1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01051c4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01051c8:	8b 10                	mov    (%eax),%edx
f01051ca:	3b 50 04             	cmp    0x4(%eax),%edx
f01051cd:	73 0a                	jae    f01051d9 <sprintputch+0x1f>
		*b->buf++ = ch;
f01051cf:	8d 4a 01             	lea    0x1(%edx),%ecx
f01051d2:	89 08                	mov    %ecx,(%eax)
f01051d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01051d7:	88 02                	mov    %al,(%edx)
}
f01051d9:	5d                   	pop    %ebp
f01051da:	c3                   	ret    

f01051db <printfmt>:
{
f01051db:	f3 0f 1e fb          	endbr32 
f01051df:	55                   	push   %ebp
f01051e0:	89 e5                	mov    %esp,%ebp
f01051e2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01051e5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01051e8:	50                   	push   %eax
f01051e9:	ff 75 10             	pushl  0x10(%ebp)
f01051ec:	ff 75 0c             	pushl  0xc(%ebp)
f01051ef:	ff 75 08             	pushl  0x8(%ebp)
f01051f2:	e8 05 00 00 00       	call   f01051fc <vprintfmt>
}
f01051f7:	83 c4 10             	add    $0x10,%esp
f01051fa:	c9                   	leave  
f01051fb:	c3                   	ret    

f01051fc <vprintfmt>:
{
f01051fc:	f3 0f 1e fb          	endbr32 
f0105200:	55                   	push   %ebp
f0105201:	89 e5                	mov    %esp,%ebp
f0105203:	57                   	push   %edi
f0105204:	56                   	push   %esi
f0105205:	53                   	push   %ebx
f0105206:	83 ec 2c             	sub    $0x2c,%esp
f0105209:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010520c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010520f:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105212:	e9 86 02 00 00       	jmp    f010549d <vprintfmt+0x2a1>
		padc = ' ';
f0105217:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f010521b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0105222:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0105229:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0105230:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105235:	8d 47 01             	lea    0x1(%edi),%eax
f0105238:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010523b:	0f b6 17             	movzbl (%edi),%edx
f010523e:	8d 42 dd             	lea    -0x23(%edx),%eax
f0105241:	3c 55                	cmp    $0x55,%al
f0105243:	0f 87 df 02 00 00    	ja     f0105528 <vprintfmt+0x32c>
f0105249:	0f b6 c0             	movzbl %al,%eax
f010524c:	3e ff 24 85 40 7e 10 	notrack jmp *-0xfef81c0(,%eax,4)
f0105253:	f0 
f0105254:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0105257:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f010525b:	eb d8                	jmp    f0105235 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f010525d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105260:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0105264:	eb cf                	jmp    f0105235 <vprintfmt+0x39>
f0105266:	0f b6 d2             	movzbl %dl,%edx
f0105269:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f010526c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105271:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0105274:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105277:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010527b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010527e:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0105281:	83 f9 09             	cmp    $0x9,%ecx
f0105284:	77 52                	ja     f01052d8 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
f0105286:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0105289:	eb e9                	jmp    f0105274 <vprintfmt+0x78>
			precision = va_arg(ap, int);
f010528b:	8b 45 14             	mov    0x14(%ebp),%eax
f010528e:	8d 50 04             	lea    0x4(%eax),%edx
f0105291:	89 55 14             	mov    %edx,0x14(%ebp)
f0105294:	8b 00                	mov    (%eax),%eax
f0105296:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105299:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f010529c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01052a0:	79 93                	jns    f0105235 <vprintfmt+0x39>
				width = precision, precision = -1;
f01052a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01052a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01052a8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01052af:	eb 84                	jmp    f0105235 <vprintfmt+0x39>
f01052b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01052b4:	85 c0                	test   %eax,%eax
f01052b6:	ba 00 00 00 00       	mov    $0x0,%edx
f01052bb:	0f 49 d0             	cmovns %eax,%edx
f01052be:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01052c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01052c4:	e9 6c ff ff ff       	jmp    f0105235 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f01052c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01052cc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01052d3:	e9 5d ff ff ff       	jmp    f0105235 <vprintfmt+0x39>
f01052d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052db:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01052de:	eb bc                	jmp    f010529c <vprintfmt+0xa0>
			lflag++;
f01052e0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01052e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01052e6:	e9 4a ff ff ff       	jmp    f0105235 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
f01052eb:	8b 45 14             	mov    0x14(%ebp),%eax
f01052ee:	8d 50 04             	lea    0x4(%eax),%edx
f01052f1:	89 55 14             	mov    %edx,0x14(%ebp)
f01052f4:	83 ec 08             	sub    $0x8,%esp
f01052f7:	56                   	push   %esi
f01052f8:	ff 30                	pushl  (%eax)
f01052fa:	ff d3                	call   *%ebx
			break;
f01052fc:	83 c4 10             	add    $0x10,%esp
f01052ff:	e9 96 01 00 00       	jmp    f010549a <vprintfmt+0x29e>
			err = va_arg(ap, int);
f0105304:	8b 45 14             	mov    0x14(%ebp),%eax
f0105307:	8d 50 04             	lea    0x4(%eax),%edx
f010530a:	89 55 14             	mov    %edx,0x14(%ebp)
f010530d:	8b 00                	mov    (%eax),%eax
f010530f:	99                   	cltd   
f0105310:	31 d0                	xor    %edx,%eax
f0105312:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105314:	83 f8 0f             	cmp    $0xf,%eax
f0105317:	7f 20                	jg     f0105339 <vprintfmt+0x13d>
f0105319:	8b 14 85 a0 7f 10 f0 	mov    -0xfef8060(,%eax,4),%edx
f0105320:	85 d2                	test   %edx,%edx
f0105322:	74 15                	je     f0105339 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
f0105324:	52                   	push   %edx
f0105325:	68 0d 75 10 f0       	push   $0xf010750d
f010532a:	56                   	push   %esi
f010532b:	53                   	push   %ebx
f010532c:	e8 aa fe ff ff       	call   f01051db <printfmt>
f0105331:	83 c4 10             	add    $0x10,%esp
f0105334:	e9 61 01 00 00       	jmp    f010549a <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
f0105339:	50                   	push   %eax
f010533a:	68 1a 7d 10 f0       	push   $0xf0107d1a
f010533f:	56                   	push   %esi
f0105340:	53                   	push   %ebx
f0105341:	e8 95 fe ff ff       	call   f01051db <printfmt>
f0105346:	83 c4 10             	add    $0x10,%esp
f0105349:	e9 4c 01 00 00       	jmp    f010549a <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
f010534e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105351:	8d 50 04             	lea    0x4(%eax),%edx
f0105354:	89 55 14             	mov    %edx,0x14(%ebp)
f0105357:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
f0105359:	85 c9                	test   %ecx,%ecx
f010535b:	b8 13 7d 10 f0       	mov    $0xf0107d13,%eax
f0105360:	0f 45 c1             	cmovne %ecx,%eax
f0105363:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f0105366:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010536a:	7e 06                	jle    f0105372 <vprintfmt+0x176>
f010536c:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0105370:	75 0d                	jne    f010537f <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105372:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105375:	89 c7                	mov    %eax,%edi
f0105377:	03 45 e0             	add    -0x20(%ebp),%eax
f010537a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010537d:	eb 57                	jmp    f01053d6 <vprintfmt+0x1da>
f010537f:	83 ec 08             	sub    $0x8,%esp
f0105382:	ff 75 d8             	pushl  -0x28(%ebp)
f0105385:	ff 75 cc             	pushl  -0x34(%ebp)
f0105388:	e8 41 03 00 00       	call   f01056ce <strnlen>
f010538d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105390:	29 c2                	sub    %eax,%edx
f0105392:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105395:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105398:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f010539c:	89 5d 08             	mov    %ebx,0x8(%ebp)
f010539f:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
f01053a1:	85 db                	test   %ebx,%ebx
f01053a3:	7e 10                	jle    f01053b5 <vprintfmt+0x1b9>
					putch(padc, putdat);
f01053a5:	83 ec 08             	sub    $0x8,%esp
f01053a8:	56                   	push   %esi
f01053a9:	57                   	push   %edi
f01053aa:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01053ad:	83 eb 01             	sub    $0x1,%ebx
f01053b0:	83 c4 10             	add    $0x10,%esp
f01053b3:	eb ec                	jmp    f01053a1 <vprintfmt+0x1a5>
f01053b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01053b8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01053bb:	85 d2                	test   %edx,%edx
f01053bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01053c2:	0f 49 c2             	cmovns %edx,%eax
f01053c5:	29 c2                	sub    %eax,%edx
f01053c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01053ca:	eb a6                	jmp    f0105372 <vprintfmt+0x176>
					putch(ch, putdat);
f01053cc:	83 ec 08             	sub    $0x8,%esp
f01053cf:	56                   	push   %esi
f01053d0:	52                   	push   %edx
f01053d1:	ff d3                	call   *%ebx
f01053d3:	83 c4 10             	add    $0x10,%esp
f01053d6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01053d9:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01053db:	83 c7 01             	add    $0x1,%edi
f01053de:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01053e2:	0f be d0             	movsbl %al,%edx
f01053e5:	85 d2                	test   %edx,%edx
f01053e7:	74 42                	je     f010542b <vprintfmt+0x22f>
f01053e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01053ed:	78 06                	js     f01053f5 <vprintfmt+0x1f9>
f01053ef:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01053f3:	78 1e                	js     f0105413 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
f01053f5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01053f9:	74 d1                	je     f01053cc <vprintfmt+0x1d0>
f01053fb:	0f be c0             	movsbl %al,%eax
f01053fe:	83 e8 20             	sub    $0x20,%eax
f0105401:	83 f8 5e             	cmp    $0x5e,%eax
f0105404:	76 c6                	jbe    f01053cc <vprintfmt+0x1d0>
					putch('?', putdat);
f0105406:	83 ec 08             	sub    $0x8,%esp
f0105409:	56                   	push   %esi
f010540a:	6a 3f                	push   $0x3f
f010540c:	ff d3                	call   *%ebx
f010540e:	83 c4 10             	add    $0x10,%esp
f0105411:	eb c3                	jmp    f01053d6 <vprintfmt+0x1da>
f0105413:	89 cf                	mov    %ecx,%edi
f0105415:	eb 0e                	jmp    f0105425 <vprintfmt+0x229>
				putch(' ', putdat);
f0105417:	83 ec 08             	sub    $0x8,%esp
f010541a:	56                   	push   %esi
f010541b:	6a 20                	push   $0x20
f010541d:	ff d3                	call   *%ebx
			for (; width > 0; width--)
f010541f:	83 ef 01             	sub    $0x1,%edi
f0105422:	83 c4 10             	add    $0x10,%esp
f0105425:	85 ff                	test   %edi,%edi
f0105427:	7f ee                	jg     f0105417 <vprintfmt+0x21b>
f0105429:	eb 6f                	jmp    f010549a <vprintfmt+0x29e>
f010542b:	89 cf                	mov    %ecx,%edi
f010542d:	eb f6                	jmp    f0105425 <vprintfmt+0x229>
			num = getint(&ap, lflag);
f010542f:	89 ca                	mov    %ecx,%edx
f0105431:	8d 45 14             	lea    0x14(%ebp),%eax
f0105434:	e8 55 fd ff ff       	call   f010518e <getint>
f0105439:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010543c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
f010543f:	85 d2                	test   %edx,%edx
f0105441:	78 0b                	js     f010544e <vprintfmt+0x252>
			num = getint(&ap, lflag);
f0105443:	89 d1                	mov    %edx,%ecx
f0105445:	89 c2                	mov    %eax,%edx
			base = 10;
f0105447:	b8 0a 00 00 00       	mov    $0xa,%eax
f010544c:	eb 32                	jmp    f0105480 <vprintfmt+0x284>
				putch('-', putdat);
f010544e:	83 ec 08             	sub    $0x8,%esp
f0105451:	56                   	push   %esi
f0105452:	6a 2d                	push   $0x2d
f0105454:	ff d3                	call   *%ebx
				num = -(long long) num;
f0105456:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105459:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010545c:	f7 da                	neg    %edx
f010545e:	83 d1 00             	adc    $0x0,%ecx
f0105461:	f7 d9                	neg    %ecx
f0105463:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105466:	b8 0a 00 00 00       	mov    $0xa,%eax
f010546b:	eb 13                	jmp    f0105480 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
f010546d:	89 ca                	mov    %ecx,%edx
f010546f:	8d 45 14             	lea    0x14(%ebp),%eax
f0105472:	e8 e3 fc ff ff       	call   f010515a <getuint>
f0105477:	89 d1                	mov    %edx,%ecx
f0105479:	89 c2                	mov    %eax,%edx
			base = 10;
f010547b:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
f0105480:	83 ec 0c             	sub    $0xc,%esp
f0105483:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f0105487:	57                   	push   %edi
f0105488:	ff 75 e0             	pushl  -0x20(%ebp)
f010548b:	50                   	push   %eax
f010548c:	51                   	push   %ecx
f010548d:	52                   	push   %edx
f010548e:	89 f2                	mov    %esi,%edx
f0105490:	89 d8                	mov    %ebx,%eax
f0105492:	e8 1a fc ff ff       	call   f01050b1 <printnum>
			break;
f0105497:	83 c4 20             	add    $0x20,%esp
{
f010549a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010549d:	83 c7 01             	add    $0x1,%edi
f01054a0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01054a4:	83 f8 25             	cmp    $0x25,%eax
f01054a7:	0f 84 6a fd ff ff    	je     f0105217 <vprintfmt+0x1b>
			if (ch == '\0')
f01054ad:	85 c0                	test   %eax,%eax
f01054af:	0f 84 93 00 00 00    	je     f0105548 <vprintfmt+0x34c>
			putch(ch, putdat);
f01054b5:	83 ec 08             	sub    $0x8,%esp
f01054b8:	56                   	push   %esi
f01054b9:	50                   	push   %eax
f01054ba:	ff d3                	call   *%ebx
f01054bc:	83 c4 10             	add    $0x10,%esp
f01054bf:	eb dc                	jmp    f010549d <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
f01054c1:	89 ca                	mov    %ecx,%edx
f01054c3:	8d 45 14             	lea    0x14(%ebp),%eax
f01054c6:	e8 8f fc ff ff       	call   f010515a <getuint>
f01054cb:	89 d1                	mov    %edx,%ecx
f01054cd:	89 c2                	mov    %eax,%edx
			base = 8;
f01054cf:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f01054d4:	eb aa                	jmp    f0105480 <vprintfmt+0x284>
			putch('0', putdat);
f01054d6:	83 ec 08             	sub    $0x8,%esp
f01054d9:	56                   	push   %esi
f01054da:	6a 30                	push   $0x30
f01054dc:	ff d3                	call   *%ebx
			putch('x', putdat);
f01054de:	83 c4 08             	add    $0x8,%esp
f01054e1:	56                   	push   %esi
f01054e2:	6a 78                	push   $0x78
f01054e4:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
f01054e6:	8b 45 14             	mov    0x14(%ebp),%eax
f01054e9:	8d 50 04             	lea    0x4(%eax),%edx
f01054ec:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
f01054ef:	8b 10                	mov    (%eax),%edx
f01054f1:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01054f6:	83 c4 10             	add    $0x10,%esp
			base = 16;
f01054f9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01054fe:	eb 80                	jmp    f0105480 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
f0105500:	89 ca                	mov    %ecx,%edx
f0105502:	8d 45 14             	lea    0x14(%ebp),%eax
f0105505:	e8 50 fc ff ff       	call   f010515a <getuint>
f010550a:	89 d1                	mov    %edx,%ecx
f010550c:	89 c2                	mov    %eax,%edx
			base = 16;
f010550e:	b8 10 00 00 00       	mov    $0x10,%eax
f0105513:	e9 68 ff ff ff       	jmp    f0105480 <vprintfmt+0x284>
			putch(ch, putdat);
f0105518:	83 ec 08             	sub    $0x8,%esp
f010551b:	56                   	push   %esi
f010551c:	6a 25                	push   $0x25
f010551e:	ff d3                	call   *%ebx
			break;
f0105520:	83 c4 10             	add    $0x10,%esp
f0105523:	e9 72 ff ff ff       	jmp    f010549a <vprintfmt+0x29e>
			putch('%', putdat);
f0105528:	83 ec 08             	sub    $0x8,%esp
f010552b:	56                   	push   %esi
f010552c:	6a 25                	push   $0x25
f010552e:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105530:	83 c4 10             	add    $0x10,%esp
f0105533:	89 f8                	mov    %edi,%eax
f0105535:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105539:	74 05                	je     f0105540 <vprintfmt+0x344>
f010553b:	83 e8 01             	sub    $0x1,%eax
f010553e:	eb f5                	jmp    f0105535 <vprintfmt+0x339>
f0105540:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105543:	e9 52 ff ff ff       	jmp    f010549a <vprintfmt+0x29e>
}
f0105548:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010554b:	5b                   	pop    %ebx
f010554c:	5e                   	pop    %esi
f010554d:	5f                   	pop    %edi
f010554e:	5d                   	pop    %ebp
f010554f:	c3                   	ret    

f0105550 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105550:	f3 0f 1e fb          	endbr32 
f0105554:	55                   	push   %ebp
f0105555:	89 e5                	mov    %esp,%ebp
f0105557:	83 ec 18             	sub    $0x18,%esp
f010555a:	8b 45 08             	mov    0x8(%ebp),%eax
f010555d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105560:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105563:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105567:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010556a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105571:	85 c0                	test   %eax,%eax
f0105573:	74 26                	je     f010559b <vsnprintf+0x4b>
f0105575:	85 d2                	test   %edx,%edx
f0105577:	7e 22                	jle    f010559b <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105579:	ff 75 14             	pushl  0x14(%ebp)
f010557c:	ff 75 10             	pushl  0x10(%ebp)
f010557f:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105582:	50                   	push   %eax
f0105583:	68 ba 51 10 f0       	push   $0xf01051ba
f0105588:	e8 6f fc ff ff       	call   f01051fc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010558d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105590:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105593:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105596:	83 c4 10             	add    $0x10,%esp
}
f0105599:	c9                   	leave  
f010559a:	c3                   	ret    
		return -E_INVAL;
f010559b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01055a0:	eb f7                	jmp    f0105599 <vsnprintf+0x49>

f01055a2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01055a2:	f3 0f 1e fb          	endbr32 
f01055a6:	55                   	push   %ebp
f01055a7:	89 e5                	mov    %esp,%ebp
f01055a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01055ac:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01055af:	50                   	push   %eax
f01055b0:	ff 75 10             	pushl  0x10(%ebp)
f01055b3:	ff 75 0c             	pushl  0xc(%ebp)
f01055b6:	ff 75 08             	pushl  0x8(%ebp)
f01055b9:	e8 92 ff ff ff       	call   f0105550 <vsnprintf>
	va_end(ap);

	return rc;
}
f01055be:	c9                   	leave  
f01055bf:	c3                   	ret    

f01055c0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01055c0:	f3 0f 1e fb          	endbr32 
f01055c4:	55                   	push   %ebp
f01055c5:	89 e5                	mov    %esp,%ebp
f01055c7:	57                   	push   %edi
f01055c8:	56                   	push   %esi
f01055c9:	53                   	push   %ebx
f01055ca:	83 ec 0c             	sub    $0xc,%esp
f01055cd:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f01055d0:	85 c0                	test   %eax,%eax
f01055d2:	74 11                	je     f01055e5 <readline+0x25>
		cprintf("%s", prompt);
f01055d4:	83 ec 08             	sub    $0x8,%esp
f01055d7:	50                   	push   %eax
f01055d8:	68 0d 75 10 f0       	push   $0xf010750d
f01055dd:	e8 2e e3 ff ff       	call   f0103910 <cprintf>
f01055e2:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f01055e5:	83 ec 0c             	sub    $0xc,%esp
f01055e8:	6a 00                	push   $0x0
f01055ea:	e8 7a b3 ff ff       	call   f0100969 <iscons>
f01055ef:	89 c7                	mov    %eax,%edi
f01055f1:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01055f4:	be 00 00 00 00       	mov    $0x0,%esi
f01055f9:	eb 57                	jmp    f0105652 <readline+0x92>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01055fb:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
f0105600:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105603:	75 08                	jne    f010560d <readline+0x4d>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105605:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105608:	5b                   	pop    %ebx
f0105609:	5e                   	pop    %esi
f010560a:	5f                   	pop    %edi
f010560b:	5d                   	pop    %ebp
f010560c:	c3                   	ret    
				cprintf("read error: %e\n", c);
f010560d:	83 ec 08             	sub    $0x8,%esp
f0105610:	53                   	push   %ebx
f0105611:	68 ff 7f 10 f0       	push   $0xf0107fff
f0105616:	e8 f5 e2 ff ff       	call   f0103910 <cprintf>
f010561b:	83 c4 10             	add    $0x10,%esp
			return NULL;
f010561e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105623:	eb e0                	jmp    f0105605 <readline+0x45>
			if (echoing)
f0105625:	85 ff                	test   %edi,%edi
f0105627:	75 05                	jne    f010562e <readline+0x6e>
			i--;
f0105629:	83 ee 01             	sub    $0x1,%esi
f010562c:	eb 24                	jmp    f0105652 <readline+0x92>
				cputchar('\b');
f010562e:	83 ec 0c             	sub    $0xc,%esp
f0105631:	6a 08                	push   $0x8
f0105633:	e8 08 b3 ff ff       	call   f0100940 <cputchar>
f0105638:	83 c4 10             	add    $0x10,%esp
f010563b:	eb ec                	jmp    f0105629 <readline+0x69>
				cputchar(c);
f010563d:	83 ec 0c             	sub    $0xc,%esp
f0105640:	53                   	push   %ebx
f0105641:	e8 fa b2 ff ff       	call   f0100940 <cputchar>
f0105646:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105649:	88 9e 80 1a 22 f0    	mov    %bl,-0xfdde580(%esi)
f010564f:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0105652:	e8 fd b2 ff ff       	call   f0100954 <getchar>
f0105657:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105659:	85 c0                	test   %eax,%eax
f010565b:	78 9e                	js     f01055fb <readline+0x3b>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010565d:	83 f8 08             	cmp    $0x8,%eax
f0105660:	0f 94 c2             	sete   %dl
f0105663:	83 f8 7f             	cmp    $0x7f,%eax
f0105666:	0f 94 c0             	sete   %al
f0105669:	08 c2                	or     %al,%dl
f010566b:	74 04                	je     f0105671 <readline+0xb1>
f010566d:	85 f6                	test   %esi,%esi
f010566f:	7f b4                	jg     f0105625 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105671:	83 fb 1f             	cmp    $0x1f,%ebx
f0105674:	7e 0e                	jle    f0105684 <readline+0xc4>
f0105676:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010567c:	7f 06                	jg     f0105684 <readline+0xc4>
			if (echoing)
f010567e:	85 ff                	test   %edi,%edi
f0105680:	74 c7                	je     f0105649 <readline+0x89>
f0105682:	eb b9                	jmp    f010563d <readline+0x7d>
		} else if (c == '\n' || c == '\r') {
f0105684:	83 fb 0a             	cmp    $0xa,%ebx
f0105687:	74 05                	je     f010568e <readline+0xce>
f0105689:	83 fb 0d             	cmp    $0xd,%ebx
f010568c:	75 c4                	jne    f0105652 <readline+0x92>
			if (echoing)
f010568e:	85 ff                	test   %edi,%edi
f0105690:	75 11                	jne    f01056a3 <readline+0xe3>
			buf[i] = 0;
f0105692:	c6 86 80 1a 22 f0 00 	movb   $0x0,-0xfdde580(%esi)
			return buf;
f0105699:	b8 80 1a 22 f0       	mov    $0xf0221a80,%eax
f010569e:	e9 62 ff ff ff       	jmp    f0105605 <readline+0x45>
				cputchar('\n');
f01056a3:	83 ec 0c             	sub    $0xc,%esp
f01056a6:	6a 0a                	push   $0xa
f01056a8:	e8 93 b2 ff ff       	call   f0100940 <cputchar>
f01056ad:	83 c4 10             	add    $0x10,%esp
f01056b0:	eb e0                	jmp    f0105692 <readline+0xd2>

f01056b2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01056b2:	f3 0f 1e fb          	endbr32 
f01056b6:	55                   	push   %ebp
f01056b7:	89 e5                	mov    %esp,%ebp
f01056b9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01056bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01056c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01056c5:	74 05                	je     f01056cc <strlen+0x1a>
		n++;
f01056c7:	83 c0 01             	add    $0x1,%eax
f01056ca:	eb f5                	jmp    f01056c1 <strlen+0xf>
	return n;
}
f01056cc:	5d                   	pop    %ebp
f01056cd:	c3                   	ret    

f01056ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01056ce:	f3 0f 1e fb          	endbr32 
f01056d2:	55                   	push   %ebp
f01056d3:	89 e5                	mov    %esp,%ebp
f01056d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01056db:	b8 00 00 00 00       	mov    $0x0,%eax
f01056e0:	39 d0                	cmp    %edx,%eax
f01056e2:	74 0d                	je     f01056f1 <strnlen+0x23>
f01056e4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01056e8:	74 05                	je     f01056ef <strnlen+0x21>
		n++;
f01056ea:	83 c0 01             	add    $0x1,%eax
f01056ed:	eb f1                	jmp    f01056e0 <strnlen+0x12>
f01056ef:	89 c2                	mov    %eax,%edx
	return n;
}
f01056f1:	89 d0                	mov    %edx,%eax
f01056f3:	5d                   	pop    %ebp
f01056f4:	c3                   	ret    

f01056f5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01056f5:	f3 0f 1e fb          	endbr32 
f01056f9:	55                   	push   %ebp
f01056fa:	89 e5                	mov    %esp,%ebp
f01056fc:	53                   	push   %ebx
f01056fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105700:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105703:	b8 00 00 00 00       	mov    $0x0,%eax
f0105708:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f010570c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f010570f:	83 c0 01             	add    $0x1,%eax
f0105712:	84 d2                	test   %dl,%dl
f0105714:	75 f2                	jne    f0105708 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f0105716:	89 c8                	mov    %ecx,%eax
f0105718:	5b                   	pop    %ebx
f0105719:	5d                   	pop    %ebp
f010571a:	c3                   	ret    

f010571b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010571b:	f3 0f 1e fb          	endbr32 
f010571f:	55                   	push   %ebp
f0105720:	89 e5                	mov    %esp,%ebp
f0105722:	53                   	push   %ebx
f0105723:	83 ec 10             	sub    $0x10,%esp
f0105726:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105729:	53                   	push   %ebx
f010572a:	e8 83 ff ff ff       	call   f01056b2 <strlen>
f010572f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0105732:	ff 75 0c             	pushl  0xc(%ebp)
f0105735:	01 d8                	add    %ebx,%eax
f0105737:	50                   	push   %eax
f0105738:	e8 b8 ff ff ff       	call   f01056f5 <strcpy>
	return dst;
}
f010573d:	89 d8                	mov    %ebx,%eax
f010573f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105742:	c9                   	leave  
f0105743:	c3                   	ret    

f0105744 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105744:	f3 0f 1e fb          	endbr32 
f0105748:	55                   	push   %ebp
f0105749:	89 e5                	mov    %esp,%ebp
f010574b:	56                   	push   %esi
f010574c:	53                   	push   %ebx
f010574d:	8b 75 08             	mov    0x8(%ebp),%esi
f0105750:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105753:	89 f3                	mov    %esi,%ebx
f0105755:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105758:	89 f0                	mov    %esi,%eax
f010575a:	39 d8                	cmp    %ebx,%eax
f010575c:	74 11                	je     f010576f <strncpy+0x2b>
		*dst++ = *src;
f010575e:	83 c0 01             	add    $0x1,%eax
f0105761:	0f b6 0a             	movzbl (%edx),%ecx
f0105764:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105767:	80 f9 01             	cmp    $0x1,%cl
f010576a:	83 da ff             	sbb    $0xffffffff,%edx
f010576d:	eb eb                	jmp    f010575a <strncpy+0x16>
	}
	return ret;
}
f010576f:	89 f0                	mov    %esi,%eax
f0105771:	5b                   	pop    %ebx
f0105772:	5e                   	pop    %esi
f0105773:	5d                   	pop    %ebp
f0105774:	c3                   	ret    

f0105775 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105775:	f3 0f 1e fb          	endbr32 
f0105779:	55                   	push   %ebp
f010577a:	89 e5                	mov    %esp,%ebp
f010577c:	56                   	push   %esi
f010577d:	53                   	push   %ebx
f010577e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105781:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105784:	8b 55 10             	mov    0x10(%ebp),%edx
f0105787:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105789:	85 d2                	test   %edx,%edx
f010578b:	74 21                	je     f01057ae <strlcpy+0x39>
f010578d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105791:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0105793:	39 c2                	cmp    %eax,%edx
f0105795:	74 14                	je     f01057ab <strlcpy+0x36>
f0105797:	0f b6 19             	movzbl (%ecx),%ebx
f010579a:	84 db                	test   %bl,%bl
f010579c:	74 0b                	je     f01057a9 <strlcpy+0x34>
			*dst++ = *src++;
f010579e:	83 c1 01             	add    $0x1,%ecx
f01057a1:	83 c2 01             	add    $0x1,%edx
f01057a4:	88 5a ff             	mov    %bl,-0x1(%edx)
f01057a7:	eb ea                	jmp    f0105793 <strlcpy+0x1e>
f01057a9:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f01057ab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01057ae:	29 f0                	sub    %esi,%eax
}
f01057b0:	5b                   	pop    %ebx
f01057b1:	5e                   	pop    %esi
f01057b2:	5d                   	pop    %ebp
f01057b3:	c3                   	ret    

f01057b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01057b4:	f3 0f 1e fb          	endbr32 
f01057b8:	55                   	push   %ebp
f01057b9:	89 e5                	mov    %esp,%ebp
f01057bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01057be:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01057c1:	0f b6 01             	movzbl (%ecx),%eax
f01057c4:	84 c0                	test   %al,%al
f01057c6:	74 0c                	je     f01057d4 <strcmp+0x20>
f01057c8:	3a 02                	cmp    (%edx),%al
f01057ca:	75 08                	jne    f01057d4 <strcmp+0x20>
		p++, q++;
f01057cc:	83 c1 01             	add    $0x1,%ecx
f01057cf:	83 c2 01             	add    $0x1,%edx
f01057d2:	eb ed                	jmp    f01057c1 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01057d4:	0f b6 c0             	movzbl %al,%eax
f01057d7:	0f b6 12             	movzbl (%edx),%edx
f01057da:	29 d0                	sub    %edx,%eax
}
f01057dc:	5d                   	pop    %ebp
f01057dd:	c3                   	ret    

f01057de <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01057de:	f3 0f 1e fb          	endbr32 
f01057e2:	55                   	push   %ebp
f01057e3:	89 e5                	mov    %esp,%ebp
f01057e5:	53                   	push   %ebx
f01057e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01057e9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01057ec:	89 c3                	mov    %eax,%ebx
f01057ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01057f1:	eb 06                	jmp    f01057f9 <strncmp+0x1b>
		n--, p++, q++;
f01057f3:	83 c0 01             	add    $0x1,%eax
f01057f6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01057f9:	39 d8                	cmp    %ebx,%eax
f01057fb:	74 16                	je     f0105813 <strncmp+0x35>
f01057fd:	0f b6 08             	movzbl (%eax),%ecx
f0105800:	84 c9                	test   %cl,%cl
f0105802:	74 04                	je     f0105808 <strncmp+0x2a>
f0105804:	3a 0a                	cmp    (%edx),%cl
f0105806:	74 eb                	je     f01057f3 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105808:	0f b6 00             	movzbl (%eax),%eax
f010580b:	0f b6 12             	movzbl (%edx),%edx
f010580e:	29 d0                	sub    %edx,%eax
}
f0105810:	5b                   	pop    %ebx
f0105811:	5d                   	pop    %ebp
f0105812:	c3                   	ret    
		return 0;
f0105813:	b8 00 00 00 00       	mov    $0x0,%eax
f0105818:	eb f6                	jmp    f0105810 <strncmp+0x32>

f010581a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010581a:	f3 0f 1e fb          	endbr32 
f010581e:	55                   	push   %ebp
f010581f:	89 e5                	mov    %esp,%ebp
f0105821:	8b 45 08             	mov    0x8(%ebp),%eax
f0105824:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105828:	0f b6 10             	movzbl (%eax),%edx
f010582b:	84 d2                	test   %dl,%dl
f010582d:	74 09                	je     f0105838 <strchr+0x1e>
		if (*s == c)
f010582f:	38 ca                	cmp    %cl,%dl
f0105831:	74 0a                	je     f010583d <strchr+0x23>
	for (; *s; s++)
f0105833:	83 c0 01             	add    $0x1,%eax
f0105836:	eb f0                	jmp    f0105828 <strchr+0xe>
			return (char *) s;
	return 0;
f0105838:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010583d:	5d                   	pop    %ebp
f010583e:	c3                   	ret    

f010583f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010583f:	f3 0f 1e fb          	endbr32 
f0105843:	55                   	push   %ebp
f0105844:	89 e5                	mov    %esp,%ebp
f0105846:	8b 45 08             	mov    0x8(%ebp),%eax
f0105849:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010584d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105850:	38 ca                	cmp    %cl,%dl
f0105852:	74 09                	je     f010585d <strfind+0x1e>
f0105854:	84 d2                	test   %dl,%dl
f0105856:	74 05                	je     f010585d <strfind+0x1e>
	for (; *s; s++)
f0105858:	83 c0 01             	add    $0x1,%eax
f010585b:	eb f0                	jmp    f010584d <strfind+0xe>
			break;
	return (char *) s;
}
f010585d:	5d                   	pop    %ebp
f010585e:	c3                   	ret    

f010585f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010585f:	f3 0f 1e fb          	endbr32 
f0105863:	55                   	push   %ebp
f0105864:	89 e5                	mov    %esp,%ebp
f0105866:	57                   	push   %edi
f0105867:	56                   	push   %esi
f0105868:	53                   	push   %ebx
f0105869:	8b 55 08             	mov    0x8(%ebp),%edx
f010586c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
f010586f:	85 c9                	test   %ecx,%ecx
f0105871:	74 33                	je     f01058a6 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105873:	89 d0                	mov    %edx,%eax
f0105875:	09 c8                	or     %ecx,%eax
f0105877:	a8 03                	test   $0x3,%al
f0105879:	75 23                	jne    f010589e <memset+0x3f>
		c &= 0xFF;
f010587b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010587f:	89 d8                	mov    %ebx,%eax
f0105881:	c1 e0 08             	shl    $0x8,%eax
f0105884:	89 df                	mov    %ebx,%edi
f0105886:	c1 e7 18             	shl    $0x18,%edi
f0105889:	89 de                	mov    %ebx,%esi
f010588b:	c1 e6 10             	shl    $0x10,%esi
f010588e:	09 f7                	or     %esi,%edi
f0105890:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
f0105892:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105895:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
f0105897:	89 d7                	mov    %edx,%edi
f0105899:	fc                   	cld    
f010589a:	f3 ab                	rep stos %eax,%es:(%edi)
f010589c:	eb 08                	jmp    f01058a6 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010589e:	89 d7                	mov    %edx,%edi
f01058a0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01058a3:	fc                   	cld    
f01058a4:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
f01058a6:	89 d0                	mov    %edx,%eax
f01058a8:	5b                   	pop    %ebx
f01058a9:	5e                   	pop    %esi
f01058aa:	5f                   	pop    %edi
f01058ab:	5d                   	pop    %ebp
f01058ac:	c3                   	ret    

f01058ad <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01058ad:	f3 0f 1e fb          	endbr32 
f01058b1:	55                   	push   %ebp
f01058b2:	89 e5                	mov    %esp,%ebp
f01058b4:	57                   	push   %edi
f01058b5:	56                   	push   %esi
f01058b6:	8b 45 08             	mov    0x8(%ebp),%eax
f01058b9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01058bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01058bf:	39 c6                	cmp    %eax,%esi
f01058c1:	73 32                	jae    f01058f5 <memmove+0x48>
f01058c3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01058c6:	39 c2                	cmp    %eax,%edx
f01058c8:	76 2b                	jbe    f01058f5 <memmove+0x48>
		s += n;
		d += n;
f01058ca:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01058cd:	89 fe                	mov    %edi,%esi
f01058cf:	09 ce                	or     %ecx,%esi
f01058d1:	09 d6                	or     %edx,%esi
f01058d3:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01058d9:	75 0e                	jne    f01058e9 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01058db:	83 ef 04             	sub    $0x4,%edi
f01058de:	8d 72 fc             	lea    -0x4(%edx),%esi
f01058e1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01058e4:	fd                   	std    
f01058e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01058e7:	eb 09                	jmp    f01058f2 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01058e9:	83 ef 01             	sub    $0x1,%edi
f01058ec:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01058ef:	fd                   	std    
f01058f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01058f2:	fc                   	cld    
f01058f3:	eb 1a                	jmp    f010590f <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01058f5:	89 c2                	mov    %eax,%edx
f01058f7:	09 ca                	or     %ecx,%edx
f01058f9:	09 f2                	or     %esi,%edx
f01058fb:	f6 c2 03             	test   $0x3,%dl
f01058fe:	75 0a                	jne    f010590a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105900:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105903:	89 c7                	mov    %eax,%edi
f0105905:	fc                   	cld    
f0105906:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105908:	eb 05                	jmp    f010590f <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f010590a:	89 c7                	mov    %eax,%edi
f010590c:	fc                   	cld    
f010590d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010590f:	5e                   	pop    %esi
f0105910:	5f                   	pop    %edi
f0105911:	5d                   	pop    %ebp
f0105912:	c3                   	ret    

f0105913 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105913:	f3 0f 1e fb          	endbr32 
f0105917:	55                   	push   %ebp
f0105918:	89 e5                	mov    %esp,%ebp
f010591a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010591d:	ff 75 10             	pushl  0x10(%ebp)
f0105920:	ff 75 0c             	pushl  0xc(%ebp)
f0105923:	ff 75 08             	pushl  0x8(%ebp)
f0105926:	e8 82 ff ff ff       	call   f01058ad <memmove>
}
f010592b:	c9                   	leave  
f010592c:	c3                   	ret    

f010592d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010592d:	f3 0f 1e fb          	endbr32 
f0105931:	55                   	push   %ebp
f0105932:	89 e5                	mov    %esp,%ebp
f0105934:	56                   	push   %esi
f0105935:	53                   	push   %ebx
f0105936:	8b 45 08             	mov    0x8(%ebp),%eax
f0105939:	8b 55 0c             	mov    0xc(%ebp),%edx
f010593c:	89 c6                	mov    %eax,%esi
f010593e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105941:	39 f0                	cmp    %esi,%eax
f0105943:	74 1c                	je     f0105961 <memcmp+0x34>
		if (*s1 != *s2)
f0105945:	0f b6 08             	movzbl (%eax),%ecx
f0105948:	0f b6 1a             	movzbl (%edx),%ebx
f010594b:	38 d9                	cmp    %bl,%cl
f010594d:	75 08                	jne    f0105957 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010594f:	83 c0 01             	add    $0x1,%eax
f0105952:	83 c2 01             	add    $0x1,%edx
f0105955:	eb ea                	jmp    f0105941 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f0105957:	0f b6 c1             	movzbl %cl,%eax
f010595a:	0f b6 db             	movzbl %bl,%ebx
f010595d:	29 d8                	sub    %ebx,%eax
f010595f:	eb 05                	jmp    f0105966 <memcmp+0x39>
	}

	return 0;
f0105961:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105966:	5b                   	pop    %ebx
f0105967:	5e                   	pop    %esi
f0105968:	5d                   	pop    %ebp
f0105969:	c3                   	ret    

f010596a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010596a:	f3 0f 1e fb          	endbr32 
f010596e:	55                   	push   %ebp
f010596f:	89 e5                	mov    %esp,%ebp
f0105971:	8b 45 08             	mov    0x8(%ebp),%eax
f0105974:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105977:	89 c2                	mov    %eax,%edx
f0105979:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010597c:	39 d0                	cmp    %edx,%eax
f010597e:	73 09                	jae    f0105989 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105980:	38 08                	cmp    %cl,(%eax)
f0105982:	74 05                	je     f0105989 <memfind+0x1f>
	for (; s < ends; s++)
f0105984:	83 c0 01             	add    $0x1,%eax
f0105987:	eb f3                	jmp    f010597c <memfind+0x12>
			break;
	return (void *) s;
}
f0105989:	5d                   	pop    %ebp
f010598a:	c3                   	ret    

f010598b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010598b:	f3 0f 1e fb          	endbr32 
f010598f:	55                   	push   %ebp
f0105990:	89 e5                	mov    %esp,%ebp
f0105992:	57                   	push   %edi
f0105993:	56                   	push   %esi
f0105994:	53                   	push   %ebx
f0105995:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105998:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010599b:	eb 03                	jmp    f01059a0 <strtol+0x15>
		s++;
f010599d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01059a0:	0f b6 01             	movzbl (%ecx),%eax
f01059a3:	3c 20                	cmp    $0x20,%al
f01059a5:	74 f6                	je     f010599d <strtol+0x12>
f01059a7:	3c 09                	cmp    $0x9,%al
f01059a9:	74 f2                	je     f010599d <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f01059ab:	3c 2b                	cmp    $0x2b,%al
f01059ad:	74 2a                	je     f01059d9 <strtol+0x4e>
	int neg = 0;
f01059af:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01059b4:	3c 2d                	cmp    $0x2d,%al
f01059b6:	74 2b                	je     f01059e3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01059b8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01059be:	75 0f                	jne    f01059cf <strtol+0x44>
f01059c0:	80 39 30             	cmpb   $0x30,(%ecx)
f01059c3:	74 28                	je     f01059ed <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01059c5:	85 db                	test   %ebx,%ebx
f01059c7:	b8 0a 00 00 00       	mov    $0xa,%eax
f01059cc:	0f 44 d8             	cmove  %eax,%ebx
f01059cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01059d4:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01059d7:	eb 46                	jmp    f0105a1f <strtol+0x94>
		s++;
f01059d9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01059dc:	bf 00 00 00 00       	mov    $0x0,%edi
f01059e1:	eb d5                	jmp    f01059b8 <strtol+0x2d>
		s++, neg = 1;
f01059e3:	83 c1 01             	add    $0x1,%ecx
f01059e6:	bf 01 00 00 00       	mov    $0x1,%edi
f01059eb:	eb cb                	jmp    f01059b8 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01059ed:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01059f1:	74 0e                	je     f0105a01 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01059f3:	85 db                	test   %ebx,%ebx
f01059f5:	75 d8                	jne    f01059cf <strtol+0x44>
		s++, base = 8;
f01059f7:	83 c1 01             	add    $0x1,%ecx
f01059fa:	bb 08 00 00 00       	mov    $0x8,%ebx
f01059ff:	eb ce                	jmp    f01059cf <strtol+0x44>
		s += 2, base = 16;
f0105a01:	83 c1 02             	add    $0x2,%ecx
f0105a04:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105a09:	eb c4                	jmp    f01059cf <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0105a0b:	0f be d2             	movsbl %dl,%edx
f0105a0e:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105a11:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105a14:	7d 3a                	jge    f0105a50 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0105a16:	83 c1 01             	add    $0x1,%ecx
f0105a19:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105a1d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105a1f:	0f b6 11             	movzbl (%ecx),%edx
f0105a22:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105a25:	89 f3                	mov    %esi,%ebx
f0105a27:	80 fb 09             	cmp    $0x9,%bl
f0105a2a:	76 df                	jbe    f0105a0b <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f0105a2c:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105a2f:	89 f3                	mov    %esi,%ebx
f0105a31:	80 fb 19             	cmp    $0x19,%bl
f0105a34:	77 08                	ja     f0105a3e <strtol+0xb3>
			dig = *s - 'a' + 10;
f0105a36:	0f be d2             	movsbl %dl,%edx
f0105a39:	83 ea 57             	sub    $0x57,%edx
f0105a3c:	eb d3                	jmp    f0105a11 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f0105a3e:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105a41:	89 f3                	mov    %esi,%ebx
f0105a43:	80 fb 19             	cmp    $0x19,%bl
f0105a46:	77 08                	ja     f0105a50 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0105a48:	0f be d2             	movsbl %dl,%edx
f0105a4b:	83 ea 37             	sub    $0x37,%edx
f0105a4e:	eb c1                	jmp    f0105a11 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105a50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105a54:	74 05                	je     f0105a5b <strtol+0xd0>
		*endptr = (char *) s;
f0105a56:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105a59:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105a5b:	89 c2                	mov    %eax,%edx
f0105a5d:	f7 da                	neg    %edx
f0105a5f:	85 ff                	test   %edi,%edi
f0105a61:	0f 45 c2             	cmovne %edx,%eax
}
f0105a64:	5b                   	pop    %ebx
f0105a65:	5e                   	pop    %esi
f0105a66:	5f                   	pop    %edi
f0105a67:	5d                   	pop    %ebp
f0105a68:	c3                   	ret    
f0105a69:	66 90                	xchg   %ax,%ax
f0105a6b:	90                   	nop

f0105a6c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105a6c:	fa                   	cli    

	xorw    %ax, %ax
f0105a6d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105a6f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105a71:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a73:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105a75:	0f 01 16             	lgdtl  (%esi)
f0105a78:	7c 70                	jl     f0105aea <gdtdesc+0x2>
	movl    %cr0, %eax
f0105a7a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105a7d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105a81:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105a84:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105a8a:	08 00                	or     %al,(%eax)

f0105a8c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105a8c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105a90:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105a92:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a94:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105a96:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105a9a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105a9c:	8e e8                	mov    %eax,%gs

	

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105a9e:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl    %eax, %cr3
f0105aa3:	0f 22 d8             	mov    %eax,%cr3

	# Turn on large pages using register %cr4 and flag CR4_PSE
    movl    %cr4, %eax
f0105aa6:	0f 20 e0             	mov    %cr4,%eax
    orl    $(CR4_PSE), %eax
f0105aa9:	83 c8 10             	or     $0x10,%eax
    movl    %eax, %cr4
f0105aac:	0f 22 e0             	mov    %eax,%cr4

	# Turn on paging.
	movl    %cr0, %eax
f0105aaf:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105ab2:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105ab7:	0f 22 c0             	mov    %eax,%cr0

	

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105aba:	8b 25 84 2e 22 f0    	mov    0xf0222e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105ac0:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105ac5:	b8 52 02 10 f0       	mov    $0xf0100252,%eax
	call    *%eax
f0105aca:	ff d0                	call   *%eax

f0105acc <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105acc:	eb fe                	jmp    f0105acc <spin>
f0105ace:	66 90                	xchg   %ax,%ax

f0105ad0 <gdt>:
	...
f0105ad8:	ff                   	(bad)  
f0105ad9:	ff 00                	incl   (%eax)
f0105adb:	00 00                	add    %al,(%eax)
f0105add:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105ae4:	00                   	.byte 0x0
f0105ae5:	92                   	xchg   %eax,%edx
f0105ae6:	cf                   	iret   
	...

f0105ae8 <gdtdesc>:
f0105ae8:	17                   	pop    %ss
f0105ae9:	00 64 70 00          	add    %ah,0x0(%eax,%esi,2)
	...

f0105aee <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105aee:	90                   	nop

f0105aef <inb>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105aef:	89 c2                	mov    %eax,%edx
f0105af1:	ec                   	in     (%dx),%al
}
f0105af2:	c3                   	ret    

f0105af3 <outb>:
{
f0105af3:	89 c1                	mov    %eax,%ecx
f0105af5:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105af7:	89 ca                	mov    %ecx,%edx
f0105af9:	ee                   	out    %al,(%dx)
}
f0105afa:	c3                   	ret    

f0105afb <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0105afb:	55                   	push   %ebp
f0105afc:	89 e5                	mov    %esp,%ebp
f0105afe:	56                   	push   %esi
f0105aff:	53                   	push   %ebx
f0105b00:	89 c6                	mov    %eax,%esi
	int i, sum;

	sum = 0;
f0105b02:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < len; i++)
f0105b07:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105b0c:	39 d1                	cmp    %edx,%ecx
f0105b0e:	7d 0b                	jge    f0105b1b <sum+0x20>
		sum += ((uint8_t *)addr)[i];
f0105b10:	0f b6 1c 0e          	movzbl (%esi,%ecx,1),%ebx
f0105b14:	01 d8                	add    %ebx,%eax
	for (i = 0; i < len; i++)
f0105b16:	83 c1 01             	add    $0x1,%ecx
f0105b19:	eb f1                	jmp    f0105b0c <sum+0x11>
	return sum;
}
f0105b1b:	5b                   	pop    %ebx
f0105b1c:	5e                   	pop    %esi
f0105b1d:	5d                   	pop    %ebp
f0105b1e:	c3                   	ret    

f0105b1f <_kaddr>:
{
f0105b1f:	55                   	push   %ebp
f0105b20:	89 e5                	mov    %esp,%ebp
f0105b22:	53                   	push   %ebx
f0105b23:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f0105b26:	89 cb                	mov    %ecx,%ebx
f0105b28:	c1 eb 0c             	shr    $0xc,%ebx
f0105b2b:	3b 1d 88 2e 22 f0    	cmp    0xf0222e88,%ebx
f0105b31:	73 0b                	jae    f0105b3e <_kaddr+0x1f>
	return (void *)(pa + KERNBASE);
f0105b33:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f0105b39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105b3c:	c9                   	leave  
f0105b3d:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b3e:	51                   	push   %ecx
f0105b3f:	68 cc 65 10 f0       	push   $0xf01065cc
f0105b44:	52                   	push   %edx
f0105b45:	50                   	push   %eax
f0105b46:	e8 1f a5 ff ff       	call   f010006a <_panic>

f0105b4b <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105b4b:	55                   	push   %ebp
f0105b4c:	89 e5                	mov    %esp,%ebp
f0105b4e:	57                   	push   %edi
f0105b4f:	56                   	push   %esi
f0105b50:	53                   	push   %ebx
f0105b51:	83 ec 0c             	sub    $0xc,%esp
f0105b54:	89 c7                	mov    %eax,%edi
f0105b56:	89 d6                	mov    %edx,%esi
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105b58:	89 c1                	mov    %eax,%ecx
f0105b5a:	ba 57 00 00 00       	mov    $0x57,%edx
f0105b5f:	b8 9d 81 10 f0       	mov    $0xf010819d,%eax
f0105b64:	e8 b6 ff ff ff       	call   f0105b1f <_kaddr>
f0105b69:	89 c3                	mov    %eax,%ebx
f0105b6b:	8d 0c 3e             	lea    (%esi,%edi,1),%ecx
f0105b6e:	ba 57 00 00 00       	mov    $0x57,%edx
f0105b73:	b8 9d 81 10 f0       	mov    $0xf010819d,%eax
f0105b78:	e8 a2 ff ff ff       	call   f0105b1f <_kaddr>
f0105b7d:	89 c6                	mov    %eax,%esi

	for (; mp < end; mp++)
f0105b7f:	eb 03                	jmp    f0105b84 <mpsearch1+0x39>
f0105b81:	83 c3 10             	add    $0x10,%ebx
f0105b84:	39 f3                	cmp    %esi,%ebx
f0105b86:	73 29                	jae    f0105bb1 <mpsearch1+0x66>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105b88:	83 ec 04             	sub    $0x4,%esp
f0105b8b:	6a 04                	push   $0x4
f0105b8d:	68 ad 81 10 f0       	push   $0xf01081ad
f0105b92:	53                   	push   %ebx
f0105b93:	e8 95 fd ff ff       	call   f010592d <memcmp>
f0105b98:	83 c4 10             	add    $0x10,%esp
f0105b9b:	85 c0                	test   %eax,%eax
f0105b9d:	75 e2                	jne    f0105b81 <mpsearch1+0x36>
		    sum(mp, sizeof(*mp)) == 0)
f0105b9f:	ba 10 00 00 00       	mov    $0x10,%edx
f0105ba4:	89 d8                	mov    %ebx,%eax
f0105ba6:	e8 50 ff ff ff       	call   f0105afb <sum>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105bab:	84 c0                	test   %al,%al
f0105bad:	75 d2                	jne    f0105b81 <mpsearch1+0x36>
f0105baf:	eb 05                	jmp    f0105bb6 <mpsearch1+0x6b>
			return mp;
	return NULL;
f0105bb1:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105bb6:	89 d8                	mov    %ebx,%eax
f0105bb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105bbb:	5b                   	pop    %ebx
f0105bbc:	5e                   	pop    %esi
f0105bbd:	5f                   	pop    %edi
f0105bbe:	5d                   	pop    %ebp
f0105bbf:	c3                   	ret    

f0105bc0 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) if there is no EBDA, in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp *
mpsearch(void)
{
f0105bc0:	55                   	push   %ebp
f0105bc1:	89 e5                	mov    %esp,%ebp
f0105bc3:	83 ec 08             	sub    $0x8,%esp
	struct mp *mp;

	static_assert(sizeof(*mp) == 16);

	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);
f0105bc6:	b9 00 04 00 00       	mov    $0x400,%ecx
f0105bcb:	ba 6f 00 00 00       	mov    $0x6f,%edx
f0105bd0:	b8 9d 81 10 f0       	mov    $0xf010819d,%eax
f0105bd5:	e8 45 ff ff ff       	call   f0105b1f <_kaddr>

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105bda:	0f b7 50 0e          	movzwl 0xe(%eax),%edx
f0105bde:	85 d2                	test   %edx,%edx
f0105be0:	74 24                	je     f0105c06 <mpsearch+0x46>
		p <<= 4;	// Translate from segment to PA
f0105be2:	89 d0                	mov    %edx,%eax
f0105be4:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105be7:	ba 00 04 00 00       	mov    $0x400,%edx
f0105bec:	e8 5a ff ff ff       	call   f0105b4b <mpsearch1>
f0105bf1:	85 c0                	test   %eax,%eax
f0105bf3:	75 0f                	jne    f0105c04 <mpsearch+0x44>
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105bf5:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105bfa:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105bff:	e8 47 ff ff ff       	call   f0105b4b <mpsearch1>
}
f0105c04:	c9                   	leave  
f0105c05:	c3                   	ret    
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105c06:	0f b7 40 13          	movzwl 0x13(%eax),%eax
f0105c0a:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105c0d:	2d 00 04 00 00       	sub    $0x400,%eax
f0105c12:	ba 00 04 00 00       	mov    $0x400,%edx
f0105c17:	e8 2f ff ff ff       	call   f0105b4b <mpsearch1>
f0105c1c:	85 c0                	test   %eax,%eax
f0105c1e:	75 e4                	jne    f0105c04 <mpsearch+0x44>
f0105c20:	eb d3                	jmp    f0105bf5 <mpsearch+0x35>

f0105c22 <mpconfig>:
// Search for an MP configuration table.  For now, don't accept the
// default configurations (physaddr == 0).
// Check for the correct signature, checksum, and version.
static struct mpconf *
mpconfig(struct mp **pmp)
{
f0105c22:	55                   	push   %ebp
f0105c23:	89 e5                	mov    %esp,%ebp
f0105c25:	57                   	push   %edi
f0105c26:	56                   	push   %esi
f0105c27:	53                   	push   %ebx
f0105c28:	83 ec 1c             	sub    $0x1c,%esp
f0105c2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105c2e:	e8 8d ff ff ff       	call   f0105bc0 <mpsearch>
f0105c33:	89 c6                	mov    %eax,%esi
f0105c35:	85 c0                	test   %eax,%eax
f0105c37:	0f 84 ef 00 00 00    	je     f0105d2c <mpconfig+0x10a>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105c3d:	8b 48 04             	mov    0x4(%eax),%ecx
f0105c40:	85 c9                	test   %ecx,%ecx
f0105c42:	74 6e                	je     f0105cb2 <mpconfig+0x90>
f0105c44:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105c48:	75 68                	jne    f0105cb2 <mpconfig+0x90>
		cprintf("SMP: Default configurations not implemented\n");
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f0105c4a:	ba 90 00 00 00       	mov    $0x90,%edx
f0105c4f:	b8 9d 81 10 f0       	mov    $0xf010819d,%eax
f0105c54:	e8 c6 fe ff ff       	call   f0105b1f <_kaddr>
f0105c59:	89 c3                	mov    %eax,%ebx
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105c5b:	83 ec 04             	sub    $0x4,%esp
f0105c5e:	6a 04                	push   $0x4
f0105c60:	68 b2 81 10 f0       	push   $0xf01081b2
f0105c65:	50                   	push   %eax
f0105c66:	e8 c2 fc ff ff       	call   f010592d <memcmp>
f0105c6b:	83 c4 10             	add    $0x10,%esp
f0105c6e:	85 c0                	test   %eax,%eax
f0105c70:	75 57                	jne    f0105cc9 <mpconfig+0xa7>
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105c72:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105c76:	0f b7 d7             	movzwl %di,%edx
f0105c79:	89 d8                	mov    %ebx,%eax
f0105c7b:	e8 7b fe ff ff       	call   f0105afb <sum>
f0105c80:	84 c0                	test   %al,%al
f0105c82:	75 5c                	jne    f0105ce0 <mpconfig+0xbe>
		cprintf("SMP: Bad MP configuration checksum\n");
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105c84:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105c88:	3c 01                	cmp    $0x1,%al
f0105c8a:	74 04                	je     f0105c90 <mpconfig+0x6e>
f0105c8c:	3c 04                	cmp    $0x4,%al
f0105c8e:	75 67                	jne    f0105cf7 <mpconfig+0xd5>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105c90:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f0105c94:	0f b7 c7             	movzwl %di,%eax
f0105c97:	01 d8                	add    %ebx,%eax
f0105c99:	e8 5d fe ff ff       	call   f0105afb <sum>
f0105c9e:	02 43 2a             	add    0x2a(%ebx),%al
f0105ca1:	75 6f                	jne    f0105d12 <mpconfig+0xf0>
		cprintf("SMP: Bad MP configuration extended checksum\n");
		return NULL;
	}
	*pmp = mp;
f0105ca3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ca6:	89 30                	mov    %esi,(%eax)
	return conf;
}
f0105ca8:	89 d8                	mov    %ebx,%eax
f0105caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105cad:	5b                   	pop    %ebx
f0105cae:	5e                   	pop    %esi
f0105caf:	5f                   	pop    %edi
f0105cb0:	5d                   	pop    %ebp
f0105cb1:	c3                   	ret    
		cprintf("SMP: Default configurations not implemented\n");
f0105cb2:	83 ec 0c             	sub    $0xc,%esp
f0105cb5:	68 10 80 10 f0       	push   $0xf0108010
f0105cba:	e8 51 dc ff ff       	call   f0103910 <cprintf>
		return NULL;
f0105cbf:	83 c4 10             	add    $0x10,%esp
f0105cc2:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105cc7:	eb df                	jmp    f0105ca8 <mpconfig+0x86>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105cc9:	83 ec 0c             	sub    $0xc,%esp
f0105ccc:	68 40 80 10 f0       	push   $0xf0108040
f0105cd1:	e8 3a dc ff ff       	call   f0103910 <cprintf>
		return NULL;
f0105cd6:	83 c4 10             	add    $0x10,%esp
f0105cd9:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105cde:	eb c8                	jmp    f0105ca8 <mpconfig+0x86>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105ce0:	83 ec 0c             	sub    $0xc,%esp
f0105ce3:	68 74 80 10 f0       	push   $0xf0108074
f0105ce8:	e8 23 dc ff ff       	call   f0103910 <cprintf>
		return NULL;
f0105ced:	83 c4 10             	add    $0x10,%esp
f0105cf0:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105cf5:	eb b1                	jmp    f0105ca8 <mpconfig+0x86>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105cf7:	83 ec 08             	sub    $0x8,%esp
f0105cfa:	0f b6 c0             	movzbl %al,%eax
f0105cfd:	50                   	push   %eax
f0105cfe:	68 98 80 10 f0       	push   $0xf0108098
f0105d03:	e8 08 dc ff ff       	call   f0103910 <cprintf>
		return NULL;
f0105d08:	83 c4 10             	add    $0x10,%esp
f0105d0b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105d10:	eb 96                	jmp    f0105ca8 <mpconfig+0x86>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105d12:	83 ec 0c             	sub    $0xc,%esp
f0105d15:	68 b8 80 10 f0       	push   $0xf01080b8
f0105d1a:	e8 f1 db ff ff       	call   f0103910 <cprintf>
		return NULL;
f0105d1f:	83 c4 10             	add    $0x10,%esp
f0105d22:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105d27:	e9 7c ff ff ff       	jmp    f0105ca8 <mpconfig+0x86>
		return NULL;
f0105d2c:	89 c3                	mov    %eax,%ebx
f0105d2e:	e9 75 ff ff ff       	jmp    f0105ca8 <mpconfig+0x86>

f0105d33 <mp_init>:

void
mp_init(void)
{
f0105d33:	f3 0f 1e fb          	endbr32 
f0105d37:	55                   	push   %ebp
f0105d38:	89 e5                	mov    %esp,%ebp
f0105d3a:	57                   	push   %edi
f0105d3b:	56                   	push   %esi
f0105d3c:	53                   	push   %ebx
f0105d3d:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105d40:	c7 05 c0 33 22 f0 20 	movl   $0xf0223020,0xf02233c0
f0105d47:	30 22 f0 
	if ((conf = mpconfig(&mp)) == 0)
f0105d4a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105d4d:	e8 d0 fe ff ff       	call   f0105c22 <mpconfig>
f0105d52:	85 c0                	test   %eax,%eax
f0105d54:	0f 84 e5 00 00 00    	je     f0105e3f <mp_init+0x10c>
f0105d5a:	89 c7                	mov    %eax,%edi
		return;
	ismp = 1;
f0105d5c:	c7 05 00 30 22 f0 01 	movl   $0x1,0xf0223000
f0105d63:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105d66:	8b 40 24             	mov    0x24(%eax),%eax
f0105d69:	a3 00 40 26 f0       	mov    %eax,0xf0264000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105d6e:	8d 77 2c             	lea    0x2c(%edi),%esi
f0105d71:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105d76:	eb 38                	jmp    f0105db0 <mp_init+0x7d>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105d78:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0105d7c:	74 11                	je     f0105d8f <mp_init+0x5c>
				bootcpu = &cpus[ncpu];
f0105d7e:	6b 05 c4 33 22 f0 74 	imul   $0x74,0xf02233c4,%eax
f0105d85:	05 20 30 22 f0       	add    $0xf0223020,%eax
f0105d8a:	a3 c0 33 22 f0       	mov    %eax,0xf02233c0
			if (ncpu < NCPU) {
f0105d8f:	a1 c4 33 22 f0       	mov    0xf02233c4,%eax
f0105d94:	83 f8 07             	cmp    $0x7,%eax
f0105d97:	7f 33                	jg     f0105dcc <mp_init+0x99>
				cpus[ncpu].cpu_id = ncpu;
f0105d99:	6b d0 74             	imul   $0x74,%eax,%edx
f0105d9c:	88 82 20 30 22 f0    	mov    %al,-0xfddcfe0(%edx)
				ncpu++;
f0105da2:	83 c0 01             	add    $0x1,%eax
f0105da5:	a3 c4 33 22 f0       	mov    %eax,0xf02233c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105daa:	83 c6 14             	add    $0x14,%esi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105dad:	83 c3 01             	add    $0x1,%ebx
f0105db0:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0105db4:	39 d8                	cmp    %ebx,%eax
f0105db6:	76 4f                	jbe    f0105e07 <mp_init+0xd4>
		switch (*p) {
f0105db8:	0f b6 06             	movzbl (%esi),%eax
f0105dbb:	84 c0                	test   %al,%al
f0105dbd:	74 b9                	je     f0105d78 <mp_init+0x45>
f0105dbf:	8d 50 ff             	lea    -0x1(%eax),%edx
f0105dc2:	80 fa 03             	cmp    $0x3,%dl
f0105dc5:	77 1c                	ja     f0105de3 <mp_init+0xb0>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105dc7:	83 c6 08             	add    $0x8,%esi
			continue;
f0105dca:	eb e1                	jmp    f0105dad <mp_init+0x7a>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105dcc:	83 ec 08             	sub    $0x8,%esp
f0105dcf:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0105dd3:	50                   	push   %eax
f0105dd4:	68 e8 80 10 f0       	push   $0xf01080e8
f0105dd9:	e8 32 db ff ff       	call   f0103910 <cprintf>
f0105dde:	83 c4 10             	add    $0x10,%esp
f0105de1:	eb c7                	jmp    f0105daa <mp_init+0x77>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105de3:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0105de6:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0105de9:	50                   	push   %eax
f0105dea:	68 10 81 10 f0       	push   $0xf0108110
f0105def:	e8 1c db ff ff       	call   f0103910 <cprintf>
			ismp = 0;
f0105df4:	c7 05 00 30 22 f0 00 	movl   $0x0,0xf0223000
f0105dfb:	00 00 00 
			i = conf->entry;
f0105dfe:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
f0105e02:	83 c4 10             	add    $0x10,%esp
f0105e05:	eb a6                	jmp    f0105dad <mp_init+0x7a>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105e07:	a1 c0 33 22 f0       	mov    0xf02233c0,%eax
f0105e0c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105e13:	83 3d 00 30 22 f0 00 	cmpl   $0x0,0xf0223000
f0105e1a:	74 2b                	je     f0105e47 <mp_init+0x114>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105e1c:	83 ec 04             	sub    $0x4,%esp
f0105e1f:	ff 35 c4 33 22 f0    	pushl  0xf02233c4
f0105e25:	0f b6 00             	movzbl (%eax),%eax
f0105e28:	50                   	push   %eax
f0105e29:	68 b7 81 10 f0       	push   $0xf01081b7
f0105e2e:	e8 dd da ff ff       	call   f0103910 <cprintf>

	if (mp->imcrp) {
f0105e33:	83 c4 10             	add    $0x10,%esp
f0105e36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e39:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105e3d:	75 2e                	jne    f0105e6d <mp_init+0x13a>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105e3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105e42:	5b                   	pop    %ebx
f0105e43:	5e                   	pop    %esi
f0105e44:	5f                   	pop    %edi
f0105e45:	5d                   	pop    %ebp
f0105e46:	c3                   	ret    
		ncpu = 1;
f0105e47:	c7 05 c4 33 22 f0 01 	movl   $0x1,0xf02233c4
f0105e4e:	00 00 00 
		lapicaddr = 0;
f0105e51:	c7 05 00 40 26 f0 00 	movl   $0x0,0xf0264000
f0105e58:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105e5b:	83 ec 0c             	sub    $0xc,%esp
f0105e5e:	68 30 81 10 f0       	push   $0xf0108130
f0105e63:	e8 a8 da ff ff       	call   f0103910 <cprintf>
		return;
f0105e68:	83 c4 10             	add    $0x10,%esp
f0105e6b:	eb d2                	jmp    f0105e3f <mp_init+0x10c>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105e6d:	83 ec 0c             	sub    $0xc,%esp
f0105e70:	68 5c 81 10 f0       	push   $0xf010815c
f0105e75:	e8 96 da ff ff       	call   f0103910 <cprintf>
		outb(0x22, 0x70);   // Select IMCR
f0105e7a:	ba 70 00 00 00       	mov    $0x70,%edx
f0105e7f:	b8 22 00 00 00       	mov    $0x22,%eax
f0105e84:	e8 6a fc ff ff       	call   f0105af3 <outb>
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105e89:	b8 23 00 00 00       	mov    $0x23,%eax
f0105e8e:	e8 5c fc ff ff       	call   f0105aef <inb>
f0105e93:	83 c8 01             	or     $0x1,%eax
f0105e96:	0f b6 d0             	movzbl %al,%edx
f0105e99:	b8 23 00 00 00       	mov    $0x23,%eax
f0105e9e:	e8 50 fc ff ff       	call   f0105af3 <outb>
f0105ea3:	83 c4 10             	add    $0x10,%esp
f0105ea6:	eb 97                	jmp    f0105e3f <mp_init+0x10c>

f0105ea8 <outb>:
{
f0105ea8:	89 c1                	mov    %eax,%ecx
f0105eaa:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105eac:	89 ca                	mov    %ecx,%edx
f0105eae:	ee                   	out    %al,(%dx)
}
f0105eaf:	c3                   	ret    

f0105eb0 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0105eb0:	8b 0d 04 40 26 f0    	mov    0xf0264004,%ecx
f0105eb6:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105eb9:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105ebb:	a1 04 40 26 f0       	mov    0xf0264004,%eax
f0105ec0:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105ec3:	c3                   	ret    

f0105ec4 <_kaddr>:
{
f0105ec4:	55                   	push   %ebp
f0105ec5:	89 e5                	mov    %esp,%ebp
f0105ec7:	53                   	push   %ebx
f0105ec8:	83 ec 04             	sub    $0x4,%esp
	if (PGNUM(pa) >= npages)
f0105ecb:	89 cb                	mov    %ecx,%ebx
f0105ecd:	c1 eb 0c             	shr    $0xc,%ebx
f0105ed0:	3b 1d 88 2e 22 f0    	cmp    0xf0222e88,%ebx
f0105ed6:	73 0b                	jae    f0105ee3 <_kaddr+0x1f>
	return (void *)(pa + KERNBASE);
f0105ed8:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f0105ede:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105ee1:	c9                   	leave  
f0105ee2:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105ee3:	51                   	push   %ecx
f0105ee4:	68 cc 65 10 f0       	push   $0xf01065cc
f0105ee9:	52                   	push   %edx
f0105eea:	50                   	push   %eax
f0105eeb:	e8 7a a1 ff ff       	call   f010006a <_panic>

f0105ef0 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105ef0:	f3 0f 1e fb          	endbr32 
	if (lapic)
f0105ef4:	8b 15 04 40 26 f0    	mov    0xf0264004,%edx
		return lapic[ID] >> 24;
	return 0;
f0105efa:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0105eff:	85 d2                	test   %edx,%edx
f0105f01:	74 06                	je     f0105f09 <cpunum+0x19>
		return lapic[ID] >> 24;
f0105f03:	8b 42 20             	mov    0x20(%edx),%eax
f0105f06:	c1 e8 18             	shr    $0x18,%eax
}
f0105f09:	c3                   	ret    

f0105f0a <lapic_init>:
{
f0105f0a:	f3 0f 1e fb          	endbr32 
	if (!lapicaddr)
f0105f0e:	a1 00 40 26 f0       	mov    0xf0264000,%eax
f0105f13:	85 c0                	test   %eax,%eax
f0105f15:	75 01                	jne    f0105f18 <lapic_init+0xe>
f0105f17:	c3                   	ret    
{
f0105f18:	55                   	push   %ebp
f0105f19:	89 e5                	mov    %esp,%ebp
f0105f1b:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0105f1e:	68 00 10 00 00       	push   $0x1000
f0105f23:	50                   	push   %eax
f0105f24:	e8 05 bf ff ff       	call   f0101e2e <mmio_map_region>
f0105f29:	a3 04 40 26 f0       	mov    %eax,0xf0264004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105f2e:	ba 27 01 00 00       	mov    $0x127,%edx
f0105f33:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105f38:	e8 73 ff ff ff       	call   f0105eb0 <lapicw>
	lapicw(TDCR, X1);
f0105f3d:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105f42:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105f47:	e8 64 ff ff ff       	call   f0105eb0 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105f4c:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105f51:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105f56:	e8 55 ff ff ff       	call   f0105eb0 <lapicw>
	lapicw(TICR, 10000000); 
f0105f5b:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105f60:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105f65:	e8 46 ff ff ff       	call   f0105eb0 <lapicw>
	if (thiscpu != bootcpu)
f0105f6a:	e8 81 ff ff ff       	call   f0105ef0 <cpunum>
f0105f6f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f72:	05 20 30 22 f0       	add    $0xf0223020,%eax
f0105f77:	83 c4 10             	add    $0x10,%esp
f0105f7a:	39 05 c0 33 22 f0    	cmp    %eax,0xf02233c0
f0105f80:	74 0f                	je     f0105f91 <lapic_init+0x87>
		lapicw(LINT0, MASKED);
f0105f82:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105f87:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105f8c:	e8 1f ff ff ff       	call   f0105eb0 <lapicw>
	lapicw(LINT1, MASKED);
f0105f91:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105f96:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105f9b:	e8 10 ff ff ff       	call   f0105eb0 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105fa0:	a1 04 40 26 f0       	mov    0xf0264004,%eax
f0105fa5:	8b 40 30             	mov    0x30(%eax),%eax
f0105fa8:	c1 e8 10             	shr    $0x10,%eax
f0105fab:	a8 fc                	test   $0xfc,%al
f0105fad:	75 7c                	jne    f010602b <lapic_init+0x121>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105faf:	ba 33 00 00 00       	mov    $0x33,%edx
f0105fb4:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105fb9:	e8 f2 fe ff ff       	call   f0105eb0 <lapicw>
	lapicw(ESR, 0);
f0105fbe:	ba 00 00 00 00       	mov    $0x0,%edx
f0105fc3:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105fc8:	e8 e3 fe ff ff       	call   f0105eb0 <lapicw>
	lapicw(ESR, 0);
f0105fcd:	ba 00 00 00 00       	mov    $0x0,%edx
f0105fd2:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105fd7:	e8 d4 fe ff ff       	call   f0105eb0 <lapicw>
	lapicw(EOI, 0);
f0105fdc:	ba 00 00 00 00       	mov    $0x0,%edx
f0105fe1:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105fe6:	e8 c5 fe ff ff       	call   f0105eb0 <lapicw>
	lapicw(ICRHI, 0);
f0105feb:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ff0:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ff5:	e8 b6 fe ff ff       	call   f0105eb0 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105ffa:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105fff:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106004:	e8 a7 fe ff ff       	call   f0105eb0 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106009:	8b 15 04 40 26 f0    	mov    0xf0264004,%edx
f010600f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106015:	f6 c4 10             	test   $0x10,%ah
f0106018:	75 f5                	jne    f010600f <lapic_init+0x105>
	lapicw(TPR, 0);
f010601a:	ba 00 00 00 00       	mov    $0x0,%edx
f010601f:	b8 20 00 00 00       	mov    $0x20,%eax
f0106024:	e8 87 fe ff ff       	call   f0105eb0 <lapicw>
}
f0106029:	c9                   	leave  
f010602a:	c3                   	ret    
		lapicw(PCINT, MASKED);
f010602b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106030:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106035:	e8 76 fe ff ff       	call   f0105eb0 <lapicw>
f010603a:	e9 70 ff ff ff       	jmp    f0105faf <lapic_init+0xa5>

f010603f <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010603f:	f3 0f 1e fb          	endbr32 
	if (lapic)
f0106043:	83 3d 04 40 26 f0 00 	cmpl   $0x0,0xf0264004
f010604a:	74 17                	je     f0106063 <lapic_eoi+0x24>
{
f010604c:	55                   	push   %ebp
f010604d:	89 e5                	mov    %esp,%ebp
f010604f:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f0106052:	ba 00 00 00 00       	mov    $0x0,%edx
f0106057:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010605c:	e8 4f fe ff ff       	call   f0105eb0 <lapicw>
}
f0106061:	c9                   	leave  
f0106062:	c3                   	ret    
f0106063:	c3                   	ret    

f0106064 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106064:	f3 0f 1e fb          	endbr32 
f0106068:	55                   	push   %ebp
f0106069:	89 e5                	mov    %esp,%ebp
f010606b:	56                   	push   %esi
f010606c:	53                   	push   %ebx
f010606d:	8b 75 08             	mov    0x8(%ebp),%esi
f0106070:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uint16_t *wrv;

	// "The BSP must initialize CMOS shutdown code to 0AH
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
f0106073:	ba 0f 00 00 00       	mov    $0xf,%edx
f0106078:	b8 70 00 00 00       	mov    $0x70,%eax
f010607d:	e8 26 fe ff ff       	call   f0105ea8 <outb>
	outb(IO_RTC+1, 0x0A);
f0106082:	ba 0a 00 00 00       	mov    $0xa,%edx
f0106087:	b8 71 00 00 00       	mov    $0x71,%eax
f010608c:	e8 17 fe ff ff       	call   f0105ea8 <outb>
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
f0106091:	b9 67 04 00 00       	mov    $0x467,%ecx
f0106096:	ba 98 00 00 00       	mov    $0x98,%edx
f010609b:	b8 d4 81 10 f0       	mov    $0xf01081d4,%eax
f01060a0:	e8 1f fe ff ff       	call   f0105ec4 <_kaddr>
	wrv[0] = 0;
f01060a5:	66 c7 00 00 00       	movw   $0x0,(%eax)
	wrv[1] = addr >> 4;
f01060aa:	89 da                	mov    %ebx,%edx
f01060ac:	c1 ea 04             	shr    $0x4,%edx
f01060af:	66 89 50 02          	mov    %dx,0x2(%eax)

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01060b3:	c1 e6 18             	shl    $0x18,%esi
f01060b6:	89 f2                	mov    %esi,%edx
f01060b8:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01060bd:	e8 ee fd ff ff       	call   f0105eb0 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01060c2:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01060c7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060cc:	e8 df fd ff ff       	call   f0105eb0 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01060d1:	ba 00 85 00 00       	mov    $0x8500,%edx
f01060d6:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060db:	e8 d0 fd ff ff       	call   f0105eb0 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01060e0:	c1 eb 0c             	shr    $0xc,%ebx
f01060e3:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f01060e6:	89 f2                	mov    %esi,%edx
f01060e8:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01060ed:	e8 be fd ff ff       	call   f0105eb0 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01060f2:	89 da                	mov    %ebx,%edx
f01060f4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01060f9:	e8 b2 fd ff ff       	call   f0105eb0 <lapicw>
		lapicw(ICRHI, apicid << 24);
f01060fe:	89 f2                	mov    %esi,%edx
f0106100:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106105:	e8 a6 fd ff ff       	call   f0105eb0 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010610a:	89 da                	mov    %ebx,%edx
f010610c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106111:	e8 9a fd ff ff       	call   f0105eb0 <lapicw>
		microdelay(200);
	}
}
f0106116:	5b                   	pop    %ebx
f0106117:	5e                   	pop    %esi
f0106118:	5d                   	pop    %ebp
f0106119:	c3                   	ret    

f010611a <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010611a:	f3 0f 1e fb          	endbr32 
f010611e:	55                   	push   %ebp
f010611f:	89 e5                	mov    %esp,%ebp
f0106121:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106124:	8b 55 08             	mov    0x8(%ebp),%edx
f0106127:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010612d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106132:	e8 79 fd ff ff       	call   f0105eb0 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106137:	8b 15 04 40 26 f0    	mov    0xf0264004,%edx
f010613d:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106143:	f6 c4 10             	test   $0x10,%ah
f0106146:	75 f5                	jne    f010613d <lapic_ipi+0x23>
		;
}
f0106148:	c9                   	leave  
f0106149:	c3                   	ret    

f010614a <xchg>:
{
f010614a:	89 c1                	mov    %eax,%ecx
f010614c:	89 d0                	mov    %edx,%eax
	asm volatile("lock; xchgl %0, %1"
f010614e:	f0 87 01             	lock xchg %eax,(%ecx)
}
f0106151:	c3                   	ret    

f0106152 <get_caller_pcs>:
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0106152:	89 e9                	mov    %ebp,%ecx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106154:	ba 00 00 00 00       	mov    $0x0,%edx
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106159:	81 f9 ff ff 7f ef    	cmp    $0xef7fffff,%ecx
f010615f:	76 3f                	jbe    f01061a0 <get_caller_pcs+0x4e>
f0106161:	83 fa 09             	cmp    $0x9,%edx
f0106164:	7f 3a                	jg     f01061a0 <get_caller_pcs+0x4e>
{
f0106166:	55                   	push   %ebp
f0106167:	89 e5                	mov    %esp,%ebp
f0106169:	53                   	push   %ebx
			break;
		pcs[i] = ebp[1];          // saved %eip
f010616a:	8b 59 04             	mov    0x4(%ecx),%ebx
f010616d:	89 1c 90             	mov    %ebx,(%eax,%edx,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106170:	8b 09                	mov    (%ecx),%ecx
	for (i = 0; i < 10; i++){
f0106172:	83 c2 01             	add    $0x1,%edx
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106175:	81 f9 ff ff 7f ef    	cmp    $0xef7fffff,%ecx
f010617b:	76 11                	jbe    f010618e <get_caller_pcs+0x3c>
f010617d:	83 fa 09             	cmp    $0x9,%edx
f0106180:	7e e8                	jle    f010616a <get_caller_pcs+0x18>
f0106182:	eb 0a                	jmp    f010618e <get_caller_pcs+0x3c>
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106184:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
	for (; i < 10; i++)
f010618b:	83 c2 01             	add    $0x1,%edx
f010618e:	83 fa 09             	cmp    $0x9,%edx
f0106191:	7e f1                	jle    f0106184 <get_caller_pcs+0x32>
}
f0106193:	5b                   	pop    %ebx
f0106194:	5d                   	pop    %ebp
f0106195:	c3                   	ret    
		pcs[i] = 0;
f0106196:	c7 04 90 00 00 00 00 	movl   $0x0,(%eax,%edx,4)
	for (; i < 10; i++)
f010619d:	83 c2 01             	add    $0x1,%edx
f01061a0:	83 fa 09             	cmp    $0x9,%edx
f01061a3:	7e f1                	jle    f0106196 <get_caller_pcs+0x44>
f01061a5:	c3                   	ret    

f01061a6 <holding>:

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01061a6:	83 38 00             	cmpl   $0x0,(%eax)
f01061a9:	75 06                	jne    f01061b1 <holding+0xb>
f01061ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01061b0:	c3                   	ret    
{
f01061b1:	55                   	push   %ebp
f01061b2:	89 e5                	mov    %esp,%ebp
f01061b4:	53                   	push   %ebx
f01061b5:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f01061b8:	8b 58 08             	mov    0x8(%eax),%ebx
f01061bb:	e8 30 fd ff ff       	call   f0105ef0 <cpunum>
f01061c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01061c3:	05 20 30 22 f0       	add    $0xf0223020,%eax
f01061c8:	39 c3                	cmp    %eax,%ebx
f01061ca:	0f 94 c0             	sete   %al
f01061cd:	0f b6 c0             	movzbl %al,%eax
}
f01061d0:	83 c4 04             	add    $0x4,%esp
f01061d3:	5b                   	pop    %ebx
f01061d4:	5d                   	pop    %ebp
f01061d5:	c3                   	ret    

f01061d6 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01061d6:	f3 0f 1e fb          	endbr32 
f01061da:	55                   	push   %ebp
f01061db:	89 e5                	mov    %esp,%ebp
f01061dd:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01061e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01061e6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01061e9:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01061ec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01061f3:	5d                   	pop    %ebp
f01061f4:	c3                   	ret    

f01061f5 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01061f5:	f3 0f 1e fb          	endbr32 
f01061f9:	55                   	push   %ebp
f01061fa:	89 e5                	mov    %esp,%ebp
f01061fc:	53                   	push   %ebx
f01061fd:	83 ec 04             	sub    $0x4,%esp
f0106200:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106203:	89 d8                	mov    %ebx,%eax
f0106205:	e8 9c ff ff ff       	call   f01061a6 <holding>
f010620a:	85 c0                	test   %eax,%eax
f010620c:	74 20                	je     f010622e <spin_lock+0x39>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010620e:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106211:	e8 da fc ff ff       	call   f0105ef0 <cpunum>
f0106216:	83 ec 0c             	sub    $0xc,%esp
f0106219:	53                   	push   %ebx
f010621a:	50                   	push   %eax
f010621b:	68 e4 81 10 f0       	push   $0xf01081e4
f0106220:	6a 41                	push   $0x41
f0106222:	68 46 82 10 f0       	push   $0xf0108246
f0106227:	e8 3e 9e ff ff       	call   f010006a <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010622c:	f3 90                	pause  
	while (xchg(&lk->locked, 1) != 0)
f010622e:	ba 01 00 00 00       	mov    $0x1,%edx
f0106233:	89 d8                	mov    %ebx,%eax
f0106235:	e8 10 ff ff ff       	call   f010614a <xchg>
f010623a:	85 c0                	test   %eax,%eax
f010623c:	75 ee                	jne    f010622c <spin_lock+0x37>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010623e:	e8 ad fc ff ff       	call   f0105ef0 <cpunum>
f0106243:	6b c0 74             	imul   $0x74,%eax,%eax
f0106246:	05 20 30 22 f0       	add    $0xf0223020,%eax
f010624b:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f010624e:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106251:	e8 fc fe ff ff       	call   f0106152 <get_caller_pcs>
#endif
}
f0106256:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0106259:	c9                   	leave  
f010625a:	c3                   	ret    

f010625b <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010625b:	f3 0f 1e fb          	endbr32 
f010625f:	55                   	push   %ebp
f0106260:	89 e5                	mov    %esp,%ebp
f0106262:	57                   	push   %edi
f0106263:	56                   	push   %esi
f0106264:	53                   	push   %ebx
f0106265:	83 ec 4c             	sub    $0x4c,%esp
f0106268:	8b 75 08             	mov    0x8(%ebp),%esi
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010626b:	89 f0                	mov    %esi,%eax
f010626d:	e8 34 ff ff ff       	call   f01061a6 <holding>
f0106272:	85 c0                	test   %eax,%eax
f0106274:	74 22                	je     f0106298 <spin_unlock+0x3d>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0106276:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f010627d:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	// The xchg instruction is atomic (i.e. uses the "lock" prefix) with
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
f0106284:	ba 00 00 00 00       	mov    $0x0,%edx
f0106289:	89 f0                	mov    %esi,%eax
f010628b:	e8 ba fe ff ff       	call   f010614a <xchg>
}
f0106290:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106293:	5b                   	pop    %ebx
f0106294:	5e                   	pop    %esi
f0106295:	5f                   	pop    %edi
f0106296:	5d                   	pop    %ebp
f0106297:	c3                   	ret    
		memmove(pcs, lk->pcs, sizeof pcs);
f0106298:	83 ec 04             	sub    $0x4,%esp
f010629b:	6a 28                	push   $0x28
f010629d:	8d 46 0c             	lea    0xc(%esi),%eax
f01062a0:	50                   	push   %eax
f01062a1:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01062a4:	53                   	push   %ebx
f01062a5:	e8 03 f6 ff ff       	call   f01058ad <memmove>
			cpunum(), lk->name, lk->cpu->cpu_id);
f01062aa:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01062ad:	0f b6 38             	movzbl (%eax),%edi
f01062b0:	8b 76 04             	mov    0x4(%esi),%esi
f01062b3:	e8 38 fc ff ff       	call   f0105ef0 <cpunum>
f01062b8:	57                   	push   %edi
f01062b9:	56                   	push   %esi
f01062ba:	50                   	push   %eax
f01062bb:	68 10 82 10 f0       	push   $0xf0108210
f01062c0:	e8 4b d6 ff ff       	call   f0103910 <cprintf>
f01062c5:	83 c4 20             	add    $0x20,%esp
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01062c8:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01062cb:	eb 1c                	jmp    f01062e9 <spin_unlock+0x8e>
				cprintf("  %08x\n", pcs[i]);
f01062cd:	83 ec 08             	sub    $0x8,%esp
f01062d0:	ff 36                	pushl  (%esi)
f01062d2:	68 6d 82 10 f0       	push   $0xf010826d
f01062d7:	e8 34 d6 ff ff       	call   f0103910 <cprintf>
f01062dc:	83 c4 10             	add    $0x10,%esp
f01062df:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f01062e2:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01062e5:	39 c3                	cmp    %eax,%ebx
f01062e7:	74 40                	je     f0106329 <spin_unlock+0xce>
f01062e9:	89 de                	mov    %ebx,%esi
f01062eb:	8b 03                	mov    (%ebx),%eax
f01062ed:	85 c0                	test   %eax,%eax
f01062ef:	74 38                	je     f0106329 <spin_unlock+0xce>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01062f1:	83 ec 08             	sub    $0x8,%esp
f01062f4:	57                   	push   %edi
f01062f5:	50                   	push   %eax
f01062f6:	e8 c6 ea ff ff       	call   f0104dc1 <debuginfo_eip>
f01062fb:	83 c4 10             	add    $0x10,%esp
f01062fe:	85 c0                	test   %eax,%eax
f0106300:	78 cb                	js     f01062cd <spin_unlock+0x72>
					pcs[i] - info.eip_fn_addr);
f0106302:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106304:	83 ec 04             	sub    $0x4,%esp
f0106307:	89 c2                	mov    %eax,%edx
f0106309:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010630c:	52                   	push   %edx
f010630d:	ff 75 b0             	pushl  -0x50(%ebp)
f0106310:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106313:	ff 75 ac             	pushl  -0x54(%ebp)
f0106316:	ff 75 a8             	pushl  -0x58(%ebp)
f0106319:	50                   	push   %eax
f010631a:	68 56 82 10 f0       	push   $0xf0108256
f010631f:	e8 ec d5 ff ff       	call   f0103910 <cprintf>
f0106324:	83 c4 20             	add    $0x20,%esp
f0106327:	eb b6                	jmp    f01062df <spin_unlock+0x84>
		panic("spin_unlock");
f0106329:	83 ec 04             	sub    $0x4,%esp
f010632c:	68 75 82 10 f0       	push   $0xf0108275
f0106331:	6a 67                	push   $0x67
f0106333:	68 46 82 10 f0       	push   $0xf0108246
f0106338:	e8 2d 9d ff ff       	call   f010006a <_panic>
f010633d:	66 90                	xchg   %ax,%ax
f010633f:	90                   	nop

f0106340 <__udivdi3>:
f0106340:	f3 0f 1e fb          	endbr32 
f0106344:	55                   	push   %ebp
f0106345:	57                   	push   %edi
f0106346:	56                   	push   %esi
f0106347:	53                   	push   %ebx
f0106348:	83 ec 1c             	sub    $0x1c,%esp
f010634b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010634f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0106353:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106357:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010635b:	85 d2                	test   %edx,%edx
f010635d:	75 19                	jne    f0106378 <__udivdi3+0x38>
f010635f:	39 f3                	cmp    %esi,%ebx
f0106361:	76 4d                	jbe    f01063b0 <__udivdi3+0x70>
f0106363:	31 ff                	xor    %edi,%edi
f0106365:	89 e8                	mov    %ebp,%eax
f0106367:	89 f2                	mov    %esi,%edx
f0106369:	f7 f3                	div    %ebx
f010636b:	89 fa                	mov    %edi,%edx
f010636d:	83 c4 1c             	add    $0x1c,%esp
f0106370:	5b                   	pop    %ebx
f0106371:	5e                   	pop    %esi
f0106372:	5f                   	pop    %edi
f0106373:	5d                   	pop    %ebp
f0106374:	c3                   	ret    
f0106375:	8d 76 00             	lea    0x0(%esi),%esi
f0106378:	39 f2                	cmp    %esi,%edx
f010637a:	76 14                	jbe    f0106390 <__udivdi3+0x50>
f010637c:	31 ff                	xor    %edi,%edi
f010637e:	31 c0                	xor    %eax,%eax
f0106380:	89 fa                	mov    %edi,%edx
f0106382:	83 c4 1c             	add    $0x1c,%esp
f0106385:	5b                   	pop    %ebx
f0106386:	5e                   	pop    %esi
f0106387:	5f                   	pop    %edi
f0106388:	5d                   	pop    %ebp
f0106389:	c3                   	ret    
f010638a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106390:	0f bd fa             	bsr    %edx,%edi
f0106393:	83 f7 1f             	xor    $0x1f,%edi
f0106396:	75 48                	jne    f01063e0 <__udivdi3+0xa0>
f0106398:	39 f2                	cmp    %esi,%edx
f010639a:	72 06                	jb     f01063a2 <__udivdi3+0x62>
f010639c:	31 c0                	xor    %eax,%eax
f010639e:	39 eb                	cmp    %ebp,%ebx
f01063a0:	77 de                	ja     f0106380 <__udivdi3+0x40>
f01063a2:	b8 01 00 00 00       	mov    $0x1,%eax
f01063a7:	eb d7                	jmp    f0106380 <__udivdi3+0x40>
f01063a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01063b0:	89 d9                	mov    %ebx,%ecx
f01063b2:	85 db                	test   %ebx,%ebx
f01063b4:	75 0b                	jne    f01063c1 <__udivdi3+0x81>
f01063b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01063bb:	31 d2                	xor    %edx,%edx
f01063bd:	f7 f3                	div    %ebx
f01063bf:	89 c1                	mov    %eax,%ecx
f01063c1:	31 d2                	xor    %edx,%edx
f01063c3:	89 f0                	mov    %esi,%eax
f01063c5:	f7 f1                	div    %ecx
f01063c7:	89 c6                	mov    %eax,%esi
f01063c9:	89 e8                	mov    %ebp,%eax
f01063cb:	89 f7                	mov    %esi,%edi
f01063cd:	f7 f1                	div    %ecx
f01063cf:	89 fa                	mov    %edi,%edx
f01063d1:	83 c4 1c             	add    $0x1c,%esp
f01063d4:	5b                   	pop    %ebx
f01063d5:	5e                   	pop    %esi
f01063d6:	5f                   	pop    %edi
f01063d7:	5d                   	pop    %ebp
f01063d8:	c3                   	ret    
f01063d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01063e0:	89 f9                	mov    %edi,%ecx
f01063e2:	b8 20 00 00 00       	mov    $0x20,%eax
f01063e7:	29 f8                	sub    %edi,%eax
f01063e9:	d3 e2                	shl    %cl,%edx
f01063eb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01063ef:	89 c1                	mov    %eax,%ecx
f01063f1:	89 da                	mov    %ebx,%edx
f01063f3:	d3 ea                	shr    %cl,%edx
f01063f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01063f9:	09 d1                	or     %edx,%ecx
f01063fb:	89 f2                	mov    %esi,%edx
f01063fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106401:	89 f9                	mov    %edi,%ecx
f0106403:	d3 e3                	shl    %cl,%ebx
f0106405:	89 c1                	mov    %eax,%ecx
f0106407:	d3 ea                	shr    %cl,%edx
f0106409:	89 f9                	mov    %edi,%ecx
f010640b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010640f:	89 eb                	mov    %ebp,%ebx
f0106411:	d3 e6                	shl    %cl,%esi
f0106413:	89 c1                	mov    %eax,%ecx
f0106415:	d3 eb                	shr    %cl,%ebx
f0106417:	09 de                	or     %ebx,%esi
f0106419:	89 f0                	mov    %esi,%eax
f010641b:	f7 74 24 08          	divl   0x8(%esp)
f010641f:	89 d6                	mov    %edx,%esi
f0106421:	89 c3                	mov    %eax,%ebx
f0106423:	f7 64 24 0c          	mull   0xc(%esp)
f0106427:	39 d6                	cmp    %edx,%esi
f0106429:	72 15                	jb     f0106440 <__udivdi3+0x100>
f010642b:	89 f9                	mov    %edi,%ecx
f010642d:	d3 e5                	shl    %cl,%ebp
f010642f:	39 c5                	cmp    %eax,%ebp
f0106431:	73 04                	jae    f0106437 <__udivdi3+0xf7>
f0106433:	39 d6                	cmp    %edx,%esi
f0106435:	74 09                	je     f0106440 <__udivdi3+0x100>
f0106437:	89 d8                	mov    %ebx,%eax
f0106439:	31 ff                	xor    %edi,%edi
f010643b:	e9 40 ff ff ff       	jmp    f0106380 <__udivdi3+0x40>
f0106440:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0106443:	31 ff                	xor    %edi,%edi
f0106445:	e9 36 ff ff ff       	jmp    f0106380 <__udivdi3+0x40>
f010644a:	66 90                	xchg   %ax,%ax
f010644c:	66 90                	xchg   %ax,%ax
f010644e:	66 90                	xchg   %ax,%ax

f0106450 <__umoddi3>:
f0106450:	f3 0f 1e fb          	endbr32 
f0106454:	55                   	push   %ebp
f0106455:	57                   	push   %edi
f0106456:	56                   	push   %esi
f0106457:	53                   	push   %ebx
f0106458:	83 ec 1c             	sub    $0x1c,%esp
f010645b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010645f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0106463:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106467:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010646b:	85 c0                	test   %eax,%eax
f010646d:	75 19                	jne    f0106488 <__umoddi3+0x38>
f010646f:	39 df                	cmp    %ebx,%edi
f0106471:	76 5d                	jbe    f01064d0 <__umoddi3+0x80>
f0106473:	89 f0                	mov    %esi,%eax
f0106475:	89 da                	mov    %ebx,%edx
f0106477:	f7 f7                	div    %edi
f0106479:	89 d0                	mov    %edx,%eax
f010647b:	31 d2                	xor    %edx,%edx
f010647d:	83 c4 1c             	add    $0x1c,%esp
f0106480:	5b                   	pop    %ebx
f0106481:	5e                   	pop    %esi
f0106482:	5f                   	pop    %edi
f0106483:	5d                   	pop    %ebp
f0106484:	c3                   	ret    
f0106485:	8d 76 00             	lea    0x0(%esi),%esi
f0106488:	89 f2                	mov    %esi,%edx
f010648a:	39 d8                	cmp    %ebx,%eax
f010648c:	76 12                	jbe    f01064a0 <__umoddi3+0x50>
f010648e:	89 f0                	mov    %esi,%eax
f0106490:	89 da                	mov    %ebx,%edx
f0106492:	83 c4 1c             	add    $0x1c,%esp
f0106495:	5b                   	pop    %ebx
f0106496:	5e                   	pop    %esi
f0106497:	5f                   	pop    %edi
f0106498:	5d                   	pop    %ebp
f0106499:	c3                   	ret    
f010649a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01064a0:	0f bd e8             	bsr    %eax,%ebp
f01064a3:	83 f5 1f             	xor    $0x1f,%ebp
f01064a6:	75 50                	jne    f01064f8 <__umoddi3+0xa8>
f01064a8:	39 d8                	cmp    %ebx,%eax
f01064aa:	0f 82 e0 00 00 00    	jb     f0106590 <__umoddi3+0x140>
f01064b0:	89 d9                	mov    %ebx,%ecx
f01064b2:	39 f7                	cmp    %esi,%edi
f01064b4:	0f 86 d6 00 00 00    	jbe    f0106590 <__umoddi3+0x140>
f01064ba:	89 d0                	mov    %edx,%eax
f01064bc:	89 ca                	mov    %ecx,%edx
f01064be:	83 c4 1c             	add    $0x1c,%esp
f01064c1:	5b                   	pop    %ebx
f01064c2:	5e                   	pop    %esi
f01064c3:	5f                   	pop    %edi
f01064c4:	5d                   	pop    %ebp
f01064c5:	c3                   	ret    
f01064c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01064cd:	8d 76 00             	lea    0x0(%esi),%esi
f01064d0:	89 fd                	mov    %edi,%ebp
f01064d2:	85 ff                	test   %edi,%edi
f01064d4:	75 0b                	jne    f01064e1 <__umoddi3+0x91>
f01064d6:	b8 01 00 00 00       	mov    $0x1,%eax
f01064db:	31 d2                	xor    %edx,%edx
f01064dd:	f7 f7                	div    %edi
f01064df:	89 c5                	mov    %eax,%ebp
f01064e1:	89 d8                	mov    %ebx,%eax
f01064e3:	31 d2                	xor    %edx,%edx
f01064e5:	f7 f5                	div    %ebp
f01064e7:	89 f0                	mov    %esi,%eax
f01064e9:	f7 f5                	div    %ebp
f01064eb:	89 d0                	mov    %edx,%eax
f01064ed:	31 d2                	xor    %edx,%edx
f01064ef:	eb 8c                	jmp    f010647d <__umoddi3+0x2d>
f01064f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01064f8:	89 e9                	mov    %ebp,%ecx
f01064fa:	ba 20 00 00 00       	mov    $0x20,%edx
f01064ff:	29 ea                	sub    %ebp,%edx
f0106501:	d3 e0                	shl    %cl,%eax
f0106503:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106507:	89 d1                	mov    %edx,%ecx
f0106509:	89 f8                	mov    %edi,%eax
f010650b:	d3 e8                	shr    %cl,%eax
f010650d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106511:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106515:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106519:	09 c1                	or     %eax,%ecx
f010651b:	89 d8                	mov    %ebx,%eax
f010651d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106521:	89 e9                	mov    %ebp,%ecx
f0106523:	d3 e7                	shl    %cl,%edi
f0106525:	89 d1                	mov    %edx,%ecx
f0106527:	d3 e8                	shr    %cl,%eax
f0106529:	89 e9                	mov    %ebp,%ecx
f010652b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010652f:	d3 e3                	shl    %cl,%ebx
f0106531:	89 c7                	mov    %eax,%edi
f0106533:	89 d1                	mov    %edx,%ecx
f0106535:	89 f0                	mov    %esi,%eax
f0106537:	d3 e8                	shr    %cl,%eax
f0106539:	89 e9                	mov    %ebp,%ecx
f010653b:	89 fa                	mov    %edi,%edx
f010653d:	d3 e6                	shl    %cl,%esi
f010653f:	09 d8                	or     %ebx,%eax
f0106541:	f7 74 24 08          	divl   0x8(%esp)
f0106545:	89 d1                	mov    %edx,%ecx
f0106547:	89 f3                	mov    %esi,%ebx
f0106549:	f7 64 24 0c          	mull   0xc(%esp)
f010654d:	89 c6                	mov    %eax,%esi
f010654f:	89 d7                	mov    %edx,%edi
f0106551:	39 d1                	cmp    %edx,%ecx
f0106553:	72 06                	jb     f010655b <__umoddi3+0x10b>
f0106555:	75 10                	jne    f0106567 <__umoddi3+0x117>
f0106557:	39 c3                	cmp    %eax,%ebx
f0106559:	73 0c                	jae    f0106567 <__umoddi3+0x117>
f010655b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f010655f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0106563:	89 d7                	mov    %edx,%edi
f0106565:	89 c6                	mov    %eax,%esi
f0106567:	89 ca                	mov    %ecx,%edx
f0106569:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010656e:	29 f3                	sub    %esi,%ebx
f0106570:	19 fa                	sbb    %edi,%edx
f0106572:	89 d0                	mov    %edx,%eax
f0106574:	d3 e0                	shl    %cl,%eax
f0106576:	89 e9                	mov    %ebp,%ecx
f0106578:	d3 eb                	shr    %cl,%ebx
f010657a:	d3 ea                	shr    %cl,%edx
f010657c:	09 d8                	or     %ebx,%eax
f010657e:	83 c4 1c             	add    $0x1c,%esp
f0106581:	5b                   	pop    %ebx
f0106582:	5e                   	pop    %esi
f0106583:	5f                   	pop    %edi
f0106584:	5d                   	pop    %ebp
f0106585:	c3                   	ret    
f0106586:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010658d:	8d 76 00             	lea    0x0(%esi),%esi
f0106590:	29 fe                	sub    %edi,%esi
f0106592:	19 c3                	sbb    %eax,%ebx
f0106594:	89 f2                	mov    %esi,%edx
f0106596:	89 d9                	mov    %ebx,%ecx
f0106598:	e9 1d ff ff ff       	jmp    f01064ba <__umoddi3+0x6a>
