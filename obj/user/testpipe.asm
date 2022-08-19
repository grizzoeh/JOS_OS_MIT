
obj/user/testpipe.debug:     file format elf32-i386


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
  80002c:	e8 a5 02 00 00       	call   8002d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003f:	c7 05 04 30 80 00 20 	movl   $0x802620,0x803004
  800046:	26 80 00 

	if ((i = pipe(p)) < 0)
  800049:	8d 45 8c             	lea    -0x74(%ebp),%eax
  80004c:	50                   	push   %eax
  80004d:	e8 22 1e 00 00       	call   801e74 <pipe>
  800052:	89 c6                	mov    %eax,%esi
  800054:	83 c4 10             	add    $0x10,%esp
  800057:	85 c0                	test   %eax,%eax
  800059:	0f 88 1b 01 00 00    	js     80017a <umain+0x147>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  80005f:	e8 68 12 00 00       	call   8012cc <fork>
  800064:	89 c3                	mov    %eax,%ebx
  800066:	85 c0                	test   %eax,%eax
  800068:	0f 88 1e 01 00 00    	js     80018c <umain+0x159>
		panic("fork: %e", i);

	if (pid == 0) {
  80006e:	0f 85 56 01 00 00    	jne    8001ca <umain+0x197>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  800074:	a1 04 40 80 00       	mov    0x804004,%eax
  800079:	8b 40 48             	mov    0x48(%eax),%eax
  80007c:	83 ec 04             	sub    $0x4,%esp
  80007f:	ff 75 90             	pushl  -0x70(%ebp)
  800082:	50                   	push   %eax
  800083:	68 4e 26 80 00       	push   $0x80264e
  800088:	e8 9c 03 00 00       	call   800429 <cprintf>
		close(p[1]);
  80008d:	83 c4 04             	add    $0x4,%esp
  800090:	ff 75 90             	pushl  -0x70(%ebp)
  800093:	e8 4a 15 00 00       	call   8015e2 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  800098:	a1 04 40 80 00       	mov    0x804004,%eax
  80009d:	8b 40 48             	mov    0x48(%eax),%eax
  8000a0:	83 c4 0c             	add    $0xc,%esp
  8000a3:	ff 75 8c             	pushl  -0x74(%ebp)
  8000a6:	50                   	push   %eax
  8000a7:	68 6b 26 80 00       	push   $0x80266b
  8000ac:	e8 78 03 00 00       	call   800429 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000b1:	83 c4 0c             	add    $0xc,%esp
  8000b4:	6a 63                	push   $0x63
  8000b6:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000b9:	50                   	push   %eax
  8000ba:	ff 75 8c             	pushl  -0x74(%ebp)
  8000bd:	e8 f5 16 00 00       	call   8017b7 <readn>
  8000c2:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000c4:	83 c4 10             	add    $0x10,%esp
  8000c7:	85 c0                	test   %eax,%eax
  8000c9:	0f 88 cf 00 00 00    	js     80019e <umain+0x16b>
			panic("read: %e", i);
		buf[i] = 0;
  8000cf:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	ff 35 00 30 80 00    	pushl  0x803000
  8000dd:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000e0:	50                   	push   %eax
  8000e1:	e8 6c 09 00 00       	call   800a52 <strcmp>
  8000e6:	83 c4 10             	add    $0x10,%esp
  8000e9:	85 c0                	test   %eax,%eax
  8000eb:	0f 85 bf 00 00 00    	jne    8001b0 <umain+0x17d>
			cprintf("\npipe read closed properly\n");
  8000f1:	83 ec 0c             	sub    $0xc,%esp
  8000f4:	68 91 26 80 00       	push   $0x802691
  8000f9:	e8 2b 03 00 00       	call   800429 <cprintf>
  8000fe:	83 c4 10             	add    $0x10,%esp
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
		exit();
  800101:	e8 1e 02 00 00       	call   800324 <exit>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
			panic("write: %e", i);
		close(p[1]);
	}
	wait(pid);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	53                   	push   %ebx
  80010a:	e8 ea 1e 00 00       	call   801ff9 <wait>

	binaryname = "pipewriteeof";
  80010f:	c7 05 04 30 80 00 e7 	movl   $0x8026e7,0x803004
  800116:	26 80 00 
	if ((i = pipe(p)) < 0)
  800119:	8d 45 8c             	lea    -0x74(%ebp),%eax
  80011c:	89 04 24             	mov    %eax,(%esp)
  80011f:	e8 50 1d 00 00       	call   801e74 <pipe>
  800124:	89 c6                	mov    %eax,%esi
  800126:	83 c4 10             	add    $0x10,%esp
  800129:	85 c0                	test   %eax,%eax
  80012b:	0f 88 32 01 00 00    	js     800263 <umain+0x230>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  800131:	e8 96 11 00 00       	call   8012cc <fork>
  800136:	89 c3                	mov    %eax,%ebx
  800138:	85 c0                	test   %eax,%eax
  80013a:	0f 88 35 01 00 00    	js     800275 <umain+0x242>
		panic("fork: %e", i);

	if (pid == 0) {
  800140:	0f 84 41 01 00 00    	je     800287 <umain+0x254>
				break;
		}
		cprintf("\npipe write closed properly\n");
		exit();
	}
	close(p[0]);
  800146:	83 ec 0c             	sub    $0xc,%esp
  800149:	ff 75 8c             	pushl  -0x74(%ebp)
  80014c:	e8 91 14 00 00       	call   8015e2 <close>
	close(p[1]);
  800151:	83 c4 04             	add    $0x4,%esp
  800154:	ff 75 90             	pushl  -0x70(%ebp)
  800157:	e8 86 14 00 00       	call   8015e2 <close>
	wait(pid);
  80015c:	89 1c 24             	mov    %ebx,(%esp)
  80015f:	e8 95 1e 00 00       	call   801ff9 <wait>

	cprintf("pipe tests passed\n");
  800164:	c7 04 24 15 27 80 00 	movl   $0x802715,(%esp)
  80016b:	e8 b9 02 00 00       	call   800429 <cprintf>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    
		panic("pipe: %e", i);
  80017a:	50                   	push   %eax
  80017b:	68 2c 26 80 00       	push   $0x80262c
  800180:	6a 0e                	push   $0xe
  800182:	68 35 26 80 00       	push   $0x802635
  800187:	e8 b6 01 00 00       	call   800342 <_panic>
		panic("fork: %e", i);
  80018c:	56                   	push   %esi
  80018d:	68 45 26 80 00       	push   $0x802645
  800192:	6a 11                	push   $0x11
  800194:	68 35 26 80 00       	push   $0x802635
  800199:	e8 a4 01 00 00       	call   800342 <_panic>
			panic("read: %e", i);
  80019e:	50                   	push   %eax
  80019f:	68 88 26 80 00       	push   $0x802688
  8001a4:	6a 19                	push   $0x19
  8001a6:	68 35 26 80 00       	push   $0x802635
  8001ab:	e8 92 01 00 00       	call   800342 <_panic>
			cprintf("\ngot %d bytes: %s\n", i, buf);
  8001b0:	83 ec 04             	sub    $0x4,%esp
  8001b3:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001b6:	50                   	push   %eax
  8001b7:	56                   	push   %esi
  8001b8:	68 ad 26 80 00       	push   $0x8026ad
  8001bd:	e8 67 02 00 00       	call   800429 <cprintf>
  8001c2:	83 c4 10             	add    $0x10,%esp
  8001c5:	e9 37 ff ff ff       	jmp    800101 <umain+0xce>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  8001ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8001cf:	8b 40 48             	mov    0x48(%eax),%eax
  8001d2:	83 ec 04             	sub    $0x4,%esp
  8001d5:	ff 75 8c             	pushl  -0x74(%ebp)
  8001d8:	50                   	push   %eax
  8001d9:	68 4e 26 80 00       	push   $0x80264e
  8001de:	e8 46 02 00 00       	call   800429 <cprintf>
		close(p[0]);
  8001e3:	83 c4 04             	add    $0x4,%esp
  8001e6:	ff 75 8c             	pushl  -0x74(%ebp)
  8001e9:	e8 f4 13 00 00       	call   8015e2 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8001f3:	8b 40 48             	mov    0x48(%eax),%eax
  8001f6:	83 c4 0c             	add    $0xc,%esp
  8001f9:	ff 75 90             	pushl  -0x70(%ebp)
  8001fc:	50                   	push   %eax
  8001fd:	68 c0 26 80 00       	push   $0x8026c0
  800202:	e8 22 02 00 00       	call   800429 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800207:	83 c4 04             	add    $0x4,%esp
  80020a:	ff 35 00 30 80 00    	pushl  0x803000
  800210:	e8 3b 07 00 00       	call   800950 <strlen>
  800215:	83 c4 0c             	add    $0xc,%esp
  800218:	50                   	push   %eax
  800219:	ff 35 00 30 80 00    	pushl  0x803000
  80021f:	ff 75 90             	pushl  -0x70(%ebp)
  800222:	e8 db 15 00 00       	call   801802 <write>
  800227:	89 c6                	mov    %eax,%esi
  800229:	83 c4 04             	add    $0x4,%esp
  80022c:	ff 35 00 30 80 00    	pushl  0x803000
  800232:	e8 19 07 00 00       	call   800950 <strlen>
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	39 f0                	cmp    %esi,%eax
  80023c:	75 13                	jne    800251 <umain+0x21e>
		close(p[1]);
  80023e:	83 ec 0c             	sub    $0xc,%esp
  800241:	ff 75 90             	pushl  -0x70(%ebp)
  800244:	e8 99 13 00 00       	call   8015e2 <close>
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	e9 b5 fe ff ff       	jmp    800106 <umain+0xd3>
			panic("write: %e", i);
  800251:	56                   	push   %esi
  800252:	68 dd 26 80 00       	push   $0x8026dd
  800257:	6a 25                	push   $0x25
  800259:	68 35 26 80 00       	push   $0x802635
  80025e:	e8 df 00 00 00       	call   800342 <_panic>
		panic("pipe: %e", i);
  800263:	50                   	push   %eax
  800264:	68 2c 26 80 00       	push   $0x80262c
  800269:	6a 2c                	push   $0x2c
  80026b:	68 35 26 80 00       	push   $0x802635
  800270:	e8 cd 00 00 00       	call   800342 <_panic>
		panic("fork: %e", i);
  800275:	56                   	push   %esi
  800276:	68 45 26 80 00       	push   $0x802645
  80027b:	6a 2f                	push   $0x2f
  80027d:	68 35 26 80 00       	push   $0x802635
  800282:	e8 bb 00 00 00       	call   800342 <_panic>
		close(p[0]);
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	ff 75 8c             	pushl  -0x74(%ebp)
  80028d:	e8 50 13 00 00       	call   8015e2 <close>
  800292:	83 c4 10             	add    $0x10,%esp
			cprintf(".");
  800295:	83 ec 0c             	sub    $0xc,%esp
  800298:	68 f4 26 80 00       	push   $0x8026f4
  80029d:	e8 87 01 00 00       	call   800429 <cprintf>
			if (write(p[1], "x", 1) != 1)
  8002a2:	83 c4 0c             	add    $0xc,%esp
  8002a5:	6a 01                	push   $0x1
  8002a7:	68 f6 26 80 00       	push   $0x8026f6
  8002ac:	ff 75 90             	pushl  -0x70(%ebp)
  8002af:	e8 4e 15 00 00       	call   801802 <write>
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	83 f8 01             	cmp    $0x1,%eax
  8002ba:	74 d9                	je     800295 <umain+0x262>
		cprintf("\npipe write closed properly\n");
  8002bc:	83 ec 0c             	sub    $0xc,%esp
  8002bf:	68 f8 26 80 00       	push   $0x8026f8
  8002c4:	e8 60 01 00 00       	call   800429 <cprintf>
		exit();
  8002c9:	e8 56 00 00 00       	call   800324 <exit>
  8002ce:	83 c4 10             	add    $0x10,%esp
  8002d1:	e9 70 fe ff ff       	jmp    800146 <umain+0x113>

008002d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002d6:	f3 0f 1e fb          	endbr32 
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	56                   	push   %esi
  8002de:	53                   	push   %ebx
  8002df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002e2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8002e5:	e8 de 0a 00 00       	call   800dc8 <sys_getenvid>
	if (id >= 0)
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	78 12                	js     800300 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8002ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002f3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002fb:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800300:	85 db                	test   %ebx,%ebx
  800302:	7e 07                	jle    80030b <libmain+0x35>
		binaryname = argv[0];
  800304:	8b 06                	mov    (%esi),%eax
  800306:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80030b:	83 ec 08             	sub    $0x8,%esp
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	e8 1e fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800315:	e8 0a 00 00 00       	call   800324 <exit>
}
  80031a:	83 c4 10             	add    $0x10,%esp
  80031d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800320:	5b                   	pop    %ebx
  800321:	5e                   	pop    %esi
  800322:	5d                   	pop    %ebp
  800323:	c3                   	ret    

00800324 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800324:	f3 0f 1e fb          	endbr32 
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80032e:	e8 e0 12 00 00       	call   801613 <close_all>
	sys_env_destroy(0);
  800333:	83 ec 0c             	sub    $0xc,%esp
  800336:	6a 00                	push   $0x0
  800338:	e8 65 0a 00 00       	call   800da2 <sys_env_destroy>
}
  80033d:	83 c4 10             	add    $0x10,%esp
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800342:	f3 0f 1e fb          	endbr32 
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	56                   	push   %esi
  80034a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80034b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80034e:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800354:	e8 6f 0a 00 00       	call   800dc8 <sys_getenvid>
  800359:	83 ec 0c             	sub    $0xc,%esp
  80035c:	ff 75 0c             	pushl  0xc(%ebp)
  80035f:	ff 75 08             	pushl  0x8(%ebp)
  800362:	56                   	push   %esi
  800363:	50                   	push   %eax
  800364:	68 78 27 80 00       	push   $0x802778
  800369:	e8 bb 00 00 00       	call   800429 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80036e:	83 c4 18             	add    $0x18,%esp
  800371:	53                   	push   %ebx
  800372:	ff 75 10             	pushl  0x10(%ebp)
  800375:	e8 5a 00 00 00       	call   8003d4 <vcprintf>
	cprintf("\n");
  80037a:	c7 04 24 69 26 80 00 	movl   $0x802669,(%esp)
  800381:	e8 a3 00 00 00       	call   800429 <cprintf>
  800386:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800389:	cc                   	int3   
  80038a:	eb fd                	jmp    800389 <_panic+0x47>

0080038c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80038c:	f3 0f 1e fb          	endbr32 
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	53                   	push   %ebx
  800394:	83 ec 04             	sub    $0x4,%esp
  800397:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80039a:	8b 13                	mov    (%ebx),%edx
  80039c:	8d 42 01             	lea    0x1(%edx),%eax
  80039f:	89 03                	mov    %eax,(%ebx)
  8003a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003a8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ad:	74 09                	je     8003b8 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003af:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003b6:	c9                   	leave  
  8003b7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003b8:	83 ec 08             	sub    $0x8,%esp
  8003bb:	68 ff 00 00 00       	push   $0xff
  8003c0:	8d 43 08             	lea    0x8(%ebx),%eax
  8003c3:	50                   	push   %eax
  8003c4:	e8 87 09 00 00       	call   800d50 <sys_cputs>
		b->idx = 0;
  8003c9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003cf:	83 c4 10             	add    $0x10,%esp
  8003d2:	eb db                	jmp    8003af <putch+0x23>

008003d4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003d4:	f3 0f 1e fb          	endbr32 
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003e8:	00 00 00 
	b.cnt = 0;
  8003eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003f5:	ff 75 0c             	pushl  0xc(%ebp)
  8003f8:	ff 75 08             	pushl  0x8(%ebp)
  8003fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800401:	50                   	push   %eax
  800402:	68 8c 03 80 00       	push   $0x80038c
  800407:	e8 80 01 00 00       	call   80058c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80040c:	83 c4 08             	add    $0x8,%esp
  80040f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800415:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80041b:	50                   	push   %eax
  80041c:	e8 2f 09 00 00       	call   800d50 <sys_cputs>

	return b.cnt;
}
  800421:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800427:	c9                   	leave  
  800428:	c3                   	ret    

00800429 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800429:	f3 0f 1e fb          	endbr32 
  80042d:	55                   	push   %ebp
  80042e:	89 e5                	mov    %esp,%ebp
  800430:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800433:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800436:	50                   	push   %eax
  800437:	ff 75 08             	pushl  0x8(%ebp)
  80043a:	e8 95 ff ff ff       	call   8003d4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80043f:	c9                   	leave  
  800440:	c3                   	ret    

00800441 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800441:	55                   	push   %ebp
  800442:	89 e5                	mov    %esp,%ebp
  800444:	57                   	push   %edi
  800445:	56                   	push   %esi
  800446:	53                   	push   %ebx
  800447:	83 ec 1c             	sub    $0x1c,%esp
  80044a:	89 c7                	mov    %eax,%edi
  80044c:	89 d6                	mov    %edx,%esi
  80044e:	8b 45 08             	mov    0x8(%ebp),%eax
  800451:	8b 55 0c             	mov    0xc(%ebp),%edx
  800454:	89 d1                	mov    %edx,%ecx
  800456:	89 c2                	mov    %eax,%edx
  800458:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80045b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80045e:	8b 45 10             	mov    0x10(%ebp),%eax
  800461:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800464:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800467:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80046e:	39 c2                	cmp    %eax,%edx
  800470:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800473:	72 3e                	jb     8004b3 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800475:	83 ec 0c             	sub    $0xc,%esp
  800478:	ff 75 18             	pushl  0x18(%ebp)
  80047b:	83 eb 01             	sub    $0x1,%ebx
  80047e:	53                   	push   %ebx
  80047f:	50                   	push   %eax
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	ff 75 e4             	pushl  -0x1c(%ebp)
  800486:	ff 75 e0             	pushl  -0x20(%ebp)
  800489:	ff 75 dc             	pushl  -0x24(%ebp)
  80048c:	ff 75 d8             	pushl  -0x28(%ebp)
  80048f:	e8 2c 1f 00 00       	call   8023c0 <__udivdi3>
  800494:	83 c4 18             	add    $0x18,%esp
  800497:	52                   	push   %edx
  800498:	50                   	push   %eax
  800499:	89 f2                	mov    %esi,%edx
  80049b:	89 f8                	mov    %edi,%eax
  80049d:	e8 9f ff ff ff       	call   800441 <printnum>
  8004a2:	83 c4 20             	add    $0x20,%esp
  8004a5:	eb 13                	jmp    8004ba <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	56                   	push   %esi
  8004ab:	ff 75 18             	pushl  0x18(%ebp)
  8004ae:	ff d7                	call   *%edi
  8004b0:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004b3:	83 eb 01             	sub    $0x1,%ebx
  8004b6:	85 db                	test   %ebx,%ebx
  8004b8:	7f ed                	jg     8004a7 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	56                   	push   %esi
  8004be:	83 ec 04             	sub    $0x4,%esp
  8004c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c7:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ca:	ff 75 d8             	pushl  -0x28(%ebp)
  8004cd:	e8 fe 1f 00 00       	call   8024d0 <__umoddi3>
  8004d2:	83 c4 14             	add    $0x14,%esp
  8004d5:	0f be 80 9b 27 80 00 	movsbl 0x80279b(%eax),%eax
  8004dc:	50                   	push   %eax
  8004dd:	ff d7                	call   *%edi
}
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004e5:	5b                   	pop    %ebx
  8004e6:	5e                   	pop    %esi
  8004e7:	5f                   	pop    %edi
  8004e8:	5d                   	pop    %ebp
  8004e9:	c3                   	ret    

