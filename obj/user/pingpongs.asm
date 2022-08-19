
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 d6 00 00 00       	call   800107 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  800040:	e8 a4 11 00 00       	call   8011e9 <sfork>
  800045:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800048:	85 c0                	test   %eax,%eax
  80004a:	75 74                	jne    8000c0 <umain+0x8d>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80004c:	83 ec 04             	sub    $0x4,%esp
  80004f:	6a 00                	push   $0x0
  800051:	6a 00                	push   $0x0
  800053:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 ab 11 00 00       	call   801207 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80005c:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  800062:	8b 7b 48             	mov    0x48(%ebx),%edi
  800065:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800068:	a1 04 40 80 00       	mov    0x804004,%eax
  80006d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800070:	e8 3a 0b 00 00       	call   800baf <sys_getenvid>
  800075:	83 c4 08             	add    $0x8,%esp
  800078:	57                   	push   %edi
  800079:	53                   	push   %ebx
  80007a:	56                   	push   %esi
  80007b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80007e:	50                   	push   %eax
  80007f:	68 30 24 80 00       	push   $0x802430
  800084:	e8 87 01 00 00       	call   800210 <cprintf>
		if (val == 10)
  800089:	a1 04 40 80 00       	mov    0x804004,%eax
  80008e:	83 c4 20             	add    $0x20,%esp
  800091:	83 f8 0a             	cmp    $0xa,%eax
  800094:	74 22                	je     8000b8 <umain+0x85>
			return;
		++val;
  800096:	83 c0 01             	add    $0x1,%eax
  800099:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  80009e:	6a 00                	push   $0x0
  8000a0:	6a 00                	push   $0x0
  8000a2:	6a 00                	push   $0x0
  8000a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a7:	e8 c8 11 00 00       	call   801274 <ipc_send>
		if (val == 10)
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  8000b6:	75 94                	jne    80004c <umain+0x19>
			return;
	}

}
  8000b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  8000c0:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000c6:	e8 e4 0a 00 00       	call   800baf <sys_getenvid>
  8000cb:	83 ec 04             	sub    $0x4,%esp
  8000ce:	53                   	push   %ebx
  8000cf:	50                   	push   %eax
  8000d0:	68 00 24 80 00       	push   $0x802400
  8000d5:	e8 36 01 00 00       	call   800210 <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000da:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000dd:	e8 cd 0a 00 00       	call   800baf <sys_getenvid>
  8000e2:	83 c4 0c             	add    $0xc,%esp
  8000e5:	53                   	push   %ebx
  8000e6:	50                   	push   %eax
  8000e7:	68 1a 24 80 00       	push   $0x80241a
  8000ec:	e8 1f 01 00 00       	call   800210 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000f1:	6a 00                	push   $0x0
  8000f3:	6a 00                	push   $0x0
  8000f5:	6a 00                	push   $0x0
  8000f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000fa:	e8 75 11 00 00       	call   801274 <ipc_send>
  8000ff:	83 c4 20             	add    $0x20,%esp
  800102:	e9 45 ff ff ff       	jmp    80004c <umain+0x19>

00800107 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800107:	f3 0f 1e fb          	endbr32 
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800113:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800116:	e8 94 0a 00 00       	call   800baf <sys_getenvid>
	if (id >= 0)
  80011b:	85 c0                	test   %eax,%eax
  80011d:	78 12                	js     800131 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  80011f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800124:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800127:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012c:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800131:	85 db                	test   %ebx,%ebx
  800133:	7e 07                	jle    80013c <libmain+0x35>
		binaryname = argv[0];
  800135:	8b 06                	mov    (%esi),%eax
  800137:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013c:	83 ec 08             	sub    $0x8,%esp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
  800141:	e8 ed fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800146:	e8 0a 00 00 00       	call   800155 <exit>
}
  80014b:	83 c4 10             	add    $0x10,%esp
  80014e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800155:	f3 0f 1e fb          	endbr32 
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80015f:	e8 93 13 00 00       	call   8014f7 <close_all>
	sys_env_destroy(0);
  800164:	83 ec 0c             	sub    $0xc,%esp
  800167:	6a 00                	push   $0x0
  800169:	e8 1b 0a 00 00       	call   800b89 <sys_env_destroy>
}
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800173:	f3 0f 1e fb          	endbr32 
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	53                   	push   %ebx
  80017b:	83 ec 04             	sub    $0x4,%esp
  80017e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800181:	8b 13                	mov    (%ebx),%edx
  800183:	8d 42 01             	lea    0x1(%edx),%eax
  800186:	89 03                	mov    %eax,(%ebx)
  800188:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800194:	74 09                	je     80019f <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800196:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80019f:	83 ec 08             	sub    $0x8,%esp
  8001a2:	68 ff 00 00 00       	push   $0xff
  8001a7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001aa:	50                   	push   %eax
  8001ab:	e8 87 09 00 00       	call   800b37 <sys_cputs>
		b->idx = 0;
  8001b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	eb db                	jmp    800196 <putch+0x23>

008001bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bb:	f3 0f 1e fb          	endbr32 
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cf:	00 00 00 
	b.cnt = 0;
  8001d2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001dc:	ff 75 0c             	pushl  0xc(%ebp)
  8001df:	ff 75 08             	pushl  0x8(%ebp)
  8001e2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e8:	50                   	push   %eax
  8001e9:	68 73 01 80 00       	push   $0x800173
  8001ee:	e8 80 01 00 00       	call   800373 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f3:	83 c4 08             	add    $0x8,%esp
  8001f6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001fc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800202:	50                   	push   %eax
  800203:	e8 2f 09 00 00       	call   800b37 <sys_cputs>

	return b.cnt;
}
  800208:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800210:	f3 0f 1e fb          	endbr32 
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021d:	50                   	push   %eax
  80021e:	ff 75 08             	pushl  0x8(%ebp)
  800221:	e8 95 ff ff ff       	call   8001bb <vcprintf>
	va_end(ap);

	return cnt;
}
  800226:	c9                   	leave  
  800227:	c3                   	ret    

00800228 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 1c             	sub    $0x1c,%esp
  800231:	89 c7                	mov    %eax,%edi
  800233:	89 d6                	mov    %edx,%esi
  800235:	8b 45 08             	mov    0x8(%ebp),%eax
  800238:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023b:	89 d1                	mov    %edx,%ecx
  80023d:	89 c2                	mov    %eax,%edx
  80023f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800242:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800245:	8b 45 10             	mov    0x10(%ebp),%eax
  800248:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80024e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800255:	39 c2                	cmp    %eax,%edx
  800257:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80025a:	72 3e                	jb     80029a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025c:	83 ec 0c             	sub    $0xc,%esp
  80025f:	ff 75 18             	pushl  0x18(%ebp)
  800262:	83 eb 01             	sub    $0x1,%ebx
  800265:	53                   	push   %ebx
  800266:	50                   	push   %eax
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026d:	ff 75 e0             	pushl  -0x20(%ebp)
  800270:	ff 75 dc             	pushl  -0x24(%ebp)
  800273:	ff 75 d8             	pushl  -0x28(%ebp)
  800276:	e8 25 1f 00 00       	call   8021a0 <__udivdi3>
  80027b:	83 c4 18             	add    $0x18,%esp
  80027e:	52                   	push   %edx
  80027f:	50                   	push   %eax
  800280:	89 f2                	mov    %esi,%edx
  800282:	89 f8                	mov    %edi,%eax
  800284:	e8 9f ff ff ff       	call   800228 <printnum>
  800289:	83 c4 20             	add    $0x20,%esp
  80028c:	eb 13                	jmp    8002a1 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	56                   	push   %esi
  800292:	ff 75 18             	pushl  0x18(%ebp)
  800295:	ff d7                	call   *%edi
  800297:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80029a:	83 eb 01             	sub    $0x1,%ebx
  80029d:	85 db                	test   %ebx,%ebx
  80029f:	7f ed                	jg     80028e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	83 ec 04             	sub    $0x4,%esp
  8002a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b4:	e8 f7 1f 00 00       	call   8022b0 <__umoddi3>
  8002b9:	83 c4 14             	add    $0x14,%esp
  8002bc:	0f be 80 60 24 80 00 	movsbl 0x802460(%eax),%eax
  8002c3:	50                   	push   %eax
  8002c4:	ff d7                	call   *%edi
}
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cc:	5b                   	pop    %ebx
  8002cd:	5e                   	pop    %esi
  8002ce:	5f                   	pop    %edi
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002d1:	83 fa 01             	cmp    $0x1,%edx
  8002d4:	7f 13                	jg     8002e9 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8002d6:	85 d2                	test   %edx,%edx
  8002d8:	74 1c                	je     8002f6 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8002da:	8b 10                	mov    (%eax),%edx
  8002dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002df:	89 08                	mov    %ecx,(%eax)
  8002e1:	8b 02                	mov    (%edx),%eax
  8002e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e8:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 02                	mov    (%edx),%eax
  8002f2:	8b 52 04             	mov    0x4(%edx),%edx
  8002f5:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fb:	89 08                	mov    %ecx,(%eax)
  8002fd:	8b 02                	mov    (%edx),%eax
  8002ff:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800304:	c3                   	ret    

00800305 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800305:	83 fa 01             	cmp    $0x1,%edx
  800308:	7f 0f                	jg     800319 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80030a:	85 d2                	test   %edx,%edx
  80030c:	74 18                	je     800326 <getint+0x21>
		return va_arg(*ap, long);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	99                   	cltd   
  800318:	c3                   	ret    
		return va_arg(*ap, long long);
  800319:	8b 10                	mov    (%eax),%edx
  80031b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80031e:	89 08                	mov    %ecx,(%eax)
  800320:	8b 02                	mov    (%edx),%eax
  800322:	8b 52 04             	mov    0x4(%edx),%edx
  800325:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800326:	8b 10                	mov    (%eax),%edx
  800328:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032b:	89 08                	mov    %ecx,(%eax)
  80032d:	8b 02                	mov    (%edx),%eax
  80032f:	99                   	cltd   
}
  800330:	c3                   	ret    

00800331 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800331:	f3 0f 1e fb          	endbr32 
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033f:	8b 10                	mov    (%eax),%edx
  800341:	3b 50 04             	cmp    0x4(%eax),%edx
  800344:	73 0a                	jae    800350 <sprintputch+0x1f>
		*b->buf++ = ch;
  800346:	8d 4a 01             	lea    0x1(%edx),%ecx
  800349:	89 08                	mov    %ecx,(%eax)
  80034b:	8b 45 08             	mov    0x8(%ebp),%eax
  80034e:	88 02                	mov    %al,(%edx)
}
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    

00800352 <printfmt>:
{
  800352:	f3 0f 1e fb          	endbr32 
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80035c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035f:	50                   	push   %eax
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	ff 75 0c             	pushl  0xc(%ebp)
  800366:	ff 75 08             	pushl  0x8(%ebp)
  800369:	e8 05 00 00 00       	call   800373 <vprintfmt>
}
  80036e:	83 c4 10             	add    $0x10,%esp
  800371:	c9                   	leave  
  800372:	c3                   	ret    

