
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 83 01 00 00       	call   8001b4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003d:	e8 1e 11 00 00       	call   801160 <fork>
  800042:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	0f 84 ab 00 00 00    	je     8000f8 <umain+0xc5>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
		return;
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80004d:	a1 04 40 80 00       	mov    0x804004,%eax
  800052:	8b 40 48             	mov    0x48(%eax),%eax
  800055:	83 ec 04             	sub    $0x4,%esp
  800058:	6a 07                	push   $0x7
  80005a:	68 00 00 a0 00       	push   $0xa00000
  80005f:	50                   	push   %eax
  800060:	e8 4a 0c 00 00       	call   800caf <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800065:	83 c4 04             	add    $0x4,%esp
  800068:	ff 35 04 30 80 00    	pushl  0x803004
  80006e:	e8 71 07 00 00       	call   8007e4 <strlen>
  800073:	83 c4 0c             	add    $0xc,%esp
  800076:	83 c0 01             	add    $0x1,%eax
  800079:	50                   	push   %eax
  80007a:	ff 35 04 30 80 00    	pushl  0x803004
  800080:	68 00 00 a0 00       	push   $0xa00000
  800085:	e8 bb 09 00 00       	call   800a45 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80008a:	6a 07                	push   $0x7
  80008c:	68 00 00 a0 00       	push   $0xa00000
  800091:	6a 00                	push   $0x0
  800093:	ff 75 f4             	pushl  -0xc(%ebp)
  800096:	e8 86 12 00 00       	call   801321 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80009b:	83 c4 1c             	add    $0x1c,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	68 00 00 a0 00       	push   $0xa00000
  8000a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a8:	50                   	push   %eax
  8000a9:	e8 06 12 00 00       	call   8012b4 <ipc_recv>
	cprintf("%x got message from %x: %s\n",
		thisenv->env_id, who, TEMP_ADDR);
  8000ae:	a1 04 40 80 00       	mov    0x804004,%eax
	cprintf("%x got message from %x: %s\n",
  8000b3:	8b 40 48             	mov    0x48(%eax),%eax
  8000b6:	68 00 00 a0 00       	push   $0xa00000
  8000bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8000be:	50                   	push   %eax
  8000bf:	68 c0 24 80 00       	push   $0x8024c0
  8000c4:	e8 f4 01 00 00       	call   8002bd <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8000c9:	83 c4 14             	add    $0x14,%esp
  8000cc:	ff 35 00 30 80 00    	pushl  0x803000
  8000d2:	e8 0d 07 00 00       	call   8007e4 <strlen>
  8000d7:	83 c4 0c             	add    $0xc,%esp
  8000da:	50                   	push   %eax
  8000db:	ff 35 00 30 80 00    	pushl  0x803000
  8000e1:	68 00 00 a0 00       	push   $0xa00000
  8000e6:	e8 25 08 00 00       	call   800910 <strncmp>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	0f 84 a9 00 00 00    	je     80019f <umain+0x16c>
		cprintf("parent received correct message\n");
	return;
}
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  8000f8:	83 ec 04             	sub    $0x4,%esp
  8000fb:	6a 00                	push   $0x0
  8000fd:	68 00 00 b0 00       	push   $0xb00000
  800102:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 a9 11 00 00       	call   8012b4 <ipc_recv>
			thisenv->env_id, who, TEMP_ADDR_CHILD);
  80010b:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("%x got message from %x: %s\n",
  800110:	8b 40 48             	mov    0x48(%eax),%eax
  800113:	68 00 00 b0 00       	push   $0xb00000
  800118:	ff 75 f4             	pushl  -0xc(%ebp)
  80011b:	50                   	push   %eax
  80011c:	68 c0 24 80 00       	push   $0x8024c0
  800121:	e8 97 01 00 00       	call   8002bd <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800126:	83 c4 14             	add    $0x14,%esp
  800129:	ff 35 04 30 80 00    	pushl  0x803004
  80012f:	e8 b0 06 00 00       	call   8007e4 <strlen>
  800134:	83 c4 0c             	add    $0xc,%esp
  800137:	50                   	push   %eax
  800138:	ff 35 04 30 80 00    	pushl  0x803004
  80013e:	68 00 00 b0 00       	push   $0xb00000
  800143:	e8 c8 07 00 00       	call   800910 <strncmp>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	85 c0                	test   %eax,%eax
  80014d:	74 3e                	je     80018d <umain+0x15a>
		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 35 00 30 80 00    	pushl  0x803000
  800158:	e8 87 06 00 00       	call   8007e4 <strlen>
  80015d:	83 c4 0c             	add    $0xc,%esp
  800160:	83 c0 01             	add    $0x1,%eax
  800163:	50                   	push   %eax
  800164:	ff 35 00 30 80 00    	pushl  0x803000
  80016a:	68 00 00 b0 00       	push   $0xb00000
  80016f:	e8 d1 08 00 00       	call   800a45 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  800174:	6a 07                	push   $0x7
  800176:	68 00 00 b0 00       	push   $0xb00000
  80017b:	6a 00                	push   $0x0
  80017d:	ff 75 f4             	pushl  -0xc(%ebp)
  800180:	e8 9c 11 00 00       	call   801321 <ipc_send>
		return;
  800185:	83 c4 20             	add    $0x20,%esp
  800188:	e9 69 ff ff ff       	jmp    8000f6 <umain+0xc3>
			cprintf("child received correct message\n");
  80018d:	83 ec 0c             	sub    $0xc,%esp
  800190:	68 dc 24 80 00       	push   $0x8024dc
  800195:	e8 23 01 00 00       	call   8002bd <cprintf>
  80019a:	83 c4 10             	add    $0x10,%esp
  80019d:	eb b0                	jmp    80014f <umain+0x11c>
		cprintf("parent received correct message\n");
  80019f:	83 ec 0c             	sub    $0xc,%esp
  8001a2:	68 fc 24 80 00       	push   $0x8024fc
  8001a7:	e8 11 01 00 00       	call   8002bd <cprintf>
  8001ac:	83 c4 10             	add    $0x10,%esp
  8001af:	e9 42 ff ff ff       	jmp    8000f6 <umain+0xc3>

008001b4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b4:	f3 0f 1e fb          	endbr32 
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8001c3:	e8 94 0a 00 00       	call   800c5c <sys_getenvid>
	if (id >= 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	78 12                	js     8001de <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8001cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d9:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001de:	85 db                	test   %ebx,%ebx
  8001e0:	7e 07                	jle    8001e9 <libmain+0x35>
		binaryname = argv[0];
  8001e2:	8b 06                	mov    (%esi),%eax
  8001e4:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001e9:	83 ec 08             	sub    $0x8,%esp
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	e8 40 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001f3:	e8 0a 00 00 00       	call   800202 <exit>
}
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fe:	5b                   	pop    %ebx
  8001ff:	5e                   	pop    %esi
  800200:	5d                   	pop    %ebp
  800201:	c3                   	ret    

00800202 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800202:	f3 0f 1e fb          	endbr32 
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80020c:	e8 93 13 00 00       	call   8015a4 <close_all>
	sys_env_destroy(0);
  800211:	83 ec 0c             	sub    $0xc,%esp
  800214:	6a 00                	push   $0x0
  800216:	e8 1b 0a 00 00       	call   800c36 <sys_env_destroy>
}
  80021b:	83 c4 10             	add    $0x10,%esp
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800220:	f3 0f 1e fb          	endbr32 
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	53                   	push   %ebx
  800228:	83 ec 04             	sub    $0x4,%esp
  80022b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80022e:	8b 13                	mov    (%ebx),%edx
  800230:	8d 42 01             	lea    0x1(%edx),%eax
  800233:	89 03                	mov    %eax,(%ebx)
  800235:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800238:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80023c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800241:	74 09                	je     80024c <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800243:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800247:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80024c:	83 ec 08             	sub    $0x8,%esp
  80024f:	68 ff 00 00 00       	push   $0xff
  800254:	8d 43 08             	lea    0x8(%ebx),%eax
  800257:	50                   	push   %eax
  800258:	e8 87 09 00 00       	call   800be4 <sys_cputs>
		b->idx = 0;
  80025d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800263:	83 c4 10             	add    $0x10,%esp
  800266:	eb db                	jmp    800243 <putch+0x23>

00800268 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800268:	f3 0f 1e fb          	endbr32 
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800275:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027c:	00 00 00 
	b.cnt = 0;
  80027f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800286:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800289:	ff 75 0c             	pushl  0xc(%ebp)
  80028c:	ff 75 08             	pushl  0x8(%ebp)
  80028f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800295:	50                   	push   %eax
  800296:	68 20 02 80 00       	push   $0x800220
  80029b:	e8 80 01 00 00       	call   800420 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a0:	83 c4 08             	add    $0x8,%esp
  8002a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002af:	50                   	push   %eax
  8002b0:	e8 2f 09 00 00       	call   800be4 <sys_cputs>

	return b.cnt;
}
  8002b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bb:	c9                   	leave  
  8002bc:	c3                   	ret    

008002bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002bd:	f3 0f 1e fb          	endbr32 
  8002c1:	55                   	push   %ebp
  8002c2:	89 e5                	mov    %esp,%ebp
  8002c4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ca:	50                   	push   %eax
  8002cb:	ff 75 08             	pushl  0x8(%ebp)
  8002ce:	e8 95 ff ff ff       	call   800268 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	57                   	push   %edi
  8002d9:	56                   	push   %esi
  8002da:	53                   	push   %ebx
  8002db:	83 ec 1c             	sub    $0x1c,%esp
  8002de:	89 c7                	mov    %eax,%edi
  8002e0:	89 d6                	mov    %edx,%esi
  8002e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e8:	89 d1                	mov    %edx,%ecx
  8002ea:	89 c2                	mov    %eax,%edx
  8002ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800302:	39 c2                	cmp    %eax,%edx
  800304:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800307:	72 3e                	jb     800347 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800309:	83 ec 0c             	sub    $0xc,%esp
  80030c:	ff 75 18             	pushl  0x18(%ebp)
  80030f:	83 eb 01             	sub    $0x1,%ebx
  800312:	53                   	push   %ebx
  800313:	50                   	push   %eax
  800314:	83 ec 08             	sub    $0x8,%esp
  800317:	ff 75 e4             	pushl  -0x1c(%ebp)
  80031a:	ff 75 e0             	pushl  -0x20(%ebp)
  80031d:	ff 75 dc             	pushl  -0x24(%ebp)
  800320:	ff 75 d8             	pushl  -0x28(%ebp)
  800323:	e8 28 1f 00 00       	call   802250 <__udivdi3>
  800328:	83 c4 18             	add    $0x18,%esp
  80032b:	52                   	push   %edx
  80032c:	50                   	push   %eax
  80032d:	89 f2                	mov    %esi,%edx
  80032f:	89 f8                	mov    %edi,%eax
  800331:	e8 9f ff ff ff       	call   8002d5 <printnum>
  800336:	83 c4 20             	add    $0x20,%esp
  800339:	eb 13                	jmp    80034e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80033b:	83 ec 08             	sub    $0x8,%esp
  80033e:	56                   	push   %esi
  80033f:	ff 75 18             	pushl  0x18(%ebp)
  800342:	ff d7                	call   *%edi
  800344:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800347:	83 eb 01             	sub    $0x1,%ebx
  80034a:	85 db                	test   %ebx,%ebx
  80034c:	7f ed                	jg     80033b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034e:	83 ec 08             	sub    $0x8,%esp
  800351:	56                   	push   %esi
  800352:	83 ec 04             	sub    $0x4,%esp
  800355:	ff 75 e4             	pushl  -0x1c(%ebp)
  800358:	ff 75 e0             	pushl  -0x20(%ebp)
  80035b:	ff 75 dc             	pushl  -0x24(%ebp)
  80035e:	ff 75 d8             	pushl  -0x28(%ebp)
  800361:	e8 fa 1f 00 00       	call   802360 <__umoddi3>
  800366:	83 c4 14             	add    $0x14,%esp
  800369:	0f be 80 74 25 80 00 	movsbl 0x802574(%eax),%eax
  800370:	50                   	push   %eax
  800371:	ff d7                	call   *%edi
}
  800373:	83 c4 10             	add    $0x10,%esp
  800376:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800379:	5b                   	pop    %ebx
  80037a:	5e                   	pop    %esi
  80037b:	5f                   	pop    %edi
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80037e:	83 fa 01             	cmp    $0x1,%edx
  800381:	7f 13                	jg     800396 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800383:	85 d2                	test   %edx,%edx
  800385:	74 1c                	je     8003a3 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800387:	8b 10                	mov    (%eax),%edx
  800389:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038c:	89 08                	mov    %ecx,(%eax)
  80038e:	8b 02                	mov    (%edx),%eax
  800390:	ba 00 00 00 00       	mov    $0x0,%edx
  800395:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800396:	8b 10                	mov    (%eax),%edx
  800398:	8d 4a 08             	lea    0x8(%edx),%ecx
  80039b:	89 08                	mov    %ecx,(%eax)
  80039d:	8b 02                	mov    (%edx),%eax
  80039f:	8b 52 04             	mov    0x4(%edx),%edx
  8003a2:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8003a3:	8b 10                	mov    (%eax),%edx
  8003a5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a8:	89 08                	mov    %ecx,(%eax)
  8003aa:	8b 02                	mov    (%edx),%eax
  8003ac:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b1:	c3                   	ret    

008003b2 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8003b2:	83 fa 01             	cmp    $0x1,%edx
  8003b5:	7f 0f                	jg     8003c6 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8003b7:	85 d2                	test   %edx,%edx
  8003b9:	74 18                	je     8003d3 <getint+0x21>
		return va_arg(*ap, long);
  8003bb:	8b 10                	mov    (%eax),%edx
  8003bd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c0:	89 08                	mov    %ecx,(%eax)
  8003c2:	8b 02                	mov    (%edx),%eax
  8003c4:	99                   	cltd   
  8003c5:	c3                   	ret    
		return va_arg(*ap, long long);
  8003c6:	8b 10                	mov    (%eax),%edx
  8003c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003cb:	89 08                	mov    %ecx,(%eax)
  8003cd:	8b 02                	mov    (%edx),%eax
  8003cf:	8b 52 04             	mov    0x4(%edx),%edx
  8003d2:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8003d3:	8b 10                	mov    (%eax),%edx
  8003d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d8:	89 08                	mov    %ecx,(%eax)
  8003da:	8b 02                	mov    (%edx),%eax
  8003dc:	99                   	cltd   
}
  8003dd:	c3                   	ret    

008003de <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003de:	f3 0f 1e fb          	endbr32 
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f1:	73 0a                	jae    8003fd <sprintputch+0x1f>
		*b->buf++ = ch;
  8003f3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003f6:	89 08                	mov    %ecx,(%eax)
  8003f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fb:	88 02                	mov    %al,(%edx)
}
  8003fd:	5d                   	pop    %ebp
  8003fe:	c3                   	ret    

008003ff <printfmt>:
{
  8003ff:	f3 0f 1e fb          	endbr32 
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800409:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80040c:	50                   	push   %eax
  80040d:	ff 75 10             	pushl  0x10(%ebp)
  800410:	ff 75 0c             	pushl  0xc(%ebp)
  800413:	ff 75 08             	pushl  0x8(%ebp)
  800416:	e8 05 00 00 00       	call   800420 <vprintfmt>
}
  80041b:	83 c4 10             	add    $0x10,%esp
  80041e:	c9                   	leave  
  80041f:	c3                   	ret    

