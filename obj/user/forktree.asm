
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 be 00 00 00       	call   8000ef <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	53                   	push   %ebx
  80003b:	83 ec 04             	sub    $0x4,%esp
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  800041:	e8 51 0b 00 00       	call   800b97 <sys_getenvid>
  800046:	83 ec 04             	sub    $0x4,%esp
  800049:	53                   	push   %ebx
  80004a:	50                   	push   %eax
  80004b:	68 e0 23 80 00       	push   $0x8023e0
  800050:	e8 a3 01 00 00       	call   8001f8 <cprintf>

	forkchild(cur, '0');
  800055:	83 c4 08             	add    $0x8,%esp
  800058:	6a 30                	push   $0x30
  80005a:	53                   	push   %ebx
  80005b:	e8 13 00 00 00       	call   800073 <forkchild>
	forkchild(cur, '1');
  800060:	83 c4 08             	add    $0x8,%esp
  800063:	6a 31                	push   $0x31
  800065:	53                   	push   %ebx
  800066:	e8 08 00 00 00       	call   800073 <forkchild>
}
  80006b:	83 c4 10             	add    $0x10,%esp
  80006e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800071:	c9                   	leave  
  800072:	c3                   	ret    

00800073 <forkchild>:
{
  800073:	f3 0f 1e fb          	endbr32 
  800077:	55                   	push   %ebp
  800078:	89 e5                	mov    %esp,%ebp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	83 ec 1c             	sub    $0x1c,%esp
  80007f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800082:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  800085:	53                   	push   %ebx
  800086:	e8 94 06 00 00       	call   80071f <strlen>
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	83 f8 02             	cmp    $0x2,%eax
  800091:	7e 07                	jle    80009a <forkchild+0x27>
}
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	89 f0                	mov    %esi,%eax
  80009f:	0f be f0             	movsbl %al,%esi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
  8000a4:	68 f1 23 80 00       	push   $0x8023f1
  8000a9:	6a 04                	push   $0x4
  8000ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ae:	50                   	push   %eax
  8000af:	e8 4d 06 00 00       	call   800701 <snprintf>
	if (fork() == 0) {
  8000b4:	83 c4 20             	add    $0x20,%esp
  8000b7:	e8 df 0f 00 00       	call   80109b <fork>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	75 d3                	jne    800093 <forkchild+0x20>
		forktree(nxt);
  8000c0:	83 ec 0c             	sub    $0xc,%esp
  8000c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000c6:	50                   	push   %eax
  8000c7:	e8 67 ff ff ff       	call   800033 <forktree>
		exit();
  8000cc:	e8 6c 00 00 00       	call   80013d <exit>
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	eb bd                	jmp    800093 <forkchild+0x20>

008000d6 <umain>:

void
umain(int argc, char **argv)
{
  8000d6:	f3 0f 1e fb          	endbr32 
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000e0:	68 f0 23 80 00       	push   $0x8023f0
  8000e5:	e8 49 ff ff ff       	call   800033 <forktree>
}
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	c9                   	leave  
  8000ee:	c3                   	ret    

008000ef <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ef:	f3 0f 1e fb          	endbr32 
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000fb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000fe:	e8 94 0a 00 00       	call   800b97 <sys_getenvid>
	if (id >= 0)
  800103:	85 c0                	test   %eax,%eax
  800105:	78 12                	js     800119 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800114:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800119:	85 db                	test   %ebx,%ebx
  80011b:	7e 07                	jle    800124 <libmain+0x35>
		binaryname = argv[0];
  80011d:	8b 06                	mov    (%esi),%eax
  80011f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800124:	83 ec 08             	sub    $0x8,%esp
  800127:	56                   	push   %esi
  800128:	53                   	push   %ebx
  800129:	e8 a8 ff ff ff       	call   8000d6 <umain>

	// exit gracefully
	exit();
  80012e:	e8 0a 00 00 00       	call   80013d <exit>
}
  800133:	83 c4 10             	add    $0x10,%esp
  800136:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800139:	5b                   	pop    %ebx
  80013a:	5e                   	pop    %esi
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    

0080013d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013d:	f3 0f 1e fb          	endbr32 
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800147:	e8 96 12 00 00       	call   8013e2 <close_all>
	sys_env_destroy(0);
  80014c:	83 ec 0c             	sub    $0xc,%esp
  80014f:	6a 00                	push   $0x0
  800151:	e8 1b 0a 00 00       	call   800b71 <sys_env_destroy>
}
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	f3 0f 1e fb          	endbr32 
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	53                   	push   %ebx
  800163:	83 ec 04             	sub    $0x4,%esp
  800166:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800169:	8b 13                	mov    (%ebx),%edx
  80016b:	8d 42 01             	lea    0x1(%edx),%eax
  80016e:	89 03                	mov    %eax,(%ebx)
  800170:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800173:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800177:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017c:	74 09                	je     800187 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80017e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800182:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800185:	c9                   	leave  
  800186:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800187:	83 ec 08             	sub    $0x8,%esp
  80018a:	68 ff 00 00 00       	push   $0xff
  80018f:	8d 43 08             	lea    0x8(%ebx),%eax
  800192:	50                   	push   %eax
  800193:	e8 87 09 00 00       	call   800b1f <sys_cputs>
		b->idx = 0;
  800198:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019e:	83 c4 10             	add    $0x10,%esp
  8001a1:	eb db                	jmp    80017e <putch+0x23>

008001a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a3:	f3 0f 1e fb          	endbr32 
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b7:	00 00 00 
	b.cnt = 0;
  8001ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c4:	ff 75 0c             	pushl  0xc(%ebp)
  8001c7:	ff 75 08             	pushl  0x8(%ebp)
  8001ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d0:	50                   	push   %eax
  8001d1:	68 5b 01 80 00       	push   $0x80015b
  8001d6:	e8 80 01 00 00       	call   80035b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001db:	83 c4 08             	add    $0x8,%esp
  8001de:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ea:	50                   	push   %eax
  8001eb:	e8 2f 09 00 00       	call   800b1f <sys_cputs>

	return b.cnt;
}
  8001f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f8:	f3 0f 1e fb          	endbr32 
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800202:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800205:	50                   	push   %eax
  800206:	ff 75 08             	pushl  0x8(%ebp)
  800209:	e8 95 ff ff ff       	call   8001a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	83 ec 1c             	sub    $0x1c,%esp
  800219:	89 c7                	mov    %eax,%edi
  80021b:	89 d6                	mov    %edx,%esi
  80021d:	8b 45 08             	mov    0x8(%ebp),%eax
  800220:	8b 55 0c             	mov    0xc(%ebp),%edx
  800223:	89 d1                	mov    %edx,%ecx
  800225:	89 c2                	mov    %eax,%edx
  800227:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80022d:	8b 45 10             	mov    0x10(%ebp),%eax
  800230:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800233:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800236:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80023d:	39 c2                	cmp    %eax,%edx
  80023f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800242:	72 3e                	jb     800282 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	ff 75 18             	pushl  0x18(%ebp)
  80024a:	83 eb 01             	sub    $0x1,%ebx
  80024d:	53                   	push   %ebx
  80024e:	50                   	push   %eax
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	ff 75 e4             	pushl  -0x1c(%ebp)
  800255:	ff 75 e0             	pushl  -0x20(%ebp)
  800258:	ff 75 dc             	pushl  -0x24(%ebp)
  80025b:	ff 75 d8             	pushl  -0x28(%ebp)
  80025e:	e8 1d 1f 00 00       	call   802180 <__udivdi3>
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	52                   	push   %edx
  800267:	50                   	push   %eax
  800268:	89 f2                	mov    %esi,%edx
  80026a:	89 f8                	mov    %edi,%eax
  80026c:	e8 9f ff ff ff       	call   800210 <printnum>
  800271:	83 c4 20             	add    $0x20,%esp
  800274:	eb 13                	jmp    800289 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800276:	83 ec 08             	sub    $0x8,%esp
  800279:	56                   	push   %esi
  80027a:	ff 75 18             	pushl  0x18(%ebp)
  80027d:	ff d7                	call   *%edi
  80027f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800282:	83 eb 01             	sub    $0x1,%ebx
  800285:	85 db                	test   %ebx,%ebx
  800287:	7f ed                	jg     800276 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	56                   	push   %esi
  80028d:	83 ec 04             	sub    $0x4,%esp
  800290:	ff 75 e4             	pushl  -0x1c(%ebp)
  800293:	ff 75 e0             	pushl  -0x20(%ebp)
  800296:	ff 75 dc             	pushl  -0x24(%ebp)
  800299:	ff 75 d8             	pushl  -0x28(%ebp)
  80029c:	e8 ef 1f 00 00       	call   802290 <__umoddi3>
  8002a1:	83 c4 14             	add    $0x14,%esp
  8002a4:	0f be 80 00 24 80 00 	movsbl 0x802400(%eax),%eax
  8002ab:	50                   	push   %eax
  8002ac:	ff d7                	call   *%edi
}
  8002ae:	83 c4 10             	add    $0x10,%esp
  8002b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b4:	5b                   	pop    %ebx
  8002b5:	5e                   	pop    %esi
  8002b6:	5f                   	pop    %edi
  8002b7:	5d                   	pop    %ebp
  8002b8:	c3                   	ret    

008002b9 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002b9:	83 fa 01             	cmp    $0x1,%edx
  8002bc:	7f 13                	jg     8002d1 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8002be:	85 d2                	test   %edx,%edx
  8002c0:	74 1c                	je     8002de <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d0:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8002d1:	8b 10                	mov    (%eax),%edx
  8002d3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d6:	89 08                	mov    %ecx,(%eax)
  8002d8:	8b 02                	mov    (%edx),%eax
  8002da:	8b 52 04             	mov    0x4(%edx),%edx
  8002dd:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ec:	c3                   	ret    

008002ed <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002ed:	83 fa 01             	cmp    $0x1,%edx
  8002f0:	7f 0f                	jg     800301 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8002f2:	85 d2                	test   %edx,%edx
  8002f4:	74 18                	je     80030e <getint+0x21>
		return va_arg(*ap, long);
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fb:	89 08                	mov    %ecx,(%eax)
  8002fd:	8b 02                	mov    (%edx),%eax
  8002ff:	99                   	cltd   
  800300:	c3                   	ret    
		return va_arg(*ap, long long);
  800301:	8b 10                	mov    (%eax),%edx
  800303:	8d 4a 08             	lea    0x8(%edx),%ecx
  800306:	89 08                	mov    %ecx,(%eax)
  800308:	8b 02                	mov    (%edx),%eax
  80030a:	8b 52 04             	mov    0x4(%edx),%edx
  80030d:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	99                   	cltd   
}
  800318:	c3                   	ret    

00800319 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800319:	f3 0f 1e fb          	endbr32 
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800323:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800327:	8b 10                	mov    (%eax),%edx
  800329:	3b 50 04             	cmp    0x4(%eax),%edx
  80032c:	73 0a                	jae    800338 <sprintputch+0x1f>
		*b->buf++ = ch;
  80032e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800331:	89 08                	mov    %ecx,(%eax)
  800333:	8b 45 08             	mov    0x8(%ebp),%eax
  800336:	88 02                	mov    %al,(%edx)
}
  800338:	5d                   	pop    %ebp
  800339:	c3                   	ret    

0080033a <printfmt>:
{
  80033a:	f3 0f 1e fb          	endbr32 
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800344:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800347:	50                   	push   %eax
  800348:	ff 75 10             	pushl  0x10(%ebp)
  80034b:	ff 75 0c             	pushl  0xc(%ebp)
  80034e:	ff 75 08             	pushl  0x8(%ebp)
  800351:	e8 05 00 00 00       	call   80035b <vprintfmt>
}
  800356:	83 c4 10             	add    $0x10,%esp
  800359:	c9                   	leave  
  80035a:	c3                   	ret    

