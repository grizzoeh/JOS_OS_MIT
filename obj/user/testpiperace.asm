
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 c1 01 00 00       	call   8001f2 <libmain>
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
  80003c:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003f:	68 e0 24 80 00       	push   $0x8024e0
  800044:	e8 fc 02 00 00       	call   800345 <cprintf>
	if ((r = pipe(p)) < 0)
  800049:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80004c:	89 04 24             	mov    %eax,(%esp)
  80004f:	e8 79 1e 00 00       	call   801ecd <pipe>
  800054:	83 c4 10             	add    $0x10,%esp
  800057:	85 c0                	test   %eax,%eax
  800059:	78 59                	js     8000b4 <umain+0x81>
		panic("pipe: %e", r);
	max = 200;
	if ((r = fork()) < 0)
  80005b:	e8 88 11 00 00       	call   8011e8 <fork>
  800060:	89 c6                	mov    %eax,%esi
  800062:	85 c0                	test   %eax,%eax
  800064:	78 60                	js     8000c6 <umain+0x93>
		panic("fork: %e", r);
	if (r == 0) {
  800066:	74 70                	je     8000d8 <umain+0xa5>
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  800068:	83 ec 08             	sub    $0x8,%esp
  80006b:	56                   	push   %esi
  80006c:	68 3a 25 80 00       	push   $0x80253a
  800071:	e8 cf 02 00 00       	call   800345 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  800076:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  80007c:	83 c4 08             	add    $0x8,%esp
  80007f:	6b c6 7c             	imul   $0x7c,%esi,%eax
  800082:	c1 f8 02             	sar    $0x2,%eax
  800085:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  80008b:	50                   	push   %eax
  80008c:	68 45 25 80 00       	push   $0x802545
  800091:	e8 af 02 00 00       	call   800345 <cprintf>
	dup(p[0], 10);
  800096:	83 c4 08             	add    $0x8,%esp
  800099:	6a 0a                	push   $0xa
  80009b:	ff 75 f0             	pushl  -0x10(%ebp)
  80009e:	e8 b2 15 00 00       	call   801655 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  8000a3:	83 c4 10             	add    $0x10,%esp
  8000a6:	6b de 7c             	imul   $0x7c,%esi,%ebx
  8000a9:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8000af:	e9 92 00 00 00       	jmp    800146 <umain+0x113>
		panic("pipe: %e", r);
  8000b4:	50                   	push   %eax
  8000b5:	68 f9 24 80 00       	push   $0x8024f9
  8000ba:	6a 0d                	push   $0xd
  8000bc:	68 02 25 80 00       	push   $0x802502
  8000c1:	e8 98 01 00 00       	call   80025e <_panic>
		panic("fork: %e", r);
  8000c6:	50                   	push   %eax
  8000c7:	68 16 25 80 00       	push   $0x802516
  8000cc:	6a 10                	push   $0x10
  8000ce:	68 02 25 80 00       	push   $0x802502
  8000d3:	e8 86 01 00 00       	call   80025e <_panic>
		close(p[1]);
  8000d8:	83 ec 0c             	sub    $0xc,%esp
  8000db:	ff 75 f4             	pushl  -0xc(%ebp)
  8000de:	e8 18 15 00 00       	call   8015fb <close>
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	bb c8 00 00 00       	mov    $0xc8,%ebx
  8000eb:	eb 1f                	jmp    80010c <umain+0xd9>
				cprintf("RACE: pipe appears closed\n");
  8000ed:	83 ec 0c             	sub    $0xc,%esp
  8000f0:	68 1f 25 80 00       	push   $0x80251f
  8000f5:	e8 4b 02 00 00       	call   800345 <cprintf>
				exit();
  8000fa:	e8 41 01 00 00       	call   800240 <exit>
  8000ff:	83 c4 10             	add    $0x10,%esp
			sys_yield();
  800102:	e8 05 0c 00 00       	call   800d0c <sys_yield>
		for (i=0; i<max; i++) {
  800107:	83 eb 01             	sub    $0x1,%ebx
  80010a:	74 14                	je     800120 <umain+0xed>
			if(pipeisclosed(p[0])){
  80010c:	83 ec 0c             	sub    $0xc,%esp
  80010f:	ff 75 f0             	pushl  -0x10(%ebp)
  800112:	e8 04 1f 00 00       	call   80201b <pipeisclosed>
  800117:	83 c4 10             	add    $0x10,%esp
  80011a:	85 c0                	test   %eax,%eax
  80011c:	74 e4                	je     800102 <umain+0xcf>
  80011e:	eb cd                	jmp    8000ed <umain+0xba>
		ipc_recv(0,0,0);
  800120:	83 ec 04             	sub    $0x4,%esp
  800123:	6a 00                	push   $0x0
  800125:	6a 00                	push   $0x0
  800127:	6a 00                	push   $0x0
  800129:	e8 0e 12 00 00       	call   80133c <ipc_recv>
  80012e:	83 c4 10             	add    $0x10,%esp
  800131:	e9 32 ff ff ff       	jmp    800068 <umain+0x35>
		dup(p[0], 10);
  800136:	83 ec 08             	sub    $0x8,%esp
  800139:	6a 0a                	push   $0xa
  80013b:	ff 75 f0             	pushl  -0x10(%ebp)
  80013e:	e8 12 15 00 00       	call   801655 <dup>
  800143:	83 c4 10             	add    $0x10,%esp
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 43 54             	mov    0x54(%ebx),%eax
  800149:	83 f8 02             	cmp    $0x2,%eax
  80014c:	74 e8                	je     800136 <umain+0x103>

	cprintf("child done with loop\n");
  80014e:	83 ec 0c             	sub    $0xc,%esp
  800151:	68 50 25 80 00       	push   $0x802550
  800156:	e8 ea 01 00 00       	call   800345 <cprintf>
	if (pipeisclosed(p[0]))
  80015b:	83 c4 04             	add    $0x4,%esp
  80015e:	ff 75 f0             	pushl  -0x10(%ebp)
  800161:	e8 b5 1e 00 00       	call   80201b <pipeisclosed>
  800166:	83 c4 10             	add    $0x10,%esp
  800169:	85 c0                	test   %eax,%eax
  80016b:	75 48                	jne    8001b5 <umain+0x182>
		panic("somehow the other end of p[0] got closed!");
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80016d:	83 ec 08             	sub    $0x8,%esp
  800170:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800173:	50                   	push   %eax
  800174:	ff 75 f0             	pushl  -0x10(%ebp)
  800177:	e8 46 13 00 00       	call   8014c2 <fd_lookup>
  80017c:	83 c4 10             	add    $0x10,%esp
  80017f:	85 c0                	test   %eax,%eax
  800181:	78 46                	js     8001c9 <umain+0x196>
		panic("cannot look up p[0]: %e", r);
	va = fd2data(fd);
  800183:	83 ec 0c             	sub    $0xc,%esp
  800186:	ff 75 ec             	pushl  -0x14(%ebp)
  800189:	e8 bf 12 00 00       	call   80144d <fd2data>
	if (pageref(va) != 3+1)
  80018e:	89 04 24             	mov    %eax,(%esp)
  800191:	e8 16 1b 00 00       	call   801cac <pageref>
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	83 f8 04             	cmp    $0x4,%eax
  80019c:	74 3d                	je     8001db <umain+0x1a8>
		cprintf("\nchild detected race\n");
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	68 7e 25 80 00       	push   $0x80257e
  8001a6:	e8 9a 01 00 00       	call   800345 <cprintf>
  8001ab:	83 c4 10             	add    $0x10,%esp
	else
		cprintf("\nrace didn't happen\n", max);
}
  8001ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001b1:	5b                   	pop    %ebx
  8001b2:	5e                   	pop    %esi
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    
		panic("somehow the other end of p[0] got closed!");
  8001b5:	83 ec 04             	sub    $0x4,%esp
  8001b8:	68 ac 25 80 00       	push   $0x8025ac
  8001bd:	6a 3a                	push   $0x3a
  8001bf:	68 02 25 80 00       	push   $0x802502
  8001c4:	e8 95 00 00 00       	call   80025e <_panic>
		panic("cannot look up p[0]: %e", r);
  8001c9:	50                   	push   %eax
  8001ca:	68 66 25 80 00       	push   $0x802566
  8001cf:	6a 3c                	push   $0x3c
  8001d1:	68 02 25 80 00       	push   $0x802502
  8001d6:	e8 83 00 00 00       	call   80025e <_panic>
		cprintf("\nrace didn't happen\n", max);
  8001db:	83 ec 08             	sub    $0x8,%esp
  8001de:	68 c8 00 00 00       	push   $0xc8
  8001e3:	68 94 25 80 00       	push   $0x802594
  8001e8:	e8 58 01 00 00       	call   800345 <cprintf>
  8001ed:	83 c4 10             	add    $0x10,%esp
}
  8001f0:	eb bc                	jmp    8001ae <umain+0x17b>

008001f2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001f2:	f3 0f 1e fb          	endbr32 
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001fe:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800201:	e8 de 0a 00 00       	call   800ce4 <sys_getenvid>
	if (id >= 0)
  800206:	85 c0                	test   %eax,%eax
  800208:	78 12                	js     80021c <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  80020a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80020f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800212:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800217:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7e 07                	jle    800227 <libmain+0x35>
		binaryname = argv[0];
  800220:	8b 06                	mov    (%esi),%eax
  800222:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	53                   	push   %ebx
  80022c:	e8 02 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800231:	e8 0a 00 00 00       	call   800240 <exit>
}
  800236:	83 c4 10             	add    $0x10,%esp
  800239:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80023c:	5b                   	pop    %ebx
  80023d:	5e                   	pop    %esi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800240:	f3 0f 1e fb          	endbr32 
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80024a:	e8 dd 13 00 00       	call   80162c <close_all>
	sys_env_destroy(0);
  80024f:	83 ec 0c             	sub    $0xc,%esp
  800252:	6a 00                	push   $0x0
  800254:	e8 65 0a 00 00       	call   800cbe <sys_env_destroy>
}
  800259:	83 c4 10             	add    $0x10,%esp
  80025c:	c9                   	leave  
  80025d:	c3                   	ret    

0080025e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80025e:	f3 0f 1e fb          	endbr32 
  800262:	55                   	push   %ebp
  800263:	89 e5                	mov    %esp,%ebp
  800265:	56                   	push   %esi
  800266:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800267:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80026a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800270:	e8 6f 0a 00 00       	call   800ce4 <sys_getenvid>
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	ff 75 0c             	pushl  0xc(%ebp)
  80027b:	ff 75 08             	pushl  0x8(%ebp)
  80027e:	56                   	push   %esi
  80027f:	50                   	push   %eax
  800280:	68 e0 25 80 00       	push   $0x8025e0
  800285:	e8 bb 00 00 00       	call   800345 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80028a:	83 c4 18             	add    $0x18,%esp
  80028d:	53                   	push   %ebx
  80028e:	ff 75 10             	pushl  0x10(%ebp)
  800291:	e8 5a 00 00 00       	call   8002f0 <vcprintf>
	cprintf("\n");
  800296:	c7 04 24 f7 24 80 00 	movl   $0x8024f7,(%esp)
  80029d:	e8 a3 00 00 00       	call   800345 <cprintf>
  8002a2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002a5:	cc                   	int3   
  8002a6:	eb fd                	jmp    8002a5 <_panic+0x47>

008002a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a8:	f3 0f 1e fb          	endbr32 
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	53                   	push   %ebx
  8002b0:	83 ec 04             	sub    $0x4,%esp
  8002b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002b6:	8b 13                	mov    (%ebx),%edx
  8002b8:	8d 42 01             	lea    0x1(%edx),%eax
  8002bb:	89 03                	mov    %eax,(%ebx)
  8002bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002c4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002c9:	74 09                	je     8002d4 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002cb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002d2:	c9                   	leave  
  8002d3:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002d4:	83 ec 08             	sub    $0x8,%esp
  8002d7:	68 ff 00 00 00       	push   $0xff
  8002dc:	8d 43 08             	lea    0x8(%ebx),%eax
  8002df:	50                   	push   %eax
  8002e0:	e8 87 09 00 00       	call   800c6c <sys_cputs>
		b->idx = 0;
  8002e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002eb:	83 c4 10             	add    $0x10,%esp
  8002ee:	eb db                	jmp    8002cb <putch+0x23>

008002f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002f0:	f3 0f 1e fb          	endbr32 
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002fd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800304:	00 00 00 
	b.cnt = 0;
  800307:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80030e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800311:	ff 75 0c             	pushl  0xc(%ebp)
  800314:	ff 75 08             	pushl  0x8(%ebp)
  800317:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80031d:	50                   	push   %eax
  80031e:	68 a8 02 80 00       	push   $0x8002a8
  800323:	e8 80 01 00 00       	call   8004a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800328:	83 c4 08             	add    $0x8,%esp
  80032b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800331:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800337:	50                   	push   %eax
  800338:	e8 2f 09 00 00       	call   800c6c <sys_cputs>

	return b.cnt;
}
  80033d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800343:	c9                   	leave  
  800344:	c3                   	ret    

00800345 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800345:	f3 0f 1e fb          	endbr32 
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80034f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800352:	50                   	push   %eax
  800353:	ff 75 08             	pushl  0x8(%ebp)
  800356:	e8 95 ff ff ff       	call   8002f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	57                   	push   %edi
  800361:	56                   	push   %esi
  800362:	53                   	push   %ebx
  800363:	83 ec 1c             	sub    $0x1c,%esp
  800366:	89 c7                	mov    %eax,%edi
  800368:	89 d6                	mov    %edx,%esi
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800370:	89 d1                	mov    %edx,%ecx
  800372:	89 c2                	mov    %eax,%edx
  800374:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800377:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80037a:	8b 45 10             	mov    0x10(%ebp),%eax
  80037d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800380:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800383:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80038a:	39 c2                	cmp    %eax,%edx
  80038c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80038f:	72 3e                	jb     8003cf <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800391:	83 ec 0c             	sub    $0xc,%esp
  800394:	ff 75 18             	pushl  0x18(%ebp)
  800397:	83 eb 01             	sub    $0x1,%ebx
  80039a:	53                   	push   %ebx
  80039b:	50                   	push   %eax
  80039c:	83 ec 08             	sub    $0x8,%esp
  80039f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8003a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ab:	e8 d0 1e 00 00       	call   802280 <__udivdi3>
  8003b0:	83 c4 18             	add    $0x18,%esp
  8003b3:	52                   	push   %edx
  8003b4:	50                   	push   %eax
  8003b5:	89 f2                	mov    %esi,%edx
  8003b7:	89 f8                	mov    %edi,%eax
  8003b9:	e8 9f ff ff ff       	call   80035d <printnum>
  8003be:	83 c4 20             	add    $0x20,%esp
  8003c1:	eb 13                	jmp    8003d6 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	56                   	push   %esi
  8003c7:	ff 75 18             	pushl  0x18(%ebp)
  8003ca:	ff d7                	call   *%edi
  8003cc:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003cf:	83 eb 01             	sub    $0x1,%ebx
  8003d2:	85 db                	test   %ebx,%ebx
  8003d4:	7f ed                	jg     8003c3 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003d6:	83 ec 08             	sub    $0x8,%esp
  8003d9:	56                   	push   %esi
  8003da:	83 ec 04             	sub    $0x4,%esp
  8003dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8003e3:	ff 75 dc             	pushl  -0x24(%ebp)
  8003e6:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e9:	e8 a2 1f 00 00       	call   802390 <__umoddi3>
  8003ee:	83 c4 14             	add    $0x14,%esp
  8003f1:	0f be 80 03 26 80 00 	movsbl 0x802603(%eax),%eax
  8003f8:	50                   	push   %eax
  8003f9:	ff d7                	call   *%edi
}
  8003fb:	83 c4 10             	add    $0x10,%esp
  8003fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800401:	5b                   	pop    %ebx
  800402:	5e                   	pop    %esi
  800403:	5f                   	pop    %edi
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    

00800406 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800406:	83 fa 01             	cmp    $0x1,%edx
  800409:	7f 13                	jg     80041e <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80040b:	85 d2                	test   %edx,%edx
  80040d:	74 1c                	je     80042b <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80040f:	8b 10                	mov    (%eax),%edx
  800411:	8d 4a 04             	lea    0x4(%edx),%ecx
  800414:	89 08                	mov    %ecx,(%eax)
  800416:	8b 02                	mov    (%edx),%eax
  800418:	ba 00 00 00 00       	mov    $0x0,%edx
  80041d:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80041e:	8b 10                	mov    (%eax),%edx
  800420:	8d 4a 08             	lea    0x8(%edx),%ecx
  800423:	89 08                	mov    %ecx,(%eax)
  800425:	8b 02                	mov    (%edx),%eax
  800427:	8b 52 04             	mov    0x4(%edx),%edx
  80042a:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80042b:	8b 10                	mov    (%eax),%edx
  80042d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800430:	89 08                	mov    %ecx,(%eax)
  800432:	8b 02                	mov    (%edx),%eax
  800434:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800439:	c3                   	ret    

0080043a <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80043a:	83 fa 01             	cmp    $0x1,%edx
  80043d:	7f 0f                	jg     80044e <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80043f:	85 d2                	test   %edx,%edx
  800441:	74 18                	je     80045b <getint+0x21>
		return va_arg(*ap, long);
  800443:	8b 10                	mov    (%eax),%edx
  800445:	8d 4a 04             	lea    0x4(%edx),%ecx
  800448:	89 08                	mov    %ecx,(%eax)
  80044a:	8b 02                	mov    (%edx),%eax
  80044c:	99                   	cltd   
  80044d:	c3                   	ret    
		return va_arg(*ap, long long);
  80044e:	8b 10                	mov    (%eax),%edx
  800450:	8d 4a 08             	lea    0x8(%edx),%ecx
  800453:	89 08                	mov    %ecx,(%eax)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	8b 52 04             	mov    0x4(%edx),%edx
  80045a:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80045b:	8b 10                	mov    (%eax),%edx
  80045d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800460:	89 08                	mov    %ecx,(%eax)
  800462:	8b 02                	mov    (%edx),%eax
  800464:	99                   	cltd   
}
  800465:	c3                   	ret    

00800466 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800466:	f3 0f 1e fb          	endbr32 
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800470:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800474:	8b 10                	mov    (%eax),%edx
  800476:	3b 50 04             	cmp    0x4(%eax),%edx
  800479:	73 0a                	jae    800485 <sprintputch+0x1f>
		*b->buf++ = ch;
  80047b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80047e:	89 08                	mov    %ecx,(%eax)
  800480:	8b 45 08             	mov    0x8(%ebp),%eax
  800483:	88 02                	mov    %al,(%edx)
}
  800485:	5d                   	pop    %ebp
  800486:	c3                   	ret    

