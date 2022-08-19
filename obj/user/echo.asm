
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 b7 00 00 00       	call   8000e8 <libmain>
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
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 1c             	sub    $0x1c,%esp
  800040:	8b 7d 08             	mov    0x8(%ebp),%edi
  800043:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800046:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  80004d:	83 ff 01             	cmp    $0x1,%edi
  800050:	7f 07                	jg     800059 <umain+0x26>
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800052:	bb 01 00 00 00       	mov    $0x1,%ebx
  800057:	eb 60                	jmp    8000b9 <umain+0x86>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	68 80 1e 80 00       	push   $0x801e80
  800061:	ff 76 04             	pushl  0x4(%esi)
  800064:	e8 ed 01 00 00       	call   800256 <strcmp>
  800069:	83 c4 10             	add    $0x10,%esp
	nflag = 0;
  80006c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800073:	85 c0                	test   %eax,%eax
  800075:	75 db                	jne    800052 <umain+0x1f>
		argc--;
  800077:	83 ef 01             	sub    $0x1,%edi
		argv++;
  80007a:	83 c6 04             	add    $0x4,%esi
		nflag = 1;
  80007d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  800084:	eb cc                	jmp    800052 <umain+0x1f>
		if (i > 1)
			write(1, " ", 1);
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 01                	push   $0x1
  80008b:	68 83 1e 80 00       	push   $0x801e83
  800090:	6a 01                	push   $0x1
  800092:	e8 a7 0a 00 00       	call   800b3e <write>
  800097:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000a0:	e8 af 00 00 00       	call   800154 <strlen>
  8000a5:	83 c4 0c             	add    $0xc,%esp
  8000a8:	50                   	push   %eax
  8000a9:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ac:	6a 01                	push   $0x1
  8000ae:	e8 8b 0a 00 00       	call   800b3e <write>
	for (i = 1; i < argc; i++) {
  8000b3:	83 c3 01             	add    $0x1,%ebx
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	39 df                	cmp    %ebx,%edi
  8000bb:	7e 07                	jle    8000c4 <umain+0x91>
		if (i > 1)
  8000bd:	83 fb 01             	cmp    $0x1,%ebx
  8000c0:	7f c4                	jg     800086 <umain+0x53>
  8000c2:	eb d6                	jmp    80009a <umain+0x67>
	}
	if (!nflag)
  8000c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c8:	74 08                	je     8000d2 <umain+0x9f>
		write(1, "\n", 1);
}
  8000ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    
		write(1, "\n", 1);
  8000d2:	83 ec 04             	sub    $0x4,%esp
  8000d5:	6a 01                	push   $0x1
  8000d7:	68 93 1f 80 00       	push   $0x801f93
  8000dc:	6a 01                	push   $0x1
  8000de:	e8 5b 0a 00 00       	call   800b3e <write>
  8000e3:	83 c4 10             	add    $0x10,%esp
}
  8000e6:	eb e2                	jmp    8000ca <umain+0x97>

008000e8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e8:	f3 0f 1e fb          	endbr32 
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000f7:	e8 d0 04 00 00       	call   8005cc <sys_getenvid>
	if (id >= 0)
  8000fc:	85 c0                	test   %eax,%eax
  8000fe:	78 12                	js     800112 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800100:	25 ff 03 00 00       	and    $0x3ff,%eax
  800105:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800108:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800112:	85 db                	test   %ebx,%ebx
  800114:	7e 07                	jle    80011d <libmain+0x35>
		binaryname = argv[0];
  800116:	8b 06                	mov    (%esi),%eax
  800118:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011d:	83 ec 08             	sub    $0x8,%esp
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
  800122:	e8 0c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800127:	e8 0a 00 00 00       	call   800136 <exit>
}
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800136:	f3 0f 1e fb          	endbr32 
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800140:	e8 0a 08 00 00       	call   80094f <close_all>
	sys_env_destroy(0);
  800145:	83 ec 0c             	sub    $0xc,%esp
  800148:	6a 00                	push   $0x0
  80014a:	e8 57 04 00 00       	call   8005a6 <sys_env_destroy>
}
  80014f:	83 c4 10             	add    $0x10,%esp
  800152:	c9                   	leave  
  800153:	c3                   	ret    

00800154 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800154:	f3 0f 1e fb          	endbr32 
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80015e:	b8 00 00 00 00       	mov    $0x0,%eax
  800163:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800167:	74 05                	je     80016e <strlen+0x1a>
		n++;
  800169:	83 c0 01             	add    $0x1,%eax
  80016c:	eb f5                	jmp    800163 <strlen+0xf>
	return n;
}
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800170:	f3 0f 1e fb          	endbr32 
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80017d:	b8 00 00 00 00       	mov    $0x0,%eax
  800182:	39 d0                	cmp    %edx,%eax
  800184:	74 0d                	je     800193 <strnlen+0x23>
  800186:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80018a:	74 05                	je     800191 <strnlen+0x21>
		n++;
  80018c:	83 c0 01             	add    $0x1,%eax
  80018f:	eb f1                	jmp    800182 <strnlen+0x12>
  800191:	89 c2                	mov    %eax,%edx
	return n;
}
  800193:	89 d0                	mov    %edx,%eax
  800195:	5d                   	pop    %ebp
  800196:	c3                   	ret    

00800197 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800197:	f3 0f 1e fb          	endbr32 
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	53                   	push   %ebx
  80019f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8001a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8001aa:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8001ae:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8001b1:	83 c0 01             	add    $0x1,%eax
  8001b4:	84 d2                	test   %dl,%dl
  8001b6:	75 f2                	jne    8001aa <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8001b8:	89 c8                	mov    %ecx,%eax
  8001ba:	5b                   	pop    %ebx
  8001bb:	5d                   	pop    %ebp
  8001bc:	c3                   	ret    

008001bd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001bd:	f3 0f 1e fb          	endbr32 
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	53                   	push   %ebx
  8001c5:	83 ec 10             	sub    $0x10,%esp
  8001c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001cb:	53                   	push   %ebx
  8001cc:	e8 83 ff ff ff       	call   800154 <strlen>
  8001d1:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8001d4:	ff 75 0c             	pushl  0xc(%ebp)
  8001d7:	01 d8                	add    %ebx,%eax
  8001d9:	50                   	push   %eax
  8001da:	e8 b8 ff ff ff       	call   800197 <strcpy>
	return dst;
}
  8001df:	89 d8                	mov    %ebx,%eax
  8001e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001e6:	f3 0f 1e fb          	endbr32 
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	56                   	push   %esi
  8001ee:	53                   	push   %ebx
  8001ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8001f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f5:	89 f3                	mov    %esi,%ebx
  8001f7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	39 d8                	cmp    %ebx,%eax
  8001fe:	74 11                	je     800211 <strncpy+0x2b>
		*dst++ = *src;
  800200:	83 c0 01             	add    $0x1,%eax
  800203:	0f b6 0a             	movzbl (%edx),%ecx
  800206:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800209:	80 f9 01             	cmp    $0x1,%cl
  80020c:	83 da ff             	sbb    $0xffffffff,%edx
  80020f:	eb eb                	jmp    8001fc <strncpy+0x16>
	}
	return ret;
}
  800211:	89 f0                	mov    %esi,%eax
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5d                   	pop    %ebp
  800216:	c3                   	ret    

00800217 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800217:	f3 0f 1e fb          	endbr32 
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	56                   	push   %esi
  80021f:	53                   	push   %ebx
  800220:	8b 75 08             	mov    0x8(%ebp),%esi
  800223:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800226:	8b 55 10             	mov    0x10(%ebp),%edx
  800229:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80022b:	85 d2                	test   %edx,%edx
  80022d:	74 21                	je     800250 <strlcpy+0x39>
  80022f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800233:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800235:	39 c2                	cmp    %eax,%edx
  800237:	74 14                	je     80024d <strlcpy+0x36>
  800239:	0f b6 19             	movzbl (%ecx),%ebx
  80023c:	84 db                	test   %bl,%bl
  80023e:	74 0b                	je     80024b <strlcpy+0x34>
			*dst++ = *src++;
  800240:	83 c1 01             	add    $0x1,%ecx
  800243:	83 c2 01             	add    $0x1,%edx
  800246:	88 5a ff             	mov    %bl,-0x1(%edx)
  800249:	eb ea                	jmp    800235 <strlcpy+0x1e>
  80024b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80024d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800250:	29 f0                	sub    %esi,%eax
}
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800256:	f3 0f 1e fb          	endbr32 
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
  80025d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800260:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800263:	0f b6 01             	movzbl (%ecx),%eax
  800266:	84 c0                	test   %al,%al
  800268:	74 0c                	je     800276 <strcmp+0x20>
  80026a:	3a 02                	cmp    (%edx),%al
  80026c:	75 08                	jne    800276 <strcmp+0x20>
		p++, q++;
  80026e:	83 c1 01             	add    $0x1,%ecx
  800271:	83 c2 01             	add    $0x1,%edx
  800274:	eb ed                	jmp    800263 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800276:	0f b6 c0             	movzbl %al,%eax
  800279:	0f b6 12             	movzbl (%edx),%edx
  80027c:	29 d0                	sub    %edx,%eax
}
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    

00800280 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800280:	f3 0f 1e fb          	endbr32 
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	53                   	push   %ebx
  800288:	8b 45 08             	mov    0x8(%ebp),%eax
  80028b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80028e:	89 c3                	mov    %eax,%ebx
  800290:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800293:	eb 06                	jmp    80029b <strncmp+0x1b>
		n--, p++, q++;
  800295:	83 c0 01             	add    $0x1,%eax
  800298:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80029b:	39 d8                	cmp    %ebx,%eax
  80029d:	74 16                	je     8002b5 <strncmp+0x35>
  80029f:	0f b6 08             	movzbl (%eax),%ecx
  8002a2:	84 c9                	test   %cl,%cl
  8002a4:	74 04                	je     8002aa <strncmp+0x2a>
  8002a6:	3a 0a                	cmp    (%edx),%cl
  8002a8:	74 eb                	je     800295 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8002aa:	0f b6 00             	movzbl (%eax),%eax
  8002ad:	0f b6 12             	movzbl (%edx),%edx
  8002b0:	29 d0                	sub    %edx,%eax
}
  8002b2:	5b                   	pop    %ebx
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    
		return 0;
  8002b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ba:	eb f6                	jmp    8002b2 <strncmp+0x32>

008002bc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8002bc:	f3 0f 1e fb          	endbr32 
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002ca:	0f b6 10             	movzbl (%eax),%edx
  8002cd:	84 d2                	test   %dl,%dl
  8002cf:	74 09                	je     8002da <strchr+0x1e>
		if (*s == c)
  8002d1:	38 ca                	cmp    %cl,%dl
  8002d3:	74 0a                	je     8002df <strchr+0x23>
	for (; *s; s++)
  8002d5:	83 c0 01             	add    $0x1,%eax
  8002d8:	eb f0                	jmp    8002ca <strchr+0xe>
			return (char *) s;
	return 0;
  8002da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    

008002e1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002e1:	f3 0f 1e fb          	endbr32 
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002eb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002ef:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002f2:	38 ca                	cmp    %cl,%dl
  8002f4:	74 09                	je     8002ff <strfind+0x1e>
  8002f6:	84 d2                	test   %dl,%dl
  8002f8:	74 05                	je     8002ff <strfind+0x1e>
	for (; *s; s++)
  8002fa:	83 c0 01             	add    $0x1,%eax
  8002fd:	eb f0                	jmp    8002ef <strfind+0xe>
			break;
	return (char *) s;
}
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800301:	f3 0f 1e fb          	endbr32 
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	8b 55 08             	mov    0x8(%ebp),%edx
  80030e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800311:	85 c9                	test   %ecx,%ecx
  800313:	74 33                	je     800348 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800315:	89 d0                	mov    %edx,%eax
  800317:	09 c8                	or     %ecx,%eax
  800319:	a8 03                	test   $0x3,%al
  80031b:	75 23                	jne    800340 <memset+0x3f>
		c &= 0xFF;
  80031d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800321:	89 d8                	mov    %ebx,%eax
  800323:	c1 e0 08             	shl    $0x8,%eax
  800326:	89 df                	mov    %ebx,%edi
  800328:	c1 e7 18             	shl    $0x18,%edi
  80032b:	89 de                	mov    %ebx,%esi
  80032d:	c1 e6 10             	shl    $0x10,%esi
  800330:	09 f7                	or     %esi,%edi
  800332:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800334:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800337:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800339:	89 d7                	mov    %edx,%edi
  80033b:	fc                   	cld    
  80033c:	f3 ab                	rep stos %eax,%es:(%edi)
  80033e:	eb 08                	jmp    800348 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800340:	89 d7                	mov    %edx,%edi
  800342:	8b 45 0c             	mov    0xc(%ebp),%eax
  800345:	fc                   	cld    
  800346:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800348:	89 d0                	mov    %edx,%eax
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80034f:	f3 0f 1e fb          	endbr32 
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	57                   	push   %edi
  800357:	56                   	push   %esi
  800358:	8b 45 08             	mov    0x8(%ebp),%eax
  80035b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80035e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800361:	39 c6                	cmp    %eax,%esi
  800363:	73 32                	jae    800397 <memmove+0x48>
  800365:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800368:	39 c2                	cmp    %eax,%edx
  80036a:	76 2b                	jbe    800397 <memmove+0x48>
		s += n;
		d += n;
  80036c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80036f:	89 fe                	mov    %edi,%esi
  800371:	09 ce                	or     %ecx,%esi
  800373:	09 d6                	or     %edx,%esi
  800375:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80037b:	75 0e                	jne    80038b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80037d:	83 ef 04             	sub    $0x4,%edi
  800380:	8d 72 fc             	lea    -0x4(%edx),%esi
  800383:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800386:	fd                   	std    
  800387:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800389:	eb 09                	jmp    800394 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80038b:	83 ef 01             	sub    $0x1,%edi
  80038e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800391:	fd                   	std    
  800392:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800394:	fc                   	cld    
  800395:	eb 1a                	jmp    8003b1 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800397:	89 c2                	mov    %eax,%edx
  800399:	09 ca                	or     %ecx,%edx
  80039b:	09 f2                	or     %esi,%edx
  80039d:	f6 c2 03             	test   $0x3,%dl
  8003a0:	75 0a                	jne    8003ac <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8003a2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8003a5:	89 c7                	mov    %eax,%edi
  8003a7:	fc                   	cld    
  8003a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8003aa:	eb 05                	jmp    8003b1 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8003ac:	89 c7                	mov    %eax,%edi
  8003ae:	fc                   	cld    
  8003af:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8003b1:	5e                   	pop    %esi
  8003b2:	5f                   	pop    %edi
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    

008003b5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8003b5:	f3 0f 1e fb          	endbr32 
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8003bf:	ff 75 10             	pushl  0x10(%ebp)
  8003c2:	ff 75 0c             	pushl  0xc(%ebp)
  8003c5:	ff 75 08             	pushl  0x8(%ebp)
  8003c8:	e8 82 ff ff ff       	call   80034f <memmove>
}
  8003cd:	c9                   	leave  
  8003ce:	c3                   	ret    