0080035b <vprintfmt>:
{
  80035b:	f3 0f 1e fb          	endbr32 
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	57                   	push   %edi
  800363:	56                   	push   %esi
  800364:	53                   	push   %ebx
  800365:	83 ec 2c             	sub    $0x2c,%esp
  800368:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80036b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80036e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800371:	e9 86 02 00 00       	jmp    8005fc <vprintfmt+0x2a1>
		padc = ' ';
  800376:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80037a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800381:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800388:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80038f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8d 47 01             	lea    0x1(%edi),%eax
  800397:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039a:	0f b6 17             	movzbl (%edi),%edx
  80039d:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003a0:	3c 55                	cmp    $0x55,%al
  8003a2:	0f 87 df 02 00 00    	ja     800687 <vprintfmt+0x32c>
  8003a8:	0f b6 c0             	movzbl %al,%eax
  8003ab:	3e ff 24 85 40 25 80 	notrack jmp *0x802540(,%eax,4)
  8003b2:	00 
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003b6:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003ba:	eb d8                	jmp    800394 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bf:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003c3:	eb cf                	jmp    800394 <vprintfmt+0x39>
  8003c5:	0f b6 d2             	movzbl %dl,%edx
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003d3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003da:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003dd:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003e0:	83 f9 09             	cmp    $0x9,%ecx
  8003e3:	77 52                	ja     800437 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8003e5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003e8:	eb e9                	jmp    8003d3 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ed:	8d 50 04             	lea    0x4(%eax),%edx
  8003f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f3:	8b 00                	mov    (%eax),%eax
  8003f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ff:	79 93                	jns    800394 <vprintfmt+0x39>
				width = precision, precision = -1;
  800401:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800404:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800407:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80040e:	eb 84                	jmp    800394 <vprintfmt+0x39>
  800410:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800413:	85 c0                	test   %eax,%eax
  800415:	ba 00 00 00 00       	mov    $0x0,%edx
  80041a:	0f 49 d0             	cmovns %eax,%edx
  80041d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800423:	e9 6c ff ff ff       	jmp    800394 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80042b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800432:	e9 5d ff ff ff       	jmp    800394 <vprintfmt+0x39>
  800437:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80043a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80043d:	eb bc                	jmp    8003fb <vprintfmt+0xa0>
			lflag++;
  80043f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800445:	e9 4a ff ff ff       	jmp    800394 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	8d 50 04             	lea    0x4(%eax),%edx
  800450:	89 55 14             	mov    %edx,0x14(%ebp)
  800453:	83 ec 08             	sub    $0x8,%esp
  800456:	56                   	push   %esi
  800457:	ff 30                	pushl  (%eax)
  800459:	ff d3                	call   *%ebx
			break;
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	e9 96 01 00 00       	jmp    8005f9 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	8d 50 04             	lea    0x4(%eax),%edx
  800469:	89 55 14             	mov    %edx,0x14(%ebp)
  80046c:	8b 00                	mov    (%eax),%eax
  80046e:	99                   	cltd   
  80046f:	31 d0                	xor    %edx,%eax
  800471:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800473:	83 f8 0f             	cmp    $0xf,%eax
  800476:	7f 20                	jg     800498 <vprintfmt+0x13d>
  800478:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  80047f:	85 d2                	test   %edx,%edx
  800481:	74 15                	je     800498 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800483:	52                   	push   %edx
  800484:	68 a5 29 80 00       	push   $0x8029a5
  800489:	56                   	push   %esi
  80048a:	53                   	push   %ebx
  80048b:	e8 aa fe ff ff       	call   80033a <printfmt>
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	e9 61 01 00 00       	jmp    8005f9 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800498:	50                   	push   %eax
  800499:	68 18 24 80 00       	push   $0x802418
  80049e:	56                   	push   %esi
  80049f:	53                   	push   %ebx
  8004a0:	e8 95 fe ff ff       	call   80033a <printfmt>
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	e9 4c 01 00 00       	jmp    8005f9 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8d 50 04             	lea    0x4(%eax),%edx
  8004b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b6:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8004b8:	85 c9                	test   %ecx,%ecx
  8004ba:	b8 11 24 80 00       	mov    $0x802411,%eax
  8004bf:	0f 45 c1             	cmovne %ecx,%eax
  8004c2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c9:	7e 06                	jle    8004d1 <vprintfmt+0x176>
  8004cb:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004cf:	75 0d                	jne    8004de <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004d4:	89 c7                	mov    %eax,%edi
  8004d6:	03 45 e0             	add    -0x20(%ebp),%eax
  8004d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004dc:	eb 57                	jmp    800535 <vprintfmt+0x1da>
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e4:	ff 75 cc             	pushl  -0x34(%ebp)
  8004e7:	e8 4f 02 00 00       	call   80073b <strnlen>
  8004ec:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ef:	29 c2                	sub    %eax,%edx
  8004f1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004f4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004f7:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8004fb:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8004fe:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800500:	85 db                	test   %ebx,%ebx
  800502:	7e 10                	jle    800514 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	56                   	push   %esi
  800508:	57                   	push   %edi
  800509:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80050c:	83 eb 01             	sub    $0x1,%ebx
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	eb ec                	jmp    800500 <vprintfmt+0x1a5>
  800514:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800517:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80051a:	85 d2                	test   %edx,%edx
  80051c:	b8 00 00 00 00       	mov    $0x0,%eax
  800521:	0f 49 c2             	cmovns %edx,%eax
  800524:	29 c2                	sub    %eax,%edx
  800526:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800529:	eb a6                	jmp    8004d1 <vprintfmt+0x176>
					putch(ch, putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	56                   	push   %esi
  80052f:	52                   	push   %edx
  800530:	ff d3                	call   *%ebx
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800538:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053a:	83 c7 01             	add    $0x1,%edi
  80053d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800541:	0f be d0             	movsbl %al,%edx
  800544:	85 d2                	test   %edx,%edx
  800546:	74 42                	je     80058a <vprintfmt+0x22f>
  800548:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054c:	78 06                	js     800554 <vprintfmt+0x1f9>
  80054e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800552:	78 1e                	js     800572 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800554:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800558:	74 d1                	je     80052b <vprintfmt+0x1d0>
  80055a:	0f be c0             	movsbl %al,%eax
  80055d:	83 e8 20             	sub    $0x20,%eax
  800560:	83 f8 5e             	cmp    $0x5e,%eax
  800563:	76 c6                	jbe    80052b <vprintfmt+0x1d0>
					putch('?', putdat);
  800565:	83 ec 08             	sub    $0x8,%esp
  800568:	56                   	push   %esi
  800569:	6a 3f                	push   $0x3f
  80056b:	ff d3                	call   *%ebx
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	eb c3                	jmp    800535 <vprintfmt+0x1da>
  800572:	89 cf                	mov    %ecx,%edi
  800574:	eb 0e                	jmp    800584 <vprintfmt+0x229>
				putch(' ', putdat);
  800576:	83 ec 08             	sub    $0x8,%esp
  800579:	56                   	push   %esi
  80057a:	6a 20                	push   $0x20
  80057c:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80057e:	83 ef 01             	sub    $0x1,%edi
  800581:	83 c4 10             	add    $0x10,%esp
  800584:	85 ff                	test   %edi,%edi
  800586:	7f ee                	jg     800576 <vprintfmt+0x21b>
  800588:	eb 6f                	jmp    8005f9 <vprintfmt+0x29e>
  80058a:	89 cf                	mov    %ecx,%edi
  80058c:	eb f6                	jmp    800584 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  80058e:	89 ca                	mov    %ecx,%edx
  800590:	8d 45 14             	lea    0x14(%ebp),%eax
  800593:	e8 55 fd ff ff       	call   8002ed <getint>
  800598:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80059e:	85 d2                	test   %edx,%edx
  8005a0:	78 0b                	js     8005ad <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8005a2:	89 d1                	mov    %edx,%ecx
  8005a4:	89 c2                	mov    %eax,%edx
			base = 10;
  8005a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ab:	eb 32                	jmp    8005df <vprintfmt+0x284>
				putch('-', putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	56                   	push   %esi
  8005b1:	6a 2d                	push   $0x2d
  8005b3:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005bb:	f7 da                	neg    %edx
  8005bd:	83 d1 00             	adc    $0x0,%ecx
  8005c0:	f7 d9                	neg    %ecx
  8005c2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ca:	eb 13                	jmp    8005df <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8005cc:	89 ca                	mov    %ecx,%edx
  8005ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d1:	e8 e3 fc ff ff       	call   8002b9 <getuint>
  8005d6:	89 d1                	mov    %edx,%ecx
  8005d8:	89 c2                	mov    %eax,%edx
			base = 10;
  8005da:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005e6:	57                   	push   %edi
  8005e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ea:	50                   	push   %eax
  8005eb:	51                   	push   %ecx
  8005ec:	52                   	push   %edx
  8005ed:	89 f2                	mov    %esi,%edx
  8005ef:	89 d8                	mov    %ebx,%eax
  8005f1:	e8 1a fc ff ff       	call   800210 <printnum>
			break;
  8005f6:	83 c4 20             	add    $0x20,%esp
{
  8005f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005fc:	83 c7 01             	add    $0x1,%edi
  8005ff:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800603:	83 f8 25             	cmp    $0x25,%eax
  800606:	0f 84 6a fd ff ff    	je     800376 <vprintfmt+0x1b>
			if (ch == '\0')
  80060c:	85 c0                	test   %eax,%eax
  80060e:	0f 84 93 00 00 00    	je     8006a7 <vprintfmt+0x34c>
			putch(ch, putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	56                   	push   %esi
  800618:	50                   	push   %eax
  800619:	ff d3                	call   *%ebx
  80061b:	83 c4 10             	add    $0x10,%esp
  80061e:	eb dc                	jmp    8005fc <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800620:	89 ca                	mov    %ecx,%edx
  800622:	8d 45 14             	lea    0x14(%ebp),%eax
  800625:	e8 8f fc ff ff       	call   8002b9 <getuint>
  80062a:	89 d1                	mov    %edx,%ecx
  80062c:	89 c2                	mov    %eax,%edx
			base = 8;
  80062e:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800633:	eb aa                	jmp    8005df <vprintfmt+0x284>
			putch('0', putdat);
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	56                   	push   %esi
  800639:	6a 30                	push   $0x30
  80063b:	ff d3                	call   *%ebx
			putch('x', putdat);
  80063d:	83 c4 08             	add    $0x8,%esp
  800640:	56                   	push   %esi
  800641:	6a 78                	push   $0x78
  800643:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8d 50 04             	lea    0x4(%eax),%edx
  80064b:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80064e:	8b 10                	mov    (%eax),%edx
  800650:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800655:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800658:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80065d:	eb 80                	jmp    8005df <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80065f:	89 ca                	mov    %ecx,%edx
  800661:	8d 45 14             	lea    0x14(%ebp),%eax
  800664:	e8 50 fc ff ff       	call   8002b9 <getuint>
  800669:	89 d1                	mov    %edx,%ecx
  80066b:	89 c2                	mov    %eax,%edx
			base = 16;
  80066d:	b8 10 00 00 00       	mov    $0x10,%eax
  800672:	e9 68 ff ff ff       	jmp    8005df <vprintfmt+0x284>
			putch(ch, putdat);
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	56                   	push   %esi
  80067b:	6a 25                	push   $0x25
  80067d:	ff d3                	call   *%ebx
			break;
  80067f:	83 c4 10             	add    $0x10,%esp
  800682:	e9 72 ff ff ff       	jmp    8005f9 <vprintfmt+0x29e>
			putch('%', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	56                   	push   %esi
  80068b:	6a 25                	push   $0x25
  80068d:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	89 f8                	mov    %edi,%eax
  800694:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800698:	74 05                	je     80069f <vprintfmt+0x344>
  80069a:	83 e8 01             	sub    $0x1,%eax
  80069d:	eb f5                	jmp    800694 <vprintfmt+0x339>
  80069f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006a2:	e9 52 ff ff ff       	jmp    8005f9 <vprintfmt+0x29e>
}
  8006a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006aa:	5b                   	pop    %ebx
  8006ab:	5e                   	pop    %esi
  8006ac:	5f                   	pop    %edi
  8006ad:	5d                   	pop    %ebp
  8006ae:	c3                   	ret    

008006af <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006af:	f3 0f 1e fb          	endbr32 
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	83 ec 18             	sub    $0x18,%esp
  8006b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d0:	85 c0                	test   %eax,%eax
  8006d2:	74 26                	je     8006fa <vsnprintf+0x4b>
  8006d4:	85 d2                	test   %edx,%edx
  8006d6:	7e 22                	jle    8006fa <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d8:	ff 75 14             	pushl  0x14(%ebp)
  8006db:	ff 75 10             	pushl  0x10(%ebp)
  8006de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e1:	50                   	push   %eax
  8006e2:	68 19 03 80 00       	push   $0x800319
  8006e7:	e8 6f fc ff ff       	call   80035b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f5:	83 c4 10             	add    $0x10,%esp
}
  8006f8:	c9                   	leave  
  8006f9:	c3                   	ret    
		return -E_INVAL;
  8006fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ff:	eb f7                	jmp    8006f8 <vsnprintf+0x49>

00800701 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800701:	f3 0f 1e fb          	endbr32 
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070e:	50                   	push   %eax
  80070f:	ff 75 10             	pushl  0x10(%ebp)
  800712:	ff 75 0c             	pushl  0xc(%ebp)
  800715:	ff 75 08             	pushl  0x8(%ebp)
  800718:	e8 92 ff ff ff       	call   8006af <vsnprintf>
	va_end(ap);

	return rc;
}
  80071d:	c9                   	leave  
  80071e:	c3                   	ret    

0080071f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071f:	f3 0f 1e fb          	endbr32 
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800729:	b8 00 00 00 00       	mov    $0x0,%eax
  80072e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800732:	74 05                	je     800739 <strlen+0x1a>
		n++;
  800734:	83 c0 01             	add    $0x1,%eax
  800737:	eb f5                	jmp    80072e <strlen+0xf>
	return n;
}
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073b:	f3 0f 1e fb          	endbr32 
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800745:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800748:	b8 00 00 00 00       	mov    $0x0,%eax
  80074d:	39 d0                	cmp    %edx,%eax
  80074f:	74 0d                	je     80075e <strnlen+0x23>
  800751:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800755:	74 05                	je     80075c <strnlen+0x21>
		n++;
  800757:	83 c0 01             	add    $0x1,%eax
  80075a:	eb f1                	jmp    80074d <strnlen+0x12>
  80075c:	89 c2                	mov    %eax,%edx
	return n;
}
  80075e:	89 d0                	mov    %edx,%eax
  800760:	5d                   	pop    %ebp
  800761:	c3                   	ret    

00800762 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800762:	f3 0f 1e fb          	endbr32 
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	53                   	push   %ebx
  80076a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800770:	b8 00 00 00 00       	mov    $0x0,%eax
  800775:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800779:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80077c:	83 c0 01             	add    $0x1,%eax
  80077f:	84 d2                	test   %dl,%dl
  800781:	75 f2                	jne    800775 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800783:	89 c8                	mov    %ecx,%eax
  800785:	5b                   	pop    %ebx
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800788:	f3 0f 1e fb          	endbr32 
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	53                   	push   %ebx
  800790:	83 ec 10             	sub    $0x10,%esp
  800793:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800796:	53                   	push   %ebx
  800797:	e8 83 ff ff ff       	call   80071f <strlen>
  80079c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80079f:	ff 75 0c             	pushl  0xc(%ebp)
  8007a2:	01 d8                	add    %ebx,%eax
  8007a4:	50                   	push   %eax
  8007a5:	e8 b8 ff ff ff       	call   800762 <strcpy>
	return dst;
}
  8007aa:	89 d8                	mov    %ebx,%eax
  8007ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b1:	f3 0f 1e fb          	endbr32 
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	56                   	push   %esi
  8007b9:	53                   	push   %ebx
  8007ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c0:	89 f3                	mov    %esi,%ebx
  8007c2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c5:	89 f0                	mov    %esi,%eax
  8007c7:	39 d8                	cmp    %ebx,%eax
  8007c9:	74 11                	je     8007dc <strncpy+0x2b>
		*dst++ = *src;
  8007cb:	83 c0 01             	add    $0x1,%eax
  8007ce:	0f b6 0a             	movzbl (%edx),%ecx
  8007d1:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d4:	80 f9 01             	cmp    $0x1,%cl
  8007d7:	83 da ff             	sbb    $0xffffffff,%edx
  8007da:	eb eb                	jmp    8007c7 <strncpy+0x16>
	}
	return ret;
}
  8007dc:	89 f0                	mov    %esi,%eax
  8007de:	5b                   	pop    %ebx
  8007df:	5e                   	pop    %esi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e2:	f3 0f 1e fb          	endbr32 
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	56                   	push   %esi
  8007ea:	53                   	push   %ebx
  8007eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	74 21                	je     80081b <strlcpy+0x39>
  8007fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fe:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800800:	39 c2                	cmp    %eax,%edx
  800802:	74 14                	je     800818 <strlcpy+0x36>
  800804:	0f b6 19             	movzbl (%ecx),%ebx
  800807:	84 db                	test   %bl,%bl
  800809:	74 0b                	je     800816 <strlcpy+0x34>
			*dst++ = *src++;
  80080b:	83 c1 01             	add    $0x1,%ecx
  80080e:	83 c2 01             	add    $0x1,%edx
  800811:	88 5a ff             	mov    %bl,-0x1(%edx)
  800814:	eb ea                	jmp    800800 <strlcpy+0x1e>
  800816:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800818:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081b:	29 f0                	sub    %esi,%eax
}
  80081d:	5b                   	pop    %ebx
  80081e:	5e                   	pop    %esi
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800821:	f3 0f 1e fb          	endbr32 
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082e:	0f b6 01             	movzbl (%ecx),%eax
  800831:	84 c0                	test   %al,%al
  800833:	74 0c                	je     800841 <strcmp+0x20>
  800835:	3a 02                	cmp    (%edx),%al
  800837:	75 08                	jne    800841 <strcmp+0x20>
		p++, q++;
  800839:	83 c1 01             	add    $0x1,%ecx
  80083c:	83 c2 01             	add    $0x1,%edx
  80083f:	eb ed                	jmp    80082e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800841:	0f b6 c0             	movzbl %al,%eax
  800844:	0f b6 12             	movzbl (%edx),%edx
  800847:	29 d0                	sub    %edx,%eax
}
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084b:	f3 0f 1e fb          	endbr32 
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	8b 55 0c             	mov    0xc(%ebp),%edx
  800859:	89 c3                	mov    %eax,%ebx
  80085b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085e:	eb 06                	jmp    800866 <strncmp+0x1b>
		n--, p++, q++;
  800860:	83 c0 01             	add    $0x1,%eax
  800863:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800866:	39 d8                	cmp    %ebx,%eax
  800868:	74 16                	je     800880 <strncmp+0x35>
  80086a:	0f b6 08             	movzbl (%eax),%ecx
  80086d:	84 c9                	test   %cl,%cl
  80086f:	74 04                	je     800875 <strncmp+0x2a>
  800871:	3a 0a                	cmp    (%edx),%cl
  800873:	74 eb                	je     800860 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800875:	0f b6 00             	movzbl (%eax),%eax
  800878:	0f b6 12             	movzbl (%edx),%edx
  80087b:	29 d0                	sub    %edx,%eax
}
  80087d:	5b                   	pop    %ebx
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    
		return 0;
  800880:	b8 00 00 00 00       	mov    $0x0,%eax
  800885:	eb f6                	jmp    80087d <strncmp+0x32>

