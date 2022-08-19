
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 21 00 00 00       	call   800052 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  80003d:	68 00 00 10 00       	push   $0x100000
  800042:	ff 35 00 30 80 00    	pushl  0x803000
  800048:	e8 ba 00 00 00       	call   800107 <sys_cputs>
}
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	c9                   	leave  
  800051:	c3                   	ret    

00800052 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800052:	f3 0f 1e fb          	endbr32 
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	56                   	push   %esi
  80005a:	53                   	push   %ebx
  80005b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800061:	e8 19 01 00 00       	call   80017f <sys_getenvid>
	if (id >= 0)
  800066:	85 c0                	test   %eax,%eax
  800068:	78 12                	js     80007c <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  80006a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800072:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800077:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007c:	85 db                	test   %ebx,%ebx
  80007e:	7e 07                	jle    800087 <libmain+0x35>
		binaryname = argv[0];
  800080:	8b 06                	mov    (%esi),%eax
  800082:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	56                   	push   %esi
  80008b:	53                   	push   %ebx
  80008c:	e8 a2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800091:	e8 0a 00 00 00       	call   8000a0 <exit>
}
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009c:	5b                   	pop    %ebx
  80009d:	5e                   	pop    %esi
  80009e:	5d                   	pop    %ebp
  80009f:	c3                   	ret    

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	f3 0f 1e fb          	endbr32 
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 53 04 00 00       	call   800502 <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 a0 00 00 00       	call   800159 <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 1c             	sub    $0x1c,%esp
  8000c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000ca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000cd:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000d5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000d8:	8b 75 14             	mov    0x14(%ebp),%esi
  8000db:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000dd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000e1:	74 04                	je     8000e7 <syscall+0x29>
  8000e3:	85 c0                	test   %eax,%eax
  8000e5:	7f 08                	jg     8000ef <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5f                   	pop    %edi
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ef:	83 ec 0c             	sub    $0xc,%esp
  8000f2:	50                   	push   %eax
  8000f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8000f6:	68 f8 1d 80 00       	push   $0x801df8
  8000fb:	6a 23                	push   $0x23
  8000fd:	68 15 1e 80 00       	push   $0x801e15
  800102:	e8 76 0f 00 00       	call   80107d <_panic>

00800107 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800107:	f3 0f 1e fb          	endbr32 
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800111:	6a 00                	push   $0x0
  800113:	6a 00                	push   $0x0
  800115:	6a 00                	push   $0x0
  800117:	ff 75 0c             	pushl  0xc(%ebp)
  80011a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 00 00 00 00       	mov    $0x0,%eax
  800127:	e8 92 ff ff ff       	call   8000be <syscall>
}
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	c9                   	leave  
  800130:	c3                   	ret    

00800131 <sys_cgetc>:

int
sys_cgetc(void)
{
  800131:	f3 0f 1e fb          	endbr32 
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80013b:	6a 00                	push   $0x0
  80013d:	6a 00                	push   $0x0
  80013f:	6a 00                	push   $0x0
  800141:	6a 00                	push   $0x0
  800143:	b9 00 00 00 00       	mov    $0x0,%ecx
  800148:	ba 00 00 00 00       	mov    $0x0,%edx
  80014d:	b8 01 00 00 00       	mov    $0x1,%eax
  800152:	e8 67 ff ff ff       	call   8000be <syscall>
}
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800159:	f3 0f 1e fb          	endbr32 
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800163:	6a 00                	push   $0x0
  800165:	6a 00                	push   $0x0
  800167:	6a 00                	push   $0x0
  800169:	6a 00                	push   $0x0
  80016b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016e:	ba 01 00 00 00       	mov    $0x1,%edx
  800173:	b8 03 00 00 00       	mov    $0x3,%eax
  800178:	e8 41 ff ff ff       	call   8000be <syscall>
}
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80017f:	f3 0f 1e fb          	endbr32 
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800189:	6a 00                	push   $0x0
  80018b:	6a 00                	push   $0x0
  80018d:	6a 00                	push   $0x0
  80018f:	6a 00                	push   $0x0
  800191:	b9 00 00 00 00       	mov    $0x0,%ecx
  800196:	ba 00 00 00 00       	mov    $0x0,%edx
  80019b:	b8 02 00 00 00       	mov    $0x2,%eax
  8001a0:	e8 19 ff ff ff       	call   8000be <syscall>
}
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <sys_yield>:

void
sys_yield(void)
{
  8001a7:	f3 0f 1e fb          	endbr32 
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001b1:	6a 00                	push   $0x0
  8001b3:	6a 00                	push   $0x0
  8001b5:	6a 00                	push   $0x0
  8001b7:	6a 00                	push   $0x0
  8001b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001be:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001c8:	e8 f1 fe ff ff       	call   8000be <syscall>
}
  8001cd:	83 c4 10             	add    $0x10,%esp
  8001d0:	c9                   	leave  
  8001d1:	c3                   	ret    

008001d2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001d2:	f3 0f 1e fb          	endbr32 
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001dc:	6a 00                	push   $0x0
  8001de:	6a 00                	push   $0x0
  8001e0:	ff 75 10             	pushl  0x10(%ebp)
  8001e3:	ff 75 0c             	pushl  0xc(%ebp)
  8001e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e9:	ba 01 00 00 00       	mov    $0x1,%edx
  8001ee:	b8 04 00 00 00       	mov    $0x4,%eax
  8001f3:	e8 c6 fe ff ff       	call   8000be <syscall>
}
  8001f8:	c9                   	leave  
  8001f9:	c3                   	ret    

008001fa <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001fa:	f3 0f 1e fb          	endbr32 
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800204:	ff 75 18             	pushl  0x18(%ebp)
  800207:	ff 75 14             	pushl  0x14(%ebp)
  80020a:	ff 75 10             	pushl  0x10(%ebp)
  80020d:	ff 75 0c             	pushl  0xc(%ebp)
  800210:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800213:	ba 01 00 00 00       	mov    $0x1,%edx
  800218:	b8 05 00 00 00       	mov    $0x5,%eax
  80021d:	e8 9c fe ff ff       	call   8000be <syscall>
}
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800224:	f3 0f 1e fb          	endbr32 
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80022e:	6a 00                	push   $0x0
  800230:	6a 00                	push   $0x0
  800232:	6a 00                	push   $0x0
  800234:	ff 75 0c             	pushl  0xc(%ebp)
  800237:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023a:	ba 01 00 00 00       	mov    $0x1,%edx
  80023f:	b8 06 00 00 00       	mov    $0x6,%eax
  800244:	e8 75 fe ff ff       	call   8000be <syscall>
}
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80024b:	f3 0f 1e fb          	endbr32 
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800255:	6a 00                	push   $0x0
  800257:	6a 00                	push   $0x0
  800259:	6a 00                	push   $0x0
  80025b:	ff 75 0c             	pushl  0xc(%ebp)
  80025e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800261:	ba 01 00 00 00       	mov    $0x1,%edx
  800266:	b8 08 00 00 00       	mov    $0x8,%eax
  80026b:	e8 4e fe ff ff       	call   8000be <syscall>
}
  800270:	c9                   	leave  
  800271:	c3                   	ret    

00800272 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800272:	f3 0f 1e fb          	endbr32 
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80027c:	6a 00                	push   $0x0
  80027e:	6a 00                	push   $0x0
  800280:	6a 00                	push   $0x0
  800282:	ff 75 0c             	pushl  0xc(%ebp)
  800285:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800288:	ba 01 00 00 00       	mov    $0x1,%edx
  80028d:	b8 09 00 00 00       	mov    $0x9,%eax
  800292:	e8 27 fe ff ff       	call   8000be <syscall>
}
  800297:	c9                   	leave  
  800298:	c3                   	ret    

00800299 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800299:	f3 0f 1e fb          	endbr32 
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8002a3:	6a 00                	push   $0x0
  8002a5:	6a 00                	push   $0x0
  8002a7:	6a 00                	push   $0x0
  8002a9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002af:	ba 01 00 00 00       	mov    $0x1,%edx
  8002b4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b9:	e8 00 fe ff ff       	call   8000be <syscall>
}
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    

008002c0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002c0:	f3 0f 1e fb          	endbr32 
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002ca:	6a 00                	push   $0x0
  8002cc:	ff 75 14             	pushl  0x14(%ebp)
  8002cf:	ff 75 10             	pushl  0x10(%ebp)
  8002d2:	ff 75 0c             	pushl  0xc(%ebp)
  8002d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e2:	e8 d7 fd ff ff       	call   8000be <syscall>
}
  8002e7:	c9                   	leave  
  8002e8:	c3                   	ret    

008002e9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002e9:	f3 0f 1e fb          	endbr32 
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002f3:	6a 00                	push   $0x0
  8002f5:	6a 00                	push   $0x0
  8002f7:	6a 00                	push   $0x0
  8002f9:	6a 00                	push   $0x0
  8002fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002fe:	ba 01 00 00 00       	mov    $0x1,%edx
  800303:	b8 0d 00 00 00       	mov    $0xd,%eax
  800308:	e8 b1 fd ff ff       	call   8000be <syscall>
}
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80030f:	f3 0f 1e fb          	endbr32 
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800316:	8b 45 08             	mov    0x8(%ebp),%eax
  800319:	05 00 00 00 30       	add    $0x30000000,%eax
  80031e:	c1 e8 0c             	shr    $0xc,%eax
}
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800323:	f3 0f 1e fb          	endbr32 
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  80032d:	ff 75 08             	pushl  0x8(%ebp)
  800330:	e8 da ff ff ff       	call   80030f <fd2num>
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	c1 e0 0c             	shl    $0xc,%eax
  80033b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800342:	f3 0f 1e fb          	endbr32 
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80034e:	89 c2                	mov    %eax,%edx
  800350:	c1 ea 16             	shr    $0x16,%edx
  800353:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80035a:	f6 c2 01             	test   $0x1,%dl
  80035d:	74 2d                	je     80038c <fd_alloc+0x4a>
  80035f:	89 c2                	mov    %eax,%edx
  800361:	c1 ea 0c             	shr    $0xc,%edx
  800364:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80036b:	f6 c2 01             	test   $0x1,%dl
  80036e:	74 1c                	je     80038c <fd_alloc+0x4a>
  800370:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800375:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80037a:	75 d2                	jne    80034e <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80037c:	8b 45 08             	mov    0x8(%ebp),%eax
  80037f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800385:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80038a:	eb 0a                	jmp    800396 <fd_alloc+0x54>
			*fd_store = fd;
  80038c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800391:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800396:	5d                   	pop    %ebp
  800397:	c3                   	ret    

00800398 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800398:	f3 0f 1e fb          	endbr32 
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003a2:	83 f8 1f             	cmp    $0x1f,%eax
  8003a5:	77 30                	ja     8003d7 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003a7:	c1 e0 0c             	shl    $0xc,%eax
  8003aa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003af:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003b5:	f6 c2 01             	test   $0x1,%dl
  8003b8:	74 24                	je     8003de <fd_lookup+0x46>
  8003ba:	89 c2                	mov    %eax,%edx
  8003bc:	c1 ea 0c             	shr    $0xc,%edx
  8003bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c6:	f6 c2 01             	test   $0x1,%dl
  8003c9:	74 1a                	je     8003e5 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ce:	89 02                	mov    %eax,(%edx)
	return 0;
  8003d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    
		return -E_INVAL;
  8003d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003dc:	eb f7                	jmp    8003d5 <fd_lookup+0x3d>
		return -E_INVAL;
  8003de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003e3:	eb f0                	jmp    8003d5 <fd_lookup+0x3d>
  8003e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003ea:	eb e9                	jmp    8003d5 <fd_lookup+0x3d>

008003ec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003ec:	f3 0f 1e fb          	endbr32 
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	83 ec 08             	sub    $0x8,%esp
  8003f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f9:	ba a0 1e 80 00       	mov    $0x801ea0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8003fe:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
  800403:	39 08                	cmp    %ecx,(%eax)
  800405:	74 33                	je     80043a <dev_lookup+0x4e>
  800407:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80040a:	8b 02                	mov    (%edx),%eax
  80040c:	85 c0                	test   %eax,%eax
  80040e:	75 f3                	jne    800403 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800410:	a1 04 40 80 00       	mov    0x804004,%eax
  800415:	8b 40 48             	mov    0x48(%eax),%eax
  800418:	83 ec 04             	sub    $0x4,%esp
  80041b:	51                   	push   %ecx
  80041c:	50                   	push   %eax
  80041d:	68 24 1e 80 00       	push   $0x801e24
  800422:	e8 3d 0d 00 00       	call   801164 <cprintf>
	*dev = 0;
  800427:	8b 45 0c             	mov    0xc(%ebp),%eax
  80042a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800430:	83 c4 10             	add    $0x10,%esp
  800433:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800438:	c9                   	leave  
  800439:	c3                   	ret    
			*dev = devtab[i];
  80043a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	eb f2                	jmp    800438 <dev_lookup+0x4c>

00800446 <fd_close>:
{
  800446:	f3 0f 1e fb          	endbr32 
  80044a:	55                   	push   %ebp
  80044b:	89 e5                	mov    %esp,%ebp
  80044d:	57                   	push   %edi
  80044e:	56                   	push   %esi
  80044f:	53                   	push   %ebx
  800450:	83 ec 28             	sub    $0x28,%esp
  800453:	8b 75 08             	mov    0x8(%ebp),%esi
  800456:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800459:	56                   	push   %esi
  80045a:	e8 b0 fe ff ff       	call   80030f <fd2num>
  80045f:	83 c4 08             	add    $0x8,%esp
  800462:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800465:	52                   	push   %edx
  800466:	50                   	push   %eax
  800467:	e8 2c ff ff ff       	call   800398 <fd_lookup>
  80046c:	89 c3                	mov    %eax,%ebx
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	85 c0                	test   %eax,%eax
  800473:	78 05                	js     80047a <fd_close+0x34>
	    || fd != fd2)
  800475:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800478:	74 16                	je     800490 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80047a:	89 f8                	mov    %edi,%eax
  80047c:	84 c0                	test   %al,%al
  80047e:	b8 00 00 00 00       	mov    $0x0,%eax
  800483:	0f 44 d8             	cmove  %eax,%ebx
}
  800486:	89 d8                	mov    %ebx,%eax
  800488:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048b:	5b                   	pop    %ebx
  80048c:	5e                   	pop    %esi
  80048d:	5f                   	pop    %edi
  80048e:	5d                   	pop    %ebp
  80048f:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800496:	50                   	push   %eax
  800497:	ff 36                	pushl  (%esi)
  800499:	e8 4e ff ff ff       	call   8003ec <dev_lookup>
  80049e:	89 c3                	mov    %eax,%ebx
  8004a0:	83 c4 10             	add    $0x10,%esp
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	78 1a                	js     8004c1 <fd_close+0x7b>
		if (dev->dev_close)
  8004a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004aa:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004ad:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004b2:	85 c0                	test   %eax,%eax
  8004b4:	74 0b                	je     8004c1 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004b6:	83 ec 0c             	sub    $0xc,%esp
  8004b9:	56                   	push   %esi
  8004ba:	ff d0                	call   *%eax
  8004bc:	89 c3                	mov    %eax,%ebx
  8004be:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	56                   	push   %esi
  8004c5:	6a 00                	push   $0x0
  8004c7:	e8 58 fd ff ff       	call   800224 <sys_page_unmap>
	return r;
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	eb b5                	jmp    800486 <fd_close+0x40>

