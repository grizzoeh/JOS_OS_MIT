
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 a1 00 00 00       	call   8000d2 <libmain>
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
  800049:	e8 d7 01 00 00       	call   800225 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004e:	83 c4 0c             	add    $0xc,%esp
  800051:	6a 07                	push   $0x7
  800053:	89 d8                	mov    %ebx,%eax
  800055:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005a:	50                   	push   %eax
  80005b:	6a 00                	push   $0x0
  80005d:	e8 b5 0b 00 00       	call   800c17 <sys_page_alloc>
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
  800072:	e8 b7 06 00 00       	call   80072e <snprintf>
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
  800089:	6a 0e                	push   $0xe
  80008b:	68 0a 1f 80 00       	push   $0x801f0a
  800090:	e8 a9 00 00 00       	call   80013e <_panic>

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
  8000a4:	e8 ab 0c 00 00       	call   800d54 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a9:	83 c4 08             	add    $0x8,%esp
  8000ac:	68 ef be ad de       	push   $0xdeadbeef
  8000b1:	68 1c 1f 80 00       	push   $0x801f1c
  8000b6:	e8 6a 01 00 00       	call   800225 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000bb:	83 c4 08             	add    $0x8,%esp
  8000be:	68 fe bf fe ca       	push   $0xcafebffe
  8000c3:	68 1c 1f 80 00       	push   $0x801f1c
  8000c8:	e8 58 01 00 00       	call   800225 <cprintf>
}
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	c9                   	leave  
  8000d1:	c3                   	ret    

008000d2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000d2:	f3 0f 1e fb          	endbr32 
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000e1:	e8 de 0a 00 00       	call   800bc4 <sys_getenvid>
	if (id >= 0)
  8000e6:	85 c0                	test   %eax,%eax
  8000e8:	78 12                	js     8000fc <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8000ea:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ef:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f7:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fc:	85 db                	test   %ebx,%ebx
  8000fe:	7e 07                	jle    800107 <libmain+0x35>
		binaryname = argv[0];
  800100:	8b 06                	mov    (%esi),%eax
  800102:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800107:	83 ec 08             	sub    $0x8,%esp
  80010a:	56                   	push   %esi
  80010b:	53                   	push   %ebx
  80010c:	e8 84 ff ff ff       	call   800095 <umain>

	// exit gracefully
	exit();
  800111:	e8 0a 00 00 00       	call   800120 <exit>
}
  800116:	83 c4 10             	add    $0x10,%esp
  800119:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011c:	5b                   	pop    %ebx
  80011d:	5e                   	pop    %esi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800120:	f3 0f 1e fb          	endbr32 
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012a:	e8 b1 0e 00 00       	call   800fe0 <close_all>
	sys_env_destroy(0);
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	6a 00                	push   $0x0
  800134:	e8 65 0a 00 00       	call   800b9e <sys_env_destroy>
}
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013e:	f3 0f 1e fb          	endbr32 
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	56                   	push   %esi
  800146:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800147:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800150:	e8 6f 0a 00 00       	call   800bc4 <sys_getenvid>
  800155:	83 ec 0c             	sub    $0xc,%esp
  800158:	ff 75 0c             	pushl  0xc(%ebp)
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	56                   	push   %esi
  80015f:	50                   	push   %eax
  800160:	68 78 1f 80 00       	push   $0x801f78
  800165:	e8 bb 00 00 00       	call   800225 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016a:	83 c4 18             	add    $0x18,%esp
  80016d:	53                   	push   %ebx
  80016e:	ff 75 10             	pushl  0x10(%ebp)
  800171:	e8 5a 00 00 00       	call   8001d0 <vcprintf>
	cprintf("\n");
  800176:	c7 04 24 2f 24 80 00 	movl   $0x80242f,(%esp)
  80017d:	e8 a3 00 00 00       	call   800225 <cprintf>
  800182:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800185:	cc                   	int3   
  800186:	eb fd                	jmp    800185 <_panic+0x47>

00800188 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800188:	f3 0f 1e fb          	endbr32 
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	53                   	push   %ebx
  800190:	83 ec 04             	sub    $0x4,%esp
  800193:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800196:	8b 13                	mov    (%ebx),%edx
  800198:	8d 42 01             	lea    0x1(%edx),%eax
  80019b:	89 03                	mov    %eax,(%ebx)
  80019d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a9:	74 09                	je     8001b4 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	68 ff 00 00 00       	push   $0xff
  8001bc:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bf:	50                   	push   %eax
  8001c0:	e8 87 09 00 00       	call   800b4c <sys_cputs>
		b->idx = 0;
  8001c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	eb db                	jmp    8001ab <putch+0x23>

008001d0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d0:	f3 0f 1e fb          	endbr32 
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001dd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e4:	00 00 00 
	b.cnt = 0;
  8001e7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ee:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f1:	ff 75 0c             	pushl  0xc(%ebp)
  8001f4:	ff 75 08             	pushl  0x8(%ebp)
  8001f7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fd:	50                   	push   %eax
  8001fe:	68 88 01 80 00       	push   $0x800188
  800203:	e8 80 01 00 00       	call   800388 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800208:	83 c4 08             	add    $0x8,%esp
  80020b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800211:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800217:	50                   	push   %eax
  800218:	e8 2f 09 00 00       	call   800b4c <sys_cputs>

	return b.cnt;
}
  80021d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800223:	c9                   	leave  
  800224:	c3                   	ret    

00800225 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800225:	f3 0f 1e fb          	endbr32 
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800232:	50                   	push   %eax
  800233:	ff 75 08             	pushl  0x8(%ebp)
  800236:	e8 95 ff ff ff       	call   8001d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023b:	c9                   	leave  
  80023c:	c3                   	ret    

0080023d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	57                   	push   %edi
  800241:	56                   	push   %esi
  800242:	53                   	push   %ebx
  800243:	83 ec 1c             	sub    $0x1c,%esp
  800246:	89 c7                	mov    %eax,%edi
  800248:	89 d6                	mov    %edx,%esi
  80024a:	8b 45 08             	mov    0x8(%ebp),%eax
  80024d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800250:	89 d1                	mov    %edx,%ecx
  800252:	89 c2                	mov    %eax,%edx
  800254:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800257:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80025a:	8b 45 10             	mov    0x10(%ebp),%eax
  80025d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800260:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800263:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80026a:	39 c2                	cmp    %eax,%edx
  80026c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80026f:	72 3e                	jb     8002af <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800271:	83 ec 0c             	sub    $0xc,%esp
  800274:	ff 75 18             	pushl  0x18(%ebp)
  800277:	83 eb 01             	sub    $0x1,%ebx
  80027a:	53                   	push   %ebx
  80027b:	50                   	push   %eax
  80027c:	83 ec 08             	sub    $0x8,%esp
  80027f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800282:	ff 75 e0             	pushl  -0x20(%ebp)
  800285:	ff 75 dc             	pushl  -0x24(%ebp)
  800288:	ff 75 d8             	pushl  -0x28(%ebp)
  80028b:	e8 10 1a 00 00       	call   801ca0 <__udivdi3>
  800290:	83 c4 18             	add    $0x18,%esp
  800293:	52                   	push   %edx
  800294:	50                   	push   %eax
  800295:	89 f2                	mov    %esi,%edx
  800297:	89 f8                	mov    %edi,%eax
  800299:	e8 9f ff ff ff       	call   80023d <printnum>
  80029e:	83 c4 20             	add    $0x20,%esp
  8002a1:	eb 13                	jmp    8002b6 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a3:	83 ec 08             	sub    $0x8,%esp
  8002a6:	56                   	push   %esi
  8002a7:	ff 75 18             	pushl  0x18(%ebp)
  8002aa:	ff d7                	call   *%edi
  8002ac:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002af:	83 eb 01             	sub    $0x1,%ebx
  8002b2:	85 db                	test   %ebx,%ebx
  8002b4:	7f ed                	jg     8002a3 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b6:	83 ec 08             	sub    $0x8,%esp
  8002b9:	56                   	push   %esi
  8002ba:	83 ec 04             	sub    $0x4,%esp
  8002bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c9:	e8 e2 1a 00 00       	call   801db0 <__umoddi3>
  8002ce:	83 c4 14             	add    $0x14,%esp
  8002d1:	0f be 80 9b 1f 80 00 	movsbl 0x801f9b(%eax),%eax
  8002d8:	50                   	push   %eax
  8002d9:	ff d7                	call   *%edi
}
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002e6:	83 fa 01             	cmp    $0x1,%edx
  8002e9:	7f 13                	jg     8002fe <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8002eb:	85 d2                	test   %edx,%edx
  8002ed:	74 1c                	je     80030b <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8002ef:	8b 10                	mov    (%eax),%edx
  8002f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f4:	89 08                	mov    %ecx,(%eax)
  8002f6:	8b 02                	mov    (%edx),%eax
  8002f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fd:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	8d 4a 08             	lea    0x8(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 02                	mov    (%edx),%eax
  800307:	8b 52 04             	mov    0x4(%edx),%edx
  80030a:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80030b:	8b 10                	mov    (%eax),%edx
  80030d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800310:	89 08                	mov    %ecx,(%eax)
  800312:	8b 02                	mov    (%edx),%eax
  800314:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800319:	c3                   	ret    

0080031a <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80031a:	83 fa 01             	cmp    $0x1,%edx
  80031d:	7f 0f                	jg     80032e <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80031f:	85 d2                	test   %edx,%edx
  800321:	74 18                	je     80033b <getint+0x21>
		return va_arg(*ap, long);
  800323:	8b 10                	mov    (%eax),%edx
  800325:	8d 4a 04             	lea    0x4(%edx),%ecx
  800328:	89 08                	mov    %ecx,(%eax)
  80032a:	8b 02                	mov    (%edx),%eax
  80032c:	99                   	cltd   
  80032d:	c3                   	ret    
		return va_arg(*ap, long long);
  80032e:	8b 10                	mov    (%eax),%edx
  800330:	8d 4a 08             	lea    0x8(%edx),%ecx
  800333:	89 08                	mov    %ecx,(%eax)
  800335:	8b 02                	mov    (%edx),%eax
  800337:	8b 52 04             	mov    0x4(%edx),%edx
  80033a:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80033b:	8b 10                	mov    (%eax),%edx
  80033d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800340:	89 08                	mov    %ecx,(%eax)
  800342:	8b 02                	mov    (%edx),%eax
  800344:	99                   	cltd   
}
  800345:	c3                   	ret    

00800346 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800346:	f3 0f 1e fb          	endbr32 
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800350:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800354:	8b 10                	mov    (%eax),%edx
  800356:	3b 50 04             	cmp    0x4(%eax),%edx
  800359:	73 0a                	jae    800365 <sprintputch+0x1f>
		*b->buf++ = ch;
  80035b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80035e:	89 08                	mov    %ecx,(%eax)
  800360:	8b 45 08             	mov    0x8(%ebp),%eax
  800363:	88 02                	mov    %al,(%edx)
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <printfmt>:
{
  800367:	f3 0f 1e fb          	endbr32 
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800371:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800374:	50                   	push   %eax
  800375:	ff 75 10             	pushl  0x10(%ebp)
  800378:	ff 75 0c             	pushl  0xc(%ebp)
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 05 00 00 00       	call   800388 <vprintfmt>
}
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	c9                   	leave  
  800387:	c3                   	ret    

