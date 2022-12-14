
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2e 00 00 00       	call   80005f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  80003d:	68 00 1e 80 00       	push   $0x801e00
  800042:	e8 21 01 00 00       	call   800168 <cprintf>
	cprintf("i am environment %08x\n", sys_getenvid());
  800047:	e8 bb 0a 00 00       	call   800b07 <sys_getenvid>
  80004c:	83 c4 08             	add    $0x8,%esp
  80004f:	50                   	push   %eax
  800050:	68 0e 1e 80 00       	push   $0x801e0e
  800055:	e8 0e 01 00 00       	call   800168 <cprintf>
}
  80005a:	83 c4 10             	add    $0x10,%esp
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005f:	f3 0f 1e fb          	endbr32 
  800063:	55                   	push   %ebp
  800064:	89 e5                	mov    %esp,%ebp
  800066:	56                   	push   %esi
  800067:	53                   	push   %ebx
  800068:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  80006e:	e8 94 0a 00 00       	call   800b07 <sys_getenvid>
	if (id >= 0)
  800073:	85 c0                	test   %eax,%eax
  800075:	78 12                	js     800089 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800084:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 db                	test   %ebx,%ebx
  80008b:	7e 07                	jle    800094 <libmain+0x35>
		binaryname = argv[0];
  80008d:	8b 06                	mov    (%esi),%eax
  80008f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800094:	83 ec 08             	sub    $0x8,%esp
  800097:	56                   	push   %esi
  800098:	53                   	push   %ebx
  800099:	e8 95 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009e:	e8 0a 00 00 00       	call   8000ad <exit>
}
  8000a3:	83 c4 10             	add    $0x10,%esp
  8000a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a9:	5b                   	pop    %ebx
  8000aa:	5e                   	pop    %esi
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    

008000ad <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ad:	f3 0f 1e fb          	endbr32 
  8000b1:	55                   	push   %ebp
  8000b2:	89 e5                	mov    %esp,%ebp
  8000b4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b7:	e8 ce 0d 00 00       	call   800e8a <close_all>
	sys_env_destroy(0);
  8000bc:	83 ec 0c             	sub    $0xc,%esp
  8000bf:	6a 00                	push   $0x0
  8000c1:	e8 1b 0a 00 00       	call   800ae1 <sys_env_destroy>
}
  8000c6:	83 c4 10             	add    $0x10,%esp
  8000c9:	c9                   	leave  
  8000ca:	c3                   	ret    

008000cb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cb:	f3 0f 1e fb          	endbr32 
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	53                   	push   %ebx
  8000d3:	83 ec 04             	sub    $0x4,%esp
  8000d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d9:	8b 13                	mov    (%ebx),%edx
  8000db:	8d 42 01             	lea    0x1(%edx),%eax
  8000de:	89 03                	mov    %eax,(%ebx)
  8000e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ec:	74 09                	je     8000f7 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000ee:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f5:	c9                   	leave  
  8000f6:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 ff 00 00 00       	push   $0xff
  8000ff:	8d 43 08             	lea    0x8(%ebx),%eax
  800102:	50                   	push   %eax
  800103:	e8 87 09 00 00       	call   800a8f <sys_cputs>
		b->idx = 0;
  800108:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	eb db                	jmp    8000ee <putch+0x23>

00800113 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800113:	f3 0f 1e fb          	endbr32 
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800120:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800127:	00 00 00 
	b.cnt = 0;
  80012a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800131:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800134:	ff 75 0c             	pushl  0xc(%ebp)
  800137:	ff 75 08             	pushl  0x8(%ebp)
  80013a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800140:	50                   	push   %eax
  800141:	68 cb 00 80 00       	push   $0x8000cb
  800146:	e8 80 01 00 00       	call   8002cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014b:	83 c4 08             	add    $0x8,%esp
  80014e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800154:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015a:	50                   	push   %eax
  80015b:	e8 2f 09 00 00       	call   800a8f <sys_cputs>

	return b.cnt;
}
  800160:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800166:	c9                   	leave  
  800167:	c3                   	ret    

00800168 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800168:	f3 0f 1e fb          	endbr32 
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800172:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800175:	50                   	push   %eax
  800176:	ff 75 08             	pushl  0x8(%ebp)
  800179:	e8 95 ff ff ff       	call   800113 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017e:	c9                   	leave  
  80017f:	c3                   	ret    

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 1c             	sub    $0x1c,%esp
  800189:	89 c7                	mov    %eax,%edi
  80018b:	89 d6                	mov    %edx,%esi
  80018d:	8b 45 08             	mov    0x8(%ebp),%eax
  800190:	8b 55 0c             	mov    0xc(%ebp),%edx
  800193:	89 d1                	mov    %edx,%ecx
  800195:	89 c2                	mov    %eax,%edx
  800197:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80019d:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001ad:	39 c2                	cmp    %eax,%edx
  8001af:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001b2:	72 3e                	jb     8001f2 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 18             	pushl  0x18(%ebp)
  8001ba:	83 eb 01             	sub    $0x1,%ebx
  8001bd:	53                   	push   %ebx
  8001be:	50                   	push   %eax
  8001bf:	83 ec 08             	sub    $0x8,%esp
  8001c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ce:	e8 bd 19 00 00       	call   801b90 <__udivdi3>
  8001d3:	83 c4 18             	add    $0x18,%esp
  8001d6:	52                   	push   %edx
  8001d7:	50                   	push   %eax
  8001d8:	89 f2                	mov    %esi,%edx
  8001da:	89 f8                	mov    %edi,%eax
  8001dc:	e8 9f ff ff ff       	call   800180 <printnum>
  8001e1:	83 c4 20             	add    $0x20,%esp
  8001e4:	eb 13                	jmp    8001f9 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e6:	83 ec 08             	sub    $0x8,%esp
  8001e9:	56                   	push   %esi
  8001ea:	ff 75 18             	pushl  0x18(%ebp)
  8001ed:	ff d7                	call   *%edi
  8001ef:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001f2:	83 eb 01             	sub    $0x1,%ebx
  8001f5:	85 db                	test   %ebx,%ebx
  8001f7:	7f ed                	jg     8001e6 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	56                   	push   %esi
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	ff 75 e4             	pushl  -0x1c(%ebp)
  800203:	ff 75 e0             	pushl  -0x20(%ebp)
  800206:	ff 75 dc             	pushl  -0x24(%ebp)
  800209:	ff 75 d8             	pushl  -0x28(%ebp)
  80020c:	e8 8f 1a 00 00       	call   801ca0 <__umoddi3>
  800211:	83 c4 14             	add    $0x14,%esp
  800214:	0f be 80 2f 1e 80 00 	movsbl 0x801e2f(%eax),%eax
  80021b:	50                   	push   %eax
  80021c:	ff d7                	call   *%edi
}
  80021e:	83 c4 10             	add    $0x10,%esp
  800221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5f                   	pop    %edi
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    

00800229 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800229:	83 fa 01             	cmp    $0x1,%edx
  80022c:	7f 13                	jg     800241 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80022e:	85 d2                	test   %edx,%edx
  800230:	74 1c                	je     80024e <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800232:	8b 10                	mov    (%eax),%edx
  800234:	8d 4a 04             	lea    0x4(%edx),%ecx
  800237:	89 08                	mov    %ecx,(%eax)
  800239:	8b 02                	mov    (%edx),%eax
  80023b:	ba 00 00 00 00       	mov    $0x0,%edx
  800240:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800241:	8b 10                	mov    (%eax),%edx
  800243:	8d 4a 08             	lea    0x8(%edx),%ecx
  800246:	89 08                	mov    %ecx,(%eax)
  800248:	8b 02                	mov    (%edx),%eax
  80024a:	8b 52 04             	mov    0x4(%edx),%edx
  80024d:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80024e:	8b 10                	mov    (%eax),%edx
  800250:	8d 4a 04             	lea    0x4(%edx),%ecx
  800253:	89 08                	mov    %ecx,(%eax)
  800255:	8b 02                	mov    (%edx),%eax
  800257:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80025c:	c3                   	ret    

0080025d <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80025d:	83 fa 01             	cmp    $0x1,%edx
  800260:	7f 0f                	jg     800271 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800262:	85 d2                	test   %edx,%edx
  800264:	74 18                	je     80027e <getint+0x21>
		return va_arg(*ap, long);
  800266:	8b 10                	mov    (%eax),%edx
  800268:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026b:	89 08                	mov    %ecx,(%eax)
  80026d:	8b 02                	mov    (%edx),%eax
  80026f:	99                   	cltd   
  800270:	c3                   	ret    
		return va_arg(*ap, long long);
  800271:	8b 10                	mov    (%eax),%edx
  800273:	8d 4a 08             	lea    0x8(%edx),%ecx
  800276:	89 08                	mov    %ecx,(%eax)
  800278:	8b 02                	mov    (%edx),%eax
  80027a:	8b 52 04             	mov    0x4(%edx),%edx
  80027d:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	8d 4a 04             	lea    0x4(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 02                	mov    (%edx),%eax
  800287:	99                   	cltd   
}
  800288:	c3                   	ret    

00800289 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800289:	f3 0f 1e fb          	endbr32 
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800293:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800297:	8b 10                	mov    (%eax),%edx
  800299:	3b 50 04             	cmp    0x4(%eax),%edx
  80029c:	73 0a                	jae    8002a8 <sprintputch+0x1f>
		*b->buf++ = ch;
  80029e:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a1:	89 08                	mov    %ecx,(%eax)
  8002a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a6:	88 02                	mov    %al,(%edx)
}
  8002a8:	5d                   	pop    %ebp
  8002a9:	c3                   	ret    

008002aa <printfmt>:
{
  8002aa:	f3 0f 1e fb          	endbr32 
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b7:	50                   	push   %eax
  8002b8:	ff 75 10             	pushl  0x10(%ebp)
  8002bb:	ff 75 0c             	pushl  0xc(%ebp)
  8002be:	ff 75 08             	pushl  0x8(%ebp)
  8002c1:	e8 05 00 00 00       	call   8002cb <vprintfmt>
}
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	c9                   	leave  
  8002ca:	c3                   	ret    

