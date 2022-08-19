
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 88 00 00 00       	call   8000b9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	53                   	push   %ebx
  80003b:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003e:	68 c0 23 80 00       	push   $0x8023c0
  800043:	e8 7a 01 00 00       	call   8001c2 <cprintf>
	if ((env = fork()) == 0) {
  800048:	e8 18 10 00 00       	call   801065 <fork>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	85 c0                	test   %eax,%eax
  800052:	75 12                	jne    800066 <umain+0x33>
		cprintf("I am the child.  Spinning...\n");
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	68 38 24 80 00       	push   $0x802438
  80005c:	e8 61 01 00 00       	call   8001c2 <cprintf>
  800061:	83 c4 10             	add    $0x10,%esp
  800064:	eb fe                	jmp    800064 <umain+0x31>
  800066:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800068:	83 ec 0c             	sub    $0xc,%esp
  80006b:	68 e8 23 80 00       	push   $0x8023e8
  800070:	e8 4d 01 00 00       	call   8001c2 <cprintf>
	sys_yield();
  800075:	e8 0f 0b 00 00       	call   800b89 <sys_yield>
	sys_yield();
  80007a:	e8 0a 0b 00 00       	call   800b89 <sys_yield>
	sys_yield();
  80007f:	e8 05 0b 00 00       	call   800b89 <sys_yield>
	sys_yield();
  800084:	e8 00 0b 00 00       	call   800b89 <sys_yield>
	sys_yield();
  800089:	e8 fb 0a 00 00       	call   800b89 <sys_yield>
	sys_yield();
  80008e:	e8 f6 0a 00 00       	call   800b89 <sys_yield>
	sys_yield();
  800093:	e8 f1 0a 00 00       	call   800b89 <sys_yield>
	sys_yield();
  800098:	e8 ec 0a 00 00       	call   800b89 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  80009d:	c7 04 24 10 24 80 00 	movl   $0x802410,(%esp)
  8000a4:	e8 19 01 00 00       	call   8001c2 <cprintf>
	sys_env_destroy(env);
  8000a9:	89 1c 24             	mov    %ebx,(%esp)
  8000ac:	e8 8a 0a 00 00       	call   800b3b <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    

008000b9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b9:	f3 0f 1e fb          	endbr32 
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
  8000c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000c8:	e8 94 0a 00 00       	call   800b61 <sys_getenvid>
	if (id >= 0)
  8000cd:	85 c0                	test   %eax,%eax
  8000cf:	78 12                	js     8000e3 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8000d1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000de:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e3:	85 db                	test   %ebx,%ebx
  8000e5:	7e 07                	jle    8000ee <libmain+0x35>
		binaryname = argv[0];
  8000e7:	8b 06                	mov    (%esi),%eax
  8000e9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ee:	83 ec 08             	sub    $0x8,%esp
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	e8 3b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f8:	e8 0a 00 00 00       	call   800107 <exit>
}
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800107:	f3 0f 1e fb          	endbr32 
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800111:	e8 96 12 00 00       	call   8013ac <close_all>
	sys_env_destroy(0);
  800116:	83 ec 0c             	sub    $0xc,%esp
  800119:	6a 00                	push   $0x0
  80011b:	e8 1b 0a 00 00       	call   800b3b <sys_env_destroy>
}
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	c9                   	leave  
  800124:	c3                   	ret    

00800125 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800125:	f3 0f 1e fb          	endbr32 
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	53                   	push   %ebx
  80012d:	83 ec 04             	sub    $0x4,%esp
  800130:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800133:	8b 13                	mov    (%ebx),%edx
  800135:	8d 42 01             	lea    0x1(%edx),%eax
  800138:	89 03                	mov    %eax,(%ebx)
  80013a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800141:	3d ff 00 00 00       	cmp    $0xff,%eax
  800146:	74 09                	je     800151 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800148:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80014c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014f:	c9                   	leave  
  800150:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800151:	83 ec 08             	sub    $0x8,%esp
  800154:	68 ff 00 00 00       	push   $0xff
  800159:	8d 43 08             	lea    0x8(%ebx),%eax
  80015c:	50                   	push   %eax
  80015d:	e8 87 09 00 00       	call   800ae9 <sys_cputs>
		b->idx = 0;
  800162:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	eb db                	jmp    800148 <putch+0x23>

0080016d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016d:	f3 0f 1e fb          	endbr32 
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80017a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800181:	00 00 00 
	b.cnt = 0;
  800184:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80018b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80018e:	ff 75 0c             	pushl  0xc(%ebp)
  800191:	ff 75 08             	pushl  0x8(%ebp)
  800194:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019a:	50                   	push   %eax
  80019b:	68 25 01 80 00       	push   $0x800125
  8001a0:	e8 80 01 00 00       	call   800325 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a5:	83 c4 08             	add    $0x8,%esp
  8001a8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ae:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b4:	50                   	push   %eax
  8001b5:	e8 2f 09 00 00       	call   800ae9 <sys_cputs>

	return b.cnt;
}
  8001ba:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    

008001c2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c2:	f3 0f 1e fb          	endbr32 
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001cc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001cf:	50                   	push   %eax
  8001d0:	ff 75 08             	pushl  0x8(%ebp)
  8001d3:	e8 95 ff ff ff       	call   80016d <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d8:	c9                   	leave  
  8001d9:	c3                   	ret    

008001da <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 1c             	sub    $0x1c,%esp
  8001e3:	89 c7                	mov    %eax,%edi
  8001e5:	89 d6                	mov    %edx,%esi
  8001e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ed:	89 d1                	mov    %edx,%ecx
  8001ef:	89 c2                	mov    %eax,%edx
  8001f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8001fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800200:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800207:	39 c2                	cmp    %eax,%edx
  800209:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80020c:	72 3e                	jb     80024c <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	ff 75 18             	pushl  0x18(%ebp)
  800214:	83 eb 01             	sub    $0x1,%ebx
  800217:	53                   	push   %ebx
  800218:	50                   	push   %eax
  800219:	83 ec 08             	sub    $0x8,%esp
  80021c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80021f:	ff 75 e0             	pushl  -0x20(%ebp)
  800222:	ff 75 dc             	pushl  -0x24(%ebp)
  800225:	ff 75 d8             	pushl  -0x28(%ebp)
  800228:	e8 23 1f 00 00       	call   802150 <__udivdi3>
  80022d:	83 c4 18             	add    $0x18,%esp
  800230:	52                   	push   %edx
  800231:	50                   	push   %eax
  800232:	89 f2                	mov    %esi,%edx
  800234:	89 f8                	mov    %edi,%eax
  800236:	e8 9f ff ff ff       	call   8001da <printnum>
  80023b:	83 c4 20             	add    $0x20,%esp
  80023e:	eb 13                	jmp    800253 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800240:	83 ec 08             	sub    $0x8,%esp
  800243:	56                   	push   %esi
  800244:	ff 75 18             	pushl  0x18(%ebp)
  800247:	ff d7                	call   *%edi
  800249:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80024c:	83 eb 01             	sub    $0x1,%ebx
  80024f:	85 db                	test   %ebx,%ebx
  800251:	7f ed                	jg     800240 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800253:	83 ec 08             	sub    $0x8,%esp
  800256:	56                   	push   %esi
  800257:	83 ec 04             	sub    $0x4,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 f5 1f 00 00       	call   802260 <__umoddi3>
  80026b:	83 c4 14             	add    $0x14,%esp
  80026e:	0f be 80 60 24 80 00 	movsbl 0x802460(%eax),%eax
  800275:	50                   	push   %eax
  800276:	ff d7                	call   *%edi
}
  800278:	83 c4 10             	add    $0x10,%esp
  80027b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5e                   	pop    %esi
  800280:	5f                   	pop    %edi
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    

00800283 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800283:	83 fa 01             	cmp    $0x1,%edx
  800286:	7f 13                	jg     80029b <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800288:	85 d2                	test   %edx,%edx
  80028a:	74 1c                	je     8002a8 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80028c:	8b 10                	mov    (%eax),%edx
  80028e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800291:	89 08                	mov    %ecx,(%eax)
  800293:	8b 02                	mov    (%edx),%eax
  800295:	ba 00 00 00 00       	mov    $0x0,%edx
  80029a:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80029b:	8b 10                	mov    (%eax),%edx
  80029d:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a0:	89 08                	mov    %ecx,(%eax)
  8002a2:	8b 02                	mov    (%edx),%eax
  8002a4:	8b 52 04             	mov    0x4(%edx),%edx
  8002a7:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8002a8:	8b 10                	mov    (%eax),%edx
  8002aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ad:	89 08                	mov    %ecx,(%eax)
  8002af:	8b 02                	mov    (%edx),%eax
  8002b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b6:	c3                   	ret    

008002b7 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002b7:	83 fa 01             	cmp    $0x1,%edx
  8002ba:	7f 0f                	jg     8002cb <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8002bc:	85 d2                	test   %edx,%edx
  8002be:	74 18                	je     8002d8 <getint+0x21>
		return va_arg(*ap, long);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	99                   	cltd   
  8002ca:	c3                   	ret    
		return va_arg(*ap, long long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	8b 52 04             	mov    0x4(%edx),%edx
  8002d7:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	99                   	cltd   
}
  8002e2:	c3                   	ret    

008002e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e3:	f3 0f 1e fb          	endbr32 
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ed:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f6:	73 0a                	jae    800302 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002f8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fb:	89 08                	mov    %ecx,(%eax)
  8002fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800300:	88 02                	mov    %al,(%edx)
}
  800302:	5d                   	pop    %ebp
  800303:	c3                   	ret    

00800304 <printfmt>:
{
  800304:	f3 0f 1e fb          	endbr32 
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80030e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800311:	50                   	push   %eax
  800312:	ff 75 10             	pushl  0x10(%ebp)
  800315:	ff 75 0c             	pushl  0xc(%ebp)
  800318:	ff 75 08             	pushl  0x8(%ebp)
  80031b:	e8 05 00 00 00       	call   800325 <vprintfmt>
}
  800320:	83 c4 10             	add    $0x10,%esp
  800323:	c9                   	leave  
  800324:	c3                   	ret    