00800388 <vprintfmt>:
{
  800388:	f3 0f 1e fb          	endbr32 
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	57                   	push   %edi
  800390:	56                   	push   %esi
  800391:	53                   	push   %ebx
  800392:	83 ec 2c             	sub    $0x2c,%esp
  800395:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800398:	8b 75 0c             	mov    0xc(%ebp),%esi
  80039b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80039e:	e9 86 02 00 00       	jmp    800629 <vprintfmt+0x2a1>
		padc = ' ';
  8003a3:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003a7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003ae:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003b5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003bc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8d 47 01             	lea    0x1(%edi),%eax
  8003c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c7:	0f b6 17             	movzbl (%edi),%edx
  8003ca:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003cd:	3c 55                	cmp    $0x55,%al
  8003cf:	0f 87 df 02 00 00    	ja     8006b4 <vprintfmt+0x32c>
  8003d5:	0f b6 c0             	movzbl %al,%eax
  8003d8:	3e ff 24 85 e0 20 80 	notrack jmp *0x8020e0(,%eax,4)
  8003df:	00 
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003e3:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003e7:	eb d8                	jmp    8003c1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ec:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003f0:	eb cf                	jmp    8003c1 <vprintfmt+0x39>
  8003f2:	0f b6 d2             	movzbl %dl,%edx
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800400:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800403:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800407:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80040a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80040d:	83 f9 09             	cmp    $0x9,%ecx
  800410:	77 52                	ja     800464 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800412:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800415:	eb e9                	jmp    800400 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 50 04             	lea    0x4(%eax),%edx
  80041d:	89 55 14             	mov    %edx,0x14(%ebp)
  800420:	8b 00                	mov    (%eax),%eax
  800422:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800428:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042c:	79 93                	jns    8003c1 <vprintfmt+0x39>
				width = precision, precision = -1;
  80042e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800431:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800434:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80043b:	eb 84                	jmp    8003c1 <vprintfmt+0x39>
  80043d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800440:	85 c0                	test   %eax,%eax
  800442:	ba 00 00 00 00       	mov    $0x0,%edx
  800447:	0f 49 d0             	cmovns %eax,%edx
  80044a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800450:	e9 6c ff ff ff       	jmp    8003c1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800458:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80045f:	e9 5d ff ff ff       	jmp    8003c1 <vprintfmt+0x39>
  800464:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800467:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80046a:	eb bc                	jmp    800428 <vprintfmt+0xa0>
			lflag++;
  80046c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800472:	e9 4a ff ff ff       	jmp    8003c1 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800477:	8b 45 14             	mov    0x14(%ebp),%eax
  80047a:	8d 50 04             	lea    0x4(%eax),%edx
  80047d:	89 55 14             	mov    %edx,0x14(%ebp)
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	56                   	push   %esi
  800484:	ff 30                	pushl  (%eax)
  800486:	ff d3                	call   *%ebx
			break;
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	e9 96 01 00 00       	jmp    800626 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	8d 50 04             	lea    0x4(%eax),%edx
  800496:	89 55 14             	mov    %edx,0x14(%ebp)
  800499:	8b 00                	mov    (%eax),%eax
  80049b:	99                   	cltd   
  80049c:	31 d0                	xor    %edx,%eax
  80049e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a0:	83 f8 0f             	cmp    $0xf,%eax
  8004a3:	7f 20                	jg     8004c5 <vprintfmt+0x13d>
  8004a5:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  8004ac:	85 d2                	test   %edx,%edx
  8004ae:	74 15                	je     8004c5 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8004b0:	52                   	push   %edx
  8004b1:	68 fd 23 80 00       	push   $0x8023fd
  8004b6:	56                   	push   %esi
  8004b7:	53                   	push   %ebx
  8004b8:	e8 aa fe ff ff       	call   800367 <printfmt>
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	e9 61 01 00 00       	jmp    800626 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8004c5:	50                   	push   %eax
  8004c6:	68 b3 1f 80 00       	push   $0x801fb3
  8004cb:	56                   	push   %esi
  8004cc:	53                   	push   %ebx
  8004cd:	e8 95 fe ff ff       	call   800367 <printfmt>
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	e9 4c 01 00 00       	jmp    800626 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 50 04             	lea    0x4(%eax),%edx
  8004e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e3:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8004e5:	85 c9                	test   %ecx,%ecx
  8004e7:	b8 ac 1f 80 00       	mov    $0x801fac,%eax
  8004ec:	0f 45 c1             	cmovne %ecx,%eax
  8004ef:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004f2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f6:	7e 06                	jle    8004fe <vprintfmt+0x176>
  8004f8:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004fc:	75 0d                	jne    80050b <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fe:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800501:	89 c7                	mov    %eax,%edi
  800503:	03 45 e0             	add    -0x20(%ebp),%eax
  800506:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800509:	eb 57                	jmp    800562 <vprintfmt+0x1da>
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	ff 75 d8             	pushl  -0x28(%ebp)
  800511:	ff 75 cc             	pushl  -0x34(%ebp)
  800514:	e8 4f 02 00 00       	call   800768 <strnlen>
  800519:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80051c:	29 c2                	sub    %eax,%edx
  80051e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800521:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800524:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800528:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80052b:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80052d:	85 db                	test   %ebx,%ebx
  80052f:	7e 10                	jle    800541 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	56                   	push   %esi
  800535:	57                   	push   %edi
  800536:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800539:	83 eb 01             	sub    $0x1,%ebx
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	eb ec                	jmp    80052d <vprintfmt+0x1a5>
  800541:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800544:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800547:	85 d2                	test   %edx,%edx
  800549:	b8 00 00 00 00       	mov    $0x0,%eax
  80054e:	0f 49 c2             	cmovns %edx,%eax
  800551:	29 c2                	sub    %eax,%edx
  800553:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800556:	eb a6                	jmp    8004fe <vprintfmt+0x176>
					putch(ch, putdat);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	56                   	push   %esi
  80055c:	52                   	push   %edx
  80055d:	ff d3                	call   *%ebx
  80055f:	83 c4 10             	add    $0x10,%esp
  800562:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800565:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800567:	83 c7 01             	add    $0x1,%edi
  80056a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056e:	0f be d0             	movsbl %al,%edx
  800571:	85 d2                	test   %edx,%edx
  800573:	74 42                	je     8005b7 <vprintfmt+0x22f>
  800575:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800579:	78 06                	js     800581 <vprintfmt+0x1f9>
  80057b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80057f:	78 1e                	js     80059f <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800581:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800585:	74 d1                	je     800558 <vprintfmt+0x1d0>
  800587:	0f be c0             	movsbl %al,%eax
  80058a:	83 e8 20             	sub    $0x20,%eax
  80058d:	83 f8 5e             	cmp    $0x5e,%eax
  800590:	76 c6                	jbe    800558 <vprintfmt+0x1d0>
					putch('?', putdat);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	56                   	push   %esi
  800596:	6a 3f                	push   $0x3f
  800598:	ff d3                	call   *%ebx
  80059a:	83 c4 10             	add    $0x10,%esp
  80059d:	eb c3                	jmp    800562 <vprintfmt+0x1da>
  80059f:	89 cf                	mov    %ecx,%edi
  8005a1:	eb 0e                	jmp    8005b1 <vprintfmt+0x229>
				putch(' ', putdat);
  8005a3:	83 ec 08             	sub    $0x8,%esp
  8005a6:	56                   	push   %esi
  8005a7:	6a 20                	push   $0x20
  8005a9:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8005ab:	83 ef 01             	sub    $0x1,%edi
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	85 ff                	test   %edi,%edi
  8005b3:	7f ee                	jg     8005a3 <vprintfmt+0x21b>
  8005b5:	eb 6f                	jmp    800626 <vprintfmt+0x29e>
  8005b7:	89 cf                	mov    %ecx,%edi
  8005b9:	eb f6                	jmp    8005b1 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8005bb:	89 ca                	mov    %ecx,%edx
  8005bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c0:	e8 55 fd ff ff       	call   80031a <getint>
  8005c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8005cb:	85 d2                	test   %edx,%edx
  8005cd:	78 0b                	js     8005da <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8005cf:	89 d1                	mov    %edx,%ecx
  8005d1:	89 c2                	mov    %eax,%edx
			base = 10;
  8005d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d8:	eb 32                	jmp    80060c <vprintfmt+0x284>
				putch('-', putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	56                   	push   %esi
  8005de:	6a 2d                	push   $0x2d
  8005e0:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005e2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005e5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e8:	f7 da                	neg    %edx
  8005ea:	83 d1 00             	adc    $0x0,%ecx
  8005ed:	f7 d9                	neg    %ecx
  8005ef:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f7:	eb 13                	jmp    80060c <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8005f9:	89 ca                	mov    %ecx,%edx
  8005fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fe:	e8 e3 fc ff ff       	call   8002e6 <getuint>
  800603:	89 d1                	mov    %edx,%ecx
  800605:	89 c2                	mov    %eax,%edx
			base = 10;
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  80060c:	83 ec 0c             	sub    $0xc,%esp
  80060f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800613:	57                   	push   %edi
  800614:	ff 75 e0             	pushl  -0x20(%ebp)
  800617:	50                   	push   %eax
  800618:	51                   	push   %ecx
  800619:	52                   	push   %edx
  80061a:	89 f2                	mov    %esi,%edx
  80061c:	89 d8                	mov    %ebx,%eax
  80061e:	e8 1a fc ff ff       	call   80023d <printnum>
			break;
  800623:	83 c4 20             	add    $0x20,%esp
{
  800626:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800629:	83 c7 01             	add    $0x1,%edi
  80062c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800630:	83 f8 25             	cmp    $0x25,%eax
  800633:	0f 84 6a fd ff ff    	je     8003a3 <vprintfmt+0x1b>
			if (ch == '\0')
  800639:	85 c0                	test   %eax,%eax
  80063b:	0f 84 93 00 00 00    	je     8006d4 <vprintfmt+0x34c>
			putch(ch, putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	56                   	push   %esi
  800645:	50                   	push   %eax
  800646:	ff d3                	call   *%ebx
  800648:	83 c4 10             	add    $0x10,%esp
  80064b:	eb dc                	jmp    800629 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  80064d:	89 ca                	mov    %ecx,%edx
  80064f:	8d 45 14             	lea    0x14(%ebp),%eax
  800652:	e8 8f fc ff ff       	call   8002e6 <getuint>
  800657:	89 d1                	mov    %edx,%ecx
  800659:	89 c2                	mov    %eax,%edx
			base = 8;
  80065b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800660:	eb aa                	jmp    80060c <vprintfmt+0x284>
			putch('0', putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	56                   	push   %esi
  800666:	6a 30                	push   $0x30
  800668:	ff d3                	call   *%ebx
			putch('x', putdat);
  80066a:	83 c4 08             	add    $0x8,%esp
  80066d:	56                   	push   %esi
  80066e:	6a 78                	push   $0x78
  800670:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8d 50 04             	lea    0x4(%eax),%edx
  800678:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80067b:	8b 10                	mov    (%eax),%edx
  80067d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800682:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800685:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80068a:	eb 80                	jmp    80060c <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80068c:	89 ca                	mov    %ecx,%edx
  80068e:	8d 45 14             	lea    0x14(%ebp),%eax
  800691:	e8 50 fc ff ff       	call   8002e6 <getuint>
  800696:	89 d1                	mov    %edx,%ecx
  800698:	89 c2                	mov    %eax,%edx
			base = 16;
  80069a:	b8 10 00 00 00       	mov    $0x10,%eax
  80069f:	e9 68 ff ff ff       	jmp    80060c <vprintfmt+0x284>
			putch(ch, putdat);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	56                   	push   %esi
  8006a8:	6a 25                	push   $0x25
  8006aa:	ff d3                	call   *%ebx
			break;
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	e9 72 ff ff ff       	jmp    800626 <vprintfmt+0x29e>
			putch('%', putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	56                   	push   %esi
  8006b8:	6a 25                	push   $0x25
  8006ba:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	89 f8                	mov    %edi,%eax
  8006c1:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006c5:	74 05                	je     8006cc <vprintfmt+0x344>
  8006c7:	83 e8 01             	sub    $0x1,%eax
  8006ca:	eb f5                	jmp    8006c1 <vprintfmt+0x339>
  8006cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006cf:	e9 52 ff ff ff       	jmp    800626 <vprintfmt+0x29e>
}
  8006d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d7:	5b                   	pop    %ebx
  8006d8:	5e                   	pop    %esi
  8006d9:	5f                   	pop    %edi
  8006da:	5d                   	pop    %ebp
  8006db:	c3                   	ret    

008006dc <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006dc:	f3 0f 1e fb          	endbr32 
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	83 ec 18             	sub    $0x18,%esp
  8006e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ef:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	74 26                	je     800727 <vsnprintf+0x4b>
  800701:	85 d2                	test   %edx,%edx
  800703:	7e 22                	jle    800727 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800705:	ff 75 14             	pushl  0x14(%ebp)
  800708:	ff 75 10             	pushl  0x10(%ebp)
  80070b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070e:	50                   	push   %eax
  80070f:	68 46 03 80 00       	push   $0x800346
  800714:	e8 6f fc ff ff       	call   800388 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800719:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800722:	83 c4 10             	add    $0x10,%esp
}
  800725:	c9                   	leave  
  800726:	c3                   	ret    
		return -E_INVAL;
  800727:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80072c:	eb f7                	jmp    800725 <vsnprintf+0x49>

0080072e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072e:	f3 0f 1e fb          	endbr32 
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073b:	50                   	push   %eax
  80073c:	ff 75 10             	pushl  0x10(%ebp)
  80073f:	ff 75 0c             	pushl  0xc(%ebp)
  800742:	ff 75 08             	pushl  0x8(%ebp)
  800745:	e8 92 ff ff ff       	call   8006dc <vsnprintf>
	va_end(ap);

	return rc;
}
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074c:	f3 0f 1e fb          	endbr32 
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800756:	b8 00 00 00 00       	mov    $0x0,%eax
  80075b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075f:	74 05                	je     800766 <strlen+0x1a>
		n++;
  800761:	83 c0 01             	add    $0x1,%eax
  800764:	eb f5                	jmp    80075b <strlen+0xf>
	return n;
}
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800768:	f3 0f 1e fb          	endbr32 
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800772:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800775:	b8 00 00 00 00       	mov    $0x0,%eax
  80077a:	39 d0                	cmp    %edx,%eax
  80077c:	74 0d                	je     80078b <strnlen+0x23>
  80077e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800782:	74 05                	je     800789 <strnlen+0x21>
		n++;
  800784:	83 c0 01             	add    $0x1,%eax
  800787:	eb f1                	jmp    80077a <strnlen+0x12>
  800789:	89 c2                	mov    %eax,%edx
	return n;
}
  80078b:	89 d0                	mov    %edx,%eax
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078f:	f3 0f 1e fb          	endbr32 
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	53                   	push   %ebx
  800797:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079d:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a2:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007a6:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007a9:	83 c0 01             	add    $0x1,%eax
  8007ac:	84 d2                	test   %dl,%dl
  8007ae:	75 f2                	jne    8007a2 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007b0:	89 c8                	mov    %ecx,%eax
  8007b2:	5b                   	pop    %ebx
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b5:	f3 0f 1e fb          	endbr32 
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	53                   	push   %ebx
  8007bd:	83 ec 10             	sub    $0x10,%esp
  8007c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c3:	53                   	push   %ebx
  8007c4:	e8 83 ff ff ff       	call   80074c <strlen>
  8007c9:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007cc:	ff 75 0c             	pushl  0xc(%ebp)
  8007cf:	01 d8                	add    %ebx,%eax
  8007d1:	50                   	push   %eax
  8007d2:	e8 b8 ff ff ff       	call   80078f <strcpy>
	return dst;
}
  8007d7:	89 d8                	mov    %ebx,%eax
  8007d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    

008007de <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007de:	f3 0f 1e fb          	endbr32 
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
  8007e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ed:	89 f3                	mov    %esi,%ebx
  8007ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f2:	89 f0                	mov    %esi,%eax
  8007f4:	39 d8                	cmp    %ebx,%eax
  8007f6:	74 11                	je     800809 <strncpy+0x2b>
		*dst++ = *src;
  8007f8:	83 c0 01             	add    $0x1,%eax
  8007fb:	0f b6 0a             	movzbl (%edx),%ecx
  8007fe:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800801:	80 f9 01             	cmp    $0x1,%cl
  800804:	83 da ff             	sbb    $0xffffffff,%edx
  800807:	eb eb                	jmp    8007f4 <strncpy+0x16>
	}
	return ret;
}
  800809:	89 f0                	mov    %esi,%eax
  80080b:	5b                   	pop    %ebx
  80080c:	5e                   	pop    %esi
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080f:	f3 0f 1e fb          	endbr32 
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	56                   	push   %esi
  800817:	53                   	push   %ebx
  800818:	8b 75 08             	mov    0x8(%ebp),%esi
  80081b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081e:	8b 55 10             	mov    0x10(%ebp),%edx
  800821:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800823:	85 d2                	test   %edx,%edx
  800825:	74 21                	je     800848 <strlcpy+0x39>
  800827:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80082b:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80082d:	39 c2                	cmp    %eax,%edx
  80082f:	74 14                	je     800845 <strlcpy+0x36>
  800831:	0f b6 19             	movzbl (%ecx),%ebx
  800834:	84 db                	test   %bl,%bl
  800836:	74 0b                	je     800843 <strlcpy+0x34>
			*dst++ = *src++;
  800838:	83 c1 01             	add    $0x1,%ecx
  80083b:	83 c2 01             	add    $0x1,%edx
  80083e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800841:	eb ea                	jmp    80082d <strlcpy+0x1e>
  800843:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800845:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800848:	29 f0                	sub    %esi,%eax
}
  80084a:	5b                   	pop    %ebx
  80084b:	5e                   	pop    %esi
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084e:	f3 0f 1e fb          	endbr32 
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800858:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085b:	0f b6 01             	movzbl (%ecx),%eax
  80085e:	84 c0                	test   %al,%al
  800860:	74 0c                	je     80086e <strcmp+0x20>
  800862:	3a 02                	cmp    (%edx),%al
  800864:	75 08                	jne    80086e <strcmp+0x20>
		p++, q++;
  800866:	83 c1 01             	add    $0x1,%ecx
  800869:	83 c2 01             	add    $0x1,%edx
  80086c:	eb ed                	jmp    80085b <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086e:	0f b6 c0             	movzbl %al,%eax
  800871:	0f b6 12             	movzbl (%edx),%edx
  800874:	29 d0                	sub    %edx,%eax
}
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800878:	f3 0f 1e fb          	endbr32 
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	53                   	push   %ebx
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	8b 55 0c             	mov    0xc(%ebp),%edx
  800886:	89 c3                	mov    %eax,%ebx
  800888:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088b:	eb 06                	jmp    800893 <strncmp+0x1b>
		n--, p++, q++;
  80088d:	83 c0 01             	add    $0x1,%eax
  800890:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800893:	39 d8                	cmp    %ebx,%eax
  800895:	74 16                	je     8008ad <strncmp+0x35>
  800897:	0f b6 08             	movzbl (%eax),%ecx
  80089a:	84 c9                	test   %cl,%cl
  80089c:	74 04                	je     8008a2 <strncmp+0x2a>
  80089e:	3a 0a                	cmp    (%edx),%cl
  8008a0:	74 eb                	je     80088d <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a2:	0f b6 00             	movzbl (%eax),%eax
  8008a5:	0f b6 12             	movzbl (%edx),%edx
  8008a8:	29 d0                	sub    %edx,%eax
}
  8008aa:	5b                   	pop    %ebx
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    
		return 0;
  8008ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b2:	eb f6                	jmp    8008aa <strncmp+0x32>

