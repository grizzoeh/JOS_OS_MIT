
obj/user/stresssched.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 b6 00 00 00       	call   8000e7 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  80003c:	e8 98 0b 00 00       	call   800bd9 <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800043:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800048:	e8 90 10 00 00       	call   8010dd <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 0f                	je     800060 <umain+0x2d>
	for (i = 0; i < 20; i++)
  800051:	83 c3 01             	add    $0x1,%ebx
  800054:	83 fb 14             	cmp    $0x14,%ebx
  800057:	75 ef                	jne    800048 <umain+0x15>
			break;
	if (i == 20) {
		sys_yield();
  800059:	e8 a3 0b 00 00       	call   800c01 <sys_yield>
		return;
  80005e:	eb 69                	jmp    8000c9 <umain+0x96>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800060:	89 f0                	mov    %esi,%eax
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006f:	eb 02                	jmp    800073 <umain+0x40>
		asm volatile("pause");
  800071:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800073:	8b 50 54             	mov    0x54(%eax),%edx
  800076:	85 d2                	test   %edx,%edx
  800078:	75 f7                	jne    800071 <umain+0x3e>
  80007a:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  80007f:	e8 7d 0b 00 00       	call   800c01 <sys_yield>
  800084:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  800089:	a1 04 40 80 00       	mov    0x804004,%eax
  80008e:	83 c0 01             	add    $0x1,%eax
  800091:	a3 04 40 80 00       	mov    %eax,0x804004
		for (j = 0; j < 10000; j++)
  800096:	83 ea 01             	sub    $0x1,%edx
  800099:	75 ee                	jne    800089 <umain+0x56>
	for (i = 0; i < 10; i++) {
  80009b:	83 eb 01             	sub    $0x1,%ebx
  80009e:	75 df                	jne    80007f <umain+0x4c>
	}

	if (counter != 10*10000)
  8000a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8000a5:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000aa:	75 24                	jne    8000d0 <umain+0x9d>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000ac:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b1:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000b4:	8b 40 48             	mov    0x48(%eax),%eax
  8000b7:	83 ec 04             	sub    $0x4,%esp
  8000ba:	52                   	push   %edx
  8000bb:	50                   	push   %eax
  8000bc:	68 1b 24 80 00       	push   $0x80241b
  8000c1:	e8 74 01 00 00       	call   80023a <cprintf>
  8000c6:	83 c4 10             	add    $0x10,%esp

}
  8000c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5d                   	pop    %ebp
  8000cf:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8000d5:	50                   	push   %eax
  8000d6:	68 e0 23 80 00       	push   $0x8023e0
  8000db:	6a 21                	push   $0x21
  8000dd:	68 08 24 80 00       	push   $0x802408
  8000e2:	e8 6c 00 00 00       	call   800153 <_panic>

008000e7 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e7:	f3 0f 1e fb          	endbr32 
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000f6:	e8 de 0a 00 00       	call   800bd9 <sys_getenvid>
	if (id >= 0)
  8000fb:	85 c0                	test   %eax,%eax
  8000fd:	78 12                	js     800111 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8000ff:	25 ff 03 00 00       	and    $0x3ff,%eax
  800104:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800107:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010c:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800111:	85 db                	test   %ebx,%ebx
  800113:	7e 07                	jle    80011c <libmain+0x35>
		binaryname = argv[0];
  800115:	8b 06                	mov    (%esi),%eax
  800117:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011c:	83 ec 08             	sub    $0x8,%esp
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
  800121:	e8 0d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800126:	e8 0a 00 00 00       	call   800135 <exit>
}
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5d                   	pop    %ebp
  800134:	c3                   	ret    

00800135 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800135:	f3 0f 1e fb          	endbr32 
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80013f:	e8 e0 12 00 00       	call   801424 <close_all>
	sys_env_destroy(0);
  800144:	83 ec 0c             	sub    $0xc,%esp
  800147:	6a 00                	push   $0x0
  800149:	e8 65 0a 00 00       	call   800bb3 <sys_env_destroy>
}
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800153:	f3 0f 1e fb          	endbr32 
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800165:	e8 6f 0a 00 00       	call   800bd9 <sys_getenvid>
  80016a:	83 ec 0c             	sub    $0xc,%esp
  80016d:	ff 75 0c             	pushl  0xc(%ebp)
  800170:	ff 75 08             	pushl  0x8(%ebp)
  800173:	56                   	push   %esi
  800174:	50                   	push   %eax
  800175:	68 44 24 80 00       	push   $0x802444
  80017a:	e8 bb 00 00 00       	call   80023a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017f:	83 c4 18             	add    $0x18,%esp
  800182:	53                   	push   %ebx
  800183:	ff 75 10             	pushl  0x10(%ebp)
  800186:	e8 5a 00 00 00       	call   8001e5 <vcprintf>
	cprintf("\n");
  80018b:	c7 04 24 37 24 80 00 	movl   $0x802437,(%esp)
  800192:	e8 a3 00 00 00       	call   80023a <cprintf>
  800197:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019a:	cc                   	int3   
  80019b:	eb fd                	jmp    80019a <_panic+0x47>

0080019d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019d:	f3 0f 1e fb          	endbr32 
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	53                   	push   %ebx
  8001a5:	83 ec 04             	sub    $0x4,%esp
  8001a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ab:	8b 13                	mov    (%ebx),%edx
  8001ad:	8d 42 01             	lea    0x1(%edx),%eax
  8001b0:	89 03                	mov    %eax,(%ebx)
  8001b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001be:	74 09                	je     8001c9 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001c0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	68 ff 00 00 00       	push   $0xff
  8001d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d4:	50                   	push   %eax
  8001d5:	e8 87 09 00 00       	call   800b61 <sys_cputs>
		b->idx = 0;
  8001da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001e0:	83 c4 10             	add    $0x10,%esp
  8001e3:	eb db                	jmp    8001c0 <putch+0x23>

008001e5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e5:	f3 0f 1e fb          	endbr32 
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f9:	00 00 00 
	b.cnt = 0;
  8001fc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800203:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800206:	ff 75 0c             	pushl  0xc(%ebp)
  800209:	ff 75 08             	pushl  0x8(%ebp)
  80020c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800212:	50                   	push   %eax
  800213:	68 9d 01 80 00       	push   $0x80019d
  800218:	e8 80 01 00 00       	call   80039d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021d:	83 c4 08             	add    $0x8,%esp
  800220:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800226:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022c:	50                   	push   %eax
  80022d:	e8 2f 09 00 00       	call   800b61 <sys_cputs>

	return b.cnt;
}
  800232:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023a:	f3 0f 1e fb          	endbr32 
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800244:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800247:	50                   	push   %eax
  800248:	ff 75 08             	pushl  0x8(%ebp)
  80024b:	e8 95 ff ff ff       	call   8001e5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800250:	c9                   	leave  
  800251:	c3                   	ret    

00800252 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	57                   	push   %edi
  800256:	56                   	push   %esi
  800257:	53                   	push   %ebx
  800258:	83 ec 1c             	sub    $0x1c,%esp
  80025b:	89 c7                	mov    %eax,%edi
  80025d:	89 d6                	mov    %edx,%esi
  80025f:	8b 45 08             	mov    0x8(%ebp),%eax
  800262:	8b 55 0c             	mov    0xc(%ebp),%edx
  800265:	89 d1                	mov    %edx,%ecx
  800267:	89 c2                	mov    %eax,%edx
  800269:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80026c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80026f:	8b 45 10             	mov    0x10(%ebp),%eax
  800272:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800275:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800278:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80027f:	39 c2                	cmp    %eax,%edx
  800281:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800284:	72 3e                	jb     8002c4 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	ff 75 18             	pushl  0x18(%ebp)
  80028c:	83 eb 01             	sub    $0x1,%ebx
  80028f:	53                   	push   %ebx
  800290:	50                   	push   %eax
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	ff 75 e4             	pushl  -0x1c(%ebp)
  800297:	ff 75 e0             	pushl  -0x20(%ebp)
  80029a:	ff 75 dc             	pushl  -0x24(%ebp)
  80029d:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a0:	e8 db 1e 00 00       	call   802180 <__udivdi3>
  8002a5:	83 c4 18             	add    $0x18,%esp
  8002a8:	52                   	push   %edx
  8002a9:	50                   	push   %eax
  8002aa:	89 f2                	mov    %esi,%edx
  8002ac:	89 f8                	mov    %edi,%eax
  8002ae:	e8 9f ff ff ff       	call   800252 <printnum>
  8002b3:	83 c4 20             	add    $0x20,%esp
  8002b6:	eb 13                	jmp    8002cb <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b8:	83 ec 08             	sub    $0x8,%esp
  8002bb:	56                   	push   %esi
  8002bc:	ff 75 18             	pushl  0x18(%ebp)
  8002bf:	ff d7                	call   *%edi
  8002c1:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002c4:	83 eb 01             	sub    $0x1,%ebx
  8002c7:	85 db                	test   %ebx,%ebx
  8002c9:	7f ed                	jg     8002b8 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cb:	83 ec 08             	sub    $0x8,%esp
  8002ce:	56                   	push   %esi
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002db:	ff 75 d8             	pushl  -0x28(%ebp)
  8002de:	e8 ad 1f 00 00       	call   802290 <__umoddi3>
  8002e3:	83 c4 14             	add    $0x14,%esp
  8002e6:	0f be 80 67 24 80 00 	movsbl 0x802467(%eax),%eax
  8002ed:	50                   	push   %eax
  8002ee:	ff d7                	call   *%edi
}
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f6:	5b                   	pop    %ebx
  8002f7:	5e                   	pop    %esi
  8002f8:	5f                   	pop    %edi
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002fb:	83 fa 01             	cmp    $0x1,%edx
  8002fe:	7f 13                	jg     800313 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800300:	85 d2                	test   %edx,%edx
  800302:	74 1c                	je     800320 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800304:	8b 10                	mov    (%eax),%edx
  800306:	8d 4a 04             	lea    0x4(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 02                	mov    (%edx),%eax
  80030d:	ba 00 00 00 00       	mov    $0x0,%edx
  800312:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800313:	8b 10                	mov    (%eax),%edx
  800315:	8d 4a 08             	lea    0x8(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 02                	mov    (%edx),%eax
  80031c:	8b 52 04             	mov    0x4(%edx),%edx
  80031f:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800320:	8b 10                	mov    (%eax),%edx
  800322:	8d 4a 04             	lea    0x4(%edx),%ecx
  800325:	89 08                	mov    %ecx,(%eax)
  800327:	8b 02                	mov    (%edx),%eax
  800329:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032e:	c3                   	ret    

0080032f <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80032f:	83 fa 01             	cmp    $0x1,%edx
  800332:	7f 0f                	jg     800343 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800334:	85 d2                	test   %edx,%edx
  800336:	74 18                	je     800350 <getint+0x21>
		return va_arg(*ap, long);
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033d:	89 08                	mov    %ecx,(%eax)
  80033f:	8b 02                	mov    (%edx),%eax
  800341:	99                   	cltd   
  800342:	c3                   	ret    
		return va_arg(*ap, long long);
  800343:	8b 10                	mov    (%eax),%edx
  800345:	8d 4a 08             	lea    0x8(%edx),%ecx
  800348:	89 08                	mov    %ecx,(%eax)
  80034a:	8b 02                	mov    (%edx),%eax
  80034c:	8b 52 04             	mov    0x4(%edx),%edx
  80034f:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800350:	8b 10                	mov    (%eax),%edx
  800352:	8d 4a 04             	lea    0x4(%edx),%ecx
  800355:	89 08                	mov    %ecx,(%eax)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	99                   	cltd   
}
  80035a:	c3                   	ret    

0080035b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035b:	f3 0f 1e fb          	endbr32 
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800365:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	3b 50 04             	cmp    0x4(%eax),%edx
  80036e:	73 0a                	jae    80037a <sprintputch+0x1f>
		*b->buf++ = ch;
  800370:	8d 4a 01             	lea    0x1(%edx),%ecx
  800373:	89 08                	mov    %ecx,(%eax)
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	88 02                	mov    %al,(%edx)
}
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <printfmt>:
{
  80037c:	f3 0f 1e fb          	endbr32 
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800386:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800389:	50                   	push   %eax
  80038a:	ff 75 10             	pushl  0x10(%ebp)
  80038d:	ff 75 0c             	pushl  0xc(%ebp)
  800390:	ff 75 08             	pushl  0x8(%ebp)
  800393:	e8 05 00 00 00       	call   80039d <vprintfmt>
}
  800398:	83 c4 10             	add    $0x10,%esp
  80039b:	c9                   	leave  
  80039c:	c3                   	ret    

