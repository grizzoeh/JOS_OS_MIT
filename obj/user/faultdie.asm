
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 0c             	sub    $0xc,%esp
  80003d:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800040:	8b 42 04             	mov    0x4(%edx),%eax
  800043:	83 e0 07             	and    $0x7,%eax
  800046:	50                   	push   %eax
  800047:	ff 32                	pushl  (%edx)
  800049:	68 c0 1e 80 00       	push   $0x801ec0
  80004e:	e8 3e 01 00 00       	call   800191 <cprintf>
	sys_env_destroy(sys_getenvid());
  800053:	e8 d8 0a 00 00       	call   800b30 <sys_getenvid>
  800058:	89 04 24             	mov    %eax,(%esp)
  80005b:	e8 aa 0a 00 00       	call   800b0a <sys_env_destroy>
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <umain>:

void
umain(int argc, char **argv)
{
  800065:	f3 0f 1e fb          	endbr32 
  800069:	55                   	push   %ebp
  80006a:	89 e5                	mov    %esp,%ebp
  80006c:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  80006f:	68 33 00 80 00       	push   $0x800033
  800074:	e8 47 0c 00 00       	call   800cc0 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800079:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800080:	00 00 00 
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	c9                   	leave  
  800087:	c3                   	ret    

00800088 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800088:	f3 0f 1e fb          	endbr32 
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	56                   	push   %esi
  800090:	53                   	push   %ebx
  800091:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800094:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800097:	e8 94 0a 00 00       	call   800b30 <sys_getenvid>
	if (id >= 0)
  80009c:	85 c0                	test   %eax,%eax
  80009e:	78 12                	js     8000b2 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8000a0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000a8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ad:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b2:	85 db                	test   %ebx,%ebx
  8000b4:	7e 07                	jle    8000bd <libmain+0x35>
		binaryname = argv[0];
  8000b6:	8b 06                	mov    (%esi),%eax
  8000b8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000bd:	83 ec 08             	sub    $0x8,%esp
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
  8000c2:	e8 9e ff ff ff       	call   800065 <umain>

	// exit gracefully
	exit();
  8000c7:	e8 0a 00 00 00       	call   8000d6 <exit>
}
  8000cc:	83 c4 10             	add    $0x10,%esp
  8000cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d6:	f3 0f 1e fb          	endbr32 
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e0:	e8 67 0e 00 00       	call   800f4c <close_all>
	sys_env_destroy(0);
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	6a 00                	push   $0x0
  8000ea:	e8 1b 0a 00 00       	call   800b0a <sys_env_destroy>
}
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f4:	f3 0f 1e fb          	endbr32 
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	53                   	push   %ebx
  8000fc:	83 ec 04             	sub    $0x4,%esp
  8000ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800102:	8b 13                	mov    (%ebx),%edx
  800104:	8d 42 01             	lea    0x1(%edx),%eax
  800107:	89 03                	mov    %eax,(%ebx)
  800109:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800110:	3d ff 00 00 00       	cmp    $0xff,%eax
  800115:	74 09                	je     800120 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800117:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80011e:	c9                   	leave  
  80011f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 87 09 00 00       	call   800ab8 <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	eb db                	jmp    800117 <putch+0x23>

0080013c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013c:	f3 0f 1e fb          	endbr32 
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800149:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800150:	00 00 00 
	b.cnt = 0;
  800153:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015d:	ff 75 0c             	pushl  0xc(%ebp)
  800160:	ff 75 08             	pushl  0x8(%ebp)
  800163:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800169:	50                   	push   %eax
  80016a:	68 f4 00 80 00       	push   $0x8000f4
  80016f:	e8 80 01 00 00       	call   8002f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800174:	83 c4 08             	add    $0x8,%esp
  800177:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800183:	50                   	push   %eax
  800184:	e8 2f 09 00 00       	call   800ab8 <sys_cputs>

	return b.cnt;
}
  800189:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800191:	f3 0f 1e fb          	endbr32 
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019e:	50                   	push   %eax
  80019f:	ff 75 08             	pushl  0x8(%ebp)
  8001a2:	e8 95 ff ff ff       	call   80013c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 1c             	sub    $0x1c,%esp
  8001b2:	89 c7                	mov    %eax,%edi
  8001b4:	89 d6                	mov    %edx,%esi
  8001b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bc:	89 d1                	mov    %edx,%ecx
  8001be:	89 c2                	mov    %eax,%edx
  8001c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001cf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001d6:	39 c2                	cmp    %eax,%edx
  8001d8:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001db:	72 3e                	jb     80021b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	ff 75 18             	pushl  0x18(%ebp)
  8001e3:	83 eb 01             	sub    $0x1,%ebx
  8001e6:	53                   	push   %ebx
  8001e7:	50                   	push   %eax
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 54 1a 00 00       	call   801c50 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9f ff ff ff       	call   8001a9 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 13                	jmp    800222 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80021b:	83 eb 01             	sub    $0x1,%ebx
  80021e:	85 db                	test   %ebx,%ebx
  800220:	7f ed                	jg     80020f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800222:	83 ec 08             	sub    $0x8,%esp
  800225:	56                   	push   %esi
  800226:	83 ec 04             	sub    $0x4,%esp
  800229:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022c:	ff 75 e0             	pushl  -0x20(%ebp)
  80022f:	ff 75 dc             	pushl  -0x24(%ebp)
  800232:	ff 75 d8             	pushl  -0x28(%ebp)
  800235:	e8 26 1b 00 00       	call   801d60 <__umoddi3>
  80023a:	83 c4 14             	add    $0x14,%esp
  80023d:	0f be 80 e6 1e 80 00 	movsbl 0x801ee6(%eax),%eax
  800244:	50                   	push   %eax
  800245:	ff d7                	call   *%edi
}
  800247:	83 c4 10             	add    $0x10,%esp
  80024a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024d:	5b                   	pop    %ebx
  80024e:	5e                   	pop    %esi
  80024f:	5f                   	pop    %edi
  800250:	5d                   	pop    %ebp
  800251:	c3                   	ret    

00800252 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800252:	83 fa 01             	cmp    $0x1,%edx
  800255:	7f 13                	jg     80026a <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800257:	85 d2                	test   %edx,%edx
  800259:	74 1c                	je     800277 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80025b:	8b 10                	mov    (%eax),%edx
  80025d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800260:	89 08                	mov    %ecx,(%eax)
  800262:	8b 02                	mov    (%edx),%eax
  800264:	ba 00 00 00 00       	mov    $0x0,%edx
  800269:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80026a:	8b 10                	mov    (%eax),%edx
  80026c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80026f:	89 08                	mov    %ecx,(%eax)
  800271:	8b 02                	mov    (%edx),%eax
  800273:	8b 52 04             	mov    0x4(%edx),%edx
  800276:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800277:	8b 10                	mov    (%eax),%edx
  800279:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027c:	89 08                	mov    %ecx,(%eax)
  80027e:	8b 02                	mov    (%edx),%eax
  800280:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800285:	c3                   	ret    

00800286 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800286:	83 fa 01             	cmp    $0x1,%edx
  800289:	7f 0f                	jg     80029a <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80028b:	85 d2                	test   %edx,%edx
  80028d:	74 18                	je     8002a7 <getint+0x21>
		return va_arg(*ap, long);
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	8d 4a 04             	lea    0x4(%edx),%ecx
  800294:	89 08                	mov    %ecx,(%eax)
  800296:	8b 02                	mov    (%edx),%eax
  800298:	99                   	cltd   
  800299:	c3                   	ret    
		return va_arg(*ap, long long);
  80029a:	8b 10                	mov    (%eax),%edx
  80029c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029f:	89 08                	mov    %ecx,(%eax)
  8002a1:	8b 02                	mov    (%edx),%eax
  8002a3:	8b 52 04             	mov    0x4(%edx),%edx
  8002a6:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8002a7:	8b 10                	mov    (%eax),%edx
  8002a9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ac:	89 08                	mov    %ecx,(%eax)
  8002ae:	8b 02                	mov    (%edx),%eax
  8002b0:	99                   	cltd   
}
  8002b1:	c3                   	ret    

008002b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b2:	f3 0f 1e fb          	endbr32 
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002bc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c5:	73 0a                	jae    8002d1 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002c7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ca:	89 08                	mov    %ecx,(%eax)
  8002cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cf:	88 02                	mov    %al,(%edx)
}
  8002d1:	5d                   	pop    %ebp
  8002d2:	c3                   	ret    

008002d3 <printfmt>:
{
  8002d3:	f3 0f 1e fb          	endbr32 
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e0:	50                   	push   %eax
  8002e1:	ff 75 10             	pushl  0x10(%ebp)
  8002e4:	ff 75 0c             	pushl  0xc(%ebp)
  8002e7:	ff 75 08             	pushl  0x8(%ebp)
  8002ea:	e8 05 00 00 00       	call   8002f4 <vprintfmt>
}
  8002ef:	83 c4 10             	add    $0x10,%esp
  8002f2:	c9                   	leave  
  8002f3:	c3                   	ret    

