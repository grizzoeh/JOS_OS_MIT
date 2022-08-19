
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  800040:	e8 2b 10 00 00       	call   801070 <fork>
  800045:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800048:	85 c0                	test   %eax,%eax
  80004a:	75 4f                	jne    80009b <umain+0x68>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80004c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	6a 00                	push   $0x0
  800054:	6a 00                	push   $0x0
  800056:	56                   	push   %esi
  800057:	e8 68 11 00 00       	call   8011c4 <ipc_recv>
  80005c:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800061:	e8 06 0b 00 00       	call   800b6c <sys_getenvid>
  800066:	57                   	push   %edi
  800067:	53                   	push   %ebx
  800068:	50                   	push   %eax
  800069:	68 d6 23 80 00       	push   $0x8023d6
  80006e:	e8 5a 01 00 00       	call   8001cd <cprintf>
		if (i == 10)
  800073:	83 c4 20             	add    $0x20,%esp
  800076:	83 fb 0a             	cmp    $0xa,%ebx
  800079:	74 18                	je     800093 <umain+0x60>
			return;
		i++;
  80007b:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  80007e:	6a 00                	push   $0x0
  800080:	6a 00                	push   $0x0
  800082:	53                   	push   %ebx
  800083:	ff 75 e4             	pushl  -0x1c(%ebp)
  800086:	e8 a6 11 00 00       	call   801231 <ipc_send>
		if (i == 10)
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	83 fb 0a             	cmp    $0xa,%ebx
  800091:	75 bc                	jne    80004f <umain+0x1c>
			return;
	}

}
  800093:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5f                   	pop    %edi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
  80009b:	89 c3                	mov    %eax,%ebx
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80009d:	e8 ca 0a 00 00       	call   800b6c <sys_getenvid>
  8000a2:	83 ec 04             	sub    $0x4,%esp
  8000a5:	53                   	push   %ebx
  8000a6:	50                   	push   %eax
  8000a7:	68 c0 23 80 00       	push   $0x8023c0
  8000ac:	e8 1c 01 00 00       	call   8001cd <cprintf>
		ipc_send(who, 0, 0, 0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	6a 00                	push   $0x0
  8000b5:	6a 00                	push   $0x0
  8000b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000ba:	e8 72 11 00 00       	call   801231 <ipc_send>
  8000bf:	83 c4 20             	add    $0x20,%esp
  8000c2:	eb 88                	jmp    80004c <umain+0x19>

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	f3 0f 1e fb          	endbr32 
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
  8000cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000d3:	e8 94 0a 00 00       	call   800b6c <sys_getenvid>
	if (id >= 0)
  8000d8:	85 c0                	test   %eax,%eax
  8000da:	78 12                	js     8000ee <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8000dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e9:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ee:	85 db                	test   %ebx,%ebx
  8000f0:	7e 07                	jle    8000f9 <libmain+0x35>
		binaryname = argv[0];
  8000f2:	8b 06                	mov    (%esi),%eax
  8000f4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f9:	83 ec 08             	sub    $0x8,%esp
  8000fc:	56                   	push   %esi
  8000fd:	53                   	push   %ebx
  8000fe:	e8 30 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800103:	e8 0a 00 00 00       	call   800112 <exit>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5d                   	pop    %ebp
  800111:	c3                   	ret    

00800112 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800112:	f3 0f 1e fb          	endbr32 
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80011c:	e8 93 13 00 00       	call   8014b4 <close_all>
	sys_env_destroy(0);
  800121:	83 ec 0c             	sub    $0xc,%esp
  800124:	6a 00                	push   $0x0
  800126:	e8 1b 0a 00 00       	call   800b46 <sys_env_destroy>
}
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	c9                   	leave  
  80012f:	c3                   	ret    

00800130 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800130:	f3 0f 1e fb          	endbr32 
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	53                   	push   %ebx
  800138:	83 ec 04             	sub    $0x4,%esp
  80013b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013e:	8b 13                	mov    (%ebx),%edx
  800140:	8d 42 01             	lea    0x1(%edx),%eax
  800143:	89 03                	mov    %eax,(%ebx)
  800145:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800148:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80014c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800151:	74 09                	je     80015c <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800153:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800157:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80015c:	83 ec 08             	sub    $0x8,%esp
  80015f:	68 ff 00 00 00       	push   $0xff
  800164:	8d 43 08             	lea    0x8(%ebx),%eax
  800167:	50                   	push   %eax
  800168:	e8 87 09 00 00       	call   800af4 <sys_cputs>
		b->idx = 0;
  80016d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800173:	83 c4 10             	add    $0x10,%esp
  800176:	eb db                	jmp    800153 <putch+0x23>

00800178 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800178:	f3 0f 1e fb          	endbr32 
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800185:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018c:	00 00 00 
	b.cnt = 0;
  80018f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800196:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800199:	ff 75 0c             	pushl  0xc(%ebp)
  80019c:	ff 75 08             	pushl  0x8(%ebp)
  80019f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a5:	50                   	push   %eax
  8001a6:	68 30 01 80 00       	push   $0x800130
  8001ab:	e8 80 01 00 00       	call   800330 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b0:	83 c4 08             	add    $0x8,%esp
  8001b3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001b9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001bf:	50                   	push   %eax
  8001c0:	e8 2f 09 00 00       	call   800af4 <sys_cputs>

	return b.cnt;
}
  8001c5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001cb:	c9                   	leave  
  8001cc:	c3                   	ret    

008001cd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cd:	f3 0f 1e fb          	endbr32 
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001da:	50                   	push   %eax
  8001db:	ff 75 08             	pushl  0x8(%ebp)
  8001de:	e8 95 ff ff ff       	call   800178 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	57                   	push   %edi
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 1c             	sub    $0x1c,%esp
  8001ee:	89 c7                	mov    %eax,%edi
  8001f0:	89 d6                	mov    %edx,%esi
  8001f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f8:	89 d1                	mov    %edx,%ecx
  8001fa:	89 c2                	mov    %eax,%edx
  8001fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800202:	8b 45 10             	mov    0x10(%ebp),%eax
  800205:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800208:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80020b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800212:	39 c2                	cmp    %eax,%edx
  800214:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800217:	72 3e                	jb     800257 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800219:	83 ec 0c             	sub    $0xc,%esp
  80021c:	ff 75 18             	pushl  0x18(%ebp)
  80021f:	83 eb 01             	sub    $0x1,%ebx
  800222:	53                   	push   %ebx
  800223:	50                   	push   %eax
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022a:	ff 75 e0             	pushl  -0x20(%ebp)
  80022d:	ff 75 dc             	pushl  -0x24(%ebp)
  800230:	ff 75 d8             	pushl  -0x28(%ebp)
  800233:	e8 28 1f 00 00       	call   802160 <__udivdi3>
  800238:	83 c4 18             	add    $0x18,%esp
  80023b:	52                   	push   %edx
  80023c:	50                   	push   %eax
  80023d:	89 f2                	mov    %esi,%edx
  80023f:	89 f8                	mov    %edi,%eax
  800241:	e8 9f ff ff ff       	call   8001e5 <printnum>
  800246:	83 c4 20             	add    $0x20,%esp
  800249:	eb 13                	jmp    80025e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024b:	83 ec 08             	sub    $0x8,%esp
  80024e:	56                   	push   %esi
  80024f:	ff 75 18             	pushl  0x18(%ebp)
  800252:	ff d7                	call   *%edi
  800254:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800257:	83 eb 01             	sub    $0x1,%ebx
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7f ed                	jg     80024b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025e:	83 ec 08             	sub    $0x8,%esp
  800261:	56                   	push   %esi
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	ff 75 e4             	pushl  -0x1c(%ebp)
  800268:	ff 75 e0             	pushl  -0x20(%ebp)
  80026b:	ff 75 dc             	pushl  -0x24(%ebp)
  80026e:	ff 75 d8             	pushl  -0x28(%ebp)
  800271:	e8 fa 1f 00 00       	call   802270 <__umoddi3>
  800276:	83 c4 14             	add    $0x14,%esp
  800279:	0f be 80 f3 23 80 00 	movsbl 0x8023f3(%eax),%eax
  800280:	50                   	push   %eax
  800281:	ff d7                	call   *%edi
}
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800289:	5b                   	pop    %ebx
  80028a:	5e                   	pop    %esi
  80028b:	5f                   	pop    %edi
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    

0080028e <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80028e:	83 fa 01             	cmp    $0x1,%edx
  800291:	7f 13                	jg     8002a6 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800293:	85 d2                	test   %edx,%edx
  800295:	74 1c                	je     8002b3 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800297:	8b 10                	mov    (%eax),%edx
  800299:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029c:	89 08                	mov    %ecx,(%eax)
  80029e:	8b 02                	mov    (%edx),%eax
  8002a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a5:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8002a6:	8b 10                	mov    (%eax),%edx
  8002a8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ab:	89 08                	mov    %ecx,(%eax)
  8002ad:	8b 02                	mov    (%edx),%eax
  8002af:	8b 52 04             	mov    0x4(%edx),%edx
  8002b2:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b8:	89 08                	mov    %ecx,(%eax)
  8002ba:	8b 02                	mov    (%edx),%eax
  8002bc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c1:	c3                   	ret    

008002c2 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002c2:	83 fa 01             	cmp    $0x1,%edx
  8002c5:	7f 0f                	jg     8002d6 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8002c7:	85 d2                	test   %edx,%edx
  8002c9:	74 18                	je     8002e3 <getint+0x21>
		return va_arg(*ap, long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	99                   	cltd   
  8002d5:	c3                   	ret    
		return va_arg(*ap, long long);
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002db:	89 08                	mov    %ecx,(%eax)
  8002dd:	8b 02                	mov    (%edx),%eax
  8002df:	8b 52 04             	mov    0x4(%edx),%edx
  8002e2:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8002e3:	8b 10                	mov    (%eax),%edx
  8002e5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e8:	89 08                	mov    %ecx,(%eax)
  8002ea:	8b 02                	mov    (%edx),%eax
  8002ec:	99                   	cltd   
}
  8002ed:	c3                   	ret    

008002ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ee:	f3 0f 1e fb          	endbr32 
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	3b 50 04             	cmp    0x4(%eax),%edx
  800301:	73 0a                	jae    80030d <sprintputch+0x1f>
		*b->buf++ = ch;
  800303:	8d 4a 01             	lea    0x1(%edx),%ecx
  800306:	89 08                	mov    %ecx,(%eax)
  800308:	8b 45 08             	mov    0x8(%ebp),%eax
  80030b:	88 02                	mov    %al,(%edx)
}
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <printfmt>:
{
  80030f:	f3 0f 1e fb          	endbr32 
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800319:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031c:	50                   	push   %eax
  80031d:	ff 75 10             	pushl  0x10(%ebp)
  800320:	ff 75 0c             	pushl  0xc(%ebp)
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 05 00 00 00       	call   800330 <vprintfmt>
}
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	c9                   	leave  
  80032f:	c3                   	ret    