00800325 <vprintfmt>:
{
  800325:	f3 0f 1e fb          	endbr32 
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	57                   	push   %edi
  80032d:	56                   	push   %esi
  80032e:	53                   	push   %ebx
  80032f:	83 ec 2c             	sub    $0x2c,%esp
  800332:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800335:	8b 75 0c             	mov    0xc(%ebp),%esi
  800338:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033b:	e9 86 02 00 00       	jmp    8005c6 <vprintfmt+0x2a1>
		padc = ' ';
  800340:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800344:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80034b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800352:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800359:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8d 47 01             	lea    0x1(%edi),%eax
  800361:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800364:	0f b6 17             	movzbl (%edi),%edx
  800367:	8d 42 dd             	lea    -0x23(%edx),%eax
  80036a:	3c 55                	cmp    $0x55,%al
  80036c:	0f 87 df 02 00 00    	ja     800651 <vprintfmt+0x32c>
  800372:	0f b6 c0             	movzbl %al,%eax
  800375:	3e ff 24 85 a0 25 80 	notrack jmp *0x8025a0(,%eax,4)
  80037c:	00 
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800380:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800384:	eb d8                	jmp    80035e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800389:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80038d:	eb cf                	jmp    80035e <vprintfmt+0x39>
  80038f:	0f b6 d2             	movzbl %dl,%edx
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800395:	b8 00 00 00 00       	mov    $0x0,%eax
  80039a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80039d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003a4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003aa:	83 f9 09             	cmp    $0x9,%ecx
  8003ad:	77 52                	ja     800401 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8003af:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003b2:	eb e9                	jmp    80039d <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bd:	8b 00                	mov    (%eax),%eax
  8003bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c9:	79 93                	jns    80035e <vprintfmt+0x39>
				width = precision, precision = -1;
  8003cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003d8:	eb 84                	jmp    80035e <vprintfmt+0x39>
  8003da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003dd:	85 c0                	test   %eax,%eax
  8003df:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e4:	0f 49 d0             	cmovns %eax,%edx
  8003e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ed:	e9 6c ff ff ff       	jmp    80035e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003f5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003fc:	e9 5d ff ff ff       	jmp    80035e <vprintfmt+0x39>
  800401:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800404:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800407:	eb bc                	jmp    8003c5 <vprintfmt+0xa0>
			lflag++;
  800409:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80040f:	e9 4a ff ff ff       	jmp    80035e <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	56                   	push   %esi
  800421:	ff 30                	pushl  (%eax)
  800423:	ff d3                	call   *%ebx
			break;
  800425:	83 c4 10             	add    $0x10,%esp
  800428:	e9 96 01 00 00       	jmp    8005c3 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 50 04             	lea    0x4(%eax),%edx
  800433:	89 55 14             	mov    %edx,0x14(%ebp)
  800436:	8b 00                	mov    (%eax),%eax
  800438:	99                   	cltd   
  800439:	31 d0                	xor    %edx,%eax
  80043b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043d:	83 f8 0f             	cmp    $0xf,%eax
  800440:	7f 20                	jg     800462 <vprintfmt+0x13d>
  800442:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  800449:	85 d2                	test   %edx,%edx
  80044b:	74 15                	je     800462 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  80044d:	52                   	push   %edx
  80044e:	68 05 2a 80 00       	push   $0x802a05
  800453:	56                   	push   %esi
  800454:	53                   	push   %ebx
  800455:	e8 aa fe ff ff       	call   800304 <printfmt>
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	e9 61 01 00 00       	jmp    8005c3 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800462:	50                   	push   %eax
  800463:	68 78 24 80 00       	push   $0x802478
  800468:	56                   	push   %esi
  800469:	53                   	push   %ebx
  80046a:	e8 95 fe ff ff       	call   800304 <printfmt>
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	e9 4c 01 00 00       	jmp    8005c3 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800477:	8b 45 14             	mov    0x14(%ebp),%eax
  80047a:	8d 50 04             	lea    0x4(%eax),%edx
  80047d:	89 55 14             	mov    %edx,0x14(%ebp)
  800480:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800482:	85 c9                	test   %ecx,%ecx
  800484:	b8 71 24 80 00       	mov    $0x802471,%eax
  800489:	0f 45 c1             	cmovne %ecx,%eax
  80048c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80048f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800493:	7e 06                	jle    80049b <vprintfmt+0x176>
  800495:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800499:	75 0d                	jne    8004a8 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80049e:	89 c7                	mov    %eax,%edi
  8004a0:	03 45 e0             	add    -0x20(%ebp),%eax
  8004a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a6:	eb 57                	jmp    8004ff <vprintfmt+0x1da>
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ae:	ff 75 cc             	pushl  -0x34(%ebp)
  8004b1:	e8 4f 02 00 00       	call   800705 <strnlen>
  8004b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004b9:	29 c2                	sub    %eax,%edx
  8004bb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004be:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c1:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8004c5:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8004c8:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	85 db                	test   %ebx,%ebx
  8004cc:	7e 10                	jle    8004de <vprintfmt+0x1b9>
					putch(padc, putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	56                   	push   %esi
  8004d2:	57                   	push   %edi
  8004d3:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d6:	83 eb 01             	sub    $0x1,%ebx
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	eb ec                	jmp    8004ca <vprintfmt+0x1a5>
  8004de:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004e4:	85 d2                	test   %edx,%edx
  8004e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004eb:	0f 49 c2             	cmovns %edx,%eax
  8004ee:	29 c2                	sub    %eax,%edx
  8004f0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004f3:	eb a6                	jmp    80049b <vprintfmt+0x176>
					putch(ch, putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	56                   	push   %esi
  8004f9:	52                   	push   %edx
  8004fa:	ff d3                	call   *%ebx
  8004fc:	83 c4 10             	add    $0x10,%esp
  8004ff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800502:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800504:	83 c7 01             	add    $0x1,%edi
  800507:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80050b:	0f be d0             	movsbl %al,%edx
  80050e:	85 d2                	test   %edx,%edx
  800510:	74 42                	je     800554 <vprintfmt+0x22f>
  800512:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800516:	78 06                	js     80051e <vprintfmt+0x1f9>
  800518:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80051c:	78 1e                	js     80053c <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  80051e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800522:	74 d1                	je     8004f5 <vprintfmt+0x1d0>
  800524:	0f be c0             	movsbl %al,%eax
  800527:	83 e8 20             	sub    $0x20,%eax
  80052a:	83 f8 5e             	cmp    $0x5e,%eax
  80052d:	76 c6                	jbe    8004f5 <vprintfmt+0x1d0>
					putch('?', putdat);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	56                   	push   %esi
  800533:	6a 3f                	push   $0x3f
  800535:	ff d3                	call   *%ebx
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	eb c3                	jmp    8004ff <vprintfmt+0x1da>
  80053c:	89 cf                	mov    %ecx,%edi
  80053e:	eb 0e                	jmp    80054e <vprintfmt+0x229>
				putch(' ', putdat);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	56                   	push   %esi
  800544:	6a 20                	push   $0x20
  800546:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800548:	83 ef 01             	sub    $0x1,%edi
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	85 ff                	test   %edi,%edi
  800550:	7f ee                	jg     800540 <vprintfmt+0x21b>
  800552:	eb 6f                	jmp    8005c3 <vprintfmt+0x29e>
  800554:	89 cf                	mov    %ecx,%edi
  800556:	eb f6                	jmp    80054e <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800558:	89 ca                	mov    %ecx,%edx
  80055a:	8d 45 14             	lea    0x14(%ebp),%eax
  80055d:	e8 55 fd ff ff       	call   8002b7 <getint>
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800568:	85 d2                	test   %edx,%edx
  80056a:	78 0b                	js     800577 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  80056c:	89 d1                	mov    %edx,%ecx
  80056e:	89 c2                	mov    %eax,%edx
			base = 10;
  800570:	b8 0a 00 00 00       	mov    $0xa,%eax
  800575:	eb 32                	jmp    8005a9 <vprintfmt+0x284>
				putch('-', putdat);
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	56                   	push   %esi
  80057b:	6a 2d                	push   $0x2d
  80057d:	ff d3                	call   *%ebx
				num = -(long long) num;
  80057f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800582:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800585:	f7 da                	neg    %edx
  800587:	83 d1 00             	adc    $0x0,%ecx
  80058a:	f7 d9                	neg    %ecx
  80058c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80058f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800594:	eb 13                	jmp    8005a9 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800596:	89 ca                	mov    %ecx,%edx
  800598:	8d 45 14             	lea    0x14(%ebp),%eax
  80059b:	e8 e3 fc ff ff       	call   800283 <getuint>
  8005a0:	89 d1                	mov    %edx,%ecx
  8005a2:	89 c2                	mov    %eax,%edx
			base = 10;
  8005a4:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005a9:	83 ec 0c             	sub    $0xc,%esp
  8005ac:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005b0:	57                   	push   %edi
  8005b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b4:	50                   	push   %eax
  8005b5:	51                   	push   %ecx
  8005b6:	52                   	push   %edx
  8005b7:	89 f2                	mov    %esi,%edx
  8005b9:	89 d8                	mov    %ebx,%eax
  8005bb:	e8 1a fc ff ff       	call   8001da <printnum>
			break;
  8005c0:	83 c4 20             	add    $0x20,%esp
{
  8005c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005c6:	83 c7 01             	add    $0x1,%edi
  8005c9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005cd:	83 f8 25             	cmp    $0x25,%eax
  8005d0:	0f 84 6a fd ff ff    	je     800340 <vprintfmt+0x1b>
			if (ch == '\0')
  8005d6:	85 c0                	test   %eax,%eax
  8005d8:	0f 84 93 00 00 00    	je     800671 <vprintfmt+0x34c>
			putch(ch, putdat);
  8005de:	83 ec 08             	sub    $0x8,%esp
  8005e1:	56                   	push   %esi
  8005e2:	50                   	push   %eax
  8005e3:	ff d3                	call   *%ebx
  8005e5:	83 c4 10             	add    $0x10,%esp
  8005e8:	eb dc                	jmp    8005c6 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8005ea:	89 ca                	mov    %ecx,%edx
  8005ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ef:	e8 8f fc ff ff       	call   800283 <getuint>
  8005f4:	89 d1                	mov    %edx,%ecx
  8005f6:	89 c2                	mov    %eax,%edx
			base = 8;
  8005f8:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005fd:	eb aa                	jmp    8005a9 <vprintfmt+0x284>
			putch('0', putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	56                   	push   %esi
  800603:	6a 30                	push   $0x30
  800605:	ff d3                	call   *%ebx
			putch('x', putdat);
  800607:	83 c4 08             	add    $0x8,%esp
  80060a:	56                   	push   %esi
  80060b:	6a 78                	push   $0x78
  80060d:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8d 50 04             	lea    0x4(%eax),%edx
  800615:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80061f:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800622:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800627:	eb 80                	jmp    8005a9 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800629:	89 ca                	mov    %ecx,%edx
  80062b:	8d 45 14             	lea    0x14(%ebp),%eax
  80062e:	e8 50 fc ff ff       	call   800283 <getuint>
  800633:	89 d1                	mov    %edx,%ecx
  800635:	89 c2                	mov    %eax,%edx
			base = 16;
  800637:	b8 10 00 00 00       	mov    $0x10,%eax
  80063c:	e9 68 ff ff ff       	jmp    8005a9 <vprintfmt+0x284>
			putch(ch, putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	56                   	push   %esi
  800645:	6a 25                	push   $0x25
  800647:	ff d3                	call   *%ebx
			break;
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	e9 72 ff ff ff       	jmp    8005c3 <vprintfmt+0x29e>
			putch('%', putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	56                   	push   %esi
  800655:	6a 25                	push   $0x25
  800657:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	89 f8                	mov    %edi,%eax
  80065e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800662:	74 05                	je     800669 <vprintfmt+0x344>
  800664:	83 e8 01             	sub    $0x1,%eax
  800667:	eb f5                	jmp    80065e <vprintfmt+0x339>
  800669:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80066c:	e9 52 ff ff ff       	jmp    8005c3 <vprintfmt+0x29e>
}
  800671:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800674:	5b                   	pop    %ebx
  800675:	5e                   	pop    %esi
  800676:	5f                   	pop    %edi
  800677:	5d                   	pop    %ebp
  800678:	c3                   	ret    

00800679 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800679:	f3 0f 1e fb          	endbr32 
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	83 ec 18             	sub    $0x18,%esp
  800683:	8b 45 08             	mov    0x8(%ebp),%eax
  800686:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800689:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80068c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800690:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800693:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069a:	85 c0                	test   %eax,%eax
  80069c:	74 26                	je     8006c4 <vsnprintf+0x4b>
  80069e:	85 d2                	test   %edx,%edx
  8006a0:	7e 22                	jle    8006c4 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a2:	ff 75 14             	pushl  0x14(%ebp)
  8006a5:	ff 75 10             	pushl  0x10(%ebp)
  8006a8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ab:	50                   	push   %eax
  8006ac:	68 e3 02 80 00       	push   $0x8002e3
  8006b1:	e8 6f fc ff ff       	call   800325 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bf:	83 c4 10             	add    $0x10,%esp
}
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    
		return -E_INVAL;
  8006c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c9:	eb f7                	jmp    8006c2 <vsnprintf+0x49>

008006cb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006cb:	f3 0f 1e fb          	endbr32 
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d8:	50                   	push   %eax
  8006d9:	ff 75 10             	pushl  0x10(%ebp)
  8006dc:	ff 75 0c             	pushl  0xc(%ebp)
  8006df:	ff 75 08             	pushl  0x8(%ebp)
  8006e2:	e8 92 ff ff ff       	call   800679 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e7:	c9                   	leave  
  8006e8:	c3                   	ret    

008006e9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e9:	f3 0f 1e fb          	endbr32 
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006fc:	74 05                	je     800703 <strlen+0x1a>
		n++;
  8006fe:	83 c0 01             	add    $0x1,%eax
  800701:	eb f5                	jmp    8006f8 <strlen+0xf>
	return n;
}
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800705:	f3 0f 1e fb          	endbr32 
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80070f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
  800717:	39 d0                	cmp    %edx,%eax
  800719:	74 0d                	je     800728 <strnlen+0x23>
  80071b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80071f:	74 05                	je     800726 <strnlen+0x21>
		n++;
  800721:	83 c0 01             	add    $0x1,%eax
  800724:	eb f1                	jmp    800717 <strnlen+0x12>
  800726:	89 c2                	mov    %eax,%edx
	return n;
}
  800728:	89 d0                	mov    %edx,%eax
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072c:	f3 0f 1e fb          	endbr32 
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	53                   	push   %ebx
  800734:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800737:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80073a:	b8 00 00 00 00       	mov    $0x0,%eax
  80073f:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800743:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800746:	83 c0 01             	add    $0x1,%eax
  800749:	84 d2                	test   %dl,%dl
  80074b:	75 f2                	jne    80073f <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80074d:	89 c8                	mov    %ecx,%eax
  80074f:	5b                   	pop    %ebx
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800752:	f3 0f 1e fb          	endbr32 
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	53                   	push   %ebx
  80075a:	83 ec 10             	sub    $0x10,%esp
  80075d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800760:	53                   	push   %ebx
  800761:	e8 83 ff ff ff       	call   8006e9 <strlen>
  800766:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800769:	ff 75 0c             	pushl  0xc(%ebp)
  80076c:	01 d8                	add    %ebx,%eax
  80076e:	50                   	push   %eax
  80076f:	e8 b8 ff ff ff       	call   80072c <strcpy>
	return dst;
}
  800774:	89 d8                	mov    %ebx,%eax
  800776:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800779:	c9                   	leave  
  80077a:	c3                   	ret    

0080077b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077b:	f3 0f 1e fb          	endbr32 
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	56                   	push   %esi
  800783:	53                   	push   %ebx
  800784:	8b 75 08             	mov    0x8(%ebp),%esi
  800787:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078a:	89 f3                	mov    %esi,%ebx
  80078c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078f:	89 f0                	mov    %esi,%eax
  800791:	39 d8                	cmp    %ebx,%eax
  800793:	74 11                	je     8007a6 <strncpy+0x2b>
		*dst++ = *src;
  800795:	83 c0 01             	add    $0x1,%eax
  800798:	0f b6 0a             	movzbl (%edx),%ecx
  80079b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80079e:	80 f9 01             	cmp    $0x1,%cl
  8007a1:	83 da ff             	sbb    $0xffffffff,%edx
  8007a4:	eb eb                	jmp    800791 <strncpy+0x16>
	}
	return ret;
}
  8007a6:	89 f0                	mov    %esi,%eax
  8007a8:	5b                   	pop    %ebx
  8007a9:	5e                   	pop    %esi
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ac:	f3 0f 1e fb          	endbr32 
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	56                   	push   %esi
  8007b4:	53                   	push   %ebx
  8007b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bb:	8b 55 10             	mov    0x10(%ebp),%edx
  8007be:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c0:	85 d2                	test   %edx,%edx
  8007c2:	74 21                	je     8007e5 <strlcpy+0x39>
  8007c4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c8:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8007ca:	39 c2                	cmp    %eax,%edx
  8007cc:	74 14                	je     8007e2 <strlcpy+0x36>
  8007ce:	0f b6 19             	movzbl (%ecx),%ebx
  8007d1:	84 db                	test   %bl,%bl
  8007d3:	74 0b                	je     8007e0 <strlcpy+0x34>
			*dst++ = *src++;
  8007d5:	83 c1 01             	add    $0x1,%ecx
  8007d8:	83 c2 01             	add    $0x1,%edx
  8007db:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007de:	eb ea                	jmp    8007ca <strlcpy+0x1e>
  8007e0:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007e2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e5:	29 f0                	sub    %esi,%eax
}
  8007e7:	5b                   	pop    %ebx
  8007e8:	5e                   	pop    %esi
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007eb:	f3 0f 1e fb          	endbr32 
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f8:	0f b6 01             	movzbl (%ecx),%eax
  8007fb:	84 c0                	test   %al,%al
  8007fd:	74 0c                	je     80080b <strcmp+0x20>
  8007ff:	3a 02                	cmp    (%edx),%al
  800801:	75 08                	jne    80080b <strcmp+0x20>
		p++, q++;
  800803:	83 c1 01             	add    $0x1,%ecx
  800806:	83 c2 01             	add    $0x1,%edx
  800809:	eb ed                	jmp    8007f8 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080b:	0f b6 c0             	movzbl %al,%eax
  80080e:	0f b6 12             	movzbl (%edx),%edx
  800811:	29 d0                	sub    %edx,%eax
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800815:	f3 0f 1e fb          	endbr32 
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	53                   	push   %ebx
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	8b 55 0c             	mov    0xc(%ebp),%edx
  800823:	89 c3                	mov    %eax,%ebx
  800825:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800828:	eb 06                	jmp    800830 <strncmp+0x1b>
		n--, p++, q++;
  80082a:	83 c0 01             	add    $0x1,%eax
  80082d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800830:	39 d8                	cmp    %ebx,%eax
  800832:	74 16                	je     80084a <strncmp+0x35>
  800834:	0f b6 08             	movzbl (%eax),%ecx
  800837:	84 c9                	test   %cl,%cl
  800839:	74 04                	je     80083f <strncmp+0x2a>
  80083b:	3a 0a                	cmp    (%edx),%cl
  80083d:	74 eb                	je     80082a <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083f:	0f b6 00             	movzbl (%eax),%eax
  800842:	0f b6 12             	movzbl (%edx),%edx
  800845:	29 d0                	sub    %edx,%eax
}
  800847:	5b                   	pop    %ebx
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    
		return 0;
  80084a:	b8 00 00 00 00       	mov    $0x0,%eax
  80084f:	eb f6                	jmp    800847 <strncmp+0x32>

00800851 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800851:	f3 0f 1e fb          	endbr32 
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80085f:	0f b6 10             	movzbl (%eax),%edx
  800862:	84 d2                	test   %dl,%dl
  800864:	74 09                	je     80086f <strchr+0x1e>
		if (*s == c)
  800866:	38 ca                	cmp    %cl,%dl
  800868:	74 0a                	je     800874 <strchr+0x23>
	for (; *s; s++)
  80086a:	83 c0 01             	add    $0x1,%eax
  80086d:	eb f0                	jmp    80085f <strchr+0xe>
			return (char *) s;
	return 0;
  80086f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800876:	f3 0f 1e fb          	endbr32 
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800884:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800887:	38 ca                	cmp    %cl,%dl
  800889:	74 09                	je     800894 <strfind+0x1e>
  80088b:	84 d2                	test   %dl,%dl
  80088d:	74 05                	je     800894 <strfind+0x1e>
	for (; *s; s++)
  80088f:	83 c0 01             	add    $0x1,%eax
  800892:	eb f0                	jmp    800884 <strfind+0xe>
			break;
	return (char *) s;
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800896:	f3 0f 1e fb          	endbr32 
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	57                   	push   %edi
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8008a6:	85 c9                	test   %ecx,%ecx
  8008a8:	74 33                	je     8008dd <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008aa:	89 d0                	mov    %edx,%eax
  8008ac:	09 c8                	or     %ecx,%eax
  8008ae:	a8 03                	test   $0x3,%al
  8008b0:	75 23                	jne    8008d5 <memset+0x3f>
		c &= 0xFF;
  8008b2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b6:	89 d8                	mov    %ebx,%eax
  8008b8:	c1 e0 08             	shl    $0x8,%eax
  8008bb:	89 df                	mov    %ebx,%edi
  8008bd:	c1 e7 18             	shl    $0x18,%edi
  8008c0:	89 de                	mov    %ebx,%esi
  8008c2:	c1 e6 10             	shl    $0x10,%esi
  8008c5:	09 f7                	or     %esi,%edi
  8008c7:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  8008c9:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008cc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8008ce:	89 d7                	mov    %edx,%edi
  8008d0:	fc                   	cld    
  8008d1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d3:	eb 08                	jmp    8008dd <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d5:	89 d7                	mov    %edx,%edi
  8008d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008da:	fc                   	cld    
  8008db:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8008dd:	89 d0                	mov    %edx,%eax
  8008df:	5b                   	pop    %ebx
  8008e0:	5e                   	pop    %esi
  8008e1:	5f                   	pop    %edi
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e4:	f3 0f 1e fb          	endbr32 
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	57                   	push   %edi
  8008ec:	56                   	push   %esi
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f6:	39 c6                	cmp    %eax,%esi
  8008f8:	73 32                	jae    80092c <memmove+0x48>
  8008fa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fd:	39 c2                	cmp    %eax,%edx
  8008ff:	76 2b                	jbe    80092c <memmove+0x48>
		s += n;
		d += n;
  800901:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800904:	89 fe                	mov    %edi,%esi
  800906:	09 ce                	or     %ecx,%esi
  800908:	09 d6                	or     %edx,%esi
  80090a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800910:	75 0e                	jne    800920 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800912:	83 ef 04             	sub    $0x4,%edi
  800915:	8d 72 fc             	lea    -0x4(%edx),%esi
  800918:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80091b:	fd                   	std    
  80091c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091e:	eb 09                	jmp    800929 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800920:	83 ef 01             	sub    $0x1,%edi
  800923:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800926:	fd                   	std    
  800927:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800929:	fc                   	cld    
  80092a:	eb 1a                	jmp    800946 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092c:	89 c2                	mov    %eax,%edx
  80092e:	09 ca                	or     %ecx,%edx
  800930:	09 f2                	or     %esi,%edx
  800932:	f6 c2 03             	test   $0x3,%dl
  800935:	75 0a                	jne    800941 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800937:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80093a:	89 c7                	mov    %eax,%edi
  80093c:	fc                   	cld    
  80093d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093f:	eb 05                	jmp    800946 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800941:	89 c7                	mov    %eax,%edi
  800943:	fc                   	cld    
  800944:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800946:	5e                   	pop    %esi
  800947:	5f                   	pop    %edi
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094a:	f3 0f 1e fb          	endbr32 
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800954:	ff 75 10             	pushl  0x10(%ebp)
  800957:	ff 75 0c             	pushl  0xc(%ebp)
  80095a:	ff 75 08             	pushl  0x8(%ebp)
  80095d:	e8 82 ff ff ff       	call   8008e4 <memmove>
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800964:	f3 0f 1e fb          	endbr32 
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
  800973:	89 c6                	mov    %eax,%esi
  800975:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800978:	39 f0                	cmp    %esi,%eax
  80097a:	74 1c                	je     800998 <memcmp+0x34>
		if (*s1 != *s2)
  80097c:	0f b6 08             	movzbl (%eax),%ecx
  80097f:	0f b6 1a             	movzbl (%edx),%ebx
  800982:	38 d9                	cmp    %bl,%cl
  800984:	75 08                	jne    80098e <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800986:	83 c0 01             	add    $0x1,%eax
  800989:	83 c2 01             	add    $0x1,%edx
  80098c:	eb ea                	jmp    800978 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  80098e:	0f b6 c1             	movzbl %cl,%eax
  800991:	0f b6 db             	movzbl %bl,%ebx
  800994:	29 d8                	sub    %ebx,%eax
  800996:	eb 05                	jmp    80099d <memcmp+0x39>
	}

	return 0;
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099d:	5b                   	pop    %ebx
  80099e:	5e                   	pop    %esi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a1:	f3 0f 1e fb          	endbr32 
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ae:	89 c2                	mov    %eax,%edx
  8009b0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009b3:	39 d0                	cmp    %edx,%eax
  8009b5:	73 09                	jae    8009c0 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b7:	38 08                	cmp    %cl,(%eax)
  8009b9:	74 05                	je     8009c0 <memfind+0x1f>
	for (; s < ends; s++)
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	eb f3                	jmp    8009b3 <memfind+0x12>
			break;
	return (void *) s;
}
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c2:	f3 0f 1e fb          	endbr32 
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	57                   	push   %edi
  8009ca:	56                   	push   %esi
  8009cb:	53                   	push   %ebx
  8009cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d2:	eb 03                	jmp    8009d7 <strtol+0x15>
		s++;
  8009d4:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009d7:	0f b6 01             	movzbl (%ecx),%eax
  8009da:	3c 20                	cmp    $0x20,%al
  8009dc:	74 f6                	je     8009d4 <strtol+0x12>
  8009de:	3c 09                	cmp    $0x9,%al
  8009e0:	74 f2                	je     8009d4 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  8009e2:	3c 2b                	cmp    $0x2b,%al
  8009e4:	74 2a                	je     800a10 <strtol+0x4e>
	int neg = 0;
  8009e6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009eb:	3c 2d                	cmp    $0x2d,%al
  8009ed:	74 2b                	je     800a1a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ef:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009f5:	75 0f                	jne    800a06 <strtol+0x44>
  8009f7:	80 39 30             	cmpb   $0x30,(%ecx)
  8009fa:	74 28                	je     800a24 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fc:	85 db                	test   %ebx,%ebx
  8009fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a03:	0f 44 d8             	cmove  %eax,%ebx
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a0e:	eb 46                	jmp    800a56 <strtol+0x94>
		s++;
  800a10:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a13:	bf 00 00 00 00       	mov    $0x0,%edi
  800a18:	eb d5                	jmp    8009ef <strtol+0x2d>
		s++, neg = 1;
  800a1a:	83 c1 01             	add    $0x1,%ecx
  800a1d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a22:	eb cb                	jmp    8009ef <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a24:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a28:	74 0e                	je     800a38 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a2a:	85 db                	test   %ebx,%ebx
  800a2c:	75 d8                	jne    800a06 <strtol+0x44>
		s++, base = 8;
  800a2e:	83 c1 01             	add    $0x1,%ecx
  800a31:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a36:	eb ce                	jmp    800a06 <strtol+0x44>
		s += 2, base = 16;
  800a38:	83 c1 02             	add    $0x2,%ecx
  800a3b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a40:	eb c4                	jmp    800a06 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a42:	0f be d2             	movsbl %dl,%edx
  800a45:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a48:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a4b:	7d 3a                	jge    800a87 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a4d:	83 c1 01             	add    $0x1,%ecx
  800a50:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a54:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a56:	0f b6 11             	movzbl (%ecx),%edx
  800a59:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5c:	89 f3                	mov    %esi,%ebx
  800a5e:	80 fb 09             	cmp    $0x9,%bl
  800a61:	76 df                	jbe    800a42 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800a63:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a66:	89 f3                	mov    %esi,%ebx
  800a68:	80 fb 19             	cmp    $0x19,%bl
  800a6b:	77 08                	ja     800a75 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a6d:	0f be d2             	movsbl %dl,%edx
  800a70:	83 ea 57             	sub    $0x57,%edx
  800a73:	eb d3                	jmp    800a48 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800a75:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a78:	89 f3                	mov    %esi,%ebx
  800a7a:	80 fb 19             	cmp    $0x19,%bl
  800a7d:	77 08                	ja     800a87 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a7f:	0f be d2             	movsbl %dl,%edx
  800a82:	83 ea 37             	sub    $0x37,%edx
  800a85:	eb c1                	jmp    800a48 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a87:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8b:	74 05                	je     800a92 <strtol+0xd0>
		*endptr = (char *) s;
  800a8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a90:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a92:	89 c2                	mov    %eax,%edx
  800a94:	f7 da                	neg    %edx
  800a96:	85 ff                	test   %edi,%edi
  800a98:	0f 45 c2             	cmovne %edx,%eax
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	83 ec 1c             	sub    $0x1c,%esp
  800aa9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800aac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800aaf:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab7:	8b 7d 10             	mov    0x10(%ebp),%edi
  800aba:	8b 75 14             	mov    0x14(%ebp),%esi
  800abd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800abf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ac3:	74 04                	je     800ac9 <syscall+0x29>
  800ac5:	85 c0                	test   %eax,%eax
  800ac7:	7f 08                	jg     800ad1 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800ac9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad1:	83 ec 0c             	sub    $0xc,%esp
  800ad4:	50                   	push   %eax
  800ad5:	ff 75 e0             	pushl  -0x20(%ebp)
  800ad8:	68 5f 27 80 00       	push   $0x80275f
  800add:	6a 23                	push   $0x23
  800adf:	68 7c 27 80 00       	push   $0x80277c
  800ae4:	e8 3e 14 00 00       	call   801f27 <_panic>

