
obj/user/primespipe.debug:     file format elf32-i386


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
  80002c:	e8 08 02 00 00       	call   800239 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 1c             	sub    $0x1c,%esp
  800040:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800043:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800046:	8d 7d d8             	lea    -0x28(%ebp),%edi
  800049:	eb 5e                	jmp    8000a9 <primeproc+0x76>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  80004b:	83 ec 0c             	sub    $0xc,%esp
  80004e:	85 c0                	test   %eax,%eax
  800050:	ba 00 00 00 00       	mov    $0x0,%edx
  800055:	0f 4e d0             	cmovle %eax,%edx
  800058:	52                   	push   %edx
  800059:	50                   	push   %eax
  80005a:	68 40 25 80 00       	push   $0x802540
  80005f:	6a 15                	push   $0x15
  800061:	68 6f 25 80 00       	push   $0x80256f
  800066:	e8 3a 02 00 00       	call   8002a5 <_panic>
		panic("pipe: %e", i);
  80006b:	50                   	push   %eax
  80006c:	68 85 25 80 00       	push   $0x802585
  800071:	6a 1b                	push   $0x1b
  800073:	68 6f 25 80 00       	push   $0x80256f
  800078:	e8 28 02 00 00       	call   8002a5 <_panic>
	if ((id = fork()) < 0)
		panic("fork: %e", id);
  80007d:	50                   	push   %eax
  80007e:	68 8e 25 80 00       	push   $0x80258e
  800083:	6a 1d                	push   $0x1d
  800085:	68 6f 25 80 00       	push   $0x80256f
  80008a:	e8 16 02 00 00       	call   8002a5 <_panic>
	if (id == 0) {
		close(fd);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	53                   	push   %ebx
  800093:	e8 ad 14 00 00       	call   801545 <close>
		close(pfd[1]);
  800098:	83 c4 04             	add    $0x4,%esp
  80009b:	ff 75 dc             	pushl  -0x24(%ebp)
  80009e:	e8 a2 14 00 00       	call   801545 <close>
		fd = pfd[0];
  8000a3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000a6:	83 c4 10             	add    $0x10,%esp
	if ((r = readn(fd, &p, 4)) != 4)
  8000a9:	83 ec 04             	sub    $0x4,%esp
  8000ac:	6a 04                	push   $0x4
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
  8000b0:	e8 65 16 00 00       	call   80171a <readn>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 f8 04             	cmp    $0x4,%eax
  8000bb:	75 8e                	jne    80004b <primeproc+0x18>
	cprintf("%d\n", p);
  8000bd:	83 ec 08             	sub    $0x8,%esp
  8000c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000c3:	68 81 25 80 00       	push   $0x802581
  8000c8:	e8 bf 02 00 00       	call   80038c <cprintf>
	if ((i=pipe(pfd)) < 0)
  8000cd:	89 3c 24             	mov    %edi,(%esp)
  8000d0:	e8 02 1d 00 00       	call   801dd7 <pipe>
  8000d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000d8:	83 c4 10             	add    $0x10,%esp
  8000db:	85 c0                	test   %eax,%eax
  8000dd:	78 8c                	js     80006b <primeproc+0x38>
	if ((id = fork()) < 0)
  8000df:	e8 4b 11 00 00       	call   80122f <fork>
  8000e4:	85 c0                	test   %eax,%eax
  8000e6:	78 95                	js     80007d <primeproc+0x4a>
	if (id == 0) {
  8000e8:	74 a5                	je     80008f <primeproc+0x5c>
	}

	close(pfd[0]);
  8000ea:	83 ec 0c             	sub    $0xc,%esp
  8000ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f0:	e8 50 14 00 00       	call   801545 <close>
	wfd = pfd[1];
  8000f5:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f8:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fb:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	6a 04                	push   $0x4
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
  800105:	e8 10 16 00 00       	call   80171a <readn>
  80010a:	83 c4 10             	add    $0x10,%esp
  80010d:	83 f8 04             	cmp    $0x4,%eax
  800110:	75 42                	jne    800154 <primeproc+0x121>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
		if (i%p)
  800112:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800115:	99                   	cltd   
  800116:	f7 7d e0             	idivl  -0x20(%ebp)
  800119:	85 d2                	test   %edx,%edx
  80011b:	74 e1                	je     8000fe <primeproc+0xcb>
			if ((r=write(wfd, &i, 4)) != 4)
  80011d:	83 ec 04             	sub    $0x4,%esp
  800120:	6a 04                	push   $0x4
  800122:	56                   	push   %esi
  800123:	57                   	push   %edi
  800124:	e8 3c 16 00 00       	call   801765 <write>
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	83 f8 04             	cmp    $0x4,%eax
  80012f:	74 cd                	je     8000fe <primeproc+0xcb>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800131:	83 ec 08             	sub    $0x8,%esp
  800134:	85 c0                	test   %eax,%eax
  800136:	ba 00 00 00 00       	mov    $0x0,%edx
  80013b:	0f 4e d0             	cmovle %eax,%edx
  80013e:	52                   	push   %edx
  80013f:	50                   	push   %eax
  800140:	ff 75 e0             	pushl  -0x20(%ebp)
  800143:	68 b3 25 80 00       	push   $0x8025b3
  800148:	6a 2e                	push   $0x2e
  80014a:	68 6f 25 80 00       	push   $0x80256f
  80014f:	e8 51 01 00 00       	call   8002a5 <_panic>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800154:	83 ec 04             	sub    $0x4,%esp
  800157:	85 c0                	test   %eax,%eax
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	0f 4e d0             	cmovle %eax,%edx
  800161:	52                   	push   %edx
  800162:	50                   	push   %eax
  800163:	53                   	push   %ebx
  800164:	ff 75 e0             	pushl  -0x20(%ebp)
  800167:	68 97 25 80 00       	push   $0x802597
  80016c:	6a 2b                	push   $0x2b
  80016e:	68 6f 25 80 00       	push   $0x80256f
  800173:	e8 2d 01 00 00       	call   8002a5 <_panic>

00800178 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800178:	f3 0f 1e fb          	endbr32 
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	53                   	push   %ebx
  800180:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800183:	c7 05 00 30 80 00 cd 	movl   $0x8025cd,0x803000
  80018a:	25 80 00 

	if ((i=pipe(p)) < 0)
  80018d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800190:	50                   	push   %eax
  800191:	e8 41 1c 00 00       	call   801dd7 <pipe>
  800196:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800199:	83 c4 10             	add    $0x10,%esp
  80019c:	85 c0                	test   %eax,%eax
  80019e:	78 21                	js     8001c1 <umain+0x49>
		panic("pipe: %e", i);

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001a0:	e8 8a 10 00 00       	call   80122f <fork>
  8001a5:	85 c0                	test   %eax,%eax
  8001a7:	78 2a                	js     8001d3 <umain+0x5b>
		panic("fork: %e", id);

	if (id == 0) {
  8001a9:	75 3a                	jne    8001e5 <umain+0x6d>
		close(p[1]);
  8001ab:	83 ec 0c             	sub    $0xc,%esp
  8001ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8001b1:	e8 8f 13 00 00       	call   801545 <close>
		primeproc(p[0]);
  8001b6:	83 c4 04             	add    $0x4,%esp
  8001b9:	ff 75 ec             	pushl  -0x14(%ebp)
  8001bc:	e8 72 fe ff ff       	call   800033 <primeproc>
		panic("pipe: %e", i);
  8001c1:	50                   	push   %eax
  8001c2:	68 85 25 80 00       	push   $0x802585
  8001c7:	6a 3a                	push   $0x3a
  8001c9:	68 6f 25 80 00       	push   $0x80256f
  8001ce:	e8 d2 00 00 00       	call   8002a5 <_panic>
		panic("fork: %e", id);
  8001d3:	50                   	push   %eax
  8001d4:	68 8e 25 80 00       	push   $0x80258e
  8001d9:	6a 3e                	push   $0x3e
  8001db:	68 6f 25 80 00       	push   $0x80256f
  8001e0:	e8 c0 00 00 00       	call   8002a5 <_panic>
	}

	close(p[0]);
  8001e5:	83 ec 0c             	sub    $0xc,%esp
  8001e8:	ff 75 ec             	pushl  -0x14(%ebp)
  8001eb:	e8 55 13 00 00       	call   801545 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001f0:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f7:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001fa:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	6a 04                	push   $0x4
  800202:	53                   	push   %ebx
  800203:	ff 75 f0             	pushl  -0x10(%ebp)
  800206:	e8 5a 15 00 00       	call   801765 <write>
  80020b:	83 c4 10             	add    $0x10,%esp
  80020e:	83 f8 04             	cmp    $0x4,%eax
  800211:	75 06                	jne    800219 <umain+0xa1>
	for (i=2;; i++)
  800213:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
  800217:	eb e4                	jmp    8001fd <umain+0x85>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800219:	83 ec 0c             	sub    $0xc,%esp
  80021c:	85 c0                	test   %eax,%eax
  80021e:	ba 00 00 00 00       	mov    $0x0,%edx
  800223:	0f 4e d0             	cmovle %eax,%edx
  800226:	52                   	push   %edx
  800227:	50                   	push   %eax
  800228:	68 d8 25 80 00       	push   $0x8025d8
  80022d:	6a 4a                	push   $0x4a
  80022f:	68 6f 25 80 00       	push   $0x80256f
  800234:	e8 6c 00 00 00       	call   8002a5 <_panic>

00800239 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800239:	f3 0f 1e fb          	endbr32 
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	56                   	push   %esi
  800241:	53                   	push   %ebx
  800242:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800245:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800248:	e8 de 0a 00 00       	call   800d2b <sys_getenvid>
	if (id >= 0)
  80024d:	85 c0                	test   %eax,%eax
  80024f:	78 12                	js     800263 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800251:	25 ff 03 00 00       	and    $0x3ff,%eax
  800256:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800259:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80025e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800263:	85 db                	test   %ebx,%ebx
  800265:	7e 07                	jle    80026e <libmain+0x35>
		binaryname = argv[0];
  800267:	8b 06                	mov    (%esi),%eax
  800269:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80026e:	83 ec 08             	sub    $0x8,%esp
  800271:	56                   	push   %esi
  800272:	53                   	push   %ebx
  800273:	e8 00 ff ff ff       	call   800178 <umain>

	// exit gracefully
	exit();
  800278:	e8 0a 00 00 00       	call   800287 <exit>
}
  80027d:	83 c4 10             	add    $0x10,%esp
  800280:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800283:	5b                   	pop    %ebx
  800284:	5e                   	pop    %esi
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    

00800287 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800287:	f3 0f 1e fb          	endbr32 
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800291:	e8 e0 12 00 00       	call   801576 <close_all>
	sys_env_destroy(0);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	6a 00                	push   $0x0
  80029b:	e8 65 0a 00 00       	call   800d05 <sys_env_destroy>
}
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a5:	f3 0f 1e fb          	endbr32 
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	56                   	push   %esi
  8002ad:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002ae:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002b1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002b7:	e8 6f 0a 00 00       	call   800d2b <sys_getenvid>
  8002bc:	83 ec 0c             	sub    $0xc,%esp
  8002bf:	ff 75 0c             	pushl  0xc(%ebp)
  8002c2:	ff 75 08             	pushl  0x8(%ebp)
  8002c5:	56                   	push   %esi
  8002c6:	50                   	push   %eax
  8002c7:	68 fc 25 80 00       	push   $0x8025fc
  8002cc:	e8 bb 00 00 00       	call   80038c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002d1:	83 c4 18             	add    $0x18,%esp
  8002d4:	53                   	push   %ebx
  8002d5:	ff 75 10             	pushl  0x10(%ebp)
  8002d8:	e8 5a 00 00 00       	call   800337 <vcprintf>
	cprintf("\n");
  8002dd:	c7 04 24 83 25 80 00 	movl   $0x802583,(%esp)
  8002e4:	e8 a3 00 00 00       	call   80038c <cprintf>
  8002e9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002ec:	cc                   	int3   
  8002ed:	eb fd                	jmp    8002ec <_panic+0x47>

008002ef <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002ef:	f3 0f 1e fb          	endbr32 
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	53                   	push   %ebx
  8002f7:	83 ec 04             	sub    $0x4,%esp
  8002fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002fd:	8b 13                	mov    (%ebx),%edx
  8002ff:	8d 42 01             	lea    0x1(%edx),%eax
  800302:	89 03                	mov    %eax,(%ebx)
  800304:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800307:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80030b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800310:	74 09                	je     80031b <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800312:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800316:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800319:	c9                   	leave  
  80031a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80031b:	83 ec 08             	sub    $0x8,%esp
  80031e:	68 ff 00 00 00       	push   $0xff
  800323:	8d 43 08             	lea    0x8(%ebx),%eax
  800326:	50                   	push   %eax
  800327:	e8 87 09 00 00       	call   800cb3 <sys_cputs>
		b->idx = 0;
  80032c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800332:	83 c4 10             	add    $0x10,%esp
  800335:	eb db                	jmp    800312 <putch+0x23>

00800337 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800337:	f3 0f 1e fb          	endbr32 
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800344:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80034b:	00 00 00 
	b.cnt = 0;
  80034e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800355:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800358:	ff 75 0c             	pushl  0xc(%ebp)
  80035b:	ff 75 08             	pushl  0x8(%ebp)
  80035e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800364:	50                   	push   %eax
  800365:	68 ef 02 80 00       	push   $0x8002ef
  80036a:	e8 80 01 00 00       	call   8004ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80036f:	83 c4 08             	add    $0x8,%esp
  800372:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800378:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80037e:	50                   	push   %eax
  80037f:	e8 2f 09 00 00       	call   800cb3 <sys_cputs>

	return b.cnt;
}
  800384:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80038a:	c9                   	leave  
  80038b:	c3                   	ret    

0080038c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80038c:	f3 0f 1e fb          	endbr32 
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800396:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800399:	50                   	push   %eax
  80039a:	ff 75 08             	pushl  0x8(%ebp)
  80039d:	e8 95 ff ff ff       	call   800337 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003a2:	c9                   	leave  
  8003a3:	c3                   	ret    

008003a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	57                   	push   %edi
  8003a8:	56                   	push   %esi
  8003a9:	53                   	push   %ebx
  8003aa:	83 ec 1c             	sub    $0x1c,%esp
  8003ad:	89 c7                	mov    %eax,%edi
  8003af:	89 d6                	mov    %edx,%esi
  8003b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b7:	89 d1                	mov    %edx,%ecx
  8003b9:	89 c2                	mov    %eax,%edx
  8003bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003d1:	39 c2                	cmp    %eax,%edx
  8003d3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8003d6:	72 3e                	jb     800416 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003d8:	83 ec 0c             	sub    $0xc,%esp
  8003db:	ff 75 18             	pushl  0x18(%ebp)
  8003de:	83 eb 01             	sub    $0x1,%ebx
  8003e1:	53                   	push   %ebx
  8003e2:	50                   	push   %eax
  8003e3:	83 ec 08             	sub    $0x8,%esp
  8003e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f2:	e8 d9 1e 00 00       	call   8022d0 <__udivdi3>
  8003f7:	83 c4 18             	add    $0x18,%esp
  8003fa:	52                   	push   %edx
  8003fb:	50                   	push   %eax
  8003fc:	89 f2                	mov    %esi,%edx
  8003fe:	89 f8                	mov    %edi,%eax
  800400:	e8 9f ff ff ff       	call   8003a4 <printnum>
  800405:	83 c4 20             	add    $0x20,%esp
  800408:	eb 13                	jmp    80041d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80040a:	83 ec 08             	sub    $0x8,%esp
  80040d:	56                   	push   %esi
  80040e:	ff 75 18             	pushl  0x18(%ebp)
  800411:	ff d7                	call   *%edi
  800413:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800416:	83 eb 01             	sub    $0x1,%ebx
  800419:	85 db                	test   %ebx,%ebx
  80041b:	7f ed                	jg     80040a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	56                   	push   %esi
  800421:	83 ec 04             	sub    $0x4,%esp
  800424:	ff 75 e4             	pushl  -0x1c(%ebp)
  800427:	ff 75 e0             	pushl  -0x20(%ebp)
  80042a:	ff 75 dc             	pushl  -0x24(%ebp)
  80042d:	ff 75 d8             	pushl  -0x28(%ebp)
  800430:	e8 ab 1f 00 00       	call   8023e0 <__umoddi3>
  800435:	83 c4 14             	add    $0x14,%esp
  800438:	0f be 80 1f 26 80 00 	movsbl 0x80261f(%eax),%eax
  80043f:	50                   	push   %eax
  800440:	ff d7                	call   *%edi
}
  800442:	83 c4 10             	add    $0x10,%esp
  800445:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800448:	5b                   	pop    %ebx
  800449:	5e                   	pop    %esi
  80044a:	5f                   	pop    %edi
  80044b:	5d                   	pop    %ebp
  80044c:	c3                   	ret    

0080044d <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80044d:	83 fa 01             	cmp    $0x1,%edx
  800450:	7f 13                	jg     800465 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800452:	85 d2                	test   %edx,%edx
  800454:	74 1c                	je     800472 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800456:	8b 10                	mov    (%eax),%edx
  800458:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045b:	89 08                	mov    %ecx,(%eax)
  80045d:	8b 02                	mov    (%edx),%eax
  80045f:	ba 00 00 00 00       	mov    $0x0,%edx
  800464:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800465:	8b 10                	mov    (%eax),%edx
  800467:	8d 4a 08             	lea    0x8(%edx),%ecx
  80046a:	89 08                	mov    %ecx,(%eax)
  80046c:	8b 02                	mov    (%edx),%eax
  80046e:	8b 52 04             	mov    0x4(%edx),%edx
  800471:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800472:	8b 10                	mov    (%eax),%edx
  800474:	8d 4a 04             	lea    0x4(%edx),%ecx
  800477:	89 08                	mov    %ecx,(%eax)
  800479:	8b 02                	mov    (%edx),%eax
  80047b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800480:	c3                   	ret    

00800481 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800481:	83 fa 01             	cmp    $0x1,%edx
  800484:	7f 0f                	jg     800495 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800486:	85 d2                	test   %edx,%edx
  800488:	74 18                	je     8004a2 <getint+0x21>
		return va_arg(*ap, long);
  80048a:	8b 10                	mov    (%eax),%edx
  80048c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80048f:	89 08                	mov    %ecx,(%eax)
  800491:	8b 02                	mov    (%edx),%eax
  800493:	99                   	cltd   
  800494:	c3                   	ret    
		return va_arg(*ap, long long);
  800495:	8b 10                	mov    (%eax),%edx
  800497:	8d 4a 08             	lea    0x8(%edx),%ecx
  80049a:	89 08                	mov    %ecx,(%eax)
  80049c:	8b 02                	mov    (%edx),%eax
  80049e:	8b 52 04             	mov    0x4(%edx),%edx
  8004a1:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8004a2:	8b 10                	mov    (%eax),%edx
  8004a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a7:	89 08                	mov    %ecx,(%eax)
  8004a9:	8b 02                	mov    (%edx),%eax
  8004ab:	99                   	cltd   
}
  8004ac:	c3                   	ret    

008004ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ad:	f3 0f 1e fb          	endbr32 
  8004b1:	55                   	push   %ebp
  8004b2:	89 e5                	mov    %esp,%ebp
  8004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004bb:	8b 10                	mov    (%eax),%edx
  8004bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c0:	73 0a                	jae    8004cc <sprintputch+0x1f>
		*b->buf++ = ch;
  8004c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c5:	89 08                	mov    %ecx,(%eax)
  8004c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ca:	88 02                	mov    %al,(%edx)
}
  8004cc:	5d                   	pop    %ebp
  8004cd:	c3                   	ret    