00800887 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800887:	f3 0f 1e fb          	endbr32 
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800895:	0f b6 10             	movzbl (%eax),%edx
  800898:	84 d2                	test   %dl,%dl
  80089a:	74 09                	je     8008a5 <strchr+0x1e>
		if (*s == c)
  80089c:	38 ca                	cmp    %cl,%dl
  80089e:	74 0a                	je     8008aa <strchr+0x23>
	for (; *s; s++)
  8008a0:	83 c0 01             	add    $0x1,%eax
  8008a3:	eb f0                	jmp    800895 <strchr+0xe>
			return (char *) s;
	return 0;
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ac:	f3 0f 1e fb          	endbr32 
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008bd:	38 ca                	cmp    %cl,%dl
  8008bf:	74 09                	je     8008ca <strfind+0x1e>
  8008c1:	84 d2                	test   %dl,%dl
  8008c3:	74 05                	je     8008ca <strfind+0x1e>
	for (; *s; s++)
  8008c5:	83 c0 01             	add    $0x1,%eax
  8008c8:	eb f0                	jmp    8008ba <strfind+0xe>
			break;
	return (char *) s;
}
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008cc:	f3 0f 1e fb          	endbr32 
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	57                   	push   %edi
  8008d4:	56                   	push   %esi
  8008d5:	53                   	push   %ebx
  8008d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8008d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8008dc:	85 c9                	test   %ecx,%ecx
  8008de:	74 33                	je     800913 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e0:	89 d0                	mov    %edx,%eax
  8008e2:	09 c8                	or     %ecx,%eax
  8008e4:	a8 03                	test   $0x3,%al
  8008e6:	75 23                	jne    80090b <memset+0x3f>
		c &= 0xFF;
  8008e8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ec:	89 d8                	mov    %ebx,%eax
  8008ee:	c1 e0 08             	shl    $0x8,%eax
  8008f1:	89 df                	mov    %ebx,%edi
  8008f3:	c1 e7 18             	shl    $0x18,%edi
  8008f6:	89 de                	mov    %ebx,%esi
  8008f8:	c1 e6 10             	shl    $0x10,%esi
  8008fb:	09 f7                	or     %esi,%edi
  8008fd:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  8008ff:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800902:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800904:	89 d7                	mov    %edx,%edi
  800906:	fc                   	cld    
  800907:	f3 ab                	rep stos %eax,%es:(%edi)
  800909:	eb 08                	jmp    800913 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80090b:	89 d7                	mov    %edx,%edi
  80090d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800910:	fc                   	cld    
  800911:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800913:	89 d0                	mov    %edx,%eax
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5f                   	pop    %edi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091a:	f3 0f 1e fb          	endbr32 
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	57                   	push   %edi
  800922:	56                   	push   %esi
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 75 0c             	mov    0xc(%ebp),%esi
  800929:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092c:	39 c6                	cmp    %eax,%esi
  80092e:	73 32                	jae    800962 <memmove+0x48>
  800930:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800933:	39 c2                	cmp    %eax,%edx
  800935:	76 2b                	jbe    800962 <memmove+0x48>
		s += n;
		d += n;
  800937:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093a:	89 fe                	mov    %edi,%esi
  80093c:	09 ce                	or     %ecx,%esi
  80093e:	09 d6                	or     %edx,%esi
  800940:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800946:	75 0e                	jne    800956 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800948:	83 ef 04             	sub    $0x4,%edi
  80094b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80094e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800951:	fd                   	std    
  800952:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800954:	eb 09                	jmp    80095f <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800956:	83 ef 01             	sub    $0x1,%edi
  800959:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80095c:	fd                   	std    
  80095d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80095f:	fc                   	cld    
  800960:	eb 1a                	jmp    80097c <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800962:	89 c2                	mov    %eax,%edx
  800964:	09 ca                	or     %ecx,%edx
  800966:	09 f2                	or     %esi,%edx
  800968:	f6 c2 03             	test   $0x3,%dl
  80096b:	75 0a                	jne    800977 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800970:	89 c7                	mov    %eax,%edi
  800972:	fc                   	cld    
  800973:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800975:	eb 05                	jmp    80097c <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800977:	89 c7                	mov    %eax,%edi
  800979:	fc                   	cld    
  80097a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80097c:	5e                   	pop    %esi
  80097d:	5f                   	pop    %edi
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800980:	f3 0f 1e fb          	endbr32 
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80098a:	ff 75 10             	pushl  0x10(%ebp)
  80098d:	ff 75 0c             	pushl  0xc(%ebp)
  800990:	ff 75 08             	pushl  0x8(%ebp)
  800993:	e8 82 ff ff ff       	call   80091a <memmove>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099a:	f3 0f 1e fb          	endbr32 
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	56                   	push   %esi
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a9:	89 c6                	mov    %eax,%esi
  8009ab:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ae:	39 f0                	cmp    %esi,%eax
  8009b0:	74 1c                	je     8009ce <memcmp+0x34>
		if (*s1 != *s2)
  8009b2:	0f b6 08             	movzbl (%eax),%ecx
  8009b5:	0f b6 1a             	movzbl (%edx),%ebx
  8009b8:	38 d9                	cmp    %bl,%cl
  8009ba:	75 08                	jne    8009c4 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009bc:	83 c0 01             	add    $0x1,%eax
  8009bf:	83 c2 01             	add    $0x1,%edx
  8009c2:	eb ea                	jmp    8009ae <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009c4:	0f b6 c1             	movzbl %cl,%eax
  8009c7:	0f b6 db             	movzbl %bl,%ebx
  8009ca:	29 d8                	sub    %ebx,%eax
  8009cc:	eb 05                	jmp    8009d3 <memcmp+0x39>
	}

	return 0;
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d3:	5b                   	pop    %ebx
  8009d4:	5e                   	pop    %esi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d7:	f3 0f 1e fb          	endbr32 
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e4:	89 c2                	mov    %eax,%edx
  8009e6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e9:	39 d0                	cmp    %edx,%eax
  8009eb:	73 09                	jae    8009f6 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ed:	38 08                	cmp    %cl,(%eax)
  8009ef:	74 05                	je     8009f6 <memfind+0x1f>
	for (; s < ends; s++)
  8009f1:	83 c0 01             	add    $0x1,%eax
  8009f4:	eb f3                	jmp    8009e9 <memfind+0x12>
			break;
	return (void *) s;
}
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f8:	f3 0f 1e fb          	endbr32 
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	57                   	push   %edi
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a08:	eb 03                	jmp    800a0d <strtol+0x15>
		s++;
  800a0a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a0d:	0f b6 01             	movzbl (%ecx),%eax
  800a10:	3c 20                	cmp    $0x20,%al
  800a12:	74 f6                	je     800a0a <strtol+0x12>
  800a14:	3c 09                	cmp    $0x9,%al
  800a16:	74 f2                	je     800a0a <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a18:	3c 2b                	cmp    $0x2b,%al
  800a1a:	74 2a                	je     800a46 <strtol+0x4e>
	int neg = 0;
  800a1c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a21:	3c 2d                	cmp    $0x2d,%al
  800a23:	74 2b                	je     800a50 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a25:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2b:	75 0f                	jne    800a3c <strtol+0x44>
  800a2d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a30:	74 28                	je     800a5a <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a32:	85 db                	test   %ebx,%ebx
  800a34:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a39:	0f 44 d8             	cmove  %eax,%ebx
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a41:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a44:	eb 46                	jmp    800a8c <strtol+0x94>
		s++;
  800a46:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4e:	eb d5                	jmp    800a25 <strtol+0x2d>
		s++, neg = 1;
  800a50:	83 c1 01             	add    $0x1,%ecx
  800a53:	bf 01 00 00 00       	mov    $0x1,%edi
  800a58:	eb cb                	jmp    800a25 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a5e:	74 0e                	je     800a6e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a60:	85 db                	test   %ebx,%ebx
  800a62:	75 d8                	jne    800a3c <strtol+0x44>
		s++, base = 8;
  800a64:	83 c1 01             	add    $0x1,%ecx
  800a67:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a6c:	eb ce                	jmp    800a3c <strtol+0x44>
		s += 2, base = 16;
  800a6e:	83 c1 02             	add    $0x2,%ecx
  800a71:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a76:	eb c4                	jmp    800a3c <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a78:	0f be d2             	movsbl %dl,%edx
  800a7b:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a7e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a81:	7d 3a                	jge    800abd <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a83:	83 c1 01             	add    $0x1,%ecx
  800a86:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a8a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a8c:	0f b6 11             	movzbl (%ecx),%edx
  800a8f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a92:	89 f3                	mov    %esi,%ebx
  800a94:	80 fb 09             	cmp    $0x9,%bl
  800a97:	76 df                	jbe    800a78 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800a99:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9c:	89 f3                	mov    %esi,%ebx
  800a9e:	80 fb 19             	cmp    $0x19,%bl
  800aa1:	77 08                	ja     800aab <strtol+0xb3>
			dig = *s - 'a' + 10;
  800aa3:	0f be d2             	movsbl %dl,%edx
  800aa6:	83 ea 57             	sub    $0x57,%edx
  800aa9:	eb d3                	jmp    800a7e <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800aab:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aae:	89 f3                	mov    %esi,%ebx
  800ab0:	80 fb 19             	cmp    $0x19,%bl
  800ab3:	77 08                	ja     800abd <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ab5:	0f be d2             	movsbl %dl,%edx
  800ab8:	83 ea 37             	sub    $0x37,%edx
  800abb:	eb c1                	jmp    800a7e <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800abd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac1:	74 05                	je     800ac8 <strtol+0xd0>
		*endptr = (char *) s;
  800ac3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ac8:	89 c2                	mov    %eax,%edx
  800aca:	f7 da                	neg    %edx
  800acc:	85 ff                	test   %edi,%edi
  800ace:	0f 45 c2             	cmovne %edx,%eax
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	57                   	push   %edi
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
  800adc:	83 ec 1c             	sub    $0x1c,%esp
  800adf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ae2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ae5:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aed:	8b 7d 10             	mov    0x10(%ebp),%edi
  800af0:	8b 75 14             	mov    0x14(%ebp),%esi
  800af3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800af9:	74 04                	je     800aff <syscall+0x29>
  800afb:	85 c0                	test   %eax,%eax
  800afd:	7f 08                	jg     800b07 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800aff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b07:	83 ec 0c             	sub    $0xc,%esp
  800b0a:	50                   	push   %eax
  800b0b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b0e:	68 ff 26 80 00       	push   $0x8026ff
  800b13:	6a 23                	push   $0x23
  800b15:	68 1c 27 80 00       	push   $0x80271c
  800b1a:	e8 3e 14 00 00       	call   801f5d <_panic>

00800b1f <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800b1f:	f3 0f 1e fb          	endbr32 
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b29:	6a 00                	push   $0x0
  800b2b:	6a 00                	push   $0x0
  800b2d:	6a 00                	push   $0x0
  800b2f:	ff 75 0c             	pushl  0xc(%ebp)
  800b32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b35:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	e8 92 ff ff ff       	call   800ad6 <syscall>
}
  800b44:	83 c4 10             	add    $0x10,%esp
  800b47:	c9                   	leave  
  800b48:	c3                   	ret    

00800b49 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b49:	f3 0f 1e fb          	endbr32 
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b53:	6a 00                	push   $0x0
  800b55:	6a 00                	push   $0x0
  800b57:	6a 00                	push   $0x0
  800b59:	6a 00                	push   $0x0
  800b5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6a:	e8 67 ff ff ff       	call   800ad6 <syscall>
}
  800b6f:	c9                   	leave  
  800b70:	c3                   	ret    

00800b71 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b71:	f3 0f 1e fb          	endbr32 
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b7b:	6a 00                	push   $0x0
  800b7d:	6a 00                	push   $0x0
  800b7f:	6a 00                	push   $0x0
  800b81:	6a 00                	push   $0x0
  800b83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b86:	ba 01 00 00 00       	mov    $0x1,%edx
  800b8b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b90:	e8 41 ff ff ff       	call   800ad6 <syscall>
}
  800b95:	c9                   	leave  
  800b96:	c3                   	ret    

00800b97 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b97:	f3 0f 1e fb          	endbr32 
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ba1:	6a 00                	push   $0x0
  800ba3:	6a 00                	push   $0x0
  800ba5:	6a 00                	push   $0x0
  800ba7:	6a 00                	push   $0x0
  800ba9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bae:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb3:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb8:	e8 19 ff ff ff       	call   800ad6 <syscall>
}
  800bbd:	c9                   	leave  
  800bbe:	c3                   	ret    

00800bbf <sys_yield>:

void
sys_yield(void)
{
  800bbf:	f3 0f 1e fb          	endbr32 
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bc9:	6a 00                	push   $0x0
  800bcb:	6a 00                	push   $0x0
  800bcd:	6a 00                	push   $0x0
  800bcf:	6a 00                	push   $0x0
  800bd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be0:	e8 f1 fe ff ff       	call   800ad6 <syscall>
}
  800be5:	83 c4 10             	add    $0x10,%esp
  800be8:	c9                   	leave  
  800be9:	c3                   	ret    

00800bea <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bea:	f3 0f 1e fb          	endbr32 
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bf4:	6a 00                	push   $0x0
  800bf6:	6a 00                	push   $0x0
  800bf8:	ff 75 10             	pushl  0x10(%ebp)
  800bfb:	ff 75 0c             	pushl  0xc(%ebp)
  800bfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c01:	ba 01 00 00 00       	mov    $0x1,%edx
  800c06:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0b:	e8 c6 fe ff ff       	call   800ad6 <syscall>
}
  800c10:	c9                   	leave  
  800c11:	c3                   	ret    

00800c12 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c12:	f3 0f 1e fb          	endbr32 
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c1c:	ff 75 18             	pushl  0x18(%ebp)
  800c1f:	ff 75 14             	pushl  0x14(%ebp)
  800c22:	ff 75 10             	pushl  0x10(%ebp)
  800c25:	ff 75 0c             	pushl  0xc(%ebp)
  800c28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2b:	ba 01 00 00 00       	mov    $0x1,%edx
  800c30:	b8 05 00 00 00       	mov    $0x5,%eax
  800c35:	e8 9c fe ff ff       	call   800ad6 <syscall>
}
  800c3a:	c9                   	leave  
  800c3b:	c3                   	ret    

00800c3c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3c:	f3 0f 1e fb          	endbr32 
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c46:	6a 00                	push   $0x0
  800c48:	6a 00                	push   $0x0
  800c4a:	6a 00                	push   $0x0
  800c4c:	ff 75 0c             	pushl  0xc(%ebp)
  800c4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c52:	ba 01 00 00 00       	mov    $0x1,%edx
  800c57:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5c:	e8 75 fe ff ff       	call   800ad6 <syscall>
}
  800c61:	c9                   	leave  
  800c62:	c3                   	ret    

00800c63 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c63:	f3 0f 1e fb          	endbr32 
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c6d:	6a 00                	push   $0x0
  800c6f:	6a 00                	push   $0x0
  800c71:	6a 00                	push   $0x0
  800c73:	ff 75 0c             	pushl  0xc(%ebp)
  800c76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c79:	ba 01 00 00 00       	mov    $0x1,%edx
  800c7e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c83:	e8 4e fe ff ff       	call   800ad6 <syscall>
}
  800c88:	c9                   	leave  
  800c89:	c3                   	ret    

00800c8a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c8a:	f3 0f 1e fb          	endbr32 
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c94:	6a 00                	push   $0x0
  800c96:	6a 00                	push   $0x0
  800c98:	6a 00                	push   $0x0
  800c9a:	ff 75 0c             	pushl  0xc(%ebp)
  800c9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca0:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca5:	b8 09 00 00 00       	mov    $0x9,%eax
  800caa:	e8 27 fe ff ff       	call   800ad6 <syscall>
}
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    

00800cb1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb1:	f3 0f 1e fb          	endbr32 
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cbb:	6a 00                	push   $0x0
  800cbd:	6a 00                	push   $0x0
  800cbf:	6a 00                	push   $0x0
  800cc1:	ff 75 0c             	pushl  0xc(%ebp)
  800cc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc7:	ba 01 00 00 00       	mov    $0x1,%edx
  800ccc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd1:	e8 00 fe ff ff       	call   800ad6 <syscall>
}
  800cd6:	c9                   	leave  
  800cd7:	c3                   	ret    

00800cd8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd8:	f3 0f 1e fb          	endbr32 
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800ce2:	6a 00                	push   $0x0
  800ce4:	ff 75 14             	pushl  0x14(%ebp)
  800ce7:	ff 75 10             	pushl  0x10(%ebp)
  800cea:	ff 75 0c             	pushl  0xc(%ebp)
  800ced:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfa:	e8 d7 fd ff ff       	call   800ad6 <syscall>
}
  800cff:	c9                   	leave  
  800d00:	c3                   	ret    

00800d01 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d01:	f3 0f 1e fb          	endbr32 
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d0b:	6a 00                	push   $0x0
  800d0d:	6a 00                	push   $0x0
  800d0f:	6a 00                	push   $0x0
  800d11:	6a 00                	push   $0x0
  800d13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d16:	ba 01 00 00 00       	mov    $0x1,%edx
  800d1b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d20:	e8 b1 fd ff ff       	call   800ad6 <syscall>
}
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    