008003cf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8003cf:	f3 0f 1e fb          	endbr32 
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	56                   	push   %esi
  8003d7:	53                   	push   %ebx
  8003d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003de:	89 c6                	mov    %eax,%esi
  8003e0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003e3:	39 f0                	cmp    %esi,%eax
  8003e5:	74 1c                	je     800403 <memcmp+0x34>
		if (*s1 != *s2)
  8003e7:	0f b6 08             	movzbl (%eax),%ecx
  8003ea:	0f b6 1a             	movzbl (%edx),%ebx
  8003ed:	38 d9                	cmp    %bl,%cl
  8003ef:	75 08                	jne    8003f9 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8003f1:	83 c0 01             	add    $0x1,%eax
  8003f4:	83 c2 01             	add    $0x1,%edx
  8003f7:	eb ea                	jmp    8003e3 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8003f9:	0f b6 c1             	movzbl %cl,%eax
  8003fc:	0f b6 db             	movzbl %bl,%ebx
  8003ff:	29 d8                	sub    %ebx,%eax
  800401:	eb 05                	jmp    800408 <memcmp+0x39>
	}

	return 0;
  800403:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800408:	5b                   	pop    %ebx
  800409:	5e                   	pop    %esi
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80040c:	f3 0f 1e fb          	endbr32 
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	8b 45 08             	mov    0x8(%ebp),%eax
  800416:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800419:	89 c2                	mov    %eax,%edx
  80041b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80041e:	39 d0                	cmp    %edx,%eax
  800420:	73 09                	jae    80042b <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800422:	38 08                	cmp    %cl,(%eax)
  800424:	74 05                	je     80042b <memfind+0x1f>
	for (; s < ends; s++)
  800426:	83 c0 01             	add    $0x1,%eax
  800429:	eb f3                	jmp    80041e <memfind+0x12>
			break;
	return (void *) s;
}
  80042b:	5d                   	pop    %ebp
  80042c:	c3                   	ret    

0080042d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80042d:	f3 0f 1e fb          	endbr32 
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	57                   	push   %edi
  800435:	56                   	push   %esi
  800436:	53                   	push   %ebx
  800437:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80043d:	eb 03                	jmp    800442 <strtol+0x15>
		s++;
  80043f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800442:	0f b6 01             	movzbl (%ecx),%eax
  800445:	3c 20                	cmp    $0x20,%al
  800447:	74 f6                	je     80043f <strtol+0x12>
  800449:	3c 09                	cmp    $0x9,%al
  80044b:	74 f2                	je     80043f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  80044d:	3c 2b                	cmp    $0x2b,%al
  80044f:	74 2a                	je     80047b <strtol+0x4e>
	int neg = 0;
  800451:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800456:	3c 2d                	cmp    $0x2d,%al
  800458:	74 2b                	je     800485 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80045a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800460:	75 0f                	jne    800471 <strtol+0x44>
  800462:	80 39 30             	cmpb   $0x30,(%ecx)
  800465:	74 28                	je     80048f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800467:	85 db                	test   %ebx,%ebx
  800469:	b8 0a 00 00 00       	mov    $0xa,%eax
  80046e:	0f 44 d8             	cmove  %eax,%ebx
  800471:	b8 00 00 00 00       	mov    $0x0,%eax
  800476:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800479:	eb 46                	jmp    8004c1 <strtol+0x94>
		s++;
  80047b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80047e:	bf 00 00 00 00       	mov    $0x0,%edi
  800483:	eb d5                	jmp    80045a <strtol+0x2d>
		s++, neg = 1;
  800485:	83 c1 01             	add    $0x1,%ecx
  800488:	bf 01 00 00 00       	mov    $0x1,%edi
  80048d:	eb cb                	jmp    80045a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80048f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800493:	74 0e                	je     8004a3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800495:	85 db                	test   %ebx,%ebx
  800497:	75 d8                	jne    800471 <strtol+0x44>
		s++, base = 8;
  800499:	83 c1 01             	add    $0x1,%ecx
  80049c:	bb 08 00 00 00       	mov    $0x8,%ebx
  8004a1:	eb ce                	jmp    800471 <strtol+0x44>
		s += 2, base = 16;
  8004a3:	83 c1 02             	add    $0x2,%ecx
  8004a6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8004ab:	eb c4                	jmp    800471 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8004ad:	0f be d2             	movsbl %dl,%edx
  8004b0:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8004b3:	3b 55 10             	cmp    0x10(%ebp),%edx
  8004b6:	7d 3a                	jge    8004f2 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8004b8:	83 c1 01             	add    $0x1,%ecx
  8004bb:	0f af 45 10          	imul   0x10(%ebp),%eax
  8004bf:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8004c1:	0f b6 11             	movzbl (%ecx),%edx
  8004c4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8004c7:	89 f3                	mov    %esi,%ebx
  8004c9:	80 fb 09             	cmp    $0x9,%bl
  8004cc:	76 df                	jbe    8004ad <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8004ce:	8d 72 9f             	lea    -0x61(%edx),%esi
  8004d1:	89 f3                	mov    %esi,%ebx
  8004d3:	80 fb 19             	cmp    $0x19,%bl
  8004d6:	77 08                	ja     8004e0 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8004d8:	0f be d2             	movsbl %dl,%edx
  8004db:	83 ea 57             	sub    $0x57,%edx
  8004de:	eb d3                	jmp    8004b3 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  8004e0:	8d 72 bf             	lea    -0x41(%edx),%esi
  8004e3:	89 f3                	mov    %esi,%ebx
  8004e5:	80 fb 19             	cmp    $0x19,%bl
  8004e8:	77 08                	ja     8004f2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8004ea:	0f be d2             	movsbl %dl,%edx
  8004ed:	83 ea 37             	sub    $0x37,%edx
  8004f0:	eb c1                	jmp    8004b3 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  8004f2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004f6:	74 05                	je     8004fd <strtol+0xd0>
		*endptr = (char *) s;
  8004f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004fb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8004fd:	89 c2                	mov    %eax,%edx
  8004ff:	f7 da                	neg    %edx
  800501:	85 ff                	test   %edi,%edi
  800503:	0f 45 c2             	cmovne %edx,%eax
}
  800506:	5b                   	pop    %ebx
  800507:	5e                   	pop    %esi
  800508:	5f                   	pop    %edi
  800509:	5d                   	pop    %ebp
  80050a:	c3                   	ret    

0080050b <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80050b:	55                   	push   %ebp
  80050c:	89 e5                	mov    %esp,%ebp
  80050e:	57                   	push   %edi
  80050f:	56                   	push   %esi
  800510:	53                   	push   %ebx
  800511:	83 ec 1c             	sub    $0x1c,%esp
  800514:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800517:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80051a:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80051c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800522:	8b 7d 10             	mov    0x10(%ebp),%edi
  800525:	8b 75 14             	mov    0x14(%ebp),%esi
  800528:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80052a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80052e:	74 04                	je     800534 <syscall+0x29>
  800530:	85 c0                	test   %eax,%eax
  800532:	7f 08                	jg     80053c <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800534:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800537:	5b                   	pop    %ebx
  800538:	5e                   	pop    %esi
  800539:	5f                   	pop    %edi
  80053a:	5d                   	pop    %ebp
  80053b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80053c:	83 ec 0c             	sub    $0xc,%esp
  80053f:	50                   	push   %eax
  800540:	ff 75 e0             	pushl  -0x20(%ebp)
  800543:	68 8f 1e 80 00       	push   $0x801e8f
  800548:	6a 23                	push   $0x23
  80054a:	68 ac 1e 80 00       	push   $0x801eac
  80054f:	e8 76 0f 00 00       	call   8014ca <_panic>

00800554 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800554:	f3 0f 1e fb          	endbr32 
  800558:	55                   	push   %ebp
  800559:	89 e5                	mov    %esp,%ebp
  80055b:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80055e:	6a 00                	push   $0x0
  800560:	6a 00                	push   $0x0
  800562:	6a 00                	push   $0x0
  800564:	ff 75 0c             	pushl  0xc(%ebp)
  800567:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80056a:	ba 00 00 00 00       	mov    $0x0,%edx
  80056f:	b8 00 00 00 00       	mov    $0x0,%eax
  800574:	e8 92 ff ff ff       	call   80050b <syscall>
}
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	c9                   	leave  
  80057d:	c3                   	ret    

0080057e <sys_cgetc>:

int
sys_cgetc(void)
{
  80057e:	f3 0f 1e fb          	endbr32 
  800582:	55                   	push   %ebp
  800583:	89 e5                	mov    %esp,%ebp
  800585:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800588:	6a 00                	push   $0x0
  80058a:	6a 00                	push   $0x0
  80058c:	6a 00                	push   $0x0
  80058e:	6a 00                	push   $0x0
  800590:	b9 00 00 00 00       	mov    $0x0,%ecx
  800595:	ba 00 00 00 00       	mov    $0x0,%edx
  80059a:	b8 01 00 00 00       	mov    $0x1,%eax
  80059f:	e8 67 ff ff ff       	call   80050b <syscall>
}
  8005a4:	c9                   	leave  
  8005a5:	c3                   	ret    

008005a6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8005a6:	f3 0f 1e fb          	endbr32 
  8005aa:	55                   	push   %ebp
  8005ab:	89 e5                	mov    %esp,%ebp
  8005ad:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8005b0:	6a 00                	push   $0x0
  8005b2:	6a 00                	push   $0x0
  8005b4:	6a 00                	push   $0x0
  8005b6:	6a 00                	push   $0x0
  8005b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005bb:	ba 01 00 00 00       	mov    $0x1,%edx
  8005c0:	b8 03 00 00 00       	mov    $0x3,%eax
  8005c5:	e8 41 ff ff ff       	call   80050b <syscall>
}
  8005ca:	c9                   	leave  
  8005cb:	c3                   	ret    

008005cc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8005cc:	f3 0f 1e fb          	endbr32 
  8005d0:	55                   	push   %ebp
  8005d1:	89 e5                	mov    %esp,%ebp
  8005d3:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8005d6:	6a 00                	push   $0x0
  8005d8:	6a 00                	push   $0x0
  8005da:	6a 00                	push   $0x0
  8005dc:	6a 00                	push   $0x0
  8005de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e8:	b8 02 00 00 00       	mov    $0x2,%eax
  8005ed:	e8 19 ff ff ff       	call   80050b <syscall>
}
  8005f2:	c9                   	leave  
  8005f3:	c3                   	ret    

008005f4 <sys_yield>:

void
sys_yield(void)
{
  8005f4:	f3 0f 1e fb          	endbr32 
  8005f8:	55                   	push   %ebp
  8005f9:	89 e5                	mov    %esp,%ebp
  8005fb:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8005fe:	6a 00                	push   $0x0
  800600:	6a 00                	push   $0x0
  800602:	6a 00                	push   $0x0
  800604:	6a 00                	push   $0x0
  800606:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060b:	ba 00 00 00 00       	mov    $0x0,%edx
  800610:	b8 0b 00 00 00       	mov    $0xb,%eax
  800615:	e8 f1 fe ff ff       	call   80050b <syscall>
}
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	c9                   	leave  
  80061e:	c3                   	ret    

0080061f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80061f:	f3 0f 1e fb          	endbr32 
  800623:	55                   	push   %ebp
  800624:	89 e5                	mov    %esp,%ebp
  800626:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800629:	6a 00                	push   $0x0
  80062b:	6a 00                	push   $0x0
  80062d:	ff 75 10             	pushl  0x10(%ebp)
  800630:	ff 75 0c             	pushl  0xc(%ebp)
  800633:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800636:	ba 01 00 00 00       	mov    $0x1,%edx
  80063b:	b8 04 00 00 00       	mov    $0x4,%eax
  800640:	e8 c6 fe ff ff       	call   80050b <syscall>
}
  800645:	c9                   	leave  
  800646:	c3                   	ret    

00800647 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800647:	f3 0f 1e fb          	endbr32 
  80064b:	55                   	push   %ebp
  80064c:	89 e5                	mov    %esp,%ebp
  80064e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800651:	ff 75 18             	pushl  0x18(%ebp)
  800654:	ff 75 14             	pushl  0x14(%ebp)
  800657:	ff 75 10             	pushl  0x10(%ebp)
  80065a:	ff 75 0c             	pushl  0xc(%ebp)
  80065d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800660:	ba 01 00 00 00       	mov    $0x1,%edx
  800665:	b8 05 00 00 00       	mov    $0x5,%eax
  80066a:	e8 9c fe ff ff       	call   80050b <syscall>
}
  80066f:	c9                   	leave  
  800670:	c3                   	ret    

00800671 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800671:	f3 0f 1e fb          	endbr32 
  800675:	55                   	push   %ebp
  800676:	89 e5                	mov    %esp,%ebp
  800678:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80067b:	6a 00                	push   $0x0
  80067d:	6a 00                	push   $0x0
  80067f:	6a 00                	push   $0x0
  800681:	ff 75 0c             	pushl  0xc(%ebp)
  800684:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800687:	ba 01 00 00 00       	mov    $0x1,%edx
  80068c:	b8 06 00 00 00       	mov    $0x6,%eax
  800691:	e8 75 fe ff ff       	call   80050b <syscall>
}
  800696:	c9                   	leave  
  800697:	c3                   	ret    

00800698 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800698:	f3 0f 1e fb          	endbr32 
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8006a2:	6a 00                	push   $0x0
  8006a4:	6a 00                	push   $0x0
  8006a6:	6a 00                	push   $0x0
  8006a8:	ff 75 0c             	pushl  0xc(%ebp)
  8006ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ae:	ba 01 00 00 00       	mov    $0x1,%edx
  8006b3:	b8 08 00 00 00       	mov    $0x8,%eax
  8006b8:	e8 4e fe ff ff       	call   80050b <syscall>
}
  8006bd:	c9                   	leave  
  8006be:	c3                   	ret    

008006bf <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8006bf:	f3 0f 1e fb          	endbr32 
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  8006c9:	6a 00                	push   $0x0
  8006cb:	6a 00                	push   $0x0
  8006cd:	6a 00                	push   $0x0
  8006cf:	ff 75 0c             	pushl  0xc(%ebp)
  8006d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d5:	ba 01 00 00 00       	mov    $0x1,%edx
  8006da:	b8 09 00 00 00       	mov    $0x9,%eax
  8006df:	e8 27 fe ff ff       	call   80050b <syscall>
}
  8006e4:	c9                   	leave  
  8006e5:	c3                   	ret    

008006e6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006e6:	f3 0f 1e fb          	endbr32 
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8006f0:	6a 00                	push   $0x0
  8006f2:	6a 00                	push   $0x0
  8006f4:	6a 00                	push   $0x0
  8006f6:	ff 75 0c             	pushl  0xc(%ebp)
  8006f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fc:	ba 01 00 00 00       	mov    $0x1,%edx
  800701:	b8 0a 00 00 00       	mov    $0xa,%eax
  800706:	e8 00 fe ff ff       	call   80050b <syscall>
}
  80070b:	c9                   	leave  
  80070c:	c3                   	ret    

0080070d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80070d:	f3 0f 1e fb          	endbr32 
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800717:	6a 00                	push   $0x0
  800719:	ff 75 14             	pushl  0x14(%ebp)
  80071c:	ff 75 10             	pushl  0x10(%ebp)
  80071f:	ff 75 0c             	pushl  0xc(%ebp)
  800722:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800725:	ba 00 00 00 00       	mov    $0x0,%edx
  80072a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80072f:	e8 d7 fd ff ff       	call   80050b <syscall>
}
  800734:	c9                   	leave  
  800735:	c3                   	ret    

00800736 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800736:	f3 0f 1e fb          	endbr32 
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800740:	6a 00                	push   $0x0
  800742:	6a 00                	push   $0x0
  800744:	6a 00                	push   $0x0
  800746:	6a 00                	push   $0x0
  800748:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074b:	ba 01 00 00 00       	mov    $0x1,%edx
  800750:	b8 0d 00 00 00       	mov    $0xd,%eax
  800755:	e8 b1 fd ff ff       	call   80050b <syscall>
}
  80075a:	c9                   	leave  
  80075b:	c3                   	ret    

0080075c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80075c:	f3 0f 1e fb          	endbr32 
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800763:	8b 45 08             	mov    0x8(%ebp),%eax
  800766:	05 00 00 00 30       	add    $0x30000000,%eax
  80076b:	c1 e8 0c             	shr    $0xc,%eax
}
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800770:	f3 0f 1e fb          	endbr32 
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  80077a:	ff 75 08             	pushl  0x8(%ebp)
  80077d:	e8 da ff ff ff       	call   80075c <fd2num>
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	c1 e0 0c             	shl    $0xc,%eax
  800788:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80078d:	c9                   	leave  
  80078e:	c3                   	ret    