008004ce <printfmt>:
{
  8004ce:	f3 0f 1e fb          	endbr32 
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004db:	50                   	push   %eax
  8004dc:	ff 75 10             	pushl  0x10(%ebp)
  8004df:	ff 75 0c             	pushl  0xc(%ebp)
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 05 00 00 00       	call   8004ef <vprintfmt>
}
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	c9                   	leave  
  8004ee:	c3                   	ret    

008004ef <vprintfmt>:
{
  8004ef:	f3 0f 1e fb          	endbr32 
  8004f3:	55                   	push   %ebp
  8004f4:	89 e5                	mov    %esp,%ebp
  8004f6:	57                   	push   %edi
  8004f7:	56                   	push   %esi
  8004f8:	53                   	push   %ebx
  8004f9:	83 ec 2c             	sub    $0x2c,%esp
  8004fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004ff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800502:	8b 7d 10             	mov    0x10(%ebp),%edi
  800505:	e9 86 02 00 00       	jmp    800790 <vprintfmt+0x2a1>
		padc = ' ';
  80050a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80050e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800515:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80051c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800523:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8d 47 01             	lea    0x1(%edi),%eax
  80052b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80052e:	0f b6 17             	movzbl (%edi),%edx
  800531:	8d 42 dd             	lea    -0x23(%edx),%eax
  800534:	3c 55                	cmp    $0x55,%al
  800536:	0f 87 df 02 00 00    	ja     80081b <vprintfmt+0x32c>
  80053c:	0f b6 c0             	movzbl %al,%eax
  80053f:	3e ff 24 85 60 27 80 	notrack jmp *0x802760(,%eax,4)
  800546:	00 
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80054a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80054e:	eb d8                	jmp    800528 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800553:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800557:	eb cf                	jmp    800528 <vprintfmt+0x39>
  800559:	0f b6 d2             	movzbl %dl,%edx
  80055c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80055f:	b8 00 00 00 00       	mov    $0x0,%eax
  800564:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800567:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80056a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80056e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800571:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800574:	83 f9 09             	cmp    $0x9,%ecx
  800577:	77 52                	ja     8005cb <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800579:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80057c:	eb e9                	jmp    800567 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 50 04             	lea    0x4(%eax),%edx
  800584:	89 55 14             	mov    %edx,0x14(%ebp)
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80058c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80058f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800593:	79 93                	jns    800528 <vprintfmt+0x39>
				width = precision, precision = -1;
  800595:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800598:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005a2:	eb 84                	jmp    800528 <vprintfmt+0x39>
  8005a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ae:	0f 49 d0             	cmovns %eax,%edx
  8005b1:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005b7:	e9 6c ff ff ff       	jmp    800528 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005bf:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005c6:	e9 5d ff ff ff       	jmp    800528 <vprintfmt+0x39>
  8005cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ce:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005d1:	eb bc                	jmp    80058f <vprintfmt+0xa0>
			lflag++;
  8005d3:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005d9:	e9 4a ff ff ff       	jmp    800528 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 04             	lea    0x4(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	56                   	push   %esi
  8005eb:	ff 30                	pushl  (%eax)
  8005ed:	ff d3                	call   *%ebx
			break;
  8005ef:	83 c4 10             	add    $0x10,%esp
  8005f2:	e9 96 01 00 00       	jmp    80078d <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 50 04             	lea    0x4(%eax),%edx
  8005fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800600:	8b 00                	mov    (%eax),%eax
  800602:	99                   	cltd   
  800603:	31 d0                	xor    %edx,%eax
  800605:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800607:	83 f8 0f             	cmp    $0xf,%eax
  80060a:	7f 20                	jg     80062c <vprintfmt+0x13d>
  80060c:	8b 14 85 c0 28 80 00 	mov    0x8028c0(,%eax,4),%edx
  800613:	85 d2                	test   %edx,%edx
  800615:	74 15                	je     80062c <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800617:	52                   	push   %edx
  800618:	68 c5 2b 80 00       	push   $0x802bc5
  80061d:	56                   	push   %esi
  80061e:	53                   	push   %ebx
  80061f:	e8 aa fe ff ff       	call   8004ce <printfmt>
  800624:	83 c4 10             	add    $0x10,%esp
  800627:	e9 61 01 00 00       	jmp    80078d <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80062c:	50                   	push   %eax
  80062d:	68 37 26 80 00       	push   $0x802637
  800632:	56                   	push   %esi
  800633:	53                   	push   %ebx
  800634:	e8 95 fe ff ff       	call   8004ce <printfmt>
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	e9 4c 01 00 00       	jmp    80078d <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8d 50 04             	lea    0x4(%eax),%edx
  800647:	89 55 14             	mov    %edx,0x14(%ebp)
  80064a:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80064c:	85 c9                	test   %ecx,%ecx
  80064e:	b8 30 26 80 00       	mov    $0x802630,%eax
  800653:	0f 45 c1             	cmovne %ecx,%eax
  800656:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800659:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80065d:	7e 06                	jle    800665 <vprintfmt+0x176>
  80065f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800663:	75 0d                	jne    800672 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800665:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800668:	89 c7                	mov    %eax,%edi
  80066a:	03 45 e0             	add    -0x20(%ebp),%eax
  80066d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800670:	eb 57                	jmp    8006c9 <vprintfmt+0x1da>
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	ff 75 d8             	pushl  -0x28(%ebp)
  800678:	ff 75 cc             	pushl  -0x34(%ebp)
  80067b:	e8 4f 02 00 00       	call   8008cf <strnlen>
  800680:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800683:	29 c2                	sub    %eax,%edx
  800685:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800688:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80068b:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80068f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800692:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800694:	85 db                	test   %ebx,%ebx
  800696:	7e 10                	jle    8006a8 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	56                   	push   %esi
  80069c:	57                   	push   %edi
  80069d:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a0:	83 eb 01             	sub    $0x1,%ebx
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb ec                	jmp    800694 <vprintfmt+0x1a5>
  8006a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8006ab:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006ae:	85 d2                	test   %edx,%edx
  8006b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b5:	0f 49 c2             	cmovns %edx,%eax
  8006b8:	29 c2                	sub    %eax,%edx
  8006ba:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006bd:	eb a6                	jmp    800665 <vprintfmt+0x176>
					putch(ch, putdat);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	56                   	push   %esi
  8006c3:	52                   	push   %edx
  8006c4:	ff d3                	call   *%ebx
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006cc:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ce:	83 c7 01             	add    $0x1,%edi
  8006d1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006d5:	0f be d0             	movsbl %al,%edx
  8006d8:	85 d2                	test   %edx,%edx
  8006da:	74 42                	je     80071e <vprintfmt+0x22f>
  8006dc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006e0:	78 06                	js     8006e8 <vprintfmt+0x1f9>
  8006e2:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8006e6:	78 1e                	js     800706 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8006e8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006ec:	74 d1                	je     8006bf <vprintfmt+0x1d0>
  8006ee:	0f be c0             	movsbl %al,%eax
  8006f1:	83 e8 20             	sub    $0x20,%eax
  8006f4:	83 f8 5e             	cmp    $0x5e,%eax
  8006f7:	76 c6                	jbe    8006bf <vprintfmt+0x1d0>
					putch('?', putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	56                   	push   %esi
  8006fd:	6a 3f                	push   $0x3f
  8006ff:	ff d3                	call   *%ebx
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	eb c3                	jmp    8006c9 <vprintfmt+0x1da>
  800706:	89 cf                	mov    %ecx,%edi
  800708:	eb 0e                	jmp    800718 <vprintfmt+0x229>
				putch(' ', putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	56                   	push   %esi
  80070e:	6a 20                	push   $0x20
  800710:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800712:	83 ef 01             	sub    $0x1,%edi
  800715:	83 c4 10             	add    $0x10,%esp
  800718:	85 ff                	test   %edi,%edi
  80071a:	7f ee                	jg     80070a <vprintfmt+0x21b>
  80071c:	eb 6f                	jmp    80078d <vprintfmt+0x29e>
  80071e:	89 cf                	mov    %ecx,%edi
  800720:	eb f6                	jmp    800718 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800722:	89 ca                	mov    %ecx,%edx
  800724:	8d 45 14             	lea    0x14(%ebp),%eax
  800727:	e8 55 fd ff ff       	call   800481 <getint>
  80072c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800732:	85 d2                	test   %edx,%edx
  800734:	78 0b                	js     800741 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800736:	89 d1                	mov    %edx,%ecx
  800738:	89 c2                	mov    %eax,%edx
			base = 10;
  80073a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80073f:	eb 32                	jmp    800773 <vprintfmt+0x284>
				putch('-', putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	56                   	push   %esi
  800745:	6a 2d                	push   $0x2d
  800747:	ff d3                	call   *%ebx
				num = -(long long) num;
  800749:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80074c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80074f:	f7 da                	neg    %edx
  800751:	83 d1 00             	adc    $0x0,%ecx
  800754:	f7 d9                	neg    %ecx
  800756:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800759:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075e:	eb 13                	jmp    800773 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800760:	89 ca                	mov    %ecx,%edx
  800762:	8d 45 14             	lea    0x14(%ebp),%eax
  800765:	e8 e3 fc ff ff       	call   80044d <getuint>
  80076a:	89 d1                	mov    %edx,%ecx
  80076c:	89 c2                	mov    %eax,%edx
			base = 10;
  80076e:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800773:	83 ec 0c             	sub    $0xc,%esp
  800776:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80077a:	57                   	push   %edi
  80077b:	ff 75 e0             	pushl  -0x20(%ebp)
  80077e:	50                   	push   %eax
  80077f:	51                   	push   %ecx
  800780:	52                   	push   %edx
  800781:	89 f2                	mov    %esi,%edx
  800783:	89 d8                	mov    %ebx,%eax
  800785:	e8 1a fc ff ff       	call   8003a4 <printnum>
			break;
  80078a:	83 c4 20             	add    $0x20,%esp
{
  80078d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800790:	83 c7 01             	add    $0x1,%edi
  800793:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800797:	83 f8 25             	cmp    $0x25,%eax
  80079a:	0f 84 6a fd ff ff    	je     80050a <vprintfmt+0x1b>
			if (ch == '\0')
  8007a0:	85 c0                	test   %eax,%eax
  8007a2:	0f 84 93 00 00 00    	je     80083b <vprintfmt+0x34c>
			putch(ch, putdat);
  8007a8:	83 ec 08             	sub    $0x8,%esp
  8007ab:	56                   	push   %esi
  8007ac:	50                   	push   %eax
  8007ad:	ff d3                	call   *%ebx
  8007af:	83 c4 10             	add    $0x10,%esp
  8007b2:	eb dc                	jmp    800790 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8007b4:	89 ca                	mov    %ecx,%edx
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b9:	e8 8f fc ff ff       	call   80044d <getuint>
  8007be:	89 d1                	mov    %edx,%ecx
  8007c0:	89 c2                	mov    %eax,%edx
			base = 8;
  8007c2:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007c7:	eb aa                	jmp    800773 <vprintfmt+0x284>
			putch('0', putdat);
  8007c9:	83 ec 08             	sub    $0x8,%esp
  8007cc:	56                   	push   %esi
  8007cd:	6a 30                	push   $0x30
  8007cf:	ff d3                	call   *%ebx
			putch('x', putdat);
  8007d1:	83 c4 08             	add    $0x8,%esp
  8007d4:	56                   	push   %esi
  8007d5:	6a 78                	push   $0x78
  8007d7:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8007d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dc:	8d 50 04             	lea    0x4(%eax),%edx
  8007df:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8007e2:	8b 10                	mov    (%eax),%edx
  8007e4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007e9:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8007ec:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007f1:	eb 80                	jmp    800773 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8007f3:	89 ca                	mov    %ecx,%edx
  8007f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f8:	e8 50 fc ff ff       	call   80044d <getuint>
  8007fd:	89 d1                	mov    %edx,%ecx
  8007ff:	89 c2                	mov    %eax,%edx
			base = 16;
  800801:	b8 10 00 00 00       	mov    $0x10,%eax
  800806:	e9 68 ff ff ff       	jmp    800773 <vprintfmt+0x284>
			putch(ch, putdat);
  80080b:	83 ec 08             	sub    $0x8,%esp
  80080e:	56                   	push   %esi
  80080f:	6a 25                	push   $0x25
  800811:	ff d3                	call   *%ebx
			break;
  800813:	83 c4 10             	add    $0x10,%esp
  800816:	e9 72 ff ff ff       	jmp    80078d <vprintfmt+0x29e>
			putch('%', putdat);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	56                   	push   %esi
  80081f:	6a 25                	push   $0x25
  800821:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	89 f8                	mov    %edi,%eax
  800828:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80082c:	74 05                	je     800833 <vprintfmt+0x344>
  80082e:	83 e8 01             	sub    $0x1,%eax
  800831:	eb f5                	jmp    800828 <vprintfmt+0x339>
  800833:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800836:	e9 52 ff ff ff       	jmp    80078d <vprintfmt+0x29e>
}
  80083b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80083e:	5b                   	pop    %ebx
  80083f:	5e                   	pop    %esi
  800840:	5f                   	pop    %edi
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800843:	f3 0f 1e fb          	endbr32 
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	83 ec 18             	sub    $0x18,%esp
  80084d:	8b 45 08             	mov    0x8(%ebp),%eax
  800850:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800853:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800856:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80085a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80085d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800864:	85 c0                	test   %eax,%eax
  800866:	74 26                	je     80088e <vsnprintf+0x4b>
  800868:	85 d2                	test   %edx,%edx
  80086a:	7e 22                	jle    80088e <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80086c:	ff 75 14             	pushl  0x14(%ebp)
  80086f:	ff 75 10             	pushl  0x10(%ebp)
  800872:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800875:	50                   	push   %eax
  800876:	68 ad 04 80 00       	push   $0x8004ad
  80087b:	e8 6f fc ff ff       	call   8004ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800880:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800883:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800889:	83 c4 10             	add    $0x10,%esp
}
  80088c:	c9                   	leave  
  80088d:	c3                   	ret    
		return -E_INVAL;
  80088e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800893:	eb f7                	jmp    80088c <vsnprintf+0x49>

00800895 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800895:	f3 0f 1e fb          	endbr32 
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a2:	50                   	push   %eax
  8008a3:	ff 75 10             	pushl  0x10(%ebp)
  8008a6:	ff 75 0c             	pushl  0xc(%ebp)
  8008a9:	ff 75 08             	pushl  0x8(%ebp)
  8008ac:	e8 92 ff ff ff       	call   800843 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b1:	c9                   	leave  
  8008b2:	c3                   	ret    

008008b3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b3:	f3 0f 1e fb          	endbr32 
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c6:	74 05                	je     8008cd <strlen+0x1a>
		n++;
  8008c8:	83 c0 01             	add    $0x1,%eax
  8008cb:	eb f5                	jmp    8008c2 <strlen+0xf>
	return n;
}
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008cf:	f3 0f 1e fb          	endbr32 
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e1:	39 d0                	cmp    %edx,%eax
  8008e3:	74 0d                	je     8008f2 <strnlen+0x23>
  8008e5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e9:	74 05                	je     8008f0 <strnlen+0x21>
		n++;
  8008eb:	83 c0 01             	add    $0x1,%eax
  8008ee:	eb f1                	jmp    8008e1 <strnlen+0x12>
  8008f0:	89 c2                	mov    %eax,%edx
	return n;
}
  8008f2:	89 d0                	mov    %edx,%eax
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f6:	f3 0f 1e fb          	endbr32 
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	53                   	push   %ebx
  8008fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800901:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800904:	b8 00 00 00 00       	mov    $0x0,%eax
  800909:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80090d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800910:	83 c0 01             	add    $0x1,%eax
  800913:	84 d2                	test   %dl,%dl
  800915:	75 f2                	jne    800909 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800917:	89 c8                	mov    %ecx,%eax
  800919:	5b                   	pop    %ebx
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80091c:	f3 0f 1e fb          	endbr32 
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	53                   	push   %ebx
  800924:	83 ec 10             	sub    $0x10,%esp
  800927:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80092a:	53                   	push   %ebx
  80092b:	e8 83 ff ff ff       	call   8008b3 <strlen>
  800930:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800933:	ff 75 0c             	pushl  0xc(%ebp)
  800936:	01 d8                	add    %ebx,%eax
  800938:	50                   	push   %eax
  800939:	e8 b8 ff ff ff       	call   8008f6 <strcpy>
	return dst;
}
  80093e:	89 d8                	mov    %ebx,%eax
  800940:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800945:	f3 0f 1e fb          	endbr32 
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	56                   	push   %esi
  80094d:	53                   	push   %ebx
  80094e:	8b 75 08             	mov    0x8(%ebp),%esi
  800951:	8b 55 0c             	mov    0xc(%ebp),%edx
  800954:	89 f3                	mov    %esi,%ebx
  800956:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800959:	89 f0                	mov    %esi,%eax
  80095b:	39 d8                	cmp    %ebx,%eax
  80095d:	74 11                	je     800970 <strncpy+0x2b>
		*dst++ = *src;
  80095f:	83 c0 01             	add    $0x1,%eax
  800962:	0f b6 0a             	movzbl (%edx),%ecx
  800965:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800968:	80 f9 01             	cmp    $0x1,%cl
  80096b:	83 da ff             	sbb    $0xffffffff,%edx
  80096e:	eb eb                	jmp    80095b <strncpy+0x16>
	}
	return ret;
}
  800970:	89 f0                	mov    %esi,%eax
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800976:	f3 0f 1e fb          	endbr32 
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	56                   	push   %esi
  80097e:	53                   	push   %ebx
  80097f:	8b 75 08             	mov    0x8(%ebp),%esi
  800982:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800985:	8b 55 10             	mov    0x10(%ebp),%edx
  800988:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80098a:	85 d2                	test   %edx,%edx
  80098c:	74 21                	je     8009af <strlcpy+0x39>
  80098e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800992:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800994:	39 c2                	cmp    %eax,%edx
  800996:	74 14                	je     8009ac <strlcpy+0x36>
  800998:	0f b6 19             	movzbl (%ecx),%ebx
  80099b:	84 db                	test   %bl,%bl
  80099d:	74 0b                	je     8009aa <strlcpy+0x34>
			*dst++ = *src++;
  80099f:	83 c1 01             	add    $0x1,%ecx
  8009a2:	83 c2 01             	add    $0x1,%edx
  8009a5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009a8:	eb ea                	jmp    800994 <strlcpy+0x1e>
  8009aa:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009ac:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009af:	29 f0                	sub    %esi,%eax
}
  8009b1:	5b                   	pop    %ebx
  8009b2:	5e                   	pop    %esi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009b5:	f3 0f 1e fb          	endbr32 
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009c2:	0f b6 01             	movzbl (%ecx),%eax
  8009c5:	84 c0                	test   %al,%al
  8009c7:	74 0c                	je     8009d5 <strcmp+0x20>
  8009c9:	3a 02                	cmp    (%edx),%al
  8009cb:	75 08                	jne    8009d5 <strcmp+0x20>
		p++, q++;
  8009cd:	83 c1 01             	add    $0x1,%ecx
  8009d0:	83 c2 01             	add    $0x1,%edx
  8009d3:	eb ed                	jmp    8009c2 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d5:	0f b6 c0             	movzbl %al,%eax
  8009d8:	0f b6 12             	movzbl (%edx),%edx
  8009db:	29 d0                	sub    %edx,%eax
}
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009df:	f3 0f 1e fb          	endbr32 
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	53                   	push   %ebx
  8009e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ed:	89 c3                	mov    %eax,%ebx
  8009ef:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009f2:	eb 06                	jmp    8009fa <strncmp+0x1b>
		n--, p++, q++;
  8009f4:	83 c0 01             	add    $0x1,%eax
  8009f7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009fa:	39 d8                	cmp    %ebx,%eax
  8009fc:	74 16                	je     800a14 <strncmp+0x35>
  8009fe:	0f b6 08             	movzbl (%eax),%ecx
  800a01:	84 c9                	test   %cl,%cl
  800a03:	74 04                	je     800a09 <strncmp+0x2a>
  800a05:	3a 0a                	cmp    (%edx),%cl
  800a07:	74 eb                	je     8009f4 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a09:	0f b6 00             	movzbl (%eax),%eax
  800a0c:	0f b6 12             	movzbl (%edx),%edx
  800a0f:	29 d0                	sub    %edx,%eax
}
  800a11:	5b                   	pop    %ebx
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    
		return 0;
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
  800a19:	eb f6                	jmp    800a11 <strncmp+0x32>