008002f4 <vprintfmt>:
{
  8002f4:	f3 0f 1e fb          	endbr32 
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	57                   	push   %edi
  8002fc:	56                   	push   %esi
  8002fd:	53                   	push   %ebx
  8002fe:	83 ec 2c             	sub    $0x2c,%esp
  800301:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800304:	8b 75 0c             	mov    0xc(%ebp),%esi
  800307:	8b 7d 10             	mov    0x10(%ebp),%edi
  80030a:	e9 86 02 00 00       	jmp    800595 <vprintfmt+0x2a1>
		padc = ' ';
  80030f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800313:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80031a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800321:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800328:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8d 47 01             	lea    0x1(%edi),%eax
  800330:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800333:	0f b6 17             	movzbl (%edi),%edx
  800336:	8d 42 dd             	lea    -0x23(%edx),%eax
  800339:	3c 55                	cmp    $0x55,%al
  80033b:	0f 87 df 02 00 00    	ja     800620 <vprintfmt+0x32c>
  800341:	0f b6 c0             	movzbl %al,%eax
  800344:	3e ff 24 85 20 20 80 	notrack jmp *0x802020(,%eax,4)
  80034b:	00 
  80034c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80034f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800353:	eb d8                	jmp    80032d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800358:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80035c:	eb cf                	jmp    80032d <vprintfmt+0x39>
  80035e:	0f b6 d2             	movzbl %dl,%edx
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800364:	b8 00 00 00 00       	mov    $0x0,%eax
  800369:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80036c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80036f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800373:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800376:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800379:	83 f9 09             	cmp    $0x9,%ecx
  80037c:	77 52                	ja     8003d0 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  80037e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800381:	eb e9                	jmp    80036c <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800383:	8b 45 14             	mov    0x14(%ebp),%eax
  800386:	8d 50 04             	lea    0x4(%eax),%edx
  800389:	89 55 14             	mov    %edx,0x14(%ebp)
  80038c:	8b 00                	mov    (%eax),%eax
  80038e:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800394:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800398:	79 93                	jns    80032d <vprintfmt+0x39>
				width = precision, precision = -1;
  80039a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80039d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003a7:	eb 84                	jmp    80032d <vprintfmt+0x39>
  8003a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ac:	85 c0                	test   %eax,%eax
  8003ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b3:	0f 49 d0             	cmovns %eax,%edx
  8003b6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003bc:	e9 6c ff ff ff       	jmp    80032d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003c4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003cb:	e9 5d ff ff ff       	jmp    80032d <vprintfmt+0x39>
  8003d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d6:	eb bc                	jmp    800394 <vprintfmt+0xa0>
			lflag++;
  8003d8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003de:	e9 4a ff ff ff       	jmp    80032d <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e6:	8d 50 04             	lea    0x4(%eax),%edx
  8003e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	56                   	push   %esi
  8003f0:	ff 30                	pushl  (%eax)
  8003f2:	ff d3                	call   *%ebx
			break;
  8003f4:	83 c4 10             	add    $0x10,%esp
  8003f7:	e9 96 01 00 00       	jmp    800592 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	8d 50 04             	lea    0x4(%eax),%edx
  800402:	89 55 14             	mov    %edx,0x14(%ebp)
  800405:	8b 00                	mov    (%eax),%eax
  800407:	99                   	cltd   
  800408:	31 d0                	xor    %edx,%eax
  80040a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040c:	83 f8 0f             	cmp    $0xf,%eax
  80040f:	7f 20                	jg     800431 <vprintfmt+0x13d>
  800411:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  800418:	85 d2                	test   %edx,%edx
  80041a:	74 15                	je     800431 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  80041c:	52                   	push   %edx
  80041d:	68 3d 23 80 00       	push   $0x80233d
  800422:	56                   	push   %esi
  800423:	53                   	push   %ebx
  800424:	e8 aa fe ff ff       	call   8002d3 <printfmt>
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	e9 61 01 00 00       	jmp    800592 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800431:	50                   	push   %eax
  800432:	68 fe 1e 80 00       	push   $0x801efe
  800437:	56                   	push   %esi
  800438:	53                   	push   %ebx
  800439:	e8 95 fe ff ff       	call   8002d3 <printfmt>
  80043e:	83 c4 10             	add    $0x10,%esp
  800441:	e9 4c 01 00 00       	jmp    800592 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800446:	8b 45 14             	mov    0x14(%ebp),%eax
  800449:	8d 50 04             	lea    0x4(%eax),%edx
  80044c:	89 55 14             	mov    %edx,0x14(%ebp)
  80044f:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800451:	85 c9                	test   %ecx,%ecx
  800453:	b8 f7 1e 80 00       	mov    $0x801ef7,%eax
  800458:	0f 45 c1             	cmovne %ecx,%eax
  80045b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80045e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800462:	7e 06                	jle    80046a <vprintfmt+0x176>
  800464:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800468:	75 0d                	jne    800477 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80046d:	89 c7                	mov    %eax,%edi
  80046f:	03 45 e0             	add    -0x20(%ebp),%eax
  800472:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800475:	eb 57                	jmp    8004ce <vprintfmt+0x1da>
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	ff 75 d8             	pushl  -0x28(%ebp)
  80047d:	ff 75 cc             	pushl  -0x34(%ebp)
  800480:	e8 4f 02 00 00       	call   8006d4 <strnlen>
  800485:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800488:	29 c2                	sub    %eax,%edx
  80048a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80048d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800490:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800494:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800497:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800499:	85 db                	test   %ebx,%ebx
  80049b:	7e 10                	jle    8004ad <vprintfmt+0x1b9>
					putch(padc, putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	56                   	push   %esi
  8004a1:	57                   	push   %edi
  8004a2:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a5:	83 eb 01             	sub    $0x1,%ebx
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	eb ec                	jmp    800499 <vprintfmt+0x1a5>
  8004ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004b3:	85 d2                	test   %edx,%edx
  8004b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ba:	0f 49 c2             	cmovns %edx,%eax
  8004bd:	29 c2                	sub    %eax,%edx
  8004bf:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004c2:	eb a6                	jmp    80046a <vprintfmt+0x176>
					putch(ch, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	56                   	push   %esi
  8004c8:	52                   	push   %edx
  8004c9:	ff d3                	call   *%ebx
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d1:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d3:	83 c7 01             	add    $0x1,%edi
  8004d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004da:	0f be d0             	movsbl %al,%edx
  8004dd:	85 d2                	test   %edx,%edx
  8004df:	74 42                	je     800523 <vprintfmt+0x22f>
  8004e1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e5:	78 06                	js     8004ed <vprintfmt+0x1f9>
  8004e7:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004eb:	78 1e                	js     80050b <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ed:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004f1:	74 d1                	je     8004c4 <vprintfmt+0x1d0>
  8004f3:	0f be c0             	movsbl %al,%eax
  8004f6:	83 e8 20             	sub    $0x20,%eax
  8004f9:	83 f8 5e             	cmp    $0x5e,%eax
  8004fc:	76 c6                	jbe    8004c4 <vprintfmt+0x1d0>
					putch('?', putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	56                   	push   %esi
  800502:	6a 3f                	push   $0x3f
  800504:	ff d3                	call   *%ebx
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	eb c3                	jmp    8004ce <vprintfmt+0x1da>
  80050b:	89 cf                	mov    %ecx,%edi
  80050d:	eb 0e                	jmp    80051d <vprintfmt+0x229>
				putch(' ', putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	56                   	push   %esi
  800513:	6a 20                	push   $0x20
  800515:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800517:	83 ef 01             	sub    $0x1,%edi
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	85 ff                	test   %edi,%edi
  80051f:	7f ee                	jg     80050f <vprintfmt+0x21b>
  800521:	eb 6f                	jmp    800592 <vprintfmt+0x29e>
  800523:	89 cf                	mov    %ecx,%edi
  800525:	eb f6                	jmp    80051d <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800527:	89 ca                	mov    %ecx,%edx
  800529:	8d 45 14             	lea    0x14(%ebp),%eax
  80052c:	e8 55 fd ff ff       	call   800286 <getint>
  800531:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800534:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800537:	85 d2                	test   %edx,%edx
  800539:	78 0b                	js     800546 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  80053b:	89 d1                	mov    %edx,%ecx
  80053d:	89 c2                	mov    %eax,%edx
			base = 10;
  80053f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800544:	eb 32                	jmp    800578 <vprintfmt+0x284>
				putch('-', putdat);
  800546:	83 ec 08             	sub    $0x8,%esp
  800549:	56                   	push   %esi
  80054a:	6a 2d                	push   $0x2d
  80054c:	ff d3                	call   *%ebx
				num = -(long long) num;
  80054e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800551:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800554:	f7 da                	neg    %edx
  800556:	83 d1 00             	adc    $0x0,%ecx
  800559:	f7 d9                	neg    %ecx
  80055b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80055e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800563:	eb 13                	jmp    800578 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800565:	89 ca                	mov    %ecx,%edx
  800567:	8d 45 14             	lea    0x14(%ebp),%eax
  80056a:	e8 e3 fc ff ff       	call   800252 <getuint>
  80056f:	89 d1                	mov    %edx,%ecx
  800571:	89 c2                	mov    %eax,%edx
			base = 10;
  800573:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800578:	83 ec 0c             	sub    $0xc,%esp
  80057b:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80057f:	57                   	push   %edi
  800580:	ff 75 e0             	pushl  -0x20(%ebp)
  800583:	50                   	push   %eax
  800584:	51                   	push   %ecx
  800585:	52                   	push   %edx
  800586:	89 f2                	mov    %esi,%edx
  800588:	89 d8                	mov    %ebx,%eax
  80058a:	e8 1a fc ff ff       	call   8001a9 <printnum>
			break;
  80058f:	83 c4 20             	add    $0x20,%esp
{
  800592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800595:	83 c7 01             	add    $0x1,%edi
  800598:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80059c:	83 f8 25             	cmp    $0x25,%eax
  80059f:	0f 84 6a fd ff ff    	je     80030f <vprintfmt+0x1b>
			if (ch == '\0')
  8005a5:	85 c0                	test   %eax,%eax
  8005a7:	0f 84 93 00 00 00    	je     800640 <vprintfmt+0x34c>
			putch(ch, putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	56                   	push   %esi
  8005b1:	50                   	push   %eax
  8005b2:	ff d3                	call   *%ebx
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	eb dc                	jmp    800595 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8005b9:	89 ca                	mov    %ecx,%edx
  8005bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005be:	e8 8f fc ff ff       	call   800252 <getuint>
  8005c3:	89 d1                	mov    %edx,%ecx
  8005c5:	89 c2                	mov    %eax,%edx
			base = 8;
  8005c7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005cc:	eb aa                	jmp    800578 <vprintfmt+0x284>
			putch('0', putdat);
  8005ce:	83 ec 08             	sub    $0x8,%esp
  8005d1:	56                   	push   %esi
  8005d2:	6a 30                	push   $0x30
  8005d4:	ff d3                	call   *%ebx
			putch('x', putdat);
  8005d6:	83 c4 08             	add    $0x8,%esp
  8005d9:	56                   	push   %esi
  8005da:	6a 78                	push   $0x78
  8005dc:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 04             	lea    0x4(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8005e7:	8b 10                	mov    (%eax),%edx
  8005e9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005ee:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8005f1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005f6:	eb 80                	jmp    800578 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8005f8:	89 ca                	mov    %ecx,%edx
  8005fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fd:	e8 50 fc ff ff       	call   800252 <getuint>
  800602:	89 d1                	mov    %edx,%ecx
  800604:	89 c2                	mov    %eax,%edx
			base = 16;
  800606:	b8 10 00 00 00       	mov    $0x10,%eax
  80060b:	e9 68 ff ff ff       	jmp    800578 <vprintfmt+0x284>
			putch(ch, putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	56                   	push   %esi
  800614:	6a 25                	push   $0x25
  800616:	ff d3                	call   *%ebx
			break;
  800618:	83 c4 10             	add    $0x10,%esp
  80061b:	e9 72 ff ff ff       	jmp    800592 <vprintfmt+0x29e>
			putch('%', putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	56                   	push   %esi
  800624:	6a 25                	push   $0x25
  800626:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800628:	83 c4 10             	add    $0x10,%esp
  80062b:	89 f8                	mov    %edi,%eax
  80062d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800631:	74 05                	je     800638 <vprintfmt+0x344>
  800633:	83 e8 01             	sub    $0x1,%eax
  800636:	eb f5                	jmp    80062d <vprintfmt+0x339>
  800638:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80063b:	e9 52 ff ff ff       	jmp    800592 <vprintfmt+0x29e>
}
  800640:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800643:	5b                   	pop    %ebx
  800644:	5e                   	pop    %esi
  800645:	5f                   	pop    %edi
  800646:	5d                   	pop    %ebp
  800647:	c3                   	ret    

00800648 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800648:	f3 0f 1e fb          	endbr32 
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	83 ec 18             	sub    $0x18,%esp
  800652:	8b 45 08             	mov    0x8(%ebp),%eax
  800655:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800658:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80065b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80065f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800662:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800669:	85 c0                	test   %eax,%eax
  80066b:	74 26                	je     800693 <vsnprintf+0x4b>
  80066d:	85 d2                	test   %edx,%edx
  80066f:	7e 22                	jle    800693 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800671:	ff 75 14             	pushl  0x14(%ebp)
  800674:	ff 75 10             	pushl  0x10(%ebp)
  800677:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80067a:	50                   	push   %eax
  80067b:	68 b2 02 80 00       	push   $0x8002b2
  800680:	e8 6f fc ff ff       	call   8002f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800685:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800688:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80068b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068e:	83 c4 10             	add    $0x10,%esp
}
  800691:	c9                   	leave  
  800692:	c3                   	ret    
		return -E_INVAL;
  800693:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800698:	eb f7                	jmp    800691 <vsnprintf+0x49>

0080069a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80069a:	f3 0f 1e fb          	endbr32 
  80069e:	55                   	push   %ebp
  80069f:	89 e5                	mov    %esp,%ebp
  8006a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a7:	50                   	push   %eax
  8006a8:	ff 75 10             	pushl  0x10(%ebp)
  8006ab:	ff 75 0c             	pushl  0xc(%ebp)
  8006ae:	ff 75 08             	pushl  0x8(%ebp)
  8006b1:	e8 92 ff ff ff       	call   800648 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    

008006b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b8:	f3 0f 1e fb          	endbr32 
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006cb:	74 05                	je     8006d2 <strlen+0x1a>
		n++;
  8006cd:	83 c0 01             	add    $0x1,%eax
  8006d0:	eb f5                	jmp    8006c7 <strlen+0xf>
	return n;
}
  8006d2:	5d                   	pop    %ebp
  8006d3:	c3                   	ret    

008006d4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d4:	f3 0f 1e fb          	endbr32 
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e6:	39 d0                	cmp    %edx,%eax
  8006e8:	74 0d                	je     8006f7 <strnlen+0x23>
  8006ea:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006ee:	74 05                	je     8006f5 <strnlen+0x21>
		n++;
  8006f0:	83 c0 01             	add    $0x1,%eax
  8006f3:	eb f1                	jmp    8006e6 <strnlen+0x12>
  8006f5:	89 c2                	mov    %eax,%edx
	return n;
}
  8006f7:	89 d0                	mov    %edx,%eax
  8006f9:	5d                   	pop    %ebp
  8006fa:	c3                   	ret    

008006fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006fb:	f3 0f 1e fb          	endbr32 
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	53                   	push   %ebx
  800703:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800706:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800709:	b8 00 00 00 00       	mov    $0x0,%eax
  80070e:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800712:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800715:	83 c0 01             	add    $0x1,%eax
  800718:	84 d2                	test   %dl,%dl
  80071a:	75 f2                	jne    80070e <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80071c:	89 c8                	mov    %ecx,%eax
  80071e:	5b                   	pop    %ebx
  80071f:	5d                   	pop    %ebp
  800720:	c3                   	ret    

00800721 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800721:	f3 0f 1e fb          	endbr32 
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	53                   	push   %ebx
  800729:	83 ec 10             	sub    $0x10,%esp
  80072c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80072f:	53                   	push   %ebx
  800730:	e8 83 ff ff ff       	call   8006b8 <strlen>
  800735:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	01 d8                	add    %ebx,%eax
  80073d:	50                   	push   %eax
  80073e:	e8 b8 ff ff ff       	call   8006fb <strcpy>
	return dst;
}
  800743:	89 d8                	mov    %ebx,%eax
  800745:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800748:	c9                   	leave  
  800749:	c3                   	ret    

0080074a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074a:	f3 0f 1e fb          	endbr32 
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	56                   	push   %esi
  800752:	53                   	push   %ebx
  800753:	8b 75 08             	mov    0x8(%ebp),%esi
  800756:	8b 55 0c             	mov    0xc(%ebp),%edx
  800759:	89 f3                	mov    %esi,%ebx
  80075b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075e:	89 f0                	mov    %esi,%eax
  800760:	39 d8                	cmp    %ebx,%eax
  800762:	74 11                	je     800775 <strncpy+0x2b>
		*dst++ = *src;
  800764:	83 c0 01             	add    $0x1,%eax
  800767:	0f b6 0a             	movzbl (%edx),%ecx
  80076a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80076d:	80 f9 01             	cmp    $0x1,%cl
  800770:	83 da ff             	sbb    $0xffffffff,%edx
  800773:	eb eb                	jmp    800760 <strncpy+0x16>
	}
	return ret;
}
  800775:	89 f0                	mov    %esi,%eax
  800777:	5b                   	pop    %ebx
  800778:	5e                   	pop    %esi
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80077b:	f3 0f 1e fb          	endbr32 
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	56                   	push   %esi
  800783:	53                   	push   %ebx
  800784:	8b 75 08             	mov    0x8(%ebp),%esi
  800787:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078a:	8b 55 10             	mov    0x10(%ebp),%edx
  80078d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80078f:	85 d2                	test   %edx,%edx
  800791:	74 21                	je     8007b4 <strlcpy+0x39>
  800793:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800797:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800799:	39 c2                	cmp    %eax,%edx
  80079b:	74 14                	je     8007b1 <strlcpy+0x36>
  80079d:	0f b6 19             	movzbl (%ecx),%ebx
  8007a0:	84 db                	test   %bl,%bl
  8007a2:	74 0b                	je     8007af <strlcpy+0x34>
			*dst++ = *src++;
  8007a4:	83 c1 01             	add    $0x1,%ecx
  8007a7:	83 c2 01             	add    $0x1,%edx
  8007aa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ad:	eb ea                	jmp    800799 <strlcpy+0x1e>
  8007af:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007b1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b4:	29 f0                	sub    %esi,%eax
}
  8007b6:	5b                   	pop    %ebx
  8007b7:	5e                   	pop    %esi
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ba:	f3 0f 1e fb          	endbr32 
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c7:	0f b6 01             	movzbl (%ecx),%eax
  8007ca:	84 c0                	test   %al,%al
  8007cc:	74 0c                	je     8007da <strcmp+0x20>
  8007ce:	3a 02                	cmp    (%edx),%al
  8007d0:	75 08                	jne    8007da <strcmp+0x20>
		p++, q++;
  8007d2:	83 c1 01             	add    $0x1,%ecx
  8007d5:	83 c2 01             	add    $0x1,%edx
  8007d8:	eb ed                	jmp    8007c7 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007da:	0f b6 c0             	movzbl %al,%eax
  8007dd:	0f b6 12             	movzbl (%edx),%edx
  8007e0:	29 d0                	sub    %edx,%eax
}
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e4:	f3 0f 1e fb          	endbr32 
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	53                   	push   %ebx
  8007ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f2:	89 c3                	mov    %eax,%ebx
  8007f4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f7:	eb 06                	jmp    8007ff <strncmp+0x1b>
		n--, p++, q++;
  8007f9:	83 c0 01             	add    $0x1,%eax
  8007fc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8007ff:	39 d8                	cmp    %ebx,%eax
  800801:	74 16                	je     800819 <strncmp+0x35>
  800803:	0f b6 08             	movzbl (%eax),%ecx
  800806:	84 c9                	test   %cl,%cl
  800808:	74 04                	je     80080e <strncmp+0x2a>
  80080a:	3a 0a                	cmp    (%edx),%cl
  80080c:	74 eb                	je     8007f9 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080e:	0f b6 00             	movzbl (%eax),%eax
  800811:	0f b6 12             	movzbl (%edx),%edx
  800814:	29 d0                	sub    %edx,%eax
}
  800816:	5b                   	pop    %ebx
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    
		return 0;
  800819:	b8 00 00 00 00       	mov    $0x0,%eax
  80081e:	eb f6                	jmp    800816 <strncmp+0x32>