008004d1 <close>:

int
close(int fdnum)
{
  8004d1:	f3 0f 1e fb          	endbr32 
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004de:	50                   	push   %eax
  8004df:	ff 75 08             	pushl  0x8(%ebp)
  8004e2:	e8 b1 fe ff ff       	call   800398 <fd_lookup>
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	85 c0                	test   %eax,%eax
  8004ec:	79 02                	jns    8004f0 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004ee:	c9                   	leave  
  8004ef:	c3                   	ret    
		return fd_close(fd, 1);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	6a 01                	push   $0x1
  8004f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8004f8:	e8 49 ff ff ff       	call   800446 <fd_close>
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	eb ec                	jmp    8004ee <close+0x1d>

00800502 <close_all>:

void
close_all(void)
{
  800502:	f3 0f 1e fb          	endbr32 
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	53                   	push   %ebx
  80050a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80050d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800512:	83 ec 0c             	sub    $0xc,%esp
  800515:	53                   	push   %ebx
  800516:	e8 b6 ff ff ff       	call   8004d1 <close>
	for (i = 0; i < MAXFD; i++)
  80051b:	83 c3 01             	add    $0x1,%ebx
  80051e:	83 c4 10             	add    $0x10,%esp
  800521:	83 fb 20             	cmp    $0x20,%ebx
  800524:	75 ec                	jne    800512 <close_all+0x10>
}
  800526:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800529:	c9                   	leave  
  80052a:	c3                   	ret    

0080052b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80052b:	f3 0f 1e fb          	endbr32 
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
  800532:	57                   	push   %edi
  800533:	56                   	push   %esi
  800534:	53                   	push   %ebx
  800535:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800538:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80053b:	50                   	push   %eax
  80053c:	ff 75 08             	pushl  0x8(%ebp)
  80053f:	e8 54 fe ff ff       	call   800398 <fd_lookup>
  800544:	89 c3                	mov    %eax,%ebx
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	85 c0                	test   %eax,%eax
  80054b:	0f 88 81 00 00 00    	js     8005d2 <dup+0xa7>
		return r;
	close(newfdnum);
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	ff 75 0c             	pushl  0xc(%ebp)
  800557:	e8 75 ff ff ff       	call   8004d1 <close>

	newfd = INDEX2FD(newfdnum);
  80055c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80055f:	c1 e6 0c             	shl    $0xc,%esi
  800562:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800568:	83 c4 04             	add    $0x4,%esp
  80056b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80056e:	e8 b0 fd ff ff       	call   800323 <fd2data>
  800573:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800575:	89 34 24             	mov    %esi,(%esp)
  800578:	e8 a6 fd ff ff       	call   800323 <fd2data>
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800582:	89 d8                	mov    %ebx,%eax
  800584:	c1 e8 16             	shr    $0x16,%eax
  800587:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80058e:	a8 01                	test   $0x1,%al
  800590:	74 11                	je     8005a3 <dup+0x78>
  800592:	89 d8                	mov    %ebx,%eax
  800594:	c1 e8 0c             	shr    $0xc,%eax
  800597:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80059e:	f6 c2 01             	test   $0x1,%dl
  8005a1:	75 39                	jne    8005dc <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005a6:	89 d0                	mov    %edx,%eax
  8005a8:	c1 e8 0c             	shr    $0xc,%eax
  8005ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b2:	83 ec 0c             	sub    $0xc,%esp
  8005b5:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ba:	50                   	push   %eax
  8005bb:	56                   	push   %esi
  8005bc:	6a 00                	push   $0x0
  8005be:	52                   	push   %edx
  8005bf:	6a 00                	push   $0x0
  8005c1:	e8 34 fc ff ff       	call   8001fa <sys_page_map>
  8005c6:	89 c3                	mov    %eax,%ebx
  8005c8:	83 c4 20             	add    $0x20,%esp
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	78 31                	js     800600 <dup+0xd5>
		goto err;

	return newfdnum;
  8005cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005d2:	89 d8                	mov    %ebx,%eax
  8005d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005d7:	5b                   	pop    %ebx
  8005d8:	5e                   	pop    %esi
  8005d9:	5f                   	pop    %edi
  8005da:	5d                   	pop    %ebp
  8005db:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005eb:	50                   	push   %eax
  8005ec:	57                   	push   %edi
  8005ed:	6a 00                	push   $0x0
  8005ef:	53                   	push   %ebx
  8005f0:	6a 00                	push   $0x0
  8005f2:	e8 03 fc ff ff       	call   8001fa <sys_page_map>
  8005f7:	89 c3                	mov    %eax,%ebx
  8005f9:	83 c4 20             	add    $0x20,%esp
  8005fc:	85 c0                	test   %eax,%eax
  8005fe:	79 a3                	jns    8005a3 <dup+0x78>
	sys_page_unmap(0, newfd);
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	56                   	push   %esi
  800604:	6a 00                	push   $0x0
  800606:	e8 19 fc ff ff       	call   800224 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80060b:	83 c4 08             	add    $0x8,%esp
  80060e:	57                   	push   %edi
  80060f:	6a 00                	push   $0x0
  800611:	e8 0e fc ff ff       	call   800224 <sys_page_unmap>
	return r;
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	eb b7                	jmp    8005d2 <dup+0xa7>

0080061b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80061b:	f3 0f 1e fb          	endbr32 
  80061f:	55                   	push   %ebp
  800620:	89 e5                	mov    %esp,%ebp
  800622:	53                   	push   %ebx
  800623:	83 ec 1c             	sub    $0x1c,%esp
  800626:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800629:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80062c:	50                   	push   %eax
  80062d:	53                   	push   %ebx
  80062e:	e8 65 fd ff ff       	call   800398 <fd_lookup>
  800633:	83 c4 10             	add    $0x10,%esp
  800636:	85 c0                	test   %eax,%eax
  800638:	78 3f                	js     800679 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800640:	50                   	push   %eax
  800641:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800644:	ff 30                	pushl  (%eax)
  800646:	e8 a1 fd ff ff       	call   8003ec <dev_lookup>
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	85 c0                	test   %eax,%eax
  800650:	78 27                	js     800679 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800652:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800655:	8b 42 08             	mov    0x8(%edx),%eax
  800658:	83 e0 03             	and    $0x3,%eax
  80065b:	83 f8 01             	cmp    $0x1,%eax
  80065e:	74 1e                	je     80067e <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800663:	8b 40 08             	mov    0x8(%eax),%eax
  800666:	85 c0                	test   %eax,%eax
  800668:	74 35                	je     80069f <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80066a:	83 ec 04             	sub    $0x4,%esp
  80066d:	ff 75 10             	pushl  0x10(%ebp)
  800670:	ff 75 0c             	pushl  0xc(%ebp)
  800673:	52                   	push   %edx
  800674:	ff d0                	call   *%eax
  800676:	83 c4 10             	add    $0x10,%esp
}
  800679:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80067c:	c9                   	leave  
  80067d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067e:	a1 04 40 80 00       	mov    0x804004,%eax
  800683:	8b 40 48             	mov    0x48(%eax),%eax
  800686:	83 ec 04             	sub    $0x4,%esp
  800689:	53                   	push   %ebx
  80068a:	50                   	push   %eax
  80068b:	68 65 1e 80 00       	push   $0x801e65
  800690:	e8 cf 0a 00 00       	call   801164 <cprintf>
		return -E_INVAL;
  800695:	83 c4 10             	add    $0x10,%esp
  800698:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80069d:	eb da                	jmp    800679 <read+0x5e>
		return -E_NOT_SUPP;
  80069f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006a4:	eb d3                	jmp    800679 <read+0x5e>

008006a6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006a6:	f3 0f 1e fb          	endbr32 
  8006aa:	55                   	push   %ebp
  8006ab:	89 e5                	mov    %esp,%ebp
  8006ad:	57                   	push   %edi
  8006ae:	56                   	push   %esi
  8006af:	53                   	push   %ebx
  8006b0:	83 ec 0c             	sub    $0xc,%esp
  8006b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006be:	eb 02                	jmp    8006c2 <readn+0x1c>
  8006c0:	01 c3                	add    %eax,%ebx
  8006c2:	39 f3                	cmp    %esi,%ebx
  8006c4:	73 21                	jae    8006e7 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c6:	83 ec 04             	sub    $0x4,%esp
  8006c9:	89 f0                	mov    %esi,%eax
  8006cb:	29 d8                	sub    %ebx,%eax
  8006cd:	50                   	push   %eax
  8006ce:	89 d8                	mov    %ebx,%eax
  8006d0:	03 45 0c             	add    0xc(%ebp),%eax
  8006d3:	50                   	push   %eax
  8006d4:	57                   	push   %edi
  8006d5:	e8 41 ff ff ff       	call   80061b <read>
		if (m < 0)
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	85 c0                	test   %eax,%eax
  8006df:	78 04                	js     8006e5 <readn+0x3f>
			return m;
		if (m == 0)
  8006e1:	75 dd                	jne    8006c0 <readn+0x1a>
  8006e3:	eb 02                	jmp    8006e7 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e5:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006e7:	89 d8                	mov    %ebx,%eax
  8006e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ec:	5b                   	pop    %ebx
  8006ed:	5e                   	pop    %esi
  8006ee:	5f                   	pop    %edi
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    

008006f1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006f1:	f3 0f 1e fb          	endbr32 
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	53                   	push   %ebx
  8006f9:	83 ec 1c             	sub    $0x1c,%esp
  8006fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	53                   	push   %ebx
  800704:	e8 8f fc ff ff       	call   800398 <fd_lookup>
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	85 c0                	test   %eax,%eax
  80070e:	78 3a                	js     80074a <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800716:	50                   	push   %eax
  800717:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80071a:	ff 30                	pushl  (%eax)
  80071c:	e8 cb fc ff ff       	call   8003ec <dev_lookup>
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	85 c0                	test   %eax,%eax
  800726:	78 22                	js     80074a <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800728:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80072f:	74 1e                	je     80074f <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800731:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800734:	8b 52 0c             	mov    0xc(%edx),%edx
  800737:	85 d2                	test   %edx,%edx
  800739:	74 35                	je     800770 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80073b:	83 ec 04             	sub    $0x4,%esp
  80073e:	ff 75 10             	pushl  0x10(%ebp)
  800741:	ff 75 0c             	pushl  0xc(%ebp)
  800744:	50                   	push   %eax
  800745:	ff d2                	call   *%edx
  800747:	83 c4 10             	add    $0x10,%esp
}
  80074a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80074d:	c9                   	leave  
  80074e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074f:	a1 04 40 80 00       	mov    0x804004,%eax
  800754:	8b 40 48             	mov    0x48(%eax),%eax
  800757:	83 ec 04             	sub    $0x4,%esp
  80075a:	53                   	push   %ebx
  80075b:	50                   	push   %eax
  80075c:	68 81 1e 80 00       	push   $0x801e81
  800761:	e8 fe 09 00 00       	call   801164 <cprintf>
		return -E_INVAL;
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076e:	eb da                	jmp    80074a <write+0x59>
		return -E_NOT_SUPP;
  800770:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800775:	eb d3                	jmp    80074a <write+0x59>

00800777 <seek>:

int
seek(int fdnum, off_t offset)
{
  800777:	f3 0f 1e fb          	endbr32 
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800781:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800784:	50                   	push   %eax
  800785:	ff 75 08             	pushl  0x8(%ebp)
  800788:	e8 0b fc ff ff       	call   800398 <fd_lookup>
  80078d:	83 c4 10             	add    $0x10,%esp
  800790:	85 c0                	test   %eax,%eax
  800792:	78 0e                	js     8007a2 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800794:	8b 55 0c             	mov    0xc(%ebp),%edx
  800797:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80079d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007a2:	c9                   	leave  
  8007a3:	c3                   	ret    

008007a4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007a4:	f3 0f 1e fb          	endbr32 
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	83 ec 1c             	sub    $0x1c,%esp
  8007af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b5:	50                   	push   %eax
  8007b6:	53                   	push   %ebx
  8007b7:	e8 dc fb ff ff       	call   800398 <fd_lookup>
  8007bc:	83 c4 10             	add    $0x10,%esp
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	78 37                	js     8007fa <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c3:	83 ec 08             	sub    $0x8,%esp
  8007c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c9:	50                   	push   %eax
  8007ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007cd:	ff 30                	pushl  (%eax)
  8007cf:	e8 18 fc ff ff       	call   8003ec <dev_lookup>
  8007d4:	83 c4 10             	add    $0x10,%esp
  8007d7:	85 c0                	test   %eax,%eax
  8007d9:	78 1f                	js     8007fa <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007de:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007e2:	74 1b                	je     8007ff <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007e7:	8b 52 18             	mov    0x18(%edx),%edx
  8007ea:	85 d2                	test   %edx,%edx
  8007ec:	74 32                	je     800820 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	ff 75 0c             	pushl  0xc(%ebp)
  8007f4:	50                   	push   %eax
  8007f5:	ff d2                	call   *%edx
  8007f7:	83 c4 10             	add    $0x10,%esp
}
  8007fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007ff:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800804:	8b 40 48             	mov    0x48(%eax),%eax
  800807:	83 ec 04             	sub    $0x4,%esp
  80080a:	53                   	push   %ebx
  80080b:	50                   	push   %eax
  80080c:	68 44 1e 80 00       	push   $0x801e44
  800811:	e8 4e 09 00 00       	call   801164 <cprintf>
		return -E_INVAL;
  800816:	83 c4 10             	add    $0x10,%esp
  800819:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081e:	eb da                	jmp    8007fa <ftruncate+0x56>
		return -E_NOT_SUPP;
  800820:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800825:	eb d3                	jmp    8007fa <ftruncate+0x56>

00800827 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800827:	f3 0f 1e fb          	endbr32 
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	83 ec 1c             	sub    $0x1c,%esp
  800832:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800835:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800838:	50                   	push   %eax
  800839:	ff 75 08             	pushl  0x8(%ebp)
  80083c:	e8 57 fb ff ff       	call   800398 <fd_lookup>
  800841:	83 c4 10             	add    $0x10,%esp
  800844:	85 c0                	test   %eax,%eax
  800846:	78 4b                	js     800893 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800848:	83 ec 08             	sub    $0x8,%esp
  80084b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80084e:	50                   	push   %eax
  80084f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800852:	ff 30                	pushl  (%eax)
  800854:	e8 93 fb ff ff       	call   8003ec <dev_lookup>
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	85 c0                	test   %eax,%eax
  80085e:	78 33                	js     800893 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800860:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800863:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800867:	74 2f                	je     800898 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800869:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80086c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800873:	00 00 00 
	stat->st_isdir = 0;
  800876:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80087d:	00 00 00 
	stat->st_dev = dev;
  800880:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	53                   	push   %ebx
  80088a:	ff 75 f0             	pushl  -0x10(%ebp)
  80088d:	ff 50 14             	call   *0x14(%eax)
  800890:	83 c4 10             	add    $0x10,%esp
}
  800893:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800896:	c9                   	leave  
  800897:	c3                   	ret    
		return -E_NOT_SUPP;
  800898:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80089d:	eb f4                	jmp    800893 <fstat+0x6c>