008002cb <vprintfmt>:
{
  8002cb:	f3 0f 1e fb          	endbr32 
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	57                   	push   %edi
  8002d3:	56                   	push   %esi
  8002d4:	53                   	push   %ebx
  8002d5:	83 ec 2c             	sub    $0x2c,%esp
  8002d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002db:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e1:	e9 86 02 00 00       	jmp    80056c <vprintfmt+0x2a1>
		padc = ' ';
  8002e6:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002ea:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002f1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002ff:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800304:	8d 47 01             	lea    0x1(%edi),%eax
  800307:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030a:	0f b6 17             	movzbl (%edi),%edx
  80030d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800310:	3c 55                	cmp    $0x55,%al
  800312:	0f 87 df 02 00 00    	ja     8005f7 <vprintfmt+0x32c>
  800318:	0f b6 c0             	movzbl %al,%eax
  80031b:	3e ff 24 85 80 1f 80 	notrack jmp *0x801f80(,%eax,4)
  800322:	00 
  800323:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800326:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80032a:	eb d8                	jmp    800304 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80032c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80032f:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800333:	eb cf                	jmp    800304 <vprintfmt+0x39>
  800335:	0f b6 d2             	movzbl %dl,%edx
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80033b:	b8 00 00 00 00       	mov    $0x0,%eax
  800340:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800343:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800346:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80034a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80034d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800350:	83 f9 09             	cmp    $0x9,%ecx
  800353:	77 52                	ja     8003a7 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800355:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800358:	eb e9                	jmp    800343 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80035a:	8b 45 14             	mov    0x14(%ebp),%eax
  80035d:	8d 50 04             	lea    0x4(%eax),%edx
  800360:	89 55 14             	mov    %edx,0x14(%ebp)
  800363:	8b 00                	mov    (%eax),%eax
  800365:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80036b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036f:	79 93                	jns    800304 <vprintfmt+0x39>
				width = precision, precision = -1;
  800371:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800374:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800377:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80037e:	eb 84                	jmp    800304 <vprintfmt+0x39>
  800380:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800383:	85 c0                	test   %eax,%eax
  800385:	ba 00 00 00 00       	mov    $0x0,%edx
  80038a:	0f 49 d0             	cmovns %eax,%edx
  80038d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800393:	e9 6c ff ff ff       	jmp    800304 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80039b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003a2:	e9 5d ff ff ff       	jmp    800304 <vprintfmt+0x39>
  8003a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003aa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ad:	eb bc                	jmp    80036b <vprintfmt+0xa0>
			lflag++;
  8003af:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b5:	e9 4a ff ff ff       	jmp    800304 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8d 50 04             	lea    0x4(%eax),%edx
  8003c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	56                   	push   %esi
  8003c7:	ff 30                	pushl  (%eax)
  8003c9:	ff d3                	call   *%ebx
			break;
  8003cb:	83 c4 10             	add    $0x10,%esp
  8003ce:	e9 96 01 00 00       	jmp    800569 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	8d 50 04             	lea    0x4(%eax),%edx
  8003d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003dc:	8b 00                	mov    (%eax),%eax
  8003de:	99                   	cltd   
  8003df:	31 d0                	xor    %edx,%eax
  8003e1:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e3:	83 f8 0f             	cmp    $0xf,%eax
  8003e6:	7f 20                	jg     800408 <vprintfmt+0x13d>
  8003e8:	8b 14 85 e0 20 80 00 	mov    0x8020e0(,%eax,4),%edx
  8003ef:	85 d2                	test   %edx,%edx
  8003f1:	74 15                	je     800408 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8003f3:	52                   	push   %edx
  8003f4:	68 11 22 80 00       	push   $0x802211
  8003f9:	56                   	push   %esi
  8003fa:	53                   	push   %ebx
  8003fb:	e8 aa fe ff ff       	call   8002aa <printfmt>
  800400:	83 c4 10             	add    $0x10,%esp
  800403:	e9 61 01 00 00       	jmp    800569 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800408:	50                   	push   %eax
  800409:	68 47 1e 80 00       	push   $0x801e47
  80040e:	56                   	push   %esi
  80040f:	53                   	push   %ebx
  800410:	e8 95 fe ff ff       	call   8002aa <printfmt>
  800415:	83 c4 10             	add    $0x10,%esp
  800418:	e9 4c 01 00 00       	jmp    800569 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  80041d:	8b 45 14             	mov    0x14(%ebp),%eax
  800420:	8d 50 04             	lea    0x4(%eax),%edx
  800423:	89 55 14             	mov    %edx,0x14(%ebp)
  800426:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800428:	85 c9                	test   %ecx,%ecx
  80042a:	b8 40 1e 80 00       	mov    $0x801e40,%eax
  80042f:	0f 45 c1             	cmovne %ecx,%eax
  800432:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800435:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800439:	7e 06                	jle    800441 <vprintfmt+0x176>
  80043b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80043f:	75 0d                	jne    80044e <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800441:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800444:	89 c7                	mov    %eax,%edi
  800446:	03 45 e0             	add    -0x20(%ebp),%eax
  800449:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044c:	eb 57                	jmp    8004a5 <vprintfmt+0x1da>
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	ff 75 d8             	pushl  -0x28(%ebp)
  800454:	ff 75 cc             	pushl  -0x34(%ebp)
  800457:	e8 4f 02 00 00       	call   8006ab <strnlen>
  80045c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80045f:	29 c2                	sub    %eax,%edx
  800461:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800464:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800467:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80046b:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80046e:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800470:	85 db                	test   %ebx,%ebx
  800472:	7e 10                	jle    800484 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800474:	83 ec 08             	sub    $0x8,%esp
  800477:	56                   	push   %esi
  800478:	57                   	push   %edi
  800479:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80047c:	83 eb 01             	sub    $0x1,%ebx
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	eb ec                	jmp    800470 <vprintfmt+0x1a5>
  800484:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800487:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80048a:	85 d2                	test   %edx,%edx
  80048c:	b8 00 00 00 00       	mov    $0x0,%eax
  800491:	0f 49 c2             	cmovns %edx,%eax
  800494:	29 c2                	sub    %eax,%edx
  800496:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800499:	eb a6                	jmp    800441 <vprintfmt+0x176>
					putch(ch, putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	56                   	push   %esi
  80049f:	52                   	push   %edx
  8004a0:	ff d3                	call   *%ebx
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a8:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004aa:	83 c7 01             	add    $0x1,%edi
  8004ad:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b1:	0f be d0             	movsbl %al,%edx
  8004b4:	85 d2                	test   %edx,%edx
  8004b6:	74 42                	je     8004fa <vprintfmt+0x22f>
  8004b8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004bc:	78 06                	js     8004c4 <vprintfmt+0x1f9>
  8004be:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004c2:	78 1e                	js     8004e2 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004c8:	74 d1                	je     80049b <vprintfmt+0x1d0>
  8004ca:	0f be c0             	movsbl %al,%eax
  8004cd:	83 e8 20             	sub    $0x20,%eax
  8004d0:	83 f8 5e             	cmp    $0x5e,%eax
  8004d3:	76 c6                	jbe    80049b <vprintfmt+0x1d0>
					putch('?', putdat);
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	56                   	push   %esi
  8004d9:	6a 3f                	push   $0x3f
  8004db:	ff d3                	call   *%ebx
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	eb c3                	jmp    8004a5 <vprintfmt+0x1da>
  8004e2:	89 cf                	mov    %ecx,%edi
  8004e4:	eb 0e                	jmp    8004f4 <vprintfmt+0x229>
				putch(' ', putdat);
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	56                   	push   %esi
  8004ea:	6a 20                	push   $0x20
  8004ec:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8004ee:	83 ef 01             	sub    $0x1,%edi
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	85 ff                	test   %edi,%edi
  8004f6:	7f ee                	jg     8004e6 <vprintfmt+0x21b>
  8004f8:	eb 6f                	jmp    800569 <vprintfmt+0x29e>
  8004fa:	89 cf                	mov    %ecx,%edi
  8004fc:	eb f6                	jmp    8004f4 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8004fe:	89 ca                	mov    %ecx,%edx
  800500:	8d 45 14             	lea    0x14(%ebp),%eax
  800503:	e8 55 fd ff ff       	call   80025d <getint>
  800508:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80050e:	85 d2                	test   %edx,%edx
  800510:	78 0b                	js     80051d <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800512:	89 d1                	mov    %edx,%ecx
  800514:	89 c2                	mov    %eax,%edx
			base = 10;
  800516:	b8 0a 00 00 00       	mov    $0xa,%eax
  80051b:	eb 32                	jmp    80054f <vprintfmt+0x284>
				putch('-', putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	56                   	push   %esi
  800521:	6a 2d                	push   $0x2d
  800523:	ff d3                	call   *%ebx
				num = -(long long) num;
  800525:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800528:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80052b:	f7 da                	neg    %edx
  80052d:	83 d1 00             	adc    $0x0,%ecx
  800530:	f7 d9                	neg    %ecx
  800532:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800535:	b8 0a 00 00 00       	mov    $0xa,%eax
  80053a:	eb 13                	jmp    80054f <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80053c:	89 ca                	mov    %ecx,%edx
  80053e:	8d 45 14             	lea    0x14(%ebp),%eax
  800541:	e8 e3 fc ff ff       	call   800229 <getuint>
  800546:	89 d1                	mov    %edx,%ecx
  800548:	89 c2                	mov    %eax,%edx
			base = 10;
  80054a:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  80054f:	83 ec 0c             	sub    $0xc,%esp
  800552:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800556:	57                   	push   %edi
  800557:	ff 75 e0             	pushl  -0x20(%ebp)
  80055a:	50                   	push   %eax
  80055b:	51                   	push   %ecx
  80055c:	52                   	push   %edx
  80055d:	89 f2                	mov    %esi,%edx
  80055f:	89 d8                	mov    %ebx,%eax
  800561:	e8 1a fc ff ff       	call   800180 <printnum>
			break;
  800566:	83 c4 20             	add    $0x20,%esp
{
  800569:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80056c:	83 c7 01             	add    $0x1,%edi
  80056f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800573:	83 f8 25             	cmp    $0x25,%eax
  800576:	0f 84 6a fd ff ff    	je     8002e6 <vprintfmt+0x1b>
			if (ch == '\0')
  80057c:	85 c0                	test   %eax,%eax
  80057e:	0f 84 93 00 00 00    	je     800617 <vprintfmt+0x34c>
			putch(ch, putdat);
  800584:	83 ec 08             	sub    $0x8,%esp
  800587:	56                   	push   %esi
  800588:	50                   	push   %eax
  800589:	ff d3                	call   *%ebx
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	eb dc                	jmp    80056c <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800590:	89 ca                	mov    %ecx,%edx
  800592:	8d 45 14             	lea    0x14(%ebp),%eax
  800595:	e8 8f fc ff ff       	call   800229 <getuint>
  80059a:	89 d1                	mov    %edx,%ecx
  80059c:	89 c2                	mov    %eax,%edx
			base = 8;
  80059e:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005a3:	eb aa                	jmp    80054f <vprintfmt+0x284>
			putch('0', putdat);
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	56                   	push   %esi
  8005a9:	6a 30                	push   $0x30
  8005ab:	ff d3                	call   *%ebx
			putch('x', putdat);
  8005ad:	83 c4 08             	add    $0x8,%esp
  8005b0:	56                   	push   %esi
  8005b1:	6a 78                	push   $0x78
  8005b3:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 50 04             	lea    0x4(%eax),%edx
  8005bb:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8005be:	8b 10                	mov    (%eax),%edx
  8005c0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005c5:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8005c8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005cd:	eb 80                	jmp    80054f <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8005cf:	89 ca                	mov    %ecx,%edx
  8005d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d4:	e8 50 fc ff ff       	call   800229 <getuint>
  8005d9:	89 d1                	mov    %edx,%ecx
  8005db:	89 c2                	mov    %eax,%edx
			base = 16;
  8005dd:	b8 10 00 00 00       	mov    $0x10,%eax
  8005e2:	e9 68 ff ff ff       	jmp    80054f <vprintfmt+0x284>
			putch(ch, putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	56                   	push   %esi
  8005eb:	6a 25                	push   $0x25
  8005ed:	ff d3                	call   *%ebx
			break;
  8005ef:	83 c4 10             	add    $0x10,%esp
  8005f2:	e9 72 ff ff ff       	jmp    800569 <vprintfmt+0x29e>
			putch('%', putdat);
  8005f7:	83 ec 08             	sub    $0x8,%esp
  8005fa:	56                   	push   %esi
  8005fb:	6a 25                	push   $0x25
  8005fd:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8005ff:	83 c4 10             	add    $0x10,%esp
  800602:	89 f8                	mov    %edi,%eax
  800604:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800608:	74 05                	je     80060f <vprintfmt+0x344>
  80060a:	83 e8 01             	sub    $0x1,%eax
  80060d:	eb f5                	jmp    800604 <vprintfmt+0x339>
  80060f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800612:	e9 52 ff ff ff       	jmp    800569 <vprintfmt+0x29e>
}
  800617:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061a:	5b                   	pop    %ebx
  80061b:	5e                   	pop    %esi
  80061c:	5f                   	pop    %edi
  80061d:	5d                   	pop    %ebp
  80061e:	c3                   	ret    

0080061f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80061f:	f3 0f 1e fb          	endbr32 
  800623:	55                   	push   %ebp
  800624:	89 e5                	mov    %esp,%ebp
  800626:	83 ec 18             	sub    $0x18,%esp
  800629:	8b 45 08             	mov    0x8(%ebp),%eax
  80062c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80062f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800632:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800636:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800639:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800640:	85 c0                	test   %eax,%eax
  800642:	74 26                	je     80066a <vsnprintf+0x4b>
  800644:	85 d2                	test   %edx,%edx
  800646:	7e 22                	jle    80066a <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800648:	ff 75 14             	pushl  0x14(%ebp)
  80064b:	ff 75 10             	pushl  0x10(%ebp)
  80064e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800651:	50                   	push   %eax
  800652:	68 89 02 80 00       	push   $0x800289
  800657:	e8 6f fc ff ff       	call   8002cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80065c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80065f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800662:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800665:	83 c4 10             	add    $0x10,%esp
}
  800668:	c9                   	leave  
  800669:	c3                   	ret    
		return -E_INVAL;
  80066a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80066f:	eb f7                	jmp    800668 <vsnprintf+0x49>

00800671 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800671:	f3 0f 1e fb          	endbr32 
  800675:	55                   	push   %ebp
  800676:	89 e5                	mov    %esp,%ebp
  800678:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80067e:	50                   	push   %eax
  80067f:	ff 75 10             	pushl  0x10(%ebp)
  800682:	ff 75 0c             	pushl  0xc(%ebp)
  800685:	ff 75 08             	pushl  0x8(%ebp)
  800688:	e8 92 ff ff ff       	call   80061f <vsnprintf>
	va_end(ap);

	return rc;
}
  80068d:	c9                   	leave  
  80068e:	c3                   	ret    

0080068f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80068f:	f3 0f 1e fb          	endbr32 
  800693:	55                   	push   %ebp
  800694:	89 e5                	mov    %esp,%ebp
  800696:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800699:	b8 00 00 00 00       	mov    $0x0,%eax
  80069e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006a2:	74 05                	je     8006a9 <strlen+0x1a>
		n++;
  8006a4:	83 c0 01             	add    $0x1,%eax
  8006a7:	eb f5                	jmp    80069e <strlen+0xf>
	return n;
}
  8006a9:	5d                   	pop    %ebp
  8006aa:	c3                   	ret    

008006ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ab:	f3 0f 1e fb          	endbr32 
  8006af:	55                   	push   %ebp
  8006b0:	89 e5                	mov    %esp,%ebp
  8006b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bd:	39 d0                	cmp    %edx,%eax
  8006bf:	74 0d                	je     8006ce <strnlen+0x23>
  8006c1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006c5:	74 05                	je     8006cc <strnlen+0x21>
		n++;
  8006c7:	83 c0 01             	add    $0x1,%eax
  8006ca:	eb f1                	jmp    8006bd <strnlen+0x12>
  8006cc:	89 c2                	mov    %eax,%edx
	return n;
}
  8006ce:	89 d0                	mov    %edx,%eax
  8006d0:	5d                   	pop    %ebp
  8006d1:	c3                   	ret    

008006d2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d2:	f3 0f 1e fb          	endbr32 
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	53                   	push   %ebx
  8006da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8006e9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8006ec:	83 c0 01             	add    $0x1,%eax
  8006ef:	84 d2                	test   %dl,%dl
  8006f1:	75 f2                	jne    8006e5 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8006f3:	89 c8                	mov    %ecx,%eax
  8006f5:	5b                   	pop    %ebx
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f8:	f3 0f 1e fb          	endbr32 
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	53                   	push   %ebx
  800700:	83 ec 10             	sub    $0x10,%esp
  800703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800706:	53                   	push   %ebx
  800707:	e8 83 ff ff ff       	call   80068f <strlen>
  80070c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80070f:	ff 75 0c             	pushl  0xc(%ebp)
  800712:	01 d8                	add    %ebx,%eax
  800714:	50                   	push   %eax
  800715:	e8 b8 ff ff ff       	call   8006d2 <strcpy>
	return dst;
}
  80071a:	89 d8                	mov    %ebx,%eax
  80071c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80071f:	c9                   	leave  
  800720:	c3                   	ret    

00800721 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800721:	f3 0f 1e fb          	endbr32 
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	56                   	push   %esi
  800729:	53                   	push   %ebx
  80072a:	8b 75 08             	mov    0x8(%ebp),%esi
  80072d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800730:	89 f3                	mov    %esi,%ebx
  800732:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800735:	89 f0                	mov    %esi,%eax
  800737:	39 d8                	cmp    %ebx,%eax
  800739:	74 11                	je     80074c <strncpy+0x2b>
		*dst++ = *src;
  80073b:	83 c0 01             	add    $0x1,%eax
  80073e:	0f b6 0a             	movzbl (%edx),%ecx
  800741:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800744:	80 f9 01             	cmp    $0x1,%cl
  800747:	83 da ff             	sbb    $0xffffffff,%edx
  80074a:	eb eb                	jmp    800737 <strncpy+0x16>
	}
	return ret;
}
  80074c:	89 f0                	mov    %esi,%eax
  80074e:	5b                   	pop    %ebx
  80074f:	5e                   	pop    %esi
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800752:	f3 0f 1e fb          	endbr32 
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	56                   	push   %esi
  80075a:	53                   	push   %ebx
  80075b:	8b 75 08             	mov    0x8(%ebp),%esi
  80075e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800761:	8b 55 10             	mov    0x10(%ebp),%edx
  800764:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800766:	85 d2                	test   %edx,%edx
  800768:	74 21                	je     80078b <strlcpy+0x39>
  80076a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80076e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800770:	39 c2                	cmp    %eax,%edx
  800772:	74 14                	je     800788 <strlcpy+0x36>
  800774:	0f b6 19             	movzbl (%ecx),%ebx
  800777:	84 db                	test   %bl,%bl
  800779:	74 0b                	je     800786 <strlcpy+0x34>
			*dst++ = *src++;
  80077b:	83 c1 01             	add    $0x1,%ecx
  80077e:	83 c2 01             	add    $0x1,%edx
  800781:	88 5a ff             	mov    %bl,-0x1(%edx)
  800784:	eb ea                	jmp    800770 <strlcpy+0x1e>
  800786:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800788:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80078b:	29 f0                	sub    %esi,%eax
}
  80078d:	5b                   	pop    %ebx
  80078e:	5e                   	pop    %esi
  80078f:	5d                   	pop    %ebp
  800790:	c3                   	ret    

