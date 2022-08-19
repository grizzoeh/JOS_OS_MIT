
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 07 01 00 00       	call   800138 <libmain>
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
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  800042:	c7 05 00 30 80 00 e0 	movl   $0x8024e0,0x803000
  800049:	24 80 00 

	cprintf("icode startup\n");
  80004c:	68 e6 24 80 00       	push   $0x8024e6
  800051:	e8 35 02 00 00       	call   80028b <cprintf>

	cprintf("icode: open /motd\n");
  800056:	c7 04 24 f5 24 80 00 	movl   $0x8024f5,(%esp)
  80005d:	e8 29 02 00 00       	call   80028b <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800062:	83 c4 08             	add    $0x8,%esp
  800065:	6a 00                	push   $0x0
  800067:	68 08 25 80 00       	push   $0x802508
  80006c:	e8 0f 15 00 00       	call   801580 <open>
  800071:	89 c6                	mov    %eax,%esi
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	85 c0                	test   %eax,%eax
  800078:	78 18                	js     800092 <umain+0x5f>
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
  80007a:	83 ec 0c             	sub    $0xc,%esp
  80007d:	68 31 25 80 00       	push   $0x802531
  800082:	e8 04 02 00 00       	call   80028b <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  800090:	eb 1f                	jmp    8000b1 <umain+0x7e>
		panic("icode: open /motd: %e", fd);
  800092:	50                   	push   %eax
  800093:	68 0e 25 80 00       	push   $0x80250e
  800098:	6a 0f                	push   $0xf
  80009a:	68 24 25 80 00       	push   $0x802524
  80009f:	e8 00 01 00 00       	call   8001a4 <_panic>
		sys_cputs(buf, n);
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	50                   	push   %eax
  8000a8:	53                   	push   %ebx
  8000a9:	e8 04 0b 00 00       	call   800bb2 <sys_cputs>
  8000ae:	83 c4 10             	add    $0x10,%esp
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000b1:	83 ec 04             	sub    $0x4,%esp
  8000b4:	68 00 02 00 00       	push   $0x200
  8000b9:	53                   	push   %ebx
  8000ba:	56                   	push   %esi
  8000bb:	e8 06 10 00 00       	call   8010c6 <read>
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	85 c0                	test   %eax,%eax
  8000c5:	7f dd                	jg     8000a4 <umain+0x71>

	cprintf("icode: close /motd\n");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 44 25 80 00       	push   $0x802544
  8000cf:	e8 b7 01 00 00       	call   80028b <cprintf>
	close(fd);
  8000d4:	89 34 24             	mov    %esi,(%esp)
  8000d7:	e8 a0 0e 00 00       	call   800f7c <close>

	cprintf("icode: spawn /init\n");
  8000dc:	c7 04 24 58 25 80 00 	movl   $0x802558,(%esp)
  8000e3:	e8 a3 01 00 00       	call   80028b <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ef:	68 6c 25 80 00       	push   $0x80256c
  8000f4:	68 75 25 80 00       	push   $0x802575
  8000f9:	68 7f 25 80 00       	push   $0x80257f
  8000fe:	68 7e 25 80 00       	push   $0x80257e
  800103:	e8 7b 1a 00 00       	call   801b83 <spawnl>
  800108:	83 c4 20             	add    $0x20,%esp
  80010b:	85 c0                	test   %eax,%eax
  80010d:	78 17                	js     800126 <umain+0xf3>
		panic("icode: spawn /init: %e", r);

	cprintf("icode: exiting\n");
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	68 9b 25 80 00       	push   $0x80259b
  800117:	e8 6f 01 00 00       	call   80028b <cprintf>
}
  80011c:	83 c4 10             	add    $0x10,%esp
  80011f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    
		panic("icode: spawn /init: %e", r);
  800126:	50                   	push   %eax
  800127:	68 84 25 80 00       	push   $0x802584
  80012c:	6a 1a                	push   $0x1a
  80012e:	68 24 25 80 00       	push   $0x802524
  800133:	e8 6c 00 00 00       	call   8001a4 <_panic>

00800138 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800138:	f3 0f 1e fb          	endbr32 
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
  800141:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800144:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800147:	e8 de 0a 00 00       	call   800c2a <sys_getenvid>
	if (id >= 0)
  80014c:	85 c0                	test   %eax,%eax
  80014e:	78 12                	js     800162 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800150:	25 ff 03 00 00       	and    $0x3ff,%eax
  800155:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800158:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80015d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800162:	85 db                	test   %ebx,%ebx
  800164:	7e 07                	jle    80016d <libmain+0x35>
		binaryname = argv[0];
  800166:	8b 06                	mov    (%esi),%eax
  800168:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80016d:	83 ec 08             	sub    $0x8,%esp
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
  800172:	e8 bc fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800177:	e8 0a 00 00 00       	call   800186 <exit>
}
  80017c:	83 c4 10             	add    $0x10,%esp
  80017f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800182:	5b                   	pop    %ebx
  800183:	5e                   	pop    %esi
  800184:	5d                   	pop    %ebp
  800185:	c3                   	ret    

00800186 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800186:	f3 0f 1e fb          	endbr32 
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800190:	e8 18 0e 00 00       	call   800fad <close_all>
	sys_env_destroy(0);
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	6a 00                	push   $0x0
  80019a:	e8 65 0a 00 00       	call   800c04 <sys_env_destroy>
}
  80019f:	83 c4 10             	add    $0x10,%esp
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a4:	f3 0f 1e fb          	endbr32 
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	56                   	push   %esi
  8001ac:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001ad:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001b0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001b6:	e8 6f 0a 00 00       	call   800c2a <sys_getenvid>
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	ff 75 0c             	pushl  0xc(%ebp)
  8001c1:	ff 75 08             	pushl  0x8(%ebp)
  8001c4:	56                   	push   %esi
  8001c5:	50                   	push   %eax
  8001c6:	68 b8 25 80 00       	push   $0x8025b8
  8001cb:	e8 bb 00 00 00       	call   80028b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d0:	83 c4 18             	add    $0x18,%esp
  8001d3:	53                   	push   %ebx
  8001d4:	ff 75 10             	pushl  0x10(%ebp)
  8001d7:	e8 5a 00 00 00       	call   800236 <vcprintf>
	cprintf("\n");
  8001dc:	c7 04 24 96 2a 80 00 	movl   $0x802a96,(%esp)
  8001e3:	e8 a3 00 00 00       	call   80028b <cprintf>
  8001e8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001eb:	cc                   	int3   
  8001ec:	eb fd                	jmp    8001eb <_panic+0x47>

008001ee <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ee:	f3 0f 1e fb          	endbr32 
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 04             	sub    $0x4,%esp
  8001f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fc:	8b 13                	mov    (%ebx),%edx
  8001fe:	8d 42 01             	lea    0x1(%edx),%eax
  800201:	89 03                	mov    %eax,(%ebx)
  800203:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800206:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80020a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020f:	74 09                	je     80021a <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800211:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800218:	c9                   	leave  
  800219:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80021a:	83 ec 08             	sub    $0x8,%esp
  80021d:	68 ff 00 00 00       	push   $0xff
  800222:	8d 43 08             	lea    0x8(%ebx),%eax
  800225:	50                   	push   %eax
  800226:	e8 87 09 00 00       	call   800bb2 <sys_cputs>
		b->idx = 0;
  80022b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	eb db                	jmp    800211 <putch+0x23>

00800236 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800236:	f3 0f 1e fb          	endbr32 
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800243:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024a:	00 00 00 
	b.cnt = 0;
  80024d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800254:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800257:	ff 75 0c             	pushl  0xc(%ebp)
  80025a:	ff 75 08             	pushl  0x8(%ebp)
  80025d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	68 ee 01 80 00       	push   $0x8001ee
  800269:	e8 80 01 00 00       	call   8003ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026e:	83 c4 08             	add    $0x8,%esp
  800271:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800277:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027d:	50                   	push   %eax
  80027e:	e8 2f 09 00 00       	call   800bb2 <sys_cputs>

	return b.cnt;
}
  800283:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028b:	f3 0f 1e fb          	endbr32 
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800295:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800298:	50                   	push   %eax
  800299:	ff 75 08             	pushl  0x8(%ebp)
  80029c:	e8 95 ff ff ff       	call   800236 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a1:	c9                   	leave  
  8002a2:	c3                   	ret    

008002a3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	57                   	push   %edi
  8002a7:	56                   	push   %esi
  8002a8:	53                   	push   %ebx
  8002a9:	83 ec 1c             	sub    $0x1c,%esp
  8002ac:	89 c7                	mov    %eax,%edi
  8002ae:	89 d6                	mov    %edx,%esi
  8002b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b6:	89 d1                	mov    %edx,%ecx
  8002b8:	89 c2                	mov    %eax,%edx
  8002ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002bd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002d0:	39 c2                	cmp    %eax,%edx
  8002d2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002d5:	72 3e                	jb     800315 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d7:	83 ec 0c             	sub    $0xc,%esp
  8002da:	ff 75 18             	pushl  0x18(%ebp)
  8002dd:	83 eb 01             	sub    $0x1,%ebx
  8002e0:	53                   	push   %ebx
  8002e1:	50                   	push   %eax
  8002e2:	83 ec 08             	sub    $0x8,%esp
  8002e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002eb:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f1:	e8 7a 1f 00 00       	call   802270 <__udivdi3>
  8002f6:	83 c4 18             	add    $0x18,%esp
  8002f9:	52                   	push   %edx
  8002fa:	50                   	push   %eax
  8002fb:	89 f2                	mov    %esi,%edx
  8002fd:	89 f8                	mov    %edi,%eax
  8002ff:	e8 9f ff ff ff       	call   8002a3 <printnum>
  800304:	83 c4 20             	add    $0x20,%esp
  800307:	eb 13                	jmp    80031c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	56                   	push   %esi
  80030d:	ff 75 18             	pushl  0x18(%ebp)
  800310:	ff d7                	call   *%edi
  800312:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800315:	83 eb 01             	sub    $0x1,%ebx
  800318:	85 db                	test   %ebx,%ebx
  80031a:	7f ed                	jg     800309 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031c:	83 ec 08             	sub    $0x8,%esp
  80031f:	56                   	push   %esi
  800320:	83 ec 04             	sub    $0x4,%esp
  800323:	ff 75 e4             	pushl  -0x1c(%ebp)
  800326:	ff 75 e0             	pushl  -0x20(%ebp)
  800329:	ff 75 dc             	pushl  -0x24(%ebp)
  80032c:	ff 75 d8             	pushl  -0x28(%ebp)
  80032f:	e8 4c 20 00 00       	call   802380 <__umoddi3>
  800334:	83 c4 14             	add    $0x14,%esp
  800337:	0f be 80 db 25 80 00 	movsbl 0x8025db(%eax),%eax
  80033e:	50                   	push   %eax
  80033f:	ff d7                	call   *%edi
}
  800341:	83 c4 10             	add    $0x10,%esp
  800344:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800347:	5b                   	pop    %ebx
  800348:	5e                   	pop    %esi
  800349:	5f                   	pop    %edi
  80034a:	5d                   	pop    %ebp
  80034b:	c3                   	ret    

0080034c <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80034c:	83 fa 01             	cmp    $0x1,%edx
  80034f:	7f 13                	jg     800364 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800351:	85 d2                	test   %edx,%edx
  800353:	74 1c                	je     800371 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800355:	8b 10                	mov    (%eax),%edx
  800357:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035a:	89 08                	mov    %ecx,(%eax)
  80035c:	8b 02                	mov    (%edx),%eax
  80035e:	ba 00 00 00 00       	mov    $0x0,%edx
  800363:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800364:	8b 10                	mov    (%eax),%edx
  800366:	8d 4a 08             	lea    0x8(%edx),%ecx
  800369:	89 08                	mov    %ecx,(%eax)
  80036b:	8b 02                	mov    (%edx),%eax
  80036d:	8b 52 04             	mov    0x4(%edx),%edx
  800370:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800371:	8b 10                	mov    (%eax),%edx
  800373:	8d 4a 04             	lea    0x4(%edx),%ecx
  800376:	89 08                	mov    %ecx,(%eax)
  800378:	8b 02                	mov    (%edx),%eax
  80037a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037f:	c3                   	ret    

00800380 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800380:	83 fa 01             	cmp    $0x1,%edx
  800383:	7f 0f                	jg     800394 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800385:	85 d2                	test   %edx,%edx
  800387:	74 18                	je     8003a1 <getint+0x21>
		return va_arg(*ap, long);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	99                   	cltd   
  800393:	c3                   	ret    
		return va_arg(*ap, long long);
  800394:	8b 10                	mov    (%eax),%edx
  800396:	8d 4a 08             	lea    0x8(%edx),%ecx
  800399:	89 08                	mov    %ecx,(%eax)
  80039b:	8b 02                	mov    (%edx),%eax
  80039d:	8b 52 04             	mov    0x4(%edx),%edx
  8003a0:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8003a1:	8b 10                	mov    (%eax),%edx
  8003a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a6:	89 08                	mov    %ecx,(%eax)
  8003a8:	8b 02                	mov    (%edx),%eax
  8003aa:	99                   	cltd   
}
  8003ab:	c3                   	ret    