00800487 <printfmt>:
{
  800487:	f3 0f 1e fb          	endbr32 
  80048b:	55                   	push   %ebp
  80048c:	89 e5                	mov    %esp,%ebp
  80048e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800491:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800494:	50                   	push   %eax
  800495:	ff 75 10             	pushl  0x10(%ebp)
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	ff 75 08             	pushl  0x8(%ebp)
  80049e:	e8 05 00 00 00       	call   8004a8 <vprintfmt>
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	c9                   	leave  
  8004a7:	c3                   	ret    

008004a8 <vprintfmt>:
{
  8004a8:	f3 0f 1e fb          	endbr32 
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	57                   	push   %edi
  8004b0:	56                   	push   %esi
  8004b1:	53                   	push   %ebx
  8004b2:	83 ec 2c             	sub    $0x2c,%esp
  8004b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004b8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004bb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004be:	e9 86 02 00 00       	jmp    800749 <vprintfmt+0x2a1>
		padc = ' ';
  8004c3:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8004c7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8004ce:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8004d5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004dc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8d 47 01             	lea    0x1(%edi),%eax
  8004e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004e7:	0f b6 17             	movzbl (%edi),%edx
  8004ea:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004ed:	3c 55                	cmp    $0x55,%al
  8004ef:	0f 87 df 02 00 00    	ja     8007d4 <vprintfmt+0x32c>
  8004f5:	0f b6 c0             	movzbl %al,%eax
  8004f8:	3e ff 24 85 40 27 80 	notrack jmp *0x802740(,%eax,4)
  8004ff:	00 
  800500:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800503:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800507:	eb d8                	jmp    8004e1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800510:	eb cf                	jmp    8004e1 <vprintfmt+0x39>
  800512:	0f b6 d2             	movzbl %dl,%edx
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800518:	b8 00 00 00 00       	mov    $0x0,%eax
  80051d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800520:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800523:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800527:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80052a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80052d:	83 f9 09             	cmp    $0x9,%ecx
  800530:	77 52                	ja     800584 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800532:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800535:	eb e9                	jmp    800520 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8d 50 04             	lea    0x4(%eax),%edx
  80053d:	89 55 14             	mov    %edx,0x14(%ebp)
  800540:	8b 00                	mov    (%eax),%eax
  800542:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800545:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800548:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054c:	79 93                	jns    8004e1 <vprintfmt+0x39>
				width = precision, precision = -1;
  80054e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800551:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800554:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80055b:	eb 84                	jmp    8004e1 <vprintfmt+0x39>
  80055d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800560:	85 c0                	test   %eax,%eax
  800562:	ba 00 00 00 00       	mov    $0x0,%edx
  800567:	0f 49 d0             	cmovns %eax,%edx
  80056a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80056d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800570:	e9 6c ff ff ff       	jmp    8004e1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800578:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80057f:	e9 5d ff ff ff       	jmp    8004e1 <vprintfmt+0x39>
  800584:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800587:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80058a:	eb bc                	jmp    800548 <vprintfmt+0xa0>
			lflag++;
  80058c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800592:	e9 4a ff ff ff       	jmp    8004e1 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 50 04             	lea    0x4(%eax),%edx
  80059d:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	56                   	push   %esi
  8005a4:	ff 30                	pushl  (%eax)
  8005a6:	ff d3                	call   *%ebx
			break;
  8005a8:	83 c4 10             	add    $0x10,%esp
  8005ab:	e9 96 01 00 00       	jmp    800746 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 04             	lea    0x4(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	99                   	cltd   
  8005bc:	31 d0                	xor    %edx,%eax
  8005be:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005c0:	83 f8 0f             	cmp    $0xf,%eax
  8005c3:	7f 20                	jg     8005e5 <vprintfmt+0x13d>
  8005c5:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  8005cc:	85 d2                	test   %edx,%edx
  8005ce:	74 15                	je     8005e5 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8005d0:	52                   	push   %edx
  8005d1:	68 d1 2b 80 00       	push   $0x802bd1
  8005d6:	56                   	push   %esi
  8005d7:	53                   	push   %ebx
  8005d8:	e8 aa fe ff ff       	call   800487 <printfmt>
  8005dd:	83 c4 10             	add    $0x10,%esp
  8005e0:	e9 61 01 00 00       	jmp    800746 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8005e5:	50                   	push   %eax
  8005e6:	68 1b 26 80 00       	push   $0x80261b
  8005eb:	56                   	push   %esi
  8005ec:	53                   	push   %ebx
  8005ed:	e8 95 fe ff ff       	call   800487 <printfmt>
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	e9 4c 01 00 00       	jmp    800746 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 04             	lea    0x4(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)
  800603:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800605:	85 c9                	test   %ecx,%ecx
  800607:	b8 14 26 80 00       	mov    $0x802614,%eax
  80060c:	0f 45 c1             	cmovne %ecx,%eax
  80060f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800612:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800616:	7e 06                	jle    80061e <vprintfmt+0x176>
  800618:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80061c:	75 0d                	jne    80062b <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  80061e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800621:	89 c7                	mov    %eax,%edi
  800623:	03 45 e0             	add    -0x20(%ebp),%eax
  800626:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800629:	eb 57                	jmp    800682 <vprintfmt+0x1da>
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	ff 75 d8             	pushl  -0x28(%ebp)
  800631:	ff 75 cc             	pushl  -0x34(%ebp)
  800634:	e8 4f 02 00 00       	call   800888 <strnlen>
  800639:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80063c:	29 c2                	sub    %eax,%edx
  80063e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800641:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800644:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800648:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80064b:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80064d:	85 db                	test   %ebx,%ebx
  80064f:	7e 10                	jle    800661 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	56                   	push   %esi
  800655:	57                   	push   %edi
  800656:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800659:	83 eb 01             	sub    $0x1,%ebx
  80065c:	83 c4 10             	add    $0x10,%esp
  80065f:	eb ec                	jmp    80064d <vprintfmt+0x1a5>
  800661:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800664:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800667:	85 d2                	test   %edx,%edx
  800669:	b8 00 00 00 00       	mov    $0x0,%eax
  80066e:	0f 49 c2             	cmovns %edx,%eax
  800671:	29 c2                	sub    %eax,%edx
  800673:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800676:	eb a6                	jmp    80061e <vprintfmt+0x176>
					putch(ch, putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	56                   	push   %esi
  80067c:	52                   	push   %edx
  80067d:	ff d3                	call   *%ebx
  80067f:	83 c4 10             	add    $0x10,%esp
  800682:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800685:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800687:	83 c7 01             	add    $0x1,%edi
  80068a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068e:	0f be d0             	movsbl %al,%edx
  800691:	85 d2                	test   %edx,%edx
  800693:	74 42                	je     8006d7 <vprintfmt+0x22f>
  800695:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800699:	78 06                	js     8006a1 <vprintfmt+0x1f9>
  80069b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80069f:	78 1e                	js     8006bf <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8006a1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006a5:	74 d1                	je     800678 <vprintfmt+0x1d0>
  8006a7:	0f be c0             	movsbl %al,%eax
  8006aa:	83 e8 20             	sub    $0x20,%eax
  8006ad:	83 f8 5e             	cmp    $0x5e,%eax
  8006b0:	76 c6                	jbe    800678 <vprintfmt+0x1d0>
					putch('?', putdat);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	56                   	push   %esi
  8006b6:	6a 3f                	push   $0x3f
  8006b8:	ff d3                	call   *%ebx
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	eb c3                	jmp    800682 <vprintfmt+0x1da>
  8006bf:	89 cf                	mov    %ecx,%edi
  8006c1:	eb 0e                	jmp    8006d1 <vprintfmt+0x229>
				putch(' ', putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	56                   	push   %esi
  8006c7:	6a 20                	push   $0x20
  8006c9:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8006cb:	83 ef 01             	sub    $0x1,%edi
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	85 ff                	test   %edi,%edi
  8006d3:	7f ee                	jg     8006c3 <vprintfmt+0x21b>
  8006d5:	eb 6f                	jmp    800746 <vprintfmt+0x29e>
  8006d7:	89 cf                	mov    %ecx,%edi
  8006d9:	eb f6                	jmp    8006d1 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8006db:	89 ca                	mov    %ecx,%edx
  8006dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e0:	e8 55 fd ff ff       	call   80043a <getint>
  8006e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8006eb:	85 d2                	test   %edx,%edx
  8006ed:	78 0b                	js     8006fa <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8006ef:	89 d1                	mov    %edx,%ecx
  8006f1:	89 c2                	mov    %eax,%edx
			base = 10;
  8006f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f8:	eb 32                	jmp    80072c <vprintfmt+0x284>
				putch('-', putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	56                   	push   %esi
  8006fe:	6a 2d                	push   $0x2d
  800700:	ff d3                	call   *%ebx
				num = -(long long) num;
  800702:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800705:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800708:	f7 da                	neg    %edx
  80070a:	83 d1 00             	adc    $0x0,%ecx
  80070d:	f7 d9                	neg    %ecx
  80070f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800712:	b8 0a 00 00 00       	mov    $0xa,%eax
  800717:	eb 13                	jmp    80072c <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800719:	89 ca                	mov    %ecx,%edx
  80071b:	8d 45 14             	lea    0x14(%ebp),%eax
  80071e:	e8 e3 fc ff ff       	call   800406 <getuint>
  800723:	89 d1                	mov    %edx,%ecx
  800725:	89 c2                	mov    %eax,%edx
			base = 10;
  800727:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  80072c:	83 ec 0c             	sub    $0xc,%esp
  80072f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800733:	57                   	push   %edi
  800734:	ff 75 e0             	pushl  -0x20(%ebp)
  800737:	50                   	push   %eax
  800738:	51                   	push   %ecx
  800739:	52                   	push   %edx
  80073a:	89 f2                	mov    %esi,%edx
  80073c:	89 d8                	mov    %ebx,%eax
  80073e:	e8 1a fc ff ff       	call   80035d <printnum>
			break;
  800743:	83 c4 20             	add    $0x20,%esp
{
  800746:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800749:	83 c7 01             	add    $0x1,%edi
  80074c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800750:	83 f8 25             	cmp    $0x25,%eax
  800753:	0f 84 6a fd ff ff    	je     8004c3 <vprintfmt+0x1b>
			if (ch == '\0')
  800759:	85 c0                	test   %eax,%eax
  80075b:	0f 84 93 00 00 00    	je     8007f4 <vprintfmt+0x34c>
			putch(ch, putdat);
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	56                   	push   %esi
  800765:	50                   	push   %eax
  800766:	ff d3                	call   *%ebx
  800768:	83 c4 10             	add    $0x10,%esp
  80076b:	eb dc                	jmp    800749 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  80076d:	89 ca                	mov    %ecx,%edx
  80076f:	8d 45 14             	lea    0x14(%ebp),%eax
  800772:	e8 8f fc ff ff       	call   800406 <getuint>
  800777:	89 d1                	mov    %edx,%ecx
  800779:	89 c2                	mov    %eax,%edx
			base = 8;
  80077b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800780:	eb aa                	jmp    80072c <vprintfmt+0x284>
			putch('0', putdat);
  800782:	83 ec 08             	sub    $0x8,%esp
  800785:	56                   	push   %esi
  800786:	6a 30                	push   $0x30
  800788:	ff d3                	call   *%ebx
			putch('x', putdat);
  80078a:	83 c4 08             	add    $0x8,%esp
  80078d:	56                   	push   %esi
  80078e:	6a 78                	push   $0x78
  800790:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8d 50 04             	lea    0x4(%eax),%edx
  800798:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80079b:	8b 10                	mov    (%eax),%edx
  80079d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007a2:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8007a5:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007aa:	eb 80                	jmp    80072c <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8007ac:	89 ca                	mov    %ecx,%edx
  8007ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b1:	e8 50 fc ff ff       	call   800406 <getuint>
  8007b6:	89 d1                	mov    %edx,%ecx
  8007b8:	89 c2                	mov    %eax,%edx
			base = 16;
  8007ba:	b8 10 00 00 00       	mov    $0x10,%eax
  8007bf:	e9 68 ff ff ff       	jmp    80072c <vprintfmt+0x284>
			putch(ch, putdat);
  8007c4:	83 ec 08             	sub    $0x8,%esp
  8007c7:	56                   	push   %esi
  8007c8:	6a 25                	push   $0x25
  8007ca:	ff d3                	call   *%ebx
			break;
  8007cc:	83 c4 10             	add    $0x10,%esp
  8007cf:	e9 72 ff ff ff       	jmp    800746 <vprintfmt+0x29e>
			putch('%', putdat);
  8007d4:	83 ec 08             	sub    $0x8,%esp
  8007d7:	56                   	push   %esi
  8007d8:	6a 25                	push   $0x25
  8007da:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007dc:	83 c4 10             	add    $0x10,%esp
  8007df:	89 f8                	mov    %edi,%eax
  8007e1:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007e5:	74 05                	je     8007ec <vprintfmt+0x344>
  8007e7:	83 e8 01             	sub    $0x1,%eax
  8007ea:	eb f5                	jmp    8007e1 <vprintfmt+0x339>
  8007ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007ef:	e9 52 ff ff ff       	jmp    800746 <vprintfmt+0x29e>
}
  8007f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f7:	5b                   	pop    %ebx
  8007f8:	5e                   	pop    %esi
  8007f9:	5f                   	pop    %edi
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007fc:	f3 0f 1e fb          	endbr32 
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	83 ec 18             	sub    $0x18,%esp
  800806:	8b 45 08             	mov    0x8(%ebp),%eax
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800813:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800816:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081d:	85 c0                	test   %eax,%eax
  80081f:	74 26                	je     800847 <vsnprintf+0x4b>
  800821:	85 d2                	test   %edx,%edx
  800823:	7e 22                	jle    800847 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800825:	ff 75 14             	pushl  0x14(%ebp)
  800828:	ff 75 10             	pushl  0x10(%ebp)
  80082b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082e:	50                   	push   %eax
  80082f:	68 66 04 80 00       	push   $0x800466
  800834:	e8 6f fc ff ff       	call   8004a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800839:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800842:	83 c4 10             	add    $0x10,%esp
}
  800845:	c9                   	leave  
  800846:	c3                   	ret    
		return -E_INVAL;
  800847:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084c:	eb f7                	jmp    800845 <vsnprintf+0x49>

0080084e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80084e:	f3 0f 1e fb          	endbr32 
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800858:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80085b:	50                   	push   %eax
  80085c:	ff 75 10             	pushl  0x10(%ebp)
  80085f:	ff 75 0c             	pushl  0xc(%ebp)
  800862:	ff 75 08             	pushl  0x8(%ebp)
  800865:	e8 92 ff ff ff       	call   8007fc <vsnprintf>
	va_end(ap);

	return rc;
}
  80086a:	c9                   	leave  
  80086b:	c3                   	ret    

0080086c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80086c:	f3 0f 1e fb          	endbr32 
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
  80087b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087f:	74 05                	je     800886 <strlen+0x1a>
		n++;
  800881:	83 c0 01             	add    $0x1,%eax
  800884:	eb f5                	jmp    80087b <strlen+0xf>
	return n;
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800888:	f3 0f 1e fb          	endbr32 
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
  80089a:	39 d0                	cmp    %edx,%eax
  80089c:	74 0d                	je     8008ab <strnlen+0x23>
  80089e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a2:	74 05                	je     8008a9 <strnlen+0x21>
		n++;
  8008a4:	83 c0 01             	add    $0x1,%eax
  8008a7:	eb f1                	jmp    80089a <strnlen+0x12>
  8008a9:	89 c2                	mov    %eax,%edx
	return n;
}
  8008ab:	89 d0                	mov    %edx,%eax
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008af:	f3 0f 1e fb          	endbr32 
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	53                   	push   %ebx
  8008b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c2:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008c6:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008c9:	83 c0 01             	add    $0x1,%eax
  8008cc:	84 d2                	test   %dl,%dl
  8008ce:	75 f2                	jne    8008c2 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8008d0:	89 c8                	mov    %ecx,%eax
  8008d2:	5b                   	pop    %ebx
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d5:	f3 0f 1e fb          	endbr32 
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	53                   	push   %ebx
  8008dd:	83 ec 10             	sub    $0x10,%esp
  8008e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e3:	53                   	push   %ebx
  8008e4:	e8 83 ff ff ff       	call   80086c <strlen>
  8008e9:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008ec:	ff 75 0c             	pushl  0xc(%ebp)
  8008ef:	01 d8                	add    %ebx,%eax
  8008f1:	50                   	push   %eax
  8008f2:	e8 b8 ff ff ff       	call   8008af <strcpy>
	return dst;
}
  8008f7:	89 d8                	mov    %ebx,%eax
  8008f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fc:	c9                   	leave  
  8008fd:	c3                   	ret    

008008fe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008fe:	f3 0f 1e fb          	endbr32 
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	56                   	push   %esi
  800906:	53                   	push   %ebx
  800907:	8b 75 08             	mov    0x8(%ebp),%esi
  80090a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090d:	89 f3                	mov    %esi,%ebx
  80090f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800912:	89 f0                	mov    %esi,%eax
  800914:	39 d8                	cmp    %ebx,%eax
  800916:	74 11                	je     800929 <strncpy+0x2b>
		*dst++ = *src;
  800918:	83 c0 01             	add    $0x1,%eax
  80091b:	0f b6 0a             	movzbl (%edx),%ecx
  80091e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800921:	80 f9 01             	cmp    $0x1,%cl
  800924:	83 da ff             	sbb    $0xffffffff,%edx
  800927:	eb eb                	jmp    800914 <strncpy+0x16>
	}
	return ret;
}
  800929:	89 f0                	mov    %esi,%eax
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092f:	f3 0f 1e fb          	endbr32 
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	56                   	push   %esi
  800937:	53                   	push   %ebx
  800938:	8b 75 08             	mov    0x8(%ebp),%esi
  80093b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093e:	8b 55 10             	mov    0x10(%ebp),%edx
  800941:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800943:	85 d2                	test   %edx,%edx
  800945:	74 21                	je     800968 <strlcpy+0x39>
  800947:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80094b:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80094d:	39 c2                	cmp    %eax,%edx
  80094f:	74 14                	je     800965 <strlcpy+0x36>
  800951:	0f b6 19             	movzbl (%ecx),%ebx
  800954:	84 db                	test   %bl,%bl
  800956:	74 0b                	je     800963 <strlcpy+0x34>
			*dst++ = *src++;
  800958:	83 c1 01             	add    $0x1,%ecx
  80095b:	83 c2 01             	add    $0x1,%edx
  80095e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800961:	eb ea                	jmp    80094d <strlcpy+0x1e>
  800963:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800965:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800968:	29 f0                	sub    %esi,%eax
}
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096e:	f3 0f 1e fb          	endbr32 
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800978:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80097b:	0f b6 01             	movzbl (%ecx),%eax
  80097e:	84 c0                	test   %al,%al
  800980:	74 0c                	je     80098e <strcmp+0x20>
  800982:	3a 02                	cmp    (%edx),%al
  800984:	75 08                	jne    80098e <strcmp+0x20>
		p++, q++;
  800986:	83 c1 01             	add    $0x1,%ecx
  800989:	83 c2 01             	add    $0x1,%edx
  80098c:	eb ed                	jmp    80097b <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80098e:	0f b6 c0             	movzbl %al,%eax
  800991:	0f b6 12             	movzbl (%edx),%edx
  800994:	29 d0                	sub    %edx,%eax
}
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800998:	f3 0f 1e fb          	endbr32 
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	53                   	push   %ebx
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a6:	89 c3                	mov    %eax,%ebx
  8009a8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009ab:	eb 06                	jmp    8009b3 <strncmp+0x1b>
		n--, p++, q++;
  8009ad:	83 c0 01             	add    $0x1,%eax
  8009b0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009b3:	39 d8                	cmp    %ebx,%eax
  8009b5:	74 16                	je     8009cd <strncmp+0x35>
  8009b7:	0f b6 08             	movzbl (%eax),%ecx
  8009ba:	84 c9                	test   %cl,%cl
  8009bc:	74 04                	je     8009c2 <strncmp+0x2a>
  8009be:	3a 0a                	cmp    (%edx),%cl
  8009c0:	74 eb                	je     8009ad <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c2:	0f b6 00             	movzbl (%eax),%eax
  8009c5:	0f b6 12             	movzbl (%edx),%edx
  8009c8:	29 d0                	sub    %edx,%eax
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    
		return 0;
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d2:	eb f6                	jmp    8009ca <strncmp+0x32>