00800791 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800791:	f3 0f 1e fb          	endbr32 
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80079e:	0f b6 01             	movzbl (%ecx),%eax
  8007a1:	84 c0                	test   %al,%al
  8007a3:	74 0c                	je     8007b1 <strcmp+0x20>
  8007a5:	3a 02                	cmp    (%edx),%al
  8007a7:	75 08                	jne    8007b1 <strcmp+0x20>
		p++, q++;
  8007a9:	83 c1 01             	add    $0x1,%ecx
  8007ac:	83 c2 01             	add    $0x1,%edx
  8007af:	eb ed                	jmp    80079e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b1:	0f b6 c0             	movzbl %al,%eax
  8007b4:	0f b6 12             	movzbl (%edx),%edx
  8007b7:	29 d0                	sub    %edx,%eax
}
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007bb:	f3 0f 1e fb          	endbr32 
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c9:	89 c3                	mov    %eax,%ebx
  8007cb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007ce:	eb 06                	jmp    8007d6 <strncmp+0x1b>
		n--, p++, q++;
  8007d0:	83 c0 01             	add    $0x1,%eax
  8007d3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8007d6:	39 d8                	cmp    %ebx,%eax
  8007d8:	74 16                	je     8007f0 <strncmp+0x35>
  8007da:	0f b6 08             	movzbl (%eax),%ecx
  8007dd:	84 c9                	test   %cl,%cl
  8007df:	74 04                	je     8007e5 <strncmp+0x2a>
  8007e1:	3a 0a                	cmp    (%edx),%cl
  8007e3:	74 eb                	je     8007d0 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e5:	0f b6 00             	movzbl (%eax),%eax
  8007e8:	0f b6 12             	movzbl (%edx),%edx
  8007eb:	29 d0                	sub    %edx,%eax
}
  8007ed:	5b                   	pop    %ebx
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    
		return 0;
  8007f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f5:	eb f6                	jmp    8007ed <strncmp+0x32>

008007f7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007f7:	f3 0f 1e fb          	endbr32 
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800805:	0f b6 10             	movzbl (%eax),%edx
  800808:	84 d2                	test   %dl,%dl
  80080a:	74 09                	je     800815 <strchr+0x1e>
		if (*s == c)
  80080c:	38 ca                	cmp    %cl,%dl
  80080e:	74 0a                	je     80081a <strchr+0x23>
	for (; *s; s++)
  800810:	83 c0 01             	add    $0x1,%eax
  800813:	eb f0                	jmp    800805 <strchr+0xe>
			return (char *) s;
	return 0;
  800815:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    

0080081c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80081c:	f3 0f 1e fb          	endbr32 
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80082d:	38 ca                	cmp    %cl,%dl
  80082f:	74 09                	je     80083a <strfind+0x1e>
  800831:	84 d2                	test   %dl,%dl
  800833:	74 05                	je     80083a <strfind+0x1e>
	for (; *s; s++)
  800835:	83 c0 01             	add    $0x1,%eax
  800838:	eb f0                	jmp    80082a <strfind+0xe>
			break;
	return (char *) s;
}
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083c:	f3 0f 1e fb          	endbr32 
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	57                   	push   %edi
  800844:	56                   	push   %esi
  800845:	53                   	push   %ebx
  800846:	8b 55 08             	mov    0x8(%ebp),%edx
  800849:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80084c:	85 c9                	test   %ecx,%ecx
  80084e:	74 33                	je     800883 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800850:	89 d0                	mov    %edx,%eax
  800852:	09 c8                	or     %ecx,%eax
  800854:	a8 03                	test   $0x3,%al
  800856:	75 23                	jne    80087b <memset+0x3f>
		c &= 0xFF;
  800858:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085c:	89 d8                	mov    %ebx,%eax
  80085e:	c1 e0 08             	shl    $0x8,%eax
  800861:	89 df                	mov    %ebx,%edi
  800863:	c1 e7 18             	shl    $0x18,%edi
  800866:	89 de                	mov    %ebx,%esi
  800868:	c1 e6 10             	shl    $0x10,%esi
  80086b:	09 f7                	or     %esi,%edi
  80086d:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  80086f:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800872:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800874:	89 d7                	mov    %edx,%edi
  800876:	fc                   	cld    
  800877:	f3 ab                	rep stos %eax,%es:(%edi)
  800879:	eb 08                	jmp    800883 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087b:	89 d7                	mov    %edx,%edi
  80087d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800880:	fc                   	cld    
  800881:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800883:	89 d0                	mov    %edx,%eax
  800885:	5b                   	pop    %ebx
  800886:	5e                   	pop    %esi
  800887:	5f                   	pop    %edi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088a:	f3 0f 1e fb          	endbr32 
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	57                   	push   %edi
  800892:	56                   	push   %esi
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	8b 75 0c             	mov    0xc(%ebp),%esi
  800899:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80089c:	39 c6                	cmp    %eax,%esi
  80089e:	73 32                	jae    8008d2 <memmove+0x48>
  8008a0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a3:	39 c2                	cmp    %eax,%edx
  8008a5:	76 2b                	jbe    8008d2 <memmove+0x48>
		s += n;
		d += n;
  8008a7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008aa:	89 fe                	mov    %edi,%esi
  8008ac:	09 ce                	or     %ecx,%esi
  8008ae:	09 d6                	or     %edx,%esi
  8008b0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b6:	75 0e                	jne    8008c6 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008b8:	83 ef 04             	sub    $0x4,%edi
  8008bb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008be:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008c1:	fd                   	std    
  8008c2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c4:	eb 09                	jmp    8008cf <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008c6:	83 ef 01             	sub    $0x1,%edi
  8008c9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008cc:	fd                   	std    
  8008cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008cf:	fc                   	cld    
  8008d0:	eb 1a                	jmp    8008ec <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d2:	89 c2                	mov    %eax,%edx
  8008d4:	09 ca                	or     %ecx,%edx
  8008d6:	09 f2                	or     %esi,%edx
  8008d8:	f6 c2 03             	test   $0x3,%dl
  8008db:	75 0a                	jne    8008e7 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008dd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8008e0:	89 c7                	mov    %eax,%edi
  8008e2:	fc                   	cld    
  8008e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e5:	eb 05                	jmp    8008ec <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8008e7:	89 c7                	mov    %eax,%edi
  8008e9:	fc                   	cld    
  8008ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ec:	5e                   	pop    %esi
  8008ed:	5f                   	pop    %edi
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f0:	f3 0f 1e fb          	endbr32 
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8008fa:	ff 75 10             	pushl  0x10(%ebp)
  8008fd:	ff 75 0c             	pushl  0xc(%ebp)
  800900:	ff 75 08             	pushl  0x8(%ebp)
  800903:	e8 82 ff ff ff       	call   80088a <memmove>
}
  800908:	c9                   	leave  
  800909:	c3                   	ret    

0080090a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80090a:	f3 0f 1e fb          	endbr32 
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	56                   	push   %esi
  800912:	53                   	push   %ebx
  800913:	8b 45 08             	mov    0x8(%ebp),%eax
  800916:	8b 55 0c             	mov    0xc(%ebp),%edx
  800919:	89 c6                	mov    %eax,%esi
  80091b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80091e:	39 f0                	cmp    %esi,%eax
  800920:	74 1c                	je     80093e <memcmp+0x34>
		if (*s1 != *s2)
  800922:	0f b6 08             	movzbl (%eax),%ecx
  800925:	0f b6 1a             	movzbl (%edx),%ebx
  800928:	38 d9                	cmp    %bl,%cl
  80092a:	75 08                	jne    800934 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80092c:	83 c0 01             	add    $0x1,%eax
  80092f:	83 c2 01             	add    $0x1,%edx
  800932:	eb ea                	jmp    80091e <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800934:	0f b6 c1             	movzbl %cl,%eax
  800937:	0f b6 db             	movzbl %bl,%ebx
  80093a:	29 d8                	sub    %ebx,%eax
  80093c:	eb 05                	jmp    800943 <memcmp+0x39>
	}

	return 0;
  80093e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800947:	f3 0f 1e fb          	endbr32 
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800954:	89 c2                	mov    %eax,%edx
  800956:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800959:	39 d0                	cmp    %edx,%eax
  80095b:	73 09                	jae    800966 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  80095d:	38 08                	cmp    %cl,(%eax)
  80095f:	74 05                	je     800966 <memfind+0x1f>
	for (; s < ends; s++)
  800961:	83 c0 01             	add    $0x1,%eax
  800964:	eb f3                	jmp    800959 <memfind+0x12>
			break;
	return (void *) s;
}
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800968:	f3 0f 1e fb          	endbr32 
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	57                   	push   %edi
  800970:	56                   	push   %esi
  800971:	53                   	push   %ebx
  800972:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800975:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800978:	eb 03                	jmp    80097d <strtol+0x15>
		s++;
  80097a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80097d:	0f b6 01             	movzbl (%ecx),%eax
  800980:	3c 20                	cmp    $0x20,%al
  800982:	74 f6                	je     80097a <strtol+0x12>
  800984:	3c 09                	cmp    $0x9,%al
  800986:	74 f2                	je     80097a <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800988:	3c 2b                	cmp    $0x2b,%al
  80098a:	74 2a                	je     8009b6 <strtol+0x4e>
	int neg = 0;
  80098c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800991:	3c 2d                	cmp    $0x2d,%al
  800993:	74 2b                	je     8009c0 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800995:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80099b:	75 0f                	jne    8009ac <strtol+0x44>
  80099d:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a0:	74 28                	je     8009ca <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009a2:	85 db                	test   %ebx,%ebx
  8009a4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009a9:	0f 44 d8             	cmove  %eax,%ebx
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009b4:	eb 46                	jmp    8009fc <strtol+0x94>
		s++;
  8009b6:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8009b9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009be:	eb d5                	jmp    800995 <strtol+0x2d>
		s++, neg = 1;
  8009c0:	83 c1 01             	add    $0x1,%ecx
  8009c3:	bf 01 00 00 00       	mov    $0x1,%edi
  8009c8:	eb cb                	jmp    800995 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ca:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ce:	74 0e                	je     8009de <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009d0:	85 db                	test   %ebx,%ebx
  8009d2:	75 d8                	jne    8009ac <strtol+0x44>
		s++, base = 8;
  8009d4:	83 c1 01             	add    $0x1,%ecx
  8009d7:	bb 08 00 00 00       	mov    $0x8,%ebx
  8009dc:	eb ce                	jmp    8009ac <strtol+0x44>
		s += 2, base = 16;
  8009de:	83 c1 02             	add    $0x2,%ecx
  8009e1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e6:	eb c4                	jmp    8009ac <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8009e8:	0f be d2             	movsbl %dl,%edx
  8009eb:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8009ee:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009f1:	7d 3a                	jge    800a2d <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8009f3:	83 c1 01             	add    $0x1,%ecx
  8009f6:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009fa:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8009fc:	0f b6 11             	movzbl (%ecx),%edx
  8009ff:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a02:	89 f3                	mov    %esi,%ebx
  800a04:	80 fb 09             	cmp    $0x9,%bl
  800a07:	76 df                	jbe    8009e8 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800a09:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a0c:	89 f3                	mov    %esi,%ebx
  800a0e:	80 fb 19             	cmp    $0x19,%bl
  800a11:	77 08                	ja     800a1b <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a13:	0f be d2             	movsbl %dl,%edx
  800a16:	83 ea 57             	sub    $0x57,%edx
  800a19:	eb d3                	jmp    8009ee <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800a1b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a1e:	89 f3                	mov    %esi,%ebx
  800a20:	80 fb 19             	cmp    $0x19,%bl
  800a23:	77 08                	ja     800a2d <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a25:	0f be d2             	movsbl %dl,%edx
  800a28:	83 ea 37             	sub    $0x37,%edx
  800a2b:	eb c1                	jmp    8009ee <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a2d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a31:	74 05                	je     800a38 <strtol+0xd0>
		*endptr = (char *) s;
  800a33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a36:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a38:	89 c2                	mov    %eax,%edx
  800a3a:	f7 da                	neg    %edx
  800a3c:	85 ff                	test   %edi,%edi
  800a3e:	0f 45 c2             	cmovne %edx,%eax
}
  800a41:	5b                   	pop    %ebx
  800a42:	5e                   	pop    %esi
  800a43:	5f                   	pop    %edi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	57                   	push   %edi
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
  800a4c:	83 ec 1c             	sub    $0x1c,%esp
  800a4f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a52:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a55:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a60:	8b 75 14             	mov    0x14(%ebp),%esi
  800a63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a65:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a69:	74 04                	je     800a6f <syscall+0x29>
  800a6b:	85 c0                	test   %eax,%eax
  800a6d:	7f 08                	jg     800a77 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5f                   	pop    %edi
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a77:	83 ec 0c             	sub    $0xc,%esp
  800a7a:	50                   	push   %eax
  800a7b:	ff 75 e0             	pushl  -0x20(%ebp)
  800a7e:	68 3f 21 80 00       	push   $0x80213f
  800a83:	6a 23                	push   $0x23
  800a85:	68 5c 21 80 00       	push   $0x80215c
  800a8a:	e8 76 0f 00 00       	call   801a05 <_panic>

00800a8f <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800a8f:	f3 0f 1e fb          	endbr32 
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800a99:	6a 00                	push   $0x0
  800a9b:	6a 00                	push   $0x0
  800a9d:	6a 00                	push   $0x0
  800a9f:	ff 75 0c             	pushl  0xc(%ebp)
  800aa2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaf:	e8 92 ff ff ff       	call   800a46 <syscall>
}
  800ab4:	83 c4 10             	add    $0x10,%esp
  800ab7:	c9                   	leave  
  800ab8:	c3                   	ret    

00800ab9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ab9:	f3 0f 1e fb          	endbr32 
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ac3:	6a 00                	push   $0x0
  800ac5:	6a 00                	push   $0x0
  800ac7:	6a 00                	push   $0x0
  800ac9:	6a 00                	push   $0x0
  800acb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad5:	b8 01 00 00 00       	mov    $0x1,%eax
  800ada:	e8 67 ff ff ff       	call   800a46 <syscall>
}
  800adf:	c9                   	leave  
  800ae0:	c3                   	ret    

00800ae1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae1:	f3 0f 1e fb          	endbr32 
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800aeb:	6a 00                	push   $0x0
  800aed:	6a 00                	push   $0x0
  800aef:	6a 00                	push   $0x0
  800af1:	6a 00                	push   $0x0
  800af3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af6:	ba 01 00 00 00       	mov    $0x1,%edx
  800afb:	b8 03 00 00 00       	mov    $0x3,%eax
  800b00:	e8 41 ff ff ff       	call   800a46 <syscall>
}
  800b05:	c9                   	leave  
  800b06:	c3                   	ret    

00800b07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b07:	f3 0f 1e fb          	endbr32 
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b11:	6a 00                	push   $0x0
  800b13:	6a 00                	push   $0x0
  800b15:	6a 00                	push   $0x0
  800b17:	6a 00                	push   $0x0
  800b19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b23:	b8 02 00 00 00       	mov    $0x2,%eax
  800b28:	e8 19 ff ff ff       	call   800a46 <syscall>
}
  800b2d:	c9                   	leave  
  800b2e:	c3                   	ret    

00800b2f <sys_yield>:

void
sys_yield(void)
{
  800b2f:	f3 0f 1e fb          	endbr32 
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b39:	6a 00                	push   $0x0
  800b3b:	6a 00                	push   $0x0
  800b3d:	6a 00                	push   $0x0
  800b3f:	6a 00                	push   $0x0
  800b41:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b46:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b50:	e8 f1 fe ff ff       	call   800a46 <syscall>
}
  800b55:	83 c4 10             	add    $0x10,%esp
  800b58:	c9                   	leave  
  800b59:	c3                   	ret    

