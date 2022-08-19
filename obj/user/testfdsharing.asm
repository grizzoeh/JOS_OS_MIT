
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 a3 01 00 00       	call   8001d4 <libmain>
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

00800035 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800035:	f3 0f 1e fb          	endbr32 
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	57                   	push   %edi
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  800042:	6a 00                	push   $0x0
  800044:	68 20 25 80 00       	push   $0x802520
  800049:	e8 96 1a 00 00       	call   801ae4 <open>
  80004e:	89 c3                	mov    %eax,%ebx
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	0f 88 03 01 00 00    	js     80015e <umain+0x129>
		panic("open motd: %e", fd);
	seek(fd, 0);
  80005b:	83 ec 08             	sub    $0x8,%esp
  80005e:	6a 00                	push   $0x0
  800060:	50                   	push   %eax
  800061:	e8 20 17 00 00       	call   801786 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  800066:	83 c4 0c             	add    $0xc,%esp
  800069:	68 00 02 00 00       	push   $0x200
  80006e:	68 20 42 80 00       	push   $0x804220
  800073:	53                   	push   %ebx
  800074:	e8 3c 16 00 00       	call   8016b5 <readn>
  800079:	89 c6                	mov    %eax,%esi
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	85 c0                	test   %eax,%eax
  800080:	0f 8e ea 00 00 00    	jle    800170 <umain+0x13b>
		panic("readn: %e", n);

	if ((r = fork()) < 0)
  800086:	e8 3f 11 00 00       	call   8011ca <fork>
  80008b:	89 c7                	mov    %eax,%edi
  80008d:	85 c0                	test   %eax,%eax
  80008f:	0f 88 ed 00 00 00    	js     800182 <umain+0x14d>
		panic("fork: %e", r);
	if (r == 0) {
  800095:	75 7b                	jne    800112 <umain+0xdd>
		seek(fd, 0);
  800097:	83 ec 08             	sub    $0x8,%esp
  80009a:	6a 00                	push   $0x0
  80009c:	53                   	push   %ebx
  80009d:	e8 e4 16 00 00       	call   801786 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000a2:	c7 04 24 90 25 80 00 	movl   $0x802590,(%esp)
  8000a9:	e8 79 02 00 00       	call   800327 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000ae:	83 c4 0c             	add    $0xc,%esp
  8000b1:	68 00 02 00 00       	push   $0x200
  8000b6:	68 20 40 80 00       	push   $0x804020
  8000bb:	53                   	push   %ebx
  8000bc:	e8 f4 15 00 00       	call   8016b5 <readn>
  8000c1:	83 c4 10             	add    $0x10,%esp
  8000c4:	39 c6                	cmp    %eax,%esi
  8000c6:	0f 85 c8 00 00 00    	jne    800194 <umain+0x15f>
			panic("read in parent got %d, read in child got %d", n, n2);
		if (memcmp(buf, buf2, n) != 0)
  8000cc:	83 ec 04             	sub    $0x4,%esp
  8000cf:	56                   	push   %esi
  8000d0:	68 20 40 80 00       	push   $0x804020
  8000d5:	68 20 42 80 00       	push   $0x804220
  8000da:	e8 ea 09 00 00       	call   800ac9 <memcmp>
  8000df:	83 c4 10             	add    $0x10,%esp
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	0f 85 c0 00 00 00    	jne    8001aa <umain+0x175>
			panic("read in parent got different bytes from read in child");
		cprintf("read in child succeeded\n");
  8000ea:	83 ec 0c             	sub    $0xc,%esp
  8000ed:	68 5b 25 80 00       	push   $0x80255b
  8000f2:	e8 30 02 00 00       	call   800327 <cprintf>
		seek(fd, 0);
  8000f7:	83 c4 08             	add    $0x8,%esp
  8000fa:	6a 00                	push   $0x0
  8000fc:	53                   	push   %ebx
  8000fd:	e8 84 16 00 00       	call   801786 <seek>
		close(fd);
  800102:	89 1c 24             	mov    %ebx,(%esp)
  800105:	e8 d6 13 00 00       	call   8014e0 <close>
		exit();
  80010a:	e8 13 01 00 00       	call   800222 <exit>
  80010f:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  800112:	83 ec 0c             	sub    $0xc,%esp
  800115:	57                   	push   %edi
  800116:	e8 dc 1d 00 00       	call   801ef7 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  80011b:	83 c4 0c             	add    $0xc,%esp
  80011e:	68 00 02 00 00       	push   $0x200
  800123:	68 20 40 80 00       	push   $0x804020
  800128:	53                   	push   %ebx
  800129:	e8 87 15 00 00       	call   8016b5 <readn>
  80012e:	83 c4 10             	add    $0x10,%esp
  800131:	39 c6                	cmp    %eax,%esi
  800133:	0f 85 85 00 00 00    	jne    8001be <umain+0x189>
		panic("read in parent got %d, then got %d", n, n2);
	cprintf("read in parent succeeded\n");
  800139:	83 ec 0c             	sub    $0xc,%esp
  80013c:	68 74 25 80 00       	push   $0x802574
  800141:	e8 e1 01 00 00       	call   800327 <cprintf>
	close(fd);
  800146:	89 1c 24             	mov    %ebx,(%esp)
  800149:	e8 92 13 00 00       	call   8014e0 <close>

	breakpoint();
  80014e:	e8 e0 fe ff ff       	call   800033 <breakpoint>
}
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    
		panic("open motd: %e", fd);
  80015e:	50                   	push   %eax
  80015f:	68 25 25 80 00       	push   $0x802525
  800164:	6a 0c                	push   $0xc
  800166:	68 33 25 80 00       	push   $0x802533
  80016b:	e8 d0 00 00 00       	call   800240 <_panic>
		panic("readn: %e", n);
  800170:	50                   	push   %eax
  800171:	68 48 25 80 00       	push   $0x802548
  800176:	6a 0f                	push   $0xf
  800178:	68 33 25 80 00       	push   $0x802533
  80017d:	e8 be 00 00 00       	call   800240 <_panic>
		panic("fork: %e", r);
  800182:	50                   	push   %eax
  800183:	68 52 25 80 00       	push   $0x802552
  800188:	6a 12                	push   $0x12
  80018a:	68 33 25 80 00       	push   $0x802533
  80018f:	e8 ac 00 00 00       	call   800240 <_panic>
			panic("read in parent got %d, read in child got %d", n, n2);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	56                   	push   %esi
  800199:	68 d4 25 80 00       	push   $0x8025d4
  80019e:	6a 17                	push   $0x17
  8001a0:	68 33 25 80 00       	push   $0x802533
  8001a5:	e8 96 00 00 00       	call   800240 <_panic>
			panic("read in parent got different bytes from read in child");
  8001aa:	83 ec 04             	sub    $0x4,%esp
  8001ad:	68 00 26 80 00       	push   $0x802600
  8001b2:	6a 19                	push   $0x19
  8001b4:	68 33 25 80 00       	push   $0x802533
  8001b9:	e8 82 00 00 00       	call   800240 <_panic>
		panic("read in parent got %d, then got %d", n, n2);
  8001be:	83 ec 0c             	sub    $0xc,%esp
  8001c1:	50                   	push   %eax
  8001c2:	56                   	push   %esi
  8001c3:	68 38 26 80 00       	push   $0x802638
  8001c8:	6a 21                	push   $0x21
  8001ca:	68 33 25 80 00       	push   $0x802533
  8001cf:	e8 6c 00 00 00       	call   800240 <_panic>

008001d4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d4:	f3 0f 1e fb          	endbr32 
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8001e3:	e8 de 0a 00 00       	call   800cc6 <sys_getenvid>
	if (id >= 0)
  8001e8:	85 c0                	test   %eax,%eax
  8001ea:	78 12                	js     8001fe <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8001ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f9:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001fe:	85 db                	test   %ebx,%ebx
  800200:	7e 07                	jle    800209 <libmain+0x35>
		binaryname = argv[0];
  800202:	8b 06                	mov    (%esi),%eax
  800204:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800209:	83 ec 08             	sub    $0x8,%esp
  80020c:	56                   	push   %esi
  80020d:	53                   	push   %ebx
  80020e:	e8 22 fe ff ff       	call   800035 <umain>

	// exit gracefully
	exit();
  800213:	e8 0a 00 00 00       	call   800222 <exit>
}
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5e                   	pop    %esi
  800220:	5d                   	pop    %ebp
  800221:	c3                   	ret    

00800222 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800222:	f3 0f 1e fb          	endbr32 
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80022c:	e8 e0 12 00 00       	call   801511 <close_all>
	sys_env_destroy(0);
  800231:	83 ec 0c             	sub    $0xc,%esp
  800234:	6a 00                	push   $0x0
  800236:	e8 65 0a 00 00       	call   800ca0 <sys_env_destroy>
}
  80023b:	83 c4 10             	add    $0x10,%esp
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800240:	f3 0f 1e fb          	endbr32 
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800252:	e8 6f 0a 00 00       	call   800cc6 <sys_getenvid>
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	56                   	push   %esi
  800261:	50                   	push   %eax
  800262:	68 68 26 80 00       	push   $0x802668
  800267:	e8 bb 00 00 00       	call   800327 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 5a 00 00 00       	call   8002d2 <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 72 25 80 00 	movl   $0x802572,(%esp)
  80027f:	e8 a3 00 00 00       	call   800327 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x47>

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	f3 0f 1e fb          	endbr32 
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	53                   	push   %ebx
  800292:	83 ec 04             	sub    $0x4,%esp
  800295:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800298:	8b 13                	mov    (%ebx),%edx
  80029a:	8d 42 01             	lea    0x1(%edx),%eax
  80029d:	89 03                	mov    %eax,(%ebx)
  80029f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002ab:	74 09                	je     8002b6 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002ad:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b4:	c9                   	leave  
  8002b5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002b6:	83 ec 08             	sub    $0x8,%esp
  8002b9:	68 ff 00 00 00       	push   $0xff
  8002be:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c1:	50                   	push   %eax
  8002c2:	e8 87 09 00 00       	call   800c4e <sys_cputs>
		b->idx = 0;
  8002c7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	eb db                	jmp    8002ad <putch+0x23>

008002d2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002d2:	f3 0f 1e fb          	endbr32 
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002df:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002e6:	00 00 00 
	b.cnt = 0;
  8002e9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002f0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002f3:	ff 75 0c             	pushl  0xc(%ebp)
  8002f6:	ff 75 08             	pushl  0x8(%ebp)
  8002f9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ff:	50                   	push   %eax
  800300:	68 8a 02 80 00       	push   $0x80028a
  800305:	e8 80 01 00 00       	call   80048a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80030a:	83 c4 08             	add    $0x8,%esp
  80030d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800313:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800319:	50                   	push   %eax
  80031a:	e8 2f 09 00 00       	call   800c4e <sys_cputs>

	return b.cnt;
}
  80031f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800325:	c9                   	leave  
  800326:	c3                   	ret    

00800327 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800327:	f3 0f 1e fb          	endbr32 
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800331:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800334:	50                   	push   %eax
  800335:	ff 75 08             	pushl  0x8(%ebp)
  800338:	e8 95 ff ff ff       	call   8002d2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80033d:	c9                   	leave  
  80033e:	c3                   	ret    

0080033f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	57                   	push   %edi
  800343:	56                   	push   %esi
  800344:	53                   	push   %ebx
  800345:	83 ec 1c             	sub    $0x1c,%esp
  800348:	89 c7                	mov    %eax,%edi
  80034a:	89 d6                	mov    %edx,%esi
  80034c:	8b 45 08             	mov    0x8(%ebp),%eax
  80034f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800352:	89 d1                	mov    %edx,%ecx
  800354:	89 c2                	mov    %eax,%edx
  800356:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800359:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80035c:	8b 45 10             	mov    0x10(%ebp),%eax
  80035f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800362:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800365:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80036c:	39 c2                	cmp    %eax,%edx
  80036e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800371:	72 3e                	jb     8003b1 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800373:	83 ec 0c             	sub    $0xc,%esp
  800376:	ff 75 18             	pushl  0x18(%ebp)
  800379:	83 eb 01             	sub    $0x1,%ebx
  80037c:	53                   	push   %ebx
  80037d:	50                   	push   %eax
  80037e:	83 ec 08             	sub    $0x8,%esp
  800381:	ff 75 e4             	pushl  -0x1c(%ebp)
  800384:	ff 75 e0             	pushl  -0x20(%ebp)
  800387:	ff 75 dc             	pushl  -0x24(%ebp)
  80038a:	ff 75 d8             	pushl  -0x28(%ebp)
  80038d:	e8 2e 1f 00 00       	call   8022c0 <__udivdi3>
  800392:	83 c4 18             	add    $0x18,%esp
  800395:	52                   	push   %edx
  800396:	50                   	push   %eax
  800397:	89 f2                	mov    %esi,%edx
  800399:	89 f8                	mov    %edi,%eax
  80039b:	e8 9f ff ff ff       	call   80033f <printnum>
  8003a0:	83 c4 20             	add    $0x20,%esp
  8003a3:	eb 13                	jmp    8003b8 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	56                   	push   %esi
  8003a9:	ff 75 18             	pushl  0x18(%ebp)
  8003ac:	ff d7                	call   *%edi
  8003ae:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003b1:	83 eb 01             	sub    $0x1,%ebx
  8003b4:	85 db                	test   %ebx,%ebx
  8003b6:	7f ed                	jg     8003a5 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b8:	83 ec 08             	sub    $0x8,%esp
  8003bb:	56                   	push   %esi
  8003bc:	83 ec 04             	sub    $0x4,%esp
  8003bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8003c5:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c8:	ff 75 d8             	pushl  -0x28(%ebp)
  8003cb:	e8 00 20 00 00       	call   8023d0 <__umoddi3>
  8003d0:	83 c4 14             	add    $0x14,%esp
  8003d3:	0f be 80 8b 26 80 00 	movsbl 0x80268b(%eax),%eax
  8003da:	50                   	push   %eax
  8003db:	ff d7                	call   *%edi
}
  8003dd:	83 c4 10             	add    $0x10,%esp
  8003e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e3:	5b                   	pop    %ebx
  8003e4:	5e                   	pop    %esi
  8003e5:	5f                   	pop    %edi
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8003e8:	83 fa 01             	cmp    $0x1,%edx
  8003eb:	7f 13                	jg     800400 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8003ed:	85 d2                	test   %edx,%edx
  8003ef:	74 1c                	je     80040d <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8003f1:	8b 10                	mov    (%eax),%edx
  8003f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f6:	89 08                	mov    %ecx,(%eax)
  8003f8:	8b 02                	mov    (%edx),%eax
  8003fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ff:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800400:	8b 10                	mov    (%eax),%edx
  800402:	8d 4a 08             	lea    0x8(%edx),%ecx
  800405:	89 08                	mov    %ecx,(%eax)
  800407:	8b 02                	mov    (%edx),%eax
  800409:	8b 52 04             	mov    0x4(%edx),%edx
  80040c:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80040d:	8b 10                	mov    (%eax),%edx
  80040f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800412:	89 08                	mov    %ecx,(%eax)
  800414:	8b 02                	mov    (%edx),%eax
  800416:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80041b:	c3                   	ret    

0080041c <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80041c:	83 fa 01             	cmp    $0x1,%edx
  80041f:	7f 0f                	jg     800430 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800421:	85 d2                	test   %edx,%edx
  800423:	74 18                	je     80043d <getint+0x21>
		return va_arg(*ap, long);
  800425:	8b 10                	mov    (%eax),%edx
  800427:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042a:	89 08                	mov    %ecx,(%eax)
  80042c:	8b 02                	mov    (%edx),%eax
  80042e:	99                   	cltd   
  80042f:	c3                   	ret    
		return va_arg(*ap, long long);
  800430:	8b 10                	mov    (%eax),%edx
  800432:	8d 4a 08             	lea    0x8(%edx),%ecx
  800435:	89 08                	mov    %ecx,(%eax)
  800437:	8b 02                	mov    (%edx),%eax
  800439:	8b 52 04             	mov    0x4(%edx),%edx
  80043c:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80043d:	8b 10                	mov    (%eax),%edx
  80043f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800442:	89 08                	mov    %ecx,(%eax)
  800444:	8b 02                	mov    (%edx),%eax
  800446:	99                   	cltd   
}
  800447:	c3                   	ret    

00800448 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800448:	f3 0f 1e fb          	endbr32 
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800452:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800456:	8b 10                	mov    (%eax),%edx
  800458:	3b 50 04             	cmp    0x4(%eax),%edx
  80045b:	73 0a                	jae    800467 <sprintputch+0x1f>
		*b->buf++ = ch;
  80045d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800460:	89 08                	mov    %ecx,(%eax)
  800462:	8b 45 08             	mov    0x8(%ebp),%eax
  800465:	88 02                	mov    %al,(%edx)
}
  800467:	5d                   	pop    %ebp
  800468:	c3                   	ret    

00800469 <printfmt>:
{
  800469:	f3 0f 1e fb          	endbr32 
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
  800470:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800473:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800476:	50                   	push   %eax
  800477:	ff 75 10             	pushl  0x10(%ebp)
  80047a:	ff 75 0c             	pushl  0xc(%ebp)
  80047d:	ff 75 08             	pushl  0x8(%ebp)
  800480:	e8 05 00 00 00       	call   80048a <vprintfmt>
}
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	c9                   	leave  
  800489:	c3                   	ret    