00800a1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a1b:	f3 0f 1e fb          	endbr32 
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a29:	0f b6 10             	movzbl (%eax),%edx
  800a2c:	84 d2                	test   %dl,%dl
  800a2e:	74 09                	je     800a39 <strchr+0x1e>
		if (*s == c)
  800a30:	38 ca                	cmp    %cl,%dl
  800a32:	74 0a                	je     800a3e <strchr+0x23>
	for (; *s; s++)
  800a34:	83 c0 01             	add    $0x1,%eax
  800a37:	eb f0                	jmp    800a29 <strchr+0xe>
			return (char *) s;
	return 0;
  800a39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a40:	f3 0f 1e fb          	endbr32 
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a4e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a51:	38 ca                	cmp    %cl,%dl
  800a53:	74 09                	je     800a5e <strfind+0x1e>
  800a55:	84 d2                	test   %dl,%dl
  800a57:	74 05                	je     800a5e <strfind+0x1e>
	for (; *s; s++)
  800a59:	83 c0 01             	add    $0x1,%eax
  800a5c:	eb f0                	jmp    800a4e <strfind+0xe>
			break;
	return (char *) s;
}
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a60:	f3 0f 1e fb          	endbr32 
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a70:	85 c9                	test   %ecx,%ecx
  800a72:	74 33                	je     800aa7 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a74:	89 d0                	mov    %edx,%eax
  800a76:	09 c8                	or     %ecx,%eax
  800a78:	a8 03                	test   $0x3,%al
  800a7a:	75 23                	jne    800a9f <memset+0x3f>
		c &= 0xFF;
  800a7c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a80:	89 d8                	mov    %ebx,%eax
  800a82:	c1 e0 08             	shl    $0x8,%eax
  800a85:	89 df                	mov    %ebx,%edi
  800a87:	c1 e7 18             	shl    $0x18,%edi
  800a8a:	89 de                	mov    %ebx,%esi
  800a8c:	c1 e6 10             	shl    $0x10,%esi
  800a8f:	09 f7                	or     %esi,%edi
  800a91:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800a93:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a96:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a98:	89 d7                	mov    %edx,%edi
  800a9a:	fc                   	cld    
  800a9b:	f3 ab                	rep stos %eax,%es:(%edi)
  800a9d:	eb 08                	jmp    800aa7 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9f:	89 d7                	mov    %edx,%edi
  800aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa4:	fc                   	cld    
  800aa5:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800aa7:	89 d0                	mov    %edx,%eax
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5f                   	pop    %edi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aae:	f3 0f 1e fb          	endbr32 
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac0:	39 c6                	cmp    %eax,%esi
  800ac2:	73 32                	jae    800af6 <memmove+0x48>
  800ac4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac7:	39 c2                	cmp    %eax,%edx
  800ac9:	76 2b                	jbe    800af6 <memmove+0x48>
		s += n;
		d += n;
  800acb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ace:	89 fe                	mov    %edi,%esi
  800ad0:	09 ce                	or     %ecx,%esi
  800ad2:	09 d6                	or     %edx,%esi
  800ad4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ada:	75 0e                	jne    800aea <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800adc:	83 ef 04             	sub    $0x4,%edi
  800adf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ae2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ae5:	fd                   	std    
  800ae6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae8:	eb 09                	jmp    800af3 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aea:	83 ef 01             	sub    $0x1,%edi
  800aed:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800af0:	fd                   	std    
  800af1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800af3:	fc                   	cld    
  800af4:	eb 1a                	jmp    800b10 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af6:	89 c2                	mov    %eax,%edx
  800af8:	09 ca                	or     %ecx,%edx
  800afa:	09 f2                	or     %esi,%edx
  800afc:	f6 c2 03             	test   $0x3,%dl
  800aff:	75 0a                	jne    800b0b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b01:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b04:	89 c7                	mov    %eax,%edi
  800b06:	fc                   	cld    
  800b07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b09:	eb 05                	jmp    800b10 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	fc                   	cld    
  800b0e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b14:	f3 0f 1e fb          	endbr32 
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b1e:	ff 75 10             	pushl  0x10(%ebp)
  800b21:	ff 75 0c             	pushl  0xc(%ebp)
  800b24:	ff 75 08             	pushl  0x8(%ebp)
  800b27:	e8 82 ff ff ff       	call   800aae <memmove>
}
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2e:	f3 0f 1e fb          	endbr32 
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3d:	89 c6                	mov    %eax,%esi
  800b3f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b42:	39 f0                	cmp    %esi,%eax
  800b44:	74 1c                	je     800b62 <memcmp+0x34>
		if (*s1 != *s2)
  800b46:	0f b6 08             	movzbl (%eax),%ecx
  800b49:	0f b6 1a             	movzbl (%edx),%ebx
  800b4c:	38 d9                	cmp    %bl,%cl
  800b4e:	75 08                	jne    800b58 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b50:	83 c0 01             	add    $0x1,%eax
  800b53:	83 c2 01             	add    $0x1,%edx
  800b56:	eb ea                	jmp    800b42 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800b58:	0f b6 c1             	movzbl %cl,%eax
  800b5b:	0f b6 db             	movzbl %bl,%ebx
  800b5e:	29 d8                	sub    %ebx,%eax
  800b60:	eb 05                	jmp    800b67 <memcmp+0x39>
	}

	return 0;
  800b62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b6b:	f3 0f 1e fb          	endbr32 
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	8b 45 08             	mov    0x8(%ebp),%eax
  800b75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b78:	89 c2                	mov    %eax,%edx
  800b7a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b7d:	39 d0                	cmp    %edx,%eax
  800b7f:	73 09                	jae    800b8a <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b81:	38 08                	cmp    %cl,(%eax)
  800b83:	74 05                	je     800b8a <memfind+0x1f>
	for (; s < ends; s++)
  800b85:	83 c0 01             	add    $0x1,%eax
  800b88:	eb f3                	jmp    800b7d <memfind+0x12>
			break;
	return (void *) s;
}
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b8c:	f3 0f 1e fb          	endbr32 
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
  800b96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b9c:	eb 03                	jmp    800ba1 <strtol+0x15>
		s++;
  800b9e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ba1:	0f b6 01             	movzbl (%ecx),%eax
  800ba4:	3c 20                	cmp    $0x20,%al
  800ba6:	74 f6                	je     800b9e <strtol+0x12>
  800ba8:	3c 09                	cmp    $0x9,%al
  800baa:	74 f2                	je     800b9e <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800bac:	3c 2b                	cmp    $0x2b,%al
  800bae:	74 2a                	je     800bda <strtol+0x4e>
	int neg = 0;
  800bb0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bb5:	3c 2d                	cmp    $0x2d,%al
  800bb7:	74 2b                	je     800be4 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bbf:	75 0f                	jne    800bd0 <strtol+0x44>
  800bc1:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc4:	74 28                	je     800bee <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bc6:	85 db                	test   %ebx,%ebx
  800bc8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bcd:	0f 44 d8             	cmove  %eax,%ebx
  800bd0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bd8:	eb 46                	jmp    800c20 <strtol+0x94>
		s++;
  800bda:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bdd:	bf 00 00 00 00       	mov    $0x0,%edi
  800be2:	eb d5                	jmp    800bb9 <strtol+0x2d>
		s++, neg = 1;
  800be4:	83 c1 01             	add    $0x1,%ecx
  800be7:	bf 01 00 00 00       	mov    $0x1,%edi
  800bec:	eb cb                	jmp    800bb9 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bee:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf2:	74 0e                	je     800c02 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bf4:	85 db                	test   %ebx,%ebx
  800bf6:	75 d8                	jne    800bd0 <strtol+0x44>
		s++, base = 8;
  800bf8:	83 c1 01             	add    $0x1,%ecx
  800bfb:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c00:	eb ce                	jmp    800bd0 <strtol+0x44>
		s += 2, base = 16;
  800c02:	83 c1 02             	add    $0x2,%ecx
  800c05:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c0a:	eb c4                	jmp    800bd0 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c0c:	0f be d2             	movsbl %dl,%edx
  800c0f:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c12:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c15:	7d 3a                	jge    800c51 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c17:	83 c1 01             	add    $0x1,%ecx
  800c1a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c1e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c20:	0f b6 11             	movzbl (%ecx),%edx
  800c23:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c26:	89 f3                	mov    %esi,%ebx
  800c28:	80 fb 09             	cmp    $0x9,%bl
  800c2b:	76 df                	jbe    800c0c <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800c2d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c30:	89 f3                	mov    %esi,%ebx
  800c32:	80 fb 19             	cmp    $0x19,%bl
  800c35:	77 08                	ja     800c3f <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c37:	0f be d2             	movsbl %dl,%edx
  800c3a:	83 ea 57             	sub    $0x57,%edx
  800c3d:	eb d3                	jmp    800c12 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800c3f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c42:	89 f3                	mov    %esi,%ebx
  800c44:	80 fb 19             	cmp    $0x19,%bl
  800c47:	77 08                	ja     800c51 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c49:	0f be d2             	movsbl %dl,%edx
  800c4c:	83 ea 37             	sub    $0x37,%edx
  800c4f:	eb c1                	jmp    800c12 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c55:	74 05                	je     800c5c <strtol+0xd0>
		*endptr = (char *) s;
  800c57:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c5a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c5c:	89 c2                	mov    %eax,%edx
  800c5e:	f7 da                	neg    %edx
  800c60:	85 ff                	test   %edi,%edi
  800c62:	0f 45 c2             	cmovne %edx,%eax
}
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 1c             	sub    $0x1c,%esp
  800c73:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c76:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c79:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c81:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c84:	8b 75 14             	mov    0x14(%ebp),%esi
  800c87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c89:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c8d:	74 04                	je     800c93 <syscall+0x29>
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	7f 08                	jg     800c9b <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800c93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	50                   	push   %eax
  800c9f:	ff 75 e0             	pushl  -0x20(%ebp)
  800ca2:	68 1f 29 80 00       	push   $0x80291f
  800ca7:	6a 23                	push   $0x23
  800ca9:	68 3c 29 80 00       	push   $0x80293c
  800cae:	e8 f2 f5 ff ff       	call   8002a5 <_panic>

00800cb3 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800cb3:	f3 0f 1e fb          	endbr32 
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800cbd:	6a 00                	push   $0x0
  800cbf:	6a 00                	push   $0x0
  800cc1:	6a 00                	push   $0x0
  800cc3:	ff 75 0c             	pushl  0xc(%ebp)
  800cc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cce:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd3:	e8 92 ff ff ff       	call   800c6a <syscall>
}
  800cd8:	83 c4 10             	add    $0x10,%esp
  800cdb:	c9                   	leave  
  800cdc:	c3                   	ret    

00800cdd <sys_cgetc>:

int
sys_cgetc(void)
{
  800cdd:	f3 0f 1e fb          	endbr32 
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ce7:	6a 00                	push   $0x0
  800ce9:	6a 00                	push   $0x0
  800ceb:	6a 00                	push   $0x0
  800ced:	6a 00                	push   $0x0
  800cef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfe:	e8 67 ff ff ff       	call   800c6a <syscall>
}
  800d03:	c9                   	leave  
  800d04:	c3                   	ret    

00800d05 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d05:	f3 0f 1e fb          	endbr32 
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800d0f:	6a 00                	push   $0x0
  800d11:	6a 00                	push   $0x0
  800d13:	6a 00                	push   $0x0
  800d15:	6a 00                	push   $0x0
  800d17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1a:	ba 01 00 00 00       	mov    $0x1,%edx
  800d1f:	b8 03 00 00 00       	mov    $0x3,%eax
  800d24:	e8 41 ff ff ff       	call   800c6a <syscall>
}
  800d29:	c9                   	leave  
  800d2a:	c3                   	ret    

00800d2b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d2b:	f3 0f 1e fb          	endbr32 
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800d35:	6a 00                	push   $0x0
  800d37:	6a 00                	push   $0x0
  800d39:	6a 00                	push   $0x0
  800d3b:	6a 00                	push   $0x0
  800d3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d42:	ba 00 00 00 00       	mov    $0x0,%edx
  800d47:	b8 02 00 00 00       	mov    $0x2,%eax
  800d4c:	e8 19 ff ff ff       	call   800c6a <syscall>
}
  800d51:	c9                   	leave  
  800d52:	c3                   	ret    

00800d53 <sys_yield>:

void
sys_yield(void)
{
  800d53:	f3 0f 1e fb          	endbr32 
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800d5d:	6a 00                	push   $0x0
  800d5f:	6a 00                	push   $0x0
  800d61:	6a 00                	push   $0x0
  800d63:	6a 00                	push   $0x0
  800d65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d74:	e8 f1 fe ff ff       	call   800c6a <syscall>
}
  800d79:	83 c4 10             	add    $0x10,%esp
  800d7c:	c9                   	leave  
  800d7d:	c3                   	ret    

00800d7e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d7e:	f3 0f 1e fb          	endbr32 
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d88:	6a 00                	push   $0x0
  800d8a:	6a 00                	push   $0x0
  800d8c:	ff 75 10             	pushl  0x10(%ebp)
  800d8f:	ff 75 0c             	pushl  0xc(%ebp)
  800d92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d95:	ba 01 00 00 00       	mov    $0x1,%edx
  800d9a:	b8 04 00 00 00       	mov    $0x4,%eax
  800d9f:	e8 c6 fe ff ff       	call   800c6a <syscall>
}
  800da4:	c9                   	leave  
  800da5:	c3                   	ret    

00800da6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800da6:	f3 0f 1e fb          	endbr32 
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800db0:	ff 75 18             	pushl  0x18(%ebp)
  800db3:	ff 75 14             	pushl  0x14(%ebp)
  800db6:	ff 75 10             	pushl  0x10(%ebp)
  800db9:	ff 75 0c             	pushl  0xc(%ebp)
  800dbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dbf:	ba 01 00 00 00       	mov    $0x1,%edx
  800dc4:	b8 05 00 00 00       	mov    $0x5,%eax
  800dc9:	e8 9c fe ff ff       	call   800c6a <syscall>
}
  800dce:	c9                   	leave  
  800dcf:	c3                   	ret    

00800dd0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dd0:	f3 0f 1e fb          	endbr32 
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800dda:	6a 00                	push   $0x0
  800ddc:	6a 00                	push   $0x0
  800dde:	6a 00                	push   $0x0
  800de0:	ff 75 0c             	pushl  0xc(%ebp)
  800de3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de6:	ba 01 00 00 00       	mov    $0x1,%edx
  800deb:	b8 06 00 00 00       	mov    $0x6,%eax
  800df0:	e8 75 fe ff ff       	call   800c6a <syscall>
}
  800df5:	c9                   	leave  
  800df6:	c3                   	ret    

00800df7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800df7:	f3 0f 1e fb          	endbr32 
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e01:	6a 00                	push   $0x0
  800e03:	6a 00                	push   $0x0
  800e05:	6a 00                	push   $0x0
  800e07:	ff 75 0c             	pushl  0xc(%ebp)
  800e0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0d:	ba 01 00 00 00       	mov    $0x1,%edx
  800e12:	b8 08 00 00 00       	mov    $0x8,%eax
  800e17:	e8 4e fe ff ff       	call   800c6a <syscall>
}
  800e1c:	c9                   	leave  
  800e1d:	c3                   	ret    

00800e1e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e1e:	f3 0f 1e fb          	endbr32 
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800e28:	6a 00                	push   $0x0
  800e2a:	6a 00                	push   $0x0
  800e2c:	6a 00                	push   $0x0
  800e2e:	ff 75 0c             	pushl  0xc(%ebp)
  800e31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e34:	ba 01 00 00 00       	mov    $0x1,%edx
  800e39:	b8 09 00 00 00       	mov    $0x9,%eax
  800e3e:	e8 27 fe ff ff       	call   800c6a <syscall>
}
  800e43:	c9                   	leave  
  800e44:	c3                   	ret    

00800e45 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e45:	f3 0f 1e fb          	endbr32 
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e4f:	6a 00                	push   $0x0
  800e51:	6a 00                	push   $0x0
  800e53:	6a 00                	push   $0x0
  800e55:	ff 75 0c             	pushl  0xc(%ebp)
  800e58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5b:	ba 01 00 00 00       	mov    $0x1,%edx
  800e60:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e65:	e8 00 fe ff ff       	call   800c6a <syscall>
}
  800e6a:	c9                   	leave  
  800e6b:	c3                   	ret    

00800e6c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e6c:	f3 0f 1e fb          	endbr32 
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e76:	6a 00                	push   $0x0
  800e78:	ff 75 14             	pushl  0x14(%ebp)
  800e7b:	ff 75 10             	pushl  0x10(%ebp)
  800e7e:	ff 75 0c             	pushl  0xc(%ebp)
  800e81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e84:	ba 00 00 00 00       	mov    $0x0,%edx
  800e89:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e8e:	e8 d7 fd ff ff       	call   800c6a <syscall>
}
  800e93:	c9                   	leave  
  800e94:	c3                   	ret    

00800e95 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e95:	f3 0f 1e fb          	endbr32 
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e9f:	6a 00                	push   $0x0
  800ea1:	6a 00                	push   $0x0
  800ea3:	6a 00                	push   $0x0
  800ea5:	6a 00                	push   $0x0
  800ea7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eaa:	ba 01 00 00 00       	mov    $0x1,%edx
  800eaf:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eb4:	e8 b1 fd ff ff       	call   800c6a <syscall>
}
  800eb9:	c9                   	leave  
  800eba:	c3                   	ret    