00800b5a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5a:	f3 0f 1e fb          	endbr32 
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b64:	6a 00                	push   $0x0
  800b66:	6a 00                	push   $0x0
  800b68:	ff 75 10             	pushl  0x10(%ebp)
  800b6b:	ff 75 0c             	pushl  0xc(%ebp)
  800b6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b71:	ba 01 00 00 00       	mov    $0x1,%edx
  800b76:	b8 04 00 00 00       	mov    $0x4,%eax
  800b7b:	e8 c6 fe ff ff       	call   800a46 <syscall>
}
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    

00800b82 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b82:	f3 0f 1e fb          	endbr32 
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800b8c:	ff 75 18             	pushl  0x18(%ebp)
  800b8f:	ff 75 14             	pushl  0x14(%ebp)
  800b92:	ff 75 10             	pushl  0x10(%ebp)
  800b95:	ff 75 0c             	pushl  0xc(%ebp)
  800b98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9b:	ba 01 00 00 00       	mov    $0x1,%edx
  800ba0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ba5:	e8 9c fe ff ff       	call   800a46 <syscall>
}
  800baa:	c9                   	leave  
  800bab:	c3                   	ret    

00800bac <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bac:	f3 0f 1e fb          	endbr32 
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bb6:	6a 00                	push   $0x0
  800bb8:	6a 00                	push   $0x0
  800bba:	6a 00                	push   $0x0
  800bbc:	ff 75 0c             	pushl  0xc(%ebp)
  800bbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc2:	ba 01 00 00 00       	mov    $0x1,%edx
  800bc7:	b8 06 00 00 00       	mov    $0x6,%eax
  800bcc:	e8 75 fe ff ff       	call   800a46 <syscall>
}
  800bd1:	c9                   	leave  
  800bd2:	c3                   	ret    

00800bd3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bd3:	f3 0f 1e fb          	endbr32 
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800bdd:	6a 00                	push   $0x0
  800bdf:	6a 00                	push   $0x0
  800be1:	6a 00                	push   $0x0
  800be3:	ff 75 0c             	pushl  0xc(%ebp)
  800be6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be9:	ba 01 00 00 00       	mov    $0x1,%edx
  800bee:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf3:	e8 4e fe ff ff       	call   800a46 <syscall>
}
  800bf8:	c9                   	leave  
  800bf9:	c3                   	ret    

00800bfa <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bfa:	f3 0f 1e fb          	endbr32 
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c04:	6a 00                	push   $0x0
  800c06:	6a 00                	push   $0x0
  800c08:	6a 00                	push   $0x0
  800c0a:	ff 75 0c             	pushl  0xc(%ebp)
  800c0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c10:	ba 01 00 00 00       	mov    $0x1,%edx
  800c15:	b8 09 00 00 00       	mov    $0x9,%eax
  800c1a:	e8 27 fe ff ff       	call   800a46 <syscall>
}
  800c1f:	c9                   	leave  
  800c20:	c3                   	ret    

00800c21 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c21:	f3 0f 1e fb          	endbr32 
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c2b:	6a 00                	push   $0x0
  800c2d:	6a 00                	push   $0x0
  800c2f:	6a 00                	push   $0x0
  800c31:	ff 75 0c             	pushl  0xc(%ebp)
  800c34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c37:	ba 01 00 00 00       	mov    $0x1,%edx
  800c3c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c41:	e8 00 fe ff ff       	call   800a46 <syscall>
}
  800c46:	c9                   	leave  
  800c47:	c3                   	ret    

00800c48 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c48:	f3 0f 1e fb          	endbr32 
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c52:	6a 00                	push   $0x0
  800c54:	ff 75 14             	pushl  0x14(%ebp)
  800c57:	ff 75 10             	pushl  0x10(%ebp)
  800c5a:	ff 75 0c             	pushl  0xc(%ebp)
  800c5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c6a:	e8 d7 fd ff ff       	call   800a46 <syscall>
}
  800c6f:	c9                   	leave  
  800c70:	c3                   	ret    

00800c71 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c71:	f3 0f 1e fb          	endbr32 
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800c7b:	6a 00                	push   $0x0
  800c7d:	6a 00                	push   $0x0
  800c7f:	6a 00                	push   $0x0
  800c81:	6a 00                	push   $0x0
  800c83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c86:	ba 01 00 00 00       	mov    $0x1,%edx
  800c8b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800c90:	e8 b1 fd ff ff       	call   800a46 <syscall>
}
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    

00800c97 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800c97:	f3 0f 1e fb          	endbr32 
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca1:	05 00 00 00 30       	add    $0x30000000,%eax
  800ca6:	c1 e8 0c             	shr    $0xc,%eax
}
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800cab:	f3 0f 1e fb          	endbr32 
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800cb5:	ff 75 08             	pushl  0x8(%ebp)
  800cb8:	e8 da ff ff ff       	call   800c97 <fd2num>
  800cbd:	83 c4 10             	add    $0x10,%esp
  800cc0:	c1 e0 0c             	shl    $0xc,%eax
  800cc3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800cc8:	c9                   	leave  
  800cc9:	c3                   	ret    

00800cca <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800cca:	f3 0f 1e fb          	endbr32 
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800cd6:	89 c2                	mov    %eax,%edx
  800cd8:	c1 ea 16             	shr    $0x16,%edx
  800cdb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ce2:	f6 c2 01             	test   $0x1,%dl
  800ce5:	74 2d                	je     800d14 <fd_alloc+0x4a>
  800ce7:	89 c2                	mov    %eax,%edx
  800ce9:	c1 ea 0c             	shr    $0xc,%edx
  800cec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800cf3:	f6 c2 01             	test   $0x1,%dl
  800cf6:	74 1c                	je     800d14 <fd_alloc+0x4a>
  800cf8:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800cfd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d02:	75 d2                	jne    800cd6 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d04:	8b 45 08             	mov    0x8(%ebp),%eax
  800d07:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800d0d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800d12:	eb 0a                	jmp    800d1e <fd_alloc+0x54>
			*fd_store = fd;
  800d14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d17:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d20:	f3 0f 1e fb          	endbr32 
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d2a:	83 f8 1f             	cmp    $0x1f,%eax
  800d2d:	77 30                	ja     800d5f <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d2f:	c1 e0 0c             	shl    $0xc,%eax
  800d32:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d37:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800d3d:	f6 c2 01             	test   $0x1,%dl
  800d40:	74 24                	je     800d66 <fd_lookup+0x46>
  800d42:	89 c2                	mov    %eax,%edx
  800d44:	c1 ea 0c             	shr    $0xc,%edx
  800d47:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d4e:	f6 c2 01             	test   $0x1,%dl
  800d51:	74 1a                	je     800d6d <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d53:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d56:	89 02                	mov    %eax,(%edx)
	return 0;
  800d58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    
		return -E_INVAL;
  800d5f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d64:	eb f7                	jmp    800d5d <fd_lookup+0x3d>
		return -E_INVAL;
  800d66:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d6b:	eb f0                	jmp    800d5d <fd_lookup+0x3d>
  800d6d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d72:	eb e9                	jmp    800d5d <fd_lookup+0x3d>

00800d74 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800d74:	f3 0f 1e fb          	endbr32 
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	83 ec 08             	sub    $0x8,%esp
  800d7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d81:	ba e8 21 80 00       	mov    $0x8021e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800d86:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800d8b:	39 08                	cmp    %ecx,(%eax)
  800d8d:	74 33                	je     800dc2 <dev_lookup+0x4e>
  800d8f:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800d92:	8b 02                	mov    (%edx),%eax
  800d94:	85 c0                	test   %eax,%eax
  800d96:	75 f3                	jne    800d8b <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800d98:	a1 04 40 80 00       	mov    0x804004,%eax
  800d9d:	8b 40 48             	mov    0x48(%eax),%eax
  800da0:	83 ec 04             	sub    $0x4,%esp
  800da3:	51                   	push   %ecx
  800da4:	50                   	push   %eax
  800da5:	68 6c 21 80 00       	push   $0x80216c
  800daa:	e8 b9 f3 ff ff       	call   800168 <cprintf>
	*dev = 0;
  800daf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800db8:	83 c4 10             	add    $0x10,%esp
  800dbb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800dc0:	c9                   	leave  
  800dc1:	c3                   	ret    
			*dev = devtab[i];
  800dc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcc:	eb f2                	jmp    800dc0 <dev_lookup+0x4c>

00800dce <fd_close>:
{
  800dce:	f3 0f 1e fb          	endbr32 
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 28             	sub    $0x28,%esp
  800ddb:	8b 75 08             	mov    0x8(%ebp),%esi
  800dde:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800de1:	56                   	push   %esi
  800de2:	e8 b0 fe ff ff       	call   800c97 <fd2num>
  800de7:	83 c4 08             	add    $0x8,%esp
  800dea:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800ded:	52                   	push   %edx
  800dee:	50                   	push   %eax
  800def:	e8 2c ff ff ff       	call   800d20 <fd_lookup>
  800df4:	89 c3                	mov    %eax,%ebx
  800df6:	83 c4 10             	add    $0x10,%esp
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	78 05                	js     800e02 <fd_close+0x34>
	    || fd != fd2)
  800dfd:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800e00:	74 16                	je     800e18 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800e02:	89 f8                	mov    %edi,%eax
  800e04:	84 c0                	test   %al,%al
  800e06:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0b:	0f 44 d8             	cmove  %eax,%ebx
}
  800e0e:	89 d8                	mov    %ebx,%eax
  800e10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e18:	83 ec 08             	sub    $0x8,%esp
  800e1b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800e1e:	50                   	push   %eax
  800e1f:	ff 36                	pushl  (%esi)
  800e21:	e8 4e ff ff ff       	call   800d74 <dev_lookup>
  800e26:	89 c3                	mov    %eax,%ebx
  800e28:	83 c4 10             	add    $0x10,%esp
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	78 1a                	js     800e49 <fd_close+0x7b>
		if (dev->dev_close)
  800e2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e32:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800e35:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	74 0b                	je     800e49 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800e3e:	83 ec 0c             	sub    $0xc,%esp
  800e41:	56                   	push   %esi
  800e42:	ff d0                	call   *%eax
  800e44:	89 c3                	mov    %eax,%ebx
  800e46:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800e49:	83 ec 08             	sub    $0x8,%esp
  800e4c:	56                   	push   %esi
  800e4d:	6a 00                	push   $0x0
  800e4f:	e8 58 fd ff ff       	call   800bac <sys_page_unmap>
	return r;
  800e54:	83 c4 10             	add    $0x10,%esp
  800e57:	eb b5                	jmp    800e0e <fd_close+0x40>

00800e59 <close>:

int
close(int fdnum)
{
  800e59:	f3 0f 1e fb          	endbr32 
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e66:	50                   	push   %eax
  800e67:	ff 75 08             	pushl  0x8(%ebp)
  800e6a:	e8 b1 fe ff ff       	call   800d20 <fd_lookup>
  800e6f:	83 c4 10             	add    $0x10,%esp
  800e72:	85 c0                	test   %eax,%eax
  800e74:	79 02                	jns    800e78 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800e76:	c9                   	leave  
  800e77:	c3                   	ret    
		return fd_close(fd, 1);
  800e78:	83 ec 08             	sub    $0x8,%esp
  800e7b:	6a 01                	push   $0x1
  800e7d:	ff 75 f4             	pushl  -0xc(%ebp)
  800e80:	e8 49 ff ff ff       	call   800dce <fd_close>
  800e85:	83 c4 10             	add    $0x10,%esp
  800e88:	eb ec                	jmp    800e76 <close+0x1d>

00800e8a <close_all>:

void
close_all(void)
{
  800e8a:	f3 0f 1e fb          	endbr32 
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	53                   	push   %ebx
  800e92:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800e95:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800e9a:	83 ec 0c             	sub    $0xc,%esp
  800e9d:	53                   	push   %ebx
  800e9e:	e8 b6 ff ff ff       	call   800e59 <close>
	for (i = 0; i < MAXFD; i++)
  800ea3:	83 c3 01             	add    $0x1,%ebx
  800ea6:	83 c4 10             	add    $0x10,%esp
  800ea9:	83 fb 20             	cmp    $0x20,%ebx
  800eac:	75 ec                	jne    800e9a <close_all+0x10>
}
  800eae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    

00800eb3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800eb3:	f3 0f 1e fb          	endbr32 
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	57                   	push   %edi
  800ebb:	56                   	push   %esi
  800ebc:	53                   	push   %ebx
  800ebd:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ec0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ec3:	50                   	push   %eax
  800ec4:	ff 75 08             	pushl  0x8(%ebp)
  800ec7:	e8 54 fe ff ff       	call   800d20 <fd_lookup>
  800ecc:	89 c3                	mov    %eax,%ebx
  800ece:	83 c4 10             	add    $0x10,%esp
  800ed1:	85 c0                	test   %eax,%eax
  800ed3:	0f 88 81 00 00 00    	js     800f5a <dup+0xa7>
		return r;
	close(newfdnum);
  800ed9:	83 ec 0c             	sub    $0xc,%esp
  800edc:	ff 75 0c             	pushl  0xc(%ebp)
  800edf:	e8 75 ff ff ff       	call   800e59 <close>

	newfd = INDEX2FD(newfdnum);
  800ee4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ee7:	c1 e6 0c             	shl    $0xc,%esi
  800eea:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800ef0:	83 c4 04             	add    $0x4,%esp
  800ef3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ef6:	e8 b0 fd ff ff       	call   800cab <fd2data>
  800efb:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800efd:	89 34 24             	mov    %esi,(%esp)
  800f00:	e8 a6 fd ff ff       	call   800cab <fd2data>
  800f05:	83 c4 10             	add    $0x10,%esp
  800f08:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f0a:	89 d8                	mov    %ebx,%eax
  800f0c:	c1 e8 16             	shr    $0x16,%eax
  800f0f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f16:	a8 01                	test   $0x1,%al
  800f18:	74 11                	je     800f2b <dup+0x78>
  800f1a:	89 d8                	mov    %ebx,%eax
  800f1c:	c1 e8 0c             	shr    $0xc,%eax
  800f1f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f26:	f6 c2 01             	test   $0x1,%dl
  800f29:	75 39                	jne    800f64 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f2b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f2e:	89 d0                	mov    %edx,%eax
  800f30:	c1 e8 0c             	shr    $0xc,%eax
  800f33:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f3a:	83 ec 0c             	sub    $0xc,%esp
  800f3d:	25 07 0e 00 00       	and    $0xe07,%eax
  800f42:	50                   	push   %eax
  800f43:	56                   	push   %esi
  800f44:	6a 00                	push   $0x0
  800f46:	52                   	push   %edx
  800f47:	6a 00                	push   $0x0
  800f49:	e8 34 fc ff ff       	call   800b82 <sys_page_map>
  800f4e:	89 c3                	mov    %eax,%ebx
  800f50:	83 c4 20             	add    $0x20,%esp
  800f53:	85 c0                	test   %eax,%eax
  800f55:	78 31                	js     800f88 <dup+0xd5>
		goto err;

	return newfdnum;
  800f57:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800f5a:	89 d8                	mov    %ebx,%eax
  800f5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5f:	5b                   	pop    %ebx
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f64:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6b:	83 ec 0c             	sub    $0xc,%esp
  800f6e:	25 07 0e 00 00       	and    $0xe07,%eax
  800f73:	50                   	push   %eax
  800f74:	57                   	push   %edi
  800f75:	6a 00                	push   $0x0
  800f77:	53                   	push   %ebx
  800f78:	6a 00                	push   $0x0
  800f7a:	e8 03 fc ff ff       	call   800b82 <sys_page_map>
  800f7f:	89 c3                	mov    %eax,%ebx
  800f81:	83 c4 20             	add    $0x20,%esp
  800f84:	85 c0                	test   %eax,%eax
  800f86:	79 a3                	jns    800f2b <dup+0x78>
	sys_page_unmap(0, newfd);
  800f88:	83 ec 08             	sub    $0x8,%esp
  800f8b:	56                   	push   %esi
  800f8c:	6a 00                	push   $0x0
  800f8e:	e8 19 fc ff ff       	call   800bac <sys_page_unmap>
	sys_page_unmap(0, nva);
  800f93:	83 c4 08             	add    $0x8,%esp
  800f96:	57                   	push   %edi
  800f97:	6a 00                	push   $0x0
  800f99:	e8 0e fc ff ff       	call   800bac <sys_page_unmap>
	return r;
  800f9e:	83 c4 10             	add    $0x10,%esp
  800fa1:	eb b7                	jmp    800f5a <dup+0xa7>

00800fa3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fa3:	f3 0f 1e fb          	endbr32 
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	53                   	push   %ebx
  800fab:	83 ec 1c             	sub    $0x1c,%esp
  800fae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fb1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fb4:	50                   	push   %eax
  800fb5:	53                   	push   %ebx
  800fb6:	e8 65 fd ff ff       	call   800d20 <fd_lookup>
  800fbb:	83 c4 10             	add    $0x10,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	78 3f                	js     801001 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fc2:	83 ec 08             	sub    $0x8,%esp
  800fc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc8:	50                   	push   %eax
  800fc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fcc:	ff 30                	pushl  (%eax)
  800fce:	e8 a1 fd ff ff       	call   800d74 <dev_lookup>
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	78 27                	js     801001 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800fda:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fdd:	8b 42 08             	mov    0x8(%edx),%eax
  800fe0:	83 e0 03             	and    $0x3,%eax
  800fe3:	83 f8 01             	cmp    $0x1,%eax
  800fe6:	74 1e                	je     801006 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800feb:	8b 40 08             	mov    0x8(%eax),%eax
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	74 35                	je     801027 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800ff2:	83 ec 04             	sub    $0x4,%esp
  800ff5:	ff 75 10             	pushl  0x10(%ebp)
  800ff8:	ff 75 0c             	pushl  0xc(%ebp)
  800ffb:	52                   	push   %edx
  800ffc:	ff d0                	call   *%eax
  800ffe:	83 c4 10             	add    $0x10,%esp
}
  801001:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801004:	c9                   	leave  
  801005:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801006:	a1 04 40 80 00       	mov    0x804004,%eax
  80100b:	8b 40 48             	mov    0x48(%eax),%eax
  80100e:	83 ec 04             	sub    $0x4,%esp
  801011:	53                   	push   %ebx
  801012:	50                   	push   %eax
  801013:	68 ad 21 80 00       	push   $0x8021ad
  801018:	e8 4b f1 ff ff       	call   800168 <cprintf>
		return -E_INVAL;
  80101d:	83 c4 10             	add    $0x10,%esp
  801020:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801025:	eb da                	jmp    801001 <read+0x5e>
		return -E_NOT_SUPP;
  801027:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80102c:	eb d3                	jmp    801001 <read+0x5e>