0080048a <vprintfmt>:
{
  80048a:	f3 0f 1e fb          	endbr32 
  80048e:	55                   	push   %ebp
  80048f:	89 e5                	mov    %esp,%ebp
  800491:	57                   	push   %edi
  800492:	56                   	push   %esi
  800493:	53                   	push   %ebx
  800494:	83 ec 2c             	sub    $0x2c,%esp
  800497:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80049a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80049d:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004a0:	e9 86 02 00 00       	jmp    80072b <vprintfmt+0x2a1>
		padc = ' ';
  8004a5:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8004a9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8004b0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8004b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004be:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	8d 47 01             	lea    0x1(%edi),%eax
  8004c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004c9:	0f b6 17             	movzbl (%edi),%edx
  8004cc:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004cf:	3c 55                	cmp    $0x55,%al
  8004d1:	0f 87 df 02 00 00    	ja     8007b6 <vprintfmt+0x32c>
  8004d7:	0f b6 c0             	movzbl %al,%eax
  8004da:	3e ff 24 85 c0 27 80 	notrack jmp *0x8027c0(,%eax,4)
  8004e1:	00 
  8004e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8004e5:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8004e9:	eb d8                	jmp    8004c3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ee:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8004f2:	eb cf                	jmp    8004c3 <vprintfmt+0x39>
  8004f4:	0f b6 d2             	movzbl %dl,%edx
  8004f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8004fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ff:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800502:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800505:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800509:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80050c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80050f:	83 f9 09             	cmp    $0x9,%ecx
  800512:	77 52                	ja     800566 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800514:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800517:	eb e9                	jmp    800502 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 50 04             	lea    0x4(%eax),%edx
  80051f:	89 55 14             	mov    %edx,0x14(%ebp)
  800522:	8b 00                	mov    (%eax),%eax
  800524:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80052a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052e:	79 93                	jns    8004c3 <vprintfmt+0x39>
				width = precision, precision = -1;
  800530:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800533:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800536:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80053d:	eb 84                	jmp    8004c3 <vprintfmt+0x39>
  80053f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800542:	85 c0                	test   %eax,%eax
  800544:	ba 00 00 00 00       	mov    $0x0,%edx
  800549:	0f 49 d0             	cmovns %eax,%edx
  80054c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80054f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800552:	e9 6c ff ff ff       	jmp    8004c3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80055a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800561:	e9 5d ff ff ff       	jmp    8004c3 <vprintfmt+0x39>
  800566:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800569:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80056c:	eb bc                	jmp    80052a <vprintfmt+0xa0>
			lflag++;
  80056e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800574:	e9 4a ff ff ff       	jmp    8004c3 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 50 04             	lea    0x4(%eax),%edx
  80057f:	89 55 14             	mov    %edx,0x14(%ebp)
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	56                   	push   %esi
  800586:	ff 30                	pushl  (%eax)
  800588:	ff d3                	call   *%ebx
			break;
  80058a:	83 c4 10             	add    $0x10,%esp
  80058d:	e9 96 01 00 00       	jmp    800728 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 50 04             	lea    0x4(%eax),%edx
  800598:	89 55 14             	mov    %edx,0x14(%ebp)
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	99                   	cltd   
  80059e:	31 d0                	xor    %edx,%eax
  8005a0:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a2:	83 f8 0f             	cmp    $0xf,%eax
  8005a5:	7f 20                	jg     8005c7 <vprintfmt+0x13d>
  8005a7:	8b 14 85 20 29 80 00 	mov    0x802920(,%eax,4),%edx
  8005ae:	85 d2                	test   %edx,%edx
  8005b0:	74 15                	je     8005c7 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8005b2:	52                   	push   %edx
  8005b3:	68 25 2c 80 00       	push   $0x802c25
  8005b8:	56                   	push   %esi
  8005b9:	53                   	push   %ebx
  8005ba:	e8 aa fe ff ff       	call   800469 <printfmt>
  8005bf:	83 c4 10             	add    $0x10,%esp
  8005c2:	e9 61 01 00 00       	jmp    800728 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8005c7:	50                   	push   %eax
  8005c8:	68 a3 26 80 00       	push   $0x8026a3
  8005cd:	56                   	push   %esi
  8005ce:	53                   	push   %ebx
  8005cf:	e8 95 fe ff ff       	call   800469 <printfmt>
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	e9 4c 01 00 00       	jmp    800728 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 50 04             	lea    0x4(%eax),%edx
  8005e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e5:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8005e7:	85 c9                	test   %ecx,%ecx
  8005e9:	b8 9c 26 80 00       	mov    $0x80269c,%eax
  8005ee:	0f 45 c1             	cmovne %ecx,%eax
  8005f1:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f8:	7e 06                	jle    800600 <vprintfmt+0x176>
  8005fa:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8005fe:	75 0d                	jne    80060d <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800600:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800603:	89 c7                	mov    %eax,%edi
  800605:	03 45 e0             	add    -0x20(%ebp),%eax
  800608:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060b:	eb 57                	jmp    800664 <vprintfmt+0x1da>
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	ff 75 d8             	pushl  -0x28(%ebp)
  800613:	ff 75 cc             	pushl  -0x34(%ebp)
  800616:	e8 4f 02 00 00       	call   80086a <strnlen>
  80061b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80061e:	29 c2                	sub    %eax,%edx
  800620:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800623:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800626:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80062a:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80062d:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80062f:	85 db                	test   %ebx,%ebx
  800631:	7e 10                	jle    800643 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	56                   	push   %esi
  800637:	57                   	push   %edi
  800638:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80063b:	83 eb 01             	sub    $0x1,%ebx
  80063e:	83 c4 10             	add    $0x10,%esp
  800641:	eb ec                	jmp    80062f <vprintfmt+0x1a5>
  800643:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800646:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800649:	85 d2                	test   %edx,%edx
  80064b:	b8 00 00 00 00       	mov    $0x0,%eax
  800650:	0f 49 c2             	cmovns %edx,%eax
  800653:	29 c2                	sub    %eax,%edx
  800655:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800658:	eb a6                	jmp    800600 <vprintfmt+0x176>
					putch(ch, putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	56                   	push   %esi
  80065e:	52                   	push   %edx
  80065f:	ff d3                	call   *%ebx
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800667:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800669:	83 c7 01             	add    $0x1,%edi
  80066c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800670:	0f be d0             	movsbl %al,%edx
  800673:	85 d2                	test   %edx,%edx
  800675:	74 42                	je     8006b9 <vprintfmt+0x22f>
  800677:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80067b:	78 06                	js     800683 <vprintfmt+0x1f9>
  80067d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800681:	78 1e                	js     8006a1 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800683:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800687:	74 d1                	je     80065a <vprintfmt+0x1d0>
  800689:	0f be c0             	movsbl %al,%eax
  80068c:	83 e8 20             	sub    $0x20,%eax
  80068f:	83 f8 5e             	cmp    $0x5e,%eax
  800692:	76 c6                	jbe    80065a <vprintfmt+0x1d0>
					putch('?', putdat);
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	56                   	push   %esi
  800698:	6a 3f                	push   $0x3f
  80069a:	ff d3                	call   *%ebx
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	eb c3                	jmp    800664 <vprintfmt+0x1da>
  8006a1:	89 cf                	mov    %ecx,%edi
  8006a3:	eb 0e                	jmp    8006b3 <vprintfmt+0x229>
				putch(' ', putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	56                   	push   %esi
  8006a9:	6a 20                	push   $0x20
  8006ab:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8006ad:	83 ef 01             	sub    $0x1,%edi
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	85 ff                	test   %edi,%edi
  8006b5:	7f ee                	jg     8006a5 <vprintfmt+0x21b>
  8006b7:	eb 6f                	jmp    800728 <vprintfmt+0x29e>
  8006b9:	89 cf                	mov    %ecx,%edi
  8006bb:	eb f6                	jmp    8006b3 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8006bd:	89 ca                	mov    %ecx,%edx
  8006bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c2:	e8 55 fd ff ff       	call   80041c <getint>
  8006c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8006cd:	85 d2                	test   %edx,%edx
  8006cf:	78 0b                	js     8006dc <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8006d1:	89 d1                	mov    %edx,%ecx
  8006d3:	89 c2                	mov    %eax,%edx
			base = 10;
  8006d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006da:	eb 32                	jmp    80070e <vprintfmt+0x284>
				putch('-', putdat);
  8006dc:	83 ec 08             	sub    $0x8,%esp
  8006df:	56                   	push   %esi
  8006e0:	6a 2d                	push   $0x2d
  8006e2:	ff d3                	call   *%ebx
				num = -(long long) num;
  8006e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006ea:	f7 da                	neg    %edx
  8006ec:	83 d1 00             	adc    $0x0,%ecx
  8006ef:	f7 d9                	neg    %ecx
  8006f1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006f4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f9:	eb 13                	jmp    80070e <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8006fb:	89 ca                	mov    %ecx,%edx
  8006fd:	8d 45 14             	lea    0x14(%ebp),%eax
  800700:	e8 e3 fc ff ff       	call   8003e8 <getuint>
  800705:	89 d1                	mov    %edx,%ecx
  800707:	89 c2                	mov    %eax,%edx
			base = 10;
  800709:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  80070e:	83 ec 0c             	sub    $0xc,%esp
  800711:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800715:	57                   	push   %edi
  800716:	ff 75 e0             	pushl  -0x20(%ebp)
  800719:	50                   	push   %eax
  80071a:	51                   	push   %ecx
  80071b:	52                   	push   %edx
  80071c:	89 f2                	mov    %esi,%edx
  80071e:	89 d8                	mov    %ebx,%eax
  800720:	e8 1a fc ff ff       	call   80033f <printnum>
			break;
  800725:	83 c4 20             	add    $0x20,%esp
{
  800728:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80072b:	83 c7 01             	add    $0x1,%edi
  80072e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800732:	83 f8 25             	cmp    $0x25,%eax
  800735:	0f 84 6a fd ff ff    	je     8004a5 <vprintfmt+0x1b>
			if (ch == '\0')
  80073b:	85 c0                	test   %eax,%eax
  80073d:	0f 84 93 00 00 00    	je     8007d6 <vprintfmt+0x34c>
			putch(ch, putdat);
  800743:	83 ec 08             	sub    $0x8,%esp
  800746:	56                   	push   %esi
  800747:	50                   	push   %eax
  800748:	ff d3                	call   *%ebx
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	eb dc                	jmp    80072b <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  80074f:	89 ca                	mov    %ecx,%edx
  800751:	8d 45 14             	lea    0x14(%ebp),%eax
  800754:	e8 8f fc ff ff       	call   8003e8 <getuint>
  800759:	89 d1                	mov    %edx,%ecx
  80075b:	89 c2                	mov    %eax,%edx
			base = 8;
  80075d:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800762:	eb aa                	jmp    80070e <vprintfmt+0x284>
			putch('0', putdat);
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	56                   	push   %esi
  800768:	6a 30                	push   $0x30
  80076a:	ff d3                	call   *%ebx
			putch('x', putdat);
  80076c:	83 c4 08             	add    $0x8,%esp
  80076f:	56                   	push   %esi
  800770:	6a 78                	push   $0x78
  800772:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8d 50 04             	lea    0x4(%eax),%edx
  80077a:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80077d:	8b 10                	mov    (%eax),%edx
  80077f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800784:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800787:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80078c:	eb 80                	jmp    80070e <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80078e:	89 ca                	mov    %ecx,%edx
  800790:	8d 45 14             	lea    0x14(%ebp),%eax
  800793:	e8 50 fc ff ff       	call   8003e8 <getuint>
  800798:	89 d1                	mov    %edx,%ecx
  80079a:	89 c2                	mov    %eax,%edx
			base = 16;
  80079c:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a1:	e9 68 ff ff ff       	jmp    80070e <vprintfmt+0x284>
			putch(ch, putdat);
  8007a6:	83 ec 08             	sub    $0x8,%esp
  8007a9:	56                   	push   %esi
  8007aa:	6a 25                	push   $0x25
  8007ac:	ff d3                	call   *%ebx
			break;
  8007ae:	83 c4 10             	add    $0x10,%esp
  8007b1:	e9 72 ff ff ff       	jmp    800728 <vprintfmt+0x29e>
			putch('%', putdat);
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	56                   	push   %esi
  8007ba:	6a 25                	push   $0x25
  8007bc:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007be:	83 c4 10             	add    $0x10,%esp
  8007c1:	89 f8                	mov    %edi,%eax
  8007c3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007c7:	74 05                	je     8007ce <vprintfmt+0x344>
  8007c9:	83 e8 01             	sub    $0x1,%eax
  8007cc:	eb f5                	jmp    8007c3 <vprintfmt+0x339>
  8007ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007d1:	e9 52 ff ff ff       	jmp    800728 <vprintfmt+0x29e>
}
  8007d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d9:	5b                   	pop    %ebx
  8007da:	5e                   	pop    %esi
  8007db:	5f                   	pop    %edi
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007de:	f3 0f 1e fb          	endbr32 
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	83 ec 18             	sub    $0x18,%esp
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ff:	85 c0                	test   %eax,%eax
  800801:	74 26                	je     800829 <vsnprintf+0x4b>
  800803:	85 d2                	test   %edx,%edx
  800805:	7e 22                	jle    800829 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800807:	ff 75 14             	pushl  0x14(%ebp)
  80080a:	ff 75 10             	pushl  0x10(%ebp)
  80080d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800810:	50                   	push   %eax
  800811:	68 48 04 80 00       	push   $0x800448
  800816:	e8 6f fc ff ff       	call   80048a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80081b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800821:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800824:	83 c4 10             	add    $0x10,%esp
}
  800827:	c9                   	leave  
  800828:	c3                   	ret    
		return -E_INVAL;
  800829:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082e:	eb f7                	jmp    800827 <vsnprintf+0x49>

00800830 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800830:	f3 0f 1e fb          	endbr32 
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80083a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80083d:	50                   	push   %eax
  80083e:	ff 75 10             	pushl  0x10(%ebp)
  800841:	ff 75 0c             	pushl  0xc(%ebp)
  800844:	ff 75 08             	pushl  0x8(%ebp)
  800847:	e8 92 ff ff ff       	call   8007de <vsnprintf>
	va_end(ap);

	return rc;
}
  80084c:	c9                   	leave  
  80084d:	c3                   	ret    

0080084e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80084e:	f3 0f 1e fb          	endbr32 
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800858:	b8 00 00 00 00       	mov    $0x0,%eax
  80085d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800861:	74 05                	je     800868 <strlen+0x1a>
		n++;
  800863:	83 c0 01             	add    $0x1,%eax
  800866:	eb f5                	jmp    80085d <strlen+0xf>
	return n;
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086a:	f3 0f 1e fb          	endbr32 
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800874:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
  80087c:	39 d0                	cmp    %edx,%eax
  80087e:	74 0d                	je     80088d <strnlen+0x23>
  800880:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800884:	74 05                	je     80088b <strnlen+0x21>
		n++;
  800886:	83 c0 01             	add    $0x1,%eax
  800889:	eb f1                	jmp    80087c <strnlen+0x12>
  80088b:	89 c2                	mov    %eax,%edx
	return n;
}
  80088d:	89 d0                	mov    %edx,%eax
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800891:	f3 0f 1e fb          	endbr32 
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	53                   	push   %ebx
  800899:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008a8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008ab:	83 c0 01             	add    $0x1,%eax
  8008ae:	84 d2                	test   %dl,%dl
  8008b0:	75 f2                	jne    8008a4 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8008b2:	89 c8                	mov    %ecx,%eax
  8008b4:	5b                   	pop    %ebx
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b7:	f3 0f 1e fb          	endbr32 
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	83 ec 10             	sub    $0x10,%esp
  8008c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c5:	53                   	push   %ebx
  8008c6:	e8 83 ff ff ff       	call   80084e <strlen>
  8008cb:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008ce:	ff 75 0c             	pushl  0xc(%ebp)
  8008d1:	01 d8                	add    %ebx,%eax
  8008d3:	50                   	push   %eax
  8008d4:	e8 b8 ff ff ff       	call   800891 <strcpy>
	return dst;
}
  8008d9:	89 d8                	mov    %ebx,%eax
  8008db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e0:	f3 0f 1e fb          	endbr32 
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ef:	89 f3                	mov    %esi,%ebx
  8008f1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f4:	89 f0                	mov    %esi,%eax
  8008f6:	39 d8                	cmp    %ebx,%eax
  8008f8:	74 11                	je     80090b <strncpy+0x2b>
		*dst++ = *src;
  8008fa:	83 c0 01             	add    $0x1,%eax
  8008fd:	0f b6 0a             	movzbl (%edx),%ecx
  800900:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800903:	80 f9 01             	cmp    $0x1,%cl
  800906:	83 da ff             	sbb    $0xffffffff,%edx
  800909:	eb eb                	jmp    8008f6 <strncpy+0x16>
	}
	return ret;
}
  80090b:	89 f0                	mov    %esi,%eax
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800911:	f3 0f 1e fb          	endbr32 
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	56                   	push   %esi
  800919:	53                   	push   %ebx
  80091a:	8b 75 08             	mov    0x8(%ebp),%esi
  80091d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800920:	8b 55 10             	mov    0x10(%ebp),%edx
  800923:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800925:	85 d2                	test   %edx,%edx
  800927:	74 21                	je     80094a <strlcpy+0x39>
  800929:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80092d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80092f:	39 c2                	cmp    %eax,%edx
  800931:	74 14                	je     800947 <strlcpy+0x36>
  800933:	0f b6 19             	movzbl (%ecx),%ebx
  800936:	84 db                	test   %bl,%bl
  800938:	74 0b                	je     800945 <strlcpy+0x34>
			*dst++ = *src++;
  80093a:	83 c1 01             	add    $0x1,%ecx
  80093d:	83 c2 01             	add    $0x1,%edx
  800940:	88 5a ff             	mov    %bl,-0x1(%edx)
  800943:	eb ea                	jmp    80092f <strlcpy+0x1e>
  800945:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800947:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80094a:	29 f0                	sub    %esi,%eax
}
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800950:	f3 0f 1e fb          	endbr32 
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095d:	0f b6 01             	movzbl (%ecx),%eax
  800960:	84 c0                	test   %al,%al
  800962:	74 0c                	je     800970 <strcmp+0x20>
  800964:	3a 02                	cmp    (%edx),%al
  800966:	75 08                	jne    800970 <strcmp+0x20>
		p++, q++;
  800968:	83 c1 01             	add    $0x1,%ecx
  80096b:	83 c2 01             	add    $0x1,%edx
  80096e:	eb ed                	jmp    80095d <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800970:	0f b6 c0             	movzbl %al,%eax
  800973:	0f b6 12             	movzbl (%edx),%edx
  800976:	29 d0                	sub    %edx,%eax
}
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80097a:	f3 0f 1e fb          	endbr32 
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	53                   	push   %ebx
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	8b 55 0c             	mov    0xc(%ebp),%edx
  800988:	89 c3                	mov    %eax,%ebx
  80098a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80098d:	eb 06                	jmp    800995 <strncmp+0x1b>
		n--, p++, q++;
  80098f:	83 c0 01             	add    $0x1,%eax
  800992:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800995:	39 d8                	cmp    %ebx,%eax
  800997:	74 16                	je     8009af <strncmp+0x35>
  800999:	0f b6 08             	movzbl (%eax),%ecx
  80099c:	84 c9                	test   %cl,%cl
  80099e:	74 04                	je     8009a4 <strncmp+0x2a>
  8009a0:	3a 0a                	cmp    (%edx),%cl
  8009a2:	74 eb                	je     80098f <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a4:	0f b6 00             	movzbl (%eax),%eax
  8009a7:	0f b6 12             	movzbl (%edx),%edx
  8009aa:	29 d0                	sub    %edx,%eax
}
  8009ac:	5b                   	pop    %ebx
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    
		return 0;
  8009af:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b4:	eb f6                	jmp    8009ac <strncmp+0x32>

