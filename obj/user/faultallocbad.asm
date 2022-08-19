
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 8c 00 00 00       	call   8000bd <libmain>
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
  80003a:	53                   	push   %ebx
  80003b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003e:	8b 45 08             	mov    0x8(%ebp),%eax
  800041:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800043:	53                   	push   %ebx
  800044:	68 00 1f 80 00       	push   $0x801f00
  800049:	e8 c2 01 00 00       	call   800210 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004e:	83 c4 0c             	add    $0xc,%esp
  800051:	6a 07                	push   $0x7
  800053:	89 d8                	mov    %ebx,%eax
  800055:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005a:	50                   	push   %eax
  80005b:	6a 00                	push   $0x0
  80005d:	e8 a0 0b 00 00       	call   800c02 <sys_page_alloc>
  800062:	83 c4 10             	add    $0x10,%esp
  800065:	85 c0                	test   %eax,%eax
  800067:	78 16                	js     80007f <handler+0x4c>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800069:	53                   	push   %ebx
  80006a:	68 4c 1f 80 00       	push   $0x801f4c
  80006f:	6a 64                	push   $0x64
  800071:	53                   	push   %ebx
  800072:	e8 a2 06 00 00       	call   800719 <snprintf>
}
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007f:	83 ec 0c             	sub    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	53                   	push   %ebx
  800084:	68 20 1f 80 00       	push   $0x801f20
  800089:	6a 0f                	push   $0xf
  80008b:	68 0a 1f 80 00       	push   $0x801f0a
  800090:	e8 94 00 00 00       	call   800129 <_panic>

00800095 <umain>:

void
umain(int argc, char **argv)
{
  800095:	f3 0f 1e fb          	endbr32 
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  80009f:	68 33 00 80 00       	push   $0x800033
  8000a4:	e8 96 0c 00 00       	call   800d3f <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a9:	83 c4 08             	add    $0x8,%esp
  8000ac:	6a 04                	push   $0x4
  8000ae:	68 ef be ad de       	push   $0xdeadbeef
  8000b3:	e8 7f 0a 00 00       	call   800b37 <sys_cputs>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000bd:	f3 0f 1e fb          	endbr32 
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
  8000c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000cc:	e8 de 0a 00 00       	call   800baf <sys_getenvid>
	if (id >= 0)
  8000d1:	85 c0                	test   %eax,%eax
  8000d3:	78 12                	js     8000e7 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8000d5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000da:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e7:	85 db                	test   %ebx,%ebx
  8000e9:	7e 07                	jle    8000f2 <libmain+0x35>
		binaryname = argv[0];
  8000eb:	8b 06                	mov    (%esi),%eax
  8000ed:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f2:	83 ec 08             	sub    $0x8,%esp
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	e8 99 ff ff ff       	call   800095 <umain>

	// exit gracefully
	exit();
  8000fc:	e8 0a 00 00 00       	call   80010b <exit>
}
  800101:	83 c4 10             	add    $0x10,%esp
  800104:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800107:	5b                   	pop    %ebx
  800108:	5e                   	pop    %esi
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010b:	f3 0f 1e fb          	endbr32 
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800115:	e8 b1 0e 00 00       	call   800fcb <close_all>
	sys_env_destroy(0);
  80011a:	83 ec 0c             	sub    $0xc,%esp
  80011d:	6a 00                	push   $0x0
  80011f:	e8 65 0a 00 00       	call   800b89 <sys_env_destroy>
}
  800124:	83 c4 10             	add    $0x10,%esp
  800127:	c9                   	leave  
  800128:	c3                   	ret    

00800129 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800129:	f3 0f 1e fb          	endbr32 
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800132:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800135:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80013b:	e8 6f 0a 00 00       	call   800baf <sys_getenvid>
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	ff 75 0c             	pushl  0xc(%ebp)
  800146:	ff 75 08             	pushl  0x8(%ebp)
  800149:	56                   	push   %esi
  80014a:	50                   	push   %eax
  80014b:	68 78 1f 80 00       	push   $0x801f78
  800150:	e8 bb 00 00 00       	call   800210 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800155:	83 c4 18             	add    $0x18,%esp
  800158:	53                   	push   %ebx
  800159:	ff 75 10             	pushl  0x10(%ebp)
  80015c:	e8 5a 00 00 00       	call   8001bb <vcprintf>
	cprintf("\n");
  800161:	c7 04 24 2f 24 80 00 	movl   $0x80242f,(%esp)
  800168:	e8 a3 00 00 00       	call   800210 <cprintf>
  80016d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800170:	cc                   	int3   
  800171:	eb fd                	jmp    800170 <_panic+0x47>

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
  800276:	e8 15 1a 00 00       	call   801c90 <__udivdi3>
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
  8002b4:	e8 e7 1a 00 00       	call   801da0 <__umoddi3>
  8002b9:	83 c4 14             	add    $0x14,%esp
  8002bc:	0f be 80 9b 1f 80 00 	movsbl 0x801f9b(%eax),%eax
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
  8003c3:	3e ff 24 85 e0 20 80 	notrack jmp *0x8020e0(,%eax,4)
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
  800490:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  800497:	85 d2                	test   %edx,%edx
  800499:	74 15                	je     8004b0 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  80049b:	52                   	push   %edx
  80049c:	68 fd 23 80 00       	push   $0x8023fd
  8004a1:	56                   	push   %esi
  8004a2:	53                   	push   %ebx
  8004a3:	e8 aa fe ff ff       	call   800352 <printfmt>
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	e9 61 01 00 00       	jmp    800611 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8004b0:	50                   	push   %eax
  8004b1:	68 b3 1f 80 00       	push   $0x801fb3
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
  8004d2:	b8 ac 1f 80 00       	mov    $0x801fac,%eax
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
  800b26:	68 9f 22 80 00       	push   $0x80229f
  800b2b:	6a 23                	push   $0x23
  800b2d:	68 bc 22 80 00       	push   $0x8022bc
  800b32:	e8 f2 f5 ff ff       	call   800129 <_panic>

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