008009d4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d4:	f3 0f 1e fb          	endbr32 
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e2:	0f b6 10             	movzbl (%eax),%edx
  8009e5:	84 d2                	test   %dl,%dl
  8009e7:	74 09                	je     8009f2 <strchr+0x1e>
		if (*s == c)
  8009e9:	38 ca                	cmp    %cl,%dl
  8009eb:	74 0a                	je     8009f7 <strchr+0x23>
	for (; *s; s++)
  8009ed:	83 c0 01             	add    $0x1,%eax
  8009f0:	eb f0                	jmp    8009e2 <strchr+0xe>
			return (char *) s;
	return 0;
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009f9:	f3 0f 1e fb          	endbr32 
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a07:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a0a:	38 ca                	cmp    %cl,%dl
  800a0c:	74 09                	je     800a17 <strfind+0x1e>
  800a0e:	84 d2                	test   %dl,%dl
  800a10:	74 05                	je     800a17 <strfind+0x1e>
	for (; *s; s++)
  800a12:	83 c0 01             	add    $0x1,%eax
  800a15:	eb f0                	jmp    800a07 <strfind+0xe>
			break;
	return (char *) s;
}
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a19:	f3 0f 1e fb          	endbr32 
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	57                   	push   %edi
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 55 08             	mov    0x8(%ebp),%edx
  800a26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a29:	85 c9                	test   %ecx,%ecx
  800a2b:	74 33                	je     800a60 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a2d:	89 d0                	mov    %edx,%eax
  800a2f:	09 c8                	or     %ecx,%eax
  800a31:	a8 03                	test   $0x3,%al
  800a33:	75 23                	jne    800a58 <memset+0x3f>
		c &= 0xFF;
  800a35:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a39:	89 d8                	mov    %ebx,%eax
  800a3b:	c1 e0 08             	shl    $0x8,%eax
  800a3e:	89 df                	mov    %ebx,%edi
  800a40:	c1 e7 18             	shl    $0x18,%edi
  800a43:	89 de                	mov    %ebx,%esi
  800a45:	c1 e6 10             	shl    $0x10,%esi
  800a48:	09 f7                	or     %esi,%edi
  800a4a:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800a4c:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a4f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a51:	89 d7                	mov    %edx,%edi
  800a53:	fc                   	cld    
  800a54:	f3 ab                	rep stos %eax,%es:(%edi)
  800a56:	eb 08                	jmp    800a60 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a58:	89 d7                	mov    %edx,%edi
  800a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5d:	fc                   	cld    
  800a5e:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800a60:	89 d0                	mov    %edx,%eax
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a67:	f3 0f 1e fb          	endbr32 
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	57                   	push   %edi
  800a6f:	56                   	push   %esi
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a79:	39 c6                	cmp    %eax,%esi
  800a7b:	73 32                	jae    800aaf <memmove+0x48>
  800a7d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a80:	39 c2                	cmp    %eax,%edx
  800a82:	76 2b                	jbe    800aaf <memmove+0x48>
		s += n;
		d += n;
  800a84:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a87:	89 fe                	mov    %edi,%esi
  800a89:	09 ce                	or     %ecx,%esi
  800a8b:	09 d6                	or     %edx,%esi
  800a8d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a93:	75 0e                	jne    800aa3 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a95:	83 ef 04             	sub    $0x4,%edi
  800a98:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a9b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a9e:	fd                   	std    
  800a9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa1:	eb 09                	jmp    800aac <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa3:	83 ef 01             	sub    $0x1,%edi
  800aa6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aa9:	fd                   	std    
  800aaa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aac:	fc                   	cld    
  800aad:	eb 1a                	jmp    800ac9 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aaf:	89 c2                	mov    %eax,%edx
  800ab1:	09 ca                	or     %ecx,%edx
  800ab3:	09 f2                	or     %esi,%edx
  800ab5:	f6 c2 03             	test   $0x3,%dl
  800ab8:	75 0a                	jne    800ac4 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aba:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800abd:	89 c7                	mov    %eax,%edi
  800abf:	fc                   	cld    
  800ac0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac2:	eb 05                	jmp    800ac9 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800ac4:	89 c7                	mov    %eax,%edi
  800ac6:	fc                   	cld    
  800ac7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800acd:	f3 0f 1e fb          	endbr32 
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad7:	ff 75 10             	pushl  0x10(%ebp)
  800ada:	ff 75 0c             	pushl  0xc(%ebp)
  800add:	ff 75 08             	pushl  0x8(%ebp)
  800ae0:	e8 82 ff ff ff       	call   800a67 <memmove>
}
  800ae5:	c9                   	leave  
  800ae6:	c3                   	ret    

00800ae7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae7:	f3 0f 1e fb          	endbr32 
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
  800af0:	8b 45 08             	mov    0x8(%ebp),%eax
  800af3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af6:	89 c6                	mov    %eax,%esi
  800af8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afb:	39 f0                	cmp    %esi,%eax
  800afd:	74 1c                	je     800b1b <memcmp+0x34>
		if (*s1 != *s2)
  800aff:	0f b6 08             	movzbl (%eax),%ecx
  800b02:	0f b6 1a             	movzbl (%edx),%ebx
  800b05:	38 d9                	cmp    %bl,%cl
  800b07:	75 08                	jne    800b11 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b09:	83 c0 01             	add    $0x1,%eax
  800b0c:	83 c2 01             	add    $0x1,%edx
  800b0f:	eb ea                	jmp    800afb <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800b11:	0f b6 c1             	movzbl %cl,%eax
  800b14:	0f b6 db             	movzbl %bl,%ebx
  800b17:	29 d8                	sub    %ebx,%eax
  800b19:	eb 05                	jmp    800b20 <memcmp+0x39>
	}

	return 0;
  800b1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b24:	f3 0f 1e fb          	endbr32 
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b31:	89 c2                	mov    %eax,%edx
  800b33:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b36:	39 d0                	cmp    %edx,%eax
  800b38:	73 09                	jae    800b43 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b3a:	38 08                	cmp    %cl,(%eax)
  800b3c:	74 05                	je     800b43 <memfind+0x1f>
	for (; s < ends; s++)
  800b3e:	83 c0 01             	add    $0x1,%eax
  800b41:	eb f3                	jmp    800b36 <memfind+0x12>
			break;
	return (void *) s;
}
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b45:	f3 0f 1e fb          	endbr32 
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
  800b4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b55:	eb 03                	jmp    800b5a <strtol+0x15>
		s++;
  800b57:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b5a:	0f b6 01             	movzbl (%ecx),%eax
  800b5d:	3c 20                	cmp    $0x20,%al
  800b5f:	74 f6                	je     800b57 <strtol+0x12>
  800b61:	3c 09                	cmp    $0x9,%al
  800b63:	74 f2                	je     800b57 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b65:	3c 2b                	cmp    $0x2b,%al
  800b67:	74 2a                	je     800b93 <strtol+0x4e>
	int neg = 0;
  800b69:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b6e:	3c 2d                	cmp    $0x2d,%al
  800b70:	74 2b                	je     800b9d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b72:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b78:	75 0f                	jne    800b89 <strtol+0x44>
  800b7a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b7d:	74 28                	je     800ba7 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b7f:	85 db                	test   %ebx,%ebx
  800b81:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b86:	0f 44 d8             	cmove  %eax,%ebx
  800b89:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b91:	eb 46                	jmp    800bd9 <strtol+0x94>
		s++;
  800b93:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b96:	bf 00 00 00 00       	mov    $0x0,%edi
  800b9b:	eb d5                	jmp    800b72 <strtol+0x2d>
		s++, neg = 1;
  800b9d:	83 c1 01             	add    $0x1,%ecx
  800ba0:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba5:	eb cb                	jmp    800b72 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bab:	74 0e                	je     800bbb <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bad:	85 db                	test   %ebx,%ebx
  800baf:	75 d8                	jne    800b89 <strtol+0x44>
		s++, base = 8;
  800bb1:	83 c1 01             	add    $0x1,%ecx
  800bb4:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bb9:	eb ce                	jmp    800b89 <strtol+0x44>
		s += 2, base = 16;
  800bbb:	83 c1 02             	add    $0x2,%ecx
  800bbe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc3:	eb c4                	jmp    800b89 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bc5:	0f be d2             	movsbl %dl,%edx
  800bc8:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bcb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bce:	7d 3a                	jge    800c0a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bd9:	0f b6 11             	movzbl (%ecx),%edx
  800bdc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bdf:	89 f3                	mov    %esi,%ebx
  800be1:	80 fb 09             	cmp    $0x9,%bl
  800be4:	76 df                	jbe    800bc5 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800be6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800be9:	89 f3                	mov    %esi,%ebx
  800beb:	80 fb 19             	cmp    $0x19,%bl
  800bee:	77 08                	ja     800bf8 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bf0:	0f be d2             	movsbl %dl,%edx
  800bf3:	83 ea 57             	sub    $0x57,%edx
  800bf6:	eb d3                	jmp    800bcb <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800bf8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bfb:	89 f3                	mov    %esi,%ebx
  800bfd:	80 fb 19             	cmp    $0x19,%bl
  800c00:	77 08                	ja     800c0a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c02:	0f be d2             	movsbl %dl,%edx
  800c05:	83 ea 37             	sub    $0x37,%edx
  800c08:	eb c1                	jmp    800bcb <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c0a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c0e:	74 05                	je     800c15 <strtol+0xd0>
		*endptr = (char *) s;
  800c10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c13:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c15:	89 c2                	mov    %eax,%edx
  800c17:	f7 da                	neg    %edx
  800c19:	85 ff                	test   %edi,%edi
  800c1b:	0f 45 c2             	cmovne %edx,%eax
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 1c             	sub    $0x1c,%esp
  800c2c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c2f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c32:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c3a:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c3d:	8b 75 14             	mov    0x14(%ebp),%esi
  800c40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c42:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c46:	74 04                	je     800c4c <syscall+0x29>
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	7f 08                	jg     800c54 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800c4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c54:	83 ec 0c             	sub    $0xc,%esp
  800c57:	50                   	push   %eax
  800c58:	ff 75 e0             	pushl  -0x20(%ebp)
  800c5b:	68 ff 28 80 00       	push   $0x8028ff
  800c60:	6a 23                	push   $0x23
  800c62:	68 1c 29 80 00       	push   $0x80291c
  800c67:	e8 f2 f5 ff ff       	call   80025e <_panic>

00800c6c <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800c6c:	f3 0f 1e fb          	endbr32 
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800c76:	6a 00                	push   $0x0
  800c78:	6a 00                	push   $0x0
  800c7a:	6a 00                	push   $0x0
  800c7c:	ff 75 0c             	pushl  0xc(%ebp)
  800c7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c82:	ba 00 00 00 00       	mov    $0x0,%edx
  800c87:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8c:	e8 92 ff ff ff       	call   800c23 <syscall>
}
  800c91:	83 c4 10             	add    $0x10,%esp
  800c94:	c9                   	leave  
  800c95:	c3                   	ret    

00800c96 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c96:	f3 0f 1e fb          	endbr32 
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ca0:	6a 00                	push   $0x0
  800ca2:	6a 00                	push   $0x0
  800ca4:	6a 00                	push   $0x0
  800ca6:	6a 00                	push   $0x0
  800ca8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cad:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb7:	e8 67 ff ff ff       	call   800c23 <syscall>
}
  800cbc:	c9                   	leave  
  800cbd:	c3                   	ret    

00800cbe <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cbe:	f3 0f 1e fb          	endbr32 
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800cc8:	6a 00                	push   $0x0
  800cca:	6a 00                	push   $0x0
  800ccc:	6a 00                	push   $0x0
  800cce:	6a 00                	push   $0x0
  800cd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd3:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd8:	b8 03 00 00 00       	mov    $0x3,%eax
  800cdd:	e8 41 ff ff ff       	call   800c23 <syscall>
}
  800ce2:	c9                   	leave  
  800ce3:	c3                   	ret    

00800ce4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ce4:	f3 0f 1e fb          	endbr32 
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800cee:	6a 00                	push   $0x0
  800cf0:	6a 00                	push   $0x0
  800cf2:	6a 00                	push   $0x0
  800cf4:	6a 00                	push   $0x0
  800cf6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800d00:	b8 02 00 00 00       	mov    $0x2,%eax
  800d05:	e8 19 ff ff ff       	call   800c23 <syscall>
}
  800d0a:	c9                   	leave  
  800d0b:	c3                   	ret    

00800d0c <sys_yield>:

void
sys_yield(void)
{
  800d0c:	f3 0f 1e fb          	endbr32 
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800d16:	6a 00                	push   $0x0
  800d18:	6a 00                	push   $0x0
  800d1a:	6a 00                	push   $0x0
  800d1c:	6a 00                	push   $0x0
  800d1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d23:	ba 00 00 00 00       	mov    $0x0,%edx
  800d28:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d2d:	e8 f1 fe ff ff       	call   800c23 <syscall>
}
  800d32:	83 c4 10             	add    $0x10,%esp
  800d35:	c9                   	leave  
  800d36:	c3                   	ret    

00800d37 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d37:	f3 0f 1e fb          	endbr32 
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d41:	6a 00                	push   $0x0
  800d43:	6a 00                	push   $0x0
  800d45:	ff 75 10             	pushl  0x10(%ebp)
  800d48:	ff 75 0c             	pushl  0xc(%ebp)
  800d4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4e:	ba 01 00 00 00       	mov    $0x1,%edx
  800d53:	b8 04 00 00 00       	mov    $0x4,%eax
  800d58:	e8 c6 fe ff ff       	call   800c23 <syscall>
}
  800d5d:	c9                   	leave  
  800d5e:	c3                   	ret    

00800d5f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d5f:	f3 0f 1e fb          	endbr32 
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800d69:	ff 75 18             	pushl  0x18(%ebp)
  800d6c:	ff 75 14             	pushl  0x14(%ebp)
  800d6f:	ff 75 10             	pushl  0x10(%ebp)
  800d72:	ff 75 0c             	pushl  0xc(%ebp)
  800d75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d78:	ba 01 00 00 00       	mov    $0x1,%edx
  800d7d:	b8 05 00 00 00       	mov    $0x5,%eax
  800d82:	e8 9c fe ff ff       	call   800c23 <syscall>
}
  800d87:	c9                   	leave  
  800d88:	c3                   	ret    

00800d89 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d89:	f3 0f 1e fb          	endbr32 
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d93:	6a 00                	push   $0x0
  800d95:	6a 00                	push   $0x0
  800d97:	6a 00                	push   $0x0
  800d99:	ff 75 0c             	pushl  0xc(%ebp)
  800d9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9f:	ba 01 00 00 00       	mov    $0x1,%edx
  800da4:	b8 06 00 00 00       	mov    $0x6,%eax
  800da9:	e8 75 fe ff ff       	call   800c23 <syscall>
}
  800dae:	c9                   	leave  
  800daf:	c3                   	ret    

00800db0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800db0:	f3 0f 1e fb          	endbr32 
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800dba:	6a 00                	push   $0x0
  800dbc:	6a 00                	push   $0x0
  800dbe:	6a 00                	push   $0x0
  800dc0:	ff 75 0c             	pushl  0xc(%ebp)
  800dc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc6:	ba 01 00 00 00       	mov    $0x1,%edx
  800dcb:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd0:	e8 4e fe ff ff       	call   800c23 <syscall>
}
  800dd5:	c9                   	leave  
  800dd6:	c3                   	ret    

00800dd7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dd7:	f3 0f 1e fb          	endbr32 
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800de1:	6a 00                	push   $0x0
  800de3:	6a 00                	push   $0x0
  800de5:	6a 00                	push   $0x0
  800de7:	ff 75 0c             	pushl  0xc(%ebp)
  800dea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ded:	ba 01 00 00 00       	mov    $0x1,%edx
  800df2:	b8 09 00 00 00       	mov    $0x9,%eax
  800df7:	e8 27 fe ff ff       	call   800c23 <syscall>
}
  800dfc:	c9                   	leave  
  800dfd:	c3                   	ret    

00800dfe <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dfe:	f3 0f 1e fb          	endbr32 
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e08:	6a 00                	push   $0x0
  800e0a:	6a 00                	push   $0x0
  800e0c:	6a 00                	push   $0x0
  800e0e:	ff 75 0c             	pushl  0xc(%ebp)
  800e11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e14:	ba 01 00 00 00       	mov    $0x1,%edx
  800e19:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e1e:	e8 00 fe ff ff       	call   800c23 <syscall>
}
  800e23:	c9                   	leave  
  800e24:	c3                   	ret    

00800e25 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e25:	f3 0f 1e fb          	endbr32 
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e2f:	6a 00                	push   $0x0
  800e31:	ff 75 14             	pushl  0x14(%ebp)
  800e34:	ff 75 10             	pushl  0x10(%ebp)
  800e37:	ff 75 0c             	pushl  0xc(%ebp)
  800e3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e42:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e47:	e8 d7 fd ff ff       	call   800c23 <syscall>
}
  800e4c:	c9                   	leave  
  800e4d:	c3                   	ret    

00800e4e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4e:	f3 0f 1e fb          	endbr32 
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e58:	6a 00                	push   $0x0
  800e5a:	6a 00                	push   $0x0
  800e5c:	6a 00                	push   $0x0
  800e5e:	6a 00                	push   $0x0
  800e60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e63:	ba 01 00 00 00       	mov    $0x1,%edx
  800e68:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e6d:	e8 b1 fd ff ff       	call   800c23 <syscall>
}
  800e72:	c9                   	leave  
  800e73:	c3                   	ret    