0080078f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80078f:	f3 0f 1e fb          	endbr32 
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80079b:	89 c2                	mov    %eax,%edx
  80079d:	c1 ea 16             	shr    $0x16,%edx
  8007a0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007a7:	f6 c2 01             	test   $0x1,%dl
  8007aa:	74 2d                	je     8007d9 <fd_alloc+0x4a>
  8007ac:	89 c2                	mov    %eax,%edx
  8007ae:	c1 ea 0c             	shr    $0xc,%edx
  8007b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007b8:	f6 c2 01             	test   $0x1,%dl
  8007bb:	74 1c                	je     8007d9 <fd_alloc+0x4a>
  8007bd:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8007c2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8007c7:	75 d2                	jne    80079b <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8007c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8007d2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8007d7:	eb 0a                	jmp    8007e3 <fd_alloc+0x54>
			*fd_store = fd;
  8007d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007dc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8007e5:	f3 0f 1e fb          	endbr32 
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8007ef:	83 f8 1f             	cmp    $0x1f,%eax
  8007f2:	77 30                	ja     800824 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8007f4:	c1 e0 0c             	shl    $0xc,%eax
  8007f7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8007fc:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800802:	f6 c2 01             	test   $0x1,%dl
  800805:	74 24                	je     80082b <fd_lookup+0x46>
  800807:	89 c2                	mov    %eax,%edx
  800809:	c1 ea 0c             	shr    $0xc,%edx
  80080c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800813:	f6 c2 01             	test   $0x1,%dl
  800816:	74 1a                	je     800832 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800818:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081b:	89 02                	mov    %eax,(%edx)
	return 0;
  80081d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    
		return -E_INVAL;
  800824:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800829:	eb f7                	jmp    800822 <fd_lookup+0x3d>
		return -E_INVAL;
  80082b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800830:	eb f0                	jmp    800822 <fd_lookup+0x3d>
  800832:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800837:	eb e9                	jmp    800822 <fd_lookup+0x3d>

00800839 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800839:	f3 0f 1e fb          	endbr32 
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	83 ec 08             	sub    $0x8,%esp
  800843:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800846:	ba 38 1f 80 00       	mov    $0x801f38,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80084b:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800850:	39 08                	cmp    %ecx,(%eax)
  800852:	74 33                	je     800887 <dev_lookup+0x4e>
  800854:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800857:	8b 02                	mov    (%edx),%eax
  800859:	85 c0                	test   %eax,%eax
  80085b:	75 f3                	jne    800850 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80085d:	a1 04 40 80 00       	mov    0x804004,%eax
  800862:	8b 40 48             	mov    0x48(%eax),%eax
  800865:	83 ec 04             	sub    $0x4,%esp
  800868:	51                   	push   %ecx
  800869:	50                   	push   %eax
  80086a:	68 bc 1e 80 00       	push   $0x801ebc
  80086f:	e8 3d 0d 00 00       	call   8015b1 <cprintf>
	*dev = 0;
  800874:	8b 45 0c             	mov    0xc(%ebp),%eax
  800877:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80087d:	83 c4 10             	add    $0x10,%esp
  800880:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800885:	c9                   	leave  
  800886:	c3                   	ret    
			*dev = devtab[i];
  800887:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80088c:	b8 00 00 00 00       	mov    $0x0,%eax
  800891:	eb f2                	jmp    800885 <dev_lookup+0x4c>

00800893 <fd_close>:
{
  800893:	f3 0f 1e fb          	endbr32 
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	57                   	push   %edi
  80089b:	56                   	push   %esi
  80089c:	53                   	push   %ebx
  80089d:	83 ec 28             	sub    $0x28,%esp
  8008a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008a6:	56                   	push   %esi
  8008a7:	e8 b0 fe ff ff       	call   80075c <fd2num>
  8008ac:	83 c4 08             	add    $0x8,%esp
  8008af:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8008b2:	52                   	push   %edx
  8008b3:	50                   	push   %eax
  8008b4:	e8 2c ff ff ff       	call   8007e5 <fd_lookup>
  8008b9:	89 c3                	mov    %eax,%ebx
  8008bb:	83 c4 10             	add    $0x10,%esp
  8008be:	85 c0                	test   %eax,%eax
  8008c0:	78 05                	js     8008c7 <fd_close+0x34>
	    || fd != fd2)
  8008c2:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8008c5:	74 16                	je     8008dd <fd_close+0x4a>
		return (must_exist ? r : 0);
  8008c7:	89 f8                	mov    %edi,%eax
  8008c9:	84 c0                	test   %al,%al
  8008cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d0:	0f 44 d8             	cmove  %eax,%ebx
}
  8008d3:	89 d8                	mov    %ebx,%eax
  8008d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008d8:	5b                   	pop    %ebx
  8008d9:	5e                   	pop    %esi
  8008da:	5f                   	pop    %edi
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008dd:	83 ec 08             	sub    $0x8,%esp
  8008e0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8008e3:	50                   	push   %eax
  8008e4:	ff 36                	pushl  (%esi)
  8008e6:	e8 4e ff ff ff       	call   800839 <dev_lookup>
  8008eb:	89 c3                	mov    %eax,%ebx
  8008ed:	83 c4 10             	add    $0x10,%esp
  8008f0:	85 c0                	test   %eax,%eax
  8008f2:	78 1a                	js     80090e <fd_close+0x7b>
		if (dev->dev_close)
  8008f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008f7:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8008fa:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8008ff:	85 c0                	test   %eax,%eax
  800901:	74 0b                	je     80090e <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800903:	83 ec 0c             	sub    $0xc,%esp
  800906:	56                   	push   %esi
  800907:	ff d0                	call   *%eax
  800909:	89 c3                	mov    %eax,%ebx
  80090b:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80090e:	83 ec 08             	sub    $0x8,%esp
  800911:	56                   	push   %esi
  800912:	6a 00                	push   $0x0
  800914:	e8 58 fd ff ff       	call   800671 <sys_page_unmap>
	return r;
  800919:	83 c4 10             	add    $0x10,%esp
  80091c:	eb b5                	jmp    8008d3 <fd_close+0x40>

0080091e <close>:

int
close(int fdnum)
{
  80091e:	f3 0f 1e fb          	endbr32 
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800928:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80092b:	50                   	push   %eax
  80092c:	ff 75 08             	pushl  0x8(%ebp)
  80092f:	e8 b1 fe ff ff       	call   8007e5 <fd_lookup>
  800934:	83 c4 10             	add    $0x10,%esp
  800937:	85 c0                	test   %eax,%eax
  800939:	79 02                	jns    80093d <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80093b:	c9                   	leave  
  80093c:	c3                   	ret    
		return fd_close(fd, 1);
  80093d:	83 ec 08             	sub    $0x8,%esp
  800940:	6a 01                	push   $0x1
  800942:	ff 75 f4             	pushl  -0xc(%ebp)
  800945:	e8 49 ff ff ff       	call   800893 <fd_close>
  80094a:	83 c4 10             	add    $0x10,%esp
  80094d:	eb ec                	jmp    80093b <close+0x1d>

0080094f <close_all>:

void
close_all(void)
{
  80094f:	f3 0f 1e fb          	endbr32 
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	53                   	push   %ebx
  800957:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80095a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80095f:	83 ec 0c             	sub    $0xc,%esp
  800962:	53                   	push   %ebx
  800963:	e8 b6 ff ff ff       	call   80091e <close>
	for (i = 0; i < MAXFD; i++)
  800968:	83 c3 01             	add    $0x1,%ebx
  80096b:	83 c4 10             	add    $0x10,%esp
  80096e:	83 fb 20             	cmp    $0x20,%ebx
  800971:	75 ec                	jne    80095f <close_all+0x10>
}
  800973:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800978:	f3 0f 1e fb          	endbr32 
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	57                   	push   %edi
  800980:	56                   	push   %esi
  800981:	53                   	push   %ebx
  800982:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800985:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800988:	50                   	push   %eax
  800989:	ff 75 08             	pushl  0x8(%ebp)
  80098c:	e8 54 fe ff ff       	call   8007e5 <fd_lookup>
  800991:	89 c3                	mov    %eax,%ebx
  800993:	83 c4 10             	add    $0x10,%esp
  800996:	85 c0                	test   %eax,%eax
  800998:	0f 88 81 00 00 00    	js     800a1f <dup+0xa7>
		return r;
	close(newfdnum);
  80099e:	83 ec 0c             	sub    $0xc,%esp
  8009a1:	ff 75 0c             	pushl  0xc(%ebp)
  8009a4:	e8 75 ff ff ff       	call   80091e <close>

	newfd = INDEX2FD(newfdnum);
  8009a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ac:	c1 e6 0c             	shl    $0xc,%esi
  8009af:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8009b5:	83 c4 04             	add    $0x4,%esp
  8009b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009bb:	e8 b0 fd ff ff       	call   800770 <fd2data>
  8009c0:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8009c2:	89 34 24             	mov    %esi,(%esp)
  8009c5:	e8 a6 fd ff ff       	call   800770 <fd2data>
  8009ca:	83 c4 10             	add    $0x10,%esp
  8009cd:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8009cf:	89 d8                	mov    %ebx,%eax
  8009d1:	c1 e8 16             	shr    $0x16,%eax
  8009d4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8009db:	a8 01                	test   $0x1,%al
  8009dd:	74 11                	je     8009f0 <dup+0x78>
  8009df:	89 d8                	mov    %ebx,%eax
  8009e1:	c1 e8 0c             	shr    $0xc,%eax
  8009e4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8009eb:	f6 c2 01             	test   $0x1,%dl
  8009ee:	75 39                	jne    800a29 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8009f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009f3:	89 d0                	mov    %edx,%eax
  8009f5:	c1 e8 0c             	shr    $0xc,%eax
  8009f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009ff:	83 ec 0c             	sub    $0xc,%esp
  800a02:	25 07 0e 00 00       	and    $0xe07,%eax
  800a07:	50                   	push   %eax
  800a08:	56                   	push   %esi
  800a09:	6a 00                	push   $0x0
  800a0b:	52                   	push   %edx
  800a0c:	6a 00                	push   $0x0
  800a0e:	e8 34 fc ff ff       	call   800647 <sys_page_map>
  800a13:	89 c3                	mov    %eax,%ebx
  800a15:	83 c4 20             	add    $0x20,%esp
  800a18:	85 c0                	test   %eax,%eax
  800a1a:	78 31                	js     800a4d <dup+0xd5>
		goto err;

	return newfdnum;
  800a1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800a1f:	89 d8                	mov    %ebx,%eax
  800a21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a24:	5b                   	pop    %ebx
  800a25:	5e                   	pop    %esi
  800a26:	5f                   	pop    %edi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a29:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a30:	83 ec 0c             	sub    $0xc,%esp
  800a33:	25 07 0e 00 00       	and    $0xe07,%eax
  800a38:	50                   	push   %eax
  800a39:	57                   	push   %edi
  800a3a:	6a 00                	push   $0x0
  800a3c:	53                   	push   %ebx
  800a3d:	6a 00                	push   $0x0
  800a3f:	e8 03 fc ff ff       	call   800647 <sys_page_map>
  800a44:	89 c3                	mov    %eax,%ebx
  800a46:	83 c4 20             	add    $0x20,%esp
  800a49:	85 c0                	test   %eax,%eax
  800a4b:	79 a3                	jns    8009f0 <dup+0x78>
	sys_page_unmap(0, newfd);
  800a4d:	83 ec 08             	sub    $0x8,%esp
  800a50:	56                   	push   %esi
  800a51:	6a 00                	push   $0x0
  800a53:	e8 19 fc ff ff       	call   800671 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a58:	83 c4 08             	add    $0x8,%esp
  800a5b:	57                   	push   %edi
  800a5c:	6a 00                	push   $0x0
  800a5e:	e8 0e fc ff ff       	call   800671 <sys_page_unmap>
	return r;
  800a63:	83 c4 10             	add    $0x10,%esp
  800a66:	eb b7                	jmp    800a1f <dup+0xa7>

00800a68 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a68:	f3 0f 1e fb          	endbr32 
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	53                   	push   %ebx
  800a70:	83 ec 1c             	sub    $0x1c,%esp
  800a73:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a76:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a79:	50                   	push   %eax
  800a7a:	53                   	push   %ebx
  800a7b:	e8 65 fd ff ff       	call   8007e5 <fd_lookup>
  800a80:	83 c4 10             	add    $0x10,%esp
  800a83:	85 c0                	test   %eax,%eax
  800a85:	78 3f                	js     800ac6 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a87:	83 ec 08             	sub    $0x8,%esp
  800a8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a8d:	50                   	push   %eax
  800a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a91:	ff 30                	pushl  (%eax)
  800a93:	e8 a1 fd ff ff       	call   800839 <dev_lookup>
  800a98:	83 c4 10             	add    $0x10,%esp
  800a9b:	85 c0                	test   %eax,%eax
  800a9d:	78 27                	js     800ac6 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a9f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800aa2:	8b 42 08             	mov    0x8(%edx),%eax
  800aa5:	83 e0 03             	and    $0x3,%eax
  800aa8:	83 f8 01             	cmp    $0x1,%eax
  800aab:	74 1e                	je     800acb <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ab0:	8b 40 08             	mov    0x8(%eax),%eax
  800ab3:	85 c0                	test   %eax,%eax
  800ab5:	74 35                	je     800aec <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800ab7:	83 ec 04             	sub    $0x4,%esp
  800aba:	ff 75 10             	pushl  0x10(%ebp)
  800abd:	ff 75 0c             	pushl  0xc(%ebp)
  800ac0:	52                   	push   %edx
  800ac1:	ff d0                	call   *%eax
  800ac3:	83 c4 10             	add    $0x10,%esp
}
  800ac6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac9:	c9                   	leave  
  800aca:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800acb:	a1 04 40 80 00       	mov    0x804004,%eax
  800ad0:	8b 40 48             	mov    0x48(%eax),%eax
  800ad3:	83 ec 04             	sub    $0x4,%esp
  800ad6:	53                   	push   %ebx
  800ad7:	50                   	push   %eax
  800ad8:	68 fd 1e 80 00       	push   $0x801efd
  800add:	e8 cf 0a 00 00       	call   8015b1 <cprintf>
		return -E_INVAL;
  800ae2:	83 c4 10             	add    $0x10,%esp
  800ae5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800aea:	eb da                	jmp    800ac6 <read+0x5e>
		return -E_NOT_SUPP;
  800aec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800af1:	eb d3                	jmp    800ac6 <read+0x5e>

