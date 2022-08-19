
obj/user/testshell.debug:     file format elf32-i386


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
  80002c:	e8 83 04 00 00       	call   8004b4 <libmain>
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

00800035 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800035:	f3 0f 1e fb          	endbr32 
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	57                   	push   %edi
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	81 ec 84 00 00 00    	sub    $0x84,%esp
  800045:	8b 75 08             	mov    0x8(%ebp),%esi
  800048:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80004b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  80004e:	53                   	push   %ebx
  80004f:	56                   	push   %esi
  800050:	e8 11 1a 00 00       	call   801a66 <seek>
	seek(kfd, off);
  800055:	83 c4 08             	add    $0x8,%esp
  800058:	53                   	push   %ebx
  800059:	57                   	push   %edi
  80005a:	e8 07 1a 00 00       	call   801a66 <seek>

	cprintf("shell produced incorrect output.\n");
  80005f:	c7 04 24 80 2c 80 00 	movl   $0x802c80,(%esp)
  800066:	e8 9c 05 00 00       	call   800607 <cprintf>
	cprintf("expected:\n===\n");
  80006b:	c7 04 24 eb 2c 80 00 	movl   $0x802ceb,(%esp)
  800072:	e8 90 05 00 00       	call   800607 <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  80007d:	83 ec 04             	sub    $0x4,%esp
  800080:	6a 63                	push   $0x63
  800082:	53                   	push   %ebx
  800083:	57                   	push   %edi
  800084:	e8 81 18 00 00       	call   80190a <read>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	85 c0                	test   %eax,%eax
  80008e:	7e 0f                	jle    80009f <wrong+0x6a>
		sys_cputs(buf, n);
  800090:	83 ec 08             	sub    $0x8,%esp
  800093:	50                   	push   %eax
  800094:	53                   	push   %ebx
  800095:	e8 94 0e 00 00       	call   800f2e <sys_cputs>
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	eb de                	jmp    80007d <wrong+0x48>
	cprintf("===\ngot:\n===\n");
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	68 fa 2c 80 00       	push   $0x802cfa
  8000a7:	e8 5b 05 00 00       	call   800607 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000b2:	eb 0d                	jmp    8000c1 <wrong+0x8c>
		sys_cputs(buf, n);
  8000b4:	83 ec 08             	sub    $0x8,%esp
  8000b7:	50                   	push   %eax
  8000b8:	53                   	push   %ebx
  8000b9:	e8 70 0e 00 00       	call   800f2e <sys_cputs>
  8000be:	83 c4 10             	add    $0x10,%esp
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000c1:	83 ec 04             	sub    $0x4,%esp
  8000c4:	6a 63                	push   $0x63
  8000c6:	53                   	push   %ebx
  8000c7:	56                   	push   %esi
  8000c8:	e8 3d 18 00 00       	call   80190a <read>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	7f e0                	jg     8000b4 <wrong+0x7f>
	cprintf("===\n");
  8000d4:	83 ec 0c             	sub    $0xc,%esp
  8000d7:	68 f5 2c 80 00       	push   $0x802cf5
  8000dc:	e8 26 05 00 00       	call   800607 <cprintf>
	exit();
  8000e1:	e8 1c 04 00 00       	call   800502 <exit>
}
  8000e6:	83 c4 10             	add    $0x10,%esp
  8000e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <umain>:
{
  8000f1:	f3 0f 1e fb          	endbr32 
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	57                   	push   %edi
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
  8000fb:	83 ec 38             	sub    $0x38,%esp
	close(0);
  8000fe:	6a 00                	push   $0x0
  800100:	e8 bb 16 00 00       	call   8017c0 <close>
	close(1);
  800105:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80010c:	e8 af 16 00 00       	call   8017c0 <close>
	opencons();
  800111:	e8 48 03 00 00       	call   80045e <opencons>
	opencons();
  800116:	e8 43 03 00 00       	call   80045e <opencons>
	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  80011b:	83 c4 08             	add    $0x8,%esp
  80011e:	6a 00                	push   $0x0
  800120:	68 08 2d 80 00       	push   $0x802d08
  800125:	e8 9a 1c 00 00       	call   801dc4 <open>
  80012a:	89 c3                	mov    %eax,%ebx
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	85 c0                	test   %eax,%eax
  800131:	0f 88 e7 00 00 00    	js     80021e <umain+0x12d>
	if ((wfd = pipe(pfds)) < 0)
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	e8 17 25 00 00       	call   80265a <pipe>
  800143:	83 c4 10             	add    $0x10,%esp
  800146:	85 c0                	test   %eax,%eax
  800148:	0f 88 e2 00 00 00    	js     800230 <umain+0x13f>
	wfd = pfds[1];
  80014e:	8b 75 e0             	mov    -0x20(%ebp),%esi
	cprintf("running sh -x < testshell.sh | cat\n");
  800151:	83 ec 0c             	sub    $0xc,%esp
  800154:	68 a4 2c 80 00       	push   $0x802ca4
  800159:	e8 a9 04 00 00       	call   800607 <cprintf>
	if ((r = fork()) < 0)
  80015e:	e8 47 13 00 00       	call   8014aa <fork>
  800163:	83 c4 10             	add    $0x10,%esp
  800166:	85 c0                	test   %eax,%eax
  800168:	0f 88 d4 00 00 00    	js     800242 <umain+0x151>
	if (r == 0) {
  80016e:	75 6f                	jne    8001df <umain+0xee>
		dup(rfd, 0);
  800170:	83 ec 08             	sub    $0x8,%esp
  800173:	6a 00                	push   $0x0
  800175:	53                   	push   %ebx
  800176:	e8 9f 16 00 00       	call   80181a <dup>
		dup(wfd, 1);
  80017b:	83 c4 08             	add    $0x8,%esp
  80017e:	6a 01                	push   $0x1
  800180:	56                   	push   %esi
  800181:	e8 94 16 00 00       	call   80181a <dup>
		close(rfd);
  800186:	89 1c 24             	mov    %ebx,(%esp)
  800189:	e8 32 16 00 00       	call   8017c0 <close>
		close(wfd);
  80018e:	89 34 24             	mov    %esi,(%esp)
  800191:	e8 2a 16 00 00       	call   8017c0 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  800196:	6a 00                	push   $0x0
  800198:	68 4e 2d 80 00       	push   $0x802d4e
  80019d:	68 12 2d 80 00       	push   $0x802d12
  8001a2:	68 51 2d 80 00       	push   $0x802d51
  8001a7:	e8 1b 22 00 00       	call   8023c7 <spawnl>
  8001ac:	89 c7                	mov    %eax,%edi
  8001ae:	83 c4 20             	add    $0x20,%esp
  8001b1:	85 c0                	test   %eax,%eax
  8001b3:	0f 88 9b 00 00 00    	js     800254 <umain+0x163>
		close(0);
  8001b9:	83 ec 0c             	sub    $0xc,%esp
  8001bc:	6a 00                	push   $0x0
  8001be:	e8 fd 15 00 00       	call   8017c0 <close>
		close(1);
  8001c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001ca:	e8 f1 15 00 00       	call   8017c0 <close>
		wait(r);
  8001cf:	89 3c 24             	mov    %edi,(%esp)
  8001d2:	e8 08 26 00 00       	call   8027df <wait>
		exit();
  8001d7:	e8 26 03 00 00       	call   800502 <exit>
  8001dc:	83 c4 10             	add    $0x10,%esp
	close(rfd);
  8001df:	83 ec 0c             	sub    $0xc,%esp
  8001e2:	53                   	push   %ebx
  8001e3:	e8 d8 15 00 00       	call   8017c0 <close>
	close(wfd);
  8001e8:	89 34 24             	mov    %esi,(%esp)
  8001eb:	e8 d0 15 00 00       	call   8017c0 <close>
	rfd = pfds[0];
  8001f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8001f6:	83 c4 08             	add    $0x8,%esp
  8001f9:	6a 00                	push   $0x0
  8001fb:	68 5f 2d 80 00       	push   $0x802d5f
  800200:	e8 bf 1b 00 00       	call   801dc4 <open>
  800205:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	85 c0                	test   %eax,%eax
  80020d:	78 57                	js     800266 <umain+0x175>
  80020f:	be 01 00 00 00       	mov    $0x1,%esi
	nloff = 0;
  800214:	bf 00 00 00 00       	mov    $0x0,%edi
  800219:	e9 9a 00 00 00       	jmp    8002b8 <umain+0x1c7>
		panic("open testshell.sh: %e", rfd);
  80021e:	50                   	push   %eax
  80021f:	68 15 2d 80 00       	push   $0x802d15
  800224:	6a 13                	push   $0x13
  800226:	68 2b 2d 80 00       	push   $0x802d2b
  80022b:	e8 f0 02 00 00       	call   800520 <_panic>
		panic("pipe: %e", wfd);
  800230:	50                   	push   %eax
  800231:	68 3c 2d 80 00       	push   $0x802d3c
  800236:	6a 15                	push   $0x15
  800238:	68 2b 2d 80 00       	push   $0x802d2b
  80023d:	e8 de 02 00 00       	call   800520 <_panic>
		panic("fork: %e", r);
  800242:	50                   	push   %eax
  800243:	68 45 2d 80 00       	push   $0x802d45
  800248:	6a 1a                	push   $0x1a
  80024a:	68 2b 2d 80 00       	push   $0x802d2b
  80024f:	e8 cc 02 00 00       	call   800520 <_panic>
			panic("spawn: %e", r);
  800254:	50                   	push   %eax
  800255:	68 55 2d 80 00       	push   $0x802d55
  80025a:	6a 21                	push   $0x21
  80025c:	68 2b 2d 80 00       	push   $0x802d2b
  800261:	e8 ba 02 00 00       	call   800520 <_panic>
		panic("open testshell.key for reading: %e", kfd);
  800266:	50                   	push   %eax
  800267:	68 c8 2c 80 00       	push   $0x802cc8
  80026c:	6a 2c                	push   $0x2c
  80026e:	68 2b 2d 80 00       	push   $0x802d2b
  800273:	e8 a8 02 00 00       	call   800520 <_panic>
			panic("reading testshell.out: %e", n1);
  800278:	53                   	push   %ebx
  800279:	68 6d 2d 80 00       	push   $0x802d6d
  80027e:	6a 33                	push   $0x33
  800280:	68 2b 2d 80 00       	push   $0x802d2b
  800285:	e8 96 02 00 00       	call   800520 <_panic>
			panic("reading testshell.key: %e", n2);
  80028a:	50                   	push   %eax
  80028b:	68 87 2d 80 00       	push   $0x802d87
  800290:	6a 35                	push   $0x35
  800292:	68 2b 2d 80 00       	push   $0x802d2b
  800297:	e8 84 02 00 00       	call   800520 <_panic>
			wrong(rfd, kfd, nloff);
  80029c:	83 ec 04             	sub    $0x4,%esp
  80029f:	57                   	push   %edi
  8002a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002a3:	ff 75 d0             	pushl  -0x30(%ebp)
  8002a6:	e8 8a fd ff ff       	call   800035 <wrong>
  8002ab:	83 c4 10             	add    $0x10,%esp
			nloff = off+1;
  8002ae:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002b2:	0f 44 fe             	cmove  %esi,%edi
  8002b5:	83 c6 01             	add    $0x1,%esi
		n1 = read(rfd, &c1, 1);
  8002b8:	83 ec 04             	sub    $0x4,%esp
  8002bb:	6a 01                	push   $0x1
  8002bd:	8d 45 e7             	lea    -0x19(%ebp),%eax
  8002c0:	50                   	push   %eax
  8002c1:	ff 75 d0             	pushl  -0x30(%ebp)
  8002c4:	e8 41 16 00 00       	call   80190a <read>
  8002c9:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002cb:	83 c4 0c             	add    $0xc,%esp
  8002ce:	6a 01                	push   $0x1
  8002d0:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  8002d3:	50                   	push   %eax
  8002d4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002d7:	e8 2e 16 00 00       	call   80190a <read>
		if (n1 < 0)
  8002dc:	83 c4 10             	add    $0x10,%esp
  8002df:	85 db                	test   %ebx,%ebx
  8002e1:	78 95                	js     800278 <umain+0x187>
		if (n2 < 0)
  8002e3:	85 c0                	test   %eax,%eax
  8002e5:	78 a3                	js     80028a <umain+0x199>
		if (n1 == 0 && n2 == 0)
  8002e7:	89 da                	mov    %ebx,%edx
  8002e9:	09 c2                	or     %eax,%edx
  8002eb:	74 15                	je     800302 <umain+0x211>
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002ed:	83 fb 01             	cmp    $0x1,%ebx
  8002f0:	75 aa                	jne    80029c <umain+0x1ab>
  8002f2:	83 f8 01             	cmp    $0x1,%eax
  8002f5:	75 a5                	jne    80029c <umain+0x1ab>
  8002f7:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002fb:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002fe:	75 9c                	jne    80029c <umain+0x1ab>
  800300:	eb ac                	jmp    8002ae <umain+0x1bd>
	cprintf("shell ran correctly\n");
  800302:	83 ec 0c             	sub    $0xc,%esp
  800305:	68 a1 2d 80 00       	push   $0x802da1
  80030a:	e8 f8 02 00 00       	call   800607 <cprintf>
	breakpoint();
  80030f:	e8 1f fd ff ff       	call   800033 <breakpoint>
}
  800314:	83 c4 10             	add    $0x10,%esp
  800317:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031a:	5b                   	pop    %ebx
  80031b:	5e                   	pop    %esi
  80031c:	5f                   	pop    %edi
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80031f:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800323:	b8 00 00 00 00       	mov    $0x0,%eax
  800328:	c3                   	ret    

00800329 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800329:	f3 0f 1e fb          	endbr32 
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800333:	68 b6 2d 80 00       	push   $0x802db6
  800338:	ff 75 0c             	pushl  0xc(%ebp)
  80033b:	e8 31 08 00 00       	call   800b71 <strcpy>
	return 0;
}
  800340:	b8 00 00 00 00       	mov    $0x0,%eax
  800345:	c9                   	leave  
  800346:	c3                   	ret    

00800347 <devcons_write>:
{
  800347:	f3 0f 1e fb          	endbr32 
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	57                   	push   %edi
  80034f:	56                   	push   %esi
  800350:	53                   	push   %ebx
  800351:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800357:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80035c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800362:	3b 75 10             	cmp    0x10(%ebp),%esi
  800365:	73 31                	jae    800398 <devcons_write+0x51>
		m = n - tot;
  800367:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80036a:	29 f3                	sub    %esi,%ebx
  80036c:	83 fb 7f             	cmp    $0x7f,%ebx
  80036f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800374:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800377:	83 ec 04             	sub    $0x4,%esp
  80037a:	53                   	push   %ebx
  80037b:	89 f0                	mov    %esi,%eax
  80037d:	03 45 0c             	add    0xc(%ebp),%eax
  800380:	50                   	push   %eax
  800381:	57                   	push   %edi
  800382:	e8 a2 09 00 00       	call   800d29 <memmove>
		sys_cputs(buf, m);
  800387:	83 c4 08             	add    $0x8,%esp
  80038a:	53                   	push   %ebx
  80038b:	57                   	push   %edi
  80038c:	e8 9d 0b 00 00       	call   800f2e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800391:	01 de                	add    %ebx,%esi
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb ca                	jmp    800362 <devcons_write+0x1b>
}
  800398:	89 f0                	mov    %esi,%eax
  80039a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039d:	5b                   	pop    %ebx
  80039e:	5e                   	pop    %esi
  80039f:	5f                   	pop    %edi
  8003a0:	5d                   	pop    %ebp
  8003a1:	c3                   	ret    

008003a2 <devcons_read>:
{
  8003a2:	f3 0f 1e fb          	endbr32 
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 08             	sub    $0x8,%esp
  8003ac:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8003b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8003b5:	74 21                	je     8003d8 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8003b7:	e8 9c 0b 00 00       	call   800f58 <sys_cgetc>
  8003bc:	85 c0                	test   %eax,%eax
  8003be:	75 07                	jne    8003c7 <devcons_read+0x25>
		sys_yield();
  8003c0:	e8 09 0c 00 00       	call   800fce <sys_yield>
  8003c5:	eb f0                	jmp    8003b7 <devcons_read+0x15>
	if (c < 0)
  8003c7:	78 0f                	js     8003d8 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8003c9:	83 f8 04             	cmp    $0x4,%eax
  8003cc:	74 0c                	je     8003da <devcons_read+0x38>
	*(char*)vbuf = c;
  8003ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d1:	88 02                	mov    %al,(%edx)
	return 1;
  8003d3:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8003d8:	c9                   	leave  
  8003d9:	c3                   	ret    
		return 0;
  8003da:	b8 00 00 00 00       	mov    $0x0,%eax
  8003df:	eb f7                	jmp    8003d8 <devcons_read+0x36>

008003e1 <cputchar>:
{
  8003e1:	f3 0f 1e fb          	endbr32 
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ee:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8003f1:	6a 01                	push   $0x1
  8003f3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003f6:	50                   	push   %eax
  8003f7:	e8 32 0b 00 00       	call   800f2e <sys_cputs>
}
  8003fc:	83 c4 10             	add    $0x10,%esp
  8003ff:	c9                   	leave  
  800400:	c3                   	ret    

00800401 <getchar>:
{
  800401:	f3 0f 1e fb          	endbr32 
  800405:	55                   	push   %ebp
  800406:	89 e5                	mov    %esp,%ebp
  800408:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80040b:	6a 01                	push   $0x1
  80040d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800410:	50                   	push   %eax
  800411:	6a 00                	push   $0x0
  800413:	e8 f2 14 00 00       	call   80190a <read>
	if (r < 0)
  800418:	83 c4 10             	add    $0x10,%esp
  80041b:	85 c0                	test   %eax,%eax
  80041d:	78 06                	js     800425 <getchar+0x24>
	if (r < 1)
  80041f:	74 06                	je     800427 <getchar+0x26>
	return c;
  800421:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800425:	c9                   	leave  
  800426:	c3                   	ret    
		return -E_EOF;
  800427:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80042c:	eb f7                	jmp    800425 <getchar+0x24>

0080042e <iscons>:
{
  80042e:	f3 0f 1e fb          	endbr32 
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800438:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80043b:	50                   	push   %eax
  80043c:	ff 75 08             	pushl  0x8(%ebp)
  80043f:	e8 43 12 00 00       	call   801687 <fd_lookup>
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	85 c0                	test   %eax,%eax
  800449:	78 11                	js     80045c <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80044b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80044e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800454:	39 10                	cmp    %edx,(%eax)
  800456:	0f 94 c0             	sete   %al
  800459:	0f b6 c0             	movzbl %al,%eax
}
  80045c:	c9                   	leave  
  80045d:	c3                   	ret    

0080045e <opencons>:
{
  80045e:	f3 0f 1e fb          	endbr32 
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800468:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80046b:	50                   	push   %eax
  80046c:	e8 c0 11 00 00       	call   801631 <fd_alloc>
  800471:	83 c4 10             	add    $0x10,%esp
  800474:	85 c0                	test   %eax,%eax
  800476:	78 3a                	js     8004b2 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800478:	83 ec 04             	sub    $0x4,%esp
  80047b:	68 07 04 00 00       	push   $0x407
  800480:	ff 75 f4             	pushl  -0xc(%ebp)
  800483:	6a 00                	push   $0x0
  800485:	e8 6f 0b 00 00       	call   800ff9 <sys_page_alloc>
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	85 c0                	test   %eax,%eax
  80048f:	78 21                	js     8004b2 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  800491:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800494:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80049a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80049c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80049f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8004a6:	83 ec 0c             	sub    $0xc,%esp
  8004a9:	50                   	push   %eax
  8004aa:	e8 4f 11 00 00       	call   8015fe <fd2num>
  8004af:	83 c4 10             	add    $0x10,%esp
}
  8004b2:	c9                   	leave  
  8004b3:	c3                   	ret    

008004b4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8004b4:	f3 0f 1e fb          	endbr32 
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	56                   	push   %esi
  8004bc:	53                   	push   %ebx
  8004bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8004c3:	e8 de 0a 00 00       	call   800fa6 <sys_getenvid>
	if (id >= 0)
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	78 12                	js     8004de <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8004cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004d1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004d9:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004de:	85 db                	test   %ebx,%ebx
  8004e0:	7e 07                	jle    8004e9 <libmain+0x35>
		binaryname = argv[0];
  8004e2:	8b 06                	mov    (%esi),%eax
  8004e4:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	56                   	push   %esi
  8004ed:	53                   	push   %ebx
  8004ee:	e8 fe fb ff ff       	call   8000f1 <umain>

	// exit gracefully
	exit();
  8004f3:	e8 0a 00 00 00       	call   800502 <exit>
}
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004fe:	5b                   	pop    %ebx
  8004ff:	5e                   	pop    %esi
  800500:	5d                   	pop    %ebp
  800501:	c3                   	ret    

00800502 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800502:	f3 0f 1e fb          	endbr32 
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80050c:	e8 e0 12 00 00       	call   8017f1 <close_all>
	sys_env_destroy(0);
  800511:	83 ec 0c             	sub    $0xc,%esp
  800514:	6a 00                	push   $0x0
  800516:	e8 65 0a 00 00       	call   800f80 <sys_env_destroy>
}
  80051b:	83 c4 10             	add    $0x10,%esp
  80051e:	c9                   	leave  
  80051f:	c3                   	ret    

00800520 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800520:	f3 0f 1e fb          	endbr32 
  800524:	55                   	push   %ebp
  800525:	89 e5                	mov    %esp,%ebp
  800527:	56                   	push   %esi
  800528:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800529:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80052c:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800532:	e8 6f 0a 00 00       	call   800fa6 <sys_getenvid>
  800537:	83 ec 0c             	sub    $0xc,%esp
  80053a:	ff 75 0c             	pushl  0xc(%ebp)
  80053d:	ff 75 08             	pushl  0x8(%ebp)
  800540:	56                   	push   %esi
  800541:	50                   	push   %eax
  800542:	68 cc 2d 80 00       	push   $0x802dcc
  800547:	e8 bb 00 00 00       	call   800607 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80054c:	83 c4 18             	add    $0x18,%esp
  80054f:	53                   	push   %ebx
  800550:	ff 75 10             	pushl  0x10(%ebp)
  800553:	e8 5a 00 00 00       	call   8005b2 <vcprintf>
	cprintf("\n");
  800558:	c7 04 24 f8 2c 80 00 	movl   $0x802cf8,(%esp)
  80055f:	e8 a3 00 00 00       	call   800607 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800567:	cc                   	int3   
  800568:	eb fd                	jmp    800567 <_panic+0x47>

0080056a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80056a:	f3 0f 1e fb          	endbr32 
  80056e:	55                   	push   %ebp
  80056f:	89 e5                	mov    %esp,%ebp
  800571:	53                   	push   %ebx
  800572:	83 ec 04             	sub    $0x4,%esp
  800575:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800578:	8b 13                	mov    (%ebx),%edx
  80057a:	8d 42 01             	lea    0x1(%edx),%eax
  80057d:	89 03                	mov    %eax,(%ebx)
  80057f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800582:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800586:	3d ff 00 00 00       	cmp    $0xff,%eax
  80058b:	74 09                	je     800596 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80058d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800591:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800594:	c9                   	leave  
  800595:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800596:	83 ec 08             	sub    $0x8,%esp
  800599:	68 ff 00 00 00       	push   $0xff
  80059e:	8d 43 08             	lea    0x8(%ebx),%eax
  8005a1:	50                   	push   %eax
  8005a2:	e8 87 09 00 00       	call   800f2e <sys_cputs>
		b->idx = 0;
  8005a7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8005ad:	83 c4 10             	add    $0x10,%esp
  8005b0:	eb db                	jmp    80058d <putch+0x23>