00800330 <vprintfmt>:
{
  800330:	f3 0f 1e fb          	endbr32 
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	57                   	push   %edi
  800338:	56                   	push   %esi
  800339:	53                   	push   %ebx
  80033a:	83 ec 2c             	sub    $0x2c,%esp
  80033d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800340:	8b 75 0c             	mov    0xc(%ebp),%esi
  800343:	8b 7d 10             	mov    0x10(%ebp),%edi
  800346:	e9 86 02 00 00       	jmp    8005d1 <vprintfmt+0x2a1>
		padc = ' ';
  80034b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80034f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800356:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80035d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800364:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8d 47 01             	lea    0x1(%edi),%eax
  80036c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036f:	0f b6 17             	movzbl (%edi),%edx
  800372:	8d 42 dd             	lea    -0x23(%edx),%eax
  800375:	3c 55                	cmp    $0x55,%al
  800377:	0f 87 df 02 00 00    	ja     80065c <vprintfmt+0x32c>
  80037d:	0f b6 c0             	movzbl %al,%eax
  800380:	3e ff 24 85 40 25 80 	notrack jmp *0x802540(,%eax,4)
  800387:	00 
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80038b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80038f:	eb d8                	jmp    800369 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800394:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800398:	eb cf                	jmp    800369 <vprintfmt+0x39>
  80039a:	0f b6 d2             	movzbl %dl,%edx
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ab:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003af:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003b2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b5:	83 f9 09             	cmp    $0x9,%ecx
  8003b8:	77 52                	ja     80040c <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8003ba:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003bd:	eb e9                	jmp    8003a8 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c2:	8d 50 04             	lea    0x4(%eax),%edx
  8003c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c8:	8b 00                	mov    (%eax),%eax
  8003ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d4:	79 93                	jns    800369 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003dc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003e3:	eb 84                	jmp    800369 <vprintfmt+0x39>
  8003e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e8:	85 c0                	test   %eax,%eax
  8003ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ef:	0f 49 d0             	cmovns %eax,%edx
  8003f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f8:	e9 6c ff ff ff       	jmp    800369 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800400:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800407:	e9 5d ff ff ff       	jmp    800369 <vprintfmt+0x39>
  80040c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800412:	eb bc                	jmp    8003d0 <vprintfmt+0xa0>
			lflag++;
  800414:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80041a:	e9 4a ff ff ff       	jmp    800369 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80041f:	8b 45 14             	mov    0x14(%ebp),%eax
  800422:	8d 50 04             	lea    0x4(%eax),%edx
  800425:	89 55 14             	mov    %edx,0x14(%ebp)
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	56                   	push   %esi
  80042c:	ff 30                	pushl  (%eax)
  80042e:	ff d3                	call   *%ebx
			break;
  800430:	83 c4 10             	add    $0x10,%esp
  800433:	e9 96 01 00 00       	jmp    8005ce <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 50 04             	lea    0x4(%eax),%edx
  80043e:	89 55 14             	mov    %edx,0x14(%ebp)
  800441:	8b 00                	mov    (%eax),%eax
  800443:	99                   	cltd   
  800444:	31 d0                	xor    %edx,%eax
  800446:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800448:	83 f8 0f             	cmp    $0xf,%eax
  80044b:	7f 20                	jg     80046d <vprintfmt+0x13d>
  80044d:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  800454:	85 d2                	test   %edx,%edx
  800456:	74 15                	je     80046d <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800458:	52                   	push   %edx
  800459:	68 d1 29 80 00       	push   $0x8029d1
  80045e:	56                   	push   %esi
  80045f:	53                   	push   %ebx
  800460:	e8 aa fe ff ff       	call   80030f <printfmt>
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	e9 61 01 00 00       	jmp    8005ce <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80046d:	50                   	push   %eax
  80046e:	68 0b 24 80 00       	push   $0x80240b
  800473:	56                   	push   %esi
  800474:	53                   	push   %ebx
  800475:	e8 95 fe ff ff       	call   80030f <printfmt>
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	e9 4c 01 00 00       	jmp    8005ce <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800482:	8b 45 14             	mov    0x14(%ebp),%eax
  800485:	8d 50 04             	lea    0x4(%eax),%edx
  800488:	89 55 14             	mov    %edx,0x14(%ebp)
  80048b:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80048d:	85 c9                	test   %ecx,%ecx
  80048f:	b8 04 24 80 00       	mov    $0x802404,%eax
  800494:	0f 45 c1             	cmovne %ecx,%eax
  800497:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80049a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049e:	7e 06                	jle    8004a6 <vprintfmt+0x176>
  8004a0:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004a4:	75 0d                	jne    8004b3 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004a9:	89 c7                	mov    %eax,%edi
  8004ab:	03 45 e0             	add    -0x20(%ebp),%eax
  8004ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b1:	eb 57                	jmp    80050a <vprintfmt+0x1da>
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b9:	ff 75 cc             	pushl  -0x34(%ebp)
  8004bc:	e8 4f 02 00 00       	call   800710 <strnlen>
  8004c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c4:	29 c2                	sub    %eax,%edx
  8004c6:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004c9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004cc:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8004d0:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8004d3:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	85 db                	test   %ebx,%ebx
  8004d7:	7e 10                	jle    8004e9 <vprintfmt+0x1b9>
					putch(padc, putdat);
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	56                   	push   %esi
  8004dd:	57                   	push   %edi
  8004de:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e1:	83 eb 01             	sub    $0x1,%ebx
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	eb ec                	jmp    8004d5 <vprintfmt+0x1a5>
  8004e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004ec:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f6:	0f 49 c2             	cmovns %edx,%eax
  8004f9:	29 c2                	sub    %eax,%edx
  8004fb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004fe:	eb a6                	jmp    8004a6 <vprintfmt+0x176>
					putch(ch, putdat);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	56                   	push   %esi
  800504:	52                   	push   %edx
  800505:	ff d3                	call   *%ebx
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80050d:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050f:	83 c7 01             	add    $0x1,%edi
  800512:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800516:	0f be d0             	movsbl %al,%edx
  800519:	85 d2                	test   %edx,%edx
  80051b:	74 42                	je     80055f <vprintfmt+0x22f>
  80051d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800521:	78 06                	js     800529 <vprintfmt+0x1f9>
  800523:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800527:	78 1e                	js     800547 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800529:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80052d:	74 d1                	je     800500 <vprintfmt+0x1d0>
  80052f:	0f be c0             	movsbl %al,%eax
  800532:	83 e8 20             	sub    $0x20,%eax
  800535:	83 f8 5e             	cmp    $0x5e,%eax
  800538:	76 c6                	jbe    800500 <vprintfmt+0x1d0>
					putch('?', putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	56                   	push   %esi
  80053e:	6a 3f                	push   $0x3f
  800540:	ff d3                	call   *%ebx
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	eb c3                	jmp    80050a <vprintfmt+0x1da>
  800547:	89 cf                	mov    %ecx,%edi
  800549:	eb 0e                	jmp    800559 <vprintfmt+0x229>
				putch(' ', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	56                   	push   %esi
  80054f:	6a 20                	push   $0x20
  800551:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800553:	83 ef 01             	sub    $0x1,%edi
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	85 ff                	test   %edi,%edi
  80055b:	7f ee                	jg     80054b <vprintfmt+0x21b>
  80055d:	eb 6f                	jmp    8005ce <vprintfmt+0x29e>
  80055f:	89 cf                	mov    %ecx,%edi
  800561:	eb f6                	jmp    800559 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800563:	89 ca                	mov    %ecx,%edx
  800565:	8d 45 14             	lea    0x14(%ebp),%eax
  800568:	e8 55 fd ff ff       	call   8002c2 <getint>
  80056d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800570:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800573:	85 d2                	test   %edx,%edx
  800575:	78 0b                	js     800582 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800577:	89 d1                	mov    %edx,%ecx
  800579:	89 c2                	mov    %eax,%edx
			base = 10;
  80057b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800580:	eb 32                	jmp    8005b4 <vprintfmt+0x284>
				putch('-', putdat);
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	56                   	push   %esi
  800586:	6a 2d                	push   $0x2d
  800588:	ff d3                	call   *%ebx
				num = -(long long) num;
  80058a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800590:	f7 da                	neg    %edx
  800592:	83 d1 00             	adc    $0x0,%ecx
  800595:	f7 d9                	neg    %ecx
  800597:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80059a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059f:	eb 13                	jmp    8005b4 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8005a1:	89 ca                	mov    %ecx,%edx
  8005a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a6:	e8 e3 fc ff ff       	call   80028e <getuint>
  8005ab:	89 d1                	mov    %edx,%ecx
  8005ad:	89 c2                	mov    %eax,%edx
			base = 10;
  8005af:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005b4:	83 ec 0c             	sub    $0xc,%esp
  8005b7:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005bb:	57                   	push   %edi
  8005bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8005bf:	50                   	push   %eax
  8005c0:	51                   	push   %ecx
  8005c1:	52                   	push   %edx
  8005c2:	89 f2                	mov    %esi,%edx
  8005c4:	89 d8                	mov    %ebx,%eax
  8005c6:	e8 1a fc ff ff       	call   8001e5 <printnum>
			break;
  8005cb:	83 c4 20             	add    $0x20,%esp
{
  8005ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005d1:	83 c7 01             	add    $0x1,%edi
  8005d4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005d8:	83 f8 25             	cmp    $0x25,%eax
  8005db:	0f 84 6a fd ff ff    	je     80034b <vprintfmt+0x1b>
			if (ch == '\0')
  8005e1:	85 c0                	test   %eax,%eax
  8005e3:	0f 84 93 00 00 00    	je     80067c <vprintfmt+0x34c>
			putch(ch, putdat);
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	56                   	push   %esi
  8005ed:	50                   	push   %eax
  8005ee:	ff d3                	call   *%ebx
  8005f0:	83 c4 10             	add    $0x10,%esp
  8005f3:	eb dc                	jmp    8005d1 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8005f5:	89 ca                	mov    %ecx,%edx
  8005f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fa:	e8 8f fc ff ff       	call   80028e <getuint>
  8005ff:	89 d1                	mov    %edx,%ecx
  800601:	89 c2                	mov    %eax,%edx
			base = 8;
  800603:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800608:	eb aa                	jmp    8005b4 <vprintfmt+0x284>
			putch('0', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	56                   	push   %esi
  80060e:	6a 30                	push   $0x30
  800610:	ff d3                	call   *%ebx
			putch('x', putdat);
  800612:	83 c4 08             	add    $0x8,%esp
  800615:	56                   	push   %esi
  800616:	6a 78                	push   $0x78
  800618:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800623:	8b 10                	mov    (%eax),%edx
  800625:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80062a:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80062d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800632:	eb 80                	jmp    8005b4 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800634:	89 ca                	mov    %ecx,%edx
  800636:	8d 45 14             	lea    0x14(%ebp),%eax
  800639:	e8 50 fc ff ff       	call   80028e <getuint>
  80063e:	89 d1                	mov    %edx,%ecx
  800640:	89 c2                	mov    %eax,%edx
			base = 16;
  800642:	b8 10 00 00 00       	mov    $0x10,%eax
  800647:	e9 68 ff ff ff       	jmp    8005b4 <vprintfmt+0x284>
			putch(ch, putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	56                   	push   %esi
  800650:	6a 25                	push   $0x25
  800652:	ff d3                	call   *%ebx
			break;
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	e9 72 ff ff ff       	jmp    8005ce <vprintfmt+0x29e>
			putch('%', putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	56                   	push   %esi
  800660:	6a 25                	push   $0x25
  800662:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	89 f8                	mov    %edi,%eax
  800669:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80066d:	74 05                	je     800674 <vprintfmt+0x344>
  80066f:	83 e8 01             	sub    $0x1,%eax
  800672:	eb f5                	jmp    800669 <vprintfmt+0x339>
  800674:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800677:	e9 52 ff ff ff       	jmp    8005ce <vprintfmt+0x29e>
}
  80067c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067f:	5b                   	pop    %ebx
  800680:	5e                   	pop    %esi
  800681:	5f                   	pop    %edi
  800682:	5d                   	pop    %ebp
  800683:	c3                   	ret    

00800684 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800684:	f3 0f 1e fb          	endbr32 
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	83 ec 18             	sub    $0x18,%esp
  80068e:	8b 45 08             	mov    0x8(%ebp),%eax
  800691:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800694:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800697:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80069b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80069e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a5:	85 c0                	test   %eax,%eax
  8006a7:	74 26                	je     8006cf <vsnprintf+0x4b>
  8006a9:	85 d2                	test   %edx,%edx
  8006ab:	7e 22                	jle    8006cf <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ad:	ff 75 14             	pushl  0x14(%ebp)
  8006b0:	ff 75 10             	pushl  0x10(%ebp)
  8006b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b6:	50                   	push   %eax
  8006b7:	68 ee 02 80 00       	push   $0x8002ee
  8006bc:	e8 6f fc ff ff       	call   800330 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ca:	83 c4 10             	add    $0x10,%esp
}
  8006cd:	c9                   	leave  
  8006ce:	c3                   	ret    
		return -E_INVAL;
  8006cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d4:	eb f7                	jmp    8006cd <vsnprintf+0x49>

008006d6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d6:	f3 0f 1e fb          	endbr32 
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e3:	50                   	push   %eax
  8006e4:	ff 75 10             	pushl  0x10(%ebp)
  8006e7:	ff 75 0c             	pushl  0xc(%ebp)
  8006ea:	ff 75 08             	pushl  0x8(%ebp)
  8006ed:	e8 92 ff ff ff       	call   800684 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f4:	f3 0f 1e fb          	endbr32 
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800703:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800707:	74 05                	je     80070e <strlen+0x1a>
		n++;
  800709:	83 c0 01             	add    $0x1,%eax
  80070c:	eb f5                	jmp    800703 <strlen+0xf>
	return n;
}
  80070e:	5d                   	pop    %ebp
  80070f:	c3                   	ret    

00800710 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800710:	f3 0f 1e fb          	endbr32 
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071d:	b8 00 00 00 00       	mov    $0x0,%eax
  800722:	39 d0                	cmp    %edx,%eax
  800724:	74 0d                	je     800733 <strnlen+0x23>
  800726:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80072a:	74 05                	je     800731 <strnlen+0x21>
		n++;
  80072c:	83 c0 01             	add    $0x1,%eax
  80072f:	eb f1                	jmp    800722 <strnlen+0x12>
  800731:	89 c2                	mov    %eax,%edx
	return n;
}
  800733:	89 d0                	mov    %edx,%eax
  800735:	5d                   	pop    %ebp
  800736:	c3                   	ret    

00800737 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800737:	f3 0f 1e fb          	endbr32 
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	53                   	push   %ebx
  80073f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800742:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800745:	b8 00 00 00 00       	mov    $0x0,%eax
  80074a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80074e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800751:	83 c0 01             	add    $0x1,%eax
  800754:	84 d2                	test   %dl,%dl
  800756:	75 f2                	jne    80074a <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800758:	89 c8                	mov    %ecx,%eax
  80075a:	5b                   	pop    %ebx
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075d:	f3 0f 1e fb          	endbr32 
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	53                   	push   %ebx
  800765:	83 ec 10             	sub    $0x10,%esp
  800768:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076b:	53                   	push   %ebx
  80076c:	e8 83 ff ff ff       	call   8006f4 <strlen>
  800771:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800774:	ff 75 0c             	pushl  0xc(%ebp)
  800777:	01 d8                	add    %ebx,%eax
  800779:	50                   	push   %eax
  80077a:	e8 b8 ff ff ff       	call   800737 <strcpy>
	return dst;
}
  80077f:	89 d8                	mov    %ebx,%eax
  800781:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800784:	c9                   	leave  
  800785:	c3                   	ret    

00800786 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800786:	f3 0f 1e fb          	endbr32 
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	56                   	push   %esi
  80078e:	53                   	push   %ebx
  80078f:	8b 75 08             	mov    0x8(%ebp),%esi
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
  800795:	89 f3                	mov    %esi,%ebx
  800797:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079a:	89 f0                	mov    %esi,%eax
  80079c:	39 d8                	cmp    %ebx,%eax
  80079e:	74 11                	je     8007b1 <strncpy+0x2b>
		*dst++ = *src;
  8007a0:	83 c0 01             	add    $0x1,%eax
  8007a3:	0f b6 0a             	movzbl (%edx),%ecx
  8007a6:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a9:	80 f9 01             	cmp    $0x1,%cl
  8007ac:	83 da ff             	sbb    $0xffffffff,%edx
  8007af:	eb eb                	jmp    80079c <strncpy+0x16>
	}
	return ret;
}
  8007b1:	89 f0                	mov    %esi,%eax
  8007b3:	5b                   	pop    %ebx
  8007b4:	5e                   	pop    %esi
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b7:	f3 0f 1e fb          	endbr32 
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	56                   	push   %esi
  8007bf:	53                   	push   %ebx
  8007c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c6:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007cb:	85 d2                	test   %edx,%edx
  8007cd:	74 21                	je     8007f0 <strlcpy+0x39>
  8007cf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007d3:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8007d5:	39 c2                	cmp    %eax,%edx
  8007d7:	74 14                	je     8007ed <strlcpy+0x36>
  8007d9:	0f b6 19             	movzbl (%ecx),%ebx
  8007dc:	84 db                	test   %bl,%bl
  8007de:	74 0b                	je     8007eb <strlcpy+0x34>
			*dst++ = *src++;
  8007e0:	83 c1 01             	add    $0x1,%ecx
  8007e3:	83 c2 01             	add    $0x1,%edx
  8007e6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e9:	eb ea                	jmp    8007d5 <strlcpy+0x1e>
  8007eb:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007ed:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f0:	29 f0                	sub    %esi,%eax
}
  8007f2:	5b                   	pop    %ebx
  8007f3:	5e                   	pop    %esi
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007f6:	f3 0f 1e fb          	endbr32 
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800800:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800803:	0f b6 01             	movzbl (%ecx),%eax
  800806:	84 c0                	test   %al,%al
  800808:	74 0c                	je     800816 <strcmp+0x20>
  80080a:	3a 02                	cmp    (%edx),%al
  80080c:	75 08                	jne    800816 <strcmp+0x20>
		p++, q++;
  80080e:	83 c1 01             	add    $0x1,%ecx
  800811:	83 c2 01             	add    $0x1,%edx
  800814:	eb ed                	jmp    800803 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800816:	0f b6 c0             	movzbl %al,%eax
  800819:	0f b6 12             	movzbl (%edx),%edx
  80081c:	29 d0                	sub    %edx,%eax
}
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800820:	f3 0f 1e fb          	endbr32 
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	53                   	push   %ebx
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082e:	89 c3                	mov    %eax,%ebx
  800830:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800833:	eb 06                	jmp    80083b <strncmp+0x1b>
		n--, p++, q++;
  800835:	83 c0 01             	add    $0x1,%eax
  800838:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80083b:	39 d8                	cmp    %ebx,%eax
  80083d:	74 16                	je     800855 <strncmp+0x35>
  80083f:	0f b6 08             	movzbl (%eax),%ecx
  800842:	84 c9                	test   %cl,%cl
  800844:	74 04                	je     80084a <strncmp+0x2a>
  800846:	3a 0a                	cmp    (%edx),%cl
  800848:	74 eb                	je     800835 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084a:	0f b6 00             	movzbl (%eax),%eax
  80084d:	0f b6 12             	movzbl (%edx),%edx
  800850:	29 d0                	sub    %edx,%eax
}
  800852:	5b                   	pop    %ebx
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    
		return 0;
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
  80085a:	eb f6                	jmp    800852 <strncmp+0x32>

0080085c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085c:	f3 0f 1e fb          	endbr32 
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086a:	0f b6 10             	movzbl (%eax),%edx
  80086d:	84 d2                	test   %dl,%dl
  80086f:	74 09                	je     80087a <strchr+0x1e>
		if (*s == c)
  800871:	38 ca                	cmp    %cl,%dl
  800873:	74 0a                	je     80087f <strchr+0x23>
	for (; *s; s++)
  800875:	83 c0 01             	add    $0x1,%eax
  800878:	eb f0                	jmp    80086a <strchr+0xe>
			return (char *) s;
	return 0;
  80087a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800881:	f3 0f 1e fb          	endbr32 
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800892:	38 ca                	cmp    %cl,%dl
  800894:	74 09                	je     80089f <strfind+0x1e>
  800896:	84 d2                	test   %dl,%dl
  800898:	74 05                	je     80089f <strfind+0x1e>
	for (; *s; s++)
  80089a:	83 c0 01             	add    $0x1,%eax
  80089d:	eb f0                	jmp    80088f <strfind+0xe>
			break;
	return (char *) s;
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a1:	f3 0f 1e fb          	endbr32 
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	57                   	push   %edi
  8008a9:	56                   	push   %esi
  8008aa:	53                   	push   %ebx
  8008ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8008b1:	85 c9                	test   %ecx,%ecx
  8008b3:	74 33                	je     8008e8 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b5:	89 d0                	mov    %edx,%eax
  8008b7:	09 c8                	or     %ecx,%eax
  8008b9:	a8 03                	test   $0x3,%al
  8008bb:	75 23                	jne    8008e0 <memset+0x3f>
		c &= 0xFF;
  8008bd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c1:	89 d8                	mov    %ebx,%eax
  8008c3:	c1 e0 08             	shl    $0x8,%eax
  8008c6:	89 df                	mov    %ebx,%edi
  8008c8:	c1 e7 18             	shl    $0x18,%edi
  8008cb:	89 de                	mov    %ebx,%esi
  8008cd:	c1 e6 10             	shl    $0x10,%esi
  8008d0:	09 f7                	or     %esi,%edi
  8008d2:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  8008d4:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8008d9:	89 d7                	mov    %edx,%edi
  8008db:	fc                   	cld    
  8008dc:	f3 ab                	rep stos %eax,%es:(%edi)
  8008de:	eb 08                	jmp    8008e8 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e0:	89 d7                	mov    %edx,%edi
  8008e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e5:	fc                   	cld    
  8008e6:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8008e8:	89 d0                	mov    %edx,%eax
  8008ea:	5b                   	pop    %ebx
  8008eb:	5e                   	pop    %esi
  8008ec:	5f                   	pop    %edi
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ef:	f3 0f 1e fb          	endbr32 
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	57                   	push   %edi
  8008f7:	56                   	push   %esi
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800901:	39 c6                	cmp    %eax,%esi
  800903:	73 32                	jae    800937 <memmove+0x48>
  800905:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800908:	39 c2                	cmp    %eax,%edx
  80090a:	76 2b                	jbe    800937 <memmove+0x48>
		s += n;
		d += n;
  80090c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090f:	89 fe                	mov    %edi,%esi
  800911:	09 ce                	or     %ecx,%esi
  800913:	09 d6                	or     %edx,%esi
  800915:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80091b:	75 0e                	jne    80092b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80091d:	83 ef 04             	sub    $0x4,%edi
  800920:	8d 72 fc             	lea    -0x4(%edx),%esi
  800923:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800926:	fd                   	std    
  800927:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800929:	eb 09                	jmp    800934 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80092b:	83 ef 01             	sub    $0x1,%edi
  80092e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800931:	fd                   	std    
  800932:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800934:	fc                   	cld    
  800935:	eb 1a                	jmp    800951 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800937:	89 c2                	mov    %eax,%edx
  800939:	09 ca                	or     %ecx,%edx
  80093b:	09 f2                	or     %esi,%edx
  80093d:	f6 c2 03             	test   $0x3,%dl
  800940:	75 0a                	jne    80094c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800942:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800945:	89 c7                	mov    %eax,%edi
  800947:	fc                   	cld    
  800948:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094a:	eb 05                	jmp    800951 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  80094c:	89 c7                	mov    %eax,%edi
  80094e:	fc                   	cld    
  80094f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800951:	5e                   	pop    %esi
  800952:	5f                   	pop    %edi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800955:	f3 0f 1e fb          	endbr32 
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80095f:	ff 75 10             	pushl  0x10(%ebp)
  800962:	ff 75 0c             	pushl  0xc(%ebp)
  800965:	ff 75 08             	pushl  0x8(%ebp)
  800968:	e8 82 ff ff ff       	call   8008ef <memmove>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096f:	f3 0f 1e fb          	endbr32 
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	56                   	push   %esi
  800977:	53                   	push   %ebx
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097e:	89 c6                	mov    %eax,%esi
  800980:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800983:	39 f0                	cmp    %esi,%eax
  800985:	74 1c                	je     8009a3 <memcmp+0x34>
		if (*s1 != *s2)
  800987:	0f b6 08             	movzbl (%eax),%ecx
  80098a:	0f b6 1a             	movzbl (%edx),%ebx
  80098d:	38 d9                	cmp    %bl,%cl
  80098f:	75 08                	jne    800999 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800991:	83 c0 01             	add    $0x1,%eax
  800994:	83 c2 01             	add    $0x1,%edx
  800997:	eb ea                	jmp    800983 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800999:	0f b6 c1             	movzbl %cl,%eax
  80099c:	0f b6 db             	movzbl %bl,%ebx
  80099f:	29 d8                	sub    %ebx,%eax
  8009a1:	eb 05                	jmp    8009a8 <memcmp+0x39>
	}

	return 0;
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ac:	f3 0f 1e fb          	endbr32 
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009b9:	89 c2                	mov    %eax,%edx
  8009bb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009be:	39 d0                	cmp    %edx,%eax
  8009c0:	73 09                	jae    8009cb <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c2:	38 08                	cmp    %cl,(%eax)
  8009c4:	74 05                	je     8009cb <memfind+0x1f>
	for (; s < ends; s++)
  8009c6:	83 c0 01             	add    $0x1,%eax
  8009c9:	eb f3                	jmp    8009be <memfind+0x12>
			break;
	return (void *) s;
}
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009cd:	f3 0f 1e fb          	endbr32 
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	57                   	push   %edi
  8009d5:	56                   	push   %esi
  8009d6:	53                   	push   %ebx
  8009d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009dd:	eb 03                	jmp    8009e2 <strtol+0x15>
		s++;
  8009df:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009e2:	0f b6 01             	movzbl (%ecx),%eax
  8009e5:	3c 20                	cmp    $0x20,%al
  8009e7:	74 f6                	je     8009df <strtol+0x12>
  8009e9:	3c 09                	cmp    $0x9,%al
  8009eb:	74 f2                	je     8009df <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  8009ed:	3c 2b                	cmp    $0x2b,%al
  8009ef:	74 2a                	je     800a1b <strtol+0x4e>
	int neg = 0;
  8009f1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009f6:	3c 2d                	cmp    $0x2d,%al
  8009f8:	74 2b                	je     800a25 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fa:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a00:	75 0f                	jne    800a11 <strtol+0x44>
  800a02:	80 39 30             	cmpb   $0x30,(%ecx)
  800a05:	74 28                	je     800a2f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a07:	85 db                	test   %ebx,%ebx
  800a09:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a0e:	0f 44 d8             	cmove  %eax,%ebx
  800a11:	b8 00 00 00 00       	mov    $0x0,%eax
  800a16:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a19:	eb 46                	jmp    800a61 <strtol+0x94>
		s++;
  800a1b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a1e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a23:	eb d5                	jmp    8009fa <strtol+0x2d>
		s++, neg = 1;
  800a25:	83 c1 01             	add    $0x1,%ecx
  800a28:	bf 01 00 00 00       	mov    $0x1,%edi
  800a2d:	eb cb                	jmp    8009fa <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a33:	74 0e                	je     800a43 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a35:	85 db                	test   %ebx,%ebx
  800a37:	75 d8                	jne    800a11 <strtol+0x44>
		s++, base = 8;
  800a39:	83 c1 01             	add    $0x1,%ecx
  800a3c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a41:	eb ce                	jmp    800a11 <strtol+0x44>
		s += 2, base = 16;
  800a43:	83 c1 02             	add    $0x2,%ecx
  800a46:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a4b:	eb c4                	jmp    800a11 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a4d:	0f be d2             	movsbl %dl,%edx
  800a50:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a53:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a56:	7d 3a                	jge    800a92 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a58:	83 c1 01             	add    $0x1,%ecx
  800a5b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a61:	0f b6 11             	movzbl (%ecx),%edx
  800a64:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a67:	89 f3                	mov    %esi,%ebx
  800a69:	80 fb 09             	cmp    $0x9,%bl
  800a6c:	76 df                	jbe    800a4d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800a6e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a71:	89 f3                	mov    %esi,%ebx
  800a73:	80 fb 19             	cmp    $0x19,%bl
  800a76:	77 08                	ja     800a80 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a78:	0f be d2             	movsbl %dl,%edx
  800a7b:	83 ea 57             	sub    $0x57,%edx
  800a7e:	eb d3                	jmp    800a53 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800a80:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a83:	89 f3                	mov    %esi,%ebx
  800a85:	80 fb 19             	cmp    $0x19,%bl
  800a88:	77 08                	ja     800a92 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a8a:	0f be d2             	movsbl %dl,%edx
  800a8d:	83 ea 37             	sub    $0x37,%edx
  800a90:	eb c1                	jmp    800a53 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a92:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a96:	74 05                	je     800a9d <strtol+0xd0>
		*endptr = (char *) s;
  800a98:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a9d:	89 c2                	mov    %eax,%edx
  800a9f:	f7 da                	neg    %edx
  800aa1:	85 ff                	test   %edi,%edi
  800aa3:	0f 45 c2             	cmovne %edx,%eax
}
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5f                   	pop    %edi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	57                   	push   %edi
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	83 ec 1c             	sub    $0x1c,%esp
  800ab4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ab7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800aba:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800abf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac2:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ac5:	8b 75 14             	mov    0x14(%ebp),%esi
  800ac8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ace:	74 04                	je     800ad4 <syscall+0x29>
  800ad0:	85 c0                	test   %eax,%eax
  800ad2:	7f 08                	jg     800adc <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800ad4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	50                   	push   %eax
  800ae0:	ff 75 e0             	pushl  -0x20(%ebp)
  800ae3:	68 ff 26 80 00       	push   $0x8026ff
  800ae8:	6a 23                	push   $0x23
  800aea:	68 1c 27 80 00       	push   $0x80271c
  800aef:	e8 3b 15 00 00       	call   80202f <_panic>