00800373 <vprintfmt>:
{
  800373:	f3 0f 1e fb          	endbr32 
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	57                   	push   %edi
  80037b:	56                   	push   %esi
  80037c:	53                   	push   %ebx
  80037d:	83 ec 2c             	sub    $0x2c,%esp
  800380:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800383:	8b 75 0c             	mov    0xc(%ebp),%esi
  800386:	8b 7d 10             	mov    0x10(%ebp),%edi
  800389:	e9 86 02 00 00       	jmp    800614 <vprintfmt+0x2a1>
		padc = ' ';
  80038e:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800392:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800399:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003a0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003a7:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8d 47 01             	lea    0x1(%edi),%eax
  8003af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b2:	0f b6 17             	movzbl (%edi),%edx
  8003b5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003b8:	3c 55                	cmp    $0x55,%al
  8003ba:	0f 87 df 02 00 00    	ja     80069f <vprintfmt+0x32c>
  8003c0:	0f b6 c0             	movzbl %al,%eax
  8003c3:	3e ff 24 85 a0 25 80 	notrack jmp *0x8025a0(,%eax,4)
  8003ca:	00 
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003ce:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003d2:	eb d8                	jmp    8003ac <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d7:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003db:	eb cf                	jmp    8003ac <vprintfmt+0x39>
  8003dd:	0f b6 d2             	movzbl %dl,%edx
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ee:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003f2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003f5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003f8:	83 f9 09             	cmp    $0x9,%ecx
  8003fb:	77 52                	ja     80044f <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8003fd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800400:	eb e9                	jmp    8003eb <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	8d 50 04             	lea    0x4(%eax),%edx
  800408:	89 55 14             	mov    %edx,0x14(%ebp)
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800413:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800417:	79 93                	jns    8003ac <vprintfmt+0x39>
				width = precision, precision = -1;
  800419:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80041c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800426:	eb 84                	jmp    8003ac <vprintfmt+0x39>
  800428:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042b:	85 c0                	test   %eax,%eax
  80042d:	ba 00 00 00 00       	mov    $0x0,%edx
  800432:	0f 49 d0             	cmovns %eax,%edx
  800435:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80043b:	e9 6c ff ff ff       	jmp    8003ac <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800443:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80044a:	e9 5d ff ff ff       	jmp    8003ac <vprintfmt+0x39>
  80044f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800452:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800455:	eb bc                	jmp    800413 <vprintfmt+0xa0>
			lflag++;
  800457:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80045d:	e9 4a ff ff ff       	jmp    8003ac <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	8d 50 04             	lea    0x4(%eax),%edx
  800468:	89 55 14             	mov    %edx,0x14(%ebp)
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	56                   	push   %esi
  80046f:	ff 30                	pushl  (%eax)
  800471:	ff d3                	call   *%ebx
			break;
  800473:	83 c4 10             	add    $0x10,%esp
  800476:	e9 96 01 00 00       	jmp    800611 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	8d 50 04             	lea    0x4(%eax),%edx
  800481:	89 55 14             	mov    %edx,0x14(%ebp)
  800484:	8b 00                	mov    (%eax),%eax
  800486:	99                   	cltd   
  800487:	31 d0                	xor    %edx,%eax
  800489:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048b:	83 f8 0f             	cmp    $0xf,%eax
  80048e:	7f 20                	jg     8004b0 <vprintfmt+0x13d>
  800490:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  800497:	85 d2                	test   %edx,%edx
  800499:	74 15                	je     8004b0 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  80049b:	52                   	push   %edx
  80049c:	68 31 2a 80 00       	push   $0x802a31
  8004a1:	56                   	push   %esi
  8004a2:	53                   	push   %ebx
  8004a3:	e8 aa fe ff ff       	call   800352 <printfmt>
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	e9 61 01 00 00       	jmp    800611 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8004b0:	50                   	push   %eax
  8004b1:	68 78 24 80 00       	push   $0x802478
  8004b6:	56                   	push   %esi
  8004b7:	53                   	push   %ebx
  8004b8:	e8 95 fe ff ff       	call   800352 <printfmt>
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	e9 4c 01 00 00       	jmp    800611 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 50 04             	lea    0x4(%eax),%edx
  8004cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ce:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8004d0:	85 c9                	test   %ecx,%ecx
  8004d2:	b8 71 24 80 00       	mov    $0x802471,%eax
  8004d7:	0f 45 c1             	cmovne %ecx,%eax
  8004da:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e1:	7e 06                	jle    8004e9 <vprintfmt+0x176>
  8004e3:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004e7:	75 0d                	jne    8004f6 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004ec:	89 c7                	mov    %eax,%edi
  8004ee:	03 45 e0             	add    -0x20(%ebp),%eax
  8004f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f4:	eb 57                	jmp    80054d <vprintfmt+0x1da>
  8004f6:	83 ec 08             	sub    $0x8,%esp
  8004f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8004fc:	ff 75 cc             	pushl  -0x34(%ebp)
  8004ff:	e8 4f 02 00 00       	call   800753 <strnlen>
  800504:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800507:	29 c2                	sub    %eax,%edx
  800509:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80050c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800513:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800516:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800518:	85 db                	test   %ebx,%ebx
  80051a:	7e 10                	jle    80052c <vprintfmt+0x1b9>
					putch(padc, putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	56                   	push   %esi
  800520:	57                   	push   %edi
  800521:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800524:	83 eb 01             	sub    $0x1,%ebx
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	eb ec                	jmp    800518 <vprintfmt+0x1a5>
  80052c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80052f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800532:	85 d2                	test   %edx,%edx
  800534:	b8 00 00 00 00       	mov    $0x0,%eax
  800539:	0f 49 c2             	cmovns %edx,%eax
  80053c:	29 c2                	sub    %eax,%edx
  80053e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800541:	eb a6                	jmp    8004e9 <vprintfmt+0x176>
					putch(ch, putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	56                   	push   %esi
  800547:	52                   	push   %edx
  800548:	ff d3                	call   *%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800550:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800552:	83 c7 01             	add    $0x1,%edi
  800555:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800559:	0f be d0             	movsbl %al,%edx
  80055c:	85 d2                	test   %edx,%edx
  80055e:	74 42                	je     8005a2 <vprintfmt+0x22f>
  800560:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800564:	78 06                	js     80056c <vprintfmt+0x1f9>
  800566:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80056a:	78 1e                	js     80058a <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  80056c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800570:	74 d1                	je     800543 <vprintfmt+0x1d0>
  800572:	0f be c0             	movsbl %al,%eax
  800575:	83 e8 20             	sub    $0x20,%eax
  800578:	83 f8 5e             	cmp    $0x5e,%eax
  80057b:	76 c6                	jbe    800543 <vprintfmt+0x1d0>
					putch('?', putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	56                   	push   %esi
  800581:	6a 3f                	push   $0x3f
  800583:	ff d3                	call   *%ebx
  800585:	83 c4 10             	add    $0x10,%esp
  800588:	eb c3                	jmp    80054d <vprintfmt+0x1da>
  80058a:	89 cf                	mov    %ecx,%edi
  80058c:	eb 0e                	jmp    80059c <vprintfmt+0x229>
				putch(' ', putdat);
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	56                   	push   %esi
  800592:	6a 20                	push   $0x20
  800594:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800596:	83 ef 01             	sub    $0x1,%edi
  800599:	83 c4 10             	add    $0x10,%esp
  80059c:	85 ff                	test   %edi,%edi
  80059e:	7f ee                	jg     80058e <vprintfmt+0x21b>
  8005a0:	eb 6f                	jmp    800611 <vprintfmt+0x29e>
  8005a2:	89 cf                	mov    %ecx,%edi
  8005a4:	eb f6                	jmp    80059c <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8005a6:	89 ca                	mov    %ecx,%edx
  8005a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ab:	e8 55 fd ff ff       	call   800305 <getint>
  8005b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8005b6:	85 d2                	test   %edx,%edx
  8005b8:	78 0b                	js     8005c5 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8005ba:	89 d1                	mov    %edx,%ecx
  8005bc:	89 c2                	mov    %eax,%edx
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c3:	eb 32                	jmp    8005f7 <vprintfmt+0x284>
				putch('-', putdat);
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	56                   	push   %esi
  8005c9:	6a 2d                	push   $0x2d
  8005cb:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005cd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d3:	f7 da                	neg    %edx
  8005d5:	83 d1 00             	adc    $0x0,%ecx
  8005d8:	f7 d9                	neg    %ecx
  8005da:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e2:	eb 13                	jmp    8005f7 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8005e4:	89 ca                	mov    %ecx,%edx
  8005e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e9:	e8 e3 fc ff ff       	call   8002d1 <getuint>
  8005ee:	89 d1                	mov    %edx,%ecx
  8005f0:	89 c2                	mov    %eax,%edx
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005f7:	83 ec 0c             	sub    $0xc,%esp
  8005fa:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005fe:	57                   	push   %edi
  8005ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800602:	50                   	push   %eax
  800603:	51                   	push   %ecx
  800604:	52                   	push   %edx
  800605:	89 f2                	mov    %esi,%edx
  800607:	89 d8                	mov    %ebx,%eax
  800609:	e8 1a fc ff ff       	call   800228 <printnum>
			break;
  80060e:	83 c4 20             	add    $0x20,%esp
{
  800611:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800614:	83 c7 01             	add    $0x1,%edi
  800617:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80061b:	83 f8 25             	cmp    $0x25,%eax
  80061e:	0f 84 6a fd ff ff    	je     80038e <vprintfmt+0x1b>
			if (ch == '\0')
  800624:	85 c0                	test   %eax,%eax
  800626:	0f 84 93 00 00 00    	je     8006bf <vprintfmt+0x34c>
			putch(ch, putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	56                   	push   %esi
  800630:	50                   	push   %eax
  800631:	ff d3                	call   *%ebx
  800633:	83 c4 10             	add    $0x10,%esp
  800636:	eb dc                	jmp    800614 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800638:	89 ca                	mov    %ecx,%edx
  80063a:	8d 45 14             	lea    0x14(%ebp),%eax
  80063d:	e8 8f fc ff ff       	call   8002d1 <getuint>
  800642:	89 d1                	mov    %edx,%ecx
  800644:	89 c2                	mov    %eax,%edx
			base = 8;
  800646:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80064b:	eb aa                	jmp    8005f7 <vprintfmt+0x284>
			putch('0', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	56                   	push   %esi
  800651:	6a 30                	push   $0x30
  800653:	ff d3                	call   *%ebx
			putch('x', putdat);
  800655:	83 c4 08             	add    $0x8,%esp
  800658:	56                   	push   %esi
  800659:	6a 78                	push   $0x78
  80065b:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8d 50 04             	lea    0x4(%eax),%edx
  800663:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800666:	8b 10                	mov    (%eax),%edx
  800668:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80066d:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800670:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800675:	eb 80                	jmp    8005f7 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800677:	89 ca                	mov    %ecx,%edx
  800679:	8d 45 14             	lea    0x14(%ebp),%eax
  80067c:	e8 50 fc ff ff       	call   8002d1 <getuint>
  800681:	89 d1                	mov    %edx,%ecx
  800683:	89 c2                	mov    %eax,%edx
			base = 16;
  800685:	b8 10 00 00 00       	mov    $0x10,%eax
  80068a:	e9 68 ff ff ff       	jmp    8005f7 <vprintfmt+0x284>
			putch(ch, putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	56                   	push   %esi
  800693:	6a 25                	push   $0x25
  800695:	ff d3                	call   *%ebx
			break;
  800697:	83 c4 10             	add    $0x10,%esp
  80069a:	e9 72 ff ff ff       	jmp    800611 <vprintfmt+0x29e>
			putch('%', putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	56                   	push   %esi
  8006a3:	6a 25                	push   $0x25
  8006a5:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	89 f8                	mov    %edi,%eax
  8006ac:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006b0:	74 05                	je     8006b7 <vprintfmt+0x344>
  8006b2:	83 e8 01             	sub    $0x1,%eax
  8006b5:	eb f5                	jmp    8006ac <vprintfmt+0x339>
  8006b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ba:	e9 52 ff ff ff       	jmp    800611 <vprintfmt+0x29e>
}
  8006bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c2:	5b                   	pop    %ebx
  8006c3:	5e                   	pop    %esi
  8006c4:	5f                   	pop    %edi
  8006c5:	5d                   	pop    %ebp
  8006c6:	c3                   	ret    

008006c7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c7:	f3 0f 1e fb          	endbr32 
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	83 ec 18             	sub    $0x18,%esp
  8006d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006da:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006de:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	74 26                	je     800712 <vsnprintf+0x4b>
  8006ec:	85 d2                	test   %edx,%edx
  8006ee:	7e 22                	jle    800712 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f0:	ff 75 14             	pushl  0x14(%ebp)
  8006f3:	ff 75 10             	pushl  0x10(%ebp)
  8006f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f9:	50                   	push   %eax
  8006fa:	68 31 03 80 00       	push   $0x800331
  8006ff:	e8 6f fc ff ff       	call   800373 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800704:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800707:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070d:	83 c4 10             	add    $0x10,%esp
}
  800710:	c9                   	leave  
  800711:	c3                   	ret    
		return -E_INVAL;
  800712:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800717:	eb f7                	jmp    800710 <vsnprintf+0x49>

00800719 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800719:	f3 0f 1e fb          	endbr32 
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800723:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800726:	50                   	push   %eax
  800727:	ff 75 10             	pushl  0x10(%ebp)
  80072a:	ff 75 0c             	pushl  0xc(%ebp)
  80072d:	ff 75 08             	pushl  0x8(%ebp)
  800730:	e8 92 ff ff ff       	call   8006c7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800735:	c9                   	leave  
  800736:	c3                   	ret    

00800737 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800737:	f3 0f 1e fb          	endbr32 
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800741:	b8 00 00 00 00       	mov    $0x0,%eax
  800746:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074a:	74 05                	je     800751 <strlen+0x1a>
		n++;
  80074c:	83 c0 01             	add    $0x1,%eax
  80074f:	eb f5                	jmp    800746 <strlen+0xf>
	return n;
}
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800753:	f3 0f 1e fb          	endbr32 
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800760:	b8 00 00 00 00       	mov    $0x0,%eax
  800765:	39 d0                	cmp    %edx,%eax
  800767:	74 0d                	je     800776 <strnlen+0x23>
  800769:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80076d:	74 05                	je     800774 <strnlen+0x21>
		n++;
  80076f:	83 c0 01             	add    $0x1,%eax
  800772:	eb f1                	jmp    800765 <strnlen+0x12>
  800774:	89 c2                	mov    %eax,%edx
	return n;
}
  800776:	89 d0                	mov    %edx,%eax
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077a:	f3 0f 1e fb          	endbr32 
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	53                   	push   %ebx
  800782:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800785:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800788:	b8 00 00 00 00       	mov    $0x0,%eax
  80078d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800791:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800794:	83 c0 01             	add    $0x1,%eax
  800797:	84 d2                	test   %dl,%dl
  800799:	75 f2                	jne    80078d <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80079b:	89 c8                	mov    %ecx,%eax
  80079d:	5b                   	pop    %ebx
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a0:	f3 0f 1e fb          	endbr32 
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	53                   	push   %ebx
  8007a8:	83 ec 10             	sub    $0x10,%esp
  8007ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ae:	53                   	push   %ebx
  8007af:	e8 83 ff ff ff       	call   800737 <strlen>
  8007b4:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007b7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ba:	01 d8                	add    %ebx,%eax
  8007bc:	50                   	push   %eax
  8007bd:	e8 b8 ff ff ff       	call   80077a <strcpy>
	return dst;
}
  8007c2:	89 d8                	mov    %ebx,%eax
  8007c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c9:	f3 0f 1e fb          	endbr32 
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	56                   	push   %esi
  8007d1:	53                   	push   %ebx
  8007d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d8:	89 f3                	mov    %esi,%ebx
  8007da:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007dd:	89 f0                	mov    %esi,%eax
  8007df:	39 d8                	cmp    %ebx,%eax
  8007e1:	74 11                	je     8007f4 <strncpy+0x2b>
		*dst++ = *src;
  8007e3:	83 c0 01             	add    $0x1,%eax
  8007e6:	0f b6 0a             	movzbl (%edx),%ecx
  8007e9:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ec:	80 f9 01             	cmp    $0x1,%cl
  8007ef:	83 da ff             	sbb    $0xffffffff,%edx
  8007f2:	eb eb                	jmp    8007df <strncpy+0x16>
	}
	return ret;
}
  8007f4:	89 f0                	mov    %esi,%eax
  8007f6:	5b                   	pop    %ebx
  8007f7:	5e                   	pop    %esi
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fa:	f3 0f 1e fb          	endbr32 
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	56                   	push   %esi
  800802:	53                   	push   %ebx
  800803:	8b 75 08             	mov    0x8(%ebp),%esi
  800806:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800809:	8b 55 10             	mov    0x10(%ebp),%edx
  80080c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080e:	85 d2                	test   %edx,%edx
  800810:	74 21                	je     800833 <strlcpy+0x39>
  800812:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800816:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800818:	39 c2                	cmp    %eax,%edx
  80081a:	74 14                	je     800830 <strlcpy+0x36>
  80081c:	0f b6 19             	movzbl (%ecx),%ebx
  80081f:	84 db                	test   %bl,%bl
  800821:	74 0b                	je     80082e <strlcpy+0x34>
			*dst++ = *src++;
  800823:	83 c1 01             	add    $0x1,%ecx
  800826:	83 c2 01             	add    $0x1,%edx
  800829:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082c:	eb ea                	jmp    800818 <strlcpy+0x1e>
  80082e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800830:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800833:	29 f0                	sub    %esi,%eax
}
  800835:	5b                   	pop    %ebx
  800836:	5e                   	pop    %esi
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800839:	f3 0f 1e fb          	endbr32 
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800843:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800846:	0f b6 01             	movzbl (%ecx),%eax
  800849:	84 c0                	test   %al,%al
  80084b:	74 0c                	je     800859 <strcmp+0x20>
  80084d:	3a 02                	cmp    (%edx),%al
  80084f:	75 08                	jne    800859 <strcmp+0x20>
		p++, q++;
  800851:	83 c1 01             	add    $0x1,%ecx
  800854:	83 c2 01             	add    $0x1,%edx
  800857:	eb ed                	jmp    800846 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800859:	0f b6 c0             	movzbl %al,%eax
  80085c:	0f b6 12             	movzbl (%edx),%edx
  80085f:	29 d0                	sub    %edx,%eax
}
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800863:	f3 0f 1e fb          	endbr32 
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	89 c3                	mov    %eax,%ebx
  800873:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800876:	eb 06                	jmp    80087e <strncmp+0x1b>
		n--, p++, q++;
  800878:	83 c0 01             	add    $0x1,%eax
  80087b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80087e:	39 d8                	cmp    %ebx,%eax
  800880:	74 16                	je     800898 <strncmp+0x35>
  800882:	0f b6 08             	movzbl (%eax),%ecx
  800885:	84 c9                	test   %cl,%cl
  800887:	74 04                	je     80088d <strncmp+0x2a>
  800889:	3a 0a                	cmp    (%edx),%cl
  80088b:	74 eb                	je     800878 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088d:	0f b6 00             	movzbl (%eax),%eax
  800890:	0f b6 12             	movzbl (%edx),%edx
  800893:	29 d0                	sub    %edx,%eax
}
  800895:	5b                   	pop    %ebx
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    
		return 0;
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
  80089d:	eb f6                	jmp    800895 <strncmp+0x32>

0080089f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089f:	f3 0f 1e fb          	endbr32 
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ad:	0f b6 10             	movzbl (%eax),%edx
  8008b0:	84 d2                	test   %dl,%dl
  8008b2:	74 09                	je     8008bd <strchr+0x1e>
		if (*s == c)
  8008b4:	38 ca                	cmp    %cl,%dl
  8008b6:	74 0a                	je     8008c2 <strchr+0x23>
	for (; *s; s++)
  8008b8:	83 c0 01             	add    $0x1,%eax
  8008bb:	eb f0                	jmp    8008ad <strchr+0xe>
			return (char *) s;
	return 0;
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c4:	f3 0f 1e fb          	endbr32 
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d5:	38 ca                	cmp    %cl,%dl
  8008d7:	74 09                	je     8008e2 <strfind+0x1e>
  8008d9:	84 d2                	test   %dl,%dl
  8008db:	74 05                	je     8008e2 <strfind+0x1e>
	for (; *s; s++)
  8008dd:	83 c0 01             	add    $0x1,%eax
  8008e0:	eb f0                	jmp    8008d2 <strfind+0xe>
			break;
	return (char *) s;
}
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e4:	f3 0f 1e fb          	endbr32 
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	57                   	push   %edi
  8008ec:	56                   	push   %esi
  8008ed:	53                   	push   %ebx
  8008ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8008f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8008f4:	85 c9                	test   %ecx,%ecx
  8008f6:	74 33                	je     80092b <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f8:	89 d0                	mov    %edx,%eax
  8008fa:	09 c8                	or     %ecx,%eax
  8008fc:	a8 03                	test   $0x3,%al
  8008fe:	75 23                	jne    800923 <memset+0x3f>
		c &= 0xFF;
  800900:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800904:	89 d8                	mov    %ebx,%eax
  800906:	c1 e0 08             	shl    $0x8,%eax
  800909:	89 df                	mov    %ebx,%edi
  80090b:	c1 e7 18             	shl    $0x18,%edi
  80090e:	89 de                	mov    %ebx,%esi
  800910:	c1 e6 10             	shl    $0x10,%esi
  800913:	09 f7                	or     %esi,%edi
  800915:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800917:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80091c:	89 d7                	mov    %edx,%edi
  80091e:	fc                   	cld    
  80091f:	f3 ab                	rep stos %eax,%es:(%edi)
  800921:	eb 08                	jmp    80092b <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800923:	89 d7                	mov    %edx,%edi
  800925:	8b 45 0c             	mov    0xc(%ebp),%eax
  800928:	fc                   	cld    
  800929:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  80092b:	89 d0                	mov    %edx,%eax
  80092d:	5b                   	pop    %ebx
  80092e:	5e                   	pop    %esi
  80092f:	5f                   	pop    %edi
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800932:	f3 0f 1e fb          	endbr32 
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	57                   	push   %edi
  80093a:	56                   	push   %esi
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800941:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800944:	39 c6                	cmp    %eax,%esi
  800946:	73 32                	jae    80097a <memmove+0x48>
  800948:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094b:	39 c2                	cmp    %eax,%edx
  80094d:	76 2b                	jbe    80097a <memmove+0x48>
		s += n;
		d += n;
  80094f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800952:	89 fe                	mov    %edi,%esi
  800954:	09 ce                	or     %ecx,%esi
  800956:	09 d6                	or     %edx,%esi
  800958:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095e:	75 0e                	jne    80096e <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800960:	83 ef 04             	sub    $0x4,%edi
  800963:	8d 72 fc             	lea    -0x4(%edx),%esi
  800966:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800969:	fd                   	std    
  80096a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096c:	eb 09                	jmp    800977 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096e:	83 ef 01             	sub    $0x1,%edi
  800971:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800974:	fd                   	std    
  800975:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800977:	fc                   	cld    
  800978:	eb 1a                	jmp    800994 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097a:	89 c2                	mov    %eax,%edx
  80097c:	09 ca                	or     %ecx,%edx
  80097e:	09 f2                	or     %esi,%edx
  800980:	f6 c2 03             	test   $0x3,%dl
  800983:	75 0a                	jne    80098f <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800985:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800988:	89 c7                	mov    %eax,%edi
  80098a:	fc                   	cld    
  80098b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098d:	eb 05                	jmp    800994 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  80098f:	89 c7                	mov    %eax,%edi
  800991:	fc                   	cld    
  800992:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800994:	5e                   	pop    %esi
  800995:	5f                   	pop    %edi
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800998:	f3 0f 1e fb          	endbr32 
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009a2:	ff 75 10             	pushl  0x10(%ebp)
  8009a5:	ff 75 0c             	pushl  0xc(%ebp)
  8009a8:	ff 75 08             	pushl  0x8(%ebp)
  8009ab:	e8 82 ff ff ff       	call   800932 <memmove>
}
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b2:	f3 0f 1e fb          	endbr32 
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	56                   	push   %esi
  8009ba:	53                   	push   %ebx
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c1:	89 c6                	mov    %eax,%esi
  8009c3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c6:	39 f0                	cmp    %esi,%eax
  8009c8:	74 1c                	je     8009e6 <memcmp+0x34>
		if (*s1 != *s2)
  8009ca:	0f b6 08             	movzbl (%eax),%ecx
  8009cd:	0f b6 1a             	movzbl (%edx),%ebx
  8009d0:	38 d9                	cmp    %bl,%cl
  8009d2:	75 08                	jne    8009dc <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009d4:	83 c0 01             	add    $0x1,%eax
  8009d7:	83 c2 01             	add    $0x1,%edx
  8009da:	eb ea                	jmp    8009c6 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009dc:	0f b6 c1             	movzbl %cl,%eax
  8009df:	0f b6 db             	movzbl %bl,%ebx
  8009e2:	29 d8                	sub    %ebx,%eax
  8009e4:	eb 05                	jmp    8009eb <memcmp+0x39>
	}

	return 0;
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ef:	f3 0f 1e fb          	endbr32 
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009fc:	89 c2                	mov    %eax,%edx
  8009fe:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a01:	39 d0                	cmp    %edx,%eax
  800a03:	73 09                	jae    800a0e <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a05:	38 08                	cmp    %cl,(%eax)
  800a07:	74 05                	je     800a0e <memfind+0x1f>
	for (; s < ends; s++)
  800a09:	83 c0 01             	add    $0x1,%eax
  800a0c:	eb f3                	jmp    800a01 <memfind+0x12>
			break;
	return (void *) s;
}
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a10:	f3 0f 1e fb          	endbr32 
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a20:	eb 03                	jmp    800a25 <strtol+0x15>
		s++;
  800a22:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a25:	0f b6 01             	movzbl (%ecx),%eax
  800a28:	3c 20                	cmp    $0x20,%al
  800a2a:	74 f6                	je     800a22 <strtol+0x12>
  800a2c:	3c 09                	cmp    $0x9,%al
  800a2e:	74 f2                	je     800a22 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a30:	3c 2b                	cmp    $0x2b,%al
  800a32:	74 2a                	je     800a5e <strtol+0x4e>
	int neg = 0;
  800a34:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a39:	3c 2d                	cmp    $0x2d,%al
  800a3b:	74 2b                	je     800a68 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a43:	75 0f                	jne    800a54 <strtol+0x44>
  800a45:	80 39 30             	cmpb   $0x30,(%ecx)
  800a48:	74 28                	je     800a72 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4a:	85 db                	test   %ebx,%ebx
  800a4c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a51:	0f 44 d8             	cmove  %eax,%ebx
  800a54:	b8 00 00 00 00       	mov    $0x0,%eax
  800a59:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a5c:	eb 46                	jmp    800aa4 <strtol+0x94>
		s++;
  800a5e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a61:	bf 00 00 00 00       	mov    $0x0,%edi
  800a66:	eb d5                	jmp    800a3d <strtol+0x2d>
		s++, neg = 1;
  800a68:	83 c1 01             	add    $0x1,%ecx
  800a6b:	bf 01 00 00 00       	mov    $0x1,%edi
  800a70:	eb cb                	jmp    800a3d <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a72:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a76:	74 0e                	je     800a86 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a78:	85 db                	test   %ebx,%ebx
  800a7a:	75 d8                	jne    800a54 <strtol+0x44>
		s++, base = 8;
  800a7c:	83 c1 01             	add    $0x1,%ecx
  800a7f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a84:	eb ce                	jmp    800a54 <strtol+0x44>
		s += 2, base = 16;
  800a86:	83 c1 02             	add    $0x2,%ecx
  800a89:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8e:	eb c4                	jmp    800a54 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a90:	0f be d2             	movsbl %dl,%edx
  800a93:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a96:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a99:	7d 3a                	jge    800ad5 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a9b:	83 c1 01             	add    $0x1,%ecx
  800a9e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa2:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aa4:	0f b6 11             	movzbl (%ecx),%edx
  800aa7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aaa:	89 f3                	mov    %esi,%ebx
  800aac:	80 fb 09             	cmp    $0x9,%bl
  800aaf:	76 df                	jbe    800a90 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ab1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	80 fb 19             	cmp    $0x19,%bl
  800ab9:	77 08                	ja     800ac3 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800abb:	0f be d2             	movsbl %dl,%edx
  800abe:	83 ea 57             	sub    $0x57,%edx
  800ac1:	eb d3                	jmp    800a96 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ac3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac6:	89 f3                	mov    %esi,%ebx
  800ac8:	80 fb 19             	cmp    $0x19,%bl
  800acb:	77 08                	ja     800ad5 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800acd:	0f be d2             	movsbl %dl,%edx
  800ad0:	83 ea 37             	sub    $0x37,%edx
  800ad3:	eb c1                	jmp    800a96 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad9:	74 05                	je     800ae0 <strtol+0xd0>
		*endptr = (char *) s;
  800adb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ade:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ae0:	89 c2                	mov    %eax,%edx
  800ae2:	f7 da                	neg    %edx
  800ae4:	85 ff                	test   %edi,%edi
  800ae6:	0f 45 c2             	cmovne %edx,%eax
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	83 ec 1c             	sub    $0x1c,%esp
  800af7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800afa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800afd:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b05:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b08:	8b 75 14             	mov    0x14(%ebp),%esi
  800b0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b0d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b11:	74 04                	je     800b17 <syscall+0x29>
  800b13:	85 c0                	test   %eax,%eax
  800b15:	7f 08                	jg     800b1f <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800b17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1f:	83 ec 0c             	sub    $0xc,%esp
  800b22:	50                   	push   %eax
  800b23:	ff 75 e0             	pushl  -0x20(%ebp)
  800b26:	68 5f 27 80 00       	push   $0x80275f
  800b2b:	6a 23                	push   $0x23
  800b2d:	68 7c 27 80 00       	push   $0x80277c
  800b32:	e8 3b 15 00 00       	call   802072 <_panic>