008005b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8005b2:	f3 0f 1e fb          	endbr32 
  8005b6:	55                   	push   %ebp
  8005b7:	89 e5                	mov    %esp,%ebp
  8005b9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8005bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005c6:	00 00 00 
	b.cnt = 0;
  8005c9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005d0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005d3:	ff 75 0c             	pushl  0xc(%ebp)
  8005d6:	ff 75 08             	pushl  0x8(%ebp)
  8005d9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005df:	50                   	push   %eax
  8005e0:	68 6a 05 80 00       	push   $0x80056a
  8005e5:	e8 80 01 00 00       	call   80076a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005ea:	83 c4 08             	add    $0x8,%esp
  8005ed:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005f3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005f9:	50                   	push   %eax
  8005fa:	e8 2f 09 00 00       	call   800f2e <sys_cputs>

	return b.cnt;
}
  8005ff:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800605:	c9                   	leave  
  800606:	c3                   	ret    

00800607 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800607:	f3 0f 1e fb          	endbr32 
  80060b:	55                   	push   %ebp
  80060c:	89 e5                	mov    %esp,%ebp
  80060e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800611:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800614:	50                   	push   %eax
  800615:	ff 75 08             	pushl  0x8(%ebp)
  800618:	e8 95 ff ff ff       	call   8005b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80061d:	c9                   	leave  
  80061e:	c3                   	ret    

0080061f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80061f:	55                   	push   %ebp
  800620:	89 e5                	mov    %esp,%ebp
  800622:	57                   	push   %edi
  800623:	56                   	push   %esi
  800624:	53                   	push   %ebx
  800625:	83 ec 1c             	sub    $0x1c,%esp
  800628:	89 c7                	mov    %eax,%edi
  80062a:	89 d6                	mov    %edx,%esi
  80062c:	8b 45 08             	mov    0x8(%ebp),%eax
  80062f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800632:	89 d1                	mov    %edx,%ecx
  800634:	89 c2                	mov    %eax,%edx
  800636:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800639:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80063c:	8b 45 10             	mov    0x10(%ebp),%eax
  80063f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800642:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800645:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80064c:	39 c2                	cmp    %eax,%edx
  80064e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800651:	72 3e                	jb     800691 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800653:	83 ec 0c             	sub    $0xc,%esp
  800656:	ff 75 18             	pushl  0x18(%ebp)
  800659:	83 eb 01             	sub    $0x1,%ebx
  80065c:	53                   	push   %ebx
  80065d:	50                   	push   %eax
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	ff 75 e4             	pushl  -0x1c(%ebp)
  800664:	ff 75 e0             	pushl  -0x20(%ebp)
  800667:	ff 75 dc             	pushl  -0x24(%ebp)
  80066a:	ff 75 d8             	pushl  -0x28(%ebp)
  80066d:	e8 9e 23 00 00       	call   802a10 <__udivdi3>
  800672:	83 c4 18             	add    $0x18,%esp
  800675:	52                   	push   %edx
  800676:	50                   	push   %eax
  800677:	89 f2                	mov    %esi,%edx
  800679:	89 f8                	mov    %edi,%eax
  80067b:	e8 9f ff ff ff       	call   80061f <printnum>
  800680:	83 c4 20             	add    $0x20,%esp
  800683:	eb 13                	jmp    800698 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	56                   	push   %esi
  800689:	ff 75 18             	pushl  0x18(%ebp)
  80068c:	ff d7                	call   *%edi
  80068e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800691:	83 eb 01             	sub    $0x1,%ebx
  800694:	85 db                	test   %ebx,%ebx
  800696:	7f ed                	jg     800685 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	56                   	push   %esi
  80069c:	83 ec 04             	sub    $0x4,%esp
  80069f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8006a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8006ab:	e8 70 24 00 00       	call   802b20 <__umoddi3>
  8006b0:	83 c4 14             	add    $0x14,%esp
  8006b3:	0f be 80 ef 2d 80 00 	movsbl 0x802def(%eax),%eax
  8006ba:	50                   	push   %eax
  8006bb:	ff d7                	call   *%edi
}
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c3:	5b                   	pop    %ebx
  8006c4:	5e                   	pop    %esi
  8006c5:	5f                   	pop    %edi
  8006c6:	5d                   	pop    %ebp
  8006c7:	c3                   	ret    

008006c8 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c8:	83 fa 01             	cmp    $0x1,%edx
  8006cb:	7f 13                	jg     8006e0 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006cd:	85 d2                	test   %edx,%edx
  8006cf:	74 1c                	je     8006ed <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8006d1:	8b 10                	mov    (%eax),%edx
  8006d3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006d6:	89 08                	mov    %ecx,(%eax)
  8006d8:	8b 02                	mov    (%edx),%eax
  8006da:	ba 00 00 00 00       	mov    $0x0,%edx
  8006df:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8006e0:	8b 10                	mov    (%eax),%edx
  8006e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006e5:	89 08                	mov    %ecx,(%eax)
  8006e7:	8b 02                	mov    (%edx),%eax
  8006e9:	8b 52 04             	mov    0x4(%edx),%edx
  8006ec:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8006ed:	8b 10                	mov    (%eax),%edx
  8006ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006f2:	89 08                	mov    %ecx,(%eax)
  8006f4:	8b 02                	mov    (%edx),%eax
  8006f6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006fb:	c3                   	ret    

008006fc <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006fc:	83 fa 01             	cmp    $0x1,%edx
  8006ff:	7f 0f                	jg     800710 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800701:	85 d2                	test   %edx,%edx
  800703:	74 18                	je     80071d <getint+0x21>
		return va_arg(*ap, long);
  800705:	8b 10                	mov    (%eax),%edx
  800707:	8d 4a 04             	lea    0x4(%edx),%ecx
  80070a:	89 08                	mov    %ecx,(%eax)
  80070c:	8b 02                	mov    (%edx),%eax
  80070e:	99                   	cltd   
  80070f:	c3                   	ret    
		return va_arg(*ap, long long);
  800710:	8b 10                	mov    (%eax),%edx
  800712:	8d 4a 08             	lea    0x8(%edx),%ecx
  800715:	89 08                	mov    %ecx,(%eax)
  800717:	8b 02                	mov    (%edx),%eax
  800719:	8b 52 04             	mov    0x4(%edx),%edx
  80071c:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80071d:	8b 10                	mov    (%eax),%edx
  80071f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800722:	89 08                	mov    %ecx,(%eax)
  800724:	8b 02                	mov    (%edx),%eax
  800726:	99                   	cltd   
}
  800727:	c3                   	ret    

00800728 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800728:	f3 0f 1e fb          	endbr32 
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800732:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800736:	8b 10                	mov    (%eax),%edx
  800738:	3b 50 04             	cmp    0x4(%eax),%edx
  80073b:	73 0a                	jae    800747 <sprintputch+0x1f>
		*b->buf++ = ch;
  80073d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800740:	89 08                	mov    %ecx,(%eax)
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	88 02                	mov    %al,(%edx)
}
  800747:	5d                   	pop    %ebp
  800748:	c3                   	ret    

00800749 <printfmt>:
{
  800749:	f3 0f 1e fb          	endbr32 
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800753:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800756:	50                   	push   %eax
  800757:	ff 75 10             	pushl  0x10(%ebp)
  80075a:	ff 75 0c             	pushl  0xc(%ebp)
  80075d:	ff 75 08             	pushl  0x8(%ebp)
  800760:	e8 05 00 00 00       	call   80076a <vprintfmt>
}
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	c9                   	leave  
  800769:	c3                   	ret    

0080076a <vprintfmt>:
{
  80076a:	f3 0f 1e fb          	endbr32 
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	57                   	push   %edi
  800772:	56                   	push   %esi
  800773:	53                   	push   %ebx
  800774:	83 ec 2c             	sub    $0x2c,%esp
  800777:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80077a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80077d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800780:	e9 86 02 00 00       	jmp    800a0b <vprintfmt+0x2a1>
		padc = ' ';
  800785:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800789:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800790:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800797:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80079e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8007a3:	8d 47 01             	lea    0x1(%edi),%eax
  8007a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007a9:	0f b6 17             	movzbl (%edi),%edx
  8007ac:	8d 42 dd             	lea    -0x23(%edx),%eax
  8007af:	3c 55                	cmp    $0x55,%al
  8007b1:	0f 87 df 02 00 00    	ja     800a96 <vprintfmt+0x32c>
  8007b7:	0f b6 c0             	movzbl %al,%eax
  8007ba:	3e ff 24 85 40 2f 80 	notrack jmp *0x802f40(,%eax,4)
  8007c1:	00 
  8007c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8007c5:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8007c9:	eb d8                	jmp    8007a3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8007cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007ce:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8007d2:	eb cf                	jmp    8007a3 <vprintfmt+0x39>
  8007d4:	0f b6 d2             	movzbl %dl,%edx
  8007d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8007da:	b8 00 00 00 00       	mov    $0x0,%eax
  8007df:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8007e2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8007e5:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8007e9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8007ec:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8007ef:	83 f9 09             	cmp    $0x9,%ecx
  8007f2:	77 52                	ja     800846 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8007f4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8007f7:	eb e9                	jmp    8007e2 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8007f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fc:	8d 50 04             	lea    0x4(%eax),%edx
  8007ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800802:	8b 00                	mov    (%eax),%eax
  800804:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800807:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80080a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80080e:	79 93                	jns    8007a3 <vprintfmt+0x39>
				width = precision, precision = -1;
  800810:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800813:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800816:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80081d:	eb 84                	jmp    8007a3 <vprintfmt+0x39>
  80081f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800822:	85 c0                	test   %eax,%eax
  800824:	ba 00 00 00 00       	mov    $0x0,%edx
  800829:	0f 49 d0             	cmovns %eax,%edx
  80082c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80082f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800832:	e9 6c ff ff ff       	jmp    8007a3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800837:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80083a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800841:	e9 5d ff ff ff       	jmp    8007a3 <vprintfmt+0x39>
  800846:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800849:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80084c:	eb bc                	jmp    80080a <vprintfmt+0xa0>
			lflag++;
  80084e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800851:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800854:	e9 4a ff ff ff       	jmp    8007a3 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800859:	8b 45 14             	mov    0x14(%ebp),%eax
  80085c:	8d 50 04             	lea    0x4(%eax),%edx
  80085f:	89 55 14             	mov    %edx,0x14(%ebp)
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	56                   	push   %esi
  800866:	ff 30                	pushl  (%eax)
  800868:	ff d3                	call   *%ebx
			break;
  80086a:	83 c4 10             	add    $0x10,%esp
  80086d:	e9 96 01 00 00       	jmp    800a08 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	8d 50 04             	lea    0x4(%eax),%edx
  800878:	89 55 14             	mov    %edx,0x14(%ebp)
  80087b:	8b 00                	mov    (%eax),%eax
  80087d:	99                   	cltd   
  80087e:	31 d0                	xor    %edx,%eax
  800880:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800882:	83 f8 0f             	cmp    $0xf,%eax
  800885:	7f 20                	jg     8008a7 <vprintfmt+0x13d>
  800887:	8b 14 85 a0 30 80 00 	mov    0x8030a0(,%eax,4),%edx
  80088e:	85 d2                	test   %edx,%edx
  800890:	74 15                	je     8008a7 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800892:	52                   	push   %edx
  800893:	68 a5 33 80 00       	push   $0x8033a5
  800898:	56                   	push   %esi
  800899:	53                   	push   %ebx
  80089a:	e8 aa fe ff ff       	call   800749 <printfmt>
  80089f:	83 c4 10             	add    $0x10,%esp
  8008a2:	e9 61 01 00 00       	jmp    800a08 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8008a7:	50                   	push   %eax
  8008a8:	68 07 2e 80 00       	push   $0x802e07
  8008ad:	56                   	push   %esi
  8008ae:	53                   	push   %ebx
  8008af:	e8 95 fe ff ff       	call   800749 <printfmt>
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	e9 4c 01 00 00       	jmp    800a08 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8008bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bf:	8d 50 04             	lea    0x4(%eax),%edx
  8008c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c5:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8008c7:	85 c9                	test   %ecx,%ecx
  8008c9:	b8 00 2e 80 00       	mov    $0x802e00,%eax
  8008ce:	0f 45 c1             	cmovne %ecx,%eax
  8008d1:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8008d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008d8:	7e 06                	jle    8008e0 <vprintfmt+0x176>
  8008da:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8008de:	75 0d                	jne    8008ed <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008e0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008e3:	89 c7                	mov    %eax,%edi
  8008e5:	03 45 e0             	add    -0x20(%ebp),%eax
  8008e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008eb:	eb 57                	jmp    800944 <vprintfmt+0x1da>
  8008ed:	83 ec 08             	sub    $0x8,%esp
  8008f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8008f3:	ff 75 cc             	pushl  -0x34(%ebp)
  8008f6:	e8 4f 02 00 00       	call   800b4a <strnlen>
  8008fb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8008fe:	29 c2                	sub    %eax,%edx
  800900:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800903:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800906:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80090a:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80090d:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80090f:	85 db                	test   %ebx,%ebx
  800911:	7e 10                	jle    800923 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800913:	83 ec 08             	sub    $0x8,%esp
  800916:	56                   	push   %esi
  800917:	57                   	push   %edi
  800918:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80091b:	83 eb 01             	sub    $0x1,%ebx
  80091e:	83 c4 10             	add    $0x10,%esp
  800921:	eb ec                	jmp    80090f <vprintfmt+0x1a5>
  800923:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800926:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800929:	85 d2                	test   %edx,%edx
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
  800930:	0f 49 c2             	cmovns %edx,%eax
  800933:	29 c2                	sub    %eax,%edx
  800935:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800938:	eb a6                	jmp    8008e0 <vprintfmt+0x176>
					putch(ch, putdat);
  80093a:	83 ec 08             	sub    $0x8,%esp
  80093d:	56                   	push   %esi
  80093e:	52                   	push   %edx
  80093f:	ff d3                	call   *%ebx
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800947:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800949:	83 c7 01             	add    $0x1,%edi
  80094c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800950:	0f be d0             	movsbl %al,%edx
  800953:	85 d2                	test   %edx,%edx
  800955:	74 42                	je     800999 <vprintfmt+0x22f>
  800957:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80095b:	78 06                	js     800963 <vprintfmt+0x1f9>
  80095d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800961:	78 1e                	js     800981 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800963:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800967:	74 d1                	je     80093a <vprintfmt+0x1d0>
  800969:	0f be c0             	movsbl %al,%eax
  80096c:	83 e8 20             	sub    $0x20,%eax
  80096f:	83 f8 5e             	cmp    $0x5e,%eax
  800972:	76 c6                	jbe    80093a <vprintfmt+0x1d0>
					putch('?', putdat);
  800974:	83 ec 08             	sub    $0x8,%esp
  800977:	56                   	push   %esi
  800978:	6a 3f                	push   $0x3f
  80097a:	ff d3                	call   *%ebx
  80097c:	83 c4 10             	add    $0x10,%esp
  80097f:	eb c3                	jmp    800944 <vprintfmt+0x1da>
  800981:	89 cf                	mov    %ecx,%edi
  800983:	eb 0e                	jmp    800993 <vprintfmt+0x229>
				putch(' ', putdat);
  800985:	83 ec 08             	sub    $0x8,%esp
  800988:	56                   	push   %esi
  800989:	6a 20                	push   $0x20
  80098b:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80098d:	83 ef 01             	sub    $0x1,%edi
  800990:	83 c4 10             	add    $0x10,%esp
  800993:	85 ff                	test   %edi,%edi
  800995:	7f ee                	jg     800985 <vprintfmt+0x21b>
  800997:	eb 6f                	jmp    800a08 <vprintfmt+0x29e>
  800999:	89 cf                	mov    %ecx,%edi
  80099b:	eb f6                	jmp    800993 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  80099d:	89 ca                	mov    %ecx,%edx
  80099f:	8d 45 14             	lea    0x14(%ebp),%eax
  8009a2:	e8 55 fd ff ff       	call   8006fc <getint>
  8009a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8009ad:	85 d2                	test   %edx,%edx
  8009af:	78 0b                	js     8009bc <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8009b1:	89 d1                	mov    %edx,%ecx
  8009b3:	89 c2                	mov    %eax,%edx
			base = 10;
  8009b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009ba:	eb 32                	jmp    8009ee <vprintfmt+0x284>
				putch('-', putdat);
  8009bc:	83 ec 08             	sub    $0x8,%esp
  8009bf:	56                   	push   %esi
  8009c0:	6a 2d                	push   $0x2d
  8009c2:	ff d3                	call   *%ebx
				num = -(long long) num;
  8009c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8009ca:	f7 da                	neg    %edx
  8009cc:	83 d1 00             	adc    $0x0,%ecx
  8009cf:	f7 d9                	neg    %ecx
  8009d1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8009d4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d9:	eb 13                	jmp    8009ee <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8009db:	89 ca                	mov    %ecx,%edx
  8009dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8009e0:	e8 e3 fc ff ff       	call   8006c8 <getuint>
  8009e5:	89 d1                	mov    %edx,%ecx
  8009e7:	89 c2                	mov    %eax,%edx
			base = 10;
  8009e9:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  8009ee:	83 ec 0c             	sub    $0xc,%esp
  8009f1:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8009f5:	57                   	push   %edi
  8009f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8009f9:	50                   	push   %eax
  8009fa:	51                   	push   %ecx
  8009fb:	52                   	push   %edx
  8009fc:	89 f2                	mov    %esi,%edx
  8009fe:	89 d8                	mov    %ebx,%eax
  800a00:	e8 1a fc ff ff       	call   80061f <printnum>
			break;
  800a05:	83 c4 20             	add    $0x20,%esp
{
  800a08:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a0b:	83 c7 01             	add    $0x1,%edi
  800a0e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a12:	83 f8 25             	cmp    $0x25,%eax
  800a15:	0f 84 6a fd ff ff    	je     800785 <vprintfmt+0x1b>
			if (ch == '\0')
  800a1b:	85 c0                	test   %eax,%eax
  800a1d:	0f 84 93 00 00 00    	je     800ab6 <vprintfmt+0x34c>
			putch(ch, putdat);
  800a23:	83 ec 08             	sub    $0x8,%esp
  800a26:	56                   	push   %esi
  800a27:	50                   	push   %eax
  800a28:	ff d3                	call   *%ebx
  800a2a:	83 c4 10             	add    $0x10,%esp
  800a2d:	eb dc                	jmp    800a0b <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800a2f:	89 ca                	mov    %ecx,%edx
  800a31:	8d 45 14             	lea    0x14(%ebp),%eax
  800a34:	e8 8f fc ff ff       	call   8006c8 <getuint>
  800a39:	89 d1                	mov    %edx,%ecx
  800a3b:	89 c2                	mov    %eax,%edx
			base = 8;
  800a3d:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800a42:	eb aa                	jmp    8009ee <vprintfmt+0x284>
			putch('0', putdat);
  800a44:	83 ec 08             	sub    $0x8,%esp
  800a47:	56                   	push   %esi
  800a48:	6a 30                	push   $0x30
  800a4a:	ff d3                	call   *%ebx
			putch('x', putdat);
  800a4c:	83 c4 08             	add    $0x8,%esp
  800a4f:	56                   	push   %esi
  800a50:	6a 78                	push   $0x78
  800a52:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800a54:	8b 45 14             	mov    0x14(%ebp),%eax
  800a57:	8d 50 04             	lea    0x4(%eax),%edx
  800a5a:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800a5d:	8b 10                	mov    (%eax),%edx
  800a5f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800a64:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800a67:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a6c:	eb 80                	jmp    8009ee <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800a6e:	89 ca                	mov    %ecx,%edx
  800a70:	8d 45 14             	lea    0x14(%ebp),%eax
  800a73:	e8 50 fc ff ff       	call   8006c8 <getuint>
  800a78:	89 d1                	mov    %edx,%ecx
  800a7a:	89 c2                	mov    %eax,%edx
			base = 16;
  800a7c:	b8 10 00 00 00       	mov    $0x10,%eax
  800a81:	e9 68 ff ff ff       	jmp    8009ee <vprintfmt+0x284>
			putch(ch, putdat);
  800a86:	83 ec 08             	sub    $0x8,%esp
  800a89:	56                   	push   %esi
  800a8a:	6a 25                	push   $0x25
  800a8c:	ff d3                	call   *%ebx
			break;
  800a8e:	83 c4 10             	add    $0x10,%esp
  800a91:	e9 72 ff ff ff       	jmp    800a08 <vprintfmt+0x29e>
			putch('%', putdat);
  800a96:	83 ec 08             	sub    $0x8,%esp
  800a99:	56                   	push   %esi
  800a9a:	6a 25                	push   $0x25
  800a9c:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a9e:	83 c4 10             	add    $0x10,%esp
  800aa1:	89 f8                	mov    %edi,%eax
  800aa3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800aa7:	74 05                	je     800aae <vprintfmt+0x344>
  800aa9:	83 e8 01             	sub    $0x1,%eax
  800aac:	eb f5                	jmp    800aa3 <vprintfmt+0x339>
  800aae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ab1:	e9 52 ff ff ff       	jmp    800a08 <vprintfmt+0x29e>
}
  800ab6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800abe:	f3 0f 1e fb          	endbr32 
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	83 ec 18             	sub    $0x18,%esp
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ace:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ad1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ad5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ad8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800adf:	85 c0                	test   %eax,%eax
  800ae1:	74 26                	je     800b09 <vsnprintf+0x4b>
  800ae3:	85 d2                	test   %edx,%edx
  800ae5:	7e 22                	jle    800b09 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ae7:	ff 75 14             	pushl  0x14(%ebp)
  800aea:	ff 75 10             	pushl  0x10(%ebp)
  800aed:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800af0:	50                   	push   %eax
  800af1:	68 28 07 80 00       	push   $0x800728
  800af6:	e8 6f fc ff ff       	call   80076a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800afb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800afe:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b04:	83 c4 10             	add    $0x10,%esp
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    
		return -E_INVAL;
  800b09:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b0e:	eb f7                	jmp    800b07 <vsnprintf+0x49>

00800b10 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b10:	f3 0f 1e fb          	endbr32 
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b1a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b1d:	50                   	push   %eax
  800b1e:	ff 75 10             	pushl  0x10(%ebp)
  800b21:	ff 75 0c             	pushl  0xc(%ebp)
  800b24:	ff 75 08             	pushl  0x8(%ebp)
  800b27:	e8 92 ff ff ff       	call   800abe <vsnprintf>
	va_end(ap);

	return rc;
}
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b2e:	f3 0f 1e fb          	endbr32 
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b38:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b41:	74 05                	je     800b48 <strlen+0x1a>
		n++;
  800b43:	83 c0 01             	add    $0x1,%eax
  800b46:	eb f5                	jmp    800b3d <strlen+0xf>
	return n;
}
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b4a:	f3 0f 1e fb          	endbr32 
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b54:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b57:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5c:	39 d0                	cmp    %edx,%eax
  800b5e:	74 0d                	je     800b6d <strnlen+0x23>
  800b60:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b64:	74 05                	je     800b6b <strnlen+0x21>
		n++;
  800b66:	83 c0 01             	add    $0x1,%eax
  800b69:	eb f1                	jmp    800b5c <strnlen+0x12>
  800b6b:	89 c2                	mov    %eax,%edx
	return n;
}
  800b6d:	89 d0                	mov    %edx,%eax
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b71:	f3 0f 1e fb          	endbr32 
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	53                   	push   %ebx
  800b79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b84:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800b88:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800b8b:	83 c0 01             	add    $0x1,%eax
  800b8e:	84 d2                	test   %dl,%dl
  800b90:	75 f2                	jne    800b84 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800b92:	89 c8                	mov    %ecx,%eax
  800b94:	5b                   	pop    %ebx
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b97:	f3 0f 1e fb          	endbr32 
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 10             	sub    $0x10,%esp
  800ba2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ba5:	53                   	push   %ebx
  800ba6:	e8 83 ff ff ff       	call   800b2e <strlen>
  800bab:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800bae:	ff 75 0c             	pushl  0xc(%ebp)
  800bb1:	01 d8                	add    %ebx,%eax
  800bb3:	50                   	push   %eax
  800bb4:	e8 b8 ff ff ff       	call   800b71 <strcpy>
	return dst;
}
  800bb9:	89 d8                	mov    %ebx,%eax
  800bbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bbe:	c9                   	leave  
  800bbf:	c3                   	ret    

