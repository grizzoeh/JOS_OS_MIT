
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 f9 09 00 00       	call   800a2a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 0c             	sub    $0xc,%esp
  800040:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800043:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int t;

	if (s == 0) {
  800046:	85 db                	test   %ebx,%ebx
  800048:	74 1a                	je     800064 <_gettoken+0x31>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
	}

	if (debug > 1)
  80004a:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800051:	7f 31                	jg     800084 <_gettoken+0x51>
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
  800053:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	*p2 = 0;
  800059:	8b 45 10             	mov    0x10(%ebp),%eax
  80005c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  800062:	eb 3a                	jmp    80009e <_gettoken+0x6b>
		return 0;
  800064:	be 00 00 00 00       	mov    $0x0,%esi
		if (debug > 1)
  800069:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800070:	7e 59                	jle    8000cb <_gettoken+0x98>
			cprintf("GETTOKEN NULL\n");
  800072:	83 ec 0c             	sub    $0xc,%esp
  800075:	68 60 35 80 00       	push   $0x803560
  80007a:	e8 fe 0a 00 00       	call   800b7d <cprintf>
  80007f:	83 c4 10             	add    $0x10,%esp
  800082:	eb 47                	jmp    8000cb <_gettoken+0x98>
		cprintf("GETTOKEN: %s\n", s);
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	53                   	push   %ebx
  800088:	68 6f 35 80 00       	push   $0x80356f
  80008d:	e8 eb 0a 00 00       	call   800b7d <cprintf>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	eb bc                	jmp    800053 <_gettoken+0x20>
		*s++ = 0;
  800097:	83 c3 01             	add    $0x1,%ebx
  80009a:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
	while (strchr(WHITESPACE, *s))
  80009e:	83 ec 08             	sub    $0x8,%esp
  8000a1:	0f be 03             	movsbl (%ebx),%eax
  8000a4:	50                   	push   %eax
  8000a5:	68 7d 35 80 00       	push   $0x80357d
  8000aa:	e8 51 12 00 00       	call   801300 <strchr>
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	75 e1                	jne    800097 <_gettoken+0x64>
	if (*s == 0) {
  8000b6:	0f b6 03             	movzbl (%ebx),%eax
  8000b9:	84 c0                	test   %al,%al
  8000bb:	75 2a                	jne    8000e7 <_gettoken+0xb4>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000bd:	be 00 00 00 00       	mov    $0x0,%esi
		if (debug > 1)
  8000c2:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000c9:	7f 0a                	jg     8000d5 <_gettoken+0xa2>
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
}
  8000cb:	89 f0                	mov    %esi,%eax
  8000cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d0:	5b                   	pop    %ebx
  8000d1:	5e                   	pop    %esi
  8000d2:	5f                   	pop    %edi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    
			cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 82 35 80 00       	push   $0x803582
  8000dd:	e8 9b 0a 00 00       	call   800b7d <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb e4                	jmp    8000cb <_gettoken+0x98>
	if (strchr(SYMBOLS, *s)) {
  8000e7:	83 ec 08             	sub    $0x8,%esp
  8000ea:	0f be c0             	movsbl %al,%eax
  8000ed:	50                   	push   %eax
  8000ee:	68 93 35 80 00       	push   $0x803593
  8000f3:	e8 08 12 00 00       	call   801300 <strchr>
  8000f8:	83 c4 10             	add    $0x10,%esp
  8000fb:	85 c0                	test   %eax,%eax
  8000fd:	74 2c                	je     80012b <_gettoken+0xf8>
		t = *s;
  8000ff:	0f be 33             	movsbl (%ebx),%esi
		*p1 = s;
  800102:	89 1f                	mov    %ebx,(%edi)
		*s++ = 0;
  800104:	c6 03 00             	movb   $0x0,(%ebx)
  800107:	83 c3 01             	add    $0x1,%ebx
  80010a:	8b 45 10             	mov    0x10(%ebp),%eax
  80010d:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
  80010f:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800116:	7e b3                	jle    8000cb <_gettoken+0x98>
			cprintf("TOK %c\n", t);
  800118:	83 ec 08             	sub    $0x8,%esp
  80011b:	56                   	push   %esi
  80011c:	68 87 35 80 00       	push   $0x803587
  800121:	e8 57 0a 00 00       	call   800b7d <cprintf>
  800126:	83 c4 10             	add    $0x10,%esp
  800129:	eb a0                	jmp    8000cb <_gettoken+0x98>
	*p1 = s;
  80012b:	89 1f                	mov    %ebx,(%edi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80012d:	eb 03                	jmp    800132 <_gettoken+0xff>
		s++;
  80012f:	83 c3 01             	add    $0x1,%ebx
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800132:	0f b6 03             	movzbl (%ebx),%eax
  800135:	84 c0                	test   %al,%al
  800137:	74 18                	je     800151 <_gettoken+0x11e>
  800139:	83 ec 08             	sub    $0x8,%esp
  80013c:	0f be c0             	movsbl %al,%eax
  80013f:	50                   	push   %eax
  800140:	68 8f 35 80 00       	push   $0x80358f
  800145:	e8 b6 11 00 00       	call   801300 <strchr>
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	85 c0                	test   %eax,%eax
  80014f:	74 de                	je     80012f <_gettoken+0xfc>
	*p2 = s;
  800151:	8b 45 10             	mov    0x10(%ebp),%eax
  800154:	89 18                	mov    %ebx,(%eax)
	return 'w';
  800156:	be 77 00 00 00       	mov    $0x77,%esi
	if (debug > 1) {
  80015b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800162:	0f 8e 63 ff ff ff    	jle    8000cb <_gettoken+0x98>
		t = **p2;
  800168:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  80016b:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  80016e:	83 ec 08             	sub    $0x8,%esp
  800171:	ff 37                	pushl  (%edi)
  800173:	68 9b 35 80 00       	push   $0x80359b
  800178:	e8 00 0a 00 00       	call   800b7d <cprintf>
		**p2 = t;
  80017d:	8b 45 10             	mov    0x10(%ebp),%eax
  800180:	8b 00                	mov    (%eax),%eax
  800182:	89 f2                	mov    %esi,%edx
  800184:	88 10                	mov    %dl,(%eax)
  800186:	83 c4 10             	add    $0x10,%esp
	return 'w';
  800189:	be 77 00 00 00       	mov    $0x77,%esi
  80018e:	e9 38 ff ff ff       	jmp    8000cb <_gettoken+0x98>

00800193 <gettoken>:

int
gettoken(char *s, char **p1)
{
  800193:	f3 0f 1e fb          	endbr32 
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	83 ec 08             	sub    $0x8,%esp
  80019d:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char *np1, *np2;

	if (s) {
  8001a0:	85 c0                	test   %eax,%eax
  8001a2:	74 22                	je     8001c6 <gettoken+0x33>
		nc = _gettoken(s, &np1, &np2);
  8001a4:	83 ec 04             	sub    $0x4,%esp
  8001a7:	68 0c 50 80 00       	push   $0x80500c
  8001ac:	68 10 50 80 00       	push   $0x805010
  8001b1:	50                   	push   %eax
  8001b2:	e8 7c fe ff ff       	call   800033 <_gettoken>
  8001b7:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001bc:	83 c4 10             	add    $0x10,%esp
  8001bf:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	c = nc;
	*p1 = np1;
	nc = _gettoken(np2, &np1, &np2);
	return c;
}
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    
	c = nc;
  8001c6:	a1 08 50 80 00       	mov    0x805008,%eax
  8001cb:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001d0:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d9:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001db:	83 ec 04             	sub    $0x4,%esp
  8001de:	68 0c 50 80 00       	push   $0x80500c
  8001e3:	68 10 50 80 00       	push   $0x805010
  8001e8:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001ee:	e8 40 fe ff ff       	call   800033 <_gettoken>
  8001f3:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001f8:	a1 04 50 80 00       	mov    0x805004,%eax
  8001fd:	83 c4 10             	add    $0x10,%esp
  800200:	eb c2                	jmp    8001c4 <gettoken+0x31>

00800202 <runcmd>:
{
  800202:	f3 0f 1e fb          	endbr32 
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	81 ec 64 04 00 00    	sub    $0x464,%esp
	gettoken(s, 0);
  800212:	6a 00                	push   $0x0
  800214:	ff 75 08             	pushl  0x8(%ebp)
  800217:	e8 77 ff ff ff       	call   800193 <gettoken>
  80021c:	83 c4 10             	add    $0x10,%esp
		switch ((c = gettoken(0, &t))) {
  80021f:	8d 75 a4             	lea    -0x5c(%ebp),%esi
	argc = 0;
  800222:	bf 00 00 00 00       	mov    $0x0,%edi
		switch ((c = gettoken(0, &t))) {
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	6a 00                	push   $0x0
  80022d:	e8 61 ff ff ff       	call   800193 <gettoken>
  800232:	89 c3                	mov    %eax,%ebx
  800234:	83 c4 10             	add    $0x10,%esp
  800237:	83 f8 3e             	cmp    $0x3e,%eax
  80023a:	0f 84 1e 01 00 00    	je     80035e <runcmd+0x15c>
  800240:	7f 49                	jg     80028b <runcmd+0x89>
  800242:	85 c0                	test   %eax,%eax
  800244:	0f 84 08 02 00 00    	je     800452 <runcmd+0x250>
  80024a:	83 f8 3c             	cmp    $0x3c,%eax
  80024d:	0f 85 db 02 00 00    	jne    80052e <runcmd+0x32c>
			if (gettoken(0, &t) != 'w') {
  800253:	83 ec 08             	sub    $0x8,%esp
  800256:	56                   	push   %esi
  800257:	6a 00                	push   $0x0
  800259:	e8 35 ff ff ff       	call   800193 <gettoken>
  80025e:	83 c4 10             	add    $0x10,%esp
  800261:	83 f8 77             	cmp    $0x77,%eax
  800264:	0f 85 ba 00 00 00    	jne    800324 <runcmd+0x122>
			if ((fd = open(t, O_RDONLY)) < 0) {
  80026a:	83 ec 08             	sub    $0x8,%esp
  80026d:	6a 00                	push   $0x0
  80026f:	ff 75 a4             	pushl  -0x5c(%ebp)
  800272:	e8 16 23 00 00       	call   80258d <open>
  800277:	89 c3                	mov    %eax,%ebx
  800279:	83 c4 10             	add    $0x10,%esp
  80027c:	85 c0                	test   %eax,%eax
  80027e:	0f 88 ba 00 00 00    	js     80033e <runcmd+0x13c>
			if (fd != 0) {
  800284:	74 a1                	je     800227 <runcmd+0x25>
  800286:	e9 b8 00 00 00       	jmp    800343 <runcmd+0x141>
		switch ((c = gettoken(0, &t))) {
  80028b:	83 f8 77             	cmp    $0x77,%eax
  80028e:	74 69                	je     8002f9 <runcmd+0xf7>
  800290:	83 f8 7c             	cmp    $0x7c,%eax
  800293:	0f 85 95 02 00 00    	jne    80052e <runcmd+0x32c>
			if ((r = pipe(p)) < 0) {
  800299:	83 ec 0c             	sub    $0xc,%esp
  80029c:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  8002a2:	50                   	push   %eax
  8002a3:	e8 9f 2c 00 00       	call   802f47 <pipe>
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	85 c0                	test   %eax,%eax
  8002ad:	0f 88 2d 01 00 00    	js     8003e0 <runcmd+0x1de>
			if (debug)
  8002b3:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8002ba:	0f 85 3b 01 00 00    	jne    8003fb <runcmd+0x1f9>
			if ((r = fork()) < 0) {
  8002c0:	e8 4f 18 00 00       	call   801b14 <fork>
  8002c5:	89 c3                	mov    %eax,%ebx
  8002c7:	85 c0                	test   %eax,%eax
  8002c9:	0f 88 4d 01 00 00    	js     80041c <runcmd+0x21a>
			if (r == 0) {
  8002cf:	0f 85 5d 01 00 00    	jne    800432 <runcmd+0x230>
				if (p[0] != 0) {
  8002d5:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8002db:	85 c0                	test   %eax,%eax
  8002dd:	0f 85 09 02 00 00    	jne    8004ec <runcmd+0x2ea>
				close(p[1]);
  8002e3:	83 ec 0c             	sub    $0xc,%esp
  8002e6:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8002ec:	e8 98 1c 00 00       	call   801f89 <close>
				goto again;
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	e9 29 ff ff ff       	jmp    800222 <runcmd+0x20>
			if (argc == MAXARGS) {
  8002f9:	83 ff 10             	cmp    $0x10,%edi
  8002fc:	74 0f                	je     80030d <runcmd+0x10b>
			argv[argc++] = t;
  8002fe:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800301:	89 44 bd a8          	mov    %eax,-0x58(%ebp,%edi,4)
  800305:	8d 7f 01             	lea    0x1(%edi),%edi
			break;
  800308:	e9 1a ff ff ff       	jmp    800227 <runcmd+0x25>
				cprintf("too many arguments\n");
  80030d:	83 ec 0c             	sub    $0xc,%esp
  800310:	68 a5 35 80 00       	push   $0x8035a5
  800315:	e8 63 08 00 00       	call   800b7d <cprintf>
				exit();
  80031a:	e8 59 07 00 00       	call   800a78 <exit>
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	eb da                	jmp    8002fe <runcmd+0xfc>
				cprintf("syntax error: < not followed by "
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	68 e4 36 80 00       	push   $0x8036e4
  80032c:	e8 4c 08 00 00       	call   800b7d <cprintf>
				exit();
  800331:	e8 42 07 00 00       	call   800a78 <exit>
  800336:	83 c4 10             	add    $0x10,%esp
  800339:	e9 2c ff ff ff       	jmp    80026a <runcmd+0x68>
				exit();
  80033e:	e8 35 07 00 00       	call   800a78 <exit>
				dup(fd, 0);
  800343:	83 ec 08             	sub    $0x8,%esp
  800346:	6a 00                	push   $0x0
  800348:	53                   	push   %ebx
  800349:	e8 95 1c 00 00       	call   801fe3 <dup>
				close(fd);
  80034e:	89 1c 24             	mov    %ebx,(%esp)
  800351:	e8 33 1c 00 00       	call   801f89 <close>
  800356:	83 c4 10             	add    $0x10,%esp
  800359:	e9 c9 fe ff ff       	jmp    800227 <runcmd+0x25>
			if (gettoken(0, &t) != 'w') {
  80035e:	83 ec 08             	sub    $0x8,%esp
  800361:	56                   	push   %esi
  800362:	6a 00                	push   $0x0
  800364:	e8 2a fe ff ff       	call   800193 <gettoken>
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	83 f8 77             	cmp    $0x77,%eax
  80036f:	75 24                	jne    800395 <runcmd+0x193>
			if ((fd = open(t, O_WRONLY | O_CREAT | O_TRUNC)) < 0) {
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	68 01 03 00 00       	push   $0x301
  800379:	ff 75 a4             	pushl  -0x5c(%ebp)
  80037c:	e8 0c 22 00 00       	call   80258d <open>
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	78 22                	js     8003ac <runcmd+0x1aa>
			if (fd != 1) {
  80038a:	83 f8 01             	cmp    $0x1,%eax
  80038d:	0f 84 94 fe ff ff    	je     800227 <runcmd+0x25>
  800393:	eb 30                	jmp    8003c5 <runcmd+0x1c3>
				cprintf("syntax error: > not followed by "
  800395:	83 ec 0c             	sub    $0xc,%esp
  800398:	68 0c 37 80 00       	push   $0x80370c
  80039d:	e8 db 07 00 00       	call   800b7d <cprintf>
				exit();
  8003a2:	e8 d1 06 00 00       	call   800a78 <exit>
  8003a7:	83 c4 10             	add    $0x10,%esp
  8003aa:	eb c5                	jmp    800371 <runcmd+0x16f>
				cprintf("open %s for write: %e", t, fd);
  8003ac:	83 ec 04             	sub    $0x4,%esp
  8003af:	50                   	push   %eax
  8003b0:	ff 75 a4             	pushl  -0x5c(%ebp)
  8003b3:	68 b9 35 80 00       	push   $0x8035b9
  8003b8:	e8 c0 07 00 00       	call   800b7d <cprintf>
				exit();
  8003bd:	e8 b6 06 00 00       	call   800a78 <exit>
  8003c2:	83 c4 10             	add    $0x10,%esp
				dup(fd, 1);
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	6a 01                	push   $0x1
  8003ca:	53                   	push   %ebx
  8003cb:	e8 13 1c 00 00       	call   801fe3 <dup>
				close(fd);
  8003d0:	89 1c 24             	mov    %ebx,(%esp)
  8003d3:	e8 b1 1b 00 00       	call   801f89 <close>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	e9 47 fe ff ff       	jmp    800227 <runcmd+0x25>
				cprintf("pipe: %e", r);
  8003e0:	83 ec 08             	sub    $0x8,%esp
  8003e3:	50                   	push   %eax
  8003e4:	68 cf 35 80 00       	push   $0x8035cf
  8003e9:	e8 8f 07 00 00       	call   800b7d <cprintf>
				exit();
  8003ee:	e8 85 06 00 00       	call   800a78 <exit>
  8003f3:	83 c4 10             	add    $0x10,%esp
  8003f6:	e9 b8 fe ff ff       	jmp    8002b3 <runcmd+0xb1>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003fb:	83 ec 04             	sub    $0x4,%esp
  8003fe:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800404:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80040a:	68 d8 35 80 00       	push   $0x8035d8
  80040f:	e8 69 07 00 00       	call   800b7d <cprintf>
  800414:	83 c4 10             	add    $0x10,%esp
  800417:	e9 a4 fe ff ff       	jmp    8002c0 <runcmd+0xbe>
				cprintf("fork: %e", r);
  80041c:	83 ec 08             	sub    $0x8,%esp
  80041f:	50                   	push   %eax
  800420:	68 e5 35 80 00       	push   $0x8035e5
  800425:	e8 53 07 00 00       	call   800b7d <cprintf>
				exit();
  80042a:	e8 49 06 00 00       	call   800a78 <exit>
  80042f:	83 c4 10             	add    $0x10,%esp
				if (p[1] != 1) {
  800432:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800438:	83 f8 01             	cmp    $0x1,%eax
  80043b:	0f 85 cc 00 00 00    	jne    80050d <runcmd+0x30b>
				close(p[0]);
  800441:	83 ec 0c             	sub    $0xc,%esp
  800444:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80044a:	e8 3a 1b 00 00       	call   801f89 <close>
				goto runit;
  80044f:	83 c4 10             	add    $0x10,%esp
	if (argc == 0) {
  800452:	85 ff                	test   %edi,%edi
  800454:	0f 84 e6 00 00 00    	je     800540 <runcmd+0x33e>
	if (argv[0][0] != '/') {
  80045a:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80045d:	80 38 2f             	cmpb   $0x2f,(%eax)
  800460:	0f 85 f5 00 00 00    	jne    80055b <runcmd+0x359>
	argv[argc] = 0;
  800466:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
  80046d:	00 
	if (debug) {
  80046e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800475:	0f 85 08 01 00 00    	jne    800583 <runcmd+0x381>
	if ((r = spawn(argv[0], (const char **) argv)) < 0)
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	8d 45 a8             	lea    -0x58(%ebp),%eax
  800481:	50                   	push   %eax
  800482:	ff 75 a8             	pushl  -0x58(%ebp)
  800485:	e8 de 25 00 00       	call   802a68 <spawn>
  80048a:	89 c6                	mov    %eax,%esi
  80048c:	83 c4 10             	add    $0x10,%esp
  80048f:	85 c0                	test   %eax,%eax
  800491:	0f 88 3a 01 00 00    	js     8005d1 <runcmd+0x3cf>
	close_all();
  800497:	e8 1e 1b 00 00       	call   801fba <close_all>
		if (debug)
  80049c:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004a3:	0f 85 75 01 00 00    	jne    80061e <runcmd+0x41c>
		wait(r);
  8004a9:	83 ec 0c             	sub    $0xc,%esp
  8004ac:	56                   	push   %esi
  8004ad:	e8 1a 2c 00 00       	call   8030cc <wait>
		if (debug)
  8004b2:	83 c4 10             	add    $0x10,%esp
  8004b5:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004bc:	0f 85 7b 01 00 00    	jne    80063d <runcmd+0x43b>
	if (pipe_child) {
  8004c2:	85 db                	test   %ebx,%ebx
  8004c4:	74 19                	je     8004df <runcmd+0x2dd>
		wait(pipe_child);
  8004c6:	83 ec 0c             	sub    $0xc,%esp
  8004c9:	53                   	push   %ebx
  8004ca:	e8 fd 2b 00 00       	call   8030cc <wait>
		if (debug)
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004d9:	0f 85 79 01 00 00    	jne    800658 <runcmd+0x456>
	exit();
  8004df:	e8 94 05 00 00       	call   800a78 <exit>
}
  8004e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004e7:	5b                   	pop    %ebx
  8004e8:	5e                   	pop    %esi
  8004e9:	5f                   	pop    %edi
  8004ea:	5d                   	pop    %ebp
  8004eb:	c3                   	ret    
					dup(p[0], 0);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	6a 00                	push   $0x0
  8004f1:	50                   	push   %eax
  8004f2:	e8 ec 1a 00 00       	call   801fe3 <dup>
					close(p[0]);
  8004f7:	83 c4 04             	add    $0x4,%esp
  8004fa:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800500:	e8 84 1a 00 00       	call   801f89 <close>
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	e9 d6 fd ff ff       	jmp    8002e3 <runcmd+0xe1>
					dup(p[1], 1);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	6a 01                	push   $0x1
  800512:	50                   	push   %eax
  800513:	e8 cb 1a 00 00       	call   801fe3 <dup>
					close(p[1]);
  800518:	83 c4 04             	add    $0x4,%esp
  80051b:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800521:	e8 63 1a 00 00       	call   801f89 <close>
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	e9 13 ff ff ff       	jmp    800441 <runcmd+0x23f>
			panic("bad return %d from gettoken", c);
  80052e:	53                   	push   %ebx
  80052f:	68 ee 35 80 00       	push   $0x8035ee
  800534:	6a 78                	push   $0x78
  800536:	68 0a 36 80 00       	push   $0x80360a
  80053b:	e8 56 05 00 00       	call   800a96 <_panic>
		if (debug)
  800540:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800547:	74 9b                	je     8004e4 <runcmd+0x2e2>
			cprintf("EMPTY COMMAND\n");
  800549:	83 ec 0c             	sub    $0xc,%esp
  80054c:	68 14 36 80 00       	push   $0x803614
  800551:	e8 27 06 00 00       	call   800b7d <cprintf>
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb 89                	jmp    8004e4 <runcmd+0x2e2>
		argv0buf[0] = '/';
  80055b:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	50                   	push   %eax
  800566:	8d b5 a4 fb ff ff    	lea    -0x45c(%ebp),%esi
  80056c:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  800572:	50                   	push   %eax
  800573:	e8 63 0c 00 00       	call   8011db <strcpy>
		argv[0] = argv0buf;
  800578:	89 75 a8             	mov    %esi,-0x58(%ebp)
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	e9 e3 fe ff ff       	jmp    800466 <runcmd+0x264>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  800583:	a1 24 54 80 00       	mov    0x805424,%eax
  800588:	8b 40 48             	mov    0x48(%eax),%eax
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	50                   	push   %eax
  80058f:	68 23 36 80 00       	push   $0x803623
  800594:	e8 e4 05 00 00       	call   800b7d <cprintf>
  800599:	8d 75 a8             	lea    -0x58(%ebp),%esi
		for (i = 0; argv[i]; i++)
  80059c:	83 c4 10             	add    $0x10,%esp
  80059f:	eb 11                	jmp    8005b2 <runcmd+0x3b0>
			cprintf(" %s", argv[i]);
  8005a1:	83 ec 08             	sub    $0x8,%esp
  8005a4:	50                   	push   %eax
  8005a5:	68 ab 36 80 00       	push   $0x8036ab
  8005aa:	e8 ce 05 00 00       	call   800b7d <cprintf>
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	83 c6 04             	add    $0x4,%esi
		for (i = 0; argv[i]; i++)
  8005b5:	8b 46 fc             	mov    -0x4(%esi),%eax
  8005b8:	85 c0                	test   %eax,%eax
  8005ba:	75 e5                	jne    8005a1 <runcmd+0x39f>
		cprintf("\n");
  8005bc:	83 ec 0c             	sub    $0xc,%esp
  8005bf:	68 80 35 80 00       	push   $0x803580
  8005c4:	e8 b4 05 00 00       	call   800b7d <cprintf>
  8005c9:	83 c4 10             	add    $0x10,%esp
  8005cc:	e9 aa fe ff ff       	jmp    80047b <runcmd+0x279>
		cprintf("spawn %s: %e\n", argv[0], r);
  8005d1:	83 ec 04             	sub    $0x4,%esp
  8005d4:	50                   	push   %eax
  8005d5:	ff 75 a8             	pushl  -0x58(%ebp)
  8005d8:	68 31 36 80 00       	push   $0x803631
  8005dd:	e8 9b 05 00 00       	call   800b7d <cprintf>
	close_all();
  8005e2:	e8 d3 19 00 00       	call   801fba <close_all>
  8005e7:	83 c4 10             	add    $0x10,%esp
	if (pipe_child) {
  8005ea:	85 db                	test   %ebx,%ebx
  8005ec:	0f 84 ed fe ff ff    	je     8004df <runcmd+0x2dd>
		if (debug)
  8005f2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f9:	0f 84 c7 fe ff ff    	je     8004c6 <runcmd+0x2c4>
			        thisenv->env_id,
  8005ff:	a1 24 54 80 00       	mov    0x805424,%eax
			cprintf("[%08x] WAIT pipe_child %08x\n",
  800604:	8b 40 48             	mov    0x48(%eax),%eax
  800607:	83 ec 04             	sub    $0x4,%esp
  80060a:	53                   	push   %ebx
  80060b:	50                   	push   %eax
  80060c:	68 6a 36 80 00       	push   $0x80366a
  800611:	e8 67 05 00 00       	call   800b7d <cprintf>
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	e9 a8 fe ff ff       	jmp    8004c6 <runcmd+0x2c4>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  80061e:	a1 24 54 80 00       	mov    0x805424,%eax
  800623:	8b 40 48             	mov    0x48(%eax),%eax
  800626:	56                   	push   %esi
  800627:	ff 75 a8             	pushl  -0x58(%ebp)
  80062a:	50                   	push   %eax
  80062b:	68 3f 36 80 00       	push   $0x80363f
  800630:	e8 48 05 00 00       	call   800b7d <cprintf>
  800635:	83 c4 10             	add    $0x10,%esp
  800638:	e9 6c fe ff ff       	jmp    8004a9 <runcmd+0x2a7>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  80063d:	a1 24 54 80 00       	mov    0x805424,%eax
  800642:	8b 40 48             	mov    0x48(%eax),%eax
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	50                   	push   %eax
  800649:	68 54 36 80 00       	push   $0x803654
  80064e:	e8 2a 05 00 00       	call   800b7d <cprintf>
  800653:	83 c4 10             	add    $0x10,%esp
  800656:	eb 92                	jmp    8005ea <runcmd+0x3e8>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800658:	a1 24 54 80 00       	mov    0x805424,%eax
  80065d:	8b 40 48             	mov    0x48(%eax),%eax
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	50                   	push   %eax
  800664:	68 54 36 80 00       	push   $0x803654
  800669:	e8 0f 05 00 00       	call   800b7d <cprintf>
  80066e:	83 c4 10             	add    $0x10,%esp
  800671:	e9 69 fe ff ff       	jmp    8004df <runcmd+0x2dd>

00800676 <usage>:


void
usage(void)
{
  800676:	f3 0f 1e fb          	endbr32 
  80067a:	55                   	push   %ebp
  80067b:	89 e5                	mov    %esp,%ebp
  80067d:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800680:	68 34 37 80 00       	push   $0x803734
  800685:	e8 f3 04 00 00       	call   800b7d <cprintf>
	exit();
  80068a:	e8 e9 03 00 00       	call   800a78 <exit>
}
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	c9                   	leave  
  800693:	c3                   	ret    

00800694 <umain>:

void
umain(int argc, char **argv)
{
  800694:	f3 0f 1e fb          	endbr32 
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	57                   	push   %edi
  80069c:	56                   	push   %esi
  80069d:	53                   	push   %ebx
  80069e:	83 ec 30             	sub    $0x30,%esp
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  8006a1:	8d 45 d8             	lea    -0x28(%ebp),%eax
  8006a4:	50                   	push   %eax
  8006a5:	ff 75 0c             	pushl  0xc(%ebp)
  8006a8:	8d 45 08             	lea    0x8(%ebp),%eax
  8006ab:	50                   	push   %eax
  8006ac:	e8 b7 15 00 00       	call   801c68 <argstart>
	while ((r = argnext(&args)) >= 0)
  8006b1:	83 c4 10             	add    $0x10,%esp
	echocmds = 0;
  8006b4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
	interactive = '?';
  8006bb:	bf 3f 00 00 00       	mov    $0x3f,%edi
	while ((r = argnext(&args)) >= 0)
  8006c0:	8d 5d d8             	lea    -0x28(%ebp),%ebx
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006c3:	be 01 00 00 00       	mov    $0x1,%esi
	while ((r = argnext(&args)) >= 0)
  8006c8:	eb 10                	jmp    8006da <umain+0x46>
			debug++;
  8006ca:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  8006d1:	eb 07                	jmp    8006da <umain+0x46>
			interactive = 1;
  8006d3:	89 f7                	mov    %esi,%edi
  8006d5:	eb 03                	jmp    8006da <umain+0x46>
		switch (r) {
  8006d7:	89 75 d4             	mov    %esi,-0x2c(%ebp)
	while ((r = argnext(&args)) >= 0)
  8006da:	83 ec 0c             	sub    $0xc,%esp
  8006dd:	53                   	push   %ebx
  8006de:	e8 b9 15 00 00       	call   801c9c <argnext>
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	85 c0                	test   %eax,%eax
  8006e8:	78 16                	js     800700 <umain+0x6c>
		switch (r) {
  8006ea:	83 f8 69             	cmp    $0x69,%eax
  8006ed:	74 e4                	je     8006d3 <umain+0x3f>
  8006ef:	83 f8 78             	cmp    $0x78,%eax
  8006f2:	74 e3                	je     8006d7 <umain+0x43>
  8006f4:	83 f8 64             	cmp    $0x64,%eax
  8006f7:	74 d1                	je     8006ca <umain+0x36>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006f9:	e8 78 ff ff ff       	call   800676 <usage>
  8006fe:	eb da                	jmp    8006da <umain+0x46>
		}

	if (argc > 2)
  800700:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  800704:	7f 1f                	jg     800725 <umain+0x91>
		usage();
	if (argc == 2) {
  800706:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  80070a:	74 20                	je     80072c <umain+0x98>
		close(0);
		if ((r = open(argv[1], O_RDONLY)) < 0)
			panic("open %s: %e", argv[1], r);
		assert(r == 0);
	}
	if (interactive == '?')
  80070c:	83 ff 3f             	cmp    $0x3f,%edi
  80070f:	74 75                	je     800786 <umain+0xf2>
  800711:	85 ff                	test   %edi,%edi
  800713:	bf af 36 80 00       	mov    $0x8036af,%edi
  800718:	b8 00 00 00 00       	mov    $0x0,%eax
  80071d:	0f 44 f8             	cmove  %eax,%edi
  800720:	e9 06 01 00 00       	jmp    80082b <umain+0x197>
		usage();
  800725:	e8 4c ff ff ff       	call   800676 <usage>
  80072a:	eb da                	jmp    800706 <umain+0x72>
		close(0);
  80072c:	83 ec 0c             	sub    $0xc,%esp
  80072f:	6a 00                	push   $0x0
  800731:	e8 53 18 00 00       	call   801f89 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  800736:	83 c4 08             	add    $0x8,%esp
  800739:	6a 00                	push   $0x0
  80073b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073e:	ff 70 04             	pushl  0x4(%eax)
  800741:	e8 47 1e 00 00       	call   80258d <open>
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	85 c0                	test   %eax,%eax
  80074b:	78 1b                	js     800768 <umain+0xd4>
		assert(r == 0);
  80074d:	74 bd                	je     80070c <umain+0x78>
  80074f:	68 93 36 80 00       	push   $0x803693
  800754:	68 9a 36 80 00       	push   $0x80369a
  800759:	68 2a 01 00 00       	push   $0x12a
  80075e:	68 0a 36 80 00       	push   $0x80360a
  800763:	e8 2e 03 00 00       	call   800a96 <_panic>
			panic("open %s: %e", argv[1], r);
  800768:	83 ec 0c             	sub    $0xc,%esp
  80076b:	50                   	push   %eax
  80076c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076f:	ff 70 04             	pushl  0x4(%eax)
  800772:	68 87 36 80 00       	push   $0x803687
  800777:	68 29 01 00 00       	push   $0x129
  80077c:	68 0a 36 80 00       	push   $0x80360a
  800781:	e8 10 03 00 00       	call   800a96 <_panic>
		interactive = iscons(0);
  800786:	83 ec 0c             	sub    $0xc,%esp
  800789:	6a 00                	push   $0x0
  80078b:	e8 14 02 00 00       	call   8009a4 <iscons>
  800790:	89 c7                	mov    %eax,%edi
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	e9 77 ff ff ff       	jmp    800711 <umain+0x7d>
	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
		if (buf == NULL) {
			if (debug)
  80079a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007a1:	75 0a                	jne    8007ad <umain+0x119>
				cprintf("EXITING\n");
			exit();  // end of file
  8007a3:	e8 d0 02 00 00       	call   800a78 <exit>
  8007a8:	e9 94 00 00 00       	jmp    800841 <umain+0x1ad>
				cprintf("EXITING\n");
  8007ad:	83 ec 0c             	sub    $0xc,%esp
  8007b0:	68 b2 36 80 00       	push   $0x8036b2
  8007b5:	e8 c3 03 00 00       	call   800b7d <cprintf>
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	eb e4                	jmp    8007a3 <umain+0x10f>
		}
		if (debug)
			cprintf("LINE: %s\n", buf);
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	53                   	push   %ebx
  8007c3:	68 bb 36 80 00       	push   $0x8036bb
  8007c8:	e8 b0 03 00 00       	call   800b7d <cprintf>
  8007cd:	83 c4 10             	add    $0x10,%esp
  8007d0:	eb 7c                	jmp    80084e <umain+0x1ba>
		if (buf[0] == '#')
			continue;
		if (echocmds)
			printf("# %s\n", buf);
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	53                   	push   %ebx
  8007d6:	68 c5 36 80 00       	push   $0x8036c5
  8007db:	e8 64 1f 00 00       	call   802744 <printf>
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	eb 78                	jmp    80085d <umain+0x1c9>
		if (debug)
			cprintf("BEFORE FORK\n");
  8007e5:	83 ec 0c             	sub    $0xc,%esp
  8007e8:	68 cb 36 80 00       	push   $0x8036cb
  8007ed:	e8 8b 03 00 00       	call   800b7d <cprintf>
  8007f2:	83 c4 10             	add    $0x10,%esp
  8007f5:	eb 73                	jmp    80086a <umain+0x1d6>
		if ((r = fork()) < 0)
			panic("fork: %e", r);
  8007f7:	50                   	push   %eax
  8007f8:	68 e5 35 80 00       	push   $0x8035e5
  8007fd:	68 41 01 00 00       	push   $0x141
  800802:	68 0a 36 80 00       	push   $0x80360a
  800807:	e8 8a 02 00 00       	call   800a96 <_panic>
		if (debug)
			cprintf("FORK: %d\n", r);
  80080c:	83 ec 08             	sub    $0x8,%esp
  80080f:	50                   	push   %eax
  800810:	68 d8 36 80 00       	push   $0x8036d8
  800815:	e8 63 03 00 00       	call   800b7d <cprintf>
  80081a:	83 c4 10             	add    $0x10,%esp
  80081d:	eb 5f                	jmp    80087e <umain+0x1ea>
		if (r == 0) {
			runcmd(buf);
			exit();
		} else
			wait(r);
  80081f:	83 ec 0c             	sub    $0xc,%esp
  800822:	56                   	push   %esi
  800823:	e8 a4 28 00 00       	call   8030cc <wait>
  800828:	83 c4 10             	add    $0x10,%esp
		buf = readline(interactive ? "$ " : NULL);
  80082b:	83 ec 0c             	sub    $0xc,%esp
  80082e:	57                   	push   %edi
  80082f:	e8 70 08 00 00       	call   8010a4 <readline>
  800834:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	85 c0                	test   %eax,%eax
  80083b:	0f 84 59 ff ff ff    	je     80079a <umain+0x106>
		if (debug)
  800841:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800848:	0f 85 71 ff ff ff    	jne    8007bf <umain+0x12b>
		if (buf[0] == '#')
  80084e:	80 3b 23             	cmpb   $0x23,(%ebx)
  800851:	74 d8                	je     80082b <umain+0x197>
		if (echocmds)
  800853:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800857:	0f 85 75 ff ff ff    	jne    8007d2 <umain+0x13e>
		if (debug)
  80085d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800864:	0f 85 7b ff ff ff    	jne    8007e5 <umain+0x151>
		if ((r = fork()) < 0)
  80086a:	e8 a5 12 00 00       	call   801b14 <fork>
  80086f:	89 c6                	mov    %eax,%esi
  800871:	85 c0                	test   %eax,%eax
  800873:	78 82                	js     8007f7 <umain+0x163>
		if (debug)
  800875:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80087c:	75 8e                	jne    80080c <umain+0x178>
		if (r == 0) {
  80087e:	85 f6                	test   %esi,%esi
  800880:	75 9d                	jne    80081f <umain+0x18b>
			runcmd(buf);
  800882:	83 ec 0c             	sub    $0xc,%esp
  800885:	53                   	push   %ebx
  800886:	e8 77 f9 ff ff       	call   800202 <runcmd>
			exit();
  80088b:	e8 e8 01 00 00       	call   800a78 <exit>
  800890:	83 c4 10             	add    $0x10,%esp
  800893:	eb 96                	jmp    80082b <umain+0x197>

00800895 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800895:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
  80089e:	c3                   	ret    

0080089f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80089f:	f3 0f 1e fb          	endbr32 
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8008a9:	68 55 37 80 00       	push   $0x803755
  8008ae:	ff 75 0c             	pushl  0xc(%ebp)
  8008b1:	e8 25 09 00 00       	call   8011db <strcpy>
	return 0;
}
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <devcons_write>:
{
  8008bd:	f3 0f 1e fb          	endbr32 
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	57                   	push   %edi
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8008cd:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8008d2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8008d8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008db:	73 31                	jae    80090e <devcons_write+0x51>
		m = n - tot;
  8008dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008e0:	29 f3                	sub    %esi,%ebx
  8008e2:	83 fb 7f             	cmp    $0x7f,%ebx
  8008e5:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8008ea:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8008ed:	83 ec 04             	sub    $0x4,%esp
  8008f0:	53                   	push   %ebx
  8008f1:	89 f0                	mov    %esi,%eax
  8008f3:	03 45 0c             	add    0xc(%ebp),%eax
  8008f6:	50                   	push   %eax
  8008f7:	57                   	push   %edi
  8008f8:	e8 96 0a 00 00       	call   801393 <memmove>
		sys_cputs(buf, m);
  8008fd:	83 c4 08             	add    $0x8,%esp
  800900:	53                   	push   %ebx
  800901:	57                   	push   %edi
  800902:	e8 91 0c 00 00       	call   801598 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800907:	01 de                	add    %ebx,%esi
  800909:	83 c4 10             	add    $0x10,%esp
  80090c:	eb ca                	jmp    8008d8 <devcons_write+0x1b>
}
  80090e:	89 f0                	mov    %esi,%eax
  800910:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800913:	5b                   	pop    %ebx
  800914:	5e                   	pop    %esi
  800915:	5f                   	pop    %edi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <devcons_read>:
{
  800918:	f3 0f 1e fb          	endbr32 
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	83 ec 08             	sub    $0x8,%esp
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800927:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80092b:	74 21                	je     80094e <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80092d:	e8 90 0c 00 00       	call   8015c2 <sys_cgetc>
  800932:	85 c0                	test   %eax,%eax
  800934:	75 07                	jne    80093d <devcons_read+0x25>
		sys_yield();
  800936:	e8 fd 0c 00 00       	call   801638 <sys_yield>
  80093b:	eb f0                	jmp    80092d <devcons_read+0x15>
	if (c < 0)
  80093d:	78 0f                	js     80094e <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80093f:	83 f8 04             	cmp    $0x4,%eax
  800942:	74 0c                	je     800950 <devcons_read+0x38>
	*(char*)vbuf = c;
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
  800947:	88 02                	mov    %al,(%edx)
	return 1;
  800949:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80094e:	c9                   	leave  
  80094f:	c3                   	ret    
		return 0;
  800950:	b8 00 00 00 00       	mov    $0x0,%eax
  800955:	eb f7                	jmp    80094e <devcons_read+0x36>

00800957 <cputchar>:
{
  800957:	f3 0f 1e fb          	endbr32 
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800967:	6a 01                	push   $0x1
  800969:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80096c:	50                   	push   %eax
  80096d:	e8 26 0c 00 00       	call   801598 <sys_cputs>
}
  800972:	83 c4 10             	add    $0x10,%esp
  800975:	c9                   	leave  
  800976:	c3                   	ret    

00800977 <getchar>:
{
  800977:	f3 0f 1e fb          	endbr32 
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800981:	6a 01                	push   $0x1
  800983:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800986:	50                   	push   %eax
  800987:	6a 00                	push   $0x0
  800989:	e8 45 17 00 00       	call   8020d3 <read>
	if (r < 0)
  80098e:	83 c4 10             	add    $0x10,%esp
  800991:	85 c0                	test   %eax,%eax
  800993:	78 06                	js     80099b <getchar+0x24>
	if (r < 1)
  800995:	74 06                	je     80099d <getchar+0x26>
	return c;
  800997:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    
		return -E_EOF;
  80099d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8009a2:	eb f7                	jmp    80099b <getchar+0x24>

008009a4 <iscons>:
{
  8009a4:	f3 0f 1e fb          	endbr32 
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009b1:	50                   	push   %eax
  8009b2:	ff 75 08             	pushl  0x8(%ebp)
  8009b5:	e8 96 14 00 00       	call   801e50 <fd_lookup>
  8009ba:	83 c4 10             	add    $0x10,%esp
  8009bd:	85 c0                	test   %eax,%eax
  8009bf:	78 11                	js     8009d2 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8009c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c4:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8009ca:	39 10                	cmp    %edx,(%eax)
  8009cc:	0f 94 c0             	sete   %al
  8009cf:	0f b6 c0             	movzbl %al,%eax
}
  8009d2:	c9                   	leave  
  8009d3:	c3                   	ret    

008009d4 <opencons>:
{
  8009d4:	f3 0f 1e fb          	endbr32 
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8009de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009e1:	50                   	push   %eax
  8009e2:	e8 13 14 00 00       	call   801dfa <fd_alloc>
  8009e7:	83 c4 10             	add    $0x10,%esp
  8009ea:	85 c0                	test   %eax,%eax
  8009ec:	78 3a                	js     800a28 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8009ee:	83 ec 04             	sub    $0x4,%esp
  8009f1:	68 07 04 00 00       	push   $0x407
  8009f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8009f9:	6a 00                	push   $0x0
  8009fb:	e8 63 0c 00 00       	call   801663 <sys_page_alloc>
  800a00:	83 c4 10             	add    $0x10,%esp
  800a03:	85 c0                	test   %eax,%eax
  800a05:	78 21                	js     800a28 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  800a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a0a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800a10:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a15:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800a1c:	83 ec 0c             	sub    $0xc,%esp
  800a1f:	50                   	push   %eax
  800a20:	e8 a2 13 00 00       	call   801dc7 <fd2num>
  800a25:	83 c4 10             	add    $0x10,%esp
}
  800a28:	c9                   	leave  
  800a29:	c3                   	ret    

00800a2a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800a2a:	f3 0f 1e fb          	endbr32 
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	56                   	push   %esi
  800a32:	53                   	push   %ebx
  800a33:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a36:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800a39:	e8 d2 0b 00 00       	call   801610 <sys_getenvid>
	if (id >= 0)
  800a3e:	85 c0                	test   %eax,%eax
  800a40:	78 12                	js     800a54 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800a42:	25 ff 03 00 00       	and    $0x3ff,%eax
  800a47:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800a4a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800a4f:	a3 24 54 80 00       	mov    %eax,0x805424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800a54:	85 db                	test   %ebx,%ebx
  800a56:	7e 07                	jle    800a5f <libmain+0x35>
		binaryname = argv[0];
  800a58:	8b 06                	mov    (%esi),%eax
  800a5a:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  800a5f:	83 ec 08             	sub    $0x8,%esp
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	e8 2b fc ff ff       	call   800694 <umain>

	// exit gracefully
	exit();
  800a69:	e8 0a 00 00 00       	call   800a78 <exit>
}
  800a6e:	83 c4 10             	add    $0x10,%esp
  800a71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a74:	5b                   	pop    %ebx
  800a75:	5e                   	pop    %esi
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a78:	f3 0f 1e fb          	endbr32 
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a82:	e8 33 15 00 00       	call   801fba <close_all>
	sys_env_destroy(0);
  800a87:	83 ec 0c             	sub    $0xc,%esp
  800a8a:	6a 00                	push   $0x0
  800a8c:	e8 59 0b 00 00       	call   8015ea <sys_env_destroy>
}
  800a91:	83 c4 10             	add    $0x10,%esp
  800a94:	c9                   	leave  
  800a95:	c3                   	ret    

00800a96 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a96:	f3 0f 1e fb          	endbr32 
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a9f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800aa2:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800aa8:	e8 63 0b 00 00       	call   801610 <sys_getenvid>
  800aad:	83 ec 0c             	sub    $0xc,%esp
  800ab0:	ff 75 0c             	pushl  0xc(%ebp)
  800ab3:	ff 75 08             	pushl  0x8(%ebp)
  800ab6:	56                   	push   %esi
  800ab7:	50                   	push   %eax
  800ab8:	68 6c 37 80 00       	push   $0x80376c
  800abd:	e8 bb 00 00 00       	call   800b7d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ac2:	83 c4 18             	add    $0x18,%esp
  800ac5:	53                   	push   %ebx
  800ac6:	ff 75 10             	pushl  0x10(%ebp)
  800ac9:	e8 5a 00 00 00       	call   800b28 <vcprintf>
	cprintf("\n");
  800ace:	c7 04 24 80 35 80 00 	movl   $0x803580,(%esp)
  800ad5:	e8 a3 00 00 00       	call   800b7d <cprintf>
  800ada:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800add:	cc                   	int3   
  800ade:	eb fd                	jmp    800add <_panic+0x47>

00800ae0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800ae0:	f3 0f 1e fb          	endbr32 
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	53                   	push   %ebx
  800ae8:	83 ec 04             	sub    $0x4,%esp
  800aeb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800aee:	8b 13                	mov    (%ebx),%edx
  800af0:	8d 42 01             	lea    0x1(%edx),%eax
  800af3:	89 03                	mov    %eax,(%ebx)
  800af5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800afc:	3d ff 00 00 00       	cmp    $0xff,%eax
  800b01:	74 09                	je     800b0c <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800b03:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800b07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800b0c:	83 ec 08             	sub    $0x8,%esp
  800b0f:	68 ff 00 00 00       	push   $0xff
  800b14:	8d 43 08             	lea    0x8(%ebx),%eax
  800b17:	50                   	push   %eax
  800b18:	e8 7b 0a 00 00       	call   801598 <sys_cputs>
		b->idx = 0;
  800b1d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800b23:	83 c4 10             	add    $0x10,%esp
  800b26:	eb db                	jmp    800b03 <putch+0x23>

00800b28 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800b28:	f3 0f 1e fb          	endbr32 
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800b35:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800b3c:	00 00 00 
	b.cnt = 0;
  800b3f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800b46:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800b49:	ff 75 0c             	pushl  0xc(%ebp)
  800b4c:	ff 75 08             	pushl  0x8(%ebp)
  800b4f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800b55:	50                   	push   %eax
  800b56:	68 e0 0a 80 00       	push   $0x800ae0
  800b5b:	e8 80 01 00 00       	call   800ce0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b60:	83 c4 08             	add    $0x8,%esp
  800b63:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800b69:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b6f:	50                   	push   %eax
  800b70:	e8 23 0a 00 00       	call   801598 <sys_cputs>

	return b.cnt;
}
  800b75:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b7d:	f3 0f 1e fb          	endbr32 
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b87:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b8a:	50                   	push   %eax
  800b8b:	ff 75 08             	pushl  0x8(%ebp)
  800b8e:	e8 95 ff ff ff       	call   800b28 <vcprintf>
	va_end(ap);

	return cnt;
}
  800b93:	c9                   	leave  
  800b94:	c3                   	ret    

00800b95 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
  800b9b:	83 ec 1c             	sub    $0x1c,%esp
  800b9e:	89 c7                	mov    %eax,%edi
  800ba0:	89 d6                	mov    %edx,%esi
  800ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba8:	89 d1                	mov    %edx,%ecx
  800baa:	89 c2                	mov    %eax,%edx
  800bac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800baf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800bb2:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800bb8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bbb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800bc2:	39 c2                	cmp    %eax,%edx
  800bc4:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800bc7:	72 3e                	jb     800c07 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800bc9:	83 ec 0c             	sub    $0xc,%esp
  800bcc:	ff 75 18             	pushl  0x18(%ebp)
  800bcf:	83 eb 01             	sub    $0x1,%ebx
  800bd2:	53                   	push   %ebx
  800bd3:	50                   	push   %eax
  800bd4:	83 ec 08             	sub    $0x8,%esp
  800bd7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bda:	ff 75 e0             	pushl  -0x20(%ebp)
  800bdd:	ff 75 dc             	pushl  -0x24(%ebp)
  800be0:	ff 75 d8             	pushl  -0x28(%ebp)
  800be3:	e8 18 27 00 00       	call   803300 <__udivdi3>
  800be8:	83 c4 18             	add    $0x18,%esp
  800beb:	52                   	push   %edx
  800bec:	50                   	push   %eax
  800bed:	89 f2                	mov    %esi,%edx
  800bef:	89 f8                	mov    %edi,%eax
  800bf1:	e8 9f ff ff ff       	call   800b95 <printnum>
  800bf6:	83 c4 20             	add    $0x20,%esp
  800bf9:	eb 13                	jmp    800c0e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800bfb:	83 ec 08             	sub    $0x8,%esp
  800bfe:	56                   	push   %esi
  800bff:	ff 75 18             	pushl  0x18(%ebp)
  800c02:	ff d7                	call   *%edi
  800c04:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800c07:	83 eb 01             	sub    $0x1,%ebx
  800c0a:	85 db                	test   %ebx,%ebx
  800c0c:	7f ed                	jg     800bfb <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800c0e:	83 ec 08             	sub    $0x8,%esp
  800c11:	56                   	push   %esi
  800c12:	83 ec 04             	sub    $0x4,%esp
  800c15:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c18:	ff 75 e0             	pushl  -0x20(%ebp)
  800c1b:	ff 75 dc             	pushl  -0x24(%ebp)
  800c1e:	ff 75 d8             	pushl  -0x28(%ebp)
  800c21:	e8 ea 27 00 00       	call   803410 <__umoddi3>
  800c26:	83 c4 14             	add    $0x14,%esp
  800c29:	0f be 80 8f 37 80 00 	movsbl 0x80378f(%eax),%eax
  800c30:	50                   	push   %eax
  800c31:	ff d7                	call   *%edi
}
  800c33:	83 c4 10             	add    $0x10,%esp
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c3e:	83 fa 01             	cmp    $0x1,%edx
  800c41:	7f 13                	jg     800c56 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800c43:	85 d2                	test   %edx,%edx
  800c45:	74 1c                	je     800c63 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800c47:	8b 10                	mov    (%eax),%edx
  800c49:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c4c:	89 08                	mov    %ecx,(%eax)
  800c4e:	8b 02                	mov    (%edx),%eax
  800c50:	ba 00 00 00 00       	mov    $0x0,%edx
  800c55:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800c56:	8b 10                	mov    (%eax),%edx
  800c58:	8d 4a 08             	lea    0x8(%edx),%ecx
  800c5b:	89 08                	mov    %ecx,(%eax)
  800c5d:	8b 02                	mov    (%edx),%eax
  800c5f:	8b 52 04             	mov    0x4(%edx),%edx
  800c62:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800c63:	8b 10                	mov    (%eax),%edx
  800c65:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c68:	89 08                	mov    %ecx,(%eax)
  800c6a:	8b 02                	mov    (%edx),%eax
  800c6c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c71:	c3                   	ret    

00800c72 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c72:	83 fa 01             	cmp    $0x1,%edx
  800c75:	7f 0f                	jg     800c86 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800c77:	85 d2                	test   %edx,%edx
  800c79:	74 18                	je     800c93 <getint+0x21>
		return va_arg(*ap, long);
  800c7b:	8b 10                	mov    (%eax),%edx
  800c7d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c80:	89 08                	mov    %ecx,(%eax)
  800c82:	8b 02                	mov    (%edx),%eax
  800c84:	99                   	cltd   
  800c85:	c3                   	ret    
		return va_arg(*ap, long long);
  800c86:	8b 10                	mov    (%eax),%edx
  800c88:	8d 4a 08             	lea    0x8(%edx),%ecx
  800c8b:	89 08                	mov    %ecx,(%eax)
  800c8d:	8b 02                	mov    (%edx),%eax
  800c8f:	8b 52 04             	mov    0x4(%edx),%edx
  800c92:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800c93:	8b 10                	mov    (%eax),%edx
  800c95:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c98:	89 08                	mov    %ecx,(%eax)
  800c9a:	8b 02                	mov    (%edx),%eax
  800c9c:	99                   	cltd   
}
  800c9d:	c3                   	ret    

00800c9e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c9e:	f3 0f 1e fb          	endbr32 
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800ca8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800cac:	8b 10                	mov    (%eax),%edx
  800cae:	3b 50 04             	cmp    0x4(%eax),%edx
  800cb1:	73 0a                	jae    800cbd <sprintputch+0x1f>
		*b->buf++ = ch;
  800cb3:	8d 4a 01             	lea    0x1(%edx),%ecx
  800cb6:	89 08                	mov    %ecx,(%eax)
  800cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbb:	88 02                	mov    %al,(%edx)
}
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <printfmt>:
{
  800cbf:	f3 0f 1e fb          	endbr32 
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800cc9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800ccc:	50                   	push   %eax
  800ccd:	ff 75 10             	pushl  0x10(%ebp)
  800cd0:	ff 75 0c             	pushl  0xc(%ebp)
  800cd3:	ff 75 08             	pushl  0x8(%ebp)
  800cd6:	e8 05 00 00 00       	call   800ce0 <vprintfmt>
}
  800cdb:	83 c4 10             	add    $0x10,%esp
  800cde:	c9                   	leave  
  800cdf:	c3                   	ret    

00800ce0 <vprintfmt>:
{
  800ce0:	f3 0f 1e fb          	endbr32 
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 2c             	sub    $0x2c,%esp
  800ced:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cf0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf3:	8b 7d 10             	mov    0x10(%ebp),%edi
  800cf6:	e9 86 02 00 00       	jmp    800f81 <vprintfmt+0x2a1>
		padc = ' ';
  800cfb:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800cff:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800d06:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800d0d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800d14:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800d19:	8d 47 01             	lea    0x1(%edi),%eax
  800d1c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800d1f:	0f b6 17             	movzbl (%edi),%edx
  800d22:	8d 42 dd             	lea    -0x23(%edx),%eax
  800d25:	3c 55                	cmp    $0x55,%al
  800d27:	0f 87 df 02 00 00    	ja     80100c <vprintfmt+0x32c>
  800d2d:	0f b6 c0             	movzbl %al,%eax
  800d30:	3e ff 24 85 e0 38 80 	notrack jmp *0x8038e0(,%eax,4)
  800d37:	00 
  800d38:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800d3b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800d3f:	eb d8                	jmp    800d19 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800d41:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d44:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800d48:	eb cf                	jmp    800d19 <vprintfmt+0x39>
  800d4a:	0f b6 d2             	movzbl %dl,%edx
  800d4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800d50:	b8 00 00 00 00       	mov    $0x0,%eax
  800d55:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800d58:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800d5b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800d5f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800d62:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800d65:	83 f9 09             	cmp    $0x9,%ecx
  800d68:	77 52                	ja     800dbc <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800d6a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800d6d:	eb e9                	jmp    800d58 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800d6f:	8b 45 14             	mov    0x14(%ebp),%eax
  800d72:	8d 50 04             	lea    0x4(%eax),%edx
  800d75:	89 55 14             	mov    %edx,0x14(%ebp)
  800d78:	8b 00                	mov    (%eax),%eax
  800d7a:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800d7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800d80:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d84:	79 93                	jns    800d19 <vprintfmt+0x39>
				width = precision, precision = -1;
  800d86:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d89:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d8c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800d93:	eb 84                	jmp    800d19 <vprintfmt+0x39>
  800d95:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9f:	0f 49 d0             	cmovns %eax,%edx
  800da2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800da5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800da8:	e9 6c ff ff ff       	jmp    800d19 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800dad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800db0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800db7:	e9 5d ff ff ff       	jmp    800d19 <vprintfmt+0x39>
  800dbc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800dbf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800dc2:	eb bc                	jmp    800d80 <vprintfmt+0xa0>
			lflag++;
  800dc4:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800dc7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800dca:	e9 4a ff ff ff       	jmp    800d19 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800dcf:	8b 45 14             	mov    0x14(%ebp),%eax
  800dd2:	8d 50 04             	lea    0x4(%eax),%edx
  800dd5:	89 55 14             	mov    %edx,0x14(%ebp)
  800dd8:	83 ec 08             	sub    $0x8,%esp
  800ddb:	56                   	push   %esi
  800ddc:	ff 30                	pushl  (%eax)
  800dde:	ff d3                	call   *%ebx
			break;
  800de0:	83 c4 10             	add    $0x10,%esp
  800de3:	e9 96 01 00 00       	jmp    800f7e <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800de8:	8b 45 14             	mov    0x14(%ebp),%eax
  800deb:	8d 50 04             	lea    0x4(%eax),%edx
  800dee:	89 55 14             	mov    %edx,0x14(%ebp)
  800df1:	8b 00                	mov    (%eax),%eax
  800df3:	99                   	cltd   
  800df4:	31 d0                	xor    %edx,%eax
  800df6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800df8:	83 f8 0f             	cmp    $0xf,%eax
  800dfb:	7f 20                	jg     800e1d <vprintfmt+0x13d>
  800dfd:	8b 14 85 40 3a 80 00 	mov    0x803a40(,%eax,4),%edx
  800e04:	85 d2                	test   %edx,%edx
  800e06:	74 15                	je     800e1d <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800e08:	52                   	push   %edx
  800e09:	68 ac 36 80 00       	push   $0x8036ac
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	e8 aa fe ff ff       	call   800cbf <printfmt>
  800e15:	83 c4 10             	add    $0x10,%esp
  800e18:	e9 61 01 00 00       	jmp    800f7e <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800e1d:	50                   	push   %eax
  800e1e:	68 a7 37 80 00       	push   $0x8037a7
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
  800e25:	e8 95 fe ff ff       	call   800cbf <printfmt>
  800e2a:	83 c4 10             	add    $0x10,%esp
  800e2d:	e9 4c 01 00 00       	jmp    800f7e <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800e32:	8b 45 14             	mov    0x14(%ebp),%eax
  800e35:	8d 50 04             	lea    0x4(%eax),%edx
  800e38:	89 55 14             	mov    %edx,0x14(%ebp)
  800e3b:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800e3d:	85 c9                	test   %ecx,%ecx
  800e3f:	b8 a0 37 80 00       	mov    $0x8037a0,%eax
  800e44:	0f 45 c1             	cmovne %ecx,%eax
  800e47:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800e4a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800e4e:	7e 06                	jle    800e56 <vprintfmt+0x176>
  800e50:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800e54:	75 0d                	jne    800e63 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800e56:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e59:	89 c7                	mov    %eax,%edi
  800e5b:	03 45 e0             	add    -0x20(%ebp),%eax
  800e5e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e61:	eb 57                	jmp    800eba <vprintfmt+0x1da>
  800e63:	83 ec 08             	sub    $0x8,%esp
  800e66:	ff 75 d8             	pushl  -0x28(%ebp)
  800e69:	ff 75 cc             	pushl  -0x34(%ebp)
  800e6c:	e8 43 03 00 00       	call   8011b4 <strnlen>
  800e71:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e74:	29 c2                	sub    %eax,%edx
  800e76:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800e79:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800e7c:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800e80:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800e83:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800e85:	85 db                	test   %ebx,%ebx
  800e87:	7e 10                	jle    800e99 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800e89:	83 ec 08             	sub    $0x8,%esp
  800e8c:	56                   	push   %esi
  800e8d:	57                   	push   %edi
  800e8e:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800e91:	83 eb 01             	sub    $0x1,%ebx
  800e94:	83 c4 10             	add    $0x10,%esp
  800e97:	eb ec                	jmp    800e85 <vprintfmt+0x1a5>
  800e99:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e9c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e9f:	85 d2                	test   %edx,%edx
  800ea1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea6:	0f 49 c2             	cmovns %edx,%eax
  800ea9:	29 c2                	sub    %eax,%edx
  800eab:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800eae:	eb a6                	jmp    800e56 <vprintfmt+0x176>
					putch(ch, putdat);
  800eb0:	83 ec 08             	sub    $0x8,%esp
  800eb3:	56                   	push   %esi
  800eb4:	52                   	push   %edx
  800eb5:	ff d3                	call   *%ebx
  800eb7:	83 c4 10             	add    $0x10,%esp
  800eba:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ebd:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ebf:	83 c7 01             	add    $0x1,%edi
  800ec2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ec6:	0f be d0             	movsbl %al,%edx
  800ec9:	85 d2                	test   %edx,%edx
  800ecb:	74 42                	je     800f0f <vprintfmt+0x22f>
  800ecd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ed1:	78 06                	js     800ed9 <vprintfmt+0x1f9>
  800ed3:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800ed7:	78 1e                	js     800ef7 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800ed9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800edd:	74 d1                	je     800eb0 <vprintfmt+0x1d0>
  800edf:	0f be c0             	movsbl %al,%eax
  800ee2:	83 e8 20             	sub    $0x20,%eax
  800ee5:	83 f8 5e             	cmp    $0x5e,%eax
  800ee8:	76 c6                	jbe    800eb0 <vprintfmt+0x1d0>
					putch('?', putdat);
  800eea:	83 ec 08             	sub    $0x8,%esp
  800eed:	56                   	push   %esi
  800eee:	6a 3f                	push   $0x3f
  800ef0:	ff d3                	call   *%ebx
  800ef2:	83 c4 10             	add    $0x10,%esp
  800ef5:	eb c3                	jmp    800eba <vprintfmt+0x1da>
  800ef7:	89 cf                	mov    %ecx,%edi
  800ef9:	eb 0e                	jmp    800f09 <vprintfmt+0x229>
				putch(' ', putdat);
  800efb:	83 ec 08             	sub    $0x8,%esp
  800efe:	56                   	push   %esi
  800eff:	6a 20                	push   $0x20
  800f01:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800f03:	83 ef 01             	sub    $0x1,%edi
  800f06:	83 c4 10             	add    $0x10,%esp
  800f09:	85 ff                	test   %edi,%edi
  800f0b:	7f ee                	jg     800efb <vprintfmt+0x21b>
  800f0d:	eb 6f                	jmp    800f7e <vprintfmt+0x29e>
  800f0f:	89 cf                	mov    %ecx,%edi
  800f11:	eb f6                	jmp    800f09 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800f13:	89 ca                	mov    %ecx,%edx
  800f15:	8d 45 14             	lea    0x14(%ebp),%eax
  800f18:	e8 55 fd ff ff       	call   800c72 <getint>
  800f1d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f20:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800f23:	85 d2                	test   %edx,%edx
  800f25:	78 0b                	js     800f32 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800f27:	89 d1                	mov    %edx,%ecx
  800f29:	89 c2                	mov    %eax,%edx
			base = 10;
  800f2b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f30:	eb 32                	jmp    800f64 <vprintfmt+0x284>
				putch('-', putdat);
  800f32:	83 ec 08             	sub    $0x8,%esp
  800f35:	56                   	push   %esi
  800f36:	6a 2d                	push   $0x2d
  800f38:	ff d3                	call   *%ebx
				num = -(long long) num;
  800f3a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800f3d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800f40:	f7 da                	neg    %edx
  800f42:	83 d1 00             	adc    $0x0,%ecx
  800f45:	f7 d9                	neg    %ecx
  800f47:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800f4a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f4f:	eb 13                	jmp    800f64 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800f51:	89 ca                	mov    %ecx,%edx
  800f53:	8d 45 14             	lea    0x14(%ebp),%eax
  800f56:	e8 e3 fc ff ff       	call   800c3e <getuint>
  800f5b:	89 d1                	mov    %edx,%ecx
  800f5d:	89 c2                	mov    %eax,%edx
			base = 10;
  800f5f:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800f64:	83 ec 0c             	sub    $0xc,%esp
  800f67:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800f6b:	57                   	push   %edi
  800f6c:	ff 75 e0             	pushl  -0x20(%ebp)
  800f6f:	50                   	push   %eax
  800f70:	51                   	push   %ecx
  800f71:	52                   	push   %edx
  800f72:	89 f2                	mov    %esi,%edx
  800f74:	89 d8                	mov    %ebx,%eax
  800f76:	e8 1a fc ff ff       	call   800b95 <printnum>
			break;
  800f7b:	83 c4 20             	add    $0x20,%esp
{
  800f7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800f81:	83 c7 01             	add    $0x1,%edi
  800f84:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800f88:	83 f8 25             	cmp    $0x25,%eax
  800f8b:	0f 84 6a fd ff ff    	je     800cfb <vprintfmt+0x1b>
			if (ch == '\0')
  800f91:	85 c0                	test   %eax,%eax
  800f93:	0f 84 93 00 00 00    	je     80102c <vprintfmt+0x34c>
			putch(ch, putdat);
  800f99:	83 ec 08             	sub    $0x8,%esp
  800f9c:	56                   	push   %esi
  800f9d:	50                   	push   %eax
  800f9e:	ff d3                	call   *%ebx
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	eb dc                	jmp    800f81 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800fa5:	89 ca                	mov    %ecx,%edx
  800fa7:	8d 45 14             	lea    0x14(%ebp),%eax
  800faa:	e8 8f fc ff ff       	call   800c3e <getuint>
  800faf:	89 d1                	mov    %edx,%ecx
  800fb1:	89 c2                	mov    %eax,%edx
			base = 8;
  800fb3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800fb8:	eb aa                	jmp    800f64 <vprintfmt+0x284>
			putch('0', putdat);
  800fba:	83 ec 08             	sub    $0x8,%esp
  800fbd:	56                   	push   %esi
  800fbe:	6a 30                	push   $0x30
  800fc0:	ff d3                	call   *%ebx
			putch('x', putdat);
  800fc2:	83 c4 08             	add    $0x8,%esp
  800fc5:	56                   	push   %esi
  800fc6:	6a 78                	push   $0x78
  800fc8:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800fca:	8b 45 14             	mov    0x14(%ebp),%eax
  800fcd:	8d 50 04             	lea    0x4(%eax),%edx
  800fd0:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800fd3:	8b 10                	mov    (%eax),%edx
  800fd5:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800fda:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800fdd:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800fe2:	eb 80                	jmp    800f64 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800fe4:	89 ca                	mov    %ecx,%edx
  800fe6:	8d 45 14             	lea    0x14(%ebp),%eax
  800fe9:	e8 50 fc ff ff       	call   800c3e <getuint>
  800fee:	89 d1                	mov    %edx,%ecx
  800ff0:	89 c2                	mov    %eax,%edx
			base = 16;
  800ff2:	b8 10 00 00 00       	mov    $0x10,%eax
  800ff7:	e9 68 ff ff ff       	jmp    800f64 <vprintfmt+0x284>
			putch(ch, putdat);
  800ffc:	83 ec 08             	sub    $0x8,%esp
  800fff:	56                   	push   %esi
  801000:	6a 25                	push   $0x25
  801002:	ff d3                	call   *%ebx
			break;
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	e9 72 ff ff ff       	jmp    800f7e <vprintfmt+0x29e>
			putch('%', putdat);
  80100c:	83 ec 08             	sub    $0x8,%esp
  80100f:	56                   	push   %esi
  801010:	6a 25                	push   $0x25
  801012:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	89 f8                	mov    %edi,%eax
  801019:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80101d:	74 05                	je     801024 <vprintfmt+0x344>
  80101f:	83 e8 01             	sub    $0x1,%eax
  801022:	eb f5                	jmp    801019 <vprintfmt+0x339>
  801024:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801027:	e9 52 ff ff ff       	jmp    800f7e <vprintfmt+0x29e>
}
  80102c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102f:	5b                   	pop    %ebx
  801030:	5e                   	pop    %esi
  801031:	5f                   	pop    %edi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801034:	f3 0f 1e fb          	endbr32 
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	83 ec 18             	sub    $0x18,%esp
  80103e:	8b 45 08             	mov    0x8(%ebp),%eax
  801041:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801044:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801047:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80104b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80104e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801055:	85 c0                	test   %eax,%eax
  801057:	74 26                	je     80107f <vsnprintf+0x4b>
  801059:	85 d2                	test   %edx,%edx
  80105b:	7e 22                	jle    80107f <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80105d:	ff 75 14             	pushl  0x14(%ebp)
  801060:	ff 75 10             	pushl  0x10(%ebp)
  801063:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801066:	50                   	push   %eax
  801067:	68 9e 0c 80 00       	push   $0x800c9e
  80106c:	e8 6f fc ff ff       	call   800ce0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801071:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801074:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801077:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80107a:	83 c4 10             	add    $0x10,%esp
}
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    
		return -E_INVAL;
  80107f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801084:	eb f7                	jmp    80107d <vsnprintf+0x49>

00801086 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801086:	f3 0f 1e fb          	endbr32 
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801090:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801093:	50                   	push   %eax
  801094:	ff 75 10             	pushl  0x10(%ebp)
  801097:	ff 75 0c             	pushl  0xc(%ebp)
  80109a:	ff 75 08             	pushl  0x8(%ebp)
  80109d:	e8 92 ff ff ff       	call   801034 <vsnprintf>
	va_end(ap);

	return rc;
}
  8010a2:	c9                   	leave  
  8010a3:	c3                   	ret    

008010a4 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8010a4:	f3 0f 1e fb          	endbr32 
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
  8010ab:	57                   	push   %edi
  8010ac:	56                   	push   %esi
  8010ad:	53                   	push   %ebx
  8010ae:	83 ec 0c             	sub    $0xc,%esp
  8010b1:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	74 13                	je     8010cb <readline+0x27>
		fprintf(1, "%s", prompt);
  8010b8:	83 ec 04             	sub    $0x4,%esp
  8010bb:	50                   	push   %eax
  8010bc:	68 ac 36 80 00       	push   $0x8036ac
  8010c1:	6a 01                	push   $0x1
  8010c3:	e8 61 16 00 00       	call   802729 <fprintf>
  8010c8:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  8010cb:	83 ec 0c             	sub    $0xc,%esp
  8010ce:	6a 00                	push   $0x0
  8010d0:	e8 cf f8 ff ff       	call   8009a4 <iscons>
  8010d5:	89 c7                	mov    %eax,%edi
  8010d7:	83 c4 10             	add    $0x10,%esp
	i = 0;
  8010da:	be 00 00 00 00       	mov    $0x0,%esi
  8010df:	eb 57                	jmp    801138 <readline+0x94>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8010e1:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
  8010e6:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8010e9:	75 08                	jne    8010f3 <readline+0x4f>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  8010eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ee:	5b                   	pop    %ebx
  8010ef:	5e                   	pop    %esi
  8010f0:	5f                   	pop    %edi
  8010f1:	5d                   	pop    %ebp
  8010f2:	c3                   	ret    
				cprintf("read error: %e\n", c);
  8010f3:	83 ec 08             	sub    $0x8,%esp
  8010f6:	53                   	push   %ebx
  8010f7:	68 9f 3a 80 00       	push   $0x803a9f
  8010fc:	e8 7c fa ff ff       	call   800b7d <cprintf>
  801101:	83 c4 10             	add    $0x10,%esp
			return NULL;
  801104:	b8 00 00 00 00       	mov    $0x0,%eax
  801109:	eb e0                	jmp    8010eb <readline+0x47>
			if (echoing)
  80110b:	85 ff                	test   %edi,%edi
  80110d:	75 05                	jne    801114 <readline+0x70>
			i--;
  80110f:	83 ee 01             	sub    $0x1,%esi
  801112:	eb 24                	jmp    801138 <readline+0x94>
				cputchar('\b');
  801114:	83 ec 0c             	sub    $0xc,%esp
  801117:	6a 08                	push   $0x8
  801119:	e8 39 f8 ff ff       	call   800957 <cputchar>
  80111e:	83 c4 10             	add    $0x10,%esp
  801121:	eb ec                	jmp    80110f <readline+0x6b>
				cputchar(c);
  801123:	83 ec 0c             	sub    $0xc,%esp
  801126:	53                   	push   %ebx
  801127:	e8 2b f8 ff ff       	call   800957 <cputchar>
  80112c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  80112f:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  801135:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
  801138:	e8 3a f8 ff ff       	call   800977 <getchar>
  80113d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80113f:	85 c0                	test   %eax,%eax
  801141:	78 9e                	js     8010e1 <readline+0x3d>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  801143:	83 f8 08             	cmp    $0x8,%eax
  801146:	0f 94 c2             	sete   %dl
  801149:	83 f8 7f             	cmp    $0x7f,%eax
  80114c:	0f 94 c0             	sete   %al
  80114f:	08 c2                	or     %al,%dl
  801151:	74 04                	je     801157 <readline+0xb3>
  801153:	85 f6                	test   %esi,%esi
  801155:	7f b4                	jg     80110b <readline+0x67>
		} else if (c >= ' ' && i < BUFLEN-1) {
  801157:	83 fb 1f             	cmp    $0x1f,%ebx
  80115a:	7e 0e                	jle    80116a <readline+0xc6>
  80115c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801162:	7f 06                	jg     80116a <readline+0xc6>
			if (echoing)
  801164:	85 ff                	test   %edi,%edi
  801166:	74 c7                	je     80112f <readline+0x8b>
  801168:	eb b9                	jmp    801123 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
  80116a:	83 fb 0a             	cmp    $0xa,%ebx
  80116d:	74 05                	je     801174 <readline+0xd0>
  80116f:	83 fb 0d             	cmp    $0xd,%ebx
  801172:	75 c4                	jne    801138 <readline+0x94>
			if (echoing)
  801174:	85 ff                	test   %edi,%edi
  801176:	75 11                	jne    801189 <readline+0xe5>
			buf[i] = 0;
  801178:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  80117f:	b8 20 50 80 00       	mov    $0x805020,%eax
  801184:	e9 62 ff ff ff       	jmp    8010eb <readline+0x47>
				cputchar('\n');
  801189:	83 ec 0c             	sub    $0xc,%esp
  80118c:	6a 0a                	push   $0xa
  80118e:	e8 c4 f7 ff ff       	call   800957 <cputchar>
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	eb e0                	jmp    801178 <readline+0xd4>

00801198 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801198:	f3 0f 1e fb          	endbr32 
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8011a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8011ab:	74 05                	je     8011b2 <strlen+0x1a>
		n++;
  8011ad:	83 c0 01             	add    $0x1,%eax
  8011b0:	eb f5                	jmp    8011a7 <strlen+0xf>
	return n;
}
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    

008011b4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011b4:	f3 0f 1e fb          	endbr32 
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011be:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011c6:	39 d0                	cmp    %edx,%eax
  8011c8:	74 0d                	je     8011d7 <strnlen+0x23>
  8011ca:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8011ce:	74 05                	je     8011d5 <strnlen+0x21>
		n++;
  8011d0:	83 c0 01             	add    $0x1,%eax
  8011d3:	eb f1                	jmp    8011c6 <strnlen+0x12>
  8011d5:	89 c2                	mov    %eax,%edx
	return n;
}
  8011d7:	89 d0                	mov    %edx,%eax
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    

008011db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011db:	f3 0f 1e fb          	endbr32 
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	53                   	push   %ebx
  8011e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ee:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8011f2:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8011f5:	83 c0 01             	add    $0x1,%eax
  8011f8:	84 d2                	test   %dl,%dl
  8011fa:	75 f2                	jne    8011ee <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8011fc:	89 c8                	mov    %ecx,%eax
  8011fe:	5b                   	pop    %ebx
  8011ff:	5d                   	pop    %ebp
  801200:	c3                   	ret    

00801201 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801201:	f3 0f 1e fb          	endbr32 
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	53                   	push   %ebx
  801209:	83 ec 10             	sub    $0x10,%esp
  80120c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80120f:	53                   	push   %ebx
  801210:	e8 83 ff ff ff       	call   801198 <strlen>
  801215:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801218:	ff 75 0c             	pushl  0xc(%ebp)
  80121b:	01 d8                	add    %ebx,%eax
  80121d:	50                   	push   %eax
  80121e:	e8 b8 ff ff ff       	call   8011db <strcpy>
	return dst;
}
  801223:	89 d8                	mov    %ebx,%eax
  801225:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801228:	c9                   	leave  
  801229:	c3                   	ret    

0080122a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80122a:	f3 0f 1e fb          	endbr32 
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	56                   	push   %esi
  801232:	53                   	push   %ebx
  801233:	8b 75 08             	mov    0x8(%ebp),%esi
  801236:	8b 55 0c             	mov    0xc(%ebp),%edx
  801239:	89 f3                	mov    %esi,%ebx
  80123b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80123e:	89 f0                	mov    %esi,%eax
  801240:	39 d8                	cmp    %ebx,%eax
  801242:	74 11                	je     801255 <strncpy+0x2b>
		*dst++ = *src;
  801244:	83 c0 01             	add    $0x1,%eax
  801247:	0f b6 0a             	movzbl (%edx),%ecx
  80124a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80124d:	80 f9 01             	cmp    $0x1,%cl
  801250:	83 da ff             	sbb    $0xffffffff,%edx
  801253:	eb eb                	jmp    801240 <strncpy+0x16>
	}
	return ret;
}
  801255:	89 f0                	mov    %esi,%eax
  801257:	5b                   	pop    %ebx
  801258:	5e                   	pop    %esi
  801259:	5d                   	pop    %ebp
  80125a:	c3                   	ret    

0080125b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80125b:	f3 0f 1e fb          	endbr32 
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	56                   	push   %esi
  801263:	53                   	push   %ebx
  801264:	8b 75 08             	mov    0x8(%ebp),%esi
  801267:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80126a:	8b 55 10             	mov    0x10(%ebp),%edx
  80126d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80126f:	85 d2                	test   %edx,%edx
  801271:	74 21                	je     801294 <strlcpy+0x39>
  801273:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801277:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801279:	39 c2                	cmp    %eax,%edx
  80127b:	74 14                	je     801291 <strlcpy+0x36>
  80127d:	0f b6 19             	movzbl (%ecx),%ebx
  801280:	84 db                	test   %bl,%bl
  801282:	74 0b                	je     80128f <strlcpy+0x34>
			*dst++ = *src++;
  801284:	83 c1 01             	add    $0x1,%ecx
  801287:	83 c2 01             	add    $0x1,%edx
  80128a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80128d:	eb ea                	jmp    801279 <strlcpy+0x1e>
  80128f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801291:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801294:	29 f0                	sub    %esi,%eax
}
  801296:	5b                   	pop    %ebx
  801297:	5e                   	pop    %esi
  801298:	5d                   	pop    %ebp
  801299:	c3                   	ret    

0080129a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80129a:	f3 0f 1e fb          	endbr32 
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8012a7:	0f b6 01             	movzbl (%ecx),%eax
  8012aa:	84 c0                	test   %al,%al
  8012ac:	74 0c                	je     8012ba <strcmp+0x20>
  8012ae:	3a 02                	cmp    (%edx),%al
  8012b0:	75 08                	jne    8012ba <strcmp+0x20>
		p++, q++;
  8012b2:	83 c1 01             	add    $0x1,%ecx
  8012b5:	83 c2 01             	add    $0x1,%edx
  8012b8:	eb ed                	jmp    8012a7 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8012ba:	0f b6 c0             	movzbl %al,%eax
  8012bd:	0f b6 12             	movzbl (%edx),%edx
  8012c0:	29 d0                	sub    %edx,%eax
}
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    

008012c4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8012c4:	f3 0f 1e fb          	endbr32 
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	53                   	push   %ebx
  8012cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d2:	89 c3                	mov    %eax,%ebx
  8012d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8012d7:	eb 06                	jmp    8012df <strncmp+0x1b>
		n--, p++, q++;
  8012d9:	83 c0 01             	add    $0x1,%eax
  8012dc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8012df:	39 d8                	cmp    %ebx,%eax
  8012e1:	74 16                	je     8012f9 <strncmp+0x35>
  8012e3:	0f b6 08             	movzbl (%eax),%ecx
  8012e6:	84 c9                	test   %cl,%cl
  8012e8:	74 04                	je     8012ee <strncmp+0x2a>
  8012ea:	3a 0a                	cmp    (%edx),%cl
  8012ec:	74 eb                	je     8012d9 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8012ee:	0f b6 00             	movzbl (%eax),%eax
  8012f1:	0f b6 12             	movzbl (%edx),%edx
  8012f4:	29 d0                	sub    %edx,%eax
}
  8012f6:	5b                   	pop    %ebx
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    
		return 0;
  8012f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fe:	eb f6                	jmp    8012f6 <strncmp+0x32>

00801300 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801300:	f3 0f 1e fb          	endbr32 
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	8b 45 08             	mov    0x8(%ebp),%eax
  80130a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80130e:	0f b6 10             	movzbl (%eax),%edx
  801311:	84 d2                	test   %dl,%dl
  801313:	74 09                	je     80131e <strchr+0x1e>
		if (*s == c)
  801315:	38 ca                	cmp    %cl,%dl
  801317:	74 0a                	je     801323 <strchr+0x23>
	for (; *s; s++)
  801319:	83 c0 01             	add    $0x1,%eax
  80131c:	eb f0                	jmp    80130e <strchr+0xe>
			return (char *) s;
	return 0;
  80131e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801323:	5d                   	pop    %ebp
  801324:	c3                   	ret    

00801325 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801325:	f3 0f 1e fb          	endbr32 
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	8b 45 08             	mov    0x8(%ebp),%eax
  80132f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801333:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801336:	38 ca                	cmp    %cl,%dl
  801338:	74 09                	je     801343 <strfind+0x1e>
  80133a:	84 d2                	test   %dl,%dl
  80133c:	74 05                	je     801343 <strfind+0x1e>
	for (; *s; s++)
  80133e:	83 c0 01             	add    $0x1,%eax
  801341:	eb f0                	jmp    801333 <strfind+0xe>
			break;
	return (char *) s;
}
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801345:	f3 0f 1e fb          	endbr32 
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	57                   	push   %edi
  80134d:	56                   	push   %esi
  80134e:	53                   	push   %ebx
  80134f:	8b 55 08             	mov    0x8(%ebp),%edx
  801352:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  801355:	85 c9                	test   %ecx,%ecx
  801357:	74 33                	je     80138c <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801359:	89 d0                	mov    %edx,%eax
  80135b:	09 c8                	or     %ecx,%eax
  80135d:	a8 03                	test   $0x3,%al
  80135f:	75 23                	jne    801384 <memset+0x3f>
		c &= 0xFF;
  801361:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801365:	89 d8                	mov    %ebx,%eax
  801367:	c1 e0 08             	shl    $0x8,%eax
  80136a:	89 df                	mov    %ebx,%edi
  80136c:	c1 e7 18             	shl    $0x18,%edi
  80136f:	89 de                	mov    %ebx,%esi
  801371:	c1 e6 10             	shl    $0x10,%esi
  801374:	09 f7                	or     %esi,%edi
  801376:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  801378:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80137b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80137d:	89 d7                	mov    %edx,%edi
  80137f:	fc                   	cld    
  801380:	f3 ab                	rep stos %eax,%es:(%edi)
  801382:	eb 08                	jmp    80138c <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801384:	89 d7                	mov    %edx,%edi
  801386:	8b 45 0c             	mov    0xc(%ebp),%eax
  801389:	fc                   	cld    
  80138a:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  80138c:	89 d0                	mov    %edx,%eax
  80138e:	5b                   	pop    %ebx
  80138f:	5e                   	pop    %esi
  801390:	5f                   	pop    %edi
  801391:	5d                   	pop    %ebp
  801392:	c3                   	ret    

00801393 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801393:	f3 0f 1e fb          	endbr32 
  801397:	55                   	push   %ebp
  801398:	89 e5                	mov    %esp,%ebp
  80139a:	57                   	push   %edi
  80139b:	56                   	push   %esi
  80139c:	8b 45 08             	mov    0x8(%ebp),%eax
  80139f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8013a5:	39 c6                	cmp    %eax,%esi
  8013a7:	73 32                	jae    8013db <memmove+0x48>
  8013a9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8013ac:	39 c2                	cmp    %eax,%edx
  8013ae:	76 2b                	jbe    8013db <memmove+0x48>
		s += n;
		d += n;
  8013b0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013b3:	89 fe                	mov    %edi,%esi
  8013b5:	09 ce                	or     %ecx,%esi
  8013b7:	09 d6                	or     %edx,%esi
  8013b9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8013bf:	75 0e                	jne    8013cf <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8013c1:	83 ef 04             	sub    $0x4,%edi
  8013c4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8013c7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8013ca:	fd                   	std    
  8013cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013cd:	eb 09                	jmp    8013d8 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8013cf:	83 ef 01             	sub    $0x1,%edi
  8013d2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8013d5:	fd                   	std    
  8013d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8013d8:	fc                   	cld    
  8013d9:	eb 1a                	jmp    8013f5 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013db:	89 c2                	mov    %eax,%edx
  8013dd:	09 ca                	or     %ecx,%edx
  8013df:	09 f2                	or     %esi,%edx
  8013e1:	f6 c2 03             	test   $0x3,%dl
  8013e4:	75 0a                	jne    8013f0 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8013e6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8013e9:	89 c7                	mov    %eax,%edi
  8013eb:	fc                   	cld    
  8013ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013ee:	eb 05                	jmp    8013f5 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8013f0:	89 c7                	mov    %eax,%edi
  8013f2:	fc                   	cld    
  8013f3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8013f5:	5e                   	pop    %esi
  8013f6:	5f                   	pop    %edi
  8013f7:	5d                   	pop    %ebp
  8013f8:	c3                   	ret    

008013f9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8013f9:	f3 0f 1e fb          	endbr32 
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801403:	ff 75 10             	pushl  0x10(%ebp)
  801406:	ff 75 0c             	pushl  0xc(%ebp)
  801409:	ff 75 08             	pushl  0x8(%ebp)
  80140c:	e8 82 ff ff ff       	call   801393 <memmove>
}
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801413:	f3 0f 1e fb          	endbr32 
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	56                   	push   %esi
  80141b:	53                   	push   %ebx
  80141c:	8b 45 08             	mov    0x8(%ebp),%eax
  80141f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801422:	89 c6                	mov    %eax,%esi
  801424:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801427:	39 f0                	cmp    %esi,%eax
  801429:	74 1c                	je     801447 <memcmp+0x34>
		if (*s1 != *s2)
  80142b:	0f b6 08             	movzbl (%eax),%ecx
  80142e:	0f b6 1a             	movzbl (%edx),%ebx
  801431:	38 d9                	cmp    %bl,%cl
  801433:	75 08                	jne    80143d <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801435:	83 c0 01             	add    $0x1,%eax
  801438:	83 c2 01             	add    $0x1,%edx
  80143b:	eb ea                	jmp    801427 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  80143d:	0f b6 c1             	movzbl %cl,%eax
  801440:	0f b6 db             	movzbl %bl,%ebx
  801443:	29 d8                	sub    %ebx,%eax
  801445:	eb 05                	jmp    80144c <memcmp+0x39>
	}

	return 0;
  801447:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80144c:	5b                   	pop    %ebx
  80144d:	5e                   	pop    %esi
  80144e:	5d                   	pop    %ebp
  80144f:	c3                   	ret    

00801450 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801450:	f3 0f 1e fb          	endbr32 
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	8b 45 08             	mov    0x8(%ebp),%eax
  80145a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80145d:	89 c2                	mov    %eax,%edx
  80145f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801462:	39 d0                	cmp    %edx,%eax
  801464:	73 09                	jae    80146f <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801466:	38 08                	cmp    %cl,(%eax)
  801468:	74 05                	je     80146f <memfind+0x1f>
	for (; s < ends; s++)
  80146a:	83 c0 01             	add    $0x1,%eax
  80146d:	eb f3                	jmp    801462 <memfind+0x12>
			break;
	return (void *) s;
}
  80146f:	5d                   	pop    %ebp
  801470:	c3                   	ret    

00801471 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801471:	f3 0f 1e fb          	endbr32 
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	57                   	push   %edi
  801479:	56                   	push   %esi
  80147a:	53                   	push   %ebx
  80147b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80147e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801481:	eb 03                	jmp    801486 <strtol+0x15>
		s++;
  801483:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801486:	0f b6 01             	movzbl (%ecx),%eax
  801489:	3c 20                	cmp    $0x20,%al
  80148b:	74 f6                	je     801483 <strtol+0x12>
  80148d:	3c 09                	cmp    $0x9,%al
  80148f:	74 f2                	je     801483 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801491:	3c 2b                	cmp    $0x2b,%al
  801493:	74 2a                	je     8014bf <strtol+0x4e>
	int neg = 0;
  801495:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80149a:	3c 2d                	cmp    $0x2d,%al
  80149c:	74 2b                	je     8014c9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80149e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8014a4:	75 0f                	jne    8014b5 <strtol+0x44>
  8014a6:	80 39 30             	cmpb   $0x30,(%ecx)
  8014a9:	74 28                	je     8014d3 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8014ab:	85 db                	test   %ebx,%ebx
  8014ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014b2:	0f 44 d8             	cmove  %eax,%ebx
  8014b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ba:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8014bd:	eb 46                	jmp    801505 <strtol+0x94>
		s++;
  8014bf:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8014c2:	bf 00 00 00 00       	mov    $0x0,%edi
  8014c7:	eb d5                	jmp    80149e <strtol+0x2d>
		s++, neg = 1;
  8014c9:	83 c1 01             	add    $0x1,%ecx
  8014cc:	bf 01 00 00 00       	mov    $0x1,%edi
  8014d1:	eb cb                	jmp    80149e <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8014d3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8014d7:	74 0e                	je     8014e7 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8014d9:	85 db                	test   %ebx,%ebx
  8014db:	75 d8                	jne    8014b5 <strtol+0x44>
		s++, base = 8;
  8014dd:	83 c1 01             	add    $0x1,%ecx
  8014e0:	bb 08 00 00 00       	mov    $0x8,%ebx
  8014e5:	eb ce                	jmp    8014b5 <strtol+0x44>
		s += 2, base = 16;
  8014e7:	83 c1 02             	add    $0x2,%ecx
  8014ea:	bb 10 00 00 00       	mov    $0x10,%ebx
  8014ef:	eb c4                	jmp    8014b5 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8014f1:	0f be d2             	movsbl %dl,%edx
  8014f4:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8014f7:	3b 55 10             	cmp    0x10(%ebp),%edx
  8014fa:	7d 3a                	jge    801536 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8014fc:	83 c1 01             	add    $0x1,%ecx
  8014ff:	0f af 45 10          	imul   0x10(%ebp),%eax
  801503:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801505:	0f b6 11             	movzbl (%ecx),%edx
  801508:	8d 72 d0             	lea    -0x30(%edx),%esi
  80150b:	89 f3                	mov    %esi,%ebx
  80150d:	80 fb 09             	cmp    $0x9,%bl
  801510:	76 df                	jbe    8014f1 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801512:	8d 72 9f             	lea    -0x61(%edx),%esi
  801515:	89 f3                	mov    %esi,%ebx
  801517:	80 fb 19             	cmp    $0x19,%bl
  80151a:	77 08                	ja     801524 <strtol+0xb3>
			dig = *s - 'a' + 10;
  80151c:	0f be d2             	movsbl %dl,%edx
  80151f:	83 ea 57             	sub    $0x57,%edx
  801522:	eb d3                	jmp    8014f7 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801524:	8d 72 bf             	lea    -0x41(%edx),%esi
  801527:	89 f3                	mov    %esi,%ebx
  801529:	80 fb 19             	cmp    $0x19,%bl
  80152c:	77 08                	ja     801536 <strtol+0xc5>
			dig = *s - 'A' + 10;
  80152e:	0f be d2             	movsbl %dl,%edx
  801531:	83 ea 37             	sub    $0x37,%edx
  801534:	eb c1                	jmp    8014f7 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801536:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80153a:	74 05                	je     801541 <strtol+0xd0>
		*endptr = (char *) s;
  80153c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80153f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801541:	89 c2                	mov    %eax,%edx
  801543:	f7 da                	neg    %edx
  801545:	85 ff                	test   %edi,%edi
  801547:	0f 45 c2             	cmovne %edx,%eax
}
  80154a:	5b                   	pop    %ebx
  80154b:	5e                   	pop    %esi
  80154c:	5f                   	pop    %edi
  80154d:	5d                   	pop    %ebp
  80154e:	c3                   	ret    

0080154f <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	57                   	push   %edi
  801553:	56                   	push   %esi
  801554:	53                   	push   %ebx
  801555:	83 ec 1c             	sub    $0x1c,%esp
  801558:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80155b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80155e:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801560:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801563:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801566:	8b 7d 10             	mov    0x10(%ebp),%edi
  801569:	8b 75 14             	mov    0x14(%ebp),%esi
  80156c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80156e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801572:	74 04                	je     801578 <syscall+0x29>
  801574:	85 c0                	test   %eax,%eax
  801576:	7f 08                	jg     801580 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  801578:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80157b:	5b                   	pop    %ebx
  80157c:	5e                   	pop    %esi
  80157d:	5f                   	pop    %edi
  80157e:	5d                   	pop    %ebp
  80157f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801580:	83 ec 0c             	sub    $0xc,%esp
  801583:	50                   	push   %eax
  801584:	ff 75 e0             	pushl  -0x20(%ebp)
  801587:	68 af 3a 80 00       	push   $0x803aaf
  80158c:	6a 23                	push   $0x23
  80158e:	68 cc 3a 80 00       	push   $0x803acc
  801593:	e8 fe f4 ff ff       	call   800a96 <_panic>

00801598 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  801598:	f3 0f 1e fb          	endbr32 
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8015a2:	6a 00                	push   $0x0
  8015a4:	6a 00                	push   $0x0
  8015a6:	6a 00                	push   $0x0
  8015a8:	ff 75 0c             	pushl  0xc(%ebp)
  8015ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b8:	e8 92 ff ff ff       	call   80154f <syscall>
}
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	c9                   	leave  
  8015c1:	c3                   	ret    

008015c2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8015c2:	f3 0f 1e fb          	endbr32 
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8015cc:	6a 00                	push   $0x0
  8015ce:	6a 00                	push   $0x0
  8015d0:	6a 00                	push   $0x0
  8015d2:	6a 00                	push   $0x0
  8015d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015de:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e3:	e8 67 ff ff ff       	call   80154f <syscall>
}
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    

008015ea <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8015ea:	f3 0f 1e fb          	endbr32 
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8015f4:	6a 00                	push   $0x0
  8015f6:	6a 00                	push   $0x0
  8015f8:	6a 00                	push   $0x0
  8015fa:	6a 00                	push   $0x0
  8015fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015ff:	ba 01 00 00 00       	mov    $0x1,%edx
  801604:	b8 03 00 00 00       	mov    $0x3,%eax
  801609:	e8 41 ff ff ff       	call   80154f <syscall>
}
  80160e:	c9                   	leave  
  80160f:	c3                   	ret    

00801610 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801610:	f3 0f 1e fb          	endbr32 
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80161a:	6a 00                	push   $0x0
  80161c:	6a 00                	push   $0x0
  80161e:	6a 00                	push   $0x0
  801620:	6a 00                	push   $0x0
  801622:	b9 00 00 00 00       	mov    $0x0,%ecx
  801627:	ba 00 00 00 00       	mov    $0x0,%edx
  80162c:	b8 02 00 00 00       	mov    $0x2,%eax
  801631:	e8 19 ff ff ff       	call   80154f <syscall>
}
  801636:	c9                   	leave  
  801637:	c3                   	ret    

00801638 <sys_yield>:

void
sys_yield(void)
{
  801638:	f3 0f 1e fb          	endbr32 
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801642:	6a 00                	push   $0x0
  801644:	6a 00                	push   $0x0
  801646:	6a 00                	push   $0x0
  801648:	6a 00                	push   $0x0
  80164a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80164f:	ba 00 00 00 00       	mov    $0x0,%edx
  801654:	b8 0b 00 00 00       	mov    $0xb,%eax
  801659:	e8 f1 fe ff ff       	call   80154f <syscall>
}
  80165e:	83 c4 10             	add    $0x10,%esp
  801661:	c9                   	leave  
  801662:	c3                   	ret    

00801663 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801663:	f3 0f 1e fb          	endbr32 
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80166d:	6a 00                	push   $0x0
  80166f:	6a 00                	push   $0x0
  801671:	ff 75 10             	pushl  0x10(%ebp)
  801674:	ff 75 0c             	pushl  0xc(%ebp)
  801677:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80167a:	ba 01 00 00 00       	mov    $0x1,%edx
  80167f:	b8 04 00 00 00       	mov    $0x4,%eax
  801684:	e8 c6 fe ff ff       	call   80154f <syscall>
}
  801689:	c9                   	leave  
  80168a:	c3                   	ret    

0080168b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80168b:	f3 0f 1e fb          	endbr32 
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801695:	ff 75 18             	pushl  0x18(%ebp)
  801698:	ff 75 14             	pushl  0x14(%ebp)
  80169b:	ff 75 10             	pushl  0x10(%ebp)
  80169e:	ff 75 0c             	pushl  0xc(%ebp)
  8016a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a4:	ba 01 00 00 00       	mov    $0x1,%edx
  8016a9:	b8 05 00 00 00       	mov    $0x5,%eax
  8016ae:	e8 9c fe ff ff       	call   80154f <syscall>
}
  8016b3:	c9                   	leave  
  8016b4:	c3                   	ret    

008016b5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8016b5:	f3 0f 1e fb          	endbr32 
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8016bf:	6a 00                	push   $0x0
  8016c1:	6a 00                	push   $0x0
  8016c3:	6a 00                	push   $0x0
  8016c5:	ff 75 0c             	pushl  0xc(%ebp)
  8016c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016cb:	ba 01 00 00 00       	mov    $0x1,%edx
  8016d0:	b8 06 00 00 00       	mov    $0x6,%eax
  8016d5:	e8 75 fe ff ff       	call   80154f <syscall>
}
  8016da:	c9                   	leave  
  8016db:	c3                   	ret    

008016dc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8016dc:	f3 0f 1e fb          	endbr32 
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8016e6:	6a 00                	push   $0x0
  8016e8:	6a 00                	push   $0x0
  8016ea:	6a 00                	push   $0x0
  8016ec:	ff 75 0c             	pushl  0xc(%ebp)
  8016ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f2:	ba 01 00 00 00       	mov    $0x1,%edx
  8016f7:	b8 08 00 00 00       	mov    $0x8,%eax
  8016fc:	e8 4e fe ff ff       	call   80154f <syscall>
}
  801701:	c9                   	leave  
  801702:	c3                   	ret    

00801703 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801703:	f3 0f 1e fb          	endbr32 
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80170d:	6a 00                	push   $0x0
  80170f:	6a 00                	push   $0x0
  801711:	6a 00                	push   $0x0
  801713:	ff 75 0c             	pushl  0xc(%ebp)
  801716:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801719:	ba 01 00 00 00       	mov    $0x1,%edx
  80171e:	b8 09 00 00 00       	mov    $0x9,%eax
  801723:	e8 27 fe ff ff       	call   80154f <syscall>
}
  801728:	c9                   	leave  
  801729:	c3                   	ret    

0080172a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80172a:	f3 0f 1e fb          	endbr32 
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801734:	6a 00                	push   $0x0
  801736:	6a 00                	push   $0x0
  801738:	6a 00                	push   $0x0
  80173a:	ff 75 0c             	pushl  0xc(%ebp)
  80173d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801740:	ba 01 00 00 00       	mov    $0x1,%edx
  801745:	b8 0a 00 00 00       	mov    $0xa,%eax
  80174a:	e8 00 fe ff ff       	call   80154f <syscall>
}
  80174f:	c9                   	leave  
  801750:	c3                   	ret    