008008b4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b4:	f3 0f 1e fb          	endbr32 
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c2:	0f b6 10             	movzbl (%eax),%edx
  8008c5:	84 d2                	test   %dl,%dl
  8008c7:	74 09                	je     8008d2 <strchr+0x1e>
		if (*s == c)
  8008c9:	38 ca                	cmp    %cl,%dl
  8008cb:	74 0a                	je     8008d7 <strchr+0x23>
	for (; *s; s++)
  8008cd:	83 c0 01             	add    $0x1,%eax
  8008d0:	eb f0                	jmp    8008c2 <strchr+0xe>
			return (char *) s;
	return 0;
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d9:	f3 0f 1e fb          	endbr32 
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ea:	38 ca                	cmp    %cl,%dl
  8008ec:	74 09                	je     8008f7 <strfind+0x1e>
  8008ee:	84 d2                	test   %dl,%dl
  8008f0:	74 05                	je     8008f7 <strfind+0x1e>
	for (; *s; s++)
  8008f2:	83 c0 01             	add    $0x1,%eax
  8008f5:	eb f0                	jmp    8008e7 <strfind+0xe>
			break;
	return (char *) s;
}
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f9:	f3 0f 1e fb          	endbr32 
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	57                   	push   %edi
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	8b 55 08             	mov    0x8(%ebp),%edx
  800906:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800909:	85 c9                	test   %ecx,%ecx
  80090b:	74 33                	je     800940 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090d:	89 d0                	mov    %edx,%eax
  80090f:	09 c8                	or     %ecx,%eax
  800911:	a8 03                	test   $0x3,%al
  800913:	75 23                	jne    800938 <memset+0x3f>
		c &= 0xFF;
  800915:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800919:	89 d8                	mov    %ebx,%eax
  80091b:	c1 e0 08             	shl    $0x8,%eax
  80091e:	89 df                	mov    %ebx,%edi
  800920:	c1 e7 18             	shl    $0x18,%edi
  800923:	89 de                	mov    %ebx,%esi
  800925:	c1 e6 10             	shl    $0x10,%esi
  800928:	09 f7                	or     %esi,%edi
  80092a:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  80092c:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800931:	89 d7                	mov    %edx,%edi
  800933:	fc                   	cld    
  800934:	f3 ab                	rep stos %eax,%es:(%edi)
  800936:	eb 08                	jmp    800940 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800938:	89 d7                	mov    %edx,%edi
  80093a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093d:	fc                   	cld    
  80093e:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800940:	89 d0                	mov    %edx,%eax
  800942:	5b                   	pop    %ebx
  800943:	5e                   	pop    %esi
  800944:	5f                   	pop    %edi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800947:	f3 0f 1e fb          	endbr32 
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	57                   	push   %edi
  80094f:	56                   	push   %esi
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 75 0c             	mov    0xc(%ebp),%esi
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800959:	39 c6                	cmp    %eax,%esi
  80095b:	73 32                	jae    80098f <memmove+0x48>
  80095d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800960:	39 c2                	cmp    %eax,%edx
  800962:	76 2b                	jbe    80098f <memmove+0x48>
		s += n;
		d += n;
  800964:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800967:	89 fe                	mov    %edi,%esi
  800969:	09 ce                	or     %ecx,%esi
  80096b:	09 d6                	or     %edx,%esi
  80096d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800973:	75 0e                	jne    800983 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800975:	83 ef 04             	sub    $0x4,%edi
  800978:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80097e:	fd                   	std    
  80097f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800981:	eb 09                	jmp    80098c <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800983:	83 ef 01             	sub    $0x1,%edi
  800986:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800989:	fd                   	std    
  80098a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098c:	fc                   	cld    
  80098d:	eb 1a                	jmp    8009a9 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098f:	89 c2                	mov    %eax,%edx
  800991:	09 ca                	or     %ecx,%edx
  800993:	09 f2                	or     %esi,%edx
  800995:	f6 c2 03             	test   $0x3,%dl
  800998:	75 0a                	jne    8009a4 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80099a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80099d:	89 c7                	mov    %eax,%edi
  80099f:	fc                   	cld    
  8009a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a2:	eb 05                	jmp    8009a9 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009a4:	89 c7                	mov    %eax,%edi
  8009a6:	fc                   	cld    
  8009a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a9:	5e                   	pop    %esi
  8009aa:	5f                   	pop    %edi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ad:	f3 0f 1e fb          	endbr32 
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009b7:	ff 75 10             	pushl  0x10(%ebp)
  8009ba:	ff 75 0c             	pushl  0xc(%ebp)
  8009bd:	ff 75 08             	pushl  0x8(%ebp)
  8009c0:	e8 82 ff ff ff       	call   800947 <memmove>
}
  8009c5:	c9                   	leave  
  8009c6:	c3                   	ret    

008009c7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c7:	f3 0f 1e fb          	endbr32 
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	56                   	push   %esi
  8009cf:	53                   	push   %ebx
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d6:	89 c6                	mov    %eax,%esi
  8009d8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009db:	39 f0                	cmp    %esi,%eax
  8009dd:	74 1c                	je     8009fb <memcmp+0x34>
		if (*s1 != *s2)
  8009df:	0f b6 08             	movzbl (%eax),%ecx
  8009e2:	0f b6 1a             	movzbl (%edx),%ebx
  8009e5:	38 d9                	cmp    %bl,%cl
  8009e7:	75 08                	jne    8009f1 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009e9:	83 c0 01             	add    $0x1,%eax
  8009ec:	83 c2 01             	add    $0x1,%edx
  8009ef:	eb ea                	jmp    8009db <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009f1:	0f b6 c1             	movzbl %cl,%eax
  8009f4:	0f b6 db             	movzbl %bl,%ebx
  8009f7:	29 d8                	sub    %ebx,%eax
  8009f9:	eb 05                	jmp    800a00 <memcmp+0x39>
	}

	return 0;
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a00:	5b                   	pop    %ebx
  800a01:	5e                   	pop    %esi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a04:	f3 0f 1e fb          	endbr32 
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a11:	89 c2                	mov    %eax,%edx
  800a13:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a16:	39 d0                	cmp    %edx,%eax
  800a18:	73 09                	jae    800a23 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1a:	38 08                	cmp    %cl,(%eax)
  800a1c:	74 05                	je     800a23 <memfind+0x1f>
	for (; s < ends; s++)
  800a1e:	83 c0 01             	add    $0x1,%eax
  800a21:	eb f3                	jmp    800a16 <memfind+0x12>
			break;
	return (void *) s;
}
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a25:	f3 0f 1e fb          	endbr32 
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	57                   	push   %edi
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a35:	eb 03                	jmp    800a3a <strtol+0x15>
		s++;
  800a37:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a3a:	0f b6 01             	movzbl (%ecx),%eax
  800a3d:	3c 20                	cmp    $0x20,%al
  800a3f:	74 f6                	je     800a37 <strtol+0x12>
  800a41:	3c 09                	cmp    $0x9,%al
  800a43:	74 f2                	je     800a37 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a45:	3c 2b                	cmp    $0x2b,%al
  800a47:	74 2a                	je     800a73 <strtol+0x4e>
	int neg = 0;
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a4e:	3c 2d                	cmp    $0x2d,%al
  800a50:	74 2b                	je     800a7d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a52:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a58:	75 0f                	jne    800a69 <strtol+0x44>
  800a5a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5d:	74 28                	je     800a87 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5f:	85 db                	test   %ebx,%ebx
  800a61:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a66:	0f 44 d8             	cmove  %eax,%ebx
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a71:	eb 46                	jmp    800ab9 <strtol+0x94>
		s++;
  800a73:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a76:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7b:	eb d5                	jmp    800a52 <strtol+0x2d>
		s++, neg = 1;
  800a7d:	83 c1 01             	add    $0x1,%ecx
  800a80:	bf 01 00 00 00       	mov    $0x1,%edi
  800a85:	eb cb                	jmp    800a52 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a87:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a8b:	74 0e                	je     800a9b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	75 d8                	jne    800a69 <strtol+0x44>
		s++, base = 8;
  800a91:	83 c1 01             	add    $0x1,%ecx
  800a94:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a99:	eb ce                	jmp    800a69 <strtol+0x44>
		s += 2, base = 16;
  800a9b:	83 c1 02             	add    $0x2,%ecx
  800a9e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa3:	eb c4                	jmp    800a69 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aa5:	0f be d2             	movsbl %dl,%edx
  800aa8:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aab:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aae:	7d 3a                	jge    800aea <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ab0:	83 c1 01             	add    $0x1,%ecx
  800ab3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ab9:	0f b6 11             	movzbl (%ecx),%edx
  800abc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800abf:	89 f3                	mov    %esi,%ebx
  800ac1:	80 fb 09             	cmp    $0x9,%bl
  800ac4:	76 df                	jbe    800aa5 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ac6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ac9:	89 f3                	mov    %esi,%ebx
  800acb:	80 fb 19             	cmp    $0x19,%bl
  800ace:	77 08                	ja     800ad8 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ad0:	0f be d2             	movsbl %dl,%edx
  800ad3:	83 ea 57             	sub    $0x57,%edx
  800ad6:	eb d3                	jmp    800aab <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ad8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800adb:	89 f3                	mov    %esi,%ebx
  800add:	80 fb 19             	cmp    $0x19,%bl
  800ae0:	77 08                	ja     800aea <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ae2:	0f be d2             	movsbl %dl,%edx
  800ae5:	83 ea 37             	sub    $0x37,%edx
  800ae8:	eb c1                	jmp    800aab <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aee:	74 05                	je     800af5 <strtol+0xd0>
		*endptr = (char *) s;
  800af0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800af5:	89 c2                	mov    %eax,%edx
  800af7:	f7 da                	neg    %edx
  800af9:	85 ff                	test   %edi,%edi
  800afb:	0f 45 c2             	cmovne %edx,%eax
}
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5f                   	pop    %edi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
  800b09:	83 ec 1c             	sub    $0x1c,%esp
  800b0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b0f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b12:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b1a:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b1d:	8b 75 14             	mov    0x14(%ebp),%esi
  800b20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b22:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b26:	74 04                	je     800b2c <syscall+0x29>
  800b28:	85 c0                	test   %eax,%eax
  800b2a:	7f 08                	jg     800b34 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800b2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b34:	83 ec 0c             	sub    $0xc,%esp
  800b37:	50                   	push   %eax
  800b38:	ff 75 e0             	pushl  -0x20(%ebp)
  800b3b:	68 9f 22 80 00       	push   $0x80229f
  800b40:	6a 23                	push   $0x23
  800b42:	68 bc 22 80 00       	push   $0x8022bc
  800b47:	e8 f2 f5 ff ff       	call   80013e <_panic>

00800b4c <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800b4c:	f3 0f 1e fb          	endbr32 
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b56:	6a 00                	push   $0x0
  800b58:	6a 00                	push   $0x0
  800b5a:	6a 00                	push   $0x0
  800b5c:	ff 75 0c             	pushl  0xc(%ebp)
  800b5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6c:	e8 92 ff ff ff       	call   800b03 <syscall>
}
  800b71:	83 c4 10             	add    $0x10,%esp
  800b74:	c9                   	leave  
  800b75:	c3                   	ret    

00800b76 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b76:	f3 0f 1e fb          	endbr32 
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b80:	6a 00                	push   $0x0
  800b82:	6a 00                	push   $0x0
  800b84:	6a 00                	push   $0x0
  800b86:	6a 00                	push   $0x0
  800b88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	b8 01 00 00 00       	mov    $0x1,%eax
  800b97:	e8 67 ff ff ff       	call   800b03 <syscall>
}
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    

00800b9e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9e:	f3 0f 1e fb          	endbr32 
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ba8:	6a 00                	push   $0x0
  800baa:	6a 00                	push   $0x0
  800bac:	6a 00                	push   $0x0
  800bae:	6a 00                	push   $0x0
  800bb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb3:	ba 01 00 00 00       	mov    $0x1,%edx
  800bb8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bbd:	e8 41 ff ff ff       	call   800b03 <syscall>
}
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc4:	f3 0f 1e fb          	endbr32 
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bce:	6a 00                	push   $0x0
  800bd0:	6a 00                	push   $0x0
  800bd2:	6a 00                	push   $0x0
  800bd4:	6a 00                	push   $0x0
  800bd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800be0:	b8 02 00 00 00       	mov    $0x2,%eax
  800be5:	e8 19 ff ff ff       	call   800b03 <syscall>
}
  800bea:	c9                   	leave  
  800beb:	c3                   	ret    

00800bec <sys_yield>:

void
sys_yield(void)
{
  800bec:	f3 0f 1e fb          	endbr32 
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bf6:	6a 00                	push   $0x0
  800bf8:	6a 00                	push   $0x0
  800bfa:	6a 00                	push   $0x0
  800bfc:	6a 00                	push   $0x0
  800bfe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c03:	ba 00 00 00 00       	mov    $0x0,%edx
  800c08:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c0d:	e8 f1 fe ff ff       	call   800b03 <syscall>
}
  800c12:	83 c4 10             	add    $0x10,%esp
  800c15:	c9                   	leave  
  800c16:	c3                   	ret    

00800c17 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c17:	f3 0f 1e fb          	endbr32 
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c21:	6a 00                	push   $0x0
  800c23:	6a 00                	push   $0x0
  800c25:	ff 75 10             	pushl  0x10(%ebp)
  800c28:	ff 75 0c             	pushl  0xc(%ebp)
  800c2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2e:	ba 01 00 00 00       	mov    $0x1,%edx
  800c33:	b8 04 00 00 00       	mov    $0x4,%eax
  800c38:	e8 c6 fe ff ff       	call   800b03 <syscall>
}
  800c3d:	c9                   	leave  
  800c3e:	c3                   	ret    

00800c3f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c3f:	f3 0f 1e fb          	endbr32 
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c49:	ff 75 18             	pushl  0x18(%ebp)
  800c4c:	ff 75 14             	pushl  0x14(%ebp)
  800c4f:	ff 75 10             	pushl  0x10(%ebp)
  800c52:	ff 75 0c             	pushl  0xc(%ebp)
  800c55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c58:	ba 01 00 00 00       	mov    $0x1,%edx
  800c5d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c62:	e8 9c fe ff ff       	call   800b03 <syscall>
}
  800c67:	c9                   	leave  
  800c68:	c3                   	ret    