00800ebb <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 04             	sub    $0x4,%esp
	int r;

	// LAB 4: Your code here.
	void *addr = (void *) (pn * PGSIZE);
  800ec2:	89 d3                	mov    %edx,%ebx
  800ec4:	c1 e3 0c             	shl    $0xc,%ebx

	if (uvpt[pn] & PTE_SHARE) {
  800ec7:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800ece:	f6 c5 04             	test   $0x4,%ch
  800ed1:	75 56                	jne    800f29 <duppage+0x6e>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
		return 0;
	}

	if ((uvpt[pn] & (PTE_W | PTE_COW)) != 0) {
  800ed3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eda:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800ee0:	74 72                	je     800f54 <duppage+0x99>
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW) <
  800ee2:	83 ec 0c             	sub    $0xc,%esp
  800ee5:	68 05 08 00 00       	push   $0x805
  800eea:	53                   	push   %ebx
  800eeb:	50                   	push   %eax
  800eec:	53                   	push   %ebx
  800eed:	6a 00                	push   $0x0
  800eef:	e8 b2 fe ff ff       	call   800da6 <sys_page_map>
  800ef4:	83 c4 20             	add    $0x20,%esp
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	78 45                	js     800f40 <duppage+0x85>
		    0) {
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
		}
		if (sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW) < 0) {
  800efb:	83 ec 0c             	sub    $0xc,%esp
  800efe:	68 05 08 00 00       	push   $0x805
  800f03:	53                   	push   %ebx
  800f04:	6a 00                	push   $0x0
  800f06:	53                   	push   %ebx
  800f07:	6a 00                	push   $0x0
  800f09:	e8 98 fe ff ff       	call   800da6 <sys_page_map>
  800f0e:	83 c4 20             	add    $0x20,%esp
  800f11:	85 c0                	test   %eax,%eax
  800f13:	79 55                	jns    800f6a <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP FATHER");
  800f15:	83 ec 04             	sub    $0x4,%esp
  800f18:	68 6c 29 80 00       	push   $0x80296c
  800f1d:	6a 54                	push   $0x54
  800f1f:	68 ff 29 80 00       	push   $0x8029ff
  800f24:	e8 7c f3 ff ff       	call   8002a5 <_panic>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800f29:	83 ec 0c             	sub    $0xc,%esp
  800f2c:	68 07 0e 00 00       	push   $0xe07
  800f31:	53                   	push   %ebx
  800f32:	50                   	push   %eax
  800f33:	53                   	push   %ebx
  800f34:	6a 00                	push   $0x0
  800f36:	e8 6b fe ff ff       	call   800da6 <sys_page_map>
		return 0;
  800f3b:	83 c4 20             	add    $0x20,%esp
  800f3e:	eb 2a                	jmp    800f6a <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
  800f40:	83 ec 04             	sub    $0x4,%esp
  800f43:	68 4c 29 80 00       	push   $0x80294c
  800f48:	6a 51                	push   $0x51
  800f4a:	68 ff 29 80 00       	push   $0x8029ff
  800f4f:	e8 51 f3 ff ff       	call   8002a5 <_panic>
		}
	} else {
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U) < 0) {
  800f54:	83 ec 0c             	sub    $0xc,%esp
  800f57:	6a 05                	push   $0x5
  800f59:	53                   	push   %ebx
  800f5a:	50                   	push   %eax
  800f5b:	53                   	push   %ebx
  800f5c:	6a 00                	push   $0x0
  800f5e:	e8 43 fe ff ff       	call   800da6 <sys_page_map>
  800f63:	83 c4 20             	add    $0x20,%esp
  800f66:	85 c0                	test   %eax,%eax
  800f68:	78 0a                	js     800f74 <duppage+0xb9>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
		}
	}

	return 0;
}
  800f6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
  800f74:	83 ec 04             	sub    $0x4,%esp
  800f77:	68 0a 2a 80 00       	push   $0x802a0a
  800f7c:	6a 58                	push   $0x58
  800f7e:	68 ff 29 80 00       	push   $0x8029ff
  800f83:	e8 1d f3 ff ff       	call   8002a5 <_panic>

00800f88 <dup_or_share>:

static void
dup_or_share(envid_t dstenv, void *va, int perm)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	56                   	push   %esi
  800f8c:	53                   	push   %ebx
  800f8d:	89 c6                	mov    %eax,%esi
  800f8f:	89 d3                	mov    %edx,%ebx
	int r;
	if (perm & PTE_W) {
  800f91:	f6 c1 02             	test   $0x2,%cl
  800f94:	0f 84 8c 00 00 00    	je     801026 <dup_or_share+0x9e>
		// dup
		if ((r = sys_page_alloc(dstenv, va, PTE_P | PTE_U | PTE_W)) < 0)
  800f9a:	83 ec 04             	sub    $0x4,%esp
  800f9d:	6a 07                	push   $0x7
  800f9f:	52                   	push   %edx
  800fa0:	50                   	push   %eax
  800fa1:	e8 d8 fd ff ff       	call   800d7e <sys_page_alloc>
  800fa6:	83 c4 10             	add    $0x10,%esp
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	78 55                	js     801002 <dup_or_share+0x7a>
			panic("sys_page_alloc: %e", r);
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  800fad:	83 ec 0c             	sub    $0xc,%esp
  800fb0:	6a 07                	push   $0x7
  800fb2:	68 00 00 40 00       	push   $0x400000
  800fb7:	6a 00                	push   $0x0
  800fb9:	53                   	push   %ebx
  800fba:	56                   	push   %esi
  800fbb:	e8 e6 fd ff ff       	call   800da6 <sys_page_map>
  800fc0:	83 c4 20             	add    $0x20,%esp
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	78 4d                	js     801014 <dup_or_share+0x8c>
		    0)
			panic("sys_page_map: %e", r);
		memmove(UTEMP, va, PGSIZE);
  800fc7:	83 ec 04             	sub    $0x4,%esp
  800fca:	68 00 10 00 00       	push   $0x1000
  800fcf:	53                   	push   %ebx
  800fd0:	68 00 00 40 00       	push   $0x400000
  800fd5:	e8 d4 fa ff ff       	call   800aae <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800fda:	83 c4 08             	add    $0x8,%esp
  800fdd:	68 00 00 40 00       	push   $0x400000
  800fe2:	6a 00                	push   $0x0
  800fe4:	e8 e7 fd ff ff       	call   800dd0 <sys_page_unmap>
  800fe9:	83 c4 10             	add    $0x10,%esp
  800fec:	85 c0                	test   %eax,%eax
  800fee:	79 52                	jns    801042 <dup_or_share+0xba>
			panic("sys_page_unmap: %e", r);
  800ff0:	50                   	push   %eax
  800ff1:	68 4a 2a 80 00       	push   $0x802a4a
  800ff6:	6a 6c                	push   $0x6c
  800ff8:	68 ff 29 80 00       	push   $0x8029ff
  800ffd:	e8 a3 f2 ff ff       	call   8002a5 <_panic>
			panic("sys_page_alloc: %e", r);
  801002:	50                   	push   %eax
  801003:	68 26 2a 80 00       	push   $0x802a26
  801008:	6a 66                	push   $0x66
  80100a:	68 ff 29 80 00       	push   $0x8029ff
  80100f:	e8 91 f2 ff ff       	call   8002a5 <_panic>
			panic("sys_page_map: %e", r);
  801014:	50                   	push   %eax
  801015:	68 39 2a 80 00       	push   $0x802a39
  80101a:	6a 69                	push   $0x69
  80101c:	68 ff 29 80 00       	push   $0x8029ff
  801021:	e8 7f f2 ff ff       	call   8002a5 <_panic>

	} else {
		// share
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | perm)) <
  801026:	83 ec 0c             	sub    $0xc,%esp
  801029:	83 c9 05             	or     $0x5,%ecx
  80102c:	51                   	push   %ecx
  80102d:	68 00 00 40 00       	push   $0x400000
  801032:	6a 00                	push   $0x0
  801034:	52                   	push   %edx
  801035:	50                   	push   %eax
  801036:	e8 6b fd ff ff       	call   800da6 <sys_page_map>
  80103b:	83 c4 20             	add    $0x20,%esp
  80103e:	85 c0                	test   %eax,%eax
  801040:	78 07                	js     801049 <dup_or_share+0xc1>
		    0)
			panic("sys_page_map: %e", r);
	}
}
  801042:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801045:	5b                   	pop    %ebx
  801046:	5e                   	pop    %esi
  801047:	5d                   	pop    %ebp
  801048:	c3                   	ret    
			panic("sys_page_map: %e", r);
  801049:	50                   	push   %eax
  80104a:	68 39 2a 80 00       	push   $0x802a39
  80104f:	6a 72                	push   $0x72
  801051:	68 ff 29 80 00       	push   $0x8029ff
  801056:	e8 4a f2 ff ff       	call   8002a5 <_panic>

0080105b <pgfault>:
{
  80105b:	f3 0f 1e fb          	endbr32 
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	53                   	push   %ebx
  801063:	83 ec 04             	sub    $0x4,%esp
  801066:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  801069:	8b 02                	mov    (%edx),%eax
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  80106b:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  80106f:	0f 84 95 00 00 00    	je     80110a <pgfault+0xaf>
  801075:	89 c2                	mov    %eax,%edx
  801077:	c1 ea 16             	shr    $0x16,%edx
  80107a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801081:	f6 c2 01             	test   $0x1,%dl
  801084:	0f 84 80 00 00 00    	je     80110a <pgfault+0xaf>
	    (~uvpt[PGNUM(addr)] & (PTE_COW | PTE_P)) != 0) {
  80108a:	89 c2                	mov    %eax,%edx
  80108c:	c1 ea 0c             	shr    $0xc,%edx
  80108f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801096:	f7 d2                	not    %edx
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  801098:	f7 c2 01 08 00 00    	test   $0x801,%edx
  80109e:	75 6a                	jne    80110a <pgfault+0xaf>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  8010a0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010a5:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U) < 0) {
  8010a7:	83 ec 04             	sub    $0x4,%esp
  8010aa:	6a 07                	push   $0x7
  8010ac:	68 00 f0 7f 00       	push   $0x7ff000
  8010b1:	6a 00                	push   $0x0
  8010b3:	e8 c6 fc ff ff       	call   800d7e <sys_page_alloc>
  8010b8:	83 c4 10             	add    $0x10,%esp
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	78 5f                	js     80111e <pgfault+0xc3>
	memcpy((void *) PFTEMP, addr, PGSIZE);
  8010bf:	83 ec 04             	sub    $0x4,%esp
  8010c2:	68 00 10 00 00       	push   $0x1000
  8010c7:	53                   	push   %ebx
  8010c8:	68 00 f0 7f 00       	push   $0x7ff000
  8010cd:	e8 42 fa ff ff       	call   800b14 <memcpy>
	if (sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U) < 0) {
  8010d2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8010d9:	53                   	push   %ebx
  8010da:	6a 00                	push   $0x0
  8010dc:	68 00 f0 7f 00       	push   $0x7ff000
  8010e1:	6a 00                	push   $0x0
  8010e3:	e8 be fc ff ff       	call   800da6 <sys_page_map>
  8010e8:	83 c4 20             	add    $0x20,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	78 43                	js     801132 <pgfault+0xd7>
	if (sys_page_unmap(0, (void *) PFTEMP) < 0) {
  8010ef:	83 ec 08             	sub    $0x8,%esp
  8010f2:	68 00 f0 7f 00       	push   $0x7ff000
  8010f7:	6a 00                	push   $0x0
  8010f9:	e8 d2 fc ff ff       	call   800dd0 <sys_page_unmap>
  8010fe:	83 c4 10             	add    $0x10,%esp
  801101:	85 c0                	test   %eax,%eax
  801103:	78 41                	js     801146 <pgfault+0xeb>
}
  801105:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801108:	c9                   	leave  
  801109:	c3                   	ret    
		panic("ERROR PGFAULT");
  80110a:	83 ec 04             	sub    $0x4,%esp
  80110d:	68 5d 2a 80 00       	push   $0x802a5d
  801112:	6a 1e                	push   $0x1e
  801114:	68 ff 29 80 00       	push   $0x8029ff
  801119:	e8 87 f1 ff ff       	call   8002a5 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_ALLOC");
  80111e:	83 ec 04             	sub    $0x4,%esp
  801121:	68 6b 2a 80 00       	push   $0x802a6b
  801126:	6a 2b                	push   $0x2b
  801128:	68 ff 29 80 00       	push   $0x8029ff
  80112d:	e8 73 f1 ff ff       	call   8002a5 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_MAP");
  801132:	83 ec 04             	sub    $0x4,%esp
  801135:	68 89 2a 80 00       	push   $0x802a89
  80113a:	6a 2f                	push   $0x2f
  80113c:	68 ff 29 80 00       	push   $0x8029ff
  801141:	e8 5f f1 ff ff       	call   8002a5 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_UNMAP");
  801146:	83 ec 04             	sub    $0x4,%esp
  801149:	68 a5 2a 80 00       	push   $0x802aa5
  80114e:	6a 32                	push   $0x32
  801150:	68 ff 29 80 00       	push   $0x8029ff
  801155:	e8 4b f1 ff ff       	call   8002a5 <_panic>

0080115a <fork_v0>:

envid_t
fork_v0(void)
{
  80115a:	f3 0f 1e fb          	endbr32 
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	57                   	push   %edi
  801162:	56                   	push   %esi
  801163:	53                   	push   %ebx
  801164:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801167:	b8 07 00 00 00       	mov    $0x7,%eax
  80116c:	cd 30                	int    $0x30
	envid_t env_id = sys_exofork();
	if (env_id < 0) {
  80116e:	85 c0                	test   %eax,%eax
  801170:	78 24                	js     801196 <fork_v0+0x3c>
  801172:	89 c6                	mov    %eax,%esi
  801174:	89 c7                	mov    %eax,%edi
		thisenv = envs + ENVX(sys_getenvid());
		return env_id;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801176:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (env_id == 0) {  // Son
  80117b:	75 51                	jne    8011ce <fork_v0+0x74>
		thisenv = envs + ENVX(sys_getenvid());
  80117d:	e8 a9 fb ff ff       	call   800d2b <sys_getenvid>
  801182:	25 ff 03 00 00       	and    $0x3ff,%eax
  801187:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80118a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80118f:	a3 04 40 80 00       	mov    %eax,0x804004
		return env_id;
  801194:	eb 78                	jmp    80120e <fork_v0+0xb4>
		panic("ERROR ON FORK_V0");
  801196:	83 ec 04             	sub    $0x4,%esp
  801199:	68 c3 2a 80 00       	push   $0x802ac3
  80119e:	6a 7b                	push   $0x7b
  8011a0:	68 ff 29 80 00       	push   $0x8029ff
  8011a5:	e8 fb f0 ff ff       	call   8002a5 <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
				dup_or_share(env_id,
  8011aa:	b9 07 00 00 00       	mov    $0x7,%ecx
  8011af:	89 da                	mov    %ebx,%edx
  8011b1:	89 f8                	mov    %edi,%eax
  8011b3:	e8 d0 fd ff ff       	call   800f88 <dup_or_share>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  8011b8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011be:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8011c4:	77 36                	ja     8011fc <fork_v0+0xa2>
		if (addr != UXSTACKTOP - PGSIZE) {
  8011c6:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8011cc:	74 ea                	je     8011b8 <fork_v0+0x5e>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  8011ce:	89 d8                	mov    %ebx,%eax
  8011d0:	c1 e8 16             	shr    $0x16,%eax
  8011d3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011da:	a8 01                	test   $0x1,%al
  8011dc:	74 da                	je     8011b8 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  8011de:	89 d8                	mov    %ebx,%eax
  8011e0:	c1 e8 0c             	shr    $0xc,%eax
  8011e3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  8011ea:	f6 c2 01             	test   $0x1,%dl
  8011ed:	74 c9                	je     8011b8 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
  8011ef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  8011f6:	a8 04                	test   $0x4,%al
  8011f8:	74 be                	je     8011b8 <fork_v0+0x5e>
  8011fa:	eb ae                	jmp    8011aa <fork_v0+0x50>
				             PTE_P | PTE_U | PTE_W);
			}
		}
	}

	if (sys_env_set_status(env_id, ENV_RUNNABLE) < 0) {
  8011fc:	83 ec 08             	sub    $0x8,%esp
  8011ff:	6a 02                	push   $0x2
  801201:	56                   	push   %esi
  801202:	e8 f0 fb ff ff       	call   800df7 <sys_env_set_status>
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	85 c0                	test   %eax,%eax
  80120c:	78 0a                	js     801218 <fork_v0+0xbe>
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
	}

	return env_id;
}
  80120e:	89 f0                	mov    %esi,%eax
  801210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801213:	5b                   	pop    %ebx
  801214:	5e                   	pop    %esi
  801215:	5f                   	pop    %edi
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
  801218:	83 ec 04             	sub    $0x4,%esp
  80121b:	68 90 29 80 00       	push   $0x802990
  801220:	68 92 00 00 00       	push   $0x92
  801225:	68 ff 29 80 00       	push   $0x8029ff
  80122a:	e8 76 f0 ff ff       	call   8002a5 <_panic>

0080122f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80122f:	f3 0f 1e fb          	endbr32 
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	57                   	push   %edi
  801237:	56                   	push   %esi
  801238:	53                   	push   %ebx
  801239:	83 ec 18             	sub    $0x18,%esp
	// return fork_v0(); // Uncomment this line if you want to run fork_v0.
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80123c:	68 5b 10 80 00       	push   $0x80105b
  801241:	e8 ab 0e 00 00       	call   8020f1 <set_pgfault_handler>
  801246:	b8 07 00 00 00       	mov    $0x7,%eax
  80124b:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0) {
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	85 c0                	test   %eax,%eax
  801252:	78 27                	js     80127b <fork+0x4c>
  801254:	89 c7                	mov    %eax,%edi
  801256:	89 c6                	mov    %eax,%esi
		thisenv = envs + ENVX(sys_getenvid());
		return envid;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801258:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else if (envid == 0) {  // Son
  80125d:	75 55                	jne    8012b4 <fork+0x85>
		thisenv = envs + ENVX(sys_getenvid());
  80125f:	e8 c7 fa ff ff       	call   800d2b <sys_getenvid>
  801264:	25 ff 03 00 00       	and    $0x3ff,%eax
  801269:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80126c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801271:	a3 04 40 80 00       	mov    %eax,0x804004
		return envid;
  801276:	e9 9b 00 00 00       	jmp    801316 <fork+0xe7>
		panic("ERROR IN FORK: SYS_EXOFORK");
  80127b:	83 ec 04             	sub    $0x4,%esp
  80127e:	68 d4 2a 80 00       	push   $0x802ad4
  801283:	68 b1 00 00 00       	push   $0xb1
  801288:	68 ff 29 80 00       	push   $0x8029ff
  80128d:	e8 13 f0 ff ff       	call   8002a5 <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
				duppage(envid, addr / PGSIZE);
  801292:	89 da                	mov    %ebx,%edx
  801294:	c1 ea 0c             	shr    $0xc,%edx
  801297:	89 f0                	mov    %esi,%eax
  801299:	e8 1d fc ff ff       	call   800ebb <duppage>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  80129e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012a4:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8012aa:	77 2c                	ja     8012d8 <fork+0xa9>
		if (addr != UXSTACKTOP - PGSIZE) {
  8012ac:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8012b2:	74 ea                	je     80129e <fork+0x6f>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  8012b4:	89 d8                	mov    %ebx,%eax
  8012b6:	c1 e8 16             	shr    $0x16,%eax
  8012b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012c0:	a8 01                	test   $0x1,%al
  8012c2:	74 da                	je     80129e <fork+0x6f>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
  8012c4:	89 d8                	mov    %ebx,%eax
  8012c6:	c1 e8 0c             	shr    $0xc,%eax
  8012c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012d0:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  8012d2:	a8 05                	test   $0x5,%al
  8012d4:	75 c8                	jne    80129e <fork+0x6f>
  8012d6:	eb ba                	jmp    801292 <fork+0x63>
			}
		}
	}

	if (sys_page_alloc(envid,
  8012d8:	83 ec 04             	sub    $0x4,%esp
  8012db:	6a 07                	push   $0x7
  8012dd:	68 00 f0 bf ee       	push   $0xeebff000
  8012e2:	57                   	push   %edi
  8012e3:	e8 96 fa ff ff       	call   800d7e <sys_page_alloc>
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 31                	js     801320 <fork+0xf1>
	                   PTE_P | PTE_U | PTE_W) < 0) {
		panic("ERROR FORK: SYS_PAGE_ALLOC");
	}

	extern void _pgfault_upcall(void);
	if (sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0) {
  8012ef:	83 ec 08             	sub    $0x8,%esp
  8012f2:	68 64 21 80 00       	push   $0x802164
  8012f7:	57                   	push   %edi
  8012f8:	e8 48 fb ff ff       	call   800e45 <sys_env_set_pgfault_upcall>
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	78 33                	js     801337 <fork+0x108>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
	}

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0) {
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	6a 02                	push   $0x2
  801309:	57                   	push   %edi
  80130a:	e8 e8 fa ff ff       	call   800df7 <sys_env_set_status>
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	85 c0                	test   %eax,%eax
  801314:	78 38                	js     80134e <fork+0x11f>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
	}

	return envid;
}
  801316:	89 f8                	mov    %edi,%eax
  801318:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80131b:	5b                   	pop    %ebx
  80131c:	5e                   	pop    %esi
  80131d:	5f                   	pop    %edi
  80131e:	5d                   	pop    %ebp
  80131f:	c3                   	ret    
		panic("ERROR FORK: SYS_PAGE_ALLOC");
  801320:	83 ec 04             	sub    $0x4,%esp
  801323:	68 ef 2a 80 00       	push   $0x802aef
  801328:	68 c4 00 00 00       	push   $0xc4
  80132d:	68 ff 29 80 00       	push   $0x8029ff
  801332:	e8 6e ef ff ff       	call   8002a5 <_panic>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
  801337:	83 ec 04             	sub    $0x4,%esp
  80133a:	68 b8 29 80 00       	push   $0x8029b8
  80133f:	68 c9 00 00 00       	push   $0xc9
  801344:	68 ff 29 80 00       	push   $0x8029ff
  801349:	e8 57 ef ff ff       	call   8002a5 <_panic>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
  80134e:	83 ec 04             	sub    $0x4,%esp
  801351:	68 e0 29 80 00       	push   $0x8029e0
  801356:	68 cd 00 00 00       	push   $0xcd
  80135b:	68 ff 29 80 00       	push   $0x8029ff
  801360:	e8 40 ef ff ff       	call   8002a5 <_panic>