00800af4 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800af4:	f3 0f 1e fb          	endbr32 
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800afe:	6a 00                	push   $0x0
  800b00:	6a 00                	push   $0x0
  800b02:	6a 00                	push   $0x0
  800b04:	ff 75 0c             	pushl  0xc(%ebp)
  800b07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b14:	e8 92 ff ff ff       	call   800aab <syscall>
}
  800b19:	83 c4 10             	add    $0x10,%esp
  800b1c:	c9                   	leave  
  800b1d:	c3                   	ret    

00800b1e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1e:	f3 0f 1e fb          	endbr32 
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b28:	6a 00                	push   $0x0
  800b2a:	6a 00                	push   $0x0
  800b2c:	6a 00                	push   $0x0
  800b2e:	6a 00                	push   $0x0
  800b30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b35:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3f:	e8 67 ff ff ff       	call   800aab <syscall>
}
  800b44:	c9                   	leave  
  800b45:	c3                   	ret    

00800b46 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b46:	f3 0f 1e fb          	endbr32 
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b50:	6a 00                	push   $0x0
  800b52:	6a 00                	push   $0x0
  800b54:	6a 00                	push   $0x0
  800b56:	6a 00                	push   $0x0
  800b58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5b:	ba 01 00 00 00       	mov    $0x1,%edx
  800b60:	b8 03 00 00 00       	mov    $0x3,%eax
  800b65:	e8 41 ff ff ff       	call   800aab <syscall>
}
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b6c:	f3 0f 1e fb          	endbr32 
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b76:	6a 00                	push   $0x0
  800b78:	6a 00                	push   $0x0
  800b7a:	6a 00                	push   $0x0
  800b7c:	6a 00                	push   $0x0
  800b7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b83:	ba 00 00 00 00       	mov    $0x0,%edx
  800b88:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8d:	e8 19 ff ff ff       	call   800aab <syscall>
}
  800b92:	c9                   	leave  
  800b93:	c3                   	ret    

00800b94 <sys_yield>:

void
sys_yield(void)
{
  800b94:	f3 0f 1e fb          	endbr32 
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b9e:	6a 00                	push   $0x0
  800ba0:	6a 00                	push   $0x0
  800ba2:	6a 00                	push   $0x0
  800ba4:	6a 00                	push   $0x0
  800ba6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bab:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb5:	e8 f1 fe ff ff       	call   800aab <syscall>
}
  800bba:	83 c4 10             	add    $0x10,%esp
  800bbd:	c9                   	leave  
  800bbe:	c3                   	ret    

00800bbf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bbf:	f3 0f 1e fb          	endbr32 
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bc9:	6a 00                	push   $0x0
  800bcb:	6a 00                	push   $0x0
  800bcd:	ff 75 10             	pushl  0x10(%ebp)
  800bd0:	ff 75 0c             	pushl  0xc(%ebp)
  800bd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd6:	ba 01 00 00 00       	mov    $0x1,%edx
  800bdb:	b8 04 00 00 00       	mov    $0x4,%eax
  800be0:	e8 c6 fe ff ff       	call   800aab <syscall>
}
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be7:	f3 0f 1e fb          	endbr32 
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bf1:	ff 75 18             	pushl  0x18(%ebp)
  800bf4:	ff 75 14             	pushl  0x14(%ebp)
  800bf7:	ff 75 10             	pushl  0x10(%ebp)
  800bfa:	ff 75 0c             	pushl  0xc(%ebp)
  800bfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c00:	ba 01 00 00 00       	mov    $0x1,%edx
  800c05:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0a:	e8 9c fe ff ff       	call   800aab <syscall>
}
  800c0f:	c9                   	leave  
  800c10:	c3                   	ret    

00800c11 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c11:	f3 0f 1e fb          	endbr32 
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c1b:	6a 00                	push   $0x0
  800c1d:	6a 00                	push   $0x0
  800c1f:	6a 00                	push   $0x0
  800c21:	ff 75 0c             	pushl  0xc(%ebp)
  800c24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c27:	ba 01 00 00 00       	mov    $0x1,%edx
  800c2c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c31:	e8 75 fe ff ff       	call   800aab <syscall>
}
  800c36:	c9                   	leave  
  800c37:	c3                   	ret    

00800c38 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c38:	f3 0f 1e fb          	endbr32 
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c42:	6a 00                	push   $0x0
  800c44:	6a 00                	push   $0x0
  800c46:	6a 00                	push   $0x0
  800c48:	ff 75 0c             	pushl  0xc(%ebp)
  800c4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4e:	ba 01 00 00 00       	mov    $0x1,%edx
  800c53:	b8 08 00 00 00       	mov    $0x8,%eax
  800c58:	e8 4e fe ff ff       	call   800aab <syscall>
}
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    

00800c5f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c5f:	f3 0f 1e fb          	endbr32 
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c69:	6a 00                	push   $0x0
  800c6b:	6a 00                	push   $0x0
  800c6d:	6a 00                	push   $0x0
  800c6f:	ff 75 0c             	pushl  0xc(%ebp)
  800c72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c75:	ba 01 00 00 00       	mov    $0x1,%edx
  800c7a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7f:	e8 27 fe ff ff       	call   800aab <syscall>
}
  800c84:	c9                   	leave  
  800c85:	c3                   	ret    

00800c86 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c86:	f3 0f 1e fb          	endbr32 
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c90:	6a 00                	push   $0x0
  800c92:	6a 00                	push   $0x0
  800c94:	6a 00                	push   $0x0
  800c96:	ff 75 0c             	pushl  0xc(%ebp)
  800c99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9c:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ca6:	e8 00 fe ff ff       	call   800aab <syscall>
}
  800cab:	c9                   	leave  
  800cac:	c3                   	ret    

00800cad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cad:	f3 0f 1e fb          	endbr32 
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cb7:	6a 00                	push   $0x0
  800cb9:	ff 75 14             	pushl  0x14(%ebp)
  800cbc:	ff 75 10             	pushl  0x10(%ebp)
  800cbf:	ff 75 0c             	pushl  0xc(%ebp)
  800cc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cca:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccf:	e8 d7 fd ff ff       	call   800aab <syscall>
}
  800cd4:	c9                   	leave  
  800cd5:	c3                   	ret    

00800cd6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd6:	f3 0f 1e fb          	endbr32 
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800ce0:	6a 00                	push   $0x0
  800ce2:	6a 00                	push   $0x0
  800ce4:	6a 00                	push   $0x0
  800ce6:	6a 00                	push   $0x0
  800ce8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ceb:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf5:	e8 b1 fd ff ff       	call   800aab <syscall>
}
  800cfa:	c9                   	leave  
  800cfb:	c3                   	ret    

00800cfc <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	53                   	push   %ebx
  800d00:	83 ec 04             	sub    $0x4,%esp
	int r;

	// LAB 4: Your code here.
	void *addr = (void *) (pn * PGSIZE);
  800d03:	89 d3                	mov    %edx,%ebx
  800d05:	c1 e3 0c             	shl    $0xc,%ebx

	if (uvpt[pn] & PTE_SHARE) {
  800d08:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d0f:	f6 c5 04             	test   $0x4,%ch
  800d12:	75 56                	jne    800d6a <duppage+0x6e>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
		return 0;
	}

	if ((uvpt[pn] & (PTE_W | PTE_COW)) != 0) {
  800d14:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d1b:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800d21:	74 72                	je     800d95 <duppage+0x99>
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW) <
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	68 05 08 00 00       	push   $0x805
  800d2b:	53                   	push   %ebx
  800d2c:	50                   	push   %eax
  800d2d:	53                   	push   %ebx
  800d2e:	6a 00                	push   $0x0
  800d30:	e8 b2 fe ff ff       	call   800be7 <sys_page_map>
  800d35:	83 c4 20             	add    $0x20,%esp
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	78 45                	js     800d81 <duppage+0x85>
		    0) {
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
		}
		if (sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW) < 0) {
  800d3c:	83 ec 0c             	sub    $0xc,%esp
  800d3f:	68 05 08 00 00       	push   $0x805
  800d44:	53                   	push   %ebx
  800d45:	6a 00                	push   $0x0
  800d47:	53                   	push   %ebx
  800d48:	6a 00                	push   $0x0
  800d4a:	e8 98 fe ff ff       	call   800be7 <sys_page_map>
  800d4f:	83 c4 20             	add    $0x20,%esp
  800d52:	85 c0                	test   %eax,%eax
  800d54:	79 55                	jns    800dab <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP FATHER");
  800d56:	83 ec 04             	sub    $0x4,%esp
  800d59:	68 4c 27 80 00       	push   $0x80274c
  800d5e:	6a 54                	push   $0x54
  800d60:	68 df 27 80 00       	push   $0x8027df
  800d65:	e8 c5 12 00 00       	call   80202f <_panic>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800d6a:	83 ec 0c             	sub    $0xc,%esp
  800d6d:	68 07 0e 00 00       	push   $0xe07
  800d72:	53                   	push   %ebx
  800d73:	50                   	push   %eax
  800d74:	53                   	push   %ebx
  800d75:	6a 00                	push   $0x0
  800d77:	e8 6b fe ff ff       	call   800be7 <sys_page_map>
		return 0;
  800d7c:	83 c4 20             	add    $0x20,%esp
  800d7f:	eb 2a                	jmp    800dab <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
  800d81:	83 ec 04             	sub    $0x4,%esp
  800d84:	68 2c 27 80 00       	push   $0x80272c
  800d89:	6a 51                	push   $0x51
  800d8b:	68 df 27 80 00       	push   $0x8027df
  800d90:	e8 9a 12 00 00       	call   80202f <_panic>
		}
	} else {
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U) < 0) {
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	6a 05                	push   $0x5
  800d9a:	53                   	push   %ebx
  800d9b:	50                   	push   %eax
  800d9c:	53                   	push   %ebx
  800d9d:	6a 00                	push   $0x0
  800d9f:	e8 43 fe ff ff       	call   800be7 <sys_page_map>
  800da4:	83 c4 20             	add    $0x20,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	78 0a                	js     800db5 <duppage+0xb9>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
		}
	}

	return 0;
}
  800dab:	b8 00 00 00 00       	mov    $0x0,%eax
  800db0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800db3:	c9                   	leave  
  800db4:	c3                   	ret    
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
  800db5:	83 ec 04             	sub    $0x4,%esp
  800db8:	68 ea 27 80 00       	push   $0x8027ea
  800dbd:	6a 58                	push   $0x58
  800dbf:	68 df 27 80 00       	push   $0x8027df
  800dc4:	e8 66 12 00 00       	call   80202f <_panic>

00800dc9 <dup_or_share>:

static void
dup_or_share(envid_t dstenv, void *va, int perm)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	89 c6                	mov    %eax,%esi
  800dd0:	89 d3                	mov    %edx,%ebx
	int r;
	if (perm & PTE_W) {
  800dd2:	f6 c1 02             	test   $0x2,%cl
  800dd5:	0f 84 8c 00 00 00    	je     800e67 <dup_or_share+0x9e>
		// dup
		if ((r = sys_page_alloc(dstenv, va, PTE_P | PTE_U | PTE_W)) < 0)
  800ddb:	83 ec 04             	sub    $0x4,%esp
  800dde:	6a 07                	push   $0x7
  800de0:	52                   	push   %edx
  800de1:	50                   	push   %eax
  800de2:	e8 d8 fd ff ff       	call   800bbf <sys_page_alloc>
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	78 55                	js     800e43 <dup_or_share+0x7a>
			panic("sys_page_alloc: %e", r);
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  800dee:	83 ec 0c             	sub    $0xc,%esp
  800df1:	6a 07                	push   $0x7
  800df3:	68 00 00 40 00       	push   $0x400000
  800df8:	6a 00                	push   $0x0
  800dfa:	53                   	push   %ebx
  800dfb:	56                   	push   %esi
  800dfc:	e8 e6 fd ff ff       	call   800be7 <sys_page_map>
  800e01:	83 c4 20             	add    $0x20,%esp
  800e04:	85 c0                	test   %eax,%eax
  800e06:	78 4d                	js     800e55 <dup_or_share+0x8c>
		    0)
			panic("sys_page_map: %e", r);
		memmove(UTEMP, va, PGSIZE);
  800e08:	83 ec 04             	sub    $0x4,%esp
  800e0b:	68 00 10 00 00       	push   $0x1000
  800e10:	53                   	push   %ebx
  800e11:	68 00 00 40 00       	push   $0x400000
  800e16:	e8 d4 fa ff ff       	call   8008ef <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800e1b:	83 c4 08             	add    $0x8,%esp
  800e1e:	68 00 00 40 00       	push   $0x400000
  800e23:	6a 00                	push   $0x0
  800e25:	e8 e7 fd ff ff       	call   800c11 <sys_page_unmap>
  800e2a:	83 c4 10             	add    $0x10,%esp
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	79 52                	jns    800e83 <dup_or_share+0xba>
			panic("sys_page_unmap: %e", r);
  800e31:	50                   	push   %eax
  800e32:	68 2a 28 80 00       	push   $0x80282a
  800e37:	6a 6c                	push   $0x6c
  800e39:	68 df 27 80 00       	push   $0x8027df
  800e3e:	e8 ec 11 00 00       	call   80202f <_panic>
			panic("sys_page_alloc: %e", r);
  800e43:	50                   	push   %eax
  800e44:	68 06 28 80 00       	push   $0x802806
  800e49:	6a 66                	push   $0x66
  800e4b:	68 df 27 80 00       	push   $0x8027df
  800e50:	e8 da 11 00 00       	call   80202f <_panic>
			panic("sys_page_map: %e", r);
  800e55:	50                   	push   %eax
  800e56:	68 19 28 80 00       	push   $0x802819
  800e5b:	6a 69                	push   $0x69
  800e5d:	68 df 27 80 00       	push   $0x8027df
  800e62:	e8 c8 11 00 00       	call   80202f <_panic>

	} else {
		// share
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | perm)) <
  800e67:	83 ec 0c             	sub    $0xc,%esp
  800e6a:	83 c9 05             	or     $0x5,%ecx
  800e6d:	51                   	push   %ecx
  800e6e:	68 00 00 40 00       	push   $0x400000
  800e73:	6a 00                	push   $0x0
  800e75:	52                   	push   %edx
  800e76:	50                   	push   %eax
  800e77:	e8 6b fd ff ff       	call   800be7 <sys_page_map>
  800e7c:	83 c4 20             	add    $0x20,%esp
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	78 07                	js     800e8a <dup_or_share+0xc1>
		    0)
			panic("sys_page_map: %e", r);
	}
}
  800e83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e86:	5b                   	pop    %ebx
  800e87:	5e                   	pop    %esi
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    
			panic("sys_page_map: %e", r);
  800e8a:	50                   	push   %eax
  800e8b:	68 19 28 80 00       	push   $0x802819
  800e90:	6a 72                	push   $0x72
  800e92:	68 df 27 80 00       	push   $0x8027df
  800e97:	e8 93 11 00 00       	call   80202f <_panic>

