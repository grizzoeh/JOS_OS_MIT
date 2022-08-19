
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 71 01 00 00       	call   8001a2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <breakpoint>:
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800033:	cc                   	int3   
}
  800034:	c3                   	ret    

00800035 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800035:	f3 0f 1e fb          	endbr32 
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  80003f:	ff 35 00 40 80 00    	pushl  0x804000
  800045:	68 00 00 00 a0       	push   $0xa0000000
  80004a:	e8 10 08 00 00       	call   80085f <strcpy>
	exit();
  80004f:	e8 9c 01 00 00       	call   8001f0 <exit>
}
  800054:	83 c4 10             	add    $0x10,%esp
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <umain>:
{
  800059:	f3 0f 1e fb          	endbr32 
  80005d:	55                   	push   %ebp
  80005e:	89 e5                	mov    %esp,%ebp
  800060:	53                   	push   %ebx
  800061:	83 ec 04             	sub    $0x4,%esp
	if (argc != 0)
  800064:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800068:	0f 85 d4 00 00 00    	jne    800142 <umain+0xe9>
	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80006e:	83 ec 04             	sub    $0x4,%esp
  800071:	68 07 04 00 00       	push   $0x407
  800076:	68 00 00 00 a0       	push   $0xa0000000
  80007b:	6a 00                	push   $0x0
  80007d:	e8 65 0c 00 00       	call   800ce7 <sys_page_alloc>
  800082:	83 c4 10             	add    $0x10,%esp
  800085:	85 c0                	test   %eax,%eax
  800087:	0f 88 bf 00 00 00    	js     80014c <umain+0xf3>
	if ((r = fork()) < 0)
  80008d:	e8 06 11 00 00       	call   801198 <fork>
  800092:	89 c3                	mov    %eax,%ebx
  800094:	85 c0                	test   %eax,%eax
  800096:	0f 88 c2 00 00 00    	js     80015e <umain+0x105>
	if (r == 0) {
  80009c:	0f 84 ce 00 00 00    	je     800170 <umain+0x117>
	wait(r);
  8000a2:	83 ec 0c             	sub    $0xc,%esp
  8000a5:	53                   	push   %ebx
  8000a6:	e8 22 24 00 00       	call   8024cd <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000ab:	83 c4 08             	add    $0x8,%esp
  8000ae:	ff 35 04 40 80 00    	pushl  0x804004
  8000b4:	68 00 00 00 a0       	push   $0xa0000000
  8000b9:	e8 60 08 00 00       	call   80091e <strcmp>
  8000be:	83 c4 08             	add    $0x8,%esp
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	b8 00 2b 80 00       	mov    $0x802b00,%eax
  8000c8:	ba 06 2b 80 00       	mov    $0x802b06,%edx
  8000cd:	0f 45 c2             	cmovne %edx,%eax
  8000d0:	50                   	push   %eax
  8000d1:	68 3c 2b 80 00       	push   $0x802b3c
  8000d6:	e8 1a 02 00 00       	call   8002f5 <cprintf>
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  8000db:	6a 00                	push   $0x0
  8000dd:	68 57 2b 80 00       	push   $0x802b57
  8000e2:	68 5c 2b 80 00       	push   $0x802b5c
  8000e7:	68 5b 2b 80 00       	push   $0x802b5b
  8000ec:	e8 c4 1f 00 00       	call   8020b5 <spawnl>
  8000f1:	83 c4 20             	add    $0x20,%esp
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	0f 88 94 00 00 00    	js     800190 <umain+0x137>
	wait(r);
  8000fc:	83 ec 0c             	sub    $0xc,%esp
  8000ff:	50                   	push   %eax
  800100:	e8 c8 23 00 00       	call   8024cd <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  800105:	83 c4 08             	add    $0x8,%esp
  800108:	ff 35 00 40 80 00    	pushl  0x804000
  80010e:	68 00 00 00 a0       	push   $0xa0000000
  800113:	e8 06 08 00 00       	call   80091e <strcmp>
  800118:	83 c4 08             	add    $0x8,%esp
  80011b:	85 c0                	test   %eax,%eax
  80011d:	b8 00 2b 80 00       	mov    $0x802b00,%eax
  800122:	ba 06 2b 80 00       	mov    $0x802b06,%edx
  800127:	0f 45 c2             	cmovne %edx,%eax
  80012a:	50                   	push   %eax
  80012b:	68 73 2b 80 00       	push   $0x802b73
  800130:	e8 c0 01 00 00       	call   8002f5 <cprintf>
	breakpoint();
  800135:	e8 f9 fe ff ff       	call   800033 <breakpoint>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800140:	c9                   	leave  
  800141:	c3                   	ret    
		childofspawn();
  800142:	e8 ee fe ff ff       	call   800035 <childofspawn>
  800147:	e9 22 ff ff ff       	jmp    80006e <umain+0x15>
		panic("sys_page_alloc: %e", r);
  80014c:	50                   	push   %eax
  80014d:	68 0c 2b 80 00       	push   $0x802b0c
  800152:	6a 13                	push   $0x13
  800154:	68 1f 2b 80 00       	push   $0x802b1f
  800159:	e8 b0 00 00 00       	call   80020e <_panic>
		panic("fork: %e", r);
  80015e:	50                   	push   %eax
  80015f:	68 33 2b 80 00       	push   $0x802b33
  800164:	6a 17                	push   $0x17
  800166:	68 1f 2b 80 00       	push   $0x802b1f
  80016b:	e8 9e 00 00 00       	call   80020e <_panic>
		strcpy(VA, msg);
  800170:	83 ec 08             	sub    $0x8,%esp
  800173:	ff 35 04 40 80 00    	pushl  0x804004
  800179:	68 00 00 00 a0       	push   $0xa0000000
  80017e:	e8 dc 06 00 00       	call   80085f <strcpy>
		exit();
  800183:	e8 68 00 00 00       	call   8001f0 <exit>
  800188:	83 c4 10             	add    $0x10,%esp
  80018b:	e9 12 ff ff ff       	jmp    8000a2 <umain+0x49>
		panic("spawn: %e", r);
  800190:	50                   	push   %eax
  800191:	68 69 2b 80 00       	push   $0x802b69
  800196:	6a 21                	push   $0x21
  800198:	68 1f 2b 80 00       	push   $0x802b1f
  80019d:	e8 6c 00 00 00       	call   80020e <_panic>

008001a2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001a2:	f3 0f 1e fb          	endbr32 
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ae:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8001b1:	e8 de 0a 00 00       	call   800c94 <sys_getenvid>
	if (id >= 0)
  8001b6:	85 c0                	test   %eax,%eax
  8001b8:	78 12                	js     8001cc <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8001ba:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001bf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001c2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001c7:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001cc:	85 db                	test   %ebx,%ebx
  8001ce:	7e 07                	jle    8001d7 <libmain+0x35>
		binaryname = argv[0];
  8001d0:	8b 06                	mov    (%esi),%eax
  8001d2:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001d7:	83 ec 08             	sub    $0x8,%esp
  8001da:	56                   	push   %esi
  8001db:	53                   	push   %ebx
  8001dc:	e8 78 fe ff ff       	call   800059 <umain>

	// exit gracefully
	exit();
  8001e1:	e8 0a 00 00 00       	call   8001f0 <exit>
}
  8001e6:	83 c4 10             	add    $0x10,%esp
  8001e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ec:	5b                   	pop    %ebx
  8001ed:	5e                   	pop    %esi
  8001ee:	5d                   	pop    %ebp
  8001ef:	c3                   	ret    

008001f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001f0:	f3 0f 1e fb          	endbr32 
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001fa:	e8 e0 12 00 00       	call   8014df <close_all>
	sys_env_destroy(0);
  8001ff:	83 ec 0c             	sub    $0xc,%esp
  800202:	6a 00                	push   $0x0
  800204:	e8 65 0a 00 00       	call   800c6e <sys_env_destroy>
}
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	c9                   	leave  
  80020d:	c3                   	ret    

0080020e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80020e:	f3 0f 1e fb          	endbr32 
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	56                   	push   %esi
  800216:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800217:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80021a:	8b 35 08 40 80 00    	mov    0x804008,%esi
  800220:	e8 6f 0a 00 00       	call   800c94 <sys_getenvid>
  800225:	83 ec 0c             	sub    $0xc,%esp
  800228:	ff 75 0c             	pushl  0xc(%ebp)
  80022b:	ff 75 08             	pushl  0x8(%ebp)
  80022e:	56                   	push   %esi
  80022f:	50                   	push   %eax
  800230:	68 b8 2b 80 00       	push   $0x802bb8
  800235:	e8 bb 00 00 00       	call   8002f5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80023a:	83 c4 18             	add    $0x18,%esp
  80023d:	53                   	push   %ebx
  80023e:	ff 75 10             	pushl  0x10(%ebp)
  800241:	e8 5a 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  800246:	c7 04 24 5a 32 80 00 	movl   $0x80325a,(%esp)
  80024d:	e8 a3 00 00 00       	call   8002f5 <cprintf>
  800252:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800255:	cc                   	int3   
  800256:	eb fd                	jmp    800255 <_panic+0x47>

00800258 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800258:	f3 0f 1e fb          	endbr32 
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	53                   	push   %ebx
  800260:	83 ec 04             	sub    $0x4,%esp
  800263:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800266:	8b 13                	mov    (%ebx),%edx
  800268:	8d 42 01             	lea    0x1(%edx),%eax
  80026b:	89 03                	mov    %eax,(%ebx)
  80026d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800270:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800274:	3d ff 00 00 00       	cmp    $0xff,%eax
  800279:	74 09                	je     800284 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80027b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80027f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800282:	c9                   	leave  
  800283:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	68 ff 00 00 00       	push   $0xff
  80028c:	8d 43 08             	lea    0x8(%ebx),%eax
  80028f:	50                   	push   %eax
  800290:	e8 87 09 00 00       	call   800c1c <sys_cputs>
		b->idx = 0;
  800295:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80029b:	83 c4 10             	add    $0x10,%esp
  80029e:	eb db                	jmp    80027b <putch+0x23>

008002a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a0:	f3 0f 1e fb          	endbr32 
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002ad:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b4:	00 00 00 
	b.cnt = 0;
  8002b7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002be:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002c1:	ff 75 0c             	pushl  0xc(%ebp)
  8002c4:	ff 75 08             	pushl  0x8(%ebp)
  8002c7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002cd:	50                   	push   %eax
  8002ce:	68 58 02 80 00       	push   $0x800258
  8002d3:	e8 80 01 00 00       	call   800458 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d8:	83 c4 08             	add    $0x8,%esp
  8002db:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002e1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	e8 2f 09 00 00       	call   800c1c <sys_cputs>

	return b.cnt;
}
  8002ed:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002f3:	c9                   	leave  
  8002f4:	c3                   	ret    

008002f5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f5:	f3 0f 1e fb          	endbr32 
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ff:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800302:	50                   	push   %eax
  800303:	ff 75 08             	pushl  0x8(%ebp)
  800306:	e8 95 ff ff ff       	call   8002a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  80030b:	c9                   	leave  
  80030c:	c3                   	ret    

0080030d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	57                   	push   %edi
  800311:	56                   	push   %esi
  800312:	53                   	push   %ebx
  800313:	83 ec 1c             	sub    $0x1c,%esp
  800316:	89 c7                	mov    %eax,%edi
  800318:	89 d6                	mov    %edx,%esi
  80031a:	8b 45 08             	mov    0x8(%ebp),%eax
  80031d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800320:	89 d1                	mov    %edx,%ecx
  800322:	89 c2                	mov    %eax,%edx
  800324:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800327:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80032a:	8b 45 10             	mov    0x10(%ebp),%eax
  80032d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800330:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800333:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80033a:	39 c2                	cmp    %eax,%edx
  80033c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80033f:	72 3e                	jb     80037f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800341:	83 ec 0c             	sub    $0xc,%esp
  800344:	ff 75 18             	pushl  0x18(%ebp)
  800347:	83 eb 01             	sub    $0x1,%ebx
  80034a:	53                   	push   %ebx
  80034b:	50                   	push   %eax
  80034c:	83 ec 08             	sub    $0x8,%esp
  80034f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800352:	ff 75 e0             	pushl  -0x20(%ebp)
  800355:	ff 75 dc             	pushl  -0x24(%ebp)
  800358:	ff 75 d8             	pushl  -0x28(%ebp)
  80035b:	e8 30 25 00 00       	call   802890 <__udivdi3>
  800360:	83 c4 18             	add    $0x18,%esp
  800363:	52                   	push   %edx
  800364:	50                   	push   %eax
  800365:	89 f2                	mov    %esi,%edx
  800367:	89 f8                	mov    %edi,%eax
  800369:	e8 9f ff ff ff       	call   80030d <printnum>
  80036e:	83 c4 20             	add    $0x20,%esp
  800371:	eb 13                	jmp    800386 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800373:	83 ec 08             	sub    $0x8,%esp
  800376:	56                   	push   %esi
  800377:	ff 75 18             	pushl  0x18(%ebp)
  80037a:	ff d7                	call   *%edi
  80037c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80037f:	83 eb 01             	sub    $0x1,%ebx
  800382:	85 db                	test   %ebx,%ebx
  800384:	7f ed                	jg     800373 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	56                   	push   %esi
  80038a:	83 ec 04             	sub    $0x4,%esp
  80038d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800390:	ff 75 e0             	pushl  -0x20(%ebp)
  800393:	ff 75 dc             	pushl  -0x24(%ebp)
  800396:	ff 75 d8             	pushl  -0x28(%ebp)
  800399:	e8 02 26 00 00       	call   8029a0 <__umoddi3>
  80039e:	83 c4 14             	add    $0x14,%esp
  8003a1:	0f be 80 db 2b 80 00 	movsbl 0x802bdb(%eax),%eax
  8003a8:	50                   	push   %eax
  8003a9:	ff d7                	call   *%edi
}
  8003ab:	83 c4 10             	add    $0x10,%esp
  8003ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b1:	5b                   	pop    %ebx
  8003b2:	5e                   	pop    %esi
  8003b3:	5f                   	pop    %edi
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    

008003b6 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8003b6:	83 fa 01             	cmp    $0x1,%edx
  8003b9:	7f 13                	jg     8003ce <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8003bb:	85 d2                	test   %edx,%edx
  8003bd:	74 1c                	je     8003db <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8003bf:	8b 10                	mov    (%eax),%edx
  8003c1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c4:	89 08                	mov    %ecx,(%eax)
  8003c6:	8b 02                	mov    (%edx),%eax
  8003c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cd:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	8b 52 04             	mov    0x4(%edx),%edx
  8003da:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8003db:	8b 10                	mov    (%eax),%edx
  8003dd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e0:	89 08                	mov    %ecx,(%eax)
  8003e2:	8b 02                	mov    (%edx),%eax
  8003e4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003e9:	c3                   	ret    

008003ea <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8003ea:	83 fa 01             	cmp    $0x1,%edx
  8003ed:	7f 0f                	jg     8003fe <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8003ef:	85 d2                	test   %edx,%edx
  8003f1:	74 18                	je     80040b <getint+0x21>
		return va_arg(*ap, long);
  8003f3:	8b 10                	mov    (%eax),%edx
  8003f5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f8:	89 08                	mov    %ecx,(%eax)
  8003fa:	8b 02                	mov    (%edx),%eax
  8003fc:	99                   	cltd   
  8003fd:	c3                   	ret    
		return va_arg(*ap, long long);
  8003fe:	8b 10                	mov    (%eax),%edx
  800400:	8d 4a 08             	lea    0x8(%edx),%ecx
  800403:	89 08                	mov    %ecx,(%eax)
  800405:	8b 02                	mov    (%edx),%eax
  800407:	8b 52 04             	mov    0x4(%edx),%edx
  80040a:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80040b:	8b 10                	mov    (%eax),%edx
  80040d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800410:	89 08                	mov    %ecx,(%eax)
  800412:	8b 02                	mov    (%edx),%eax
  800414:	99                   	cltd   
}
  800415:	c3                   	ret    

00800416 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800416:	f3 0f 1e fb          	endbr32 
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800420:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800424:	8b 10                	mov    (%eax),%edx
  800426:	3b 50 04             	cmp    0x4(%eax),%edx
  800429:	73 0a                	jae    800435 <sprintputch+0x1f>
		*b->buf++ = ch;
  80042b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80042e:	89 08                	mov    %ecx,(%eax)
  800430:	8b 45 08             	mov    0x8(%ebp),%eax
  800433:	88 02                	mov    %al,(%edx)
}
  800435:	5d                   	pop    %ebp
  800436:	c3                   	ret    

00800437 <printfmt>:
{
  800437:	f3 0f 1e fb          	endbr32 
  80043b:	55                   	push   %ebp
  80043c:	89 e5                	mov    %esp,%ebp
  80043e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800441:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800444:	50                   	push   %eax
  800445:	ff 75 10             	pushl  0x10(%ebp)
  800448:	ff 75 0c             	pushl  0xc(%ebp)
  80044b:	ff 75 08             	pushl  0x8(%ebp)
  80044e:	e8 05 00 00 00       	call   800458 <vprintfmt>
}
  800453:	83 c4 10             	add    $0x10,%esp
  800456:	c9                   	leave  
  800457:	c3                   	ret    