00800d27 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 04             	sub    $0x4,%esp
	int r;

	// LAB 4: Your code here.
	void *addr = (void *) (pn * PGSIZE);
  800d2e:	89 d3                	mov    %edx,%ebx
  800d30:	c1 e3 0c             	shl    $0xc,%ebx

	if (uvpt[pn] & PTE_SHARE) {
  800d33:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d3a:	f6 c5 04             	test   $0x4,%ch
  800d3d:	75 56                	jne    800d95 <duppage+0x6e>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
		return 0;
	}

	if ((uvpt[pn] & (PTE_W | PTE_COW)) != 0) {
  800d3f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d46:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800d4c:	74 72                	je     800dc0 <duppage+0x99>
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW) <
  800d4e:	83 ec 0c             	sub    $0xc,%esp
  800d51:	68 05 08 00 00       	push   $0x805
  800d56:	53                   	push   %ebx
  800d57:	50                   	push   %eax
  800d58:	53                   	push   %ebx
  800d59:	6a 00                	push   $0x0
  800d5b:	e8 b2 fe ff ff       	call   800c12 <sys_page_map>
  800d60:	83 c4 20             	add    $0x20,%esp
  800d63:	85 c0                	test   %eax,%eax
  800d65:	78 45                	js     800dac <duppage+0x85>
		    0) {
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
		}
		if (sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW) < 0) {
  800d67:	83 ec 0c             	sub    $0xc,%esp
  800d6a:	68 05 08 00 00       	push   $0x805
  800d6f:	53                   	push   %ebx
  800d70:	6a 00                	push   $0x0
  800d72:	53                   	push   %ebx
  800d73:	6a 00                	push   $0x0
  800d75:	e8 98 fe ff ff       	call   800c12 <sys_page_map>
  800d7a:	83 c4 20             	add    $0x20,%esp
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	79 55                	jns    800dd6 <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP FATHER");
  800d81:	83 ec 04             	sub    $0x4,%esp
  800d84:	68 4c 27 80 00       	push   $0x80274c
  800d89:	6a 54                	push   $0x54
  800d8b:	68 df 27 80 00       	push   $0x8027df
  800d90:	e8 c8 11 00 00       	call   801f5d <_panic>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	68 07 0e 00 00       	push   $0xe07
  800d9d:	53                   	push   %ebx
  800d9e:	50                   	push   %eax
  800d9f:	53                   	push   %ebx
  800da0:	6a 00                	push   $0x0
  800da2:	e8 6b fe ff ff       	call   800c12 <sys_page_map>
		return 0;
  800da7:	83 c4 20             	add    $0x20,%esp
  800daa:	eb 2a                	jmp    800dd6 <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
  800dac:	83 ec 04             	sub    $0x4,%esp
  800daf:	68 2c 27 80 00       	push   $0x80272c
  800db4:	6a 51                	push   $0x51
  800db6:	68 df 27 80 00       	push   $0x8027df
  800dbb:	e8 9d 11 00 00       	call   801f5d <_panic>
		}
	} else {
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U) < 0) {
  800dc0:	83 ec 0c             	sub    $0xc,%esp
  800dc3:	6a 05                	push   $0x5
  800dc5:	53                   	push   %ebx
  800dc6:	50                   	push   %eax
  800dc7:	53                   	push   %ebx
  800dc8:	6a 00                	push   $0x0
  800dca:	e8 43 fe ff ff       	call   800c12 <sys_page_map>
  800dcf:	83 c4 20             	add    $0x20,%esp
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	78 0a                	js     800de0 <duppage+0xb9>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
		}
	}

	return 0;
}
  800dd6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ddb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dde:	c9                   	leave  
  800ddf:	c3                   	ret    
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
  800de0:	83 ec 04             	sub    $0x4,%esp
  800de3:	68 ea 27 80 00       	push   $0x8027ea
  800de8:	6a 58                	push   $0x58
  800dea:	68 df 27 80 00       	push   $0x8027df
  800def:	e8 69 11 00 00       	call   801f5d <_panic>

00800df4 <dup_or_share>:

static void
dup_or_share(envid_t dstenv, void *va, int perm)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	89 c6                	mov    %eax,%esi
  800dfb:	89 d3                	mov    %edx,%ebx
	int r;
	if (perm & PTE_W) {
  800dfd:	f6 c1 02             	test   $0x2,%cl
  800e00:	0f 84 8c 00 00 00    	je     800e92 <dup_or_share+0x9e>
		// dup
		if ((r = sys_page_alloc(dstenv, va, PTE_P | PTE_U | PTE_W)) < 0)
  800e06:	83 ec 04             	sub    $0x4,%esp
  800e09:	6a 07                	push   $0x7
  800e0b:	52                   	push   %edx
  800e0c:	50                   	push   %eax
  800e0d:	e8 d8 fd ff ff       	call   800bea <sys_page_alloc>
  800e12:	83 c4 10             	add    $0x10,%esp
  800e15:	85 c0                	test   %eax,%eax
  800e17:	78 55                	js     800e6e <dup_or_share+0x7a>
			panic("sys_page_alloc: %e", r);
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  800e19:	83 ec 0c             	sub    $0xc,%esp
  800e1c:	6a 07                	push   $0x7
  800e1e:	68 00 00 40 00       	push   $0x400000
  800e23:	6a 00                	push   $0x0
  800e25:	53                   	push   %ebx
  800e26:	56                   	push   %esi
  800e27:	e8 e6 fd ff ff       	call   800c12 <sys_page_map>
  800e2c:	83 c4 20             	add    $0x20,%esp
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	78 4d                	js     800e80 <dup_or_share+0x8c>
		    0)
			panic("sys_page_map: %e", r);
		memmove(UTEMP, va, PGSIZE);
  800e33:	83 ec 04             	sub    $0x4,%esp
  800e36:	68 00 10 00 00       	push   $0x1000
  800e3b:	53                   	push   %ebx
  800e3c:	68 00 00 40 00       	push   $0x400000
  800e41:	e8 d4 fa ff ff       	call   80091a <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800e46:	83 c4 08             	add    $0x8,%esp
  800e49:	68 00 00 40 00       	push   $0x400000
  800e4e:	6a 00                	push   $0x0
  800e50:	e8 e7 fd ff ff       	call   800c3c <sys_page_unmap>
  800e55:	83 c4 10             	add    $0x10,%esp
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	79 52                	jns    800eae <dup_or_share+0xba>
			panic("sys_page_unmap: %e", r);
  800e5c:	50                   	push   %eax
  800e5d:	68 2a 28 80 00       	push   $0x80282a
  800e62:	6a 6c                	push   $0x6c
  800e64:	68 df 27 80 00       	push   $0x8027df
  800e69:	e8 ef 10 00 00       	call   801f5d <_panic>
			panic("sys_page_alloc: %e", r);
  800e6e:	50                   	push   %eax
  800e6f:	68 06 28 80 00       	push   $0x802806
  800e74:	6a 66                	push   $0x66
  800e76:	68 df 27 80 00       	push   $0x8027df
  800e7b:	e8 dd 10 00 00       	call   801f5d <_panic>
			panic("sys_page_map: %e", r);
  800e80:	50                   	push   %eax
  800e81:	68 19 28 80 00       	push   $0x802819
  800e86:	6a 69                	push   $0x69
  800e88:	68 df 27 80 00       	push   $0x8027df
  800e8d:	e8 cb 10 00 00       	call   801f5d <_panic>

	} else {
		// share
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | perm)) <
  800e92:	83 ec 0c             	sub    $0xc,%esp
  800e95:	83 c9 05             	or     $0x5,%ecx
  800e98:	51                   	push   %ecx
  800e99:	68 00 00 40 00       	push   $0x400000
  800e9e:	6a 00                	push   $0x0
  800ea0:	52                   	push   %edx
  800ea1:	50                   	push   %eax
  800ea2:	e8 6b fd ff ff       	call   800c12 <sys_page_map>
  800ea7:	83 c4 20             	add    $0x20,%esp
  800eaa:	85 c0                	test   %eax,%eax
  800eac:	78 07                	js     800eb5 <dup_or_share+0xc1>
		    0)
			panic("sys_page_map: %e", r);
	}
}
  800eae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    
			panic("sys_page_map: %e", r);
  800eb5:	50                   	push   %eax
  800eb6:	68 19 28 80 00       	push   $0x802819
  800ebb:	6a 72                	push   $0x72
  800ebd:	68 df 27 80 00       	push   $0x8027df
  800ec2:	e8 96 10 00 00       	call   801f5d <_panic>

00800ec7 <pgfault>:
{
  800ec7:	f3 0f 1e fb          	endbr32 
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	53                   	push   %ebx
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800ed5:	8b 02                	mov    (%edx),%eax
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800ed7:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800edb:	0f 84 95 00 00 00    	je     800f76 <pgfault+0xaf>
  800ee1:	89 c2                	mov    %eax,%edx
  800ee3:	c1 ea 16             	shr    $0x16,%edx
  800ee6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eed:	f6 c2 01             	test   $0x1,%dl
  800ef0:	0f 84 80 00 00 00    	je     800f76 <pgfault+0xaf>
	    (~uvpt[PGNUM(addr)] & (PTE_COW | PTE_P)) != 0) {
  800ef6:	89 c2                	mov    %eax,%edx
  800ef8:	c1 ea 0c             	shr    $0xc,%edx
  800efb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f02:	f7 d2                	not    %edx
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800f04:	f7 c2 01 08 00 00    	test   $0x801,%edx
  800f0a:	75 6a                	jne    800f76 <pgfault+0xaf>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800f0c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f11:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U) < 0) {
  800f13:	83 ec 04             	sub    $0x4,%esp
  800f16:	6a 07                	push   $0x7
  800f18:	68 00 f0 7f 00       	push   $0x7ff000
  800f1d:	6a 00                	push   $0x0
  800f1f:	e8 c6 fc ff ff       	call   800bea <sys_page_alloc>
  800f24:	83 c4 10             	add    $0x10,%esp
  800f27:	85 c0                	test   %eax,%eax
  800f29:	78 5f                	js     800f8a <pgfault+0xc3>
	memcpy((void *) PFTEMP, addr, PGSIZE);
  800f2b:	83 ec 04             	sub    $0x4,%esp
  800f2e:	68 00 10 00 00       	push   $0x1000
  800f33:	53                   	push   %ebx
  800f34:	68 00 f0 7f 00       	push   $0x7ff000
  800f39:	e8 42 fa ff ff       	call   800980 <memcpy>
	if (sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U) < 0) {
  800f3e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f45:	53                   	push   %ebx
  800f46:	6a 00                	push   $0x0
  800f48:	68 00 f0 7f 00       	push   $0x7ff000
  800f4d:	6a 00                	push   $0x0
  800f4f:	e8 be fc ff ff       	call   800c12 <sys_page_map>
  800f54:	83 c4 20             	add    $0x20,%esp
  800f57:	85 c0                	test   %eax,%eax
  800f59:	78 43                	js     800f9e <pgfault+0xd7>
	if (sys_page_unmap(0, (void *) PFTEMP) < 0) {
  800f5b:	83 ec 08             	sub    $0x8,%esp
  800f5e:	68 00 f0 7f 00       	push   $0x7ff000
  800f63:	6a 00                	push   $0x0
  800f65:	e8 d2 fc ff ff       	call   800c3c <sys_page_unmap>
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	78 41                	js     800fb2 <pgfault+0xeb>
}
  800f71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f74:	c9                   	leave  
  800f75:	c3                   	ret    
		panic("ERROR PGFAULT");
  800f76:	83 ec 04             	sub    $0x4,%esp
  800f79:	68 3d 28 80 00       	push   $0x80283d
  800f7e:	6a 1e                	push   $0x1e
  800f80:	68 df 27 80 00       	push   $0x8027df
  800f85:	e8 d3 0f 00 00       	call   801f5d <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_ALLOC");
  800f8a:	83 ec 04             	sub    $0x4,%esp
  800f8d:	68 4b 28 80 00       	push   $0x80284b
  800f92:	6a 2b                	push   $0x2b
  800f94:	68 df 27 80 00       	push   $0x8027df
  800f99:	e8 bf 0f 00 00       	call   801f5d <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_MAP");
  800f9e:	83 ec 04             	sub    $0x4,%esp
  800fa1:	68 69 28 80 00       	push   $0x802869
  800fa6:	6a 2f                	push   $0x2f
  800fa8:	68 df 27 80 00       	push   $0x8027df
  800fad:	e8 ab 0f 00 00       	call   801f5d <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_UNMAP");
  800fb2:	83 ec 04             	sub    $0x4,%esp
  800fb5:	68 85 28 80 00       	push   $0x802885
  800fba:	6a 32                	push   $0x32
  800fbc:	68 df 27 80 00       	push   $0x8027df
  800fc1:	e8 97 0f 00 00       	call   801f5d <_panic>

00800fc6 <fork_v0>:

envid_t
fork_v0(void)
{
  800fc6:	f3 0f 1e fb          	endbr32 
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fd3:	b8 07 00 00 00       	mov    $0x7,%eax
  800fd8:	cd 30                	int    $0x30
	envid_t env_id = sys_exofork();
	if (env_id < 0) {
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	78 24                	js     801002 <fork_v0+0x3c>
  800fde:	89 c6                	mov    %eax,%esi
  800fe0:	89 c7                	mov    %eax,%edi
		thisenv = envs + ENVX(sys_getenvid());
		return env_id;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  800fe2:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (env_id == 0) {  // Son
  800fe7:	75 51                	jne    80103a <fork_v0+0x74>
		thisenv = envs + ENVX(sys_getenvid());
  800fe9:	e8 a9 fb ff ff       	call   800b97 <sys_getenvid>
  800fee:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ff3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ff6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ffb:	a3 04 40 80 00       	mov    %eax,0x804004
		return env_id;
  801000:	eb 78                	jmp    80107a <fork_v0+0xb4>
		panic("ERROR ON FORK_V0");
  801002:	83 ec 04             	sub    $0x4,%esp
  801005:	68 a3 28 80 00       	push   $0x8028a3
  80100a:	6a 7b                	push   $0x7b
  80100c:	68 df 27 80 00       	push   $0x8027df
  801011:	e8 47 0f 00 00       	call   801f5d <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
				dup_or_share(env_id,
  801016:	b9 07 00 00 00       	mov    $0x7,%ecx
  80101b:	89 da                	mov    %ebx,%edx
  80101d:	89 f8                	mov    %edi,%eax
  80101f:	e8 d0 fd ff ff       	call   800df4 <dup_or_share>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801024:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80102a:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801030:	77 36                	ja     801068 <fork_v0+0xa2>
		if (addr != UXSTACKTOP - PGSIZE) {
  801032:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801038:	74 ea                	je     801024 <fork_v0+0x5e>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80103a:	89 d8                	mov    %ebx,%eax
  80103c:	c1 e8 16             	shr    $0x16,%eax
  80103f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801046:	a8 01                	test   $0x1,%al
  801048:	74 da                	je     801024 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  80104a:	89 d8                	mov    %ebx,%eax
  80104c:	c1 e8 0c             	shr    $0xc,%eax
  80104f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801056:	f6 c2 01             	test   $0x1,%dl
  801059:	74 c9                	je     801024 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
  80105b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  801062:	a8 04                	test   $0x4,%al
  801064:	74 be                	je     801024 <fork_v0+0x5e>
  801066:	eb ae                	jmp    801016 <fork_v0+0x50>
				             PTE_P | PTE_U | PTE_W);
			}
		}
	}

	if (sys_env_set_status(env_id, ENV_RUNNABLE) < 0) {
  801068:	83 ec 08             	sub    $0x8,%esp
  80106b:	6a 02                	push   $0x2
  80106d:	56                   	push   %esi
  80106e:	e8 f0 fb ff ff       	call   800c63 <sys_env_set_status>
  801073:	83 c4 10             	add    $0x10,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 0a                	js     801084 <fork_v0+0xbe>
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
	}

	return env_id;
}
  80107a:	89 f0                	mov    %esi,%eax
  80107c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107f:	5b                   	pop    %ebx
  801080:	5e                   	pop    %esi
  801081:	5f                   	pop    %edi
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
  801084:	83 ec 04             	sub    $0x4,%esp
  801087:	68 70 27 80 00       	push   $0x802770
  80108c:	68 92 00 00 00       	push   $0x92
  801091:	68 df 27 80 00       	push   $0x8027df
  801096:	e8 c2 0e 00 00       	call   801f5d <_panic>

0080109b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80109b:	f3 0f 1e fb          	endbr32 
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	57                   	push   %edi
  8010a3:	56                   	push   %esi
  8010a4:	53                   	push   %ebx
  8010a5:	83 ec 18             	sub    $0x18,%esp
	// return fork_v0(); // Uncomment this line if you want to run fork_v0.
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8010a8:	68 c7 0e 80 00       	push   $0x800ec7
  8010ad:	e8 f5 0e 00 00       	call   801fa7 <set_pgfault_handler>
  8010b2:	b8 07 00 00 00       	mov    $0x7,%eax
  8010b7:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0) {
  8010b9:	83 c4 10             	add    $0x10,%esp
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	78 27                	js     8010e7 <fork+0x4c>
  8010c0:	89 c7                	mov    %eax,%edi
  8010c2:	89 c6                	mov    %eax,%esi
		thisenv = envs + ENVX(sys_getenvid());
		return envid;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  8010c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else if (envid == 0) {  // Son
  8010c9:	75 55                	jne    801120 <fork+0x85>
		thisenv = envs + ENVX(sys_getenvid());
  8010cb:	e8 c7 fa ff ff       	call   800b97 <sys_getenvid>
  8010d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010d5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010dd:	a3 04 40 80 00       	mov    %eax,0x804004
		return envid;
  8010e2:	e9 9b 00 00 00       	jmp    801182 <fork+0xe7>
		panic("ERROR IN FORK: SYS_EXOFORK");
  8010e7:	83 ec 04             	sub    $0x4,%esp
  8010ea:	68 b4 28 80 00       	push   $0x8028b4
  8010ef:	68 b1 00 00 00       	push   $0xb1
  8010f4:	68 df 27 80 00       	push   $0x8027df
  8010f9:	e8 5f 0e 00 00       	call   801f5d <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
				duppage(envid, addr / PGSIZE);
  8010fe:	89 da                	mov    %ebx,%edx
  801100:	c1 ea 0c             	shr    $0xc,%edx
  801103:	89 f0                	mov    %esi,%eax
  801105:	e8 1d fc ff ff       	call   800d27 <duppage>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  80110a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801110:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801116:	77 2c                	ja     801144 <fork+0xa9>
		if (addr != UXSTACKTOP - PGSIZE) {
  801118:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80111e:	74 ea                	je     80110a <fork+0x6f>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801120:	89 d8                	mov    %ebx,%eax
  801122:	c1 e8 16             	shr    $0x16,%eax
  801125:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80112c:	a8 01                	test   $0x1,%al
  80112e:	74 da                	je     80110a <fork+0x6f>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
  801130:	89 d8                	mov    %ebx,%eax
  801132:	c1 e8 0c             	shr    $0xc,%eax
  801135:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80113c:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80113e:	a8 05                	test   $0x5,%al
  801140:	75 c8                	jne    80110a <fork+0x6f>
  801142:	eb ba                	jmp    8010fe <fork+0x63>
			}
		}
	}

	if (sys_page_alloc(envid,
  801144:	83 ec 04             	sub    $0x4,%esp
  801147:	6a 07                	push   $0x7
  801149:	68 00 f0 bf ee       	push   $0xeebff000
  80114e:	57                   	push   %edi
  80114f:	e8 96 fa ff ff       	call   800bea <sys_page_alloc>
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	85 c0                	test   %eax,%eax
  801159:	78 31                	js     80118c <fork+0xf1>
	                   PTE_P | PTE_U | PTE_W) < 0) {
		panic("ERROR FORK: SYS_PAGE_ALLOC");
	}

	extern void _pgfault_upcall(void);
	if (sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0) {
  80115b:	83 ec 08             	sub    $0x8,%esp
  80115e:	68 1a 20 80 00       	push   $0x80201a
  801163:	57                   	push   %edi
  801164:	e8 48 fb ff ff       	call   800cb1 <sys_env_set_pgfault_upcall>
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	85 c0                	test   %eax,%eax
  80116e:	78 33                	js     8011a3 <fork+0x108>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
	}

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0) {
  801170:	83 ec 08             	sub    $0x8,%esp
  801173:	6a 02                	push   $0x2
  801175:	57                   	push   %edi
  801176:	e8 e8 fa ff ff       	call   800c63 <sys_env_set_status>
  80117b:	83 c4 10             	add    $0x10,%esp
  80117e:	85 c0                	test   %eax,%eax
  801180:	78 38                	js     8011ba <fork+0x11f>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
	}

	return envid;
}
  801182:	89 f8                	mov    %edi,%eax
  801184:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801187:	5b                   	pop    %ebx
  801188:	5e                   	pop    %esi
  801189:	5f                   	pop    %edi
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    
		panic("ERROR FORK: SYS_PAGE_ALLOC");
  80118c:	83 ec 04             	sub    $0x4,%esp
  80118f:	68 cf 28 80 00       	push   $0x8028cf
  801194:	68 c4 00 00 00       	push   $0xc4
  801199:	68 df 27 80 00       	push   $0x8027df
  80119e:	e8 ba 0d 00 00       	call   801f5d <_panic>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
  8011a3:	83 ec 04             	sub    $0x4,%esp
  8011a6:	68 98 27 80 00       	push   $0x802798
  8011ab:	68 c9 00 00 00       	push   $0xc9
  8011b0:	68 df 27 80 00       	push   $0x8027df
  8011b5:	e8 a3 0d 00 00       	call   801f5d <_panic>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
  8011ba:	83 ec 04             	sub    $0x4,%esp
  8011bd:	68 c0 27 80 00       	push   $0x8027c0
  8011c2:	68 cd 00 00 00       	push   $0xcd
  8011c7:	68 df 27 80 00       	push   $0x8027df
  8011cc:	e8 8c 0d 00 00       	call   801f5d <_panic>