0080102e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80102e:	f3 0f 1e fb          	endbr32 
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	57                   	push   %edi
  801036:	56                   	push   %esi
  801037:	53                   	push   %ebx
  801038:	83 ec 0c             	sub    $0xc,%esp
  80103b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80103e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801041:	bb 00 00 00 00       	mov    $0x0,%ebx
  801046:	eb 02                	jmp    80104a <readn+0x1c>
  801048:	01 c3                	add    %eax,%ebx
  80104a:	39 f3                	cmp    %esi,%ebx
  80104c:	73 21                	jae    80106f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80104e:	83 ec 04             	sub    $0x4,%esp
  801051:	89 f0                	mov    %esi,%eax
  801053:	29 d8                	sub    %ebx,%eax
  801055:	50                   	push   %eax
  801056:	89 d8                	mov    %ebx,%eax
  801058:	03 45 0c             	add    0xc(%ebp),%eax
  80105b:	50                   	push   %eax
  80105c:	57                   	push   %edi
  80105d:	e8 41 ff ff ff       	call   800fa3 <read>
		if (m < 0)
  801062:	83 c4 10             	add    $0x10,%esp
  801065:	85 c0                	test   %eax,%eax
  801067:	78 04                	js     80106d <readn+0x3f>
			return m;
		if (m == 0)
  801069:	75 dd                	jne    801048 <readn+0x1a>
  80106b:	eb 02                	jmp    80106f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80106d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80106f:	89 d8                	mov    %ebx,%eax
  801071:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801074:	5b                   	pop    %ebx
  801075:	5e                   	pop    %esi
  801076:	5f                   	pop    %edi
  801077:	5d                   	pop    %ebp
  801078:	c3                   	ret    

00801079 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801079:	f3 0f 1e fb          	endbr32 
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	53                   	push   %ebx
  801081:	83 ec 1c             	sub    $0x1c,%esp
  801084:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801087:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80108a:	50                   	push   %eax
  80108b:	53                   	push   %ebx
  80108c:	e8 8f fc ff ff       	call   800d20 <fd_lookup>
  801091:	83 c4 10             	add    $0x10,%esp
  801094:	85 c0                	test   %eax,%eax
  801096:	78 3a                	js     8010d2 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801098:	83 ec 08             	sub    $0x8,%esp
  80109b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80109e:	50                   	push   %eax
  80109f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010a2:	ff 30                	pushl  (%eax)
  8010a4:	e8 cb fc ff ff       	call   800d74 <dev_lookup>
  8010a9:	83 c4 10             	add    $0x10,%esp
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	78 22                	js     8010d2 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010b3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010b7:	74 1e                	je     8010d7 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8010bf:	85 d2                	test   %edx,%edx
  8010c1:	74 35                	je     8010f8 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8010c3:	83 ec 04             	sub    $0x4,%esp
  8010c6:	ff 75 10             	pushl  0x10(%ebp)
  8010c9:	ff 75 0c             	pushl  0xc(%ebp)
  8010cc:	50                   	push   %eax
  8010cd:	ff d2                	call   *%edx
  8010cf:	83 c4 10             	add    $0x10,%esp
}
  8010d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d5:	c9                   	leave  
  8010d6:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8010dc:	8b 40 48             	mov    0x48(%eax),%eax
  8010df:	83 ec 04             	sub    $0x4,%esp
  8010e2:	53                   	push   %ebx
  8010e3:	50                   	push   %eax
  8010e4:	68 c9 21 80 00       	push   $0x8021c9
  8010e9:	e8 7a f0 ff ff       	call   800168 <cprintf>
		return -E_INVAL;
  8010ee:	83 c4 10             	add    $0x10,%esp
  8010f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010f6:	eb da                	jmp    8010d2 <write+0x59>
		return -E_NOT_SUPP;
  8010f8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010fd:	eb d3                	jmp    8010d2 <write+0x59>

008010ff <seek>:

int
seek(int fdnum, off_t offset)
{
  8010ff:	f3 0f 1e fb          	endbr32 
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801109:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80110c:	50                   	push   %eax
  80110d:	ff 75 08             	pushl  0x8(%ebp)
  801110:	e8 0b fc ff ff       	call   800d20 <fd_lookup>
  801115:	83 c4 10             	add    $0x10,%esp
  801118:	85 c0                	test   %eax,%eax
  80111a:	78 0e                	js     80112a <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80111c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80111f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801122:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801125:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80112a:	c9                   	leave  
  80112b:	c3                   	ret    

0080112c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80112c:	f3 0f 1e fb          	endbr32 
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	53                   	push   %ebx
  801134:	83 ec 1c             	sub    $0x1c,%esp
  801137:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80113a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113d:	50                   	push   %eax
  80113e:	53                   	push   %ebx
  80113f:	e8 dc fb ff ff       	call   800d20 <fd_lookup>
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	85 c0                	test   %eax,%eax
  801149:	78 37                	js     801182 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114b:	83 ec 08             	sub    $0x8,%esp
  80114e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801151:	50                   	push   %eax
  801152:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801155:	ff 30                	pushl  (%eax)
  801157:	e8 18 fc ff ff       	call   800d74 <dev_lookup>
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	85 c0                	test   %eax,%eax
  801161:	78 1f                	js     801182 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801163:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801166:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80116a:	74 1b                	je     801187 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80116c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80116f:	8b 52 18             	mov    0x18(%edx),%edx
  801172:	85 d2                	test   %edx,%edx
  801174:	74 32                	je     8011a8 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801176:	83 ec 08             	sub    $0x8,%esp
  801179:	ff 75 0c             	pushl  0xc(%ebp)
  80117c:	50                   	push   %eax
  80117d:	ff d2                	call   *%edx
  80117f:	83 c4 10             	add    $0x10,%esp
}
  801182:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801185:	c9                   	leave  
  801186:	c3                   	ret    
			thisenv->env_id, fdnum);
  801187:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80118c:	8b 40 48             	mov    0x48(%eax),%eax
  80118f:	83 ec 04             	sub    $0x4,%esp
  801192:	53                   	push   %ebx
  801193:	50                   	push   %eax
  801194:	68 8c 21 80 00       	push   $0x80218c
  801199:	e8 ca ef ff ff       	call   800168 <cprintf>
		return -E_INVAL;
  80119e:	83 c4 10             	add    $0x10,%esp
  8011a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a6:	eb da                	jmp    801182 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8011a8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011ad:	eb d3                	jmp    801182 <ftruncate+0x56>

008011af <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011af:	f3 0f 1e fb          	endbr32 
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	53                   	push   %ebx
  8011b7:	83 ec 1c             	sub    $0x1c,%esp
  8011ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	ff 75 08             	pushl  0x8(%ebp)
  8011c4:	e8 57 fb ff ff       	call   800d20 <fd_lookup>
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	78 4b                	js     80121b <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d0:	83 ec 08             	sub    $0x8,%esp
  8011d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d6:	50                   	push   %eax
  8011d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011da:	ff 30                	pushl  (%eax)
  8011dc:	e8 93 fb ff ff       	call   800d74 <dev_lookup>
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	78 33                	js     80121b <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8011e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011eb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8011ef:	74 2f                	je     801220 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8011f1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8011f4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8011fb:	00 00 00 
	stat->st_isdir = 0;
  8011fe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801205:	00 00 00 
	stat->st_dev = dev;
  801208:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80120e:	83 ec 08             	sub    $0x8,%esp
  801211:	53                   	push   %ebx
  801212:	ff 75 f0             	pushl  -0x10(%ebp)
  801215:	ff 50 14             	call   *0x14(%eax)
  801218:	83 c4 10             	add    $0x10,%esp
}
  80121b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80121e:	c9                   	leave  
  80121f:	c3                   	ret    
		return -E_NOT_SUPP;
  801220:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801225:	eb f4                	jmp    80121b <fstat+0x6c>

00801227 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801227:	f3 0f 1e fb          	endbr32 
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	56                   	push   %esi
  80122f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801230:	83 ec 08             	sub    $0x8,%esp
  801233:	6a 00                	push   $0x0
  801235:	ff 75 08             	pushl  0x8(%ebp)
  801238:	e8 20 02 00 00       	call   80145d <open>
  80123d:	89 c3                	mov    %eax,%ebx
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	85 c0                	test   %eax,%eax
  801244:	78 1b                	js     801261 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801246:	83 ec 08             	sub    $0x8,%esp
  801249:	ff 75 0c             	pushl  0xc(%ebp)
  80124c:	50                   	push   %eax
  80124d:	e8 5d ff ff ff       	call   8011af <fstat>
  801252:	89 c6                	mov    %eax,%esi
	close(fd);
  801254:	89 1c 24             	mov    %ebx,(%esp)
  801257:	e8 fd fb ff ff       	call   800e59 <close>
	return r;
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	89 f3                	mov    %esi,%ebx
}
  801261:	89 d8                	mov    %ebx,%eax
  801263:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801266:	5b                   	pop    %ebx
  801267:	5e                   	pop    %esi
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    

0080126a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	56                   	push   %esi
  80126e:	53                   	push   %ebx
  80126f:	89 c6                	mov    %eax,%esi
  801271:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801273:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80127a:	74 27                	je     8012a3 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80127c:	6a 07                	push   $0x7
  80127e:	68 00 50 80 00       	push   $0x805000
  801283:	56                   	push   %esi
  801284:	ff 35 00 40 80 00    	pushl  0x804000
  80128a:	e8 2d 08 00 00       	call   801abc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80128f:	83 c4 0c             	add    $0xc,%esp
  801292:	6a 00                	push   $0x0
  801294:	53                   	push   %ebx
  801295:	6a 00                	push   $0x0
  801297:	e8 b3 07 00 00       	call   801a4f <ipc_recv>
}
  80129c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80129f:	5b                   	pop    %ebx
  8012a0:	5e                   	pop    %esi
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012a3:	83 ec 0c             	sub    $0xc,%esp
  8012a6:	6a 01                	push   $0x1
  8012a8:	e8 62 08 00 00       	call   801b0f <ipc_find_env>
  8012ad:	a3 00 40 80 00       	mov    %eax,0x804000
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	eb c5                	jmp    80127c <fsipc+0x12>

008012b7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012b7:	f3 0f 1e fb          	endbr32 
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8012c7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cf:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8012d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d9:	b8 02 00 00 00       	mov    $0x2,%eax
  8012de:	e8 87 ff ff ff       	call   80126a <fsipc>
}
  8012e3:	c9                   	leave  
  8012e4:	c3                   	ret    

008012e5 <devfile_flush>:
{
  8012e5:	f3 0f 1e fb          	endbr32 
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8012ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8012f5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8012fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ff:	b8 06 00 00 00       	mov    $0x6,%eax
  801304:	e8 61 ff ff ff       	call   80126a <fsipc>
}
  801309:	c9                   	leave  
  80130a:	c3                   	ret    