008004ea <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004ea:	83 fa 01             	cmp    $0x1,%edx
  8004ed:	7f 13                	jg     800502 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	74 1c                	je     80050f <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8004f3:	8b 10                	mov    (%eax),%edx
  8004f5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f8:	89 08                	mov    %ecx,(%eax)
  8004fa:	8b 02                	mov    (%edx),%eax
  8004fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800501:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800502:	8b 10                	mov    (%eax),%edx
  800504:	8d 4a 08             	lea    0x8(%edx),%ecx
  800507:	89 08                	mov    %ecx,(%eax)
  800509:	8b 02                	mov    (%edx),%eax
  80050b:	8b 52 04             	mov    0x4(%edx),%edx
  80050e:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80050f:	8b 10                	mov    (%eax),%edx
  800511:	8d 4a 04             	lea    0x4(%edx),%ecx
  800514:	89 08                	mov    %ecx,(%eax)
  800516:	8b 02                	mov    (%edx),%eax
  800518:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80051d:	c3                   	ret    

0080051e <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80051e:	83 fa 01             	cmp    $0x1,%edx
  800521:	7f 0f                	jg     800532 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800523:	85 d2                	test   %edx,%edx
  800525:	74 18                	je     80053f <getint+0x21>
		return va_arg(*ap, long);
  800527:	8b 10                	mov    (%eax),%edx
  800529:	8d 4a 04             	lea    0x4(%edx),%ecx
  80052c:	89 08                	mov    %ecx,(%eax)
  80052e:	8b 02                	mov    (%edx),%eax
  800530:	99                   	cltd   
  800531:	c3                   	ret    
		return va_arg(*ap, long long);
  800532:	8b 10                	mov    (%eax),%edx
  800534:	8d 4a 08             	lea    0x8(%edx),%ecx
  800537:	89 08                	mov    %ecx,(%eax)
  800539:	8b 02                	mov    (%edx),%eax
  80053b:	8b 52 04             	mov    0x4(%edx),%edx
  80053e:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80053f:	8b 10                	mov    (%eax),%edx
  800541:	8d 4a 04             	lea    0x4(%edx),%ecx
  800544:	89 08                	mov    %ecx,(%eax)
  800546:	8b 02                	mov    (%edx),%eax
  800548:	99                   	cltd   
}
  800549:	c3                   	ret    

0080054a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80054a:	f3 0f 1e fb          	endbr32 
  80054e:	55                   	push   %ebp
  80054f:	89 e5                	mov    %esp,%ebp
  800551:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800554:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800558:	8b 10                	mov    (%eax),%edx
  80055a:	3b 50 04             	cmp    0x4(%eax),%edx
  80055d:	73 0a                	jae    800569 <sprintputch+0x1f>
		*b->buf++ = ch;
  80055f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800562:	89 08                	mov    %ecx,(%eax)
  800564:	8b 45 08             	mov    0x8(%ebp),%eax
  800567:	88 02                	mov    %al,(%edx)
}
  800569:	5d                   	pop    %ebp
  80056a:	c3                   	ret    

0080056b <printfmt>:
{
  80056b:	f3 0f 1e fb          	endbr32 
  80056f:	55                   	push   %ebp
  800570:	89 e5                	mov    %esp,%ebp
  800572:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800575:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800578:	50                   	push   %eax
  800579:	ff 75 10             	pushl  0x10(%ebp)
  80057c:	ff 75 0c             	pushl  0xc(%ebp)
  80057f:	ff 75 08             	pushl  0x8(%ebp)
  800582:	e8 05 00 00 00       	call   80058c <vprintfmt>
}
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	c9                   	leave  
  80058b:	c3                   	ret    

0080058c <vprintfmt>:
{
  80058c:	f3 0f 1e fb          	endbr32 
  800590:	55                   	push   %ebp
  800591:	89 e5                	mov    %esp,%ebp
  800593:	57                   	push   %edi
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	83 ec 2c             	sub    $0x2c,%esp
  800599:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80059c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80059f:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005a2:	e9 86 02 00 00       	jmp    80082d <vprintfmt+0x2a1>
		padc = ' ';
  8005a7:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8005ab:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8005b2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8005b9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8005c0:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8d 47 01             	lea    0x1(%edi),%eax
  8005c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005cb:	0f b6 17             	movzbl (%edi),%edx
  8005ce:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005d1:	3c 55                	cmp    $0x55,%al
  8005d3:	0f 87 df 02 00 00    	ja     8008b8 <vprintfmt+0x32c>
  8005d9:	0f b6 c0             	movzbl %al,%eax
  8005dc:	3e ff 24 85 e0 28 80 	notrack jmp *0x8028e0(,%eax,4)
  8005e3:	00 
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005e7:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005eb:	eb d8                	jmp    8005c5 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f0:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005f4:	eb cf                	jmp    8005c5 <vprintfmt+0x39>
  8005f6:	0f b6 d2             	movzbl %dl,%edx
  8005f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800601:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800604:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800607:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80060b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80060e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800611:	83 f9 09             	cmp    $0x9,%ecx
  800614:	77 52                	ja     800668 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800616:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800619:	eb e9                	jmp    800604 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 50 04             	lea    0x4(%eax),%edx
  800621:	89 55 14             	mov    %edx,0x14(%ebp)
  800624:	8b 00                	mov    (%eax),%eax
  800626:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800629:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80062c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800630:	79 93                	jns    8005c5 <vprintfmt+0x39>
				width = precision, precision = -1;
  800632:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800635:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800638:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80063f:	eb 84                	jmp    8005c5 <vprintfmt+0x39>
  800641:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800644:	85 c0                	test   %eax,%eax
  800646:	ba 00 00 00 00       	mov    $0x0,%edx
  80064b:	0f 49 d0             	cmovns %eax,%edx
  80064e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800651:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800654:	e9 6c ff ff ff       	jmp    8005c5 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800659:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80065c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800663:	e9 5d ff ff ff       	jmp    8005c5 <vprintfmt+0x39>
  800668:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80066e:	eb bc                	jmp    80062c <vprintfmt+0xa0>
			lflag++;
  800670:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800676:	e9 4a ff ff ff       	jmp    8005c5 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8d 50 04             	lea    0x4(%eax),%edx
  800681:	89 55 14             	mov    %edx,0x14(%ebp)
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	56                   	push   %esi
  800688:	ff 30                	pushl  (%eax)
  80068a:	ff d3                	call   *%ebx
			break;
  80068c:	83 c4 10             	add    $0x10,%esp
  80068f:	e9 96 01 00 00       	jmp    80082a <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 00                	mov    (%eax),%eax
  80069f:	99                   	cltd   
  8006a0:	31 d0                	xor    %edx,%eax
  8006a2:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006a4:	83 f8 0f             	cmp    $0xf,%eax
  8006a7:	7f 20                	jg     8006c9 <vprintfmt+0x13d>
  8006a9:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  8006b0:	85 d2                	test   %edx,%edx
  8006b2:	74 15                	je     8006c9 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8006b4:	52                   	push   %edx
  8006b5:	68 45 2d 80 00       	push   $0x802d45
  8006ba:	56                   	push   %esi
  8006bb:	53                   	push   %ebx
  8006bc:	e8 aa fe ff ff       	call   80056b <printfmt>
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	e9 61 01 00 00       	jmp    80082a <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8006c9:	50                   	push   %eax
  8006ca:	68 b3 27 80 00       	push   $0x8027b3
  8006cf:	56                   	push   %esi
  8006d0:	53                   	push   %ebx
  8006d1:	e8 95 fe ff ff       	call   80056b <printfmt>
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	e9 4c 01 00 00       	jmp    80082a <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 50 04             	lea    0x4(%eax),%edx
  8006e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e7:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8006e9:	85 c9                	test   %ecx,%ecx
  8006eb:	b8 ac 27 80 00       	mov    $0x8027ac,%eax
  8006f0:	0f 45 c1             	cmovne %ecx,%eax
  8006f3:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006fa:	7e 06                	jle    800702 <vprintfmt+0x176>
  8006fc:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800700:	75 0d                	jne    80070f <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800702:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800705:	89 c7                	mov    %eax,%edi
  800707:	03 45 e0             	add    -0x20(%ebp),%eax
  80070a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80070d:	eb 57                	jmp    800766 <vprintfmt+0x1da>
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	ff 75 d8             	pushl  -0x28(%ebp)
  800715:	ff 75 cc             	pushl  -0x34(%ebp)
  800718:	e8 4f 02 00 00       	call   80096c <strnlen>
  80071d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800720:	29 c2                	sub    %eax,%edx
  800722:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800725:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800728:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80072c:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80072f:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800731:	85 db                	test   %ebx,%ebx
  800733:	7e 10                	jle    800745 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	56                   	push   %esi
  800739:	57                   	push   %edi
  80073a:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80073d:	83 eb 01             	sub    $0x1,%ebx
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	eb ec                	jmp    800731 <vprintfmt+0x1a5>
  800745:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800748:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80074b:	85 d2                	test   %edx,%edx
  80074d:	b8 00 00 00 00       	mov    $0x0,%eax
  800752:	0f 49 c2             	cmovns %edx,%eax
  800755:	29 c2                	sub    %eax,%edx
  800757:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80075a:	eb a6                	jmp    800702 <vprintfmt+0x176>
					putch(ch, putdat);
  80075c:	83 ec 08             	sub    $0x8,%esp
  80075f:	56                   	push   %esi
  800760:	52                   	push   %edx
  800761:	ff d3                	call   *%ebx
  800763:	83 c4 10             	add    $0x10,%esp
  800766:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800769:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076b:	83 c7 01             	add    $0x1,%edi
  80076e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800772:	0f be d0             	movsbl %al,%edx
  800775:	85 d2                	test   %edx,%edx
  800777:	74 42                	je     8007bb <vprintfmt+0x22f>
  800779:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80077d:	78 06                	js     800785 <vprintfmt+0x1f9>
  80077f:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800783:	78 1e                	js     8007a3 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800785:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800789:	74 d1                	je     80075c <vprintfmt+0x1d0>
  80078b:	0f be c0             	movsbl %al,%eax
  80078e:	83 e8 20             	sub    $0x20,%eax
  800791:	83 f8 5e             	cmp    $0x5e,%eax
  800794:	76 c6                	jbe    80075c <vprintfmt+0x1d0>
					putch('?', putdat);
  800796:	83 ec 08             	sub    $0x8,%esp
  800799:	56                   	push   %esi
  80079a:	6a 3f                	push   $0x3f
  80079c:	ff d3                	call   *%ebx
  80079e:	83 c4 10             	add    $0x10,%esp
  8007a1:	eb c3                	jmp    800766 <vprintfmt+0x1da>
  8007a3:	89 cf                	mov    %ecx,%edi
  8007a5:	eb 0e                	jmp    8007b5 <vprintfmt+0x229>
				putch(' ', putdat);
  8007a7:	83 ec 08             	sub    $0x8,%esp
  8007aa:	56                   	push   %esi
  8007ab:	6a 20                	push   $0x20
  8007ad:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8007af:	83 ef 01             	sub    $0x1,%edi
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	85 ff                	test   %edi,%edi
  8007b7:	7f ee                	jg     8007a7 <vprintfmt+0x21b>
  8007b9:	eb 6f                	jmp    80082a <vprintfmt+0x29e>
  8007bb:	89 cf                	mov    %ecx,%edi
  8007bd:	eb f6                	jmp    8007b5 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8007bf:	89 ca                	mov    %ecx,%edx
  8007c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c4:	e8 55 fd ff ff       	call   80051e <getint>
  8007c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8007cf:	85 d2                	test   %edx,%edx
  8007d1:	78 0b                	js     8007de <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8007d3:	89 d1                	mov    %edx,%ecx
  8007d5:	89 c2                	mov    %eax,%edx
			base = 10;
  8007d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007dc:	eb 32                	jmp    800810 <vprintfmt+0x284>
				putch('-', putdat);
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	56                   	push   %esi
  8007e2:	6a 2d                	push   $0x2d
  8007e4:	ff d3                	call   *%ebx
				num = -(long long) num;
  8007e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007ec:	f7 da                	neg    %edx
  8007ee:	83 d1 00             	adc    $0x0,%ecx
  8007f1:	f7 d9                	neg    %ecx
  8007f3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fb:	eb 13                	jmp    800810 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8007fd:	89 ca                	mov    %ecx,%edx
  8007ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800802:	e8 e3 fc ff ff       	call   8004ea <getuint>
  800807:	89 d1                	mov    %edx,%ecx
  800809:	89 c2                	mov    %eax,%edx
			base = 10;
  80080b:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800810:	83 ec 0c             	sub    $0xc,%esp
  800813:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800817:	57                   	push   %edi
  800818:	ff 75 e0             	pushl  -0x20(%ebp)
  80081b:	50                   	push   %eax
  80081c:	51                   	push   %ecx
  80081d:	52                   	push   %edx
  80081e:	89 f2                	mov    %esi,%edx
  800820:	89 d8                	mov    %ebx,%eax
  800822:	e8 1a fc ff ff       	call   800441 <printnum>
			break;
  800827:	83 c4 20             	add    $0x20,%esp
{
  80082a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80082d:	83 c7 01             	add    $0x1,%edi
  800830:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800834:	83 f8 25             	cmp    $0x25,%eax
  800837:	0f 84 6a fd ff ff    	je     8005a7 <vprintfmt+0x1b>
			if (ch == '\0')
  80083d:	85 c0                	test   %eax,%eax
  80083f:	0f 84 93 00 00 00    	je     8008d8 <vprintfmt+0x34c>
			putch(ch, putdat);
  800845:	83 ec 08             	sub    $0x8,%esp
  800848:	56                   	push   %esi
  800849:	50                   	push   %eax
  80084a:	ff d3                	call   *%ebx
  80084c:	83 c4 10             	add    $0x10,%esp
  80084f:	eb dc                	jmp    80082d <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800851:	89 ca                	mov    %ecx,%edx
  800853:	8d 45 14             	lea    0x14(%ebp),%eax
  800856:	e8 8f fc ff ff       	call   8004ea <getuint>
  80085b:	89 d1                	mov    %edx,%ecx
  80085d:	89 c2                	mov    %eax,%edx
			base = 8;
  80085f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800864:	eb aa                	jmp    800810 <vprintfmt+0x284>
			putch('0', putdat);
  800866:	83 ec 08             	sub    $0x8,%esp
  800869:	56                   	push   %esi
  80086a:	6a 30                	push   $0x30
  80086c:	ff d3                	call   *%ebx
			putch('x', putdat);
  80086e:	83 c4 08             	add    $0x8,%esp
  800871:	56                   	push   %esi
  800872:	6a 78                	push   $0x78
  800874:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800876:	8b 45 14             	mov    0x14(%ebp),%eax
  800879:	8d 50 04             	lea    0x4(%eax),%edx
  80087c:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80087f:	8b 10                	mov    (%eax),%edx
  800881:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800886:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800889:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80088e:	eb 80                	jmp    800810 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800890:	89 ca                	mov    %ecx,%edx
  800892:	8d 45 14             	lea    0x14(%ebp),%eax
  800895:	e8 50 fc ff ff       	call   8004ea <getuint>
  80089a:	89 d1                	mov    %edx,%ecx
  80089c:	89 c2                	mov    %eax,%edx
			base = 16;
  80089e:	b8 10 00 00 00       	mov    $0x10,%eax
  8008a3:	e9 68 ff ff ff       	jmp    800810 <vprintfmt+0x284>
			putch(ch, putdat);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	56                   	push   %esi
  8008ac:	6a 25                	push   $0x25
  8008ae:	ff d3                	call   *%ebx
			break;
  8008b0:	83 c4 10             	add    $0x10,%esp
  8008b3:	e9 72 ff ff ff       	jmp    80082a <vprintfmt+0x29e>
			putch('%', putdat);
  8008b8:	83 ec 08             	sub    $0x8,%esp
  8008bb:	56                   	push   %esi
  8008bc:	6a 25                	push   $0x25
  8008be:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	89 f8                	mov    %edi,%eax
  8008c5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8008c9:	74 05                	je     8008d0 <vprintfmt+0x344>
  8008cb:	83 e8 01             	sub    $0x1,%eax
  8008ce:	eb f5                	jmp    8008c5 <vprintfmt+0x339>
  8008d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008d3:	e9 52 ff ff ff       	jmp    80082a <vprintfmt+0x29e>
}
  8008d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5f                   	pop    %edi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e0:	f3 0f 1e fb          	endbr32 
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	83 ec 18             	sub    $0x18,%esp
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800901:	85 c0                	test   %eax,%eax
  800903:	74 26                	je     80092b <vsnprintf+0x4b>
  800905:	85 d2                	test   %edx,%edx
  800907:	7e 22                	jle    80092b <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800909:	ff 75 14             	pushl  0x14(%ebp)
  80090c:	ff 75 10             	pushl  0x10(%ebp)
  80090f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800912:	50                   	push   %eax
  800913:	68 4a 05 80 00       	push   $0x80054a
  800918:	e8 6f fc ff ff       	call   80058c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80091d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800920:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800923:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800926:	83 c4 10             	add    $0x10,%esp
}
  800929:	c9                   	leave  
  80092a:	c3                   	ret    
		return -E_INVAL;
  80092b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800930:	eb f7                	jmp    800929 <vsnprintf+0x49>

00800932 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800932:	f3 0f 1e fb          	endbr32 
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80093c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80093f:	50                   	push   %eax
  800940:	ff 75 10             	pushl  0x10(%ebp)
  800943:	ff 75 0c             	pushl  0xc(%ebp)
  800946:	ff 75 08             	pushl  0x8(%ebp)
  800949:	e8 92 ff ff ff       	call   8008e0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80094e:	c9                   	leave  
  80094f:	c3                   	ret    

00800950 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800950:	f3 0f 1e fb          	endbr32 
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80095a:	b8 00 00 00 00       	mov    $0x0,%eax
  80095f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800963:	74 05                	je     80096a <strlen+0x1a>
		n++;
  800965:	83 c0 01             	add    $0x1,%eax
  800968:	eb f5                	jmp    80095f <strlen+0xf>
	return n;
}
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80096c:	f3 0f 1e fb          	endbr32 
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800976:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
  80097e:	39 d0                	cmp    %edx,%eax
  800980:	74 0d                	je     80098f <strnlen+0x23>
  800982:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800986:	74 05                	je     80098d <strnlen+0x21>
		n++;
  800988:	83 c0 01             	add    $0x1,%eax
  80098b:	eb f1                	jmp    80097e <strnlen+0x12>
  80098d:	89 c2                	mov    %eax,%edx
	return n;
}
  80098f:	89 d0                	mov    %edx,%eax
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800993:	f3 0f 1e fb          	endbr32 
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	53                   	push   %ebx
  80099b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a6:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8009aa:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8009ad:	83 c0 01             	add    $0x1,%eax
  8009b0:	84 d2                	test   %dl,%dl
  8009b2:	75 f2                	jne    8009a6 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8009b4:	89 c8                	mov    %ecx,%eax
  8009b6:	5b                   	pop    %ebx
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009b9:	f3 0f 1e fb          	endbr32 
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	53                   	push   %ebx
  8009c1:	83 ec 10             	sub    $0x10,%esp
  8009c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c7:	53                   	push   %ebx
  8009c8:	e8 83 ff ff ff       	call   800950 <strlen>
  8009cd:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009d0:	ff 75 0c             	pushl  0xc(%ebp)
  8009d3:	01 d8                	add    %ebx,%eax
  8009d5:	50                   	push   %eax
  8009d6:	e8 b8 ff ff ff       	call   800993 <strcpy>
	return dst;
}
  8009db:	89 d8                	mov    %ebx,%eax
  8009dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e0:	c9                   	leave  
  8009e1:	c3                   	ret    