00800420 <vprintfmt>:
{
  800420:	f3 0f 1e fb          	endbr32 
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	57                   	push   %edi
  800428:	56                   	push   %esi
  800429:	53                   	push   %ebx
  80042a:	83 ec 2c             	sub    $0x2c,%esp
  80042d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800430:	8b 75 0c             	mov    0xc(%ebp),%esi
  800433:	8b 7d 10             	mov    0x10(%ebp),%edi
  800436:	e9 86 02 00 00       	jmp    8006c1 <vprintfmt+0x2a1>
		padc = ' ';
  80043b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80043f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800446:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80044d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800454:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8d 47 01             	lea    0x1(%edi),%eax
  80045c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80045f:	0f b6 17             	movzbl (%edi),%edx
  800462:	8d 42 dd             	lea    -0x23(%edx),%eax
  800465:	3c 55                	cmp    $0x55,%al
  800467:	0f 87 df 02 00 00    	ja     80074c <vprintfmt+0x32c>
  80046d:	0f b6 c0             	movzbl %al,%eax
  800470:	3e ff 24 85 c0 26 80 	notrack jmp *0x8026c0(,%eax,4)
  800477:	00 
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80047b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80047f:	eb d8                	jmp    800459 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800484:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800488:	eb cf                	jmp    800459 <vprintfmt+0x39>
  80048a:	0f b6 d2             	movzbl %dl,%edx
  80048d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800490:	b8 00 00 00 00       	mov    $0x0,%eax
  800495:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800498:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80049b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80049f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004a2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004a5:	83 f9 09             	cmp    $0x9,%ecx
  8004a8:	77 52                	ja     8004fc <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8004aa:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004ad:	eb e9                	jmp    800498 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8004af:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b2:	8d 50 04             	lea    0x4(%eax),%edx
  8004b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b8:	8b 00                	mov    (%eax),%eax
  8004ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004c0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c4:	79 93                	jns    800459 <vprintfmt+0x39>
				width = precision, precision = -1;
  8004c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004d3:	eb 84                	jmp    800459 <vprintfmt+0x39>
  8004d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d8:	85 c0                	test   %eax,%eax
  8004da:	ba 00 00 00 00       	mov    $0x0,%edx
  8004df:	0f 49 d0             	cmovns %eax,%edx
  8004e2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004e8:	e9 6c ff ff ff       	jmp    800459 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004f0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004f7:	e9 5d ff ff ff       	jmp    800459 <vprintfmt+0x39>
  8004fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ff:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800502:	eb bc                	jmp    8004c0 <vprintfmt+0xa0>
			lflag++;
  800504:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80050a:	e9 4a ff ff ff       	jmp    800459 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
  800512:	8d 50 04             	lea    0x4(%eax),%edx
  800515:	89 55 14             	mov    %edx,0x14(%ebp)
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	56                   	push   %esi
  80051c:	ff 30                	pushl  (%eax)
  80051e:	ff d3                	call   *%ebx
			break;
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	e9 96 01 00 00       	jmp    8006be <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 04             	lea    0x4(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	8b 00                	mov    (%eax),%eax
  800533:	99                   	cltd   
  800534:	31 d0                	xor    %edx,%eax
  800536:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800538:	83 f8 0f             	cmp    $0xf,%eax
  80053b:	7f 20                	jg     80055d <vprintfmt+0x13d>
  80053d:	8b 14 85 20 28 80 00 	mov    0x802820(,%eax,4),%edx
  800544:	85 d2                	test   %edx,%edx
  800546:	74 15                	je     80055d <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800548:	52                   	push   %edx
  800549:	68 51 2b 80 00       	push   $0x802b51
  80054e:	56                   	push   %esi
  80054f:	53                   	push   %ebx
  800550:	e8 aa fe ff ff       	call   8003ff <printfmt>
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	e9 61 01 00 00       	jmp    8006be <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80055d:	50                   	push   %eax
  80055e:	68 8c 25 80 00       	push   $0x80258c
  800563:	56                   	push   %esi
  800564:	53                   	push   %ebx
  800565:	e8 95 fe ff ff       	call   8003ff <printfmt>
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	e9 4c 01 00 00       	jmp    8006be <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 50 04             	lea    0x4(%eax),%edx
  800578:	89 55 14             	mov    %edx,0x14(%ebp)
  80057b:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80057d:	85 c9                	test   %ecx,%ecx
  80057f:	b8 85 25 80 00       	mov    $0x802585,%eax
  800584:	0f 45 c1             	cmovne %ecx,%eax
  800587:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80058a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058e:	7e 06                	jle    800596 <vprintfmt+0x176>
  800590:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800594:	75 0d                	jne    8005a3 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800596:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800599:	89 c7                	mov    %eax,%edi
  80059b:	03 45 e0             	add    -0x20(%ebp),%eax
  80059e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a1:	eb 57                	jmp    8005fa <vprintfmt+0x1da>
  8005a3:	83 ec 08             	sub    $0x8,%esp
  8005a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8005a9:	ff 75 cc             	pushl  -0x34(%ebp)
  8005ac:	e8 4f 02 00 00       	call   800800 <strnlen>
  8005b1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005b4:	29 c2                	sub    %eax,%edx
  8005b6:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005b9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005bc:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005c0:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8005c3:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c5:	85 db                	test   %ebx,%ebx
  8005c7:	7e 10                	jle    8005d9 <vprintfmt+0x1b9>
					putch(padc, putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	56                   	push   %esi
  8005cd:	57                   	push   %edi
  8005ce:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d1:	83 eb 01             	sub    $0x1,%ebx
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	eb ec                	jmp    8005c5 <vprintfmt+0x1a5>
  8005d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005dc:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005df:	85 d2                	test   %edx,%edx
  8005e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e6:	0f 49 c2             	cmovns %edx,%eax
  8005e9:	29 c2                	sub    %eax,%edx
  8005eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005ee:	eb a6                	jmp    800596 <vprintfmt+0x176>
					putch(ch, putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	56                   	push   %esi
  8005f4:	52                   	push   %edx
  8005f5:	ff d3                	call   *%ebx
  8005f7:	83 c4 10             	add    $0x10,%esp
  8005fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005fd:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ff:	83 c7 01             	add    $0x1,%edi
  800602:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800606:	0f be d0             	movsbl %al,%edx
  800609:	85 d2                	test   %edx,%edx
  80060b:	74 42                	je     80064f <vprintfmt+0x22f>
  80060d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800611:	78 06                	js     800619 <vprintfmt+0x1f9>
  800613:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800617:	78 1e                	js     800637 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800619:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80061d:	74 d1                	je     8005f0 <vprintfmt+0x1d0>
  80061f:	0f be c0             	movsbl %al,%eax
  800622:	83 e8 20             	sub    $0x20,%eax
  800625:	83 f8 5e             	cmp    $0x5e,%eax
  800628:	76 c6                	jbe    8005f0 <vprintfmt+0x1d0>
					putch('?', putdat);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	56                   	push   %esi
  80062e:	6a 3f                	push   $0x3f
  800630:	ff d3                	call   *%ebx
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	eb c3                	jmp    8005fa <vprintfmt+0x1da>
  800637:	89 cf                	mov    %ecx,%edi
  800639:	eb 0e                	jmp    800649 <vprintfmt+0x229>
				putch(' ', putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	56                   	push   %esi
  80063f:	6a 20                	push   $0x20
  800641:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800643:	83 ef 01             	sub    $0x1,%edi
  800646:	83 c4 10             	add    $0x10,%esp
  800649:	85 ff                	test   %edi,%edi
  80064b:	7f ee                	jg     80063b <vprintfmt+0x21b>
  80064d:	eb 6f                	jmp    8006be <vprintfmt+0x29e>
  80064f:	89 cf                	mov    %ecx,%edi
  800651:	eb f6                	jmp    800649 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800653:	89 ca                	mov    %ecx,%edx
  800655:	8d 45 14             	lea    0x14(%ebp),%eax
  800658:	e8 55 fd ff ff       	call   8003b2 <getint>
  80065d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800660:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800663:	85 d2                	test   %edx,%edx
  800665:	78 0b                	js     800672 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800667:	89 d1                	mov    %edx,%ecx
  800669:	89 c2                	mov    %eax,%edx
			base = 10;
  80066b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800670:	eb 32                	jmp    8006a4 <vprintfmt+0x284>
				putch('-', putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	56                   	push   %esi
  800676:	6a 2d                	push   $0x2d
  800678:	ff d3                	call   *%ebx
				num = -(long long) num;
  80067a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80067d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800680:	f7 da                	neg    %edx
  800682:	83 d1 00             	adc    $0x0,%ecx
  800685:	f7 d9                	neg    %ecx
  800687:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80068a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068f:	eb 13                	jmp    8006a4 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800691:	89 ca                	mov    %ecx,%edx
  800693:	8d 45 14             	lea    0x14(%ebp),%eax
  800696:	e8 e3 fc ff ff       	call   80037e <getuint>
  80069b:	89 d1                	mov    %edx,%ecx
  80069d:	89 c2                	mov    %eax,%edx
			base = 10;
  80069f:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006a4:	83 ec 0c             	sub    $0xc,%esp
  8006a7:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006ab:	57                   	push   %edi
  8006ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8006af:	50                   	push   %eax
  8006b0:	51                   	push   %ecx
  8006b1:	52                   	push   %edx
  8006b2:	89 f2                	mov    %esi,%edx
  8006b4:	89 d8                	mov    %ebx,%eax
  8006b6:	e8 1a fc ff ff       	call   8002d5 <printnum>
			break;
  8006bb:	83 c4 20             	add    $0x20,%esp
{
  8006be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006c1:	83 c7 01             	add    $0x1,%edi
  8006c4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006c8:	83 f8 25             	cmp    $0x25,%eax
  8006cb:	0f 84 6a fd ff ff    	je     80043b <vprintfmt+0x1b>
			if (ch == '\0')
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	0f 84 93 00 00 00    	je     80076c <vprintfmt+0x34c>
			putch(ch, putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	56                   	push   %esi
  8006dd:	50                   	push   %eax
  8006de:	ff d3                	call   *%ebx
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	eb dc                	jmp    8006c1 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8006e5:	89 ca                	mov    %ecx,%edx
  8006e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ea:	e8 8f fc ff ff       	call   80037e <getuint>
  8006ef:	89 d1                	mov    %edx,%ecx
  8006f1:	89 c2                	mov    %eax,%edx
			base = 8;
  8006f3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006f8:	eb aa                	jmp    8006a4 <vprintfmt+0x284>
			putch('0', putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	56                   	push   %esi
  8006fe:	6a 30                	push   $0x30
  800700:	ff d3                	call   *%ebx
			putch('x', putdat);
  800702:	83 c4 08             	add    $0x8,%esp
  800705:	56                   	push   %esi
  800706:	6a 78                	push   $0x78
  800708:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8d 50 04             	lea    0x4(%eax),%edx
  800710:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800713:	8b 10                	mov    (%eax),%edx
  800715:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80071a:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80071d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800722:	eb 80                	jmp    8006a4 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800724:	89 ca                	mov    %ecx,%edx
  800726:	8d 45 14             	lea    0x14(%ebp),%eax
  800729:	e8 50 fc ff ff       	call   80037e <getuint>
  80072e:	89 d1                	mov    %edx,%ecx
  800730:	89 c2                	mov    %eax,%edx
			base = 16;
  800732:	b8 10 00 00 00       	mov    $0x10,%eax
  800737:	e9 68 ff ff ff       	jmp    8006a4 <vprintfmt+0x284>
			putch(ch, putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	56                   	push   %esi
  800740:	6a 25                	push   $0x25
  800742:	ff d3                	call   *%ebx
			break;
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	e9 72 ff ff ff       	jmp    8006be <vprintfmt+0x29e>
			putch('%', putdat);
  80074c:	83 ec 08             	sub    $0x8,%esp
  80074f:	56                   	push   %esi
  800750:	6a 25                	push   $0x25
  800752:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	89 f8                	mov    %edi,%eax
  800759:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80075d:	74 05                	je     800764 <vprintfmt+0x344>
  80075f:	83 e8 01             	sub    $0x1,%eax
  800762:	eb f5                	jmp    800759 <vprintfmt+0x339>
  800764:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800767:	e9 52 ff ff ff       	jmp    8006be <vprintfmt+0x29e>
}
  80076c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076f:	5b                   	pop    %ebx
  800770:	5e                   	pop    %esi
  800771:	5f                   	pop    %edi
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800774:	f3 0f 1e fb          	endbr32 
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	83 ec 18             	sub    $0x18,%esp
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800784:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800787:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800795:	85 c0                	test   %eax,%eax
  800797:	74 26                	je     8007bf <vsnprintf+0x4b>
  800799:	85 d2                	test   %edx,%edx
  80079b:	7e 22                	jle    8007bf <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079d:	ff 75 14             	pushl  0x14(%ebp)
  8007a0:	ff 75 10             	pushl  0x10(%ebp)
  8007a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	68 de 03 80 00       	push   $0x8003de
  8007ac:	e8 6f fc ff ff       	call   800420 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ba:	83 c4 10             	add    $0x10,%esp
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    
		return -E_INVAL;
  8007bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c4:	eb f7                	jmp    8007bd <vsnprintf+0x49>

008007c6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c6:	f3 0f 1e fb          	endbr32 
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d3:	50                   	push   %eax
  8007d4:	ff 75 10             	pushl  0x10(%ebp)
  8007d7:	ff 75 0c             	pushl  0xc(%ebp)
  8007da:	ff 75 08             	pushl  0x8(%ebp)
  8007dd:	e8 92 ff ff ff       	call   800774 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e2:	c9                   	leave  
  8007e3:	c3                   	ret    

008007e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e4:	f3 0f 1e fb          	endbr32 
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f7:	74 05                	je     8007fe <strlen+0x1a>
		n++;
  8007f9:	83 c0 01             	add    $0x1,%eax
  8007fc:	eb f5                	jmp    8007f3 <strlen+0xf>
	return n;
}
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800800:	f3 0f 1e fb          	endbr32 
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080d:	b8 00 00 00 00       	mov    $0x0,%eax
  800812:	39 d0                	cmp    %edx,%eax
  800814:	74 0d                	je     800823 <strnlen+0x23>
  800816:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80081a:	74 05                	je     800821 <strnlen+0x21>
		n++;
  80081c:	83 c0 01             	add    $0x1,%eax
  80081f:	eb f1                	jmp    800812 <strnlen+0x12>
  800821:	89 c2                	mov    %eax,%edx
	return n;
}
  800823:	89 d0                	mov    %edx,%eax
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800827:	f3 0f 1e fb          	endbr32 
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800832:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
  80083a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80083e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800841:	83 c0 01             	add    $0x1,%eax
  800844:	84 d2                	test   %dl,%dl
  800846:	75 f2                	jne    80083a <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800848:	89 c8                	mov    %ecx,%eax
  80084a:	5b                   	pop    %ebx
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084d:	f3 0f 1e fb          	endbr32 
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	53                   	push   %ebx
  800855:	83 ec 10             	sub    $0x10,%esp
  800858:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085b:	53                   	push   %ebx
  80085c:	e8 83 ff ff ff       	call   8007e4 <strlen>
  800861:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800864:	ff 75 0c             	pushl  0xc(%ebp)
  800867:	01 d8                	add    %ebx,%eax
  800869:	50                   	push   %eax
  80086a:	e8 b8 ff ff ff       	call   800827 <strcpy>
	return dst;
}
  80086f:	89 d8                	mov    %ebx,%eax
  800871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800874:	c9                   	leave  
  800875:	c3                   	ret    

00800876 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800876:	f3 0f 1e fb          	endbr32 
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	56                   	push   %esi
  80087e:	53                   	push   %ebx
  80087f:	8b 75 08             	mov    0x8(%ebp),%esi
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
  800885:	89 f3                	mov    %esi,%ebx
  800887:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088a:	89 f0                	mov    %esi,%eax
  80088c:	39 d8                	cmp    %ebx,%eax
  80088e:	74 11                	je     8008a1 <strncpy+0x2b>
		*dst++ = *src;
  800890:	83 c0 01             	add    $0x1,%eax
  800893:	0f b6 0a             	movzbl (%edx),%ecx
  800896:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800899:	80 f9 01             	cmp    $0x1,%cl
  80089c:	83 da ff             	sbb    $0xffffffff,%edx
  80089f:	eb eb                	jmp    80088c <strncpy+0x16>
	}
	return ret;
}
  8008a1:	89 f0                	mov    %esi,%eax
  8008a3:	5b                   	pop    %ebx
  8008a4:	5e                   	pop    %esi
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a7:	f3 0f 1e fb          	endbr32 
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	56                   	push   %esi
  8008af:	53                   	push   %ebx
  8008b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b6:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008bb:	85 d2                	test   %edx,%edx
  8008bd:	74 21                	je     8008e0 <strlcpy+0x39>
  8008bf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008c3:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008c5:	39 c2                	cmp    %eax,%edx
  8008c7:	74 14                	je     8008dd <strlcpy+0x36>
  8008c9:	0f b6 19             	movzbl (%ecx),%ebx
  8008cc:	84 db                	test   %bl,%bl
  8008ce:	74 0b                	je     8008db <strlcpy+0x34>
			*dst++ = *src++;
  8008d0:	83 c1 01             	add    $0x1,%ecx
  8008d3:	83 c2 01             	add    $0x1,%edx
  8008d6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d9:	eb ea                	jmp    8008c5 <strlcpy+0x1e>
  8008db:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008dd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e0:	29 f0                	sub    %esi,%eax
}
  8008e2:	5b                   	pop    %ebx
  8008e3:	5e                   	pop    %esi
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e6:	f3 0f 1e fb          	endbr32 
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f3:	0f b6 01             	movzbl (%ecx),%eax
  8008f6:	84 c0                	test   %al,%al
  8008f8:	74 0c                	je     800906 <strcmp+0x20>
  8008fa:	3a 02                	cmp    (%edx),%al
  8008fc:	75 08                	jne    800906 <strcmp+0x20>
		p++, q++;
  8008fe:	83 c1 01             	add    $0x1,%ecx
  800901:	83 c2 01             	add    $0x1,%edx
  800904:	eb ed                	jmp    8008f3 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800906:	0f b6 c0             	movzbl %al,%eax
  800909:	0f b6 12             	movzbl (%edx),%edx
  80090c:	29 d0                	sub    %edx,%eax
}
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800910:	f3 0f 1e fb          	endbr32 
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	53                   	push   %ebx
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091e:	89 c3                	mov    %eax,%ebx
  800920:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800923:	eb 06                	jmp    80092b <strncmp+0x1b>
		n--, p++, q++;
  800925:	83 c0 01             	add    $0x1,%eax
  800928:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80092b:	39 d8                	cmp    %ebx,%eax
  80092d:	74 16                	je     800945 <strncmp+0x35>
  80092f:	0f b6 08             	movzbl (%eax),%ecx
  800932:	84 c9                	test   %cl,%cl
  800934:	74 04                	je     80093a <strncmp+0x2a>
  800936:	3a 0a                	cmp    (%edx),%cl
  800938:	74 eb                	je     800925 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80093a:	0f b6 00             	movzbl (%eax),%eax
  80093d:	0f b6 12             	movzbl (%edx),%edx
  800940:	29 d0                	sub    %edx,%eax
}
  800942:	5b                   	pop    %ebx
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    
		return 0;
  800945:	b8 00 00 00 00       	mov    $0x0,%eax
  80094a:	eb f6                	jmp    800942 <strncmp+0x32>

0080094c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80094c:	f3 0f 1e fb          	endbr32 
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	8b 45 08             	mov    0x8(%ebp),%eax
  800956:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095a:	0f b6 10             	movzbl (%eax),%edx
  80095d:	84 d2                	test   %dl,%dl
  80095f:	74 09                	je     80096a <strchr+0x1e>
		if (*s == c)
  800961:	38 ca                	cmp    %cl,%dl
  800963:	74 0a                	je     80096f <strchr+0x23>
	for (; *s; s++)
  800965:	83 c0 01             	add    $0x1,%eax
  800968:	eb f0                	jmp    80095a <strchr+0xe>
			return (char *) s;
	return 0;
  80096a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800971:	f3 0f 1e fb          	endbr32 
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80097f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800982:	38 ca                	cmp    %cl,%dl
  800984:	74 09                	je     80098f <strfind+0x1e>
  800986:	84 d2                	test   %dl,%dl
  800988:	74 05                	je     80098f <strfind+0x1e>
	for (; *s; s++)
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	eb f0                	jmp    80097f <strfind+0xe>
			break;
	return (char *) s;
}
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800991:	f3 0f 1e fb          	endbr32 
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	57                   	push   %edi
  800999:	56                   	push   %esi
  80099a:	53                   	push   %ebx
  80099b:	8b 55 08             	mov    0x8(%ebp),%edx
  80099e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8009a1:	85 c9                	test   %ecx,%ecx
  8009a3:	74 33                	je     8009d8 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a5:	89 d0                	mov    %edx,%eax
  8009a7:	09 c8                	or     %ecx,%eax
  8009a9:	a8 03                	test   $0x3,%al
  8009ab:	75 23                	jne    8009d0 <memset+0x3f>
		c &= 0xFF;
  8009ad:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b1:	89 d8                	mov    %ebx,%eax
  8009b3:	c1 e0 08             	shl    $0x8,%eax
  8009b6:	89 df                	mov    %ebx,%edi
  8009b8:	c1 e7 18             	shl    $0x18,%edi
  8009bb:	89 de                	mov    %ebx,%esi
  8009bd:	c1 e6 10             	shl    $0x10,%esi
  8009c0:	09 f7                	or     %esi,%edi
  8009c2:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  8009c4:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8009c9:	89 d7                	mov    %edx,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ce:	eb 08                	jmp    8009d8 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d0:	89 d7                	mov    %edx,%edi
  8009d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d5:	fc                   	cld    
  8009d6:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8009d8:	89 d0                	mov    %edx,%eax
  8009da:	5b                   	pop    %ebx
  8009db:	5e                   	pop    %esi
  8009dc:	5f                   	pop    %edi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009df:	f3 0f 1e fb          	endbr32 
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	57                   	push   %edi
  8009e7:	56                   	push   %esi
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f1:	39 c6                	cmp    %eax,%esi
  8009f3:	73 32                	jae    800a27 <memmove+0x48>
  8009f5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f8:	39 c2                	cmp    %eax,%edx
  8009fa:	76 2b                	jbe    800a27 <memmove+0x48>
		s += n;
		d += n;
  8009fc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ff:	89 fe                	mov    %edi,%esi
  800a01:	09 ce                	or     %ecx,%esi
  800a03:	09 d6                	or     %edx,%esi
  800a05:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0b:	75 0e                	jne    800a1b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a0d:	83 ef 04             	sub    $0x4,%edi
  800a10:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a13:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a16:	fd                   	std    
  800a17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a19:	eb 09                	jmp    800a24 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a1b:	83 ef 01             	sub    $0x1,%edi
  800a1e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a21:	fd                   	std    
  800a22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a24:	fc                   	cld    
  800a25:	eb 1a                	jmp    800a41 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a27:	89 c2                	mov    %eax,%edx
  800a29:	09 ca                	or     %ecx,%edx
  800a2b:	09 f2                	or     %esi,%edx
  800a2d:	f6 c2 03             	test   $0x3,%dl
  800a30:	75 0a                	jne    800a3c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a32:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a35:	89 c7                	mov    %eax,%edi
  800a37:	fc                   	cld    
  800a38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3a:	eb 05                	jmp    800a41 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a3c:	89 c7                	mov    %eax,%edi
  800a3e:	fc                   	cld    
  800a3f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a41:	5e                   	pop    %esi
  800a42:	5f                   	pop    %edi
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a45:	f3 0f 1e fb          	endbr32 
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a4f:	ff 75 10             	pushl  0x10(%ebp)
  800a52:	ff 75 0c             	pushl  0xc(%ebp)
  800a55:	ff 75 08             	pushl  0x8(%ebp)
  800a58:	e8 82 ff ff ff       	call   8009df <memmove>
}
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5f:	f3 0f 1e fb          	endbr32 
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6e:	89 c6                	mov    %eax,%esi
  800a70:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a73:	39 f0                	cmp    %esi,%eax
  800a75:	74 1c                	je     800a93 <memcmp+0x34>
		if (*s1 != *s2)
  800a77:	0f b6 08             	movzbl (%eax),%ecx
  800a7a:	0f b6 1a             	movzbl (%edx),%ebx
  800a7d:	38 d9                	cmp    %bl,%cl
  800a7f:	75 08                	jne    800a89 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a81:	83 c0 01             	add    $0x1,%eax
  800a84:	83 c2 01             	add    $0x1,%edx
  800a87:	eb ea                	jmp    800a73 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a89:	0f b6 c1             	movzbl %cl,%eax
  800a8c:	0f b6 db             	movzbl %bl,%ebx
  800a8f:	29 d8                	sub    %ebx,%eax
  800a91:	eb 05                	jmp    800a98 <memcmp+0x39>
	}

	return 0;
  800a93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a9c:	f3 0f 1e fb          	endbr32 
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aa9:	89 c2                	mov    %eax,%edx
  800aab:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aae:	39 d0                	cmp    %edx,%eax
  800ab0:	73 09                	jae    800abb <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab2:	38 08                	cmp    %cl,(%eax)
  800ab4:	74 05                	je     800abb <memfind+0x1f>
	for (; s < ends; s++)
  800ab6:	83 c0 01             	add    $0x1,%eax
  800ab9:	eb f3                	jmp    800aae <memfind+0x12>
			break;
	return (void *) s;
}
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800abd:	f3 0f 1e fb          	endbr32 
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	57                   	push   %edi
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
  800ac7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800acd:	eb 03                	jmp    800ad2 <strtol+0x15>
		s++;
  800acf:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ad2:	0f b6 01             	movzbl (%ecx),%eax
  800ad5:	3c 20                	cmp    $0x20,%al
  800ad7:	74 f6                	je     800acf <strtol+0x12>
  800ad9:	3c 09                	cmp    $0x9,%al
  800adb:	74 f2                	je     800acf <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800add:	3c 2b                	cmp    $0x2b,%al
  800adf:	74 2a                	je     800b0b <strtol+0x4e>
	int neg = 0;
  800ae1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ae6:	3c 2d                	cmp    $0x2d,%al
  800ae8:	74 2b                	je     800b15 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aea:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800af0:	75 0f                	jne    800b01 <strtol+0x44>
  800af2:	80 39 30             	cmpb   $0x30,(%ecx)
  800af5:	74 28                	je     800b1f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800af7:	85 db                	test   %ebx,%ebx
  800af9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800afe:	0f 44 d8             	cmove  %eax,%ebx
  800b01:	b8 00 00 00 00       	mov    $0x0,%eax
  800b06:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b09:	eb 46                	jmp    800b51 <strtol+0x94>
		s++;
  800b0b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b13:	eb d5                	jmp    800aea <strtol+0x2d>
		s++, neg = 1;
  800b15:	83 c1 01             	add    $0x1,%ecx
  800b18:	bf 01 00 00 00       	mov    $0x1,%edi
  800b1d:	eb cb                	jmp    800aea <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b23:	74 0e                	je     800b33 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b25:	85 db                	test   %ebx,%ebx
  800b27:	75 d8                	jne    800b01 <strtol+0x44>
		s++, base = 8;
  800b29:	83 c1 01             	add    $0x1,%ecx
  800b2c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b31:	eb ce                	jmp    800b01 <strtol+0x44>
		s += 2, base = 16;
  800b33:	83 c1 02             	add    $0x2,%ecx
  800b36:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b3b:	eb c4                	jmp    800b01 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b3d:	0f be d2             	movsbl %dl,%edx
  800b40:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b43:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b46:	7d 3a                	jge    800b82 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b48:	83 c1 01             	add    $0x1,%ecx
  800b4b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b4f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b51:	0f b6 11             	movzbl (%ecx),%edx
  800b54:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b57:	89 f3                	mov    %esi,%ebx
  800b59:	80 fb 09             	cmp    $0x9,%bl
  800b5c:	76 df                	jbe    800b3d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b5e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b61:	89 f3                	mov    %esi,%ebx
  800b63:	80 fb 19             	cmp    $0x19,%bl
  800b66:	77 08                	ja     800b70 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b68:	0f be d2             	movsbl %dl,%edx
  800b6b:	83 ea 57             	sub    $0x57,%edx
  800b6e:	eb d3                	jmp    800b43 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b70:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b73:	89 f3                	mov    %esi,%ebx
  800b75:	80 fb 19             	cmp    $0x19,%bl
  800b78:	77 08                	ja     800b82 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b7a:	0f be d2             	movsbl %dl,%edx
  800b7d:	83 ea 37             	sub    $0x37,%edx
  800b80:	eb c1                	jmp    800b43 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b82:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b86:	74 05                	je     800b8d <strtol+0xd0>
		*endptr = (char *) s;
  800b88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b8d:	89 c2                	mov    %eax,%edx
  800b8f:	f7 da                	neg    %edx
  800b91:	85 ff                	test   %edi,%edi
  800b93:	0f 45 c2             	cmovne %edx,%eax
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
  800ba1:	83 ec 1c             	sub    $0x1c,%esp
  800ba4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ba7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800baa:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800baf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bb2:	8b 7d 10             	mov    0x10(%ebp),%edi
  800bb5:	8b 75 14             	mov    0x14(%ebp),%esi
  800bb8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800bbe:	74 04                	je     800bc4 <syscall+0x29>
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	7f 08                	jg     800bcc <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800bc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	50                   	push   %eax
  800bd0:	ff 75 e0             	pushl  -0x20(%ebp)
  800bd3:	68 7f 28 80 00       	push   $0x80287f
  800bd8:	6a 23                	push   $0x23
  800bda:	68 9c 28 80 00       	push   $0x80289c
  800bdf:	e8 3b 15 00 00       	call   80211f <_panic>