00800bc0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bc0:	f3 0f 1e fb          	endbr32 
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	8b 75 08             	mov    0x8(%ebp),%esi
  800bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcf:	89 f3                	mov    %esi,%ebx
  800bd1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bd4:	89 f0                	mov    %esi,%eax
  800bd6:	39 d8                	cmp    %ebx,%eax
  800bd8:	74 11                	je     800beb <strncpy+0x2b>
		*dst++ = *src;
  800bda:	83 c0 01             	add    $0x1,%eax
  800bdd:	0f b6 0a             	movzbl (%edx),%ecx
  800be0:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800be3:	80 f9 01             	cmp    $0x1,%cl
  800be6:	83 da ff             	sbb    $0xffffffff,%edx
  800be9:	eb eb                	jmp    800bd6 <strncpy+0x16>
	}
	return ret;
}
  800beb:	89 f0                	mov    %esi,%eax
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bf1:	f3 0f 1e fb          	endbr32 
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	8b 75 08             	mov    0x8(%ebp),%esi
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	8b 55 10             	mov    0x10(%ebp),%edx
  800c03:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c05:	85 d2                	test   %edx,%edx
  800c07:	74 21                	je     800c2a <strlcpy+0x39>
  800c09:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c0d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800c0f:	39 c2                	cmp    %eax,%edx
  800c11:	74 14                	je     800c27 <strlcpy+0x36>
  800c13:	0f b6 19             	movzbl (%ecx),%ebx
  800c16:	84 db                	test   %bl,%bl
  800c18:	74 0b                	je     800c25 <strlcpy+0x34>
			*dst++ = *src++;
  800c1a:	83 c1 01             	add    $0x1,%ecx
  800c1d:	83 c2 01             	add    $0x1,%edx
  800c20:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c23:	eb ea                	jmp    800c0f <strlcpy+0x1e>
  800c25:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800c27:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c2a:	29 f0                	sub    %esi,%eax
}
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c30:	f3 0f 1e fb          	endbr32 
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c3d:	0f b6 01             	movzbl (%ecx),%eax
  800c40:	84 c0                	test   %al,%al
  800c42:	74 0c                	je     800c50 <strcmp+0x20>
  800c44:	3a 02                	cmp    (%edx),%al
  800c46:	75 08                	jne    800c50 <strcmp+0x20>
		p++, q++;
  800c48:	83 c1 01             	add    $0x1,%ecx
  800c4b:	83 c2 01             	add    $0x1,%edx
  800c4e:	eb ed                	jmp    800c3d <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c50:	0f b6 c0             	movzbl %al,%eax
  800c53:	0f b6 12             	movzbl (%edx),%edx
  800c56:	29 d0                	sub    %edx,%eax
}
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c5a:	f3 0f 1e fb          	endbr32 
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	53                   	push   %ebx
  800c62:	8b 45 08             	mov    0x8(%ebp),%eax
  800c65:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c68:	89 c3                	mov    %eax,%ebx
  800c6a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c6d:	eb 06                	jmp    800c75 <strncmp+0x1b>
		n--, p++, q++;
  800c6f:	83 c0 01             	add    $0x1,%eax
  800c72:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c75:	39 d8                	cmp    %ebx,%eax
  800c77:	74 16                	je     800c8f <strncmp+0x35>
  800c79:	0f b6 08             	movzbl (%eax),%ecx
  800c7c:	84 c9                	test   %cl,%cl
  800c7e:	74 04                	je     800c84 <strncmp+0x2a>
  800c80:	3a 0a                	cmp    (%edx),%cl
  800c82:	74 eb                	je     800c6f <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c84:	0f b6 00             	movzbl (%eax),%eax
  800c87:	0f b6 12             	movzbl (%edx),%edx
  800c8a:	29 d0                	sub    %edx,%eax
}
  800c8c:	5b                   	pop    %ebx
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    
		return 0;
  800c8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c94:	eb f6                	jmp    800c8c <strncmp+0x32>

00800c96 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c96:	f3 0f 1e fb          	endbr32 
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ca4:	0f b6 10             	movzbl (%eax),%edx
  800ca7:	84 d2                	test   %dl,%dl
  800ca9:	74 09                	je     800cb4 <strchr+0x1e>
		if (*s == c)
  800cab:	38 ca                	cmp    %cl,%dl
  800cad:	74 0a                	je     800cb9 <strchr+0x23>
	for (; *s; s++)
  800caf:	83 c0 01             	add    $0x1,%eax
  800cb2:	eb f0                	jmp    800ca4 <strchr+0xe>
			return (char *) s;
	return 0;
  800cb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cbb:	f3 0f 1e fb          	endbr32 
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cc9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ccc:	38 ca                	cmp    %cl,%dl
  800cce:	74 09                	je     800cd9 <strfind+0x1e>
  800cd0:	84 d2                	test   %dl,%dl
  800cd2:	74 05                	je     800cd9 <strfind+0x1e>
	for (; *s; s++)
  800cd4:	83 c0 01             	add    $0x1,%eax
  800cd7:	eb f0                	jmp    800cc9 <strfind+0xe>
			break;
	return (char *) s;
}
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cdb:	f3 0f 1e fb          	endbr32 
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800ceb:	85 c9                	test   %ecx,%ecx
  800ced:	74 33                	je     800d22 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cef:	89 d0                	mov    %edx,%eax
  800cf1:	09 c8                	or     %ecx,%eax
  800cf3:	a8 03                	test   $0x3,%al
  800cf5:	75 23                	jne    800d1a <memset+0x3f>
		c &= 0xFF;
  800cf7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cfb:	89 d8                	mov    %ebx,%eax
  800cfd:	c1 e0 08             	shl    $0x8,%eax
  800d00:	89 df                	mov    %ebx,%edi
  800d02:	c1 e7 18             	shl    $0x18,%edi
  800d05:	89 de                	mov    %ebx,%esi
  800d07:	c1 e6 10             	shl    $0x10,%esi
  800d0a:	09 f7                	or     %esi,%edi
  800d0c:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800d0e:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d11:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800d13:	89 d7                	mov    %edx,%edi
  800d15:	fc                   	cld    
  800d16:	f3 ab                	rep stos %eax,%es:(%edi)
  800d18:	eb 08                	jmp    800d22 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d1a:	89 d7                	mov    %edx,%edi
  800d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1f:	fc                   	cld    
  800d20:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800d22:	89 d0                	mov    %edx,%eax
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d29:	f3 0f 1e fb          	endbr32 
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	8b 45 08             	mov    0x8(%ebp),%eax
  800d35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d38:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d3b:	39 c6                	cmp    %eax,%esi
  800d3d:	73 32                	jae    800d71 <memmove+0x48>
  800d3f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d42:	39 c2                	cmp    %eax,%edx
  800d44:	76 2b                	jbe    800d71 <memmove+0x48>
		s += n;
		d += n;
  800d46:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d49:	89 fe                	mov    %edi,%esi
  800d4b:	09 ce                	or     %ecx,%esi
  800d4d:	09 d6                	or     %edx,%esi
  800d4f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d55:	75 0e                	jne    800d65 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d57:	83 ef 04             	sub    $0x4,%edi
  800d5a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d5d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d60:	fd                   	std    
  800d61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d63:	eb 09                	jmp    800d6e <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d65:	83 ef 01             	sub    $0x1,%edi
  800d68:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d6b:	fd                   	std    
  800d6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d6e:	fc                   	cld    
  800d6f:	eb 1a                	jmp    800d8b <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d71:	89 c2                	mov    %eax,%edx
  800d73:	09 ca                	or     %ecx,%edx
  800d75:	09 f2                	or     %esi,%edx
  800d77:	f6 c2 03             	test   $0x3,%dl
  800d7a:	75 0a                	jne    800d86 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d7c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d7f:	89 c7                	mov    %eax,%edi
  800d81:	fc                   	cld    
  800d82:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d84:	eb 05                	jmp    800d8b <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800d86:	89 c7                	mov    %eax,%edi
  800d88:	fc                   	cld    
  800d89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d8f:	f3 0f 1e fb          	endbr32 
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d99:	ff 75 10             	pushl  0x10(%ebp)
  800d9c:	ff 75 0c             	pushl  0xc(%ebp)
  800d9f:	ff 75 08             	pushl  0x8(%ebp)
  800da2:	e8 82 ff ff ff       	call   800d29 <memmove>
}
  800da7:	c9                   	leave  
  800da8:	c3                   	ret    

00800da9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800da9:	f3 0f 1e fb          	endbr32 
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
  800db2:	8b 45 08             	mov    0x8(%ebp),%eax
  800db5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db8:	89 c6                	mov    %eax,%esi
  800dba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dbd:	39 f0                	cmp    %esi,%eax
  800dbf:	74 1c                	je     800ddd <memcmp+0x34>
		if (*s1 != *s2)
  800dc1:	0f b6 08             	movzbl (%eax),%ecx
  800dc4:	0f b6 1a             	movzbl (%edx),%ebx
  800dc7:	38 d9                	cmp    %bl,%cl
  800dc9:	75 08                	jne    800dd3 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800dcb:	83 c0 01             	add    $0x1,%eax
  800dce:	83 c2 01             	add    $0x1,%edx
  800dd1:	eb ea                	jmp    800dbd <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800dd3:	0f b6 c1             	movzbl %cl,%eax
  800dd6:	0f b6 db             	movzbl %bl,%ebx
  800dd9:	29 d8                	sub    %ebx,%eax
  800ddb:	eb 05                	jmp    800de2 <memcmp+0x39>
	}

	return 0;
  800ddd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800de6:	f3 0f 1e fb          	endbr32 
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	8b 45 08             	mov    0x8(%ebp),%eax
  800df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800df3:	89 c2                	mov    %eax,%edx
  800df5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800df8:	39 d0                	cmp    %edx,%eax
  800dfa:	73 09                	jae    800e05 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dfc:	38 08                	cmp    %cl,(%eax)
  800dfe:	74 05                	je     800e05 <memfind+0x1f>
	for (; s < ends; s++)
  800e00:	83 c0 01             	add    $0x1,%eax
  800e03:	eb f3                	jmp    800df8 <memfind+0x12>
			break;
	return (void *) s;
}
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e07:	f3 0f 1e fb          	endbr32 
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	57                   	push   %edi
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
  800e11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e17:	eb 03                	jmp    800e1c <strtol+0x15>
		s++;
  800e19:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800e1c:	0f b6 01             	movzbl (%ecx),%eax
  800e1f:	3c 20                	cmp    $0x20,%al
  800e21:	74 f6                	je     800e19 <strtol+0x12>
  800e23:	3c 09                	cmp    $0x9,%al
  800e25:	74 f2                	je     800e19 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800e27:	3c 2b                	cmp    $0x2b,%al
  800e29:	74 2a                	je     800e55 <strtol+0x4e>
	int neg = 0;
  800e2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e30:	3c 2d                	cmp    $0x2d,%al
  800e32:	74 2b                	je     800e5f <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e34:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e3a:	75 0f                	jne    800e4b <strtol+0x44>
  800e3c:	80 39 30             	cmpb   $0x30,(%ecx)
  800e3f:	74 28                	je     800e69 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e41:	85 db                	test   %ebx,%ebx
  800e43:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e48:	0f 44 d8             	cmove  %eax,%ebx
  800e4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e50:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e53:	eb 46                	jmp    800e9b <strtol+0x94>
		s++;
  800e55:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800e58:	bf 00 00 00 00       	mov    $0x0,%edi
  800e5d:	eb d5                	jmp    800e34 <strtol+0x2d>
		s++, neg = 1;
  800e5f:	83 c1 01             	add    $0x1,%ecx
  800e62:	bf 01 00 00 00       	mov    $0x1,%edi
  800e67:	eb cb                	jmp    800e34 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e69:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e6d:	74 0e                	je     800e7d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800e6f:	85 db                	test   %ebx,%ebx
  800e71:	75 d8                	jne    800e4b <strtol+0x44>
		s++, base = 8;
  800e73:	83 c1 01             	add    $0x1,%ecx
  800e76:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e7b:	eb ce                	jmp    800e4b <strtol+0x44>
		s += 2, base = 16;
  800e7d:	83 c1 02             	add    $0x2,%ecx
  800e80:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e85:	eb c4                	jmp    800e4b <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800e87:	0f be d2             	movsbl %dl,%edx
  800e8a:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e8d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e90:	7d 3a                	jge    800ecc <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800e92:	83 c1 01             	add    $0x1,%ecx
  800e95:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e99:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800e9b:	0f b6 11             	movzbl (%ecx),%edx
  800e9e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ea1:	89 f3                	mov    %esi,%ebx
  800ea3:	80 fb 09             	cmp    $0x9,%bl
  800ea6:	76 df                	jbe    800e87 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ea8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800eab:	89 f3                	mov    %esi,%ebx
  800ead:	80 fb 19             	cmp    $0x19,%bl
  800eb0:	77 08                	ja     800eba <strtol+0xb3>
			dig = *s - 'a' + 10;
  800eb2:	0f be d2             	movsbl %dl,%edx
  800eb5:	83 ea 57             	sub    $0x57,%edx
  800eb8:	eb d3                	jmp    800e8d <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800eba:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ebd:	89 f3                	mov    %esi,%ebx
  800ebf:	80 fb 19             	cmp    $0x19,%bl
  800ec2:	77 08                	ja     800ecc <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ec4:	0f be d2             	movsbl %dl,%edx
  800ec7:	83 ea 37             	sub    $0x37,%edx
  800eca:	eb c1                	jmp    800e8d <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ecc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ed0:	74 05                	je     800ed7 <strtol+0xd0>
		*endptr = (char *) s;
  800ed2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ed5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ed7:	89 c2                	mov    %eax,%edx
  800ed9:	f7 da                	neg    %edx
  800edb:	85 ff                	test   %edi,%edi
  800edd:	0f 45 c2             	cmovne %edx,%eax
}
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	57                   	push   %edi
  800ee9:	56                   	push   %esi
  800eea:	53                   	push   %ebx
  800eeb:	83 ec 1c             	sub    $0x1c,%esp
  800eee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ef1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ef4:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800efc:	8b 7d 10             	mov    0x10(%ebp),%edi
  800eff:	8b 75 14             	mov    0x14(%ebp),%esi
  800f02:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f04:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f08:	74 04                	je     800f0e <syscall+0x29>
  800f0a:	85 c0                	test   %eax,%eax
  800f0c:	7f 08                	jg     800f16 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800f0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f11:	5b                   	pop    %ebx
  800f12:	5e                   	pop    %esi
  800f13:	5f                   	pop    %edi
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f16:	83 ec 0c             	sub    $0xc,%esp
  800f19:	50                   	push   %eax
  800f1a:	ff 75 e0             	pushl  -0x20(%ebp)
  800f1d:	68 ff 30 80 00       	push   $0x8030ff
  800f22:	6a 23                	push   $0x23
  800f24:	68 1c 31 80 00       	push   $0x80311c
  800f29:	e8 f2 f5 ff ff       	call   800520 <_panic>

00800f2e <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800f2e:	f3 0f 1e fb          	endbr32 
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f38:	6a 00                	push   $0x0
  800f3a:	6a 00                	push   $0x0
  800f3c:	6a 00                	push   $0x0
  800f3e:	ff 75 0c             	pushl  0xc(%ebp)
  800f41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f44:	ba 00 00 00 00       	mov    $0x0,%edx
  800f49:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4e:	e8 92 ff ff ff       	call   800ee5 <syscall>
}
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	c9                   	leave  
  800f57:	c3                   	ret    

00800f58 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f58:	f3 0f 1e fb          	endbr32 
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f62:	6a 00                	push   $0x0
  800f64:	6a 00                	push   $0x0
  800f66:	6a 00                	push   $0x0
  800f68:	6a 00                	push   $0x0
  800f6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f74:	b8 01 00 00 00       	mov    $0x1,%eax
  800f79:	e8 67 ff ff ff       	call   800ee5 <syscall>
}
  800f7e:	c9                   	leave  
  800f7f:	c3                   	ret    

00800f80 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f80:	f3 0f 1e fb          	endbr32 
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f8a:	6a 00                	push   $0x0
  800f8c:	6a 00                	push   $0x0
  800f8e:	6a 00                	push   $0x0
  800f90:	6a 00                	push   $0x0
  800f92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f95:	ba 01 00 00 00       	mov    $0x1,%edx
  800f9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800f9f:	e8 41 ff ff ff       	call   800ee5 <syscall>
}
  800fa4:	c9                   	leave  
  800fa5:	c3                   	ret    

00800fa6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fa6:	f3 0f 1e fb          	endbr32 
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fb0:	6a 00                	push   $0x0
  800fb2:	6a 00                	push   $0x0
  800fb4:	6a 00                	push   $0x0
  800fb6:	6a 00                	push   $0x0
  800fb8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc2:	b8 02 00 00 00       	mov    $0x2,%eax
  800fc7:	e8 19 ff ff ff       	call   800ee5 <syscall>
}
  800fcc:	c9                   	leave  
  800fcd:	c3                   	ret    

00800fce <sys_yield>:

void
sys_yield(void)
{
  800fce:	f3 0f 1e fb          	endbr32 
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800fd8:	6a 00                	push   $0x0
  800fda:	6a 00                	push   $0x0
  800fdc:	6a 00                	push   $0x0
  800fde:	6a 00                	push   $0x0
  800fe0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fea:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fef:	e8 f1 fe ff ff       	call   800ee5 <syscall>
}
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	c9                   	leave  
  800ff8:	c3                   	ret    

00800ff9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ff9:	f3 0f 1e fb          	endbr32 
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801003:	6a 00                	push   $0x0
  801005:	6a 00                	push   $0x0
  801007:	ff 75 10             	pushl  0x10(%ebp)
  80100a:	ff 75 0c             	pushl  0xc(%ebp)
  80100d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801010:	ba 01 00 00 00       	mov    $0x1,%edx
  801015:	b8 04 00 00 00       	mov    $0x4,%eax
  80101a:	e8 c6 fe ff ff       	call   800ee5 <syscall>
}
  80101f:	c9                   	leave  
  801020:	c3                   	ret    

00801021 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801021:	f3 0f 1e fb          	endbr32 
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80102b:	ff 75 18             	pushl  0x18(%ebp)
  80102e:	ff 75 14             	pushl  0x14(%ebp)
  801031:	ff 75 10             	pushl  0x10(%ebp)
  801034:	ff 75 0c             	pushl  0xc(%ebp)
  801037:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80103a:	ba 01 00 00 00       	mov    $0x1,%edx
  80103f:	b8 05 00 00 00       	mov    $0x5,%eax
  801044:	e8 9c fe ff ff       	call   800ee5 <syscall>
}
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80104b:	f3 0f 1e fb          	endbr32 
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801055:	6a 00                	push   $0x0
  801057:	6a 00                	push   $0x0
  801059:	6a 00                	push   $0x0
  80105b:	ff 75 0c             	pushl  0xc(%ebp)
  80105e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801061:	ba 01 00 00 00       	mov    $0x1,%edx
  801066:	b8 06 00 00 00       	mov    $0x6,%eax
  80106b:	e8 75 fe ff ff       	call   800ee5 <syscall>
}
  801070:	c9                   	leave  
  801071:	c3                   	ret    

00801072 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801072:	f3 0f 1e fb          	endbr32 
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80107c:	6a 00                	push   $0x0
  80107e:	6a 00                	push   $0x0
  801080:	6a 00                	push   $0x0
  801082:	ff 75 0c             	pushl  0xc(%ebp)
  801085:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801088:	ba 01 00 00 00       	mov    $0x1,%edx
  80108d:	b8 08 00 00 00       	mov    $0x8,%eax
  801092:	e8 4e fe ff ff       	call   800ee5 <syscall>
}
  801097:	c9                   	leave  
  801098:	c3                   	ret    

00801099 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801099:	f3 0f 1e fb          	endbr32 
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  8010a3:	6a 00                	push   $0x0
  8010a5:	6a 00                	push   $0x0
  8010a7:	6a 00                	push   $0x0
  8010a9:	ff 75 0c             	pushl  0xc(%ebp)
  8010ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010af:	ba 01 00 00 00       	mov    $0x1,%edx
  8010b4:	b8 09 00 00 00       	mov    $0x9,%eax
  8010b9:	e8 27 fe ff ff       	call   800ee5 <syscall>
}
  8010be:	c9                   	leave  
  8010bf:	c3                   	ret    

008010c0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010c0:	f3 0f 1e fb          	endbr32 
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8010ca:	6a 00                	push   $0x0
  8010cc:	6a 00                	push   $0x0
  8010ce:	6a 00                	push   $0x0
  8010d0:	ff 75 0c             	pushl  0xc(%ebp)
  8010d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d6:	ba 01 00 00 00       	mov    $0x1,%edx
  8010db:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010e0:	e8 00 fe ff ff       	call   800ee5 <syscall>
}
  8010e5:	c9                   	leave  
  8010e6:	c3                   	ret    

008010e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010e7:	f3 0f 1e fb          	endbr32 
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8010f1:	6a 00                	push   $0x0
  8010f3:	ff 75 14             	pushl  0x14(%ebp)
  8010f6:	ff 75 10             	pushl  0x10(%ebp)
  8010f9:	ff 75 0c             	pushl  0xc(%ebp)
  8010fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801104:	b8 0c 00 00 00       	mov    $0xc,%eax
  801109:	e8 d7 fd ff ff       	call   800ee5 <syscall>
}
  80110e:	c9                   	leave  
  80110f:	c3                   	ret    

00801110 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801110:	f3 0f 1e fb          	endbr32 
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80111a:	6a 00                	push   $0x0
  80111c:	6a 00                	push   $0x0
  80111e:	6a 00                	push   $0x0
  801120:	6a 00                	push   $0x0
  801122:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801125:	ba 01 00 00 00       	mov    $0x1,%edx
  80112a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80112f:	e8 b1 fd ff ff       	call   800ee5 <syscall>
}
  801134:	c9                   	leave  
  801135:	c3                   	ret    