0080039d <vprintfmt>:
{
  80039d:	f3 0f 1e fb          	endbr32 
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	57                   	push   %edi
  8003a5:	56                   	push   %esi
  8003a6:	53                   	push   %ebx
  8003a7:	83 ec 2c             	sub    $0x2c,%esp
  8003aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003b0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b3:	e9 86 02 00 00       	jmp    80063e <vprintfmt+0x2a1>
		padc = ' ';
  8003b8:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003bc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003c3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003ca:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003d1:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8d 47 01             	lea    0x1(%edi),%eax
  8003d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003dc:	0f b6 17             	movzbl (%edi),%edx
  8003df:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003e2:	3c 55                	cmp    $0x55,%al
  8003e4:	0f 87 df 02 00 00    	ja     8006c9 <vprintfmt+0x32c>
  8003ea:	0f b6 c0             	movzbl %al,%eax
  8003ed:	3e ff 24 85 a0 25 80 	notrack jmp *0x8025a0(,%eax,4)
  8003f4:	00 
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003f8:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003fc:	eb d8                	jmp    8003d6 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800401:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800405:	eb cf                	jmp    8003d6 <vprintfmt+0x39>
  800407:	0f b6 d2             	movzbl %dl,%edx
  80040a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80040d:	b8 00 00 00 00       	mov    $0x0,%eax
  800412:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800415:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800418:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80041c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80041f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800422:	83 f9 09             	cmp    $0x9,%ecx
  800425:	77 52                	ja     800479 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800427:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80042a:	eb e9                	jmp    800415 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80042c:	8b 45 14             	mov    0x14(%ebp),%eax
  80042f:	8d 50 04             	lea    0x4(%eax),%edx
  800432:	89 55 14             	mov    %edx,0x14(%ebp)
  800435:	8b 00                	mov    (%eax),%eax
  800437:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80043d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800441:	79 93                	jns    8003d6 <vprintfmt+0x39>
				width = precision, precision = -1;
  800443:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800446:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800449:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800450:	eb 84                	jmp    8003d6 <vprintfmt+0x39>
  800452:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800455:	85 c0                	test   %eax,%eax
  800457:	ba 00 00 00 00       	mov    $0x0,%edx
  80045c:	0f 49 d0             	cmovns %eax,%edx
  80045f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800462:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800465:	e9 6c ff ff ff       	jmp    8003d6 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80046d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800474:	e9 5d ff ff ff       	jmp    8003d6 <vprintfmt+0x39>
  800479:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80047c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80047f:	eb bc                	jmp    80043d <vprintfmt+0xa0>
			lflag++;
  800481:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800487:	e9 4a ff ff ff       	jmp    8003d6 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8d 50 04             	lea    0x4(%eax),%edx
  800492:	89 55 14             	mov    %edx,0x14(%ebp)
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	56                   	push   %esi
  800499:	ff 30                	pushl  (%eax)
  80049b:	ff d3                	call   *%ebx
			break;
  80049d:	83 c4 10             	add    $0x10,%esp
  8004a0:	e9 96 01 00 00       	jmp    80063b <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8d 50 04             	lea    0x4(%eax),%edx
  8004ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ae:	8b 00                	mov    (%eax),%eax
  8004b0:	99                   	cltd   
  8004b1:	31 d0                	xor    %edx,%eax
  8004b3:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b5:	83 f8 0f             	cmp    $0xf,%eax
  8004b8:	7f 20                	jg     8004da <vprintfmt+0x13d>
  8004ba:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  8004c1:	85 d2                	test   %edx,%edx
  8004c3:	74 15                	je     8004da <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8004c5:	52                   	push   %edx
  8004c6:	68 05 2a 80 00       	push   $0x802a05
  8004cb:	56                   	push   %esi
  8004cc:	53                   	push   %ebx
  8004cd:	e8 aa fe ff ff       	call   80037c <printfmt>
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	e9 61 01 00 00       	jmp    80063b <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8004da:	50                   	push   %eax
  8004db:	68 7f 24 80 00       	push   $0x80247f
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
  8004e2:	e8 95 fe ff ff       	call   80037c <printfmt>
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	e9 4c 01 00 00       	jmp    80063b <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f2:	8d 50 04             	lea    0x4(%eax),%edx
  8004f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f8:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8004fa:	85 c9                	test   %ecx,%ecx
  8004fc:	b8 78 24 80 00       	mov    $0x802478,%eax
  800501:	0f 45 c1             	cmovne %ecx,%eax
  800504:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800507:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050b:	7e 06                	jle    800513 <vprintfmt+0x176>
  80050d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800511:	75 0d                	jne    800520 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800513:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800516:	89 c7                	mov    %eax,%edi
  800518:	03 45 e0             	add    -0x20(%ebp),%eax
  80051b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80051e:	eb 57                	jmp    800577 <vprintfmt+0x1da>
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	ff 75 d8             	pushl  -0x28(%ebp)
  800526:	ff 75 cc             	pushl  -0x34(%ebp)
  800529:	e8 4f 02 00 00       	call   80077d <strnlen>
  80052e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800531:	29 c2                	sub    %eax,%edx
  800533:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800536:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800539:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80053d:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800540:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800542:	85 db                	test   %ebx,%ebx
  800544:	7e 10                	jle    800556 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800546:	83 ec 08             	sub    $0x8,%esp
  800549:	56                   	push   %esi
  80054a:	57                   	push   %edi
  80054b:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80054e:	83 eb 01             	sub    $0x1,%ebx
  800551:	83 c4 10             	add    $0x10,%esp
  800554:	eb ec                	jmp    800542 <vprintfmt+0x1a5>
  800556:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800559:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80055c:	85 d2                	test   %edx,%edx
  80055e:	b8 00 00 00 00       	mov    $0x0,%eax
  800563:	0f 49 c2             	cmovns %edx,%eax
  800566:	29 c2                	sub    %eax,%edx
  800568:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80056b:	eb a6                	jmp    800513 <vprintfmt+0x176>
					putch(ch, putdat);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	56                   	push   %esi
  800571:	52                   	push   %edx
  800572:	ff d3                	call   *%ebx
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80057a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057c:	83 c7 01             	add    $0x1,%edi
  80057f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800583:	0f be d0             	movsbl %al,%edx
  800586:	85 d2                	test   %edx,%edx
  800588:	74 42                	je     8005cc <vprintfmt+0x22f>
  80058a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058e:	78 06                	js     800596 <vprintfmt+0x1f9>
  800590:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800594:	78 1e                	js     8005b4 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800596:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80059a:	74 d1                	je     80056d <vprintfmt+0x1d0>
  80059c:	0f be c0             	movsbl %al,%eax
  80059f:	83 e8 20             	sub    $0x20,%eax
  8005a2:	83 f8 5e             	cmp    $0x5e,%eax
  8005a5:	76 c6                	jbe    80056d <vprintfmt+0x1d0>
					putch('?', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	56                   	push   %esi
  8005ab:	6a 3f                	push   $0x3f
  8005ad:	ff d3                	call   *%ebx
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	eb c3                	jmp    800577 <vprintfmt+0x1da>
  8005b4:	89 cf                	mov    %ecx,%edi
  8005b6:	eb 0e                	jmp    8005c6 <vprintfmt+0x229>
				putch(' ', putdat);
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	56                   	push   %esi
  8005bc:	6a 20                	push   $0x20
  8005be:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8005c0:	83 ef 01             	sub    $0x1,%edi
  8005c3:	83 c4 10             	add    $0x10,%esp
  8005c6:	85 ff                	test   %edi,%edi
  8005c8:	7f ee                	jg     8005b8 <vprintfmt+0x21b>
  8005ca:	eb 6f                	jmp    80063b <vprintfmt+0x29e>
  8005cc:	89 cf                	mov    %ecx,%edi
  8005ce:	eb f6                	jmp    8005c6 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8005d0:	89 ca                	mov    %ecx,%edx
  8005d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d5:	e8 55 fd ff ff       	call   80032f <getint>
  8005da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8005e0:	85 d2                	test   %edx,%edx
  8005e2:	78 0b                	js     8005ef <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8005e4:	89 d1                	mov    %edx,%ecx
  8005e6:	89 c2                	mov    %eax,%edx
			base = 10;
  8005e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ed:	eb 32                	jmp    800621 <vprintfmt+0x284>
				putch('-', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	56                   	push   %esi
  8005f3:	6a 2d                	push   $0x2d
  8005f5:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005fd:	f7 da                	neg    %edx
  8005ff:	83 d1 00             	adc    $0x0,%ecx
  800602:	f7 d9                	neg    %ecx
  800604:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060c:	eb 13                	jmp    800621 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80060e:	89 ca                	mov    %ecx,%edx
  800610:	8d 45 14             	lea    0x14(%ebp),%eax
  800613:	e8 e3 fc ff ff       	call   8002fb <getuint>
  800618:	89 d1                	mov    %edx,%ecx
  80061a:	89 c2                	mov    %eax,%edx
			base = 10;
  80061c:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800621:	83 ec 0c             	sub    $0xc,%esp
  800624:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800628:	57                   	push   %edi
  800629:	ff 75 e0             	pushl  -0x20(%ebp)
  80062c:	50                   	push   %eax
  80062d:	51                   	push   %ecx
  80062e:	52                   	push   %edx
  80062f:	89 f2                	mov    %esi,%edx
  800631:	89 d8                	mov    %ebx,%eax
  800633:	e8 1a fc ff ff       	call   800252 <printnum>
			break;
  800638:	83 c4 20             	add    $0x20,%esp
{
  80063b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80063e:	83 c7 01             	add    $0x1,%edi
  800641:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800645:	83 f8 25             	cmp    $0x25,%eax
  800648:	0f 84 6a fd ff ff    	je     8003b8 <vprintfmt+0x1b>
			if (ch == '\0')
  80064e:	85 c0                	test   %eax,%eax
  800650:	0f 84 93 00 00 00    	je     8006e9 <vprintfmt+0x34c>
			putch(ch, putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	56                   	push   %esi
  80065a:	50                   	push   %eax
  80065b:	ff d3                	call   *%ebx
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	eb dc                	jmp    80063e <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800662:	89 ca                	mov    %ecx,%edx
  800664:	8d 45 14             	lea    0x14(%ebp),%eax
  800667:	e8 8f fc ff ff       	call   8002fb <getuint>
  80066c:	89 d1                	mov    %edx,%ecx
  80066e:	89 c2                	mov    %eax,%edx
			base = 8;
  800670:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800675:	eb aa                	jmp    800621 <vprintfmt+0x284>
			putch('0', putdat);
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	56                   	push   %esi
  80067b:	6a 30                	push   $0x30
  80067d:	ff d3                	call   *%ebx
			putch('x', putdat);
  80067f:	83 c4 08             	add    $0x8,%esp
  800682:	56                   	push   %esi
  800683:	6a 78                	push   $0x78
  800685:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8d 50 04             	lea    0x4(%eax),%edx
  80068d:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800690:	8b 10                	mov    (%eax),%edx
  800692:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800697:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80069a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80069f:	eb 80                	jmp    800621 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8006a1:	89 ca                	mov    %ecx,%edx
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	e8 50 fc ff ff       	call   8002fb <getuint>
  8006ab:	89 d1                	mov    %edx,%ecx
  8006ad:	89 c2                	mov    %eax,%edx
			base = 16;
  8006af:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b4:	e9 68 ff ff ff       	jmp    800621 <vprintfmt+0x284>
			putch(ch, putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	56                   	push   %esi
  8006bd:	6a 25                	push   $0x25
  8006bf:	ff d3                	call   *%ebx
			break;
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	e9 72 ff ff ff       	jmp    80063b <vprintfmt+0x29e>
			putch('%', putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	56                   	push   %esi
  8006cd:	6a 25                	push   $0x25
  8006cf:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d1:	83 c4 10             	add    $0x10,%esp
  8006d4:	89 f8                	mov    %edi,%eax
  8006d6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006da:	74 05                	je     8006e1 <vprintfmt+0x344>
  8006dc:	83 e8 01             	sub    $0x1,%eax
  8006df:	eb f5                	jmp    8006d6 <vprintfmt+0x339>
  8006e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006e4:	e9 52 ff ff ff       	jmp    80063b <vprintfmt+0x29e>
}
  8006e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ec:	5b                   	pop    %ebx
  8006ed:	5e                   	pop    %esi
  8006ee:	5f                   	pop    %edi
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    

008006f1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f1:	f3 0f 1e fb          	endbr32 
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	83 ec 18             	sub    $0x18,%esp
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800701:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800704:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800708:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800712:	85 c0                	test   %eax,%eax
  800714:	74 26                	je     80073c <vsnprintf+0x4b>
  800716:	85 d2                	test   %edx,%edx
  800718:	7e 22                	jle    80073c <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071a:	ff 75 14             	pushl  0x14(%ebp)
  80071d:	ff 75 10             	pushl  0x10(%ebp)
  800720:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800723:	50                   	push   %eax
  800724:	68 5b 03 80 00       	push   $0x80035b
  800729:	e8 6f fc ff ff       	call   80039d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800731:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800737:	83 c4 10             	add    $0x10,%esp
}
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    
		return -E_INVAL;
  80073c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800741:	eb f7                	jmp    80073a <vsnprintf+0x49>

00800743 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800743:	f3 0f 1e fb          	endbr32 
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800750:	50                   	push   %eax
  800751:	ff 75 10             	pushl  0x10(%ebp)
  800754:	ff 75 0c             	pushl  0xc(%ebp)
  800757:	ff 75 08             	pushl  0x8(%ebp)
  80075a:	e8 92 ff ff ff       	call   8006f1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800761:	f3 0f 1e fb          	endbr32 
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80076b:	b8 00 00 00 00       	mov    $0x0,%eax
  800770:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800774:	74 05                	je     80077b <strlen+0x1a>
		n++;
  800776:	83 c0 01             	add    $0x1,%eax
  800779:	eb f5                	jmp    800770 <strlen+0xf>
	return n;
}
  80077b:	5d                   	pop    %ebp
  80077c:	c3                   	ret    

0080077d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077d:	f3 0f 1e fb          	endbr32 
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800787:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078a:	b8 00 00 00 00       	mov    $0x0,%eax
  80078f:	39 d0                	cmp    %edx,%eax
  800791:	74 0d                	je     8007a0 <strnlen+0x23>
  800793:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800797:	74 05                	je     80079e <strnlen+0x21>
		n++;
  800799:	83 c0 01             	add    $0x1,%eax
  80079c:	eb f1                	jmp    80078f <strnlen+0x12>
  80079e:	89 c2                	mov    %eax,%edx
	return n;
}
  8007a0:	89 d0                	mov    %edx,%eax
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a4:	f3 0f 1e fb          	endbr32 
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b7:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007bb:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007be:	83 c0 01             	add    $0x1,%eax
  8007c1:	84 d2                	test   %dl,%dl
  8007c3:	75 f2                	jne    8007b7 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007c5:	89 c8                	mov    %ecx,%eax
  8007c7:	5b                   	pop    %ebx
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ca:	f3 0f 1e fb          	endbr32 
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	53                   	push   %ebx
  8007d2:	83 ec 10             	sub    $0x10,%esp
  8007d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d8:	53                   	push   %ebx
  8007d9:	e8 83 ff ff ff       	call   800761 <strlen>
  8007de:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007e1:	ff 75 0c             	pushl  0xc(%ebp)
  8007e4:	01 d8                	add    %ebx,%eax
  8007e6:	50                   	push   %eax
  8007e7:	e8 b8 ff ff ff       	call   8007a4 <strcpy>
	return dst;
}
  8007ec:	89 d8                	mov    %ebx,%eax
  8007ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f1:	c9                   	leave  
  8007f2:	c3                   	ret    

008007f3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f3:	f3 0f 1e fb          	endbr32 
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800802:	89 f3                	mov    %esi,%ebx
  800804:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800807:	89 f0                	mov    %esi,%eax
  800809:	39 d8                	cmp    %ebx,%eax
  80080b:	74 11                	je     80081e <strncpy+0x2b>
		*dst++ = *src;
  80080d:	83 c0 01             	add    $0x1,%eax
  800810:	0f b6 0a             	movzbl (%edx),%ecx
  800813:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800816:	80 f9 01             	cmp    $0x1,%cl
  800819:	83 da ff             	sbb    $0xffffffff,%edx
  80081c:	eb eb                	jmp    800809 <strncpy+0x16>
	}
	return ret;
}
  80081e:	89 f0                	mov    %esi,%eax
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800824:	f3 0f 1e fb          	endbr32 
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	56                   	push   %esi
  80082c:	53                   	push   %ebx
  80082d:	8b 75 08             	mov    0x8(%ebp),%esi
  800830:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800833:	8b 55 10             	mov    0x10(%ebp),%edx
  800836:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800838:	85 d2                	test   %edx,%edx
  80083a:	74 21                	je     80085d <strlcpy+0x39>
  80083c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800840:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800842:	39 c2                	cmp    %eax,%edx
  800844:	74 14                	je     80085a <strlcpy+0x36>
  800846:	0f b6 19             	movzbl (%ecx),%ebx
  800849:	84 db                	test   %bl,%bl
  80084b:	74 0b                	je     800858 <strlcpy+0x34>
			*dst++ = *src++;
  80084d:	83 c1 01             	add    $0x1,%ecx
  800850:	83 c2 01             	add    $0x1,%edx
  800853:	88 5a ff             	mov    %bl,-0x1(%edx)
  800856:	eb ea                	jmp    800842 <strlcpy+0x1e>
  800858:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80085a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085d:	29 f0                	sub    %esi,%eax
}
  80085f:	5b                   	pop    %ebx
  800860:	5e                   	pop    %esi
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800863:	f3 0f 1e fb          	endbr32 
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800870:	0f b6 01             	movzbl (%ecx),%eax
  800873:	84 c0                	test   %al,%al
  800875:	74 0c                	je     800883 <strcmp+0x20>
  800877:	3a 02                	cmp    (%edx),%al
  800879:	75 08                	jne    800883 <strcmp+0x20>
		p++, q++;
  80087b:	83 c1 01             	add    $0x1,%ecx
  80087e:	83 c2 01             	add    $0x1,%edx
  800881:	eb ed                	jmp    800870 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800883:	0f b6 c0             	movzbl %al,%eax
  800886:	0f b6 12             	movzbl (%edx),%edx
  800889:	29 d0                	sub    %edx,%eax
}
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088d:	f3 0f 1e fb          	endbr32 
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	53                   	push   %ebx
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089b:	89 c3                	mov    %eax,%ebx
  80089d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a0:	eb 06                	jmp    8008a8 <strncmp+0x1b>
		n--, p++, q++;
  8008a2:	83 c0 01             	add    $0x1,%eax
  8008a5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008a8:	39 d8                	cmp    %ebx,%eax
  8008aa:	74 16                	je     8008c2 <strncmp+0x35>
  8008ac:	0f b6 08             	movzbl (%eax),%ecx
  8008af:	84 c9                	test   %cl,%cl
  8008b1:	74 04                	je     8008b7 <strncmp+0x2a>
  8008b3:	3a 0a                	cmp    (%edx),%cl
  8008b5:	74 eb                	je     8008a2 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b7:	0f b6 00             	movzbl (%eax),%eax
  8008ba:	0f b6 12             	movzbl (%edx),%edx
  8008bd:	29 d0                	sub    %edx,%eax
}
  8008bf:	5b                   	pop    %ebx
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    
		return 0;
  8008c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c7:	eb f6                	jmp    8008bf <strncmp+0x32>