008011d1 <sfork>:

// Challenge!
int
sfork(void)
{
  8011d1:	f3 0f 1e fb          	endbr32 
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011db:	68 ea 28 80 00       	push   $0x8028ea
  8011e0:	68 d7 00 00 00       	push   $0xd7
  8011e5:	68 df 27 80 00       	push   $0x8027df
  8011ea:	e8 6e 0d 00 00       	call   801f5d <_panic>

008011ef <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011ef:	f3 0f 1e fb          	endbr32 
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f9:	05 00 00 00 30       	add    $0x30000000,%eax
  8011fe:	c1 e8 0c             	shr    $0xc,%eax
}
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801203:	f3 0f 1e fb          	endbr32 
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  80120d:	ff 75 08             	pushl  0x8(%ebp)
  801210:	e8 da ff ff ff       	call   8011ef <fd2num>
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	c1 e0 0c             	shl    $0xc,%eax
  80121b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801220:	c9                   	leave  
  801221:	c3                   	ret    

00801222 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801222:	f3 0f 1e fb          	endbr32 
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80122e:	89 c2                	mov    %eax,%edx
  801230:	c1 ea 16             	shr    $0x16,%edx
  801233:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80123a:	f6 c2 01             	test   $0x1,%dl
  80123d:	74 2d                	je     80126c <fd_alloc+0x4a>
  80123f:	89 c2                	mov    %eax,%edx
  801241:	c1 ea 0c             	shr    $0xc,%edx
  801244:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124b:	f6 c2 01             	test   $0x1,%dl
  80124e:	74 1c                	je     80126c <fd_alloc+0x4a>
  801250:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801255:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80125a:	75 d2                	jne    80122e <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80125c:	8b 45 08             	mov    0x8(%ebp),%eax
  80125f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801265:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80126a:	eb 0a                	jmp    801276 <fd_alloc+0x54>
			*fd_store = fd;
  80126c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801271:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    

00801278 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801278:	f3 0f 1e fb          	endbr32 
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801282:	83 f8 1f             	cmp    $0x1f,%eax
  801285:	77 30                	ja     8012b7 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801287:	c1 e0 0c             	shl    $0xc,%eax
  80128a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80128f:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801295:	f6 c2 01             	test   $0x1,%dl
  801298:	74 24                	je     8012be <fd_lookup+0x46>
  80129a:	89 c2                	mov    %eax,%edx
  80129c:	c1 ea 0c             	shr    $0xc,%edx
  80129f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a6:	f6 c2 01             	test   $0x1,%dl
  8012a9:	74 1a                	je     8012c5 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ae:	89 02                	mov    %eax,(%edx)
	return 0;
  8012b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b5:	5d                   	pop    %ebp
  8012b6:	c3                   	ret    
		return -E_INVAL;
  8012b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012bc:	eb f7                	jmp    8012b5 <fd_lookup+0x3d>
		return -E_INVAL;
  8012be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c3:	eb f0                	jmp    8012b5 <fd_lookup+0x3d>
  8012c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ca:	eb e9                	jmp    8012b5 <fd_lookup+0x3d>

008012cc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012cc:	f3 0f 1e fb          	endbr32 
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	83 ec 08             	sub    $0x8,%esp
  8012d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d9:	ba 7c 29 80 00       	mov    $0x80297c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012de:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012e3:	39 08                	cmp    %ecx,(%eax)
  8012e5:	74 33                	je     80131a <dev_lookup+0x4e>
  8012e7:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8012ea:	8b 02                	mov    (%edx),%eax
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	75 f3                	jne    8012e3 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012f0:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f5:	8b 40 48             	mov    0x48(%eax),%eax
  8012f8:	83 ec 04             	sub    $0x4,%esp
  8012fb:	51                   	push   %ecx
  8012fc:	50                   	push   %eax
  8012fd:	68 00 29 80 00       	push   $0x802900
  801302:	e8 f1 ee ff ff       	call   8001f8 <cprintf>
	*dev = 0;
  801307:	8b 45 0c             	mov    0xc(%ebp),%eax
  80130a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801310:	83 c4 10             	add    $0x10,%esp
  801313:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801318:	c9                   	leave  
  801319:	c3                   	ret    
			*dev = devtab[i];
  80131a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80131d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80131f:	b8 00 00 00 00       	mov    $0x0,%eax
  801324:	eb f2                	jmp    801318 <dev_lookup+0x4c>

00801326 <fd_close>:
{
  801326:	f3 0f 1e fb          	endbr32 
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	57                   	push   %edi
  80132e:	56                   	push   %esi
  80132f:	53                   	push   %ebx
  801330:	83 ec 28             	sub    $0x28,%esp
  801333:	8b 75 08             	mov    0x8(%ebp),%esi
  801336:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801339:	56                   	push   %esi
  80133a:	e8 b0 fe ff ff       	call   8011ef <fd2num>
  80133f:	83 c4 08             	add    $0x8,%esp
  801342:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801345:	52                   	push   %edx
  801346:	50                   	push   %eax
  801347:	e8 2c ff ff ff       	call   801278 <fd_lookup>
  80134c:	89 c3                	mov    %eax,%ebx
  80134e:	83 c4 10             	add    $0x10,%esp
  801351:	85 c0                	test   %eax,%eax
  801353:	78 05                	js     80135a <fd_close+0x34>
	    || fd != fd2)
  801355:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801358:	74 16                	je     801370 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80135a:	89 f8                	mov    %edi,%eax
  80135c:	84 c0                	test   %al,%al
  80135e:	b8 00 00 00 00       	mov    $0x0,%eax
  801363:	0f 44 d8             	cmove  %eax,%ebx
}
  801366:	89 d8                	mov    %ebx,%eax
  801368:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80136b:	5b                   	pop    %ebx
  80136c:	5e                   	pop    %esi
  80136d:	5f                   	pop    %edi
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801370:	83 ec 08             	sub    $0x8,%esp
  801373:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801376:	50                   	push   %eax
  801377:	ff 36                	pushl  (%esi)
  801379:	e8 4e ff ff ff       	call   8012cc <dev_lookup>
  80137e:	89 c3                	mov    %eax,%ebx
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	85 c0                	test   %eax,%eax
  801385:	78 1a                	js     8013a1 <fd_close+0x7b>
		if (dev->dev_close)
  801387:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80138a:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80138d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801392:	85 c0                	test   %eax,%eax
  801394:	74 0b                	je     8013a1 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801396:	83 ec 0c             	sub    $0xc,%esp
  801399:	56                   	push   %esi
  80139a:	ff d0                	call   *%eax
  80139c:	89 c3                	mov    %eax,%ebx
  80139e:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013a1:	83 ec 08             	sub    $0x8,%esp
  8013a4:	56                   	push   %esi
  8013a5:	6a 00                	push   $0x0
  8013a7:	e8 90 f8 ff ff       	call   800c3c <sys_page_unmap>
	return r;
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	eb b5                	jmp    801366 <fd_close+0x40>

008013b1 <close>:

int
close(int fdnum)
{
  8013b1:	f3 0f 1e fb          	endbr32 
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013be:	50                   	push   %eax
  8013bf:	ff 75 08             	pushl  0x8(%ebp)
  8013c2:	e8 b1 fe ff ff       	call   801278 <fd_lookup>
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	79 02                	jns    8013d0 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8013ce:	c9                   	leave  
  8013cf:	c3                   	ret    
		return fd_close(fd, 1);
  8013d0:	83 ec 08             	sub    $0x8,%esp
  8013d3:	6a 01                	push   $0x1
  8013d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8013d8:	e8 49 ff ff ff       	call   801326 <fd_close>
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	eb ec                	jmp    8013ce <close+0x1d>

008013e2 <close_all>:

void
close_all(void)
{
  8013e2:	f3 0f 1e fb          	endbr32 
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	53                   	push   %ebx
  8013ea:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f2:	83 ec 0c             	sub    $0xc,%esp
  8013f5:	53                   	push   %ebx
  8013f6:	e8 b6 ff ff ff       	call   8013b1 <close>
	for (i = 0; i < MAXFD; i++)
  8013fb:	83 c3 01             	add    $0x1,%ebx
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	83 fb 20             	cmp    $0x20,%ebx
  801404:	75 ec                	jne    8013f2 <close_all+0x10>
}
  801406:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801409:	c9                   	leave  
  80140a:	c3                   	ret    

0080140b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80140b:	f3 0f 1e fb          	endbr32 
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	57                   	push   %edi
  801413:	56                   	push   %esi
  801414:	53                   	push   %ebx
  801415:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801418:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80141b:	50                   	push   %eax
  80141c:	ff 75 08             	pushl  0x8(%ebp)
  80141f:	e8 54 fe ff ff       	call   801278 <fd_lookup>
  801424:	89 c3                	mov    %eax,%ebx
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	85 c0                	test   %eax,%eax
  80142b:	0f 88 81 00 00 00    	js     8014b2 <dup+0xa7>
		return r;
	close(newfdnum);
  801431:	83 ec 0c             	sub    $0xc,%esp
  801434:	ff 75 0c             	pushl  0xc(%ebp)
  801437:	e8 75 ff ff ff       	call   8013b1 <close>

	newfd = INDEX2FD(newfdnum);
  80143c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80143f:	c1 e6 0c             	shl    $0xc,%esi
  801442:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801448:	83 c4 04             	add    $0x4,%esp
  80144b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80144e:	e8 b0 fd ff ff       	call   801203 <fd2data>
  801453:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801455:	89 34 24             	mov    %esi,(%esp)
  801458:	e8 a6 fd ff ff       	call   801203 <fd2data>
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801462:	89 d8                	mov    %ebx,%eax
  801464:	c1 e8 16             	shr    $0x16,%eax
  801467:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80146e:	a8 01                	test   $0x1,%al
  801470:	74 11                	je     801483 <dup+0x78>
  801472:	89 d8                	mov    %ebx,%eax
  801474:	c1 e8 0c             	shr    $0xc,%eax
  801477:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80147e:	f6 c2 01             	test   $0x1,%dl
  801481:	75 39                	jne    8014bc <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801483:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801486:	89 d0                	mov    %edx,%eax
  801488:	c1 e8 0c             	shr    $0xc,%eax
  80148b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801492:	83 ec 0c             	sub    $0xc,%esp
  801495:	25 07 0e 00 00       	and    $0xe07,%eax
  80149a:	50                   	push   %eax
  80149b:	56                   	push   %esi
  80149c:	6a 00                	push   $0x0
  80149e:	52                   	push   %edx
  80149f:	6a 00                	push   $0x0
  8014a1:	e8 6c f7 ff ff       	call   800c12 <sys_page_map>
  8014a6:	89 c3                	mov    %eax,%ebx
  8014a8:	83 c4 20             	add    $0x20,%esp
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 31                	js     8014e0 <dup+0xd5>
		goto err;

	return newfdnum;
  8014af:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014b2:	89 d8                	mov    %ebx,%eax
  8014b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	5f                   	pop    %edi
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c3:	83 ec 0c             	sub    $0xc,%esp
  8014c6:	25 07 0e 00 00       	and    $0xe07,%eax
  8014cb:	50                   	push   %eax
  8014cc:	57                   	push   %edi
  8014cd:	6a 00                	push   $0x0
  8014cf:	53                   	push   %ebx
  8014d0:	6a 00                	push   $0x0
  8014d2:	e8 3b f7 ff ff       	call   800c12 <sys_page_map>
  8014d7:	89 c3                	mov    %eax,%ebx
  8014d9:	83 c4 20             	add    $0x20,%esp
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	79 a3                	jns    801483 <dup+0x78>
	sys_page_unmap(0, newfd);
  8014e0:	83 ec 08             	sub    $0x8,%esp
  8014e3:	56                   	push   %esi
  8014e4:	6a 00                	push   $0x0
  8014e6:	e8 51 f7 ff ff       	call   800c3c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014eb:	83 c4 08             	add    $0x8,%esp
  8014ee:	57                   	push   %edi
  8014ef:	6a 00                	push   $0x0
  8014f1:	e8 46 f7 ff ff       	call   800c3c <sys_page_unmap>
	return r;
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	eb b7                	jmp    8014b2 <dup+0xa7>

008014fb <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014fb:	f3 0f 1e fb          	endbr32 
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	53                   	push   %ebx
  801503:	83 ec 1c             	sub    $0x1c,%esp
  801506:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801509:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80150c:	50                   	push   %eax
  80150d:	53                   	push   %ebx
  80150e:	e8 65 fd ff ff       	call   801278 <fd_lookup>
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	85 c0                	test   %eax,%eax
  801518:	78 3f                	js     801559 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151a:	83 ec 08             	sub    $0x8,%esp
  80151d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801520:	50                   	push   %eax
  801521:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801524:	ff 30                	pushl  (%eax)
  801526:	e8 a1 fd ff ff       	call   8012cc <dev_lookup>
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 27                	js     801559 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801532:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801535:	8b 42 08             	mov    0x8(%edx),%eax
  801538:	83 e0 03             	and    $0x3,%eax
  80153b:	83 f8 01             	cmp    $0x1,%eax
  80153e:	74 1e                	je     80155e <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801540:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801543:	8b 40 08             	mov    0x8(%eax),%eax
  801546:	85 c0                	test   %eax,%eax
  801548:	74 35                	je     80157f <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80154a:	83 ec 04             	sub    $0x4,%esp
  80154d:	ff 75 10             	pushl  0x10(%ebp)
  801550:	ff 75 0c             	pushl  0xc(%ebp)
  801553:	52                   	push   %edx
  801554:	ff d0                	call   *%eax
  801556:	83 c4 10             	add    $0x10,%esp
}
  801559:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155c:	c9                   	leave  
  80155d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80155e:	a1 04 40 80 00       	mov    0x804004,%eax
  801563:	8b 40 48             	mov    0x48(%eax),%eax
  801566:	83 ec 04             	sub    $0x4,%esp
  801569:	53                   	push   %ebx
  80156a:	50                   	push   %eax
  80156b:	68 41 29 80 00       	push   $0x802941
  801570:	e8 83 ec ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  801575:	83 c4 10             	add    $0x10,%esp
  801578:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80157d:	eb da                	jmp    801559 <read+0x5e>
		return -E_NOT_SUPP;
  80157f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801584:	eb d3                	jmp    801559 <read+0x5e>

