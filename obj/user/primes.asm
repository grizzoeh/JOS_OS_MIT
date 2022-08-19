
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  800040:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800043:	83 ec 04             	sub    $0x4,%esp
  800046:	6a 00                	push   $0x0
  800048:	6a 00                	push   $0x0
  80004a:	56                   	push   %esi
  80004b:	e8 f8 11 00 00       	call   801248 <ipc_recv>
  800050:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800052:	a1 04 40 80 00       	mov    0x804004,%eax
  800057:	8b 40 5c             	mov    0x5c(%eax),%eax
  80005a:	83 c4 0c             	add    $0xc,%esp
  80005d:	53                   	push   %ebx
  80005e:	50                   	push   %eax
  80005f:	68 00 24 80 00       	push   $0x802400
  800064:	e8 e8 01 00 00       	call   800251 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800069:	e8 86 10 00 00       	call   8010f4 <fork>
  80006e:	89 c7                	mov    %eax,%edi
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	85 c0                	test   %eax,%eax
  800075:	78 07                	js     80007e <primeproc+0x4b>
		panic("fork: %e", id);
	if (id == 0)
  800077:	74 ca                	je     800043 <primeproc+0x10>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800079:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80007c:	eb 20                	jmp    80009e <primeproc+0x6b>
		panic("fork: %e", id);
  80007e:	50                   	push   %eax
  80007f:	68 0c 24 80 00       	push   $0x80240c
  800084:	6a 1a                	push   $0x1a
  800086:	68 15 24 80 00       	push   $0x802415
  80008b:	e8 da 00 00 00       	call   80016a <_panic>
		if (i % p)
			ipc_send(id, i, 0, 0);
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	51                   	push   %ecx
  800095:	57                   	push   %edi
  800096:	e8 1a 12 00 00       	call   8012b5 <ipc_send>
  80009b:	83 c4 10             	add    $0x10,%esp
		i = ipc_recv(&envid, 0, 0);
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	56                   	push   %esi
  8000a6:	e8 9d 11 00 00       	call   801248 <ipc_recv>
  8000ab:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000ad:	99                   	cltd   
  8000ae:	f7 fb                	idiv   %ebx
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	85 d2                	test   %edx,%edx
  8000b5:	74 e7                	je     80009e <primeproc+0x6b>
  8000b7:	eb d7                	jmp    800090 <primeproc+0x5d>

008000b9 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b9:	f3 0f 1e fb          	endbr32 
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000c2:	e8 2d 10 00 00       	call   8010f4 <fork>
  8000c7:	89 c6                	mov    %eax,%esi
  8000c9:	85 c0                	test   %eax,%eax
  8000cb:	78 1a                	js     8000e7 <umain+0x2e>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000cd:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000d2:	74 25                	je     8000f9 <umain+0x40>
		ipc_send(id, i, 0, 0);
  8000d4:	6a 00                	push   $0x0
  8000d6:	6a 00                	push   $0x0
  8000d8:	53                   	push   %ebx
  8000d9:	56                   	push   %esi
  8000da:	e8 d6 11 00 00       	call   8012b5 <ipc_send>
	for (i = 2; ; i++)
  8000df:	83 c3 01             	add    $0x1,%ebx
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb ed                	jmp    8000d4 <umain+0x1b>
		panic("fork: %e", id);
  8000e7:	50                   	push   %eax
  8000e8:	68 0c 24 80 00       	push   $0x80240c
  8000ed:	6a 2d                	push   $0x2d
  8000ef:	68 15 24 80 00       	push   $0x802415
  8000f4:	e8 71 00 00 00       	call   80016a <_panic>
		primeproc();
  8000f9:	e8 35 ff ff ff       	call   800033 <primeproc>

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	f3 0f 1e fb          	endbr32 
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
  800107:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  80010d:	e8 de 0a 00 00       	call   800bf0 <sys_getenvid>
	if (id >= 0)
  800112:	85 c0                	test   %eax,%eax
  800114:	78 12                	js     800128 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800116:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800123:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800128:	85 db                	test   %ebx,%ebx
  80012a:	7e 07                	jle    800133 <libmain+0x35>
		binaryname = argv[0];
  80012c:	8b 06                	mov    (%esi),%eax
  80012e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800133:	83 ec 08             	sub    $0x8,%esp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	e8 7c ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  80013d:	e8 0a 00 00 00       	call   80014c <exit>
}
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5d                   	pop    %ebp
  80014b:	c3                   	ret    

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	f3 0f 1e fb          	endbr32 
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800156:	e8 dd 13 00 00       	call   801538 <close_all>
	sys_env_destroy(0);
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	6a 00                	push   $0x0
  800160:	e8 65 0a 00 00       	call   800bca <sys_env_destroy>
}
  800165:	83 c4 10             	add    $0x10,%esp
  800168:	c9                   	leave  
  800169:	c3                   	ret    

0080016a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80016a:	f3 0f 1e fb          	endbr32 
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	56                   	push   %esi
  800172:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800173:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800176:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80017c:	e8 6f 0a 00 00       	call   800bf0 <sys_getenvid>
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	ff 75 0c             	pushl  0xc(%ebp)
  800187:	ff 75 08             	pushl  0x8(%ebp)
  80018a:	56                   	push   %esi
  80018b:	50                   	push   %eax
  80018c:	68 30 24 80 00       	push   $0x802430
  800191:	e8 bb 00 00 00       	call   800251 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800196:	83 c4 18             	add    $0x18,%esp
  800199:	53                   	push   %ebx
  80019a:	ff 75 10             	pushl  0x10(%ebp)
  80019d:	e8 5a 00 00 00       	call   8001fc <vcprintf>
	cprintf("\n");
  8001a2:	c7 04 24 63 2a 80 00 	movl   $0x802a63,(%esp)
  8001a9:	e8 a3 00 00 00       	call   800251 <cprintf>
  8001ae:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b1:	cc                   	int3   
  8001b2:	eb fd                	jmp    8001b1 <_panic+0x47>

008001b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b4:	f3 0f 1e fb          	endbr32 
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 04             	sub    $0x4,%esp
  8001bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c2:	8b 13                	mov    (%ebx),%edx
  8001c4:	8d 42 01             	lea    0x1(%edx),%eax
  8001c7:	89 03                	mov    %eax,(%ebx)
  8001c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d5:	74 09                	je     8001e0 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001e0:	83 ec 08             	sub    $0x8,%esp
  8001e3:	68 ff 00 00 00       	push   $0xff
  8001e8:	8d 43 08             	lea    0x8(%ebx),%eax
  8001eb:	50                   	push   %eax
  8001ec:	e8 87 09 00 00       	call   800b78 <sys_cputs>
		b->idx = 0;
  8001f1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	eb db                	jmp    8001d7 <putch+0x23>

008001fc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001fc:	f3 0f 1e fb          	endbr32 
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800209:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800210:	00 00 00 
	b.cnt = 0;
  800213:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80021d:	ff 75 0c             	pushl  0xc(%ebp)
  800220:	ff 75 08             	pushl  0x8(%ebp)
  800223:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800229:	50                   	push   %eax
  80022a:	68 b4 01 80 00       	push   $0x8001b4
  80022f:	e8 80 01 00 00       	call   8003b4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800234:	83 c4 08             	add    $0x8,%esp
  800237:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80023d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800243:	50                   	push   %eax
  800244:	e8 2f 09 00 00       	call   800b78 <sys_cputs>

	return b.cnt;
}
  800249:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024f:	c9                   	leave  
  800250:	c3                   	ret    

00800251 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800251:	f3 0f 1e fb          	endbr32 
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80025e:	50                   	push   %eax
  80025f:	ff 75 08             	pushl  0x8(%ebp)
  800262:	e8 95 ff ff ff       	call   8001fc <vcprintf>
	va_end(ap);

	return cnt;
}
  800267:	c9                   	leave  
  800268:	c3                   	ret    

00800269 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	57                   	push   %edi
  80026d:	56                   	push   %esi
  80026e:	53                   	push   %ebx
  80026f:	83 ec 1c             	sub    $0x1c,%esp
  800272:	89 c7                	mov    %eax,%edi
  800274:	89 d6                	mov    %edx,%esi
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	8b 55 0c             	mov    0xc(%ebp),%edx
  80027c:	89 d1                	mov    %edx,%ecx
  80027e:	89 c2                	mov    %eax,%edx
  800280:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800283:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800286:	8b 45 10             	mov    0x10(%ebp),%eax
  800289:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80028c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80028f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800296:	39 c2                	cmp    %eax,%edx
  800298:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80029b:	72 3e                	jb     8002db <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80029d:	83 ec 0c             	sub    $0xc,%esp
  8002a0:	ff 75 18             	pushl  0x18(%ebp)
  8002a3:	83 eb 01             	sub    $0x1,%ebx
  8002a6:	53                   	push   %ebx
  8002a7:	50                   	push   %eax
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b7:	e8 d4 1e 00 00       	call   802190 <__udivdi3>
  8002bc:	83 c4 18             	add    $0x18,%esp
  8002bf:	52                   	push   %edx
  8002c0:	50                   	push   %eax
  8002c1:	89 f2                	mov    %esi,%edx
  8002c3:	89 f8                	mov    %edi,%eax
  8002c5:	e8 9f ff ff ff       	call   800269 <printnum>
  8002ca:	83 c4 20             	add    $0x20,%esp
  8002cd:	eb 13                	jmp    8002e2 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002cf:	83 ec 08             	sub    $0x8,%esp
  8002d2:	56                   	push   %esi
  8002d3:	ff 75 18             	pushl  0x18(%ebp)
  8002d6:	ff d7                	call   *%edi
  8002d8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002db:	83 eb 01             	sub    $0x1,%ebx
  8002de:	85 db                	test   %ebx,%ebx
  8002e0:	7f ed                	jg     8002cf <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e2:	83 ec 08             	sub    $0x8,%esp
  8002e5:	56                   	push   %esi
  8002e6:	83 ec 04             	sub    $0x4,%esp
  8002e9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ef:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f5:	e8 a6 1f 00 00       	call   8022a0 <__umoddi3>
  8002fa:	83 c4 14             	add    $0x14,%esp
  8002fd:	0f be 80 53 24 80 00 	movsbl 0x802453(%eax),%eax
  800304:	50                   	push   %eax
  800305:	ff d7                	call   *%edi
}
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030d:	5b                   	pop    %ebx
  80030e:	5e                   	pop    %esi
  80030f:	5f                   	pop    %edi
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800312:	83 fa 01             	cmp    $0x1,%edx
  800315:	7f 13                	jg     80032a <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800317:	85 d2                	test   %edx,%edx
  800319:	74 1c                	je     800337 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80031b:	8b 10                	mov    (%eax),%edx
  80031d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800320:	89 08                	mov    %ecx,(%eax)
  800322:	8b 02                	mov    (%edx),%eax
  800324:	ba 00 00 00 00       	mov    $0x0,%edx
  800329:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80032a:	8b 10                	mov    (%eax),%edx
  80032c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80032f:	89 08                	mov    %ecx,(%eax)
  800331:	8b 02                	mov    (%edx),%eax
  800333:	8b 52 04             	mov    0x4(%edx),%edx
  800336:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800337:	8b 10                	mov    (%eax),%edx
  800339:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033c:	89 08                	mov    %ecx,(%eax)
  80033e:	8b 02                	mov    (%edx),%eax
  800340:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800345:	c3                   	ret    

00800346 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800346:	83 fa 01             	cmp    $0x1,%edx
  800349:	7f 0f                	jg     80035a <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80034b:	85 d2                	test   %edx,%edx
  80034d:	74 18                	je     800367 <getint+0x21>
		return va_arg(*ap, long);
  80034f:	8b 10                	mov    (%eax),%edx
  800351:	8d 4a 04             	lea    0x4(%edx),%ecx
  800354:	89 08                	mov    %ecx,(%eax)
  800356:	8b 02                	mov    (%edx),%eax
  800358:	99                   	cltd   
  800359:	c3                   	ret    
		return va_arg(*ap, long long);
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 02                	mov    (%edx),%eax
  800363:	8b 52 04             	mov    0x4(%edx),%edx
  800366:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800367:	8b 10                	mov    (%eax),%edx
  800369:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036c:	89 08                	mov    %ecx,(%eax)
  80036e:	8b 02                	mov    (%edx),%eax
  800370:	99                   	cltd   
}
  800371:	c3                   	ret    

00800372 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800372:	f3 0f 1e fb          	endbr32 
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800380:	8b 10                	mov    (%eax),%edx
  800382:	3b 50 04             	cmp    0x4(%eax),%edx
  800385:	73 0a                	jae    800391 <sprintputch+0x1f>
		*b->buf++ = ch;
  800387:	8d 4a 01             	lea    0x1(%edx),%ecx
  80038a:	89 08                	mov    %ecx,(%eax)
  80038c:	8b 45 08             	mov    0x8(%ebp),%eax
  80038f:	88 02                	mov    %al,(%edx)
}
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <printfmt>:
{
  800393:	f3 0f 1e fb          	endbr32 
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80039d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a0:	50                   	push   %eax
  8003a1:	ff 75 10             	pushl  0x10(%ebp)
  8003a4:	ff 75 0c             	pushl  0xc(%ebp)
  8003a7:	ff 75 08             	pushl  0x8(%ebp)
  8003aa:	e8 05 00 00 00       	call   8003b4 <vprintfmt>
}
  8003af:	83 c4 10             	add    $0x10,%esp
  8003b2:	c9                   	leave  
  8003b3:	c3                   	ret    