00800d3f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d3f:	f3 0f 1e fb          	endbr32 
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  800d49:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d50:	74 0a                	je     800d5c <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800d5a:	c9                   	leave  
  800d5b:	c3                   	ret    
		if (sys_page_alloc(0,
  800d5c:	83 ec 04             	sub    $0x4,%esp
  800d5f:	6a 07                	push   $0x7
  800d61:	68 00 f0 bf ee       	push   $0xeebff000
  800d66:	6a 00                	push   $0x0
  800d68:	e8 95 fe ff ff       	call   800c02 <sys_page_alloc>
  800d6d:	83 c4 10             	add    $0x10,%esp
  800d70:	85 c0                	test   %eax,%eax
  800d72:	78 2a                	js     800d9e <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  800d74:	83 ec 08             	sub    $0x8,%esp
  800d77:	68 b2 0d 80 00       	push   $0x800db2
  800d7c:	6a 00                	push   $0x0
  800d7e:	e8 46 ff ff ff       	call   800cc9 <sys_env_set_pgfault_upcall>
  800d83:	83 c4 10             	add    $0x10,%esp
  800d86:	85 c0                	test   %eax,%eax
  800d88:	79 c8                	jns    800d52 <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  800d8a:	83 ec 04             	sub    $0x4,%esp
  800d8d:	68 00 23 80 00       	push   $0x802300
  800d92:	6a 25                	push   $0x25
  800d94:	68 47 23 80 00       	push   $0x802347
  800d99:	e8 8b f3 ff ff       	call   800129 <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  800d9e:	83 ec 04             	sub    $0x4,%esp
  800da1:	68 cc 22 80 00       	push   $0x8022cc
  800da6:	6a 21                	push   $0x21
  800da8:	68 47 23 80 00       	push   $0x802347
  800dad:	e8 77 f3 ff ff       	call   800129 <_panic>

00800db2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800db2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800db3:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800db8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dba:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  800dbd:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  800dc2:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  800dc6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800dca:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  800dcc:	83 c4 08             	add    $0x8,%esp
	popal
  800dcf:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  800dd0:	83 c4 04             	add    $0x4,%esp
	popfl
  800dd3:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  800dd4:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800dd7:	c3                   	ret    

00800dd8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dd8:	f3 0f 1e fb          	endbr32 
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	05 00 00 00 30       	add    $0x30000000,%eax
  800de7:	c1 e8 0c             	shr    $0xc,%eax
}
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dec:	f3 0f 1e fb          	endbr32 
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800df6:	ff 75 08             	pushl  0x8(%ebp)
  800df9:	e8 da ff ff ff       	call   800dd8 <fd2num>
  800dfe:	83 c4 10             	add    $0x10,%esp
  800e01:	c1 e0 0c             	shl    $0xc,%eax
  800e04:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e09:	c9                   	leave  
  800e0a:	c3                   	ret    

00800e0b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e0b:	f3 0f 1e fb          	endbr32 
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e17:	89 c2                	mov    %eax,%edx
  800e19:	c1 ea 16             	shr    $0x16,%edx
  800e1c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e23:	f6 c2 01             	test   $0x1,%dl
  800e26:	74 2d                	je     800e55 <fd_alloc+0x4a>
  800e28:	89 c2                	mov    %eax,%edx
  800e2a:	c1 ea 0c             	shr    $0xc,%edx
  800e2d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e34:	f6 c2 01             	test   $0x1,%dl
  800e37:	74 1c                	je     800e55 <fd_alloc+0x4a>
  800e39:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e3e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e43:	75 d2                	jne    800e17 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e45:	8b 45 08             	mov    0x8(%ebp),%eax
  800e48:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e4e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e53:	eb 0a                	jmp    800e5f <fd_alloc+0x54>
			*fd_store = fd;
  800e55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e58:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e61:	f3 0f 1e fb          	endbr32 
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e6b:	83 f8 1f             	cmp    $0x1f,%eax
  800e6e:	77 30                	ja     800ea0 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e70:	c1 e0 0c             	shl    $0xc,%eax
  800e73:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e78:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e7e:	f6 c2 01             	test   $0x1,%dl
  800e81:	74 24                	je     800ea7 <fd_lookup+0x46>
  800e83:	89 c2                	mov    %eax,%edx
  800e85:	c1 ea 0c             	shr    $0xc,%edx
  800e88:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e8f:	f6 c2 01             	test   $0x1,%dl
  800e92:	74 1a                	je     800eae <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e97:	89 02                	mov    %eax,(%edx)
	return 0;
  800e99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    
		return -E_INVAL;
  800ea0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea5:	eb f7                	jmp    800e9e <fd_lookup+0x3d>
		return -E_INVAL;
  800ea7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eac:	eb f0                	jmp    800e9e <fd_lookup+0x3d>
  800eae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb3:	eb e9                	jmp    800e9e <fd_lookup+0x3d>

00800eb5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eb5:	f3 0f 1e fb          	endbr32 
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	83 ec 08             	sub    $0x8,%esp
  800ebf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec2:	ba d4 23 80 00       	mov    $0x8023d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ec7:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800ecc:	39 08                	cmp    %ecx,(%eax)
  800ece:	74 33                	je     800f03 <dev_lookup+0x4e>
  800ed0:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800ed3:	8b 02                	mov    (%edx),%eax
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	75 f3                	jne    800ecc <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ed9:	a1 04 40 80 00       	mov    0x804004,%eax
  800ede:	8b 40 48             	mov    0x48(%eax),%eax
  800ee1:	83 ec 04             	sub    $0x4,%esp
  800ee4:	51                   	push   %ecx
  800ee5:	50                   	push   %eax
  800ee6:	68 58 23 80 00       	push   $0x802358
  800eeb:	e8 20 f3 ff ff       	call   800210 <cprintf>
	*dev = 0;
  800ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ef9:	83 c4 10             	add    $0x10,%esp
  800efc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    
			*dev = devtab[i];
  800f03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f06:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f08:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0d:	eb f2                	jmp    800f01 <dev_lookup+0x4c>

00800f0f <fd_close>:
{
  800f0f:	f3 0f 1e fb          	endbr32 
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	57                   	push   %edi
  800f17:	56                   	push   %esi
  800f18:	53                   	push   %ebx
  800f19:	83 ec 28             	sub    $0x28,%esp
  800f1c:	8b 75 08             	mov    0x8(%ebp),%esi
  800f1f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f22:	56                   	push   %esi
  800f23:	e8 b0 fe ff ff       	call   800dd8 <fd2num>
  800f28:	83 c4 08             	add    $0x8,%esp
  800f2b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800f2e:	52                   	push   %edx
  800f2f:	50                   	push   %eax
  800f30:	e8 2c ff ff ff       	call   800e61 <fd_lookup>
  800f35:	89 c3                	mov    %eax,%ebx
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	78 05                	js     800f43 <fd_close+0x34>
	    || fd != fd2)
  800f3e:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f41:	74 16                	je     800f59 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800f43:	89 f8                	mov    %edi,%eax
  800f45:	84 c0                	test   %al,%al
  800f47:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4c:	0f 44 d8             	cmove  %eax,%ebx
}
  800f4f:	89 d8                	mov    %ebx,%eax
  800f51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f59:	83 ec 08             	sub    $0x8,%esp
  800f5c:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f5f:	50                   	push   %eax
  800f60:	ff 36                	pushl  (%esi)
  800f62:	e8 4e ff ff ff       	call   800eb5 <dev_lookup>
  800f67:	89 c3                	mov    %eax,%ebx
  800f69:	83 c4 10             	add    $0x10,%esp
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	78 1a                	js     800f8a <fd_close+0x7b>
		if (dev->dev_close)
  800f70:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f73:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f76:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	74 0b                	je     800f8a <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f7f:	83 ec 0c             	sub    $0xc,%esp
  800f82:	56                   	push   %esi
  800f83:	ff d0                	call   *%eax
  800f85:	89 c3                	mov    %eax,%ebx
  800f87:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f8a:	83 ec 08             	sub    $0x8,%esp
  800f8d:	56                   	push   %esi
  800f8e:	6a 00                	push   $0x0
  800f90:	e8 bf fc ff ff       	call   800c54 <sys_page_unmap>
	return r;
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	eb b5                	jmp    800f4f <fd_close+0x40>

00800f9a <close>:

int
close(int fdnum)
{
  800f9a:	f3 0f 1e fb          	endbr32 
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa7:	50                   	push   %eax
  800fa8:	ff 75 08             	pushl  0x8(%ebp)
  800fab:	e8 b1 fe ff ff       	call   800e61 <fd_lookup>
  800fb0:	83 c4 10             	add    $0x10,%esp
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	79 02                	jns    800fb9 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800fb7:	c9                   	leave  
  800fb8:	c3                   	ret    
		return fd_close(fd, 1);
  800fb9:	83 ec 08             	sub    $0x8,%esp
  800fbc:	6a 01                	push   $0x1
  800fbe:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc1:	e8 49 ff ff ff       	call   800f0f <fd_close>
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	eb ec                	jmp    800fb7 <close+0x1d>

00800fcb <close_all>:

void
close_all(void)
{
  800fcb:	f3 0f 1e fb          	endbr32 
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	53                   	push   %ebx
  800fd3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fdb:	83 ec 0c             	sub    $0xc,%esp
  800fde:	53                   	push   %ebx
  800fdf:	e8 b6 ff ff ff       	call   800f9a <close>
	for (i = 0; i < MAXFD; i++)
  800fe4:	83 c3 01             	add    $0x1,%ebx
  800fe7:	83 c4 10             	add    $0x10,%esp
  800fea:	83 fb 20             	cmp    $0x20,%ebx
  800fed:	75 ec                	jne    800fdb <close_all+0x10>
}
  800fef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ff4:	f3 0f 1e fb          	endbr32 
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	57                   	push   %edi
  800ffc:	56                   	push   %esi
  800ffd:	53                   	push   %ebx
  800ffe:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801001:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801004:	50                   	push   %eax
  801005:	ff 75 08             	pushl  0x8(%ebp)
  801008:	e8 54 fe ff ff       	call   800e61 <fd_lookup>
  80100d:	89 c3                	mov    %eax,%ebx
  80100f:	83 c4 10             	add    $0x10,%esp
  801012:	85 c0                	test   %eax,%eax
  801014:	0f 88 81 00 00 00    	js     80109b <dup+0xa7>
		return r;
	close(newfdnum);
  80101a:	83 ec 0c             	sub    $0xc,%esp
  80101d:	ff 75 0c             	pushl  0xc(%ebp)
  801020:	e8 75 ff ff ff       	call   800f9a <close>

	newfd = INDEX2FD(newfdnum);
  801025:	8b 75 0c             	mov    0xc(%ebp),%esi
  801028:	c1 e6 0c             	shl    $0xc,%esi
  80102b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801031:	83 c4 04             	add    $0x4,%esp
  801034:	ff 75 e4             	pushl  -0x1c(%ebp)
  801037:	e8 b0 fd ff ff       	call   800dec <fd2data>
  80103c:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80103e:	89 34 24             	mov    %esi,(%esp)
  801041:	e8 a6 fd ff ff       	call   800dec <fd2data>
  801046:	83 c4 10             	add    $0x10,%esp
  801049:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80104b:	89 d8                	mov    %ebx,%eax
  80104d:	c1 e8 16             	shr    $0x16,%eax
  801050:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801057:	a8 01                	test   $0x1,%al
  801059:	74 11                	je     80106c <dup+0x78>
  80105b:	89 d8                	mov    %ebx,%eax
  80105d:	c1 e8 0c             	shr    $0xc,%eax
  801060:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801067:	f6 c2 01             	test   $0x1,%dl
  80106a:	75 39                	jne    8010a5 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80106c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80106f:	89 d0                	mov    %edx,%eax
  801071:	c1 e8 0c             	shr    $0xc,%eax
  801074:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	25 07 0e 00 00       	and    $0xe07,%eax
  801083:	50                   	push   %eax
  801084:	56                   	push   %esi
  801085:	6a 00                	push   $0x0
  801087:	52                   	push   %edx
  801088:	6a 00                	push   $0x0
  80108a:	e8 9b fb ff ff       	call   800c2a <sys_page_map>
  80108f:	89 c3                	mov    %eax,%ebx
  801091:	83 c4 20             	add    $0x20,%esp
  801094:	85 c0                	test   %eax,%eax
  801096:	78 31                	js     8010c9 <dup+0xd5>
		goto err;

	return newfdnum;
  801098:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80109b:	89 d8                	mov    %ebx,%eax
  80109d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a0:	5b                   	pop    %ebx
  8010a1:	5e                   	pop    %esi
  8010a2:	5f                   	pop    %edi
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ac:	83 ec 0c             	sub    $0xc,%esp
  8010af:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b4:	50                   	push   %eax
  8010b5:	57                   	push   %edi
  8010b6:	6a 00                	push   $0x0
  8010b8:	53                   	push   %ebx
  8010b9:	6a 00                	push   $0x0
  8010bb:	e8 6a fb ff ff       	call   800c2a <sys_page_map>
  8010c0:	89 c3                	mov    %eax,%ebx
  8010c2:	83 c4 20             	add    $0x20,%esp
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	79 a3                	jns    80106c <dup+0x78>
	sys_page_unmap(0, newfd);
  8010c9:	83 ec 08             	sub    $0x8,%esp
  8010cc:	56                   	push   %esi
  8010cd:	6a 00                	push   $0x0
  8010cf:	e8 80 fb ff ff       	call   800c54 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010d4:	83 c4 08             	add    $0x8,%esp
  8010d7:	57                   	push   %edi
  8010d8:	6a 00                	push   $0x0
  8010da:	e8 75 fb ff ff       	call   800c54 <sys_page_unmap>
	return r;
  8010df:	83 c4 10             	add    $0x10,%esp
  8010e2:	eb b7                	jmp    80109b <dup+0xa7>

008010e4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010e4:	f3 0f 1e fb          	endbr32 
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	53                   	push   %ebx
  8010ec:	83 ec 1c             	sub    $0x1c,%esp
  8010ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f5:	50                   	push   %eax
  8010f6:	53                   	push   %ebx
  8010f7:	e8 65 fd ff ff       	call   800e61 <fd_lookup>
  8010fc:	83 c4 10             	add    $0x10,%esp
  8010ff:	85 c0                	test   %eax,%eax
  801101:	78 3f                	js     801142 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801103:	83 ec 08             	sub    $0x8,%esp
  801106:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801109:	50                   	push   %eax
  80110a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80110d:	ff 30                	pushl  (%eax)
  80110f:	e8 a1 fd ff ff       	call   800eb5 <dev_lookup>
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	78 27                	js     801142 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80111b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80111e:	8b 42 08             	mov    0x8(%edx),%eax
  801121:	83 e0 03             	and    $0x3,%eax
  801124:	83 f8 01             	cmp    $0x1,%eax
  801127:	74 1e                	je     801147 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801129:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112c:	8b 40 08             	mov    0x8(%eax),%eax
  80112f:	85 c0                	test   %eax,%eax
  801131:	74 35                	je     801168 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801133:	83 ec 04             	sub    $0x4,%esp
  801136:	ff 75 10             	pushl  0x10(%ebp)
  801139:	ff 75 0c             	pushl  0xc(%ebp)
  80113c:	52                   	push   %edx
  80113d:	ff d0                	call   *%eax
  80113f:	83 c4 10             	add    $0x10,%esp
}
  801142:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801145:	c9                   	leave  
  801146:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801147:	a1 04 40 80 00       	mov    0x804004,%eax
  80114c:	8b 40 48             	mov    0x48(%eax),%eax
  80114f:	83 ec 04             	sub    $0x4,%esp
  801152:	53                   	push   %ebx
  801153:	50                   	push   %eax
  801154:	68 99 23 80 00       	push   $0x802399
  801159:	e8 b2 f0 ff ff       	call   800210 <cprintf>
		return -E_INVAL;
  80115e:	83 c4 10             	add    $0x10,%esp
  801161:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801166:	eb da                	jmp    801142 <read+0x5e>
		return -E_NOT_SUPP;
  801168:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80116d:	eb d3                	jmp    801142 <read+0x5e>