00800458 <vprintfmt>:
{
  800458:	f3 0f 1e fb          	endbr32 
  80045c:	55                   	push   %ebp
  80045d:	89 e5                	mov    %esp,%ebp
  80045f:	57                   	push   %edi
  800460:	56                   	push   %esi
  800461:	53                   	push   %ebx
  800462:	83 ec 2c             	sub    $0x2c,%esp
  800465:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800468:	8b 75 0c             	mov    0xc(%ebp),%esi
  80046b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80046e:	e9 86 02 00 00       	jmp    8006f9 <vprintfmt+0x2a1>
		padc = ' ';
  800473:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800477:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80047e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800485:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80048c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8d 47 01             	lea    0x1(%edi),%eax
  800494:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800497:	0f b6 17             	movzbl (%edi),%edx
  80049a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80049d:	3c 55                	cmp    $0x55,%al
  80049f:	0f 87 df 02 00 00    	ja     800784 <vprintfmt+0x32c>
  8004a5:	0f b6 c0             	movzbl %al,%eax
  8004a8:	3e ff 24 85 20 2d 80 	notrack jmp *0x802d20(,%eax,4)
  8004af:	00 
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8004b3:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8004b7:	eb d8                	jmp    800491 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004bc:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8004c0:	eb cf                	jmp    800491 <vprintfmt+0x39>
  8004c2:	0f b6 d2             	movzbl %dl,%edx
  8004c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8004c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8004d0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004d3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004d7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004da:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004dd:	83 f9 09             	cmp    $0x9,%ecx
  8004e0:	77 52                	ja     800534 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8004e2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004e5:	eb e9                	jmp    8004d0 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	8d 50 04             	lea    0x4(%eax),%edx
  8004ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f0:	8b 00                	mov    (%eax),%eax
  8004f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fc:	79 93                	jns    800491 <vprintfmt+0x39>
				width = precision, precision = -1;
  8004fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800501:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800504:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80050b:	eb 84                	jmp    800491 <vprintfmt+0x39>
  80050d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800510:	85 c0                	test   %eax,%eax
  800512:	ba 00 00 00 00       	mov    $0x0,%edx
  800517:	0f 49 d0             	cmovns %eax,%edx
  80051a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80051d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800520:	e9 6c ff ff ff       	jmp    800491 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800525:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800528:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80052f:	e9 5d ff ff ff       	jmp    800491 <vprintfmt+0x39>
  800534:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800537:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80053a:	eb bc                	jmp    8004f8 <vprintfmt+0xa0>
			lflag++;
  80053c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800542:	e9 4a ff ff ff       	jmp    800491 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8d 50 04             	lea    0x4(%eax),%edx
  80054d:	89 55 14             	mov    %edx,0x14(%ebp)
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	56                   	push   %esi
  800554:	ff 30                	pushl  (%eax)
  800556:	ff d3                	call   *%ebx
			break;
  800558:	83 c4 10             	add    $0x10,%esp
  80055b:	e9 96 01 00 00       	jmp    8006f6 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 50 04             	lea    0x4(%eax),%edx
  800566:	89 55 14             	mov    %edx,0x14(%ebp)
  800569:	8b 00                	mov    (%eax),%eax
  80056b:	99                   	cltd   
  80056c:	31 d0                	xor    %edx,%eax
  80056e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800570:	83 f8 0f             	cmp    $0xf,%eax
  800573:	7f 20                	jg     800595 <vprintfmt+0x13d>
  800575:	8b 14 85 80 2e 80 00 	mov    0x802e80(,%eax,4),%edx
  80057c:	85 d2                	test   %edx,%edx
  80057e:	74 15                	je     800595 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800580:	52                   	push   %edx
  800581:	68 75 31 80 00       	push   $0x803175
  800586:	56                   	push   %esi
  800587:	53                   	push   %ebx
  800588:	e8 aa fe ff ff       	call   800437 <printfmt>
  80058d:	83 c4 10             	add    $0x10,%esp
  800590:	e9 61 01 00 00       	jmp    8006f6 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800595:	50                   	push   %eax
  800596:	68 f3 2b 80 00       	push   $0x802bf3
  80059b:	56                   	push   %esi
  80059c:	53                   	push   %ebx
  80059d:	e8 95 fe ff ff       	call   800437 <printfmt>
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	e9 4c 01 00 00       	jmp    8006f6 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 50 04             	lea    0x4(%eax),%edx
  8005b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b3:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8005b5:	85 c9                	test   %ecx,%ecx
  8005b7:	b8 ec 2b 80 00       	mov    $0x802bec,%eax
  8005bc:	0f 45 c1             	cmovne %ecx,%eax
  8005bf:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c6:	7e 06                	jle    8005ce <vprintfmt+0x176>
  8005c8:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8005cc:	75 0d                	jne    8005db <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ce:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005d1:	89 c7                	mov    %eax,%edi
  8005d3:	03 45 e0             	add    -0x20(%ebp),%eax
  8005d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d9:	eb 57                	jmp    800632 <vprintfmt+0x1da>
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	ff 75 d8             	pushl  -0x28(%ebp)
  8005e1:	ff 75 cc             	pushl  -0x34(%ebp)
  8005e4:	e8 4f 02 00 00       	call   800838 <strnlen>
  8005e9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005ec:	29 c2                	sub    %eax,%edx
  8005ee:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005f1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005f4:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005f8:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8005fb:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fd:	85 db                	test   %ebx,%ebx
  8005ff:	7e 10                	jle    800611 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	56                   	push   %esi
  800605:	57                   	push   %edi
  800606:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800609:	83 eb 01             	sub    $0x1,%ebx
  80060c:	83 c4 10             	add    $0x10,%esp
  80060f:	eb ec                	jmp    8005fd <vprintfmt+0x1a5>
  800611:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800614:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800617:	85 d2                	test   %edx,%edx
  800619:	b8 00 00 00 00       	mov    $0x0,%eax
  80061e:	0f 49 c2             	cmovns %edx,%eax
  800621:	29 c2                	sub    %eax,%edx
  800623:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800626:	eb a6                	jmp    8005ce <vprintfmt+0x176>
					putch(ch, putdat);
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	56                   	push   %esi
  80062c:	52                   	push   %edx
  80062d:	ff d3                	call   *%ebx
  80062f:	83 c4 10             	add    $0x10,%esp
  800632:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800635:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800637:	83 c7 01             	add    $0x1,%edi
  80063a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063e:	0f be d0             	movsbl %al,%edx
  800641:	85 d2                	test   %edx,%edx
  800643:	74 42                	je     800687 <vprintfmt+0x22f>
  800645:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800649:	78 06                	js     800651 <vprintfmt+0x1f9>
  80064b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80064f:	78 1e                	js     80066f <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800651:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800655:	74 d1                	je     800628 <vprintfmt+0x1d0>
  800657:	0f be c0             	movsbl %al,%eax
  80065a:	83 e8 20             	sub    $0x20,%eax
  80065d:	83 f8 5e             	cmp    $0x5e,%eax
  800660:	76 c6                	jbe    800628 <vprintfmt+0x1d0>
					putch('?', putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	56                   	push   %esi
  800666:	6a 3f                	push   $0x3f
  800668:	ff d3                	call   *%ebx
  80066a:	83 c4 10             	add    $0x10,%esp
  80066d:	eb c3                	jmp    800632 <vprintfmt+0x1da>
  80066f:	89 cf                	mov    %ecx,%edi
  800671:	eb 0e                	jmp    800681 <vprintfmt+0x229>
				putch(' ', putdat);
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	56                   	push   %esi
  800677:	6a 20                	push   $0x20
  800679:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80067b:	83 ef 01             	sub    $0x1,%edi
  80067e:	83 c4 10             	add    $0x10,%esp
  800681:	85 ff                	test   %edi,%edi
  800683:	7f ee                	jg     800673 <vprintfmt+0x21b>
  800685:	eb 6f                	jmp    8006f6 <vprintfmt+0x29e>
  800687:	89 cf                	mov    %ecx,%edi
  800689:	eb f6                	jmp    800681 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  80068b:	89 ca                	mov    %ecx,%edx
  80068d:	8d 45 14             	lea    0x14(%ebp),%eax
  800690:	e8 55 fd ff ff       	call   8003ea <getint>
  800695:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800698:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80069b:	85 d2                	test   %edx,%edx
  80069d:	78 0b                	js     8006aa <vprintfmt+0x252>
			num = getint(&ap, lflag);
  80069f:	89 d1                	mov    %edx,%ecx
  8006a1:	89 c2                	mov    %eax,%edx
			base = 10;
  8006a3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a8:	eb 32                	jmp    8006dc <vprintfmt+0x284>
				putch('-', putdat);
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	56                   	push   %esi
  8006ae:	6a 2d                	push   $0x2d
  8006b0:	ff d3                	call   *%ebx
				num = -(long long) num;
  8006b2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006b8:	f7 da                	neg    %edx
  8006ba:	83 d1 00             	adc    $0x0,%ecx
  8006bd:	f7 d9                	neg    %ecx
  8006bf:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c7:	eb 13                	jmp    8006dc <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8006c9:	89 ca                	mov    %ecx,%edx
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ce:	e8 e3 fc ff ff       	call   8003b6 <getuint>
  8006d3:	89 d1                	mov    %edx,%ecx
  8006d5:	89 c2                	mov    %eax,%edx
			base = 10;
  8006d7:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006dc:	83 ec 0c             	sub    $0xc,%esp
  8006df:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006e3:	57                   	push   %edi
  8006e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e7:	50                   	push   %eax
  8006e8:	51                   	push   %ecx
  8006e9:	52                   	push   %edx
  8006ea:	89 f2                	mov    %esi,%edx
  8006ec:	89 d8                	mov    %ebx,%eax
  8006ee:	e8 1a fc ff ff       	call   80030d <printnum>
			break;
  8006f3:	83 c4 20             	add    $0x20,%esp
{
  8006f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f9:	83 c7 01             	add    $0x1,%edi
  8006fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800700:	83 f8 25             	cmp    $0x25,%eax
  800703:	0f 84 6a fd ff ff    	je     800473 <vprintfmt+0x1b>
			if (ch == '\0')
  800709:	85 c0                	test   %eax,%eax
  80070b:	0f 84 93 00 00 00    	je     8007a4 <vprintfmt+0x34c>
			putch(ch, putdat);
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	56                   	push   %esi
  800715:	50                   	push   %eax
  800716:	ff d3                	call   *%ebx
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	eb dc                	jmp    8006f9 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  80071d:	89 ca                	mov    %ecx,%edx
  80071f:	8d 45 14             	lea    0x14(%ebp),%eax
  800722:	e8 8f fc ff ff       	call   8003b6 <getuint>
  800727:	89 d1                	mov    %edx,%ecx
  800729:	89 c2                	mov    %eax,%edx
			base = 8;
  80072b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800730:	eb aa                	jmp    8006dc <vprintfmt+0x284>
			putch('0', putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	56                   	push   %esi
  800736:	6a 30                	push   $0x30
  800738:	ff d3                	call   *%ebx
			putch('x', putdat);
  80073a:	83 c4 08             	add    $0x8,%esp
  80073d:	56                   	push   %esi
  80073e:	6a 78                	push   $0x78
  800740:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800742:	8b 45 14             	mov    0x14(%ebp),%eax
  800745:	8d 50 04             	lea    0x4(%eax),%edx
  800748:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80074b:	8b 10                	mov    (%eax),%edx
  80074d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800752:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800755:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80075a:	eb 80                	jmp    8006dc <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80075c:	89 ca                	mov    %ecx,%edx
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
  800761:	e8 50 fc ff ff       	call   8003b6 <getuint>
  800766:	89 d1                	mov    %edx,%ecx
  800768:	89 c2                	mov    %eax,%edx
			base = 16;
  80076a:	b8 10 00 00 00       	mov    $0x10,%eax
  80076f:	e9 68 ff ff ff       	jmp    8006dc <vprintfmt+0x284>
			putch(ch, putdat);
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	56                   	push   %esi
  800778:	6a 25                	push   $0x25
  80077a:	ff d3                	call   *%ebx
			break;
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	e9 72 ff ff ff       	jmp    8006f6 <vprintfmt+0x29e>
			putch('%', putdat);
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	56                   	push   %esi
  800788:	6a 25                	push   $0x25
  80078a:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  80078c:	83 c4 10             	add    $0x10,%esp
  80078f:	89 f8                	mov    %edi,%eax
  800791:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800795:	74 05                	je     80079c <vprintfmt+0x344>
  800797:	83 e8 01             	sub    $0x1,%eax
  80079a:	eb f5                	jmp    800791 <vprintfmt+0x339>
  80079c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80079f:	e9 52 ff ff ff       	jmp    8006f6 <vprintfmt+0x29e>
}
  8007a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007a7:	5b                   	pop    %ebx
  8007a8:	5e                   	pop    %esi
  8007a9:	5f                   	pop    %edi
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ac:	f3 0f 1e fb          	endbr32 
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 18             	sub    $0x18,%esp
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007bf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	74 26                	je     8007f7 <vsnprintf+0x4b>
  8007d1:	85 d2                	test   %edx,%edx
  8007d3:	7e 22                	jle    8007f7 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d5:	ff 75 14             	pushl  0x14(%ebp)
  8007d8:	ff 75 10             	pushl  0x10(%ebp)
  8007db:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007de:	50                   	push   %eax
  8007df:	68 16 04 80 00       	push   $0x800416
  8007e4:	e8 6f fc ff ff       	call   800458 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ec:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f2:	83 c4 10             	add    $0x10,%esp
}
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    
		return -E_INVAL;
  8007f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007fc:	eb f7                	jmp    8007f5 <vsnprintf+0x49>

008007fe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007fe:	f3 0f 1e fb          	endbr32 
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800808:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080b:	50                   	push   %eax
  80080c:	ff 75 10             	pushl  0x10(%ebp)
  80080f:	ff 75 0c             	pushl  0xc(%ebp)
  800812:	ff 75 08             	pushl  0x8(%ebp)
  800815:	e8 92 ff ff ff       	call   8007ac <vsnprintf>
	va_end(ap);

	return rc;
}
  80081a:	c9                   	leave  
  80081b:	c3                   	ret    

0080081c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80081c:	f3 0f 1e fb          	endbr32 
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80082f:	74 05                	je     800836 <strlen+0x1a>
		n++;
  800831:	83 c0 01             	add    $0x1,%eax
  800834:	eb f5                	jmp    80082b <strlen+0xf>
	return n;
}
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800838:	f3 0f 1e fb          	endbr32 
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800842:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
  80084a:	39 d0                	cmp    %edx,%eax
  80084c:	74 0d                	je     80085b <strnlen+0x23>
  80084e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800852:	74 05                	je     800859 <strnlen+0x21>
		n++;
  800854:	83 c0 01             	add    $0x1,%eax
  800857:	eb f1                	jmp    80084a <strnlen+0x12>
  800859:	89 c2                	mov    %eax,%edx
	return n;
}
  80085b:	89 d0                	mov    %edx,%eax
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085f:	f3 0f 1e fb          	endbr32 
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	53                   	push   %ebx
  800867:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80086d:	b8 00 00 00 00       	mov    $0x0,%eax
  800872:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800876:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800879:	83 c0 01             	add    $0x1,%eax
  80087c:	84 d2                	test   %dl,%dl
  80087e:	75 f2                	jne    800872 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800880:	89 c8                	mov    %ecx,%eax
  800882:	5b                   	pop    %ebx
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800885:	f3 0f 1e fb          	endbr32 
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	53                   	push   %ebx
  80088d:	83 ec 10             	sub    $0x10,%esp
  800890:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800893:	53                   	push   %ebx
  800894:	e8 83 ff ff ff       	call   80081c <strlen>
  800899:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80089c:	ff 75 0c             	pushl  0xc(%ebp)
  80089f:	01 d8                	add    %ebx,%eax
  8008a1:	50                   	push   %eax
  8008a2:	e8 b8 ff ff ff       	call   80085f <strcpy>
	return dst;
}
  8008a7:	89 d8                	mov    %ebx,%eax
  8008a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ac:	c9                   	leave  
  8008ad:	c3                   	ret    

008008ae <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008ae:	f3 0f 1e fb          	endbr32 
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
  8008b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bd:	89 f3                	mov    %esi,%ebx
  8008bf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c2:	89 f0                	mov    %esi,%eax
  8008c4:	39 d8                	cmp    %ebx,%eax
  8008c6:	74 11                	je     8008d9 <strncpy+0x2b>
		*dst++ = *src;
  8008c8:	83 c0 01             	add    $0x1,%eax
  8008cb:	0f b6 0a             	movzbl (%edx),%ecx
  8008ce:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d1:	80 f9 01             	cmp    $0x1,%cl
  8008d4:	83 da ff             	sbb    $0xffffffff,%edx
  8008d7:	eb eb                	jmp    8008c4 <strncpy+0x16>
	}
	return ret;
}
  8008d9:	89 f0                	mov    %esi,%eax
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008df:	f3 0f 1e fb          	endbr32 
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	56                   	push   %esi
  8008e7:	53                   	push   %ebx
  8008e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ee:	8b 55 10             	mov    0x10(%ebp),%edx
  8008f1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f3:	85 d2                	test   %edx,%edx
  8008f5:	74 21                	je     800918 <strlcpy+0x39>
  8008f7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008fb:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008fd:	39 c2                	cmp    %eax,%edx
  8008ff:	74 14                	je     800915 <strlcpy+0x36>
  800901:	0f b6 19             	movzbl (%ecx),%ebx
  800904:	84 db                	test   %bl,%bl
  800906:	74 0b                	je     800913 <strlcpy+0x34>
			*dst++ = *src++;
  800908:	83 c1 01             	add    $0x1,%ecx
  80090b:	83 c2 01             	add    $0x1,%edx
  80090e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800911:	eb ea                	jmp    8008fd <strlcpy+0x1e>
  800913:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800915:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800918:	29 f0                	sub    %esi,%eax
}
  80091a:	5b                   	pop    %ebx
  80091b:	5e                   	pop    %esi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091e:	f3 0f 1e fb          	endbr32 
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800928:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80092b:	0f b6 01             	movzbl (%ecx),%eax
  80092e:	84 c0                	test   %al,%al
  800930:	74 0c                	je     80093e <strcmp+0x20>
  800932:	3a 02                	cmp    (%edx),%al
  800934:	75 08                	jne    80093e <strcmp+0x20>
		p++, q++;
  800936:	83 c1 01             	add    $0x1,%ecx
  800939:	83 c2 01             	add    $0x1,%edx
  80093c:	eb ed                	jmp    80092b <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80093e:	0f b6 c0             	movzbl %al,%eax
  800941:	0f b6 12             	movzbl (%edx),%edx
  800944:	29 d0                	sub    %edx,%eax
}
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800948:	f3 0f 1e fb          	endbr32 
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	53                   	push   %ebx
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 55 0c             	mov    0xc(%ebp),%edx
  800956:	89 c3                	mov    %eax,%ebx
  800958:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80095b:	eb 06                	jmp    800963 <strncmp+0x1b>
		n--, p++, q++;
  80095d:	83 c0 01             	add    $0x1,%eax
  800960:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800963:	39 d8                	cmp    %ebx,%eax
  800965:	74 16                	je     80097d <strncmp+0x35>
  800967:	0f b6 08             	movzbl (%eax),%ecx
  80096a:	84 c9                	test   %cl,%cl
  80096c:	74 04                	je     800972 <strncmp+0x2a>
  80096e:	3a 0a                	cmp    (%edx),%cl
  800970:	74 eb                	je     80095d <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800972:	0f b6 00             	movzbl (%eax),%eax
  800975:	0f b6 12             	movzbl (%edx),%edx
  800978:	29 d0                	sub    %edx,%eax
}
  80097a:	5b                   	pop    %ebx
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    
		return 0;
  80097d:	b8 00 00 00 00       	mov    $0x0,%eax
  800982:	eb f6                	jmp    80097a <strncmp+0x32>

00800984 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800984:	f3 0f 1e fb          	endbr32 
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800992:	0f b6 10             	movzbl (%eax),%edx
  800995:	84 d2                	test   %dl,%dl
  800997:	74 09                	je     8009a2 <strchr+0x1e>
		if (*s == c)
  800999:	38 ca                	cmp    %cl,%dl
  80099b:	74 0a                	je     8009a7 <strchr+0x23>
	for (; *s; s++)
  80099d:	83 c0 01             	add    $0x1,%eax
  8009a0:	eb f0                	jmp    800992 <strchr+0xe>
			return (char *) s;
	return 0;
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a9:	f3 0f 1e fb          	endbr32 
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ba:	38 ca                	cmp    %cl,%dl
  8009bc:	74 09                	je     8009c7 <strfind+0x1e>
  8009be:	84 d2                	test   %dl,%dl
  8009c0:	74 05                	je     8009c7 <strfind+0x1e>
	for (; *s; s++)
  8009c2:	83 c0 01             	add    $0x1,%eax
  8009c5:	eb f0                	jmp    8009b7 <strfind+0xe>
			break;
	return (char *) s;
}
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c9:	f3 0f 1e fb          	endbr32 
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	57                   	push   %edi
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
  8009d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8009d9:	85 c9                	test   %ecx,%ecx
  8009db:	74 33                	je     800a10 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009dd:	89 d0                	mov    %edx,%eax
  8009df:	09 c8                	or     %ecx,%eax
  8009e1:	a8 03                	test   $0x3,%al
  8009e3:	75 23                	jne    800a08 <memset+0x3f>
		c &= 0xFF;
  8009e5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e9:	89 d8                	mov    %ebx,%eax
  8009eb:	c1 e0 08             	shl    $0x8,%eax
  8009ee:	89 df                	mov    %ebx,%edi
  8009f0:	c1 e7 18             	shl    $0x18,%edi
  8009f3:	89 de                	mov    %ebx,%esi
  8009f5:	c1 e6 10             	shl    $0x10,%esi
  8009f8:	09 f7                	or     %esi,%edi
  8009fa:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  8009fc:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ff:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a01:	89 d7                	mov    %edx,%edi
  800a03:	fc                   	cld    
  800a04:	f3 ab                	rep stos %eax,%es:(%edi)
  800a06:	eb 08                	jmp    800a10 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a08:	89 d7                	mov    %edx,%edi
  800a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0d:	fc                   	cld    
  800a0e:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800a10:	89 d0                	mov    %edx,%eax
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5f                   	pop    %edi
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a17:	f3 0f 1e fb          	endbr32 
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	57                   	push   %edi
  800a1f:	56                   	push   %esi
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a29:	39 c6                	cmp    %eax,%esi
  800a2b:	73 32                	jae    800a5f <memmove+0x48>
  800a2d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a30:	39 c2                	cmp    %eax,%edx
  800a32:	76 2b                	jbe    800a5f <memmove+0x48>
		s += n;
		d += n;
  800a34:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a37:	89 fe                	mov    %edi,%esi
  800a39:	09 ce                	or     %ecx,%esi
  800a3b:	09 d6                	or     %edx,%esi
  800a3d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a43:	75 0e                	jne    800a53 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a45:	83 ef 04             	sub    $0x4,%edi
  800a48:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a4b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a4e:	fd                   	std    
  800a4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a51:	eb 09                	jmp    800a5c <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a53:	83 ef 01             	sub    $0x1,%edi
  800a56:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a59:	fd                   	std    
  800a5a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a5c:	fc                   	cld    
  800a5d:	eb 1a                	jmp    800a79 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5f:	89 c2                	mov    %eax,%edx
  800a61:	09 ca                	or     %ecx,%edx
  800a63:	09 f2                	or     %esi,%edx
  800a65:	f6 c2 03             	test   $0x3,%dl
  800a68:	75 0a                	jne    800a74 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a6a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a6d:	89 c7                	mov    %eax,%edi
  800a6f:	fc                   	cld    
  800a70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a72:	eb 05                	jmp    800a79 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a74:	89 c7                	mov    %eax,%edi
  800a76:	fc                   	cld    
  800a77:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7d:	f3 0f 1e fb          	endbr32 
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a87:	ff 75 10             	pushl  0x10(%ebp)
  800a8a:	ff 75 0c             	pushl  0xc(%ebp)
  800a8d:	ff 75 08             	pushl  0x8(%ebp)
  800a90:	e8 82 ff ff ff       	call   800a17 <memmove>
}
  800a95:	c9                   	leave  
  800a96:	c3                   	ret    

00800a97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a97:	f3 0f 1e fb          	endbr32 
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa6:	89 c6                	mov    %eax,%esi
  800aa8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aab:	39 f0                	cmp    %esi,%eax
  800aad:	74 1c                	je     800acb <memcmp+0x34>
		if (*s1 != *s2)
  800aaf:	0f b6 08             	movzbl (%eax),%ecx
  800ab2:	0f b6 1a             	movzbl (%edx),%ebx
  800ab5:	38 d9                	cmp    %bl,%cl
  800ab7:	75 08                	jne    800ac1 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ab9:	83 c0 01             	add    $0x1,%eax
  800abc:	83 c2 01             	add    $0x1,%edx
  800abf:	eb ea                	jmp    800aab <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ac1:	0f b6 c1             	movzbl %cl,%eax
  800ac4:	0f b6 db             	movzbl %bl,%ebx
  800ac7:	29 d8                	sub    %ebx,%eax
  800ac9:	eb 05                	jmp    800ad0 <memcmp+0x39>
	}

	return 0;
  800acb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad4:	f3 0f 1e fb          	endbr32 
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ae1:	89 c2                	mov    %eax,%edx
  800ae3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae6:	39 d0                	cmp    %edx,%eax
  800ae8:	73 09                	jae    800af3 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aea:	38 08                	cmp    %cl,(%eax)
  800aec:	74 05                	je     800af3 <memfind+0x1f>
	for (; s < ends; s++)
  800aee:	83 c0 01             	add    $0x1,%eax
  800af1:	eb f3                	jmp    800ae6 <memfind+0x12>
			break;
	return (void *) s;
}
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af5:	f3 0f 1e fb          	endbr32 
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b05:	eb 03                	jmp    800b0a <strtol+0x15>
		s++;
  800b07:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b0a:	0f b6 01             	movzbl (%ecx),%eax
  800b0d:	3c 20                	cmp    $0x20,%al
  800b0f:	74 f6                	je     800b07 <strtol+0x12>
  800b11:	3c 09                	cmp    $0x9,%al
  800b13:	74 f2                	je     800b07 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b15:	3c 2b                	cmp    $0x2b,%al
  800b17:	74 2a                	je     800b43 <strtol+0x4e>
	int neg = 0;
  800b19:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b1e:	3c 2d                	cmp    $0x2d,%al
  800b20:	74 2b                	je     800b4d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b22:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b28:	75 0f                	jne    800b39 <strtol+0x44>
  800b2a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b2d:	74 28                	je     800b57 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b2f:	85 db                	test   %ebx,%ebx
  800b31:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b36:	0f 44 d8             	cmove  %eax,%ebx
  800b39:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b41:	eb 46                	jmp    800b89 <strtol+0x94>
		s++;
  800b43:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b46:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4b:	eb d5                	jmp    800b22 <strtol+0x2d>
		s++, neg = 1;
  800b4d:	83 c1 01             	add    $0x1,%ecx
  800b50:	bf 01 00 00 00       	mov    $0x1,%edi
  800b55:	eb cb                	jmp    800b22 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b57:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b5b:	74 0e                	je     800b6b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b5d:	85 db                	test   %ebx,%ebx
  800b5f:	75 d8                	jne    800b39 <strtol+0x44>
		s++, base = 8;
  800b61:	83 c1 01             	add    $0x1,%ecx
  800b64:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b69:	eb ce                	jmp    800b39 <strtol+0x44>
		s += 2, base = 16;
  800b6b:	83 c1 02             	add    $0x2,%ecx
  800b6e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b73:	eb c4                	jmp    800b39 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b75:	0f be d2             	movsbl %dl,%edx
  800b78:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b7b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b7e:	7d 3a                	jge    800bba <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b80:	83 c1 01             	add    $0x1,%ecx
  800b83:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b87:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b89:	0f b6 11             	movzbl (%ecx),%edx
  800b8c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b8f:	89 f3                	mov    %esi,%ebx
  800b91:	80 fb 09             	cmp    $0x9,%bl
  800b94:	76 df                	jbe    800b75 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b96:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b99:	89 f3                	mov    %esi,%ebx
  800b9b:	80 fb 19             	cmp    $0x19,%bl
  800b9e:	77 08                	ja     800ba8 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ba0:	0f be d2             	movsbl %dl,%edx
  800ba3:	83 ea 57             	sub    $0x57,%edx
  800ba6:	eb d3                	jmp    800b7b <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ba8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bab:	89 f3                	mov    %esi,%ebx
  800bad:	80 fb 19             	cmp    $0x19,%bl
  800bb0:	77 08                	ja     800bba <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bb2:	0f be d2             	movsbl %dl,%edx
  800bb5:	83 ea 37             	sub    $0x37,%edx
  800bb8:	eb c1                	jmp    800b7b <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbe:	74 05                	je     800bc5 <strtol+0xd0>
		*endptr = (char *) s;
  800bc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bc5:	89 c2                	mov    %eax,%edx
  800bc7:	f7 da                	neg    %edx
  800bc9:	85 ff                	test   %edi,%edi
  800bcb:	0f 45 c2             	cmovne %edx,%eax
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
  800bd9:	83 ec 1c             	sub    $0x1c,%esp
  800bdc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bdf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800be2:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bea:	8b 7d 10             	mov    0x10(%ebp),%edi
  800bed:	8b 75 14             	mov    0x14(%ebp),%esi
  800bf0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800bf6:	74 04                	je     800bfc <syscall+0x29>
  800bf8:	85 c0                	test   %eax,%eax
  800bfa:	7f 08                	jg     800c04 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	50                   	push   %eax
  800c08:	ff 75 e0             	pushl  -0x20(%ebp)
  800c0b:	68 df 2e 80 00       	push   $0x802edf
  800c10:	6a 23                	push   $0x23
  800c12:	68 fc 2e 80 00       	push   $0x802efc
  800c17:	e8 f2 f5 ff ff       	call   80020e <_panic>