008003ac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ac:	f3 0f 1e fb          	endbr32 
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ba:	8b 10                	mov    (%eax),%edx
  8003bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bf:	73 0a                	jae    8003cb <sprintputch+0x1f>
		*b->buf++ = ch;
  8003c1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c4:	89 08                	mov    %ecx,(%eax)
  8003c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c9:	88 02                	mov    %al,(%edx)
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <printfmt>:
{
  8003cd:	f3 0f 1e fb          	endbr32 
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003da:	50                   	push   %eax
  8003db:	ff 75 10             	pushl  0x10(%ebp)
  8003de:	ff 75 0c             	pushl  0xc(%ebp)
  8003e1:	ff 75 08             	pushl  0x8(%ebp)
  8003e4:	e8 05 00 00 00       	call   8003ee <vprintfmt>
}
  8003e9:	83 c4 10             	add    $0x10,%esp
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <vprintfmt>:
{
  8003ee:	f3 0f 1e fb          	endbr32 
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	57                   	push   %edi
  8003f6:	56                   	push   %esi
  8003f7:	53                   	push   %ebx
  8003f8:	83 ec 2c             	sub    $0x2c,%esp
  8003fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003fe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800401:	8b 7d 10             	mov    0x10(%ebp),%edi
  800404:	e9 86 02 00 00       	jmp    80068f <vprintfmt+0x2a1>
		padc = ' ';
  800409:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80040d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800414:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80041b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800422:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8d 47 01             	lea    0x1(%edi),%eax
  80042a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80042d:	0f b6 17             	movzbl (%edi),%edx
  800430:	8d 42 dd             	lea    -0x23(%edx),%eax
  800433:	3c 55                	cmp    $0x55,%al
  800435:	0f 87 df 02 00 00    	ja     80071a <vprintfmt+0x32c>
  80043b:	0f b6 c0             	movzbl %al,%eax
  80043e:	3e ff 24 85 20 27 80 	notrack jmp *0x802720(,%eax,4)
  800445:	00 
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800449:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80044d:	eb d8                	jmp    800427 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800452:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800456:	eb cf                	jmp    800427 <vprintfmt+0x39>
  800458:	0f b6 d2             	movzbl %dl,%edx
  80045b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80045e:	b8 00 00 00 00       	mov    $0x0,%eax
  800463:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800466:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800469:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80046d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800470:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800473:	83 f9 09             	cmp    $0x9,%ecx
  800476:	77 52                	ja     8004ca <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800478:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80047b:	eb e9                	jmp    800466 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8d 50 04             	lea    0x4(%eax),%edx
  800483:	89 55 14             	mov    %edx,0x14(%ebp)
  800486:	8b 00                	mov    (%eax),%eax
  800488:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80048e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800492:	79 93                	jns    800427 <vprintfmt+0x39>
				width = precision, precision = -1;
  800494:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800497:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004a1:	eb 84                	jmp    800427 <vprintfmt+0x39>
  8004a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a6:	85 c0                	test   %eax,%eax
  8004a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ad:	0f 49 d0             	cmovns %eax,%edx
  8004b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004b6:	e9 6c ff ff ff       	jmp    800427 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004be:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004c5:	e9 5d ff ff ff       	jmp    800427 <vprintfmt+0x39>
  8004ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004d0:	eb bc                	jmp    80048e <vprintfmt+0xa0>
			lflag++;
  8004d2:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004d8:	e9 4a ff ff ff       	jmp    800427 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8004dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e0:	8d 50 04             	lea    0x4(%eax),%edx
  8004e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	56                   	push   %esi
  8004ea:	ff 30                	pushl  (%eax)
  8004ec:	ff d3                	call   *%ebx
			break;
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	e9 96 01 00 00       	jmp    80068c <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	8d 50 04             	lea    0x4(%eax),%edx
  8004fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ff:	8b 00                	mov    (%eax),%eax
  800501:	99                   	cltd   
  800502:	31 d0                	xor    %edx,%eax
  800504:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800506:	83 f8 0f             	cmp    $0xf,%eax
  800509:	7f 20                	jg     80052b <vprintfmt+0x13d>
  80050b:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  800512:	85 d2                	test   %edx,%edx
  800514:	74 15                	je     80052b <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800516:	52                   	push   %edx
  800517:	68 b1 29 80 00       	push   $0x8029b1
  80051c:	56                   	push   %esi
  80051d:	53                   	push   %ebx
  80051e:	e8 aa fe ff ff       	call   8003cd <printfmt>
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	e9 61 01 00 00       	jmp    80068c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80052b:	50                   	push   %eax
  80052c:	68 f3 25 80 00       	push   $0x8025f3
  800531:	56                   	push   %esi
  800532:	53                   	push   %ebx
  800533:	e8 95 fe ff ff       	call   8003cd <printfmt>
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	e9 4c 01 00 00       	jmp    80068c <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 50 04             	lea    0x4(%eax),%edx
  800546:	89 55 14             	mov    %edx,0x14(%ebp)
  800549:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80054b:	85 c9                	test   %ecx,%ecx
  80054d:	b8 ec 25 80 00       	mov    $0x8025ec,%eax
  800552:	0f 45 c1             	cmovne %ecx,%eax
  800555:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800558:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80055c:	7e 06                	jle    800564 <vprintfmt+0x176>
  80055e:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800562:	75 0d                	jne    800571 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800564:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800567:	89 c7                	mov    %eax,%edi
  800569:	03 45 e0             	add    -0x20(%ebp),%eax
  80056c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056f:	eb 57                	jmp    8005c8 <vprintfmt+0x1da>
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	ff 75 d8             	pushl  -0x28(%ebp)
  800577:	ff 75 cc             	pushl  -0x34(%ebp)
  80057a:	e8 4f 02 00 00       	call   8007ce <strnlen>
  80057f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800582:	29 c2                	sub    %eax,%edx
  800584:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800587:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80058a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80058e:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800591:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800593:	85 db                	test   %ebx,%ebx
  800595:	7e 10                	jle    8005a7 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	56                   	push   %esi
  80059b:	57                   	push   %edi
  80059c:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80059f:	83 eb 01             	sub    $0x1,%ebx
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	eb ec                	jmp    800593 <vprintfmt+0x1a5>
  8005a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005aa:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005ad:	85 d2                	test   %edx,%edx
  8005af:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b4:	0f 49 c2             	cmovns %edx,%eax
  8005b7:	29 c2                	sub    %eax,%edx
  8005b9:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005bc:	eb a6                	jmp    800564 <vprintfmt+0x176>
					putch(ch, putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	56                   	push   %esi
  8005c2:	52                   	push   %edx
  8005c3:	ff d3                	call   *%ebx
  8005c5:	83 c4 10             	add    $0x10,%esp
  8005c8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005cb:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005cd:	83 c7 01             	add    $0x1,%edi
  8005d0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005d4:	0f be d0             	movsbl %al,%edx
  8005d7:	85 d2                	test   %edx,%edx
  8005d9:	74 42                	je     80061d <vprintfmt+0x22f>
  8005db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005df:	78 06                	js     8005e7 <vprintfmt+0x1f9>
  8005e1:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005e5:	78 1e                	js     800605 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005eb:	74 d1                	je     8005be <vprintfmt+0x1d0>
  8005ed:	0f be c0             	movsbl %al,%eax
  8005f0:	83 e8 20             	sub    $0x20,%eax
  8005f3:	83 f8 5e             	cmp    $0x5e,%eax
  8005f6:	76 c6                	jbe    8005be <vprintfmt+0x1d0>
					putch('?', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	56                   	push   %esi
  8005fc:	6a 3f                	push   $0x3f
  8005fe:	ff d3                	call   *%ebx
  800600:	83 c4 10             	add    $0x10,%esp
  800603:	eb c3                	jmp    8005c8 <vprintfmt+0x1da>
  800605:	89 cf                	mov    %ecx,%edi
  800607:	eb 0e                	jmp    800617 <vprintfmt+0x229>
				putch(' ', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	56                   	push   %esi
  80060d:	6a 20                	push   $0x20
  80060f:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800611:	83 ef 01             	sub    $0x1,%edi
  800614:	83 c4 10             	add    $0x10,%esp
  800617:	85 ff                	test   %edi,%edi
  800619:	7f ee                	jg     800609 <vprintfmt+0x21b>
  80061b:	eb 6f                	jmp    80068c <vprintfmt+0x29e>
  80061d:	89 cf                	mov    %ecx,%edi
  80061f:	eb f6                	jmp    800617 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800621:	89 ca                	mov    %ecx,%edx
  800623:	8d 45 14             	lea    0x14(%ebp),%eax
  800626:	e8 55 fd ff ff       	call   800380 <getint>
  80062b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800631:	85 d2                	test   %edx,%edx
  800633:	78 0b                	js     800640 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800635:	89 d1                	mov    %edx,%ecx
  800637:	89 c2                	mov    %eax,%edx
			base = 10;
  800639:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063e:	eb 32                	jmp    800672 <vprintfmt+0x284>
				putch('-', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	56                   	push   %esi
  800644:	6a 2d                	push   $0x2d
  800646:	ff d3                	call   *%ebx
				num = -(long long) num;
  800648:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80064b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80064e:	f7 da                	neg    %edx
  800650:	83 d1 00             	adc    $0x0,%ecx
  800653:	f7 d9                	neg    %ecx
  800655:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800658:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065d:	eb 13                	jmp    800672 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80065f:	89 ca                	mov    %ecx,%edx
  800661:	8d 45 14             	lea    0x14(%ebp),%eax
  800664:	e8 e3 fc ff ff       	call   80034c <getuint>
  800669:	89 d1                	mov    %edx,%ecx
  80066b:	89 c2                	mov    %eax,%edx
			base = 10;
  80066d:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800672:	83 ec 0c             	sub    $0xc,%esp
  800675:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800679:	57                   	push   %edi
  80067a:	ff 75 e0             	pushl  -0x20(%ebp)
  80067d:	50                   	push   %eax
  80067e:	51                   	push   %ecx
  80067f:	52                   	push   %edx
  800680:	89 f2                	mov    %esi,%edx
  800682:	89 d8                	mov    %ebx,%eax
  800684:	e8 1a fc ff ff       	call   8002a3 <printnum>
			break;
  800689:	83 c4 20             	add    $0x20,%esp
{
  80068c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80068f:	83 c7 01             	add    $0x1,%edi
  800692:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800696:	83 f8 25             	cmp    $0x25,%eax
  800699:	0f 84 6a fd ff ff    	je     800409 <vprintfmt+0x1b>
			if (ch == '\0')
  80069f:	85 c0                	test   %eax,%eax
  8006a1:	0f 84 93 00 00 00    	je     80073a <vprintfmt+0x34c>
			putch(ch, putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	56                   	push   %esi
  8006ab:	50                   	push   %eax
  8006ac:	ff d3                	call   *%ebx
  8006ae:	83 c4 10             	add    $0x10,%esp
  8006b1:	eb dc                	jmp    80068f <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8006b3:	89 ca                	mov    %ecx,%edx
  8006b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b8:	e8 8f fc ff ff       	call   80034c <getuint>
  8006bd:	89 d1                	mov    %edx,%ecx
  8006bf:	89 c2                	mov    %eax,%edx
			base = 8;
  8006c1:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006c6:	eb aa                	jmp    800672 <vprintfmt+0x284>
			putch('0', putdat);
  8006c8:	83 ec 08             	sub    $0x8,%esp
  8006cb:	56                   	push   %esi
  8006cc:	6a 30                	push   $0x30
  8006ce:	ff d3                	call   *%ebx
			putch('x', putdat);
  8006d0:	83 c4 08             	add    $0x8,%esp
  8006d3:	56                   	push   %esi
  8006d4:	6a 78                	push   $0x78
  8006d6:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 50 04             	lea    0x4(%eax),%edx
  8006de:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8006e1:	8b 10                	mov    (%eax),%edx
  8006e3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006e8:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8006eb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006f0:	eb 80                	jmp    800672 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8006f2:	89 ca                	mov    %ecx,%edx
  8006f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f7:	e8 50 fc ff ff       	call   80034c <getuint>
  8006fc:	89 d1                	mov    %edx,%ecx
  8006fe:	89 c2                	mov    %eax,%edx
			base = 16;
  800700:	b8 10 00 00 00       	mov    $0x10,%eax
  800705:	e9 68 ff ff ff       	jmp    800672 <vprintfmt+0x284>
			putch(ch, putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	56                   	push   %esi
  80070e:	6a 25                	push   $0x25
  800710:	ff d3                	call   *%ebx
			break;
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	e9 72 ff ff ff       	jmp    80068c <vprintfmt+0x29e>
			putch('%', putdat);
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	56                   	push   %esi
  80071e:	6a 25                	push   $0x25
  800720:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	89 f8                	mov    %edi,%eax
  800727:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80072b:	74 05                	je     800732 <vprintfmt+0x344>
  80072d:	83 e8 01             	sub    $0x1,%eax
  800730:	eb f5                	jmp    800727 <vprintfmt+0x339>
  800732:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800735:	e9 52 ff ff ff       	jmp    80068c <vprintfmt+0x29e>
}
  80073a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80073d:	5b                   	pop    %ebx
  80073e:	5e                   	pop    %esi
  80073f:	5f                   	pop    %edi
  800740:	5d                   	pop    %ebp
  800741:	c3                   	ret    

00800742 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800742:	f3 0f 1e fb          	endbr32 
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	83 ec 18             	sub    $0x18,%esp
  80074c:	8b 45 08             	mov    0x8(%ebp),%eax
  80074f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800752:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800755:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800759:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800763:	85 c0                	test   %eax,%eax
  800765:	74 26                	je     80078d <vsnprintf+0x4b>
  800767:	85 d2                	test   %edx,%edx
  800769:	7e 22                	jle    80078d <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076b:	ff 75 14             	pushl  0x14(%ebp)
  80076e:	ff 75 10             	pushl  0x10(%ebp)
  800771:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800774:	50                   	push   %eax
  800775:	68 ac 03 80 00       	push   $0x8003ac
  80077a:	e8 6f fc ff ff       	call   8003ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800782:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800785:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800788:	83 c4 10             	add    $0x10,%esp
}
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    
		return -E_INVAL;
  80078d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800792:	eb f7                	jmp    80078b <vsnprintf+0x49>

00800794 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800794:	f3 0f 1e fb          	endbr32 
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a1:	50                   	push   %eax
  8007a2:	ff 75 10             	pushl  0x10(%ebp)
  8007a5:	ff 75 0c             	pushl  0xc(%ebp)
  8007a8:	ff 75 08             	pushl  0x8(%ebp)
  8007ab:	e8 92 ff ff ff       	call   800742 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b2:	f3 0f 1e fb          	endbr32 
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c5:	74 05                	je     8007cc <strlen+0x1a>
		n++;
  8007c7:	83 c0 01             	add    $0x1,%eax
  8007ca:	eb f5                	jmp    8007c1 <strlen+0xf>
	return n;
}
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ce:	f3 0f 1e fb          	endbr32 
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e0:	39 d0                	cmp    %edx,%eax
  8007e2:	74 0d                	je     8007f1 <strnlen+0x23>
  8007e4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007e8:	74 05                	je     8007ef <strnlen+0x21>
		n++;
  8007ea:	83 c0 01             	add    $0x1,%eax
  8007ed:	eb f1                	jmp    8007e0 <strnlen+0x12>
  8007ef:	89 c2                	mov    %eax,%edx
	return n;
}
  8007f1:	89 d0                	mov    %edx,%eax
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f5:	f3 0f 1e fb          	endbr32 
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	53                   	push   %ebx
  8007fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800800:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800803:	b8 00 00 00 00       	mov    $0x0,%eax
  800808:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80080c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80080f:	83 c0 01             	add    $0x1,%eax
  800812:	84 d2                	test   %dl,%dl
  800814:	75 f2                	jne    800808 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800816:	89 c8                	mov    %ecx,%eax
  800818:	5b                   	pop    %ebx
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081b:	f3 0f 1e fb          	endbr32 
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	53                   	push   %ebx
  800823:	83 ec 10             	sub    $0x10,%esp
  800826:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800829:	53                   	push   %ebx
  80082a:	e8 83 ff ff ff       	call   8007b2 <strlen>
  80082f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800832:	ff 75 0c             	pushl  0xc(%ebp)
  800835:	01 d8                	add    %ebx,%eax
  800837:	50                   	push   %eax
  800838:	e8 b8 ff ff ff       	call   8007f5 <strcpy>
	return dst;
}
  80083d:	89 d8                	mov    %ebx,%eax
  80083f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800842:	c9                   	leave  
  800843:	c3                   	ret    

00800844 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800844:	f3 0f 1e fb          	endbr32 
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	56                   	push   %esi
  80084c:	53                   	push   %ebx
  80084d:	8b 75 08             	mov    0x8(%ebp),%esi
  800850:	8b 55 0c             	mov    0xc(%ebp),%edx
  800853:	89 f3                	mov    %esi,%ebx
  800855:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800858:	89 f0                	mov    %esi,%eax
  80085a:	39 d8                	cmp    %ebx,%eax
  80085c:	74 11                	je     80086f <strncpy+0x2b>
		*dst++ = *src;
  80085e:	83 c0 01             	add    $0x1,%eax
  800861:	0f b6 0a             	movzbl (%edx),%ecx
  800864:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800867:	80 f9 01             	cmp    $0x1,%cl
  80086a:	83 da ff             	sbb    $0xffffffff,%edx
  80086d:	eb eb                	jmp    80085a <strncpy+0x16>
	}
	return ret;
}
  80086f:	89 f0                	mov    %esi,%eax
  800871:	5b                   	pop    %ebx
  800872:	5e                   	pop    %esi
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800875:	f3 0f 1e fb          	endbr32 
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	56                   	push   %esi
  80087d:	53                   	push   %ebx
  80087e:	8b 75 08             	mov    0x8(%ebp),%esi
  800881:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800884:	8b 55 10             	mov    0x10(%ebp),%edx
  800887:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800889:	85 d2                	test   %edx,%edx
  80088b:	74 21                	je     8008ae <strlcpy+0x39>
  80088d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800891:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800893:	39 c2                	cmp    %eax,%edx
  800895:	74 14                	je     8008ab <strlcpy+0x36>
  800897:	0f b6 19             	movzbl (%ecx),%ebx
  80089a:	84 db                	test   %bl,%bl
  80089c:	74 0b                	je     8008a9 <strlcpy+0x34>
			*dst++ = *src++;
  80089e:	83 c1 01             	add    $0x1,%ecx
  8008a1:	83 c2 01             	add    $0x1,%edx
  8008a4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a7:	eb ea                	jmp    800893 <strlcpy+0x1e>
  8008a9:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008ab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ae:	29 f0                	sub    %esi,%eax
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	5e                   	pop    %esi
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b4:	f3 0f 1e fb          	endbr32 
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008be:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c1:	0f b6 01             	movzbl (%ecx),%eax
  8008c4:	84 c0                	test   %al,%al
  8008c6:	74 0c                	je     8008d4 <strcmp+0x20>
  8008c8:	3a 02                	cmp    (%edx),%al
  8008ca:	75 08                	jne    8008d4 <strcmp+0x20>
		p++, q++;
  8008cc:	83 c1 01             	add    $0x1,%ecx
  8008cf:	83 c2 01             	add    $0x1,%edx
  8008d2:	eb ed                	jmp    8008c1 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d4:	0f b6 c0             	movzbl %al,%eax
  8008d7:	0f b6 12             	movzbl (%edx),%edx
  8008da:	29 d0                	sub    %edx,%eax
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008de:	f3 0f 1e fb          	endbr32 
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	53                   	push   %ebx
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ec:	89 c3                	mov    %eax,%ebx
  8008ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f1:	eb 06                	jmp    8008f9 <strncmp+0x1b>
		n--, p++, q++;
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008f9:	39 d8                	cmp    %ebx,%eax
  8008fb:	74 16                	je     800913 <strncmp+0x35>
  8008fd:	0f b6 08             	movzbl (%eax),%ecx
  800900:	84 c9                	test   %cl,%cl
  800902:	74 04                	je     800908 <strncmp+0x2a>
  800904:	3a 0a                	cmp    (%edx),%cl
  800906:	74 eb                	je     8008f3 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800908:	0f b6 00             	movzbl (%eax),%eax
  80090b:	0f b6 12             	movzbl (%edx),%edx
  80090e:	29 d0                	sub    %edx,%eax
}
  800910:	5b                   	pop    %ebx
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    
		return 0;
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
  800918:	eb f6                	jmp    800910 <strncmp+0x32>

0080091a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091a:	f3 0f 1e fb          	endbr32 
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800928:	0f b6 10             	movzbl (%eax),%edx
  80092b:	84 d2                	test   %dl,%dl
  80092d:	74 09                	je     800938 <strchr+0x1e>
		if (*s == c)
  80092f:	38 ca                	cmp    %cl,%dl
  800931:	74 0a                	je     80093d <strchr+0x23>
	for (; *s; s++)
  800933:	83 c0 01             	add    $0x1,%eax
  800936:	eb f0                	jmp    800928 <strchr+0xe>
			return (char *) s;
	return 0;
  800938:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093f:	f3 0f 1e fb          	endbr32 
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800950:	38 ca                	cmp    %cl,%dl
  800952:	74 09                	je     80095d <strfind+0x1e>
  800954:	84 d2                	test   %dl,%dl
  800956:	74 05                	je     80095d <strfind+0x1e>
	for (; *s; s++)
  800958:	83 c0 01             	add    $0x1,%eax
  80095b:	eb f0                	jmp    80094d <strfind+0xe>
			break;
	return (char *) s;
}
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095f:	f3 0f 1e fb          	endbr32 
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	57                   	push   %edi
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	8b 55 08             	mov    0x8(%ebp),%edx
  80096c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80096f:	85 c9                	test   %ecx,%ecx
  800971:	74 33                	je     8009a6 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800973:	89 d0                	mov    %edx,%eax
  800975:	09 c8                	or     %ecx,%eax
  800977:	a8 03                	test   $0x3,%al
  800979:	75 23                	jne    80099e <memset+0x3f>
		c &= 0xFF;
  80097b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097f:	89 d8                	mov    %ebx,%eax
  800981:	c1 e0 08             	shl    $0x8,%eax
  800984:	89 df                	mov    %ebx,%edi
  800986:	c1 e7 18             	shl    $0x18,%edi
  800989:	89 de                	mov    %ebx,%esi
  80098b:	c1 e6 10             	shl    $0x10,%esi
  80098e:	09 f7                	or     %esi,%edi
  800990:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800992:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800995:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800997:	89 d7                	mov    %edx,%edi
  800999:	fc                   	cld    
  80099a:	f3 ab                	rep stos %eax,%es:(%edi)
  80099c:	eb 08                	jmp    8009a6 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099e:	89 d7                	mov    %edx,%edi
  8009a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a3:	fc                   	cld    
  8009a4:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8009a6:	89 d0                	mov    %edx,%eax
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5f                   	pop    %edi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ad:	f3 0f 1e fb          	endbr32 
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	57                   	push   %edi
  8009b5:	56                   	push   %esi
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009bf:	39 c6                	cmp    %eax,%esi
  8009c1:	73 32                	jae    8009f5 <memmove+0x48>
  8009c3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c6:	39 c2                	cmp    %eax,%edx
  8009c8:	76 2b                	jbe    8009f5 <memmove+0x48>
		s += n;
		d += n;
  8009ca:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cd:	89 fe                	mov    %edi,%esi
  8009cf:	09 ce                	or     %ecx,%esi
  8009d1:	09 d6                	or     %edx,%esi
  8009d3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d9:	75 0e                	jne    8009e9 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009db:	83 ef 04             	sub    $0x4,%edi
  8009de:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009e4:	fd                   	std    
  8009e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e7:	eb 09                	jmp    8009f2 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009e9:	83 ef 01             	sub    $0x1,%edi
  8009ec:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ef:	fd                   	std    
  8009f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f2:	fc                   	cld    
  8009f3:	eb 1a                	jmp    800a0f <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f5:	89 c2                	mov    %eax,%edx
  8009f7:	09 ca                	or     %ecx,%edx
  8009f9:	09 f2                	or     %esi,%edx
  8009fb:	f6 c2 03             	test   $0x3,%dl
  8009fe:	75 0a                	jne    800a0a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a00:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a03:	89 c7                	mov    %eax,%edi
  800a05:	fc                   	cld    
  800a06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a08:	eb 05                	jmp    800a0f <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a0a:	89 c7                	mov    %eax,%edi
  800a0c:	fc                   	cld    
  800a0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0f:	5e                   	pop    %esi
  800a10:	5f                   	pop    %edi
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a13:	f3 0f 1e fb          	endbr32 
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a1d:	ff 75 10             	pushl  0x10(%ebp)
  800a20:	ff 75 0c             	pushl  0xc(%ebp)
  800a23:	ff 75 08             	pushl  0x8(%ebp)
  800a26:	e8 82 ff ff ff       	call   8009ad <memmove>
}
  800a2b:	c9                   	leave  
  800a2c:	c3                   	ret    