0080089f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80089f:	f3 0f 1e fb          	endbr32 
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	6a 00                	push   $0x0
  8008ad:	ff 75 08             	pushl  0x8(%ebp)
  8008b0:	e8 20 02 00 00       	call   800ad5 <open>
  8008b5:	89 c3                	mov    %eax,%ebx
  8008b7:	83 c4 10             	add    $0x10,%esp
  8008ba:	85 c0                	test   %eax,%eax
  8008bc:	78 1b                	js     8008d9 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	ff 75 0c             	pushl  0xc(%ebp)
  8008c4:	50                   	push   %eax
  8008c5:	e8 5d ff ff ff       	call   800827 <fstat>
  8008ca:	89 c6                	mov    %eax,%esi
	close(fd);
  8008cc:	89 1c 24             	mov    %ebx,(%esp)
  8008cf:	e8 fd fb ff ff       	call   8004d1 <close>
	return r;
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	89 f3                	mov    %esi,%ebx
}
  8008d9:	89 d8                	mov    %ebx,%eax
  8008db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008de:	5b                   	pop    %ebx
  8008df:	5e                   	pop    %esi
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	89 c6                	mov    %eax,%esi
  8008e9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008eb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008f2:	74 27                	je     80091b <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008f4:	6a 07                	push   $0x7
  8008f6:	68 00 50 80 00       	push   $0x805000
  8008fb:	56                   	push   %esi
  8008fc:	ff 35 00 40 80 00    	pushl  0x804000
  800902:	e8 a8 11 00 00       	call   801aaf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800907:	83 c4 0c             	add    $0xc,%esp
  80090a:	6a 00                	push   $0x0
  80090c:	53                   	push   %ebx
  80090d:	6a 00                	push   $0x0
  80090f:	e8 2e 11 00 00       	call   801a42 <ipc_recv>
}
  800914:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091b:	83 ec 0c             	sub    $0xc,%esp
  80091e:	6a 01                	push   $0x1
  800920:	e8 dd 11 00 00       	call   801b02 <ipc_find_env>
  800925:	a3 00 40 80 00       	mov    %eax,0x804000
  80092a:	83 c4 10             	add    $0x10,%esp
  80092d:	eb c5                	jmp    8008f4 <fsipc+0x12>

0080092f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80092f:	f3 0f 1e fb          	endbr32 
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 40 0c             	mov    0xc(%eax),%eax
  80093f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800944:	8b 45 0c             	mov    0xc(%ebp),%eax
  800947:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80094c:	ba 00 00 00 00       	mov    $0x0,%edx
  800951:	b8 02 00 00 00       	mov    $0x2,%eax
  800956:	e8 87 ff ff ff       	call   8008e2 <fsipc>
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <devfile_flush>:
{
  80095d:	f3 0f 1e fb          	endbr32 
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 40 0c             	mov    0xc(%eax),%eax
  80096d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800972:	ba 00 00 00 00       	mov    $0x0,%edx
  800977:	b8 06 00 00 00       	mov    $0x6,%eax
  80097c:	e8 61 ff ff ff       	call   8008e2 <fsipc>
}
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <devfile_stat>:
{
  800983:	f3 0f 1e fb          	endbr32 
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	53                   	push   %ebx
  80098b:	83 ec 04             	sub    $0x4,%esp
  80098e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 40 0c             	mov    0xc(%eax),%eax
  800997:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80099c:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8009a6:	e8 37 ff ff ff       	call   8008e2 <fsipc>
  8009ab:	85 c0                	test   %eax,%eax
  8009ad:	78 2c                	js     8009db <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009af:	83 ec 08             	sub    $0x8,%esp
  8009b2:	68 00 50 80 00       	push   $0x805000
  8009b7:	53                   	push   %ebx
  8009b8:	e8 11 0d 00 00       	call   8016ce <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009bd:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c8:	a1 84 50 80 00       	mov    0x805084,%eax
  8009cd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d3:	83 c4 10             	add    $0x10,%esp
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    

008009e0 <devfile_write>:
{
  8009e0:	f3 0f 1e fb          	endbr32 
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	57                   	push   %edi
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	83 ec 0c             	sub    $0xc,%esp
  8009ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f9:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a03:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  800a08:	85 db                	test   %ebx,%ebx
  800a0a:	74 3b                	je     800a47 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a0c:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800a12:	89 f8                	mov    %edi,%eax
  800a14:	0f 46 c3             	cmovbe %ebx,%eax
  800a17:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  800a1c:	83 ec 04             	sub    $0x4,%esp
  800a1f:	50                   	push   %eax
  800a20:	56                   	push   %esi
  800a21:	68 08 50 80 00       	push   $0x805008
  800a26:	e8 5b 0e 00 00       	call   801886 <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a30:	b8 04 00 00 00       	mov    $0x4,%eax
  800a35:	e8 a8 fe ff ff       	call   8008e2 <fsipc>
  800a3a:	83 c4 10             	add    $0x10,%esp
  800a3d:	85 c0                	test   %eax,%eax
  800a3f:	78 06                	js     800a47 <devfile_write+0x67>
		buf_aux += r;
  800a41:	01 c6                	add    %eax,%esi
		n -= r;
  800a43:	29 c3                	sub    %eax,%ebx
  800a45:	eb c1                	jmp    800a08 <devfile_write+0x28>
}
  800a47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	5f                   	pop    %edi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <devfile_read>:
{
  800a4f:	f3 0f 1e fb          	endbr32 
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	56                   	push   %esi
  800a57:	53                   	push   %ebx
  800a58:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a61:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a66:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a71:	b8 03 00 00 00       	mov    $0x3,%eax
  800a76:	e8 67 fe ff ff       	call   8008e2 <fsipc>
  800a7b:	89 c3                	mov    %eax,%ebx
  800a7d:	85 c0                	test   %eax,%eax
  800a7f:	78 1f                	js     800aa0 <devfile_read+0x51>
	assert(r <= n);
  800a81:	39 f0                	cmp    %esi,%eax
  800a83:	77 24                	ja     800aa9 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a85:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a8a:	7f 33                	jg     800abf <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a8c:	83 ec 04             	sub    $0x4,%esp
  800a8f:	50                   	push   %eax
  800a90:	68 00 50 80 00       	push   $0x805000
  800a95:	ff 75 0c             	pushl  0xc(%ebp)
  800a98:	e8 e9 0d 00 00       	call   801886 <memmove>
	return r;
  800a9d:	83 c4 10             	add    $0x10,%esp
}
  800aa0:	89 d8                	mov    %ebx,%eax
  800aa2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    
	assert(r <= n);
  800aa9:	68 b0 1e 80 00       	push   $0x801eb0
  800aae:	68 b7 1e 80 00       	push   $0x801eb7
  800ab3:	6a 7c                	push   $0x7c
  800ab5:	68 cc 1e 80 00       	push   $0x801ecc
  800aba:	e8 be 05 00 00       	call   80107d <_panic>
	assert(r <= PGSIZE);
  800abf:	68 d7 1e 80 00       	push   $0x801ed7
  800ac4:	68 b7 1e 80 00       	push   $0x801eb7
  800ac9:	6a 7d                	push   $0x7d
  800acb:	68 cc 1e 80 00       	push   $0x801ecc
  800ad0:	e8 a8 05 00 00       	call   80107d <_panic>

00800ad5 <open>:
{
  800ad5:	f3 0f 1e fb          	endbr32 
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
  800ade:	83 ec 1c             	sub    $0x1c,%esp
  800ae1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ae4:	56                   	push   %esi
  800ae5:	e8 a1 0b 00 00       	call   80168b <strlen>
  800aea:	83 c4 10             	add    $0x10,%esp
  800aed:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800af2:	7f 6c                	jg     800b60 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800af4:	83 ec 0c             	sub    $0xc,%esp
  800af7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800afa:	50                   	push   %eax
  800afb:	e8 42 f8 ff ff       	call   800342 <fd_alloc>
  800b00:	89 c3                	mov    %eax,%ebx
  800b02:	83 c4 10             	add    $0x10,%esp
  800b05:	85 c0                	test   %eax,%eax
  800b07:	78 3c                	js     800b45 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b09:	83 ec 08             	sub    $0x8,%esp
  800b0c:	56                   	push   %esi
  800b0d:	68 00 50 80 00       	push   $0x805000
  800b12:	e8 b7 0b 00 00       	call   8016ce <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1a:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b22:	b8 01 00 00 00       	mov    $0x1,%eax
  800b27:	e8 b6 fd ff ff       	call   8008e2 <fsipc>
  800b2c:	89 c3                	mov    %eax,%ebx
  800b2e:	83 c4 10             	add    $0x10,%esp
  800b31:	85 c0                	test   %eax,%eax
  800b33:	78 19                	js     800b4e <open+0x79>
	return fd2num(fd);
  800b35:	83 ec 0c             	sub    $0xc,%esp
  800b38:	ff 75 f4             	pushl  -0xc(%ebp)
  800b3b:	e8 cf f7 ff ff       	call   80030f <fd2num>
  800b40:	89 c3                	mov    %eax,%ebx
  800b42:	83 c4 10             	add    $0x10,%esp
}
  800b45:	89 d8                	mov    %ebx,%eax
  800b47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    
		fd_close(fd, 0);
  800b4e:	83 ec 08             	sub    $0x8,%esp
  800b51:	6a 00                	push   $0x0
  800b53:	ff 75 f4             	pushl  -0xc(%ebp)
  800b56:	e8 eb f8 ff ff       	call   800446 <fd_close>
		return r;
  800b5b:	83 c4 10             	add    $0x10,%esp
  800b5e:	eb e5                	jmp    800b45 <open+0x70>
		return -E_BAD_PATH;
  800b60:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b65:	eb de                	jmp    800b45 <open+0x70>

00800b67 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b67:	f3 0f 1e fb          	endbr32 
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b71:	ba 00 00 00 00       	mov    $0x0,%edx
  800b76:	b8 08 00 00 00       	mov    $0x8,%eax
  800b7b:	e8 62 fd ff ff       	call   8008e2 <fsipc>
}
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    