00800c1c <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800c1c:	f3 0f 1e fb          	endbr32 
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800c26:	6a 00                	push   $0x0
  800c28:	6a 00                	push   $0x0
  800c2a:	6a 00                	push   $0x0
  800c2c:	ff 75 0c             	pushl  0xc(%ebp)
  800c2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c32:	ba 00 00 00 00       	mov    $0x0,%edx
  800c37:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3c:	e8 92 ff ff ff       	call   800bd3 <syscall>
}
  800c41:	83 c4 10             	add    $0x10,%esp
  800c44:	c9                   	leave  
  800c45:	c3                   	ret    

00800c46 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c46:	f3 0f 1e fb          	endbr32 
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c50:	6a 00                	push   $0x0
  800c52:	6a 00                	push   $0x0
  800c54:	6a 00                	push   $0x0
  800c56:	6a 00                	push   $0x0
  800c58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c62:	b8 01 00 00 00       	mov    $0x1,%eax
  800c67:	e8 67 ff ff ff       	call   800bd3 <syscall>
}
  800c6c:	c9                   	leave  
  800c6d:	c3                   	ret    

00800c6e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c6e:	f3 0f 1e fb          	endbr32 
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c78:	6a 00                	push   $0x0
  800c7a:	6a 00                	push   $0x0
  800c7c:	6a 00                	push   $0x0
  800c7e:	6a 00                	push   $0x0
  800c80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c83:	ba 01 00 00 00       	mov    $0x1,%edx
  800c88:	b8 03 00 00 00       	mov    $0x3,%eax
  800c8d:	e8 41 ff ff ff       	call   800bd3 <syscall>
}
  800c92:	c9                   	leave  
  800c93:	c3                   	ret    

00800c94 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c94:	f3 0f 1e fb          	endbr32 
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c9e:	6a 00                	push   $0x0
  800ca0:	6a 00                	push   $0x0
  800ca2:	6a 00                	push   $0x0
  800ca4:	6a 00                	push   $0x0
  800ca6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cab:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb0:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb5:	e8 19 ff ff ff       	call   800bd3 <syscall>
}
  800cba:	c9                   	leave  
  800cbb:	c3                   	ret    

00800cbc <sys_yield>:

void
sys_yield(void)
{
  800cbc:	f3 0f 1e fb          	endbr32 
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800cc6:	6a 00                	push   $0x0
  800cc8:	6a 00                	push   $0x0
  800cca:	6a 00                	push   $0x0
  800ccc:	6a 00                	push   $0x0
  800cce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cdd:	e8 f1 fe ff ff       	call   800bd3 <syscall>
}
  800ce2:	83 c4 10             	add    $0x10,%esp
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce7:	f3 0f 1e fb          	endbr32 
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800cf1:	6a 00                	push   $0x0
  800cf3:	6a 00                	push   $0x0
  800cf5:	ff 75 10             	pushl  0x10(%ebp)
  800cf8:	ff 75 0c             	pushl  0xc(%ebp)
  800cfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cfe:	ba 01 00 00 00       	mov    $0x1,%edx
  800d03:	b8 04 00 00 00       	mov    $0x4,%eax
  800d08:	e8 c6 fe ff ff       	call   800bd3 <syscall>
}
  800d0d:	c9                   	leave  
  800d0e:	c3                   	ret    

00800d0f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d0f:	f3 0f 1e fb          	endbr32 
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800d19:	ff 75 18             	pushl  0x18(%ebp)
  800d1c:	ff 75 14             	pushl  0x14(%ebp)
  800d1f:	ff 75 10             	pushl  0x10(%ebp)
  800d22:	ff 75 0c             	pushl  0xc(%ebp)
  800d25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d28:	ba 01 00 00 00       	mov    $0x1,%edx
  800d2d:	b8 05 00 00 00       	mov    $0x5,%eax
  800d32:	e8 9c fe ff ff       	call   800bd3 <syscall>
}
  800d37:	c9                   	leave  
  800d38:	c3                   	ret    

00800d39 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d39:	f3 0f 1e fb          	endbr32 
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d43:	6a 00                	push   $0x0
  800d45:	6a 00                	push   $0x0
  800d47:	6a 00                	push   $0x0
  800d49:	ff 75 0c             	pushl  0xc(%ebp)
  800d4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4f:	ba 01 00 00 00       	mov    $0x1,%edx
  800d54:	b8 06 00 00 00       	mov    $0x6,%eax
  800d59:	e8 75 fe ff ff       	call   800bd3 <syscall>
}
  800d5e:	c9                   	leave  
  800d5f:	c3                   	ret    

00800d60 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d60:	f3 0f 1e fb          	endbr32 
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d6a:	6a 00                	push   $0x0
  800d6c:	6a 00                	push   $0x0
  800d6e:	6a 00                	push   $0x0
  800d70:	ff 75 0c             	pushl  0xc(%ebp)
  800d73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d76:	ba 01 00 00 00       	mov    $0x1,%edx
  800d7b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d80:	e8 4e fe ff ff       	call   800bd3 <syscall>
}
  800d85:	c9                   	leave  
  800d86:	c3                   	ret    

00800d87 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d87:	f3 0f 1e fb          	endbr32 
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d91:	6a 00                	push   $0x0
  800d93:	6a 00                	push   $0x0
  800d95:	6a 00                	push   $0x0
  800d97:	ff 75 0c             	pushl  0xc(%ebp)
  800d9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9d:	ba 01 00 00 00       	mov    $0x1,%edx
  800da2:	b8 09 00 00 00       	mov    $0x9,%eax
  800da7:	e8 27 fe ff ff       	call   800bd3 <syscall>
}
  800dac:	c9                   	leave  
  800dad:	c3                   	ret    

00800dae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dae:	f3 0f 1e fb          	endbr32 
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800db8:	6a 00                	push   $0x0
  800dba:	6a 00                	push   $0x0
  800dbc:	6a 00                	push   $0x0
  800dbe:	ff 75 0c             	pushl  0xc(%ebp)
  800dc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc4:	ba 01 00 00 00       	mov    $0x1,%edx
  800dc9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dce:	e8 00 fe ff ff       	call   800bd3 <syscall>
}
  800dd3:	c9                   	leave  
  800dd4:	c3                   	ret    

00800dd5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd5:	f3 0f 1e fb          	endbr32 
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800ddf:	6a 00                	push   $0x0
  800de1:	ff 75 14             	pushl  0x14(%ebp)
  800de4:	ff 75 10             	pushl  0x10(%ebp)
  800de7:	ff 75 0c             	pushl  0xc(%ebp)
  800dea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ded:	ba 00 00 00 00       	mov    $0x0,%edx
  800df2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df7:	e8 d7 fd ff ff       	call   800bd3 <syscall>
}
  800dfc:	c9                   	leave  
  800dfd:	c3                   	ret    

00800dfe <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dfe:	f3 0f 1e fb          	endbr32 
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e08:	6a 00                	push   $0x0
  800e0a:	6a 00                	push   $0x0
  800e0c:	6a 00                	push   $0x0
  800e0e:	6a 00                	push   $0x0
  800e10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e13:	ba 01 00 00 00       	mov    $0x1,%edx
  800e18:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e1d:	e8 b1 fd ff ff       	call   800bd3 <syscall>
}
  800e22:	c9                   	leave  
  800e23:	c3                   	ret    

00800e24 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	53                   	push   %ebx
  800e28:	83 ec 04             	sub    $0x4,%esp
	int r;

	// LAB 4: Your code here.
	void *addr = (void *) (pn * PGSIZE);
  800e2b:	89 d3                	mov    %edx,%ebx
  800e2d:	c1 e3 0c             	shl    $0xc,%ebx

	if (uvpt[pn] & PTE_SHARE) {
  800e30:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e37:	f6 c5 04             	test   $0x4,%ch
  800e3a:	75 56                	jne    800e92 <duppage+0x6e>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
		return 0;
	}

	if ((uvpt[pn] & (PTE_W | PTE_COW)) != 0) {
  800e3c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e43:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800e49:	74 72                	je     800ebd <duppage+0x99>
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW) <
  800e4b:	83 ec 0c             	sub    $0xc,%esp
  800e4e:	68 05 08 00 00       	push   $0x805
  800e53:	53                   	push   %ebx
  800e54:	50                   	push   %eax
  800e55:	53                   	push   %ebx
  800e56:	6a 00                	push   $0x0
  800e58:	e8 b2 fe ff ff       	call   800d0f <sys_page_map>
  800e5d:	83 c4 20             	add    $0x20,%esp
  800e60:	85 c0                	test   %eax,%eax
  800e62:	78 45                	js     800ea9 <duppage+0x85>
		    0) {
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
		}
		if (sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW) < 0) {
  800e64:	83 ec 0c             	sub    $0xc,%esp
  800e67:	68 05 08 00 00       	push   $0x805
  800e6c:	53                   	push   %ebx
  800e6d:	6a 00                	push   $0x0
  800e6f:	53                   	push   %ebx
  800e70:	6a 00                	push   $0x0
  800e72:	e8 98 fe ff ff       	call   800d0f <sys_page_map>
  800e77:	83 c4 20             	add    $0x20,%esp
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	79 55                	jns    800ed3 <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP FATHER");
  800e7e:	83 ec 04             	sub    $0x4,%esp
  800e81:	68 2c 2f 80 00       	push   $0x802f2c
  800e86:	6a 54                	push   $0x54
  800e88:	68 bf 2f 80 00       	push   $0x802fbf
  800e8d:	e8 7c f3 ff ff       	call   80020e <_panic>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800e92:	83 ec 0c             	sub    $0xc,%esp
  800e95:	68 07 0e 00 00       	push   $0xe07
  800e9a:	53                   	push   %ebx
  800e9b:	50                   	push   %eax
  800e9c:	53                   	push   %ebx
  800e9d:	6a 00                	push   $0x0
  800e9f:	e8 6b fe ff ff       	call   800d0f <sys_page_map>
		return 0;
  800ea4:	83 c4 20             	add    $0x20,%esp
  800ea7:	eb 2a                	jmp    800ed3 <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
  800ea9:	83 ec 04             	sub    $0x4,%esp
  800eac:	68 0c 2f 80 00       	push   $0x802f0c
  800eb1:	6a 51                	push   $0x51
  800eb3:	68 bf 2f 80 00       	push   $0x802fbf
  800eb8:	e8 51 f3 ff ff       	call   80020e <_panic>
		}
	} else {
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U) < 0) {
  800ebd:	83 ec 0c             	sub    $0xc,%esp
  800ec0:	6a 05                	push   $0x5
  800ec2:	53                   	push   %ebx
  800ec3:	50                   	push   %eax
  800ec4:	53                   	push   %ebx
  800ec5:	6a 00                	push   $0x0
  800ec7:	e8 43 fe ff ff       	call   800d0f <sys_page_map>
  800ecc:	83 c4 20             	add    $0x20,%esp
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	78 0a                	js     800edd <duppage+0xb9>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
		}
	}

	return 0;
}
  800ed3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800edb:	c9                   	leave  
  800edc:	c3                   	ret    
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
  800edd:	83 ec 04             	sub    $0x4,%esp
  800ee0:	68 ca 2f 80 00       	push   $0x802fca
  800ee5:	6a 58                	push   $0x58
  800ee7:	68 bf 2f 80 00       	push   $0x802fbf
  800eec:	e8 1d f3 ff ff       	call   80020e <_panic>

00800ef1 <dup_or_share>:

static void
dup_or_share(envid_t dstenv, void *va, int perm)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	89 c6                	mov    %eax,%esi
  800ef8:	89 d3                	mov    %edx,%ebx
	int r;
	if (perm & PTE_W) {
  800efa:	f6 c1 02             	test   $0x2,%cl
  800efd:	0f 84 8c 00 00 00    	je     800f8f <dup_or_share+0x9e>
		// dup
		if ((r = sys_page_alloc(dstenv, va, PTE_P | PTE_U | PTE_W)) < 0)
  800f03:	83 ec 04             	sub    $0x4,%esp
  800f06:	6a 07                	push   $0x7
  800f08:	52                   	push   %edx
  800f09:	50                   	push   %eax
  800f0a:	e8 d8 fd ff ff       	call   800ce7 <sys_page_alloc>
  800f0f:	83 c4 10             	add    $0x10,%esp
  800f12:	85 c0                	test   %eax,%eax
  800f14:	78 55                	js     800f6b <dup_or_share+0x7a>
			panic("sys_page_alloc: %e", r);
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  800f16:	83 ec 0c             	sub    $0xc,%esp
  800f19:	6a 07                	push   $0x7
  800f1b:	68 00 00 40 00       	push   $0x400000
  800f20:	6a 00                	push   $0x0
  800f22:	53                   	push   %ebx
  800f23:	56                   	push   %esi
  800f24:	e8 e6 fd ff ff       	call   800d0f <sys_page_map>
  800f29:	83 c4 20             	add    $0x20,%esp
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	78 4d                	js     800f7d <dup_or_share+0x8c>
		    0)
			panic("sys_page_map: %e", r);
		memmove(UTEMP, va, PGSIZE);
  800f30:	83 ec 04             	sub    $0x4,%esp
  800f33:	68 00 10 00 00       	push   $0x1000
  800f38:	53                   	push   %ebx
  800f39:	68 00 00 40 00       	push   $0x400000
  800f3e:	e8 d4 fa ff ff       	call   800a17 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800f43:	83 c4 08             	add    $0x8,%esp
  800f46:	68 00 00 40 00       	push   $0x400000
  800f4b:	6a 00                	push   $0x0
  800f4d:	e8 e7 fd ff ff       	call   800d39 <sys_page_unmap>
  800f52:	83 c4 10             	add    $0x10,%esp
  800f55:	85 c0                	test   %eax,%eax
  800f57:	79 52                	jns    800fab <dup_or_share+0xba>
			panic("sys_page_unmap: %e", r);
  800f59:	50                   	push   %eax
  800f5a:	68 f7 2f 80 00       	push   $0x802ff7
  800f5f:	6a 6c                	push   $0x6c
  800f61:	68 bf 2f 80 00       	push   $0x802fbf
  800f66:	e8 a3 f2 ff ff       	call   80020e <_panic>
			panic("sys_page_alloc: %e", r);
  800f6b:	50                   	push   %eax
  800f6c:	68 0c 2b 80 00       	push   $0x802b0c
  800f71:	6a 66                	push   $0x66
  800f73:	68 bf 2f 80 00       	push   $0x802fbf
  800f78:	e8 91 f2 ff ff       	call   80020e <_panic>
			panic("sys_page_map: %e", r);
  800f7d:	50                   	push   %eax
  800f7e:	68 e6 2f 80 00       	push   $0x802fe6
  800f83:	6a 69                	push   $0x69
  800f85:	68 bf 2f 80 00       	push   $0x802fbf
  800f8a:	e8 7f f2 ff ff       	call   80020e <_panic>

	} else {
		// share
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | perm)) <
  800f8f:	83 ec 0c             	sub    $0xc,%esp
  800f92:	83 c9 05             	or     $0x5,%ecx
  800f95:	51                   	push   %ecx
  800f96:	68 00 00 40 00       	push   $0x400000
  800f9b:	6a 00                	push   $0x0
  800f9d:	52                   	push   %edx
  800f9e:	50                   	push   %eax
  800f9f:	e8 6b fd ff ff       	call   800d0f <sys_page_map>
  800fa4:	83 c4 20             	add    $0x20,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	78 07                	js     800fb2 <dup_or_share+0xc1>
		    0)
			panic("sys_page_map: %e", r);
	}
}
  800fab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fae:	5b                   	pop    %ebx
  800faf:	5e                   	pop    %esi
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    
			panic("sys_page_map: %e", r);
  800fb2:	50                   	push   %eax
  800fb3:	68 e6 2f 80 00       	push   $0x802fe6
  800fb8:	6a 72                	push   $0x72
  800fba:	68 bf 2f 80 00       	push   $0x802fbf
  800fbf:	e8 4a f2 ff ff       	call   80020e <_panic>