00800a2d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2d:	f3 0f 1e fb          	endbr32 
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3c:	89 c6                	mov    %eax,%esi
  800a3e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a41:	39 f0                	cmp    %esi,%eax
  800a43:	74 1c                	je     800a61 <memcmp+0x34>
		if (*s1 != *s2)
  800a45:	0f b6 08             	movzbl (%eax),%ecx
  800a48:	0f b6 1a             	movzbl (%edx),%ebx
  800a4b:	38 d9                	cmp    %bl,%cl
  800a4d:	75 08                	jne    800a57 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a4f:	83 c0 01             	add    $0x1,%eax
  800a52:	83 c2 01             	add    $0x1,%edx
  800a55:	eb ea                	jmp    800a41 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a57:	0f b6 c1             	movzbl %cl,%eax
  800a5a:	0f b6 db             	movzbl %bl,%ebx
  800a5d:	29 d8                	sub    %ebx,%eax
  800a5f:	eb 05                	jmp    800a66 <memcmp+0x39>
	}

	return 0;
  800a61:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a6a:	f3 0f 1e fb          	endbr32 
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	8b 45 08             	mov    0x8(%ebp),%eax
  800a74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a77:	89 c2                	mov    %eax,%edx
  800a79:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a7c:	39 d0                	cmp    %edx,%eax
  800a7e:	73 09                	jae    800a89 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a80:	38 08                	cmp    %cl,(%eax)
  800a82:	74 05                	je     800a89 <memfind+0x1f>
	for (; s < ends; s++)
  800a84:	83 c0 01             	add    $0x1,%eax
  800a87:	eb f3                	jmp    800a7c <memfind+0x12>
			break;
	return (void *) s;
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a8b:	f3 0f 1e fb          	endbr32 
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	57                   	push   %edi
  800a93:	56                   	push   %esi
  800a94:	53                   	push   %ebx
  800a95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9b:	eb 03                	jmp    800aa0 <strtol+0x15>
		s++;
  800a9d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800aa0:	0f b6 01             	movzbl (%ecx),%eax
  800aa3:	3c 20                	cmp    $0x20,%al
  800aa5:	74 f6                	je     800a9d <strtol+0x12>
  800aa7:	3c 09                	cmp    $0x9,%al
  800aa9:	74 f2                	je     800a9d <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800aab:	3c 2b                	cmp    $0x2b,%al
  800aad:	74 2a                	je     800ad9 <strtol+0x4e>
	int neg = 0;
  800aaf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ab4:	3c 2d                	cmp    $0x2d,%al
  800ab6:	74 2b                	je     800ae3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abe:	75 0f                	jne    800acf <strtol+0x44>
  800ac0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac3:	74 28                	je     800aed <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac5:	85 db                	test   %ebx,%ebx
  800ac7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800acc:	0f 44 d8             	cmove  %eax,%ebx
  800acf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ad7:	eb 46                	jmp    800b1f <strtol+0x94>
		s++;
  800ad9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800adc:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae1:	eb d5                	jmp    800ab8 <strtol+0x2d>
		s++, neg = 1;
  800ae3:	83 c1 01             	add    $0x1,%ecx
  800ae6:	bf 01 00 00 00       	mov    $0x1,%edi
  800aeb:	eb cb                	jmp    800ab8 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aed:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800af1:	74 0e                	je     800b01 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800af3:	85 db                	test   %ebx,%ebx
  800af5:	75 d8                	jne    800acf <strtol+0x44>
		s++, base = 8;
  800af7:	83 c1 01             	add    $0x1,%ecx
  800afa:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aff:	eb ce                	jmp    800acf <strtol+0x44>
		s += 2, base = 16;
  800b01:	83 c1 02             	add    $0x2,%ecx
  800b04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b09:	eb c4                	jmp    800acf <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b0b:	0f be d2             	movsbl %dl,%edx
  800b0e:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b11:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b14:	7d 3a                	jge    800b50 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b16:	83 c1 01             	add    $0x1,%ecx
  800b19:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b1f:	0f b6 11             	movzbl (%ecx),%edx
  800b22:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b25:	89 f3                	mov    %esi,%ebx
  800b27:	80 fb 09             	cmp    $0x9,%bl
  800b2a:	76 df                	jbe    800b0b <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b2c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2f:	89 f3                	mov    %esi,%ebx
  800b31:	80 fb 19             	cmp    $0x19,%bl
  800b34:	77 08                	ja     800b3e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b36:	0f be d2             	movsbl %dl,%edx
  800b39:	83 ea 57             	sub    $0x57,%edx
  800b3c:	eb d3                	jmp    800b11 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b3e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b41:	89 f3                	mov    %esi,%ebx
  800b43:	80 fb 19             	cmp    $0x19,%bl
  800b46:	77 08                	ja     800b50 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b48:	0f be d2             	movsbl %dl,%edx
  800b4b:	83 ea 37             	sub    $0x37,%edx
  800b4e:	eb c1                	jmp    800b11 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b54:	74 05                	je     800b5b <strtol+0xd0>
		*endptr = (char *) s;
  800b56:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b59:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b5b:	89 c2                	mov    %eax,%edx
  800b5d:	f7 da                	neg    %edx
  800b5f:	85 ff                	test   %edi,%edi
  800b61:	0f 45 c2             	cmovne %edx,%eax
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	83 ec 1c             	sub    $0x1c,%esp
  800b72:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b75:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b78:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b80:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b83:	8b 75 14             	mov    0x14(%ebp),%esi
  800b86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b88:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b8c:	74 04                	je     800b92 <syscall+0x29>
  800b8e:	85 c0                	test   %eax,%eax
  800b90:	7f 08                	jg     800b9a <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	50                   	push   %eax
  800b9e:	ff 75 e0             	pushl  -0x20(%ebp)
  800ba1:	68 df 28 80 00       	push   $0x8028df
  800ba6:	6a 23                	push   $0x23
  800ba8:	68 fc 28 80 00       	push   $0x8028fc
  800bad:	e8 f2 f5 ff ff       	call   8001a4 <_panic>

00800bb2 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800bb2:	f3 0f 1e fb          	endbr32 
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800bbc:	6a 00                	push   $0x0
  800bbe:	6a 00                	push   $0x0
  800bc0:	6a 00                	push   $0x0
  800bc2:	ff 75 0c             	pushl  0xc(%ebp)
  800bc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd2:	e8 92 ff ff ff       	call   800b69 <syscall>
}
  800bd7:	83 c4 10             	add    $0x10,%esp
  800bda:	c9                   	leave  
  800bdb:	c3                   	ret    

00800bdc <sys_cgetc>:

int
sys_cgetc(void)
{
  800bdc:	f3 0f 1e fb          	endbr32 
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800be6:	6a 00                	push   $0x0
  800be8:	6a 00                	push   $0x0
  800bea:	6a 00                	push   $0x0
  800bec:	6a 00                	push   $0x0
  800bee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf8:	b8 01 00 00 00       	mov    $0x1,%eax
  800bfd:	e8 67 ff ff ff       	call   800b69 <syscall>
}
  800c02:	c9                   	leave  
  800c03:	c3                   	ret    

00800c04 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c04:	f3 0f 1e fb          	endbr32 
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c0e:	6a 00                	push   $0x0
  800c10:	6a 00                	push   $0x0
  800c12:	6a 00                	push   $0x0
  800c14:	6a 00                	push   $0x0
  800c16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c19:	ba 01 00 00 00       	mov    $0x1,%edx
  800c1e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c23:	e8 41 ff ff ff       	call   800b69 <syscall>
}
  800c28:	c9                   	leave  
  800c29:	c3                   	ret    

00800c2a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c2a:	f3 0f 1e fb          	endbr32 
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c34:	6a 00                	push   $0x0
  800c36:	6a 00                	push   $0x0
  800c38:	6a 00                	push   $0x0
  800c3a:	6a 00                	push   $0x0
  800c3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c41:	ba 00 00 00 00       	mov    $0x0,%edx
  800c46:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4b:	e8 19 ff ff ff       	call   800b69 <syscall>
}
  800c50:	c9                   	leave  
  800c51:	c3                   	ret    

00800c52 <sys_yield>:

void
sys_yield(void)
{
  800c52:	f3 0f 1e fb          	endbr32 
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c5c:	6a 00                	push   $0x0
  800c5e:	6a 00                	push   $0x0
  800c60:	6a 00                	push   $0x0
  800c62:	6a 00                	push   $0x0
  800c64:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c69:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c73:	e8 f1 fe ff ff       	call   800b69 <syscall>
}
  800c78:	83 c4 10             	add    $0x10,%esp
  800c7b:	c9                   	leave  
  800c7c:	c3                   	ret    

00800c7d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c7d:	f3 0f 1e fb          	endbr32 
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c87:	6a 00                	push   $0x0
  800c89:	6a 00                	push   $0x0
  800c8b:	ff 75 10             	pushl  0x10(%ebp)
  800c8e:	ff 75 0c             	pushl  0xc(%ebp)
  800c91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c94:	ba 01 00 00 00       	mov    $0x1,%edx
  800c99:	b8 04 00 00 00       	mov    $0x4,%eax
  800c9e:	e8 c6 fe ff ff       	call   800b69 <syscall>
}
  800ca3:	c9                   	leave  
  800ca4:	c3                   	ret    

00800ca5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca5:	f3 0f 1e fb          	endbr32 
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800caf:	ff 75 18             	pushl  0x18(%ebp)
  800cb2:	ff 75 14             	pushl  0x14(%ebp)
  800cb5:	ff 75 10             	pushl  0x10(%ebp)
  800cb8:	ff 75 0c             	pushl  0xc(%ebp)
  800cbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbe:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc3:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc8:	e8 9c fe ff ff       	call   800b69 <syscall>
}
  800ccd:	c9                   	leave  
  800cce:	c3                   	ret    

00800ccf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ccf:	f3 0f 1e fb          	endbr32 
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800cd9:	6a 00                	push   $0x0
  800cdb:	6a 00                	push   $0x0
  800cdd:	6a 00                	push   $0x0
  800cdf:	ff 75 0c             	pushl  0xc(%ebp)
  800ce2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce5:	ba 01 00 00 00       	mov    $0x1,%edx
  800cea:	b8 06 00 00 00       	mov    $0x6,%eax
  800cef:	e8 75 fe ff ff       	call   800b69 <syscall>
}
  800cf4:	c9                   	leave  
  800cf5:	c3                   	ret    

00800cf6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf6:	f3 0f 1e fb          	endbr32 
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d00:	6a 00                	push   $0x0
  800d02:	6a 00                	push   $0x0
  800d04:	6a 00                	push   $0x0
  800d06:	ff 75 0c             	pushl  0xc(%ebp)
  800d09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0c:	ba 01 00 00 00       	mov    $0x1,%edx
  800d11:	b8 08 00 00 00       	mov    $0x8,%eax
  800d16:	e8 4e fe ff ff       	call   800b69 <syscall>
}
  800d1b:	c9                   	leave  
  800d1c:	c3                   	ret    

00800d1d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d1d:	f3 0f 1e fb          	endbr32 
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d27:	6a 00                	push   $0x0
  800d29:	6a 00                	push   $0x0
  800d2b:	6a 00                	push   $0x0
  800d2d:	ff 75 0c             	pushl  0xc(%ebp)
  800d30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d33:	ba 01 00 00 00       	mov    $0x1,%edx
  800d38:	b8 09 00 00 00       	mov    $0x9,%eax
  800d3d:	e8 27 fe ff ff       	call   800b69 <syscall>
}
  800d42:	c9                   	leave  
  800d43:	c3                   	ret    

00800d44 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d44:	f3 0f 1e fb          	endbr32 
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d4e:	6a 00                	push   $0x0
  800d50:	6a 00                	push   $0x0
  800d52:	6a 00                	push   $0x0
  800d54:	ff 75 0c             	pushl  0xc(%ebp)
  800d57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5a:	ba 01 00 00 00       	mov    $0x1,%edx
  800d5f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d64:	e8 00 fe ff ff       	call   800b69 <syscall>
}
  800d69:	c9                   	leave  
  800d6a:	c3                   	ret    

00800d6b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d6b:	f3 0f 1e fb          	endbr32 
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d75:	6a 00                	push   $0x0
  800d77:	ff 75 14             	pushl  0x14(%ebp)
  800d7a:	ff 75 10             	pushl  0x10(%ebp)
  800d7d:	ff 75 0c             	pushl  0xc(%ebp)
  800d80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d83:	ba 00 00 00 00       	mov    $0x0,%edx
  800d88:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8d:	e8 d7 fd ff ff       	call   800b69 <syscall>
}
  800d92:	c9                   	leave  
  800d93:	c3                   	ret    

00800d94 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d94:	f3 0f 1e fb          	endbr32 
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d9e:	6a 00                	push   $0x0
  800da0:	6a 00                	push   $0x0
  800da2:	6a 00                	push   $0x0
  800da4:	6a 00                	push   $0x0
  800da6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da9:	ba 01 00 00 00       	mov    $0x1,%edx
  800dae:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db3:	e8 b1 fd ff ff       	call   800b69 <syscall>
}
  800db8:	c9                   	leave  
  800db9:	c3                   	ret    

00800dba <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dba:	f3 0f 1e fb          	endbr32 
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc4:	05 00 00 00 30       	add    $0x30000000,%eax
  800dc9:	c1 e8 0c             	shr    $0xc,%eax
}
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dce:	f3 0f 1e fb          	endbr32 
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800dd8:	ff 75 08             	pushl  0x8(%ebp)
  800ddb:	e8 da ff ff ff       	call   800dba <fd2num>
  800de0:	83 c4 10             	add    $0x10,%esp
  800de3:	c1 e0 0c             	shl    $0xc,%eax
  800de6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800deb:	c9                   	leave  
  800dec:	c3                   	ret    

00800ded <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ded:	f3 0f 1e fb          	endbr32 
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800df9:	89 c2                	mov    %eax,%edx
  800dfb:	c1 ea 16             	shr    $0x16,%edx
  800dfe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e05:	f6 c2 01             	test   $0x1,%dl
  800e08:	74 2d                	je     800e37 <fd_alloc+0x4a>
  800e0a:	89 c2                	mov    %eax,%edx
  800e0c:	c1 ea 0c             	shr    $0xc,%edx
  800e0f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e16:	f6 c2 01             	test   $0x1,%dl
  800e19:	74 1c                	je     800e37 <fd_alloc+0x4a>
  800e1b:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e20:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e25:	75 d2                	jne    800df9 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e27:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e30:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e35:	eb 0a                	jmp    800e41 <fd_alloc+0x54>
			*fd_store = fd;
  800e37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e43:	f3 0f 1e fb          	endbr32 
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e4d:	83 f8 1f             	cmp    $0x1f,%eax
  800e50:	77 30                	ja     800e82 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e52:	c1 e0 0c             	shl    $0xc,%eax
  800e55:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e5a:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e60:	f6 c2 01             	test   $0x1,%dl
  800e63:	74 24                	je     800e89 <fd_lookup+0x46>
  800e65:	89 c2                	mov    %eax,%edx
  800e67:	c1 ea 0c             	shr    $0xc,%edx
  800e6a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e71:	f6 c2 01             	test   $0x1,%dl
  800e74:	74 1a                	je     800e90 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e79:	89 02                	mov    %eax,(%edx)
	return 0;
  800e7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
		return -E_INVAL;
  800e82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e87:	eb f7                	jmp    800e80 <fd_lookup+0x3d>
		return -E_INVAL;
  800e89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e8e:	eb f0                	jmp    800e80 <fd_lookup+0x3d>
  800e90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e95:	eb e9                	jmp    800e80 <fd_lookup+0x3d>

00800e97 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e97:	f3 0f 1e fb          	endbr32 
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	83 ec 08             	sub    $0x8,%esp
  800ea1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea4:	ba 88 29 80 00       	mov    $0x802988,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ea9:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800eae:	39 08                	cmp    %ecx,(%eax)
  800eb0:	74 33                	je     800ee5 <dev_lookup+0x4e>
  800eb2:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800eb5:	8b 02                	mov    (%edx),%eax
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	75 f3                	jne    800eae <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ebb:	a1 04 40 80 00       	mov    0x804004,%eax
  800ec0:	8b 40 48             	mov    0x48(%eax),%eax
  800ec3:	83 ec 04             	sub    $0x4,%esp
  800ec6:	51                   	push   %ecx
  800ec7:	50                   	push   %eax
  800ec8:	68 0c 29 80 00       	push   $0x80290c
  800ecd:	e8 b9 f3 ff ff       	call   80028b <cprintf>
	*dev = 0;
  800ed2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800edb:	83 c4 10             	add    $0x10,%esp
  800ede:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ee3:	c9                   	leave  
  800ee4:	c3                   	ret    
			*dev = devtab[i];
  800ee5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eea:	b8 00 00 00 00       	mov    $0x0,%eax
  800eef:	eb f2                	jmp    800ee3 <dev_lookup+0x4c>