00800af3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800af3:	f3 0f 1e fb          	endbr32 
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	83 ec 0c             	sub    $0xc,%esp
  800b00:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b03:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b0b:	eb 02                	jmp    800b0f <readn+0x1c>
  800b0d:	01 c3                	add    %eax,%ebx
  800b0f:	39 f3                	cmp    %esi,%ebx
  800b11:	73 21                	jae    800b34 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b13:	83 ec 04             	sub    $0x4,%esp
  800b16:	89 f0                	mov    %esi,%eax
  800b18:	29 d8                	sub    %ebx,%eax
  800b1a:	50                   	push   %eax
  800b1b:	89 d8                	mov    %ebx,%eax
  800b1d:	03 45 0c             	add    0xc(%ebp),%eax
  800b20:	50                   	push   %eax
  800b21:	57                   	push   %edi
  800b22:	e8 41 ff ff ff       	call   800a68 <read>
		if (m < 0)
  800b27:	83 c4 10             	add    $0x10,%esp
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	78 04                	js     800b32 <readn+0x3f>
			return m;
		if (m == 0)
  800b2e:	75 dd                	jne    800b0d <readn+0x1a>
  800b30:	eb 02                	jmp    800b34 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b32:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800b34:	89 d8                	mov    %ebx,%eax
  800b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b3e:	f3 0f 1e fb          	endbr32 
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	53                   	push   %ebx
  800b46:	83 ec 1c             	sub    $0x1c,%esp
  800b49:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b4c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b4f:	50                   	push   %eax
  800b50:	53                   	push   %ebx
  800b51:	e8 8f fc ff ff       	call   8007e5 <fd_lookup>
  800b56:	83 c4 10             	add    $0x10,%esp
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	78 3a                	js     800b97 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b5d:	83 ec 08             	sub    $0x8,%esp
  800b60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b63:	50                   	push   %eax
  800b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b67:	ff 30                	pushl  (%eax)
  800b69:	e8 cb fc ff ff       	call   800839 <dev_lookup>
  800b6e:	83 c4 10             	add    $0x10,%esp
  800b71:	85 c0                	test   %eax,%eax
  800b73:	78 22                	js     800b97 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b78:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b7c:	74 1e                	je     800b9c <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b81:	8b 52 0c             	mov    0xc(%edx),%edx
  800b84:	85 d2                	test   %edx,%edx
  800b86:	74 35                	je     800bbd <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b88:	83 ec 04             	sub    $0x4,%esp
  800b8b:	ff 75 10             	pushl  0x10(%ebp)
  800b8e:	ff 75 0c             	pushl  0xc(%ebp)
  800b91:	50                   	push   %eax
  800b92:	ff d2                	call   *%edx
  800b94:	83 c4 10             	add    $0x10,%esp
}
  800b97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b9a:	c9                   	leave  
  800b9b:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800b9c:	a1 04 40 80 00       	mov    0x804004,%eax
  800ba1:	8b 40 48             	mov    0x48(%eax),%eax
  800ba4:	83 ec 04             	sub    $0x4,%esp
  800ba7:	53                   	push   %ebx
  800ba8:	50                   	push   %eax
  800ba9:	68 19 1f 80 00       	push   $0x801f19
  800bae:	e8 fe 09 00 00       	call   8015b1 <cprintf>
		return -E_INVAL;
  800bb3:	83 c4 10             	add    $0x10,%esp
  800bb6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bbb:	eb da                	jmp    800b97 <write+0x59>
		return -E_NOT_SUPP;
  800bbd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800bc2:	eb d3                	jmp    800b97 <write+0x59>

00800bc4 <seek>:

int
seek(int fdnum, off_t offset)
{
  800bc4:	f3 0f 1e fb          	endbr32 
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800bce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bd1:	50                   	push   %eax
  800bd2:	ff 75 08             	pushl  0x8(%ebp)
  800bd5:	e8 0b fc ff ff       	call   8007e5 <fd_lookup>
  800bda:	83 c4 10             	add    $0x10,%esp
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	78 0e                	js     800bef <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800be1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800be7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800bea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bef:	c9                   	leave  
  800bf0:	c3                   	ret    

00800bf1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800bf1:	f3 0f 1e fb          	endbr32 
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 1c             	sub    $0x1c,%esp
  800bfc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c02:	50                   	push   %eax
  800c03:	53                   	push   %ebx
  800c04:	e8 dc fb ff ff       	call   8007e5 <fd_lookup>
  800c09:	83 c4 10             	add    $0x10,%esp
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	78 37                	js     800c47 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c10:	83 ec 08             	sub    $0x8,%esp
  800c13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c16:	50                   	push   %eax
  800c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c1a:	ff 30                	pushl  (%eax)
  800c1c:	e8 18 fc ff ff       	call   800839 <dev_lookup>
  800c21:	83 c4 10             	add    $0x10,%esp
  800c24:	85 c0                	test   %eax,%eax
  800c26:	78 1f                	js     800c47 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c2b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c2f:	74 1b                	je     800c4c <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800c31:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c34:	8b 52 18             	mov    0x18(%edx),%edx
  800c37:	85 d2                	test   %edx,%edx
  800c39:	74 32                	je     800c6d <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c3b:	83 ec 08             	sub    $0x8,%esp
  800c3e:	ff 75 0c             	pushl  0xc(%ebp)
  800c41:	50                   	push   %eax
  800c42:	ff d2                	call   *%edx
  800c44:	83 c4 10             	add    $0x10,%esp
}
  800c47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c4a:	c9                   	leave  
  800c4b:	c3                   	ret    
			thisenv->env_id, fdnum);
  800c4c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c51:	8b 40 48             	mov    0x48(%eax),%eax
  800c54:	83 ec 04             	sub    $0x4,%esp
  800c57:	53                   	push   %ebx
  800c58:	50                   	push   %eax
  800c59:	68 dc 1e 80 00       	push   $0x801edc
  800c5e:	e8 4e 09 00 00       	call   8015b1 <cprintf>
		return -E_INVAL;
  800c63:	83 c4 10             	add    $0x10,%esp
  800c66:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c6b:	eb da                	jmp    800c47 <ftruncate+0x56>
		return -E_NOT_SUPP;
  800c6d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c72:	eb d3                	jmp    800c47 <ftruncate+0x56>

00800c74 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800c74:	f3 0f 1e fb          	endbr32 
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	53                   	push   %ebx
  800c7c:	83 ec 1c             	sub    $0x1c,%esp
  800c7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c82:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c85:	50                   	push   %eax
  800c86:	ff 75 08             	pushl  0x8(%ebp)
  800c89:	e8 57 fb ff ff       	call   8007e5 <fd_lookup>
  800c8e:	83 c4 10             	add    $0x10,%esp
  800c91:	85 c0                	test   %eax,%eax
  800c93:	78 4b                	js     800ce0 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c95:	83 ec 08             	sub    $0x8,%esp
  800c98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c9b:	50                   	push   %eax
  800c9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c9f:	ff 30                	pushl  (%eax)
  800ca1:	e8 93 fb ff ff       	call   800839 <dev_lookup>
  800ca6:	83 c4 10             	add    $0x10,%esp
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	78 33                	js     800ce0 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800cb4:	74 2f                	je     800ce5 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800cb6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800cb9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800cc0:	00 00 00 
	stat->st_isdir = 0;
  800cc3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800cca:	00 00 00 
	stat->st_dev = dev;
  800ccd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800cd3:	83 ec 08             	sub    $0x8,%esp
  800cd6:	53                   	push   %ebx
  800cd7:	ff 75 f0             	pushl  -0x10(%ebp)
  800cda:	ff 50 14             	call   *0x14(%eax)
  800cdd:	83 c4 10             	add    $0x10,%esp
}
  800ce0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ce3:	c9                   	leave  
  800ce4:	c3                   	ret    
		return -E_NOT_SUPP;
  800ce5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800cea:	eb f4                	jmp    800ce0 <fstat+0x6c>

00800cec <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800cec:	f3 0f 1e fb          	endbr32 
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800cf5:	83 ec 08             	sub    $0x8,%esp
  800cf8:	6a 00                	push   $0x0
  800cfa:	ff 75 08             	pushl  0x8(%ebp)
  800cfd:	e8 20 02 00 00       	call   800f22 <open>
  800d02:	89 c3                	mov    %eax,%ebx
  800d04:	83 c4 10             	add    $0x10,%esp
  800d07:	85 c0                	test   %eax,%eax
  800d09:	78 1b                	js     800d26 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  800d0b:	83 ec 08             	sub    $0x8,%esp
  800d0e:	ff 75 0c             	pushl  0xc(%ebp)
  800d11:	50                   	push   %eax
  800d12:	e8 5d ff ff ff       	call   800c74 <fstat>
  800d17:	89 c6                	mov    %eax,%esi
	close(fd);
  800d19:	89 1c 24             	mov    %ebx,(%esp)
  800d1c:	e8 fd fb ff ff       	call   80091e <close>
	return r;
  800d21:	83 c4 10             	add    $0x10,%esp
  800d24:	89 f3                	mov    %esi,%ebx
}
  800d26:	89 d8                	mov    %ebx,%eax
  800d28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	89 c6                	mov    %eax,%esi
  800d36:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800d38:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d3f:	74 27                	je     800d68 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d41:	6a 07                	push   $0x7
  800d43:	68 00 50 80 00       	push   $0x805000
  800d48:	56                   	push   %esi
  800d49:	ff 35 00 40 80 00    	pushl  0x804000
  800d4f:	e8 f1 0d 00 00       	call   801b45 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d54:	83 c4 0c             	add    $0xc,%esp
  800d57:	6a 00                	push   $0x0
  800d59:	53                   	push   %ebx
  800d5a:	6a 00                	push   $0x0
  800d5c:	e8 77 0d 00 00       	call   801ad8 <ipc_recv>
}
  800d61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d68:	83 ec 0c             	sub    $0xc,%esp
  800d6b:	6a 01                	push   $0x1
  800d6d:	e8 26 0e 00 00       	call   801b98 <ipc_find_env>
  800d72:	a3 00 40 80 00       	mov    %eax,0x804000
  800d77:	83 c4 10             	add    $0x10,%esp
  800d7a:	eb c5                	jmp    800d41 <fsipc+0x12>

00800d7c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d7c:	f3 0f 1e fb          	endbr32 
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d86:	8b 45 08             	mov    0x8(%ebp),%eax
  800d89:	8b 40 0c             	mov    0xc(%eax),%eax
  800d8c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d94:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d99:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9e:	b8 02 00 00 00       	mov    $0x2,%eax
  800da3:	e8 87 ff ff ff       	call   800d2f <fsipc>
}
  800da8:	c9                   	leave  
  800da9:	c3                   	ret    

00800daa <devfile_flush>:
{
  800daa:	f3 0f 1e fb          	endbr32 
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800db4:	8b 45 08             	mov    0x8(%ebp),%eax
  800db7:	8b 40 0c             	mov    0xc(%eax),%eax
  800dba:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800dbf:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc4:	b8 06 00 00 00       	mov    $0x6,%eax
  800dc9:	e8 61 ff ff ff       	call   800d2f <fsipc>
}
  800dce:	c9                   	leave  
  800dcf:	c3                   	ret    

00800dd0 <devfile_stat>:
{
  800dd0:	f3 0f 1e fb          	endbr32 
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 04             	sub    $0x4,%esp
  800ddb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800dde:	8b 45 08             	mov    0x8(%ebp),%eax
  800de1:	8b 40 0c             	mov    0xc(%eax),%eax
  800de4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800de9:	ba 00 00 00 00       	mov    $0x0,%edx
  800dee:	b8 05 00 00 00       	mov    $0x5,%eax
  800df3:	e8 37 ff ff ff       	call   800d2f <fsipc>
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	78 2c                	js     800e28 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800dfc:	83 ec 08             	sub    $0x8,%esp
  800dff:	68 00 50 80 00       	push   $0x805000
  800e04:	53                   	push   %ebx
  800e05:	e8 8d f3 ff ff       	call   800197 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800e0a:	a1 80 50 80 00       	mov    0x805080,%eax
  800e0f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800e15:	a1 84 50 80 00       	mov    0x805084,%eax
  800e1a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800e20:	83 c4 10             	add    $0x10,%esp
  800e23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e2b:	c9                   	leave  
  800e2c:	c3                   	ret    

00800e2d <devfile_write>:
{
  800e2d:	f3 0f 1e fb          	endbr32 
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	57                   	push   %edi
  800e35:	56                   	push   %esi
  800e36:	53                   	push   %ebx
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800e40:	8b 45 08             	mov    0x8(%ebp),%eax
  800e43:	8b 40 0c             	mov    0xc(%eax),%eax
  800e46:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  800e4b:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800e50:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  800e55:	85 db                	test   %ebx,%ebx
  800e57:	74 3b                	je     800e94 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800e59:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800e5f:	89 f8                	mov    %edi,%eax
  800e61:	0f 46 c3             	cmovbe %ebx,%eax
  800e64:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  800e69:	83 ec 04             	sub    $0x4,%esp
  800e6c:	50                   	push   %eax
  800e6d:	56                   	push   %esi
  800e6e:	68 08 50 80 00       	push   $0x805008
  800e73:	e8 d7 f4 ff ff       	call   80034f <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800e78:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7d:	b8 04 00 00 00       	mov    $0x4,%eax
  800e82:	e8 a8 fe ff ff       	call   800d2f <fsipc>
  800e87:	83 c4 10             	add    $0x10,%esp
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	78 06                	js     800e94 <devfile_write+0x67>
		buf_aux += r;
  800e8e:	01 c6                	add    %eax,%esi
		n -= r;
  800e90:	29 c3                	sub    %eax,%ebx
  800e92:	eb c1                	jmp    800e55 <devfile_write+0x28>
}
  800e94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <devfile_read>:
{
  800e9c:	f3 0f 1e fb          	endbr32 
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	56                   	push   %esi
  800ea4:	53                   	push   %ebx
  800ea5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ea8:	8b 45 08             	mov    0x8(%ebp),%eax
  800eab:	8b 40 0c             	mov    0xc(%eax),%eax
  800eae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800eb3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800eb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ebe:	b8 03 00 00 00       	mov    $0x3,%eax
  800ec3:	e8 67 fe ff ff       	call   800d2f <fsipc>
  800ec8:	89 c3                	mov    %eax,%ebx
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	78 1f                	js     800eed <devfile_read+0x51>
	assert(r <= n);
  800ece:	39 f0                	cmp    %esi,%eax
  800ed0:	77 24                	ja     800ef6 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800ed2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ed7:	7f 33                	jg     800f0c <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ed9:	83 ec 04             	sub    $0x4,%esp
  800edc:	50                   	push   %eax
  800edd:	68 00 50 80 00       	push   $0x805000
  800ee2:	ff 75 0c             	pushl  0xc(%ebp)
  800ee5:	e8 65 f4 ff ff       	call   80034f <memmove>
	return r;
  800eea:	83 c4 10             	add    $0x10,%esp
}
  800eed:	89 d8                	mov    %ebx,%eax
  800eef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    
	assert(r <= n);
  800ef6:	68 48 1f 80 00       	push   $0x801f48
  800efb:	68 4f 1f 80 00       	push   $0x801f4f
  800f00:	6a 7c                	push   $0x7c
  800f02:	68 64 1f 80 00       	push   $0x801f64
  800f07:	e8 be 05 00 00       	call   8014ca <_panic>
	assert(r <= PGSIZE);
  800f0c:	68 6f 1f 80 00       	push   $0x801f6f
  800f11:	68 4f 1f 80 00       	push   $0x801f4f
  800f16:	6a 7d                	push   $0x7d
  800f18:	68 64 1f 80 00       	push   $0x801f64
  800f1d:	e8 a8 05 00 00       	call   8014ca <_panic>

00800f22 <open>:
{
  800f22:	f3 0f 1e fb          	endbr32 
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	56                   	push   %esi
  800f2a:	53                   	push   %ebx
  800f2b:	83 ec 1c             	sub    $0x1c,%esp
  800f2e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800f31:	56                   	push   %esi
  800f32:	e8 1d f2 ff ff       	call   800154 <strlen>
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800f3f:	7f 6c                	jg     800fad <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800f41:	83 ec 0c             	sub    $0xc,%esp
  800f44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f47:	50                   	push   %eax
  800f48:	e8 42 f8 ff ff       	call   80078f <fd_alloc>
  800f4d:	89 c3                	mov    %eax,%ebx
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	85 c0                	test   %eax,%eax
  800f54:	78 3c                	js     800f92 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800f56:	83 ec 08             	sub    $0x8,%esp
  800f59:	56                   	push   %esi
  800f5a:	68 00 50 80 00       	push   $0x805000
  800f5f:	e8 33 f2 ff ff       	call   800197 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800f64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f67:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800f6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f6f:	b8 01 00 00 00       	mov    $0x1,%eax
  800f74:	e8 b6 fd ff ff       	call   800d2f <fsipc>
  800f79:	89 c3                	mov    %eax,%ebx
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	78 19                	js     800f9b <open+0x79>
	return fd2num(fd);
  800f82:	83 ec 0c             	sub    $0xc,%esp
  800f85:	ff 75 f4             	pushl  -0xc(%ebp)
  800f88:	e8 cf f7 ff ff       	call   80075c <fd2num>
  800f8d:	89 c3                	mov    %eax,%ebx
  800f8f:	83 c4 10             	add    $0x10,%esp
}
  800f92:	89 d8                	mov    %ebx,%eax
  800f94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    
		fd_close(fd, 0);
  800f9b:	83 ec 08             	sub    $0x8,%esp
  800f9e:	6a 00                	push   $0x0
  800fa0:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa3:	e8 eb f8 ff ff       	call   800893 <fd_close>
		return r;
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	eb e5                	jmp    800f92 <open+0x70>
		return -E_BAD_PATH;
  800fad:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800fb2:	eb de                	jmp    800f92 <open+0x70>

00800fb4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800fb4:	f3 0f 1e fb          	endbr32 
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800fbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc3:	b8 08 00 00 00       	mov    $0x8,%eax
  800fc8:	e8 62 fd ff ff       	call   800d2f <fsipc>
}
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    