00800b82 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b82:	f3 0f 1e fb          	endbr32 
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b8e:	83 ec 0c             	sub    $0xc,%esp
  800b91:	ff 75 08             	pushl  0x8(%ebp)
  800b94:	e8 8a f7 ff ff       	call   800323 <fd2data>
  800b99:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b9b:	83 c4 08             	add    $0x8,%esp
  800b9e:	68 e3 1e 80 00       	push   $0x801ee3
  800ba3:	53                   	push   %ebx
  800ba4:	e8 25 0b 00 00       	call   8016ce <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ba9:	8b 46 04             	mov    0x4(%esi),%eax
  800bac:	2b 06                	sub    (%esi),%eax
  800bae:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bb4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bbb:	00 00 00 
	stat->st_dev = &devpipe;
  800bbe:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800bc5:	30 80 00 
	return 0;
}
  800bc8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bd4:	f3 0f 1e fb          	endbr32 
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	53                   	push   %ebx
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800be2:	53                   	push   %ebx
  800be3:	6a 00                	push   $0x0
  800be5:	e8 3a f6 ff ff       	call   800224 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bea:	89 1c 24             	mov    %ebx,(%esp)
  800bed:	e8 31 f7 ff ff       	call   800323 <fd2data>
  800bf2:	83 c4 08             	add    $0x8,%esp
  800bf5:	50                   	push   %eax
  800bf6:	6a 00                	push   $0x0
  800bf8:	e8 27 f6 ff ff       	call   800224 <sys_page_unmap>
}
  800bfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <_pipeisclosed>:
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 1c             	sub    $0x1c,%esp
  800c0b:	89 c7                	mov    %eax,%edi
  800c0d:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c0f:	a1 04 40 80 00       	mov    0x804004,%eax
  800c14:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c17:	83 ec 0c             	sub    $0xc,%esp
  800c1a:	57                   	push   %edi
  800c1b:	e8 1f 0f 00 00       	call   801b3f <pageref>
  800c20:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c23:	89 34 24             	mov    %esi,(%esp)
  800c26:	e8 14 0f 00 00       	call   801b3f <pageref>
		nn = thisenv->env_runs;
  800c2b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c31:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c34:	83 c4 10             	add    $0x10,%esp
  800c37:	39 cb                	cmp    %ecx,%ebx
  800c39:	74 1b                	je     800c56 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c3b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c3e:	75 cf                	jne    800c0f <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c40:	8b 42 58             	mov    0x58(%edx),%eax
  800c43:	6a 01                	push   $0x1
  800c45:	50                   	push   %eax
  800c46:	53                   	push   %ebx
  800c47:	68 ea 1e 80 00       	push   $0x801eea
  800c4c:	e8 13 05 00 00       	call   801164 <cprintf>
  800c51:	83 c4 10             	add    $0x10,%esp
  800c54:	eb b9                	jmp    800c0f <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c56:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c59:	0f 94 c0             	sete   %al
  800c5c:	0f b6 c0             	movzbl %al,%eax
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <devpipe_write>:
{
  800c67:	f3 0f 1e fb          	endbr32 
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 28             	sub    $0x28,%esp
  800c74:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c77:	56                   	push   %esi
  800c78:	e8 a6 f6 ff ff       	call   800323 <fd2data>
  800c7d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c7f:	83 c4 10             	add    $0x10,%esp
  800c82:	bf 00 00 00 00       	mov    $0x0,%edi
  800c87:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c8a:	74 4f                	je     800cdb <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c8c:	8b 43 04             	mov    0x4(%ebx),%eax
  800c8f:	8b 0b                	mov    (%ebx),%ecx
  800c91:	8d 51 20             	lea    0x20(%ecx),%edx
  800c94:	39 d0                	cmp    %edx,%eax
  800c96:	72 14                	jb     800cac <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800c98:	89 da                	mov    %ebx,%edx
  800c9a:	89 f0                	mov    %esi,%eax
  800c9c:	e8 61 ff ff ff       	call   800c02 <_pipeisclosed>
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	75 3b                	jne    800ce0 <devpipe_write+0x79>
			sys_yield();
  800ca5:	e8 fd f4 ff ff       	call   8001a7 <sys_yield>
  800caa:	eb e0                	jmp    800c8c <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cb3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cb6:	89 c2                	mov    %eax,%edx
  800cb8:	c1 fa 1f             	sar    $0x1f,%edx
  800cbb:	89 d1                	mov    %edx,%ecx
  800cbd:	c1 e9 1b             	shr    $0x1b,%ecx
  800cc0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cc3:	83 e2 1f             	and    $0x1f,%edx
  800cc6:	29 ca                	sub    %ecx,%edx
  800cc8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ccc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cd0:	83 c0 01             	add    $0x1,%eax
  800cd3:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cd6:	83 c7 01             	add    $0x1,%edi
  800cd9:	eb ac                	jmp    800c87 <devpipe_write+0x20>
	return i;
  800cdb:	8b 45 10             	mov    0x10(%ebp),%eax
  800cde:	eb 05                	jmp    800ce5 <devpipe_write+0x7e>
				return 0;
  800ce0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <devpipe_read>:
{
  800ced:	f3 0f 1e fb          	endbr32 
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 18             	sub    $0x18,%esp
  800cfa:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cfd:	57                   	push   %edi
  800cfe:	e8 20 f6 ff ff       	call   800323 <fd2data>
  800d03:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d05:	83 c4 10             	add    $0x10,%esp
  800d08:	be 00 00 00 00       	mov    $0x0,%esi
  800d0d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d10:	75 14                	jne    800d26 <devpipe_read+0x39>
	return i;
  800d12:	8b 45 10             	mov    0x10(%ebp),%eax
  800d15:	eb 02                	jmp    800d19 <devpipe_read+0x2c>
				return i;
  800d17:	89 f0                	mov    %esi,%eax
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    
			sys_yield();
  800d21:	e8 81 f4 ff ff       	call   8001a7 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d26:	8b 03                	mov    (%ebx),%eax
  800d28:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d2b:	75 18                	jne    800d45 <devpipe_read+0x58>
			if (i > 0)
  800d2d:	85 f6                	test   %esi,%esi
  800d2f:	75 e6                	jne    800d17 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d31:	89 da                	mov    %ebx,%edx
  800d33:	89 f8                	mov    %edi,%eax
  800d35:	e8 c8 fe ff ff       	call   800c02 <_pipeisclosed>
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	74 e3                	je     800d21 <devpipe_read+0x34>
				return 0;
  800d3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d43:	eb d4                	jmp    800d19 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d45:	99                   	cltd   
  800d46:	c1 ea 1b             	shr    $0x1b,%edx
  800d49:	01 d0                	add    %edx,%eax
  800d4b:	83 e0 1f             	and    $0x1f,%eax
  800d4e:	29 d0                	sub    %edx,%eax
  800d50:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d5b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d5e:	83 c6 01             	add    $0x1,%esi
  800d61:	eb aa                	jmp    800d0d <devpipe_read+0x20>

00800d63 <pipe>:
{
  800d63:	f3 0f 1e fb          	endbr32 
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
  800d6c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d72:	50                   	push   %eax
  800d73:	e8 ca f5 ff ff       	call   800342 <fd_alloc>
  800d78:	89 c3                	mov    %eax,%ebx
  800d7a:	83 c4 10             	add    $0x10,%esp
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	0f 88 23 01 00 00    	js     800ea8 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d85:	83 ec 04             	sub    $0x4,%esp
  800d88:	68 07 04 00 00       	push   $0x407
  800d8d:	ff 75 f4             	pushl  -0xc(%ebp)
  800d90:	6a 00                	push   $0x0
  800d92:	e8 3b f4 ff ff       	call   8001d2 <sys_page_alloc>
  800d97:	89 c3                	mov    %eax,%ebx
  800d99:	83 c4 10             	add    $0x10,%esp
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	0f 88 04 01 00 00    	js     800ea8 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800da4:	83 ec 0c             	sub    $0xc,%esp
  800da7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800daa:	50                   	push   %eax
  800dab:	e8 92 f5 ff ff       	call   800342 <fd_alloc>
  800db0:	89 c3                	mov    %eax,%ebx
  800db2:	83 c4 10             	add    $0x10,%esp
  800db5:	85 c0                	test   %eax,%eax
  800db7:	0f 88 db 00 00 00    	js     800e98 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbd:	83 ec 04             	sub    $0x4,%esp
  800dc0:	68 07 04 00 00       	push   $0x407
  800dc5:	ff 75 f0             	pushl  -0x10(%ebp)
  800dc8:	6a 00                	push   $0x0
  800dca:	e8 03 f4 ff ff       	call   8001d2 <sys_page_alloc>
  800dcf:	89 c3                	mov    %eax,%ebx
  800dd1:	83 c4 10             	add    $0x10,%esp
  800dd4:	85 c0                	test   %eax,%eax
  800dd6:	0f 88 bc 00 00 00    	js     800e98 <pipe+0x135>
	va = fd2data(fd0);
  800ddc:	83 ec 0c             	sub    $0xc,%esp
  800ddf:	ff 75 f4             	pushl  -0xc(%ebp)
  800de2:	e8 3c f5 ff ff       	call   800323 <fd2data>
  800de7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de9:	83 c4 0c             	add    $0xc,%esp
  800dec:	68 07 04 00 00       	push   $0x407
  800df1:	50                   	push   %eax
  800df2:	6a 00                	push   $0x0
  800df4:	e8 d9 f3 ff ff       	call   8001d2 <sys_page_alloc>
  800df9:	89 c3                	mov    %eax,%ebx
  800dfb:	83 c4 10             	add    $0x10,%esp
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	0f 88 82 00 00 00    	js     800e88 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e06:	83 ec 0c             	sub    $0xc,%esp
  800e09:	ff 75 f0             	pushl  -0x10(%ebp)
  800e0c:	e8 12 f5 ff ff       	call   800323 <fd2data>
  800e11:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e18:	50                   	push   %eax
  800e19:	6a 00                	push   $0x0
  800e1b:	56                   	push   %esi
  800e1c:	6a 00                	push   $0x0
  800e1e:	e8 d7 f3 ff ff       	call   8001fa <sys_page_map>
  800e23:	89 c3                	mov    %eax,%ebx
  800e25:	83 c4 20             	add    $0x20,%esp
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	78 4e                	js     800e7a <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e2c:	a1 24 30 80 00       	mov    0x803024,%eax
  800e31:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e34:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e36:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e39:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e40:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e43:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e48:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e4f:	83 ec 0c             	sub    $0xc,%esp
  800e52:	ff 75 f4             	pushl  -0xc(%ebp)
  800e55:	e8 b5 f4 ff ff       	call   80030f <fd2num>
  800e5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e5f:	83 c4 04             	add    $0x4,%esp
  800e62:	ff 75 f0             	pushl  -0x10(%ebp)
  800e65:	e8 a5 f4 ff ff       	call   80030f <fd2num>
  800e6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e70:	83 c4 10             	add    $0x10,%esp
  800e73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e78:	eb 2e                	jmp    800ea8 <pipe+0x145>
	sys_page_unmap(0, va);
  800e7a:	83 ec 08             	sub    $0x8,%esp
  800e7d:	56                   	push   %esi
  800e7e:	6a 00                	push   $0x0
  800e80:	e8 9f f3 ff ff       	call   800224 <sys_page_unmap>
  800e85:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e88:	83 ec 08             	sub    $0x8,%esp
  800e8b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e8e:	6a 00                	push   $0x0
  800e90:	e8 8f f3 ff ff       	call   800224 <sys_page_unmap>
  800e95:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e98:	83 ec 08             	sub    $0x8,%esp
  800e9b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9e:	6a 00                	push   $0x0
  800ea0:	e8 7f f3 ff ff       	call   800224 <sys_page_unmap>
  800ea5:	83 c4 10             	add    $0x10,%esp
}
  800ea8:	89 d8                	mov    %ebx,%eax
  800eaa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ead:	5b                   	pop    %ebx
  800eae:	5e                   	pop    %esi
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <pipeisclosed>:
{
  800eb1:	f3 0f 1e fb          	endbr32 
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ebb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ebe:	50                   	push   %eax
  800ebf:	ff 75 08             	pushl  0x8(%ebp)
  800ec2:	e8 d1 f4 ff ff       	call   800398 <fd_lookup>
  800ec7:	83 c4 10             	add    $0x10,%esp
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	78 18                	js     800ee6 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800ece:	83 ec 0c             	sub    $0xc,%esp
  800ed1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed4:	e8 4a f4 ff ff       	call   800323 <fd2data>
  800ed9:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ede:	e8 1f fd ff ff       	call   800c02 <_pipeisclosed>
  800ee3:	83 c4 10             	add    $0x10,%esp
}
  800ee6:	c9                   	leave  
  800ee7:	c3                   	ret    

00800ee8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ee8:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800eec:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef1:	c3                   	ret    

00800ef2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ef2:	f3 0f 1e fb          	endbr32 
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800efc:	68 02 1f 80 00       	push   $0x801f02
  800f01:	ff 75 0c             	pushl  0xc(%ebp)
  800f04:	e8 c5 07 00 00       	call   8016ce <strcpy>
	return 0;
}
  800f09:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0e:	c9                   	leave  
  800f0f:	c3                   	ret    

00800f10 <devcons_write>:
{
  800f10:	f3 0f 1e fb          	endbr32 
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	57                   	push   %edi
  800f18:	56                   	push   %esi
  800f19:	53                   	push   %ebx
  800f1a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f20:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f25:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f2b:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f2e:	73 31                	jae    800f61 <devcons_write+0x51>
		m = n - tot;
  800f30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f33:	29 f3                	sub    %esi,%ebx
  800f35:	83 fb 7f             	cmp    $0x7f,%ebx
  800f38:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f3d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f40:	83 ec 04             	sub    $0x4,%esp
  800f43:	53                   	push   %ebx
  800f44:	89 f0                	mov    %esi,%eax
  800f46:	03 45 0c             	add    0xc(%ebp),%eax
  800f49:	50                   	push   %eax
  800f4a:	57                   	push   %edi
  800f4b:	e8 36 09 00 00       	call   801886 <memmove>
		sys_cputs(buf, m);
  800f50:	83 c4 08             	add    $0x8,%esp
  800f53:	53                   	push   %ebx
  800f54:	57                   	push   %edi
  800f55:	e8 ad f1 ff ff       	call   800107 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f5a:	01 de                	add    %ebx,%esi
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	eb ca                	jmp    800f2b <devcons_write+0x1b>
}
  800f61:	89 f0                	mov    %esi,%eax
  800f63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f66:	5b                   	pop    %ebx
  800f67:	5e                   	pop    %esi
  800f68:	5f                   	pop    %edi
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <devcons_read>:
{
  800f6b:	f3 0f 1e fb          	endbr32 
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	83 ec 08             	sub    $0x8,%esp
  800f75:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f7e:	74 21                	je     800fa1 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800f80:	e8 ac f1 ff ff       	call   800131 <sys_cgetc>
  800f85:	85 c0                	test   %eax,%eax
  800f87:	75 07                	jne    800f90 <devcons_read+0x25>
		sys_yield();
  800f89:	e8 19 f2 ff ff       	call   8001a7 <sys_yield>
  800f8e:	eb f0                	jmp    800f80 <devcons_read+0x15>
	if (c < 0)
  800f90:	78 0f                	js     800fa1 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800f92:	83 f8 04             	cmp    $0x4,%eax
  800f95:	74 0c                	je     800fa3 <devcons_read+0x38>
	*(char*)vbuf = c;
  800f97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9a:	88 02                	mov    %al,(%edx)
	return 1;
  800f9c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    
		return 0;
  800fa3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa8:	eb f7                	jmp    800fa1 <devcons_read+0x36>

00800faa <cputchar>:
{
  800faa:	f3 0f 1e fb          	endbr32 
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb7:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800fba:	6a 01                	push   $0x1
  800fbc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fbf:	50                   	push   %eax
  800fc0:	e8 42 f1 ff ff       	call   800107 <sys_cputs>
}
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	c9                   	leave  
  800fc9:	c3                   	ret    

00800fca <getchar>:
{
  800fca:	f3 0f 1e fb          	endbr32 
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800fd4:	6a 01                	push   $0x1
  800fd6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd9:	50                   	push   %eax
  800fda:	6a 00                	push   $0x0
  800fdc:	e8 3a f6 ff ff       	call   80061b <read>
	if (r < 0)
  800fe1:	83 c4 10             	add    $0x10,%esp
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	78 06                	js     800fee <getchar+0x24>
	if (r < 1)
  800fe8:	74 06                	je     800ff0 <getchar+0x26>
	return c;
  800fea:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fee:	c9                   	leave  
  800fef:	c3                   	ret    
		return -E_EOF;
  800ff0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800ff5:	eb f7                	jmp    800fee <getchar+0x24>

00800ff7 <iscons>:
{
  800ff7:	f3 0f 1e fb          	endbr32 
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801001:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801004:	50                   	push   %eax
  801005:	ff 75 08             	pushl  0x8(%ebp)
  801008:	e8 8b f3 ff ff       	call   800398 <fd_lookup>
  80100d:	83 c4 10             	add    $0x10,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	78 11                	js     801025 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801014:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801017:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80101d:	39 10                	cmp    %edx,(%eax)
  80101f:	0f 94 c0             	sete   %al
  801022:	0f b6 c0             	movzbl %al,%eax
}
  801025:	c9                   	leave  
  801026:	c3                   	ret    

00801027 <opencons>:
{
  801027:	f3 0f 1e fb          	endbr32 
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801031:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801034:	50                   	push   %eax
  801035:	e8 08 f3 ff ff       	call   800342 <fd_alloc>
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	85 c0                	test   %eax,%eax
  80103f:	78 3a                	js     80107b <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801041:	83 ec 04             	sub    $0x4,%esp
  801044:	68 07 04 00 00       	push   $0x407
  801049:	ff 75 f4             	pushl  -0xc(%ebp)
  80104c:	6a 00                	push   $0x0
  80104e:	e8 7f f1 ff ff       	call   8001d2 <sys_page_alloc>
  801053:	83 c4 10             	add    $0x10,%esp
  801056:	85 c0                	test   %eax,%eax
  801058:	78 21                	js     80107b <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80105a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801063:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801065:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801068:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	50                   	push   %eax
  801073:	e8 97 f2 ff ff       	call   80030f <fd2num>
  801078:	83 c4 10             	add    $0x10,%esp
}
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    

0080107d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80107d:	f3 0f 1e fb          	endbr32 
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	56                   	push   %esi
  801085:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801086:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801089:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80108f:	e8 eb f0 ff ff       	call   80017f <sys_getenvid>
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	ff 75 0c             	pushl  0xc(%ebp)
  80109a:	ff 75 08             	pushl  0x8(%ebp)
  80109d:	56                   	push   %esi
  80109e:	50                   	push   %eax
  80109f:	68 10 1f 80 00       	push   $0x801f10
  8010a4:	e8 bb 00 00 00       	call   801164 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010a9:	83 c4 18             	add    $0x18,%esp
  8010ac:	53                   	push   %ebx
  8010ad:	ff 75 10             	pushl  0x10(%ebp)
  8010b0:	e8 5a 00 00 00       	call   80110f <vcprintf>
	cprintf("\n");
  8010b5:	c7 04 24 fb 1e 80 00 	movl   $0x801efb,(%esp)
  8010bc:	e8 a3 00 00 00       	call   801164 <cprintf>
  8010c1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010c4:	cc                   	int3   
  8010c5:	eb fd                	jmp    8010c4 <_panic+0x47>

008010c7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010c7:	f3 0f 1e fb          	endbr32 
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	53                   	push   %ebx
  8010cf:	83 ec 04             	sub    $0x4,%esp
  8010d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010d5:	8b 13                	mov    (%ebx),%edx
  8010d7:	8d 42 01             	lea    0x1(%edx),%eax
  8010da:	89 03                	mov    %eax,(%ebx)
  8010dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010df:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010e3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010e8:	74 09                	je     8010f3 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010ea:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f1:	c9                   	leave  
  8010f2:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010f3:	83 ec 08             	sub    $0x8,%esp
  8010f6:	68 ff 00 00 00       	push   $0xff
  8010fb:	8d 43 08             	lea    0x8(%ebx),%eax
  8010fe:	50                   	push   %eax
  8010ff:	e8 03 f0 ff ff       	call   800107 <sys_cputs>
		b->idx = 0;
  801104:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80110a:	83 c4 10             	add    $0x10,%esp
  80110d:	eb db                	jmp    8010ea <putch+0x23>

0080110f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80110f:	f3 0f 1e fb          	endbr32 
  801113:	55                   	push   %ebp
  801114:	89 e5                	mov    %esp,%ebp
  801116:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80111c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801123:	00 00 00 
	b.cnt = 0;
  801126:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80112d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801130:	ff 75 0c             	pushl  0xc(%ebp)
  801133:	ff 75 08             	pushl  0x8(%ebp)
  801136:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80113c:	50                   	push   %eax
  80113d:	68 c7 10 80 00       	push   $0x8010c7
  801142:	e8 80 01 00 00       	call   8012c7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801147:	83 c4 08             	add    $0x8,%esp
  80114a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801150:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801156:	50                   	push   %eax
  801157:	e8 ab ef ff ff       	call   800107 <sys_cputs>

	return b.cnt;
}
  80115c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801162:	c9                   	leave  
  801163:	c3                   	ret    

00801164 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801164:	f3 0f 1e fb          	endbr32 
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80116e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801171:	50                   	push   %eax
  801172:	ff 75 08             	pushl  0x8(%ebp)
  801175:	e8 95 ff ff ff       	call   80110f <vcprintf>
	va_end(ap);

	return cnt;
}
  80117a:	c9                   	leave  
  80117b:	c3                   	ret    

0080117c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	57                   	push   %edi
  801180:	56                   	push   %esi
  801181:	53                   	push   %ebx
  801182:	83 ec 1c             	sub    $0x1c,%esp
  801185:	89 c7                	mov    %eax,%edi
  801187:	89 d6                	mov    %edx,%esi
  801189:	8b 45 08             	mov    0x8(%ebp),%eax
  80118c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118f:	89 d1                	mov    %edx,%ecx
  801191:	89 c2                	mov    %eax,%edx
  801193:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801196:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801199:	8b 45 10             	mov    0x10(%ebp),%eax
  80119c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80119f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011a2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011a9:	39 c2                	cmp    %eax,%edx
  8011ab:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011ae:	72 3e                	jb     8011ee <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011b0:	83 ec 0c             	sub    $0xc,%esp
  8011b3:	ff 75 18             	pushl  0x18(%ebp)
  8011b6:	83 eb 01             	sub    $0x1,%ebx
  8011b9:	53                   	push   %ebx
  8011ba:	50                   	push   %eax
  8011bb:	83 ec 08             	sub    $0x8,%esp
  8011be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c4:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c7:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ca:	e8 b1 09 00 00       	call   801b80 <__udivdi3>
  8011cf:	83 c4 18             	add    $0x18,%esp
  8011d2:	52                   	push   %edx
  8011d3:	50                   	push   %eax
  8011d4:	89 f2                	mov    %esi,%edx
  8011d6:	89 f8                	mov    %edi,%eax
  8011d8:	e8 9f ff ff ff       	call   80117c <printnum>
  8011dd:	83 c4 20             	add    $0x20,%esp
  8011e0:	eb 13                	jmp    8011f5 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011e2:	83 ec 08             	sub    $0x8,%esp
  8011e5:	56                   	push   %esi
  8011e6:	ff 75 18             	pushl  0x18(%ebp)
  8011e9:	ff d7                	call   *%edi
  8011eb:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011ee:	83 eb 01             	sub    $0x1,%ebx
  8011f1:	85 db                	test   %ebx,%ebx
  8011f3:	7f ed                	jg     8011e2 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011f5:	83 ec 08             	sub    $0x8,%esp
  8011f8:	56                   	push   %esi
  8011f9:	83 ec 04             	sub    $0x4,%esp
  8011fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ff:	ff 75 e0             	pushl  -0x20(%ebp)
  801202:	ff 75 dc             	pushl  -0x24(%ebp)
  801205:	ff 75 d8             	pushl  -0x28(%ebp)
  801208:	e8 83 0a 00 00       	call   801c90 <__umoddi3>
  80120d:	83 c4 14             	add    $0x14,%esp
  801210:	0f be 80 33 1f 80 00 	movsbl 0x801f33(%eax),%eax
  801217:	50                   	push   %eax
  801218:	ff d7                	call   *%edi
}
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801220:	5b                   	pop    %ebx
  801221:	5e                   	pop    %esi
  801222:	5f                   	pop    %edi
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    