00801586 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801586:	f3 0f 1e fb          	endbr32 
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	57                   	push   %edi
  80158e:	56                   	push   %esi
  80158f:	53                   	push   %ebx
  801590:	83 ec 0c             	sub    $0xc,%esp
  801593:	8b 7d 08             	mov    0x8(%ebp),%edi
  801596:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801599:	bb 00 00 00 00       	mov    $0x0,%ebx
  80159e:	eb 02                	jmp    8015a2 <readn+0x1c>
  8015a0:	01 c3                	add    %eax,%ebx
  8015a2:	39 f3                	cmp    %esi,%ebx
  8015a4:	73 21                	jae    8015c7 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a6:	83 ec 04             	sub    $0x4,%esp
  8015a9:	89 f0                	mov    %esi,%eax
  8015ab:	29 d8                	sub    %ebx,%eax
  8015ad:	50                   	push   %eax
  8015ae:	89 d8                	mov    %ebx,%eax
  8015b0:	03 45 0c             	add    0xc(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	57                   	push   %edi
  8015b5:	e8 41 ff ff ff       	call   8014fb <read>
		if (m < 0)
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	78 04                	js     8015c5 <readn+0x3f>
			return m;
		if (m == 0)
  8015c1:	75 dd                	jne    8015a0 <readn+0x1a>
  8015c3:	eb 02                	jmp    8015c7 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015c5:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015c7:	89 d8                	mov    %ebx,%eax
  8015c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015cc:	5b                   	pop    %ebx
  8015cd:	5e                   	pop    %esi
  8015ce:	5f                   	pop    %edi
  8015cf:	5d                   	pop    %ebp
  8015d0:	c3                   	ret    

008015d1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015d1:	f3 0f 1e fb          	endbr32 
  8015d5:	55                   	push   %ebp
  8015d6:	89 e5                	mov    %esp,%ebp
  8015d8:	53                   	push   %ebx
  8015d9:	83 ec 1c             	sub    $0x1c,%esp
  8015dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e2:	50                   	push   %eax
  8015e3:	53                   	push   %ebx
  8015e4:	e8 8f fc ff ff       	call   801278 <fd_lookup>
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 3a                	js     80162a <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f0:	83 ec 08             	sub    $0x8,%esp
  8015f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f6:	50                   	push   %eax
  8015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015fa:	ff 30                	pushl  (%eax)
  8015fc:	e8 cb fc ff ff       	call   8012cc <dev_lookup>
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	85 c0                	test   %eax,%eax
  801606:	78 22                	js     80162a <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801608:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80160f:	74 1e                	je     80162f <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801611:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801614:	8b 52 0c             	mov    0xc(%edx),%edx
  801617:	85 d2                	test   %edx,%edx
  801619:	74 35                	je     801650 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80161b:	83 ec 04             	sub    $0x4,%esp
  80161e:	ff 75 10             	pushl  0x10(%ebp)
  801621:	ff 75 0c             	pushl  0xc(%ebp)
  801624:	50                   	push   %eax
  801625:	ff d2                	call   *%edx
  801627:	83 c4 10             	add    $0x10,%esp
}
  80162a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162d:	c9                   	leave  
  80162e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80162f:	a1 04 40 80 00       	mov    0x804004,%eax
  801634:	8b 40 48             	mov    0x48(%eax),%eax
  801637:	83 ec 04             	sub    $0x4,%esp
  80163a:	53                   	push   %ebx
  80163b:	50                   	push   %eax
  80163c:	68 5d 29 80 00       	push   $0x80295d
  801641:	e8 b2 eb ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80164e:	eb da                	jmp    80162a <write+0x59>
		return -E_NOT_SUPP;
  801650:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801655:	eb d3                	jmp    80162a <write+0x59>

00801657 <seek>:

int
seek(int fdnum, off_t offset)
{
  801657:	f3 0f 1e fb          	endbr32 
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801661:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801664:	50                   	push   %eax
  801665:	ff 75 08             	pushl  0x8(%ebp)
  801668:	e8 0b fc ff ff       	call   801278 <fd_lookup>
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	85 c0                	test   %eax,%eax
  801672:	78 0e                	js     801682 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801674:	8b 55 0c             	mov    0xc(%ebp),%edx
  801677:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80167d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801682:	c9                   	leave  
  801683:	c3                   	ret    

00801684 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801684:	f3 0f 1e fb          	endbr32 
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	53                   	push   %ebx
  80168c:	83 ec 1c             	sub    $0x1c,%esp
  80168f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801692:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801695:	50                   	push   %eax
  801696:	53                   	push   %ebx
  801697:	e8 dc fb ff ff       	call   801278 <fd_lookup>
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	78 37                	js     8016da <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a3:	83 ec 08             	sub    $0x8,%esp
  8016a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a9:	50                   	push   %eax
  8016aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ad:	ff 30                	pushl  (%eax)
  8016af:	e8 18 fc ff ff       	call   8012cc <dev_lookup>
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	78 1f                	js     8016da <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016be:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c2:	74 1b                	je     8016df <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c7:	8b 52 18             	mov    0x18(%edx),%edx
  8016ca:	85 d2                	test   %edx,%edx
  8016cc:	74 32                	je     801700 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ce:	83 ec 08             	sub    $0x8,%esp
  8016d1:	ff 75 0c             	pushl  0xc(%ebp)
  8016d4:	50                   	push   %eax
  8016d5:	ff d2                	call   *%edx
  8016d7:	83 c4 10             	add    $0x10,%esp
}
  8016da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016df:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016e4:	8b 40 48             	mov    0x48(%eax),%eax
  8016e7:	83 ec 04             	sub    $0x4,%esp
  8016ea:	53                   	push   %ebx
  8016eb:	50                   	push   %eax
  8016ec:	68 20 29 80 00       	push   $0x802920
  8016f1:	e8 02 eb ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016fe:	eb da                	jmp    8016da <ftruncate+0x56>
		return -E_NOT_SUPP;
  801700:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801705:	eb d3                	jmp    8016da <ftruncate+0x56>

00801707 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801707:	f3 0f 1e fb          	endbr32 
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	53                   	push   %ebx
  80170f:	83 ec 1c             	sub    $0x1c,%esp
  801712:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801715:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801718:	50                   	push   %eax
  801719:	ff 75 08             	pushl  0x8(%ebp)
  80171c:	e8 57 fb ff ff       	call   801278 <fd_lookup>
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	85 c0                	test   %eax,%eax
  801726:	78 4b                	js     801773 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801728:	83 ec 08             	sub    $0x8,%esp
  80172b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172e:	50                   	push   %eax
  80172f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801732:	ff 30                	pushl  (%eax)
  801734:	e8 93 fb ff ff       	call   8012cc <dev_lookup>
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 33                	js     801773 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801740:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801743:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801747:	74 2f                	je     801778 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801749:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80174c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801753:	00 00 00 
	stat->st_isdir = 0;
  801756:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80175d:	00 00 00 
	stat->st_dev = dev;
  801760:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801766:	83 ec 08             	sub    $0x8,%esp
  801769:	53                   	push   %ebx
  80176a:	ff 75 f0             	pushl  -0x10(%ebp)
  80176d:	ff 50 14             	call   *0x14(%eax)
  801770:	83 c4 10             	add    $0x10,%esp
}
  801773:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801776:	c9                   	leave  
  801777:	c3                   	ret    
		return -E_NOT_SUPP;
  801778:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80177d:	eb f4                	jmp    801773 <fstat+0x6c>

0080177f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80177f:	f3 0f 1e fb          	endbr32 
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	56                   	push   %esi
  801787:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801788:	83 ec 08             	sub    $0x8,%esp
  80178b:	6a 00                	push   $0x0
  80178d:	ff 75 08             	pushl  0x8(%ebp)
  801790:	e8 20 02 00 00       	call   8019b5 <open>
  801795:	89 c3                	mov    %eax,%ebx
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 1b                	js     8017b9 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80179e:	83 ec 08             	sub    $0x8,%esp
  8017a1:	ff 75 0c             	pushl  0xc(%ebp)
  8017a4:	50                   	push   %eax
  8017a5:	e8 5d ff ff ff       	call   801707 <fstat>
  8017aa:	89 c6                	mov    %eax,%esi
	close(fd);
  8017ac:	89 1c 24             	mov    %ebx,(%esp)
  8017af:	e8 fd fb ff ff       	call   8013b1 <close>
	return r;
  8017b4:	83 c4 10             	add    $0x10,%esp
  8017b7:	89 f3                	mov    %esi,%ebx
}
  8017b9:	89 d8                	mov    %ebx,%eax
  8017bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017be:	5b                   	pop    %ebx
  8017bf:	5e                   	pop    %esi
  8017c0:	5d                   	pop    %ebp
  8017c1:	c3                   	ret    

008017c2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	56                   	push   %esi
  8017c6:	53                   	push   %ebx
  8017c7:	89 c6                	mov    %eax,%esi
  8017c9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017cb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017d2:	74 27                	je     8017fb <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017d4:	6a 07                	push   $0x7
  8017d6:	68 00 50 80 00       	push   $0x805000
  8017db:	56                   	push   %esi
  8017dc:	ff 35 00 40 80 00    	pushl  0x804000
  8017e2:	e8 c6 08 00 00       	call   8020ad <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017e7:	83 c4 0c             	add    $0xc,%esp
  8017ea:	6a 00                	push   $0x0
  8017ec:	53                   	push   %ebx
  8017ed:	6a 00                	push   $0x0
  8017ef:	e8 4c 08 00 00       	call   802040 <ipc_recv>
}
  8017f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f7:	5b                   	pop    %ebx
  8017f8:	5e                   	pop    %esi
  8017f9:	5d                   	pop    %ebp
  8017fa:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017fb:	83 ec 0c             	sub    $0xc,%esp
  8017fe:	6a 01                	push   $0x1
  801800:	e8 fb 08 00 00       	call   802100 <ipc_find_env>
  801805:	a3 00 40 80 00       	mov    %eax,0x804000
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	eb c5                	jmp    8017d4 <fsipc+0x12>

0080180f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80180f:	f3 0f 1e fb          	endbr32 
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801819:	8b 45 08             	mov    0x8(%ebp),%eax
  80181c:	8b 40 0c             	mov    0xc(%eax),%eax
  80181f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801824:	8b 45 0c             	mov    0xc(%ebp),%eax
  801827:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80182c:	ba 00 00 00 00       	mov    $0x0,%edx
  801831:	b8 02 00 00 00       	mov    $0x2,%eax
  801836:	e8 87 ff ff ff       	call   8017c2 <fsipc>
}
  80183b:	c9                   	leave  
  80183c:	c3                   	ret    

0080183d <devfile_flush>:
{
  80183d:	f3 0f 1e fb          	endbr32 
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801847:	8b 45 08             	mov    0x8(%ebp),%eax
  80184a:	8b 40 0c             	mov    0xc(%eax),%eax
  80184d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801852:	ba 00 00 00 00       	mov    $0x0,%edx
  801857:	b8 06 00 00 00       	mov    $0x6,%eax
  80185c:	e8 61 ff ff ff       	call   8017c2 <fsipc>
}
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <devfile_stat>:
{
  801863:	f3 0f 1e fb          	endbr32 
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	53                   	push   %ebx
  80186b:	83 ec 04             	sub    $0x4,%esp
  80186e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801871:	8b 45 08             	mov    0x8(%ebp),%eax
  801874:	8b 40 0c             	mov    0xc(%eax),%eax
  801877:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80187c:	ba 00 00 00 00       	mov    $0x0,%edx
  801881:	b8 05 00 00 00       	mov    $0x5,%eax
  801886:	e8 37 ff ff ff       	call   8017c2 <fsipc>
  80188b:	85 c0                	test   %eax,%eax
  80188d:	78 2c                	js     8018bb <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80188f:	83 ec 08             	sub    $0x8,%esp
  801892:	68 00 50 80 00       	push   $0x805000
  801897:	53                   	push   %ebx
  801898:	e8 c5 ee ff ff       	call   800762 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80189d:	a1 80 50 80 00       	mov    0x805080,%eax
  8018a2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018a8:	a1 84 50 80 00       	mov    0x805084,%eax
  8018ad:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018be:	c9                   	leave  
  8018bf:	c3                   	ret    

008018c0 <devfile_write>:
{
  8018c0:	f3 0f 1e fb          	endbr32 
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	57                   	push   %edi
  8018c8:	56                   	push   %esi
  8018c9:	53                   	push   %ebx
  8018ca:	83 ec 0c             	sub    $0xc,%esp
  8018cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d9:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  8018de:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8018e3:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  8018e8:	85 db                	test   %ebx,%ebx
  8018ea:	74 3b                	je     801927 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8018ec:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8018f2:	89 f8                	mov    %edi,%eax
  8018f4:	0f 46 c3             	cmovbe %ebx,%eax
  8018f7:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  8018fc:	83 ec 04             	sub    $0x4,%esp
  8018ff:	50                   	push   %eax
  801900:	56                   	push   %esi
  801901:	68 08 50 80 00       	push   $0x805008
  801906:	e8 0f f0 ff ff       	call   80091a <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80190b:	ba 00 00 00 00       	mov    $0x0,%edx
  801910:	b8 04 00 00 00       	mov    $0x4,%eax
  801915:	e8 a8 fe ff ff       	call   8017c2 <fsipc>
  80191a:	83 c4 10             	add    $0x10,%esp
  80191d:	85 c0                	test   %eax,%eax
  80191f:	78 06                	js     801927 <devfile_write+0x67>
		buf_aux += r;
  801921:	01 c6                	add    %eax,%esi
		n -= r;
  801923:	29 c3                	sub    %eax,%ebx
  801925:	eb c1                	jmp    8018e8 <devfile_write+0x28>
}
  801927:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80192a:	5b                   	pop    %ebx
  80192b:	5e                   	pop    %esi
  80192c:	5f                   	pop    %edi
  80192d:	5d                   	pop    %ebp
  80192e:	c3                   	ret    

0080192f <devfile_read>:
{
  80192f:	f3 0f 1e fb          	endbr32 
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	56                   	push   %esi
  801937:	53                   	push   %ebx
  801938:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80193b:	8b 45 08             	mov    0x8(%ebp),%eax
  80193e:	8b 40 0c             	mov    0xc(%eax),%eax
  801941:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801946:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80194c:	ba 00 00 00 00       	mov    $0x0,%edx
  801951:	b8 03 00 00 00       	mov    $0x3,%eax
  801956:	e8 67 fe ff ff       	call   8017c2 <fsipc>
  80195b:	89 c3                	mov    %eax,%ebx
  80195d:	85 c0                	test   %eax,%eax
  80195f:	78 1f                	js     801980 <devfile_read+0x51>
	assert(r <= n);
  801961:	39 f0                	cmp    %esi,%eax
  801963:	77 24                	ja     801989 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801965:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80196a:	7f 33                	jg     80199f <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80196c:	83 ec 04             	sub    $0x4,%esp
  80196f:	50                   	push   %eax
  801970:	68 00 50 80 00       	push   $0x805000
  801975:	ff 75 0c             	pushl  0xc(%ebp)
  801978:	e8 9d ef ff ff       	call   80091a <memmove>
	return r;
  80197d:	83 c4 10             	add    $0x10,%esp
}
  801980:	89 d8                	mov    %ebx,%eax
  801982:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801985:	5b                   	pop    %ebx
  801986:	5e                   	pop    %esi
  801987:	5d                   	pop    %ebp
  801988:	c3                   	ret    
	assert(r <= n);
  801989:	68 8c 29 80 00       	push   $0x80298c
  80198e:	68 93 29 80 00       	push   $0x802993
  801993:	6a 7c                	push   $0x7c
  801995:	68 a8 29 80 00       	push   $0x8029a8
  80199a:	e8 be 05 00 00       	call   801f5d <_panic>
	assert(r <= PGSIZE);
  80199f:	68 b3 29 80 00       	push   $0x8029b3
  8019a4:	68 93 29 80 00       	push   $0x802993
  8019a9:	6a 7d                	push   $0x7d
  8019ab:	68 a8 29 80 00       	push   $0x8029a8
  8019b0:	e8 a8 05 00 00       	call   801f5d <_panic>

008019b5 <open>:
{
  8019b5:	f3 0f 1e fb          	endbr32 
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	56                   	push   %esi
  8019bd:	53                   	push   %ebx
  8019be:	83 ec 1c             	sub    $0x1c,%esp
  8019c1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019c4:	56                   	push   %esi
  8019c5:	e8 55 ed ff ff       	call   80071f <strlen>
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019d2:	7f 6c                	jg     801a40 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8019d4:	83 ec 0c             	sub    $0xc,%esp
  8019d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019da:	50                   	push   %eax
  8019db:	e8 42 f8 ff ff       	call   801222 <fd_alloc>
  8019e0:	89 c3                	mov    %eax,%ebx
  8019e2:	83 c4 10             	add    $0x10,%esp
  8019e5:	85 c0                	test   %eax,%eax
  8019e7:	78 3c                	js     801a25 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8019e9:	83 ec 08             	sub    $0x8,%esp
  8019ec:	56                   	push   %esi
  8019ed:	68 00 50 80 00       	push   $0x805000
  8019f2:	e8 6b ed ff ff       	call   800762 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fa:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a02:	b8 01 00 00 00       	mov    $0x1,%eax
  801a07:	e8 b6 fd ff ff       	call   8017c2 <fsipc>
  801a0c:	89 c3                	mov    %eax,%ebx
  801a0e:	83 c4 10             	add    $0x10,%esp
  801a11:	85 c0                	test   %eax,%eax
  801a13:	78 19                	js     801a2e <open+0x79>
	return fd2num(fd);
  801a15:	83 ec 0c             	sub    $0xc,%esp
  801a18:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1b:	e8 cf f7 ff ff       	call   8011ef <fd2num>
  801a20:	89 c3                	mov    %eax,%ebx
  801a22:	83 c4 10             	add    $0x10,%esp
}
  801a25:	89 d8                	mov    %ebx,%eax
  801a27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2a:	5b                   	pop    %ebx
  801a2b:	5e                   	pop    %esi
  801a2c:	5d                   	pop    %ebp
  801a2d:	c3                   	ret    
		fd_close(fd, 0);
  801a2e:	83 ec 08             	sub    $0x8,%esp
  801a31:	6a 00                	push   $0x0
  801a33:	ff 75 f4             	pushl  -0xc(%ebp)
  801a36:	e8 eb f8 ff ff       	call   801326 <fd_close>
		return r;
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	eb e5                	jmp    801a25 <open+0x70>
		return -E_BAD_PATH;
  801a40:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a45:	eb de                	jmp    801a25 <open+0x70>

00801a47 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a47:	f3 0f 1e fb          	endbr32 
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a51:	ba 00 00 00 00       	mov    $0x0,%edx
  801a56:	b8 08 00 00 00       	mov    $0x8,%eax
  801a5b:	e8 62 fd ff ff       	call   8017c2 <fsipc>
}
  801a60:	c9                   	leave  
  801a61:	c3                   	ret    