00800c69 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c69:	f3 0f 1e fb          	endbr32 
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c73:	6a 00                	push   $0x0
  800c75:	6a 00                	push   $0x0
  800c77:	6a 00                	push   $0x0
  800c79:	ff 75 0c             	pushl  0xc(%ebp)
  800c7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c84:	b8 06 00 00 00       	mov    $0x6,%eax
  800c89:	e8 75 fe ff ff       	call   800b03 <syscall>
}
  800c8e:	c9                   	leave  
  800c8f:	c3                   	ret    

00800c90 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c90:	f3 0f 1e fb          	endbr32 
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c9a:	6a 00                	push   $0x0
  800c9c:	6a 00                	push   $0x0
  800c9e:	6a 00                	push   $0x0
  800ca0:	ff 75 0c             	pushl  0xc(%ebp)
  800ca3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca6:	ba 01 00 00 00       	mov    $0x1,%edx
  800cab:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb0:	e8 4e fe ff ff       	call   800b03 <syscall>
}
  800cb5:	c9                   	leave  
  800cb6:	c3                   	ret    

00800cb7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb7:	f3 0f 1e fb          	endbr32 
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800cc1:	6a 00                	push   $0x0
  800cc3:	6a 00                	push   $0x0
  800cc5:	6a 00                	push   $0x0
  800cc7:	ff 75 0c             	pushl  0xc(%ebp)
  800cca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccd:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd2:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd7:	e8 27 fe ff ff       	call   800b03 <syscall>
}
  800cdc:	c9                   	leave  
  800cdd:	c3                   	ret    

00800cde <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cde:	f3 0f 1e fb          	endbr32 
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800ce8:	6a 00                	push   $0x0
  800cea:	6a 00                	push   $0x0
  800cec:	6a 00                	push   $0x0
  800cee:	ff 75 0c             	pushl  0xc(%ebp)
  800cf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf4:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cfe:	e8 00 fe ff ff       	call   800b03 <syscall>
}
  800d03:	c9                   	leave  
  800d04:	c3                   	ret    

00800d05 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d05:	f3 0f 1e fb          	endbr32 
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d0f:	6a 00                	push   $0x0
  800d11:	ff 75 14             	pushl  0x14(%ebp)
  800d14:	ff 75 10             	pushl  0x10(%ebp)
  800d17:	ff 75 0c             	pushl  0xc(%ebp)
  800d1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d22:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d27:	e8 d7 fd ff ff       	call   800b03 <syscall>
}
  800d2c:	c9                   	leave  
  800d2d:	c3                   	ret    

00800d2e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2e:	f3 0f 1e fb          	endbr32 
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d38:	6a 00                	push   $0x0
  800d3a:	6a 00                	push   $0x0
  800d3c:	6a 00                	push   $0x0
  800d3e:	6a 00                	push   $0x0
  800d40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d43:	ba 01 00 00 00       	mov    $0x1,%edx
  800d48:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d4d:	e8 b1 fd ff ff       	call   800b03 <syscall>
}
  800d52:	c9                   	leave  
  800d53:	c3                   	ret    

00800d54 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d54:	f3 0f 1e fb          	endbr32 
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  800d5e:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d65:	74 0a                	je     800d71 <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d67:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6a:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800d6f:	c9                   	leave  
  800d70:	c3                   	ret    
		if (sys_page_alloc(0,
  800d71:	83 ec 04             	sub    $0x4,%esp
  800d74:	6a 07                	push   $0x7
  800d76:	68 00 f0 bf ee       	push   $0xeebff000
  800d7b:	6a 00                	push   $0x0
  800d7d:	e8 95 fe ff ff       	call   800c17 <sys_page_alloc>
  800d82:	83 c4 10             	add    $0x10,%esp
  800d85:	85 c0                	test   %eax,%eax
  800d87:	78 2a                	js     800db3 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  800d89:	83 ec 08             	sub    $0x8,%esp
  800d8c:	68 c7 0d 80 00       	push   $0x800dc7
  800d91:	6a 00                	push   $0x0
  800d93:	e8 46 ff ff ff       	call   800cde <sys_env_set_pgfault_upcall>
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	79 c8                	jns    800d67 <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  800d9f:	83 ec 04             	sub    $0x4,%esp
  800da2:	68 00 23 80 00       	push   $0x802300
  800da7:	6a 25                	push   $0x25
  800da9:	68 47 23 80 00       	push   $0x802347
  800dae:	e8 8b f3 ff ff       	call   80013e <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  800db3:	83 ec 04             	sub    $0x4,%esp
  800db6:	68 cc 22 80 00       	push   $0x8022cc
  800dbb:	6a 21                	push   $0x21
  800dbd:	68 47 23 80 00       	push   $0x802347
  800dc2:	e8 77 f3 ff ff       	call   80013e <_panic>

00800dc7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dc7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dc8:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800dcd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dcf:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  800dd2:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  800dd7:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  800ddb:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800ddf:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  800de1:	83 c4 08             	add    $0x8,%esp
	popal
  800de4:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  800de5:	83 c4 04             	add    $0x4,%esp
	popfl
  800de8:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  800de9:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800dec:	c3                   	ret    

00800ded <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ded:	f3 0f 1e fb          	endbr32 
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800df4:	8b 45 08             	mov    0x8(%ebp),%eax
  800df7:	05 00 00 00 30       	add    $0x30000000,%eax
  800dfc:	c1 e8 0c             	shr    $0xc,%eax
}
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e01:	f3 0f 1e fb          	endbr32 
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800e0b:	ff 75 08             	pushl  0x8(%ebp)
  800e0e:	e8 da ff ff ff       	call   800ded <fd2num>
  800e13:	83 c4 10             	add    $0x10,%esp
  800e16:	c1 e0 0c             	shl    $0xc,%eax
  800e19:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e1e:	c9                   	leave  
  800e1f:	c3                   	ret    

00800e20 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e20:	f3 0f 1e fb          	endbr32 
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e2c:	89 c2                	mov    %eax,%edx
  800e2e:	c1 ea 16             	shr    $0x16,%edx
  800e31:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e38:	f6 c2 01             	test   $0x1,%dl
  800e3b:	74 2d                	je     800e6a <fd_alloc+0x4a>
  800e3d:	89 c2                	mov    %eax,%edx
  800e3f:	c1 ea 0c             	shr    $0xc,%edx
  800e42:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e49:	f6 c2 01             	test   $0x1,%dl
  800e4c:	74 1c                	je     800e6a <fd_alloc+0x4a>
  800e4e:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e53:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e58:	75 d2                	jne    800e2c <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e63:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e68:	eb 0a                	jmp    800e74 <fd_alloc+0x54>
			*fd_store = fd;
  800e6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e76:	f3 0f 1e fb          	endbr32 
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e80:	83 f8 1f             	cmp    $0x1f,%eax
  800e83:	77 30                	ja     800eb5 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e85:	c1 e0 0c             	shl    $0xc,%eax
  800e88:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e8d:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e93:	f6 c2 01             	test   $0x1,%dl
  800e96:	74 24                	je     800ebc <fd_lookup+0x46>
  800e98:	89 c2                	mov    %eax,%edx
  800e9a:	c1 ea 0c             	shr    $0xc,%edx
  800e9d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea4:	f6 c2 01             	test   $0x1,%dl
  800ea7:	74 1a                	je     800ec3 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ea9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eac:	89 02                	mov    %eax,(%edx)
	return 0;
  800eae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    
		return -E_INVAL;
  800eb5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eba:	eb f7                	jmp    800eb3 <fd_lookup+0x3d>
		return -E_INVAL;
  800ebc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec1:	eb f0                	jmp    800eb3 <fd_lookup+0x3d>
  800ec3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec8:	eb e9                	jmp    800eb3 <fd_lookup+0x3d>

00800eca <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eca:	f3 0f 1e fb          	endbr32 
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	83 ec 08             	sub    $0x8,%esp
  800ed4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed7:	ba d4 23 80 00       	mov    $0x8023d4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800edc:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800ee1:	39 08                	cmp    %ecx,(%eax)
  800ee3:	74 33                	je     800f18 <dev_lookup+0x4e>
  800ee5:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800ee8:	8b 02                	mov    (%edx),%eax
  800eea:	85 c0                	test   %eax,%eax
  800eec:	75 f3                	jne    800ee1 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eee:	a1 04 40 80 00       	mov    0x804004,%eax
  800ef3:	8b 40 48             	mov    0x48(%eax),%eax
  800ef6:	83 ec 04             	sub    $0x4,%esp
  800ef9:	51                   	push   %ecx
  800efa:	50                   	push   %eax
  800efb:	68 58 23 80 00       	push   $0x802358
  800f00:	e8 20 f3 ff ff       	call   800225 <cprintf>
	*dev = 0;
  800f05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f0e:	83 c4 10             	add    $0x10,%esp
  800f11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f16:	c9                   	leave  
  800f17:	c3                   	ret    
			*dev = devtab[i];
  800f18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f22:	eb f2                	jmp    800f16 <dev_lookup+0x4c>

00800f24 <fd_close>:
{
  800f24:	f3 0f 1e fb          	endbr32 
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	57                   	push   %edi
  800f2c:	56                   	push   %esi
  800f2d:	53                   	push   %ebx
  800f2e:	83 ec 28             	sub    $0x28,%esp
  800f31:	8b 75 08             	mov    0x8(%ebp),%esi
  800f34:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f37:	56                   	push   %esi
  800f38:	e8 b0 fe ff ff       	call   800ded <fd2num>
  800f3d:	83 c4 08             	add    $0x8,%esp
  800f40:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800f43:	52                   	push   %edx
  800f44:	50                   	push   %eax
  800f45:	e8 2c ff ff ff       	call   800e76 <fd_lookup>
  800f4a:	89 c3                	mov    %eax,%ebx
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	78 05                	js     800f58 <fd_close+0x34>
	    || fd != fd2)
  800f53:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f56:	74 16                	je     800f6e <fd_close+0x4a>
		return (must_exist ? r : 0);
  800f58:	89 f8                	mov    %edi,%eax
  800f5a:	84 c0                	test   %al,%al
  800f5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f61:	0f 44 d8             	cmove  %eax,%ebx
}
  800f64:	89 d8                	mov    %ebx,%eax
  800f66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f69:	5b                   	pop    %ebx
  800f6a:	5e                   	pop    %esi
  800f6b:	5f                   	pop    %edi
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f6e:	83 ec 08             	sub    $0x8,%esp
  800f71:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f74:	50                   	push   %eax
  800f75:	ff 36                	pushl  (%esi)
  800f77:	e8 4e ff ff ff       	call   800eca <dev_lookup>
  800f7c:	89 c3                	mov    %eax,%ebx
  800f7e:	83 c4 10             	add    $0x10,%esp
  800f81:	85 c0                	test   %eax,%eax
  800f83:	78 1a                	js     800f9f <fd_close+0x7b>
		if (dev->dev_close)
  800f85:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f88:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f8b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f90:	85 c0                	test   %eax,%eax
  800f92:	74 0b                	je     800f9f <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	56                   	push   %esi
  800f98:	ff d0                	call   *%eax
  800f9a:	89 c3                	mov    %eax,%ebx
  800f9c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f9f:	83 ec 08             	sub    $0x8,%esp
  800fa2:	56                   	push   %esi
  800fa3:	6a 00                	push   $0x0
  800fa5:	e8 bf fc ff ff       	call   800c69 <sys_page_unmap>
	return r;
  800faa:	83 c4 10             	add    $0x10,%esp
  800fad:	eb b5                	jmp    800f64 <fd_close+0x40>

00800faf <close>:

int
close(int fdnum)
{
  800faf:	f3 0f 1e fb          	endbr32 
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbc:	50                   	push   %eax
  800fbd:	ff 75 08             	pushl  0x8(%ebp)
  800fc0:	e8 b1 fe ff ff       	call   800e76 <fd_lookup>
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	79 02                	jns    800fce <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800fcc:	c9                   	leave  
  800fcd:	c3                   	ret    
		return fd_close(fd, 1);
  800fce:	83 ec 08             	sub    $0x8,%esp
  800fd1:	6a 01                	push   $0x1
  800fd3:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd6:	e8 49 ff ff ff       	call   800f24 <fd_close>
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	eb ec                	jmp    800fcc <close+0x1d>

00800fe0 <close_all>:

void
close_all(void)
{
  800fe0:	f3 0f 1e fb          	endbr32 
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800feb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ff0:	83 ec 0c             	sub    $0xc,%esp
  800ff3:	53                   	push   %ebx
  800ff4:	e8 b6 ff ff ff       	call   800faf <close>
	for (i = 0; i < MAXFD; i++)
  800ff9:	83 c3 01             	add    $0x1,%ebx
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	83 fb 20             	cmp    $0x20,%ebx
  801002:	75 ec                	jne    800ff0 <close_all+0x10>
}
  801004:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801007:	c9                   	leave  
  801008:	c3                   	ret    

00801009 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801009:	f3 0f 1e fb          	endbr32 
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	57                   	push   %edi
  801011:	56                   	push   %esi
  801012:	53                   	push   %ebx
  801013:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801016:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801019:	50                   	push   %eax
  80101a:	ff 75 08             	pushl  0x8(%ebp)
  80101d:	e8 54 fe ff ff       	call   800e76 <fd_lookup>
  801022:	89 c3                	mov    %eax,%ebx
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	0f 88 81 00 00 00    	js     8010b0 <dup+0xa7>
		return r;
	close(newfdnum);
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	ff 75 0c             	pushl  0xc(%ebp)
  801035:	e8 75 ff ff ff       	call   800faf <close>

	newfd = INDEX2FD(newfdnum);
  80103a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80103d:	c1 e6 0c             	shl    $0xc,%esi
  801040:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801046:	83 c4 04             	add    $0x4,%esp
  801049:	ff 75 e4             	pushl  -0x1c(%ebp)
  80104c:	e8 b0 fd ff ff       	call   800e01 <fd2data>
  801051:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801053:	89 34 24             	mov    %esi,(%esp)
  801056:	e8 a6 fd ff ff       	call   800e01 <fd2data>
  80105b:	83 c4 10             	add    $0x10,%esp
  80105e:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801060:	89 d8                	mov    %ebx,%eax
  801062:	c1 e8 16             	shr    $0x16,%eax
  801065:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80106c:	a8 01                	test   $0x1,%al
  80106e:	74 11                	je     801081 <dup+0x78>
  801070:	89 d8                	mov    %ebx,%eax
  801072:	c1 e8 0c             	shr    $0xc,%eax
  801075:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80107c:	f6 c2 01             	test   $0x1,%dl
  80107f:	75 39                	jne    8010ba <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801081:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801084:	89 d0                	mov    %edx,%eax
  801086:	c1 e8 0c             	shr    $0xc,%eax
  801089:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801090:	83 ec 0c             	sub    $0xc,%esp
  801093:	25 07 0e 00 00       	and    $0xe07,%eax
  801098:	50                   	push   %eax
  801099:	56                   	push   %esi
  80109a:	6a 00                	push   $0x0
  80109c:	52                   	push   %edx
  80109d:	6a 00                	push   $0x0
  80109f:	e8 9b fb ff ff       	call   800c3f <sys_page_map>
  8010a4:	89 c3                	mov    %eax,%ebx
  8010a6:	83 c4 20             	add    $0x20,%esp
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	78 31                	js     8010de <dup+0xd5>
		goto err;

	return newfdnum;
  8010ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8010b0:	89 d8                	mov    %ebx,%eax
  8010b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b5:	5b                   	pop    %ebx
  8010b6:	5e                   	pop    %esi
  8010b7:	5f                   	pop    %edi
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c1:	83 ec 0c             	sub    $0xc,%esp
  8010c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c9:	50                   	push   %eax
  8010ca:	57                   	push   %edi
  8010cb:	6a 00                	push   $0x0
  8010cd:	53                   	push   %ebx
  8010ce:	6a 00                	push   $0x0
  8010d0:	e8 6a fb ff ff       	call   800c3f <sys_page_map>
  8010d5:	89 c3                	mov    %eax,%ebx
  8010d7:	83 c4 20             	add    $0x20,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	79 a3                	jns    801081 <dup+0x78>
	sys_page_unmap(0, newfd);
  8010de:	83 ec 08             	sub    $0x8,%esp
  8010e1:	56                   	push   %esi
  8010e2:	6a 00                	push   $0x0
  8010e4:	e8 80 fb ff ff       	call   800c69 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010e9:	83 c4 08             	add    $0x8,%esp
  8010ec:	57                   	push   %edi
  8010ed:	6a 00                	push   $0x0
  8010ef:	e8 75 fb ff ff       	call   800c69 <sys_page_unmap>
	return r;
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	eb b7                	jmp    8010b0 <dup+0xa7>

008010f9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010f9:	f3 0f 1e fb          	endbr32 
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	53                   	push   %ebx
  801101:	83 ec 1c             	sub    $0x1c,%esp
  801104:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801107:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110a:	50                   	push   %eax
  80110b:	53                   	push   %ebx
  80110c:	e8 65 fd ff ff       	call   800e76 <fd_lookup>
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	85 c0                	test   %eax,%eax
  801116:	78 3f                	js     801157 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801118:	83 ec 08             	sub    $0x8,%esp
  80111b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80111e:	50                   	push   %eax
  80111f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801122:	ff 30                	pushl  (%eax)
  801124:	e8 a1 fd ff ff       	call   800eca <dev_lookup>
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	85 c0                	test   %eax,%eax
  80112e:	78 27                	js     801157 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801130:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801133:	8b 42 08             	mov    0x8(%edx),%eax
  801136:	83 e0 03             	and    $0x3,%eax
  801139:	83 f8 01             	cmp    $0x1,%eax
  80113c:	74 1e                	je     80115c <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80113e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801141:	8b 40 08             	mov    0x8(%eax),%eax
  801144:	85 c0                	test   %eax,%eax
  801146:	74 35                	je     80117d <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801148:	83 ec 04             	sub    $0x4,%esp
  80114b:	ff 75 10             	pushl  0x10(%ebp)
  80114e:	ff 75 0c             	pushl  0xc(%ebp)
  801151:	52                   	push   %edx
  801152:	ff d0                	call   *%eax
  801154:	83 c4 10             	add    $0x10,%esp
}
  801157:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115a:	c9                   	leave  
  80115b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80115c:	a1 04 40 80 00       	mov    0x804004,%eax
  801161:	8b 40 48             	mov    0x48(%eax),%eax
  801164:	83 ec 04             	sub    $0x4,%esp
  801167:	53                   	push   %ebx
  801168:	50                   	push   %eax
  801169:	68 99 23 80 00       	push   $0x802399
  80116e:	e8 b2 f0 ff ff       	call   800225 <cprintf>
		return -E_INVAL;
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117b:	eb da                	jmp    801157 <read+0x5e>
		return -E_NOT_SUPP;
  80117d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801182:	eb d3                	jmp    801157 <read+0x5e>

00801184 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801184:	f3 0f 1e fb          	endbr32 
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	57                   	push   %edi
  80118c:	56                   	push   %esi
  80118d:	53                   	push   %ebx
  80118e:	83 ec 0c             	sub    $0xc,%esp
  801191:	8b 7d 08             	mov    0x8(%ebp),%edi
  801194:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801197:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119c:	eb 02                	jmp    8011a0 <readn+0x1c>
  80119e:	01 c3                	add    %eax,%ebx
  8011a0:	39 f3                	cmp    %esi,%ebx
  8011a2:	73 21                	jae    8011c5 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011a4:	83 ec 04             	sub    $0x4,%esp
  8011a7:	89 f0                	mov    %esi,%eax
  8011a9:	29 d8                	sub    %ebx,%eax
  8011ab:	50                   	push   %eax
  8011ac:	89 d8                	mov    %ebx,%eax
  8011ae:	03 45 0c             	add    0xc(%ebp),%eax
  8011b1:	50                   	push   %eax
  8011b2:	57                   	push   %edi
  8011b3:	e8 41 ff ff ff       	call   8010f9 <read>
		if (m < 0)
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	78 04                	js     8011c3 <readn+0x3f>
			return m;
		if (m == 0)
  8011bf:	75 dd                	jne    80119e <readn+0x1a>
  8011c1:	eb 02                	jmp    8011c5 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011c3:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011c5:	89 d8                	mov    %ebx,%eax
  8011c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ca:	5b                   	pop    %ebx
  8011cb:	5e                   	pop    %esi
  8011cc:	5f                   	pop    %edi
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    

008011cf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011cf:	f3 0f 1e fb          	endbr32 
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	53                   	push   %ebx
  8011d7:	83 ec 1c             	sub    $0x1c,%esp
  8011da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e0:	50                   	push   %eax
  8011e1:	53                   	push   %ebx
  8011e2:	e8 8f fc ff ff       	call   800e76 <fd_lookup>
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	78 3a                	js     801228 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ee:	83 ec 08             	sub    $0x8,%esp
  8011f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f4:	50                   	push   %eax
  8011f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f8:	ff 30                	pushl  (%eax)
  8011fa:	e8 cb fc ff ff       	call   800eca <dev_lookup>
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	85 c0                	test   %eax,%eax
  801204:	78 22                	js     801228 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801206:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801209:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80120d:	74 1e                	je     80122d <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80120f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801212:	8b 52 0c             	mov    0xc(%edx),%edx
  801215:	85 d2                	test   %edx,%edx
  801217:	74 35                	je     80124e <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801219:	83 ec 04             	sub    $0x4,%esp
  80121c:	ff 75 10             	pushl  0x10(%ebp)
  80121f:	ff 75 0c             	pushl  0xc(%ebp)
  801222:	50                   	push   %eax
  801223:	ff d2                	call   *%edx
  801225:	83 c4 10             	add    $0x10,%esp
}
  801228:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122b:	c9                   	leave  
  80122c:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80122d:	a1 04 40 80 00       	mov    0x804004,%eax
  801232:	8b 40 48             	mov    0x48(%eax),%eax
  801235:	83 ec 04             	sub    $0x4,%esp
  801238:	53                   	push   %ebx
  801239:	50                   	push   %eax
  80123a:	68 b5 23 80 00       	push   $0x8023b5
  80123f:	e8 e1 ef ff ff       	call   800225 <cprintf>
		return -E_INVAL;
  801244:	83 c4 10             	add    $0x10,%esp
  801247:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124c:	eb da                	jmp    801228 <write+0x59>
		return -E_NOT_SUPP;
  80124e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801253:	eb d3                	jmp    801228 <write+0x59>

00801255 <seek>:

int
seek(int fdnum, off_t offset)
{
  801255:	f3 0f 1e fb          	endbr32 
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80125f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801262:	50                   	push   %eax
  801263:	ff 75 08             	pushl  0x8(%ebp)
  801266:	e8 0b fc ff ff       	call   800e76 <fd_lookup>
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 0e                	js     801280 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801272:	8b 55 0c             	mov    0xc(%ebp),%edx
  801275:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801278:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80127b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801280:	c9                   	leave  
  801281:	c3                   	ret    

00801282 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801282:	f3 0f 1e fb          	endbr32 
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	53                   	push   %ebx
  80128a:	83 ec 1c             	sub    $0x1c,%esp
  80128d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801290:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801293:	50                   	push   %eax
  801294:	53                   	push   %ebx
  801295:	e8 dc fb ff ff       	call   800e76 <fd_lookup>
  80129a:	83 c4 10             	add    $0x10,%esp
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 37                	js     8012d8 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ab:	ff 30                	pushl  (%eax)
  8012ad:	e8 18 fc ff ff       	call   800eca <dev_lookup>
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 1f                	js     8012d8 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012c0:	74 1b                	je     8012dd <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c5:	8b 52 18             	mov    0x18(%edx),%edx
  8012c8:	85 d2                	test   %edx,%edx
  8012ca:	74 32                	je     8012fe <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012cc:	83 ec 08             	sub    $0x8,%esp
  8012cf:	ff 75 0c             	pushl  0xc(%ebp)
  8012d2:	50                   	push   %eax
  8012d3:	ff d2                	call   *%edx
  8012d5:	83 c4 10             	add    $0x10,%esp
}
  8012d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012db:	c9                   	leave  
  8012dc:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012dd:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012e2:	8b 40 48             	mov    0x48(%eax),%eax
  8012e5:	83 ec 04             	sub    $0x4,%esp
  8012e8:	53                   	push   %ebx
  8012e9:	50                   	push   %eax
  8012ea:	68 78 23 80 00       	push   $0x802378
  8012ef:	e8 31 ef ff ff       	call   800225 <cprintf>
		return -E_INVAL;
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012fc:	eb da                	jmp    8012d8 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8012fe:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801303:	eb d3                	jmp    8012d8 <ftruncate+0x56>

00801305 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801305:	f3 0f 1e fb          	endbr32 
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	53                   	push   %ebx
  80130d:	83 ec 1c             	sub    $0x1c,%esp
  801310:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801313:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801316:	50                   	push   %eax
  801317:	ff 75 08             	pushl  0x8(%ebp)
  80131a:	e8 57 fb ff ff       	call   800e76 <fd_lookup>
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	85 c0                	test   %eax,%eax
  801324:	78 4b                	js     801371 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801326:	83 ec 08             	sub    $0x8,%esp
  801329:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132c:	50                   	push   %eax
  80132d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801330:	ff 30                	pushl  (%eax)
  801332:	e8 93 fb ff ff       	call   800eca <dev_lookup>
  801337:	83 c4 10             	add    $0x10,%esp
  80133a:	85 c0                	test   %eax,%eax
  80133c:	78 33                	js     801371 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80133e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801341:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801345:	74 2f                	je     801376 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801347:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80134a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801351:	00 00 00 
	stat->st_isdir = 0;
  801354:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80135b:	00 00 00 
	stat->st_dev = dev;
  80135e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801364:	83 ec 08             	sub    $0x8,%esp
  801367:	53                   	push   %ebx
  801368:	ff 75 f0             	pushl  -0x10(%ebp)
  80136b:	ff 50 14             	call   *0x14(%eax)
  80136e:	83 c4 10             	add    $0x10,%esp
}
  801371:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801374:	c9                   	leave  
  801375:	c3                   	ret    
		return -E_NOT_SUPP;
  801376:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80137b:	eb f4                	jmp    801371 <fstat+0x6c>

0080137d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80137d:	f3 0f 1e fb          	endbr32 
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	56                   	push   %esi
  801385:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	6a 00                	push   $0x0
  80138b:	ff 75 08             	pushl  0x8(%ebp)
  80138e:	e8 20 02 00 00       	call   8015b3 <open>
  801393:	89 c3                	mov    %eax,%ebx
  801395:	83 c4 10             	add    $0x10,%esp
  801398:	85 c0                	test   %eax,%eax
  80139a:	78 1b                	js     8013b7 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	ff 75 0c             	pushl  0xc(%ebp)
  8013a2:	50                   	push   %eax
  8013a3:	e8 5d ff ff ff       	call   801305 <fstat>
  8013a8:	89 c6                	mov    %eax,%esi
	close(fd);
  8013aa:	89 1c 24             	mov    %ebx,(%esp)
  8013ad:	e8 fd fb ff ff       	call   800faf <close>
	return r;
  8013b2:	83 c4 10             	add    $0x10,%esp
  8013b5:	89 f3                	mov    %esi,%ebx
}
  8013b7:	89 d8                	mov    %ebx,%eax
  8013b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bc:	5b                   	pop    %ebx
  8013bd:	5e                   	pop    %esi
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	56                   	push   %esi
  8013c4:	53                   	push   %ebx
  8013c5:	89 c6                	mov    %eax,%esi
  8013c7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013c9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013d0:	74 27                	je     8013f9 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013d2:	6a 07                	push   $0x7
  8013d4:	68 00 50 80 00       	push   $0x805000
  8013d9:	56                   	push   %esi
  8013da:	ff 35 00 40 80 00    	pushl  0x804000
  8013e0:	e8 e3 07 00 00       	call   801bc8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013e5:	83 c4 0c             	add    $0xc,%esp
  8013e8:	6a 00                	push   $0x0
  8013ea:	53                   	push   %ebx
  8013eb:	6a 00                	push   $0x0
  8013ed:	e8 69 07 00 00       	call   801b5b <ipc_recv>
}
  8013f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f5:	5b                   	pop    %ebx
  8013f6:	5e                   	pop    %esi
  8013f7:	5d                   	pop    %ebp
  8013f8:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013f9:	83 ec 0c             	sub    $0xc,%esp
  8013fc:	6a 01                	push   $0x1
  8013fe:	e8 18 08 00 00       	call   801c1b <ipc_find_env>
  801403:	a3 00 40 80 00       	mov    %eax,0x804000
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	eb c5                	jmp    8013d2 <fsipc+0x12>

0080140d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80140d:	f3 0f 1e fb          	endbr32 
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801417:	8b 45 08             	mov    0x8(%ebp),%eax
  80141a:	8b 40 0c             	mov    0xc(%eax),%eax
  80141d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801422:	8b 45 0c             	mov    0xc(%ebp),%eax
  801425:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80142a:	ba 00 00 00 00       	mov    $0x0,%edx
  80142f:	b8 02 00 00 00       	mov    $0x2,%eax
  801434:	e8 87 ff ff ff       	call   8013c0 <fsipc>
}
  801439:	c9                   	leave  
  80143a:	c3                   	ret    

0080143b <devfile_flush>:
{
  80143b:	f3 0f 1e fb          	endbr32 
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801445:	8b 45 08             	mov    0x8(%ebp),%eax
  801448:	8b 40 0c             	mov    0xc(%eax),%eax
  80144b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801450:	ba 00 00 00 00       	mov    $0x0,%edx
  801455:	b8 06 00 00 00       	mov    $0x6,%eax
  80145a:	e8 61 ff ff ff       	call   8013c0 <fsipc>
}
  80145f:	c9                   	leave  
  801460:	c3                   	ret    