00800fcf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800fcf:	f3 0f 1e fb          	endbr32 
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	56                   	push   %esi
  800fd7:	53                   	push   %ebx
  800fd8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800fdb:	83 ec 0c             	sub    $0xc,%esp
  800fde:	ff 75 08             	pushl  0x8(%ebp)
  800fe1:	e8 8a f7 ff ff       	call   800770 <fd2data>
  800fe6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800fe8:	83 c4 08             	add    $0x8,%esp
  800feb:	68 7b 1f 80 00       	push   $0x801f7b
  800ff0:	53                   	push   %ebx
  800ff1:	e8 a1 f1 ff ff       	call   800197 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ff6:	8b 46 04             	mov    0x4(%esi),%eax
  800ff9:	2b 06                	sub    (%esi),%eax
  800ffb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801001:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801008:	00 00 00 
	stat->st_dev = &devpipe;
  80100b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801012:	30 80 00 
	return 0;
}
  801015:	b8 00 00 00 00       	mov    $0x0,%eax
  80101a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80101d:	5b                   	pop    %ebx
  80101e:	5e                   	pop    %esi
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801021:	f3 0f 1e fb          	endbr32 
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	53                   	push   %ebx
  801029:	83 ec 0c             	sub    $0xc,%esp
  80102c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80102f:	53                   	push   %ebx
  801030:	6a 00                	push   $0x0
  801032:	e8 3a f6 ff ff       	call   800671 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801037:	89 1c 24             	mov    %ebx,(%esp)
  80103a:	e8 31 f7 ff ff       	call   800770 <fd2data>
  80103f:	83 c4 08             	add    $0x8,%esp
  801042:	50                   	push   %eax
  801043:	6a 00                	push   $0x0
  801045:	e8 27 f6 ff ff       	call   800671 <sys_page_unmap>
}
  80104a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    

0080104f <_pipeisclosed>:
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	57                   	push   %edi
  801053:	56                   	push   %esi
  801054:	53                   	push   %ebx
  801055:	83 ec 1c             	sub    $0x1c,%esp
  801058:	89 c7                	mov    %eax,%edi
  80105a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80105c:	a1 04 40 80 00       	mov    0x804004,%eax
  801061:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801064:	83 ec 0c             	sub    $0xc,%esp
  801067:	57                   	push   %edi
  801068:	e8 68 0b 00 00       	call   801bd5 <pageref>
  80106d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801070:	89 34 24             	mov    %esi,(%esp)
  801073:	e8 5d 0b 00 00       	call   801bd5 <pageref>
		nn = thisenv->env_runs;
  801078:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80107e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	39 cb                	cmp    %ecx,%ebx
  801086:	74 1b                	je     8010a3 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801088:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80108b:	75 cf                	jne    80105c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80108d:	8b 42 58             	mov    0x58(%edx),%eax
  801090:	6a 01                	push   $0x1
  801092:	50                   	push   %eax
  801093:	53                   	push   %ebx
  801094:	68 82 1f 80 00       	push   $0x801f82
  801099:	e8 13 05 00 00       	call   8015b1 <cprintf>
  80109e:	83 c4 10             	add    $0x10,%esp
  8010a1:	eb b9                	jmp    80105c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010a3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010a6:	0f 94 c0             	sete   %al
  8010a9:	0f b6 c0             	movzbl %al,%eax
}
  8010ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5f                   	pop    %edi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <devpipe_write>:
{
  8010b4:	f3 0f 1e fb          	endbr32 
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	57                   	push   %edi
  8010bc:	56                   	push   %esi
  8010bd:	53                   	push   %ebx
  8010be:	83 ec 28             	sub    $0x28,%esp
  8010c1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010c4:	56                   	push   %esi
  8010c5:	e8 a6 f6 ff ff       	call   800770 <fd2data>
  8010ca:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010cc:	83 c4 10             	add    $0x10,%esp
  8010cf:	bf 00 00 00 00       	mov    $0x0,%edi
  8010d4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8010d7:	74 4f                	je     801128 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010d9:	8b 43 04             	mov    0x4(%ebx),%eax
  8010dc:	8b 0b                	mov    (%ebx),%ecx
  8010de:	8d 51 20             	lea    0x20(%ecx),%edx
  8010e1:	39 d0                	cmp    %edx,%eax
  8010e3:	72 14                	jb     8010f9 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8010e5:	89 da                	mov    %ebx,%edx
  8010e7:	89 f0                	mov    %esi,%eax
  8010e9:	e8 61 ff ff ff       	call   80104f <_pipeisclosed>
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	75 3b                	jne    80112d <devpipe_write+0x79>
			sys_yield();
  8010f2:	e8 fd f4 ff ff       	call   8005f4 <sys_yield>
  8010f7:	eb e0                	jmp    8010d9 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8010f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010fc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801100:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801103:	89 c2                	mov    %eax,%edx
  801105:	c1 fa 1f             	sar    $0x1f,%edx
  801108:	89 d1                	mov    %edx,%ecx
  80110a:	c1 e9 1b             	shr    $0x1b,%ecx
  80110d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801110:	83 e2 1f             	and    $0x1f,%edx
  801113:	29 ca                	sub    %ecx,%edx
  801115:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801119:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80111d:	83 c0 01             	add    $0x1,%eax
  801120:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801123:	83 c7 01             	add    $0x1,%edi
  801126:	eb ac                	jmp    8010d4 <devpipe_write+0x20>
	return i;
  801128:	8b 45 10             	mov    0x10(%ebp),%eax
  80112b:	eb 05                	jmp    801132 <devpipe_write+0x7e>
				return 0;
  80112d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801132:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801135:	5b                   	pop    %ebx
  801136:	5e                   	pop    %esi
  801137:	5f                   	pop    %edi
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <devpipe_read>:
{
  80113a:	f3 0f 1e fb          	endbr32 
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	57                   	push   %edi
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
  801144:	83 ec 18             	sub    $0x18,%esp
  801147:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80114a:	57                   	push   %edi
  80114b:	e8 20 f6 ff ff       	call   800770 <fd2data>
  801150:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801152:	83 c4 10             	add    $0x10,%esp
  801155:	be 00 00 00 00       	mov    $0x0,%esi
  80115a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80115d:	75 14                	jne    801173 <devpipe_read+0x39>
	return i;
  80115f:	8b 45 10             	mov    0x10(%ebp),%eax
  801162:	eb 02                	jmp    801166 <devpipe_read+0x2c>
				return i;
  801164:	89 f0                	mov    %esi,%eax
}
  801166:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801169:	5b                   	pop    %ebx
  80116a:	5e                   	pop    %esi
  80116b:	5f                   	pop    %edi
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    
			sys_yield();
  80116e:	e8 81 f4 ff ff       	call   8005f4 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801173:	8b 03                	mov    (%ebx),%eax
  801175:	3b 43 04             	cmp    0x4(%ebx),%eax
  801178:	75 18                	jne    801192 <devpipe_read+0x58>
			if (i > 0)
  80117a:	85 f6                	test   %esi,%esi
  80117c:	75 e6                	jne    801164 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  80117e:	89 da                	mov    %ebx,%edx
  801180:	89 f8                	mov    %edi,%eax
  801182:	e8 c8 fe ff ff       	call   80104f <_pipeisclosed>
  801187:	85 c0                	test   %eax,%eax
  801189:	74 e3                	je     80116e <devpipe_read+0x34>
				return 0;
  80118b:	b8 00 00 00 00       	mov    $0x0,%eax
  801190:	eb d4                	jmp    801166 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801192:	99                   	cltd   
  801193:	c1 ea 1b             	shr    $0x1b,%edx
  801196:	01 d0                	add    %edx,%eax
  801198:	83 e0 1f             	and    $0x1f,%eax
  80119b:	29 d0                	sub    %edx,%eax
  80119d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011a8:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011ab:	83 c6 01             	add    $0x1,%esi
  8011ae:	eb aa                	jmp    80115a <devpipe_read+0x20>

008011b0 <pipe>:
{
  8011b0:	f3 0f 1e fb          	endbr32 
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	56                   	push   %esi
  8011b8:	53                   	push   %ebx
  8011b9:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011bf:	50                   	push   %eax
  8011c0:	e8 ca f5 ff ff       	call   80078f <fd_alloc>
  8011c5:	89 c3                	mov    %eax,%ebx
  8011c7:	83 c4 10             	add    $0x10,%esp
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	0f 88 23 01 00 00    	js     8012f5 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011d2:	83 ec 04             	sub    $0x4,%esp
  8011d5:	68 07 04 00 00       	push   $0x407
  8011da:	ff 75 f4             	pushl  -0xc(%ebp)
  8011dd:	6a 00                	push   $0x0
  8011df:	e8 3b f4 ff ff       	call   80061f <sys_page_alloc>
  8011e4:	89 c3                	mov    %eax,%ebx
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	0f 88 04 01 00 00    	js     8012f5 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8011f1:	83 ec 0c             	sub    $0xc,%esp
  8011f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f7:	50                   	push   %eax
  8011f8:	e8 92 f5 ff ff       	call   80078f <fd_alloc>
  8011fd:	89 c3                	mov    %eax,%ebx
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	85 c0                	test   %eax,%eax
  801204:	0f 88 db 00 00 00    	js     8012e5 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80120a:	83 ec 04             	sub    $0x4,%esp
  80120d:	68 07 04 00 00       	push   $0x407
  801212:	ff 75 f0             	pushl  -0x10(%ebp)
  801215:	6a 00                	push   $0x0
  801217:	e8 03 f4 ff ff       	call   80061f <sys_page_alloc>
  80121c:	89 c3                	mov    %eax,%ebx
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	85 c0                	test   %eax,%eax
  801223:	0f 88 bc 00 00 00    	js     8012e5 <pipe+0x135>
	va = fd2data(fd0);
  801229:	83 ec 0c             	sub    $0xc,%esp
  80122c:	ff 75 f4             	pushl  -0xc(%ebp)
  80122f:	e8 3c f5 ff ff       	call   800770 <fd2data>
  801234:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801236:	83 c4 0c             	add    $0xc,%esp
  801239:	68 07 04 00 00       	push   $0x407
  80123e:	50                   	push   %eax
  80123f:	6a 00                	push   $0x0
  801241:	e8 d9 f3 ff ff       	call   80061f <sys_page_alloc>
  801246:	89 c3                	mov    %eax,%ebx
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	85 c0                	test   %eax,%eax
  80124d:	0f 88 82 00 00 00    	js     8012d5 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801253:	83 ec 0c             	sub    $0xc,%esp
  801256:	ff 75 f0             	pushl  -0x10(%ebp)
  801259:	e8 12 f5 ff ff       	call   800770 <fd2data>
  80125e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801265:	50                   	push   %eax
  801266:	6a 00                	push   $0x0
  801268:	56                   	push   %esi
  801269:	6a 00                	push   $0x0
  80126b:	e8 d7 f3 ff ff       	call   800647 <sys_page_map>
  801270:	89 c3                	mov    %eax,%ebx
  801272:	83 c4 20             	add    $0x20,%esp
  801275:	85 c0                	test   %eax,%eax
  801277:	78 4e                	js     8012c7 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801279:	a1 20 30 80 00       	mov    0x803020,%eax
  80127e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801281:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801283:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801286:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80128d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801290:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801292:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801295:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80129c:	83 ec 0c             	sub    $0xc,%esp
  80129f:	ff 75 f4             	pushl  -0xc(%ebp)
  8012a2:	e8 b5 f4 ff ff       	call   80075c <fd2num>
  8012a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012aa:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012ac:	83 c4 04             	add    $0x4,%esp
  8012af:	ff 75 f0             	pushl  -0x10(%ebp)
  8012b2:	e8 a5 f4 ff ff       	call   80075c <fd2num>
  8012b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ba:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012bd:	83 c4 10             	add    $0x10,%esp
  8012c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c5:	eb 2e                	jmp    8012f5 <pipe+0x145>
	sys_page_unmap(0, va);
  8012c7:	83 ec 08             	sub    $0x8,%esp
  8012ca:	56                   	push   %esi
  8012cb:	6a 00                	push   $0x0
  8012cd:	e8 9f f3 ff ff       	call   800671 <sys_page_unmap>
  8012d2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8012d5:	83 ec 08             	sub    $0x8,%esp
  8012d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8012db:	6a 00                	push   $0x0
  8012dd:	e8 8f f3 ff ff       	call   800671 <sys_page_unmap>
  8012e2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8012e5:	83 ec 08             	sub    $0x8,%esp
  8012e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8012eb:	6a 00                	push   $0x0
  8012ed:	e8 7f f3 ff ff       	call   800671 <sys_page_unmap>
  8012f2:	83 c4 10             	add    $0x10,%esp
}
  8012f5:	89 d8                	mov    %ebx,%eax
  8012f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fa:	5b                   	pop    %ebx
  8012fb:	5e                   	pop    %esi
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    

008012fe <pipeisclosed>:
{
  8012fe:	f3 0f 1e fb          	endbr32 
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801308:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130b:	50                   	push   %eax
  80130c:	ff 75 08             	pushl  0x8(%ebp)
  80130f:	e8 d1 f4 ff ff       	call   8007e5 <fd_lookup>
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	85 c0                	test   %eax,%eax
  801319:	78 18                	js     801333 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  80131b:	83 ec 0c             	sub    $0xc,%esp
  80131e:	ff 75 f4             	pushl  -0xc(%ebp)
  801321:	e8 4a f4 ff ff       	call   800770 <fd2data>
  801326:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801328:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132b:	e8 1f fd ff ff       	call   80104f <_pipeisclosed>
  801330:	83 c4 10             	add    $0x10,%esp
}
  801333:	c9                   	leave  
  801334:	c3                   	ret    

00801335 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801335:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801339:	b8 00 00 00 00       	mov    $0x0,%eax
  80133e:	c3                   	ret    

0080133f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80133f:	f3 0f 1e fb          	endbr32 
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801349:	68 9a 1f 80 00       	push   $0x801f9a
  80134e:	ff 75 0c             	pushl  0xc(%ebp)
  801351:	e8 41 ee ff ff       	call   800197 <strcpy>
	return 0;
}
  801356:	b8 00 00 00 00       	mov    $0x0,%eax
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <devcons_write>:
{
  80135d:	f3 0f 1e fb          	endbr32 
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	57                   	push   %edi
  801365:	56                   	push   %esi
  801366:	53                   	push   %ebx
  801367:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80136d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801372:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801378:	3b 75 10             	cmp    0x10(%ebp),%esi
  80137b:	73 31                	jae    8013ae <devcons_write+0x51>
		m = n - tot;
  80137d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801380:	29 f3                	sub    %esi,%ebx
  801382:	83 fb 7f             	cmp    $0x7f,%ebx
  801385:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80138a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80138d:	83 ec 04             	sub    $0x4,%esp
  801390:	53                   	push   %ebx
  801391:	89 f0                	mov    %esi,%eax
  801393:	03 45 0c             	add    0xc(%ebp),%eax
  801396:	50                   	push   %eax
  801397:	57                   	push   %edi
  801398:	e8 b2 ef ff ff       	call   80034f <memmove>
		sys_cputs(buf, m);
  80139d:	83 c4 08             	add    $0x8,%esp
  8013a0:	53                   	push   %ebx
  8013a1:	57                   	push   %edi
  8013a2:	e8 ad f1 ff ff       	call   800554 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013a7:	01 de                	add    %ebx,%esi
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	eb ca                	jmp    801378 <devcons_write+0x1b>
}
  8013ae:	89 f0                	mov    %esi,%eax
  8013b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b3:	5b                   	pop    %ebx
  8013b4:	5e                   	pop    %esi
  8013b5:	5f                   	pop    %edi
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    