00801365 <sfork>:

// Challenge!
int
sfork(void)
{
  801365:	f3 0f 1e fb          	endbr32 
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80136f:	68 0a 2b 80 00       	push   $0x802b0a
  801374:	68 d7 00 00 00       	push   $0xd7
  801379:	68 ff 29 80 00       	push   $0x8029ff
  80137e:	e8 22 ef ff ff       	call   8002a5 <_panic>

00801383 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801383:	f3 0f 1e fb          	endbr32 
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80138a:	8b 45 08             	mov    0x8(%ebp),%eax
  80138d:	05 00 00 00 30       	add    $0x30000000,%eax
  801392:	c1 e8 0c             	shr    $0xc,%eax
}
  801395:	5d                   	pop    %ebp
  801396:	c3                   	ret    

00801397 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801397:	f3 0f 1e fb          	endbr32 
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  8013a1:	ff 75 08             	pushl  0x8(%ebp)
  8013a4:	e8 da ff ff ff       	call   801383 <fd2num>
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	c1 e0 0c             	shl    $0xc,%eax
  8013af:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013b4:	c9                   	leave  
  8013b5:	c3                   	ret    

008013b6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013b6:	f3 0f 1e fb          	endbr32 
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013c2:	89 c2                	mov    %eax,%edx
  8013c4:	c1 ea 16             	shr    $0x16,%edx
  8013c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ce:	f6 c2 01             	test   $0x1,%dl
  8013d1:	74 2d                	je     801400 <fd_alloc+0x4a>
  8013d3:	89 c2                	mov    %eax,%edx
  8013d5:	c1 ea 0c             	shr    $0xc,%edx
  8013d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013df:	f6 c2 01             	test   $0x1,%dl
  8013e2:	74 1c                	je     801400 <fd_alloc+0x4a>
  8013e4:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8013e9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013ee:	75 d2                	jne    8013c2 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8013f9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8013fe:	eb 0a                	jmp    80140a <fd_alloc+0x54>
			*fd_store = fd;
  801400:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801403:	89 01                	mov    %eax,(%ecx)
			return 0;
  801405:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    

0080140c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80140c:	f3 0f 1e fb          	endbr32 
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801416:	83 f8 1f             	cmp    $0x1f,%eax
  801419:	77 30                	ja     80144b <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80141b:	c1 e0 0c             	shl    $0xc,%eax
  80141e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801423:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801429:	f6 c2 01             	test   $0x1,%dl
  80142c:	74 24                	je     801452 <fd_lookup+0x46>
  80142e:	89 c2                	mov    %eax,%edx
  801430:	c1 ea 0c             	shr    $0xc,%edx
  801433:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80143a:	f6 c2 01             	test   $0x1,%dl
  80143d:	74 1a                	je     801459 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80143f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801442:	89 02                	mov    %eax,(%edx)
	return 0;
  801444:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    
		return -E_INVAL;
  80144b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801450:	eb f7                	jmp    801449 <fd_lookup+0x3d>
		return -E_INVAL;
  801452:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801457:	eb f0                	jmp    801449 <fd_lookup+0x3d>
  801459:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80145e:	eb e9                	jmp    801449 <fd_lookup+0x3d>

00801460 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801460:	f3 0f 1e fb          	endbr32 
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	83 ec 08             	sub    $0x8,%esp
  80146a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80146d:	ba 9c 2b 80 00       	mov    $0x802b9c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801472:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801477:	39 08                	cmp    %ecx,(%eax)
  801479:	74 33                	je     8014ae <dev_lookup+0x4e>
  80147b:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80147e:	8b 02                	mov    (%edx),%eax
  801480:	85 c0                	test   %eax,%eax
  801482:	75 f3                	jne    801477 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801484:	a1 04 40 80 00       	mov    0x804004,%eax
  801489:	8b 40 48             	mov    0x48(%eax),%eax
  80148c:	83 ec 04             	sub    $0x4,%esp
  80148f:	51                   	push   %ecx
  801490:	50                   	push   %eax
  801491:	68 20 2b 80 00       	push   $0x802b20
  801496:	e8 f1 ee ff ff       	call   80038c <cprintf>
	*dev = 0;
  80149b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014ac:	c9                   	leave  
  8014ad:	c3                   	ret    
			*dev = devtab[i];
  8014ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014b1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b8:	eb f2                	jmp    8014ac <dev_lookup+0x4c>

008014ba <fd_close>:
{
  8014ba:	f3 0f 1e fb          	endbr32 
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	57                   	push   %edi
  8014c2:	56                   	push   %esi
  8014c3:	53                   	push   %ebx
  8014c4:	83 ec 28             	sub    $0x28,%esp
  8014c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ca:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014cd:	56                   	push   %esi
  8014ce:	e8 b0 fe ff ff       	call   801383 <fd2num>
  8014d3:	83 c4 08             	add    $0x8,%esp
  8014d6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8014d9:	52                   	push   %edx
  8014da:	50                   	push   %eax
  8014db:	e8 2c ff ff ff       	call   80140c <fd_lookup>
  8014e0:	89 c3                	mov    %eax,%ebx
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 05                	js     8014ee <fd_close+0x34>
	    || fd != fd2)
  8014e9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8014ec:	74 16                	je     801504 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8014ee:	89 f8                	mov    %edi,%eax
  8014f0:	84 c0                	test   %al,%al
  8014f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f7:	0f 44 d8             	cmove  %eax,%ebx
}
  8014fa:	89 d8                	mov    %ebx,%eax
  8014fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ff:	5b                   	pop    %ebx
  801500:	5e                   	pop    %esi
  801501:	5f                   	pop    %edi
  801502:	5d                   	pop    %ebp
  801503:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801504:	83 ec 08             	sub    $0x8,%esp
  801507:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80150a:	50                   	push   %eax
  80150b:	ff 36                	pushl  (%esi)
  80150d:	e8 4e ff ff ff       	call   801460 <dev_lookup>
  801512:	89 c3                	mov    %eax,%ebx
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	85 c0                	test   %eax,%eax
  801519:	78 1a                	js     801535 <fd_close+0x7b>
		if (dev->dev_close)
  80151b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80151e:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801521:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801526:	85 c0                	test   %eax,%eax
  801528:	74 0b                	je     801535 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80152a:	83 ec 0c             	sub    $0xc,%esp
  80152d:	56                   	push   %esi
  80152e:	ff d0                	call   *%eax
  801530:	89 c3                	mov    %eax,%ebx
  801532:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801535:	83 ec 08             	sub    $0x8,%esp
  801538:	56                   	push   %esi
  801539:	6a 00                	push   $0x0
  80153b:	e8 90 f8 ff ff       	call   800dd0 <sys_page_unmap>
	return r;
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	eb b5                	jmp    8014fa <fd_close+0x40>

00801545 <close>:

int
close(int fdnum)
{
  801545:	f3 0f 1e fb          	endbr32 
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80154f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801552:	50                   	push   %eax
  801553:	ff 75 08             	pushl  0x8(%ebp)
  801556:	e8 b1 fe ff ff       	call   80140c <fd_lookup>
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	85 c0                	test   %eax,%eax
  801560:	79 02                	jns    801564 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801562:	c9                   	leave  
  801563:	c3                   	ret    
		return fd_close(fd, 1);
  801564:	83 ec 08             	sub    $0x8,%esp
  801567:	6a 01                	push   $0x1
  801569:	ff 75 f4             	pushl  -0xc(%ebp)
  80156c:	e8 49 ff ff ff       	call   8014ba <fd_close>
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	eb ec                	jmp    801562 <close+0x1d>

00801576 <close_all>:

void
close_all(void)
{
  801576:	f3 0f 1e fb          	endbr32 
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	53                   	push   %ebx
  80157e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801581:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801586:	83 ec 0c             	sub    $0xc,%esp
  801589:	53                   	push   %ebx
  80158a:	e8 b6 ff ff ff       	call   801545 <close>
	for (i = 0; i < MAXFD; i++)
  80158f:	83 c3 01             	add    $0x1,%ebx
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	83 fb 20             	cmp    $0x20,%ebx
  801598:	75 ec                	jne    801586 <close_all+0x10>
}
  80159a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    

0080159f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80159f:	f3 0f 1e fb          	endbr32 
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	57                   	push   %edi
  8015a7:	56                   	push   %esi
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015ac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015af:	50                   	push   %eax
  8015b0:	ff 75 08             	pushl  0x8(%ebp)
  8015b3:	e8 54 fe ff ff       	call   80140c <fd_lookup>
  8015b8:	89 c3                	mov    %eax,%ebx
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	0f 88 81 00 00 00    	js     801646 <dup+0xa7>
		return r;
	close(newfdnum);
  8015c5:	83 ec 0c             	sub    $0xc,%esp
  8015c8:	ff 75 0c             	pushl  0xc(%ebp)
  8015cb:	e8 75 ff ff ff       	call   801545 <close>

	newfd = INDEX2FD(newfdnum);
  8015d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8015d3:	c1 e6 0c             	shl    $0xc,%esi
  8015d6:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8015dc:	83 c4 04             	add    $0x4,%esp
  8015df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015e2:	e8 b0 fd ff ff       	call   801397 <fd2data>
  8015e7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015e9:	89 34 24             	mov    %esi,(%esp)
  8015ec:	e8 a6 fd ff ff       	call   801397 <fd2data>
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015f6:	89 d8                	mov    %ebx,%eax
  8015f8:	c1 e8 16             	shr    $0x16,%eax
  8015fb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801602:	a8 01                	test   $0x1,%al
  801604:	74 11                	je     801617 <dup+0x78>
  801606:	89 d8                	mov    %ebx,%eax
  801608:	c1 e8 0c             	shr    $0xc,%eax
  80160b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801612:	f6 c2 01             	test   $0x1,%dl
  801615:	75 39                	jne    801650 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801617:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80161a:	89 d0                	mov    %edx,%eax
  80161c:	c1 e8 0c             	shr    $0xc,%eax
  80161f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801626:	83 ec 0c             	sub    $0xc,%esp
  801629:	25 07 0e 00 00       	and    $0xe07,%eax
  80162e:	50                   	push   %eax
  80162f:	56                   	push   %esi
  801630:	6a 00                	push   $0x0
  801632:	52                   	push   %edx
  801633:	6a 00                	push   $0x0
  801635:	e8 6c f7 ff ff       	call   800da6 <sys_page_map>
  80163a:	89 c3                	mov    %eax,%ebx
  80163c:	83 c4 20             	add    $0x20,%esp
  80163f:	85 c0                	test   %eax,%eax
  801641:	78 31                	js     801674 <dup+0xd5>
		goto err;

	return newfdnum;
  801643:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801646:	89 d8                	mov    %ebx,%eax
  801648:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164b:	5b                   	pop    %ebx
  80164c:	5e                   	pop    %esi
  80164d:	5f                   	pop    %edi
  80164e:	5d                   	pop    %ebp
  80164f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801650:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801657:	83 ec 0c             	sub    $0xc,%esp
  80165a:	25 07 0e 00 00       	and    $0xe07,%eax
  80165f:	50                   	push   %eax
  801660:	57                   	push   %edi
  801661:	6a 00                	push   $0x0
  801663:	53                   	push   %ebx
  801664:	6a 00                	push   $0x0
  801666:	e8 3b f7 ff ff       	call   800da6 <sys_page_map>
  80166b:	89 c3                	mov    %eax,%ebx
  80166d:	83 c4 20             	add    $0x20,%esp
  801670:	85 c0                	test   %eax,%eax
  801672:	79 a3                	jns    801617 <dup+0x78>
	sys_page_unmap(0, newfd);
  801674:	83 ec 08             	sub    $0x8,%esp
  801677:	56                   	push   %esi
  801678:	6a 00                	push   $0x0
  80167a:	e8 51 f7 ff ff       	call   800dd0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80167f:	83 c4 08             	add    $0x8,%esp
  801682:	57                   	push   %edi
  801683:	6a 00                	push   $0x0
  801685:	e8 46 f7 ff ff       	call   800dd0 <sys_page_unmap>
	return r;
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	eb b7                	jmp    801646 <dup+0xa7>

0080168f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80168f:	f3 0f 1e fb          	endbr32 
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	53                   	push   %ebx
  801697:	83 ec 1c             	sub    $0x1c,%esp
  80169a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a0:	50                   	push   %eax
  8016a1:	53                   	push   %ebx
  8016a2:	e8 65 fd ff ff       	call   80140c <fd_lookup>
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	78 3f                	js     8016ed <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b4:	50                   	push   %eax
  8016b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b8:	ff 30                	pushl  (%eax)
  8016ba:	e8 a1 fd ff ff       	call   801460 <dev_lookup>
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	78 27                	js     8016ed <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016c9:	8b 42 08             	mov    0x8(%edx),%eax
  8016cc:	83 e0 03             	and    $0x3,%eax
  8016cf:	83 f8 01             	cmp    $0x1,%eax
  8016d2:	74 1e                	je     8016f2 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8016d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d7:	8b 40 08             	mov    0x8(%eax),%eax
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	74 35                	je     801713 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016de:	83 ec 04             	sub    $0x4,%esp
  8016e1:	ff 75 10             	pushl  0x10(%ebp)
  8016e4:	ff 75 0c             	pushl  0xc(%ebp)
  8016e7:	52                   	push   %edx
  8016e8:	ff d0                	call   *%eax
  8016ea:	83 c4 10             	add    $0x10,%esp
}
  8016ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f0:	c9                   	leave  
  8016f1:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8016f7:	8b 40 48             	mov    0x48(%eax),%eax
  8016fa:	83 ec 04             	sub    $0x4,%esp
  8016fd:	53                   	push   %ebx
  8016fe:	50                   	push   %eax
  8016ff:	68 61 2b 80 00       	push   $0x802b61
  801704:	e8 83 ec ff ff       	call   80038c <cprintf>
		return -E_INVAL;
  801709:	83 c4 10             	add    $0x10,%esp
  80170c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801711:	eb da                	jmp    8016ed <read+0x5e>
		return -E_NOT_SUPP;
  801713:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801718:	eb d3                	jmp    8016ed <read+0x5e>

0080171a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80171a:	f3 0f 1e fb          	endbr32 
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	57                   	push   %edi
  801722:	56                   	push   %esi
  801723:	53                   	push   %ebx
  801724:	83 ec 0c             	sub    $0xc,%esp
  801727:	8b 7d 08             	mov    0x8(%ebp),%edi
  80172a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80172d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801732:	eb 02                	jmp    801736 <readn+0x1c>
  801734:	01 c3                	add    %eax,%ebx
  801736:	39 f3                	cmp    %esi,%ebx
  801738:	73 21                	jae    80175b <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80173a:	83 ec 04             	sub    $0x4,%esp
  80173d:	89 f0                	mov    %esi,%eax
  80173f:	29 d8                	sub    %ebx,%eax
  801741:	50                   	push   %eax
  801742:	89 d8                	mov    %ebx,%eax
  801744:	03 45 0c             	add    0xc(%ebp),%eax
  801747:	50                   	push   %eax
  801748:	57                   	push   %edi
  801749:	e8 41 ff ff ff       	call   80168f <read>
		if (m < 0)
  80174e:	83 c4 10             	add    $0x10,%esp
  801751:	85 c0                	test   %eax,%eax
  801753:	78 04                	js     801759 <readn+0x3f>
			return m;
		if (m == 0)
  801755:	75 dd                	jne    801734 <readn+0x1a>
  801757:	eb 02                	jmp    80175b <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801759:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80175b:	89 d8                	mov    %ebx,%eax
  80175d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801760:	5b                   	pop    %ebx
  801761:	5e                   	pop    %esi
  801762:	5f                   	pop    %edi
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    

00801765 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801765:	f3 0f 1e fb          	endbr32 
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	53                   	push   %ebx
  80176d:	83 ec 1c             	sub    $0x1c,%esp
  801770:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801773:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801776:	50                   	push   %eax
  801777:	53                   	push   %ebx
  801778:	e8 8f fc ff ff       	call   80140c <fd_lookup>
  80177d:	83 c4 10             	add    $0x10,%esp
  801780:	85 c0                	test   %eax,%eax
  801782:	78 3a                	js     8017be <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801784:	83 ec 08             	sub    $0x8,%esp
  801787:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178a:	50                   	push   %eax
  80178b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178e:	ff 30                	pushl  (%eax)
  801790:	e8 cb fc ff ff       	call   801460 <dev_lookup>
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	85 c0                	test   %eax,%eax
  80179a:	78 22                	js     8017be <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80179c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017a3:	74 1e                	je     8017c3 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8017ab:	85 d2                	test   %edx,%edx
  8017ad:	74 35                	je     8017e4 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017af:	83 ec 04             	sub    $0x4,%esp
  8017b2:	ff 75 10             	pushl  0x10(%ebp)
  8017b5:	ff 75 0c             	pushl  0xc(%ebp)
  8017b8:	50                   	push   %eax
  8017b9:	ff d2                	call   *%edx
  8017bb:	83 c4 10             	add    $0x10,%esp
}
  8017be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017c3:	a1 04 40 80 00       	mov    0x804004,%eax
  8017c8:	8b 40 48             	mov    0x48(%eax),%eax
  8017cb:	83 ec 04             	sub    $0x4,%esp
  8017ce:	53                   	push   %ebx
  8017cf:	50                   	push   %eax
  8017d0:	68 7d 2b 80 00       	push   $0x802b7d
  8017d5:	e8 b2 eb ff ff       	call   80038c <cprintf>
		return -E_INVAL;
  8017da:	83 c4 10             	add    $0x10,%esp
  8017dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017e2:	eb da                	jmp    8017be <write+0x59>
		return -E_NOT_SUPP;
  8017e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017e9:	eb d3                	jmp    8017be <write+0x59>