008003b4 <vprintfmt>:
{
  8003b4:	f3 0f 1e fb          	endbr32 
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	57                   	push   %edi
  8003bc:	56                   	push   %esi
  8003bd:	53                   	push   %ebx
  8003be:	83 ec 2c             	sub    $0x2c,%esp
  8003c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003c7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003ca:	e9 86 02 00 00       	jmp    800655 <vprintfmt+0x2a1>
		padc = ' ';
  8003cf:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003d3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003da:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003e1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003e8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8d 47 01             	lea    0x1(%edi),%eax
  8003f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003f3:	0f b6 17             	movzbl (%edi),%edx
  8003f6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f9:	3c 55                	cmp    $0x55,%al
  8003fb:	0f 87 df 02 00 00    	ja     8006e0 <vprintfmt+0x32c>
  800401:	0f b6 c0             	movzbl %al,%eax
  800404:	3e ff 24 85 a0 25 80 	notrack jmp *0x8025a0(,%eax,4)
  80040b:	00 
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80040f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800413:	eb d8                	jmp    8003ed <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800418:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80041c:	eb cf                	jmp    8003ed <vprintfmt+0x39>
  80041e:	0f b6 d2             	movzbl %dl,%edx
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800424:	b8 00 00 00 00       	mov    $0x0,%eax
  800429:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80042c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800433:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800436:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800439:	83 f9 09             	cmp    $0x9,%ecx
  80043c:	77 52                	ja     800490 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  80043e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800441:	eb e9                	jmp    80042c <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 50 04             	lea    0x4(%eax),%edx
  800449:	89 55 14             	mov    %edx,0x14(%ebp)
  80044c:	8b 00                	mov    (%eax),%eax
  80044e:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800454:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800458:	79 93                	jns    8003ed <vprintfmt+0x39>
				width = precision, precision = -1;
  80045a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80045d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800460:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800467:	eb 84                	jmp    8003ed <vprintfmt+0x39>
  800469:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046c:	85 c0                	test   %eax,%eax
  80046e:	ba 00 00 00 00       	mov    $0x0,%edx
  800473:	0f 49 d0             	cmovns %eax,%edx
  800476:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80047c:	e9 6c ff ff ff       	jmp    8003ed <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800484:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80048b:	e9 5d ff ff ff       	jmp    8003ed <vprintfmt+0x39>
  800490:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800493:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800496:	eb bc                	jmp    800454 <vprintfmt+0xa0>
			lflag++;
  800498:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80049e:	e9 4a ff ff ff       	jmp    8003ed <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8004a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a6:	8d 50 04             	lea    0x4(%eax),%edx
  8004a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	56                   	push   %esi
  8004b0:	ff 30                	pushl  (%eax)
  8004b2:	ff d3                	call   *%ebx
			break;
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	e9 96 01 00 00       	jmp    800652 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 50 04             	lea    0x4(%eax),%edx
  8004c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c5:	8b 00                	mov    (%eax),%eax
  8004c7:	99                   	cltd   
  8004c8:	31 d0                	xor    %edx,%eax
  8004ca:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004cc:	83 f8 0f             	cmp    $0xf,%eax
  8004cf:	7f 20                	jg     8004f1 <vprintfmt+0x13d>
  8004d1:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  8004d8:	85 d2                	test   %edx,%edx
  8004da:	74 15                	je     8004f1 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8004dc:	52                   	push   %edx
  8004dd:	68 31 2a 80 00       	push   $0x802a31
  8004e2:	56                   	push   %esi
  8004e3:	53                   	push   %ebx
  8004e4:	e8 aa fe ff ff       	call   800393 <printfmt>
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	e9 61 01 00 00       	jmp    800652 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8004f1:	50                   	push   %eax
  8004f2:	68 6b 24 80 00       	push   $0x80246b
  8004f7:	56                   	push   %esi
  8004f8:	53                   	push   %ebx
  8004f9:	e8 95 fe ff ff       	call   800393 <printfmt>
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	e9 4c 01 00 00       	jmp    800652 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 50 04             	lea    0x4(%eax),%edx
  80050c:	89 55 14             	mov    %edx,0x14(%ebp)
  80050f:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800511:	85 c9                	test   %ecx,%ecx
  800513:	b8 64 24 80 00       	mov    $0x802464,%eax
  800518:	0f 45 c1             	cmovne %ecx,%eax
  80051b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80051e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800522:	7e 06                	jle    80052a <vprintfmt+0x176>
  800524:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800528:	75 0d                	jne    800537 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80052d:	89 c7                	mov    %eax,%edi
  80052f:	03 45 e0             	add    -0x20(%ebp),%eax
  800532:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800535:	eb 57                	jmp    80058e <vprintfmt+0x1da>
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	ff 75 d8             	pushl  -0x28(%ebp)
  80053d:	ff 75 cc             	pushl  -0x34(%ebp)
  800540:	e8 4f 02 00 00       	call   800794 <strnlen>
  800545:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800548:	29 c2                	sub    %eax,%edx
  80054a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80054d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800550:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800554:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800557:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800559:	85 db                	test   %ebx,%ebx
  80055b:	7e 10                	jle    80056d <vprintfmt+0x1b9>
					putch(padc, putdat);
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	56                   	push   %esi
  800561:	57                   	push   %edi
  800562:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800565:	83 eb 01             	sub    $0x1,%ebx
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	eb ec                	jmp    800559 <vprintfmt+0x1a5>
  80056d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800570:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800573:	85 d2                	test   %edx,%edx
  800575:	b8 00 00 00 00       	mov    $0x0,%eax
  80057a:	0f 49 c2             	cmovns %edx,%eax
  80057d:	29 c2                	sub    %eax,%edx
  80057f:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800582:	eb a6                	jmp    80052a <vprintfmt+0x176>
					putch(ch, putdat);
  800584:	83 ec 08             	sub    $0x8,%esp
  800587:	56                   	push   %esi
  800588:	52                   	push   %edx
  800589:	ff d3                	call   *%ebx
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800591:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800593:	83 c7 01             	add    $0x1,%edi
  800596:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80059a:	0f be d0             	movsbl %al,%edx
  80059d:	85 d2                	test   %edx,%edx
  80059f:	74 42                	je     8005e3 <vprintfmt+0x22f>
  8005a1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a5:	78 06                	js     8005ad <vprintfmt+0x1f9>
  8005a7:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005ab:	78 1e                	js     8005cb <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ad:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005b1:	74 d1                	je     800584 <vprintfmt+0x1d0>
  8005b3:	0f be c0             	movsbl %al,%eax
  8005b6:	83 e8 20             	sub    $0x20,%eax
  8005b9:	83 f8 5e             	cmp    $0x5e,%eax
  8005bc:	76 c6                	jbe    800584 <vprintfmt+0x1d0>
					putch('?', putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	56                   	push   %esi
  8005c2:	6a 3f                	push   $0x3f
  8005c4:	ff d3                	call   *%ebx
  8005c6:	83 c4 10             	add    $0x10,%esp
  8005c9:	eb c3                	jmp    80058e <vprintfmt+0x1da>
  8005cb:	89 cf                	mov    %ecx,%edi
  8005cd:	eb 0e                	jmp    8005dd <vprintfmt+0x229>
				putch(' ', putdat);
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	56                   	push   %esi
  8005d3:	6a 20                	push   $0x20
  8005d5:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8005d7:	83 ef 01             	sub    $0x1,%edi
  8005da:	83 c4 10             	add    $0x10,%esp
  8005dd:	85 ff                	test   %edi,%edi
  8005df:	7f ee                	jg     8005cf <vprintfmt+0x21b>
  8005e1:	eb 6f                	jmp    800652 <vprintfmt+0x29e>
  8005e3:	89 cf                	mov    %ecx,%edi
  8005e5:	eb f6                	jmp    8005dd <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8005e7:	89 ca                	mov    %ecx,%edx
  8005e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ec:	e8 55 fd ff ff       	call   800346 <getint>
  8005f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8005f7:	85 d2                	test   %edx,%edx
  8005f9:	78 0b                	js     800606 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8005fb:	89 d1                	mov    %edx,%ecx
  8005fd:	89 c2                	mov    %eax,%edx
			base = 10;
  8005ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800604:	eb 32                	jmp    800638 <vprintfmt+0x284>
				putch('-', putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	56                   	push   %esi
  80060a:	6a 2d                	push   $0x2d
  80060c:	ff d3                	call   *%ebx
				num = -(long long) num;
  80060e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800611:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800614:	f7 da                	neg    %edx
  800616:	83 d1 00             	adc    $0x0,%ecx
  800619:	f7 d9                	neg    %ecx
  80061b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80061e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800623:	eb 13                	jmp    800638 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800625:	89 ca                	mov    %ecx,%edx
  800627:	8d 45 14             	lea    0x14(%ebp),%eax
  80062a:	e8 e3 fc ff ff       	call   800312 <getuint>
  80062f:	89 d1                	mov    %edx,%ecx
  800631:	89 c2                	mov    %eax,%edx
			base = 10;
  800633:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800638:	83 ec 0c             	sub    $0xc,%esp
  80063b:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80063f:	57                   	push   %edi
  800640:	ff 75 e0             	pushl  -0x20(%ebp)
  800643:	50                   	push   %eax
  800644:	51                   	push   %ecx
  800645:	52                   	push   %edx
  800646:	89 f2                	mov    %esi,%edx
  800648:	89 d8                	mov    %ebx,%eax
  80064a:	e8 1a fc ff ff       	call   800269 <printnum>
			break;
  80064f:	83 c4 20             	add    $0x20,%esp
{
  800652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800655:	83 c7 01             	add    $0x1,%edi
  800658:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80065c:	83 f8 25             	cmp    $0x25,%eax
  80065f:	0f 84 6a fd ff ff    	je     8003cf <vprintfmt+0x1b>
			if (ch == '\0')
  800665:	85 c0                	test   %eax,%eax
  800667:	0f 84 93 00 00 00    	je     800700 <vprintfmt+0x34c>
			putch(ch, putdat);
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	56                   	push   %esi
  800671:	50                   	push   %eax
  800672:	ff d3                	call   *%ebx
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	eb dc                	jmp    800655 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800679:	89 ca                	mov    %ecx,%edx
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 8f fc ff ff       	call   800312 <getuint>
  800683:	89 d1                	mov    %edx,%ecx
  800685:	89 c2                	mov    %eax,%edx
			base = 8;
  800687:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80068c:	eb aa                	jmp    800638 <vprintfmt+0x284>
			putch('0', putdat);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	56                   	push   %esi
  800692:	6a 30                	push   $0x30
  800694:	ff d3                	call   *%ebx
			putch('x', putdat);
  800696:	83 c4 08             	add    $0x8,%esp
  800699:	56                   	push   %esi
  80069a:	6a 78                	push   $0x78
  80069c:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 50 04             	lea    0x4(%eax),%edx
  8006a4:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8006a7:	8b 10                	mov    (%eax),%edx
  8006a9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006ae:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8006b1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006b6:	eb 80                	jmp    800638 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8006b8:	89 ca                	mov    %ecx,%edx
  8006ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bd:	e8 50 fc ff ff       	call   800312 <getuint>
  8006c2:	89 d1                	mov    %edx,%ecx
  8006c4:	89 c2                	mov    %eax,%edx
			base = 16;
  8006c6:	b8 10 00 00 00       	mov    $0x10,%eax
  8006cb:	e9 68 ff ff ff       	jmp    800638 <vprintfmt+0x284>
			putch(ch, putdat);
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	56                   	push   %esi
  8006d4:	6a 25                	push   $0x25
  8006d6:	ff d3                	call   *%ebx
			break;
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	e9 72 ff ff ff       	jmp    800652 <vprintfmt+0x29e>
			putch('%', putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	56                   	push   %esi
  8006e4:	6a 25                	push   $0x25
  8006e6:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	89 f8                	mov    %edi,%eax
  8006ed:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006f1:	74 05                	je     8006f8 <vprintfmt+0x344>
  8006f3:	83 e8 01             	sub    $0x1,%eax
  8006f6:	eb f5                	jmp    8006ed <vprintfmt+0x339>
  8006f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006fb:	e9 52 ff ff ff       	jmp    800652 <vprintfmt+0x29e>
}
  800700:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800703:	5b                   	pop    %ebx
  800704:	5e                   	pop    %esi
  800705:	5f                   	pop    %edi
  800706:	5d                   	pop    %ebp
  800707:	c3                   	ret    

00800708 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800708:	f3 0f 1e fb          	endbr32 
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	83 ec 18             	sub    $0x18,%esp
  800712:	8b 45 08             	mov    0x8(%ebp),%eax
  800715:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800718:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800722:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800729:	85 c0                	test   %eax,%eax
  80072b:	74 26                	je     800753 <vsnprintf+0x4b>
  80072d:	85 d2                	test   %edx,%edx
  80072f:	7e 22                	jle    800753 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800731:	ff 75 14             	pushl  0x14(%ebp)
  800734:	ff 75 10             	pushl  0x10(%ebp)
  800737:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073a:	50                   	push   %eax
  80073b:	68 72 03 80 00       	push   $0x800372
  800740:	e8 6f fc ff ff       	call   8003b4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800745:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800748:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074e:	83 c4 10             	add    $0x10,%esp
}
  800751:	c9                   	leave  
  800752:	c3                   	ret    
		return -E_INVAL;
  800753:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800758:	eb f7                	jmp    800751 <vsnprintf+0x49>

0080075a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075a:	f3 0f 1e fb          	endbr32 
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800764:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800767:	50                   	push   %eax
  800768:	ff 75 10             	pushl  0x10(%ebp)
  80076b:	ff 75 0c             	pushl  0xc(%ebp)
  80076e:	ff 75 08             	pushl  0x8(%ebp)
  800771:	e8 92 ff ff ff       	call   800708 <vsnprintf>
	va_end(ap);

	return rc;
}
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800778:	f3 0f 1e fb          	endbr32 
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	b8 00 00 00 00       	mov    $0x0,%eax
  800787:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078b:	74 05                	je     800792 <strlen+0x1a>
		n++;
  80078d:	83 c0 01             	add    $0x1,%eax
  800790:	eb f5                	jmp    800787 <strlen+0xf>
	return n;
}
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800794:	f3 0f 1e fb          	endbr32 
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a6:	39 d0                	cmp    %edx,%eax
  8007a8:	74 0d                	je     8007b7 <strnlen+0x23>
  8007aa:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ae:	74 05                	je     8007b5 <strnlen+0x21>
		n++;
  8007b0:	83 c0 01             	add    $0x1,%eax
  8007b3:	eb f1                	jmp    8007a6 <strnlen+0x12>
  8007b5:	89 c2                	mov    %eax,%edx
	return n;
}
  8007b7:	89 d0                	mov    %edx,%eax
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007bb:	f3 0f 1e fb          	endbr32 
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ce:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007d2:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007d5:	83 c0 01             	add    $0x1,%eax
  8007d8:	84 d2                	test   %dl,%dl
  8007da:	75 f2                	jne    8007ce <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007dc:	89 c8                	mov    %ecx,%eax
  8007de:	5b                   	pop    %ebx
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e1:	f3 0f 1e fb          	endbr32 
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	53                   	push   %ebx
  8007e9:	83 ec 10             	sub    $0x10,%esp
  8007ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ef:	53                   	push   %ebx
  8007f0:	e8 83 ff ff ff       	call   800778 <strlen>
  8007f5:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007f8:	ff 75 0c             	pushl  0xc(%ebp)
  8007fb:	01 d8                	add    %ebx,%eax
  8007fd:	50                   	push   %eax
  8007fe:	e8 b8 ff ff ff       	call   8007bb <strcpy>
	return dst;
}
  800803:	89 d8                	mov    %ebx,%eax
  800805:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080a:	f3 0f 1e fb          	endbr32 
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	56                   	push   %esi
  800812:	53                   	push   %ebx
  800813:	8b 75 08             	mov    0x8(%ebp),%esi
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
  800819:	89 f3                	mov    %esi,%ebx
  80081b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081e:	89 f0                	mov    %esi,%eax
  800820:	39 d8                	cmp    %ebx,%eax
  800822:	74 11                	je     800835 <strncpy+0x2b>
		*dst++ = *src;
  800824:	83 c0 01             	add    $0x1,%eax
  800827:	0f b6 0a             	movzbl (%edx),%ecx
  80082a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082d:	80 f9 01             	cmp    $0x1,%cl
  800830:	83 da ff             	sbb    $0xffffffff,%edx
  800833:	eb eb                	jmp    800820 <strncpy+0x16>
	}
	return ret;
}
  800835:	89 f0                	mov    %esi,%eax
  800837:	5b                   	pop    %ebx
  800838:	5e                   	pop    %esi
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083b:	f3 0f 1e fb          	endbr32 
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	8b 75 08             	mov    0x8(%ebp),%esi
  800847:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084a:	8b 55 10             	mov    0x10(%ebp),%edx
  80084d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084f:	85 d2                	test   %edx,%edx
  800851:	74 21                	je     800874 <strlcpy+0x39>
  800853:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800857:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800859:	39 c2                	cmp    %eax,%edx
  80085b:	74 14                	je     800871 <strlcpy+0x36>
  80085d:	0f b6 19             	movzbl (%ecx),%ebx
  800860:	84 db                	test   %bl,%bl
  800862:	74 0b                	je     80086f <strlcpy+0x34>
			*dst++ = *src++;
  800864:	83 c1 01             	add    $0x1,%ecx
  800867:	83 c2 01             	add    $0x1,%edx
  80086a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086d:	eb ea                	jmp    800859 <strlcpy+0x1e>
  80086f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800871:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800874:	29 f0                	sub    %esi,%eax
}
  800876:	5b                   	pop    %ebx
  800877:	5e                   	pop    %esi
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087a:	f3 0f 1e fb          	endbr32 
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800884:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800887:	0f b6 01             	movzbl (%ecx),%eax
  80088a:	84 c0                	test   %al,%al
  80088c:	74 0c                	je     80089a <strcmp+0x20>
  80088e:	3a 02                	cmp    (%edx),%al
  800890:	75 08                	jne    80089a <strcmp+0x20>
		p++, q++;
  800892:	83 c1 01             	add    $0x1,%ecx
  800895:	83 c2 01             	add    $0x1,%edx
  800898:	eb ed                	jmp    800887 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089a:	0f b6 c0             	movzbl %al,%eax
  80089d:	0f b6 12             	movzbl (%edx),%edx
  8008a0:	29 d0                	sub    %edx,%eax
}
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a4:	f3 0f 1e fb          	endbr32 
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	53                   	push   %ebx
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b2:	89 c3                	mov    %eax,%ebx
  8008b4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b7:	eb 06                	jmp    8008bf <strncmp+0x1b>
		n--, p++, q++;
  8008b9:	83 c0 01             	add    $0x1,%eax
  8008bc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008bf:	39 d8                	cmp    %ebx,%eax
  8008c1:	74 16                	je     8008d9 <strncmp+0x35>
  8008c3:	0f b6 08             	movzbl (%eax),%ecx
  8008c6:	84 c9                	test   %cl,%cl
  8008c8:	74 04                	je     8008ce <strncmp+0x2a>
  8008ca:	3a 0a                	cmp    (%edx),%cl
  8008cc:	74 eb                	je     8008b9 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ce:	0f b6 00             	movzbl (%eax),%eax
  8008d1:	0f b6 12             	movzbl (%edx),%edx
  8008d4:	29 d0                	sub    %edx,%eax
}
  8008d6:	5b                   	pop    %ebx
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    
		return 0;
  8008d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008de:	eb f6                	jmp    8008d6 <strncmp+0x32>