00801751 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801751:	f3 0f 1e fb          	endbr32 
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80175b:	6a 00                	push   $0x0
  80175d:	ff 75 14             	pushl  0x14(%ebp)
  801760:	ff 75 10             	pushl  0x10(%ebp)
  801763:	ff 75 0c             	pushl  0xc(%ebp)
  801766:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801769:	ba 00 00 00 00       	mov    $0x0,%edx
  80176e:	b8 0c 00 00 00       	mov    $0xc,%eax
  801773:	e8 d7 fd ff ff       	call   80154f <syscall>
}
  801778:	c9                   	leave  
  801779:	c3                   	ret    

0080177a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80177a:	f3 0f 1e fb          	endbr32 
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801784:	6a 00                	push   $0x0
  801786:	6a 00                	push   $0x0
  801788:	6a 00                	push   $0x0
  80178a:	6a 00                	push   $0x0
  80178c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80178f:	ba 01 00 00 00       	mov    $0x1,%edx
  801794:	b8 0d 00 00 00       	mov    $0xd,%eax
  801799:	e8 b1 fd ff ff       	call   80154f <syscall>
}
  80179e:	c9                   	leave  
  80179f:	c3                   	ret    

008017a0 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	53                   	push   %ebx
  8017a4:	83 ec 04             	sub    $0x4,%esp
	int r;

	// LAB 4: Your code here.
	void *addr = (void *) (pn * PGSIZE);
  8017a7:	89 d3                	mov    %edx,%ebx
  8017a9:	c1 e3 0c             	shl    $0xc,%ebx

	if (uvpt[pn] & PTE_SHARE) {
  8017ac:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  8017b3:	f6 c5 04             	test   $0x4,%ch
  8017b6:	75 56                	jne    80180e <duppage+0x6e>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
		return 0;
	}

	if ((uvpt[pn] & (PTE_W | PTE_COW)) != 0) {
  8017b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017bf:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8017c5:	74 72                	je     801839 <duppage+0x99>
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW) <
  8017c7:	83 ec 0c             	sub    $0xc,%esp
  8017ca:	68 05 08 00 00       	push   $0x805
  8017cf:	53                   	push   %ebx
  8017d0:	50                   	push   %eax
  8017d1:	53                   	push   %ebx
  8017d2:	6a 00                	push   $0x0
  8017d4:	e8 b2 fe ff ff       	call   80168b <sys_page_map>
  8017d9:	83 c4 20             	add    $0x20,%esp
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 45                	js     801825 <duppage+0x85>
		    0) {
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
		}
		if (sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW) < 0) {
  8017e0:	83 ec 0c             	sub    $0xc,%esp
  8017e3:	68 05 08 00 00       	push   $0x805
  8017e8:	53                   	push   %ebx
  8017e9:	6a 00                	push   $0x0
  8017eb:	53                   	push   %ebx
  8017ec:	6a 00                	push   $0x0
  8017ee:	e8 98 fe ff ff       	call   80168b <sys_page_map>
  8017f3:	83 c4 20             	add    $0x20,%esp
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	79 55                	jns    80184f <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP FATHER");
  8017fa:	83 ec 04             	sub    $0x4,%esp
  8017fd:	68 fc 3a 80 00       	push   $0x803afc
  801802:	6a 54                	push   $0x54
  801804:	68 8f 3b 80 00       	push   $0x803b8f
  801809:	e8 88 f2 ff ff       	call   800a96 <_panic>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  80180e:	83 ec 0c             	sub    $0xc,%esp
  801811:	68 07 0e 00 00       	push   $0xe07
  801816:	53                   	push   %ebx
  801817:	50                   	push   %eax
  801818:	53                   	push   %ebx
  801819:	6a 00                	push   $0x0
  80181b:	e8 6b fe ff ff       	call   80168b <sys_page_map>
		return 0;
  801820:	83 c4 20             	add    $0x20,%esp
  801823:	eb 2a                	jmp    80184f <duppage+0xaf>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP SON");
  801825:	83 ec 04             	sub    $0x4,%esp
  801828:	68 dc 3a 80 00       	push   $0x803adc
  80182d:	6a 51                	push   $0x51
  80182f:	68 8f 3b 80 00       	push   $0x803b8f
  801834:	e8 5d f2 ff ff       	call   800a96 <_panic>
		}
	} else {
		if (sys_page_map(0, addr, envid, addr, PTE_P | PTE_U) < 0) {
  801839:	83 ec 0c             	sub    $0xc,%esp
  80183c:	6a 05                	push   $0x5
  80183e:	53                   	push   %ebx
  80183f:	50                   	push   %eax
  801840:	53                   	push   %ebx
  801841:	6a 00                	push   $0x0
  801843:	e8 43 fe ff ff       	call   80168b <sys_page_map>
  801848:	83 c4 20             	add    $0x20,%esp
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 0a                	js     801859 <duppage+0xb9>
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
		}
	}

	return 0;
}
  80184f:	b8 00 00 00 00       	mov    $0x0,%eax
  801854:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801857:	c9                   	leave  
  801858:	c3                   	ret    
			panic("ERROR DUPPAGE: SYS_PAGE_MAP");
  801859:	83 ec 04             	sub    $0x4,%esp
  80185c:	68 9a 3b 80 00       	push   $0x803b9a
  801861:	6a 58                	push   $0x58
  801863:	68 8f 3b 80 00       	push   $0x803b8f
  801868:	e8 29 f2 ff ff       	call   800a96 <_panic>