00801225 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801225:	83 fa 01             	cmp    $0x1,%edx
  801228:	7f 13                	jg     80123d <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80122a:	85 d2                	test   %edx,%edx
  80122c:	74 1c                	je     80124a <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80122e:	8b 10                	mov    (%eax),%edx
  801230:	8d 4a 04             	lea    0x4(%edx),%ecx
  801233:	89 08                	mov    %ecx,(%eax)
  801235:	8b 02                	mov    (%edx),%eax
  801237:	ba 00 00 00 00       	mov    $0x0,%edx
  80123c:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80123d:	8b 10                	mov    (%eax),%edx
  80123f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801242:	89 08                	mov    %ecx,(%eax)
  801244:	8b 02                	mov    (%edx),%eax
  801246:	8b 52 04             	mov    0x4(%edx),%edx
  801249:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80124a:	8b 10                	mov    (%eax),%edx
  80124c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80124f:	89 08                	mov    %ecx,(%eax)
  801251:	8b 02                	mov    (%edx),%eax
  801253:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801258:	c3                   	ret    

00801259 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801259:	83 fa 01             	cmp    $0x1,%edx
  80125c:	7f 0f                	jg     80126d <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80125e:	85 d2                	test   %edx,%edx
  801260:	74 18                	je     80127a <getint+0x21>
		return va_arg(*ap, long);
  801262:	8b 10                	mov    (%eax),%edx
  801264:	8d 4a 04             	lea    0x4(%edx),%ecx
  801267:	89 08                	mov    %ecx,(%eax)
  801269:	8b 02                	mov    (%edx),%eax
  80126b:	99                   	cltd   
  80126c:	c3                   	ret    
		return va_arg(*ap, long long);
  80126d:	8b 10                	mov    (%eax),%edx
  80126f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801272:	89 08                	mov    %ecx,(%eax)
  801274:	8b 02                	mov    (%edx),%eax
  801276:	8b 52 04             	mov    0x4(%edx),%edx
  801279:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80127a:	8b 10                	mov    (%eax),%edx
  80127c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80127f:	89 08                	mov    %ecx,(%eax)
  801281:	8b 02                	mov    (%edx),%eax
  801283:	99                   	cltd   
}
  801284:	c3                   	ret    

00801285 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801285:	f3 0f 1e fb          	endbr32 
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80128f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801293:	8b 10                	mov    (%eax),%edx
  801295:	3b 50 04             	cmp    0x4(%eax),%edx
  801298:	73 0a                	jae    8012a4 <sprintputch+0x1f>
		*b->buf++ = ch;
  80129a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80129d:	89 08                	mov    %ecx,(%eax)
  80129f:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a2:	88 02                	mov    %al,(%edx)
}
  8012a4:	5d                   	pop    %ebp
  8012a5:	c3                   	ret    

008012a6 <printfmt>:
{
  8012a6:	f3 0f 1e fb          	endbr32 
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012b3:	50                   	push   %eax
  8012b4:	ff 75 10             	pushl  0x10(%ebp)
  8012b7:	ff 75 0c             	pushl  0xc(%ebp)
  8012ba:	ff 75 08             	pushl  0x8(%ebp)
  8012bd:	e8 05 00 00 00       	call   8012c7 <vprintfmt>
}
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	c9                   	leave  
  8012c6:	c3                   	ret    