008017eb <seek>:

int
seek(int fdnum, off_t offset)
{
  8017eb:	f3 0f 1e fb          	endbr32 
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f8:	50                   	push   %eax
  8017f9:	ff 75 08             	pushl  0x8(%ebp)
  8017fc:	e8 0b fc ff ff       	call   80140c <fd_lookup>
  801801:	83 c4 10             	add    $0x10,%esp
  801804:	85 c0                	test   %eax,%eax
  801806:	78 0e                	js     801816 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801808:	8b 55 0c             	mov    0xc(%ebp),%edx
  80180b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801811:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801816:	c9                   	leave  
  801817:	c3                   	ret    

00801818 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801818:	f3 0f 1e fb          	endbr32 
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	53                   	push   %ebx
  801820:	83 ec 1c             	sub    $0x1c,%esp
  801823:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801826:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801829:	50                   	push   %eax
  80182a:	53                   	push   %ebx
  80182b:	e8 dc fb ff ff       	call   80140c <fd_lookup>
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	85 c0                	test   %eax,%eax
  801835:	78 37                	js     80186e <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801837:	83 ec 08             	sub    $0x8,%esp
  80183a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183d:	50                   	push   %eax
  80183e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801841:	ff 30                	pushl  (%eax)
  801843:	e8 18 fc ff ff       	call   801460 <dev_lookup>
  801848:	83 c4 10             	add    $0x10,%esp
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 1f                	js     80186e <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80184f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801852:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801856:	74 1b                	je     801873 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801858:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185b:	8b 52 18             	mov    0x18(%edx),%edx
  80185e:	85 d2                	test   %edx,%edx
  801860:	74 32                	je     801894 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801862:	83 ec 08             	sub    $0x8,%esp
  801865:	ff 75 0c             	pushl  0xc(%ebp)
  801868:	50                   	push   %eax
  801869:	ff d2                	call   *%edx
  80186b:	83 c4 10             	add    $0x10,%esp
}
  80186e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801871:	c9                   	leave  
  801872:	c3                   	ret    
			thisenv->env_id, fdnum);
  801873:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801878:	8b 40 48             	mov    0x48(%eax),%eax
  80187b:	83 ec 04             	sub    $0x4,%esp
  80187e:	53                   	push   %ebx
  80187f:	50                   	push   %eax
  801880:	68 40 2b 80 00       	push   $0x802b40
  801885:	e8 02 eb ff ff       	call   80038c <cprintf>
		return -E_INVAL;
  80188a:	83 c4 10             	add    $0x10,%esp
  80188d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801892:	eb da                	jmp    80186e <ftruncate+0x56>
		return -E_NOT_SUPP;
  801894:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801899:	eb d3                	jmp    80186e <ftruncate+0x56>

0080189b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80189b:	f3 0f 1e fb          	endbr32 
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	53                   	push   %ebx
  8018a3:	83 ec 1c             	sub    $0x1c,%esp
  8018a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ac:	50                   	push   %eax
  8018ad:	ff 75 08             	pushl  0x8(%ebp)
  8018b0:	e8 57 fb ff ff       	call   80140c <fd_lookup>
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	78 4b                	js     801907 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018bc:	83 ec 08             	sub    $0x8,%esp
  8018bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c2:	50                   	push   %eax
  8018c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c6:	ff 30                	pushl  (%eax)
  8018c8:	e8 93 fb ff ff       	call   801460 <dev_lookup>
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	78 33                	js     801907 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8018d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018d7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018db:	74 2f                	je     80190c <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018dd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018e0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018e7:	00 00 00 
	stat->st_isdir = 0;
  8018ea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018f1:	00 00 00 
	stat->st_dev = dev;
  8018f4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018fa:	83 ec 08             	sub    $0x8,%esp
  8018fd:	53                   	push   %ebx
  8018fe:	ff 75 f0             	pushl  -0x10(%ebp)
  801901:	ff 50 14             	call   *0x14(%eax)
  801904:	83 c4 10             	add    $0x10,%esp
}
  801907:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190a:	c9                   	leave  
  80190b:	c3                   	ret    
		return -E_NOT_SUPP;
  80190c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801911:	eb f4                	jmp    801907 <fstat+0x6c>

00801913 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801913:	f3 0f 1e fb          	endbr32 
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	56                   	push   %esi
  80191b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80191c:	83 ec 08             	sub    $0x8,%esp
  80191f:	6a 00                	push   $0x0
  801921:	ff 75 08             	pushl  0x8(%ebp)
  801924:	e8 20 02 00 00       	call   801b49 <open>
  801929:	89 c3                	mov    %eax,%ebx
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	85 c0                	test   %eax,%eax
  801930:	78 1b                	js     80194d <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801932:	83 ec 08             	sub    $0x8,%esp
  801935:	ff 75 0c             	pushl  0xc(%ebp)
  801938:	50                   	push   %eax
  801939:	e8 5d ff ff ff       	call   80189b <fstat>
  80193e:	89 c6                	mov    %eax,%esi
	close(fd);
  801940:	89 1c 24             	mov    %ebx,(%esp)
  801943:	e8 fd fb ff ff       	call   801545 <close>
	return r;
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	89 f3                	mov    %esi,%ebx
}
  80194d:	89 d8                	mov    %ebx,%eax
  80194f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801952:	5b                   	pop    %ebx
  801953:	5e                   	pop    %esi
  801954:	5d                   	pop    %ebp
  801955:	c3                   	ret    

00801956 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	56                   	push   %esi
  80195a:	53                   	push   %ebx
  80195b:	89 c6                	mov    %eax,%esi
  80195d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80195f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801966:	74 27                	je     80198f <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801968:	6a 07                	push   $0x7
  80196a:	68 00 50 80 00       	push   $0x805000
  80196f:	56                   	push   %esi
  801970:	ff 35 00 40 80 00    	pushl  0x804000
  801976:	e8 7c 08 00 00       	call   8021f7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80197b:	83 c4 0c             	add    $0xc,%esp
  80197e:	6a 00                	push   $0x0
  801980:	53                   	push   %ebx
  801981:	6a 00                	push   $0x0
  801983:	e8 02 08 00 00       	call   80218a <ipc_recv>
}
  801988:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198b:	5b                   	pop    %ebx
  80198c:	5e                   	pop    %esi
  80198d:	5d                   	pop    %ebp
  80198e:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80198f:	83 ec 0c             	sub    $0xc,%esp
  801992:	6a 01                	push   $0x1
  801994:	e8 b1 08 00 00       	call   80224a <ipc_find_env>
  801999:	a3 00 40 80 00       	mov    %eax,0x804000
  80199e:	83 c4 10             	add    $0x10,%esp
  8019a1:	eb c5                	jmp    801968 <fsipc+0x12>

008019a3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019a3:	f3 0f 1e fb          	endbr32 
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c5:	b8 02 00 00 00       	mov    $0x2,%eax
  8019ca:	e8 87 ff ff ff       	call   801956 <fsipc>
}
  8019cf:	c9                   	leave  
  8019d0:	c3                   	ret    

008019d1 <devfile_flush>:
{
  8019d1:	f3 0f 1e fb          	endbr32 
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019db:	8b 45 08             	mov    0x8(%ebp),%eax
  8019de:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019eb:	b8 06 00 00 00       	mov    $0x6,%eax
  8019f0:	e8 61 ff ff ff       	call   801956 <fsipc>
}
  8019f5:	c9                   	leave  
  8019f6:	c3                   	ret    

008019f7 <devfile_stat>:
{
  8019f7:	f3 0f 1e fb          	endbr32 
  8019fb:	55                   	push   %ebp
  8019fc:	89 e5                	mov    %esp,%ebp
  8019fe:	53                   	push   %ebx
  8019ff:	83 ec 04             	sub    $0x4,%esp
  801a02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a05:	8b 45 08             	mov    0x8(%ebp),%eax
  801a08:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a10:	ba 00 00 00 00       	mov    $0x0,%edx
  801a15:	b8 05 00 00 00       	mov    $0x5,%eax
  801a1a:	e8 37 ff ff ff       	call   801956 <fsipc>
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	78 2c                	js     801a4f <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a23:	83 ec 08             	sub    $0x8,%esp
  801a26:	68 00 50 80 00       	push   $0x805000
  801a2b:	53                   	push   %ebx
  801a2c:	e8 c5 ee ff ff       	call   8008f6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a31:	a1 80 50 80 00       	mov    0x805080,%eax
  801a36:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a3c:	a1 84 50 80 00       	mov    0x805084,%eax
  801a41:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a47:	83 c4 10             	add    $0x10,%esp
  801a4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a52:	c9                   	leave  
  801a53:	c3                   	ret    

00801a54 <devfile_write>:
{
  801a54:	f3 0f 1e fb          	endbr32 
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	57                   	push   %edi
  801a5c:	56                   	push   %esi
  801a5d:	53                   	push   %ebx
  801a5e:	83 ec 0c             	sub    $0xc,%esp
  801a61:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a64:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a67:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6d:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  801a72:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a77:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  801a7c:	85 db                	test   %ebx,%ebx
  801a7e:	74 3b                	je     801abb <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a80:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801a86:	89 f8                	mov    %edi,%eax
  801a88:	0f 46 c3             	cmovbe %ebx,%eax
  801a8b:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  801a90:	83 ec 04             	sub    $0x4,%esp
  801a93:	50                   	push   %eax
  801a94:	56                   	push   %esi
  801a95:	68 08 50 80 00       	push   $0x805008
  801a9a:	e8 0f f0 ff ff       	call   800aae <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa4:	b8 04 00 00 00       	mov    $0x4,%eax
  801aa9:	e8 a8 fe ff ff       	call   801956 <fsipc>
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 06                	js     801abb <devfile_write+0x67>
		buf_aux += r;
  801ab5:	01 c6                	add    %eax,%esi
		n -= r;
  801ab7:	29 c3                	sub    %eax,%ebx
  801ab9:	eb c1                	jmp    801a7c <devfile_write+0x28>
}
  801abb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abe:	5b                   	pop    %ebx
  801abf:	5e                   	pop    %esi
  801ac0:	5f                   	pop    %edi
  801ac1:	5d                   	pop    %ebp
  801ac2:	c3                   	ret    

00801ac3 <devfile_read>:
{
  801ac3:	f3 0f 1e fb          	endbr32 
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	56                   	push   %esi
  801acb:	53                   	push   %ebx
  801acc:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801acf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ada:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ae0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae5:	b8 03 00 00 00       	mov    $0x3,%eax
  801aea:	e8 67 fe ff ff       	call   801956 <fsipc>
  801aef:	89 c3                	mov    %eax,%ebx
  801af1:	85 c0                	test   %eax,%eax
  801af3:	78 1f                	js     801b14 <devfile_read+0x51>
	assert(r <= n);
  801af5:	39 f0                	cmp    %esi,%eax
  801af7:	77 24                	ja     801b1d <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801af9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801afe:	7f 33                	jg     801b33 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b00:	83 ec 04             	sub    $0x4,%esp
  801b03:	50                   	push   %eax
  801b04:	68 00 50 80 00       	push   $0x805000
  801b09:	ff 75 0c             	pushl  0xc(%ebp)
  801b0c:	e8 9d ef ff ff       	call   800aae <memmove>
	return r;
  801b11:	83 c4 10             	add    $0x10,%esp
}
  801b14:	89 d8                	mov    %ebx,%eax
  801b16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b19:	5b                   	pop    %ebx
  801b1a:	5e                   	pop    %esi
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    
	assert(r <= n);
  801b1d:	68 ac 2b 80 00       	push   $0x802bac
  801b22:	68 b3 2b 80 00       	push   $0x802bb3
  801b27:	6a 7c                	push   $0x7c
  801b29:	68 c8 2b 80 00       	push   $0x802bc8
  801b2e:	e8 72 e7 ff ff       	call   8002a5 <_panic>
	assert(r <= PGSIZE);
  801b33:	68 d3 2b 80 00       	push   $0x802bd3
  801b38:	68 b3 2b 80 00       	push   $0x802bb3
  801b3d:	6a 7d                	push   $0x7d
  801b3f:	68 c8 2b 80 00       	push   $0x802bc8
  801b44:	e8 5c e7 ff ff       	call   8002a5 <_panic>

00801b49 <open>:
{
  801b49:	f3 0f 1e fb          	endbr32 
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	56                   	push   %esi
  801b51:	53                   	push   %ebx
  801b52:	83 ec 1c             	sub    $0x1c,%esp
  801b55:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801b58:	56                   	push   %esi
  801b59:	e8 55 ed ff ff       	call   8008b3 <strlen>
  801b5e:	83 c4 10             	add    $0x10,%esp
  801b61:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b66:	7f 6c                	jg     801bd4 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801b68:	83 ec 0c             	sub    $0xc,%esp
  801b6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b6e:	50                   	push   %eax
  801b6f:	e8 42 f8 ff ff       	call   8013b6 <fd_alloc>
  801b74:	89 c3                	mov    %eax,%ebx
  801b76:	83 c4 10             	add    $0x10,%esp
  801b79:	85 c0                	test   %eax,%eax
  801b7b:	78 3c                	js     801bb9 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801b7d:	83 ec 08             	sub    $0x8,%esp
  801b80:	56                   	push   %esi
  801b81:	68 00 50 80 00       	push   $0x805000
  801b86:	e8 6b ed ff ff       	call   8008f6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b8e:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b93:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b96:	b8 01 00 00 00       	mov    $0x1,%eax
  801b9b:	e8 b6 fd ff ff       	call   801956 <fsipc>
  801ba0:	89 c3                	mov    %eax,%ebx
  801ba2:	83 c4 10             	add    $0x10,%esp
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	78 19                	js     801bc2 <open+0x79>
	return fd2num(fd);
  801ba9:	83 ec 0c             	sub    $0xc,%esp
  801bac:	ff 75 f4             	pushl  -0xc(%ebp)
  801baf:	e8 cf f7 ff ff       	call   801383 <fd2num>
  801bb4:	89 c3                	mov    %eax,%ebx
  801bb6:	83 c4 10             	add    $0x10,%esp
}
  801bb9:	89 d8                	mov    %ebx,%eax
  801bbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bbe:	5b                   	pop    %ebx
  801bbf:	5e                   	pop    %esi
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    
		fd_close(fd, 0);
  801bc2:	83 ec 08             	sub    $0x8,%esp
  801bc5:	6a 00                	push   $0x0
  801bc7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bca:	e8 eb f8 ff ff       	call   8014ba <fd_close>
		return r;
  801bcf:	83 c4 10             	add    $0x10,%esp
  801bd2:	eb e5                	jmp    801bb9 <open+0x70>
		return -E_BAD_PATH;
  801bd4:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801bd9:	eb de                	jmp    801bb9 <open+0x70>

00801bdb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bdb:	f3 0f 1e fb          	endbr32 
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801be5:	ba 00 00 00 00       	mov    $0x0,%edx
  801bea:	b8 08 00 00 00       	mov    $0x8,%eax
  801bef:	e8 62 fd ff ff       	call   801956 <fsipc>
}
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bf6:	f3 0f 1e fb          	endbr32 
  801bfa:	55                   	push   %ebp
  801bfb:	89 e5                	mov    %esp,%ebp
  801bfd:	56                   	push   %esi
  801bfe:	53                   	push   %ebx
  801bff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c02:	83 ec 0c             	sub    $0xc,%esp
  801c05:	ff 75 08             	pushl  0x8(%ebp)
  801c08:	e8 8a f7 ff ff       	call   801397 <fd2data>
  801c0d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c0f:	83 c4 08             	add    $0x8,%esp
  801c12:	68 df 2b 80 00       	push   $0x802bdf
  801c17:	53                   	push   %ebx
  801c18:	e8 d9 ec ff ff       	call   8008f6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c1d:	8b 46 04             	mov    0x4(%esi),%eax
  801c20:	2b 06                	sub    (%esi),%eax
  801c22:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c28:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c2f:	00 00 00 
	stat->st_dev = &devpipe;
  801c32:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c39:	30 80 00 
	return 0;
}
  801c3c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c44:	5b                   	pop    %ebx
  801c45:	5e                   	pop    %esi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    

00801c48 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c48:	f3 0f 1e fb          	endbr32 
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	53                   	push   %ebx
  801c50:	83 ec 0c             	sub    $0xc,%esp
  801c53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c56:	53                   	push   %ebx
  801c57:	6a 00                	push   $0x0
  801c59:	e8 72 f1 ff ff       	call   800dd0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c5e:	89 1c 24             	mov    %ebx,(%esp)
  801c61:	e8 31 f7 ff ff       	call   801397 <fd2data>
  801c66:	83 c4 08             	add    $0x8,%esp
  801c69:	50                   	push   %eax
  801c6a:	6a 00                	push   $0x0
  801c6c:	e8 5f f1 ff ff       	call   800dd0 <sys_page_unmap>
}
  801c71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c74:	c9                   	leave  
  801c75:	c3                   	ret    

00801c76 <_pipeisclosed>:
{
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	57                   	push   %edi
  801c7a:	56                   	push   %esi
  801c7b:	53                   	push   %ebx
  801c7c:	83 ec 1c             	sub    $0x1c,%esp
  801c7f:	89 c7                	mov    %eax,%edi
  801c81:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c83:	a1 04 40 80 00       	mov    0x804004,%eax
  801c88:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c8b:	83 ec 0c             	sub    $0xc,%esp
  801c8e:	57                   	push   %edi
  801c8f:	e8 f3 05 00 00       	call   802287 <pageref>
  801c94:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c97:	89 34 24             	mov    %esi,(%esp)
  801c9a:	e8 e8 05 00 00       	call   802287 <pageref>
		nn = thisenv->env_runs;
  801c9f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ca5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ca8:	83 c4 10             	add    $0x10,%esp
  801cab:	39 cb                	cmp    %ecx,%ebx
  801cad:	74 1b                	je     801cca <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801caf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801cb2:	75 cf                	jne    801c83 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cb4:	8b 42 58             	mov    0x58(%edx),%eax
  801cb7:	6a 01                	push   $0x1
  801cb9:	50                   	push   %eax
  801cba:	53                   	push   %ebx
  801cbb:	68 e6 2b 80 00       	push   $0x802be6
  801cc0:	e8 c7 e6 ff ff       	call   80038c <cprintf>
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	eb b9                	jmp    801c83 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801cca:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ccd:	0f 94 c0             	sete   %al
  801cd0:	0f b6 c0             	movzbl %al,%eax
}
  801cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cd6:	5b                   	pop    %ebx
  801cd7:	5e                   	pop    %esi
  801cd8:	5f                   	pop    %edi
  801cd9:	5d                   	pop    %ebp
  801cda:	c3                   	ret    