00800820 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800820:	f3 0f 1e fb          	endbr32 
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082e:	0f b6 10             	movzbl (%eax),%edx
  800831:	84 d2                	test   %dl,%dl
  800833:	74 09                	je     80083e <strchr+0x1e>
		if (*s == c)
  800835:	38 ca                	cmp    %cl,%dl
  800837:	74 0a                	je     800843 <strchr+0x23>
	for (; *s; s++)
  800839:	83 c0 01             	add    $0x1,%eax
  80083c:	eb f0                	jmp    80082e <strchr+0xe>
			return (char *) s;
	return 0;
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800845:	f3 0f 1e fb          	endbr32 
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800853:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800856:	38 ca                	cmp    %cl,%dl
  800858:	74 09                	je     800863 <strfind+0x1e>
  80085a:	84 d2                	test   %dl,%dl
  80085c:	74 05                	je     800863 <strfind+0x1e>
	for (; *s; s++)
  80085e:	83 c0 01             	add    $0x1,%eax
  800861:	eb f0                	jmp    800853 <strfind+0xe>
			break;
	return (char *) s;
}
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800865:	f3 0f 1e fb          	endbr32 
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	57                   	push   %edi
  80086d:	56                   	push   %esi
  80086e:	53                   	push   %ebx
  80086f:	8b 55 08             	mov    0x8(%ebp),%edx
  800872:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800875:	85 c9                	test   %ecx,%ecx
  800877:	74 33                	je     8008ac <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800879:	89 d0                	mov    %edx,%eax
  80087b:	09 c8                	or     %ecx,%eax
  80087d:	a8 03                	test   $0x3,%al
  80087f:	75 23                	jne    8008a4 <memset+0x3f>
		c &= 0xFF;
  800881:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800885:	89 d8                	mov    %ebx,%eax
  800887:	c1 e0 08             	shl    $0x8,%eax
  80088a:	89 df                	mov    %ebx,%edi
  80088c:	c1 e7 18             	shl    $0x18,%edi
  80088f:	89 de                	mov    %ebx,%esi
  800891:	c1 e6 10             	shl    $0x10,%esi
  800894:	09 f7                	or     %esi,%edi
  800896:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800898:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80089d:	89 d7                	mov    %edx,%edi
  80089f:	fc                   	cld    
  8008a0:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a2:	eb 08                	jmp    8008ac <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a4:	89 d7                	mov    %edx,%edi
  8008a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a9:	fc                   	cld    
  8008aa:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8008ac:	89 d0                	mov    %edx,%eax
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5f                   	pop    %edi
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b3:	f3 0f 1e fb          	endbr32 
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	57                   	push   %edi
  8008bb:	56                   	push   %esi
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c5:	39 c6                	cmp    %eax,%esi
  8008c7:	73 32                	jae    8008fb <memmove+0x48>
  8008c9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008cc:	39 c2                	cmp    %eax,%edx
  8008ce:	76 2b                	jbe    8008fb <memmove+0x48>
		s += n;
		d += n;
  8008d0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d3:	89 fe                	mov    %edi,%esi
  8008d5:	09 ce                	or     %ecx,%esi
  8008d7:	09 d6                	or     %edx,%esi
  8008d9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008df:	75 0e                	jne    8008ef <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008e1:	83 ef 04             	sub    $0x4,%edi
  8008e4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008ea:	fd                   	std    
  8008eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ed:	eb 09                	jmp    8008f8 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008ef:	83 ef 01             	sub    $0x1,%edi
  8008f2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008f5:	fd                   	std    
  8008f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f8:	fc                   	cld    
  8008f9:	eb 1a                	jmp    800915 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fb:	89 c2                	mov    %eax,%edx
  8008fd:	09 ca                	or     %ecx,%edx
  8008ff:	09 f2                	or     %esi,%edx
  800901:	f6 c2 03             	test   $0x3,%dl
  800904:	75 0a                	jne    800910 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800906:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800909:	89 c7                	mov    %eax,%edi
  80090b:	fc                   	cld    
  80090c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090e:	eb 05                	jmp    800915 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800910:	89 c7                	mov    %eax,%edi
  800912:	fc                   	cld    
  800913:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800915:	5e                   	pop    %esi
  800916:	5f                   	pop    %edi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800919:	f3 0f 1e fb          	endbr32 
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800923:	ff 75 10             	pushl  0x10(%ebp)
  800926:	ff 75 0c             	pushl  0xc(%ebp)
  800929:	ff 75 08             	pushl  0x8(%ebp)
  80092c:	e8 82 ff ff ff       	call   8008b3 <memmove>
}
  800931:	c9                   	leave  
  800932:	c3                   	ret    

00800933 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800933:	f3 0f 1e fb          	endbr32 
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800942:	89 c6                	mov    %eax,%esi
  800944:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800947:	39 f0                	cmp    %esi,%eax
  800949:	74 1c                	je     800967 <memcmp+0x34>
		if (*s1 != *s2)
  80094b:	0f b6 08             	movzbl (%eax),%ecx
  80094e:	0f b6 1a             	movzbl (%edx),%ebx
  800951:	38 d9                	cmp    %bl,%cl
  800953:	75 08                	jne    80095d <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	83 c2 01             	add    $0x1,%edx
  80095b:	eb ea                	jmp    800947 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  80095d:	0f b6 c1             	movzbl %cl,%eax
  800960:	0f b6 db             	movzbl %bl,%ebx
  800963:	29 d8                	sub    %ebx,%eax
  800965:	eb 05                	jmp    80096c <memcmp+0x39>
	}

	return 0;
  800967:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096c:	5b                   	pop    %ebx
  80096d:	5e                   	pop    %esi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800970:	f3 0f 1e fb          	endbr32 
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
  80097a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80097d:	89 c2                	mov    %eax,%edx
  80097f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800982:	39 d0                	cmp    %edx,%eax
  800984:	73 09                	jae    80098f <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800986:	38 08                	cmp    %cl,(%eax)
  800988:	74 05                	je     80098f <memfind+0x1f>
	for (; s < ends; s++)
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	eb f3                	jmp    800982 <memfind+0x12>
			break;
	return (void *) s;
}
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800991:	f3 0f 1e fb          	endbr32 
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	57                   	push   %edi
  800999:	56                   	push   %esi
  80099a:	53                   	push   %ebx
  80099b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a1:	eb 03                	jmp    8009a6 <strtol+0x15>
		s++;
  8009a3:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009a6:	0f b6 01             	movzbl (%ecx),%eax
  8009a9:	3c 20                	cmp    $0x20,%al
  8009ab:	74 f6                	je     8009a3 <strtol+0x12>
  8009ad:	3c 09                	cmp    $0x9,%al
  8009af:	74 f2                	je     8009a3 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  8009b1:	3c 2b                	cmp    $0x2b,%al
  8009b3:	74 2a                	je     8009df <strtol+0x4e>
	int neg = 0;
  8009b5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009ba:	3c 2d                	cmp    $0x2d,%al
  8009bc:	74 2b                	je     8009e9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009be:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c4:	75 0f                	jne    8009d5 <strtol+0x44>
  8009c6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c9:	74 28                	je     8009f3 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009cb:	85 db                	test   %ebx,%ebx
  8009cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d2:	0f 44 d8             	cmove  %eax,%ebx
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009da:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009dd:	eb 46                	jmp    800a25 <strtol+0x94>
		s++;
  8009df:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8009e2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e7:	eb d5                	jmp    8009be <strtol+0x2d>
		s++, neg = 1;
  8009e9:	83 c1 01             	add    $0x1,%ecx
  8009ec:	bf 01 00 00 00       	mov    $0x1,%edi
  8009f1:	eb cb                	jmp    8009be <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009f7:	74 0e                	je     800a07 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009f9:	85 db                	test   %ebx,%ebx
  8009fb:	75 d8                	jne    8009d5 <strtol+0x44>
		s++, base = 8;
  8009fd:	83 c1 01             	add    $0x1,%ecx
  800a00:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a05:	eb ce                	jmp    8009d5 <strtol+0x44>
		s += 2, base = 16;
  800a07:	83 c1 02             	add    $0x2,%ecx
  800a0a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a0f:	eb c4                	jmp    8009d5 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a11:	0f be d2             	movsbl %dl,%edx
  800a14:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a17:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a1a:	7d 3a                	jge    800a56 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a1c:	83 c1 01             	add    $0x1,%ecx
  800a1f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a23:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a25:	0f b6 11             	movzbl (%ecx),%edx
  800a28:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a2b:	89 f3                	mov    %esi,%ebx
  800a2d:	80 fb 09             	cmp    $0x9,%bl
  800a30:	76 df                	jbe    800a11 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800a32:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a35:	89 f3                	mov    %esi,%ebx
  800a37:	80 fb 19             	cmp    $0x19,%bl
  800a3a:	77 08                	ja     800a44 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a3c:	0f be d2             	movsbl %dl,%edx
  800a3f:	83 ea 57             	sub    $0x57,%edx
  800a42:	eb d3                	jmp    800a17 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800a44:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a47:	89 f3                	mov    %esi,%ebx
  800a49:	80 fb 19             	cmp    $0x19,%bl
  800a4c:	77 08                	ja     800a56 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a4e:	0f be d2             	movsbl %dl,%edx
  800a51:	83 ea 37             	sub    $0x37,%edx
  800a54:	eb c1                	jmp    800a17 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a56:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a5a:	74 05                	je     800a61 <strtol+0xd0>
		*endptr = (char *) s;
  800a5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a61:	89 c2                	mov    %eax,%edx
  800a63:	f7 da                	neg    %edx
  800a65:	85 ff                	test   %edi,%edi
  800a67:	0f 45 c2             	cmovne %edx,%eax
}
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5f                   	pop    %edi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	57                   	push   %edi
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	83 ec 1c             	sub    $0x1c,%esp
  800a78:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a7b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a7e:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a86:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a89:	8b 75 14             	mov    0x14(%ebp),%esi
  800a8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a8e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a92:	74 04                	je     800a98 <syscall+0x29>
  800a94:	85 c0                	test   %eax,%eax
  800a96:	7f 08                	jg     800aa0 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa0:	83 ec 0c             	sub    $0xc,%esp
  800aa3:	50                   	push   %eax
  800aa4:	ff 75 e0             	pushl  -0x20(%ebp)
  800aa7:	68 df 21 80 00       	push   $0x8021df
  800aac:	6a 23                	push   $0x23
  800aae:	68 fc 21 80 00       	push   $0x8021fc
  800ab3:	e8 0f 10 00 00       	call   801ac7 <_panic>

00800ab8 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800ab8:	f3 0f 1e fb          	endbr32 
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800ac2:	6a 00                	push   $0x0
  800ac4:	6a 00                	push   $0x0
  800ac6:	6a 00                	push   $0x0
  800ac8:	ff 75 0c             	pushl  0xc(%ebp)
  800acb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ace:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad8:	e8 92 ff ff ff       	call   800a6f <syscall>
}
  800add:	83 c4 10             	add    $0x10,%esp
  800ae0:	c9                   	leave  
  800ae1:	c3                   	ret    

00800ae2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae2:	f3 0f 1e fb          	endbr32 
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800aec:	6a 00                	push   $0x0
  800aee:	6a 00                	push   $0x0
  800af0:	6a 00                	push   $0x0
  800af2:	6a 00                	push   $0x0
  800af4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af9:	ba 00 00 00 00       	mov    $0x0,%edx
  800afe:	b8 01 00 00 00       	mov    $0x1,%eax
  800b03:	e8 67 ff ff ff       	call   800a6f <syscall>
}
  800b08:	c9                   	leave  
  800b09:	c3                   	ret    

00800b0a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b0a:	f3 0f 1e fb          	endbr32 
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b14:	6a 00                	push   $0x0
  800b16:	6a 00                	push   $0x0
  800b18:	6a 00                	push   $0x0
  800b1a:	6a 00                	push   $0x0
  800b1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1f:	ba 01 00 00 00       	mov    $0x1,%edx
  800b24:	b8 03 00 00 00       	mov    $0x3,%eax
  800b29:	e8 41 ff ff ff       	call   800a6f <syscall>
}
  800b2e:	c9                   	leave  
  800b2f:	c3                   	ret    

00800b30 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b30:	f3 0f 1e fb          	endbr32 
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b3a:	6a 00                	push   $0x0
  800b3c:	6a 00                	push   $0x0
  800b3e:	6a 00                	push   $0x0
  800b40:	6a 00                	push   $0x0
  800b42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b47:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b51:	e8 19 ff ff ff       	call   800a6f <syscall>
}
  800b56:	c9                   	leave  
  800b57:	c3                   	ret    

00800b58 <sys_yield>:

void
sys_yield(void)
{
  800b58:	f3 0f 1e fb          	endbr32 
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b62:	6a 00                	push   $0x0
  800b64:	6a 00                	push   $0x0
  800b66:	6a 00                	push   $0x0
  800b68:	6a 00                	push   $0x0
  800b6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b74:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b79:	e8 f1 fe ff ff       	call   800a6f <syscall>
}
  800b7e:	83 c4 10             	add    $0x10,%esp
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b83:	f3 0f 1e fb          	endbr32 
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b8d:	6a 00                	push   $0x0
  800b8f:	6a 00                	push   $0x0
  800b91:	ff 75 10             	pushl  0x10(%ebp)
  800b94:	ff 75 0c             	pushl  0xc(%ebp)
  800b97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9a:	ba 01 00 00 00       	mov    $0x1,%edx
  800b9f:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba4:	e8 c6 fe ff ff       	call   800a6f <syscall>
}
  800ba9:	c9                   	leave  
  800baa:	c3                   	ret    

00800bab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bab:	f3 0f 1e fb          	endbr32 
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bb5:	ff 75 18             	pushl  0x18(%ebp)
  800bb8:	ff 75 14             	pushl  0x14(%ebp)
  800bbb:	ff 75 10             	pushl  0x10(%ebp)
  800bbe:	ff 75 0c             	pushl  0xc(%ebp)
  800bc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc4:	ba 01 00 00 00       	mov    $0x1,%edx
  800bc9:	b8 05 00 00 00       	mov    $0x5,%eax
  800bce:	e8 9c fe ff ff       	call   800a6f <syscall>
}
  800bd3:	c9                   	leave  
  800bd4:	c3                   	ret    

00800bd5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd5:	f3 0f 1e fb          	endbr32 
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bdf:	6a 00                	push   $0x0
  800be1:	6a 00                	push   $0x0
  800be3:	6a 00                	push   $0x0
  800be5:	ff 75 0c             	pushl  0xc(%ebp)
  800be8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800beb:	ba 01 00 00 00       	mov    $0x1,%edx
  800bf0:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf5:	e8 75 fe ff ff       	call   800a6f <syscall>
}
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bfc:	f3 0f 1e fb          	endbr32 
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c06:	6a 00                	push   $0x0
  800c08:	6a 00                	push   $0x0
  800c0a:	6a 00                	push   $0x0
  800c0c:	ff 75 0c             	pushl  0xc(%ebp)
  800c0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c12:	ba 01 00 00 00       	mov    $0x1,%edx
  800c17:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1c:	e8 4e fe ff ff       	call   800a6f <syscall>
}
  800c21:	c9                   	leave  
  800c22:	c3                   	ret    

00800c23 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c23:	f3 0f 1e fb          	endbr32 
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c2d:	6a 00                	push   $0x0
  800c2f:	6a 00                	push   $0x0
  800c31:	6a 00                	push   $0x0
  800c33:	ff 75 0c             	pushl  0xc(%ebp)
  800c36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c39:	ba 01 00 00 00       	mov    $0x1,%edx
  800c3e:	b8 09 00 00 00       	mov    $0x9,%eax
  800c43:	e8 27 fe ff ff       	call   800a6f <syscall>
}
  800c48:	c9                   	leave  
  800c49:	c3                   	ret    