00801a62 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a62:	f3 0f 1e fb          	endbr32 
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	56                   	push   %esi
  801a6a:	53                   	push   %ebx
  801a6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	ff 75 08             	pushl  0x8(%ebp)
  801a74:	e8 8a f7 ff ff       	call   801203 <fd2data>
  801a79:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a7b:	83 c4 08             	add    $0x8,%esp
  801a7e:	68 bf 29 80 00       	push   $0x8029bf
  801a83:	53                   	push   %ebx
  801a84:	e8 d9 ec ff ff       	call   800762 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a89:	8b 46 04             	mov    0x4(%esi),%eax
  801a8c:	2b 06                	sub    (%esi),%eax
  801a8e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a94:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a9b:	00 00 00 
	stat->st_dev = &devpipe;
  801a9e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801aa5:	30 80 00 
	return 0;
}
  801aa8:	b8 00 00 00 00       	mov    $0x0,%eax
  801aad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab0:	5b                   	pop    %ebx
  801ab1:	5e                   	pop    %esi
  801ab2:	5d                   	pop    %ebp
  801ab3:	c3                   	ret    

00801ab4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ab4:	f3 0f 1e fb          	endbr32 
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	53                   	push   %ebx
  801abc:	83 ec 0c             	sub    $0xc,%esp
  801abf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ac2:	53                   	push   %ebx
  801ac3:	6a 00                	push   $0x0
  801ac5:	e8 72 f1 ff ff       	call   800c3c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aca:	89 1c 24             	mov    %ebx,(%esp)
  801acd:	e8 31 f7 ff ff       	call   801203 <fd2data>
  801ad2:	83 c4 08             	add    $0x8,%esp
  801ad5:	50                   	push   %eax
  801ad6:	6a 00                	push   $0x0
  801ad8:	e8 5f f1 ff ff       	call   800c3c <sys_page_unmap>
}
  801add:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae0:	c9                   	leave  
  801ae1:	c3                   	ret    

00801ae2 <_pipeisclosed>:
{
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	57                   	push   %edi
  801ae6:	56                   	push   %esi
  801ae7:	53                   	push   %ebx
  801ae8:	83 ec 1c             	sub    $0x1c,%esp
  801aeb:	89 c7                	mov    %eax,%edi
  801aed:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801aef:	a1 04 40 80 00       	mov    0x804004,%eax
  801af4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801af7:	83 ec 0c             	sub    $0xc,%esp
  801afa:	57                   	push   %edi
  801afb:	e8 3d 06 00 00       	call   80213d <pageref>
  801b00:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b03:	89 34 24             	mov    %esi,(%esp)
  801b06:	e8 32 06 00 00       	call   80213d <pageref>
		nn = thisenv->env_runs;
  801b0b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b11:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b14:	83 c4 10             	add    $0x10,%esp
  801b17:	39 cb                	cmp    %ecx,%ebx
  801b19:	74 1b                	je     801b36 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b1b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b1e:	75 cf                	jne    801aef <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b20:	8b 42 58             	mov    0x58(%edx),%eax
  801b23:	6a 01                	push   $0x1
  801b25:	50                   	push   %eax
  801b26:	53                   	push   %ebx
  801b27:	68 c6 29 80 00       	push   $0x8029c6
  801b2c:	e8 c7 e6 ff ff       	call   8001f8 <cprintf>
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	eb b9                	jmp    801aef <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b36:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b39:	0f 94 c0             	sete   %al
  801b3c:	0f b6 c0             	movzbl %al,%eax
}
  801b3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b42:	5b                   	pop    %ebx
  801b43:	5e                   	pop    %esi
  801b44:	5f                   	pop    %edi
  801b45:	5d                   	pop    %ebp
  801b46:	c3                   	ret    

00801b47 <devpipe_write>:
{
  801b47:	f3 0f 1e fb          	endbr32 
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	57                   	push   %edi
  801b4f:	56                   	push   %esi
  801b50:	53                   	push   %ebx
  801b51:	83 ec 28             	sub    $0x28,%esp
  801b54:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b57:	56                   	push   %esi
  801b58:	e8 a6 f6 ff ff       	call   801203 <fd2data>
  801b5d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	bf 00 00 00 00       	mov    $0x0,%edi
  801b67:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b6a:	74 4f                	je     801bbb <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b6c:	8b 43 04             	mov    0x4(%ebx),%eax
  801b6f:	8b 0b                	mov    (%ebx),%ecx
  801b71:	8d 51 20             	lea    0x20(%ecx),%edx
  801b74:	39 d0                	cmp    %edx,%eax
  801b76:	72 14                	jb     801b8c <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801b78:	89 da                	mov    %ebx,%edx
  801b7a:	89 f0                	mov    %esi,%eax
  801b7c:	e8 61 ff ff ff       	call   801ae2 <_pipeisclosed>
  801b81:	85 c0                	test   %eax,%eax
  801b83:	75 3b                	jne    801bc0 <devpipe_write+0x79>
			sys_yield();
  801b85:	e8 35 f0 ff ff       	call   800bbf <sys_yield>
  801b8a:	eb e0                	jmp    801b6c <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b93:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b96:	89 c2                	mov    %eax,%edx
  801b98:	c1 fa 1f             	sar    $0x1f,%edx
  801b9b:	89 d1                	mov    %edx,%ecx
  801b9d:	c1 e9 1b             	shr    $0x1b,%ecx
  801ba0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ba3:	83 e2 1f             	and    $0x1f,%edx
  801ba6:	29 ca                	sub    %ecx,%edx
  801ba8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bb0:	83 c0 01             	add    $0x1,%eax
  801bb3:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801bb6:	83 c7 01             	add    $0x1,%edi
  801bb9:	eb ac                	jmp    801b67 <devpipe_write+0x20>
	return i;
  801bbb:	8b 45 10             	mov    0x10(%ebp),%eax
  801bbe:	eb 05                	jmp    801bc5 <devpipe_write+0x7e>
				return 0;
  801bc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc8:	5b                   	pop    %ebx
  801bc9:	5e                   	pop    %esi
  801bca:	5f                   	pop    %edi
  801bcb:	5d                   	pop    %ebp
  801bcc:	c3                   	ret    

00801bcd <devpipe_read>:
{
  801bcd:	f3 0f 1e fb          	endbr32 
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	57                   	push   %edi
  801bd5:	56                   	push   %esi
  801bd6:	53                   	push   %ebx
  801bd7:	83 ec 18             	sub    $0x18,%esp
  801bda:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801bdd:	57                   	push   %edi
  801bde:	e8 20 f6 ff ff       	call   801203 <fd2data>
  801be3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801be5:	83 c4 10             	add    $0x10,%esp
  801be8:	be 00 00 00 00       	mov    $0x0,%esi
  801bed:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bf0:	75 14                	jne    801c06 <devpipe_read+0x39>
	return i;
  801bf2:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf5:	eb 02                	jmp    801bf9 <devpipe_read+0x2c>
				return i;
  801bf7:	89 f0                	mov    %esi,%eax
}
  801bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfc:	5b                   	pop    %ebx
  801bfd:	5e                   	pop    %esi
  801bfe:	5f                   	pop    %edi
  801bff:	5d                   	pop    %ebp
  801c00:	c3                   	ret    
			sys_yield();
  801c01:	e8 b9 ef ff ff       	call   800bbf <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c06:	8b 03                	mov    (%ebx),%eax
  801c08:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c0b:	75 18                	jne    801c25 <devpipe_read+0x58>
			if (i > 0)
  801c0d:	85 f6                	test   %esi,%esi
  801c0f:	75 e6                	jne    801bf7 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801c11:	89 da                	mov    %ebx,%edx
  801c13:	89 f8                	mov    %edi,%eax
  801c15:	e8 c8 fe ff ff       	call   801ae2 <_pipeisclosed>
  801c1a:	85 c0                	test   %eax,%eax
  801c1c:	74 e3                	je     801c01 <devpipe_read+0x34>
				return 0;
  801c1e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c23:	eb d4                	jmp    801bf9 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c25:	99                   	cltd   
  801c26:	c1 ea 1b             	shr    $0x1b,%edx
  801c29:	01 d0                	add    %edx,%eax
  801c2b:	83 e0 1f             	and    $0x1f,%eax
  801c2e:	29 d0                	sub    %edx,%eax
  801c30:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c38:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c3b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c3e:	83 c6 01             	add    $0x1,%esi
  801c41:	eb aa                	jmp    801bed <devpipe_read+0x20>

00801c43 <pipe>:
{
  801c43:	f3 0f 1e fb          	endbr32 
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	56                   	push   %esi
  801c4b:	53                   	push   %ebx
  801c4c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c52:	50                   	push   %eax
  801c53:	e8 ca f5 ff ff       	call   801222 <fd_alloc>
  801c58:	89 c3                	mov    %eax,%ebx
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	0f 88 23 01 00 00    	js     801d88 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c65:	83 ec 04             	sub    $0x4,%esp
  801c68:	68 07 04 00 00       	push   $0x407
  801c6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c70:	6a 00                	push   $0x0
  801c72:	e8 73 ef ff ff       	call   800bea <sys_page_alloc>
  801c77:	89 c3                	mov    %eax,%ebx
  801c79:	83 c4 10             	add    $0x10,%esp
  801c7c:	85 c0                	test   %eax,%eax
  801c7e:	0f 88 04 01 00 00    	js     801d88 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801c84:	83 ec 0c             	sub    $0xc,%esp
  801c87:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c8a:	50                   	push   %eax
  801c8b:	e8 92 f5 ff ff       	call   801222 <fd_alloc>
  801c90:	89 c3                	mov    %eax,%ebx
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	85 c0                	test   %eax,%eax
  801c97:	0f 88 db 00 00 00    	js     801d78 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9d:	83 ec 04             	sub    $0x4,%esp
  801ca0:	68 07 04 00 00       	push   $0x407
  801ca5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca8:	6a 00                	push   $0x0
  801caa:	e8 3b ef ff ff       	call   800bea <sys_page_alloc>
  801caf:	89 c3                	mov    %eax,%ebx
  801cb1:	83 c4 10             	add    $0x10,%esp
  801cb4:	85 c0                	test   %eax,%eax
  801cb6:	0f 88 bc 00 00 00    	js     801d78 <pipe+0x135>
	va = fd2data(fd0);
  801cbc:	83 ec 0c             	sub    $0xc,%esp
  801cbf:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc2:	e8 3c f5 ff ff       	call   801203 <fd2data>
  801cc7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc9:	83 c4 0c             	add    $0xc,%esp
  801ccc:	68 07 04 00 00       	push   $0x407
  801cd1:	50                   	push   %eax
  801cd2:	6a 00                	push   $0x0
  801cd4:	e8 11 ef ff ff       	call   800bea <sys_page_alloc>
  801cd9:	89 c3                	mov    %eax,%ebx
  801cdb:	83 c4 10             	add    $0x10,%esp
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	0f 88 82 00 00 00    	js     801d68 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce6:	83 ec 0c             	sub    $0xc,%esp
  801ce9:	ff 75 f0             	pushl  -0x10(%ebp)
  801cec:	e8 12 f5 ff ff       	call   801203 <fd2data>
  801cf1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cf8:	50                   	push   %eax
  801cf9:	6a 00                	push   $0x0
  801cfb:	56                   	push   %esi
  801cfc:	6a 00                	push   $0x0
  801cfe:	e8 0f ef ff ff       	call   800c12 <sys_page_map>
  801d03:	89 c3                	mov    %eax,%ebx
  801d05:	83 c4 20             	add    $0x20,%esp
  801d08:	85 c0                	test   %eax,%eax
  801d0a:	78 4e                	js     801d5a <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801d0c:	a1 20 30 80 00       	mov    0x803020,%eax
  801d11:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d14:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d16:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d19:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d20:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d23:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d28:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d2f:	83 ec 0c             	sub    $0xc,%esp
  801d32:	ff 75 f4             	pushl  -0xc(%ebp)
  801d35:	e8 b5 f4 ff ff       	call   8011ef <fd2num>
  801d3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d3d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d3f:	83 c4 04             	add    $0x4,%esp
  801d42:	ff 75 f0             	pushl  -0x10(%ebp)
  801d45:	e8 a5 f4 ff ff       	call   8011ef <fd2num>
  801d4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d4d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d50:	83 c4 10             	add    $0x10,%esp
  801d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d58:	eb 2e                	jmp    801d88 <pipe+0x145>
	sys_page_unmap(0, va);
  801d5a:	83 ec 08             	sub    $0x8,%esp
  801d5d:	56                   	push   %esi
  801d5e:	6a 00                	push   $0x0
  801d60:	e8 d7 ee ff ff       	call   800c3c <sys_page_unmap>
  801d65:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d68:	83 ec 08             	sub    $0x8,%esp
  801d6b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d6e:	6a 00                	push   $0x0
  801d70:	e8 c7 ee ff ff       	call   800c3c <sys_page_unmap>
  801d75:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d78:	83 ec 08             	sub    $0x8,%esp
  801d7b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7e:	6a 00                	push   $0x0
  801d80:	e8 b7 ee ff ff       	call   800c3c <sys_page_unmap>
  801d85:	83 c4 10             	add    $0x10,%esp
}
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d8d:	5b                   	pop    %ebx
  801d8e:	5e                   	pop    %esi
  801d8f:	5d                   	pop    %ebp
  801d90:	c3                   	ret    

00801d91 <pipeisclosed>:
{
  801d91:	f3 0f 1e fb          	endbr32 
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d9e:	50                   	push   %eax
  801d9f:	ff 75 08             	pushl  0x8(%ebp)
  801da2:	e8 d1 f4 ff ff       	call   801278 <fd_lookup>
  801da7:	83 c4 10             	add    $0x10,%esp
  801daa:	85 c0                	test   %eax,%eax
  801dac:	78 18                	js     801dc6 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801dae:	83 ec 0c             	sub    $0xc,%esp
  801db1:	ff 75 f4             	pushl  -0xc(%ebp)
  801db4:	e8 4a f4 ff ff       	call   801203 <fd2data>
  801db9:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbe:	e8 1f fd ff ff       	call   801ae2 <_pipeisclosed>
  801dc3:	83 c4 10             	add    $0x10,%esp
}
  801dc6:	c9                   	leave  
  801dc7:	c3                   	ret    

00801dc8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dc8:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801dcc:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd1:	c3                   	ret    

00801dd2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dd2:	f3 0f 1e fb          	endbr32 
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ddc:	68 de 29 80 00       	push   $0x8029de
  801de1:	ff 75 0c             	pushl  0xc(%ebp)
  801de4:	e8 79 e9 ff ff       	call   800762 <strcpy>
	return 0;
}
  801de9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dee:	c9                   	leave  
  801def:	c3                   	ret    