00801cdb <devpipe_write>:
{
  801cdb:	f3 0f 1e fb          	endbr32 
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	57                   	push   %edi
  801ce3:	56                   	push   %esi
  801ce4:	53                   	push   %ebx
  801ce5:	83 ec 28             	sub    $0x28,%esp
  801ce8:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ceb:	56                   	push   %esi
  801cec:	e8 a6 f6 ff ff       	call   801397 <fd2data>
  801cf1:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cf3:	83 c4 10             	add    $0x10,%esp
  801cf6:	bf 00 00 00 00       	mov    $0x0,%edi
  801cfb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cfe:	74 4f                	je     801d4f <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d00:	8b 43 04             	mov    0x4(%ebx),%eax
  801d03:	8b 0b                	mov    (%ebx),%ecx
  801d05:	8d 51 20             	lea    0x20(%ecx),%edx
  801d08:	39 d0                	cmp    %edx,%eax
  801d0a:	72 14                	jb     801d20 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801d0c:	89 da                	mov    %ebx,%edx
  801d0e:	89 f0                	mov    %esi,%eax
  801d10:	e8 61 ff ff ff       	call   801c76 <_pipeisclosed>
  801d15:	85 c0                	test   %eax,%eax
  801d17:	75 3b                	jne    801d54 <devpipe_write+0x79>
			sys_yield();
  801d19:	e8 35 f0 ff ff       	call   800d53 <sys_yield>
  801d1e:	eb e0                	jmp    801d00 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d23:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d27:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d2a:	89 c2                	mov    %eax,%edx
  801d2c:	c1 fa 1f             	sar    $0x1f,%edx
  801d2f:	89 d1                	mov    %edx,%ecx
  801d31:	c1 e9 1b             	shr    $0x1b,%ecx
  801d34:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d37:	83 e2 1f             	and    $0x1f,%edx
  801d3a:	29 ca                	sub    %ecx,%edx
  801d3c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d40:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d44:	83 c0 01             	add    $0x1,%eax
  801d47:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d4a:	83 c7 01             	add    $0x1,%edi
  801d4d:	eb ac                	jmp    801cfb <devpipe_write+0x20>
	return i;
  801d4f:	8b 45 10             	mov    0x10(%ebp),%eax
  801d52:	eb 05                	jmp    801d59 <devpipe_write+0x7e>
				return 0;
  801d54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d5c:	5b                   	pop    %ebx
  801d5d:	5e                   	pop    %esi
  801d5e:	5f                   	pop    %edi
  801d5f:	5d                   	pop    %ebp
  801d60:	c3                   	ret    

00801d61 <devpipe_read>:
{
  801d61:	f3 0f 1e fb          	endbr32 
  801d65:	55                   	push   %ebp
  801d66:	89 e5                	mov    %esp,%ebp
  801d68:	57                   	push   %edi
  801d69:	56                   	push   %esi
  801d6a:	53                   	push   %ebx
  801d6b:	83 ec 18             	sub    $0x18,%esp
  801d6e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d71:	57                   	push   %edi
  801d72:	e8 20 f6 ff ff       	call   801397 <fd2data>
  801d77:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d79:	83 c4 10             	add    $0x10,%esp
  801d7c:	be 00 00 00 00       	mov    $0x0,%esi
  801d81:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d84:	75 14                	jne    801d9a <devpipe_read+0x39>
	return i;
  801d86:	8b 45 10             	mov    0x10(%ebp),%eax
  801d89:	eb 02                	jmp    801d8d <devpipe_read+0x2c>
				return i;
  801d8b:	89 f0                	mov    %esi,%eax
}
  801d8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5f                   	pop    %edi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    
			sys_yield();
  801d95:	e8 b9 ef ff ff       	call   800d53 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d9a:	8b 03                	mov    (%ebx),%eax
  801d9c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d9f:	75 18                	jne    801db9 <devpipe_read+0x58>
			if (i > 0)
  801da1:	85 f6                	test   %esi,%esi
  801da3:	75 e6                	jne    801d8b <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801da5:	89 da                	mov    %ebx,%edx
  801da7:	89 f8                	mov    %edi,%eax
  801da9:	e8 c8 fe ff ff       	call   801c76 <_pipeisclosed>
  801dae:	85 c0                	test   %eax,%eax
  801db0:	74 e3                	je     801d95 <devpipe_read+0x34>
				return 0;
  801db2:	b8 00 00 00 00       	mov    $0x0,%eax
  801db7:	eb d4                	jmp    801d8d <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801db9:	99                   	cltd   
  801dba:	c1 ea 1b             	shr    $0x1b,%edx
  801dbd:	01 d0                	add    %edx,%eax
  801dbf:	83 e0 1f             	and    $0x1f,%eax
  801dc2:	29 d0                	sub    %edx,%eax
  801dc4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801dc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dcc:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801dcf:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801dd2:	83 c6 01             	add    $0x1,%esi
  801dd5:	eb aa                	jmp    801d81 <devpipe_read+0x20>

00801dd7 <pipe>:
{
  801dd7:	f3 0f 1e fb          	endbr32 
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	56                   	push   %esi
  801ddf:	53                   	push   %ebx
  801de0:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801de3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de6:	50                   	push   %eax
  801de7:	e8 ca f5 ff ff       	call   8013b6 <fd_alloc>
  801dec:	89 c3                	mov    %eax,%ebx
  801dee:	83 c4 10             	add    $0x10,%esp
  801df1:	85 c0                	test   %eax,%eax
  801df3:	0f 88 23 01 00 00    	js     801f1c <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df9:	83 ec 04             	sub    $0x4,%esp
  801dfc:	68 07 04 00 00       	push   $0x407
  801e01:	ff 75 f4             	pushl  -0xc(%ebp)
  801e04:	6a 00                	push   $0x0
  801e06:	e8 73 ef ff ff       	call   800d7e <sys_page_alloc>
  801e0b:	89 c3                	mov    %eax,%ebx
  801e0d:	83 c4 10             	add    $0x10,%esp
  801e10:	85 c0                	test   %eax,%eax
  801e12:	0f 88 04 01 00 00    	js     801f1c <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801e18:	83 ec 0c             	sub    $0xc,%esp
  801e1b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e1e:	50                   	push   %eax
  801e1f:	e8 92 f5 ff ff       	call   8013b6 <fd_alloc>
  801e24:	89 c3                	mov    %eax,%ebx
  801e26:	83 c4 10             	add    $0x10,%esp
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	0f 88 db 00 00 00    	js     801f0c <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e31:	83 ec 04             	sub    $0x4,%esp
  801e34:	68 07 04 00 00       	push   $0x407
  801e39:	ff 75 f0             	pushl  -0x10(%ebp)
  801e3c:	6a 00                	push   $0x0
  801e3e:	e8 3b ef ff ff       	call   800d7e <sys_page_alloc>
  801e43:	89 c3                	mov    %eax,%ebx
  801e45:	83 c4 10             	add    $0x10,%esp
  801e48:	85 c0                	test   %eax,%eax
  801e4a:	0f 88 bc 00 00 00    	js     801f0c <pipe+0x135>
	va = fd2data(fd0);
  801e50:	83 ec 0c             	sub    $0xc,%esp
  801e53:	ff 75 f4             	pushl  -0xc(%ebp)
  801e56:	e8 3c f5 ff ff       	call   801397 <fd2data>
  801e5b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5d:	83 c4 0c             	add    $0xc,%esp
  801e60:	68 07 04 00 00       	push   $0x407
  801e65:	50                   	push   %eax
  801e66:	6a 00                	push   $0x0
  801e68:	e8 11 ef ff ff       	call   800d7e <sys_page_alloc>
  801e6d:	89 c3                	mov    %eax,%ebx
  801e6f:	83 c4 10             	add    $0x10,%esp
  801e72:	85 c0                	test   %eax,%eax
  801e74:	0f 88 82 00 00 00    	js     801efc <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7a:	83 ec 0c             	sub    $0xc,%esp
  801e7d:	ff 75 f0             	pushl  -0x10(%ebp)
  801e80:	e8 12 f5 ff ff       	call   801397 <fd2data>
  801e85:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e8c:	50                   	push   %eax
  801e8d:	6a 00                	push   $0x0
  801e8f:	56                   	push   %esi
  801e90:	6a 00                	push   $0x0
  801e92:	e8 0f ef ff ff       	call   800da6 <sys_page_map>
  801e97:	89 c3                	mov    %eax,%ebx
  801e99:	83 c4 20             	add    $0x20,%esp
  801e9c:	85 c0                	test   %eax,%eax
  801e9e:	78 4e                	js     801eee <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801ea0:	a1 20 30 80 00       	mov    0x803020,%eax
  801ea5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ea8:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801eaa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ead:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801eb4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801eb7:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801eb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ebc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801ec3:	83 ec 0c             	sub    $0xc,%esp
  801ec6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec9:	e8 b5 f4 ff ff       	call   801383 <fd2num>
  801ece:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ed1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ed3:	83 c4 04             	add    $0x4,%esp
  801ed6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ed9:	e8 a5 f4 ff ff       	call   801383 <fd2num>
  801ede:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ee1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ee4:	83 c4 10             	add    $0x10,%esp
  801ee7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801eec:	eb 2e                	jmp    801f1c <pipe+0x145>
	sys_page_unmap(0, va);
  801eee:	83 ec 08             	sub    $0x8,%esp
  801ef1:	56                   	push   %esi
  801ef2:	6a 00                	push   $0x0
  801ef4:	e8 d7 ee ff ff       	call   800dd0 <sys_page_unmap>
  801ef9:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801efc:	83 ec 08             	sub    $0x8,%esp
  801eff:	ff 75 f0             	pushl  -0x10(%ebp)
  801f02:	6a 00                	push   $0x0
  801f04:	e8 c7 ee ff ff       	call   800dd0 <sys_page_unmap>
  801f09:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801f0c:	83 ec 08             	sub    $0x8,%esp
  801f0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f12:	6a 00                	push   $0x0
  801f14:	e8 b7 ee ff ff       	call   800dd0 <sys_page_unmap>
  801f19:	83 c4 10             	add    $0x10,%esp
}
  801f1c:	89 d8                	mov    %ebx,%eax
  801f1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f21:	5b                   	pop    %ebx
  801f22:	5e                   	pop    %esi
  801f23:	5d                   	pop    %ebp
  801f24:	c3                   	ret    

00801f25 <pipeisclosed>:
{
  801f25:	f3 0f 1e fb          	endbr32 
  801f29:	55                   	push   %ebp
  801f2a:	89 e5                	mov    %esp,%ebp
  801f2c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f32:	50                   	push   %eax
  801f33:	ff 75 08             	pushl  0x8(%ebp)
  801f36:	e8 d1 f4 ff ff       	call   80140c <fd_lookup>
  801f3b:	83 c4 10             	add    $0x10,%esp
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	78 18                	js     801f5a <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801f42:	83 ec 0c             	sub    $0xc,%esp
  801f45:	ff 75 f4             	pushl  -0xc(%ebp)
  801f48:	e8 4a f4 ff ff       	call   801397 <fd2data>
  801f4d:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f52:	e8 1f fd ff ff       	call   801c76 <_pipeisclosed>
  801f57:	83 c4 10             	add    $0x10,%esp
}
  801f5a:	c9                   	leave  
  801f5b:	c3                   	ret    

00801f5c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f5c:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801f60:	b8 00 00 00 00       	mov    $0x0,%eax
  801f65:	c3                   	ret    

00801f66 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f66:	f3 0f 1e fb          	endbr32 
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f70:	68 f9 2b 80 00       	push   $0x802bf9
  801f75:	ff 75 0c             	pushl  0xc(%ebp)
  801f78:	e8 79 e9 ff ff       	call   8008f6 <strcpy>
	return 0;
}
  801f7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f82:	c9                   	leave  
  801f83:	c3                   	ret    

00801f84 <devcons_write>:
{
  801f84:	f3 0f 1e fb          	endbr32 
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	57                   	push   %edi
  801f8c:	56                   	push   %esi
  801f8d:	53                   	push   %ebx
  801f8e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f94:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f99:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f9f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fa2:	73 31                	jae    801fd5 <devcons_write+0x51>
		m = n - tot;
  801fa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fa7:	29 f3                	sub    %esi,%ebx
  801fa9:	83 fb 7f             	cmp    $0x7f,%ebx
  801fac:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801fb1:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801fb4:	83 ec 04             	sub    $0x4,%esp
  801fb7:	53                   	push   %ebx
  801fb8:	89 f0                	mov    %esi,%eax
  801fba:	03 45 0c             	add    0xc(%ebp),%eax
  801fbd:	50                   	push   %eax
  801fbe:	57                   	push   %edi
  801fbf:	e8 ea ea ff ff       	call   800aae <memmove>
		sys_cputs(buf, m);
  801fc4:	83 c4 08             	add    $0x8,%esp
  801fc7:	53                   	push   %ebx
  801fc8:	57                   	push   %edi
  801fc9:	e8 e5 ec ff ff       	call   800cb3 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801fce:	01 de                	add    %ebx,%esi
  801fd0:	83 c4 10             	add    $0x10,%esp
  801fd3:	eb ca                	jmp    801f9f <devcons_write+0x1b>
}
  801fd5:	89 f0                	mov    %esi,%eax
  801fd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fda:	5b                   	pop    %ebx
  801fdb:	5e                   	pop    %esi
  801fdc:	5f                   	pop    %edi
  801fdd:	5d                   	pop    %ebp
  801fde:	c3                   	ret    

00801fdf <devcons_read>:
{
  801fdf:	f3 0f 1e fb          	endbr32 
  801fe3:	55                   	push   %ebp
  801fe4:	89 e5                	mov    %esp,%ebp
  801fe6:	83 ec 08             	sub    $0x8,%esp
  801fe9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801fee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ff2:	74 21                	je     802015 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801ff4:	e8 e4 ec ff ff       	call   800cdd <sys_cgetc>
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	75 07                	jne    802004 <devcons_read+0x25>
		sys_yield();
  801ffd:	e8 51 ed ff ff       	call   800d53 <sys_yield>
  802002:	eb f0                	jmp    801ff4 <devcons_read+0x15>
	if (c < 0)
  802004:	78 0f                	js     802015 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802006:	83 f8 04             	cmp    $0x4,%eax
  802009:	74 0c                	je     802017 <devcons_read+0x38>
	*(char*)vbuf = c;
  80200b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80200e:	88 02                	mov    %al,(%edx)
	return 1;
  802010:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802015:	c9                   	leave  
  802016:	c3                   	ret    
		return 0;
  802017:	b8 00 00 00 00       	mov    $0x0,%eax
  80201c:	eb f7                	jmp    802015 <devcons_read+0x36>

0080201e <cputchar>:
{
  80201e:	f3 0f 1e fb          	endbr32 
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
  802025:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802028:	8b 45 08             	mov    0x8(%ebp),%eax
  80202b:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80202e:	6a 01                	push   $0x1
  802030:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802033:	50                   	push   %eax
  802034:	e8 7a ec ff ff       	call   800cb3 <sys_cputs>
}
  802039:	83 c4 10             	add    $0x10,%esp
  80203c:	c9                   	leave  
  80203d:	c3                   	ret    

0080203e <getchar>:
{
  80203e:	f3 0f 1e fb          	endbr32 
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802048:	6a 01                	push   $0x1
  80204a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80204d:	50                   	push   %eax
  80204e:	6a 00                	push   $0x0
  802050:	e8 3a f6 ff ff       	call   80168f <read>
	if (r < 0)
  802055:	83 c4 10             	add    $0x10,%esp
  802058:	85 c0                	test   %eax,%eax
  80205a:	78 06                	js     802062 <getchar+0x24>
	if (r < 1)
  80205c:	74 06                	je     802064 <getchar+0x26>
	return c;
  80205e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802062:	c9                   	leave  
  802063:	c3                   	ret    
		return -E_EOF;
  802064:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802069:	eb f7                	jmp    802062 <getchar+0x24>

0080206b <iscons>:
{
  80206b:	f3 0f 1e fb          	endbr32 
  80206f:	55                   	push   %ebp
  802070:	89 e5                	mov    %esp,%ebp
  802072:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802075:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802078:	50                   	push   %eax
  802079:	ff 75 08             	pushl  0x8(%ebp)
  80207c:	e8 8b f3 ff ff       	call   80140c <fd_lookup>
  802081:	83 c4 10             	add    $0x10,%esp
  802084:	85 c0                	test   %eax,%eax
  802086:	78 11                	js     802099 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802088:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802091:	39 10                	cmp    %edx,(%eax)
  802093:	0f 94 c0             	sete   %al
  802096:	0f b6 c0             	movzbl %al,%eax
}
  802099:	c9                   	leave  
  80209a:	c3                   	ret    

0080209b <opencons>:
{
  80209b:	f3 0f 1e fb          	endbr32 
  80209f:	55                   	push   %ebp
  8020a0:	89 e5                	mov    %esp,%ebp
  8020a2:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8020a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a8:	50                   	push   %eax
  8020a9:	e8 08 f3 ff ff       	call   8013b6 <fd_alloc>
  8020ae:	83 c4 10             	add    $0x10,%esp
  8020b1:	85 c0                	test   %eax,%eax
  8020b3:	78 3a                	js     8020ef <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020b5:	83 ec 04             	sub    $0x4,%esp
  8020b8:	68 07 04 00 00       	push   $0x407
  8020bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8020c0:	6a 00                	push   $0x0
  8020c2:	e8 b7 ec ff ff       	call   800d7e <sys_page_alloc>
  8020c7:	83 c4 10             	add    $0x10,%esp
  8020ca:	85 c0                	test   %eax,%eax
  8020cc:	78 21                	js     8020ef <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8020ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020d7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020dc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020e3:	83 ec 0c             	sub    $0xc,%esp
  8020e6:	50                   	push   %eax
  8020e7:	e8 97 f2 ff ff       	call   801383 <fd2num>
  8020ec:	83 c4 10             	add    $0x10,%esp
}
  8020ef:	c9                   	leave  
  8020f0:	c3                   	ret    

008020f1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020f1:	f3 0f 1e fb          	endbr32 
  8020f5:	55                   	push   %ebp
  8020f6:	89 e5                	mov    %esp,%ebp
  8020f8:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  8020fb:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802102:	74 0a                	je     80210e <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802104:	8b 45 08             	mov    0x8(%ebp),%eax
  802107:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80210c:	c9                   	leave  
  80210d:	c3                   	ret    
		if (sys_page_alloc(0,
  80210e:	83 ec 04             	sub    $0x4,%esp
  802111:	6a 07                	push   $0x7
  802113:	68 00 f0 bf ee       	push   $0xeebff000
  802118:	6a 00                	push   $0x0
  80211a:	e8 5f ec ff ff       	call   800d7e <sys_page_alloc>
  80211f:	83 c4 10             	add    $0x10,%esp
  802122:	85 c0                	test   %eax,%eax
  802124:	78 2a                	js     802150 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  802126:	83 ec 08             	sub    $0x8,%esp
  802129:	68 64 21 80 00       	push   $0x802164
  80212e:	6a 00                	push   $0x0
  802130:	e8 10 ed ff ff       	call   800e45 <sys_env_set_pgfault_upcall>
  802135:	83 c4 10             	add    $0x10,%esp
  802138:	85 c0                	test   %eax,%eax
  80213a:	79 c8                	jns    802104 <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  80213c:	83 ec 04             	sub    $0x4,%esp
  80213f:	68 3c 2c 80 00       	push   $0x802c3c
  802144:	6a 25                	push   $0x25
  802146:	68 83 2c 80 00       	push   $0x802c83
  80214b:	e8 55 e1 ff ff       	call   8002a5 <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  802150:	83 ec 04             	sub    $0x4,%esp
  802153:	68 08 2c 80 00       	push   $0x802c08
  802158:	6a 21                	push   $0x21
  80215a:	68 83 2c 80 00       	push   $0x802c83
  80215f:	e8 41 e1 ff ff       	call   8002a5 <_panic>

00802164 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802164:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802165:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80216a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80216c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  80216f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  802174:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  802178:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80217c:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  80217e:	83 c4 08             	add    $0x8,%esp
	popal
  802181:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  802182:	83 c4 04             	add    $0x4,%esp
	popfl
  802185:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  802186:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802189:	c3                   	ret    

0080218a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80218a:	f3 0f 1e fb          	endbr32 
  80218e:	55                   	push   %ebp
  80218f:	89 e5                	mov    %esp,%ebp
  802191:	56                   	push   %esi
  802192:	53                   	push   %ebx
  802193:	8b 75 08             	mov    0x8(%ebp),%esi
  802196:	8b 45 0c             	mov    0xc(%ebp),%eax
  802199:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  80219c:	85 c0                	test   %eax,%eax
  80219e:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8021a3:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  8021a6:	83 ec 0c             	sub    $0xc,%esp
  8021a9:	50                   	push   %eax
  8021aa:	e8 e6 ec ff ff       	call   800e95 <sys_ipc_recv>
	if (f < 0) {
  8021af:	83 c4 10             	add    $0x10,%esp
  8021b2:	85 c0                	test   %eax,%eax
  8021b4:	78 2b                	js     8021e1 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  8021b6:	85 f6                	test   %esi,%esi
  8021b8:	74 0a                	je     8021c4 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  8021ba:	a1 04 40 80 00       	mov    0x804004,%eax
  8021bf:	8b 40 74             	mov    0x74(%eax),%eax
  8021c2:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  8021c4:	85 db                	test   %ebx,%ebx
  8021c6:	74 0a                	je     8021d2 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  8021c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8021cd:	8b 40 78             	mov    0x78(%eax),%eax
  8021d0:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  8021d2:	a1 04 40 80 00       	mov    0x804004,%eax
  8021d7:	8b 40 70             	mov    0x70(%eax),%eax
}
  8021da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    
		if (from_env_store != NULL) {
  8021e1:	85 f6                	test   %esi,%esi
  8021e3:	74 06                	je     8021eb <ipc_recv+0x61>
			*from_env_store = 0;
  8021e5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  8021eb:	85 db                	test   %ebx,%ebx
  8021ed:	74 eb                	je     8021da <ipc_recv+0x50>
			*perm_store = 0;
  8021ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8021f5:	eb e3                	jmp    8021da <ipc_recv+0x50>

008021f7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021f7:	f3 0f 1e fb          	endbr32 
  8021fb:	55                   	push   %ebp
  8021fc:	89 e5                	mov    %esp,%ebp
  8021fe:	57                   	push   %edi
  8021ff:	56                   	push   %esi
  802200:	53                   	push   %ebx
  802201:	83 ec 0c             	sub    $0xc,%esp
  802204:	8b 7d 08             	mov    0x8(%ebp),%edi
  802207:	8b 75 0c             	mov    0xc(%ebp),%esi
  80220a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  80220d:	85 db                	test   %ebx,%ebx
  80220f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802214:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802217:	ff 75 14             	pushl  0x14(%ebp)
  80221a:	53                   	push   %ebx
  80221b:	56                   	push   %esi
  80221c:	57                   	push   %edi
  80221d:	e8 4a ec ff ff       	call   800e6c <sys_ipc_try_send>
  802222:	83 c4 10             	add    $0x10,%esp
  802225:	85 c0                	test   %eax,%eax
  802227:	79 19                	jns    802242 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  802229:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80222c:	74 e9                	je     802217 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  80222e:	83 ec 04             	sub    $0x4,%esp
  802231:	68 94 2c 80 00       	push   $0x802c94
  802236:	6a 48                	push   $0x48
  802238:	68 b6 2c 80 00       	push   $0x802cb6
  80223d:	e8 63 e0 ff ff       	call   8002a5 <_panic>
		}
	}
}
  802242:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802245:	5b                   	pop    %ebx
  802246:	5e                   	pop    %esi
  802247:	5f                   	pop    %edi
  802248:	5d                   	pop    %ebp
  802249:	c3                   	ret    

0080224a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80224a:	f3 0f 1e fb          	endbr32 
  80224e:	55                   	push   %ebp
  80224f:	89 e5                	mov    %esp,%ebp
  802251:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802254:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802259:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80225c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802262:	8b 52 50             	mov    0x50(%edx),%edx
  802265:	39 ca                	cmp    %ecx,%edx
  802267:	74 11                	je     80227a <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802269:	83 c0 01             	add    $0x1,%eax
  80226c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802271:	75 e6                	jne    802259 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802273:	b8 00 00 00 00       	mov    $0x0,%eax
  802278:	eb 0b                	jmp    802285 <ipc_find_env+0x3b>
			return envs[i].env_id;
  80227a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80227d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802282:	8b 40 48             	mov    0x48(%eax),%eax
}
  802285:	5d                   	pop    %ebp
  802286:	c3                   	ret    

00802287 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802287:	f3 0f 1e fb          	endbr32 
  80228b:	55                   	push   %ebp
  80228c:	89 e5                	mov    %esp,%ebp
  80228e:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802291:	89 c2                	mov    %eax,%edx
  802293:	c1 ea 16             	shr    $0x16,%edx
  802296:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80229d:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8022a2:	f6 c1 01             	test   $0x1,%cl
  8022a5:	74 1c                	je     8022c3 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8022a7:	c1 e8 0c             	shr    $0xc,%eax
  8022aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8022b1:	a8 01                	test   $0x1,%al
  8022b3:	74 0e                	je     8022c3 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022b5:	c1 e8 0c             	shr    $0xc,%eax
  8022b8:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8022bf:	ef 
  8022c0:	0f b7 d2             	movzwl %dx,%edx
}
  8022c3:	89 d0                	mov    %edx,%eax
  8022c5:	5d                   	pop    %ebp
  8022c6:	c3                   	ret    
  8022c7:	66 90                	xchg   %ax,%ax
  8022c9:	66 90                	xchg   %ax,%ax
  8022cb:	66 90                	xchg   %ax,%ax
  8022cd:	66 90                	xchg   %ax,%ax
  8022cf:	90                   	nop