00800c4a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c4a:	f3 0f 1e fb          	endbr32 
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c54:	6a 00                	push   $0x0
  800c56:	6a 00                	push   $0x0
  800c58:	6a 00                	push   $0x0
  800c5a:	ff 75 0c             	pushl  0xc(%ebp)
  800c5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c60:	ba 01 00 00 00       	mov    $0x1,%edx
  800c65:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c6a:	e8 00 fe ff ff       	call   800a6f <syscall>
}
  800c6f:	c9                   	leave  
  800c70:	c3                   	ret    

00800c71 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c71:	f3 0f 1e fb          	endbr32 
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c7b:	6a 00                	push   $0x0
  800c7d:	ff 75 14             	pushl  0x14(%ebp)
  800c80:	ff 75 10             	pushl  0x10(%ebp)
  800c83:	ff 75 0c             	pushl  0xc(%ebp)
  800c86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c89:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c93:	e8 d7 fd ff ff       	call   800a6f <syscall>
}
  800c98:	c9                   	leave  
  800c99:	c3                   	ret    

00800c9a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c9a:	f3 0f 1e fb          	endbr32 
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800ca4:	6a 00                	push   $0x0
  800ca6:	6a 00                	push   $0x0
  800ca8:	6a 00                	push   $0x0
  800caa:	6a 00                	push   $0x0
  800cac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800caf:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb4:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cb9:	e8 b1 fd ff ff       	call   800a6f <syscall>
}
  800cbe:	c9                   	leave  
  800cbf:	c3                   	ret    

00800cc0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cc0:	f3 0f 1e fb          	endbr32 
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  800cca:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800cd1:	74 0a                	je     800cdd <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd6:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800cdb:	c9                   	leave  
  800cdc:	c3                   	ret    
		if (sys_page_alloc(0,
  800cdd:	83 ec 04             	sub    $0x4,%esp
  800ce0:	6a 07                	push   $0x7
  800ce2:	68 00 f0 bf ee       	push   $0xeebff000
  800ce7:	6a 00                	push   $0x0
  800ce9:	e8 95 fe ff ff       	call   800b83 <sys_page_alloc>
  800cee:	83 c4 10             	add    $0x10,%esp
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	78 2a                	js     800d1f <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  800cf5:	83 ec 08             	sub    $0x8,%esp
  800cf8:	68 33 0d 80 00       	push   $0x800d33
  800cfd:	6a 00                	push   $0x0
  800cff:	e8 46 ff ff ff       	call   800c4a <sys_env_set_pgfault_upcall>
  800d04:	83 c4 10             	add    $0x10,%esp
  800d07:	85 c0                	test   %eax,%eax
  800d09:	79 c8                	jns    800cd3 <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  800d0b:	83 ec 04             	sub    $0x4,%esp
  800d0e:	68 40 22 80 00       	push   $0x802240
  800d13:	6a 25                	push   $0x25
  800d15:	68 87 22 80 00       	push   $0x802287
  800d1a:	e8 a8 0d 00 00       	call   801ac7 <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  800d1f:	83 ec 04             	sub    $0x4,%esp
  800d22:	68 0c 22 80 00       	push   $0x80220c
  800d27:	6a 21                	push   $0x21
  800d29:	68 87 22 80 00       	push   $0x802287
  800d2e:	e8 94 0d 00 00       	call   801ac7 <_panic>

00800d33 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d33:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d34:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800d39:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d3b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  800d3e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  800d43:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  800d47:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800d4b:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  800d4d:	83 c4 08             	add    $0x8,%esp
	popal
  800d50:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  800d51:	83 c4 04             	add    $0x4,%esp
	popfl
  800d54:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  800d55:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800d58:	c3                   	ret    

00800d59 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d59:	f3 0f 1e fb          	endbr32 
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	05 00 00 00 30       	add    $0x30000000,%eax
  800d68:	c1 e8 0c             	shr    $0xc,%eax
}
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d6d:	f3 0f 1e fb          	endbr32 
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800d77:	ff 75 08             	pushl  0x8(%ebp)
  800d7a:	e8 da ff ff ff       	call   800d59 <fd2num>
  800d7f:	83 c4 10             	add    $0x10,%esp
  800d82:	c1 e0 0c             	shl    $0xc,%eax
  800d85:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d8a:	c9                   	leave  
  800d8b:	c3                   	ret    

00800d8c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d8c:	f3 0f 1e fb          	endbr32 
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d98:	89 c2                	mov    %eax,%edx
  800d9a:	c1 ea 16             	shr    $0x16,%edx
  800d9d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800da4:	f6 c2 01             	test   $0x1,%dl
  800da7:	74 2d                	je     800dd6 <fd_alloc+0x4a>
  800da9:	89 c2                	mov    %eax,%edx
  800dab:	c1 ea 0c             	shr    $0xc,%edx
  800dae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800db5:	f6 c2 01             	test   $0x1,%dl
  800db8:	74 1c                	je     800dd6 <fd_alloc+0x4a>
  800dba:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800dbf:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dc4:	75 d2                	jne    800d98 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800dcf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800dd4:	eb 0a                	jmp    800de0 <fd_alloc+0x54>
			*fd_store = fd;
  800dd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd9:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ddb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800de2:	f3 0f 1e fb          	endbr32 
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dec:	83 f8 1f             	cmp    $0x1f,%eax
  800def:	77 30                	ja     800e21 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800df1:	c1 e0 0c             	shl    $0xc,%eax
  800df4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800df9:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800dff:	f6 c2 01             	test   $0x1,%dl
  800e02:	74 24                	je     800e28 <fd_lookup+0x46>
  800e04:	89 c2                	mov    %eax,%edx
  800e06:	c1 ea 0c             	shr    $0xc,%edx
  800e09:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e10:	f6 c2 01             	test   $0x1,%dl
  800e13:	74 1a                	je     800e2f <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e15:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e18:	89 02                	mov    %eax,(%edx)
	return 0;
  800e1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    
		return -E_INVAL;
  800e21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e26:	eb f7                	jmp    800e1f <fd_lookup+0x3d>
		return -E_INVAL;
  800e28:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e2d:	eb f0                	jmp    800e1f <fd_lookup+0x3d>
  800e2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e34:	eb e9                	jmp    800e1f <fd_lookup+0x3d>

00800e36 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e36:	f3 0f 1e fb          	endbr32 
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	83 ec 08             	sub    $0x8,%esp
  800e40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e43:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e48:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800e4d:	39 08                	cmp    %ecx,(%eax)
  800e4f:	74 33                	je     800e84 <dev_lookup+0x4e>
  800e51:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800e54:	8b 02                	mov    (%edx),%eax
  800e56:	85 c0                	test   %eax,%eax
  800e58:	75 f3                	jne    800e4d <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e5a:	a1 04 40 80 00       	mov    0x804004,%eax
  800e5f:	8b 40 48             	mov    0x48(%eax),%eax
  800e62:	83 ec 04             	sub    $0x4,%esp
  800e65:	51                   	push   %ecx
  800e66:	50                   	push   %eax
  800e67:	68 98 22 80 00       	push   $0x802298
  800e6c:	e8 20 f3 ff ff       	call   800191 <cprintf>
	*dev = 0;
  800e71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e74:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e7a:	83 c4 10             	add    $0x10,%esp
  800e7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    
			*dev = devtab[i];
  800e84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e87:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e89:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8e:	eb f2                	jmp    800e82 <dev_lookup+0x4c>

00800e90 <fd_close>:
{
  800e90:	f3 0f 1e fb          	endbr32 
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	57                   	push   %edi
  800e98:	56                   	push   %esi
  800e99:	53                   	push   %ebx
  800e9a:	83 ec 28             	sub    $0x28,%esp
  800e9d:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ea3:	56                   	push   %esi
  800ea4:	e8 b0 fe ff ff       	call   800d59 <fd2num>
  800ea9:	83 c4 08             	add    $0x8,%esp
  800eac:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800eaf:	52                   	push   %edx
  800eb0:	50                   	push   %eax
  800eb1:	e8 2c ff ff ff       	call   800de2 <fd_lookup>
  800eb6:	89 c3                	mov    %eax,%ebx
  800eb8:	83 c4 10             	add    $0x10,%esp
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	78 05                	js     800ec4 <fd_close+0x34>
	    || fd != fd2)
  800ebf:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800ec2:	74 16                	je     800eda <fd_close+0x4a>
		return (must_exist ? r : 0);
  800ec4:	89 f8                	mov    %edi,%eax
  800ec6:	84 c0                	test   %al,%al
  800ec8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecd:	0f 44 d8             	cmove  %eax,%ebx
}
  800ed0:	89 d8                	mov    %ebx,%eax
  800ed2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed5:	5b                   	pop    %ebx
  800ed6:	5e                   	pop    %esi
  800ed7:	5f                   	pop    %edi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800eda:	83 ec 08             	sub    $0x8,%esp
  800edd:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800ee0:	50                   	push   %eax
  800ee1:	ff 36                	pushl  (%esi)
  800ee3:	e8 4e ff ff ff       	call   800e36 <dev_lookup>
  800ee8:	89 c3                	mov    %eax,%ebx
  800eea:	83 c4 10             	add    $0x10,%esp
  800eed:	85 c0                	test   %eax,%eax
  800eef:	78 1a                	js     800f0b <fd_close+0x7b>
		if (dev->dev_close)
  800ef1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ef4:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800ef7:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800efc:	85 c0                	test   %eax,%eax
  800efe:	74 0b                	je     800f0b <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f00:	83 ec 0c             	sub    $0xc,%esp
  800f03:	56                   	push   %esi
  800f04:	ff d0                	call   *%eax
  800f06:	89 c3                	mov    %eax,%ebx
  800f08:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f0b:	83 ec 08             	sub    $0x8,%esp
  800f0e:	56                   	push   %esi
  800f0f:	6a 00                	push   $0x0
  800f11:	e8 bf fc ff ff       	call   800bd5 <sys_page_unmap>
	return r;
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	eb b5                	jmp    800ed0 <fd_close+0x40>

00800f1b <close>:

int
close(int fdnum)
{
  800f1b:	f3 0f 1e fb          	endbr32 
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f28:	50                   	push   %eax
  800f29:	ff 75 08             	pushl  0x8(%ebp)
  800f2c:	e8 b1 fe ff ff       	call   800de2 <fd_lookup>
  800f31:	83 c4 10             	add    $0x10,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	79 02                	jns    800f3a <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800f38:	c9                   	leave  
  800f39:	c3                   	ret    
		return fd_close(fd, 1);
  800f3a:	83 ec 08             	sub    $0x8,%esp
  800f3d:	6a 01                	push   $0x1
  800f3f:	ff 75 f4             	pushl  -0xc(%ebp)
  800f42:	e8 49 ff ff ff       	call   800e90 <fd_close>
  800f47:	83 c4 10             	add    $0x10,%esp
  800f4a:	eb ec                	jmp    800f38 <close+0x1d>

00800f4c <close_all>:

void
close_all(void)
{
  800f4c:	f3 0f 1e fb          	endbr32 
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	53                   	push   %ebx
  800f54:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f57:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f5c:	83 ec 0c             	sub    $0xc,%esp
  800f5f:	53                   	push   %ebx
  800f60:	e8 b6 ff ff ff       	call   800f1b <close>
	for (i = 0; i < MAXFD; i++)
  800f65:	83 c3 01             	add    $0x1,%ebx
  800f68:	83 c4 10             	add    $0x10,%esp
  800f6b:	83 fb 20             	cmp    $0x20,%ebx
  800f6e:	75 ec                	jne    800f5c <close_all+0x10>
}
  800f70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f73:	c9                   	leave  
  800f74:	c3                   	ret    

00800f75 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f75:	f3 0f 1e fb          	endbr32 
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	57                   	push   %edi
  800f7d:	56                   	push   %esi
  800f7e:	53                   	push   %ebx
  800f7f:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f82:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f85:	50                   	push   %eax
  800f86:	ff 75 08             	pushl  0x8(%ebp)
  800f89:	e8 54 fe ff ff       	call   800de2 <fd_lookup>
  800f8e:	89 c3                	mov    %eax,%ebx
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	85 c0                	test   %eax,%eax
  800f95:	0f 88 81 00 00 00    	js     80101c <dup+0xa7>
		return r;
	close(newfdnum);
  800f9b:	83 ec 0c             	sub    $0xc,%esp
  800f9e:	ff 75 0c             	pushl  0xc(%ebp)
  800fa1:	e8 75 ff ff ff       	call   800f1b <close>

	newfd = INDEX2FD(newfdnum);
  800fa6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fa9:	c1 e6 0c             	shl    $0xc,%esi
  800fac:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800fb2:	83 c4 04             	add    $0x4,%esp
  800fb5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb8:	e8 b0 fd ff ff       	call   800d6d <fd2data>
  800fbd:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fbf:	89 34 24             	mov    %esi,(%esp)
  800fc2:	e8 a6 fd ff ff       	call   800d6d <fd2data>
  800fc7:	83 c4 10             	add    $0x10,%esp
  800fca:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fcc:	89 d8                	mov    %ebx,%eax
  800fce:	c1 e8 16             	shr    $0x16,%eax
  800fd1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd8:	a8 01                	test   $0x1,%al
  800fda:	74 11                	je     800fed <dup+0x78>
  800fdc:	89 d8                	mov    %ebx,%eax
  800fde:	c1 e8 0c             	shr    $0xc,%eax
  800fe1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe8:	f6 c2 01             	test   $0x1,%dl
  800feb:	75 39                	jne    801026 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ff0:	89 d0                	mov    %edx,%eax
  800ff2:	c1 e8 0c             	shr    $0xc,%eax
  800ff5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ffc:	83 ec 0c             	sub    $0xc,%esp
  800fff:	25 07 0e 00 00       	and    $0xe07,%eax
  801004:	50                   	push   %eax
  801005:	56                   	push   %esi
  801006:	6a 00                	push   $0x0
  801008:	52                   	push   %edx
  801009:	6a 00                	push   $0x0
  80100b:	e8 9b fb ff ff       	call   800bab <sys_page_map>
  801010:	89 c3                	mov    %eax,%ebx
  801012:	83 c4 20             	add    $0x20,%esp
  801015:	85 c0                	test   %eax,%eax
  801017:	78 31                	js     80104a <dup+0xd5>
		goto err;

	return newfdnum;
  801019:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80101c:	89 d8                	mov    %ebx,%eax
  80101e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801021:	5b                   	pop    %ebx
  801022:	5e                   	pop    %esi
  801023:	5f                   	pop    %edi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801026:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	25 07 0e 00 00       	and    $0xe07,%eax
  801035:	50                   	push   %eax
  801036:	57                   	push   %edi
  801037:	6a 00                	push   $0x0
  801039:	53                   	push   %ebx
  80103a:	6a 00                	push   $0x0
  80103c:	e8 6a fb ff ff       	call   800bab <sys_page_map>
  801041:	89 c3                	mov    %eax,%ebx
  801043:	83 c4 20             	add    $0x20,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	79 a3                	jns    800fed <dup+0x78>
	sys_page_unmap(0, newfd);
  80104a:	83 ec 08             	sub    $0x8,%esp
  80104d:	56                   	push   %esi
  80104e:	6a 00                	push   $0x0
  801050:	e8 80 fb ff ff       	call   800bd5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801055:	83 c4 08             	add    $0x8,%esp
  801058:	57                   	push   %edi
  801059:	6a 00                	push   $0x0
  80105b:	e8 75 fb ff ff       	call   800bd5 <sys_page_unmap>
	return r;
  801060:	83 c4 10             	add    $0x10,%esp
  801063:	eb b7                	jmp    80101c <dup+0xa7>

00801065 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801065:	f3 0f 1e fb          	endbr32 
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	53                   	push   %ebx
  80106d:	83 ec 1c             	sub    $0x1c,%esp
  801070:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801073:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801076:	50                   	push   %eax
  801077:	53                   	push   %ebx
  801078:	e8 65 fd ff ff       	call   800de2 <fd_lookup>
  80107d:	83 c4 10             	add    $0x10,%esp
  801080:	85 c0                	test   %eax,%eax
  801082:	78 3f                	js     8010c3 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801084:	83 ec 08             	sub    $0x8,%esp
  801087:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80108a:	50                   	push   %eax
  80108b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80108e:	ff 30                	pushl  (%eax)
  801090:	e8 a1 fd ff ff       	call   800e36 <dev_lookup>
  801095:	83 c4 10             	add    $0x10,%esp
  801098:	85 c0                	test   %eax,%eax
  80109a:	78 27                	js     8010c3 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80109c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80109f:	8b 42 08             	mov    0x8(%edx),%eax
  8010a2:	83 e0 03             	and    $0x3,%eax
  8010a5:	83 f8 01             	cmp    $0x1,%eax
  8010a8:	74 1e                	je     8010c8 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8010aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ad:	8b 40 08             	mov    0x8(%eax),%eax
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	74 35                	je     8010e9 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010b4:	83 ec 04             	sub    $0x4,%esp
  8010b7:	ff 75 10             	pushl  0x10(%ebp)
  8010ba:	ff 75 0c             	pushl  0xc(%ebp)
  8010bd:	52                   	push   %edx
  8010be:	ff d0                	call   *%eax
  8010c0:	83 c4 10             	add    $0x10,%esp
}
  8010c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c6:	c9                   	leave  
  8010c7:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8010cd:	8b 40 48             	mov    0x48(%eax),%eax
  8010d0:	83 ec 04             	sub    $0x4,%esp
  8010d3:	53                   	push   %ebx
  8010d4:	50                   	push   %eax
  8010d5:	68 d9 22 80 00       	push   $0x8022d9
  8010da:	e8 b2 f0 ff ff       	call   800191 <cprintf>
		return -E_INVAL;
  8010df:	83 c4 10             	add    $0x10,%esp
  8010e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010e7:	eb da                	jmp    8010c3 <read+0x5e>
		return -E_NOT_SUPP;
  8010e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010ee:	eb d3                	jmp    8010c3 <read+0x5e>