0080186d <dup_or_share>:

static void
dup_or_share(envid_t dstenv, void *va, int perm)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	56                   	push   %esi
  801871:	53                   	push   %ebx
  801872:	89 c6                	mov    %eax,%esi
  801874:	89 d3                	mov    %edx,%ebx
	int r;
	if (perm & PTE_W) {
  801876:	f6 c1 02             	test   $0x2,%cl
  801879:	0f 84 8c 00 00 00    	je     80190b <dup_or_share+0x9e>
		// dup
		if ((r = sys_page_alloc(dstenv, va, PTE_P | PTE_U | PTE_W)) < 0)
  80187f:	83 ec 04             	sub    $0x4,%esp
  801882:	6a 07                	push   $0x7
  801884:	52                   	push   %edx
  801885:	50                   	push   %eax
  801886:	e8 d8 fd ff ff       	call   801663 <sys_page_alloc>
  80188b:	83 c4 10             	add    $0x10,%esp
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 55                	js     8018e7 <dup_or_share+0x7a>
			panic("sys_page_alloc: %e", r);
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  801892:	83 ec 0c             	sub    $0xc,%esp
  801895:	6a 07                	push   $0x7
  801897:	68 00 00 40 00       	push   $0x400000
  80189c:	6a 00                	push   $0x0
  80189e:	53                   	push   %ebx
  80189f:	56                   	push   %esi
  8018a0:	e8 e6 fd ff ff       	call   80168b <sys_page_map>
  8018a5:	83 c4 20             	add    $0x20,%esp
  8018a8:	85 c0                	test   %eax,%eax
  8018aa:	78 4d                	js     8018f9 <dup_or_share+0x8c>
		    0)
			panic("sys_page_map: %e", r);
		memmove(UTEMP, va, PGSIZE);
  8018ac:	83 ec 04             	sub    $0x4,%esp
  8018af:	68 00 10 00 00       	push   $0x1000
  8018b4:	53                   	push   %ebx
  8018b5:	68 00 00 40 00       	push   $0x400000
  8018ba:	e8 d4 fa ff ff       	call   801393 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8018bf:	83 c4 08             	add    $0x8,%esp
  8018c2:	68 00 00 40 00       	push   $0x400000
  8018c7:	6a 00                	push   $0x0
  8018c9:	e8 e7 fd ff ff       	call   8016b5 <sys_page_unmap>
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	85 c0                	test   %eax,%eax
  8018d3:	79 52                	jns    801927 <dup_or_share+0xba>
			panic("sys_page_unmap: %e", r);
  8018d5:	50                   	push   %eax
  8018d6:	68 da 3b 80 00       	push   $0x803bda
  8018db:	6a 6c                	push   $0x6c
  8018dd:	68 8f 3b 80 00       	push   $0x803b8f
  8018e2:	e8 af f1 ff ff       	call   800a96 <_panic>
			panic("sys_page_alloc: %e", r);
  8018e7:	50                   	push   %eax
  8018e8:	68 b6 3b 80 00       	push   $0x803bb6
  8018ed:	6a 66                	push   $0x66
  8018ef:	68 8f 3b 80 00       	push   $0x803b8f
  8018f4:	e8 9d f1 ff ff       	call   800a96 <_panic>
			panic("sys_page_map: %e", r);
  8018f9:	50                   	push   %eax
  8018fa:	68 c9 3b 80 00       	push   $0x803bc9
  8018ff:	6a 69                	push   $0x69
  801901:	68 8f 3b 80 00       	push   $0x803b8f
  801906:	e8 8b f1 ff ff       	call   800a96 <_panic>

	} else {
		// share
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, PTE_P | PTE_U | perm)) <
  80190b:	83 ec 0c             	sub    $0xc,%esp
  80190e:	83 c9 05             	or     $0x5,%ecx
  801911:	51                   	push   %ecx
  801912:	68 00 00 40 00       	push   $0x400000
  801917:	6a 00                	push   $0x0
  801919:	52                   	push   %edx
  80191a:	50                   	push   %eax
  80191b:	e8 6b fd ff ff       	call   80168b <sys_page_map>
  801920:	83 c4 20             	add    $0x20,%esp
  801923:	85 c0                	test   %eax,%eax
  801925:	78 07                	js     80192e <dup_or_share+0xc1>
		    0)
			panic("sys_page_map: %e", r);
	}
}
  801927:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192a:	5b                   	pop    %ebx
  80192b:	5e                   	pop    %esi
  80192c:	5d                   	pop    %ebp
  80192d:	c3                   	ret    
			panic("sys_page_map: %e", r);
  80192e:	50                   	push   %eax
  80192f:	68 c9 3b 80 00       	push   $0x803bc9
  801934:	6a 72                	push   $0x72
  801936:	68 8f 3b 80 00       	push   $0x803b8f
  80193b:	e8 56 f1 ff ff       	call   800a96 <_panic>