008008c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c9:	f3 0f 1e fb          	endbr32 
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d7:	0f b6 10             	movzbl (%eax),%edx
  8008da:	84 d2                	test   %dl,%dl
  8008dc:	74 09                	je     8008e7 <strchr+0x1e>
		if (*s == c)
  8008de:	38 ca                	cmp    %cl,%dl
  8008e0:	74 0a                	je     8008ec <strchr+0x23>
	for (; *s; s++)
  8008e2:	83 c0 01             	add    $0x1,%eax
  8008e5:	eb f0                	jmp    8008d7 <strchr+0xe>
			return (char *) s;
	return 0;
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ee:	f3 0f 1e fb          	endbr32 
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ff:	38 ca                	cmp    %cl,%dl
  800901:	74 09                	je     80090c <strfind+0x1e>
  800903:	84 d2                	test   %dl,%dl
  800905:	74 05                	je     80090c <strfind+0x1e>
	for (; *s; s++)
  800907:	83 c0 01             	add    $0x1,%eax
  80090a:	eb f0                	jmp    8008fc <strfind+0xe>
			break;
	return (char *) s;
}
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090e:	f3 0f 1e fb          	endbr32 
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	57                   	push   %edi
  800916:	56                   	push   %esi
  800917:	53                   	push   %ebx
  800918:	8b 55 08             	mov    0x8(%ebp),%edx
  80091b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80091e:	85 c9                	test   %ecx,%ecx
  800920:	74 33                	je     800955 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800922:	89 d0                	mov    %edx,%eax
  800924:	09 c8                	or     %ecx,%eax
  800926:	a8 03                	test   $0x3,%al
  800928:	75 23                	jne    80094d <memset+0x3f>
		c &= 0xFF;
  80092a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092e:	89 d8                	mov    %ebx,%eax
  800930:	c1 e0 08             	shl    $0x8,%eax
  800933:	89 df                	mov    %ebx,%edi
  800935:	c1 e7 18             	shl    $0x18,%edi
  800938:	89 de                	mov    %ebx,%esi
  80093a:	c1 e6 10             	shl    $0x10,%esi
  80093d:	09 f7                	or     %esi,%edi
  80093f:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800941:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800944:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800946:	89 d7                	mov    %edx,%edi
  800948:	fc                   	cld    
  800949:	f3 ab                	rep stos %eax,%es:(%edi)
  80094b:	eb 08                	jmp    800955 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094d:	89 d7                	mov    %edx,%edi
  80094f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800952:	fc                   	cld    
  800953:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800955:	89 d0                	mov    %edx,%eax
  800957:	5b                   	pop    %ebx
  800958:	5e                   	pop    %esi
  800959:	5f                   	pop    %edi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095c:	f3 0f 1e fb          	endbr32 
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	57                   	push   %edi
  800964:	56                   	push   %esi
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096e:	39 c6                	cmp    %eax,%esi
  800970:	73 32                	jae    8009a4 <memmove+0x48>
  800972:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800975:	39 c2                	cmp    %eax,%edx
  800977:	76 2b                	jbe    8009a4 <memmove+0x48>
		s += n;
		d += n;
  800979:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097c:	89 fe                	mov    %edi,%esi
  80097e:	09 ce                	or     %ecx,%esi
  800980:	09 d6                	or     %edx,%esi
  800982:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800988:	75 0e                	jne    800998 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80098a:	83 ef 04             	sub    $0x4,%edi
  80098d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800990:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800993:	fd                   	std    
  800994:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800996:	eb 09                	jmp    8009a1 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800998:	83 ef 01             	sub    $0x1,%edi
  80099b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80099e:	fd                   	std    
  80099f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a1:	fc                   	cld    
  8009a2:	eb 1a                	jmp    8009be <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	89 c2                	mov    %eax,%edx
  8009a6:	09 ca                	or     %ecx,%edx
  8009a8:	09 f2                	or     %esi,%edx
  8009aa:	f6 c2 03             	test   $0x3,%dl
  8009ad:	75 0a                	jne    8009b9 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009af:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009b2:	89 c7                	mov    %eax,%edi
  8009b4:	fc                   	cld    
  8009b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b7:	eb 05                	jmp    8009be <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009b9:	89 c7                	mov    %eax,%edi
  8009bb:	fc                   	cld    
  8009bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009be:	5e                   	pop    %esi
  8009bf:	5f                   	pop    %edi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c2:	f3 0f 1e fb          	endbr32 
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009cc:	ff 75 10             	pushl  0x10(%ebp)
  8009cf:	ff 75 0c             	pushl  0xc(%ebp)
  8009d2:	ff 75 08             	pushl  0x8(%ebp)
  8009d5:	e8 82 ff ff ff       	call   80095c <memmove>
}
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009dc:	f3 0f 1e fb          	endbr32 
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009eb:	89 c6                	mov    %eax,%esi
  8009ed:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f0:	39 f0                	cmp    %esi,%eax
  8009f2:	74 1c                	je     800a10 <memcmp+0x34>
		if (*s1 != *s2)
  8009f4:	0f b6 08             	movzbl (%eax),%ecx
  8009f7:	0f b6 1a             	movzbl (%edx),%ebx
  8009fa:	38 d9                	cmp    %bl,%cl
  8009fc:	75 08                	jne    800a06 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009fe:	83 c0 01             	add    $0x1,%eax
  800a01:	83 c2 01             	add    $0x1,%edx
  800a04:	eb ea                	jmp    8009f0 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a06:	0f b6 c1             	movzbl %cl,%eax
  800a09:	0f b6 db             	movzbl %bl,%ebx
  800a0c:	29 d8                	sub    %ebx,%eax
  800a0e:	eb 05                	jmp    800a15 <memcmp+0x39>
	}

	return 0;
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a15:	5b                   	pop    %ebx
  800a16:	5e                   	pop    %esi
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a19:	f3 0f 1e fb          	endbr32 
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a26:	89 c2                	mov    %eax,%edx
  800a28:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2b:	39 d0                	cmp    %edx,%eax
  800a2d:	73 09                	jae    800a38 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2f:	38 08                	cmp    %cl,(%eax)
  800a31:	74 05                	je     800a38 <memfind+0x1f>
	for (; s < ends; s++)
  800a33:	83 c0 01             	add    $0x1,%eax
  800a36:	eb f3                	jmp    800a2b <memfind+0x12>
			break;
	return (void *) s;
}
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3a:	f3 0f 1e fb          	endbr32 
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	57                   	push   %edi
  800a42:	56                   	push   %esi
  800a43:	53                   	push   %ebx
  800a44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4a:	eb 03                	jmp    800a4f <strtol+0x15>
		s++;
  800a4c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a4f:	0f b6 01             	movzbl (%ecx),%eax
  800a52:	3c 20                	cmp    $0x20,%al
  800a54:	74 f6                	je     800a4c <strtol+0x12>
  800a56:	3c 09                	cmp    $0x9,%al
  800a58:	74 f2                	je     800a4c <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a5a:	3c 2b                	cmp    $0x2b,%al
  800a5c:	74 2a                	je     800a88 <strtol+0x4e>
	int neg = 0;
  800a5e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a63:	3c 2d                	cmp    $0x2d,%al
  800a65:	74 2b                	je     800a92 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a67:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a6d:	75 0f                	jne    800a7e <strtol+0x44>
  800a6f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a72:	74 28                	je     800a9c <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a74:	85 db                	test   %ebx,%ebx
  800a76:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a7b:	0f 44 d8             	cmove  %eax,%ebx
  800a7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a83:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a86:	eb 46                	jmp    800ace <strtol+0x94>
		s++;
  800a88:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a8b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a90:	eb d5                	jmp    800a67 <strtol+0x2d>
		s++, neg = 1;
  800a92:	83 c1 01             	add    $0x1,%ecx
  800a95:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9a:	eb cb                	jmp    800a67 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa0:	74 0e                	je     800ab0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aa2:	85 db                	test   %ebx,%ebx
  800aa4:	75 d8                	jne    800a7e <strtol+0x44>
		s++, base = 8;
  800aa6:	83 c1 01             	add    $0x1,%ecx
  800aa9:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aae:	eb ce                	jmp    800a7e <strtol+0x44>
		s += 2, base = 16;
  800ab0:	83 c1 02             	add    $0x2,%ecx
  800ab3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab8:	eb c4                	jmp    800a7e <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aba:	0f be d2             	movsbl %dl,%edx
  800abd:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac3:	7d 3a                	jge    800aff <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ac5:	83 c1 01             	add    $0x1,%ecx
  800ac8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800acc:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ace:	0f b6 11             	movzbl (%ecx),%edx
  800ad1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad4:	89 f3                	mov    %esi,%ebx
  800ad6:	80 fb 09             	cmp    $0x9,%bl
  800ad9:	76 df                	jbe    800aba <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800adb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ade:	89 f3                	mov    %esi,%ebx
  800ae0:	80 fb 19             	cmp    $0x19,%bl
  800ae3:	77 08                	ja     800aed <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ae5:	0f be d2             	movsbl %dl,%edx
  800ae8:	83 ea 57             	sub    $0x57,%edx
  800aeb:	eb d3                	jmp    800ac0 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800aed:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af0:	89 f3                	mov    %esi,%ebx
  800af2:	80 fb 19             	cmp    $0x19,%bl
  800af5:	77 08                	ja     800aff <strtol+0xc5>
			dig = *s - 'A' + 10;
  800af7:	0f be d2             	movsbl %dl,%edx
  800afa:	83 ea 37             	sub    $0x37,%edx
  800afd:	eb c1                	jmp    800ac0 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b03:	74 05                	je     800b0a <strtol+0xd0>
		*endptr = (char *) s;
  800b05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b08:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b0a:	89 c2                	mov    %eax,%edx
  800b0c:	f7 da                	neg    %edx
  800b0e:	85 ff                	test   %edi,%edi
  800b10:	0f 45 c2             	cmovne %edx,%eax
}
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5f                   	pop    %edi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 1c             	sub    $0x1c,%esp
  800b21:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b24:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b27:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b32:	8b 75 14             	mov    0x14(%ebp),%esi
  800b35:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b37:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b3b:	74 04                	je     800b41 <syscall+0x29>
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	7f 08                	jg     800b49 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800b41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b49:	83 ec 0c             	sub    $0xc,%esp
  800b4c:	50                   	push   %eax
  800b4d:	ff 75 e0             	pushl  -0x20(%ebp)
  800b50:	68 5f 27 80 00       	push   $0x80275f
  800b55:	6a 23                	push   $0x23
  800b57:	68 7c 27 80 00       	push   $0x80277c
  800b5c:	e8 f2 f5 ff ff       	call   800153 <_panic>

00800b61 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800b61:	f3 0f 1e fb          	endbr32 
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b6b:	6a 00                	push   $0x0
  800b6d:	6a 00                	push   $0x0
  800b6f:	6a 00                	push   $0x0
  800b71:	ff 75 0c             	pushl  0xc(%ebp)
  800b74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b77:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b81:	e8 92 ff ff ff       	call   800b18 <syscall>
}
  800b86:	83 c4 10             	add    $0x10,%esp
  800b89:	c9                   	leave  
  800b8a:	c3                   	ret    

00800b8b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b8b:	f3 0f 1e fb          	endbr32 
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b95:	6a 00                	push   $0x0
  800b97:	6a 00                	push   $0x0
  800b99:	6a 00                	push   $0x0
  800b9b:	6a 00                	push   $0x0
  800b9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba7:	b8 01 00 00 00       	mov    $0x1,%eax
  800bac:	e8 67 ff ff ff       	call   800b18 <syscall>
}
  800bb1:	c9                   	leave  
  800bb2:	c3                   	ret    

00800bb3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb3:	f3 0f 1e fb          	endbr32 
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bbd:	6a 00                	push   $0x0
  800bbf:	6a 00                	push   $0x0
  800bc1:	6a 00                	push   $0x0
  800bc3:	6a 00                	push   $0x0
  800bc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc8:	ba 01 00 00 00       	mov    $0x1,%edx
  800bcd:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd2:	e8 41 ff ff ff       	call   800b18 <syscall>
}
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd9:	f3 0f 1e fb          	endbr32 
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800be3:	6a 00                	push   $0x0
  800be5:	6a 00                	push   $0x0
  800be7:	6a 00                	push   $0x0
  800be9:	6a 00                	push   $0x0
  800beb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bfa:	e8 19 ff ff ff       	call   800b18 <syscall>
}
  800bff:	c9                   	leave  
  800c00:	c3                   	ret    

00800c01 <sys_yield>:

void
sys_yield(void)
{
  800c01:	f3 0f 1e fb          	endbr32 
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c0b:	6a 00                	push   $0x0
  800c0d:	6a 00                	push   $0x0
  800c0f:	6a 00                	push   $0x0
  800c11:	6a 00                	push   $0x0
  800c13:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c18:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c22:	e8 f1 fe ff ff       	call   800b18 <syscall>
}
  800c27:	83 c4 10             	add    $0x10,%esp
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c2c:	f3 0f 1e fb          	endbr32 
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c36:	6a 00                	push   $0x0
  800c38:	6a 00                	push   $0x0
  800c3a:	ff 75 10             	pushl  0x10(%ebp)
  800c3d:	ff 75 0c             	pushl  0xc(%ebp)
  800c40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c43:	ba 01 00 00 00       	mov    $0x1,%edx
  800c48:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4d:	e8 c6 fe ff ff       	call   800b18 <syscall>
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c54:	f3 0f 1e fb          	endbr32 
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c5e:	ff 75 18             	pushl  0x18(%ebp)
  800c61:	ff 75 14             	pushl  0x14(%ebp)
  800c64:	ff 75 10             	pushl  0x10(%ebp)
  800c67:	ff 75 0c             	pushl  0xc(%ebp)
  800c6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c72:	b8 05 00 00 00       	mov    $0x5,%eax
  800c77:	e8 9c fe ff ff       	call   800b18 <syscall>
}
  800c7c:	c9                   	leave  
  800c7d:	c3                   	ret    

00800c7e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7e:	f3 0f 1e fb          	endbr32 
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c88:	6a 00                	push   $0x0
  800c8a:	6a 00                	push   $0x0
  800c8c:	6a 00                	push   $0x0
  800c8e:	ff 75 0c             	pushl  0xc(%ebp)
  800c91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c94:	ba 01 00 00 00       	mov    $0x1,%edx
  800c99:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9e:	e8 75 fe ff ff       	call   800b18 <syscall>
}
  800ca3:	c9                   	leave  
  800ca4:	c3                   	ret    

00800ca5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca5:	f3 0f 1e fb          	endbr32 
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800caf:	6a 00                	push   $0x0
  800cb1:	6a 00                	push   $0x0
  800cb3:	6a 00                	push   $0x0
  800cb5:	ff 75 0c             	pushl  0xc(%ebp)
  800cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbb:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc0:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc5:	e8 4e fe ff ff       	call   800b18 <syscall>
}
  800cca:	c9                   	leave  
  800ccb:	c3                   	ret    

00800ccc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ccc:	f3 0f 1e fb          	endbr32 
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800cd6:	6a 00                	push   $0x0
  800cd8:	6a 00                	push   $0x0
  800cda:	6a 00                	push   $0x0
  800cdc:	ff 75 0c             	pushl  0xc(%ebp)
  800cdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce2:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce7:	b8 09 00 00 00       	mov    $0x9,%eax
  800cec:	e8 27 fe ff ff       	call   800b18 <syscall>
}
  800cf1:	c9                   	leave  
  800cf2:	c3                   	ret    

00800cf3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf3:	f3 0f 1e fb          	endbr32 
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cfd:	6a 00                	push   $0x0
  800cff:	6a 00                	push   $0x0
  800d01:	6a 00                	push   $0x0
  800d03:	ff 75 0c             	pushl  0xc(%ebp)
  800d06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d09:	ba 01 00 00 00       	mov    $0x1,%edx
  800d0e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d13:	e8 00 fe ff ff       	call   800b18 <syscall>
}
  800d18:	c9                   	leave  
  800d19:	c3                   	ret    

00800d1a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1a:	f3 0f 1e fb          	endbr32 
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d24:	6a 00                	push   $0x0
  800d26:	ff 75 14             	pushl  0x14(%ebp)
  800d29:	ff 75 10             	pushl  0x10(%ebp)
  800d2c:	ff 75 0c             	pushl  0xc(%ebp)
  800d2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d32:	ba 00 00 00 00       	mov    $0x0,%edx
  800d37:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3c:	e8 d7 fd ff ff       	call   800b18 <syscall>
}
  800d41:	c9                   	leave  
  800d42:	c3                   	ret    

00800d43 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d43:	f3 0f 1e fb          	endbr32 
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d4d:	6a 00                	push   $0x0
  800d4f:	6a 00                	push   $0x0
  800d51:	6a 00                	push   $0x0
  800d53:	6a 00                	push   $0x0
  800d55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d58:	ba 01 00 00 00       	mov    $0x1,%edx
  800d5d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d62:	e8 b1 fd ff ff       	call   800b18 <syscall>
}
  800d67:	c9                   	leave  
  800d68:	c3                   	ret    

00800d69 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 04             	sub    $0x4,%esp
	int r;

	// LAB 4: Your code here.
	void *addr = (void *) (pn * PGSIZE);
  800d70:	89 d3                	mov    %edx,%ebx
  800d72:	c1 e3 0c             	shl    $0xc,%ebx

	if (uvpt[pn] & PTE_SHARE) {
  800d75:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d7c:	f6 c5 04             	test   $0x4,%ch
  800d7f:	75 56                	jne    800dd7 <duppage+0x6e>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
		return 0;
	}

	if ((uvpt[pn] & (PTE_W | PTE_COW)) != 0) {
  800d81:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d88:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800d8e:	74 72                	je     800e02 <duppage+0x99>
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW) <
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	68 05 08 00 00       	push   $0x805
  800d98:	53                   	push   %ebx
  800d99:	50                   	push   %eax
  800d9a:	53                   	push   %ebx
  800d9b:	6a 00                	push   $0x0
  800d9d:	e8 b2 fe ff ff       	call   800c54 <sys_page_map>
  800da2:	83 c4 20             	add    $0x20,%esp
  800da5:	85 c0                	test   %eax,%eax
  800da7:	78 45                	js     800dee <duppage+0x85>
		    0) {
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
		}
		if (sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW) < 0) {
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	68 05 08 00 00       	push   $0x805
  800db1:	53                   	push   %ebx
  800db2:	6a 00                	push   $0x0
  800db4:	53                   	push   %ebx
  800db5:	6a 00                	push   $0x0
  800db7:	e8 98 fe ff ff       	call   800c54 <sys_page_map>
  800dbc:	83 c4 20             	add    $0x20,%esp
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	79 55                	jns    800e18 <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP FATHER");
  800dc3:	83 ec 04             	sub    $0x4,%esp
  800dc6:	68 ac 27 80 00       	push   $0x8027ac
  800dcb:	6a 54                	push   $0x54
  800dcd:	68 3f 28 80 00       	push   $0x80283f
  800dd2:	e8 7c f3 ff ff       	call   800153 <_panic>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	68 07 0e 00 00       	push   $0xe07
  800ddf:	53                   	push   %ebx
  800de0:	50                   	push   %eax
  800de1:	53                   	push   %ebx
  800de2:	6a 00                	push   $0x0
  800de4:	e8 6b fe ff ff       	call   800c54 <sys_page_map>
		return 0;
  800de9:	83 c4 20             	add    $0x20,%esp
  800dec:	eb 2a                	jmp    800e18 <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
  800dee:	83 ec 04             	sub    $0x4,%esp
  800df1:	68 8c 27 80 00       	push   $0x80278c
  800df6:	6a 51                	push   $0x51
  800df8:	68 3f 28 80 00       	push   $0x80283f
  800dfd:	e8 51 f3 ff ff       	call   800153 <_panic>
		}
	} else {
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U) < 0) {
  800e02:	83 ec 0c             	sub    $0xc,%esp
  800e05:	6a 05                	push   $0x5
  800e07:	53                   	push   %ebx
  800e08:	50                   	push   %eax
  800e09:	53                   	push   %ebx
  800e0a:	6a 00                	push   $0x0
  800e0c:	e8 43 fe ff ff       	call   800c54 <sys_page_map>
  800e11:	83 c4 20             	add    $0x20,%esp
  800e14:	85 c0                	test   %eax,%eax
  800e16:	78 0a                	js     800e22 <duppage+0xb9>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
		}
	}

	return 0;
}
  800e18:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e20:	c9                   	leave  
  800e21:	c3                   	ret    
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
  800e22:	83 ec 04             	sub    $0x4,%esp
  800e25:	68 4a 28 80 00       	push   $0x80284a
  800e2a:	6a 58                	push   $0x58
  800e2c:	68 3f 28 80 00       	push   $0x80283f
  800e31:	e8 1d f3 ff ff       	call   800153 <_panic>

00800e36 <dup_or_share>:

static void
dup_or_share(envid_t dstenv, void *va, int perm)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	56                   	push   %esi
  800e3a:	53                   	push   %ebx
  800e3b:	89 c6                	mov    %eax,%esi
  800e3d:	89 d3                	mov    %edx,%ebx
	int r;
	if (perm & PTE_W) {
  800e3f:	f6 c1 02             	test   $0x2,%cl
  800e42:	0f 84 8c 00 00 00    	je     800ed4 <dup_or_share+0x9e>
		// dup
		if ((r = sys_page_alloc(dstenv, va, PTE_P | PTE_U | PTE_W)) < 0)
  800e48:	83 ec 04             	sub    $0x4,%esp
  800e4b:	6a 07                	push   $0x7
  800e4d:	52                   	push   %edx
  800e4e:	50                   	push   %eax
  800e4f:	e8 d8 fd ff ff       	call   800c2c <sys_page_alloc>
  800e54:	83 c4 10             	add    $0x10,%esp
  800e57:	85 c0                	test   %eax,%eax
  800e59:	78 55                	js     800eb0 <dup_or_share+0x7a>
			panic("sys_page_alloc: %e", r);
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  800e5b:	83 ec 0c             	sub    $0xc,%esp
  800e5e:	6a 07                	push   $0x7
  800e60:	68 00 00 40 00       	push   $0x400000
  800e65:	6a 00                	push   $0x0
  800e67:	53                   	push   %ebx
  800e68:	56                   	push   %esi
  800e69:	e8 e6 fd ff ff       	call   800c54 <sys_page_map>
  800e6e:	83 c4 20             	add    $0x20,%esp
  800e71:	85 c0                	test   %eax,%eax
  800e73:	78 4d                	js     800ec2 <dup_or_share+0x8c>
		    0)
			panic("sys_page_map: %e", r);
		memmove(UTEMP, va, PGSIZE);
  800e75:	83 ec 04             	sub    $0x4,%esp
  800e78:	68 00 10 00 00       	push   $0x1000
  800e7d:	53                   	push   %ebx
  800e7e:	68 00 00 40 00       	push   $0x400000
  800e83:	e8 d4 fa ff ff       	call   80095c <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800e88:	83 c4 08             	add    $0x8,%esp
  800e8b:	68 00 00 40 00       	push   $0x400000
  800e90:	6a 00                	push   $0x0
  800e92:	e8 e7 fd ff ff       	call   800c7e <sys_page_unmap>
  800e97:	83 c4 10             	add    $0x10,%esp
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	79 52                	jns    800ef0 <dup_or_share+0xba>
			panic("sys_page_unmap: %e", r);
  800e9e:	50                   	push   %eax
  800e9f:	68 8a 28 80 00       	push   $0x80288a
  800ea4:	6a 6c                	push   $0x6c
  800ea6:	68 3f 28 80 00       	push   $0x80283f
  800eab:	e8 a3 f2 ff ff       	call   800153 <_panic>
			panic("sys_page_alloc: %e", r);
  800eb0:	50                   	push   %eax
  800eb1:	68 66 28 80 00       	push   $0x802866
  800eb6:	6a 66                	push   $0x66
  800eb8:	68 3f 28 80 00       	push   $0x80283f
  800ebd:	e8 91 f2 ff ff       	call   800153 <_panic>
			panic("sys_page_map: %e", r);
  800ec2:	50                   	push   %eax
  800ec3:	68 79 28 80 00       	push   $0x802879
  800ec8:	6a 69                	push   $0x69
  800eca:	68 3f 28 80 00       	push   $0x80283f
  800ecf:	e8 7f f2 ff ff       	call   800153 <_panic>

	} else {
		// share
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | perm)) <
  800ed4:	83 ec 0c             	sub    $0xc,%esp
  800ed7:	83 c9 05             	or     $0x5,%ecx
  800eda:	51                   	push   %ecx
  800edb:	68 00 00 40 00       	push   $0x400000
  800ee0:	6a 00                	push   $0x0
  800ee2:	52                   	push   %edx
  800ee3:	50                   	push   %eax
  800ee4:	e8 6b fd ff ff       	call   800c54 <sys_page_map>
  800ee9:	83 c4 20             	add    $0x20,%esp
  800eec:	85 c0                	test   %eax,%eax
  800eee:	78 07                	js     800ef7 <dup_or_share+0xc1>
		    0)
			panic("sys_page_map: %e", r);
	}
}
  800ef0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef3:	5b                   	pop    %ebx
  800ef4:	5e                   	pop    %esi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    
			panic("sys_page_map: %e", r);
  800ef7:	50                   	push   %eax
  800ef8:	68 79 28 80 00       	push   $0x802879
  800efd:	6a 72                	push   $0x72
  800eff:	68 3f 28 80 00       	push   $0x80283f
  800f04:	e8 4a f2 ff ff       	call   800153 <_panic>

00800f09 <pgfault>:
{
  800f09:	f3 0f 1e fb          	endbr32 
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	53                   	push   %ebx
  800f11:	83 ec 04             	sub    $0x4,%esp
  800f14:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800f17:	8b 02                	mov    (%edx),%eax
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800f19:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f1d:	0f 84 95 00 00 00    	je     800fb8 <pgfault+0xaf>
  800f23:	89 c2                	mov    %eax,%edx
  800f25:	c1 ea 16             	shr    $0x16,%edx
  800f28:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f2f:	f6 c2 01             	test   $0x1,%dl
  800f32:	0f 84 80 00 00 00    	je     800fb8 <pgfault+0xaf>
	    (~uvpt[PGNUM(addr)] & (PTE_COW | PTE_P)) != 0) {
  800f38:	89 c2                	mov    %eax,%edx
  800f3a:	c1 ea 0c             	shr    $0xc,%edx
  800f3d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f44:	f7 d2                	not    %edx
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800f46:	f7 c2 01 08 00 00    	test   $0x801,%edx
  800f4c:	75 6a                	jne    800fb8 <pgfault+0xaf>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800f4e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f53:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U) < 0) {
  800f55:	83 ec 04             	sub    $0x4,%esp
  800f58:	6a 07                	push   $0x7
  800f5a:	68 00 f0 7f 00       	push   $0x7ff000
  800f5f:	6a 00                	push   $0x0
  800f61:	e8 c6 fc ff ff       	call   800c2c <sys_page_alloc>
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	78 5f                	js     800fcc <pgfault+0xc3>
	memcpy((void *) PFTEMP, addr, PGSIZE);
  800f6d:	83 ec 04             	sub    $0x4,%esp
  800f70:	68 00 10 00 00       	push   $0x1000
  800f75:	53                   	push   %ebx
  800f76:	68 00 f0 7f 00       	push   $0x7ff000
  800f7b:	e8 42 fa ff ff       	call   8009c2 <memcpy>
	if (sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U) < 0) {
  800f80:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f87:	53                   	push   %ebx
  800f88:	6a 00                	push   $0x0
  800f8a:	68 00 f0 7f 00       	push   $0x7ff000
  800f8f:	6a 00                	push   $0x0
  800f91:	e8 be fc ff ff       	call   800c54 <sys_page_map>
  800f96:	83 c4 20             	add    $0x20,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 43                	js     800fe0 <pgfault+0xd7>
	if (sys_page_unmap(0, (void *) PFTEMP) < 0) {
  800f9d:	83 ec 08             	sub    $0x8,%esp
  800fa0:	68 00 f0 7f 00       	push   $0x7ff000
  800fa5:	6a 00                	push   $0x0
  800fa7:	e8 d2 fc ff ff       	call   800c7e <sys_page_unmap>
  800fac:	83 c4 10             	add    $0x10,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	78 41                	js     800ff4 <pgfault+0xeb>
}
  800fb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    
		panic("ERROR PGFAULT");
  800fb8:	83 ec 04             	sub    $0x4,%esp
  800fbb:	68 9d 28 80 00       	push   $0x80289d
  800fc0:	6a 1e                	push   $0x1e
  800fc2:	68 3f 28 80 00       	push   $0x80283f
  800fc7:	e8 87 f1 ff ff       	call   800153 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_ALLOC");
  800fcc:	83 ec 04             	sub    $0x4,%esp
  800fcf:	68 ab 28 80 00       	push   $0x8028ab
  800fd4:	6a 2b                	push   $0x2b
  800fd6:	68 3f 28 80 00       	push   $0x80283f
  800fdb:	e8 73 f1 ff ff       	call   800153 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_MAP");
  800fe0:	83 ec 04             	sub    $0x4,%esp
  800fe3:	68 c9 28 80 00       	push   $0x8028c9
  800fe8:	6a 2f                	push   $0x2f
  800fea:	68 3f 28 80 00       	push   $0x80283f
  800fef:	e8 5f f1 ff ff       	call   800153 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_UNMAP");
  800ff4:	83 ec 04             	sub    $0x4,%esp
  800ff7:	68 e5 28 80 00       	push   $0x8028e5
  800ffc:	6a 32                	push   $0x32
  800ffe:	68 3f 28 80 00       	push   $0x80283f
  801003:	e8 4b f1 ff ff       	call   800153 <_panic>

00801008 <fork_v0>:

envid_t
fork_v0(void)
{
  801008:	f3 0f 1e fb          	endbr32 
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	57                   	push   %edi
  801010:	56                   	push   %esi
  801011:	53                   	push   %ebx
  801012:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801015:	b8 07 00 00 00       	mov    $0x7,%eax
  80101a:	cd 30                	int    $0x30
	envid_t env_id = sys_exofork();
	if (env_id < 0) {
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 24                	js     801044 <fork_v0+0x3c>
  801020:	89 c6                	mov    %eax,%esi
  801022:	89 c7                	mov    %eax,%edi
		thisenv = envs + ENVX(sys_getenvid());
		return env_id;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801024:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (env_id == 0) {  // Son
  801029:	75 51                	jne    80107c <fork_v0+0x74>
		thisenv = envs + ENVX(sys_getenvid());
  80102b:	e8 a9 fb ff ff       	call   800bd9 <sys_getenvid>
  801030:	25 ff 03 00 00       	and    $0x3ff,%eax
  801035:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801038:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80103d:	a3 08 40 80 00       	mov    %eax,0x804008
		return env_id;
  801042:	eb 78                	jmp    8010bc <fork_v0+0xb4>
		panic("ERROR ON FORK_V0");
  801044:	83 ec 04             	sub    $0x4,%esp
  801047:	68 03 29 80 00       	push   $0x802903
  80104c:	6a 7b                	push   $0x7b
  80104e:	68 3f 28 80 00       	push   $0x80283f
  801053:	e8 fb f0 ff ff       	call   800153 <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
				dup_or_share(env_id,
  801058:	b9 07 00 00 00       	mov    $0x7,%ecx
  80105d:	89 da                	mov    %ebx,%edx
  80105f:	89 f8                	mov    %edi,%eax
  801061:	e8 d0 fd ff ff       	call   800e36 <dup_or_share>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801066:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80106c:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801072:	77 36                	ja     8010aa <fork_v0+0xa2>
		if (addr != UXSTACKTOP - PGSIZE) {
  801074:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80107a:	74 ea                	je     801066 <fork_v0+0x5e>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80107c:	89 d8                	mov    %ebx,%eax
  80107e:	c1 e8 16             	shr    $0x16,%eax
  801081:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801088:	a8 01                	test   $0x1,%al
  80108a:	74 da                	je     801066 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  80108c:	89 d8                	mov    %ebx,%eax
  80108e:	c1 e8 0c             	shr    $0xc,%eax
  801091:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801098:	f6 c2 01             	test   $0x1,%dl
  80109b:	74 c9                	je     801066 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
  80109d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  8010a4:	a8 04                	test   $0x4,%al
  8010a6:	74 be                	je     801066 <fork_v0+0x5e>
  8010a8:	eb ae                	jmp    801058 <fork_v0+0x50>
				             PTE_P | PTE_U | PTE_W);
			}
		}
	}

	if (sys_env_set_status(env_id, ENV_RUNNABLE) < 0) {
  8010aa:	83 ec 08             	sub    $0x8,%esp
  8010ad:	6a 02                	push   $0x2
  8010af:	56                   	push   %esi
  8010b0:	e8 f0 fb ff ff       	call   800ca5 <sys_env_set_status>
  8010b5:	83 c4 10             	add    $0x10,%esp
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	78 0a                	js     8010c6 <fork_v0+0xbe>
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
	}

	return env_id;
}
  8010bc:	89 f0                	mov    %esi,%eax
  8010be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c1:	5b                   	pop    %ebx
  8010c2:	5e                   	pop    %esi
  8010c3:	5f                   	pop    %edi
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
  8010c6:	83 ec 04             	sub    $0x4,%esp
  8010c9:	68 d0 27 80 00       	push   $0x8027d0
  8010ce:	68 92 00 00 00       	push   $0x92
  8010d3:	68 3f 28 80 00       	push   $0x80283f
  8010d8:	e8 76 f0 ff ff       	call   800153 <_panic>

008010dd <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010dd:	f3 0f 1e fb          	endbr32 
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	57                   	push   %edi
  8010e5:	56                   	push   %esi
  8010e6:	53                   	push   %ebx
  8010e7:	83 ec 18             	sub    $0x18,%esp
	// return fork_v0(); // Uncomment this line if you want to run fork_v0.
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8010ea:	68 09 0f 80 00       	push   $0x800f09
  8010ef:	e8 ab 0e 00 00       	call   801f9f <set_pgfault_handler>
  8010f4:	b8 07 00 00 00       	mov    $0x7,%eax
  8010f9:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0) {
  8010fb:	83 c4 10             	add    $0x10,%esp
  8010fe:	85 c0                	test   %eax,%eax
  801100:	78 27                	js     801129 <fork+0x4c>
  801102:	89 c7                	mov    %eax,%edi
  801104:	89 c6                	mov    %eax,%esi
		thisenv = envs + ENVX(sys_getenvid());
		return envid;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801106:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else if (envid == 0) {  // Son
  80110b:	75 55                	jne    801162 <fork+0x85>
		thisenv = envs + ENVX(sys_getenvid());
  80110d:	e8 c7 fa ff ff       	call   800bd9 <sys_getenvid>
  801112:	25 ff 03 00 00       	and    $0x3ff,%eax
  801117:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80111a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80111f:	a3 08 40 80 00       	mov    %eax,0x804008
		return envid;
  801124:	e9 9b 00 00 00       	jmp    8011c4 <fork+0xe7>
		panic("ERROR IN FORK: SYS_EXOFORK");
  801129:	83 ec 04             	sub    $0x4,%esp
  80112c:	68 14 29 80 00       	push   $0x802914
  801131:	68 b1 00 00 00       	push   $0xb1
  801136:	68 3f 28 80 00       	push   $0x80283f
  80113b:	e8 13 f0 ff ff       	call   800153 <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
				duppage(envid, addr / PGSIZE);
  801140:	89 da                	mov    %ebx,%edx
  801142:	c1 ea 0c             	shr    $0xc,%edx
  801145:	89 f0                	mov    %esi,%eax
  801147:	e8 1d fc ff ff       	call   800d69 <duppage>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  80114c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801152:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801158:	77 2c                	ja     801186 <fork+0xa9>
		if (addr != UXSTACKTOP - PGSIZE) {
  80115a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801160:	74 ea                	je     80114c <fork+0x6f>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801162:	89 d8                	mov    %ebx,%eax
  801164:	c1 e8 16             	shr    $0x16,%eax
  801167:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80116e:	a8 01                	test   $0x1,%al
  801170:	74 da                	je     80114c <fork+0x6f>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
  801172:	89 d8                	mov    %ebx,%eax
  801174:	c1 e8 0c             	shr    $0xc,%eax
  801177:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80117e:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801180:	a8 05                	test   $0x5,%al
  801182:	75 c8                	jne    80114c <fork+0x6f>
  801184:	eb ba                	jmp    801140 <fork+0x63>
			}
		}
	}

	if (sys_page_alloc(envid,
  801186:	83 ec 04             	sub    $0x4,%esp
  801189:	6a 07                	push   $0x7
  80118b:	68 00 f0 bf ee       	push   $0xeebff000
  801190:	57                   	push   %edi
  801191:	e8 96 fa ff ff       	call   800c2c <sys_page_alloc>
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	85 c0                	test   %eax,%eax
  80119b:	78 31                	js     8011ce <fork+0xf1>
	                   PTE_P | PTE_U | PTE_W) < 0) {
		panic("ERROR FORK: SYS_PAGE_ALLOC");
	}

	extern void _pgfault_upcall(void);
	if (sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0) {
  80119d:	83 ec 08             	sub    $0x8,%esp
  8011a0:	68 12 20 80 00       	push   $0x802012
  8011a5:	57                   	push   %edi
  8011a6:	e8 48 fb ff ff       	call   800cf3 <sys_env_set_pgfault_upcall>
  8011ab:	83 c4 10             	add    $0x10,%esp
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	78 33                	js     8011e5 <fork+0x108>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
	}

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0) {
  8011b2:	83 ec 08             	sub    $0x8,%esp
  8011b5:	6a 02                	push   $0x2
  8011b7:	57                   	push   %edi
  8011b8:	e8 e8 fa ff ff       	call   800ca5 <sys_env_set_status>
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	78 38                	js     8011fc <fork+0x11f>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
	}

	return envid;
}
  8011c4:	89 f8                	mov    %edi,%eax
  8011c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c9:	5b                   	pop    %ebx
  8011ca:	5e                   	pop    %esi
  8011cb:	5f                   	pop    %edi
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    
		panic("ERROR FORK: SYS_PAGE_ALLOC");
  8011ce:	83 ec 04             	sub    $0x4,%esp
  8011d1:	68 2f 29 80 00       	push   $0x80292f
  8011d6:	68 c4 00 00 00       	push   $0xc4
  8011db:	68 3f 28 80 00       	push   $0x80283f
  8011e0:	e8 6e ef ff ff       	call   800153 <_panic>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
  8011e5:	83 ec 04             	sub    $0x4,%esp
  8011e8:	68 f8 27 80 00       	push   $0x8027f8
  8011ed:	68 c9 00 00 00       	push   $0xc9
  8011f2:	68 3f 28 80 00       	push   $0x80283f
  8011f7:	e8 57 ef ff ff       	call   800153 <_panic>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
  8011fc:	83 ec 04             	sub    $0x4,%esp
  8011ff:	68 20 28 80 00       	push   $0x802820
  801204:	68 cd 00 00 00       	push   $0xcd
  801209:	68 3f 28 80 00       	push   $0x80283f
  80120e:	e8 40 ef ff ff       	call   800153 <_panic>

00801213 <sfork>:

// Challenge!
int
sfork(void)
{
  801213:	f3 0f 1e fb          	endbr32 
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80121d:	68 4a 29 80 00       	push   $0x80294a
  801222:	68 d7 00 00 00       	push   $0xd7
  801227:	68 3f 28 80 00       	push   $0x80283f
  80122c:	e8 22 ef ff ff       	call   800153 <_panic>

00801231 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801231:	f3 0f 1e fb          	endbr32 
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801238:	8b 45 08             	mov    0x8(%ebp),%eax
  80123b:	05 00 00 00 30       	add    $0x30000000,%eax
  801240:	c1 e8 0c             	shr    $0xc,%eax
}
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    

00801245 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801245:	f3 0f 1e fb          	endbr32 
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  80124f:	ff 75 08             	pushl  0x8(%ebp)
  801252:	e8 da ff ff ff       	call   801231 <fd2num>
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	c1 e0 0c             	shl    $0xc,%eax
  80125d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801262:	c9                   	leave  
  801263:	c3                   	ret    