00800ae9 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800ae9:	f3 0f 1e fb          	endbr32 
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800af3:	6a 00                	push   $0x0
  800af5:	6a 00                	push   $0x0
  800af7:	6a 00                	push   $0x0
  800af9:	ff 75 0c             	pushl  0xc(%ebp)
  800afc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aff:	ba 00 00 00 00       	mov    $0x0,%edx
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
  800b09:	e8 92 ff ff ff       	call   800aa0 <syscall>
}
  800b0e:	83 c4 10             	add    $0x10,%esp
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b13:	f3 0f 1e fb          	endbr32 
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b1d:	6a 00                	push   $0x0
  800b1f:	6a 00                	push   $0x0
  800b21:	6a 00                	push   $0x0
  800b23:	6a 00                	push   $0x0
  800b25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b34:	e8 67 ff ff ff       	call   800aa0 <syscall>
}
  800b39:	c9                   	leave  
  800b3a:	c3                   	ret    

00800b3b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3b:	f3 0f 1e fb          	endbr32 
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b45:	6a 00                	push   $0x0
  800b47:	6a 00                	push   $0x0
  800b49:	6a 00                	push   $0x0
  800b4b:	6a 00                	push   $0x0
  800b4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b50:	ba 01 00 00 00       	mov    $0x1,%edx
  800b55:	b8 03 00 00 00       	mov    $0x3,%eax
  800b5a:	e8 41 ff ff ff       	call   800aa0 <syscall>
}
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    

00800b61 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b61:	f3 0f 1e fb          	endbr32 
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b6b:	6a 00                	push   $0x0
  800b6d:	6a 00                	push   $0x0
  800b6f:	6a 00                	push   $0x0
  800b71:	6a 00                	push   $0x0
  800b73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b78:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b82:	e8 19 ff ff ff       	call   800aa0 <syscall>
}
  800b87:	c9                   	leave  
  800b88:	c3                   	ret    

00800b89 <sys_yield>:

void
sys_yield(void)
{
  800b89:	f3 0f 1e fb          	endbr32 
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b93:	6a 00                	push   $0x0
  800b95:	6a 00                	push   $0x0
  800b97:	6a 00                	push   $0x0
  800b99:	6a 00                	push   $0x0
  800b9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800baa:	e8 f1 fe ff ff       	call   800aa0 <syscall>
}
  800baf:	83 c4 10             	add    $0x10,%esp
  800bb2:	c9                   	leave  
  800bb3:	c3                   	ret    

00800bb4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb4:	f3 0f 1e fb          	endbr32 
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bbe:	6a 00                	push   $0x0
  800bc0:	6a 00                	push   $0x0
  800bc2:	ff 75 10             	pushl  0x10(%ebp)
  800bc5:	ff 75 0c             	pushl  0xc(%ebp)
  800bc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcb:	ba 01 00 00 00       	mov    $0x1,%edx
  800bd0:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd5:	e8 c6 fe ff ff       	call   800aa0 <syscall>
}
  800bda:	c9                   	leave  
  800bdb:	c3                   	ret    

00800bdc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bdc:	f3 0f 1e fb          	endbr32 
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800be6:	ff 75 18             	pushl  0x18(%ebp)
  800be9:	ff 75 14             	pushl  0x14(%ebp)
  800bec:	ff 75 10             	pushl  0x10(%ebp)
  800bef:	ff 75 0c             	pushl  0xc(%ebp)
  800bf2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf5:	ba 01 00 00 00       	mov    $0x1,%edx
  800bfa:	b8 05 00 00 00       	mov    $0x5,%eax
  800bff:	e8 9c fe ff ff       	call   800aa0 <syscall>
}
  800c04:	c9                   	leave  
  800c05:	c3                   	ret    

00800c06 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c06:	f3 0f 1e fb          	endbr32 
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c10:	6a 00                	push   $0x0
  800c12:	6a 00                	push   $0x0
  800c14:	6a 00                	push   $0x0
  800c16:	ff 75 0c             	pushl  0xc(%ebp)
  800c19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1c:	ba 01 00 00 00       	mov    $0x1,%edx
  800c21:	b8 06 00 00 00       	mov    $0x6,%eax
  800c26:	e8 75 fe ff ff       	call   800aa0 <syscall>
}
  800c2b:	c9                   	leave  
  800c2c:	c3                   	ret    

00800c2d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2d:	f3 0f 1e fb          	endbr32 
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c37:	6a 00                	push   $0x0
  800c39:	6a 00                	push   $0x0
  800c3b:	6a 00                	push   $0x0
  800c3d:	ff 75 0c             	pushl  0xc(%ebp)
  800c40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c43:	ba 01 00 00 00       	mov    $0x1,%edx
  800c48:	b8 08 00 00 00       	mov    $0x8,%eax
  800c4d:	e8 4e fe ff ff       	call   800aa0 <syscall>
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c54:	f3 0f 1e fb          	endbr32 
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c5e:	6a 00                	push   $0x0
  800c60:	6a 00                	push   $0x0
  800c62:	6a 00                	push   $0x0
  800c64:	ff 75 0c             	pushl  0xc(%ebp)
  800c67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c6f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c74:	e8 27 fe ff ff       	call   800aa0 <syscall>
}
  800c79:	c9                   	leave  
  800c7a:	c3                   	ret    

00800c7b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c7b:	f3 0f 1e fb          	endbr32 
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c85:	6a 00                	push   $0x0
  800c87:	6a 00                	push   $0x0
  800c89:	6a 00                	push   $0x0
  800c8b:	ff 75 0c             	pushl  0xc(%ebp)
  800c8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c91:	ba 01 00 00 00       	mov    $0x1,%edx
  800c96:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9b:	e8 00 fe ff ff       	call   800aa0 <syscall>
}
  800ca0:	c9                   	leave  
  800ca1:	c3                   	ret    

00800ca2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca2:	f3 0f 1e fb          	endbr32 
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cac:	6a 00                	push   $0x0
  800cae:	ff 75 14             	pushl  0x14(%ebp)
  800cb1:	ff 75 10             	pushl  0x10(%ebp)
  800cb4:	ff 75 0c             	pushl  0xc(%ebp)
  800cb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cba:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc4:	e8 d7 fd ff ff       	call   800aa0 <syscall>
}
  800cc9:	c9                   	leave  
  800cca:	c3                   	ret    

00800ccb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccb:	f3 0f 1e fb          	endbr32 
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cd5:	6a 00                	push   $0x0
  800cd7:	6a 00                	push   $0x0
  800cd9:	6a 00                	push   $0x0
  800cdb:	6a 00                	push   $0x0
  800cdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce0:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cea:	e8 b1 fd ff ff       	call   800aa0 <syscall>
}
  800cef:	c9                   	leave  
  800cf0:	c3                   	ret    

00800cf1 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 04             	sub    $0x4,%esp
	int r;

	// LAB 4: Your code here.
	void *addr = (void *) (pn * PGSIZE);
  800cf8:	89 d3                	mov    %edx,%ebx
  800cfa:	c1 e3 0c             	shl    $0xc,%ebx

	if (uvpt[pn] & PTE_SHARE) {
  800cfd:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d04:	f6 c5 04             	test   $0x4,%ch
  800d07:	75 56                	jne    800d5f <duppage+0x6e>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
		return 0;
	}

	if ((uvpt[pn] & (PTE_W | PTE_COW)) != 0) {
  800d09:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d10:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800d16:	74 72                	je     800d8a <duppage+0x99>
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW) <
  800d18:	83 ec 0c             	sub    $0xc,%esp
  800d1b:	68 05 08 00 00       	push   $0x805
  800d20:	53                   	push   %ebx
  800d21:	50                   	push   %eax
  800d22:	53                   	push   %ebx
  800d23:	6a 00                	push   $0x0
  800d25:	e8 b2 fe ff ff       	call   800bdc <sys_page_map>
  800d2a:	83 c4 20             	add    $0x20,%esp
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	78 45                	js     800d76 <duppage+0x85>
		    0) {
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
		}
		if (sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW) < 0) {
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	68 05 08 00 00       	push   $0x805
  800d39:	53                   	push   %ebx
  800d3a:	6a 00                	push   $0x0
  800d3c:	53                   	push   %ebx
  800d3d:	6a 00                	push   $0x0
  800d3f:	e8 98 fe ff ff       	call   800bdc <sys_page_map>
  800d44:	83 c4 20             	add    $0x20,%esp
  800d47:	85 c0                	test   %eax,%eax
  800d49:	79 55                	jns    800da0 <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP FATHER");
  800d4b:	83 ec 04             	sub    $0x4,%esp
  800d4e:	68 ac 27 80 00       	push   $0x8027ac
  800d53:	6a 54                	push   $0x54
  800d55:	68 3f 28 80 00       	push   $0x80283f
  800d5a:	e8 c8 11 00 00       	call   801f27 <_panic>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800d5f:	83 ec 0c             	sub    $0xc,%esp
  800d62:	68 07 0e 00 00       	push   $0xe07
  800d67:	53                   	push   %ebx
  800d68:	50                   	push   %eax
  800d69:	53                   	push   %ebx
  800d6a:	6a 00                	push   $0x0
  800d6c:	e8 6b fe ff ff       	call   800bdc <sys_page_map>
		return 0;
  800d71:	83 c4 20             	add    $0x20,%esp
  800d74:	eb 2a                	jmp    800da0 <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
  800d76:	83 ec 04             	sub    $0x4,%esp
  800d79:	68 8c 27 80 00       	push   $0x80278c
  800d7e:	6a 51                	push   $0x51
  800d80:	68 3f 28 80 00       	push   $0x80283f
  800d85:	e8 9d 11 00 00       	call   801f27 <_panic>
		}
	} else {
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U) < 0) {
  800d8a:	83 ec 0c             	sub    $0xc,%esp
  800d8d:	6a 05                	push   $0x5
  800d8f:	53                   	push   %ebx
  800d90:	50                   	push   %eax
  800d91:	53                   	push   %ebx
  800d92:	6a 00                	push   $0x0
  800d94:	e8 43 fe ff ff       	call   800bdc <sys_page_map>
  800d99:	83 c4 20             	add    $0x20,%esp
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	78 0a                	js     800daa <duppage+0xb9>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
		}
	}

	return 0;
}
  800da0:	b8 00 00 00 00       	mov    $0x0,%eax
  800da5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800da8:	c9                   	leave  
  800da9:	c3                   	ret    
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
  800daa:	83 ec 04             	sub    $0x4,%esp
  800dad:	68 4a 28 80 00       	push   $0x80284a
  800db2:	6a 58                	push   $0x58
  800db4:	68 3f 28 80 00       	push   $0x80283f
  800db9:	e8 69 11 00 00       	call   801f27 <_panic>

00800dbe <dup_or_share>:

static void
dup_or_share(envid_t dstenv, void *va, int perm)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
  800dc3:	89 c6                	mov    %eax,%esi
  800dc5:	89 d3                	mov    %edx,%ebx
	int r;
	if (perm & PTE_W) {
  800dc7:	f6 c1 02             	test   $0x2,%cl
  800dca:	0f 84 8c 00 00 00    	je     800e5c <dup_or_share+0x9e>
		// dup
		if ((r = sys_page_alloc(dstenv, va, PTE_P | PTE_U | PTE_W)) < 0)
  800dd0:	83 ec 04             	sub    $0x4,%esp
  800dd3:	6a 07                	push   $0x7
  800dd5:	52                   	push   %edx
  800dd6:	50                   	push   %eax
  800dd7:	e8 d8 fd ff ff       	call   800bb4 <sys_page_alloc>
  800ddc:	83 c4 10             	add    $0x10,%esp
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	78 55                	js     800e38 <dup_or_share+0x7a>
			panic("sys_page_alloc: %e", r);
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	6a 07                	push   $0x7
  800de8:	68 00 00 40 00       	push   $0x400000
  800ded:	6a 00                	push   $0x0
  800def:	53                   	push   %ebx
  800df0:	56                   	push   %esi
  800df1:	e8 e6 fd ff ff       	call   800bdc <sys_page_map>
  800df6:	83 c4 20             	add    $0x20,%esp
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	78 4d                	js     800e4a <dup_or_share+0x8c>
		    0)
			panic("sys_page_map: %e", r);
		memmove(UTEMP, va, PGSIZE);
  800dfd:	83 ec 04             	sub    $0x4,%esp
  800e00:	68 00 10 00 00       	push   $0x1000
  800e05:	53                   	push   %ebx
  800e06:	68 00 00 40 00       	push   $0x400000
  800e0b:	e8 d4 fa ff ff       	call   8008e4 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800e10:	83 c4 08             	add    $0x8,%esp
  800e13:	68 00 00 40 00       	push   $0x400000
  800e18:	6a 00                	push   $0x0
  800e1a:	e8 e7 fd ff ff       	call   800c06 <sys_page_unmap>
  800e1f:	83 c4 10             	add    $0x10,%esp
  800e22:	85 c0                	test   %eax,%eax
  800e24:	79 52                	jns    800e78 <dup_or_share+0xba>
			panic("sys_page_unmap: %e", r);
  800e26:	50                   	push   %eax
  800e27:	68 8a 28 80 00       	push   $0x80288a
  800e2c:	6a 6c                	push   $0x6c
  800e2e:	68 3f 28 80 00       	push   $0x80283f
  800e33:	e8 ef 10 00 00       	call   801f27 <_panic>
			panic("sys_page_alloc: %e", r);
  800e38:	50                   	push   %eax
  800e39:	68 66 28 80 00       	push   $0x802866
  800e3e:	6a 66                	push   $0x66
  800e40:	68 3f 28 80 00       	push   $0x80283f
  800e45:	e8 dd 10 00 00       	call   801f27 <_panic>
			panic("sys_page_map: %e", r);
  800e4a:	50                   	push   %eax
  800e4b:	68 79 28 80 00       	push   $0x802879
  800e50:	6a 69                	push   $0x69
  800e52:	68 3f 28 80 00       	push   $0x80283f
  800e57:	e8 cb 10 00 00       	call   801f27 <_panic>

	} else {
		// share
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | perm)) <
  800e5c:	83 ec 0c             	sub    $0xc,%esp
  800e5f:	83 c9 05             	or     $0x5,%ecx
  800e62:	51                   	push   %ecx
  800e63:	68 00 00 40 00       	push   $0x400000
  800e68:	6a 00                	push   $0x0
  800e6a:	52                   	push   %edx
  800e6b:	50                   	push   %eax
  800e6c:	e8 6b fd ff ff       	call   800bdc <sys_page_map>
  800e71:	83 c4 20             	add    $0x20,%esp
  800e74:	85 c0                	test   %eax,%eax
  800e76:	78 07                	js     800e7f <dup_or_share+0xc1>
		    0)
			panic("sys_page_map: %e", r);
	}
}
  800e78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    
			panic("sys_page_map: %e", r);
  800e7f:	50                   	push   %eax
  800e80:	68 79 28 80 00       	push   $0x802879
  800e85:	6a 72                	push   $0x72
  800e87:	68 3f 28 80 00       	push   $0x80283f
  800e8c:	e8 96 10 00 00       	call   801f27 <_panic>