008012c7 <vprintfmt>:
{
  8012c7:	f3 0f 1e fb          	endbr32 
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	57                   	push   %edi
  8012cf:	56                   	push   %esi
  8012d0:	53                   	push   %ebx
  8012d1:	83 ec 2c             	sub    $0x2c,%esp
  8012d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012d7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012da:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012dd:	e9 86 02 00 00       	jmp    801568 <vprintfmt+0x2a1>
		padc = ' ';
  8012e2:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012e6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012ed:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012f4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012fb:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801300:	8d 47 01             	lea    0x1(%edi),%eax
  801303:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801306:	0f b6 17             	movzbl (%edi),%edx
  801309:	8d 42 dd             	lea    -0x23(%edx),%eax
  80130c:	3c 55                	cmp    $0x55,%al
  80130e:	0f 87 df 02 00 00    	ja     8015f3 <vprintfmt+0x32c>
  801314:	0f b6 c0             	movzbl %al,%eax
  801317:	3e ff 24 85 80 20 80 	notrack jmp *0x802080(,%eax,4)
  80131e:	00 
  80131f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801322:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801326:	eb d8                	jmp    801300 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80132b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80132f:	eb cf                	jmp    801300 <vprintfmt+0x39>
  801331:	0f b6 d2             	movzbl %dl,%edx
  801334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801337:	b8 00 00 00 00       	mov    $0x0,%eax
  80133c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80133f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801342:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801346:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801349:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80134c:	83 f9 09             	cmp    $0x9,%ecx
  80134f:	77 52                	ja     8013a3 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  801351:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801354:	eb e9                	jmp    80133f <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801356:	8b 45 14             	mov    0x14(%ebp),%eax
  801359:	8d 50 04             	lea    0x4(%eax),%edx
  80135c:	89 55 14             	mov    %edx,0x14(%ebp)
  80135f:	8b 00                	mov    (%eax),%eax
  801361:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801367:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80136b:	79 93                	jns    801300 <vprintfmt+0x39>
				width = precision, precision = -1;
  80136d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801370:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801373:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80137a:	eb 84                	jmp    801300 <vprintfmt+0x39>
  80137c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80137f:	85 c0                	test   %eax,%eax
  801381:	ba 00 00 00 00       	mov    $0x0,%edx
  801386:	0f 49 d0             	cmovns %eax,%edx
  801389:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80138c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80138f:	e9 6c ff ff ff       	jmp    801300 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801397:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80139e:	e9 5d ff ff ff       	jmp    801300 <vprintfmt+0x39>
  8013a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013a6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8013a9:	eb bc                	jmp    801367 <vprintfmt+0xa0>
			lflag++;
  8013ab:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8013ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013b1:	e9 4a ff ff ff       	jmp    801300 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b9:	8d 50 04             	lea    0x4(%eax),%edx
  8013bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8013bf:	83 ec 08             	sub    $0x8,%esp
  8013c2:	56                   	push   %esi
  8013c3:	ff 30                	pushl  (%eax)
  8013c5:	ff d3                	call   *%ebx
			break;
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	e9 96 01 00 00       	jmp    801565 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8013cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d2:	8d 50 04             	lea    0x4(%eax),%edx
  8013d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8013d8:	8b 00                	mov    (%eax),%eax
  8013da:	99                   	cltd   
  8013db:	31 d0                	xor    %edx,%eax
  8013dd:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013df:	83 f8 0f             	cmp    $0xf,%eax
  8013e2:	7f 20                	jg     801404 <vprintfmt+0x13d>
  8013e4:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  8013eb:	85 d2                	test   %edx,%edx
  8013ed:	74 15                	je     801404 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8013ef:	52                   	push   %edx
  8013f0:	68 c9 1e 80 00       	push   $0x801ec9
  8013f5:	56                   	push   %esi
  8013f6:	53                   	push   %ebx
  8013f7:	e8 aa fe ff ff       	call   8012a6 <printfmt>
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	e9 61 01 00 00       	jmp    801565 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  801404:	50                   	push   %eax
  801405:	68 4b 1f 80 00       	push   $0x801f4b
  80140a:	56                   	push   %esi
  80140b:	53                   	push   %ebx
  80140c:	e8 95 fe ff ff       	call   8012a6 <printfmt>
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	e9 4c 01 00 00       	jmp    801565 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  801419:	8b 45 14             	mov    0x14(%ebp),%eax
  80141c:	8d 50 04             	lea    0x4(%eax),%edx
  80141f:	89 55 14             	mov    %edx,0x14(%ebp)
  801422:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  801424:	85 c9                	test   %ecx,%ecx
  801426:	b8 44 1f 80 00       	mov    $0x801f44,%eax
  80142b:	0f 45 c1             	cmovne %ecx,%eax
  80142e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801431:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801435:	7e 06                	jle    80143d <vprintfmt+0x176>
  801437:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80143b:	75 0d                	jne    80144a <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  80143d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801440:	89 c7                	mov    %eax,%edi
  801442:	03 45 e0             	add    -0x20(%ebp),%eax
  801445:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801448:	eb 57                	jmp    8014a1 <vprintfmt+0x1da>
  80144a:	83 ec 08             	sub    $0x8,%esp
  80144d:	ff 75 d8             	pushl  -0x28(%ebp)
  801450:	ff 75 cc             	pushl  -0x34(%ebp)
  801453:	e8 4f 02 00 00       	call   8016a7 <strnlen>
  801458:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80145b:	29 c2                	sub    %eax,%edx
  80145d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801460:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801463:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801467:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80146a:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80146c:	85 db                	test   %ebx,%ebx
  80146e:	7e 10                	jle    801480 <vprintfmt+0x1b9>
					putch(padc, putdat);
  801470:	83 ec 08             	sub    $0x8,%esp
  801473:	56                   	push   %esi
  801474:	57                   	push   %edi
  801475:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801478:	83 eb 01             	sub    $0x1,%ebx
  80147b:	83 c4 10             	add    $0x10,%esp
  80147e:	eb ec                	jmp    80146c <vprintfmt+0x1a5>
  801480:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801483:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801486:	85 d2                	test   %edx,%edx
  801488:	b8 00 00 00 00       	mov    $0x0,%eax
  80148d:	0f 49 c2             	cmovns %edx,%eax
  801490:	29 c2                	sub    %eax,%edx
  801492:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801495:	eb a6                	jmp    80143d <vprintfmt+0x176>
					putch(ch, putdat);
  801497:	83 ec 08             	sub    $0x8,%esp
  80149a:	56                   	push   %esi
  80149b:	52                   	push   %edx
  80149c:	ff d3                	call   *%ebx
  80149e:	83 c4 10             	add    $0x10,%esp
  8014a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014a4:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014a6:	83 c7 01             	add    $0x1,%edi
  8014a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014ad:	0f be d0             	movsbl %al,%edx
  8014b0:	85 d2                	test   %edx,%edx
  8014b2:	74 42                	je     8014f6 <vprintfmt+0x22f>
  8014b4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014b8:	78 06                	js     8014c0 <vprintfmt+0x1f9>
  8014ba:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014be:	78 1e                	js     8014de <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8014c0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014c4:	74 d1                	je     801497 <vprintfmt+0x1d0>
  8014c6:	0f be c0             	movsbl %al,%eax
  8014c9:	83 e8 20             	sub    $0x20,%eax
  8014cc:	83 f8 5e             	cmp    $0x5e,%eax
  8014cf:	76 c6                	jbe    801497 <vprintfmt+0x1d0>
					putch('?', putdat);
  8014d1:	83 ec 08             	sub    $0x8,%esp
  8014d4:	56                   	push   %esi
  8014d5:	6a 3f                	push   $0x3f
  8014d7:	ff d3                	call   *%ebx
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	eb c3                	jmp    8014a1 <vprintfmt+0x1da>
  8014de:	89 cf                	mov    %ecx,%edi
  8014e0:	eb 0e                	jmp    8014f0 <vprintfmt+0x229>
				putch(' ', putdat);
  8014e2:	83 ec 08             	sub    $0x8,%esp
  8014e5:	56                   	push   %esi
  8014e6:	6a 20                	push   $0x20
  8014e8:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8014ea:	83 ef 01             	sub    $0x1,%edi
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	85 ff                	test   %edi,%edi
  8014f2:	7f ee                	jg     8014e2 <vprintfmt+0x21b>
  8014f4:	eb 6f                	jmp    801565 <vprintfmt+0x29e>
  8014f6:	89 cf                	mov    %ecx,%edi
  8014f8:	eb f6                	jmp    8014f0 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8014fa:	89 ca                	mov    %ecx,%edx
  8014fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8014ff:	e8 55 fd ff ff       	call   801259 <getint>
  801504:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801507:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80150a:	85 d2                	test   %edx,%edx
  80150c:	78 0b                	js     801519 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  80150e:	89 d1                	mov    %edx,%ecx
  801510:	89 c2                	mov    %eax,%edx
			base = 10;
  801512:	b8 0a 00 00 00       	mov    $0xa,%eax
  801517:	eb 32                	jmp    80154b <vprintfmt+0x284>
				putch('-', putdat);
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	56                   	push   %esi
  80151d:	6a 2d                	push   $0x2d
  80151f:	ff d3                	call   *%ebx
				num = -(long long) num;
  801521:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801524:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801527:	f7 da                	neg    %edx
  801529:	83 d1 00             	adc    $0x0,%ecx
  80152c:	f7 d9                	neg    %ecx
  80152e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801531:	b8 0a 00 00 00       	mov    $0xa,%eax
  801536:	eb 13                	jmp    80154b <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  801538:	89 ca                	mov    %ecx,%edx
  80153a:	8d 45 14             	lea    0x14(%ebp),%eax
  80153d:	e8 e3 fc ff ff       	call   801225 <getuint>
  801542:	89 d1                	mov    %edx,%ecx
  801544:	89 c2                	mov    %eax,%edx
			base = 10;
  801546:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  80154b:	83 ec 0c             	sub    $0xc,%esp
  80154e:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801552:	57                   	push   %edi
  801553:	ff 75 e0             	pushl  -0x20(%ebp)
  801556:	50                   	push   %eax
  801557:	51                   	push   %ecx
  801558:	52                   	push   %edx
  801559:	89 f2                	mov    %esi,%edx
  80155b:	89 d8                	mov    %ebx,%eax
  80155d:	e8 1a fc ff ff       	call   80117c <printnum>
			break;
  801562:	83 c4 20             	add    $0x20,%esp
{
  801565:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801568:	83 c7 01             	add    $0x1,%edi
  80156b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80156f:	83 f8 25             	cmp    $0x25,%eax
  801572:	0f 84 6a fd ff ff    	je     8012e2 <vprintfmt+0x1b>
			if (ch == '\0')
  801578:	85 c0                	test   %eax,%eax
  80157a:	0f 84 93 00 00 00    	je     801613 <vprintfmt+0x34c>
			putch(ch, putdat);
  801580:	83 ec 08             	sub    $0x8,%esp
  801583:	56                   	push   %esi
  801584:	50                   	push   %eax
  801585:	ff d3                	call   *%ebx
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	eb dc                	jmp    801568 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  80158c:	89 ca                	mov    %ecx,%edx
  80158e:	8d 45 14             	lea    0x14(%ebp),%eax
  801591:	e8 8f fc ff ff       	call   801225 <getuint>
  801596:	89 d1                	mov    %edx,%ecx
  801598:	89 c2                	mov    %eax,%edx
			base = 8;
  80159a:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80159f:	eb aa                	jmp    80154b <vprintfmt+0x284>
			putch('0', putdat);
  8015a1:	83 ec 08             	sub    $0x8,%esp
  8015a4:	56                   	push   %esi
  8015a5:	6a 30                	push   $0x30
  8015a7:	ff d3                	call   *%ebx
			putch('x', putdat);
  8015a9:	83 c4 08             	add    $0x8,%esp
  8015ac:	56                   	push   %esi
  8015ad:	6a 78                	push   $0x78
  8015af:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8015b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b4:	8d 50 04             	lea    0x4(%eax),%edx
  8015b7:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8015ba:	8b 10                	mov    (%eax),%edx
  8015bc:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015c1:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8015c4:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015c9:	eb 80                	jmp    80154b <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8015cb:	89 ca                	mov    %ecx,%edx
  8015cd:	8d 45 14             	lea    0x14(%ebp),%eax
  8015d0:	e8 50 fc ff ff       	call   801225 <getuint>
  8015d5:	89 d1                	mov    %edx,%ecx
  8015d7:	89 c2                	mov    %eax,%edx
			base = 16;
  8015d9:	b8 10 00 00 00       	mov    $0x10,%eax
  8015de:	e9 68 ff ff ff       	jmp    80154b <vprintfmt+0x284>
			putch(ch, putdat);
  8015e3:	83 ec 08             	sub    $0x8,%esp
  8015e6:	56                   	push   %esi
  8015e7:	6a 25                	push   $0x25
  8015e9:	ff d3                	call   *%ebx
			break;
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	e9 72 ff ff ff       	jmp    801565 <vprintfmt+0x29e>
			putch('%', putdat);
  8015f3:	83 ec 08             	sub    $0x8,%esp
  8015f6:	56                   	push   %esi
  8015f7:	6a 25                	push   $0x25
  8015f9:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	89 f8                	mov    %edi,%eax
  801600:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801604:	74 05                	je     80160b <vprintfmt+0x344>
  801606:	83 e8 01             	sub    $0x1,%eax
  801609:	eb f5                	jmp    801600 <vprintfmt+0x339>
  80160b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80160e:	e9 52 ff ff ff       	jmp    801565 <vprintfmt+0x29e>
}
  801613:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801616:	5b                   	pop    %ebx
  801617:	5e                   	pop    %esi
  801618:	5f                   	pop    %edi
  801619:	5d                   	pop    %ebp
  80161a:	c3                   	ret    

0080161b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80161b:	f3 0f 1e fb          	endbr32 
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	83 ec 18             	sub    $0x18,%esp
  801625:	8b 45 08             	mov    0x8(%ebp),%eax
  801628:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80162b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80162e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801632:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801635:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80163c:	85 c0                	test   %eax,%eax
  80163e:	74 26                	je     801666 <vsnprintf+0x4b>
  801640:	85 d2                	test   %edx,%edx
  801642:	7e 22                	jle    801666 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801644:	ff 75 14             	pushl  0x14(%ebp)
  801647:	ff 75 10             	pushl  0x10(%ebp)
  80164a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80164d:	50                   	push   %eax
  80164e:	68 85 12 80 00       	push   $0x801285
  801653:	e8 6f fc ff ff       	call   8012c7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801658:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80165b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80165e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801661:	83 c4 10             	add    $0x10,%esp
}
  801664:	c9                   	leave  
  801665:	c3                   	ret    
		return -E_INVAL;
  801666:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80166b:	eb f7                	jmp    801664 <vsnprintf+0x49>

0080166d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80166d:	f3 0f 1e fb          	endbr32 
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801677:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80167a:	50                   	push   %eax
  80167b:	ff 75 10             	pushl  0x10(%ebp)
  80167e:	ff 75 0c             	pushl  0xc(%ebp)
  801681:	ff 75 08             	pushl  0x8(%ebp)
  801684:	e8 92 ff ff ff       	call   80161b <vsnprintf>
	va_end(ap);

	return rc;
}
  801689:	c9                   	leave  
  80168a:	c3                   	ret    

0080168b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80168b:	f3 0f 1e fb          	endbr32 
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801695:	b8 00 00 00 00       	mov    $0x0,%eax
  80169a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80169e:	74 05                	je     8016a5 <strlen+0x1a>
		n++;
  8016a0:	83 c0 01             	add    $0x1,%eax
  8016a3:	eb f5                	jmp    80169a <strlen+0xf>
	return n;
}
  8016a5:	5d                   	pop    %ebp
  8016a6:	c3                   	ret    

008016a7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016a7:	f3 0f 1e fb          	endbr32 
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b9:	39 d0                	cmp    %edx,%eax
  8016bb:	74 0d                	je     8016ca <strnlen+0x23>
  8016bd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016c1:	74 05                	je     8016c8 <strnlen+0x21>
		n++;
  8016c3:	83 c0 01             	add    $0x1,%eax
  8016c6:	eb f1                	jmp    8016b9 <strnlen+0x12>
  8016c8:	89 c2                	mov    %eax,%edx
	return n;
}
  8016ca:	89 d0                	mov    %edx,%eax
  8016cc:	5d                   	pop    %ebp
  8016cd:	c3                   	ret    

008016ce <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016ce:	f3 0f 1e fb          	endbr32 
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	53                   	push   %ebx
  8016d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016e5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016e8:	83 c0 01             	add    $0x1,%eax
  8016eb:	84 d2                	test   %dl,%dl
  8016ed:	75 f2                	jne    8016e1 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8016ef:	89 c8                	mov    %ecx,%eax
  8016f1:	5b                   	pop    %ebx
  8016f2:	5d                   	pop    %ebp
  8016f3:	c3                   	ret    

008016f4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016f4:	f3 0f 1e fb          	endbr32 
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	53                   	push   %ebx
  8016fc:	83 ec 10             	sub    $0x10,%esp
  8016ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801702:	53                   	push   %ebx
  801703:	e8 83 ff ff ff       	call   80168b <strlen>
  801708:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80170b:	ff 75 0c             	pushl  0xc(%ebp)
  80170e:	01 d8                	add    %ebx,%eax
  801710:	50                   	push   %eax
  801711:	e8 b8 ff ff ff       	call   8016ce <strcpy>
	return dst;
}
  801716:	89 d8                	mov    %ebx,%eax
  801718:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80171d:	f3 0f 1e fb          	endbr32 
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	56                   	push   %esi
  801725:	53                   	push   %ebx
  801726:	8b 75 08             	mov    0x8(%ebp),%esi
  801729:	8b 55 0c             	mov    0xc(%ebp),%edx
  80172c:	89 f3                	mov    %esi,%ebx
  80172e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801731:	89 f0                	mov    %esi,%eax
  801733:	39 d8                	cmp    %ebx,%eax
  801735:	74 11                	je     801748 <strncpy+0x2b>
		*dst++ = *src;
  801737:	83 c0 01             	add    $0x1,%eax
  80173a:	0f b6 0a             	movzbl (%edx),%ecx
  80173d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801740:	80 f9 01             	cmp    $0x1,%cl
  801743:	83 da ff             	sbb    $0xffffffff,%edx
  801746:	eb eb                	jmp    801733 <strncpy+0x16>
	}
	return ret;
}
  801748:	89 f0                	mov    %esi,%eax
  80174a:	5b                   	pop    %ebx
  80174b:	5e                   	pop    %esi
  80174c:	5d                   	pop    %ebp
  80174d:	c3                   	ret    

0080174e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80174e:	f3 0f 1e fb          	endbr32 
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	56                   	push   %esi
  801756:	53                   	push   %ebx
  801757:	8b 75 08             	mov    0x8(%ebp),%esi
  80175a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175d:	8b 55 10             	mov    0x10(%ebp),%edx
  801760:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801762:	85 d2                	test   %edx,%edx
  801764:	74 21                	je     801787 <strlcpy+0x39>
  801766:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80176a:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80176c:	39 c2                	cmp    %eax,%edx
  80176e:	74 14                	je     801784 <strlcpy+0x36>
  801770:	0f b6 19             	movzbl (%ecx),%ebx
  801773:	84 db                	test   %bl,%bl
  801775:	74 0b                	je     801782 <strlcpy+0x34>
			*dst++ = *src++;
  801777:	83 c1 01             	add    $0x1,%ecx
  80177a:	83 c2 01             	add    $0x1,%edx
  80177d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801780:	eb ea                	jmp    80176c <strlcpy+0x1e>
  801782:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801784:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801787:	29 f0                	sub    %esi,%eax
}
  801789:	5b                   	pop    %ebx
  80178a:	5e                   	pop    %esi
  80178b:	5d                   	pop    %ebp
  80178c:	c3                   	ret    

0080178d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80178d:	f3 0f 1e fb          	endbr32 
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801797:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80179a:	0f b6 01             	movzbl (%ecx),%eax
  80179d:	84 c0                	test   %al,%al
  80179f:	74 0c                	je     8017ad <strcmp+0x20>
  8017a1:	3a 02                	cmp    (%edx),%al
  8017a3:	75 08                	jne    8017ad <strcmp+0x20>
		p++, q++;
  8017a5:	83 c1 01             	add    $0x1,%ecx
  8017a8:	83 c2 01             	add    $0x1,%edx
  8017ab:	eb ed                	jmp    80179a <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ad:	0f b6 c0             	movzbl %al,%eax
  8017b0:	0f b6 12             	movzbl (%edx),%edx
  8017b3:	29 d0                	sub    %edx,%eax
}
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    

008017b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017b7:	f3 0f 1e fb          	endbr32 
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	53                   	push   %ebx
  8017bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c5:	89 c3                	mov    %eax,%ebx
  8017c7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017ca:	eb 06                	jmp    8017d2 <strncmp+0x1b>
		n--, p++, q++;
  8017cc:	83 c0 01             	add    $0x1,%eax
  8017cf:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017d2:	39 d8                	cmp    %ebx,%eax
  8017d4:	74 16                	je     8017ec <strncmp+0x35>
  8017d6:	0f b6 08             	movzbl (%eax),%ecx
  8017d9:	84 c9                	test   %cl,%cl
  8017db:	74 04                	je     8017e1 <strncmp+0x2a>
  8017dd:	3a 0a                	cmp    (%edx),%cl
  8017df:	74 eb                	je     8017cc <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e1:	0f b6 00             	movzbl (%eax),%eax
  8017e4:	0f b6 12             	movzbl (%edx),%edx
  8017e7:	29 d0                	sub    %edx,%eax
}
  8017e9:	5b                   	pop    %ebx
  8017ea:	5d                   	pop    %ebp
  8017eb:	c3                   	ret    
		return 0;
  8017ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f1:	eb f6                	jmp    8017e9 <strncmp+0x32>