008009e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e2:	f3 0f 1e fb          	endbr32 
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	56                   	push   %esi
  8009ea:	53                   	push   %ebx
  8009eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f1:	89 f3                	mov    %esi,%ebx
  8009f3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f6:	89 f0                	mov    %esi,%eax
  8009f8:	39 d8                	cmp    %ebx,%eax
  8009fa:	74 11                	je     800a0d <strncpy+0x2b>
		*dst++ = *src;
  8009fc:	83 c0 01             	add    $0x1,%eax
  8009ff:	0f b6 0a             	movzbl (%edx),%ecx
  800a02:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a05:	80 f9 01             	cmp    $0x1,%cl
  800a08:	83 da ff             	sbb    $0xffffffff,%edx
  800a0b:	eb eb                	jmp    8009f8 <strncpy+0x16>
	}
	return ret;
}
  800a0d:	89 f0                	mov    %esi,%eax
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a13:	f3 0f 1e fb          	endbr32 
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	56                   	push   %esi
  800a1b:	53                   	push   %ebx
  800a1c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a22:	8b 55 10             	mov    0x10(%ebp),%edx
  800a25:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a27:	85 d2                	test   %edx,%edx
  800a29:	74 21                	je     800a4c <strlcpy+0x39>
  800a2b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a2f:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800a31:	39 c2                	cmp    %eax,%edx
  800a33:	74 14                	je     800a49 <strlcpy+0x36>
  800a35:	0f b6 19             	movzbl (%ecx),%ebx
  800a38:	84 db                	test   %bl,%bl
  800a3a:	74 0b                	je     800a47 <strlcpy+0x34>
			*dst++ = *src++;
  800a3c:	83 c1 01             	add    $0x1,%ecx
  800a3f:	83 c2 01             	add    $0x1,%edx
  800a42:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a45:	eb ea                	jmp    800a31 <strlcpy+0x1e>
  800a47:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a49:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a4c:	29 f0                	sub    %esi,%eax
}
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a52:	f3 0f 1e fb          	endbr32 
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a5f:	0f b6 01             	movzbl (%ecx),%eax
  800a62:	84 c0                	test   %al,%al
  800a64:	74 0c                	je     800a72 <strcmp+0x20>
  800a66:	3a 02                	cmp    (%edx),%al
  800a68:	75 08                	jne    800a72 <strcmp+0x20>
		p++, q++;
  800a6a:	83 c1 01             	add    $0x1,%ecx
  800a6d:	83 c2 01             	add    $0x1,%edx
  800a70:	eb ed                	jmp    800a5f <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a72:	0f b6 c0             	movzbl %al,%eax
  800a75:	0f b6 12             	movzbl (%edx),%edx
  800a78:	29 d0                	sub    %edx,%eax
}
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a7c:	f3 0f 1e fb          	endbr32 
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	53                   	push   %ebx
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8a:	89 c3                	mov    %eax,%ebx
  800a8c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a8f:	eb 06                	jmp    800a97 <strncmp+0x1b>
		n--, p++, q++;
  800a91:	83 c0 01             	add    $0x1,%eax
  800a94:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a97:	39 d8                	cmp    %ebx,%eax
  800a99:	74 16                	je     800ab1 <strncmp+0x35>
  800a9b:	0f b6 08             	movzbl (%eax),%ecx
  800a9e:	84 c9                	test   %cl,%cl
  800aa0:	74 04                	je     800aa6 <strncmp+0x2a>
  800aa2:	3a 0a                	cmp    (%edx),%cl
  800aa4:	74 eb                	je     800a91 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa6:	0f b6 00             	movzbl (%eax),%eax
  800aa9:	0f b6 12             	movzbl (%edx),%edx
  800aac:	29 d0                	sub    %edx,%eax
}
  800aae:	5b                   	pop    %ebx
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    
		return 0;
  800ab1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab6:	eb f6                	jmp    800aae <strncmp+0x32>

00800ab8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ab8:	f3 0f 1e fb          	endbr32 
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac6:	0f b6 10             	movzbl (%eax),%edx
  800ac9:	84 d2                	test   %dl,%dl
  800acb:	74 09                	je     800ad6 <strchr+0x1e>
		if (*s == c)
  800acd:	38 ca                	cmp    %cl,%dl
  800acf:	74 0a                	je     800adb <strchr+0x23>
	for (; *s; s++)
  800ad1:	83 c0 01             	add    $0x1,%eax
  800ad4:	eb f0                	jmp    800ac6 <strchr+0xe>
			return (char *) s;
	return 0;
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800add:	f3 0f 1e fb          	endbr32 
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aeb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aee:	38 ca                	cmp    %cl,%dl
  800af0:	74 09                	je     800afb <strfind+0x1e>
  800af2:	84 d2                	test   %dl,%dl
  800af4:	74 05                	je     800afb <strfind+0x1e>
	for (; *s; s++)
  800af6:	83 c0 01             	add    $0x1,%eax
  800af9:	eb f0                	jmp    800aeb <strfind+0xe>
			break;
	return (char *) s;
}
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800afd:	f3 0f 1e fb          	endbr32 
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800b0d:	85 c9                	test   %ecx,%ecx
  800b0f:	74 33                	je     800b44 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b11:	89 d0                	mov    %edx,%eax
  800b13:	09 c8                	or     %ecx,%eax
  800b15:	a8 03                	test   $0x3,%al
  800b17:	75 23                	jne    800b3c <memset+0x3f>
		c &= 0xFF;
  800b19:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b1d:	89 d8                	mov    %ebx,%eax
  800b1f:	c1 e0 08             	shl    $0x8,%eax
  800b22:	89 df                	mov    %ebx,%edi
  800b24:	c1 e7 18             	shl    $0x18,%edi
  800b27:	89 de                	mov    %ebx,%esi
  800b29:	c1 e6 10             	shl    $0x10,%esi
  800b2c:	09 f7                	or     %esi,%edi
  800b2e:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800b30:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b33:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800b35:	89 d7                	mov    %edx,%edi
  800b37:	fc                   	cld    
  800b38:	f3 ab                	rep stos %eax,%es:(%edi)
  800b3a:	eb 08                	jmp    800b44 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b3c:	89 d7                	mov    %edx,%edi
  800b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b41:	fc                   	cld    
  800b42:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800b44:	89 d0                	mov    %edx,%eax
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b4b:	f3 0f 1e fb          	endbr32 
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
  800b57:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b5d:	39 c6                	cmp    %eax,%esi
  800b5f:	73 32                	jae    800b93 <memmove+0x48>
  800b61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b64:	39 c2                	cmp    %eax,%edx
  800b66:	76 2b                	jbe    800b93 <memmove+0x48>
		s += n;
		d += n;
  800b68:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6b:	89 fe                	mov    %edi,%esi
  800b6d:	09 ce                	or     %ecx,%esi
  800b6f:	09 d6                	or     %edx,%esi
  800b71:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b77:	75 0e                	jne    800b87 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b79:	83 ef 04             	sub    $0x4,%edi
  800b7c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b7f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b82:	fd                   	std    
  800b83:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b85:	eb 09                	jmp    800b90 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b87:	83 ef 01             	sub    $0x1,%edi
  800b8a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b8d:	fd                   	std    
  800b8e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b90:	fc                   	cld    
  800b91:	eb 1a                	jmp    800bad <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b93:	89 c2                	mov    %eax,%edx
  800b95:	09 ca                	or     %ecx,%edx
  800b97:	09 f2                	or     %esi,%edx
  800b99:	f6 c2 03             	test   $0x3,%dl
  800b9c:	75 0a                	jne    800ba8 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b9e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ba1:	89 c7                	mov    %eax,%edi
  800ba3:	fc                   	cld    
  800ba4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba6:	eb 05                	jmp    800bad <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800ba8:	89 c7                	mov    %eax,%edi
  800baa:	fc                   	cld    
  800bab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bb1:	f3 0f 1e fb          	endbr32 
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bbb:	ff 75 10             	pushl  0x10(%ebp)
  800bbe:	ff 75 0c             	pushl  0xc(%ebp)
  800bc1:	ff 75 08             	pushl  0x8(%ebp)
  800bc4:	e8 82 ff ff ff       	call   800b4b <memmove>
}
  800bc9:	c9                   	leave  
  800bca:	c3                   	ret    

00800bcb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bcb:	f3 0f 1e fb          	endbr32 
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bda:	89 c6                	mov    %eax,%esi
  800bdc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bdf:	39 f0                	cmp    %esi,%eax
  800be1:	74 1c                	je     800bff <memcmp+0x34>
		if (*s1 != *s2)
  800be3:	0f b6 08             	movzbl (%eax),%ecx
  800be6:	0f b6 1a             	movzbl (%edx),%ebx
  800be9:	38 d9                	cmp    %bl,%cl
  800beb:	75 08                	jne    800bf5 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bed:	83 c0 01             	add    $0x1,%eax
  800bf0:	83 c2 01             	add    $0x1,%edx
  800bf3:	eb ea                	jmp    800bdf <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800bf5:	0f b6 c1             	movzbl %cl,%eax
  800bf8:	0f b6 db             	movzbl %bl,%ebx
  800bfb:	29 d8                	sub    %ebx,%eax
  800bfd:	eb 05                	jmp    800c04 <memcmp+0x39>
	}

	return 0;
  800bff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c08:	f3 0f 1e fb          	endbr32 
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c15:	89 c2                	mov    %eax,%edx
  800c17:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c1a:	39 d0                	cmp    %edx,%eax
  800c1c:	73 09                	jae    800c27 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c1e:	38 08                	cmp    %cl,(%eax)
  800c20:	74 05                	je     800c27 <memfind+0x1f>
	for (; s < ends; s++)
  800c22:	83 c0 01             	add    $0x1,%eax
  800c25:	eb f3                	jmp    800c1a <memfind+0x12>
			break;
	return (void *) s;
}
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c29:	f3 0f 1e fb          	endbr32 
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c39:	eb 03                	jmp    800c3e <strtol+0x15>
		s++;
  800c3b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c3e:	0f b6 01             	movzbl (%ecx),%eax
  800c41:	3c 20                	cmp    $0x20,%al
  800c43:	74 f6                	je     800c3b <strtol+0x12>
  800c45:	3c 09                	cmp    $0x9,%al
  800c47:	74 f2                	je     800c3b <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800c49:	3c 2b                	cmp    $0x2b,%al
  800c4b:	74 2a                	je     800c77 <strtol+0x4e>
	int neg = 0;
  800c4d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c52:	3c 2d                	cmp    $0x2d,%al
  800c54:	74 2b                	je     800c81 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c56:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c5c:	75 0f                	jne    800c6d <strtol+0x44>
  800c5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c61:	74 28                	je     800c8b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c63:	85 db                	test   %ebx,%ebx
  800c65:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c6a:	0f 44 d8             	cmove  %eax,%ebx
  800c6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c72:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c75:	eb 46                	jmp    800cbd <strtol+0x94>
		s++;
  800c77:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7f:	eb d5                	jmp    800c56 <strtol+0x2d>
		s++, neg = 1;
  800c81:	83 c1 01             	add    $0x1,%ecx
  800c84:	bf 01 00 00 00       	mov    $0x1,%edi
  800c89:	eb cb                	jmp    800c56 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c8b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c8f:	74 0e                	je     800c9f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c91:	85 db                	test   %ebx,%ebx
  800c93:	75 d8                	jne    800c6d <strtol+0x44>
		s++, base = 8;
  800c95:	83 c1 01             	add    $0x1,%ecx
  800c98:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c9d:	eb ce                	jmp    800c6d <strtol+0x44>
		s += 2, base = 16;
  800c9f:	83 c1 02             	add    $0x2,%ecx
  800ca2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ca7:	eb c4                	jmp    800c6d <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ca9:	0f be d2             	movsbl %dl,%edx
  800cac:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800caf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cb2:	7d 3a                	jge    800cee <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800cb4:	83 c1 01             	add    $0x1,%ecx
  800cb7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cbb:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800cbd:	0f b6 11             	movzbl (%ecx),%edx
  800cc0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cc3:	89 f3                	mov    %esi,%ebx
  800cc5:	80 fb 09             	cmp    $0x9,%bl
  800cc8:	76 df                	jbe    800ca9 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800cca:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ccd:	89 f3                	mov    %esi,%ebx
  800ccf:	80 fb 19             	cmp    $0x19,%bl
  800cd2:	77 08                	ja     800cdc <strtol+0xb3>
			dig = *s - 'a' + 10;
  800cd4:	0f be d2             	movsbl %dl,%edx
  800cd7:	83 ea 57             	sub    $0x57,%edx
  800cda:	eb d3                	jmp    800caf <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800cdc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cdf:	89 f3                	mov    %esi,%ebx
  800ce1:	80 fb 19             	cmp    $0x19,%bl
  800ce4:	77 08                	ja     800cee <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ce6:	0f be d2             	movsbl %dl,%edx
  800ce9:	83 ea 37             	sub    $0x37,%edx
  800cec:	eb c1                	jmp    800caf <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf2:	74 05                	je     800cf9 <strtol+0xd0>
		*endptr = (char *) s;
  800cf4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf7:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cf9:	89 c2                	mov    %eax,%edx
  800cfb:	f7 da                	neg    %edx
  800cfd:	85 ff                	test   %edi,%edi
  800cff:	0f 45 c2             	cmovne %edx,%eax
}
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 1c             	sub    $0x1c,%esp
  800d10:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d13:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d16:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d1e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800d21:	8b 75 14             	mov    0x14(%ebp),%esi
  800d24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d2a:	74 04                	je     800d30 <syscall+0x29>
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7f 08                	jg     800d38 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	83 ec 0c             	sub    $0xc,%esp
  800d3b:	50                   	push   %eax
  800d3c:	ff 75 e0             	pushl  -0x20(%ebp)
  800d3f:	68 9f 2a 80 00       	push   $0x802a9f
  800d44:	6a 23                	push   $0x23
  800d46:	68 bc 2a 80 00       	push   $0x802abc
  800d4b:	e8 f2 f5 ff ff       	call   800342 <_panic>

00800d50 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800d50:	f3 0f 1e fb          	endbr32 
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800d5a:	6a 00                	push   $0x0
  800d5c:	6a 00                	push   $0x0
  800d5e:	6a 00                	push   $0x0
  800d60:	ff 75 0c             	pushl  0xc(%ebp)
  800d63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d66:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d70:	e8 92 ff ff ff       	call   800d07 <syscall>
}
  800d75:	83 c4 10             	add    $0x10,%esp
  800d78:	c9                   	leave  
  800d79:	c3                   	ret    

00800d7a <sys_cgetc>:

int
sys_cgetc(void)
{
  800d7a:	f3 0f 1e fb          	endbr32 
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800d84:	6a 00                	push   $0x0
  800d86:	6a 00                	push   $0x0
  800d88:	6a 00                	push   $0x0
  800d8a:	6a 00                	push   $0x0
  800d8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d91:	ba 00 00 00 00       	mov    $0x0,%edx
  800d96:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9b:	e8 67 ff ff ff       	call   800d07 <syscall>
}
  800da0:	c9                   	leave  
  800da1:	c3                   	ret    

00800da2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800da2:	f3 0f 1e fb          	endbr32 
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800dac:	6a 00                	push   $0x0
  800dae:	6a 00                	push   $0x0
  800db0:	6a 00                	push   $0x0
  800db2:	6a 00                	push   $0x0
  800db4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db7:	ba 01 00 00 00       	mov    $0x1,%edx
  800dbc:	b8 03 00 00 00       	mov    $0x3,%eax
  800dc1:	e8 41 ff ff ff       	call   800d07 <syscall>
}
  800dc6:	c9                   	leave  
  800dc7:	c3                   	ret    

00800dc8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dc8:	f3 0f 1e fb          	endbr32 
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800dd2:	6a 00                	push   $0x0
  800dd4:	6a 00                	push   $0x0
  800dd6:	6a 00                	push   $0x0
  800dd8:	6a 00                	push   $0x0
  800dda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddf:	ba 00 00 00 00       	mov    $0x0,%edx
  800de4:	b8 02 00 00 00       	mov    $0x2,%eax
  800de9:	e8 19 ff ff ff       	call   800d07 <syscall>
}
  800dee:	c9                   	leave  
  800def:	c3                   	ret    

00800df0 <sys_yield>:

void
sys_yield(void)
{
  800df0:	f3 0f 1e fb          	endbr32 
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800dfa:	6a 00                	push   $0x0
  800dfc:	6a 00                	push   $0x0
  800dfe:	6a 00                	push   $0x0
  800e00:	6a 00                	push   $0x0
  800e02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e07:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e11:	e8 f1 fe ff ff       	call   800d07 <syscall>
}
  800e16:	83 c4 10             	add    $0x10,%esp
  800e19:	c9                   	leave  
  800e1a:	c3                   	ret    

00800e1b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e1b:	f3 0f 1e fb          	endbr32 
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800e25:	6a 00                	push   $0x0
  800e27:	6a 00                	push   $0x0
  800e29:	ff 75 10             	pushl  0x10(%ebp)
  800e2c:	ff 75 0c             	pushl  0xc(%ebp)
  800e2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e32:	ba 01 00 00 00       	mov    $0x1,%edx
  800e37:	b8 04 00 00 00       	mov    $0x4,%eax
  800e3c:	e8 c6 fe ff ff       	call   800d07 <syscall>
}
  800e41:	c9                   	leave  
  800e42:	c3                   	ret    

00800e43 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e43:	f3 0f 1e fb          	endbr32 
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800e4d:	ff 75 18             	pushl  0x18(%ebp)
  800e50:	ff 75 14             	pushl  0x14(%ebp)
  800e53:	ff 75 10             	pushl  0x10(%ebp)
  800e56:	ff 75 0c             	pushl  0xc(%ebp)
  800e59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5c:	ba 01 00 00 00       	mov    $0x1,%edx
  800e61:	b8 05 00 00 00       	mov    $0x5,%eax
  800e66:	e8 9c fe ff ff       	call   800d07 <syscall>
}
  800e6b:	c9                   	leave  
  800e6c:	c3                   	ret    

00800e6d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e6d:	f3 0f 1e fb          	endbr32 
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800e77:	6a 00                	push   $0x0
  800e79:	6a 00                	push   $0x0
  800e7b:	6a 00                	push   $0x0
  800e7d:	ff 75 0c             	pushl  0xc(%ebp)
  800e80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e83:	ba 01 00 00 00       	mov    $0x1,%edx
  800e88:	b8 06 00 00 00       	mov    $0x6,%eax
  800e8d:	e8 75 fe ff ff       	call   800d07 <syscall>
}
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    

00800e94 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e94:	f3 0f 1e fb          	endbr32 
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e9e:	6a 00                	push   $0x0
  800ea0:	6a 00                	push   $0x0
  800ea2:	6a 00                	push   $0x0
  800ea4:	ff 75 0c             	pushl  0xc(%ebp)
  800ea7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eaa:	ba 01 00 00 00       	mov    $0x1,%edx
  800eaf:	b8 08 00 00 00       	mov    $0x8,%eax
  800eb4:	e8 4e fe ff ff       	call   800d07 <syscall>
}
  800eb9:	c9                   	leave  
  800eba:	c3                   	ret    

00800ebb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ebb:	f3 0f 1e fb          	endbr32 
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800ec5:	6a 00                	push   $0x0
  800ec7:	6a 00                	push   $0x0
  800ec9:	6a 00                	push   $0x0
  800ecb:	ff 75 0c             	pushl  0xc(%ebp)
  800ece:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed1:	ba 01 00 00 00       	mov    $0x1,%edx
  800ed6:	b8 09 00 00 00       	mov    $0x9,%eax
  800edb:	e8 27 fe ff ff       	call   800d07 <syscall>
}
  800ee0:	c9                   	leave  
  800ee1:	c3                   	ret    

00800ee2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ee2:	f3 0f 1e fb          	endbr32 
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800eec:	6a 00                	push   $0x0
  800eee:	6a 00                	push   $0x0
  800ef0:	6a 00                	push   $0x0
  800ef2:	ff 75 0c             	pushl  0xc(%ebp)
  800ef5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef8:	ba 01 00 00 00       	mov    $0x1,%edx
  800efd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f02:	e8 00 fe ff ff       	call   800d07 <syscall>
}
  800f07:	c9                   	leave  
  800f08:	c3                   	ret    

00800f09 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f09:	f3 0f 1e fb          	endbr32 
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800f13:	6a 00                	push   $0x0
  800f15:	ff 75 14             	pushl  0x14(%ebp)
  800f18:	ff 75 10             	pushl  0x10(%ebp)
  800f1b:	ff 75 0c             	pushl  0xc(%ebp)
  800f1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f21:	ba 00 00 00 00       	mov    $0x0,%edx
  800f26:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f2b:	e8 d7 fd ff ff       	call   800d07 <syscall>
}
  800f30:	c9                   	leave  
  800f31:	c3                   	ret    