00801940 <pgfault>:
{
  801940:	f3 0f 1e fb          	endbr32 
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	53                   	push   %ebx
  801948:	83 ec 04             	sub    $0x4,%esp
  80194b:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  80194e:	8b 02                	mov    (%edx),%eax
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  801950:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  801954:	0f 84 95 00 00 00    	je     8019ef <pgfault+0xaf>
  80195a:	89 c2                	mov    %eax,%edx
  80195c:	c1 ea 16             	shr    $0x16,%edx
  80195f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801966:	f6 c2 01             	test   $0x1,%dl
  801969:	0f 84 80 00 00 00    	je     8019ef <pgfault+0xaf>
	    (~uvpt[PGNUM(addr)] & (PTE_COW | PTE_P)) != 0) {
  80196f:	89 c2                	mov    %eax,%edx
  801971:	c1 ea 0c             	shr    $0xc,%edx
  801974:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80197b:	f7 d2                	not    %edx
	if ((err & FEC_WR) == 0 || (uvpd[PDX(addr)] & PTE_P) == 0 ||
  80197d:	f7 c2 01 08 00 00    	test   $0x801,%edx
  801983:	75 6a                	jne    8019ef <pgfault+0xaf>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  801985:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80198a:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U) < 0) {
  80198c:	83 ec 04             	sub    $0x4,%esp
  80198f:	6a 07                	push   $0x7
  801991:	68 00 f0 7f 00       	push   $0x7ff000
  801996:	6a 00                	push   $0x0
  801998:	e8 c6 fc ff ff       	call   801663 <sys_page_alloc>
  80199d:	83 c4 10             	add    $0x10,%esp
  8019a0:	85 c0                	test   %eax,%eax
  8019a2:	78 5f                	js     801a03 <pgfault+0xc3>
	memcpy((void *) PFTEMP, addr, PGSIZE);
  8019a4:	83 ec 04             	sub    $0x4,%esp
  8019a7:	68 00 10 00 00       	push   $0x1000
  8019ac:	53                   	push   %ebx
  8019ad:	68 00 f0 7f 00       	push   $0x7ff000
  8019b2:	e8 42 fa ff ff       	call   8013f9 <memcpy>
	if (sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U) < 0) {
  8019b7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8019be:	53                   	push   %ebx
  8019bf:	6a 00                	push   $0x0
  8019c1:	68 00 f0 7f 00       	push   $0x7ff000
  8019c6:	6a 00                	push   $0x0
  8019c8:	e8 be fc ff ff       	call   80168b <sys_page_map>
  8019cd:	83 c4 20             	add    $0x20,%esp
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	78 43                	js     801a17 <pgfault+0xd7>
	if (sys_page_unmap(0, (void *) PFTEMP) < 0) {
  8019d4:	83 ec 08             	sub    $0x8,%esp
  8019d7:	68 00 f0 7f 00       	push   $0x7ff000
  8019dc:	6a 00                	push   $0x0
  8019de:	e8 d2 fc ff ff       	call   8016b5 <sys_page_unmap>
  8019e3:	83 c4 10             	add    $0x10,%esp
  8019e6:	85 c0                	test   %eax,%eax
  8019e8:	78 41                	js     801a2b <pgfault+0xeb>
}
  8019ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ed:	c9                   	leave  
  8019ee:	c3                   	ret    
		panic("ERROR PGFAULT");
  8019ef:	83 ec 04             	sub    $0x4,%esp
  8019f2:	68 ed 3b 80 00       	push   $0x803bed
  8019f7:	6a 1e                	push   $0x1e
  8019f9:	68 8f 3b 80 00       	push   $0x803b8f
  8019fe:	e8 93 f0 ff ff       	call   800a96 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_ALLOC");
  801a03:	83 ec 04             	sub    $0x4,%esp
  801a06:	68 fb 3b 80 00       	push   $0x803bfb
  801a0b:	6a 2b                	push   $0x2b
  801a0d:	68 8f 3b 80 00       	push   $0x803b8f
  801a12:	e8 7f f0 ff ff       	call   800a96 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_MAP");
  801a17:	83 ec 04             	sub    $0x4,%esp
  801a1a:	68 19 3c 80 00       	push   $0x803c19
  801a1f:	6a 2f                	push   $0x2f
  801a21:	68 8f 3b 80 00       	push   $0x803b8f
  801a26:	e8 6b f0 ff ff       	call   800a96 <_panic>
		panic("ERROR PGFAULT: SYS_PAGE_UNMAP");
  801a2b:	83 ec 04             	sub    $0x4,%esp
  801a2e:	68 35 3c 80 00       	push   $0x803c35
  801a33:	6a 32                	push   $0x32
  801a35:	68 8f 3b 80 00       	push   $0x803b8f
  801a3a:	e8 57 f0 ff ff       	call   800a96 <_panic>

00801a3f <fork_v0>:

envid_t
fork_v0(void)
{
  801a3f:	f3 0f 1e fb          	endbr32 
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	57                   	push   %edi
  801a47:	56                   	push   %esi
  801a48:	53                   	push   %ebx
  801a49:	83 ec 0c             	sub    $0xc,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801a4c:	b8 07 00 00 00       	mov    $0x7,%eax
  801a51:	cd 30                	int    $0x30
	envid_t env_id = sys_exofork();
	if (env_id < 0) {
  801a53:	85 c0                	test   %eax,%eax
  801a55:	78 24                	js     801a7b <fork_v0+0x3c>
  801a57:	89 c6                	mov    %eax,%esi
  801a59:	89 c7                	mov    %eax,%edi
		thisenv = envs + ENVX(sys_getenvid());
		return env_id;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801a5b:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (env_id == 0) {  // Son
  801a60:	75 51                	jne    801ab3 <fork_v0+0x74>
		thisenv = envs + ENVX(sys_getenvid());
  801a62:	e8 a9 fb ff ff       	call   801610 <sys_getenvid>
  801a67:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a6c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a6f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a74:	a3 24 54 80 00       	mov    %eax,0x805424
		return env_id;
  801a79:	eb 78                	jmp    801af3 <fork_v0+0xb4>
		panic("ERROR ON FORK_V0");
  801a7b:	83 ec 04             	sub    $0x4,%esp
  801a7e:	68 53 3c 80 00       	push   $0x803c53
  801a83:	6a 7b                	push   $0x7b
  801a85:	68 8f 3b 80 00       	push   $0x803b8f
  801a8a:	e8 07 f0 ff ff       	call   800a96 <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
				dup_or_share(env_id,
  801a8f:	b9 07 00 00 00       	mov    $0x7,%ecx
  801a94:	89 da                	mov    %ebx,%edx
  801a96:	89 f8                	mov    %edi,%eax
  801a98:	e8 d0 fd ff ff       	call   80186d <dup_or_share>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801a9d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801aa3:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801aa9:	77 36                	ja     801ae1 <fork_v0+0xa2>
		if (addr != UXSTACKTOP - PGSIZE) {
  801aab:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801ab1:	74 ea                	je     801a9d <fork_v0+0x5e>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801ab3:	89 d8                	mov    %ebx,%eax
  801ab5:	c1 e8 16             	shr    $0x16,%eax
  801ab8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801abf:	a8 01                	test   $0x1,%al
  801ac1:	74 da                	je     801a9d <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  801ac3:	89 d8                	mov    %ebx,%eax
  801ac5:	c1 e8 0c             	shr    $0xc,%eax
  801ac8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801acf:	f6 c2 01             	test   $0x1,%dl
  801ad2:	74 c9                	je     801a9d <fork_v0+0x5e>
			    ((uvpt[PGNUM(addr)] & (PTE_U)) != 0)) {
  801ad4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
			    ((uvpt[PGNUM(addr)] & (PTE_P)) != 0) &&
  801adb:	a8 04                	test   $0x4,%al
  801add:	74 be                	je     801a9d <fork_v0+0x5e>
  801adf:	eb ae                	jmp    801a8f <fork_v0+0x50>
				             PTE_P | PTE_U | PTE_W);
			}
		}
	}

	if (sys_env_set_status(env_id, ENV_RUNNABLE) < 0) {
  801ae1:	83 ec 08             	sub    $0x8,%esp
  801ae4:	6a 02                	push   $0x2
  801ae6:	56                   	push   %esi
  801ae7:	e8 f0 fb ff ff       	call   8016dc <sys_env_set_status>
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	85 c0                	test   %eax,%eax
  801af1:	78 0a                	js     801afd <fork_v0+0xbe>
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
	}

	return env_id;
}
  801af3:	89 f0                	mov    %esi,%eax
  801af5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af8:	5b                   	pop    %ebx
  801af9:	5e                   	pop    %esi
  801afa:	5f                   	pop    %edi
  801afb:	5d                   	pop    %ebp
  801afc:	c3                   	ret    
		panic("ERROR ON FORK_V0 -> SYS ENV SET STATUS");
  801afd:	83 ec 04             	sub    $0x4,%esp
  801b00:	68 20 3b 80 00       	push   $0x803b20
  801b05:	68 92 00 00 00       	push   $0x92
  801b0a:	68 8f 3b 80 00       	push   $0x803b8f
  801b0f:	e8 82 ef ff ff       	call   800a96 <_panic>

00801b14 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801b14:	f3 0f 1e fb          	endbr32 
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	57                   	push   %edi
  801b1c:	56                   	push   %esi
  801b1d:	53                   	push   %ebx
  801b1e:	83 ec 18             	sub    $0x18,%esp
	// return fork_v0(); // Uncomment this line if you want to run fork_v0.
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801b21:	68 40 19 80 00       	push   $0x801940
  801b26:	e8 f4 15 00 00       	call   80311f <set_pgfault_handler>
  801b2b:	b8 07 00 00 00       	mov    $0x7,%eax
  801b30:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0) {
  801b32:	83 c4 10             	add    $0x10,%esp
  801b35:	85 c0                	test   %eax,%eax
  801b37:	78 27                	js     801b60 <fork+0x4c>
  801b39:	89 c7                	mov    %eax,%edi
  801b3b:	89 c6                	mov    %eax,%esi
		thisenv = envs + ENVX(sys_getenvid());
		return envid;
	}

	// Father
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801b3d:	bb 00 00 00 00       	mov    $0x0,%ebx
	} else if (envid == 0) {  // Son
  801b42:	75 55                	jne    801b99 <fork+0x85>
		thisenv = envs + ENVX(sys_getenvid());
  801b44:	e8 c7 fa ff ff       	call   801610 <sys_getenvid>
  801b49:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b4e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b51:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b56:	a3 24 54 80 00       	mov    %eax,0x805424
		return envid;
  801b5b:	e9 9b 00 00 00       	jmp    801bfb <fork+0xe7>
		panic("ERROR IN FORK: SYS_EXOFORK");
  801b60:	83 ec 04             	sub    $0x4,%esp
  801b63:	68 64 3c 80 00       	push   $0x803c64
  801b68:	68 b1 00 00 00       	push   $0xb1
  801b6d:	68 8f 3b 80 00       	push   $0x803b8f
  801b72:	e8 1f ef ff ff       	call   800a96 <_panic>
		if (addr != UXSTACKTOP - PGSIZE) {
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
				duppage(envid, addr / PGSIZE);
  801b77:	89 da                	mov    %ebx,%edx
  801b79:	c1 ea 0c             	shr    $0xc,%edx
  801b7c:	89 f0                	mov    %esi,%eax
  801b7e:	e8 1d fc ff ff       	call   8017a0 <duppage>
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  801b83:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801b89:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801b8f:	77 2c                	ja     801bbd <fork+0xa9>
		if (addr != UXSTACKTOP - PGSIZE) {
  801b91:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801b97:	74 ea                	je     801b83 <fork+0x6f>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801b99:	89 d8                	mov    %ebx,%eax
  801b9b:	c1 e8 16             	shr    $0x16,%eax
  801b9e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ba5:	a8 01                	test   $0x1,%al
  801ba7:	74 da                	je     801b83 <fork+0x6f>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U)) == 0)) {
  801ba9:	89 d8                	mov    %ebx,%eax
  801bab:	c1 e8 0c             	shr    $0xc,%eax
  801bae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bb5:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  801bb7:	a8 05                	test   $0x5,%al
  801bb9:	75 c8                	jne    801b83 <fork+0x6f>
  801bbb:	eb ba                	jmp    801b77 <fork+0x63>
			}
		}
	}

	if (sys_page_alloc(envid,
  801bbd:	83 ec 04             	sub    $0x4,%esp
  801bc0:	6a 07                	push   $0x7
  801bc2:	68 00 f0 bf ee       	push   $0xeebff000
  801bc7:	57                   	push   %edi
  801bc8:	e8 96 fa ff ff       	call   801663 <sys_page_alloc>
  801bcd:	83 c4 10             	add    $0x10,%esp
  801bd0:	85 c0                	test   %eax,%eax
  801bd2:	78 31                	js     801c05 <fork+0xf1>
	                   PTE_P | PTE_U | PTE_W) < 0) {
		panic("ERROR FORK: SYS_PAGE_ALLOC");
	}

	extern void _pgfault_upcall(void);
	if (sys_env_set_pgfault_upcall(envid, _pgfault_upcall) < 0) {
  801bd4:	83 ec 08             	sub    $0x8,%esp
  801bd7:	68 92 31 80 00       	push   $0x803192
  801bdc:	57                   	push   %edi
  801bdd:	e8 48 fb ff ff       	call   80172a <sys_env_set_pgfault_upcall>
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	85 c0                	test   %eax,%eax
  801be7:	78 33                	js     801c1c <fork+0x108>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
	}

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0) {
  801be9:	83 ec 08             	sub    $0x8,%esp
  801bec:	6a 02                	push   $0x2
  801bee:	57                   	push   %edi
  801bef:	e8 e8 fa ff ff       	call   8016dc <sys_env_set_status>
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	78 38                	js     801c33 <fork+0x11f>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
	}

	return envid;
}
  801bfb:	89 f8                	mov    %edi,%eax
  801bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c00:	5b                   	pop    %ebx
  801c01:	5e                   	pop    %esi
  801c02:	5f                   	pop    %edi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    
		panic("ERROR FORK: SYS_PAGE_ALLOC");
  801c05:	83 ec 04             	sub    $0x4,%esp
  801c08:	68 7f 3c 80 00       	push   $0x803c7f
  801c0d:	68 c4 00 00 00       	push   $0xc4
  801c12:	68 8f 3b 80 00       	push   $0x803b8f
  801c17:	e8 7a ee ff ff       	call   800a96 <_panic>
		panic("ERROR FORK: SYS_ENV_SET_PGFAULT_UPCALL");
  801c1c:	83 ec 04             	sub    $0x4,%esp
  801c1f:	68 48 3b 80 00       	push   $0x803b48
  801c24:	68 c9 00 00 00       	push   $0xc9
  801c29:	68 8f 3b 80 00       	push   $0x803b8f
  801c2e:	e8 63 ee ff ff       	call   800a96 <_panic>
		panic("ERROR FORK: SYS_ENV_SET_STATUS");
  801c33:	83 ec 04             	sub    $0x4,%esp
  801c36:	68 70 3b 80 00       	push   $0x803b70
  801c3b:	68 cd 00 00 00       	push   $0xcd
  801c40:	68 8f 3b 80 00       	push   $0x803b8f
  801c45:	e8 4c ee ff ff       	call   800a96 <_panic>