008010f0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010f0:	f3 0f 1e fb          	endbr32 
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	57                   	push   %edi
  8010f8:	56                   	push   %esi
  8010f9:	53                   	push   %ebx
  8010fa:	83 ec 0c             	sub    $0xc,%esp
  8010fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801100:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801103:	bb 00 00 00 00       	mov    $0x0,%ebx
  801108:	eb 02                	jmp    80110c <readn+0x1c>
  80110a:	01 c3                	add    %eax,%ebx
  80110c:	39 f3                	cmp    %esi,%ebx
  80110e:	73 21                	jae    801131 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801110:	83 ec 04             	sub    $0x4,%esp
  801113:	89 f0                	mov    %esi,%eax
  801115:	29 d8                	sub    %ebx,%eax
  801117:	50                   	push   %eax
  801118:	89 d8                	mov    %ebx,%eax
  80111a:	03 45 0c             	add    0xc(%ebp),%eax
  80111d:	50                   	push   %eax
  80111e:	57                   	push   %edi
  80111f:	e8 41 ff ff ff       	call   801065 <read>
		if (m < 0)
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	78 04                	js     80112f <readn+0x3f>
			return m;
		if (m == 0)
  80112b:	75 dd                	jne    80110a <readn+0x1a>
  80112d:	eb 02                	jmp    801131 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80112f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801131:	89 d8                	mov    %ebx,%eax
  801133:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801136:	5b                   	pop    %ebx
  801137:	5e                   	pop    %esi
  801138:	5f                   	pop    %edi
  801139:	5d                   	pop    %ebp
  80113a:	c3                   	ret    

0080113b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80113b:	f3 0f 1e fb          	endbr32 
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	53                   	push   %ebx
  801143:	83 ec 1c             	sub    $0x1c,%esp
  801146:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801149:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80114c:	50                   	push   %eax
  80114d:	53                   	push   %ebx
  80114e:	e8 8f fc ff ff       	call   800de2 <fd_lookup>
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	85 c0                	test   %eax,%eax
  801158:	78 3a                	js     801194 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115a:	83 ec 08             	sub    $0x8,%esp
  80115d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801160:	50                   	push   %eax
  801161:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801164:	ff 30                	pushl  (%eax)
  801166:	e8 cb fc ff ff       	call   800e36 <dev_lookup>
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	85 c0                	test   %eax,%eax
  801170:	78 22                	js     801194 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801172:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801175:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801179:	74 1e                	je     801199 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80117b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80117e:	8b 52 0c             	mov    0xc(%edx),%edx
  801181:	85 d2                	test   %edx,%edx
  801183:	74 35                	je     8011ba <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801185:	83 ec 04             	sub    $0x4,%esp
  801188:	ff 75 10             	pushl  0x10(%ebp)
  80118b:	ff 75 0c             	pushl  0xc(%ebp)
  80118e:	50                   	push   %eax
  80118f:	ff d2                	call   *%edx
  801191:	83 c4 10             	add    $0x10,%esp
}
  801194:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801197:	c9                   	leave  
  801198:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801199:	a1 04 40 80 00       	mov    0x804004,%eax
  80119e:	8b 40 48             	mov    0x48(%eax),%eax
  8011a1:	83 ec 04             	sub    $0x4,%esp
  8011a4:	53                   	push   %ebx
  8011a5:	50                   	push   %eax
  8011a6:	68 f5 22 80 00       	push   $0x8022f5
  8011ab:	e8 e1 ef ff ff       	call   800191 <cprintf>
		return -E_INVAL;
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b8:	eb da                	jmp    801194 <write+0x59>
		return -E_NOT_SUPP;
  8011ba:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011bf:	eb d3                	jmp    801194 <write+0x59>

008011c1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011c1:	f3 0f 1e fb          	endbr32 
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ce:	50                   	push   %eax
  8011cf:	ff 75 08             	pushl  0x8(%ebp)
  8011d2:	e8 0b fc ff ff       	call   800de2 <fd_lookup>
  8011d7:	83 c4 10             	add    $0x10,%esp
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	78 0e                	js     8011ec <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8011de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ec:	c9                   	leave  
  8011ed:	c3                   	ret    

008011ee <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011ee:	f3 0f 1e fb          	endbr32 
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	53                   	push   %ebx
  8011f6:	83 ec 1c             	sub    $0x1c,%esp
  8011f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ff:	50                   	push   %eax
  801200:	53                   	push   %ebx
  801201:	e8 dc fb ff ff       	call   800de2 <fd_lookup>
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 37                	js     801244 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120d:	83 ec 08             	sub    $0x8,%esp
  801210:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801213:	50                   	push   %eax
  801214:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801217:	ff 30                	pushl  (%eax)
  801219:	e8 18 fc ff ff       	call   800e36 <dev_lookup>
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	85 c0                	test   %eax,%eax
  801223:	78 1f                	js     801244 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801225:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801228:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80122c:	74 1b                	je     801249 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80122e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801231:	8b 52 18             	mov    0x18(%edx),%edx
  801234:	85 d2                	test   %edx,%edx
  801236:	74 32                	je     80126a <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801238:	83 ec 08             	sub    $0x8,%esp
  80123b:	ff 75 0c             	pushl  0xc(%ebp)
  80123e:	50                   	push   %eax
  80123f:	ff d2                	call   *%edx
  801241:	83 c4 10             	add    $0x10,%esp
}
  801244:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801247:	c9                   	leave  
  801248:	c3                   	ret    
			thisenv->env_id, fdnum);
  801249:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80124e:	8b 40 48             	mov    0x48(%eax),%eax
  801251:	83 ec 04             	sub    $0x4,%esp
  801254:	53                   	push   %ebx
  801255:	50                   	push   %eax
  801256:	68 b8 22 80 00       	push   $0x8022b8
  80125b:	e8 31 ef ff ff       	call   800191 <cprintf>
		return -E_INVAL;
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801268:	eb da                	jmp    801244 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80126a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80126f:	eb d3                	jmp    801244 <ftruncate+0x56>

00801271 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801271:	f3 0f 1e fb          	endbr32 
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	53                   	push   %ebx
  801279:	83 ec 1c             	sub    $0x1c,%esp
  80127c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801282:	50                   	push   %eax
  801283:	ff 75 08             	pushl  0x8(%ebp)
  801286:	e8 57 fb ff ff       	call   800de2 <fd_lookup>
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 4b                	js     8012dd <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801292:	83 ec 08             	sub    $0x8,%esp
  801295:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801298:	50                   	push   %eax
  801299:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129c:	ff 30                	pushl  (%eax)
  80129e:	e8 93 fb ff ff       	call   800e36 <dev_lookup>
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 33                	js     8012dd <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8012aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ad:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012b1:	74 2f                	je     8012e2 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012b3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012b6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012bd:	00 00 00 
	stat->st_isdir = 0;
  8012c0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012c7:	00 00 00 
	stat->st_dev = dev;
  8012ca:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012d0:	83 ec 08             	sub    $0x8,%esp
  8012d3:	53                   	push   %ebx
  8012d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d7:	ff 50 14             	call   *0x14(%eax)
  8012da:	83 c4 10             	add    $0x10,%esp
}
  8012dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e0:	c9                   	leave  
  8012e1:	c3                   	ret    
		return -E_NOT_SUPP;
  8012e2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012e7:	eb f4                	jmp    8012dd <fstat+0x6c>

008012e9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012e9:	f3 0f 1e fb          	endbr32 
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	56                   	push   %esi
  8012f1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012f2:	83 ec 08             	sub    $0x8,%esp
  8012f5:	6a 00                	push   $0x0
  8012f7:	ff 75 08             	pushl  0x8(%ebp)
  8012fa:	e8 20 02 00 00       	call   80151f <open>
  8012ff:	89 c3                	mov    %eax,%ebx
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	85 c0                	test   %eax,%eax
  801306:	78 1b                	js     801323 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801308:	83 ec 08             	sub    $0x8,%esp
  80130b:	ff 75 0c             	pushl  0xc(%ebp)
  80130e:	50                   	push   %eax
  80130f:	e8 5d ff ff ff       	call   801271 <fstat>
  801314:	89 c6                	mov    %eax,%esi
	close(fd);
  801316:	89 1c 24             	mov    %ebx,(%esp)
  801319:	e8 fd fb ff ff       	call   800f1b <close>
	return r;
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	89 f3                	mov    %esi,%ebx
}
  801323:	89 d8                	mov    %ebx,%eax
  801325:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801328:	5b                   	pop    %ebx
  801329:	5e                   	pop    %esi
  80132a:	5d                   	pop    %ebp
  80132b:	c3                   	ret    

0080132c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	56                   	push   %esi
  801330:	53                   	push   %ebx
  801331:	89 c6                	mov    %eax,%esi
  801333:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801335:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80133c:	74 27                	je     801365 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80133e:	6a 07                	push   $0x7
  801340:	68 00 50 80 00       	push   $0x805000
  801345:	56                   	push   %esi
  801346:	ff 35 00 40 80 00    	pushl  0x804000
  80134c:	e8 2d 08 00 00       	call   801b7e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801351:	83 c4 0c             	add    $0xc,%esp
  801354:	6a 00                	push   $0x0
  801356:	53                   	push   %ebx
  801357:	6a 00                	push   $0x0
  801359:	e8 b3 07 00 00       	call   801b11 <ipc_recv>
}
  80135e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801361:	5b                   	pop    %ebx
  801362:	5e                   	pop    %esi
  801363:	5d                   	pop    %ebp
  801364:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801365:	83 ec 0c             	sub    $0xc,%esp
  801368:	6a 01                	push   $0x1
  80136a:	e8 62 08 00 00       	call   801bd1 <ipc_find_env>
  80136f:	a3 00 40 80 00       	mov    %eax,0x804000
  801374:	83 c4 10             	add    $0x10,%esp
  801377:	eb c5                	jmp    80133e <fsipc+0x12>

00801379 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801379:	f3 0f 1e fb          	endbr32 
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801383:	8b 45 08             	mov    0x8(%ebp),%eax
  801386:	8b 40 0c             	mov    0xc(%eax),%eax
  801389:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80138e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801391:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801396:	ba 00 00 00 00       	mov    $0x0,%edx
  80139b:	b8 02 00 00 00       	mov    $0x2,%eax
  8013a0:	e8 87 ff ff ff       	call   80132c <fsipc>
}
  8013a5:	c9                   	leave  
  8013a6:	c3                   	ret    

008013a7 <devfile_flush>:
{
  8013a7:	f3 0f 1e fb          	endbr32 
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c1:	b8 06 00 00 00       	mov    $0x6,%eax
  8013c6:	e8 61 ff ff ff       	call   80132c <fsipc>
}
  8013cb:	c9                   	leave  
  8013cc:	c3                   	ret    