008009b6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b6:	f3 0f 1e fb          	endbr32 
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c4:	0f b6 10             	movzbl (%eax),%edx
  8009c7:	84 d2                	test   %dl,%dl
  8009c9:	74 09                	je     8009d4 <strchr+0x1e>
		if (*s == c)
  8009cb:	38 ca                	cmp    %cl,%dl
  8009cd:	74 0a                	je     8009d9 <strchr+0x23>
	for (; *s; s++)
  8009cf:	83 c0 01             	add    $0x1,%eax
  8009d2:	eb f0                	jmp    8009c4 <strchr+0xe>
			return (char *) s;
	return 0;
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009db:	f3 0f 1e fb          	endbr32 
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ec:	38 ca                	cmp    %cl,%dl
  8009ee:	74 09                	je     8009f9 <strfind+0x1e>
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	74 05                	je     8009f9 <strfind+0x1e>
	for (; *s; s++)
  8009f4:	83 c0 01             	add    $0x1,%eax
  8009f7:	eb f0                	jmp    8009e9 <strfind+0xe>
			break;
	return (char *) s;
}
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009fb:	f3 0f 1e fb          	endbr32 
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	57                   	push   %edi
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 55 08             	mov    0x8(%ebp),%edx
  800a08:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a0b:	85 c9                	test   %ecx,%ecx
  800a0d:	74 33                	je     800a42 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0f:	89 d0                	mov    %edx,%eax
  800a11:	09 c8                	or     %ecx,%eax
  800a13:	a8 03                	test   $0x3,%al
  800a15:	75 23                	jne    800a3a <memset+0x3f>
		c &= 0xFF;
  800a17:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1b:	89 d8                	mov    %ebx,%eax
  800a1d:	c1 e0 08             	shl    $0x8,%eax
  800a20:	89 df                	mov    %ebx,%edi
  800a22:	c1 e7 18             	shl    $0x18,%edi
  800a25:	89 de                	mov    %ebx,%esi
  800a27:	c1 e6 10             	shl    $0x10,%esi
  800a2a:	09 f7                	or     %esi,%edi
  800a2c:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800a2e:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a31:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a33:	89 d7                	mov    %edx,%edi
  800a35:	fc                   	cld    
  800a36:	f3 ab                	rep stos %eax,%es:(%edi)
  800a38:	eb 08                	jmp    800a42 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3a:	89 d7                	mov    %edx,%edi
  800a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3f:	fc                   	cld    
  800a40:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800a42:	89 d0                	mov    %edx,%eax
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	5f                   	pop    %edi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a49:	f3 0f 1e fb          	endbr32 
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	57                   	push   %edi
  800a51:	56                   	push   %esi
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a58:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a5b:	39 c6                	cmp    %eax,%esi
  800a5d:	73 32                	jae    800a91 <memmove+0x48>
  800a5f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a62:	39 c2                	cmp    %eax,%edx
  800a64:	76 2b                	jbe    800a91 <memmove+0x48>
		s += n;
		d += n;
  800a66:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a69:	89 fe                	mov    %edi,%esi
  800a6b:	09 ce                	or     %ecx,%esi
  800a6d:	09 d6                	or     %edx,%esi
  800a6f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a75:	75 0e                	jne    800a85 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a77:	83 ef 04             	sub    $0x4,%edi
  800a7a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a7d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a80:	fd                   	std    
  800a81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a83:	eb 09                	jmp    800a8e <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a85:	83 ef 01             	sub    $0x1,%edi
  800a88:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a8b:	fd                   	std    
  800a8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8e:	fc                   	cld    
  800a8f:	eb 1a                	jmp    800aab <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a91:	89 c2                	mov    %eax,%edx
  800a93:	09 ca                	or     %ecx,%edx
  800a95:	09 f2                	or     %esi,%edx
  800a97:	f6 c2 03             	test   $0x3,%dl
  800a9a:	75 0a                	jne    800aa6 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a9c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a9f:	89 c7                	mov    %eax,%edi
  800aa1:	fc                   	cld    
  800aa2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa4:	eb 05                	jmp    800aab <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800aa6:	89 c7                	mov    %eax,%edi
  800aa8:	fc                   	cld    
  800aa9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aab:	5e                   	pop    %esi
  800aac:	5f                   	pop    %edi
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aaf:	f3 0f 1e fb          	endbr32 
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab9:	ff 75 10             	pushl  0x10(%ebp)
  800abc:	ff 75 0c             	pushl  0xc(%ebp)
  800abf:	ff 75 08             	pushl  0x8(%ebp)
  800ac2:	e8 82 ff ff ff       	call   800a49 <memmove>
}
  800ac7:	c9                   	leave  
  800ac8:	c3                   	ret    

00800ac9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac9:	f3 0f 1e fb          	endbr32 
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad8:	89 c6                	mov    %eax,%esi
  800ada:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800add:	39 f0                	cmp    %esi,%eax
  800adf:	74 1c                	je     800afd <memcmp+0x34>
		if (*s1 != *s2)
  800ae1:	0f b6 08             	movzbl (%eax),%ecx
  800ae4:	0f b6 1a             	movzbl (%edx),%ebx
  800ae7:	38 d9                	cmp    %bl,%cl
  800ae9:	75 08                	jne    800af3 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800aeb:	83 c0 01             	add    $0x1,%eax
  800aee:	83 c2 01             	add    $0x1,%edx
  800af1:	eb ea                	jmp    800add <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800af3:	0f b6 c1             	movzbl %cl,%eax
  800af6:	0f b6 db             	movzbl %bl,%ebx
  800af9:	29 d8                	sub    %ebx,%eax
  800afb:	eb 05                	jmp    800b02 <memcmp+0x39>
	}

	return 0;
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b06:	f3 0f 1e fb          	endbr32 
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b13:	89 c2                	mov    %eax,%edx
  800b15:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b18:	39 d0                	cmp    %edx,%eax
  800b1a:	73 09                	jae    800b25 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b1c:	38 08                	cmp    %cl,(%eax)
  800b1e:	74 05                	je     800b25 <memfind+0x1f>
	for (; s < ends; s++)
  800b20:	83 c0 01             	add    $0x1,%eax
  800b23:	eb f3                	jmp    800b18 <memfind+0x12>
			break;
	return (void *) s;
}
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b27:	f3 0f 1e fb          	endbr32 
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
  800b31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b34:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b37:	eb 03                	jmp    800b3c <strtol+0x15>
		s++;
  800b39:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b3c:	0f b6 01             	movzbl (%ecx),%eax
  800b3f:	3c 20                	cmp    $0x20,%al
  800b41:	74 f6                	je     800b39 <strtol+0x12>
  800b43:	3c 09                	cmp    $0x9,%al
  800b45:	74 f2                	je     800b39 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b47:	3c 2b                	cmp    $0x2b,%al
  800b49:	74 2a                	je     800b75 <strtol+0x4e>
	int neg = 0;
  800b4b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b50:	3c 2d                	cmp    $0x2d,%al
  800b52:	74 2b                	je     800b7f <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b54:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b5a:	75 0f                	jne    800b6b <strtol+0x44>
  800b5c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b5f:	74 28                	je     800b89 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b61:	85 db                	test   %ebx,%ebx
  800b63:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b68:	0f 44 d8             	cmove  %eax,%ebx
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b70:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b73:	eb 46                	jmp    800bbb <strtol+0x94>
		s++;
  800b75:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b78:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7d:	eb d5                	jmp    800b54 <strtol+0x2d>
		s++, neg = 1;
  800b7f:	83 c1 01             	add    $0x1,%ecx
  800b82:	bf 01 00 00 00       	mov    $0x1,%edi
  800b87:	eb cb                	jmp    800b54 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b89:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b8d:	74 0e                	je     800b9d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b8f:	85 db                	test   %ebx,%ebx
  800b91:	75 d8                	jne    800b6b <strtol+0x44>
		s++, base = 8;
  800b93:	83 c1 01             	add    $0x1,%ecx
  800b96:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b9b:	eb ce                	jmp    800b6b <strtol+0x44>
		s += 2, base = 16;
  800b9d:	83 c1 02             	add    $0x2,%ecx
  800ba0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ba5:	eb c4                	jmp    800b6b <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ba7:	0f be d2             	movsbl %dl,%edx
  800baa:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bad:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bb0:	7d 3a                	jge    800bec <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bb2:	83 c1 01             	add    $0x1,%ecx
  800bb5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb9:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bbb:	0f b6 11             	movzbl (%ecx),%edx
  800bbe:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bc1:	89 f3                	mov    %esi,%ebx
  800bc3:	80 fb 09             	cmp    $0x9,%bl
  800bc6:	76 df                	jbe    800ba7 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800bc8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bcb:	89 f3                	mov    %esi,%ebx
  800bcd:	80 fb 19             	cmp    $0x19,%bl
  800bd0:	77 08                	ja     800bda <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bd2:	0f be d2             	movsbl %dl,%edx
  800bd5:	83 ea 57             	sub    $0x57,%edx
  800bd8:	eb d3                	jmp    800bad <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800bda:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bdd:	89 f3                	mov    %esi,%ebx
  800bdf:	80 fb 19             	cmp    $0x19,%bl
  800be2:	77 08                	ja     800bec <strtol+0xc5>
			dig = *s - 'A' + 10;
  800be4:	0f be d2             	movsbl %dl,%edx
  800be7:	83 ea 37             	sub    $0x37,%edx
  800bea:	eb c1                	jmp    800bad <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf0:	74 05                	je     800bf7 <strtol+0xd0>
		*endptr = (char *) s;
  800bf2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bf7:	89 c2                	mov    %eax,%edx
  800bf9:	f7 da                	neg    %edx
  800bfb:	85 ff                	test   %edi,%edi
  800bfd:	0f 45 c2             	cmovne %edx,%eax
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	83 ec 1c             	sub    $0x1c,%esp
  800c0e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c11:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c14:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c19:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c1c:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c1f:	8b 75 14             	mov    0x14(%ebp),%esi
  800c22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c24:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c28:	74 04                	je     800c2e <syscall+0x29>
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	7f 08                	jg     800c36 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800c2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c36:	83 ec 0c             	sub    $0xc,%esp
  800c39:	50                   	push   %eax
  800c3a:	ff 75 e0             	pushl  -0x20(%ebp)
  800c3d:	68 7f 29 80 00       	push   $0x80297f
  800c42:	6a 23                	push   $0x23
  800c44:	68 9c 29 80 00       	push   $0x80299c
  800c49:	e8 f2 f5 ff ff       	call   800240 <_panic>

00800c4e <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800c4e:	f3 0f 1e fb          	endbr32 
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800c58:	6a 00                	push   $0x0
  800c5a:	6a 00                	push   $0x0
  800c5c:	6a 00                	push   $0x0
  800c5e:	ff 75 0c             	pushl  0xc(%ebp)
  800c61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c64:	ba 00 00 00 00       	mov    $0x0,%edx
  800c69:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6e:	e8 92 ff ff ff       	call   800c05 <syscall>
}
  800c73:	83 c4 10             	add    $0x10,%esp
  800c76:	c9                   	leave  
  800c77:	c3                   	ret    

00800c78 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c78:	f3 0f 1e fb          	endbr32 
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c82:	6a 00                	push   $0x0
  800c84:	6a 00                	push   $0x0
  800c86:	6a 00                	push   $0x0
  800c88:	6a 00                	push   $0x0
  800c8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c94:	b8 01 00 00 00       	mov    $0x1,%eax
  800c99:	e8 67 ff ff ff       	call   800c05 <syscall>
}
  800c9e:	c9                   	leave  
  800c9f:	c3                   	ret    

00800ca0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ca0:	f3 0f 1e fb          	endbr32 
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800caa:	6a 00                	push   $0x0
  800cac:	6a 00                	push   $0x0
  800cae:	6a 00                	push   $0x0
  800cb0:	6a 00                	push   $0x0
  800cb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb5:	ba 01 00 00 00       	mov    $0x1,%edx
  800cba:	b8 03 00 00 00       	mov    $0x3,%eax
  800cbf:	e8 41 ff ff ff       	call   800c05 <syscall>
}
  800cc4:	c9                   	leave  
  800cc5:	c3                   	ret    

00800cc6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cc6:	f3 0f 1e fb          	endbr32 
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800cd0:	6a 00                	push   $0x0
  800cd2:	6a 00                	push   $0x0
  800cd4:	6a 00                	push   $0x0
  800cd6:	6a 00                	push   $0x0
  800cd8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce7:	e8 19 ff ff ff       	call   800c05 <syscall>
}
  800cec:	c9                   	leave  
  800ced:	c3                   	ret    

00800cee <sys_yield>:

void
sys_yield(void)
{
  800cee:	f3 0f 1e fb          	endbr32 
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800cf8:	6a 00                	push   $0x0
  800cfa:	6a 00                	push   $0x0
  800cfc:	6a 00                	push   $0x0
  800cfe:	6a 00                	push   $0x0
  800d00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d05:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0f:	e8 f1 fe ff ff       	call   800c05 <syscall>
}
  800d14:	83 c4 10             	add    $0x10,%esp
  800d17:	c9                   	leave  
  800d18:	c3                   	ret    

00800d19 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d19:	f3 0f 1e fb          	endbr32 
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d23:	6a 00                	push   $0x0
  800d25:	6a 00                	push   $0x0
  800d27:	ff 75 10             	pushl  0x10(%ebp)
  800d2a:	ff 75 0c             	pushl  0xc(%ebp)
  800d2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d30:	ba 01 00 00 00       	mov    $0x1,%edx
  800d35:	b8 04 00 00 00       	mov    $0x4,%eax
  800d3a:	e8 c6 fe ff ff       	call   800c05 <syscall>
}
  800d3f:	c9                   	leave  
  800d40:	c3                   	ret    

00800d41 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d41:	f3 0f 1e fb          	endbr32 
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800d4b:	ff 75 18             	pushl  0x18(%ebp)
  800d4e:	ff 75 14             	pushl  0x14(%ebp)
  800d51:	ff 75 10             	pushl  0x10(%ebp)
  800d54:	ff 75 0c             	pushl  0xc(%ebp)
  800d57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5a:	ba 01 00 00 00       	mov    $0x1,%edx
  800d5f:	b8 05 00 00 00       	mov    $0x5,%eax
  800d64:	e8 9c fe ff ff       	call   800c05 <syscall>
}
  800d69:	c9                   	leave  
  800d6a:	c3                   	ret    

00800d6b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d6b:	f3 0f 1e fb          	endbr32 
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d75:	6a 00                	push   $0x0
  800d77:	6a 00                	push   $0x0
  800d79:	6a 00                	push   $0x0
  800d7b:	ff 75 0c             	pushl  0xc(%ebp)
  800d7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d81:	ba 01 00 00 00       	mov    $0x1,%edx
  800d86:	b8 06 00 00 00       	mov    $0x6,%eax
  800d8b:	e8 75 fe ff ff       	call   800c05 <syscall>
}
  800d90:	c9                   	leave  
  800d91:	c3                   	ret    

00800d92 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d92:	f3 0f 1e fb          	endbr32 
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d9c:	6a 00                	push   $0x0
  800d9e:	6a 00                	push   $0x0
  800da0:	6a 00                	push   $0x0
  800da2:	ff 75 0c             	pushl  0xc(%ebp)
  800da5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da8:	ba 01 00 00 00       	mov    $0x1,%edx
  800dad:	b8 08 00 00 00       	mov    $0x8,%eax
  800db2:	e8 4e fe ff ff       	call   800c05 <syscall>
}
  800db7:	c9                   	leave  
  800db8:	c3                   	ret    

00800db9 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db9:	f3 0f 1e fb          	endbr32 
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800dc3:	6a 00                	push   $0x0
  800dc5:	6a 00                	push   $0x0
  800dc7:	6a 00                	push   $0x0
  800dc9:	ff 75 0c             	pushl  0xc(%ebp)
  800dcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dcf:	ba 01 00 00 00       	mov    $0x1,%edx
  800dd4:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd9:	e8 27 fe ff ff       	call   800c05 <syscall>
}
  800dde:	c9                   	leave  
  800ddf:	c3                   	ret    

00800de0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de0:	f3 0f 1e fb          	endbr32 
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800dea:	6a 00                	push   $0x0
  800dec:	6a 00                	push   $0x0
  800dee:	6a 00                	push   $0x0
  800df0:	ff 75 0c             	pushl  0xc(%ebp)
  800df3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df6:	ba 01 00 00 00       	mov    $0x1,%edx
  800dfb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e00:	e8 00 fe ff ff       	call   800c05 <syscall>
}
  800e05:	c9                   	leave  
  800e06:	c3                   	ret    

00800e07 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e07:	f3 0f 1e fb          	endbr32 
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e11:	6a 00                	push   $0x0
  800e13:	ff 75 14             	pushl  0x14(%ebp)
  800e16:	ff 75 10             	pushl  0x10(%ebp)
  800e19:	ff 75 0c             	pushl  0xc(%ebp)
  800e1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e24:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e29:	e8 d7 fd ff ff       	call   800c05 <syscall>
}
  800e2e:	c9                   	leave  
  800e2f:	c3                   	ret    

00800e30 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e30:	f3 0f 1e fb          	endbr32 
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e3a:	6a 00                	push   $0x0
  800e3c:	6a 00                	push   $0x0
  800e3e:	6a 00                	push   $0x0
  800e40:	6a 00                	push   $0x0
  800e42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e45:	ba 01 00 00 00       	mov    $0x1,%edx
  800e4a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e4f:	e8 b1 fd ff ff       	call   800c05 <syscall>
}
  800e54:	c9                   	leave  
  800e55:	c3                   	ret    

00800e56 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	53                   	push   %ebx
  800e5a:	83 ec 04             	sub    $0x4,%esp
	int r;

	// LAB 4: Your code here.
	void *addr = (void *) (pn * PGSIZE);
  800e5d:	89 d3                	mov    %edx,%ebx
  800e5f:	c1 e3 0c             	shl    $0xc,%ebx

	if (uvpt[pn] & PTE_SHARE) {
  800e62:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e69:	f6 c5 04             	test   $0x4,%ch
  800e6c:	75 56                	jne    800ec4 <duppage+0x6e>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
		return 0;
	}

	if ((uvpt[pn] & (PTE_W | PTE_COW)) != 0) {
  800e6e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e75:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800e7b:	74 72                	je     800eef <duppage+0x99>
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW) <
  800e7d:	83 ec 0c             	sub    $0xc,%esp
  800e80:	68 05 08 00 00       	push   $0x805
  800e85:	53                   	push   %ebx
  800e86:	50                   	push   %eax
  800e87:	53                   	push   %ebx
  800e88:	6a 00                	push   $0x0
  800e8a:	e8 b2 fe ff ff       	call   800d41 <sys_page_map>
  800e8f:	83 c4 20             	add    $0x20,%esp
  800e92:	85 c0                	test   %eax,%eax
  800e94:	78 45                	js     800edb <duppage+0x85>
		    0) {
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
		}
		if (sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW) < 0) {
  800e96:	83 ec 0c             	sub    $0xc,%esp
  800e99:	68 05 08 00 00       	push   $0x805
  800e9e:	53                   	push   %ebx
  800e9f:	6a 00                	push   $0x0
  800ea1:	53                   	push   %ebx
  800ea2:	6a 00                	push   $0x0
  800ea4:	e8 98 fe ff ff       	call   800d41 <sys_page_map>
  800ea9:	83 c4 20             	add    $0x20,%esp
  800eac:	85 c0                	test   %eax,%eax
  800eae:	79 55                	jns    800f05 <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP FATHER");
  800eb0:	83 ec 04             	sub    $0x4,%esp
  800eb3:	68 cc 29 80 00       	push   $0x8029cc
  800eb8:	6a 54                	push   $0x54
  800eba:	68 5f 2a 80 00       	push   $0x802a5f
  800ebf:	e8 7c f3 ff ff       	call   800240 <_panic>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800ec4:	83 ec 0c             	sub    $0xc,%esp
  800ec7:	68 07 0e 00 00       	push   $0xe07
  800ecc:	53                   	push   %ebx
  800ecd:	50                   	push   %eax
  800ece:	53                   	push   %ebx
  800ecf:	6a 00                	push   $0x0
  800ed1:	e8 6b fe ff ff       	call   800d41 <sys_page_map>
		return 0;
  800ed6:	83 c4 20             	add    $0x20,%esp
  800ed9:	eb 2a                	jmp    800f05 <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
  800edb:	83 ec 04             	sub    $0x4,%esp
  800ede:	68 ac 29 80 00       	push   $0x8029ac
  800ee3:	6a 51                	push   $0x51
  800ee5:	68 5f 2a 80 00       	push   $0x802a5f
  800eea:	e8 51 f3 ff ff       	call   800240 <_panic>
		}
	} else {
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U) < 0) {
  800eef:	83 ec 0c             	sub    $0xc,%esp
  800ef2:	6a 05                	push   $0x5
  800ef4:	53                   	push   %ebx
  800ef5:	50                   	push   %eax
  800ef6:	53                   	push   %ebx
  800ef7:	6a 00                	push   $0x0
  800ef9:	e8 43 fe ff ff       	call   800d41 <sys_page_map>
  800efe:	83 c4 20             	add    $0x20,%esp
  800f01:	85 c0                	test   %eax,%eax
  800f03:	78 0a                	js     800f0f <duppage+0xb9>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
		}
	}

	return 0;
}
  800f05:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f0d:	c9                   	leave  
  800f0e:	c3                   	ret    
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
  800f0f:	83 ec 04             	sub    $0x4,%esp
  800f12:	68 6a 2a 80 00       	push   $0x802a6a
  800f17:	6a 58                	push   $0x58
  800f19:	68 5f 2a 80 00       	push   $0x802a5f
  800f1e:	e8 1d f3 ff ff       	call   800240 <_panic>