00800e91 <pgfault>:
{
  800e91:	f3 0f 1e fb          	endbr32 
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	53                   	push   %ebx
  800e99:	83 ec 04             	sub    $0x4,%esp
  800e9c:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e9f:	8b 02                	mov    (%edx),%eax
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800ea1:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800ea5:	0f 84 95 00 00 00    	je     800f40 <pgfault+0xaf>
  800eab:	89 c2                	mov    %eax,%edx
  800ead:	c1 ea 16             	shr    $0x16,%edx
  800eb0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb7:	f6 c2 01             	test   $0x1,%dl
  800eba:	0f 84 80 00 00 00    	je     800f40 <pgfault+0xaf>
	    (~uvpt[PGNUM(addr)] & (PTE_COW | PTE_P)) != 0) {
  800ec0:	89 c2                	mov    %eax,%edx
  800ec2:	c1 ea 0c             	shr    $0xc,%edx
  800ec5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ecc:	f7 d2                	not    %edx
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800ece:	f7 c2 01 08 00 00    	test   $0x801,%edx
  800ed4:	75 6a                	jne    800f40 <pgfault+0xaf>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800ed6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800edb:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U) < 0) {
  800edd:	83 ec 04             	sub    $0x4,%esp
  800ee0:	6a 07                	push   $0x7
  800ee2:	68 00 f0 7f 00       	push   $0x7ff000
  800ee7:	6a 00                	push   $0x0
  800ee9:	e8 c6 fc ff ff       	call   800bb4 <sys_page_alloc>
  800eee:	83 c4 10             	add    $0x10,%esp
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	78 5f                	js     800f54 <pgfault+0xc3>
	memcpy((void *) PFTEMP, addr, PGSIZE);
  800ef5:	83 ec 04             	sub    $0x4,%esp
  800ef8:	68 00 10 00 00       	push   $0x1000
  800efd:	53                   	push   %ebx
  800efe:	68 00 f0 7f 00       	push   $0x7ff000
  800f03:	e8 42 fa ff ff       	call   80094a <memcpy>
	if (sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U) < 0) {
  800f08:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f0f:	53                   	push   %ebx
  800f10:	6a 00                	push   $0x0
  800f12:	68 00 f0 7f 00       	push   $0x7ff000
  800f17:	6a 00                	push   $0x0
  800f19:	e8 be fc ff ff       	call   800bdc <sys_page_map>
  800f1e:	83 c4 20             	add    $0x20,%esp
  800f21:	85 c0                	test   %eax,%eax
  800f23:	78 43                	js     800f68 <pgfault+0xd7>
	if (sys_page_unmap(0, (void *) PFTEMP) < 0) {
  800f25:	83 ec 08             	sub    $0x8,%esp
  800f28:	68 00 f0 7f 00       	push   $0x7ff000
  800f2d:	6a 00                	push   $0x0
  800f2f:	e8 d2 fc ff ff       	call   800c06 <sys_page_unmap>
  800f34:	83 c4 10             	add    $0x10,%esp
  800f37:	85 c0                	test   %eax,%eax
  800f39:	78 41                	js     800f7c <pgfault+0xeb>
}
  800f3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3e:	c9                   	leave  
  800f3f:	c3                   	ret    
		panic("ERROR PGFAULT");
  800f40:	83 ec 04             	sub    $0x4,%esp
  800f43:	68 9d 28 80 00       	push   $0x80289d
  800f48:	6a 1e                	push   $0x1e
  800f4a:	68 3f 28 80 00       	push   $0x80283f
  800f4f:	e8 d3 0f 00 00       	call   801f27 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_ALLOC");
  800f54:	83 ec 04             	sub    $0x4,%esp
  800f57:	68 ab 28 80 00       	push   $0x8028ab
  800f5c:	6a 2b                	push   $0x2b
  800f5e:	68 3f 28 80 00       	push   $0x80283f
  800f63:	e8 bf 0f 00 00       	call   801f27 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_MAP");
  800f68:	83 ec 04             	sub    $0x4,%esp
  800f6b:	68 c9 28 80 00       	push   $0x8028c9
  800f70:	6a 2f                	push   $0x2f
  800f72:	68 3f 28 80 00       	push   $0x80283f
  800f77:	e8 ab 0f 00 00       	call   801f27 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_UNMAP");
  800f7c:	83 ec 04             	sub    $0x4,%esp
  800f7f:	68 e5 28 80 00       	push   $0x8028e5
  800f84:	6a 32                	push   $0x32
  800f86:	68 3f 28 80 00       	push   $0x80283f
  800f8b:	e8 97 0f 00 00       	call   801f27 <_panic>

00800f90 <fork_v0>:

envid_t
fork_v0(void)
{
  800f90:	f3 0f 1e fb          	endbr32 
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	57                   	push   %edi
  800f98:	56                   	push   %esi
  800f99:	53                   	push   %ebx
  800f9a:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f9d:	b8 07 00 00 00       	mov    $0x7,%eax
  800fa2:	cd 30                	int    $0x30
	envid_t env_id = sys_exofork();
	if (env_id < 0) {
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	78 24                	js     800fcc <fork_v0+0x3c>
  800fa8:	89 c6                	mov    %eax,%esi
  800faa:	89 c7                	mov    %eax,%edi
		thisenv = envs + ENVX(sys_getenvid());
		return env_id;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  800fac:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (env_id == 0) {  // Son
  800fb1:	75 51                	jne    801004 <fork_v0+0x74>
		thisenv = envs + ENVX(sys_getenvid());
  800fb3:	e8 a9 fb ff ff       	call   800b61 <sys_getenvid>
  800fb8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fbd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fc0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc5:	a3 04 40 80 00       	mov    %eax,0x804004
		return env_id;
  800fca:	eb 78                	jmp    801044 <fork_v0+0xb4>
		panic("ERROR ON FORK_V0");
  800fcc:	83 ec 04             	sub    $0x4,%esp
  800fcf:	68 03 29 80 00       	push   $0x802903
  800fd4:	6a 7b                	push   $0x7b
  800fd6:	68 3f 28 80 00       	push   $0x80283f
  800fdb:	e8 47 0f 00 00       	call   801f27 <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
				dup_or_share(env_id,
  800fe0:	b9 07 00 00 00       	mov    $0x7,%ecx
  800fe5:	89 da                	mov    %ebx,%edx
  800fe7:	89 f8                	mov    %edi,%eax
  800fe9:	e8 d0 fd ff ff       	call   800dbe <dup_or_share>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  800fee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ff4:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  800ffa:	77 36                	ja     801032 <fork_v0+0xa2>
		if (addr != UXSTACKTOP - PGSIZE) {
  800ffc:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801002:	74 ea                	je     800fee <fork_v0+0x5e>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801004:	89 d8                	mov    %ebx,%eax
  801006:	c1 e8 16             	shr    $0x16,%eax
  801009:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801010:	a8 01                	test   $0x1,%al
  801012:	74 da                	je     800fee <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  801014:	89 d8                	mov    %ebx,%eax
  801016:	c1 e8 0c             	shr    $0xc,%eax
  801019:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801020:	f6 c2 01             	test   $0x1,%dl
  801023:	74 c9                	je     800fee <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
  801025:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  80102c:	a8 04                	test   $0x4,%al
  80102e:	74 be                	je     800fee <fork_v0+0x5e>
  801030:	eb ae                	jmp    800fe0 <fork_v0+0x50>
				             PTE_P | PTE_U | PTE_W);
			}
		}
	}

	if (sys_env_set_status(env_id, ENV_RUNNABLE) < 0) {
  801032:	83 ec 08             	sub    $0x8,%esp
  801035:	6a 02                	push   $0x2
  801037:	56                   	push   %esi
  801038:	e8 f0 fb ff ff       	call   800c2d <sys_env_set_status>
  80103d:	83 c4 10             	add    $0x10,%esp
  801040:	85 c0                	test   %eax,%eax
  801042:	78 0a                	js     80104e <fork_v0+0xbe>
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
	}

	return env_id;
}
  801044:	89 f0                	mov    %esi,%eax
  801046:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801049:	5b                   	pop    %ebx
  80104a:	5e                   	pop    %esi
  80104b:	5f                   	pop    %edi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
  80104e:	83 ec 04             	sub    $0x4,%esp
  801051:	68 d0 27 80 00       	push   $0x8027d0
  801056:	68 92 00 00 00       	push   $0x92
  80105b:	68 3f 28 80 00       	push   $0x80283f
  801060:	e8 c2 0e 00 00       	call   801f27 <_panic>

00801065 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801065:	f3 0f 1e fb          	endbr32 
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	57                   	push   %edi
  80106d:	56                   	push   %esi
  80106e:	53                   	push   %ebx
  80106f:	83 ec 18             	sub    $0x18,%esp
	// return fork_v0(); // Uncomment this line if you want to run fork_v0.
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801072:	68 91 0e 80 00       	push   $0x800e91
  801077:	e8 f5 0e 00 00       	call   801f71 <set_pgfault_handler>
  80107c:	b8 07 00 00 00       	mov    $0x7,%eax
  801081:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0) {
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	85 c0                	test   %eax,%eax
  801088:	78 27                	js     8010b1 <fork+0x4c>
  80108a:	89 c7                	mov    %eax,%edi
  80108c:	89 c6                	mov    %eax,%esi
		thisenv = envs + ENVX(sys_getenvid());
		return envid;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  80108e:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else if (envid == 0) {  // Son
  801093:	75 55                	jne    8010ea <fork+0x85>
		thisenv = envs + ENVX(sys_getenvid());
  801095:	e8 c7 fa ff ff       	call   800b61 <sys_getenvid>
  80109a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80109f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010a2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010a7:	a3 04 40 80 00       	mov    %eax,0x804004
		return envid;
  8010ac:	e9 9b 00 00 00       	jmp    80114c <fork+0xe7>
		panic("ERROR IN FORK: SYS_EXOFORK");
  8010b1:	83 ec 04             	sub    $0x4,%esp
  8010b4:	68 14 29 80 00       	push   $0x802914
  8010b9:	68 b1 00 00 00       	push   $0xb1
  8010be:	68 3f 28 80 00       	push   $0x80283f
  8010c3:	e8 5f 0e 00 00       	call   801f27 <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
				duppage(envid, addr / PGSIZE);
  8010c8:	89 da                	mov    %ebx,%edx
  8010ca:	c1 ea 0c             	shr    $0xc,%edx
  8010cd:	89 f0                	mov    %esi,%eax
  8010cf:	e8 1d fc ff ff       	call   800cf1 <duppage>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  8010d4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010da:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8010e0:	77 2c                	ja     80110e <fork+0xa9>
		if (addr != UXSTACKTOP - PGSIZE) {
  8010e2:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010e8:	74 ea                	je     8010d4 <fork+0x6f>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  8010ea:	89 d8                	mov    %ebx,%eax
  8010ec:	c1 e8 16             	shr    $0x16,%eax
  8010ef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010f6:	a8 01                	test   $0x1,%al
  8010f8:	74 da                	je     8010d4 <fork+0x6f>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
  8010fa:	89 d8                	mov    %ebx,%eax
  8010fc:	c1 e8 0c             	shr    $0xc,%eax
  8010ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801106:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801108:	a8 05                	test   $0x5,%al
  80110a:	75 c8                	jne    8010d4 <fork+0x6f>
  80110c:	eb ba                	jmp    8010c8 <fork+0x63>
			}
		}
	}

	if (sys_page_alloc(envid,
  80110e:	83 ec 04             	sub    $0x4,%esp
  801111:	6a 07                	push   $0x7
  801113:	68 00 f0 bf ee       	push   $0xeebff000
  801118:	57                   	push   %edi
  801119:	e8 96 fa ff ff       	call   800bb4 <sys_page_alloc>
  80111e:	83 c4 10             	add    $0x10,%esp
  801121:	85 c0                	test   %eax,%eax
  801123:	78 31                	js     801156 <fork+0xf1>
	                   PTE_P | PTE_U | PTE_W) < 0) {
		panic("ERROR FORK: SYS_PAGE_ALLOC");
	}

	extern void _pgfault_upcall(void);
	if (sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0) {
  801125:	83 ec 08             	sub    $0x8,%esp
  801128:	68 e4 1f 80 00       	push   $0x801fe4
  80112d:	57                   	push   %edi
  80112e:	e8 48 fb ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
  801133:	83 c4 10             	add    $0x10,%esp
  801136:	85 c0                	test   %eax,%eax
  801138:	78 33                	js     80116d <fork+0x108>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
	}

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0) {
  80113a:	83 ec 08             	sub    $0x8,%esp
  80113d:	6a 02                	push   $0x2
  80113f:	57                   	push   %edi
  801140:	e8 e8 fa ff ff       	call   800c2d <sys_env_set_status>
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	85 c0                	test   %eax,%eax
  80114a:	78 38                	js     801184 <fork+0x11f>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
	}

	return envid;
}
  80114c:	89 f8                	mov    %edi,%eax
  80114e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    
		panic("ERROR FORK: SYS_PAGE_ALLOC");
  801156:	83 ec 04             	sub    $0x4,%esp
  801159:	68 2f 29 80 00       	push   $0x80292f
  80115e:	68 c4 00 00 00       	push   $0xc4
  801163:	68 3f 28 80 00       	push   $0x80283f
  801168:	e8 ba 0d 00 00       	call   801f27 <_panic>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
  80116d:	83 ec 04             	sub    $0x4,%esp
  801170:	68 f8 27 80 00       	push   $0x8027f8
  801175:	68 c9 00 00 00       	push   $0xc9
  80117a:	68 3f 28 80 00       	push   $0x80283f
  80117f:	e8 a3 0d 00 00       	call   801f27 <_panic>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
  801184:	83 ec 04             	sub    $0x4,%esp
  801187:	68 20 28 80 00       	push   $0x802820
  80118c:	68 cd 00 00 00       	push   $0xcd
  801191:	68 3f 28 80 00       	push   $0x80283f
  801196:	e8 8c 0d 00 00       	call   801f27 <_panic>

0080119b <sfork>:

// Challenge!
int
sfork(void)
{
  80119b:	f3 0f 1e fb          	endbr32 
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011a5:	68 4a 29 80 00       	push   $0x80294a
  8011aa:	68 d7 00 00 00       	push   $0xd7
  8011af:	68 3f 28 80 00       	push   $0x80283f
  8011b4:	e8 6e 0d 00 00       	call   801f27 <_panic>

008011b9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011b9:	f3 0f 1e fb          	endbr32 
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c3:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c8:	c1 e8 0c             	shr    $0xc,%eax
}
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011cd:	f3 0f 1e fb          	endbr32 
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  8011d7:	ff 75 08             	pushl  0x8(%ebp)
  8011da:	e8 da ff ff ff       	call   8011b9 <fd2num>
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	c1 e0 0c             	shl    $0xc,%eax
  8011e5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011ea:	c9                   	leave  
  8011eb:	c3                   	ret    

008011ec <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011ec:	f3 0f 1e fb          	endbr32 
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011f8:	89 c2                	mov    %eax,%edx
  8011fa:	c1 ea 16             	shr    $0x16,%edx
  8011fd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801204:	f6 c2 01             	test   $0x1,%dl
  801207:	74 2d                	je     801236 <fd_alloc+0x4a>
  801209:	89 c2                	mov    %eax,%edx
  80120b:	c1 ea 0c             	shr    $0xc,%edx
  80120e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801215:	f6 c2 01             	test   $0x1,%dl
  801218:	74 1c                	je     801236 <fd_alloc+0x4a>
  80121a:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80121f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801224:	75 d2                	jne    8011f8 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801226:	8b 45 08             	mov    0x8(%ebp),%eax
  801229:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80122f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801234:	eb 0a                	jmp    801240 <fd_alloc+0x54>
			*fd_store = fd;
  801236:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801239:	89 01                	mov    %eax,(%ecx)
			return 0;
  80123b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801242:	f3 0f 1e fb          	endbr32 
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80124c:	83 f8 1f             	cmp    $0x1f,%eax
  80124f:	77 30                	ja     801281 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801251:	c1 e0 0c             	shl    $0xc,%eax
  801254:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801259:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80125f:	f6 c2 01             	test   $0x1,%dl
  801262:	74 24                	je     801288 <fd_lookup+0x46>
  801264:	89 c2                	mov    %eax,%edx
  801266:	c1 ea 0c             	shr    $0xc,%edx
  801269:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801270:	f6 c2 01             	test   $0x1,%dl
  801273:	74 1a                	je     80128f <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801275:	8b 55 0c             	mov    0xc(%ebp),%edx
  801278:	89 02                	mov    %eax,(%edx)
	return 0;
  80127a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80127f:	5d                   	pop    %ebp
  801280:	c3                   	ret    
		return -E_INVAL;
  801281:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801286:	eb f7                	jmp    80127f <fd_lookup+0x3d>
		return -E_INVAL;
  801288:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128d:	eb f0                	jmp    80127f <fd_lookup+0x3d>
  80128f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801294:	eb e9                	jmp    80127f <fd_lookup+0x3d>