00801264 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801264:	f3 0f 1e fb          	endbr32 
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801270:	89 c2                	mov    %eax,%edx
  801272:	c1 ea 16             	shr    $0x16,%edx
  801275:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80127c:	f6 c2 01             	test   $0x1,%dl
  80127f:	74 2d                	je     8012ae <fd_alloc+0x4a>
  801281:	89 c2                	mov    %eax,%edx
  801283:	c1 ea 0c             	shr    $0xc,%edx
  801286:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80128d:	f6 c2 01             	test   $0x1,%dl
  801290:	74 1c                	je     8012ae <fd_alloc+0x4a>
  801292:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801297:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80129c:	75 d2                	jne    801270 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80129e:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8012a7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8012ac:	eb 0a                	jmp    8012b8 <fd_alloc+0x54>
			*fd_store = fd;
  8012ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b8:	5d                   	pop    %ebp
  8012b9:	c3                   	ret    

008012ba <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012ba:	f3 0f 1e fb          	endbr32 
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012c4:	83 f8 1f             	cmp    $0x1f,%eax
  8012c7:	77 30                	ja     8012f9 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012c9:	c1 e0 0c             	shl    $0xc,%eax
  8012cc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012d1:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8012d7:	f6 c2 01             	test   $0x1,%dl
  8012da:	74 24                	je     801300 <fd_lookup+0x46>
  8012dc:	89 c2                	mov    %eax,%edx
  8012de:	c1 ea 0c             	shr    $0xc,%edx
  8012e1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e8:	f6 c2 01             	test   $0x1,%dl
  8012eb:	74 1a                	je     801307 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f0:	89 02                	mov    %eax,(%edx)
	return 0;
  8012f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    
		return -E_INVAL;
  8012f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012fe:	eb f7                	jmp    8012f7 <fd_lookup+0x3d>
		return -E_INVAL;
  801300:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801305:	eb f0                	jmp    8012f7 <fd_lookup+0x3d>
  801307:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80130c:	eb e9                	jmp    8012f7 <fd_lookup+0x3d>

0080130e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80130e:	f3 0f 1e fb          	endbr32 
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80131b:	ba dc 29 80 00       	mov    $0x8029dc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801320:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801325:	39 08                	cmp    %ecx,(%eax)
  801327:	74 33                	je     80135c <dev_lookup+0x4e>
  801329:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80132c:	8b 02                	mov    (%edx),%eax
  80132e:	85 c0                	test   %eax,%eax
  801330:	75 f3                	jne    801325 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801332:	a1 08 40 80 00       	mov    0x804008,%eax
  801337:	8b 40 48             	mov    0x48(%eax),%eax
  80133a:	83 ec 04             	sub    $0x4,%esp
  80133d:	51                   	push   %ecx
  80133e:	50                   	push   %eax
  80133f:	68 60 29 80 00       	push   $0x802960
  801344:	e8 f1 ee ff ff       	call   80023a <cprintf>
	*dev = 0;
  801349:	8b 45 0c             	mov    0xc(%ebp),%eax
  80134c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80135a:	c9                   	leave  
  80135b:	c3                   	ret    
			*dev = devtab[i];
  80135c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80135f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801361:	b8 00 00 00 00       	mov    $0x0,%eax
  801366:	eb f2                	jmp    80135a <dev_lookup+0x4c>

00801368 <fd_close>:
{
  801368:	f3 0f 1e fb          	endbr32 
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	57                   	push   %edi
  801370:	56                   	push   %esi
  801371:	53                   	push   %ebx
  801372:	83 ec 28             	sub    $0x28,%esp
  801375:	8b 75 08             	mov    0x8(%ebp),%esi
  801378:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80137b:	56                   	push   %esi
  80137c:	e8 b0 fe ff ff       	call   801231 <fd2num>
  801381:	83 c4 08             	add    $0x8,%esp
  801384:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801387:	52                   	push   %edx
  801388:	50                   	push   %eax
  801389:	e8 2c ff ff ff       	call   8012ba <fd_lookup>
  80138e:	89 c3                	mov    %eax,%ebx
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	85 c0                	test   %eax,%eax
  801395:	78 05                	js     80139c <fd_close+0x34>
	    || fd != fd2)
  801397:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80139a:	74 16                	je     8013b2 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80139c:	89 f8                	mov    %edi,%eax
  80139e:	84 c0                	test   %al,%al
  8013a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a5:	0f 44 d8             	cmove  %eax,%ebx
}
  8013a8:	89 d8                	mov    %ebx,%eax
  8013aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ad:	5b                   	pop    %ebx
  8013ae:	5e                   	pop    %esi
  8013af:	5f                   	pop    %edi
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013b2:	83 ec 08             	sub    $0x8,%esp
  8013b5:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013b8:	50                   	push   %eax
  8013b9:	ff 36                	pushl  (%esi)
  8013bb:	e8 4e ff ff ff       	call   80130e <dev_lookup>
  8013c0:	89 c3                	mov    %eax,%ebx
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 1a                	js     8013e3 <fd_close+0x7b>
		if (dev->dev_close)
  8013c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013cc:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8013cf:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	74 0b                	je     8013e3 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8013d8:	83 ec 0c             	sub    $0xc,%esp
  8013db:	56                   	push   %esi
  8013dc:	ff d0                	call   *%eax
  8013de:	89 c3                	mov    %eax,%ebx
  8013e0:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	56                   	push   %esi
  8013e7:	6a 00                	push   $0x0
  8013e9:	e8 90 f8 ff ff       	call   800c7e <sys_page_unmap>
	return r;
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	eb b5                	jmp    8013a8 <fd_close+0x40>

008013f3 <close>:

int
close(int fdnum)
{
  8013f3:	f3 0f 1e fb          	endbr32 
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801400:	50                   	push   %eax
  801401:	ff 75 08             	pushl  0x8(%ebp)
  801404:	e8 b1 fe ff ff       	call   8012ba <fd_lookup>
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	85 c0                	test   %eax,%eax
  80140e:	79 02                	jns    801412 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801410:	c9                   	leave  
  801411:	c3                   	ret    
		return fd_close(fd, 1);
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	6a 01                	push   $0x1
  801417:	ff 75 f4             	pushl  -0xc(%ebp)
  80141a:	e8 49 ff ff ff       	call   801368 <fd_close>
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	eb ec                	jmp    801410 <close+0x1d>

00801424 <close_all>:

void
close_all(void)
{
  801424:	f3 0f 1e fb          	endbr32 
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	53                   	push   %ebx
  80142c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80142f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801434:	83 ec 0c             	sub    $0xc,%esp
  801437:	53                   	push   %ebx
  801438:	e8 b6 ff ff ff       	call   8013f3 <close>
	for (i = 0; i < MAXFD; i++)
  80143d:	83 c3 01             	add    $0x1,%ebx
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	83 fb 20             	cmp    $0x20,%ebx
  801446:	75 ec                	jne    801434 <close_all+0x10>
}
  801448:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144b:	c9                   	leave  
  80144c:	c3                   	ret    

0080144d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80144d:	f3 0f 1e fb          	endbr32 
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	57                   	push   %edi
  801455:	56                   	push   %esi
  801456:	53                   	push   %ebx
  801457:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80145a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80145d:	50                   	push   %eax
  80145e:	ff 75 08             	pushl  0x8(%ebp)
  801461:	e8 54 fe ff ff       	call   8012ba <fd_lookup>
  801466:	89 c3                	mov    %eax,%ebx
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	85 c0                	test   %eax,%eax
  80146d:	0f 88 81 00 00 00    	js     8014f4 <dup+0xa7>
		return r;
	close(newfdnum);
  801473:	83 ec 0c             	sub    $0xc,%esp
  801476:	ff 75 0c             	pushl  0xc(%ebp)
  801479:	e8 75 ff ff ff       	call   8013f3 <close>

	newfd = INDEX2FD(newfdnum);
  80147e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801481:	c1 e6 0c             	shl    $0xc,%esi
  801484:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80148a:	83 c4 04             	add    $0x4,%esp
  80148d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801490:	e8 b0 fd ff ff       	call   801245 <fd2data>
  801495:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801497:	89 34 24             	mov    %esi,(%esp)
  80149a:	e8 a6 fd ff ff       	call   801245 <fd2data>
  80149f:	83 c4 10             	add    $0x10,%esp
  8014a2:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014a4:	89 d8                	mov    %ebx,%eax
  8014a6:	c1 e8 16             	shr    $0x16,%eax
  8014a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014b0:	a8 01                	test   $0x1,%al
  8014b2:	74 11                	je     8014c5 <dup+0x78>
  8014b4:	89 d8                	mov    %ebx,%eax
  8014b6:	c1 e8 0c             	shr    $0xc,%eax
  8014b9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014c0:	f6 c2 01             	test   $0x1,%dl
  8014c3:	75 39                	jne    8014fe <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014c8:	89 d0                	mov    %edx,%eax
  8014ca:	c1 e8 0c             	shr    $0xc,%eax
  8014cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d4:	83 ec 0c             	sub    $0xc,%esp
  8014d7:	25 07 0e 00 00       	and    $0xe07,%eax
  8014dc:	50                   	push   %eax
  8014dd:	56                   	push   %esi
  8014de:	6a 00                	push   $0x0
  8014e0:	52                   	push   %edx
  8014e1:	6a 00                	push   $0x0
  8014e3:	e8 6c f7 ff ff       	call   800c54 <sys_page_map>
  8014e8:	89 c3                	mov    %eax,%ebx
  8014ea:	83 c4 20             	add    $0x20,%esp
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	78 31                	js     801522 <dup+0xd5>
		goto err;

	return newfdnum;
  8014f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014f4:	89 d8                	mov    %ebx,%eax
  8014f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f9:	5b                   	pop    %ebx
  8014fa:	5e                   	pop    %esi
  8014fb:	5f                   	pop    %edi
  8014fc:	5d                   	pop    %ebp
  8014fd:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801505:	83 ec 0c             	sub    $0xc,%esp
  801508:	25 07 0e 00 00       	and    $0xe07,%eax
  80150d:	50                   	push   %eax
  80150e:	57                   	push   %edi
  80150f:	6a 00                	push   $0x0
  801511:	53                   	push   %ebx
  801512:	6a 00                	push   $0x0
  801514:	e8 3b f7 ff ff       	call   800c54 <sys_page_map>
  801519:	89 c3                	mov    %eax,%ebx
  80151b:	83 c4 20             	add    $0x20,%esp
  80151e:	85 c0                	test   %eax,%eax
  801520:	79 a3                	jns    8014c5 <dup+0x78>
	sys_page_unmap(0, newfd);
  801522:	83 ec 08             	sub    $0x8,%esp
  801525:	56                   	push   %esi
  801526:	6a 00                	push   $0x0
  801528:	e8 51 f7 ff ff       	call   800c7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80152d:	83 c4 08             	add    $0x8,%esp
  801530:	57                   	push   %edi
  801531:	6a 00                	push   $0x0
  801533:	e8 46 f7 ff ff       	call   800c7e <sys_page_unmap>
	return r;
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	eb b7                	jmp    8014f4 <dup+0xa7>

0080153d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80153d:	f3 0f 1e fb          	endbr32 
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	53                   	push   %ebx
  801545:	83 ec 1c             	sub    $0x1c,%esp
  801548:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154e:	50                   	push   %eax
  80154f:	53                   	push   %ebx
  801550:	e8 65 fd ff ff       	call   8012ba <fd_lookup>
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	85 c0                	test   %eax,%eax
  80155a:	78 3f                	js     80159b <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155c:	83 ec 08             	sub    $0x8,%esp
  80155f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801562:	50                   	push   %eax
  801563:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801566:	ff 30                	pushl  (%eax)
  801568:	e8 a1 fd ff ff       	call   80130e <dev_lookup>
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	85 c0                	test   %eax,%eax
  801572:	78 27                	js     80159b <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801574:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801577:	8b 42 08             	mov    0x8(%edx),%eax
  80157a:	83 e0 03             	and    $0x3,%eax
  80157d:	83 f8 01             	cmp    $0x1,%eax
  801580:	74 1e                	je     8015a0 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801582:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801585:	8b 40 08             	mov    0x8(%eax),%eax
  801588:	85 c0                	test   %eax,%eax
  80158a:	74 35                	je     8015c1 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80158c:	83 ec 04             	sub    $0x4,%esp
  80158f:	ff 75 10             	pushl  0x10(%ebp)
  801592:	ff 75 0c             	pushl  0xc(%ebp)
  801595:	52                   	push   %edx
  801596:	ff d0                	call   *%eax
  801598:	83 c4 10             	add    $0x10,%esp
}
  80159b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159e:	c9                   	leave  
  80159f:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a0:	a1 08 40 80 00       	mov    0x804008,%eax
  8015a5:	8b 40 48             	mov    0x48(%eax),%eax
  8015a8:	83 ec 04             	sub    $0x4,%esp
  8015ab:	53                   	push   %ebx
  8015ac:	50                   	push   %eax
  8015ad:	68 a1 29 80 00       	push   $0x8029a1
  8015b2:	e8 83 ec ff ff       	call   80023a <cprintf>
		return -E_INVAL;
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015bf:	eb da                	jmp    80159b <read+0x5e>
		return -E_NOT_SUPP;
  8015c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015c6:	eb d3                	jmp    80159b <read+0x5e>

008015c8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015c8:	f3 0f 1e fb          	endbr32 
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	57                   	push   %edi
  8015d0:	56                   	push   %esi
  8015d1:	53                   	push   %ebx
  8015d2:	83 ec 0c             	sub    $0xc,%esp
  8015d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015d8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e0:	eb 02                	jmp    8015e4 <readn+0x1c>
  8015e2:	01 c3                	add    %eax,%ebx
  8015e4:	39 f3                	cmp    %esi,%ebx
  8015e6:	73 21                	jae    801609 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015e8:	83 ec 04             	sub    $0x4,%esp
  8015eb:	89 f0                	mov    %esi,%eax
  8015ed:	29 d8                	sub    %ebx,%eax
  8015ef:	50                   	push   %eax
  8015f0:	89 d8                	mov    %ebx,%eax
  8015f2:	03 45 0c             	add    0xc(%ebp),%eax
  8015f5:	50                   	push   %eax
  8015f6:	57                   	push   %edi
  8015f7:	e8 41 ff ff ff       	call   80153d <read>
		if (m < 0)
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 04                	js     801607 <readn+0x3f>
			return m;
		if (m == 0)
  801603:	75 dd                	jne    8015e2 <readn+0x1a>
  801605:	eb 02                	jmp    801609 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801607:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801609:	89 d8                	mov    %ebx,%eax
  80160b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160e:	5b                   	pop    %ebx
  80160f:	5e                   	pop    %esi
  801610:	5f                   	pop    %edi
  801611:	5d                   	pop    %ebp
  801612:	c3                   	ret    

00801613 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801613:	f3 0f 1e fb          	endbr32 
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	53                   	push   %ebx
  80161b:	83 ec 1c             	sub    $0x1c,%esp
  80161e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801621:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801624:	50                   	push   %eax
  801625:	53                   	push   %ebx
  801626:	e8 8f fc ff ff       	call   8012ba <fd_lookup>
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 3a                	js     80166c <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801632:	83 ec 08             	sub    $0x8,%esp
  801635:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801638:	50                   	push   %eax
  801639:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163c:	ff 30                	pushl  (%eax)
  80163e:	e8 cb fc ff ff       	call   80130e <dev_lookup>
  801643:	83 c4 10             	add    $0x10,%esp
  801646:	85 c0                	test   %eax,%eax
  801648:	78 22                	js     80166c <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80164a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801651:	74 1e                	je     801671 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801653:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801656:	8b 52 0c             	mov    0xc(%edx),%edx
  801659:	85 d2                	test   %edx,%edx
  80165b:	74 35                	je     801692 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80165d:	83 ec 04             	sub    $0x4,%esp
  801660:	ff 75 10             	pushl  0x10(%ebp)
  801663:	ff 75 0c             	pushl  0xc(%ebp)
  801666:	50                   	push   %eax
  801667:	ff d2                	call   *%edx
  801669:	83 c4 10             	add    $0x10,%esp
}
  80166c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166f:	c9                   	leave  
  801670:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801671:	a1 08 40 80 00       	mov    0x804008,%eax
  801676:	8b 40 48             	mov    0x48(%eax),%eax
  801679:	83 ec 04             	sub    $0x4,%esp
  80167c:	53                   	push   %ebx
  80167d:	50                   	push   %eax
  80167e:	68 bd 29 80 00       	push   $0x8029bd
  801683:	e8 b2 eb ff ff       	call   80023a <cprintf>
		return -E_INVAL;
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801690:	eb da                	jmp    80166c <write+0x59>
		return -E_NOT_SUPP;
  801692:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801697:	eb d3                	jmp    80166c <write+0x59>

00801699 <seek>:

int
seek(int fdnum, off_t offset)
{
  801699:	f3 0f 1e fb          	endbr32 
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a6:	50                   	push   %eax
  8016a7:	ff 75 08             	pushl  0x8(%ebp)
  8016aa:	e8 0b fc ff ff       	call   8012ba <fd_lookup>
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	78 0e                	js     8016c4 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8016b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    

008016c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016c6:	f3 0f 1e fb          	endbr32 
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	53                   	push   %ebx
  8016ce:	83 ec 1c             	sub    $0x1c,%esp
  8016d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d7:	50                   	push   %eax
  8016d8:	53                   	push   %ebx
  8016d9:	e8 dc fb ff ff       	call   8012ba <fd_lookup>
  8016de:	83 c4 10             	add    $0x10,%esp
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 37                	js     80171c <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e5:	83 ec 08             	sub    $0x8,%esp
  8016e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016eb:	50                   	push   %eax
  8016ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ef:	ff 30                	pushl  (%eax)
  8016f1:	e8 18 fc ff ff       	call   80130e <dev_lookup>
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 1f                	js     80171c <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801700:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801704:	74 1b                	je     801721 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801706:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801709:	8b 52 18             	mov    0x18(%edx),%edx
  80170c:	85 d2                	test   %edx,%edx
  80170e:	74 32                	je     801742 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801710:	83 ec 08             	sub    $0x8,%esp
  801713:	ff 75 0c             	pushl  0xc(%ebp)
  801716:	50                   	push   %eax
  801717:	ff d2                	call   *%edx
  801719:	83 c4 10             	add    $0x10,%esp
}
  80171c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171f:	c9                   	leave  
  801720:	c3                   	ret    
			thisenv->env_id, fdnum);
  801721:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801726:	8b 40 48             	mov    0x48(%eax),%eax
  801729:	83 ec 04             	sub    $0x4,%esp
  80172c:	53                   	push   %ebx
  80172d:	50                   	push   %eax
  80172e:	68 80 29 80 00       	push   $0x802980
  801733:	e8 02 eb ff ff       	call   80023a <cprintf>
		return -E_INVAL;
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801740:	eb da                	jmp    80171c <ftruncate+0x56>
		return -E_NOT_SUPP;
  801742:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801747:	eb d3                	jmp    80171c <ftruncate+0x56>