00800fc4 <pgfault>:
{
  800fc4:	f3 0f 1e fb          	endbr32 
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	53                   	push   %ebx
  800fcc:	83 ec 04             	sub    $0x4,%esp
  800fcf:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800fd2:	8b 02                	mov    (%edx),%eax
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800fd4:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800fd8:	0f 84 95 00 00 00    	je     801073 <pgfault+0xaf>
  800fde:	89 c2                	mov    %eax,%edx
  800fe0:	c1 ea 16             	shr    $0x16,%edx
  800fe3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fea:	f6 c2 01             	test   $0x1,%dl
  800fed:	0f 84 80 00 00 00    	je     801073 <pgfault+0xaf>
	    (~uvpt[PGNUM(addr)] & (PTE_COW | PTE_P)) != 0) {
  800ff3:	89 c2                	mov    %eax,%edx
  800ff5:	c1 ea 0c             	shr    $0xc,%edx
  800ff8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fff:	f7 d2                	not    %edx
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  801001:	f7 c2 01 08 00 00    	test   $0x801,%edx
  801007:	75 6a                	jne    801073 <pgfault+0xaf>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  801009:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80100e:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U) < 0) {
  801010:	83 ec 04             	sub    $0x4,%esp
  801013:	6a 07                	push   $0x7
  801015:	68 00 f0 7f 00       	push   $0x7ff000
  80101a:	6a 00                	push   $0x0
  80101c:	e8 c6 fc ff ff       	call   800ce7 <sys_page_alloc>
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	85 c0                	test   %eax,%eax
  801026:	78 5f                	js     801087 <pgfault+0xc3>
	memcpy((void *) PFTEMP, addr, PGSIZE);
  801028:	83 ec 04             	sub    $0x4,%esp
  80102b:	68 00 10 00 00       	push   $0x1000
  801030:	53                   	push   %ebx
  801031:	68 00 f0 7f 00       	push   $0x7ff000
  801036:	e8 42 fa ff ff       	call   800a7d <memcpy>
	if (sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U) < 0) {
  80103b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801042:	53                   	push   %ebx
  801043:	6a 00                	push   $0x0
  801045:	68 00 f0 7f 00       	push   $0x7ff000
  80104a:	6a 00                	push   $0x0
  80104c:	e8 be fc ff ff       	call   800d0f <sys_page_map>
  801051:	83 c4 20             	add    $0x20,%esp
  801054:	85 c0                	test   %eax,%eax
  801056:	78 43                	js     80109b <pgfault+0xd7>
	if (sys_page_unmap(0, (void *) PFTEMP) < 0) {
  801058:	83 ec 08             	sub    $0x8,%esp
  80105b:	68 00 f0 7f 00       	push   $0x7ff000
  801060:	6a 00                	push   $0x0
  801062:	e8 d2 fc ff ff       	call   800d39 <sys_page_unmap>
  801067:	83 c4 10             	add    $0x10,%esp
  80106a:	85 c0                	test   %eax,%eax
  80106c:	78 41                	js     8010af <pgfault+0xeb>
}
  80106e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801071:	c9                   	leave  
  801072:	c3                   	ret    
		panic("ERROR PGFAULT");
  801073:	83 ec 04             	sub    $0x4,%esp
  801076:	68 0a 30 80 00       	push   $0x80300a
  80107b:	6a 1e                	push   $0x1e
  80107d:	68 bf 2f 80 00       	push   $0x802fbf
  801082:	e8 87 f1 ff ff       	call   80020e <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_ALLOC");
  801087:	83 ec 04             	sub    $0x4,%esp
  80108a:	68 18 30 80 00       	push   $0x803018
  80108f:	6a 2b                	push   $0x2b
  801091:	68 bf 2f 80 00       	push   $0x802fbf
  801096:	e8 73 f1 ff ff       	call   80020e <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_MAP");
  80109b:	83 ec 04             	sub    $0x4,%esp
  80109e:	68 36 30 80 00       	push   $0x803036
  8010a3:	6a 2f                	push   $0x2f
  8010a5:	68 bf 2f 80 00       	push   $0x802fbf
  8010aa:	e8 5f f1 ff ff       	call   80020e <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_UNMAP");
  8010af:	83 ec 04             	sub    $0x4,%esp
  8010b2:	68 52 30 80 00       	push   $0x803052
  8010b7:	6a 32                	push   $0x32
  8010b9:	68 bf 2f 80 00       	push   $0x802fbf
  8010be:	e8 4b f1 ff ff       	call   80020e <_panic>

008010c3 <fork_v0>:

envid_t
fork_v0(void)
{
  8010c3:	f3 0f 1e fb          	endbr32 
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	57                   	push   %edi
  8010cb:	56                   	push   %esi
  8010cc:	53                   	push   %ebx
  8010cd:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010d0:	b8 07 00 00 00       	mov    $0x7,%eax
  8010d5:	cd 30                	int    $0x30
	envid_t env_id = sys_exofork();
	if (env_id < 0) {
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	78 24                	js     8010ff <fork_v0+0x3c>
  8010db:	89 c6                	mov    %eax,%esi
  8010dd:	89 c7                	mov    %eax,%edi
		thisenv = envs + ENVX(sys_getenvid());
		return env_id;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  8010df:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (env_id == 0) {  // Son
  8010e4:	75 51                	jne    801137 <fork_v0+0x74>
		thisenv = envs + ENVX(sys_getenvid());
  8010e6:	e8 a9 fb ff ff       	call   800c94 <sys_getenvid>
  8010eb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010f0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010f3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010f8:	a3 04 50 80 00       	mov    %eax,0x805004
		return env_id;
  8010fd:	eb 78                	jmp    801177 <fork_v0+0xb4>
		panic("ERROR ON FORK_V0");
  8010ff:	83 ec 04             	sub    $0x4,%esp
  801102:	68 70 30 80 00       	push   $0x803070
  801107:	6a 7b                	push   $0x7b
  801109:	68 bf 2f 80 00       	push   $0x802fbf
  80110e:	e8 fb f0 ff ff       	call   80020e <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
				dup_or_share(env_id,
  801113:	b9 07 00 00 00       	mov    $0x7,%ecx
  801118:	89 da                	mov    %ebx,%edx
  80111a:	89 f8                	mov    %edi,%eax
  80111c:	e8 d0 fd ff ff       	call   800ef1 <dup_or_share>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801121:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801127:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  80112d:	77 36                	ja     801165 <fork_v0+0xa2>
		if (addr != UXSTACKTOP - PGSIZE) {
  80112f:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801135:	74 ea                	je     801121 <fork_v0+0x5e>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801137:	89 d8                	mov    %ebx,%eax
  801139:	c1 e8 16             	shr    $0x16,%eax
  80113c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801143:	a8 01                	test   $0x1,%al
  801145:	74 da                	je     801121 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  801147:	89 d8                	mov    %ebx,%eax
  801149:	c1 e8 0c             	shr    $0xc,%eax
  80114c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801153:	f6 c2 01             	test   $0x1,%dl
  801156:	74 c9                	je     801121 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
  801158:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  80115f:	a8 04                	test   $0x4,%al
  801161:	74 be                	je     801121 <fork_v0+0x5e>
  801163:	eb ae                	jmp    801113 <fork_v0+0x50>
				             PTE_P | PTE_U | PTE_W);
			}
		}
	}

	if (sys_env_set_status(env_id, ENV_RUNNABLE) < 0) {
  801165:	83 ec 08             	sub    $0x8,%esp
  801168:	6a 02                	push   $0x2
  80116a:	56                   	push   %esi
  80116b:	e8 f0 fb ff ff       	call   800d60 <sys_env_set_status>
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	85 c0                	test   %eax,%eax
  801175:	78 0a                	js     801181 <fork_v0+0xbe>
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
	}

	return env_id;
}
  801177:	89 f0                	mov    %esi,%eax
  801179:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117c:	5b                   	pop    %ebx
  80117d:	5e                   	pop    %esi
  80117e:	5f                   	pop    %edi
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
  801181:	83 ec 04             	sub    $0x4,%esp
  801184:	68 50 2f 80 00       	push   $0x802f50
  801189:	68 92 00 00 00       	push   $0x92
  80118e:	68 bf 2f 80 00       	push   $0x802fbf
  801193:	e8 76 f0 ff ff       	call   80020e <_panic>

00801198 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801198:	f3 0f 1e fb          	endbr32 
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	57                   	push   %edi
  8011a0:	56                   	push   %esi
  8011a1:	53                   	push   %ebx
  8011a2:	83 ec 18             	sub    $0x18,%esp
	// return fork_v0(); // Uncomment this line if you want to run fork_v0.
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8011a5:	68 c4 0f 80 00       	push   $0x800fc4
  8011aa:	e8 06 15 00 00       	call   8026b5 <set_pgfault_handler>
  8011af:	b8 07 00 00 00       	mov    $0x7,%eax
  8011b4:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0) {
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	78 27                	js     8011e4 <fork+0x4c>
  8011bd:	89 c7                	mov    %eax,%edi
  8011bf:	89 c6                	mov    %eax,%esi
		thisenv = envs + ENVX(sys_getenvid());
		return envid;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  8011c1:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else if (envid == 0) {  // Son
  8011c6:	75 55                	jne    80121d <fork+0x85>
		thisenv = envs + ENVX(sys_getenvid());
  8011c8:	e8 c7 fa ff ff       	call   800c94 <sys_getenvid>
  8011cd:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011d2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011d5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011da:	a3 04 50 80 00       	mov    %eax,0x805004
		return envid;
  8011df:	e9 9b 00 00 00       	jmp    80127f <fork+0xe7>
		panic("ERROR IN FORK: SYS_EXOFORK");
  8011e4:	83 ec 04             	sub    $0x4,%esp
  8011e7:	68 81 30 80 00       	push   $0x803081
  8011ec:	68 b1 00 00 00       	push   $0xb1
  8011f1:	68 bf 2f 80 00       	push   $0x802fbf
  8011f6:	e8 13 f0 ff ff       	call   80020e <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
				duppage(envid, addr / PGSIZE);
  8011fb:	89 da                	mov    %ebx,%edx
  8011fd:	c1 ea 0c             	shr    $0xc,%edx
  801200:	89 f0                	mov    %esi,%eax
  801202:	e8 1d fc ff ff       	call   800e24 <duppage>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801207:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80120d:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801213:	77 2c                	ja     801241 <fork+0xa9>
		if (addr != UXSTACKTOP - PGSIZE) {
  801215:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80121b:	74 ea                	je     801207 <fork+0x6f>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80121d:	89 d8                	mov    %ebx,%eax
  80121f:	c1 e8 16             	shr    $0x16,%eax
  801222:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801229:	a8 01                	test   $0x1,%al
  80122b:	74 da                	je     801207 <fork+0x6f>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
  80122d:	89 d8                	mov    %ebx,%eax
  80122f:	c1 e8 0c             	shr    $0xc,%eax
  801232:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801239:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80123b:	a8 05                	test   $0x5,%al
  80123d:	75 c8                	jne    801207 <fork+0x6f>
  80123f:	eb ba                	jmp    8011fb <fork+0x63>
			}
		}
	}

	if (sys_page_alloc(envid,
  801241:	83 ec 04             	sub    $0x4,%esp
  801244:	6a 07                	push   $0x7
  801246:	68 00 f0 bf ee       	push   $0xeebff000
  80124b:	57                   	push   %edi
  80124c:	e8 96 fa ff ff       	call   800ce7 <sys_page_alloc>
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	85 c0                	test   %eax,%eax
  801256:	78 31                	js     801289 <fork+0xf1>
	                   PTE_P | PTE_U | PTE_W) < 0) {
		panic("ERROR FORK: SYS_PAGE_ALLOC");
	}

	extern void _pgfault_upcall(void);
	if (sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0) {
  801258:	83 ec 08             	sub    $0x8,%esp
  80125b:	68 28 27 80 00       	push   $0x802728
  801260:	57                   	push   %edi
  801261:	e8 48 fb ff ff       	call   800dae <sys_env_set_pgfault_upcall>
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 33                	js     8012a0 <fork+0x108>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
	}

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0) {
  80126d:	83 ec 08             	sub    $0x8,%esp
  801270:	6a 02                	push   $0x2
  801272:	57                   	push   %edi
  801273:	e8 e8 fa ff ff       	call   800d60 <sys_env_set_status>
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	78 38                	js     8012b7 <fork+0x11f>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
	}

	return envid;
}
  80127f:	89 f8                	mov    %edi,%eax
  801281:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801284:	5b                   	pop    %ebx
  801285:	5e                   	pop    %esi
  801286:	5f                   	pop    %edi
  801287:	5d                   	pop    %ebp
  801288:	c3                   	ret    
		panic("ERROR FORK: SYS_PAGE_ALLOC");
  801289:	83 ec 04             	sub    $0x4,%esp
  80128c:	68 9c 30 80 00       	push   $0x80309c
  801291:	68 c4 00 00 00       	push   $0xc4
  801296:	68 bf 2f 80 00       	push   $0x802fbf
  80129b:	e8 6e ef ff ff       	call   80020e <_panic>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
  8012a0:	83 ec 04             	sub    $0x4,%esp
  8012a3:	68 78 2f 80 00       	push   $0x802f78
  8012a8:	68 c9 00 00 00       	push   $0xc9
  8012ad:	68 bf 2f 80 00       	push   $0x802fbf
  8012b2:	e8 57 ef ff ff       	call   80020e <_panic>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
  8012b7:	83 ec 04             	sub    $0x4,%esp
  8012ba:	68 a0 2f 80 00       	push   $0x802fa0
  8012bf:	68 cd 00 00 00       	push   $0xcd
  8012c4:	68 bf 2f 80 00       	push   $0x802fbf
  8012c9:	e8 40 ef ff ff       	call   80020e <_panic>

008012ce <sfork>:

// Challenge!
int
sfork(void)
{
  8012ce:	f3 0f 1e fb          	endbr32 
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012d8:	68 b7 30 80 00       	push   $0x8030b7
  8012dd:	68 d7 00 00 00       	push   $0xd7
  8012e2:	68 bf 2f 80 00       	push   $0x802fbf
  8012e7:	e8 22 ef ff ff       	call   80020e <_panic>

008012ec <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012ec:	f3 0f 1e fb          	endbr32 
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012fb:	c1 e8 0c             	shr    $0xc,%eax
}
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801300:	f3 0f 1e fb          	endbr32 
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  80130a:	ff 75 08             	pushl  0x8(%ebp)
  80130d:	e8 da ff ff ff       	call   8012ec <fd2num>
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	c1 e0 0c             	shl    $0xc,%eax
  801318:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80131d:	c9                   	leave  
  80131e:	c3                   	ret    

0080131f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80131f:	f3 0f 1e fb          	endbr32 
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80132b:	89 c2                	mov    %eax,%edx
  80132d:	c1 ea 16             	shr    $0x16,%edx
  801330:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801337:	f6 c2 01             	test   $0x1,%dl
  80133a:	74 2d                	je     801369 <fd_alloc+0x4a>
  80133c:	89 c2                	mov    %eax,%edx
  80133e:	c1 ea 0c             	shr    $0xc,%edx
  801341:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801348:	f6 c2 01             	test   $0x1,%dl
  80134b:	74 1c                	je     801369 <fd_alloc+0x4a>
  80134d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801352:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801357:	75 d2                	jne    80132b <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801359:	8b 45 08             	mov    0x8(%ebp),%eax
  80135c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801362:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801367:	eb 0a                	jmp    801373 <fd_alloc+0x54>
			*fd_store = fd;
  801369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80136c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80136e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    

00801375 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801375:	f3 0f 1e fb          	endbr32 
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80137f:	83 f8 1f             	cmp    $0x1f,%eax
  801382:	77 30                	ja     8013b4 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801384:	c1 e0 0c             	shl    $0xc,%eax
  801387:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80138c:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801392:	f6 c2 01             	test   $0x1,%dl
  801395:	74 24                	je     8013bb <fd_lookup+0x46>
  801397:	89 c2                	mov    %eax,%edx
  801399:	c1 ea 0c             	shr    $0xc,%edx
  80139c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013a3:	f6 c2 01             	test   $0x1,%dl
  8013a6:	74 1a                	je     8013c2 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ab:	89 02                	mov    %eax,(%edx)
	return 0;
  8013ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013b2:	5d                   	pop    %ebp
  8013b3:	c3                   	ret    
		return -E_INVAL;
  8013b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013b9:	eb f7                	jmp    8013b2 <fd_lookup+0x3d>
		return -E_INVAL;
  8013bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c0:	eb f0                	jmp    8013b2 <fd_lookup+0x3d>
  8013c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c7:	eb e9                	jmp    8013b2 <fd_lookup+0x3d>

008013c9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013c9:	f3 0f 1e fb          	endbr32 
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	83 ec 08             	sub    $0x8,%esp
  8013d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d6:	ba 4c 31 80 00       	mov    $0x80314c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013db:	b8 0c 40 80 00       	mov    $0x80400c,%eax
		if (devtab[i]->dev_id == dev_id) {
  8013e0:	39 08                	cmp    %ecx,(%eax)
  8013e2:	74 33                	je     801417 <dev_lookup+0x4e>
  8013e4:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8013e7:	8b 02                	mov    (%edx),%eax
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	75 f3                	jne    8013e0 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013ed:	a1 04 50 80 00       	mov    0x805004,%eax
  8013f2:	8b 40 48             	mov    0x48(%eax),%eax
  8013f5:	83 ec 04             	sub    $0x4,%esp
  8013f8:	51                   	push   %ecx
  8013f9:	50                   	push   %eax
  8013fa:	68 d0 30 80 00       	push   $0x8030d0
  8013ff:	e8 f1 ee ff ff       	call   8002f5 <cprintf>
	*dev = 0;
  801404:	8b 45 0c             	mov    0xc(%ebp),%eax
  801407:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801415:	c9                   	leave  
  801416:	c3                   	ret    
			*dev = devtab[i];
  801417:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80141a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80141c:	b8 00 00 00 00       	mov    $0x0,%eax
  801421:	eb f2                	jmp    801415 <dev_lookup+0x4c>

00801423 <fd_close>:
{
  801423:	f3 0f 1e fb          	endbr32 
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	57                   	push   %edi
  80142b:	56                   	push   %esi
  80142c:	53                   	push   %ebx
  80142d:	83 ec 28             	sub    $0x28,%esp
  801430:	8b 75 08             	mov    0x8(%ebp),%esi
  801433:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801436:	56                   	push   %esi
  801437:	e8 b0 fe ff ff       	call   8012ec <fd2num>
  80143c:	83 c4 08             	add    $0x8,%esp
  80143f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801442:	52                   	push   %edx
  801443:	50                   	push   %eax
  801444:	e8 2c ff ff ff       	call   801375 <fd_lookup>
  801449:	89 c3                	mov    %eax,%ebx
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	85 c0                	test   %eax,%eax
  801450:	78 05                	js     801457 <fd_close+0x34>
	    || fd != fd2)
  801452:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801455:	74 16                	je     80146d <fd_close+0x4a>
		return (must_exist ? r : 0);
  801457:	89 f8                	mov    %edi,%eax
  801459:	84 c0                	test   %al,%al
  80145b:	b8 00 00 00 00       	mov    $0x0,%eax
  801460:	0f 44 d8             	cmove  %eax,%ebx
}
  801463:	89 d8                	mov    %ebx,%eax
  801465:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801468:	5b                   	pop    %ebx
  801469:	5e                   	pop    %esi
  80146a:	5f                   	pop    %edi
  80146b:	5d                   	pop    %ebp
  80146c:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80146d:	83 ec 08             	sub    $0x8,%esp
  801470:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801473:	50                   	push   %eax
  801474:	ff 36                	pushl  (%esi)
  801476:	e8 4e ff ff ff       	call   8013c9 <dev_lookup>
  80147b:	89 c3                	mov    %eax,%ebx
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	85 c0                	test   %eax,%eax
  801482:	78 1a                	js     80149e <fd_close+0x7b>
		if (dev->dev_close)
  801484:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801487:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80148a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80148f:	85 c0                	test   %eax,%eax
  801491:	74 0b                	je     80149e <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801493:	83 ec 0c             	sub    $0xc,%esp
  801496:	56                   	push   %esi
  801497:	ff d0                	call   *%eax
  801499:	89 c3                	mov    %eax,%ebx
  80149b:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80149e:	83 ec 08             	sub    $0x8,%esp
  8014a1:	56                   	push   %esi
  8014a2:	6a 00                	push   $0x0
  8014a4:	e8 90 f8 ff ff       	call   800d39 <sys_page_unmap>
	return r;
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	eb b5                	jmp    801463 <fd_close+0x40>

008014ae <close>:

int
close(int fdnum)
{
  8014ae:	f3 0f 1e fb          	endbr32 
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	ff 75 08             	pushl  0x8(%ebp)
  8014bf:	e8 b1 fe ff ff       	call   801375 <fd_lookup>
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	79 02                	jns    8014cd <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8014cb:	c9                   	leave  
  8014cc:	c3                   	ret    
		return fd_close(fd, 1);
  8014cd:	83 ec 08             	sub    $0x8,%esp
  8014d0:	6a 01                	push   $0x1
  8014d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d5:	e8 49 ff ff ff       	call   801423 <fd_close>
  8014da:	83 c4 10             	add    $0x10,%esp
  8014dd:	eb ec                	jmp    8014cb <close+0x1d>

008014df <close_all>:

void
close_all(void)
{
  8014df:	f3 0f 1e fb          	endbr32 
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	53                   	push   %ebx
  8014e7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ea:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014ef:	83 ec 0c             	sub    $0xc,%esp
  8014f2:	53                   	push   %ebx
  8014f3:	e8 b6 ff ff ff       	call   8014ae <close>
	for (i = 0; i < MAXFD; i++)
  8014f8:	83 c3 01             	add    $0x1,%ebx
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	83 fb 20             	cmp    $0x20,%ebx
  801501:	75 ec                	jne    8014ef <close_all+0x10>
}
  801503:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801506:	c9                   	leave  
  801507:	c3                   	ret    

00801508 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801508:	f3 0f 1e fb          	endbr32 
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	57                   	push   %edi
  801510:	56                   	push   %esi
  801511:	53                   	push   %ebx
  801512:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801515:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801518:	50                   	push   %eax
  801519:	ff 75 08             	pushl  0x8(%ebp)
  80151c:	e8 54 fe ff ff       	call   801375 <fd_lookup>
  801521:	89 c3                	mov    %eax,%ebx
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	85 c0                	test   %eax,%eax
  801528:	0f 88 81 00 00 00    	js     8015af <dup+0xa7>
		return r;
	close(newfdnum);
  80152e:	83 ec 0c             	sub    $0xc,%esp
  801531:	ff 75 0c             	pushl  0xc(%ebp)
  801534:	e8 75 ff ff ff       	call   8014ae <close>

	newfd = INDEX2FD(newfdnum);
  801539:	8b 75 0c             	mov    0xc(%ebp),%esi
  80153c:	c1 e6 0c             	shl    $0xc,%esi
  80153f:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801545:	83 c4 04             	add    $0x4,%esp
  801548:	ff 75 e4             	pushl  -0x1c(%ebp)
  80154b:	e8 b0 fd ff ff       	call   801300 <fd2data>
  801550:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801552:	89 34 24             	mov    %esi,(%esp)
  801555:	e8 a6 fd ff ff       	call   801300 <fd2data>
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80155f:	89 d8                	mov    %ebx,%eax
  801561:	c1 e8 16             	shr    $0x16,%eax
  801564:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80156b:	a8 01                	test   $0x1,%al
  80156d:	74 11                	je     801580 <dup+0x78>
  80156f:	89 d8                	mov    %ebx,%eax
  801571:	c1 e8 0c             	shr    $0xc,%eax
  801574:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80157b:	f6 c2 01             	test   $0x1,%dl
  80157e:	75 39                	jne    8015b9 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801580:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801583:	89 d0                	mov    %edx,%eax
  801585:	c1 e8 0c             	shr    $0xc,%eax
  801588:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80158f:	83 ec 0c             	sub    $0xc,%esp
  801592:	25 07 0e 00 00       	and    $0xe07,%eax
  801597:	50                   	push   %eax
  801598:	56                   	push   %esi
  801599:	6a 00                	push   $0x0
  80159b:	52                   	push   %edx
  80159c:	6a 00                	push   $0x0
  80159e:	e8 6c f7 ff ff       	call   800d0f <sys_page_map>
  8015a3:	89 c3                	mov    %eax,%ebx
  8015a5:	83 c4 20             	add    $0x20,%esp
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 31                	js     8015dd <dup+0xd5>
		goto err;

	return newfdnum;
  8015ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015af:	89 d8                	mov    %ebx,%eax
  8015b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b4:	5b                   	pop    %ebx
  8015b5:	5e                   	pop    %esi
  8015b6:	5f                   	pop    %edi
  8015b7:	5d                   	pop    %ebp
  8015b8:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015b9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015c0:	83 ec 0c             	sub    $0xc,%esp
  8015c3:	25 07 0e 00 00       	and    $0xe07,%eax
  8015c8:	50                   	push   %eax
  8015c9:	57                   	push   %edi
  8015ca:	6a 00                	push   $0x0
  8015cc:	53                   	push   %ebx
  8015cd:	6a 00                	push   $0x0
  8015cf:	e8 3b f7 ff ff       	call   800d0f <sys_page_map>
  8015d4:	89 c3                	mov    %eax,%ebx
  8015d6:	83 c4 20             	add    $0x20,%esp
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	79 a3                	jns    801580 <dup+0x78>
	sys_page_unmap(0, newfd);
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	56                   	push   %esi
  8015e1:	6a 00                	push   $0x0
  8015e3:	e8 51 f7 ff ff       	call   800d39 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015e8:	83 c4 08             	add    $0x8,%esp
  8015eb:	57                   	push   %edi
  8015ec:	6a 00                	push   $0x0
  8015ee:	e8 46 f7 ff ff       	call   800d39 <sys_page_unmap>
	return r;
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	eb b7                	jmp    8015af <dup+0xa7>

008015f8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015f8:	f3 0f 1e fb          	endbr32 
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	53                   	push   %ebx
  801600:	83 ec 1c             	sub    $0x1c,%esp
  801603:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801606:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801609:	50                   	push   %eax
  80160a:	53                   	push   %ebx
  80160b:	e8 65 fd ff ff       	call   801375 <fd_lookup>
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	78 3f                	js     801656 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161d:	50                   	push   %eax
  80161e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801621:	ff 30                	pushl  (%eax)
  801623:	e8 a1 fd ff ff       	call   8013c9 <dev_lookup>
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 27                	js     801656 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80162f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801632:	8b 42 08             	mov    0x8(%edx),%eax
  801635:	83 e0 03             	and    $0x3,%eax
  801638:	83 f8 01             	cmp    $0x1,%eax
  80163b:	74 1e                	je     80165b <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80163d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801640:	8b 40 08             	mov    0x8(%eax),%eax
  801643:	85 c0                	test   %eax,%eax
  801645:	74 35                	je     80167c <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801647:	83 ec 04             	sub    $0x4,%esp
  80164a:	ff 75 10             	pushl  0x10(%ebp)
  80164d:	ff 75 0c             	pushl  0xc(%ebp)
  801650:	52                   	push   %edx
  801651:	ff d0                	call   *%eax
  801653:	83 c4 10             	add    $0x10,%esp
}
  801656:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801659:	c9                   	leave  
  80165a:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80165b:	a1 04 50 80 00       	mov    0x805004,%eax
  801660:	8b 40 48             	mov    0x48(%eax),%eax
  801663:	83 ec 04             	sub    $0x4,%esp
  801666:	53                   	push   %ebx
  801667:	50                   	push   %eax
  801668:	68 11 31 80 00       	push   $0x803111
  80166d:	e8 83 ec ff ff       	call   8002f5 <cprintf>
		return -E_INVAL;
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80167a:	eb da                	jmp    801656 <read+0x5e>
		return -E_NOT_SUPP;
  80167c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801681:	eb d3                	jmp    801656 <read+0x5e>