008008e0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e0:	f3 0f 1e fb          	endbr32 
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ee:	0f b6 10             	movzbl (%eax),%edx
  8008f1:	84 d2                	test   %dl,%dl
  8008f3:	74 09                	je     8008fe <strchr+0x1e>
		if (*s == c)
  8008f5:	38 ca                	cmp    %cl,%dl
  8008f7:	74 0a                	je     800903 <strchr+0x23>
	for (; *s; s++)
  8008f9:	83 c0 01             	add    $0x1,%eax
  8008fc:	eb f0                	jmp    8008ee <strchr+0xe>
			return (char *) s;
	return 0;
  8008fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800905:	f3 0f 1e fb          	endbr32 
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800913:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800916:	38 ca                	cmp    %cl,%dl
  800918:	74 09                	je     800923 <strfind+0x1e>
  80091a:	84 d2                	test   %dl,%dl
  80091c:	74 05                	je     800923 <strfind+0x1e>
	for (; *s; s++)
  80091e:	83 c0 01             	add    $0x1,%eax
  800921:	eb f0                	jmp    800913 <strfind+0xe>
			break;
	return (char *) s;
}
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800925:	f3 0f 1e fb          	endbr32 
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	53                   	push   %ebx
  80092f:	8b 55 08             	mov    0x8(%ebp),%edx
  800932:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800935:	85 c9                	test   %ecx,%ecx
  800937:	74 33                	je     80096c <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800939:	89 d0                	mov    %edx,%eax
  80093b:	09 c8                	or     %ecx,%eax
  80093d:	a8 03                	test   $0x3,%al
  80093f:	75 23                	jne    800964 <memset+0x3f>
		c &= 0xFF;
  800941:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800945:	89 d8                	mov    %ebx,%eax
  800947:	c1 e0 08             	shl    $0x8,%eax
  80094a:	89 df                	mov    %ebx,%edi
  80094c:	c1 e7 18             	shl    $0x18,%edi
  80094f:	89 de                	mov    %ebx,%esi
  800951:	c1 e6 10             	shl    $0x10,%esi
  800954:	09 f7                	or     %esi,%edi
  800956:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800958:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80095d:	89 d7                	mov    %edx,%edi
  80095f:	fc                   	cld    
  800960:	f3 ab                	rep stos %eax,%es:(%edi)
  800962:	eb 08                	jmp    80096c <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800964:	89 d7                	mov    %edx,%edi
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	fc                   	cld    
  80096a:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  80096c:	89 d0                	mov    %edx,%eax
  80096e:	5b                   	pop    %ebx
  80096f:	5e                   	pop    %esi
  800970:	5f                   	pop    %edi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800973:	f3 0f 1e fb          	endbr32 
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	57                   	push   %edi
  80097b:	56                   	push   %esi
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800982:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800985:	39 c6                	cmp    %eax,%esi
  800987:	73 32                	jae    8009bb <memmove+0x48>
  800989:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098c:	39 c2                	cmp    %eax,%edx
  80098e:	76 2b                	jbe    8009bb <memmove+0x48>
		s += n;
		d += n;
  800990:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800993:	89 fe                	mov    %edi,%esi
  800995:	09 ce                	or     %ecx,%esi
  800997:	09 d6                	or     %edx,%esi
  800999:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80099f:	75 0e                	jne    8009af <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a1:	83 ef 04             	sub    $0x4,%edi
  8009a4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009aa:	fd                   	std    
  8009ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ad:	eb 09                	jmp    8009b8 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009af:	83 ef 01             	sub    $0x1,%edi
  8009b2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009b5:	fd                   	std    
  8009b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b8:	fc                   	cld    
  8009b9:	eb 1a                	jmp    8009d5 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bb:	89 c2                	mov    %eax,%edx
  8009bd:	09 ca                	or     %ecx,%edx
  8009bf:	09 f2                	or     %esi,%edx
  8009c1:	f6 c2 03             	test   $0x3,%dl
  8009c4:	75 0a                	jne    8009d0 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009c9:	89 c7                	mov    %eax,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ce:	eb 05                	jmp    8009d5 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009d0:	89 c7                	mov    %eax,%edi
  8009d2:	fc                   	cld    
  8009d3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d5:	5e                   	pop    %esi
  8009d6:	5f                   	pop    %edi
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d9:	f3 0f 1e fb          	endbr32 
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e3:	ff 75 10             	pushl  0x10(%ebp)
  8009e6:	ff 75 0c             	pushl  0xc(%ebp)
  8009e9:	ff 75 08             	pushl  0x8(%ebp)
  8009ec:	e8 82 ff ff ff       	call   800973 <memmove>
}
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f3:	f3 0f 1e fb          	endbr32 
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a02:	89 c6                	mov    %eax,%esi
  800a04:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a07:	39 f0                	cmp    %esi,%eax
  800a09:	74 1c                	je     800a27 <memcmp+0x34>
		if (*s1 != *s2)
  800a0b:	0f b6 08             	movzbl (%eax),%ecx
  800a0e:	0f b6 1a             	movzbl (%edx),%ebx
  800a11:	38 d9                	cmp    %bl,%cl
  800a13:	75 08                	jne    800a1d <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	83 c2 01             	add    $0x1,%edx
  800a1b:	eb ea                	jmp    800a07 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a1d:	0f b6 c1             	movzbl %cl,%eax
  800a20:	0f b6 db             	movzbl %bl,%ebx
  800a23:	29 d8                	sub    %ebx,%eax
  800a25:	eb 05                	jmp    800a2c <memcmp+0x39>
	}

	return 0;
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2c:	5b                   	pop    %ebx
  800a2d:	5e                   	pop    %esi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a30:	f3 0f 1e fb          	endbr32 
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a3d:	89 c2                	mov    %eax,%edx
  800a3f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a42:	39 d0                	cmp    %edx,%eax
  800a44:	73 09                	jae    800a4f <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a46:	38 08                	cmp    %cl,(%eax)
  800a48:	74 05                	je     800a4f <memfind+0x1f>
	for (; s < ends; s++)
  800a4a:	83 c0 01             	add    $0x1,%eax
  800a4d:	eb f3                	jmp    800a42 <memfind+0x12>
			break;
	return (void *) s;
}
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a51:	f3 0f 1e fb          	endbr32 
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	57                   	push   %edi
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a61:	eb 03                	jmp    800a66 <strtol+0x15>
		s++;
  800a63:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a66:	0f b6 01             	movzbl (%ecx),%eax
  800a69:	3c 20                	cmp    $0x20,%al
  800a6b:	74 f6                	je     800a63 <strtol+0x12>
  800a6d:	3c 09                	cmp    $0x9,%al
  800a6f:	74 f2                	je     800a63 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a71:	3c 2b                	cmp    $0x2b,%al
  800a73:	74 2a                	je     800a9f <strtol+0x4e>
	int neg = 0;
  800a75:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a7a:	3c 2d                	cmp    $0x2d,%al
  800a7c:	74 2b                	je     800aa9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a84:	75 0f                	jne    800a95 <strtol+0x44>
  800a86:	80 39 30             	cmpb   $0x30,(%ecx)
  800a89:	74 28                	je     800ab3 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a8b:	85 db                	test   %ebx,%ebx
  800a8d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a92:	0f 44 d8             	cmove  %eax,%ebx
  800a95:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a9d:	eb 46                	jmp    800ae5 <strtol+0x94>
		s++;
  800a9f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aa2:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa7:	eb d5                	jmp    800a7e <strtol+0x2d>
		s++, neg = 1;
  800aa9:	83 c1 01             	add    $0x1,%ecx
  800aac:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab1:	eb cb                	jmp    800a7e <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab7:	74 0e                	je     800ac7 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ab9:	85 db                	test   %ebx,%ebx
  800abb:	75 d8                	jne    800a95 <strtol+0x44>
		s++, base = 8;
  800abd:	83 c1 01             	add    $0x1,%ecx
  800ac0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ac5:	eb ce                	jmp    800a95 <strtol+0x44>
		s += 2, base = 16;
  800ac7:	83 c1 02             	add    $0x2,%ecx
  800aca:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acf:	eb c4                	jmp    800a95 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ad1:	0f be d2             	movsbl %dl,%edx
  800ad4:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ad7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ada:	7d 3a                	jge    800b16 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800adc:	83 c1 01             	add    $0x1,%ecx
  800adf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ae5:	0f b6 11             	movzbl (%ecx),%edx
  800ae8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aeb:	89 f3                	mov    %esi,%ebx
  800aed:	80 fb 09             	cmp    $0x9,%bl
  800af0:	76 df                	jbe    800ad1 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800af2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af5:	89 f3                	mov    %esi,%ebx
  800af7:	80 fb 19             	cmp    $0x19,%bl
  800afa:	77 08                	ja     800b04 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800afc:	0f be d2             	movsbl %dl,%edx
  800aff:	83 ea 57             	sub    $0x57,%edx
  800b02:	eb d3                	jmp    800ad7 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b04:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b07:	89 f3                	mov    %esi,%ebx
  800b09:	80 fb 19             	cmp    $0x19,%bl
  800b0c:	77 08                	ja     800b16 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b0e:	0f be d2             	movsbl %dl,%edx
  800b11:	83 ea 37             	sub    $0x37,%edx
  800b14:	eb c1                	jmp    800ad7 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1a:	74 05                	je     800b21 <strtol+0xd0>
		*endptr = (char *) s;
  800b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b21:	89 c2                	mov    %eax,%edx
  800b23:	f7 da                	neg    %edx
  800b25:	85 ff                	test   %edi,%edi
  800b27:	0f 45 c2             	cmovne %edx,%eax
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 1c             	sub    $0x1c,%esp
  800b38:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b3b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b3e:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b46:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b49:	8b 75 14             	mov    0x14(%ebp),%esi
  800b4c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b52:	74 04                	je     800b58 <syscall+0x29>
  800b54:	85 c0                	test   %eax,%eax
  800b56:	7f 08                	jg     800b60 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	50                   	push   %eax
  800b64:	ff 75 e0             	pushl  -0x20(%ebp)
  800b67:	68 5f 27 80 00       	push   $0x80275f
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 7c 27 80 00       	push   $0x80277c
  800b73:	e8 f2 f5 ff ff       	call   80016a <_panic>

00800b78 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800b78:	f3 0f 1e fb          	endbr32 
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b82:	6a 00                	push   $0x0
  800b84:	6a 00                	push   $0x0
  800b86:	6a 00                	push   $0x0
  800b88:	ff 75 0c             	pushl  0xc(%ebp)
  800b8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	e8 92 ff ff ff       	call   800b2f <syscall>
}
  800b9d:	83 c4 10             	add    $0x10,%esp
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    

00800ba2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba2:	f3 0f 1e fb          	endbr32 
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800bac:	6a 00                	push   $0x0
  800bae:	6a 00                	push   $0x0
  800bb0:	6a 00                	push   $0x0
  800bb2:	6a 00                	push   $0x0
  800bb4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbe:	b8 01 00 00 00       	mov    $0x1,%eax
  800bc3:	e8 67 ff ff ff       	call   800b2f <syscall>
}
  800bc8:	c9                   	leave  
  800bc9:	c3                   	ret    

00800bca <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bca:	f3 0f 1e fb          	endbr32 
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bd4:	6a 00                	push   $0x0
  800bd6:	6a 00                	push   $0x0
  800bd8:	6a 00                	push   $0x0
  800bda:	6a 00                	push   $0x0
  800bdc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdf:	ba 01 00 00 00       	mov    $0x1,%edx
  800be4:	b8 03 00 00 00       	mov    $0x3,%eax
  800be9:	e8 41 ff ff ff       	call   800b2f <syscall>
}
  800bee:	c9                   	leave  
  800bef:	c3                   	ret    

00800bf0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf0:	f3 0f 1e fb          	endbr32 
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bfa:	6a 00                	push   $0x0
  800bfc:	6a 00                	push   $0x0
  800bfe:	6a 00                	push   $0x0
  800c00:	6a 00                	push   $0x0
  800c02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c07:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0c:	b8 02 00 00 00       	mov    $0x2,%eax
  800c11:	e8 19 ff ff ff       	call   800b2f <syscall>
}
  800c16:	c9                   	leave  
  800c17:	c3                   	ret    

00800c18 <sys_yield>:

void
sys_yield(void)
{
  800c18:	f3 0f 1e fb          	endbr32 
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c22:	6a 00                	push   $0x0
  800c24:	6a 00                	push   $0x0
  800c26:	6a 00                	push   $0x0
  800c28:	6a 00                	push   $0x0
  800c2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c34:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c39:	e8 f1 fe ff ff       	call   800b2f <syscall>
}
  800c3e:	83 c4 10             	add    $0x10,%esp
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c43:	f3 0f 1e fb          	endbr32 
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c4d:	6a 00                	push   $0x0
  800c4f:	6a 00                	push   $0x0
  800c51:	ff 75 10             	pushl  0x10(%ebp)
  800c54:	ff 75 0c             	pushl  0xc(%ebp)
  800c57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c5f:	b8 04 00 00 00       	mov    $0x4,%eax
  800c64:	e8 c6 fe ff ff       	call   800b2f <syscall>
}
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    

00800c6b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c6b:	f3 0f 1e fb          	endbr32 
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c75:	ff 75 18             	pushl  0x18(%ebp)
  800c78:	ff 75 14             	pushl  0x14(%ebp)
  800c7b:	ff 75 10             	pushl  0x10(%ebp)
  800c7e:	ff 75 0c             	pushl  0xc(%ebp)
  800c81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c84:	ba 01 00 00 00       	mov    $0x1,%edx
  800c89:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8e:	e8 9c fe ff ff       	call   800b2f <syscall>
}
  800c93:	c9                   	leave  
  800c94:	c3                   	ret    

00800c95 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c95:	f3 0f 1e fb          	endbr32 
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c9f:	6a 00                	push   $0x0
  800ca1:	6a 00                	push   $0x0
  800ca3:	6a 00                	push   $0x0
  800ca5:	ff 75 0c             	pushl  0xc(%ebp)
  800ca8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cab:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb0:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb5:	e8 75 fe ff ff       	call   800b2f <syscall>
}
  800cba:	c9                   	leave  
  800cbb:	c3                   	ret    

00800cbc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbc:	f3 0f 1e fb          	endbr32 
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800cc6:	6a 00                	push   $0x0
  800cc8:	6a 00                	push   $0x0
  800cca:	6a 00                	push   $0x0
  800ccc:	ff 75 0c             	pushl  0xc(%ebp)
  800ccf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd2:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd7:	b8 08 00 00 00       	mov    $0x8,%eax
  800cdc:	e8 4e fe ff ff       	call   800b2f <syscall>
}
  800ce1:	c9                   	leave  
  800ce2:	c3                   	ret    

00800ce3 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce3:	f3 0f 1e fb          	endbr32 
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800ced:	6a 00                	push   $0x0
  800cef:	6a 00                	push   $0x0
  800cf1:	6a 00                	push   $0x0
  800cf3:	ff 75 0c             	pushl  0xc(%ebp)
  800cf6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf9:	ba 01 00 00 00       	mov    $0x1,%edx
  800cfe:	b8 09 00 00 00       	mov    $0x9,%eax
  800d03:	e8 27 fe ff ff       	call   800b2f <syscall>
}
  800d08:	c9                   	leave  
  800d09:	c3                   	ret    

00800d0a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0a:	f3 0f 1e fb          	endbr32 
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d14:	6a 00                	push   $0x0
  800d16:	6a 00                	push   $0x0
  800d18:	6a 00                	push   $0x0
  800d1a:	ff 75 0c             	pushl  0xc(%ebp)
  800d1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d20:	ba 01 00 00 00       	mov    $0x1,%edx
  800d25:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d2a:	e8 00 fe ff ff       	call   800b2f <syscall>
}
  800d2f:	c9                   	leave  
  800d30:	c3                   	ret    

00800d31 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d31:	f3 0f 1e fb          	endbr32 
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d3b:	6a 00                	push   $0x0
  800d3d:	ff 75 14             	pushl  0x14(%ebp)
  800d40:	ff 75 10             	pushl  0x10(%ebp)
  800d43:	ff 75 0c             	pushl  0xc(%ebp)
  800d46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d49:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d53:	e8 d7 fd ff ff       	call   800b2f <syscall>
}
  800d58:	c9                   	leave  
  800d59:	c3                   	ret    

00800d5a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5a:	f3 0f 1e fb          	endbr32 
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d64:	6a 00                	push   $0x0
  800d66:	6a 00                	push   $0x0
  800d68:	6a 00                	push   $0x0
  800d6a:	6a 00                	push   $0x0
  800d6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d6f:	ba 01 00 00 00       	mov    $0x1,%edx
  800d74:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d79:	e8 b1 fd ff ff       	call   800b2f <syscall>
}
  800d7e:	c9                   	leave  
  800d7f:	c3                   	ret    

00800d80 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	53                   	push   %ebx
  800d84:	83 ec 04             	sub    $0x4,%esp
	int r;

	// LAB 4: Your code here.
	void *addr = (void *) (pn * PGSIZE);
  800d87:	89 d3                	mov    %edx,%ebx
  800d89:	c1 e3 0c             	shl    $0xc,%ebx

	if (uvpt[pn] & PTE_SHARE) {
  800d8c:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d93:	f6 c5 04             	test   $0x4,%ch
  800d96:	75 56                	jne    800dee <duppage+0x6e>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
		return 0;
	}

	if ((uvpt[pn] & (PTE_W | PTE_COW)) != 0) {
  800d98:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d9f:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800da5:	74 72                	je     800e19 <duppage+0x99>
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW) <
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	68 05 08 00 00       	push   $0x805
  800daf:	53                   	push   %ebx
  800db0:	50                   	push   %eax
  800db1:	53                   	push   %ebx
  800db2:	6a 00                	push   $0x0
  800db4:	e8 b2 fe ff ff       	call   800c6b <sys_page_map>
  800db9:	83 c4 20             	add    $0x20,%esp
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	78 45                	js     800e05 <duppage+0x85>
		    0) {
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
		}
		if (sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW) < 0) {
  800dc0:	83 ec 0c             	sub    $0xc,%esp
  800dc3:	68 05 08 00 00       	push   $0x805
  800dc8:	53                   	push   %ebx
  800dc9:	6a 00                	push   $0x0
  800dcb:	53                   	push   %ebx
  800dcc:	6a 00                	push   $0x0
  800dce:	e8 98 fe ff ff       	call   800c6b <sys_page_map>
  800dd3:	83 c4 20             	add    $0x20,%esp
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	79 55                	jns    800e2f <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP FATHER");
  800dda:	83 ec 04             	sub    $0x4,%esp
  800ddd:	68 ac 27 80 00       	push   $0x8027ac
  800de2:	6a 54                	push   $0x54
  800de4:	68 3f 28 80 00       	push   $0x80283f
  800de9:	e8 7c f3 ff ff       	call   80016a <_panic>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800dee:	83 ec 0c             	sub    $0xc,%esp
  800df1:	68 07 0e 00 00       	push   $0xe07
  800df6:	53                   	push   %ebx
  800df7:	50                   	push   %eax
  800df8:	53                   	push   %ebx
  800df9:	6a 00                	push   $0x0
  800dfb:	e8 6b fe ff ff       	call   800c6b <sys_page_map>
		return 0;
  800e00:	83 c4 20             	add    $0x20,%esp
  800e03:	eb 2a                	jmp    800e2f <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
  800e05:	83 ec 04             	sub    $0x4,%esp
  800e08:	68 8c 27 80 00       	push   $0x80278c
  800e0d:	6a 51                	push   $0x51
  800e0f:	68 3f 28 80 00       	push   $0x80283f
  800e14:	e8 51 f3 ff ff       	call   80016a <_panic>
		}
	} else {
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U) < 0) {
  800e19:	83 ec 0c             	sub    $0xc,%esp
  800e1c:	6a 05                	push   $0x5
  800e1e:	53                   	push   %ebx
  800e1f:	50                   	push   %eax
  800e20:	53                   	push   %ebx
  800e21:	6a 00                	push   $0x0
  800e23:	e8 43 fe ff ff       	call   800c6b <sys_page_map>
  800e28:	83 c4 20             	add    $0x20,%esp
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	78 0a                	js     800e39 <duppage+0xb9>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
		}
	}

	return 0;
}
  800e2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e37:	c9                   	leave  
  800e38:	c3                   	ret    
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
  800e39:	83 ec 04             	sub    $0x4,%esp
  800e3c:	68 4a 28 80 00       	push   $0x80284a
  800e41:	6a 58                	push   $0x58
  800e43:	68 3f 28 80 00       	push   $0x80283f
  800e48:	e8 1d f3 ff ff       	call   80016a <_panic>

00800e4d <dup_or_share>:

static void
dup_or_share(envid_t dstenv, void *va, int perm)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	89 c6                	mov    %eax,%esi
  800e54:	89 d3                	mov    %edx,%ebx
	int r;
	if (perm & PTE_W) {
  800e56:	f6 c1 02             	test   $0x2,%cl
  800e59:	0f 84 8c 00 00 00    	je     800eeb <dup_or_share+0x9e>
		// dup
		if ((r = sys_page_alloc(dstenv, va, PTE_P | PTE_U | PTE_W)) < 0)
  800e5f:	83 ec 04             	sub    $0x4,%esp
  800e62:	6a 07                	push   $0x7
  800e64:	52                   	push   %edx
  800e65:	50                   	push   %eax
  800e66:	e8 d8 fd ff ff       	call   800c43 <sys_page_alloc>
  800e6b:	83 c4 10             	add    $0x10,%esp
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	78 55                	js     800ec7 <dup_or_share+0x7a>
			panic("sys_page_alloc: %e", r);
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  800e72:	83 ec 0c             	sub    $0xc,%esp
  800e75:	6a 07                	push   $0x7
  800e77:	68 00 00 40 00       	push   $0x400000
  800e7c:	6a 00                	push   $0x0
  800e7e:	53                   	push   %ebx
  800e7f:	56                   	push   %esi
  800e80:	e8 e6 fd ff ff       	call   800c6b <sys_page_map>
  800e85:	83 c4 20             	add    $0x20,%esp
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	78 4d                	js     800ed9 <dup_or_share+0x8c>
		    0)
			panic("sys_page_map: %e", r);
		memmove(UTEMP, va, PGSIZE);
  800e8c:	83 ec 04             	sub    $0x4,%esp
  800e8f:	68 00 10 00 00       	push   $0x1000
  800e94:	53                   	push   %ebx
  800e95:	68 00 00 40 00       	push   $0x400000
  800e9a:	e8 d4 fa ff ff       	call   800973 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800e9f:	83 c4 08             	add    $0x8,%esp
  800ea2:	68 00 00 40 00       	push   $0x400000
  800ea7:	6a 00                	push   $0x0
  800ea9:	e8 e7 fd ff ff       	call   800c95 <sys_page_unmap>
  800eae:	83 c4 10             	add    $0x10,%esp
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	79 52                	jns    800f07 <dup_or_share+0xba>
			panic("sys_page_unmap: %e", r);
  800eb5:	50                   	push   %eax
  800eb6:	68 8a 28 80 00       	push   $0x80288a
  800ebb:	6a 6c                	push   $0x6c
  800ebd:	68 3f 28 80 00       	push   $0x80283f
  800ec2:	e8 a3 f2 ff ff       	call   80016a <_panic>
			panic("sys_page_alloc: %e", r);
  800ec7:	50                   	push   %eax
  800ec8:	68 66 28 80 00       	push   $0x802866
  800ecd:	6a 66                	push   $0x66
  800ecf:	68 3f 28 80 00       	push   $0x80283f
  800ed4:	e8 91 f2 ff ff       	call   80016a <_panic>
			panic("sys_page_map: %e", r);
  800ed9:	50                   	push   %eax
  800eda:	68 79 28 80 00       	push   $0x802879
  800edf:	6a 69                	push   $0x69
  800ee1:	68 3f 28 80 00       	push   $0x80283f
  800ee6:	e8 7f f2 ff ff       	call   80016a <_panic>

	} else {
		// share
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | perm)) <
  800eeb:	83 ec 0c             	sub    $0xc,%esp
  800eee:	83 c9 05             	or     $0x5,%ecx
  800ef1:	51                   	push   %ecx
  800ef2:	68 00 00 40 00       	push   $0x400000
  800ef7:	6a 00                	push   $0x0
  800ef9:	52                   	push   %edx
  800efa:	50                   	push   %eax
  800efb:	e8 6b fd ff ff       	call   800c6b <sys_page_map>
  800f00:	83 c4 20             	add    $0x20,%esp
  800f03:	85 c0                	test   %eax,%eax
  800f05:	78 07                	js     800f0e <dup_or_share+0xc1>
		    0)
			panic("sys_page_map: %e", r);
	}
}
  800f07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f0a:	5b                   	pop    %ebx
  800f0b:	5e                   	pop    %esi
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    
			panic("sys_page_map: %e", r);
  800f0e:	50                   	push   %eax
  800f0f:	68 79 28 80 00       	push   $0x802879
  800f14:	6a 72                	push   $0x72
  800f16:	68 3f 28 80 00       	push   $0x80283f
  800f1b:	e8 4a f2 ff ff       	call   80016a <_panic>

00800f20 <pgfault>:
{
  800f20:	f3 0f 1e fb          	endbr32 
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	53                   	push   %ebx
  800f28:	83 ec 04             	sub    $0x4,%esp
  800f2b:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800f2e:	8b 02                	mov    (%edx),%eax
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800f30:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f34:	0f 84 95 00 00 00    	je     800fcf <pgfault+0xaf>
  800f3a:	89 c2                	mov    %eax,%edx
  800f3c:	c1 ea 16             	shr    $0x16,%edx
  800f3f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f46:	f6 c2 01             	test   $0x1,%dl
  800f49:	0f 84 80 00 00 00    	je     800fcf <pgfault+0xaf>
	    (~uvpt[PGNUM(addr)] & (PTE_COW | PTE_P)) != 0) {
  800f4f:	89 c2                	mov    %eax,%edx
  800f51:	c1 ea 0c             	shr    $0xc,%edx
  800f54:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f5b:	f7 d2                	not    %edx
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800f5d:	f7 c2 01 08 00 00    	test   $0x801,%edx
  800f63:	75 6a                	jne    800fcf <pgfault+0xaf>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800f65:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f6a:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U) < 0) {
  800f6c:	83 ec 04             	sub    $0x4,%esp
  800f6f:	6a 07                	push   $0x7
  800f71:	68 00 f0 7f 00       	push   $0x7ff000
  800f76:	6a 00                	push   $0x0
  800f78:	e8 c6 fc ff ff       	call   800c43 <sys_page_alloc>
  800f7d:	83 c4 10             	add    $0x10,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	78 5f                	js     800fe3 <pgfault+0xc3>
	memcpy((void *) PFTEMP, addr, PGSIZE);
  800f84:	83 ec 04             	sub    $0x4,%esp
  800f87:	68 00 10 00 00       	push   $0x1000
  800f8c:	53                   	push   %ebx
  800f8d:	68 00 f0 7f 00       	push   $0x7ff000
  800f92:	e8 42 fa ff ff       	call   8009d9 <memcpy>
	if (sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U) < 0) {
  800f97:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f9e:	53                   	push   %ebx
  800f9f:	6a 00                	push   $0x0
  800fa1:	68 00 f0 7f 00       	push   $0x7ff000
  800fa6:	6a 00                	push   $0x0
  800fa8:	e8 be fc ff ff       	call   800c6b <sys_page_map>
  800fad:	83 c4 20             	add    $0x20,%esp
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	78 43                	js     800ff7 <pgfault+0xd7>
	if (sys_page_unmap(0, (void *) PFTEMP) < 0) {
  800fb4:	83 ec 08             	sub    $0x8,%esp
  800fb7:	68 00 f0 7f 00       	push   $0x7ff000
  800fbc:	6a 00                	push   $0x0
  800fbe:	e8 d2 fc ff ff       	call   800c95 <sys_page_unmap>
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	78 41                	js     80100b <pgfault+0xeb>
}
  800fca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    
		panic("ERROR PGFAULT");
  800fcf:	83 ec 04             	sub    $0x4,%esp
  800fd2:	68 9d 28 80 00       	push   $0x80289d
  800fd7:	6a 1e                	push   $0x1e
  800fd9:	68 3f 28 80 00       	push   $0x80283f
  800fde:	e8 87 f1 ff ff       	call   80016a <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_ALLOC");
  800fe3:	83 ec 04             	sub    $0x4,%esp
  800fe6:	68 ab 28 80 00       	push   $0x8028ab
  800feb:	6a 2b                	push   $0x2b
  800fed:	68 3f 28 80 00       	push   $0x80283f
  800ff2:	e8 73 f1 ff ff       	call   80016a <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_MAP");
  800ff7:	83 ec 04             	sub    $0x4,%esp
  800ffa:	68 c9 28 80 00       	push   $0x8028c9
  800fff:	6a 2f                	push   $0x2f
  801001:	68 3f 28 80 00       	push   $0x80283f
  801006:	e8 5f f1 ff ff       	call   80016a <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_UNMAP");
  80100b:	83 ec 04             	sub    $0x4,%esp
  80100e:	68 e5 28 80 00       	push   $0x8028e5
  801013:	6a 32                	push   $0x32
  801015:	68 3f 28 80 00       	push   $0x80283f
  80101a:	e8 4b f1 ff ff       	call   80016a <_panic>

0080101f <fork_v0>:

envid_t
fork_v0(void)
{
  80101f:	f3 0f 1e fb          	endbr32 
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	57                   	push   %edi
  801027:	56                   	push   %esi
  801028:	53                   	push   %ebx
  801029:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80102c:	b8 07 00 00 00       	mov    $0x7,%eax
  801031:	cd 30                	int    $0x30
	envid_t env_id = sys_exofork();
	if (env_id < 0) {
  801033:	85 c0                	test   %eax,%eax
  801035:	78 24                	js     80105b <fork_v0+0x3c>
  801037:	89 c6                	mov    %eax,%esi
  801039:	89 c7                	mov    %eax,%edi
		thisenv = envs + ENVX(sys_getenvid());
		return env_id;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  80103b:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (env_id == 0) {  // Son
  801040:	75 51                	jne    801093 <fork_v0+0x74>
		thisenv = envs + ENVX(sys_getenvid());
  801042:	e8 a9 fb ff ff       	call   800bf0 <sys_getenvid>
  801047:	25 ff 03 00 00       	and    $0x3ff,%eax
  80104c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80104f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801054:	a3 04 40 80 00       	mov    %eax,0x804004
		return env_id;
  801059:	eb 78                	jmp    8010d3 <fork_v0+0xb4>
		panic("ERROR ON FORK_V0");
  80105b:	83 ec 04             	sub    $0x4,%esp
  80105e:	68 03 29 80 00       	push   $0x802903
  801063:	6a 7b                	push   $0x7b
  801065:	68 3f 28 80 00       	push   $0x80283f
  80106a:	e8 fb f0 ff ff       	call   80016a <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
				dup_or_share(env_id,
  80106f:	b9 07 00 00 00       	mov    $0x7,%ecx
  801074:	89 da                	mov    %ebx,%edx
  801076:	89 f8                	mov    %edi,%eax
  801078:	e8 d0 fd ff ff       	call   800e4d <dup_or_share>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  80107d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801083:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801089:	77 36                	ja     8010c1 <fork_v0+0xa2>
		if (addr != UXSTACKTOP - PGSIZE) {
  80108b:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801091:	74 ea                	je     80107d <fork_v0+0x5e>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801093:	89 d8                	mov    %ebx,%eax
  801095:	c1 e8 16             	shr    $0x16,%eax
  801098:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80109f:	a8 01                	test   $0x1,%al
  8010a1:	74 da                	je     80107d <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  8010a3:	89 d8                	mov    %ebx,%eax
  8010a5:	c1 e8 0c             	shr    $0xc,%eax
  8010a8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  8010af:	f6 c2 01             	test   $0x1,%dl
  8010b2:	74 c9                	je     80107d <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
  8010b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  8010bb:	a8 04                	test   $0x4,%al
  8010bd:	74 be                	je     80107d <fork_v0+0x5e>
  8010bf:	eb ae                	jmp    80106f <fork_v0+0x50>
				             PTE_P | PTE_U | PTE_W);
			}
		}
	}

	if (sys_env_set_status(env_id, ENV_RUNNABLE) < 0) {
  8010c1:	83 ec 08             	sub    $0x8,%esp
  8010c4:	6a 02                	push   $0x2
  8010c6:	56                   	push   %esi
  8010c7:	e8 f0 fb ff ff       	call   800cbc <sys_env_set_status>
  8010cc:	83 c4 10             	add    $0x10,%esp
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	78 0a                	js     8010dd <fork_v0+0xbe>
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
	}

	return env_id;
}
  8010d3:	89 f0                	mov    %esi,%eax
  8010d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5f                   	pop    %edi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
  8010dd:	83 ec 04             	sub    $0x4,%esp
  8010e0:	68 d0 27 80 00       	push   $0x8027d0
  8010e5:	68 92 00 00 00       	push   $0x92
  8010ea:	68 3f 28 80 00       	push   $0x80283f
  8010ef:	e8 76 f0 ff ff       	call   80016a <_panic>

008010f4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010f4:	f3 0f 1e fb          	endbr32 
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	57                   	push   %edi
  8010fc:	56                   	push   %esi
  8010fd:	53                   	push   %ebx
  8010fe:	83 ec 18             	sub    $0x18,%esp
	// return fork_v0(); // Uncomment this line if you want to run fork_v0.
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801101:	68 20 0f 80 00       	push   $0x800f20
  801106:	e8 a8 0f 00 00       	call   8020b3 <set_pgfault_handler>
  80110b:	b8 07 00 00 00       	mov    $0x7,%eax
  801110:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0) {
  801112:	83 c4 10             	add    $0x10,%esp
  801115:	85 c0                	test   %eax,%eax
  801117:	78 27                	js     801140 <fork+0x4c>
  801119:	89 c7                	mov    %eax,%edi
  80111b:	89 c6                	mov    %eax,%esi
		thisenv = envs + ENVX(sys_getenvid());
		return envid;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  80111d:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else if (envid == 0) {  // Son
  801122:	75 55                	jne    801179 <fork+0x85>
		thisenv = envs + ENVX(sys_getenvid());
  801124:	e8 c7 fa ff ff       	call   800bf0 <sys_getenvid>
  801129:	25 ff 03 00 00       	and    $0x3ff,%eax
  80112e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801131:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801136:	a3 04 40 80 00       	mov    %eax,0x804004
		return envid;
  80113b:	e9 9b 00 00 00       	jmp    8011db <fork+0xe7>
		panic("ERROR IN FORK: SYS_EXOFORK");
  801140:	83 ec 04             	sub    $0x4,%esp
  801143:	68 14 29 80 00       	push   $0x802914
  801148:	68 b1 00 00 00       	push   $0xb1
  80114d:	68 3f 28 80 00       	push   $0x80283f
  801152:	e8 13 f0 ff ff       	call   80016a <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
				duppage(envid, addr / PGSIZE);
  801157:	89 da                	mov    %ebx,%edx
  801159:	c1 ea 0c             	shr    $0xc,%edx
  80115c:	89 f0                	mov    %esi,%eax
  80115e:	e8 1d fc ff ff       	call   800d80 <duppage>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801163:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801169:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  80116f:	77 2c                	ja     80119d <fork+0xa9>
		if (addr != UXSTACKTOP - PGSIZE) {
  801171:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801177:	74 ea                	je     801163 <fork+0x6f>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801179:	89 d8                	mov    %ebx,%eax
  80117b:	c1 e8 16             	shr    $0x16,%eax
  80117e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801185:	a8 01                	test   $0x1,%al
  801187:	74 da                	je     801163 <fork+0x6f>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
  801189:	89 d8                	mov    %ebx,%eax
  80118b:	c1 e8 0c             	shr    $0xc,%eax
  80118e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801195:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801197:	a8 05                	test   $0x5,%al
  801199:	75 c8                	jne    801163 <fork+0x6f>
  80119b:	eb ba                	jmp    801157 <fork+0x63>
			}
		}
	}

	if (sys_page_alloc(envid,
  80119d:	83 ec 04             	sub    $0x4,%esp
  8011a0:	6a 07                	push   $0x7
  8011a2:	68 00 f0 bf ee       	push   $0xeebff000
  8011a7:	57                   	push   %edi
  8011a8:	e8 96 fa ff ff       	call   800c43 <sys_page_alloc>
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	78 31                	js     8011e5 <fork+0xf1>
	                   PTE_P | PTE_U | PTE_W) < 0) {
		panic("ERROR FORK: SYS_PAGE_ALLOC");
	}

	extern void _pgfault_upcall(void);
	if (sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0) {
  8011b4:	83 ec 08             	sub    $0x8,%esp
  8011b7:	68 26 21 80 00       	push   $0x802126
  8011bc:	57                   	push   %edi
  8011bd:	e8 48 fb ff ff       	call   800d0a <sys_env_set_pgfault_upcall>
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	78 33                	js     8011fc <fork+0x108>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
	}

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0) {
  8011c9:	83 ec 08             	sub    $0x8,%esp
  8011cc:	6a 02                	push   $0x2
  8011ce:	57                   	push   %edi
  8011cf:	e8 e8 fa ff ff       	call   800cbc <sys_env_set_status>
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	78 38                	js     801213 <fork+0x11f>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
	}

	return envid;
}
  8011db:	89 f8                	mov    %edi,%eax
  8011dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    
		panic("ERROR FORK: SYS_PAGE_ALLOC");
  8011e5:	83 ec 04             	sub    $0x4,%esp
  8011e8:	68 2f 29 80 00       	push   $0x80292f
  8011ed:	68 c4 00 00 00       	push   $0xc4
  8011f2:	68 3f 28 80 00       	push   $0x80283f
  8011f7:	e8 6e ef ff ff       	call   80016a <_panic>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
  8011fc:	83 ec 04             	sub    $0x4,%esp
  8011ff:	68 f8 27 80 00       	push   $0x8027f8
  801204:	68 c9 00 00 00       	push   $0xc9
  801209:	68 3f 28 80 00       	push   $0x80283f
  80120e:	e8 57 ef ff ff       	call   80016a <_panic>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
  801213:	83 ec 04             	sub    $0x4,%esp
  801216:	68 20 28 80 00       	push   $0x802820
  80121b:	68 cd 00 00 00       	push   $0xcd
  801220:	68 3f 28 80 00       	push   $0x80283f
  801225:	e8 40 ef ff ff       	call   80016a <_panic>

0080122a <sfork>:

// Challenge!
int
sfork(void)
{
  80122a:	f3 0f 1e fb          	endbr32 
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801234:	68 4a 29 80 00       	push   $0x80294a
  801239:	68 d7 00 00 00       	push   $0xd7
  80123e:	68 3f 28 80 00       	push   $0x80283f
  801243:	e8 22 ef ff ff       	call   80016a <_panic>

00801248 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801248:	f3 0f 1e fb          	endbr32 
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	56                   	push   %esi
  801250:	53                   	push   %ebx
  801251:	8b 75 08             	mov    0x8(%ebp),%esi
  801254:	8b 45 0c             	mov    0xc(%ebp),%eax
  801257:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  80125a:	85 c0                	test   %eax,%eax
  80125c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801261:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801264:	83 ec 0c             	sub    $0xc,%esp
  801267:	50                   	push   %eax
  801268:	e8 ed fa ff ff       	call   800d5a <sys_ipc_recv>
	if (f < 0) {
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	85 c0                	test   %eax,%eax
  801272:	78 2b                	js     80129f <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801274:	85 f6                	test   %esi,%esi
  801276:	74 0a                	je     801282 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801278:	a1 04 40 80 00       	mov    0x804004,%eax
  80127d:	8b 40 74             	mov    0x74(%eax),%eax
  801280:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801282:	85 db                	test   %ebx,%ebx
  801284:	74 0a                	je     801290 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801286:	a1 04 40 80 00       	mov    0x804004,%eax
  80128b:	8b 40 78             	mov    0x78(%eax),%eax
  80128e:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  801290:	a1 04 40 80 00       	mov    0x804004,%eax
  801295:	8b 40 70             	mov    0x70(%eax),%eax
}
  801298:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80129b:	5b                   	pop    %ebx
  80129c:	5e                   	pop    %esi
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    
		if (from_env_store != NULL) {
  80129f:	85 f6                	test   %esi,%esi
  8012a1:	74 06                	je     8012a9 <ipc_recv+0x61>
			*from_env_store = 0;
  8012a3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  8012a9:	85 db                	test   %ebx,%ebx
  8012ab:	74 eb                	je     801298 <ipc_recv+0x50>
			*perm_store = 0;
  8012ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012b3:	eb e3                	jmp    801298 <ipc_recv+0x50>

008012b5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012b5:	f3 0f 1e fb          	endbr32 
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	57                   	push   %edi
  8012bd:	56                   	push   %esi
  8012be:	53                   	push   %ebx
  8012bf:	83 ec 0c             	sub    $0xc,%esp
  8012c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  8012cb:	85 db                	test   %ebx,%ebx
  8012cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8012d2:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8012d5:	ff 75 14             	pushl  0x14(%ebp)
  8012d8:	53                   	push   %ebx
  8012d9:	56                   	push   %esi
  8012da:	57                   	push   %edi
  8012db:	e8 51 fa ff ff       	call   800d31 <sys_ipc_try_send>
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	79 19                	jns    801300 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  8012e7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012ea:	74 e9                	je     8012d5 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  8012ec:	83 ec 04             	sub    $0x4,%esp
  8012ef:	68 60 29 80 00       	push   $0x802960
  8012f4:	6a 48                	push   $0x48
  8012f6:	68 82 29 80 00       	push   $0x802982
  8012fb:	e8 6a ee ff ff       	call   80016a <_panic>
		}
	}
}
  801300:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801303:	5b                   	pop    %ebx
  801304:	5e                   	pop    %esi
  801305:	5f                   	pop    %edi
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    

00801308 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801308:	f3 0f 1e fb          	endbr32 
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801312:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801317:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80131a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801320:	8b 52 50             	mov    0x50(%edx),%edx
  801323:	39 ca                	cmp    %ecx,%edx
  801325:	74 11                	je     801338 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801327:	83 c0 01             	add    $0x1,%eax
  80132a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80132f:	75 e6                	jne    801317 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801331:	b8 00 00 00 00       	mov    $0x0,%eax
  801336:	eb 0b                	jmp    801343 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801338:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80133b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801340:	8b 40 48             	mov    0x48(%eax),%eax
}
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801345:	f3 0f 1e fb          	endbr32 
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80134c:	8b 45 08             	mov    0x8(%ebp),%eax
  80134f:	05 00 00 00 30       	add    $0x30000000,%eax
  801354:	c1 e8 0c             	shr    $0xc,%eax
}
  801357:	5d                   	pop    %ebp
  801358:	c3                   	ret    

00801359 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801359:	f3 0f 1e fb          	endbr32 
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  801363:	ff 75 08             	pushl  0x8(%ebp)
  801366:	e8 da ff ff ff       	call   801345 <fd2num>
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	c1 e0 0c             	shl    $0xc,%eax
  801371:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801376:	c9                   	leave  
  801377:	c3                   	ret    

00801378 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801378:	f3 0f 1e fb          	endbr32 
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801384:	89 c2                	mov    %eax,%edx
  801386:	c1 ea 16             	shr    $0x16,%edx
  801389:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801390:	f6 c2 01             	test   $0x1,%dl
  801393:	74 2d                	je     8013c2 <fd_alloc+0x4a>
  801395:	89 c2                	mov    %eax,%edx
  801397:	c1 ea 0c             	shr    $0xc,%edx
  80139a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013a1:	f6 c2 01             	test   $0x1,%dl
  8013a4:	74 1c                	je     8013c2 <fd_alloc+0x4a>
  8013a6:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8013ab:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013b0:	75 d2                	jne    801384 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8013bb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8013c0:	eb 0a                	jmp    8013cc <fd_alloc+0x54>
			*fd_store = fd;
  8013c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013c5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    

008013ce <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013ce:	f3 0f 1e fb          	endbr32 
  8013d2:	55                   	push   %ebp
  8013d3:	89 e5                	mov    %esp,%ebp
  8013d5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013d8:	83 f8 1f             	cmp    $0x1f,%eax
  8013db:	77 30                	ja     80140d <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013dd:	c1 e0 0c             	shl    $0xc,%eax
  8013e0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013e5:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8013eb:	f6 c2 01             	test   $0x1,%dl
  8013ee:	74 24                	je     801414 <fd_lookup+0x46>
  8013f0:	89 c2                	mov    %eax,%edx
  8013f2:	c1 ea 0c             	shr    $0xc,%edx
  8013f5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013fc:	f6 c2 01             	test   $0x1,%dl
  8013ff:	74 1a                	je     80141b <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801401:	8b 55 0c             	mov    0xc(%ebp),%edx
  801404:	89 02                	mov    %eax,(%edx)
	return 0;
  801406:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    
		return -E_INVAL;
  80140d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801412:	eb f7                	jmp    80140b <fd_lookup+0x3d>
		return -E_INVAL;
  801414:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801419:	eb f0                	jmp    80140b <fd_lookup+0x3d>
  80141b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801420:	eb e9                	jmp    80140b <fd_lookup+0x3d>

00801422 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801422:	f3 0f 1e fb          	endbr32 
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	83 ec 08             	sub    $0x8,%esp
  80142c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80142f:	ba 08 2a 80 00       	mov    $0x802a08,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801434:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801439:	39 08                	cmp    %ecx,(%eax)
  80143b:	74 33                	je     801470 <dev_lookup+0x4e>
  80143d:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801440:	8b 02                	mov    (%edx),%eax
  801442:	85 c0                	test   %eax,%eax
  801444:	75 f3                	jne    801439 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801446:	a1 04 40 80 00       	mov    0x804004,%eax
  80144b:	8b 40 48             	mov    0x48(%eax),%eax
  80144e:	83 ec 04             	sub    $0x4,%esp
  801451:	51                   	push   %ecx
  801452:	50                   	push   %eax
  801453:	68 8c 29 80 00       	push   $0x80298c
  801458:	e8 f4 ed ff ff       	call   800251 <cprintf>
	*dev = 0;
  80145d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801460:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801466:	83 c4 10             	add    $0x10,%esp
  801469:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80146e:	c9                   	leave  
  80146f:	c3                   	ret    
			*dev = devtab[i];
  801470:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801473:	89 01                	mov    %eax,(%ecx)
			return 0;
  801475:	b8 00 00 00 00       	mov    $0x0,%eax
  80147a:	eb f2                	jmp    80146e <dev_lookup+0x4c>

0080147c <fd_close>:
{
  80147c:	f3 0f 1e fb          	endbr32 
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	57                   	push   %edi
  801484:	56                   	push   %esi
  801485:	53                   	push   %ebx
  801486:	83 ec 28             	sub    $0x28,%esp
  801489:	8b 75 08             	mov    0x8(%ebp),%esi
  80148c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80148f:	56                   	push   %esi
  801490:	e8 b0 fe ff ff       	call   801345 <fd2num>
  801495:	83 c4 08             	add    $0x8,%esp
  801498:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80149b:	52                   	push   %edx
  80149c:	50                   	push   %eax
  80149d:	e8 2c ff ff ff       	call   8013ce <fd_lookup>
  8014a2:	89 c3                	mov    %eax,%ebx
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 05                	js     8014b0 <fd_close+0x34>
	    || fd != fd2)
  8014ab:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8014ae:	74 16                	je     8014c6 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8014b0:	89 f8                	mov    %edi,%eax
  8014b2:	84 c0                	test   %al,%al
  8014b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b9:	0f 44 d8             	cmove  %eax,%ebx
}
  8014bc:	89 d8                	mov    %ebx,%eax
  8014be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c1:	5b                   	pop    %ebx
  8014c2:	5e                   	pop    %esi
  8014c3:	5f                   	pop    %edi
  8014c4:	5d                   	pop    %ebp
  8014c5:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014c6:	83 ec 08             	sub    $0x8,%esp
  8014c9:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8014cc:	50                   	push   %eax
  8014cd:	ff 36                	pushl  (%esi)
  8014cf:	e8 4e ff ff ff       	call   801422 <dev_lookup>
  8014d4:	89 c3                	mov    %eax,%ebx
  8014d6:	83 c4 10             	add    $0x10,%esp
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 1a                	js     8014f7 <fd_close+0x7b>
		if (dev->dev_close)
  8014dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014e0:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8014e3:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	74 0b                	je     8014f7 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8014ec:	83 ec 0c             	sub    $0xc,%esp
  8014ef:	56                   	push   %esi
  8014f0:	ff d0                	call   *%eax
  8014f2:	89 c3                	mov    %eax,%ebx
  8014f4:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8014f7:	83 ec 08             	sub    $0x8,%esp
  8014fa:	56                   	push   %esi
  8014fb:	6a 00                	push   $0x0
  8014fd:	e8 93 f7 ff ff       	call   800c95 <sys_page_unmap>
	return r;
  801502:	83 c4 10             	add    $0x10,%esp
  801505:	eb b5                	jmp    8014bc <fd_close+0x40>

00801507 <close>:

int
close(int fdnum)
{
  801507:	f3 0f 1e fb          	endbr32 
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801511:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801514:	50                   	push   %eax
  801515:	ff 75 08             	pushl  0x8(%ebp)
  801518:	e8 b1 fe ff ff       	call   8013ce <fd_lookup>
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	85 c0                	test   %eax,%eax
  801522:	79 02                	jns    801526 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801524:	c9                   	leave  
  801525:	c3                   	ret    
		return fd_close(fd, 1);
  801526:	83 ec 08             	sub    $0x8,%esp
  801529:	6a 01                	push   $0x1
  80152b:	ff 75 f4             	pushl  -0xc(%ebp)
  80152e:	e8 49 ff ff ff       	call   80147c <fd_close>
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	eb ec                	jmp    801524 <close+0x1d>

00801538 <close_all>:

void
close_all(void)
{
  801538:	f3 0f 1e fb          	endbr32 
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	53                   	push   %ebx
  801540:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801543:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801548:	83 ec 0c             	sub    $0xc,%esp
  80154b:	53                   	push   %ebx
  80154c:	e8 b6 ff ff ff       	call   801507 <close>
	for (i = 0; i < MAXFD; i++)
  801551:	83 c3 01             	add    $0x1,%ebx
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	83 fb 20             	cmp    $0x20,%ebx
  80155a:	75 ec                	jne    801548 <close_all+0x10>
}
  80155c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155f:	c9                   	leave  
  801560:	c3                   	ret    

00801561 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801561:	f3 0f 1e fb          	endbr32 
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	57                   	push   %edi
  801569:	56                   	push   %esi
  80156a:	53                   	push   %ebx
  80156b:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80156e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	ff 75 08             	pushl  0x8(%ebp)
  801575:	e8 54 fe ff ff       	call   8013ce <fd_lookup>
  80157a:	89 c3                	mov    %eax,%ebx
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	85 c0                	test   %eax,%eax
  801581:	0f 88 81 00 00 00    	js     801608 <dup+0xa7>
		return r;
	close(newfdnum);
  801587:	83 ec 0c             	sub    $0xc,%esp
  80158a:	ff 75 0c             	pushl  0xc(%ebp)
  80158d:	e8 75 ff ff ff       	call   801507 <close>

	newfd = INDEX2FD(newfdnum);
  801592:	8b 75 0c             	mov    0xc(%ebp),%esi
  801595:	c1 e6 0c             	shl    $0xc,%esi
  801598:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80159e:	83 c4 04             	add    $0x4,%esp
  8015a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015a4:	e8 b0 fd ff ff       	call   801359 <fd2data>
  8015a9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015ab:	89 34 24             	mov    %esi,(%esp)
  8015ae:	e8 a6 fd ff ff       	call   801359 <fd2data>
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015b8:	89 d8                	mov    %ebx,%eax
  8015ba:	c1 e8 16             	shr    $0x16,%eax
  8015bd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015c4:	a8 01                	test   $0x1,%al
  8015c6:	74 11                	je     8015d9 <dup+0x78>
  8015c8:	89 d8                	mov    %ebx,%eax
  8015ca:	c1 e8 0c             	shr    $0xc,%eax
  8015cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015d4:	f6 c2 01             	test   $0x1,%dl
  8015d7:	75 39                	jne    801612 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015dc:	89 d0                	mov    %edx,%eax
  8015de:	c1 e8 0c             	shr    $0xc,%eax
  8015e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015e8:	83 ec 0c             	sub    $0xc,%esp
  8015eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8015f0:	50                   	push   %eax
  8015f1:	56                   	push   %esi
  8015f2:	6a 00                	push   $0x0
  8015f4:	52                   	push   %edx
  8015f5:	6a 00                	push   $0x0
  8015f7:	e8 6f f6 ff ff       	call   800c6b <sys_page_map>
  8015fc:	89 c3                	mov    %eax,%ebx
  8015fe:	83 c4 20             	add    $0x20,%esp
  801601:	85 c0                	test   %eax,%eax
  801603:	78 31                	js     801636 <dup+0xd5>
		goto err;

	return newfdnum;
  801605:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801608:	89 d8                	mov    %ebx,%eax
  80160a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160d:	5b                   	pop    %ebx
  80160e:	5e                   	pop    %esi
  80160f:	5f                   	pop    %edi
  801610:	5d                   	pop    %ebp
  801611:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801612:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801619:	83 ec 0c             	sub    $0xc,%esp
  80161c:	25 07 0e 00 00       	and    $0xe07,%eax
  801621:	50                   	push   %eax
  801622:	57                   	push   %edi
  801623:	6a 00                	push   $0x0
  801625:	53                   	push   %ebx
  801626:	6a 00                	push   $0x0
  801628:	e8 3e f6 ff ff       	call   800c6b <sys_page_map>
  80162d:	89 c3                	mov    %eax,%ebx
  80162f:	83 c4 20             	add    $0x20,%esp
  801632:	85 c0                	test   %eax,%eax
  801634:	79 a3                	jns    8015d9 <dup+0x78>
	sys_page_unmap(0, newfd);
  801636:	83 ec 08             	sub    $0x8,%esp
  801639:	56                   	push   %esi
  80163a:	6a 00                	push   $0x0
  80163c:	e8 54 f6 ff ff       	call   800c95 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801641:	83 c4 08             	add    $0x8,%esp
  801644:	57                   	push   %edi
  801645:	6a 00                	push   $0x0
  801647:	e8 49 f6 ff ff       	call   800c95 <sys_page_unmap>
	return r;
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	eb b7                	jmp    801608 <dup+0xa7>

00801651 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801651:	f3 0f 1e fb          	endbr32 
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	53                   	push   %ebx
  801659:	83 ec 1c             	sub    $0x1c,%esp
  80165c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801662:	50                   	push   %eax
  801663:	53                   	push   %ebx
  801664:	e8 65 fd ff ff       	call   8013ce <fd_lookup>
  801669:	83 c4 10             	add    $0x10,%esp
  80166c:	85 c0                	test   %eax,%eax
  80166e:	78 3f                	js     8016af <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801670:	83 ec 08             	sub    $0x8,%esp
  801673:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801676:	50                   	push   %eax
  801677:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167a:	ff 30                	pushl  (%eax)
  80167c:	e8 a1 fd ff ff       	call   801422 <dev_lookup>
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	85 c0                	test   %eax,%eax
  801686:	78 27                	js     8016af <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801688:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80168b:	8b 42 08             	mov    0x8(%edx),%eax
  80168e:	83 e0 03             	and    $0x3,%eax
  801691:	83 f8 01             	cmp    $0x1,%eax
  801694:	74 1e                	je     8016b4 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801696:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801699:	8b 40 08             	mov    0x8(%eax),%eax
  80169c:	85 c0                	test   %eax,%eax
  80169e:	74 35                	je     8016d5 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016a0:	83 ec 04             	sub    $0x4,%esp
  8016a3:	ff 75 10             	pushl  0x10(%ebp)
  8016a6:	ff 75 0c             	pushl  0xc(%ebp)
  8016a9:	52                   	push   %edx
  8016aa:	ff d0                	call   *%eax
  8016ac:	83 c4 10             	add    $0x10,%esp
}
  8016af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b2:	c9                   	leave  
  8016b3:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016b4:	a1 04 40 80 00       	mov    0x804004,%eax
  8016b9:	8b 40 48             	mov    0x48(%eax),%eax
  8016bc:	83 ec 04             	sub    $0x4,%esp
  8016bf:	53                   	push   %ebx
  8016c0:	50                   	push   %eax
  8016c1:	68 cd 29 80 00       	push   $0x8029cd
  8016c6:	e8 86 eb ff ff       	call   800251 <cprintf>
		return -E_INVAL;
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d3:	eb da                	jmp    8016af <read+0x5e>
		return -E_NOT_SUPP;
  8016d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016da:	eb d3                	jmp    8016af <read+0x5e>

008016dc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016dc:	f3 0f 1e fb          	endbr32 
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	57                   	push   %edi
  8016e4:	56                   	push   %esi
  8016e5:	53                   	push   %ebx
  8016e6:	83 ec 0c             	sub    $0xc,%esp
  8016e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016ec:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016f4:	eb 02                	jmp    8016f8 <readn+0x1c>
  8016f6:	01 c3                	add    %eax,%ebx
  8016f8:	39 f3                	cmp    %esi,%ebx
  8016fa:	73 21                	jae    80171d <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016fc:	83 ec 04             	sub    $0x4,%esp
  8016ff:	89 f0                	mov    %esi,%eax
  801701:	29 d8                	sub    %ebx,%eax
  801703:	50                   	push   %eax
  801704:	89 d8                	mov    %ebx,%eax
  801706:	03 45 0c             	add    0xc(%ebp),%eax
  801709:	50                   	push   %eax
  80170a:	57                   	push   %edi
  80170b:	e8 41 ff ff ff       	call   801651 <read>
		if (m < 0)
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	85 c0                	test   %eax,%eax
  801715:	78 04                	js     80171b <readn+0x3f>
			return m;
		if (m == 0)
  801717:	75 dd                	jne    8016f6 <readn+0x1a>
  801719:	eb 02                	jmp    80171d <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80171b:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80171d:	89 d8                	mov    %ebx,%eax
  80171f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801722:	5b                   	pop    %ebx
  801723:	5e                   	pop    %esi
  801724:	5f                   	pop    %edi
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    