0080130b <devfile_stat>:
{
  80130b:	f3 0f 1e fb          	endbr32 
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	53                   	push   %ebx
  801313:	83 ec 04             	sub    $0x4,%esp
  801316:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801319:	8b 45 08             	mov    0x8(%ebp),%eax
  80131c:	8b 40 0c             	mov    0xc(%eax),%eax
  80131f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801324:	ba 00 00 00 00       	mov    $0x0,%edx
  801329:	b8 05 00 00 00       	mov    $0x5,%eax
  80132e:	e8 37 ff ff ff       	call   80126a <fsipc>
  801333:	85 c0                	test   %eax,%eax
  801335:	78 2c                	js     801363 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801337:	83 ec 08             	sub    $0x8,%esp
  80133a:	68 00 50 80 00       	push   $0x805000
  80133f:	53                   	push   %ebx
  801340:	e8 8d f3 ff ff       	call   8006d2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801345:	a1 80 50 80 00       	mov    0x805080,%eax
  80134a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801350:	a1 84 50 80 00       	mov    0x805084,%eax
  801355:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801363:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801366:	c9                   	leave  
  801367:	c3                   	ret    

00801368 <devfile_write>:
{
  801368:	f3 0f 1e fb          	endbr32 
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	57                   	push   %edi
  801370:	56                   	push   %esi
  801371:	53                   	push   %ebx
  801372:	83 ec 0c             	sub    $0xc,%esp
  801375:	8b 75 0c             	mov    0xc(%ebp),%esi
  801378:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80137b:	8b 45 08             	mov    0x8(%ebp),%eax
  80137e:	8b 40 0c             	mov    0xc(%eax),%eax
  801381:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  801386:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80138b:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  801390:	85 db                	test   %ebx,%ebx
  801392:	74 3b                	je     8013cf <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801394:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  80139a:	89 f8                	mov    %edi,%eax
  80139c:	0f 46 c3             	cmovbe %ebx,%eax
  80139f:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  8013a4:	83 ec 04             	sub    $0x4,%esp
  8013a7:	50                   	push   %eax
  8013a8:	56                   	push   %esi
  8013a9:	68 08 50 80 00       	push   $0x805008
  8013ae:	e8 d7 f4 ff ff       	call   80088a <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8013b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b8:	b8 04 00 00 00       	mov    $0x4,%eax
  8013bd:	e8 a8 fe ff ff       	call   80126a <fsipc>
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 06                	js     8013cf <devfile_write+0x67>
		buf_aux += r;
  8013c9:	01 c6                	add    %eax,%esi
		n -= r;
  8013cb:	29 c3                	sub    %eax,%ebx
  8013cd:	eb c1                	jmp    801390 <devfile_write+0x28>
}
  8013cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d2:	5b                   	pop    %ebx
  8013d3:	5e                   	pop    %esi
  8013d4:	5f                   	pop    %edi
  8013d5:	5d                   	pop    %ebp
  8013d6:	c3                   	ret    

008013d7 <devfile_read>:
{
  8013d7:	f3 0f 1e fb          	endbr32 
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	56                   	push   %esi
  8013df:	53                   	push   %ebx
  8013e0:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013ee:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8013fe:	e8 67 fe ff ff       	call   80126a <fsipc>
  801403:	89 c3                	mov    %eax,%ebx
  801405:	85 c0                	test   %eax,%eax
  801407:	78 1f                	js     801428 <devfile_read+0x51>
	assert(r <= n);
  801409:	39 f0                	cmp    %esi,%eax
  80140b:	77 24                	ja     801431 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80140d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801412:	7f 33                	jg     801447 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801414:	83 ec 04             	sub    $0x4,%esp
  801417:	50                   	push   %eax
  801418:	68 00 50 80 00       	push   $0x805000
  80141d:	ff 75 0c             	pushl  0xc(%ebp)
  801420:	e8 65 f4 ff ff       	call   80088a <memmove>
	return r;
  801425:	83 c4 10             	add    $0x10,%esp
}
  801428:	89 d8                	mov    %ebx,%eax
  80142a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142d:	5b                   	pop    %ebx
  80142e:	5e                   	pop    %esi
  80142f:	5d                   	pop    %ebp
  801430:	c3                   	ret    
	assert(r <= n);
  801431:	68 f8 21 80 00       	push   $0x8021f8
  801436:	68 ff 21 80 00       	push   $0x8021ff
  80143b:	6a 7c                	push   $0x7c
  80143d:	68 14 22 80 00       	push   $0x802214
  801442:	e8 be 05 00 00       	call   801a05 <_panic>
	assert(r <= PGSIZE);
  801447:	68 1f 22 80 00       	push   $0x80221f
  80144c:	68 ff 21 80 00       	push   $0x8021ff
  801451:	6a 7d                	push   $0x7d
  801453:	68 14 22 80 00       	push   $0x802214
  801458:	e8 a8 05 00 00       	call   801a05 <_panic>

0080145d <open>:
{
  80145d:	f3 0f 1e fb          	endbr32 
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	56                   	push   %esi
  801465:	53                   	push   %ebx
  801466:	83 ec 1c             	sub    $0x1c,%esp
  801469:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80146c:	56                   	push   %esi
  80146d:	e8 1d f2 ff ff       	call   80068f <strlen>
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80147a:	7f 6c                	jg     8014e8 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80147c:	83 ec 0c             	sub    $0xc,%esp
  80147f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801482:	50                   	push   %eax
  801483:	e8 42 f8 ff ff       	call   800cca <fd_alloc>
  801488:	89 c3                	mov    %eax,%ebx
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 3c                	js     8014cd <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801491:	83 ec 08             	sub    $0x8,%esp
  801494:	56                   	push   %esi
  801495:	68 00 50 80 00       	push   $0x805000
  80149a:	e8 33 f2 ff ff       	call   8006d2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80149f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a2:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8014af:	e8 b6 fd ff ff       	call   80126a <fsipc>
  8014b4:	89 c3                	mov    %eax,%ebx
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 19                	js     8014d6 <open+0x79>
	return fd2num(fd);
  8014bd:	83 ec 0c             	sub    $0xc,%esp
  8014c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c3:	e8 cf f7 ff ff       	call   800c97 <fd2num>
  8014c8:	89 c3                	mov    %eax,%ebx
  8014ca:	83 c4 10             	add    $0x10,%esp
}
  8014cd:	89 d8                	mov    %ebx,%eax
  8014cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d2:	5b                   	pop    %ebx
  8014d3:	5e                   	pop    %esi
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    
		fd_close(fd, 0);
  8014d6:	83 ec 08             	sub    $0x8,%esp
  8014d9:	6a 00                	push   $0x0
  8014db:	ff 75 f4             	pushl  -0xc(%ebp)
  8014de:	e8 eb f8 ff ff       	call   800dce <fd_close>
		return r;
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	eb e5                	jmp    8014cd <open+0x70>
		return -E_BAD_PATH;
  8014e8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8014ed:	eb de                	jmp    8014cd <open+0x70>

008014ef <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014ef:	f3 0f 1e fb          	endbr32 
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fe:	b8 08 00 00 00       	mov    $0x8,%eax
  801503:	e8 62 fd ff ff       	call   80126a <fsipc>
}
  801508:	c9                   	leave  
  801509:	c3                   	ret    

0080150a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80150a:	f3 0f 1e fb          	endbr32 
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	56                   	push   %esi
  801512:	53                   	push   %ebx
  801513:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801516:	83 ec 0c             	sub    $0xc,%esp
  801519:	ff 75 08             	pushl  0x8(%ebp)
  80151c:	e8 8a f7 ff ff       	call   800cab <fd2data>
  801521:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801523:	83 c4 08             	add    $0x8,%esp
  801526:	68 2b 22 80 00       	push   $0x80222b
  80152b:	53                   	push   %ebx
  80152c:	e8 a1 f1 ff ff       	call   8006d2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801531:	8b 46 04             	mov    0x4(%esi),%eax
  801534:	2b 06                	sub    (%esi),%eax
  801536:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80153c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801543:	00 00 00 
	stat->st_dev = &devpipe;
  801546:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80154d:	30 80 00 
	return 0;
}
  801550:	b8 00 00 00 00       	mov    $0x0,%eax
  801555:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801558:	5b                   	pop    %ebx
  801559:	5e                   	pop    %esi
  80155a:	5d                   	pop    %ebp
  80155b:	c3                   	ret    

0080155c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80155c:	f3 0f 1e fb          	endbr32 
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	53                   	push   %ebx
  801564:	83 ec 0c             	sub    $0xc,%esp
  801567:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80156a:	53                   	push   %ebx
  80156b:	6a 00                	push   $0x0
  80156d:	e8 3a f6 ff ff       	call   800bac <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801572:	89 1c 24             	mov    %ebx,(%esp)
  801575:	e8 31 f7 ff ff       	call   800cab <fd2data>
  80157a:	83 c4 08             	add    $0x8,%esp
  80157d:	50                   	push   %eax
  80157e:	6a 00                	push   $0x0
  801580:	e8 27 f6 ff ff       	call   800bac <sys_page_unmap>
}
  801585:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801588:	c9                   	leave  
  801589:	c3                   	ret    

0080158a <_pipeisclosed>:
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	57                   	push   %edi
  80158e:	56                   	push   %esi
  80158f:	53                   	push   %ebx
  801590:	83 ec 1c             	sub    $0x1c,%esp
  801593:	89 c7                	mov    %eax,%edi
  801595:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801597:	a1 04 40 80 00       	mov    0x804004,%eax
  80159c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80159f:	83 ec 0c             	sub    $0xc,%esp
  8015a2:	57                   	push   %edi
  8015a3:	e8 a4 05 00 00       	call   801b4c <pageref>
  8015a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015ab:	89 34 24             	mov    %esi,(%esp)
  8015ae:	e8 99 05 00 00       	call   801b4c <pageref>
		nn = thisenv->env_runs;
  8015b3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015b9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	39 cb                	cmp    %ecx,%ebx
  8015c1:	74 1b                	je     8015de <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8015c3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015c6:	75 cf                	jne    801597 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015c8:	8b 42 58             	mov    0x58(%edx),%eax
  8015cb:	6a 01                	push   $0x1
  8015cd:	50                   	push   %eax
  8015ce:	53                   	push   %ebx
  8015cf:	68 32 22 80 00       	push   $0x802232
  8015d4:	e8 8f eb ff ff       	call   800168 <cprintf>
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	eb b9                	jmp    801597 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8015de:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015e1:	0f 94 c0             	sete   %al
  8015e4:	0f b6 c0             	movzbl %al,%eax
}
  8015e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ea:	5b                   	pop    %ebx
  8015eb:	5e                   	pop    %esi
  8015ec:	5f                   	pop    %edi
  8015ed:	5d                   	pop    %ebp
  8015ee:	c3                   	ret    