00800be4 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800be4:	f3 0f 1e fb          	endbr32 
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800bee:	6a 00                	push   $0x0
  800bf0:	6a 00                	push   $0x0
  800bf2:	6a 00                	push   $0x0
  800bf4:	ff 75 0c             	pushl  0xc(%ebp)
  800bf7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800bff:	b8 00 00 00 00       	mov    $0x0,%eax
  800c04:	e8 92 ff ff ff       	call   800b9b <syscall>
}
  800c09:	83 c4 10             	add    $0x10,%esp
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    

00800c0e <sys_cgetc>:

int
sys_cgetc(void)
{
  800c0e:	f3 0f 1e fb          	endbr32 
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c18:	6a 00                	push   $0x0
  800c1a:	6a 00                	push   $0x0
  800c1c:	6a 00                	push   $0x0
  800c1e:	6a 00                	push   $0x0
  800c20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c25:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c2f:	e8 67 ff ff ff       	call   800b9b <syscall>
}
  800c34:	c9                   	leave  
  800c35:	c3                   	ret    

00800c36 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c36:	f3 0f 1e fb          	endbr32 
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c40:	6a 00                	push   $0x0
  800c42:	6a 00                	push   $0x0
  800c44:	6a 00                	push   $0x0
  800c46:	6a 00                	push   $0x0
  800c48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4b:	ba 01 00 00 00       	mov    $0x1,%edx
  800c50:	b8 03 00 00 00       	mov    $0x3,%eax
  800c55:	e8 41 ff ff ff       	call   800b9b <syscall>
}
  800c5a:	c9                   	leave  
  800c5b:	c3                   	ret    

00800c5c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5c:	f3 0f 1e fb          	endbr32 
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c66:	6a 00                	push   $0x0
  800c68:	6a 00                	push   $0x0
  800c6a:	6a 00                	push   $0x0
  800c6c:	6a 00                	push   $0x0
  800c6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c73:	ba 00 00 00 00       	mov    $0x0,%edx
  800c78:	b8 02 00 00 00       	mov    $0x2,%eax
  800c7d:	e8 19 ff ff ff       	call   800b9b <syscall>
}
  800c82:	c9                   	leave  
  800c83:	c3                   	ret    

00800c84 <sys_yield>:

void
sys_yield(void)
{
  800c84:	f3 0f 1e fb          	endbr32 
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c8e:	6a 00                	push   $0x0
  800c90:	6a 00                	push   $0x0
  800c92:	6a 00                	push   $0x0
  800c94:	6a 00                	push   $0x0
  800c96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca5:	e8 f1 fe ff ff       	call   800b9b <syscall>
}
  800caa:	83 c4 10             	add    $0x10,%esp
  800cad:	c9                   	leave  
  800cae:	c3                   	ret    

00800caf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800caf:	f3 0f 1e fb          	endbr32 
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800cb9:	6a 00                	push   $0x0
  800cbb:	6a 00                	push   $0x0
  800cbd:	ff 75 10             	pushl  0x10(%ebp)
  800cc0:	ff 75 0c             	pushl  0xc(%ebp)
  800cc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc6:	ba 01 00 00 00       	mov    $0x1,%edx
  800ccb:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd0:	e8 c6 fe ff ff       	call   800b9b <syscall>
}
  800cd5:	c9                   	leave  
  800cd6:	c3                   	ret    

00800cd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd7:	f3 0f 1e fb          	endbr32 
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800ce1:	ff 75 18             	pushl  0x18(%ebp)
  800ce4:	ff 75 14             	pushl  0x14(%ebp)
  800ce7:	ff 75 10             	pushl  0x10(%ebp)
  800cea:	ff 75 0c             	pushl  0xc(%ebp)
  800ced:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf0:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf5:	b8 05 00 00 00       	mov    $0x5,%eax
  800cfa:	e8 9c fe ff ff       	call   800b9b <syscall>
}
  800cff:	c9                   	leave  
  800d00:	c3                   	ret    

00800d01 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d01:	f3 0f 1e fb          	endbr32 
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d0b:	6a 00                	push   $0x0
  800d0d:	6a 00                	push   $0x0
  800d0f:	6a 00                	push   $0x0
  800d11:	ff 75 0c             	pushl  0xc(%ebp)
  800d14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d17:	ba 01 00 00 00       	mov    $0x1,%edx
  800d1c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d21:	e8 75 fe ff ff       	call   800b9b <syscall>
}
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d28:	f3 0f 1e fb          	endbr32 
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d32:	6a 00                	push   $0x0
  800d34:	6a 00                	push   $0x0
  800d36:	6a 00                	push   $0x0
  800d38:	ff 75 0c             	pushl  0xc(%ebp)
  800d3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3e:	ba 01 00 00 00       	mov    $0x1,%edx
  800d43:	b8 08 00 00 00       	mov    $0x8,%eax
  800d48:	e8 4e fe ff ff       	call   800b9b <syscall>
}
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4f:	f3 0f 1e fb          	endbr32 
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d59:	6a 00                	push   $0x0
  800d5b:	6a 00                	push   $0x0
  800d5d:	6a 00                	push   $0x0
  800d5f:	ff 75 0c             	pushl  0xc(%ebp)
  800d62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d65:	ba 01 00 00 00       	mov    $0x1,%edx
  800d6a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6f:	e8 27 fe ff ff       	call   800b9b <syscall>
}
  800d74:	c9                   	leave  
  800d75:	c3                   	ret    

00800d76 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d76:	f3 0f 1e fb          	endbr32 
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d80:	6a 00                	push   $0x0
  800d82:	6a 00                	push   $0x0
  800d84:	6a 00                	push   $0x0
  800d86:	ff 75 0c             	pushl  0xc(%ebp)
  800d89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d8c:	ba 01 00 00 00       	mov    $0x1,%edx
  800d91:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d96:	e8 00 fe ff ff       	call   800b9b <syscall>
}
  800d9b:	c9                   	leave  
  800d9c:	c3                   	ret    

00800d9d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d9d:	f3 0f 1e fb          	endbr32 
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800da7:	6a 00                	push   $0x0
  800da9:	ff 75 14             	pushl  0x14(%ebp)
  800dac:	ff 75 10             	pushl  0x10(%ebp)
  800daf:	ff 75 0c             	pushl  0xc(%ebp)
  800db2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dba:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dbf:	e8 d7 fd ff ff       	call   800b9b <syscall>
}
  800dc4:	c9                   	leave  
  800dc5:	c3                   	ret    

00800dc6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc6:	f3 0f 1e fb          	endbr32 
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800dd0:	6a 00                	push   $0x0
  800dd2:	6a 00                	push   $0x0
  800dd4:	6a 00                	push   $0x0
  800dd6:	6a 00                	push   $0x0
  800dd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ddb:	ba 01 00 00 00       	mov    $0x1,%edx
  800de0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800de5:	e8 b1 fd ff ff       	call   800b9b <syscall>
}
  800dea:	c9                   	leave  
  800deb:	c3                   	ret    

00800dec <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	53                   	push   %ebx
  800df0:	83 ec 04             	sub    $0x4,%esp
	int r;

	// LAB 4: Your code here.
	void *addr = (void *) (pn * PGSIZE);
  800df3:	89 d3                	mov    %edx,%ebx
  800df5:	c1 e3 0c             	shl    $0xc,%ebx

	if (uvpt[pn] & PTE_SHARE) {
  800df8:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800dff:	f6 c5 04             	test   $0x4,%ch
  800e02:	75 56                	jne    800e5a <duppage+0x6e>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
		return 0;
	}

	if ((uvpt[pn] & (PTE_W | PTE_COW)) != 0) {
  800e04:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e0b:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800e11:	74 72                	je     800e85 <duppage+0x99>
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW) <
  800e13:	83 ec 0c             	sub    $0xc,%esp
  800e16:	68 05 08 00 00       	push   $0x805
  800e1b:	53                   	push   %ebx
  800e1c:	50                   	push   %eax
  800e1d:	53                   	push   %ebx
  800e1e:	6a 00                	push   $0x0
  800e20:	e8 b2 fe ff ff       	call   800cd7 <sys_page_map>
  800e25:	83 c4 20             	add    $0x20,%esp
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	78 45                	js     800e71 <duppage+0x85>
		    0) {
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
		}
		if (sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW) < 0) {
  800e2c:	83 ec 0c             	sub    $0xc,%esp
  800e2f:	68 05 08 00 00       	push   $0x805
  800e34:	53                   	push   %ebx
  800e35:	6a 00                	push   $0x0
  800e37:	53                   	push   %ebx
  800e38:	6a 00                	push   $0x0
  800e3a:	e8 98 fe ff ff       	call   800cd7 <sys_page_map>
  800e3f:	83 c4 20             	add    $0x20,%esp
  800e42:	85 c0                	test   %eax,%eax
  800e44:	79 55                	jns    800e9b <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP FATHER");
  800e46:	83 ec 04             	sub    $0x4,%esp
  800e49:	68 cc 28 80 00       	push   $0x8028cc
  800e4e:	6a 54                	push   $0x54
  800e50:	68 5f 29 80 00       	push   $0x80295f
  800e55:	e8 c5 12 00 00       	call   80211f <_panic>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  800e5a:	83 ec 0c             	sub    $0xc,%esp
  800e5d:	68 07 0e 00 00       	push   $0xe07
  800e62:	53                   	push   %ebx
  800e63:	50                   	push   %eax
  800e64:	53                   	push   %ebx
  800e65:	6a 00                	push   $0x0
  800e67:	e8 6b fe ff ff       	call   800cd7 <sys_page_map>
		return 0;
  800e6c:	83 c4 20             	add    $0x20,%esp
  800e6f:	eb 2a                	jmp    800e9b <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
  800e71:	83 ec 04             	sub    $0x4,%esp
  800e74:	68 ac 28 80 00       	push   $0x8028ac
  800e79:	6a 51                	push   $0x51
  800e7b:	68 5f 29 80 00       	push   $0x80295f
  800e80:	e8 9a 12 00 00       	call   80211f <_panic>
		}
	} else {
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U) < 0) {
  800e85:	83 ec 0c             	sub    $0xc,%esp
  800e88:	6a 05                	push   $0x5
  800e8a:	53                   	push   %ebx
  800e8b:	50                   	push   %eax
  800e8c:	53                   	push   %ebx
  800e8d:	6a 00                	push   $0x0
  800e8f:	e8 43 fe ff ff       	call   800cd7 <sys_page_map>
  800e94:	83 c4 20             	add    $0x20,%esp
  800e97:	85 c0                	test   %eax,%eax
  800e99:	78 0a                	js     800ea5 <duppage+0xb9>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
		}
	}

	return 0;
}
  800e9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
  800ea5:	83 ec 04             	sub    $0x4,%esp
  800ea8:	68 6a 29 80 00       	push   $0x80296a
  800ead:	6a 58                	push   $0x58
  800eaf:	68 5f 29 80 00       	push   $0x80295f
  800eb4:	e8 66 12 00 00       	call   80211f <_panic>

00800eb9 <dup_or_share>:

static void
dup_or_share(envid_t dstenv, void *va, int perm)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	56                   	push   %esi
  800ebd:	53                   	push   %ebx
  800ebe:	89 c6                	mov    %eax,%esi
  800ec0:	89 d3                	mov    %edx,%ebx
	int r;
	if (perm & PTE_W) {
  800ec2:	f6 c1 02             	test   $0x2,%cl
  800ec5:	0f 84 8c 00 00 00    	je     800f57 <dup_or_share+0x9e>
		// dup
		if ((r = sys_page_alloc(dstenv, va, PTE_P | PTE_U | PTE_W)) < 0)
  800ecb:	83 ec 04             	sub    $0x4,%esp
  800ece:	6a 07                	push   $0x7
  800ed0:	52                   	push   %edx
  800ed1:	50                   	push   %eax
  800ed2:	e8 d8 fd ff ff       	call   800caf <sys_page_alloc>
  800ed7:	83 c4 10             	add    $0x10,%esp
  800eda:	85 c0                	test   %eax,%eax
  800edc:	78 55                	js     800f33 <dup_or_share+0x7a>
			panic("sys_page_alloc: %e", r);
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  800ede:	83 ec 0c             	sub    $0xc,%esp
  800ee1:	6a 07                	push   $0x7
  800ee3:	68 00 00 40 00       	push   $0x400000
  800ee8:	6a 00                	push   $0x0
  800eea:	53                   	push   %ebx
  800eeb:	56                   	push   %esi
  800eec:	e8 e6 fd ff ff       	call   800cd7 <sys_page_map>
  800ef1:	83 c4 20             	add    $0x20,%esp
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	78 4d                	js     800f45 <dup_or_share+0x8c>
		    0)
			panic("sys_page_map: %e", r);
		memmove(UTEMP, va, PGSIZE);
  800ef8:	83 ec 04             	sub    $0x4,%esp
  800efb:	68 00 10 00 00       	push   $0x1000
  800f00:	53                   	push   %ebx
  800f01:	68 00 00 40 00       	push   $0x400000
  800f06:	e8 d4 fa ff ff       	call   8009df <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800f0b:	83 c4 08             	add    $0x8,%esp
  800f0e:	68 00 00 40 00       	push   $0x400000
  800f13:	6a 00                	push   $0x0
  800f15:	e8 e7 fd ff ff       	call   800d01 <sys_page_unmap>
  800f1a:	83 c4 10             	add    $0x10,%esp
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	79 52                	jns    800f73 <dup_or_share+0xba>
			panic("sys_page_unmap: %e", r);
  800f21:	50                   	push   %eax
  800f22:	68 aa 29 80 00       	push   $0x8029aa
  800f27:	6a 6c                	push   $0x6c
  800f29:	68 5f 29 80 00       	push   $0x80295f
  800f2e:	e8 ec 11 00 00       	call   80211f <_panic>
			panic("sys_page_alloc: %e", r);
  800f33:	50                   	push   %eax
  800f34:	68 86 29 80 00       	push   $0x802986
  800f39:	6a 66                	push   $0x66
  800f3b:	68 5f 29 80 00       	push   $0x80295f
  800f40:	e8 da 11 00 00       	call   80211f <_panic>
			panic("sys_page_map: %e", r);
  800f45:	50                   	push   %eax
  800f46:	68 99 29 80 00       	push   $0x802999
  800f4b:	6a 69                	push   $0x69
  800f4d:	68 5f 29 80 00       	push   $0x80295f
  800f52:	e8 c8 11 00 00       	call   80211f <_panic>

	} else {
		// share
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | perm)) <
  800f57:	83 ec 0c             	sub    $0xc,%esp
  800f5a:	83 c9 05             	or     $0x5,%ecx
  800f5d:	51                   	push   %ecx
  800f5e:	68 00 00 40 00       	push   $0x400000
  800f63:	6a 00                	push   $0x0
  800f65:	52                   	push   %edx
  800f66:	50                   	push   %eax
  800f67:	e8 6b fd ff ff       	call   800cd7 <sys_page_map>
  800f6c:	83 c4 20             	add    $0x20,%esp
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	78 07                	js     800f7a <dup_or_share+0xc1>
		    0)
			panic("sys_page_map: %e", r);
	}
}
  800f73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f76:	5b                   	pop    %ebx
  800f77:	5e                   	pop    %esi
  800f78:	5d                   	pop    %ebp
  800f79:	c3                   	ret    
			panic("sys_page_map: %e", r);
  800f7a:	50                   	push   %eax
  800f7b:	68 99 29 80 00       	push   $0x802999
  800f80:	6a 72                	push   $0x72
  800f82:	68 5f 29 80 00       	push   $0x80295f
  800f87:	e8 93 11 00 00       	call   80211f <_panic>

00800f8c <pgfault>:
{
  800f8c:	f3 0f 1e fb          	endbr32 
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	53                   	push   %ebx
  800f94:	83 ec 04             	sub    $0x4,%esp
  800f97:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800f9a:	8b 02                	mov    (%edx),%eax
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800f9c:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800fa0:	0f 84 95 00 00 00    	je     80103b <pgfault+0xaf>
  800fa6:	89 c2                	mov    %eax,%edx
  800fa8:	c1 ea 16             	shr    $0x16,%edx
  800fab:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fb2:	f6 c2 01             	test   $0x1,%dl
  800fb5:	0f 84 80 00 00 00    	je     80103b <pgfault+0xaf>
	    (~uvpt[PGNUM(addr)] & (PTE_COW | PTE_P)) != 0) {
  800fbb:	89 c2                	mov    %eax,%edx
  800fbd:	c1 ea 0c             	shr    $0xc,%edx
  800fc0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fc7:	f7 d2                	not    %edx
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  800fc9:	f7 c2 01 08 00 00    	test   $0x801,%edx
  800fcf:	75 6a                	jne    80103b <pgfault+0xaf>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800fd1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fd6:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U) < 0) {
  800fd8:	83 ec 04             	sub    $0x4,%esp
  800fdb:	6a 07                	push   $0x7
  800fdd:	68 00 f0 7f 00       	push   $0x7ff000
  800fe2:	6a 00                	push   $0x0
  800fe4:	e8 c6 fc ff ff       	call   800caf <sys_page_alloc>
  800fe9:	83 c4 10             	add    $0x10,%esp
  800fec:	85 c0                	test   %eax,%eax
  800fee:	78 5f                	js     80104f <pgfault+0xc3>
	memcpy((void *) PFTEMP, addr, PGSIZE);
  800ff0:	83 ec 04             	sub    $0x4,%esp
  800ff3:	68 00 10 00 00       	push   $0x1000
  800ff8:	53                   	push   %ebx
  800ff9:	68 00 f0 7f 00       	push   $0x7ff000
  800ffe:	e8 42 fa ff ff       	call   800a45 <memcpy>
	if (sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U) < 0) {
  801003:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80100a:	53                   	push   %ebx
  80100b:	6a 00                	push   $0x0
  80100d:	68 00 f0 7f 00       	push   $0x7ff000
  801012:	6a 00                	push   $0x0
  801014:	e8 be fc ff ff       	call   800cd7 <sys_page_map>
  801019:	83 c4 20             	add    $0x20,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 43                	js     801063 <pgfault+0xd7>
	if (sys_page_unmap(0, (void *) PFTEMP) < 0) {
  801020:	83 ec 08             	sub    $0x8,%esp
  801023:	68 00 f0 7f 00       	push   $0x7ff000
  801028:	6a 00                	push   $0x0
  80102a:	e8 d2 fc ff ff       	call   800d01 <sys_page_unmap>
  80102f:	83 c4 10             	add    $0x10,%esp
  801032:	85 c0                	test   %eax,%eax
  801034:	78 41                	js     801077 <pgfault+0xeb>
}
  801036:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801039:	c9                   	leave  
  80103a:	c3                   	ret    
		panic("ERROR PGFAULT");
  80103b:	83 ec 04             	sub    $0x4,%esp
  80103e:	68 bd 29 80 00       	push   $0x8029bd
  801043:	6a 1e                	push   $0x1e
  801045:	68 5f 29 80 00       	push   $0x80295f
  80104a:	e8 d0 10 00 00       	call   80211f <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_ALLOC");
  80104f:	83 ec 04             	sub    $0x4,%esp
  801052:	68 cb 29 80 00       	push   $0x8029cb
  801057:	6a 2b                	push   $0x2b
  801059:	68 5f 29 80 00       	push   $0x80295f
  80105e:	e8 bc 10 00 00       	call   80211f <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_MAP");
  801063:	83 ec 04             	sub    $0x4,%esp
  801066:	68 e9 29 80 00       	push   $0x8029e9
  80106b:	6a 2f                	push   $0x2f
  80106d:	68 5f 29 80 00       	push   $0x80295f
  801072:	e8 a8 10 00 00       	call   80211f <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_UNMAP");
  801077:	83 ec 04             	sub    $0x4,%esp
  80107a:	68 05 2a 80 00       	push   $0x802a05
  80107f:	6a 32                	push   $0x32
  801081:	68 5f 29 80 00       	push   $0x80295f
  801086:	e8 94 10 00 00       	call   80211f <_panic>

0080108b <fork_v0>:

envid_t
fork_v0(void)
{
  80108b:	f3 0f 1e fb          	endbr32 
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	57                   	push   %edi
  801093:	56                   	push   %esi
  801094:	53                   	push   %ebx
  801095:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801098:	b8 07 00 00 00       	mov    $0x7,%eax
  80109d:	cd 30                	int    $0x30
	envid_t env_id = sys_exofork();
	if (env_id < 0) {
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	78 24                	js     8010c7 <fork_v0+0x3c>
  8010a3:	89 c6                	mov    %eax,%esi
  8010a5:	89 c7                	mov    %eax,%edi
		thisenv = envs + ENVX(sys_getenvid());
		return env_id;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  8010a7:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (env_id == 0) {  // Son
  8010ac:	75 51                	jne    8010ff <fork_v0+0x74>
		thisenv = envs + ENVX(sys_getenvid());
  8010ae:	e8 a9 fb ff ff       	call   800c5c <sys_getenvid>
  8010b3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010b8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010bb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010c0:	a3 04 40 80 00       	mov    %eax,0x804004
		return env_id;
  8010c5:	eb 78                	jmp    80113f <fork_v0+0xb4>
		panic("ERROR ON FORK_V0");
  8010c7:	83 ec 04             	sub    $0x4,%esp
  8010ca:	68 23 2a 80 00       	push   $0x802a23
  8010cf:	6a 7b                	push   $0x7b
  8010d1:	68 5f 29 80 00       	push   $0x80295f
  8010d6:	e8 44 10 00 00       	call   80211f <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
				dup_or_share(env_id,
  8010db:	b9 07 00 00 00       	mov    $0x7,%ecx
  8010e0:	89 da                	mov    %ebx,%edx
  8010e2:	89 f8                	mov    %edi,%eax
  8010e4:	e8 d0 fd ff ff       	call   800eb9 <dup_or_share>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  8010e9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010ef:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8010f5:	77 36                	ja     80112d <fork_v0+0xa2>
		if (addr != UXSTACKTOP - PGSIZE) {
  8010f7:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010fd:	74 ea                	je     8010e9 <fork_v0+0x5e>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  8010ff:	89 d8                	mov    %ebx,%eax
  801101:	c1 e8 16             	shr    $0x16,%eax
  801104:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80110b:	a8 01                	test   $0x1,%al
  80110d:	74 da                	je     8010e9 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  80110f:	89 d8                	mov    %ebx,%eax
  801111:	c1 e8 0c             	shr    $0xc,%eax
  801114:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80111b:	f6 c2 01             	test   $0x1,%dl
  80111e:	74 c9                	je     8010e9 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
  801120:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  801127:	a8 04                	test   $0x4,%al
  801129:	74 be                	je     8010e9 <fork_v0+0x5e>
  80112b:	eb ae                	jmp    8010db <fork_v0+0x50>
				             PTE_P | PTE_U | PTE_W);
			}
		}
	}

	if (sys_env_set_status(env_id, ENV_RUNNABLE) < 0) {
  80112d:	83 ec 08             	sub    $0x8,%esp
  801130:	6a 02                	push   $0x2
  801132:	56                   	push   %esi
  801133:	e8 f0 fb ff ff       	call   800d28 <sys_env_set_status>
  801138:	83 c4 10             	add    $0x10,%esp
  80113b:	85 c0                	test   %eax,%eax
  80113d:	78 0a                	js     801149 <fork_v0+0xbe>
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
	}

	return env_id;
}
  80113f:	89 f0                	mov    %esi,%eax
  801141:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801144:	5b                   	pop    %ebx
  801145:	5e                   	pop    %esi
  801146:	5f                   	pop    %edi
  801147:	5d                   	pop    %ebp
  801148:	c3                   	ret    
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
  801149:	83 ec 04             	sub    $0x4,%esp
  80114c:	68 f0 28 80 00       	push   $0x8028f0
  801151:	68 92 00 00 00       	push   $0x92
  801156:	68 5f 29 80 00       	push   $0x80295f
  80115b:	e8 bf 0f 00 00       	call   80211f <_panic>

00801160 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801160:	f3 0f 1e fb          	endbr32 
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	57                   	push   %edi
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
  80116a:	83 ec 18             	sub    $0x18,%esp
	// return fork_v0(); // Uncomment this line if you want to run fork_v0.
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80116d:	68 8c 0f 80 00       	push   $0x800f8c
  801172:	e8 f2 0f 00 00       	call   802169 <set_pgfault_handler>
  801177:	b8 07 00 00 00       	mov    $0x7,%eax
  80117c:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0) {
  80117e:	83 c4 10             	add    $0x10,%esp
  801181:	85 c0                	test   %eax,%eax
  801183:	78 27                	js     8011ac <fork+0x4c>
  801185:	89 c7                	mov    %eax,%edi
  801187:	89 c6                	mov    %eax,%esi
		thisenv = envs + ENVX(sys_getenvid());
		return envid;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801189:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else if (envid == 0) {  // Son
  80118e:	75 55                	jne    8011e5 <fork+0x85>
		thisenv = envs + ENVX(sys_getenvid());
  801190:	e8 c7 fa ff ff       	call   800c5c <sys_getenvid>
  801195:	25 ff 03 00 00       	and    $0x3ff,%eax
  80119a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80119d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a2:	a3 04 40 80 00       	mov    %eax,0x804004
		return envid;
  8011a7:	e9 9b 00 00 00       	jmp    801247 <fork+0xe7>
		panic("ERROR IN FORK: SYS_EXOFORK");
  8011ac:	83 ec 04             	sub    $0x4,%esp
  8011af:	68 34 2a 80 00       	push   $0x802a34
  8011b4:	68 b1 00 00 00       	push   $0xb1
  8011b9:	68 5f 29 80 00       	push   $0x80295f
  8011be:	e8 5c 0f 00 00       	call   80211f <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
				duppage(envid, addr / PGSIZE);
  8011c3:	89 da                	mov    %ebx,%edx
  8011c5:	c1 ea 0c             	shr    $0xc,%edx
  8011c8:	89 f0                	mov    %esi,%eax
  8011ca:	e8 1d fc ff ff       	call   800dec <duppage>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  8011cf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011d5:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8011db:	77 2c                	ja     801209 <fork+0xa9>
		if (addr != UXSTACKTOP - PGSIZE) {
  8011dd:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8011e3:	74 ea                	je     8011cf <fork+0x6f>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  8011e5:	89 d8                	mov    %ebx,%eax
  8011e7:	c1 e8 16             	shr    $0x16,%eax
  8011ea:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011f1:	a8 01                	test   $0x1,%al
  8011f3:	74 da                	je     8011cf <fork+0x6f>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
  8011f5:	89 d8                	mov    %ebx,%eax
  8011f7:	c1 e8 0c             	shr    $0xc,%eax
  8011fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801201:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801203:	a8 05                	test   $0x5,%al
  801205:	75 c8                	jne    8011cf <fork+0x6f>
  801207:	eb ba                	jmp    8011c3 <fork+0x63>
			}
		}
	}

	if (sys_page_alloc(envid,
  801209:	83 ec 04             	sub    $0x4,%esp
  80120c:	6a 07                	push   $0x7
  80120e:	68 00 f0 bf ee       	push   $0xeebff000
  801213:	57                   	push   %edi
  801214:	e8 96 fa ff ff       	call   800caf <sys_page_alloc>
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	85 c0                	test   %eax,%eax
  80121e:	78 31                	js     801251 <fork+0xf1>
	                   PTE_P | PTE_U | PTE_W) < 0) {
		panic("ERROR FORK: SYS_PAGE_ALLOC");
	}

	extern void _pgfault_upcall(void);
	if (sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0) {
  801220:	83 ec 08             	sub    $0x8,%esp
  801223:	68 dc 21 80 00       	push   $0x8021dc
  801228:	57                   	push   %edi
  801229:	e8 48 fb ff ff       	call   800d76 <sys_env_set_pgfault_upcall>
  80122e:	83 c4 10             	add    $0x10,%esp
  801231:	85 c0                	test   %eax,%eax
  801233:	78 33                	js     801268 <fork+0x108>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
	}

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0) {
  801235:	83 ec 08             	sub    $0x8,%esp
  801238:	6a 02                	push   $0x2
  80123a:	57                   	push   %edi
  80123b:	e8 e8 fa ff ff       	call   800d28 <sys_env_set_status>
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	85 c0                	test   %eax,%eax
  801245:	78 38                	js     80127f <fork+0x11f>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
	}

	return envid;
}
  801247:	89 f8                	mov    %edi,%eax
  801249:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124c:	5b                   	pop    %ebx
  80124d:	5e                   	pop    %esi
  80124e:	5f                   	pop    %edi
  80124f:	5d                   	pop    %ebp
  801250:	c3                   	ret    
		panic("ERROR FORK: SYS_PAGE_ALLOC");
  801251:	83 ec 04             	sub    $0x4,%esp
  801254:	68 4f 2a 80 00       	push   $0x802a4f
  801259:	68 c4 00 00 00       	push   $0xc4
  80125e:	68 5f 29 80 00       	push   $0x80295f
  801263:	e8 b7 0e 00 00       	call   80211f <_panic>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
  801268:	83 ec 04             	sub    $0x4,%esp
  80126b:	68 18 29 80 00       	push   $0x802918
  801270:	68 c9 00 00 00       	push   $0xc9
  801275:	68 5f 29 80 00       	push   $0x80295f
  80127a:	e8 a0 0e 00 00       	call   80211f <_panic>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
  80127f:	83 ec 04             	sub    $0x4,%esp
  801282:	68 40 29 80 00       	push   $0x802940
  801287:	68 cd 00 00 00       	push   $0xcd
  80128c:	68 5f 29 80 00       	push   $0x80295f
  801291:	e8 89 0e 00 00       	call   80211f <_panic>

00801296 <sfork>:

// Challenge!
int
sfork(void)
{
  801296:	f3 0f 1e fb          	endbr32 
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012a0:	68 6a 2a 80 00       	push   $0x802a6a
  8012a5:	68 d7 00 00 00       	push   $0xd7
  8012aa:	68 5f 29 80 00       	push   $0x80295f
  8012af:	e8 6b 0e 00 00       	call   80211f <_panic>

008012b4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012b4:	f3 0f 1e fb          	endbr32 
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	56                   	push   %esi
  8012bc:	53                   	push   %ebx
  8012bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8012c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8012cd:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  8012d0:	83 ec 0c             	sub    $0xc,%esp
  8012d3:	50                   	push   %eax
  8012d4:	e8 ed fa ff ff       	call   800dc6 <sys_ipc_recv>
	if (f < 0) {
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 2b                	js     80130b <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  8012e0:	85 f6                	test   %esi,%esi
  8012e2:	74 0a                	je     8012ee <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  8012e4:	a1 04 40 80 00       	mov    0x804004,%eax
  8012e9:	8b 40 74             	mov    0x74(%eax),%eax
  8012ec:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  8012ee:	85 db                	test   %ebx,%ebx
  8012f0:	74 0a                	je     8012fc <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  8012f2:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f7:	8b 40 78             	mov    0x78(%eax),%eax
  8012fa:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  8012fc:	a1 04 40 80 00       	mov    0x804004,%eax
  801301:	8b 40 70             	mov    0x70(%eax),%eax
}
  801304:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801307:	5b                   	pop    %ebx
  801308:	5e                   	pop    %esi
  801309:	5d                   	pop    %ebp
  80130a:	c3                   	ret    
		if (from_env_store != NULL) {
  80130b:	85 f6                	test   %esi,%esi
  80130d:	74 06                	je     801315 <ipc_recv+0x61>
			*from_env_store = 0;
  80130f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801315:	85 db                	test   %ebx,%ebx
  801317:	74 eb                	je     801304 <ipc_recv+0x50>
			*perm_store = 0;
  801319:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80131f:	eb e3                	jmp    801304 <ipc_recv+0x50>

00801321 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801321:	f3 0f 1e fb          	endbr32 
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	57                   	push   %edi
  801329:	56                   	push   %esi
  80132a:	53                   	push   %ebx
  80132b:	83 ec 0c             	sub    $0xc,%esp
  80132e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801331:	8b 75 0c             	mov    0xc(%ebp),%esi
  801334:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  801337:	85 db                	test   %ebx,%ebx
  801339:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80133e:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801341:	ff 75 14             	pushl  0x14(%ebp)
  801344:	53                   	push   %ebx
  801345:	56                   	push   %esi
  801346:	57                   	push   %edi
  801347:	e8 51 fa ff ff       	call   800d9d <sys_ipc_try_send>
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	85 c0                	test   %eax,%eax
  801351:	79 19                	jns    80136c <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  801353:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801356:	74 e9                	je     801341 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  801358:	83 ec 04             	sub    $0x4,%esp
  80135b:	68 80 2a 80 00       	push   $0x802a80
  801360:	6a 48                	push   $0x48
  801362:	68 a2 2a 80 00       	push   $0x802aa2
  801367:	e8 b3 0d 00 00       	call   80211f <_panic>
		}
	}
}
  80136c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80136f:	5b                   	pop    %ebx
  801370:	5e                   	pop    %esi
  801371:	5f                   	pop    %edi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801374:	f3 0f 1e fb          	endbr32 
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80137e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801383:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801386:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80138c:	8b 52 50             	mov    0x50(%edx),%edx
  80138f:	39 ca                	cmp    %ecx,%edx
  801391:	74 11                	je     8013a4 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801393:	83 c0 01             	add    $0x1,%eax
  801396:	3d 00 04 00 00       	cmp    $0x400,%eax
  80139b:	75 e6                	jne    801383 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80139d:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a2:	eb 0b                	jmp    8013af <ipc_find_env+0x3b>
			return envs[i].env_id;
  8013a4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013a7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013ac:	8b 40 48             	mov    0x48(%eax),%eax
}
  8013af:	5d                   	pop    %ebp
  8013b0:	c3                   	ret    

008013b1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013b1:	f3 0f 1e fb          	endbr32 
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bb:	05 00 00 00 30       	add    $0x30000000,%eax
  8013c0:	c1 e8 0c             	shr    $0xc,%eax
}
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    

008013c5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013c5:	f3 0f 1e fb          	endbr32 
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  8013cf:	ff 75 08             	pushl  0x8(%ebp)
  8013d2:	e8 da ff ff ff       	call   8013b1 <fd2num>
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	c1 e0 0c             	shl    $0xc,%eax
  8013dd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013e2:	c9                   	leave  
  8013e3:	c3                   	ret    

008013e4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013e4:	f3 0f 1e fb          	endbr32 
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013f0:	89 c2                	mov    %eax,%edx
  8013f2:	c1 ea 16             	shr    $0x16,%edx
  8013f5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013fc:	f6 c2 01             	test   $0x1,%dl
  8013ff:	74 2d                	je     80142e <fd_alloc+0x4a>
  801401:	89 c2                	mov    %eax,%edx
  801403:	c1 ea 0c             	shr    $0xc,%edx
  801406:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80140d:	f6 c2 01             	test   $0x1,%dl
  801410:	74 1c                	je     80142e <fd_alloc+0x4a>
  801412:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801417:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80141c:	75 d2                	jne    8013f0 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80141e:	8b 45 08             	mov    0x8(%ebp),%eax
  801421:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801427:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80142c:	eb 0a                	jmp    801438 <fd_alloc+0x54>
			*fd_store = fd;
  80142e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801431:	89 01                	mov    %eax,(%ecx)
			return 0;
  801433:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801438:	5d                   	pop    %ebp
  801439:	c3                   	ret    

0080143a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80143a:	f3 0f 1e fb          	endbr32 
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801444:	83 f8 1f             	cmp    $0x1f,%eax
  801447:	77 30                	ja     801479 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801449:	c1 e0 0c             	shl    $0xc,%eax
  80144c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801451:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801457:	f6 c2 01             	test   $0x1,%dl
  80145a:	74 24                	je     801480 <fd_lookup+0x46>
  80145c:	89 c2                	mov    %eax,%edx
  80145e:	c1 ea 0c             	shr    $0xc,%edx
  801461:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801468:	f6 c2 01             	test   $0x1,%dl
  80146b:	74 1a                	je     801487 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80146d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801470:	89 02                	mov    %eax,(%edx)
	return 0;
  801472:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801477:	5d                   	pop    %ebp
  801478:	c3                   	ret    
		return -E_INVAL;
  801479:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80147e:	eb f7                	jmp    801477 <fd_lookup+0x3d>
		return -E_INVAL;
  801480:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801485:	eb f0                	jmp    801477 <fd_lookup+0x3d>
  801487:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80148c:	eb e9                	jmp    801477 <fd_lookup+0x3d>

0080148e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80148e:	f3 0f 1e fb          	endbr32 
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	83 ec 08             	sub    $0x8,%esp
  801498:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80149b:	ba 28 2b 80 00       	mov    $0x802b28,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014a0:	b8 0c 30 80 00       	mov    $0x80300c,%eax
		if (devtab[i]->dev_id == dev_id) {
  8014a5:	39 08                	cmp    %ecx,(%eax)
  8014a7:	74 33                	je     8014dc <dev_lookup+0x4e>
  8014a9:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8014ac:	8b 02                	mov    (%edx),%eax
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	75 f3                	jne    8014a5 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8014b7:	8b 40 48             	mov    0x48(%eax),%eax
  8014ba:	83 ec 04             	sub    $0x4,%esp
  8014bd:	51                   	push   %ecx
  8014be:	50                   	push   %eax
  8014bf:	68 ac 2a 80 00       	push   $0x802aac
  8014c4:	e8 f4 ed ff ff       	call   8002bd <cprintf>
	*dev = 0;
  8014c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014da:	c9                   	leave  
  8014db:	c3                   	ret    
			*dev = devtab[i];
  8014dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014df:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e6:	eb f2                	jmp    8014da <dev_lookup+0x4c>

008014e8 <fd_close>:
{
  8014e8:	f3 0f 1e fb          	endbr32 
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	57                   	push   %edi
  8014f0:	56                   	push   %esi
  8014f1:	53                   	push   %ebx
  8014f2:	83 ec 28             	sub    $0x28,%esp
  8014f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8014f8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014fb:	56                   	push   %esi
  8014fc:	e8 b0 fe ff ff       	call   8013b1 <fd2num>
  801501:	83 c4 08             	add    $0x8,%esp
  801504:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801507:	52                   	push   %edx
  801508:	50                   	push   %eax
  801509:	e8 2c ff ff ff       	call   80143a <fd_lookup>
  80150e:	89 c3                	mov    %eax,%ebx
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	85 c0                	test   %eax,%eax
  801515:	78 05                	js     80151c <fd_close+0x34>
	    || fd != fd2)
  801517:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80151a:	74 16                	je     801532 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80151c:	89 f8                	mov    %edi,%eax
  80151e:	84 c0                	test   %al,%al
  801520:	b8 00 00 00 00       	mov    $0x0,%eax
  801525:	0f 44 d8             	cmove  %eax,%ebx
}
  801528:	89 d8                	mov    %ebx,%eax
  80152a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152d:	5b                   	pop    %ebx
  80152e:	5e                   	pop    %esi
  80152f:	5f                   	pop    %edi
  801530:	5d                   	pop    %ebp
  801531:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801532:	83 ec 08             	sub    $0x8,%esp
  801535:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801538:	50                   	push   %eax
  801539:	ff 36                	pushl  (%esi)
  80153b:	e8 4e ff ff ff       	call   80148e <dev_lookup>
  801540:	89 c3                	mov    %eax,%ebx
  801542:	83 c4 10             	add    $0x10,%esp
  801545:	85 c0                	test   %eax,%eax
  801547:	78 1a                	js     801563 <fd_close+0x7b>
		if (dev->dev_close)
  801549:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80154c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80154f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801554:	85 c0                	test   %eax,%eax
  801556:	74 0b                	je     801563 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801558:	83 ec 0c             	sub    $0xc,%esp
  80155b:	56                   	push   %esi
  80155c:	ff d0                	call   *%eax
  80155e:	89 c3                	mov    %eax,%ebx
  801560:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801563:	83 ec 08             	sub    $0x8,%esp
  801566:	56                   	push   %esi
  801567:	6a 00                	push   $0x0
  801569:	e8 93 f7 ff ff       	call   800d01 <sys_page_unmap>
	return r;
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	eb b5                	jmp    801528 <fd_close+0x40>

00801573 <close>:

int
close(int fdnum)
{
  801573:	f3 0f 1e fb          	endbr32 
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80157d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801580:	50                   	push   %eax
  801581:	ff 75 08             	pushl  0x8(%ebp)
  801584:	e8 b1 fe ff ff       	call   80143a <fd_lookup>
  801589:	83 c4 10             	add    $0x10,%esp
  80158c:	85 c0                	test   %eax,%eax
  80158e:	79 02                	jns    801592 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801590:	c9                   	leave  
  801591:	c3                   	ret    
		return fd_close(fd, 1);
  801592:	83 ec 08             	sub    $0x8,%esp
  801595:	6a 01                	push   $0x1
  801597:	ff 75 f4             	pushl  -0xc(%ebp)
  80159a:	e8 49 ff ff ff       	call   8014e8 <fd_close>
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	eb ec                	jmp    801590 <close+0x1d>

008015a4 <close_all>:

void
close_all(void)
{
  8015a4:	f3 0f 1e fb          	endbr32 
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	53                   	push   %ebx
  8015ac:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015af:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015b4:	83 ec 0c             	sub    $0xc,%esp
  8015b7:	53                   	push   %ebx
  8015b8:	e8 b6 ff ff ff       	call   801573 <close>
	for (i = 0; i < MAXFD; i++)
  8015bd:	83 c3 01             	add    $0x1,%ebx
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	83 fb 20             	cmp    $0x20,%ebx
  8015c6:	75 ec                	jne    8015b4 <close_all+0x10>
}
  8015c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cb:	c9                   	leave  
  8015cc:	c3                   	ret    

008015cd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015cd:	f3 0f 1e fb          	endbr32 
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	57                   	push   %edi
  8015d5:	56                   	push   %esi
  8015d6:	53                   	push   %ebx
  8015d7:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015da:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	ff 75 08             	pushl  0x8(%ebp)
  8015e1:	e8 54 fe ff ff       	call   80143a <fd_lookup>
  8015e6:	89 c3                	mov    %eax,%ebx
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	0f 88 81 00 00 00    	js     801674 <dup+0xa7>
		return r;
	close(newfdnum);
  8015f3:	83 ec 0c             	sub    $0xc,%esp
  8015f6:	ff 75 0c             	pushl  0xc(%ebp)
  8015f9:	e8 75 ff ff ff       	call   801573 <close>

	newfd = INDEX2FD(newfdnum);
  8015fe:	8b 75 0c             	mov    0xc(%ebp),%esi
  801601:	c1 e6 0c             	shl    $0xc,%esi
  801604:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80160a:	83 c4 04             	add    $0x4,%esp
  80160d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801610:	e8 b0 fd ff ff       	call   8013c5 <fd2data>
  801615:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801617:	89 34 24             	mov    %esi,(%esp)
  80161a:	e8 a6 fd ff ff       	call   8013c5 <fd2data>
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801624:	89 d8                	mov    %ebx,%eax
  801626:	c1 e8 16             	shr    $0x16,%eax
  801629:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801630:	a8 01                	test   $0x1,%al
  801632:	74 11                	je     801645 <dup+0x78>
  801634:	89 d8                	mov    %ebx,%eax
  801636:	c1 e8 0c             	shr    $0xc,%eax
  801639:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801640:	f6 c2 01             	test   $0x1,%dl
  801643:	75 39                	jne    80167e <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801645:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801648:	89 d0                	mov    %edx,%eax
  80164a:	c1 e8 0c             	shr    $0xc,%eax
  80164d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801654:	83 ec 0c             	sub    $0xc,%esp
  801657:	25 07 0e 00 00       	and    $0xe07,%eax
  80165c:	50                   	push   %eax
  80165d:	56                   	push   %esi
  80165e:	6a 00                	push   $0x0
  801660:	52                   	push   %edx
  801661:	6a 00                	push   $0x0
  801663:	e8 6f f6 ff ff       	call   800cd7 <sys_page_map>
  801668:	89 c3                	mov    %eax,%ebx
  80166a:	83 c4 20             	add    $0x20,%esp
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 31                	js     8016a2 <dup+0xd5>
		goto err;

	return newfdnum;
  801671:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801674:	89 d8                	mov    %ebx,%eax
  801676:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801679:	5b                   	pop    %ebx
  80167a:	5e                   	pop    %esi
  80167b:	5f                   	pop    %edi
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80167e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801685:	83 ec 0c             	sub    $0xc,%esp
  801688:	25 07 0e 00 00       	and    $0xe07,%eax
  80168d:	50                   	push   %eax
  80168e:	57                   	push   %edi
  80168f:	6a 00                	push   $0x0
  801691:	53                   	push   %ebx
  801692:	6a 00                	push   $0x0
  801694:	e8 3e f6 ff ff       	call   800cd7 <sys_page_map>
  801699:	89 c3                	mov    %eax,%ebx
  80169b:	83 c4 20             	add    $0x20,%esp
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	79 a3                	jns    801645 <dup+0x78>
	sys_page_unmap(0, newfd);
  8016a2:	83 ec 08             	sub    $0x8,%esp
  8016a5:	56                   	push   %esi
  8016a6:	6a 00                	push   $0x0
  8016a8:	e8 54 f6 ff ff       	call   800d01 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016ad:	83 c4 08             	add    $0x8,%esp
  8016b0:	57                   	push   %edi
  8016b1:	6a 00                	push   $0x0
  8016b3:	e8 49 f6 ff ff       	call   800d01 <sys_page_unmap>
	return r;
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	eb b7                	jmp    801674 <dup+0xa7>

008016bd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016bd:	f3 0f 1e fb          	endbr32 
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	53                   	push   %ebx
  8016c5:	83 ec 1c             	sub    $0x1c,%esp
  8016c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ce:	50                   	push   %eax
  8016cf:	53                   	push   %ebx
  8016d0:	e8 65 fd ff ff       	call   80143a <fd_lookup>
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	78 3f                	js     80171b <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016dc:	83 ec 08             	sub    $0x8,%esp
  8016df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e2:	50                   	push   %eax
  8016e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e6:	ff 30                	pushl  (%eax)
  8016e8:	e8 a1 fd ff ff       	call   80148e <dev_lookup>
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	78 27                	js     80171b <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016f7:	8b 42 08             	mov    0x8(%edx),%eax
  8016fa:	83 e0 03             	and    $0x3,%eax
  8016fd:	83 f8 01             	cmp    $0x1,%eax
  801700:	74 1e                	je     801720 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801702:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801705:	8b 40 08             	mov    0x8(%eax),%eax
  801708:	85 c0                	test   %eax,%eax
  80170a:	74 35                	je     801741 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80170c:	83 ec 04             	sub    $0x4,%esp
  80170f:	ff 75 10             	pushl  0x10(%ebp)
  801712:	ff 75 0c             	pushl  0xc(%ebp)
  801715:	52                   	push   %edx
  801716:	ff d0                	call   *%eax
  801718:	83 c4 10             	add    $0x10,%esp
}
  80171b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171e:	c9                   	leave  
  80171f:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801720:	a1 04 40 80 00       	mov    0x804004,%eax
  801725:	8b 40 48             	mov    0x48(%eax),%eax
  801728:	83 ec 04             	sub    $0x4,%esp
  80172b:	53                   	push   %ebx
  80172c:	50                   	push   %eax
  80172d:	68 ed 2a 80 00       	push   $0x802aed
  801732:	e8 86 eb ff ff       	call   8002bd <cprintf>
		return -E_INVAL;
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80173f:	eb da                	jmp    80171b <read+0x5e>
		return -E_NOT_SUPP;
  801741:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801746:	eb d3                	jmp    80171b <read+0x5e>

00801748 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801748:	f3 0f 1e fb          	endbr32 
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	57                   	push   %edi
  801750:	56                   	push   %esi
  801751:	53                   	push   %ebx
  801752:	83 ec 0c             	sub    $0xc,%esp
  801755:	8b 7d 08             	mov    0x8(%ebp),%edi
  801758:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80175b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801760:	eb 02                	jmp    801764 <readn+0x1c>
  801762:	01 c3                	add    %eax,%ebx
  801764:	39 f3                	cmp    %esi,%ebx
  801766:	73 21                	jae    801789 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801768:	83 ec 04             	sub    $0x4,%esp
  80176b:	89 f0                	mov    %esi,%eax
  80176d:	29 d8                	sub    %ebx,%eax
  80176f:	50                   	push   %eax
  801770:	89 d8                	mov    %ebx,%eax
  801772:	03 45 0c             	add    0xc(%ebp),%eax
  801775:	50                   	push   %eax
  801776:	57                   	push   %edi
  801777:	e8 41 ff ff ff       	call   8016bd <read>
		if (m < 0)
  80177c:	83 c4 10             	add    $0x10,%esp
  80177f:	85 c0                	test   %eax,%eax
  801781:	78 04                	js     801787 <readn+0x3f>
			return m;
		if (m == 0)
  801783:	75 dd                	jne    801762 <readn+0x1a>
  801785:	eb 02                	jmp    801789 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801787:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801789:	89 d8                	mov    %ebx,%eax
  80178b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80178e:	5b                   	pop    %ebx
  80178f:	5e                   	pop    %esi
  801790:	5f                   	pop    %edi
  801791:	5d                   	pop    %ebp
  801792:	c3                   	ret    