00801727 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801727:	f3 0f 1e fb          	endbr32 
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	53                   	push   %ebx
  80172f:	83 ec 1c             	sub    $0x1c,%esp
  801732:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801735:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801738:	50                   	push   %eax
  801739:	53                   	push   %ebx
  80173a:	e8 8f fc ff ff       	call   8013ce <fd_lookup>
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	85 c0                	test   %eax,%eax
  801744:	78 3a                	js     801780 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801746:	83 ec 08             	sub    $0x8,%esp
  801749:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174c:	50                   	push   %eax
  80174d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801750:	ff 30                	pushl  (%eax)
  801752:	e8 cb fc ff ff       	call   801422 <dev_lookup>
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	85 c0                	test   %eax,%eax
  80175c:	78 22                	js     801780 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80175e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801761:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801765:	74 1e                	je     801785 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801767:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80176a:	8b 52 0c             	mov    0xc(%edx),%edx
  80176d:	85 d2                	test   %edx,%edx
  80176f:	74 35                	je     8017a6 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801771:	83 ec 04             	sub    $0x4,%esp
  801774:	ff 75 10             	pushl  0x10(%ebp)
  801777:	ff 75 0c             	pushl  0xc(%ebp)
  80177a:	50                   	push   %eax
  80177b:	ff d2                	call   *%edx
  80177d:	83 c4 10             	add    $0x10,%esp
}
  801780:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801783:	c9                   	leave  
  801784:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801785:	a1 04 40 80 00       	mov    0x804004,%eax
  80178a:	8b 40 48             	mov    0x48(%eax),%eax
  80178d:	83 ec 04             	sub    $0x4,%esp
  801790:	53                   	push   %ebx
  801791:	50                   	push   %eax
  801792:	68 e9 29 80 00       	push   $0x8029e9
  801797:	e8 b5 ea ff ff       	call   800251 <cprintf>
		return -E_INVAL;
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017a4:	eb da                	jmp    801780 <write+0x59>
		return -E_NOT_SUPP;
  8017a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017ab:	eb d3                	jmp    801780 <write+0x59>

008017ad <seek>:

int
seek(int fdnum, off_t offset)
{
  8017ad:	f3 0f 1e fb          	endbr32 
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ba:	50                   	push   %eax
  8017bb:	ff 75 08             	pushl  0x8(%ebp)
  8017be:	e8 0b fc ff ff       	call   8013ce <fd_lookup>
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	78 0e                	js     8017d8 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8017ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d8:	c9                   	leave  
  8017d9:	c3                   	ret    

008017da <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017da:	f3 0f 1e fb          	endbr32 
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 1c             	sub    $0x1c,%esp
  8017e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017eb:	50                   	push   %eax
  8017ec:	53                   	push   %ebx
  8017ed:	e8 dc fb ff ff       	call   8013ce <fd_lookup>
  8017f2:	83 c4 10             	add    $0x10,%esp
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	78 37                	js     801830 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f9:	83 ec 08             	sub    $0x8,%esp
  8017fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ff:	50                   	push   %eax
  801800:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801803:	ff 30                	pushl  (%eax)
  801805:	e8 18 fc ff ff       	call   801422 <dev_lookup>
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	85 c0                	test   %eax,%eax
  80180f:	78 1f                	js     801830 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801811:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801814:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801818:	74 1b                	je     801835 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80181a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80181d:	8b 52 18             	mov    0x18(%edx),%edx
  801820:	85 d2                	test   %edx,%edx
  801822:	74 32                	je     801856 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801824:	83 ec 08             	sub    $0x8,%esp
  801827:	ff 75 0c             	pushl  0xc(%ebp)
  80182a:	50                   	push   %eax
  80182b:	ff d2                	call   *%edx
  80182d:	83 c4 10             	add    $0x10,%esp
}
  801830:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801833:	c9                   	leave  
  801834:	c3                   	ret    
			thisenv->env_id, fdnum);
  801835:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80183a:	8b 40 48             	mov    0x48(%eax),%eax
  80183d:	83 ec 04             	sub    $0x4,%esp
  801840:	53                   	push   %ebx
  801841:	50                   	push   %eax
  801842:	68 ac 29 80 00       	push   $0x8029ac
  801847:	e8 05 ea ff ff       	call   800251 <cprintf>
		return -E_INVAL;
  80184c:	83 c4 10             	add    $0x10,%esp
  80184f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801854:	eb da                	jmp    801830 <ftruncate+0x56>
		return -E_NOT_SUPP;
  801856:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80185b:	eb d3                	jmp    801830 <ftruncate+0x56>

0080185d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80185d:	f3 0f 1e fb          	endbr32 
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	53                   	push   %ebx
  801865:	83 ec 1c             	sub    $0x1c,%esp
  801868:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80186b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80186e:	50                   	push   %eax
  80186f:	ff 75 08             	pushl  0x8(%ebp)
  801872:	e8 57 fb ff ff       	call   8013ce <fd_lookup>
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	85 c0                	test   %eax,%eax
  80187c:	78 4b                	js     8018c9 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187e:	83 ec 08             	sub    $0x8,%esp
  801881:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801884:	50                   	push   %eax
  801885:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801888:	ff 30                	pushl  (%eax)
  80188a:	e8 93 fb ff ff       	call   801422 <dev_lookup>
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	85 c0                	test   %eax,%eax
  801894:	78 33                	js     8018c9 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801896:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801899:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80189d:	74 2f                	je     8018ce <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80189f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018a2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018a9:	00 00 00 
	stat->st_isdir = 0;
  8018ac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018b3:	00 00 00 
	stat->st_dev = dev;
  8018b6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018bc:	83 ec 08             	sub    $0x8,%esp
  8018bf:	53                   	push   %ebx
  8018c0:	ff 75 f0             	pushl  -0x10(%ebp)
  8018c3:	ff 50 14             	call   *0x14(%eax)
  8018c6:	83 c4 10             	add    $0x10,%esp
}
  8018c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018cc:	c9                   	leave  
  8018cd:	c3                   	ret    
		return -E_NOT_SUPP;
  8018ce:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018d3:	eb f4                	jmp    8018c9 <fstat+0x6c>

008018d5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018d5:	f3 0f 1e fb          	endbr32 
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	56                   	push   %esi
  8018dd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018de:	83 ec 08             	sub    $0x8,%esp
  8018e1:	6a 00                	push   $0x0
  8018e3:	ff 75 08             	pushl  0x8(%ebp)
  8018e6:	e8 20 02 00 00       	call   801b0b <open>
  8018eb:	89 c3                	mov    %eax,%ebx
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	78 1b                	js     80190f <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8018f4:	83 ec 08             	sub    $0x8,%esp
  8018f7:	ff 75 0c             	pushl  0xc(%ebp)
  8018fa:	50                   	push   %eax
  8018fb:	e8 5d ff ff ff       	call   80185d <fstat>
  801900:	89 c6                	mov    %eax,%esi
	close(fd);
  801902:	89 1c 24             	mov    %ebx,(%esp)
  801905:	e8 fd fb ff ff       	call   801507 <close>
	return r;
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	89 f3                	mov    %esi,%ebx
}
  80190f:	89 d8                	mov    %ebx,%eax
  801911:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801914:	5b                   	pop    %ebx
  801915:	5e                   	pop    %esi
  801916:	5d                   	pop    %ebp
  801917:	c3                   	ret    

00801918 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	56                   	push   %esi
  80191c:	53                   	push   %ebx
  80191d:	89 c6                	mov    %eax,%esi
  80191f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801921:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801928:	74 27                	je     801951 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80192a:	6a 07                	push   $0x7
  80192c:	68 00 50 80 00       	push   $0x805000
  801931:	56                   	push   %esi
  801932:	ff 35 00 40 80 00    	pushl  0x804000
  801938:	e8 78 f9 ff ff       	call   8012b5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80193d:	83 c4 0c             	add    $0xc,%esp
  801940:	6a 00                	push   $0x0
  801942:	53                   	push   %ebx
  801943:	6a 00                	push   $0x0
  801945:	e8 fe f8 ff ff       	call   801248 <ipc_recv>
}
  80194a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194d:	5b                   	pop    %ebx
  80194e:	5e                   	pop    %esi
  80194f:	5d                   	pop    %ebp
  801950:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801951:	83 ec 0c             	sub    $0xc,%esp
  801954:	6a 01                	push   $0x1
  801956:	e8 ad f9 ff ff       	call   801308 <ipc_find_env>
  80195b:	a3 00 40 80 00       	mov    %eax,0x804000
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	eb c5                	jmp    80192a <fsipc+0x12>

00801965 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801965:	f3 0f 1e fb          	endbr32 
  801969:	55                   	push   %ebp
  80196a:	89 e5                	mov    %esp,%ebp
  80196c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80196f:	8b 45 08             	mov    0x8(%ebp),%eax
  801972:	8b 40 0c             	mov    0xc(%eax),%eax
  801975:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80197a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801982:	ba 00 00 00 00       	mov    $0x0,%edx
  801987:	b8 02 00 00 00       	mov    $0x2,%eax
  80198c:	e8 87 ff ff ff       	call   801918 <fsipc>
}
  801991:	c9                   	leave  
  801992:	c3                   	ret    

00801993 <devfile_flush>:
{
  801993:	f3 0f 1e fb          	endbr32 
  801997:	55                   	push   %ebp
  801998:	89 e5                	mov    %esp,%ebp
  80199a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80199d:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8019a3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ad:	b8 06 00 00 00       	mov    $0x6,%eax
  8019b2:	e8 61 ff ff ff       	call   801918 <fsipc>
}
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <devfile_stat>:
{
  8019b9:	f3 0f 1e fb          	endbr32 
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	53                   	push   %ebx
  8019c1:	83 ec 04             	sub    $0x4,%esp
  8019c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8019cd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d7:	b8 05 00 00 00       	mov    $0x5,%eax
  8019dc:	e8 37 ff ff ff       	call   801918 <fsipc>
  8019e1:	85 c0                	test   %eax,%eax
  8019e3:	78 2c                	js     801a11 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019e5:	83 ec 08             	sub    $0x8,%esp
  8019e8:	68 00 50 80 00       	push   $0x805000
  8019ed:	53                   	push   %ebx
  8019ee:	e8 c8 ed ff ff       	call   8007bb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019f3:	a1 80 50 80 00       	mov    0x805080,%eax
  8019f8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019fe:	a1 84 50 80 00       	mov    0x805084,%eax
  801a03:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a09:	83 c4 10             	add    $0x10,%esp
  801a0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    

00801a16 <devfile_write>:
{
  801a16:	f3 0f 1e fb          	endbr32 
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	57                   	push   %edi
  801a1e:	56                   	push   %esi
  801a1f:	53                   	push   %ebx
  801a20:	83 ec 0c             	sub    $0xc,%esp
  801a23:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a29:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a2f:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  801a34:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a39:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  801a3e:	85 db                	test   %ebx,%ebx
  801a40:	74 3b                	je     801a7d <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a42:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801a48:	89 f8                	mov    %edi,%eax
  801a4a:	0f 46 c3             	cmovbe %ebx,%eax
  801a4d:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  801a52:	83 ec 04             	sub    $0x4,%esp
  801a55:	50                   	push   %eax
  801a56:	56                   	push   %esi
  801a57:	68 08 50 80 00       	push   $0x805008
  801a5c:	e8 12 ef ff ff       	call   800973 <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a61:	ba 00 00 00 00       	mov    $0x0,%edx
  801a66:	b8 04 00 00 00       	mov    $0x4,%eax
  801a6b:	e8 a8 fe ff ff       	call   801918 <fsipc>
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	85 c0                	test   %eax,%eax
  801a75:	78 06                	js     801a7d <devfile_write+0x67>
		buf_aux += r;
  801a77:	01 c6                	add    %eax,%esi
		n -= r;
  801a79:	29 c3                	sub    %eax,%ebx
  801a7b:	eb c1                	jmp    801a3e <devfile_write+0x28>
}
  801a7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a80:	5b                   	pop    %ebx
  801a81:	5e                   	pop    %esi
  801a82:	5f                   	pop    %edi
  801a83:	5d                   	pop    %ebp
  801a84:	c3                   	ret    

00801a85 <devfile_read>:
{
  801a85:	f3 0f 1e fb          	endbr32 
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	56                   	push   %esi
  801a8d:	53                   	push   %ebx
  801a8e:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a91:	8b 45 08             	mov    0x8(%ebp),%eax
  801a94:	8b 40 0c             	mov    0xc(%eax),%eax
  801a97:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a9c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aa2:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa7:	b8 03 00 00 00       	mov    $0x3,%eax
  801aac:	e8 67 fe ff ff       	call   801918 <fsipc>
  801ab1:	89 c3                	mov    %eax,%ebx
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	78 1f                	js     801ad6 <devfile_read+0x51>
	assert(r <= n);
  801ab7:	39 f0                	cmp    %esi,%eax
  801ab9:	77 24                	ja     801adf <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801abb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ac0:	7f 33                	jg     801af5 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ac2:	83 ec 04             	sub    $0x4,%esp
  801ac5:	50                   	push   %eax
  801ac6:	68 00 50 80 00       	push   $0x805000
  801acb:	ff 75 0c             	pushl  0xc(%ebp)
  801ace:	e8 a0 ee ff ff       	call   800973 <memmove>
	return r;
  801ad3:	83 c4 10             	add    $0x10,%esp
}
  801ad6:	89 d8                	mov    %ebx,%eax
  801ad8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801adb:	5b                   	pop    %ebx
  801adc:	5e                   	pop    %esi
  801add:	5d                   	pop    %ebp
  801ade:	c3                   	ret    
	assert(r <= n);
  801adf:	68 18 2a 80 00       	push   $0x802a18
  801ae4:	68 1f 2a 80 00       	push   $0x802a1f
  801ae9:	6a 7c                	push   $0x7c
  801aeb:	68 34 2a 80 00       	push   $0x802a34
  801af0:	e8 75 e6 ff ff       	call   80016a <_panic>
	assert(r <= PGSIZE);
  801af5:	68 3f 2a 80 00       	push   $0x802a3f
  801afa:	68 1f 2a 80 00       	push   $0x802a1f
  801aff:	6a 7d                	push   $0x7d
  801b01:	68 34 2a 80 00       	push   $0x802a34
  801b06:	e8 5f e6 ff ff       	call   80016a <_panic>

00801b0b <open>:
{
  801b0b:	f3 0f 1e fb          	endbr32 
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
  801b14:	83 ec 1c             	sub    $0x1c,%esp
  801b17:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801b1a:	56                   	push   %esi
  801b1b:	e8 58 ec ff ff       	call   800778 <strlen>
  801b20:	83 c4 10             	add    $0x10,%esp
  801b23:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b28:	7f 6c                	jg     801b96 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801b2a:	83 ec 0c             	sub    $0xc,%esp
  801b2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b30:	50                   	push   %eax
  801b31:	e8 42 f8 ff ff       	call   801378 <fd_alloc>
  801b36:	89 c3                	mov    %eax,%ebx
  801b38:	83 c4 10             	add    $0x10,%esp
  801b3b:	85 c0                	test   %eax,%eax
  801b3d:	78 3c                	js     801b7b <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801b3f:	83 ec 08             	sub    $0x8,%esp
  801b42:	56                   	push   %esi
  801b43:	68 00 50 80 00       	push   $0x805000
  801b48:	e8 6e ec ff ff       	call   8007bb <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b50:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b55:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b58:	b8 01 00 00 00       	mov    $0x1,%eax
  801b5d:	e8 b6 fd ff ff       	call   801918 <fsipc>
  801b62:	89 c3                	mov    %eax,%ebx
  801b64:	83 c4 10             	add    $0x10,%esp
  801b67:	85 c0                	test   %eax,%eax
  801b69:	78 19                	js     801b84 <open+0x79>
	return fd2num(fd);
  801b6b:	83 ec 0c             	sub    $0xc,%esp
  801b6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b71:	e8 cf f7 ff ff       	call   801345 <fd2num>
  801b76:	89 c3                	mov    %eax,%ebx
  801b78:	83 c4 10             	add    $0x10,%esp
}
  801b7b:	89 d8                	mov    %ebx,%eax
  801b7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b80:	5b                   	pop    %ebx
  801b81:	5e                   	pop    %esi
  801b82:	5d                   	pop    %ebp
  801b83:	c3                   	ret    
		fd_close(fd, 0);
  801b84:	83 ec 08             	sub    $0x8,%esp
  801b87:	6a 00                	push   $0x0
  801b89:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8c:	e8 eb f8 ff ff       	call   80147c <fd_close>
		return r;
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	eb e5                	jmp    801b7b <open+0x70>
		return -E_BAD_PATH;
  801b96:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801b9b:	eb de                	jmp    801b7b <open+0x70>

00801b9d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b9d:	f3 0f 1e fb          	endbr32 
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ba7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bac:	b8 08 00 00 00       	mov    $0x8,%eax
  801bb1:	e8 62 fd ff ff       	call   801918 <fsipc>
}
  801bb6:	c9                   	leave  
  801bb7:	c3                   	ret    

00801bb8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bb8:	f3 0f 1e fb          	endbr32 
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	56                   	push   %esi
  801bc0:	53                   	push   %ebx
  801bc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bc4:	83 ec 0c             	sub    $0xc,%esp
  801bc7:	ff 75 08             	pushl  0x8(%ebp)
  801bca:	e8 8a f7 ff ff       	call   801359 <fd2data>
  801bcf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bd1:	83 c4 08             	add    $0x8,%esp
  801bd4:	68 4b 2a 80 00       	push   $0x802a4b
  801bd9:	53                   	push   %ebx
  801bda:	e8 dc eb ff ff       	call   8007bb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bdf:	8b 46 04             	mov    0x4(%esi),%eax
  801be2:	2b 06                	sub    (%esi),%eax
  801be4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bf1:	00 00 00 
	stat->st_dev = &devpipe;
  801bf4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bfb:	30 80 00 
	return 0;
}
  801bfe:	b8 00 00 00 00       	mov    $0x0,%eax
  801c03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c06:	5b                   	pop    %ebx
  801c07:	5e                   	pop    %esi
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    