00801749 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801749:	f3 0f 1e fb          	endbr32 
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	53                   	push   %ebx
  801751:	83 ec 1c             	sub    $0x1c,%esp
  801754:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801757:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175a:	50                   	push   %eax
  80175b:	ff 75 08             	pushl  0x8(%ebp)
  80175e:	e8 57 fb ff ff       	call   8012ba <fd_lookup>
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	85 c0                	test   %eax,%eax
  801768:	78 4b                	js     8017b5 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176a:	83 ec 08             	sub    $0x8,%esp
  80176d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801770:	50                   	push   %eax
  801771:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801774:	ff 30                	pushl  (%eax)
  801776:	e8 93 fb ff ff       	call   80130e <dev_lookup>
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 33                	js     8017b5 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801782:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801785:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801789:	74 2f                	je     8017ba <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80178b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80178e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801795:	00 00 00 
	stat->st_isdir = 0;
  801798:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80179f:	00 00 00 
	stat->st_dev = dev;
  8017a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017a8:	83 ec 08             	sub    $0x8,%esp
  8017ab:	53                   	push   %ebx
  8017ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8017af:	ff 50 14             	call   *0x14(%eax)
  8017b2:	83 c4 10             	add    $0x10,%esp
}
  8017b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b8:	c9                   	leave  
  8017b9:	c3                   	ret    
		return -E_NOT_SUPP;
  8017ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017bf:	eb f4                	jmp    8017b5 <fstat+0x6c>

008017c1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017c1:	f3 0f 1e fb          	endbr32 
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	56                   	push   %esi
  8017c9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017ca:	83 ec 08             	sub    $0x8,%esp
  8017cd:	6a 00                	push   $0x0
  8017cf:	ff 75 08             	pushl  0x8(%ebp)
  8017d2:	e8 20 02 00 00       	call   8019f7 <open>
  8017d7:	89 c3                	mov    %eax,%ebx
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 1b                	js     8017fb <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8017e0:	83 ec 08             	sub    $0x8,%esp
  8017e3:	ff 75 0c             	pushl  0xc(%ebp)
  8017e6:	50                   	push   %eax
  8017e7:	e8 5d ff ff ff       	call   801749 <fstat>
  8017ec:	89 c6                	mov    %eax,%esi
	close(fd);
  8017ee:	89 1c 24             	mov    %ebx,(%esp)
  8017f1:	e8 fd fb ff ff       	call   8013f3 <close>
	return r;
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	89 f3                	mov    %esi,%ebx
}
  8017fb:	89 d8                	mov    %ebx,%eax
  8017fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801800:	5b                   	pop    %ebx
  801801:	5e                   	pop    %esi
  801802:	5d                   	pop    %ebp
  801803:	c3                   	ret    

00801804 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	56                   	push   %esi
  801808:	53                   	push   %ebx
  801809:	89 c6                	mov    %eax,%esi
  80180b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80180d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801814:	74 27                	je     80183d <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801816:	6a 07                	push   $0x7
  801818:	68 00 50 80 00       	push   $0x805000
  80181d:	56                   	push   %esi
  80181e:	ff 35 00 40 80 00    	pushl  0x804000
  801824:	e8 7c 08 00 00       	call   8020a5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801829:	83 c4 0c             	add    $0xc,%esp
  80182c:	6a 00                	push   $0x0
  80182e:	53                   	push   %ebx
  80182f:	6a 00                	push   $0x0
  801831:	e8 02 08 00 00       	call   802038 <ipc_recv>
}
  801836:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801839:	5b                   	pop    %ebx
  80183a:	5e                   	pop    %esi
  80183b:	5d                   	pop    %ebp
  80183c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80183d:	83 ec 0c             	sub    $0xc,%esp
  801840:	6a 01                	push   $0x1
  801842:	e8 b1 08 00 00       	call   8020f8 <ipc_find_env>
  801847:	a3 00 40 80 00       	mov    %eax,0x804000
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	eb c5                	jmp    801816 <fsipc+0x12>

00801851 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801851:	f3 0f 1e fb          	endbr32 
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80185b:	8b 45 08             	mov    0x8(%ebp),%eax
  80185e:	8b 40 0c             	mov    0xc(%eax),%eax
  801861:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801866:	8b 45 0c             	mov    0xc(%ebp),%eax
  801869:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80186e:	ba 00 00 00 00       	mov    $0x0,%edx
  801873:	b8 02 00 00 00       	mov    $0x2,%eax
  801878:	e8 87 ff ff ff       	call   801804 <fsipc>
}
  80187d:	c9                   	leave  
  80187e:	c3                   	ret    

0080187f <devfile_flush>:
{
  80187f:	f3 0f 1e fb          	endbr32 
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801889:	8b 45 08             	mov    0x8(%ebp),%eax
  80188c:	8b 40 0c             	mov    0xc(%eax),%eax
  80188f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801894:	ba 00 00 00 00       	mov    $0x0,%edx
  801899:	b8 06 00 00 00       	mov    $0x6,%eax
  80189e:	e8 61 ff ff ff       	call   801804 <fsipc>
}
  8018a3:	c9                   	leave  
  8018a4:	c3                   	ret    

008018a5 <devfile_stat>:
{
  8018a5:	f3 0f 1e fb          	endbr32 
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	53                   	push   %ebx
  8018ad:	83 ec 04             	sub    $0x4,%esp
  8018b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018be:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c3:	b8 05 00 00 00       	mov    $0x5,%eax
  8018c8:	e8 37 ff ff ff       	call   801804 <fsipc>
  8018cd:	85 c0                	test   %eax,%eax
  8018cf:	78 2c                	js     8018fd <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018d1:	83 ec 08             	sub    $0x8,%esp
  8018d4:	68 00 50 80 00       	push   $0x805000
  8018d9:	53                   	push   %ebx
  8018da:	e8 c5 ee ff ff       	call   8007a4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018df:	a1 80 50 80 00       	mov    0x805080,%eax
  8018e4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018ea:	a1 84 50 80 00       	mov    0x805084,%eax
  8018ef:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <devfile_write>:
{
  801902:	f3 0f 1e fb          	endbr32 
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	57                   	push   %edi
  80190a:	56                   	push   %esi
  80190b:	53                   	push   %ebx
  80190c:	83 ec 0c             	sub    $0xc,%esp
  80190f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801912:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	8b 40 0c             	mov    0xc(%eax),%eax
  80191b:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  801920:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801925:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  80192a:	85 db                	test   %ebx,%ebx
  80192c:	74 3b                	je     801969 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80192e:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801934:	89 f8                	mov    %edi,%eax
  801936:	0f 46 c3             	cmovbe %ebx,%eax
  801939:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  80193e:	83 ec 04             	sub    $0x4,%esp
  801941:	50                   	push   %eax
  801942:	56                   	push   %esi
  801943:	68 08 50 80 00       	push   $0x805008
  801948:	e8 0f f0 ff ff       	call   80095c <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80194d:	ba 00 00 00 00       	mov    $0x0,%edx
  801952:	b8 04 00 00 00       	mov    $0x4,%eax
  801957:	e8 a8 fe ff ff       	call   801804 <fsipc>
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	85 c0                	test   %eax,%eax
  801961:	78 06                	js     801969 <devfile_write+0x67>
		buf_aux += r;
  801963:	01 c6                	add    %eax,%esi
		n -= r;
  801965:	29 c3                	sub    %eax,%ebx
  801967:	eb c1                	jmp    80192a <devfile_write+0x28>
}
  801969:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80196c:	5b                   	pop    %ebx
  80196d:	5e                   	pop    %esi
  80196e:	5f                   	pop    %edi
  80196f:	5d                   	pop    %ebp
  801970:	c3                   	ret    

00801971 <devfile_read>:
{
  801971:	f3 0f 1e fb          	endbr32 
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	56                   	push   %esi
  801979:	53                   	push   %ebx
  80197a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80197d:	8b 45 08             	mov    0x8(%ebp),%eax
  801980:	8b 40 0c             	mov    0xc(%eax),%eax
  801983:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801988:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80198e:	ba 00 00 00 00       	mov    $0x0,%edx
  801993:	b8 03 00 00 00       	mov    $0x3,%eax
  801998:	e8 67 fe ff ff       	call   801804 <fsipc>
  80199d:	89 c3                	mov    %eax,%ebx
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	78 1f                	js     8019c2 <devfile_read+0x51>
	assert(r <= n);
  8019a3:	39 f0                	cmp    %esi,%eax
  8019a5:	77 24                	ja     8019cb <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8019a7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019ac:	7f 33                	jg     8019e1 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019ae:	83 ec 04             	sub    $0x4,%esp
  8019b1:	50                   	push   %eax
  8019b2:	68 00 50 80 00       	push   $0x805000
  8019b7:	ff 75 0c             	pushl  0xc(%ebp)
  8019ba:	e8 9d ef ff ff       	call   80095c <memmove>
	return r;
  8019bf:	83 c4 10             	add    $0x10,%esp
}
  8019c2:	89 d8                	mov    %ebx,%eax
  8019c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c7:	5b                   	pop    %ebx
  8019c8:	5e                   	pop    %esi
  8019c9:	5d                   	pop    %ebp
  8019ca:	c3                   	ret    
	assert(r <= n);
  8019cb:	68 ec 29 80 00       	push   $0x8029ec
  8019d0:	68 f3 29 80 00       	push   $0x8029f3
  8019d5:	6a 7c                	push   $0x7c
  8019d7:	68 08 2a 80 00       	push   $0x802a08
  8019dc:	e8 72 e7 ff ff       	call   800153 <_panic>
	assert(r <= PGSIZE);
  8019e1:	68 13 2a 80 00       	push   $0x802a13
  8019e6:	68 f3 29 80 00       	push   $0x8029f3
  8019eb:	6a 7d                	push   $0x7d
  8019ed:	68 08 2a 80 00       	push   $0x802a08
  8019f2:	e8 5c e7 ff ff       	call   800153 <_panic>

008019f7 <open>:
{
  8019f7:	f3 0f 1e fb          	endbr32 
  8019fb:	55                   	push   %ebp
  8019fc:	89 e5                	mov    %esp,%ebp
  8019fe:	56                   	push   %esi
  8019ff:	53                   	push   %ebx
  801a00:	83 ec 1c             	sub    $0x1c,%esp
  801a03:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801a06:	56                   	push   %esi
  801a07:	e8 55 ed ff ff       	call   800761 <strlen>
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a14:	7f 6c                	jg     801a82 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801a16:	83 ec 0c             	sub    $0xc,%esp
  801a19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1c:	50                   	push   %eax
  801a1d:	e8 42 f8 ff ff       	call   801264 <fd_alloc>
  801a22:	89 c3                	mov    %eax,%ebx
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	85 c0                	test   %eax,%eax
  801a29:	78 3c                	js     801a67 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801a2b:	83 ec 08             	sub    $0x8,%esp
  801a2e:	56                   	push   %esi
  801a2f:	68 00 50 80 00       	push   $0x805000
  801a34:	e8 6b ed ff ff       	call   8007a4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a39:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3c:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a41:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a44:	b8 01 00 00 00       	mov    $0x1,%eax
  801a49:	e8 b6 fd ff ff       	call   801804 <fsipc>
  801a4e:	89 c3                	mov    %eax,%ebx
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	85 c0                	test   %eax,%eax
  801a55:	78 19                	js     801a70 <open+0x79>
	return fd2num(fd);
  801a57:	83 ec 0c             	sub    $0xc,%esp
  801a5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5d:	e8 cf f7 ff ff       	call   801231 <fd2num>
  801a62:	89 c3                	mov    %eax,%ebx
  801a64:	83 c4 10             	add    $0x10,%esp
}
  801a67:	89 d8                	mov    %ebx,%eax
  801a69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6c:	5b                   	pop    %ebx
  801a6d:	5e                   	pop    %esi
  801a6e:	5d                   	pop    %ebp
  801a6f:	c3                   	ret    
		fd_close(fd, 0);
  801a70:	83 ec 08             	sub    $0x8,%esp
  801a73:	6a 00                	push   $0x0
  801a75:	ff 75 f4             	pushl  -0xc(%ebp)
  801a78:	e8 eb f8 ff ff       	call   801368 <fd_close>
		return r;
  801a7d:	83 c4 10             	add    $0x10,%esp
  801a80:	eb e5                	jmp    801a67 <open+0x70>
		return -E_BAD_PATH;
  801a82:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a87:	eb de                	jmp    801a67 <open+0x70>

00801a89 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a89:	f3 0f 1e fb          	endbr32 
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a93:	ba 00 00 00 00       	mov    $0x0,%edx
  801a98:	b8 08 00 00 00       	mov    $0x8,%eax
  801a9d:	e8 62 fd ff ff       	call   801804 <fsipc>
}
  801aa2:	c9                   	leave  
  801aa3:	c3                   	ret    

00801aa4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aa4:	f3 0f 1e fb          	endbr32 
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	56                   	push   %esi
  801aac:	53                   	push   %ebx
  801aad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ab0:	83 ec 0c             	sub    $0xc,%esp
  801ab3:	ff 75 08             	pushl  0x8(%ebp)
  801ab6:	e8 8a f7 ff ff       	call   801245 <fd2data>
  801abb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801abd:	83 c4 08             	add    $0x8,%esp
  801ac0:	68 1f 2a 80 00       	push   $0x802a1f
  801ac5:	53                   	push   %ebx
  801ac6:	e8 d9 ec ff ff       	call   8007a4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801acb:	8b 46 04             	mov    0x4(%esi),%eax
  801ace:	2b 06                	sub    (%esi),%eax
  801ad0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ad6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801add:	00 00 00 
	stat->st_dev = &devpipe;
  801ae0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ae7:	30 80 00 
	return 0;
}
  801aea:	b8 00 00 00 00       	mov    $0x0,%eax
  801aef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801af6:	f3 0f 1e fb          	endbr32 
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	53                   	push   %ebx
  801afe:	83 ec 0c             	sub    $0xc,%esp
  801b01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b04:	53                   	push   %ebx
  801b05:	6a 00                	push   $0x0
  801b07:	e8 72 f1 ff ff       	call   800c7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b0c:	89 1c 24             	mov    %ebx,(%esp)
  801b0f:	e8 31 f7 ff ff       	call   801245 <fd2data>
  801b14:	83 c4 08             	add    $0x8,%esp
  801b17:	50                   	push   %eax
  801b18:	6a 00                	push   $0x0
  801b1a:	e8 5f f1 ff ff       	call   800c7e <sys_page_unmap>
}
  801b1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b22:	c9                   	leave  
  801b23:	c3                   	ret    