00800f23 <dup_or_share>:

static void
dup_or_share(envid_t dstenv, void *va, int perm)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	56                   	push   %esi
  800f27:	53                   	push   %ebx
  800f28:	89 c6                	mov    %eax,%esi
  800f2a:	89 d3                	mov    %edx,%ebx
	int r;
	if (perm & PTE_W) {
  800f2c:	f6 c1 02             	test   $0x2,%cl
  800f2f:	0f 84 8c 00 00 00    	je     800fc1 <dup_or_share+0x9e>
		// dup
		if ((r = sys_page_alloc(dstenv, va, PTE_P | PTE_U | PTE_W)) < 0)
  800f35:	83 ec 04             	sub    $0x4,%esp
  800f38:	6a 07                	push   $0x7
  800f3a:	52                   	push   %edx
  800f3b:	50                   	push   %eax
  800f3c:	e8 d8 fd ff ff       	call   800d19 <sys_page_alloc>
  800f41:	83 c4 10             	add    $0x10,%esp
  800f44:	85 c0                	test   %eax,%eax
  800f46:	78 55                	js     800f9d <dup_or_share+0x7a>
			panic("sys_page_alloc: %e", r);
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  800f48:	83 ec 0c             	sub    $0xc,%esp
  800f4b:	6a 07                	push   $0x7
  800f4d:	68 00 00 40 00       	push   $0x400000
  800f52:	6a 00                	push   $0x0
  800f54:	53                   	push   %ebx
  800f55:	56                   	push   %esi
  800f56:	e8 e6 fd ff ff       	call   800d41 <sys_page_map>
  800f5b:	83 c4 20             	add    $0x20,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	78 4d                	js     800faf <dup_or_share+0x8c>
		    0)
			panic("sys_page_map: %e", r);
		memmove(UTEMP, va, PGSIZE);
  800f62:	83 ec 04             	sub    $0x4,%esp
  800f65:	68 00 10 00 00       	push   $0x1000
  800f6a:	53                   	push   %ebx
  800f6b:	68 00 00 40 00       	push   $0x400000
  800f70:	e8 d4 fa ff ff       	call   800a49 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800f75:	83 c4 08             	add    $0x8,%esp
  800f78:	68 00 00 40 00       	push   $0x400000
  800f7d:	6a 00                	push   $0x0
  800f7f:	e8 e7 fd ff ff       	call   800d6b <sys_page_unmap>
  800f84:	83 c4 10             	add    $0x10,%esp
  800f87:	85 c0                	test   %eax,%eax
  800f89:	79 52                	jns    800fdd <dup_or_share+0xba>
			panic("sys_page_unmap: %e", r);
  800f8b:	50                   	push   %eax
  800f8c:	68 aa 2a 80 00       	push   $0x802aaa
  800f91:	6a 6c                	push   $0x6c
  800f93:	68 5f 2a 80 00       	push   $0x802a5f
  800f98:	e8 a3 f2 ff ff       	call   800240 <_panic>
			panic("sys_page_alloc: %e", r);
  800f9d:	50                   	push   %eax
  800f9e:	68 86 2a 80 00       	push   $0x802a86
  800fa3:	6a 66                	push   $0x66
  800fa5:	68 5f 2a 80 00       	push   $0x802a5f
  800faa:	e8 91 f2 ff ff       	call   800240 <_panic>
			panic("sys_page_map: %e", r);
  800faf:	50                   	push   %eax
  800fb0:	68 99 2a 80 00       	push   $0x802a99
  800fb5:	6a 69                	push   $0x69
  800fb7:	68 5f 2a 80 00       	push   $0x802a5f
  800fbc:	e8 7f f2 ff ff       	call   800240 <_panic>

	} else {
		// share
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | perm)) <
  800fc1:	83 ec 0c             	sub    $0xc,%esp
  800fc4:	83 c9 05             	or     $0x5,%ecx
  800fc7:	51                   	push   %ecx
  800fc8:	68 00 00 40 00       	push   $0x400000
  800fcd:	6a 00                	push   $0x0
  800fcf:	52                   	push   %edx
  800fd0:	50                   	push   %eax
  800fd1:	e8 6b fd ff ff       	call   800d41 <sys_page_map>
  800fd6:	83 c4 20             	add    $0x20,%esp
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	78 07                	js     800fe4 <dup_or_share+0xc1>
		    0)
			panic("sys_page_map: %e", r);
	}
}
  800fdd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fe0:	5b                   	pop    %ebx
  800fe1:	5e                   	pop    %esi
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    
			panic("sys_page_map: %e", r);
  800fe4:	50                   	push   %eax
  800fe5:	68 99 2a 80 00       	push   $0x802a99
  800fea:	6a 72                	push   $0x72
  800fec:	68 5f 2a 80 00       	push   $0x802a5f
  800ff1:	e8 4a f2 ff ff       	call   800240 <_panic>

00800ff6 <pgfault>:
{
  800ff6:	f3 0f 1e fb          	endbr32 
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	53                   	push   %ebx
  800ffe:	83 ec 04             	sub    $0x4,%esp
  801001:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  801004:	8b 02                	mov    (%edx),%eax
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  801006:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  80100a:	0f 84 95 00 00 00    	je     8010a5 <pgfault+0xaf>
  801010:	89 c2                	mov    %eax,%edx
  801012:	c1 ea 16             	shr    $0x16,%edx
  801015:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80101c:	f6 c2 01             	test   $0x1,%dl
  80101f:	0f 84 80 00 00 00    	je     8010a5 <pgfault+0xaf>
	    (~uvpt[PGNUM(addr)] & (PTE_COW | PTE_P)) != 0) {
  801025:	89 c2                	mov    %eax,%edx
  801027:	c1 ea 0c             	shr    $0xc,%edx
  80102a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801031:	f7 d2                	not    %edx
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  801033:	f7 c2 01 08 00 00    	test   $0x801,%edx
  801039:	75 6a                	jne    8010a5 <pgfault+0xaf>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  80103b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801040:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U) < 0) {
  801042:	83 ec 04             	sub    $0x4,%esp
  801045:	6a 07                	push   $0x7
  801047:	68 00 f0 7f 00       	push   $0x7ff000
  80104c:	6a 00                	push   $0x0
  80104e:	e8 c6 fc ff ff       	call   800d19 <sys_page_alloc>
  801053:	83 c4 10             	add    $0x10,%esp
  801056:	85 c0                	test   %eax,%eax
  801058:	78 5f                	js     8010b9 <pgfault+0xc3>
	memcpy((void *) PFTEMP, addr, PGSIZE);
  80105a:	83 ec 04             	sub    $0x4,%esp
  80105d:	68 00 10 00 00       	push   $0x1000
  801062:	53                   	push   %ebx
  801063:	68 00 f0 7f 00       	push   $0x7ff000
  801068:	e8 42 fa ff ff       	call   800aaf <memcpy>
	if (sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U) < 0) {
  80106d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801074:	53                   	push   %ebx
  801075:	6a 00                	push   $0x0
  801077:	68 00 f0 7f 00       	push   $0x7ff000
  80107c:	6a 00                	push   $0x0
  80107e:	e8 be fc ff ff       	call   800d41 <sys_page_map>
  801083:	83 c4 20             	add    $0x20,%esp
  801086:	85 c0                	test   %eax,%eax
  801088:	78 43                	js     8010cd <pgfault+0xd7>
	if (sys_page_unmap(0, (void *) PFTEMP) < 0) {
  80108a:	83 ec 08             	sub    $0x8,%esp
  80108d:	68 00 f0 7f 00       	push   $0x7ff000
  801092:	6a 00                	push   $0x0
  801094:	e8 d2 fc ff ff       	call   800d6b <sys_page_unmap>
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	85 c0                	test   %eax,%eax
  80109e:	78 41                	js     8010e1 <pgfault+0xeb>
}
  8010a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a3:	c9                   	leave  
  8010a4:	c3                   	ret    
		panic("ERROR PGFAULT");
  8010a5:	83 ec 04             	sub    $0x4,%esp
  8010a8:	68 bd 2a 80 00       	push   $0x802abd
  8010ad:	6a 1e                	push   $0x1e
  8010af:	68 5f 2a 80 00       	push   $0x802a5f
  8010b4:	e8 87 f1 ff ff       	call   800240 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_ALLOC");
  8010b9:	83 ec 04             	sub    $0x4,%esp
  8010bc:	68 cb 2a 80 00       	push   $0x802acb
  8010c1:	6a 2b                	push   $0x2b
  8010c3:	68 5f 2a 80 00       	push   $0x802a5f
  8010c8:	e8 73 f1 ff ff       	call   800240 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_MAP");
  8010cd:	83 ec 04             	sub    $0x4,%esp
  8010d0:	68 e9 2a 80 00       	push   $0x802ae9
  8010d5:	6a 2f                	push   $0x2f
  8010d7:	68 5f 2a 80 00       	push   $0x802a5f
  8010dc:	e8 5f f1 ff ff       	call   800240 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_UNMAP");
  8010e1:	83 ec 04             	sub    $0x4,%esp
  8010e4:	68 05 2b 80 00       	push   $0x802b05
  8010e9:	6a 32                	push   $0x32
  8010eb:	68 5f 2a 80 00       	push   $0x802a5f
  8010f0:	e8 4b f1 ff ff       	call   800240 <_panic>

008010f5 <fork_v0>:

envid_t
fork_v0(void)
{
  8010f5:	f3 0f 1e fb          	endbr32 
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	57                   	push   %edi
  8010fd:	56                   	push   %esi
  8010fe:	53                   	push   %ebx
  8010ff:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801102:	b8 07 00 00 00       	mov    $0x7,%eax
  801107:	cd 30                	int    $0x30
	envid_t env_id = sys_exofork();
	if (env_id < 0) {
  801109:	85 c0                	test   %eax,%eax
  80110b:	78 24                	js     801131 <fork_v0+0x3c>
  80110d:	89 c6                	mov    %eax,%esi
  80110f:	89 c7                	mov    %eax,%edi
		thisenv = envs + ENVX(sys_getenvid());
		return env_id;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801111:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (env_id == 0) {  // Son
  801116:	75 51                	jne    801169 <fork_v0+0x74>
		thisenv = envs + ENVX(sys_getenvid());
  801118:	e8 a9 fb ff ff       	call   800cc6 <sys_getenvid>
  80111d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801122:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801125:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80112a:	a3 20 44 80 00       	mov    %eax,0x804420
		return env_id;
  80112f:	eb 78                	jmp    8011a9 <fork_v0+0xb4>
		panic("ERROR ON FORK_V0");
  801131:	83 ec 04             	sub    $0x4,%esp
  801134:	68 23 2b 80 00       	push   $0x802b23
  801139:	6a 7b                	push   $0x7b
  80113b:	68 5f 2a 80 00       	push   $0x802a5f
  801140:	e8 fb f0 ff ff       	call   800240 <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
				dup_or_share(env_id,
  801145:	b9 07 00 00 00       	mov    $0x7,%ecx
  80114a:	89 da                	mov    %ebx,%edx
  80114c:	89 f8                	mov    %edi,%eax
  80114e:	e8 d0 fd ff ff       	call   800f23 <dup_or_share>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801153:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801159:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  80115f:	77 36                	ja     801197 <fork_v0+0xa2>
		if (addr != UXSTACKTOP - PGSIZE) {
  801161:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801167:	74 ea                	je     801153 <fork_v0+0x5e>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801169:	89 d8                	mov    %ebx,%eax
  80116b:	c1 e8 16             	shr    $0x16,%eax
  80116e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801175:	a8 01                	test   $0x1,%al
  801177:	74 da                	je     801153 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  801179:	89 d8                	mov    %ebx,%eax
  80117b:	c1 e8 0c             	shr    $0xc,%eax
  80117e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801185:	f6 c2 01             	test   $0x1,%dl
  801188:	74 c9                	je     801153 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
  80118a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  801191:	a8 04                	test   $0x4,%al
  801193:	74 be                	je     801153 <fork_v0+0x5e>
  801195:	eb ae                	jmp    801145 <fork_v0+0x50>
				             PTE_P | PTE_U | PTE_W);
			}
		}
	}

	if (sys_env_set_status(env_id, ENV_RUNNABLE) < 0) {
  801197:	83 ec 08             	sub    $0x8,%esp
  80119a:	6a 02                	push   $0x2
  80119c:	56                   	push   %esi
  80119d:	e8 f0 fb ff ff       	call   800d92 <sys_env_set_status>
  8011a2:	83 c4 10             	add    $0x10,%esp
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	78 0a                	js     8011b3 <fork_v0+0xbe>
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
	}

	return env_id;
}
  8011a9:	89 f0                	mov    %esi,%eax
  8011ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ae:	5b                   	pop    %ebx
  8011af:	5e                   	pop    %esi
  8011b0:	5f                   	pop    %edi
  8011b1:	5d                   	pop    %ebp
  8011b2:	c3                   	ret    
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
  8011b3:	83 ec 04             	sub    $0x4,%esp
  8011b6:	68 f0 29 80 00       	push   $0x8029f0
  8011bb:	68 92 00 00 00       	push   $0x92
  8011c0:	68 5f 2a 80 00       	push   $0x802a5f
  8011c5:	e8 76 f0 ff ff       	call   800240 <_panic>

008011ca <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011ca:	f3 0f 1e fb          	endbr32 
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	57                   	push   %edi
  8011d2:	56                   	push   %esi
  8011d3:	53                   	push   %ebx
  8011d4:	83 ec 18             	sub    $0x18,%esp
	// return fork_v0(); // Uncomment this line if you want to run fork_v0.
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8011d7:	68 f6 0f 80 00       	push   $0x800ff6
  8011dc:	e8 fe 0e 00 00       	call   8020df <set_pgfault_handler>
  8011e1:	b8 07 00 00 00       	mov    $0x7,%eax
  8011e6:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0) {
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	78 27                	js     801216 <fork+0x4c>
  8011ef:	89 c7                	mov    %eax,%edi
  8011f1:	89 c6                	mov    %eax,%esi
		thisenv = envs + ENVX(sys_getenvid());
		return envid;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  8011f3:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else if (envid == 0) {  // Son
  8011f8:	75 55                	jne    80124f <fork+0x85>
		thisenv = envs + ENVX(sys_getenvid());
  8011fa:	e8 c7 fa ff ff       	call   800cc6 <sys_getenvid>
  8011ff:	25 ff 03 00 00       	and    $0x3ff,%eax
  801204:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801207:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80120c:	a3 20 44 80 00       	mov    %eax,0x804420
		return envid;
  801211:	e9 9b 00 00 00       	jmp    8012b1 <fork+0xe7>
		panic("ERROR IN FORK: SYS_EXOFORK");
  801216:	83 ec 04             	sub    $0x4,%esp
  801219:	68 34 2b 80 00       	push   $0x802b34
  80121e:	68 b1 00 00 00       	push   $0xb1
  801223:	68 5f 2a 80 00       	push   $0x802a5f
  801228:	e8 13 f0 ff ff       	call   800240 <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
				duppage(envid, addr / PGSIZE);
  80122d:	89 da                	mov    %ebx,%edx
  80122f:	c1 ea 0c             	shr    $0xc,%edx
  801232:	89 f0                	mov    %esi,%eax
  801234:	e8 1d fc ff ff       	call   800e56 <duppage>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801239:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80123f:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801245:	77 2c                	ja     801273 <fork+0xa9>
		if (addr != UXSTACKTOP - PGSIZE) {
  801247:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80124d:	74 ea                	je     801239 <fork+0x6f>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80124f:	89 d8                	mov    %ebx,%eax
  801251:	c1 e8 16             	shr    $0x16,%eax
  801254:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80125b:	a8 01                	test   $0x1,%al
  80125d:	74 da                	je     801239 <fork+0x6f>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
  80125f:	89 d8                	mov    %ebx,%eax
  801261:	c1 e8 0c             	shr    $0xc,%eax
  801264:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80126b:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80126d:	a8 05                	test   $0x5,%al
  80126f:	75 c8                	jne    801239 <fork+0x6f>
  801271:	eb ba                	jmp    80122d <fork+0x63>
			}
		}
	}

	if (sys_page_alloc(envid,
  801273:	83 ec 04             	sub    $0x4,%esp
  801276:	6a 07                	push   $0x7
  801278:	68 00 f0 bf ee       	push   $0xeebff000
  80127d:	57                   	push   %edi
  80127e:	e8 96 fa ff ff       	call   800d19 <sys_page_alloc>
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	78 31                	js     8012bb <fork+0xf1>
	                   PTE_P | PTE_U | PTE_W) < 0) {
		panic("ERROR FORK: SYS_PAGE_ALLOC");
	}

	extern void _pgfault_upcall(void);
	if (sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0) {
  80128a:	83 ec 08             	sub    $0x8,%esp
  80128d:	68 52 21 80 00       	push   $0x802152
  801292:	57                   	push   %edi
  801293:	e8 48 fb ff ff       	call   800de0 <sys_env_set_pgfault_upcall>
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 33                	js     8012d2 <fork+0x108>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
	}

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0) {
  80129f:	83 ec 08             	sub    $0x8,%esp
  8012a2:	6a 02                	push   $0x2
  8012a4:	57                   	push   %edi
  8012a5:	e8 e8 fa ff ff       	call   800d92 <sys_env_set_status>
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 38                	js     8012e9 <fork+0x11f>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
	}

	return envid;
}
  8012b1:	89 f8                	mov    %edi,%eax
  8012b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b6:	5b                   	pop    %ebx
  8012b7:	5e                   	pop    %esi
  8012b8:	5f                   	pop    %edi
  8012b9:	5d                   	pop    %ebp
  8012ba:	c3                   	ret    
		panic("ERROR FORK: SYS_PAGE_ALLOC");
  8012bb:	83 ec 04             	sub    $0x4,%esp
  8012be:	68 4f 2b 80 00       	push   $0x802b4f
  8012c3:	68 c4 00 00 00       	push   $0xc4
  8012c8:	68 5f 2a 80 00       	push   $0x802a5f
  8012cd:	e8 6e ef ff ff       	call   800240 <_panic>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
  8012d2:	83 ec 04             	sub    $0x4,%esp
  8012d5:	68 18 2a 80 00       	push   $0x802a18
  8012da:	68 c9 00 00 00       	push   $0xc9
  8012df:	68 5f 2a 80 00       	push   $0x802a5f
  8012e4:	e8 57 ef ff ff       	call   800240 <_panic>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
  8012e9:	83 ec 04             	sub    $0x4,%esp
  8012ec:	68 40 2a 80 00       	push   $0x802a40
  8012f1:	68 cd 00 00 00       	push   $0xcd
  8012f6:	68 5f 2a 80 00       	push   $0x802a5f
  8012fb:	e8 40 ef ff ff       	call   800240 <_panic>

00801300 <sfork>:

// Challenge!
int
sfork(void)
{
  801300:	f3 0f 1e fb          	endbr32 
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80130a:	68 6a 2b 80 00       	push   $0x802b6a
  80130f:	68 d7 00 00 00       	push   $0xd7
  801314:	68 5f 2a 80 00       	push   $0x802a5f
  801319:	e8 22 ef ff ff       	call   800240 <_panic>

0080131e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80131e:	f3 0f 1e fb          	endbr32 
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801325:	8b 45 08             	mov    0x8(%ebp),%eax
  801328:	05 00 00 00 30       	add    $0x30000000,%eax
  80132d:	c1 e8 0c             	shr    $0xc,%eax
}
  801330:	5d                   	pop    %ebp
  801331:	c3                   	ret    

00801332 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801332:	f3 0f 1e fb          	endbr32 
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  80133c:	ff 75 08             	pushl  0x8(%ebp)
  80133f:	e8 da ff ff ff       	call   80131e <fd2num>
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	c1 e0 0c             	shl    $0xc,%eax
  80134a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80134f:	c9                   	leave  
  801350:	c3                   	ret    

00801351 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801351:	f3 0f 1e fb          	endbr32 
  801355:	55                   	push   %ebp
  801356:	89 e5                	mov    %esp,%ebp
  801358:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80135d:	89 c2                	mov    %eax,%edx
  80135f:	c1 ea 16             	shr    $0x16,%edx
  801362:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801369:	f6 c2 01             	test   $0x1,%dl
  80136c:	74 2d                	je     80139b <fd_alloc+0x4a>
  80136e:	89 c2                	mov    %eax,%edx
  801370:	c1 ea 0c             	shr    $0xc,%edx
  801373:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80137a:	f6 c2 01             	test   $0x1,%dl
  80137d:	74 1c                	je     80139b <fd_alloc+0x4a>
  80137f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801384:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801389:	75 d2                	jne    80135d <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80138b:	8b 45 08             	mov    0x8(%ebp),%eax
  80138e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801394:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801399:	eb 0a                	jmp    8013a5 <fd_alloc+0x54>
			*fd_store = fd;
  80139b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80139e:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013a5:	5d                   	pop    %ebp
  8013a6:	c3                   	ret    

008013a7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013a7:	f3 0f 1e fb          	endbr32 
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013b1:	83 f8 1f             	cmp    $0x1f,%eax
  8013b4:	77 30                	ja     8013e6 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013b6:	c1 e0 0c             	shl    $0xc,%eax
  8013b9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013be:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8013c4:	f6 c2 01             	test   $0x1,%dl
  8013c7:	74 24                	je     8013ed <fd_lookup+0x46>
  8013c9:	89 c2                	mov    %eax,%edx
  8013cb:	c1 ea 0c             	shr    $0xc,%edx
  8013ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013d5:	f6 c2 01             	test   $0x1,%dl
  8013d8:	74 1a                	je     8013f4 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013dd:	89 02                	mov    %eax,(%edx)
	return 0;
  8013df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    
		return -E_INVAL;
  8013e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013eb:	eb f7                	jmp    8013e4 <fd_lookup+0x3d>
		return -E_INVAL;
  8013ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f2:	eb f0                	jmp    8013e4 <fd_lookup+0x3d>
  8013f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013f9:	eb e9                	jmp    8013e4 <fd_lookup+0x3d>

008013fb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013fb:	f3 0f 1e fb          	endbr32 
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801408:	ba fc 2b 80 00       	mov    $0x802bfc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80140d:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801412:	39 08                	cmp    %ecx,(%eax)
  801414:	74 33                	je     801449 <dev_lookup+0x4e>
  801416:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801419:	8b 02                	mov    (%edx),%eax
  80141b:	85 c0                	test   %eax,%eax
  80141d:	75 f3                	jne    801412 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80141f:	a1 20 44 80 00       	mov    0x804420,%eax
  801424:	8b 40 48             	mov    0x48(%eax),%eax
  801427:	83 ec 04             	sub    $0x4,%esp
  80142a:	51                   	push   %ecx
  80142b:	50                   	push   %eax
  80142c:	68 80 2b 80 00       	push   $0x802b80
  801431:	e8 f1 ee ff ff       	call   800327 <cprintf>
	*dev = 0;
  801436:	8b 45 0c             	mov    0xc(%ebp),%eax
  801439:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80143f:	83 c4 10             	add    $0x10,%esp
  801442:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801447:	c9                   	leave  
  801448:	c3                   	ret    
			*dev = devtab[i];
  801449:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80144c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80144e:	b8 00 00 00 00       	mov    $0x0,%eax
  801453:	eb f2                	jmp    801447 <dev_lookup+0x4c>

00801455 <fd_close>:
{
  801455:	f3 0f 1e fb          	endbr32 
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	57                   	push   %edi
  80145d:	56                   	push   %esi
  80145e:	53                   	push   %ebx
  80145f:	83 ec 28             	sub    $0x28,%esp
  801462:	8b 75 08             	mov    0x8(%ebp),%esi
  801465:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801468:	56                   	push   %esi
  801469:	e8 b0 fe ff ff       	call   80131e <fd2num>
  80146e:	83 c4 08             	add    $0x8,%esp
  801471:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801474:	52                   	push   %edx
  801475:	50                   	push   %eax
  801476:	e8 2c ff ff ff       	call   8013a7 <fd_lookup>
  80147b:	89 c3                	mov    %eax,%ebx
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	85 c0                	test   %eax,%eax
  801482:	78 05                	js     801489 <fd_close+0x34>
	    || fd != fd2)
  801484:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801487:	74 16                	je     80149f <fd_close+0x4a>
		return (must_exist ? r : 0);
  801489:	89 f8                	mov    %edi,%eax
  80148b:	84 c0                	test   %al,%al
  80148d:	b8 00 00 00 00       	mov    $0x0,%eax
  801492:	0f 44 d8             	cmove  %eax,%ebx
}
  801495:	89 d8                	mov    %ebx,%eax
  801497:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149a:	5b                   	pop    %ebx
  80149b:	5e                   	pop    %esi
  80149c:	5f                   	pop    %edi
  80149d:	5d                   	pop    %ebp
  80149e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80149f:	83 ec 08             	sub    $0x8,%esp
  8014a2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8014a5:	50                   	push   %eax
  8014a6:	ff 36                	pushl  (%esi)
  8014a8:	e8 4e ff ff ff       	call   8013fb <dev_lookup>
  8014ad:	89 c3                	mov    %eax,%ebx
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	78 1a                	js     8014d0 <fd_close+0x7b>
		if (dev->dev_close)
  8014b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014b9:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8014bc:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	74 0b                	je     8014d0 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8014c5:	83 ec 0c             	sub    $0xc,%esp
  8014c8:	56                   	push   %esi
  8014c9:	ff d0                	call   *%eax
  8014cb:	89 c3                	mov    %eax,%ebx
  8014cd:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8014d0:	83 ec 08             	sub    $0x8,%esp
  8014d3:	56                   	push   %esi
  8014d4:	6a 00                	push   $0x0
  8014d6:	e8 90 f8 ff ff       	call   800d6b <sys_page_unmap>
	return r;
  8014db:	83 c4 10             	add    $0x10,%esp
  8014de:	eb b5                	jmp    801495 <fd_close+0x40>

008014e0 <close>:

int
close(int fdnum)
{
  8014e0:	f3 0f 1e fb          	endbr32 
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ed:	50                   	push   %eax
  8014ee:	ff 75 08             	pushl  0x8(%ebp)
  8014f1:	e8 b1 fe ff ff       	call   8013a7 <fd_lookup>
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	79 02                	jns    8014ff <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8014fd:	c9                   	leave  
  8014fe:	c3                   	ret    
		return fd_close(fd, 1);
  8014ff:	83 ec 08             	sub    $0x8,%esp
  801502:	6a 01                	push   $0x1
  801504:	ff 75 f4             	pushl  -0xc(%ebp)
  801507:	e8 49 ff ff ff       	call   801455 <fd_close>
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	eb ec                	jmp    8014fd <close+0x1d>

00801511 <close_all>:

void
close_all(void)
{
  801511:	f3 0f 1e fb          	endbr32 
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	53                   	push   %ebx
  801519:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80151c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801521:	83 ec 0c             	sub    $0xc,%esp
  801524:	53                   	push   %ebx
  801525:	e8 b6 ff ff ff       	call   8014e0 <close>
	for (i = 0; i < MAXFD; i++)
  80152a:	83 c3 01             	add    $0x1,%ebx
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	83 fb 20             	cmp    $0x20,%ebx
  801533:	75 ec                	jne    801521 <close_all+0x10>
}
  801535:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801538:	c9                   	leave  
  801539:	c3                   	ret    

0080153a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80153a:	f3 0f 1e fb          	endbr32 
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	57                   	push   %edi
  801542:	56                   	push   %esi
  801543:	53                   	push   %ebx
  801544:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801547:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	ff 75 08             	pushl  0x8(%ebp)
  80154e:	e8 54 fe ff ff       	call   8013a7 <fd_lookup>
  801553:	89 c3                	mov    %eax,%ebx
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	85 c0                	test   %eax,%eax
  80155a:	0f 88 81 00 00 00    	js     8015e1 <dup+0xa7>
		return r;
	close(newfdnum);
  801560:	83 ec 0c             	sub    $0xc,%esp
  801563:	ff 75 0c             	pushl  0xc(%ebp)
  801566:	e8 75 ff ff ff       	call   8014e0 <close>

	newfd = INDEX2FD(newfdnum);
  80156b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80156e:	c1 e6 0c             	shl    $0xc,%esi
  801571:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801577:	83 c4 04             	add    $0x4,%esp
  80157a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80157d:	e8 b0 fd ff ff       	call   801332 <fd2data>
  801582:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801584:	89 34 24             	mov    %esi,(%esp)
  801587:	e8 a6 fd ff ff       	call   801332 <fd2data>
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801591:	89 d8                	mov    %ebx,%eax
  801593:	c1 e8 16             	shr    $0x16,%eax
  801596:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80159d:	a8 01                	test   $0x1,%al
  80159f:	74 11                	je     8015b2 <dup+0x78>
  8015a1:	89 d8                	mov    %ebx,%eax
  8015a3:	c1 e8 0c             	shr    $0xc,%eax
  8015a6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015ad:	f6 c2 01             	test   $0x1,%dl
  8015b0:	75 39                	jne    8015eb <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015b5:	89 d0                	mov    %edx,%eax
  8015b7:	c1 e8 0c             	shr    $0xc,%eax
  8015ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015c1:	83 ec 0c             	sub    $0xc,%esp
  8015c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8015c9:	50                   	push   %eax
  8015ca:	56                   	push   %esi
  8015cb:	6a 00                	push   $0x0
  8015cd:	52                   	push   %edx
  8015ce:	6a 00                	push   $0x0
  8015d0:	e8 6c f7 ff ff       	call   800d41 <sys_page_map>
  8015d5:	89 c3                	mov    %eax,%ebx
  8015d7:	83 c4 20             	add    $0x20,%esp
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 31                	js     80160f <dup+0xd5>
		goto err;

	return newfdnum;
  8015de:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015e1:	89 d8                	mov    %ebx,%eax
  8015e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e6:	5b                   	pop    %ebx
  8015e7:	5e                   	pop    %esi
  8015e8:	5f                   	pop    %edi
  8015e9:	5d                   	pop    %ebp
  8015ea:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015eb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015f2:	83 ec 0c             	sub    $0xc,%esp
  8015f5:	25 07 0e 00 00       	and    $0xe07,%eax
  8015fa:	50                   	push   %eax
  8015fb:	57                   	push   %edi
  8015fc:	6a 00                	push   $0x0
  8015fe:	53                   	push   %ebx
  8015ff:	6a 00                	push   $0x0
  801601:	e8 3b f7 ff ff       	call   800d41 <sys_page_map>
  801606:	89 c3                	mov    %eax,%ebx
  801608:	83 c4 20             	add    $0x20,%esp
  80160b:	85 c0                	test   %eax,%eax
  80160d:	79 a3                	jns    8015b2 <dup+0x78>
	sys_page_unmap(0, newfd);
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	56                   	push   %esi
  801613:	6a 00                	push   $0x0
  801615:	e8 51 f7 ff ff       	call   800d6b <sys_page_unmap>
	sys_page_unmap(0, nva);
  80161a:	83 c4 08             	add    $0x8,%esp
  80161d:	57                   	push   %edi
  80161e:	6a 00                	push   $0x0
  801620:	e8 46 f7 ff ff       	call   800d6b <sys_page_unmap>
	return r;
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	eb b7                	jmp    8015e1 <dup+0xa7>

0080162a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80162a:	f3 0f 1e fb          	endbr32 
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	53                   	push   %ebx
  801632:	83 ec 1c             	sub    $0x1c,%esp
  801635:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801638:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163b:	50                   	push   %eax
  80163c:	53                   	push   %ebx
  80163d:	e8 65 fd ff ff       	call   8013a7 <fd_lookup>
  801642:	83 c4 10             	add    $0x10,%esp
  801645:	85 c0                	test   %eax,%eax
  801647:	78 3f                	js     801688 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801649:	83 ec 08             	sub    $0x8,%esp
  80164c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164f:	50                   	push   %eax
  801650:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801653:	ff 30                	pushl  (%eax)
  801655:	e8 a1 fd ff ff       	call   8013fb <dev_lookup>
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	85 c0                	test   %eax,%eax
  80165f:	78 27                	js     801688 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801661:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801664:	8b 42 08             	mov    0x8(%edx),%eax
  801667:	83 e0 03             	and    $0x3,%eax
  80166a:	83 f8 01             	cmp    $0x1,%eax
  80166d:	74 1e                	je     80168d <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80166f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801672:	8b 40 08             	mov    0x8(%eax),%eax
  801675:	85 c0                	test   %eax,%eax
  801677:	74 35                	je     8016ae <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801679:	83 ec 04             	sub    $0x4,%esp
  80167c:	ff 75 10             	pushl  0x10(%ebp)
  80167f:	ff 75 0c             	pushl  0xc(%ebp)
  801682:	52                   	push   %edx
  801683:	ff d0                	call   *%eax
  801685:	83 c4 10             	add    $0x10,%esp
}
  801688:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168b:	c9                   	leave  
  80168c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80168d:	a1 20 44 80 00       	mov    0x804420,%eax
  801692:	8b 40 48             	mov    0x48(%eax),%eax
  801695:	83 ec 04             	sub    $0x4,%esp
  801698:	53                   	push   %ebx
  801699:	50                   	push   %eax
  80169a:	68 c1 2b 80 00       	push   $0x802bc1
  80169f:	e8 83 ec ff ff       	call   800327 <cprintf>
		return -E_INVAL;
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ac:	eb da                	jmp    801688 <read+0x5e>
		return -E_NOT_SUPP;
  8016ae:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016b3:	eb d3                	jmp    801688 <read+0x5e>

008016b5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016b5:	f3 0f 1e fb          	endbr32 
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	57                   	push   %edi
  8016bd:	56                   	push   %esi
  8016be:	53                   	push   %ebx
  8016bf:	83 ec 0c             	sub    $0xc,%esp
  8016c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016c5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016cd:	eb 02                	jmp    8016d1 <readn+0x1c>
  8016cf:	01 c3                	add    %eax,%ebx
  8016d1:	39 f3                	cmp    %esi,%ebx
  8016d3:	73 21                	jae    8016f6 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016d5:	83 ec 04             	sub    $0x4,%esp
  8016d8:	89 f0                	mov    %esi,%eax
  8016da:	29 d8                	sub    %ebx,%eax
  8016dc:	50                   	push   %eax
  8016dd:	89 d8                	mov    %ebx,%eax
  8016df:	03 45 0c             	add    0xc(%ebp),%eax
  8016e2:	50                   	push   %eax
  8016e3:	57                   	push   %edi
  8016e4:	e8 41 ff ff ff       	call   80162a <read>
		if (m < 0)
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 04                	js     8016f4 <readn+0x3f>
			return m;
		if (m == 0)
  8016f0:	75 dd                	jne    8016cf <readn+0x1a>
  8016f2:	eb 02                	jmp    8016f6 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016f4:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8016f6:	89 d8                	mov    %ebx,%eax
  8016f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016fb:	5b                   	pop    %ebx
  8016fc:	5e                   	pop    %esi
  8016fd:	5f                   	pop    %edi
  8016fe:	5d                   	pop    %ebp
  8016ff:	c3                   	ret    

00801700 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801700:	f3 0f 1e fb          	endbr32 
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	53                   	push   %ebx
  801708:	83 ec 1c             	sub    $0x1c,%esp
  80170b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80170e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801711:	50                   	push   %eax
  801712:	53                   	push   %ebx
  801713:	e8 8f fc ff ff       	call   8013a7 <fd_lookup>
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	85 c0                	test   %eax,%eax
  80171d:	78 3a                	js     801759 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171f:	83 ec 08             	sub    $0x8,%esp
  801722:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801725:	50                   	push   %eax
  801726:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801729:	ff 30                	pushl  (%eax)
  80172b:	e8 cb fc ff ff       	call   8013fb <dev_lookup>
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	85 c0                	test   %eax,%eax
  801735:	78 22                	js     801759 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801737:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80173e:	74 1e                	je     80175e <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801740:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801743:	8b 52 0c             	mov    0xc(%edx),%edx
  801746:	85 d2                	test   %edx,%edx
  801748:	74 35                	je     80177f <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80174a:	83 ec 04             	sub    $0x4,%esp
  80174d:	ff 75 10             	pushl  0x10(%ebp)
  801750:	ff 75 0c             	pushl  0xc(%ebp)
  801753:	50                   	push   %eax
  801754:	ff d2                	call   *%edx
  801756:	83 c4 10             	add    $0x10,%esp
}
  801759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175c:	c9                   	leave  
  80175d:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80175e:	a1 20 44 80 00       	mov    0x804420,%eax
  801763:	8b 40 48             	mov    0x48(%eax),%eax
  801766:	83 ec 04             	sub    $0x4,%esp
  801769:	53                   	push   %ebx
  80176a:	50                   	push   %eax
  80176b:	68 dd 2b 80 00       	push   $0x802bdd
  801770:	e8 b2 eb ff ff       	call   800327 <cprintf>
		return -E_INVAL;
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80177d:	eb da                	jmp    801759 <write+0x59>
		return -E_NOT_SUPP;
  80177f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801784:	eb d3                	jmp    801759 <write+0x59>

00801786 <seek>:

int
seek(int fdnum, off_t offset)
{
  801786:	f3 0f 1e fb          	endbr32 
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801790:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801793:	50                   	push   %eax
  801794:	ff 75 08             	pushl  0x8(%ebp)
  801797:	e8 0b fc ff ff       	call   8013a7 <fd_lookup>
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	78 0e                	js     8017b1 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8017a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017b3:	f3 0f 1e fb          	endbr32 
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	53                   	push   %ebx
  8017bb:	83 ec 1c             	sub    $0x1c,%esp
  8017be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c4:	50                   	push   %eax
  8017c5:	53                   	push   %ebx
  8017c6:	e8 dc fb ff ff       	call   8013a7 <fd_lookup>
  8017cb:	83 c4 10             	add    $0x10,%esp
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	78 37                	js     801809 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d2:	83 ec 08             	sub    $0x8,%esp
  8017d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d8:	50                   	push   %eax
  8017d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017dc:	ff 30                	pushl  (%eax)
  8017de:	e8 18 fc ff ff       	call   8013fb <dev_lookup>
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 1f                	js     801809 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017f1:	74 1b                	je     80180e <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8017f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017f6:	8b 52 18             	mov    0x18(%edx),%edx
  8017f9:	85 d2                	test   %edx,%edx
  8017fb:	74 32                	je     80182f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017fd:	83 ec 08             	sub    $0x8,%esp
  801800:	ff 75 0c             	pushl  0xc(%ebp)
  801803:	50                   	push   %eax
  801804:	ff d2                	call   *%edx
  801806:	83 c4 10             	add    $0x10,%esp
}
  801809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180c:	c9                   	leave  
  80180d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80180e:	a1 20 44 80 00       	mov    0x804420,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801813:	8b 40 48             	mov    0x48(%eax),%eax
  801816:	83 ec 04             	sub    $0x4,%esp
  801819:	53                   	push   %ebx
  80181a:	50                   	push   %eax
  80181b:	68 a0 2b 80 00       	push   $0x802ba0
  801820:	e8 02 eb ff ff       	call   800327 <cprintf>
		return -E_INVAL;
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80182d:	eb da                	jmp    801809 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80182f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801834:	eb d3                	jmp    801809 <ftruncate+0x56>

00801836 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801836:	f3 0f 1e fb          	endbr32 
  80183a:	55                   	push   %ebp
  80183b:	89 e5                	mov    %esp,%ebp
  80183d:	53                   	push   %ebx
  80183e:	83 ec 1c             	sub    $0x1c,%esp
  801841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801847:	50                   	push   %eax
  801848:	ff 75 08             	pushl  0x8(%ebp)
  80184b:	e8 57 fb ff ff       	call   8013a7 <fd_lookup>
  801850:	83 c4 10             	add    $0x10,%esp
  801853:	85 c0                	test   %eax,%eax
  801855:	78 4b                	js     8018a2 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801857:	83 ec 08             	sub    $0x8,%esp
  80185a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185d:	50                   	push   %eax
  80185e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801861:	ff 30                	pushl  (%eax)
  801863:	e8 93 fb ff ff       	call   8013fb <dev_lookup>
  801868:	83 c4 10             	add    $0x10,%esp
  80186b:	85 c0                	test   %eax,%eax
  80186d:	78 33                	js     8018a2 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80186f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801872:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801876:	74 2f                	je     8018a7 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801878:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80187b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801882:	00 00 00 
	stat->st_isdir = 0;
  801885:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80188c:	00 00 00 
	stat->st_dev = dev;
  80188f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801895:	83 ec 08             	sub    $0x8,%esp
  801898:	53                   	push   %ebx
  801899:	ff 75 f0             	pushl  -0x10(%ebp)
  80189c:	ff 50 14             	call   *0x14(%eax)
  80189f:	83 c4 10             	add    $0x10,%esp
}
  8018a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    
		return -E_NOT_SUPP;
  8018a7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018ac:	eb f4                	jmp    8018a2 <fstat+0x6c>

008018ae <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018ae:	f3 0f 1e fb          	endbr32 
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	56                   	push   %esi
  8018b6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018b7:	83 ec 08             	sub    $0x8,%esp
  8018ba:	6a 00                	push   $0x0
  8018bc:	ff 75 08             	pushl  0x8(%ebp)
  8018bf:	e8 20 02 00 00       	call   801ae4 <open>
  8018c4:	89 c3                	mov    %eax,%ebx
  8018c6:	83 c4 10             	add    $0x10,%esp
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	78 1b                	js     8018e8 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8018cd:	83 ec 08             	sub    $0x8,%esp
  8018d0:	ff 75 0c             	pushl  0xc(%ebp)
  8018d3:	50                   	push   %eax
  8018d4:	e8 5d ff ff ff       	call   801836 <fstat>
  8018d9:	89 c6                	mov    %eax,%esi
	close(fd);
  8018db:	89 1c 24             	mov    %ebx,(%esp)
  8018de:	e8 fd fb ff ff       	call   8014e0 <close>
	return r;
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	89 f3                	mov    %esi,%ebx
}
  8018e8:	89 d8                	mov    %ebx,%eax
  8018ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ed:	5b                   	pop    %ebx
  8018ee:	5e                   	pop    %esi
  8018ef:	5d                   	pop    %ebp
  8018f0:	c3                   	ret    

008018f1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	56                   	push   %esi
  8018f5:	53                   	push   %ebx
  8018f6:	89 c6                	mov    %eax,%esi
  8018f8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018fa:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801901:	74 27                	je     80192a <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801903:	6a 07                	push   $0x7
  801905:	68 00 50 80 00       	push   $0x805000
  80190a:	56                   	push   %esi
  80190b:	ff 35 00 40 80 00    	pushl  0x804000
  801911:	e8 cf 08 00 00       	call   8021e5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801916:	83 c4 0c             	add    $0xc,%esp
  801919:	6a 00                	push   $0x0
  80191b:	53                   	push   %ebx
  80191c:	6a 00                	push   $0x0
  80191e:	e8 55 08 00 00       	call   802178 <ipc_recv>
}
  801923:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801926:	5b                   	pop    %ebx
  801927:	5e                   	pop    %esi
  801928:	5d                   	pop    %ebp
  801929:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80192a:	83 ec 0c             	sub    $0xc,%esp
  80192d:	6a 01                	push   $0x1
  80192f:	e8 04 09 00 00       	call   802238 <ipc_find_env>
  801934:	a3 00 40 80 00       	mov    %eax,0x804000
  801939:	83 c4 10             	add    $0x10,%esp
  80193c:	eb c5                	jmp    801903 <fsipc+0x12>

0080193e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80193e:	f3 0f 1e fb          	endbr32 
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801948:	8b 45 08             	mov    0x8(%ebp),%eax
  80194b:	8b 40 0c             	mov    0xc(%eax),%eax
  80194e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801953:	8b 45 0c             	mov    0xc(%ebp),%eax
  801956:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80195b:	ba 00 00 00 00       	mov    $0x0,%edx
  801960:	b8 02 00 00 00       	mov    $0x2,%eax
  801965:	e8 87 ff ff ff       	call   8018f1 <fsipc>
}
  80196a:	c9                   	leave  
  80196b:	c3                   	ret    

0080196c <devfile_flush>:
{
  80196c:	f3 0f 1e fb          	endbr32 
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801976:	8b 45 08             	mov    0x8(%ebp),%eax
  801979:	8b 40 0c             	mov    0xc(%eax),%eax
  80197c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801981:	ba 00 00 00 00       	mov    $0x0,%edx
  801986:	b8 06 00 00 00       	mov    $0x6,%eax
  80198b:	e8 61 ff ff ff       	call   8018f1 <fsipc>
}
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <devfile_stat>:
{
  801992:	f3 0f 1e fb          	endbr32 
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	53                   	push   %ebx
  80199a:	83 ec 04             	sub    $0x4,%esp
  80199d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8019a6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8019b5:	e8 37 ff ff ff       	call   8018f1 <fsipc>
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	78 2c                	js     8019ea <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019be:	83 ec 08             	sub    $0x8,%esp
  8019c1:	68 00 50 80 00       	push   $0x805000
  8019c6:	53                   	push   %ebx
  8019c7:	e8 c5 ee ff ff       	call   800891 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019cc:	a1 80 50 80 00       	mov    0x805080,%eax
  8019d1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019d7:	a1 84 50 80 00       	mov    0x805084,%eax
  8019dc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019e2:	83 c4 10             	add    $0x10,%esp
  8019e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ed:	c9                   	leave  
  8019ee:	c3                   	ret    

008019ef <devfile_write>:
{
  8019ef:	f3 0f 1e fb          	endbr32 
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	57                   	push   %edi
  8019f7:	56                   	push   %esi
  8019f8:	53                   	push   %ebx
  8019f9:	83 ec 0c             	sub    $0xc,%esp
  8019fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a02:	8b 45 08             	mov    0x8(%ebp),%eax
  801a05:	8b 40 0c             	mov    0xc(%eax),%eax
  801a08:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  801a0d:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a12:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  801a17:	85 db                	test   %ebx,%ebx
  801a19:	74 3b                	je     801a56 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a1b:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801a21:	89 f8                	mov    %edi,%eax
  801a23:	0f 46 c3             	cmovbe %ebx,%eax
  801a26:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  801a2b:	83 ec 04             	sub    $0x4,%esp
  801a2e:	50                   	push   %eax
  801a2f:	56                   	push   %esi
  801a30:	68 08 50 80 00       	push   $0x805008
  801a35:	e8 0f f0 ff ff       	call   800a49 <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3f:	b8 04 00 00 00       	mov    $0x4,%eax
  801a44:	e8 a8 fe ff ff       	call   8018f1 <fsipc>
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	85 c0                	test   %eax,%eax
  801a4e:	78 06                	js     801a56 <devfile_write+0x67>
		buf_aux += r;
  801a50:	01 c6                	add    %eax,%esi
		n -= r;
  801a52:	29 c3                	sub    %eax,%ebx
  801a54:	eb c1                	jmp    801a17 <devfile_write+0x28>
}
  801a56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a59:	5b                   	pop    %ebx
  801a5a:	5e                   	pop    %esi
  801a5b:	5f                   	pop    %edi
  801a5c:	5d                   	pop    %ebp
  801a5d:	c3                   	ret    

00801a5e <devfile_read>:
{
  801a5e:	f3 0f 1e fb          	endbr32 
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	56                   	push   %esi
  801a66:	53                   	push   %ebx
  801a67:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a70:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a75:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a80:	b8 03 00 00 00       	mov    $0x3,%eax
  801a85:	e8 67 fe ff ff       	call   8018f1 <fsipc>
  801a8a:	89 c3                	mov    %eax,%ebx
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	78 1f                	js     801aaf <devfile_read+0x51>
	assert(r <= n);
  801a90:	39 f0                	cmp    %esi,%eax
  801a92:	77 24                	ja     801ab8 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801a94:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a99:	7f 33                	jg     801ace <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a9b:	83 ec 04             	sub    $0x4,%esp
  801a9e:	50                   	push   %eax
  801a9f:	68 00 50 80 00       	push   $0x805000
  801aa4:	ff 75 0c             	pushl  0xc(%ebp)
  801aa7:	e8 9d ef ff ff       	call   800a49 <memmove>
	return r;
  801aac:	83 c4 10             	add    $0x10,%esp
}
  801aaf:	89 d8                	mov    %ebx,%eax
  801ab1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab4:	5b                   	pop    %ebx
  801ab5:	5e                   	pop    %esi
  801ab6:	5d                   	pop    %ebp
  801ab7:	c3                   	ret    
	assert(r <= n);
  801ab8:	68 0c 2c 80 00       	push   $0x802c0c
  801abd:	68 13 2c 80 00       	push   $0x802c13
  801ac2:	6a 7c                	push   $0x7c
  801ac4:	68 28 2c 80 00       	push   $0x802c28
  801ac9:	e8 72 e7 ff ff       	call   800240 <_panic>
	assert(r <= PGSIZE);
  801ace:	68 33 2c 80 00       	push   $0x802c33
  801ad3:	68 13 2c 80 00       	push   $0x802c13
  801ad8:	6a 7d                	push   $0x7d
  801ada:	68 28 2c 80 00       	push   $0x802c28
  801adf:	e8 5c e7 ff ff       	call   800240 <_panic>

00801ae4 <open>:
{
  801ae4:	f3 0f 1e fb          	endbr32 
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	56                   	push   %esi
  801aec:	53                   	push   %ebx
  801aed:	83 ec 1c             	sub    $0x1c,%esp
  801af0:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801af3:	56                   	push   %esi
  801af4:	e8 55 ed ff ff       	call   80084e <strlen>
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b01:	7f 6c                	jg     801b6f <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801b03:	83 ec 0c             	sub    $0xc,%esp
  801b06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b09:	50                   	push   %eax
  801b0a:	e8 42 f8 ff ff       	call   801351 <fd_alloc>
  801b0f:	89 c3                	mov    %eax,%ebx
  801b11:	83 c4 10             	add    $0x10,%esp
  801b14:	85 c0                	test   %eax,%eax
  801b16:	78 3c                	js     801b54 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801b18:	83 ec 08             	sub    $0x8,%esp
  801b1b:	56                   	push   %esi
  801b1c:	68 00 50 80 00       	push   $0x805000
  801b21:	e8 6b ed ff ff       	call   800891 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b26:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b29:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b31:	b8 01 00 00 00       	mov    $0x1,%eax
  801b36:	e8 b6 fd ff ff       	call   8018f1 <fsipc>
  801b3b:	89 c3                	mov    %eax,%ebx
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	85 c0                	test   %eax,%eax
  801b42:	78 19                	js     801b5d <open+0x79>
	return fd2num(fd);
  801b44:	83 ec 0c             	sub    $0xc,%esp
  801b47:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4a:	e8 cf f7 ff ff       	call   80131e <fd2num>
  801b4f:	89 c3                	mov    %eax,%ebx
  801b51:	83 c4 10             	add    $0x10,%esp
}
  801b54:	89 d8                	mov    %ebx,%eax
  801b56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5d                   	pop    %ebp
  801b5c:	c3                   	ret    
		fd_close(fd, 0);
  801b5d:	83 ec 08             	sub    $0x8,%esp
  801b60:	6a 00                	push   $0x0
  801b62:	ff 75 f4             	pushl  -0xc(%ebp)
  801b65:	e8 eb f8 ff ff       	call   801455 <fd_close>
		return r;
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	eb e5                	jmp    801b54 <open+0x70>
		return -E_BAD_PATH;
  801b6f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801b74:	eb de                	jmp    801b54 <open+0x70>

00801b76 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b76:	f3 0f 1e fb          	endbr32 
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b80:	ba 00 00 00 00       	mov    $0x0,%edx
  801b85:	b8 08 00 00 00       	mov    $0x8,%eax
  801b8a:	e8 62 fd ff ff       	call   8018f1 <fsipc>
}
  801b8f:	c9                   	leave  
  801b90:	c3                   	ret    

00801b91 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b91:	f3 0f 1e fb          	endbr32 
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	56                   	push   %esi
  801b99:	53                   	push   %ebx
  801b9a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b9d:	83 ec 0c             	sub    $0xc,%esp
  801ba0:	ff 75 08             	pushl  0x8(%ebp)
  801ba3:	e8 8a f7 ff ff       	call   801332 <fd2data>
  801ba8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801baa:	83 c4 08             	add    $0x8,%esp
  801bad:	68 3f 2c 80 00       	push   $0x802c3f
  801bb2:	53                   	push   %ebx
  801bb3:	e8 d9 ec ff ff       	call   800891 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bb8:	8b 46 04             	mov    0x4(%esi),%eax
  801bbb:	2b 06                	sub    (%esi),%eax
  801bbd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bc3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bca:	00 00 00 
	stat->st_dev = &devpipe;
  801bcd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bd4:	30 80 00 
	return 0;
}
  801bd7:	b8 00 00 00 00       	mov    $0x0,%eax
  801bdc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bdf:	5b                   	pop    %ebx
  801be0:	5e                   	pop    %esi
  801be1:	5d                   	pop    %ebp
  801be2:	c3                   	ret    

00801be3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801be3:	f3 0f 1e fb          	endbr32 
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	53                   	push   %ebx
  801beb:	83 ec 0c             	sub    $0xc,%esp
  801bee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bf1:	53                   	push   %ebx
  801bf2:	6a 00                	push   $0x0
  801bf4:	e8 72 f1 ff ff       	call   800d6b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bf9:	89 1c 24             	mov    %ebx,(%esp)
  801bfc:	e8 31 f7 ff ff       	call   801332 <fd2data>
  801c01:	83 c4 08             	add    $0x8,%esp
  801c04:	50                   	push   %eax
  801c05:	6a 00                	push   $0x0
  801c07:	e8 5f f1 ff ff       	call   800d6b <sys_page_unmap>
}
  801c0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c0f:	c9                   	leave  
  801c10:	c3                   	ret    

00801c11 <_pipeisclosed>:
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	57                   	push   %edi
  801c15:	56                   	push   %esi
  801c16:	53                   	push   %ebx
  801c17:	83 ec 1c             	sub    $0x1c,%esp
  801c1a:	89 c7                	mov    %eax,%edi
  801c1c:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c1e:	a1 20 44 80 00       	mov    0x804420,%eax
  801c23:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c26:	83 ec 0c             	sub    $0xc,%esp
  801c29:	57                   	push   %edi
  801c2a:	e8 46 06 00 00       	call   802275 <pageref>
  801c2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c32:	89 34 24             	mov    %esi,(%esp)
  801c35:	e8 3b 06 00 00       	call   802275 <pageref>
		nn = thisenv->env_runs;
  801c3a:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801c40:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	39 cb                	cmp    %ecx,%ebx
  801c48:	74 1b                	je     801c65 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c4a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c4d:	75 cf                	jne    801c1e <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c4f:	8b 42 58             	mov    0x58(%edx),%eax
  801c52:	6a 01                	push   $0x1
  801c54:	50                   	push   %eax
  801c55:	53                   	push   %ebx
  801c56:	68 46 2c 80 00       	push   $0x802c46
  801c5b:	e8 c7 e6 ff ff       	call   800327 <cprintf>
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	eb b9                	jmp    801c1e <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c65:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c68:	0f 94 c0             	sete   %al
  801c6b:	0f b6 c0             	movzbl %al,%eax
}
  801c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c71:	5b                   	pop    %ebx
  801c72:	5e                   	pop    %esi
  801c73:	5f                   	pop    %edi
  801c74:	5d                   	pop    %ebp
  801c75:	c3                   	ret    