008017f3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017f3:	f3 0f 1e fb          	endbr32 
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801801:	0f b6 10             	movzbl (%eax),%edx
  801804:	84 d2                	test   %dl,%dl
  801806:	74 09                	je     801811 <strchr+0x1e>
		if (*s == c)
  801808:	38 ca                	cmp    %cl,%dl
  80180a:	74 0a                	je     801816 <strchr+0x23>
	for (; *s; s++)
  80180c:	83 c0 01             	add    $0x1,%eax
  80180f:	eb f0                	jmp    801801 <strchr+0xe>
			return (char *) s;
	return 0;
  801811:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801816:	5d                   	pop    %ebp
  801817:	c3                   	ret    

00801818 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801818:	f3 0f 1e fb          	endbr32 
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	8b 45 08             	mov    0x8(%ebp),%eax
  801822:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801826:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801829:	38 ca                	cmp    %cl,%dl
  80182b:	74 09                	je     801836 <strfind+0x1e>
  80182d:	84 d2                	test   %dl,%dl
  80182f:	74 05                	je     801836 <strfind+0x1e>
	for (; *s; s++)
  801831:	83 c0 01             	add    $0x1,%eax
  801834:	eb f0                	jmp    801826 <strfind+0xe>
			break;
	return (char *) s;
}
  801836:	5d                   	pop    %ebp
  801837:	c3                   	ret    

00801838 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801838:	f3 0f 1e fb          	endbr32 
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	57                   	push   %edi
  801840:	56                   	push   %esi
  801841:	53                   	push   %ebx
  801842:	8b 55 08             	mov    0x8(%ebp),%edx
  801845:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  801848:	85 c9                	test   %ecx,%ecx
  80184a:	74 33                	je     80187f <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80184c:	89 d0                	mov    %edx,%eax
  80184e:	09 c8                	or     %ecx,%eax
  801850:	a8 03                	test   $0x3,%al
  801852:	75 23                	jne    801877 <memset+0x3f>
		c &= 0xFF;
  801854:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801858:	89 d8                	mov    %ebx,%eax
  80185a:	c1 e0 08             	shl    $0x8,%eax
  80185d:	89 df                	mov    %ebx,%edi
  80185f:	c1 e7 18             	shl    $0x18,%edi
  801862:	89 de                	mov    %ebx,%esi
  801864:	c1 e6 10             	shl    $0x10,%esi
  801867:	09 f7                	or     %esi,%edi
  801869:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  80186b:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80186e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  801870:	89 d7                	mov    %edx,%edi
  801872:	fc                   	cld    
  801873:	f3 ab                	rep stos %eax,%es:(%edi)
  801875:	eb 08                	jmp    80187f <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801877:	89 d7                	mov    %edx,%edi
  801879:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187c:	fc                   	cld    
  80187d:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  80187f:	89 d0                	mov    %edx,%eax
  801881:	5b                   	pop    %ebx
  801882:	5e                   	pop    %esi
  801883:	5f                   	pop    %edi
  801884:	5d                   	pop    %ebp
  801885:	c3                   	ret    

00801886 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801886:	f3 0f 1e fb          	endbr32 
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	57                   	push   %edi
  80188e:	56                   	push   %esi
  80188f:	8b 45 08             	mov    0x8(%ebp),%eax
  801892:	8b 75 0c             	mov    0xc(%ebp),%esi
  801895:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801898:	39 c6                	cmp    %eax,%esi
  80189a:	73 32                	jae    8018ce <memmove+0x48>
  80189c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80189f:	39 c2                	cmp    %eax,%edx
  8018a1:	76 2b                	jbe    8018ce <memmove+0x48>
		s += n;
		d += n;
  8018a3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a6:	89 fe                	mov    %edi,%esi
  8018a8:	09 ce                	or     %ecx,%esi
  8018aa:	09 d6                	or     %edx,%esi
  8018ac:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018b2:	75 0e                	jne    8018c2 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018b4:	83 ef 04             	sub    $0x4,%edi
  8018b7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018ba:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018bd:	fd                   	std    
  8018be:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c0:	eb 09                	jmp    8018cb <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018c2:	83 ef 01             	sub    $0x1,%edi
  8018c5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018c8:	fd                   	std    
  8018c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018cb:	fc                   	cld    
  8018cc:	eb 1a                	jmp    8018e8 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ce:	89 c2                	mov    %eax,%edx
  8018d0:	09 ca                	or     %ecx,%edx
  8018d2:	09 f2                	or     %esi,%edx
  8018d4:	f6 c2 03             	test   $0x3,%dl
  8018d7:	75 0a                	jne    8018e3 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018d9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018dc:	89 c7                	mov    %eax,%edi
  8018de:	fc                   	cld    
  8018df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e1:	eb 05                	jmp    8018e8 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8018e3:	89 c7                	mov    %eax,%edi
  8018e5:	fc                   	cld    
  8018e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018e8:	5e                   	pop    %esi
  8018e9:	5f                   	pop    %edi
  8018ea:	5d                   	pop    %ebp
  8018eb:	c3                   	ret    

008018ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018ec:	f3 0f 1e fb          	endbr32 
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018f6:	ff 75 10             	pushl  0x10(%ebp)
  8018f9:	ff 75 0c             	pushl  0xc(%ebp)
  8018fc:	ff 75 08             	pushl  0x8(%ebp)
  8018ff:	e8 82 ff ff ff       	call   801886 <memmove>
}
  801904:	c9                   	leave  
  801905:	c3                   	ret    

00801906 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801906:	f3 0f 1e fb          	endbr32 
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	56                   	push   %esi
  80190e:	53                   	push   %ebx
  80190f:	8b 45 08             	mov    0x8(%ebp),%eax
  801912:	8b 55 0c             	mov    0xc(%ebp),%edx
  801915:	89 c6                	mov    %eax,%esi
  801917:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80191a:	39 f0                	cmp    %esi,%eax
  80191c:	74 1c                	je     80193a <memcmp+0x34>
		if (*s1 != *s2)
  80191e:	0f b6 08             	movzbl (%eax),%ecx
  801921:	0f b6 1a             	movzbl (%edx),%ebx
  801924:	38 d9                	cmp    %bl,%cl
  801926:	75 08                	jne    801930 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801928:	83 c0 01             	add    $0x1,%eax
  80192b:	83 c2 01             	add    $0x1,%edx
  80192e:	eb ea                	jmp    80191a <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801930:	0f b6 c1             	movzbl %cl,%eax
  801933:	0f b6 db             	movzbl %bl,%ebx
  801936:	29 d8                	sub    %ebx,%eax
  801938:	eb 05                	jmp    80193f <memcmp+0x39>
	}

	return 0;
  80193a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80193f:	5b                   	pop    %ebx
  801940:	5e                   	pop    %esi
  801941:	5d                   	pop    %ebp
  801942:	c3                   	ret    

00801943 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801943:	f3 0f 1e fb          	endbr32 
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	8b 45 08             	mov    0x8(%ebp),%eax
  80194d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801950:	89 c2                	mov    %eax,%edx
  801952:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801955:	39 d0                	cmp    %edx,%eax
  801957:	73 09                	jae    801962 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801959:	38 08                	cmp    %cl,(%eax)
  80195b:	74 05                	je     801962 <memfind+0x1f>
	for (; s < ends; s++)
  80195d:	83 c0 01             	add    $0x1,%eax
  801960:	eb f3                	jmp    801955 <memfind+0x12>
			break;
	return (void *) s;
}
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    

00801964 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801964:	f3 0f 1e fb          	endbr32 
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	57                   	push   %edi
  80196c:	56                   	push   %esi
  80196d:	53                   	push   %ebx
  80196e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801971:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801974:	eb 03                	jmp    801979 <strtol+0x15>
		s++;
  801976:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801979:	0f b6 01             	movzbl (%ecx),%eax
  80197c:	3c 20                	cmp    $0x20,%al
  80197e:	74 f6                	je     801976 <strtol+0x12>
  801980:	3c 09                	cmp    $0x9,%al
  801982:	74 f2                	je     801976 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801984:	3c 2b                	cmp    $0x2b,%al
  801986:	74 2a                	je     8019b2 <strtol+0x4e>
	int neg = 0;
  801988:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80198d:	3c 2d                	cmp    $0x2d,%al
  80198f:	74 2b                	je     8019bc <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801991:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801997:	75 0f                	jne    8019a8 <strtol+0x44>
  801999:	80 39 30             	cmpb   $0x30,(%ecx)
  80199c:	74 28                	je     8019c6 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80199e:	85 db                	test   %ebx,%ebx
  8019a0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019a5:	0f 44 d8             	cmove  %eax,%ebx
  8019a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ad:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019b0:	eb 46                	jmp    8019f8 <strtol+0x94>
		s++;
  8019b2:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019b5:	bf 00 00 00 00       	mov    $0x0,%edi
  8019ba:	eb d5                	jmp    801991 <strtol+0x2d>
		s++, neg = 1;
  8019bc:	83 c1 01             	add    $0x1,%ecx
  8019bf:	bf 01 00 00 00       	mov    $0x1,%edi
  8019c4:	eb cb                	jmp    801991 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019c6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019ca:	74 0e                	je     8019da <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019cc:	85 db                	test   %ebx,%ebx
  8019ce:	75 d8                	jne    8019a8 <strtol+0x44>
		s++, base = 8;
  8019d0:	83 c1 01             	add    $0x1,%ecx
  8019d3:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019d8:	eb ce                	jmp    8019a8 <strtol+0x44>
		s += 2, base = 16;
  8019da:	83 c1 02             	add    $0x2,%ecx
  8019dd:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019e2:	eb c4                	jmp    8019a8 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019e4:	0f be d2             	movsbl %dl,%edx
  8019e7:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019ea:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019ed:	7d 3a                	jge    801a29 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019ef:	83 c1 01             	add    $0x1,%ecx
  8019f2:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019f6:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019f8:	0f b6 11             	movzbl (%ecx),%edx
  8019fb:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019fe:	89 f3                	mov    %esi,%ebx
  801a00:	80 fb 09             	cmp    $0x9,%bl
  801a03:	76 df                	jbe    8019e4 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801a05:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a08:	89 f3                	mov    %esi,%ebx
  801a0a:	80 fb 19             	cmp    $0x19,%bl
  801a0d:	77 08                	ja     801a17 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a0f:	0f be d2             	movsbl %dl,%edx
  801a12:	83 ea 57             	sub    $0x57,%edx
  801a15:	eb d3                	jmp    8019ea <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801a17:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a1a:	89 f3                	mov    %esi,%ebx
  801a1c:	80 fb 19             	cmp    $0x19,%bl
  801a1f:	77 08                	ja     801a29 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a21:	0f be d2             	movsbl %dl,%edx
  801a24:	83 ea 37             	sub    $0x37,%edx
  801a27:	eb c1                	jmp    8019ea <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a29:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a2d:	74 05                	je     801a34 <strtol+0xd0>
		*endptr = (char *) s;
  801a2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a32:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a34:	89 c2                	mov    %eax,%edx
  801a36:	f7 da                	neg    %edx
  801a38:	85 ff                	test   %edi,%edi
  801a3a:	0f 45 c2             	cmovne %edx,%eax
}
  801a3d:	5b                   	pop    %ebx
  801a3e:	5e                   	pop    %esi
  801a3f:	5f                   	pop    %edi
  801a40:	5d                   	pop    %ebp
  801a41:	c3                   	ret    

00801a42 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a42:	f3 0f 1e fb          	endbr32 
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	56                   	push   %esi
  801a4a:	53                   	push   %ebx
  801a4b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  801a54:	85 c0                	test   %eax,%eax
  801a56:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a5b:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801a5e:	83 ec 0c             	sub    $0xc,%esp
  801a61:	50                   	push   %eax
  801a62:	e8 82 e8 ff ff       	call   8002e9 <sys_ipc_recv>
	if (f < 0) {
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	78 2b                	js     801a99 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801a6e:	85 f6                	test   %esi,%esi
  801a70:	74 0a                	je     801a7c <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801a72:	a1 04 40 80 00       	mov    0x804004,%eax
  801a77:	8b 40 74             	mov    0x74(%eax),%eax
  801a7a:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801a7c:	85 db                	test   %ebx,%ebx
  801a7e:	74 0a                	je     801a8a <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801a80:	a1 04 40 80 00       	mov    0x804004,%eax
  801a85:	8b 40 78             	mov    0x78(%eax),%eax
  801a88:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  801a8a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a8f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a95:	5b                   	pop    %ebx
  801a96:	5e                   	pop    %esi
  801a97:	5d                   	pop    %ebp
  801a98:	c3                   	ret    
		if (from_env_store != NULL) {
  801a99:	85 f6                	test   %esi,%esi
  801a9b:	74 06                	je     801aa3 <ipc_recv+0x61>
			*from_env_store = 0;
  801a9d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801aa3:	85 db                	test   %ebx,%ebx
  801aa5:	74 eb                	je     801a92 <ipc_recv+0x50>
			*perm_store = 0;
  801aa7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aad:	eb e3                	jmp    801a92 <ipc_recv+0x50>

00801aaf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aaf:	f3 0f 1e fb          	endbr32 
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	57                   	push   %edi
  801ab7:	56                   	push   %esi
  801ab8:	53                   	push   %ebx
  801ab9:	83 ec 0c             	sub    $0xc,%esp
  801abc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801abf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ac2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  801ac5:	85 db                	test   %ebx,%ebx
  801ac7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801acc:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801acf:	ff 75 14             	pushl  0x14(%ebp)
  801ad2:	53                   	push   %ebx
  801ad3:	56                   	push   %esi
  801ad4:	57                   	push   %edi
  801ad5:	e8 e6 e7 ff ff       	call   8002c0 <sys_ipc_try_send>
  801ada:	83 c4 10             	add    $0x10,%esp
  801add:	85 c0                	test   %eax,%eax
  801adf:	79 19                	jns    801afa <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  801ae1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ae4:	74 e9                	je     801acf <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  801ae6:	83 ec 04             	sub    $0x4,%esp
  801ae9:	68 40 22 80 00       	push   $0x802240
  801aee:	6a 48                	push   $0x48
  801af0:	68 62 22 80 00       	push   $0x802262
  801af5:	e8 83 f5 ff ff       	call   80107d <_panic>
		}
	}
}
  801afa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801afd:	5b                   	pop    %ebx
  801afe:	5e                   	pop    %esi
  801aff:	5f                   	pop    %edi
  801b00:	5d                   	pop    %ebp
  801b01:	c3                   	ret    