00800b37 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800b37:	f3 0f 1e fb          	endbr32 
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b41:	6a 00                	push   $0x0
  800b43:	6a 00                	push   $0x0
  800b45:	6a 00                	push   $0x0
  800b47:	ff 75 0c             	pushl  0xc(%ebp)
  800b4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b52:	b8 00 00 00 00       	mov    $0x0,%eax
  800b57:	e8 92 ff ff ff       	call   800aee <syscall>
}
  800b5c:	83 c4 10             	add    $0x10,%esp
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    

00800b61 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b61:	f3 0f 1e fb          	endbr32 
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b6b:	6a 00                	push   $0x0
  800b6d:	6a 00                	push   $0x0
  800b6f:	6a 00                	push   $0x0
  800b71:	6a 00                	push   $0x0
  800b73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b78:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b82:	e8 67 ff ff ff       	call   800aee <syscall>
}
  800b87:	c9                   	leave  
  800b88:	c3                   	ret    

00800b89 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b89:	f3 0f 1e fb          	endbr32 
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b93:	6a 00                	push   $0x0
  800b95:	6a 00                	push   $0x0
  800b97:	6a 00                	push   $0x0
  800b99:	6a 00                	push   $0x0
  800b9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9e:	ba 01 00 00 00       	mov    $0x1,%edx
  800ba3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba8:	e8 41 ff ff ff       	call   800aee <syscall>
}
  800bad:	c9                   	leave  
  800bae:	c3                   	ret    

00800baf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800baf:	f3 0f 1e fb          	endbr32 
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bb9:	6a 00                	push   $0x0
  800bbb:	6a 00                	push   $0x0
  800bbd:	6a 00                	push   $0x0
  800bbf:	6a 00                	push   $0x0
  800bc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcb:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd0:	e8 19 ff ff ff       	call   800aee <syscall>
}
  800bd5:	c9                   	leave  
  800bd6:	c3                   	ret    

00800bd7 <sys_yield>:

void
sys_yield(void)
{
  800bd7:	f3 0f 1e fb          	endbr32 
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800be1:	6a 00                	push   $0x0
  800be3:	6a 00                	push   $0x0
  800be5:	6a 00                	push   $0x0
  800be7:	6a 00                	push   $0x0
  800be9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bee:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf8:	e8 f1 fe ff ff       	call   800aee <syscall>
}
  800bfd:	83 c4 10             	add    $0x10,%esp
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c02:	f3 0f 1e fb          	endbr32 
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c0c:	6a 00                	push   $0x0
  800c0e:	6a 00                	push   $0x0
  800c10:	ff 75 10             	pushl  0x10(%ebp)
  800c13:	ff 75 0c             	pushl  0xc(%ebp)
  800c16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c19:	ba 01 00 00 00       	mov    $0x1,%edx
  800c1e:	b8 04 00 00 00       	mov    $0x4,%eax
  800c23:	e8 c6 fe ff ff       	call   800aee <syscall>
}
  800c28:	c9                   	leave  
  800c29:	c3                   	ret    

00800c2a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c2a:	f3 0f 1e fb          	endbr32 
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c34:	ff 75 18             	pushl  0x18(%ebp)
  800c37:	ff 75 14             	pushl  0x14(%ebp)
  800c3a:	ff 75 10             	pushl  0x10(%ebp)
  800c3d:	ff 75 0c             	pushl  0xc(%ebp)
  800c40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c43:	ba 01 00 00 00       	mov    $0x1,%edx
  800c48:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4d:	e8 9c fe ff ff       	call   800aee <syscall>
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c54:	f3 0f 1e fb          	endbr32 
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c5e:	6a 00                	push   $0x0
  800c60:	6a 00                	push   $0x0
  800c62:	6a 00                	push   $0x0
  800c64:	ff 75 0c             	pushl  0xc(%ebp)
  800c67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c6f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c74:	e8 75 fe ff ff       	call   800aee <syscall>
}
  800c79:	c9                   	leave  
  800c7a:	c3                   	ret    

00800c7b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c7b:	f3 0f 1e fb          	endbr32 
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c85:	6a 00                	push   $0x0
  800c87:	6a 00                	push   $0x0
  800c89:	6a 00                	push   $0x0
  800c8b:	ff 75 0c             	pushl  0xc(%ebp)
  800c8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c91:	ba 01 00 00 00       	mov    $0x1,%edx
  800c96:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9b:	e8 4e fe ff ff       	call   800aee <syscall>
}
  800ca0:	c9                   	leave  
  800ca1:	c3                   	ret    

00800ca2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca2:	f3 0f 1e fb          	endbr32 
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800cac:	6a 00                	push   $0x0
  800cae:	6a 00                	push   $0x0
  800cb0:	6a 00                	push   $0x0
  800cb2:	ff 75 0c             	pushl  0xc(%ebp)
  800cb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb8:	ba 01 00 00 00       	mov    $0x1,%edx
  800cbd:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc2:	e8 27 fe ff ff       	call   800aee <syscall>
}
  800cc7:	c9                   	leave  
  800cc8:	c3                   	ret    

00800cc9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc9:	f3 0f 1e fb          	endbr32 
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cd3:	6a 00                	push   $0x0
  800cd5:	6a 00                	push   $0x0
  800cd7:	6a 00                	push   $0x0
  800cd9:	ff 75 0c             	pushl  0xc(%ebp)
  800cdc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cdf:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce9:	e8 00 fe ff ff       	call   800aee <syscall>
}
  800cee:	c9                   	leave  
  800cef:	c3                   	ret    

00800cf0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf0:	f3 0f 1e fb          	endbr32 
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cfa:	6a 00                	push   $0x0
  800cfc:	ff 75 14             	pushl  0x14(%ebp)
  800cff:	ff 75 10             	pushl  0x10(%ebp)
  800d02:	ff 75 0c             	pushl  0xc(%ebp)
  800d05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d08:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d12:	e8 d7 fd ff ff       	call   800aee <syscall>
}
  800d17:	c9                   	leave  
  800d18:	c3                   	ret    

00800d19 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d19:	f3 0f 1e fb          	endbr32 
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d23:	6a 00                	push   $0x0
  800d25:	6a 00                	push   $0x0
  800d27:	6a 00                	push   $0x0
  800d29:	6a 00                	push   $0x0
  800d2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2e:	ba 01 00 00 00       	mov    $0x1,%edx
  800d33:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d38:	e8 b1 fd ff ff       	call   800aee <syscall>
}
  800d3d:	c9                   	leave  
  800d3e:	c3                   	ret    

00800d3f <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	53                   	push   %ebx
  800d43:	83 ec 04             	sub    $0x4,%esp
	int r;

	// LAB 4: Your code here.
	void *addr = (void *) (pn * PGSIZE);
  800d46:	89 d3                	mov    %edx,%ebx
  800d48:	c1 e3 0c             	shl    $0xc,%ebx

	if (uvpt[pn] & PTE_SHARE) {
  800d4b:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d52:	f6 c5 04             	test   $0x4,%ch
  800d55:	75 56                	jne    800dad <duppage+0x6e>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
		return 0;
	}

	if ((uvpt[pn] & (PTE_W | PTE_COW)) != 0) {
  800d57:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d5e:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800d64:	74 72                	je     800dd8 <duppage+0x99>
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW) <
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	68 05 08 00 00       	push   $0x805
  800d6e:	53                   	push   %ebx
  800d6f:	50                   	push   %eax
  800d70:	53                   	push   %ebx
  800d71:	6a 00                	push   $0x0
  800d73:	e8 b2 fe ff ff       	call   800c2a <sys_page_map>
  800d78:	83 c4 20             	add    $0x20,%esp
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	78 45                	js     800dc4 <duppage+0x85>
		    0) {
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
		}
		if (sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW) < 0) {
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	68 05 08 00 00       	push   $0x805
  800d87:	53                   	push   %ebx
  800d88:	6a 00                	push   $0x0
  800d8a:	53                   	push   %ebx
  800d8b:	6a 00                	push   $0x0
  800d8d:	e8 98 fe ff ff       	call   800c2a <sys_page_map>
  800d92:	83 c4 20             	add    $0x20,%esp
  800d95:	85 c0                	test   %eax,%eax
  800d97:	79 55                	jns    800dee <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP FATHER");
  800d99:	83 ec 04             	sub    $0x4,%esp
  800d9c:	68 ac 27 80 00       	push   $0x8027ac
  800da1:	6a 54                	push   $0x54
  800da3:	68 3f 28 80 00       	push   $0x80283f
  800da8:	e8 c5 12 00 00       	call   802072 <_panic>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	68 07 0e 00 00       	push   $0xe07
  800db5:	53                   	push   %ebx
  800db6:	50                   	push   %eax
  800db7:	53                   	push   %ebx
  800db8:	6a 00                	push   $0x0
  800dba:	e8 6b fe ff ff       	call   800c2a <sys_page_map>
		return 0;
  800dbf:	83 c4 20             	add    $0x20,%esp
  800dc2:	eb 2a                	jmp    800dee <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
  800dc4:	83 ec 04             	sub    $0x4,%esp
  800dc7:	68 8c 27 80 00       	push   $0x80278c
  800dcc:	6a 51                	push   $0x51
  800dce:	68 3f 28 80 00       	push   $0x80283f
  800dd3:	e8 9a 12 00 00       	call   802072 <_panic>
		}
	} else {
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U) < 0) {
  800dd8:	83 ec 0c             	sub    $0xc,%esp
  800ddb:	6a 05                	push   $0x5
  800ddd:	53                   	push   %ebx
  800dde:	50                   	push   %eax
  800ddf:	53                   	push   %ebx
  800de0:	6a 00                	push   $0x0
  800de2:	e8 43 fe ff ff       	call   800c2a <sys_page_map>
  800de7:	83 c4 20             	add    $0x20,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	78 0a                	js     800df8 <duppage+0xb9>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
		}
	}

	return 0;
}
  800dee:	b8 00 00 00 00       	mov    $0x0,%eax
  800df3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800df6:	c9                   	leave  
  800df7:	c3                   	ret    
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
  800df8:	83 ec 04             	sub    $0x4,%esp
  800dfb:	68 4a 28 80 00       	push   $0x80284a
  800e00:	6a 58                	push   $0x58
  800e02:	68 3f 28 80 00       	push   $0x80283f
  800e07:	e8 66 12 00 00       	call   802072 <_panic>

00800e0c <dup_or_share>:

static void
dup_or_share(envid_t dstenv, void *va, int perm)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
  800e11:	89 c6                	mov    %eax,%esi
  800e13:	89 d3                	mov    %edx,%ebx
	int r;
	if (perm & PTE_W) {
  800e15:	f6 c1 02             	test   $0x2,%cl
  800e18:	0f 84 8c 00 00 00    	je     800eaa <dup_or_share+0x9e>
		// dup
		if ((r = sys_page_alloc(dstenv, va, PTE_P | PTE_U | PTE_W)) < 0)
  800e1e:	83 ec 04             	sub    $0x4,%esp
  800e21:	6a 07                	push   $0x7
  800e23:	52                   	push   %edx
  800e24:	50                   	push   %eax
  800e25:	e8 d8 fd ff ff       	call   800c02 <sys_page_alloc>
  800e2a:	83 c4 10             	add    $0x10,%esp
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	78 55                	js     800e86 <dup_or_share+0x7a>
			panic("sys_page_alloc: %e", r);
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  800e31:	83 ec 0c             	sub    $0xc,%esp
  800e34:	6a 07                	push   $0x7
  800e36:	68 00 00 40 00       	push   $0x400000
  800e3b:	6a 00                	push   $0x0
  800e3d:	53                   	push   %ebx
  800e3e:	56                   	push   %esi
  800e3f:	e8 e6 fd ff ff       	call   800c2a <sys_page_map>
  800e44:	83 c4 20             	add    $0x20,%esp
  800e47:	85 c0                	test   %eax,%eax
  800e49:	78 4d                	js     800e98 <dup_or_share+0x8c>
		    0)
			panic("sys_page_map: %e", r);
		memmove(UTEMP, va, PGSIZE);
  800e4b:	83 ec 04             	sub    $0x4,%esp
  800e4e:	68 00 10 00 00       	push   $0x1000
  800e53:	53                   	push   %ebx
  800e54:	68 00 00 40 00       	push   $0x400000
  800e59:	e8 d4 fa ff ff       	call   800932 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800e5e:	83 c4 08             	add    $0x8,%esp
  800e61:	68 00 00 40 00       	push   $0x400000
  800e66:	6a 00                	push   $0x0
  800e68:	e8 e7 fd ff ff       	call   800c54 <sys_page_unmap>
  800e6d:	83 c4 10             	add    $0x10,%esp
  800e70:	85 c0                	test   %eax,%eax
  800e72:	79 52                	jns    800ec6 <dup_or_share+0xba>
			panic("sys_page_unmap: %e", r);
  800e74:	50                   	push   %eax
  800e75:	68 8a 28 80 00       	push   $0x80288a
  800e7a:	6a 6c                	push   $0x6c
  800e7c:	68 3f 28 80 00       	push   $0x80283f
  800e81:	e8 ec 11 00 00       	call   802072 <_panic>
			panic("sys_page_alloc: %e", r);
  800e86:	50                   	push   %eax
  800e87:	68 66 28 80 00       	push   $0x802866
  800e8c:	6a 66                	push   $0x66
  800e8e:	68 3f 28 80 00       	push   $0x80283f
  800e93:	e8 da 11 00 00       	call   802072 <_panic>
			panic("sys_page_map: %e", r);
  800e98:	50                   	push   %eax
  800e99:	68 79 28 80 00       	push   $0x802879
  800e9e:	6a 69                	push   $0x69
  800ea0:	68 3f 28 80 00       	push   $0x80283f
  800ea5:	e8 c8 11 00 00       	call   802072 <_panic>

	} else {
		// share
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | perm)) <
  800eaa:	83 ec 0c             	sub    $0xc,%esp
  800ead:	83 c9 05             	or     $0x5,%ecx
  800eb0:	51                   	push   %ecx
  800eb1:	68 00 00 40 00       	push   $0x400000
  800eb6:	6a 00                	push   $0x0
  800eb8:	52                   	push   %edx
  800eb9:	50                   	push   %eax
  800eba:	e8 6b fd ff ff       	call   800c2a <sys_page_map>
  800ebf:	83 c4 20             	add    $0x20,%esp
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	78 07                	js     800ecd <dup_or_share+0xc1>
		    0)
			panic("sys_page_map: %e", r);
	}
}
  800ec6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec9:	5b                   	pop    %ebx
  800eca:	5e                   	pop    %esi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    
			panic("sys_page_map: %e", r);
  800ecd:	50                   	push   %eax
  800ece:	68 79 28 80 00       	push   $0x802879
  800ed3:	6a 72                	push   $0x72
  800ed5:	68 3f 28 80 00       	push   $0x80283f
  800eda:	e8 93 11 00 00       	call   802072 <_panic>