00801c76 <devpipe_write>:
{
  801c76:	f3 0f 1e fb          	endbr32 
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	57                   	push   %edi
  801c7e:	56                   	push   %esi
  801c7f:	53                   	push   %ebx
  801c80:	83 ec 28             	sub    $0x28,%esp
  801c83:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c86:	56                   	push   %esi
  801c87:	e8 a6 f6 ff ff       	call   801332 <fd2data>
  801c8c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c8e:	83 c4 10             	add    $0x10,%esp
  801c91:	bf 00 00 00 00       	mov    $0x0,%edi
  801c96:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c99:	74 4f                	je     801cea <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c9b:	8b 43 04             	mov    0x4(%ebx),%eax
  801c9e:	8b 0b                	mov    (%ebx),%ecx
  801ca0:	8d 51 20             	lea    0x20(%ecx),%edx
  801ca3:	39 d0                	cmp    %edx,%eax
  801ca5:	72 14                	jb     801cbb <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801ca7:	89 da                	mov    %ebx,%edx
  801ca9:	89 f0                	mov    %esi,%eax
  801cab:	e8 61 ff ff ff       	call   801c11 <_pipeisclosed>
  801cb0:	85 c0                	test   %eax,%eax
  801cb2:	75 3b                	jne    801cef <devpipe_write+0x79>
			sys_yield();
  801cb4:	e8 35 f0 ff ff       	call   800cee <sys_yield>
  801cb9:	eb e0                	jmp    801c9b <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cbe:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cc2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cc5:	89 c2                	mov    %eax,%edx
  801cc7:	c1 fa 1f             	sar    $0x1f,%edx
  801cca:	89 d1                	mov    %edx,%ecx
  801ccc:	c1 e9 1b             	shr    $0x1b,%ecx
  801ccf:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cd2:	83 e2 1f             	and    $0x1f,%edx
  801cd5:	29 ca                	sub    %ecx,%edx
  801cd7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cdb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cdf:	83 c0 01             	add    $0x1,%eax
  801ce2:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801ce5:	83 c7 01             	add    $0x1,%edi
  801ce8:	eb ac                	jmp    801c96 <devpipe_write+0x20>
	return i;
  801cea:	8b 45 10             	mov    0x10(%ebp),%eax
  801ced:	eb 05                	jmp    801cf4 <devpipe_write+0x7e>
				return 0;
  801cef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf7:	5b                   	pop    %ebx
  801cf8:	5e                   	pop    %esi
  801cf9:	5f                   	pop    %edi
  801cfa:	5d                   	pop    %ebp
  801cfb:	c3                   	ret    

00801cfc <devpipe_read>:
{
  801cfc:	f3 0f 1e fb          	endbr32 
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	57                   	push   %edi
  801d04:	56                   	push   %esi
  801d05:	53                   	push   %ebx
  801d06:	83 ec 18             	sub    $0x18,%esp
  801d09:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d0c:	57                   	push   %edi
  801d0d:	e8 20 f6 ff ff       	call   801332 <fd2data>
  801d12:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	be 00 00 00 00       	mov    $0x0,%esi
  801d1c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d1f:	75 14                	jne    801d35 <devpipe_read+0x39>
	return i;
  801d21:	8b 45 10             	mov    0x10(%ebp),%eax
  801d24:	eb 02                	jmp    801d28 <devpipe_read+0x2c>
				return i;
  801d26:	89 f0                	mov    %esi,%eax
}
  801d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d2b:	5b                   	pop    %ebx
  801d2c:	5e                   	pop    %esi
  801d2d:	5f                   	pop    %edi
  801d2e:	5d                   	pop    %ebp
  801d2f:	c3                   	ret    
			sys_yield();
  801d30:	e8 b9 ef ff ff       	call   800cee <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d35:	8b 03                	mov    (%ebx),%eax
  801d37:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d3a:	75 18                	jne    801d54 <devpipe_read+0x58>
			if (i > 0)
  801d3c:	85 f6                	test   %esi,%esi
  801d3e:	75 e6                	jne    801d26 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801d40:	89 da                	mov    %ebx,%edx
  801d42:	89 f8                	mov    %edi,%eax
  801d44:	e8 c8 fe ff ff       	call   801c11 <_pipeisclosed>
  801d49:	85 c0                	test   %eax,%eax
  801d4b:	74 e3                	je     801d30 <devpipe_read+0x34>
				return 0;
  801d4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d52:	eb d4                	jmp    801d28 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d54:	99                   	cltd   
  801d55:	c1 ea 1b             	shr    $0x1b,%edx
  801d58:	01 d0                	add    %edx,%eax
  801d5a:	83 e0 1f             	and    $0x1f,%eax
  801d5d:	29 d0                	sub    %edx,%eax
  801d5f:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d67:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d6a:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d6d:	83 c6 01             	add    $0x1,%esi
  801d70:	eb aa                	jmp    801d1c <devpipe_read+0x20>

00801d72 <pipe>:
{
  801d72:	f3 0f 1e fb          	endbr32 
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	56                   	push   %esi
  801d7a:	53                   	push   %ebx
  801d7b:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d81:	50                   	push   %eax
  801d82:	e8 ca f5 ff ff       	call   801351 <fd_alloc>
  801d87:	89 c3                	mov    %eax,%ebx
  801d89:	83 c4 10             	add    $0x10,%esp
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	0f 88 23 01 00 00    	js     801eb7 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d94:	83 ec 04             	sub    $0x4,%esp
  801d97:	68 07 04 00 00       	push   $0x407
  801d9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9f:	6a 00                	push   $0x0
  801da1:	e8 73 ef ff ff       	call   800d19 <sys_page_alloc>
  801da6:	89 c3                	mov    %eax,%ebx
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	85 c0                	test   %eax,%eax
  801dad:	0f 88 04 01 00 00    	js     801eb7 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801db3:	83 ec 0c             	sub    $0xc,%esp
  801db6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801db9:	50                   	push   %eax
  801dba:	e8 92 f5 ff ff       	call   801351 <fd_alloc>
  801dbf:	89 c3                	mov    %eax,%ebx
  801dc1:	83 c4 10             	add    $0x10,%esp
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	0f 88 db 00 00 00    	js     801ea7 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dcc:	83 ec 04             	sub    $0x4,%esp
  801dcf:	68 07 04 00 00       	push   $0x407
  801dd4:	ff 75 f0             	pushl  -0x10(%ebp)
  801dd7:	6a 00                	push   $0x0
  801dd9:	e8 3b ef ff ff       	call   800d19 <sys_page_alloc>
  801dde:	89 c3                	mov    %eax,%ebx
  801de0:	83 c4 10             	add    $0x10,%esp
  801de3:	85 c0                	test   %eax,%eax
  801de5:	0f 88 bc 00 00 00    	js     801ea7 <pipe+0x135>
	va = fd2data(fd0);
  801deb:	83 ec 0c             	sub    $0xc,%esp
  801dee:	ff 75 f4             	pushl  -0xc(%ebp)
  801df1:	e8 3c f5 ff ff       	call   801332 <fd2data>
  801df6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df8:	83 c4 0c             	add    $0xc,%esp
  801dfb:	68 07 04 00 00       	push   $0x407
  801e00:	50                   	push   %eax
  801e01:	6a 00                	push   $0x0
  801e03:	e8 11 ef ff ff       	call   800d19 <sys_page_alloc>
  801e08:	89 c3                	mov    %eax,%ebx
  801e0a:	83 c4 10             	add    $0x10,%esp
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	0f 88 82 00 00 00    	js     801e97 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e15:	83 ec 0c             	sub    $0xc,%esp
  801e18:	ff 75 f0             	pushl  -0x10(%ebp)
  801e1b:	e8 12 f5 ff ff       	call   801332 <fd2data>
  801e20:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e27:	50                   	push   %eax
  801e28:	6a 00                	push   $0x0
  801e2a:	56                   	push   %esi
  801e2b:	6a 00                	push   $0x0
  801e2d:	e8 0f ef ff ff       	call   800d41 <sys_page_map>
  801e32:	89 c3                	mov    %eax,%ebx
  801e34:	83 c4 20             	add    $0x20,%esp
  801e37:	85 c0                	test   %eax,%eax
  801e39:	78 4e                	js     801e89 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801e3b:	a1 20 30 80 00       	mov    0x803020,%eax
  801e40:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e43:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801e45:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e48:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e4f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e52:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801e54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e57:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e5e:	83 ec 0c             	sub    $0xc,%esp
  801e61:	ff 75 f4             	pushl  -0xc(%ebp)
  801e64:	e8 b5 f4 ff ff       	call   80131e <fd2num>
  801e69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e6c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e6e:	83 c4 04             	add    $0x4,%esp
  801e71:	ff 75 f0             	pushl  -0x10(%ebp)
  801e74:	e8 a5 f4 ff ff       	call   80131e <fd2num>
  801e79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e7c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e7f:	83 c4 10             	add    $0x10,%esp
  801e82:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e87:	eb 2e                	jmp    801eb7 <pipe+0x145>
	sys_page_unmap(0, va);
  801e89:	83 ec 08             	sub    $0x8,%esp
  801e8c:	56                   	push   %esi
  801e8d:	6a 00                	push   $0x0
  801e8f:	e8 d7 ee ff ff       	call   800d6b <sys_page_unmap>
  801e94:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e97:	83 ec 08             	sub    $0x8,%esp
  801e9a:	ff 75 f0             	pushl  -0x10(%ebp)
  801e9d:	6a 00                	push   $0x0
  801e9f:	e8 c7 ee ff ff       	call   800d6b <sys_page_unmap>
  801ea4:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801ea7:	83 ec 08             	sub    $0x8,%esp
  801eaa:	ff 75 f4             	pushl  -0xc(%ebp)
  801ead:	6a 00                	push   $0x0
  801eaf:	e8 b7 ee ff ff       	call   800d6b <sys_page_unmap>
  801eb4:	83 c4 10             	add    $0x10,%esp
}
  801eb7:	89 d8                	mov    %ebx,%eax
  801eb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ebc:	5b                   	pop    %ebx
  801ebd:	5e                   	pop    %esi
  801ebe:	5d                   	pop    %ebp
  801ebf:	c3                   	ret    

00801ec0 <pipeisclosed>:
{
  801ec0:	f3 0f 1e fb          	endbr32 
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ecd:	50                   	push   %eax
  801ece:	ff 75 08             	pushl  0x8(%ebp)
  801ed1:	e8 d1 f4 ff ff       	call   8013a7 <fd_lookup>
  801ed6:	83 c4 10             	add    $0x10,%esp
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	78 18                	js     801ef5 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801edd:	83 ec 0c             	sub    $0xc,%esp
  801ee0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee3:	e8 4a f4 ff ff       	call   801332 <fd2data>
  801ee8:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eed:	e8 1f fd ff ff       	call   801c11 <_pipeisclosed>
  801ef2:	83 c4 10             	add    $0x10,%esp
}
  801ef5:	c9                   	leave  
  801ef6:	c3                   	ret    

00801ef7 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801ef7:	f3 0f 1e fb          	endbr32 
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	56                   	push   %esi
  801eff:	53                   	push   %ebx
  801f00:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801f03:	85 f6                	test   %esi,%esi
  801f05:	74 13                	je     801f1a <wait+0x23>
	e = &envs[ENVX(envid)];
  801f07:	89 f3                	mov    %esi,%ebx
  801f09:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801f0f:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801f12:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801f18:	eb 1b                	jmp    801f35 <wait+0x3e>
	assert(envid != 0);
  801f1a:	68 5e 2c 80 00       	push   $0x802c5e
  801f1f:	68 13 2c 80 00       	push   $0x802c13
  801f24:	6a 09                	push   $0x9
  801f26:	68 69 2c 80 00       	push   $0x802c69
  801f2b:	e8 10 e3 ff ff       	call   800240 <_panic>
		sys_yield();
  801f30:	e8 b9 ed ff ff       	call   800cee <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801f35:	8b 43 48             	mov    0x48(%ebx),%eax
  801f38:	39 f0                	cmp    %esi,%eax
  801f3a:	75 07                	jne    801f43 <wait+0x4c>
  801f3c:	8b 43 54             	mov    0x54(%ebx),%eax
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	75 ed                	jne    801f30 <wait+0x39>
}
  801f43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f46:	5b                   	pop    %ebx
  801f47:	5e                   	pop    %esi
  801f48:	5d                   	pop    %ebp
  801f49:	c3                   	ret    

00801f4a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f4a:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801f4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f53:	c3                   	ret    

00801f54 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f54:	f3 0f 1e fb          	endbr32 
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f5e:	68 74 2c 80 00       	push   $0x802c74
  801f63:	ff 75 0c             	pushl  0xc(%ebp)
  801f66:	e8 26 e9 ff ff       	call   800891 <strcpy>
	return 0;
}
  801f6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f70:	c9                   	leave  
  801f71:	c3                   	ret    

00801f72 <devcons_write>:
{
  801f72:	f3 0f 1e fb          	endbr32 
  801f76:	55                   	push   %ebp
  801f77:	89 e5                	mov    %esp,%ebp
  801f79:	57                   	push   %edi
  801f7a:	56                   	push   %esi
  801f7b:	53                   	push   %ebx
  801f7c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f82:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f87:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f8d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f90:	73 31                	jae    801fc3 <devcons_write+0x51>
		m = n - tot;
  801f92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f95:	29 f3                	sub    %esi,%ebx
  801f97:	83 fb 7f             	cmp    $0x7f,%ebx
  801f9a:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f9f:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801fa2:	83 ec 04             	sub    $0x4,%esp
  801fa5:	53                   	push   %ebx
  801fa6:	89 f0                	mov    %esi,%eax
  801fa8:	03 45 0c             	add    0xc(%ebp),%eax
  801fab:	50                   	push   %eax
  801fac:	57                   	push   %edi
  801fad:	e8 97 ea ff ff       	call   800a49 <memmove>
		sys_cputs(buf, m);
  801fb2:	83 c4 08             	add    $0x8,%esp
  801fb5:	53                   	push   %ebx
  801fb6:	57                   	push   %edi
  801fb7:	e8 92 ec ff ff       	call   800c4e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801fbc:	01 de                	add    %ebx,%esi
  801fbe:	83 c4 10             	add    $0x10,%esp
  801fc1:	eb ca                	jmp    801f8d <devcons_write+0x1b>
}
  801fc3:	89 f0                	mov    %esi,%eax
  801fc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc8:	5b                   	pop    %ebx
  801fc9:	5e                   	pop    %esi
  801fca:	5f                   	pop    %edi
  801fcb:	5d                   	pop    %ebp
  801fcc:	c3                   	ret    

00801fcd <devcons_read>:
{
  801fcd:	f3 0f 1e fb          	endbr32 
  801fd1:	55                   	push   %ebp
  801fd2:	89 e5                	mov    %esp,%ebp
  801fd4:	83 ec 08             	sub    $0x8,%esp
  801fd7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801fdc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fe0:	74 21                	je     802003 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801fe2:	e8 91 ec ff ff       	call   800c78 <sys_cgetc>
  801fe7:	85 c0                	test   %eax,%eax
  801fe9:	75 07                	jne    801ff2 <devcons_read+0x25>
		sys_yield();
  801feb:	e8 fe ec ff ff       	call   800cee <sys_yield>
  801ff0:	eb f0                	jmp    801fe2 <devcons_read+0x15>
	if (c < 0)
  801ff2:	78 0f                	js     802003 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801ff4:	83 f8 04             	cmp    $0x4,%eax
  801ff7:	74 0c                	je     802005 <devcons_read+0x38>
	*(char*)vbuf = c;
  801ff9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ffc:	88 02                	mov    %al,(%edx)
	return 1;
  801ffe:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802003:	c9                   	leave  
  802004:	c3                   	ret    
		return 0;
  802005:	b8 00 00 00 00       	mov    $0x0,%eax
  80200a:	eb f7                	jmp    802003 <devcons_read+0x36>

0080200c <cputchar>:
{
  80200c:	f3 0f 1e fb          	endbr32 
  802010:	55                   	push   %ebp
  802011:	89 e5                	mov    %esp,%ebp
  802013:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802016:	8b 45 08             	mov    0x8(%ebp),%eax
  802019:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80201c:	6a 01                	push   $0x1
  80201e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802021:	50                   	push   %eax
  802022:	e8 27 ec ff ff       	call   800c4e <sys_cputs>
}
  802027:	83 c4 10             	add    $0x10,%esp
  80202a:	c9                   	leave  
  80202b:	c3                   	ret    

0080202c <getchar>:
{
  80202c:	f3 0f 1e fb          	endbr32 
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802036:	6a 01                	push   $0x1
  802038:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80203b:	50                   	push   %eax
  80203c:	6a 00                	push   $0x0
  80203e:	e8 e7 f5 ff ff       	call   80162a <read>
	if (r < 0)
  802043:	83 c4 10             	add    $0x10,%esp
  802046:	85 c0                	test   %eax,%eax
  802048:	78 06                	js     802050 <getchar+0x24>
	if (r < 1)
  80204a:	74 06                	je     802052 <getchar+0x26>
	return c;
  80204c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802050:	c9                   	leave  
  802051:	c3                   	ret    
		return -E_EOF;
  802052:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802057:	eb f7                	jmp    802050 <getchar+0x24>

00802059 <iscons>:
{
  802059:	f3 0f 1e fb          	endbr32 
  80205d:	55                   	push   %ebp
  80205e:	89 e5                	mov    %esp,%ebp
  802060:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802063:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802066:	50                   	push   %eax
  802067:	ff 75 08             	pushl  0x8(%ebp)
  80206a:	e8 38 f3 ff ff       	call   8013a7 <fd_lookup>
  80206f:	83 c4 10             	add    $0x10,%esp
  802072:	85 c0                	test   %eax,%eax
  802074:	78 11                	js     802087 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802076:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802079:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80207f:	39 10                	cmp    %edx,(%eax)
  802081:	0f 94 c0             	sete   %al
  802084:	0f b6 c0             	movzbl %al,%eax
}
  802087:	c9                   	leave  
  802088:	c3                   	ret    

00802089 <opencons>:
{
  802089:	f3 0f 1e fb          	endbr32 
  80208d:	55                   	push   %ebp
  80208e:	89 e5                	mov    %esp,%ebp
  802090:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802093:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802096:	50                   	push   %eax
  802097:	e8 b5 f2 ff ff       	call   801351 <fd_alloc>
  80209c:	83 c4 10             	add    $0x10,%esp
  80209f:	85 c0                	test   %eax,%eax
  8020a1:	78 3a                	js     8020dd <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020a3:	83 ec 04             	sub    $0x4,%esp
  8020a6:	68 07 04 00 00       	push   $0x407
  8020ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ae:	6a 00                	push   $0x0
  8020b0:	e8 64 ec ff ff       	call   800d19 <sys_page_alloc>
  8020b5:	83 c4 10             	add    $0x10,%esp
  8020b8:	85 c0                	test   %eax,%eax
  8020ba:	78 21                	js     8020dd <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8020bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020bf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020c5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ca:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020d1:	83 ec 0c             	sub    $0xc,%esp
  8020d4:	50                   	push   %eax
  8020d5:	e8 44 f2 ff ff       	call   80131e <fd2num>
  8020da:	83 c4 10             	add    $0x10,%esp
}
  8020dd:	c9                   	leave  
  8020de:	c3                   	ret    

008020df <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020df:	f3 0f 1e fb          	endbr32 
  8020e3:	55                   	push   %ebp
  8020e4:	89 e5                	mov    %esp,%ebp
  8020e6:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  8020e9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8020f0:	74 0a                	je     8020fc <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f5:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8020fa:	c9                   	leave  
  8020fb:	c3                   	ret    
		if (sys_page_alloc(0,
  8020fc:	83 ec 04             	sub    $0x4,%esp
  8020ff:	6a 07                	push   $0x7
  802101:	68 00 f0 bf ee       	push   $0xeebff000
  802106:	6a 00                	push   $0x0
  802108:	e8 0c ec ff ff       	call   800d19 <sys_page_alloc>
  80210d:	83 c4 10             	add    $0x10,%esp
  802110:	85 c0                	test   %eax,%eax
  802112:	78 2a                	js     80213e <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  802114:	83 ec 08             	sub    $0x8,%esp
  802117:	68 52 21 80 00       	push   $0x802152
  80211c:	6a 00                	push   $0x0
  80211e:	e8 bd ec ff ff       	call   800de0 <sys_env_set_pgfault_upcall>
  802123:	83 c4 10             	add    $0x10,%esp
  802126:	85 c0                	test   %eax,%eax
  802128:	79 c8                	jns    8020f2 <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  80212a:	83 ec 04             	sub    $0x4,%esp
  80212d:	68 b4 2c 80 00       	push   $0x802cb4
  802132:	6a 25                	push   $0x25
  802134:	68 fb 2c 80 00       	push   $0x802cfb
  802139:	e8 02 e1 ff ff       	call   800240 <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  80213e:	83 ec 04             	sub    $0x4,%esp
  802141:	68 80 2c 80 00       	push   $0x802c80
  802146:	6a 21                	push   $0x21
  802148:	68 fb 2c 80 00       	push   $0x802cfb
  80214d:	e8 ee e0 ff ff       	call   800240 <_panic>

00802152 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802152:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802153:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802158:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80215a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  80215d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  802162:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  802166:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80216a:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  80216c:	83 c4 08             	add    $0x8,%esp
	popal
  80216f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  802170:	83 c4 04             	add    $0x4,%esp
	popfl
  802173:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  802174:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802177:	c3                   	ret    

00802178 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802178:	f3 0f 1e fb          	endbr32 
  80217c:	55                   	push   %ebp
  80217d:	89 e5                	mov    %esp,%ebp
  80217f:	56                   	push   %esi
  802180:	53                   	push   %ebx
  802181:	8b 75 08             	mov    0x8(%ebp),%esi
  802184:	8b 45 0c             	mov    0xc(%ebp),%eax
  802187:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  80218a:	85 c0                	test   %eax,%eax
  80218c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802191:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  802194:	83 ec 0c             	sub    $0xc,%esp
  802197:	50                   	push   %eax
  802198:	e8 93 ec ff ff       	call   800e30 <sys_ipc_recv>
	if (f < 0) {
  80219d:	83 c4 10             	add    $0x10,%esp
  8021a0:	85 c0                	test   %eax,%eax
  8021a2:	78 2b                	js     8021cf <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  8021a4:	85 f6                	test   %esi,%esi
  8021a6:	74 0a                	je     8021b2 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  8021a8:	a1 20 44 80 00       	mov    0x804420,%eax
  8021ad:	8b 40 74             	mov    0x74(%eax),%eax
  8021b0:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  8021b2:	85 db                	test   %ebx,%ebx
  8021b4:	74 0a                	je     8021c0 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  8021b6:	a1 20 44 80 00       	mov    0x804420,%eax
  8021bb:	8b 40 78             	mov    0x78(%eax),%eax
  8021be:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  8021c0:	a1 20 44 80 00       	mov    0x804420,%eax
  8021c5:	8b 40 70             	mov    0x70(%eax),%eax
}
  8021c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021cb:	5b                   	pop    %ebx
  8021cc:	5e                   	pop    %esi
  8021cd:	5d                   	pop    %ebp
  8021ce:	c3                   	ret    
		if (from_env_store != NULL) {
  8021cf:	85 f6                	test   %esi,%esi
  8021d1:	74 06                	je     8021d9 <ipc_recv+0x61>
			*from_env_store = 0;
  8021d3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  8021d9:	85 db                	test   %ebx,%ebx
  8021db:	74 eb                	je     8021c8 <ipc_recv+0x50>
			*perm_store = 0;
  8021dd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8021e3:	eb e3                	jmp    8021c8 <ipc_recv+0x50>

008021e5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021e5:	f3 0f 1e fb          	endbr32 
  8021e9:	55                   	push   %ebp
  8021ea:	89 e5                	mov    %esp,%ebp
  8021ec:	57                   	push   %edi
  8021ed:	56                   	push   %esi
  8021ee:	53                   	push   %ebx
  8021ef:	83 ec 0c             	sub    $0xc,%esp
  8021f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  8021fb:	85 db                	test   %ebx,%ebx
  8021fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802202:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802205:	ff 75 14             	pushl  0x14(%ebp)
  802208:	53                   	push   %ebx
  802209:	56                   	push   %esi
  80220a:	57                   	push   %edi
  80220b:	e8 f7 eb ff ff       	call   800e07 <sys_ipc_try_send>
  802210:	83 c4 10             	add    $0x10,%esp
  802213:	85 c0                	test   %eax,%eax
  802215:	79 19                	jns    802230 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  802217:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80221a:	74 e9                	je     802205 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  80221c:	83 ec 04             	sub    $0x4,%esp
  80221f:	68 0c 2d 80 00       	push   $0x802d0c
  802224:	6a 48                	push   $0x48
  802226:	68 2e 2d 80 00       	push   $0x802d2e
  80222b:	e8 10 e0 ff ff       	call   800240 <_panic>
		}
	}
}
  802230:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802233:	5b                   	pop    %ebx
  802234:	5e                   	pop    %esi
  802235:	5f                   	pop    %edi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    

00802238 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802238:	f3 0f 1e fb          	endbr32 
  80223c:	55                   	push   %ebp
  80223d:	89 e5                	mov    %esp,%ebp
  80223f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802242:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802247:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80224a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802250:	8b 52 50             	mov    0x50(%edx),%edx
  802253:	39 ca                	cmp    %ecx,%edx
  802255:	74 11                	je     802268 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802257:	83 c0 01             	add    $0x1,%eax
  80225a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80225f:	75 e6                	jne    802247 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802261:	b8 00 00 00 00       	mov    $0x0,%eax
  802266:	eb 0b                	jmp    802273 <ipc_find_env+0x3b>
			return envs[i].env_id;
  802268:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80226b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802270:	8b 40 48             	mov    0x48(%eax),%eax
}
  802273:	5d                   	pop    %ebp
  802274:	c3                   	ret    

00802275 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802275:	f3 0f 1e fb          	endbr32 
  802279:	55                   	push   %ebp
  80227a:	89 e5                	mov    %esp,%ebp
  80227c:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80227f:	89 c2                	mov    %eax,%edx
  802281:	c1 ea 16             	shr    $0x16,%edx
  802284:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80228b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802290:	f6 c1 01             	test   $0x1,%cl
  802293:	74 1c                	je     8022b1 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802295:	c1 e8 0c             	shr    $0xc,%eax
  802298:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80229f:	a8 01                	test   $0x1,%al
  8022a1:	74 0e                	je     8022b1 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022a3:	c1 e8 0c             	shr    $0xc,%eax
  8022a6:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8022ad:	ef 
  8022ae:	0f b7 d2             	movzwl %dx,%edx
}
  8022b1:	89 d0                	mov    %edx,%eax
  8022b3:	5d                   	pop    %ebp
  8022b4:	c3                   	ret    
  8022b5:	66 90                	xchg   %ax,%ax
  8022b7:	66 90                	xchg   %ax,%ax
  8022b9:	66 90                	xchg   %ax,%ax
  8022bb:	66 90                	xchg   %ax,%ax
  8022bd:	66 90                	xchg   %ax,%ax
  8022bf:	90                   	nop