00800f32 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f32:	f3 0f 1e fb          	endbr32 
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800f3c:	6a 00                	push   $0x0
  800f3e:	6a 00                	push   $0x0
  800f40:	6a 00                	push   $0x0
  800f42:	6a 00                	push   $0x0
  800f44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f47:	ba 01 00 00 00       	mov    $0x1,%edx
  800f4c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f51:	e8 b1 fd ff ff       	call   800d07 <syscall>
}
  800f56:	c9                   	leave  
  800f57:	c3                   	ret    

00800f58 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	53                   	push   %ebx
  800f5c:	83 ec 04             	sub    $0x4,%esp
	int r;

	// LAB 4: Your code here.
	void *addr = (void *) (pn * PGSIZE);
  800f5f:	89 d3                	mov    %edx,%ebx
  800f61:	c1 e3 0c             	shl    $0xc,%ebx

	if (uvpt[pn] & PTE_SHARE) {
  800f64:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f6b:	f6 c5 04             	test   $0x4,%ch
  800f6e:	75 56                	jne    800fc6 <duppage+0x6e>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
		return 0;
	}

	if ((uvpt[pn] & (PTE_W | PTE_COW)) != 0) {
  800f70:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f77:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800f7d:	74 72                	je     800ff1 <duppage+0x99>
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW) <
  800f7f:	83 ec 0c             	sub    $0xc,%esp
  800f82:	68 05 08 00 00       	push   $0x805
  800f87:	53                   	push   %ebx
  800f88:	50                   	push   %eax
  800f89:	53                   	push   %ebx
  800f8a:	6a 00                	push   $0x0
  800f8c:	e8 b2 fe ff ff       	call   800e43 <sys_page_map>
  800f91:	83 c4 20             	add    $0x20,%esp
  800f94:	85 c0                	test   %eax,%eax
  800f96:	78 45                	js     800fdd <duppage+0x85>
		    0) {
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
		}
		if (sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW) < 0) {
  800f98:	83 ec 0c             	sub    $0xc,%esp
  800f9b:	68 05 08 00 00       	push   $0x805
  800fa0:	53                   	push   %ebx
  800fa1:	6a 00                	push   $0x0
  800fa3:	53                   	push   %ebx
  800fa4:	6a 00                	push   $0x0
  800fa6:	e8 98 fe ff ff       	call   800e43 <sys_page_map>
  800fab:	83 c4 20             	add    $0x20,%esp
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	79 55                	jns    801007 <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP FATHER");
  800fb2:	83 ec 04             	sub    $0x4,%esp
  800fb5:	68 ec 2a 80 00       	push   $0x802aec
  800fba:	6a 54                	push   $0x54
  800fbc:	68 7f 2b 80 00       	push   $0x802b7f
  800fc1:	e8 7c f3 ff ff       	call   800342 <_panic>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800fc6:	83 ec 0c             	sub    $0xc,%esp
  800fc9:	68 07 0e 00 00       	push   $0xe07
  800fce:	53                   	push   %ebx
  800fcf:	50                   	push   %eax
  800fd0:	53                   	push   %ebx
  800fd1:	6a 00                	push   $0x0
  800fd3:	e8 6b fe ff ff       	call   800e43 <sys_page_map>
		return 0;
  800fd8:	83 c4 20             	add    $0x20,%esp
  800fdb:	eb 2a                	jmp    801007 <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
  800fdd:	83 ec 04             	sub    $0x4,%esp
  800fe0:	68 cc 2a 80 00       	push   $0x802acc
  800fe5:	6a 51                	push   $0x51
  800fe7:	68 7f 2b 80 00       	push   $0x802b7f
  800fec:	e8 51 f3 ff ff       	call   800342 <_panic>
		}
	} else {
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U) < 0) {
  800ff1:	83 ec 0c             	sub    $0xc,%esp
  800ff4:	6a 05                	push   $0x5
  800ff6:	53                   	push   %ebx
  800ff7:	50                   	push   %eax
  800ff8:	53                   	push   %ebx
  800ff9:	6a 00                	push   $0x0
  800ffb:	e8 43 fe ff ff       	call   800e43 <sys_page_map>
  801000:	83 c4 20             	add    $0x20,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	78 0a                	js     801011 <duppage+0xb9>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
		}
	}

	return 0;
}
  801007:	b8 00 00 00 00       	mov    $0x0,%eax
  80100c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80100f:	c9                   	leave  
  801010:	c3                   	ret    
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
  801011:	83 ec 04             	sub    $0x4,%esp
  801014:	68 8a 2b 80 00       	push   $0x802b8a
  801019:	6a 58                	push   $0x58
  80101b:	68 7f 2b 80 00       	push   $0x802b7f
  801020:	e8 1d f3 ff ff       	call   800342 <_panic>

00801025 <dup_or_share>:

static void
dup_or_share(envid_t dstenv, void *va, int perm)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	56                   	push   %esi
  801029:	53                   	push   %ebx
  80102a:	89 c6                	mov    %eax,%esi
  80102c:	89 d3                	mov    %edx,%ebx
	int r;
	if (perm & PTE_W) {
  80102e:	f6 c1 02             	test   $0x2,%cl
  801031:	0f 84 8c 00 00 00    	je     8010c3 <dup_or_share+0x9e>
		// dup
		if ((r = sys_page_alloc(dstenv, va, PTE_P | PTE_U | PTE_W)) < 0)
  801037:	83 ec 04             	sub    $0x4,%esp
  80103a:	6a 07                	push   $0x7
  80103c:	52                   	push   %edx
  80103d:	50                   	push   %eax
  80103e:	e8 d8 fd ff ff       	call   800e1b <sys_page_alloc>
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	78 55                	js     80109f <dup_or_share+0x7a>
			panic("sys_page_alloc: %e", r);
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	6a 07                	push   $0x7
  80104f:	68 00 00 40 00       	push   $0x400000
  801054:	6a 00                	push   $0x0
  801056:	53                   	push   %ebx
  801057:	56                   	push   %esi
  801058:	e8 e6 fd ff ff       	call   800e43 <sys_page_map>
  80105d:	83 c4 20             	add    $0x20,%esp
  801060:	85 c0                	test   %eax,%eax
  801062:	78 4d                	js     8010b1 <dup_or_share+0x8c>
		    0)
			panic("sys_page_map: %e", r);
		memmove(UTEMP, va, PGSIZE);
  801064:	83 ec 04             	sub    $0x4,%esp
  801067:	68 00 10 00 00       	push   $0x1000
  80106c:	53                   	push   %ebx
  80106d:	68 00 00 40 00       	push   $0x400000
  801072:	e8 d4 fa ff ff       	call   800b4b <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801077:	83 c4 08             	add    $0x8,%esp
  80107a:	68 00 00 40 00       	push   $0x400000
  80107f:	6a 00                	push   $0x0
  801081:	e8 e7 fd ff ff       	call   800e6d <sys_page_unmap>
  801086:	83 c4 10             	add    $0x10,%esp
  801089:	85 c0                	test   %eax,%eax
  80108b:	79 52                	jns    8010df <dup_or_share+0xba>
			panic("sys_page_unmap: %e", r);
  80108d:	50                   	push   %eax
  80108e:	68 ca 2b 80 00       	push   $0x802bca
  801093:	6a 6c                	push   $0x6c
  801095:	68 7f 2b 80 00       	push   $0x802b7f
  80109a:	e8 a3 f2 ff ff       	call   800342 <_panic>
			panic("sys_page_alloc: %e", r);
  80109f:	50                   	push   %eax
  8010a0:	68 a6 2b 80 00       	push   $0x802ba6
  8010a5:	6a 66                	push   $0x66
  8010a7:	68 7f 2b 80 00       	push   $0x802b7f
  8010ac:	e8 91 f2 ff ff       	call   800342 <_panic>
			panic("sys_page_map: %e", r);
  8010b1:	50                   	push   %eax
  8010b2:	68 b9 2b 80 00       	push   $0x802bb9
  8010b7:	6a 69                	push   $0x69
  8010b9:	68 7f 2b 80 00       	push   $0x802b7f
  8010be:	e8 7f f2 ff ff       	call   800342 <_panic>

	} else {
		// share
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | perm)) <
  8010c3:	83 ec 0c             	sub    $0xc,%esp
  8010c6:	83 c9 05             	or     $0x5,%ecx
  8010c9:	51                   	push   %ecx
  8010ca:	68 00 00 40 00       	push   $0x400000
  8010cf:	6a 00                	push   $0x0
  8010d1:	52                   	push   %edx
  8010d2:	50                   	push   %eax
  8010d3:	e8 6b fd ff ff       	call   800e43 <sys_page_map>
  8010d8:	83 c4 20             	add    $0x20,%esp
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	78 07                	js     8010e6 <dup_or_share+0xc1>
		    0)
			panic("sys_page_map: %e", r);
	}
}
  8010df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e2:	5b                   	pop    %ebx
  8010e3:	5e                   	pop    %esi
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    
			panic("sys_page_map: %e", r);
  8010e6:	50                   	push   %eax
  8010e7:	68 b9 2b 80 00       	push   $0x802bb9
  8010ec:	6a 72                	push   $0x72
  8010ee:	68 7f 2b 80 00       	push   $0x802b7f
  8010f3:	e8 4a f2 ff ff       	call   800342 <_panic>

008010f8 <pgfault>:
{
  8010f8:	f3 0f 1e fb          	endbr32 
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	53                   	push   %ebx
  801100:	83 ec 04             	sub    $0x4,%esp
  801103:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  801106:	8b 02                	mov    (%edx),%eax
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  801108:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  80110c:	0f 84 95 00 00 00    	je     8011a7 <pgfault+0xaf>
  801112:	89 c2                	mov    %eax,%edx
  801114:	c1 ea 16             	shr    $0x16,%edx
  801117:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80111e:	f6 c2 01             	test   $0x1,%dl
  801121:	0f 84 80 00 00 00    	je     8011a7 <pgfault+0xaf>
	    (~uvpt[PGNUM(addr)] & (PTE_COW | PTE_P)) != 0) {
  801127:	89 c2                	mov    %eax,%edx
  801129:	c1 ea 0c             	shr    $0xc,%edx
  80112c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801133:	f7 d2                	not    %edx
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  801135:	f7 c2 01 08 00 00    	test   $0x801,%edx
  80113b:	75 6a                	jne    8011a7 <pgfault+0xaf>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  80113d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801142:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U) < 0) {
  801144:	83 ec 04             	sub    $0x4,%esp
  801147:	6a 07                	push   $0x7
  801149:	68 00 f0 7f 00       	push   $0x7ff000
  80114e:	6a 00                	push   $0x0
  801150:	e8 c6 fc ff ff       	call   800e1b <sys_page_alloc>
  801155:	83 c4 10             	add    $0x10,%esp
  801158:	85 c0                	test   %eax,%eax
  80115a:	78 5f                	js     8011bb <pgfault+0xc3>
	memcpy((void *) PFTEMP, addr, PGSIZE);
  80115c:	83 ec 04             	sub    $0x4,%esp
  80115f:	68 00 10 00 00       	push   $0x1000
  801164:	53                   	push   %ebx
  801165:	68 00 f0 7f 00       	push   $0x7ff000
  80116a:	e8 42 fa ff ff       	call   800bb1 <memcpy>
	if (sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U) < 0) {
  80116f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801176:	53                   	push   %ebx
  801177:	6a 00                	push   $0x0
  801179:	68 00 f0 7f 00       	push   $0x7ff000
  80117e:	6a 00                	push   $0x0
  801180:	e8 be fc ff ff       	call   800e43 <sys_page_map>
  801185:	83 c4 20             	add    $0x20,%esp
  801188:	85 c0                	test   %eax,%eax
  80118a:	78 43                	js     8011cf <pgfault+0xd7>
	if (sys_page_unmap(0, (void *) PFTEMP) < 0) {
  80118c:	83 ec 08             	sub    $0x8,%esp
  80118f:	68 00 f0 7f 00       	push   $0x7ff000
  801194:	6a 00                	push   $0x0
  801196:	e8 d2 fc ff ff       	call   800e6d <sys_page_unmap>
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 41                	js     8011e3 <pgfault+0xeb>
}
  8011a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a5:	c9                   	leave  
  8011a6:	c3                   	ret    
		panic("ERROR PGFAULT");
  8011a7:	83 ec 04             	sub    $0x4,%esp
  8011aa:	68 dd 2b 80 00       	push   $0x802bdd
  8011af:	6a 1e                	push   $0x1e
  8011b1:	68 7f 2b 80 00       	push   $0x802b7f
  8011b6:	e8 87 f1 ff ff       	call   800342 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_ALLOC");
  8011bb:	83 ec 04             	sub    $0x4,%esp
  8011be:	68 eb 2b 80 00       	push   $0x802beb
  8011c3:	6a 2b                	push   $0x2b
  8011c5:	68 7f 2b 80 00       	push   $0x802b7f
  8011ca:	e8 73 f1 ff ff       	call   800342 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_MAP");
  8011cf:	83 ec 04             	sub    $0x4,%esp
  8011d2:	68 09 2c 80 00       	push   $0x802c09
  8011d7:	6a 2f                	push   $0x2f
  8011d9:	68 7f 2b 80 00       	push   $0x802b7f
  8011de:	e8 5f f1 ff ff       	call   800342 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_UNMAP");
  8011e3:	83 ec 04             	sub    $0x4,%esp
  8011e6:	68 25 2c 80 00       	push   $0x802c25
  8011eb:	6a 32                	push   $0x32
  8011ed:	68 7f 2b 80 00       	push   $0x802b7f
  8011f2:	e8 4b f1 ff ff       	call   800342 <_panic>

008011f7 <fork_v0>:

envid_t
fork_v0(void)
{
  8011f7:	f3 0f 1e fb          	endbr32 
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	57                   	push   %edi
  8011ff:	56                   	push   %esi
  801200:	53                   	push   %ebx
  801201:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801204:	b8 07 00 00 00       	mov    $0x7,%eax
  801209:	cd 30                	int    $0x30
	envid_t env_id = sys_exofork();
	if (env_id < 0) {
  80120b:	85 c0                	test   %eax,%eax
  80120d:	78 24                	js     801233 <fork_v0+0x3c>
  80120f:	89 c6                	mov    %eax,%esi
  801211:	89 c7                	mov    %eax,%edi
		thisenv = envs + ENVX(sys_getenvid());
		return env_id;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801213:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (env_id == 0) {  // Son
  801218:	75 51                	jne    80126b <fork_v0+0x74>
		thisenv = envs + ENVX(sys_getenvid());
  80121a:	e8 a9 fb ff ff       	call   800dc8 <sys_getenvid>
  80121f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801224:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801227:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80122c:	a3 04 40 80 00       	mov    %eax,0x804004
		return env_id;
  801231:	eb 78                	jmp    8012ab <fork_v0+0xb4>
		panic("ERROR ON FORK_V0");
  801233:	83 ec 04             	sub    $0x4,%esp
  801236:	68 43 2c 80 00       	push   $0x802c43
  80123b:	6a 7b                	push   $0x7b
  80123d:	68 7f 2b 80 00       	push   $0x802b7f
  801242:	e8 fb f0 ff ff       	call   800342 <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
				dup_or_share(env_id,
  801247:	b9 07 00 00 00       	mov    $0x7,%ecx
  80124c:	89 da                	mov    %ebx,%edx
  80124e:	89 f8                	mov    %edi,%eax
  801250:	e8 d0 fd ff ff       	call   801025 <dup_or_share>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801255:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80125b:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801261:	77 36                	ja     801299 <fork_v0+0xa2>
		if (addr != UXSTACKTOP - PGSIZE) {
  801263:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801269:	74 ea                	je     801255 <fork_v0+0x5e>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80126b:	89 d8                	mov    %ebx,%eax
  80126d:	c1 e8 16             	shr    $0x16,%eax
  801270:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801277:	a8 01                	test   $0x1,%al
  801279:	74 da                	je     801255 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  80127b:	89 d8                	mov    %ebx,%eax
  80127d:	c1 e8 0c             	shr    $0xc,%eax
  801280:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801287:	f6 c2 01             	test   $0x1,%dl
  80128a:	74 c9                	je     801255 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
  80128c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  801293:	a8 04                	test   $0x4,%al
  801295:	74 be                	je     801255 <fork_v0+0x5e>
  801297:	eb ae                	jmp    801247 <fork_v0+0x50>
				             PTE_P | PTE_U | PTE_W);
			}
		}
	}

	if (sys_env_set_status(env_id, ENV_RUNNABLE) < 0) {
  801299:	83 ec 08             	sub    $0x8,%esp
  80129c:	6a 02                	push   $0x2
  80129e:	56                   	push   %esi
  80129f:	e8 f0 fb ff ff       	call   800e94 <sys_env_set_status>
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	78 0a                	js     8012b5 <fork_v0+0xbe>
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
	}

	return env_id;
}
  8012ab:	89 f0                	mov    %esi,%eax
  8012ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b0:	5b                   	pop    %ebx
  8012b1:	5e                   	pop    %esi
  8012b2:	5f                   	pop    %edi
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
  8012b5:	83 ec 04             	sub    $0x4,%esp
  8012b8:	68 10 2b 80 00       	push   $0x802b10
  8012bd:	68 92 00 00 00       	push   $0x92
  8012c2:	68 7f 2b 80 00       	push   $0x802b7f
  8012c7:	e8 76 f0 ff ff       	call   800342 <_panic>

008012cc <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8012cc:	f3 0f 1e fb          	endbr32 
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	57                   	push   %edi
  8012d4:	56                   	push   %esi
  8012d5:	53                   	push   %ebx
  8012d6:	83 ec 18             	sub    $0x18,%esp
	// return fork_v0(); // Uncomment this line if you want to run fork_v0.
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8012d9:	68 f8 10 80 00       	push   $0x8010f8
  8012de:	e8 fe 0e 00 00       	call   8021e1 <set_pgfault_handler>
  8012e3:	b8 07 00 00 00       	mov    $0x7,%eax
  8012e8:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0) {
  8012ea:	83 c4 10             	add    $0x10,%esp
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 27                	js     801318 <fork+0x4c>
  8012f1:	89 c7                	mov    %eax,%edi
  8012f3:	89 c6                	mov    %eax,%esi
		thisenv = envs + ENVX(sys_getenvid());
		return envid;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  8012f5:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else if (envid == 0) {  // Son
  8012fa:	75 55                	jne    801351 <fork+0x85>
		thisenv = envs + ENVX(sys_getenvid());
  8012fc:	e8 c7 fa ff ff       	call   800dc8 <sys_getenvid>
  801301:	25 ff 03 00 00       	and    $0x3ff,%eax
  801306:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801309:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80130e:	a3 04 40 80 00       	mov    %eax,0x804004
		return envid;
  801313:	e9 9b 00 00 00       	jmp    8013b3 <fork+0xe7>
		panic("ERROR IN FORK: SYS_EXOFORK");
  801318:	83 ec 04             	sub    $0x4,%esp
  80131b:	68 54 2c 80 00       	push   $0x802c54
  801320:	68 b1 00 00 00       	push   $0xb1
  801325:	68 7f 2b 80 00       	push   $0x802b7f
  80132a:	e8 13 f0 ff ff       	call   800342 <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
				duppage(envid, addr / PGSIZE);
  80132f:	89 da                	mov    %ebx,%edx
  801331:	c1 ea 0c             	shr    $0xc,%edx
  801334:	89 f0                	mov    %esi,%eax
  801336:	e8 1d fc ff ff       	call   800f58 <duppage>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  80133b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801341:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801347:	77 2c                	ja     801375 <fork+0xa9>
		if (addr != UXSTACKTOP - PGSIZE) {
  801349:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80134f:	74 ea                	je     80133b <fork+0x6f>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801351:	89 d8                	mov    %ebx,%eax
  801353:	c1 e8 16             	shr    $0x16,%eax
  801356:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80135d:	a8 01                	test   $0x1,%al
  80135f:	74 da                	je     80133b <fork+0x6f>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
  801361:	89 d8                	mov    %ebx,%eax
  801363:	c1 e8 0c             	shr    $0xc,%eax
  801366:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80136d:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80136f:	a8 05                	test   $0x5,%al
  801371:	75 c8                	jne    80133b <fork+0x6f>
  801373:	eb ba                	jmp    80132f <fork+0x63>
			}
		}
	}

	if (sys_page_alloc(envid,
  801375:	83 ec 04             	sub    $0x4,%esp
  801378:	6a 07                	push   $0x7
  80137a:	68 00 f0 bf ee       	push   $0xeebff000
  80137f:	57                   	push   %edi
  801380:	e8 96 fa ff ff       	call   800e1b <sys_page_alloc>
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 31                	js     8013bd <fork+0xf1>
	                   PTE_P | PTE_U | PTE_W) < 0) {
		panic("ERROR FORK: SYS_PAGE_ALLOC");
	}

	extern void _pgfault_upcall(void);
	if (sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0) {
  80138c:	83 ec 08             	sub    $0x8,%esp
  80138f:	68 54 22 80 00       	push   $0x802254
  801394:	57                   	push   %edi
  801395:	e8 48 fb ff ff       	call   800ee2 <sys_env_set_pgfault_upcall>
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 33                	js     8013d4 <fork+0x108>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
	}

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0) {
  8013a1:	83 ec 08             	sub    $0x8,%esp
  8013a4:	6a 02                	push   $0x2
  8013a6:	57                   	push   %edi
  8013a7:	e8 e8 fa ff ff       	call   800e94 <sys_env_set_status>
  8013ac:	83 c4 10             	add    $0x10,%esp
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	78 38                	js     8013eb <fork+0x11f>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
	}

	return envid;
}
  8013b3:	89 f8                	mov    %edi,%eax
  8013b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b8:	5b                   	pop    %ebx
  8013b9:	5e                   	pop    %esi
  8013ba:	5f                   	pop    %edi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    
		panic("ERROR FORK: SYS_PAGE_ALLOC");
  8013bd:	83 ec 04             	sub    $0x4,%esp
  8013c0:	68 6f 2c 80 00       	push   $0x802c6f
  8013c5:	68 c4 00 00 00       	push   $0xc4
  8013ca:	68 7f 2b 80 00       	push   $0x802b7f
  8013cf:	e8 6e ef ff ff       	call   800342 <_panic>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
  8013d4:	83 ec 04             	sub    $0x4,%esp
  8013d7:	68 38 2b 80 00       	push   $0x802b38
  8013dc:	68 c9 00 00 00       	push   $0xc9
  8013e1:	68 7f 2b 80 00       	push   $0x802b7f
  8013e6:	e8 57 ef ff ff       	call   800342 <_panic>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
  8013eb:	83 ec 04             	sub    $0x4,%esp
  8013ee:	68 60 2b 80 00       	push   $0x802b60
  8013f3:	68 cd 00 00 00       	push   $0xcd
  8013f8:	68 7f 2b 80 00       	push   $0x802b7f
  8013fd:	e8 40 ef ff ff       	call   800342 <_panic>