0080116f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80116f:	f3 0f 1e fb          	endbr32 
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	57                   	push   %edi
  801177:	56                   	push   %esi
  801178:	53                   	push   %ebx
  801179:	83 ec 0c             	sub    $0xc,%esp
  80117c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80117f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801182:	bb 00 00 00 00       	mov    $0x0,%ebx
  801187:	eb 02                	jmp    80118b <readn+0x1c>
  801189:	01 c3                	add    %eax,%ebx
  80118b:	39 f3                	cmp    %esi,%ebx
  80118d:	73 21                	jae    8011b0 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80118f:	83 ec 04             	sub    $0x4,%esp
  801192:	89 f0                	mov    %esi,%eax
  801194:	29 d8                	sub    %ebx,%eax
  801196:	50                   	push   %eax
  801197:	89 d8                	mov    %ebx,%eax
  801199:	03 45 0c             	add    0xc(%ebp),%eax
  80119c:	50                   	push   %eax
  80119d:	57                   	push   %edi
  80119e:	e8 41 ff ff ff       	call   8010e4 <read>
		if (m < 0)
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	78 04                	js     8011ae <readn+0x3f>
			return m;
		if (m == 0)
  8011aa:	75 dd                	jne    801189 <readn+0x1a>
  8011ac:	eb 02                	jmp    8011b0 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011ae:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011b0:	89 d8                	mov    %ebx,%eax
  8011b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b5:	5b                   	pop    %ebx
  8011b6:	5e                   	pop    %esi
  8011b7:	5f                   	pop    %edi
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011ba:	f3 0f 1e fb          	endbr32 
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	53                   	push   %ebx
  8011c2:	83 ec 1c             	sub    $0x1c,%esp
  8011c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011cb:	50                   	push   %eax
  8011cc:	53                   	push   %ebx
  8011cd:	e8 8f fc ff ff       	call   800e61 <fd_lookup>
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	78 3a                	js     801213 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d9:	83 ec 08             	sub    $0x8,%esp
  8011dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011df:	50                   	push   %eax
  8011e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e3:	ff 30                	pushl  (%eax)
  8011e5:	e8 cb fc ff ff       	call   800eb5 <dev_lookup>
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	78 22                	js     801213 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f8:	74 1e                	je     801218 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011fd:	8b 52 0c             	mov    0xc(%edx),%edx
  801200:	85 d2                	test   %edx,%edx
  801202:	74 35                	je     801239 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801204:	83 ec 04             	sub    $0x4,%esp
  801207:	ff 75 10             	pushl  0x10(%ebp)
  80120a:	ff 75 0c             	pushl  0xc(%ebp)
  80120d:	50                   	push   %eax
  80120e:	ff d2                	call   *%edx
  801210:	83 c4 10             	add    $0x10,%esp
}
  801213:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801216:	c9                   	leave  
  801217:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801218:	a1 04 40 80 00       	mov    0x804004,%eax
  80121d:	8b 40 48             	mov    0x48(%eax),%eax
  801220:	83 ec 04             	sub    $0x4,%esp
  801223:	53                   	push   %ebx
  801224:	50                   	push   %eax
  801225:	68 b5 23 80 00       	push   $0x8023b5
  80122a:	e8 e1 ef ff ff       	call   800210 <cprintf>
		return -E_INVAL;
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801237:	eb da                	jmp    801213 <write+0x59>
		return -E_NOT_SUPP;
  801239:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80123e:	eb d3                	jmp    801213 <write+0x59>

00801240 <seek>:

int
seek(int fdnum, off_t offset)
{
  801240:	f3 0f 1e fb          	endbr32 
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80124a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124d:	50                   	push   %eax
  80124e:	ff 75 08             	pushl  0x8(%ebp)
  801251:	e8 0b fc ff ff       	call   800e61 <fd_lookup>
  801256:	83 c4 10             	add    $0x10,%esp
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 0e                	js     80126b <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80125d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801260:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801263:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801266:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80126b:	c9                   	leave  
  80126c:	c3                   	ret    

0080126d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80126d:	f3 0f 1e fb          	endbr32 
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	53                   	push   %ebx
  801275:	83 ec 1c             	sub    $0x1c,%esp
  801278:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127e:	50                   	push   %eax
  80127f:	53                   	push   %ebx
  801280:	e8 dc fb ff ff       	call   800e61 <fd_lookup>
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	85 c0                	test   %eax,%eax
  80128a:	78 37                	js     8012c3 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128c:	83 ec 08             	sub    $0x8,%esp
  80128f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801292:	50                   	push   %eax
  801293:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801296:	ff 30                	pushl  (%eax)
  801298:	e8 18 fc ff ff       	call   800eb5 <dev_lookup>
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	78 1f                	js     8012c3 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012ab:	74 1b                	je     8012c8 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b0:	8b 52 18             	mov    0x18(%edx),%edx
  8012b3:	85 d2                	test   %edx,%edx
  8012b5:	74 32                	je     8012e9 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012b7:	83 ec 08             	sub    $0x8,%esp
  8012ba:	ff 75 0c             	pushl  0xc(%ebp)
  8012bd:	50                   	push   %eax
  8012be:	ff d2                	call   *%edx
  8012c0:	83 c4 10             	add    $0x10,%esp
}
  8012c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c6:	c9                   	leave  
  8012c7:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012c8:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012cd:	8b 40 48             	mov    0x48(%eax),%eax
  8012d0:	83 ec 04             	sub    $0x4,%esp
  8012d3:	53                   	push   %ebx
  8012d4:	50                   	push   %eax
  8012d5:	68 78 23 80 00       	push   $0x802378
  8012da:	e8 31 ef ff ff       	call   800210 <cprintf>
		return -E_INVAL;
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e7:	eb da                	jmp    8012c3 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8012e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012ee:	eb d3                	jmp    8012c3 <ftruncate+0x56>

008012f0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012f0:	f3 0f 1e fb          	endbr32 
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	53                   	push   %ebx
  8012f8:	83 ec 1c             	sub    $0x1c,%esp
  8012fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801301:	50                   	push   %eax
  801302:	ff 75 08             	pushl  0x8(%ebp)
  801305:	e8 57 fb ff ff       	call   800e61 <fd_lookup>
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 4b                	js     80135c <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801311:	83 ec 08             	sub    $0x8,%esp
  801314:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801317:	50                   	push   %eax
  801318:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131b:	ff 30                	pushl  (%eax)
  80131d:	e8 93 fb ff ff       	call   800eb5 <dev_lookup>
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	85 c0                	test   %eax,%eax
  801327:	78 33                	js     80135c <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801329:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801330:	74 2f                	je     801361 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801332:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801335:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80133c:	00 00 00 
	stat->st_isdir = 0;
  80133f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801346:	00 00 00 
	stat->st_dev = dev;
  801349:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	53                   	push   %ebx
  801353:	ff 75 f0             	pushl  -0x10(%ebp)
  801356:	ff 50 14             	call   *0x14(%eax)
  801359:	83 c4 10             	add    $0x10,%esp
}
  80135c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135f:	c9                   	leave  
  801360:	c3                   	ret    
		return -E_NOT_SUPP;
  801361:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801366:	eb f4                	jmp    80135c <fstat+0x6c>