00801136 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	53                   	push   %ebx
  80113a:	83 ec 04             	sub    $0x4,%esp
	int r;

	// LAB 4: Your code here.
	void *addr = (void *) (pn * PGSIZE);
  80113d:	89 d3                	mov    %edx,%ebx
  80113f:	c1 e3 0c             	shl    $0xc,%ebx

	if (uvpt[pn] & PTE_SHARE) {
  801142:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801149:	f6 c5 04             	test   $0x4,%ch
  80114c:	75 56                	jne    8011a4 <duppage+0x6e>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
		return 0;
	}

	if ((uvpt[pn] & (PTE_W | PTE_COW)) != 0) {
  80114e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801155:	f7 c2 02 08 00 00    	test   $0x802,%edx
  80115b:	74 72                	je     8011cf <duppage+0x99>
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW) <
  80115d:	83 ec 0c             	sub    $0xc,%esp
  801160:	68 05 08 00 00       	push   $0x805
  801165:	53                   	push   %ebx
  801166:	50                   	push   %eax
  801167:	53                   	push   %ebx
  801168:	6a 00                	push   $0x0
  80116a:	e8 b2 fe ff ff       	call   801021 <sys_page_map>
  80116f:	83 c4 20             	add    $0x20,%esp
  801172:	85 c0                	test   %eax,%eax
  801174:	78 45                	js     8011bb <duppage+0x85>
		    0) {
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
		}
		if (sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW) < 0) {
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	68 05 08 00 00       	push   $0x805
  80117e:	53                   	push   %ebx
  80117f:	6a 00                	push   $0x0
  801181:	53                   	push   %ebx
  801182:	6a 00                	push   $0x0
  801184:	e8 98 fe ff ff       	call   801021 <sys_page_map>
  801189:	83 c4 20             	add    $0x20,%esp
  80118c:	85 c0                	test   %eax,%eax
  80118e:	79 55                	jns    8011e5 <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP FATHER");
  801190:	83 ec 04             	sub    $0x4,%esp
  801193:	68 4c 31 80 00       	push   $0x80314c
  801198:	6a 54                	push   $0x54
  80119a:	68 df 31 80 00       	push   $0x8031df
  80119f:	e8 7c f3 ff ff       	call   800520 <_panic>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  8011a4:	83 ec 0c             	sub    $0xc,%esp
  8011a7:	68 07 0e 00 00       	push   $0xe07
  8011ac:	53                   	push   %ebx
  8011ad:	50                   	push   %eax
  8011ae:	53                   	push   %ebx
  8011af:	6a 00                	push   $0x0
  8011b1:	e8 6b fe ff ff       	call   801021 <sys_page_map>
		return 0;
  8011b6:	83 c4 20             	add    $0x20,%esp
  8011b9:	eb 2a                	jmp    8011e5 <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
  8011bb:	83 ec 04             	sub    $0x4,%esp
  8011be:	68 2c 31 80 00       	push   $0x80312c
  8011c3:	6a 51                	push   $0x51
  8011c5:	68 df 31 80 00       	push   $0x8031df
  8011ca:	e8 51 f3 ff ff       	call   800520 <_panic>
		}
	} else {
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U) < 0) {
  8011cf:	83 ec 0c             	sub    $0xc,%esp
  8011d2:	6a 05                	push   $0x5
  8011d4:	53                   	push   %ebx
  8011d5:	50                   	push   %eax
  8011d6:	53                   	push   %ebx
  8011d7:	6a 00                	push   $0x0
  8011d9:	e8 43 fe ff ff       	call   801021 <sys_page_map>
  8011de:	83 c4 20             	add    $0x20,%esp
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	78 0a                	js     8011ef <duppage+0xb9>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
		}
	}

	return 0;
}
  8011e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ed:	c9                   	leave  
  8011ee:	c3                   	ret    
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
  8011ef:	83 ec 04             	sub    $0x4,%esp
  8011f2:	68 ea 31 80 00       	push   $0x8031ea
  8011f7:	6a 58                	push   $0x58
  8011f9:	68 df 31 80 00       	push   $0x8031df
  8011fe:	e8 1d f3 ff ff       	call   800520 <_panic>

00801203 <dup_or_share>:

static void
dup_or_share(envid_t dstenv, void *va, int perm)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	56                   	push   %esi
  801207:	53                   	push   %ebx
  801208:	89 c6                	mov    %eax,%esi
  80120a:	89 d3                	mov    %edx,%ebx
	int r;
	if (perm & PTE_W) {
  80120c:	f6 c1 02             	test   $0x2,%cl
  80120f:	0f 84 8c 00 00 00    	je     8012a1 <dup_or_share+0x9e>
		// dup
		if ((r = sys_page_alloc(dstenv, va, PTE_P | PTE_U | PTE_W)) < 0)
  801215:	83 ec 04             	sub    $0x4,%esp
  801218:	6a 07                	push   $0x7
  80121a:	52                   	push   %edx
  80121b:	50                   	push   %eax
  80121c:	e8 d8 fd ff ff       	call   800ff9 <sys_page_alloc>
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	85 c0                	test   %eax,%eax
  801226:	78 55                	js     80127d <dup_or_share+0x7a>
			panic("sys_page_alloc: %e", r);
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  801228:	83 ec 0c             	sub    $0xc,%esp
  80122b:	6a 07                	push   $0x7
  80122d:	68 00 00 40 00       	push   $0x400000
  801232:	6a 00                	push   $0x0
  801234:	53                   	push   %ebx
  801235:	56                   	push   %esi
  801236:	e8 e6 fd ff ff       	call   801021 <sys_page_map>
  80123b:	83 c4 20             	add    $0x20,%esp
  80123e:	85 c0                	test   %eax,%eax
  801240:	78 4d                	js     80128f <dup_or_share+0x8c>
		    0)
			panic("sys_page_map: %e", r);
		memmove(UTEMP, va, PGSIZE);
  801242:	83 ec 04             	sub    $0x4,%esp
  801245:	68 00 10 00 00       	push   $0x1000
  80124a:	53                   	push   %ebx
  80124b:	68 00 00 40 00       	push   $0x400000
  801250:	e8 d4 fa ff ff       	call   800d29 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801255:	83 c4 08             	add    $0x8,%esp
  801258:	68 00 00 40 00       	push   $0x400000
  80125d:	6a 00                	push   $0x0
  80125f:	e8 e7 fd ff ff       	call   80104b <sys_page_unmap>
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	79 52                	jns    8012bd <dup_or_share+0xba>
			panic("sys_page_unmap: %e", r);
  80126b:	50                   	push   %eax
  80126c:	68 2a 32 80 00       	push   $0x80322a
  801271:	6a 6c                	push   $0x6c
  801273:	68 df 31 80 00       	push   $0x8031df
  801278:	e8 a3 f2 ff ff       	call   800520 <_panic>
			panic("sys_page_alloc: %e", r);
  80127d:	50                   	push   %eax
  80127e:	68 06 32 80 00       	push   $0x803206
  801283:	6a 66                	push   $0x66
  801285:	68 df 31 80 00       	push   $0x8031df
  80128a:	e8 91 f2 ff ff       	call   800520 <_panic>
			panic("sys_page_map: %e", r);
  80128f:	50                   	push   %eax
  801290:	68 19 32 80 00       	push   $0x803219
  801295:	6a 69                	push   $0x69
  801297:	68 df 31 80 00       	push   $0x8031df
  80129c:	e8 7f f2 ff ff       	call   800520 <_panic>

	} else {
		// share
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | perm)) <
  8012a1:	83 ec 0c             	sub    $0xc,%esp
  8012a4:	83 c9 05             	or     $0x5,%ecx
  8012a7:	51                   	push   %ecx
  8012a8:	68 00 00 40 00       	push   $0x400000
  8012ad:	6a 00                	push   $0x0
  8012af:	52                   	push   %edx
  8012b0:	50                   	push   %eax
  8012b1:	e8 6b fd ff ff       	call   801021 <sys_page_map>
  8012b6:	83 c4 20             	add    $0x20,%esp
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	78 07                	js     8012c4 <dup_or_share+0xc1>
		    0)
			panic("sys_page_map: %e", r);
	}
}
  8012bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    
			panic("sys_page_map: %e", r);
  8012c4:	50                   	push   %eax
  8012c5:	68 19 32 80 00       	push   $0x803219
  8012ca:	6a 72                	push   $0x72
  8012cc:	68 df 31 80 00       	push   $0x8031df
  8012d1:	e8 4a f2 ff ff       	call   800520 <_panic>

008012d6 <pgfault>:
{
  8012d6:	f3 0f 1e fb          	endbr32 
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	53                   	push   %ebx
  8012de:	83 ec 04             	sub    $0x4,%esp
  8012e1:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  8012e4:	8b 02                	mov    (%edx),%eax
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  8012e6:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  8012ea:	0f 84 95 00 00 00    	je     801385 <pgfault+0xaf>
  8012f0:	89 c2                	mov    %eax,%edx
  8012f2:	c1 ea 16             	shr    $0x16,%edx
  8012f5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012fc:	f6 c2 01             	test   $0x1,%dl
  8012ff:	0f 84 80 00 00 00    	je     801385 <pgfault+0xaf>
	    (~uvpt[PGNUM(addr)] & (PTE_COW | PTE_P)) != 0) {
  801305:	89 c2                	mov    %eax,%edx
  801307:	c1 ea 0c             	shr    $0xc,%edx
  80130a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801311:	f7 d2                	not    %edx
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  801313:	f7 c2 01 08 00 00    	test   $0x801,%edx
  801319:	75 6a                	jne    801385 <pgfault+0xaf>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  80131b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801320:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U) < 0) {
  801322:	83 ec 04             	sub    $0x4,%esp
  801325:	6a 07                	push   $0x7
  801327:	68 00 f0 7f 00       	push   $0x7ff000
  80132c:	6a 00                	push   $0x0
  80132e:	e8 c6 fc ff ff       	call   800ff9 <sys_page_alloc>
  801333:	83 c4 10             	add    $0x10,%esp
  801336:	85 c0                	test   %eax,%eax
  801338:	78 5f                	js     801399 <pgfault+0xc3>
	memcpy((void *) PFTEMP, addr, PGSIZE);
  80133a:	83 ec 04             	sub    $0x4,%esp
  80133d:	68 00 10 00 00       	push   $0x1000
  801342:	53                   	push   %ebx
  801343:	68 00 f0 7f 00       	push   $0x7ff000
  801348:	e8 42 fa ff ff       	call   800d8f <memcpy>
	if (sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U) < 0) {
  80134d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801354:	53                   	push   %ebx
  801355:	6a 00                	push   $0x0
  801357:	68 00 f0 7f 00       	push   $0x7ff000
  80135c:	6a 00                	push   $0x0
  80135e:	e8 be fc ff ff       	call   801021 <sys_page_map>
  801363:	83 c4 20             	add    $0x20,%esp
  801366:	85 c0                	test   %eax,%eax
  801368:	78 43                	js     8013ad <pgfault+0xd7>
	if (sys_page_unmap(0, (void *) PFTEMP) < 0) {
  80136a:	83 ec 08             	sub    $0x8,%esp
  80136d:	68 00 f0 7f 00       	push   $0x7ff000
  801372:	6a 00                	push   $0x0
  801374:	e8 d2 fc ff ff       	call   80104b <sys_page_unmap>
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 41                	js     8013c1 <pgfault+0xeb>
}
  801380:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801383:	c9                   	leave  
  801384:	c3                   	ret    
		panic("ERROR PGFAULT");
  801385:	83 ec 04             	sub    $0x4,%esp
  801388:	68 3d 32 80 00       	push   $0x80323d
  80138d:	6a 1e                	push   $0x1e
  80138f:	68 df 31 80 00       	push   $0x8031df
  801394:	e8 87 f1 ff ff       	call   800520 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_ALLOC");
  801399:	83 ec 04             	sub    $0x4,%esp
  80139c:	68 4b 32 80 00       	push   $0x80324b
  8013a1:	6a 2b                	push   $0x2b
  8013a3:	68 df 31 80 00       	push   $0x8031df
  8013a8:	e8 73 f1 ff ff       	call   800520 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_MAP");
  8013ad:	83 ec 04             	sub    $0x4,%esp
  8013b0:	68 69 32 80 00       	push   $0x803269
  8013b5:	6a 2f                	push   $0x2f
  8013b7:	68 df 31 80 00       	push   $0x8031df
  8013bc:	e8 5f f1 ff ff       	call   800520 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_UNMAP");
  8013c1:	83 ec 04             	sub    $0x4,%esp
  8013c4:	68 85 32 80 00       	push   $0x803285
  8013c9:	6a 32                	push   $0x32
  8013cb:	68 df 31 80 00       	push   $0x8031df
  8013d0:	e8 4b f1 ff ff       	call   800520 <_panic>

008013d5 <fork_v0>:

envid_t
fork_v0(void)
{
  8013d5:	f3 0f 1e fb          	endbr32 
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	57                   	push   %edi
  8013dd:	56                   	push   %esi
  8013de:	53                   	push   %ebx
  8013df:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8013e2:	b8 07 00 00 00       	mov    $0x7,%eax
  8013e7:	cd 30                	int    $0x30
	envid_t env_id = sys_exofork();
	if (env_id < 0) {
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	78 24                	js     801411 <fork_v0+0x3c>
  8013ed:	89 c6                	mov    %eax,%esi
  8013ef:	89 c7                	mov    %eax,%edi
		thisenv = envs + ENVX(sys_getenvid());
		return env_id;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  8013f1:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (env_id == 0) {  // Son
  8013f6:	75 51                	jne    801449 <fork_v0+0x74>
		thisenv = envs + ENVX(sys_getenvid());
  8013f8:	e8 a9 fb ff ff       	call   800fa6 <sys_getenvid>
  8013fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  801402:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801405:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80140a:	a3 04 50 80 00       	mov    %eax,0x805004
		return env_id;
  80140f:	eb 78                	jmp    801489 <fork_v0+0xb4>
		panic("ERROR ON FORK_V0");
  801411:	83 ec 04             	sub    $0x4,%esp
  801414:	68 a3 32 80 00       	push   $0x8032a3
  801419:	6a 7b                	push   $0x7b
  80141b:	68 df 31 80 00       	push   $0x8031df
  801420:	e8 fb f0 ff ff       	call   800520 <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
				dup_or_share(env_id,
  801425:	b9 07 00 00 00       	mov    $0x7,%ecx
  80142a:	89 da                	mov    %ebx,%edx
  80142c:	89 f8                	mov    %edi,%eax
  80142e:	e8 d0 fd ff ff       	call   801203 <dup_or_share>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801433:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801439:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  80143f:	77 36                	ja     801477 <fork_v0+0xa2>
		if (addr != UXSTACKTOP - PGSIZE) {
  801441:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801447:	74 ea                	je     801433 <fork_v0+0x5e>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801449:	89 d8                	mov    %ebx,%eax
  80144b:	c1 e8 16             	shr    $0x16,%eax
  80144e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801455:	a8 01                	test   $0x1,%al
  801457:	74 da                	je     801433 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  801459:	89 d8                	mov    %ebx,%eax
  80145b:	c1 e8 0c             	shr    $0xc,%eax
  80145e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801465:	f6 c2 01             	test   $0x1,%dl
  801468:	74 c9                	je     801433 <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
  80146a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  801471:	a8 04                	test   $0x4,%al
  801473:	74 be                	je     801433 <fork_v0+0x5e>
  801475:	eb ae                	jmp    801425 <fork_v0+0x50>
				             PTE_P | PTE_U | PTE_W);
			}
		}
	}

	if (sys_env_set_status(env_id, ENV_RUNNABLE) < 0) {
  801477:	83 ec 08             	sub    $0x8,%esp
  80147a:	6a 02                	push   $0x2
  80147c:	56                   	push   %esi
  80147d:	e8 f0 fb ff ff       	call   801072 <sys_env_set_status>
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	85 c0                	test   %eax,%eax
  801487:	78 0a                	js     801493 <fork_v0+0xbe>
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
	}

	return env_id;
}
  801489:	89 f0                	mov    %esi,%eax
  80148b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80148e:	5b                   	pop    %ebx
  80148f:	5e                   	pop    %esi
  801490:	5f                   	pop    %edi
  801491:	5d                   	pop    %ebp
  801492:	c3                   	ret    
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
  801493:	83 ec 04             	sub    $0x4,%esp
  801496:	68 70 31 80 00       	push   $0x803170
  80149b:	68 92 00 00 00       	push   $0x92
  8014a0:	68 df 31 80 00       	push   $0x8031df
  8014a5:	e8 76 f0 ff ff       	call   800520 <_panic>

008014aa <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8014aa:	f3 0f 1e fb          	endbr32 
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	57                   	push   %edi
  8014b2:	56                   	push   %esi
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 18             	sub    $0x18,%esp
	// return fork_v0(); // Uncomment this line if you want to run fork_v0.
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8014b7:	68 d6 12 80 00       	push   $0x8012d6
  8014bc:	e8 71 13 00 00       	call   802832 <set_pgfault_handler>
  8014c1:	b8 07 00 00 00       	mov    $0x7,%eax
  8014c6:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0) {
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 27                	js     8014f6 <fork+0x4c>
  8014cf:	89 c7                	mov    %eax,%edi
  8014d1:	89 c6                	mov    %eax,%esi
		thisenv = envs + ENVX(sys_getenvid());
		return envid;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  8014d3:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else if (envid == 0) {  // Son
  8014d8:	75 55                	jne    80152f <fork+0x85>
		thisenv = envs + ENVX(sys_getenvid());
  8014da:	e8 c7 fa ff ff       	call   800fa6 <sys_getenvid>
  8014df:	25 ff 03 00 00       	and    $0x3ff,%eax
  8014e4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8014e7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8014ec:	a3 04 50 80 00       	mov    %eax,0x805004
		return envid;
  8014f1:	e9 9b 00 00 00       	jmp    801591 <fork+0xe7>
		panic("ERROR IN FORK: SYS_EXOFORK");
  8014f6:	83 ec 04             	sub    $0x4,%esp
  8014f9:	68 b4 32 80 00       	push   $0x8032b4
  8014fe:	68 b1 00 00 00       	push   $0xb1
  801503:	68 df 31 80 00       	push   $0x8031df
  801508:	e8 13 f0 ff ff       	call   800520 <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
				duppage(envid, addr / PGSIZE);
  80150d:	89 da                	mov    %ebx,%edx
  80150f:	c1 ea 0c             	shr    $0xc,%edx
  801512:	89 f0                	mov    %esi,%eax
  801514:	e8 1d fc ff ff       	call   801136 <duppage>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801519:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80151f:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801525:	77 2c                	ja     801553 <fork+0xa9>
		if (addr != UXSTACKTOP - PGSIZE) {
  801527:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80152d:	74 ea                	je     801519 <fork+0x6f>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80152f:	89 d8                	mov    %ebx,%eax
  801531:	c1 e8 16             	shr    $0x16,%eax
  801534:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80153b:	a8 01                	test   $0x1,%al
  80153d:	74 da                	je     801519 <fork+0x6f>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
  80153f:	89 d8                	mov    %ebx,%eax
  801541:	c1 e8 0c             	shr    $0xc,%eax
  801544:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80154b:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80154d:	a8 05                	test   $0x5,%al
  80154f:	75 c8                	jne    801519 <fork+0x6f>
  801551:	eb ba                	jmp    80150d <fork+0x63>
			}
		}
	}

	if (sys_page_alloc(envid,
  801553:	83 ec 04             	sub    $0x4,%esp
  801556:	6a 07                	push   $0x7
  801558:	68 00 f0 bf ee       	push   $0xeebff000
  80155d:	57                   	push   %edi
  80155e:	e8 96 fa ff ff       	call   800ff9 <sys_page_alloc>
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	85 c0                	test   %eax,%eax
  801568:	78 31                	js     80159b <fork+0xf1>
	                   PTE_P | PTE_U | PTE_W) < 0) {
		panic("ERROR FORK: SYS_PAGE_ALLOC");
	}

	extern void _pgfault_upcall(void);
	if (sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0) {
  80156a:	83 ec 08             	sub    $0x8,%esp
  80156d:	68 a5 28 80 00       	push   $0x8028a5
  801572:	57                   	push   %edi
  801573:	e8 48 fb ff ff       	call   8010c0 <sys_env_set_pgfault_upcall>
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 33                	js     8015b2 <fork+0x108>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
	}

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0) {
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	6a 02                	push   $0x2
  801584:	57                   	push   %edi
  801585:	e8 e8 fa ff ff       	call   801072 <sys_env_set_status>
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 38                	js     8015c9 <fork+0x11f>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
	}

	return envid;
}
  801591:	89 f8                	mov    %edi,%eax
  801593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801596:	5b                   	pop    %ebx
  801597:	5e                   	pop    %esi
  801598:	5f                   	pop    %edi
  801599:	5d                   	pop    %ebp
  80159a:	c3                   	ret    
		panic("ERROR FORK: SYS_PAGE_ALLOC");
  80159b:	83 ec 04             	sub    $0x4,%esp
  80159e:	68 cf 32 80 00       	push   $0x8032cf
  8015a3:	68 c4 00 00 00       	push   $0xc4
  8015a8:	68 df 31 80 00       	push   $0x8031df
  8015ad:	e8 6e ef ff ff       	call   800520 <_panic>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
  8015b2:	83 ec 04             	sub    $0x4,%esp
  8015b5:	68 98 31 80 00       	push   $0x803198
  8015ba:	68 c9 00 00 00       	push   $0xc9
  8015bf:	68 df 31 80 00       	push   $0x8031df
  8015c4:	e8 57 ef ff ff       	call   800520 <_panic>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
  8015c9:	83 ec 04             	sub    $0x4,%esp
  8015cc:	68 c0 31 80 00       	push   $0x8031c0
  8015d1:	68 cd 00 00 00       	push   $0xcd
  8015d6:	68 df 31 80 00       	push   $0x8031df
  8015db:	e8 40 ef ff ff       	call   800520 <_panic>

008015e0 <sfork>:

// Challenge!
int
sfork(void)
{
  8015e0:	f3 0f 1e fb          	endbr32 
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8015ea:	68 ea 32 80 00       	push   $0x8032ea
  8015ef:	68 d7 00 00 00       	push   $0xd7
  8015f4:	68 df 31 80 00       	push   $0x8031df
  8015f9:	e8 22 ef ff ff       	call   800520 <_panic>

008015fe <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8015fe:	f3 0f 1e fb          	endbr32 
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801605:	8b 45 08             	mov    0x8(%ebp),%eax
  801608:	05 00 00 00 30       	add    $0x30000000,%eax
  80160d:	c1 e8 0c             	shr    $0xc,%eax
}
  801610:	5d                   	pop    %ebp
  801611:	c3                   	ret    

00801612 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801612:	f3 0f 1e fb          	endbr32 
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  80161c:	ff 75 08             	pushl  0x8(%ebp)
  80161f:	e8 da ff ff ff       	call   8015fe <fd2num>
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	c1 e0 0c             	shl    $0xc,%eax
  80162a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80162f:	c9                   	leave  
  801630:	c3                   	ret    

00801631 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801631:	f3 0f 1e fb          	endbr32 
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80163d:	89 c2                	mov    %eax,%edx
  80163f:	c1 ea 16             	shr    $0x16,%edx
  801642:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801649:	f6 c2 01             	test   $0x1,%dl
  80164c:	74 2d                	je     80167b <fd_alloc+0x4a>
  80164e:	89 c2                	mov    %eax,%edx
  801650:	c1 ea 0c             	shr    $0xc,%edx
  801653:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80165a:	f6 c2 01             	test   $0x1,%dl
  80165d:	74 1c                	je     80167b <fd_alloc+0x4a>
  80165f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801664:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801669:	75 d2                	jne    80163d <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80166b:	8b 45 08             	mov    0x8(%ebp),%eax
  80166e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801674:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801679:	eb 0a                	jmp    801685 <fd_alloc+0x54>
			*fd_store = fd;
  80167b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80167e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801680:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801687:	f3 0f 1e fb          	endbr32 
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801691:	83 f8 1f             	cmp    $0x1f,%eax
  801694:	77 30                	ja     8016c6 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801696:	c1 e0 0c             	shl    $0xc,%eax
  801699:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80169e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8016a4:	f6 c2 01             	test   $0x1,%dl
  8016a7:	74 24                	je     8016cd <fd_lookup+0x46>
  8016a9:	89 c2                	mov    %eax,%edx
  8016ab:	c1 ea 0c             	shr    $0xc,%edx
  8016ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016b5:	f6 c2 01             	test   $0x1,%dl
  8016b8:	74 1a                	je     8016d4 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016bd:	89 02                	mov    %eax,(%edx)
	return 0;
  8016bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c4:	5d                   	pop    %ebp
  8016c5:	c3                   	ret    
		return -E_INVAL;
  8016c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016cb:	eb f7                	jmp    8016c4 <fd_lookup+0x3d>
		return -E_INVAL;
  8016cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d2:	eb f0                	jmp    8016c4 <fd_lookup+0x3d>
  8016d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d9:	eb e9                	jmp    8016c4 <fd_lookup+0x3d>

008016db <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016db:	f3 0f 1e fb          	endbr32 
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	83 ec 08             	sub    $0x8,%esp
  8016e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e8:	ba 7c 33 80 00       	mov    $0x80337c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8016ed:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8016f2:	39 08                	cmp    %ecx,(%eax)
  8016f4:	74 33                	je     801729 <dev_lookup+0x4e>
  8016f6:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8016f9:	8b 02                	mov    (%edx),%eax
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	75 f3                	jne    8016f2 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8016ff:	a1 04 50 80 00       	mov    0x805004,%eax
  801704:	8b 40 48             	mov    0x48(%eax),%eax
  801707:	83 ec 04             	sub    $0x4,%esp
  80170a:	51                   	push   %ecx
  80170b:	50                   	push   %eax
  80170c:	68 00 33 80 00       	push   $0x803300
  801711:	e8 f1 ee ff ff       	call   800607 <cprintf>
	*dev = 0;
  801716:	8b 45 0c             	mov    0xc(%ebp),%eax
  801719:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801727:	c9                   	leave  
  801728:	c3                   	ret    
			*dev = devtab[i];
  801729:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80172e:	b8 00 00 00 00       	mov    $0x0,%eax
  801733:	eb f2                	jmp    801727 <dev_lookup+0x4c>