008015ef <devpipe_write>:
{
  8015ef:	f3 0f 1e fb          	endbr32 
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	57                   	push   %edi
  8015f7:	56                   	push   %esi
  8015f8:	53                   	push   %ebx
  8015f9:	83 ec 28             	sub    $0x28,%esp
  8015fc:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8015ff:	56                   	push   %esi
  801600:	e8 a6 f6 ff ff       	call   800cab <fd2data>
  801605:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	bf 00 00 00 00       	mov    $0x0,%edi
  80160f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801612:	74 4f                	je     801663 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801614:	8b 43 04             	mov    0x4(%ebx),%eax
  801617:	8b 0b                	mov    (%ebx),%ecx
  801619:	8d 51 20             	lea    0x20(%ecx),%edx
  80161c:	39 d0                	cmp    %edx,%eax
  80161e:	72 14                	jb     801634 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801620:	89 da                	mov    %ebx,%edx
  801622:	89 f0                	mov    %esi,%eax
  801624:	e8 61 ff ff ff       	call   80158a <_pipeisclosed>
  801629:	85 c0                	test   %eax,%eax
  80162b:	75 3b                	jne    801668 <devpipe_write+0x79>
			sys_yield();
  80162d:	e8 fd f4 ff ff       	call   800b2f <sys_yield>
  801632:	eb e0                	jmp    801614 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801634:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801637:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80163b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80163e:	89 c2                	mov    %eax,%edx
  801640:	c1 fa 1f             	sar    $0x1f,%edx
  801643:	89 d1                	mov    %edx,%ecx
  801645:	c1 e9 1b             	shr    $0x1b,%ecx
  801648:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80164b:	83 e2 1f             	and    $0x1f,%edx
  80164e:	29 ca                	sub    %ecx,%edx
  801650:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801654:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801658:	83 c0 01             	add    $0x1,%eax
  80165b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80165e:	83 c7 01             	add    $0x1,%edi
  801661:	eb ac                	jmp    80160f <devpipe_write+0x20>
	return i;
  801663:	8b 45 10             	mov    0x10(%ebp),%eax
  801666:	eb 05                	jmp    80166d <devpipe_write+0x7e>
				return 0;
  801668:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80166d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801670:	5b                   	pop    %ebx
  801671:	5e                   	pop    %esi
  801672:	5f                   	pop    %edi
  801673:	5d                   	pop    %ebp
  801674:	c3                   	ret    

00801675 <devpipe_read>:
{
  801675:	f3 0f 1e fb          	endbr32 
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
  80167c:	57                   	push   %edi
  80167d:	56                   	push   %esi
  80167e:	53                   	push   %ebx
  80167f:	83 ec 18             	sub    $0x18,%esp
  801682:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801685:	57                   	push   %edi
  801686:	e8 20 f6 ff ff       	call   800cab <fd2data>
  80168b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	be 00 00 00 00       	mov    $0x0,%esi
  801695:	3b 75 10             	cmp    0x10(%ebp),%esi
  801698:	75 14                	jne    8016ae <devpipe_read+0x39>
	return i;
  80169a:	8b 45 10             	mov    0x10(%ebp),%eax
  80169d:	eb 02                	jmp    8016a1 <devpipe_read+0x2c>
				return i;
  80169f:	89 f0                	mov    %esi,%eax
}
  8016a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a4:	5b                   	pop    %ebx
  8016a5:	5e                   	pop    %esi
  8016a6:	5f                   	pop    %edi
  8016a7:	5d                   	pop    %ebp
  8016a8:	c3                   	ret    
			sys_yield();
  8016a9:	e8 81 f4 ff ff       	call   800b2f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8016ae:	8b 03                	mov    (%ebx),%eax
  8016b0:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016b3:	75 18                	jne    8016cd <devpipe_read+0x58>
			if (i > 0)
  8016b5:	85 f6                	test   %esi,%esi
  8016b7:	75 e6                	jne    80169f <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8016b9:	89 da                	mov    %ebx,%edx
  8016bb:	89 f8                	mov    %edi,%eax
  8016bd:	e8 c8 fe ff ff       	call   80158a <_pipeisclosed>
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	74 e3                	je     8016a9 <devpipe_read+0x34>
				return 0;
  8016c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016cb:	eb d4                	jmp    8016a1 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016cd:	99                   	cltd   
  8016ce:	c1 ea 1b             	shr    $0x1b,%edx
  8016d1:	01 d0                	add    %edx,%eax
  8016d3:	83 e0 1f             	and    $0x1f,%eax
  8016d6:	29 d0                	sub    %edx,%eax
  8016d8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8016dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e0:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8016e3:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8016e6:	83 c6 01             	add    $0x1,%esi
  8016e9:	eb aa                	jmp    801695 <devpipe_read+0x20>

008016eb <pipe>:
{
  8016eb:	f3 0f 1e fb          	endbr32 
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	56                   	push   %esi
  8016f3:	53                   	push   %ebx
  8016f4:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8016f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fa:	50                   	push   %eax
  8016fb:	e8 ca f5 ff ff       	call   800cca <fd_alloc>
  801700:	89 c3                	mov    %eax,%ebx
  801702:	83 c4 10             	add    $0x10,%esp
  801705:	85 c0                	test   %eax,%eax
  801707:	0f 88 23 01 00 00    	js     801830 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80170d:	83 ec 04             	sub    $0x4,%esp
  801710:	68 07 04 00 00       	push   $0x407
  801715:	ff 75 f4             	pushl  -0xc(%ebp)
  801718:	6a 00                	push   $0x0
  80171a:	e8 3b f4 ff ff       	call   800b5a <sys_page_alloc>
  80171f:	89 c3                	mov    %eax,%ebx
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	85 c0                	test   %eax,%eax
  801726:	0f 88 04 01 00 00    	js     801830 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80172c:	83 ec 0c             	sub    $0xc,%esp
  80172f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801732:	50                   	push   %eax
  801733:	e8 92 f5 ff ff       	call   800cca <fd_alloc>
  801738:	89 c3                	mov    %eax,%ebx
  80173a:	83 c4 10             	add    $0x10,%esp
  80173d:	85 c0                	test   %eax,%eax
  80173f:	0f 88 db 00 00 00    	js     801820 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801745:	83 ec 04             	sub    $0x4,%esp
  801748:	68 07 04 00 00       	push   $0x407
  80174d:	ff 75 f0             	pushl  -0x10(%ebp)
  801750:	6a 00                	push   $0x0
  801752:	e8 03 f4 ff ff       	call   800b5a <sys_page_alloc>
  801757:	89 c3                	mov    %eax,%ebx
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	85 c0                	test   %eax,%eax
  80175e:	0f 88 bc 00 00 00    	js     801820 <pipe+0x135>
	va = fd2data(fd0);
  801764:	83 ec 0c             	sub    $0xc,%esp
  801767:	ff 75 f4             	pushl  -0xc(%ebp)
  80176a:	e8 3c f5 ff ff       	call   800cab <fd2data>
  80176f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801771:	83 c4 0c             	add    $0xc,%esp
  801774:	68 07 04 00 00       	push   $0x407
  801779:	50                   	push   %eax
  80177a:	6a 00                	push   $0x0
  80177c:	e8 d9 f3 ff ff       	call   800b5a <sys_page_alloc>
  801781:	89 c3                	mov    %eax,%ebx
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	85 c0                	test   %eax,%eax
  801788:	0f 88 82 00 00 00    	js     801810 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80178e:	83 ec 0c             	sub    $0xc,%esp
  801791:	ff 75 f0             	pushl  -0x10(%ebp)
  801794:	e8 12 f5 ff ff       	call   800cab <fd2data>
  801799:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017a0:	50                   	push   %eax
  8017a1:	6a 00                	push   $0x0
  8017a3:	56                   	push   %esi
  8017a4:	6a 00                	push   $0x0
  8017a6:	e8 d7 f3 ff ff       	call   800b82 <sys_page_map>
  8017ab:	89 c3                	mov    %eax,%ebx
  8017ad:	83 c4 20             	add    $0x20,%esp
  8017b0:	85 c0                	test   %eax,%eax
  8017b2:	78 4e                	js     801802 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8017b4:	a1 20 30 80 00       	mov    0x803020,%eax
  8017b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017bc:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8017be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017c1:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8017c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017cb:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8017cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8017d7:	83 ec 0c             	sub    $0xc,%esp
  8017da:	ff 75 f4             	pushl  -0xc(%ebp)
  8017dd:	e8 b5 f4 ff ff       	call   800c97 <fd2num>
  8017e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017e7:	83 c4 04             	add    $0x4,%esp
  8017ea:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ed:	e8 a5 f4 ff ff       	call   800c97 <fd2num>
  8017f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017f5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801800:	eb 2e                	jmp    801830 <pipe+0x145>
	sys_page_unmap(0, va);
  801802:	83 ec 08             	sub    $0x8,%esp
  801805:	56                   	push   %esi
  801806:	6a 00                	push   $0x0
  801808:	e8 9f f3 ff ff       	call   800bac <sys_page_unmap>
  80180d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801810:	83 ec 08             	sub    $0x8,%esp
  801813:	ff 75 f0             	pushl  -0x10(%ebp)
  801816:	6a 00                	push   $0x0
  801818:	e8 8f f3 ff ff       	call   800bac <sys_page_unmap>
  80181d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801820:	83 ec 08             	sub    $0x8,%esp
  801823:	ff 75 f4             	pushl  -0xc(%ebp)
  801826:	6a 00                	push   $0x0
  801828:	e8 7f f3 ff ff       	call   800bac <sys_page_unmap>
  80182d:	83 c4 10             	add    $0x10,%esp
}
  801830:	89 d8                	mov    %ebx,%eax
  801832:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801835:	5b                   	pop    %ebx
  801836:	5e                   	pop    %esi
  801837:	5d                   	pop    %ebp
  801838:	c3                   	ret    

00801839 <pipeisclosed>:
{
  801839:	f3 0f 1e fb          	endbr32 
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801843:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801846:	50                   	push   %eax
  801847:	ff 75 08             	pushl  0x8(%ebp)
  80184a:	e8 d1 f4 ff ff       	call   800d20 <fd_lookup>
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	85 c0                	test   %eax,%eax
  801854:	78 18                	js     80186e <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801856:	83 ec 0c             	sub    $0xc,%esp
  801859:	ff 75 f4             	pushl  -0xc(%ebp)
  80185c:	e8 4a f4 ff ff       	call   800cab <fd2data>
  801861:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801863:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801866:	e8 1f fd ff ff       	call   80158a <_pipeisclosed>
  80186b:	83 c4 10             	add    $0x10,%esp
}
  80186e:	c9                   	leave  
  80186f:	c3                   	ret    

00801870 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801870:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801874:	b8 00 00 00 00       	mov    $0x0,%eax
  801879:	c3                   	ret    

0080187a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80187a:	f3 0f 1e fb          	endbr32 
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801884:	68 4a 22 80 00       	push   $0x80224a
  801889:	ff 75 0c             	pushl  0xc(%ebp)
  80188c:	e8 41 ee ff ff       	call   8006d2 <strcpy>
	return 0;
}
  801891:	b8 00 00 00 00       	mov    $0x0,%eax
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <devcons_write>:
{
  801898:	f3 0f 1e fb          	endbr32 
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	57                   	push   %edi
  8018a0:	56                   	push   %esi
  8018a1:	53                   	push   %ebx
  8018a2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8018a8:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8018ad:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8018b3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018b6:	73 31                	jae    8018e9 <devcons_write+0x51>
		m = n - tot;
  8018b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018bb:	29 f3                	sub    %esi,%ebx
  8018bd:	83 fb 7f             	cmp    $0x7f,%ebx
  8018c0:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8018c5:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8018c8:	83 ec 04             	sub    $0x4,%esp
  8018cb:	53                   	push   %ebx
  8018cc:	89 f0                	mov    %esi,%eax
  8018ce:	03 45 0c             	add    0xc(%ebp),%eax
  8018d1:	50                   	push   %eax
  8018d2:	57                   	push   %edi
  8018d3:	e8 b2 ef ff ff       	call   80088a <memmove>
		sys_cputs(buf, m);
  8018d8:	83 c4 08             	add    $0x8,%esp
  8018db:	53                   	push   %ebx
  8018dc:	57                   	push   %edi
  8018dd:	e8 ad f1 ff ff       	call   800a8f <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8018e2:	01 de                	add    %ebx,%esi
  8018e4:	83 c4 10             	add    $0x10,%esp
  8018e7:	eb ca                	jmp    8018b3 <devcons_write+0x1b>
}
  8018e9:	89 f0                	mov    %esi,%eax
  8018eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ee:	5b                   	pop    %ebx
  8018ef:	5e                   	pop    %esi
  8018f0:	5f                   	pop    %edi
  8018f1:	5d                   	pop    %ebp
  8018f2:	c3                   	ret    

008018f3 <devcons_read>:
{
  8018f3:	f3 0f 1e fb          	endbr32 
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	83 ec 08             	sub    $0x8,%esp
  8018fd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801902:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801906:	74 21                	je     801929 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801908:	e8 ac f1 ff ff       	call   800ab9 <sys_cgetc>
  80190d:	85 c0                	test   %eax,%eax
  80190f:	75 07                	jne    801918 <devcons_read+0x25>
		sys_yield();
  801911:	e8 19 f2 ff ff       	call   800b2f <sys_yield>
  801916:	eb f0                	jmp    801908 <devcons_read+0x15>
	if (c < 0)
  801918:	78 0f                	js     801929 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80191a:	83 f8 04             	cmp    $0x4,%eax
  80191d:	74 0c                	je     80192b <devcons_read+0x38>
	*(char*)vbuf = c;
  80191f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801922:	88 02                	mov    %al,(%edx)
	return 1;
  801924:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801929:	c9                   	leave  
  80192a:	c3                   	ret    
		return 0;
  80192b:	b8 00 00 00 00       	mov    $0x0,%eax
  801930:	eb f7                	jmp    801929 <devcons_read+0x36>

00801932 <cputchar>:
{
  801932:	f3 0f 1e fb          	endbr32 
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80193c:	8b 45 08             	mov    0x8(%ebp),%eax
  80193f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801942:	6a 01                	push   $0x1
  801944:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801947:	50                   	push   %eax
  801948:	e8 42 f1 ff ff       	call   800a8f <sys_cputs>
}
  80194d:	83 c4 10             	add    $0x10,%esp
  801950:	c9                   	leave  
  801951:	c3                   	ret    

00801952 <getchar>:
{
  801952:	f3 0f 1e fb          	endbr32 
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80195c:	6a 01                	push   $0x1
  80195e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801961:	50                   	push   %eax
  801962:	6a 00                	push   $0x0
  801964:	e8 3a f6 ff ff       	call   800fa3 <read>
	if (r < 0)
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	85 c0                	test   %eax,%eax
  80196e:	78 06                	js     801976 <getchar+0x24>
	if (r < 1)
  801970:	74 06                	je     801978 <getchar+0x26>
	return c;
  801972:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801976:	c9                   	leave  
  801977:	c3                   	ret    
		return -E_EOF;
  801978:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80197d:	eb f7                	jmp    801976 <getchar+0x24>

0080197f <iscons>:
{
  80197f:	f3 0f 1e fb          	endbr32 
  801983:	55                   	push   %ebp
  801984:	89 e5                	mov    %esp,%ebp
  801986:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801989:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198c:	50                   	push   %eax
  80198d:	ff 75 08             	pushl  0x8(%ebp)
  801990:	e8 8b f3 ff ff       	call   800d20 <fd_lookup>
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	85 c0                	test   %eax,%eax
  80199a:	78 11                	js     8019ad <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80199c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019a5:	39 10                	cmp    %edx,(%eax)
  8019a7:	0f 94 c0             	sete   %al
  8019aa:	0f b6 c0             	movzbl %al,%eax
}
  8019ad:	c9                   	leave  
  8019ae:	c3                   	ret    

008019af <opencons>:
{
  8019af:	f3 0f 1e fb          	endbr32 
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8019b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bc:	50                   	push   %eax
  8019bd:	e8 08 f3 ff ff       	call   800cca <fd_alloc>
  8019c2:	83 c4 10             	add    $0x10,%esp
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	78 3a                	js     801a03 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019c9:	83 ec 04             	sub    $0x4,%esp
  8019cc:	68 07 04 00 00       	push   $0x407
  8019d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d4:	6a 00                	push   $0x0
  8019d6:	e8 7f f1 ff ff       	call   800b5a <sys_page_alloc>
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	85 c0                	test   %eax,%eax
  8019e0:	78 21                	js     801a03 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8019e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019eb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019f7:	83 ec 0c             	sub    $0xc,%esp
  8019fa:	50                   	push   %eax
  8019fb:	e8 97 f2 ff ff       	call   800c97 <fd2num>
  801a00:	83 c4 10             	add    $0x10,%esp
}
  801a03:	c9                   	leave  
  801a04:	c3                   	ret    

00801a05 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a05:	f3 0f 1e fb          	endbr32 
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	56                   	push   %esi
  801a0d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a0e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a11:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a17:	e8 eb f0 ff ff       	call   800b07 <sys_getenvid>
  801a1c:	83 ec 0c             	sub    $0xc,%esp
  801a1f:	ff 75 0c             	pushl  0xc(%ebp)
  801a22:	ff 75 08             	pushl  0x8(%ebp)
  801a25:	56                   	push   %esi
  801a26:	50                   	push   %eax
  801a27:	68 58 22 80 00       	push   $0x802258
  801a2c:	e8 37 e7 ff ff       	call   800168 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a31:	83 c4 18             	add    $0x18,%esp
  801a34:	53                   	push   %ebx
  801a35:	ff 75 10             	pushl  0x10(%ebp)
  801a38:	e8 d6 e6 ff ff       	call   800113 <vcprintf>
	cprintf("\n");
  801a3d:	c7 04 24 43 22 80 00 	movl   $0x802243,(%esp)
  801a44:	e8 1f e7 ff ff       	call   800168 <cprintf>
  801a49:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a4c:	cc                   	int3   
  801a4d:	eb fd                	jmp    801a4c <_panic+0x47>

00801a4f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a4f:	f3 0f 1e fb          	endbr32 
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	56                   	push   %esi
  801a57:	53                   	push   %ebx
  801a58:	8b 75 08             	mov    0x8(%ebp),%esi
  801a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  801a61:	85 c0                	test   %eax,%eax
  801a63:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a68:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801a6b:	83 ec 0c             	sub    $0xc,%esp
  801a6e:	50                   	push   %eax
  801a6f:	e8 fd f1 ff ff       	call   800c71 <sys_ipc_recv>
	if (f < 0) {
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	85 c0                	test   %eax,%eax
  801a79:	78 2b                	js     801aa6 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801a7b:	85 f6                	test   %esi,%esi
  801a7d:	74 0a                	je     801a89 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801a7f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a84:	8b 40 74             	mov    0x74(%eax),%eax
  801a87:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801a89:	85 db                	test   %ebx,%ebx
  801a8b:	74 0a                	je     801a97 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801a8d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a92:	8b 40 78             	mov    0x78(%eax),%eax
  801a95:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  801a97:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9c:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa2:	5b                   	pop    %ebx
  801aa3:	5e                   	pop    %esi
  801aa4:	5d                   	pop    %ebp
  801aa5:	c3                   	ret    
		if (from_env_store != NULL) {
  801aa6:	85 f6                	test   %esi,%esi
  801aa8:	74 06                	je     801ab0 <ipc_recv+0x61>
			*from_env_store = 0;
  801aaa:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801ab0:	85 db                	test   %ebx,%ebx
  801ab2:	74 eb                	je     801a9f <ipc_recv+0x50>
			*perm_store = 0;
  801ab4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aba:	eb e3                	jmp    801a9f <ipc_recv+0x50>

00801abc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801abc:	f3 0f 1e fb          	endbr32 
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	57                   	push   %edi
  801ac4:	56                   	push   %esi
  801ac5:	53                   	push   %ebx
  801ac6:	83 ec 0c             	sub    $0xc,%esp
  801ac9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801acc:	8b 75 0c             	mov    0xc(%ebp),%esi
  801acf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  801ad2:	85 db                	test   %ebx,%ebx
  801ad4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ad9:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801adc:	ff 75 14             	pushl  0x14(%ebp)
  801adf:	53                   	push   %ebx
  801ae0:	56                   	push   %esi
  801ae1:	57                   	push   %edi
  801ae2:	e8 61 f1 ff ff       	call   800c48 <sys_ipc_try_send>
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	85 c0                	test   %eax,%eax
  801aec:	79 19                	jns    801b07 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  801aee:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801af1:	74 e9                	je     801adc <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  801af3:	83 ec 04             	sub    $0x4,%esp
  801af6:	68 7c 22 80 00       	push   $0x80227c
  801afb:	6a 48                	push   $0x48
  801afd:	68 9e 22 80 00       	push   $0x80229e
  801b02:	e8 fe fe ff ff       	call   801a05 <_panic>
		}
	}
}
  801b07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0a:	5b                   	pop    %ebx
  801b0b:	5e                   	pop    %esi
  801b0c:	5f                   	pop    %edi
  801b0d:	5d                   	pop    %ebp
  801b0e:	c3                   	ret    

00801b0f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b0f:	f3 0f 1e fb          	endbr32 
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b19:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b1e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b21:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b27:	8b 52 50             	mov    0x50(%edx),%edx
  801b2a:	39 ca                	cmp    %ecx,%edx
  801b2c:	74 11                	je     801b3f <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801b2e:	83 c0 01             	add    $0x1,%eax
  801b31:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b36:	75 e6                	jne    801b1e <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b38:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3d:	eb 0b                	jmp    801b4a <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b3f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b42:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b47:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b4c:	f3 0f 1e fb          	endbr32 
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b56:	89 c2                	mov    %eax,%edx
  801b58:	c1 ea 16             	shr    $0x16,%edx
  801b5b:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b62:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b67:	f6 c1 01             	test   $0x1,%cl
  801b6a:	74 1c                	je     801b88 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b6c:	c1 e8 0c             	shr    $0xc,%eax
  801b6f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b76:	a8 01                	test   $0x1,%al
  801b78:	74 0e                	je     801b88 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b7a:	c1 e8 0c             	shr    $0xc,%eax
  801b7d:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b84:	ef 
  801b85:	0f b7 d2             	movzwl %dx,%edx
}
  801b88:	89 d0                	mov    %edx,%eax
  801b8a:	5d                   	pop    %ebp
  801b8b:	c3                   	ret    
  801b8c:	66 90                	xchg   %ax,%ax
  801b8e:	66 90                	xchg   %ax,%ax