00801368 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801368:	f3 0f 1e fb          	endbr32 
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	56                   	push   %esi
  801370:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801371:	83 ec 08             	sub    $0x8,%esp
  801374:	6a 00                	push   $0x0
  801376:	ff 75 08             	pushl  0x8(%ebp)
  801379:	e8 20 02 00 00       	call   80159e <open>
  80137e:	89 c3                	mov    %eax,%ebx
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	85 c0                	test   %eax,%eax
  801385:	78 1b                	js     8013a2 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801387:	83 ec 08             	sub    $0x8,%esp
  80138a:	ff 75 0c             	pushl  0xc(%ebp)
  80138d:	50                   	push   %eax
  80138e:	e8 5d ff ff ff       	call   8012f0 <fstat>
  801393:	89 c6                	mov    %eax,%esi
	close(fd);
  801395:	89 1c 24             	mov    %ebx,(%esp)
  801398:	e8 fd fb ff ff       	call   800f9a <close>
	return r;
  80139d:	83 c4 10             	add    $0x10,%esp
  8013a0:	89 f3                	mov    %esi,%ebx
}
  8013a2:	89 d8                	mov    %ebx,%eax
  8013a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a7:	5b                   	pop    %ebx
  8013a8:	5e                   	pop    %esi
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    

008013ab <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	56                   	push   %esi
  8013af:	53                   	push   %ebx
  8013b0:	89 c6                	mov    %eax,%esi
  8013b2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013b4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013bb:	74 27                	je     8013e4 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013bd:	6a 07                	push   $0x7
  8013bf:	68 00 50 80 00       	push   $0x805000
  8013c4:	56                   	push   %esi
  8013c5:	ff 35 00 40 80 00    	pushl  0x804000
  8013cb:	e8 e3 07 00 00       	call   801bb3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013d0:	83 c4 0c             	add    $0xc,%esp
  8013d3:	6a 00                	push   $0x0
  8013d5:	53                   	push   %ebx
  8013d6:	6a 00                	push   $0x0
  8013d8:	e8 69 07 00 00       	call   801b46 <ipc_recv>
}
  8013dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e0:	5b                   	pop    %ebx
  8013e1:	5e                   	pop    %esi
  8013e2:	5d                   	pop    %ebp
  8013e3:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013e4:	83 ec 0c             	sub    $0xc,%esp
  8013e7:	6a 01                	push   $0x1
  8013e9:	e8 18 08 00 00       	call   801c06 <ipc_find_env>
  8013ee:	a3 00 40 80 00       	mov    %eax,0x804000
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	eb c5                	jmp    8013bd <fsipc+0x12>

008013f8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013f8:	f3 0f 1e fb          	endbr32 
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801402:	8b 45 08             	mov    0x8(%ebp),%eax
  801405:	8b 40 0c             	mov    0xc(%eax),%eax
  801408:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80140d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801410:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801415:	ba 00 00 00 00       	mov    $0x0,%edx
  80141a:	b8 02 00 00 00       	mov    $0x2,%eax
  80141f:	e8 87 ff ff ff       	call   8013ab <fsipc>
}
  801424:	c9                   	leave  
  801425:	c3                   	ret    

00801426 <devfile_flush>:
{
  801426:	f3 0f 1e fb          	endbr32 
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801430:	8b 45 08             	mov    0x8(%ebp),%eax
  801433:	8b 40 0c             	mov    0xc(%eax),%eax
  801436:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80143b:	ba 00 00 00 00       	mov    $0x0,%edx
  801440:	b8 06 00 00 00       	mov    $0x6,%eax
  801445:	e8 61 ff ff ff       	call   8013ab <fsipc>
}
  80144a:	c9                   	leave  
  80144b:	c3                   	ret    

0080144c <devfile_stat>:
{
  80144c:	f3 0f 1e fb          	endbr32 
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	53                   	push   %ebx
  801454:	83 ec 04             	sub    $0x4,%esp
  801457:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80145a:	8b 45 08             	mov    0x8(%ebp),%eax
  80145d:	8b 40 0c             	mov    0xc(%eax),%eax
  801460:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801465:	ba 00 00 00 00       	mov    $0x0,%edx
  80146a:	b8 05 00 00 00       	mov    $0x5,%eax
  80146f:	e8 37 ff ff ff       	call   8013ab <fsipc>
  801474:	85 c0                	test   %eax,%eax
  801476:	78 2c                	js     8014a4 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801478:	83 ec 08             	sub    $0x8,%esp
  80147b:	68 00 50 80 00       	push   $0x805000
  801480:	53                   	push   %ebx
  801481:	e8 f4 f2 ff ff       	call   80077a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801486:	a1 80 50 80 00       	mov    0x805080,%eax
  80148b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801491:	a1 84 50 80 00       	mov    0x805084,%eax
  801496:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a7:	c9                   	leave  
  8014a8:	c3                   	ret    

008014a9 <devfile_write>:
{
  8014a9:	f3 0f 1e fb          	endbr32 
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	57                   	push   %edi
  8014b1:	56                   	push   %esi
  8014b2:	53                   	push   %ebx
  8014b3:	83 ec 0c             	sub    $0xc,%esp
  8014b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c2:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  8014c7:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8014cc:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  8014d1:	85 db                	test   %ebx,%ebx
  8014d3:	74 3b                	je     801510 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8014d5:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8014db:	89 f8                	mov    %edi,%eax
  8014dd:	0f 46 c3             	cmovbe %ebx,%eax
  8014e0:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  8014e5:	83 ec 04             	sub    $0x4,%esp
  8014e8:	50                   	push   %eax
  8014e9:	56                   	push   %esi
  8014ea:	68 08 50 80 00       	push   $0x805008
  8014ef:	e8 3e f4 ff ff       	call   800932 <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8014f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f9:	b8 04 00 00 00       	mov    $0x4,%eax
  8014fe:	e8 a8 fe ff ff       	call   8013ab <fsipc>
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	85 c0                	test   %eax,%eax
  801508:	78 06                	js     801510 <devfile_write+0x67>
		buf_aux += r;
  80150a:	01 c6                	add    %eax,%esi
		n -= r;
  80150c:	29 c3                	sub    %eax,%ebx
  80150e:	eb c1                	jmp    8014d1 <devfile_write+0x28>
}
  801510:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801513:	5b                   	pop    %ebx
  801514:	5e                   	pop    %esi
  801515:	5f                   	pop    %edi
  801516:	5d                   	pop    %ebp
  801517:	c3                   	ret    

00801518 <devfile_read>:
{
  801518:	f3 0f 1e fb          	endbr32 
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	56                   	push   %esi
  801520:	53                   	push   %ebx
  801521:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801524:	8b 45 08             	mov    0x8(%ebp),%eax
  801527:	8b 40 0c             	mov    0xc(%eax),%eax
  80152a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80152f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801535:	ba 00 00 00 00       	mov    $0x0,%edx
  80153a:	b8 03 00 00 00       	mov    $0x3,%eax
  80153f:	e8 67 fe ff ff       	call   8013ab <fsipc>
  801544:	89 c3                	mov    %eax,%ebx
  801546:	85 c0                	test   %eax,%eax
  801548:	78 1f                	js     801569 <devfile_read+0x51>
	assert(r <= n);
  80154a:	39 f0                	cmp    %esi,%eax
  80154c:	77 24                	ja     801572 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80154e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801553:	7f 33                	jg     801588 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801555:	83 ec 04             	sub    $0x4,%esp
  801558:	50                   	push   %eax
  801559:	68 00 50 80 00       	push   $0x805000
  80155e:	ff 75 0c             	pushl  0xc(%ebp)
  801561:	e8 cc f3 ff ff       	call   800932 <memmove>
	return r;
  801566:	83 c4 10             	add    $0x10,%esp
}
  801569:	89 d8                	mov    %ebx,%eax
  80156b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80156e:	5b                   	pop    %ebx
  80156f:	5e                   	pop    %esi
  801570:	5d                   	pop    %ebp
  801571:	c3                   	ret    
	assert(r <= n);
  801572:	68 e4 23 80 00       	push   $0x8023e4
  801577:	68 eb 23 80 00       	push   $0x8023eb
  80157c:	6a 7c                	push   $0x7c
  80157e:	68 00 24 80 00       	push   $0x802400
  801583:	e8 a1 eb ff ff       	call   800129 <_panic>
	assert(r <= PGSIZE);
  801588:	68 0b 24 80 00       	push   $0x80240b
  80158d:	68 eb 23 80 00       	push   $0x8023eb
  801592:	6a 7d                	push   $0x7d
  801594:	68 00 24 80 00       	push   $0x802400
  801599:	e8 8b eb ff ff       	call   800129 <_panic>

0080159e <open>:
{
  80159e:	f3 0f 1e fb          	endbr32 
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	56                   	push   %esi
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 1c             	sub    $0x1c,%esp
  8015aa:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015ad:	56                   	push   %esi
  8015ae:	e8 84 f1 ff ff       	call   800737 <strlen>
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015bb:	7f 6c                	jg     801629 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8015bd:	83 ec 0c             	sub    $0xc,%esp
  8015c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c3:	50                   	push   %eax
  8015c4:	e8 42 f8 ff ff       	call   800e0b <fd_alloc>
  8015c9:	89 c3                	mov    %eax,%ebx
  8015cb:	83 c4 10             	add    $0x10,%esp
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 3c                	js     80160e <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8015d2:	83 ec 08             	sub    $0x8,%esp
  8015d5:	56                   	push   %esi
  8015d6:	68 00 50 80 00       	push   $0x805000
  8015db:	e8 9a f1 ff ff       	call   80077a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f0:	e8 b6 fd ff ff       	call   8013ab <fsipc>
  8015f5:	89 c3                	mov    %eax,%ebx
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	78 19                	js     801617 <open+0x79>
	return fd2num(fd);
  8015fe:	83 ec 0c             	sub    $0xc,%esp
  801601:	ff 75 f4             	pushl  -0xc(%ebp)
  801604:	e8 cf f7 ff ff       	call   800dd8 <fd2num>
  801609:	89 c3                	mov    %eax,%ebx
  80160b:	83 c4 10             	add    $0x10,%esp
}
  80160e:	89 d8                	mov    %ebx,%eax
  801610:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801613:	5b                   	pop    %ebx
  801614:	5e                   	pop    %esi
  801615:	5d                   	pop    %ebp
  801616:	c3                   	ret    
		fd_close(fd, 0);
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	6a 00                	push   $0x0
  80161c:	ff 75 f4             	pushl  -0xc(%ebp)
  80161f:	e8 eb f8 ff ff       	call   800f0f <fd_close>
		return r;
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	eb e5                	jmp    80160e <open+0x70>
		return -E_BAD_PATH;
  801629:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80162e:	eb de                	jmp    80160e <open+0x70>

00801630 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801630:	f3 0f 1e fb          	endbr32 
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80163a:	ba 00 00 00 00       	mov    $0x0,%edx
  80163f:	b8 08 00 00 00       	mov    $0x8,%eax
  801644:	e8 62 fd ff ff       	call   8013ab <fsipc>
}
  801649:	c9                   	leave  
  80164a:	c3                   	ret    