00801461 <devfile_stat>:
{
  801461:	f3 0f 1e fb          	endbr32 
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	53                   	push   %ebx
  801469:	83 ec 04             	sub    $0x4,%esp
  80146c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80146f:	8b 45 08             	mov    0x8(%ebp),%eax
  801472:	8b 40 0c             	mov    0xc(%eax),%eax
  801475:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80147a:	ba 00 00 00 00       	mov    $0x0,%edx
  80147f:	b8 05 00 00 00       	mov    $0x5,%eax
  801484:	e8 37 ff ff ff       	call   8013c0 <fsipc>
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 2c                	js     8014b9 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80148d:	83 ec 08             	sub    $0x8,%esp
  801490:	68 00 50 80 00       	push   $0x805000
  801495:	53                   	push   %ebx
  801496:	e8 f4 f2 ff ff       	call   80078f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80149b:	a1 80 50 80 00       	mov    0x805080,%eax
  8014a0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014a6:	a1 84 50 80 00       	mov    0x805084,%eax
  8014ab:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014b1:	83 c4 10             	add    $0x10,%esp
  8014b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bc:	c9                   	leave  
  8014bd:	c3                   	ret    

008014be <devfile_write>:
{
  8014be:	f3 0f 1e fb          	endbr32 
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
  8014c5:	57                   	push   %edi
  8014c6:	56                   	push   %esi
  8014c7:	53                   	push   %ebx
  8014c8:	83 ec 0c             	sub    $0xc,%esp
  8014cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d7:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  8014dc:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8014e1:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  8014e6:	85 db                	test   %ebx,%ebx
  8014e8:	74 3b                	je     801525 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8014ea:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8014f0:	89 f8                	mov    %edi,%eax
  8014f2:	0f 46 c3             	cmovbe %ebx,%eax
  8014f5:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  8014fa:	83 ec 04             	sub    $0x4,%esp
  8014fd:	50                   	push   %eax
  8014fe:	56                   	push   %esi
  8014ff:	68 08 50 80 00       	push   $0x805008
  801504:	e8 3e f4 ff ff       	call   800947 <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801509:	ba 00 00 00 00       	mov    $0x0,%edx
  80150e:	b8 04 00 00 00       	mov    $0x4,%eax
  801513:	e8 a8 fe ff ff       	call   8013c0 <fsipc>
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	85 c0                	test   %eax,%eax
  80151d:	78 06                	js     801525 <devfile_write+0x67>
		buf_aux += r;
  80151f:	01 c6                	add    %eax,%esi
		n -= r;
  801521:	29 c3                	sub    %eax,%ebx
  801523:	eb c1                	jmp    8014e6 <devfile_write+0x28>
}
  801525:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801528:	5b                   	pop    %ebx
  801529:	5e                   	pop    %esi
  80152a:	5f                   	pop    %edi
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    

0080152d <devfile_read>:
{
  80152d:	f3 0f 1e fb          	endbr32 
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	56                   	push   %esi
  801535:	53                   	push   %ebx
  801536:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801539:	8b 45 08             	mov    0x8(%ebp),%eax
  80153c:	8b 40 0c             	mov    0xc(%eax),%eax
  80153f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801544:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80154a:	ba 00 00 00 00       	mov    $0x0,%edx
  80154f:	b8 03 00 00 00       	mov    $0x3,%eax
  801554:	e8 67 fe ff ff       	call   8013c0 <fsipc>
  801559:	89 c3                	mov    %eax,%ebx
  80155b:	85 c0                	test   %eax,%eax
  80155d:	78 1f                	js     80157e <devfile_read+0x51>
	assert(r <= n);
  80155f:	39 f0                	cmp    %esi,%eax
  801561:	77 24                	ja     801587 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801563:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801568:	7f 33                	jg     80159d <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80156a:	83 ec 04             	sub    $0x4,%esp
  80156d:	50                   	push   %eax
  80156e:	68 00 50 80 00       	push   $0x805000
  801573:	ff 75 0c             	pushl  0xc(%ebp)
  801576:	e8 cc f3 ff ff       	call   800947 <memmove>
	return r;
  80157b:	83 c4 10             	add    $0x10,%esp
}
  80157e:	89 d8                	mov    %ebx,%eax
  801580:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801583:	5b                   	pop    %ebx
  801584:	5e                   	pop    %esi
  801585:	5d                   	pop    %ebp
  801586:	c3                   	ret    
	assert(r <= n);
  801587:	68 e4 23 80 00       	push   $0x8023e4
  80158c:	68 eb 23 80 00       	push   $0x8023eb
  801591:	6a 7c                	push   $0x7c
  801593:	68 00 24 80 00       	push   $0x802400
  801598:	e8 a1 eb ff ff       	call   80013e <_panic>
	assert(r <= PGSIZE);
  80159d:	68 0b 24 80 00       	push   $0x80240b
  8015a2:	68 eb 23 80 00       	push   $0x8023eb
  8015a7:	6a 7d                	push   $0x7d
  8015a9:	68 00 24 80 00       	push   $0x802400
  8015ae:	e8 8b eb ff ff       	call   80013e <_panic>

008015b3 <open>:
{
  8015b3:	f3 0f 1e fb          	endbr32 
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	56                   	push   %esi
  8015bb:	53                   	push   %ebx
  8015bc:	83 ec 1c             	sub    $0x1c,%esp
  8015bf:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8015c2:	56                   	push   %esi
  8015c3:	e8 84 f1 ff ff       	call   80074c <strlen>
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015d0:	7f 6c                	jg     80163e <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8015d2:	83 ec 0c             	sub    $0xc,%esp
  8015d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d8:	50                   	push   %eax
  8015d9:	e8 42 f8 ff ff       	call   800e20 <fd_alloc>
  8015de:	89 c3                	mov    %eax,%ebx
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	78 3c                	js     801623 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8015e7:	83 ec 08             	sub    $0x8,%esp
  8015ea:	56                   	push   %esi
  8015eb:	68 00 50 80 00       	push   $0x805000
  8015f0:	e8 9a f1 ff ff       	call   80078f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f8:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801600:	b8 01 00 00 00       	mov    $0x1,%eax
  801605:	e8 b6 fd ff ff       	call   8013c0 <fsipc>
  80160a:	89 c3                	mov    %eax,%ebx
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	85 c0                	test   %eax,%eax
  801611:	78 19                	js     80162c <open+0x79>
	return fd2num(fd);
  801613:	83 ec 0c             	sub    $0xc,%esp
  801616:	ff 75 f4             	pushl  -0xc(%ebp)
  801619:	e8 cf f7 ff ff       	call   800ded <fd2num>
  80161e:	89 c3                	mov    %eax,%ebx
  801620:	83 c4 10             	add    $0x10,%esp
}
  801623:	89 d8                	mov    %ebx,%eax
  801625:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801628:	5b                   	pop    %ebx
  801629:	5e                   	pop    %esi
  80162a:	5d                   	pop    %ebp
  80162b:	c3                   	ret    
		fd_close(fd, 0);
  80162c:	83 ec 08             	sub    $0x8,%esp
  80162f:	6a 00                	push   $0x0
  801631:	ff 75 f4             	pushl  -0xc(%ebp)
  801634:	e8 eb f8 ff ff       	call   800f24 <fd_close>
		return r;
  801639:	83 c4 10             	add    $0x10,%esp
  80163c:	eb e5                	jmp    801623 <open+0x70>
		return -E_BAD_PATH;
  80163e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801643:	eb de                	jmp    801623 <open+0x70>

00801645 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801645:	f3 0f 1e fb          	endbr32 
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80164f:	ba 00 00 00 00       	mov    $0x0,%edx
  801654:	b8 08 00 00 00       	mov    $0x8,%eax
  801659:	e8 62 fd ff ff       	call   8013c0 <fsipc>
}
  80165e:	c9                   	leave  
  80165f:	c3                   	ret    

00801660 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801660:	f3 0f 1e fb          	endbr32 
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	56                   	push   %esi
  801668:	53                   	push   %ebx
  801669:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80166c:	83 ec 0c             	sub    $0xc,%esp
  80166f:	ff 75 08             	pushl  0x8(%ebp)
  801672:	e8 8a f7 ff ff       	call   800e01 <fd2data>
  801677:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801679:	83 c4 08             	add    $0x8,%esp
  80167c:	68 17 24 80 00       	push   $0x802417
  801681:	53                   	push   %ebx
  801682:	e8 08 f1 ff ff       	call   80078f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801687:	8b 46 04             	mov    0x4(%esi),%eax
  80168a:	2b 06                	sub    (%esi),%eax
  80168c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801692:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801699:	00 00 00 
	stat->st_dev = &devpipe;
  80169c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016a3:	30 80 00 
	return 0;
}
  8016a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ae:	5b                   	pop    %ebx
  8016af:	5e                   	pop    %esi
  8016b0:	5d                   	pop    %ebp
  8016b1:	c3                   	ret    

008016b2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016b2:	f3 0f 1e fb          	endbr32 
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 0c             	sub    $0xc,%esp
  8016bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016c0:	53                   	push   %ebx
  8016c1:	6a 00                	push   $0x0
  8016c3:	e8 a1 f5 ff ff       	call   800c69 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016c8:	89 1c 24             	mov    %ebx,(%esp)
  8016cb:	e8 31 f7 ff ff       	call   800e01 <fd2data>
  8016d0:	83 c4 08             	add    $0x8,%esp
  8016d3:	50                   	push   %eax
  8016d4:	6a 00                	push   $0x0
  8016d6:	e8 8e f5 ff ff       	call   800c69 <sys_page_unmap>
}
  8016db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    

008016e0 <_pipeisclosed>:
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	57                   	push   %edi
  8016e4:	56                   	push   %esi
  8016e5:	53                   	push   %ebx
  8016e6:	83 ec 1c             	sub    $0x1c,%esp
  8016e9:	89 c7                	mov    %eax,%edi
  8016eb:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8016ed:	a1 04 40 80 00       	mov    0x804004,%eax
  8016f2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016f5:	83 ec 0c             	sub    $0xc,%esp
  8016f8:	57                   	push   %edi
  8016f9:	e8 5a 05 00 00       	call   801c58 <pageref>
  8016fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801701:	89 34 24             	mov    %esi,(%esp)
  801704:	e8 4f 05 00 00       	call   801c58 <pageref>
		nn = thisenv->env_runs;
  801709:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80170f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801712:	83 c4 10             	add    $0x10,%esp
  801715:	39 cb                	cmp    %ecx,%ebx
  801717:	74 1b                	je     801734 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801719:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80171c:	75 cf                	jne    8016ed <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80171e:	8b 42 58             	mov    0x58(%edx),%eax
  801721:	6a 01                	push   $0x1
  801723:	50                   	push   %eax
  801724:	53                   	push   %ebx
  801725:	68 1e 24 80 00       	push   $0x80241e
  80172a:	e8 f6 ea ff ff       	call   800225 <cprintf>
  80172f:	83 c4 10             	add    $0x10,%esp
  801732:	eb b9                	jmp    8016ed <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801734:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801737:	0f 94 c0             	sete   %al
  80173a:	0f b6 c0             	movzbl %al,%eax
}
  80173d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801740:	5b                   	pop    %ebx
  801741:	5e                   	pop    %esi
  801742:	5f                   	pop    %edi
  801743:	5d                   	pop    %ebp
  801744:	c3                   	ret    