00801793 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801793:	f3 0f 1e fb          	endbr32 
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	53                   	push   %ebx
  80179b:	83 ec 1c             	sub    $0x1c,%esp
  80179e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a4:	50                   	push   %eax
  8017a5:	53                   	push   %ebx
  8017a6:	e8 8f fc ff ff       	call   80143a <fd_lookup>
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	78 3a                	js     8017ec <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b2:	83 ec 08             	sub    $0x8,%esp
  8017b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b8:	50                   	push   %eax
  8017b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017bc:	ff 30                	pushl  (%eax)
  8017be:	e8 cb fc ff ff       	call   80148e <dev_lookup>
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	78 22                	js     8017ec <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017cd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017d1:	74 1e                	je     8017f1 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d6:	8b 52 0c             	mov    0xc(%edx),%edx
  8017d9:	85 d2                	test   %edx,%edx
  8017db:	74 35                	je     801812 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017dd:	83 ec 04             	sub    $0x4,%esp
  8017e0:	ff 75 10             	pushl  0x10(%ebp)
  8017e3:	ff 75 0c             	pushl  0xc(%ebp)
  8017e6:	50                   	push   %eax
  8017e7:	ff d2                	call   *%edx
  8017e9:	83 c4 10             	add    $0x10,%esp
}
  8017ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ef:	c9                   	leave  
  8017f0:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8017f6:	8b 40 48             	mov    0x48(%eax),%eax
  8017f9:	83 ec 04             	sub    $0x4,%esp
  8017fc:	53                   	push   %ebx
  8017fd:	50                   	push   %eax
  8017fe:	68 09 2b 80 00       	push   $0x802b09
  801803:	e8 b5 ea ff ff       	call   8002bd <cprintf>
		return -E_INVAL;
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801810:	eb da                	jmp    8017ec <write+0x59>
		return -E_NOT_SUPP;
  801812:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801817:	eb d3                	jmp    8017ec <write+0x59>

00801819 <seek>:

int
seek(int fdnum, off_t offset)
{
  801819:	f3 0f 1e fb          	endbr32 
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801823:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801826:	50                   	push   %eax
  801827:	ff 75 08             	pushl  0x8(%ebp)
  80182a:	e8 0b fc ff ff       	call   80143a <fd_lookup>
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	85 c0                	test   %eax,%eax
  801834:	78 0e                	js     801844 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801836:	8b 55 0c             	mov    0xc(%ebp),%edx
  801839:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80183f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801846:	f3 0f 1e fb          	endbr32 
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	53                   	push   %ebx
  80184e:	83 ec 1c             	sub    $0x1c,%esp
  801851:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801854:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801857:	50                   	push   %eax
  801858:	53                   	push   %ebx
  801859:	e8 dc fb ff ff       	call   80143a <fd_lookup>
  80185e:	83 c4 10             	add    $0x10,%esp
  801861:	85 c0                	test   %eax,%eax
  801863:	78 37                	js     80189c <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801865:	83 ec 08             	sub    $0x8,%esp
  801868:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186b:	50                   	push   %eax
  80186c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186f:	ff 30                	pushl  (%eax)
  801871:	e8 18 fc ff ff       	call   80148e <dev_lookup>
  801876:	83 c4 10             	add    $0x10,%esp
  801879:	85 c0                	test   %eax,%eax
  80187b:	78 1f                	js     80189c <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80187d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801880:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801884:	74 1b                	je     8018a1 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801886:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801889:	8b 52 18             	mov    0x18(%edx),%edx
  80188c:	85 d2                	test   %edx,%edx
  80188e:	74 32                	je     8018c2 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801890:	83 ec 08             	sub    $0x8,%esp
  801893:	ff 75 0c             	pushl  0xc(%ebp)
  801896:	50                   	push   %eax
  801897:	ff d2                	call   *%edx
  801899:	83 c4 10             	add    $0x10,%esp
}
  80189c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189f:	c9                   	leave  
  8018a0:	c3                   	ret    
			thisenv->env_id, fdnum);
  8018a1:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018a6:	8b 40 48             	mov    0x48(%eax),%eax
  8018a9:	83 ec 04             	sub    $0x4,%esp
  8018ac:	53                   	push   %ebx
  8018ad:	50                   	push   %eax
  8018ae:	68 cc 2a 80 00       	push   $0x802acc
  8018b3:	e8 05 ea ff ff       	call   8002bd <cprintf>
		return -E_INVAL;
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018c0:	eb da                	jmp    80189c <ftruncate+0x56>
		return -E_NOT_SUPP;
  8018c2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018c7:	eb d3                	jmp    80189c <ftruncate+0x56>

008018c9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018c9:	f3 0f 1e fb          	endbr32 
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	53                   	push   %ebx
  8018d1:	83 ec 1c             	sub    $0x1c,%esp
  8018d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018da:	50                   	push   %eax
  8018db:	ff 75 08             	pushl  0x8(%ebp)
  8018de:	e8 57 fb ff ff       	call   80143a <fd_lookup>
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	78 4b                	js     801935 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ea:	83 ec 08             	sub    $0x8,%esp
  8018ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f0:	50                   	push   %eax
  8018f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f4:	ff 30                	pushl  (%eax)
  8018f6:	e8 93 fb ff ff       	call   80148e <dev_lookup>
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	85 c0                	test   %eax,%eax
  801900:	78 33                	js     801935 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801902:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801905:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801909:	74 2f                	je     80193a <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80190b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80190e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801915:	00 00 00 
	stat->st_isdir = 0;
  801918:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80191f:	00 00 00 
	stat->st_dev = dev;
  801922:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801928:	83 ec 08             	sub    $0x8,%esp
  80192b:	53                   	push   %ebx
  80192c:	ff 75 f0             	pushl  -0x10(%ebp)
  80192f:	ff 50 14             	call   *0x14(%eax)
  801932:	83 c4 10             	add    $0x10,%esp
}
  801935:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801938:	c9                   	leave  
  801939:	c3                   	ret    
		return -E_NOT_SUPP;
  80193a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80193f:	eb f4                	jmp    801935 <fstat+0x6c>

00801941 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801941:	f3 0f 1e fb          	endbr32 
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	56                   	push   %esi
  801949:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80194a:	83 ec 08             	sub    $0x8,%esp
  80194d:	6a 00                	push   $0x0
  80194f:	ff 75 08             	pushl  0x8(%ebp)
  801952:	e8 20 02 00 00       	call   801b77 <open>
  801957:	89 c3                	mov    %eax,%ebx
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	85 c0                	test   %eax,%eax
  80195e:	78 1b                	js     80197b <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801960:	83 ec 08             	sub    $0x8,%esp
  801963:	ff 75 0c             	pushl  0xc(%ebp)
  801966:	50                   	push   %eax
  801967:	e8 5d ff ff ff       	call   8018c9 <fstat>
  80196c:	89 c6                	mov    %eax,%esi
	close(fd);
  80196e:	89 1c 24             	mov    %ebx,(%esp)
  801971:	e8 fd fb ff ff       	call   801573 <close>
	return r;
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	89 f3                	mov    %esi,%ebx
}
  80197b:	89 d8                	mov    %ebx,%eax
  80197d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801980:	5b                   	pop    %ebx
  801981:	5e                   	pop    %esi
  801982:	5d                   	pop    %ebp
  801983:	c3                   	ret    

00801984 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	56                   	push   %esi
  801988:	53                   	push   %ebx
  801989:	89 c6                	mov    %eax,%esi
  80198b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80198d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801994:	74 27                	je     8019bd <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801996:	6a 07                	push   $0x7
  801998:	68 00 50 80 00       	push   $0x805000
  80199d:	56                   	push   %esi
  80199e:	ff 35 00 40 80 00    	pushl  0x804000
  8019a4:	e8 78 f9 ff ff       	call   801321 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019a9:	83 c4 0c             	add    $0xc,%esp
  8019ac:	6a 00                	push   $0x0
  8019ae:	53                   	push   %ebx
  8019af:	6a 00                	push   $0x0
  8019b1:	e8 fe f8 ff ff       	call   8012b4 <ipc_recv>
}
  8019b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b9:	5b                   	pop    %ebx
  8019ba:	5e                   	pop    %esi
  8019bb:	5d                   	pop    %ebp
  8019bc:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019bd:	83 ec 0c             	sub    $0xc,%esp
  8019c0:	6a 01                	push   $0x1
  8019c2:	e8 ad f9 ff ff       	call   801374 <ipc_find_env>
  8019c7:	a3 00 40 80 00       	mov    %eax,0x804000
  8019cc:	83 c4 10             	add    $0x10,%esp
  8019cf:	eb c5                	jmp    801996 <fsipc+0x12>

008019d1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019d1:	f3 0f 1e fb          	endbr32 
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019db:	8b 45 08             	mov    0x8(%ebp),%eax
  8019de:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f3:	b8 02 00 00 00       	mov    $0x2,%eax
  8019f8:	e8 87 ff ff ff       	call   801984 <fsipc>
}
  8019fd:	c9                   	leave  
  8019fe:	c3                   	ret    

008019ff <devfile_flush>:
{
  8019ff:	f3 0f 1e fb          	endbr32 
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a09:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a14:	ba 00 00 00 00       	mov    $0x0,%edx
  801a19:	b8 06 00 00 00       	mov    $0x6,%eax
  801a1e:	e8 61 ff ff ff       	call   801984 <fsipc>
}
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    

00801a25 <devfile_stat>:
{
  801a25:	f3 0f 1e fb          	endbr32 
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	53                   	push   %ebx
  801a2d:	83 ec 04             	sub    $0x4,%esp
  801a30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a33:	8b 45 08             	mov    0x8(%ebp),%eax
  801a36:	8b 40 0c             	mov    0xc(%eax),%eax
  801a39:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a43:	b8 05 00 00 00       	mov    $0x5,%eax
  801a48:	e8 37 ff ff ff       	call   801984 <fsipc>
  801a4d:	85 c0                	test   %eax,%eax
  801a4f:	78 2c                	js     801a7d <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a51:	83 ec 08             	sub    $0x8,%esp
  801a54:	68 00 50 80 00       	push   $0x805000
  801a59:	53                   	push   %ebx
  801a5a:	e8 c8 ed ff ff       	call   800827 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a5f:	a1 80 50 80 00       	mov    0x805080,%eax
  801a64:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a6a:	a1 84 50 80 00       	mov    0x805084,%eax
  801a6f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <devfile_write>:
{
  801a82:	f3 0f 1e fb          	endbr32 
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	57                   	push   %edi
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
  801a8c:	83 ec 0c             	sub    $0xc,%esp
  801a8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a95:	8b 45 08             	mov    0x8(%ebp),%eax
  801a98:	8b 40 0c             	mov    0xc(%eax),%eax
  801a9b:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  801aa0:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801aa5:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  801aaa:	85 db                	test   %ebx,%ebx
  801aac:	74 3b                	je     801ae9 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801aae:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801ab4:	89 f8                	mov    %edi,%eax
  801ab6:	0f 46 c3             	cmovbe %ebx,%eax
  801ab9:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  801abe:	83 ec 04             	sub    $0x4,%esp
  801ac1:	50                   	push   %eax
  801ac2:	56                   	push   %esi
  801ac3:	68 08 50 80 00       	push   $0x805008
  801ac8:	e8 12 ef ff ff       	call   8009df <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801acd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad2:	b8 04 00 00 00       	mov    $0x4,%eax
  801ad7:	e8 a8 fe ff ff       	call   801984 <fsipc>
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	78 06                	js     801ae9 <devfile_write+0x67>
		buf_aux += r;
  801ae3:	01 c6                	add    %eax,%esi
		n -= r;
  801ae5:	29 c3                	sub    %eax,%ebx
  801ae7:	eb c1                	jmp    801aaa <devfile_write+0x28>
}
  801ae9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aec:	5b                   	pop    %ebx
  801aed:	5e                   	pop    %esi
  801aee:	5f                   	pop    %edi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <devfile_read>:
{
  801af1:	f3 0f 1e fb          	endbr32 
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	56                   	push   %esi
  801af9:	53                   	push   %ebx
  801afa:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801afd:	8b 45 08             	mov    0x8(%ebp),%eax
  801b00:	8b 40 0c             	mov    0xc(%eax),%eax
  801b03:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b08:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b0e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b13:	b8 03 00 00 00       	mov    $0x3,%eax
  801b18:	e8 67 fe ff ff       	call   801984 <fsipc>
  801b1d:	89 c3                	mov    %eax,%ebx
  801b1f:	85 c0                	test   %eax,%eax
  801b21:	78 1f                	js     801b42 <devfile_read+0x51>
	assert(r <= n);
  801b23:	39 f0                	cmp    %esi,%eax
  801b25:	77 24                	ja     801b4b <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801b27:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b2c:	7f 33                	jg     801b61 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b2e:	83 ec 04             	sub    $0x4,%esp
  801b31:	50                   	push   %eax
  801b32:	68 00 50 80 00       	push   $0x805000
  801b37:	ff 75 0c             	pushl  0xc(%ebp)
  801b3a:	e8 a0 ee ff ff       	call   8009df <memmove>
	return r;
  801b3f:	83 c4 10             	add    $0x10,%esp
}
  801b42:	89 d8                	mov    %ebx,%eax
  801b44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b47:	5b                   	pop    %ebx
  801b48:	5e                   	pop    %esi
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    
	assert(r <= n);
  801b4b:	68 38 2b 80 00       	push   $0x802b38
  801b50:	68 3f 2b 80 00       	push   $0x802b3f
  801b55:	6a 7c                	push   $0x7c
  801b57:	68 54 2b 80 00       	push   $0x802b54
  801b5c:	e8 be 05 00 00       	call   80211f <_panic>
	assert(r <= PGSIZE);
  801b61:	68 5f 2b 80 00       	push   $0x802b5f
  801b66:	68 3f 2b 80 00       	push   $0x802b3f
  801b6b:	6a 7d                	push   $0x7d
  801b6d:	68 54 2b 80 00       	push   $0x802b54
  801b72:	e8 a8 05 00 00       	call   80211f <_panic>

00801b77 <open>:
{
  801b77:	f3 0f 1e fb          	endbr32 
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	56                   	push   %esi
  801b7f:	53                   	push   %ebx
  801b80:	83 ec 1c             	sub    $0x1c,%esp
  801b83:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801b86:	56                   	push   %esi
  801b87:	e8 58 ec ff ff       	call   8007e4 <strlen>
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b94:	7f 6c                	jg     801c02 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801b96:	83 ec 0c             	sub    $0xc,%esp
  801b99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9c:	50                   	push   %eax
  801b9d:	e8 42 f8 ff ff       	call   8013e4 <fd_alloc>
  801ba2:	89 c3                	mov    %eax,%ebx
  801ba4:	83 c4 10             	add    $0x10,%esp
  801ba7:	85 c0                	test   %eax,%eax
  801ba9:	78 3c                	js     801be7 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801bab:	83 ec 08             	sub    $0x8,%esp
  801bae:	56                   	push   %esi
  801baf:	68 00 50 80 00       	push   $0x805000
  801bb4:	e8 6e ec ff ff       	call   800827 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bbc:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc4:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc9:	e8 b6 fd ff ff       	call   801984 <fsipc>
  801bce:	89 c3                	mov    %eax,%ebx
  801bd0:	83 c4 10             	add    $0x10,%esp
  801bd3:	85 c0                	test   %eax,%eax
  801bd5:	78 19                	js     801bf0 <open+0x79>
	return fd2num(fd);
  801bd7:	83 ec 0c             	sub    $0xc,%esp
  801bda:	ff 75 f4             	pushl  -0xc(%ebp)
  801bdd:	e8 cf f7 ff ff       	call   8013b1 <fd2num>
  801be2:	89 c3                	mov    %eax,%ebx
  801be4:	83 c4 10             	add    $0x10,%esp
}
  801be7:	89 d8                	mov    %ebx,%eax
  801be9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bec:	5b                   	pop    %ebx
  801bed:	5e                   	pop    %esi
  801bee:	5d                   	pop    %ebp
  801bef:	c3                   	ret    
		fd_close(fd, 0);
  801bf0:	83 ec 08             	sub    $0x8,%esp
  801bf3:	6a 00                	push   $0x0
  801bf5:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf8:	e8 eb f8 ff ff       	call   8014e8 <fd_close>
		return r;
  801bfd:	83 c4 10             	add    $0x10,%esp
  801c00:	eb e5                	jmp    801be7 <open+0x70>
		return -E_BAD_PATH;
  801c02:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c07:	eb de                	jmp    801be7 <open+0x70>

00801c09 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c09:	f3 0f 1e fb          	endbr32 
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c13:	ba 00 00 00 00       	mov    $0x0,%edx
  801c18:	b8 08 00 00 00       	mov    $0x8,%eax
  801c1d:	e8 62 fd ff ff       	call   801984 <fsipc>
}
  801c22:	c9                   	leave  
  801c23:	c3                   	ret    

00801c24 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c24:	f3 0f 1e fb          	endbr32 
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	56                   	push   %esi
  801c2c:	53                   	push   %ebx
  801c2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c30:	83 ec 0c             	sub    $0xc,%esp
  801c33:	ff 75 08             	pushl  0x8(%ebp)
  801c36:	e8 8a f7 ff ff       	call   8013c5 <fd2data>
  801c3b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c3d:	83 c4 08             	add    $0x8,%esp
  801c40:	68 6b 2b 80 00       	push   $0x802b6b
  801c45:	53                   	push   %ebx
  801c46:	e8 dc eb ff ff       	call   800827 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c4b:	8b 46 04             	mov    0x4(%esi),%eax
  801c4e:	2b 06                	sub    (%esi),%eax
  801c50:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c56:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c5d:	00 00 00 
	stat->st_dev = &devpipe;
  801c60:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801c67:	30 80 00 
	return 0;
}
  801c6a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c72:	5b                   	pop    %ebx
  801c73:	5e                   	pop    %esi
  801c74:	5d                   	pop    %ebp
  801c75:	c3                   	ret    

00801c76 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c76:	f3 0f 1e fb          	endbr32 
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	53                   	push   %ebx
  801c7e:	83 ec 0c             	sub    $0xc,%esp
  801c81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c84:	53                   	push   %ebx
  801c85:	6a 00                	push   $0x0
  801c87:	e8 75 f0 ff ff       	call   800d01 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c8c:	89 1c 24             	mov    %ebx,(%esp)
  801c8f:	e8 31 f7 ff ff       	call   8013c5 <fd2data>
  801c94:	83 c4 08             	add    $0x8,%esp
  801c97:	50                   	push   %eax
  801c98:	6a 00                	push   $0x0
  801c9a:	e8 62 f0 ff ff       	call   800d01 <sys_page_unmap>
}
  801c9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca2:	c9                   	leave  
  801ca3:	c3                   	ret    