008013cd <devfile_stat>:
{
  8013cd:	f3 0f 1e fb          	endbr32 
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	53                   	push   %ebx
  8013d5:	83 ec 04             	sub    $0x4,%esp
  8013d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013db:	8b 45 08             	mov    0x8(%ebp),%eax
  8013de:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013eb:	b8 05 00 00 00       	mov    $0x5,%eax
  8013f0:	e8 37 ff ff ff       	call   80132c <fsipc>
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	78 2c                	js     801425 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	68 00 50 80 00       	push   $0x805000
  801401:	53                   	push   %ebx
  801402:	e8 f4 f2 ff ff       	call   8006fb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801407:	a1 80 50 80 00       	mov    0x805080,%eax
  80140c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801412:	a1 84 50 80 00       	mov    0x805084,%eax
  801417:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801425:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801428:	c9                   	leave  
  801429:	c3                   	ret    

0080142a <devfile_write>:
{
  80142a:	f3 0f 1e fb          	endbr32 
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	57                   	push   %edi
  801432:	56                   	push   %esi
  801433:	53                   	push   %ebx
  801434:	83 ec 0c             	sub    $0xc,%esp
  801437:	8b 75 0c             	mov    0xc(%ebp),%esi
  80143a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80143d:	8b 45 08             	mov    0x8(%ebp),%eax
  801440:	8b 40 0c             	mov    0xc(%eax),%eax
  801443:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  801448:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80144d:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  801452:	85 db                	test   %ebx,%ebx
  801454:	74 3b                	je     801491 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801456:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  80145c:	89 f8                	mov    %edi,%eax
  80145e:	0f 46 c3             	cmovbe %ebx,%eax
  801461:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  801466:	83 ec 04             	sub    $0x4,%esp
  801469:	50                   	push   %eax
  80146a:	56                   	push   %esi
  80146b:	68 08 50 80 00       	push   $0x805008
  801470:	e8 3e f4 ff ff       	call   8008b3 <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801475:	ba 00 00 00 00       	mov    $0x0,%edx
  80147a:	b8 04 00 00 00       	mov    $0x4,%eax
  80147f:	e8 a8 fe ff ff       	call   80132c <fsipc>
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	85 c0                	test   %eax,%eax
  801489:	78 06                	js     801491 <devfile_write+0x67>
		buf_aux += r;
  80148b:	01 c6                	add    %eax,%esi
		n -= r;
  80148d:	29 c3                	sub    %eax,%ebx
  80148f:	eb c1                	jmp    801452 <devfile_write+0x28>
}
  801491:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801494:	5b                   	pop    %ebx
  801495:	5e                   	pop    %esi
  801496:	5f                   	pop    %edi
  801497:	5d                   	pop    %ebp
  801498:	c3                   	ret    

00801499 <devfile_read>:
{
  801499:	f3 0f 1e fb          	endbr32 
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	56                   	push   %esi
  8014a1:	53                   	push   %ebx
  8014a2:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ab:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014b0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bb:	b8 03 00 00 00       	mov    $0x3,%eax
  8014c0:	e8 67 fe ff ff       	call   80132c <fsipc>
  8014c5:	89 c3                	mov    %eax,%ebx
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	78 1f                	js     8014ea <devfile_read+0x51>
	assert(r <= n);
  8014cb:	39 f0                	cmp    %esi,%eax
  8014cd:	77 24                	ja     8014f3 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8014cf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014d4:	7f 33                	jg     801509 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014d6:	83 ec 04             	sub    $0x4,%esp
  8014d9:	50                   	push   %eax
  8014da:	68 00 50 80 00       	push   $0x805000
  8014df:	ff 75 0c             	pushl  0xc(%ebp)
  8014e2:	e8 cc f3 ff ff       	call   8008b3 <memmove>
	return r;
  8014e7:	83 c4 10             	add    $0x10,%esp
}
  8014ea:	89 d8                	mov    %ebx,%eax
  8014ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ef:	5b                   	pop    %ebx
  8014f0:	5e                   	pop    %esi
  8014f1:	5d                   	pop    %ebp
  8014f2:	c3                   	ret    
	assert(r <= n);
  8014f3:	68 24 23 80 00       	push   $0x802324
  8014f8:	68 2b 23 80 00       	push   $0x80232b
  8014fd:	6a 7c                	push   $0x7c
  8014ff:	68 40 23 80 00       	push   $0x802340
  801504:	e8 be 05 00 00       	call   801ac7 <_panic>
	assert(r <= PGSIZE);
  801509:	68 4b 23 80 00       	push   $0x80234b
  80150e:	68 2b 23 80 00       	push   $0x80232b
  801513:	6a 7d                	push   $0x7d
  801515:	68 40 23 80 00       	push   $0x802340
  80151a:	e8 a8 05 00 00       	call   801ac7 <_panic>

0080151f <open>:
{
  80151f:	f3 0f 1e fb          	endbr32 
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	56                   	push   %esi
  801527:	53                   	push   %ebx
  801528:	83 ec 1c             	sub    $0x1c,%esp
  80152b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80152e:	56                   	push   %esi
  80152f:	e8 84 f1 ff ff       	call   8006b8 <strlen>
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80153c:	7f 6c                	jg     8015aa <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80153e:	83 ec 0c             	sub    $0xc,%esp
  801541:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801544:	50                   	push   %eax
  801545:	e8 42 f8 ff ff       	call   800d8c <fd_alloc>
  80154a:	89 c3                	mov    %eax,%ebx
  80154c:	83 c4 10             	add    $0x10,%esp
  80154f:	85 c0                	test   %eax,%eax
  801551:	78 3c                	js     80158f <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801553:	83 ec 08             	sub    $0x8,%esp
  801556:	56                   	push   %esi
  801557:	68 00 50 80 00       	push   $0x805000
  80155c:	e8 9a f1 ff ff       	call   8006fb <strcpy>
	fsipcbuf.open.req_omode = mode;
  801561:	8b 45 0c             	mov    0xc(%ebp),%eax
  801564:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801569:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156c:	b8 01 00 00 00       	mov    $0x1,%eax
  801571:	e8 b6 fd ff ff       	call   80132c <fsipc>
  801576:	89 c3                	mov    %eax,%ebx
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 19                	js     801598 <open+0x79>
	return fd2num(fd);
  80157f:	83 ec 0c             	sub    $0xc,%esp
  801582:	ff 75 f4             	pushl  -0xc(%ebp)
  801585:	e8 cf f7 ff ff       	call   800d59 <fd2num>
  80158a:	89 c3                	mov    %eax,%ebx
  80158c:	83 c4 10             	add    $0x10,%esp
}
  80158f:	89 d8                	mov    %ebx,%eax
  801591:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801594:	5b                   	pop    %ebx
  801595:	5e                   	pop    %esi
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    
		fd_close(fd, 0);
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	6a 00                	push   $0x0
  80159d:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a0:	e8 eb f8 ff ff       	call   800e90 <fd_close>
		return r;
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	eb e5                	jmp    80158f <open+0x70>
		return -E_BAD_PATH;
  8015aa:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015af:	eb de                	jmp    80158f <open+0x70>

008015b1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015b1:	f3 0f 1e fb          	endbr32 
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c0:	b8 08 00 00 00       	mov    $0x8,%eax
  8015c5:	e8 62 fd ff ff       	call   80132c <fsipc>
}
  8015ca:	c9                   	leave  
  8015cb:	c3                   	ret    

008015cc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015cc:	f3 0f 1e fb          	endbr32 
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	56                   	push   %esi
  8015d4:	53                   	push   %ebx
  8015d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015d8:	83 ec 0c             	sub    $0xc,%esp
  8015db:	ff 75 08             	pushl  0x8(%ebp)
  8015de:	e8 8a f7 ff ff       	call   800d6d <fd2data>
  8015e3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015e5:	83 c4 08             	add    $0x8,%esp
  8015e8:	68 57 23 80 00       	push   $0x802357
  8015ed:	53                   	push   %ebx
  8015ee:	e8 08 f1 ff ff       	call   8006fb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015f3:	8b 46 04             	mov    0x4(%esi),%eax
  8015f6:	2b 06                	sub    (%esi),%eax
  8015f8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015fe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801605:	00 00 00 
	stat->st_dev = &devpipe;
  801608:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80160f:	30 80 00 
	return 0;
}
  801612:	b8 00 00 00 00       	mov    $0x0,%eax
  801617:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161a:	5b                   	pop    %ebx
  80161b:	5e                   	pop    %esi
  80161c:	5d                   	pop    %ebp
  80161d:	c3                   	ret    

0080161e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80161e:	f3 0f 1e fb          	endbr32 
  801622:	55                   	push   %ebp
  801623:	89 e5                	mov    %esp,%ebp
  801625:	53                   	push   %ebx
  801626:	83 ec 0c             	sub    $0xc,%esp
  801629:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80162c:	53                   	push   %ebx
  80162d:	6a 00                	push   $0x0
  80162f:	e8 a1 f5 ff ff       	call   800bd5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801634:	89 1c 24             	mov    %ebx,(%esp)
  801637:	e8 31 f7 ff ff       	call   800d6d <fd2data>
  80163c:	83 c4 08             	add    $0x8,%esp
  80163f:	50                   	push   %eax
  801640:	6a 00                	push   $0x0
  801642:	e8 8e f5 ff ff       	call   800bd5 <sys_page_unmap>
}
  801647:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164a:	c9                   	leave  
  80164b:	c3                   	ret    

0080164c <_pipeisclosed>:
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	57                   	push   %edi
  801650:	56                   	push   %esi
  801651:	53                   	push   %ebx
  801652:	83 ec 1c             	sub    $0x1c,%esp
  801655:	89 c7                	mov    %eax,%edi
  801657:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801659:	a1 04 40 80 00       	mov    0x804004,%eax
  80165e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801661:	83 ec 0c             	sub    $0xc,%esp
  801664:	57                   	push   %edi
  801665:	e8 a4 05 00 00       	call   801c0e <pageref>
  80166a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80166d:	89 34 24             	mov    %esi,(%esp)
  801670:	e8 99 05 00 00       	call   801c0e <pageref>
		nn = thisenv->env_runs;
  801675:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80167b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	39 cb                	cmp    %ecx,%ebx
  801683:	74 1b                	je     8016a0 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801685:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801688:	75 cf                	jne    801659 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80168a:	8b 42 58             	mov    0x58(%edx),%eax
  80168d:	6a 01                	push   $0x1
  80168f:	50                   	push   %eax
  801690:	53                   	push   %ebx
  801691:	68 5e 23 80 00       	push   $0x80235e
  801696:	e8 f6 ea ff ff       	call   800191 <cprintf>
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	eb b9                	jmp    801659 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8016a0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016a3:	0f 94 c0             	sete   %al
  8016a6:	0f b6 c0             	movzbl %al,%eax
}
  8016a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ac:	5b                   	pop    %ebx
  8016ad:	5e                   	pop    %esi
  8016ae:	5f                   	pop    %edi
  8016af:	5d                   	pop    %ebp
  8016b0:	c3                   	ret    