00800e9c <pgfault>:
{
  800e9c:	f3 0f 1e fb          	endbr32 
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 04             	sub    $0x4,%esp
  800ea7:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800eaa:	8b 02                	mov    (%edx),%eax
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800eac:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800eb0:	0f 84 95 00 00 00    	je     800f4b <pgfault+0xaf>
  800eb6:	89 c2                	mov    %eax,%edx
  800eb8:	c1 ea 16             	shr    $0x16,%edx
  800ebb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec2:	f6 c2 01             	test   $0x1,%dl
  800ec5:	0f 84 80 00 00 00    	je     800f4b <pgfault+0xaf>
	    (~uvpt[PGNUM(addr)] & (PTE_COW | PTE_P)) != 0) {
  800ecb:	89 c2                	mov    %eax,%edx
  800ecd:	c1 ea 0c             	shr    $0xc,%edx
  800ed0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed7:	f7 d2                	not    %edx
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800ed9:	f7 c2 01 08 00 00    	test   $0x801,%edx
  800edf:	75 6a                	jne    800f4b <pgfault+0xaf>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800ee1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ee6:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U) < 0) {
  800ee8:	83 ec 04             	sub    $0x4,%esp
  800eeb:	6a 07                	push   $0x7
  800eed:	68 00 f0 7f 00       	push   $0x7ff000
  800ef2:	6a 00                	push   $0x0
  800ef4:	e8 c6 fc ff ff       	call   800bbf <sys_page_alloc>
  800ef9:	83 c4 10             	add    $0x10,%esp
  800efc:	85 c0                	test   %eax,%eax
  800efe:	78 5f                	js     800f5f <pgfault+0xc3>
	memcpy((void *) PFTEMP, addr, PGSIZE);
  800f00:	83 ec 04             	sub    $0x4,%esp
  800f03:	68 00 10 00 00       	push   $0x1000
  800f08:	53                   	push   %ebx
  800f09:	68 00 f0 7f 00       	push   $0x7ff000
  800f0e:	e8 42 fa ff ff       	call   800955 <memcpy>
	if (sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U) < 0) {
  800f13:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f1a:	53                   	push   %ebx
  800f1b:	6a 00                	push   $0x0
  800f1d:	68 00 f0 7f 00       	push   $0x7ff000
  800f22:	6a 00                	push   $0x0
  800f24:	e8 be fc ff ff       	call   800be7 <sys_page_map>
  800f29:	83 c4 20             	add    $0x20,%esp
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	78 43                	js     800f73 <pgfault+0xd7>
	if (sys_page_unmap(0, (void *) PFTEMP) < 0) {
  800f30:	83 ec 08             	sub    $0x8,%esp
  800f33:	68 00 f0 7f 00       	push   $0x7ff000
  800f38:	6a 00                	push   $0x0
  800f3a:	e8 d2 fc ff ff       	call   800c11 <sys_page_unmap>
  800f3f:	83 c4 10             	add    $0x10,%esp
  800f42:	85 c0                	test   %eax,%eax
  800f44:	78 41                	js     800f87 <pgfault+0xeb>
}
  800f46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f49:	c9                   	leave  
  800f4a:	c3                   	ret    
		panic("ERROR PGFAULT");
  800f4b:	83 ec 04             	sub    $0x4,%esp
  800f4e:	68 3d 28 80 00       	push   $0x80283d
  800f53:	6a 1e                	push   $0x1e
  800f55:	68 df 27 80 00       	push   $0x8027df
  800f5a:	e8 d0 10 00 00       	call   80202f <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_ALLOC");
  800f5f:	83 ec 04             	sub    $0x4,%esp
  800f62:	68 4b 28 80 00       	push   $0x80284b
  800f67:	6a 2b                	push   $0x2b
  800f69:	68 df 27 80 00       	push   $0x8027df
  800f6e:	e8 bc 10 00 00       	call   80202f <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_MAP");
  800f73:	83 ec 04             	sub    $0x4,%esp
  800f76:	68 69 28 80 00       	push   $0x802869
  800f7b:	6a 2f                	push   $0x2f
  800f7d:	68 df 27 80 00       	push   $0x8027df
  800f82:	e8 a8 10 00 00       	call   80202f <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_UNMAP");
  800f87:	83 ec 04             	sub    $0x4,%esp
  800f8a:	68 85 28 80 00       	push   $0x802885
  800f8f:	6a 32                	push   $0x32
  800f91:	68 df 27 80 00       	push   $0x8027df
  800f96:	e8 94 10 00 00       	call   80202f <_panic>

00800f9b <fork_v0>:

envid_t
fork_v0(void)
{
  800f9b:	f3 0f 1e fb          	endbr32 
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	57                   	push   %edi
  800fa3:	56                   	push   %esi
  800fa4:	53                   	push   %ebx
  800fa5:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fa8:	b8 07 00 00 00       	mov    $0x7,%eax
  800fad:	cd 30                	int    $0x30
	envid_t env_id = sys_exofork();
	if (env_id < 0) {
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	78 24                	js     800fd7 <fork_v0+0x3c>
  800fb3:	89 c6                	mov    %eax,%esi
  800fb5:	89 c7                	mov    %eax,%edi
		thisenv = envs + ENVX(sys_getenvid());
		return env_id;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  800fb7:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (env_id == 0) {  // Son
  800fbc:	75 51                	jne    80100f <fork_v0+0x74>
		thisenv = envs + ENVX(sys_getenvid());
  800fbe:	e8 a9 fb ff ff       	call   800b6c <sys_getenvid>
  800fc3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fc8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fcb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fd0:	a3 04 40 80 00       	mov    %eax,0x804004
		return env_id;
  800fd5:	eb 78                	jmp    80104f <fork_v0+0xb4>
		panic("ERROR ON FORK_V0");
  800fd7:	83 ec 04             	sub    $0x4,%esp
  800fda:	68 a3 28 80 00       	push   $0x8028a3
  800fdf:	6a 7b                	push   $0x7b
  800fe1:	68 df 27 80 00       	push   $0x8027df
  800fe6:	e8 44 10 00 00       	call   80202f <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
				dup_or_share(env_id,
  800feb:	b9 07 00 00 00       	mov    $0x7,%ecx
  800ff0:	89 da                	mov    %ebx,%edx
  800ff2:	89 f8                	mov    %edi,%eax
  800ff4:	e8 d0 fd ff ff       	call   800dc9 <dup_or_share>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  800ff9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fff:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801005:	77 36                	ja     80103d <fork_v0+0xa2>
		if (addr != UXSTACKTOP - PGSIZE) {
  801007:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80100d:	74 ea                	je     800ff9 <fork_v0+0x5e>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80100f:	89 d8                	mov    %ebx,%eax
  801011:	c1 e8 16             	shr    $0x16,%eax
  801014:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80101b:	a8 01                	test   $0x1,%al
  80101d:	74 da                	je     800ff9 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  80101f:	89 d8                	mov    %ebx,%eax
  801021:	c1 e8 0c             	shr    $0xc,%eax
  801024:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80102b:	f6 c2 01             	test   $0x1,%dl
  80102e:	74 c9                	je     800ff9 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
  801030:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  801037:	a8 04                	test   $0x4,%al
  801039:	74 be                	je     800ff9 <fork_v0+0x5e>
  80103b:	eb ae                	jmp    800feb <fork_v0+0x50>
				             PTE_P | PTE_U | PTE_W);
			}
		}
	}

	if (sys_env_set_status(env_id, ENV_RUNNABLE) < 0) {
  80103d:	83 ec 08             	sub    $0x8,%esp
  801040:	6a 02                	push   $0x2
  801042:	56                   	push   %esi
  801043:	e8 f0 fb ff ff       	call   800c38 <sys_env_set_status>
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	85 c0                	test   %eax,%eax
  80104d:	78 0a                	js     801059 <fork_v0+0xbe>
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
	}

	return env_id;
}
  80104f:	89 f0                	mov    %esi,%eax
  801051:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801054:	5b                   	pop    %ebx
  801055:	5e                   	pop    %esi
  801056:	5f                   	pop    %edi
  801057:	5d                   	pop    %ebp
  801058:	c3                   	ret    
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
  801059:	83 ec 04             	sub    $0x4,%esp
  80105c:	68 70 27 80 00       	push   $0x802770
  801061:	68 92 00 00 00       	push   $0x92
  801066:	68 df 27 80 00       	push   $0x8027df
  80106b:	e8 bf 0f 00 00       	call   80202f <_panic>

00801070 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801070:	f3 0f 1e fb          	endbr32 
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	57                   	push   %edi
  801078:	56                   	push   %esi
  801079:	53                   	push   %ebx
  80107a:	83 ec 18             	sub    $0x18,%esp
	// return fork_v0(); // Uncomment this line if you want to run fork_v0.
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80107d:	68 9c 0e 80 00       	push   $0x800e9c
  801082:	e8 f2 0f 00 00       	call   802079 <set_pgfault_handler>
  801087:	b8 07 00 00 00       	mov    $0x7,%eax
  80108c:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0) {
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	85 c0                	test   %eax,%eax
  801093:	78 27                	js     8010bc <fork+0x4c>
  801095:	89 c7                	mov    %eax,%edi
  801097:	89 c6                	mov    %eax,%esi
		thisenv = envs + ENVX(sys_getenvid());
		return envid;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801099:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else if (envid == 0) {  // Son
  80109e:	75 55                	jne    8010f5 <fork+0x85>
		thisenv = envs + ENVX(sys_getenvid());
  8010a0:	e8 c7 fa ff ff       	call   800b6c <sys_getenvid>
  8010a5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010aa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010ad:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010b2:	a3 04 40 80 00       	mov    %eax,0x804004
		return envid;
  8010b7:	e9 9b 00 00 00       	jmp    801157 <fork+0xe7>
		panic("ERROR IN FORK: SYS_EXOFORK");
  8010bc:	83 ec 04             	sub    $0x4,%esp
  8010bf:	68 b4 28 80 00       	push   $0x8028b4
  8010c4:	68 b1 00 00 00       	push   $0xb1
  8010c9:	68 df 27 80 00       	push   $0x8027df
  8010ce:	e8 5c 0f 00 00       	call   80202f <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
				duppage(envid, addr / PGSIZE);
  8010d3:	89 da                	mov    %ebx,%edx
  8010d5:	c1 ea 0c             	shr    $0xc,%edx
  8010d8:	89 f0                	mov    %esi,%eax
  8010da:	e8 1d fc ff ff       	call   800cfc <duppage>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  8010df:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010e5:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8010eb:	77 2c                	ja     801119 <fork+0xa9>
		if (addr != UXSTACKTOP - PGSIZE) {
  8010ed:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010f3:	74 ea                	je     8010df <fork+0x6f>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  8010f5:	89 d8                	mov    %ebx,%eax
  8010f7:	c1 e8 16             	shr    $0x16,%eax
  8010fa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801101:	a8 01                	test   $0x1,%al
  801103:	74 da                	je     8010df <fork+0x6f>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
  801105:	89 d8                	mov    %ebx,%eax
  801107:	c1 e8 0c             	shr    $0xc,%eax
  80110a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801111:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801113:	a8 05                	test   $0x5,%al
  801115:	75 c8                	jne    8010df <fork+0x6f>
  801117:	eb ba                	jmp    8010d3 <fork+0x63>
			}
		}
	}

	if (sys_page_alloc(envid,
  801119:	83 ec 04             	sub    $0x4,%esp
  80111c:	6a 07                	push   $0x7
  80111e:	68 00 f0 bf ee       	push   $0xeebff000
  801123:	57                   	push   %edi
  801124:	e8 96 fa ff ff       	call   800bbf <sys_page_alloc>
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	85 c0                	test   %eax,%eax
  80112e:	78 31                	js     801161 <fork+0xf1>
	                   PTE_P | PTE_U | PTE_W) < 0) {
		panic("ERROR FORK: SYS_PAGE_ALLOC");
	}

	extern void _pgfault_upcall(void);
	if (sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0) {
  801130:	83 ec 08             	sub    $0x8,%esp
  801133:	68 ec 20 80 00       	push   $0x8020ec
  801138:	57                   	push   %edi
  801139:	e8 48 fb ff ff       	call   800c86 <sys_env_set_pgfault_upcall>
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	85 c0                	test   %eax,%eax
  801143:	78 33                	js     801178 <fork+0x108>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
	}

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0) {
  801145:	83 ec 08             	sub    $0x8,%esp
  801148:	6a 02                	push   $0x2
  80114a:	57                   	push   %edi
  80114b:	e8 e8 fa ff ff       	call   800c38 <sys_env_set_status>
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	85 c0                	test   %eax,%eax
  801155:	78 38                	js     80118f <fork+0x11f>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
	}

	return envid;
}
  801157:	89 f8                	mov    %edi,%eax
  801159:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115c:	5b                   	pop    %ebx
  80115d:	5e                   	pop    %esi
  80115e:	5f                   	pop    %edi
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    
		panic("ERROR FORK: SYS_PAGE_ALLOC");
  801161:	83 ec 04             	sub    $0x4,%esp
  801164:	68 cf 28 80 00       	push   $0x8028cf
  801169:	68 c4 00 00 00       	push   $0xc4
  80116e:	68 df 27 80 00       	push   $0x8027df
  801173:	e8 b7 0e 00 00       	call   80202f <_panic>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
  801178:	83 ec 04             	sub    $0x4,%esp
  80117b:	68 98 27 80 00       	push   $0x802798
  801180:	68 c9 00 00 00       	push   $0xc9
  801185:	68 df 27 80 00       	push   $0x8027df
  80118a:	e8 a0 0e 00 00       	call   80202f <_panic>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
  80118f:	83 ec 04             	sub    $0x4,%esp
  801192:	68 c0 27 80 00       	push   $0x8027c0
  801197:	68 cd 00 00 00       	push   $0xcd
  80119c:	68 df 27 80 00       	push   $0x8027df
  8011a1:	e8 89 0e 00 00       	call   80202f <_panic>

008011a6 <sfork>:

// Challenge!
int
sfork(void)
{
  8011a6:	f3 0f 1e fb          	endbr32 
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011b0:	68 ea 28 80 00       	push   $0x8028ea
  8011b5:	68 d7 00 00 00       	push   $0xd7
  8011ba:	68 df 27 80 00       	push   $0x8027df
  8011bf:	e8 6b 0e 00 00       	call   80202f <_panic>

008011c4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011c4:	f3 0f 1e fb          	endbr32 
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8011dd:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  8011e0:	83 ec 0c             	sub    $0xc,%esp
  8011e3:	50                   	push   %eax
  8011e4:	e8 ed fa ff ff       	call   800cd6 <sys_ipc_recv>
	if (f < 0) {
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	78 2b                	js     80121b <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  8011f0:	85 f6                	test   %esi,%esi
  8011f2:	74 0a                	je     8011fe <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  8011f4:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f9:	8b 40 74             	mov    0x74(%eax),%eax
  8011fc:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  8011fe:	85 db                	test   %ebx,%ebx
  801200:	74 0a                	je     80120c <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801202:	a1 04 40 80 00       	mov    0x804004,%eax
  801207:	8b 40 78             	mov    0x78(%eax),%eax
  80120a:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  80120c:	a1 04 40 80 00       	mov    0x804004,%eax
  801211:	8b 40 70             	mov    0x70(%eax),%eax
}
  801214:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801217:	5b                   	pop    %ebx
  801218:	5e                   	pop    %esi
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    
		if (from_env_store != NULL) {
  80121b:	85 f6                	test   %esi,%esi
  80121d:	74 06                	je     801225 <ipc_recv+0x61>
			*from_env_store = 0;
  80121f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801225:	85 db                	test   %ebx,%ebx
  801227:	74 eb                	je     801214 <ipc_recv+0x50>
			*perm_store = 0;
  801229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80122f:	eb e3                	jmp    801214 <ipc_recv+0x50>

00801231 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801231:	f3 0f 1e fb          	endbr32 
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	57                   	push   %edi
  801239:	56                   	push   %esi
  80123a:	53                   	push   %ebx
  80123b:	83 ec 0c             	sub    $0xc,%esp
  80123e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801241:	8b 75 0c             	mov    0xc(%ebp),%esi
  801244:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  801247:	85 db                	test   %ebx,%ebx
  801249:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80124e:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801251:	ff 75 14             	pushl  0x14(%ebp)
  801254:	53                   	push   %ebx
  801255:	56                   	push   %esi
  801256:	57                   	push   %edi
  801257:	e8 51 fa ff ff       	call   800cad <sys_ipc_try_send>
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	85 c0                	test   %eax,%eax
  801261:	79 19                	jns    80127c <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  801263:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801266:	74 e9                	je     801251 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  801268:	83 ec 04             	sub    $0x4,%esp
  80126b:	68 00 29 80 00       	push   $0x802900
  801270:	6a 48                	push   $0x48
  801272:	68 22 29 80 00       	push   $0x802922
  801277:	e8 b3 0d 00 00       	call   80202f <_panic>
		}
	}
}
  80127c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127f:	5b                   	pop    %ebx
  801280:	5e                   	pop    %esi
  801281:	5f                   	pop    %edi
  801282:	5d                   	pop    %ebp
  801283:	c3                   	ret    