00801ca4 <_pipeisclosed>:
{
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	57                   	push   %edi
  801ca8:	56                   	push   %esi
  801ca9:	53                   	push   %ebx
  801caa:	83 ec 1c             	sub    $0x1c,%esp
  801cad:	89 c7                	mov    %eax,%edi
  801caf:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801cb1:	a1 04 40 80 00       	mov    0x804004,%eax
  801cb6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cb9:	83 ec 0c             	sub    $0xc,%esp
  801cbc:	57                   	push   %edi
  801cbd:	e8 40 05 00 00       	call   802202 <pageref>
  801cc2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801cc5:	89 34 24             	mov    %esi,(%esp)
  801cc8:	e8 35 05 00 00       	call   802202 <pageref>
		nn = thisenv->env_runs;
  801ccd:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cd3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cd6:	83 c4 10             	add    $0x10,%esp
  801cd9:	39 cb                	cmp    %ecx,%ebx
  801cdb:	74 1b                	je     801cf8 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801cdd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ce0:	75 cf                	jne    801cb1 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ce2:	8b 42 58             	mov    0x58(%edx),%eax
  801ce5:	6a 01                	push   $0x1
  801ce7:	50                   	push   %eax
  801ce8:	53                   	push   %ebx
  801ce9:	68 72 2b 80 00       	push   $0x802b72
  801cee:	e8 ca e5 ff ff       	call   8002bd <cprintf>
  801cf3:	83 c4 10             	add    $0x10,%esp
  801cf6:	eb b9                	jmp    801cb1 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801cf8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801cfb:	0f 94 c0             	sete   %al
  801cfe:	0f b6 c0             	movzbl %al,%eax
}
  801d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5e                   	pop    %esi
  801d06:	5f                   	pop    %edi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    

00801d09 <devpipe_write>:
{
  801d09:	f3 0f 1e fb          	endbr32 
  801d0d:	55                   	push   %ebp
  801d0e:	89 e5                	mov    %esp,%ebp
  801d10:	57                   	push   %edi
  801d11:	56                   	push   %esi
  801d12:	53                   	push   %ebx
  801d13:	83 ec 28             	sub    $0x28,%esp
  801d16:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d19:	56                   	push   %esi
  801d1a:	e8 a6 f6 ff ff       	call   8013c5 <fd2data>
  801d1f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d21:	83 c4 10             	add    $0x10,%esp
  801d24:	bf 00 00 00 00       	mov    $0x0,%edi
  801d29:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d2c:	74 4f                	je     801d7d <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d2e:	8b 43 04             	mov    0x4(%ebx),%eax
  801d31:	8b 0b                	mov    (%ebx),%ecx
  801d33:	8d 51 20             	lea    0x20(%ecx),%edx
  801d36:	39 d0                	cmp    %edx,%eax
  801d38:	72 14                	jb     801d4e <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801d3a:	89 da                	mov    %ebx,%edx
  801d3c:	89 f0                	mov    %esi,%eax
  801d3e:	e8 61 ff ff ff       	call   801ca4 <_pipeisclosed>
  801d43:	85 c0                	test   %eax,%eax
  801d45:	75 3b                	jne    801d82 <devpipe_write+0x79>
			sys_yield();
  801d47:	e8 38 ef ff ff       	call   800c84 <sys_yield>
  801d4c:	eb e0                	jmp    801d2e <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d51:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d55:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d58:	89 c2                	mov    %eax,%edx
  801d5a:	c1 fa 1f             	sar    $0x1f,%edx
  801d5d:	89 d1                	mov    %edx,%ecx
  801d5f:	c1 e9 1b             	shr    $0x1b,%ecx
  801d62:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d65:	83 e2 1f             	and    $0x1f,%edx
  801d68:	29 ca                	sub    %ecx,%edx
  801d6a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d6e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d72:	83 c0 01             	add    $0x1,%eax
  801d75:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d78:	83 c7 01             	add    $0x1,%edi
  801d7b:	eb ac                	jmp    801d29 <devpipe_write+0x20>
	return i;
  801d7d:	8b 45 10             	mov    0x10(%ebp),%eax
  801d80:	eb 05                	jmp    801d87 <devpipe_write+0x7e>
				return 0;
  801d82:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d8a:	5b                   	pop    %ebx
  801d8b:	5e                   	pop    %esi
  801d8c:	5f                   	pop    %edi
  801d8d:	5d                   	pop    %ebp
  801d8e:	c3                   	ret    

00801d8f <devpipe_read>:
{
  801d8f:	f3 0f 1e fb          	endbr32 
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	57                   	push   %edi
  801d97:	56                   	push   %esi
  801d98:	53                   	push   %ebx
  801d99:	83 ec 18             	sub    $0x18,%esp
  801d9c:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d9f:	57                   	push   %edi
  801da0:	e8 20 f6 ff ff       	call   8013c5 <fd2data>
  801da5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801da7:	83 c4 10             	add    $0x10,%esp
  801daa:	be 00 00 00 00       	mov    $0x0,%esi
  801daf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801db2:	75 14                	jne    801dc8 <devpipe_read+0x39>
	return i;
  801db4:	8b 45 10             	mov    0x10(%ebp),%eax
  801db7:	eb 02                	jmp    801dbb <devpipe_read+0x2c>
				return i;
  801db9:	89 f0                	mov    %esi,%eax
}
  801dbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dbe:	5b                   	pop    %ebx
  801dbf:	5e                   	pop    %esi
  801dc0:	5f                   	pop    %edi
  801dc1:	5d                   	pop    %ebp
  801dc2:	c3                   	ret    
			sys_yield();
  801dc3:	e8 bc ee ff ff       	call   800c84 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801dc8:	8b 03                	mov    (%ebx),%eax
  801dca:	3b 43 04             	cmp    0x4(%ebx),%eax
  801dcd:	75 18                	jne    801de7 <devpipe_read+0x58>
			if (i > 0)
  801dcf:	85 f6                	test   %esi,%esi
  801dd1:	75 e6                	jne    801db9 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801dd3:	89 da                	mov    %ebx,%edx
  801dd5:	89 f8                	mov    %edi,%eax
  801dd7:	e8 c8 fe ff ff       	call   801ca4 <_pipeisclosed>
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	74 e3                	je     801dc3 <devpipe_read+0x34>
				return 0;
  801de0:	b8 00 00 00 00       	mov    $0x0,%eax
  801de5:	eb d4                	jmp    801dbb <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801de7:	99                   	cltd   
  801de8:	c1 ea 1b             	shr    $0x1b,%edx
  801deb:	01 d0                	add    %edx,%eax
  801ded:	83 e0 1f             	and    $0x1f,%eax
  801df0:	29 d0                	sub    %edx,%eax
  801df2:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801df7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dfa:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801dfd:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e00:	83 c6 01             	add    $0x1,%esi
  801e03:	eb aa                	jmp    801daf <devpipe_read+0x20>

00801e05 <pipe>:
{
  801e05:	f3 0f 1e fb          	endbr32 
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	56                   	push   %esi
  801e0d:	53                   	push   %ebx
  801e0e:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e14:	50                   	push   %eax
  801e15:	e8 ca f5 ff ff       	call   8013e4 <fd_alloc>
  801e1a:	89 c3                	mov    %eax,%ebx
  801e1c:	83 c4 10             	add    $0x10,%esp
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	0f 88 23 01 00 00    	js     801f4a <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e27:	83 ec 04             	sub    $0x4,%esp
  801e2a:	68 07 04 00 00       	push   $0x407
  801e2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e32:	6a 00                	push   $0x0
  801e34:	e8 76 ee ff ff       	call   800caf <sys_page_alloc>
  801e39:	89 c3                	mov    %eax,%ebx
  801e3b:	83 c4 10             	add    $0x10,%esp
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	0f 88 04 01 00 00    	js     801f4a <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801e46:	83 ec 0c             	sub    $0xc,%esp
  801e49:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e4c:	50                   	push   %eax
  801e4d:	e8 92 f5 ff ff       	call   8013e4 <fd_alloc>
  801e52:	89 c3                	mov    %eax,%ebx
  801e54:	83 c4 10             	add    $0x10,%esp
  801e57:	85 c0                	test   %eax,%eax
  801e59:	0f 88 db 00 00 00    	js     801f3a <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5f:	83 ec 04             	sub    $0x4,%esp
  801e62:	68 07 04 00 00       	push   $0x407
  801e67:	ff 75 f0             	pushl  -0x10(%ebp)
  801e6a:	6a 00                	push   $0x0
  801e6c:	e8 3e ee ff ff       	call   800caf <sys_page_alloc>
  801e71:	89 c3                	mov    %eax,%ebx
  801e73:	83 c4 10             	add    $0x10,%esp
  801e76:	85 c0                	test   %eax,%eax
  801e78:	0f 88 bc 00 00 00    	js     801f3a <pipe+0x135>
	va = fd2data(fd0);
  801e7e:	83 ec 0c             	sub    $0xc,%esp
  801e81:	ff 75 f4             	pushl  -0xc(%ebp)
  801e84:	e8 3c f5 ff ff       	call   8013c5 <fd2data>
  801e89:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e8b:	83 c4 0c             	add    $0xc,%esp
  801e8e:	68 07 04 00 00       	push   $0x407
  801e93:	50                   	push   %eax
  801e94:	6a 00                	push   $0x0
  801e96:	e8 14 ee ff ff       	call   800caf <sys_page_alloc>
  801e9b:	89 c3                	mov    %eax,%ebx
  801e9d:	83 c4 10             	add    $0x10,%esp
  801ea0:	85 c0                	test   %eax,%eax
  801ea2:	0f 88 82 00 00 00    	js     801f2a <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea8:	83 ec 0c             	sub    $0xc,%esp
  801eab:	ff 75 f0             	pushl  -0x10(%ebp)
  801eae:	e8 12 f5 ff ff       	call   8013c5 <fd2data>
  801eb3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801eba:	50                   	push   %eax
  801ebb:	6a 00                	push   $0x0
  801ebd:	56                   	push   %esi
  801ebe:	6a 00                	push   $0x0
  801ec0:	e8 12 ee ff ff       	call   800cd7 <sys_page_map>
  801ec5:	89 c3                	mov    %eax,%ebx
  801ec7:	83 c4 20             	add    $0x20,%esp
  801eca:	85 c0                	test   %eax,%eax
  801ecc:	78 4e                	js     801f1c <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801ece:	a1 28 30 80 00       	mov    0x803028,%eax
  801ed3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ed6:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801ed8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801edb:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801ee2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ee5:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801ee7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eea:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801ef1:	83 ec 0c             	sub    $0xc,%esp
  801ef4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef7:	e8 b5 f4 ff ff       	call   8013b1 <fd2num>
  801efc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eff:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f01:	83 c4 04             	add    $0x4,%esp
  801f04:	ff 75 f0             	pushl  -0x10(%ebp)
  801f07:	e8 a5 f4 ff ff       	call   8013b1 <fd2num>
  801f0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f0f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f12:	83 c4 10             	add    $0x10,%esp
  801f15:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f1a:	eb 2e                	jmp    801f4a <pipe+0x145>
	sys_page_unmap(0, va);
  801f1c:	83 ec 08             	sub    $0x8,%esp
  801f1f:	56                   	push   %esi
  801f20:	6a 00                	push   $0x0
  801f22:	e8 da ed ff ff       	call   800d01 <sys_page_unmap>
  801f27:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f2a:	83 ec 08             	sub    $0x8,%esp
  801f2d:	ff 75 f0             	pushl  -0x10(%ebp)
  801f30:	6a 00                	push   $0x0
  801f32:	e8 ca ed ff ff       	call   800d01 <sys_page_unmap>
  801f37:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801f3a:	83 ec 08             	sub    $0x8,%esp
  801f3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801f40:	6a 00                	push   $0x0
  801f42:	e8 ba ed ff ff       	call   800d01 <sys_page_unmap>
  801f47:	83 c4 10             	add    $0x10,%esp
}
  801f4a:	89 d8                	mov    %ebx,%eax
  801f4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f4f:	5b                   	pop    %ebx
  801f50:	5e                   	pop    %esi
  801f51:	5d                   	pop    %ebp
  801f52:	c3                   	ret    

00801f53 <pipeisclosed>:
{
  801f53:	f3 0f 1e fb          	endbr32 
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f60:	50                   	push   %eax
  801f61:	ff 75 08             	pushl  0x8(%ebp)
  801f64:	e8 d1 f4 ff ff       	call   80143a <fd_lookup>
  801f69:	83 c4 10             	add    $0x10,%esp
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	78 18                	js     801f88 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801f70:	83 ec 0c             	sub    $0xc,%esp
  801f73:	ff 75 f4             	pushl  -0xc(%ebp)
  801f76:	e8 4a f4 ff ff       	call   8013c5 <fd2data>
  801f7b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f80:	e8 1f fd ff ff       	call   801ca4 <_pipeisclosed>
  801f85:	83 c4 10             	add    $0x10,%esp
}
  801f88:	c9                   	leave  
  801f89:	c3                   	ret    

00801f8a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f8a:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801f8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f93:	c3                   	ret    

00801f94 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f94:	f3 0f 1e fb          	endbr32 
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f9e:	68 8a 2b 80 00       	push   $0x802b8a
  801fa3:	ff 75 0c             	pushl  0xc(%ebp)
  801fa6:	e8 7c e8 ff ff       	call   800827 <strcpy>
	return 0;
}
  801fab:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb0:	c9                   	leave  
  801fb1:	c3                   	ret    

00801fb2 <devcons_write>:
{
  801fb2:	f3 0f 1e fb          	endbr32 
  801fb6:	55                   	push   %ebp
  801fb7:	89 e5                	mov    %esp,%ebp
  801fb9:	57                   	push   %edi
  801fba:	56                   	push   %esi
  801fbb:	53                   	push   %ebx
  801fbc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801fc2:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fc7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801fcd:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fd0:	73 31                	jae    802003 <devcons_write+0x51>
		m = n - tot;
  801fd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fd5:	29 f3                	sub    %esi,%ebx
  801fd7:	83 fb 7f             	cmp    $0x7f,%ebx
  801fda:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801fdf:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801fe2:	83 ec 04             	sub    $0x4,%esp
  801fe5:	53                   	push   %ebx
  801fe6:	89 f0                	mov    %esi,%eax
  801fe8:	03 45 0c             	add    0xc(%ebp),%eax
  801feb:	50                   	push   %eax
  801fec:	57                   	push   %edi
  801fed:	e8 ed e9 ff ff       	call   8009df <memmove>
		sys_cputs(buf, m);
  801ff2:	83 c4 08             	add    $0x8,%esp
  801ff5:	53                   	push   %ebx
  801ff6:	57                   	push   %edi
  801ff7:	e8 e8 eb ff ff       	call   800be4 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801ffc:	01 de                	add    %ebx,%esi
  801ffe:	83 c4 10             	add    $0x10,%esp
  802001:	eb ca                	jmp    801fcd <devcons_write+0x1b>
}
  802003:	89 f0                	mov    %esi,%eax
  802005:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802008:	5b                   	pop    %ebx
  802009:	5e                   	pop    %esi
  80200a:	5f                   	pop    %edi
  80200b:	5d                   	pop    %ebp
  80200c:	c3                   	ret    