008016b1 <devpipe_write>:
{
  8016b1:	f3 0f 1e fb          	endbr32 
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	57                   	push   %edi
  8016b9:	56                   	push   %esi
  8016ba:	53                   	push   %ebx
  8016bb:	83 ec 28             	sub    $0x28,%esp
  8016be:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8016c1:	56                   	push   %esi
  8016c2:	e8 a6 f6 ff ff       	call   800d6d <fd2data>
  8016c7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	bf 00 00 00 00       	mov    $0x0,%edi
  8016d1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016d4:	74 4f                	je     801725 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016d6:	8b 43 04             	mov    0x4(%ebx),%eax
  8016d9:	8b 0b                	mov    (%ebx),%ecx
  8016db:	8d 51 20             	lea    0x20(%ecx),%edx
  8016de:	39 d0                	cmp    %edx,%eax
  8016e0:	72 14                	jb     8016f6 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8016e2:	89 da                	mov    %ebx,%edx
  8016e4:	89 f0                	mov    %esi,%eax
  8016e6:	e8 61 ff ff ff       	call   80164c <_pipeisclosed>
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	75 3b                	jne    80172a <devpipe_write+0x79>
			sys_yield();
  8016ef:	e8 64 f4 ff ff       	call   800b58 <sys_yield>
  8016f4:	eb e0                	jmp    8016d6 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016fd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801700:	89 c2                	mov    %eax,%edx
  801702:	c1 fa 1f             	sar    $0x1f,%edx
  801705:	89 d1                	mov    %edx,%ecx
  801707:	c1 e9 1b             	shr    $0x1b,%ecx
  80170a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80170d:	83 e2 1f             	and    $0x1f,%edx
  801710:	29 ca                	sub    %ecx,%edx
  801712:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801716:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80171a:	83 c0 01             	add    $0x1,%eax
  80171d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801720:	83 c7 01             	add    $0x1,%edi
  801723:	eb ac                	jmp    8016d1 <devpipe_write+0x20>
	return i;
  801725:	8b 45 10             	mov    0x10(%ebp),%eax
  801728:	eb 05                	jmp    80172f <devpipe_write+0x7e>
				return 0;
  80172a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80172f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801732:	5b                   	pop    %ebx
  801733:	5e                   	pop    %esi
  801734:	5f                   	pop    %edi
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <devpipe_read>:
{
  801737:	f3 0f 1e fb          	endbr32 
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	57                   	push   %edi
  80173f:	56                   	push   %esi
  801740:	53                   	push   %ebx
  801741:	83 ec 18             	sub    $0x18,%esp
  801744:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801747:	57                   	push   %edi
  801748:	e8 20 f6 ff ff       	call   800d6d <fd2data>
  80174d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	be 00 00 00 00       	mov    $0x0,%esi
  801757:	3b 75 10             	cmp    0x10(%ebp),%esi
  80175a:	75 14                	jne    801770 <devpipe_read+0x39>
	return i;
  80175c:	8b 45 10             	mov    0x10(%ebp),%eax
  80175f:	eb 02                	jmp    801763 <devpipe_read+0x2c>
				return i;
  801761:	89 f0                	mov    %esi,%eax
}
  801763:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801766:	5b                   	pop    %ebx
  801767:	5e                   	pop    %esi
  801768:	5f                   	pop    %edi
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    
			sys_yield();
  80176b:	e8 e8 f3 ff ff       	call   800b58 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801770:	8b 03                	mov    (%ebx),%eax
  801772:	3b 43 04             	cmp    0x4(%ebx),%eax
  801775:	75 18                	jne    80178f <devpipe_read+0x58>
			if (i > 0)
  801777:	85 f6                	test   %esi,%esi
  801779:	75 e6                	jne    801761 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  80177b:	89 da                	mov    %ebx,%edx
  80177d:	89 f8                	mov    %edi,%eax
  80177f:	e8 c8 fe ff ff       	call   80164c <_pipeisclosed>
  801784:	85 c0                	test   %eax,%eax
  801786:	74 e3                	je     80176b <devpipe_read+0x34>
				return 0;
  801788:	b8 00 00 00 00       	mov    $0x0,%eax
  80178d:	eb d4                	jmp    801763 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80178f:	99                   	cltd   
  801790:	c1 ea 1b             	shr    $0x1b,%edx
  801793:	01 d0                	add    %edx,%eax
  801795:	83 e0 1f             	and    $0x1f,%eax
  801798:	29 d0                	sub    %edx,%eax
  80179a:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80179f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017a2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8017a5:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8017a8:	83 c6 01             	add    $0x1,%esi
  8017ab:	eb aa                	jmp    801757 <devpipe_read+0x20>

008017ad <pipe>:
{
  8017ad:	f3 0f 1e fb          	endbr32 
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	56                   	push   %esi
  8017b5:	53                   	push   %ebx
  8017b6:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8017b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017bc:	50                   	push   %eax
  8017bd:	e8 ca f5 ff ff       	call   800d8c <fd_alloc>
  8017c2:	89 c3                	mov    %eax,%ebx
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	0f 88 23 01 00 00    	js     8018f2 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017cf:	83 ec 04             	sub    $0x4,%esp
  8017d2:	68 07 04 00 00       	push   $0x407
  8017d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8017da:	6a 00                	push   $0x0
  8017dc:	e8 a2 f3 ff ff       	call   800b83 <sys_page_alloc>
  8017e1:	89 c3                	mov    %eax,%ebx
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	0f 88 04 01 00 00    	js     8018f2 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8017ee:	83 ec 0c             	sub    $0xc,%esp
  8017f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f4:	50                   	push   %eax
  8017f5:	e8 92 f5 ff ff       	call   800d8c <fd_alloc>
  8017fa:	89 c3                	mov    %eax,%ebx
  8017fc:	83 c4 10             	add    $0x10,%esp
  8017ff:	85 c0                	test   %eax,%eax
  801801:	0f 88 db 00 00 00    	js     8018e2 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801807:	83 ec 04             	sub    $0x4,%esp
  80180a:	68 07 04 00 00       	push   $0x407
  80180f:	ff 75 f0             	pushl  -0x10(%ebp)
  801812:	6a 00                	push   $0x0
  801814:	e8 6a f3 ff ff       	call   800b83 <sys_page_alloc>
  801819:	89 c3                	mov    %eax,%ebx
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	85 c0                	test   %eax,%eax
  801820:	0f 88 bc 00 00 00    	js     8018e2 <pipe+0x135>
	va = fd2data(fd0);
  801826:	83 ec 0c             	sub    $0xc,%esp
  801829:	ff 75 f4             	pushl  -0xc(%ebp)
  80182c:	e8 3c f5 ff ff       	call   800d6d <fd2data>
  801831:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801833:	83 c4 0c             	add    $0xc,%esp
  801836:	68 07 04 00 00       	push   $0x407
  80183b:	50                   	push   %eax
  80183c:	6a 00                	push   $0x0
  80183e:	e8 40 f3 ff ff       	call   800b83 <sys_page_alloc>
  801843:	89 c3                	mov    %eax,%ebx
  801845:	83 c4 10             	add    $0x10,%esp
  801848:	85 c0                	test   %eax,%eax
  80184a:	0f 88 82 00 00 00    	js     8018d2 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801850:	83 ec 0c             	sub    $0xc,%esp
  801853:	ff 75 f0             	pushl  -0x10(%ebp)
  801856:	e8 12 f5 ff ff       	call   800d6d <fd2data>
  80185b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801862:	50                   	push   %eax
  801863:	6a 00                	push   $0x0
  801865:	56                   	push   %esi
  801866:	6a 00                	push   $0x0
  801868:	e8 3e f3 ff ff       	call   800bab <sys_page_map>
  80186d:	89 c3                	mov    %eax,%ebx
  80186f:	83 c4 20             	add    $0x20,%esp
  801872:	85 c0                	test   %eax,%eax
  801874:	78 4e                	js     8018c4 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801876:	a1 20 30 80 00       	mov    0x803020,%eax
  80187b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80187e:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801880:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801883:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80188a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80188d:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80188f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801892:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801899:	83 ec 0c             	sub    $0xc,%esp
  80189c:	ff 75 f4             	pushl  -0xc(%ebp)
  80189f:	e8 b5 f4 ff ff       	call   800d59 <fd2num>
  8018a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018a7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018a9:	83 c4 04             	add    $0x4,%esp
  8018ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8018af:	e8 a5 f4 ff ff       	call   800d59 <fd2num>
  8018b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018b7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018ba:	83 c4 10             	add    $0x10,%esp
  8018bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018c2:	eb 2e                	jmp    8018f2 <pipe+0x145>
	sys_page_unmap(0, va);
  8018c4:	83 ec 08             	sub    $0x8,%esp
  8018c7:	56                   	push   %esi
  8018c8:	6a 00                	push   $0x0
  8018ca:	e8 06 f3 ff ff       	call   800bd5 <sys_page_unmap>
  8018cf:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8018d2:	83 ec 08             	sub    $0x8,%esp
  8018d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d8:	6a 00                	push   $0x0
  8018da:	e8 f6 f2 ff ff       	call   800bd5 <sys_page_unmap>
  8018df:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8018e2:	83 ec 08             	sub    $0x8,%esp
  8018e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e8:	6a 00                	push   $0x0
  8018ea:	e8 e6 f2 ff ff       	call   800bd5 <sys_page_unmap>
  8018ef:	83 c4 10             	add    $0x10,%esp
}
  8018f2:	89 d8                	mov    %ebx,%eax
  8018f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f7:	5b                   	pop    %ebx
  8018f8:	5e                   	pop    %esi
  8018f9:	5d                   	pop    %ebp
  8018fa:	c3                   	ret    

008018fb <pipeisclosed>:
{
  8018fb:	f3 0f 1e fb          	endbr32 
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801905:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801908:	50                   	push   %eax
  801909:	ff 75 08             	pushl  0x8(%ebp)
  80190c:	e8 d1 f4 ff ff       	call   800de2 <fd_lookup>
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	85 c0                	test   %eax,%eax
  801916:	78 18                	js     801930 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801918:	83 ec 0c             	sub    $0xc,%esp
  80191b:	ff 75 f4             	pushl  -0xc(%ebp)
  80191e:	e8 4a f4 ff ff       	call   800d6d <fd2data>
  801923:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801925:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801928:	e8 1f fd ff ff       	call   80164c <_pipeisclosed>
  80192d:	83 c4 10             	add    $0x10,%esp
}
  801930:	c9                   	leave  
  801931:	c3                   	ret    

00801932 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801932:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801936:	b8 00 00 00 00       	mov    $0x0,%eax
  80193b:	c3                   	ret    

0080193c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80193c:	f3 0f 1e fb          	endbr32 
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801946:	68 76 23 80 00       	push   $0x802376
  80194b:	ff 75 0c             	pushl  0xc(%ebp)
  80194e:	e8 a8 ed ff ff       	call   8006fb <strcpy>
	return 0;
}
  801953:	b8 00 00 00 00       	mov    $0x0,%eax
  801958:	c9                   	leave  
  801959:	c3                   	ret    

0080195a <devcons_write>:
{
  80195a:	f3 0f 1e fb          	endbr32 
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	57                   	push   %edi
  801962:	56                   	push   %esi
  801963:	53                   	push   %ebx
  801964:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80196a:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80196f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801975:	3b 75 10             	cmp    0x10(%ebp),%esi
  801978:	73 31                	jae    8019ab <devcons_write+0x51>
		m = n - tot;
  80197a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80197d:	29 f3                	sub    %esi,%ebx
  80197f:	83 fb 7f             	cmp    $0x7f,%ebx
  801982:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801987:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80198a:	83 ec 04             	sub    $0x4,%esp
  80198d:	53                   	push   %ebx
  80198e:	89 f0                	mov    %esi,%eax
  801990:	03 45 0c             	add    0xc(%ebp),%eax
  801993:	50                   	push   %eax
  801994:	57                   	push   %edi
  801995:	e8 19 ef ff ff       	call   8008b3 <memmove>
		sys_cputs(buf, m);
  80199a:	83 c4 08             	add    $0x8,%esp
  80199d:	53                   	push   %ebx
  80199e:	57                   	push   %edi
  80199f:	e8 14 f1 ff ff       	call   800ab8 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8019a4:	01 de                	add    %ebx,%esi
  8019a6:	83 c4 10             	add    $0x10,%esp
  8019a9:	eb ca                	jmp    801975 <devcons_write+0x1b>
}
  8019ab:	89 f0                	mov    %esi,%eax
  8019ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b0:	5b                   	pop    %ebx
  8019b1:	5e                   	pop    %esi
  8019b2:	5f                   	pop    %edi
  8019b3:	5d                   	pop    %ebp
  8019b4:	c3                   	ret    

008019b5 <devcons_read>:
{
  8019b5:	f3 0f 1e fb          	endbr32 
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	83 ec 08             	sub    $0x8,%esp
  8019bf:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8019c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019c8:	74 21                	je     8019eb <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8019ca:	e8 13 f1 ff ff       	call   800ae2 <sys_cgetc>
  8019cf:	85 c0                	test   %eax,%eax
  8019d1:	75 07                	jne    8019da <devcons_read+0x25>
		sys_yield();
  8019d3:	e8 80 f1 ff ff       	call   800b58 <sys_yield>
  8019d8:	eb f0                	jmp    8019ca <devcons_read+0x15>
	if (c < 0)
  8019da:	78 0f                	js     8019eb <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8019dc:	83 f8 04             	cmp    $0x4,%eax
  8019df:	74 0c                	je     8019ed <devcons_read+0x38>
	*(char*)vbuf = c;
  8019e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019e4:	88 02                	mov    %al,(%edx)
	return 1;
  8019e6:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8019eb:	c9                   	leave  
  8019ec:	c3                   	ret    
		return 0;
  8019ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f2:	eb f7                	jmp    8019eb <devcons_read+0x36>

008019f4 <cputchar>:
{
  8019f4:	f3 0f 1e fb          	endbr32 
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801a01:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a04:	6a 01                	push   $0x1
  801a06:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a09:	50                   	push   %eax
  801a0a:	e8 a9 f0 ff ff       	call   800ab8 <sys_cputs>
}
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	c9                   	leave  
  801a13:	c3                   	ret    

00801a14 <getchar>:
{
  801a14:	f3 0f 1e fb          	endbr32 
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801a1e:	6a 01                	push   $0x1
  801a20:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a23:	50                   	push   %eax
  801a24:	6a 00                	push   $0x0
  801a26:	e8 3a f6 ff ff       	call   801065 <read>
	if (r < 0)
  801a2b:	83 c4 10             	add    $0x10,%esp
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	78 06                	js     801a38 <getchar+0x24>
	if (r < 1)
  801a32:	74 06                	je     801a3a <getchar+0x26>
	return c;
  801a34:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801a38:	c9                   	leave  
  801a39:	c3                   	ret    
		return -E_EOF;
  801a3a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801a3f:	eb f7                	jmp    801a38 <getchar+0x24>

00801a41 <iscons>:
{
  801a41:	f3 0f 1e fb          	endbr32 
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4e:	50                   	push   %eax
  801a4f:	ff 75 08             	pushl  0x8(%ebp)
  801a52:	e8 8b f3 ff ff       	call   800de2 <fd_lookup>
  801a57:	83 c4 10             	add    $0x10,%esp
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	78 11                	js     801a6f <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a61:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a67:	39 10                	cmp    %edx,(%eax)
  801a69:	0f 94 c0             	sete   %al
  801a6c:	0f b6 c0             	movzbl %al,%eax
}
  801a6f:	c9                   	leave  
  801a70:	c3                   	ret    

00801a71 <opencons>:
{
  801a71:	f3 0f 1e fb          	endbr32 
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801a7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7e:	50                   	push   %eax
  801a7f:	e8 08 f3 ff ff       	call   800d8c <fd_alloc>
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	85 c0                	test   %eax,%eax
  801a89:	78 3a                	js     801ac5 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a8b:	83 ec 04             	sub    $0x4,%esp
  801a8e:	68 07 04 00 00       	push   $0x407
  801a93:	ff 75 f4             	pushl  -0xc(%ebp)
  801a96:	6a 00                	push   $0x0
  801a98:	e8 e6 f0 ff ff       	call   800b83 <sys_page_alloc>
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	78 21                	js     801ac5 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aad:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ab9:	83 ec 0c             	sub    $0xc,%esp
  801abc:	50                   	push   %eax
  801abd:	e8 97 f2 ff ff       	call   800d59 <fd2num>
  801ac2:	83 c4 10             	add    $0x10,%esp
}
  801ac5:	c9                   	leave  
  801ac6:	c3                   	ret    

00801ac7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ac7:	f3 0f 1e fb          	endbr32 
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	56                   	push   %esi
  801acf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ad0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ad3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ad9:	e8 52 f0 ff ff       	call   800b30 <sys_getenvid>
  801ade:	83 ec 0c             	sub    $0xc,%esp
  801ae1:	ff 75 0c             	pushl  0xc(%ebp)
  801ae4:	ff 75 08             	pushl  0x8(%ebp)
  801ae7:	56                   	push   %esi
  801ae8:	50                   	push   %eax
  801ae9:	68 84 23 80 00       	push   $0x802384
  801aee:	e8 9e e6 ff ff       	call   800191 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801af3:	83 c4 18             	add    $0x18,%esp
  801af6:	53                   	push   %ebx
  801af7:	ff 75 10             	pushl  0x10(%ebp)
  801afa:	e8 3d e6 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  801aff:	c7 04 24 6f 23 80 00 	movl   $0x80236f,(%esp)
  801b06:	e8 86 e6 ff ff       	call   800191 <cprintf>
  801b0b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b0e:	cc                   	int3   
  801b0f:	eb fd                	jmp    801b0e <_panic+0x47>

00801b11 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b11:	f3 0f 1e fb          	endbr32 
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	56                   	push   %esi
  801b19:	53                   	push   %ebx
  801b1a:	8b 75 08             	mov    0x8(%ebp),%esi
  801b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  801b23:	85 c0                	test   %eax,%eax
  801b25:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b2a:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801b2d:	83 ec 0c             	sub    $0xc,%esp
  801b30:	50                   	push   %eax
  801b31:	e8 64 f1 ff ff       	call   800c9a <sys_ipc_recv>
	if (f < 0) {
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	78 2b                	js     801b68 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801b3d:	85 f6                	test   %esi,%esi
  801b3f:	74 0a                	je     801b4b <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801b41:	a1 04 40 80 00       	mov    0x804004,%eax
  801b46:	8b 40 74             	mov    0x74(%eax),%eax
  801b49:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801b4b:	85 db                	test   %ebx,%ebx
  801b4d:	74 0a                	je     801b59 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801b4f:	a1 04 40 80 00       	mov    0x804004,%eax
  801b54:	8b 40 78             	mov    0x78(%eax),%eax
  801b57:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  801b59:	a1 04 40 80 00       	mov    0x804004,%eax
  801b5e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b64:	5b                   	pop    %ebx
  801b65:	5e                   	pop    %esi
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    
		if (from_env_store != NULL) {
  801b68:	85 f6                	test   %esi,%esi
  801b6a:	74 06                	je     801b72 <ipc_recv+0x61>
			*from_env_store = 0;
  801b6c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801b72:	85 db                	test   %ebx,%ebx
  801b74:	74 eb                	je     801b61 <ipc_recv+0x50>
			*perm_store = 0;
  801b76:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b7c:	eb e3                	jmp    801b61 <ipc_recv+0x50>

00801b7e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b7e:	f3 0f 1e fb          	endbr32 
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	57                   	push   %edi
  801b86:	56                   	push   %esi
  801b87:	53                   	push   %ebx
  801b88:	83 ec 0c             	sub    $0xc,%esp
  801b8b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b8e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  801b94:	85 db                	test   %ebx,%ebx
  801b96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b9b:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b9e:	ff 75 14             	pushl  0x14(%ebp)
  801ba1:	53                   	push   %ebx
  801ba2:	56                   	push   %esi
  801ba3:	57                   	push   %edi
  801ba4:	e8 c8 f0 ff ff       	call   800c71 <sys_ipc_try_send>
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	85 c0                	test   %eax,%eax
  801bae:	79 19                	jns    801bc9 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  801bb0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bb3:	74 e9                	je     801b9e <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  801bb5:	83 ec 04             	sub    $0x4,%esp
  801bb8:	68 a8 23 80 00       	push   $0x8023a8
  801bbd:	6a 48                	push   $0x48
  801bbf:	68 ca 23 80 00       	push   $0x8023ca
  801bc4:	e8 fe fe ff ff       	call   801ac7 <_panic>
		}
	}
}
  801bc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcc:	5b                   	pop    %ebx
  801bcd:	5e                   	pop    %esi
  801bce:	5f                   	pop    %edi
  801bcf:	5d                   	pop    %ebp
  801bd0:	c3                   	ret    

00801bd1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bd1:	f3 0f 1e fb          	endbr32 
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bdb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801be0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801be3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801be9:	8b 52 50             	mov    0x50(%edx),%edx
  801bec:	39 ca                	cmp    %ecx,%edx
  801bee:	74 11                	je     801c01 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801bf0:	83 c0 01             	add    $0x1,%eax
  801bf3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bf8:	75 e6                	jne    801be0 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801bfa:	b8 00 00 00 00       	mov    $0x0,%eax
  801bff:	eb 0b                	jmp    801c0c <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c01:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c04:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c09:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c0c:	5d                   	pop    %ebp
  801c0d:	c3                   	ret    

00801c0e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c0e:	f3 0f 1e fb          	endbr32 
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c18:	89 c2                	mov    %eax,%edx
  801c1a:	c1 ea 16             	shr    $0x16,%edx
  801c1d:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c24:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c29:	f6 c1 01             	test   $0x1,%cl
  801c2c:	74 1c                	je     801c4a <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c2e:	c1 e8 0c             	shr    $0xc,%eax
  801c31:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c38:	a8 01                	test   $0x1,%al
  801c3a:	74 0e                	je     801c4a <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c3c:	c1 e8 0c             	shr    $0xc,%eax
  801c3f:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c46:	ef 
  801c47:	0f b7 d2             	movzwl %dx,%edx
}
  801c4a:	89 d0                	mov    %edx,%eax
  801c4c:	5d                   	pop    %ebp
  801c4d:	c3                   	ret    
  801c4e:	66 90                	xchg   %ax,%ax