00801284 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801284:	f3 0f 1e fb          	endbr32 
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80128e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801293:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801296:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80129c:	8b 52 50             	mov    0x50(%edx),%edx
  80129f:	39 ca                	cmp    %ecx,%edx
  8012a1:	74 11                	je     8012b4 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8012a3:	83 c0 01             	add    $0x1,%eax
  8012a6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012ab:	75 e6                	jne    801293 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8012ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b2:	eb 0b                	jmp    8012bf <ipc_find_env+0x3b>
			return envs[i].env_id;
  8012b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012bc:	8b 40 48             	mov    0x48(%eax),%eax
}
  8012bf:	5d                   	pop    %ebp
  8012c0:	c3                   	ret    

008012c1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012c1:	f3 0f 1e fb          	endbr32 
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cb:	05 00 00 00 30       	add    $0x30000000,%eax
  8012d0:	c1 e8 0c             	shr    $0xc,%eax
}
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    

008012d5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012d5:	f3 0f 1e fb          	endbr32 
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  8012df:	ff 75 08             	pushl  0x8(%ebp)
  8012e2:	e8 da ff ff ff       	call   8012c1 <fd2num>
  8012e7:	83 c4 10             	add    $0x10,%esp
  8012ea:	c1 e0 0c             	shl    $0xc,%eax
  8012ed:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012f2:	c9                   	leave  
  8012f3:	c3                   	ret    

008012f4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012f4:	f3 0f 1e fb          	endbr32 
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801300:	89 c2                	mov    %eax,%edx
  801302:	c1 ea 16             	shr    $0x16,%edx
  801305:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80130c:	f6 c2 01             	test   $0x1,%dl
  80130f:	74 2d                	je     80133e <fd_alloc+0x4a>
  801311:	89 c2                	mov    %eax,%edx
  801313:	c1 ea 0c             	shr    $0xc,%edx
  801316:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80131d:	f6 c2 01             	test   $0x1,%dl
  801320:	74 1c                	je     80133e <fd_alloc+0x4a>
  801322:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801327:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80132c:	75 d2                	jne    801300 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80132e:	8b 45 08             	mov    0x8(%ebp),%eax
  801331:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801337:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80133c:	eb 0a                	jmp    801348 <fd_alloc+0x54>
			*fd_store = fd;
  80133e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801341:	89 01                	mov    %eax,(%ecx)
			return 0;
  801343:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    

0080134a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80134a:	f3 0f 1e fb          	endbr32 
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801354:	83 f8 1f             	cmp    $0x1f,%eax
  801357:	77 30                	ja     801389 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801359:	c1 e0 0c             	shl    $0xc,%eax
  80135c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801361:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801367:	f6 c2 01             	test   $0x1,%dl
  80136a:	74 24                	je     801390 <fd_lookup+0x46>
  80136c:	89 c2                	mov    %eax,%edx
  80136e:	c1 ea 0c             	shr    $0xc,%edx
  801371:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801378:	f6 c2 01             	test   $0x1,%dl
  80137b:	74 1a                	je     801397 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80137d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801380:	89 02                	mov    %eax,(%edx)
	return 0;
  801382:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801387:	5d                   	pop    %ebp
  801388:	c3                   	ret    
		return -E_INVAL;
  801389:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80138e:	eb f7                	jmp    801387 <fd_lookup+0x3d>
		return -E_INVAL;
  801390:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801395:	eb f0                	jmp    801387 <fd_lookup+0x3d>
  801397:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139c:	eb e9                	jmp    801387 <fd_lookup+0x3d>

0080139e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80139e:	f3 0f 1e fb          	endbr32 
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	83 ec 08             	sub    $0x8,%esp
  8013a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ab:	ba a8 29 80 00       	mov    $0x8029a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013b0:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8013b5:	39 08                	cmp    %ecx,(%eax)
  8013b7:	74 33                	je     8013ec <dev_lookup+0x4e>
  8013b9:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8013bc:	8b 02                	mov    (%edx),%eax
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	75 f3                	jne    8013b5 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013c2:	a1 04 40 80 00       	mov    0x804004,%eax
  8013c7:	8b 40 48             	mov    0x48(%eax),%eax
  8013ca:	83 ec 04             	sub    $0x4,%esp
  8013cd:	51                   	push   %ecx
  8013ce:	50                   	push   %eax
  8013cf:	68 2c 29 80 00       	push   $0x80292c
  8013d4:	e8 f4 ed ff ff       	call   8001cd <cprintf>
	*dev = 0;
  8013d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013ea:	c9                   	leave  
  8013eb:	c3                   	ret    
			*dev = devtab[i];
  8013ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ef:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f6:	eb f2                	jmp    8013ea <dev_lookup+0x4c>

008013f8 <fd_close>:
{
  8013f8:	f3 0f 1e fb          	endbr32 
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	57                   	push   %edi
  801400:	56                   	push   %esi
  801401:	53                   	push   %ebx
  801402:	83 ec 28             	sub    $0x28,%esp
  801405:	8b 75 08             	mov    0x8(%ebp),%esi
  801408:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80140b:	56                   	push   %esi
  80140c:	e8 b0 fe ff ff       	call   8012c1 <fd2num>
  801411:	83 c4 08             	add    $0x8,%esp
  801414:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801417:	52                   	push   %edx
  801418:	50                   	push   %eax
  801419:	e8 2c ff ff ff       	call   80134a <fd_lookup>
  80141e:	89 c3                	mov    %eax,%ebx
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	85 c0                	test   %eax,%eax
  801425:	78 05                	js     80142c <fd_close+0x34>
	    || fd != fd2)
  801427:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80142a:	74 16                	je     801442 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80142c:	89 f8                	mov    %edi,%eax
  80142e:	84 c0                	test   %al,%al
  801430:	b8 00 00 00 00       	mov    $0x0,%eax
  801435:	0f 44 d8             	cmove  %eax,%ebx
}
  801438:	89 d8                	mov    %ebx,%eax
  80143a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80143d:	5b                   	pop    %ebx
  80143e:	5e                   	pop    %esi
  80143f:	5f                   	pop    %edi
  801440:	5d                   	pop    %ebp
  801441:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801442:	83 ec 08             	sub    $0x8,%esp
  801445:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	ff 36                	pushl  (%esi)
  80144b:	e8 4e ff ff ff       	call   80139e <dev_lookup>
  801450:	89 c3                	mov    %eax,%ebx
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	85 c0                	test   %eax,%eax
  801457:	78 1a                	js     801473 <fd_close+0x7b>
		if (dev->dev_close)
  801459:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80145c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80145f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801464:	85 c0                	test   %eax,%eax
  801466:	74 0b                	je     801473 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801468:	83 ec 0c             	sub    $0xc,%esp
  80146b:	56                   	push   %esi
  80146c:	ff d0                	call   *%eax
  80146e:	89 c3                	mov    %eax,%ebx
  801470:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801473:	83 ec 08             	sub    $0x8,%esp
  801476:	56                   	push   %esi
  801477:	6a 00                	push   $0x0
  801479:	e8 93 f7 ff ff       	call   800c11 <sys_page_unmap>
	return r;
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	eb b5                	jmp    801438 <fd_close+0x40>

00801483 <close>:

int
close(int fdnum)
{
  801483:	f3 0f 1e fb          	endbr32 
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80148d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801490:	50                   	push   %eax
  801491:	ff 75 08             	pushl  0x8(%ebp)
  801494:	e8 b1 fe ff ff       	call   80134a <fd_lookup>
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	85 c0                	test   %eax,%eax
  80149e:	79 02                	jns    8014a2 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8014a0:	c9                   	leave  
  8014a1:	c3                   	ret    
		return fd_close(fd, 1);
  8014a2:	83 ec 08             	sub    $0x8,%esp
  8014a5:	6a 01                	push   $0x1
  8014a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8014aa:	e8 49 ff ff ff       	call   8013f8 <fd_close>
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	eb ec                	jmp    8014a0 <close+0x1d>

008014b4 <close_all>:

void
close_all(void)
{
  8014b4:	f3 0f 1e fb          	endbr32 
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	53                   	push   %ebx
  8014bc:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014bf:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014c4:	83 ec 0c             	sub    $0xc,%esp
  8014c7:	53                   	push   %ebx
  8014c8:	e8 b6 ff ff ff       	call   801483 <close>
	for (i = 0; i < MAXFD; i++)
  8014cd:	83 c3 01             	add    $0x1,%ebx
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	83 fb 20             	cmp    $0x20,%ebx
  8014d6:	75 ec                	jne    8014c4 <close_all+0x10>
}
  8014d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014db:	c9                   	leave  
  8014dc:	c3                   	ret    

008014dd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014dd:	f3 0f 1e fb          	endbr32 
  8014e1:	55                   	push   %ebp
  8014e2:	89 e5                	mov    %esp,%ebp
  8014e4:	57                   	push   %edi
  8014e5:	56                   	push   %esi
  8014e6:	53                   	push   %ebx
  8014e7:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014ea:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014ed:	50                   	push   %eax
  8014ee:	ff 75 08             	pushl  0x8(%ebp)
  8014f1:	e8 54 fe ff ff       	call   80134a <fd_lookup>
  8014f6:	89 c3                	mov    %eax,%ebx
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	0f 88 81 00 00 00    	js     801584 <dup+0xa7>
		return r;
	close(newfdnum);
  801503:	83 ec 0c             	sub    $0xc,%esp
  801506:	ff 75 0c             	pushl  0xc(%ebp)
  801509:	e8 75 ff ff ff       	call   801483 <close>

	newfd = INDEX2FD(newfdnum);
  80150e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801511:	c1 e6 0c             	shl    $0xc,%esi
  801514:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80151a:	83 c4 04             	add    $0x4,%esp
  80151d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801520:	e8 b0 fd ff ff       	call   8012d5 <fd2data>
  801525:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801527:	89 34 24             	mov    %esi,(%esp)
  80152a:	e8 a6 fd ff ff       	call   8012d5 <fd2data>
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801534:	89 d8                	mov    %ebx,%eax
  801536:	c1 e8 16             	shr    $0x16,%eax
  801539:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801540:	a8 01                	test   $0x1,%al
  801542:	74 11                	je     801555 <dup+0x78>
  801544:	89 d8                	mov    %ebx,%eax
  801546:	c1 e8 0c             	shr    $0xc,%eax
  801549:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801550:	f6 c2 01             	test   $0x1,%dl
  801553:	75 39                	jne    80158e <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801555:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801558:	89 d0                	mov    %edx,%eax
  80155a:	c1 e8 0c             	shr    $0xc,%eax
  80155d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801564:	83 ec 0c             	sub    $0xc,%esp
  801567:	25 07 0e 00 00       	and    $0xe07,%eax
  80156c:	50                   	push   %eax
  80156d:	56                   	push   %esi
  80156e:	6a 00                	push   $0x0
  801570:	52                   	push   %edx
  801571:	6a 00                	push   $0x0
  801573:	e8 6f f6 ff ff       	call   800be7 <sys_page_map>
  801578:	89 c3                	mov    %eax,%ebx
  80157a:	83 c4 20             	add    $0x20,%esp
  80157d:	85 c0                	test   %eax,%eax
  80157f:	78 31                	js     8015b2 <dup+0xd5>
		goto err;

	return newfdnum;
  801581:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801584:	89 d8                	mov    %ebx,%eax
  801586:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801589:	5b                   	pop    %ebx
  80158a:	5e                   	pop    %esi
  80158b:	5f                   	pop    %edi
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80158e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801595:	83 ec 0c             	sub    $0xc,%esp
  801598:	25 07 0e 00 00       	and    $0xe07,%eax
  80159d:	50                   	push   %eax
  80159e:	57                   	push   %edi
  80159f:	6a 00                	push   $0x0
  8015a1:	53                   	push   %ebx
  8015a2:	6a 00                	push   $0x0
  8015a4:	e8 3e f6 ff ff       	call   800be7 <sys_page_map>
  8015a9:	89 c3                	mov    %eax,%ebx
  8015ab:	83 c4 20             	add    $0x20,%esp
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	79 a3                	jns    801555 <dup+0x78>
	sys_page_unmap(0, newfd);
  8015b2:	83 ec 08             	sub    $0x8,%esp
  8015b5:	56                   	push   %esi
  8015b6:	6a 00                	push   $0x0
  8015b8:	e8 54 f6 ff ff       	call   800c11 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015bd:	83 c4 08             	add    $0x8,%esp
  8015c0:	57                   	push   %edi
  8015c1:	6a 00                	push   $0x0
  8015c3:	e8 49 f6 ff ff       	call   800c11 <sys_page_unmap>
	return r;
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	eb b7                	jmp    801584 <dup+0xa7>

008015cd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015cd:	f3 0f 1e fb          	endbr32 
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	53                   	push   %ebx
  8015d5:	83 ec 1c             	sub    $0x1c,%esp
  8015d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015de:	50                   	push   %eax
  8015df:	53                   	push   %ebx
  8015e0:	e8 65 fd ff ff       	call   80134a <fd_lookup>
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	78 3f                	js     80162b <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ec:	83 ec 08             	sub    $0x8,%esp
  8015ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f2:	50                   	push   %eax
  8015f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f6:	ff 30                	pushl  (%eax)
  8015f8:	e8 a1 fd ff ff       	call   80139e <dev_lookup>
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	85 c0                	test   %eax,%eax
  801602:	78 27                	js     80162b <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801604:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801607:	8b 42 08             	mov    0x8(%edx),%eax
  80160a:	83 e0 03             	and    $0x3,%eax
  80160d:	83 f8 01             	cmp    $0x1,%eax
  801610:	74 1e                	je     801630 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801612:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801615:	8b 40 08             	mov    0x8(%eax),%eax
  801618:	85 c0                	test   %eax,%eax
  80161a:	74 35                	je     801651 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80161c:	83 ec 04             	sub    $0x4,%esp
  80161f:	ff 75 10             	pushl  0x10(%ebp)
  801622:	ff 75 0c             	pushl  0xc(%ebp)
  801625:	52                   	push   %edx
  801626:	ff d0                	call   *%eax
  801628:	83 c4 10             	add    $0x10,%esp
}
  80162b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162e:	c9                   	leave  
  80162f:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801630:	a1 04 40 80 00       	mov    0x804004,%eax
  801635:	8b 40 48             	mov    0x48(%eax),%eax
  801638:	83 ec 04             	sub    $0x4,%esp
  80163b:	53                   	push   %ebx
  80163c:	50                   	push   %eax
  80163d:	68 6d 29 80 00       	push   $0x80296d
  801642:	e8 86 eb ff ff       	call   8001cd <cprintf>
		return -E_INVAL;
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80164f:	eb da                	jmp    80162b <read+0x5e>
		return -E_NOT_SUPP;
  801651:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801656:	eb d3                	jmp    80162b <read+0x5e>

00801658 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801658:	f3 0f 1e fb          	endbr32 
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	57                   	push   %edi
  801660:	56                   	push   %esi
  801661:	53                   	push   %ebx
  801662:	83 ec 0c             	sub    $0xc,%esp
  801665:	8b 7d 08             	mov    0x8(%ebp),%edi
  801668:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80166b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801670:	eb 02                	jmp    801674 <readn+0x1c>
  801672:	01 c3                	add    %eax,%ebx
  801674:	39 f3                	cmp    %esi,%ebx
  801676:	73 21                	jae    801699 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801678:	83 ec 04             	sub    $0x4,%esp
  80167b:	89 f0                	mov    %esi,%eax
  80167d:	29 d8                	sub    %ebx,%eax
  80167f:	50                   	push   %eax
  801680:	89 d8                	mov    %ebx,%eax
  801682:	03 45 0c             	add    0xc(%ebp),%eax
  801685:	50                   	push   %eax
  801686:	57                   	push   %edi
  801687:	e8 41 ff ff ff       	call   8015cd <read>
		if (m < 0)
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	85 c0                	test   %eax,%eax
  801691:	78 04                	js     801697 <readn+0x3f>
			return m;
		if (m == 0)
  801693:	75 dd                	jne    801672 <readn+0x1a>
  801695:	eb 02                	jmp    801699 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801697:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801699:	89 d8                	mov    %ebx,%eax
  80169b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80169e:	5b                   	pop    %ebx
  80169f:	5e                   	pop    %esi
  8016a0:	5f                   	pop    %edi
  8016a1:	5d                   	pop    %ebp
  8016a2:	c3                   	ret    

008016a3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016a3:	f3 0f 1e fb          	endbr32 
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	53                   	push   %ebx
  8016ab:	83 ec 1c             	sub    $0x1c,%esp
  8016ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b4:	50                   	push   %eax
  8016b5:	53                   	push   %ebx
  8016b6:	e8 8f fc ff ff       	call   80134a <fd_lookup>
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	78 3a                	js     8016fc <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c2:	83 ec 08             	sub    $0x8,%esp
  8016c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c8:	50                   	push   %eax
  8016c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cc:	ff 30                	pushl  (%eax)
  8016ce:	e8 cb fc ff ff       	call   80139e <dev_lookup>
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 22                	js     8016fc <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e1:	74 1e                	je     801701 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e6:	8b 52 0c             	mov    0xc(%edx),%edx
  8016e9:	85 d2                	test   %edx,%edx
  8016eb:	74 35                	je     801722 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016ed:	83 ec 04             	sub    $0x4,%esp
  8016f0:	ff 75 10             	pushl  0x10(%ebp)
  8016f3:	ff 75 0c             	pushl  0xc(%ebp)
  8016f6:	50                   	push   %eax
  8016f7:	ff d2                	call   *%edx
  8016f9:	83 c4 10             	add    $0x10,%esp
}
  8016fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ff:	c9                   	leave  
  801700:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801701:	a1 04 40 80 00       	mov    0x804004,%eax
  801706:	8b 40 48             	mov    0x48(%eax),%eax
  801709:	83 ec 04             	sub    $0x4,%esp
  80170c:	53                   	push   %ebx
  80170d:	50                   	push   %eax
  80170e:	68 89 29 80 00       	push   $0x802989
  801713:	e8 b5 ea ff ff       	call   8001cd <cprintf>
		return -E_INVAL;
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801720:	eb da                	jmp    8016fc <write+0x59>
		return -E_NOT_SUPP;
  801722:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801727:	eb d3                	jmp    8016fc <write+0x59>