00800e74 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	53                   	push   %ebx
  800e78:	83 ec 04             	sub    $0x4,%esp
	int r;

	// LAB 4: Your code here.
	void *addr = (void *) (pn * PGSIZE);
  800e7b:	89 d3                	mov    %edx,%ebx
  800e7d:	c1 e3 0c             	shl    $0xc,%ebx

	if (uvpt[pn] & PTE_SHARE) {
  800e80:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e87:	f6 c5 04             	test   $0x4,%ch
  800e8a:	75 56                	jne    800ee2 <duppage+0x6e>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
		return 0;
	}

	if ((uvpt[pn] & (PTE_W | PTE_COW)) != 0) {
  800e8c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e93:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800e99:	74 72                	je     800f0d <duppage+0x99>
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW) <
  800e9b:	83 ec 0c             	sub    $0xc,%esp
  800e9e:	68 05 08 00 00       	push   $0x805
  800ea3:	53                   	push   %ebx
  800ea4:	50                   	push   %eax
  800ea5:	53                   	push   %ebx
  800ea6:	6a 00                	push   $0x0
  800ea8:	e8 b2 fe ff ff       	call   800d5f <sys_page_map>
  800ead:	83 c4 20             	add    $0x20,%esp
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	78 45                	js     800ef9 <duppage+0x85>
		    0) {
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
		}
		if (sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW) < 0) {
  800eb4:	83 ec 0c             	sub    $0xc,%esp
  800eb7:	68 05 08 00 00       	push   $0x805
  800ebc:	53                   	push   %ebx
  800ebd:	6a 00                	push   $0x0
  800ebf:	53                   	push   %ebx
  800ec0:	6a 00                	push   $0x0
  800ec2:	e8 98 fe ff ff       	call   800d5f <sys_page_map>
  800ec7:	83 c4 20             	add    $0x20,%esp
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	79 55                	jns    800f23 <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP FATHER");
  800ece:	83 ec 04             	sub    $0x4,%esp
  800ed1:	68 4c 29 80 00       	push   $0x80294c
  800ed6:	6a 54                	push   $0x54
  800ed8:	68 df 29 80 00       	push   $0x8029df
  800edd:	e8 7c f3 ff ff       	call   80025e <_panic>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800ee2:	83 ec 0c             	sub    $0xc,%esp
  800ee5:	68 07 0e 00 00       	push   $0xe07
  800eea:	53                   	push   %ebx
  800eeb:	50                   	push   %eax
  800eec:	53                   	push   %ebx
  800eed:	6a 00                	push   $0x0
  800eef:	e8 6b fe ff ff       	call   800d5f <sys_page_map>
		return 0;
  800ef4:	83 c4 20             	add    $0x20,%esp
  800ef7:	eb 2a                	jmp    800f23 <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
  800ef9:	83 ec 04             	sub    $0x4,%esp
  800efc:	68 2c 29 80 00       	push   $0x80292c
  800f01:	6a 51                	push   $0x51
  800f03:	68 df 29 80 00       	push   $0x8029df
  800f08:	e8 51 f3 ff ff       	call   80025e <_panic>
		}
	} else {
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U) < 0) {
  800f0d:	83 ec 0c             	sub    $0xc,%esp
  800f10:	6a 05                	push   $0x5
  800f12:	53                   	push   %ebx
  800f13:	50                   	push   %eax
  800f14:	53                   	push   %ebx
  800f15:	6a 00                	push   $0x0
  800f17:	e8 43 fe ff ff       	call   800d5f <sys_page_map>
  800f1c:	83 c4 20             	add    $0x20,%esp
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	78 0a                	js     800f2d <duppage+0xb9>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
		}
	}

	return 0;
}
  800f23:	b8 00 00 00 00       	mov    $0x0,%eax
  800f28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f2b:	c9                   	leave  
  800f2c:	c3                   	ret    
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
  800f2d:	83 ec 04             	sub    $0x4,%esp
  800f30:	68 ea 29 80 00       	push   $0x8029ea
  800f35:	6a 58                	push   $0x58
  800f37:	68 df 29 80 00       	push   $0x8029df
  800f3c:	e8 1d f3 ff ff       	call   80025e <_panic>

00800f41 <dup_or_share>:

static void
dup_or_share(envid_t dstenv, void *va, int perm)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
  800f46:	89 c6                	mov    %eax,%esi
  800f48:	89 d3                	mov    %edx,%ebx
	int r;
	if (perm & PTE_W) {
  800f4a:	f6 c1 02             	test   $0x2,%cl
  800f4d:	0f 84 8c 00 00 00    	je     800fdf <dup_or_share+0x9e>
		// dup
		if ((r = sys_page_alloc(dstenv, va, PTE_P | PTE_U | PTE_W)) < 0)
  800f53:	83 ec 04             	sub    $0x4,%esp
  800f56:	6a 07                	push   $0x7
  800f58:	52                   	push   %edx
  800f59:	50                   	push   %eax
  800f5a:	e8 d8 fd ff ff       	call   800d37 <sys_page_alloc>
  800f5f:	83 c4 10             	add    $0x10,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	78 55                	js     800fbb <dup_or_share+0x7a>
			panic("sys_page_alloc: %e", r);
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  800f66:	83 ec 0c             	sub    $0xc,%esp
  800f69:	6a 07                	push   $0x7
  800f6b:	68 00 00 40 00       	push   $0x400000
  800f70:	6a 00                	push   $0x0
  800f72:	53                   	push   %ebx
  800f73:	56                   	push   %esi
  800f74:	e8 e6 fd ff ff       	call   800d5f <sys_page_map>
  800f79:	83 c4 20             	add    $0x20,%esp
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	78 4d                	js     800fcd <dup_or_share+0x8c>
		    0)
			panic("sys_page_map: %e", r);
		memmove(UTEMP, va, PGSIZE);
  800f80:	83 ec 04             	sub    $0x4,%esp
  800f83:	68 00 10 00 00       	push   $0x1000
  800f88:	53                   	push   %ebx
  800f89:	68 00 00 40 00       	push   $0x400000
  800f8e:	e8 d4 fa ff ff       	call   800a67 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800f93:	83 c4 08             	add    $0x8,%esp
  800f96:	68 00 00 40 00       	push   $0x400000
  800f9b:	6a 00                	push   $0x0
  800f9d:	e8 e7 fd ff ff       	call   800d89 <sys_page_unmap>
  800fa2:	83 c4 10             	add    $0x10,%esp
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	79 52                	jns    800ffb <dup_or_share+0xba>
			panic("sys_page_unmap: %e", r);
  800fa9:	50                   	push   %eax
  800faa:	68 2a 2a 80 00       	push   $0x802a2a
  800faf:	6a 6c                	push   $0x6c
  800fb1:	68 df 29 80 00       	push   $0x8029df
  800fb6:	e8 a3 f2 ff ff       	call   80025e <_panic>
			panic("sys_page_alloc: %e", r);
  800fbb:	50                   	push   %eax
  800fbc:	68 06 2a 80 00       	push   $0x802a06
  800fc1:	6a 66                	push   $0x66
  800fc3:	68 df 29 80 00       	push   $0x8029df
  800fc8:	e8 91 f2 ff ff       	call   80025e <_panic>
			panic("sys_page_map: %e", r);
  800fcd:	50                   	push   %eax
  800fce:	68 19 2a 80 00       	push   $0x802a19
  800fd3:	6a 69                	push   $0x69
  800fd5:	68 df 29 80 00       	push   $0x8029df
  800fda:	e8 7f f2 ff ff       	call   80025e <_panic>

	} else {
		// share
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | perm)) <
  800fdf:	83 ec 0c             	sub    $0xc,%esp
  800fe2:	83 c9 05             	or     $0x5,%ecx
  800fe5:	51                   	push   %ecx
  800fe6:	68 00 00 40 00       	push   $0x400000
  800feb:	6a 00                	push   $0x0
  800fed:	52                   	push   %edx
  800fee:	50                   	push   %eax
  800fef:	e8 6b fd ff ff       	call   800d5f <sys_page_map>
  800ff4:	83 c4 20             	add    $0x20,%esp
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	78 07                	js     801002 <dup_or_share+0xc1>
		    0)
			panic("sys_page_map: %e", r);
	}
}
  800ffb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5e                   	pop    %esi
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    
			panic("sys_page_map: %e", r);
  801002:	50                   	push   %eax
  801003:	68 19 2a 80 00       	push   $0x802a19
  801008:	6a 72                	push   $0x72
  80100a:	68 df 29 80 00       	push   $0x8029df
  80100f:	e8 4a f2 ff ff       	call   80025e <_panic>

00801014 <pgfault>:
{
  801014:	f3 0f 1e fb          	endbr32 
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	53                   	push   %ebx
  80101c:	83 ec 04             	sub    $0x4,%esp
  80101f:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  801022:	8b 02                	mov    (%edx),%eax
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  801024:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  801028:	0f 84 95 00 00 00    	je     8010c3 <pgfault+0xaf>
  80102e:	89 c2                	mov    %eax,%edx
  801030:	c1 ea 16             	shr    $0x16,%edx
  801033:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80103a:	f6 c2 01             	test   $0x1,%dl
  80103d:	0f 84 80 00 00 00    	je     8010c3 <pgfault+0xaf>
	    (~uvpt[PGNUM(addr)] & (PTE_COW | PTE_P)) != 0) {
  801043:	89 c2                	mov    %eax,%edx
  801045:	c1 ea 0c             	shr    $0xc,%edx
  801048:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80104f:	f7 d2                	not    %edx
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  801051:	f7 c2 01 08 00 00    	test   $0x801,%edx
  801057:	75 6a                	jne    8010c3 <pgfault+0xaf>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  801059:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80105e:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U) < 0) {
  801060:	83 ec 04             	sub    $0x4,%esp
  801063:	6a 07                	push   $0x7
  801065:	68 00 f0 7f 00       	push   $0x7ff000
  80106a:	6a 00                	push   $0x0
  80106c:	e8 c6 fc ff ff       	call   800d37 <sys_page_alloc>
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	85 c0                	test   %eax,%eax
  801076:	78 5f                	js     8010d7 <pgfault+0xc3>
	memcpy((void *) PFTEMP, addr, PGSIZE);
  801078:	83 ec 04             	sub    $0x4,%esp
  80107b:	68 00 10 00 00       	push   $0x1000
  801080:	53                   	push   %ebx
  801081:	68 00 f0 7f 00       	push   $0x7ff000
  801086:	e8 42 fa ff ff       	call   800acd <memcpy>
	if (sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U) < 0) {
  80108b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801092:	53                   	push   %ebx
  801093:	6a 00                	push   $0x0
  801095:	68 00 f0 7f 00       	push   $0x7ff000
  80109a:	6a 00                	push   $0x0
  80109c:	e8 be fc ff ff       	call   800d5f <sys_page_map>
  8010a1:	83 c4 20             	add    $0x20,%esp
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	78 43                	js     8010eb <pgfault+0xd7>
	if (sys_page_unmap(0, (void *) PFTEMP) < 0) {
  8010a8:	83 ec 08             	sub    $0x8,%esp
  8010ab:	68 00 f0 7f 00       	push   $0x7ff000
  8010b0:	6a 00                	push   $0x0
  8010b2:	e8 d2 fc ff ff       	call   800d89 <sys_page_unmap>
  8010b7:	83 c4 10             	add    $0x10,%esp
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	78 41                	js     8010ff <pgfault+0xeb>
}
  8010be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c1:	c9                   	leave  
  8010c2:	c3                   	ret    
		panic("ERROR PGFAULT");
  8010c3:	83 ec 04             	sub    $0x4,%esp
  8010c6:	68 3d 2a 80 00       	push   $0x802a3d
  8010cb:	6a 1e                	push   $0x1e
  8010cd:	68 df 29 80 00       	push   $0x8029df
  8010d2:	e8 87 f1 ff ff       	call   80025e <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_ALLOC");
  8010d7:	83 ec 04             	sub    $0x4,%esp
  8010da:	68 4b 2a 80 00       	push   $0x802a4b
  8010df:	6a 2b                	push   $0x2b
  8010e1:	68 df 29 80 00       	push   $0x8029df
  8010e6:	e8 73 f1 ff ff       	call   80025e <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_MAP");
  8010eb:	83 ec 04             	sub    $0x4,%esp
  8010ee:	68 69 2a 80 00       	push   $0x802a69
  8010f3:	6a 2f                	push   $0x2f
  8010f5:	68 df 29 80 00       	push   $0x8029df
  8010fa:	e8 5f f1 ff ff       	call   80025e <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_UNMAP");
  8010ff:	83 ec 04             	sub    $0x4,%esp
  801102:	68 85 2a 80 00       	push   $0x802a85
  801107:	6a 32                	push   $0x32
  801109:	68 df 29 80 00       	push   $0x8029df
  80110e:	e8 4b f1 ff ff       	call   80025e <_panic>

00801113 <fork_v0>:

envid_t
fork_v0(void)
{
  801113:	f3 0f 1e fb          	endbr32 
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	57                   	push   %edi
  80111b:	56                   	push   %esi
  80111c:	53                   	push   %ebx
  80111d:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801120:	b8 07 00 00 00       	mov    $0x7,%eax
  801125:	cd 30                	int    $0x30
	envid_t env_id = sys_exofork();
	if (env_id < 0) {
  801127:	85 c0                	test   %eax,%eax
  801129:	78 24                	js     80114f <fork_v0+0x3c>
  80112b:	89 c6                	mov    %eax,%esi
  80112d:	89 c7                	mov    %eax,%edi
		thisenv = envs + ENVX(sys_getenvid());
		return env_id;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  80112f:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (env_id == 0) {  // Son
  801134:	75 51                	jne    801187 <fork_v0+0x74>
		thisenv = envs + ENVX(sys_getenvid());
  801136:	e8 a9 fb ff ff       	call   800ce4 <sys_getenvid>
  80113b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801140:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801143:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801148:	a3 04 40 80 00       	mov    %eax,0x804004
		return env_id;
  80114d:	eb 78                	jmp    8011c7 <fork_v0+0xb4>
		panic("ERROR ON FORK_V0");
  80114f:	83 ec 04             	sub    $0x4,%esp
  801152:	68 a3 2a 80 00       	push   $0x802aa3
  801157:	6a 7b                	push   $0x7b
  801159:	68 df 29 80 00       	push   $0x8029df
  80115e:	e8 fb f0 ff ff       	call   80025e <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
				dup_or_share(env_id,
  801163:	b9 07 00 00 00       	mov    $0x7,%ecx
  801168:	89 da                	mov    %ebx,%edx
  80116a:	89 f8                	mov    %edi,%eax
  80116c:	e8 d0 fd ff ff       	call   800f41 <dup_or_share>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801171:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801177:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  80117d:	77 36                	ja     8011b5 <fork_v0+0xa2>
		if (addr != UXSTACKTOP - PGSIZE) {
  80117f:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801185:	74 ea                	je     801171 <fork_v0+0x5e>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801187:	89 d8                	mov    %ebx,%eax
  801189:	c1 e8 16             	shr    $0x16,%eax
  80118c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801193:	a8 01                	test   $0x1,%al
  801195:	74 da                	je     801171 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  801197:	89 d8                	mov    %ebx,%eax
  801199:	c1 e8 0c             	shr    $0xc,%eax
  80119c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  8011a3:	f6 c2 01             	test   $0x1,%dl
  8011a6:	74 c9                	je     801171 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
  8011a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  8011af:	a8 04                	test   $0x4,%al
  8011b1:	74 be                	je     801171 <fork_v0+0x5e>
  8011b3:	eb ae                	jmp    801163 <fork_v0+0x50>
				             PTE_P | PTE_U | PTE_W);
			}
		}
	}

	if (sys_env_set_status(env_id, ENV_RUNNABLE) < 0) {
  8011b5:	83 ec 08             	sub    $0x8,%esp
  8011b8:	6a 02                	push   $0x2
  8011ba:	56                   	push   %esi
  8011bb:	e8 f0 fb ff ff       	call   800db0 <sys_env_set_status>
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	78 0a                	js     8011d1 <fork_v0+0xbe>
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
	}

	return env_id;
}
  8011c7:	89 f0                	mov    %esi,%eax
  8011c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cc:	5b                   	pop    %ebx
  8011cd:	5e                   	pop    %esi
  8011ce:	5f                   	pop    %edi
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
  8011d1:	83 ec 04             	sub    $0x4,%esp
  8011d4:	68 70 29 80 00       	push   $0x802970
  8011d9:	68 92 00 00 00       	push   $0x92
  8011de:	68 df 29 80 00       	push   $0x8029df
  8011e3:	e8 76 f0 ff ff       	call   80025e <_panic>

008011e8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011e8:	f3 0f 1e fb          	endbr32 
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	57                   	push   %edi
  8011f0:	56                   	push   %esi
  8011f1:	53                   	push   %ebx
  8011f2:	83 ec 18             	sub    $0x18,%esp
	// return fork_v0(); // Uncomment this line if you want to run fork_v0.
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8011f5:	68 14 10 80 00       	push   $0x801014
  8011fa:	e8 e8 0f 00 00       	call   8021e7 <set_pgfault_handler>
  8011ff:	b8 07 00 00 00       	mov    $0x7,%eax
  801204:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0) {
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 27                	js     801234 <fork+0x4c>
  80120d:	89 c7                	mov    %eax,%edi
  80120f:	89 c6                	mov    %eax,%esi
		thisenv = envs + ENVX(sys_getenvid());
		return envid;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801211:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else if (envid == 0) {  // Son
  801216:	75 55                	jne    80126d <fork+0x85>
		thisenv = envs + ENVX(sys_getenvid());
  801218:	e8 c7 fa ff ff       	call   800ce4 <sys_getenvid>
  80121d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801222:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801225:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80122a:	a3 04 40 80 00       	mov    %eax,0x804004
		return envid;
  80122f:	e9 9b 00 00 00       	jmp    8012cf <fork+0xe7>
		panic("ERROR IN FORK: SYS_EXOFORK");
  801234:	83 ec 04             	sub    $0x4,%esp
  801237:	68 b4 2a 80 00       	push   $0x802ab4
  80123c:	68 b1 00 00 00       	push   $0xb1
  801241:	68 df 29 80 00       	push   $0x8029df
  801246:	e8 13 f0 ff ff       	call   80025e <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
				duppage(envid, addr / PGSIZE);
  80124b:	89 da                	mov    %ebx,%edx
  80124d:	c1 ea 0c             	shr    $0xc,%edx
  801250:	89 f0                	mov    %esi,%eax
  801252:	e8 1d fc ff ff       	call   800e74 <duppage>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801257:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80125d:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801263:	77 2c                	ja     801291 <fork+0xa9>
		if (addr != UXSTACKTOP - PGSIZE) {
  801265:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80126b:	74 ea                	je     801257 <fork+0x6f>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80126d:	89 d8                	mov    %ebx,%eax
  80126f:	c1 e8 16             	shr    $0x16,%eax
  801272:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801279:	a8 01                	test   $0x1,%al
  80127b:	74 da                	je     801257 <fork+0x6f>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
  80127d:	89 d8                	mov    %ebx,%eax
  80127f:	c1 e8 0c             	shr    $0xc,%eax
  801282:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801289:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80128b:	a8 05                	test   $0x5,%al
  80128d:	75 c8                	jne    801257 <fork+0x6f>
  80128f:	eb ba                	jmp    80124b <fork+0x63>
			}
		}
	}

	if (sys_page_alloc(envid,
  801291:	83 ec 04             	sub    $0x4,%esp
  801294:	6a 07                	push   $0x7
  801296:	68 00 f0 bf ee       	push   $0xeebff000
  80129b:	57                   	push   %edi
  80129c:	e8 96 fa ff ff       	call   800d37 <sys_page_alloc>
  8012a1:	83 c4 10             	add    $0x10,%esp
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	78 31                	js     8012d9 <fork+0xf1>
	                   PTE_P | PTE_U | PTE_W) < 0) {
		panic("ERROR FORK: SYS_PAGE_ALLOC");
	}

	extern void _pgfault_upcall(void);
	if (sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0) {
  8012a8:	83 ec 08             	sub    $0x8,%esp
  8012ab:	68 5a 22 80 00       	push   $0x80225a
  8012b0:	57                   	push   %edi
  8012b1:	e8 48 fb ff ff       	call   800dfe <sys_env_set_pgfault_upcall>
  8012b6:	83 c4 10             	add    $0x10,%esp
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	78 33                	js     8012f0 <fork+0x108>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
	}

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0) {
  8012bd:	83 ec 08             	sub    $0x8,%esp
  8012c0:	6a 02                	push   $0x2
  8012c2:	57                   	push   %edi
  8012c3:	e8 e8 fa ff ff       	call   800db0 <sys_env_set_status>
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	78 38                	js     801307 <fork+0x11f>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
	}

	return envid;
}
  8012cf:	89 f8                	mov    %edi,%eax
  8012d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d4:	5b                   	pop    %ebx
  8012d5:	5e                   	pop    %esi
  8012d6:	5f                   	pop    %edi
  8012d7:	5d                   	pop    %ebp
  8012d8:	c3                   	ret    
		panic("ERROR FORK: SYS_PAGE_ALLOC");
  8012d9:	83 ec 04             	sub    $0x4,%esp
  8012dc:	68 cf 2a 80 00       	push   $0x802acf
  8012e1:	68 c4 00 00 00       	push   $0xc4
  8012e6:	68 df 29 80 00       	push   $0x8029df
  8012eb:	e8 6e ef ff ff       	call   80025e <_panic>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
  8012f0:	83 ec 04             	sub    $0x4,%esp
  8012f3:	68 98 29 80 00       	push   $0x802998
  8012f8:	68 c9 00 00 00       	push   $0xc9
  8012fd:	68 df 29 80 00       	push   $0x8029df
  801302:	e8 57 ef ff ff       	call   80025e <_panic>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
  801307:	83 ec 04             	sub    $0x4,%esp
  80130a:	68 c0 29 80 00       	push   $0x8029c0
  80130f:	68 cd 00 00 00       	push   $0xcd
  801314:	68 df 29 80 00       	push   $0x8029df
  801319:	e8 40 ef ff ff       	call   80025e <_panic>