00801402 <sfork>:

// Challenge!
int
sfork(void)
{
  801402:	f3 0f 1e fb          	endbr32 
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80140c:	68 8a 2c 80 00       	push   $0x802c8a
  801411:	68 d7 00 00 00       	push   $0xd7
  801416:	68 7f 2b 80 00       	push   $0x802b7f
  80141b:	e8 22 ef ff ff       	call   800342 <_panic>

00801420 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801420:	f3 0f 1e fb          	endbr32 
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801427:	8b 45 08             	mov    0x8(%ebp),%eax
  80142a:	05 00 00 00 30       	add    $0x30000000,%eax
  80142f:	c1 e8 0c             	shr    $0xc,%eax
}
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    

00801434 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801434:	f3 0f 1e fb          	endbr32 
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  80143e:	ff 75 08             	pushl  0x8(%ebp)
  801441:	e8 da ff ff ff       	call   801420 <fd2num>
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	c1 e0 0c             	shl    $0xc,%eax
  80144c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801451:	c9                   	leave  
  801452:	c3                   	ret    

00801453 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801453:	f3 0f 1e fb          	endbr32 
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80145f:	89 c2                	mov    %eax,%edx
  801461:	c1 ea 16             	shr    $0x16,%edx
  801464:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80146b:	f6 c2 01             	test   $0x1,%dl
  80146e:	74 2d                	je     80149d <fd_alloc+0x4a>
  801470:	89 c2                	mov    %eax,%edx
  801472:	c1 ea 0c             	shr    $0xc,%edx
  801475:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80147c:	f6 c2 01             	test   $0x1,%dl
  80147f:	74 1c                	je     80149d <fd_alloc+0x4a>
  801481:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801486:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80148b:	75 d2                	jne    80145f <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80148d:	8b 45 08             	mov    0x8(%ebp),%eax
  801490:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801496:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80149b:	eb 0a                	jmp    8014a7 <fd_alloc+0x54>
			*fd_store = fd;
  80149d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014a0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a7:	5d                   	pop    %ebp
  8014a8:	c3                   	ret    

008014a9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014a9:	f3 0f 1e fb          	endbr32 
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014b3:	83 f8 1f             	cmp    $0x1f,%eax
  8014b6:	77 30                	ja     8014e8 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014b8:	c1 e0 0c             	shl    $0xc,%eax
  8014bb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014c0:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8014c6:	f6 c2 01             	test   $0x1,%dl
  8014c9:	74 24                	je     8014ef <fd_lookup+0x46>
  8014cb:	89 c2                	mov    %eax,%edx
  8014cd:	c1 ea 0c             	shr    $0xc,%edx
  8014d0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014d7:	f6 c2 01             	test   $0x1,%dl
  8014da:	74 1a                	je     8014f6 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014df:	89 02                	mov    %eax,(%edx)
	return 0;
  8014e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e6:	5d                   	pop    %ebp
  8014e7:	c3                   	ret    
		return -E_INVAL;
  8014e8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ed:	eb f7                	jmp    8014e6 <fd_lookup+0x3d>
		return -E_INVAL;
  8014ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f4:	eb f0                	jmp    8014e6 <fd_lookup+0x3d>
  8014f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014fb:	eb e9                	jmp    8014e6 <fd_lookup+0x3d>

008014fd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014fd:	f3 0f 1e fb          	endbr32 
  801501:	55                   	push   %ebp
  801502:	89 e5                	mov    %esp,%ebp
  801504:	83 ec 08             	sub    $0x8,%esp
  801507:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80150a:	ba 1c 2d 80 00       	mov    $0x802d1c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80150f:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
  801514:	39 08                	cmp    %ecx,(%eax)
  801516:	74 33                	je     80154b <dev_lookup+0x4e>
  801518:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80151b:	8b 02                	mov    (%edx),%eax
  80151d:	85 c0                	test   %eax,%eax
  80151f:	75 f3                	jne    801514 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801521:	a1 04 40 80 00       	mov    0x804004,%eax
  801526:	8b 40 48             	mov    0x48(%eax),%eax
  801529:	83 ec 04             	sub    $0x4,%esp
  80152c:	51                   	push   %ecx
  80152d:	50                   	push   %eax
  80152e:	68 a0 2c 80 00       	push   $0x802ca0
  801533:	e8 f1 ee ff ff       	call   800429 <cprintf>
	*dev = 0;
  801538:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801541:	83 c4 10             	add    $0x10,%esp
  801544:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801549:	c9                   	leave  
  80154a:	c3                   	ret    
			*dev = devtab[i];
  80154b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80154e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801550:	b8 00 00 00 00       	mov    $0x0,%eax
  801555:	eb f2                	jmp    801549 <dev_lookup+0x4c>

00801557 <fd_close>:
{
  801557:	f3 0f 1e fb          	endbr32 
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	57                   	push   %edi
  80155f:	56                   	push   %esi
  801560:	53                   	push   %ebx
  801561:	83 ec 28             	sub    $0x28,%esp
  801564:	8b 75 08             	mov    0x8(%ebp),%esi
  801567:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80156a:	56                   	push   %esi
  80156b:	e8 b0 fe ff ff       	call   801420 <fd2num>
  801570:	83 c4 08             	add    $0x8,%esp
  801573:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801576:	52                   	push   %edx
  801577:	50                   	push   %eax
  801578:	e8 2c ff ff ff       	call   8014a9 <fd_lookup>
  80157d:	89 c3                	mov    %eax,%ebx
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	85 c0                	test   %eax,%eax
  801584:	78 05                	js     80158b <fd_close+0x34>
	    || fd != fd2)
  801586:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801589:	74 16                	je     8015a1 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80158b:	89 f8                	mov    %edi,%eax
  80158d:	84 c0                	test   %al,%al
  80158f:	b8 00 00 00 00       	mov    $0x0,%eax
  801594:	0f 44 d8             	cmove  %eax,%ebx
}
  801597:	89 d8                	mov    %ebx,%eax
  801599:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80159c:	5b                   	pop    %ebx
  80159d:	5e                   	pop    %esi
  80159e:	5f                   	pop    %edi
  80159f:	5d                   	pop    %ebp
  8015a0:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015a1:	83 ec 08             	sub    $0x8,%esp
  8015a4:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8015a7:	50                   	push   %eax
  8015a8:	ff 36                	pushl  (%esi)
  8015aa:	e8 4e ff ff ff       	call   8014fd <dev_lookup>
  8015af:	89 c3                	mov    %eax,%ebx
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	78 1a                	js     8015d2 <fd_close+0x7b>
		if (dev->dev_close)
  8015b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015bb:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8015be:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	74 0b                	je     8015d2 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8015c7:	83 ec 0c             	sub    $0xc,%esp
  8015ca:	56                   	push   %esi
  8015cb:	ff d0                	call   *%eax
  8015cd:	89 c3                	mov    %eax,%ebx
  8015cf:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8015d2:	83 ec 08             	sub    $0x8,%esp
  8015d5:	56                   	push   %esi
  8015d6:	6a 00                	push   $0x0
  8015d8:	e8 90 f8 ff ff       	call   800e6d <sys_page_unmap>
	return r;
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	eb b5                	jmp    801597 <fd_close+0x40>

008015e2 <close>:

int
close(int fdnum)
{
  8015e2:	f3 0f 1e fb          	endbr32 
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ef:	50                   	push   %eax
  8015f0:	ff 75 08             	pushl  0x8(%ebp)
  8015f3:	e8 b1 fe ff ff       	call   8014a9 <fd_lookup>
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	79 02                	jns    801601 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8015ff:	c9                   	leave  
  801600:	c3                   	ret    
		return fd_close(fd, 1);
  801601:	83 ec 08             	sub    $0x8,%esp
  801604:	6a 01                	push   $0x1
  801606:	ff 75 f4             	pushl  -0xc(%ebp)
  801609:	e8 49 ff ff ff       	call   801557 <fd_close>
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	eb ec                	jmp    8015ff <close+0x1d>

00801613 <close_all>:

void
close_all(void)
{
  801613:	f3 0f 1e fb          	endbr32 
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	53                   	push   %ebx
  80161b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80161e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801623:	83 ec 0c             	sub    $0xc,%esp
  801626:	53                   	push   %ebx
  801627:	e8 b6 ff ff ff       	call   8015e2 <close>
	for (i = 0; i < MAXFD; i++)
  80162c:	83 c3 01             	add    $0x1,%ebx
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	83 fb 20             	cmp    $0x20,%ebx
  801635:	75 ec                	jne    801623 <close_all+0x10>
}
  801637:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80163c:	f3 0f 1e fb          	endbr32 
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	57                   	push   %edi
  801644:	56                   	push   %esi
  801645:	53                   	push   %ebx
  801646:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801649:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80164c:	50                   	push   %eax
  80164d:	ff 75 08             	pushl  0x8(%ebp)
  801650:	e8 54 fe ff ff       	call   8014a9 <fd_lookup>
  801655:	89 c3                	mov    %eax,%ebx
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	85 c0                	test   %eax,%eax
  80165c:	0f 88 81 00 00 00    	js     8016e3 <dup+0xa7>
		return r;
	close(newfdnum);
  801662:	83 ec 0c             	sub    $0xc,%esp
  801665:	ff 75 0c             	pushl  0xc(%ebp)
  801668:	e8 75 ff ff ff       	call   8015e2 <close>

	newfd = INDEX2FD(newfdnum);
  80166d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801670:	c1 e6 0c             	shl    $0xc,%esi
  801673:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801679:	83 c4 04             	add    $0x4,%esp
  80167c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80167f:	e8 b0 fd ff ff       	call   801434 <fd2data>
  801684:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801686:	89 34 24             	mov    %esi,(%esp)
  801689:	e8 a6 fd ff ff       	call   801434 <fd2data>
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801693:	89 d8                	mov    %ebx,%eax
  801695:	c1 e8 16             	shr    $0x16,%eax
  801698:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80169f:	a8 01                	test   $0x1,%al
  8016a1:	74 11                	je     8016b4 <dup+0x78>
  8016a3:	89 d8                	mov    %ebx,%eax
  8016a5:	c1 e8 0c             	shr    $0xc,%eax
  8016a8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016af:	f6 c2 01             	test   $0x1,%dl
  8016b2:	75 39                	jne    8016ed <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016b7:	89 d0                	mov    %edx,%eax
  8016b9:	c1 e8 0c             	shr    $0xc,%eax
  8016bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016c3:	83 ec 0c             	sub    $0xc,%esp
  8016c6:	25 07 0e 00 00       	and    $0xe07,%eax
  8016cb:	50                   	push   %eax
  8016cc:	56                   	push   %esi
  8016cd:	6a 00                	push   $0x0
  8016cf:	52                   	push   %edx
  8016d0:	6a 00                	push   $0x0
  8016d2:	e8 6c f7 ff ff       	call   800e43 <sys_page_map>
  8016d7:	89 c3                	mov    %eax,%ebx
  8016d9:	83 c4 20             	add    $0x20,%esp
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 31                	js     801711 <dup+0xd5>
		goto err;

	return newfdnum;
  8016e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016e3:	89 d8                	mov    %ebx,%eax
  8016e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e8:	5b                   	pop    %ebx
  8016e9:	5e                   	pop    %esi
  8016ea:	5f                   	pop    %edi
  8016eb:	5d                   	pop    %ebp
  8016ec:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016f4:	83 ec 0c             	sub    $0xc,%esp
  8016f7:	25 07 0e 00 00       	and    $0xe07,%eax
  8016fc:	50                   	push   %eax
  8016fd:	57                   	push   %edi
  8016fe:	6a 00                	push   $0x0
  801700:	53                   	push   %ebx
  801701:	6a 00                	push   $0x0
  801703:	e8 3b f7 ff ff       	call   800e43 <sys_page_map>
  801708:	89 c3                	mov    %eax,%ebx
  80170a:	83 c4 20             	add    $0x20,%esp
  80170d:	85 c0                	test   %eax,%eax
  80170f:	79 a3                	jns    8016b4 <dup+0x78>
	sys_page_unmap(0, newfd);
  801711:	83 ec 08             	sub    $0x8,%esp
  801714:	56                   	push   %esi
  801715:	6a 00                	push   $0x0
  801717:	e8 51 f7 ff ff       	call   800e6d <sys_page_unmap>
	sys_page_unmap(0, nva);
  80171c:	83 c4 08             	add    $0x8,%esp
  80171f:	57                   	push   %edi
  801720:	6a 00                	push   $0x0
  801722:	e8 46 f7 ff ff       	call   800e6d <sys_page_unmap>
	return r;
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	eb b7                	jmp    8016e3 <dup+0xa7>

0080172c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80172c:	f3 0f 1e fb          	endbr32 
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	53                   	push   %ebx
  801734:	83 ec 1c             	sub    $0x1c,%esp
  801737:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173d:	50                   	push   %eax
  80173e:	53                   	push   %ebx
  80173f:	e8 65 fd ff ff       	call   8014a9 <fd_lookup>
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	85 c0                	test   %eax,%eax
  801749:	78 3f                	js     80178a <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174b:	83 ec 08             	sub    $0x8,%esp
  80174e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801751:	50                   	push   %eax
  801752:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801755:	ff 30                	pushl  (%eax)
  801757:	e8 a1 fd ff ff       	call   8014fd <dev_lookup>
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	85 c0                	test   %eax,%eax
  801761:	78 27                	js     80178a <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801763:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801766:	8b 42 08             	mov    0x8(%edx),%eax
  801769:	83 e0 03             	and    $0x3,%eax
  80176c:	83 f8 01             	cmp    $0x1,%eax
  80176f:	74 1e                	je     80178f <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801771:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801774:	8b 40 08             	mov    0x8(%eax),%eax
  801777:	85 c0                	test   %eax,%eax
  801779:	74 35                	je     8017b0 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80177b:	83 ec 04             	sub    $0x4,%esp
  80177e:	ff 75 10             	pushl  0x10(%ebp)
  801781:	ff 75 0c             	pushl  0xc(%ebp)
  801784:	52                   	push   %edx
  801785:	ff d0                	call   *%eax
  801787:	83 c4 10             	add    $0x10,%esp
}
  80178a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178d:	c9                   	leave  
  80178e:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80178f:	a1 04 40 80 00       	mov    0x804004,%eax
  801794:	8b 40 48             	mov    0x48(%eax),%eax
  801797:	83 ec 04             	sub    $0x4,%esp
  80179a:	53                   	push   %ebx
  80179b:	50                   	push   %eax
  80179c:	68 e1 2c 80 00       	push   $0x802ce1
  8017a1:	e8 83 ec ff ff       	call   800429 <cprintf>
		return -E_INVAL;
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017ae:	eb da                	jmp    80178a <read+0x5e>
		return -E_NOT_SUPP;
  8017b0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017b5:	eb d3                	jmp    80178a <read+0x5e>

008017b7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017b7:	f3 0f 1e fb          	endbr32 
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	57                   	push   %edi
  8017bf:	56                   	push   %esi
  8017c0:	53                   	push   %ebx
  8017c1:	83 ec 0c             	sub    $0xc,%esp
  8017c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017c7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017cf:	eb 02                	jmp    8017d3 <readn+0x1c>
  8017d1:	01 c3                	add    %eax,%ebx
  8017d3:	39 f3                	cmp    %esi,%ebx
  8017d5:	73 21                	jae    8017f8 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017d7:	83 ec 04             	sub    $0x4,%esp
  8017da:	89 f0                	mov    %esi,%eax
  8017dc:	29 d8                	sub    %ebx,%eax
  8017de:	50                   	push   %eax
  8017df:	89 d8                	mov    %ebx,%eax
  8017e1:	03 45 0c             	add    0xc(%ebp),%eax
  8017e4:	50                   	push   %eax
  8017e5:	57                   	push   %edi
  8017e6:	e8 41 ff ff ff       	call   80172c <read>
		if (m < 0)
  8017eb:	83 c4 10             	add    $0x10,%esp
  8017ee:	85 c0                	test   %eax,%eax
  8017f0:	78 04                	js     8017f6 <readn+0x3f>
			return m;
		if (m == 0)
  8017f2:	75 dd                	jne    8017d1 <readn+0x1a>
  8017f4:	eb 02                	jmp    8017f8 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017f6:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8017f8:	89 d8                	mov    %ebx,%eax
  8017fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017fd:	5b                   	pop    %ebx
  8017fe:	5e                   	pop    %esi
  8017ff:	5f                   	pop    %edi
  801800:	5d                   	pop    %ebp
  801801:	c3                   	ret    