00801b24 <_pipeisclosed>:
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	57                   	push   %edi
  801b28:	56                   	push   %esi
  801b29:	53                   	push   %ebx
  801b2a:	83 ec 1c             	sub    $0x1c,%esp
  801b2d:	89 c7                	mov    %eax,%edi
  801b2f:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b31:	a1 08 40 80 00       	mov    0x804008,%eax
  801b36:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b39:	83 ec 0c             	sub    $0xc,%esp
  801b3c:	57                   	push   %edi
  801b3d:	e8 f3 05 00 00       	call   802135 <pageref>
  801b42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b45:	89 34 24             	mov    %esi,(%esp)
  801b48:	e8 e8 05 00 00       	call   802135 <pageref>
		nn = thisenv->env_runs;
  801b4d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b53:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	39 cb                	cmp    %ecx,%ebx
  801b5b:	74 1b                	je     801b78 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b5d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b60:	75 cf                	jne    801b31 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b62:	8b 42 58             	mov    0x58(%edx),%eax
  801b65:	6a 01                	push   $0x1
  801b67:	50                   	push   %eax
  801b68:	53                   	push   %ebx
  801b69:	68 26 2a 80 00       	push   $0x802a26
  801b6e:	e8 c7 e6 ff ff       	call   80023a <cprintf>
  801b73:	83 c4 10             	add    $0x10,%esp
  801b76:	eb b9                	jmp    801b31 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b78:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b7b:	0f 94 c0             	sete   %al
  801b7e:	0f b6 c0             	movzbl %al,%eax
}
  801b81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b84:	5b                   	pop    %ebx
  801b85:	5e                   	pop    %esi
  801b86:	5f                   	pop    %edi
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <devpipe_write>:
{
  801b89:	f3 0f 1e fb          	endbr32 
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	57                   	push   %edi
  801b91:	56                   	push   %esi
  801b92:	53                   	push   %ebx
  801b93:	83 ec 28             	sub    $0x28,%esp
  801b96:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b99:	56                   	push   %esi
  801b9a:	e8 a6 f6 ff ff       	call   801245 <fd2data>
  801b9f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	bf 00 00 00 00       	mov    $0x0,%edi
  801ba9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bac:	74 4f                	je     801bfd <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bae:	8b 43 04             	mov    0x4(%ebx),%eax
  801bb1:	8b 0b                	mov    (%ebx),%ecx
  801bb3:	8d 51 20             	lea    0x20(%ecx),%edx
  801bb6:	39 d0                	cmp    %edx,%eax
  801bb8:	72 14                	jb     801bce <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801bba:	89 da                	mov    %ebx,%edx
  801bbc:	89 f0                	mov    %esi,%eax
  801bbe:	e8 61 ff ff ff       	call   801b24 <_pipeisclosed>
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	75 3b                	jne    801c02 <devpipe_write+0x79>
			sys_yield();
  801bc7:	e8 35 f0 ff ff       	call   800c01 <sys_yield>
  801bcc:	eb e0                	jmp    801bae <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bd5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bd8:	89 c2                	mov    %eax,%edx
  801bda:	c1 fa 1f             	sar    $0x1f,%edx
  801bdd:	89 d1                	mov    %edx,%ecx
  801bdf:	c1 e9 1b             	shr    $0x1b,%ecx
  801be2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801be5:	83 e2 1f             	and    $0x1f,%edx
  801be8:	29 ca                	sub    %ecx,%edx
  801bea:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bf2:	83 c0 01             	add    $0x1,%eax
  801bf5:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801bf8:	83 c7 01             	add    $0x1,%edi
  801bfb:	eb ac                	jmp    801ba9 <devpipe_write+0x20>
	return i;
  801bfd:	8b 45 10             	mov    0x10(%ebp),%eax
  801c00:	eb 05                	jmp    801c07 <devpipe_write+0x7e>
				return 0;
  801c02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0a:	5b                   	pop    %ebx
  801c0b:	5e                   	pop    %esi
  801c0c:	5f                   	pop    %edi
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <devpipe_read>:
{
  801c0f:	f3 0f 1e fb          	endbr32 
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	57                   	push   %edi
  801c17:	56                   	push   %esi
  801c18:	53                   	push   %ebx
  801c19:	83 ec 18             	sub    $0x18,%esp
  801c1c:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c1f:	57                   	push   %edi
  801c20:	e8 20 f6 ff ff       	call   801245 <fd2data>
  801c25:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	be 00 00 00 00       	mov    $0x0,%esi
  801c2f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c32:	75 14                	jne    801c48 <devpipe_read+0x39>
	return i;
  801c34:	8b 45 10             	mov    0x10(%ebp),%eax
  801c37:	eb 02                	jmp    801c3b <devpipe_read+0x2c>
				return i;
  801c39:	89 f0                	mov    %esi,%eax
}
  801c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3e:	5b                   	pop    %ebx
  801c3f:	5e                   	pop    %esi
  801c40:	5f                   	pop    %edi
  801c41:	5d                   	pop    %ebp
  801c42:	c3                   	ret    
			sys_yield();
  801c43:	e8 b9 ef ff ff       	call   800c01 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c48:	8b 03                	mov    (%ebx),%eax
  801c4a:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c4d:	75 18                	jne    801c67 <devpipe_read+0x58>
			if (i > 0)
  801c4f:	85 f6                	test   %esi,%esi
  801c51:	75 e6                	jne    801c39 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801c53:	89 da                	mov    %ebx,%edx
  801c55:	89 f8                	mov    %edi,%eax
  801c57:	e8 c8 fe ff ff       	call   801b24 <_pipeisclosed>
  801c5c:	85 c0                	test   %eax,%eax
  801c5e:	74 e3                	je     801c43 <devpipe_read+0x34>
				return 0;
  801c60:	b8 00 00 00 00       	mov    $0x0,%eax
  801c65:	eb d4                	jmp    801c3b <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c67:	99                   	cltd   
  801c68:	c1 ea 1b             	shr    $0x1b,%edx
  801c6b:	01 d0                	add    %edx,%eax
  801c6d:	83 e0 1f             	and    $0x1f,%eax
  801c70:	29 d0                	sub    %edx,%eax
  801c72:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c7a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c7d:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c80:	83 c6 01             	add    $0x1,%esi
  801c83:	eb aa                	jmp    801c2f <devpipe_read+0x20>

00801c85 <pipe>:
{
  801c85:	f3 0f 1e fb          	endbr32 
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	56                   	push   %esi
  801c8d:	53                   	push   %ebx
  801c8e:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c94:	50                   	push   %eax
  801c95:	e8 ca f5 ff ff       	call   801264 <fd_alloc>
  801c9a:	89 c3                	mov    %eax,%ebx
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	0f 88 23 01 00 00    	js     801dca <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca7:	83 ec 04             	sub    $0x4,%esp
  801caa:	68 07 04 00 00       	push   $0x407
  801caf:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb2:	6a 00                	push   $0x0
  801cb4:	e8 73 ef ff ff       	call   800c2c <sys_page_alloc>
  801cb9:	89 c3                	mov    %eax,%ebx
  801cbb:	83 c4 10             	add    $0x10,%esp
  801cbe:	85 c0                	test   %eax,%eax
  801cc0:	0f 88 04 01 00 00    	js     801dca <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801cc6:	83 ec 0c             	sub    $0xc,%esp
  801cc9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ccc:	50                   	push   %eax
  801ccd:	e8 92 f5 ff ff       	call   801264 <fd_alloc>
  801cd2:	89 c3                	mov    %eax,%ebx
  801cd4:	83 c4 10             	add    $0x10,%esp
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	0f 88 db 00 00 00    	js     801dba <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cdf:	83 ec 04             	sub    $0x4,%esp
  801ce2:	68 07 04 00 00       	push   $0x407
  801ce7:	ff 75 f0             	pushl  -0x10(%ebp)
  801cea:	6a 00                	push   $0x0
  801cec:	e8 3b ef ff ff       	call   800c2c <sys_page_alloc>
  801cf1:	89 c3                	mov    %eax,%ebx
  801cf3:	83 c4 10             	add    $0x10,%esp
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	0f 88 bc 00 00 00    	js     801dba <pipe+0x135>
	va = fd2data(fd0);
  801cfe:	83 ec 0c             	sub    $0xc,%esp
  801d01:	ff 75 f4             	pushl  -0xc(%ebp)
  801d04:	e8 3c f5 ff ff       	call   801245 <fd2data>
  801d09:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d0b:	83 c4 0c             	add    $0xc,%esp
  801d0e:	68 07 04 00 00       	push   $0x407
  801d13:	50                   	push   %eax
  801d14:	6a 00                	push   $0x0
  801d16:	e8 11 ef ff ff       	call   800c2c <sys_page_alloc>
  801d1b:	89 c3                	mov    %eax,%ebx
  801d1d:	83 c4 10             	add    $0x10,%esp
  801d20:	85 c0                	test   %eax,%eax
  801d22:	0f 88 82 00 00 00    	js     801daa <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d28:	83 ec 0c             	sub    $0xc,%esp
  801d2b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d2e:	e8 12 f5 ff ff       	call   801245 <fd2data>
  801d33:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d3a:	50                   	push   %eax
  801d3b:	6a 00                	push   $0x0
  801d3d:	56                   	push   %esi
  801d3e:	6a 00                	push   $0x0
  801d40:	e8 0f ef ff ff       	call   800c54 <sys_page_map>
  801d45:	89 c3                	mov    %eax,%ebx
  801d47:	83 c4 20             	add    $0x20,%esp
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	78 4e                	js     801d9c <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801d4e:	a1 20 30 80 00       	mov    0x803020,%eax
  801d53:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d56:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d58:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d5b:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d62:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d65:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d6a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d71:	83 ec 0c             	sub    $0xc,%esp
  801d74:	ff 75 f4             	pushl  -0xc(%ebp)
  801d77:	e8 b5 f4 ff ff       	call   801231 <fd2num>
  801d7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d81:	83 c4 04             	add    $0x4,%esp
  801d84:	ff 75 f0             	pushl  -0x10(%ebp)
  801d87:	e8 a5 f4 ff ff       	call   801231 <fd2num>
  801d8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d8f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d92:	83 c4 10             	add    $0x10,%esp
  801d95:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d9a:	eb 2e                	jmp    801dca <pipe+0x145>
	sys_page_unmap(0, va);
  801d9c:	83 ec 08             	sub    $0x8,%esp
  801d9f:	56                   	push   %esi
  801da0:	6a 00                	push   $0x0
  801da2:	e8 d7 ee ff ff       	call   800c7e <sys_page_unmap>
  801da7:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801daa:	83 ec 08             	sub    $0x8,%esp
  801dad:	ff 75 f0             	pushl  -0x10(%ebp)
  801db0:	6a 00                	push   $0x0
  801db2:	e8 c7 ee ff ff       	call   800c7e <sys_page_unmap>
  801db7:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801dba:	83 ec 08             	sub    $0x8,%esp
  801dbd:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc0:	6a 00                	push   $0x0
  801dc2:	e8 b7 ee ff ff       	call   800c7e <sys_page_unmap>
  801dc7:	83 c4 10             	add    $0x10,%esp
}
  801dca:	89 d8                	mov    %ebx,%eax
  801dcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dcf:	5b                   	pop    %ebx
  801dd0:	5e                   	pop    %esi
  801dd1:	5d                   	pop    %ebp
  801dd2:	c3                   	ret    

00801dd3 <pipeisclosed>:
{
  801dd3:	f3 0f 1e fb          	endbr32 
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ddd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de0:	50                   	push   %eax
  801de1:	ff 75 08             	pushl  0x8(%ebp)
  801de4:	e8 d1 f4 ff ff       	call   8012ba <fd_lookup>
  801de9:	83 c4 10             	add    $0x10,%esp
  801dec:	85 c0                	test   %eax,%eax
  801dee:	78 18                	js     801e08 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801df0:	83 ec 0c             	sub    $0xc,%esp
  801df3:	ff 75 f4             	pushl  -0xc(%ebp)
  801df6:	e8 4a f4 ff ff       	call   801245 <fd2data>
  801dfb:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e00:	e8 1f fd ff ff       	call   801b24 <_pipeisclosed>
  801e05:	83 c4 10             	add    $0x10,%esp
}
  801e08:	c9                   	leave  
  801e09:	c3                   	ret    

00801e0a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e0a:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801e0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e13:	c3                   	ret    

00801e14 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e14:	f3 0f 1e fb          	endbr32 
  801e18:	55                   	push   %ebp
  801e19:	89 e5                	mov    %esp,%ebp
  801e1b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e1e:	68 3e 2a 80 00       	push   $0x802a3e
  801e23:	ff 75 0c             	pushl  0xc(%ebp)
  801e26:	e8 79 e9 ff ff       	call   8007a4 <strcpy>
	return 0;
}
  801e2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e30:	c9                   	leave  
  801e31:	c3                   	ret    

00801e32 <devcons_write>:
{
  801e32:	f3 0f 1e fb          	endbr32 
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	57                   	push   %edi
  801e3a:	56                   	push   %esi
  801e3b:	53                   	push   %ebx
  801e3c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e42:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e47:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e4d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e50:	73 31                	jae    801e83 <devcons_write+0x51>
		m = n - tot;
  801e52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e55:	29 f3                	sub    %esi,%ebx
  801e57:	83 fb 7f             	cmp    $0x7f,%ebx
  801e5a:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e5f:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e62:	83 ec 04             	sub    $0x4,%esp
  801e65:	53                   	push   %ebx
  801e66:	89 f0                	mov    %esi,%eax
  801e68:	03 45 0c             	add    0xc(%ebp),%eax
  801e6b:	50                   	push   %eax
  801e6c:	57                   	push   %edi
  801e6d:	e8 ea ea ff ff       	call   80095c <memmove>
		sys_cputs(buf, m);
  801e72:	83 c4 08             	add    $0x8,%esp
  801e75:	53                   	push   %ebx
  801e76:	57                   	push   %edi
  801e77:	e8 e5 ec ff ff       	call   800b61 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e7c:	01 de                	add    %ebx,%esi
  801e7e:	83 c4 10             	add    $0x10,%esp
  801e81:	eb ca                	jmp    801e4d <devcons_write+0x1b>
}
  801e83:	89 f0                	mov    %esi,%eax
  801e85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e88:	5b                   	pop    %ebx
  801e89:	5e                   	pop    %esi
  801e8a:	5f                   	pop    %edi
  801e8b:	5d                   	pop    %ebp
  801e8c:	c3                   	ret    

00801e8d <devcons_read>:
{
  801e8d:	f3 0f 1e fb          	endbr32 
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	83 ec 08             	sub    $0x8,%esp
  801e97:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e9c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ea0:	74 21                	je     801ec3 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801ea2:	e8 e4 ec ff ff       	call   800b8b <sys_cgetc>
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	75 07                	jne    801eb2 <devcons_read+0x25>
		sys_yield();
  801eab:	e8 51 ed ff ff       	call   800c01 <sys_yield>
  801eb0:	eb f0                	jmp    801ea2 <devcons_read+0x15>
	if (c < 0)
  801eb2:	78 0f                	js     801ec3 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801eb4:	83 f8 04             	cmp    $0x4,%eax
  801eb7:	74 0c                	je     801ec5 <devcons_read+0x38>
	*(char*)vbuf = c;
  801eb9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ebc:	88 02                	mov    %al,(%edx)
	return 1;
  801ebe:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801ec3:	c9                   	leave  
  801ec4:	c3                   	ret    
		return 0;
  801ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eca:	eb f7                	jmp    801ec3 <devcons_read+0x36>

00801ecc <cputchar>:
{
  801ecc:	f3 0f 1e fb          	endbr32 
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed9:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801edc:	6a 01                	push   $0x1
  801ede:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ee1:	50                   	push   %eax
  801ee2:	e8 7a ec ff ff       	call   800b61 <sys_cputs>
}
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	c9                   	leave  
  801eeb:	c3                   	ret    

00801eec <getchar>:
{
  801eec:	f3 0f 1e fb          	endbr32 
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ef6:	6a 01                	push   $0x1
  801ef8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801efb:	50                   	push   %eax
  801efc:	6a 00                	push   $0x0
  801efe:	e8 3a f6 ff ff       	call   80153d <read>
	if (r < 0)
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	85 c0                	test   %eax,%eax
  801f08:	78 06                	js     801f10 <getchar+0x24>
	if (r < 1)
  801f0a:	74 06                	je     801f12 <getchar+0x26>
	return c;
  801f0c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f10:	c9                   	leave  
  801f11:	c3                   	ret    
		return -E_EOF;
  801f12:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f17:	eb f7                	jmp    801f10 <getchar+0x24>

00801f19 <iscons>:
{
  801f19:	f3 0f 1e fb          	endbr32 
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f26:	50                   	push   %eax
  801f27:	ff 75 08             	pushl  0x8(%ebp)
  801f2a:	e8 8b f3 ff ff       	call   8012ba <fd_lookup>
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	85 c0                	test   %eax,%eax
  801f34:	78 11                	js     801f47 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f39:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f3f:	39 10                	cmp    %edx,(%eax)
  801f41:	0f 94 c0             	sete   %al
  801f44:	0f b6 c0             	movzbl %al,%eax
}
  801f47:	c9                   	leave  
  801f48:	c3                   	ret    

00801f49 <opencons>:
{
  801f49:	f3 0f 1e fb          	endbr32 
  801f4d:	55                   	push   %ebp
  801f4e:	89 e5                	mov    %esp,%ebp
  801f50:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f56:	50                   	push   %eax
  801f57:	e8 08 f3 ff ff       	call   801264 <fd_alloc>
  801f5c:	83 c4 10             	add    $0x10,%esp
  801f5f:	85 c0                	test   %eax,%eax
  801f61:	78 3a                	js     801f9d <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f63:	83 ec 04             	sub    $0x4,%esp
  801f66:	68 07 04 00 00       	push   $0x407
  801f6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f6e:	6a 00                	push   $0x0
  801f70:	e8 b7 ec ff ff       	call   800c2c <sys_page_alloc>
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	78 21                	js     801f9d <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f85:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f91:	83 ec 0c             	sub    $0xc,%esp
  801f94:	50                   	push   %eax
  801f95:	e8 97 f2 ff ff       	call   801231 <fd2num>
  801f9a:	83 c4 10             	add    $0x10,%esp
}
  801f9d:	c9                   	leave  
  801f9e:	c3                   	ret    

00801f9f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f9f:	f3 0f 1e fb          	endbr32 
  801fa3:	55                   	push   %ebp
  801fa4:	89 e5                	mov    %esp,%ebp
  801fa6:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801fa9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fb0:	74 0a                	je     801fbc <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb5:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801fba:	c9                   	leave  
  801fbb:	c3                   	ret    
		if (sys_page_alloc(0,
  801fbc:	83 ec 04             	sub    $0x4,%esp
  801fbf:	6a 07                	push   $0x7
  801fc1:	68 00 f0 bf ee       	push   $0xeebff000
  801fc6:	6a 00                	push   $0x0
  801fc8:	e8 5f ec ff ff       	call   800c2c <sys_page_alloc>
  801fcd:	83 c4 10             	add    $0x10,%esp
  801fd0:	85 c0                	test   %eax,%eax
  801fd2:	78 2a                	js     801ffe <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801fd4:	83 ec 08             	sub    $0x8,%esp
  801fd7:	68 12 20 80 00       	push   $0x802012
  801fdc:	6a 00                	push   $0x0
  801fde:	e8 10 ed ff ff       	call   800cf3 <sys_env_set_pgfault_upcall>
  801fe3:	83 c4 10             	add    $0x10,%esp
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	79 c8                	jns    801fb2 <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  801fea:	83 ec 04             	sub    $0x4,%esp
  801fed:	68 80 2a 80 00       	push   $0x802a80
  801ff2:	6a 25                	push   $0x25
  801ff4:	68 c7 2a 80 00       	push   $0x802ac7
  801ff9:	e8 55 e1 ff ff       	call   800153 <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  801ffe:	83 ec 04             	sub    $0x4,%esp
  802001:	68 4c 2a 80 00       	push   $0x802a4c
  802006:	6a 21                	push   $0x21
  802008:	68 c7 2a 80 00       	push   $0x802ac7
  80200d:	e8 41 e1 ff ff       	call   800153 <_panic>

00802012 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802012:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802013:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802018:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80201a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  80201d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  802022:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  802026:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80202a:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  80202c:	83 c4 08             	add    $0x8,%esp
	popal
  80202f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  802030:	83 c4 04             	add    $0x4,%esp
	popfl
  802033:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  802034:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802037:	c3                   	ret    

00802038 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802038:	f3 0f 1e fb          	endbr32 
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	56                   	push   %esi
  802040:	53                   	push   %ebx
  802041:	8b 75 08             	mov    0x8(%ebp),%esi
  802044:	8b 45 0c             	mov    0xc(%ebp),%eax
  802047:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  80204a:	85 c0                	test   %eax,%eax
  80204c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802051:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  802054:	83 ec 0c             	sub    $0xc,%esp
  802057:	50                   	push   %eax
  802058:	e8 e6 ec ff ff       	call   800d43 <sys_ipc_recv>
	if (f < 0) {
  80205d:	83 c4 10             	add    $0x10,%esp
  802060:	85 c0                	test   %eax,%eax
  802062:	78 2b                	js     80208f <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  802064:	85 f6                	test   %esi,%esi
  802066:	74 0a                	je     802072 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  802068:	a1 08 40 80 00       	mov    0x804008,%eax
  80206d:	8b 40 74             	mov    0x74(%eax),%eax
  802070:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  802072:	85 db                	test   %ebx,%ebx
  802074:	74 0a                	je     802080 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  802076:	a1 08 40 80 00       	mov    0x804008,%eax
  80207b:	8b 40 78             	mov    0x78(%eax),%eax
  80207e:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  802080:	a1 08 40 80 00       	mov    0x804008,%eax
  802085:	8b 40 70             	mov    0x70(%eax),%eax
}
  802088:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80208b:	5b                   	pop    %ebx
  80208c:	5e                   	pop    %esi
  80208d:	5d                   	pop    %ebp
  80208e:	c3                   	ret    
		if (from_env_store != NULL) {
  80208f:	85 f6                	test   %esi,%esi
  802091:	74 06                	je     802099 <ipc_recv+0x61>
			*from_env_store = 0;
  802093:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  802099:	85 db                	test   %ebx,%ebx
  80209b:	74 eb                	je     802088 <ipc_recv+0x50>
			*perm_store = 0;
  80209d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020a3:	eb e3                	jmp    802088 <ipc_recv+0x50>

008020a5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020a5:	f3 0f 1e fb          	endbr32 
  8020a9:	55                   	push   %ebp
  8020aa:	89 e5                	mov    %esp,%ebp
  8020ac:	57                   	push   %edi
  8020ad:	56                   	push   %esi
  8020ae:	53                   	push   %ebx
  8020af:	83 ec 0c             	sub    $0xc,%esp
  8020b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  8020bb:	85 db                	test   %ebx,%ebx
  8020bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8020c2:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8020c5:	ff 75 14             	pushl  0x14(%ebp)
  8020c8:	53                   	push   %ebx
  8020c9:	56                   	push   %esi
  8020ca:	57                   	push   %edi
  8020cb:	e8 4a ec ff ff       	call   800d1a <sys_ipc_try_send>
  8020d0:	83 c4 10             	add    $0x10,%esp
  8020d3:	85 c0                	test   %eax,%eax
  8020d5:	79 19                	jns    8020f0 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  8020d7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020da:	74 e9                	je     8020c5 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  8020dc:	83 ec 04             	sub    $0x4,%esp
  8020df:	68 d8 2a 80 00       	push   $0x802ad8
  8020e4:	6a 48                	push   $0x48
  8020e6:	68 fa 2a 80 00       	push   $0x802afa
  8020eb:	e8 63 e0 ff ff       	call   800153 <_panic>
		}
	}
}
  8020f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    

008020f8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020f8:	f3 0f 1e fb          	endbr32 
  8020fc:	55                   	push   %ebp
  8020fd:	89 e5                	mov    %esp,%ebp
  8020ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802102:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802107:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80210a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802110:	8b 52 50             	mov    0x50(%edx),%edx
  802113:	39 ca                	cmp    %ecx,%edx
  802115:	74 11                	je     802128 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802117:	83 c0 01             	add    $0x1,%eax
  80211a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80211f:	75 e6                	jne    802107 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802121:	b8 00 00 00 00       	mov    $0x0,%eax
  802126:	eb 0b                	jmp    802133 <ipc_find_env+0x3b>
			return envs[i].env_id;
  802128:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80212b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802130:	8b 40 48             	mov    0x48(%eax),%eax
}
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    

00802135 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802135:	f3 0f 1e fb          	endbr32 
  802139:	55                   	push   %ebp
  80213a:	89 e5                	mov    %esp,%ebp
  80213c:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80213f:	89 c2                	mov    %eax,%edx
  802141:	c1 ea 16             	shr    $0x16,%edx
  802144:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80214b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802150:	f6 c1 01             	test   $0x1,%cl
  802153:	74 1c                	je     802171 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802155:	c1 e8 0c             	shr    $0xc,%eax
  802158:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80215f:	a8 01                	test   $0x1,%al
  802161:	74 0e                	je     802171 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802163:	c1 e8 0c             	shr    $0xc,%eax
  802166:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80216d:	ef 
  80216e:	0f b7 d2             	movzwl %dx,%edx
}
  802171:	89 d0                	mov    %edx,%eax
  802173:	5d                   	pop    %ebp
  802174:	c3                   	ret    
  802175:	66 90                	xchg   %ax,%ax
  802177:	66 90                	xchg   %ax,%ax
  802179:	66 90                	xchg   %ax,%ax
  80217b:	66 90                	xchg   %ax,%ax
  80217d:	66 90                	xchg   %ax,%ax
  80217f:	90                   	nop