00801683 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801683:	f3 0f 1e fb          	endbr32 
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	57                   	push   %edi
  80168b:	56                   	push   %esi
  80168c:	53                   	push   %ebx
  80168d:	83 ec 0c             	sub    $0xc,%esp
  801690:	8b 7d 08             	mov    0x8(%ebp),%edi
  801693:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801696:	bb 00 00 00 00       	mov    $0x0,%ebx
  80169b:	eb 02                	jmp    80169f <readn+0x1c>
  80169d:	01 c3                	add    %eax,%ebx
  80169f:	39 f3                	cmp    %esi,%ebx
  8016a1:	73 21                	jae    8016c4 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016a3:	83 ec 04             	sub    $0x4,%esp
  8016a6:	89 f0                	mov    %esi,%eax
  8016a8:	29 d8                	sub    %ebx,%eax
  8016aa:	50                   	push   %eax
  8016ab:	89 d8                	mov    %ebx,%eax
  8016ad:	03 45 0c             	add    0xc(%ebp),%eax
  8016b0:	50                   	push   %eax
  8016b1:	57                   	push   %edi
  8016b2:	e8 41 ff ff ff       	call   8015f8 <read>
		if (m < 0)
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 04                	js     8016c2 <readn+0x3f>
			return m;
		if (m == 0)
  8016be:	75 dd                	jne    80169d <readn+0x1a>
  8016c0:	eb 02                	jmp    8016c4 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016c2:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8016c4:	89 d8                	mov    %ebx,%eax
  8016c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c9:	5b                   	pop    %ebx
  8016ca:	5e                   	pop    %esi
  8016cb:	5f                   	pop    %edi
  8016cc:	5d                   	pop    %ebp
  8016cd:	c3                   	ret    

008016ce <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016ce:	f3 0f 1e fb          	endbr32 
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	53                   	push   %ebx
  8016d6:	83 ec 1c             	sub    $0x1c,%esp
  8016d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016df:	50                   	push   %eax
  8016e0:	53                   	push   %ebx
  8016e1:	e8 8f fc ff ff       	call   801375 <fd_lookup>
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	78 3a                	js     801727 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ed:	83 ec 08             	sub    $0x8,%esp
  8016f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f3:	50                   	push   %eax
  8016f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f7:	ff 30                	pushl  (%eax)
  8016f9:	e8 cb fc ff ff       	call   8013c9 <dev_lookup>
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	85 c0                	test   %eax,%eax
  801703:	78 22                	js     801727 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801705:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801708:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80170c:	74 1e                	je     80172c <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80170e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801711:	8b 52 0c             	mov    0xc(%edx),%edx
  801714:	85 d2                	test   %edx,%edx
  801716:	74 35                	je     80174d <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801718:	83 ec 04             	sub    $0x4,%esp
  80171b:	ff 75 10             	pushl  0x10(%ebp)
  80171e:	ff 75 0c             	pushl  0xc(%ebp)
  801721:	50                   	push   %eax
  801722:	ff d2                	call   *%edx
  801724:	83 c4 10             	add    $0x10,%esp
}
  801727:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172a:	c9                   	leave  
  80172b:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80172c:	a1 04 50 80 00       	mov    0x805004,%eax
  801731:	8b 40 48             	mov    0x48(%eax),%eax
  801734:	83 ec 04             	sub    $0x4,%esp
  801737:	53                   	push   %ebx
  801738:	50                   	push   %eax
  801739:	68 2d 31 80 00       	push   $0x80312d
  80173e:	e8 b2 eb ff ff       	call   8002f5 <cprintf>
		return -E_INVAL;
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80174b:	eb da                	jmp    801727 <write+0x59>
		return -E_NOT_SUPP;
  80174d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801752:	eb d3                	jmp    801727 <write+0x59>

00801754 <seek>:

int
seek(int fdnum, off_t offset)
{
  801754:	f3 0f 1e fb          	endbr32 
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80175e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801761:	50                   	push   %eax
  801762:	ff 75 08             	pushl  0x8(%ebp)
  801765:	e8 0b fc ff ff       	call   801375 <fd_lookup>
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 0e                	js     80177f <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801771:	8b 55 0c             	mov    0xc(%ebp),%edx
  801774:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801777:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80177a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80177f:	c9                   	leave  
  801780:	c3                   	ret    

00801781 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801781:	f3 0f 1e fb          	endbr32 
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	53                   	push   %ebx
  801789:	83 ec 1c             	sub    $0x1c,%esp
  80178c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801792:	50                   	push   %eax
  801793:	53                   	push   %ebx
  801794:	e8 dc fb ff ff       	call   801375 <fd_lookup>
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	85 c0                	test   %eax,%eax
  80179e:	78 37                	js     8017d7 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a0:	83 ec 08             	sub    $0x8,%esp
  8017a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a6:	50                   	push   %eax
  8017a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017aa:	ff 30                	pushl  (%eax)
  8017ac:	e8 18 fc ff ff       	call   8013c9 <dev_lookup>
  8017b1:	83 c4 10             	add    $0x10,%esp
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	78 1f                	js     8017d7 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017bf:	74 1b                	je     8017dc <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8017c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017c4:	8b 52 18             	mov    0x18(%edx),%edx
  8017c7:	85 d2                	test   %edx,%edx
  8017c9:	74 32                	je     8017fd <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017cb:	83 ec 08             	sub    $0x8,%esp
  8017ce:	ff 75 0c             	pushl  0xc(%ebp)
  8017d1:	50                   	push   %eax
  8017d2:	ff d2                	call   *%edx
  8017d4:	83 c4 10             	add    $0x10,%esp
}
  8017d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017da:	c9                   	leave  
  8017db:	c3                   	ret    
			thisenv->env_id, fdnum);
  8017dc:	a1 04 50 80 00       	mov    0x805004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017e1:	8b 40 48             	mov    0x48(%eax),%eax
  8017e4:	83 ec 04             	sub    $0x4,%esp
  8017e7:	53                   	push   %ebx
  8017e8:	50                   	push   %eax
  8017e9:	68 f0 30 80 00       	push   $0x8030f0
  8017ee:	e8 02 eb ff ff       	call   8002f5 <cprintf>
		return -E_INVAL;
  8017f3:	83 c4 10             	add    $0x10,%esp
  8017f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017fb:	eb da                	jmp    8017d7 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8017fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801802:	eb d3                	jmp    8017d7 <ftruncate+0x56>

00801804 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801804:	f3 0f 1e fb          	endbr32 
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	53                   	push   %ebx
  80180c:	83 ec 1c             	sub    $0x1c,%esp
  80180f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801812:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801815:	50                   	push   %eax
  801816:	ff 75 08             	pushl  0x8(%ebp)
  801819:	e8 57 fb ff ff       	call   801375 <fd_lookup>
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	85 c0                	test   %eax,%eax
  801823:	78 4b                	js     801870 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801825:	83 ec 08             	sub    $0x8,%esp
  801828:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80182b:	50                   	push   %eax
  80182c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182f:	ff 30                	pushl  (%eax)
  801831:	e8 93 fb ff ff       	call   8013c9 <dev_lookup>
  801836:	83 c4 10             	add    $0x10,%esp
  801839:	85 c0                	test   %eax,%eax
  80183b:	78 33                	js     801870 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80183d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801840:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801844:	74 2f                	je     801875 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801846:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801849:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801850:	00 00 00 
	stat->st_isdir = 0;
  801853:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80185a:	00 00 00 
	stat->st_dev = dev;
  80185d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801863:	83 ec 08             	sub    $0x8,%esp
  801866:	53                   	push   %ebx
  801867:	ff 75 f0             	pushl  -0x10(%ebp)
  80186a:	ff 50 14             	call   *0x14(%eax)
  80186d:	83 c4 10             	add    $0x10,%esp
}
  801870:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801873:	c9                   	leave  
  801874:	c3                   	ret    
		return -E_NOT_SUPP;
  801875:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80187a:	eb f4                	jmp    801870 <fstat+0x6c>

0080187c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80187c:	f3 0f 1e fb          	endbr32 
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	56                   	push   %esi
  801884:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801885:	83 ec 08             	sub    $0x8,%esp
  801888:	6a 00                	push   $0x0
  80188a:	ff 75 08             	pushl  0x8(%ebp)
  80188d:	e8 20 02 00 00       	call   801ab2 <open>
  801892:	89 c3                	mov    %eax,%ebx
  801894:	83 c4 10             	add    $0x10,%esp
  801897:	85 c0                	test   %eax,%eax
  801899:	78 1b                	js     8018b6 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80189b:	83 ec 08             	sub    $0x8,%esp
  80189e:	ff 75 0c             	pushl  0xc(%ebp)
  8018a1:	50                   	push   %eax
  8018a2:	e8 5d ff ff ff       	call   801804 <fstat>
  8018a7:	89 c6                	mov    %eax,%esi
	close(fd);
  8018a9:	89 1c 24             	mov    %ebx,(%esp)
  8018ac:	e8 fd fb ff ff       	call   8014ae <close>
	return r;
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	89 f3                	mov    %esi,%ebx
}
  8018b6:	89 d8                	mov    %ebx,%eax
  8018b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018bb:	5b                   	pop    %ebx
  8018bc:	5e                   	pop    %esi
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	56                   	push   %esi
  8018c3:	53                   	push   %ebx
  8018c4:	89 c6                	mov    %eax,%esi
  8018c6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018c8:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8018cf:	74 27                	je     8018f8 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018d1:	6a 07                	push   $0x7
  8018d3:	68 00 60 80 00       	push   $0x806000
  8018d8:	56                   	push   %esi
  8018d9:	ff 35 00 50 80 00    	pushl  0x805000
  8018df:	e8 d7 0e 00 00       	call   8027bb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018e4:	83 c4 0c             	add    $0xc,%esp
  8018e7:	6a 00                	push   $0x0
  8018e9:	53                   	push   %ebx
  8018ea:	6a 00                	push   $0x0
  8018ec:	e8 5d 0e 00 00       	call   80274e <ipc_recv>
}
  8018f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5e                   	pop    %esi
  8018f6:	5d                   	pop    %ebp
  8018f7:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018f8:	83 ec 0c             	sub    $0xc,%esp
  8018fb:	6a 01                	push   $0x1
  8018fd:	e8 0c 0f 00 00       	call   80280e <ipc_find_env>
  801902:	a3 00 50 80 00       	mov    %eax,0x805000
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	eb c5                	jmp    8018d1 <fsipc+0x12>

0080190c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80190c:	f3 0f 1e fb          	endbr32 
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801916:	8b 45 08             	mov    0x8(%ebp),%eax
  801919:	8b 40 0c             	mov    0xc(%eax),%eax
  80191c:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801921:	8b 45 0c             	mov    0xc(%ebp),%eax
  801924:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801929:	ba 00 00 00 00       	mov    $0x0,%edx
  80192e:	b8 02 00 00 00       	mov    $0x2,%eax
  801933:	e8 87 ff ff ff       	call   8018bf <fsipc>
}
  801938:	c9                   	leave  
  801939:	c3                   	ret    

0080193a <devfile_flush>:
{
  80193a:	f3 0f 1e fb          	endbr32 
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801944:	8b 45 08             	mov    0x8(%ebp),%eax
  801947:	8b 40 0c             	mov    0xc(%eax),%eax
  80194a:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80194f:	ba 00 00 00 00       	mov    $0x0,%edx
  801954:	b8 06 00 00 00       	mov    $0x6,%eax
  801959:	e8 61 ff ff ff       	call   8018bf <fsipc>
}
  80195e:	c9                   	leave  
  80195f:	c3                   	ret    

00801960 <devfile_stat>:
{
  801960:	f3 0f 1e fb          	endbr32 
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	53                   	push   %ebx
  801968:	83 ec 04             	sub    $0x4,%esp
  80196b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80196e:	8b 45 08             	mov    0x8(%ebp),%eax
  801971:	8b 40 0c             	mov    0xc(%eax),%eax
  801974:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801979:	ba 00 00 00 00       	mov    $0x0,%edx
  80197e:	b8 05 00 00 00       	mov    $0x5,%eax
  801983:	e8 37 ff ff ff       	call   8018bf <fsipc>
  801988:	85 c0                	test   %eax,%eax
  80198a:	78 2c                	js     8019b8 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80198c:	83 ec 08             	sub    $0x8,%esp
  80198f:	68 00 60 80 00       	push   $0x806000
  801994:	53                   	push   %ebx
  801995:	e8 c5 ee ff ff       	call   80085f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80199a:	a1 80 60 80 00       	mov    0x806080,%eax
  80199f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019a5:	a1 84 60 80 00       	mov    0x806084,%eax
  8019aa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019bb:	c9                   	leave  
  8019bc:	c3                   	ret    

008019bd <devfile_write>:
{
  8019bd:	f3 0f 1e fb          	endbr32 
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	57                   	push   %edi
  8019c5:	56                   	push   %esi
  8019c6:	53                   	push   %ebx
  8019c7:	83 ec 0c             	sub    $0xc,%esp
  8019ca:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d6:	a3 00 60 80 00       	mov    %eax,0x806000
	int r = 0;
  8019db:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8019e0:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  8019e5:	85 db                	test   %ebx,%ebx
  8019e7:	74 3b                	je     801a24 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8019e9:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8019ef:	89 f8                	mov    %edi,%eax
  8019f1:	0f 46 c3             	cmovbe %ebx,%eax
  8019f4:	a3 04 60 80 00       	mov    %eax,0x806004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  8019f9:	83 ec 04             	sub    $0x4,%esp
  8019fc:	50                   	push   %eax
  8019fd:	56                   	push   %esi
  8019fe:	68 08 60 80 00       	push   $0x806008
  801a03:	e8 0f f0 ff ff       	call   800a17 <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a08:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0d:	b8 04 00 00 00       	mov    $0x4,%eax
  801a12:	e8 a8 fe ff ff       	call   8018bf <fsipc>
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 06                	js     801a24 <devfile_write+0x67>
		buf_aux += r;
  801a1e:	01 c6                	add    %eax,%esi
		n -= r;
  801a20:	29 c3                	sub    %eax,%ebx
  801a22:	eb c1                	jmp    8019e5 <devfile_write+0x28>
}
  801a24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a27:	5b                   	pop    %ebx
  801a28:	5e                   	pop    %esi
  801a29:	5f                   	pop    %edi
  801a2a:	5d                   	pop    %ebp
  801a2b:	c3                   	ret    

00801a2c <devfile_read>:
{
  801a2c:	f3 0f 1e fb          	endbr32 
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	56                   	push   %esi
  801a34:	53                   	push   %ebx
  801a35:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a38:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a3e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801a43:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a49:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4e:	b8 03 00 00 00       	mov    $0x3,%eax
  801a53:	e8 67 fe ff ff       	call   8018bf <fsipc>
  801a58:	89 c3                	mov    %eax,%ebx
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	78 1f                	js     801a7d <devfile_read+0x51>
	assert(r <= n);
  801a5e:	39 f0                	cmp    %esi,%eax
  801a60:	77 24                	ja     801a86 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801a62:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a67:	7f 33                	jg     801a9c <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a69:	83 ec 04             	sub    $0x4,%esp
  801a6c:	50                   	push   %eax
  801a6d:	68 00 60 80 00       	push   $0x806000
  801a72:	ff 75 0c             	pushl  0xc(%ebp)
  801a75:	e8 9d ef ff ff       	call   800a17 <memmove>
	return r;
  801a7a:	83 c4 10             	add    $0x10,%esp
}
  801a7d:	89 d8                	mov    %ebx,%eax
  801a7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a82:	5b                   	pop    %ebx
  801a83:	5e                   	pop    %esi
  801a84:	5d                   	pop    %ebp
  801a85:	c3                   	ret    
	assert(r <= n);
  801a86:	68 5c 31 80 00       	push   $0x80315c
  801a8b:	68 63 31 80 00       	push   $0x803163
  801a90:	6a 7c                	push   $0x7c
  801a92:	68 78 31 80 00       	push   $0x803178
  801a97:	e8 72 e7 ff ff       	call   80020e <_panic>
	assert(r <= PGSIZE);
  801a9c:	68 83 31 80 00       	push   $0x803183
  801aa1:	68 63 31 80 00       	push   $0x803163
  801aa6:	6a 7d                	push   $0x7d
  801aa8:	68 78 31 80 00       	push   $0x803178
  801aad:	e8 5c e7 ff ff       	call   80020e <_panic>

00801ab2 <open>:
{
  801ab2:	f3 0f 1e fb          	endbr32 
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	56                   	push   %esi
  801aba:	53                   	push   %ebx
  801abb:	83 ec 1c             	sub    $0x1c,%esp
  801abe:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801ac1:	56                   	push   %esi
  801ac2:	e8 55 ed ff ff       	call   80081c <strlen>
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801acf:	7f 6c                	jg     801b3d <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801ad1:	83 ec 0c             	sub    $0xc,%esp
  801ad4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad7:	50                   	push   %eax
  801ad8:	e8 42 f8 ff ff       	call   80131f <fd_alloc>
  801add:	89 c3                	mov    %eax,%ebx
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	78 3c                	js     801b22 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801ae6:	83 ec 08             	sub    $0x8,%esp
  801ae9:	56                   	push   %esi
  801aea:	68 00 60 80 00       	push   $0x806000
  801aef:	e8 6b ed ff ff       	call   80085f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af7:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801afc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aff:	b8 01 00 00 00       	mov    $0x1,%eax
  801b04:	e8 b6 fd ff ff       	call   8018bf <fsipc>
  801b09:	89 c3                	mov    %eax,%ebx
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	78 19                	js     801b2b <open+0x79>
	return fd2num(fd);
  801b12:	83 ec 0c             	sub    $0xc,%esp
  801b15:	ff 75 f4             	pushl  -0xc(%ebp)
  801b18:	e8 cf f7 ff ff       	call   8012ec <fd2num>
  801b1d:	89 c3                	mov    %eax,%ebx
  801b1f:	83 c4 10             	add    $0x10,%esp
}
  801b22:	89 d8                	mov    %ebx,%eax
  801b24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b27:	5b                   	pop    %ebx
  801b28:	5e                   	pop    %esi
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    
		fd_close(fd, 0);
  801b2b:	83 ec 08             	sub    $0x8,%esp
  801b2e:	6a 00                	push   $0x0
  801b30:	ff 75 f4             	pushl  -0xc(%ebp)
  801b33:	e8 eb f8 ff ff       	call   801423 <fd_close>
		return r;
  801b38:	83 c4 10             	add    $0x10,%esp
  801b3b:	eb e5                	jmp    801b22 <open+0x70>
		return -E_BAD_PATH;
  801b3d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801b42:	eb de                	jmp    801b22 <open+0x70>

00801b44 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b44:	f3 0f 1e fb          	endbr32 
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b53:	b8 08 00 00 00       	mov    $0x8,%eax
  801b58:	e8 62 fd ff ff       	call   8018bf <fsipc>
}
  801b5d:	c9                   	leave  
  801b5e:	c3                   	ret    

00801b5f <copy_shared_pages>:
}

// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	89 c6                	mov    %eax,%esi
	// LAB 5: Your code here.
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801b66:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b6b:	eb 33                	jmp    801ba0 <copy_shared_pages+0x41>
			     0)) {
				sys_page_map(0,
				             (void *) addr,
				             child,
				             (void *) addr,
				             (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  801b6d:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
				sys_page_map(0,
  801b74:	83 ec 0c             	sub    $0xc,%esp
  801b77:	25 07 0e 00 00       	and    $0xe07,%eax
  801b7c:	50                   	push   %eax
  801b7d:	53                   	push   %ebx
  801b7e:	56                   	push   %esi
  801b7f:	53                   	push   %ebx
  801b80:	6a 00                	push   $0x0
  801b82:	e8 88 f1 ff ff       	call   800d0f <sys_page_map>
  801b87:	83 c4 20             	add    $0x20,%esp
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801b8a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801b90:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801b96:	77 2f                	ja     801bc7 <copy_shared_pages+0x68>
		if (addr != UXSTACKTOP - PGSIZE) {
  801b98:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801b9e:	74 ea                	je     801b8a <copy_shared_pages+0x2b>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801ba0:	89 d8                	mov    %ebx,%eax
  801ba2:	c1 e8 16             	shr    $0x16,%eax
  801ba5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bac:	a8 01                	test   $0x1,%al
  801bae:	74 da                	je     801b8a <copy_shared_pages+0x2b>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U | PTE_SHARE)) ==
  801bb0:	89 da                	mov    %ebx,%edx
  801bb2:	c1 ea 0c             	shr    $0xc,%edx
  801bb5:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801bbc:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801bbe:	a9 05 04 00 00       	test   $0x405,%eax
  801bc3:	75 c5                	jne    801b8a <copy_shared_pages+0x2b>
  801bc5:	eb a6                	jmp    801b6d <copy_shared_pages+0xe>
			}
		}
	}
	return 0;
}
  801bc7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bcf:	5b                   	pop    %ebx
  801bd0:	5e                   	pop    %esi
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    