00801b90 <__udivdi3>:
  801b90:	f3 0f 1e fb          	endbr32 
  801b94:	55                   	push   %ebp
  801b95:	57                   	push   %edi
  801b96:	56                   	push   %esi
  801b97:	53                   	push   %ebx
  801b98:	83 ec 1c             	sub    $0x1c,%esp
  801b9b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b9f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801ba3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ba7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801bab:	85 d2                	test   %edx,%edx
  801bad:	75 19                	jne    801bc8 <__udivdi3+0x38>
  801baf:	39 f3                	cmp    %esi,%ebx
  801bb1:	76 4d                	jbe    801c00 <__udivdi3+0x70>
  801bb3:	31 ff                	xor    %edi,%edi
  801bb5:	89 e8                	mov    %ebp,%eax
  801bb7:	89 f2                	mov    %esi,%edx
  801bb9:	f7 f3                	div    %ebx
  801bbb:	89 fa                	mov    %edi,%edx
  801bbd:	83 c4 1c             	add    $0x1c,%esp
  801bc0:	5b                   	pop    %ebx
  801bc1:	5e                   	pop    %esi
  801bc2:	5f                   	pop    %edi
  801bc3:	5d                   	pop    %ebp
  801bc4:	c3                   	ret    
  801bc5:	8d 76 00             	lea    0x0(%esi),%esi
  801bc8:	39 f2                	cmp    %esi,%edx
  801bca:	76 14                	jbe    801be0 <__udivdi3+0x50>
  801bcc:	31 ff                	xor    %edi,%edi
  801bce:	31 c0                	xor    %eax,%eax
  801bd0:	89 fa                	mov    %edi,%edx
  801bd2:	83 c4 1c             	add    $0x1c,%esp
  801bd5:	5b                   	pop    %ebx
  801bd6:	5e                   	pop    %esi
  801bd7:	5f                   	pop    %edi
  801bd8:	5d                   	pop    %ebp
  801bd9:	c3                   	ret    
  801bda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801be0:	0f bd fa             	bsr    %edx,%edi
  801be3:	83 f7 1f             	xor    $0x1f,%edi
  801be6:	75 48                	jne    801c30 <__udivdi3+0xa0>
  801be8:	39 f2                	cmp    %esi,%edx
  801bea:	72 06                	jb     801bf2 <__udivdi3+0x62>
  801bec:	31 c0                	xor    %eax,%eax
  801bee:	39 eb                	cmp    %ebp,%ebx
  801bf0:	77 de                	ja     801bd0 <__udivdi3+0x40>
  801bf2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf7:	eb d7                	jmp    801bd0 <__udivdi3+0x40>
  801bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c00:	89 d9                	mov    %ebx,%ecx
  801c02:	85 db                	test   %ebx,%ebx
  801c04:	75 0b                	jne    801c11 <__udivdi3+0x81>
  801c06:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0b:	31 d2                	xor    %edx,%edx
  801c0d:	f7 f3                	div    %ebx
  801c0f:	89 c1                	mov    %eax,%ecx
  801c11:	31 d2                	xor    %edx,%edx
  801c13:	89 f0                	mov    %esi,%eax
  801c15:	f7 f1                	div    %ecx
  801c17:	89 c6                	mov    %eax,%esi
  801c19:	89 e8                	mov    %ebp,%eax
  801c1b:	89 f7                	mov    %esi,%edi
  801c1d:	f7 f1                	div    %ecx
  801c1f:	89 fa                	mov    %edi,%edx
  801c21:	83 c4 1c             	add    $0x1c,%esp
  801c24:	5b                   	pop    %ebx
  801c25:	5e                   	pop    %esi
  801c26:	5f                   	pop    %edi
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	89 f9                	mov    %edi,%ecx
  801c32:	b8 20 00 00 00       	mov    $0x20,%eax
  801c37:	29 f8                	sub    %edi,%eax
  801c39:	d3 e2                	shl    %cl,%edx
  801c3b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c3f:	89 c1                	mov    %eax,%ecx
  801c41:	89 da                	mov    %ebx,%edx
  801c43:	d3 ea                	shr    %cl,%edx
  801c45:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c49:	09 d1                	or     %edx,%ecx
  801c4b:	89 f2                	mov    %esi,%edx
  801c4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c51:	89 f9                	mov    %edi,%ecx
  801c53:	d3 e3                	shl    %cl,%ebx
  801c55:	89 c1                	mov    %eax,%ecx
  801c57:	d3 ea                	shr    %cl,%edx
  801c59:	89 f9                	mov    %edi,%ecx
  801c5b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c5f:	89 eb                	mov    %ebp,%ebx
  801c61:	d3 e6                	shl    %cl,%esi
  801c63:	89 c1                	mov    %eax,%ecx
  801c65:	d3 eb                	shr    %cl,%ebx
  801c67:	09 de                	or     %ebx,%esi
  801c69:	89 f0                	mov    %esi,%eax
  801c6b:	f7 74 24 08          	divl   0x8(%esp)
  801c6f:	89 d6                	mov    %edx,%esi
  801c71:	89 c3                	mov    %eax,%ebx
  801c73:	f7 64 24 0c          	mull   0xc(%esp)
  801c77:	39 d6                	cmp    %edx,%esi
  801c79:	72 15                	jb     801c90 <__udivdi3+0x100>
  801c7b:	89 f9                	mov    %edi,%ecx
  801c7d:	d3 e5                	shl    %cl,%ebp
  801c7f:	39 c5                	cmp    %eax,%ebp
  801c81:	73 04                	jae    801c87 <__udivdi3+0xf7>
  801c83:	39 d6                	cmp    %edx,%esi
  801c85:	74 09                	je     801c90 <__udivdi3+0x100>
  801c87:	89 d8                	mov    %ebx,%eax
  801c89:	31 ff                	xor    %edi,%edi
  801c8b:	e9 40 ff ff ff       	jmp    801bd0 <__udivdi3+0x40>
  801c90:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c93:	31 ff                	xor    %edi,%edi
  801c95:	e9 36 ff ff ff       	jmp    801bd0 <__udivdi3+0x40>
  801c9a:	66 90                	xchg   %ax,%ax
  801c9c:	66 90                	xchg   %ax,%ax
  801c9e:	66 90                	xchg   %ax,%ax

00801ca0 <__umoddi3>:
  801ca0:	f3 0f 1e fb          	endbr32 
  801ca4:	55                   	push   %ebp
  801ca5:	57                   	push   %edi
  801ca6:	56                   	push   %esi
  801ca7:	53                   	push   %ebx
  801ca8:	83 ec 1c             	sub    $0x1c,%esp
  801cab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801caf:	8b 74 24 30          	mov    0x30(%esp),%esi
  801cb3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801cb7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	75 19                	jne    801cd8 <__umoddi3+0x38>
  801cbf:	39 df                	cmp    %ebx,%edi
  801cc1:	76 5d                	jbe    801d20 <__umoddi3+0x80>
  801cc3:	89 f0                	mov    %esi,%eax
  801cc5:	89 da                	mov    %ebx,%edx
  801cc7:	f7 f7                	div    %edi
  801cc9:	89 d0                	mov    %edx,%eax
  801ccb:	31 d2                	xor    %edx,%edx
  801ccd:	83 c4 1c             	add    $0x1c,%esp
  801cd0:	5b                   	pop    %ebx
  801cd1:	5e                   	pop    %esi
  801cd2:	5f                   	pop    %edi
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    
  801cd5:	8d 76 00             	lea    0x0(%esi),%esi
  801cd8:	89 f2                	mov    %esi,%edx
  801cda:	39 d8                	cmp    %ebx,%eax
  801cdc:	76 12                	jbe    801cf0 <__umoddi3+0x50>
  801cde:	89 f0                	mov    %esi,%eax
  801ce0:	89 da                	mov    %ebx,%edx
  801ce2:	83 c4 1c             	add    $0x1c,%esp
  801ce5:	5b                   	pop    %ebx
  801ce6:	5e                   	pop    %esi
  801ce7:	5f                   	pop    %edi
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    
  801cea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf0:	0f bd e8             	bsr    %eax,%ebp
  801cf3:	83 f5 1f             	xor    $0x1f,%ebp
  801cf6:	75 50                	jne    801d48 <__umoddi3+0xa8>
  801cf8:	39 d8                	cmp    %ebx,%eax
  801cfa:	0f 82 e0 00 00 00    	jb     801de0 <__umoddi3+0x140>
  801d00:	89 d9                	mov    %ebx,%ecx
  801d02:	39 f7                	cmp    %esi,%edi
  801d04:	0f 86 d6 00 00 00    	jbe    801de0 <__umoddi3+0x140>
  801d0a:	89 d0                	mov    %edx,%eax
  801d0c:	89 ca                	mov    %ecx,%edx
  801d0e:	83 c4 1c             	add    $0x1c,%esp
  801d11:	5b                   	pop    %ebx
  801d12:	5e                   	pop    %esi
  801d13:	5f                   	pop    %edi
  801d14:	5d                   	pop    %ebp
  801d15:	c3                   	ret    
  801d16:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d1d:	8d 76 00             	lea    0x0(%esi),%esi
  801d20:	89 fd                	mov    %edi,%ebp
  801d22:	85 ff                	test   %edi,%edi
  801d24:	75 0b                	jne    801d31 <__umoddi3+0x91>
  801d26:	b8 01 00 00 00       	mov    $0x1,%eax
  801d2b:	31 d2                	xor    %edx,%edx
  801d2d:	f7 f7                	div    %edi
  801d2f:	89 c5                	mov    %eax,%ebp
  801d31:	89 d8                	mov    %ebx,%eax
  801d33:	31 d2                	xor    %edx,%edx
  801d35:	f7 f5                	div    %ebp
  801d37:	89 f0                	mov    %esi,%eax
  801d39:	f7 f5                	div    %ebp
  801d3b:	89 d0                	mov    %edx,%eax
  801d3d:	31 d2                	xor    %edx,%edx
  801d3f:	eb 8c                	jmp    801ccd <__umoddi3+0x2d>
  801d41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d48:	89 e9                	mov    %ebp,%ecx
  801d4a:	ba 20 00 00 00       	mov    $0x20,%edx
  801d4f:	29 ea                	sub    %ebp,%edx
  801d51:	d3 e0                	shl    %cl,%eax
  801d53:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d57:	89 d1                	mov    %edx,%ecx
  801d59:	89 f8                	mov    %edi,%eax
  801d5b:	d3 e8                	shr    %cl,%eax
  801d5d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d61:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d65:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d69:	09 c1                	or     %eax,%ecx
  801d6b:	89 d8                	mov    %ebx,%eax
  801d6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d71:	89 e9                	mov    %ebp,%ecx
  801d73:	d3 e7                	shl    %cl,%edi
  801d75:	89 d1                	mov    %edx,%ecx
  801d77:	d3 e8                	shr    %cl,%eax
  801d79:	89 e9                	mov    %ebp,%ecx
  801d7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d7f:	d3 e3                	shl    %cl,%ebx
  801d81:	89 c7                	mov    %eax,%edi
  801d83:	89 d1                	mov    %edx,%ecx
  801d85:	89 f0                	mov    %esi,%eax
  801d87:	d3 e8                	shr    %cl,%eax
  801d89:	89 e9                	mov    %ebp,%ecx
  801d8b:	89 fa                	mov    %edi,%edx
  801d8d:	d3 e6                	shl    %cl,%esi
  801d8f:	09 d8                	or     %ebx,%eax
  801d91:	f7 74 24 08          	divl   0x8(%esp)
  801d95:	89 d1                	mov    %edx,%ecx
  801d97:	89 f3                	mov    %esi,%ebx
  801d99:	f7 64 24 0c          	mull   0xc(%esp)
  801d9d:	89 c6                	mov    %eax,%esi
  801d9f:	89 d7                	mov    %edx,%edi
  801da1:	39 d1                	cmp    %edx,%ecx
  801da3:	72 06                	jb     801dab <__umoddi3+0x10b>
  801da5:	75 10                	jne    801db7 <__umoddi3+0x117>
  801da7:	39 c3                	cmp    %eax,%ebx
  801da9:	73 0c                	jae    801db7 <__umoddi3+0x117>
  801dab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801daf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801db3:	89 d7                	mov    %edx,%edi
  801db5:	89 c6                	mov    %eax,%esi
  801db7:	89 ca                	mov    %ecx,%edx
  801db9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801dbe:	29 f3                	sub    %esi,%ebx
  801dc0:	19 fa                	sbb    %edi,%edx
  801dc2:	89 d0                	mov    %edx,%eax
  801dc4:	d3 e0                	shl    %cl,%eax
  801dc6:	89 e9                	mov    %ebp,%ecx
  801dc8:	d3 eb                	shr    %cl,%ebx
  801dca:	d3 ea                	shr    %cl,%edx
  801dcc:	09 d8                	or     %ebx,%eax
  801dce:	83 c4 1c             	add    $0x1c,%esp
  801dd1:	5b                   	pop    %ebx
  801dd2:	5e                   	pop    %esi
  801dd3:	5f                   	pop    %edi
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    
  801dd6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ddd:	8d 76 00             	lea    0x0(%esi),%esi
  801de0:	29 fe                	sub    %edi,%esi
  801de2:	19 c3                	sbb    %eax,%ebx
  801de4:	89 f2                	mov    %esi,%edx
  801de6:	89 d9                	mov    %ebx,%ecx
  801de8:	e9 1d ff ff ff       	jmp    801d0a <__umoddi3+0x6a>