00801729 <seek>:

int
seek(int fdnum, off_t offset)
{
  801729:	f3 0f 1e fb          	endbr32 
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801733:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801736:	50                   	push   %eax
  801737:	ff 75 08             	pushl  0x8(%ebp)
  80173a:	e8 0b fc ff ff       	call   80134a <fd_lookup>
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	85 c0                	test   %eax,%eax
  801744:	78 0e                	js     801754 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801746:	8b 55 0c             	mov    0xc(%ebp),%edx
  801749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80174f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801754:	c9                   	leave  
  801755:	c3                   	ret    

00801756 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801756:	f3 0f 1e fb          	endbr32 
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	53                   	push   %ebx
  80175e:	83 ec 1c             	sub    $0x1c,%esp
  801761:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801764:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801767:	50                   	push   %eax
  801768:	53                   	push   %ebx
  801769:	e8 dc fb ff ff       	call   80134a <fd_lookup>
  80176e:	83 c4 10             	add    $0x10,%esp
  801771:	85 c0                	test   %eax,%eax
  801773:	78 37                	js     8017ac <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801775:	83 ec 08             	sub    $0x8,%esp
  801778:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177b:	50                   	push   %eax
  80177c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177f:	ff 30                	pushl  (%eax)
  801781:	e8 18 fc ff ff       	call   80139e <dev_lookup>
  801786:	83 c4 10             	add    $0x10,%esp
  801789:	85 c0                	test   %eax,%eax
  80178b:	78 1f                	js     8017ac <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80178d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801790:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801794:	74 1b                	je     8017b1 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801796:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801799:	8b 52 18             	mov    0x18(%edx),%edx
  80179c:	85 d2                	test   %edx,%edx
  80179e:	74 32                	je     8017d2 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017a0:	83 ec 08             	sub    $0x8,%esp
  8017a3:	ff 75 0c             	pushl  0xc(%ebp)
  8017a6:	50                   	push   %eax
  8017a7:	ff d2                	call   *%edx
  8017a9:	83 c4 10             	add    $0x10,%esp
}
  8017ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017af:	c9                   	leave  
  8017b0:	c3                   	ret    
			thisenv->env_id, fdnum);
  8017b1:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017b6:	8b 40 48             	mov    0x48(%eax),%eax
  8017b9:	83 ec 04             	sub    $0x4,%esp
  8017bc:	53                   	push   %ebx
  8017bd:	50                   	push   %eax
  8017be:	68 4c 29 80 00       	push   $0x80294c
  8017c3:	e8 05 ea ff ff       	call   8001cd <cprintf>
		return -E_INVAL;
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017d0:	eb da                	jmp    8017ac <ftruncate+0x56>
		return -E_NOT_SUPP;
  8017d2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017d7:	eb d3                	jmp    8017ac <ftruncate+0x56>

008017d9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017d9:	f3 0f 1e fb          	endbr32 
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	53                   	push   %ebx
  8017e1:	83 ec 1c             	sub    $0x1c,%esp
  8017e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ea:	50                   	push   %eax
  8017eb:	ff 75 08             	pushl  0x8(%ebp)
  8017ee:	e8 57 fb ff ff       	call   80134a <fd_lookup>
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	78 4b                	js     801845 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017fa:	83 ec 08             	sub    $0x8,%esp
  8017fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801800:	50                   	push   %eax
  801801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801804:	ff 30                	pushl  (%eax)
  801806:	e8 93 fb ff ff       	call   80139e <dev_lookup>
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 33                	js     801845 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801812:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801815:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801819:	74 2f                	je     80184a <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80181b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80181e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801825:	00 00 00 
	stat->st_isdir = 0;
  801828:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80182f:	00 00 00 
	stat->st_dev = dev;
  801832:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801838:	83 ec 08             	sub    $0x8,%esp
  80183b:	53                   	push   %ebx
  80183c:	ff 75 f0             	pushl  -0x10(%ebp)
  80183f:	ff 50 14             	call   *0x14(%eax)
  801842:	83 c4 10             	add    $0x10,%esp
}
  801845:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801848:	c9                   	leave  
  801849:	c3                   	ret    
		return -E_NOT_SUPP;
  80184a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80184f:	eb f4                	jmp    801845 <fstat+0x6c>

00801851 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801851:	f3 0f 1e fb          	endbr32 
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	56                   	push   %esi
  801859:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80185a:	83 ec 08             	sub    $0x8,%esp
  80185d:	6a 00                	push   $0x0
  80185f:	ff 75 08             	pushl  0x8(%ebp)
  801862:	e8 20 02 00 00       	call   801a87 <open>
  801867:	89 c3                	mov    %eax,%ebx
  801869:	83 c4 10             	add    $0x10,%esp
  80186c:	85 c0                	test   %eax,%eax
  80186e:	78 1b                	js     80188b <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801870:	83 ec 08             	sub    $0x8,%esp
  801873:	ff 75 0c             	pushl  0xc(%ebp)
  801876:	50                   	push   %eax
  801877:	e8 5d ff ff ff       	call   8017d9 <fstat>
  80187c:	89 c6                	mov    %eax,%esi
	close(fd);
  80187e:	89 1c 24             	mov    %ebx,(%esp)
  801881:	e8 fd fb ff ff       	call   801483 <close>
	return r;
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	89 f3                	mov    %esi,%ebx
}
  80188b:	89 d8                	mov    %ebx,%eax
  80188d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801890:	5b                   	pop    %ebx
  801891:	5e                   	pop    %esi
  801892:	5d                   	pop    %ebp
  801893:	c3                   	ret    

00801894 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	56                   	push   %esi
  801898:	53                   	push   %ebx
  801899:	89 c6                	mov    %eax,%esi
  80189b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80189d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018a4:	74 27                	je     8018cd <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018a6:	6a 07                	push   $0x7
  8018a8:	68 00 50 80 00       	push   $0x805000
  8018ad:	56                   	push   %esi
  8018ae:	ff 35 00 40 80 00    	pushl  0x804000
  8018b4:	e8 78 f9 ff ff       	call   801231 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018b9:	83 c4 0c             	add    $0xc,%esp
  8018bc:	6a 00                	push   $0x0
  8018be:	53                   	push   %ebx
  8018bf:	6a 00                	push   $0x0
  8018c1:	e8 fe f8 ff ff       	call   8011c4 <ipc_recv>
}
  8018c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c9:	5b                   	pop    %ebx
  8018ca:	5e                   	pop    %esi
  8018cb:	5d                   	pop    %ebp
  8018cc:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018cd:	83 ec 0c             	sub    $0xc,%esp
  8018d0:	6a 01                	push   $0x1
  8018d2:	e8 ad f9 ff ff       	call   801284 <ipc_find_env>
  8018d7:	a3 00 40 80 00       	mov    %eax,0x804000
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	eb c5                	jmp    8018a6 <fsipc+0x12>

008018e1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018e1:	f3 0f 1e fb          	endbr32 
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801903:	b8 02 00 00 00       	mov    $0x2,%eax
  801908:	e8 87 ff ff ff       	call   801894 <fsipc>
}
  80190d:	c9                   	leave  
  80190e:	c3                   	ret    

0080190f <devfile_flush>:
{
  80190f:	f3 0f 1e fb          	endbr32 
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801919:	8b 45 08             	mov    0x8(%ebp),%eax
  80191c:	8b 40 0c             	mov    0xc(%eax),%eax
  80191f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801924:	ba 00 00 00 00       	mov    $0x0,%edx
  801929:	b8 06 00 00 00       	mov    $0x6,%eax
  80192e:	e8 61 ff ff ff       	call   801894 <fsipc>
}
  801933:	c9                   	leave  
  801934:	c3                   	ret    

00801935 <devfile_stat>:
{
  801935:	f3 0f 1e fb          	endbr32 
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	53                   	push   %ebx
  80193d:	83 ec 04             	sub    $0x4,%esp
  801940:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801943:	8b 45 08             	mov    0x8(%ebp),%eax
  801946:	8b 40 0c             	mov    0xc(%eax),%eax
  801949:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80194e:	ba 00 00 00 00       	mov    $0x0,%edx
  801953:	b8 05 00 00 00       	mov    $0x5,%eax
  801958:	e8 37 ff ff ff       	call   801894 <fsipc>
  80195d:	85 c0                	test   %eax,%eax
  80195f:	78 2c                	js     80198d <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801961:	83 ec 08             	sub    $0x8,%esp
  801964:	68 00 50 80 00       	push   $0x805000
  801969:	53                   	push   %ebx
  80196a:	e8 c8 ed ff ff       	call   800737 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80196f:	a1 80 50 80 00       	mov    0x805080,%eax
  801974:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80197a:	a1 84 50 80 00       	mov    0x805084,%eax
  80197f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80198d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <devfile_write>:
{
  801992:	f3 0f 1e fb          	endbr32 
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	57                   	push   %edi
  80199a:	56                   	push   %esi
  80199b:	53                   	push   %ebx
  80199c:	83 ec 0c             	sub    $0xc,%esp
  80199f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ab:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  8019b0:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8019b5:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  8019ba:	85 db                	test   %ebx,%ebx
  8019bc:	74 3b                	je     8019f9 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8019be:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8019c4:	89 f8                	mov    %edi,%eax
  8019c6:	0f 46 c3             	cmovbe %ebx,%eax
  8019c9:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  8019ce:	83 ec 04             	sub    $0x4,%esp
  8019d1:	50                   	push   %eax
  8019d2:	56                   	push   %esi
  8019d3:	68 08 50 80 00       	push   $0x805008
  8019d8:	e8 12 ef ff ff       	call   8008ef <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8019dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e2:	b8 04 00 00 00       	mov    $0x4,%eax
  8019e7:	e8 a8 fe ff ff       	call   801894 <fsipc>
  8019ec:	83 c4 10             	add    $0x10,%esp
  8019ef:	85 c0                	test   %eax,%eax
  8019f1:	78 06                	js     8019f9 <devfile_write+0x67>
		buf_aux += r;
  8019f3:	01 c6                	add    %eax,%esi
		n -= r;
  8019f5:	29 c3                	sub    %eax,%ebx
  8019f7:	eb c1                	jmp    8019ba <devfile_write+0x28>
}
  8019f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019fc:	5b                   	pop    %ebx
  8019fd:	5e                   	pop    %esi
  8019fe:	5f                   	pop    %edi
  8019ff:	5d                   	pop    %ebp
  801a00:	c3                   	ret    

00801a01 <devfile_read>:
{
  801a01:	f3 0f 1e fb          	endbr32 
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	56                   	push   %esi
  801a09:	53                   	push   %ebx
  801a0a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a10:	8b 40 0c             	mov    0xc(%eax),%eax
  801a13:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a18:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a23:	b8 03 00 00 00       	mov    $0x3,%eax
  801a28:	e8 67 fe ff ff       	call   801894 <fsipc>
  801a2d:	89 c3                	mov    %eax,%ebx
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	78 1f                	js     801a52 <devfile_read+0x51>
	assert(r <= n);
  801a33:	39 f0                	cmp    %esi,%eax
  801a35:	77 24                	ja     801a5b <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801a37:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a3c:	7f 33                	jg     801a71 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a3e:	83 ec 04             	sub    $0x4,%esp
  801a41:	50                   	push   %eax
  801a42:	68 00 50 80 00       	push   $0x805000
  801a47:	ff 75 0c             	pushl  0xc(%ebp)
  801a4a:	e8 a0 ee ff ff       	call   8008ef <memmove>
	return r;
  801a4f:	83 c4 10             	add    $0x10,%esp
}
  801a52:	89 d8                	mov    %ebx,%eax
  801a54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a57:	5b                   	pop    %ebx
  801a58:	5e                   	pop    %esi
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    
	assert(r <= n);
  801a5b:	68 b8 29 80 00       	push   $0x8029b8
  801a60:	68 bf 29 80 00       	push   $0x8029bf
  801a65:	6a 7c                	push   $0x7c
  801a67:	68 d4 29 80 00       	push   $0x8029d4
  801a6c:	e8 be 05 00 00       	call   80202f <_panic>
	assert(r <= PGSIZE);
  801a71:	68 df 29 80 00       	push   $0x8029df
  801a76:	68 bf 29 80 00       	push   $0x8029bf
  801a7b:	6a 7d                	push   $0x7d
  801a7d:	68 d4 29 80 00       	push   $0x8029d4
  801a82:	e8 a8 05 00 00       	call   80202f <_panic>

00801a87 <open>:
{
  801a87:	f3 0f 1e fb          	endbr32 
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	56                   	push   %esi
  801a8f:	53                   	push   %ebx
  801a90:	83 ec 1c             	sub    $0x1c,%esp
  801a93:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801a96:	56                   	push   %esi
  801a97:	e8 58 ec ff ff       	call   8006f4 <strlen>
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801aa4:	7f 6c                	jg     801b12 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801aa6:	83 ec 0c             	sub    $0xc,%esp
  801aa9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aac:	50                   	push   %eax
  801aad:	e8 42 f8 ff ff       	call   8012f4 <fd_alloc>
  801ab2:	89 c3                	mov    %eax,%ebx
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	78 3c                	js     801af7 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801abb:	83 ec 08             	sub    $0x8,%esp
  801abe:	56                   	push   %esi
  801abf:	68 00 50 80 00       	push   $0x805000
  801ac4:	e8 6e ec ff ff       	call   800737 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acc:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ad1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ad4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ad9:	e8 b6 fd ff ff       	call   801894 <fsipc>
  801ade:	89 c3                	mov    %eax,%ebx
  801ae0:	83 c4 10             	add    $0x10,%esp
  801ae3:	85 c0                	test   %eax,%eax
  801ae5:	78 19                	js     801b00 <open+0x79>
	return fd2num(fd);
  801ae7:	83 ec 0c             	sub    $0xc,%esp
  801aea:	ff 75 f4             	pushl  -0xc(%ebp)
  801aed:	e8 cf f7 ff ff       	call   8012c1 <fd2num>
  801af2:	89 c3                	mov    %eax,%ebx
  801af4:	83 c4 10             	add    $0x10,%esp
}
  801af7:	89 d8                	mov    %ebx,%eax
  801af9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801afc:	5b                   	pop    %ebx
  801afd:	5e                   	pop    %esi
  801afe:	5d                   	pop    %ebp
  801aff:	c3                   	ret    
		fd_close(fd, 0);
  801b00:	83 ec 08             	sub    $0x8,%esp
  801b03:	6a 00                	push   $0x0
  801b05:	ff 75 f4             	pushl  -0xc(%ebp)
  801b08:	e8 eb f8 ff ff       	call   8013f8 <fd_close>
		return r;
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	eb e5                	jmp    801af7 <open+0x70>
		return -E_BAD_PATH;
  801b12:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801b17:	eb de                	jmp    801af7 <open+0x70>

00801b19 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b19:	f3 0f 1e fb          	endbr32 
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b23:	ba 00 00 00 00       	mov    $0x0,%edx
  801b28:	b8 08 00 00 00       	mov    $0x8,%eax
  801b2d:	e8 62 fd ff ff       	call   801894 <fsipc>
}
  801b32:	c9                   	leave  
  801b33:	c3                   	ret    

00801b34 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b34:	f3 0f 1e fb          	endbr32 
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	56                   	push   %esi
  801b3c:	53                   	push   %ebx
  801b3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b40:	83 ec 0c             	sub    $0xc,%esp
  801b43:	ff 75 08             	pushl  0x8(%ebp)
  801b46:	e8 8a f7 ff ff       	call   8012d5 <fd2data>
  801b4b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b4d:	83 c4 08             	add    $0x8,%esp
  801b50:	68 eb 29 80 00       	push   $0x8029eb
  801b55:	53                   	push   %ebx
  801b56:	e8 dc eb ff ff       	call   800737 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b5b:	8b 46 04             	mov    0x4(%esi),%eax
  801b5e:	2b 06                	sub    (%esi),%eax
  801b60:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b66:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b6d:	00 00 00 
	stat->st_dev = &devpipe;
  801b70:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b77:	30 80 00 
	return 0;
}
  801b7a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b82:	5b                   	pop    %ebx
  801b83:	5e                   	pop    %esi
  801b84:	5d                   	pop    %ebp
  801b85:	c3                   	ret    

00801b86 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b86:	f3 0f 1e fb          	endbr32 
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	53                   	push   %ebx
  801b8e:	83 ec 0c             	sub    $0xc,%esp
  801b91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b94:	53                   	push   %ebx
  801b95:	6a 00                	push   $0x0
  801b97:	e8 75 f0 ff ff       	call   800c11 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b9c:	89 1c 24             	mov    %ebx,(%esp)
  801b9f:	e8 31 f7 ff ff       	call   8012d5 <fd2data>
  801ba4:	83 c4 08             	add    $0x8,%esp
  801ba7:	50                   	push   %eax
  801ba8:	6a 00                	push   $0x0
  801baa:	e8 62 f0 ff ff       	call   800c11 <sys_page_unmap>
}
  801baf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb2:	c9                   	leave  
  801bb3:	c3                   	ret    

00801bb4 <_pipeisclosed>:
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	57                   	push   %edi
  801bb8:	56                   	push   %esi
  801bb9:	53                   	push   %ebx
  801bba:	83 ec 1c             	sub    $0x1c,%esp
  801bbd:	89 c7                	mov    %eax,%edi
  801bbf:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801bc1:	a1 04 40 80 00       	mov    0x804004,%eax
  801bc6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bc9:	83 ec 0c             	sub    $0xc,%esp
  801bcc:	57                   	push   %edi
  801bcd:	e8 40 05 00 00       	call   802112 <pageref>
  801bd2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bd5:	89 34 24             	mov    %esi,(%esp)
  801bd8:	e8 35 05 00 00       	call   802112 <pageref>
		nn = thisenv->env_runs;
  801bdd:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801be3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	39 cb                	cmp    %ecx,%ebx
  801beb:	74 1b                	je     801c08 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801bed:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bf0:	75 cf                	jne    801bc1 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bf2:	8b 42 58             	mov    0x58(%edx),%eax
  801bf5:	6a 01                	push   $0x1
  801bf7:	50                   	push   %eax
  801bf8:	53                   	push   %ebx
  801bf9:	68 f2 29 80 00       	push   $0x8029f2
  801bfe:	e8 ca e5 ff ff       	call   8001cd <cprintf>
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	eb b9                	jmp    801bc1 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c08:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c0b:	0f 94 c0             	sete   %al
  801c0e:	0f b6 c0             	movzbl %al,%eax
}
  801c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c14:	5b                   	pop    %ebx
  801c15:	5e                   	pop    %esi
  801c16:	5f                   	pop    %edi
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    