00800ef1 <fd_close>:
{
  800ef1:	f3 0f 1e fb          	endbr32 
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	57                   	push   %edi
  800ef9:	56                   	push   %esi
  800efa:	53                   	push   %ebx
  800efb:	83 ec 28             	sub    $0x28,%esp
  800efe:	8b 75 08             	mov    0x8(%ebp),%esi
  800f01:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f04:	56                   	push   %esi
  800f05:	e8 b0 fe ff ff       	call   800dba <fd2num>
  800f0a:	83 c4 08             	add    $0x8,%esp
  800f0d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800f10:	52                   	push   %edx
  800f11:	50                   	push   %eax
  800f12:	e8 2c ff ff ff       	call   800e43 <fd_lookup>
  800f17:	89 c3                	mov    %eax,%ebx
  800f19:	83 c4 10             	add    $0x10,%esp
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	78 05                	js     800f25 <fd_close+0x34>
	    || fd != fd2)
  800f20:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f23:	74 16                	je     800f3b <fd_close+0x4a>
		return (must_exist ? r : 0);
  800f25:	89 f8                	mov    %edi,%eax
  800f27:	84 c0                	test   %al,%al
  800f29:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2e:	0f 44 d8             	cmove  %eax,%ebx
}
  800f31:	89 d8                	mov    %ebx,%eax
  800f33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f36:	5b                   	pop    %ebx
  800f37:	5e                   	pop    %esi
  800f38:	5f                   	pop    %edi
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f3b:	83 ec 08             	sub    $0x8,%esp
  800f3e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f41:	50                   	push   %eax
  800f42:	ff 36                	pushl  (%esi)
  800f44:	e8 4e ff ff ff       	call   800e97 <dev_lookup>
  800f49:	89 c3                	mov    %eax,%ebx
  800f4b:	83 c4 10             	add    $0x10,%esp
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	78 1a                	js     800f6c <fd_close+0x7b>
		if (dev->dev_close)
  800f52:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f55:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f58:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	74 0b                	je     800f6c <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	56                   	push   %esi
  800f65:	ff d0                	call   *%eax
  800f67:	89 c3                	mov    %eax,%ebx
  800f69:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f6c:	83 ec 08             	sub    $0x8,%esp
  800f6f:	56                   	push   %esi
  800f70:	6a 00                	push   $0x0
  800f72:	e8 58 fd ff ff       	call   800ccf <sys_page_unmap>
	return r;
  800f77:	83 c4 10             	add    $0x10,%esp
  800f7a:	eb b5                	jmp    800f31 <fd_close+0x40>

00800f7c <close>:

int
close(int fdnum)
{
  800f7c:	f3 0f 1e fb          	endbr32 
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f89:	50                   	push   %eax
  800f8a:	ff 75 08             	pushl  0x8(%ebp)
  800f8d:	e8 b1 fe ff ff       	call   800e43 <fd_lookup>
  800f92:	83 c4 10             	add    $0x10,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	79 02                	jns    800f9b <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800f99:	c9                   	leave  
  800f9a:	c3                   	ret    
		return fd_close(fd, 1);
  800f9b:	83 ec 08             	sub    $0x8,%esp
  800f9e:	6a 01                	push   $0x1
  800fa0:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa3:	e8 49 ff ff ff       	call   800ef1 <fd_close>
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	eb ec                	jmp    800f99 <close+0x1d>

00800fad <close_all>:

void
close_all(void)
{
  800fad:	f3 0f 1e fb          	endbr32 
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	53                   	push   %ebx
  800fb5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fbd:	83 ec 0c             	sub    $0xc,%esp
  800fc0:	53                   	push   %ebx
  800fc1:	e8 b6 ff ff ff       	call   800f7c <close>
	for (i = 0; i < MAXFD; i++)
  800fc6:	83 c3 01             	add    $0x1,%ebx
  800fc9:	83 c4 10             	add    $0x10,%esp
  800fcc:	83 fb 20             	cmp    $0x20,%ebx
  800fcf:	75 ec                	jne    800fbd <close_all+0x10>
}
  800fd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fd6:	f3 0f 1e fb          	endbr32 
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	57                   	push   %edi
  800fde:	56                   	push   %esi
  800fdf:	53                   	push   %ebx
  800fe0:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fe3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fe6:	50                   	push   %eax
  800fe7:	ff 75 08             	pushl  0x8(%ebp)
  800fea:	e8 54 fe ff ff       	call   800e43 <fd_lookup>
  800fef:	89 c3                	mov    %eax,%ebx
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	0f 88 81 00 00 00    	js     80107d <dup+0xa7>
		return r;
	close(newfdnum);
  800ffc:	83 ec 0c             	sub    $0xc,%esp
  800fff:	ff 75 0c             	pushl  0xc(%ebp)
  801002:	e8 75 ff ff ff       	call   800f7c <close>

	newfd = INDEX2FD(newfdnum);
  801007:	8b 75 0c             	mov    0xc(%ebp),%esi
  80100a:	c1 e6 0c             	shl    $0xc,%esi
  80100d:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801013:	83 c4 04             	add    $0x4,%esp
  801016:	ff 75 e4             	pushl  -0x1c(%ebp)
  801019:	e8 b0 fd ff ff       	call   800dce <fd2data>
  80101e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801020:	89 34 24             	mov    %esi,(%esp)
  801023:	e8 a6 fd ff ff       	call   800dce <fd2data>
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80102d:	89 d8                	mov    %ebx,%eax
  80102f:	c1 e8 16             	shr    $0x16,%eax
  801032:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801039:	a8 01                	test   $0x1,%al
  80103b:	74 11                	je     80104e <dup+0x78>
  80103d:	89 d8                	mov    %ebx,%eax
  80103f:	c1 e8 0c             	shr    $0xc,%eax
  801042:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801049:	f6 c2 01             	test   $0x1,%dl
  80104c:	75 39                	jne    801087 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80104e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801051:	89 d0                	mov    %edx,%eax
  801053:	c1 e8 0c             	shr    $0xc,%eax
  801056:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105d:	83 ec 0c             	sub    $0xc,%esp
  801060:	25 07 0e 00 00       	and    $0xe07,%eax
  801065:	50                   	push   %eax
  801066:	56                   	push   %esi
  801067:	6a 00                	push   $0x0
  801069:	52                   	push   %edx
  80106a:	6a 00                	push   $0x0
  80106c:	e8 34 fc ff ff       	call   800ca5 <sys_page_map>
  801071:	89 c3                	mov    %eax,%ebx
  801073:	83 c4 20             	add    $0x20,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 31                	js     8010ab <dup+0xd5>
		goto err;

	return newfdnum;
  80107a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80107d:	89 d8                	mov    %ebx,%eax
  80107f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801082:	5b                   	pop    %ebx
  801083:	5e                   	pop    %esi
  801084:	5f                   	pop    %edi
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801087:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108e:	83 ec 0c             	sub    $0xc,%esp
  801091:	25 07 0e 00 00       	and    $0xe07,%eax
  801096:	50                   	push   %eax
  801097:	57                   	push   %edi
  801098:	6a 00                	push   $0x0
  80109a:	53                   	push   %ebx
  80109b:	6a 00                	push   $0x0
  80109d:	e8 03 fc ff ff       	call   800ca5 <sys_page_map>
  8010a2:	89 c3                	mov    %eax,%ebx
  8010a4:	83 c4 20             	add    $0x20,%esp
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	79 a3                	jns    80104e <dup+0x78>
	sys_page_unmap(0, newfd);
  8010ab:	83 ec 08             	sub    $0x8,%esp
  8010ae:	56                   	push   %esi
  8010af:	6a 00                	push   $0x0
  8010b1:	e8 19 fc ff ff       	call   800ccf <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010b6:	83 c4 08             	add    $0x8,%esp
  8010b9:	57                   	push   %edi
  8010ba:	6a 00                	push   $0x0
  8010bc:	e8 0e fc ff ff       	call   800ccf <sys_page_unmap>
	return r;
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	eb b7                	jmp    80107d <dup+0xa7>

008010c6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010c6:	f3 0f 1e fb          	endbr32 
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	53                   	push   %ebx
  8010ce:	83 ec 1c             	sub    $0x1c,%esp
  8010d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d7:	50                   	push   %eax
  8010d8:	53                   	push   %ebx
  8010d9:	e8 65 fd ff ff       	call   800e43 <fd_lookup>
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	78 3f                	js     801124 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e5:	83 ec 08             	sub    $0x8,%esp
  8010e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010eb:	50                   	push   %eax
  8010ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ef:	ff 30                	pushl  (%eax)
  8010f1:	e8 a1 fd ff ff       	call   800e97 <dev_lookup>
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	78 27                	js     801124 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801100:	8b 42 08             	mov    0x8(%edx),%eax
  801103:	83 e0 03             	and    $0x3,%eax
  801106:	83 f8 01             	cmp    $0x1,%eax
  801109:	74 1e                	je     801129 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80110b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110e:	8b 40 08             	mov    0x8(%eax),%eax
  801111:	85 c0                	test   %eax,%eax
  801113:	74 35                	je     80114a <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801115:	83 ec 04             	sub    $0x4,%esp
  801118:	ff 75 10             	pushl  0x10(%ebp)
  80111b:	ff 75 0c             	pushl  0xc(%ebp)
  80111e:	52                   	push   %edx
  80111f:	ff d0                	call   *%eax
  801121:	83 c4 10             	add    $0x10,%esp
}
  801124:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801127:	c9                   	leave  
  801128:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801129:	a1 04 40 80 00       	mov    0x804004,%eax
  80112e:	8b 40 48             	mov    0x48(%eax),%eax
  801131:	83 ec 04             	sub    $0x4,%esp
  801134:	53                   	push   %ebx
  801135:	50                   	push   %eax
  801136:	68 4d 29 80 00       	push   $0x80294d
  80113b:	e8 4b f1 ff ff       	call   80028b <cprintf>
		return -E_INVAL;
  801140:	83 c4 10             	add    $0x10,%esp
  801143:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801148:	eb da                	jmp    801124 <read+0x5e>
		return -E_NOT_SUPP;
  80114a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80114f:	eb d3                	jmp    801124 <read+0x5e>

00801151 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801151:	f3 0f 1e fb          	endbr32 
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	57                   	push   %edi
  801159:	56                   	push   %esi
  80115a:	53                   	push   %ebx
  80115b:	83 ec 0c             	sub    $0xc,%esp
  80115e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801161:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801164:	bb 00 00 00 00       	mov    $0x0,%ebx
  801169:	eb 02                	jmp    80116d <readn+0x1c>
  80116b:	01 c3                	add    %eax,%ebx
  80116d:	39 f3                	cmp    %esi,%ebx
  80116f:	73 21                	jae    801192 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801171:	83 ec 04             	sub    $0x4,%esp
  801174:	89 f0                	mov    %esi,%eax
  801176:	29 d8                	sub    %ebx,%eax
  801178:	50                   	push   %eax
  801179:	89 d8                	mov    %ebx,%eax
  80117b:	03 45 0c             	add    0xc(%ebp),%eax
  80117e:	50                   	push   %eax
  80117f:	57                   	push   %edi
  801180:	e8 41 ff ff ff       	call   8010c6 <read>
		if (m < 0)
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	85 c0                	test   %eax,%eax
  80118a:	78 04                	js     801190 <readn+0x3f>
			return m;
		if (m == 0)
  80118c:	75 dd                	jne    80116b <readn+0x1a>
  80118e:	eb 02                	jmp    801192 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801190:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801192:	89 d8                	mov    %ebx,%eax
  801194:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801197:	5b                   	pop    %ebx
  801198:	5e                   	pop    %esi
  801199:	5f                   	pop    %edi
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80119c:	f3 0f 1e fb          	endbr32 
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	53                   	push   %ebx
  8011a4:	83 ec 1c             	sub    $0x1c,%esp
  8011a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ad:	50                   	push   %eax
  8011ae:	53                   	push   %ebx
  8011af:	e8 8f fc ff ff       	call   800e43 <fd_lookup>
  8011b4:	83 c4 10             	add    $0x10,%esp
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	78 3a                	js     8011f5 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011bb:	83 ec 08             	sub    $0x8,%esp
  8011be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c1:	50                   	push   %eax
  8011c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c5:	ff 30                	pushl  (%eax)
  8011c7:	e8 cb fc ff ff       	call   800e97 <dev_lookup>
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 22                	js     8011f5 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011da:	74 1e                	je     8011fa <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011df:	8b 52 0c             	mov    0xc(%edx),%edx
  8011e2:	85 d2                	test   %edx,%edx
  8011e4:	74 35                	je     80121b <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011e6:	83 ec 04             	sub    $0x4,%esp
  8011e9:	ff 75 10             	pushl  0x10(%ebp)
  8011ec:	ff 75 0c             	pushl  0xc(%ebp)
  8011ef:	50                   	push   %eax
  8011f0:	ff d2                	call   *%edx
  8011f2:	83 c4 10             	add    $0x10,%esp
}
  8011f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ff:	8b 40 48             	mov    0x48(%eax),%eax
  801202:	83 ec 04             	sub    $0x4,%esp
  801205:	53                   	push   %ebx
  801206:	50                   	push   %eax
  801207:	68 69 29 80 00       	push   $0x802969
  80120c:	e8 7a f0 ff ff       	call   80028b <cprintf>
		return -E_INVAL;
  801211:	83 c4 10             	add    $0x10,%esp
  801214:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801219:	eb da                	jmp    8011f5 <write+0x59>
		return -E_NOT_SUPP;
  80121b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801220:	eb d3                	jmp    8011f5 <write+0x59>

00801222 <seek>:

int
seek(int fdnum, off_t offset)
{
  801222:	f3 0f 1e fb          	endbr32 
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80122c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122f:	50                   	push   %eax
  801230:	ff 75 08             	pushl  0x8(%ebp)
  801233:	e8 0b fc ff ff       	call   800e43 <fd_lookup>
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	78 0e                	js     80124d <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80123f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801242:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801245:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801248:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80124d:	c9                   	leave  
  80124e:	c3                   	ret    

0080124f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80124f:	f3 0f 1e fb          	endbr32 
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	53                   	push   %ebx
  801257:	83 ec 1c             	sub    $0x1c,%esp
  80125a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801260:	50                   	push   %eax
  801261:	53                   	push   %ebx
  801262:	e8 dc fb ff ff       	call   800e43 <fd_lookup>
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 37                	js     8012a5 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126e:	83 ec 08             	sub    $0x8,%esp
  801271:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801274:	50                   	push   %eax
  801275:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801278:	ff 30                	pushl  (%eax)
  80127a:	e8 18 fc ff ff       	call   800e97 <dev_lookup>
  80127f:	83 c4 10             	add    $0x10,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	78 1f                	js     8012a5 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801286:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801289:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80128d:	74 1b                	je     8012aa <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80128f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801292:	8b 52 18             	mov    0x18(%edx),%edx
  801295:	85 d2                	test   %edx,%edx
  801297:	74 32                	je     8012cb <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801299:	83 ec 08             	sub    $0x8,%esp
  80129c:	ff 75 0c             	pushl  0xc(%ebp)
  80129f:	50                   	push   %eax
  8012a0:	ff d2                	call   *%edx
  8012a2:	83 c4 10             	add    $0x10,%esp
}
  8012a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a8:	c9                   	leave  
  8012a9:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012aa:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012af:	8b 40 48             	mov    0x48(%eax),%eax
  8012b2:	83 ec 04             	sub    $0x4,%esp
  8012b5:	53                   	push   %ebx
  8012b6:	50                   	push   %eax
  8012b7:	68 2c 29 80 00       	push   $0x80292c
  8012bc:	e8 ca ef ff ff       	call   80028b <cprintf>
		return -E_INVAL;
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c9:	eb da                	jmp    8012a5 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8012cb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012d0:	eb d3                	jmp    8012a5 <ftruncate+0x56>

008012d2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012d2:	f3 0f 1e fb          	endbr32 
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	53                   	push   %ebx
  8012da:	83 ec 1c             	sub    $0x1c,%esp
  8012dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e3:	50                   	push   %eax
  8012e4:	ff 75 08             	pushl  0x8(%ebp)
  8012e7:	e8 57 fb ff ff       	call   800e43 <fd_lookup>
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 4b                	js     80133e <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f3:	83 ec 08             	sub    $0x8,%esp
  8012f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f9:	50                   	push   %eax
  8012fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fd:	ff 30                	pushl  (%eax)
  8012ff:	e8 93 fb ff ff       	call   800e97 <dev_lookup>
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	85 c0                	test   %eax,%eax
  801309:	78 33                	js     80133e <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80130b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801312:	74 2f                	je     801343 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801314:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801317:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80131e:	00 00 00 
	stat->st_isdir = 0;
  801321:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801328:	00 00 00 
	stat->st_dev = dev;
  80132b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801331:	83 ec 08             	sub    $0x8,%esp
  801334:	53                   	push   %ebx
  801335:	ff 75 f0             	pushl  -0x10(%ebp)
  801338:	ff 50 14             	call   *0x14(%eax)
  80133b:	83 c4 10             	add    $0x10,%esp
}
  80133e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801341:	c9                   	leave  
  801342:	c3                   	ret    
		return -E_NOT_SUPP;
  801343:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801348:	eb f4                	jmp    80133e <fstat+0x6c>

0080134a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80134a:	f3 0f 1e fb          	endbr32 
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	56                   	push   %esi
  801352:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801353:	83 ec 08             	sub    $0x8,%esp
  801356:	6a 00                	push   $0x0
  801358:	ff 75 08             	pushl  0x8(%ebp)
  80135b:	e8 20 02 00 00       	call   801580 <open>
  801360:	89 c3                	mov    %eax,%ebx
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	85 c0                	test   %eax,%eax
  801367:	78 1b                	js     801384 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801369:	83 ec 08             	sub    $0x8,%esp
  80136c:	ff 75 0c             	pushl  0xc(%ebp)
  80136f:	50                   	push   %eax
  801370:	e8 5d ff ff ff       	call   8012d2 <fstat>
  801375:	89 c6                	mov    %eax,%esi
	close(fd);
  801377:	89 1c 24             	mov    %ebx,(%esp)
  80137a:	e8 fd fb ff ff       	call   800f7c <close>
	return r;
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	89 f3                	mov    %esi,%ebx
}
  801384:	89 d8                	mov    %ebx,%eax
  801386:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801389:	5b                   	pop    %ebx
  80138a:	5e                   	pop    %esi
  80138b:	5d                   	pop    %ebp
  80138c:	c3                   	ret    

0080138d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	56                   	push   %esi
  801391:	53                   	push   %ebx
  801392:	89 c6                	mov    %eax,%esi
  801394:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801396:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80139d:	74 27                	je     8013c6 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80139f:	6a 07                	push   $0x7
  8013a1:	68 00 50 80 00       	push   $0x805000
  8013a6:	56                   	push   %esi
  8013a7:	ff 35 00 40 80 00    	pushl  0x804000
  8013ad:	e8 eb 0d 00 00       	call   80219d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013b2:	83 c4 0c             	add    $0xc,%esp
  8013b5:	6a 00                	push   $0x0
  8013b7:	53                   	push   %ebx
  8013b8:	6a 00                	push   $0x0
  8013ba:	e8 71 0d 00 00       	call   802130 <ipc_recv>
}
  8013bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c2:	5b                   	pop    %ebx
  8013c3:	5e                   	pop    %esi
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013c6:	83 ec 0c             	sub    $0xc,%esp
  8013c9:	6a 01                	push   $0x1
  8013cb:	e8 20 0e 00 00       	call   8021f0 <ipc_find_env>
  8013d0:	a3 00 40 80 00       	mov    %eax,0x804000
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	eb c5                	jmp    80139f <fsipc+0x12>