00801bd3 <init_stack>:
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	57                   	push   %edi
  801bd7:	56                   	push   %esi
  801bd8:	53                   	push   %ebx
  801bd9:	83 ec 2c             	sub    $0x2c,%esp
  801bdc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801bdf:	89 55 d0             	mov    %edx,-0x30(%ebp)
  801be2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (argc = 0; argv[argc] != 0; argc++)
  801be5:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801bea:	be 00 00 00 00       	mov    $0x0,%esi
  801bef:	89 d7                	mov    %edx,%edi
  801bf1:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
	for (argc = 0; argv[argc] != 0; argc++)
  801bf8:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801bfb:	85 c0                	test   %eax,%eax
  801bfd:	74 15                	je     801c14 <init_stack+0x41>
		string_size += strlen(argv[argc]) + 1;
  801bff:	83 ec 0c             	sub    $0xc,%esp
  801c02:	50                   	push   %eax
  801c03:	e8 14 ec ff ff       	call   80081c <strlen>
  801c08:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801c0c:	83 c3 01             	add    $0x1,%ebx
  801c0f:	83 c4 10             	add    $0x10,%esp
  801c12:	eb dd                	jmp    801bf1 <init_stack+0x1e>
  801c14:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801c17:	89 4d d8             	mov    %ecx,-0x28(%ebp)
	string_store = (char *) UTEMP + PGSIZE - string_size;
  801c1a:	bf 00 10 40 00       	mov    $0x401000,%edi
  801c1f:	29 f7                	sub    %esi,%edi
	argv_store = (uintptr_t *) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801c21:	89 fa                	mov    %edi,%edx
  801c23:	83 e2 fc             	and    $0xfffffffc,%edx
  801c26:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801c2d:	29 c2                	sub    %eax,%edx
  801c2f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	if ((void *) (argv_store - 2) < (void *) UTEMP)
  801c32:	8d 42 f8             	lea    -0x8(%edx),%eax
  801c35:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801c3a:	0f 86 06 01 00 00    	jbe    801d46 <init_stack+0x173>
	if ((r = sys_page_alloc(0, (void *) UTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801c40:	83 ec 04             	sub    $0x4,%esp
  801c43:	6a 07                	push   $0x7
  801c45:	68 00 00 40 00       	push   $0x400000
  801c4a:	6a 00                	push   $0x0
  801c4c:	e8 96 f0 ff ff       	call   800ce7 <sys_page_alloc>
  801c51:	89 c6                	mov    %eax,%esi
  801c53:	83 c4 10             	add    $0x10,%esp
  801c56:	85 c0                	test   %eax,%eax
  801c58:	0f 88 de 00 00 00    	js     801d3c <init_stack+0x169>
	for (i = 0; i < argc; i++) {
  801c5e:	be 00 00 00 00       	mov    $0x0,%esi
  801c63:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  801c66:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801c69:	39 75 e0             	cmp    %esi,-0x20(%ebp)
  801c6c:	7e 2f                	jle    801c9d <init_stack+0xca>
		argv_store[i] = UTEMP2USTACK(string_store);
  801c6e:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801c74:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801c77:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801c7a:	83 ec 08             	sub    $0x8,%esp
  801c7d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801c80:	57                   	push   %edi
  801c81:	e8 d9 eb ff ff       	call   80085f <strcpy>
		string_store += strlen(argv[i]) + 1;
  801c86:	83 c4 04             	add    $0x4,%esp
  801c89:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801c8c:	e8 8b eb ff ff       	call   80081c <strlen>
  801c91:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801c95:	83 c6 01             	add    $0x1,%esi
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	eb cc                	jmp    801c69 <init_stack+0x96>
	argv_store[argc] = 0;
  801c9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ca0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  801ca3:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char *) UTEMP + PGSIZE);
  801caa:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801cb0:	75 5f                	jne    801d11 <init_stack+0x13e>
	argv_store[-1] = UTEMP2USTACK(argv_store);
  801cb2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801cb5:	8d 82 00 d0 7f ee    	lea    -0x11803000(%edx),%eax
  801cbb:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801cbe:	89 d0                	mov    %edx,%eax
  801cc0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801cc3:	89 4a f8             	mov    %ecx,-0x8(%edx)
	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801cc6:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801ccb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801cce:	89 01                	mov    %eax,(%ecx)
	if ((r = sys_page_map(0,
  801cd0:	83 ec 0c             	sub    $0xc,%esp
  801cd3:	6a 07                	push   $0x7
  801cd5:	68 00 d0 bf ee       	push   $0xeebfd000
  801cda:	ff 75 d4             	pushl  -0x2c(%ebp)
  801cdd:	68 00 00 40 00       	push   $0x400000
  801ce2:	6a 00                	push   $0x0
  801ce4:	e8 26 f0 ff ff       	call   800d0f <sys_page_map>
  801ce9:	89 c6                	mov    %eax,%esi
  801ceb:	83 c4 20             	add    $0x20,%esp
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	78 38                	js     801d2a <init_stack+0x157>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801cf2:	83 ec 08             	sub    $0x8,%esp
  801cf5:	68 00 00 40 00       	push   $0x400000
  801cfa:	6a 00                	push   $0x0
  801cfc:	e8 38 f0 ff ff       	call   800d39 <sys_page_unmap>
  801d01:	89 c6                	mov    %eax,%esi
  801d03:	83 c4 10             	add    $0x10,%esp
  801d06:	85 c0                	test   %eax,%eax
  801d08:	78 20                	js     801d2a <init_stack+0x157>
	return 0;
  801d0a:	be 00 00 00 00       	mov    $0x0,%esi
  801d0f:	eb 2b                	jmp    801d3c <init_stack+0x169>
	assert(string_store == (char *) UTEMP + PGSIZE);
  801d11:	68 90 31 80 00       	push   $0x803190
  801d16:	68 63 31 80 00       	push   $0x803163
  801d1b:	68 fc 00 00 00       	push   $0xfc
  801d20:	68 b8 31 80 00       	push   $0x8031b8
  801d25:	e8 e4 e4 ff ff       	call   80020e <_panic>
	sys_page_unmap(0, UTEMP);
  801d2a:	83 ec 08             	sub    $0x8,%esp
  801d2d:	68 00 00 40 00       	push   $0x400000
  801d32:	6a 00                	push   $0x0
  801d34:	e8 00 f0 ff ff       	call   800d39 <sys_page_unmap>
	return r;
  801d39:	83 c4 10             	add    $0x10,%esp
}
  801d3c:	89 f0                	mov    %esi,%eax
  801d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d41:	5b                   	pop    %ebx
  801d42:	5e                   	pop    %esi
  801d43:	5f                   	pop    %edi
  801d44:	5d                   	pop    %ebp
  801d45:	c3                   	ret    
		return -E_NO_MEM;
  801d46:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  801d4b:	eb ef                	jmp    801d3c <init_stack+0x169>

00801d4d <map_segment>:
{
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	57                   	push   %edi
  801d51:	56                   	push   %esi
  801d52:	53                   	push   %ebx
  801d53:	83 ec 1c             	sub    $0x1c,%esp
  801d56:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801d59:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801d5c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  801d5f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((i = PGOFF(va))) {
  801d62:	89 d0                	mov    %edx,%eax
  801d64:	25 ff 0f 00 00       	and    $0xfff,%eax
  801d69:	74 0f                	je     801d7a <map_segment+0x2d>
		va -= i;
  801d6b:	29 c2                	sub    %eax,%edx
  801d6d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		memsz += i;
  801d70:	01 c1                	add    %eax,%ecx
  801d72:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		filesz += i;
  801d75:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801d77:	29 45 10             	sub    %eax,0x10(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801d7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d7f:	e9 99 00 00 00       	jmp    801e1d <map_segment+0xd0>
			if ((r = sys_page_alloc(0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  801d84:	83 ec 04             	sub    $0x4,%esp
  801d87:	6a 07                	push   $0x7
  801d89:	68 00 00 40 00       	push   $0x400000
  801d8e:	6a 00                	push   $0x0
  801d90:	e8 52 ef ff ff       	call   800ce7 <sys_page_alloc>
  801d95:	83 c4 10             	add    $0x10,%esp
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	0f 88 c1 00 00 00    	js     801e61 <map_segment+0x114>
			if ((r = seek(fd, fileoffset + i)) < 0)
  801da0:	83 ec 08             	sub    $0x8,%esp
  801da3:	89 f0                	mov    %esi,%eax
  801da5:	03 45 10             	add    0x10(%ebp),%eax
  801da8:	50                   	push   %eax
  801da9:	ff 75 08             	pushl  0x8(%ebp)
  801dac:	e8 a3 f9 ff ff       	call   801754 <seek>
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	85 c0                	test   %eax,%eax
  801db6:	0f 88 a5 00 00 00    	js     801e61 <map_segment+0x114>
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz - i))) < 0)
  801dbc:	83 ec 04             	sub    $0x4,%esp
  801dbf:	89 f8                	mov    %edi,%eax
  801dc1:	29 f0                	sub    %esi,%eax
  801dc3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801dc8:	ba 00 10 00 00       	mov    $0x1000,%edx
  801dcd:	0f 47 c2             	cmova  %edx,%eax
  801dd0:	50                   	push   %eax
  801dd1:	68 00 00 40 00       	push   $0x400000
  801dd6:	ff 75 08             	pushl  0x8(%ebp)
  801dd9:	e8 a5 f8 ff ff       	call   801683 <readn>
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	85 c0                	test   %eax,%eax
  801de3:	78 7c                	js     801e61 <map_segment+0x114>
			if ((r = sys_page_map(
  801de5:	83 ec 0c             	sub    $0xc,%esp
  801de8:	ff 75 14             	pushl  0x14(%ebp)
  801deb:	03 75 e0             	add    -0x20(%ebp),%esi
  801dee:	56                   	push   %esi
  801def:	ff 75 dc             	pushl  -0x24(%ebp)
  801df2:	68 00 00 40 00       	push   $0x400000
  801df7:	6a 00                	push   $0x0
  801df9:	e8 11 ef ff ff       	call   800d0f <sys_page_map>
  801dfe:	83 c4 20             	add    $0x20,%esp
  801e01:	85 c0                	test   %eax,%eax
  801e03:	78 42                	js     801e47 <map_segment+0xfa>
			sys_page_unmap(0, UTEMP);
  801e05:	83 ec 08             	sub    $0x8,%esp
  801e08:	68 00 00 40 00       	push   $0x400000
  801e0d:	6a 00                	push   $0x0
  801e0f:	e8 25 ef ff ff       	call   800d39 <sys_page_unmap>
  801e14:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801e17:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e1d:	89 de                	mov    %ebx,%esi
  801e1f:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  801e22:	76 38                	jbe    801e5c <map_segment+0x10f>
		if (i >= filesz) {
  801e24:	39 df                	cmp    %ebx,%edi
  801e26:	0f 87 58 ff ff ff    	ja     801d84 <map_segment+0x37>
			if ((r = sys_page_alloc(child, (void *) (va + i), perm)) < 0)
  801e2c:	83 ec 04             	sub    $0x4,%esp
  801e2f:	ff 75 14             	pushl  0x14(%ebp)
  801e32:	03 75 e0             	add    -0x20(%ebp),%esi
  801e35:	56                   	push   %esi
  801e36:	ff 75 dc             	pushl  -0x24(%ebp)
  801e39:	e8 a9 ee ff ff       	call   800ce7 <sys_page_alloc>
  801e3e:	83 c4 10             	add    $0x10,%esp
  801e41:	85 c0                	test   %eax,%eax
  801e43:	79 d2                	jns    801e17 <map_segment+0xca>
  801e45:	eb 1a                	jmp    801e61 <map_segment+0x114>
				panic("spawn: sys_page_map data: %e", r);
  801e47:	50                   	push   %eax
  801e48:	68 c4 31 80 00       	push   $0x8031c4
  801e4d:	68 3a 01 00 00       	push   $0x13a
  801e52:	68 b8 31 80 00       	push   $0x8031b8
  801e57:	e8 b2 e3 ff ff       	call   80020e <_panic>
	return 0;
  801e5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e64:	5b                   	pop    %ebx
  801e65:	5e                   	pop    %esi
  801e66:	5f                   	pop    %edi
  801e67:	5d                   	pop    %ebp
  801e68:	c3                   	ret    

00801e69 <spawn>:
{
  801e69:	f3 0f 1e fb          	endbr32 
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	57                   	push   %edi
  801e71:	56                   	push   %esi
  801e72:	53                   	push   %ebx
  801e73:	81 ec 74 02 00 00    	sub    $0x274,%esp
	if ((r = open(prog, O_RDONLY)) < 0)
  801e79:	6a 00                	push   $0x0
  801e7b:	ff 75 08             	pushl  0x8(%ebp)
  801e7e:	e8 2f fc ff ff       	call   801ab2 <open>
  801e83:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801e89:	83 c4 10             	add    $0x10,%esp
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	0f 88 0b 02 00 00    	js     80209f <spawn+0x236>
  801e94:	89 c7                	mov    %eax,%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf) ||
  801e96:	83 ec 04             	sub    $0x4,%esp
  801e99:	68 00 02 00 00       	push   $0x200
  801e9e:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801ea4:	50                   	push   %eax
  801ea5:	57                   	push   %edi
  801ea6:	e8 d8 f7 ff ff       	call   801683 <readn>
  801eab:	83 c4 10             	add    $0x10,%esp
  801eae:	3d 00 02 00 00       	cmp    $0x200,%eax
  801eb3:	0f 85 85 00 00 00    	jne    801f3e <spawn+0xd5>
  801eb9:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801ec0:	45 4c 46 
  801ec3:	75 79                	jne    801f3e <spawn+0xd5>
  801ec5:	b8 07 00 00 00       	mov    $0x7,%eax
  801eca:	cd 30                	int    $0x30
  801ecc:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801ed2:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	if ((r = sys_exofork()) < 0)
  801ed8:	89 c3                	mov    %eax,%ebx
  801eda:	85 c0                	test   %eax,%eax
  801edc:	0f 88 b1 01 00 00    	js     802093 <spawn+0x22a>
	child_tf = envs[ENVX(child)].env_tf;
  801ee2:	89 c6                	mov    %eax,%esi
  801ee4:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801eea:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801eed:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801ef3:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801ef9:	b9 11 00 00 00       	mov    $0x11,%ecx
  801efe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801f00:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801f06:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
  801f0c:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  801f12:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f15:	89 d8                	mov    %ebx,%eax
  801f17:	e8 b7 fc ff ff       	call   801bd3 <init_stack>
  801f1c:	85 c0                	test   %eax,%eax
  801f1e:	0f 88 89 01 00 00    	js     8020ad <spawn+0x244>
	ph = (struct Proghdr *) (elf_buf + elf->e_phoff);
  801f24:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801f2a:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f31:	be 00 00 00 00       	mov    $0x0,%esi
  801f36:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801f3c:	eb 3e                	jmp    801f7c <spawn+0x113>
		close(fd);
  801f3e:	83 ec 0c             	sub    $0xc,%esp
  801f41:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801f47:	e8 62 f5 ff ff       	call   8014ae <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801f4c:	83 c4 0c             	add    $0xc,%esp
  801f4f:	68 7f 45 4c 46       	push   $0x464c457f
  801f54:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801f5a:	68 e1 31 80 00       	push   $0x8031e1
  801f5f:	e8 91 e3 ff ff       	call   8002f5 <cprintf>
		return -E_NOT_EXEC;
  801f64:	83 c4 10             	add    $0x10,%esp
  801f67:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  801f6e:	ff ff ff 
  801f71:	e9 29 01 00 00       	jmp    80209f <spawn+0x236>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f76:	83 c6 01             	add    $0x1,%esi
  801f79:	83 c3 20             	add    $0x20,%ebx
  801f7c:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801f83:	39 f0                	cmp    %esi,%eax
  801f85:	7e 62                	jle    801fe9 <spawn+0x180>
		if (ph->p_type != ELF_PROG_LOAD)
  801f87:	83 3b 01             	cmpl   $0x1,(%ebx)
  801f8a:	75 ea                	jne    801f76 <spawn+0x10d>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801f8c:	8b 43 18             	mov    0x18(%ebx),%eax
  801f8f:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801f92:	83 f8 01             	cmp    $0x1,%eax
  801f95:	19 c0                	sbb    %eax,%eax
  801f97:	83 e0 fe             	and    $0xfffffffe,%eax
  801f9a:	83 c0 07             	add    $0x7,%eax
		if ((r = map_segment(child,
  801f9d:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801fa0:	8b 53 08             	mov    0x8(%ebx),%edx
  801fa3:	50                   	push   %eax
  801fa4:	ff 73 04             	pushl  0x4(%ebx)
  801fa7:	ff 73 10             	pushl  0x10(%ebx)
  801faa:	57                   	push   %edi
  801fab:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801fb1:	e8 97 fd ff ff       	call   801d4d <map_segment>
  801fb6:	83 c4 10             	add    $0x10,%esp
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	79 b9                	jns    801f76 <spawn+0x10d>
  801fbd:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801fbf:	83 ec 0c             	sub    $0xc,%esp
  801fc2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801fc8:	e8 a1 ec ff ff       	call   800c6e <sys_env_destroy>
	close(fd);
  801fcd:	83 c4 04             	add    $0x4,%esp
  801fd0:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801fd6:	e8 d3 f4 ff ff       	call   8014ae <close>
	return r;
  801fdb:	83 c4 10             	add    $0x10,%esp
		if ((r = map_segment(child,
  801fde:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return r;
  801fe4:	e9 b6 00 00 00       	jmp    80209f <spawn+0x236>
	close(fd);
  801fe9:	83 ec 0c             	sub    $0xc,%esp
  801fec:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801ff2:	e8 b7 f4 ff ff       	call   8014ae <close>
	if ((r = copy_shared_pages(child)) < 0)
  801ff7:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801ffd:	e8 5d fb ff ff       	call   801b5f <copy_shared_pages>
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	85 c0                	test   %eax,%eax
  802007:	78 4b                	js     802054 <spawn+0x1eb>
	child_tf.tf_eflags |= FL_IOPL_3;  // devious: see user/faultio.c
  802009:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802010:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802013:	83 ec 08             	sub    $0x8,%esp
  802016:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80201c:	50                   	push   %eax
  80201d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802023:	e8 5f ed ff ff       	call   800d87 <sys_env_set_trapframe>
  802028:	83 c4 10             	add    $0x10,%esp
  80202b:	85 c0                	test   %eax,%eax
  80202d:	78 3a                	js     802069 <spawn+0x200>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80202f:	83 ec 08             	sub    $0x8,%esp
  802032:	6a 02                	push   $0x2
  802034:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80203a:	e8 21 ed ff ff       	call   800d60 <sys_env_set_status>
  80203f:	83 c4 10             	add    $0x10,%esp
  802042:	85 c0                	test   %eax,%eax
  802044:	78 38                	js     80207e <spawn+0x215>
	return child;
  802046:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  80204c:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802052:	eb 4b                	jmp    80209f <spawn+0x236>
		panic("copy_shared_pages: %e", r);
  802054:	50                   	push   %eax
  802055:	68 fb 31 80 00       	push   $0x8031fb
  80205a:	68 8c 00 00 00       	push   $0x8c
  80205f:	68 b8 31 80 00       	push   $0x8031b8
  802064:	e8 a5 e1 ff ff       	call   80020e <_panic>
		panic("sys_env_set_trapframe: %e", r);
  802069:	50                   	push   %eax
  80206a:	68 11 32 80 00       	push   $0x803211
  80206f:	68 90 00 00 00       	push   $0x90
  802074:	68 b8 31 80 00       	push   $0x8031b8
  802079:	e8 90 e1 ff ff       	call   80020e <_panic>
		panic("sys_env_set_status: %e", r);
  80207e:	50                   	push   %eax
  80207f:	68 2b 32 80 00       	push   $0x80322b
  802084:	68 93 00 00 00       	push   $0x93
  802089:	68 b8 31 80 00       	push   $0x8031b8
  80208e:	e8 7b e1 ff ff       	call   80020e <_panic>
		return r;
  802093:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802099:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
}
  80209f:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8020a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a8:	5b                   	pop    %ebx
  8020a9:	5e                   	pop    %esi
  8020aa:	5f                   	pop    %edi
  8020ab:	5d                   	pop    %ebp
  8020ac:	c3                   	ret    
		return r;
  8020ad:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8020b3:	eb ea                	jmp    80209f <spawn+0x236>

008020b5 <spawnl>:
{
  8020b5:	f3 0f 1e fb          	endbr32 
  8020b9:	55                   	push   %ebp
  8020ba:	89 e5                	mov    %esp,%ebp
  8020bc:	57                   	push   %edi
  8020bd:	56                   	push   %esi
  8020be:	53                   	push   %ebx
  8020bf:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  8020c2:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc = 0;
  8020c5:	b8 00 00 00 00       	mov    $0x0,%eax
	while (va_arg(vl, void *) != NULL)
  8020ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8020cd:	83 3a 00             	cmpl   $0x0,(%edx)
  8020d0:	74 07                	je     8020d9 <spawnl+0x24>
		argc++;
  8020d2:	83 c0 01             	add    $0x1,%eax
	while (va_arg(vl, void *) != NULL)
  8020d5:	89 ca                	mov    %ecx,%edx
  8020d7:	eb f1                	jmp    8020ca <spawnl+0x15>
	const char *argv[argc + 2];
  8020d9:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  8020e0:	89 d1                	mov    %edx,%ecx
  8020e2:	83 e1 f0             	and    $0xfffffff0,%ecx
  8020e5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  8020eb:	89 e6                	mov    %esp,%esi
  8020ed:	29 d6                	sub    %edx,%esi
  8020ef:	89 f2                	mov    %esi,%edx
  8020f1:	39 d4                	cmp    %edx,%esp
  8020f3:	74 10                	je     802105 <spawnl+0x50>
  8020f5:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  8020fb:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  802102:	00 
  802103:	eb ec                	jmp    8020f1 <spawnl+0x3c>
  802105:	89 ca                	mov    %ecx,%edx
  802107:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  80210d:	29 d4                	sub    %edx,%esp
  80210f:	85 d2                	test   %edx,%edx
  802111:	74 05                	je     802118 <spawnl+0x63>
  802113:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  802118:	8d 74 24 03          	lea    0x3(%esp),%esi
  80211c:	89 f2                	mov    %esi,%edx
  80211e:	c1 ea 02             	shr    $0x2,%edx
  802121:	83 e6 fc             	and    $0xfffffffc,%esi
  802124:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802126:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802129:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc + 1] = NULL;
  802130:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802137:	00 
	va_start(vl, arg0);
  802138:	8d 4d 10             	lea    0x10(%ebp),%ecx
  80213b:	89 c2                	mov    %eax,%edx
	for (i = 0; i < argc; i++)
  80213d:	b8 00 00 00 00       	mov    $0x0,%eax
  802142:	eb 0b                	jmp    80214f <spawnl+0x9a>
		argv[i + 1] = va_arg(vl, const char *);
  802144:	83 c0 01             	add    $0x1,%eax
  802147:	8b 39                	mov    (%ecx),%edi
  802149:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  80214c:	8d 49 04             	lea    0x4(%ecx),%ecx
	for (i = 0; i < argc; i++)
  80214f:	39 d0                	cmp    %edx,%eax
  802151:	75 f1                	jne    802144 <spawnl+0x8f>
	return spawn(prog, argv);
  802153:	83 ec 08             	sub    $0x8,%esp
  802156:	56                   	push   %esi
  802157:	ff 75 08             	pushl  0x8(%ebp)
  80215a:	e8 0a fd ff ff       	call   801e69 <spawn>
}
  80215f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802162:	5b                   	pop    %ebx
  802163:	5e                   	pop    %esi
  802164:	5f                   	pop    %edi
  802165:	5d                   	pop    %ebp
  802166:	c3                   	ret    

00802167 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802167:	f3 0f 1e fb          	endbr32 
  80216b:	55                   	push   %ebp
  80216c:	89 e5                	mov    %esp,%ebp
  80216e:	56                   	push   %esi
  80216f:	53                   	push   %ebx
  802170:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802173:	83 ec 0c             	sub    $0xc,%esp
  802176:	ff 75 08             	pushl  0x8(%ebp)
  802179:	e8 82 f1 ff ff       	call   801300 <fd2data>
  80217e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802180:	83 c4 08             	add    $0x8,%esp
  802183:	68 42 32 80 00       	push   $0x803242
  802188:	53                   	push   %ebx
  802189:	e8 d1 e6 ff ff       	call   80085f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80218e:	8b 46 04             	mov    0x4(%esi),%eax
  802191:	2b 06                	sub    (%esi),%eax
  802193:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802199:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021a0:	00 00 00 
	stat->st_dev = &devpipe;
  8021a3:	c7 83 88 00 00 00 28 	movl   $0x804028,0x88(%ebx)
  8021aa:	40 80 00 
	return 0;
}
  8021ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021b5:	5b                   	pop    %ebx
  8021b6:	5e                   	pop    %esi
  8021b7:	5d                   	pop    %ebp
  8021b8:	c3                   	ret    

008021b9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8021b9:	f3 0f 1e fb          	endbr32 
  8021bd:	55                   	push   %ebp
  8021be:	89 e5                	mov    %esp,%ebp
  8021c0:	53                   	push   %ebx
  8021c1:	83 ec 0c             	sub    $0xc,%esp
  8021c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8021c7:	53                   	push   %ebx
  8021c8:	6a 00                	push   $0x0
  8021ca:	e8 6a eb ff ff       	call   800d39 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021cf:	89 1c 24             	mov    %ebx,(%esp)
  8021d2:	e8 29 f1 ff ff       	call   801300 <fd2data>
  8021d7:	83 c4 08             	add    $0x8,%esp
  8021da:	50                   	push   %eax
  8021db:	6a 00                	push   $0x0
  8021dd:	e8 57 eb ff ff       	call   800d39 <sys_page_unmap>
}
  8021e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021e5:	c9                   	leave  
  8021e6:	c3                   	ret    

008021e7 <_pipeisclosed>:
{
  8021e7:	55                   	push   %ebp
  8021e8:	89 e5                	mov    %esp,%ebp
  8021ea:	57                   	push   %edi
  8021eb:	56                   	push   %esi
  8021ec:	53                   	push   %ebx
  8021ed:	83 ec 1c             	sub    $0x1c,%esp
  8021f0:	89 c7                	mov    %eax,%edi
  8021f2:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8021f4:	a1 04 50 80 00       	mov    0x805004,%eax
  8021f9:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8021fc:	83 ec 0c             	sub    $0xc,%esp
  8021ff:	57                   	push   %edi
  802200:	e8 46 06 00 00       	call   80284b <pageref>
  802205:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802208:	89 34 24             	mov    %esi,(%esp)
  80220b:	e8 3b 06 00 00       	call   80284b <pageref>
		nn = thisenv->env_runs;
  802210:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802216:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802219:	83 c4 10             	add    $0x10,%esp
  80221c:	39 cb                	cmp    %ecx,%ebx
  80221e:	74 1b                	je     80223b <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802220:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802223:	75 cf                	jne    8021f4 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802225:	8b 42 58             	mov    0x58(%edx),%eax
  802228:	6a 01                	push   $0x1
  80222a:	50                   	push   %eax
  80222b:	53                   	push   %ebx
  80222c:	68 49 32 80 00       	push   $0x803249
  802231:	e8 bf e0 ff ff       	call   8002f5 <cprintf>
  802236:	83 c4 10             	add    $0x10,%esp
  802239:	eb b9                	jmp    8021f4 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80223b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80223e:	0f 94 c0             	sete   %al
  802241:	0f b6 c0             	movzbl %al,%eax
}
  802244:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802247:	5b                   	pop    %ebx
  802248:	5e                   	pop    %esi
  802249:	5f                   	pop    %edi
  80224a:	5d                   	pop    %ebp
  80224b:	c3                   	ret    

0080224c <devpipe_write>:
{
  80224c:	f3 0f 1e fb          	endbr32 
  802250:	55                   	push   %ebp
  802251:	89 e5                	mov    %esp,%ebp
  802253:	57                   	push   %edi
  802254:	56                   	push   %esi
  802255:	53                   	push   %ebx
  802256:	83 ec 28             	sub    $0x28,%esp
  802259:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80225c:	56                   	push   %esi
  80225d:	e8 9e f0 ff ff       	call   801300 <fd2data>
  802262:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802264:	83 c4 10             	add    $0x10,%esp
  802267:	bf 00 00 00 00       	mov    $0x0,%edi
  80226c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80226f:	74 4f                	je     8022c0 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802271:	8b 43 04             	mov    0x4(%ebx),%eax
  802274:	8b 0b                	mov    (%ebx),%ecx
  802276:	8d 51 20             	lea    0x20(%ecx),%edx
  802279:	39 d0                	cmp    %edx,%eax
  80227b:	72 14                	jb     802291 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  80227d:	89 da                	mov    %ebx,%edx
  80227f:	89 f0                	mov    %esi,%eax
  802281:	e8 61 ff ff ff       	call   8021e7 <_pipeisclosed>
  802286:	85 c0                	test   %eax,%eax
  802288:	75 3b                	jne    8022c5 <devpipe_write+0x79>
			sys_yield();
  80228a:	e8 2d ea ff ff       	call   800cbc <sys_yield>
  80228f:	eb e0                	jmp    802271 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802291:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802294:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802298:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80229b:	89 c2                	mov    %eax,%edx
  80229d:	c1 fa 1f             	sar    $0x1f,%edx
  8022a0:	89 d1                	mov    %edx,%ecx
  8022a2:	c1 e9 1b             	shr    $0x1b,%ecx
  8022a5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8022a8:	83 e2 1f             	and    $0x1f,%edx
  8022ab:	29 ca                	sub    %ecx,%edx
  8022ad:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8022b1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8022b5:	83 c0 01             	add    $0x1,%eax
  8022b8:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8022bb:	83 c7 01             	add    $0x1,%edi
  8022be:	eb ac                	jmp    80226c <devpipe_write+0x20>
	return i;
  8022c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8022c3:	eb 05                	jmp    8022ca <devpipe_write+0x7e>
				return 0;
  8022c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5f                   	pop    %edi
  8022d0:	5d                   	pop    %ebp
  8022d1:	c3                   	ret    

008022d2 <devpipe_read>:
{
  8022d2:	f3 0f 1e fb          	endbr32 
  8022d6:	55                   	push   %ebp
  8022d7:	89 e5                	mov    %esp,%ebp
  8022d9:	57                   	push   %edi
  8022da:	56                   	push   %esi
  8022db:	53                   	push   %ebx
  8022dc:	83 ec 18             	sub    $0x18,%esp
  8022df:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8022e2:	57                   	push   %edi
  8022e3:	e8 18 f0 ff ff       	call   801300 <fd2data>
  8022e8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8022ea:	83 c4 10             	add    $0x10,%esp
  8022ed:	be 00 00 00 00       	mov    $0x0,%esi
  8022f2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022f5:	75 14                	jne    80230b <devpipe_read+0x39>
	return i;
  8022f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8022fa:	eb 02                	jmp    8022fe <devpipe_read+0x2c>
				return i;
  8022fc:	89 f0                	mov    %esi,%eax
}
  8022fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802301:	5b                   	pop    %ebx
  802302:	5e                   	pop    %esi
  802303:	5f                   	pop    %edi
  802304:	5d                   	pop    %ebp
  802305:	c3                   	ret    
			sys_yield();
  802306:	e8 b1 e9 ff ff       	call   800cbc <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80230b:	8b 03                	mov    (%ebx),%eax
  80230d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802310:	75 18                	jne    80232a <devpipe_read+0x58>
			if (i > 0)
  802312:	85 f6                	test   %esi,%esi
  802314:	75 e6                	jne    8022fc <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802316:	89 da                	mov    %ebx,%edx
  802318:	89 f8                	mov    %edi,%eax
  80231a:	e8 c8 fe ff ff       	call   8021e7 <_pipeisclosed>
  80231f:	85 c0                	test   %eax,%eax
  802321:	74 e3                	je     802306 <devpipe_read+0x34>
				return 0;
  802323:	b8 00 00 00 00       	mov    $0x0,%eax
  802328:	eb d4                	jmp    8022fe <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80232a:	99                   	cltd   
  80232b:	c1 ea 1b             	shr    $0x1b,%edx
  80232e:	01 d0                	add    %edx,%eax
  802330:	83 e0 1f             	and    $0x1f,%eax
  802333:	29 d0                	sub    %edx,%eax
  802335:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80233a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80233d:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802340:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802343:	83 c6 01             	add    $0x1,%esi
  802346:	eb aa                	jmp    8022f2 <devpipe_read+0x20>

00802348 <pipe>:
{
  802348:	f3 0f 1e fb          	endbr32 
  80234c:	55                   	push   %ebp
  80234d:	89 e5                	mov    %esp,%ebp
  80234f:	56                   	push   %esi
  802350:	53                   	push   %ebx
  802351:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802354:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802357:	50                   	push   %eax
  802358:	e8 c2 ef ff ff       	call   80131f <fd_alloc>
  80235d:	89 c3                	mov    %eax,%ebx
  80235f:	83 c4 10             	add    $0x10,%esp
  802362:	85 c0                	test   %eax,%eax
  802364:	0f 88 23 01 00 00    	js     80248d <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80236a:	83 ec 04             	sub    $0x4,%esp
  80236d:	68 07 04 00 00       	push   $0x407
  802372:	ff 75 f4             	pushl  -0xc(%ebp)
  802375:	6a 00                	push   $0x0
  802377:	e8 6b e9 ff ff       	call   800ce7 <sys_page_alloc>
  80237c:	89 c3                	mov    %eax,%ebx
  80237e:	83 c4 10             	add    $0x10,%esp
  802381:	85 c0                	test   %eax,%eax
  802383:	0f 88 04 01 00 00    	js     80248d <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  802389:	83 ec 0c             	sub    $0xc,%esp
  80238c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80238f:	50                   	push   %eax
  802390:	e8 8a ef ff ff       	call   80131f <fd_alloc>
  802395:	89 c3                	mov    %eax,%ebx
  802397:	83 c4 10             	add    $0x10,%esp
  80239a:	85 c0                	test   %eax,%eax
  80239c:	0f 88 db 00 00 00    	js     80247d <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023a2:	83 ec 04             	sub    $0x4,%esp
  8023a5:	68 07 04 00 00       	push   $0x407
  8023aa:	ff 75 f0             	pushl  -0x10(%ebp)
  8023ad:	6a 00                	push   $0x0
  8023af:	e8 33 e9 ff ff       	call   800ce7 <sys_page_alloc>
  8023b4:	89 c3                	mov    %eax,%ebx
  8023b6:	83 c4 10             	add    $0x10,%esp
  8023b9:	85 c0                	test   %eax,%eax
  8023bb:	0f 88 bc 00 00 00    	js     80247d <pipe+0x135>
	va = fd2data(fd0);
  8023c1:	83 ec 0c             	sub    $0xc,%esp
  8023c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8023c7:	e8 34 ef ff ff       	call   801300 <fd2data>
  8023cc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023ce:	83 c4 0c             	add    $0xc,%esp
  8023d1:	68 07 04 00 00       	push   $0x407
  8023d6:	50                   	push   %eax
  8023d7:	6a 00                	push   $0x0
  8023d9:	e8 09 e9 ff ff       	call   800ce7 <sys_page_alloc>
  8023de:	89 c3                	mov    %eax,%ebx
  8023e0:	83 c4 10             	add    $0x10,%esp
  8023e3:	85 c0                	test   %eax,%eax
  8023e5:	0f 88 82 00 00 00    	js     80246d <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023eb:	83 ec 0c             	sub    $0xc,%esp
  8023ee:	ff 75 f0             	pushl  -0x10(%ebp)
  8023f1:	e8 0a ef ff ff       	call   801300 <fd2data>
  8023f6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8023fd:	50                   	push   %eax
  8023fe:	6a 00                	push   $0x0
  802400:	56                   	push   %esi
  802401:	6a 00                	push   $0x0
  802403:	e8 07 e9 ff ff       	call   800d0f <sys_page_map>
  802408:	89 c3                	mov    %eax,%ebx
  80240a:	83 c4 20             	add    $0x20,%esp
  80240d:	85 c0                	test   %eax,%eax
  80240f:	78 4e                	js     80245f <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  802411:	a1 28 40 80 00       	mov    0x804028,%eax
  802416:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802419:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80241b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80241e:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802425:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802428:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80242a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80242d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802434:	83 ec 0c             	sub    $0xc,%esp
  802437:	ff 75 f4             	pushl  -0xc(%ebp)
  80243a:	e8 ad ee ff ff       	call   8012ec <fd2num>
  80243f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802442:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802444:	83 c4 04             	add    $0x4,%esp
  802447:	ff 75 f0             	pushl  -0x10(%ebp)
  80244a:	e8 9d ee ff ff       	call   8012ec <fd2num>
  80244f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802452:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802455:	83 c4 10             	add    $0x10,%esp
  802458:	bb 00 00 00 00       	mov    $0x0,%ebx
  80245d:	eb 2e                	jmp    80248d <pipe+0x145>
	sys_page_unmap(0, va);
  80245f:	83 ec 08             	sub    $0x8,%esp
  802462:	56                   	push   %esi
  802463:	6a 00                	push   $0x0
  802465:	e8 cf e8 ff ff       	call   800d39 <sys_page_unmap>
  80246a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80246d:	83 ec 08             	sub    $0x8,%esp
  802470:	ff 75 f0             	pushl  -0x10(%ebp)
  802473:	6a 00                	push   $0x0
  802475:	e8 bf e8 ff ff       	call   800d39 <sys_page_unmap>
  80247a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80247d:	83 ec 08             	sub    $0x8,%esp
  802480:	ff 75 f4             	pushl  -0xc(%ebp)
  802483:	6a 00                	push   $0x0
  802485:	e8 af e8 ff ff       	call   800d39 <sys_page_unmap>
  80248a:	83 c4 10             	add    $0x10,%esp
}
  80248d:	89 d8                	mov    %ebx,%eax
  80248f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802492:	5b                   	pop    %ebx
  802493:	5e                   	pop    %esi
  802494:	5d                   	pop    %ebp
  802495:	c3                   	ret    

00802496 <pipeisclosed>:
{
  802496:	f3 0f 1e fb          	endbr32 
  80249a:	55                   	push   %ebp
  80249b:	89 e5                	mov    %esp,%ebp
  80249d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024a3:	50                   	push   %eax
  8024a4:	ff 75 08             	pushl  0x8(%ebp)
  8024a7:	e8 c9 ee ff ff       	call   801375 <fd_lookup>
  8024ac:	83 c4 10             	add    $0x10,%esp
  8024af:	85 c0                	test   %eax,%eax
  8024b1:	78 18                	js     8024cb <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  8024b3:	83 ec 0c             	sub    $0xc,%esp
  8024b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8024b9:	e8 42 ee ff ff       	call   801300 <fd2data>
  8024be:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8024c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c3:	e8 1f fd ff ff       	call   8021e7 <_pipeisclosed>
  8024c8:	83 c4 10             	add    $0x10,%esp
}
  8024cb:	c9                   	leave  
  8024cc:	c3                   	ret    

008024cd <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8024cd:	f3 0f 1e fb          	endbr32 
  8024d1:	55                   	push   %ebp
  8024d2:	89 e5                	mov    %esp,%ebp
  8024d4:	56                   	push   %esi
  8024d5:	53                   	push   %ebx
  8024d6:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8024d9:	85 f6                	test   %esi,%esi
  8024db:	74 13                	je     8024f0 <wait+0x23>
	e = &envs[ENVX(envid)];
  8024dd:	89 f3                	mov    %esi,%ebx
  8024df:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8024e5:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8024e8:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8024ee:	eb 1b                	jmp    80250b <wait+0x3e>
	assert(envid != 0);
  8024f0:	68 61 32 80 00       	push   $0x803261
  8024f5:	68 63 31 80 00       	push   $0x803163
  8024fa:	6a 09                	push   $0x9
  8024fc:	68 6c 32 80 00       	push   $0x80326c
  802501:	e8 08 dd ff ff       	call   80020e <_panic>
		sys_yield();
  802506:	e8 b1 e7 ff ff       	call   800cbc <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80250b:	8b 43 48             	mov    0x48(%ebx),%eax
  80250e:	39 f0                	cmp    %esi,%eax
  802510:	75 07                	jne    802519 <wait+0x4c>
  802512:	8b 43 54             	mov    0x54(%ebx),%eax
  802515:	85 c0                	test   %eax,%eax
  802517:	75 ed                	jne    802506 <wait+0x39>
}
  802519:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80251c:	5b                   	pop    %ebx
  80251d:	5e                   	pop    %esi
  80251e:	5d                   	pop    %ebp
  80251f:	c3                   	ret    

00802520 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802520:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  802524:	b8 00 00 00 00       	mov    $0x0,%eax
  802529:	c3                   	ret    

0080252a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80252a:	f3 0f 1e fb          	endbr32 
  80252e:	55                   	push   %ebp
  80252f:	89 e5                	mov    %esp,%ebp
  802531:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802534:	68 77 32 80 00       	push   $0x803277
  802539:	ff 75 0c             	pushl  0xc(%ebp)
  80253c:	e8 1e e3 ff ff       	call   80085f <strcpy>
	return 0;
}
  802541:	b8 00 00 00 00       	mov    $0x0,%eax
  802546:	c9                   	leave  
  802547:	c3                   	ret    

00802548 <devcons_write>:
{
  802548:	f3 0f 1e fb          	endbr32 
  80254c:	55                   	push   %ebp
  80254d:	89 e5                	mov    %esp,%ebp
  80254f:	57                   	push   %edi
  802550:	56                   	push   %esi
  802551:	53                   	push   %ebx
  802552:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802558:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80255d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802563:	3b 75 10             	cmp    0x10(%ebp),%esi
  802566:	73 31                	jae    802599 <devcons_write+0x51>
		m = n - tot;
  802568:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80256b:	29 f3                	sub    %esi,%ebx
  80256d:	83 fb 7f             	cmp    $0x7f,%ebx
  802570:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802575:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802578:	83 ec 04             	sub    $0x4,%esp
  80257b:	53                   	push   %ebx
  80257c:	89 f0                	mov    %esi,%eax
  80257e:	03 45 0c             	add    0xc(%ebp),%eax
  802581:	50                   	push   %eax
  802582:	57                   	push   %edi
  802583:	e8 8f e4 ff ff       	call   800a17 <memmove>
		sys_cputs(buf, m);
  802588:	83 c4 08             	add    $0x8,%esp
  80258b:	53                   	push   %ebx
  80258c:	57                   	push   %edi
  80258d:	e8 8a e6 ff ff       	call   800c1c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802592:	01 de                	add    %ebx,%esi
  802594:	83 c4 10             	add    $0x10,%esp
  802597:	eb ca                	jmp    802563 <devcons_write+0x1b>
}
  802599:	89 f0                	mov    %esi,%eax
  80259b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80259e:	5b                   	pop    %ebx
  80259f:	5e                   	pop    %esi
  8025a0:	5f                   	pop    %edi
  8025a1:	5d                   	pop    %ebp
  8025a2:	c3                   	ret    

008025a3 <devcons_read>:
{
  8025a3:	f3 0f 1e fb          	endbr32 
  8025a7:	55                   	push   %ebp
  8025a8:	89 e5                	mov    %esp,%ebp
  8025aa:	83 ec 08             	sub    $0x8,%esp
  8025ad:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8025b2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8025b6:	74 21                	je     8025d9 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8025b8:	e8 89 e6 ff ff       	call   800c46 <sys_cgetc>
  8025bd:	85 c0                	test   %eax,%eax
  8025bf:	75 07                	jne    8025c8 <devcons_read+0x25>
		sys_yield();
  8025c1:	e8 f6 e6 ff ff       	call   800cbc <sys_yield>
  8025c6:	eb f0                	jmp    8025b8 <devcons_read+0x15>
	if (c < 0)
  8025c8:	78 0f                	js     8025d9 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8025ca:	83 f8 04             	cmp    $0x4,%eax
  8025cd:	74 0c                	je     8025db <devcons_read+0x38>
	*(char*)vbuf = c;
  8025cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025d2:	88 02                	mov    %al,(%edx)
	return 1;
  8025d4:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8025d9:	c9                   	leave  
  8025da:	c3                   	ret    
		return 0;
  8025db:	b8 00 00 00 00       	mov    $0x0,%eax
  8025e0:	eb f7                	jmp    8025d9 <devcons_read+0x36>

008025e2 <cputchar>:
{
  8025e2:	f3 0f 1e fb          	endbr32 
  8025e6:	55                   	push   %ebp
  8025e7:	89 e5                	mov    %esp,%ebp
  8025e9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8025ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ef:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8025f2:	6a 01                	push   $0x1
  8025f4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025f7:	50                   	push   %eax
  8025f8:	e8 1f e6 ff ff       	call   800c1c <sys_cputs>
}
  8025fd:	83 c4 10             	add    $0x10,%esp
  802600:	c9                   	leave  
  802601:	c3                   	ret    

00802602 <getchar>:
{
  802602:	f3 0f 1e fb          	endbr32 
  802606:	55                   	push   %ebp
  802607:	89 e5                	mov    %esp,%ebp
  802609:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80260c:	6a 01                	push   $0x1
  80260e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802611:	50                   	push   %eax
  802612:	6a 00                	push   $0x0
  802614:	e8 df ef ff ff       	call   8015f8 <read>
	if (r < 0)
  802619:	83 c4 10             	add    $0x10,%esp
  80261c:	85 c0                	test   %eax,%eax
  80261e:	78 06                	js     802626 <getchar+0x24>
	if (r < 1)
  802620:	74 06                	je     802628 <getchar+0x26>
	return c;
  802622:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802626:	c9                   	leave  
  802627:	c3                   	ret    
		return -E_EOF;
  802628:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80262d:	eb f7                	jmp    802626 <getchar+0x24>

0080262f <iscons>:
{
  80262f:	f3 0f 1e fb          	endbr32 
  802633:	55                   	push   %ebp
  802634:	89 e5                	mov    %esp,%ebp
  802636:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802639:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80263c:	50                   	push   %eax
  80263d:	ff 75 08             	pushl  0x8(%ebp)
  802640:	e8 30 ed ff ff       	call   801375 <fd_lookup>
  802645:	83 c4 10             	add    $0x10,%esp
  802648:	85 c0                	test   %eax,%eax
  80264a:	78 11                	js     80265d <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80264c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80264f:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802655:	39 10                	cmp    %edx,(%eax)
  802657:	0f 94 c0             	sete   %al
  80265a:	0f b6 c0             	movzbl %al,%eax
}
  80265d:	c9                   	leave  
  80265e:	c3                   	ret    

0080265f <opencons>:
{
  80265f:	f3 0f 1e fb          	endbr32 
  802663:	55                   	push   %ebp
  802664:	89 e5                	mov    %esp,%ebp
  802666:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802669:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80266c:	50                   	push   %eax
  80266d:	e8 ad ec ff ff       	call   80131f <fd_alloc>
  802672:	83 c4 10             	add    $0x10,%esp
  802675:	85 c0                	test   %eax,%eax
  802677:	78 3a                	js     8026b3 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802679:	83 ec 04             	sub    $0x4,%esp
  80267c:	68 07 04 00 00       	push   $0x407
  802681:	ff 75 f4             	pushl  -0xc(%ebp)
  802684:	6a 00                	push   $0x0
  802686:	e8 5c e6 ff ff       	call   800ce7 <sys_page_alloc>
  80268b:	83 c4 10             	add    $0x10,%esp
  80268e:	85 c0                	test   %eax,%eax
  802690:	78 21                	js     8026b3 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  802692:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802695:	8b 15 44 40 80 00    	mov    0x804044,%edx
  80269b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80269d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026a0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8026a7:	83 ec 0c             	sub    $0xc,%esp
  8026aa:	50                   	push   %eax
  8026ab:	e8 3c ec ff ff       	call   8012ec <fd2num>
  8026b0:	83 c4 10             	add    $0x10,%esp
}
  8026b3:	c9                   	leave  
  8026b4:	c3                   	ret    

008026b5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8026b5:	f3 0f 1e fb          	endbr32 
  8026b9:	55                   	push   %ebp
  8026ba:	89 e5                	mov    %esp,%ebp
  8026bc:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  8026bf:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8026c6:	74 0a                	je     8026d2 <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8026c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8026cb:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8026d0:	c9                   	leave  
  8026d1:	c3                   	ret    
		if (sys_page_alloc(0,
  8026d2:	83 ec 04             	sub    $0x4,%esp
  8026d5:	6a 07                	push   $0x7
  8026d7:	68 00 f0 bf ee       	push   $0xeebff000
  8026dc:	6a 00                	push   $0x0
  8026de:	e8 04 e6 ff ff       	call   800ce7 <sys_page_alloc>
  8026e3:	83 c4 10             	add    $0x10,%esp
  8026e6:	85 c0                	test   %eax,%eax
  8026e8:	78 2a                	js     802714 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  8026ea:	83 ec 08             	sub    $0x8,%esp
  8026ed:	68 28 27 80 00       	push   $0x802728
  8026f2:	6a 00                	push   $0x0
  8026f4:	e8 b5 e6 ff ff       	call   800dae <sys_env_set_pgfault_upcall>
  8026f9:	83 c4 10             	add    $0x10,%esp
  8026fc:	85 c0                	test   %eax,%eax
  8026fe:	79 c8                	jns    8026c8 <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  802700:	83 ec 04             	sub    $0x4,%esp
  802703:	68 b8 32 80 00       	push   $0x8032b8
  802708:	6a 25                	push   $0x25
  80270a:	68 ff 32 80 00       	push   $0x8032ff
  80270f:	e8 fa da ff ff       	call   80020e <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  802714:	83 ec 04             	sub    $0x4,%esp
  802717:	68 84 32 80 00       	push   $0x803284
  80271c:	6a 21                	push   $0x21
  80271e:	68 ff 32 80 00       	push   $0x8032ff
  802723:	e8 e6 da ff ff       	call   80020e <_panic>

00802728 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802728:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802729:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80272e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802730:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  802733:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  802738:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  80273c:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802740:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  802742:	83 c4 08             	add    $0x8,%esp
	popal
  802745:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  802746:	83 c4 04             	add    $0x4,%esp
	popfl
  802749:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  80274a:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80274d:	c3                   	ret    

0080274e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80274e:	f3 0f 1e fb          	endbr32 
  802752:	55                   	push   %ebp
  802753:	89 e5                	mov    %esp,%ebp
  802755:	56                   	push   %esi
  802756:	53                   	push   %ebx
  802757:	8b 75 08             	mov    0x8(%ebp),%esi
  80275a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80275d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  802760:	85 c0                	test   %eax,%eax
  802762:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802767:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  80276a:	83 ec 0c             	sub    $0xc,%esp
  80276d:	50                   	push   %eax
  80276e:	e8 8b e6 ff ff       	call   800dfe <sys_ipc_recv>
	if (f < 0) {
  802773:	83 c4 10             	add    $0x10,%esp
  802776:	85 c0                	test   %eax,%eax
  802778:	78 2b                	js     8027a5 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  80277a:	85 f6                	test   %esi,%esi
  80277c:	74 0a                	je     802788 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  80277e:	a1 04 50 80 00       	mov    0x805004,%eax
  802783:	8b 40 74             	mov    0x74(%eax),%eax
  802786:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  802788:	85 db                	test   %ebx,%ebx
  80278a:	74 0a                	je     802796 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  80278c:	a1 04 50 80 00       	mov    0x805004,%eax
  802791:	8b 40 78             	mov    0x78(%eax),%eax
  802794:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  802796:	a1 04 50 80 00       	mov    0x805004,%eax
  80279b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80279e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8027a1:	5b                   	pop    %ebx
  8027a2:	5e                   	pop    %esi
  8027a3:	5d                   	pop    %ebp
  8027a4:	c3                   	ret    
		if (from_env_store != NULL) {
  8027a5:	85 f6                	test   %esi,%esi
  8027a7:	74 06                	je     8027af <ipc_recv+0x61>
			*from_env_store = 0;
  8027a9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  8027af:	85 db                	test   %ebx,%ebx
  8027b1:	74 eb                	je     80279e <ipc_recv+0x50>
			*perm_store = 0;
  8027b3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8027b9:	eb e3                	jmp    80279e <ipc_recv+0x50>

008027bb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8027bb:	f3 0f 1e fb          	endbr32 
  8027bf:	55                   	push   %ebp
  8027c0:	89 e5                	mov    %esp,%ebp
  8027c2:	57                   	push   %edi
  8027c3:	56                   	push   %esi
  8027c4:	53                   	push   %ebx
  8027c5:	83 ec 0c             	sub    $0xc,%esp
  8027c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8027cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8027ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  8027d1:	85 db                	test   %ebx,%ebx
  8027d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8027d8:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8027db:	ff 75 14             	pushl  0x14(%ebp)
  8027de:	53                   	push   %ebx
  8027df:	56                   	push   %esi
  8027e0:	57                   	push   %edi
  8027e1:	e8 ef e5 ff ff       	call   800dd5 <sys_ipc_try_send>
  8027e6:	83 c4 10             	add    $0x10,%esp
  8027e9:	85 c0                	test   %eax,%eax
  8027eb:	79 19                	jns    802806 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  8027ed:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8027f0:	74 e9                	je     8027db <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  8027f2:	83 ec 04             	sub    $0x4,%esp
  8027f5:	68 10 33 80 00       	push   $0x803310
  8027fa:	6a 48                	push   $0x48
  8027fc:	68 32 33 80 00       	push   $0x803332
  802801:	e8 08 da ff ff       	call   80020e <_panic>
		}
	}
}
  802806:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802809:	5b                   	pop    %ebx
  80280a:	5e                   	pop    %esi
  80280b:	5f                   	pop    %edi
  80280c:	5d                   	pop    %ebp
  80280d:	c3                   	ret    

0080280e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80280e:	f3 0f 1e fb          	endbr32 
  802812:	55                   	push   %ebp
  802813:	89 e5                	mov    %esp,%ebp
  802815:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802818:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80281d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802820:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802826:	8b 52 50             	mov    0x50(%edx),%edx
  802829:	39 ca                	cmp    %ecx,%edx
  80282b:	74 11                	je     80283e <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80282d:	83 c0 01             	add    $0x1,%eax
  802830:	3d 00 04 00 00       	cmp    $0x400,%eax
  802835:	75 e6                	jne    80281d <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802837:	b8 00 00 00 00       	mov    $0x0,%eax
  80283c:	eb 0b                	jmp    802849 <ipc_find_env+0x3b>
			return envs[i].env_id;
  80283e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802841:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802846:	8b 40 48             	mov    0x48(%eax),%eax
}
  802849:	5d                   	pop    %ebp
  80284a:	c3                   	ret    

0080284b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80284b:	f3 0f 1e fb          	endbr32 
  80284f:	55                   	push   %ebp
  802850:	89 e5                	mov    %esp,%ebp
  802852:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802855:	89 c2                	mov    %eax,%edx
  802857:	c1 ea 16             	shr    $0x16,%edx
  80285a:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802861:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802866:	f6 c1 01             	test   $0x1,%cl
  802869:	74 1c                	je     802887 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80286b:	c1 e8 0c             	shr    $0xc,%eax
  80286e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802875:	a8 01                	test   $0x1,%al
  802877:	74 0e                	je     802887 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802879:	c1 e8 0c             	shr    $0xc,%eax
  80287c:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802883:	ef 
  802884:	0f b7 d2             	movzwl %dx,%edx
}
  802887:	89 d0                	mov    %edx,%eax
  802889:	5d                   	pop    %ebp
  80288a:	c3                   	ret    
  80288b:	66 90                	xchg   %ax,%ax
  80288d:	66 90                	xchg   %ax,%ax
  80288f:	90                   	nop

00802890 <__udivdi3>:
  802890:	f3 0f 1e fb          	endbr32 
  802894:	55                   	push   %ebp
  802895:	57                   	push   %edi
  802896:	56                   	push   %esi
  802897:	53                   	push   %ebx
  802898:	83 ec 1c             	sub    $0x1c,%esp
  80289b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80289f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8028a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8028a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8028ab:	85 d2                	test   %edx,%edx
  8028ad:	75 19                	jne    8028c8 <__udivdi3+0x38>
  8028af:	39 f3                	cmp    %esi,%ebx
  8028b1:	76 4d                	jbe    802900 <__udivdi3+0x70>
  8028b3:	31 ff                	xor    %edi,%edi
  8028b5:	89 e8                	mov    %ebp,%eax
  8028b7:	89 f2                	mov    %esi,%edx
  8028b9:	f7 f3                	div    %ebx
  8028bb:	89 fa                	mov    %edi,%edx
  8028bd:	83 c4 1c             	add    $0x1c,%esp
  8028c0:	5b                   	pop    %ebx
  8028c1:	5e                   	pop    %esi
  8028c2:	5f                   	pop    %edi
  8028c3:	5d                   	pop    %ebp
  8028c4:	c3                   	ret    
  8028c5:	8d 76 00             	lea    0x0(%esi),%esi
  8028c8:	39 f2                	cmp    %esi,%edx
  8028ca:	76 14                	jbe    8028e0 <__udivdi3+0x50>
  8028cc:	31 ff                	xor    %edi,%edi
  8028ce:	31 c0                	xor    %eax,%eax
  8028d0:	89 fa                	mov    %edi,%edx
  8028d2:	83 c4 1c             	add    $0x1c,%esp
  8028d5:	5b                   	pop    %ebx
  8028d6:	5e                   	pop    %esi
  8028d7:	5f                   	pop    %edi
  8028d8:	5d                   	pop    %ebp
  8028d9:	c3                   	ret    
  8028da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028e0:	0f bd fa             	bsr    %edx,%edi
  8028e3:	83 f7 1f             	xor    $0x1f,%edi
  8028e6:	75 48                	jne    802930 <__udivdi3+0xa0>
  8028e8:	39 f2                	cmp    %esi,%edx
  8028ea:	72 06                	jb     8028f2 <__udivdi3+0x62>
  8028ec:	31 c0                	xor    %eax,%eax
  8028ee:	39 eb                	cmp    %ebp,%ebx
  8028f0:	77 de                	ja     8028d0 <__udivdi3+0x40>
  8028f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8028f7:	eb d7                	jmp    8028d0 <__udivdi3+0x40>
  8028f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802900:	89 d9                	mov    %ebx,%ecx
  802902:	85 db                	test   %ebx,%ebx
  802904:	75 0b                	jne    802911 <__udivdi3+0x81>
  802906:	b8 01 00 00 00       	mov    $0x1,%eax
  80290b:	31 d2                	xor    %edx,%edx
  80290d:	f7 f3                	div    %ebx
  80290f:	89 c1                	mov    %eax,%ecx
  802911:	31 d2                	xor    %edx,%edx
  802913:	89 f0                	mov    %esi,%eax
  802915:	f7 f1                	div    %ecx
  802917:	89 c6                	mov    %eax,%esi
  802919:	89 e8                	mov    %ebp,%eax
  80291b:	89 f7                	mov    %esi,%edi
  80291d:	f7 f1                	div    %ecx
  80291f:	89 fa                	mov    %edi,%edx
  802921:	83 c4 1c             	add    $0x1c,%esp
  802924:	5b                   	pop    %ebx
  802925:	5e                   	pop    %esi
  802926:	5f                   	pop    %edi
  802927:	5d                   	pop    %ebp
  802928:	c3                   	ret    
  802929:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802930:	89 f9                	mov    %edi,%ecx
  802932:	b8 20 00 00 00       	mov    $0x20,%eax
  802937:	29 f8                	sub    %edi,%eax
  802939:	d3 e2                	shl    %cl,%edx
  80293b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80293f:	89 c1                	mov    %eax,%ecx
  802941:	89 da                	mov    %ebx,%edx
  802943:	d3 ea                	shr    %cl,%edx
  802945:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802949:	09 d1                	or     %edx,%ecx
  80294b:	89 f2                	mov    %esi,%edx
  80294d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802951:	89 f9                	mov    %edi,%ecx
  802953:	d3 e3                	shl    %cl,%ebx
  802955:	89 c1                	mov    %eax,%ecx
  802957:	d3 ea                	shr    %cl,%edx
  802959:	89 f9                	mov    %edi,%ecx
  80295b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80295f:	89 eb                	mov    %ebp,%ebx
  802961:	d3 e6                	shl    %cl,%esi
  802963:	89 c1                	mov    %eax,%ecx
  802965:	d3 eb                	shr    %cl,%ebx
  802967:	09 de                	or     %ebx,%esi
  802969:	89 f0                	mov    %esi,%eax
  80296b:	f7 74 24 08          	divl   0x8(%esp)
  80296f:	89 d6                	mov    %edx,%esi
  802971:	89 c3                	mov    %eax,%ebx
  802973:	f7 64 24 0c          	mull   0xc(%esp)
  802977:	39 d6                	cmp    %edx,%esi
  802979:	72 15                	jb     802990 <__udivdi3+0x100>
  80297b:	89 f9                	mov    %edi,%ecx
  80297d:	d3 e5                	shl    %cl,%ebp
  80297f:	39 c5                	cmp    %eax,%ebp
  802981:	73 04                	jae    802987 <__udivdi3+0xf7>
  802983:	39 d6                	cmp    %edx,%esi
  802985:	74 09                	je     802990 <__udivdi3+0x100>
  802987:	89 d8                	mov    %ebx,%eax
  802989:	31 ff                	xor    %edi,%edi
  80298b:	e9 40 ff ff ff       	jmp    8028d0 <__udivdi3+0x40>
  802990:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802993:	31 ff                	xor    %edi,%edi
  802995:	e9 36 ff ff ff       	jmp    8028d0 <__udivdi3+0x40>
  80299a:	66 90                	xchg   %ax,%ax
  80299c:	66 90                	xchg   %ax,%ax
  80299e:	66 90                	xchg   %ax,%ax

008029a0 <__umoddi3>:
  8029a0:	f3 0f 1e fb          	endbr32 
  8029a4:	55                   	push   %ebp
  8029a5:	57                   	push   %edi
  8029a6:	56                   	push   %esi
  8029a7:	53                   	push   %ebx
  8029a8:	83 ec 1c             	sub    $0x1c,%esp
  8029ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8029af:	8b 74 24 30          	mov    0x30(%esp),%esi
  8029b3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8029b7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8029bb:	85 c0                	test   %eax,%eax
  8029bd:	75 19                	jne    8029d8 <__umoddi3+0x38>
  8029bf:	39 df                	cmp    %ebx,%edi
  8029c1:	76 5d                	jbe    802a20 <__umoddi3+0x80>
  8029c3:	89 f0                	mov    %esi,%eax
  8029c5:	89 da                	mov    %ebx,%edx
  8029c7:	f7 f7                	div    %edi
  8029c9:	89 d0                	mov    %edx,%eax
  8029cb:	31 d2                	xor    %edx,%edx
  8029cd:	83 c4 1c             	add    $0x1c,%esp
  8029d0:	5b                   	pop    %ebx
  8029d1:	5e                   	pop    %esi
  8029d2:	5f                   	pop    %edi
  8029d3:	5d                   	pop    %ebp
  8029d4:	c3                   	ret    
  8029d5:	8d 76 00             	lea    0x0(%esi),%esi
  8029d8:	89 f2                	mov    %esi,%edx
  8029da:	39 d8                	cmp    %ebx,%eax
  8029dc:	76 12                	jbe    8029f0 <__umoddi3+0x50>
  8029de:	89 f0                	mov    %esi,%eax
  8029e0:	89 da                	mov    %ebx,%edx
  8029e2:	83 c4 1c             	add    $0x1c,%esp
  8029e5:	5b                   	pop    %ebx
  8029e6:	5e                   	pop    %esi
  8029e7:	5f                   	pop    %edi
  8029e8:	5d                   	pop    %ebp
  8029e9:	c3                   	ret    
  8029ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8029f0:	0f bd e8             	bsr    %eax,%ebp
  8029f3:	83 f5 1f             	xor    $0x1f,%ebp
  8029f6:	75 50                	jne    802a48 <__umoddi3+0xa8>
  8029f8:	39 d8                	cmp    %ebx,%eax
  8029fa:	0f 82 e0 00 00 00    	jb     802ae0 <__umoddi3+0x140>
  802a00:	89 d9                	mov    %ebx,%ecx
  802a02:	39 f7                	cmp    %esi,%edi
  802a04:	0f 86 d6 00 00 00    	jbe    802ae0 <__umoddi3+0x140>
  802a0a:	89 d0                	mov    %edx,%eax
  802a0c:	89 ca                	mov    %ecx,%edx
  802a0e:	83 c4 1c             	add    $0x1c,%esp
  802a11:	5b                   	pop    %ebx
  802a12:	5e                   	pop    %esi
  802a13:	5f                   	pop    %edi
  802a14:	5d                   	pop    %ebp
  802a15:	c3                   	ret    
  802a16:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a1d:	8d 76 00             	lea    0x0(%esi),%esi
  802a20:	89 fd                	mov    %edi,%ebp
  802a22:	85 ff                	test   %edi,%edi
  802a24:	75 0b                	jne    802a31 <__umoddi3+0x91>
  802a26:	b8 01 00 00 00       	mov    $0x1,%eax
  802a2b:	31 d2                	xor    %edx,%edx
  802a2d:	f7 f7                	div    %edi
  802a2f:	89 c5                	mov    %eax,%ebp
  802a31:	89 d8                	mov    %ebx,%eax
  802a33:	31 d2                	xor    %edx,%edx
  802a35:	f7 f5                	div    %ebp
  802a37:	89 f0                	mov    %esi,%eax
  802a39:	f7 f5                	div    %ebp
  802a3b:	89 d0                	mov    %edx,%eax
  802a3d:	31 d2                	xor    %edx,%edx
  802a3f:	eb 8c                	jmp    8029cd <__umoddi3+0x2d>
  802a41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a48:	89 e9                	mov    %ebp,%ecx
  802a4a:	ba 20 00 00 00       	mov    $0x20,%edx
  802a4f:	29 ea                	sub    %ebp,%edx
  802a51:	d3 e0                	shl    %cl,%eax
  802a53:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a57:	89 d1                	mov    %edx,%ecx
  802a59:	89 f8                	mov    %edi,%eax
  802a5b:	d3 e8                	shr    %cl,%eax
  802a5d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802a61:	89 54 24 04          	mov    %edx,0x4(%esp)
  802a65:	8b 54 24 04          	mov    0x4(%esp),%edx
  802a69:	09 c1                	or     %eax,%ecx
  802a6b:	89 d8                	mov    %ebx,%eax
  802a6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802a71:	89 e9                	mov    %ebp,%ecx
  802a73:	d3 e7                	shl    %cl,%edi
  802a75:	89 d1                	mov    %edx,%ecx
  802a77:	d3 e8                	shr    %cl,%eax
  802a79:	89 e9                	mov    %ebp,%ecx
  802a7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802a7f:	d3 e3                	shl    %cl,%ebx
  802a81:	89 c7                	mov    %eax,%edi
  802a83:	89 d1                	mov    %edx,%ecx
  802a85:	89 f0                	mov    %esi,%eax
  802a87:	d3 e8                	shr    %cl,%eax
  802a89:	89 e9                	mov    %ebp,%ecx
  802a8b:	89 fa                	mov    %edi,%edx
  802a8d:	d3 e6                	shl    %cl,%esi
  802a8f:	09 d8                	or     %ebx,%eax
  802a91:	f7 74 24 08          	divl   0x8(%esp)
  802a95:	89 d1                	mov    %edx,%ecx
  802a97:	89 f3                	mov    %esi,%ebx
  802a99:	f7 64 24 0c          	mull   0xc(%esp)
  802a9d:	89 c6                	mov    %eax,%esi
  802a9f:	89 d7                	mov    %edx,%edi
  802aa1:	39 d1                	cmp    %edx,%ecx
  802aa3:	72 06                	jb     802aab <__umoddi3+0x10b>
  802aa5:	75 10                	jne    802ab7 <__umoddi3+0x117>
  802aa7:	39 c3                	cmp    %eax,%ebx
  802aa9:	73 0c                	jae    802ab7 <__umoddi3+0x117>
  802aab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  802aaf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802ab3:	89 d7                	mov    %edx,%edi
  802ab5:	89 c6                	mov    %eax,%esi
  802ab7:	89 ca                	mov    %ecx,%edx
  802ab9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802abe:	29 f3                	sub    %esi,%ebx
  802ac0:	19 fa                	sbb    %edi,%edx
  802ac2:	89 d0                	mov    %edx,%eax
  802ac4:	d3 e0                	shl    %cl,%eax
  802ac6:	89 e9                	mov    %ebp,%ecx
  802ac8:	d3 eb                	shr    %cl,%ebx
  802aca:	d3 ea                	shr    %cl,%edx
  802acc:	09 d8                	or     %ebx,%eax
  802ace:	83 c4 1c             	add    $0x1c,%esp
  802ad1:	5b                   	pop    %ebx
  802ad2:	5e                   	pop    %esi
  802ad3:	5f                   	pop    %edi
  802ad4:	5d                   	pop    %ebp
  802ad5:	c3                   	ret    
  802ad6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802add:	8d 76 00             	lea    0x0(%esi),%esi
  802ae0:	29 fe                	sub    %edi,%esi
  802ae2:	19 c3                	sbb    %eax,%ebx
  802ae4:	89 f2                	mov    %esi,%edx
  802ae6:	89 d9                	mov    %ebx,%ecx
  802ae8:	e9 1d ff ff ff       	jmp    802a0a <__umoddi3+0x6a>