00801296 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801296:	f3 0f 1e fb          	endbr32 
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	83 ec 08             	sub    $0x8,%esp
  8012a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a3:	ba dc 29 80 00       	mov    $0x8029dc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012a8:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012ad:	39 08                	cmp    %ecx,(%eax)
  8012af:	74 33                	je     8012e4 <dev_lookup+0x4e>
  8012b1:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8012b4:	8b 02                	mov    (%edx),%eax
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	75 f3                	jne    8012ad <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012ba:	a1 04 40 80 00       	mov    0x804004,%eax
  8012bf:	8b 40 48             	mov    0x48(%eax),%eax
  8012c2:	83 ec 04             	sub    $0x4,%esp
  8012c5:	51                   	push   %ecx
  8012c6:	50                   	push   %eax
  8012c7:	68 60 29 80 00       	push   $0x802960
  8012cc:	e8 f1 ee ff ff       	call   8001c2 <cprintf>
	*dev = 0;
  8012d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012da:	83 c4 10             	add    $0x10,%esp
  8012dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012e2:	c9                   	leave  
  8012e3:	c3                   	ret    
			*dev = devtab[i];
  8012e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ee:	eb f2                	jmp    8012e2 <dev_lookup+0x4c>

008012f0 <fd_close>:
{
  8012f0:	f3 0f 1e fb          	endbr32 
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	57                   	push   %edi
  8012f8:	56                   	push   %esi
  8012f9:	53                   	push   %ebx
  8012fa:	83 ec 28             	sub    $0x28,%esp
  8012fd:	8b 75 08             	mov    0x8(%ebp),%esi
  801300:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801303:	56                   	push   %esi
  801304:	e8 b0 fe ff ff       	call   8011b9 <fd2num>
  801309:	83 c4 08             	add    $0x8,%esp
  80130c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80130f:	52                   	push   %edx
  801310:	50                   	push   %eax
  801311:	e8 2c ff ff ff       	call   801242 <fd_lookup>
  801316:	89 c3                	mov    %eax,%ebx
  801318:	83 c4 10             	add    $0x10,%esp
  80131b:	85 c0                	test   %eax,%eax
  80131d:	78 05                	js     801324 <fd_close+0x34>
	    || fd != fd2)
  80131f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801322:	74 16                	je     80133a <fd_close+0x4a>
		return (must_exist ? r : 0);
  801324:	89 f8                	mov    %edi,%eax
  801326:	84 c0                	test   %al,%al
  801328:	b8 00 00 00 00       	mov    $0x0,%eax
  80132d:	0f 44 d8             	cmove  %eax,%ebx
}
  801330:	89 d8                	mov    %ebx,%eax
  801332:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801335:	5b                   	pop    %ebx
  801336:	5e                   	pop    %esi
  801337:	5f                   	pop    %edi
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80133a:	83 ec 08             	sub    $0x8,%esp
  80133d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801340:	50                   	push   %eax
  801341:	ff 36                	pushl  (%esi)
  801343:	e8 4e ff ff ff       	call   801296 <dev_lookup>
  801348:	89 c3                	mov    %eax,%ebx
  80134a:	83 c4 10             	add    $0x10,%esp
  80134d:	85 c0                	test   %eax,%eax
  80134f:	78 1a                	js     80136b <fd_close+0x7b>
		if (dev->dev_close)
  801351:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801354:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801357:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80135c:	85 c0                	test   %eax,%eax
  80135e:	74 0b                	je     80136b <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801360:	83 ec 0c             	sub    $0xc,%esp
  801363:	56                   	push   %esi
  801364:	ff d0                	call   *%eax
  801366:	89 c3                	mov    %eax,%ebx
  801368:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80136b:	83 ec 08             	sub    $0x8,%esp
  80136e:	56                   	push   %esi
  80136f:	6a 00                	push   $0x0
  801371:	e8 90 f8 ff ff       	call   800c06 <sys_page_unmap>
	return r;
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	eb b5                	jmp    801330 <fd_close+0x40>

0080137b <close>:

int
close(int fdnum)
{
  80137b:	f3 0f 1e fb          	endbr32 
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801385:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801388:	50                   	push   %eax
  801389:	ff 75 08             	pushl  0x8(%ebp)
  80138c:	e8 b1 fe ff ff       	call   801242 <fd_lookup>
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	85 c0                	test   %eax,%eax
  801396:	79 02                	jns    80139a <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801398:	c9                   	leave  
  801399:	c3                   	ret    
		return fd_close(fd, 1);
  80139a:	83 ec 08             	sub    $0x8,%esp
  80139d:	6a 01                	push   $0x1
  80139f:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a2:	e8 49 ff ff ff       	call   8012f0 <fd_close>
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	eb ec                	jmp    801398 <close+0x1d>

008013ac <close_all>:

void
close_all(void)
{
  8013ac:	f3 0f 1e fb          	endbr32 
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	53                   	push   %ebx
  8013b4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013bc:	83 ec 0c             	sub    $0xc,%esp
  8013bf:	53                   	push   %ebx
  8013c0:	e8 b6 ff ff ff       	call   80137b <close>
	for (i = 0; i < MAXFD; i++)
  8013c5:	83 c3 01             	add    $0x1,%ebx
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	83 fb 20             	cmp    $0x20,%ebx
  8013ce:	75 ec                	jne    8013bc <close_all+0x10>
}
  8013d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d3:	c9                   	leave  
  8013d4:	c3                   	ret    

008013d5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013d5:	f3 0f 1e fb          	endbr32 
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	57                   	push   %edi
  8013dd:	56                   	push   %esi
  8013de:	53                   	push   %ebx
  8013df:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013e2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013e5:	50                   	push   %eax
  8013e6:	ff 75 08             	pushl  0x8(%ebp)
  8013e9:	e8 54 fe ff ff       	call   801242 <fd_lookup>
  8013ee:	89 c3                	mov    %eax,%ebx
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	0f 88 81 00 00 00    	js     80147c <dup+0xa7>
		return r;
	close(newfdnum);
  8013fb:	83 ec 0c             	sub    $0xc,%esp
  8013fe:	ff 75 0c             	pushl  0xc(%ebp)
  801401:	e8 75 ff ff ff       	call   80137b <close>

	newfd = INDEX2FD(newfdnum);
  801406:	8b 75 0c             	mov    0xc(%ebp),%esi
  801409:	c1 e6 0c             	shl    $0xc,%esi
  80140c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801412:	83 c4 04             	add    $0x4,%esp
  801415:	ff 75 e4             	pushl  -0x1c(%ebp)
  801418:	e8 b0 fd ff ff       	call   8011cd <fd2data>
  80141d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80141f:	89 34 24             	mov    %esi,(%esp)
  801422:	e8 a6 fd ff ff       	call   8011cd <fd2data>
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80142c:	89 d8                	mov    %ebx,%eax
  80142e:	c1 e8 16             	shr    $0x16,%eax
  801431:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801438:	a8 01                	test   $0x1,%al
  80143a:	74 11                	je     80144d <dup+0x78>
  80143c:	89 d8                	mov    %ebx,%eax
  80143e:	c1 e8 0c             	shr    $0xc,%eax
  801441:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801448:	f6 c2 01             	test   $0x1,%dl
  80144b:	75 39                	jne    801486 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80144d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801450:	89 d0                	mov    %edx,%eax
  801452:	c1 e8 0c             	shr    $0xc,%eax
  801455:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80145c:	83 ec 0c             	sub    $0xc,%esp
  80145f:	25 07 0e 00 00       	and    $0xe07,%eax
  801464:	50                   	push   %eax
  801465:	56                   	push   %esi
  801466:	6a 00                	push   $0x0
  801468:	52                   	push   %edx
  801469:	6a 00                	push   $0x0
  80146b:	e8 6c f7 ff ff       	call   800bdc <sys_page_map>
  801470:	89 c3                	mov    %eax,%ebx
  801472:	83 c4 20             	add    $0x20,%esp
  801475:	85 c0                	test   %eax,%eax
  801477:	78 31                	js     8014aa <dup+0xd5>
		goto err;

	return newfdnum;
  801479:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80147c:	89 d8                	mov    %ebx,%eax
  80147e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801481:	5b                   	pop    %ebx
  801482:	5e                   	pop    %esi
  801483:	5f                   	pop    %edi
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801486:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148d:	83 ec 0c             	sub    $0xc,%esp
  801490:	25 07 0e 00 00       	and    $0xe07,%eax
  801495:	50                   	push   %eax
  801496:	57                   	push   %edi
  801497:	6a 00                	push   $0x0
  801499:	53                   	push   %ebx
  80149a:	6a 00                	push   $0x0
  80149c:	e8 3b f7 ff ff       	call   800bdc <sys_page_map>
  8014a1:	89 c3                	mov    %eax,%ebx
  8014a3:	83 c4 20             	add    $0x20,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	79 a3                	jns    80144d <dup+0x78>
	sys_page_unmap(0, newfd);
  8014aa:	83 ec 08             	sub    $0x8,%esp
  8014ad:	56                   	push   %esi
  8014ae:	6a 00                	push   $0x0
  8014b0:	e8 51 f7 ff ff       	call   800c06 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014b5:	83 c4 08             	add    $0x8,%esp
  8014b8:	57                   	push   %edi
  8014b9:	6a 00                	push   $0x0
  8014bb:	e8 46 f7 ff ff       	call   800c06 <sys_page_unmap>
	return r;
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	eb b7                	jmp    80147c <dup+0xa7>

008014c5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014c5:	f3 0f 1e fb          	endbr32 
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
  8014cc:	53                   	push   %ebx
  8014cd:	83 ec 1c             	sub    $0x1c,%esp
  8014d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d6:	50                   	push   %eax
  8014d7:	53                   	push   %ebx
  8014d8:	e8 65 fd ff ff       	call   801242 <fd_lookup>
  8014dd:	83 c4 10             	add    $0x10,%esp
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	78 3f                	js     801523 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ea:	50                   	push   %eax
  8014eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ee:	ff 30                	pushl  (%eax)
  8014f0:	e8 a1 fd ff ff       	call   801296 <dev_lookup>
  8014f5:	83 c4 10             	add    $0x10,%esp
  8014f8:	85 c0                	test   %eax,%eax
  8014fa:	78 27                	js     801523 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ff:	8b 42 08             	mov    0x8(%edx),%eax
  801502:	83 e0 03             	and    $0x3,%eax
  801505:	83 f8 01             	cmp    $0x1,%eax
  801508:	74 1e                	je     801528 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80150a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150d:	8b 40 08             	mov    0x8(%eax),%eax
  801510:	85 c0                	test   %eax,%eax
  801512:	74 35                	je     801549 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801514:	83 ec 04             	sub    $0x4,%esp
  801517:	ff 75 10             	pushl  0x10(%ebp)
  80151a:	ff 75 0c             	pushl  0xc(%ebp)
  80151d:	52                   	push   %edx
  80151e:	ff d0                	call   *%eax
  801520:	83 c4 10             	add    $0x10,%esp
}
  801523:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801526:	c9                   	leave  
  801527:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801528:	a1 04 40 80 00       	mov    0x804004,%eax
  80152d:	8b 40 48             	mov    0x48(%eax),%eax
  801530:	83 ec 04             	sub    $0x4,%esp
  801533:	53                   	push   %ebx
  801534:	50                   	push   %eax
  801535:	68 a1 29 80 00       	push   $0x8029a1
  80153a:	e8 83 ec ff ff       	call   8001c2 <cprintf>
		return -E_INVAL;
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801547:	eb da                	jmp    801523 <read+0x5e>
		return -E_NOT_SUPP;
  801549:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80154e:	eb d3                	jmp    801523 <read+0x5e>

00801550 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801550:	f3 0f 1e fb          	endbr32 
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	57                   	push   %edi
  801558:	56                   	push   %esi
  801559:	53                   	push   %ebx
  80155a:	83 ec 0c             	sub    $0xc,%esp
  80155d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801560:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801563:	bb 00 00 00 00       	mov    $0x0,%ebx
  801568:	eb 02                	jmp    80156c <readn+0x1c>
  80156a:	01 c3                	add    %eax,%ebx
  80156c:	39 f3                	cmp    %esi,%ebx
  80156e:	73 21                	jae    801591 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801570:	83 ec 04             	sub    $0x4,%esp
  801573:	89 f0                	mov    %esi,%eax
  801575:	29 d8                	sub    %ebx,%eax
  801577:	50                   	push   %eax
  801578:	89 d8                	mov    %ebx,%eax
  80157a:	03 45 0c             	add    0xc(%ebp),%eax
  80157d:	50                   	push   %eax
  80157e:	57                   	push   %edi
  80157f:	e8 41 ff ff ff       	call   8014c5 <read>
		if (m < 0)
  801584:	83 c4 10             	add    $0x10,%esp
  801587:	85 c0                	test   %eax,%eax
  801589:	78 04                	js     80158f <readn+0x3f>
			return m;
		if (m == 0)
  80158b:	75 dd                	jne    80156a <readn+0x1a>
  80158d:	eb 02                	jmp    801591 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80158f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801591:	89 d8                	mov    %ebx,%eax
  801593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801596:	5b                   	pop    %ebx
  801597:	5e                   	pop    %esi
  801598:	5f                   	pop    %edi
  801599:	5d                   	pop    %ebp
  80159a:	c3                   	ret    

0080159b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80159b:	f3 0f 1e fb          	endbr32 
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	53                   	push   %ebx
  8015a3:	83 ec 1c             	sub    $0x1c,%esp
  8015a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ac:	50                   	push   %eax
  8015ad:	53                   	push   %ebx
  8015ae:	e8 8f fc ff ff       	call   801242 <fd_lookup>
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	78 3a                	js     8015f4 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ba:	83 ec 08             	sub    $0x8,%esp
  8015bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c0:	50                   	push   %eax
  8015c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c4:	ff 30                	pushl  (%eax)
  8015c6:	e8 cb fc ff ff       	call   801296 <dev_lookup>
  8015cb:	83 c4 10             	add    $0x10,%esp
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 22                	js     8015f4 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d9:	74 1e                	je     8015f9 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015de:	8b 52 0c             	mov    0xc(%edx),%edx
  8015e1:	85 d2                	test   %edx,%edx
  8015e3:	74 35                	je     80161a <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015e5:	83 ec 04             	sub    $0x4,%esp
  8015e8:	ff 75 10             	pushl  0x10(%ebp)
  8015eb:	ff 75 0c             	pushl  0xc(%ebp)
  8015ee:	50                   	push   %eax
  8015ef:	ff d2                	call   *%edx
  8015f1:	83 c4 10             	add    $0x10,%esp
}
  8015f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f7:	c9                   	leave  
  8015f8:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8015fe:	8b 40 48             	mov    0x48(%eax),%eax
  801601:	83 ec 04             	sub    $0x4,%esp
  801604:	53                   	push   %ebx
  801605:	50                   	push   %eax
  801606:	68 bd 29 80 00       	push   $0x8029bd
  80160b:	e8 b2 eb ff ff       	call   8001c2 <cprintf>
		return -E_INVAL;
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801618:	eb da                	jmp    8015f4 <write+0x59>
		return -E_NOT_SUPP;
  80161a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80161f:	eb d3                	jmp    8015f4 <write+0x59>

00801621 <seek>:

int
seek(int fdnum, off_t offset)
{
  801621:	f3 0f 1e fb          	endbr32 
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80162b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162e:	50                   	push   %eax
  80162f:	ff 75 08             	pushl  0x8(%ebp)
  801632:	e8 0b fc ff ff       	call   801242 <fd_lookup>
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	85 c0                	test   %eax,%eax
  80163c:	78 0e                	js     80164c <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80163e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801641:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801644:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801647:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80164c:	c9                   	leave  
  80164d:	c3                   	ret    

0080164e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80164e:	f3 0f 1e fb          	endbr32 
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	53                   	push   %ebx
  801656:	83 ec 1c             	sub    $0x1c,%esp
  801659:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165f:	50                   	push   %eax
  801660:	53                   	push   %ebx
  801661:	e8 dc fb ff ff       	call   801242 <fd_lookup>
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	85 c0                	test   %eax,%eax
  80166b:	78 37                	js     8016a4 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166d:	83 ec 08             	sub    $0x8,%esp
  801670:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801673:	50                   	push   %eax
  801674:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801677:	ff 30                	pushl  (%eax)
  801679:	e8 18 fc ff ff       	call   801296 <dev_lookup>
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	85 c0                	test   %eax,%eax
  801683:	78 1f                	js     8016a4 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801685:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801688:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80168c:	74 1b                	je     8016a9 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80168e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801691:	8b 52 18             	mov    0x18(%edx),%edx
  801694:	85 d2                	test   %edx,%edx
  801696:	74 32                	je     8016ca <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801698:	83 ec 08             	sub    $0x8,%esp
  80169b:	ff 75 0c             	pushl  0xc(%ebp)
  80169e:	50                   	push   %eax
  80169f:	ff d2                	call   *%edx
  8016a1:	83 c4 10             	add    $0x10,%esp
}
  8016a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a7:	c9                   	leave  
  8016a8:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016a9:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016ae:	8b 40 48             	mov    0x48(%eax),%eax
  8016b1:	83 ec 04             	sub    $0x4,%esp
  8016b4:	53                   	push   %ebx
  8016b5:	50                   	push   %eax
  8016b6:	68 80 29 80 00       	push   $0x802980
  8016bb:	e8 02 eb ff ff       	call   8001c2 <cprintf>
		return -E_INVAL;
  8016c0:	83 c4 10             	add    $0x10,%esp
  8016c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016c8:	eb da                	jmp    8016a4 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8016ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016cf:	eb d3                	jmp    8016a4 <ftruncate+0x56>

008016d1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016d1:	f3 0f 1e fb          	endbr32 
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 1c             	sub    $0x1c,%esp
  8016dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e2:	50                   	push   %eax
  8016e3:	ff 75 08             	pushl  0x8(%ebp)
  8016e6:	e8 57 fb ff ff       	call   801242 <fd_lookup>
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 4b                	js     80173d <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f2:	83 ec 08             	sub    $0x8,%esp
  8016f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f8:	50                   	push   %eax
  8016f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fc:	ff 30                	pushl  (%eax)
  8016fe:	e8 93 fb ff ff       	call   801296 <dev_lookup>
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	85 c0                	test   %eax,%eax
  801708:	78 33                	js     80173d <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80170a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801711:	74 2f                	je     801742 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801713:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801716:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80171d:	00 00 00 
	stat->st_isdir = 0;
  801720:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801727:	00 00 00 
	stat->st_dev = dev;
  80172a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801730:	83 ec 08             	sub    $0x8,%esp
  801733:	53                   	push   %ebx
  801734:	ff 75 f0             	pushl  -0x10(%ebp)
  801737:	ff 50 14             	call   *0x14(%eax)
  80173a:	83 c4 10             	add    $0x10,%esp
}
  80173d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801740:	c9                   	leave  
  801741:	c3                   	ret    
		return -E_NOT_SUPP;
  801742:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801747:	eb f4                	jmp    80173d <fstat+0x6c>