0080164b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80164b:	f3 0f 1e fb          	endbr32 
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	56                   	push   %esi
  801653:	53                   	push   %ebx
  801654:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801657:	83 ec 0c             	sub    $0xc,%esp
  80165a:	ff 75 08             	pushl  0x8(%ebp)
  80165d:	e8 8a f7 ff ff       	call   800dec <fd2data>
  801662:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801664:	83 c4 08             	add    $0x8,%esp
  801667:	68 17 24 80 00       	push   $0x802417
  80166c:	53                   	push   %ebx
  80166d:	e8 08 f1 ff ff       	call   80077a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801672:	8b 46 04             	mov    0x4(%esi),%eax
  801675:	2b 06                	sub    (%esi),%eax
  801677:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80167d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801684:	00 00 00 
	stat->st_dev = &devpipe;
  801687:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80168e:	30 80 00 
	return 0;
}
  801691:	b8 00 00 00 00       	mov    $0x0,%eax
  801696:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801699:	5b                   	pop    %ebx
  80169a:	5e                   	pop    %esi
  80169b:	5d                   	pop    %ebp
  80169c:	c3                   	ret    

0080169d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80169d:	f3 0f 1e fb          	endbr32 
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	53                   	push   %ebx
  8016a5:	83 ec 0c             	sub    $0xc,%esp
  8016a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016ab:	53                   	push   %ebx
  8016ac:	6a 00                	push   $0x0
  8016ae:	e8 a1 f5 ff ff       	call   800c54 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016b3:	89 1c 24             	mov    %ebx,(%esp)
  8016b6:	e8 31 f7 ff ff       	call   800dec <fd2data>
  8016bb:	83 c4 08             	add    $0x8,%esp
  8016be:	50                   	push   %eax
  8016bf:	6a 00                	push   $0x0
  8016c1:	e8 8e f5 ff ff       	call   800c54 <sys_page_unmap>
}
  8016c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c9:	c9                   	leave  
  8016ca:	c3                   	ret    

008016cb <_pipeisclosed>:
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	57                   	push   %edi
  8016cf:	56                   	push   %esi
  8016d0:	53                   	push   %ebx
  8016d1:	83 ec 1c             	sub    $0x1c,%esp
  8016d4:	89 c7                	mov    %eax,%edi
  8016d6:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8016d8:	a1 04 40 80 00       	mov    0x804004,%eax
  8016dd:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016e0:	83 ec 0c             	sub    $0xc,%esp
  8016e3:	57                   	push   %edi
  8016e4:	e8 5a 05 00 00       	call   801c43 <pageref>
  8016e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016ec:	89 34 24             	mov    %esi,(%esp)
  8016ef:	e8 4f 05 00 00       	call   801c43 <pageref>
		nn = thisenv->env_runs;
  8016f4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016fa:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	39 cb                	cmp    %ecx,%ebx
  801702:	74 1b                	je     80171f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801704:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801707:	75 cf                	jne    8016d8 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801709:	8b 42 58             	mov    0x58(%edx),%eax
  80170c:	6a 01                	push   $0x1
  80170e:	50                   	push   %eax
  80170f:	53                   	push   %ebx
  801710:	68 1e 24 80 00       	push   $0x80241e
  801715:	e8 f6 ea ff ff       	call   800210 <cprintf>
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	eb b9                	jmp    8016d8 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80171f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801722:	0f 94 c0             	sete   %al
  801725:	0f b6 c0             	movzbl %al,%eax
}
  801728:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172b:	5b                   	pop    %ebx
  80172c:	5e                   	pop    %esi
  80172d:	5f                   	pop    %edi
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    