00802180 <__udivdi3>:
  802180:	f3 0f 1e fb          	endbr32 
  802184:	55                   	push   %ebp
  802185:	57                   	push   %edi
  802186:	56                   	push   %esi
  802187:	53                   	push   %ebx
  802188:	83 ec 1c             	sub    $0x1c,%esp
  80218b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80218f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802193:	8b 74 24 34          	mov    0x34(%esp),%esi
  802197:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80219b:	85 d2                	test   %edx,%edx
  80219d:	75 19                	jne    8021b8 <__udivdi3+0x38>
  80219f:	39 f3                	cmp    %esi,%ebx
  8021a1:	76 4d                	jbe    8021f0 <__udivdi3+0x70>
  8021a3:	31 ff                	xor    %edi,%edi
  8021a5:	89 e8                	mov    %ebp,%eax
  8021a7:	89 f2                	mov    %esi,%edx
  8021a9:	f7 f3                	div    %ebx
  8021ab:	89 fa                	mov    %edi,%edx
  8021ad:	83 c4 1c             	add    $0x1c,%esp
  8021b0:	5b                   	pop    %ebx
  8021b1:	5e                   	pop    %esi
  8021b2:	5f                   	pop    %edi
  8021b3:	5d                   	pop    %ebp
  8021b4:	c3                   	ret    
  8021b5:	8d 76 00             	lea    0x0(%esi),%esi
  8021b8:	39 f2                	cmp    %esi,%edx
  8021ba:	76 14                	jbe    8021d0 <__udivdi3+0x50>
  8021bc:	31 ff                	xor    %edi,%edi
  8021be:	31 c0                	xor    %eax,%eax
  8021c0:	89 fa                	mov    %edi,%edx
  8021c2:	83 c4 1c             	add    $0x1c,%esp
  8021c5:	5b                   	pop    %ebx
  8021c6:	5e                   	pop    %esi
  8021c7:	5f                   	pop    %edi
  8021c8:	5d                   	pop    %ebp
  8021c9:	c3                   	ret    
  8021ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d0:	0f bd fa             	bsr    %edx,%edi
  8021d3:	83 f7 1f             	xor    $0x1f,%edi
  8021d6:	75 48                	jne    802220 <__udivdi3+0xa0>
  8021d8:	39 f2                	cmp    %esi,%edx
  8021da:	72 06                	jb     8021e2 <__udivdi3+0x62>
  8021dc:	31 c0                	xor    %eax,%eax
  8021de:	39 eb                	cmp    %ebp,%ebx
  8021e0:	77 de                	ja     8021c0 <__udivdi3+0x40>
  8021e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021e7:	eb d7                	jmp    8021c0 <__udivdi3+0x40>
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	89 d9                	mov    %ebx,%ecx
  8021f2:	85 db                	test   %ebx,%ebx
  8021f4:	75 0b                	jne    802201 <__udivdi3+0x81>
  8021f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fb:	31 d2                	xor    %edx,%edx
  8021fd:	f7 f3                	div    %ebx
  8021ff:	89 c1                	mov    %eax,%ecx
  802201:	31 d2                	xor    %edx,%edx
  802203:	89 f0                	mov    %esi,%eax
  802205:	f7 f1                	div    %ecx
  802207:	89 c6                	mov    %eax,%esi
  802209:	89 e8                	mov    %ebp,%eax
  80220b:	89 f7                	mov    %esi,%edi
  80220d:	f7 f1                	div    %ecx
  80220f:	89 fa                	mov    %edi,%edx
  802211:	83 c4 1c             	add    $0x1c,%esp
  802214:	5b                   	pop    %ebx
  802215:	5e                   	pop    %esi
  802216:	5f                   	pop    %edi
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	89 f9                	mov    %edi,%ecx
  802222:	b8 20 00 00 00       	mov    $0x20,%eax
  802227:	29 f8                	sub    %edi,%eax
  802229:	d3 e2                	shl    %cl,%edx
  80222b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80222f:	89 c1                	mov    %eax,%ecx
  802231:	89 da                	mov    %ebx,%edx
  802233:	d3 ea                	shr    %cl,%edx
  802235:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802239:	09 d1                	or     %edx,%ecx
  80223b:	89 f2                	mov    %esi,%edx
  80223d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802241:	89 f9                	mov    %edi,%ecx
  802243:	d3 e3                	shl    %cl,%ebx
  802245:	89 c1                	mov    %eax,%ecx
  802247:	d3 ea                	shr    %cl,%edx
  802249:	89 f9                	mov    %edi,%ecx
  80224b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80224f:	89 eb                	mov    %ebp,%ebx
  802251:	d3 e6                	shl    %cl,%esi
  802253:	89 c1                	mov    %eax,%ecx
  802255:	d3 eb                	shr    %cl,%ebx
  802257:	09 de                	or     %ebx,%esi
  802259:	89 f0                	mov    %esi,%eax
  80225b:	f7 74 24 08          	divl   0x8(%esp)
  80225f:	89 d6                	mov    %edx,%esi
  802261:	89 c3                	mov    %eax,%ebx
  802263:	f7 64 24 0c          	mull   0xc(%esp)
  802267:	39 d6                	cmp    %edx,%esi
  802269:	72 15                	jb     802280 <__udivdi3+0x100>
  80226b:	89 f9                	mov    %edi,%ecx
  80226d:	d3 e5                	shl    %cl,%ebp
  80226f:	39 c5                	cmp    %eax,%ebp
  802271:	73 04                	jae    802277 <__udivdi3+0xf7>
  802273:	39 d6                	cmp    %edx,%esi
  802275:	74 09                	je     802280 <__udivdi3+0x100>
  802277:	89 d8                	mov    %ebx,%eax
  802279:	31 ff                	xor    %edi,%edi
  80227b:	e9 40 ff ff ff       	jmp    8021c0 <__udivdi3+0x40>
  802280:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802283:	31 ff                	xor    %edi,%edi
  802285:	e9 36 ff ff ff       	jmp    8021c0 <__udivdi3+0x40>
  80228a:	66 90                	xchg   %ax,%ax
  80228c:	66 90                	xchg   %ax,%ax
  80228e:	66 90                	xchg   %ax,%ax

00802290 <__umoddi3>:
  802290:	f3 0f 1e fb          	endbr32 
  802294:	55                   	push   %ebp
  802295:	57                   	push   %edi
  802296:	56                   	push   %esi
  802297:	53                   	push   %ebx
  802298:	83 ec 1c             	sub    $0x1c,%esp
  80229b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80229f:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022a3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022a7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022ab:	85 c0                	test   %eax,%eax
  8022ad:	75 19                	jne    8022c8 <__umoddi3+0x38>
  8022af:	39 df                	cmp    %ebx,%edi
  8022b1:	76 5d                	jbe    802310 <__umoddi3+0x80>
  8022b3:	89 f0                	mov    %esi,%eax
  8022b5:	89 da                	mov    %ebx,%edx
  8022b7:	f7 f7                	div    %edi
  8022b9:	89 d0                	mov    %edx,%eax
  8022bb:	31 d2                	xor    %edx,%edx
  8022bd:	83 c4 1c             	add    $0x1c,%esp
  8022c0:	5b                   	pop    %ebx
  8022c1:	5e                   	pop    %esi
  8022c2:	5f                   	pop    %edi
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    
  8022c5:	8d 76 00             	lea    0x0(%esi),%esi
  8022c8:	89 f2                	mov    %esi,%edx
  8022ca:	39 d8                	cmp    %ebx,%eax
  8022cc:	76 12                	jbe    8022e0 <__umoddi3+0x50>
  8022ce:	89 f0                	mov    %esi,%eax
  8022d0:	89 da                	mov    %ebx,%edx
  8022d2:	83 c4 1c             	add    $0x1c,%esp
  8022d5:	5b                   	pop    %ebx
  8022d6:	5e                   	pop    %esi
  8022d7:	5f                   	pop    %edi
  8022d8:	5d                   	pop    %ebp
  8022d9:	c3                   	ret    
  8022da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e0:	0f bd e8             	bsr    %eax,%ebp
  8022e3:	83 f5 1f             	xor    $0x1f,%ebp
  8022e6:	75 50                	jne    802338 <__umoddi3+0xa8>
  8022e8:	39 d8                	cmp    %ebx,%eax
  8022ea:	0f 82 e0 00 00 00    	jb     8023d0 <__umoddi3+0x140>
  8022f0:	89 d9                	mov    %ebx,%ecx
  8022f2:	39 f7                	cmp    %esi,%edi
  8022f4:	0f 86 d6 00 00 00    	jbe    8023d0 <__umoddi3+0x140>
  8022fa:	89 d0                	mov    %edx,%eax
  8022fc:	89 ca                	mov    %ecx,%edx
  8022fe:	83 c4 1c             	add    $0x1c,%esp
  802301:	5b                   	pop    %ebx
  802302:	5e                   	pop    %esi
  802303:	5f                   	pop    %edi
  802304:	5d                   	pop    %ebp
  802305:	c3                   	ret    
  802306:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80230d:	8d 76 00             	lea    0x0(%esi),%esi
  802310:	89 fd                	mov    %edi,%ebp
  802312:	85 ff                	test   %edi,%edi
  802314:	75 0b                	jne    802321 <__umoddi3+0x91>
  802316:	b8 01 00 00 00       	mov    $0x1,%eax
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	f7 f7                	div    %edi
  80231f:	89 c5                	mov    %eax,%ebp
  802321:	89 d8                	mov    %ebx,%eax
  802323:	31 d2                	xor    %edx,%edx
  802325:	f7 f5                	div    %ebp
  802327:	89 f0                	mov    %esi,%eax
  802329:	f7 f5                	div    %ebp
  80232b:	89 d0                	mov    %edx,%eax
  80232d:	31 d2                	xor    %edx,%edx
  80232f:	eb 8c                	jmp    8022bd <__umoddi3+0x2d>
  802331:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802338:	89 e9                	mov    %ebp,%ecx
  80233a:	ba 20 00 00 00       	mov    $0x20,%edx
  80233f:	29 ea                	sub    %ebp,%edx
  802341:	d3 e0                	shl    %cl,%eax
  802343:	89 44 24 08          	mov    %eax,0x8(%esp)
  802347:	89 d1                	mov    %edx,%ecx
  802349:	89 f8                	mov    %edi,%eax
  80234b:	d3 e8                	shr    %cl,%eax
  80234d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802351:	89 54 24 04          	mov    %edx,0x4(%esp)
  802355:	8b 54 24 04          	mov    0x4(%esp),%edx
  802359:	09 c1                	or     %eax,%ecx
  80235b:	89 d8                	mov    %ebx,%eax
  80235d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802361:	89 e9                	mov    %ebp,%ecx
  802363:	d3 e7                	shl    %cl,%edi
  802365:	89 d1                	mov    %edx,%ecx
  802367:	d3 e8                	shr    %cl,%eax
  802369:	89 e9                	mov    %ebp,%ecx
  80236b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80236f:	d3 e3                	shl    %cl,%ebx
  802371:	89 c7                	mov    %eax,%edi
  802373:	89 d1                	mov    %edx,%ecx
  802375:	89 f0                	mov    %esi,%eax
  802377:	d3 e8                	shr    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	89 fa                	mov    %edi,%edx
  80237d:	d3 e6                	shl    %cl,%esi
  80237f:	09 d8                	or     %ebx,%eax
  802381:	f7 74 24 08          	divl   0x8(%esp)
  802385:	89 d1                	mov    %edx,%ecx
  802387:	89 f3                	mov    %esi,%ebx
  802389:	f7 64 24 0c          	mull   0xc(%esp)
  80238d:	89 c6                	mov    %eax,%esi
  80238f:	89 d7                	mov    %edx,%edi
  802391:	39 d1                	cmp    %edx,%ecx
  802393:	72 06                	jb     80239b <__umoddi3+0x10b>
  802395:	75 10                	jne    8023a7 <__umoddi3+0x117>
  802397:	39 c3                	cmp    %eax,%ebx
  802399:	73 0c                	jae    8023a7 <__umoddi3+0x117>
  80239b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80239f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8023a3:	89 d7                	mov    %edx,%edi
  8023a5:	89 c6                	mov    %eax,%esi
  8023a7:	89 ca                	mov    %ecx,%edx
  8023a9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023ae:	29 f3                	sub    %esi,%ebx
  8023b0:	19 fa                	sbb    %edi,%edx
  8023b2:	89 d0                	mov    %edx,%eax
  8023b4:	d3 e0                	shl    %cl,%eax
  8023b6:	89 e9                	mov    %ebp,%ecx
  8023b8:	d3 eb                	shr    %cl,%ebx
  8023ba:	d3 ea                	shr    %cl,%edx
  8023bc:	09 d8                	or     %ebx,%eax
  8023be:	83 c4 1c             	add    $0x1c,%esp
  8023c1:	5b                   	pop    %ebx
  8023c2:	5e                   	pop    %esi
  8023c3:	5f                   	pop    %edi
  8023c4:	5d                   	pop    %ebp
  8023c5:	c3                   	ret    
  8023c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023cd:	8d 76 00             	lea    0x0(%esi),%esi
  8023d0:	29 fe                	sub    %edi,%esi
  8023d2:	19 c3                	sbb    %eax,%ebx
  8023d4:	89 f2                	mov    %esi,%edx
  8023d6:	89 d9                	mov    %ebx,%ecx
  8023d8:	e9 1d ff ff ff       	jmp    8022fa <__umoddi3+0x6a>