0080131e <sfork>:

// Challenge!
int
sfork(void)
{
  80131e:	f3 0f 1e fb          	endbr32 
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801328:	68 ea 2a 80 00       	push   $0x802aea
  80132d:	68 d7 00 00 00       	push   $0xd7
  801332:	68 df 29 80 00       	push   $0x8029df
  801337:	e8 22 ef ff ff       	call   80025e <_panic>

0080133c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80133c:	f3 0f 1e fb          	endbr32 
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	56                   	push   %esi
  801344:	53                   	push   %ebx
  801345:	8b 75 08             	mov    0x8(%ebp),%esi
  801348:	8b 45 0c             	mov    0xc(%ebp),%eax
  80134b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  80134e:	85 c0                	test   %eax,%eax
  801350:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801355:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801358:	83 ec 0c             	sub    $0xc,%esp
  80135b:	50                   	push   %eax
  80135c:	e8 ed fa ff ff       	call   800e4e <sys_ipc_recv>
	if (f < 0) {
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	85 c0                	test   %eax,%eax
  801366:	78 2b                	js     801393 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801368:	85 f6                	test   %esi,%esi
  80136a:	74 0a                	je     801376 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  80136c:	a1 04 40 80 00       	mov    0x804004,%eax
  801371:	8b 40 74             	mov    0x74(%eax),%eax
  801374:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801376:	85 db                	test   %ebx,%ebx
  801378:	74 0a                	je     801384 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  80137a:	a1 04 40 80 00       	mov    0x804004,%eax
  80137f:	8b 40 78             	mov    0x78(%eax),%eax
  801382:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  801384:	a1 04 40 80 00       	mov    0x804004,%eax
  801389:	8b 40 70             	mov    0x70(%eax),%eax
}
  80138c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80138f:	5b                   	pop    %ebx
  801390:	5e                   	pop    %esi
  801391:	5d                   	pop    %ebp
  801392:	c3                   	ret    
		if (from_env_store != NULL) {
  801393:	85 f6                	test   %esi,%esi
  801395:	74 06                	je     80139d <ipc_recv+0x61>
			*from_env_store = 0;
  801397:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  80139d:	85 db                	test   %ebx,%ebx
  80139f:	74 eb                	je     80138c <ipc_recv+0x50>
			*perm_store = 0;
  8013a1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013a7:	eb e3                	jmp    80138c <ipc_recv+0x50>

008013a9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013a9:	f3 0f 1e fb          	endbr32 
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	57                   	push   %edi
  8013b1:	56                   	push   %esi
  8013b2:	53                   	push   %ebx
  8013b3:	83 ec 0c             	sub    $0xc,%esp
  8013b6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  8013bf:	85 db                	test   %ebx,%ebx
  8013c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8013c6:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8013c9:	ff 75 14             	pushl  0x14(%ebp)
  8013cc:	53                   	push   %ebx
  8013cd:	56                   	push   %esi
  8013ce:	57                   	push   %edi
  8013cf:	e8 51 fa ff ff       	call   800e25 <sys_ipc_try_send>
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	79 19                	jns    8013f4 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  8013db:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013de:	74 e9                	je     8013c9 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  8013e0:	83 ec 04             	sub    $0x4,%esp
  8013e3:	68 00 2b 80 00       	push   $0x802b00
  8013e8:	6a 48                	push   $0x48
  8013ea:	68 22 2b 80 00       	push   $0x802b22
  8013ef:	e8 6a ee ff ff       	call   80025e <_panic>
		}
	}
}
  8013f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f7:	5b                   	pop    %ebx
  8013f8:	5e                   	pop    %esi
  8013f9:	5f                   	pop    %edi
  8013fa:	5d                   	pop    %ebp
  8013fb:	c3                   	ret    

008013fc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013fc:	f3 0f 1e fb          	endbr32 
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801406:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80140b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80140e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801414:	8b 52 50             	mov    0x50(%edx),%edx
  801417:	39 ca                	cmp    %ecx,%edx
  801419:	74 11                	je     80142c <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80141b:	83 c0 01             	add    $0x1,%eax
  80141e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801423:	75 e6                	jne    80140b <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801425:	b8 00 00 00 00       	mov    $0x0,%eax
  80142a:	eb 0b                	jmp    801437 <ipc_find_env+0x3b>
			return envs[i].env_id;
  80142c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80142f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801434:	8b 40 48             	mov    0x48(%eax),%eax
}
  801437:	5d                   	pop    %ebp
  801438:	c3                   	ret    

00801439 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801439:	f3 0f 1e fb          	endbr32 
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801440:	8b 45 08             	mov    0x8(%ebp),%eax
  801443:	05 00 00 00 30       	add    $0x30000000,%eax
  801448:	c1 e8 0c             	shr    $0xc,%eax
}
  80144b:	5d                   	pop    %ebp
  80144c:	c3                   	ret    

0080144d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80144d:	f3 0f 1e fb          	endbr32 
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  801457:	ff 75 08             	pushl  0x8(%ebp)
  80145a:	e8 da ff ff ff       	call   801439 <fd2num>
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	c1 e0 0c             	shl    $0xc,%eax
  801465:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80146a:	c9                   	leave  
  80146b:	c3                   	ret    

0080146c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80146c:	f3 0f 1e fb          	endbr32 
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801478:	89 c2                	mov    %eax,%edx
  80147a:	c1 ea 16             	shr    $0x16,%edx
  80147d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801484:	f6 c2 01             	test   $0x1,%dl
  801487:	74 2d                	je     8014b6 <fd_alloc+0x4a>
  801489:	89 c2                	mov    %eax,%edx
  80148b:	c1 ea 0c             	shr    $0xc,%edx
  80148e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801495:	f6 c2 01             	test   $0x1,%dl
  801498:	74 1c                	je     8014b6 <fd_alloc+0x4a>
  80149a:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80149f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014a4:	75 d2                	jne    801478 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8014af:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8014b4:	eb 0a                	jmp    8014c0 <fd_alloc+0x54>
			*fd_store = fd;
  8014b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014b9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c0:	5d                   	pop    %ebp
  8014c1:	c3                   	ret    

008014c2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014c2:	f3 0f 1e fb          	endbr32 
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014cc:	83 f8 1f             	cmp    $0x1f,%eax
  8014cf:	77 30                	ja     801501 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014d1:	c1 e0 0c             	shl    $0xc,%eax
  8014d4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014d9:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8014df:	f6 c2 01             	test   $0x1,%dl
  8014e2:	74 24                	je     801508 <fd_lookup+0x46>
  8014e4:	89 c2                	mov    %eax,%edx
  8014e6:	c1 ea 0c             	shr    $0xc,%edx
  8014e9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014f0:	f6 c2 01             	test   $0x1,%dl
  8014f3:	74 1a                	je     80150f <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f8:	89 02                	mov    %eax,(%edx)
	return 0;
  8014fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ff:	5d                   	pop    %ebp
  801500:	c3                   	ret    
		return -E_INVAL;
  801501:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801506:	eb f7                	jmp    8014ff <fd_lookup+0x3d>
		return -E_INVAL;
  801508:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80150d:	eb f0                	jmp    8014ff <fd_lookup+0x3d>
  80150f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801514:	eb e9                	jmp    8014ff <fd_lookup+0x3d>

00801516 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801516:	f3 0f 1e fb          	endbr32 
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	83 ec 08             	sub    $0x8,%esp
  801520:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801523:	ba a8 2b 80 00       	mov    $0x802ba8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801528:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80152d:	39 08                	cmp    %ecx,(%eax)
  80152f:	74 33                	je     801564 <dev_lookup+0x4e>
  801531:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801534:	8b 02                	mov    (%edx),%eax
  801536:	85 c0                	test   %eax,%eax
  801538:	75 f3                	jne    80152d <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80153a:	a1 04 40 80 00       	mov    0x804004,%eax
  80153f:	8b 40 48             	mov    0x48(%eax),%eax
  801542:	83 ec 04             	sub    $0x4,%esp
  801545:	51                   	push   %ecx
  801546:	50                   	push   %eax
  801547:	68 2c 2b 80 00       	push   $0x802b2c
  80154c:	e8 f4 ed ff ff       	call   800345 <cprintf>
	*dev = 0;
  801551:	8b 45 0c             	mov    0xc(%ebp),%eax
  801554:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801562:	c9                   	leave  
  801563:	c3                   	ret    
			*dev = devtab[i];
  801564:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801567:	89 01                	mov    %eax,(%ecx)
			return 0;
  801569:	b8 00 00 00 00       	mov    $0x0,%eax
  80156e:	eb f2                	jmp    801562 <dev_lookup+0x4c>

00801570 <fd_close>:
{
  801570:	f3 0f 1e fb          	endbr32 
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	57                   	push   %edi
  801578:	56                   	push   %esi
  801579:	53                   	push   %ebx
  80157a:	83 ec 28             	sub    $0x28,%esp
  80157d:	8b 75 08             	mov    0x8(%ebp),%esi
  801580:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801583:	56                   	push   %esi
  801584:	e8 b0 fe ff ff       	call   801439 <fd2num>
  801589:	83 c4 08             	add    $0x8,%esp
  80158c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80158f:	52                   	push   %edx
  801590:	50                   	push   %eax
  801591:	e8 2c ff ff ff       	call   8014c2 <fd_lookup>
  801596:	89 c3                	mov    %eax,%ebx
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 05                	js     8015a4 <fd_close+0x34>
	    || fd != fd2)
  80159f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8015a2:	74 16                	je     8015ba <fd_close+0x4a>
		return (must_exist ? r : 0);
  8015a4:	89 f8                	mov    %edi,%eax
  8015a6:	84 c0                	test   %al,%al
  8015a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ad:	0f 44 d8             	cmove  %eax,%ebx
}
  8015b0:	89 d8                	mov    %ebx,%eax
  8015b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b5:	5b                   	pop    %ebx
  8015b6:	5e                   	pop    %esi
  8015b7:	5f                   	pop    %edi
  8015b8:	5d                   	pop    %ebp
  8015b9:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015ba:	83 ec 08             	sub    $0x8,%esp
  8015bd:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8015c0:	50                   	push   %eax
  8015c1:	ff 36                	pushl  (%esi)
  8015c3:	e8 4e ff ff ff       	call   801516 <dev_lookup>
  8015c8:	89 c3                	mov    %eax,%ebx
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	78 1a                	js     8015eb <fd_close+0x7b>
		if (dev->dev_close)
  8015d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015d4:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8015d7:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	74 0b                	je     8015eb <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	56                   	push   %esi
  8015e4:	ff d0                	call   *%eax
  8015e6:	89 c3                	mov    %eax,%ebx
  8015e8:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8015eb:	83 ec 08             	sub    $0x8,%esp
  8015ee:	56                   	push   %esi
  8015ef:	6a 00                	push   $0x0
  8015f1:	e8 93 f7 ff ff       	call   800d89 <sys_page_unmap>
	return r;
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	eb b5                	jmp    8015b0 <fd_close+0x40>

008015fb <close>:

int
close(int fdnum)
{
  8015fb:	f3 0f 1e fb          	endbr32 
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801605:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801608:	50                   	push   %eax
  801609:	ff 75 08             	pushl  0x8(%ebp)
  80160c:	e8 b1 fe ff ff       	call   8014c2 <fd_lookup>
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	85 c0                	test   %eax,%eax
  801616:	79 02                	jns    80161a <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801618:	c9                   	leave  
  801619:	c3                   	ret    
		return fd_close(fd, 1);
  80161a:	83 ec 08             	sub    $0x8,%esp
  80161d:	6a 01                	push   $0x1
  80161f:	ff 75 f4             	pushl  -0xc(%ebp)
  801622:	e8 49 ff ff ff       	call   801570 <fd_close>
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	eb ec                	jmp    801618 <close+0x1d>

0080162c <close_all>:

void
close_all(void)
{
  80162c:	f3 0f 1e fb          	endbr32 
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	53                   	push   %ebx
  801634:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801637:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80163c:	83 ec 0c             	sub    $0xc,%esp
  80163f:	53                   	push   %ebx
  801640:	e8 b6 ff ff ff       	call   8015fb <close>
	for (i = 0; i < MAXFD; i++)
  801645:	83 c3 01             	add    $0x1,%ebx
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	83 fb 20             	cmp    $0x20,%ebx
  80164e:	75 ec                	jne    80163c <close_all+0x10>
}
  801650:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801653:	c9                   	leave  
  801654:	c3                   	ret    

00801655 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801655:	f3 0f 1e fb          	endbr32 
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	57                   	push   %edi
  80165d:	56                   	push   %esi
  80165e:	53                   	push   %ebx
  80165f:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801662:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801665:	50                   	push   %eax
  801666:	ff 75 08             	pushl  0x8(%ebp)
  801669:	e8 54 fe ff ff       	call   8014c2 <fd_lookup>
  80166e:	89 c3                	mov    %eax,%ebx
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	85 c0                	test   %eax,%eax
  801675:	0f 88 81 00 00 00    	js     8016fc <dup+0xa7>
		return r;
	close(newfdnum);
  80167b:	83 ec 0c             	sub    $0xc,%esp
  80167e:	ff 75 0c             	pushl  0xc(%ebp)
  801681:	e8 75 ff ff ff       	call   8015fb <close>

	newfd = INDEX2FD(newfdnum);
  801686:	8b 75 0c             	mov    0xc(%ebp),%esi
  801689:	c1 e6 0c             	shl    $0xc,%esi
  80168c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801692:	83 c4 04             	add    $0x4,%esp
  801695:	ff 75 e4             	pushl  -0x1c(%ebp)
  801698:	e8 b0 fd ff ff       	call   80144d <fd2data>
  80169d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80169f:	89 34 24             	mov    %esi,(%esp)
  8016a2:	e8 a6 fd ff ff       	call   80144d <fd2data>
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016ac:	89 d8                	mov    %ebx,%eax
  8016ae:	c1 e8 16             	shr    $0x16,%eax
  8016b1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016b8:	a8 01                	test   $0x1,%al
  8016ba:	74 11                	je     8016cd <dup+0x78>
  8016bc:	89 d8                	mov    %ebx,%eax
  8016be:	c1 e8 0c             	shr    $0xc,%eax
  8016c1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016c8:	f6 c2 01             	test   $0x1,%dl
  8016cb:	75 39                	jne    801706 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016d0:	89 d0                	mov    %edx,%eax
  8016d2:	c1 e8 0c             	shr    $0xc,%eax
  8016d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016dc:	83 ec 0c             	sub    $0xc,%esp
  8016df:	25 07 0e 00 00       	and    $0xe07,%eax
  8016e4:	50                   	push   %eax
  8016e5:	56                   	push   %esi
  8016e6:	6a 00                	push   $0x0
  8016e8:	52                   	push   %edx
  8016e9:	6a 00                	push   $0x0
  8016eb:	e8 6f f6 ff ff       	call   800d5f <sys_page_map>
  8016f0:	89 c3                	mov    %eax,%ebx
  8016f2:	83 c4 20             	add    $0x20,%esp
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	78 31                	js     80172a <dup+0xd5>
		goto err;

	return newfdnum;
  8016f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016fc:	89 d8                	mov    %ebx,%eax
  8016fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801701:	5b                   	pop    %ebx
  801702:	5e                   	pop    %esi
  801703:	5f                   	pop    %edi
  801704:	5d                   	pop    %ebp
  801705:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801706:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80170d:	83 ec 0c             	sub    $0xc,%esp
  801710:	25 07 0e 00 00       	and    $0xe07,%eax
  801715:	50                   	push   %eax
  801716:	57                   	push   %edi
  801717:	6a 00                	push   $0x0
  801719:	53                   	push   %ebx
  80171a:	6a 00                	push   $0x0
  80171c:	e8 3e f6 ff ff       	call   800d5f <sys_page_map>
  801721:	89 c3                	mov    %eax,%ebx
  801723:	83 c4 20             	add    $0x20,%esp
  801726:	85 c0                	test   %eax,%eax
  801728:	79 a3                	jns    8016cd <dup+0x78>
	sys_page_unmap(0, newfd);
  80172a:	83 ec 08             	sub    $0x8,%esp
  80172d:	56                   	push   %esi
  80172e:	6a 00                	push   $0x0
  801730:	e8 54 f6 ff ff       	call   800d89 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801735:	83 c4 08             	add    $0x8,%esp
  801738:	57                   	push   %edi
  801739:	6a 00                	push   $0x0
  80173b:	e8 49 f6 ff ff       	call   800d89 <sys_page_unmap>
	return r;
  801740:	83 c4 10             	add    $0x10,%esp
  801743:	eb b7                	jmp    8016fc <dup+0xa7>

00801745 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801745:	f3 0f 1e fb          	endbr32 
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	53                   	push   %ebx
  80174d:	83 ec 1c             	sub    $0x1c,%esp
  801750:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801753:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801756:	50                   	push   %eax
  801757:	53                   	push   %ebx
  801758:	e8 65 fd ff ff       	call   8014c2 <fd_lookup>
  80175d:	83 c4 10             	add    $0x10,%esp
  801760:	85 c0                	test   %eax,%eax
  801762:	78 3f                	js     8017a3 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801764:	83 ec 08             	sub    $0x8,%esp
  801767:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176a:	50                   	push   %eax
  80176b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176e:	ff 30                	pushl  (%eax)
  801770:	e8 a1 fd ff ff       	call   801516 <dev_lookup>
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	85 c0                	test   %eax,%eax
  80177a:	78 27                	js     8017a3 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80177c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80177f:	8b 42 08             	mov    0x8(%edx),%eax
  801782:	83 e0 03             	and    $0x3,%eax
  801785:	83 f8 01             	cmp    $0x1,%eax
  801788:	74 1e                	je     8017a8 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80178a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178d:	8b 40 08             	mov    0x8(%eax),%eax
  801790:	85 c0                	test   %eax,%eax
  801792:	74 35                	je     8017c9 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801794:	83 ec 04             	sub    $0x4,%esp
  801797:	ff 75 10             	pushl  0x10(%ebp)
  80179a:	ff 75 0c             	pushl  0xc(%ebp)
  80179d:	52                   	push   %edx
  80179e:	ff d0                	call   *%eax
  8017a0:	83 c4 10             	add    $0x10,%esp
}
  8017a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a6:	c9                   	leave  
  8017a7:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017a8:	a1 04 40 80 00       	mov    0x804004,%eax
  8017ad:	8b 40 48             	mov    0x48(%eax),%eax
  8017b0:	83 ec 04             	sub    $0x4,%esp
  8017b3:	53                   	push   %ebx
  8017b4:	50                   	push   %eax
  8017b5:	68 6d 2b 80 00       	push   $0x802b6d
  8017ba:	e8 86 eb ff ff       	call   800345 <cprintf>
		return -E_INVAL;
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017c7:	eb da                	jmp    8017a3 <read+0x5e>
		return -E_NOT_SUPP;
  8017c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017ce:	eb d3                	jmp    8017a3 <read+0x5e>