00801745 <devpipe_write>:
{
  801745:	f3 0f 1e fb          	endbr32 
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	57                   	push   %edi
  80174d:	56                   	push   %esi
  80174e:	53                   	push   %ebx
  80174f:	83 ec 28             	sub    $0x28,%esp
  801752:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801755:	56                   	push   %esi
  801756:	e8 a6 f6 ff ff       	call   800e01 <fd2data>
  80175b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80175d:	83 c4 10             	add    $0x10,%esp
  801760:	bf 00 00 00 00       	mov    $0x0,%edi
  801765:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801768:	74 4f                	je     8017b9 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80176a:	8b 43 04             	mov    0x4(%ebx),%eax
  80176d:	8b 0b                	mov    (%ebx),%ecx
  80176f:	8d 51 20             	lea    0x20(%ecx),%edx
  801772:	39 d0                	cmp    %edx,%eax
  801774:	72 14                	jb     80178a <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801776:	89 da                	mov    %ebx,%edx
  801778:	89 f0                	mov    %esi,%eax
  80177a:	e8 61 ff ff ff       	call   8016e0 <_pipeisclosed>
  80177f:	85 c0                	test   %eax,%eax
  801781:	75 3b                	jne    8017be <devpipe_write+0x79>
			sys_yield();
  801783:	e8 64 f4 ff ff       	call   800bec <sys_yield>
  801788:	eb e0                	jmp    80176a <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80178a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801791:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801794:	89 c2                	mov    %eax,%edx
  801796:	c1 fa 1f             	sar    $0x1f,%edx
  801799:	89 d1                	mov    %edx,%ecx
  80179b:	c1 e9 1b             	shr    $0x1b,%ecx
  80179e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017a1:	83 e2 1f             	and    $0x1f,%edx
  8017a4:	29 ca                	sub    %ecx,%edx
  8017a6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017ae:	83 c0 01             	add    $0x1,%eax
  8017b1:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8017b4:	83 c7 01             	add    $0x1,%edi
  8017b7:	eb ac                	jmp    801765 <devpipe_write+0x20>
	return i;
  8017b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8017bc:	eb 05                	jmp    8017c3 <devpipe_write+0x7e>
				return 0;
  8017be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c6:	5b                   	pop    %ebx
  8017c7:	5e                   	pop    %esi
  8017c8:	5f                   	pop    %edi
  8017c9:	5d                   	pop    %ebp
  8017ca:	c3                   	ret    

008017cb <devpipe_read>:
{
  8017cb:	f3 0f 1e fb          	endbr32 
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	57                   	push   %edi
  8017d3:	56                   	push   %esi
  8017d4:	53                   	push   %ebx
  8017d5:	83 ec 18             	sub    $0x18,%esp
  8017d8:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8017db:	57                   	push   %edi
  8017dc:	e8 20 f6 ff ff       	call   800e01 <fd2data>
  8017e1:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017e3:	83 c4 10             	add    $0x10,%esp
  8017e6:	be 00 00 00 00       	mov    $0x0,%esi
  8017eb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017ee:	75 14                	jne    801804 <devpipe_read+0x39>
	return i;
  8017f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8017f3:	eb 02                	jmp    8017f7 <devpipe_read+0x2c>
				return i;
  8017f5:	89 f0                	mov    %esi,%eax
}
  8017f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017fa:	5b                   	pop    %ebx
  8017fb:	5e                   	pop    %esi
  8017fc:	5f                   	pop    %edi
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    
			sys_yield();
  8017ff:	e8 e8 f3 ff ff       	call   800bec <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801804:	8b 03                	mov    (%ebx),%eax
  801806:	3b 43 04             	cmp    0x4(%ebx),%eax
  801809:	75 18                	jne    801823 <devpipe_read+0x58>
			if (i > 0)
  80180b:	85 f6                	test   %esi,%esi
  80180d:	75 e6                	jne    8017f5 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  80180f:	89 da                	mov    %ebx,%edx
  801811:	89 f8                	mov    %edi,%eax
  801813:	e8 c8 fe ff ff       	call   8016e0 <_pipeisclosed>
  801818:	85 c0                	test   %eax,%eax
  80181a:	74 e3                	je     8017ff <devpipe_read+0x34>
				return 0;
  80181c:	b8 00 00 00 00       	mov    $0x0,%eax
  801821:	eb d4                	jmp    8017f7 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801823:	99                   	cltd   
  801824:	c1 ea 1b             	shr    $0x1b,%edx
  801827:	01 d0                	add    %edx,%eax
  801829:	83 e0 1f             	and    $0x1f,%eax
  80182c:	29 d0                	sub    %edx,%eax
  80182e:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801833:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801836:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801839:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80183c:	83 c6 01             	add    $0x1,%esi
  80183f:	eb aa                	jmp    8017eb <devpipe_read+0x20>

00801841 <pipe>:
{
  801841:	f3 0f 1e fb          	endbr32 
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	56                   	push   %esi
  801849:	53                   	push   %ebx
  80184a:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80184d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801850:	50                   	push   %eax
  801851:	e8 ca f5 ff ff       	call   800e20 <fd_alloc>
  801856:	89 c3                	mov    %eax,%ebx
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	85 c0                	test   %eax,%eax
  80185d:	0f 88 23 01 00 00    	js     801986 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801863:	83 ec 04             	sub    $0x4,%esp
  801866:	68 07 04 00 00       	push   $0x407
  80186b:	ff 75 f4             	pushl  -0xc(%ebp)
  80186e:	6a 00                	push   $0x0
  801870:	e8 a2 f3 ff ff       	call   800c17 <sys_page_alloc>
  801875:	89 c3                	mov    %eax,%ebx
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	85 c0                	test   %eax,%eax
  80187c:	0f 88 04 01 00 00    	js     801986 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801882:	83 ec 0c             	sub    $0xc,%esp
  801885:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801888:	50                   	push   %eax
  801889:	e8 92 f5 ff ff       	call   800e20 <fd_alloc>
  80188e:	89 c3                	mov    %eax,%ebx
  801890:	83 c4 10             	add    $0x10,%esp
  801893:	85 c0                	test   %eax,%eax
  801895:	0f 88 db 00 00 00    	js     801976 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80189b:	83 ec 04             	sub    $0x4,%esp
  80189e:	68 07 04 00 00       	push   $0x407
  8018a3:	ff 75 f0             	pushl  -0x10(%ebp)
  8018a6:	6a 00                	push   $0x0
  8018a8:	e8 6a f3 ff ff       	call   800c17 <sys_page_alloc>
  8018ad:	89 c3                	mov    %eax,%ebx
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	85 c0                	test   %eax,%eax
  8018b4:	0f 88 bc 00 00 00    	js     801976 <pipe+0x135>
	va = fd2data(fd0);
  8018ba:	83 ec 0c             	sub    $0xc,%esp
  8018bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c0:	e8 3c f5 ff ff       	call   800e01 <fd2data>
  8018c5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c7:	83 c4 0c             	add    $0xc,%esp
  8018ca:	68 07 04 00 00       	push   $0x407
  8018cf:	50                   	push   %eax
  8018d0:	6a 00                	push   $0x0
  8018d2:	e8 40 f3 ff ff       	call   800c17 <sys_page_alloc>
  8018d7:	89 c3                	mov    %eax,%ebx
  8018d9:	83 c4 10             	add    $0x10,%esp
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	0f 88 82 00 00 00    	js     801966 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018e4:	83 ec 0c             	sub    $0xc,%esp
  8018e7:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ea:	e8 12 f5 ff ff       	call   800e01 <fd2data>
  8018ef:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018f6:	50                   	push   %eax
  8018f7:	6a 00                	push   $0x0
  8018f9:	56                   	push   %esi
  8018fa:	6a 00                	push   $0x0
  8018fc:	e8 3e f3 ff ff       	call   800c3f <sys_page_map>
  801901:	89 c3                	mov    %eax,%ebx
  801903:	83 c4 20             	add    $0x20,%esp
  801906:	85 c0                	test   %eax,%eax
  801908:	78 4e                	js     801958 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  80190a:	a1 20 30 80 00       	mov    0x803020,%eax
  80190f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801912:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801914:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801917:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80191e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801921:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801923:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801926:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80192d:	83 ec 0c             	sub    $0xc,%esp
  801930:	ff 75 f4             	pushl  -0xc(%ebp)
  801933:	e8 b5 f4 ff ff       	call   800ded <fd2num>
  801938:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80193b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80193d:	83 c4 04             	add    $0x4,%esp
  801940:	ff 75 f0             	pushl  -0x10(%ebp)
  801943:	e8 a5 f4 ff ff       	call   800ded <fd2num>
  801948:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80194b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	bb 00 00 00 00       	mov    $0x0,%ebx
  801956:	eb 2e                	jmp    801986 <pipe+0x145>
	sys_page_unmap(0, va);
  801958:	83 ec 08             	sub    $0x8,%esp
  80195b:	56                   	push   %esi
  80195c:	6a 00                	push   $0x0
  80195e:	e8 06 f3 ff ff       	call   800c69 <sys_page_unmap>
  801963:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801966:	83 ec 08             	sub    $0x8,%esp
  801969:	ff 75 f0             	pushl  -0x10(%ebp)
  80196c:	6a 00                	push   $0x0
  80196e:	e8 f6 f2 ff ff       	call   800c69 <sys_page_unmap>
  801973:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801976:	83 ec 08             	sub    $0x8,%esp
  801979:	ff 75 f4             	pushl  -0xc(%ebp)
  80197c:	6a 00                	push   $0x0
  80197e:	e8 e6 f2 ff ff       	call   800c69 <sys_page_unmap>
  801983:	83 c4 10             	add    $0x10,%esp
}
  801986:	89 d8                	mov    %ebx,%eax
  801988:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198b:	5b                   	pop    %ebx
  80198c:	5e                   	pop    %esi
  80198d:	5d                   	pop    %ebp
  80198e:	c3                   	ret    

0080198f <pipeisclosed>:
{
  80198f:	f3 0f 1e fb          	endbr32 
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801999:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199c:	50                   	push   %eax
  80199d:	ff 75 08             	pushl  0x8(%ebp)
  8019a0:	e8 d1 f4 ff ff       	call   800e76 <fd_lookup>
  8019a5:	83 c4 10             	add    $0x10,%esp
  8019a8:	85 c0                	test   %eax,%eax
  8019aa:	78 18                	js     8019c4 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  8019ac:	83 ec 0c             	sub    $0xc,%esp
  8019af:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b2:	e8 4a f4 ff ff       	call   800e01 <fd2data>
  8019b7:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8019b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019bc:	e8 1f fd ff ff       	call   8016e0 <_pipeisclosed>
  8019c1:	83 c4 10             	add    $0x10,%esp
}
  8019c4:	c9                   	leave  
  8019c5:	c3                   	ret    

008019c6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019c6:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  8019ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8019cf:	c3                   	ret    

008019d0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019d0:	f3 0f 1e fb          	endbr32 
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019da:	68 36 24 80 00       	push   $0x802436
  8019df:	ff 75 0c             	pushl  0xc(%ebp)
  8019e2:	e8 a8 ed ff ff       	call   80078f <strcpy>
	return 0;
}
  8019e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <devcons_write>:
{
  8019ee:	f3 0f 1e fb          	endbr32 
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	57                   	push   %edi
  8019f6:	56                   	push   %esi
  8019f7:	53                   	push   %ebx
  8019f8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8019fe:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a03:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801a09:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a0c:	73 31                	jae    801a3f <devcons_write+0x51>
		m = n - tot;
  801a0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a11:	29 f3                	sub    %esi,%ebx
  801a13:	83 fb 7f             	cmp    $0x7f,%ebx
  801a16:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801a1b:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a1e:	83 ec 04             	sub    $0x4,%esp
  801a21:	53                   	push   %ebx
  801a22:	89 f0                	mov    %esi,%eax
  801a24:	03 45 0c             	add    0xc(%ebp),%eax
  801a27:	50                   	push   %eax
  801a28:	57                   	push   %edi
  801a29:	e8 19 ef ff ff       	call   800947 <memmove>
		sys_cputs(buf, m);
  801a2e:	83 c4 08             	add    $0x8,%esp
  801a31:	53                   	push   %ebx
  801a32:	57                   	push   %edi
  801a33:	e8 14 f1 ff ff       	call   800b4c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801a38:	01 de                	add    %ebx,%esi
  801a3a:	83 c4 10             	add    $0x10,%esp
  801a3d:	eb ca                	jmp    801a09 <devcons_write+0x1b>
}
  801a3f:	89 f0                	mov    %esi,%eax
  801a41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a44:	5b                   	pop    %ebx
  801a45:	5e                   	pop    %esi
  801a46:	5f                   	pop    %edi
  801a47:	5d                   	pop    %ebp
  801a48:	c3                   	ret    

00801a49 <devcons_read>:
{
  801a49:	f3 0f 1e fb          	endbr32 
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	83 ec 08             	sub    $0x8,%esp
  801a53:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a58:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a5c:	74 21                	je     801a7f <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801a5e:	e8 13 f1 ff ff       	call   800b76 <sys_cgetc>
  801a63:	85 c0                	test   %eax,%eax
  801a65:	75 07                	jne    801a6e <devcons_read+0x25>
		sys_yield();
  801a67:	e8 80 f1 ff ff       	call   800bec <sys_yield>
  801a6c:	eb f0                	jmp    801a5e <devcons_read+0x15>
	if (c < 0)
  801a6e:	78 0f                	js     801a7f <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801a70:	83 f8 04             	cmp    $0x4,%eax
  801a73:	74 0c                	je     801a81 <devcons_read+0x38>
	*(char*)vbuf = c;
  801a75:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a78:	88 02                	mov    %al,(%edx)
	return 1;
  801a7a:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    
		return 0;
  801a81:	b8 00 00 00 00       	mov    $0x0,%eax
  801a86:	eb f7                	jmp    801a7f <devcons_read+0x36>

00801a88 <cputchar>:
{
  801a88:	f3 0f 1e fb          	endbr32 
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a92:	8b 45 08             	mov    0x8(%ebp),%eax
  801a95:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a98:	6a 01                	push   $0x1
  801a9a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a9d:	50                   	push   %eax
  801a9e:	e8 a9 f0 ff ff       	call   800b4c <sys_cputs>
}
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <getchar>:
{
  801aa8:	f3 0f 1e fb          	endbr32 
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
  801aaf:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ab2:	6a 01                	push   $0x1
  801ab4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ab7:	50                   	push   %eax
  801ab8:	6a 00                	push   $0x0
  801aba:	e8 3a f6 ff ff       	call   8010f9 <read>
	if (r < 0)
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	78 06                	js     801acc <getchar+0x24>
	if (r < 1)
  801ac6:	74 06                	je     801ace <getchar+0x26>
	return c;
  801ac8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801acc:	c9                   	leave  
  801acd:	c3                   	ret    
		return -E_EOF;
  801ace:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ad3:	eb f7                	jmp    801acc <getchar+0x24>

00801ad5 <iscons>:
{
  801ad5:	f3 0f 1e fb          	endbr32 
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801adf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae2:	50                   	push   %eax
  801ae3:	ff 75 08             	pushl  0x8(%ebp)
  801ae6:	e8 8b f3 ff ff       	call   800e76 <fd_lookup>
  801aeb:	83 c4 10             	add    $0x10,%esp
  801aee:	85 c0                	test   %eax,%eax
  801af0:	78 11                	js     801b03 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801afb:	39 10                	cmp    %edx,(%eax)
  801afd:	0f 94 c0             	sete   %al
  801b00:	0f b6 c0             	movzbl %al,%eax
}
  801b03:	c9                   	leave  
  801b04:	c3                   	ret    

00801b05 <opencons>:
{
  801b05:	f3 0f 1e fb          	endbr32 
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801b0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b12:	50                   	push   %eax
  801b13:	e8 08 f3 ff ff       	call   800e20 <fd_alloc>
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	78 3a                	js     801b59 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b1f:	83 ec 04             	sub    $0x4,%esp
  801b22:	68 07 04 00 00       	push   $0x407
  801b27:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2a:	6a 00                	push   $0x0
  801b2c:	e8 e6 f0 ff ff       	call   800c17 <sys_page_alloc>
  801b31:	83 c4 10             	add    $0x10,%esp
  801b34:	85 c0                	test   %eax,%eax
  801b36:	78 21                	js     801b59 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b41:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b46:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b4d:	83 ec 0c             	sub    $0xc,%esp
  801b50:	50                   	push   %eax
  801b51:	e8 97 f2 ff ff       	call   800ded <fd2num>
  801b56:	83 c4 10             	add    $0x10,%esp
}
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    

00801b5b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b5b:	f3 0f 1e fb          	endbr32 
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	8b 75 08             	mov    0x8(%ebp),%esi
  801b67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b74:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801b77:	83 ec 0c             	sub    $0xc,%esp
  801b7a:	50                   	push   %eax
  801b7b:	e8 ae f1 ff ff       	call   800d2e <sys_ipc_recv>
	if (f < 0) {
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	85 c0                	test   %eax,%eax
  801b85:	78 2b                	js     801bb2 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801b87:	85 f6                	test   %esi,%esi
  801b89:	74 0a                	je     801b95 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801b8b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b90:	8b 40 74             	mov    0x74(%eax),%eax
  801b93:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801b95:	85 db                	test   %ebx,%ebx
  801b97:	74 0a                	je     801ba3 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801b99:	a1 04 40 80 00       	mov    0x804004,%eax
  801b9e:	8b 40 78             	mov    0x78(%eax),%eax
  801ba1:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  801ba3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba8:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bae:	5b                   	pop    %ebx
  801baf:	5e                   	pop    %esi
  801bb0:	5d                   	pop    %ebp
  801bb1:	c3                   	ret    
		if (from_env_store != NULL) {
  801bb2:	85 f6                	test   %esi,%esi
  801bb4:	74 06                	je     801bbc <ipc_recv+0x61>
			*from_env_store = 0;
  801bb6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801bbc:	85 db                	test   %ebx,%ebx
  801bbe:	74 eb                	je     801bab <ipc_recv+0x50>
			*perm_store = 0;
  801bc0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801bc6:	eb e3                	jmp    801bab <ipc_recv+0x50>

00801bc8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bc8:	f3 0f 1e fb          	endbr32 
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	57                   	push   %edi
  801bd0:	56                   	push   %esi
  801bd1:	53                   	push   %ebx
  801bd2:	83 ec 0c             	sub    $0xc,%esp
  801bd5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bd8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  801bde:	85 db                	test   %ebx,%ebx
  801be0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801be5:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801be8:	ff 75 14             	pushl  0x14(%ebp)
  801beb:	53                   	push   %ebx
  801bec:	56                   	push   %esi
  801bed:	57                   	push   %edi
  801bee:	e8 12 f1 ff ff       	call   800d05 <sys_ipc_try_send>
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	79 19                	jns    801c13 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  801bfa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bfd:	74 e9                	je     801be8 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  801bff:	83 ec 04             	sub    $0x4,%esp
  801c02:	68 44 24 80 00       	push   $0x802444
  801c07:	6a 48                	push   $0x48
  801c09:	68 66 24 80 00       	push   $0x802466
  801c0e:	e8 2b e5 ff ff       	call   80013e <_panic>
		}
	}
}
  801c13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c16:	5b                   	pop    %ebx
  801c17:	5e                   	pop    %esi
  801c18:	5f                   	pop    %edi
  801c19:	5d                   	pop    %ebp
  801c1a:	c3                   	ret    

00801c1b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c1b:	f3 0f 1e fb          	endbr32 
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c25:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c2a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c2d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c33:	8b 52 50             	mov    0x50(%edx),%edx
  801c36:	39 ca                	cmp    %ecx,%edx
  801c38:	74 11                	je     801c4b <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c3a:	83 c0 01             	add    $0x1,%eax
  801c3d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c42:	75 e6                	jne    801c2a <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c44:	b8 00 00 00 00       	mov    $0x0,%eax
  801c49:	eb 0b                	jmp    801c56 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c4b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c4e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c53:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    

00801c58 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c58:	f3 0f 1e fb          	endbr32 
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c62:	89 c2                	mov    %eax,%edx
  801c64:	c1 ea 16             	shr    $0x16,%edx
  801c67:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c6e:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c73:	f6 c1 01             	test   $0x1,%cl
  801c76:	74 1c                	je     801c94 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c78:	c1 e8 0c             	shr    $0xc,%eax
  801c7b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c82:	a8 01                	test   $0x1,%al
  801c84:	74 0e                	je     801c94 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c86:	c1 e8 0c             	shr    $0xc,%eax
  801c89:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c90:	ef 
  801c91:	0f b7 d2             	movzwl %dx,%edx
}
  801c94:	89 d0                	mov    %edx,%eax
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    
  801c98:	66 90                	xchg   %ax,%ax
  801c9a:	66 90                	xchg   %ax,%ax
  801c9c:	66 90                	xchg   %ax,%ax
  801c9e:	66 90                	xchg   %ax,%ax