008013b8 <devcons_read>:
{
  8013b8:	f3 0f 1e fb          	endbr32 
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	83 ec 08             	sub    $0x8,%esp
  8013c2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013c7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013cb:	74 21                	je     8013ee <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8013cd:	e8 ac f1 ff ff       	call   80057e <sys_cgetc>
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	75 07                	jne    8013dd <devcons_read+0x25>
		sys_yield();
  8013d6:	e8 19 f2 ff ff       	call   8005f4 <sys_yield>
  8013db:	eb f0                	jmp    8013cd <devcons_read+0x15>
	if (c < 0)
  8013dd:	78 0f                	js     8013ee <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8013df:	83 f8 04             	cmp    $0x4,%eax
  8013e2:	74 0c                	je     8013f0 <devcons_read+0x38>
	*(char*)vbuf = c;
  8013e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e7:	88 02                	mov    %al,(%edx)
	return 1;
  8013e9:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8013ee:	c9                   	leave  
  8013ef:	c3                   	ret    
		return 0;
  8013f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f5:	eb f7                	jmp    8013ee <devcons_read+0x36>

008013f7 <cputchar>:
{
  8013f7:	f3 0f 1e fb          	endbr32 
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801401:	8b 45 08             	mov    0x8(%ebp),%eax
  801404:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801407:	6a 01                	push   $0x1
  801409:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80140c:	50                   	push   %eax
  80140d:	e8 42 f1 ff ff       	call   800554 <sys_cputs>
}
  801412:	83 c4 10             	add    $0x10,%esp
  801415:	c9                   	leave  
  801416:	c3                   	ret    

00801417 <getchar>:
{
  801417:	f3 0f 1e fb          	endbr32 
  80141b:	55                   	push   %ebp
  80141c:	89 e5                	mov    %esp,%ebp
  80141e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801421:	6a 01                	push   $0x1
  801423:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801426:	50                   	push   %eax
  801427:	6a 00                	push   $0x0
  801429:	e8 3a f6 ff ff       	call   800a68 <read>
	if (r < 0)
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	85 c0                	test   %eax,%eax
  801433:	78 06                	js     80143b <getchar+0x24>
	if (r < 1)
  801435:	74 06                	je     80143d <getchar+0x26>
	return c;
  801437:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80143b:	c9                   	leave  
  80143c:	c3                   	ret    
		return -E_EOF;
  80143d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801442:	eb f7                	jmp    80143b <getchar+0x24>

00801444 <iscons>:
{
  801444:	f3 0f 1e fb          	endbr32 
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80144e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801451:	50                   	push   %eax
  801452:	ff 75 08             	pushl  0x8(%ebp)
  801455:	e8 8b f3 ff ff       	call   8007e5 <fd_lookup>
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	85 c0                	test   %eax,%eax
  80145f:	78 11                	js     801472 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801461:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801464:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80146a:	39 10                	cmp    %edx,(%eax)
  80146c:	0f 94 c0             	sete   %al
  80146f:	0f b6 c0             	movzbl %al,%eax
}
  801472:	c9                   	leave  
  801473:	c3                   	ret    

00801474 <opencons>:
{
  801474:	f3 0f 1e fb          	endbr32 
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80147e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	e8 08 f3 ff ff       	call   80078f <fd_alloc>
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 3a                	js     8014c8 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80148e:	83 ec 04             	sub    $0x4,%esp
  801491:	68 07 04 00 00       	push   $0x407
  801496:	ff 75 f4             	pushl  -0xc(%ebp)
  801499:	6a 00                	push   $0x0
  80149b:	e8 7f f1 ff ff       	call   80061f <sys_page_alloc>
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 21                	js     8014c8 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8014a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014aa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8014b0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014bc:	83 ec 0c             	sub    $0xc,%esp
  8014bf:	50                   	push   %eax
  8014c0:	e8 97 f2 ff ff       	call   80075c <fd2num>
  8014c5:	83 c4 10             	add    $0x10,%esp
}
  8014c8:	c9                   	leave  
  8014c9:	c3                   	ret    

008014ca <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014ca:	f3 0f 1e fb          	endbr32 
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	56                   	push   %esi
  8014d2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014d3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014d6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014dc:	e8 eb f0 ff ff       	call   8005cc <sys_getenvid>
  8014e1:	83 ec 0c             	sub    $0xc,%esp
  8014e4:	ff 75 0c             	pushl  0xc(%ebp)
  8014e7:	ff 75 08             	pushl  0x8(%ebp)
  8014ea:	56                   	push   %esi
  8014eb:	50                   	push   %eax
  8014ec:	68 a8 1f 80 00       	push   $0x801fa8
  8014f1:	e8 bb 00 00 00       	call   8015b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014f6:	83 c4 18             	add    $0x18,%esp
  8014f9:	53                   	push   %ebx
  8014fa:	ff 75 10             	pushl  0x10(%ebp)
  8014fd:	e8 5a 00 00 00       	call   80155c <vcprintf>
	cprintf("\n");
  801502:	c7 04 24 93 1f 80 00 	movl   $0x801f93,(%esp)
  801509:	e8 a3 00 00 00       	call   8015b1 <cprintf>
  80150e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801511:	cc                   	int3   
  801512:	eb fd                	jmp    801511 <_panic+0x47>

00801514 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801514:	f3 0f 1e fb          	endbr32 
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	53                   	push   %ebx
  80151c:	83 ec 04             	sub    $0x4,%esp
  80151f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801522:	8b 13                	mov    (%ebx),%edx
  801524:	8d 42 01             	lea    0x1(%edx),%eax
  801527:	89 03                	mov    %eax,(%ebx)
  801529:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80152c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801530:	3d ff 00 00 00       	cmp    $0xff,%eax
  801535:	74 09                	je     801540 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801537:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80153b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153e:	c9                   	leave  
  80153f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	68 ff 00 00 00       	push   $0xff
  801548:	8d 43 08             	lea    0x8(%ebx),%eax
  80154b:	50                   	push   %eax
  80154c:	e8 03 f0 ff ff       	call   800554 <sys_cputs>
		b->idx = 0;
  801551:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	eb db                	jmp    801537 <putch+0x23>

0080155c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80155c:	f3 0f 1e fb          	endbr32 
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801569:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801570:	00 00 00 
	b.cnt = 0;
  801573:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80157a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80157d:	ff 75 0c             	pushl  0xc(%ebp)
  801580:	ff 75 08             	pushl  0x8(%ebp)
  801583:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801589:	50                   	push   %eax
  80158a:	68 14 15 80 00       	push   $0x801514
  80158f:	e8 80 01 00 00       	call   801714 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801594:	83 c4 08             	add    $0x8,%esp
  801597:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80159d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015a3:	50                   	push   %eax
  8015a4:	e8 ab ef ff ff       	call   800554 <sys_cputs>

	return b.cnt;
}
  8015a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015af:	c9                   	leave  
  8015b0:	c3                   	ret    

008015b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015b1:	f3 0f 1e fb          	endbr32 
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015bb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015be:	50                   	push   %eax
  8015bf:	ff 75 08             	pushl  0x8(%ebp)
  8015c2:	e8 95 ff ff ff       	call   80155c <vcprintf>
	va_end(ap);

	return cnt;
}
  8015c7:	c9                   	leave  
  8015c8:	c3                   	ret    

008015c9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	57                   	push   %edi
  8015cd:	56                   	push   %esi
  8015ce:	53                   	push   %ebx
  8015cf:	83 ec 1c             	sub    $0x1c,%esp
  8015d2:	89 c7                	mov    %eax,%edi
  8015d4:	89 d6                	mov    %edx,%esi
  8015d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015dc:	89 d1                	mov    %edx,%ecx
  8015de:	89 c2                	mov    %eax,%edx
  8015e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015e3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8015e9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015ef:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8015f6:	39 c2                	cmp    %eax,%edx
  8015f8:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8015fb:	72 3e                	jb     80163b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015fd:	83 ec 0c             	sub    $0xc,%esp
  801600:	ff 75 18             	pushl  0x18(%ebp)
  801603:	83 eb 01             	sub    $0x1,%ebx
  801606:	53                   	push   %ebx
  801607:	50                   	push   %eax
  801608:	83 ec 08             	sub    $0x8,%esp
  80160b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80160e:	ff 75 e0             	pushl  -0x20(%ebp)
  801611:	ff 75 dc             	pushl  -0x24(%ebp)
  801614:	ff 75 d8             	pushl  -0x28(%ebp)
  801617:	e8 04 06 00 00       	call   801c20 <__udivdi3>
  80161c:	83 c4 18             	add    $0x18,%esp
  80161f:	52                   	push   %edx
  801620:	50                   	push   %eax
  801621:	89 f2                	mov    %esi,%edx
  801623:	89 f8                	mov    %edi,%eax
  801625:	e8 9f ff ff ff       	call   8015c9 <printnum>
  80162a:	83 c4 20             	add    $0x20,%esp
  80162d:	eb 13                	jmp    801642 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	56                   	push   %esi
  801633:	ff 75 18             	pushl  0x18(%ebp)
  801636:	ff d7                	call   *%edi
  801638:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80163b:	83 eb 01             	sub    $0x1,%ebx
  80163e:	85 db                	test   %ebx,%ebx
  801640:	7f ed                	jg     80162f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	56                   	push   %esi
  801646:	83 ec 04             	sub    $0x4,%esp
  801649:	ff 75 e4             	pushl  -0x1c(%ebp)
  80164c:	ff 75 e0             	pushl  -0x20(%ebp)
  80164f:	ff 75 dc             	pushl  -0x24(%ebp)
  801652:	ff 75 d8             	pushl  -0x28(%ebp)
  801655:	e8 d6 06 00 00       	call   801d30 <__umoddi3>
  80165a:	83 c4 14             	add    $0x14,%esp
  80165d:	0f be 80 cb 1f 80 00 	movsbl 0x801fcb(%eax),%eax
  801664:	50                   	push   %eax
  801665:	ff d7                	call   *%edi
}
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166d:	5b                   	pop    %ebx
  80166e:	5e                   	pop    %esi
  80166f:	5f                   	pop    %edi
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    

00801672 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801672:	83 fa 01             	cmp    $0x1,%edx
  801675:	7f 13                	jg     80168a <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801677:	85 d2                	test   %edx,%edx
  801679:	74 1c                	je     801697 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80167b:	8b 10                	mov    (%eax),%edx
  80167d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801680:	89 08                	mov    %ecx,(%eax)
  801682:	8b 02                	mov    (%edx),%eax
  801684:	ba 00 00 00 00       	mov    $0x0,%edx
  801689:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80168a:	8b 10                	mov    (%eax),%edx
  80168c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80168f:	89 08                	mov    %ecx,(%eax)
  801691:	8b 02                	mov    (%edx),%eax
  801693:	8b 52 04             	mov    0x4(%edx),%edx
  801696:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  801697:	8b 10                	mov    (%eax),%edx
  801699:	8d 4a 04             	lea    0x4(%edx),%ecx
  80169c:	89 08                	mov    %ecx,(%eax)
  80169e:	8b 02                	mov    (%edx),%eax
  8016a0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016a5:	c3                   	ret    

008016a6 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8016a6:	83 fa 01             	cmp    $0x1,%edx
  8016a9:	7f 0f                	jg     8016ba <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8016ab:	85 d2                	test   %edx,%edx
  8016ad:	74 18                	je     8016c7 <getint+0x21>
		return va_arg(*ap, long);
  8016af:	8b 10                	mov    (%eax),%edx
  8016b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016b4:	89 08                	mov    %ecx,(%eax)
  8016b6:	8b 02                	mov    (%edx),%eax
  8016b8:	99                   	cltd   
  8016b9:	c3                   	ret    
		return va_arg(*ap, long long);
  8016ba:	8b 10                	mov    (%eax),%edx
  8016bc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016bf:	89 08                	mov    %ecx,(%eax)
  8016c1:	8b 02                	mov    (%edx),%eax
  8016c3:	8b 52 04             	mov    0x4(%edx),%edx
  8016c6:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8016c7:	8b 10                	mov    (%eax),%edx
  8016c9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016cc:	89 08                	mov    %ecx,(%eax)
  8016ce:	8b 02                	mov    (%edx),%eax
  8016d0:	99                   	cltd   
}
  8016d1:	c3                   	ret    

008016d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016d2:	f3 0f 1e fb          	endbr32 
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016dc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016e0:	8b 10                	mov    (%eax),%edx
  8016e2:	3b 50 04             	cmp    0x4(%eax),%edx
  8016e5:	73 0a                	jae    8016f1 <sprintputch+0x1f>
		*b->buf++ = ch;
  8016e7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016ea:	89 08                	mov    %ecx,(%eax)
  8016ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ef:	88 02                	mov    %al,(%edx)
}
  8016f1:	5d                   	pop    %ebp
  8016f2:	c3                   	ret    

008016f3 <printfmt>:
{
  8016f3:	f3 0f 1e fb          	endbr32 
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8016fd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801700:	50                   	push   %eax
  801701:	ff 75 10             	pushl  0x10(%ebp)
  801704:	ff 75 0c             	pushl  0xc(%ebp)
  801707:	ff 75 08             	pushl  0x8(%ebp)
  80170a:	e8 05 00 00 00       	call   801714 <vprintfmt>
}
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	c9                   	leave  
  801713:	c3                   	ret    