008017d0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017d0:	f3 0f 1e fb          	endbr32 
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	57                   	push   %edi
  8017d8:	56                   	push   %esi
  8017d9:	53                   	push   %ebx
  8017da:	83 ec 0c             	sub    $0xc,%esp
  8017dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017e8:	eb 02                	jmp    8017ec <readn+0x1c>
  8017ea:	01 c3                	add    %eax,%ebx
  8017ec:	39 f3                	cmp    %esi,%ebx
  8017ee:	73 21                	jae    801811 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017f0:	83 ec 04             	sub    $0x4,%esp
  8017f3:	89 f0                	mov    %esi,%eax
  8017f5:	29 d8                	sub    %ebx,%eax
  8017f7:	50                   	push   %eax
  8017f8:	89 d8                	mov    %ebx,%eax
  8017fa:	03 45 0c             	add    0xc(%ebp),%eax
  8017fd:	50                   	push   %eax
  8017fe:	57                   	push   %edi
  8017ff:	e8 41 ff ff ff       	call   801745 <read>
		if (m < 0)
  801804:	83 c4 10             	add    $0x10,%esp
  801807:	85 c0                	test   %eax,%eax
  801809:	78 04                	js     80180f <readn+0x3f>
			return m;
		if (m == 0)
  80180b:	75 dd                	jne    8017ea <readn+0x1a>
  80180d:	eb 02                	jmp    801811 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80180f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801811:	89 d8                	mov    %ebx,%eax
  801813:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801816:	5b                   	pop    %ebx
  801817:	5e                   	pop    %esi
  801818:	5f                   	pop    %edi
  801819:	5d                   	pop    %ebp
  80181a:	c3                   	ret    

0080181b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80181b:	f3 0f 1e fb          	endbr32 
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	53                   	push   %ebx
  801823:	83 ec 1c             	sub    $0x1c,%esp
  801826:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801829:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182c:	50                   	push   %eax
  80182d:	53                   	push   %ebx
  80182e:	e8 8f fc ff ff       	call   8014c2 <fd_lookup>
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	85 c0                	test   %eax,%eax
  801838:	78 3a                	js     801874 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183a:	83 ec 08             	sub    $0x8,%esp
  80183d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801840:	50                   	push   %eax
  801841:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801844:	ff 30                	pushl  (%eax)
  801846:	e8 cb fc ff ff       	call   801516 <dev_lookup>
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	85 c0                	test   %eax,%eax
  801850:	78 22                	js     801874 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801852:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801855:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801859:	74 1e                	je     801879 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80185b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185e:	8b 52 0c             	mov    0xc(%edx),%edx
  801861:	85 d2                	test   %edx,%edx
  801863:	74 35                	je     80189a <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801865:	83 ec 04             	sub    $0x4,%esp
  801868:	ff 75 10             	pushl  0x10(%ebp)
  80186b:	ff 75 0c             	pushl  0xc(%ebp)
  80186e:	50                   	push   %eax
  80186f:	ff d2                	call   *%edx
  801871:	83 c4 10             	add    $0x10,%esp
}
  801874:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801877:	c9                   	leave  
  801878:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801879:	a1 04 40 80 00       	mov    0x804004,%eax
  80187e:	8b 40 48             	mov    0x48(%eax),%eax
  801881:	83 ec 04             	sub    $0x4,%esp
  801884:	53                   	push   %ebx
  801885:	50                   	push   %eax
  801886:	68 89 2b 80 00       	push   $0x802b89
  80188b:	e8 b5 ea ff ff       	call   800345 <cprintf>
		return -E_INVAL;
  801890:	83 c4 10             	add    $0x10,%esp
  801893:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801898:	eb da                	jmp    801874 <write+0x59>
		return -E_NOT_SUPP;
  80189a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80189f:	eb d3                	jmp    801874 <write+0x59>

008018a1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018a1:	f3 0f 1e fb          	endbr32 
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ae:	50                   	push   %eax
  8018af:	ff 75 08             	pushl  0x8(%ebp)
  8018b2:	e8 0b fc ff ff       	call   8014c2 <fd_lookup>
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 0e                	js     8018cc <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8018be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018cc:	c9                   	leave  
  8018cd:	c3                   	ret    

008018ce <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018ce:	f3 0f 1e fb          	endbr32 
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	53                   	push   %ebx
  8018d6:	83 ec 1c             	sub    $0x1c,%esp
  8018d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018df:	50                   	push   %eax
  8018e0:	53                   	push   %ebx
  8018e1:	e8 dc fb ff ff       	call   8014c2 <fd_lookup>
  8018e6:	83 c4 10             	add    $0x10,%esp
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	78 37                	js     801924 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ed:	83 ec 08             	sub    $0x8,%esp
  8018f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f3:	50                   	push   %eax
  8018f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f7:	ff 30                	pushl  (%eax)
  8018f9:	e8 18 fc ff ff       	call   801516 <dev_lookup>
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	85 c0                	test   %eax,%eax
  801903:	78 1f                	js     801924 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801905:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801908:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80190c:	74 1b                	je     801929 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80190e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801911:	8b 52 18             	mov    0x18(%edx),%edx
  801914:	85 d2                	test   %edx,%edx
  801916:	74 32                	je     80194a <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801918:	83 ec 08             	sub    $0x8,%esp
  80191b:	ff 75 0c             	pushl  0xc(%ebp)
  80191e:	50                   	push   %eax
  80191f:	ff d2                	call   *%edx
  801921:	83 c4 10             	add    $0x10,%esp
}
  801924:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801927:	c9                   	leave  
  801928:	c3                   	ret    
			thisenv->env_id, fdnum);
  801929:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80192e:	8b 40 48             	mov    0x48(%eax),%eax
  801931:	83 ec 04             	sub    $0x4,%esp
  801934:	53                   	push   %ebx
  801935:	50                   	push   %eax
  801936:	68 4c 2b 80 00       	push   $0x802b4c
  80193b:	e8 05 ea ff ff       	call   800345 <cprintf>
		return -E_INVAL;
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801948:	eb da                	jmp    801924 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80194a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80194f:	eb d3                	jmp    801924 <ftruncate+0x56>

00801951 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801951:	f3 0f 1e fb          	endbr32 
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	53                   	push   %ebx
  801959:	83 ec 1c             	sub    $0x1c,%esp
  80195c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80195f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801962:	50                   	push   %eax
  801963:	ff 75 08             	pushl  0x8(%ebp)
  801966:	e8 57 fb ff ff       	call   8014c2 <fd_lookup>
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	85 c0                	test   %eax,%eax
  801970:	78 4b                	js     8019bd <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801972:	83 ec 08             	sub    $0x8,%esp
  801975:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801978:	50                   	push   %eax
  801979:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197c:	ff 30                	pushl  (%eax)
  80197e:	e8 93 fb ff ff       	call   801516 <dev_lookup>
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	85 c0                	test   %eax,%eax
  801988:	78 33                	js     8019bd <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80198a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801991:	74 2f                	je     8019c2 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801993:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801996:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80199d:	00 00 00 
	stat->st_isdir = 0;
  8019a0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019a7:	00 00 00 
	stat->st_dev = dev;
  8019aa:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019b0:	83 ec 08             	sub    $0x8,%esp
  8019b3:	53                   	push   %ebx
  8019b4:	ff 75 f0             	pushl  -0x10(%ebp)
  8019b7:	ff 50 14             	call   *0x14(%eax)
  8019ba:	83 c4 10             	add    $0x10,%esp
}
  8019bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c0:	c9                   	leave  
  8019c1:	c3                   	ret    
		return -E_NOT_SUPP;
  8019c2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019c7:	eb f4                	jmp    8019bd <fstat+0x6c>

008019c9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019c9:	f3 0f 1e fb          	endbr32 
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
  8019d0:	56                   	push   %esi
  8019d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019d2:	83 ec 08             	sub    $0x8,%esp
  8019d5:	6a 00                	push   $0x0
  8019d7:	ff 75 08             	pushl  0x8(%ebp)
  8019da:	e8 20 02 00 00       	call   801bff <open>
  8019df:	89 c3                	mov    %eax,%ebx
  8019e1:	83 c4 10             	add    $0x10,%esp
  8019e4:	85 c0                	test   %eax,%eax
  8019e6:	78 1b                	js     801a03 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8019e8:	83 ec 08             	sub    $0x8,%esp
  8019eb:	ff 75 0c             	pushl  0xc(%ebp)
  8019ee:	50                   	push   %eax
  8019ef:	e8 5d ff ff ff       	call   801951 <fstat>
  8019f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8019f6:	89 1c 24             	mov    %ebx,(%esp)
  8019f9:	e8 fd fb ff ff       	call   8015fb <close>
	return r;
  8019fe:	83 c4 10             	add    $0x10,%esp
  801a01:	89 f3                	mov    %esi,%ebx
}
  801a03:	89 d8                	mov    %ebx,%eax
  801a05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a08:	5b                   	pop    %ebx
  801a09:	5e                   	pop    %esi
  801a0a:	5d                   	pop    %ebp
  801a0b:	c3                   	ret    

00801a0c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	56                   	push   %esi
  801a10:	53                   	push   %ebx
  801a11:	89 c6                	mov    %eax,%esi
  801a13:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a15:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a1c:	74 27                	je     801a45 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a1e:	6a 07                	push   $0x7
  801a20:	68 00 50 80 00       	push   $0x805000
  801a25:	56                   	push   %esi
  801a26:	ff 35 00 40 80 00    	pushl  0x804000
  801a2c:	e8 78 f9 ff ff       	call   8013a9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a31:	83 c4 0c             	add    $0xc,%esp
  801a34:	6a 00                	push   $0x0
  801a36:	53                   	push   %ebx
  801a37:	6a 00                	push   $0x0
  801a39:	e8 fe f8 ff ff       	call   80133c <ipc_recv>
}
  801a3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a41:	5b                   	pop    %ebx
  801a42:	5e                   	pop    %esi
  801a43:	5d                   	pop    %ebp
  801a44:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a45:	83 ec 0c             	sub    $0xc,%esp
  801a48:	6a 01                	push   $0x1
  801a4a:	e8 ad f9 ff ff       	call   8013fc <ipc_find_env>
  801a4f:	a3 00 40 80 00       	mov    %eax,0x804000
  801a54:	83 c4 10             	add    $0x10,%esp
  801a57:	eb c5                	jmp    801a1e <fsipc+0x12>

00801a59 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a59:	f3 0f 1e fb          	endbr32 
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a63:	8b 45 08             	mov    0x8(%ebp),%eax
  801a66:	8b 40 0c             	mov    0xc(%eax),%eax
  801a69:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a71:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a76:	ba 00 00 00 00       	mov    $0x0,%edx
  801a7b:	b8 02 00 00 00       	mov    $0x2,%eax
  801a80:	e8 87 ff ff ff       	call   801a0c <fsipc>
}
  801a85:	c9                   	leave  
  801a86:	c3                   	ret    

00801a87 <devfile_flush>:
{
  801a87:	f3 0f 1e fb          	endbr32 
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a91:	8b 45 08             	mov    0x8(%ebp),%eax
  801a94:	8b 40 0c             	mov    0xc(%eax),%eax
  801a97:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a9c:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa1:	b8 06 00 00 00       	mov    $0x6,%eax
  801aa6:	e8 61 ff ff ff       	call   801a0c <fsipc>
}
  801aab:	c9                   	leave  
  801aac:	c3                   	ret    

00801aad <devfile_stat>:
{
  801aad:	f3 0f 1e fb          	endbr32 
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	53                   	push   %ebx
  801ab5:	83 ec 04             	sub    $0x4,%esp
  801ab8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801abb:	8b 45 08             	mov    0x8(%ebp),%eax
  801abe:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ac6:	ba 00 00 00 00       	mov    $0x0,%edx
  801acb:	b8 05 00 00 00       	mov    $0x5,%eax
  801ad0:	e8 37 ff ff ff       	call   801a0c <fsipc>
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	78 2c                	js     801b05 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ad9:	83 ec 08             	sub    $0x8,%esp
  801adc:	68 00 50 80 00       	push   $0x805000
  801ae1:	53                   	push   %ebx
  801ae2:	e8 c8 ed ff ff       	call   8008af <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ae7:	a1 80 50 80 00       	mov    0x805080,%eax
  801aec:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801af2:	a1 84 50 80 00       	mov    0x805084,%eax
  801af7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b08:	c9                   	leave  
  801b09:	c3                   	ret    

00801b0a <devfile_write>:
{
  801b0a:	f3 0f 1e fb          	endbr32 
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	57                   	push   %edi
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
  801b14:	83 ec 0c             	sub    $0xc,%esp
  801b17:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b20:	8b 40 0c             	mov    0xc(%eax),%eax
  801b23:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  801b28:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b2d:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  801b32:	85 db                	test   %ebx,%ebx
  801b34:	74 3b                	je     801b71 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b36:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801b3c:	89 f8                	mov    %edi,%eax
  801b3e:	0f 46 c3             	cmovbe %ebx,%eax
  801b41:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  801b46:	83 ec 04             	sub    $0x4,%esp
  801b49:	50                   	push   %eax
  801b4a:	56                   	push   %esi
  801b4b:	68 08 50 80 00       	push   $0x805008
  801b50:	e8 12 ef ff ff       	call   800a67 <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b55:	ba 00 00 00 00       	mov    $0x0,%edx
  801b5a:	b8 04 00 00 00       	mov    $0x4,%eax
  801b5f:	e8 a8 fe ff ff       	call   801a0c <fsipc>
  801b64:	83 c4 10             	add    $0x10,%esp
  801b67:	85 c0                	test   %eax,%eax
  801b69:	78 06                	js     801b71 <devfile_write+0x67>
		buf_aux += r;
  801b6b:	01 c6                	add    %eax,%esi
		n -= r;
  801b6d:	29 c3                	sub    %eax,%ebx
  801b6f:	eb c1                	jmp    801b32 <devfile_write+0x28>
}
  801b71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b74:	5b                   	pop    %ebx
  801b75:	5e                   	pop    %esi
  801b76:	5f                   	pop    %edi
  801b77:	5d                   	pop    %ebp
  801b78:	c3                   	ret    

00801b79 <devfile_read>:
{
  801b79:	f3 0f 1e fb          	endbr32 
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	56                   	push   %esi
  801b81:	53                   	push   %ebx
  801b82:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b85:	8b 45 08             	mov    0x8(%ebp),%eax
  801b88:	8b 40 0c             	mov    0xc(%eax),%eax
  801b8b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b90:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b96:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9b:	b8 03 00 00 00       	mov    $0x3,%eax
  801ba0:	e8 67 fe ff ff       	call   801a0c <fsipc>
  801ba5:	89 c3                	mov    %eax,%ebx
  801ba7:	85 c0                	test   %eax,%eax
  801ba9:	78 1f                	js     801bca <devfile_read+0x51>
	assert(r <= n);
  801bab:	39 f0                	cmp    %esi,%eax
  801bad:	77 24                	ja     801bd3 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801baf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bb4:	7f 33                	jg     801be9 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bb6:	83 ec 04             	sub    $0x4,%esp
  801bb9:	50                   	push   %eax
  801bba:	68 00 50 80 00       	push   $0x805000
  801bbf:	ff 75 0c             	pushl  0xc(%ebp)
  801bc2:	e8 a0 ee ff ff       	call   800a67 <memmove>
	return r;
  801bc7:	83 c4 10             	add    $0x10,%esp
}
  801bca:	89 d8                	mov    %ebx,%eax
  801bcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bcf:	5b                   	pop    %ebx
  801bd0:	5e                   	pop    %esi
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    
	assert(r <= n);
  801bd3:	68 b8 2b 80 00       	push   $0x802bb8
  801bd8:	68 bf 2b 80 00       	push   $0x802bbf
  801bdd:	6a 7c                	push   $0x7c
  801bdf:	68 d4 2b 80 00       	push   $0x802bd4
  801be4:	e8 75 e6 ff ff       	call   80025e <_panic>
	assert(r <= PGSIZE);
  801be9:	68 df 2b 80 00       	push   $0x802bdf
  801bee:	68 bf 2b 80 00       	push   $0x802bbf
  801bf3:	6a 7d                	push   $0x7d
  801bf5:	68 d4 2b 80 00       	push   $0x802bd4
  801bfa:	e8 5f e6 ff ff       	call   80025e <_panic>

00801bff <open>:
{
  801bff:	f3 0f 1e fb          	endbr32 
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	56                   	push   %esi
  801c07:	53                   	push   %ebx
  801c08:	83 ec 1c             	sub    $0x1c,%esp
  801c0b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801c0e:	56                   	push   %esi
  801c0f:	e8 58 ec ff ff       	call   80086c <strlen>
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c1c:	7f 6c                	jg     801c8a <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801c1e:	83 ec 0c             	sub    $0xc,%esp
  801c21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c24:	50                   	push   %eax
  801c25:	e8 42 f8 ff ff       	call   80146c <fd_alloc>
  801c2a:	89 c3                	mov    %eax,%ebx
  801c2c:	83 c4 10             	add    $0x10,%esp
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	78 3c                	js     801c6f <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801c33:	83 ec 08             	sub    $0x8,%esp
  801c36:	56                   	push   %esi
  801c37:	68 00 50 80 00       	push   $0x805000
  801c3c:	e8 6e ec ff ff       	call   8008af <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c41:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c44:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c49:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c4c:	b8 01 00 00 00       	mov    $0x1,%eax
  801c51:	e8 b6 fd ff ff       	call   801a0c <fsipc>
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	83 c4 10             	add    $0x10,%esp
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	78 19                	js     801c78 <open+0x79>
	return fd2num(fd);
  801c5f:	83 ec 0c             	sub    $0xc,%esp
  801c62:	ff 75 f4             	pushl  -0xc(%ebp)
  801c65:	e8 cf f7 ff ff       	call   801439 <fd2num>
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	83 c4 10             	add    $0x10,%esp
}
  801c6f:	89 d8                	mov    %ebx,%eax
  801c71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c74:	5b                   	pop    %ebx
  801c75:	5e                   	pop    %esi
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    
		fd_close(fd, 0);
  801c78:	83 ec 08             	sub    $0x8,%esp
  801c7b:	6a 00                	push   $0x0
  801c7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c80:	e8 eb f8 ff ff       	call   801570 <fd_close>
		return r;
  801c85:	83 c4 10             	add    $0x10,%esp
  801c88:	eb e5                	jmp    801c6f <open+0x70>
		return -E_BAD_PATH;
  801c8a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c8f:	eb de                	jmp    801c6f <open+0x70>

00801c91 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c91:	f3 0f 1e fb          	endbr32 
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca0:	b8 08 00 00 00       	mov    $0x8,%eax
  801ca5:	e8 62 fd ff ff       	call   801a0c <fsipc>
}
  801caa:	c9                   	leave  
  801cab:	c3                   	ret    