00801730 <devpipe_write>:
{
  801730:	f3 0f 1e fb          	endbr32 
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	57                   	push   %edi
  801738:	56                   	push   %esi
  801739:	53                   	push   %ebx
  80173a:	83 ec 28             	sub    $0x28,%esp
  80173d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801740:	56                   	push   %esi
  801741:	e8 a6 f6 ff ff       	call   800dec <fd2data>
  801746:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	bf 00 00 00 00       	mov    $0x0,%edi
  801750:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801753:	74 4f                	je     8017a4 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801755:	8b 43 04             	mov    0x4(%ebx),%eax
  801758:	8b 0b                	mov    (%ebx),%ecx
  80175a:	8d 51 20             	lea    0x20(%ecx),%edx
  80175d:	39 d0                	cmp    %edx,%eax
  80175f:	72 14                	jb     801775 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801761:	89 da                	mov    %ebx,%edx
  801763:	89 f0                	mov    %esi,%eax
  801765:	e8 61 ff ff ff       	call   8016cb <_pipeisclosed>
  80176a:	85 c0                	test   %eax,%eax
  80176c:	75 3b                	jne    8017a9 <devpipe_write+0x79>
			sys_yield();
  80176e:	e8 64 f4 ff ff       	call   800bd7 <sys_yield>
  801773:	eb e0                	jmp    801755 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801775:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801778:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80177c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80177f:	89 c2                	mov    %eax,%edx
  801781:	c1 fa 1f             	sar    $0x1f,%edx
  801784:	89 d1                	mov    %edx,%ecx
  801786:	c1 e9 1b             	shr    $0x1b,%ecx
  801789:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80178c:	83 e2 1f             	and    $0x1f,%edx
  80178f:	29 ca                	sub    %ecx,%edx
  801791:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801795:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801799:	83 c0 01             	add    $0x1,%eax
  80179c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80179f:	83 c7 01             	add    $0x1,%edi
  8017a2:	eb ac                	jmp    801750 <devpipe_write+0x20>
	return i;
  8017a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a7:	eb 05                	jmp    8017ae <devpipe_write+0x7e>
				return 0;
  8017a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b1:	5b                   	pop    %ebx
  8017b2:	5e                   	pop    %esi
  8017b3:	5f                   	pop    %edi
  8017b4:	5d                   	pop    %ebp
  8017b5:	c3                   	ret    

008017b6 <devpipe_read>:
{
  8017b6:	f3 0f 1e fb          	endbr32 
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	57                   	push   %edi
  8017be:	56                   	push   %esi
  8017bf:	53                   	push   %ebx
  8017c0:	83 ec 18             	sub    $0x18,%esp
  8017c3:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8017c6:	57                   	push   %edi
  8017c7:	e8 20 f6 ff ff       	call   800dec <fd2data>
  8017cc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	be 00 00 00 00       	mov    $0x0,%esi
  8017d6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017d9:	75 14                	jne    8017ef <devpipe_read+0x39>
	return i;
  8017db:	8b 45 10             	mov    0x10(%ebp),%eax
  8017de:	eb 02                	jmp    8017e2 <devpipe_read+0x2c>
				return i;
  8017e0:	89 f0                	mov    %esi,%eax
}
  8017e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	5f                   	pop    %edi
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    
			sys_yield();
  8017ea:	e8 e8 f3 ff ff       	call   800bd7 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8017ef:	8b 03                	mov    (%ebx),%eax
  8017f1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017f4:	75 18                	jne    80180e <devpipe_read+0x58>
			if (i > 0)
  8017f6:	85 f6                	test   %esi,%esi
  8017f8:	75 e6                	jne    8017e0 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8017fa:	89 da                	mov    %ebx,%edx
  8017fc:	89 f8                	mov    %edi,%eax
  8017fe:	e8 c8 fe ff ff       	call   8016cb <_pipeisclosed>
  801803:	85 c0                	test   %eax,%eax
  801805:	74 e3                	je     8017ea <devpipe_read+0x34>
				return 0;
  801807:	b8 00 00 00 00       	mov    $0x0,%eax
  80180c:	eb d4                	jmp    8017e2 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80180e:	99                   	cltd   
  80180f:	c1 ea 1b             	shr    $0x1b,%edx
  801812:	01 d0                	add    %edx,%eax
  801814:	83 e0 1f             	and    $0x1f,%eax
  801817:	29 d0                	sub    %edx,%eax
  801819:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80181e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801821:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801824:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801827:	83 c6 01             	add    $0x1,%esi
  80182a:	eb aa                	jmp    8017d6 <devpipe_read+0x20>

0080182c <pipe>:
{
  80182c:	f3 0f 1e fb          	endbr32 
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	56                   	push   %esi
  801834:	53                   	push   %ebx
  801835:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801838:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183b:	50                   	push   %eax
  80183c:	e8 ca f5 ff ff       	call   800e0b <fd_alloc>
  801841:	89 c3                	mov    %eax,%ebx
  801843:	83 c4 10             	add    $0x10,%esp
  801846:	85 c0                	test   %eax,%eax
  801848:	0f 88 23 01 00 00    	js     801971 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80184e:	83 ec 04             	sub    $0x4,%esp
  801851:	68 07 04 00 00       	push   $0x407
  801856:	ff 75 f4             	pushl  -0xc(%ebp)
  801859:	6a 00                	push   $0x0
  80185b:	e8 a2 f3 ff ff       	call   800c02 <sys_page_alloc>
  801860:	89 c3                	mov    %eax,%ebx
  801862:	83 c4 10             	add    $0x10,%esp
  801865:	85 c0                	test   %eax,%eax
  801867:	0f 88 04 01 00 00    	js     801971 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80186d:	83 ec 0c             	sub    $0xc,%esp
  801870:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801873:	50                   	push   %eax
  801874:	e8 92 f5 ff ff       	call   800e0b <fd_alloc>
  801879:	89 c3                	mov    %eax,%ebx
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	85 c0                	test   %eax,%eax
  801880:	0f 88 db 00 00 00    	js     801961 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801886:	83 ec 04             	sub    $0x4,%esp
  801889:	68 07 04 00 00       	push   $0x407
  80188e:	ff 75 f0             	pushl  -0x10(%ebp)
  801891:	6a 00                	push   $0x0
  801893:	e8 6a f3 ff ff       	call   800c02 <sys_page_alloc>
  801898:	89 c3                	mov    %eax,%ebx
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	85 c0                	test   %eax,%eax
  80189f:	0f 88 bc 00 00 00    	js     801961 <pipe+0x135>
	va = fd2data(fd0);
  8018a5:	83 ec 0c             	sub    $0xc,%esp
  8018a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ab:	e8 3c f5 ff ff       	call   800dec <fd2data>
  8018b0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b2:	83 c4 0c             	add    $0xc,%esp
  8018b5:	68 07 04 00 00       	push   $0x407
  8018ba:	50                   	push   %eax
  8018bb:	6a 00                	push   $0x0
  8018bd:	e8 40 f3 ff ff       	call   800c02 <sys_page_alloc>
  8018c2:	89 c3                	mov    %eax,%ebx
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	0f 88 82 00 00 00    	js     801951 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018cf:	83 ec 0c             	sub    $0xc,%esp
  8018d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d5:	e8 12 f5 ff ff       	call   800dec <fd2data>
  8018da:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018e1:	50                   	push   %eax
  8018e2:	6a 00                	push   $0x0
  8018e4:	56                   	push   %esi
  8018e5:	6a 00                	push   $0x0
  8018e7:	e8 3e f3 ff ff       	call   800c2a <sys_page_map>
  8018ec:	89 c3                	mov    %eax,%ebx
  8018ee:	83 c4 20             	add    $0x20,%esp
  8018f1:	85 c0                	test   %eax,%eax
  8018f3:	78 4e                	js     801943 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8018f5:	a1 20 30 80 00       	mov    0x803020,%eax
  8018fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018fd:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8018ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801902:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801909:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80190c:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80190e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801911:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801918:	83 ec 0c             	sub    $0xc,%esp
  80191b:	ff 75 f4             	pushl  -0xc(%ebp)
  80191e:	e8 b5 f4 ff ff       	call   800dd8 <fd2num>
  801923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801926:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801928:	83 c4 04             	add    $0x4,%esp
  80192b:	ff 75 f0             	pushl  -0x10(%ebp)
  80192e:	e8 a5 f4 ff ff       	call   800dd8 <fd2num>
  801933:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801936:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801939:	83 c4 10             	add    $0x10,%esp
  80193c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801941:	eb 2e                	jmp    801971 <pipe+0x145>
	sys_page_unmap(0, va);
  801943:	83 ec 08             	sub    $0x8,%esp
  801946:	56                   	push   %esi
  801947:	6a 00                	push   $0x0
  801949:	e8 06 f3 ff ff       	call   800c54 <sys_page_unmap>
  80194e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	ff 75 f0             	pushl  -0x10(%ebp)
  801957:	6a 00                	push   $0x0
  801959:	e8 f6 f2 ff ff       	call   800c54 <sys_page_unmap>
  80195e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801961:	83 ec 08             	sub    $0x8,%esp
  801964:	ff 75 f4             	pushl  -0xc(%ebp)
  801967:	6a 00                	push   $0x0
  801969:	e8 e6 f2 ff ff       	call   800c54 <sys_page_unmap>
  80196e:	83 c4 10             	add    $0x10,%esp
}
  801971:	89 d8                	mov    %ebx,%eax
  801973:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801976:	5b                   	pop    %ebx
  801977:	5e                   	pop    %esi
  801978:	5d                   	pop    %ebp
  801979:	c3                   	ret    

0080197a <pipeisclosed>:
{
  80197a:	f3 0f 1e fb          	endbr32 
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801984:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801987:	50                   	push   %eax
  801988:	ff 75 08             	pushl  0x8(%ebp)
  80198b:	e8 d1 f4 ff ff       	call   800e61 <fd_lookup>
  801990:	83 c4 10             	add    $0x10,%esp
  801993:	85 c0                	test   %eax,%eax
  801995:	78 18                	js     8019af <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801997:	83 ec 0c             	sub    $0xc,%esp
  80199a:	ff 75 f4             	pushl  -0xc(%ebp)
  80199d:	e8 4a f4 ff ff       	call   800dec <fd2data>
  8019a2:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8019a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a7:	e8 1f fd ff ff       	call   8016cb <_pipeisclosed>
  8019ac:	83 c4 10             	add    $0x10,%esp
}
  8019af:	c9                   	leave  
  8019b0:	c3                   	ret    

008019b1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019b1:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  8019b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ba:	c3                   	ret    

008019bb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019bb:	f3 0f 1e fb          	endbr32 
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019c5:	68 36 24 80 00       	push   $0x802436
  8019ca:	ff 75 0c             	pushl  0xc(%ebp)
  8019cd:	e8 a8 ed ff ff       	call   80077a <strcpy>
	return 0;
}
  8019d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d7:	c9                   	leave  
  8019d8:	c3                   	ret    

008019d9 <devcons_write>:
{
  8019d9:	f3 0f 1e fb          	endbr32 
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	57                   	push   %edi
  8019e1:	56                   	push   %esi
  8019e2:	53                   	push   %ebx
  8019e3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8019e9:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019ee:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8019f4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019f7:	73 31                	jae    801a2a <devcons_write+0x51>
		m = n - tot;
  8019f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019fc:	29 f3                	sub    %esi,%ebx
  8019fe:	83 fb 7f             	cmp    $0x7f,%ebx
  801a01:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801a06:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a09:	83 ec 04             	sub    $0x4,%esp
  801a0c:	53                   	push   %ebx
  801a0d:	89 f0                	mov    %esi,%eax
  801a0f:	03 45 0c             	add    0xc(%ebp),%eax
  801a12:	50                   	push   %eax
  801a13:	57                   	push   %edi
  801a14:	e8 19 ef ff ff       	call   800932 <memmove>
		sys_cputs(buf, m);
  801a19:	83 c4 08             	add    $0x8,%esp
  801a1c:	53                   	push   %ebx
  801a1d:	57                   	push   %edi
  801a1e:	e8 14 f1 ff ff       	call   800b37 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801a23:	01 de                	add    %ebx,%esi
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	eb ca                	jmp    8019f4 <devcons_write+0x1b>
}
  801a2a:	89 f0                	mov    %esi,%eax
  801a2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2f:	5b                   	pop    %ebx
  801a30:	5e                   	pop    %esi
  801a31:	5f                   	pop    %edi
  801a32:	5d                   	pop    %ebp
  801a33:	c3                   	ret    