00801735 <fd_close>:
{
  801735:	f3 0f 1e fb          	endbr32 
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	57                   	push   %edi
  80173d:	56                   	push   %esi
  80173e:	53                   	push   %ebx
  80173f:	83 ec 28             	sub    $0x28,%esp
  801742:	8b 75 08             	mov    0x8(%ebp),%esi
  801745:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801748:	56                   	push   %esi
  801749:	e8 b0 fe ff ff       	call   8015fe <fd2num>
  80174e:	83 c4 08             	add    $0x8,%esp
  801751:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801754:	52                   	push   %edx
  801755:	50                   	push   %eax
  801756:	e8 2c ff ff ff       	call   801687 <fd_lookup>
  80175b:	89 c3                	mov    %eax,%ebx
  80175d:	83 c4 10             	add    $0x10,%esp
  801760:	85 c0                	test   %eax,%eax
  801762:	78 05                	js     801769 <fd_close+0x34>
	    || fd != fd2)
  801764:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801767:	74 16                	je     80177f <fd_close+0x4a>
		return (must_exist ? r : 0);
  801769:	89 f8                	mov    %edi,%eax
  80176b:	84 c0                	test   %al,%al
  80176d:	b8 00 00 00 00       	mov    $0x0,%eax
  801772:	0f 44 d8             	cmove  %eax,%ebx
}
  801775:	89 d8                	mov    %ebx,%eax
  801777:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80177a:	5b                   	pop    %ebx
  80177b:	5e                   	pop    %esi
  80177c:	5f                   	pop    %edi
  80177d:	5d                   	pop    %ebp
  80177e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80177f:	83 ec 08             	sub    $0x8,%esp
  801782:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801785:	50                   	push   %eax
  801786:	ff 36                	pushl  (%esi)
  801788:	e8 4e ff ff ff       	call   8016db <dev_lookup>
  80178d:	89 c3                	mov    %eax,%ebx
  80178f:	83 c4 10             	add    $0x10,%esp
  801792:	85 c0                	test   %eax,%eax
  801794:	78 1a                	js     8017b0 <fd_close+0x7b>
		if (dev->dev_close)
  801796:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801799:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80179c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	74 0b                	je     8017b0 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8017a5:	83 ec 0c             	sub    $0xc,%esp
  8017a8:	56                   	push   %esi
  8017a9:	ff d0                	call   *%eax
  8017ab:	89 c3                	mov    %eax,%ebx
  8017ad:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8017b0:	83 ec 08             	sub    $0x8,%esp
  8017b3:	56                   	push   %esi
  8017b4:	6a 00                	push   $0x0
  8017b6:	e8 90 f8 ff ff       	call   80104b <sys_page_unmap>
	return r;
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	eb b5                	jmp    801775 <fd_close+0x40>

008017c0 <close>:

int
close(int fdnum)
{
  8017c0:	f3 0f 1e fb          	endbr32 
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017cd:	50                   	push   %eax
  8017ce:	ff 75 08             	pushl  0x8(%ebp)
  8017d1:	e8 b1 fe ff ff       	call   801687 <fd_lookup>
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	85 c0                	test   %eax,%eax
  8017db:	79 02                	jns    8017df <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8017dd:	c9                   	leave  
  8017de:	c3                   	ret    
		return fd_close(fd, 1);
  8017df:	83 ec 08             	sub    $0x8,%esp
  8017e2:	6a 01                	push   $0x1
  8017e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e7:	e8 49 ff ff ff       	call   801735 <fd_close>
  8017ec:	83 c4 10             	add    $0x10,%esp
  8017ef:	eb ec                	jmp    8017dd <close+0x1d>

008017f1 <close_all>:

void
close_all(void)
{
  8017f1:	f3 0f 1e fb          	endbr32 
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	53                   	push   %ebx
  8017f9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8017fc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801801:	83 ec 0c             	sub    $0xc,%esp
  801804:	53                   	push   %ebx
  801805:	e8 b6 ff ff ff       	call   8017c0 <close>
	for (i = 0; i < MAXFD; i++)
  80180a:	83 c3 01             	add    $0x1,%ebx
  80180d:	83 c4 10             	add    $0x10,%esp
  801810:	83 fb 20             	cmp    $0x20,%ebx
  801813:	75 ec                	jne    801801 <close_all+0x10>
}
  801815:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80181a:	f3 0f 1e fb          	endbr32 
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	57                   	push   %edi
  801822:	56                   	push   %esi
  801823:	53                   	push   %ebx
  801824:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801827:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80182a:	50                   	push   %eax
  80182b:	ff 75 08             	pushl  0x8(%ebp)
  80182e:	e8 54 fe ff ff       	call   801687 <fd_lookup>
  801833:	89 c3                	mov    %eax,%ebx
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	85 c0                	test   %eax,%eax
  80183a:	0f 88 81 00 00 00    	js     8018c1 <dup+0xa7>
		return r;
	close(newfdnum);
  801840:	83 ec 0c             	sub    $0xc,%esp
  801843:	ff 75 0c             	pushl  0xc(%ebp)
  801846:	e8 75 ff ff ff       	call   8017c0 <close>

	newfd = INDEX2FD(newfdnum);
  80184b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80184e:	c1 e6 0c             	shl    $0xc,%esi
  801851:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801857:	83 c4 04             	add    $0x4,%esp
  80185a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80185d:	e8 b0 fd ff ff       	call   801612 <fd2data>
  801862:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801864:	89 34 24             	mov    %esi,(%esp)
  801867:	e8 a6 fd ff ff       	call   801612 <fd2data>
  80186c:	83 c4 10             	add    $0x10,%esp
  80186f:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801871:	89 d8                	mov    %ebx,%eax
  801873:	c1 e8 16             	shr    $0x16,%eax
  801876:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80187d:	a8 01                	test   $0x1,%al
  80187f:	74 11                	je     801892 <dup+0x78>
  801881:	89 d8                	mov    %ebx,%eax
  801883:	c1 e8 0c             	shr    $0xc,%eax
  801886:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80188d:	f6 c2 01             	test   $0x1,%dl
  801890:	75 39                	jne    8018cb <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801892:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801895:	89 d0                	mov    %edx,%eax
  801897:	c1 e8 0c             	shr    $0xc,%eax
  80189a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018a1:	83 ec 0c             	sub    $0xc,%esp
  8018a4:	25 07 0e 00 00       	and    $0xe07,%eax
  8018a9:	50                   	push   %eax
  8018aa:	56                   	push   %esi
  8018ab:	6a 00                	push   $0x0
  8018ad:	52                   	push   %edx
  8018ae:	6a 00                	push   $0x0
  8018b0:	e8 6c f7 ff ff       	call   801021 <sys_page_map>
  8018b5:	89 c3                	mov    %eax,%ebx
  8018b7:	83 c4 20             	add    $0x20,%esp
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 31                	js     8018ef <dup+0xd5>
		goto err;

	return newfdnum;
  8018be:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8018c1:	89 d8                	mov    %ebx,%eax
  8018c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c6:	5b                   	pop    %ebx
  8018c7:	5e                   	pop    %esi
  8018c8:	5f                   	pop    %edi
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8018cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018d2:	83 ec 0c             	sub    $0xc,%esp
  8018d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8018da:	50                   	push   %eax
  8018db:	57                   	push   %edi
  8018dc:	6a 00                	push   $0x0
  8018de:	53                   	push   %ebx
  8018df:	6a 00                	push   $0x0
  8018e1:	e8 3b f7 ff ff       	call   801021 <sys_page_map>
  8018e6:	89 c3                	mov    %eax,%ebx
  8018e8:	83 c4 20             	add    $0x20,%esp
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	79 a3                	jns    801892 <dup+0x78>
	sys_page_unmap(0, newfd);
  8018ef:	83 ec 08             	sub    $0x8,%esp
  8018f2:	56                   	push   %esi
  8018f3:	6a 00                	push   $0x0
  8018f5:	e8 51 f7 ff ff       	call   80104b <sys_page_unmap>
	sys_page_unmap(0, nva);
  8018fa:	83 c4 08             	add    $0x8,%esp
  8018fd:	57                   	push   %edi
  8018fe:	6a 00                	push   $0x0
  801900:	e8 46 f7 ff ff       	call   80104b <sys_page_unmap>
	return r;
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	eb b7                	jmp    8018c1 <dup+0xa7>

0080190a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80190a:	f3 0f 1e fb          	endbr32 
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	53                   	push   %ebx
  801912:	83 ec 1c             	sub    $0x1c,%esp
  801915:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801918:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80191b:	50                   	push   %eax
  80191c:	53                   	push   %ebx
  80191d:	e8 65 fd ff ff       	call   801687 <fd_lookup>
  801922:	83 c4 10             	add    $0x10,%esp
  801925:	85 c0                	test   %eax,%eax
  801927:	78 3f                	js     801968 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801929:	83 ec 08             	sub    $0x8,%esp
  80192c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192f:	50                   	push   %eax
  801930:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801933:	ff 30                	pushl  (%eax)
  801935:	e8 a1 fd ff ff       	call   8016db <dev_lookup>
  80193a:	83 c4 10             	add    $0x10,%esp
  80193d:	85 c0                	test   %eax,%eax
  80193f:	78 27                	js     801968 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801941:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801944:	8b 42 08             	mov    0x8(%edx),%eax
  801947:	83 e0 03             	and    $0x3,%eax
  80194a:	83 f8 01             	cmp    $0x1,%eax
  80194d:	74 1e                	je     80196d <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80194f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801952:	8b 40 08             	mov    0x8(%eax),%eax
  801955:	85 c0                	test   %eax,%eax
  801957:	74 35                	je     80198e <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801959:	83 ec 04             	sub    $0x4,%esp
  80195c:	ff 75 10             	pushl  0x10(%ebp)
  80195f:	ff 75 0c             	pushl  0xc(%ebp)
  801962:	52                   	push   %edx
  801963:	ff d0                	call   *%eax
  801965:	83 c4 10             	add    $0x10,%esp
}
  801968:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196b:	c9                   	leave  
  80196c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80196d:	a1 04 50 80 00       	mov    0x805004,%eax
  801972:	8b 40 48             	mov    0x48(%eax),%eax
  801975:	83 ec 04             	sub    $0x4,%esp
  801978:	53                   	push   %ebx
  801979:	50                   	push   %eax
  80197a:	68 41 33 80 00       	push   $0x803341
  80197f:	e8 83 ec ff ff       	call   800607 <cprintf>
		return -E_INVAL;
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80198c:	eb da                	jmp    801968 <read+0x5e>
		return -E_NOT_SUPP;
  80198e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801993:	eb d3                	jmp    801968 <read+0x5e>

00801995 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801995:	f3 0f 1e fb          	endbr32 
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	57                   	push   %edi
  80199d:	56                   	push   %esi
  80199e:	53                   	push   %ebx
  80199f:	83 ec 0c             	sub    $0xc,%esp
  8019a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019a5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ad:	eb 02                	jmp    8019b1 <readn+0x1c>
  8019af:	01 c3                	add    %eax,%ebx
  8019b1:	39 f3                	cmp    %esi,%ebx
  8019b3:	73 21                	jae    8019d6 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019b5:	83 ec 04             	sub    $0x4,%esp
  8019b8:	89 f0                	mov    %esi,%eax
  8019ba:	29 d8                	sub    %ebx,%eax
  8019bc:	50                   	push   %eax
  8019bd:	89 d8                	mov    %ebx,%eax
  8019bf:	03 45 0c             	add    0xc(%ebp),%eax
  8019c2:	50                   	push   %eax
  8019c3:	57                   	push   %edi
  8019c4:	e8 41 ff ff ff       	call   80190a <read>
		if (m < 0)
  8019c9:	83 c4 10             	add    $0x10,%esp
  8019cc:	85 c0                	test   %eax,%eax
  8019ce:	78 04                	js     8019d4 <readn+0x3f>
			return m;
		if (m == 0)
  8019d0:	75 dd                	jne    8019af <readn+0x1a>
  8019d2:	eb 02                	jmp    8019d6 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019d4:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8019d6:	89 d8                	mov    %ebx,%eax
  8019d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019db:	5b                   	pop    %ebx
  8019dc:	5e                   	pop    %esi
  8019dd:	5f                   	pop    %edi
  8019de:	5d                   	pop    %ebp
  8019df:	c3                   	ret    

008019e0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8019e0:	f3 0f 1e fb          	endbr32 
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	53                   	push   %ebx
  8019e8:	83 ec 1c             	sub    $0x1c,%esp
  8019eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f1:	50                   	push   %eax
  8019f2:	53                   	push   %ebx
  8019f3:	e8 8f fc ff ff       	call   801687 <fd_lookup>
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	78 3a                	js     801a39 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019ff:	83 ec 08             	sub    $0x8,%esp
  801a02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a05:	50                   	push   %eax
  801a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a09:	ff 30                	pushl  (%eax)
  801a0b:	e8 cb fc ff ff       	call   8016db <dev_lookup>
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	85 c0                	test   %eax,%eax
  801a15:	78 22                	js     801a39 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a1a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a1e:	74 1e                	je     801a3e <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a20:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a23:	8b 52 0c             	mov    0xc(%edx),%edx
  801a26:	85 d2                	test   %edx,%edx
  801a28:	74 35                	je     801a5f <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a2a:	83 ec 04             	sub    $0x4,%esp
  801a2d:	ff 75 10             	pushl  0x10(%ebp)
  801a30:	ff 75 0c             	pushl  0xc(%ebp)
  801a33:	50                   	push   %eax
  801a34:	ff d2                	call   *%edx
  801a36:	83 c4 10             	add    $0x10,%esp
}
  801a39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3c:	c9                   	leave  
  801a3d:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a3e:	a1 04 50 80 00       	mov    0x805004,%eax
  801a43:	8b 40 48             	mov    0x48(%eax),%eax
  801a46:	83 ec 04             	sub    $0x4,%esp
  801a49:	53                   	push   %ebx
  801a4a:	50                   	push   %eax
  801a4b:	68 5d 33 80 00       	push   $0x80335d
  801a50:	e8 b2 eb ff ff       	call   800607 <cprintf>
		return -E_INVAL;
  801a55:	83 c4 10             	add    $0x10,%esp
  801a58:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a5d:	eb da                	jmp    801a39 <write+0x59>
		return -E_NOT_SUPP;
  801a5f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a64:	eb d3                	jmp    801a39 <write+0x59>

00801a66 <seek>:

int
seek(int fdnum, off_t offset)
{
  801a66:	f3 0f 1e fb          	endbr32 
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a73:	50                   	push   %eax
  801a74:	ff 75 08             	pushl  0x8(%ebp)
  801a77:	e8 0b fc ff ff       	call   801687 <fd_lookup>
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	78 0e                	js     801a91 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801a83:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a89:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801a8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a91:	c9                   	leave  
  801a92:	c3                   	ret    

00801a93 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801a93:	f3 0f 1e fb          	endbr32 
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	53                   	push   %ebx
  801a9b:	83 ec 1c             	sub    $0x1c,%esp
  801a9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aa1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aa4:	50                   	push   %eax
  801aa5:	53                   	push   %ebx
  801aa6:	e8 dc fb ff ff       	call   801687 <fd_lookup>
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	78 37                	js     801ae9 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ab2:	83 ec 08             	sub    $0x8,%esp
  801ab5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab8:	50                   	push   %eax
  801ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801abc:	ff 30                	pushl  (%eax)
  801abe:	e8 18 fc ff ff       	call   8016db <dev_lookup>
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	78 1f                	js     801ae9 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801acd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ad1:	74 1b                	je     801aee <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801ad3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ad6:	8b 52 18             	mov    0x18(%edx),%edx
  801ad9:	85 d2                	test   %edx,%edx
  801adb:	74 32                	je     801b0f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801add:	83 ec 08             	sub    $0x8,%esp
  801ae0:	ff 75 0c             	pushl  0xc(%ebp)
  801ae3:	50                   	push   %eax
  801ae4:	ff d2                	call   *%edx
  801ae6:	83 c4 10             	add    $0x10,%esp
}
  801ae9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aec:	c9                   	leave  
  801aed:	c3                   	ret    
			thisenv->env_id, fdnum);
  801aee:	a1 04 50 80 00       	mov    0x805004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801af3:	8b 40 48             	mov    0x48(%eax),%eax
  801af6:	83 ec 04             	sub    $0x4,%esp
  801af9:	53                   	push   %ebx
  801afa:	50                   	push   %eax
  801afb:	68 20 33 80 00       	push   $0x803320
  801b00:	e8 02 eb ff ff       	call   800607 <cprintf>
		return -E_INVAL;
  801b05:	83 c4 10             	add    $0x10,%esp
  801b08:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b0d:	eb da                	jmp    801ae9 <ftruncate+0x56>
		return -E_NOT_SUPP;
  801b0f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b14:	eb d3                	jmp    801ae9 <ftruncate+0x56>

00801b16 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b16:	f3 0f 1e fb          	endbr32 
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	53                   	push   %ebx
  801b1e:	83 ec 1c             	sub    $0x1c,%esp
  801b21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b24:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b27:	50                   	push   %eax
  801b28:	ff 75 08             	pushl  0x8(%ebp)
  801b2b:	e8 57 fb ff ff       	call   801687 <fd_lookup>
  801b30:	83 c4 10             	add    $0x10,%esp
  801b33:	85 c0                	test   %eax,%eax
  801b35:	78 4b                	js     801b82 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b37:	83 ec 08             	sub    $0x8,%esp
  801b3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b3d:	50                   	push   %eax
  801b3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b41:	ff 30                	pushl  (%eax)
  801b43:	e8 93 fb ff ff       	call   8016db <dev_lookup>
  801b48:	83 c4 10             	add    $0x10,%esp
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	78 33                	js     801b82 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b52:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801b56:	74 2f                	je     801b87 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b58:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b5b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b62:	00 00 00 
	stat->st_isdir = 0;
  801b65:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b6c:	00 00 00 
	stat->st_dev = dev;
  801b6f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b75:	83 ec 08             	sub    $0x8,%esp
  801b78:	53                   	push   %ebx
  801b79:	ff 75 f0             	pushl  -0x10(%ebp)
  801b7c:	ff 50 14             	call   *0x14(%eax)
  801b7f:	83 c4 10             	add    $0x10,%esp
}
  801b82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b85:	c9                   	leave  
  801b86:	c3                   	ret    
		return -E_NOT_SUPP;
  801b87:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b8c:	eb f4                	jmp    801b82 <fstat+0x6c>

00801b8e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801b8e:	f3 0f 1e fb          	endbr32 
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	56                   	push   %esi
  801b96:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b97:	83 ec 08             	sub    $0x8,%esp
  801b9a:	6a 00                	push   $0x0
  801b9c:	ff 75 08             	pushl  0x8(%ebp)
  801b9f:	e8 20 02 00 00       	call   801dc4 <open>
  801ba4:	89 c3                	mov    %eax,%ebx
  801ba6:	83 c4 10             	add    $0x10,%esp
  801ba9:	85 c0                	test   %eax,%eax
  801bab:	78 1b                	js     801bc8 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801bad:	83 ec 08             	sub    $0x8,%esp
  801bb0:	ff 75 0c             	pushl  0xc(%ebp)
  801bb3:	50                   	push   %eax
  801bb4:	e8 5d ff ff ff       	call   801b16 <fstat>
  801bb9:	89 c6                	mov    %eax,%esi
	close(fd);
  801bbb:	89 1c 24             	mov    %ebx,(%esp)
  801bbe:	e8 fd fb ff ff       	call   8017c0 <close>
	return r;
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	89 f3                	mov    %esi,%ebx
}
  801bc8:	89 d8                	mov    %ebx,%eax
  801bca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5d                   	pop    %ebp
  801bd0:	c3                   	ret    

00801bd1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	56                   	push   %esi
  801bd5:	53                   	push   %ebx
  801bd6:	89 c6                	mov    %eax,%esi
  801bd8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801bda:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801be1:	74 27                	je     801c0a <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801be3:	6a 07                	push   $0x7
  801be5:	68 00 60 80 00       	push   $0x806000
  801bea:	56                   	push   %esi
  801beb:	ff 35 00 50 80 00    	pushl  0x805000
  801bf1:	e8 42 0d 00 00       	call   802938 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801bf6:	83 c4 0c             	add    $0xc,%esp
  801bf9:	6a 00                	push   $0x0
  801bfb:	53                   	push   %ebx
  801bfc:	6a 00                	push   $0x0
  801bfe:	e8 c8 0c 00 00       	call   8028cb <ipc_recv>
}
  801c03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c06:	5b                   	pop    %ebx
  801c07:	5e                   	pop    %esi
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c0a:	83 ec 0c             	sub    $0xc,%esp
  801c0d:	6a 01                	push   $0x1
  801c0f:	e8 77 0d 00 00       	call   80298b <ipc_find_env>
  801c14:	a3 00 50 80 00       	mov    %eax,0x805000
  801c19:	83 c4 10             	add    $0x10,%esp
  801c1c:	eb c5                	jmp    801be3 <fsipc+0x12>

00801c1e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c1e:	f3 0f 1e fb          	endbr32 
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c28:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2b:	8b 40 0c             	mov    0xc(%eax),%eax
  801c2e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801c33:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c36:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c40:	b8 02 00 00 00       	mov    $0x2,%eax
  801c45:	e8 87 ff ff ff       	call   801bd1 <fsipc>
}
  801c4a:	c9                   	leave  
  801c4b:	c3                   	ret    

00801c4c <devfile_flush>:
{
  801c4c:	f3 0f 1e fb          	endbr32 
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c56:	8b 45 08             	mov    0x8(%ebp),%eax
  801c59:	8b 40 0c             	mov    0xc(%eax),%eax
  801c5c:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801c61:	ba 00 00 00 00       	mov    $0x0,%edx
  801c66:	b8 06 00 00 00       	mov    $0x6,%eax
  801c6b:	e8 61 ff ff ff       	call   801bd1 <fsipc>
}
  801c70:	c9                   	leave  
  801c71:	c3                   	ret    