00801802 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801802:	f3 0f 1e fb          	endbr32 
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	53                   	push   %ebx
  80180a:	83 ec 1c             	sub    $0x1c,%esp
  80180d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801810:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801813:	50                   	push   %eax
  801814:	53                   	push   %ebx
  801815:	e8 8f fc ff ff       	call   8014a9 <fd_lookup>
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	85 c0                	test   %eax,%eax
  80181f:	78 3a                	js     80185b <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801821:	83 ec 08             	sub    $0x8,%esp
  801824:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801827:	50                   	push   %eax
  801828:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80182b:	ff 30                	pushl  (%eax)
  80182d:	e8 cb fc ff ff       	call   8014fd <dev_lookup>
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	85 c0                	test   %eax,%eax
  801837:	78 22                	js     80185b <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801839:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801840:	74 1e                	je     801860 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801842:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801845:	8b 52 0c             	mov    0xc(%edx),%edx
  801848:	85 d2                	test   %edx,%edx
  80184a:	74 35                	je     801881 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80184c:	83 ec 04             	sub    $0x4,%esp
  80184f:	ff 75 10             	pushl  0x10(%ebp)
  801852:	ff 75 0c             	pushl  0xc(%ebp)
  801855:	50                   	push   %eax
  801856:	ff d2                	call   *%edx
  801858:	83 c4 10             	add    $0x10,%esp
}
  80185b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185e:	c9                   	leave  
  80185f:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801860:	a1 04 40 80 00       	mov    0x804004,%eax
  801865:	8b 40 48             	mov    0x48(%eax),%eax
  801868:	83 ec 04             	sub    $0x4,%esp
  80186b:	53                   	push   %ebx
  80186c:	50                   	push   %eax
  80186d:	68 fd 2c 80 00       	push   $0x802cfd
  801872:	e8 b2 eb ff ff       	call   800429 <cprintf>
		return -E_INVAL;
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80187f:	eb da                	jmp    80185b <write+0x59>
		return -E_NOT_SUPP;
  801881:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801886:	eb d3                	jmp    80185b <write+0x59>

00801888 <seek>:

int
seek(int fdnum, off_t offset)
{
  801888:	f3 0f 1e fb          	endbr32 
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801892:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801895:	50                   	push   %eax
  801896:	ff 75 08             	pushl  0x8(%ebp)
  801899:	e8 0b fc ff ff       	call   8014a9 <fd_lookup>
  80189e:	83 c4 10             	add    $0x10,%esp
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	78 0e                	js     8018b3 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8018a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ab:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018b3:	c9                   	leave  
  8018b4:	c3                   	ret    

008018b5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018b5:	f3 0f 1e fb          	endbr32 
  8018b9:	55                   	push   %ebp
  8018ba:	89 e5                	mov    %esp,%ebp
  8018bc:	53                   	push   %ebx
  8018bd:	83 ec 1c             	sub    $0x1c,%esp
  8018c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c6:	50                   	push   %eax
  8018c7:	53                   	push   %ebx
  8018c8:	e8 dc fb ff ff       	call   8014a9 <fd_lookup>
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	78 37                	js     80190b <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018da:	50                   	push   %eax
  8018db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018de:	ff 30                	pushl  (%eax)
  8018e0:	e8 18 fc ff ff       	call   8014fd <dev_lookup>
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	85 c0                	test   %eax,%eax
  8018ea:	78 1f                	js     80190b <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ef:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018f3:	74 1b                	je     801910 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8018f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f8:	8b 52 18             	mov    0x18(%edx),%edx
  8018fb:	85 d2                	test   %edx,%edx
  8018fd:	74 32                	je     801931 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018ff:	83 ec 08             	sub    $0x8,%esp
  801902:	ff 75 0c             	pushl  0xc(%ebp)
  801905:	50                   	push   %eax
  801906:	ff d2                	call   *%edx
  801908:	83 c4 10             	add    $0x10,%esp
}
  80190b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    
			thisenv->env_id, fdnum);
  801910:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801915:	8b 40 48             	mov    0x48(%eax),%eax
  801918:	83 ec 04             	sub    $0x4,%esp
  80191b:	53                   	push   %ebx
  80191c:	50                   	push   %eax
  80191d:	68 c0 2c 80 00       	push   $0x802cc0
  801922:	e8 02 eb ff ff       	call   800429 <cprintf>
		return -E_INVAL;
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80192f:	eb da                	jmp    80190b <ftruncate+0x56>
		return -E_NOT_SUPP;
  801931:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801936:	eb d3                	jmp    80190b <ftruncate+0x56>

00801938 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801938:	f3 0f 1e fb          	endbr32 
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	53                   	push   %ebx
  801940:	83 ec 1c             	sub    $0x1c,%esp
  801943:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801946:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801949:	50                   	push   %eax
  80194a:	ff 75 08             	pushl  0x8(%ebp)
  80194d:	e8 57 fb ff ff       	call   8014a9 <fd_lookup>
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	85 c0                	test   %eax,%eax
  801957:	78 4b                	js     8019a4 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801959:	83 ec 08             	sub    $0x8,%esp
  80195c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195f:	50                   	push   %eax
  801960:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801963:	ff 30                	pushl  (%eax)
  801965:	e8 93 fb ff ff       	call   8014fd <dev_lookup>
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	85 c0                	test   %eax,%eax
  80196f:	78 33                	js     8019a4 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801971:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801974:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801978:	74 2f                	je     8019a9 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80197a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80197d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801984:	00 00 00 
	stat->st_isdir = 0;
  801987:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80198e:	00 00 00 
	stat->st_dev = dev;
  801991:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801997:	83 ec 08             	sub    $0x8,%esp
  80199a:	53                   	push   %ebx
  80199b:	ff 75 f0             	pushl  -0x10(%ebp)
  80199e:	ff 50 14             	call   *0x14(%eax)
  8019a1:	83 c4 10             	add    $0x10,%esp
}
  8019a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a7:	c9                   	leave  
  8019a8:	c3                   	ret    
		return -E_NOT_SUPP;
  8019a9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019ae:	eb f4                	jmp    8019a4 <fstat+0x6c>

008019b0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019b0:	f3 0f 1e fb          	endbr32 
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	56                   	push   %esi
  8019b8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019b9:	83 ec 08             	sub    $0x8,%esp
  8019bc:	6a 00                	push   $0x0
  8019be:	ff 75 08             	pushl  0x8(%ebp)
  8019c1:	e8 20 02 00 00       	call   801be6 <open>
  8019c6:	89 c3                	mov    %eax,%ebx
  8019c8:	83 c4 10             	add    $0x10,%esp
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	78 1b                	js     8019ea <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8019cf:	83 ec 08             	sub    $0x8,%esp
  8019d2:	ff 75 0c             	pushl  0xc(%ebp)
  8019d5:	50                   	push   %eax
  8019d6:	e8 5d ff ff ff       	call   801938 <fstat>
  8019db:	89 c6                	mov    %eax,%esi
	close(fd);
  8019dd:	89 1c 24             	mov    %ebx,(%esp)
  8019e0:	e8 fd fb ff ff       	call   8015e2 <close>
	return r;
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	89 f3                	mov    %esi,%ebx
}
  8019ea:	89 d8                	mov    %ebx,%eax
  8019ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ef:	5b                   	pop    %ebx
  8019f0:	5e                   	pop    %esi
  8019f1:	5d                   	pop    %ebp
  8019f2:	c3                   	ret    

008019f3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	56                   	push   %esi
  8019f7:	53                   	push   %ebx
  8019f8:	89 c6                	mov    %eax,%esi
  8019fa:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019fc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a03:	74 27                	je     801a2c <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a05:	6a 07                	push   $0x7
  801a07:	68 00 50 80 00       	push   $0x805000
  801a0c:	56                   	push   %esi
  801a0d:	ff 35 00 40 80 00    	pushl  0x804000
  801a13:	e8 cf 08 00 00       	call   8022e7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a18:	83 c4 0c             	add    $0xc,%esp
  801a1b:	6a 00                	push   $0x0
  801a1d:	53                   	push   %ebx
  801a1e:	6a 00                	push   $0x0
  801a20:	e8 55 08 00 00       	call   80227a <ipc_recv>
}
  801a25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a28:	5b                   	pop    %ebx
  801a29:	5e                   	pop    %esi
  801a2a:	5d                   	pop    %ebp
  801a2b:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a2c:	83 ec 0c             	sub    $0xc,%esp
  801a2f:	6a 01                	push   $0x1
  801a31:	e8 04 09 00 00       	call   80233a <ipc_find_env>
  801a36:	a3 00 40 80 00       	mov    %eax,0x804000
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	eb c5                	jmp    801a05 <fsipc+0x12>

00801a40 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a40:	f3 0f 1e fb          	endbr32 
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a50:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a58:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a62:	b8 02 00 00 00       	mov    $0x2,%eax
  801a67:	e8 87 ff ff ff       	call   8019f3 <fsipc>
}
  801a6c:	c9                   	leave  
  801a6d:	c3                   	ret    

00801a6e <devfile_flush>:
{
  801a6e:	f3 0f 1e fb          	endbr32 
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a78:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a7e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a83:	ba 00 00 00 00       	mov    $0x0,%edx
  801a88:	b8 06 00 00 00       	mov    $0x6,%eax
  801a8d:	e8 61 ff ff ff       	call   8019f3 <fsipc>
}
  801a92:	c9                   	leave  
  801a93:	c3                   	ret    

00801a94 <devfile_stat>:
{
  801a94:	f3 0f 1e fb          	endbr32 
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	53                   	push   %ebx
  801a9c:	83 ec 04             	sub    $0x4,%esp
  801a9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa5:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801aad:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab2:	b8 05 00 00 00       	mov    $0x5,%eax
  801ab7:	e8 37 ff ff ff       	call   8019f3 <fsipc>
  801abc:	85 c0                	test   %eax,%eax
  801abe:	78 2c                	js     801aec <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ac0:	83 ec 08             	sub    $0x8,%esp
  801ac3:	68 00 50 80 00       	push   $0x805000
  801ac8:	53                   	push   %ebx
  801ac9:	e8 c5 ee ff ff       	call   800993 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ace:	a1 80 50 80 00       	mov    0x805080,%eax
  801ad3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ad9:	a1 84 50 80 00       	mov    0x805084,%eax
  801ade:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aef:	c9                   	leave  
  801af0:	c3                   	ret    

00801af1 <devfile_write>:
{
  801af1:	f3 0f 1e fb          	endbr32 
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	57                   	push   %edi
  801af9:	56                   	push   %esi
  801afa:	53                   	push   %ebx
  801afb:	83 ec 0c             	sub    $0xc,%esp
  801afe:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b04:	8b 45 08             	mov    0x8(%ebp),%eax
  801b07:	8b 40 0c             	mov    0xc(%eax),%eax
  801b0a:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  801b0f:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b14:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  801b19:	85 db                	test   %ebx,%ebx
  801b1b:	74 3b                	je     801b58 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b1d:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801b23:	89 f8                	mov    %edi,%eax
  801b25:	0f 46 c3             	cmovbe %ebx,%eax
  801b28:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  801b2d:	83 ec 04             	sub    $0x4,%esp
  801b30:	50                   	push   %eax
  801b31:	56                   	push   %esi
  801b32:	68 08 50 80 00       	push   $0x805008
  801b37:	e8 0f f0 ff ff       	call   800b4b <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b3c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b41:	b8 04 00 00 00       	mov    $0x4,%eax
  801b46:	e8 a8 fe ff ff       	call   8019f3 <fsipc>
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	78 06                	js     801b58 <devfile_write+0x67>
		buf_aux += r;
  801b52:	01 c6                	add    %eax,%esi
		n -= r;
  801b54:	29 c3                	sub    %eax,%ebx
  801b56:	eb c1                	jmp    801b19 <devfile_write+0x28>
}
  801b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5b:	5b                   	pop    %ebx
  801b5c:	5e                   	pop    %esi
  801b5d:	5f                   	pop    %edi
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <devfile_read>:
{
  801b60:	f3 0f 1e fb          	endbr32 
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	56                   	push   %esi
  801b68:	53                   	push   %ebx
  801b69:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b72:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b77:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b7d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b82:	b8 03 00 00 00       	mov    $0x3,%eax
  801b87:	e8 67 fe ff ff       	call   8019f3 <fsipc>
  801b8c:	89 c3                	mov    %eax,%ebx
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	78 1f                	js     801bb1 <devfile_read+0x51>
	assert(r <= n);
  801b92:	39 f0                	cmp    %esi,%eax
  801b94:	77 24                	ja     801bba <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801b96:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b9b:	7f 33                	jg     801bd0 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b9d:	83 ec 04             	sub    $0x4,%esp
  801ba0:	50                   	push   %eax
  801ba1:	68 00 50 80 00       	push   $0x805000
  801ba6:	ff 75 0c             	pushl  0xc(%ebp)
  801ba9:	e8 9d ef ff ff       	call   800b4b <memmove>
	return r;
  801bae:	83 c4 10             	add    $0x10,%esp
}
  801bb1:	89 d8                	mov    %ebx,%eax
  801bb3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb6:	5b                   	pop    %ebx
  801bb7:	5e                   	pop    %esi
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    
	assert(r <= n);
  801bba:	68 2c 2d 80 00       	push   $0x802d2c
  801bbf:	68 33 2d 80 00       	push   $0x802d33
  801bc4:	6a 7c                	push   $0x7c
  801bc6:	68 48 2d 80 00       	push   $0x802d48
  801bcb:	e8 72 e7 ff ff       	call   800342 <_panic>
	assert(r <= PGSIZE);
  801bd0:	68 53 2d 80 00       	push   $0x802d53
  801bd5:	68 33 2d 80 00       	push   $0x802d33
  801bda:	6a 7d                	push   $0x7d
  801bdc:	68 48 2d 80 00       	push   $0x802d48
  801be1:	e8 5c e7 ff ff       	call   800342 <_panic>

00801be6 <open>:
{
  801be6:	f3 0f 1e fb          	endbr32 
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	56                   	push   %esi
  801bee:	53                   	push   %ebx
  801bef:	83 ec 1c             	sub    $0x1c,%esp
  801bf2:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801bf5:	56                   	push   %esi
  801bf6:	e8 55 ed ff ff       	call   800950 <strlen>
  801bfb:	83 c4 10             	add    $0x10,%esp
  801bfe:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c03:	7f 6c                	jg     801c71 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801c05:	83 ec 0c             	sub    $0xc,%esp
  801c08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0b:	50                   	push   %eax
  801c0c:	e8 42 f8 ff ff       	call   801453 <fd_alloc>
  801c11:	89 c3                	mov    %eax,%ebx
  801c13:	83 c4 10             	add    $0x10,%esp
  801c16:	85 c0                	test   %eax,%eax
  801c18:	78 3c                	js     801c56 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801c1a:	83 ec 08             	sub    $0x8,%esp
  801c1d:	56                   	push   %esi
  801c1e:	68 00 50 80 00       	push   $0x805000
  801c23:	e8 6b ed ff ff       	call   800993 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2b:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c30:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c33:	b8 01 00 00 00       	mov    $0x1,%eax
  801c38:	e8 b6 fd ff ff       	call   8019f3 <fsipc>
  801c3d:	89 c3                	mov    %eax,%ebx
  801c3f:	83 c4 10             	add    $0x10,%esp
  801c42:	85 c0                	test   %eax,%eax
  801c44:	78 19                	js     801c5f <open+0x79>
	return fd2num(fd);
  801c46:	83 ec 0c             	sub    $0xc,%esp
  801c49:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4c:	e8 cf f7 ff ff       	call   801420 <fd2num>
  801c51:	89 c3                	mov    %eax,%ebx
  801c53:	83 c4 10             	add    $0x10,%esp
}
  801c56:	89 d8                	mov    %ebx,%eax
  801c58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c5b:	5b                   	pop    %ebx
  801c5c:	5e                   	pop    %esi
  801c5d:	5d                   	pop    %ebp
  801c5e:	c3                   	ret    
		fd_close(fd, 0);
  801c5f:	83 ec 08             	sub    $0x8,%esp
  801c62:	6a 00                	push   $0x0
  801c64:	ff 75 f4             	pushl  -0xc(%ebp)
  801c67:	e8 eb f8 ff ff       	call   801557 <fd_close>
		return r;
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	eb e5                	jmp    801c56 <open+0x70>
		return -E_BAD_PATH;
  801c71:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c76:	eb de                	jmp    801c56 <open+0x70>

00801c78 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c78:	f3 0f 1e fb          	endbr32 
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c82:	ba 00 00 00 00       	mov    $0x0,%edx
  801c87:	b8 08 00 00 00       	mov    $0x8,%eax
  801c8c:	e8 62 fd ff ff       	call   8019f3 <fsipc>
}
  801c91:	c9                   	leave  
  801c92:	c3                   	ret    

00801c93 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c93:	f3 0f 1e fb          	endbr32 
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	56                   	push   %esi
  801c9b:	53                   	push   %ebx
  801c9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c9f:	83 ec 0c             	sub    $0xc,%esp
  801ca2:	ff 75 08             	pushl  0x8(%ebp)
  801ca5:	e8 8a f7 ff ff       	call   801434 <fd2data>
  801caa:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cac:	83 c4 08             	add    $0x8,%esp
  801caf:	68 5f 2d 80 00       	push   $0x802d5f
  801cb4:	53                   	push   %ebx
  801cb5:	e8 d9 ec ff ff       	call   800993 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cba:	8b 46 04             	mov    0x4(%esi),%eax
  801cbd:	2b 06                	sub    (%esi),%eax
  801cbf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cc5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ccc:	00 00 00 
	stat->st_dev = &devpipe;
  801ccf:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801cd6:	30 80 00 
	return 0;
}
  801cd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cde:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce1:	5b                   	pop    %ebx
  801ce2:	5e                   	pop    %esi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ce5:	f3 0f 1e fb          	endbr32 
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	53                   	push   %ebx
  801ced:	83 ec 0c             	sub    $0xc,%esp
  801cf0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cf3:	53                   	push   %ebx
  801cf4:	6a 00                	push   $0x0
  801cf6:	e8 72 f1 ff ff       	call   800e6d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cfb:	89 1c 24             	mov    %ebx,(%esp)
  801cfe:	e8 31 f7 ff ff       	call   801434 <fd2data>
  801d03:	83 c4 08             	add    $0x8,%esp
  801d06:	50                   	push   %eax
  801d07:	6a 00                	push   $0x0
  801d09:	e8 5f f1 ff ff       	call   800e6d <sys_page_unmap>
}
  801d0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <_pipeisclosed>:
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	57                   	push   %edi
  801d17:	56                   	push   %esi
  801d18:	53                   	push   %ebx
  801d19:	83 ec 1c             	sub    $0x1c,%esp
  801d1c:	89 c7                	mov    %eax,%edi
  801d1e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801d20:	a1 04 40 80 00       	mov    0x804004,%eax
  801d25:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d28:	83 ec 0c             	sub    $0xc,%esp
  801d2b:	57                   	push   %edi
  801d2c:	e8 46 06 00 00       	call   802377 <pageref>
  801d31:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d34:	89 34 24             	mov    %esi,(%esp)
  801d37:	e8 3b 06 00 00       	call   802377 <pageref>
		nn = thisenv->env_runs;
  801d3c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d42:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	39 cb                	cmp    %ecx,%ebx
  801d4a:	74 1b                	je     801d67 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801d4c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d4f:	75 cf                	jne    801d20 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d51:	8b 42 58             	mov    0x58(%edx),%eax
  801d54:	6a 01                	push   $0x1
  801d56:	50                   	push   %eax
  801d57:	53                   	push   %ebx
  801d58:	68 66 2d 80 00       	push   $0x802d66
  801d5d:	e8 c7 e6 ff ff       	call   800429 <cprintf>
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	eb b9                	jmp    801d20 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801d67:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d6a:	0f 94 c0             	sete   %al
  801d6d:	0f b6 c0             	movzbl %al,%eax
}
  801d70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d73:	5b                   	pop    %ebx
  801d74:	5e                   	pop    %esi
  801d75:	5f                   	pop    %edi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    