00800edf <pgfault>:
{
  800edf:	f3 0f 1e fb          	endbr32 
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	53                   	push   %ebx
  800ee7:	83 ec 04             	sub    $0x4,%esp
  800eea:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800eed:	8b 02                	mov    (%edx),%eax
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800eef:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800ef3:	0f 84 95 00 00 00    	je     800f8e <pgfault+0xaf>
  800ef9:	89 c2                	mov    %eax,%edx
  800efb:	c1 ea 16             	shr    $0x16,%edx
  800efe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f05:	f6 c2 01             	test   $0x1,%dl
  800f08:	0f 84 80 00 00 00    	je     800f8e <pgfault+0xaf>
	    (~uvpt[PGNUM(addr)] & (PTE_COW | PTE_P)) != 0) {
  800f0e:	89 c2                	mov    %eax,%edx
  800f10:	c1 ea 0c             	shr    $0xc,%edx
  800f13:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f1a:	f7 d2                	not    %edx
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800f1c:	f7 c2 01 08 00 00    	test   $0x801,%edx
  800f22:	75 6a                	jne    800f8e <pgfault+0xaf>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800f24:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f29:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U) < 0) {
  800f2b:	83 ec 04             	sub    $0x4,%esp
  800f2e:	6a 07                	push   $0x7
  800f30:	68 00 f0 7f 00       	push   $0x7ff000
  800f35:	6a 00                	push   $0x0
  800f37:	e8 c6 fc ff ff       	call   800c02 <sys_page_alloc>
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	78 5f                	js     800fa2 <pgfault+0xc3>
	memcpy((void *) PFTEMP, addr, PGSIZE);
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	68 00 10 00 00       	push   $0x1000
  800f4b:	53                   	push   %ebx
  800f4c:	68 00 f0 7f 00       	push   $0x7ff000
  800f51:	e8 42 fa ff ff       	call   800998 <memcpy>
	if (sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U) < 0) {
  800f56:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f5d:	53                   	push   %ebx
  800f5e:	6a 00                	push   $0x0
  800f60:	68 00 f0 7f 00       	push   $0x7ff000
  800f65:	6a 00                	push   $0x0
  800f67:	e8 be fc ff ff       	call   800c2a <sys_page_map>
  800f6c:	83 c4 20             	add    $0x20,%esp
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	78 43                	js     800fb6 <pgfault+0xd7>
	if (sys_page_unmap(0, (void *) PFTEMP) < 0) {
  800f73:	83 ec 08             	sub    $0x8,%esp
  800f76:	68 00 f0 7f 00       	push   $0x7ff000
  800f7b:	6a 00                	push   $0x0
  800f7d:	e8 d2 fc ff ff       	call   800c54 <sys_page_unmap>
  800f82:	83 c4 10             	add    $0x10,%esp
  800f85:	85 c0                	test   %eax,%eax
  800f87:	78 41                	js     800fca <pgfault+0xeb>
}
  800f89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f8c:	c9                   	leave  
  800f8d:	c3                   	ret    
		panic("ERROR PGFAULT");
  800f8e:	83 ec 04             	sub    $0x4,%esp
  800f91:	68 9d 28 80 00       	push   $0x80289d
  800f96:	6a 1e                	push   $0x1e
  800f98:	68 3f 28 80 00       	push   $0x80283f
  800f9d:	e8 d0 10 00 00       	call   802072 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_ALLOC");
  800fa2:	83 ec 04             	sub    $0x4,%esp
  800fa5:	68 ab 28 80 00       	push   $0x8028ab
  800faa:	6a 2b                	push   $0x2b
  800fac:	68 3f 28 80 00       	push   $0x80283f
  800fb1:	e8 bc 10 00 00       	call   802072 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_MAP");
  800fb6:	83 ec 04             	sub    $0x4,%esp
  800fb9:	68 c9 28 80 00       	push   $0x8028c9
  800fbe:	6a 2f                	push   $0x2f
  800fc0:	68 3f 28 80 00       	push   $0x80283f
  800fc5:	e8 a8 10 00 00       	call   802072 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_UNMAP");
  800fca:	83 ec 04             	sub    $0x4,%esp
  800fcd:	68 e5 28 80 00       	push   $0x8028e5
  800fd2:	6a 32                	push   $0x32
  800fd4:	68 3f 28 80 00       	push   $0x80283f
  800fd9:	e8 94 10 00 00       	call   802072 <_panic>

00800fde <fork_v0>:

envid_t
fork_v0(void)
{
  800fde:	f3 0f 1e fb          	endbr32 
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	57                   	push   %edi
  800fe6:	56                   	push   %esi
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800feb:	b8 07 00 00 00       	mov    $0x7,%eax
  800ff0:	cd 30                	int    $0x30
	envid_t env_id = sys_exofork();
	if (env_id < 0) {
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	78 24                	js     80101a <fork_v0+0x3c>
  800ff6:	89 c6                	mov    %eax,%esi
  800ff8:	89 c7                	mov    %eax,%edi
		thisenv = envs + ENVX(sys_getenvid());
		return env_id;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  800ffa:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (env_id == 0) {  // Son
  800fff:	75 51                	jne    801052 <fork_v0+0x74>
		thisenv = envs + ENVX(sys_getenvid());
  801001:	e8 a9 fb ff ff       	call   800baf <sys_getenvid>
  801006:	25 ff 03 00 00       	and    $0x3ff,%eax
  80100b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80100e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801013:	a3 08 40 80 00       	mov    %eax,0x804008
		return env_id;
  801018:	eb 78                	jmp    801092 <fork_v0+0xb4>
		panic("ERROR ON FORK_V0");
  80101a:	83 ec 04             	sub    $0x4,%esp
  80101d:	68 03 29 80 00       	push   $0x802903
  801022:	6a 7b                	push   $0x7b
  801024:	68 3f 28 80 00       	push   $0x80283f
  801029:	e8 44 10 00 00       	call   802072 <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
				dup_or_share(env_id,
  80102e:	b9 07 00 00 00       	mov    $0x7,%ecx
  801033:	89 da                	mov    %ebx,%edx
  801035:	89 f8                	mov    %edi,%eax
  801037:	e8 d0 fd ff ff       	call   800e0c <dup_or_share>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  80103c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801042:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801048:	77 36                	ja     801080 <fork_v0+0xa2>
		if (addr != UXSTACKTOP - PGSIZE) {
  80104a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801050:	74 ea                	je     80103c <fork_v0+0x5e>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801052:	89 d8                	mov    %ebx,%eax
  801054:	c1 e8 16             	shr    $0x16,%eax
  801057:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80105e:	a8 01                	test   $0x1,%al
  801060:	74 da                	je     80103c <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  801062:	89 d8                	mov    %ebx,%eax
  801064:	c1 e8 0c             	shr    $0xc,%eax
  801067:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80106e:	f6 c2 01             	test   $0x1,%dl
  801071:	74 c9                	je     80103c <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
  801073:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  80107a:	a8 04                	test   $0x4,%al
  80107c:	74 be                	je     80103c <fork_v0+0x5e>
  80107e:	eb ae                	jmp    80102e <fork_v0+0x50>
				             PTE_P | PTE_U | PTE_W);
			}
		}
	}

	if (sys_env_set_status(env_id, ENV_RUNNABLE) < 0) {
  801080:	83 ec 08             	sub    $0x8,%esp
  801083:	6a 02                	push   $0x2
  801085:	56                   	push   %esi
  801086:	e8 f0 fb ff ff       	call   800c7b <sys_env_set_status>
  80108b:	83 c4 10             	add    $0x10,%esp
  80108e:	85 c0                	test   %eax,%eax
  801090:	78 0a                	js     80109c <fork_v0+0xbe>
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
	}

	return env_id;
}
  801092:	89 f0                	mov    %esi,%eax
  801094:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801097:	5b                   	pop    %ebx
  801098:	5e                   	pop    %esi
  801099:	5f                   	pop    %edi
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
  80109c:	83 ec 04             	sub    $0x4,%esp
  80109f:	68 d0 27 80 00       	push   $0x8027d0
  8010a4:	68 92 00 00 00       	push   $0x92
  8010a9:	68 3f 28 80 00       	push   $0x80283f
  8010ae:	e8 bf 0f 00 00       	call   802072 <_panic>

008010b3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010b3:	f3 0f 1e fb          	endbr32 
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	57                   	push   %edi
  8010bb:	56                   	push   %esi
  8010bc:	53                   	push   %ebx
  8010bd:	83 ec 18             	sub    $0x18,%esp
	// return fork_v0(); // Uncomment this line if you want to run fork_v0.
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8010c0:	68 df 0e 80 00       	push   $0x800edf
  8010c5:	e8 f2 0f 00 00       	call   8020bc <set_pgfault_handler>
  8010ca:	b8 07 00 00 00       	mov    $0x7,%eax
  8010cf:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0) {
  8010d1:	83 c4 10             	add    $0x10,%esp
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	78 27                	js     8010ff <fork+0x4c>
  8010d8:	89 c7                	mov    %eax,%edi
  8010da:	89 c6                	mov    %eax,%esi
		thisenv = envs + ENVX(sys_getenvid());
		return envid;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  8010dc:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else if (envid == 0) {  // Son
  8010e1:	75 55                	jne    801138 <fork+0x85>
		thisenv = envs + ENVX(sys_getenvid());
  8010e3:	e8 c7 fa ff ff       	call   800baf <sys_getenvid>
  8010e8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010ed:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010f0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010f5:	a3 08 40 80 00       	mov    %eax,0x804008
		return envid;
  8010fa:	e9 9b 00 00 00       	jmp    80119a <fork+0xe7>
		panic("ERROR IN FORK: SYS_EXOFORK");
  8010ff:	83 ec 04             	sub    $0x4,%esp
  801102:	68 14 29 80 00       	push   $0x802914
  801107:	68 b1 00 00 00       	push   $0xb1
  80110c:	68 3f 28 80 00       	push   $0x80283f
  801111:	e8 5c 0f 00 00       	call   802072 <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
				duppage(envid, addr / PGSIZE);
  801116:	89 da                	mov    %ebx,%edx
  801118:	c1 ea 0c             	shr    $0xc,%edx
  80111b:	89 f0                	mov    %esi,%eax
  80111d:	e8 1d fc ff ff       	call   800d3f <duppage>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801122:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801128:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  80112e:	77 2c                	ja     80115c <fork+0xa9>
		if (addr != UXSTACKTOP - PGSIZE) {
  801130:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801136:	74 ea                	je     801122 <fork+0x6f>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801138:	89 d8                	mov    %ebx,%eax
  80113a:	c1 e8 16             	shr    $0x16,%eax
  80113d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801144:	a8 01                	test   $0x1,%al
  801146:	74 da                	je     801122 <fork+0x6f>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
  801148:	89 d8                	mov    %ebx,%eax
  80114a:	c1 e8 0c             	shr    $0xc,%eax
  80114d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801154:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801156:	a8 05                	test   $0x5,%al
  801158:	75 c8                	jne    801122 <fork+0x6f>
  80115a:	eb ba                	jmp    801116 <fork+0x63>
			}
		}
	}

	if (sys_page_alloc(envid,
  80115c:	83 ec 04             	sub    $0x4,%esp
  80115f:	6a 07                	push   $0x7
  801161:	68 00 f0 bf ee       	push   $0xeebff000
  801166:	57                   	push   %edi
  801167:	e8 96 fa ff ff       	call   800c02 <sys_page_alloc>
  80116c:	83 c4 10             	add    $0x10,%esp
  80116f:	85 c0                	test   %eax,%eax
  801171:	78 31                	js     8011a4 <fork+0xf1>
	                   PTE_P | PTE_U | PTE_W) < 0) {
		panic("ERROR FORK: SYS_PAGE_ALLOC");
	}

	extern void _pgfault_upcall(void);
	if (sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0) {
  801173:	83 ec 08             	sub    $0x8,%esp
  801176:	68 2f 21 80 00       	push   $0x80212f
  80117b:	57                   	push   %edi
  80117c:	e8 48 fb ff ff       	call   800cc9 <sys_env_set_pgfault_upcall>
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	85 c0                	test   %eax,%eax
  801186:	78 33                	js     8011bb <fork+0x108>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
	}

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0) {
  801188:	83 ec 08             	sub    $0x8,%esp
  80118b:	6a 02                	push   $0x2
  80118d:	57                   	push   %edi
  80118e:	e8 e8 fa ff ff       	call   800c7b <sys_env_set_status>
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	85 c0                	test   %eax,%eax
  801198:	78 38                	js     8011d2 <fork+0x11f>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
	}

	return envid;
}
  80119a:	89 f8                	mov    %edi,%eax
  80119c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119f:	5b                   	pop    %ebx
  8011a0:	5e                   	pop    %esi
  8011a1:	5f                   	pop    %edi
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    
		panic("ERROR FORK: SYS_PAGE_ALLOC");
  8011a4:	83 ec 04             	sub    $0x4,%esp
  8011a7:	68 2f 29 80 00       	push   $0x80292f
  8011ac:	68 c4 00 00 00       	push   $0xc4
  8011b1:	68 3f 28 80 00       	push   $0x80283f
  8011b6:	e8 b7 0e 00 00       	call   802072 <_panic>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
  8011bb:	83 ec 04             	sub    $0x4,%esp
  8011be:	68 f8 27 80 00       	push   $0x8027f8
  8011c3:	68 c9 00 00 00       	push   $0xc9
  8011c8:	68 3f 28 80 00       	push   $0x80283f
  8011cd:	e8 a0 0e 00 00       	call   802072 <_panic>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
  8011d2:	83 ec 04             	sub    $0x4,%esp
  8011d5:	68 20 28 80 00       	push   $0x802820
  8011da:	68 cd 00 00 00       	push   $0xcd
  8011df:	68 3f 28 80 00       	push   $0x80283f
  8011e4:	e8 89 0e 00 00       	call   802072 <_panic>

008011e9 <sfork>:

// Challenge!
int
sfork(void)
{
  8011e9:	f3 0f 1e fb          	endbr32 
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011f3:	68 4a 29 80 00       	push   $0x80294a
  8011f8:	68 d7 00 00 00       	push   $0xd7
  8011fd:	68 3f 28 80 00       	push   $0x80283f
  801202:	e8 6b 0e 00 00       	call   802072 <_panic>

00801207 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801207:	f3 0f 1e fb          	endbr32 
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	56                   	push   %esi
  80120f:	53                   	push   %ebx
  801210:	8b 75 08             	mov    0x8(%ebp),%esi
  801213:	8b 45 0c             	mov    0xc(%ebp),%eax
  801216:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  801219:	85 c0                	test   %eax,%eax
  80121b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801220:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801223:	83 ec 0c             	sub    $0xc,%esp
  801226:	50                   	push   %eax
  801227:	e8 ed fa ff ff       	call   800d19 <sys_ipc_recv>
	if (f < 0) {
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	78 2b                	js     80125e <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801233:	85 f6                	test   %esi,%esi
  801235:	74 0a                	je     801241 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801237:	a1 08 40 80 00       	mov    0x804008,%eax
  80123c:	8b 40 74             	mov    0x74(%eax),%eax
  80123f:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801241:	85 db                	test   %ebx,%ebx
  801243:	74 0a                	je     80124f <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801245:	a1 08 40 80 00       	mov    0x804008,%eax
  80124a:	8b 40 78             	mov    0x78(%eax),%eax
  80124d:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  80124f:	a1 08 40 80 00       	mov    0x804008,%eax
  801254:	8b 40 70             	mov    0x70(%eax),%eax
}
  801257:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80125a:	5b                   	pop    %ebx
  80125b:	5e                   	pop    %esi
  80125c:	5d                   	pop    %ebp
  80125d:	c3                   	ret    
		if (from_env_store != NULL) {
  80125e:	85 f6                	test   %esi,%esi
  801260:	74 06                	je     801268 <ipc_recv+0x61>
			*from_env_store = 0;
  801262:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801268:	85 db                	test   %ebx,%ebx
  80126a:	74 eb                	je     801257 <ipc_recv+0x50>
			*perm_store = 0;
  80126c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801272:	eb e3                	jmp    801257 <ipc_recv+0x50>

00801274 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801274:	f3 0f 1e fb          	endbr32 
  801278:	55                   	push   %ebp
  801279:	89 e5                	mov    %esp,%ebp
  80127b:	57                   	push   %edi
  80127c:	56                   	push   %esi
  80127d:	53                   	push   %ebx
  80127e:	83 ec 0c             	sub    $0xc,%esp
  801281:	8b 7d 08             	mov    0x8(%ebp),%edi
  801284:	8b 75 0c             	mov    0xc(%ebp),%esi
  801287:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  80128a:	85 db                	test   %ebx,%ebx
  80128c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801291:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801294:	ff 75 14             	pushl  0x14(%ebp)
  801297:	53                   	push   %ebx
  801298:	56                   	push   %esi
  801299:	57                   	push   %edi
  80129a:	e8 51 fa ff ff       	call   800cf0 <sys_ipc_try_send>
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	79 19                	jns    8012bf <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  8012a6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012a9:	74 e9                	je     801294 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  8012ab:	83 ec 04             	sub    $0x4,%esp
  8012ae:	68 60 29 80 00       	push   $0x802960
  8012b3:	6a 48                	push   $0x48
  8012b5:	68 82 29 80 00       	push   $0x802982
  8012ba:	e8 b3 0d 00 00       	call   802072 <_panic>
		}
	}
}
  8012bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c2:	5b                   	pop    %ebx
  8012c3:	5e                   	pop    %esi
  8012c4:	5f                   	pop    %edi
  8012c5:	5d                   	pop    %ebp
  8012c6:	c3                   	ret    