00801c72 <devfile_stat>:
{
  801c72:	f3 0f 1e fb          	endbr32 
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	53                   	push   %ebx
  801c7a:	83 ec 04             	sub    $0x4,%esp
  801c7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c80:	8b 45 08             	mov    0x8(%ebp),%eax
  801c83:	8b 40 0c             	mov    0xc(%eax),%eax
  801c86:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c8b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c90:	b8 05 00 00 00       	mov    $0x5,%eax
  801c95:	e8 37 ff ff ff       	call   801bd1 <fsipc>
  801c9a:	85 c0                	test   %eax,%eax
  801c9c:	78 2c                	js     801cca <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c9e:	83 ec 08             	sub    $0x8,%esp
  801ca1:	68 00 60 80 00       	push   $0x806000
  801ca6:	53                   	push   %ebx
  801ca7:	e8 c5 ee ff ff       	call   800b71 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801cac:	a1 80 60 80 00       	mov    0x806080,%eax
  801cb1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801cb7:	a1 84 60 80 00       	mov    0x806084,%eax
  801cbc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801cc2:	83 c4 10             	add    $0x10,%esp
  801cc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ccd:	c9                   	leave  
  801cce:	c3                   	ret    

00801ccf <devfile_write>:
{
  801ccf:	f3 0f 1e fb          	endbr32 
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	57                   	push   %edi
  801cd7:	56                   	push   %esi
  801cd8:	53                   	push   %ebx
  801cd9:	83 ec 0c             	sub    $0xc,%esp
  801cdc:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce5:	8b 40 0c             	mov    0xc(%eax),%eax
  801ce8:	a3 00 60 80 00       	mov    %eax,0x806000
	int r = 0;
  801ced:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801cf2:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  801cf7:	85 db                	test   %ebx,%ebx
  801cf9:	74 3b                	je     801d36 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801cfb:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801d01:	89 f8                	mov    %edi,%eax
  801d03:	0f 46 c3             	cmovbe %ebx,%eax
  801d06:	a3 04 60 80 00       	mov    %eax,0x806004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  801d0b:	83 ec 04             	sub    $0x4,%esp
  801d0e:	50                   	push   %eax
  801d0f:	56                   	push   %esi
  801d10:	68 08 60 80 00       	push   $0x806008
  801d15:	e8 0f f0 ff ff       	call   800d29 <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801d1a:	ba 00 00 00 00       	mov    $0x0,%edx
  801d1f:	b8 04 00 00 00       	mov    $0x4,%eax
  801d24:	e8 a8 fe ff ff       	call   801bd1 <fsipc>
  801d29:	83 c4 10             	add    $0x10,%esp
  801d2c:	85 c0                	test   %eax,%eax
  801d2e:	78 06                	js     801d36 <devfile_write+0x67>
		buf_aux += r;
  801d30:	01 c6                	add    %eax,%esi
		n -= r;
  801d32:	29 c3                	sub    %eax,%ebx
  801d34:	eb c1                	jmp    801cf7 <devfile_write+0x28>
}
  801d36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d39:	5b                   	pop    %ebx
  801d3a:	5e                   	pop    %esi
  801d3b:	5f                   	pop    %edi
  801d3c:	5d                   	pop    %ebp
  801d3d:	c3                   	ret    

00801d3e <devfile_read>:
{
  801d3e:	f3 0f 1e fb          	endbr32 
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	56                   	push   %esi
  801d46:	53                   	push   %ebx
  801d47:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4d:	8b 40 0c             	mov    0xc(%eax),%eax
  801d50:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801d55:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d5b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d60:	b8 03 00 00 00       	mov    $0x3,%eax
  801d65:	e8 67 fe ff ff       	call   801bd1 <fsipc>
  801d6a:	89 c3                	mov    %eax,%ebx
  801d6c:	85 c0                	test   %eax,%eax
  801d6e:	78 1f                	js     801d8f <devfile_read+0x51>
	assert(r <= n);
  801d70:	39 f0                	cmp    %esi,%eax
  801d72:	77 24                	ja     801d98 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801d74:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d79:	7f 33                	jg     801dae <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801d7b:	83 ec 04             	sub    $0x4,%esp
  801d7e:	50                   	push   %eax
  801d7f:	68 00 60 80 00       	push   $0x806000
  801d84:	ff 75 0c             	pushl  0xc(%ebp)
  801d87:	e8 9d ef ff ff       	call   800d29 <memmove>
	return r;
  801d8c:	83 c4 10             	add    $0x10,%esp
}
  801d8f:	89 d8                	mov    %ebx,%eax
  801d91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d94:	5b                   	pop    %ebx
  801d95:	5e                   	pop    %esi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    
	assert(r <= n);
  801d98:	68 8c 33 80 00       	push   $0x80338c
  801d9d:	68 93 33 80 00       	push   $0x803393
  801da2:	6a 7c                	push   $0x7c
  801da4:	68 a8 33 80 00       	push   $0x8033a8
  801da9:	e8 72 e7 ff ff       	call   800520 <_panic>
	assert(r <= PGSIZE);
  801dae:	68 b3 33 80 00       	push   $0x8033b3
  801db3:	68 93 33 80 00       	push   $0x803393
  801db8:	6a 7d                	push   $0x7d
  801dba:	68 a8 33 80 00       	push   $0x8033a8
  801dbf:	e8 5c e7 ff ff       	call   800520 <_panic>

00801dc4 <open>:
{
  801dc4:	f3 0f 1e fb          	endbr32 
  801dc8:	55                   	push   %ebp
  801dc9:	89 e5                	mov    %esp,%ebp
  801dcb:	56                   	push   %esi
  801dcc:	53                   	push   %ebx
  801dcd:	83 ec 1c             	sub    $0x1c,%esp
  801dd0:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801dd3:	56                   	push   %esi
  801dd4:	e8 55 ed ff ff       	call   800b2e <strlen>
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801de1:	7f 6c                	jg     801e4f <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801de3:	83 ec 0c             	sub    $0xc,%esp
  801de6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de9:	50                   	push   %eax
  801dea:	e8 42 f8 ff ff       	call   801631 <fd_alloc>
  801def:	89 c3                	mov    %eax,%ebx
  801df1:	83 c4 10             	add    $0x10,%esp
  801df4:	85 c0                	test   %eax,%eax
  801df6:	78 3c                	js     801e34 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801df8:	83 ec 08             	sub    $0x8,%esp
  801dfb:	56                   	push   %esi
  801dfc:	68 00 60 80 00       	push   $0x806000
  801e01:	e8 6b ed ff ff       	call   800b71 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e06:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e09:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e11:	b8 01 00 00 00       	mov    $0x1,%eax
  801e16:	e8 b6 fd ff ff       	call   801bd1 <fsipc>
  801e1b:	89 c3                	mov    %eax,%ebx
  801e1d:	83 c4 10             	add    $0x10,%esp
  801e20:	85 c0                	test   %eax,%eax
  801e22:	78 19                	js     801e3d <open+0x79>
	return fd2num(fd);
  801e24:	83 ec 0c             	sub    $0xc,%esp
  801e27:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2a:	e8 cf f7 ff ff       	call   8015fe <fd2num>
  801e2f:	89 c3                	mov    %eax,%ebx
  801e31:	83 c4 10             	add    $0x10,%esp
}
  801e34:	89 d8                	mov    %ebx,%eax
  801e36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e39:	5b                   	pop    %ebx
  801e3a:	5e                   	pop    %esi
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    
		fd_close(fd, 0);
  801e3d:	83 ec 08             	sub    $0x8,%esp
  801e40:	6a 00                	push   $0x0
  801e42:	ff 75 f4             	pushl  -0xc(%ebp)
  801e45:	e8 eb f8 ff ff       	call   801735 <fd_close>
		return r;
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	eb e5                	jmp    801e34 <open+0x70>
		return -E_BAD_PATH;
  801e4f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801e54:	eb de                	jmp    801e34 <open+0x70>

00801e56 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801e56:	f3 0f 1e fb          	endbr32 
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e60:	ba 00 00 00 00       	mov    $0x0,%edx
  801e65:	b8 08 00 00 00       	mov    $0x8,%eax
  801e6a:	e8 62 fd ff ff       	call   801bd1 <fsipc>
}
  801e6f:	c9                   	leave  
  801e70:	c3                   	ret    

00801e71 <copy_shared_pages>:
}

// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	56                   	push   %esi
  801e75:	53                   	push   %ebx
  801e76:	89 c6                	mov    %eax,%esi
	// LAB 5: Your code here.
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801e78:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e7d:	eb 33                	jmp    801eb2 <copy_shared_pages+0x41>
			     0)) {
				sys_page_map(0,
				             (void *) addr,
				             child,
				             (void *) addr,
				             (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  801e7f:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
				sys_page_map(0,
  801e86:	83 ec 0c             	sub    $0xc,%esp
  801e89:	25 07 0e 00 00       	and    $0xe07,%eax
  801e8e:	50                   	push   %eax
  801e8f:	53                   	push   %ebx
  801e90:	56                   	push   %esi
  801e91:	53                   	push   %ebx
  801e92:	6a 00                	push   $0x0
  801e94:	e8 88 f1 ff ff       	call   801021 <sys_page_map>
  801e99:	83 c4 20             	add    $0x20,%esp
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801e9c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ea2:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801ea8:	77 2f                	ja     801ed9 <copy_shared_pages+0x68>
		if (addr != UXSTACKTOP - PGSIZE) {
  801eaa:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801eb0:	74 ea                	je     801e9c <copy_shared_pages+0x2b>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801eb2:	89 d8                	mov    %ebx,%eax
  801eb4:	c1 e8 16             	shr    $0x16,%eax
  801eb7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ebe:	a8 01                	test   $0x1,%al
  801ec0:	74 da                	je     801e9c <copy_shared_pages+0x2b>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U | PTE_SHARE)) ==
  801ec2:	89 da                	mov    %ebx,%edx
  801ec4:	c1 ea 0c             	shr    $0xc,%edx
  801ec7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801ece:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801ed0:	a9 05 04 00 00       	test   $0x405,%eax
  801ed5:	75 c5                	jne    801e9c <copy_shared_pages+0x2b>
  801ed7:	eb a6                	jmp    801e7f <copy_shared_pages+0xe>
			}
		}
	}
	return 0;
}
  801ed9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ede:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee1:	5b                   	pop    %ebx
  801ee2:	5e                   	pop    %esi
  801ee3:	5d                   	pop    %ebp
  801ee4:	c3                   	ret    