00801714 <vprintfmt>:
{
  801714:	f3 0f 1e fb          	endbr32 
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	57                   	push   %edi
  80171c:	56                   	push   %esi
  80171d:	53                   	push   %ebx
  80171e:	83 ec 2c             	sub    $0x2c,%esp
  801721:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801724:	8b 75 0c             	mov    0xc(%ebp),%esi
  801727:	8b 7d 10             	mov    0x10(%ebp),%edi
  80172a:	e9 86 02 00 00       	jmp    8019b5 <vprintfmt+0x2a1>
		padc = ' ';
  80172f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801733:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80173a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801741:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801748:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80174d:	8d 47 01             	lea    0x1(%edi),%eax
  801750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801753:	0f b6 17             	movzbl (%edi),%edx
  801756:	8d 42 dd             	lea    -0x23(%edx),%eax
  801759:	3c 55                	cmp    $0x55,%al
  80175b:	0f 87 df 02 00 00    	ja     801a40 <vprintfmt+0x32c>
  801761:	0f b6 c0             	movzbl %al,%eax
  801764:	3e ff 24 85 00 21 80 	notrack jmp *0x802100(,%eax,4)
  80176b:	00 
  80176c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80176f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801773:	eb d8                	jmp    80174d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801775:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801778:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80177c:	eb cf                	jmp    80174d <vprintfmt+0x39>
  80177e:	0f b6 d2             	movzbl %dl,%edx
  801781:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801784:	b8 00 00 00 00       	mov    $0x0,%eax
  801789:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80178c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80178f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801793:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801796:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801799:	83 f9 09             	cmp    $0x9,%ecx
  80179c:	77 52                	ja     8017f0 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  80179e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8017a1:	eb e9                	jmp    80178c <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8017a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a6:	8d 50 04             	lea    0x4(%eax),%edx
  8017a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8017ac:	8b 00                	mov    (%eax),%eax
  8017ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8017b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8017b4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017b8:	79 93                	jns    80174d <vprintfmt+0x39>
				width = precision, precision = -1;
  8017ba:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8017bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017c0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8017c7:	eb 84                	jmp    80174d <vprintfmt+0x39>
  8017c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d3:	0f 49 d0             	cmovns %eax,%edx
  8017d6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8017d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017dc:	e9 6c ff ff ff       	jmp    80174d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8017e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8017e4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8017eb:	e9 5d ff ff ff       	jmp    80174d <vprintfmt+0x39>
  8017f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017f3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017f6:	eb bc                	jmp    8017b4 <vprintfmt+0xa0>
			lflag++;
  8017f8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8017fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017fe:	e9 4a ff ff ff       	jmp    80174d <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  801803:	8b 45 14             	mov    0x14(%ebp),%eax
  801806:	8d 50 04             	lea    0x4(%eax),%edx
  801809:	89 55 14             	mov    %edx,0x14(%ebp)
  80180c:	83 ec 08             	sub    $0x8,%esp
  80180f:	56                   	push   %esi
  801810:	ff 30                	pushl  (%eax)
  801812:	ff d3                	call   *%ebx
			break;
  801814:	83 c4 10             	add    $0x10,%esp
  801817:	e9 96 01 00 00       	jmp    8019b2 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  80181c:	8b 45 14             	mov    0x14(%ebp),%eax
  80181f:	8d 50 04             	lea    0x4(%eax),%edx
  801822:	89 55 14             	mov    %edx,0x14(%ebp)
  801825:	8b 00                	mov    (%eax),%eax
  801827:	99                   	cltd   
  801828:	31 d0                	xor    %edx,%eax
  80182a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80182c:	83 f8 0f             	cmp    $0xf,%eax
  80182f:	7f 20                	jg     801851 <vprintfmt+0x13d>
  801831:	8b 14 85 60 22 80 00 	mov    0x802260(,%eax,4),%edx
  801838:	85 d2                	test   %edx,%edx
  80183a:	74 15                	je     801851 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  80183c:	52                   	push   %edx
  80183d:	68 61 1f 80 00       	push   $0x801f61
  801842:	56                   	push   %esi
  801843:	53                   	push   %ebx
  801844:	e8 aa fe ff ff       	call   8016f3 <printfmt>
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	e9 61 01 00 00       	jmp    8019b2 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  801851:	50                   	push   %eax
  801852:	68 e3 1f 80 00       	push   $0x801fe3
  801857:	56                   	push   %esi
  801858:	53                   	push   %ebx
  801859:	e8 95 fe ff ff       	call   8016f3 <printfmt>
  80185e:	83 c4 10             	add    $0x10,%esp
  801861:	e9 4c 01 00 00       	jmp    8019b2 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  801866:	8b 45 14             	mov    0x14(%ebp),%eax
  801869:	8d 50 04             	lea    0x4(%eax),%edx
  80186c:	89 55 14             	mov    %edx,0x14(%ebp)
  80186f:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  801871:	85 c9                	test   %ecx,%ecx
  801873:	b8 dc 1f 80 00       	mov    $0x801fdc,%eax
  801878:	0f 45 c1             	cmovne %ecx,%eax
  80187b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80187e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801882:	7e 06                	jle    80188a <vprintfmt+0x176>
  801884:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801888:	75 0d                	jne    801897 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  80188a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80188d:	89 c7                	mov    %eax,%edi
  80188f:	03 45 e0             	add    -0x20(%ebp),%eax
  801892:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801895:	eb 57                	jmp    8018ee <vprintfmt+0x1da>
  801897:	83 ec 08             	sub    $0x8,%esp
  80189a:	ff 75 d8             	pushl  -0x28(%ebp)
  80189d:	ff 75 cc             	pushl  -0x34(%ebp)
  8018a0:	e8 cb e8 ff ff       	call   800170 <strnlen>
  8018a5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8018a8:	29 c2                	sub    %eax,%edx
  8018aa:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8018ad:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018b0:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8018b4:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8018b7:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8018b9:	85 db                	test   %ebx,%ebx
  8018bb:	7e 10                	jle    8018cd <vprintfmt+0x1b9>
					putch(padc, putdat);
  8018bd:	83 ec 08             	sub    $0x8,%esp
  8018c0:	56                   	push   %esi
  8018c1:	57                   	push   %edi
  8018c2:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c5:	83 eb 01             	sub    $0x1,%ebx
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	eb ec                	jmp    8018b9 <vprintfmt+0x1a5>
  8018cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8018d0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8018d3:	85 d2                	test   %edx,%edx
  8018d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018da:	0f 49 c2             	cmovns %edx,%eax
  8018dd:	29 c2                	sub    %eax,%edx
  8018df:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8018e2:	eb a6                	jmp    80188a <vprintfmt+0x176>
					putch(ch, putdat);
  8018e4:	83 ec 08             	sub    $0x8,%esp
  8018e7:	56                   	push   %esi
  8018e8:	52                   	push   %edx
  8018e9:	ff d3                	call   *%ebx
  8018eb:	83 c4 10             	add    $0x10,%esp
  8018ee:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018f1:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018f3:	83 c7 01             	add    $0x1,%edi
  8018f6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018fa:	0f be d0             	movsbl %al,%edx
  8018fd:	85 d2                	test   %edx,%edx
  8018ff:	74 42                	je     801943 <vprintfmt+0x22f>
  801901:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801905:	78 06                	js     80190d <vprintfmt+0x1f9>
  801907:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80190b:	78 1e                	js     80192b <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  80190d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801911:	74 d1                	je     8018e4 <vprintfmt+0x1d0>
  801913:	0f be c0             	movsbl %al,%eax
  801916:	83 e8 20             	sub    $0x20,%eax
  801919:	83 f8 5e             	cmp    $0x5e,%eax
  80191c:	76 c6                	jbe    8018e4 <vprintfmt+0x1d0>
					putch('?', putdat);
  80191e:	83 ec 08             	sub    $0x8,%esp
  801921:	56                   	push   %esi
  801922:	6a 3f                	push   $0x3f
  801924:	ff d3                	call   *%ebx
  801926:	83 c4 10             	add    $0x10,%esp
  801929:	eb c3                	jmp    8018ee <vprintfmt+0x1da>
  80192b:	89 cf                	mov    %ecx,%edi
  80192d:	eb 0e                	jmp    80193d <vprintfmt+0x229>
				putch(' ', putdat);
  80192f:	83 ec 08             	sub    $0x8,%esp
  801932:	56                   	push   %esi
  801933:	6a 20                	push   $0x20
  801935:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  801937:	83 ef 01             	sub    $0x1,%edi
  80193a:	83 c4 10             	add    $0x10,%esp
  80193d:	85 ff                	test   %edi,%edi
  80193f:	7f ee                	jg     80192f <vprintfmt+0x21b>
  801941:	eb 6f                	jmp    8019b2 <vprintfmt+0x29e>
  801943:	89 cf                	mov    %ecx,%edi
  801945:	eb f6                	jmp    80193d <vprintfmt+0x229>
			num = getint(&ap, lflag);
  801947:	89 ca                	mov    %ecx,%edx
  801949:	8d 45 14             	lea    0x14(%ebp),%eax
  80194c:	e8 55 fd ff ff       	call   8016a6 <getint>
  801951:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801954:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  801957:	85 d2                	test   %edx,%edx
  801959:	78 0b                	js     801966 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  80195b:	89 d1                	mov    %edx,%ecx
  80195d:	89 c2                	mov    %eax,%edx
			base = 10;
  80195f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801964:	eb 32                	jmp    801998 <vprintfmt+0x284>
				putch('-', putdat);
  801966:	83 ec 08             	sub    $0x8,%esp
  801969:	56                   	push   %esi
  80196a:	6a 2d                	push   $0x2d
  80196c:	ff d3                	call   *%ebx
				num = -(long long) num;
  80196e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801971:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801974:	f7 da                	neg    %edx
  801976:	83 d1 00             	adc    $0x0,%ecx
  801979:	f7 d9                	neg    %ecx
  80197b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80197e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801983:	eb 13                	jmp    801998 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  801985:	89 ca                	mov    %ecx,%edx
  801987:	8d 45 14             	lea    0x14(%ebp),%eax
  80198a:	e8 e3 fc ff ff       	call   801672 <getuint>
  80198f:	89 d1                	mov    %edx,%ecx
  801991:	89 c2                	mov    %eax,%edx
			base = 10;
  801993:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  801998:	83 ec 0c             	sub    $0xc,%esp
  80199b:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80199f:	57                   	push   %edi
  8019a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8019a3:	50                   	push   %eax
  8019a4:	51                   	push   %ecx
  8019a5:	52                   	push   %edx
  8019a6:	89 f2                	mov    %esi,%edx
  8019a8:	89 d8                	mov    %ebx,%eax
  8019aa:	e8 1a fc ff ff       	call   8015c9 <printnum>
			break;
  8019af:	83 c4 20             	add    $0x20,%esp
{
  8019b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8019b5:	83 c7 01             	add    $0x1,%edi
  8019b8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8019bc:	83 f8 25             	cmp    $0x25,%eax
  8019bf:	0f 84 6a fd ff ff    	je     80172f <vprintfmt+0x1b>
			if (ch == '\0')
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	0f 84 93 00 00 00    	je     801a60 <vprintfmt+0x34c>
			putch(ch, putdat);
  8019cd:	83 ec 08             	sub    $0x8,%esp
  8019d0:	56                   	push   %esi
  8019d1:	50                   	push   %eax
  8019d2:	ff d3                	call   *%ebx
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	eb dc                	jmp    8019b5 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8019d9:	89 ca                	mov    %ecx,%edx
  8019db:	8d 45 14             	lea    0x14(%ebp),%eax
  8019de:	e8 8f fc ff ff       	call   801672 <getuint>
  8019e3:	89 d1                	mov    %edx,%ecx
  8019e5:	89 c2                	mov    %eax,%edx
			base = 8;
  8019e7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8019ec:	eb aa                	jmp    801998 <vprintfmt+0x284>
			putch('0', putdat);
  8019ee:	83 ec 08             	sub    $0x8,%esp
  8019f1:	56                   	push   %esi
  8019f2:	6a 30                	push   $0x30
  8019f4:	ff d3                	call   *%ebx
			putch('x', putdat);
  8019f6:	83 c4 08             	add    $0x8,%esp
  8019f9:	56                   	push   %esi
  8019fa:	6a 78                	push   $0x78
  8019fc:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8019fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801a01:	8d 50 04             	lea    0x4(%eax),%edx
  801a04:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  801a07:	8b 10                	mov    (%eax),%edx
  801a09:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a0e:	83 c4 10             	add    $0x10,%esp
			base = 16;
  801a11:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801a16:	eb 80                	jmp    801998 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  801a18:	89 ca                	mov    %ecx,%edx
  801a1a:	8d 45 14             	lea    0x14(%ebp),%eax
  801a1d:	e8 50 fc ff ff       	call   801672 <getuint>
  801a22:	89 d1                	mov    %edx,%ecx
  801a24:	89 c2                	mov    %eax,%edx
			base = 16;
  801a26:	b8 10 00 00 00       	mov    $0x10,%eax
  801a2b:	e9 68 ff ff ff       	jmp    801998 <vprintfmt+0x284>
			putch(ch, putdat);
  801a30:	83 ec 08             	sub    $0x8,%esp
  801a33:	56                   	push   %esi
  801a34:	6a 25                	push   $0x25
  801a36:	ff d3                	call   *%ebx
			break;
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	e9 72 ff ff ff       	jmp    8019b2 <vprintfmt+0x29e>
			putch('%', putdat);
  801a40:	83 ec 08             	sub    $0x8,%esp
  801a43:	56                   	push   %esi
  801a44:	6a 25                	push   $0x25
  801a46:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a48:	83 c4 10             	add    $0x10,%esp
  801a4b:	89 f8                	mov    %edi,%eax
  801a4d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801a51:	74 05                	je     801a58 <vprintfmt+0x344>
  801a53:	83 e8 01             	sub    $0x1,%eax
  801a56:	eb f5                	jmp    801a4d <vprintfmt+0x339>
  801a58:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a5b:	e9 52 ff ff ff       	jmp    8019b2 <vprintfmt+0x29e>
}
  801a60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a63:	5b                   	pop    %ebx
  801a64:	5e                   	pop    %esi
  801a65:	5f                   	pop    %edi
  801a66:	5d                   	pop    %ebp
  801a67:	c3                   	ret    

00801a68 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a68:	f3 0f 1e fb          	endbr32 
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 18             	sub    $0x18,%esp
  801a72:	8b 45 08             	mov    0x8(%ebp),%eax
  801a75:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a78:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a7b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a7f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	74 26                	je     801ab3 <vsnprintf+0x4b>
  801a8d:	85 d2                	test   %edx,%edx
  801a8f:	7e 22                	jle    801ab3 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a91:	ff 75 14             	pushl  0x14(%ebp)
  801a94:	ff 75 10             	pushl  0x10(%ebp)
  801a97:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a9a:	50                   	push   %eax
  801a9b:	68 d2 16 80 00       	push   $0x8016d2
  801aa0:	e8 6f fc ff ff       	call   801714 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801aa5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801aa8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aae:	83 c4 10             	add    $0x10,%esp
}
  801ab1:	c9                   	leave  
  801ab2:	c3                   	ret    
		return -E_INVAL;
  801ab3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ab8:	eb f7                	jmp    801ab1 <vsnprintf+0x49>

00801aba <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801aba:	f3 0f 1e fb          	endbr32 
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801ac4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801ac7:	50                   	push   %eax
  801ac8:	ff 75 10             	pushl  0x10(%ebp)
  801acb:	ff 75 0c             	pushl  0xc(%ebp)
  801ace:	ff 75 08             	pushl  0x8(%ebp)
  801ad1:	e8 92 ff ff ff       	call   801a68 <vsnprintf>
	va_end(ap);

	return rc;
}
  801ad6:	c9                   	leave  
  801ad7:	c3                   	ret    

00801ad8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ad8:	f3 0f 1e fb          	endbr32 
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	56                   	push   %esi
  801ae0:	53                   	push   %ebx
  801ae1:	8b 75 08             	mov    0x8(%ebp),%esi
  801ae4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  801aea:	85 c0                	test   %eax,%eax
  801aec:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801af1:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801af4:	83 ec 0c             	sub    $0xc,%esp
  801af7:	50                   	push   %eax
  801af8:	e8 39 ec ff ff       	call   800736 <sys_ipc_recv>
	if (f < 0) {
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	85 c0                	test   %eax,%eax
  801b02:	78 2b                	js     801b2f <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801b04:	85 f6                	test   %esi,%esi
  801b06:	74 0a                	je     801b12 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801b08:	a1 04 40 80 00       	mov    0x804004,%eax
  801b0d:	8b 40 74             	mov    0x74(%eax),%eax
  801b10:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801b12:	85 db                	test   %ebx,%ebx
  801b14:	74 0a                	je     801b20 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801b16:	a1 04 40 80 00       	mov    0x804004,%eax
  801b1b:	8b 40 78             	mov    0x78(%eax),%eax
  801b1e:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  801b20:	a1 04 40 80 00       	mov    0x804004,%eax
  801b25:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2b:	5b                   	pop    %ebx
  801b2c:	5e                   	pop    %esi
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    
		if (from_env_store != NULL) {
  801b2f:	85 f6                	test   %esi,%esi
  801b31:	74 06                	je     801b39 <ipc_recv+0x61>
			*from_env_store = 0;
  801b33:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801b39:	85 db                	test   %ebx,%ebx
  801b3b:	74 eb                	je     801b28 <ipc_recv+0x50>
			*perm_store = 0;
  801b3d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b43:	eb e3                	jmp    801b28 <ipc_recv+0x50>

00801b45 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b45:	f3 0f 1e fb          	endbr32 
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	57                   	push   %edi
  801b4d:	56                   	push   %esi
  801b4e:	53                   	push   %ebx
  801b4f:	83 ec 0c             	sub    $0xc,%esp
  801b52:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b55:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  801b5b:	85 db                	test   %ebx,%ebx
  801b5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b62:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b65:	ff 75 14             	pushl  0x14(%ebp)
  801b68:	53                   	push   %ebx
  801b69:	56                   	push   %esi
  801b6a:	57                   	push   %edi
  801b6b:	e8 9d eb ff ff       	call   80070d <sys_ipc_try_send>
  801b70:	83 c4 10             	add    $0x10,%esp
  801b73:	85 c0                	test   %eax,%eax
  801b75:	79 19                	jns    801b90 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  801b77:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b7a:	74 e9                	je     801b65 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  801b7c:	83 ec 04             	sub    $0x4,%esp
  801b7f:	68 c0 22 80 00       	push   $0x8022c0
  801b84:	6a 48                	push   $0x48
  801b86:	68 e2 22 80 00       	push   $0x8022e2
  801b8b:	e8 3a f9 ff ff       	call   8014ca <_panic>
		}
	}
}
  801b90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b93:	5b                   	pop    %ebx
  801b94:	5e                   	pop    %esi
  801b95:	5f                   	pop    %edi
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    