00801b02 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b02:	f3 0f 1e fb          	endbr32 
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b0c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b11:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b14:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b1a:	8b 52 50             	mov    0x50(%edx),%edx
  801b1d:	39 ca                	cmp    %ecx,%edx
  801b1f:	74 11                	je     801b32 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801b21:	83 c0 01             	add    $0x1,%eax
  801b24:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b29:	75 e6                	jne    801b11 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b30:	eb 0b                	jmp    801b3d <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b32:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b35:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b3a:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b3d:	5d                   	pop    %ebp
  801b3e:	c3                   	ret    

00801b3f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b3f:	f3 0f 1e fb          	endbr32 
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b49:	89 c2                	mov    %eax,%edx
  801b4b:	c1 ea 16             	shr    $0x16,%edx
  801b4e:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b55:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b5a:	f6 c1 01             	test   $0x1,%cl
  801b5d:	74 1c                	je     801b7b <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b5f:	c1 e8 0c             	shr    $0xc,%eax
  801b62:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b69:	a8 01                	test   $0x1,%al
  801b6b:	74 0e                	je     801b7b <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b6d:	c1 e8 0c             	shr    $0xc,%eax
  801b70:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b77:	ef 
  801b78:	0f b7 d2             	movzwl %dx,%edx
}
  801b7b:	89 d0                	mov    %edx,%eax
  801b7d:	5d                   	pop    %ebp
  801b7e:	c3                   	ret    
  801b7f:	90                   	nop

00801b80 <__udivdi3>:
  801b80:	f3 0f 1e fb          	endbr32 
  801b84:	55                   	push   %ebp
  801b85:	57                   	push   %edi
  801b86:	56                   	push   %esi
  801b87:	53                   	push   %ebx
  801b88:	83 ec 1c             	sub    $0x1c,%esp
  801b8b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b8f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b93:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b97:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b9b:	85 d2                	test   %edx,%edx
  801b9d:	75 19                	jne    801bb8 <__udivdi3+0x38>
  801b9f:	39 f3                	cmp    %esi,%ebx
  801ba1:	76 4d                	jbe    801bf0 <__udivdi3+0x70>
  801ba3:	31 ff                	xor    %edi,%edi
  801ba5:	89 e8                	mov    %ebp,%eax
  801ba7:	89 f2                	mov    %esi,%edx
  801ba9:	f7 f3                	div    %ebx
  801bab:	89 fa                	mov    %edi,%edx
  801bad:	83 c4 1c             	add    $0x1c,%esp
  801bb0:	5b                   	pop    %ebx
  801bb1:	5e                   	pop    %esi
  801bb2:	5f                   	pop    %edi
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    
  801bb5:	8d 76 00             	lea    0x0(%esi),%esi
  801bb8:	39 f2                	cmp    %esi,%edx
  801bba:	76 14                	jbe    801bd0 <__udivdi3+0x50>
  801bbc:	31 ff                	xor    %edi,%edi
  801bbe:	31 c0                	xor    %eax,%eax
  801bc0:	89 fa                	mov    %edi,%edx
  801bc2:	83 c4 1c             	add    $0x1c,%esp
  801bc5:	5b                   	pop    %ebx
  801bc6:	5e                   	pop    %esi
  801bc7:	5f                   	pop    %edi
  801bc8:	5d                   	pop    %ebp
  801bc9:	c3                   	ret    
  801bca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bd0:	0f bd fa             	bsr    %edx,%edi
  801bd3:	83 f7 1f             	xor    $0x1f,%edi
  801bd6:	75 48                	jne    801c20 <__udivdi3+0xa0>
  801bd8:	39 f2                	cmp    %esi,%edx
  801bda:	72 06                	jb     801be2 <__udivdi3+0x62>
  801bdc:	31 c0                	xor    %eax,%eax
  801bde:	39 eb                	cmp    %ebp,%ebx
  801be0:	77 de                	ja     801bc0 <__udivdi3+0x40>
  801be2:	b8 01 00 00 00       	mov    $0x1,%eax
  801be7:	eb d7                	jmp    801bc0 <__udivdi3+0x40>
  801be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	89 d9                	mov    %ebx,%ecx
  801bf2:	85 db                	test   %ebx,%ebx
  801bf4:	75 0b                	jne    801c01 <__udivdi3+0x81>
  801bf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bfb:	31 d2                	xor    %edx,%edx
  801bfd:	f7 f3                	div    %ebx
  801bff:	89 c1                	mov    %eax,%ecx
  801c01:	31 d2                	xor    %edx,%edx
  801c03:	89 f0                	mov    %esi,%eax
  801c05:	f7 f1                	div    %ecx
  801c07:	89 c6                	mov    %eax,%esi
  801c09:	89 e8                	mov    %ebp,%eax
  801c0b:	89 f7                	mov    %esi,%edi
  801c0d:	f7 f1                	div    %ecx
  801c0f:	89 fa                	mov    %edi,%edx
  801c11:	83 c4 1c             	add    $0x1c,%esp
  801c14:	5b                   	pop    %ebx
  801c15:	5e                   	pop    %esi
  801c16:	5f                   	pop    %edi
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	89 f9                	mov    %edi,%ecx
  801c22:	b8 20 00 00 00       	mov    $0x20,%eax
  801c27:	29 f8                	sub    %edi,%eax
  801c29:	d3 e2                	shl    %cl,%edx
  801c2b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c2f:	89 c1                	mov    %eax,%ecx
  801c31:	89 da                	mov    %ebx,%edx
  801c33:	d3 ea                	shr    %cl,%edx
  801c35:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c39:	09 d1                	or     %edx,%ecx
  801c3b:	89 f2                	mov    %esi,%edx
  801c3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c41:	89 f9                	mov    %edi,%ecx
  801c43:	d3 e3                	shl    %cl,%ebx
  801c45:	89 c1                	mov    %eax,%ecx
  801c47:	d3 ea                	shr    %cl,%edx
  801c49:	89 f9                	mov    %edi,%ecx
  801c4b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c4f:	89 eb                	mov    %ebp,%ebx
  801c51:	d3 e6                	shl    %cl,%esi
  801c53:	89 c1                	mov    %eax,%ecx
  801c55:	d3 eb                	shr    %cl,%ebx
  801c57:	09 de                	or     %ebx,%esi
  801c59:	89 f0                	mov    %esi,%eax
  801c5b:	f7 74 24 08          	divl   0x8(%esp)
  801c5f:	89 d6                	mov    %edx,%esi
  801c61:	89 c3                	mov    %eax,%ebx
  801c63:	f7 64 24 0c          	mull   0xc(%esp)
  801c67:	39 d6                	cmp    %edx,%esi
  801c69:	72 15                	jb     801c80 <__udivdi3+0x100>
  801c6b:	89 f9                	mov    %edi,%ecx
  801c6d:	d3 e5                	shl    %cl,%ebp
  801c6f:	39 c5                	cmp    %eax,%ebp
  801c71:	73 04                	jae    801c77 <__udivdi3+0xf7>
  801c73:	39 d6                	cmp    %edx,%esi
  801c75:	74 09                	je     801c80 <__udivdi3+0x100>
  801c77:	89 d8                	mov    %ebx,%eax
  801c79:	31 ff                	xor    %edi,%edi
  801c7b:	e9 40 ff ff ff       	jmp    801bc0 <__udivdi3+0x40>
  801c80:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c83:	31 ff                	xor    %edi,%edi
  801c85:	e9 36 ff ff ff       	jmp    801bc0 <__udivdi3+0x40>
  801c8a:	66 90                	xchg   %ax,%ax
  801c8c:	66 90                	xchg   %ax,%ax
  801c8e:	66 90                	xchg   %ax,%ax

00801c90 <__umoddi3>:
  801c90:	f3 0f 1e fb          	endbr32 
  801c94:	55                   	push   %ebp
  801c95:	57                   	push   %edi
  801c96:	56                   	push   %esi
  801c97:	53                   	push   %ebx
  801c98:	83 ec 1c             	sub    $0x1c,%esp
  801c9b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c9f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801ca3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801ca7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cab:	85 c0                	test   %eax,%eax
  801cad:	75 19                	jne    801cc8 <__umoddi3+0x38>
  801caf:	39 df                	cmp    %ebx,%edi
  801cb1:	76 5d                	jbe    801d10 <__umoddi3+0x80>
  801cb3:	89 f0                	mov    %esi,%eax
  801cb5:	89 da                	mov    %ebx,%edx
  801cb7:	f7 f7                	div    %edi
  801cb9:	89 d0                	mov    %edx,%eax
  801cbb:	31 d2                	xor    %edx,%edx
  801cbd:	83 c4 1c             	add    $0x1c,%esp
  801cc0:	5b                   	pop    %ebx
  801cc1:	5e                   	pop    %esi
  801cc2:	5f                   	pop    %edi
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    
  801cc5:	8d 76 00             	lea    0x0(%esi),%esi
  801cc8:	89 f2                	mov    %esi,%edx
  801cca:	39 d8                	cmp    %ebx,%eax
  801ccc:	76 12                	jbe    801ce0 <__umoddi3+0x50>
  801cce:	89 f0                	mov    %esi,%eax
  801cd0:	89 da                	mov    %ebx,%edx
  801cd2:	83 c4 1c             	add    $0x1c,%esp
  801cd5:	5b                   	pop    %ebx
  801cd6:	5e                   	pop    %esi
  801cd7:	5f                   	pop    %edi
  801cd8:	5d                   	pop    %ebp
  801cd9:	c3                   	ret    
  801cda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ce0:	0f bd e8             	bsr    %eax,%ebp
  801ce3:	83 f5 1f             	xor    $0x1f,%ebp
  801ce6:	75 50                	jne    801d38 <__umoddi3+0xa8>
  801ce8:	39 d8                	cmp    %ebx,%eax
  801cea:	0f 82 e0 00 00 00    	jb     801dd0 <__umoddi3+0x140>
  801cf0:	89 d9                	mov    %ebx,%ecx
  801cf2:	39 f7                	cmp    %esi,%edi
  801cf4:	0f 86 d6 00 00 00    	jbe    801dd0 <__umoddi3+0x140>
  801cfa:	89 d0                	mov    %edx,%eax
  801cfc:	89 ca                	mov    %ecx,%edx
  801cfe:	83 c4 1c             	add    $0x1c,%esp
  801d01:	5b                   	pop    %ebx
  801d02:	5e                   	pop    %esi
  801d03:	5f                   	pop    %edi
  801d04:	5d                   	pop    %ebp
  801d05:	c3                   	ret    
  801d06:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d0d:	8d 76 00             	lea    0x0(%esi),%esi
  801d10:	89 fd                	mov    %edi,%ebp
  801d12:	85 ff                	test   %edi,%edi
  801d14:	75 0b                	jne    801d21 <__umoddi3+0x91>
  801d16:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1b:	31 d2                	xor    %edx,%edx
  801d1d:	f7 f7                	div    %edi
  801d1f:	89 c5                	mov    %eax,%ebp
  801d21:	89 d8                	mov    %ebx,%eax
  801d23:	31 d2                	xor    %edx,%edx
  801d25:	f7 f5                	div    %ebp
  801d27:	89 f0                	mov    %esi,%eax
  801d29:	f7 f5                	div    %ebp
  801d2b:	89 d0                	mov    %edx,%eax
  801d2d:	31 d2                	xor    %edx,%edx
  801d2f:	eb 8c                	jmp    801cbd <__umoddi3+0x2d>
  801d31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d38:	89 e9                	mov    %ebp,%ecx
  801d3a:	ba 20 00 00 00       	mov    $0x20,%edx
  801d3f:	29 ea                	sub    %ebp,%edx
  801d41:	d3 e0                	shl    %cl,%eax
  801d43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d47:	89 d1                	mov    %edx,%ecx
  801d49:	89 f8                	mov    %edi,%eax
  801d4b:	d3 e8                	shr    %cl,%eax
  801d4d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d51:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d55:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d59:	09 c1                	or     %eax,%ecx
  801d5b:	89 d8                	mov    %ebx,%eax
  801d5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d61:	89 e9                	mov    %ebp,%ecx
  801d63:	d3 e7                	shl    %cl,%edi
  801d65:	89 d1                	mov    %edx,%ecx
  801d67:	d3 e8                	shr    %cl,%eax
  801d69:	89 e9                	mov    %ebp,%ecx
  801d6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d6f:	d3 e3                	shl    %cl,%ebx
  801d71:	89 c7                	mov    %eax,%edi
  801d73:	89 d1                	mov    %edx,%ecx
  801d75:	89 f0                	mov    %esi,%eax
  801d77:	d3 e8                	shr    %cl,%eax
  801d79:	89 e9                	mov    %ebp,%ecx
  801d7b:	89 fa                	mov    %edi,%edx
  801d7d:	d3 e6                	shl    %cl,%esi
  801d7f:	09 d8                	or     %ebx,%eax
  801d81:	f7 74 24 08          	divl   0x8(%esp)
  801d85:	89 d1                	mov    %edx,%ecx
  801d87:	89 f3                	mov    %esi,%ebx
  801d89:	f7 64 24 0c          	mull   0xc(%esp)
  801d8d:	89 c6                	mov    %eax,%esi
  801d8f:	89 d7                	mov    %edx,%edi
  801d91:	39 d1                	cmp    %edx,%ecx
  801d93:	72 06                	jb     801d9b <__umoddi3+0x10b>
  801d95:	75 10                	jne    801da7 <__umoddi3+0x117>
  801d97:	39 c3                	cmp    %eax,%ebx
  801d99:	73 0c                	jae    801da7 <__umoddi3+0x117>
  801d9b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801d9f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801da3:	89 d7                	mov    %edx,%edi
  801da5:	89 c6                	mov    %eax,%esi
  801da7:	89 ca                	mov    %ecx,%edx
  801da9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801dae:	29 f3                	sub    %esi,%ebx
  801db0:	19 fa                	sbb    %edi,%edx
  801db2:	89 d0                	mov    %edx,%eax
  801db4:	d3 e0                	shl    %cl,%eax
  801db6:	89 e9                	mov    %ebp,%ecx
  801db8:	d3 eb                	shr    %cl,%ebx
  801dba:	d3 ea                	shr    %cl,%edx
  801dbc:	09 d8                	or     %ebx,%eax
  801dbe:	83 c4 1c             	add    $0x1c,%esp
  801dc1:	5b                   	pop    %ebx
  801dc2:	5e                   	pop    %esi
  801dc3:	5f                   	pop    %edi
  801dc4:	5d                   	pop    %ebp
  801dc5:	c3                   	ret    
  801dc6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dcd:	8d 76 00             	lea    0x0(%esi),%esi
  801dd0:	29 fe                	sub    %edi,%esi
  801dd2:	19 c3                	sbb    %eax,%ebx
  801dd4:	89 f2                	mov    %esi,%edx
  801dd6:	89 d9                	mov    %ebx,%ecx
  801dd8:	e9 1d ff ff ff       	jmp    801cfa <__umoddi3+0x6a>