00801749 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801749:	f3 0f 1e fb          	endbr32 
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	56                   	push   %esi
  801751:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801752:	83 ec 08             	sub    $0x8,%esp
  801755:	6a 00                	push   $0x0
  801757:	ff 75 08             	pushl  0x8(%ebp)
  80175a:	e8 20 02 00 00       	call   80197f <open>
  80175f:	89 c3                	mov    %eax,%ebx
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	85 c0                	test   %eax,%eax
  801766:	78 1b                	js     801783 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801768:	83 ec 08             	sub    $0x8,%esp
  80176b:	ff 75 0c             	pushl  0xc(%ebp)
  80176e:	50                   	push   %eax
  80176f:	e8 5d ff ff ff       	call   8016d1 <fstat>
  801774:	89 c6                	mov    %eax,%esi
	close(fd);
  801776:	89 1c 24             	mov    %ebx,(%esp)
  801779:	e8 fd fb ff ff       	call   80137b <close>
	return r;
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	89 f3                	mov    %esi,%ebx
}
  801783:	89 d8                	mov    %ebx,%eax
  801785:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801788:	5b                   	pop    %ebx
  801789:	5e                   	pop    %esi
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	56                   	push   %esi
  801790:	53                   	push   %ebx
  801791:	89 c6                	mov    %eax,%esi
  801793:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801795:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80179c:	74 27                	je     8017c5 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80179e:	6a 07                	push   $0x7
  8017a0:	68 00 50 80 00       	push   $0x805000
  8017a5:	56                   	push   %esi
  8017a6:	ff 35 00 40 80 00    	pushl  0x804000
  8017ac:	e8 c6 08 00 00       	call   802077 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017b1:	83 c4 0c             	add    $0xc,%esp
  8017b4:	6a 00                	push   $0x0
  8017b6:	53                   	push   %ebx
  8017b7:	6a 00                	push   $0x0
  8017b9:	e8 4c 08 00 00       	call   80200a <ipc_recv>
}
  8017be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c1:	5b                   	pop    %ebx
  8017c2:	5e                   	pop    %esi
  8017c3:	5d                   	pop    %ebp
  8017c4:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017c5:	83 ec 0c             	sub    $0xc,%esp
  8017c8:	6a 01                	push   $0x1
  8017ca:	e8 fb 08 00 00       	call   8020ca <ipc_find_env>
  8017cf:	a3 00 40 80 00       	mov    %eax,0x804000
  8017d4:	83 c4 10             	add    $0x10,%esp
  8017d7:	eb c5                	jmp    80179e <fsipc+0x12>

008017d9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017d9:	f3 0f 1e fb          	endbr32 
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fb:	b8 02 00 00 00       	mov    $0x2,%eax
  801800:	e8 87 ff ff ff       	call   80178c <fsipc>
}
  801805:	c9                   	leave  
  801806:	c3                   	ret    

00801807 <devfile_flush>:
{
  801807:	f3 0f 1e fb          	endbr32 
  80180b:	55                   	push   %ebp
  80180c:	89 e5                	mov    %esp,%ebp
  80180e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	8b 40 0c             	mov    0xc(%eax),%eax
  801817:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80181c:	ba 00 00 00 00       	mov    $0x0,%edx
  801821:	b8 06 00 00 00       	mov    $0x6,%eax
  801826:	e8 61 ff ff ff       	call   80178c <fsipc>
}
  80182b:	c9                   	leave  
  80182c:	c3                   	ret    

0080182d <devfile_stat>:
{
  80182d:	f3 0f 1e fb          	endbr32 
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	53                   	push   %ebx
  801835:	83 ec 04             	sub    $0x4,%esp
  801838:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80183b:	8b 45 08             	mov    0x8(%ebp),%eax
  80183e:	8b 40 0c             	mov    0xc(%eax),%eax
  801841:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801846:	ba 00 00 00 00       	mov    $0x0,%edx
  80184b:	b8 05 00 00 00       	mov    $0x5,%eax
  801850:	e8 37 ff ff ff       	call   80178c <fsipc>
  801855:	85 c0                	test   %eax,%eax
  801857:	78 2c                	js     801885 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801859:	83 ec 08             	sub    $0x8,%esp
  80185c:	68 00 50 80 00       	push   $0x805000
  801861:	53                   	push   %ebx
  801862:	e8 c5 ee ff ff       	call   80072c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801867:	a1 80 50 80 00       	mov    0x805080,%eax
  80186c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801872:	a1 84 50 80 00       	mov    0x805084,%eax
  801877:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801885:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801888:	c9                   	leave  
  801889:	c3                   	ret    

0080188a <devfile_write>:
{
  80188a:	f3 0f 1e fb          	endbr32 
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	57                   	push   %edi
  801892:	56                   	push   %esi
  801893:	53                   	push   %ebx
  801894:	83 ec 0c             	sub    $0xc,%esp
  801897:	8b 75 0c             	mov    0xc(%ebp),%esi
  80189a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80189d:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a3:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  8018a8:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8018ad:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  8018b2:	85 db                	test   %ebx,%ebx
  8018b4:	74 3b                	je     8018f1 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8018b6:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8018bc:	89 f8                	mov    %edi,%eax
  8018be:	0f 46 c3             	cmovbe %ebx,%eax
  8018c1:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  8018c6:	83 ec 04             	sub    $0x4,%esp
  8018c9:	50                   	push   %eax
  8018ca:	56                   	push   %esi
  8018cb:	68 08 50 80 00       	push   $0x805008
  8018d0:	e8 0f f0 ff ff       	call   8008e4 <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8018d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018da:	b8 04 00 00 00       	mov    $0x4,%eax
  8018df:	e8 a8 fe ff ff       	call   80178c <fsipc>
  8018e4:	83 c4 10             	add    $0x10,%esp
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	78 06                	js     8018f1 <devfile_write+0x67>
		buf_aux += r;
  8018eb:	01 c6                	add    %eax,%esi
		n -= r;
  8018ed:	29 c3                	sub    %eax,%ebx
  8018ef:	eb c1                	jmp    8018b2 <devfile_write+0x28>
}
  8018f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5e                   	pop    %esi
  8018f6:	5f                   	pop    %edi
  8018f7:	5d                   	pop    %ebp
  8018f8:	c3                   	ret    

008018f9 <devfile_read>:
{
  8018f9:	f3 0f 1e fb          	endbr32 
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	56                   	push   %esi
  801901:	53                   	push   %ebx
  801902:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801905:	8b 45 08             	mov    0x8(%ebp),%eax
  801908:	8b 40 0c             	mov    0xc(%eax),%eax
  80190b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801910:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801916:	ba 00 00 00 00       	mov    $0x0,%edx
  80191b:	b8 03 00 00 00       	mov    $0x3,%eax
  801920:	e8 67 fe ff ff       	call   80178c <fsipc>
  801925:	89 c3                	mov    %eax,%ebx
  801927:	85 c0                	test   %eax,%eax
  801929:	78 1f                	js     80194a <devfile_read+0x51>
	assert(r <= n);
  80192b:	39 f0                	cmp    %esi,%eax
  80192d:	77 24                	ja     801953 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80192f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801934:	7f 33                	jg     801969 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801936:	83 ec 04             	sub    $0x4,%esp
  801939:	50                   	push   %eax
  80193a:	68 00 50 80 00       	push   $0x805000
  80193f:	ff 75 0c             	pushl  0xc(%ebp)
  801942:	e8 9d ef ff ff       	call   8008e4 <memmove>
	return r;
  801947:	83 c4 10             	add    $0x10,%esp
}
  80194a:	89 d8                	mov    %ebx,%eax
  80194c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194f:	5b                   	pop    %ebx
  801950:	5e                   	pop    %esi
  801951:	5d                   	pop    %ebp
  801952:	c3                   	ret    
	assert(r <= n);
  801953:	68 ec 29 80 00       	push   $0x8029ec
  801958:	68 f3 29 80 00       	push   $0x8029f3
  80195d:	6a 7c                	push   $0x7c
  80195f:	68 08 2a 80 00       	push   $0x802a08
  801964:	e8 be 05 00 00       	call   801f27 <_panic>
	assert(r <= PGSIZE);
  801969:	68 13 2a 80 00       	push   $0x802a13
  80196e:	68 f3 29 80 00       	push   $0x8029f3
  801973:	6a 7d                	push   $0x7d
  801975:	68 08 2a 80 00       	push   $0x802a08
  80197a:	e8 a8 05 00 00       	call   801f27 <_panic>

0080197f <open>:
{
  80197f:	f3 0f 1e fb          	endbr32 
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	56                   	push   %esi
  801987:	53                   	push   %ebx
  801988:	83 ec 1c             	sub    $0x1c,%esp
  80198b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80198e:	56                   	push   %esi
  80198f:	e8 55 ed ff ff       	call   8006e9 <strlen>
  801994:	83 c4 10             	add    $0x10,%esp
  801997:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80199c:	7f 6c                	jg     801a0a <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80199e:	83 ec 0c             	sub    $0xc,%esp
  8019a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a4:	50                   	push   %eax
  8019a5:	e8 42 f8 ff ff       	call   8011ec <fd_alloc>
  8019aa:	89 c3                	mov    %eax,%ebx
  8019ac:	83 c4 10             	add    $0x10,%esp
  8019af:	85 c0                	test   %eax,%eax
  8019b1:	78 3c                	js     8019ef <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8019b3:	83 ec 08             	sub    $0x8,%esp
  8019b6:	56                   	push   %esi
  8019b7:	68 00 50 80 00       	push   $0x805000
  8019bc:	e8 6b ed ff ff       	call   80072c <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c4:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8019d1:	e8 b6 fd ff ff       	call   80178c <fsipc>
  8019d6:	89 c3                	mov    %eax,%ebx
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	85 c0                	test   %eax,%eax
  8019dd:	78 19                	js     8019f8 <open+0x79>
	return fd2num(fd);
  8019df:	83 ec 0c             	sub    $0xc,%esp
  8019e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e5:	e8 cf f7 ff ff       	call   8011b9 <fd2num>
  8019ea:	89 c3                	mov    %eax,%ebx
  8019ec:	83 c4 10             	add    $0x10,%esp
}
  8019ef:	89 d8                	mov    %ebx,%eax
  8019f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f4:	5b                   	pop    %ebx
  8019f5:	5e                   	pop    %esi
  8019f6:	5d                   	pop    %ebp
  8019f7:	c3                   	ret    
		fd_close(fd, 0);
  8019f8:	83 ec 08             	sub    $0x8,%esp
  8019fb:	6a 00                	push   $0x0
  8019fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801a00:	e8 eb f8 ff ff       	call   8012f0 <fd_close>
		return r;
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	eb e5                	jmp    8019ef <open+0x70>
		return -E_BAD_PATH;
  801a0a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a0f:	eb de                	jmp    8019ef <open+0x70>

00801a11 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a11:	f3 0f 1e fb          	endbr32 
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a20:	b8 08 00 00 00       	mov    $0x8,%eax
  801a25:	e8 62 fd ff ff       	call   80178c <fsipc>
}
  801a2a:	c9                   	leave  
  801a2b:	c3                   	ret    

00801a2c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a2c:	f3 0f 1e fb          	endbr32 
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	56                   	push   %esi
  801a34:	53                   	push   %ebx
  801a35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a38:	83 ec 0c             	sub    $0xc,%esp
  801a3b:	ff 75 08             	pushl  0x8(%ebp)
  801a3e:	e8 8a f7 ff ff       	call   8011cd <fd2data>
  801a43:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a45:	83 c4 08             	add    $0x8,%esp
  801a48:	68 1f 2a 80 00       	push   $0x802a1f
  801a4d:	53                   	push   %ebx
  801a4e:	e8 d9 ec ff ff       	call   80072c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a53:	8b 46 04             	mov    0x4(%esi),%eax
  801a56:	2b 06                	sub    (%esi),%eax
  801a58:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a5e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a65:	00 00 00 
	stat->st_dev = &devpipe;
  801a68:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a6f:	30 80 00 
	return 0;
}
  801a72:	b8 00 00 00 00       	mov    $0x0,%eax
  801a77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7a:	5b                   	pop    %ebx
  801a7b:	5e                   	pop    %esi
  801a7c:	5d                   	pop    %ebp
  801a7d:	c3                   	ret    

00801a7e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a7e:	f3 0f 1e fb          	endbr32 
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	53                   	push   %ebx
  801a86:	83 ec 0c             	sub    $0xc,%esp
  801a89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a8c:	53                   	push   %ebx
  801a8d:	6a 00                	push   $0x0
  801a8f:	e8 72 f1 ff ff       	call   800c06 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a94:	89 1c 24             	mov    %ebx,(%esp)
  801a97:	e8 31 f7 ff ff       	call   8011cd <fd2data>
  801a9c:	83 c4 08             	add    $0x8,%esp
  801a9f:	50                   	push   %eax
  801aa0:	6a 00                	push   $0x0
  801aa2:	e8 5f f1 ff ff       	call   800c06 <sys_page_unmap>
}
  801aa7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aaa:	c9                   	leave  
  801aab:	c3                   	ret    

00801aac <_pipeisclosed>:
{
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
  801aaf:	57                   	push   %edi
  801ab0:	56                   	push   %esi
  801ab1:	53                   	push   %ebx
  801ab2:	83 ec 1c             	sub    $0x1c,%esp
  801ab5:	89 c7                	mov    %eax,%edi
  801ab7:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801ab9:	a1 04 40 80 00       	mov    0x804004,%eax
  801abe:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ac1:	83 ec 0c             	sub    $0xc,%esp
  801ac4:	57                   	push   %edi
  801ac5:	e8 3d 06 00 00       	call   802107 <pageref>
  801aca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801acd:	89 34 24             	mov    %esi,(%esp)
  801ad0:	e8 32 06 00 00       	call   802107 <pageref>
		nn = thisenv->env_runs;
  801ad5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801adb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ade:	83 c4 10             	add    $0x10,%esp
  801ae1:	39 cb                	cmp    %ecx,%ebx
  801ae3:	74 1b                	je     801b00 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801ae5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ae8:	75 cf                	jne    801ab9 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aea:	8b 42 58             	mov    0x58(%edx),%eax
  801aed:	6a 01                	push   $0x1
  801aef:	50                   	push   %eax
  801af0:	53                   	push   %ebx
  801af1:	68 26 2a 80 00       	push   $0x802a26
  801af6:	e8 c7 e6 ff ff       	call   8001c2 <cprintf>
  801afb:	83 c4 10             	add    $0x10,%esp
  801afe:	eb b9                	jmp    801ab9 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b00:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b03:	0f 94 c0             	sete   %al
  801b06:	0f b6 c0             	movzbl %al,%eax
}
  801b09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0c:	5b                   	pop    %ebx
  801b0d:	5e                   	pop    %esi
  801b0e:	5f                   	pop    %edi
  801b0f:	5d                   	pop    %ebp
  801b10:	c3                   	ret    