00801ee5 <init_stack>:
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	57                   	push   %edi
  801ee9:	56                   	push   %esi
  801eea:	53                   	push   %ebx
  801eeb:	83 ec 2c             	sub    $0x2c,%esp
  801eee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801ef1:	89 55 d0             	mov    %edx,-0x30(%ebp)
  801ef4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (argc = 0; argv[argc] != 0; argc++)
  801ef7:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801efc:	be 00 00 00 00       	mov    $0x0,%esi
  801f01:	89 d7                	mov    %edx,%edi
  801f03:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
	for (argc = 0; argv[argc] != 0; argc++)
  801f0a:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	74 15                	je     801f26 <init_stack+0x41>
		string_size += strlen(argv[argc]) + 1;
  801f11:	83 ec 0c             	sub    $0xc,%esp
  801f14:	50                   	push   %eax
  801f15:	e8 14 ec ff ff       	call   800b2e <strlen>
  801f1a:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801f1e:	83 c3 01             	add    $0x1,%ebx
  801f21:	83 c4 10             	add    $0x10,%esp
  801f24:	eb dd                	jmp    801f03 <init_stack+0x1e>
  801f26:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801f29:	89 4d d8             	mov    %ecx,-0x28(%ebp)
	string_store = (char *) UTEMP + PGSIZE - string_size;
  801f2c:	bf 00 10 40 00       	mov    $0x401000,%edi
  801f31:	29 f7                	sub    %esi,%edi
	argv_store = (uintptr_t *) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801f33:	89 fa                	mov    %edi,%edx
  801f35:	83 e2 fc             	and    $0xfffffffc,%edx
  801f38:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801f3f:	29 c2                	sub    %eax,%edx
  801f41:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	if ((void *) (argv_store - 2) < (void *) UTEMP)
  801f44:	8d 42 f8             	lea    -0x8(%edx),%eax
  801f47:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801f4c:	0f 86 06 01 00 00    	jbe    802058 <init_stack+0x173>
	if ((r = sys_page_alloc(0, (void *) UTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801f52:	83 ec 04             	sub    $0x4,%esp
  801f55:	6a 07                	push   $0x7
  801f57:	68 00 00 40 00       	push   $0x400000
  801f5c:	6a 00                	push   $0x0
  801f5e:	e8 96 f0 ff ff       	call   800ff9 <sys_page_alloc>
  801f63:	89 c6                	mov    %eax,%esi
  801f65:	83 c4 10             	add    $0x10,%esp
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	0f 88 de 00 00 00    	js     80204e <init_stack+0x169>
	for (i = 0; i < argc; i++) {
  801f70:	be 00 00 00 00       	mov    $0x0,%esi
  801f75:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  801f78:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801f7b:	39 75 e0             	cmp    %esi,-0x20(%ebp)
  801f7e:	7e 2f                	jle    801faf <init_stack+0xca>
		argv_store[i] = UTEMP2USTACK(string_store);
  801f80:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801f86:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801f89:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801f8c:	83 ec 08             	sub    $0x8,%esp
  801f8f:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801f92:	57                   	push   %edi
  801f93:	e8 d9 eb ff ff       	call   800b71 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801f98:	83 c4 04             	add    $0x4,%esp
  801f9b:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801f9e:	e8 8b eb ff ff       	call   800b2e <strlen>
  801fa3:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801fa7:	83 c6 01             	add    $0x1,%esi
  801faa:	83 c4 10             	add    $0x10,%esp
  801fad:	eb cc                	jmp    801f7b <init_stack+0x96>
	argv_store[argc] = 0;
  801faf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fb2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  801fb5:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char *) UTEMP + PGSIZE);
  801fbc:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801fc2:	75 5f                	jne    802023 <init_stack+0x13e>
	argv_store[-1] = UTEMP2USTACK(argv_store);
  801fc4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801fc7:	8d 82 00 d0 7f ee    	lea    -0x11803000(%edx),%eax
  801fcd:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801fd0:	89 d0                	mov    %edx,%eax
  801fd2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801fd5:	89 4a f8             	mov    %ecx,-0x8(%edx)
	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801fd8:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801fdd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801fe0:	89 01                	mov    %eax,(%ecx)
	if ((r = sys_page_map(0,
  801fe2:	83 ec 0c             	sub    $0xc,%esp
  801fe5:	6a 07                	push   $0x7
  801fe7:	68 00 d0 bf ee       	push   $0xeebfd000
  801fec:	ff 75 d4             	pushl  -0x2c(%ebp)
  801fef:	68 00 00 40 00       	push   $0x400000
  801ff4:	6a 00                	push   $0x0
  801ff6:	e8 26 f0 ff ff       	call   801021 <sys_page_map>
  801ffb:	89 c6                	mov    %eax,%esi
  801ffd:	83 c4 20             	add    $0x20,%esp
  802000:	85 c0                	test   %eax,%eax
  802002:	78 38                	js     80203c <init_stack+0x157>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802004:	83 ec 08             	sub    $0x8,%esp
  802007:	68 00 00 40 00       	push   $0x400000
  80200c:	6a 00                	push   $0x0
  80200e:	e8 38 f0 ff ff       	call   80104b <sys_page_unmap>
  802013:	89 c6                	mov    %eax,%esi
  802015:	83 c4 10             	add    $0x10,%esp
  802018:	85 c0                	test   %eax,%eax
  80201a:	78 20                	js     80203c <init_stack+0x157>
	return 0;
  80201c:	be 00 00 00 00       	mov    $0x0,%esi
  802021:	eb 2b                	jmp    80204e <init_stack+0x169>
	assert(string_store == (char *) UTEMP + PGSIZE);
  802023:	68 c0 33 80 00       	push   $0x8033c0
  802028:	68 93 33 80 00       	push   $0x803393
  80202d:	68 fc 00 00 00       	push   $0xfc
  802032:	68 e8 33 80 00       	push   $0x8033e8
  802037:	e8 e4 e4 ff ff       	call   800520 <_panic>
	sys_page_unmap(0, UTEMP);
  80203c:	83 ec 08             	sub    $0x8,%esp
  80203f:	68 00 00 40 00       	push   $0x400000
  802044:	6a 00                	push   $0x0
  802046:	e8 00 f0 ff ff       	call   80104b <sys_page_unmap>
	return r;
  80204b:	83 c4 10             	add    $0x10,%esp
}
  80204e:	89 f0                	mov    %esi,%eax
  802050:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
		return -E_NO_MEM;
  802058:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  80205d:	eb ef                	jmp    80204e <init_stack+0x169>

0080205f <map_segment>:
{
  80205f:	55                   	push   %ebp
  802060:	89 e5                	mov    %esp,%ebp
  802062:	57                   	push   %edi
  802063:	56                   	push   %esi
  802064:	53                   	push   %ebx
  802065:	83 ec 1c             	sub    $0x1c,%esp
  802068:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80206b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80206e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  802071:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((i = PGOFF(va))) {
  802074:	89 d0                	mov    %edx,%eax
  802076:	25 ff 0f 00 00       	and    $0xfff,%eax
  80207b:	74 0f                	je     80208c <map_segment+0x2d>
		va -= i;
  80207d:	29 c2                	sub    %eax,%edx
  80207f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		memsz += i;
  802082:	01 c1                	add    %eax,%ecx
  802084:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		filesz += i;
  802087:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  802089:	29 45 10             	sub    %eax,0x10(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  80208c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802091:	e9 99 00 00 00       	jmp    80212f <map_segment+0xd0>
			if ((r = sys_page_alloc(0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  802096:	83 ec 04             	sub    $0x4,%esp
  802099:	6a 07                	push   $0x7
  80209b:	68 00 00 40 00       	push   $0x400000
  8020a0:	6a 00                	push   $0x0
  8020a2:	e8 52 ef ff ff       	call   800ff9 <sys_page_alloc>
  8020a7:	83 c4 10             	add    $0x10,%esp
  8020aa:	85 c0                	test   %eax,%eax
  8020ac:	0f 88 c1 00 00 00    	js     802173 <map_segment+0x114>
			if ((r = seek(fd, fileoffset + i)) < 0)
  8020b2:	83 ec 08             	sub    $0x8,%esp
  8020b5:	89 f0                	mov    %esi,%eax
  8020b7:	03 45 10             	add    0x10(%ebp),%eax
  8020ba:	50                   	push   %eax
  8020bb:	ff 75 08             	pushl  0x8(%ebp)
  8020be:	e8 a3 f9 ff ff       	call   801a66 <seek>
  8020c3:	83 c4 10             	add    $0x10,%esp
  8020c6:	85 c0                	test   %eax,%eax
  8020c8:	0f 88 a5 00 00 00    	js     802173 <map_segment+0x114>
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz - i))) < 0)
  8020ce:	83 ec 04             	sub    $0x4,%esp
  8020d1:	89 f8                	mov    %edi,%eax
  8020d3:	29 f0                	sub    %esi,%eax
  8020d5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8020da:	ba 00 10 00 00       	mov    $0x1000,%edx
  8020df:	0f 47 c2             	cmova  %edx,%eax
  8020e2:	50                   	push   %eax
  8020e3:	68 00 00 40 00       	push   $0x400000
  8020e8:	ff 75 08             	pushl  0x8(%ebp)
  8020eb:	e8 a5 f8 ff ff       	call   801995 <readn>
  8020f0:	83 c4 10             	add    $0x10,%esp
  8020f3:	85 c0                	test   %eax,%eax
  8020f5:	78 7c                	js     802173 <map_segment+0x114>
			if ((r = sys_page_map(
  8020f7:	83 ec 0c             	sub    $0xc,%esp
  8020fa:	ff 75 14             	pushl  0x14(%ebp)
  8020fd:	03 75 e0             	add    -0x20(%ebp),%esi
  802100:	56                   	push   %esi
  802101:	ff 75 dc             	pushl  -0x24(%ebp)
  802104:	68 00 00 40 00       	push   $0x400000
  802109:	6a 00                	push   $0x0
  80210b:	e8 11 ef ff ff       	call   801021 <sys_page_map>
  802110:	83 c4 20             	add    $0x20,%esp
  802113:	85 c0                	test   %eax,%eax
  802115:	78 42                	js     802159 <map_segment+0xfa>
			sys_page_unmap(0, UTEMP);
  802117:	83 ec 08             	sub    $0x8,%esp
  80211a:	68 00 00 40 00       	push   $0x400000
  80211f:	6a 00                	push   $0x0
  802121:	e8 25 ef ff ff       	call   80104b <sys_page_unmap>
  802126:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  802129:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80212f:	89 de                	mov    %ebx,%esi
  802131:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  802134:	76 38                	jbe    80216e <map_segment+0x10f>
		if (i >= filesz) {
  802136:	39 df                	cmp    %ebx,%edi
  802138:	0f 87 58 ff ff ff    	ja     802096 <map_segment+0x37>
			if ((r = sys_page_alloc(child, (void *) (va + i), perm)) < 0)
  80213e:	83 ec 04             	sub    $0x4,%esp
  802141:	ff 75 14             	pushl  0x14(%ebp)
  802144:	03 75 e0             	add    -0x20(%ebp),%esi
  802147:	56                   	push   %esi
  802148:	ff 75 dc             	pushl  -0x24(%ebp)
  80214b:	e8 a9 ee ff ff       	call   800ff9 <sys_page_alloc>
  802150:	83 c4 10             	add    $0x10,%esp
  802153:	85 c0                	test   %eax,%eax
  802155:	79 d2                	jns    802129 <map_segment+0xca>
  802157:	eb 1a                	jmp    802173 <map_segment+0x114>
				panic("spawn: sys_page_map data: %e", r);
  802159:	50                   	push   %eax
  80215a:	68 f4 33 80 00       	push   $0x8033f4
  80215f:	68 3a 01 00 00       	push   $0x13a
  802164:	68 e8 33 80 00       	push   $0x8033e8
  802169:	e8 b2 e3 ff ff       	call   800520 <_panic>
	return 0;
  80216e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802173:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802176:	5b                   	pop    %ebx
  802177:	5e                   	pop    %esi
  802178:	5f                   	pop    %edi
  802179:	5d                   	pop    %ebp
  80217a:	c3                   	ret    

0080217b <spawn>:
{
  80217b:	f3 0f 1e fb          	endbr32 
  80217f:	55                   	push   %ebp
  802180:	89 e5                	mov    %esp,%ebp
  802182:	57                   	push   %edi
  802183:	56                   	push   %esi
  802184:	53                   	push   %ebx
  802185:	81 ec 74 02 00 00    	sub    $0x274,%esp
	if ((r = open(prog, O_RDONLY)) < 0)
  80218b:	6a 00                	push   $0x0
  80218d:	ff 75 08             	pushl  0x8(%ebp)
  802190:	e8 2f fc ff ff       	call   801dc4 <open>
  802195:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80219b:	83 c4 10             	add    $0x10,%esp
  80219e:	85 c0                	test   %eax,%eax
  8021a0:	0f 88 0b 02 00 00    	js     8023b1 <spawn+0x236>
  8021a6:	89 c7                	mov    %eax,%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf) ||
  8021a8:	83 ec 04             	sub    $0x4,%esp
  8021ab:	68 00 02 00 00       	push   $0x200
  8021b0:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8021b6:	50                   	push   %eax
  8021b7:	57                   	push   %edi
  8021b8:	e8 d8 f7 ff ff       	call   801995 <readn>
  8021bd:	83 c4 10             	add    $0x10,%esp
  8021c0:	3d 00 02 00 00       	cmp    $0x200,%eax
  8021c5:	0f 85 85 00 00 00    	jne    802250 <spawn+0xd5>
  8021cb:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8021d2:	45 4c 46 
  8021d5:	75 79                	jne    802250 <spawn+0xd5>
  8021d7:	b8 07 00 00 00       	mov    $0x7,%eax
  8021dc:	cd 30                	int    $0x30
  8021de:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8021e4:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	if ((r = sys_exofork()) < 0)
  8021ea:	89 c3                	mov    %eax,%ebx
  8021ec:	85 c0                	test   %eax,%eax
  8021ee:	0f 88 b1 01 00 00    	js     8023a5 <spawn+0x22a>
	child_tf = envs[ENVX(child)].env_tf;
  8021f4:	89 c6                	mov    %eax,%esi
  8021f6:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8021fc:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8021ff:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  802205:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80220b:	b9 11 00 00 00       	mov    $0x11,%ecx
  802210:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802212:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802218:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
  80221e:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  802224:	8b 55 0c             	mov    0xc(%ebp),%edx
  802227:	89 d8                	mov    %ebx,%eax
  802229:	e8 b7 fc ff ff       	call   801ee5 <init_stack>
  80222e:	85 c0                	test   %eax,%eax
  802230:	0f 88 89 01 00 00    	js     8023bf <spawn+0x244>
	ph = (struct Proghdr *) (elf_buf + elf->e_phoff);
  802236:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80223c:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802243:	be 00 00 00 00       	mov    $0x0,%esi
  802248:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80224e:	eb 3e                	jmp    80228e <spawn+0x113>
		close(fd);
  802250:	83 ec 0c             	sub    $0xc,%esp
  802253:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  802259:	e8 62 f5 ff ff       	call   8017c0 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80225e:	83 c4 0c             	add    $0xc,%esp
  802261:	68 7f 45 4c 46       	push   $0x464c457f
  802266:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80226c:	68 11 34 80 00       	push   $0x803411
  802271:	e8 91 e3 ff ff       	call   800607 <cprintf>
		return -E_NOT_EXEC;
  802276:	83 c4 10             	add    $0x10,%esp
  802279:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  802280:	ff ff ff 
  802283:	e9 29 01 00 00       	jmp    8023b1 <spawn+0x236>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802288:	83 c6 01             	add    $0x1,%esi
  80228b:	83 c3 20             	add    $0x20,%ebx
  80228e:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802295:	39 f0                	cmp    %esi,%eax
  802297:	7e 62                	jle    8022fb <spawn+0x180>
		if (ph->p_type != ELF_PROG_LOAD)
  802299:	83 3b 01             	cmpl   $0x1,(%ebx)
  80229c:	75 ea                	jne    802288 <spawn+0x10d>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80229e:	8b 43 18             	mov    0x18(%ebx),%eax
  8022a1:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8022a4:	83 f8 01             	cmp    $0x1,%eax
  8022a7:	19 c0                	sbb    %eax,%eax
  8022a9:	83 e0 fe             	and    $0xfffffffe,%eax
  8022ac:	83 c0 07             	add    $0x7,%eax
		if ((r = map_segment(child,
  8022af:	8b 4b 14             	mov    0x14(%ebx),%ecx
  8022b2:	8b 53 08             	mov    0x8(%ebx),%edx
  8022b5:	50                   	push   %eax
  8022b6:	ff 73 04             	pushl  0x4(%ebx)
  8022b9:	ff 73 10             	pushl  0x10(%ebx)
  8022bc:	57                   	push   %edi
  8022bd:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8022c3:	e8 97 fd ff ff       	call   80205f <map_segment>
  8022c8:	83 c4 10             	add    $0x10,%esp
  8022cb:	85 c0                	test   %eax,%eax
  8022cd:	79 b9                	jns    802288 <spawn+0x10d>
  8022cf:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  8022d1:	83 ec 0c             	sub    $0xc,%esp
  8022d4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8022da:	e8 a1 ec ff ff       	call   800f80 <sys_env_destroy>
	close(fd);
  8022df:	83 c4 04             	add    $0x4,%esp
  8022e2:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  8022e8:	e8 d3 f4 ff ff       	call   8017c0 <close>
	return r;
  8022ed:	83 c4 10             	add    $0x10,%esp
		if ((r = map_segment(child,
  8022f0:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return r;
  8022f6:	e9 b6 00 00 00       	jmp    8023b1 <spawn+0x236>
	close(fd);
  8022fb:	83 ec 0c             	sub    $0xc,%esp
  8022fe:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  802304:	e8 b7 f4 ff ff       	call   8017c0 <close>
	if ((r = copy_shared_pages(child)) < 0)
  802309:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  80230f:	e8 5d fb ff ff       	call   801e71 <copy_shared_pages>
  802314:	83 c4 10             	add    $0x10,%esp
  802317:	85 c0                	test   %eax,%eax
  802319:	78 4b                	js     802366 <spawn+0x1eb>
	child_tf.tf_eflags |= FL_IOPL_3;  // devious: see user/faultio.c
  80231b:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802322:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802325:	83 ec 08             	sub    $0x8,%esp
  802328:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80232e:	50                   	push   %eax
  80232f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802335:	e8 5f ed ff ff       	call   801099 <sys_env_set_trapframe>
  80233a:	83 c4 10             	add    $0x10,%esp
  80233d:	85 c0                	test   %eax,%eax
  80233f:	78 3a                	js     80237b <spawn+0x200>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802341:	83 ec 08             	sub    $0x8,%esp
  802344:	6a 02                	push   $0x2
  802346:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80234c:	e8 21 ed ff ff       	call   801072 <sys_env_set_status>
  802351:	83 c4 10             	add    $0x10,%esp
  802354:	85 c0                	test   %eax,%eax
  802356:	78 38                	js     802390 <spawn+0x215>
	return child;
  802358:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  80235e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802364:	eb 4b                	jmp    8023b1 <spawn+0x236>
		panic("copy_shared_pages: %e", r);
  802366:	50                   	push   %eax
  802367:	68 2b 34 80 00       	push   $0x80342b
  80236c:	68 8c 00 00 00       	push   $0x8c
  802371:	68 e8 33 80 00       	push   $0x8033e8
  802376:	e8 a5 e1 ff ff       	call   800520 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  80237b:	50                   	push   %eax
  80237c:	68 41 34 80 00       	push   $0x803441
  802381:	68 90 00 00 00       	push   $0x90
  802386:	68 e8 33 80 00       	push   $0x8033e8
  80238b:	e8 90 e1 ff ff       	call   800520 <_panic>
		panic("sys_env_set_status: %e", r);
  802390:	50                   	push   %eax
  802391:	68 5b 34 80 00       	push   $0x80345b
  802396:	68 93 00 00 00       	push   $0x93
  80239b:	68 e8 33 80 00       	push   $0x8033e8
  8023a0:	e8 7b e1 ff ff       	call   800520 <_panic>
		return r;
  8023a5:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8023ab:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
}
  8023b1:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8023b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023ba:	5b                   	pop    %ebx
  8023bb:	5e                   	pop    %esi
  8023bc:	5f                   	pop    %edi
  8023bd:	5d                   	pop    %ebp
  8023be:	c3                   	ret    
		return r;
  8023bf:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8023c5:	eb ea                	jmp    8023b1 <spawn+0x236>

008023c7 <spawnl>:
{
  8023c7:	f3 0f 1e fb          	endbr32 
  8023cb:	55                   	push   %ebp
  8023cc:	89 e5                	mov    %esp,%ebp
  8023ce:	57                   	push   %edi
  8023cf:	56                   	push   %esi
  8023d0:	53                   	push   %ebx
  8023d1:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  8023d4:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc = 0;
  8023d7:	b8 00 00 00 00       	mov    $0x0,%eax
	while (va_arg(vl, void *) != NULL)
  8023dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8023df:	83 3a 00             	cmpl   $0x0,(%edx)
  8023e2:	74 07                	je     8023eb <spawnl+0x24>
		argc++;
  8023e4:	83 c0 01             	add    $0x1,%eax
	while (va_arg(vl, void *) != NULL)
  8023e7:	89 ca                	mov    %ecx,%edx
  8023e9:	eb f1                	jmp    8023dc <spawnl+0x15>
	const char *argv[argc + 2];
  8023eb:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  8023f2:	89 d1                	mov    %edx,%ecx
  8023f4:	83 e1 f0             	and    $0xfffffff0,%ecx
  8023f7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  8023fd:	89 e6                	mov    %esp,%esi
  8023ff:	29 d6                	sub    %edx,%esi
  802401:	89 f2                	mov    %esi,%edx
  802403:	39 d4                	cmp    %edx,%esp
  802405:	74 10                	je     802417 <spawnl+0x50>
  802407:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  80240d:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  802414:	00 
  802415:	eb ec                	jmp    802403 <spawnl+0x3c>
  802417:	89 ca                	mov    %ecx,%edx
  802419:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  80241f:	29 d4                	sub    %edx,%esp
  802421:	85 d2                	test   %edx,%edx
  802423:	74 05                	je     80242a <spawnl+0x63>
  802425:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  80242a:	8d 74 24 03          	lea    0x3(%esp),%esi
  80242e:	89 f2                	mov    %esi,%edx
  802430:	c1 ea 02             	shr    $0x2,%edx
  802433:	83 e6 fc             	and    $0xfffffffc,%esi
  802436:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802438:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80243b:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc + 1] = NULL;
  802442:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802449:	00 
	va_start(vl, arg0);
  80244a:	8d 4d 10             	lea    0x10(%ebp),%ecx
  80244d:	89 c2                	mov    %eax,%edx
	for (i = 0; i < argc; i++)
  80244f:	b8 00 00 00 00       	mov    $0x0,%eax
  802454:	eb 0b                	jmp    802461 <spawnl+0x9a>
		argv[i + 1] = va_arg(vl, const char *);
  802456:	83 c0 01             	add    $0x1,%eax
  802459:	8b 39                	mov    (%ecx),%edi
  80245b:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  80245e:	8d 49 04             	lea    0x4(%ecx),%ecx
	for (i = 0; i < argc; i++)
  802461:	39 d0                	cmp    %edx,%eax
  802463:	75 f1                	jne    802456 <spawnl+0x8f>
	return spawn(prog, argv);
  802465:	83 ec 08             	sub    $0x8,%esp
  802468:	56                   	push   %esi
  802469:	ff 75 08             	pushl  0x8(%ebp)
  80246c:	e8 0a fd ff ff       	call   80217b <spawn>
}
  802471:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802474:	5b                   	pop    %ebx
  802475:	5e                   	pop    %esi
  802476:	5f                   	pop    %edi
  802477:	5d                   	pop    %ebp
  802478:	c3                   	ret    

00802479 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802479:	f3 0f 1e fb          	endbr32 
  80247d:	55                   	push   %ebp
  80247e:	89 e5                	mov    %esp,%ebp
  802480:	56                   	push   %esi
  802481:	53                   	push   %ebx
  802482:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802485:	83 ec 0c             	sub    $0xc,%esp
  802488:	ff 75 08             	pushl  0x8(%ebp)
  80248b:	e8 82 f1 ff ff       	call   801612 <fd2data>
  802490:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802492:	83 c4 08             	add    $0x8,%esp
  802495:	68 72 34 80 00       	push   $0x803472
  80249a:	53                   	push   %ebx
  80249b:	e8 d1 e6 ff ff       	call   800b71 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8024a0:	8b 46 04             	mov    0x4(%esi),%eax
  8024a3:	2b 06                	sub    (%esi),%eax
  8024a5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8024ab:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8024b2:	00 00 00 
	stat->st_dev = &devpipe;
  8024b5:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  8024bc:	40 80 00 
	return 0;
}
  8024bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8024c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024c7:	5b                   	pop    %ebx
  8024c8:	5e                   	pop    %esi
  8024c9:	5d                   	pop    %ebp
  8024ca:	c3                   	ret    

008024cb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8024cb:	f3 0f 1e fb          	endbr32 
  8024cf:	55                   	push   %ebp
  8024d0:	89 e5                	mov    %esp,%ebp
  8024d2:	53                   	push   %ebx
  8024d3:	83 ec 0c             	sub    $0xc,%esp
  8024d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8024d9:	53                   	push   %ebx
  8024da:	6a 00                	push   $0x0
  8024dc:	e8 6a eb ff ff       	call   80104b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8024e1:	89 1c 24             	mov    %ebx,(%esp)
  8024e4:	e8 29 f1 ff ff       	call   801612 <fd2data>
  8024e9:	83 c4 08             	add    $0x8,%esp
  8024ec:	50                   	push   %eax
  8024ed:	6a 00                	push   $0x0
  8024ef:	e8 57 eb ff ff       	call   80104b <sys_page_unmap>
}
  8024f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024f7:	c9                   	leave  
  8024f8:	c3                   	ret    

008024f9 <_pipeisclosed>:
{
  8024f9:	55                   	push   %ebp
  8024fa:	89 e5                	mov    %esp,%ebp
  8024fc:	57                   	push   %edi
  8024fd:	56                   	push   %esi
  8024fe:	53                   	push   %ebx
  8024ff:	83 ec 1c             	sub    $0x1c,%esp
  802502:	89 c7                	mov    %eax,%edi
  802504:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802506:	a1 04 50 80 00       	mov    0x805004,%eax
  80250b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80250e:	83 ec 0c             	sub    $0xc,%esp
  802511:	57                   	push   %edi
  802512:	e8 b1 04 00 00       	call   8029c8 <pageref>
  802517:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80251a:	89 34 24             	mov    %esi,(%esp)
  80251d:	e8 a6 04 00 00       	call   8029c8 <pageref>
		nn = thisenv->env_runs;
  802522:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802528:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80252b:	83 c4 10             	add    $0x10,%esp
  80252e:	39 cb                	cmp    %ecx,%ebx
  802530:	74 1b                	je     80254d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802532:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802535:	75 cf                	jne    802506 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802537:	8b 42 58             	mov    0x58(%edx),%eax
  80253a:	6a 01                	push   $0x1
  80253c:	50                   	push   %eax
  80253d:	53                   	push   %ebx
  80253e:	68 79 34 80 00       	push   $0x803479
  802543:	e8 bf e0 ff ff       	call   800607 <cprintf>
  802548:	83 c4 10             	add    $0x10,%esp
  80254b:	eb b9                	jmp    802506 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80254d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802550:	0f 94 c0             	sete   %al
  802553:	0f b6 c0             	movzbl %al,%eax
}
  802556:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802559:	5b                   	pop    %ebx
  80255a:	5e                   	pop    %esi
  80255b:	5f                   	pop    %edi
  80255c:	5d                   	pop    %ebp
  80255d:	c3                   	ret    

0080255e <devpipe_write>:
{
  80255e:	f3 0f 1e fb          	endbr32 
  802562:	55                   	push   %ebp
  802563:	89 e5                	mov    %esp,%ebp
  802565:	57                   	push   %edi
  802566:	56                   	push   %esi
  802567:	53                   	push   %ebx
  802568:	83 ec 28             	sub    $0x28,%esp
  80256b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80256e:	56                   	push   %esi
  80256f:	e8 9e f0 ff ff       	call   801612 <fd2data>
  802574:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802576:	83 c4 10             	add    $0x10,%esp
  802579:	bf 00 00 00 00       	mov    $0x0,%edi
  80257e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802581:	74 4f                	je     8025d2 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802583:	8b 43 04             	mov    0x4(%ebx),%eax
  802586:	8b 0b                	mov    (%ebx),%ecx
  802588:	8d 51 20             	lea    0x20(%ecx),%edx
  80258b:	39 d0                	cmp    %edx,%eax
  80258d:	72 14                	jb     8025a3 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  80258f:	89 da                	mov    %ebx,%edx
  802591:	89 f0                	mov    %esi,%eax
  802593:	e8 61 ff ff ff       	call   8024f9 <_pipeisclosed>
  802598:	85 c0                	test   %eax,%eax
  80259a:	75 3b                	jne    8025d7 <devpipe_write+0x79>
			sys_yield();
  80259c:	e8 2d ea ff ff       	call   800fce <sys_yield>
  8025a1:	eb e0                	jmp    802583 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8025a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025a6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8025aa:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8025ad:	89 c2                	mov    %eax,%edx
  8025af:	c1 fa 1f             	sar    $0x1f,%edx
  8025b2:	89 d1                	mov    %edx,%ecx
  8025b4:	c1 e9 1b             	shr    $0x1b,%ecx
  8025b7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8025ba:	83 e2 1f             	and    $0x1f,%edx
  8025bd:	29 ca                	sub    %ecx,%edx
  8025bf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8025c3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8025c7:	83 c0 01             	add    $0x1,%eax
  8025ca:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8025cd:	83 c7 01             	add    $0x1,%edi
  8025d0:	eb ac                	jmp    80257e <devpipe_write+0x20>
	return i;
  8025d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8025d5:	eb 05                	jmp    8025dc <devpipe_write+0x7e>
				return 0;
  8025d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025df:	5b                   	pop    %ebx
  8025e0:	5e                   	pop    %esi
  8025e1:	5f                   	pop    %edi
  8025e2:	5d                   	pop    %ebp
  8025e3:	c3                   	ret    

008025e4 <devpipe_read>:
{
  8025e4:	f3 0f 1e fb          	endbr32 
  8025e8:	55                   	push   %ebp
  8025e9:	89 e5                	mov    %esp,%ebp
  8025eb:	57                   	push   %edi
  8025ec:	56                   	push   %esi
  8025ed:	53                   	push   %ebx
  8025ee:	83 ec 18             	sub    $0x18,%esp
  8025f1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8025f4:	57                   	push   %edi
  8025f5:	e8 18 f0 ff ff       	call   801612 <fd2data>
  8025fa:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8025fc:	83 c4 10             	add    $0x10,%esp
  8025ff:	be 00 00 00 00       	mov    $0x0,%esi
  802604:	3b 75 10             	cmp    0x10(%ebp),%esi
  802607:	75 14                	jne    80261d <devpipe_read+0x39>
	return i;
  802609:	8b 45 10             	mov    0x10(%ebp),%eax
  80260c:	eb 02                	jmp    802610 <devpipe_read+0x2c>
				return i;
  80260e:	89 f0                	mov    %esi,%eax
}
  802610:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802613:	5b                   	pop    %ebx
  802614:	5e                   	pop    %esi
  802615:	5f                   	pop    %edi
  802616:	5d                   	pop    %ebp
  802617:	c3                   	ret    
			sys_yield();
  802618:	e8 b1 e9 ff ff       	call   800fce <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80261d:	8b 03                	mov    (%ebx),%eax
  80261f:	3b 43 04             	cmp    0x4(%ebx),%eax
  802622:	75 18                	jne    80263c <devpipe_read+0x58>
			if (i > 0)
  802624:	85 f6                	test   %esi,%esi
  802626:	75 e6                	jne    80260e <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802628:	89 da                	mov    %ebx,%edx
  80262a:	89 f8                	mov    %edi,%eax
  80262c:	e8 c8 fe ff ff       	call   8024f9 <_pipeisclosed>
  802631:	85 c0                	test   %eax,%eax
  802633:	74 e3                	je     802618 <devpipe_read+0x34>
				return 0;
  802635:	b8 00 00 00 00       	mov    $0x0,%eax
  80263a:	eb d4                	jmp    802610 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80263c:	99                   	cltd   
  80263d:	c1 ea 1b             	shr    $0x1b,%edx
  802640:	01 d0                	add    %edx,%eax
  802642:	83 e0 1f             	and    $0x1f,%eax
  802645:	29 d0                	sub    %edx,%eax
  802647:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80264c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80264f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802652:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802655:	83 c6 01             	add    $0x1,%esi
  802658:	eb aa                	jmp    802604 <devpipe_read+0x20>

0080265a <pipe>:
{
  80265a:	f3 0f 1e fb          	endbr32 
  80265e:	55                   	push   %ebp
  80265f:	89 e5                	mov    %esp,%ebp
  802661:	56                   	push   %esi
  802662:	53                   	push   %ebx
  802663:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802666:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802669:	50                   	push   %eax
  80266a:	e8 c2 ef ff ff       	call   801631 <fd_alloc>
  80266f:	89 c3                	mov    %eax,%ebx
  802671:	83 c4 10             	add    $0x10,%esp
  802674:	85 c0                	test   %eax,%eax
  802676:	0f 88 23 01 00 00    	js     80279f <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80267c:	83 ec 04             	sub    $0x4,%esp
  80267f:	68 07 04 00 00       	push   $0x407
  802684:	ff 75 f4             	pushl  -0xc(%ebp)
  802687:	6a 00                	push   $0x0
  802689:	e8 6b e9 ff ff       	call   800ff9 <sys_page_alloc>
  80268e:	89 c3                	mov    %eax,%ebx
  802690:	83 c4 10             	add    $0x10,%esp
  802693:	85 c0                	test   %eax,%eax
  802695:	0f 88 04 01 00 00    	js     80279f <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80269b:	83 ec 0c             	sub    $0xc,%esp
  80269e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8026a1:	50                   	push   %eax
  8026a2:	e8 8a ef ff ff       	call   801631 <fd_alloc>
  8026a7:	89 c3                	mov    %eax,%ebx
  8026a9:	83 c4 10             	add    $0x10,%esp
  8026ac:	85 c0                	test   %eax,%eax
  8026ae:	0f 88 db 00 00 00    	js     80278f <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026b4:	83 ec 04             	sub    $0x4,%esp
  8026b7:	68 07 04 00 00       	push   $0x407
  8026bc:	ff 75 f0             	pushl  -0x10(%ebp)
  8026bf:	6a 00                	push   $0x0
  8026c1:	e8 33 e9 ff ff       	call   800ff9 <sys_page_alloc>
  8026c6:	89 c3                	mov    %eax,%ebx
  8026c8:	83 c4 10             	add    $0x10,%esp
  8026cb:	85 c0                	test   %eax,%eax
  8026cd:	0f 88 bc 00 00 00    	js     80278f <pipe+0x135>
	va = fd2data(fd0);
  8026d3:	83 ec 0c             	sub    $0xc,%esp
  8026d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8026d9:	e8 34 ef ff ff       	call   801612 <fd2data>
  8026de:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026e0:	83 c4 0c             	add    $0xc,%esp
  8026e3:	68 07 04 00 00       	push   $0x407
  8026e8:	50                   	push   %eax
  8026e9:	6a 00                	push   $0x0
  8026eb:	e8 09 e9 ff ff       	call   800ff9 <sys_page_alloc>
  8026f0:	89 c3                	mov    %eax,%ebx
  8026f2:	83 c4 10             	add    $0x10,%esp
  8026f5:	85 c0                	test   %eax,%eax
  8026f7:	0f 88 82 00 00 00    	js     80277f <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026fd:	83 ec 0c             	sub    $0xc,%esp
  802700:	ff 75 f0             	pushl  -0x10(%ebp)
  802703:	e8 0a ef ff ff       	call   801612 <fd2data>
  802708:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80270f:	50                   	push   %eax
  802710:	6a 00                	push   $0x0
  802712:	56                   	push   %esi
  802713:	6a 00                	push   $0x0
  802715:	e8 07 e9 ff ff       	call   801021 <sys_page_map>
  80271a:	89 c3                	mov    %eax,%ebx
  80271c:	83 c4 20             	add    $0x20,%esp
  80271f:	85 c0                	test   %eax,%eax
  802721:	78 4e                	js     802771 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  802723:	a1 3c 40 80 00       	mov    0x80403c,%eax
  802728:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80272b:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80272d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802730:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802737:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80273a:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80273c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80273f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802746:	83 ec 0c             	sub    $0xc,%esp
  802749:	ff 75 f4             	pushl  -0xc(%ebp)
  80274c:	e8 ad ee ff ff       	call   8015fe <fd2num>
  802751:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802754:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802756:	83 c4 04             	add    $0x4,%esp
  802759:	ff 75 f0             	pushl  -0x10(%ebp)
  80275c:	e8 9d ee ff ff       	call   8015fe <fd2num>
  802761:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802764:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802767:	83 c4 10             	add    $0x10,%esp
  80276a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80276f:	eb 2e                	jmp    80279f <pipe+0x145>
	sys_page_unmap(0, va);
  802771:	83 ec 08             	sub    $0x8,%esp
  802774:	56                   	push   %esi
  802775:	6a 00                	push   $0x0
  802777:	e8 cf e8 ff ff       	call   80104b <sys_page_unmap>
  80277c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80277f:	83 ec 08             	sub    $0x8,%esp
  802782:	ff 75 f0             	pushl  -0x10(%ebp)
  802785:	6a 00                	push   $0x0
  802787:	e8 bf e8 ff ff       	call   80104b <sys_page_unmap>
  80278c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80278f:	83 ec 08             	sub    $0x8,%esp
  802792:	ff 75 f4             	pushl  -0xc(%ebp)
  802795:	6a 00                	push   $0x0
  802797:	e8 af e8 ff ff       	call   80104b <sys_page_unmap>
  80279c:	83 c4 10             	add    $0x10,%esp
}
  80279f:	89 d8                	mov    %ebx,%eax
  8027a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8027a4:	5b                   	pop    %ebx
  8027a5:	5e                   	pop    %esi
  8027a6:	5d                   	pop    %ebp
  8027a7:	c3                   	ret    

008027a8 <pipeisclosed>:
{
  8027a8:	f3 0f 1e fb          	endbr32 
  8027ac:	55                   	push   %ebp
  8027ad:	89 e5                	mov    %esp,%ebp
  8027af:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8027b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027b5:	50                   	push   %eax
  8027b6:	ff 75 08             	pushl  0x8(%ebp)
  8027b9:	e8 c9 ee ff ff       	call   801687 <fd_lookup>
  8027be:	83 c4 10             	add    $0x10,%esp
  8027c1:	85 c0                	test   %eax,%eax
  8027c3:	78 18                	js     8027dd <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  8027c5:	83 ec 0c             	sub    $0xc,%esp
  8027c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8027cb:	e8 42 ee ff ff       	call   801612 <fd2data>
  8027d0:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8027d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027d5:	e8 1f fd ff ff       	call   8024f9 <_pipeisclosed>
  8027da:	83 c4 10             	add    $0x10,%esp
}
  8027dd:	c9                   	leave  
  8027de:	c3                   	ret    

008027df <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8027df:	f3 0f 1e fb          	endbr32 
  8027e3:	55                   	push   %ebp
  8027e4:	89 e5                	mov    %esp,%ebp
  8027e6:	56                   	push   %esi
  8027e7:	53                   	push   %ebx
  8027e8:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8027eb:	85 f6                	test   %esi,%esi
  8027ed:	74 13                	je     802802 <wait+0x23>
	e = &envs[ENVX(envid)];
  8027ef:	89 f3                	mov    %esi,%ebx
  8027f1:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8027f7:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8027fa:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802800:	eb 1b                	jmp    80281d <wait+0x3e>
	assert(envid != 0);
  802802:	68 91 34 80 00       	push   $0x803491
  802807:	68 93 33 80 00       	push   $0x803393
  80280c:	6a 09                	push   $0x9
  80280e:	68 9c 34 80 00       	push   $0x80349c
  802813:	e8 08 dd ff ff       	call   800520 <_panic>
		sys_yield();
  802818:	e8 b1 e7 ff ff       	call   800fce <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80281d:	8b 43 48             	mov    0x48(%ebx),%eax
  802820:	39 f0                	cmp    %esi,%eax
  802822:	75 07                	jne    80282b <wait+0x4c>
  802824:	8b 43 54             	mov    0x54(%ebx),%eax
  802827:	85 c0                	test   %eax,%eax
  802829:	75 ed                	jne    802818 <wait+0x39>
}
  80282b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80282e:	5b                   	pop    %ebx
  80282f:	5e                   	pop    %esi
  802830:	5d                   	pop    %ebp
  802831:	c3                   	ret    

00802832 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802832:	f3 0f 1e fb          	endbr32 
  802836:	55                   	push   %ebp
  802837:	89 e5                	mov    %esp,%ebp
  802839:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  80283c:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802843:	74 0a                	je     80284f <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802845:	8b 45 08             	mov    0x8(%ebp),%eax
  802848:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80284d:	c9                   	leave  
  80284e:	c3                   	ret    
		if (sys_page_alloc(0,
  80284f:	83 ec 04             	sub    $0x4,%esp
  802852:	6a 07                	push   $0x7
  802854:	68 00 f0 bf ee       	push   $0xeebff000
  802859:	6a 00                	push   $0x0
  80285b:	e8 99 e7 ff ff       	call   800ff9 <sys_page_alloc>
  802860:	83 c4 10             	add    $0x10,%esp
  802863:	85 c0                	test   %eax,%eax
  802865:	78 2a                	js     802891 <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  802867:	83 ec 08             	sub    $0x8,%esp
  80286a:	68 a5 28 80 00       	push   $0x8028a5
  80286f:	6a 00                	push   $0x0
  802871:	e8 4a e8 ff ff       	call   8010c0 <sys_env_set_pgfault_upcall>
  802876:	83 c4 10             	add    $0x10,%esp
  802879:	85 c0                	test   %eax,%eax
  80287b:	79 c8                	jns    802845 <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  80287d:	83 ec 04             	sub    $0x4,%esp
  802880:	68 dc 34 80 00       	push   $0x8034dc
  802885:	6a 25                	push   $0x25
  802887:	68 23 35 80 00       	push   $0x803523
  80288c:	e8 8f dc ff ff       	call   800520 <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  802891:	83 ec 04             	sub    $0x4,%esp
  802894:	68 a8 34 80 00       	push   $0x8034a8
  802899:	6a 21                	push   $0x21
  80289b:	68 23 35 80 00       	push   $0x803523
  8028a0:	e8 7b dc ff ff       	call   800520 <_panic>

008028a5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8028a5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8028a6:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8028ab:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8028ad:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  8028b0:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  8028b5:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  8028b9:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8028bd:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8028bf:	83 c4 08             	add    $0x8,%esp
	popal
  8028c2:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  8028c3:	83 c4 04             	add    $0x4,%esp
	popfl
  8028c6:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  8028c7:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8028ca:	c3                   	ret    

008028cb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8028cb:	f3 0f 1e fb          	endbr32 
  8028cf:	55                   	push   %ebp
  8028d0:	89 e5                	mov    %esp,%ebp
  8028d2:	56                   	push   %esi
  8028d3:	53                   	push   %ebx
  8028d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8028d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  8028dd:	85 c0                	test   %eax,%eax
  8028df:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8028e4:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  8028e7:	83 ec 0c             	sub    $0xc,%esp
  8028ea:	50                   	push   %eax
  8028eb:	e8 20 e8 ff ff       	call   801110 <sys_ipc_recv>
	if (f < 0) {
  8028f0:	83 c4 10             	add    $0x10,%esp
  8028f3:	85 c0                	test   %eax,%eax
  8028f5:	78 2b                	js     802922 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  8028f7:	85 f6                	test   %esi,%esi
  8028f9:	74 0a                	je     802905 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  8028fb:	a1 04 50 80 00       	mov    0x805004,%eax
  802900:	8b 40 74             	mov    0x74(%eax),%eax
  802903:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  802905:	85 db                	test   %ebx,%ebx
  802907:	74 0a                	je     802913 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  802909:	a1 04 50 80 00       	mov    0x805004,%eax
  80290e:	8b 40 78             	mov    0x78(%eax),%eax
  802911:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  802913:	a1 04 50 80 00       	mov    0x805004,%eax
  802918:	8b 40 70             	mov    0x70(%eax),%eax
}
  80291b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80291e:	5b                   	pop    %ebx
  80291f:	5e                   	pop    %esi
  802920:	5d                   	pop    %ebp
  802921:	c3                   	ret    
		if (from_env_store != NULL) {
  802922:	85 f6                	test   %esi,%esi
  802924:	74 06                	je     80292c <ipc_recv+0x61>
			*from_env_store = 0;
  802926:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  80292c:	85 db                	test   %ebx,%ebx
  80292e:	74 eb                	je     80291b <ipc_recv+0x50>
			*perm_store = 0;
  802930:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802936:	eb e3                	jmp    80291b <ipc_recv+0x50>

00802938 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802938:	f3 0f 1e fb          	endbr32 
  80293c:	55                   	push   %ebp
  80293d:	89 e5                	mov    %esp,%ebp
  80293f:	57                   	push   %edi
  802940:	56                   	push   %esi
  802941:	53                   	push   %ebx
  802942:	83 ec 0c             	sub    $0xc,%esp
  802945:	8b 7d 08             	mov    0x8(%ebp),%edi
  802948:	8b 75 0c             	mov    0xc(%ebp),%esi
  80294b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  80294e:	85 db                	test   %ebx,%ebx
  802950:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802955:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802958:	ff 75 14             	pushl  0x14(%ebp)
  80295b:	53                   	push   %ebx
  80295c:	56                   	push   %esi
  80295d:	57                   	push   %edi
  80295e:	e8 84 e7 ff ff       	call   8010e7 <sys_ipc_try_send>
  802963:	83 c4 10             	add    $0x10,%esp
  802966:	85 c0                	test   %eax,%eax
  802968:	79 19                	jns    802983 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  80296a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80296d:	74 e9                	je     802958 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  80296f:	83 ec 04             	sub    $0x4,%esp
  802972:	68 34 35 80 00       	push   $0x803534
  802977:	6a 48                	push   $0x48
  802979:	68 56 35 80 00       	push   $0x803556
  80297e:	e8 9d db ff ff       	call   800520 <_panic>
		}
	}
}
  802983:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802986:	5b                   	pop    %ebx
  802987:	5e                   	pop    %esi
  802988:	5f                   	pop    %edi
  802989:	5d                   	pop    %ebp
  80298a:	c3                   	ret    

0080298b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80298b:	f3 0f 1e fb          	endbr32 
  80298f:	55                   	push   %ebp
  802990:	89 e5                	mov    %esp,%ebp
  802992:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802995:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80299a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80299d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8029a3:	8b 52 50             	mov    0x50(%edx),%edx
  8029a6:	39 ca                	cmp    %ecx,%edx
  8029a8:	74 11                	je     8029bb <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8029aa:	83 c0 01             	add    $0x1,%eax
  8029ad:	3d 00 04 00 00       	cmp    $0x400,%eax
  8029b2:	75 e6                	jne    80299a <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8029b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8029b9:	eb 0b                	jmp    8029c6 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8029bb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8029be:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8029c3:	8b 40 48             	mov    0x48(%eax),%eax
}
  8029c6:	5d                   	pop    %ebp
  8029c7:	c3                   	ret    

008029c8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8029c8:	f3 0f 1e fb          	endbr32 
  8029cc:	55                   	push   %ebp
  8029cd:	89 e5                	mov    %esp,%ebp
  8029cf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029d2:	89 c2                	mov    %eax,%edx
  8029d4:	c1 ea 16             	shr    $0x16,%edx
  8029d7:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8029de:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8029e3:	f6 c1 01             	test   $0x1,%cl
  8029e6:	74 1c                	je     802a04 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8029e8:	c1 e8 0c             	shr    $0xc,%eax
  8029eb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8029f2:	a8 01                	test   $0x1,%al
  8029f4:	74 0e                	je     802a04 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8029f6:	c1 e8 0c             	shr    $0xc,%eax
  8029f9:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802a00:	ef 
  802a01:	0f b7 d2             	movzwl %dx,%edx
}
  802a04:	89 d0                	mov    %edx,%eax
  802a06:	5d                   	pop    %ebp
  802a07:	c3                   	ret    
  802a08:	66 90                	xchg   %ax,%ax
  802a0a:	66 90                	xchg   %ax,%ax
  802a0c:	66 90                	xchg   %ax,%ax
  802a0e:	66 90                	xchg   %ax,%ax

00802a10 <__udivdi3>:
  802a10:	f3 0f 1e fb          	endbr32 
  802a14:	55                   	push   %ebp
  802a15:	57                   	push   %edi
  802a16:	56                   	push   %esi
  802a17:	53                   	push   %ebx
  802a18:	83 ec 1c             	sub    $0x1c,%esp
  802a1b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802a1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802a23:	8b 74 24 34          	mov    0x34(%esp),%esi
  802a27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802a2b:	85 d2                	test   %edx,%edx
  802a2d:	75 19                	jne    802a48 <__udivdi3+0x38>
  802a2f:	39 f3                	cmp    %esi,%ebx
  802a31:	76 4d                	jbe    802a80 <__udivdi3+0x70>
  802a33:	31 ff                	xor    %edi,%edi
  802a35:	89 e8                	mov    %ebp,%eax
  802a37:	89 f2                	mov    %esi,%edx
  802a39:	f7 f3                	div    %ebx
  802a3b:	89 fa                	mov    %edi,%edx
  802a3d:	83 c4 1c             	add    $0x1c,%esp
  802a40:	5b                   	pop    %ebx
  802a41:	5e                   	pop    %esi
  802a42:	5f                   	pop    %edi
  802a43:	5d                   	pop    %ebp
  802a44:	c3                   	ret    
  802a45:	8d 76 00             	lea    0x0(%esi),%esi
  802a48:	39 f2                	cmp    %esi,%edx
  802a4a:	76 14                	jbe    802a60 <__udivdi3+0x50>
  802a4c:	31 ff                	xor    %edi,%edi
  802a4e:	31 c0                	xor    %eax,%eax
  802a50:	89 fa                	mov    %edi,%edx
  802a52:	83 c4 1c             	add    $0x1c,%esp
  802a55:	5b                   	pop    %ebx
  802a56:	5e                   	pop    %esi
  802a57:	5f                   	pop    %edi
  802a58:	5d                   	pop    %ebp
  802a59:	c3                   	ret    
  802a5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802a60:	0f bd fa             	bsr    %edx,%edi
  802a63:	83 f7 1f             	xor    $0x1f,%edi
  802a66:	75 48                	jne    802ab0 <__udivdi3+0xa0>
  802a68:	39 f2                	cmp    %esi,%edx
  802a6a:	72 06                	jb     802a72 <__udivdi3+0x62>
  802a6c:	31 c0                	xor    %eax,%eax
  802a6e:	39 eb                	cmp    %ebp,%ebx
  802a70:	77 de                	ja     802a50 <__udivdi3+0x40>
  802a72:	b8 01 00 00 00       	mov    $0x1,%eax
  802a77:	eb d7                	jmp    802a50 <__udivdi3+0x40>
  802a79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a80:	89 d9                	mov    %ebx,%ecx
  802a82:	85 db                	test   %ebx,%ebx
  802a84:	75 0b                	jne    802a91 <__udivdi3+0x81>
  802a86:	b8 01 00 00 00       	mov    $0x1,%eax
  802a8b:	31 d2                	xor    %edx,%edx
  802a8d:	f7 f3                	div    %ebx
  802a8f:	89 c1                	mov    %eax,%ecx
  802a91:	31 d2                	xor    %edx,%edx
  802a93:	89 f0                	mov    %esi,%eax
  802a95:	f7 f1                	div    %ecx
  802a97:	89 c6                	mov    %eax,%esi
  802a99:	89 e8                	mov    %ebp,%eax
  802a9b:	89 f7                	mov    %esi,%edi
  802a9d:	f7 f1                	div    %ecx
  802a9f:	89 fa                	mov    %edi,%edx
  802aa1:	83 c4 1c             	add    $0x1c,%esp
  802aa4:	5b                   	pop    %ebx
  802aa5:	5e                   	pop    %esi
  802aa6:	5f                   	pop    %edi
  802aa7:	5d                   	pop    %ebp
  802aa8:	c3                   	ret    
  802aa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ab0:	89 f9                	mov    %edi,%ecx
  802ab2:	b8 20 00 00 00       	mov    $0x20,%eax
  802ab7:	29 f8                	sub    %edi,%eax
  802ab9:	d3 e2                	shl    %cl,%edx
  802abb:	89 54 24 08          	mov    %edx,0x8(%esp)
  802abf:	89 c1                	mov    %eax,%ecx
  802ac1:	89 da                	mov    %ebx,%edx
  802ac3:	d3 ea                	shr    %cl,%edx
  802ac5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802ac9:	09 d1                	or     %edx,%ecx
  802acb:	89 f2                	mov    %esi,%edx
  802acd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802ad1:	89 f9                	mov    %edi,%ecx
  802ad3:	d3 e3                	shl    %cl,%ebx
  802ad5:	89 c1                	mov    %eax,%ecx
  802ad7:	d3 ea                	shr    %cl,%edx
  802ad9:	89 f9                	mov    %edi,%ecx
  802adb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802adf:	89 eb                	mov    %ebp,%ebx
  802ae1:	d3 e6                	shl    %cl,%esi
  802ae3:	89 c1                	mov    %eax,%ecx
  802ae5:	d3 eb                	shr    %cl,%ebx
  802ae7:	09 de                	or     %ebx,%esi
  802ae9:	89 f0                	mov    %esi,%eax
  802aeb:	f7 74 24 08          	divl   0x8(%esp)
  802aef:	89 d6                	mov    %edx,%esi
  802af1:	89 c3                	mov    %eax,%ebx
  802af3:	f7 64 24 0c          	mull   0xc(%esp)
  802af7:	39 d6                	cmp    %edx,%esi
  802af9:	72 15                	jb     802b10 <__udivdi3+0x100>
  802afb:	89 f9                	mov    %edi,%ecx
  802afd:	d3 e5                	shl    %cl,%ebp
  802aff:	39 c5                	cmp    %eax,%ebp
  802b01:	73 04                	jae    802b07 <__udivdi3+0xf7>
  802b03:	39 d6                	cmp    %edx,%esi
  802b05:	74 09                	je     802b10 <__udivdi3+0x100>
  802b07:	89 d8                	mov    %ebx,%eax
  802b09:	31 ff                	xor    %edi,%edi
  802b0b:	e9 40 ff ff ff       	jmp    802a50 <__udivdi3+0x40>
  802b10:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802b13:	31 ff                	xor    %edi,%edi
  802b15:	e9 36 ff ff ff       	jmp    802a50 <__udivdi3+0x40>
  802b1a:	66 90                	xchg   %ax,%ax
  802b1c:	66 90                	xchg   %ax,%ax
  802b1e:	66 90                	xchg   %ax,%ax

00802b20 <__umoddi3>:
  802b20:	f3 0f 1e fb          	endbr32 
  802b24:	55                   	push   %ebp
  802b25:	57                   	push   %edi
  802b26:	56                   	push   %esi
  802b27:	53                   	push   %ebx
  802b28:	83 ec 1c             	sub    $0x1c,%esp
  802b2b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802b2f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802b33:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802b37:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802b3b:	85 c0                	test   %eax,%eax
  802b3d:	75 19                	jne    802b58 <__umoddi3+0x38>
  802b3f:	39 df                	cmp    %ebx,%edi
  802b41:	76 5d                	jbe    802ba0 <__umoddi3+0x80>
  802b43:	89 f0                	mov    %esi,%eax
  802b45:	89 da                	mov    %ebx,%edx
  802b47:	f7 f7                	div    %edi
  802b49:	89 d0                	mov    %edx,%eax
  802b4b:	31 d2                	xor    %edx,%edx
  802b4d:	83 c4 1c             	add    $0x1c,%esp
  802b50:	5b                   	pop    %ebx
  802b51:	5e                   	pop    %esi
  802b52:	5f                   	pop    %edi
  802b53:	5d                   	pop    %ebp
  802b54:	c3                   	ret    
  802b55:	8d 76 00             	lea    0x0(%esi),%esi
  802b58:	89 f2                	mov    %esi,%edx
  802b5a:	39 d8                	cmp    %ebx,%eax
  802b5c:	76 12                	jbe    802b70 <__umoddi3+0x50>
  802b5e:	89 f0                	mov    %esi,%eax
  802b60:	89 da                	mov    %ebx,%edx
  802b62:	83 c4 1c             	add    $0x1c,%esp
  802b65:	5b                   	pop    %ebx
  802b66:	5e                   	pop    %esi
  802b67:	5f                   	pop    %edi
  802b68:	5d                   	pop    %ebp
  802b69:	c3                   	ret    
  802b6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b70:	0f bd e8             	bsr    %eax,%ebp
  802b73:	83 f5 1f             	xor    $0x1f,%ebp
  802b76:	75 50                	jne    802bc8 <__umoddi3+0xa8>
  802b78:	39 d8                	cmp    %ebx,%eax
  802b7a:	0f 82 e0 00 00 00    	jb     802c60 <__umoddi3+0x140>
  802b80:	89 d9                	mov    %ebx,%ecx
  802b82:	39 f7                	cmp    %esi,%edi
  802b84:	0f 86 d6 00 00 00    	jbe    802c60 <__umoddi3+0x140>
  802b8a:	89 d0                	mov    %edx,%eax
  802b8c:	89 ca                	mov    %ecx,%edx
  802b8e:	83 c4 1c             	add    $0x1c,%esp
  802b91:	5b                   	pop    %ebx
  802b92:	5e                   	pop    %esi
  802b93:	5f                   	pop    %edi
  802b94:	5d                   	pop    %ebp
  802b95:	c3                   	ret    
  802b96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b9d:	8d 76 00             	lea    0x0(%esi),%esi
  802ba0:	89 fd                	mov    %edi,%ebp
  802ba2:	85 ff                	test   %edi,%edi
  802ba4:	75 0b                	jne    802bb1 <__umoddi3+0x91>
  802ba6:	b8 01 00 00 00       	mov    $0x1,%eax
  802bab:	31 d2                	xor    %edx,%edx
  802bad:	f7 f7                	div    %edi
  802baf:	89 c5                	mov    %eax,%ebp
  802bb1:	89 d8                	mov    %ebx,%eax
  802bb3:	31 d2                	xor    %edx,%edx
  802bb5:	f7 f5                	div    %ebp
  802bb7:	89 f0                	mov    %esi,%eax
  802bb9:	f7 f5                	div    %ebp
  802bbb:	89 d0                	mov    %edx,%eax
  802bbd:	31 d2                	xor    %edx,%edx
  802bbf:	eb 8c                	jmp    802b4d <__umoddi3+0x2d>
  802bc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802bc8:	89 e9                	mov    %ebp,%ecx
  802bca:	ba 20 00 00 00       	mov    $0x20,%edx
  802bcf:	29 ea                	sub    %ebp,%edx
  802bd1:	d3 e0                	shl    %cl,%eax
  802bd3:	89 44 24 08          	mov    %eax,0x8(%esp)
  802bd7:	89 d1                	mov    %edx,%ecx
  802bd9:	89 f8                	mov    %edi,%eax
  802bdb:	d3 e8                	shr    %cl,%eax
  802bdd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802be1:	89 54 24 04          	mov    %edx,0x4(%esp)
  802be5:	8b 54 24 04          	mov    0x4(%esp),%edx
  802be9:	09 c1                	or     %eax,%ecx
  802beb:	89 d8                	mov    %ebx,%eax
  802bed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802bf1:	89 e9                	mov    %ebp,%ecx
  802bf3:	d3 e7                	shl    %cl,%edi
  802bf5:	89 d1                	mov    %edx,%ecx
  802bf7:	d3 e8                	shr    %cl,%eax
  802bf9:	89 e9                	mov    %ebp,%ecx
  802bfb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802bff:	d3 e3                	shl    %cl,%ebx
  802c01:	89 c7                	mov    %eax,%edi
  802c03:	89 d1                	mov    %edx,%ecx
  802c05:	89 f0                	mov    %esi,%eax
  802c07:	d3 e8                	shr    %cl,%eax
  802c09:	89 e9                	mov    %ebp,%ecx
  802c0b:	89 fa                	mov    %edi,%edx
  802c0d:	d3 e6                	shl    %cl,%esi
  802c0f:	09 d8                	or     %ebx,%eax
  802c11:	f7 74 24 08          	divl   0x8(%esp)
  802c15:	89 d1                	mov    %edx,%ecx
  802c17:	89 f3                	mov    %esi,%ebx
  802c19:	f7 64 24 0c          	mull   0xc(%esp)
  802c1d:	89 c6                	mov    %eax,%esi
  802c1f:	89 d7                	mov    %edx,%edi
  802c21:	39 d1                	cmp    %edx,%ecx
  802c23:	72 06                	jb     802c2b <__umoddi3+0x10b>
  802c25:	75 10                	jne    802c37 <__umoddi3+0x117>
  802c27:	39 c3                	cmp    %eax,%ebx
  802c29:	73 0c                	jae    802c37 <__umoddi3+0x117>
  802c2b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  802c2f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802c33:	89 d7                	mov    %edx,%edi
  802c35:	89 c6                	mov    %eax,%esi
  802c37:	89 ca                	mov    %ecx,%edx
  802c39:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802c3e:	29 f3                	sub    %esi,%ebx
  802c40:	19 fa                	sbb    %edi,%edx
  802c42:	89 d0                	mov    %edx,%eax
  802c44:	d3 e0                	shl    %cl,%eax
  802c46:	89 e9                	mov    %ebp,%ecx
  802c48:	d3 eb                	shr    %cl,%ebx
  802c4a:	d3 ea                	shr    %cl,%edx
  802c4c:	09 d8                	or     %ebx,%eax
  802c4e:	83 c4 1c             	add    $0x1c,%esp
  802c51:	5b                   	pop    %ebx
  802c52:	5e                   	pop    %esi
  802c53:	5f                   	pop    %edi
  802c54:	5d                   	pop    %ebp
  802c55:	c3                   	ret    
  802c56:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c5d:	8d 76 00             	lea    0x0(%esi),%esi
  802c60:	29 fe                	sub    %edi,%esi
  802c62:	19 c3                	sbb    %eax,%ebx
  802c64:	89 f2                	mov    %esi,%edx
  802c66:	89 d9                	mov    %ebx,%ecx
  802c68:	e9 1d ff ff ff       	jmp    802b8a <__umoddi3+0x6a>