00801cac <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cac:	f3 0f 1e fb          	endbr32 
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801cb6:	89 c2                	mov    %eax,%edx
  801cb8:	c1 ea 16             	shr    $0x16,%edx
  801cbb:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801cc2:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801cc7:	f6 c1 01             	test   $0x1,%cl
  801cca:	74 1c                	je     801ce8 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801ccc:	c1 e8 0c             	shr    $0xc,%eax
  801ccf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801cd6:	a8 01                	test   $0x1,%al
  801cd8:	74 0e                	je     801ce8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cda:	c1 e8 0c             	shr    $0xc,%eax
  801cdd:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801ce4:	ef 
  801ce5:	0f b7 d2             	movzwl %dx,%edx
}
  801ce8:	89 d0                	mov    %edx,%eax
  801cea:	5d                   	pop    %ebp
  801ceb:	c3                   	ret    

00801cec <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cec:	f3 0f 1e fb          	endbr32 
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	56                   	push   %esi
  801cf4:	53                   	push   %ebx
  801cf5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cf8:	83 ec 0c             	sub    $0xc,%esp
  801cfb:	ff 75 08             	pushl  0x8(%ebp)
  801cfe:	e8 4a f7 ff ff       	call   80144d <fd2data>
  801d03:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d05:	83 c4 08             	add    $0x8,%esp
  801d08:	68 eb 2b 80 00       	push   $0x802beb
  801d0d:	53                   	push   %ebx
  801d0e:	e8 9c eb ff ff       	call   8008af <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d13:	8b 46 04             	mov    0x4(%esi),%eax
  801d16:	2b 06                	sub    (%esi),%eax
  801d18:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d1e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d25:	00 00 00 
	stat->st_dev = &devpipe;
  801d28:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801d2f:	30 80 00 
	return 0;
}
  801d32:	b8 00 00 00 00       	mov    $0x0,%eax
  801d37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d3a:	5b                   	pop    %ebx
  801d3b:	5e                   	pop    %esi
  801d3c:	5d                   	pop    %ebp
  801d3d:	c3                   	ret    

00801d3e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d3e:	f3 0f 1e fb          	endbr32 
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	53                   	push   %ebx
  801d46:	83 ec 0c             	sub    $0xc,%esp
  801d49:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d4c:	53                   	push   %ebx
  801d4d:	6a 00                	push   $0x0
  801d4f:	e8 35 f0 ff ff       	call   800d89 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d54:	89 1c 24             	mov    %ebx,(%esp)
  801d57:	e8 f1 f6 ff ff       	call   80144d <fd2data>
  801d5c:	83 c4 08             	add    $0x8,%esp
  801d5f:	50                   	push   %eax
  801d60:	6a 00                	push   $0x0
  801d62:	e8 22 f0 ff ff       	call   800d89 <sys_page_unmap>
}
  801d67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    

00801d6c <_pipeisclosed>:
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	57                   	push   %edi
  801d70:	56                   	push   %esi
  801d71:	53                   	push   %ebx
  801d72:	83 ec 1c             	sub    $0x1c,%esp
  801d75:	89 c7                	mov    %eax,%edi
  801d77:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801d79:	a1 04 40 80 00       	mov    0x804004,%eax
  801d7e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d81:	83 ec 0c             	sub    $0xc,%esp
  801d84:	57                   	push   %edi
  801d85:	e8 22 ff ff ff       	call   801cac <pageref>
  801d8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d8d:	89 34 24             	mov    %esi,(%esp)
  801d90:	e8 17 ff ff ff       	call   801cac <pageref>
		nn = thisenv->env_runs;
  801d95:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d9b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d9e:	83 c4 10             	add    $0x10,%esp
  801da1:	39 cb                	cmp    %ecx,%ebx
  801da3:	74 1b                	je     801dc0 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801da5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801da8:	75 cf                	jne    801d79 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801daa:	8b 42 58             	mov    0x58(%edx),%eax
  801dad:	6a 01                	push   $0x1
  801daf:	50                   	push   %eax
  801db0:	53                   	push   %ebx
  801db1:	68 f2 2b 80 00       	push   $0x802bf2
  801db6:	e8 8a e5 ff ff       	call   800345 <cprintf>
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	eb b9                	jmp    801d79 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801dc0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801dc3:	0f 94 c0             	sete   %al
  801dc6:	0f b6 c0             	movzbl %al,%eax
}
  801dc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dcc:	5b                   	pop    %ebx
  801dcd:	5e                   	pop    %esi
  801dce:	5f                   	pop    %edi
  801dcf:	5d                   	pop    %ebp
  801dd0:	c3                   	ret    

00801dd1 <devpipe_write>:
{
  801dd1:	f3 0f 1e fb          	endbr32 
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	57                   	push   %edi
  801dd9:	56                   	push   %esi
  801dda:	53                   	push   %ebx
  801ddb:	83 ec 28             	sub    $0x28,%esp
  801dde:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801de1:	56                   	push   %esi
  801de2:	e8 66 f6 ff ff       	call   80144d <fd2data>
  801de7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801de9:	83 c4 10             	add    $0x10,%esp
  801dec:	bf 00 00 00 00       	mov    $0x0,%edi
  801df1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801df4:	74 4f                	je     801e45 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801df6:	8b 43 04             	mov    0x4(%ebx),%eax
  801df9:	8b 0b                	mov    (%ebx),%ecx
  801dfb:	8d 51 20             	lea    0x20(%ecx),%edx
  801dfe:	39 d0                	cmp    %edx,%eax
  801e00:	72 14                	jb     801e16 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801e02:	89 da                	mov    %ebx,%edx
  801e04:	89 f0                	mov    %esi,%eax
  801e06:	e8 61 ff ff ff       	call   801d6c <_pipeisclosed>
  801e0b:	85 c0                	test   %eax,%eax
  801e0d:	75 3b                	jne    801e4a <devpipe_write+0x79>
			sys_yield();
  801e0f:	e8 f8 ee ff ff       	call   800d0c <sys_yield>
  801e14:	eb e0                	jmp    801df6 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e19:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e1d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e20:	89 c2                	mov    %eax,%edx
  801e22:	c1 fa 1f             	sar    $0x1f,%edx
  801e25:	89 d1                	mov    %edx,%ecx
  801e27:	c1 e9 1b             	shr    $0x1b,%ecx
  801e2a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e2d:	83 e2 1f             	and    $0x1f,%edx
  801e30:	29 ca                	sub    %ecx,%edx
  801e32:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e36:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e3a:	83 c0 01             	add    $0x1,%eax
  801e3d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801e40:	83 c7 01             	add    $0x1,%edi
  801e43:	eb ac                	jmp    801df1 <devpipe_write+0x20>
	return i;
  801e45:	8b 45 10             	mov    0x10(%ebp),%eax
  801e48:	eb 05                	jmp    801e4f <devpipe_write+0x7e>
				return 0;
  801e4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e52:	5b                   	pop    %ebx
  801e53:	5e                   	pop    %esi
  801e54:	5f                   	pop    %edi
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    

00801e57 <devpipe_read>:
{
  801e57:	f3 0f 1e fb          	endbr32 
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	57                   	push   %edi
  801e5f:	56                   	push   %esi
  801e60:	53                   	push   %ebx
  801e61:	83 ec 18             	sub    $0x18,%esp
  801e64:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e67:	57                   	push   %edi
  801e68:	e8 e0 f5 ff ff       	call   80144d <fd2data>
  801e6d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e6f:	83 c4 10             	add    $0x10,%esp
  801e72:	be 00 00 00 00       	mov    $0x0,%esi
  801e77:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e7a:	75 14                	jne    801e90 <devpipe_read+0x39>
	return i;
  801e7c:	8b 45 10             	mov    0x10(%ebp),%eax
  801e7f:	eb 02                	jmp    801e83 <devpipe_read+0x2c>
				return i;
  801e81:	89 f0                	mov    %esi,%eax
}
  801e83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e86:	5b                   	pop    %ebx
  801e87:	5e                   	pop    %esi
  801e88:	5f                   	pop    %edi
  801e89:	5d                   	pop    %ebp
  801e8a:	c3                   	ret    
			sys_yield();
  801e8b:	e8 7c ee ff ff       	call   800d0c <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e90:	8b 03                	mov    (%ebx),%eax
  801e92:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e95:	75 18                	jne    801eaf <devpipe_read+0x58>
			if (i > 0)
  801e97:	85 f6                	test   %esi,%esi
  801e99:	75 e6                	jne    801e81 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801e9b:	89 da                	mov    %ebx,%edx
  801e9d:	89 f8                	mov    %edi,%eax
  801e9f:	e8 c8 fe ff ff       	call   801d6c <_pipeisclosed>
  801ea4:	85 c0                	test   %eax,%eax
  801ea6:	74 e3                	je     801e8b <devpipe_read+0x34>
				return 0;
  801ea8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ead:	eb d4                	jmp    801e83 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801eaf:	99                   	cltd   
  801eb0:	c1 ea 1b             	shr    $0x1b,%edx
  801eb3:	01 d0                	add    %edx,%eax
  801eb5:	83 e0 1f             	and    $0x1f,%eax
  801eb8:	29 d0                	sub    %edx,%eax
  801eba:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ebf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ec2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ec5:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ec8:	83 c6 01             	add    $0x1,%esi
  801ecb:	eb aa                	jmp    801e77 <devpipe_read+0x20>

00801ecd <pipe>:
{
  801ecd:	f3 0f 1e fb          	endbr32 
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	56                   	push   %esi
  801ed5:	53                   	push   %ebx
  801ed6:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ed9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801edc:	50                   	push   %eax
  801edd:	e8 8a f5 ff ff       	call   80146c <fd_alloc>
  801ee2:	89 c3                	mov    %eax,%ebx
  801ee4:	83 c4 10             	add    $0x10,%esp
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	0f 88 23 01 00 00    	js     802012 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eef:	83 ec 04             	sub    $0x4,%esp
  801ef2:	68 07 04 00 00       	push   $0x407
  801ef7:	ff 75 f4             	pushl  -0xc(%ebp)
  801efa:	6a 00                	push   $0x0
  801efc:	e8 36 ee ff ff       	call   800d37 <sys_page_alloc>
  801f01:	89 c3                	mov    %eax,%ebx
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	85 c0                	test   %eax,%eax
  801f08:	0f 88 04 01 00 00    	js     802012 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801f0e:	83 ec 0c             	sub    $0xc,%esp
  801f11:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f14:	50                   	push   %eax
  801f15:	e8 52 f5 ff ff       	call   80146c <fd_alloc>
  801f1a:	89 c3                	mov    %eax,%ebx
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	0f 88 db 00 00 00    	js     802002 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f27:	83 ec 04             	sub    $0x4,%esp
  801f2a:	68 07 04 00 00       	push   $0x407
  801f2f:	ff 75 f0             	pushl  -0x10(%ebp)
  801f32:	6a 00                	push   $0x0
  801f34:	e8 fe ed ff ff       	call   800d37 <sys_page_alloc>
  801f39:	89 c3                	mov    %eax,%ebx
  801f3b:	83 c4 10             	add    $0x10,%esp
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	0f 88 bc 00 00 00    	js     802002 <pipe+0x135>
	va = fd2data(fd0);
  801f46:	83 ec 0c             	sub    $0xc,%esp
  801f49:	ff 75 f4             	pushl  -0xc(%ebp)
  801f4c:	e8 fc f4 ff ff       	call   80144d <fd2data>
  801f51:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f53:	83 c4 0c             	add    $0xc,%esp
  801f56:	68 07 04 00 00       	push   $0x407
  801f5b:	50                   	push   %eax
  801f5c:	6a 00                	push   $0x0
  801f5e:	e8 d4 ed ff ff       	call   800d37 <sys_page_alloc>
  801f63:	89 c3                	mov    %eax,%ebx
  801f65:	83 c4 10             	add    $0x10,%esp
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	0f 88 82 00 00 00    	js     801ff2 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f70:	83 ec 0c             	sub    $0xc,%esp
  801f73:	ff 75 f0             	pushl  -0x10(%ebp)
  801f76:	e8 d2 f4 ff ff       	call   80144d <fd2data>
  801f7b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f82:	50                   	push   %eax
  801f83:	6a 00                	push   $0x0
  801f85:	56                   	push   %esi
  801f86:	6a 00                	push   $0x0
  801f88:	e8 d2 ed ff ff       	call   800d5f <sys_page_map>
  801f8d:	89 c3                	mov    %eax,%ebx
  801f8f:	83 c4 20             	add    $0x20,%esp
  801f92:	85 c0                	test   %eax,%eax
  801f94:	78 4e                	js     801fe4 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801f96:	a1 20 30 80 00       	mov    0x803020,%eax
  801f9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f9e:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801fa0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fa3:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801faa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fad:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801faf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fb2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801fb9:	83 ec 0c             	sub    $0xc,%esp
  801fbc:	ff 75 f4             	pushl  -0xc(%ebp)
  801fbf:	e8 75 f4 ff ff       	call   801439 <fd2num>
  801fc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fc7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fc9:	83 c4 04             	add    $0x4,%esp
  801fcc:	ff 75 f0             	pushl  -0x10(%ebp)
  801fcf:	e8 65 f4 ff ff       	call   801439 <fd2num>
  801fd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fd7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801fda:	83 c4 10             	add    $0x10,%esp
  801fdd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fe2:	eb 2e                	jmp    802012 <pipe+0x145>
	sys_page_unmap(0, va);
  801fe4:	83 ec 08             	sub    $0x8,%esp
  801fe7:	56                   	push   %esi
  801fe8:	6a 00                	push   $0x0
  801fea:	e8 9a ed ff ff       	call   800d89 <sys_page_unmap>
  801fef:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ff2:	83 ec 08             	sub    $0x8,%esp
  801ff5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ff8:	6a 00                	push   $0x0
  801ffa:	e8 8a ed ff ff       	call   800d89 <sys_page_unmap>
  801fff:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802002:	83 ec 08             	sub    $0x8,%esp
  802005:	ff 75 f4             	pushl  -0xc(%ebp)
  802008:	6a 00                	push   $0x0
  80200a:	e8 7a ed ff ff       	call   800d89 <sys_page_unmap>
  80200f:	83 c4 10             	add    $0x10,%esp
}
  802012:	89 d8                	mov    %ebx,%eax
  802014:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802017:	5b                   	pop    %ebx
  802018:	5e                   	pop    %esi
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    

0080201b <pipeisclosed>:
{
  80201b:	f3 0f 1e fb          	endbr32 
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802025:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802028:	50                   	push   %eax
  802029:	ff 75 08             	pushl  0x8(%ebp)
  80202c:	e8 91 f4 ff ff       	call   8014c2 <fd_lookup>
  802031:	83 c4 10             	add    $0x10,%esp
  802034:	85 c0                	test   %eax,%eax
  802036:	78 18                	js     802050 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  802038:	83 ec 0c             	sub    $0xc,%esp
  80203b:	ff 75 f4             	pushl  -0xc(%ebp)
  80203e:	e8 0a f4 ff ff       	call   80144d <fd2data>
  802043:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802045:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802048:	e8 1f fd ff ff       	call   801d6c <_pipeisclosed>
  80204d:	83 c4 10             	add    $0x10,%esp
}
  802050:	c9                   	leave  
  802051:	c3                   	ret    

00802052 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802052:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  802056:	b8 00 00 00 00       	mov    $0x0,%eax
  80205b:	c3                   	ret    

0080205c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80205c:	f3 0f 1e fb          	endbr32 
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802066:	68 0a 2c 80 00       	push   $0x802c0a
  80206b:	ff 75 0c             	pushl  0xc(%ebp)
  80206e:	e8 3c e8 ff ff       	call   8008af <strcpy>
	return 0;
}
  802073:	b8 00 00 00 00       	mov    $0x0,%eax
  802078:	c9                   	leave  
  802079:	c3                   	ret    

0080207a <devcons_write>:
{
  80207a:	f3 0f 1e fb          	endbr32 
  80207e:	55                   	push   %ebp
  80207f:	89 e5                	mov    %esp,%ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80208a:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80208f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802095:	3b 75 10             	cmp    0x10(%ebp),%esi
  802098:	73 31                	jae    8020cb <devcons_write+0x51>
		m = n - tot;
  80209a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80209d:	29 f3                	sub    %esi,%ebx
  80209f:	83 fb 7f             	cmp    $0x7f,%ebx
  8020a2:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8020a7:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8020aa:	83 ec 04             	sub    $0x4,%esp
  8020ad:	53                   	push   %ebx
  8020ae:	89 f0                	mov    %esi,%eax
  8020b0:	03 45 0c             	add    0xc(%ebp),%eax
  8020b3:	50                   	push   %eax
  8020b4:	57                   	push   %edi
  8020b5:	e8 ad e9 ff ff       	call   800a67 <memmove>
		sys_cputs(buf, m);
  8020ba:	83 c4 08             	add    $0x8,%esp
  8020bd:	53                   	push   %ebx
  8020be:	57                   	push   %edi
  8020bf:	e8 a8 eb ff ff       	call   800c6c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8020c4:	01 de                	add    %ebx,%esi
  8020c6:	83 c4 10             	add    $0x10,%esp
  8020c9:	eb ca                	jmp    802095 <devcons_write+0x1b>
}
  8020cb:	89 f0                	mov    %esi,%eax
  8020cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d0:	5b                   	pop    %ebx
  8020d1:	5e                   	pop    %esi
  8020d2:	5f                   	pop    %edi
  8020d3:	5d                   	pop    %ebp
  8020d4:	c3                   	ret    