00801b11 <devpipe_write>:
{
  801b11:	f3 0f 1e fb          	endbr32 
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	57                   	push   %edi
  801b19:	56                   	push   %esi
  801b1a:	53                   	push   %ebx
  801b1b:	83 ec 28             	sub    $0x28,%esp
  801b1e:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b21:	56                   	push   %esi
  801b22:	e8 a6 f6 ff ff       	call   8011cd <fd2data>
  801b27:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b29:	83 c4 10             	add    $0x10,%esp
  801b2c:	bf 00 00 00 00       	mov    $0x0,%edi
  801b31:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b34:	74 4f                	je     801b85 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b36:	8b 43 04             	mov    0x4(%ebx),%eax
  801b39:	8b 0b                	mov    (%ebx),%ecx
  801b3b:	8d 51 20             	lea    0x20(%ecx),%edx
  801b3e:	39 d0                	cmp    %edx,%eax
  801b40:	72 14                	jb     801b56 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801b42:	89 da                	mov    %ebx,%edx
  801b44:	89 f0                	mov    %esi,%eax
  801b46:	e8 61 ff ff ff       	call   801aac <_pipeisclosed>
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	75 3b                	jne    801b8a <devpipe_write+0x79>
			sys_yield();
  801b4f:	e8 35 f0 ff ff       	call   800b89 <sys_yield>
  801b54:	eb e0                	jmp    801b36 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b59:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b5d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b60:	89 c2                	mov    %eax,%edx
  801b62:	c1 fa 1f             	sar    $0x1f,%edx
  801b65:	89 d1                	mov    %edx,%ecx
  801b67:	c1 e9 1b             	shr    $0x1b,%ecx
  801b6a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b6d:	83 e2 1f             	and    $0x1f,%edx
  801b70:	29 ca                	sub    %ecx,%edx
  801b72:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b76:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b7a:	83 c0 01             	add    $0x1,%eax
  801b7d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b80:	83 c7 01             	add    $0x1,%edi
  801b83:	eb ac                	jmp    801b31 <devpipe_write+0x20>
	return i;
  801b85:	8b 45 10             	mov    0x10(%ebp),%eax
  801b88:	eb 05                	jmp    801b8f <devpipe_write+0x7e>
				return 0;
  801b8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b92:	5b                   	pop    %ebx
  801b93:	5e                   	pop    %esi
  801b94:	5f                   	pop    %edi
  801b95:	5d                   	pop    %ebp
  801b96:	c3                   	ret    

00801b97 <devpipe_read>:
{
  801b97:	f3 0f 1e fb          	endbr32 
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	57                   	push   %edi
  801b9f:	56                   	push   %esi
  801ba0:	53                   	push   %ebx
  801ba1:	83 ec 18             	sub    $0x18,%esp
  801ba4:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801ba7:	57                   	push   %edi
  801ba8:	e8 20 f6 ff ff       	call   8011cd <fd2data>
  801bad:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801baf:	83 c4 10             	add    $0x10,%esp
  801bb2:	be 00 00 00 00       	mov    $0x0,%esi
  801bb7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bba:	75 14                	jne    801bd0 <devpipe_read+0x39>
	return i;
  801bbc:	8b 45 10             	mov    0x10(%ebp),%eax
  801bbf:	eb 02                	jmp    801bc3 <devpipe_read+0x2c>
				return i;
  801bc1:	89 f0                	mov    %esi,%eax
}
  801bc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc6:	5b                   	pop    %ebx
  801bc7:	5e                   	pop    %esi
  801bc8:	5f                   	pop    %edi
  801bc9:	5d                   	pop    %ebp
  801bca:	c3                   	ret    
			sys_yield();
  801bcb:	e8 b9 ef ff ff       	call   800b89 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801bd0:	8b 03                	mov    (%ebx),%eax
  801bd2:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bd5:	75 18                	jne    801bef <devpipe_read+0x58>
			if (i > 0)
  801bd7:	85 f6                	test   %esi,%esi
  801bd9:	75 e6                	jne    801bc1 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801bdb:	89 da                	mov    %ebx,%edx
  801bdd:	89 f8                	mov    %edi,%eax
  801bdf:	e8 c8 fe ff ff       	call   801aac <_pipeisclosed>
  801be4:	85 c0                	test   %eax,%eax
  801be6:	74 e3                	je     801bcb <devpipe_read+0x34>
				return 0;
  801be8:	b8 00 00 00 00       	mov    $0x0,%eax
  801bed:	eb d4                	jmp    801bc3 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bef:	99                   	cltd   
  801bf0:	c1 ea 1b             	shr    $0x1b,%edx
  801bf3:	01 d0                	add    %edx,%eax
  801bf5:	83 e0 1f             	and    $0x1f,%eax
  801bf8:	29 d0                	sub    %edx,%eax
  801bfa:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c02:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c05:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c08:	83 c6 01             	add    $0x1,%esi
  801c0b:	eb aa                	jmp    801bb7 <devpipe_read+0x20>

00801c0d <pipe>:
{
  801c0d:	f3 0f 1e fb          	endbr32 
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	56                   	push   %esi
  801c15:	53                   	push   %ebx
  801c16:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c1c:	50                   	push   %eax
  801c1d:	e8 ca f5 ff ff       	call   8011ec <fd_alloc>
  801c22:	89 c3                	mov    %eax,%ebx
  801c24:	83 c4 10             	add    $0x10,%esp
  801c27:	85 c0                	test   %eax,%eax
  801c29:	0f 88 23 01 00 00    	js     801d52 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2f:	83 ec 04             	sub    $0x4,%esp
  801c32:	68 07 04 00 00       	push   $0x407
  801c37:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3a:	6a 00                	push   $0x0
  801c3c:	e8 73 ef ff ff       	call   800bb4 <sys_page_alloc>
  801c41:	89 c3                	mov    %eax,%ebx
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	85 c0                	test   %eax,%eax
  801c48:	0f 88 04 01 00 00    	js     801d52 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801c4e:	83 ec 0c             	sub    $0xc,%esp
  801c51:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c54:	50                   	push   %eax
  801c55:	e8 92 f5 ff ff       	call   8011ec <fd_alloc>
  801c5a:	89 c3                	mov    %eax,%ebx
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	0f 88 db 00 00 00    	js     801d42 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c67:	83 ec 04             	sub    $0x4,%esp
  801c6a:	68 07 04 00 00       	push   $0x407
  801c6f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c72:	6a 00                	push   $0x0
  801c74:	e8 3b ef ff ff       	call   800bb4 <sys_page_alloc>
  801c79:	89 c3                	mov    %eax,%ebx
  801c7b:	83 c4 10             	add    $0x10,%esp
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	0f 88 bc 00 00 00    	js     801d42 <pipe+0x135>
	va = fd2data(fd0);
  801c86:	83 ec 0c             	sub    $0xc,%esp
  801c89:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8c:	e8 3c f5 ff ff       	call   8011cd <fd2data>
  801c91:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c93:	83 c4 0c             	add    $0xc,%esp
  801c96:	68 07 04 00 00       	push   $0x407
  801c9b:	50                   	push   %eax
  801c9c:	6a 00                	push   $0x0
  801c9e:	e8 11 ef ff ff       	call   800bb4 <sys_page_alloc>
  801ca3:	89 c3                	mov    %eax,%ebx
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	0f 88 82 00 00 00    	js     801d32 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb0:	83 ec 0c             	sub    $0xc,%esp
  801cb3:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb6:	e8 12 f5 ff ff       	call   8011cd <fd2data>
  801cbb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cc2:	50                   	push   %eax
  801cc3:	6a 00                	push   $0x0
  801cc5:	56                   	push   %esi
  801cc6:	6a 00                	push   $0x0
  801cc8:	e8 0f ef ff ff       	call   800bdc <sys_page_map>
  801ccd:	89 c3                	mov    %eax,%ebx
  801ccf:	83 c4 20             	add    $0x20,%esp
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	78 4e                	js     801d24 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801cd6:	a1 20 30 80 00       	mov    0x803020,%eax
  801cdb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cde:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801ce0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ce3:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801cea:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ced:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801cf9:	83 ec 0c             	sub    $0xc,%esp
  801cfc:	ff 75 f4             	pushl  -0xc(%ebp)
  801cff:	e8 b5 f4 ff ff       	call   8011b9 <fd2num>
  801d04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d07:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d09:	83 c4 04             	add    $0x4,%esp
  801d0c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d0f:	e8 a5 f4 ff ff       	call   8011b9 <fd2num>
  801d14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d17:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d22:	eb 2e                	jmp    801d52 <pipe+0x145>
	sys_page_unmap(0, va);
  801d24:	83 ec 08             	sub    $0x8,%esp
  801d27:	56                   	push   %esi
  801d28:	6a 00                	push   $0x0
  801d2a:	e8 d7 ee ff ff       	call   800c06 <sys_page_unmap>
  801d2f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d32:	83 ec 08             	sub    $0x8,%esp
  801d35:	ff 75 f0             	pushl  -0x10(%ebp)
  801d38:	6a 00                	push   $0x0
  801d3a:	e8 c7 ee ff ff       	call   800c06 <sys_page_unmap>
  801d3f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d42:	83 ec 08             	sub    $0x8,%esp
  801d45:	ff 75 f4             	pushl  -0xc(%ebp)
  801d48:	6a 00                	push   $0x0
  801d4a:	e8 b7 ee ff ff       	call   800c06 <sys_page_unmap>
  801d4f:	83 c4 10             	add    $0x10,%esp
}
  801d52:	89 d8                	mov    %ebx,%eax
  801d54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5d                   	pop    %ebp
  801d5a:	c3                   	ret    

00801d5b <pipeisclosed>:
{
  801d5b:	f3 0f 1e fb          	endbr32 
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d68:	50                   	push   %eax
  801d69:	ff 75 08             	pushl  0x8(%ebp)
  801d6c:	e8 d1 f4 ff ff       	call   801242 <fd_lookup>
  801d71:	83 c4 10             	add    $0x10,%esp
  801d74:	85 c0                	test   %eax,%eax
  801d76:	78 18                	js     801d90 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801d78:	83 ec 0c             	sub    $0xc,%esp
  801d7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7e:	e8 4a f4 ff ff       	call   8011cd <fd2data>
  801d83:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d88:	e8 1f fd ff ff       	call   801aac <_pipeisclosed>
  801d8d:	83 c4 10             	add    $0x10,%esp
}
  801d90:	c9                   	leave  
  801d91:	c3                   	ret    

00801d92 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d92:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801d96:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9b:	c3                   	ret    

00801d9c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d9c:	f3 0f 1e fb          	endbr32 
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801da6:	68 3e 2a 80 00       	push   $0x802a3e
  801dab:	ff 75 0c             	pushl  0xc(%ebp)
  801dae:	e8 79 e9 ff ff       	call   80072c <strcpy>
	return 0;
}
  801db3:	b8 00 00 00 00       	mov    $0x0,%eax
  801db8:	c9                   	leave  
  801db9:	c3                   	ret    

00801dba <devcons_write>:
{
  801dba:	f3 0f 1e fb          	endbr32 
  801dbe:	55                   	push   %ebp
  801dbf:	89 e5                	mov    %esp,%ebp
  801dc1:	57                   	push   %edi
  801dc2:	56                   	push   %esi
  801dc3:	53                   	push   %ebx
  801dc4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801dca:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801dcf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801dd5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dd8:	73 31                	jae    801e0b <devcons_write+0x51>
		m = n - tot;
  801dda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ddd:	29 f3                	sub    %esi,%ebx
  801ddf:	83 fb 7f             	cmp    $0x7f,%ebx
  801de2:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801de7:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801dea:	83 ec 04             	sub    $0x4,%esp
  801ded:	53                   	push   %ebx
  801dee:	89 f0                	mov    %esi,%eax
  801df0:	03 45 0c             	add    0xc(%ebp),%eax
  801df3:	50                   	push   %eax
  801df4:	57                   	push   %edi
  801df5:	e8 ea ea ff ff       	call   8008e4 <memmove>
		sys_cputs(buf, m);
  801dfa:	83 c4 08             	add    $0x8,%esp
  801dfd:	53                   	push   %ebx
  801dfe:	57                   	push   %edi
  801dff:	e8 e5 ec ff ff       	call   800ae9 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e04:	01 de                	add    %ebx,%esi
  801e06:	83 c4 10             	add    $0x10,%esp
  801e09:	eb ca                	jmp    801dd5 <devcons_write+0x1b>
}
  801e0b:	89 f0                	mov    %esi,%eax
  801e0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e10:	5b                   	pop    %ebx
  801e11:	5e                   	pop    %esi
  801e12:	5f                   	pop    %edi
  801e13:	5d                   	pop    %ebp
  801e14:	c3                   	ret    

00801e15 <devcons_read>:
{
  801e15:	f3 0f 1e fb          	endbr32 
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	83 ec 08             	sub    $0x8,%esp
  801e1f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e24:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e28:	74 21                	je     801e4b <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801e2a:	e8 e4 ec ff ff       	call   800b13 <sys_cgetc>
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	75 07                	jne    801e3a <devcons_read+0x25>
		sys_yield();
  801e33:	e8 51 ed ff ff       	call   800b89 <sys_yield>
  801e38:	eb f0                	jmp    801e2a <devcons_read+0x15>
	if (c < 0)
  801e3a:	78 0f                	js     801e4b <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801e3c:	83 f8 04             	cmp    $0x4,%eax
  801e3f:	74 0c                	je     801e4d <devcons_read+0x38>
	*(char*)vbuf = c;
  801e41:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e44:	88 02                	mov    %al,(%edx)
	return 1;
  801e46:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801e4b:	c9                   	leave  
  801e4c:	c3                   	ret    
		return 0;
  801e4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e52:	eb f7                	jmp    801e4b <devcons_read+0x36>

00801e54 <cputchar>:
{
  801e54:	f3 0f 1e fb          	endbr32 
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e61:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e64:	6a 01                	push   $0x1
  801e66:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e69:	50                   	push   %eax
  801e6a:	e8 7a ec ff ff       	call   800ae9 <sys_cputs>
}
  801e6f:	83 c4 10             	add    $0x10,%esp
  801e72:	c9                   	leave  
  801e73:	c3                   	ret    

00801e74 <getchar>:
{
  801e74:	f3 0f 1e fb          	endbr32 
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e7e:	6a 01                	push   $0x1
  801e80:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e83:	50                   	push   %eax
  801e84:	6a 00                	push   $0x0
  801e86:	e8 3a f6 ff ff       	call   8014c5 <read>
	if (r < 0)
  801e8b:	83 c4 10             	add    $0x10,%esp
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	78 06                	js     801e98 <getchar+0x24>
	if (r < 1)
  801e92:	74 06                	je     801e9a <getchar+0x26>
	return c;
  801e94:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e98:	c9                   	leave  
  801e99:	c3                   	ret    
		return -E_EOF;
  801e9a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e9f:	eb f7                	jmp    801e98 <getchar+0x24>

00801ea1 <iscons>:
{
  801ea1:	f3 0f 1e fb          	endbr32 
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eae:	50                   	push   %eax
  801eaf:	ff 75 08             	pushl  0x8(%ebp)
  801eb2:	e8 8b f3 ff ff       	call   801242 <fd_lookup>
  801eb7:	83 c4 10             	add    $0x10,%esp
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	78 11                	js     801ecf <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ec7:	39 10                	cmp    %edx,(%eax)
  801ec9:	0f 94 c0             	sete   %al
  801ecc:	0f b6 c0             	movzbl %al,%eax
}
  801ecf:	c9                   	leave  
  801ed0:	c3                   	ret    

00801ed1 <opencons>:
{
  801ed1:	f3 0f 1e fb          	endbr32 
  801ed5:	55                   	push   %ebp
  801ed6:	89 e5                	mov    %esp,%ebp
  801ed8:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801edb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ede:	50                   	push   %eax
  801edf:	e8 08 f3 ff ff       	call   8011ec <fd_alloc>
  801ee4:	83 c4 10             	add    $0x10,%esp
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	78 3a                	js     801f25 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eeb:	83 ec 04             	sub    $0x4,%esp
  801eee:	68 07 04 00 00       	push   $0x407
  801ef3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef6:	6a 00                	push   $0x0
  801ef8:	e8 b7 ec ff ff       	call   800bb4 <sys_page_alloc>
  801efd:	83 c4 10             	add    $0x10,%esp
  801f00:	85 c0                	test   %eax,%eax
  801f02:	78 21                	js     801f25 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f07:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f0d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f12:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f19:	83 ec 0c             	sub    $0xc,%esp
  801f1c:	50                   	push   %eax
  801f1d:	e8 97 f2 ff ff       	call   8011b9 <fd2num>
  801f22:	83 c4 10             	add    $0x10,%esp
}
  801f25:	c9                   	leave  
  801f26:	c3                   	ret    

00801f27 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f27:	f3 0f 1e fb          	endbr32 
  801f2b:	55                   	push   %ebp
  801f2c:	89 e5                	mov    %esp,%ebp
  801f2e:	56                   	push   %esi
  801f2f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f30:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f33:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f39:	e8 23 ec ff ff       	call   800b61 <sys_getenvid>
  801f3e:	83 ec 0c             	sub    $0xc,%esp
  801f41:	ff 75 0c             	pushl  0xc(%ebp)
  801f44:	ff 75 08             	pushl  0x8(%ebp)
  801f47:	56                   	push   %esi
  801f48:	50                   	push   %eax
  801f49:	68 4c 2a 80 00       	push   $0x802a4c
  801f4e:	e8 6f e2 ff ff       	call   8001c2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f53:	83 c4 18             	add    $0x18,%esp
  801f56:	53                   	push   %ebx
  801f57:	ff 75 10             	pushl  0x10(%ebp)
  801f5a:	e8 0e e2 ff ff       	call   80016d <vcprintf>
	cprintf("\n");
  801f5f:	c7 04 24 54 24 80 00 	movl   $0x802454,(%esp)
  801f66:	e8 57 e2 ff ff       	call   8001c2 <cprintf>
  801f6b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f6e:	cc                   	int3   
  801f6f:	eb fd                	jmp    801f6e <_panic+0x47>

00801f71 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f71:	f3 0f 1e fb          	endbr32 
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801f7b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f82:	74 0a                	je     801f8e <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f84:	8b 45 08             	mov    0x8(%ebp),%eax
  801f87:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f8c:	c9                   	leave  
  801f8d:	c3                   	ret    
		if (sys_page_alloc(0,
  801f8e:	83 ec 04             	sub    $0x4,%esp
  801f91:	6a 07                	push   $0x7
  801f93:	68 00 f0 bf ee       	push   $0xeebff000
  801f98:	6a 00                	push   $0x0
  801f9a:	e8 15 ec ff ff       	call   800bb4 <sys_page_alloc>
  801f9f:	83 c4 10             	add    $0x10,%esp
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	78 2a                	js     801fd0 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801fa6:	83 ec 08             	sub    $0x8,%esp
  801fa9:	68 e4 1f 80 00       	push   $0x801fe4
  801fae:	6a 00                	push   $0x0
  801fb0:	e8 c6 ec ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
  801fb5:	83 c4 10             	add    $0x10,%esp
  801fb8:	85 c0                	test   %eax,%eax
  801fba:	79 c8                	jns    801f84 <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  801fbc:	83 ec 04             	sub    $0x4,%esp
  801fbf:	68 a4 2a 80 00       	push   $0x802aa4
  801fc4:	6a 25                	push   $0x25
  801fc6:	68 eb 2a 80 00       	push   $0x802aeb
  801fcb:	e8 57 ff ff ff       	call   801f27 <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  801fd0:	83 ec 04             	sub    $0x4,%esp
  801fd3:	68 70 2a 80 00       	push   $0x802a70
  801fd8:	6a 21                	push   $0x21
  801fda:	68 eb 2a 80 00       	push   $0x802aeb
  801fdf:	e8 43 ff ff ff       	call   801f27 <_panic>

00801fe4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fe4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fe5:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fea:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fec:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  801fef:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  801ff4:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  801ff8:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801ffc:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  801ffe:	83 c4 08             	add    $0x8,%esp
	popal
  802001:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  802002:	83 c4 04             	add    $0x4,%esp
	popfl
  802005:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  802006:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802009:	c3                   	ret    

0080200a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80200a:	f3 0f 1e fb          	endbr32 
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	56                   	push   %esi
  802012:	53                   	push   %ebx
  802013:	8b 75 08             	mov    0x8(%ebp),%esi
  802016:	8b 45 0c             	mov    0xc(%ebp),%eax
  802019:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  80201c:	85 c0                	test   %eax,%eax
  80201e:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802023:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  802026:	83 ec 0c             	sub    $0xc,%esp
  802029:	50                   	push   %eax
  80202a:	e8 9c ec ff ff       	call   800ccb <sys_ipc_recv>
	if (f < 0) {
  80202f:	83 c4 10             	add    $0x10,%esp
  802032:	85 c0                	test   %eax,%eax
  802034:	78 2b                	js     802061 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  802036:	85 f6                	test   %esi,%esi
  802038:	74 0a                	je     802044 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  80203a:	a1 04 40 80 00       	mov    0x804004,%eax
  80203f:	8b 40 74             	mov    0x74(%eax),%eax
  802042:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  802044:	85 db                	test   %ebx,%ebx
  802046:	74 0a                	je     802052 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  802048:	a1 04 40 80 00       	mov    0x804004,%eax
  80204d:	8b 40 78             	mov    0x78(%eax),%eax
  802050:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  802052:	a1 04 40 80 00       	mov    0x804004,%eax
  802057:	8b 40 70             	mov    0x70(%eax),%eax
}
  80205a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80205d:	5b                   	pop    %ebx
  80205e:	5e                   	pop    %esi
  80205f:	5d                   	pop    %ebp
  802060:	c3                   	ret    
		if (from_env_store != NULL) {
  802061:	85 f6                	test   %esi,%esi
  802063:	74 06                	je     80206b <ipc_recv+0x61>
			*from_env_store = 0;
  802065:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  80206b:	85 db                	test   %ebx,%ebx
  80206d:	74 eb                	je     80205a <ipc_recv+0x50>
			*perm_store = 0;
  80206f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802075:	eb e3                	jmp    80205a <ipc_recv+0x50>

00802077 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802077:	f3 0f 1e fb          	endbr32 
  80207b:	55                   	push   %ebp
  80207c:	89 e5                	mov    %esp,%ebp
  80207e:	57                   	push   %edi
  80207f:	56                   	push   %esi
  802080:	53                   	push   %ebx
  802081:	83 ec 0c             	sub    $0xc,%esp
  802084:	8b 7d 08             	mov    0x8(%ebp),%edi
  802087:	8b 75 0c             	mov    0xc(%ebp),%esi
  80208a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  80208d:	85 db                	test   %ebx,%ebx
  80208f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802094:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802097:	ff 75 14             	pushl  0x14(%ebp)
  80209a:	53                   	push   %ebx
  80209b:	56                   	push   %esi
  80209c:	57                   	push   %edi
  80209d:	e8 00 ec ff ff       	call   800ca2 <sys_ipc_try_send>
  8020a2:	83 c4 10             	add    $0x10,%esp
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	79 19                	jns    8020c2 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  8020a9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020ac:	74 e9                	je     802097 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  8020ae:	83 ec 04             	sub    $0x4,%esp
  8020b1:	68 fc 2a 80 00       	push   $0x802afc
  8020b6:	6a 48                	push   $0x48
  8020b8:	68 1e 2b 80 00       	push   $0x802b1e
  8020bd:	e8 65 fe ff ff       	call   801f27 <_panic>
		}
	}
}
  8020c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020c5:	5b                   	pop    %ebx
  8020c6:	5e                   	pop    %esi
  8020c7:	5f                   	pop    %edi
  8020c8:	5d                   	pop    %ebp
  8020c9:	c3                   	ret    

008020ca <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020ca:	f3 0f 1e fb          	endbr32 
  8020ce:	55                   	push   %ebp
  8020cf:	89 e5                	mov    %esp,%ebp
  8020d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020d4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020d9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020dc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020e2:	8b 52 50             	mov    0x50(%edx),%edx
  8020e5:	39 ca                	cmp    %ecx,%edx
  8020e7:	74 11                	je     8020fa <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8020e9:	83 c0 01             	add    $0x1,%eax
  8020ec:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020f1:	75 e6                	jne    8020d9 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8020f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8020f8:	eb 0b                	jmp    802105 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8020fa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020fd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802102:	8b 40 48             	mov    0x48(%eax),%eax
}
  802105:	5d                   	pop    %ebp
  802106:	c3                   	ret    

00802107 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802107:	f3 0f 1e fb          	endbr32 
  80210b:	55                   	push   %ebp
  80210c:	89 e5                	mov    %esp,%ebp
  80210e:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802111:	89 c2                	mov    %eax,%edx
  802113:	c1 ea 16             	shr    $0x16,%edx
  802116:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80211d:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802122:	f6 c1 01             	test   $0x1,%cl
  802125:	74 1c                	je     802143 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802127:	c1 e8 0c             	shr    $0xc,%eax
  80212a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802131:	a8 01                	test   $0x1,%al
  802133:	74 0e                	je     802143 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802135:	c1 e8 0c             	shr    $0xc,%eax
  802138:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80213f:	ef 
  802140:	0f b7 d2             	movzwl %dx,%edx
}
  802143:	89 d0                	mov    %edx,%eax
  802145:	5d                   	pop    %ebp
  802146:	c3                   	ret    
  802147:	66 90                	xchg   %ax,%ax
  802149:	66 90                	xchg   %ax,%ax
  80214b:	66 90                	xchg   %ax,%ax
  80214d:	66 90                	xchg   %ax,%ax
  80214f:	90                   	nop