008012c7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012c7:	f3 0f 1e fb          	endbr32 
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012d1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012d6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012d9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012df:	8b 52 50             	mov    0x50(%edx),%edx
  8012e2:	39 ca                	cmp    %ecx,%edx
  8012e4:	74 11                	je     8012f7 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8012e6:	83 c0 01             	add    $0x1,%eax
  8012e9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012ee:	75 e6                	jne    8012d6 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8012f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f5:	eb 0b                	jmp    801302 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8012f7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012fa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012ff:	8b 40 48             	mov    0x48(%eax),%eax
}
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    

00801304 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801304:	f3 0f 1e fb          	endbr32 
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80130b:	8b 45 08             	mov    0x8(%ebp),%eax
  80130e:	05 00 00 00 30       	add    $0x30000000,%eax
  801313:	c1 e8 0c             	shr    $0xc,%eax
}
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801318:	f3 0f 1e fb          	endbr32 
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  801322:	ff 75 08             	pushl  0x8(%ebp)
  801325:	e8 da ff ff ff       	call   801304 <fd2num>
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	c1 e0 0c             	shl    $0xc,%eax
  801330:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801335:	c9                   	leave  
  801336:	c3                   	ret    

00801337 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801337:	f3 0f 1e fb          	endbr32 
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801343:	89 c2                	mov    %eax,%edx
  801345:	c1 ea 16             	shr    $0x16,%edx
  801348:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80134f:	f6 c2 01             	test   $0x1,%dl
  801352:	74 2d                	je     801381 <fd_alloc+0x4a>
  801354:	89 c2                	mov    %eax,%edx
  801356:	c1 ea 0c             	shr    $0xc,%edx
  801359:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801360:	f6 c2 01             	test   $0x1,%dl
  801363:	74 1c                	je     801381 <fd_alloc+0x4a>
  801365:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80136a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80136f:	75 d2                	jne    801343 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801371:	8b 45 08             	mov    0x8(%ebp),%eax
  801374:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80137a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80137f:	eb 0a                	jmp    80138b <fd_alloc+0x54>
			*fd_store = fd;
  801381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801384:	89 01                	mov    %eax,(%ecx)
			return 0;
  801386:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80138b:	5d                   	pop    %ebp
  80138c:	c3                   	ret    

0080138d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80138d:	f3 0f 1e fb          	endbr32 
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801397:	83 f8 1f             	cmp    $0x1f,%eax
  80139a:	77 30                	ja     8013cc <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80139c:	c1 e0 0c             	shl    $0xc,%eax
  80139f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013a4:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8013aa:	f6 c2 01             	test   $0x1,%dl
  8013ad:	74 24                	je     8013d3 <fd_lookup+0x46>
  8013af:	89 c2                	mov    %eax,%edx
  8013b1:	c1 ea 0c             	shr    $0xc,%edx
  8013b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013bb:	f6 c2 01             	test   $0x1,%dl
  8013be:	74 1a                	je     8013da <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c3:	89 02                	mov    %eax,(%edx)
	return 0;
  8013c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    
		return -E_INVAL;
  8013cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d1:	eb f7                	jmp    8013ca <fd_lookup+0x3d>
		return -E_INVAL;
  8013d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d8:	eb f0                	jmp    8013ca <fd_lookup+0x3d>
  8013da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013df:	eb e9                	jmp    8013ca <fd_lookup+0x3d>

008013e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013e1:	f3 0f 1e fb          	endbr32 
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	83 ec 08             	sub    $0x8,%esp
  8013eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ee:	ba 08 2a 80 00       	mov    $0x802a08,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013f3:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8013f8:	39 08                	cmp    %ecx,(%eax)
  8013fa:	74 33                	je     80142f <dev_lookup+0x4e>
  8013fc:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8013ff:	8b 02                	mov    (%edx),%eax
  801401:	85 c0                	test   %eax,%eax
  801403:	75 f3                	jne    8013f8 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801405:	a1 08 40 80 00       	mov    0x804008,%eax
  80140a:	8b 40 48             	mov    0x48(%eax),%eax
  80140d:	83 ec 04             	sub    $0x4,%esp
  801410:	51                   	push   %ecx
  801411:	50                   	push   %eax
  801412:	68 8c 29 80 00       	push   $0x80298c
  801417:	e8 f4 ed ff ff       	call   800210 <cprintf>
	*dev = 0;
  80141c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80142d:	c9                   	leave  
  80142e:	c3                   	ret    
			*dev = devtab[i];
  80142f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801432:	89 01                	mov    %eax,(%ecx)
			return 0;
  801434:	b8 00 00 00 00       	mov    $0x0,%eax
  801439:	eb f2                	jmp    80142d <dev_lookup+0x4c>

0080143b <fd_close>:
{
  80143b:	f3 0f 1e fb          	endbr32 
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	57                   	push   %edi
  801443:	56                   	push   %esi
  801444:	53                   	push   %ebx
  801445:	83 ec 28             	sub    $0x28,%esp
  801448:	8b 75 08             	mov    0x8(%ebp),%esi
  80144b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80144e:	56                   	push   %esi
  80144f:	e8 b0 fe ff ff       	call   801304 <fd2num>
  801454:	83 c4 08             	add    $0x8,%esp
  801457:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80145a:	52                   	push   %edx
  80145b:	50                   	push   %eax
  80145c:	e8 2c ff ff ff       	call   80138d <fd_lookup>
  801461:	89 c3                	mov    %eax,%ebx
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	85 c0                	test   %eax,%eax
  801468:	78 05                	js     80146f <fd_close+0x34>
	    || fd != fd2)
  80146a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80146d:	74 16                	je     801485 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80146f:	89 f8                	mov    %edi,%eax
  801471:	84 c0                	test   %al,%al
  801473:	b8 00 00 00 00       	mov    $0x0,%eax
  801478:	0f 44 d8             	cmove  %eax,%ebx
}
  80147b:	89 d8                	mov    %ebx,%eax
  80147d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801480:	5b                   	pop    %ebx
  801481:	5e                   	pop    %esi
  801482:	5f                   	pop    %edi
  801483:	5d                   	pop    %ebp
  801484:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801485:	83 ec 08             	sub    $0x8,%esp
  801488:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80148b:	50                   	push   %eax
  80148c:	ff 36                	pushl  (%esi)
  80148e:	e8 4e ff ff ff       	call   8013e1 <dev_lookup>
  801493:	89 c3                	mov    %eax,%ebx
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 1a                	js     8014b6 <fd_close+0x7b>
		if (dev->dev_close)
  80149c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80149f:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8014a2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	74 0b                	je     8014b6 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8014ab:	83 ec 0c             	sub    $0xc,%esp
  8014ae:	56                   	push   %esi
  8014af:	ff d0                	call   *%eax
  8014b1:	89 c3                	mov    %eax,%ebx
  8014b3:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8014b6:	83 ec 08             	sub    $0x8,%esp
  8014b9:	56                   	push   %esi
  8014ba:	6a 00                	push   $0x0
  8014bc:	e8 93 f7 ff ff       	call   800c54 <sys_page_unmap>
	return r;
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	eb b5                	jmp    80147b <fd_close+0x40>

008014c6 <close>:

int
close(int fdnum)
{
  8014c6:	f3 0f 1e fb          	endbr32 
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d3:	50                   	push   %eax
  8014d4:	ff 75 08             	pushl  0x8(%ebp)
  8014d7:	e8 b1 fe ff ff       	call   80138d <fd_lookup>
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	79 02                	jns    8014e5 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    
		return fd_close(fd, 1);
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	6a 01                	push   $0x1
  8014ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ed:	e8 49 ff ff ff       	call   80143b <fd_close>
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	eb ec                	jmp    8014e3 <close+0x1d>

008014f7 <close_all>:

void
close_all(void)
{
  8014f7:	f3 0f 1e fb          	endbr32 
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	53                   	push   %ebx
  8014ff:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801502:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801507:	83 ec 0c             	sub    $0xc,%esp
  80150a:	53                   	push   %ebx
  80150b:	e8 b6 ff ff ff       	call   8014c6 <close>
	for (i = 0; i < MAXFD; i++)
  801510:	83 c3 01             	add    $0x1,%ebx
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	83 fb 20             	cmp    $0x20,%ebx
  801519:	75 ec                	jne    801507 <close_all+0x10>
}
  80151b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151e:	c9                   	leave  
  80151f:	c3                   	ret    

00801520 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801520:	f3 0f 1e fb          	endbr32 
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	57                   	push   %edi
  801528:	56                   	push   %esi
  801529:	53                   	push   %ebx
  80152a:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80152d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801530:	50                   	push   %eax
  801531:	ff 75 08             	pushl  0x8(%ebp)
  801534:	e8 54 fe ff ff       	call   80138d <fd_lookup>
  801539:	89 c3                	mov    %eax,%ebx
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	85 c0                	test   %eax,%eax
  801540:	0f 88 81 00 00 00    	js     8015c7 <dup+0xa7>
		return r;
	close(newfdnum);
  801546:	83 ec 0c             	sub    $0xc,%esp
  801549:	ff 75 0c             	pushl  0xc(%ebp)
  80154c:	e8 75 ff ff ff       	call   8014c6 <close>

	newfd = INDEX2FD(newfdnum);
  801551:	8b 75 0c             	mov    0xc(%ebp),%esi
  801554:	c1 e6 0c             	shl    $0xc,%esi
  801557:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80155d:	83 c4 04             	add    $0x4,%esp
  801560:	ff 75 e4             	pushl  -0x1c(%ebp)
  801563:	e8 b0 fd ff ff       	call   801318 <fd2data>
  801568:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80156a:	89 34 24             	mov    %esi,(%esp)
  80156d:	e8 a6 fd ff ff       	call   801318 <fd2data>
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801577:	89 d8                	mov    %ebx,%eax
  801579:	c1 e8 16             	shr    $0x16,%eax
  80157c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801583:	a8 01                	test   $0x1,%al
  801585:	74 11                	je     801598 <dup+0x78>
  801587:	89 d8                	mov    %ebx,%eax
  801589:	c1 e8 0c             	shr    $0xc,%eax
  80158c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801593:	f6 c2 01             	test   $0x1,%dl
  801596:	75 39                	jne    8015d1 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801598:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80159b:	89 d0                	mov    %edx,%eax
  80159d:	c1 e8 0c             	shr    $0xc,%eax
  8015a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015a7:	83 ec 0c             	sub    $0xc,%esp
  8015aa:	25 07 0e 00 00       	and    $0xe07,%eax
  8015af:	50                   	push   %eax
  8015b0:	56                   	push   %esi
  8015b1:	6a 00                	push   $0x0
  8015b3:	52                   	push   %edx
  8015b4:	6a 00                	push   $0x0
  8015b6:	e8 6f f6 ff ff       	call   800c2a <sys_page_map>
  8015bb:	89 c3                	mov    %eax,%ebx
  8015bd:	83 c4 20             	add    $0x20,%esp
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	78 31                	js     8015f5 <dup+0xd5>
		goto err;

	return newfdnum;
  8015c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015c7:	89 d8                	mov    %ebx,%eax
  8015c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015cc:	5b                   	pop    %ebx
  8015cd:	5e                   	pop    %esi
  8015ce:	5f                   	pop    %edi
  8015cf:	5d                   	pop    %ebp
  8015d0:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015d1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015d8:	83 ec 0c             	sub    $0xc,%esp
  8015db:	25 07 0e 00 00       	and    $0xe07,%eax
  8015e0:	50                   	push   %eax
  8015e1:	57                   	push   %edi
  8015e2:	6a 00                	push   $0x0
  8015e4:	53                   	push   %ebx
  8015e5:	6a 00                	push   $0x0
  8015e7:	e8 3e f6 ff ff       	call   800c2a <sys_page_map>
  8015ec:	89 c3                	mov    %eax,%ebx
  8015ee:	83 c4 20             	add    $0x20,%esp
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	79 a3                	jns    801598 <dup+0x78>
	sys_page_unmap(0, newfd);
  8015f5:	83 ec 08             	sub    $0x8,%esp
  8015f8:	56                   	push   %esi
  8015f9:	6a 00                	push   $0x0
  8015fb:	e8 54 f6 ff ff       	call   800c54 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801600:	83 c4 08             	add    $0x8,%esp
  801603:	57                   	push   %edi
  801604:	6a 00                	push   $0x0
  801606:	e8 49 f6 ff ff       	call   800c54 <sys_page_unmap>
	return r;
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	eb b7                	jmp    8015c7 <dup+0xa7>

00801610 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801610:	f3 0f 1e fb          	endbr32 
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	53                   	push   %ebx
  801618:	83 ec 1c             	sub    $0x1c,%esp
  80161b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80161e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801621:	50                   	push   %eax
  801622:	53                   	push   %ebx
  801623:	e8 65 fd ff ff       	call   80138d <fd_lookup>
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 3f                	js     80166e <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801635:	50                   	push   %eax
  801636:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801639:	ff 30                	pushl  (%eax)
  80163b:	e8 a1 fd ff ff       	call   8013e1 <dev_lookup>
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	85 c0                	test   %eax,%eax
  801645:	78 27                	js     80166e <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801647:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80164a:	8b 42 08             	mov    0x8(%edx),%eax
  80164d:	83 e0 03             	and    $0x3,%eax
  801650:	83 f8 01             	cmp    $0x1,%eax
  801653:	74 1e                	je     801673 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801655:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801658:	8b 40 08             	mov    0x8(%eax),%eax
  80165b:	85 c0                	test   %eax,%eax
  80165d:	74 35                	je     801694 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80165f:	83 ec 04             	sub    $0x4,%esp
  801662:	ff 75 10             	pushl  0x10(%ebp)
  801665:	ff 75 0c             	pushl  0xc(%ebp)
  801668:	52                   	push   %edx
  801669:	ff d0                	call   *%eax
  80166b:	83 c4 10             	add    $0x10,%esp
}
  80166e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801671:	c9                   	leave  
  801672:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801673:	a1 08 40 80 00       	mov    0x804008,%eax
  801678:	8b 40 48             	mov    0x48(%eax),%eax
  80167b:	83 ec 04             	sub    $0x4,%esp
  80167e:	53                   	push   %ebx
  80167f:	50                   	push   %eax
  801680:	68 cd 29 80 00       	push   $0x8029cd
  801685:	e8 86 eb ff ff       	call   800210 <cprintf>
		return -E_INVAL;
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801692:	eb da                	jmp    80166e <read+0x5e>
		return -E_NOT_SUPP;
  801694:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801699:	eb d3                	jmp    80166e <read+0x5e>

0080169b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80169b:	f3 0f 1e fb          	endbr32 
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	57                   	push   %edi
  8016a3:	56                   	push   %esi
  8016a4:	53                   	push   %ebx
  8016a5:	83 ec 0c             	sub    $0xc,%esp
  8016a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016ab:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b3:	eb 02                	jmp    8016b7 <readn+0x1c>
  8016b5:	01 c3                	add    %eax,%ebx
  8016b7:	39 f3                	cmp    %esi,%ebx
  8016b9:	73 21                	jae    8016dc <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016bb:	83 ec 04             	sub    $0x4,%esp
  8016be:	89 f0                	mov    %esi,%eax
  8016c0:	29 d8                	sub    %ebx,%eax
  8016c2:	50                   	push   %eax
  8016c3:	89 d8                	mov    %ebx,%eax
  8016c5:	03 45 0c             	add    0xc(%ebp),%eax
  8016c8:	50                   	push   %eax
  8016c9:	57                   	push   %edi
  8016ca:	e8 41 ff ff ff       	call   801610 <read>
		if (m < 0)
  8016cf:	83 c4 10             	add    $0x10,%esp
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	78 04                	js     8016da <readn+0x3f>
			return m;
		if (m == 0)
  8016d6:	75 dd                	jne    8016b5 <readn+0x1a>
  8016d8:	eb 02                	jmp    8016dc <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016da:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8016dc:	89 d8                	mov    %ebx,%eax
  8016de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e1:	5b                   	pop    %ebx
  8016e2:	5e                   	pop    %esi
  8016e3:	5f                   	pop    %edi
  8016e4:	5d                   	pop    %ebp
  8016e5:	c3                   	ret    

008016e6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016e6:	f3 0f 1e fb          	endbr32 
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	53                   	push   %ebx
  8016ee:	83 ec 1c             	sub    $0x1c,%esp
  8016f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f7:	50                   	push   %eax
  8016f8:	53                   	push   %ebx
  8016f9:	e8 8f fc ff ff       	call   80138d <fd_lookup>
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	85 c0                	test   %eax,%eax
  801703:	78 3a                	js     80173f <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801705:	83 ec 08             	sub    $0x8,%esp
  801708:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170b:	50                   	push   %eax
  80170c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170f:	ff 30                	pushl  (%eax)
  801711:	e8 cb fc ff ff       	call   8013e1 <dev_lookup>
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	85 c0                	test   %eax,%eax
  80171b:	78 22                	js     80173f <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80171d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801720:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801724:	74 1e                	je     801744 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801726:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801729:	8b 52 0c             	mov    0xc(%edx),%edx
  80172c:	85 d2                	test   %edx,%edx
  80172e:	74 35                	je     801765 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801730:	83 ec 04             	sub    $0x4,%esp
  801733:	ff 75 10             	pushl  0x10(%ebp)
  801736:	ff 75 0c             	pushl  0xc(%ebp)
  801739:	50                   	push   %eax
  80173a:	ff d2                	call   *%edx
  80173c:	83 c4 10             	add    $0x10,%esp
}
  80173f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801742:	c9                   	leave  
  801743:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801744:	a1 08 40 80 00       	mov    0x804008,%eax
  801749:	8b 40 48             	mov    0x48(%eax),%eax
  80174c:	83 ec 04             	sub    $0x4,%esp
  80174f:	53                   	push   %ebx
  801750:	50                   	push   %eax
  801751:	68 e9 29 80 00       	push   $0x8029e9
  801756:	e8 b5 ea ff ff       	call   800210 <cprintf>
		return -E_INVAL;
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801763:	eb da                	jmp    80173f <write+0x59>
		return -E_NOT_SUPP;
  801765:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80176a:	eb d3                	jmp    80173f <write+0x59>