008013da <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013da:	f3 0f 1e fb          	endbr32 
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ea:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fc:	b8 02 00 00 00       	mov    $0x2,%eax
  801401:	e8 87 ff ff ff       	call   80138d <fsipc>
}
  801406:	c9                   	leave  
  801407:	c3                   	ret    

00801408 <devfile_flush>:
{
  801408:	f3 0f 1e fb          	endbr32 
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801412:	8b 45 08             	mov    0x8(%ebp),%eax
  801415:	8b 40 0c             	mov    0xc(%eax),%eax
  801418:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80141d:	ba 00 00 00 00       	mov    $0x0,%edx
  801422:	b8 06 00 00 00       	mov    $0x6,%eax
  801427:	e8 61 ff ff ff       	call   80138d <fsipc>
}
  80142c:	c9                   	leave  
  80142d:	c3                   	ret    

0080142e <devfile_stat>:
{
  80142e:	f3 0f 1e fb          	endbr32 
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	53                   	push   %ebx
  801436:	83 ec 04             	sub    $0x4,%esp
  801439:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80143c:	8b 45 08             	mov    0x8(%ebp),%eax
  80143f:	8b 40 0c             	mov    0xc(%eax),%eax
  801442:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801447:	ba 00 00 00 00       	mov    $0x0,%edx
  80144c:	b8 05 00 00 00       	mov    $0x5,%eax
  801451:	e8 37 ff ff ff       	call   80138d <fsipc>
  801456:	85 c0                	test   %eax,%eax
  801458:	78 2c                	js     801486 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80145a:	83 ec 08             	sub    $0x8,%esp
  80145d:	68 00 50 80 00       	push   $0x805000
  801462:	53                   	push   %ebx
  801463:	e8 8d f3 ff ff       	call   8007f5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801468:	a1 80 50 80 00       	mov    0x805080,%eax
  80146d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801473:	a1 84 50 80 00       	mov    0x805084,%eax
  801478:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801486:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801489:	c9                   	leave  
  80148a:	c3                   	ret    

0080148b <devfile_write>:
{
  80148b:	f3 0f 1e fb          	endbr32 
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	57                   	push   %edi
  801493:	56                   	push   %esi
  801494:	53                   	push   %ebx
  801495:	83 ec 0c             	sub    $0xc,%esp
  801498:	8b 75 0c             	mov    0xc(%ebp),%esi
  80149b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80149e:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a4:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  8014a9:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8014ae:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  8014b3:	85 db                	test   %ebx,%ebx
  8014b5:	74 3b                	je     8014f2 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8014b7:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8014bd:	89 f8                	mov    %edi,%eax
  8014bf:	0f 46 c3             	cmovbe %ebx,%eax
  8014c2:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  8014c7:	83 ec 04             	sub    $0x4,%esp
  8014ca:	50                   	push   %eax
  8014cb:	56                   	push   %esi
  8014cc:	68 08 50 80 00       	push   $0x805008
  8014d1:	e8 d7 f4 ff ff       	call   8009ad <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8014d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014db:	b8 04 00 00 00       	mov    $0x4,%eax
  8014e0:	e8 a8 fe ff ff       	call   80138d <fsipc>
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 06                	js     8014f2 <devfile_write+0x67>
		buf_aux += r;
  8014ec:	01 c6                	add    %eax,%esi
		n -= r;
  8014ee:	29 c3                	sub    %eax,%ebx
  8014f0:	eb c1                	jmp    8014b3 <devfile_write+0x28>
}
  8014f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f5:	5b                   	pop    %ebx
  8014f6:	5e                   	pop    %esi
  8014f7:	5f                   	pop    %edi
  8014f8:	5d                   	pop    %ebp
  8014f9:	c3                   	ret    

008014fa <devfile_read>:
{
  8014fa:	f3 0f 1e fb          	endbr32 
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	56                   	push   %esi
  801502:	53                   	push   %ebx
  801503:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801506:	8b 45 08             	mov    0x8(%ebp),%eax
  801509:	8b 40 0c             	mov    0xc(%eax),%eax
  80150c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801511:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801517:	ba 00 00 00 00       	mov    $0x0,%edx
  80151c:	b8 03 00 00 00       	mov    $0x3,%eax
  801521:	e8 67 fe ff ff       	call   80138d <fsipc>
  801526:	89 c3                	mov    %eax,%ebx
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 1f                	js     80154b <devfile_read+0x51>
	assert(r <= n);
  80152c:	39 f0                	cmp    %esi,%eax
  80152e:	77 24                	ja     801554 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801530:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801535:	7f 33                	jg     80156a <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801537:	83 ec 04             	sub    $0x4,%esp
  80153a:	50                   	push   %eax
  80153b:	68 00 50 80 00       	push   $0x805000
  801540:	ff 75 0c             	pushl  0xc(%ebp)
  801543:	e8 65 f4 ff ff       	call   8009ad <memmove>
	return r;
  801548:	83 c4 10             	add    $0x10,%esp
}
  80154b:	89 d8                	mov    %ebx,%eax
  80154d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801550:	5b                   	pop    %ebx
  801551:	5e                   	pop    %esi
  801552:	5d                   	pop    %ebp
  801553:	c3                   	ret    
	assert(r <= n);
  801554:	68 98 29 80 00       	push   $0x802998
  801559:	68 9f 29 80 00       	push   $0x80299f
  80155e:	6a 7c                	push   $0x7c
  801560:	68 b4 29 80 00       	push   $0x8029b4
  801565:	e8 3a ec ff ff       	call   8001a4 <_panic>
	assert(r <= PGSIZE);
  80156a:	68 bf 29 80 00       	push   $0x8029bf
  80156f:	68 9f 29 80 00       	push   $0x80299f
  801574:	6a 7d                	push   $0x7d
  801576:	68 b4 29 80 00       	push   $0x8029b4
  80157b:	e8 24 ec ff ff       	call   8001a4 <_panic>

00801580 <open>:
{
  801580:	f3 0f 1e fb          	endbr32 
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	56                   	push   %esi
  801588:	53                   	push   %ebx
  801589:	83 ec 1c             	sub    $0x1c,%esp
  80158c:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80158f:	56                   	push   %esi
  801590:	e8 1d f2 ff ff       	call   8007b2 <strlen>
  801595:	83 c4 10             	add    $0x10,%esp
  801598:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80159d:	7f 6c                	jg     80160b <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80159f:	83 ec 0c             	sub    $0xc,%esp
  8015a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	e8 42 f8 ff ff       	call   800ded <fd_alloc>
  8015ab:	89 c3                	mov    %eax,%ebx
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	78 3c                	js     8015f0 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8015b4:	83 ec 08             	sub    $0x8,%esp
  8015b7:	56                   	push   %esi
  8015b8:	68 00 50 80 00       	push   $0x805000
  8015bd:	e8 33 f2 ff ff       	call   8007f5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c5:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d2:	e8 b6 fd ff ff       	call   80138d <fsipc>
  8015d7:	89 c3                	mov    %eax,%ebx
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 19                	js     8015f9 <open+0x79>
	return fd2num(fd);
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e6:	e8 cf f7 ff ff       	call   800dba <fd2num>
  8015eb:	89 c3                	mov    %eax,%ebx
  8015ed:	83 c4 10             	add    $0x10,%esp
}
  8015f0:	89 d8                	mov    %ebx,%eax
  8015f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f5:	5b                   	pop    %ebx
  8015f6:	5e                   	pop    %esi
  8015f7:	5d                   	pop    %ebp
  8015f8:	c3                   	ret    
		fd_close(fd, 0);
  8015f9:	83 ec 08             	sub    $0x8,%esp
  8015fc:	6a 00                	push   $0x0
  8015fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801601:	e8 eb f8 ff ff       	call   800ef1 <fd_close>
		return r;
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	eb e5                	jmp    8015f0 <open+0x70>
		return -E_BAD_PATH;
  80160b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801610:	eb de                	jmp    8015f0 <open+0x70>

00801612 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801612:	f3 0f 1e fb          	endbr32 
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80161c:	ba 00 00 00 00       	mov    $0x0,%edx
  801621:	b8 08 00 00 00       	mov    $0x8,%eax
  801626:	e8 62 fd ff ff       	call   80138d <fsipc>
}
  80162b:	c9                   	leave  
  80162c:	c3                   	ret    

0080162d <copy_shared_pages>:
}

// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
  80162d:	55                   	push   %ebp
  80162e:	89 e5                	mov    %esp,%ebp
  801630:	56                   	push   %esi
  801631:	53                   	push   %ebx
  801632:	89 c6                	mov    %eax,%esi
	// LAB 5: Your code here.
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801634:	bb 00 00 00 00       	mov    $0x0,%ebx
  801639:	eb 33                	jmp    80166e <copy_shared_pages+0x41>
			     0)) {
				sys_page_map(0,
				             (void *) addr,
				             child,
				             (void *) addr,
				             (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  80163b:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
				sys_page_map(0,
  801642:	83 ec 0c             	sub    $0xc,%esp
  801645:	25 07 0e 00 00       	and    $0xe07,%eax
  80164a:	50                   	push   %eax
  80164b:	53                   	push   %ebx
  80164c:	56                   	push   %esi
  80164d:	53                   	push   %ebx
  80164e:	6a 00                	push   $0x0
  801650:	e8 50 f6 ff ff       	call   800ca5 <sys_page_map>
  801655:	83 c4 20             	add    $0x20,%esp
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801658:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80165e:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801664:	77 2f                	ja     801695 <copy_shared_pages+0x68>
		if (addr != UXSTACKTOP - PGSIZE) {
  801666:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80166c:	74 ea                	je     801658 <copy_shared_pages+0x2b>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80166e:	89 d8                	mov    %ebx,%eax
  801670:	c1 e8 16             	shr    $0x16,%eax
  801673:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80167a:	a8 01                	test   $0x1,%al
  80167c:	74 da                	je     801658 <copy_shared_pages+0x2b>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U | PTE_SHARE)) ==
  80167e:	89 da                	mov    %ebx,%edx
  801680:	c1 ea 0c             	shr    $0xc,%edx
  801683:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80168a:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80168c:	a9 05 04 00 00       	test   $0x405,%eax
  801691:	75 c5                	jne    801658 <copy_shared_pages+0x2b>
  801693:	eb a6                	jmp    80163b <copy_shared_pages+0xe>
			}
		}
	}
	return 0;
}
  801695:	b8 00 00 00 00       	mov    $0x0,%eax
  80169a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169d:	5b                   	pop    %ebx
  80169e:	5e                   	pop    %esi
  80169f:	5d                   	pop    %ebp
  8016a0:	c3                   	ret    