00801b98 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b98:	f3 0f 1e fb          	endbr32 
  801b9c:	55                   	push   %ebp
  801b9d:	89 e5                	mov    %esp,%ebp
  801b9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ba2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ba7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801baa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bb0:	8b 52 50             	mov    0x50(%edx),%edx
  801bb3:	39 ca                	cmp    %ecx,%edx
  801bb5:	74 11                	je     801bc8 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801bb7:	83 c0 01             	add    $0x1,%eax
  801bba:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bbf:	75 e6                	jne    801ba7 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc6:	eb 0b                	jmp    801bd3 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801bc8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bcb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bd0:	8b 40 48             	mov    0x48(%eax),%eax
}
  801bd3:	5d                   	pop    %ebp
  801bd4:	c3                   	ret    

00801bd5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bd5:	f3 0f 1e fb          	endbr32 
  801bd9:	55                   	push   %ebp
  801bda:	89 e5                	mov    %esp,%ebp
  801bdc:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bdf:	89 c2                	mov    %eax,%edx
  801be1:	c1 ea 16             	shr    $0x16,%edx
  801be4:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801beb:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801bf0:	f6 c1 01             	test   $0x1,%cl
  801bf3:	74 1c                	je     801c11 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801bf5:	c1 e8 0c             	shr    $0xc,%eax
  801bf8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bff:	a8 01                	test   $0x1,%al
  801c01:	74 0e                	je     801c11 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c03:	c1 e8 0c             	shr    $0xc,%eax
  801c06:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c0d:	ef 
  801c0e:	0f b7 d2             	movzwl %dx,%edx
}
  801c11:	89 d0                	mov    %edx,%eax
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    
  801c15:	66 90                	xchg   %ax,%ax
  801c17:	66 90                	xchg   %ax,%ax
  801c19:	66 90                	xchg   %ax,%ax
  801c1b:	66 90                	xchg   %ax,%ax
  801c1d:	66 90                	xchg   %ax,%ax
  801c1f:	90                   	nop

00801c20 <__udivdi3>:
  801c20:	f3 0f 1e fb          	endbr32 
  801c24:	55                   	push   %ebp
  801c25:	57                   	push   %edi
  801c26:	56                   	push   %esi
  801c27:	53                   	push   %ebx
  801c28:	83 ec 1c             	sub    $0x1c,%esp
  801c2b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c33:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c37:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c3b:	85 d2                	test   %edx,%edx
  801c3d:	75 19                	jne    801c58 <__udivdi3+0x38>
  801c3f:	39 f3                	cmp    %esi,%ebx
  801c41:	76 4d                	jbe    801c90 <__udivdi3+0x70>
  801c43:	31 ff                	xor    %edi,%edi
  801c45:	89 e8                	mov    %ebp,%eax
  801c47:	89 f2                	mov    %esi,%edx
  801c49:	f7 f3                	div    %ebx
  801c4b:	89 fa                	mov    %edi,%edx
  801c4d:	83 c4 1c             	add    $0x1c,%esp
  801c50:	5b                   	pop    %ebx
  801c51:	5e                   	pop    %esi
  801c52:	5f                   	pop    %edi
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    
  801c55:	8d 76 00             	lea    0x0(%esi),%esi
  801c58:	39 f2                	cmp    %esi,%edx
  801c5a:	76 14                	jbe    801c70 <__udivdi3+0x50>
  801c5c:	31 ff                	xor    %edi,%edi
  801c5e:	31 c0                	xor    %eax,%eax
  801c60:	89 fa                	mov    %edi,%edx
  801c62:	83 c4 1c             	add    $0x1c,%esp
  801c65:	5b                   	pop    %ebx
  801c66:	5e                   	pop    %esi
  801c67:	5f                   	pop    %edi
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    
  801c6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c70:	0f bd fa             	bsr    %edx,%edi
  801c73:	83 f7 1f             	xor    $0x1f,%edi
  801c76:	75 48                	jne    801cc0 <__udivdi3+0xa0>
  801c78:	39 f2                	cmp    %esi,%edx
  801c7a:	72 06                	jb     801c82 <__udivdi3+0x62>
  801c7c:	31 c0                	xor    %eax,%eax
  801c7e:	39 eb                	cmp    %ebp,%ebx
  801c80:	77 de                	ja     801c60 <__udivdi3+0x40>
  801c82:	b8 01 00 00 00       	mov    $0x1,%eax
  801c87:	eb d7                	jmp    801c60 <__udivdi3+0x40>
  801c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c90:	89 d9                	mov    %ebx,%ecx
  801c92:	85 db                	test   %ebx,%ebx
  801c94:	75 0b                	jne    801ca1 <__udivdi3+0x81>
  801c96:	b8 01 00 00 00       	mov    $0x1,%eax
  801c9b:	31 d2                	xor    %edx,%edx
  801c9d:	f7 f3                	div    %ebx
  801c9f:	89 c1                	mov    %eax,%ecx
  801ca1:	31 d2                	xor    %edx,%edx
  801ca3:	89 f0                	mov    %esi,%eax
  801ca5:	f7 f1                	div    %ecx
  801ca7:	89 c6                	mov    %eax,%esi
  801ca9:	89 e8                	mov    %ebp,%eax
  801cab:	89 f7                	mov    %esi,%edi
  801cad:	f7 f1                	div    %ecx
  801caf:	89 fa                	mov    %edi,%edx
  801cb1:	83 c4 1c             	add    $0x1c,%esp
  801cb4:	5b                   	pop    %ebx
  801cb5:	5e                   	pop    %esi
  801cb6:	5f                   	pop    %edi
  801cb7:	5d                   	pop    %ebp
  801cb8:	c3                   	ret    
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	89 f9                	mov    %edi,%ecx
  801cc2:	b8 20 00 00 00       	mov    $0x20,%eax
  801cc7:	29 f8                	sub    %edi,%eax
  801cc9:	d3 e2                	shl    %cl,%edx
  801ccb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ccf:	89 c1                	mov    %eax,%ecx
  801cd1:	89 da                	mov    %ebx,%edx
  801cd3:	d3 ea                	shr    %cl,%edx
  801cd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801cd9:	09 d1                	or     %edx,%ecx
  801cdb:	89 f2                	mov    %esi,%edx
  801cdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ce1:	89 f9                	mov    %edi,%ecx
  801ce3:	d3 e3                	shl    %cl,%ebx
  801ce5:	89 c1                	mov    %eax,%ecx
  801ce7:	d3 ea                	shr    %cl,%edx
  801ce9:	89 f9                	mov    %edi,%ecx
  801ceb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801cef:	89 eb                	mov    %ebp,%ebx
  801cf1:	d3 e6                	shl    %cl,%esi
  801cf3:	89 c1                	mov    %eax,%ecx
  801cf5:	d3 eb                	shr    %cl,%ebx
  801cf7:	09 de                	or     %ebx,%esi
  801cf9:	89 f0                	mov    %esi,%eax
  801cfb:	f7 74 24 08          	divl   0x8(%esp)
  801cff:	89 d6                	mov    %edx,%esi
  801d01:	89 c3                	mov    %eax,%ebx
  801d03:	f7 64 24 0c          	mull   0xc(%esp)
  801d07:	39 d6                	cmp    %edx,%esi
  801d09:	72 15                	jb     801d20 <__udivdi3+0x100>
  801d0b:	89 f9                	mov    %edi,%ecx
  801d0d:	d3 e5                	shl    %cl,%ebp
  801d0f:	39 c5                	cmp    %eax,%ebp
  801d11:	73 04                	jae    801d17 <__udivdi3+0xf7>
  801d13:	39 d6                	cmp    %edx,%esi
  801d15:	74 09                	je     801d20 <__udivdi3+0x100>
  801d17:	89 d8                	mov    %ebx,%eax
  801d19:	31 ff                	xor    %edi,%edi
  801d1b:	e9 40 ff ff ff       	jmp    801c60 <__udivdi3+0x40>
  801d20:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d23:	31 ff                	xor    %edi,%edi
  801d25:	e9 36 ff ff ff       	jmp    801c60 <__udivdi3+0x40>
  801d2a:	66 90                	xchg   %ax,%ax
  801d2c:	66 90                	xchg   %ax,%ax
  801d2e:	66 90                	xchg   %ax,%ax

00801d30 <__umoddi3>:
  801d30:	f3 0f 1e fb          	endbr32 
  801d34:	55                   	push   %ebp
  801d35:	57                   	push   %edi
  801d36:	56                   	push   %esi
  801d37:	53                   	push   %ebx
  801d38:	83 ec 1c             	sub    $0x1c,%esp
  801d3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d3f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d43:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d47:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d4b:	85 c0                	test   %eax,%eax
  801d4d:	75 19                	jne    801d68 <__umoddi3+0x38>
  801d4f:	39 df                	cmp    %ebx,%edi
  801d51:	76 5d                	jbe    801db0 <__umoddi3+0x80>
  801d53:	89 f0                	mov    %esi,%eax
  801d55:	89 da                	mov    %ebx,%edx
  801d57:	f7 f7                	div    %edi
  801d59:	89 d0                	mov    %edx,%eax
  801d5b:	31 d2                	xor    %edx,%edx
  801d5d:	83 c4 1c             	add    $0x1c,%esp
  801d60:	5b                   	pop    %ebx
  801d61:	5e                   	pop    %esi
  801d62:	5f                   	pop    %edi
  801d63:	5d                   	pop    %ebp
  801d64:	c3                   	ret    
  801d65:	8d 76 00             	lea    0x0(%esi),%esi
  801d68:	89 f2                	mov    %esi,%edx
  801d6a:	39 d8                	cmp    %ebx,%eax
  801d6c:	76 12                	jbe    801d80 <__umoddi3+0x50>
  801d6e:	89 f0                	mov    %esi,%eax
  801d70:	89 da                	mov    %ebx,%edx
  801d72:	83 c4 1c             	add    $0x1c,%esp
  801d75:	5b                   	pop    %ebx
  801d76:	5e                   	pop    %esi
  801d77:	5f                   	pop    %edi
  801d78:	5d                   	pop    %ebp
  801d79:	c3                   	ret    
  801d7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d80:	0f bd e8             	bsr    %eax,%ebp
  801d83:	83 f5 1f             	xor    $0x1f,%ebp
  801d86:	75 50                	jne    801dd8 <__umoddi3+0xa8>
  801d88:	39 d8                	cmp    %ebx,%eax
  801d8a:	0f 82 e0 00 00 00    	jb     801e70 <__umoddi3+0x140>
  801d90:	89 d9                	mov    %ebx,%ecx
  801d92:	39 f7                	cmp    %esi,%edi
  801d94:	0f 86 d6 00 00 00    	jbe    801e70 <__umoddi3+0x140>
  801d9a:	89 d0                	mov    %edx,%eax
  801d9c:	89 ca                	mov    %ecx,%edx
  801d9e:	83 c4 1c             	add    $0x1c,%esp
  801da1:	5b                   	pop    %ebx
  801da2:	5e                   	pop    %esi
  801da3:	5f                   	pop    %edi
  801da4:	5d                   	pop    %ebp
  801da5:	c3                   	ret    
  801da6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dad:	8d 76 00             	lea    0x0(%esi),%esi
  801db0:	89 fd                	mov    %edi,%ebp
  801db2:	85 ff                	test   %edi,%edi
  801db4:	75 0b                	jne    801dc1 <__umoddi3+0x91>
  801db6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dbb:	31 d2                	xor    %edx,%edx
  801dbd:	f7 f7                	div    %edi
  801dbf:	89 c5                	mov    %eax,%ebp
  801dc1:	89 d8                	mov    %ebx,%eax
  801dc3:	31 d2                	xor    %edx,%edx
  801dc5:	f7 f5                	div    %ebp
  801dc7:	89 f0                	mov    %esi,%eax
  801dc9:	f7 f5                	div    %ebp
  801dcb:	89 d0                	mov    %edx,%eax
  801dcd:	31 d2                	xor    %edx,%edx
  801dcf:	eb 8c                	jmp    801d5d <__umoddi3+0x2d>
  801dd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dd8:	89 e9                	mov    %ebp,%ecx
  801dda:	ba 20 00 00 00       	mov    $0x20,%edx
  801ddf:	29 ea                	sub    %ebp,%edx
  801de1:	d3 e0                	shl    %cl,%eax
  801de3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801de7:	89 d1                	mov    %edx,%ecx
  801de9:	89 f8                	mov    %edi,%eax
  801deb:	d3 e8                	shr    %cl,%eax
  801ded:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801df1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801df5:	8b 54 24 04          	mov    0x4(%esp),%edx
  801df9:	09 c1                	or     %eax,%ecx
  801dfb:	89 d8                	mov    %ebx,%eax
  801dfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e01:	89 e9                	mov    %ebp,%ecx
  801e03:	d3 e7                	shl    %cl,%edi
  801e05:	89 d1                	mov    %edx,%ecx
  801e07:	d3 e8                	shr    %cl,%eax
  801e09:	89 e9                	mov    %ebp,%ecx
  801e0b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e0f:	d3 e3                	shl    %cl,%ebx
  801e11:	89 c7                	mov    %eax,%edi
  801e13:	89 d1                	mov    %edx,%ecx
  801e15:	89 f0                	mov    %esi,%eax
  801e17:	d3 e8                	shr    %cl,%eax
  801e19:	89 e9                	mov    %ebp,%ecx
  801e1b:	89 fa                	mov    %edi,%edx
  801e1d:	d3 e6                	shl    %cl,%esi
  801e1f:	09 d8                	or     %ebx,%eax
  801e21:	f7 74 24 08          	divl   0x8(%esp)
  801e25:	89 d1                	mov    %edx,%ecx
  801e27:	89 f3                	mov    %esi,%ebx
  801e29:	f7 64 24 0c          	mull   0xc(%esp)
  801e2d:	89 c6                	mov    %eax,%esi
  801e2f:	89 d7                	mov    %edx,%edi
  801e31:	39 d1                	cmp    %edx,%ecx
  801e33:	72 06                	jb     801e3b <__umoddi3+0x10b>
  801e35:	75 10                	jne    801e47 <__umoddi3+0x117>
  801e37:	39 c3                	cmp    %eax,%ebx
  801e39:	73 0c                	jae    801e47 <__umoddi3+0x117>
  801e3b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801e3f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801e43:	89 d7                	mov    %edx,%edi
  801e45:	89 c6                	mov    %eax,%esi
  801e47:	89 ca                	mov    %ecx,%edx
  801e49:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e4e:	29 f3                	sub    %esi,%ebx
  801e50:	19 fa                	sbb    %edi,%edx
  801e52:	89 d0                	mov    %edx,%eax
  801e54:	d3 e0                	shl    %cl,%eax
  801e56:	89 e9                	mov    %ebp,%ecx
  801e58:	d3 eb                	shr    %cl,%ebx
  801e5a:	d3 ea                	shr    %cl,%edx
  801e5c:	09 d8                	or     %ebx,%eax
  801e5e:	83 c4 1c             	add    $0x1c,%esp
  801e61:	5b                   	pop    %ebx
  801e62:	5e                   	pop    %esi
  801e63:	5f                   	pop    %edi
  801e64:	5d                   	pop    %ebp
  801e65:	c3                   	ret    
  801e66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e6d:	8d 76 00             	lea    0x0(%esi),%esi
  801e70:	29 fe                	sub    %edi,%esi
  801e72:	19 c3                	sbb    %eax,%ebx
  801e74:	89 f2                	mov    %esi,%edx
  801e76:	89 d9                	mov    %ebx,%ecx
  801e78:	e9 1d ff ff ff       	jmp    801d9a <__umoddi3+0x6a>