0080200d <devcons_read>:
{
  80200d:	f3 0f 1e fb          	endbr32 
  802011:	55                   	push   %ebp
  802012:	89 e5                	mov    %esp,%ebp
  802014:	83 ec 08             	sub    $0x8,%esp
  802017:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80201c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802020:	74 21                	je     802043 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  802022:	e8 e7 eb ff ff       	call   800c0e <sys_cgetc>
  802027:	85 c0                	test   %eax,%eax
  802029:	75 07                	jne    802032 <devcons_read+0x25>
		sys_yield();
  80202b:	e8 54 ec ff ff       	call   800c84 <sys_yield>
  802030:	eb f0                	jmp    802022 <devcons_read+0x15>
	if (c < 0)
  802032:	78 0f                	js     802043 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802034:	83 f8 04             	cmp    $0x4,%eax
  802037:	74 0c                	je     802045 <devcons_read+0x38>
	*(char*)vbuf = c;
  802039:	8b 55 0c             	mov    0xc(%ebp),%edx
  80203c:	88 02                	mov    %al,(%edx)
	return 1;
  80203e:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802043:	c9                   	leave  
  802044:	c3                   	ret    
		return 0;
  802045:	b8 00 00 00 00       	mov    $0x0,%eax
  80204a:	eb f7                	jmp    802043 <devcons_read+0x36>

0080204c <cputchar>:
{
  80204c:	f3 0f 1e fb          	endbr32 
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802056:	8b 45 08             	mov    0x8(%ebp),%eax
  802059:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80205c:	6a 01                	push   $0x1
  80205e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802061:	50                   	push   %eax
  802062:	e8 7d eb ff ff       	call   800be4 <sys_cputs>
}
  802067:	83 c4 10             	add    $0x10,%esp
  80206a:	c9                   	leave  
  80206b:	c3                   	ret    

0080206c <getchar>:
{
  80206c:	f3 0f 1e fb          	endbr32 
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802076:	6a 01                	push   $0x1
  802078:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80207b:	50                   	push   %eax
  80207c:	6a 00                	push   $0x0
  80207e:	e8 3a f6 ff ff       	call   8016bd <read>
	if (r < 0)
  802083:	83 c4 10             	add    $0x10,%esp
  802086:	85 c0                	test   %eax,%eax
  802088:	78 06                	js     802090 <getchar+0x24>
	if (r < 1)
  80208a:	74 06                	je     802092 <getchar+0x26>
	return c;
  80208c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802090:	c9                   	leave  
  802091:	c3                   	ret    
		return -E_EOF;
  802092:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802097:	eb f7                	jmp    802090 <getchar+0x24>

00802099 <iscons>:
{
  802099:	f3 0f 1e fb          	endbr32 
  80209d:	55                   	push   %ebp
  80209e:	89 e5                	mov    %esp,%ebp
  8020a0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020a6:	50                   	push   %eax
  8020a7:	ff 75 08             	pushl  0x8(%ebp)
  8020aa:	e8 8b f3 ff ff       	call   80143a <fd_lookup>
  8020af:	83 c4 10             	add    $0x10,%esp
  8020b2:	85 c0                	test   %eax,%eax
  8020b4:	78 11                	js     8020c7 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8020b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b9:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8020bf:	39 10                	cmp    %edx,(%eax)
  8020c1:	0f 94 c0             	sete   %al
  8020c4:	0f b6 c0             	movzbl %al,%eax
}
  8020c7:	c9                   	leave  
  8020c8:	c3                   	ret    

008020c9 <opencons>:
{
  8020c9:	f3 0f 1e fb          	endbr32 
  8020cd:	55                   	push   %ebp
  8020ce:	89 e5                	mov    %esp,%ebp
  8020d0:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8020d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d6:	50                   	push   %eax
  8020d7:	e8 08 f3 ff ff       	call   8013e4 <fd_alloc>
  8020dc:	83 c4 10             	add    $0x10,%esp
  8020df:	85 c0                	test   %eax,%eax
  8020e1:	78 3a                	js     80211d <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020e3:	83 ec 04             	sub    $0x4,%esp
  8020e6:	68 07 04 00 00       	push   $0x407
  8020eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ee:	6a 00                	push   $0x0
  8020f0:	e8 ba eb ff ff       	call   800caf <sys_page_alloc>
  8020f5:	83 c4 10             	add    $0x10,%esp
  8020f8:	85 c0                	test   %eax,%eax
  8020fa:	78 21                	js     80211d <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8020fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ff:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802105:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802107:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802111:	83 ec 0c             	sub    $0xc,%esp
  802114:	50                   	push   %eax
  802115:	e8 97 f2 ff ff       	call   8013b1 <fd2num>
  80211a:	83 c4 10             	add    $0x10,%esp
}
  80211d:	c9                   	leave  
  80211e:	c3                   	ret    

0080211f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80211f:	f3 0f 1e fb          	endbr32 
  802123:	55                   	push   %ebp
  802124:	89 e5                	mov    %esp,%ebp
  802126:	56                   	push   %esi
  802127:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802128:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80212b:	8b 35 08 30 80 00    	mov    0x803008,%esi
  802131:	e8 26 eb ff ff       	call   800c5c <sys_getenvid>
  802136:	83 ec 0c             	sub    $0xc,%esp
  802139:	ff 75 0c             	pushl  0xc(%ebp)
  80213c:	ff 75 08             	pushl  0x8(%ebp)
  80213f:	56                   	push   %esi
  802140:	50                   	push   %eax
  802141:	68 98 2b 80 00       	push   $0x802b98
  802146:	e8 72 e1 ff ff       	call   8002bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80214b:	83 c4 18             	add    $0x18,%esp
  80214e:	53                   	push   %ebx
  80214f:	ff 75 10             	pushl  0x10(%ebp)
  802152:	e8 11 e1 ff ff       	call   800268 <vcprintf>
	cprintf("\n");
  802157:	c7 04 24 83 2b 80 00 	movl   $0x802b83,(%esp)
  80215e:	e8 5a e1 ff ff       	call   8002bd <cprintf>
  802163:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802166:	cc                   	int3   
  802167:	eb fd                	jmp    802166 <_panic+0x47>

00802169 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802169:	f3 0f 1e fb          	endbr32 
  80216d:	55                   	push   %ebp
  80216e:	89 e5                	mov    %esp,%ebp
  802170:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  802173:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80217a:	74 0a                	je     802186 <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80217c:	8b 45 08             	mov    0x8(%ebp),%eax
  80217f:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802184:	c9                   	leave  
  802185:	c3                   	ret    
		if (sys_page_alloc(0,
  802186:	83 ec 04             	sub    $0x4,%esp
  802189:	6a 07                	push   $0x7
  80218b:	68 00 f0 bf ee       	push   $0xeebff000
  802190:	6a 00                	push   $0x0
  802192:	e8 18 eb ff ff       	call   800caf <sys_page_alloc>
  802197:	83 c4 10             	add    $0x10,%esp
  80219a:	85 c0                	test   %eax,%eax
  80219c:	78 2a                	js     8021c8 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  80219e:	83 ec 08             	sub    $0x8,%esp
  8021a1:	68 dc 21 80 00       	push   $0x8021dc
  8021a6:	6a 00                	push   $0x0
  8021a8:	e8 c9 eb ff ff       	call   800d76 <sys_env_set_pgfault_upcall>
  8021ad:	83 c4 10             	add    $0x10,%esp
  8021b0:	85 c0                	test   %eax,%eax
  8021b2:	79 c8                	jns    80217c <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  8021b4:	83 ec 04             	sub    $0x4,%esp
  8021b7:	68 f0 2b 80 00       	push   $0x802bf0
  8021bc:	6a 25                	push   $0x25
  8021be:	68 37 2c 80 00       	push   $0x802c37
  8021c3:	e8 57 ff ff ff       	call   80211f <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  8021c8:	83 ec 04             	sub    $0x4,%esp
  8021cb:	68 bc 2b 80 00       	push   $0x802bbc
  8021d0:	6a 21                	push   $0x21
  8021d2:	68 37 2c 80 00       	push   $0x802c37
  8021d7:	e8 43 ff ff ff       	call   80211f <_panic>

008021dc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021dc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021dd:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021e2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021e4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  8021e7:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  8021ec:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  8021f0:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8021f4:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8021f6:	83 c4 08             	add    $0x8,%esp
	popal
  8021f9:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  8021fa:	83 c4 04             	add    $0x4,%esp
	popfl
  8021fd:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  8021fe:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802201:	c3                   	ret    

00802202 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802202:	f3 0f 1e fb          	endbr32 
  802206:	55                   	push   %ebp
  802207:	89 e5                	mov    %esp,%ebp
  802209:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80220c:	89 c2                	mov    %eax,%edx
  80220e:	c1 ea 16             	shr    $0x16,%edx
  802211:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802218:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80221d:	f6 c1 01             	test   $0x1,%cl
  802220:	74 1c                	je     80223e <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802222:	c1 e8 0c             	shr    $0xc,%eax
  802225:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80222c:	a8 01                	test   $0x1,%al
  80222e:	74 0e                	je     80223e <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802230:	c1 e8 0c             	shr    $0xc,%eax
  802233:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80223a:	ef 
  80223b:	0f b7 d2             	movzwl %dx,%edx
}
  80223e:	89 d0                	mov    %edx,%eax
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	66 90                	xchg   %ax,%ax
  802244:	66 90                	xchg   %ax,%ax
  802246:	66 90                	xchg   %ax,%ax
  802248:	66 90                	xchg   %ax,%ax
  80224a:	66 90                	xchg   %ax,%ax
  80224c:	66 90                	xchg   %ax,%ax
  80224e:	66 90                	xchg   %ax,%ax

00802250 <__udivdi3>:
  802250:	f3 0f 1e fb          	endbr32 
  802254:	55                   	push   %ebp
  802255:	57                   	push   %edi
  802256:	56                   	push   %esi
  802257:	53                   	push   %ebx
  802258:	83 ec 1c             	sub    $0x1c,%esp
  80225b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80225f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802263:	8b 74 24 34          	mov    0x34(%esp),%esi
  802267:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80226b:	85 d2                	test   %edx,%edx
  80226d:	75 19                	jne    802288 <__udivdi3+0x38>
  80226f:	39 f3                	cmp    %esi,%ebx
  802271:	76 4d                	jbe    8022c0 <__udivdi3+0x70>
  802273:	31 ff                	xor    %edi,%edi
  802275:	89 e8                	mov    %ebp,%eax
  802277:	89 f2                	mov    %esi,%edx
  802279:	f7 f3                	div    %ebx
  80227b:	89 fa                	mov    %edi,%edx
  80227d:	83 c4 1c             	add    $0x1c,%esp
  802280:	5b                   	pop    %ebx
  802281:	5e                   	pop    %esi
  802282:	5f                   	pop    %edi
  802283:	5d                   	pop    %ebp
  802284:	c3                   	ret    
  802285:	8d 76 00             	lea    0x0(%esi),%esi
  802288:	39 f2                	cmp    %esi,%edx
  80228a:	76 14                	jbe    8022a0 <__udivdi3+0x50>
  80228c:	31 ff                	xor    %edi,%edi
  80228e:	31 c0                	xor    %eax,%eax
  802290:	89 fa                	mov    %edi,%edx
  802292:	83 c4 1c             	add    $0x1c,%esp
  802295:	5b                   	pop    %ebx
  802296:	5e                   	pop    %esi
  802297:	5f                   	pop    %edi
  802298:	5d                   	pop    %ebp
  802299:	c3                   	ret    
  80229a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a0:	0f bd fa             	bsr    %edx,%edi
  8022a3:	83 f7 1f             	xor    $0x1f,%edi
  8022a6:	75 48                	jne    8022f0 <__udivdi3+0xa0>
  8022a8:	39 f2                	cmp    %esi,%edx
  8022aa:	72 06                	jb     8022b2 <__udivdi3+0x62>
  8022ac:	31 c0                	xor    %eax,%eax
  8022ae:	39 eb                	cmp    %ebp,%ebx
  8022b0:	77 de                	ja     802290 <__udivdi3+0x40>
  8022b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b7:	eb d7                	jmp    802290 <__udivdi3+0x40>
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	89 d9                	mov    %ebx,%ecx
  8022c2:	85 db                	test   %ebx,%ebx
  8022c4:	75 0b                	jne    8022d1 <__udivdi3+0x81>
  8022c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	f7 f3                	div    %ebx
  8022cf:	89 c1                	mov    %eax,%ecx
  8022d1:	31 d2                	xor    %edx,%edx
  8022d3:	89 f0                	mov    %esi,%eax
  8022d5:	f7 f1                	div    %ecx
  8022d7:	89 c6                	mov    %eax,%esi
  8022d9:	89 e8                	mov    %ebp,%eax
  8022db:	89 f7                	mov    %esi,%edi
  8022dd:	f7 f1                	div    %ecx
  8022df:	89 fa                	mov    %edi,%edx
  8022e1:	83 c4 1c             	add    $0x1c,%esp
  8022e4:	5b                   	pop    %ebx
  8022e5:	5e                   	pop    %esi
  8022e6:	5f                   	pop    %edi
  8022e7:	5d                   	pop    %ebp
  8022e8:	c3                   	ret    
  8022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	89 f9                	mov    %edi,%ecx
  8022f2:	b8 20 00 00 00       	mov    $0x20,%eax
  8022f7:	29 f8                	sub    %edi,%eax
  8022f9:	d3 e2                	shl    %cl,%edx
  8022fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022ff:	89 c1                	mov    %eax,%ecx
  802301:	89 da                	mov    %ebx,%edx
  802303:	d3 ea                	shr    %cl,%edx
  802305:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802309:	09 d1                	or     %edx,%ecx
  80230b:	89 f2                	mov    %esi,%edx
  80230d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802311:	89 f9                	mov    %edi,%ecx
  802313:	d3 e3                	shl    %cl,%ebx
  802315:	89 c1                	mov    %eax,%ecx
  802317:	d3 ea                	shr    %cl,%edx
  802319:	89 f9                	mov    %edi,%ecx
  80231b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80231f:	89 eb                	mov    %ebp,%ebx
  802321:	d3 e6                	shl    %cl,%esi
  802323:	89 c1                	mov    %eax,%ecx
  802325:	d3 eb                	shr    %cl,%ebx
  802327:	09 de                	or     %ebx,%esi
  802329:	89 f0                	mov    %esi,%eax
  80232b:	f7 74 24 08          	divl   0x8(%esp)
  80232f:	89 d6                	mov    %edx,%esi
  802331:	89 c3                	mov    %eax,%ebx
  802333:	f7 64 24 0c          	mull   0xc(%esp)
  802337:	39 d6                	cmp    %edx,%esi
  802339:	72 15                	jb     802350 <__udivdi3+0x100>
  80233b:	89 f9                	mov    %edi,%ecx
  80233d:	d3 e5                	shl    %cl,%ebp
  80233f:	39 c5                	cmp    %eax,%ebp
  802341:	73 04                	jae    802347 <__udivdi3+0xf7>
  802343:	39 d6                	cmp    %edx,%esi
  802345:	74 09                	je     802350 <__udivdi3+0x100>
  802347:	89 d8                	mov    %ebx,%eax
  802349:	31 ff                	xor    %edi,%edi
  80234b:	e9 40 ff ff ff       	jmp    802290 <__udivdi3+0x40>
  802350:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802353:	31 ff                	xor    %edi,%edi
  802355:	e9 36 ff ff ff       	jmp    802290 <__udivdi3+0x40>
  80235a:	66 90                	xchg   %ax,%ax
  80235c:	66 90                	xchg   %ax,%ax
  80235e:	66 90                	xchg   %ax,%ax

00802360 <__umoddi3>:
  802360:	f3 0f 1e fb          	endbr32 
  802364:	55                   	push   %ebp
  802365:	57                   	push   %edi
  802366:	56                   	push   %esi
  802367:	53                   	push   %ebx
  802368:	83 ec 1c             	sub    $0x1c,%esp
  80236b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80236f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802373:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802377:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80237b:	85 c0                	test   %eax,%eax
  80237d:	75 19                	jne    802398 <__umoddi3+0x38>
  80237f:	39 df                	cmp    %ebx,%edi
  802381:	76 5d                	jbe    8023e0 <__umoddi3+0x80>
  802383:	89 f0                	mov    %esi,%eax
  802385:	89 da                	mov    %ebx,%edx
  802387:	f7 f7                	div    %edi
  802389:	89 d0                	mov    %edx,%eax
  80238b:	31 d2                	xor    %edx,%edx
  80238d:	83 c4 1c             	add    $0x1c,%esp
  802390:	5b                   	pop    %ebx
  802391:	5e                   	pop    %esi
  802392:	5f                   	pop    %edi
  802393:	5d                   	pop    %ebp
  802394:	c3                   	ret    
  802395:	8d 76 00             	lea    0x0(%esi),%esi
  802398:	89 f2                	mov    %esi,%edx
  80239a:	39 d8                	cmp    %ebx,%eax
  80239c:	76 12                	jbe    8023b0 <__umoddi3+0x50>
  80239e:	89 f0                	mov    %esi,%eax
  8023a0:	89 da                	mov    %ebx,%edx
  8023a2:	83 c4 1c             	add    $0x1c,%esp
  8023a5:	5b                   	pop    %ebx
  8023a6:	5e                   	pop    %esi
  8023a7:	5f                   	pop    %edi
  8023a8:	5d                   	pop    %ebp
  8023a9:	c3                   	ret    
  8023aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023b0:	0f bd e8             	bsr    %eax,%ebp
  8023b3:	83 f5 1f             	xor    $0x1f,%ebp
  8023b6:	75 50                	jne    802408 <__umoddi3+0xa8>
  8023b8:	39 d8                	cmp    %ebx,%eax
  8023ba:	0f 82 e0 00 00 00    	jb     8024a0 <__umoddi3+0x140>
  8023c0:	89 d9                	mov    %ebx,%ecx
  8023c2:	39 f7                	cmp    %esi,%edi
  8023c4:	0f 86 d6 00 00 00    	jbe    8024a0 <__umoddi3+0x140>
  8023ca:	89 d0                	mov    %edx,%eax
  8023cc:	89 ca                	mov    %ecx,%edx
  8023ce:	83 c4 1c             	add    $0x1c,%esp
  8023d1:	5b                   	pop    %ebx
  8023d2:	5e                   	pop    %esi
  8023d3:	5f                   	pop    %edi
  8023d4:	5d                   	pop    %ebp
  8023d5:	c3                   	ret    
  8023d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023dd:	8d 76 00             	lea    0x0(%esi),%esi
  8023e0:	89 fd                	mov    %edi,%ebp
  8023e2:	85 ff                	test   %edi,%edi
  8023e4:	75 0b                	jne    8023f1 <__umoddi3+0x91>
  8023e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023eb:	31 d2                	xor    %edx,%edx
  8023ed:	f7 f7                	div    %edi
  8023ef:	89 c5                	mov    %eax,%ebp
  8023f1:	89 d8                	mov    %ebx,%eax
  8023f3:	31 d2                	xor    %edx,%edx
  8023f5:	f7 f5                	div    %ebp
  8023f7:	89 f0                	mov    %esi,%eax
  8023f9:	f7 f5                	div    %ebp
  8023fb:	89 d0                	mov    %edx,%eax
  8023fd:	31 d2                	xor    %edx,%edx
  8023ff:	eb 8c                	jmp    80238d <__umoddi3+0x2d>
  802401:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802408:	89 e9                	mov    %ebp,%ecx
  80240a:	ba 20 00 00 00       	mov    $0x20,%edx
  80240f:	29 ea                	sub    %ebp,%edx
  802411:	d3 e0                	shl    %cl,%eax
  802413:	89 44 24 08          	mov    %eax,0x8(%esp)
  802417:	89 d1                	mov    %edx,%ecx
  802419:	89 f8                	mov    %edi,%eax
  80241b:	d3 e8                	shr    %cl,%eax
  80241d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802421:	89 54 24 04          	mov    %edx,0x4(%esp)
  802425:	8b 54 24 04          	mov    0x4(%esp),%edx
  802429:	09 c1                	or     %eax,%ecx
  80242b:	89 d8                	mov    %ebx,%eax
  80242d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802431:	89 e9                	mov    %ebp,%ecx
  802433:	d3 e7                	shl    %cl,%edi
  802435:	89 d1                	mov    %edx,%ecx
  802437:	d3 e8                	shr    %cl,%eax
  802439:	89 e9                	mov    %ebp,%ecx
  80243b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80243f:	d3 e3                	shl    %cl,%ebx
  802441:	89 c7                	mov    %eax,%edi
  802443:	89 d1                	mov    %edx,%ecx
  802445:	89 f0                	mov    %esi,%eax
  802447:	d3 e8                	shr    %cl,%eax
  802449:	89 e9                	mov    %ebp,%ecx
  80244b:	89 fa                	mov    %edi,%edx
  80244d:	d3 e6                	shl    %cl,%esi
  80244f:	09 d8                	or     %ebx,%eax
  802451:	f7 74 24 08          	divl   0x8(%esp)
  802455:	89 d1                	mov    %edx,%ecx
  802457:	89 f3                	mov    %esi,%ebx
  802459:	f7 64 24 0c          	mull   0xc(%esp)
  80245d:	89 c6                	mov    %eax,%esi
  80245f:	89 d7                	mov    %edx,%edi
  802461:	39 d1                	cmp    %edx,%ecx
  802463:	72 06                	jb     80246b <__umoddi3+0x10b>
  802465:	75 10                	jne    802477 <__umoddi3+0x117>
  802467:	39 c3                	cmp    %eax,%ebx
  802469:	73 0c                	jae    802477 <__umoddi3+0x117>
  80246b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80246f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802473:	89 d7                	mov    %edx,%edi
  802475:	89 c6                	mov    %eax,%esi
  802477:	89 ca                	mov    %ecx,%edx
  802479:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80247e:	29 f3                	sub    %esi,%ebx
  802480:	19 fa                	sbb    %edi,%edx
  802482:	89 d0                	mov    %edx,%eax
  802484:	d3 e0                	shl    %cl,%eax
  802486:	89 e9                	mov    %ebp,%ecx
  802488:	d3 eb                	shr    %cl,%ebx
  80248a:	d3 ea                	shr    %cl,%edx
  80248c:	09 d8                	or     %ebx,%eax
  80248e:	83 c4 1c             	add    $0x1c,%esp
  802491:	5b                   	pop    %ebx
  802492:	5e                   	pop    %esi
  802493:	5f                   	pop    %edi
  802494:	5d                   	pop    %ebp
  802495:	c3                   	ret    
  802496:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80249d:	8d 76 00             	lea    0x0(%esi),%esi
  8024a0:	29 fe                	sub    %edi,%esi
  8024a2:	19 c3                	sbb    %eax,%ebx
  8024a4:	89 f2                	mov    %esi,%edx
  8024a6:	89 d9                	mov    %ebx,%ecx
  8024a8:	e9 1d ff ff ff       	jmp    8023ca <__umoddi3+0x6a>