0080176c <seek>:

int
seek(int fdnum, off_t offset)
{
  80176c:	f3 0f 1e fb          	endbr32 
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801776:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801779:	50                   	push   %eax
  80177a:	ff 75 08             	pushl  0x8(%ebp)
  80177d:	e8 0b fc ff ff       	call   80138d <fd_lookup>
  801782:	83 c4 10             	add    $0x10,%esp
  801785:	85 c0                	test   %eax,%eax
  801787:	78 0e                	js     801797 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801789:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801792:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801797:	c9                   	leave  
  801798:	c3                   	ret    

00801799 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801799:	f3 0f 1e fb          	endbr32 
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	53                   	push   %ebx
  8017a1:	83 ec 1c             	sub    $0x1c,%esp
  8017a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017aa:	50                   	push   %eax
  8017ab:	53                   	push   %ebx
  8017ac:	e8 dc fb ff ff       	call   80138d <fd_lookup>
  8017b1:	83 c4 10             	add    $0x10,%esp
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	78 37                	js     8017ef <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b8:	83 ec 08             	sub    $0x8,%esp
  8017bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017be:	50                   	push   %eax
  8017bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c2:	ff 30                	pushl  (%eax)
  8017c4:	e8 18 fc ff ff       	call   8013e1 <dev_lookup>
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	78 1f                	js     8017ef <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017d7:	74 1b                	je     8017f4 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8017d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017dc:	8b 52 18             	mov    0x18(%edx),%edx
  8017df:	85 d2                	test   %edx,%edx
  8017e1:	74 32                	je     801815 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017e3:	83 ec 08             	sub    $0x8,%esp
  8017e6:	ff 75 0c             	pushl  0xc(%ebp)
  8017e9:	50                   	push   %eax
  8017ea:	ff d2                	call   *%edx
  8017ec:	83 c4 10             	add    $0x10,%esp
}
  8017ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f2:	c9                   	leave  
  8017f3:	c3                   	ret    
			thisenv->env_id, fdnum);
  8017f4:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017f9:	8b 40 48             	mov    0x48(%eax),%eax
  8017fc:	83 ec 04             	sub    $0x4,%esp
  8017ff:	53                   	push   %ebx
  801800:	50                   	push   %eax
  801801:	68 ac 29 80 00       	push   $0x8029ac
  801806:	e8 05 ea ff ff       	call   800210 <cprintf>
		return -E_INVAL;
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801813:	eb da                	jmp    8017ef <ftruncate+0x56>
		return -E_NOT_SUPP;
  801815:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80181a:	eb d3                	jmp    8017ef <ftruncate+0x56>

0080181c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80181c:	f3 0f 1e fb          	endbr32 
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	53                   	push   %ebx
  801824:	83 ec 1c             	sub    $0x1c,%esp
  801827:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182d:	50                   	push   %eax
  80182e:	ff 75 08             	pushl  0x8(%ebp)
  801831:	e8 57 fb ff ff       	call   80138d <fd_lookup>
  801836:	83 c4 10             	add    $0x10,%esp
  801839:	85 c0                	test   %eax,%eax
  80183b:	78 4b                	js     801888 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183d:	83 ec 08             	sub    $0x8,%esp
  801840:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801843:	50                   	push   %eax
  801844:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801847:	ff 30                	pushl  (%eax)
  801849:	e8 93 fb ff ff       	call   8013e1 <dev_lookup>
  80184e:	83 c4 10             	add    $0x10,%esp
  801851:	85 c0                	test   %eax,%eax
  801853:	78 33                	js     801888 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801855:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801858:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80185c:	74 2f                	je     80188d <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80185e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801861:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801868:	00 00 00 
	stat->st_isdir = 0;
  80186b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801872:	00 00 00 
	stat->st_dev = dev;
  801875:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80187b:	83 ec 08             	sub    $0x8,%esp
  80187e:	53                   	push   %ebx
  80187f:	ff 75 f0             	pushl  -0x10(%ebp)
  801882:	ff 50 14             	call   *0x14(%eax)
  801885:	83 c4 10             	add    $0x10,%esp
}
  801888:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188b:	c9                   	leave  
  80188c:	c3                   	ret    
		return -E_NOT_SUPP;
  80188d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801892:	eb f4                	jmp    801888 <fstat+0x6c>

00801894 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801894:	f3 0f 1e fb          	endbr32 
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	56                   	push   %esi
  80189c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80189d:	83 ec 08             	sub    $0x8,%esp
  8018a0:	6a 00                	push   $0x0
  8018a2:	ff 75 08             	pushl  0x8(%ebp)
  8018a5:	e8 20 02 00 00       	call   801aca <open>
  8018aa:	89 c3                	mov    %eax,%ebx
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 1b                	js     8018ce <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8018b3:	83 ec 08             	sub    $0x8,%esp
  8018b6:	ff 75 0c             	pushl  0xc(%ebp)
  8018b9:	50                   	push   %eax
  8018ba:	e8 5d ff ff ff       	call   80181c <fstat>
  8018bf:	89 c6                	mov    %eax,%esi
	close(fd);
  8018c1:	89 1c 24             	mov    %ebx,(%esp)
  8018c4:	e8 fd fb ff ff       	call   8014c6 <close>
	return r;
  8018c9:	83 c4 10             	add    $0x10,%esp
  8018cc:	89 f3                	mov    %esi,%ebx
}
  8018ce:	89 d8                	mov    %ebx,%eax
  8018d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d3:	5b                   	pop    %ebx
  8018d4:	5e                   	pop    %esi
  8018d5:	5d                   	pop    %ebp
  8018d6:	c3                   	ret    

008018d7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	56                   	push   %esi
  8018db:	53                   	push   %ebx
  8018dc:	89 c6                	mov    %eax,%esi
  8018de:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018e0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018e7:	74 27                	je     801910 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018e9:	6a 07                	push   $0x7
  8018eb:	68 00 50 80 00       	push   $0x805000
  8018f0:	56                   	push   %esi
  8018f1:	ff 35 00 40 80 00    	pushl  0x804000
  8018f7:	e8 78 f9 ff ff       	call   801274 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018fc:	83 c4 0c             	add    $0xc,%esp
  8018ff:	6a 00                	push   $0x0
  801901:	53                   	push   %ebx
  801902:	6a 00                	push   $0x0
  801904:	e8 fe f8 ff ff       	call   801207 <ipc_recv>
}
  801909:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190c:	5b                   	pop    %ebx
  80190d:	5e                   	pop    %esi
  80190e:	5d                   	pop    %ebp
  80190f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801910:	83 ec 0c             	sub    $0xc,%esp
  801913:	6a 01                	push   $0x1
  801915:	e8 ad f9 ff ff       	call   8012c7 <ipc_find_env>
  80191a:	a3 00 40 80 00       	mov    %eax,0x804000
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	eb c5                	jmp    8018e9 <fsipc+0x12>

00801924 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801924:	f3 0f 1e fb          	endbr32 
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80192e:	8b 45 08             	mov    0x8(%ebp),%eax
  801931:	8b 40 0c             	mov    0xc(%eax),%eax
  801934:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801939:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801941:	ba 00 00 00 00       	mov    $0x0,%edx
  801946:	b8 02 00 00 00       	mov    $0x2,%eax
  80194b:	e8 87 ff ff ff       	call   8018d7 <fsipc>
}
  801950:	c9                   	leave  
  801951:	c3                   	ret    

00801952 <devfile_flush>:
{
  801952:	f3 0f 1e fb          	endbr32 
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80195c:	8b 45 08             	mov    0x8(%ebp),%eax
  80195f:	8b 40 0c             	mov    0xc(%eax),%eax
  801962:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801967:	ba 00 00 00 00       	mov    $0x0,%edx
  80196c:	b8 06 00 00 00       	mov    $0x6,%eax
  801971:	e8 61 ff ff ff       	call   8018d7 <fsipc>
}
  801976:	c9                   	leave  
  801977:	c3                   	ret    

00801978 <devfile_stat>:
{
  801978:	f3 0f 1e fb          	endbr32 
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	53                   	push   %ebx
  801980:	83 ec 04             	sub    $0x4,%esp
  801983:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801986:	8b 45 08             	mov    0x8(%ebp),%eax
  801989:	8b 40 0c             	mov    0xc(%eax),%eax
  80198c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801991:	ba 00 00 00 00       	mov    $0x0,%edx
  801996:	b8 05 00 00 00       	mov    $0x5,%eax
  80199b:	e8 37 ff ff ff       	call   8018d7 <fsipc>
  8019a0:	85 c0                	test   %eax,%eax
  8019a2:	78 2c                	js     8019d0 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019a4:	83 ec 08             	sub    $0x8,%esp
  8019a7:	68 00 50 80 00       	push   $0x805000
  8019ac:	53                   	push   %ebx
  8019ad:	e8 c8 ed ff ff       	call   80077a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019b2:	a1 80 50 80 00       	mov    0x805080,%eax
  8019b7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019bd:	a1 84 50 80 00       	mov    0x805084,%eax
  8019c2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019c8:	83 c4 10             	add    $0x10,%esp
  8019cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d3:	c9                   	leave  
  8019d4:	c3                   	ret    

008019d5 <devfile_write>:
{
  8019d5:	f3 0f 1e fb          	endbr32 
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	57                   	push   %edi
  8019dd:	56                   	push   %esi
  8019de:	53                   	push   %ebx
  8019df:	83 ec 0c             	sub    $0xc,%esp
  8019e2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ee:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  8019f3:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8019f8:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  8019fd:	85 db                	test   %ebx,%ebx
  8019ff:	74 3b                	je     801a3c <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a01:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801a07:	89 f8                	mov    %edi,%eax
  801a09:	0f 46 c3             	cmovbe %ebx,%eax
  801a0c:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  801a11:	83 ec 04             	sub    $0x4,%esp
  801a14:	50                   	push   %eax
  801a15:	56                   	push   %esi
  801a16:	68 08 50 80 00       	push   $0x805008
  801a1b:	e8 12 ef ff ff       	call   800932 <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a20:	ba 00 00 00 00       	mov    $0x0,%edx
  801a25:	b8 04 00 00 00       	mov    $0x4,%eax
  801a2a:	e8 a8 fe ff ff       	call   8018d7 <fsipc>
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	85 c0                	test   %eax,%eax
  801a34:	78 06                	js     801a3c <devfile_write+0x67>
		buf_aux += r;
  801a36:	01 c6                	add    %eax,%esi
		n -= r;
  801a38:	29 c3                	sub    %eax,%ebx
  801a3a:	eb c1                	jmp    8019fd <devfile_write+0x28>
}
  801a3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a3f:	5b                   	pop    %ebx
  801a40:	5e                   	pop    %esi
  801a41:	5f                   	pop    %edi
  801a42:	5d                   	pop    %ebp
  801a43:	c3                   	ret    

00801a44 <devfile_read>:
{
  801a44:	f3 0f 1e fb          	endbr32 
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	56                   	push   %esi
  801a4c:	53                   	push   %ebx
  801a4d:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a50:	8b 45 08             	mov    0x8(%ebp),%eax
  801a53:	8b 40 0c             	mov    0xc(%eax),%eax
  801a56:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a5b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a61:	ba 00 00 00 00       	mov    $0x0,%edx
  801a66:	b8 03 00 00 00       	mov    $0x3,%eax
  801a6b:	e8 67 fe ff ff       	call   8018d7 <fsipc>
  801a70:	89 c3                	mov    %eax,%ebx
  801a72:	85 c0                	test   %eax,%eax
  801a74:	78 1f                	js     801a95 <devfile_read+0x51>
	assert(r <= n);
  801a76:	39 f0                	cmp    %esi,%eax
  801a78:	77 24                	ja     801a9e <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801a7a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a7f:	7f 33                	jg     801ab4 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a81:	83 ec 04             	sub    $0x4,%esp
  801a84:	50                   	push   %eax
  801a85:	68 00 50 80 00       	push   $0x805000
  801a8a:	ff 75 0c             	pushl  0xc(%ebp)
  801a8d:	e8 a0 ee ff ff       	call   800932 <memmove>
	return r;
  801a92:	83 c4 10             	add    $0x10,%esp
}
  801a95:	89 d8                	mov    %ebx,%eax
  801a97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9a:	5b                   	pop    %ebx
  801a9b:	5e                   	pop    %esi
  801a9c:	5d                   	pop    %ebp
  801a9d:	c3                   	ret    
	assert(r <= n);
  801a9e:	68 18 2a 80 00       	push   $0x802a18
  801aa3:	68 1f 2a 80 00       	push   $0x802a1f
  801aa8:	6a 7c                	push   $0x7c
  801aaa:	68 34 2a 80 00       	push   $0x802a34
  801aaf:	e8 be 05 00 00       	call   802072 <_panic>
	assert(r <= PGSIZE);
  801ab4:	68 3f 2a 80 00       	push   $0x802a3f
  801ab9:	68 1f 2a 80 00       	push   $0x802a1f
  801abe:	6a 7d                	push   $0x7d
  801ac0:	68 34 2a 80 00       	push   $0x802a34
  801ac5:	e8 a8 05 00 00       	call   802072 <_panic>

00801aca <open>:
{
  801aca:	f3 0f 1e fb          	endbr32 
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	56                   	push   %esi
  801ad2:	53                   	push   %ebx
  801ad3:	83 ec 1c             	sub    $0x1c,%esp
  801ad6:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801ad9:	56                   	push   %esi
  801ada:	e8 58 ec ff ff       	call   800737 <strlen>
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ae7:	7f 6c                	jg     801b55 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801ae9:	83 ec 0c             	sub    $0xc,%esp
  801aec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aef:	50                   	push   %eax
  801af0:	e8 42 f8 ff ff       	call   801337 <fd_alloc>
  801af5:	89 c3                	mov    %eax,%ebx
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	85 c0                	test   %eax,%eax
  801afc:	78 3c                	js     801b3a <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801afe:	83 ec 08             	sub    $0x8,%esp
  801b01:	56                   	push   %esi
  801b02:	68 00 50 80 00       	push   $0x805000
  801b07:	e8 6e ec ff ff       	call   80077a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0f:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b14:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b17:	b8 01 00 00 00       	mov    $0x1,%eax
  801b1c:	e8 b6 fd ff ff       	call   8018d7 <fsipc>
  801b21:	89 c3                	mov    %eax,%ebx
  801b23:	83 c4 10             	add    $0x10,%esp
  801b26:	85 c0                	test   %eax,%eax
  801b28:	78 19                	js     801b43 <open+0x79>
	return fd2num(fd);
  801b2a:	83 ec 0c             	sub    $0xc,%esp
  801b2d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b30:	e8 cf f7 ff ff       	call   801304 <fd2num>
  801b35:	89 c3                	mov    %eax,%ebx
  801b37:	83 c4 10             	add    $0x10,%esp
}
  801b3a:	89 d8                	mov    %ebx,%eax
  801b3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b3f:	5b                   	pop    %ebx
  801b40:	5e                   	pop    %esi
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    
		fd_close(fd, 0);
  801b43:	83 ec 08             	sub    $0x8,%esp
  801b46:	6a 00                	push   $0x0
  801b48:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4b:	e8 eb f8 ff ff       	call   80143b <fd_close>
		return r;
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	eb e5                	jmp    801b3a <open+0x70>
		return -E_BAD_PATH;
  801b55:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801b5a:	eb de                	jmp    801b3a <open+0x70>

00801b5c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b5c:	f3 0f 1e fb          	endbr32 
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b66:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6b:	b8 08 00 00 00       	mov    $0x8,%eax
  801b70:	e8 62 fd ff ff       	call   8018d7 <fsipc>
}
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b77:	f3 0f 1e fb          	endbr32 
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	56                   	push   %esi
  801b7f:	53                   	push   %ebx
  801b80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b83:	83 ec 0c             	sub    $0xc,%esp
  801b86:	ff 75 08             	pushl  0x8(%ebp)
  801b89:	e8 8a f7 ff ff       	call   801318 <fd2data>
  801b8e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b90:	83 c4 08             	add    $0x8,%esp
  801b93:	68 4b 2a 80 00       	push   $0x802a4b
  801b98:	53                   	push   %ebx
  801b99:	e8 dc eb ff ff       	call   80077a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b9e:	8b 46 04             	mov    0x4(%esi),%eax
  801ba1:	2b 06                	sub    (%esi),%eax
  801ba3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ba9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bb0:	00 00 00 
	stat->st_dev = &devpipe;
  801bb3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bba:	30 80 00 
	return 0;
}
  801bbd:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc5:	5b                   	pop    %ebx
  801bc6:	5e                   	pop    %esi
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    

00801bc9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bc9:	f3 0f 1e fb          	endbr32 
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	53                   	push   %ebx
  801bd1:	83 ec 0c             	sub    $0xc,%esp
  801bd4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bd7:	53                   	push   %ebx
  801bd8:	6a 00                	push   $0x0
  801bda:	e8 75 f0 ff ff       	call   800c54 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bdf:	89 1c 24             	mov    %ebx,(%esp)
  801be2:	e8 31 f7 ff ff       	call   801318 <fd2data>
  801be7:	83 c4 08             	add    $0x8,%esp
  801bea:	50                   	push   %eax
  801beb:	6a 00                	push   $0x0
  801bed:	e8 62 f0 ff ff       	call   800c54 <sys_page_unmap>
}
  801bf2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    