00801d78 <devpipe_write>:
{
  801d78:	f3 0f 1e fb          	endbr32 
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	57                   	push   %edi
  801d80:	56                   	push   %esi
  801d81:	53                   	push   %ebx
  801d82:	83 ec 28             	sub    $0x28,%esp
  801d85:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d88:	56                   	push   %esi
  801d89:	e8 a6 f6 ff ff       	call   801434 <fd2data>
  801d8e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d90:	83 c4 10             	add    $0x10,%esp
  801d93:	bf 00 00 00 00       	mov    $0x0,%edi
  801d98:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d9b:	74 4f                	je     801dec <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d9d:	8b 43 04             	mov    0x4(%ebx),%eax
  801da0:	8b 0b                	mov    (%ebx),%ecx
  801da2:	8d 51 20             	lea    0x20(%ecx),%edx
  801da5:	39 d0                	cmp    %edx,%eax
  801da7:	72 14                	jb     801dbd <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801da9:	89 da                	mov    %ebx,%edx
  801dab:	89 f0                	mov    %esi,%eax
  801dad:	e8 61 ff ff ff       	call   801d13 <_pipeisclosed>
  801db2:	85 c0                	test   %eax,%eax
  801db4:	75 3b                	jne    801df1 <devpipe_write+0x79>
			sys_yield();
  801db6:	e8 35 f0 ff ff       	call   800df0 <sys_yield>
  801dbb:	eb e0                	jmp    801d9d <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dc0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dc4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dc7:	89 c2                	mov    %eax,%edx
  801dc9:	c1 fa 1f             	sar    $0x1f,%edx
  801dcc:	89 d1                	mov    %edx,%ecx
  801dce:	c1 e9 1b             	shr    $0x1b,%ecx
  801dd1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dd4:	83 e2 1f             	and    $0x1f,%edx
  801dd7:	29 ca                	sub    %ecx,%edx
  801dd9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ddd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801de1:	83 c0 01             	add    $0x1,%eax
  801de4:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801de7:	83 c7 01             	add    $0x1,%edi
  801dea:	eb ac                	jmp    801d98 <devpipe_write+0x20>
	return i;
  801dec:	8b 45 10             	mov    0x10(%ebp),%eax
  801def:	eb 05                	jmp    801df6 <devpipe_write+0x7e>
				return 0;
  801df1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801df6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df9:	5b                   	pop    %ebx
  801dfa:	5e                   	pop    %esi
  801dfb:	5f                   	pop    %edi
  801dfc:	5d                   	pop    %ebp
  801dfd:	c3                   	ret    

00801dfe <devpipe_read>:
{
  801dfe:	f3 0f 1e fb          	endbr32 
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	57                   	push   %edi
  801e06:	56                   	push   %esi
  801e07:	53                   	push   %ebx
  801e08:	83 ec 18             	sub    $0x18,%esp
  801e0b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e0e:	57                   	push   %edi
  801e0f:	e8 20 f6 ff ff       	call   801434 <fd2data>
  801e14:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e16:	83 c4 10             	add    $0x10,%esp
  801e19:	be 00 00 00 00       	mov    $0x0,%esi
  801e1e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e21:	75 14                	jne    801e37 <devpipe_read+0x39>
	return i;
  801e23:	8b 45 10             	mov    0x10(%ebp),%eax
  801e26:	eb 02                	jmp    801e2a <devpipe_read+0x2c>
				return i;
  801e28:	89 f0                	mov    %esi,%eax
}
  801e2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e2d:	5b                   	pop    %ebx
  801e2e:	5e                   	pop    %esi
  801e2f:	5f                   	pop    %edi
  801e30:	5d                   	pop    %ebp
  801e31:	c3                   	ret    
			sys_yield();
  801e32:	e8 b9 ef ff ff       	call   800df0 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e37:	8b 03                	mov    (%ebx),%eax
  801e39:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e3c:	75 18                	jne    801e56 <devpipe_read+0x58>
			if (i > 0)
  801e3e:	85 f6                	test   %esi,%esi
  801e40:	75 e6                	jne    801e28 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801e42:	89 da                	mov    %ebx,%edx
  801e44:	89 f8                	mov    %edi,%eax
  801e46:	e8 c8 fe ff ff       	call   801d13 <_pipeisclosed>
  801e4b:	85 c0                	test   %eax,%eax
  801e4d:	74 e3                	je     801e32 <devpipe_read+0x34>
				return 0;
  801e4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e54:	eb d4                	jmp    801e2a <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e56:	99                   	cltd   
  801e57:	c1 ea 1b             	shr    $0x1b,%edx
  801e5a:	01 d0                	add    %edx,%eax
  801e5c:	83 e0 1f             	and    $0x1f,%eax
  801e5f:	29 d0                	sub    %edx,%eax
  801e61:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e69:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e6c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e6f:	83 c6 01             	add    $0x1,%esi
  801e72:	eb aa                	jmp    801e1e <devpipe_read+0x20>

00801e74 <pipe>:
{
  801e74:	f3 0f 1e fb          	endbr32 
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	56                   	push   %esi
  801e7c:	53                   	push   %ebx
  801e7d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e83:	50                   	push   %eax
  801e84:	e8 ca f5 ff ff       	call   801453 <fd_alloc>
  801e89:	89 c3                	mov    %eax,%ebx
  801e8b:	83 c4 10             	add    $0x10,%esp
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	0f 88 23 01 00 00    	js     801fb9 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e96:	83 ec 04             	sub    $0x4,%esp
  801e99:	68 07 04 00 00       	push   $0x407
  801e9e:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea1:	6a 00                	push   $0x0
  801ea3:	e8 73 ef ff ff       	call   800e1b <sys_page_alloc>
  801ea8:	89 c3                	mov    %eax,%ebx
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	0f 88 04 01 00 00    	js     801fb9 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801eb5:	83 ec 0c             	sub    $0xc,%esp
  801eb8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ebb:	50                   	push   %eax
  801ebc:	e8 92 f5 ff ff       	call   801453 <fd_alloc>
  801ec1:	89 c3                	mov    %eax,%ebx
  801ec3:	83 c4 10             	add    $0x10,%esp
  801ec6:	85 c0                	test   %eax,%eax
  801ec8:	0f 88 db 00 00 00    	js     801fa9 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ece:	83 ec 04             	sub    $0x4,%esp
  801ed1:	68 07 04 00 00       	push   $0x407
  801ed6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ed9:	6a 00                	push   $0x0
  801edb:	e8 3b ef ff ff       	call   800e1b <sys_page_alloc>
  801ee0:	89 c3                	mov    %eax,%ebx
  801ee2:	83 c4 10             	add    $0x10,%esp
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	0f 88 bc 00 00 00    	js     801fa9 <pipe+0x135>
	va = fd2data(fd0);
  801eed:	83 ec 0c             	sub    $0xc,%esp
  801ef0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef3:	e8 3c f5 ff ff       	call   801434 <fd2data>
  801ef8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801efa:	83 c4 0c             	add    $0xc,%esp
  801efd:	68 07 04 00 00       	push   $0x407
  801f02:	50                   	push   %eax
  801f03:	6a 00                	push   $0x0
  801f05:	e8 11 ef ff ff       	call   800e1b <sys_page_alloc>
  801f0a:	89 c3                	mov    %eax,%ebx
  801f0c:	83 c4 10             	add    $0x10,%esp
  801f0f:	85 c0                	test   %eax,%eax
  801f11:	0f 88 82 00 00 00    	js     801f99 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f17:	83 ec 0c             	sub    $0xc,%esp
  801f1a:	ff 75 f0             	pushl  -0x10(%ebp)
  801f1d:	e8 12 f5 ff ff       	call   801434 <fd2data>
  801f22:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f29:	50                   	push   %eax
  801f2a:	6a 00                	push   $0x0
  801f2c:	56                   	push   %esi
  801f2d:	6a 00                	push   $0x0
  801f2f:	e8 0f ef ff ff       	call   800e43 <sys_page_map>
  801f34:	89 c3                	mov    %eax,%ebx
  801f36:	83 c4 20             	add    $0x20,%esp
  801f39:	85 c0                	test   %eax,%eax
  801f3b:	78 4e                	js     801f8b <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801f3d:	a1 24 30 80 00       	mov    0x803024,%eax
  801f42:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f45:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801f47:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f4a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801f51:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f54:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f59:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f60:	83 ec 0c             	sub    $0xc,%esp
  801f63:	ff 75 f4             	pushl  -0xc(%ebp)
  801f66:	e8 b5 f4 ff ff       	call   801420 <fd2num>
  801f6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f6e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f70:	83 c4 04             	add    $0x4,%esp
  801f73:	ff 75 f0             	pushl  -0x10(%ebp)
  801f76:	e8 a5 f4 ff ff       	call   801420 <fd2num>
  801f7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f7e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f81:	83 c4 10             	add    $0x10,%esp
  801f84:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f89:	eb 2e                	jmp    801fb9 <pipe+0x145>
	sys_page_unmap(0, va);
  801f8b:	83 ec 08             	sub    $0x8,%esp
  801f8e:	56                   	push   %esi
  801f8f:	6a 00                	push   $0x0
  801f91:	e8 d7 ee ff ff       	call   800e6d <sys_page_unmap>
  801f96:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f99:	83 ec 08             	sub    $0x8,%esp
  801f9c:	ff 75 f0             	pushl  -0x10(%ebp)
  801f9f:	6a 00                	push   $0x0
  801fa1:	e8 c7 ee ff ff       	call   800e6d <sys_page_unmap>
  801fa6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801fa9:	83 ec 08             	sub    $0x8,%esp
  801fac:	ff 75 f4             	pushl  -0xc(%ebp)
  801faf:	6a 00                	push   $0x0
  801fb1:	e8 b7 ee ff ff       	call   800e6d <sys_page_unmap>
  801fb6:	83 c4 10             	add    $0x10,%esp
}
  801fb9:	89 d8                	mov    %ebx,%eax
  801fbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fbe:	5b                   	pop    %ebx
  801fbf:	5e                   	pop    %esi
  801fc0:	5d                   	pop    %ebp
  801fc1:	c3                   	ret    

00801fc2 <pipeisclosed>:
{
  801fc2:	f3 0f 1e fb          	endbr32 
  801fc6:	55                   	push   %ebp
  801fc7:	89 e5                	mov    %esp,%ebp
  801fc9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fcf:	50                   	push   %eax
  801fd0:	ff 75 08             	pushl  0x8(%ebp)
  801fd3:	e8 d1 f4 ff ff       	call   8014a9 <fd_lookup>
  801fd8:	83 c4 10             	add    $0x10,%esp
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	78 18                	js     801ff7 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801fdf:	83 ec 0c             	sub    $0xc,%esp
  801fe2:	ff 75 f4             	pushl  -0xc(%ebp)
  801fe5:	e8 4a f4 ff ff       	call   801434 <fd2data>
  801fea:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fef:	e8 1f fd ff ff       	call   801d13 <_pipeisclosed>
  801ff4:	83 c4 10             	add    $0x10,%esp
}
  801ff7:	c9                   	leave  
  801ff8:	c3                   	ret    

00801ff9 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801ff9:	f3 0f 1e fb          	endbr32 
  801ffd:	55                   	push   %ebp
  801ffe:	89 e5                	mov    %esp,%ebp
  802000:	56                   	push   %esi
  802001:	53                   	push   %ebx
  802002:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802005:	85 f6                	test   %esi,%esi
  802007:	74 13                	je     80201c <wait+0x23>
	e = &envs[ENVX(envid)];
  802009:	89 f3                	mov    %esi,%ebx
  80200b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802011:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802014:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80201a:	eb 1b                	jmp    802037 <wait+0x3e>
	assert(envid != 0);
  80201c:	68 7e 2d 80 00       	push   $0x802d7e
  802021:	68 33 2d 80 00       	push   $0x802d33
  802026:	6a 09                	push   $0x9
  802028:	68 89 2d 80 00       	push   $0x802d89
  80202d:	e8 10 e3 ff ff       	call   800342 <_panic>
		sys_yield();
  802032:	e8 b9 ed ff ff       	call   800df0 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802037:	8b 43 48             	mov    0x48(%ebx),%eax
  80203a:	39 f0                	cmp    %esi,%eax
  80203c:	75 07                	jne    802045 <wait+0x4c>
  80203e:	8b 43 54             	mov    0x54(%ebx),%eax
  802041:	85 c0                	test   %eax,%eax
  802043:	75 ed                	jne    802032 <wait+0x39>
}
  802045:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802048:	5b                   	pop    %ebx
  802049:	5e                   	pop    %esi
  80204a:	5d                   	pop    %ebp
  80204b:	c3                   	ret    

0080204c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80204c:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  802050:	b8 00 00 00 00       	mov    $0x0,%eax
  802055:	c3                   	ret    

00802056 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802056:	f3 0f 1e fb          	endbr32 
  80205a:	55                   	push   %ebp
  80205b:	89 e5                	mov    %esp,%ebp
  80205d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802060:	68 94 2d 80 00       	push   $0x802d94
  802065:	ff 75 0c             	pushl  0xc(%ebp)
  802068:	e8 26 e9 ff ff       	call   800993 <strcpy>
	return 0;
}
  80206d:	b8 00 00 00 00       	mov    $0x0,%eax
  802072:	c9                   	leave  
  802073:	c3                   	ret    

00802074 <devcons_write>:
{
  802074:	f3 0f 1e fb          	endbr32 
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	57                   	push   %edi
  80207c:	56                   	push   %esi
  80207d:	53                   	push   %ebx
  80207e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802084:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802089:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80208f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802092:	73 31                	jae    8020c5 <devcons_write+0x51>
		m = n - tot;
  802094:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802097:	29 f3                	sub    %esi,%ebx
  802099:	83 fb 7f             	cmp    $0x7f,%ebx
  80209c:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8020a1:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8020a4:	83 ec 04             	sub    $0x4,%esp
  8020a7:	53                   	push   %ebx
  8020a8:	89 f0                	mov    %esi,%eax
  8020aa:	03 45 0c             	add    0xc(%ebp),%eax
  8020ad:	50                   	push   %eax
  8020ae:	57                   	push   %edi
  8020af:	e8 97 ea ff ff       	call   800b4b <memmove>
		sys_cputs(buf, m);
  8020b4:	83 c4 08             	add    $0x8,%esp
  8020b7:	53                   	push   %ebx
  8020b8:	57                   	push   %edi
  8020b9:	e8 92 ec ff ff       	call   800d50 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8020be:	01 de                	add    %ebx,%esi
  8020c0:	83 c4 10             	add    $0x10,%esp
  8020c3:	eb ca                	jmp    80208f <devcons_write+0x1b>
}
  8020c5:	89 f0                	mov    %esi,%eax
  8020c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ca:	5b                   	pop    %ebx
  8020cb:	5e                   	pop    %esi
  8020cc:	5f                   	pop    %edi
  8020cd:	5d                   	pop    %ebp
  8020ce:	c3                   	ret    