00801c19 <devpipe_write>:
{
  801c19:	f3 0f 1e fb          	endbr32 
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	57                   	push   %edi
  801c21:	56                   	push   %esi
  801c22:	53                   	push   %ebx
  801c23:	83 ec 28             	sub    $0x28,%esp
  801c26:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c29:	56                   	push   %esi
  801c2a:	e8 a6 f6 ff ff       	call   8012d5 <fd2data>
  801c2f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	bf 00 00 00 00       	mov    $0x0,%edi
  801c39:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c3c:	74 4f                	je     801c8d <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c3e:	8b 43 04             	mov    0x4(%ebx),%eax
  801c41:	8b 0b                	mov    (%ebx),%ecx
  801c43:	8d 51 20             	lea    0x20(%ecx),%edx
  801c46:	39 d0                	cmp    %edx,%eax
  801c48:	72 14                	jb     801c5e <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801c4a:	89 da                	mov    %ebx,%edx
  801c4c:	89 f0                	mov    %esi,%eax
  801c4e:	e8 61 ff ff ff       	call   801bb4 <_pipeisclosed>
  801c53:	85 c0                	test   %eax,%eax
  801c55:	75 3b                	jne    801c92 <devpipe_write+0x79>
			sys_yield();
  801c57:	e8 38 ef ff ff       	call   800b94 <sys_yield>
  801c5c:	eb e0                	jmp    801c3e <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c61:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c65:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c68:	89 c2                	mov    %eax,%edx
  801c6a:	c1 fa 1f             	sar    $0x1f,%edx
  801c6d:	89 d1                	mov    %edx,%ecx
  801c6f:	c1 e9 1b             	shr    $0x1b,%ecx
  801c72:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c75:	83 e2 1f             	and    $0x1f,%edx
  801c78:	29 ca                	sub    %ecx,%edx
  801c7a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c7e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c82:	83 c0 01             	add    $0x1,%eax
  801c85:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c88:	83 c7 01             	add    $0x1,%edi
  801c8b:	eb ac                	jmp    801c39 <devpipe_write+0x20>
	return i;
  801c8d:	8b 45 10             	mov    0x10(%ebp),%eax
  801c90:	eb 05                	jmp    801c97 <devpipe_write+0x7e>
				return 0;
  801c92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c9a:	5b                   	pop    %ebx
  801c9b:	5e                   	pop    %esi
  801c9c:	5f                   	pop    %edi
  801c9d:	5d                   	pop    %ebp
  801c9e:	c3                   	ret    

00801c9f <devpipe_read>:
{
  801c9f:	f3 0f 1e fb          	endbr32 
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	57                   	push   %edi
  801ca7:	56                   	push   %esi
  801ca8:	53                   	push   %ebx
  801ca9:	83 ec 18             	sub    $0x18,%esp
  801cac:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801caf:	57                   	push   %edi
  801cb0:	e8 20 f6 ff ff       	call   8012d5 <fd2data>
  801cb5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cb7:	83 c4 10             	add    $0x10,%esp
  801cba:	be 00 00 00 00       	mov    $0x0,%esi
  801cbf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cc2:	75 14                	jne    801cd8 <devpipe_read+0x39>
	return i;
  801cc4:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc7:	eb 02                	jmp    801ccb <devpipe_read+0x2c>
				return i;
  801cc9:	89 f0                	mov    %esi,%eax
}
  801ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cce:	5b                   	pop    %ebx
  801ccf:	5e                   	pop    %esi
  801cd0:	5f                   	pop    %edi
  801cd1:	5d                   	pop    %ebp
  801cd2:	c3                   	ret    
			sys_yield();
  801cd3:	e8 bc ee ff ff       	call   800b94 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801cd8:	8b 03                	mov    (%ebx),%eax
  801cda:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cdd:	75 18                	jne    801cf7 <devpipe_read+0x58>
			if (i > 0)
  801cdf:	85 f6                	test   %esi,%esi
  801ce1:	75 e6                	jne    801cc9 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801ce3:	89 da                	mov    %ebx,%edx
  801ce5:	89 f8                	mov    %edi,%eax
  801ce7:	e8 c8 fe ff ff       	call   801bb4 <_pipeisclosed>
  801cec:	85 c0                	test   %eax,%eax
  801cee:	74 e3                	je     801cd3 <devpipe_read+0x34>
				return 0;
  801cf0:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf5:	eb d4                	jmp    801ccb <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cf7:	99                   	cltd   
  801cf8:	c1 ea 1b             	shr    $0x1b,%edx
  801cfb:	01 d0                	add    %edx,%eax
  801cfd:	83 e0 1f             	and    $0x1f,%eax
  801d00:	29 d0                	sub    %edx,%eax
  801d02:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d0a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d0d:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d10:	83 c6 01             	add    $0x1,%esi
  801d13:	eb aa                	jmp    801cbf <devpipe_read+0x20>

00801d15 <pipe>:
{
  801d15:	f3 0f 1e fb          	endbr32 
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	56                   	push   %esi
  801d1d:	53                   	push   %ebx
  801d1e:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d24:	50                   	push   %eax
  801d25:	e8 ca f5 ff ff       	call   8012f4 <fd_alloc>
  801d2a:	89 c3                	mov    %eax,%ebx
  801d2c:	83 c4 10             	add    $0x10,%esp
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	0f 88 23 01 00 00    	js     801e5a <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d37:	83 ec 04             	sub    $0x4,%esp
  801d3a:	68 07 04 00 00       	push   $0x407
  801d3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d42:	6a 00                	push   $0x0
  801d44:	e8 76 ee ff ff       	call   800bbf <sys_page_alloc>
  801d49:	89 c3                	mov    %eax,%ebx
  801d4b:	83 c4 10             	add    $0x10,%esp
  801d4e:	85 c0                	test   %eax,%eax
  801d50:	0f 88 04 01 00 00    	js     801e5a <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801d56:	83 ec 0c             	sub    $0xc,%esp
  801d59:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d5c:	50                   	push   %eax
  801d5d:	e8 92 f5 ff ff       	call   8012f4 <fd_alloc>
  801d62:	89 c3                	mov    %eax,%ebx
  801d64:	83 c4 10             	add    $0x10,%esp
  801d67:	85 c0                	test   %eax,%eax
  801d69:	0f 88 db 00 00 00    	js     801e4a <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d6f:	83 ec 04             	sub    $0x4,%esp
  801d72:	68 07 04 00 00       	push   $0x407
  801d77:	ff 75 f0             	pushl  -0x10(%ebp)
  801d7a:	6a 00                	push   $0x0
  801d7c:	e8 3e ee ff ff       	call   800bbf <sys_page_alloc>
  801d81:	89 c3                	mov    %eax,%ebx
  801d83:	83 c4 10             	add    $0x10,%esp
  801d86:	85 c0                	test   %eax,%eax
  801d88:	0f 88 bc 00 00 00    	js     801e4a <pipe+0x135>
	va = fd2data(fd0);
  801d8e:	83 ec 0c             	sub    $0xc,%esp
  801d91:	ff 75 f4             	pushl  -0xc(%ebp)
  801d94:	e8 3c f5 ff ff       	call   8012d5 <fd2data>
  801d99:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d9b:	83 c4 0c             	add    $0xc,%esp
  801d9e:	68 07 04 00 00       	push   $0x407
  801da3:	50                   	push   %eax
  801da4:	6a 00                	push   $0x0
  801da6:	e8 14 ee ff ff       	call   800bbf <sys_page_alloc>
  801dab:	89 c3                	mov    %eax,%ebx
  801dad:	83 c4 10             	add    $0x10,%esp
  801db0:	85 c0                	test   %eax,%eax
  801db2:	0f 88 82 00 00 00    	js     801e3a <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db8:	83 ec 0c             	sub    $0xc,%esp
  801dbb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dbe:	e8 12 f5 ff ff       	call   8012d5 <fd2data>
  801dc3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dca:	50                   	push   %eax
  801dcb:	6a 00                	push   $0x0
  801dcd:	56                   	push   %esi
  801dce:	6a 00                	push   $0x0
  801dd0:	e8 12 ee ff ff       	call   800be7 <sys_page_map>
  801dd5:	89 c3                	mov    %eax,%ebx
  801dd7:	83 c4 20             	add    $0x20,%esp
  801dda:	85 c0                	test   %eax,%eax
  801ddc:	78 4e                	js     801e2c <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801dde:	a1 20 30 80 00       	mov    0x803020,%eax
  801de3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801de6:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801de8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801deb:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801df2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801df5:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801df7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dfa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e01:	83 ec 0c             	sub    $0xc,%esp
  801e04:	ff 75 f4             	pushl  -0xc(%ebp)
  801e07:	e8 b5 f4 ff ff       	call   8012c1 <fd2num>
  801e0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e0f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e11:	83 c4 04             	add    $0x4,%esp
  801e14:	ff 75 f0             	pushl  -0x10(%ebp)
  801e17:	e8 a5 f4 ff ff       	call   8012c1 <fd2num>
  801e1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e1f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e22:	83 c4 10             	add    $0x10,%esp
  801e25:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e2a:	eb 2e                	jmp    801e5a <pipe+0x145>
	sys_page_unmap(0, va);
  801e2c:	83 ec 08             	sub    $0x8,%esp
  801e2f:	56                   	push   %esi
  801e30:	6a 00                	push   $0x0
  801e32:	e8 da ed ff ff       	call   800c11 <sys_page_unmap>
  801e37:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e3a:	83 ec 08             	sub    $0x8,%esp
  801e3d:	ff 75 f0             	pushl  -0x10(%ebp)
  801e40:	6a 00                	push   $0x0
  801e42:	e8 ca ed ff ff       	call   800c11 <sys_page_unmap>
  801e47:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e4a:	83 ec 08             	sub    $0x8,%esp
  801e4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e50:	6a 00                	push   $0x0
  801e52:	e8 ba ed ff ff       	call   800c11 <sys_page_unmap>
  801e57:	83 c4 10             	add    $0x10,%esp
}
  801e5a:	89 d8                	mov    %ebx,%eax
  801e5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e5f:	5b                   	pop    %ebx
  801e60:	5e                   	pop    %esi
  801e61:	5d                   	pop    %ebp
  801e62:	c3                   	ret    

00801e63 <pipeisclosed>:
{
  801e63:	f3 0f 1e fb          	endbr32 
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e70:	50                   	push   %eax
  801e71:	ff 75 08             	pushl  0x8(%ebp)
  801e74:	e8 d1 f4 ff ff       	call   80134a <fd_lookup>
  801e79:	83 c4 10             	add    $0x10,%esp
  801e7c:	85 c0                	test   %eax,%eax
  801e7e:	78 18                	js     801e98 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801e80:	83 ec 0c             	sub    $0xc,%esp
  801e83:	ff 75 f4             	pushl  -0xc(%ebp)
  801e86:	e8 4a f4 ff ff       	call   8012d5 <fd2data>
  801e8b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e90:	e8 1f fd ff ff       	call   801bb4 <_pipeisclosed>
  801e95:	83 c4 10             	add    $0x10,%esp
}
  801e98:	c9                   	leave  
  801e99:	c3                   	ret    

00801e9a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e9a:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801e9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea3:	c3                   	ret    

00801ea4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ea4:	f3 0f 1e fb          	endbr32 
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eae:	68 0a 2a 80 00       	push   $0x802a0a
  801eb3:	ff 75 0c             	pushl  0xc(%ebp)
  801eb6:	e8 7c e8 ff ff       	call   800737 <strcpy>
	return 0;
}
  801ebb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec0:	c9                   	leave  
  801ec1:	c3                   	ret    

00801ec2 <devcons_write>:
{
  801ec2:	f3 0f 1e fb          	endbr32 
  801ec6:	55                   	push   %ebp
  801ec7:	89 e5                	mov    %esp,%ebp
  801ec9:	57                   	push   %edi
  801eca:	56                   	push   %esi
  801ecb:	53                   	push   %ebx
  801ecc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801ed2:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801ed7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801edd:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ee0:	73 31                	jae    801f13 <devcons_write+0x51>
		m = n - tot;
  801ee2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ee5:	29 f3                	sub    %esi,%ebx
  801ee7:	83 fb 7f             	cmp    $0x7f,%ebx
  801eea:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801eef:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ef2:	83 ec 04             	sub    $0x4,%esp
  801ef5:	53                   	push   %ebx
  801ef6:	89 f0                	mov    %esi,%eax
  801ef8:	03 45 0c             	add    0xc(%ebp),%eax
  801efb:	50                   	push   %eax
  801efc:	57                   	push   %edi
  801efd:	e8 ed e9 ff ff       	call   8008ef <memmove>
		sys_cputs(buf, m);
  801f02:	83 c4 08             	add    $0x8,%esp
  801f05:	53                   	push   %ebx
  801f06:	57                   	push   %edi
  801f07:	e8 e8 eb ff ff       	call   800af4 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f0c:	01 de                	add    %ebx,%esi
  801f0e:	83 c4 10             	add    $0x10,%esp
  801f11:	eb ca                	jmp    801edd <devcons_write+0x1b>
}
  801f13:	89 f0                	mov    %esi,%eax
  801f15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f18:	5b                   	pop    %ebx
  801f19:	5e                   	pop    %esi
  801f1a:	5f                   	pop    %edi
  801f1b:	5d                   	pop    %ebp
  801f1c:	c3                   	ret    