00801bf7 <_pipeisclosed>:
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	57                   	push   %edi
  801bfb:	56                   	push   %esi
  801bfc:	53                   	push   %ebx
  801bfd:	83 ec 1c             	sub    $0x1c,%esp
  801c00:	89 c7                	mov    %eax,%edi
  801c02:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c04:	a1 08 40 80 00       	mov    0x804008,%eax
  801c09:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c0c:	83 ec 0c             	sub    $0xc,%esp
  801c0f:	57                   	push   %edi
  801c10:	e8 40 05 00 00       	call   802155 <pageref>
  801c15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c18:	89 34 24             	mov    %esi,(%esp)
  801c1b:	e8 35 05 00 00       	call   802155 <pageref>
		nn = thisenv->env_runs;
  801c20:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c26:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c29:	83 c4 10             	add    $0x10,%esp
  801c2c:	39 cb                	cmp    %ecx,%ebx
  801c2e:	74 1b                	je     801c4b <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c30:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c33:	75 cf                	jne    801c04 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c35:	8b 42 58             	mov    0x58(%edx),%eax
  801c38:	6a 01                	push   $0x1
  801c3a:	50                   	push   %eax
  801c3b:	53                   	push   %ebx
  801c3c:	68 52 2a 80 00       	push   $0x802a52
  801c41:	e8 ca e5 ff ff       	call   800210 <cprintf>
  801c46:	83 c4 10             	add    $0x10,%esp
  801c49:	eb b9                	jmp    801c04 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c4b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c4e:	0f 94 c0             	sete   %al
  801c51:	0f b6 c0             	movzbl %al,%eax
}
  801c54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c57:	5b                   	pop    %ebx
  801c58:	5e                   	pop    %esi
  801c59:	5f                   	pop    %edi
  801c5a:	5d                   	pop    %ebp
  801c5b:	c3                   	ret    

00801c5c <devpipe_write>:
{
  801c5c:	f3 0f 1e fb          	endbr32 
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	57                   	push   %edi
  801c64:	56                   	push   %esi
  801c65:	53                   	push   %ebx
  801c66:	83 ec 28             	sub    $0x28,%esp
  801c69:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c6c:	56                   	push   %esi
  801c6d:	e8 a6 f6 ff ff       	call   801318 <fd2data>
  801c72:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	bf 00 00 00 00       	mov    $0x0,%edi
  801c7c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c7f:	74 4f                	je     801cd0 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c81:	8b 43 04             	mov    0x4(%ebx),%eax
  801c84:	8b 0b                	mov    (%ebx),%ecx
  801c86:	8d 51 20             	lea    0x20(%ecx),%edx
  801c89:	39 d0                	cmp    %edx,%eax
  801c8b:	72 14                	jb     801ca1 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801c8d:	89 da                	mov    %ebx,%edx
  801c8f:	89 f0                	mov    %esi,%eax
  801c91:	e8 61 ff ff ff       	call   801bf7 <_pipeisclosed>
  801c96:	85 c0                	test   %eax,%eax
  801c98:	75 3b                	jne    801cd5 <devpipe_write+0x79>
			sys_yield();
  801c9a:	e8 38 ef ff ff       	call   800bd7 <sys_yield>
  801c9f:	eb e0                	jmp    801c81 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ca8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cab:	89 c2                	mov    %eax,%edx
  801cad:	c1 fa 1f             	sar    $0x1f,%edx
  801cb0:	89 d1                	mov    %edx,%ecx
  801cb2:	c1 e9 1b             	shr    $0x1b,%ecx
  801cb5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cb8:	83 e2 1f             	and    $0x1f,%edx
  801cbb:	29 ca                	sub    %ecx,%edx
  801cbd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cc1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cc5:	83 c0 01             	add    $0x1,%eax
  801cc8:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801ccb:	83 c7 01             	add    $0x1,%edi
  801cce:	eb ac                	jmp    801c7c <devpipe_write+0x20>
	return i;
  801cd0:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd3:	eb 05                	jmp    801cda <devpipe_write+0x7e>
				return 0;
  801cd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5f                   	pop    %edi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    

00801ce2 <devpipe_read>:
{
  801ce2:	f3 0f 1e fb          	endbr32 
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	57                   	push   %edi
  801cea:	56                   	push   %esi
  801ceb:	53                   	push   %ebx
  801cec:	83 ec 18             	sub    $0x18,%esp
  801cef:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801cf2:	57                   	push   %edi
  801cf3:	e8 20 f6 ff ff       	call   801318 <fd2data>
  801cf8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cfa:	83 c4 10             	add    $0x10,%esp
  801cfd:	be 00 00 00 00       	mov    $0x0,%esi
  801d02:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d05:	75 14                	jne    801d1b <devpipe_read+0x39>
	return i;
  801d07:	8b 45 10             	mov    0x10(%ebp),%eax
  801d0a:	eb 02                	jmp    801d0e <devpipe_read+0x2c>
				return i;
  801d0c:	89 f0                	mov    %esi,%eax
}
  801d0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d11:	5b                   	pop    %ebx
  801d12:	5e                   	pop    %esi
  801d13:	5f                   	pop    %edi
  801d14:	5d                   	pop    %ebp
  801d15:	c3                   	ret    
			sys_yield();
  801d16:	e8 bc ee ff ff       	call   800bd7 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d1b:	8b 03                	mov    (%ebx),%eax
  801d1d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d20:	75 18                	jne    801d3a <devpipe_read+0x58>
			if (i > 0)
  801d22:	85 f6                	test   %esi,%esi
  801d24:	75 e6                	jne    801d0c <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801d26:	89 da                	mov    %ebx,%edx
  801d28:	89 f8                	mov    %edi,%eax
  801d2a:	e8 c8 fe ff ff       	call   801bf7 <_pipeisclosed>
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	74 e3                	je     801d16 <devpipe_read+0x34>
				return 0;
  801d33:	b8 00 00 00 00       	mov    $0x0,%eax
  801d38:	eb d4                	jmp    801d0e <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d3a:	99                   	cltd   
  801d3b:	c1 ea 1b             	shr    $0x1b,%edx
  801d3e:	01 d0                	add    %edx,%eax
  801d40:	83 e0 1f             	and    $0x1f,%eax
  801d43:	29 d0                	sub    %edx,%eax
  801d45:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d4d:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d50:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d53:	83 c6 01             	add    $0x1,%esi
  801d56:	eb aa                	jmp    801d02 <devpipe_read+0x20>

00801d58 <pipe>:
{
  801d58:	f3 0f 1e fb          	endbr32 
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	56                   	push   %esi
  801d60:	53                   	push   %ebx
  801d61:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d67:	50                   	push   %eax
  801d68:	e8 ca f5 ff ff       	call   801337 <fd_alloc>
  801d6d:	89 c3                	mov    %eax,%ebx
  801d6f:	83 c4 10             	add    $0x10,%esp
  801d72:	85 c0                	test   %eax,%eax
  801d74:	0f 88 23 01 00 00    	js     801e9d <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7a:	83 ec 04             	sub    $0x4,%esp
  801d7d:	68 07 04 00 00       	push   $0x407
  801d82:	ff 75 f4             	pushl  -0xc(%ebp)
  801d85:	6a 00                	push   $0x0
  801d87:	e8 76 ee ff ff       	call   800c02 <sys_page_alloc>
  801d8c:	89 c3                	mov    %eax,%ebx
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	85 c0                	test   %eax,%eax
  801d93:	0f 88 04 01 00 00    	js     801e9d <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801d99:	83 ec 0c             	sub    $0xc,%esp
  801d9c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d9f:	50                   	push   %eax
  801da0:	e8 92 f5 ff ff       	call   801337 <fd_alloc>
  801da5:	89 c3                	mov    %eax,%ebx
  801da7:	83 c4 10             	add    $0x10,%esp
  801daa:	85 c0                	test   %eax,%eax
  801dac:	0f 88 db 00 00 00    	js     801e8d <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db2:	83 ec 04             	sub    $0x4,%esp
  801db5:	68 07 04 00 00       	push   $0x407
  801dba:	ff 75 f0             	pushl  -0x10(%ebp)
  801dbd:	6a 00                	push   $0x0
  801dbf:	e8 3e ee ff ff       	call   800c02 <sys_page_alloc>
  801dc4:	89 c3                	mov    %eax,%ebx
  801dc6:	83 c4 10             	add    $0x10,%esp
  801dc9:	85 c0                	test   %eax,%eax
  801dcb:	0f 88 bc 00 00 00    	js     801e8d <pipe+0x135>
	va = fd2data(fd0);
  801dd1:	83 ec 0c             	sub    $0xc,%esp
  801dd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd7:	e8 3c f5 ff ff       	call   801318 <fd2data>
  801ddc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dde:	83 c4 0c             	add    $0xc,%esp
  801de1:	68 07 04 00 00       	push   $0x407
  801de6:	50                   	push   %eax
  801de7:	6a 00                	push   $0x0
  801de9:	e8 14 ee ff ff       	call   800c02 <sys_page_alloc>
  801dee:	89 c3                	mov    %eax,%ebx
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	85 c0                	test   %eax,%eax
  801df5:	0f 88 82 00 00 00    	js     801e7d <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dfb:	83 ec 0c             	sub    $0xc,%esp
  801dfe:	ff 75 f0             	pushl  -0x10(%ebp)
  801e01:	e8 12 f5 ff ff       	call   801318 <fd2data>
  801e06:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e0d:	50                   	push   %eax
  801e0e:	6a 00                	push   $0x0
  801e10:	56                   	push   %esi
  801e11:	6a 00                	push   $0x0
  801e13:	e8 12 ee ff ff       	call   800c2a <sys_page_map>
  801e18:	89 c3                	mov    %eax,%ebx
  801e1a:	83 c4 20             	add    $0x20,%esp
  801e1d:	85 c0                	test   %eax,%eax
  801e1f:	78 4e                	js     801e6f <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801e21:	a1 20 30 80 00       	mov    0x803020,%eax
  801e26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e29:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801e2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e2e:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e35:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e38:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801e3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e3d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e44:	83 ec 0c             	sub    $0xc,%esp
  801e47:	ff 75 f4             	pushl  -0xc(%ebp)
  801e4a:	e8 b5 f4 ff ff       	call   801304 <fd2num>
  801e4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e52:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e54:	83 c4 04             	add    $0x4,%esp
  801e57:	ff 75 f0             	pushl  -0x10(%ebp)
  801e5a:	e8 a5 f4 ff ff       	call   801304 <fd2num>
  801e5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e62:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e65:	83 c4 10             	add    $0x10,%esp
  801e68:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e6d:	eb 2e                	jmp    801e9d <pipe+0x145>
	sys_page_unmap(0, va);
  801e6f:	83 ec 08             	sub    $0x8,%esp
  801e72:	56                   	push   %esi
  801e73:	6a 00                	push   $0x0
  801e75:	e8 da ed ff ff       	call   800c54 <sys_page_unmap>
  801e7a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e7d:	83 ec 08             	sub    $0x8,%esp
  801e80:	ff 75 f0             	pushl  -0x10(%ebp)
  801e83:	6a 00                	push   $0x0
  801e85:	e8 ca ed ff ff       	call   800c54 <sys_page_unmap>
  801e8a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e8d:	83 ec 08             	sub    $0x8,%esp
  801e90:	ff 75 f4             	pushl  -0xc(%ebp)
  801e93:	6a 00                	push   $0x0
  801e95:	e8 ba ed ff ff       	call   800c54 <sys_page_unmap>
  801e9a:	83 c4 10             	add    $0x10,%esp
}
  801e9d:	89 d8                	mov    %ebx,%eax
  801e9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea2:	5b                   	pop    %ebx
  801ea3:	5e                   	pop    %esi
  801ea4:	5d                   	pop    %ebp
  801ea5:	c3                   	ret    

00801ea6 <pipeisclosed>:
{
  801ea6:	f3 0f 1e fb          	endbr32 
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb3:	50                   	push   %eax
  801eb4:	ff 75 08             	pushl  0x8(%ebp)
  801eb7:	e8 d1 f4 ff ff       	call   80138d <fd_lookup>
  801ebc:	83 c4 10             	add    $0x10,%esp
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	78 18                	js     801edb <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801ec3:	83 ec 0c             	sub    $0xc,%esp
  801ec6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec9:	e8 4a f4 ff ff       	call   801318 <fd2data>
  801ece:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed3:	e8 1f fd ff ff       	call   801bf7 <_pipeisclosed>
  801ed8:	83 c4 10             	add    $0x10,%esp
}
  801edb:	c9                   	leave  
  801edc:	c3                   	ret    

00801edd <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801edd:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee6:	c3                   	ret    

00801ee7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ee7:	f3 0f 1e fb          	endbr32 
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ef1:	68 6a 2a 80 00       	push   $0x802a6a
  801ef6:	ff 75 0c             	pushl  0xc(%ebp)
  801ef9:	e8 7c e8 ff ff       	call   80077a <strcpy>
	return 0;
}
  801efe:	b8 00 00 00 00       	mov    $0x0,%eax
  801f03:	c9                   	leave  
  801f04:	c3                   	ret    

00801f05 <devcons_write>:
{
  801f05:	f3 0f 1e fb          	endbr32 
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	57                   	push   %edi
  801f0d:	56                   	push   %esi
  801f0e:	53                   	push   %ebx
  801f0f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f15:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f1a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f20:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f23:	73 31                	jae    801f56 <devcons_write+0x51>
		m = n - tot;
  801f25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f28:	29 f3                	sub    %esi,%ebx
  801f2a:	83 fb 7f             	cmp    $0x7f,%ebx
  801f2d:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f32:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f35:	83 ec 04             	sub    $0x4,%esp
  801f38:	53                   	push   %ebx
  801f39:	89 f0                	mov    %esi,%eax
  801f3b:	03 45 0c             	add    0xc(%ebp),%eax
  801f3e:	50                   	push   %eax
  801f3f:	57                   	push   %edi
  801f40:	e8 ed e9 ff ff       	call   800932 <memmove>
		sys_cputs(buf, m);
  801f45:	83 c4 08             	add    $0x8,%esp
  801f48:	53                   	push   %ebx
  801f49:	57                   	push   %edi
  801f4a:	e8 e8 eb ff ff       	call   800b37 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f4f:	01 de                	add    %ebx,%esi
  801f51:	83 c4 10             	add    $0x10,%esp
  801f54:	eb ca                	jmp    801f20 <devcons_write+0x1b>
}
  801f56:	89 f0                	mov    %esi,%eax
  801f58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5b:	5b                   	pop    %ebx
  801f5c:	5e                   	pop    %esi
  801f5d:	5f                   	pop    %edi
  801f5e:	5d                   	pop    %ebp
  801f5f:	c3                   	ret    