00801c4a <sfork>:

// Challenge!
int
sfork(void)
{
  801c4a:	f3 0f 1e fb          	endbr32 
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801c54:	68 9a 3c 80 00       	push   $0x803c9a
  801c59:	68 d7 00 00 00       	push   $0xd7
  801c5e:	68 8f 3b 80 00       	push   $0x803b8f
  801c63:	e8 2e ee ff ff       	call   800a96 <_panic>

00801c68 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801c68:	f3 0f 1e fb          	endbr32 
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	8b 55 08             	mov    0x8(%ebp),%edx
  801c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c75:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801c78:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801c7a:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801c7d:	83 3a 01             	cmpl   $0x1,(%edx)
  801c80:	7e 09                	jle    801c8b <argstart+0x23>
  801c82:	ba 81 35 80 00       	mov    $0x803581,%edx
  801c87:	85 c9                	test   %ecx,%ecx
  801c89:	75 05                	jne    801c90 <argstart+0x28>
  801c8b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c90:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801c93:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801c9a:	5d                   	pop    %ebp
  801c9b:	c3                   	ret    

00801c9c <argnext>:

int
argnext(struct Argstate *args)
{
  801c9c:	f3 0f 1e fb          	endbr32 
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	53                   	push   %ebx
  801ca4:	83 ec 04             	sub    $0x4,%esp
  801ca7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801caa:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801cb1:	8b 43 08             	mov    0x8(%ebx),%eax
  801cb4:	85 c0                	test   %eax,%eax
  801cb6:	74 74                	je     801d2c <argnext+0x90>
		return -1;

	if (!*args->curarg) {
  801cb8:	80 38 00             	cmpb   $0x0,(%eax)
  801cbb:	75 48                	jne    801d05 <argnext+0x69>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801cbd:	8b 0b                	mov    (%ebx),%ecx
  801cbf:	83 39 01             	cmpl   $0x1,(%ecx)
  801cc2:	74 5a                	je     801d1e <argnext+0x82>
		    || args->argv[1][0] != '-'
  801cc4:	8b 53 04             	mov    0x4(%ebx),%edx
  801cc7:	8b 42 04             	mov    0x4(%edx),%eax
  801cca:	80 38 2d             	cmpb   $0x2d,(%eax)
  801ccd:	75 4f                	jne    801d1e <argnext+0x82>
		    || args->argv[1][1] == '\0')
  801ccf:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801cd3:	74 49                	je     801d1e <argnext+0x82>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801cd5:	83 c0 01             	add    $0x1,%eax
  801cd8:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801cdb:	83 ec 04             	sub    $0x4,%esp
  801cde:	8b 01                	mov    (%ecx),%eax
  801ce0:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801ce7:	50                   	push   %eax
  801ce8:	8d 42 08             	lea    0x8(%edx),%eax
  801ceb:	50                   	push   %eax
  801cec:	83 c2 04             	add    $0x4,%edx
  801cef:	52                   	push   %edx
  801cf0:	e8 9e f6 ff ff       	call   801393 <memmove>
		(*args->argc)--;
  801cf5:	8b 03                	mov    (%ebx),%eax
  801cf7:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801cfa:	8b 43 08             	mov    0x8(%ebx),%eax
  801cfd:	83 c4 10             	add    $0x10,%esp
  801d00:	80 38 2d             	cmpb   $0x2d,(%eax)
  801d03:	74 13                	je     801d18 <argnext+0x7c>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801d05:	8b 43 08             	mov    0x8(%ebx),%eax
  801d08:	0f b6 10             	movzbl (%eax),%edx
	args->curarg++;
  801d0b:	83 c0 01             	add    $0x1,%eax
  801d0e:	89 43 08             	mov    %eax,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801d11:	89 d0                	mov    %edx,%eax
  801d13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d16:	c9                   	leave  
  801d17:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801d18:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801d1c:	75 e7                	jne    801d05 <argnext+0x69>
	args->curarg = 0;
  801d1e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801d25:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801d2a:	eb e5                	jmp    801d11 <argnext+0x75>
		return -1;
  801d2c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801d31:	eb de                	jmp    801d11 <argnext+0x75>

00801d33 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801d33:	f3 0f 1e fb          	endbr32 
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	53                   	push   %ebx
  801d3b:	83 ec 04             	sub    $0x4,%esp
  801d3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801d41:	8b 43 08             	mov    0x8(%ebx),%eax
  801d44:	85 c0                	test   %eax,%eax
  801d46:	74 12                	je     801d5a <argnextvalue+0x27>
		return 0;
	if (*args->curarg) {
  801d48:	80 38 00             	cmpb   $0x0,(%eax)
  801d4b:	74 12                	je     801d5f <argnextvalue+0x2c>
		args->argvalue = args->curarg;
  801d4d:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801d50:	c7 43 08 81 35 80 00 	movl   $0x803581,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  801d57:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  801d5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d5d:	c9                   	leave  
  801d5e:	c3                   	ret    
	} else if (*args->argc > 1) {
  801d5f:	8b 13                	mov    (%ebx),%edx
  801d61:	83 3a 01             	cmpl   $0x1,(%edx)
  801d64:	7f 10                	jg     801d76 <argnextvalue+0x43>
		args->argvalue = 0;
  801d66:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801d6d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  801d74:	eb e1                	jmp    801d57 <argnextvalue+0x24>
		args->argvalue = args->argv[1];
  801d76:	8b 43 04             	mov    0x4(%ebx),%eax
  801d79:	8b 48 04             	mov    0x4(%eax),%ecx
  801d7c:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801d7f:	83 ec 04             	sub    $0x4,%esp
  801d82:	8b 12                	mov    (%edx),%edx
  801d84:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801d8b:	52                   	push   %edx
  801d8c:	8d 50 08             	lea    0x8(%eax),%edx
  801d8f:	52                   	push   %edx
  801d90:	83 c0 04             	add    $0x4,%eax
  801d93:	50                   	push   %eax
  801d94:	e8 fa f5 ff ff       	call   801393 <memmove>
		(*args->argc)--;
  801d99:	8b 03                	mov    (%ebx),%eax
  801d9b:	83 28 01             	subl   $0x1,(%eax)
  801d9e:	83 c4 10             	add    $0x10,%esp
  801da1:	eb b4                	jmp    801d57 <argnextvalue+0x24>

00801da3 <argvalue>:
{
  801da3:	f3 0f 1e fb          	endbr32 
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	83 ec 08             	sub    $0x8,%esp
  801dad:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801db0:	8b 42 0c             	mov    0xc(%edx),%eax
  801db3:	85 c0                	test   %eax,%eax
  801db5:	74 02                	je     801db9 <argvalue+0x16>
}
  801db7:	c9                   	leave  
  801db8:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801db9:	83 ec 0c             	sub    $0xc,%esp
  801dbc:	52                   	push   %edx
  801dbd:	e8 71 ff ff ff       	call   801d33 <argnextvalue>
  801dc2:	83 c4 10             	add    $0x10,%esp
  801dc5:	eb f0                	jmp    801db7 <argvalue+0x14>

00801dc7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801dc7:	f3 0f 1e fb          	endbr32 
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801dce:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd1:	05 00 00 00 30       	add    $0x30000000,%eax
  801dd6:	c1 e8 0c             	shr    $0xc,%eax
}
  801dd9:	5d                   	pop    %ebp
  801dda:	c3                   	ret    

00801ddb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801ddb:	f3 0f 1e fb          	endbr32 
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  801de5:	ff 75 08             	pushl  0x8(%ebp)
  801de8:	e8 da ff ff ff       	call   801dc7 <fd2num>
  801ded:	83 c4 10             	add    $0x10,%esp
  801df0:	c1 e0 0c             	shl    $0xc,%eax
  801df3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801df8:	c9                   	leave  
  801df9:	c3                   	ret    

00801dfa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801dfa:	f3 0f 1e fb          	endbr32 
  801dfe:	55                   	push   %ebp
  801dff:	89 e5                	mov    %esp,%ebp
  801e01:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801e06:	89 c2                	mov    %eax,%edx
  801e08:	c1 ea 16             	shr    $0x16,%edx
  801e0b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e12:	f6 c2 01             	test   $0x1,%dl
  801e15:	74 2d                	je     801e44 <fd_alloc+0x4a>
  801e17:	89 c2                	mov    %eax,%edx
  801e19:	c1 ea 0c             	shr    $0xc,%edx
  801e1c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e23:	f6 c2 01             	test   $0x1,%dl
  801e26:	74 1c                	je     801e44 <fd_alloc+0x4a>
  801e28:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801e2d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801e32:	75 d2                	jne    801e06 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801e34:	8b 45 08             	mov    0x8(%ebp),%eax
  801e37:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801e3d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801e42:	eb 0a                	jmp    801e4e <fd_alloc+0x54>
			*fd_store = fd;
  801e44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e47:	89 01                	mov    %eax,(%ecx)
			return 0;
  801e49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e4e:	5d                   	pop    %ebp
  801e4f:	c3                   	ret    

00801e50 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801e50:	f3 0f 1e fb          	endbr32 
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801e5a:	83 f8 1f             	cmp    $0x1f,%eax
  801e5d:	77 30                	ja     801e8f <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801e5f:	c1 e0 0c             	shl    $0xc,%eax
  801e62:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801e67:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801e6d:	f6 c2 01             	test   $0x1,%dl
  801e70:	74 24                	je     801e96 <fd_lookup+0x46>
  801e72:	89 c2                	mov    %eax,%edx
  801e74:	c1 ea 0c             	shr    $0xc,%edx
  801e77:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e7e:	f6 c2 01             	test   $0x1,%dl
  801e81:	74 1a                	je     801e9d <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801e83:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e86:	89 02                	mov    %eax,(%edx)
	return 0;
  801e88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    
		return -E_INVAL;
  801e8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e94:	eb f7                	jmp    801e8d <fd_lookup+0x3d>
		return -E_INVAL;
  801e96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e9b:	eb f0                	jmp    801e8d <fd_lookup+0x3d>
  801e9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ea2:	eb e9                	jmp    801e8d <fd_lookup+0x3d>

00801ea4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801ea4:	f3 0f 1e fb          	endbr32 
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	83 ec 08             	sub    $0x8,%esp
  801eae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eb1:	ba 2c 3d 80 00       	mov    $0x803d2c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801eb6:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801ebb:	39 08                	cmp    %ecx,(%eax)
  801ebd:	74 33                	je     801ef2 <dev_lookup+0x4e>
  801ebf:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801ec2:	8b 02                	mov    (%edx),%eax
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	75 f3                	jne    801ebb <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801ec8:	a1 24 54 80 00       	mov    0x805424,%eax
  801ecd:	8b 40 48             	mov    0x48(%eax),%eax
  801ed0:	83 ec 04             	sub    $0x4,%esp
  801ed3:	51                   	push   %ecx
  801ed4:	50                   	push   %eax
  801ed5:	68 b0 3c 80 00       	push   $0x803cb0
  801eda:	e8 9e ec ff ff       	call   800b7d <cprintf>
	*dev = 0;
  801edf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801ee8:	83 c4 10             	add    $0x10,%esp
  801eeb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801ef0:	c9                   	leave  
  801ef1:	c3                   	ret    
			*dev = devtab[i];
  801ef2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ef5:	89 01                	mov    %eax,(%ecx)
			return 0;
  801ef7:	b8 00 00 00 00       	mov    $0x0,%eax
  801efc:	eb f2                	jmp    801ef0 <dev_lookup+0x4c>

00801efe <fd_close>:
{
  801efe:	f3 0f 1e fb          	endbr32 
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	57                   	push   %edi
  801f06:	56                   	push   %esi
  801f07:	53                   	push   %ebx
  801f08:	83 ec 28             	sub    $0x28,%esp
  801f0b:	8b 75 08             	mov    0x8(%ebp),%esi
  801f0e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801f11:	56                   	push   %esi
  801f12:	e8 b0 fe ff ff       	call   801dc7 <fd2num>
  801f17:	83 c4 08             	add    $0x8,%esp
  801f1a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801f1d:	52                   	push   %edx
  801f1e:	50                   	push   %eax
  801f1f:	e8 2c ff ff ff       	call   801e50 <fd_lookup>
  801f24:	89 c3                	mov    %eax,%ebx
  801f26:	83 c4 10             	add    $0x10,%esp
  801f29:	85 c0                	test   %eax,%eax
  801f2b:	78 05                	js     801f32 <fd_close+0x34>
	    || fd != fd2)
  801f2d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801f30:	74 16                	je     801f48 <fd_close+0x4a>
		return (must_exist ? r : 0);
  801f32:	89 f8                	mov    %edi,%eax
  801f34:	84 c0                	test   %al,%al
  801f36:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3b:	0f 44 d8             	cmove  %eax,%ebx
}
  801f3e:	89 d8                	mov    %ebx,%eax
  801f40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f43:	5b                   	pop    %ebx
  801f44:	5e                   	pop    %esi
  801f45:	5f                   	pop    %edi
  801f46:	5d                   	pop    %ebp
  801f47:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801f48:	83 ec 08             	sub    $0x8,%esp
  801f4b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801f4e:	50                   	push   %eax
  801f4f:	ff 36                	pushl  (%esi)
  801f51:	e8 4e ff ff ff       	call   801ea4 <dev_lookup>
  801f56:	89 c3                	mov    %eax,%ebx
  801f58:	83 c4 10             	add    $0x10,%esp
  801f5b:	85 c0                	test   %eax,%eax
  801f5d:	78 1a                	js     801f79 <fd_close+0x7b>
		if (dev->dev_close)
  801f5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f62:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801f65:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801f6a:	85 c0                	test   %eax,%eax
  801f6c:	74 0b                	je     801f79 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801f6e:	83 ec 0c             	sub    $0xc,%esp
  801f71:	56                   	push   %esi
  801f72:	ff d0                	call   *%eax
  801f74:	89 c3                	mov    %eax,%ebx
  801f76:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801f79:	83 ec 08             	sub    $0x8,%esp
  801f7c:	56                   	push   %esi
  801f7d:	6a 00                	push   $0x0
  801f7f:	e8 31 f7 ff ff       	call   8016b5 <sys_page_unmap>
	return r;
  801f84:	83 c4 10             	add    $0x10,%esp
  801f87:	eb b5                	jmp    801f3e <fd_close+0x40>

00801f89 <close>:

int
close(int fdnum)
{
  801f89:	f3 0f 1e fb          	endbr32 
  801f8d:	55                   	push   %ebp
  801f8e:	89 e5                	mov    %esp,%ebp
  801f90:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f96:	50                   	push   %eax
  801f97:	ff 75 08             	pushl  0x8(%ebp)
  801f9a:	e8 b1 fe ff ff       	call   801e50 <fd_lookup>
  801f9f:	83 c4 10             	add    $0x10,%esp
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	79 02                	jns    801fa8 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801fa6:	c9                   	leave  
  801fa7:	c3                   	ret    
		return fd_close(fd, 1);
  801fa8:	83 ec 08             	sub    $0x8,%esp
  801fab:	6a 01                	push   $0x1
  801fad:	ff 75 f4             	pushl  -0xc(%ebp)
  801fb0:	e8 49 ff ff ff       	call   801efe <fd_close>
  801fb5:	83 c4 10             	add    $0x10,%esp
  801fb8:	eb ec                	jmp    801fa6 <close+0x1d>

00801fba <close_all>:

void
close_all(void)
{
  801fba:	f3 0f 1e fb          	endbr32 
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	53                   	push   %ebx
  801fc2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801fc5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801fca:	83 ec 0c             	sub    $0xc,%esp
  801fcd:	53                   	push   %ebx
  801fce:	e8 b6 ff ff ff       	call   801f89 <close>
	for (i = 0; i < MAXFD; i++)
  801fd3:	83 c3 01             	add    $0x1,%ebx
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	83 fb 20             	cmp    $0x20,%ebx
  801fdc:	75 ec                	jne    801fca <close_all+0x10>
}
  801fde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe1:	c9                   	leave  
  801fe2:	c3                   	ret    

00801fe3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801fe3:	f3 0f 1e fb          	endbr32 
  801fe7:	55                   	push   %ebp
  801fe8:	89 e5                	mov    %esp,%ebp
  801fea:	57                   	push   %edi
  801feb:	56                   	push   %esi
  801fec:	53                   	push   %ebx
  801fed:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801ff0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ff3:	50                   	push   %eax
  801ff4:	ff 75 08             	pushl  0x8(%ebp)
  801ff7:	e8 54 fe ff ff       	call   801e50 <fd_lookup>
  801ffc:	89 c3                	mov    %eax,%ebx
  801ffe:	83 c4 10             	add    $0x10,%esp
  802001:	85 c0                	test   %eax,%eax
  802003:	0f 88 81 00 00 00    	js     80208a <dup+0xa7>
		return r;
	close(newfdnum);
  802009:	83 ec 0c             	sub    $0xc,%esp
  80200c:	ff 75 0c             	pushl  0xc(%ebp)
  80200f:	e8 75 ff ff ff       	call   801f89 <close>

	newfd = INDEX2FD(newfdnum);
  802014:	8b 75 0c             	mov    0xc(%ebp),%esi
  802017:	c1 e6 0c             	shl    $0xc,%esi
  80201a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  802020:	83 c4 04             	add    $0x4,%esp
  802023:	ff 75 e4             	pushl  -0x1c(%ebp)
  802026:	e8 b0 fd ff ff       	call   801ddb <fd2data>
  80202b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80202d:	89 34 24             	mov    %esi,(%esp)
  802030:	e8 a6 fd ff ff       	call   801ddb <fd2data>
  802035:	83 c4 10             	add    $0x10,%esp
  802038:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80203a:	89 d8                	mov    %ebx,%eax
  80203c:	c1 e8 16             	shr    $0x16,%eax
  80203f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802046:	a8 01                	test   $0x1,%al
  802048:	74 11                	je     80205b <dup+0x78>
  80204a:	89 d8                	mov    %ebx,%eax
  80204c:	c1 e8 0c             	shr    $0xc,%eax
  80204f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802056:	f6 c2 01             	test   $0x1,%dl
  802059:	75 39                	jne    802094 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80205b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80205e:	89 d0                	mov    %edx,%eax
  802060:	c1 e8 0c             	shr    $0xc,%eax
  802063:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80206a:	83 ec 0c             	sub    $0xc,%esp
  80206d:	25 07 0e 00 00       	and    $0xe07,%eax
  802072:	50                   	push   %eax
  802073:	56                   	push   %esi
  802074:	6a 00                	push   $0x0
  802076:	52                   	push   %edx
  802077:	6a 00                	push   $0x0
  802079:	e8 0d f6 ff ff       	call   80168b <sys_page_map>
  80207e:	89 c3                	mov    %eax,%ebx
  802080:	83 c4 20             	add    $0x20,%esp
  802083:	85 c0                	test   %eax,%eax
  802085:	78 31                	js     8020b8 <dup+0xd5>
		goto err;

	return newfdnum;
  802087:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80208a:	89 d8                	mov    %ebx,%eax
  80208c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802094:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80209b:	83 ec 0c             	sub    $0xc,%esp
  80209e:	25 07 0e 00 00       	and    $0xe07,%eax
  8020a3:	50                   	push   %eax
  8020a4:	57                   	push   %edi
  8020a5:	6a 00                	push   $0x0
  8020a7:	53                   	push   %ebx
  8020a8:	6a 00                	push   $0x0
  8020aa:	e8 dc f5 ff ff       	call   80168b <sys_page_map>
  8020af:	89 c3                	mov    %eax,%ebx
  8020b1:	83 c4 20             	add    $0x20,%esp
  8020b4:	85 c0                	test   %eax,%eax
  8020b6:	79 a3                	jns    80205b <dup+0x78>
	sys_page_unmap(0, newfd);
  8020b8:	83 ec 08             	sub    $0x8,%esp
  8020bb:	56                   	push   %esi
  8020bc:	6a 00                	push   $0x0
  8020be:	e8 f2 f5 ff ff       	call   8016b5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8020c3:	83 c4 08             	add    $0x8,%esp
  8020c6:	57                   	push   %edi
  8020c7:	6a 00                	push   $0x0
  8020c9:	e8 e7 f5 ff ff       	call   8016b5 <sys_page_unmap>
	return r;
  8020ce:	83 c4 10             	add    $0x10,%esp
  8020d1:	eb b7                	jmp    80208a <dup+0xa7>

008020d3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8020d3:	f3 0f 1e fb          	endbr32 
  8020d7:	55                   	push   %ebp
  8020d8:	89 e5                	mov    %esp,%ebp
  8020da:	53                   	push   %ebx
  8020db:	83 ec 1c             	sub    $0x1c,%esp
  8020de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020e4:	50                   	push   %eax
  8020e5:	53                   	push   %ebx
  8020e6:	e8 65 fd ff ff       	call   801e50 <fd_lookup>
  8020eb:	83 c4 10             	add    $0x10,%esp
  8020ee:	85 c0                	test   %eax,%eax
  8020f0:	78 3f                	js     802131 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020f2:	83 ec 08             	sub    $0x8,%esp
  8020f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f8:	50                   	push   %eax
  8020f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020fc:	ff 30                	pushl  (%eax)
  8020fe:	e8 a1 fd ff ff       	call   801ea4 <dev_lookup>
  802103:	83 c4 10             	add    $0x10,%esp
  802106:	85 c0                	test   %eax,%eax
  802108:	78 27                	js     802131 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80210a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80210d:	8b 42 08             	mov    0x8(%edx),%eax
  802110:	83 e0 03             	and    $0x3,%eax
  802113:	83 f8 01             	cmp    $0x1,%eax
  802116:	74 1e                	je     802136 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  802118:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211b:	8b 40 08             	mov    0x8(%eax),%eax
  80211e:	85 c0                	test   %eax,%eax
  802120:	74 35                	je     802157 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802122:	83 ec 04             	sub    $0x4,%esp
  802125:	ff 75 10             	pushl  0x10(%ebp)
  802128:	ff 75 0c             	pushl  0xc(%ebp)
  80212b:	52                   	push   %edx
  80212c:	ff d0                	call   *%eax
  80212e:	83 c4 10             	add    $0x10,%esp
}
  802131:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802134:	c9                   	leave  
  802135:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802136:	a1 24 54 80 00       	mov    0x805424,%eax
  80213b:	8b 40 48             	mov    0x48(%eax),%eax
  80213e:	83 ec 04             	sub    $0x4,%esp
  802141:	53                   	push   %ebx
  802142:	50                   	push   %eax
  802143:	68 f1 3c 80 00       	push   $0x803cf1
  802148:	e8 30 ea ff ff       	call   800b7d <cprintf>
		return -E_INVAL;
  80214d:	83 c4 10             	add    $0x10,%esp
  802150:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802155:	eb da                	jmp    802131 <read+0x5e>
		return -E_NOT_SUPP;
  802157:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80215c:	eb d3                	jmp    802131 <read+0x5e>

0080215e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80215e:	f3 0f 1e fb          	endbr32 
  802162:	55                   	push   %ebp
  802163:	89 e5                	mov    %esp,%ebp
  802165:	57                   	push   %edi
  802166:	56                   	push   %esi
  802167:	53                   	push   %ebx
  802168:	83 ec 0c             	sub    $0xc,%esp
  80216b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80216e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802171:	bb 00 00 00 00       	mov    $0x0,%ebx
  802176:	eb 02                	jmp    80217a <readn+0x1c>
  802178:	01 c3                	add    %eax,%ebx
  80217a:	39 f3                	cmp    %esi,%ebx
  80217c:	73 21                	jae    80219f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80217e:	83 ec 04             	sub    $0x4,%esp
  802181:	89 f0                	mov    %esi,%eax
  802183:	29 d8                	sub    %ebx,%eax
  802185:	50                   	push   %eax
  802186:	89 d8                	mov    %ebx,%eax
  802188:	03 45 0c             	add    0xc(%ebp),%eax
  80218b:	50                   	push   %eax
  80218c:	57                   	push   %edi
  80218d:	e8 41 ff ff ff       	call   8020d3 <read>
		if (m < 0)
  802192:	83 c4 10             	add    $0x10,%esp
  802195:	85 c0                	test   %eax,%eax
  802197:	78 04                	js     80219d <readn+0x3f>
			return m;
		if (m == 0)
  802199:	75 dd                	jne    802178 <readn+0x1a>
  80219b:	eb 02                	jmp    80219f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80219d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80219f:	89 d8                	mov    %ebx,%eax
  8021a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021a4:	5b                   	pop    %ebx
  8021a5:	5e                   	pop    %esi
  8021a6:	5f                   	pop    %edi
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    

008021a9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8021a9:	f3 0f 1e fb          	endbr32 
  8021ad:	55                   	push   %ebp
  8021ae:	89 e5                	mov    %esp,%ebp
  8021b0:	53                   	push   %ebx
  8021b1:	83 ec 1c             	sub    $0x1c,%esp
  8021b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8021b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021ba:	50                   	push   %eax
  8021bb:	53                   	push   %ebx
  8021bc:	e8 8f fc ff ff       	call   801e50 <fd_lookup>
  8021c1:	83 c4 10             	add    $0x10,%esp
  8021c4:	85 c0                	test   %eax,%eax
  8021c6:	78 3a                	js     802202 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021c8:	83 ec 08             	sub    $0x8,%esp
  8021cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ce:	50                   	push   %eax
  8021cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021d2:	ff 30                	pushl  (%eax)
  8021d4:	e8 cb fc ff ff       	call   801ea4 <dev_lookup>
  8021d9:	83 c4 10             	add    $0x10,%esp
  8021dc:	85 c0                	test   %eax,%eax
  8021de:	78 22                	js     802202 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8021e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021e3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8021e7:	74 1e                	je     802207 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8021e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021ec:	8b 52 0c             	mov    0xc(%edx),%edx
  8021ef:	85 d2                	test   %edx,%edx
  8021f1:	74 35                	je     802228 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8021f3:	83 ec 04             	sub    $0x4,%esp
  8021f6:	ff 75 10             	pushl  0x10(%ebp)
  8021f9:	ff 75 0c             	pushl  0xc(%ebp)
  8021fc:	50                   	push   %eax
  8021fd:	ff d2                	call   *%edx
  8021ff:	83 c4 10             	add    $0x10,%esp
}
  802202:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802205:	c9                   	leave  
  802206:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802207:	a1 24 54 80 00       	mov    0x805424,%eax
  80220c:	8b 40 48             	mov    0x48(%eax),%eax
  80220f:	83 ec 04             	sub    $0x4,%esp
  802212:	53                   	push   %ebx
  802213:	50                   	push   %eax
  802214:	68 0d 3d 80 00       	push   $0x803d0d
  802219:	e8 5f e9 ff ff       	call   800b7d <cprintf>
		return -E_INVAL;
  80221e:	83 c4 10             	add    $0x10,%esp
  802221:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802226:	eb da                	jmp    802202 <write+0x59>
		return -E_NOT_SUPP;
  802228:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80222d:	eb d3                	jmp    802202 <write+0x59>