00801f1d <devcons_read>:
{
  801f1d:	f3 0f 1e fb          	endbr32 
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	83 ec 08             	sub    $0x8,%esp
  801f27:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f30:	74 21                	je     801f53 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801f32:	e8 e7 eb ff ff       	call   800b1e <sys_cgetc>
  801f37:	85 c0                	test   %eax,%eax
  801f39:	75 07                	jne    801f42 <devcons_read+0x25>
		sys_yield();
  801f3b:	e8 54 ec ff ff       	call   800b94 <sys_yield>
  801f40:	eb f0                	jmp    801f32 <devcons_read+0x15>
	if (c < 0)
  801f42:	78 0f                	js     801f53 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801f44:	83 f8 04             	cmp    $0x4,%eax
  801f47:	74 0c                	je     801f55 <devcons_read+0x38>
	*(char*)vbuf = c;
  801f49:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f4c:	88 02                	mov    %al,(%edx)
	return 1;
  801f4e:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801f53:	c9                   	leave  
  801f54:	c3                   	ret    
		return 0;
  801f55:	b8 00 00 00 00       	mov    $0x0,%eax
  801f5a:	eb f7                	jmp    801f53 <devcons_read+0x36>

00801f5c <cputchar>:
{
  801f5c:	f3 0f 1e fb          	endbr32 
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f66:	8b 45 08             	mov    0x8(%ebp),%eax
  801f69:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f6c:	6a 01                	push   $0x1
  801f6e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f71:	50                   	push   %eax
  801f72:	e8 7d eb ff ff       	call   800af4 <sys_cputs>
}
  801f77:	83 c4 10             	add    $0x10,%esp
  801f7a:	c9                   	leave  
  801f7b:	c3                   	ret    

00801f7c <getchar>:
{
  801f7c:	f3 0f 1e fb          	endbr32 
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f86:	6a 01                	push   $0x1
  801f88:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f8b:	50                   	push   %eax
  801f8c:	6a 00                	push   $0x0
  801f8e:	e8 3a f6 ff ff       	call   8015cd <read>
	if (r < 0)
  801f93:	83 c4 10             	add    $0x10,%esp
  801f96:	85 c0                	test   %eax,%eax
  801f98:	78 06                	js     801fa0 <getchar+0x24>
	if (r < 1)
  801f9a:	74 06                	je     801fa2 <getchar+0x26>
	return c;
  801f9c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801fa0:	c9                   	leave  
  801fa1:	c3                   	ret    
		return -E_EOF;
  801fa2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801fa7:	eb f7                	jmp    801fa0 <getchar+0x24>

00801fa9 <iscons>:
{
  801fa9:	f3 0f 1e fb          	endbr32 
  801fad:	55                   	push   %ebp
  801fae:	89 e5                	mov    %esp,%ebp
  801fb0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb6:	50                   	push   %eax
  801fb7:	ff 75 08             	pushl  0x8(%ebp)
  801fba:	e8 8b f3 ff ff       	call   80134a <fd_lookup>
  801fbf:	83 c4 10             	add    $0x10,%esp
  801fc2:	85 c0                	test   %eax,%eax
  801fc4:	78 11                	js     801fd7 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801fc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fcf:	39 10                	cmp    %edx,(%eax)
  801fd1:	0f 94 c0             	sete   %al
  801fd4:	0f b6 c0             	movzbl %al,%eax
}
  801fd7:	c9                   	leave  
  801fd8:	c3                   	ret    

00801fd9 <opencons>:
{
  801fd9:	f3 0f 1e fb          	endbr32 
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801fe3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe6:	50                   	push   %eax
  801fe7:	e8 08 f3 ff ff       	call   8012f4 <fd_alloc>
  801fec:	83 c4 10             	add    $0x10,%esp
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	78 3a                	js     80202d <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ff3:	83 ec 04             	sub    $0x4,%esp
  801ff6:	68 07 04 00 00       	push   $0x407
  801ffb:	ff 75 f4             	pushl  -0xc(%ebp)
  801ffe:	6a 00                	push   $0x0
  802000:	e8 ba eb ff ff       	call   800bbf <sys_page_alloc>
  802005:	83 c4 10             	add    $0x10,%esp
  802008:	85 c0                	test   %eax,%eax
  80200a:	78 21                	js     80202d <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80200c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802015:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802017:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802021:	83 ec 0c             	sub    $0xc,%esp
  802024:	50                   	push   %eax
  802025:	e8 97 f2 ff ff       	call   8012c1 <fd2num>
  80202a:	83 c4 10             	add    $0x10,%esp
}
  80202d:	c9                   	leave  
  80202e:	c3                   	ret    

0080202f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80202f:	f3 0f 1e fb          	endbr32 
  802033:	55                   	push   %ebp
  802034:	89 e5                	mov    %esp,%ebp
  802036:	56                   	push   %esi
  802037:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802038:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80203b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802041:	e8 26 eb ff ff       	call   800b6c <sys_getenvid>
  802046:	83 ec 0c             	sub    $0xc,%esp
  802049:	ff 75 0c             	pushl  0xc(%ebp)
  80204c:	ff 75 08             	pushl  0x8(%ebp)
  80204f:	56                   	push   %esi
  802050:	50                   	push   %eax
  802051:	68 18 2a 80 00       	push   $0x802a18
  802056:	e8 72 e1 ff ff       	call   8001cd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80205b:	83 c4 18             	add    $0x18,%esp
  80205e:	53                   	push   %ebx
  80205f:	ff 75 10             	pushl  0x10(%ebp)
  802062:	e8 11 e1 ff ff       	call   800178 <vcprintf>
	cprintf("\n");
  802067:	c7 04 24 03 2a 80 00 	movl   $0x802a03,(%esp)
  80206e:	e8 5a e1 ff ff       	call   8001cd <cprintf>
  802073:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802076:	cc                   	int3   
  802077:	eb fd                	jmp    802076 <_panic+0x47>

00802079 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802079:	f3 0f 1e fb          	endbr32 
  80207d:	55                   	push   %ebp
  80207e:	89 e5                	mov    %esp,%ebp
  802080:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  802083:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80208a:	74 0a                	je     802096 <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80208c:	8b 45 08             	mov    0x8(%ebp),%eax
  80208f:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802094:	c9                   	leave  
  802095:	c3                   	ret    
		if (sys_page_alloc(0,
  802096:	83 ec 04             	sub    $0x4,%esp
  802099:	6a 07                	push   $0x7
  80209b:	68 00 f0 bf ee       	push   $0xeebff000
  8020a0:	6a 00                	push   $0x0
  8020a2:	e8 18 eb ff ff       	call   800bbf <sys_page_alloc>
  8020a7:	83 c4 10             	add    $0x10,%esp
  8020aa:	85 c0                	test   %eax,%eax
  8020ac:	78 2a                	js     8020d8 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  8020ae:	83 ec 08             	sub    $0x8,%esp
  8020b1:	68 ec 20 80 00       	push   $0x8020ec
  8020b6:	6a 00                	push   $0x0
  8020b8:	e8 c9 eb ff ff       	call   800c86 <sys_env_set_pgfault_upcall>
  8020bd:	83 c4 10             	add    $0x10,%esp
  8020c0:	85 c0                	test   %eax,%eax
  8020c2:	79 c8                	jns    80208c <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  8020c4:	83 ec 04             	sub    $0x4,%esp
  8020c7:	68 70 2a 80 00       	push   $0x802a70
  8020cc:	6a 25                	push   $0x25
  8020ce:	68 b7 2a 80 00       	push   $0x802ab7
  8020d3:	e8 57 ff ff ff       	call   80202f <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  8020d8:	83 ec 04             	sub    $0x4,%esp
  8020db:	68 3c 2a 80 00       	push   $0x802a3c
  8020e0:	6a 21                	push   $0x21
  8020e2:	68 b7 2a 80 00       	push   $0x802ab7
  8020e7:	e8 43 ff ff ff       	call   80202f <_panic>

008020ec <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8020ec:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8020ed:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8020f2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8020f4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  8020f7:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  8020fc:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  802100:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802104:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  802106:	83 c4 08             	add    $0x8,%esp
	popal
  802109:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  80210a:	83 c4 04             	add    $0x4,%esp
	popfl
  80210d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  80210e:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802111:	c3                   	ret    

00802112 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802112:	f3 0f 1e fb          	endbr32 
  802116:	55                   	push   %ebp
  802117:	89 e5                	mov    %esp,%ebp
  802119:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80211c:	89 c2                	mov    %eax,%edx
  80211e:	c1 ea 16             	shr    $0x16,%edx
  802121:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802128:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80212d:	f6 c1 01             	test   $0x1,%cl
  802130:	74 1c                	je     80214e <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802132:	c1 e8 0c             	shr    $0xc,%eax
  802135:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80213c:	a8 01                	test   $0x1,%al
  80213e:	74 0e                	je     80214e <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802140:	c1 e8 0c             	shr    $0xc,%eax
  802143:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80214a:	ef 
  80214b:	0f b7 d2             	movzwl %dx,%edx
}
  80214e:	89 d0                	mov    %edx,%eax
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	66 90                	xchg   %ax,%ax
  802154:	66 90                	xchg   %ax,%ax
  802156:	66 90                	xchg   %ax,%ax
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__udivdi3>:
  802160:	f3 0f 1e fb          	endbr32 
  802164:	55                   	push   %ebp
  802165:	57                   	push   %edi
  802166:	56                   	push   %esi
  802167:	53                   	push   %ebx
  802168:	83 ec 1c             	sub    $0x1c,%esp
  80216b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80216f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802173:	8b 74 24 34          	mov    0x34(%esp),%esi
  802177:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80217b:	85 d2                	test   %edx,%edx
  80217d:	75 19                	jne    802198 <__udivdi3+0x38>
  80217f:	39 f3                	cmp    %esi,%ebx
  802181:	76 4d                	jbe    8021d0 <__udivdi3+0x70>
  802183:	31 ff                	xor    %edi,%edi
  802185:	89 e8                	mov    %ebp,%eax
  802187:	89 f2                	mov    %esi,%edx
  802189:	f7 f3                	div    %ebx
  80218b:	89 fa                	mov    %edi,%edx
  80218d:	83 c4 1c             	add    $0x1c,%esp
  802190:	5b                   	pop    %ebx
  802191:	5e                   	pop    %esi
  802192:	5f                   	pop    %edi
  802193:	5d                   	pop    %ebp
  802194:	c3                   	ret    
  802195:	8d 76 00             	lea    0x0(%esi),%esi
  802198:	39 f2                	cmp    %esi,%edx
  80219a:	76 14                	jbe    8021b0 <__udivdi3+0x50>
  80219c:	31 ff                	xor    %edi,%edi
  80219e:	31 c0                	xor    %eax,%eax
  8021a0:	89 fa                	mov    %edi,%edx
  8021a2:	83 c4 1c             	add    $0x1c,%esp
  8021a5:	5b                   	pop    %ebx
  8021a6:	5e                   	pop    %esi
  8021a7:	5f                   	pop    %edi
  8021a8:	5d                   	pop    %ebp
  8021a9:	c3                   	ret    
  8021aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b0:	0f bd fa             	bsr    %edx,%edi
  8021b3:	83 f7 1f             	xor    $0x1f,%edi
  8021b6:	75 48                	jne    802200 <__udivdi3+0xa0>
  8021b8:	39 f2                	cmp    %esi,%edx
  8021ba:	72 06                	jb     8021c2 <__udivdi3+0x62>
  8021bc:	31 c0                	xor    %eax,%eax
  8021be:	39 eb                	cmp    %ebp,%ebx
  8021c0:	77 de                	ja     8021a0 <__udivdi3+0x40>
  8021c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c7:	eb d7                	jmp    8021a0 <__udivdi3+0x40>
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	89 d9                	mov    %ebx,%ecx
  8021d2:	85 db                	test   %ebx,%ebx
  8021d4:	75 0b                	jne    8021e1 <__udivdi3+0x81>
  8021d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	f7 f3                	div    %ebx
  8021df:	89 c1                	mov    %eax,%ecx
  8021e1:	31 d2                	xor    %edx,%edx
  8021e3:	89 f0                	mov    %esi,%eax
  8021e5:	f7 f1                	div    %ecx
  8021e7:	89 c6                	mov    %eax,%esi
  8021e9:	89 e8                	mov    %ebp,%eax
  8021eb:	89 f7                	mov    %esi,%edi
  8021ed:	f7 f1                	div    %ecx
  8021ef:	89 fa                	mov    %edi,%edx
  8021f1:	83 c4 1c             	add    $0x1c,%esp
  8021f4:	5b                   	pop    %ebx
  8021f5:	5e                   	pop    %esi
  8021f6:	5f                   	pop    %edi
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 f9                	mov    %edi,%ecx
  802202:	b8 20 00 00 00       	mov    $0x20,%eax
  802207:	29 f8                	sub    %edi,%eax
  802209:	d3 e2                	shl    %cl,%edx
  80220b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80220f:	89 c1                	mov    %eax,%ecx
  802211:	89 da                	mov    %ebx,%edx
  802213:	d3 ea                	shr    %cl,%edx
  802215:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802219:	09 d1                	or     %edx,%ecx
  80221b:	89 f2                	mov    %esi,%edx
  80221d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802221:	89 f9                	mov    %edi,%ecx
  802223:	d3 e3                	shl    %cl,%ebx
  802225:	89 c1                	mov    %eax,%ecx
  802227:	d3 ea                	shr    %cl,%edx
  802229:	89 f9                	mov    %edi,%ecx
  80222b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80222f:	89 eb                	mov    %ebp,%ebx
  802231:	d3 e6                	shl    %cl,%esi
  802233:	89 c1                	mov    %eax,%ecx
  802235:	d3 eb                	shr    %cl,%ebx
  802237:	09 de                	or     %ebx,%esi
  802239:	89 f0                	mov    %esi,%eax
  80223b:	f7 74 24 08          	divl   0x8(%esp)
  80223f:	89 d6                	mov    %edx,%esi
  802241:	89 c3                	mov    %eax,%ebx
  802243:	f7 64 24 0c          	mull   0xc(%esp)
  802247:	39 d6                	cmp    %edx,%esi
  802249:	72 15                	jb     802260 <__udivdi3+0x100>
  80224b:	89 f9                	mov    %edi,%ecx
  80224d:	d3 e5                	shl    %cl,%ebp
  80224f:	39 c5                	cmp    %eax,%ebp
  802251:	73 04                	jae    802257 <__udivdi3+0xf7>
  802253:	39 d6                	cmp    %edx,%esi
  802255:	74 09                	je     802260 <__udivdi3+0x100>
  802257:	89 d8                	mov    %ebx,%eax
  802259:	31 ff                	xor    %edi,%edi
  80225b:	e9 40 ff ff ff       	jmp    8021a0 <__udivdi3+0x40>
  802260:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802263:	31 ff                	xor    %edi,%edi
  802265:	e9 36 ff ff ff       	jmp    8021a0 <__udivdi3+0x40>
  80226a:	66 90                	xchg   %ax,%ax
  80226c:	66 90                	xchg   %ax,%ax
  80226e:	66 90                	xchg   %ax,%ax

00802270 <__umoddi3>:
  802270:	f3 0f 1e fb          	endbr32 
  802274:	55                   	push   %ebp
  802275:	57                   	push   %edi
  802276:	56                   	push   %esi
  802277:	53                   	push   %ebx
  802278:	83 ec 1c             	sub    $0x1c,%esp
  80227b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80227f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802283:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802287:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80228b:	85 c0                	test   %eax,%eax
  80228d:	75 19                	jne    8022a8 <__umoddi3+0x38>
  80228f:	39 df                	cmp    %ebx,%edi
  802291:	76 5d                	jbe    8022f0 <__umoddi3+0x80>
  802293:	89 f0                	mov    %esi,%eax
  802295:	89 da                	mov    %ebx,%edx
  802297:	f7 f7                	div    %edi
  802299:	89 d0                	mov    %edx,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	83 c4 1c             	add    $0x1c,%esp
  8022a0:	5b                   	pop    %ebx
  8022a1:	5e                   	pop    %esi
  8022a2:	5f                   	pop    %edi
  8022a3:	5d                   	pop    %ebp
  8022a4:	c3                   	ret    
  8022a5:	8d 76 00             	lea    0x0(%esi),%esi
  8022a8:	89 f2                	mov    %esi,%edx
  8022aa:	39 d8                	cmp    %ebx,%eax
  8022ac:	76 12                	jbe    8022c0 <__umoddi3+0x50>
  8022ae:	89 f0                	mov    %esi,%eax
  8022b0:	89 da                	mov    %ebx,%edx
  8022b2:	83 c4 1c             	add    $0x1c,%esp
  8022b5:	5b                   	pop    %ebx
  8022b6:	5e                   	pop    %esi
  8022b7:	5f                   	pop    %edi
  8022b8:	5d                   	pop    %ebp
  8022b9:	c3                   	ret    
  8022ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022c0:	0f bd e8             	bsr    %eax,%ebp
  8022c3:	83 f5 1f             	xor    $0x1f,%ebp
  8022c6:	75 50                	jne    802318 <__umoddi3+0xa8>
  8022c8:	39 d8                	cmp    %ebx,%eax
  8022ca:	0f 82 e0 00 00 00    	jb     8023b0 <__umoddi3+0x140>
  8022d0:	89 d9                	mov    %ebx,%ecx
  8022d2:	39 f7                	cmp    %esi,%edi
  8022d4:	0f 86 d6 00 00 00    	jbe    8023b0 <__umoddi3+0x140>
  8022da:	89 d0                	mov    %edx,%eax
  8022dc:	89 ca                	mov    %ecx,%edx
  8022de:	83 c4 1c             	add    $0x1c,%esp
  8022e1:	5b                   	pop    %ebx
  8022e2:	5e                   	pop    %esi
  8022e3:	5f                   	pop    %edi
  8022e4:	5d                   	pop    %ebp
  8022e5:	c3                   	ret    
  8022e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022ed:	8d 76 00             	lea    0x0(%esi),%esi
  8022f0:	89 fd                	mov    %edi,%ebp
  8022f2:	85 ff                	test   %edi,%edi
  8022f4:	75 0b                	jne    802301 <__umoddi3+0x91>
  8022f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022fb:	31 d2                	xor    %edx,%edx
  8022fd:	f7 f7                	div    %edi
  8022ff:	89 c5                	mov    %eax,%ebp
  802301:	89 d8                	mov    %ebx,%eax
  802303:	31 d2                	xor    %edx,%edx
  802305:	f7 f5                	div    %ebp
  802307:	89 f0                	mov    %esi,%eax
  802309:	f7 f5                	div    %ebp
  80230b:	89 d0                	mov    %edx,%eax
  80230d:	31 d2                	xor    %edx,%edx
  80230f:	eb 8c                	jmp    80229d <__umoddi3+0x2d>
  802311:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802318:	89 e9                	mov    %ebp,%ecx
  80231a:	ba 20 00 00 00       	mov    $0x20,%edx
  80231f:	29 ea                	sub    %ebp,%edx
  802321:	d3 e0                	shl    %cl,%eax
  802323:	89 44 24 08          	mov    %eax,0x8(%esp)
  802327:	89 d1                	mov    %edx,%ecx
  802329:	89 f8                	mov    %edi,%eax
  80232b:	d3 e8                	shr    %cl,%eax
  80232d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802331:	89 54 24 04          	mov    %edx,0x4(%esp)
  802335:	8b 54 24 04          	mov    0x4(%esp),%edx
  802339:	09 c1                	or     %eax,%ecx
  80233b:	89 d8                	mov    %ebx,%eax
  80233d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802341:	89 e9                	mov    %ebp,%ecx
  802343:	d3 e7                	shl    %cl,%edi
  802345:	89 d1                	mov    %edx,%ecx
  802347:	d3 e8                	shr    %cl,%eax
  802349:	89 e9                	mov    %ebp,%ecx
  80234b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80234f:	d3 e3                	shl    %cl,%ebx
  802351:	89 c7                	mov    %eax,%edi
  802353:	89 d1                	mov    %edx,%ecx
  802355:	89 f0                	mov    %esi,%eax
  802357:	d3 e8                	shr    %cl,%eax
  802359:	89 e9                	mov    %ebp,%ecx
  80235b:	89 fa                	mov    %edi,%edx
  80235d:	d3 e6                	shl    %cl,%esi
  80235f:	09 d8                	or     %ebx,%eax
  802361:	f7 74 24 08          	divl   0x8(%esp)
  802365:	89 d1                	mov    %edx,%ecx
  802367:	89 f3                	mov    %esi,%ebx
  802369:	f7 64 24 0c          	mull   0xc(%esp)
  80236d:	89 c6                	mov    %eax,%esi
  80236f:	89 d7                	mov    %edx,%edi
  802371:	39 d1                	cmp    %edx,%ecx
  802373:	72 06                	jb     80237b <__umoddi3+0x10b>
  802375:	75 10                	jne    802387 <__umoddi3+0x117>
  802377:	39 c3                	cmp    %eax,%ebx
  802379:	73 0c                	jae    802387 <__umoddi3+0x117>
  80237b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80237f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802383:	89 d7                	mov    %edx,%edi
  802385:	89 c6                	mov    %eax,%esi
  802387:	89 ca                	mov    %ecx,%edx
  802389:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80238e:	29 f3                	sub    %esi,%ebx
  802390:	19 fa                	sbb    %edi,%edx
  802392:	89 d0                	mov    %edx,%eax
  802394:	d3 e0                	shl    %cl,%eax
  802396:	89 e9                	mov    %ebp,%ecx
  802398:	d3 eb                	shr    %cl,%ebx
  80239a:	d3 ea                	shr    %cl,%edx
  80239c:	09 d8                	or     %ebx,%eax
  80239e:	83 c4 1c             	add    $0x1c,%esp
  8023a1:	5b                   	pop    %ebx
  8023a2:	5e                   	pop    %esi
  8023a3:	5f                   	pop    %edi
  8023a4:	5d                   	pop    %ebp
  8023a5:	c3                   	ret    
  8023a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023ad:	8d 76 00             	lea    0x0(%esi),%esi
  8023b0:	29 fe                	sub    %edi,%esi
  8023b2:	19 c3                	sbb    %eax,%ebx
  8023b4:	89 f2                	mov    %esi,%edx
  8023b6:	89 d9                	mov    %ebx,%ecx
  8023b8:	e9 1d ff ff ff       	jmp    8022da <__umoddi3+0x6a>