00802150 <__udivdi3>:
  802150:	f3 0f 1e fb          	endbr32 
  802154:	55                   	push   %ebp
  802155:	57                   	push   %edi
  802156:	56                   	push   %esi
  802157:	53                   	push   %ebx
  802158:	83 ec 1c             	sub    $0x1c,%esp
  80215b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80215f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802163:	8b 74 24 34          	mov    0x34(%esp),%esi
  802167:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80216b:	85 d2                	test   %edx,%edx
  80216d:	75 19                	jne    802188 <__udivdi3+0x38>
  80216f:	39 f3                	cmp    %esi,%ebx
  802171:	76 4d                	jbe    8021c0 <__udivdi3+0x70>
  802173:	31 ff                	xor    %edi,%edi
  802175:	89 e8                	mov    %ebp,%eax
  802177:	89 f2                	mov    %esi,%edx
  802179:	f7 f3                	div    %ebx
  80217b:	89 fa                	mov    %edi,%edx
  80217d:	83 c4 1c             	add    $0x1c,%esp
  802180:	5b                   	pop    %ebx
  802181:	5e                   	pop    %esi
  802182:	5f                   	pop    %edi
  802183:	5d                   	pop    %ebp
  802184:	c3                   	ret    
  802185:	8d 76 00             	lea    0x0(%esi),%esi
  802188:	39 f2                	cmp    %esi,%edx
  80218a:	76 14                	jbe    8021a0 <__udivdi3+0x50>
  80218c:	31 ff                	xor    %edi,%edi
  80218e:	31 c0                	xor    %eax,%eax
  802190:	89 fa                	mov    %edi,%edx
  802192:	83 c4 1c             	add    $0x1c,%esp
  802195:	5b                   	pop    %ebx
  802196:	5e                   	pop    %esi
  802197:	5f                   	pop    %edi
  802198:	5d                   	pop    %ebp
  802199:	c3                   	ret    
  80219a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a0:	0f bd fa             	bsr    %edx,%edi
  8021a3:	83 f7 1f             	xor    $0x1f,%edi
  8021a6:	75 48                	jne    8021f0 <__udivdi3+0xa0>
  8021a8:	39 f2                	cmp    %esi,%edx
  8021aa:	72 06                	jb     8021b2 <__udivdi3+0x62>
  8021ac:	31 c0                	xor    %eax,%eax
  8021ae:	39 eb                	cmp    %ebp,%ebx
  8021b0:	77 de                	ja     802190 <__udivdi3+0x40>
  8021b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b7:	eb d7                	jmp    802190 <__udivdi3+0x40>
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	89 d9                	mov    %ebx,%ecx
  8021c2:	85 db                	test   %ebx,%ebx
  8021c4:	75 0b                	jne    8021d1 <__udivdi3+0x81>
  8021c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021cb:	31 d2                	xor    %edx,%edx
  8021cd:	f7 f3                	div    %ebx
  8021cf:	89 c1                	mov    %eax,%ecx
  8021d1:	31 d2                	xor    %edx,%edx
  8021d3:	89 f0                	mov    %esi,%eax
  8021d5:	f7 f1                	div    %ecx
  8021d7:	89 c6                	mov    %eax,%esi
  8021d9:	89 e8                	mov    %ebp,%eax
  8021db:	89 f7                	mov    %esi,%edi
  8021dd:	f7 f1                	div    %ecx
  8021df:	89 fa                	mov    %edi,%edx
  8021e1:	83 c4 1c             	add    $0x1c,%esp
  8021e4:	5b                   	pop    %ebx
  8021e5:	5e                   	pop    %esi
  8021e6:	5f                   	pop    %edi
  8021e7:	5d                   	pop    %ebp
  8021e8:	c3                   	ret    
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	89 f9                	mov    %edi,%ecx
  8021f2:	b8 20 00 00 00       	mov    $0x20,%eax
  8021f7:	29 f8                	sub    %edi,%eax
  8021f9:	d3 e2                	shl    %cl,%edx
  8021fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021ff:	89 c1                	mov    %eax,%ecx
  802201:	89 da                	mov    %ebx,%edx
  802203:	d3 ea                	shr    %cl,%edx
  802205:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802209:	09 d1                	or     %edx,%ecx
  80220b:	89 f2                	mov    %esi,%edx
  80220d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802211:	89 f9                	mov    %edi,%ecx
  802213:	d3 e3                	shl    %cl,%ebx
  802215:	89 c1                	mov    %eax,%ecx
  802217:	d3 ea                	shr    %cl,%edx
  802219:	89 f9                	mov    %edi,%ecx
  80221b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80221f:	89 eb                	mov    %ebp,%ebx
  802221:	d3 e6                	shl    %cl,%esi
  802223:	89 c1                	mov    %eax,%ecx
  802225:	d3 eb                	shr    %cl,%ebx
  802227:	09 de                	or     %ebx,%esi
  802229:	89 f0                	mov    %esi,%eax
  80222b:	f7 74 24 08          	divl   0x8(%esp)
  80222f:	89 d6                	mov    %edx,%esi
  802231:	89 c3                	mov    %eax,%ebx
  802233:	f7 64 24 0c          	mull   0xc(%esp)
  802237:	39 d6                	cmp    %edx,%esi
  802239:	72 15                	jb     802250 <__udivdi3+0x100>
  80223b:	89 f9                	mov    %edi,%ecx
  80223d:	d3 e5                	shl    %cl,%ebp
  80223f:	39 c5                	cmp    %eax,%ebp
  802241:	73 04                	jae    802247 <__udivdi3+0xf7>
  802243:	39 d6                	cmp    %edx,%esi
  802245:	74 09                	je     802250 <__udivdi3+0x100>
  802247:	89 d8                	mov    %ebx,%eax
  802249:	31 ff                	xor    %edi,%edi
  80224b:	e9 40 ff ff ff       	jmp    802190 <__udivdi3+0x40>
  802250:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802253:	31 ff                	xor    %edi,%edi
  802255:	e9 36 ff ff ff       	jmp    802190 <__udivdi3+0x40>
  80225a:	66 90                	xchg   %ax,%ax
  80225c:	66 90                	xchg   %ax,%ax
  80225e:	66 90                	xchg   %ax,%ax

00802260 <__umoddi3>:
  802260:	f3 0f 1e fb          	endbr32 
  802264:	55                   	push   %ebp
  802265:	57                   	push   %edi
  802266:	56                   	push   %esi
  802267:	53                   	push   %ebx
  802268:	83 ec 1c             	sub    $0x1c,%esp
  80226b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80226f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802273:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802277:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80227b:	85 c0                	test   %eax,%eax
  80227d:	75 19                	jne    802298 <__umoddi3+0x38>
  80227f:	39 df                	cmp    %ebx,%edi
  802281:	76 5d                	jbe    8022e0 <__umoddi3+0x80>
  802283:	89 f0                	mov    %esi,%eax
  802285:	89 da                	mov    %ebx,%edx
  802287:	f7 f7                	div    %edi
  802289:	89 d0                	mov    %edx,%eax
  80228b:	31 d2                	xor    %edx,%edx
  80228d:	83 c4 1c             	add    $0x1c,%esp
  802290:	5b                   	pop    %ebx
  802291:	5e                   	pop    %esi
  802292:	5f                   	pop    %edi
  802293:	5d                   	pop    %ebp
  802294:	c3                   	ret    
  802295:	8d 76 00             	lea    0x0(%esi),%esi
  802298:	89 f2                	mov    %esi,%edx
  80229a:	39 d8                	cmp    %ebx,%eax
  80229c:	76 12                	jbe    8022b0 <__umoddi3+0x50>
  80229e:	89 f0                	mov    %esi,%eax
  8022a0:	89 da                	mov    %ebx,%edx
  8022a2:	83 c4 1c             	add    $0x1c,%esp
  8022a5:	5b                   	pop    %ebx
  8022a6:	5e                   	pop    %esi
  8022a7:	5f                   	pop    %edi
  8022a8:	5d                   	pop    %ebp
  8022a9:	c3                   	ret    
  8022aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022b0:	0f bd e8             	bsr    %eax,%ebp
  8022b3:	83 f5 1f             	xor    $0x1f,%ebp
  8022b6:	75 50                	jne    802308 <__umoddi3+0xa8>
  8022b8:	39 d8                	cmp    %ebx,%eax
  8022ba:	0f 82 e0 00 00 00    	jb     8023a0 <__umoddi3+0x140>
  8022c0:	89 d9                	mov    %ebx,%ecx
  8022c2:	39 f7                	cmp    %esi,%edi
  8022c4:	0f 86 d6 00 00 00    	jbe    8023a0 <__umoddi3+0x140>
  8022ca:	89 d0                	mov    %edx,%eax
  8022cc:	89 ca                	mov    %ecx,%edx
  8022ce:	83 c4 1c             	add    $0x1c,%esp
  8022d1:	5b                   	pop    %ebx
  8022d2:	5e                   	pop    %esi
  8022d3:	5f                   	pop    %edi
  8022d4:	5d                   	pop    %ebp
  8022d5:	c3                   	ret    
  8022d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
  8022e0:	89 fd                	mov    %edi,%ebp
  8022e2:	85 ff                	test   %edi,%edi
  8022e4:	75 0b                	jne    8022f1 <__umoddi3+0x91>
  8022e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022eb:	31 d2                	xor    %edx,%edx
  8022ed:	f7 f7                	div    %edi
  8022ef:	89 c5                	mov    %eax,%ebp
  8022f1:	89 d8                	mov    %ebx,%eax
  8022f3:	31 d2                	xor    %edx,%edx
  8022f5:	f7 f5                	div    %ebp
  8022f7:	89 f0                	mov    %esi,%eax
  8022f9:	f7 f5                	div    %ebp
  8022fb:	89 d0                	mov    %edx,%eax
  8022fd:	31 d2                	xor    %edx,%edx
  8022ff:	eb 8c                	jmp    80228d <__umoddi3+0x2d>
  802301:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802308:	89 e9                	mov    %ebp,%ecx
  80230a:	ba 20 00 00 00       	mov    $0x20,%edx
  80230f:	29 ea                	sub    %ebp,%edx
  802311:	d3 e0                	shl    %cl,%eax
  802313:	89 44 24 08          	mov    %eax,0x8(%esp)
  802317:	89 d1                	mov    %edx,%ecx
  802319:	89 f8                	mov    %edi,%eax
  80231b:	d3 e8                	shr    %cl,%eax
  80231d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802321:	89 54 24 04          	mov    %edx,0x4(%esp)
  802325:	8b 54 24 04          	mov    0x4(%esp),%edx
  802329:	09 c1                	or     %eax,%ecx
  80232b:	89 d8                	mov    %ebx,%eax
  80232d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802331:	89 e9                	mov    %ebp,%ecx
  802333:	d3 e7                	shl    %cl,%edi
  802335:	89 d1                	mov    %edx,%ecx
  802337:	d3 e8                	shr    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80233f:	d3 e3                	shl    %cl,%ebx
  802341:	89 c7                	mov    %eax,%edi
  802343:	89 d1                	mov    %edx,%ecx
  802345:	89 f0                	mov    %esi,%eax
  802347:	d3 e8                	shr    %cl,%eax
  802349:	89 e9                	mov    %ebp,%ecx
  80234b:	89 fa                	mov    %edi,%edx
  80234d:	d3 e6                	shl    %cl,%esi
  80234f:	09 d8                	or     %ebx,%eax
  802351:	f7 74 24 08          	divl   0x8(%esp)
  802355:	89 d1                	mov    %edx,%ecx
  802357:	89 f3                	mov    %esi,%ebx
  802359:	f7 64 24 0c          	mull   0xc(%esp)
  80235d:	89 c6                	mov    %eax,%esi
  80235f:	89 d7                	mov    %edx,%edi
  802361:	39 d1                	cmp    %edx,%ecx
  802363:	72 06                	jb     80236b <__umoddi3+0x10b>
  802365:	75 10                	jne    802377 <__umoddi3+0x117>
  802367:	39 c3                	cmp    %eax,%ebx
  802369:	73 0c                	jae    802377 <__umoddi3+0x117>
  80236b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80236f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802373:	89 d7                	mov    %edx,%edi
  802375:	89 c6                	mov    %eax,%esi
  802377:	89 ca                	mov    %ecx,%edx
  802379:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80237e:	29 f3                	sub    %esi,%ebx
  802380:	19 fa                	sbb    %edi,%edx
  802382:	89 d0                	mov    %edx,%eax
  802384:	d3 e0                	shl    %cl,%eax
  802386:	89 e9                	mov    %ebp,%ecx
  802388:	d3 eb                	shr    %cl,%ebx
  80238a:	d3 ea                	shr    %cl,%edx
  80238c:	09 d8                	or     %ebx,%eax
  80238e:	83 c4 1c             	add    $0x1c,%esp
  802391:	5b                   	pop    %ebx
  802392:	5e                   	pop    %esi
  802393:	5f                   	pop    %edi
  802394:	5d                   	pop    %ebp
  802395:	c3                   	ret    
  802396:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80239d:	8d 76 00             	lea    0x0(%esi),%esi
  8023a0:	29 fe                	sub    %edi,%esi
  8023a2:	19 c3                	sbb    %eax,%ebx
  8023a4:	89 f2                	mov    %esi,%edx
  8023a6:	89 d9                	mov    %ebx,%ecx
  8023a8:	e9 1d ff ff ff       	jmp    8022ca <__umoddi3+0x6a>