00801a34 <devcons_read>:
{
  801a34:	f3 0f 1e fb          	endbr32 
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	83 ec 08             	sub    $0x8,%esp
  801a3e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a43:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a47:	74 21                	je     801a6a <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801a49:	e8 13 f1 ff ff       	call   800b61 <sys_cgetc>
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	75 07                	jne    801a59 <devcons_read+0x25>
		sys_yield();
  801a52:	e8 80 f1 ff ff       	call   800bd7 <sys_yield>
  801a57:	eb f0                	jmp    801a49 <devcons_read+0x15>
	if (c < 0)
  801a59:	78 0f                	js     801a6a <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801a5b:	83 f8 04             	cmp    $0x4,%eax
  801a5e:	74 0c                	je     801a6c <devcons_read+0x38>
	*(char*)vbuf = c;
  801a60:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a63:	88 02                	mov    %al,(%edx)
	return 1;
  801a65:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801a6a:	c9                   	leave  
  801a6b:	c3                   	ret    
		return 0;
  801a6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a71:	eb f7                	jmp    801a6a <devcons_read+0x36>

00801a73 <cputchar>:
{
  801a73:	f3 0f 1e fb          	endbr32 
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a80:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a83:	6a 01                	push   $0x1
  801a85:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a88:	50                   	push   %eax
  801a89:	e8 a9 f0 ff ff       	call   800b37 <sys_cputs>
}
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	c9                   	leave  
  801a92:	c3                   	ret    

00801a93 <getchar>:
{
  801a93:	f3 0f 1e fb          	endbr32 
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801a9d:	6a 01                	push   $0x1
  801a9f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aa2:	50                   	push   %eax
  801aa3:	6a 00                	push   $0x0
  801aa5:	e8 3a f6 ff ff       	call   8010e4 <read>
	if (r < 0)
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	78 06                	js     801ab7 <getchar+0x24>
	if (r < 1)
  801ab1:	74 06                	je     801ab9 <getchar+0x26>
	return c;
  801ab3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    
		return -E_EOF;
  801ab9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801abe:	eb f7                	jmp    801ab7 <getchar+0x24>

00801ac0 <iscons>:
{
  801ac0:	f3 0f 1e fb          	endbr32 
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acd:	50                   	push   %eax
  801ace:	ff 75 08             	pushl  0x8(%ebp)
  801ad1:	e8 8b f3 ff ff       	call   800e61 <fd_lookup>
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	85 c0                	test   %eax,%eax
  801adb:	78 11                	js     801aee <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801add:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ae6:	39 10                	cmp    %edx,(%eax)
  801ae8:	0f 94 c0             	sete   %al
  801aeb:	0f b6 c0             	movzbl %al,%eax
}
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    

00801af0 <opencons>:
{
  801af0:	f3 0f 1e fb          	endbr32 
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801afa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801afd:	50                   	push   %eax
  801afe:	e8 08 f3 ff ff       	call   800e0b <fd_alloc>
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	85 c0                	test   %eax,%eax
  801b08:	78 3a                	js     801b44 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b0a:	83 ec 04             	sub    $0x4,%esp
  801b0d:	68 07 04 00 00       	push   $0x407
  801b12:	ff 75 f4             	pushl  -0xc(%ebp)
  801b15:	6a 00                	push   $0x0
  801b17:	e8 e6 f0 ff ff       	call   800c02 <sys_page_alloc>
  801b1c:	83 c4 10             	add    $0x10,%esp
  801b1f:	85 c0                	test   %eax,%eax
  801b21:	78 21                	js     801b44 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b26:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b2c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b31:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b38:	83 ec 0c             	sub    $0xc,%esp
  801b3b:	50                   	push   %eax
  801b3c:	e8 97 f2 ff ff       	call   800dd8 <fd2num>
  801b41:	83 c4 10             	add    $0x10,%esp
}
  801b44:	c9                   	leave  
  801b45:	c3                   	ret    

00801b46 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b46:	f3 0f 1e fb          	endbr32 
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	56                   	push   %esi
  801b4e:	53                   	push   %ebx
  801b4f:	8b 75 08             	mov    0x8(%ebp),%esi
  801b52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  801b58:	85 c0                	test   %eax,%eax
  801b5a:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b5f:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801b62:	83 ec 0c             	sub    $0xc,%esp
  801b65:	50                   	push   %eax
  801b66:	e8 ae f1 ff ff       	call   800d19 <sys_ipc_recv>
	if (f < 0) {
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	78 2b                	js     801b9d <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801b72:	85 f6                	test   %esi,%esi
  801b74:	74 0a                	je     801b80 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801b76:	a1 04 40 80 00       	mov    0x804004,%eax
  801b7b:	8b 40 74             	mov    0x74(%eax),%eax
  801b7e:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801b80:	85 db                	test   %ebx,%ebx
  801b82:	74 0a                	je     801b8e <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801b84:	a1 04 40 80 00       	mov    0x804004,%eax
  801b89:	8b 40 78             	mov    0x78(%eax),%eax
  801b8c:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  801b8e:	a1 04 40 80 00       	mov    0x804004,%eax
  801b93:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b99:	5b                   	pop    %ebx
  801b9a:	5e                   	pop    %esi
  801b9b:	5d                   	pop    %ebp
  801b9c:	c3                   	ret    
		if (from_env_store != NULL) {
  801b9d:	85 f6                	test   %esi,%esi
  801b9f:	74 06                	je     801ba7 <ipc_recv+0x61>
			*from_env_store = 0;
  801ba1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801ba7:	85 db                	test   %ebx,%ebx
  801ba9:	74 eb                	je     801b96 <ipc_recv+0x50>
			*perm_store = 0;
  801bab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801bb1:	eb e3                	jmp    801b96 <ipc_recv+0x50>

00801bb3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bb3:	f3 0f 1e fb          	endbr32 
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	57                   	push   %edi
  801bbb:	56                   	push   %esi
  801bbc:	53                   	push   %ebx
  801bbd:	83 ec 0c             	sub    $0xc,%esp
  801bc0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bc3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  801bc9:	85 db                	test   %ebx,%ebx
  801bcb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801bd0:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801bd3:	ff 75 14             	pushl  0x14(%ebp)
  801bd6:	53                   	push   %ebx
  801bd7:	56                   	push   %esi
  801bd8:	57                   	push   %edi
  801bd9:	e8 12 f1 ff ff       	call   800cf0 <sys_ipc_try_send>
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	85 c0                	test   %eax,%eax
  801be3:	79 19                	jns    801bfe <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  801be5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801be8:	74 e9                	je     801bd3 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  801bea:	83 ec 04             	sub    $0x4,%esp
  801bed:	68 44 24 80 00       	push   $0x802444
  801bf2:	6a 48                	push   $0x48
  801bf4:	68 66 24 80 00       	push   $0x802466
  801bf9:	e8 2b e5 ff ff       	call   800129 <_panic>
		}
	}
}
  801bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c01:	5b                   	pop    %ebx
  801c02:	5e                   	pop    %esi
  801c03:	5f                   	pop    %edi
  801c04:	5d                   	pop    %ebp
  801c05:	c3                   	ret    

00801c06 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c06:	f3 0f 1e fb          	endbr32 
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c10:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c15:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c18:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c1e:	8b 52 50             	mov    0x50(%edx),%edx
  801c21:	39 ca                	cmp    %ecx,%edx
  801c23:	74 11                	je     801c36 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c25:	83 c0 01             	add    $0x1,%eax
  801c28:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c2d:	75 e6                	jne    801c15 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c34:	eb 0b                	jmp    801c41 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c36:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c39:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c3e:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c41:	5d                   	pop    %ebp
  801c42:	c3                   	ret    

00801c43 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c43:	f3 0f 1e fb          	endbr32 
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c4d:	89 c2                	mov    %eax,%edx
  801c4f:	c1 ea 16             	shr    $0x16,%edx
  801c52:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c59:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c5e:	f6 c1 01             	test   $0x1,%cl
  801c61:	74 1c                	je     801c7f <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c63:	c1 e8 0c             	shr    $0xc,%eax
  801c66:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c6d:	a8 01                	test   $0x1,%al
  801c6f:	74 0e                	je     801c7f <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c71:	c1 e8 0c             	shr    $0xc,%eax
  801c74:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c7b:	ef 
  801c7c:	0f b7 d2             	movzwl %dx,%edx
}
  801c7f:	89 d0                	mov    %edx,%eax
  801c81:	5d                   	pop    %ebp
  801c82:	c3                   	ret    
  801c83:	66 90                	xchg   %ax,%ax
  801c85:	66 90                	xchg   %ax,%ax
  801c87:	66 90                	xchg   %ax,%ax
  801c89:	66 90                	xchg   %ax,%ax
  801c8b:	66 90                	xchg   %ax,%ax
  801c8d:	66 90                	xchg   %ax,%ax
  801c8f:	90                   	nop

00801c90 <__udivdi3>:
  801c90:	f3 0f 1e fb          	endbr32 
  801c94:	55                   	push   %ebp
  801c95:	57                   	push   %edi
  801c96:	56                   	push   %esi
  801c97:	53                   	push   %ebx
  801c98:	83 ec 1c             	sub    $0x1c,%esp
  801c9b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c9f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801ca3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ca7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801cab:	85 d2                	test   %edx,%edx
  801cad:	75 19                	jne    801cc8 <__udivdi3+0x38>
  801caf:	39 f3                	cmp    %esi,%ebx
  801cb1:	76 4d                	jbe    801d00 <__udivdi3+0x70>
  801cb3:	31 ff                	xor    %edi,%edi
  801cb5:	89 e8                	mov    %ebp,%eax
  801cb7:	89 f2                	mov    %esi,%edx
  801cb9:	f7 f3                	div    %ebx
  801cbb:	89 fa                	mov    %edi,%edx
  801cbd:	83 c4 1c             	add    $0x1c,%esp
  801cc0:	5b                   	pop    %ebx
  801cc1:	5e                   	pop    %esi
  801cc2:	5f                   	pop    %edi
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    
  801cc5:	8d 76 00             	lea    0x0(%esi),%esi
  801cc8:	39 f2                	cmp    %esi,%edx
  801cca:	76 14                	jbe    801ce0 <__udivdi3+0x50>
  801ccc:	31 ff                	xor    %edi,%edi
  801cce:	31 c0                	xor    %eax,%eax
  801cd0:	89 fa                	mov    %edi,%edx
  801cd2:	83 c4 1c             	add    $0x1c,%esp
  801cd5:	5b                   	pop    %ebx
  801cd6:	5e                   	pop    %esi
  801cd7:	5f                   	pop    %edi
  801cd8:	5d                   	pop    %ebp
  801cd9:	c3                   	ret    
  801cda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ce0:	0f bd fa             	bsr    %edx,%edi
  801ce3:	83 f7 1f             	xor    $0x1f,%edi
  801ce6:	75 48                	jne    801d30 <__udivdi3+0xa0>
  801ce8:	39 f2                	cmp    %esi,%edx
  801cea:	72 06                	jb     801cf2 <__udivdi3+0x62>
  801cec:	31 c0                	xor    %eax,%eax
  801cee:	39 eb                	cmp    %ebp,%ebx
  801cf0:	77 de                	ja     801cd0 <__udivdi3+0x40>
  801cf2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf7:	eb d7                	jmp    801cd0 <__udivdi3+0x40>
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 d9                	mov    %ebx,%ecx
  801d02:	85 db                	test   %ebx,%ebx
  801d04:	75 0b                	jne    801d11 <__udivdi3+0x81>
  801d06:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0b:	31 d2                	xor    %edx,%edx
  801d0d:	f7 f3                	div    %ebx
  801d0f:	89 c1                	mov    %eax,%ecx
  801d11:	31 d2                	xor    %edx,%edx
  801d13:	89 f0                	mov    %esi,%eax
  801d15:	f7 f1                	div    %ecx
  801d17:	89 c6                	mov    %eax,%esi
  801d19:	89 e8                	mov    %ebp,%eax
  801d1b:	89 f7                	mov    %esi,%edi
  801d1d:	f7 f1                	div    %ecx
  801d1f:	89 fa                	mov    %edi,%edx
  801d21:	83 c4 1c             	add    $0x1c,%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    
  801d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d30:	89 f9                	mov    %edi,%ecx
  801d32:	b8 20 00 00 00       	mov    $0x20,%eax
  801d37:	29 f8                	sub    %edi,%eax
  801d39:	d3 e2                	shl    %cl,%edx
  801d3b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d3f:	89 c1                	mov    %eax,%ecx
  801d41:	89 da                	mov    %ebx,%edx
  801d43:	d3 ea                	shr    %cl,%edx
  801d45:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d49:	09 d1                	or     %edx,%ecx
  801d4b:	89 f2                	mov    %esi,%edx
  801d4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d51:	89 f9                	mov    %edi,%ecx
  801d53:	d3 e3                	shl    %cl,%ebx
  801d55:	89 c1                	mov    %eax,%ecx
  801d57:	d3 ea                	shr    %cl,%edx
  801d59:	89 f9                	mov    %edi,%ecx
  801d5b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d5f:	89 eb                	mov    %ebp,%ebx
  801d61:	d3 e6                	shl    %cl,%esi
  801d63:	89 c1                	mov    %eax,%ecx
  801d65:	d3 eb                	shr    %cl,%ebx
  801d67:	09 de                	or     %ebx,%esi
  801d69:	89 f0                	mov    %esi,%eax
  801d6b:	f7 74 24 08          	divl   0x8(%esp)
  801d6f:	89 d6                	mov    %edx,%esi
  801d71:	89 c3                	mov    %eax,%ebx
  801d73:	f7 64 24 0c          	mull   0xc(%esp)
  801d77:	39 d6                	cmp    %edx,%esi
  801d79:	72 15                	jb     801d90 <__udivdi3+0x100>
  801d7b:	89 f9                	mov    %edi,%ecx
  801d7d:	d3 e5                	shl    %cl,%ebp
  801d7f:	39 c5                	cmp    %eax,%ebp
  801d81:	73 04                	jae    801d87 <__udivdi3+0xf7>
  801d83:	39 d6                	cmp    %edx,%esi
  801d85:	74 09                	je     801d90 <__udivdi3+0x100>
  801d87:	89 d8                	mov    %ebx,%eax
  801d89:	31 ff                	xor    %edi,%edi
  801d8b:	e9 40 ff ff ff       	jmp    801cd0 <__udivdi3+0x40>
  801d90:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d93:	31 ff                	xor    %edi,%edi
  801d95:	e9 36 ff ff ff       	jmp    801cd0 <__udivdi3+0x40>
  801d9a:	66 90                	xchg   %ax,%ax
  801d9c:	66 90                	xchg   %ax,%ax
  801d9e:	66 90                	xchg   %ax,%ax