00801df0 <devcons_write>:
{
  801df0:	f3 0f 1e fb          	endbr32 
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	57                   	push   %edi
  801df8:	56                   	push   %esi
  801df9:	53                   	push   %ebx
  801dfa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e00:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e05:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e0b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e0e:	73 31                	jae    801e41 <devcons_write+0x51>
		m = n - tot;
  801e10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e13:	29 f3                	sub    %esi,%ebx
  801e15:	83 fb 7f             	cmp    $0x7f,%ebx
  801e18:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e1d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e20:	83 ec 04             	sub    $0x4,%esp
  801e23:	53                   	push   %ebx
  801e24:	89 f0                	mov    %esi,%eax
  801e26:	03 45 0c             	add    0xc(%ebp),%eax
  801e29:	50                   	push   %eax
  801e2a:	57                   	push   %edi
  801e2b:	e8 ea ea ff ff       	call   80091a <memmove>
		sys_cputs(buf, m);
  801e30:	83 c4 08             	add    $0x8,%esp
  801e33:	53                   	push   %ebx
  801e34:	57                   	push   %edi
  801e35:	e8 e5 ec ff ff       	call   800b1f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e3a:	01 de                	add    %ebx,%esi
  801e3c:	83 c4 10             	add    $0x10,%esp
  801e3f:	eb ca                	jmp    801e0b <devcons_write+0x1b>
}
  801e41:	89 f0                	mov    %esi,%eax
  801e43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e46:	5b                   	pop    %ebx
  801e47:	5e                   	pop    %esi
  801e48:	5f                   	pop    %edi
  801e49:	5d                   	pop    %ebp
  801e4a:	c3                   	ret    

00801e4b <devcons_read>:
{
  801e4b:	f3 0f 1e fb          	endbr32 
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	83 ec 08             	sub    $0x8,%esp
  801e55:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e5e:	74 21                	je     801e81 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801e60:	e8 e4 ec ff ff       	call   800b49 <sys_cgetc>
  801e65:	85 c0                	test   %eax,%eax
  801e67:	75 07                	jne    801e70 <devcons_read+0x25>
		sys_yield();
  801e69:	e8 51 ed ff ff       	call   800bbf <sys_yield>
  801e6e:	eb f0                	jmp    801e60 <devcons_read+0x15>
	if (c < 0)
  801e70:	78 0f                	js     801e81 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801e72:	83 f8 04             	cmp    $0x4,%eax
  801e75:	74 0c                	je     801e83 <devcons_read+0x38>
	*(char*)vbuf = c;
  801e77:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e7a:	88 02                	mov    %al,(%edx)
	return 1;
  801e7c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801e81:	c9                   	leave  
  801e82:	c3                   	ret    
		return 0;
  801e83:	b8 00 00 00 00       	mov    $0x0,%eax
  801e88:	eb f7                	jmp    801e81 <devcons_read+0x36>

00801e8a <cputchar>:
{
  801e8a:	f3 0f 1e fb          	endbr32 
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e94:	8b 45 08             	mov    0x8(%ebp),%eax
  801e97:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e9a:	6a 01                	push   $0x1
  801e9c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e9f:	50                   	push   %eax
  801ea0:	e8 7a ec ff ff       	call   800b1f <sys_cputs>
}
  801ea5:	83 c4 10             	add    $0x10,%esp
  801ea8:	c9                   	leave  
  801ea9:	c3                   	ret    

00801eaa <getchar>:
{
  801eaa:	f3 0f 1e fb          	endbr32 
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801eb4:	6a 01                	push   $0x1
  801eb6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eb9:	50                   	push   %eax
  801eba:	6a 00                	push   $0x0
  801ebc:	e8 3a f6 ff ff       	call   8014fb <read>
	if (r < 0)
  801ec1:	83 c4 10             	add    $0x10,%esp
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	78 06                	js     801ece <getchar+0x24>
	if (r < 1)
  801ec8:	74 06                	je     801ed0 <getchar+0x26>
	return c;
  801eca:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ece:	c9                   	leave  
  801ecf:	c3                   	ret    
		return -E_EOF;
  801ed0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ed5:	eb f7                	jmp    801ece <getchar+0x24>

00801ed7 <iscons>:
{
  801ed7:	f3 0f 1e fb          	endbr32 
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ee1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee4:	50                   	push   %eax
  801ee5:	ff 75 08             	pushl  0x8(%ebp)
  801ee8:	e8 8b f3 ff ff       	call   801278 <fd_lookup>
  801eed:	83 c4 10             	add    $0x10,%esp
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	78 11                	js     801f05 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801efd:	39 10                	cmp    %edx,(%eax)
  801eff:	0f 94 c0             	sete   %al
  801f02:	0f b6 c0             	movzbl %al,%eax
}
  801f05:	c9                   	leave  
  801f06:	c3                   	ret    

00801f07 <opencons>:
{
  801f07:	f3 0f 1e fb          	endbr32 
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
  801f0e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801f11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f14:	50                   	push   %eax
  801f15:	e8 08 f3 ff ff       	call   801222 <fd_alloc>
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	78 3a                	js     801f5b <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f21:	83 ec 04             	sub    $0x4,%esp
  801f24:	68 07 04 00 00       	push   $0x407
  801f29:	ff 75 f4             	pushl  -0xc(%ebp)
  801f2c:	6a 00                	push   $0x0
  801f2e:	e8 b7 ec ff ff       	call   800bea <sys_page_alloc>
  801f33:	83 c4 10             	add    $0x10,%esp
  801f36:	85 c0                	test   %eax,%eax
  801f38:	78 21                	js     801f5b <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f43:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f48:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f4f:	83 ec 0c             	sub    $0xc,%esp
  801f52:	50                   	push   %eax
  801f53:	e8 97 f2 ff ff       	call   8011ef <fd2num>
  801f58:	83 c4 10             	add    $0x10,%esp
}
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f5d:	f3 0f 1e fb          	endbr32 
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	56                   	push   %esi
  801f65:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f66:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f69:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f6f:	e8 23 ec ff ff       	call   800b97 <sys_getenvid>
  801f74:	83 ec 0c             	sub    $0xc,%esp
  801f77:	ff 75 0c             	pushl  0xc(%ebp)
  801f7a:	ff 75 08             	pushl  0x8(%ebp)
  801f7d:	56                   	push   %esi
  801f7e:	50                   	push   %eax
  801f7f:	68 ec 29 80 00       	push   $0x8029ec
  801f84:	e8 6f e2 ff ff       	call   8001f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f89:	83 c4 18             	add    $0x18,%esp
  801f8c:	53                   	push   %ebx
  801f8d:	ff 75 10             	pushl  0x10(%ebp)
  801f90:	e8 0e e2 ff ff       	call   8001a3 <vcprintf>
	cprintf("\n");
  801f95:	c7 04 24 ef 23 80 00 	movl   $0x8023ef,(%esp)
  801f9c:	e8 57 e2 ff ff       	call   8001f8 <cprintf>
  801fa1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fa4:	cc                   	int3   
  801fa5:	eb fd                	jmp    801fa4 <_panic+0x47>

00801fa7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fa7:	f3 0f 1e fb          	endbr32 
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801fb1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fb8:	74 0a                	je     801fc4 <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fba:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbd:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801fc2:	c9                   	leave  
  801fc3:	c3                   	ret    
		if (sys_page_alloc(0,
  801fc4:	83 ec 04             	sub    $0x4,%esp
  801fc7:	6a 07                	push   $0x7
  801fc9:	68 00 f0 bf ee       	push   $0xeebff000
  801fce:	6a 00                	push   $0x0
  801fd0:	e8 15 ec ff ff       	call   800bea <sys_page_alloc>
  801fd5:	83 c4 10             	add    $0x10,%esp
  801fd8:	85 c0                	test   %eax,%eax
  801fda:	78 2a                	js     802006 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801fdc:	83 ec 08             	sub    $0x8,%esp
  801fdf:	68 1a 20 80 00       	push   $0x80201a
  801fe4:	6a 00                	push   $0x0
  801fe6:	e8 c6 ec ff ff       	call   800cb1 <sys_env_set_pgfault_upcall>
  801feb:	83 c4 10             	add    $0x10,%esp
  801fee:	85 c0                	test   %eax,%eax
  801ff0:	79 c8                	jns    801fba <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  801ff2:	83 ec 04             	sub    $0x4,%esp
  801ff5:	68 44 2a 80 00       	push   $0x802a44
  801ffa:	6a 25                	push   $0x25
  801ffc:	68 8b 2a 80 00       	push   $0x802a8b
  802001:	e8 57 ff ff ff       	call   801f5d <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  802006:	83 ec 04             	sub    $0x4,%esp
  802009:	68 10 2a 80 00       	push   $0x802a10
  80200e:	6a 21                	push   $0x21
  802010:	68 8b 2a 80 00       	push   $0x802a8b
  802015:	e8 43 ff ff ff       	call   801f5d <_panic>

0080201a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80201a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80201b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802020:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802022:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  802025:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  80202a:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  80202e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802032:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  802034:	83 c4 08             	add    $0x8,%esp
	popal
  802037:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  802038:	83 c4 04             	add    $0x4,%esp
	popfl
  80203b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  80203c:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80203f:	c3                   	ret    

00802040 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802040:	f3 0f 1e fb          	endbr32 
  802044:	55                   	push   %ebp
  802045:	89 e5                	mov    %esp,%ebp
  802047:	56                   	push   %esi
  802048:	53                   	push   %ebx
  802049:	8b 75 08             	mov    0x8(%ebp),%esi
  80204c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  802052:	85 c0                	test   %eax,%eax
  802054:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802059:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  80205c:	83 ec 0c             	sub    $0xc,%esp
  80205f:	50                   	push   %eax
  802060:	e8 9c ec ff ff       	call   800d01 <sys_ipc_recv>
	if (f < 0) {
  802065:	83 c4 10             	add    $0x10,%esp
  802068:	85 c0                	test   %eax,%eax
  80206a:	78 2b                	js     802097 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  80206c:	85 f6                	test   %esi,%esi
  80206e:	74 0a                	je     80207a <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  802070:	a1 04 40 80 00       	mov    0x804004,%eax
  802075:	8b 40 74             	mov    0x74(%eax),%eax
  802078:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  80207a:	85 db                	test   %ebx,%ebx
  80207c:	74 0a                	je     802088 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  80207e:	a1 04 40 80 00       	mov    0x804004,%eax
  802083:	8b 40 78             	mov    0x78(%eax),%eax
  802086:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  802088:	a1 04 40 80 00       	mov    0x804004,%eax
  80208d:	8b 40 70             	mov    0x70(%eax),%eax
}
  802090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5d                   	pop    %ebp
  802096:	c3                   	ret    
		if (from_env_store != NULL) {
  802097:	85 f6                	test   %esi,%esi
  802099:	74 06                	je     8020a1 <ipc_recv+0x61>
			*from_env_store = 0;
  80209b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  8020a1:	85 db                	test   %ebx,%ebx
  8020a3:	74 eb                	je     802090 <ipc_recv+0x50>
			*perm_store = 0;
  8020a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020ab:	eb e3                	jmp    802090 <ipc_recv+0x50>

008020ad <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020ad:	f3 0f 1e fb          	endbr32 
  8020b1:	55                   	push   %ebp
  8020b2:	89 e5                	mov    %esp,%ebp
  8020b4:	57                   	push   %edi
  8020b5:	56                   	push   %esi
  8020b6:	53                   	push   %ebx
  8020b7:	83 ec 0c             	sub    $0xc,%esp
  8020ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020bd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  8020c3:	85 db                	test   %ebx,%ebx
  8020c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8020ca:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8020cd:	ff 75 14             	pushl  0x14(%ebp)
  8020d0:	53                   	push   %ebx
  8020d1:	56                   	push   %esi
  8020d2:	57                   	push   %edi
  8020d3:	e8 00 ec ff ff       	call   800cd8 <sys_ipc_try_send>
  8020d8:	83 c4 10             	add    $0x10,%esp
  8020db:	85 c0                	test   %eax,%eax
  8020dd:	79 19                	jns    8020f8 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  8020df:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020e2:	74 e9                	je     8020cd <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  8020e4:	83 ec 04             	sub    $0x4,%esp
  8020e7:	68 9c 2a 80 00       	push   $0x802a9c
  8020ec:	6a 48                	push   $0x48
  8020ee:	68 be 2a 80 00       	push   $0x802abe
  8020f3:	e8 65 fe ff ff       	call   801f5d <_panic>
		}
	}
}
  8020f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020fb:	5b                   	pop    %ebx
  8020fc:	5e                   	pop    %esi
  8020fd:	5f                   	pop    %edi
  8020fe:	5d                   	pop    %ebp
  8020ff:	c3                   	ret    

00802100 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802100:	f3 0f 1e fb          	endbr32 
  802104:	55                   	push   %ebp
  802105:	89 e5                	mov    %esp,%ebp
  802107:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80210a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80210f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802112:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802118:	8b 52 50             	mov    0x50(%edx),%edx
  80211b:	39 ca                	cmp    %ecx,%edx
  80211d:	74 11                	je     802130 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80211f:	83 c0 01             	add    $0x1,%eax
  802122:	3d 00 04 00 00       	cmp    $0x400,%eax
  802127:	75 e6                	jne    80210f <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802129:	b8 00 00 00 00       	mov    $0x0,%eax
  80212e:	eb 0b                	jmp    80213b <ipc_find_env+0x3b>
			return envs[i].env_id;
  802130:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802133:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802138:	8b 40 48             	mov    0x48(%eax),%eax
}
  80213b:	5d                   	pop    %ebp
  80213c:	c3                   	ret    

0080213d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80213d:	f3 0f 1e fb          	endbr32 
  802141:	55                   	push   %ebp
  802142:	89 e5                	mov    %esp,%ebp
  802144:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802147:	89 c2                	mov    %eax,%edx
  802149:	c1 ea 16             	shr    $0x16,%edx
  80214c:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802153:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802158:	f6 c1 01             	test   $0x1,%cl
  80215b:	74 1c                	je     802179 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80215d:	c1 e8 0c             	shr    $0xc,%eax
  802160:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802167:	a8 01                	test   $0x1,%al
  802169:	74 0e                	je     802179 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80216b:	c1 e8 0c             	shr    $0xc,%eax
  80216e:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802175:	ef 
  802176:	0f b7 d2             	movzwl %dx,%edx
}
  802179:	89 d0                	mov    %edx,%eax
  80217b:	5d                   	pop    %ebp
  80217c:	c3                   	ret    
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