00801c0a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c0a:	f3 0f 1e fb          	endbr32 
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	53                   	push   %ebx
  801c12:	83 ec 0c             	sub    $0xc,%esp
  801c15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c18:	53                   	push   %ebx
  801c19:	6a 00                	push   $0x0
  801c1b:	e8 75 f0 ff ff       	call   800c95 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c20:	89 1c 24             	mov    %ebx,(%esp)
  801c23:	e8 31 f7 ff ff       	call   801359 <fd2data>
  801c28:	83 c4 08             	add    $0x8,%esp
  801c2b:	50                   	push   %eax
  801c2c:	6a 00                	push   $0x0
  801c2e:	e8 62 f0 ff ff       	call   800c95 <sys_page_unmap>
}
  801c33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c36:	c9                   	leave  
  801c37:	c3                   	ret    

00801c38 <_pipeisclosed>:
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	57                   	push   %edi
  801c3c:	56                   	push   %esi
  801c3d:	53                   	push   %ebx
  801c3e:	83 ec 1c             	sub    $0x1c,%esp
  801c41:	89 c7                	mov    %eax,%edi
  801c43:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c45:	a1 04 40 80 00       	mov    0x804004,%eax
  801c4a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c4d:	83 ec 0c             	sub    $0xc,%esp
  801c50:	57                   	push   %edi
  801c51:	e8 f6 04 00 00       	call   80214c <pageref>
  801c56:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c59:	89 34 24             	mov    %esi,(%esp)
  801c5c:	e8 eb 04 00 00       	call   80214c <pageref>
		nn = thisenv->env_runs;
  801c61:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c67:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c6a:	83 c4 10             	add    $0x10,%esp
  801c6d:	39 cb                	cmp    %ecx,%ebx
  801c6f:	74 1b                	je     801c8c <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c71:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c74:	75 cf                	jne    801c45 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c76:	8b 42 58             	mov    0x58(%edx),%eax
  801c79:	6a 01                	push   $0x1
  801c7b:	50                   	push   %eax
  801c7c:	53                   	push   %ebx
  801c7d:	68 52 2a 80 00       	push   $0x802a52
  801c82:	e8 ca e5 ff ff       	call   800251 <cprintf>
  801c87:	83 c4 10             	add    $0x10,%esp
  801c8a:	eb b9                	jmp    801c45 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c8c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c8f:	0f 94 c0             	sete   %al
  801c92:	0f b6 c0             	movzbl %al,%eax
}
  801c95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c98:	5b                   	pop    %ebx
  801c99:	5e                   	pop    %esi
  801c9a:	5f                   	pop    %edi
  801c9b:	5d                   	pop    %ebp
  801c9c:	c3                   	ret    

00801c9d <devpipe_write>:
{
  801c9d:	f3 0f 1e fb          	endbr32 
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	57                   	push   %edi
  801ca5:	56                   	push   %esi
  801ca6:	53                   	push   %ebx
  801ca7:	83 ec 28             	sub    $0x28,%esp
  801caa:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801cad:	56                   	push   %esi
  801cae:	e8 a6 f6 ff ff       	call   801359 <fd2data>
  801cb3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	bf 00 00 00 00       	mov    $0x0,%edi
  801cbd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cc0:	74 4f                	je     801d11 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cc2:	8b 43 04             	mov    0x4(%ebx),%eax
  801cc5:	8b 0b                	mov    (%ebx),%ecx
  801cc7:	8d 51 20             	lea    0x20(%ecx),%edx
  801cca:	39 d0                	cmp    %edx,%eax
  801ccc:	72 14                	jb     801ce2 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801cce:	89 da                	mov    %ebx,%edx
  801cd0:	89 f0                	mov    %esi,%eax
  801cd2:	e8 61 ff ff ff       	call   801c38 <_pipeisclosed>
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	75 3b                	jne    801d16 <devpipe_write+0x79>
			sys_yield();
  801cdb:	e8 38 ef ff ff       	call   800c18 <sys_yield>
  801ce0:	eb e0                	jmp    801cc2 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ce5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ce9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cec:	89 c2                	mov    %eax,%edx
  801cee:	c1 fa 1f             	sar    $0x1f,%edx
  801cf1:	89 d1                	mov    %edx,%ecx
  801cf3:	c1 e9 1b             	shr    $0x1b,%ecx
  801cf6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cf9:	83 e2 1f             	and    $0x1f,%edx
  801cfc:	29 ca                	sub    %ecx,%edx
  801cfe:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d02:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d06:	83 c0 01             	add    $0x1,%eax
  801d09:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d0c:	83 c7 01             	add    $0x1,%edi
  801d0f:	eb ac                	jmp    801cbd <devpipe_write+0x20>
	return i;
  801d11:	8b 45 10             	mov    0x10(%ebp),%eax
  801d14:	eb 05                	jmp    801d1b <devpipe_write+0x7e>
				return 0;
  801d16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d1e:	5b                   	pop    %ebx
  801d1f:	5e                   	pop    %esi
  801d20:	5f                   	pop    %edi
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    

00801d23 <devpipe_read>:
{
  801d23:	f3 0f 1e fb          	endbr32 
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	57                   	push   %edi
  801d2b:	56                   	push   %esi
  801d2c:	53                   	push   %ebx
  801d2d:	83 ec 18             	sub    $0x18,%esp
  801d30:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d33:	57                   	push   %edi
  801d34:	e8 20 f6 ff ff       	call   801359 <fd2data>
  801d39:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d3b:	83 c4 10             	add    $0x10,%esp
  801d3e:	be 00 00 00 00       	mov    $0x0,%esi
  801d43:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d46:	75 14                	jne    801d5c <devpipe_read+0x39>
	return i;
  801d48:	8b 45 10             	mov    0x10(%ebp),%eax
  801d4b:	eb 02                	jmp    801d4f <devpipe_read+0x2c>
				return i;
  801d4d:	89 f0                	mov    %esi,%eax
}
  801d4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d52:	5b                   	pop    %ebx
  801d53:	5e                   	pop    %esi
  801d54:	5f                   	pop    %edi
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    
			sys_yield();
  801d57:	e8 bc ee ff ff       	call   800c18 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d5c:	8b 03                	mov    (%ebx),%eax
  801d5e:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d61:	75 18                	jne    801d7b <devpipe_read+0x58>
			if (i > 0)
  801d63:	85 f6                	test   %esi,%esi
  801d65:	75 e6                	jne    801d4d <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801d67:	89 da                	mov    %ebx,%edx
  801d69:	89 f8                	mov    %edi,%eax
  801d6b:	e8 c8 fe ff ff       	call   801c38 <_pipeisclosed>
  801d70:	85 c0                	test   %eax,%eax
  801d72:	74 e3                	je     801d57 <devpipe_read+0x34>
				return 0;
  801d74:	b8 00 00 00 00       	mov    $0x0,%eax
  801d79:	eb d4                	jmp    801d4f <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d7b:	99                   	cltd   
  801d7c:	c1 ea 1b             	shr    $0x1b,%edx
  801d7f:	01 d0                	add    %edx,%eax
  801d81:	83 e0 1f             	and    $0x1f,%eax
  801d84:	29 d0                	sub    %edx,%eax
  801d86:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d8e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d91:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d94:	83 c6 01             	add    $0x1,%esi
  801d97:	eb aa                	jmp    801d43 <devpipe_read+0x20>

00801d99 <pipe>:
{
  801d99:	f3 0f 1e fb          	endbr32 
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	56                   	push   %esi
  801da1:	53                   	push   %ebx
  801da2:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801da5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da8:	50                   	push   %eax
  801da9:	e8 ca f5 ff ff       	call   801378 <fd_alloc>
  801dae:	89 c3                	mov    %eax,%ebx
  801db0:	83 c4 10             	add    $0x10,%esp
  801db3:	85 c0                	test   %eax,%eax
  801db5:	0f 88 23 01 00 00    	js     801ede <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dbb:	83 ec 04             	sub    $0x4,%esp
  801dbe:	68 07 04 00 00       	push   $0x407
  801dc3:	ff 75 f4             	pushl  -0xc(%ebp)
  801dc6:	6a 00                	push   $0x0
  801dc8:	e8 76 ee ff ff       	call   800c43 <sys_page_alloc>
  801dcd:	89 c3                	mov    %eax,%ebx
  801dcf:	83 c4 10             	add    $0x10,%esp
  801dd2:	85 c0                	test   %eax,%eax
  801dd4:	0f 88 04 01 00 00    	js     801ede <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801dda:	83 ec 0c             	sub    $0xc,%esp
  801ddd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801de0:	50                   	push   %eax
  801de1:	e8 92 f5 ff ff       	call   801378 <fd_alloc>
  801de6:	89 c3                	mov    %eax,%ebx
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	85 c0                	test   %eax,%eax
  801ded:	0f 88 db 00 00 00    	js     801ece <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df3:	83 ec 04             	sub    $0x4,%esp
  801df6:	68 07 04 00 00       	push   $0x407
  801dfb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dfe:	6a 00                	push   $0x0
  801e00:	e8 3e ee ff ff       	call   800c43 <sys_page_alloc>
  801e05:	89 c3                	mov    %eax,%ebx
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	0f 88 bc 00 00 00    	js     801ece <pipe+0x135>
	va = fd2data(fd0);
  801e12:	83 ec 0c             	sub    $0xc,%esp
  801e15:	ff 75 f4             	pushl  -0xc(%ebp)
  801e18:	e8 3c f5 ff ff       	call   801359 <fd2data>
  801e1d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e1f:	83 c4 0c             	add    $0xc,%esp
  801e22:	68 07 04 00 00       	push   $0x407
  801e27:	50                   	push   %eax
  801e28:	6a 00                	push   $0x0
  801e2a:	e8 14 ee ff ff       	call   800c43 <sys_page_alloc>
  801e2f:	89 c3                	mov    %eax,%ebx
  801e31:	83 c4 10             	add    $0x10,%esp
  801e34:	85 c0                	test   %eax,%eax
  801e36:	0f 88 82 00 00 00    	js     801ebe <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e3c:	83 ec 0c             	sub    $0xc,%esp
  801e3f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e42:	e8 12 f5 ff ff       	call   801359 <fd2data>
  801e47:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e4e:	50                   	push   %eax
  801e4f:	6a 00                	push   $0x0
  801e51:	56                   	push   %esi
  801e52:	6a 00                	push   $0x0
  801e54:	e8 12 ee ff ff       	call   800c6b <sys_page_map>
  801e59:	89 c3                	mov    %eax,%ebx
  801e5b:	83 c4 20             	add    $0x20,%esp
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	78 4e                	js     801eb0 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801e62:	a1 20 30 80 00       	mov    0x803020,%eax
  801e67:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e6a:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801e6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e6f:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e76:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e79:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801e7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e7e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e85:	83 ec 0c             	sub    $0xc,%esp
  801e88:	ff 75 f4             	pushl  -0xc(%ebp)
  801e8b:	e8 b5 f4 ff ff       	call   801345 <fd2num>
  801e90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e93:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e95:	83 c4 04             	add    $0x4,%esp
  801e98:	ff 75 f0             	pushl  -0x10(%ebp)
  801e9b:	e8 a5 f4 ff ff       	call   801345 <fd2num>
  801ea0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ea3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ea6:	83 c4 10             	add    $0x10,%esp
  801ea9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801eae:	eb 2e                	jmp    801ede <pipe+0x145>
	sys_page_unmap(0, va);
  801eb0:	83 ec 08             	sub    $0x8,%esp
  801eb3:	56                   	push   %esi
  801eb4:	6a 00                	push   $0x0
  801eb6:	e8 da ed ff ff       	call   800c95 <sys_page_unmap>
  801ebb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ebe:	83 ec 08             	sub    $0x8,%esp
  801ec1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec4:	6a 00                	push   $0x0
  801ec6:	e8 ca ed ff ff       	call   800c95 <sys_page_unmap>
  801ecb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801ece:	83 ec 08             	sub    $0x8,%esp
  801ed1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed4:	6a 00                	push   $0x0
  801ed6:	e8 ba ed ff ff       	call   800c95 <sys_page_unmap>
  801edb:	83 c4 10             	add    $0x10,%esp
}
  801ede:	89 d8                	mov    %ebx,%eax
  801ee0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee3:	5b                   	pop    %ebx
  801ee4:	5e                   	pop    %esi
  801ee5:	5d                   	pop    %ebp
  801ee6:	c3                   	ret    

00801ee7 <pipeisclosed>:
{
  801ee7:	f3 0f 1e fb          	endbr32 
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ef1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef4:	50                   	push   %eax
  801ef5:	ff 75 08             	pushl  0x8(%ebp)
  801ef8:	e8 d1 f4 ff ff       	call   8013ce <fd_lookup>
  801efd:	83 c4 10             	add    $0x10,%esp
  801f00:	85 c0                	test   %eax,%eax
  801f02:	78 18                	js     801f1c <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801f04:	83 ec 0c             	sub    $0xc,%esp
  801f07:	ff 75 f4             	pushl  -0xc(%ebp)
  801f0a:	e8 4a f4 ff ff       	call   801359 <fd2data>
  801f0f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f14:	e8 1f fd ff ff       	call   801c38 <_pipeisclosed>
  801f19:	83 c4 10             	add    $0x10,%esp
}
  801f1c:	c9                   	leave  
  801f1d:	c3                   	ret    

00801f1e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f1e:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801f22:	b8 00 00 00 00       	mov    $0x0,%eax
  801f27:	c3                   	ret    

00801f28 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f28:	f3 0f 1e fb          	endbr32 
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f32:	68 6a 2a 80 00       	push   $0x802a6a
  801f37:	ff 75 0c             	pushl  0xc(%ebp)
  801f3a:	e8 7c e8 ff ff       	call   8007bb <strcpy>
	return 0;
}
  801f3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f44:	c9                   	leave  
  801f45:	c3                   	ret    

00801f46 <devcons_write>:
{
  801f46:	f3 0f 1e fb          	endbr32 
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
  801f4d:	57                   	push   %edi
  801f4e:	56                   	push   %esi
  801f4f:	53                   	push   %ebx
  801f50:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f56:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f5b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f61:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f64:	73 31                	jae    801f97 <devcons_write+0x51>
		m = n - tot;
  801f66:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f69:	29 f3                	sub    %esi,%ebx
  801f6b:	83 fb 7f             	cmp    $0x7f,%ebx
  801f6e:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f73:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f76:	83 ec 04             	sub    $0x4,%esp
  801f79:	53                   	push   %ebx
  801f7a:	89 f0                	mov    %esi,%eax
  801f7c:	03 45 0c             	add    0xc(%ebp),%eax
  801f7f:	50                   	push   %eax
  801f80:	57                   	push   %edi
  801f81:	e8 ed e9 ff ff       	call   800973 <memmove>
		sys_cputs(buf, m);
  801f86:	83 c4 08             	add    $0x8,%esp
  801f89:	53                   	push   %ebx
  801f8a:	57                   	push   %edi
  801f8b:	e8 e8 eb ff ff       	call   800b78 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f90:	01 de                	add    %ebx,%esi
  801f92:	83 c4 10             	add    $0x10,%esp
  801f95:	eb ca                	jmp    801f61 <devcons_write+0x1b>
}
  801f97:	89 f0                	mov    %esi,%eax
  801f99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f9c:	5b                   	pop    %ebx
  801f9d:	5e                   	pop    %esi
  801f9e:	5f                   	pop    %edi
  801f9f:	5d                   	pop    %ebp
  801fa0:	c3                   	ret    