008022c0 <__udivdi3>:
  8022c0:	f3 0f 1e fb          	endbr32 
  8022c4:	55                   	push   %ebp
  8022c5:	57                   	push   %edi
  8022c6:	56                   	push   %esi
  8022c7:	53                   	push   %ebx
  8022c8:	83 ec 1c             	sub    $0x1c,%esp
  8022cb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8022d3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8022db:	85 d2                	test   %edx,%edx
  8022dd:	75 19                	jne    8022f8 <__udivdi3+0x38>
  8022df:	39 f3                	cmp    %esi,%ebx
  8022e1:	76 4d                	jbe    802330 <__udivdi3+0x70>
  8022e3:	31 ff                	xor    %edi,%edi
  8022e5:	89 e8                	mov    %ebp,%eax
  8022e7:	89 f2                	mov    %esi,%edx
  8022e9:	f7 f3                	div    %ebx
  8022eb:	89 fa                	mov    %edi,%edx
  8022ed:	83 c4 1c             	add    $0x1c,%esp
  8022f0:	5b                   	pop    %ebx
  8022f1:	5e                   	pop    %esi
  8022f2:	5f                   	pop    %edi
  8022f3:	5d                   	pop    %ebp
  8022f4:	c3                   	ret    
  8022f5:	8d 76 00             	lea    0x0(%esi),%esi
  8022f8:	39 f2                	cmp    %esi,%edx
  8022fa:	76 14                	jbe    802310 <__udivdi3+0x50>
  8022fc:	31 ff                	xor    %edi,%edi
  8022fe:	31 c0                	xor    %eax,%eax
  802300:	89 fa                	mov    %edi,%edx
  802302:	83 c4 1c             	add    $0x1c,%esp
  802305:	5b                   	pop    %ebx
  802306:	5e                   	pop    %esi
  802307:	5f                   	pop    %edi
  802308:	5d                   	pop    %ebp
  802309:	c3                   	ret    
  80230a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802310:	0f bd fa             	bsr    %edx,%edi
  802313:	83 f7 1f             	xor    $0x1f,%edi
  802316:	75 48                	jne    802360 <__udivdi3+0xa0>
  802318:	39 f2                	cmp    %esi,%edx
  80231a:	72 06                	jb     802322 <__udivdi3+0x62>
  80231c:	31 c0                	xor    %eax,%eax
  80231e:	39 eb                	cmp    %ebp,%ebx
  802320:	77 de                	ja     802300 <__udivdi3+0x40>
  802322:	b8 01 00 00 00       	mov    $0x1,%eax
  802327:	eb d7                	jmp    802300 <__udivdi3+0x40>
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	89 d9                	mov    %ebx,%ecx
  802332:	85 db                	test   %ebx,%ebx
  802334:	75 0b                	jne    802341 <__udivdi3+0x81>
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f3                	div    %ebx
  80233f:	89 c1                	mov    %eax,%ecx
  802341:	31 d2                	xor    %edx,%edx
  802343:	89 f0                	mov    %esi,%eax
  802345:	f7 f1                	div    %ecx
  802347:	89 c6                	mov    %eax,%esi
  802349:	89 e8                	mov    %ebp,%eax
  80234b:	89 f7                	mov    %esi,%edi
  80234d:	f7 f1                	div    %ecx
  80234f:	89 fa                	mov    %edi,%edx
  802351:	83 c4 1c             	add    $0x1c,%esp
  802354:	5b                   	pop    %ebx
  802355:	5e                   	pop    %esi
  802356:	5f                   	pop    %edi
  802357:	5d                   	pop    %ebp
  802358:	c3                   	ret    
  802359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802360:	89 f9                	mov    %edi,%ecx
  802362:	b8 20 00 00 00       	mov    $0x20,%eax
  802367:	29 f8                	sub    %edi,%eax
  802369:	d3 e2                	shl    %cl,%edx
  80236b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80236f:	89 c1                	mov    %eax,%ecx
  802371:	89 da                	mov    %ebx,%edx
  802373:	d3 ea                	shr    %cl,%edx
  802375:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802379:	09 d1                	or     %edx,%ecx
  80237b:	89 f2                	mov    %esi,%edx
  80237d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802381:	89 f9                	mov    %edi,%ecx
  802383:	d3 e3                	shl    %cl,%ebx
  802385:	89 c1                	mov    %eax,%ecx
  802387:	d3 ea                	shr    %cl,%edx
  802389:	89 f9                	mov    %edi,%ecx
  80238b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80238f:	89 eb                	mov    %ebp,%ebx
  802391:	d3 e6                	shl    %cl,%esi
  802393:	89 c1                	mov    %eax,%ecx
  802395:	d3 eb                	shr    %cl,%ebx
  802397:	09 de                	or     %ebx,%esi
  802399:	89 f0                	mov    %esi,%eax
  80239b:	f7 74 24 08          	divl   0x8(%esp)
  80239f:	89 d6                	mov    %edx,%esi
  8023a1:	89 c3                	mov    %eax,%ebx
  8023a3:	f7 64 24 0c          	mull   0xc(%esp)
  8023a7:	39 d6                	cmp    %edx,%esi
  8023a9:	72 15                	jb     8023c0 <__udivdi3+0x100>
  8023ab:	89 f9                	mov    %edi,%ecx
  8023ad:	d3 e5                	shl    %cl,%ebp
  8023af:	39 c5                	cmp    %eax,%ebp
  8023b1:	73 04                	jae    8023b7 <__udivdi3+0xf7>
  8023b3:	39 d6                	cmp    %edx,%esi
  8023b5:	74 09                	je     8023c0 <__udivdi3+0x100>
  8023b7:	89 d8                	mov    %ebx,%eax
  8023b9:	31 ff                	xor    %edi,%edi
  8023bb:	e9 40 ff ff ff       	jmp    802300 <__udivdi3+0x40>
  8023c0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8023c3:	31 ff                	xor    %edi,%edi
  8023c5:	e9 36 ff ff ff       	jmp    802300 <__udivdi3+0x40>
  8023ca:	66 90                	xchg   %ax,%ax
  8023cc:	66 90                	xchg   %ax,%ax
  8023ce:	66 90                	xchg   %ax,%ax

008023d0 <__umoddi3>:
  8023d0:	f3 0f 1e fb          	endbr32 
  8023d4:	55                   	push   %ebp
  8023d5:	57                   	push   %edi
  8023d6:	56                   	push   %esi
  8023d7:	53                   	push   %ebx
  8023d8:	83 ec 1c             	sub    $0x1c,%esp
  8023db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8023df:	8b 74 24 30          	mov    0x30(%esp),%esi
  8023e3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8023e7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023eb:	85 c0                	test   %eax,%eax
  8023ed:	75 19                	jne    802408 <__umoddi3+0x38>
  8023ef:	39 df                	cmp    %ebx,%edi
  8023f1:	76 5d                	jbe    802450 <__umoddi3+0x80>
  8023f3:	89 f0                	mov    %esi,%eax
  8023f5:	89 da                	mov    %ebx,%edx
  8023f7:	f7 f7                	div    %edi
  8023f9:	89 d0                	mov    %edx,%eax
  8023fb:	31 d2                	xor    %edx,%edx
  8023fd:	83 c4 1c             	add    $0x1c,%esp
  802400:	5b                   	pop    %ebx
  802401:	5e                   	pop    %esi
  802402:	5f                   	pop    %edi
  802403:	5d                   	pop    %ebp
  802404:	c3                   	ret    
  802405:	8d 76 00             	lea    0x0(%esi),%esi
  802408:	89 f2                	mov    %esi,%edx
  80240a:	39 d8                	cmp    %ebx,%eax
  80240c:	76 12                	jbe    802420 <__umoddi3+0x50>
  80240e:	89 f0                	mov    %esi,%eax
  802410:	89 da                	mov    %ebx,%edx
  802412:	83 c4 1c             	add    $0x1c,%esp
  802415:	5b                   	pop    %ebx
  802416:	5e                   	pop    %esi
  802417:	5f                   	pop    %edi
  802418:	5d                   	pop    %ebp
  802419:	c3                   	ret    
  80241a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802420:	0f bd e8             	bsr    %eax,%ebp
  802423:	83 f5 1f             	xor    $0x1f,%ebp
  802426:	75 50                	jne    802478 <__umoddi3+0xa8>
  802428:	39 d8                	cmp    %ebx,%eax
  80242a:	0f 82 e0 00 00 00    	jb     802510 <__umoddi3+0x140>
  802430:	89 d9                	mov    %ebx,%ecx
  802432:	39 f7                	cmp    %esi,%edi
  802434:	0f 86 d6 00 00 00    	jbe    802510 <__umoddi3+0x140>
  80243a:	89 d0                	mov    %edx,%eax
  80243c:	89 ca                	mov    %ecx,%edx
  80243e:	83 c4 1c             	add    $0x1c,%esp
  802441:	5b                   	pop    %ebx
  802442:	5e                   	pop    %esi
  802443:	5f                   	pop    %edi
  802444:	5d                   	pop    %ebp
  802445:	c3                   	ret    
  802446:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80244d:	8d 76 00             	lea    0x0(%esi),%esi
  802450:	89 fd                	mov    %edi,%ebp
  802452:	85 ff                	test   %edi,%edi
  802454:	75 0b                	jne    802461 <__umoddi3+0x91>
  802456:	b8 01 00 00 00       	mov    $0x1,%eax
  80245b:	31 d2                	xor    %edx,%edx
  80245d:	f7 f7                	div    %edi
  80245f:	89 c5                	mov    %eax,%ebp
  802461:	89 d8                	mov    %ebx,%eax
  802463:	31 d2                	xor    %edx,%edx
  802465:	f7 f5                	div    %ebp
  802467:	89 f0                	mov    %esi,%eax
  802469:	f7 f5                	div    %ebp
  80246b:	89 d0                	mov    %edx,%eax
  80246d:	31 d2                	xor    %edx,%edx
  80246f:	eb 8c                	jmp    8023fd <__umoddi3+0x2d>
  802471:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802478:	89 e9                	mov    %ebp,%ecx
  80247a:	ba 20 00 00 00       	mov    $0x20,%edx
  80247f:	29 ea                	sub    %ebp,%edx
  802481:	d3 e0                	shl    %cl,%eax
  802483:	89 44 24 08          	mov    %eax,0x8(%esp)
  802487:	89 d1                	mov    %edx,%ecx
  802489:	89 f8                	mov    %edi,%eax
  80248b:	d3 e8                	shr    %cl,%eax
  80248d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802491:	89 54 24 04          	mov    %edx,0x4(%esp)
  802495:	8b 54 24 04          	mov    0x4(%esp),%edx
  802499:	09 c1                	or     %eax,%ecx
  80249b:	89 d8                	mov    %ebx,%eax
  80249d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024a1:	89 e9                	mov    %ebp,%ecx
  8024a3:	d3 e7                	shl    %cl,%edi
  8024a5:	89 d1                	mov    %edx,%ecx
  8024a7:	d3 e8                	shr    %cl,%eax
  8024a9:	89 e9                	mov    %ebp,%ecx
  8024ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024af:	d3 e3                	shl    %cl,%ebx
  8024b1:	89 c7                	mov    %eax,%edi
  8024b3:	89 d1                	mov    %edx,%ecx
  8024b5:	89 f0                	mov    %esi,%eax
  8024b7:	d3 e8                	shr    %cl,%eax
  8024b9:	89 e9                	mov    %ebp,%ecx
  8024bb:	89 fa                	mov    %edi,%edx
  8024bd:	d3 e6                	shl    %cl,%esi
  8024bf:	09 d8                	or     %ebx,%eax
  8024c1:	f7 74 24 08          	divl   0x8(%esp)
  8024c5:	89 d1                	mov    %edx,%ecx
  8024c7:	89 f3                	mov    %esi,%ebx
  8024c9:	f7 64 24 0c          	mull   0xc(%esp)
  8024cd:	89 c6                	mov    %eax,%esi
  8024cf:	89 d7                	mov    %edx,%edi
  8024d1:	39 d1                	cmp    %edx,%ecx
  8024d3:	72 06                	jb     8024db <__umoddi3+0x10b>
  8024d5:	75 10                	jne    8024e7 <__umoddi3+0x117>
  8024d7:	39 c3                	cmp    %eax,%ebx
  8024d9:	73 0c                	jae    8024e7 <__umoddi3+0x117>
  8024db:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8024df:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8024e3:	89 d7                	mov    %edx,%edi
  8024e5:	89 c6                	mov    %eax,%esi
  8024e7:	89 ca                	mov    %ecx,%edx
  8024e9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8024ee:	29 f3                	sub    %esi,%ebx
  8024f0:	19 fa                	sbb    %edi,%edx
  8024f2:	89 d0                	mov    %edx,%eax
  8024f4:	d3 e0                	shl    %cl,%eax
  8024f6:	89 e9                	mov    %ebp,%ecx
  8024f8:	d3 eb                	shr    %cl,%ebx
  8024fa:	d3 ea                	shr    %cl,%edx
  8024fc:	09 d8                	or     %ebx,%eax
  8024fe:	83 c4 1c             	add    $0x1c,%esp
  802501:	5b                   	pop    %ebx
  802502:	5e                   	pop    %esi
  802503:	5f                   	pop    %edi
  802504:	5d                   	pop    %ebp
  802505:	c3                   	ret    
  802506:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80250d:	8d 76 00             	lea    0x0(%esi),%esi
  802510:	29 fe                	sub    %edi,%esi
  802512:	19 c3                	sbb    %eax,%ebx
  802514:	89 f2                	mov    %esi,%edx
  802516:	89 d9                	mov    %ebx,%ecx
  802518:	e9 1d ff ff ff       	jmp    80243a <__umoddi3+0x6a>