00801ca0 <__udivdi3>:
  801ca0:	f3 0f 1e fb          	endbr32 
  801ca4:	55                   	push   %ebp
  801ca5:	57                   	push   %edi
  801ca6:	56                   	push   %esi
  801ca7:	53                   	push   %ebx
  801ca8:	83 ec 1c             	sub    $0x1c,%esp
  801cab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801caf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801cb3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cb7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801cbb:	85 d2                	test   %edx,%edx
  801cbd:	75 19                	jne    801cd8 <__udivdi3+0x38>
  801cbf:	39 f3                	cmp    %esi,%ebx
  801cc1:	76 4d                	jbe    801d10 <__udivdi3+0x70>
  801cc3:	31 ff                	xor    %edi,%edi
  801cc5:	89 e8                	mov    %ebp,%eax
  801cc7:	89 f2                	mov    %esi,%edx
  801cc9:	f7 f3                	div    %ebx
  801ccb:	89 fa                	mov    %edi,%edx
  801ccd:	83 c4 1c             	add    $0x1c,%esp
  801cd0:	5b                   	pop    %ebx
  801cd1:	5e                   	pop    %esi
  801cd2:	5f                   	pop    %edi
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    
  801cd5:	8d 76 00             	lea    0x0(%esi),%esi
  801cd8:	39 f2                	cmp    %esi,%edx
  801cda:	76 14                	jbe    801cf0 <__udivdi3+0x50>
  801cdc:	31 ff                	xor    %edi,%edi
  801cde:	31 c0                	xor    %eax,%eax
  801ce0:	89 fa                	mov    %edi,%edx
  801ce2:	83 c4 1c             	add    $0x1c,%esp
  801ce5:	5b                   	pop    %ebx
  801ce6:	5e                   	pop    %esi
  801ce7:	5f                   	pop    %edi
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    
  801cea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf0:	0f bd fa             	bsr    %edx,%edi
  801cf3:	83 f7 1f             	xor    $0x1f,%edi
  801cf6:	75 48                	jne    801d40 <__udivdi3+0xa0>
  801cf8:	39 f2                	cmp    %esi,%edx
  801cfa:	72 06                	jb     801d02 <__udivdi3+0x62>
  801cfc:	31 c0                	xor    %eax,%eax
  801cfe:	39 eb                	cmp    %ebp,%ebx
  801d00:	77 de                	ja     801ce0 <__udivdi3+0x40>
  801d02:	b8 01 00 00 00       	mov    $0x1,%eax
  801d07:	eb d7                	jmp    801ce0 <__udivdi3+0x40>
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	89 d9                	mov    %ebx,%ecx
  801d12:	85 db                	test   %ebx,%ebx
  801d14:	75 0b                	jne    801d21 <__udivdi3+0x81>
  801d16:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1b:	31 d2                	xor    %edx,%edx
  801d1d:	f7 f3                	div    %ebx
  801d1f:	89 c1                	mov    %eax,%ecx
  801d21:	31 d2                	xor    %edx,%edx
  801d23:	89 f0                	mov    %esi,%eax
  801d25:	f7 f1                	div    %ecx
  801d27:	89 c6                	mov    %eax,%esi
  801d29:	89 e8                	mov    %ebp,%eax
  801d2b:	89 f7                	mov    %esi,%edi
  801d2d:	f7 f1                	div    %ecx
  801d2f:	89 fa                	mov    %edi,%edx
  801d31:	83 c4 1c             	add    $0x1c,%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	89 f9                	mov    %edi,%ecx
  801d42:	b8 20 00 00 00       	mov    $0x20,%eax
  801d47:	29 f8                	sub    %edi,%eax
  801d49:	d3 e2                	shl    %cl,%edx
  801d4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d4f:	89 c1                	mov    %eax,%ecx
  801d51:	89 da                	mov    %ebx,%edx
  801d53:	d3 ea                	shr    %cl,%edx
  801d55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d59:	09 d1                	or     %edx,%ecx
  801d5b:	89 f2                	mov    %esi,%edx
  801d5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d61:	89 f9                	mov    %edi,%ecx
  801d63:	d3 e3                	shl    %cl,%ebx
  801d65:	89 c1                	mov    %eax,%ecx
  801d67:	d3 ea                	shr    %cl,%edx
  801d69:	89 f9                	mov    %edi,%ecx
  801d6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d6f:	89 eb                	mov    %ebp,%ebx
  801d71:	d3 e6                	shl    %cl,%esi
  801d73:	89 c1                	mov    %eax,%ecx
  801d75:	d3 eb                	shr    %cl,%ebx
  801d77:	09 de                	or     %ebx,%esi
  801d79:	89 f0                	mov    %esi,%eax
  801d7b:	f7 74 24 08          	divl   0x8(%esp)
  801d7f:	89 d6                	mov    %edx,%esi
  801d81:	89 c3                	mov    %eax,%ebx
  801d83:	f7 64 24 0c          	mull   0xc(%esp)
  801d87:	39 d6                	cmp    %edx,%esi
  801d89:	72 15                	jb     801da0 <__udivdi3+0x100>
  801d8b:	89 f9                	mov    %edi,%ecx
  801d8d:	d3 e5                	shl    %cl,%ebp
  801d8f:	39 c5                	cmp    %eax,%ebp
  801d91:	73 04                	jae    801d97 <__udivdi3+0xf7>
  801d93:	39 d6                	cmp    %edx,%esi
  801d95:	74 09                	je     801da0 <__udivdi3+0x100>
  801d97:	89 d8                	mov    %ebx,%eax
  801d99:	31 ff                	xor    %edi,%edi
  801d9b:	e9 40 ff ff ff       	jmp    801ce0 <__udivdi3+0x40>
  801da0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801da3:	31 ff                	xor    %edi,%edi
  801da5:	e9 36 ff ff ff       	jmp    801ce0 <__udivdi3+0x40>
  801daa:	66 90                	xchg   %ax,%ax
  801dac:	66 90                	xchg   %ax,%ax
  801dae:	66 90                	xchg   %ax,%ax

00801db0 <__umoddi3>:
  801db0:	f3 0f 1e fb          	endbr32 
  801db4:	55                   	push   %ebp
  801db5:	57                   	push   %edi
  801db6:	56                   	push   %esi
  801db7:	53                   	push   %ebx
  801db8:	83 ec 1c             	sub    $0x1c,%esp
  801dbb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801dbf:	8b 74 24 30          	mov    0x30(%esp),%esi
  801dc3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801dc7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	75 19                	jne    801de8 <__umoddi3+0x38>
  801dcf:	39 df                	cmp    %ebx,%edi
  801dd1:	76 5d                	jbe    801e30 <__umoddi3+0x80>
  801dd3:	89 f0                	mov    %esi,%eax
  801dd5:	89 da                	mov    %ebx,%edx
  801dd7:	f7 f7                	div    %edi
  801dd9:	89 d0                	mov    %edx,%eax
  801ddb:	31 d2                	xor    %edx,%edx
  801ddd:	83 c4 1c             	add    $0x1c,%esp
  801de0:	5b                   	pop    %ebx
  801de1:	5e                   	pop    %esi
  801de2:	5f                   	pop    %edi
  801de3:	5d                   	pop    %ebp
  801de4:	c3                   	ret    
  801de5:	8d 76 00             	lea    0x0(%esi),%esi
  801de8:	89 f2                	mov    %esi,%edx
  801dea:	39 d8                	cmp    %ebx,%eax
  801dec:	76 12                	jbe    801e00 <__umoddi3+0x50>
  801dee:	89 f0                	mov    %esi,%eax
  801df0:	89 da                	mov    %ebx,%edx
  801df2:	83 c4 1c             	add    $0x1c,%esp
  801df5:	5b                   	pop    %ebx
  801df6:	5e                   	pop    %esi
  801df7:	5f                   	pop    %edi
  801df8:	5d                   	pop    %ebp
  801df9:	c3                   	ret    
  801dfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e00:	0f bd e8             	bsr    %eax,%ebp
  801e03:	83 f5 1f             	xor    $0x1f,%ebp
  801e06:	75 50                	jne    801e58 <__umoddi3+0xa8>
  801e08:	39 d8                	cmp    %ebx,%eax
  801e0a:	0f 82 e0 00 00 00    	jb     801ef0 <__umoddi3+0x140>
  801e10:	89 d9                	mov    %ebx,%ecx
  801e12:	39 f7                	cmp    %esi,%edi
  801e14:	0f 86 d6 00 00 00    	jbe    801ef0 <__umoddi3+0x140>
  801e1a:	89 d0                	mov    %edx,%eax
  801e1c:	89 ca                	mov    %ecx,%edx
  801e1e:	83 c4 1c             	add    $0x1c,%esp
  801e21:	5b                   	pop    %ebx
  801e22:	5e                   	pop    %esi
  801e23:	5f                   	pop    %edi
  801e24:	5d                   	pop    %ebp
  801e25:	c3                   	ret    
  801e26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	89 fd                	mov    %edi,%ebp
  801e32:	85 ff                	test   %edi,%edi
  801e34:	75 0b                	jne    801e41 <__umoddi3+0x91>
  801e36:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3b:	31 d2                	xor    %edx,%edx
  801e3d:	f7 f7                	div    %edi
  801e3f:	89 c5                	mov    %eax,%ebp
  801e41:	89 d8                	mov    %ebx,%eax
  801e43:	31 d2                	xor    %edx,%edx
  801e45:	f7 f5                	div    %ebp
  801e47:	89 f0                	mov    %esi,%eax
  801e49:	f7 f5                	div    %ebp
  801e4b:	89 d0                	mov    %edx,%eax
  801e4d:	31 d2                	xor    %edx,%edx
  801e4f:	eb 8c                	jmp    801ddd <__umoddi3+0x2d>
  801e51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e58:	89 e9                	mov    %ebp,%ecx
  801e5a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e5f:	29 ea                	sub    %ebp,%edx
  801e61:	d3 e0                	shl    %cl,%eax
  801e63:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e67:	89 d1                	mov    %edx,%ecx
  801e69:	89 f8                	mov    %edi,%eax
  801e6b:	d3 e8                	shr    %cl,%eax
  801e6d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e71:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e75:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e79:	09 c1                	or     %eax,%ecx
  801e7b:	89 d8                	mov    %ebx,%eax
  801e7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e81:	89 e9                	mov    %ebp,%ecx
  801e83:	d3 e7                	shl    %cl,%edi
  801e85:	89 d1                	mov    %edx,%ecx
  801e87:	d3 e8                	shr    %cl,%eax
  801e89:	89 e9                	mov    %ebp,%ecx
  801e8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e8f:	d3 e3                	shl    %cl,%ebx
  801e91:	89 c7                	mov    %eax,%edi
  801e93:	89 d1                	mov    %edx,%ecx
  801e95:	89 f0                	mov    %esi,%eax
  801e97:	d3 e8                	shr    %cl,%eax
  801e99:	89 e9                	mov    %ebp,%ecx
  801e9b:	89 fa                	mov    %edi,%edx
  801e9d:	d3 e6                	shl    %cl,%esi
  801e9f:	09 d8                	or     %ebx,%eax
  801ea1:	f7 74 24 08          	divl   0x8(%esp)
  801ea5:	89 d1                	mov    %edx,%ecx
  801ea7:	89 f3                	mov    %esi,%ebx
  801ea9:	f7 64 24 0c          	mull   0xc(%esp)
  801ead:	89 c6                	mov    %eax,%esi
  801eaf:	89 d7                	mov    %edx,%edi
  801eb1:	39 d1                	cmp    %edx,%ecx
  801eb3:	72 06                	jb     801ebb <__umoddi3+0x10b>
  801eb5:	75 10                	jne    801ec7 <__umoddi3+0x117>
  801eb7:	39 c3                	cmp    %eax,%ebx
  801eb9:	73 0c                	jae    801ec7 <__umoddi3+0x117>
  801ebb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801ebf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801ec3:	89 d7                	mov    %edx,%edi
  801ec5:	89 c6                	mov    %eax,%esi
  801ec7:	89 ca                	mov    %ecx,%edx
  801ec9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801ece:	29 f3                	sub    %esi,%ebx
  801ed0:	19 fa                	sbb    %edi,%edx
  801ed2:	89 d0                	mov    %edx,%eax
  801ed4:	d3 e0                	shl    %cl,%eax
  801ed6:	89 e9                	mov    %ebp,%ecx
  801ed8:	d3 eb                	shr    %cl,%ebx
  801eda:	d3 ea                	shr    %cl,%edx
  801edc:	09 d8                	or     %ebx,%eax
  801ede:	83 c4 1c             	add    $0x1c,%esp
  801ee1:	5b                   	pop    %ebx
  801ee2:	5e                   	pop    %esi
  801ee3:	5f                   	pop    %edi
  801ee4:	5d                   	pop    %ebp
  801ee5:	c3                   	ret    
  801ee6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801eed:	8d 76 00             	lea    0x0(%esi),%esi
  801ef0:	29 fe                	sub    %edi,%esi
  801ef2:	19 c3                	sbb    %eax,%ebx
  801ef4:	89 f2                	mov    %esi,%edx
  801ef6:	89 d9                	mov    %ebx,%ecx
  801ef8:	e9 1d ff ff ff       	jmp    801e1a <__umoddi3+0x6a>