00801fa1 <devcons_read>:
{
  801fa1:	f3 0f 1e fb          	endbr32 
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	83 ec 08             	sub    $0x8,%esp
  801fab:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801fb0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fb4:	74 21                	je     801fd7 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801fb6:	e8 e7 eb ff ff       	call   800ba2 <sys_cgetc>
  801fbb:	85 c0                	test   %eax,%eax
  801fbd:	75 07                	jne    801fc6 <devcons_read+0x25>
		sys_yield();
  801fbf:	e8 54 ec ff ff       	call   800c18 <sys_yield>
  801fc4:	eb f0                	jmp    801fb6 <devcons_read+0x15>
	if (c < 0)
  801fc6:	78 0f                	js     801fd7 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801fc8:	83 f8 04             	cmp    $0x4,%eax
  801fcb:	74 0c                	je     801fd9 <devcons_read+0x38>
	*(char*)vbuf = c;
  801fcd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fd0:	88 02                	mov    %al,(%edx)
	return 1;
  801fd2:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801fd7:	c9                   	leave  
  801fd8:	c3                   	ret    
		return 0;
  801fd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fde:	eb f7                	jmp    801fd7 <devcons_read+0x36>

00801fe0 <cputchar>:
{
  801fe0:	f3 0f 1e fb          	endbr32 
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fea:	8b 45 08             	mov    0x8(%ebp),%eax
  801fed:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ff0:	6a 01                	push   $0x1
  801ff2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ff5:	50                   	push   %eax
  801ff6:	e8 7d eb ff ff       	call   800b78 <sys_cputs>
}
  801ffb:	83 c4 10             	add    $0x10,%esp
  801ffe:	c9                   	leave  
  801fff:	c3                   	ret    

00802000 <getchar>:
{
  802000:	f3 0f 1e fb          	endbr32 
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
  802007:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80200a:	6a 01                	push   $0x1
  80200c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80200f:	50                   	push   %eax
  802010:	6a 00                	push   $0x0
  802012:	e8 3a f6 ff ff       	call   801651 <read>
	if (r < 0)
  802017:	83 c4 10             	add    $0x10,%esp
  80201a:	85 c0                	test   %eax,%eax
  80201c:	78 06                	js     802024 <getchar+0x24>
	if (r < 1)
  80201e:	74 06                	je     802026 <getchar+0x26>
	return c;
  802020:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802024:	c9                   	leave  
  802025:	c3                   	ret    
		return -E_EOF;
  802026:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80202b:	eb f7                	jmp    802024 <getchar+0x24>

0080202d <iscons>:
{
  80202d:	f3 0f 1e fb          	endbr32 
  802031:	55                   	push   %ebp
  802032:	89 e5                	mov    %esp,%ebp
  802034:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802037:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203a:	50                   	push   %eax
  80203b:	ff 75 08             	pushl  0x8(%ebp)
  80203e:	e8 8b f3 ff ff       	call   8013ce <fd_lookup>
  802043:	83 c4 10             	add    $0x10,%esp
  802046:	85 c0                	test   %eax,%eax
  802048:	78 11                	js     80205b <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80204a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80204d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802053:	39 10                	cmp    %edx,(%eax)
  802055:	0f 94 c0             	sete   %al
  802058:	0f b6 c0             	movzbl %al,%eax
}
  80205b:	c9                   	leave  
  80205c:	c3                   	ret    

0080205d <opencons>:
{
  80205d:	f3 0f 1e fb          	endbr32 
  802061:	55                   	push   %ebp
  802062:	89 e5                	mov    %esp,%ebp
  802064:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802067:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80206a:	50                   	push   %eax
  80206b:	e8 08 f3 ff ff       	call   801378 <fd_alloc>
  802070:	83 c4 10             	add    $0x10,%esp
  802073:	85 c0                	test   %eax,%eax
  802075:	78 3a                	js     8020b1 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802077:	83 ec 04             	sub    $0x4,%esp
  80207a:	68 07 04 00 00       	push   $0x407
  80207f:	ff 75 f4             	pushl  -0xc(%ebp)
  802082:	6a 00                	push   $0x0
  802084:	e8 ba eb ff ff       	call   800c43 <sys_page_alloc>
  802089:	83 c4 10             	add    $0x10,%esp
  80208c:	85 c0                	test   %eax,%eax
  80208e:	78 21                	js     8020b1 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  802090:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802093:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802099:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80209b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020a5:	83 ec 0c             	sub    $0xc,%esp
  8020a8:	50                   	push   %eax
  8020a9:	e8 97 f2 ff ff       	call   801345 <fd2num>
  8020ae:	83 c4 10             	add    $0x10,%esp
}
  8020b1:	c9                   	leave  
  8020b2:	c3                   	ret    

008020b3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020b3:	f3 0f 1e fb          	endbr32 
  8020b7:	55                   	push   %ebp
  8020b8:	89 e5                	mov    %esp,%ebp
  8020ba:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  8020bd:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8020c4:	74 0a                	je     8020d0 <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8020c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c9:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8020ce:	c9                   	leave  
  8020cf:	c3                   	ret    
		if (sys_page_alloc(0,
  8020d0:	83 ec 04             	sub    $0x4,%esp
  8020d3:	6a 07                	push   $0x7
  8020d5:	68 00 f0 bf ee       	push   $0xeebff000
  8020da:	6a 00                	push   $0x0
  8020dc:	e8 62 eb ff ff       	call   800c43 <sys_page_alloc>
  8020e1:	83 c4 10             	add    $0x10,%esp
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	78 2a                	js     802112 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  8020e8:	83 ec 08             	sub    $0x8,%esp
  8020eb:	68 26 21 80 00       	push   $0x802126
  8020f0:	6a 00                	push   $0x0
  8020f2:	e8 13 ec ff ff       	call   800d0a <sys_env_set_pgfault_upcall>
  8020f7:	83 c4 10             	add    $0x10,%esp
  8020fa:	85 c0                	test   %eax,%eax
  8020fc:	79 c8                	jns    8020c6 <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  8020fe:	83 ec 04             	sub    $0x4,%esp
  802101:	68 ac 2a 80 00       	push   $0x802aac
  802106:	6a 25                	push   $0x25
  802108:	68 f3 2a 80 00       	push   $0x802af3
  80210d:	e8 58 e0 ff ff       	call   80016a <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  802112:	83 ec 04             	sub    $0x4,%esp
  802115:	68 78 2a 80 00       	push   $0x802a78
  80211a:	6a 21                	push   $0x21
  80211c:	68 f3 2a 80 00       	push   $0x802af3
  802121:	e8 44 e0 ff ff       	call   80016a <_panic>

00802126 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802126:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802127:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80212c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80212e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  802131:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  802136:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  80213a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80213e:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  802140:	83 c4 08             	add    $0x8,%esp
	popal
  802143:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  802144:	83 c4 04             	add    $0x4,%esp
	popfl
  802147:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  802148:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80214b:	c3                   	ret    

0080214c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80214c:	f3 0f 1e fb          	endbr32 
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
  802153:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802156:	89 c2                	mov    %eax,%edx
  802158:	c1 ea 16             	shr    $0x16,%edx
  80215b:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802162:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802167:	f6 c1 01             	test   $0x1,%cl
  80216a:	74 1c                	je     802188 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80216c:	c1 e8 0c             	shr    $0xc,%eax
  80216f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802176:	a8 01                	test   $0x1,%al
  802178:	74 0e                	je     802188 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80217a:	c1 e8 0c             	shr    $0xc,%eax
  80217d:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802184:	ef 
  802185:	0f b7 d2             	movzwl %dx,%edx
}
  802188:	89 d0                	mov    %edx,%eax
  80218a:	5d                   	pop    %ebp
  80218b:	c3                   	ret    
  80218c:	66 90                	xchg   %ax,%ax
  80218e:	66 90                	xchg   %ax,%ax

00802190 <__udivdi3>:
  802190:	f3 0f 1e fb          	endbr32 
  802194:	55                   	push   %ebp
  802195:	57                   	push   %edi
  802196:	56                   	push   %esi
  802197:	53                   	push   %ebx
  802198:	83 ec 1c             	sub    $0x1c,%esp
  80219b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80219f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021ab:	85 d2                	test   %edx,%edx
  8021ad:	75 19                	jne    8021c8 <__udivdi3+0x38>
  8021af:	39 f3                	cmp    %esi,%ebx
  8021b1:	76 4d                	jbe    802200 <__udivdi3+0x70>
  8021b3:	31 ff                	xor    %edi,%edi
  8021b5:	89 e8                	mov    %ebp,%eax
  8021b7:	89 f2                	mov    %esi,%edx
  8021b9:	f7 f3                	div    %ebx
  8021bb:	89 fa                	mov    %edi,%edx
  8021bd:	83 c4 1c             	add    $0x1c,%esp
  8021c0:	5b                   	pop    %ebx
  8021c1:	5e                   	pop    %esi
  8021c2:	5f                   	pop    %edi
  8021c3:	5d                   	pop    %ebp
  8021c4:	c3                   	ret    
  8021c5:	8d 76 00             	lea    0x0(%esi),%esi
  8021c8:	39 f2                	cmp    %esi,%edx
  8021ca:	76 14                	jbe    8021e0 <__udivdi3+0x50>
  8021cc:	31 ff                	xor    %edi,%edi
  8021ce:	31 c0                	xor    %eax,%eax
  8021d0:	89 fa                	mov    %edi,%edx
  8021d2:	83 c4 1c             	add    $0x1c,%esp
  8021d5:	5b                   	pop    %ebx
  8021d6:	5e                   	pop    %esi
  8021d7:	5f                   	pop    %edi
  8021d8:	5d                   	pop    %ebp
  8021d9:	c3                   	ret    
  8021da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e0:	0f bd fa             	bsr    %edx,%edi
  8021e3:	83 f7 1f             	xor    $0x1f,%edi
  8021e6:	75 48                	jne    802230 <__udivdi3+0xa0>
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	72 06                	jb     8021f2 <__udivdi3+0x62>
  8021ec:	31 c0                	xor    %eax,%eax
  8021ee:	39 eb                	cmp    %ebp,%ebx
  8021f0:	77 de                	ja     8021d0 <__udivdi3+0x40>
  8021f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f7:	eb d7                	jmp    8021d0 <__udivdi3+0x40>
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 d9                	mov    %ebx,%ecx
  802202:	85 db                	test   %ebx,%ebx
  802204:	75 0b                	jne    802211 <__udivdi3+0x81>
  802206:	b8 01 00 00 00       	mov    $0x1,%eax
  80220b:	31 d2                	xor    %edx,%edx
  80220d:	f7 f3                	div    %ebx
  80220f:	89 c1                	mov    %eax,%ecx
  802211:	31 d2                	xor    %edx,%edx
  802213:	89 f0                	mov    %esi,%eax
  802215:	f7 f1                	div    %ecx
  802217:	89 c6                	mov    %eax,%esi
  802219:	89 e8                	mov    %ebp,%eax
  80221b:	89 f7                	mov    %esi,%edi
  80221d:	f7 f1                	div    %ecx
  80221f:	89 fa                	mov    %edi,%edx
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	89 f9                	mov    %edi,%ecx
  802232:	b8 20 00 00 00       	mov    $0x20,%eax
  802237:	29 f8                	sub    %edi,%eax
  802239:	d3 e2                	shl    %cl,%edx
  80223b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80223f:	89 c1                	mov    %eax,%ecx
  802241:	89 da                	mov    %ebx,%edx
  802243:	d3 ea                	shr    %cl,%edx
  802245:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802249:	09 d1                	or     %edx,%ecx
  80224b:	89 f2                	mov    %esi,%edx
  80224d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802251:	89 f9                	mov    %edi,%ecx
  802253:	d3 e3                	shl    %cl,%ebx
  802255:	89 c1                	mov    %eax,%ecx
  802257:	d3 ea                	shr    %cl,%edx
  802259:	89 f9                	mov    %edi,%ecx
  80225b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80225f:	89 eb                	mov    %ebp,%ebx
  802261:	d3 e6                	shl    %cl,%esi
  802263:	89 c1                	mov    %eax,%ecx
  802265:	d3 eb                	shr    %cl,%ebx
  802267:	09 de                	or     %ebx,%esi
  802269:	89 f0                	mov    %esi,%eax
  80226b:	f7 74 24 08          	divl   0x8(%esp)
  80226f:	89 d6                	mov    %edx,%esi
  802271:	89 c3                	mov    %eax,%ebx
  802273:	f7 64 24 0c          	mull   0xc(%esp)
  802277:	39 d6                	cmp    %edx,%esi
  802279:	72 15                	jb     802290 <__udivdi3+0x100>
  80227b:	89 f9                	mov    %edi,%ecx
  80227d:	d3 e5                	shl    %cl,%ebp
  80227f:	39 c5                	cmp    %eax,%ebp
  802281:	73 04                	jae    802287 <__udivdi3+0xf7>
  802283:	39 d6                	cmp    %edx,%esi
  802285:	74 09                	je     802290 <__udivdi3+0x100>
  802287:	89 d8                	mov    %ebx,%eax
  802289:	31 ff                	xor    %edi,%edi
  80228b:	e9 40 ff ff ff       	jmp    8021d0 <__udivdi3+0x40>
  802290:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802293:	31 ff                	xor    %edi,%edi
  802295:	e9 36 ff ff ff       	jmp    8021d0 <__udivdi3+0x40>
  80229a:	66 90                	xchg   %ax,%ax
  80229c:	66 90                	xchg   %ax,%ax
  80229e:	66 90                	xchg   %ax,%ax

008022a0 <__umoddi3>:
  8022a0:	f3 0f 1e fb          	endbr32 
  8022a4:	55                   	push   %ebp
  8022a5:	57                   	push   %edi
  8022a6:	56                   	push   %esi
  8022a7:	53                   	push   %ebx
  8022a8:	83 ec 1c             	sub    $0x1c,%esp
  8022ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022af:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022b3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022b7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022bb:	85 c0                	test   %eax,%eax
  8022bd:	75 19                	jne    8022d8 <__umoddi3+0x38>
  8022bf:	39 df                	cmp    %ebx,%edi
  8022c1:	76 5d                	jbe    802320 <__umoddi3+0x80>
  8022c3:	89 f0                	mov    %esi,%eax
  8022c5:	89 da                	mov    %ebx,%edx
  8022c7:	f7 f7                	div    %edi
  8022c9:	89 d0                	mov    %edx,%eax
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	83 c4 1c             	add    $0x1c,%esp
  8022d0:	5b                   	pop    %ebx
  8022d1:	5e                   	pop    %esi
  8022d2:	5f                   	pop    %edi
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    
  8022d5:	8d 76 00             	lea    0x0(%esi),%esi
  8022d8:	89 f2                	mov    %esi,%edx
  8022da:	39 d8                	cmp    %ebx,%eax
  8022dc:	76 12                	jbe    8022f0 <__umoddi3+0x50>
  8022de:	89 f0                	mov    %esi,%eax
  8022e0:	89 da                	mov    %ebx,%edx
  8022e2:	83 c4 1c             	add    $0x1c,%esp
  8022e5:	5b                   	pop    %ebx
  8022e6:	5e                   	pop    %esi
  8022e7:	5f                   	pop    %edi
  8022e8:	5d                   	pop    %ebp
  8022e9:	c3                   	ret    
  8022ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f0:	0f bd e8             	bsr    %eax,%ebp
  8022f3:	83 f5 1f             	xor    $0x1f,%ebp
  8022f6:	75 50                	jne    802348 <__umoddi3+0xa8>
  8022f8:	39 d8                	cmp    %ebx,%eax
  8022fa:	0f 82 e0 00 00 00    	jb     8023e0 <__umoddi3+0x140>
  802300:	89 d9                	mov    %ebx,%ecx
  802302:	39 f7                	cmp    %esi,%edi
  802304:	0f 86 d6 00 00 00    	jbe    8023e0 <__umoddi3+0x140>
  80230a:	89 d0                	mov    %edx,%eax
  80230c:	89 ca                	mov    %ecx,%edx
  80230e:	83 c4 1c             	add    $0x1c,%esp
  802311:	5b                   	pop    %ebx
  802312:	5e                   	pop    %esi
  802313:	5f                   	pop    %edi
  802314:	5d                   	pop    %ebp
  802315:	c3                   	ret    
  802316:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80231d:	8d 76 00             	lea    0x0(%esi),%esi
  802320:	89 fd                	mov    %edi,%ebp
  802322:	85 ff                	test   %edi,%edi
  802324:	75 0b                	jne    802331 <__umoddi3+0x91>
  802326:	b8 01 00 00 00       	mov    $0x1,%eax
  80232b:	31 d2                	xor    %edx,%edx
  80232d:	f7 f7                	div    %edi
  80232f:	89 c5                	mov    %eax,%ebp
  802331:	89 d8                	mov    %ebx,%eax
  802333:	31 d2                	xor    %edx,%edx
  802335:	f7 f5                	div    %ebp
  802337:	89 f0                	mov    %esi,%eax
  802339:	f7 f5                	div    %ebp
  80233b:	89 d0                	mov    %edx,%eax
  80233d:	31 d2                	xor    %edx,%edx
  80233f:	eb 8c                	jmp    8022cd <__umoddi3+0x2d>
  802341:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802348:	89 e9                	mov    %ebp,%ecx
  80234a:	ba 20 00 00 00       	mov    $0x20,%edx
  80234f:	29 ea                	sub    %ebp,%edx
  802351:	d3 e0                	shl    %cl,%eax
  802353:	89 44 24 08          	mov    %eax,0x8(%esp)
  802357:	89 d1                	mov    %edx,%ecx
  802359:	89 f8                	mov    %edi,%eax
  80235b:	d3 e8                	shr    %cl,%eax
  80235d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802361:	89 54 24 04          	mov    %edx,0x4(%esp)
  802365:	8b 54 24 04          	mov    0x4(%esp),%edx
  802369:	09 c1                	or     %eax,%ecx
  80236b:	89 d8                	mov    %ebx,%eax
  80236d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802371:	89 e9                	mov    %ebp,%ecx
  802373:	d3 e7                	shl    %cl,%edi
  802375:	89 d1                	mov    %edx,%ecx
  802377:	d3 e8                	shr    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80237f:	d3 e3                	shl    %cl,%ebx
  802381:	89 c7                	mov    %eax,%edi
  802383:	89 d1                	mov    %edx,%ecx
  802385:	89 f0                	mov    %esi,%eax
  802387:	d3 e8                	shr    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	89 fa                	mov    %edi,%edx
  80238d:	d3 e6                	shl    %cl,%esi
  80238f:	09 d8                	or     %ebx,%eax
  802391:	f7 74 24 08          	divl   0x8(%esp)
  802395:	89 d1                	mov    %edx,%ecx
  802397:	89 f3                	mov    %esi,%ebx
  802399:	f7 64 24 0c          	mull   0xc(%esp)
  80239d:	89 c6                	mov    %eax,%esi
  80239f:	89 d7                	mov    %edx,%edi
  8023a1:	39 d1                	cmp    %edx,%ecx
  8023a3:	72 06                	jb     8023ab <__umoddi3+0x10b>
  8023a5:	75 10                	jne    8023b7 <__umoddi3+0x117>
  8023a7:	39 c3                	cmp    %eax,%ebx
  8023a9:	73 0c                	jae    8023b7 <__umoddi3+0x117>
  8023ab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8023af:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8023b3:	89 d7                	mov    %edx,%edi
  8023b5:	89 c6                	mov    %eax,%esi
  8023b7:	89 ca                	mov    %ecx,%edx
  8023b9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023be:	29 f3                	sub    %esi,%ebx
  8023c0:	19 fa                	sbb    %edi,%edx
  8023c2:	89 d0                	mov    %edx,%eax
  8023c4:	d3 e0                	shl    %cl,%eax
  8023c6:	89 e9                	mov    %ebp,%ecx
  8023c8:	d3 eb                	shr    %cl,%ebx
  8023ca:	d3 ea                	shr    %cl,%edx
  8023cc:	09 d8                	or     %ebx,%eax
  8023ce:	83 c4 1c             	add    $0x1c,%esp
  8023d1:	5b                   	pop    %ebx
  8023d2:	5e                   	pop    %esi
  8023d3:	5f                   	pop    %edi
  8023d4:	5d                   	pop    %ebp
  8023d5:	c3                   	ret    
  8023d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023dd:	8d 76 00             	lea    0x0(%esi),%esi
  8023e0:	29 fe                	sub    %edi,%esi
  8023e2:	19 c3                	sbb    %eax,%ebx
  8023e4:	89 f2                	mov    %esi,%edx
  8023e6:	89 d9                	mov    %ebx,%ecx
  8023e8:	e9 1d ff ff ff       	jmp    80230a <__umoddi3+0x6a>