008016a1 <init_stack>:
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	57                   	push   %edi
  8016a5:	56                   	push   %esi
  8016a6:	53                   	push   %ebx
  8016a7:	83 ec 2c             	sub    $0x2c,%esp
  8016aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8016ad:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8016b0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (argc = 0; argv[argc] != 0; argc++)
  8016b3:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  8016b8:	be 00 00 00 00       	mov    $0x0,%esi
  8016bd:	89 d7                	mov    %edx,%edi
  8016bf:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
	for (argc = 0; argv[argc] != 0; argc++)
  8016c6:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	74 15                	je     8016e2 <init_stack+0x41>
		string_size += strlen(argv[argc]) + 1;
  8016cd:	83 ec 0c             	sub    $0xc,%esp
  8016d0:	50                   	push   %eax
  8016d1:	e8 dc f0 ff ff       	call   8007b2 <strlen>
  8016d6:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8016da:	83 c3 01             	add    $0x1,%ebx
  8016dd:	83 c4 10             	add    $0x10,%esp
  8016e0:	eb dd                	jmp    8016bf <init_stack+0x1e>
  8016e2:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8016e5:	89 4d d8             	mov    %ecx,-0x28(%ebp)
	string_store = (char *) UTEMP + PGSIZE - string_size;
  8016e8:	bf 00 10 40 00       	mov    $0x401000,%edi
  8016ed:	29 f7                	sub    %esi,%edi
	argv_store = (uintptr_t *) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8016ef:	89 fa                	mov    %edi,%edx
  8016f1:	83 e2 fc             	and    $0xfffffffc,%edx
  8016f4:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8016fb:	29 c2                	sub    %eax,%edx
  8016fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	if ((void *) (argv_store - 2) < (void *) UTEMP)
  801700:	8d 42 f8             	lea    -0x8(%edx),%eax
  801703:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801708:	0f 86 06 01 00 00    	jbe    801814 <init_stack+0x173>
	if ((r = sys_page_alloc(0, (void *) UTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  80170e:	83 ec 04             	sub    $0x4,%esp
  801711:	6a 07                	push   $0x7
  801713:	68 00 00 40 00       	push   $0x400000
  801718:	6a 00                	push   $0x0
  80171a:	e8 5e f5 ff ff       	call   800c7d <sys_page_alloc>
  80171f:	89 c6                	mov    %eax,%esi
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	85 c0                	test   %eax,%eax
  801726:	0f 88 de 00 00 00    	js     80180a <init_stack+0x169>
	for (i = 0; i < argc; i++) {
  80172c:	be 00 00 00 00       	mov    $0x0,%esi
  801731:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  801734:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801737:	39 75 e0             	cmp    %esi,-0x20(%ebp)
  80173a:	7e 2f                	jle    80176b <init_stack+0xca>
		argv_store[i] = UTEMP2USTACK(string_store);
  80173c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801742:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801745:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801748:	83 ec 08             	sub    $0x8,%esp
  80174b:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80174e:	57                   	push   %edi
  80174f:	e8 a1 f0 ff ff       	call   8007f5 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801754:	83 c4 04             	add    $0x4,%esp
  801757:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80175a:	e8 53 f0 ff ff       	call   8007b2 <strlen>
  80175f:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801763:	83 c6 01             	add    $0x1,%esi
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	eb cc                	jmp    801737 <init_stack+0x96>
	argv_store[argc] = 0;
  80176b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80176e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  801771:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char *) UTEMP + PGSIZE);
  801778:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80177e:	75 5f                	jne    8017df <init_stack+0x13e>
	argv_store[-1] = UTEMP2USTACK(argv_store);
  801780:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801783:	8d 82 00 d0 7f ee    	lea    -0x11803000(%edx),%eax
  801789:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  80178c:	89 d0                	mov    %edx,%eax
  80178e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801791:	89 4a f8             	mov    %ecx,-0x8(%edx)
	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801794:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801799:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80179c:	89 01                	mov    %eax,(%ecx)
	if ((r = sys_page_map(0,
  80179e:	83 ec 0c             	sub    $0xc,%esp
  8017a1:	6a 07                	push   $0x7
  8017a3:	68 00 d0 bf ee       	push   $0xeebfd000
  8017a8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8017ab:	68 00 00 40 00       	push   $0x400000
  8017b0:	6a 00                	push   $0x0
  8017b2:	e8 ee f4 ff ff       	call   800ca5 <sys_page_map>
  8017b7:	89 c6                	mov    %eax,%esi
  8017b9:	83 c4 20             	add    $0x20,%esp
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	78 38                	js     8017f8 <init_stack+0x157>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8017c0:	83 ec 08             	sub    $0x8,%esp
  8017c3:	68 00 00 40 00       	push   $0x400000
  8017c8:	6a 00                	push   $0x0
  8017ca:	e8 00 f5 ff ff       	call   800ccf <sys_page_unmap>
  8017cf:	89 c6                	mov    %eax,%esi
  8017d1:	83 c4 10             	add    $0x10,%esp
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	78 20                	js     8017f8 <init_stack+0x157>
	return 0;
  8017d8:	be 00 00 00 00       	mov    $0x0,%esi
  8017dd:	eb 2b                	jmp    80180a <init_stack+0x169>
	assert(string_store == (char *) UTEMP + PGSIZE);
  8017df:	68 cc 29 80 00       	push   $0x8029cc
  8017e4:	68 9f 29 80 00       	push   $0x80299f
  8017e9:	68 fc 00 00 00       	push   $0xfc
  8017ee:	68 f4 29 80 00       	push   $0x8029f4
  8017f3:	e8 ac e9 ff ff       	call   8001a4 <_panic>
	sys_page_unmap(0, UTEMP);
  8017f8:	83 ec 08             	sub    $0x8,%esp
  8017fb:	68 00 00 40 00       	push   $0x400000
  801800:	6a 00                	push   $0x0
  801802:	e8 c8 f4 ff ff       	call   800ccf <sys_page_unmap>
	return r;
  801807:	83 c4 10             	add    $0x10,%esp
}
  80180a:	89 f0                	mov    %esi,%eax
  80180c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80180f:	5b                   	pop    %ebx
  801810:	5e                   	pop    %esi
  801811:	5f                   	pop    %edi
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    
		return -E_NO_MEM;
  801814:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  801819:	eb ef                	jmp    80180a <init_stack+0x169>

0080181b <map_segment>:
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	57                   	push   %edi
  80181f:	56                   	push   %esi
  801820:	53                   	push   %ebx
  801821:	83 ec 1c             	sub    $0x1c,%esp
  801824:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801827:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80182a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80182d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((i = PGOFF(va))) {
  801830:	89 d0                	mov    %edx,%eax
  801832:	25 ff 0f 00 00       	and    $0xfff,%eax
  801837:	74 0f                	je     801848 <map_segment+0x2d>
		va -= i;
  801839:	29 c2                	sub    %eax,%edx
  80183b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		memsz += i;
  80183e:	01 c1                	add    %eax,%ecx
  801840:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		filesz += i;
  801843:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801845:	29 45 10             	sub    %eax,0x10(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801848:	bb 00 00 00 00       	mov    $0x0,%ebx
  80184d:	e9 99 00 00 00       	jmp    8018eb <map_segment+0xd0>
			if ((r = sys_page_alloc(0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  801852:	83 ec 04             	sub    $0x4,%esp
  801855:	6a 07                	push   $0x7
  801857:	68 00 00 40 00       	push   $0x400000
  80185c:	6a 00                	push   $0x0
  80185e:	e8 1a f4 ff ff       	call   800c7d <sys_page_alloc>
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	85 c0                	test   %eax,%eax
  801868:	0f 88 c1 00 00 00    	js     80192f <map_segment+0x114>
			if ((r = seek(fd, fileoffset + i)) < 0)
  80186e:	83 ec 08             	sub    $0x8,%esp
  801871:	89 f0                	mov    %esi,%eax
  801873:	03 45 10             	add    0x10(%ebp),%eax
  801876:	50                   	push   %eax
  801877:	ff 75 08             	pushl  0x8(%ebp)
  80187a:	e8 a3 f9 ff ff       	call   801222 <seek>
  80187f:	83 c4 10             	add    $0x10,%esp
  801882:	85 c0                	test   %eax,%eax
  801884:	0f 88 a5 00 00 00    	js     80192f <map_segment+0x114>
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz - i))) < 0)
  80188a:	83 ec 04             	sub    $0x4,%esp
  80188d:	89 f8                	mov    %edi,%eax
  80188f:	29 f0                	sub    %esi,%eax
  801891:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801896:	ba 00 10 00 00       	mov    $0x1000,%edx
  80189b:	0f 47 c2             	cmova  %edx,%eax
  80189e:	50                   	push   %eax
  80189f:	68 00 00 40 00       	push   $0x400000
  8018a4:	ff 75 08             	pushl  0x8(%ebp)
  8018a7:	e8 a5 f8 ff ff       	call   801151 <readn>
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 7c                	js     80192f <map_segment+0x114>
			if ((r = sys_page_map(
  8018b3:	83 ec 0c             	sub    $0xc,%esp
  8018b6:	ff 75 14             	pushl  0x14(%ebp)
  8018b9:	03 75 e0             	add    -0x20(%ebp),%esi
  8018bc:	56                   	push   %esi
  8018bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8018c0:	68 00 00 40 00       	push   $0x400000
  8018c5:	6a 00                	push   $0x0
  8018c7:	e8 d9 f3 ff ff       	call   800ca5 <sys_page_map>
  8018cc:	83 c4 20             	add    $0x20,%esp
  8018cf:	85 c0                	test   %eax,%eax
  8018d1:	78 42                	js     801915 <map_segment+0xfa>
			sys_page_unmap(0, UTEMP);
  8018d3:	83 ec 08             	sub    $0x8,%esp
  8018d6:	68 00 00 40 00       	push   $0x400000
  8018db:	6a 00                	push   $0x0
  8018dd:	e8 ed f3 ff ff       	call   800ccf <sys_page_unmap>
  8018e2:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  8018e5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8018eb:	89 de                	mov    %ebx,%esi
  8018ed:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  8018f0:	76 38                	jbe    80192a <map_segment+0x10f>
		if (i >= filesz) {
  8018f2:	39 df                	cmp    %ebx,%edi
  8018f4:	0f 87 58 ff ff ff    	ja     801852 <map_segment+0x37>
			if ((r = sys_page_alloc(child, (void *) (va + i), perm)) < 0)
  8018fa:	83 ec 04             	sub    $0x4,%esp
  8018fd:	ff 75 14             	pushl  0x14(%ebp)
  801900:	03 75 e0             	add    -0x20(%ebp),%esi
  801903:	56                   	push   %esi
  801904:	ff 75 dc             	pushl  -0x24(%ebp)
  801907:	e8 71 f3 ff ff       	call   800c7d <sys_page_alloc>
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	85 c0                	test   %eax,%eax
  801911:	79 d2                	jns    8018e5 <map_segment+0xca>
  801913:	eb 1a                	jmp    80192f <map_segment+0x114>
				panic("spawn: sys_page_map data: %e", r);
  801915:	50                   	push   %eax
  801916:	68 00 2a 80 00       	push   $0x802a00
  80191b:	68 3a 01 00 00       	push   $0x13a
  801920:	68 f4 29 80 00       	push   $0x8029f4
  801925:	e8 7a e8 ff ff       	call   8001a4 <_panic>
	return 0;
  80192a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801932:	5b                   	pop    %ebx
  801933:	5e                   	pop    %esi
  801934:	5f                   	pop    %edi
  801935:	5d                   	pop    %ebp
  801936:	c3                   	ret    

00801937 <spawn>:
{
  801937:	f3 0f 1e fb          	endbr32 
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	57                   	push   %edi
  80193f:	56                   	push   %esi
  801940:	53                   	push   %ebx
  801941:	81 ec 74 02 00 00    	sub    $0x274,%esp
	if ((r = open(prog, O_RDONLY)) < 0)
  801947:	6a 00                	push   $0x0
  801949:	ff 75 08             	pushl  0x8(%ebp)
  80194c:	e8 2f fc ff ff       	call   801580 <open>
  801951:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	85 c0                	test   %eax,%eax
  80195c:	0f 88 0b 02 00 00    	js     801b6d <spawn+0x236>
  801962:	89 c7                	mov    %eax,%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf) ||
  801964:	83 ec 04             	sub    $0x4,%esp
  801967:	68 00 02 00 00       	push   $0x200
  80196c:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801972:	50                   	push   %eax
  801973:	57                   	push   %edi
  801974:	e8 d8 f7 ff ff       	call   801151 <readn>
  801979:	83 c4 10             	add    $0x10,%esp
  80197c:	3d 00 02 00 00       	cmp    $0x200,%eax
  801981:	0f 85 85 00 00 00    	jne    801a0c <spawn+0xd5>
  801987:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80198e:	45 4c 46 
  801991:	75 79                	jne    801a0c <spawn+0xd5>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801993:	b8 07 00 00 00       	mov    $0x7,%eax
  801998:	cd 30                	int    $0x30
  80199a:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8019a0:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	if ((r = sys_exofork()) < 0)
  8019a6:	89 c3                	mov    %eax,%ebx
  8019a8:	85 c0                	test   %eax,%eax
  8019aa:	0f 88 b1 01 00 00    	js     801b61 <spawn+0x22a>
	child_tf = envs[ENVX(child)].env_tf;
  8019b0:	89 c6                	mov    %eax,%esi
  8019b2:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8019b8:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8019bb:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8019c1:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019c7:	b9 11 00 00 00       	mov    $0x11,%ecx
  8019cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8019ce:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8019d4:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
  8019da:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  8019e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019e3:	89 d8                	mov    %ebx,%eax
  8019e5:	e8 b7 fc ff ff       	call   8016a1 <init_stack>
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	0f 88 89 01 00 00    	js     801b7b <spawn+0x244>
	ph = (struct Proghdr *) (elf_buf + elf->e_phoff);
  8019f2:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8019f8:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019ff:	be 00 00 00 00       	mov    $0x0,%esi
  801a04:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801a0a:	eb 3e                	jmp    801a4a <spawn+0x113>
		close(fd);
  801a0c:	83 ec 0c             	sub    $0xc,%esp
  801a0f:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801a15:	e8 62 f5 ff ff       	call   800f7c <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a1a:	83 c4 0c             	add    $0xc,%esp
  801a1d:	68 7f 45 4c 46       	push   $0x464c457f
  801a22:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801a28:	68 1d 2a 80 00       	push   $0x802a1d
  801a2d:	e8 59 e8 ff ff       	call   80028b <cprintf>
		return -E_NOT_EXEC;
  801a32:	83 c4 10             	add    $0x10,%esp
  801a35:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  801a3c:	ff ff ff 
  801a3f:	e9 29 01 00 00       	jmp    801b6d <spawn+0x236>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a44:	83 c6 01             	add    $0x1,%esi
  801a47:	83 c3 20             	add    $0x20,%ebx
  801a4a:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a51:	39 f0                	cmp    %esi,%eax
  801a53:	7e 62                	jle    801ab7 <spawn+0x180>
		if (ph->p_type != ELF_PROG_LOAD)
  801a55:	83 3b 01             	cmpl   $0x1,(%ebx)
  801a58:	75 ea                	jne    801a44 <spawn+0x10d>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801a5a:	8b 43 18             	mov    0x18(%ebx),%eax
  801a5d:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801a60:	83 f8 01             	cmp    $0x1,%eax
  801a63:	19 c0                	sbb    %eax,%eax
  801a65:	83 e0 fe             	and    $0xfffffffe,%eax
  801a68:	83 c0 07             	add    $0x7,%eax
		if ((r = map_segment(child,
  801a6b:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801a6e:	8b 53 08             	mov    0x8(%ebx),%edx
  801a71:	50                   	push   %eax
  801a72:	ff 73 04             	pushl  0x4(%ebx)
  801a75:	ff 73 10             	pushl  0x10(%ebx)
  801a78:	57                   	push   %edi
  801a79:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801a7f:	e8 97 fd ff ff       	call   80181b <map_segment>
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	85 c0                	test   %eax,%eax
  801a89:	79 b9                	jns    801a44 <spawn+0x10d>
  801a8b:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801a8d:	83 ec 0c             	sub    $0xc,%esp
  801a90:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a96:	e8 69 f1 ff ff       	call   800c04 <sys_env_destroy>
	close(fd);
  801a9b:	83 c4 04             	add    $0x4,%esp
  801a9e:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801aa4:	e8 d3 f4 ff ff       	call   800f7c <close>
	return r;
  801aa9:	83 c4 10             	add    $0x10,%esp
		if ((r = map_segment(child,
  801aac:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return r;
  801ab2:	e9 b6 00 00 00       	jmp    801b6d <spawn+0x236>
	close(fd);
  801ab7:	83 ec 0c             	sub    $0xc,%esp
  801aba:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801ac0:	e8 b7 f4 ff ff       	call   800f7c <close>
	if ((r = copy_shared_pages(child)) < 0)
  801ac5:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801acb:	e8 5d fb ff ff       	call   80162d <copy_shared_pages>
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	78 4b                	js     801b22 <spawn+0x1eb>
	child_tf.tf_eflags |= FL_IOPL_3;  // devious: see user/faultio.c
  801ad7:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801ade:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ae1:	83 ec 08             	sub    $0x8,%esp
  801ae4:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801aea:	50                   	push   %eax
  801aeb:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801af1:	e8 27 f2 ff ff       	call   800d1d <sys_env_set_trapframe>
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	85 c0                	test   %eax,%eax
  801afb:	78 3a                	js     801b37 <spawn+0x200>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801afd:	83 ec 08             	sub    $0x8,%esp
  801b00:	6a 02                	push   $0x2
  801b02:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b08:	e8 e9 f1 ff ff       	call   800cf6 <sys_env_set_status>
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	85 c0                	test   %eax,%eax
  801b12:	78 38                	js     801b4c <spawn+0x215>
	return child;
  801b14:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801b1a:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b20:	eb 4b                	jmp    801b6d <spawn+0x236>
		panic("copy_shared_pages: %e", r);
  801b22:	50                   	push   %eax
  801b23:	68 37 2a 80 00       	push   $0x802a37
  801b28:	68 8c 00 00 00       	push   $0x8c
  801b2d:	68 f4 29 80 00       	push   $0x8029f4
  801b32:	e8 6d e6 ff ff       	call   8001a4 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801b37:	50                   	push   %eax
  801b38:	68 4d 2a 80 00       	push   $0x802a4d
  801b3d:	68 90 00 00 00       	push   $0x90
  801b42:	68 f4 29 80 00       	push   $0x8029f4
  801b47:	e8 58 e6 ff ff       	call   8001a4 <_panic>
		panic("sys_env_set_status: %e", r);
  801b4c:	50                   	push   %eax
  801b4d:	68 67 2a 80 00       	push   $0x802a67
  801b52:	68 93 00 00 00       	push   $0x93
  801b57:	68 f4 29 80 00       	push   $0x8029f4
  801b5c:	e8 43 e6 ff ff       	call   8001a4 <_panic>
		return r;
  801b61:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801b67:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
}
  801b6d:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b76:	5b                   	pop    %ebx
  801b77:	5e                   	pop    %esi
  801b78:	5f                   	pop    %edi
  801b79:	5d                   	pop    %ebp
  801b7a:	c3                   	ret    
		return r;
  801b7b:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b81:	eb ea                	jmp    801b6d <spawn+0x236>

00801b83 <spawnl>:
{
  801b83:	f3 0f 1e fb          	endbr32 
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	57                   	push   %edi
  801b8b:	56                   	push   %esi
  801b8c:	53                   	push   %ebx
  801b8d:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  801b90:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc = 0;
  801b93:	b8 00 00 00 00       	mov    $0x0,%eax
	while (va_arg(vl, void *) != NULL)
  801b98:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b9b:	83 3a 00             	cmpl   $0x0,(%edx)
  801b9e:	74 07                	je     801ba7 <spawnl+0x24>
		argc++;
  801ba0:	83 c0 01             	add    $0x1,%eax
	while (va_arg(vl, void *) != NULL)
  801ba3:	89 ca                	mov    %ecx,%edx
  801ba5:	eb f1                	jmp    801b98 <spawnl+0x15>
	const char *argv[argc + 2];
  801ba7:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801bae:	89 d1                	mov    %edx,%ecx
  801bb0:	83 e1 f0             	and    $0xfffffff0,%ecx
  801bb3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801bb9:	89 e6                	mov    %esp,%esi
  801bbb:	29 d6                	sub    %edx,%esi
  801bbd:	89 f2                	mov    %esi,%edx
  801bbf:	39 d4                	cmp    %edx,%esp
  801bc1:	74 10                	je     801bd3 <spawnl+0x50>
  801bc3:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801bc9:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801bd0:	00 
  801bd1:	eb ec                	jmp    801bbf <spawnl+0x3c>
  801bd3:	89 ca                	mov    %ecx,%edx
  801bd5:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801bdb:	29 d4                	sub    %edx,%esp
  801bdd:	85 d2                	test   %edx,%edx
  801bdf:	74 05                	je     801be6 <spawnl+0x63>
  801be1:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801be6:	8d 74 24 03          	lea    0x3(%esp),%esi
  801bea:	89 f2                	mov    %esi,%edx
  801bec:	c1 ea 02             	shr    $0x2,%edx
  801bef:	83 e6 fc             	and    $0xfffffffc,%esi
  801bf2:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bf7:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc + 1] = NULL;
  801bfe:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801c05:	00 
	va_start(vl, arg0);
  801c06:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801c09:	89 c2                	mov    %eax,%edx
	for (i = 0; i < argc; i++)
  801c0b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c10:	eb 0b                	jmp    801c1d <spawnl+0x9a>
		argv[i + 1] = va_arg(vl, const char *);
  801c12:	83 c0 01             	add    $0x1,%eax
  801c15:	8b 39                	mov    (%ecx),%edi
  801c17:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  801c1a:	8d 49 04             	lea    0x4(%ecx),%ecx
	for (i = 0; i < argc; i++)
  801c1d:	39 d0                	cmp    %edx,%eax
  801c1f:	75 f1                	jne    801c12 <spawnl+0x8f>
	return spawn(prog, argv);
  801c21:	83 ec 08             	sub    $0x8,%esp
  801c24:	56                   	push   %esi
  801c25:	ff 75 08             	pushl  0x8(%ebp)
  801c28:	e8 0a fd ff ff       	call   801937 <spawn>
}
  801c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c30:	5b                   	pop    %ebx
  801c31:	5e                   	pop    %esi
  801c32:	5f                   	pop    %edi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    

00801c35 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c35:	f3 0f 1e fb          	endbr32 
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	56                   	push   %esi
  801c3d:	53                   	push   %ebx
  801c3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c41:	83 ec 0c             	sub    $0xc,%esp
  801c44:	ff 75 08             	pushl  0x8(%ebp)
  801c47:	e8 82 f1 ff ff       	call   800dce <fd2data>
  801c4c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c4e:	83 c4 08             	add    $0x8,%esp
  801c51:	68 7e 2a 80 00       	push   $0x802a7e
  801c56:	53                   	push   %ebx
  801c57:	e8 99 eb ff ff       	call   8007f5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c5c:	8b 46 04             	mov    0x4(%esi),%eax
  801c5f:	2b 06                	sub    (%esi),%eax
  801c61:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c67:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c6e:	00 00 00 
	stat->st_dev = &devpipe;
  801c71:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c78:	30 80 00 
	return 0;
}
  801c7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c83:	5b                   	pop    %ebx
  801c84:	5e                   	pop    %esi
  801c85:	5d                   	pop    %ebp
  801c86:	c3                   	ret    

00801c87 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c87:	f3 0f 1e fb          	endbr32 
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	53                   	push   %ebx
  801c8f:	83 ec 0c             	sub    $0xc,%esp
  801c92:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c95:	53                   	push   %ebx
  801c96:	6a 00                	push   $0x0
  801c98:	e8 32 f0 ff ff       	call   800ccf <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c9d:	89 1c 24             	mov    %ebx,(%esp)
  801ca0:	e8 29 f1 ff ff       	call   800dce <fd2data>
  801ca5:	83 c4 08             	add    $0x8,%esp
  801ca8:	50                   	push   %eax
  801ca9:	6a 00                	push   $0x0
  801cab:	e8 1f f0 ff ff       	call   800ccf <sys_page_unmap>
}
  801cb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb3:	c9                   	leave  
  801cb4:	c3                   	ret    

00801cb5 <_pipeisclosed>:
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	57                   	push   %edi
  801cb9:	56                   	push   %esi
  801cba:	53                   	push   %ebx
  801cbb:	83 ec 1c             	sub    $0x1c,%esp
  801cbe:	89 c7                	mov    %eax,%edi
  801cc0:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801cc2:	a1 04 40 80 00       	mov    0x804004,%eax
  801cc7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cca:	83 ec 0c             	sub    $0xc,%esp
  801ccd:	57                   	push   %edi
  801cce:	e8 5a 05 00 00       	call   80222d <pageref>
  801cd3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801cd6:	89 34 24             	mov    %esi,(%esp)
  801cd9:	e8 4f 05 00 00       	call   80222d <pageref>
		nn = thisenv->env_runs;
  801cde:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ce4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ce7:	83 c4 10             	add    $0x10,%esp
  801cea:	39 cb                	cmp    %ecx,%ebx
  801cec:	74 1b                	je     801d09 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801cee:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801cf1:	75 cf                	jne    801cc2 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cf3:	8b 42 58             	mov    0x58(%edx),%eax
  801cf6:	6a 01                	push   $0x1
  801cf8:	50                   	push   %eax
  801cf9:	53                   	push   %ebx
  801cfa:	68 85 2a 80 00       	push   $0x802a85
  801cff:	e8 87 e5 ff ff       	call   80028b <cprintf>
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	eb b9                	jmp    801cc2 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801d09:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d0c:	0f 94 c0             	sete   %al
  801d0f:	0f b6 c0             	movzbl %al,%eax
}
  801d12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d15:	5b                   	pop    %ebx
  801d16:	5e                   	pop    %esi
  801d17:	5f                   	pop    %edi
  801d18:	5d                   	pop    %ebp
  801d19:	c3                   	ret    

00801d1a <devpipe_write>:
{
  801d1a:	f3 0f 1e fb          	endbr32 
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	53                   	push   %ebx
  801d24:	83 ec 28             	sub    $0x28,%esp
  801d27:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d2a:	56                   	push   %esi
  801d2b:	e8 9e f0 ff ff       	call   800dce <fd2data>
  801d30:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d32:	83 c4 10             	add    $0x10,%esp
  801d35:	bf 00 00 00 00       	mov    $0x0,%edi
  801d3a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d3d:	74 4f                	je     801d8e <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d3f:	8b 43 04             	mov    0x4(%ebx),%eax
  801d42:	8b 0b                	mov    (%ebx),%ecx
  801d44:	8d 51 20             	lea    0x20(%ecx),%edx
  801d47:	39 d0                	cmp    %edx,%eax
  801d49:	72 14                	jb     801d5f <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801d4b:	89 da                	mov    %ebx,%edx
  801d4d:	89 f0                	mov    %esi,%eax
  801d4f:	e8 61 ff ff ff       	call   801cb5 <_pipeisclosed>
  801d54:	85 c0                	test   %eax,%eax
  801d56:	75 3b                	jne    801d93 <devpipe_write+0x79>
			sys_yield();
  801d58:	e8 f5 ee ff ff       	call   800c52 <sys_yield>
  801d5d:	eb e0                	jmp    801d3f <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d62:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d66:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d69:	89 c2                	mov    %eax,%edx
  801d6b:	c1 fa 1f             	sar    $0x1f,%edx
  801d6e:	89 d1                	mov    %edx,%ecx
  801d70:	c1 e9 1b             	shr    $0x1b,%ecx
  801d73:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d76:	83 e2 1f             	and    $0x1f,%edx
  801d79:	29 ca                	sub    %ecx,%edx
  801d7b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d7f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d83:	83 c0 01             	add    $0x1,%eax
  801d86:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d89:	83 c7 01             	add    $0x1,%edi
  801d8c:	eb ac                	jmp    801d3a <devpipe_write+0x20>
	return i;
  801d8e:	8b 45 10             	mov    0x10(%ebp),%eax
  801d91:	eb 05                	jmp    801d98 <devpipe_write+0x7e>
				return 0;
  801d93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d9b:	5b                   	pop    %ebx
  801d9c:	5e                   	pop    %esi
  801d9d:	5f                   	pop    %edi
  801d9e:	5d                   	pop    %ebp
  801d9f:	c3                   	ret    

00801da0 <devpipe_read>:
{
  801da0:	f3 0f 1e fb          	endbr32 
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	57                   	push   %edi
  801da8:	56                   	push   %esi
  801da9:	53                   	push   %ebx
  801daa:	83 ec 18             	sub    $0x18,%esp
  801dad:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801db0:	57                   	push   %edi
  801db1:	e8 18 f0 ff ff       	call   800dce <fd2data>
  801db6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801db8:	83 c4 10             	add    $0x10,%esp
  801dbb:	be 00 00 00 00       	mov    $0x0,%esi
  801dc0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dc3:	75 14                	jne    801dd9 <devpipe_read+0x39>
	return i;
  801dc5:	8b 45 10             	mov    0x10(%ebp),%eax
  801dc8:	eb 02                	jmp    801dcc <devpipe_read+0x2c>
				return i;
  801dca:	89 f0                	mov    %esi,%eax
}
  801dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dcf:	5b                   	pop    %ebx
  801dd0:	5e                   	pop    %esi
  801dd1:	5f                   	pop    %edi
  801dd2:	5d                   	pop    %ebp
  801dd3:	c3                   	ret    
			sys_yield();
  801dd4:	e8 79 ee ff ff       	call   800c52 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801dd9:	8b 03                	mov    (%ebx),%eax
  801ddb:	3b 43 04             	cmp    0x4(%ebx),%eax
  801dde:	75 18                	jne    801df8 <devpipe_read+0x58>
			if (i > 0)
  801de0:	85 f6                	test   %esi,%esi
  801de2:	75 e6                	jne    801dca <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801de4:	89 da                	mov    %ebx,%edx
  801de6:	89 f8                	mov    %edi,%eax
  801de8:	e8 c8 fe ff ff       	call   801cb5 <_pipeisclosed>
  801ded:	85 c0                	test   %eax,%eax
  801def:	74 e3                	je     801dd4 <devpipe_read+0x34>
				return 0;
  801df1:	b8 00 00 00 00       	mov    $0x0,%eax
  801df6:	eb d4                	jmp    801dcc <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801df8:	99                   	cltd   
  801df9:	c1 ea 1b             	shr    $0x1b,%edx
  801dfc:	01 d0                	add    %edx,%eax
  801dfe:	83 e0 1f             	and    $0x1f,%eax
  801e01:	29 d0                	sub    %edx,%eax
  801e03:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e0b:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e0e:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e11:	83 c6 01             	add    $0x1,%esi
  801e14:	eb aa                	jmp    801dc0 <devpipe_read+0x20>

00801e16 <pipe>:
{
  801e16:	f3 0f 1e fb          	endbr32 
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	56                   	push   %esi
  801e1e:	53                   	push   %ebx
  801e1f:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e25:	50                   	push   %eax
  801e26:	e8 c2 ef ff ff       	call   800ded <fd_alloc>
  801e2b:	89 c3                	mov    %eax,%ebx
  801e2d:	83 c4 10             	add    $0x10,%esp
  801e30:	85 c0                	test   %eax,%eax
  801e32:	0f 88 23 01 00 00    	js     801f5b <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e38:	83 ec 04             	sub    $0x4,%esp
  801e3b:	68 07 04 00 00       	push   $0x407
  801e40:	ff 75 f4             	pushl  -0xc(%ebp)
  801e43:	6a 00                	push   $0x0
  801e45:	e8 33 ee ff ff       	call   800c7d <sys_page_alloc>
  801e4a:	89 c3                	mov    %eax,%ebx
  801e4c:	83 c4 10             	add    $0x10,%esp
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	0f 88 04 01 00 00    	js     801f5b <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801e57:	83 ec 0c             	sub    $0xc,%esp
  801e5a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e5d:	50                   	push   %eax
  801e5e:	e8 8a ef ff ff       	call   800ded <fd_alloc>
  801e63:	89 c3                	mov    %eax,%ebx
  801e65:	83 c4 10             	add    $0x10,%esp
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	0f 88 db 00 00 00    	js     801f4b <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e70:	83 ec 04             	sub    $0x4,%esp
  801e73:	68 07 04 00 00       	push   $0x407
  801e78:	ff 75 f0             	pushl  -0x10(%ebp)
  801e7b:	6a 00                	push   $0x0
  801e7d:	e8 fb ed ff ff       	call   800c7d <sys_page_alloc>
  801e82:	89 c3                	mov    %eax,%ebx
  801e84:	83 c4 10             	add    $0x10,%esp
  801e87:	85 c0                	test   %eax,%eax
  801e89:	0f 88 bc 00 00 00    	js     801f4b <pipe+0x135>
	va = fd2data(fd0);
  801e8f:	83 ec 0c             	sub    $0xc,%esp
  801e92:	ff 75 f4             	pushl  -0xc(%ebp)
  801e95:	e8 34 ef ff ff       	call   800dce <fd2data>
  801e9a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e9c:	83 c4 0c             	add    $0xc,%esp
  801e9f:	68 07 04 00 00       	push   $0x407
  801ea4:	50                   	push   %eax
  801ea5:	6a 00                	push   $0x0
  801ea7:	e8 d1 ed ff ff       	call   800c7d <sys_page_alloc>
  801eac:	89 c3                	mov    %eax,%ebx
  801eae:	83 c4 10             	add    $0x10,%esp
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	0f 88 82 00 00 00    	js     801f3b <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb9:	83 ec 0c             	sub    $0xc,%esp
  801ebc:	ff 75 f0             	pushl  -0x10(%ebp)
  801ebf:	e8 0a ef ff ff       	call   800dce <fd2data>
  801ec4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ecb:	50                   	push   %eax
  801ecc:	6a 00                	push   $0x0
  801ece:	56                   	push   %esi
  801ecf:	6a 00                	push   $0x0
  801ed1:	e8 cf ed ff ff       	call   800ca5 <sys_page_map>
  801ed6:	89 c3                	mov    %eax,%ebx
  801ed8:	83 c4 20             	add    $0x20,%esp
  801edb:	85 c0                	test   %eax,%eax
  801edd:	78 4e                	js     801f2d <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801edf:	a1 20 30 80 00       	mov    0x803020,%eax
  801ee4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ee7:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801ee9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801eec:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801ef3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ef6:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801ef8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801efb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f02:	83 ec 0c             	sub    $0xc,%esp
  801f05:	ff 75 f4             	pushl  -0xc(%ebp)
  801f08:	e8 ad ee ff ff       	call   800dba <fd2num>
  801f0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f10:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f12:	83 c4 04             	add    $0x4,%esp
  801f15:	ff 75 f0             	pushl  -0x10(%ebp)
  801f18:	e8 9d ee ff ff       	call   800dba <fd2num>
  801f1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f20:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f23:	83 c4 10             	add    $0x10,%esp
  801f26:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f2b:	eb 2e                	jmp    801f5b <pipe+0x145>
	sys_page_unmap(0, va);
  801f2d:	83 ec 08             	sub    $0x8,%esp
  801f30:	56                   	push   %esi
  801f31:	6a 00                	push   $0x0
  801f33:	e8 97 ed ff ff       	call   800ccf <sys_page_unmap>
  801f38:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f3b:	83 ec 08             	sub    $0x8,%esp
  801f3e:	ff 75 f0             	pushl  -0x10(%ebp)
  801f41:	6a 00                	push   $0x0
  801f43:	e8 87 ed ff ff       	call   800ccf <sys_page_unmap>
  801f48:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801f4b:	83 ec 08             	sub    $0x8,%esp
  801f4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f51:	6a 00                	push   $0x0
  801f53:	e8 77 ed ff ff       	call   800ccf <sys_page_unmap>
  801f58:	83 c4 10             	add    $0x10,%esp
}
  801f5b:	89 d8                	mov    %ebx,%eax
  801f5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f60:	5b                   	pop    %ebx
  801f61:	5e                   	pop    %esi
  801f62:	5d                   	pop    %ebp
  801f63:	c3                   	ret    

00801f64 <pipeisclosed>:
{
  801f64:	f3 0f 1e fb          	endbr32 
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f71:	50                   	push   %eax
  801f72:	ff 75 08             	pushl  0x8(%ebp)
  801f75:	e8 c9 ee ff ff       	call   800e43 <fd_lookup>
  801f7a:	83 c4 10             	add    $0x10,%esp
  801f7d:	85 c0                	test   %eax,%eax
  801f7f:	78 18                	js     801f99 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801f81:	83 ec 0c             	sub    $0xc,%esp
  801f84:	ff 75 f4             	pushl  -0xc(%ebp)
  801f87:	e8 42 ee ff ff       	call   800dce <fd2data>
  801f8c:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f91:	e8 1f fd ff ff       	call   801cb5 <_pipeisclosed>
  801f96:	83 c4 10             	add    $0x10,%esp
}
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    

00801f9b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f9b:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801f9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa4:	c3                   	ret    

00801fa5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fa5:	f3 0f 1e fb          	endbr32 
  801fa9:	55                   	push   %ebp
  801faa:	89 e5                	mov    %esp,%ebp
  801fac:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801faf:	68 9d 2a 80 00       	push   $0x802a9d
  801fb4:	ff 75 0c             	pushl  0xc(%ebp)
  801fb7:	e8 39 e8 ff ff       	call   8007f5 <strcpy>
	return 0;
}
  801fbc:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc1:	c9                   	leave  
  801fc2:	c3                   	ret    

00801fc3 <devcons_write>:
{
  801fc3:	f3 0f 1e fb          	endbr32 
  801fc7:	55                   	push   %ebp
  801fc8:	89 e5                	mov    %esp,%ebp
  801fca:	57                   	push   %edi
  801fcb:	56                   	push   %esi
  801fcc:	53                   	push   %ebx
  801fcd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801fd3:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fd8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801fde:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fe1:	73 31                	jae    802014 <devcons_write+0x51>
		m = n - tot;
  801fe3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fe6:	29 f3                	sub    %esi,%ebx
  801fe8:	83 fb 7f             	cmp    $0x7f,%ebx
  801feb:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801ff0:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ff3:	83 ec 04             	sub    $0x4,%esp
  801ff6:	53                   	push   %ebx
  801ff7:	89 f0                	mov    %esi,%eax
  801ff9:	03 45 0c             	add    0xc(%ebp),%eax
  801ffc:	50                   	push   %eax
  801ffd:	57                   	push   %edi
  801ffe:	e8 aa e9 ff ff       	call   8009ad <memmove>
		sys_cputs(buf, m);
  802003:	83 c4 08             	add    $0x8,%esp
  802006:	53                   	push   %ebx
  802007:	57                   	push   %edi
  802008:	e8 a5 eb ff ff       	call   800bb2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80200d:	01 de                	add    %ebx,%esi
  80200f:	83 c4 10             	add    $0x10,%esp
  802012:	eb ca                	jmp    801fde <devcons_write+0x1b>
}
  802014:	89 f0                	mov    %esi,%eax
  802016:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802019:	5b                   	pop    %ebx
  80201a:	5e                   	pop    %esi
  80201b:	5f                   	pop    %edi
  80201c:	5d                   	pop    %ebp
  80201d:	c3                   	ret    

0080201e <devcons_read>:
{
  80201e:	f3 0f 1e fb          	endbr32 
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
  802025:	83 ec 08             	sub    $0x8,%esp
  802028:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80202d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802031:	74 21                	je     802054 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  802033:	e8 a4 eb ff ff       	call   800bdc <sys_cgetc>
  802038:	85 c0                	test   %eax,%eax
  80203a:	75 07                	jne    802043 <devcons_read+0x25>
		sys_yield();
  80203c:	e8 11 ec ff ff       	call   800c52 <sys_yield>
  802041:	eb f0                	jmp    802033 <devcons_read+0x15>
	if (c < 0)
  802043:	78 0f                	js     802054 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802045:	83 f8 04             	cmp    $0x4,%eax
  802048:	74 0c                	je     802056 <devcons_read+0x38>
	*(char*)vbuf = c;
  80204a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80204d:	88 02                	mov    %al,(%edx)
	return 1;
  80204f:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802054:	c9                   	leave  
  802055:	c3                   	ret    
		return 0;
  802056:	b8 00 00 00 00       	mov    $0x0,%eax
  80205b:	eb f7                	jmp    802054 <devcons_read+0x36>

0080205d <cputchar>:
{
  80205d:	f3 0f 1e fb          	endbr32 
  802061:	55                   	push   %ebp
  802062:	89 e5                	mov    %esp,%ebp
  802064:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802067:	8b 45 08             	mov    0x8(%ebp),%eax
  80206a:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80206d:	6a 01                	push   $0x1
  80206f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802072:	50                   	push   %eax
  802073:	e8 3a eb ff ff       	call   800bb2 <sys_cputs>
}
  802078:	83 c4 10             	add    $0x10,%esp
  80207b:	c9                   	leave  
  80207c:	c3                   	ret    

0080207d <getchar>:
{
  80207d:	f3 0f 1e fb          	endbr32 
  802081:	55                   	push   %ebp
  802082:	89 e5                	mov    %esp,%ebp
  802084:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802087:	6a 01                	push   $0x1
  802089:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80208c:	50                   	push   %eax
  80208d:	6a 00                	push   $0x0
  80208f:	e8 32 f0 ff ff       	call   8010c6 <read>
	if (r < 0)
  802094:	83 c4 10             	add    $0x10,%esp
  802097:	85 c0                	test   %eax,%eax
  802099:	78 06                	js     8020a1 <getchar+0x24>
	if (r < 1)
  80209b:	74 06                	je     8020a3 <getchar+0x26>
	return c;
  80209d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8020a1:	c9                   	leave  
  8020a2:	c3                   	ret    
		return -E_EOF;
  8020a3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8020a8:	eb f7                	jmp    8020a1 <getchar+0x24>

008020aa <iscons>:
{
  8020aa:	f3 0f 1e fb          	endbr32 
  8020ae:	55                   	push   %ebp
  8020af:	89 e5                	mov    %esp,%ebp
  8020b1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b7:	50                   	push   %eax
  8020b8:	ff 75 08             	pushl  0x8(%ebp)
  8020bb:	e8 83 ed ff ff       	call   800e43 <fd_lookup>
  8020c0:	83 c4 10             	add    $0x10,%esp
  8020c3:	85 c0                	test   %eax,%eax
  8020c5:	78 11                	js     8020d8 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8020c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ca:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020d0:	39 10                	cmp    %edx,(%eax)
  8020d2:	0f 94 c0             	sete   %al
  8020d5:	0f b6 c0             	movzbl %al,%eax
}
  8020d8:	c9                   	leave  
  8020d9:	c3                   	ret    

008020da <opencons>:
{
  8020da:	f3 0f 1e fb          	endbr32 
  8020de:	55                   	push   %ebp
  8020df:	89 e5                	mov    %esp,%ebp
  8020e1:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8020e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e7:	50                   	push   %eax
  8020e8:	e8 00 ed ff ff       	call   800ded <fd_alloc>
  8020ed:	83 c4 10             	add    $0x10,%esp
  8020f0:	85 c0                	test   %eax,%eax
  8020f2:	78 3a                	js     80212e <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020f4:	83 ec 04             	sub    $0x4,%esp
  8020f7:	68 07 04 00 00       	push   $0x407
  8020fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ff:	6a 00                	push   $0x0
  802101:	e8 77 eb ff ff       	call   800c7d <sys_page_alloc>
  802106:	83 c4 10             	add    $0x10,%esp
  802109:	85 c0                	test   %eax,%eax
  80210b:	78 21                	js     80212e <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80210d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802110:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802116:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802118:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802122:	83 ec 0c             	sub    $0xc,%esp
  802125:	50                   	push   %eax
  802126:	e8 8f ec ff ff       	call   800dba <fd2num>
  80212b:	83 c4 10             	add    $0x10,%esp
}
  80212e:	c9                   	leave  
  80212f:	c3                   	ret    

00802130 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802130:	f3 0f 1e fb          	endbr32 
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
  802137:	56                   	push   %esi
  802138:	53                   	push   %ebx
  802139:	8b 75 08             	mov    0x8(%ebp),%esi
  80213c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80213f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  802142:	85 c0                	test   %eax,%eax
  802144:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802149:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  80214c:	83 ec 0c             	sub    $0xc,%esp
  80214f:	50                   	push   %eax
  802150:	e8 3f ec ff ff       	call   800d94 <sys_ipc_recv>
	if (f < 0) {
  802155:	83 c4 10             	add    $0x10,%esp
  802158:	85 c0                	test   %eax,%eax
  80215a:	78 2b                	js     802187 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  80215c:	85 f6                	test   %esi,%esi
  80215e:	74 0a                	je     80216a <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  802160:	a1 04 40 80 00       	mov    0x804004,%eax
  802165:	8b 40 74             	mov    0x74(%eax),%eax
  802168:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  80216a:	85 db                	test   %ebx,%ebx
  80216c:	74 0a                	je     802178 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  80216e:	a1 04 40 80 00       	mov    0x804004,%eax
  802173:	8b 40 78             	mov    0x78(%eax),%eax
  802176:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  802178:	a1 04 40 80 00       	mov    0x804004,%eax
  80217d:	8b 40 70             	mov    0x70(%eax),%eax
}
  802180:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5d                   	pop    %ebp
  802186:	c3                   	ret    
		if (from_env_store != NULL) {
  802187:	85 f6                	test   %esi,%esi
  802189:	74 06                	je     802191 <ipc_recv+0x61>
			*from_env_store = 0;
  80218b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  802191:	85 db                	test   %ebx,%ebx
  802193:	74 eb                	je     802180 <ipc_recv+0x50>
			*perm_store = 0;
  802195:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80219b:	eb e3                	jmp    802180 <ipc_recv+0x50>

0080219d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80219d:	f3 0f 1e fb          	endbr32 
  8021a1:	55                   	push   %ebp
  8021a2:	89 e5                	mov    %esp,%ebp
  8021a4:	57                   	push   %edi
  8021a5:	56                   	push   %esi
  8021a6:	53                   	push   %ebx
  8021a7:	83 ec 0c             	sub    $0xc,%esp
  8021aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  8021b3:	85 db                	test   %ebx,%ebx
  8021b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8021ba:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8021bd:	ff 75 14             	pushl  0x14(%ebp)
  8021c0:	53                   	push   %ebx
  8021c1:	56                   	push   %esi
  8021c2:	57                   	push   %edi
  8021c3:	e8 a3 eb ff ff       	call   800d6b <sys_ipc_try_send>
  8021c8:	83 c4 10             	add    $0x10,%esp
  8021cb:	85 c0                	test   %eax,%eax
  8021cd:	79 19                	jns    8021e8 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  8021cf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021d2:	74 e9                	je     8021bd <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  8021d4:	83 ec 04             	sub    $0x4,%esp
  8021d7:	68 ac 2a 80 00       	push   $0x802aac
  8021dc:	6a 48                	push   $0x48
  8021de:	68 ce 2a 80 00       	push   $0x802ace
  8021e3:	e8 bc df ff ff       	call   8001a4 <_panic>
		}
	}
}
  8021e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021eb:	5b                   	pop    %ebx
  8021ec:	5e                   	pop    %esi
  8021ed:	5f                   	pop    %edi
  8021ee:	5d                   	pop    %ebp
  8021ef:	c3                   	ret    

008021f0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021f0:	f3 0f 1e fb          	endbr32 
  8021f4:	55                   	push   %ebp
  8021f5:	89 e5                	mov    %esp,%ebp
  8021f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021fa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021ff:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802202:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802208:	8b 52 50             	mov    0x50(%edx),%edx
  80220b:	39 ca                	cmp    %ecx,%edx
  80220d:	74 11                	je     802220 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80220f:	83 c0 01             	add    $0x1,%eax
  802212:	3d 00 04 00 00       	cmp    $0x400,%eax
  802217:	75 e6                	jne    8021ff <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802219:	b8 00 00 00 00       	mov    $0x0,%eax
  80221e:	eb 0b                	jmp    80222b <ipc_find_env+0x3b>
			return envs[i].env_id;
  802220:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802223:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802228:	8b 40 48             	mov    0x48(%eax),%eax
}
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    

0080222d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80222d:	f3 0f 1e fb          	endbr32 
  802231:	55                   	push   %ebp
  802232:	89 e5                	mov    %esp,%ebp
  802234:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802237:	89 c2                	mov    %eax,%edx
  802239:	c1 ea 16             	shr    $0x16,%edx
  80223c:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802243:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802248:	f6 c1 01             	test   $0x1,%cl
  80224b:	74 1c                	je     802269 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80224d:	c1 e8 0c             	shr    $0xc,%eax
  802250:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802257:	a8 01                	test   $0x1,%al
  802259:	74 0e                	je     802269 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80225b:	c1 e8 0c             	shr    $0xc,%eax
  80225e:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802265:	ef 
  802266:	0f b7 d2             	movzwl %dx,%edx
}
  802269:	89 d0                	mov    %edx,%eax
  80226b:	5d                   	pop    %ebp
  80226c:	c3                   	ret    
  80226d:	66 90                	xchg   %ax,%ax
  80226f:	90                   	nop

00802270 <__udivdi3>:
  802270:	f3 0f 1e fb          	endbr32 
  802274:	55                   	push   %ebp
  802275:	57                   	push   %edi
  802276:	56                   	push   %esi
  802277:	53                   	push   %ebx
  802278:	83 ec 1c             	sub    $0x1c,%esp
  80227b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80227f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802283:	8b 74 24 34          	mov    0x34(%esp),%esi
  802287:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80228b:	85 d2                	test   %edx,%edx
  80228d:	75 19                	jne    8022a8 <__udivdi3+0x38>
  80228f:	39 f3                	cmp    %esi,%ebx
  802291:	76 4d                	jbe    8022e0 <__udivdi3+0x70>
  802293:	31 ff                	xor    %edi,%edi
  802295:	89 e8                	mov    %ebp,%eax
  802297:	89 f2                	mov    %esi,%edx
  802299:	f7 f3                	div    %ebx
  80229b:	89 fa                	mov    %edi,%edx
  80229d:	83 c4 1c             	add    $0x1c,%esp
  8022a0:	5b                   	pop    %ebx
  8022a1:	5e                   	pop    %esi
  8022a2:	5f                   	pop    %edi
  8022a3:	5d                   	pop    %ebp
  8022a4:	c3                   	ret    
  8022a5:	8d 76 00             	lea    0x0(%esi),%esi
  8022a8:	39 f2                	cmp    %esi,%edx
  8022aa:	76 14                	jbe    8022c0 <__udivdi3+0x50>
  8022ac:	31 ff                	xor    %edi,%edi
  8022ae:	31 c0                	xor    %eax,%eax
  8022b0:	89 fa                	mov    %edi,%edx
  8022b2:	83 c4 1c             	add    $0x1c,%esp
  8022b5:	5b                   	pop    %ebx
  8022b6:	5e                   	pop    %esi
  8022b7:	5f                   	pop    %edi
  8022b8:	5d                   	pop    %ebp
  8022b9:	c3                   	ret    
  8022ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022c0:	0f bd fa             	bsr    %edx,%edi
  8022c3:	83 f7 1f             	xor    $0x1f,%edi
  8022c6:	75 48                	jne    802310 <__udivdi3+0xa0>
  8022c8:	39 f2                	cmp    %esi,%edx
  8022ca:	72 06                	jb     8022d2 <__udivdi3+0x62>
  8022cc:	31 c0                	xor    %eax,%eax
  8022ce:	39 eb                	cmp    %ebp,%ebx
  8022d0:	77 de                	ja     8022b0 <__udivdi3+0x40>
  8022d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d7:	eb d7                	jmp    8022b0 <__udivdi3+0x40>
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	89 d9                	mov    %ebx,%ecx
  8022e2:	85 db                	test   %ebx,%ebx
  8022e4:	75 0b                	jne    8022f1 <__udivdi3+0x81>
  8022e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022eb:	31 d2                	xor    %edx,%edx
  8022ed:	f7 f3                	div    %ebx
  8022ef:	89 c1                	mov    %eax,%ecx
  8022f1:	31 d2                	xor    %edx,%edx
  8022f3:	89 f0                	mov    %esi,%eax
  8022f5:	f7 f1                	div    %ecx
  8022f7:	89 c6                	mov    %eax,%esi
  8022f9:	89 e8                	mov    %ebp,%eax
  8022fb:	89 f7                	mov    %esi,%edi
  8022fd:	f7 f1                	div    %ecx
  8022ff:	89 fa                	mov    %edi,%edx
  802301:	83 c4 1c             	add    $0x1c,%esp
  802304:	5b                   	pop    %ebx
  802305:	5e                   	pop    %esi
  802306:	5f                   	pop    %edi
  802307:	5d                   	pop    %ebp
  802308:	c3                   	ret    
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	89 f9                	mov    %edi,%ecx
  802312:	b8 20 00 00 00       	mov    $0x20,%eax
  802317:	29 f8                	sub    %edi,%eax
  802319:	d3 e2                	shl    %cl,%edx
  80231b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80231f:	89 c1                	mov    %eax,%ecx
  802321:	89 da                	mov    %ebx,%edx
  802323:	d3 ea                	shr    %cl,%edx
  802325:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802329:	09 d1                	or     %edx,%ecx
  80232b:	89 f2                	mov    %esi,%edx
  80232d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802331:	89 f9                	mov    %edi,%ecx
  802333:	d3 e3                	shl    %cl,%ebx
  802335:	89 c1                	mov    %eax,%ecx
  802337:	d3 ea                	shr    %cl,%edx
  802339:	89 f9                	mov    %edi,%ecx
  80233b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80233f:	89 eb                	mov    %ebp,%ebx
  802341:	d3 e6                	shl    %cl,%esi
  802343:	89 c1                	mov    %eax,%ecx
  802345:	d3 eb                	shr    %cl,%ebx
  802347:	09 de                	or     %ebx,%esi
  802349:	89 f0                	mov    %esi,%eax
  80234b:	f7 74 24 08          	divl   0x8(%esp)
  80234f:	89 d6                	mov    %edx,%esi
  802351:	89 c3                	mov    %eax,%ebx
  802353:	f7 64 24 0c          	mull   0xc(%esp)
  802357:	39 d6                	cmp    %edx,%esi
  802359:	72 15                	jb     802370 <__udivdi3+0x100>
  80235b:	89 f9                	mov    %edi,%ecx
  80235d:	d3 e5                	shl    %cl,%ebp
  80235f:	39 c5                	cmp    %eax,%ebp
  802361:	73 04                	jae    802367 <__udivdi3+0xf7>
  802363:	39 d6                	cmp    %edx,%esi
  802365:	74 09                	je     802370 <__udivdi3+0x100>
  802367:	89 d8                	mov    %ebx,%eax
  802369:	31 ff                	xor    %edi,%edi
  80236b:	e9 40 ff ff ff       	jmp    8022b0 <__udivdi3+0x40>
  802370:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802373:	31 ff                	xor    %edi,%edi
  802375:	e9 36 ff ff ff       	jmp    8022b0 <__udivdi3+0x40>
  80237a:	66 90                	xchg   %ax,%ax
  80237c:	66 90                	xchg   %ax,%ax
  80237e:	66 90                	xchg   %ax,%ax

00802380 <__umoddi3>:
  802380:	f3 0f 1e fb          	endbr32 
  802384:	55                   	push   %ebp
  802385:	57                   	push   %edi
  802386:	56                   	push   %esi
  802387:	53                   	push   %ebx
  802388:	83 ec 1c             	sub    $0x1c,%esp
  80238b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80238f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802393:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802397:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80239b:	85 c0                	test   %eax,%eax
  80239d:	75 19                	jne    8023b8 <__umoddi3+0x38>
  80239f:	39 df                	cmp    %ebx,%edi
  8023a1:	76 5d                	jbe    802400 <__umoddi3+0x80>
  8023a3:	89 f0                	mov    %esi,%eax
  8023a5:	89 da                	mov    %ebx,%edx
  8023a7:	f7 f7                	div    %edi
  8023a9:	89 d0                	mov    %edx,%eax
  8023ab:	31 d2                	xor    %edx,%edx
  8023ad:	83 c4 1c             	add    $0x1c,%esp
  8023b0:	5b                   	pop    %ebx
  8023b1:	5e                   	pop    %esi
  8023b2:	5f                   	pop    %edi
  8023b3:	5d                   	pop    %ebp
  8023b4:	c3                   	ret    
  8023b5:	8d 76 00             	lea    0x0(%esi),%esi
  8023b8:	89 f2                	mov    %esi,%edx
  8023ba:	39 d8                	cmp    %ebx,%eax
  8023bc:	76 12                	jbe    8023d0 <__umoddi3+0x50>
  8023be:	89 f0                	mov    %esi,%eax
  8023c0:	89 da                	mov    %ebx,%edx
  8023c2:	83 c4 1c             	add    $0x1c,%esp
  8023c5:	5b                   	pop    %ebx
  8023c6:	5e                   	pop    %esi
  8023c7:	5f                   	pop    %edi
  8023c8:	5d                   	pop    %ebp
  8023c9:	c3                   	ret    
  8023ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d0:	0f bd e8             	bsr    %eax,%ebp
  8023d3:	83 f5 1f             	xor    $0x1f,%ebp
  8023d6:	75 50                	jne    802428 <__umoddi3+0xa8>
  8023d8:	39 d8                	cmp    %ebx,%eax
  8023da:	0f 82 e0 00 00 00    	jb     8024c0 <__umoddi3+0x140>
  8023e0:	89 d9                	mov    %ebx,%ecx
  8023e2:	39 f7                	cmp    %esi,%edi
  8023e4:	0f 86 d6 00 00 00    	jbe    8024c0 <__umoddi3+0x140>
  8023ea:	89 d0                	mov    %edx,%eax
  8023ec:	89 ca                	mov    %ecx,%edx
  8023ee:	83 c4 1c             	add    $0x1c,%esp
  8023f1:	5b                   	pop    %ebx
  8023f2:	5e                   	pop    %esi
  8023f3:	5f                   	pop    %edi
  8023f4:	5d                   	pop    %ebp
  8023f5:	c3                   	ret    
  8023f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023fd:	8d 76 00             	lea    0x0(%esi),%esi
  802400:	89 fd                	mov    %edi,%ebp
  802402:	85 ff                	test   %edi,%edi
  802404:	75 0b                	jne    802411 <__umoddi3+0x91>
  802406:	b8 01 00 00 00       	mov    $0x1,%eax
  80240b:	31 d2                	xor    %edx,%edx
  80240d:	f7 f7                	div    %edi
  80240f:	89 c5                	mov    %eax,%ebp
  802411:	89 d8                	mov    %ebx,%eax
  802413:	31 d2                	xor    %edx,%edx
  802415:	f7 f5                	div    %ebp
  802417:	89 f0                	mov    %esi,%eax
  802419:	f7 f5                	div    %ebp
  80241b:	89 d0                	mov    %edx,%eax
  80241d:	31 d2                	xor    %edx,%edx
  80241f:	eb 8c                	jmp    8023ad <__umoddi3+0x2d>
  802421:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802428:	89 e9                	mov    %ebp,%ecx
  80242a:	ba 20 00 00 00       	mov    $0x20,%edx
  80242f:	29 ea                	sub    %ebp,%edx
  802431:	d3 e0                	shl    %cl,%eax
  802433:	89 44 24 08          	mov    %eax,0x8(%esp)
  802437:	89 d1                	mov    %edx,%ecx
  802439:	89 f8                	mov    %edi,%eax
  80243b:	d3 e8                	shr    %cl,%eax
  80243d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802441:	89 54 24 04          	mov    %edx,0x4(%esp)
  802445:	8b 54 24 04          	mov    0x4(%esp),%edx
  802449:	09 c1                	or     %eax,%ecx
  80244b:	89 d8                	mov    %ebx,%eax
  80244d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802451:	89 e9                	mov    %ebp,%ecx
  802453:	d3 e7                	shl    %cl,%edi
  802455:	89 d1                	mov    %edx,%ecx
  802457:	d3 e8                	shr    %cl,%eax
  802459:	89 e9                	mov    %ebp,%ecx
  80245b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80245f:	d3 e3                	shl    %cl,%ebx
  802461:	89 c7                	mov    %eax,%edi
  802463:	89 d1                	mov    %edx,%ecx
  802465:	89 f0                	mov    %esi,%eax
  802467:	d3 e8                	shr    %cl,%eax
  802469:	89 e9                	mov    %ebp,%ecx
  80246b:	89 fa                	mov    %edi,%edx
  80246d:	d3 e6                	shl    %cl,%esi
  80246f:	09 d8                	or     %ebx,%eax
  802471:	f7 74 24 08          	divl   0x8(%esp)
  802475:	89 d1                	mov    %edx,%ecx
  802477:	89 f3                	mov    %esi,%ebx
  802479:	f7 64 24 0c          	mull   0xc(%esp)
  80247d:	89 c6                	mov    %eax,%esi
  80247f:	89 d7                	mov    %edx,%edi
  802481:	39 d1                	cmp    %edx,%ecx
  802483:	72 06                	jb     80248b <__umoddi3+0x10b>
  802485:	75 10                	jne    802497 <__umoddi3+0x117>
  802487:	39 c3                	cmp    %eax,%ebx
  802489:	73 0c                	jae    802497 <__umoddi3+0x117>
  80248b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80248f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802493:	89 d7                	mov    %edx,%edi
  802495:	89 c6                	mov    %eax,%esi
  802497:	89 ca                	mov    %ecx,%edx
  802499:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80249e:	29 f3                	sub    %esi,%ebx
  8024a0:	19 fa                	sbb    %edi,%edx
  8024a2:	89 d0                	mov    %edx,%eax
  8024a4:	d3 e0                	shl    %cl,%eax
  8024a6:	89 e9                	mov    %ebp,%ecx
  8024a8:	d3 eb                	shr    %cl,%ebx
  8024aa:	d3 ea                	shr    %cl,%edx
  8024ac:	09 d8                	or     %ebx,%eax
  8024ae:	83 c4 1c             	add    $0x1c,%esp
  8024b1:	5b                   	pop    %ebx
  8024b2:	5e                   	pop    %esi
  8024b3:	5f                   	pop    %edi
  8024b4:	5d                   	pop    %ebp
  8024b5:	c3                   	ret    
  8024b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024bd:	8d 76 00             	lea    0x0(%esi),%esi
  8024c0:	29 fe                	sub    %edi,%esi
  8024c2:	19 c3                	sbb    %eax,%ebx
  8024c4:	89 f2                	mov    %esi,%edx
  8024c6:	89 d9                	mov    %ebx,%ecx
  8024c8:	e9 1d ff ff ff       	jmp    8023ea <__umoddi3+0x6a>