00801f60 <devcons_read>:
{
  801f60:	f3 0f 1e fb          	endbr32 
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	83 ec 08             	sub    $0x8,%esp
  801f6a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f6f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f73:	74 21                	je     801f96 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801f75:	e8 e7 eb ff ff       	call   800b61 <sys_cgetc>
  801f7a:	85 c0                	test   %eax,%eax
  801f7c:	75 07                	jne    801f85 <devcons_read+0x25>
		sys_yield();
  801f7e:	e8 54 ec ff ff       	call   800bd7 <sys_yield>
  801f83:	eb f0                	jmp    801f75 <devcons_read+0x15>
	if (c < 0)
  801f85:	78 0f                	js     801f96 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801f87:	83 f8 04             	cmp    $0x4,%eax
  801f8a:	74 0c                	je     801f98 <devcons_read+0x38>
	*(char*)vbuf = c;
  801f8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f8f:	88 02                	mov    %al,(%edx)
	return 1;
  801f91:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801f96:	c9                   	leave  
  801f97:	c3                   	ret    
		return 0;
  801f98:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9d:	eb f7                	jmp    801f96 <devcons_read+0x36>

00801f9f <cputchar>:
{
  801f9f:	f3 0f 1e fb          	endbr32 
  801fa3:	55                   	push   %ebp
  801fa4:	89 e5                	mov    %esp,%ebp
  801fa6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fa9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fac:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801faf:	6a 01                	push   $0x1
  801fb1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fb4:	50                   	push   %eax
  801fb5:	e8 7d eb ff ff       	call   800b37 <sys_cputs>
}
  801fba:	83 c4 10             	add    $0x10,%esp
  801fbd:	c9                   	leave  
  801fbe:	c3                   	ret    

00801fbf <getchar>:
{
  801fbf:	f3 0f 1e fb          	endbr32 
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801fc9:	6a 01                	push   $0x1
  801fcb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fce:	50                   	push   %eax
  801fcf:	6a 00                	push   $0x0
  801fd1:	e8 3a f6 ff ff       	call   801610 <read>
	if (r < 0)
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	78 06                	js     801fe3 <getchar+0x24>
	if (r < 1)
  801fdd:	74 06                	je     801fe5 <getchar+0x26>
	return c;
  801fdf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801fe3:	c9                   	leave  
  801fe4:	c3                   	ret    
		return -E_EOF;
  801fe5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801fea:	eb f7                	jmp    801fe3 <getchar+0x24>

00801fec <iscons>:
{
  801fec:	f3 0f 1e fb          	endbr32 
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ff6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff9:	50                   	push   %eax
  801ffa:	ff 75 08             	pushl  0x8(%ebp)
  801ffd:	e8 8b f3 ff ff       	call   80138d <fd_lookup>
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	85 c0                	test   %eax,%eax
  802007:	78 11                	js     80201a <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802009:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802012:	39 10                	cmp    %edx,(%eax)
  802014:	0f 94 c0             	sete   %al
  802017:	0f b6 c0             	movzbl %al,%eax
}
  80201a:	c9                   	leave  
  80201b:	c3                   	ret    

0080201c <opencons>:
{
  80201c:	f3 0f 1e fb          	endbr32 
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802026:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802029:	50                   	push   %eax
  80202a:	e8 08 f3 ff ff       	call   801337 <fd_alloc>
  80202f:	83 c4 10             	add    $0x10,%esp
  802032:	85 c0                	test   %eax,%eax
  802034:	78 3a                	js     802070 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802036:	83 ec 04             	sub    $0x4,%esp
  802039:	68 07 04 00 00       	push   $0x407
  80203e:	ff 75 f4             	pushl  -0xc(%ebp)
  802041:	6a 00                	push   $0x0
  802043:	e8 ba eb ff ff       	call   800c02 <sys_page_alloc>
  802048:	83 c4 10             	add    $0x10,%esp
  80204b:	85 c0                	test   %eax,%eax
  80204d:	78 21                	js     802070 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80204f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802052:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802058:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80205a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802064:	83 ec 0c             	sub    $0xc,%esp
  802067:	50                   	push   %eax
  802068:	e8 97 f2 ff ff       	call   801304 <fd2num>
  80206d:	83 c4 10             	add    $0x10,%esp
}
  802070:	c9                   	leave  
  802071:	c3                   	ret    

00802072 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802072:	f3 0f 1e fb          	endbr32 
  802076:	55                   	push   %ebp
  802077:	89 e5                	mov    %esp,%ebp
  802079:	56                   	push   %esi
  80207a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80207b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80207e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802084:	e8 26 eb ff ff       	call   800baf <sys_getenvid>
  802089:	83 ec 0c             	sub    $0xc,%esp
  80208c:	ff 75 0c             	pushl  0xc(%ebp)
  80208f:	ff 75 08             	pushl  0x8(%ebp)
  802092:	56                   	push   %esi
  802093:	50                   	push   %eax
  802094:	68 78 2a 80 00       	push   $0x802a78
  802099:	e8 72 e1 ff ff       	call   800210 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80209e:	83 c4 18             	add    $0x18,%esp
  8020a1:	53                   	push   %ebx
  8020a2:	ff 75 10             	pushl  0x10(%ebp)
  8020a5:	e8 11 e1 ff ff       	call   8001bb <vcprintf>
	cprintf("\n");
  8020aa:	c7 04 24 63 2a 80 00 	movl   $0x802a63,(%esp)
  8020b1:	e8 5a e1 ff ff       	call   800210 <cprintf>
  8020b6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8020b9:	cc                   	int3   
  8020ba:	eb fd                	jmp    8020b9 <_panic+0x47>

008020bc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020bc:	f3 0f 1e fb          	endbr32 
  8020c0:	55                   	push   %ebp
  8020c1:	89 e5                	mov    %esp,%ebp
  8020c3:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  8020c6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8020cd:	74 0a                	je     8020d9 <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d2:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8020d7:	c9                   	leave  
  8020d8:	c3                   	ret    
		if (sys_page_alloc(0,
  8020d9:	83 ec 04             	sub    $0x4,%esp
  8020dc:	6a 07                	push   $0x7
  8020de:	68 00 f0 bf ee       	push   $0xeebff000
  8020e3:	6a 00                	push   $0x0
  8020e5:	e8 18 eb ff ff       	call   800c02 <sys_page_alloc>
  8020ea:	83 c4 10             	add    $0x10,%esp
  8020ed:	85 c0                	test   %eax,%eax
  8020ef:	78 2a                	js     80211b <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  8020f1:	83 ec 08             	sub    $0x8,%esp
  8020f4:	68 2f 21 80 00       	push   $0x80212f
  8020f9:	6a 00                	push   $0x0
  8020fb:	e8 c9 eb ff ff       	call   800cc9 <sys_env_set_pgfault_upcall>
  802100:	83 c4 10             	add    $0x10,%esp
  802103:	85 c0                	test   %eax,%eax
  802105:	79 c8                	jns    8020cf <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  802107:	83 ec 04             	sub    $0x4,%esp
  80210a:	68 d0 2a 80 00       	push   $0x802ad0
  80210f:	6a 25                	push   $0x25
  802111:	68 17 2b 80 00       	push   $0x802b17
  802116:	e8 57 ff ff ff       	call   802072 <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  80211b:	83 ec 04             	sub    $0x4,%esp
  80211e:	68 9c 2a 80 00       	push   $0x802a9c
  802123:	6a 21                	push   $0x21
  802125:	68 17 2b 80 00       	push   $0x802b17
  80212a:	e8 43 ff ff ff       	call   802072 <_panic>

0080212f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80212f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802130:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802135:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802137:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  80213a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  80213f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  802143:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802147:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  802149:	83 c4 08             	add    $0x8,%esp
	popal
  80214c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  80214d:	83 c4 04             	add    $0x4,%esp
	popfl
  802150:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  802151:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802154:	c3                   	ret    

00802155 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802155:	f3 0f 1e fb          	endbr32 
  802159:	55                   	push   %ebp
  80215a:	89 e5                	mov    %esp,%ebp
  80215c:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80215f:	89 c2                	mov    %eax,%edx
  802161:	c1 ea 16             	shr    $0x16,%edx
  802164:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80216b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802170:	f6 c1 01             	test   $0x1,%cl
  802173:	74 1c                	je     802191 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802175:	c1 e8 0c             	shr    $0xc,%eax
  802178:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80217f:	a8 01                	test   $0x1,%al
  802181:	74 0e                	je     802191 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802183:	c1 e8 0c             	shr    $0xc,%eax
  802186:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80218d:	ef 
  80218e:	0f b7 d2             	movzwl %dx,%edx
}
  802191:	89 d0                	mov    %edx,%eax
  802193:	5d                   	pop    %ebp
  802194:	c3                   	ret    
  802195:	66 90                	xchg   %ax,%ax
  802197:	66 90                	xchg   %ax,%ax
  802199:	66 90                	xchg   %ax,%ax
  80219b:	66 90                	xchg   %ax,%ax
  80219d:	66 90                	xchg   %ax,%ax
  80219f:	90                   	nop

008021a0 <__udivdi3>:
  8021a0:	f3 0f 1e fb          	endbr32 
  8021a4:	55                   	push   %ebp
  8021a5:	57                   	push   %edi
  8021a6:	56                   	push   %esi
  8021a7:	53                   	push   %ebx
  8021a8:	83 ec 1c             	sub    $0x1c,%esp
  8021ab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021bb:	85 d2                	test   %edx,%edx
  8021bd:	75 19                	jne    8021d8 <__udivdi3+0x38>
  8021bf:	39 f3                	cmp    %esi,%ebx
  8021c1:	76 4d                	jbe    802210 <__udivdi3+0x70>
  8021c3:	31 ff                	xor    %edi,%edi
  8021c5:	89 e8                	mov    %ebp,%eax
  8021c7:	89 f2                	mov    %esi,%edx
  8021c9:	f7 f3                	div    %ebx
  8021cb:	89 fa                	mov    %edi,%edx
  8021cd:	83 c4 1c             	add    $0x1c,%esp
  8021d0:	5b                   	pop    %ebx
  8021d1:	5e                   	pop    %esi
  8021d2:	5f                   	pop    %edi
  8021d3:	5d                   	pop    %ebp
  8021d4:	c3                   	ret    
  8021d5:	8d 76 00             	lea    0x0(%esi),%esi
  8021d8:	39 f2                	cmp    %esi,%edx
  8021da:	76 14                	jbe    8021f0 <__udivdi3+0x50>
  8021dc:	31 ff                	xor    %edi,%edi
  8021de:	31 c0                	xor    %eax,%eax
  8021e0:	89 fa                	mov    %edi,%edx
  8021e2:	83 c4 1c             	add    $0x1c,%esp
  8021e5:	5b                   	pop    %ebx
  8021e6:	5e                   	pop    %esi
  8021e7:	5f                   	pop    %edi
  8021e8:	5d                   	pop    %ebp
  8021e9:	c3                   	ret    
  8021ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f0:	0f bd fa             	bsr    %edx,%edi
  8021f3:	83 f7 1f             	xor    $0x1f,%edi
  8021f6:	75 48                	jne    802240 <__udivdi3+0xa0>
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	72 06                	jb     802202 <__udivdi3+0x62>
  8021fc:	31 c0                	xor    %eax,%eax
  8021fe:	39 eb                	cmp    %ebp,%ebx
  802200:	77 de                	ja     8021e0 <__udivdi3+0x40>
  802202:	b8 01 00 00 00       	mov    $0x1,%eax
  802207:	eb d7                	jmp    8021e0 <__udivdi3+0x40>
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 d9                	mov    %ebx,%ecx
  802212:	85 db                	test   %ebx,%ebx
  802214:	75 0b                	jne    802221 <__udivdi3+0x81>
  802216:	b8 01 00 00 00       	mov    $0x1,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	f7 f3                	div    %ebx
  80221f:	89 c1                	mov    %eax,%ecx
  802221:	31 d2                	xor    %edx,%edx
  802223:	89 f0                	mov    %esi,%eax
  802225:	f7 f1                	div    %ecx
  802227:	89 c6                	mov    %eax,%esi
  802229:	89 e8                	mov    %ebp,%eax
  80222b:	89 f7                	mov    %esi,%edi
  80222d:	f7 f1                	div    %ecx
  80222f:	89 fa                	mov    %edi,%edx
  802231:	83 c4 1c             	add    $0x1c,%esp
  802234:	5b                   	pop    %ebx
  802235:	5e                   	pop    %esi
  802236:	5f                   	pop    %edi
  802237:	5d                   	pop    %ebp
  802238:	c3                   	ret    
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	89 f9                	mov    %edi,%ecx
  802242:	b8 20 00 00 00       	mov    $0x20,%eax
  802247:	29 f8                	sub    %edi,%eax
  802249:	d3 e2                	shl    %cl,%edx
  80224b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80224f:	89 c1                	mov    %eax,%ecx
  802251:	89 da                	mov    %ebx,%edx
  802253:	d3 ea                	shr    %cl,%edx
  802255:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802259:	09 d1                	or     %edx,%ecx
  80225b:	89 f2                	mov    %esi,%edx
  80225d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802261:	89 f9                	mov    %edi,%ecx
  802263:	d3 e3                	shl    %cl,%ebx
  802265:	89 c1                	mov    %eax,%ecx
  802267:	d3 ea                	shr    %cl,%edx
  802269:	89 f9                	mov    %edi,%ecx
  80226b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80226f:	89 eb                	mov    %ebp,%ebx
  802271:	d3 e6                	shl    %cl,%esi
  802273:	89 c1                	mov    %eax,%ecx
  802275:	d3 eb                	shr    %cl,%ebx
  802277:	09 de                	or     %ebx,%esi
  802279:	89 f0                	mov    %esi,%eax
  80227b:	f7 74 24 08          	divl   0x8(%esp)
  80227f:	89 d6                	mov    %edx,%esi
  802281:	89 c3                	mov    %eax,%ebx
  802283:	f7 64 24 0c          	mull   0xc(%esp)
  802287:	39 d6                	cmp    %edx,%esi
  802289:	72 15                	jb     8022a0 <__udivdi3+0x100>
  80228b:	89 f9                	mov    %edi,%ecx
  80228d:	d3 e5                	shl    %cl,%ebp
  80228f:	39 c5                	cmp    %eax,%ebp
  802291:	73 04                	jae    802297 <__udivdi3+0xf7>
  802293:	39 d6                	cmp    %edx,%esi
  802295:	74 09                	je     8022a0 <__udivdi3+0x100>
  802297:	89 d8                	mov    %ebx,%eax
  802299:	31 ff                	xor    %edi,%edi
  80229b:	e9 40 ff ff ff       	jmp    8021e0 <__udivdi3+0x40>
  8022a0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8022a3:	31 ff                	xor    %edi,%edi
  8022a5:	e9 36 ff ff ff       	jmp    8021e0 <__udivdi3+0x40>
  8022aa:	66 90                	xchg   %ax,%ax
  8022ac:	66 90                	xchg   %ax,%ax
  8022ae:	66 90                	xchg   %ax,%ax

008022b0 <__umoddi3>:
  8022b0:	f3 0f 1e fb          	endbr32 
  8022b4:	55                   	push   %ebp
  8022b5:	57                   	push   %edi
  8022b6:	56                   	push   %esi
  8022b7:	53                   	push   %ebx
  8022b8:	83 ec 1c             	sub    $0x1c,%esp
  8022bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022bf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022c3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022c7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022cb:	85 c0                	test   %eax,%eax
  8022cd:	75 19                	jne    8022e8 <__umoddi3+0x38>
  8022cf:	39 df                	cmp    %ebx,%edi
  8022d1:	76 5d                	jbe    802330 <__umoddi3+0x80>
  8022d3:	89 f0                	mov    %esi,%eax
  8022d5:	89 da                	mov    %ebx,%edx
  8022d7:	f7 f7                	div    %edi
  8022d9:	89 d0                	mov    %edx,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	83 c4 1c             	add    $0x1c,%esp
  8022e0:	5b                   	pop    %ebx
  8022e1:	5e                   	pop    %esi
  8022e2:	5f                   	pop    %edi
  8022e3:	5d                   	pop    %ebp
  8022e4:	c3                   	ret    
  8022e5:	8d 76 00             	lea    0x0(%esi),%esi
  8022e8:	89 f2                	mov    %esi,%edx
  8022ea:	39 d8                	cmp    %ebx,%eax
  8022ec:	76 12                	jbe    802300 <__umoddi3+0x50>
  8022ee:	89 f0                	mov    %esi,%eax
  8022f0:	89 da                	mov    %ebx,%edx
  8022f2:	83 c4 1c             	add    $0x1c,%esp
  8022f5:	5b                   	pop    %ebx
  8022f6:	5e                   	pop    %esi
  8022f7:	5f                   	pop    %edi
  8022f8:	5d                   	pop    %ebp
  8022f9:	c3                   	ret    
  8022fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802300:	0f bd e8             	bsr    %eax,%ebp
  802303:	83 f5 1f             	xor    $0x1f,%ebp
  802306:	75 50                	jne    802358 <__umoddi3+0xa8>
  802308:	39 d8                	cmp    %ebx,%eax
  80230a:	0f 82 e0 00 00 00    	jb     8023f0 <__umoddi3+0x140>
  802310:	89 d9                	mov    %ebx,%ecx
  802312:	39 f7                	cmp    %esi,%edi
  802314:	0f 86 d6 00 00 00    	jbe    8023f0 <__umoddi3+0x140>
  80231a:	89 d0                	mov    %edx,%eax
  80231c:	89 ca                	mov    %ecx,%edx
  80231e:	83 c4 1c             	add    $0x1c,%esp
  802321:	5b                   	pop    %ebx
  802322:	5e                   	pop    %esi
  802323:	5f                   	pop    %edi
  802324:	5d                   	pop    %ebp
  802325:	c3                   	ret    
  802326:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80232d:	8d 76 00             	lea    0x0(%esi),%esi
  802330:	89 fd                	mov    %edi,%ebp
  802332:	85 ff                	test   %edi,%edi
  802334:	75 0b                	jne    802341 <__umoddi3+0x91>
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f7                	div    %edi
  80233f:	89 c5                	mov    %eax,%ebp
  802341:	89 d8                	mov    %ebx,%eax
  802343:	31 d2                	xor    %edx,%edx
  802345:	f7 f5                	div    %ebp
  802347:	89 f0                	mov    %esi,%eax
  802349:	f7 f5                	div    %ebp
  80234b:	89 d0                	mov    %edx,%eax
  80234d:	31 d2                	xor    %edx,%edx
  80234f:	eb 8c                	jmp    8022dd <__umoddi3+0x2d>
  802351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802358:	89 e9                	mov    %ebp,%ecx
  80235a:	ba 20 00 00 00       	mov    $0x20,%edx
  80235f:	29 ea                	sub    %ebp,%edx
  802361:	d3 e0                	shl    %cl,%eax
  802363:	89 44 24 08          	mov    %eax,0x8(%esp)
  802367:	89 d1                	mov    %edx,%ecx
  802369:	89 f8                	mov    %edi,%eax
  80236b:	d3 e8                	shr    %cl,%eax
  80236d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802371:	89 54 24 04          	mov    %edx,0x4(%esp)
  802375:	8b 54 24 04          	mov    0x4(%esp),%edx
  802379:	09 c1                	or     %eax,%ecx
  80237b:	89 d8                	mov    %ebx,%eax
  80237d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802381:	89 e9                	mov    %ebp,%ecx
  802383:	d3 e7                	shl    %cl,%edi
  802385:	89 d1                	mov    %edx,%ecx
  802387:	d3 e8                	shr    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80238f:	d3 e3                	shl    %cl,%ebx
  802391:	89 c7                	mov    %eax,%edi
  802393:	89 d1                	mov    %edx,%ecx
  802395:	89 f0                	mov    %esi,%eax
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	89 fa                	mov    %edi,%edx
  80239d:	d3 e6                	shl    %cl,%esi
  80239f:	09 d8                	or     %ebx,%eax
  8023a1:	f7 74 24 08          	divl   0x8(%esp)
  8023a5:	89 d1                	mov    %edx,%ecx
  8023a7:	89 f3                	mov    %esi,%ebx
  8023a9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ad:	89 c6                	mov    %eax,%esi
  8023af:	89 d7                	mov    %edx,%edi
  8023b1:	39 d1                	cmp    %edx,%ecx
  8023b3:	72 06                	jb     8023bb <__umoddi3+0x10b>
  8023b5:	75 10                	jne    8023c7 <__umoddi3+0x117>
  8023b7:	39 c3                	cmp    %eax,%ebx
  8023b9:	73 0c                	jae    8023c7 <__umoddi3+0x117>
  8023bb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8023bf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8023c3:	89 d7                	mov    %edx,%edi
  8023c5:	89 c6                	mov    %eax,%esi
  8023c7:	89 ca                	mov    %ecx,%edx
  8023c9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023ce:	29 f3                	sub    %esi,%ebx
  8023d0:	19 fa                	sbb    %edi,%edx
  8023d2:	89 d0                	mov    %edx,%eax
  8023d4:	d3 e0                	shl    %cl,%eax
  8023d6:	89 e9                	mov    %ebp,%ecx
  8023d8:	d3 eb                	shr    %cl,%ebx
  8023da:	d3 ea                	shr    %cl,%edx
  8023dc:	09 d8                	or     %ebx,%eax
  8023de:	83 c4 1c             	add    $0x1c,%esp
  8023e1:	5b                   	pop    %ebx
  8023e2:	5e                   	pop    %esi
  8023e3:	5f                   	pop    %edi
  8023e4:	5d                   	pop    %ebp
  8023e5:	c3                   	ret    
  8023e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	29 fe                	sub    %edi,%esi
  8023f2:	19 c3                	sbb    %eax,%ebx
  8023f4:	89 f2                	mov    %esi,%edx
  8023f6:	89 d9                	mov    %ebx,%ecx
  8023f8:	e9 1d ff ff ff       	jmp    80231a <__umoddi3+0x6a>