0080222f <seek>:

int
seek(int fdnum, off_t offset)
{
  80222f:	f3 0f 1e fb          	endbr32 
  802233:	55                   	push   %ebp
  802234:	89 e5                	mov    %esp,%ebp
  802236:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802239:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80223c:	50                   	push   %eax
  80223d:	ff 75 08             	pushl  0x8(%ebp)
  802240:	e8 0b fc ff ff       	call   801e50 <fd_lookup>
  802245:	83 c4 10             	add    $0x10,%esp
  802248:	85 c0                	test   %eax,%eax
  80224a:	78 0e                	js     80225a <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80224c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80224f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802252:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802255:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80225a:	c9                   	leave  
  80225b:	c3                   	ret    

0080225c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80225c:	f3 0f 1e fb          	endbr32 
  802260:	55                   	push   %ebp
  802261:	89 e5                	mov    %esp,%ebp
  802263:	53                   	push   %ebx
  802264:	83 ec 1c             	sub    $0x1c,%esp
  802267:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80226a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80226d:	50                   	push   %eax
  80226e:	53                   	push   %ebx
  80226f:	e8 dc fb ff ff       	call   801e50 <fd_lookup>
  802274:	83 c4 10             	add    $0x10,%esp
  802277:	85 c0                	test   %eax,%eax
  802279:	78 37                	js     8022b2 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80227b:	83 ec 08             	sub    $0x8,%esp
  80227e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802281:	50                   	push   %eax
  802282:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802285:	ff 30                	pushl  (%eax)
  802287:	e8 18 fc ff ff       	call   801ea4 <dev_lookup>
  80228c:	83 c4 10             	add    $0x10,%esp
  80228f:	85 c0                	test   %eax,%eax
  802291:	78 1f                	js     8022b2 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802293:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802296:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80229a:	74 1b                	je     8022b7 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80229c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80229f:	8b 52 18             	mov    0x18(%edx),%edx
  8022a2:	85 d2                	test   %edx,%edx
  8022a4:	74 32                	je     8022d8 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8022a6:	83 ec 08             	sub    $0x8,%esp
  8022a9:	ff 75 0c             	pushl  0xc(%ebp)
  8022ac:	50                   	push   %eax
  8022ad:	ff d2                	call   *%edx
  8022af:	83 c4 10             	add    $0x10,%esp
}
  8022b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022b5:	c9                   	leave  
  8022b6:	c3                   	ret    
			thisenv->env_id, fdnum);
  8022b7:	a1 24 54 80 00       	mov    0x805424,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8022bc:	8b 40 48             	mov    0x48(%eax),%eax
  8022bf:	83 ec 04             	sub    $0x4,%esp
  8022c2:	53                   	push   %ebx
  8022c3:	50                   	push   %eax
  8022c4:	68 d0 3c 80 00       	push   $0x803cd0
  8022c9:	e8 af e8 ff ff       	call   800b7d <cprintf>
		return -E_INVAL;
  8022ce:	83 c4 10             	add    $0x10,%esp
  8022d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8022d6:	eb da                	jmp    8022b2 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8022d8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8022dd:	eb d3                	jmp    8022b2 <ftruncate+0x56>

008022df <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8022df:	f3 0f 1e fb          	endbr32 
  8022e3:	55                   	push   %ebp
  8022e4:	89 e5                	mov    %esp,%ebp
  8022e6:	53                   	push   %ebx
  8022e7:	83 ec 1c             	sub    $0x1c,%esp
  8022ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8022ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022f0:	50                   	push   %eax
  8022f1:	ff 75 08             	pushl  0x8(%ebp)
  8022f4:	e8 57 fb ff ff       	call   801e50 <fd_lookup>
  8022f9:	83 c4 10             	add    $0x10,%esp
  8022fc:	85 c0                	test   %eax,%eax
  8022fe:	78 4b                	js     80234b <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802300:	83 ec 08             	sub    $0x8,%esp
  802303:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802306:	50                   	push   %eax
  802307:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80230a:	ff 30                	pushl  (%eax)
  80230c:	e8 93 fb ff ff       	call   801ea4 <dev_lookup>
  802311:	83 c4 10             	add    $0x10,%esp
  802314:	85 c0                	test   %eax,%eax
  802316:	78 33                	js     80234b <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  802318:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80231b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80231f:	74 2f                	je     802350 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802321:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802324:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80232b:	00 00 00 
	stat->st_isdir = 0;
  80232e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802335:	00 00 00 
	stat->st_dev = dev;
  802338:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80233e:	83 ec 08             	sub    $0x8,%esp
  802341:	53                   	push   %ebx
  802342:	ff 75 f0             	pushl  -0x10(%ebp)
  802345:	ff 50 14             	call   *0x14(%eax)
  802348:	83 c4 10             	add    $0x10,%esp
}
  80234b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80234e:	c9                   	leave  
  80234f:	c3                   	ret    
		return -E_NOT_SUPP;
  802350:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802355:	eb f4                	jmp    80234b <fstat+0x6c>

00802357 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802357:	f3 0f 1e fb          	endbr32 
  80235b:	55                   	push   %ebp
  80235c:	89 e5                	mov    %esp,%ebp
  80235e:	56                   	push   %esi
  80235f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802360:	83 ec 08             	sub    $0x8,%esp
  802363:	6a 00                	push   $0x0
  802365:	ff 75 08             	pushl  0x8(%ebp)
  802368:	e8 20 02 00 00       	call   80258d <open>
  80236d:	89 c3                	mov    %eax,%ebx
  80236f:	83 c4 10             	add    $0x10,%esp
  802372:	85 c0                	test   %eax,%eax
  802374:	78 1b                	js     802391 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  802376:	83 ec 08             	sub    $0x8,%esp
  802379:	ff 75 0c             	pushl  0xc(%ebp)
  80237c:	50                   	push   %eax
  80237d:	e8 5d ff ff ff       	call   8022df <fstat>
  802382:	89 c6                	mov    %eax,%esi
	close(fd);
  802384:	89 1c 24             	mov    %ebx,(%esp)
  802387:	e8 fd fb ff ff       	call   801f89 <close>
	return r;
  80238c:	83 c4 10             	add    $0x10,%esp
  80238f:	89 f3                	mov    %esi,%ebx
}
  802391:	89 d8                	mov    %ebx,%eax
  802393:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802396:	5b                   	pop    %ebx
  802397:	5e                   	pop    %esi
  802398:	5d                   	pop    %ebp
  802399:	c3                   	ret    

0080239a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80239a:	55                   	push   %ebp
  80239b:	89 e5                	mov    %esp,%ebp
  80239d:	56                   	push   %esi
  80239e:	53                   	push   %ebx
  80239f:	89 c6                	mov    %eax,%esi
  8023a1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8023a3:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  8023aa:	74 27                	je     8023d3 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8023ac:	6a 07                	push   $0x7
  8023ae:	68 00 60 80 00       	push   $0x806000
  8023b3:	56                   	push   %esi
  8023b4:	ff 35 20 54 80 00    	pushl  0x805420
  8023ba:	e8 66 0e 00 00       	call   803225 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8023bf:	83 c4 0c             	add    $0xc,%esp
  8023c2:	6a 00                	push   $0x0
  8023c4:	53                   	push   %ebx
  8023c5:	6a 00                	push   $0x0
  8023c7:	e8 ec 0d 00 00       	call   8031b8 <ipc_recv>
}
  8023cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023cf:	5b                   	pop    %ebx
  8023d0:	5e                   	pop    %esi
  8023d1:	5d                   	pop    %ebp
  8023d2:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8023d3:	83 ec 0c             	sub    $0xc,%esp
  8023d6:	6a 01                	push   $0x1
  8023d8:	e8 9b 0e 00 00       	call   803278 <ipc_find_env>
  8023dd:	a3 20 54 80 00       	mov    %eax,0x805420
  8023e2:	83 c4 10             	add    $0x10,%esp
  8023e5:	eb c5                	jmp    8023ac <fsipc+0x12>

008023e7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8023e7:	f3 0f 1e fb          	endbr32 
  8023eb:	55                   	push   %ebp
  8023ec:	89 e5                	mov    %esp,%ebp
  8023ee:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8023f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8023f7:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8023fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023ff:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802404:	ba 00 00 00 00       	mov    $0x0,%edx
  802409:	b8 02 00 00 00       	mov    $0x2,%eax
  80240e:	e8 87 ff ff ff       	call   80239a <fsipc>
}
  802413:	c9                   	leave  
  802414:	c3                   	ret    

00802415 <devfile_flush>:
{
  802415:	f3 0f 1e fb          	endbr32 
  802419:	55                   	push   %ebp
  80241a:	89 e5                	mov    %esp,%ebp
  80241c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80241f:	8b 45 08             	mov    0x8(%ebp),%eax
  802422:	8b 40 0c             	mov    0xc(%eax),%eax
  802425:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80242a:	ba 00 00 00 00       	mov    $0x0,%edx
  80242f:	b8 06 00 00 00       	mov    $0x6,%eax
  802434:	e8 61 ff ff ff       	call   80239a <fsipc>
}
  802439:	c9                   	leave  
  80243a:	c3                   	ret    

0080243b <devfile_stat>:
{
  80243b:	f3 0f 1e fb          	endbr32 
  80243f:	55                   	push   %ebp
  802440:	89 e5                	mov    %esp,%ebp
  802442:	53                   	push   %ebx
  802443:	83 ec 04             	sub    $0x4,%esp
  802446:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802449:	8b 45 08             	mov    0x8(%ebp),%eax
  80244c:	8b 40 0c             	mov    0xc(%eax),%eax
  80244f:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802454:	ba 00 00 00 00       	mov    $0x0,%edx
  802459:	b8 05 00 00 00       	mov    $0x5,%eax
  80245e:	e8 37 ff ff ff       	call   80239a <fsipc>
  802463:	85 c0                	test   %eax,%eax
  802465:	78 2c                	js     802493 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802467:	83 ec 08             	sub    $0x8,%esp
  80246a:	68 00 60 80 00       	push   $0x806000
  80246f:	53                   	push   %ebx
  802470:	e8 66 ed ff ff       	call   8011db <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802475:	a1 80 60 80 00       	mov    0x806080,%eax
  80247a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802480:	a1 84 60 80 00       	mov    0x806084,%eax
  802485:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80248b:	83 c4 10             	add    $0x10,%esp
  80248e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802493:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802496:	c9                   	leave  
  802497:	c3                   	ret    

00802498 <devfile_write>:
{
  802498:	f3 0f 1e fb          	endbr32 
  80249c:	55                   	push   %ebp
  80249d:	89 e5                	mov    %esp,%ebp
  80249f:	57                   	push   %edi
  8024a0:	56                   	push   %esi
  8024a1:	53                   	push   %ebx
  8024a2:	83 ec 0c             	sub    $0xc,%esp
  8024a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8024ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8024b1:	a3 00 60 80 00       	mov    %eax,0x806000
	int r = 0;
  8024b6:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8024bb:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  8024c0:	85 db                	test   %ebx,%ebx
  8024c2:	74 3b                	je     8024ff <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8024c4:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8024ca:	89 f8                	mov    %edi,%eax
  8024cc:	0f 46 c3             	cmovbe %ebx,%eax
  8024cf:	a3 04 60 80 00       	mov    %eax,0x806004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  8024d4:	83 ec 04             	sub    $0x4,%esp
  8024d7:	50                   	push   %eax
  8024d8:	56                   	push   %esi
  8024d9:	68 08 60 80 00       	push   $0x806008
  8024de:	e8 b0 ee ff ff       	call   801393 <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8024e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8024e8:	b8 04 00 00 00       	mov    $0x4,%eax
  8024ed:	e8 a8 fe ff ff       	call   80239a <fsipc>
  8024f2:	83 c4 10             	add    $0x10,%esp
  8024f5:	85 c0                	test   %eax,%eax
  8024f7:	78 06                	js     8024ff <devfile_write+0x67>
		buf_aux += r;
  8024f9:	01 c6                	add    %eax,%esi
		n -= r;
  8024fb:	29 c3                	sub    %eax,%ebx
  8024fd:	eb c1                	jmp    8024c0 <devfile_write+0x28>
}
  8024ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802502:	5b                   	pop    %ebx
  802503:	5e                   	pop    %esi
  802504:	5f                   	pop    %edi
  802505:	5d                   	pop    %ebp
  802506:	c3                   	ret    

00802507 <devfile_read>:
{
  802507:	f3 0f 1e fb          	endbr32 
  80250b:	55                   	push   %ebp
  80250c:	89 e5                	mov    %esp,%ebp
  80250e:	56                   	push   %esi
  80250f:	53                   	push   %ebx
  802510:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802513:	8b 45 08             	mov    0x8(%ebp),%eax
  802516:	8b 40 0c             	mov    0xc(%eax),%eax
  802519:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  80251e:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802524:	ba 00 00 00 00       	mov    $0x0,%edx
  802529:	b8 03 00 00 00       	mov    $0x3,%eax
  80252e:	e8 67 fe ff ff       	call   80239a <fsipc>
  802533:	89 c3                	mov    %eax,%ebx
  802535:	85 c0                	test   %eax,%eax
  802537:	78 1f                	js     802558 <devfile_read+0x51>
	assert(r <= n);
  802539:	39 f0                	cmp    %esi,%eax
  80253b:	77 24                	ja     802561 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80253d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802542:	7f 33                	jg     802577 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802544:	83 ec 04             	sub    $0x4,%esp
  802547:	50                   	push   %eax
  802548:	68 00 60 80 00       	push   $0x806000
  80254d:	ff 75 0c             	pushl  0xc(%ebp)
  802550:	e8 3e ee ff ff       	call   801393 <memmove>
	return r;
  802555:	83 c4 10             	add    $0x10,%esp
}
  802558:	89 d8                	mov    %ebx,%eax
  80255a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80255d:	5b                   	pop    %ebx
  80255e:	5e                   	pop    %esi
  80255f:	5d                   	pop    %ebp
  802560:	c3                   	ret    
	assert(r <= n);
  802561:	68 3c 3d 80 00       	push   $0x803d3c
  802566:	68 9a 36 80 00       	push   $0x80369a
  80256b:	6a 7c                	push   $0x7c
  80256d:	68 43 3d 80 00       	push   $0x803d43
  802572:	e8 1f e5 ff ff       	call   800a96 <_panic>
	assert(r <= PGSIZE);
  802577:	68 4e 3d 80 00       	push   $0x803d4e
  80257c:	68 9a 36 80 00       	push   $0x80369a
  802581:	6a 7d                	push   $0x7d
  802583:	68 43 3d 80 00       	push   $0x803d43
  802588:	e8 09 e5 ff ff       	call   800a96 <_panic>

0080258d <open>:
{
  80258d:	f3 0f 1e fb          	endbr32 
  802591:	55                   	push   %ebp
  802592:	89 e5                	mov    %esp,%ebp
  802594:	56                   	push   %esi
  802595:	53                   	push   %ebx
  802596:	83 ec 1c             	sub    $0x1c,%esp
  802599:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80259c:	56                   	push   %esi
  80259d:	e8 f6 eb ff ff       	call   801198 <strlen>
  8025a2:	83 c4 10             	add    $0x10,%esp
  8025a5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8025aa:	7f 6c                	jg     802618 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8025ac:	83 ec 0c             	sub    $0xc,%esp
  8025af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025b2:	50                   	push   %eax
  8025b3:	e8 42 f8 ff ff       	call   801dfa <fd_alloc>
  8025b8:	89 c3                	mov    %eax,%ebx
  8025ba:	83 c4 10             	add    $0x10,%esp
  8025bd:	85 c0                	test   %eax,%eax
  8025bf:	78 3c                	js     8025fd <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8025c1:	83 ec 08             	sub    $0x8,%esp
  8025c4:	56                   	push   %esi
  8025c5:	68 00 60 80 00       	push   $0x806000
  8025ca:	e8 0c ec ff ff       	call   8011db <strcpy>
	fsipcbuf.open.req_omode = mode;
  8025cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025d2:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8025d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8025da:	b8 01 00 00 00       	mov    $0x1,%eax
  8025df:	e8 b6 fd ff ff       	call   80239a <fsipc>
  8025e4:	89 c3                	mov    %eax,%ebx
  8025e6:	83 c4 10             	add    $0x10,%esp
  8025e9:	85 c0                	test   %eax,%eax
  8025eb:	78 19                	js     802606 <open+0x79>
	return fd2num(fd);
  8025ed:	83 ec 0c             	sub    $0xc,%esp
  8025f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8025f3:	e8 cf f7 ff ff       	call   801dc7 <fd2num>
  8025f8:	89 c3                	mov    %eax,%ebx
  8025fa:	83 c4 10             	add    $0x10,%esp
}
  8025fd:	89 d8                	mov    %ebx,%eax
  8025ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802602:	5b                   	pop    %ebx
  802603:	5e                   	pop    %esi
  802604:	5d                   	pop    %ebp
  802605:	c3                   	ret    
		fd_close(fd, 0);
  802606:	83 ec 08             	sub    $0x8,%esp
  802609:	6a 00                	push   $0x0
  80260b:	ff 75 f4             	pushl  -0xc(%ebp)
  80260e:	e8 eb f8 ff ff       	call   801efe <fd_close>
		return r;
  802613:	83 c4 10             	add    $0x10,%esp
  802616:	eb e5                	jmp    8025fd <open+0x70>
		return -E_BAD_PATH;
  802618:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80261d:	eb de                	jmp    8025fd <open+0x70>

0080261f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80261f:	f3 0f 1e fb          	endbr32 
  802623:	55                   	push   %ebp
  802624:	89 e5                	mov    %esp,%ebp
  802626:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802629:	ba 00 00 00 00       	mov    $0x0,%edx
  80262e:	b8 08 00 00 00       	mov    $0x8,%eax
  802633:	e8 62 fd ff ff       	call   80239a <fsipc>
}
  802638:	c9                   	leave  
  802639:	c3                   	ret    

0080263a <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80263a:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80263e:	7f 01                	jg     802641 <writebuf+0x7>
  802640:	c3                   	ret    
{
  802641:	55                   	push   %ebp
  802642:	89 e5                	mov    %esp,%ebp
  802644:	53                   	push   %ebx
  802645:	83 ec 08             	sub    $0x8,%esp
  802648:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  80264a:	ff 70 04             	pushl  0x4(%eax)
  80264d:	8d 40 10             	lea    0x10(%eax),%eax
  802650:	50                   	push   %eax
  802651:	ff 33                	pushl  (%ebx)
  802653:	e8 51 fb ff ff       	call   8021a9 <write>
		if (result > 0)
  802658:	83 c4 10             	add    $0x10,%esp
  80265b:	85 c0                	test   %eax,%eax
  80265d:	7e 03                	jle    802662 <writebuf+0x28>
			b->result += result;
  80265f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802662:	39 43 04             	cmp    %eax,0x4(%ebx)
  802665:	74 0d                	je     802674 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  802667:	85 c0                	test   %eax,%eax
  802669:	ba 00 00 00 00       	mov    $0x0,%edx
  80266e:	0f 4f c2             	cmovg  %edx,%eax
  802671:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  802674:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802677:	c9                   	leave  
  802678:	c3                   	ret    

00802679 <putch>:

static void
putch(int ch, void *thunk)
{
  802679:	f3 0f 1e fb          	endbr32 
  80267d:	55                   	push   %ebp
  80267e:	89 e5                	mov    %esp,%ebp
  802680:	53                   	push   %ebx
  802681:	83 ec 04             	sub    $0x4,%esp
  802684:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802687:	8b 53 04             	mov    0x4(%ebx),%edx
  80268a:	8d 42 01             	lea    0x1(%edx),%eax
  80268d:	89 43 04             	mov    %eax,0x4(%ebx)
  802690:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802693:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  802697:	3d 00 01 00 00       	cmp    $0x100,%eax
  80269c:	74 06                	je     8026a4 <putch+0x2b>
		writebuf(b);
		b->idx = 0;
	}
}
  80269e:	83 c4 04             	add    $0x4,%esp
  8026a1:	5b                   	pop    %ebx
  8026a2:	5d                   	pop    %ebp
  8026a3:	c3                   	ret    
		writebuf(b);
  8026a4:	89 d8                	mov    %ebx,%eax
  8026a6:	e8 8f ff ff ff       	call   80263a <writebuf>
		b->idx = 0;
  8026ab:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  8026b2:	eb ea                	jmp    80269e <putch+0x25>

008026b4 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8026b4:	f3 0f 1e fb          	endbr32 
  8026b8:	55                   	push   %ebp
  8026b9:	89 e5                	mov    %esp,%ebp
  8026bb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8026c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8026c4:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8026ca:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8026d1:	00 00 00 
	b.result = 0;
  8026d4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8026db:	00 00 00 
	b.error = 1;
  8026de:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8026e5:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8026e8:	ff 75 10             	pushl  0x10(%ebp)
  8026eb:	ff 75 0c             	pushl  0xc(%ebp)
  8026ee:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8026f4:	50                   	push   %eax
  8026f5:	68 79 26 80 00       	push   $0x802679
  8026fa:	e8 e1 e5 ff ff       	call   800ce0 <vprintfmt>
	if (b.idx > 0)
  8026ff:	83 c4 10             	add    $0x10,%esp
  802702:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802709:	7f 11                	jg     80271c <vfprintf+0x68>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  80270b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802711:	85 c0                	test   %eax,%eax
  802713:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80271a:	c9                   	leave  
  80271b:	c3                   	ret    
		writebuf(&b);
  80271c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802722:	e8 13 ff ff ff       	call   80263a <writebuf>
  802727:	eb e2                	jmp    80270b <vfprintf+0x57>

00802729 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802729:	f3 0f 1e fb          	endbr32 
  80272d:	55                   	push   %ebp
  80272e:	89 e5                	mov    %esp,%ebp
  802730:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802733:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802736:	50                   	push   %eax
  802737:	ff 75 0c             	pushl  0xc(%ebp)
  80273a:	ff 75 08             	pushl  0x8(%ebp)
  80273d:	e8 72 ff ff ff       	call   8026b4 <vfprintf>
	va_end(ap);

	return cnt;
}
  802742:	c9                   	leave  
  802743:	c3                   	ret    

00802744 <printf>:

int
printf(const char *fmt, ...)
{
  802744:	f3 0f 1e fb          	endbr32 
  802748:	55                   	push   %ebp
  802749:	89 e5                	mov    %esp,%ebp
  80274b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80274e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802751:	50                   	push   %eax
  802752:	ff 75 08             	pushl  0x8(%ebp)
  802755:	6a 01                	push   $0x1
  802757:	e8 58 ff ff ff       	call   8026b4 <vfprintf>
	va_end(ap);

	return cnt;
}
  80275c:	c9                   	leave  
  80275d:	c3                   	ret    

0080275e <copy_shared_pages>:
}

// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
  80275e:	55                   	push   %ebp
  80275f:	89 e5                	mov    %esp,%ebp
  802761:	56                   	push   %esi
  802762:	53                   	push   %ebx
  802763:	89 c6                	mov    %eax,%esi
	// LAB 5: Your code here.
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  802765:	bb 00 00 00 00       	mov    $0x0,%ebx
  80276a:	eb 33                	jmp    80279f <copy_shared_pages+0x41>
			     0)) {
				sys_page_map(0,
				             (void *) addr,
				             child,
				             (void *) addr,
				             (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  80276c:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
				sys_page_map(0,
  802773:	83 ec 0c             	sub    $0xc,%esp
  802776:	25 07 0e 00 00       	and    $0xe07,%eax
  80277b:	50                   	push   %eax
  80277c:	53                   	push   %ebx
  80277d:	56                   	push   %esi
  80277e:	53                   	push   %ebx
  80277f:	6a 00                	push   $0x0
  802781:	e8 05 ef ff ff       	call   80168b <sys_page_map>
  802786:	83 c4 20             	add    $0x20,%esp
	for (uint32_t addr = 0; addr < UTOP; addr += PGSIZE) {
  802789:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80278f:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  802795:	77 2f                	ja     8027c6 <copy_shared_pages+0x68>
		if (addr != UXSTACKTOP - PGSIZE) {
  802797:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80279d:	74 ea                	je     802789 <copy_shared_pages+0x2b>
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  80279f:	89 d8                	mov    %ebx,%eax
  8027a1:	c1 e8 16             	shr    $0x16,%eax
  8027a4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8027ab:	a8 01                	test   $0x1,%al
  8027ad:	74 da                	je     802789 <copy_shared_pages+0x2b>
			    ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U | PTE_SHARE)) ==
  8027af:	89 da                	mov    %ebx,%edx
  8027b1:	c1 ea 0c             	shr    $0xc,%edx
  8027b4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8027bb:	f7 d0                	not    %eax
			if (((uvpd[PDX(addr)] & PTE_P) != 0) &&
  8027bd:	a9 05 04 00 00       	test   $0x405,%eax
  8027c2:	75 c5                	jne    802789 <copy_shared_pages+0x2b>
  8027c4:	eb a6                	jmp    80276c <copy_shared_pages+0xe>
			}
		}
	}
	return 0;
}
  8027c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8027cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8027ce:	5b                   	pop    %ebx
  8027cf:	5e                   	pop    %esi
  8027d0:	5d                   	pop    %ebp
  8027d1:	c3                   	ret    

008027d2 <init_stack>:
{
  8027d2:	55                   	push   %ebp
  8027d3:	89 e5                	mov    %esp,%ebp
  8027d5:	57                   	push   %edi
  8027d6:	56                   	push   %esi
  8027d7:	53                   	push   %ebx
  8027d8:	83 ec 2c             	sub    $0x2c,%esp
  8027db:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8027de:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8027e1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (argc = 0; argv[argc] != 0; argc++)
  8027e4:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  8027e9:	be 00 00 00 00       	mov    $0x0,%esi
  8027ee:	89 d7                	mov    %edx,%edi
  8027f0:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
	for (argc = 0; argv[argc] != 0; argc++)
  8027f7:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8027fa:	85 c0                	test   %eax,%eax
  8027fc:	74 15                	je     802813 <init_stack+0x41>
		string_size += strlen(argv[argc]) + 1;
  8027fe:	83 ec 0c             	sub    $0xc,%esp
  802801:	50                   	push   %eax
  802802:	e8 91 e9 ff ff       	call   801198 <strlen>
  802807:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  80280b:	83 c3 01             	add    $0x1,%ebx
  80280e:	83 c4 10             	add    $0x10,%esp
  802811:	eb dd                	jmp    8027f0 <init_stack+0x1e>
  802813:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  802816:	89 4d d8             	mov    %ecx,-0x28(%ebp)
	string_store = (char *) UTEMP + PGSIZE - string_size;
  802819:	bf 00 10 40 00       	mov    $0x401000,%edi
  80281e:	29 f7                	sub    %esi,%edi
	argv_store = (uintptr_t *) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802820:	89 fa                	mov    %edi,%edx
  802822:	83 e2 fc             	and    $0xfffffffc,%edx
  802825:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80282c:	29 c2                	sub    %eax,%edx
  80282e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	if ((void *) (argv_store - 2) < (void *) UTEMP)
  802831:	8d 42 f8             	lea    -0x8(%edx),%eax
  802834:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802839:	0f 86 06 01 00 00    	jbe    802945 <init_stack+0x173>
	if ((r = sys_page_alloc(0, (void *) UTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  80283f:	83 ec 04             	sub    $0x4,%esp
  802842:	6a 07                	push   $0x7
  802844:	68 00 00 40 00       	push   $0x400000
  802849:	6a 00                	push   $0x0
  80284b:	e8 13 ee ff ff       	call   801663 <sys_page_alloc>
  802850:	89 c6                	mov    %eax,%esi
  802852:	83 c4 10             	add    $0x10,%esp
  802855:	85 c0                	test   %eax,%eax
  802857:	0f 88 de 00 00 00    	js     80293b <init_stack+0x169>
	for (i = 0; i < argc; i++) {
  80285d:	be 00 00 00 00       	mov    $0x0,%esi
  802862:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  802865:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  802868:	39 75 e0             	cmp    %esi,-0x20(%ebp)
  80286b:	7e 2f                	jle    80289c <init_stack+0xca>
		argv_store[i] = UTEMP2USTACK(string_store);
  80286d:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802873:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  802876:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  802879:	83 ec 08             	sub    $0x8,%esp
  80287c:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80287f:	57                   	push   %edi
  802880:	e8 56 e9 ff ff       	call   8011db <strcpy>
		string_store += strlen(argv[i]) + 1;
  802885:	83 c4 04             	add    $0x4,%esp
  802888:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80288b:	e8 08 e9 ff ff       	call   801198 <strlen>
  802890:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  802894:	83 c6 01             	add    $0x1,%esi
  802897:	83 c4 10             	add    $0x10,%esp
  80289a:	eb cc                	jmp    802868 <init_stack+0x96>
	argv_store[argc] = 0;
  80289c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80289f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8028a2:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char *) UTEMP + PGSIZE);
  8028a9:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8028af:	75 5f                	jne    802910 <init_stack+0x13e>
	argv_store[-1] = UTEMP2USTACK(argv_store);
  8028b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8028b4:	8d 82 00 d0 7f ee    	lea    -0x11803000(%edx),%eax
  8028ba:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8028bd:	89 d0                	mov    %edx,%eax
  8028bf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8028c2:	89 4a f8             	mov    %ecx,-0x8(%edx)
	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8028c5:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8028ca:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8028cd:	89 01                	mov    %eax,(%ecx)
	if ((r = sys_page_map(0,
  8028cf:	83 ec 0c             	sub    $0xc,%esp
  8028d2:	6a 07                	push   $0x7
  8028d4:	68 00 d0 bf ee       	push   $0xeebfd000
  8028d9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8028dc:	68 00 00 40 00       	push   $0x400000
  8028e1:	6a 00                	push   $0x0
  8028e3:	e8 a3 ed ff ff       	call   80168b <sys_page_map>
  8028e8:	89 c6                	mov    %eax,%esi
  8028ea:	83 c4 20             	add    $0x20,%esp
  8028ed:	85 c0                	test   %eax,%eax
  8028ef:	78 38                	js     802929 <init_stack+0x157>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8028f1:	83 ec 08             	sub    $0x8,%esp
  8028f4:	68 00 00 40 00       	push   $0x400000
  8028f9:	6a 00                	push   $0x0
  8028fb:	e8 b5 ed ff ff       	call   8016b5 <sys_page_unmap>
  802900:	89 c6                	mov    %eax,%esi
  802902:	83 c4 10             	add    $0x10,%esp
  802905:	85 c0                	test   %eax,%eax
  802907:	78 20                	js     802929 <init_stack+0x157>
	return 0;
  802909:	be 00 00 00 00       	mov    $0x0,%esi
  80290e:	eb 2b                	jmp    80293b <init_stack+0x169>
	assert(string_store == (char *) UTEMP + PGSIZE);
  802910:	68 5c 3d 80 00       	push   $0x803d5c
  802915:	68 9a 36 80 00       	push   $0x80369a
  80291a:	68 fc 00 00 00       	push   $0xfc
  80291f:	68 84 3d 80 00       	push   $0x803d84
  802924:	e8 6d e1 ff ff       	call   800a96 <_panic>
	sys_page_unmap(0, UTEMP);
  802929:	83 ec 08             	sub    $0x8,%esp
  80292c:	68 00 00 40 00       	push   $0x400000
  802931:	6a 00                	push   $0x0
  802933:	e8 7d ed ff ff       	call   8016b5 <sys_page_unmap>
	return r;
  802938:	83 c4 10             	add    $0x10,%esp
}
  80293b:	89 f0                	mov    %esi,%eax
  80293d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802940:	5b                   	pop    %ebx
  802941:	5e                   	pop    %esi
  802942:	5f                   	pop    %edi
  802943:	5d                   	pop    %ebp
  802944:	c3                   	ret    
		return -E_NO_MEM;
  802945:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  80294a:	eb ef                	jmp    80293b <init_stack+0x169>

0080294c <map_segment>:
{
  80294c:	55                   	push   %ebp
  80294d:	89 e5                	mov    %esp,%ebp
  80294f:	57                   	push   %edi
  802950:	56                   	push   %esi
  802951:	53                   	push   %ebx
  802952:	83 ec 1c             	sub    $0x1c,%esp
  802955:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802958:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80295b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80295e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((i = PGOFF(va))) {
  802961:	89 d0                	mov    %edx,%eax
  802963:	25 ff 0f 00 00       	and    $0xfff,%eax
  802968:	74 0f                	je     802979 <map_segment+0x2d>
		va -= i;
  80296a:	29 c2                	sub    %eax,%edx
  80296c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		memsz += i;
  80296f:	01 c1                	add    %eax,%ecx
  802971:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		filesz += i;
  802974:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  802976:	29 45 10             	sub    %eax,0x10(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  802979:	bb 00 00 00 00       	mov    $0x0,%ebx
  80297e:	e9 99 00 00 00       	jmp    802a1c <map_segment+0xd0>
			if ((r = sys_page_alloc(0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  802983:	83 ec 04             	sub    $0x4,%esp
  802986:	6a 07                	push   $0x7
  802988:	68 00 00 40 00       	push   $0x400000
  80298d:	6a 00                	push   $0x0
  80298f:	e8 cf ec ff ff       	call   801663 <sys_page_alloc>
  802994:	83 c4 10             	add    $0x10,%esp
  802997:	85 c0                	test   %eax,%eax
  802999:	0f 88 c1 00 00 00    	js     802a60 <map_segment+0x114>
			if ((r = seek(fd, fileoffset + i)) < 0)
  80299f:	83 ec 08             	sub    $0x8,%esp
  8029a2:	89 f0                	mov    %esi,%eax
  8029a4:	03 45 10             	add    0x10(%ebp),%eax
  8029a7:	50                   	push   %eax
  8029a8:	ff 75 08             	pushl  0x8(%ebp)
  8029ab:	e8 7f f8 ff ff       	call   80222f <seek>
  8029b0:	83 c4 10             	add    $0x10,%esp
  8029b3:	85 c0                	test   %eax,%eax
  8029b5:	0f 88 a5 00 00 00    	js     802a60 <map_segment+0x114>
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz - i))) < 0)
  8029bb:	83 ec 04             	sub    $0x4,%esp
  8029be:	89 f8                	mov    %edi,%eax
  8029c0:	29 f0                	sub    %esi,%eax
  8029c2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8029c7:	ba 00 10 00 00       	mov    $0x1000,%edx
  8029cc:	0f 47 c2             	cmova  %edx,%eax
  8029cf:	50                   	push   %eax
  8029d0:	68 00 00 40 00       	push   $0x400000
  8029d5:	ff 75 08             	pushl  0x8(%ebp)
  8029d8:	e8 81 f7 ff ff       	call   80215e <readn>
  8029dd:	83 c4 10             	add    $0x10,%esp
  8029e0:	85 c0                	test   %eax,%eax
  8029e2:	78 7c                	js     802a60 <map_segment+0x114>
			if ((r = sys_page_map(
  8029e4:	83 ec 0c             	sub    $0xc,%esp
  8029e7:	ff 75 14             	pushl  0x14(%ebp)
  8029ea:	03 75 e0             	add    -0x20(%ebp),%esi
  8029ed:	56                   	push   %esi
  8029ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8029f1:	68 00 00 40 00       	push   $0x400000
  8029f6:	6a 00                	push   $0x0
  8029f8:	e8 8e ec ff ff       	call   80168b <sys_page_map>
  8029fd:	83 c4 20             	add    $0x20,%esp
  802a00:	85 c0                	test   %eax,%eax
  802a02:	78 42                	js     802a46 <map_segment+0xfa>
			sys_page_unmap(0, UTEMP);
  802a04:	83 ec 08             	sub    $0x8,%esp
  802a07:	68 00 00 40 00       	push   $0x400000
  802a0c:	6a 00                	push   $0x0
  802a0e:	e8 a2 ec ff ff       	call   8016b5 <sys_page_unmap>
  802a13:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  802a16:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802a1c:	89 de                	mov    %ebx,%esi
  802a1e:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  802a21:	76 38                	jbe    802a5b <map_segment+0x10f>
		if (i >= filesz) {
  802a23:	39 df                	cmp    %ebx,%edi
  802a25:	0f 87 58 ff ff ff    	ja     802983 <map_segment+0x37>
			if ((r = sys_page_alloc(child, (void *) (va + i), perm)) < 0)
  802a2b:	83 ec 04             	sub    $0x4,%esp
  802a2e:	ff 75 14             	pushl  0x14(%ebp)
  802a31:	03 75 e0             	add    -0x20(%ebp),%esi
  802a34:	56                   	push   %esi
  802a35:	ff 75 dc             	pushl  -0x24(%ebp)
  802a38:	e8 26 ec ff ff       	call   801663 <sys_page_alloc>
  802a3d:	83 c4 10             	add    $0x10,%esp
  802a40:	85 c0                	test   %eax,%eax
  802a42:	79 d2                	jns    802a16 <map_segment+0xca>
  802a44:	eb 1a                	jmp    802a60 <map_segment+0x114>
				panic("spawn: sys_page_map data: %e", r);
  802a46:	50                   	push   %eax
  802a47:	68 90 3d 80 00       	push   $0x803d90
  802a4c:	68 3a 01 00 00       	push   $0x13a
  802a51:	68 84 3d 80 00       	push   $0x803d84
  802a56:	e8 3b e0 ff ff       	call   800a96 <_panic>
	return 0;
  802a5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802a60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a63:	5b                   	pop    %ebx
  802a64:	5e                   	pop    %esi
  802a65:	5f                   	pop    %edi
  802a66:	5d                   	pop    %ebp
  802a67:	c3                   	ret    

00802a68 <spawn>:
{
  802a68:	f3 0f 1e fb          	endbr32 
  802a6c:	55                   	push   %ebp
  802a6d:	89 e5                	mov    %esp,%ebp
  802a6f:	57                   	push   %edi
  802a70:	56                   	push   %esi
  802a71:	53                   	push   %ebx
  802a72:	81 ec 74 02 00 00    	sub    $0x274,%esp
	if ((r = open(prog, O_RDONLY)) < 0)
  802a78:	6a 00                	push   $0x0
  802a7a:	ff 75 08             	pushl  0x8(%ebp)
  802a7d:	e8 0b fb ff ff       	call   80258d <open>
  802a82:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802a88:	83 c4 10             	add    $0x10,%esp
  802a8b:	85 c0                	test   %eax,%eax
  802a8d:	0f 88 0b 02 00 00    	js     802c9e <spawn+0x236>
  802a93:	89 c7                	mov    %eax,%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf) ||
  802a95:	83 ec 04             	sub    $0x4,%esp
  802a98:	68 00 02 00 00       	push   $0x200
  802a9d:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802aa3:	50                   	push   %eax
  802aa4:	57                   	push   %edi
  802aa5:	e8 b4 f6 ff ff       	call   80215e <readn>
  802aaa:	83 c4 10             	add    $0x10,%esp
  802aad:	3d 00 02 00 00       	cmp    $0x200,%eax
  802ab2:	0f 85 85 00 00 00    	jne    802b3d <spawn+0xd5>
  802ab8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802abf:	45 4c 46 
  802ac2:	75 79                	jne    802b3d <spawn+0xd5>
  802ac4:	b8 07 00 00 00       	mov    $0x7,%eax
  802ac9:	cd 30                	int    $0x30
  802acb:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802ad1:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	if ((r = sys_exofork()) < 0)
  802ad7:	89 c3                	mov    %eax,%ebx
  802ad9:	85 c0                	test   %eax,%eax
  802adb:	0f 88 b1 01 00 00    	js     802c92 <spawn+0x22a>
	child_tf = envs[ENVX(child)].env_tf;
  802ae1:	89 c6                	mov    %eax,%esi
  802ae3:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802ae9:	6b f6 7c             	imul   $0x7c,%esi,%esi
  802aec:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  802af2:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802af8:	b9 11 00 00 00       	mov    $0x11,%ecx
  802afd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802aff:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802b05:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
  802b0b:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  802b11:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b14:	89 d8                	mov    %ebx,%eax
  802b16:	e8 b7 fc ff ff       	call   8027d2 <init_stack>
  802b1b:	85 c0                	test   %eax,%eax
  802b1d:	0f 88 89 01 00 00    	js     802cac <spawn+0x244>
	ph = (struct Proghdr *) (elf_buf + elf->e_phoff);
  802b23:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802b29:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802b30:	be 00 00 00 00       	mov    $0x0,%esi
  802b35:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  802b3b:	eb 3e                	jmp    802b7b <spawn+0x113>
		close(fd);
  802b3d:	83 ec 0c             	sub    $0xc,%esp
  802b40:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  802b46:	e8 3e f4 ff ff       	call   801f89 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802b4b:	83 c4 0c             	add    $0xc,%esp
  802b4e:	68 7f 45 4c 46       	push   $0x464c457f
  802b53:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  802b59:	68 ad 3d 80 00       	push   $0x803dad
  802b5e:	e8 1a e0 ff ff       	call   800b7d <cprintf>
		return -E_NOT_EXEC;
  802b63:	83 c4 10             	add    $0x10,%esp
  802b66:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  802b6d:	ff ff ff 
  802b70:	e9 29 01 00 00       	jmp    802c9e <spawn+0x236>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802b75:	83 c6 01             	add    $0x1,%esi
  802b78:	83 c3 20             	add    $0x20,%ebx
  802b7b:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802b82:	39 f0                	cmp    %esi,%eax
  802b84:	7e 62                	jle    802be8 <spawn+0x180>
		if (ph->p_type != ELF_PROG_LOAD)
  802b86:	83 3b 01             	cmpl   $0x1,(%ebx)
  802b89:	75 ea                	jne    802b75 <spawn+0x10d>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802b8b:	8b 43 18             	mov    0x18(%ebx),%eax
  802b8e:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802b91:	83 f8 01             	cmp    $0x1,%eax
  802b94:	19 c0                	sbb    %eax,%eax
  802b96:	83 e0 fe             	and    $0xfffffffe,%eax
  802b99:	83 c0 07             	add    $0x7,%eax
		if ((r = map_segment(child,
  802b9c:	8b 4b 14             	mov    0x14(%ebx),%ecx
  802b9f:	8b 53 08             	mov    0x8(%ebx),%edx
  802ba2:	50                   	push   %eax
  802ba3:	ff 73 04             	pushl  0x4(%ebx)
  802ba6:	ff 73 10             	pushl  0x10(%ebx)
  802ba9:	57                   	push   %edi
  802baa:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802bb0:	e8 97 fd ff ff       	call   80294c <map_segment>
  802bb5:	83 c4 10             	add    $0x10,%esp
  802bb8:	85 c0                	test   %eax,%eax
  802bba:	79 b9                	jns    802b75 <spawn+0x10d>
  802bbc:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  802bbe:	83 ec 0c             	sub    $0xc,%esp
  802bc1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802bc7:	e8 1e ea ff ff       	call   8015ea <sys_env_destroy>
	close(fd);
  802bcc:	83 c4 04             	add    $0x4,%esp
  802bcf:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  802bd5:	e8 af f3 ff ff       	call   801f89 <close>
	return r;
  802bda:	83 c4 10             	add    $0x10,%esp
		if ((r = map_segment(child,
  802bdd:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return r;
  802be3:	e9 b6 00 00 00       	jmp    802c9e <spawn+0x236>
	close(fd);
  802be8:	83 ec 0c             	sub    $0xc,%esp
  802beb:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  802bf1:	e8 93 f3 ff ff       	call   801f89 <close>
	if ((r = copy_shared_pages(child)) < 0)
  802bf6:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802bfc:	e8 5d fb ff ff       	call   80275e <copy_shared_pages>
  802c01:	83 c4 10             	add    $0x10,%esp
  802c04:	85 c0                	test   %eax,%eax
  802c06:	78 4b                	js     802c53 <spawn+0x1eb>
	child_tf.tf_eflags |= FL_IOPL_3;  // devious: see user/faultio.c
  802c08:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802c0f:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802c12:	83 ec 08             	sub    $0x8,%esp
  802c15:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802c1b:	50                   	push   %eax
  802c1c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802c22:	e8 dc ea ff ff       	call   801703 <sys_env_set_trapframe>
  802c27:	83 c4 10             	add    $0x10,%esp
  802c2a:	85 c0                	test   %eax,%eax
  802c2c:	78 3a                	js     802c68 <spawn+0x200>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802c2e:	83 ec 08             	sub    $0x8,%esp
  802c31:	6a 02                	push   $0x2
  802c33:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802c39:	e8 9e ea ff ff       	call   8016dc <sys_env_set_status>
  802c3e:	83 c4 10             	add    $0x10,%esp
  802c41:	85 c0                	test   %eax,%eax
  802c43:	78 38                	js     802c7d <spawn+0x215>
	return child;
  802c45:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802c4b:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802c51:	eb 4b                	jmp    802c9e <spawn+0x236>
		panic("copy_shared_pages: %e", r);
  802c53:	50                   	push   %eax
  802c54:	68 c7 3d 80 00       	push   $0x803dc7
  802c59:	68 8c 00 00 00       	push   $0x8c
  802c5e:	68 84 3d 80 00       	push   $0x803d84
  802c63:	e8 2e de ff ff       	call   800a96 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  802c68:	50                   	push   %eax
  802c69:	68 dd 3d 80 00       	push   $0x803ddd
  802c6e:	68 90 00 00 00       	push   $0x90
  802c73:	68 84 3d 80 00       	push   $0x803d84
  802c78:	e8 19 de ff ff       	call   800a96 <_panic>
		panic("sys_env_set_status: %e", r);
  802c7d:	50                   	push   %eax
  802c7e:	68 f7 3d 80 00       	push   $0x803df7
  802c83:	68 93 00 00 00       	push   $0x93
  802c88:	68 84 3d 80 00       	push   $0x803d84
  802c8d:	e8 04 de ff ff       	call   800a96 <_panic>
		return r;
  802c92:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802c98:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
}
  802c9e:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802ca4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ca7:	5b                   	pop    %ebx
  802ca8:	5e                   	pop    %esi
  802ca9:	5f                   	pop    %edi
  802caa:	5d                   	pop    %ebp
  802cab:	c3                   	ret    
		return r;
  802cac:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802cb2:	eb ea                	jmp    802c9e <spawn+0x236>

00802cb4 <spawnl>:
{
  802cb4:	f3 0f 1e fb          	endbr32 
  802cb8:	55                   	push   %ebp
  802cb9:	89 e5                	mov    %esp,%ebp
  802cbb:	57                   	push   %edi
  802cbc:	56                   	push   %esi
  802cbd:	53                   	push   %ebx
  802cbe:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  802cc1:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc = 0;
  802cc4:	b8 00 00 00 00       	mov    $0x0,%eax
	while (va_arg(vl, void *) != NULL)
  802cc9:	8d 4a 04             	lea    0x4(%edx),%ecx
  802ccc:	83 3a 00             	cmpl   $0x0,(%edx)
  802ccf:	74 07                	je     802cd8 <spawnl+0x24>
		argc++;
  802cd1:	83 c0 01             	add    $0x1,%eax
	while (va_arg(vl, void *) != NULL)
  802cd4:	89 ca                	mov    %ecx,%edx
  802cd6:	eb f1                	jmp    802cc9 <spawnl+0x15>
	const char *argv[argc + 2];
  802cd8:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  802cdf:	89 d1                	mov    %edx,%ecx
  802ce1:	83 e1 f0             	and    $0xfffffff0,%ecx
  802ce4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  802cea:	89 e6                	mov    %esp,%esi
  802cec:	29 d6                	sub    %edx,%esi
  802cee:	89 f2                	mov    %esi,%edx
  802cf0:	39 d4                	cmp    %edx,%esp
  802cf2:	74 10                	je     802d04 <spawnl+0x50>
  802cf4:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  802cfa:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  802d01:	00 
  802d02:	eb ec                	jmp    802cf0 <spawnl+0x3c>
  802d04:	89 ca                	mov    %ecx,%edx
  802d06:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  802d0c:	29 d4                	sub    %edx,%esp
  802d0e:	85 d2                	test   %edx,%edx
  802d10:	74 05                	je     802d17 <spawnl+0x63>
  802d12:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  802d17:	8d 74 24 03          	lea    0x3(%esp),%esi
  802d1b:	89 f2                	mov    %esi,%edx
  802d1d:	c1 ea 02             	shr    $0x2,%edx
  802d20:	83 e6 fc             	and    $0xfffffffc,%esi
  802d23:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802d28:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc + 1] = NULL;
  802d2f:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802d36:	00 
	va_start(vl, arg0);
  802d37:	8d 4d 10             	lea    0x10(%ebp),%ecx
  802d3a:	89 c2                	mov    %eax,%edx
	for (i = 0; i < argc; i++)
  802d3c:	b8 00 00 00 00       	mov    $0x0,%eax
  802d41:	eb 0b                	jmp    802d4e <spawnl+0x9a>
		argv[i + 1] = va_arg(vl, const char *);
  802d43:	83 c0 01             	add    $0x1,%eax
  802d46:	8b 39                	mov    (%ecx),%edi
  802d48:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  802d4b:	8d 49 04             	lea    0x4(%ecx),%ecx
	for (i = 0; i < argc; i++)
  802d4e:	39 d0                	cmp    %edx,%eax
  802d50:	75 f1                	jne    802d43 <spawnl+0x8f>
	return spawn(prog, argv);
  802d52:	83 ec 08             	sub    $0x8,%esp
  802d55:	56                   	push   %esi
  802d56:	ff 75 08             	pushl  0x8(%ebp)
  802d59:	e8 0a fd ff ff       	call   802a68 <spawn>
}
  802d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d61:	5b                   	pop    %ebx
  802d62:	5e                   	pop    %esi
  802d63:	5f                   	pop    %edi
  802d64:	5d                   	pop    %ebp
  802d65:	c3                   	ret    

00802d66 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802d66:	f3 0f 1e fb          	endbr32 
  802d6a:	55                   	push   %ebp
  802d6b:	89 e5                	mov    %esp,%ebp
  802d6d:	56                   	push   %esi
  802d6e:	53                   	push   %ebx
  802d6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802d72:	83 ec 0c             	sub    $0xc,%esp
  802d75:	ff 75 08             	pushl  0x8(%ebp)
  802d78:	e8 5e f0 ff ff       	call   801ddb <fd2data>
  802d7d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802d7f:	83 c4 08             	add    $0x8,%esp
  802d82:	68 0e 3e 80 00       	push   $0x803e0e
  802d87:	53                   	push   %ebx
  802d88:	e8 4e e4 ff ff       	call   8011db <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802d8d:	8b 46 04             	mov    0x4(%esi),%eax
  802d90:	2b 06                	sub    (%esi),%eax
  802d92:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802d98:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802d9f:	00 00 00 
	stat->st_dev = &devpipe;
  802da2:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802da9:	40 80 00 
	return 0;
}
  802dac:	b8 00 00 00 00       	mov    $0x0,%eax
  802db1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802db4:	5b                   	pop    %ebx
  802db5:	5e                   	pop    %esi
  802db6:	5d                   	pop    %ebp
  802db7:	c3                   	ret    

00802db8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802db8:	f3 0f 1e fb          	endbr32 
  802dbc:	55                   	push   %ebp
  802dbd:	89 e5                	mov    %esp,%ebp
  802dbf:	53                   	push   %ebx
  802dc0:	83 ec 0c             	sub    $0xc,%esp
  802dc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802dc6:	53                   	push   %ebx
  802dc7:	6a 00                	push   $0x0
  802dc9:	e8 e7 e8 ff ff       	call   8016b5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802dce:	89 1c 24             	mov    %ebx,(%esp)
  802dd1:	e8 05 f0 ff ff       	call   801ddb <fd2data>
  802dd6:	83 c4 08             	add    $0x8,%esp
  802dd9:	50                   	push   %eax
  802dda:	6a 00                	push   $0x0
  802ddc:	e8 d4 e8 ff ff       	call   8016b5 <sys_page_unmap>
}
  802de1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802de4:	c9                   	leave  
  802de5:	c3                   	ret    

00802de6 <_pipeisclosed>:
{
  802de6:	55                   	push   %ebp
  802de7:	89 e5                	mov    %esp,%ebp
  802de9:	57                   	push   %edi
  802dea:	56                   	push   %esi
  802deb:	53                   	push   %ebx
  802dec:	83 ec 1c             	sub    $0x1c,%esp
  802def:	89 c7                	mov    %eax,%edi
  802df1:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802df3:	a1 24 54 80 00       	mov    0x805424,%eax
  802df8:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802dfb:	83 ec 0c             	sub    $0xc,%esp
  802dfe:	57                   	push   %edi
  802dff:	e8 b1 04 00 00       	call   8032b5 <pageref>
  802e04:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802e07:	89 34 24             	mov    %esi,(%esp)
  802e0a:	e8 a6 04 00 00       	call   8032b5 <pageref>
		nn = thisenv->env_runs;
  802e0f:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802e15:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802e18:	83 c4 10             	add    $0x10,%esp
  802e1b:	39 cb                	cmp    %ecx,%ebx
  802e1d:	74 1b                	je     802e3a <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802e1f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802e22:	75 cf                	jne    802df3 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802e24:	8b 42 58             	mov    0x58(%edx),%eax
  802e27:	6a 01                	push   $0x1
  802e29:	50                   	push   %eax
  802e2a:	53                   	push   %ebx
  802e2b:	68 15 3e 80 00       	push   $0x803e15
  802e30:	e8 48 dd ff ff       	call   800b7d <cprintf>
  802e35:	83 c4 10             	add    $0x10,%esp
  802e38:	eb b9                	jmp    802df3 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802e3a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802e3d:	0f 94 c0             	sete   %al
  802e40:	0f b6 c0             	movzbl %al,%eax
}
  802e43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e46:	5b                   	pop    %ebx
  802e47:	5e                   	pop    %esi
  802e48:	5f                   	pop    %edi
  802e49:	5d                   	pop    %ebp
  802e4a:	c3                   	ret    

00802e4b <devpipe_write>:
{
  802e4b:	f3 0f 1e fb          	endbr32 
  802e4f:	55                   	push   %ebp
  802e50:	89 e5                	mov    %esp,%ebp
  802e52:	57                   	push   %edi
  802e53:	56                   	push   %esi
  802e54:	53                   	push   %ebx
  802e55:	83 ec 28             	sub    $0x28,%esp
  802e58:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802e5b:	56                   	push   %esi
  802e5c:	e8 7a ef ff ff       	call   801ddb <fd2data>
  802e61:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802e63:	83 c4 10             	add    $0x10,%esp
  802e66:	bf 00 00 00 00       	mov    $0x0,%edi
  802e6b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802e6e:	74 4f                	je     802ebf <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802e70:	8b 43 04             	mov    0x4(%ebx),%eax
  802e73:	8b 0b                	mov    (%ebx),%ecx
  802e75:	8d 51 20             	lea    0x20(%ecx),%edx
  802e78:	39 d0                	cmp    %edx,%eax
  802e7a:	72 14                	jb     802e90 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  802e7c:	89 da                	mov    %ebx,%edx
  802e7e:	89 f0                	mov    %esi,%eax
  802e80:	e8 61 ff ff ff       	call   802de6 <_pipeisclosed>
  802e85:	85 c0                	test   %eax,%eax
  802e87:	75 3b                	jne    802ec4 <devpipe_write+0x79>
			sys_yield();
  802e89:	e8 aa e7 ff ff       	call   801638 <sys_yield>
  802e8e:	eb e0                	jmp    802e70 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802e90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802e93:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802e97:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802e9a:	89 c2                	mov    %eax,%edx
  802e9c:	c1 fa 1f             	sar    $0x1f,%edx
  802e9f:	89 d1                	mov    %edx,%ecx
  802ea1:	c1 e9 1b             	shr    $0x1b,%ecx
  802ea4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802ea7:	83 e2 1f             	and    $0x1f,%edx
  802eaa:	29 ca                	sub    %ecx,%edx
  802eac:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802eb0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802eb4:	83 c0 01             	add    $0x1,%eax
  802eb7:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802eba:	83 c7 01             	add    $0x1,%edi
  802ebd:	eb ac                	jmp    802e6b <devpipe_write+0x20>
	return i;
  802ebf:	8b 45 10             	mov    0x10(%ebp),%eax
  802ec2:	eb 05                	jmp    802ec9 <devpipe_write+0x7e>
				return 0;
  802ec4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ec9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ecc:	5b                   	pop    %ebx
  802ecd:	5e                   	pop    %esi
  802ece:	5f                   	pop    %edi
  802ecf:	5d                   	pop    %ebp
  802ed0:	c3                   	ret    

00802ed1 <devpipe_read>:
{
  802ed1:	f3 0f 1e fb          	endbr32 
  802ed5:	55                   	push   %ebp
  802ed6:	89 e5                	mov    %esp,%ebp
  802ed8:	57                   	push   %edi
  802ed9:	56                   	push   %esi
  802eda:	53                   	push   %ebx
  802edb:	83 ec 18             	sub    $0x18,%esp
  802ede:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802ee1:	57                   	push   %edi
  802ee2:	e8 f4 ee ff ff       	call   801ddb <fd2data>
  802ee7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802ee9:	83 c4 10             	add    $0x10,%esp
  802eec:	be 00 00 00 00       	mov    $0x0,%esi
  802ef1:	3b 75 10             	cmp    0x10(%ebp),%esi
  802ef4:	75 14                	jne    802f0a <devpipe_read+0x39>
	return i;
  802ef6:	8b 45 10             	mov    0x10(%ebp),%eax
  802ef9:	eb 02                	jmp    802efd <devpipe_read+0x2c>
				return i;
  802efb:	89 f0                	mov    %esi,%eax
}
  802efd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802f00:	5b                   	pop    %ebx
  802f01:	5e                   	pop    %esi
  802f02:	5f                   	pop    %edi
  802f03:	5d                   	pop    %ebp
  802f04:	c3                   	ret    
			sys_yield();
  802f05:	e8 2e e7 ff ff       	call   801638 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802f0a:	8b 03                	mov    (%ebx),%eax
  802f0c:	3b 43 04             	cmp    0x4(%ebx),%eax
  802f0f:	75 18                	jne    802f29 <devpipe_read+0x58>
			if (i > 0)
  802f11:	85 f6                	test   %esi,%esi
  802f13:	75 e6                	jne    802efb <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802f15:	89 da                	mov    %ebx,%edx
  802f17:	89 f8                	mov    %edi,%eax
  802f19:	e8 c8 fe ff ff       	call   802de6 <_pipeisclosed>
  802f1e:	85 c0                	test   %eax,%eax
  802f20:	74 e3                	je     802f05 <devpipe_read+0x34>
				return 0;
  802f22:	b8 00 00 00 00       	mov    $0x0,%eax
  802f27:	eb d4                	jmp    802efd <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802f29:	99                   	cltd   
  802f2a:	c1 ea 1b             	shr    $0x1b,%edx
  802f2d:	01 d0                	add    %edx,%eax
  802f2f:	83 e0 1f             	and    $0x1f,%eax
  802f32:	29 d0                	sub    %edx,%eax
  802f34:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802f39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802f3c:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802f3f:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802f42:	83 c6 01             	add    $0x1,%esi
  802f45:	eb aa                	jmp    802ef1 <devpipe_read+0x20>

00802f47 <pipe>:
{
  802f47:	f3 0f 1e fb          	endbr32 
  802f4b:	55                   	push   %ebp
  802f4c:	89 e5                	mov    %esp,%ebp
  802f4e:	56                   	push   %esi
  802f4f:	53                   	push   %ebx
  802f50:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802f53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f56:	50                   	push   %eax
  802f57:	e8 9e ee ff ff       	call   801dfa <fd_alloc>
  802f5c:	89 c3                	mov    %eax,%ebx
  802f5e:	83 c4 10             	add    $0x10,%esp
  802f61:	85 c0                	test   %eax,%eax
  802f63:	0f 88 23 01 00 00    	js     80308c <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802f69:	83 ec 04             	sub    $0x4,%esp
  802f6c:	68 07 04 00 00       	push   $0x407
  802f71:	ff 75 f4             	pushl  -0xc(%ebp)
  802f74:	6a 00                	push   $0x0
  802f76:	e8 e8 e6 ff ff       	call   801663 <sys_page_alloc>
  802f7b:	89 c3                	mov    %eax,%ebx
  802f7d:	83 c4 10             	add    $0x10,%esp
  802f80:	85 c0                	test   %eax,%eax
  802f82:	0f 88 04 01 00 00    	js     80308c <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  802f88:	83 ec 0c             	sub    $0xc,%esp
  802f8b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f8e:	50                   	push   %eax
  802f8f:	e8 66 ee ff ff       	call   801dfa <fd_alloc>
  802f94:	89 c3                	mov    %eax,%ebx
  802f96:	83 c4 10             	add    $0x10,%esp
  802f99:	85 c0                	test   %eax,%eax
  802f9b:	0f 88 db 00 00 00    	js     80307c <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802fa1:	83 ec 04             	sub    $0x4,%esp
  802fa4:	68 07 04 00 00       	push   $0x407
  802fa9:	ff 75 f0             	pushl  -0x10(%ebp)
  802fac:	6a 00                	push   $0x0
  802fae:	e8 b0 e6 ff ff       	call   801663 <sys_page_alloc>
  802fb3:	89 c3                	mov    %eax,%ebx
  802fb5:	83 c4 10             	add    $0x10,%esp
  802fb8:	85 c0                	test   %eax,%eax
  802fba:	0f 88 bc 00 00 00    	js     80307c <pipe+0x135>
	va = fd2data(fd0);
  802fc0:	83 ec 0c             	sub    $0xc,%esp
  802fc3:	ff 75 f4             	pushl  -0xc(%ebp)
  802fc6:	e8 10 ee ff ff       	call   801ddb <fd2data>
  802fcb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802fcd:	83 c4 0c             	add    $0xc,%esp
  802fd0:	68 07 04 00 00       	push   $0x407
  802fd5:	50                   	push   %eax
  802fd6:	6a 00                	push   $0x0
  802fd8:	e8 86 e6 ff ff       	call   801663 <sys_page_alloc>
  802fdd:	89 c3                	mov    %eax,%ebx
  802fdf:	83 c4 10             	add    $0x10,%esp
  802fe2:	85 c0                	test   %eax,%eax
  802fe4:	0f 88 82 00 00 00    	js     80306c <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802fea:	83 ec 0c             	sub    $0xc,%esp
  802fed:	ff 75 f0             	pushl  -0x10(%ebp)
  802ff0:	e8 e6 ed ff ff       	call   801ddb <fd2data>
  802ff5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802ffc:	50                   	push   %eax
  802ffd:	6a 00                	push   $0x0
  802fff:	56                   	push   %esi
  803000:	6a 00                	push   $0x0
  803002:	e8 84 e6 ff ff       	call   80168b <sys_page_map>
  803007:	89 c3                	mov    %eax,%ebx
  803009:	83 c4 20             	add    $0x20,%esp
  80300c:	85 c0                	test   %eax,%eax
  80300e:	78 4e                	js     80305e <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  803010:	a1 3c 40 80 00       	mov    0x80403c,%eax
  803015:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803018:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80301a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80301d:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  803024:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803027:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  803029:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80302c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  803033:	83 ec 0c             	sub    $0xc,%esp
  803036:	ff 75 f4             	pushl  -0xc(%ebp)
  803039:	e8 89 ed ff ff       	call   801dc7 <fd2num>
  80303e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803041:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803043:	83 c4 04             	add    $0x4,%esp
  803046:	ff 75 f0             	pushl  -0x10(%ebp)
  803049:	e8 79 ed ff ff       	call   801dc7 <fd2num>
  80304e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803051:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803054:	83 c4 10             	add    $0x10,%esp
  803057:	bb 00 00 00 00       	mov    $0x0,%ebx
  80305c:	eb 2e                	jmp    80308c <pipe+0x145>
	sys_page_unmap(0, va);
  80305e:	83 ec 08             	sub    $0x8,%esp
  803061:	56                   	push   %esi
  803062:	6a 00                	push   $0x0
  803064:	e8 4c e6 ff ff       	call   8016b5 <sys_page_unmap>
  803069:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80306c:	83 ec 08             	sub    $0x8,%esp
  80306f:	ff 75 f0             	pushl  -0x10(%ebp)
  803072:	6a 00                	push   $0x0
  803074:	e8 3c e6 ff ff       	call   8016b5 <sys_page_unmap>
  803079:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80307c:	83 ec 08             	sub    $0x8,%esp
  80307f:	ff 75 f4             	pushl  -0xc(%ebp)
  803082:	6a 00                	push   $0x0
  803084:	e8 2c e6 ff ff       	call   8016b5 <sys_page_unmap>
  803089:	83 c4 10             	add    $0x10,%esp
}
  80308c:	89 d8                	mov    %ebx,%eax
  80308e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803091:	5b                   	pop    %ebx
  803092:	5e                   	pop    %esi
  803093:	5d                   	pop    %ebp
  803094:	c3                   	ret    

00803095 <pipeisclosed>:
{
  803095:	f3 0f 1e fb          	endbr32 
  803099:	55                   	push   %ebp
  80309a:	89 e5                	mov    %esp,%ebp
  80309c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80309f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030a2:	50                   	push   %eax
  8030a3:	ff 75 08             	pushl  0x8(%ebp)
  8030a6:	e8 a5 ed ff ff       	call   801e50 <fd_lookup>
  8030ab:	83 c4 10             	add    $0x10,%esp
  8030ae:	85 c0                	test   %eax,%eax
  8030b0:	78 18                	js     8030ca <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  8030b2:	83 ec 0c             	sub    $0xc,%esp
  8030b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8030b8:	e8 1e ed ff ff       	call   801ddb <fd2data>
  8030bd:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8030bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8030c2:	e8 1f fd ff ff       	call   802de6 <_pipeisclosed>
  8030c7:	83 c4 10             	add    $0x10,%esp
}
  8030ca:	c9                   	leave  
  8030cb:	c3                   	ret    

008030cc <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8030cc:	f3 0f 1e fb          	endbr32 
  8030d0:	55                   	push   %ebp
  8030d1:	89 e5                	mov    %esp,%ebp
  8030d3:	56                   	push   %esi
  8030d4:	53                   	push   %ebx
  8030d5:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8030d8:	85 f6                	test   %esi,%esi
  8030da:	74 13                	je     8030ef <wait+0x23>
	e = &envs[ENVX(envid)];
  8030dc:	89 f3                	mov    %esi,%ebx
  8030de:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8030e4:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8030e7:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8030ed:	eb 1b                	jmp    80310a <wait+0x3e>
	assert(envid != 0);
  8030ef:	68 2d 3e 80 00       	push   $0x803e2d
  8030f4:	68 9a 36 80 00       	push   $0x80369a
  8030f9:	6a 09                	push   $0x9
  8030fb:	68 38 3e 80 00       	push   $0x803e38
  803100:	e8 91 d9 ff ff       	call   800a96 <_panic>
		sys_yield();
  803105:	e8 2e e5 ff ff       	call   801638 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80310a:	8b 43 48             	mov    0x48(%ebx),%eax
  80310d:	39 f0                	cmp    %esi,%eax
  80310f:	75 07                	jne    803118 <wait+0x4c>
  803111:	8b 43 54             	mov    0x54(%ebx),%eax
  803114:	85 c0                	test   %eax,%eax
  803116:	75 ed                	jne    803105 <wait+0x39>
}
  803118:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80311b:	5b                   	pop    %ebx
  80311c:	5e                   	pop    %esi
  80311d:	5d                   	pop    %ebp
  80311e:	c3                   	ret    

0080311f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80311f:	f3 0f 1e fb          	endbr32 
  803123:	55                   	push   %ebp
  803124:	89 e5                	mov    %esp,%ebp
  803126:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  803129:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  803130:	74 0a                	je     80313c <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  803132:	8b 45 08             	mov    0x8(%ebp),%eax
  803135:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80313a:	c9                   	leave  
  80313b:	c3                   	ret    
		if (sys_page_alloc(0,
  80313c:	83 ec 04             	sub    $0x4,%esp
  80313f:	6a 07                	push   $0x7
  803141:	68 00 f0 bf ee       	push   $0xeebff000
  803146:	6a 00                	push   $0x0
  803148:	e8 16 e5 ff ff       	call   801663 <sys_page_alloc>
  80314d:	83 c4 10             	add    $0x10,%esp
  803150:	85 c0                	test   %eax,%eax
  803152:	78 2a                	js     80317e <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  803154:	83 ec 08             	sub    $0x8,%esp
  803157:	68 92 31 80 00       	push   $0x803192
  80315c:	6a 00                	push   $0x0
  80315e:	e8 c7 e5 ff ff       	call   80172a <sys_env_set_pgfault_upcall>
  803163:	83 c4 10             	add    $0x10,%esp
  803166:	85 c0                	test   %eax,%eax
  803168:	79 c8                	jns    803132 <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  80316a:	83 ec 04             	sub    $0x4,%esp
  80316d:	68 78 3e 80 00       	push   $0x803e78
  803172:	6a 25                	push   $0x25
  803174:	68 bf 3e 80 00       	push   $0x803ebf
  803179:	e8 18 d9 ff ff       	call   800a96 <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  80317e:	83 ec 04             	sub    $0x4,%esp
  803181:	68 44 3e 80 00       	push   $0x803e44
  803186:	6a 21                	push   $0x21
  803188:	68 bf 3e 80 00       	push   $0x803ebf
  80318d:	e8 04 d9 ff ff       	call   800a96 <_panic>

00803192 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  803192:	54                   	push   %esp
	movl _pgfault_handler, %eax
  803193:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  803198:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80319a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  80319d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  8031a2:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  8031a6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8031aa:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8031ac:	83 c4 08             	add    $0x8,%esp
	popal
  8031af:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  8031b0:	83 c4 04             	add    $0x4,%esp
	popfl
  8031b3:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  8031b4:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8031b7:	c3                   	ret    

008031b8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8031b8:	f3 0f 1e fb          	endbr32 
  8031bc:	55                   	push   %ebp
  8031bd:	89 e5                	mov    %esp,%ebp
  8031bf:	56                   	push   %esi
  8031c0:	53                   	push   %ebx
  8031c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8031c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  8031ca:	85 c0                	test   %eax,%eax
  8031cc:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8031d1:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  8031d4:	83 ec 0c             	sub    $0xc,%esp
  8031d7:	50                   	push   %eax
  8031d8:	e8 9d e5 ff ff       	call   80177a <sys_ipc_recv>
	if (f < 0) {
  8031dd:	83 c4 10             	add    $0x10,%esp
  8031e0:	85 c0                	test   %eax,%eax
  8031e2:	78 2b                	js     80320f <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  8031e4:	85 f6                	test   %esi,%esi
  8031e6:	74 0a                	je     8031f2 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  8031e8:	a1 24 54 80 00       	mov    0x805424,%eax
  8031ed:	8b 40 74             	mov    0x74(%eax),%eax
  8031f0:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  8031f2:	85 db                	test   %ebx,%ebx
  8031f4:	74 0a                	je     803200 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  8031f6:	a1 24 54 80 00       	mov    0x805424,%eax
  8031fb:	8b 40 78             	mov    0x78(%eax),%eax
  8031fe:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  803200:	a1 24 54 80 00       	mov    0x805424,%eax
  803205:	8b 40 70             	mov    0x70(%eax),%eax
}
  803208:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80320b:	5b                   	pop    %ebx
  80320c:	5e                   	pop    %esi
  80320d:	5d                   	pop    %ebp
  80320e:	c3                   	ret    
		if (from_env_store != NULL) {
  80320f:	85 f6                	test   %esi,%esi
  803211:	74 06                	je     803219 <ipc_recv+0x61>
			*from_env_store = 0;
  803213:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  803219:	85 db                	test   %ebx,%ebx
  80321b:	74 eb                	je     803208 <ipc_recv+0x50>
			*perm_store = 0;
  80321d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  803223:	eb e3                	jmp    803208 <ipc_recv+0x50>

00803225 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  803225:	f3 0f 1e fb          	endbr32 
  803229:	55                   	push   %ebp
  80322a:	89 e5                	mov    %esp,%ebp
  80322c:	57                   	push   %edi
  80322d:	56                   	push   %esi
  80322e:	53                   	push   %ebx
  80322f:	83 ec 0c             	sub    $0xc,%esp
  803232:	8b 7d 08             	mov    0x8(%ebp),%edi
  803235:	8b 75 0c             	mov    0xc(%ebp),%esi
  803238:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  80323b:	85 db                	test   %ebx,%ebx
  80323d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  803242:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  803245:	ff 75 14             	pushl  0x14(%ebp)
  803248:	53                   	push   %ebx
  803249:	56                   	push   %esi
  80324a:	57                   	push   %edi
  80324b:	e8 01 e5 ff ff       	call   801751 <sys_ipc_try_send>
  803250:	83 c4 10             	add    $0x10,%esp
  803253:	85 c0                	test   %eax,%eax
  803255:	79 19                	jns    803270 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  803257:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80325a:	74 e9                	je     803245 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  80325c:	83 ec 04             	sub    $0x4,%esp
  80325f:	68 d0 3e 80 00       	push   $0x803ed0
  803264:	6a 48                	push   $0x48
  803266:	68 f2 3e 80 00       	push   $0x803ef2
  80326b:	e8 26 d8 ff ff       	call   800a96 <_panic>
		}
	}
}
  803270:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803273:	5b                   	pop    %ebx
  803274:	5e                   	pop    %esi
  803275:	5f                   	pop    %edi
  803276:	5d                   	pop    %ebp
  803277:	c3                   	ret    

00803278 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803278:	f3 0f 1e fb          	endbr32 
  80327c:	55                   	push   %ebp
  80327d:	89 e5                	mov    %esp,%ebp
  80327f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  803282:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  803287:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80328a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803290:	8b 52 50             	mov    0x50(%edx),%edx
  803293:	39 ca                	cmp    %ecx,%edx
  803295:	74 11                	je     8032a8 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  803297:	83 c0 01             	add    $0x1,%eax
  80329a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80329f:	75 e6                	jne    803287 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8032a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8032a6:	eb 0b                	jmp    8032b3 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8032a8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8032ab:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8032b0:	8b 40 48             	mov    0x48(%eax),%eax
}
  8032b3:	5d                   	pop    %ebp
  8032b4:	c3                   	ret    

008032b5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8032b5:	f3 0f 1e fb          	endbr32 
  8032b9:	55                   	push   %ebp
  8032ba:	89 e5                	mov    %esp,%ebp
  8032bc:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8032bf:	89 c2                	mov    %eax,%edx
  8032c1:	c1 ea 16             	shr    $0x16,%edx
  8032c4:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8032cb:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8032d0:	f6 c1 01             	test   $0x1,%cl
  8032d3:	74 1c                	je     8032f1 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8032d5:	c1 e8 0c             	shr    $0xc,%eax
  8032d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8032df:	a8 01                	test   $0x1,%al
  8032e1:	74 0e                	je     8032f1 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8032e3:	c1 e8 0c             	shr    $0xc,%eax
  8032e6:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8032ed:	ef 
  8032ee:	0f b7 d2             	movzwl %dx,%edx
}
  8032f1:	89 d0                	mov    %edx,%eax
  8032f3:	5d                   	pop    %ebp
  8032f4:	c3                   	ret    
  8032f5:	66 90                	xchg   %ax,%ax
  8032f7:	66 90                	xchg   %ax,%ax
  8032f9:	66 90                	xchg   %ax,%ax
  8032fb:	66 90                	xchg   %ax,%ax
  8032fd:	66 90                	xchg   %ax,%ax
  8032ff:	90                   	nop

00803300 <__udivdi3>:
  803300:	f3 0f 1e fb          	endbr32 
  803304:	55                   	push   %ebp
  803305:	57                   	push   %edi
  803306:	56                   	push   %esi
  803307:	53                   	push   %ebx
  803308:	83 ec 1c             	sub    $0x1c,%esp
  80330b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80330f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  803313:	8b 74 24 34          	mov    0x34(%esp),%esi
  803317:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80331b:	85 d2                	test   %edx,%edx
  80331d:	75 19                	jne    803338 <__udivdi3+0x38>
  80331f:	39 f3                	cmp    %esi,%ebx
  803321:	76 4d                	jbe    803370 <__udivdi3+0x70>
  803323:	31 ff                	xor    %edi,%edi
  803325:	89 e8                	mov    %ebp,%eax
  803327:	89 f2                	mov    %esi,%edx
  803329:	f7 f3                	div    %ebx
  80332b:	89 fa                	mov    %edi,%edx
  80332d:	83 c4 1c             	add    $0x1c,%esp
  803330:	5b                   	pop    %ebx
  803331:	5e                   	pop    %esi
  803332:	5f                   	pop    %edi
  803333:	5d                   	pop    %ebp
  803334:	c3                   	ret    
  803335:	8d 76 00             	lea    0x0(%esi),%esi
  803338:	39 f2                	cmp    %esi,%edx
  80333a:	76 14                	jbe    803350 <__udivdi3+0x50>
  80333c:	31 ff                	xor    %edi,%edi
  80333e:	31 c0                	xor    %eax,%eax
  803340:	89 fa                	mov    %edi,%edx
  803342:	83 c4 1c             	add    $0x1c,%esp
  803345:	5b                   	pop    %ebx
  803346:	5e                   	pop    %esi
  803347:	5f                   	pop    %edi
  803348:	5d                   	pop    %ebp
  803349:	c3                   	ret    
  80334a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803350:	0f bd fa             	bsr    %edx,%edi
  803353:	83 f7 1f             	xor    $0x1f,%edi
  803356:	75 48                	jne    8033a0 <__udivdi3+0xa0>
  803358:	39 f2                	cmp    %esi,%edx
  80335a:	72 06                	jb     803362 <__udivdi3+0x62>
  80335c:	31 c0                	xor    %eax,%eax
  80335e:	39 eb                	cmp    %ebp,%ebx
  803360:	77 de                	ja     803340 <__udivdi3+0x40>
  803362:	b8 01 00 00 00       	mov    $0x1,%eax
  803367:	eb d7                	jmp    803340 <__udivdi3+0x40>
  803369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803370:	89 d9                	mov    %ebx,%ecx
  803372:	85 db                	test   %ebx,%ebx
  803374:	75 0b                	jne    803381 <__udivdi3+0x81>
  803376:	b8 01 00 00 00       	mov    $0x1,%eax
  80337b:	31 d2                	xor    %edx,%edx
  80337d:	f7 f3                	div    %ebx
  80337f:	89 c1                	mov    %eax,%ecx
  803381:	31 d2                	xor    %edx,%edx
  803383:	89 f0                	mov    %esi,%eax
  803385:	f7 f1                	div    %ecx
  803387:	89 c6                	mov    %eax,%esi
  803389:	89 e8                	mov    %ebp,%eax
  80338b:	89 f7                	mov    %esi,%edi
  80338d:	f7 f1                	div    %ecx
  80338f:	89 fa                	mov    %edi,%edx
  803391:	83 c4 1c             	add    $0x1c,%esp
  803394:	5b                   	pop    %ebx
  803395:	5e                   	pop    %esi
  803396:	5f                   	pop    %edi
  803397:	5d                   	pop    %ebp
  803398:	c3                   	ret    
  803399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8033a0:	89 f9                	mov    %edi,%ecx
  8033a2:	b8 20 00 00 00       	mov    $0x20,%eax
  8033a7:	29 f8                	sub    %edi,%eax
  8033a9:	d3 e2                	shl    %cl,%edx
  8033ab:	89 54 24 08          	mov    %edx,0x8(%esp)
  8033af:	89 c1                	mov    %eax,%ecx
  8033b1:	89 da                	mov    %ebx,%edx
  8033b3:	d3 ea                	shr    %cl,%edx
  8033b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8033b9:	09 d1                	or     %edx,%ecx
  8033bb:	89 f2                	mov    %esi,%edx
  8033bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8033c1:	89 f9                	mov    %edi,%ecx
  8033c3:	d3 e3                	shl    %cl,%ebx
  8033c5:	89 c1                	mov    %eax,%ecx
  8033c7:	d3 ea                	shr    %cl,%edx
  8033c9:	89 f9                	mov    %edi,%ecx
  8033cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8033cf:	89 eb                	mov    %ebp,%ebx
  8033d1:	d3 e6                	shl    %cl,%esi
  8033d3:	89 c1                	mov    %eax,%ecx
  8033d5:	d3 eb                	shr    %cl,%ebx
  8033d7:	09 de                	or     %ebx,%esi
  8033d9:	89 f0                	mov    %esi,%eax
  8033db:	f7 74 24 08          	divl   0x8(%esp)
  8033df:	89 d6                	mov    %edx,%esi
  8033e1:	89 c3                	mov    %eax,%ebx
  8033e3:	f7 64 24 0c          	mull   0xc(%esp)
  8033e7:	39 d6                	cmp    %edx,%esi
  8033e9:	72 15                	jb     803400 <__udivdi3+0x100>
  8033eb:	89 f9                	mov    %edi,%ecx
  8033ed:	d3 e5                	shl    %cl,%ebp
  8033ef:	39 c5                	cmp    %eax,%ebp
  8033f1:	73 04                	jae    8033f7 <__udivdi3+0xf7>
  8033f3:	39 d6                	cmp    %edx,%esi
  8033f5:	74 09                	je     803400 <__udivdi3+0x100>
  8033f7:	89 d8                	mov    %ebx,%eax
  8033f9:	31 ff                	xor    %edi,%edi
  8033fb:	e9 40 ff ff ff       	jmp    803340 <__udivdi3+0x40>
  803400:	8d 43 ff             	lea    -0x1(%ebx),%eax
  803403:	31 ff                	xor    %edi,%edi
  803405:	e9 36 ff ff ff       	jmp    803340 <__udivdi3+0x40>
  80340a:	66 90                	xchg   %ax,%ax
  80340c:	66 90                	xchg   %ax,%ax
  80340e:	66 90                	xchg   %ax,%ax

00803410 <__umoddi3>:
  803410:	f3 0f 1e fb          	endbr32 
  803414:	55                   	push   %ebp
  803415:	57                   	push   %edi
  803416:	56                   	push   %esi
  803417:	53                   	push   %ebx
  803418:	83 ec 1c             	sub    $0x1c,%esp
  80341b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80341f:	8b 74 24 30          	mov    0x30(%esp),%esi
  803423:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  803427:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80342b:	85 c0                	test   %eax,%eax
  80342d:	75 19                	jne    803448 <__umoddi3+0x38>
  80342f:	39 df                	cmp    %ebx,%edi
  803431:	76 5d                	jbe    803490 <__umoddi3+0x80>
  803433:	89 f0                	mov    %esi,%eax
  803435:	89 da                	mov    %ebx,%edx
  803437:	f7 f7                	div    %edi
  803439:	89 d0                	mov    %edx,%eax
  80343b:	31 d2                	xor    %edx,%edx
  80343d:	83 c4 1c             	add    $0x1c,%esp
  803440:	5b                   	pop    %ebx
  803441:	5e                   	pop    %esi
  803442:	5f                   	pop    %edi
  803443:	5d                   	pop    %ebp
  803444:	c3                   	ret    
  803445:	8d 76 00             	lea    0x0(%esi),%esi
  803448:	89 f2                	mov    %esi,%edx
  80344a:	39 d8                	cmp    %ebx,%eax
  80344c:	76 12                	jbe    803460 <__umoddi3+0x50>
  80344e:	89 f0                	mov    %esi,%eax
  803450:	89 da                	mov    %ebx,%edx
  803452:	83 c4 1c             	add    $0x1c,%esp
  803455:	5b                   	pop    %ebx
  803456:	5e                   	pop    %esi
  803457:	5f                   	pop    %edi
  803458:	5d                   	pop    %ebp
  803459:	c3                   	ret    
  80345a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803460:	0f bd e8             	bsr    %eax,%ebp
  803463:	83 f5 1f             	xor    $0x1f,%ebp
  803466:	75 50                	jne    8034b8 <__umoddi3+0xa8>
  803468:	39 d8                	cmp    %ebx,%eax
  80346a:	0f 82 e0 00 00 00    	jb     803550 <__umoddi3+0x140>
  803470:	89 d9                	mov    %ebx,%ecx
  803472:	39 f7                	cmp    %esi,%edi
  803474:	0f 86 d6 00 00 00    	jbe    803550 <__umoddi3+0x140>
  80347a:	89 d0                	mov    %edx,%eax
  80347c:	89 ca                	mov    %ecx,%edx
  80347e:	83 c4 1c             	add    $0x1c,%esp
  803481:	5b                   	pop    %ebx
  803482:	5e                   	pop    %esi
  803483:	5f                   	pop    %edi
  803484:	5d                   	pop    %ebp
  803485:	c3                   	ret    
  803486:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80348d:	8d 76 00             	lea    0x0(%esi),%esi
  803490:	89 fd                	mov    %edi,%ebp
  803492:	85 ff                	test   %edi,%edi
  803494:	75 0b                	jne    8034a1 <__umoddi3+0x91>
  803496:	b8 01 00 00 00       	mov    $0x1,%eax
  80349b:	31 d2                	xor    %edx,%edx
  80349d:	f7 f7                	div    %edi
  80349f:	89 c5                	mov    %eax,%ebp
  8034a1:	89 d8                	mov    %ebx,%eax
  8034a3:	31 d2                	xor    %edx,%edx
  8034a5:	f7 f5                	div    %ebp
  8034a7:	89 f0                	mov    %esi,%eax
  8034a9:	f7 f5                	div    %ebp
  8034ab:	89 d0                	mov    %edx,%eax
  8034ad:	31 d2                	xor    %edx,%edx
  8034af:	eb 8c                	jmp    80343d <__umoddi3+0x2d>
  8034b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8034b8:	89 e9                	mov    %ebp,%ecx
  8034ba:	ba 20 00 00 00       	mov    $0x20,%edx
  8034bf:	29 ea                	sub    %ebp,%edx
  8034c1:	d3 e0                	shl    %cl,%eax
  8034c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8034c7:	89 d1                	mov    %edx,%ecx
  8034c9:	89 f8                	mov    %edi,%eax
  8034cb:	d3 e8                	shr    %cl,%eax
  8034cd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8034d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8034d5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8034d9:	09 c1                	or     %eax,%ecx
  8034db:	89 d8                	mov    %ebx,%eax
  8034dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8034e1:	89 e9                	mov    %ebp,%ecx
  8034e3:	d3 e7                	shl    %cl,%edi
  8034e5:	89 d1                	mov    %edx,%ecx
  8034e7:	d3 e8                	shr    %cl,%eax
  8034e9:	89 e9                	mov    %ebp,%ecx
  8034eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8034ef:	d3 e3                	shl    %cl,%ebx
  8034f1:	89 c7                	mov    %eax,%edi
  8034f3:	89 d1                	mov    %edx,%ecx
  8034f5:	89 f0                	mov    %esi,%eax
  8034f7:	d3 e8                	shr    %cl,%eax
  8034f9:	89 e9                	mov    %ebp,%ecx
  8034fb:	89 fa                	mov    %edi,%edx
  8034fd:	d3 e6                	shl    %cl,%esi
  8034ff:	09 d8                	or     %ebx,%eax
  803501:	f7 74 24 08          	divl   0x8(%esp)
  803505:	89 d1                	mov    %edx,%ecx
  803507:	89 f3                	mov    %esi,%ebx
  803509:	f7 64 24 0c          	mull   0xc(%esp)
  80350d:	89 c6                	mov    %eax,%esi
  80350f:	89 d7                	mov    %edx,%edi
  803511:	39 d1                	cmp    %edx,%ecx
  803513:	72 06                	jb     80351b <__umoddi3+0x10b>
  803515:	75 10                	jne    803527 <__umoddi3+0x117>
  803517:	39 c3                	cmp    %eax,%ebx
  803519:	73 0c                	jae    803527 <__umoddi3+0x117>
  80351b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80351f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  803523:	89 d7                	mov    %edx,%edi
  803525:	89 c6                	mov    %eax,%esi
  803527:	89 ca                	mov    %ecx,%edx
  803529:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80352e:	29 f3                	sub    %esi,%ebx
  803530:	19 fa                	sbb    %edi,%edx
  803532:	89 d0                	mov    %edx,%eax
  803534:	d3 e0                	shl    %cl,%eax
  803536:	89 e9                	mov    %ebp,%ecx
  803538:	d3 eb                	shr    %cl,%ebx
  80353a:	d3 ea                	shr    %cl,%edx
  80353c:	09 d8                	or     %ebx,%eax
  80353e:	83 c4 1c             	add    $0x1c,%esp
  803541:	5b                   	pop    %ebx
  803542:	5e                   	pop    %esi
  803543:	5f                   	pop    %edi
  803544:	5d                   	pop    %ebp
  803545:	c3                   	ret    
  803546:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80354d:	8d 76 00             	lea    0x0(%esi),%esi
  803550:	29 fe                	sub    %edi,%esi
  803552:	19 c3                	sbb    %eax,%ebx
  803554:	89 f2                	mov    %esi,%edx
  803556:	89 d9                	mov    %ebx,%ecx
  803558:	e9 1d ff ff ff       	jmp    80347a <__umoddi3+0x6a>