00801c50 <__udivdi3>:
  801c50:	f3 0f 1e fb          	endbr32 
  801c54:	55                   	push   %ebp
  801c55:	57                   	push   %edi
  801c56:	56                   	push   %esi
  801c57:	53                   	push   %ebx
  801c58:	83 ec 1c             	sub    $0x1c,%esp
  801c5b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c5f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c63:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c67:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c6b:	85 d2                	test   %edx,%edx
  801c6d:	75 19                	jne    801c88 <__udivdi3+0x38>
  801c6f:	39 f3                	cmp    %esi,%ebx
  801c71:	76 4d                	jbe    801cc0 <__udivdi3+0x70>
  801c73:	31 ff                	xor    %edi,%edi
  801c75:	89 e8                	mov    %ebp,%eax
  801c77:	89 f2                	mov    %esi,%edx
  801c79:	f7 f3                	div    %ebx
  801c7b:	89 fa                	mov    %edi,%edx
  801c7d:	83 c4 1c             	add    $0x1c,%esp
  801c80:	5b                   	pop    %ebx
  801c81:	5e                   	pop    %esi
  801c82:	5f                   	pop    %edi
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    
  801c85:	8d 76 00             	lea    0x0(%esi),%esi
  801c88:	39 f2                	cmp    %esi,%edx
  801c8a:	76 14                	jbe    801ca0 <__udivdi3+0x50>
  801c8c:	31 ff                	xor    %edi,%edi
  801c8e:	31 c0                	xor    %eax,%eax
  801c90:	89 fa                	mov    %edi,%edx
  801c92:	83 c4 1c             	add    $0x1c,%esp
  801c95:	5b                   	pop    %ebx
  801c96:	5e                   	pop    %esi
  801c97:	5f                   	pop    %edi
  801c98:	5d                   	pop    %ebp
  801c99:	c3                   	ret    
  801c9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca0:	0f bd fa             	bsr    %edx,%edi
  801ca3:	83 f7 1f             	xor    $0x1f,%edi
  801ca6:	75 48                	jne    801cf0 <__udivdi3+0xa0>
  801ca8:	39 f2                	cmp    %esi,%edx
  801caa:	72 06                	jb     801cb2 <__udivdi3+0x62>
  801cac:	31 c0                	xor    %eax,%eax
  801cae:	39 eb                	cmp    %ebp,%ebx
  801cb0:	77 de                	ja     801c90 <__udivdi3+0x40>
  801cb2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb7:	eb d7                	jmp    801c90 <__udivdi3+0x40>
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	89 d9                	mov    %ebx,%ecx
  801cc2:	85 db                	test   %ebx,%ebx
  801cc4:	75 0b                	jne    801cd1 <__udivdi3+0x81>
  801cc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ccb:	31 d2                	xor    %edx,%edx
  801ccd:	f7 f3                	div    %ebx
  801ccf:	89 c1                	mov    %eax,%ecx
  801cd1:	31 d2                	xor    %edx,%edx
  801cd3:	89 f0                	mov    %esi,%eax
  801cd5:	f7 f1                	div    %ecx
  801cd7:	89 c6                	mov    %eax,%esi
  801cd9:	89 e8                	mov    %ebp,%eax
  801cdb:	89 f7                	mov    %esi,%edi
  801cdd:	f7 f1                	div    %ecx
  801cdf:	89 fa                	mov    %edi,%edx
  801ce1:	83 c4 1c             	add    $0x1c,%esp
  801ce4:	5b                   	pop    %ebx
  801ce5:	5e                   	pop    %esi
  801ce6:	5f                   	pop    %edi
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	89 f9                	mov    %edi,%ecx
  801cf2:	b8 20 00 00 00       	mov    $0x20,%eax
  801cf7:	29 f8                	sub    %edi,%eax
  801cf9:	d3 e2                	shl    %cl,%edx
  801cfb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cff:	89 c1                	mov    %eax,%ecx
  801d01:	89 da                	mov    %ebx,%edx
  801d03:	d3 ea                	shr    %cl,%edx
  801d05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d09:	09 d1                	or     %edx,%ecx
  801d0b:	89 f2                	mov    %esi,%edx
  801d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d11:	89 f9                	mov    %edi,%ecx
  801d13:	d3 e3                	shl    %cl,%ebx
  801d15:	89 c1                	mov    %eax,%ecx
  801d17:	d3 ea                	shr    %cl,%edx
  801d19:	89 f9                	mov    %edi,%ecx
  801d1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d1f:	89 eb                	mov    %ebp,%ebx
  801d21:	d3 e6                	shl    %cl,%esi
  801d23:	89 c1                	mov    %eax,%ecx
  801d25:	d3 eb                	shr    %cl,%ebx
  801d27:	09 de                	or     %ebx,%esi
  801d29:	89 f0                	mov    %esi,%eax
  801d2b:	f7 74 24 08          	divl   0x8(%esp)
  801d2f:	89 d6                	mov    %edx,%esi
  801d31:	89 c3                	mov    %eax,%ebx
  801d33:	f7 64 24 0c          	mull   0xc(%esp)
  801d37:	39 d6                	cmp    %edx,%esi
  801d39:	72 15                	jb     801d50 <__udivdi3+0x100>
  801d3b:	89 f9                	mov    %edi,%ecx
  801d3d:	d3 e5                	shl    %cl,%ebp
  801d3f:	39 c5                	cmp    %eax,%ebp
  801d41:	73 04                	jae    801d47 <__udivdi3+0xf7>
  801d43:	39 d6                	cmp    %edx,%esi
  801d45:	74 09                	je     801d50 <__udivdi3+0x100>
  801d47:	89 d8                	mov    %ebx,%eax
  801d49:	31 ff                	xor    %edi,%edi
  801d4b:	e9 40 ff ff ff       	jmp    801c90 <__udivdi3+0x40>
  801d50:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d53:	31 ff                	xor    %edi,%edi
  801d55:	e9 36 ff ff ff       	jmp    801c90 <__udivdi3+0x40>
  801d5a:	66 90                	xchg   %ax,%ax
  801d5c:	66 90                	xchg   %ax,%ax
  801d5e:	66 90                	xchg   %ax,%ax

00801d60 <__umoddi3>:
  801d60:	f3 0f 1e fb          	endbr32 
  801d64:	55                   	push   %ebp
  801d65:	57                   	push   %edi
  801d66:	56                   	push   %esi
  801d67:	53                   	push   %ebx
  801d68:	83 ec 1c             	sub    $0x1c,%esp
  801d6b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d6f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d73:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d77:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	75 19                	jne    801d98 <__umoddi3+0x38>
  801d7f:	39 df                	cmp    %ebx,%edi
  801d81:	76 5d                	jbe    801de0 <__umoddi3+0x80>
  801d83:	89 f0                	mov    %esi,%eax
  801d85:	89 da                	mov    %ebx,%edx
  801d87:	f7 f7                	div    %edi
  801d89:	89 d0                	mov    %edx,%eax
  801d8b:	31 d2                	xor    %edx,%edx
  801d8d:	83 c4 1c             	add    $0x1c,%esp
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5f                   	pop    %edi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    
  801d95:	8d 76 00             	lea    0x0(%esi),%esi
  801d98:	89 f2                	mov    %esi,%edx
  801d9a:	39 d8                	cmp    %ebx,%eax
  801d9c:	76 12                	jbe    801db0 <__umoddi3+0x50>
  801d9e:	89 f0                	mov    %esi,%eax
  801da0:	89 da                	mov    %ebx,%edx
  801da2:	83 c4 1c             	add    $0x1c,%esp
  801da5:	5b                   	pop    %ebx
  801da6:	5e                   	pop    %esi
  801da7:	5f                   	pop    %edi
  801da8:	5d                   	pop    %ebp
  801da9:	c3                   	ret    
  801daa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801db0:	0f bd e8             	bsr    %eax,%ebp
  801db3:	83 f5 1f             	xor    $0x1f,%ebp
  801db6:	75 50                	jne    801e08 <__umoddi3+0xa8>
  801db8:	39 d8                	cmp    %ebx,%eax
  801dba:	0f 82 e0 00 00 00    	jb     801ea0 <__umoddi3+0x140>
  801dc0:	89 d9                	mov    %ebx,%ecx
  801dc2:	39 f7                	cmp    %esi,%edi
  801dc4:	0f 86 d6 00 00 00    	jbe    801ea0 <__umoddi3+0x140>
  801dca:	89 d0                	mov    %edx,%eax
  801dcc:	89 ca                	mov    %ecx,%edx
  801dce:	83 c4 1c             	add    $0x1c,%esp
  801dd1:	5b                   	pop    %ebx
  801dd2:	5e                   	pop    %esi
  801dd3:	5f                   	pop    %edi
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    
  801dd6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ddd:	8d 76 00             	lea    0x0(%esi),%esi
  801de0:	89 fd                	mov    %edi,%ebp
  801de2:	85 ff                	test   %edi,%edi
  801de4:	75 0b                	jne    801df1 <__umoddi3+0x91>
  801de6:	b8 01 00 00 00       	mov    $0x1,%eax
  801deb:	31 d2                	xor    %edx,%edx
  801ded:	f7 f7                	div    %edi
  801def:	89 c5                	mov    %eax,%ebp
  801df1:	89 d8                	mov    %ebx,%eax
  801df3:	31 d2                	xor    %edx,%edx
  801df5:	f7 f5                	div    %ebp
  801df7:	89 f0                	mov    %esi,%eax
  801df9:	f7 f5                	div    %ebp
  801dfb:	89 d0                	mov    %edx,%eax
  801dfd:	31 d2                	xor    %edx,%edx
  801dff:	eb 8c                	jmp    801d8d <__umoddi3+0x2d>
  801e01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e08:	89 e9                	mov    %ebp,%ecx
  801e0a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e0f:	29 ea                	sub    %ebp,%edx
  801e11:	d3 e0                	shl    %cl,%eax
  801e13:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e17:	89 d1                	mov    %edx,%ecx
  801e19:	89 f8                	mov    %edi,%eax
  801e1b:	d3 e8                	shr    %cl,%eax
  801e1d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e21:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e25:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e29:	09 c1                	or     %eax,%ecx
  801e2b:	89 d8                	mov    %ebx,%eax
  801e2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e31:	89 e9                	mov    %ebp,%ecx
  801e33:	d3 e7                	shl    %cl,%edi
  801e35:	89 d1                	mov    %edx,%ecx
  801e37:	d3 e8                	shr    %cl,%eax
  801e39:	89 e9                	mov    %ebp,%ecx
  801e3b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e3f:	d3 e3                	shl    %cl,%ebx
  801e41:	89 c7                	mov    %eax,%edi
  801e43:	89 d1                	mov    %edx,%ecx
  801e45:	89 f0                	mov    %esi,%eax
  801e47:	d3 e8                	shr    %cl,%eax
  801e49:	89 e9                	mov    %ebp,%ecx
  801e4b:	89 fa                	mov    %edi,%edx
  801e4d:	d3 e6                	shl    %cl,%esi
  801e4f:	09 d8                	or     %ebx,%eax
  801e51:	f7 74 24 08          	divl   0x8(%esp)
  801e55:	89 d1                	mov    %edx,%ecx
  801e57:	89 f3                	mov    %esi,%ebx
  801e59:	f7 64 24 0c          	mull   0xc(%esp)
  801e5d:	89 c6                	mov    %eax,%esi
  801e5f:	89 d7                	mov    %edx,%edi
  801e61:	39 d1                	cmp    %edx,%ecx
  801e63:	72 06                	jb     801e6b <__umoddi3+0x10b>
  801e65:	75 10                	jne    801e77 <__umoddi3+0x117>
  801e67:	39 c3                	cmp    %eax,%ebx
  801e69:	73 0c                	jae    801e77 <__umoddi3+0x117>
  801e6b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801e6f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801e73:	89 d7                	mov    %edx,%edi
  801e75:	89 c6                	mov    %eax,%esi
  801e77:	89 ca                	mov    %ecx,%edx
  801e79:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e7e:	29 f3                	sub    %esi,%ebx
  801e80:	19 fa                	sbb    %edi,%edx
  801e82:	89 d0                	mov    %edx,%eax
  801e84:	d3 e0                	shl    %cl,%eax
  801e86:	89 e9                	mov    %ebp,%ecx
  801e88:	d3 eb                	shr    %cl,%ebx
  801e8a:	d3 ea                	shr    %cl,%edx
  801e8c:	09 d8                	or     %ebx,%eax
  801e8e:	83 c4 1c             	add    $0x1c,%esp
  801e91:	5b                   	pop    %ebx
  801e92:	5e                   	pop    %esi
  801e93:	5f                   	pop    %edi
  801e94:	5d                   	pop    %ebp
  801e95:	c3                   	ret    
  801e96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e9d:	8d 76 00             	lea    0x0(%esi),%esi
  801ea0:	29 fe                	sub    %edi,%esi
  801ea2:	19 c3                	sbb    %eax,%ebx
  801ea4:	89 f2                	mov    %esi,%edx
  801ea6:	89 d9                	mov    %ebx,%ecx
  801ea8:	e9 1d ff ff ff       	jmp    801dca <__umoddi3+0x6a>