008020cf <devcons_read>:
{
  8020cf:	f3 0f 1e fb          	endbr32 
  8020d3:	55                   	push   %ebp
  8020d4:	89 e5                	mov    %esp,%ebp
  8020d6:	83 ec 08             	sub    $0x8,%esp
  8020d9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8020de:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020e2:	74 21                	je     802105 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8020e4:	e8 91 ec ff ff       	call   800d7a <sys_cgetc>
  8020e9:	85 c0                	test   %eax,%eax
  8020eb:	75 07                	jne    8020f4 <devcons_read+0x25>
		sys_yield();
  8020ed:	e8 fe ec ff ff       	call   800df0 <sys_yield>
  8020f2:	eb f0                	jmp    8020e4 <devcons_read+0x15>
	if (c < 0)
  8020f4:	78 0f                	js     802105 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8020f6:	83 f8 04             	cmp    $0x4,%eax
  8020f9:	74 0c                	je     802107 <devcons_read+0x38>
	*(char*)vbuf = c;
  8020fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020fe:	88 02                	mov    %al,(%edx)
	return 1;
  802100:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802105:	c9                   	leave  
  802106:	c3                   	ret    
		return 0;
  802107:	b8 00 00 00 00       	mov    $0x0,%eax
  80210c:	eb f7                	jmp    802105 <devcons_read+0x36>

0080210e <cputchar>:
{
  80210e:	f3 0f 1e fb          	endbr32 
  802112:	55                   	push   %ebp
  802113:	89 e5                	mov    %esp,%ebp
  802115:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802118:	8b 45 08             	mov    0x8(%ebp),%eax
  80211b:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80211e:	6a 01                	push   $0x1
  802120:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802123:	50                   	push   %eax
  802124:	e8 27 ec ff ff       	call   800d50 <sys_cputs>
}
  802129:	83 c4 10             	add    $0x10,%esp
  80212c:	c9                   	leave  
  80212d:	c3                   	ret    

0080212e <getchar>:
{
  80212e:	f3 0f 1e fb          	endbr32 
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802138:	6a 01                	push   $0x1
  80213a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80213d:	50                   	push   %eax
  80213e:	6a 00                	push   $0x0
  802140:	e8 e7 f5 ff ff       	call   80172c <read>
	if (r < 0)
  802145:	83 c4 10             	add    $0x10,%esp
  802148:	85 c0                	test   %eax,%eax
  80214a:	78 06                	js     802152 <getchar+0x24>
	if (r < 1)
  80214c:	74 06                	je     802154 <getchar+0x26>
	return c;
  80214e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802152:	c9                   	leave  
  802153:	c3                   	ret    
		return -E_EOF;
  802154:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802159:	eb f7                	jmp    802152 <getchar+0x24>

0080215b <iscons>:
{
  80215b:	f3 0f 1e fb          	endbr32 
  80215f:	55                   	push   %ebp
  802160:	89 e5                	mov    %esp,%ebp
  802162:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802165:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802168:	50                   	push   %eax
  802169:	ff 75 08             	pushl  0x8(%ebp)
  80216c:	e8 38 f3 ff ff       	call   8014a9 <fd_lookup>
  802171:	83 c4 10             	add    $0x10,%esp
  802174:	85 c0                	test   %eax,%eax
  802176:	78 11                	js     802189 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802178:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217b:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802181:	39 10                	cmp    %edx,(%eax)
  802183:	0f 94 c0             	sete   %al
  802186:	0f b6 c0             	movzbl %al,%eax
}
  802189:	c9                   	leave  
  80218a:	c3                   	ret    

0080218b <opencons>:
{
  80218b:	f3 0f 1e fb          	endbr32 
  80218f:	55                   	push   %ebp
  802190:	89 e5                	mov    %esp,%ebp
  802192:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802195:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802198:	50                   	push   %eax
  802199:	e8 b5 f2 ff ff       	call   801453 <fd_alloc>
  80219e:	83 c4 10             	add    $0x10,%esp
  8021a1:	85 c0                	test   %eax,%eax
  8021a3:	78 3a                	js     8021df <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021a5:	83 ec 04             	sub    $0x4,%esp
  8021a8:	68 07 04 00 00       	push   $0x407
  8021ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8021b0:	6a 00                	push   $0x0
  8021b2:	e8 64 ec ff ff       	call   800e1b <sys_page_alloc>
  8021b7:	83 c4 10             	add    $0x10,%esp
  8021ba:	85 c0                	test   %eax,%eax
  8021bc:	78 21                	js     8021df <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8021be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8021c7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021cc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021d3:	83 ec 0c             	sub    $0xc,%esp
  8021d6:	50                   	push   %eax
  8021d7:	e8 44 f2 ff ff       	call   801420 <fd2num>
  8021dc:	83 c4 10             	add    $0x10,%esp
}
  8021df:	c9                   	leave  
  8021e0:	c3                   	ret    

008021e1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021e1:	f3 0f 1e fb          	endbr32 
  8021e5:	55                   	push   %ebp
  8021e6:	89 e5                	mov    %esp,%ebp
  8021e8:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  8021eb:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021f2:	74 0a                	je     8021fe <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f7:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8021fc:	c9                   	leave  
  8021fd:	c3                   	ret    
		if (sys_page_alloc(0,
  8021fe:	83 ec 04             	sub    $0x4,%esp
  802201:	6a 07                	push   $0x7
  802203:	68 00 f0 bf ee       	push   $0xeebff000
  802208:	6a 00                	push   $0x0
  80220a:	e8 0c ec ff ff       	call   800e1b <sys_page_alloc>
  80220f:	83 c4 10             	add    $0x10,%esp
  802212:	85 c0                	test   %eax,%eax
  802214:	78 2a                	js     802240 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  802216:	83 ec 08             	sub    $0x8,%esp
  802219:	68 54 22 80 00       	push   $0x802254
  80221e:	6a 00                	push   $0x0
  802220:	e8 bd ec ff ff       	call   800ee2 <sys_env_set_pgfault_upcall>
  802225:	83 c4 10             	add    $0x10,%esp
  802228:	85 c0                	test   %eax,%eax
  80222a:	79 c8                	jns    8021f4 <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  80222c:	83 ec 04             	sub    $0x4,%esp
  80222f:	68 d4 2d 80 00       	push   $0x802dd4
  802234:	6a 25                	push   $0x25
  802236:	68 1b 2e 80 00       	push   $0x802e1b
  80223b:	e8 02 e1 ff ff       	call   800342 <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  802240:	83 ec 04             	sub    $0x4,%esp
  802243:	68 a0 2d 80 00       	push   $0x802da0
  802248:	6a 21                	push   $0x21
  80224a:	68 1b 2e 80 00       	push   $0x802e1b
  80224f:	e8 ee e0 ff ff       	call   800342 <_panic>

00802254 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802254:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802255:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80225a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80225c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  80225f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  802264:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  802268:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80226c:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  80226e:	83 c4 08             	add    $0x8,%esp
	popal
  802271:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  802272:	83 c4 04             	add    $0x4,%esp
	popfl
  802275:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  802276:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802279:	c3                   	ret    

0080227a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80227a:	f3 0f 1e fb          	endbr32 
  80227e:	55                   	push   %ebp
  80227f:	89 e5                	mov    %esp,%ebp
  802281:	56                   	push   %esi
  802282:	53                   	push   %ebx
  802283:	8b 75 08             	mov    0x8(%ebp),%esi
  802286:	8b 45 0c             	mov    0xc(%ebp),%eax
  802289:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  80228c:	85 c0                	test   %eax,%eax
  80228e:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802293:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  802296:	83 ec 0c             	sub    $0xc,%esp
  802299:	50                   	push   %eax
  80229a:	e8 93 ec ff ff       	call   800f32 <sys_ipc_recv>
	if (f < 0) {
  80229f:	83 c4 10             	add    $0x10,%esp
  8022a2:	85 c0                	test   %eax,%eax
  8022a4:	78 2b                	js     8022d1 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  8022a6:	85 f6                	test   %esi,%esi
  8022a8:	74 0a                	je     8022b4 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  8022aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8022af:	8b 40 74             	mov    0x74(%eax),%eax
  8022b2:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  8022b4:	85 db                	test   %ebx,%ebx
  8022b6:	74 0a                	je     8022c2 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  8022b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8022bd:	8b 40 78             	mov    0x78(%eax),%eax
  8022c0:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  8022c2:	a1 04 40 80 00       	mov    0x804004,%eax
  8022c7:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5d                   	pop    %ebp
  8022d0:	c3                   	ret    
		if (from_env_store != NULL) {
  8022d1:	85 f6                	test   %esi,%esi
  8022d3:	74 06                	je     8022db <ipc_recv+0x61>
			*from_env_store = 0;
  8022d5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  8022db:	85 db                	test   %ebx,%ebx
  8022dd:	74 eb                	je     8022ca <ipc_recv+0x50>
			*perm_store = 0;
  8022df:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8022e5:	eb e3                	jmp    8022ca <ipc_recv+0x50>

008022e7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022e7:	f3 0f 1e fb          	endbr32 
  8022eb:	55                   	push   %ebp
  8022ec:	89 e5                	mov    %esp,%ebp
  8022ee:	57                   	push   %edi
  8022ef:	56                   	push   %esi
  8022f0:	53                   	push   %ebx
  8022f1:	83 ec 0c             	sub    $0xc,%esp
  8022f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022f7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  8022fd:	85 db                	test   %ebx,%ebx
  8022ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802304:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802307:	ff 75 14             	pushl  0x14(%ebp)
  80230a:	53                   	push   %ebx
  80230b:	56                   	push   %esi
  80230c:	57                   	push   %edi
  80230d:	e8 f7 eb ff ff       	call   800f09 <sys_ipc_try_send>
  802312:	83 c4 10             	add    $0x10,%esp
  802315:	85 c0                	test   %eax,%eax
  802317:	79 19                	jns    802332 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  802319:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80231c:	74 e9                	je     802307 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  80231e:	83 ec 04             	sub    $0x4,%esp
  802321:	68 2c 2e 80 00       	push   $0x802e2c
  802326:	6a 48                	push   $0x48
  802328:	68 4e 2e 80 00       	push   $0x802e4e
  80232d:	e8 10 e0 ff ff       	call   800342 <_panic>
		}
	}
}
  802332:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802335:	5b                   	pop    %ebx
  802336:	5e                   	pop    %esi
  802337:	5f                   	pop    %edi
  802338:	5d                   	pop    %ebp
  802339:	c3                   	ret    

0080233a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80233a:	f3 0f 1e fb          	endbr32 
  80233e:	55                   	push   %ebp
  80233f:	89 e5                	mov    %esp,%ebp
  802341:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802344:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802349:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80234c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802352:	8b 52 50             	mov    0x50(%edx),%edx
  802355:	39 ca                	cmp    %ecx,%edx
  802357:	74 11                	je     80236a <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802359:	83 c0 01             	add    $0x1,%eax
  80235c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802361:	75 e6                	jne    802349 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802363:	b8 00 00 00 00       	mov    $0x0,%eax
  802368:	eb 0b                	jmp    802375 <ipc_find_env+0x3b>
			return envs[i].env_id;
  80236a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80236d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802372:	8b 40 48             	mov    0x48(%eax),%eax
}
  802375:	5d                   	pop    %ebp
  802376:	c3                   	ret    

00802377 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802377:	f3 0f 1e fb          	endbr32 
  80237b:	55                   	push   %ebp
  80237c:	89 e5                	mov    %esp,%ebp
  80237e:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802381:	89 c2                	mov    %eax,%edx
  802383:	c1 ea 16             	shr    $0x16,%edx
  802386:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80238d:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802392:	f6 c1 01             	test   $0x1,%cl
  802395:	74 1c                	je     8023b3 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802397:	c1 e8 0c             	shr    $0xc,%eax
  80239a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023a1:	a8 01                	test   $0x1,%al
  8023a3:	74 0e                	je     8023b3 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023a5:	c1 e8 0c             	shr    $0xc,%eax
  8023a8:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8023af:	ef 
  8023b0:	0f b7 d2             	movzwl %dx,%edx
}
  8023b3:	89 d0                	mov    %edx,%eax
  8023b5:	5d                   	pop    %ebp
  8023b6:	c3                   	ret    
  8023b7:	66 90                	xchg   %ax,%ax
  8023b9:	66 90                	xchg   %ax,%ax
  8023bb:	66 90                	xchg   %ax,%ax
  8023bd:	66 90                	xchg   %ax,%ax
  8023bf:	90                   	nop

008023c0 <__udivdi3>:
  8023c0:	f3 0f 1e fb          	endbr32 
  8023c4:	55                   	push   %ebp
  8023c5:	57                   	push   %edi
  8023c6:	56                   	push   %esi
  8023c7:	53                   	push   %ebx
  8023c8:	83 ec 1c             	sub    $0x1c,%esp
  8023cb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8023d3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8023db:	85 d2                	test   %edx,%edx
  8023dd:	75 19                	jne    8023f8 <__udivdi3+0x38>
  8023df:	39 f3                	cmp    %esi,%ebx
  8023e1:	76 4d                	jbe    802430 <__udivdi3+0x70>
  8023e3:	31 ff                	xor    %edi,%edi
  8023e5:	89 e8                	mov    %ebp,%eax
  8023e7:	89 f2                	mov    %esi,%edx
  8023e9:	f7 f3                	div    %ebx
  8023eb:	89 fa                	mov    %edi,%edx
  8023ed:	83 c4 1c             	add    $0x1c,%esp
  8023f0:	5b                   	pop    %ebx
  8023f1:	5e                   	pop    %esi
  8023f2:	5f                   	pop    %edi
  8023f3:	5d                   	pop    %ebp
  8023f4:	c3                   	ret    
  8023f5:	8d 76 00             	lea    0x0(%esi),%esi
  8023f8:	39 f2                	cmp    %esi,%edx
  8023fa:	76 14                	jbe    802410 <__udivdi3+0x50>
  8023fc:	31 ff                	xor    %edi,%edi
  8023fe:	31 c0                	xor    %eax,%eax
  802400:	89 fa                	mov    %edi,%edx
  802402:	83 c4 1c             	add    $0x1c,%esp
  802405:	5b                   	pop    %ebx
  802406:	5e                   	pop    %esi
  802407:	5f                   	pop    %edi
  802408:	5d                   	pop    %ebp
  802409:	c3                   	ret    
  80240a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802410:	0f bd fa             	bsr    %edx,%edi
  802413:	83 f7 1f             	xor    $0x1f,%edi
  802416:	75 48                	jne    802460 <__udivdi3+0xa0>
  802418:	39 f2                	cmp    %esi,%edx
  80241a:	72 06                	jb     802422 <__udivdi3+0x62>
  80241c:	31 c0                	xor    %eax,%eax
  80241e:	39 eb                	cmp    %ebp,%ebx
  802420:	77 de                	ja     802400 <__udivdi3+0x40>
  802422:	b8 01 00 00 00       	mov    $0x1,%eax
  802427:	eb d7                	jmp    802400 <__udivdi3+0x40>
  802429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802430:	89 d9                	mov    %ebx,%ecx
  802432:	85 db                	test   %ebx,%ebx
  802434:	75 0b                	jne    802441 <__udivdi3+0x81>
  802436:	b8 01 00 00 00       	mov    $0x1,%eax
  80243b:	31 d2                	xor    %edx,%edx
  80243d:	f7 f3                	div    %ebx
  80243f:	89 c1                	mov    %eax,%ecx
  802441:	31 d2                	xor    %edx,%edx
  802443:	89 f0                	mov    %esi,%eax
  802445:	f7 f1                	div    %ecx
  802447:	89 c6                	mov    %eax,%esi
  802449:	89 e8                	mov    %ebp,%eax
  80244b:	89 f7                	mov    %esi,%edi
  80244d:	f7 f1                	div    %ecx
  80244f:	89 fa                	mov    %edi,%edx
  802451:	83 c4 1c             	add    $0x1c,%esp
  802454:	5b                   	pop    %ebx
  802455:	5e                   	pop    %esi
  802456:	5f                   	pop    %edi
  802457:	5d                   	pop    %ebp
  802458:	c3                   	ret    
  802459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802460:	89 f9                	mov    %edi,%ecx
  802462:	b8 20 00 00 00       	mov    $0x20,%eax
  802467:	29 f8                	sub    %edi,%eax
  802469:	d3 e2                	shl    %cl,%edx
  80246b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80246f:	89 c1                	mov    %eax,%ecx
  802471:	89 da                	mov    %ebx,%edx
  802473:	d3 ea                	shr    %cl,%edx
  802475:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802479:	09 d1                	or     %edx,%ecx
  80247b:	89 f2                	mov    %esi,%edx
  80247d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802481:	89 f9                	mov    %edi,%ecx
  802483:	d3 e3                	shl    %cl,%ebx
  802485:	89 c1                	mov    %eax,%ecx
  802487:	d3 ea                	shr    %cl,%edx
  802489:	89 f9                	mov    %edi,%ecx
  80248b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80248f:	89 eb                	mov    %ebp,%ebx
  802491:	d3 e6                	shl    %cl,%esi
  802493:	89 c1                	mov    %eax,%ecx
  802495:	d3 eb                	shr    %cl,%ebx
  802497:	09 de                	or     %ebx,%esi
  802499:	89 f0                	mov    %esi,%eax
  80249b:	f7 74 24 08          	divl   0x8(%esp)
  80249f:	89 d6                	mov    %edx,%esi
  8024a1:	89 c3                	mov    %eax,%ebx
  8024a3:	f7 64 24 0c          	mull   0xc(%esp)
  8024a7:	39 d6                	cmp    %edx,%esi
  8024a9:	72 15                	jb     8024c0 <__udivdi3+0x100>
  8024ab:	89 f9                	mov    %edi,%ecx
  8024ad:	d3 e5                	shl    %cl,%ebp
  8024af:	39 c5                	cmp    %eax,%ebp
  8024b1:	73 04                	jae    8024b7 <__udivdi3+0xf7>
  8024b3:	39 d6                	cmp    %edx,%esi
  8024b5:	74 09                	je     8024c0 <__udivdi3+0x100>
  8024b7:	89 d8                	mov    %ebx,%eax
  8024b9:	31 ff                	xor    %edi,%edi
  8024bb:	e9 40 ff ff ff       	jmp    802400 <__udivdi3+0x40>
  8024c0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8024c3:	31 ff                	xor    %edi,%edi
  8024c5:	e9 36 ff ff ff       	jmp    802400 <__udivdi3+0x40>
  8024ca:	66 90                	xchg   %ax,%ax
  8024cc:	66 90                	xchg   %ax,%ax
  8024ce:	66 90                	xchg   %ax,%ax

008024d0 <__umoddi3>:
  8024d0:	f3 0f 1e fb          	endbr32 
  8024d4:	55                   	push   %ebp
  8024d5:	57                   	push   %edi
  8024d6:	56                   	push   %esi
  8024d7:	53                   	push   %ebx
  8024d8:	83 ec 1c             	sub    $0x1c,%esp
  8024db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8024df:	8b 74 24 30          	mov    0x30(%esp),%esi
  8024e3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8024e7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024eb:	85 c0                	test   %eax,%eax
  8024ed:	75 19                	jne    802508 <__umoddi3+0x38>
  8024ef:	39 df                	cmp    %ebx,%edi
  8024f1:	76 5d                	jbe    802550 <__umoddi3+0x80>
  8024f3:	89 f0                	mov    %esi,%eax
  8024f5:	89 da                	mov    %ebx,%edx
  8024f7:	f7 f7                	div    %edi
  8024f9:	89 d0                	mov    %edx,%eax
  8024fb:	31 d2                	xor    %edx,%edx
  8024fd:	83 c4 1c             	add    $0x1c,%esp
  802500:	5b                   	pop    %ebx
  802501:	5e                   	pop    %esi
  802502:	5f                   	pop    %edi
  802503:	5d                   	pop    %ebp
  802504:	c3                   	ret    
  802505:	8d 76 00             	lea    0x0(%esi),%esi
  802508:	89 f2                	mov    %esi,%edx
  80250a:	39 d8                	cmp    %ebx,%eax
  80250c:	76 12                	jbe    802520 <__umoddi3+0x50>
  80250e:	89 f0                	mov    %esi,%eax
  802510:	89 da                	mov    %ebx,%edx
  802512:	83 c4 1c             	add    $0x1c,%esp
  802515:	5b                   	pop    %ebx
  802516:	5e                   	pop    %esi
  802517:	5f                   	pop    %edi
  802518:	5d                   	pop    %ebp
  802519:	c3                   	ret    
  80251a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802520:	0f bd e8             	bsr    %eax,%ebp
  802523:	83 f5 1f             	xor    $0x1f,%ebp
  802526:	75 50                	jne    802578 <__umoddi3+0xa8>
  802528:	39 d8                	cmp    %ebx,%eax
  80252a:	0f 82 e0 00 00 00    	jb     802610 <__umoddi3+0x140>
  802530:	89 d9                	mov    %ebx,%ecx
  802532:	39 f7                	cmp    %esi,%edi
  802534:	0f 86 d6 00 00 00    	jbe    802610 <__umoddi3+0x140>
  80253a:	89 d0                	mov    %edx,%eax
  80253c:	89 ca                	mov    %ecx,%edx
  80253e:	83 c4 1c             	add    $0x1c,%esp
  802541:	5b                   	pop    %ebx
  802542:	5e                   	pop    %esi
  802543:	5f                   	pop    %edi
  802544:	5d                   	pop    %ebp
  802545:	c3                   	ret    
  802546:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80254d:	8d 76 00             	lea    0x0(%esi),%esi
  802550:	89 fd                	mov    %edi,%ebp
  802552:	85 ff                	test   %edi,%edi
  802554:	75 0b                	jne    802561 <__umoddi3+0x91>
  802556:	b8 01 00 00 00       	mov    $0x1,%eax
  80255b:	31 d2                	xor    %edx,%edx
  80255d:	f7 f7                	div    %edi
  80255f:	89 c5                	mov    %eax,%ebp
  802561:	89 d8                	mov    %ebx,%eax
  802563:	31 d2                	xor    %edx,%edx
  802565:	f7 f5                	div    %ebp
  802567:	89 f0                	mov    %esi,%eax
  802569:	f7 f5                	div    %ebp
  80256b:	89 d0                	mov    %edx,%eax
  80256d:	31 d2                	xor    %edx,%edx
  80256f:	eb 8c                	jmp    8024fd <__umoddi3+0x2d>
  802571:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802578:	89 e9                	mov    %ebp,%ecx
  80257a:	ba 20 00 00 00       	mov    $0x20,%edx
  80257f:	29 ea                	sub    %ebp,%edx
  802581:	d3 e0                	shl    %cl,%eax
  802583:	89 44 24 08          	mov    %eax,0x8(%esp)
  802587:	89 d1                	mov    %edx,%ecx
  802589:	89 f8                	mov    %edi,%eax
  80258b:	d3 e8                	shr    %cl,%eax
  80258d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802591:	89 54 24 04          	mov    %edx,0x4(%esp)
  802595:	8b 54 24 04          	mov    0x4(%esp),%edx
  802599:	09 c1                	or     %eax,%ecx
  80259b:	89 d8                	mov    %ebx,%eax
  80259d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025a1:	89 e9                	mov    %ebp,%ecx
  8025a3:	d3 e7                	shl    %cl,%edi
  8025a5:	89 d1                	mov    %edx,%ecx
  8025a7:	d3 e8                	shr    %cl,%eax
  8025a9:	89 e9                	mov    %ebp,%ecx
  8025ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8025af:	d3 e3                	shl    %cl,%ebx
  8025b1:	89 c7                	mov    %eax,%edi
  8025b3:	89 d1                	mov    %edx,%ecx
  8025b5:	89 f0                	mov    %esi,%eax
  8025b7:	d3 e8                	shr    %cl,%eax
  8025b9:	89 e9                	mov    %ebp,%ecx
  8025bb:	89 fa                	mov    %edi,%edx
  8025bd:	d3 e6                	shl    %cl,%esi
  8025bf:	09 d8                	or     %ebx,%eax
  8025c1:	f7 74 24 08          	divl   0x8(%esp)
  8025c5:	89 d1                	mov    %edx,%ecx
  8025c7:	89 f3                	mov    %esi,%ebx
  8025c9:	f7 64 24 0c          	mull   0xc(%esp)
  8025cd:	89 c6                	mov    %eax,%esi
  8025cf:	89 d7                	mov    %edx,%edi
  8025d1:	39 d1                	cmp    %edx,%ecx
  8025d3:	72 06                	jb     8025db <__umoddi3+0x10b>
  8025d5:	75 10                	jne    8025e7 <__umoddi3+0x117>
  8025d7:	39 c3                	cmp    %eax,%ebx
  8025d9:	73 0c                	jae    8025e7 <__umoddi3+0x117>
  8025db:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8025df:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8025e3:	89 d7                	mov    %edx,%edi
  8025e5:	89 c6                	mov    %eax,%esi
  8025e7:	89 ca                	mov    %ecx,%edx
  8025e9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8025ee:	29 f3                	sub    %esi,%ebx
  8025f0:	19 fa                	sbb    %edi,%edx
  8025f2:	89 d0                	mov    %edx,%eax
  8025f4:	d3 e0                	shl    %cl,%eax
  8025f6:	89 e9                	mov    %ebp,%ecx
  8025f8:	d3 eb                	shr    %cl,%ebx
  8025fa:	d3 ea                	shr    %cl,%edx
  8025fc:	09 d8                	or     %ebx,%eax
  8025fe:	83 c4 1c             	add    $0x1c,%esp
  802601:	5b                   	pop    %ebx
  802602:	5e                   	pop    %esi
  802603:	5f                   	pop    %edi
  802604:	5d                   	pop    %ebp
  802605:	c3                   	ret    
  802606:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80260d:	8d 76 00             	lea    0x0(%esi),%esi
  802610:	29 fe                	sub    %edi,%esi
  802612:	19 c3                	sbb    %eax,%ebx
  802614:	89 f2                	mov    %esi,%edx
  802616:	89 d9                	mov    %ebx,%ecx
  802618:	e9 1d ff ff ff       	jmp    80253a <__umoddi3+0x6a>