008020d5 <devcons_read>:
{
  8020d5:	f3 0f 1e fb          	endbr32 
  8020d9:	55                   	push   %ebp
  8020da:	89 e5                	mov    %esp,%ebp
  8020dc:	83 ec 08             	sub    $0x8,%esp
  8020df:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8020e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020e8:	74 21                	je     80210b <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8020ea:	e8 a7 eb ff ff       	call   800c96 <sys_cgetc>
  8020ef:	85 c0                	test   %eax,%eax
  8020f1:	75 07                	jne    8020fa <devcons_read+0x25>
		sys_yield();
  8020f3:	e8 14 ec ff ff       	call   800d0c <sys_yield>
  8020f8:	eb f0                	jmp    8020ea <devcons_read+0x15>
	if (c < 0)
  8020fa:	78 0f                	js     80210b <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8020fc:	83 f8 04             	cmp    $0x4,%eax
  8020ff:	74 0c                	je     80210d <devcons_read+0x38>
	*(char*)vbuf = c;
  802101:	8b 55 0c             	mov    0xc(%ebp),%edx
  802104:	88 02                	mov    %al,(%edx)
	return 1;
  802106:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80210b:	c9                   	leave  
  80210c:	c3                   	ret    
		return 0;
  80210d:	b8 00 00 00 00       	mov    $0x0,%eax
  802112:	eb f7                	jmp    80210b <devcons_read+0x36>

00802114 <cputchar>:
{
  802114:	f3 0f 1e fb          	endbr32 
  802118:	55                   	push   %ebp
  802119:	89 e5                	mov    %esp,%ebp
  80211b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80211e:	8b 45 08             	mov    0x8(%ebp),%eax
  802121:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802124:	6a 01                	push   $0x1
  802126:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802129:	50                   	push   %eax
  80212a:	e8 3d eb ff ff       	call   800c6c <sys_cputs>
}
  80212f:	83 c4 10             	add    $0x10,%esp
  802132:	c9                   	leave  
  802133:	c3                   	ret    

00802134 <getchar>:
{
  802134:	f3 0f 1e fb          	endbr32 
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
  80213b:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80213e:	6a 01                	push   $0x1
  802140:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802143:	50                   	push   %eax
  802144:	6a 00                	push   $0x0
  802146:	e8 fa f5 ff ff       	call   801745 <read>
	if (r < 0)
  80214b:	83 c4 10             	add    $0x10,%esp
  80214e:	85 c0                	test   %eax,%eax
  802150:	78 06                	js     802158 <getchar+0x24>
	if (r < 1)
  802152:	74 06                	je     80215a <getchar+0x26>
	return c;
  802154:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802158:	c9                   	leave  
  802159:	c3                   	ret    
		return -E_EOF;
  80215a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80215f:	eb f7                	jmp    802158 <getchar+0x24>

00802161 <iscons>:
{
  802161:	f3 0f 1e fb          	endbr32 
  802165:	55                   	push   %ebp
  802166:	89 e5                	mov    %esp,%ebp
  802168:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80216b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80216e:	50                   	push   %eax
  80216f:	ff 75 08             	pushl  0x8(%ebp)
  802172:	e8 4b f3 ff ff       	call   8014c2 <fd_lookup>
  802177:	83 c4 10             	add    $0x10,%esp
  80217a:	85 c0                	test   %eax,%eax
  80217c:	78 11                	js     80218f <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80217e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802181:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802187:	39 10                	cmp    %edx,(%eax)
  802189:	0f 94 c0             	sete   %al
  80218c:	0f b6 c0             	movzbl %al,%eax
}
  80218f:	c9                   	leave  
  802190:	c3                   	ret    

00802191 <opencons>:
{
  802191:	f3 0f 1e fb          	endbr32 
  802195:	55                   	push   %ebp
  802196:	89 e5                	mov    %esp,%ebp
  802198:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80219b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80219e:	50                   	push   %eax
  80219f:	e8 c8 f2 ff ff       	call   80146c <fd_alloc>
  8021a4:	83 c4 10             	add    $0x10,%esp
  8021a7:	85 c0                	test   %eax,%eax
  8021a9:	78 3a                	js     8021e5 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021ab:	83 ec 04             	sub    $0x4,%esp
  8021ae:	68 07 04 00 00       	push   $0x407
  8021b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8021b6:	6a 00                	push   $0x0
  8021b8:	e8 7a eb ff ff       	call   800d37 <sys_page_alloc>
  8021bd:	83 c4 10             	add    $0x10,%esp
  8021c0:	85 c0                	test   %eax,%eax
  8021c2:	78 21                	js     8021e5 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8021c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021cd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021d9:	83 ec 0c             	sub    $0xc,%esp
  8021dc:	50                   	push   %eax
  8021dd:	e8 57 f2 ff ff       	call   801439 <fd2num>
  8021e2:	83 c4 10             	add    $0x10,%esp
}
  8021e5:	c9                   	leave  
  8021e6:	c3                   	ret    

008021e7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021e7:	f3 0f 1e fb          	endbr32 
  8021eb:	55                   	push   %ebp
  8021ec:	89 e5                	mov    %esp,%ebp
  8021ee:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  8021f1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021f8:	74 0a                	je     802204 <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fd:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802202:	c9                   	leave  
  802203:	c3                   	ret    
		if (sys_page_alloc(0,
  802204:	83 ec 04             	sub    $0x4,%esp
  802207:	6a 07                	push   $0x7
  802209:	68 00 f0 bf ee       	push   $0xeebff000
  80220e:	6a 00                	push   $0x0
  802210:	e8 22 eb ff ff       	call   800d37 <sys_page_alloc>
  802215:	83 c4 10             	add    $0x10,%esp
  802218:	85 c0                	test   %eax,%eax
  80221a:	78 2a                	js     802246 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  80221c:	83 ec 08             	sub    $0x8,%esp
  80221f:	68 5a 22 80 00       	push   $0x80225a
  802224:	6a 00                	push   $0x0
  802226:	e8 d3 eb ff ff       	call   800dfe <sys_env_set_pgfault_upcall>
  80222b:	83 c4 10             	add    $0x10,%esp
  80222e:	85 c0                	test   %eax,%eax
  802230:	79 c8                	jns    8021fa <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  802232:	83 ec 04             	sub    $0x4,%esp
  802235:	68 4c 2c 80 00       	push   $0x802c4c
  80223a:	6a 25                	push   $0x25
  80223c:	68 93 2c 80 00       	push   $0x802c93
  802241:	e8 18 e0 ff ff       	call   80025e <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  802246:	83 ec 04             	sub    $0x4,%esp
  802249:	68 18 2c 80 00       	push   $0x802c18
  80224e:	6a 21                	push   $0x21
  802250:	68 93 2c 80 00       	push   $0x802c93
  802255:	e8 04 e0 ff ff       	call   80025e <_panic>

0080225a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80225a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80225b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802260:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802262:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  802265:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  80226a:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  80226e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802272:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  802274:	83 c4 08             	add    $0x8,%esp
	popal
  802277:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  802278:	83 c4 04             	add    $0x4,%esp
	popfl
  80227b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  80227c:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80227f:	c3                   	ret    

00802280 <__udivdi3>:
  802280:	f3 0f 1e fb          	endbr32 
  802284:	55                   	push   %ebp
  802285:	57                   	push   %edi
  802286:	56                   	push   %esi
  802287:	53                   	push   %ebx
  802288:	83 ec 1c             	sub    $0x1c,%esp
  80228b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80228f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802293:	8b 74 24 34          	mov    0x34(%esp),%esi
  802297:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80229b:	85 d2                	test   %edx,%edx
  80229d:	75 19                	jne    8022b8 <__udivdi3+0x38>
  80229f:	39 f3                	cmp    %esi,%ebx
  8022a1:	76 4d                	jbe    8022f0 <__udivdi3+0x70>
  8022a3:	31 ff                	xor    %edi,%edi
  8022a5:	89 e8                	mov    %ebp,%eax
  8022a7:	89 f2                	mov    %esi,%edx
  8022a9:	f7 f3                	div    %ebx
  8022ab:	89 fa                	mov    %edi,%edx
  8022ad:	83 c4 1c             	add    $0x1c,%esp
  8022b0:	5b                   	pop    %ebx
  8022b1:	5e                   	pop    %esi
  8022b2:	5f                   	pop    %edi
  8022b3:	5d                   	pop    %ebp
  8022b4:	c3                   	ret    
  8022b5:	8d 76 00             	lea    0x0(%esi),%esi
  8022b8:	39 f2                	cmp    %esi,%edx
  8022ba:	76 14                	jbe    8022d0 <__udivdi3+0x50>
  8022bc:	31 ff                	xor    %edi,%edi
  8022be:	31 c0                	xor    %eax,%eax
  8022c0:	89 fa                	mov    %edi,%edx
  8022c2:	83 c4 1c             	add    $0x1c,%esp
  8022c5:	5b                   	pop    %ebx
  8022c6:	5e                   	pop    %esi
  8022c7:	5f                   	pop    %edi
  8022c8:	5d                   	pop    %ebp
  8022c9:	c3                   	ret    
  8022ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022d0:	0f bd fa             	bsr    %edx,%edi
  8022d3:	83 f7 1f             	xor    $0x1f,%edi
  8022d6:	75 48                	jne    802320 <__udivdi3+0xa0>
  8022d8:	39 f2                	cmp    %esi,%edx
  8022da:	72 06                	jb     8022e2 <__udivdi3+0x62>
  8022dc:	31 c0                	xor    %eax,%eax
  8022de:	39 eb                	cmp    %ebp,%ebx
  8022e0:	77 de                	ja     8022c0 <__udivdi3+0x40>
  8022e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8022e7:	eb d7                	jmp    8022c0 <__udivdi3+0x40>
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	89 d9                	mov    %ebx,%ecx
  8022f2:	85 db                	test   %ebx,%ebx
  8022f4:	75 0b                	jne    802301 <__udivdi3+0x81>
  8022f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022fb:	31 d2                	xor    %edx,%edx
  8022fd:	f7 f3                	div    %ebx
  8022ff:	89 c1                	mov    %eax,%ecx
  802301:	31 d2                	xor    %edx,%edx
  802303:	89 f0                	mov    %esi,%eax
  802305:	f7 f1                	div    %ecx
  802307:	89 c6                	mov    %eax,%esi
  802309:	89 e8                	mov    %ebp,%eax
  80230b:	89 f7                	mov    %esi,%edi
  80230d:	f7 f1                	div    %ecx
  80230f:	89 fa                	mov    %edi,%edx
  802311:	83 c4 1c             	add    $0x1c,%esp
  802314:	5b                   	pop    %ebx
  802315:	5e                   	pop    %esi
  802316:	5f                   	pop    %edi
  802317:	5d                   	pop    %ebp
  802318:	c3                   	ret    
  802319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802320:	89 f9                	mov    %edi,%ecx
  802322:	b8 20 00 00 00       	mov    $0x20,%eax
  802327:	29 f8                	sub    %edi,%eax
  802329:	d3 e2                	shl    %cl,%edx
  80232b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80232f:	89 c1                	mov    %eax,%ecx
  802331:	89 da                	mov    %ebx,%edx
  802333:	d3 ea                	shr    %cl,%edx
  802335:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802339:	09 d1                	or     %edx,%ecx
  80233b:	89 f2                	mov    %esi,%edx
  80233d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802341:	89 f9                	mov    %edi,%ecx
  802343:	d3 e3                	shl    %cl,%ebx
  802345:	89 c1                	mov    %eax,%ecx
  802347:	d3 ea                	shr    %cl,%edx
  802349:	89 f9                	mov    %edi,%ecx
  80234b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80234f:	89 eb                	mov    %ebp,%ebx
  802351:	d3 e6                	shl    %cl,%esi
  802353:	89 c1                	mov    %eax,%ecx
  802355:	d3 eb                	shr    %cl,%ebx
  802357:	09 de                	or     %ebx,%esi
  802359:	89 f0                	mov    %esi,%eax
  80235b:	f7 74 24 08          	divl   0x8(%esp)
  80235f:	89 d6                	mov    %edx,%esi
  802361:	89 c3                	mov    %eax,%ebx
  802363:	f7 64 24 0c          	mull   0xc(%esp)
  802367:	39 d6                	cmp    %edx,%esi
  802369:	72 15                	jb     802380 <__udivdi3+0x100>
  80236b:	89 f9                	mov    %edi,%ecx
  80236d:	d3 e5                	shl    %cl,%ebp
  80236f:	39 c5                	cmp    %eax,%ebp
  802371:	73 04                	jae    802377 <__udivdi3+0xf7>
  802373:	39 d6                	cmp    %edx,%esi
  802375:	74 09                	je     802380 <__udivdi3+0x100>
  802377:	89 d8                	mov    %ebx,%eax
  802379:	31 ff                	xor    %edi,%edi
  80237b:	e9 40 ff ff ff       	jmp    8022c0 <__udivdi3+0x40>
  802380:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802383:	31 ff                	xor    %edi,%edi
  802385:	e9 36 ff ff ff       	jmp    8022c0 <__udivdi3+0x40>
  80238a:	66 90                	xchg   %ax,%ax
  80238c:	66 90                	xchg   %ax,%ax
  80238e:	66 90                	xchg   %ax,%ax

00802390 <__umoddi3>:
  802390:	f3 0f 1e fb          	endbr32 
  802394:	55                   	push   %ebp
  802395:	57                   	push   %edi
  802396:	56                   	push   %esi
  802397:	53                   	push   %ebx
  802398:	83 ec 1c             	sub    $0x1c,%esp
  80239b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80239f:	8b 74 24 30          	mov    0x30(%esp),%esi
  8023a3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8023a7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023ab:	85 c0                	test   %eax,%eax
  8023ad:	75 19                	jne    8023c8 <__umoddi3+0x38>
  8023af:	39 df                	cmp    %ebx,%edi
  8023b1:	76 5d                	jbe    802410 <__umoddi3+0x80>
  8023b3:	89 f0                	mov    %esi,%eax
  8023b5:	89 da                	mov    %ebx,%edx
  8023b7:	f7 f7                	div    %edi
  8023b9:	89 d0                	mov    %edx,%eax
  8023bb:	31 d2                	xor    %edx,%edx
  8023bd:	83 c4 1c             	add    $0x1c,%esp
  8023c0:	5b                   	pop    %ebx
  8023c1:	5e                   	pop    %esi
  8023c2:	5f                   	pop    %edi
  8023c3:	5d                   	pop    %ebp
  8023c4:	c3                   	ret    
  8023c5:	8d 76 00             	lea    0x0(%esi),%esi
  8023c8:	89 f2                	mov    %esi,%edx
  8023ca:	39 d8                	cmp    %ebx,%eax
  8023cc:	76 12                	jbe    8023e0 <__umoddi3+0x50>
  8023ce:	89 f0                	mov    %esi,%eax
  8023d0:	89 da                	mov    %ebx,%edx
  8023d2:	83 c4 1c             	add    $0x1c,%esp
  8023d5:	5b                   	pop    %ebx
  8023d6:	5e                   	pop    %esi
  8023d7:	5f                   	pop    %edi
  8023d8:	5d                   	pop    %ebp
  8023d9:	c3                   	ret    
  8023da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023e0:	0f bd e8             	bsr    %eax,%ebp
  8023e3:	83 f5 1f             	xor    $0x1f,%ebp
  8023e6:	75 50                	jne    802438 <__umoddi3+0xa8>
  8023e8:	39 d8                	cmp    %ebx,%eax
  8023ea:	0f 82 e0 00 00 00    	jb     8024d0 <__umoddi3+0x140>
  8023f0:	89 d9                	mov    %ebx,%ecx
  8023f2:	39 f7                	cmp    %esi,%edi
  8023f4:	0f 86 d6 00 00 00    	jbe    8024d0 <__umoddi3+0x140>
  8023fa:	89 d0                	mov    %edx,%eax
  8023fc:	89 ca                	mov    %ecx,%edx
  8023fe:	83 c4 1c             	add    $0x1c,%esp
  802401:	5b                   	pop    %ebx
  802402:	5e                   	pop    %esi
  802403:	5f                   	pop    %edi
  802404:	5d                   	pop    %ebp
  802405:	c3                   	ret    
  802406:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80240d:	8d 76 00             	lea    0x0(%esi),%esi
  802410:	89 fd                	mov    %edi,%ebp
  802412:	85 ff                	test   %edi,%edi
  802414:	75 0b                	jne    802421 <__umoddi3+0x91>
  802416:	b8 01 00 00 00       	mov    $0x1,%eax
  80241b:	31 d2                	xor    %edx,%edx
  80241d:	f7 f7                	div    %edi
  80241f:	89 c5                	mov    %eax,%ebp
  802421:	89 d8                	mov    %ebx,%eax
  802423:	31 d2                	xor    %edx,%edx
  802425:	f7 f5                	div    %ebp
  802427:	89 f0                	mov    %esi,%eax
  802429:	f7 f5                	div    %ebp
  80242b:	89 d0                	mov    %edx,%eax
  80242d:	31 d2                	xor    %edx,%edx
  80242f:	eb 8c                	jmp    8023bd <__umoddi3+0x2d>
  802431:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802438:	89 e9                	mov    %ebp,%ecx
  80243a:	ba 20 00 00 00       	mov    $0x20,%edx
  80243f:	29 ea                	sub    %ebp,%edx
  802441:	d3 e0                	shl    %cl,%eax
  802443:	89 44 24 08          	mov    %eax,0x8(%esp)
  802447:	89 d1                	mov    %edx,%ecx
  802449:	89 f8                	mov    %edi,%eax
  80244b:	d3 e8                	shr    %cl,%eax
  80244d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802451:	89 54 24 04          	mov    %edx,0x4(%esp)
  802455:	8b 54 24 04          	mov    0x4(%esp),%edx
  802459:	09 c1                	or     %eax,%ecx
  80245b:	89 d8                	mov    %ebx,%eax
  80245d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802461:	89 e9                	mov    %ebp,%ecx
  802463:	d3 e7                	shl    %cl,%edi
  802465:	89 d1                	mov    %edx,%ecx
  802467:	d3 e8                	shr    %cl,%eax
  802469:	89 e9                	mov    %ebp,%ecx
  80246b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80246f:	d3 e3                	shl    %cl,%ebx
  802471:	89 c7                	mov    %eax,%edi
  802473:	89 d1                	mov    %edx,%ecx
  802475:	89 f0                	mov    %esi,%eax
  802477:	d3 e8                	shr    %cl,%eax
  802479:	89 e9                	mov    %ebp,%ecx
  80247b:	89 fa                	mov    %edi,%edx
  80247d:	d3 e6                	shl    %cl,%esi
  80247f:	09 d8                	or     %ebx,%eax
  802481:	f7 74 24 08          	divl   0x8(%esp)
  802485:	89 d1                	mov    %edx,%ecx
  802487:	89 f3                	mov    %esi,%ebx
  802489:	f7 64 24 0c          	mull   0xc(%esp)
  80248d:	89 c6                	mov    %eax,%esi
  80248f:	89 d7                	mov    %edx,%edi
  802491:	39 d1                	cmp    %edx,%ecx
  802493:	72 06                	jb     80249b <__umoddi3+0x10b>
  802495:	75 10                	jne    8024a7 <__umoddi3+0x117>
  802497:	39 c3                	cmp    %eax,%ebx
  802499:	73 0c                	jae    8024a7 <__umoddi3+0x117>
  80249b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80249f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8024a3:	89 d7                	mov    %edx,%edi
  8024a5:	89 c6                	mov    %eax,%esi
  8024a7:	89 ca                	mov    %ecx,%edx
  8024a9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8024ae:	29 f3                	sub    %esi,%ebx
  8024b0:	19 fa                	sbb    %edi,%edx
  8024b2:	89 d0                	mov    %edx,%eax
  8024b4:	d3 e0                	shl    %cl,%eax
  8024b6:	89 e9                	mov    %ebp,%ecx
  8024b8:	d3 eb                	shr    %cl,%ebx
  8024ba:	d3 ea                	shr    %cl,%edx
  8024bc:	09 d8                	or     %ebx,%eax
  8024be:	83 c4 1c             	add    $0x1c,%esp
  8024c1:	5b                   	pop    %ebx
  8024c2:	5e                   	pop    %esi
  8024c3:	5f                   	pop    %edi
  8024c4:	5d                   	pop    %ebp
  8024c5:	c3                   	ret    
  8024c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024cd:	8d 76 00             	lea    0x0(%esi),%esi
  8024d0:	29 fe                	sub    %edi,%esi
  8024d2:	19 c3                	sbb    %eax,%ebx
  8024d4:	89 f2                	mov    %esi,%edx
  8024d6:	89 d9                	mov    %ebx,%ecx
  8024d8:	e9 1d ff ff ff       	jmp    8023fa <__umoddi3+0x6a>