008022d0 <__udivdi3>:
  8022d0:	f3 0f 1e fb          	endbr32 
  8022d4:	55                   	push   %ebp
  8022d5:	57                   	push   %edi
  8022d6:	56                   	push   %esi
  8022d7:	53                   	push   %ebx
  8022d8:	83 ec 1c             	sub    $0x1c,%esp
  8022db:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8022e3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8022eb:	85 d2                	test   %edx,%edx
  8022ed:	75 19                	jne    802308 <__udivdi3+0x38>
  8022ef:	39 f3                	cmp    %esi,%ebx
  8022f1:	76 4d                	jbe    802340 <__udivdi3+0x70>
  8022f3:	31 ff                	xor    %edi,%edi
  8022f5:	89 e8                	mov    %ebp,%eax
  8022f7:	89 f2                	mov    %esi,%edx
  8022f9:	f7 f3                	div    %ebx
  8022fb:	89 fa                	mov    %edi,%edx
  8022fd:	83 c4 1c             	add    $0x1c,%esp
  802300:	5b                   	pop    %ebx
  802301:	5e                   	pop    %esi
  802302:	5f                   	pop    %edi
  802303:	5d                   	pop    %ebp
  802304:	c3                   	ret    
  802305:	8d 76 00             	lea    0x0(%esi),%esi
  802308:	39 f2                	cmp    %esi,%edx
  80230a:	76 14                	jbe    802320 <__udivdi3+0x50>
  80230c:	31 ff                	xor    %edi,%edi
  80230e:	31 c0                	xor    %eax,%eax
  802310:	89 fa                	mov    %edi,%edx
  802312:	83 c4 1c             	add    $0x1c,%esp
  802315:	5b                   	pop    %ebx
  802316:	5e                   	pop    %esi
  802317:	5f                   	pop    %edi
  802318:	5d                   	pop    %ebp
  802319:	c3                   	ret    
  80231a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802320:	0f bd fa             	bsr    %edx,%edi
  802323:	83 f7 1f             	xor    $0x1f,%edi
  802326:	75 48                	jne    802370 <__udivdi3+0xa0>
  802328:	39 f2                	cmp    %esi,%edx
  80232a:	72 06                	jb     802332 <__udivdi3+0x62>
  80232c:	31 c0                	xor    %eax,%eax
  80232e:	39 eb                	cmp    %ebp,%ebx
  802330:	77 de                	ja     802310 <__udivdi3+0x40>
  802332:	b8 01 00 00 00       	mov    $0x1,%eax
  802337:	eb d7                	jmp    802310 <__udivdi3+0x40>
  802339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802340:	89 d9                	mov    %ebx,%ecx
  802342:	85 db                	test   %ebx,%ebx
  802344:	75 0b                	jne    802351 <__udivdi3+0x81>
  802346:	b8 01 00 00 00       	mov    $0x1,%eax
  80234b:	31 d2                	xor    %edx,%edx
  80234d:	f7 f3                	div    %ebx
  80234f:	89 c1                	mov    %eax,%ecx
  802351:	31 d2                	xor    %edx,%edx
  802353:	89 f0                	mov    %esi,%eax
  802355:	f7 f1                	div    %ecx
  802357:	89 c6                	mov    %eax,%esi
  802359:	89 e8                	mov    %ebp,%eax
  80235b:	89 f7                	mov    %esi,%edi
  80235d:	f7 f1                	div    %ecx
  80235f:	89 fa                	mov    %edi,%edx
  802361:	83 c4 1c             	add    $0x1c,%esp
  802364:	5b                   	pop    %ebx
  802365:	5e                   	pop    %esi
  802366:	5f                   	pop    %edi
  802367:	5d                   	pop    %ebp
  802368:	c3                   	ret    
  802369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802370:	89 f9                	mov    %edi,%ecx
  802372:	b8 20 00 00 00       	mov    $0x20,%eax
  802377:	29 f8                	sub    %edi,%eax
  802379:	d3 e2                	shl    %cl,%edx
  80237b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80237f:	89 c1                	mov    %eax,%ecx
  802381:	89 da                	mov    %ebx,%edx
  802383:	d3 ea                	shr    %cl,%edx
  802385:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802389:	09 d1                	or     %edx,%ecx
  80238b:	89 f2                	mov    %esi,%edx
  80238d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802391:	89 f9                	mov    %edi,%ecx
  802393:	d3 e3                	shl    %cl,%ebx
  802395:	89 c1                	mov    %eax,%ecx
  802397:	d3 ea                	shr    %cl,%edx
  802399:	89 f9                	mov    %edi,%ecx
  80239b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80239f:	89 eb                	mov    %ebp,%ebx
  8023a1:	d3 e6                	shl    %cl,%esi
  8023a3:	89 c1                	mov    %eax,%ecx
  8023a5:	d3 eb                	shr    %cl,%ebx
  8023a7:	09 de                	or     %ebx,%esi
  8023a9:	89 f0                	mov    %esi,%eax
  8023ab:	f7 74 24 08          	divl   0x8(%esp)
  8023af:	89 d6                	mov    %edx,%esi
  8023b1:	89 c3                	mov    %eax,%ebx
  8023b3:	f7 64 24 0c          	mull   0xc(%esp)
  8023b7:	39 d6                	cmp    %edx,%esi
  8023b9:	72 15                	jb     8023d0 <__udivdi3+0x100>
  8023bb:	89 f9                	mov    %edi,%ecx
  8023bd:	d3 e5                	shl    %cl,%ebp
  8023bf:	39 c5                	cmp    %eax,%ebp
  8023c1:	73 04                	jae    8023c7 <__udivdi3+0xf7>
  8023c3:	39 d6                	cmp    %edx,%esi
  8023c5:	74 09                	je     8023d0 <__udivdi3+0x100>
  8023c7:	89 d8                	mov    %ebx,%eax
  8023c9:	31 ff                	xor    %edi,%edi
  8023cb:	e9 40 ff ff ff       	jmp    802310 <__udivdi3+0x40>
  8023d0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8023d3:	31 ff                	xor    %edi,%edi
  8023d5:	e9 36 ff ff ff       	jmp    802310 <__udivdi3+0x40>
  8023da:	66 90                	xchg   %ax,%ax
  8023dc:	66 90                	xchg   %ax,%ax
  8023de:	66 90                	xchg   %ax,%ax

008023e0 <__umoddi3>:
  8023e0:	f3 0f 1e fb          	endbr32 
  8023e4:	55                   	push   %ebp
  8023e5:	57                   	push   %edi
  8023e6:	56                   	push   %esi
  8023e7:	53                   	push   %ebx
  8023e8:	83 ec 1c             	sub    $0x1c,%esp
  8023eb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8023ef:	8b 74 24 30          	mov    0x30(%esp),%esi
  8023f3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8023f7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023fb:	85 c0                	test   %eax,%eax
  8023fd:	75 19                	jne    802418 <__umoddi3+0x38>
  8023ff:	39 df                	cmp    %ebx,%edi
  802401:	76 5d                	jbe    802460 <__umoddi3+0x80>
  802403:	89 f0                	mov    %esi,%eax
  802405:	89 da                	mov    %ebx,%edx
  802407:	f7 f7                	div    %edi
  802409:	89 d0                	mov    %edx,%eax
  80240b:	31 d2                	xor    %edx,%edx
  80240d:	83 c4 1c             	add    $0x1c,%esp
  802410:	5b                   	pop    %ebx
  802411:	5e                   	pop    %esi
  802412:	5f                   	pop    %edi
  802413:	5d                   	pop    %ebp
  802414:	c3                   	ret    
  802415:	8d 76 00             	lea    0x0(%esi),%esi
  802418:	89 f2                	mov    %esi,%edx
  80241a:	39 d8                	cmp    %ebx,%eax
  80241c:	76 12                	jbe    802430 <__umoddi3+0x50>
  80241e:	89 f0                	mov    %esi,%eax
  802420:	89 da                	mov    %ebx,%edx
  802422:	83 c4 1c             	add    $0x1c,%esp
  802425:	5b                   	pop    %ebx
  802426:	5e                   	pop    %esi
  802427:	5f                   	pop    %edi
  802428:	5d                   	pop    %ebp
  802429:	c3                   	ret    
  80242a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802430:	0f bd e8             	bsr    %eax,%ebp
  802433:	83 f5 1f             	xor    $0x1f,%ebp
  802436:	75 50                	jne    802488 <__umoddi3+0xa8>
  802438:	39 d8                	cmp    %ebx,%eax
  80243a:	0f 82 e0 00 00 00    	jb     802520 <__umoddi3+0x140>
  802440:	89 d9                	mov    %ebx,%ecx
  802442:	39 f7                	cmp    %esi,%edi
  802444:	0f 86 d6 00 00 00    	jbe    802520 <__umoddi3+0x140>
  80244a:	89 d0                	mov    %edx,%eax
  80244c:	89 ca                	mov    %ecx,%edx
  80244e:	83 c4 1c             	add    $0x1c,%esp
  802451:	5b                   	pop    %ebx
  802452:	5e                   	pop    %esi
  802453:	5f                   	pop    %edi
  802454:	5d                   	pop    %ebp
  802455:	c3                   	ret    
  802456:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80245d:	8d 76 00             	lea    0x0(%esi),%esi
  802460:	89 fd                	mov    %edi,%ebp
  802462:	85 ff                	test   %edi,%edi
  802464:	75 0b                	jne    802471 <__umoddi3+0x91>
  802466:	b8 01 00 00 00       	mov    $0x1,%eax
  80246b:	31 d2                	xor    %edx,%edx
  80246d:	f7 f7                	div    %edi
  80246f:	89 c5                	mov    %eax,%ebp
  802471:	89 d8                	mov    %ebx,%eax
  802473:	31 d2                	xor    %edx,%edx
  802475:	f7 f5                	div    %ebp
  802477:	89 f0                	mov    %esi,%eax
  802479:	f7 f5                	div    %ebp
  80247b:	89 d0                	mov    %edx,%eax
  80247d:	31 d2                	xor    %edx,%edx
  80247f:	eb 8c                	jmp    80240d <__umoddi3+0x2d>
  802481:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802488:	89 e9                	mov    %ebp,%ecx
  80248a:	ba 20 00 00 00       	mov    $0x20,%edx
  80248f:	29 ea                	sub    %ebp,%edx
  802491:	d3 e0                	shl    %cl,%eax
  802493:	89 44 24 08          	mov    %eax,0x8(%esp)
  802497:	89 d1                	mov    %edx,%ecx
  802499:	89 f8                	mov    %edi,%eax
  80249b:	d3 e8                	shr    %cl,%eax
  80249d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8024a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024a5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024a9:	09 c1                	or     %eax,%ecx
  8024ab:	89 d8                	mov    %ebx,%eax
  8024ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024b1:	89 e9                	mov    %ebp,%ecx
  8024b3:	d3 e7                	shl    %cl,%edi
  8024b5:	89 d1                	mov    %edx,%ecx
  8024b7:	d3 e8                	shr    %cl,%eax
  8024b9:	89 e9                	mov    %ebp,%ecx
  8024bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8024bf:	d3 e3                	shl    %cl,%ebx
  8024c1:	89 c7                	mov    %eax,%edi
  8024c3:	89 d1                	mov    %edx,%ecx
  8024c5:	89 f0                	mov    %esi,%eax
  8024c7:	d3 e8                	shr    %cl,%eax
  8024c9:	89 e9                	mov    %ebp,%ecx
  8024cb:	89 fa                	mov    %edi,%edx
  8024cd:	d3 e6                	shl    %cl,%esi
  8024cf:	09 d8                	or     %ebx,%eax
  8024d1:	f7 74 24 08          	divl   0x8(%esp)
  8024d5:	89 d1                	mov    %edx,%ecx
  8024d7:	89 f3                	mov    %esi,%ebx
  8024d9:	f7 64 24 0c          	mull   0xc(%esp)
  8024dd:	89 c6                	mov    %eax,%esi
  8024df:	89 d7                	mov    %edx,%edi
  8024e1:	39 d1                	cmp    %edx,%ecx
  8024e3:	72 06                	jb     8024eb <__umoddi3+0x10b>
  8024e5:	75 10                	jne    8024f7 <__umoddi3+0x117>
  8024e7:	39 c3                	cmp    %eax,%ebx
  8024e9:	73 0c                	jae    8024f7 <__umoddi3+0x117>
  8024eb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8024ef:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8024f3:	89 d7                	mov    %edx,%edi
  8024f5:	89 c6                	mov    %eax,%esi
  8024f7:	89 ca                	mov    %ecx,%edx
  8024f9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8024fe:	29 f3                	sub    %esi,%ebx
  802500:	19 fa                	sbb    %edi,%edx
  802502:	89 d0                	mov    %edx,%eax
  802504:	d3 e0                	shl    %cl,%eax
  802506:	89 e9                	mov    %ebp,%ecx
  802508:	d3 eb                	shr    %cl,%ebx
  80250a:	d3 ea                	shr    %cl,%edx
  80250c:	09 d8                	or     %ebx,%eax
  80250e:	83 c4 1c             	add    $0x1c,%esp
  802511:	5b                   	pop    %ebx
  802512:	5e                   	pop    %esi
  802513:	5f                   	pop    %edi
  802514:	5d                   	pop    %ebp
  802515:	c3                   	ret    
  802516:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80251d:	8d 76 00             	lea    0x0(%esi),%esi
  802520:	29 fe                	sub    %edi,%esi
  802522:	19 c3                	sbb    %eax,%ebx
  802524:	89 f2                	mov    %esi,%edx
  802526:	89 d9                	mov    %ebx,%ecx
  802528:	e9 1d ff ff ff       	jmp    80244a <__umoddi3+0x6a>