00801da0 <__umoddi3>:
  801da0:	f3 0f 1e fb          	endbr32 
  801da4:	55                   	push   %ebp
  801da5:	57                   	push   %edi
  801da6:	56                   	push   %esi
  801da7:	53                   	push   %ebx
  801da8:	83 ec 1c             	sub    $0x1c,%esp
  801dab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801daf:	8b 74 24 30          	mov    0x30(%esp),%esi
  801db3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801db7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	75 19                	jne    801dd8 <__umoddi3+0x38>
  801dbf:	39 df                	cmp    %ebx,%edi
  801dc1:	76 5d                	jbe    801e20 <__umoddi3+0x80>
  801dc3:	89 f0                	mov    %esi,%eax
  801dc5:	89 da                	mov    %ebx,%edx
  801dc7:	f7 f7                	div    %edi
  801dc9:	89 d0                	mov    %edx,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  801dcd:	83 c4 1c             	add    $0x1c,%esp
  801dd0:	5b                   	pop    %ebx
  801dd1:	5e                   	pop    %esi
  801dd2:	5f                   	pop    %edi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    
  801dd5:	8d 76 00             	lea    0x0(%esi),%esi
  801dd8:	89 f2                	mov    %esi,%edx
  801dda:	39 d8                	cmp    %ebx,%eax
  801ddc:	76 12                	jbe    801df0 <__umoddi3+0x50>
  801dde:	89 f0                	mov    %esi,%eax
  801de0:	89 da                	mov    %ebx,%edx
  801de2:	83 c4 1c             	add    $0x1c,%esp
  801de5:	5b                   	pop    %ebx
  801de6:	5e                   	pop    %esi
  801de7:	5f                   	pop    %edi
  801de8:	5d                   	pop    %ebp
  801de9:	c3                   	ret    
  801dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801df0:	0f bd e8             	bsr    %eax,%ebp
  801df3:	83 f5 1f             	xor    $0x1f,%ebp
  801df6:	75 50                	jne    801e48 <__umoddi3+0xa8>
  801df8:	39 d8                	cmp    %ebx,%eax
  801dfa:	0f 82 e0 00 00 00    	jb     801ee0 <__umoddi3+0x140>
  801e00:	89 d9                	mov    %ebx,%ecx
  801e02:	39 f7                	cmp    %esi,%edi
  801e04:	0f 86 d6 00 00 00    	jbe    801ee0 <__umoddi3+0x140>
  801e0a:	89 d0                	mov    %edx,%eax
  801e0c:	89 ca                	mov    %ecx,%edx
  801e0e:	83 c4 1c             	add    $0x1c,%esp
  801e11:	5b                   	pop    %ebx
  801e12:	5e                   	pop    %esi
  801e13:	5f                   	pop    %edi
  801e14:	5d                   	pop    %ebp
  801e15:	c3                   	ret    
  801e16:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e1d:	8d 76 00             	lea    0x0(%esi),%esi
  801e20:	89 fd                	mov    %edi,%ebp
  801e22:	85 ff                	test   %edi,%edi
  801e24:	75 0b                	jne    801e31 <__umoddi3+0x91>
  801e26:	b8 01 00 00 00       	mov    $0x1,%eax
  801e2b:	31 d2                	xor    %edx,%edx
  801e2d:	f7 f7                	div    %edi
  801e2f:	89 c5                	mov    %eax,%ebp
  801e31:	89 d8                	mov    %ebx,%eax
  801e33:	31 d2                	xor    %edx,%edx
  801e35:	f7 f5                	div    %ebp
  801e37:	89 f0                	mov    %esi,%eax
  801e39:	f7 f5                	div    %ebp
  801e3b:	89 d0                	mov    %edx,%eax
  801e3d:	31 d2                	xor    %edx,%edx
  801e3f:	eb 8c                	jmp    801dcd <__umoddi3+0x2d>
  801e41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e48:	89 e9                	mov    %ebp,%ecx
  801e4a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e4f:	29 ea                	sub    %ebp,%edx
  801e51:	d3 e0                	shl    %cl,%eax
  801e53:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e57:	89 d1                	mov    %edx,%ecx
  801e59:	89 f8                	mov    %edi,%eax
  801e5b:	d3 e8                	shr    %cl,%eax
  801e5d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e61:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e65:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e69:	09 c1                	or     %eax,%ecx
  801e6b:	89 d8                	mov    %ebx,%eax
  801e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e71:	89 e9                	mov    %ebp,%ecx
  801e73:	d3 e7                	shl    %cl,%edi
  801e75:	89 d1                	mov    %edx,%ecx
  801e77:	d3 e8                	shr    %cl,%eax
  801e79:	89 e9                	mov    %ebp,%ecx
  801e7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e7f:	d3 e3                	shl    %cl,%ebx
  801e81:	89 c7                	mov    %eax,%edi
  801e83:	89 d1                	mov    %edx,%ecx
  801e85:	89 f0                	mov    %esi,%eax
  801e87:	d3 e8                	shr    %cl,%eax
  801e89:	89 e9                	mov    %ebp,%ecx
  801e8b:	89 fa                	mov    %edi,%edx
  801e8d:	d3 e6                	shl    %cl,%esi
  801e8f:	09 d8                	or     %ebx,%eax
  801e91:	f7 74 24 08          	divl   0x8(%esp)
  801e95:	89 d1                	mov    %edx,%ecx
  801e97:	89 f3                	mov    %esi,%ebx
  801e99:	f7 64 24 0c          	mull   0xc(%esp)
  801e9d:	89 c6                	mov    %eax,%esi
  801e9f:	89 d7                	mov    %edx,%edi
  801ea1:	39 d1                	cmp    %edx,%ecx
  801ea3:	72 06                	jb     801eab <__umoddi3+0x10b>
  801ea5:	75 10                	jne    801eb7 <__umoddi3+0x117>
  801ea7:	39 c3                	cmp    %eax,%ebx
  801ea9:	73 0c                	jae    801eb7 <__umoddi3+0x117>
  801eab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801eaf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801eb3:	89 d7                	mov    %edx,%edi
  801eb5:	89 c6                	mov    %eax,%esi
  801eb7:	89 ca                	mov    %ecx,%edx
  801eb9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801ebe:	29 f3                	sub    %esi,%ebx
  801ec0:	19 fa                	sbb    %edi,%edx
  801ec2:	89 d0                	mov    %edx,%eax
  801ec4:	d3 e0                	shl    %cl,%eax
  801ec6:	89 e9                	mov    %ebp,%ecx
  801ec8:	d3 eb                	shr    %cl,%ebx
  801eca:	d3 ea                	shr    %cl,%edx
  801ecc:	09 d8                	or     %ebx,%eax
  801ece:	83 c4 1c             	add    $0x1c,%esp
  801ed1:	5b                   	pop    %ebx
  801ed2:	5e                   	pop    %esi
  801ed3:	5f                   	pop    %edi
  801ed4:	5d                   	pop    %ebp
  801ed5:	c3                   	ret    
  801ed6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801edd:	8d 76 00             	lea    0x0(%esi),%esi
  801ee0:	29 fe                	sub    %edi,%esi
  801ee2:	19 c3                	sbb    %eax,%ebx
  801ee4:	89 f2                	mov    %esi,%edx
  801ee6:	89 d9                	mov    %ebx,%ecx
  801ee8:	e9 1d ff ff ff       	jmp    801e0a <__umoddi3+0x6a>
