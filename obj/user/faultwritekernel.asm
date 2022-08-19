
obj/user/faultwritekernel.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	*(unsigned*)0xf0100000 = 0;
  800037:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003e:	00 00 00 
}
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	f3 0f 1e fb          	endbr32 
  800046:	55                   	push   %ebp
  800047:	89 e5                	mov    %esp,%ebp
  800049:	56                   	push   %esi
  80004a:	53                   	push   %ebx
  80004b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800051:	e8 19 01 00 00       	call   80016f <sys_getenvid>
	if (id >= 0)
  800056:	85 c0                	test   %eax,%eax
  800058:	78 12                	js     80006c <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x35>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	f3 0f 1e fb          	endbr32 
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 53 04 00 00       	call   8004f2 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 a0 00 00 00       	call   800149 <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
  8000b4:	83 ec 1c             	sub    $0x1c,%esp
  8000b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000bd:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000c5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c8:	8b 75 14             	mov    0x14(%ebp),%esi
  8000cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000cd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000d1:	74 04                	je     8000d7 <syscall+0x29>
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	7f 08                	jg     8000df <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000df:	83 ec 0c             	sub    $0xc,%esp
  8000e2:	50                   	push   %eax
  8000e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8000e6:	68 ea 1d 80 00       	push   $0x801dea
  8000eb:	6a 23                	push   $0x23
  8000ed:	68 07 1e 80 00       	push   $0x801e07
  8000f2:	e8 76 0f 00 00       	call   80106d <_panic>

008000f7 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000f7:	f3 0f 1e fb          	endbr32 
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800101:	6a 00                	push   $0x0
  800103:	6a 00                	push   $0x0
  800105:	6a 00                	push   $0x0
  800107:	ff 75 0c             	pushl  0xc(%ebp)
  80010a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010d:	ba 00 00 00 00       	mov    $0x0,%edx
  800112:	b8 00 00 00 00       	mov    $0x0,%eax
  800117:	e8 92 ff ff ff       	call   8000ae <syscall>
}
  80011c:	83 c4 10             	add    $0x10,%esp
  80011f:	c9                   	leave  
  800120:	c3                   	ret    

00800121 <sys_cgetc>:

int
sys_cgetc(void)
{
  800121:	f3 0f 1e fb          	endbr32 
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80012b:	6a 00                	push   $0x0
  80012d:	6a 00                	push   $0x0
  80012f:	6a 00                	push   $0x0
  800131:	6a 00                	push   $0x0
  800133:	b9 00 00 00 00       	mov    $0x0,%ecx
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 01 00 00 00       	mov    $0x1,%eax
  800142:	e8 67 ff ff ff       	call   8000ae <syscall>
}
  800147:	c9                   	leave  
  800148:	c3                   	ret    

00800149 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800149:	f3 0f 1e fb          	endbr32 
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800153:	6a 00                	push   $0x0
  800155:	6a 00                	push   $0x0
  800157:	6a 00                	push   $0x0
  800159:	6a 00                	push   $0x0
  80015b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015e:	ba 01 00 00 00       	mov    $0x1,%edx
  800163:	b8 03 00 00 00       	mov    $0x3,%eax
  800168:	e8 41 ff ff ff       	call   8000ae <syscall>
}
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    

0080016f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016f:	f3 0f 1e fb          	endbr32 
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800179:	6a 00                	push   $0x0
  80017b:	6a 00                	push   $0x0
  80017d:	6a 00                	push   $0x0
  80017f:	6a 00                	push   $0x0
  800181:	b9 00 00 00 00       	mov    $0x0,%ecx
  800186:	ba 00 00 00 00       	mov    $0x0,%edx
  80018b:	b8 02 00 00 00       	mov    $0x2,%eax
  800190:	e8 19 ff ff ff       	call   8000ae <syscall>
}
  800195:	c9                   	leave  
  800196:	c3                   	ret    

00800197 <sys_yield>:

void
sys_yield(void)
{
  800197:	f3 0f 1e fb          	endbr32 
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001a1:	6a 00                	push   $0x0
  8001a3:	6a 00                	push   $0x0
  8001a5:	6a 00                	push   $0x0
  8001a7:	6a 00                	push   $0x0
  8001a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001b8:	e8 f1 fe ff ff       	call   8000ae <syscall>
}
  8001bd:	83 c4 10             	add    $0x10,%esp
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    

008001c2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001c2:	f3 0f 1e fb          	endbr32 
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001cc:	6a 00                	push   $0x0
  8001ce:	6a 00                	push   $0x0
  8001d0:	ff 75 10             	pushl  0x10(%ebp)
  8001d3:	ff 75 0c             	pushl  0xc(%ebp)
  8001d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d9:	ba 01 00 00 00       	mov    $0x1,%edx
  8001de:	b8 04 00 00 00       	mov    $0x4,%eax
  8001e3:	e8 c6 fe ff ff       	call   8000ae <syscall>
}
  8001e8:	c9                   	leave  
  8001e9:	c3                   	ret    

008001ea <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ea:	f3 0f 1e fb          	endbr32 
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001f4:	ff 75 18             	pushl  0x18(%ebp)
  8001f7:	ff 75 14             	pushl  0x14(%ebp)
  8001fa:	ff 75 10             	pushl  0x10(%ebp)
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800203:	ba 01 00 00 00       	mov    $0x1,%edx
  800208:	b8 05 00 00 00       	mov    $0x5,%eax
  80020d:	e8 9c fe ff ff       	call   8000ae <syscall>
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800214:	f3 0f 1e fb          	endbr32 
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80021e:	6a 00                	push   $0x0
  800220:	6a 00                	push   $0x0
  800222:	6a 00                	push   $0x0
  800224:	ff 75 0c             	pushl  0xc(%ebp)
  800227:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80022a:	ba 01 00 00 00       	mov    $0x1,%edx
  80022f:	b8 06 00 00 00       	mov    $0x6,%eax
  800234:	e8 75 fe ff ff       	call   8000ae <syscall>
}
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80023b:	f3 0f 1e fb          	endbr32 
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800245:	6a 00                	push   $0x0
  800247:	6a 00                	push   $0x0
  800249:	6a 00                	push   $0x0
  80024b:	ff 75 0c             	pushl  0xc(%ebp)
  80024e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800251:	ba 01 00 00 00       	mov    $0x1,%edx
  800256:	b8 08 00 00 00       	mov    $0x8,%eax
  80025b:	e8 4e fe ff ff       	call   8000ae <syscall>
}
  800260:	c9                   	leave  
  800261:	c3                   	ret    

00800262 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800262:	f3 0f 1e fb          	endbr32 
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80026c:	6a 00                	push   $0x0
  80026e:	6a 00                	push   $0x0
  800270:	6a 00                	push   $0x0
  800272:	ff 75 0c             	pushl  0xc(%ebp)
  800275:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800278:	ba 01 00 00 00       	mov    $0x1,%edx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	e8 27 fe ff ff       	call   8000ae <syscall>
}
  800287:	c9                   	leave  
  800288:	c3                   	ret    

00800289 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800289:	f3 0f 1e fb          	endbr32 
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800293:	6a 00                	push   $0x0
  800295:	6a 00                	push   $0x0
  800297:	6a 00                	push   $0x0
  800299:	ff 75 0c             	pushl  0xc(%ebp)
  80029c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029f:	ba 01 00 00 00       	mov    $0x1,%edx
  8002a4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002a9:	e8 00 fe ff ff       	call   8000ae <syscall>
}
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b0:	f3 0f 1e fb          	endbr32 
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002ba:	6a 00                	push   $0x0
  8002bc:	ff 75 14             	pushl  0x14(%ebp)
  8002bf:	ff 75 10             	pushl  0x10(%ebp)
  8002c2:	ff 75 0c             	pushl  0xc(%ebp)
  8002c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d2:	e8 d7 fd ff ff       	call   8000ae <syscall>
}
  8002d7:	c9                   	leave  
  8002d8:	c3                   	ret    

008002d9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d9:	f3 0f 1e fb          	endbr32 
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002e3:	6a 00                	push   $0x0
  8002e5:	6a 00                	push   $0x0
  8002e7:	6a 00                	push   $0x0
  8002e9:	6a 00                	push   $0x0
  8002eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ee:	ba 01 00 00 00       	mov    $0x1,%edx
  8002f3:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002f8:	e8 b1 fd ff ff       	call   8000ae <syscall>
}
  8002fd:	c9                   	leave  
  8002fe:	c3                   	ret    

008002ff <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002ff:	f3 0f 1e fb          	endbr32 
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800306:	8b 45 08             	mov    0x8(%ebp),%eax
  800309:	05 00 00 00 30       	add    $0x30000000,%eax
  80030e:	c1 e8 0c             	shr    $0xc,%eax
}
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800313:	f3 0f 1e fb          	endbr32 
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  80031d:	ff 75 08             	pushl  0x8(%ebp)
  800320:	e8 da ff ff ff       	call   8002ff <fd2num>
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	c1 e0 0c             	shl    $0xc,%eax
  80032b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800332:	f3 0f 1e fb          	endbr32 
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80033e:	89 c2                	mov    %eax,%edx
  800340:	c1 ea 16             	shr    $0x16,%edx
  800343:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80034a:	f6 c2 01             	test   $0x1,%dl
  80034d:	74 2d                	je     80037c <fd_alloc+0x4a>
  80034f:	89 c2                	mov    %eax,%edx
  800351:	c1 ea 0c             	shr    $0xc,%edx
  800354:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80035b:	f6 c2 01             	test   $0x1,%dl
  80035e:	74 1c                	je     80037c <fd_alloc+0x4a>
  800360:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800365:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80036a:	75 d2                	jne    80033e <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80036c:	8b 45 08             	mov    0x8(%ebp),%eax
  80036f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800375:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80037a:	eb 0a                	jmp    800386 <fd_alloc+0x54>
			*fd_store = fd;
  80037c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800381:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800386:	5d                   	pop    %ebp
  800387:	c3                   	ret    

00800388 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800388:	f3 0f 1e fb          	endbr32 
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800392:	83 f8 1f             	cmp    $0x1f,%eax
  800395:	77 30                	ja     8003c7 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800397:	c1 e0 0c             	shl    $0xc,%eax
  80039a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80039f:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003a5:	f6 c2 01             	test   $0x1,%dl
  8003a8:	74 24                	je     8003ce <fd_lookup+0x46>
  8003aa:	89 c2                	mov    %eax,%edx
  8003ac:	c1 ea 0c             	shr    $0xc,%edx
  8003af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b6:	f6 c2 01             	test   $0x1,%dl
  8003b9:	74 1a                	je     8003d5 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003be:	89 02                	mov    %eax,(%edx)
	return 0;
  8003c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003c5:	5d                   	pop    %ebp
  8003c6:	c3                   	ret    
		return -E_INVAL;
  8003c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003cc:	eb f7                	jmp    8003c5 <fd_lookup+0x3d>
		return -E_INVAL;
  8003ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d3:	eb f0                	jmp    8003c5 <fd_lookup+0x3d>
  8003d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003da:	eb e9                	jmp    8003c5 <fd_lookup+0x3d>

008003dc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003dc:	f3 0f 1e fb          	endbr32 
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	83 ec 08             	sub    $0x8,%esp
  8003e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e9:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8003ee:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003f3:	39 08                	cmp    %ecx,(%eax)
  8003f5:	74 33                	je     80042a <dev_lookup+0x4e>
  8003f7:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8003fa:	8b 02                	mov    (%edx),%eax
  8003fc:	85 c0                	test   %eax,%eax
  8003fe:	75 f3                	jne    8003f3 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800400:	a1 04 40 80 00       	mov    0x804004,%eax
  800405:	8b 40 48             	mov    0x48(%eax),%eax
  800408:	83 ec 04             	sub    $0x4,%esp
  80040b:	51                   	push   %ecx
  80040c:	50                   	push   %eax
  80040d:	68 18 1e 80 00       	push   $0x801e18
  800412:	e8 3d 0d 00 00       	call   801154 <cprintf>
	*dev = 0;
  800417:	8b 45 0c             	mov    0xc(%ebp),%eax
  80041a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800420:	83 c4 10             	add    $0x10,%esp
  800423:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    
			*dev = devtab[i];
  80042a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042f:	b8 00 00 00 00       	mov    $0x0,%eax
  800434:	eb f2                	jmp    800428 <dev_lookup+0x4c>

00800436 <fd_close>:
{
  800436:	f3 0f 1e fb          	endbr32 
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
  80043d:	57                   	push   %edi
  80043e:	56                   	push   %esi
  80043f:	53                   	push   %ebx
  800440:	83 ec 28             	sub    $0x28,%esp
  800443:	8b 75 08             	mov    0x8(%ebp),%esi
  800446:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800449:	56                   	push   %esi
  80044a:	e8 b0 fe ff ff       	call   8002ff <fd2num>
  80044f:	83 c4 08             	add    $0x8,%esp
  800452:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800455:	52                   	push   %edx
  800456:	50                   	push   %eax
  800457:	e8 2c ff ff ff       	call   800388 <fd_lookup>
  80045c:	89 c3                	mov    %eax,%ebx
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	85 c0                	test   %eax,%eax
  800463:	78 05                	js     80046a <fd_close+0x34>
	    || fd != fd2)
  800465:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800468:	74 16                	je     800480 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80046a:	89 f8                	mov    %edi,%eax
  80046c:	84 c0                	test   %al,%al
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
  800473:	0f 44 d8             	cmove  %eax,%ebx
}
  800476:	89 d8                	mov    %ebx,%eax
  800478:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80047b:	5b                   	pop    %ebx
  80047c:	5e                   	pop    %esi
  80047d:	5f                   	pop    %edi
  80047e:	5d                   	pop    %ebp
  80047f:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800486:	50                   	push   %eax
  800487:	ff 36                	pushl  (%esi)
  800489:	e8 4e ff ff ff       	call   8003dc <dev_lookup>
  80048e:	89 c3                	mov    %eax,%ebx
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	85 c0                	test   %eax,%eax
  800495:	78 1a                	js     8004b1 <fd_close+0x7b>
		if (dev->dev_close)
  800497:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80049a:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80049d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004a2:	85 c0                	test   %eax,%eax
  8004a4:	74 0b                	je     8004b1 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004a6:	83 ec 0c             	sub    $0xc,%esp
  8004a9:	56                   	push   %esi
  8004aa:	ff d0                	call   *%eax
  8004ac:	89 c3                	mov    %eax,%ebx
  8004ae:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	6a 00                	push   $0x0
  8004b7:	e8 58 fd ff ff       	call   800214 <sys_page_unmap>
	return r;
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	eb b5                	jmp    800476 <fd_close+0x40>

008004c1 <close>:

int
close(int fdnum)
{
  8004c1:	f3 0f 1e fb          	endbr32 
  8004c5:	55                   	push   %ebp
  8004c6:	89 e5                	mov    %esp,%ebp
  8004c8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ce:	50                   	push   %eax
  8004cf:	ff 75 08             	pushl  0x8(%ebp)
  8004d2:	e8 b1 fe ff ff       	call   800388 <fd_lookup>
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	85 c0                	test   %eax,%eax
  8004dc:	79 02                	jns    8004e0 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004de:	c9                   	leave  
  8004df:	c3                   	ret    
		return fd_close(fd, 1);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	6a 01                	push   $0x1
  8004e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8004e8:	e8 49 ff ff ff       	call   800436 <fd_close>
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	eb ec                	jmp    8004de <close+0x1d>

008004f2 <close_all>:

void
close_all(void)
{
  8004f2:	f3 0f 1e fb          	endbr32 
  8004f6:	55                   	push   %ebp
  8004f7:	89 e5                	mov    %esp,%ebp
  8004f9:	53                   	push   %ebx
  8004fa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8004fd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800502:	83 ec 0c             	sub    $0xc,%esp
  800505:	53                   	push   %ebx
  800506:	e8 b6 ff ff ff       	call   8004c1 <close>
	for (i = 0; i < MAXFD; i++)
  80050b:	83 c3 01             	add    $0x1,%ebx
  80050e:	83 c4 10             	add    $0x10,%esp
  800511:	83 fb 20             	cmp    $0x20,%ebx
  800514:	75 ec                	jne    800502 <close_all+0x10>
}
  800516:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800519:	c9                   	leave  
  80051a:	c3                   	ret    

0080051b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80051b:	f3 0f 1e fb          	endbr32 
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	57                   	push   %edi
  800523:	56                   	push   %esi
  800524:	53                   	push   %ebx
  800525:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800528:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80052b:	50                   	push   %eax
  80052c:	ff 75 08             	pushl  0x8(%ebp)
  80052f:	e8 54 fe ff ff       	call   800388 <fd_lookup>
  800534:	89 c3                	mov    %eax,%ebx
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	85 c0                	test   %eax,%eax
  80053b:	0f 88 81 00 00 00    	js     8005c2 <dup+0xa7>
		return r;
	close(newfdnum);
  800541:	83 ec 0c             	sub    $0xc,%esp
  800544:	ff 75 0c             	pushl  0xc(%ebp)
  800547:	e8 75 ff ff ff       	call   8004c1 <close>

	newfd = INDEX2FD(newfdnum);
  80054c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80054f:	c1 e6 0c             	shl    $0xc,%esi
  800552:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800558:	83 c4 04             	add    $0x4,%esp
  80055b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80055e:	e8 b0 fd ff ff       	call   800313 <fd2data>
  800563:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800565:	89 34 24             	mov    %esi,(%esp)
  800568:	e8 a6 fd ff ff       	call   800313 <fd2data>
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800572:	89 d8                	mov    %ebx,%eax
  800574:	c1 e8 16             	shr    $0x16,%eax
  800577:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80057e:	a8 01                	test   $0x1,%al
  800580:	74 11                	je     800593 <dup+0x78>
  800582:	89 d8                	mov    %ebx,%eax
  800584:	c1 e8 0c             	shr    $0xc,%eax
  800587:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80058e:	f6 c2 01             	test   $0x1,%dl
  800591:	75 39                	jne    8005cc <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800593:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800596:	89 d0                	mov    %edx,%eax
  800598:	c1 e8 0c             	shr    $0xc,%eax
  80059b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005a2:	83 ec 0c             	sub    $0xc,%esp
  8005a5:	25 07 0e 00 00       	and    $0xe07,%eax
  8005aa:	50                   	push   %eax
  8005ab:	56                   	push   %esi
  8005ac:	6a 00                	push   $0x0
  8005ae:	52                   	push   %edx
  8005af:	6a 00                	push   $0x0
  8005b1:	e8 34 fc ff ff       	call   8001ea <sys_page_map>
  8005b6:	89 c3                	mov    %eax,%ebx
  8005b8:	83 c4 20             	add    $0x20,%esp
  8005bb:	85 c0                	test   %eax,%eax
  8005bd:	78 31                	js     8005f0 <dup+0xd5>
		goto err;

	return newfdnum;
  8005bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005c2:	89 d8                	mov    %ebx,%eax
  8005c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005c7:	5b                   	pop    %ebx
  8005c8:	5e                   	pop    %esi
  8005c9:	5f                   	pop    %edi
  8005ca:	5d                   	pop    %ebp
  8005cb:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d3:	83 ec 0c             	sub    $0xc,%esp
  8005d6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005db:	50                   	push   %eax
  8005dc:	57                   	push   %edi
  8005dd:	6a 00                	push   $0x0
  8005df:	53                   	push   %ebx
  8005e0:	6a 00                	push   $0x0
  8005e2:	e8 03 fc ff ff       	call   8001ea <sys_page_map>
  8005e7:	89 c3                	mov    %eax,%ebx
  8005e9:	83 c4 20             	add    $0x20,%esp
  8005ec:	85 c0                	test   %eax,%eax
  8005ee:	79 a3                	jns    800593 <dup+0x78>
	sys_page_unmap(0, newfd);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	56                   	push   %esi
  8005f4:	6a 00                	push   $0x0
  8005f6:	e8 19 fc ff ff       	call   800214 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005fb:	83 c4 08             	add    $0x8,%esp
  8005fe:	57                   	push   %edi
  8005ff:	6a 00                	push   $0x0
  800601:	e8 0e fc ff ff       	call   800214 <sys_page_unmap>
	return r;
  800606:	83 c4 10             	add    $0x10,%esp
  800609:	eb b7                	jmp    8005c2 <dup+0xa7>

0080060b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80060b:	f3 0f 1e fb          	endbr32 
  80060f:	55                   	push   %ebp
  800610:	89 e5                	mov    %esp,%ebp
  800612:	53                   	push   %ebx
  800613:	83 ec 1c             	sub    $0x1c,%esp
  800616:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800619:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80061c:	50                   	push   %eax
  80061d:	53                   	push   %ebx
  80061e:	e8 65 fd ff ff       	call   800388 <fd_lookup>
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	85 c0                	test   %eax,%eax
  800628:	78 3f                	js     800669 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800630:	50                   	push   %eax
  800631:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800634:	ff 30                	pushl  (%eax)
  800636:	e8 a1 fd ff ff       	call   8003dc <dev_lookup>
  80063b:	83 c4 10             	add    $0x10,%esp
  80063e:	85 c0                	test   %eax,%eax
  800640:	78 27                	js     800669 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800642:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800645:	8b 42 08             	mov    0x8(%edx),%eax
  800648:	83 e0 03             	and    $0x3,%eax
  80064b:	83 f8 01             	cmp    $0x1,%eax
  80064e:	74 1e                	je     80066e <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800650:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800653:	8b 40 08             	mov    0x8(%eax),%eax
  800656:	85 c0                	test   %eax,%eax
  800658:	74 35                	je     80068f <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80065a:	83 ec 04             	sub    $0x4,%esp
  80065d:	ff 75 10             	pushl  0x10(%ebp)
  800660:	ff 75 0c             	pushl  0xc(%ebp)
  800663:	52                   	push   %edx
  800664:	ff d0                	call   *%eax
  800666:	83 c4 10             	add    $0x10,%esp
}
  800669:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80066c:	c9                   	leave  
  80066d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066e:	a1 04 40 80 00       	mov    0x804004,%eax
  800673:	8b 40 48             	mov    0x48(%eax),%eax
  800676:	83 ec 04             	sub    $0x4,%esp
  800679:	53                   	push   %ebx
  80067a:	50                   	push   %eax
  80067b:	68 59 1e 80 00       	push   $0x801e59
  800680:	e8 cf 0a 00 00       	call   801154 <cprintf>
		return -E_INVAL;
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80068d:	eb da                	jmp    800669 <read+0x5e>
		return -E_NOT_SUPP;
  80068f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800694:	eb d3                	jmp    800669 <read+0x5e>

00800696 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800696:	f3 0f 1e fb          	endbr32 
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	57                   	push   %edi
  80069e:	56                   	push   %esi
  80069f:	53                   	push   %ebx
  8006a0:	83 ec 0c             	sub    $0xc,%esp
  8006a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006a6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ae:	eb 02                	jmp    8006b2 <readn+0x1c>
  8006b0:	01 c3                	add    %eax,%ebx
  8006b2:	39 f3                	cmp    %esi,%ebx
  8006b4:	73 21                	jae    8006d7 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006b6:	83 ec 04             	sub    $0x4,%esp
  8006b9:	89 f0                	mov    %esi,%eax
  8006bb:	29 d8                	sub    %ebx,%eax
  8006bd:	50                   	push   %eax
  8006be:	89 d8                	mov    %ebx,%eax
  8006c0:	03 45 0c             	add    0xc(%ebp),%eax
  8006c3:	50                   	push   %eax
  8006c4:	57                   	push   %edi
  8006c5:	e8 41 ff ff ff       	call   80060b <read>
		if (m < 0)
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	85 c0                	test   %eax,%eax
  8006cf:	78 04                	js     8006d5 <readn+0x3f>
			return m;
		if (m == 0)
  8006d1:	75 dd                	jne    8006b0 <readn+0x1a>
  8006d3:	eb 02                	jmp    8006d7 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d5:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006d7:	89 d8                	mov    %ebx,%eax
  8006d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006dc:	5b                   	pop    %ebx
  8006dd:	5e                   	pop    %esi
  8006de:	5f                   	pop    %edi
  8006df:	5d                   	pop    %ebp
  8006e0:	c3                   	ret    

008006e1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006e1:	f3 0f 1e fb          	endbr32 
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	53                   	push   %ebx
  8006e9:	83 ec 1c             	sub    $0x1c,%esp
  8006ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006f2:	50                   	push   %eax
  8006f3:	53                   	push   %ebx
  8006f4:	e8 8f fc ff ff       	call   800388 <fd_lookup>
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	78 3a                	js     80073a <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800706:	50                   	push   %eax
  800707:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80070a:	ff 30                	pushl  (%eax)
  80070c:	e8 cb fc ff ff       	call   8003dc <dev_lookup>
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	85 c0                	test   %eax,%eax
  800716:	78 22                	js     80073a <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800718:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80071b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80071f:	74 1e                	je     80073f <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800721:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800724:	8b 52 0c             	mov    0xc(%edx),%edx
  800727:	85 d2                	test   %edx,%edx
  800729:	74 35                	je     800760 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80072b:	83 ec 04             	sub    $0x4,%esp
  80072e:	ff 75 10             	pushl  0x10(%ebp)
  800731:	ff 75 0c             	pushl  0xc(%ebp)
  800734:	50                   	push   %eax
  800735:	ff d2                	call   *%edx
  800737:	83 c4 10             	add    $0x10,%esp
}
  80073a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80073d:	c9                   	leave  
  80073e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073f:	a1 04 40 80 00       	mov    0x804004,%eax
  800744:	8b 40 48             	mov    0x48(%eax),%eax
  800747:	83 ec 04             	sub    $0x4,%esp
  80074a:	53                   	push   %ebx
  80074b:	50                   	push   %eax
  80074c:	68 75 1e 80 00       	push   $0x801e75
  800751:	e8 fe 09 00 00       	call   801154 <cprintf>
		return -E_INVAL;
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075e:	eb da                	jmp    80073a <write+0x59>
		return -E_NOT_SUPP;
  800760:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800765:	eb d3                	jmp    80073a <write+0x59>

00800767 <seek>:

int
seek(int fdnum, off_t offset)
{
  800767:	f3 0f 1e fb          	endbr32 
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800771:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800774:	50                   	push   %eax
  800775:	ff 75 08             	pushl  0x8(%ebp)
  800778:	e8 0b fc ff ff       	call   800388 <fd_lookup>
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	85 c0                	test   %eax,%eax
  800782:	78 0e                	js     800792 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800784:	8b 55 0c             	mov    0xc(%ebp),%edx
  800787:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80078d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800792:	c9                   	leave  
  800793:	c3                   	ret    

00800794 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800794:	f3 0f 1e fb          	endbr32 
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	53                   	push   %ebx
  80079c:	83 ec 1c             	sub    $0x1c,%esp
  80079f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007a5:	50                   	push   %eax
  8007a6:	53                   	push   %ebx
  8007a7:	e8 dc fb ff ff       	call   800388 <fd_lookup>
  8007ac:	83 c4 10             	add    $0x10,%esp
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	78 37                	js     8007ea <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b3:	83 ec 08             	sub    $0x8,%esp
  8007b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007b9:	50                   	push   %eax
  8007ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007bd:	ff 30                	pushl  (%eax)
  8007bf:	e8 18 fc ff ff       	call   8003dc <dev_lookup>
  8007c4:	83 c4 10             	add    $0x10,%esp
  8007c7:	85 c0                	test   %eax,%eax
  8007c9:	78 1f                	js     8007ea <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ce:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007d2:	74 1b                	je     8007ef <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007d7:	8b 52 18             	mov    0x18(%edx),%edx
  8007da:	85 d2                	test   %edx,%edx
  8007dc:	74 32                	je     800810 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	ff 75 0c             	pushl  0xc(%ebp)
  8007e4:	50                   	push   %eax
  8007e5:	ff d2                	call   *%edx
  8007e7:	83 c4 10             	add    $0x10,%esp
}
  8007ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ed:	c9                   	leave  
  8007ee:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007ef:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f4:	8b 40 48             	mov    0x48(%eax),%eax
  8007f7:	83 ec 04             	sub    $0x4,%esp
  8007fa:	53                   	push   %ebx
  8007fb:	50                   	push   %eax
  8007fc:	68 38 1e 80 00       	push   $0x801e38
  800801:	e8 4e 09 00 00       	call   801154 <cprintf>
		return -E_INVAL;
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80080e:	eb da                	jmp    8007ea <ftruncate+0x56>
		return -E_NOT_SUPP;
  800810:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800815:	eb d3                	jmp    8007ea <ftruncate+0x56>

00800817 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800817:	f3 0f 1e fb          	endbr32 
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	83 ec 1c             	sub    $0x1c,%esp
  800822:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800825:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800828:	50                   	push   %eax
  800829:	ff 75 08             	pushl  0x8(%ebp)
  80082c:	e8 57 fb ff ff       	call   800388 <fd_lookup>
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	85 c0                	test   %eax,%eax
  800836:	78 4b                	js     800883 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800838:	83 ec 08             	sub    $0x8,%esp
  80083b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083e:	50                   	push   %eax
  80083f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800842:	ff 30                	pushl  (%eax)
  800844:	e8 93 fb ff ff       	call   8003dc <dev_lookup>
  800849:	83 c4 10             	add    $0x10,%esp
  80084c:	85 c0                	test   %eax,%eax
  80084e:	78 33                	js     800883 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800850:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800853:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800857:	74 2f                	je     800888 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800859:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80085c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800863:	00 00 00 
	stat->st_isdir = 0;
  800866:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80086d:	00 00 00 
	stat->st_dev = dev;
  800870:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800876:	83 ec 08             	sub    $0x8,%esp
  800879:	53                   	push   %ebx
  80087a:	ff 75 f0             	pushl  -0x10(%ebp)
  80087d:	ff 50 14             	call   *0x14(%eax)
  800880:	83 c4 10             	add    $0x10,%esp
}
  800883:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800886:	c9                   	leave  
  800887:	c3                   	ret    
		return -E_NOT_SUPP;
  800888:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80088d:	eb f4                	jmp    800883 <fstat+0x6c>

0080088f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80088f:	f3 0f 1e fb          	endbr32 
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	6a 00                	push   $0x0
  80089d:	ff 75 08             	pushl  0x8(%ebp)
  8008a0:	e8 20 02 00 00       	call   800ac5 <open>
  8008a5:	89 c3                	mov    %eax,%ebx
  8008a7:	83 c4 10             	add    $0x10,%esp
  8008aa:	85 c0                	test   %eax,%eax
  8008ac:	78 1b                	js     8008c9 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	ff 75 0c             	pushl  0xc(%ebp)
  8008b4:	50                   	push   %eax
  8008b5:	e8 5d ff ff ff       	call   800817 <fstat>
  8008ba:	89 c6                	mov    %eax,%esi
	close(fd);
  8008bc:	89 1c 24             	mov    %ebx,(%esp)
  8008bf:	e8 fd fb ff ff       	call   8004c1 <close>
	return r;
  8008c4:	83 c4 10             	add    $0x10,%esp
  8008c7:	89 f3                	mov    %esi,%ebx
}
  8008c9:	89 d8                	mov    %ebx,%eax
  8008cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ce:	5b                   	pop    %ebx
  8008cf:	5e                   	pop    %esi
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	89 c6                	mov    %eax,%esi
  8008d9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008db:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008e2:	74 27                	je     80090b <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008e4:	6a 07                	push   $0x7
  8008e6:	68 00 50 80 00       	push   $0x805000
  8008eb:	56                   	push   %esi
  8008ec:	ff 35 00 40 80 00    	pushl  0x804000
  8008f2:	e8 a8 11 00 00       	call   801a9f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008f7:	83 c4 0c             	add    $0xc,%esp
  8008fa:	6a 00                	push   $0x0
  8008fc:	53                   	push   %ebx
  8008fd:	6a 00                	push   $0x0
  8008ff:	e8 2e 11 00 00       	call   801a32 <ipc_recv>
}
  800904:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800907:	5b                   	pop    %ebx
  800908:	5e                   	pop    %esi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80090b:	83 ec 0c             	sub    $0xc,%esp
  80090e:	6a 01                	push   $0x1
  800910:	e8 dd 11 00 00       	call   801af2 <ipc_find_env>
  800915:	a3 00 40 80 00       	mov    %eax,0x804000
  80091a:	83 c4 10             	add    $0x10,%esp
  80091d:	eb c5                	jmp    8008e4 <fsipc+0x12>

0080091f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80091f:	f3 0f 1e fb          	endbr32 
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8b 40 0c             	mov    0xc(%eax),%eax
  80092f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800934:	8b 45 0c             	mov    0xc(%ebp),%eax
  800937:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80093c:	ba 00 00 00 00       	mov    $0x0,%edx
  800941:	b8 02 00 00 00       	mov    $0x2,%eax
  800946:	e8 87 ff ff ff       	call   8008d2 <fsipc>
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <devfile_flush>:
{
  80094d:	f3 0f 1e fb          	endbr32 
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 40 0c             	mov    0xc(%eax),%eax
  80095d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800962:	ba 00 00 00 00       	mov    $0x0,%edx
  800967:	b8 06 00 00 00       	mov    $0x6,%eax
  80096c:	e8 61 ff ff ff       	call   8008d2 <fsipc>
}
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <devfile_stat>:
{
  800973:	f3 0f 1e fb          	endbr32 
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	53                   	push   %ebx
  80097b:	83 ec 04             	sub    $0x4,%esp
  80097e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 05 00 00 00       	mov    $0x5,%eax
  800996:	e8 37 ff ff ff       	call   8008d2 <fsipc>
  80099b:	85 c0                	test   %eax,%eax
  80099d:	78 2c                	js     8009cb <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80099f:	83 ec 08             	sub    $0x8,%esp
  8009a2:	68 00 50 80 00       	push   $0x805000
  8009a7:	53                   	push   %ebx
  8009a8:	e8 11 0d 00 00       	call   8016be <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ad:	a1 80 50 80 00       	mov    0x805080,%eax
  8009b2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b8:	a1 84 50 80 00       	mov    0x805084,%eax
  8009bd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009c3:	83 c4 10             	add    $0x10,%esp
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ce:	c9                   	leave  
  8009cf:	c3                   	ret    

008009d0 <devfile_write>:
{
  8009d0:	f3 0f 1e fb          	endbr32 
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	57                   	push   %edi
  8009d8:	56                   	push   %esi
  8009d9:	53                   	push   %ebx
  8009da:	83 ec 0c             	sub    $0xc,%esp
  8009dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e9:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8009f3:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  8009f8:	85 db                	test   %ebx,%ebx
  8009fa:	74 3b                	je     800a37 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8009fc:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800a02:	89 f8                	mov    %edi,%eax
  800a04:	0f 46 c3             	cmovbe %ebx,%eax
  800a07:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  800a0c:	83 ec 04             	sub    $0x4,%esp
  800a0f:	50                   	push   %eax
  800a10:	56                   	push   %esi
  800a11:	68 08 50 80 00       	push   $0x805008
  800a16:	e8 5b 0e 00 00       	call   801876 <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a20:	b8 04 00 00 00       	mov    $0x4,%eax
  800a25:	e8 a8 fe ff ff       	call   8008d2 <fsipc>
  800a2a:	83 c4 10             	add    $0x10,%esp
  800a2d:	85 c0                	test   %eax,%eax
  800a2f:	78 06                	js     800a37 <devfile_write+0x67>
		buf_aux += r;
  800a31:	01 c6                	add    %eax,%esi
		n -= r;
  800a33:	29 c3                	sub    %eax,%ebx
  800a35:	eb c1                	jmp    8009f8 <devfile_write+0x28>
}
  800a37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <devfile_read>:
{
  800a3f:	f3 0f 1e fb          	endbr32 
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
  800a48:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a51:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a56:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a61:	b8 03 00 00 00       	mov    $0x3,%eax
  800a66:	e8 67 fe ff ff       	call   8008d2 <fsipc>
  800a6b:	89 c3                	mov    %eax,%ebx
  800a6d:	85 c0                	test   %eax,%eax
  800a6f:	78 1f                	js     800a90 <devfile_read+0x51>
	assert(r <= n);
  800a71:	39 f0                	cmp    %esi,%eax
  800a73:	77 24                	ja     800a99 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a75:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a7a:	7f 33                	jg     800aaf <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a7c:	83 ec 04             	sub    $0x4,%esp
  800a7f:	50                   	push   %eax
  800a80:	68 00 50 80 00       	push   $0x805000
  800a85:	ff 75 0c             	pushl  0xc(%ebp)
  800a88:	e8 e9 0d 00 00       	call   801876 <memmove>
	return r;
  800a8d:	83 c4 10             	add    $0x10,%esp
}
  800a90:	89 d8                	mov    %ebx,%eax
  800a92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    
	assert(r <= n);
  800a99:	68 a4 1e 80 00       	push   $0x801ea4
  800a9e:	68 ab 1e 80 00       	push   $0x801eab
  800aa3:	6a 7c                	push   $0x7c
  800aa5:	68 c0 1e 80 00       	push   $0x801ec0
  800aaa:	e8 be 05 00 00       	call   80106d <_panic>
	assert(r <= PGSIZE);
  800aaf:	68 cb 1e 80 00       	push   $0x801ecb
  800ab4:	68 ab 1e 80 00       	push   $0x801eab
  800ab9:	6a 7d                	push   $0x7d
  800abb:	68 c0 1e 80 00       	push   $0x801ec0
  800ac0:	e8 a8 05 00 00       	call   80106d <_panic>

00800ac5 <open>:
{
  800ac5:	f3 0f 1e fb          	endbr32 
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	56                   	push   %esi
  800acd:	53                   	push   %ebx
  800ace:	83 ec 1c             	sub    $0x1c,%esp
  800ad1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ad4:	56                   	push   %esi
  800ad5:	e8 a1 0b 00 00       	call   80167b <strlen>
  800ada:	83 c4 10             	add    $0x10,%esp
  800add:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ae2:	7f 6c                	jg     800b50 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800ae4:	83 ec 0c             	sub    $0xc,%esp
  800ae7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aea:	50                   	push   %eax
  800aeb:	e8 42 f8 ff ff       	call   800332 <fd_alloc>
  800af0:	89 c3                	mov    %eax,%ebx
  800af2:	83 c4 10             	add    $0x10,%esp
  800af5:	85 c0                	test   %eax,%eax
  800af7:	78 3c                	js     800b35 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800af9:	83 ec 08             	sub    $0x8,%esp
  800afc:	56                   	push   %esi
  800afd:	68 00 50 80 00       	push   $0x805000
  800b02:	e8 b7 0b 00 00       	call   8016be <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0a:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b12:	b8 01 00 00 00       	mov    $0x1,%eax
  800b17:	e8 b6 fd ff ff       	call   8008d2 <fsipc>
  800b1c:	89 c3                	mov    %eax,%ebx
  800b1e:	83 c4 10             	add    $0x10,%esp
  800b21:	85 c0                	test   %eax,%eax
  800b23:	78 19                	js     800b3e <open+0x79>
	return fd2num(fd);
  800b25:	83 ec 0c             	sub    $0xc,%esp
  800b28:	ff 75 f4             	pushl  -0xc(%ebp)
  800b2b:	e8 cf f7 ff ff       	call   8002ff <fd2num>
  800b30:	89 c3                	mov    %eax,%ebx
  800b32:	83 c4 10             	add    $0x10,%esp
}
  800b35:	89 d8                	mov    %ebx,%eax
  800b37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    
		fd_close(fd, 0);
  800b3e:	83 ec 08             	sub    $0x8,%esp
  800b41:	6a 00                	push   $0x0
  800b43:	ff 75 f4             	pushl  -0xc(%ebp)
  800b46:	e8 eb f8 ff ff       	call   800436 <fd_close>
		return r;
  800b4b:	83 c4 10             	add    $0x10,%esp
  800b4e:	eb e5                	jmp    800b35 <open+0x70>
		return -E_BAD_PATH;
  800b50:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b55:	eb de                	jmp    800b35 <open+0x70>

00800b57 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b57:	f3 0f 1e fb          	endbr32 
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b61:	ba 00 00 00 00       	mov    $0x0,%edx
  800b66:	b8 08 00 00 00       	mov    $0x8,%eax
  800b6b:	e8 62 fd ff ff       	call   8008d2 <fsipc>
}
  800b70:	c9                   	leave  
  800b71:	c3                   	ret    

00800b72 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b72:	f3 0f 1e fb          	endbr32 
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	ff 75 08             	pushl  0x8(%ebp)
  800b84:	e8 8a f7 ff ff       	call   800313 <fd2data>
  800b89:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b8b:	83 c4 08             	add    $0x8,%esp
  800b8e:	68 d7 1e 80 00       	push   $0x801ed7
  800b93:	53                   	push   %ebx
  800b94:	e8 25 0b 00 00       	call   8016be <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b99:	8b 46 04             	mov    0x4(%esi),%eax
  800b9c:	2b 06                	sub    (%esi),%eax
  800b9e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ba4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bab:	00 00 00 
	stat->st_dev = &devpipe;
  800bae:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bb5:	30 80 00 
	return 0;
}
  800bb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bc4:	f3 0f 1e fb          	endbr32 
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bd2:	53                   	push   %ebx
  800bd3:	6a 00                	push   $0x0
  800bd5:	e8 3a f6 ff ff       	call   800214 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bda:	89 1c 24             	mov    %ebx,(%esp)
  800bdd:	e8 31 f7 ff ff       	call   800313 <fd2data>
  800be2:	83 c4 08             	add    $0x8,%esp
  800be5:	50                   	push   %eax
  800be6:	6a 00                	push   $0x0
  800be8:	e8 27 f6 ff ff       	call   800214 <sys_page_unmap>
}
  800bed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf0:	c9                   	leave  
  800bf1:	c3                   	ret    

00800bf2 <_pipeisclosed>:
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 1c             	sub    $0x1c,%esp
  800bfb:	89 c7                	mov    %eax,%edi
  800bfd:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bff:	a1 04 40 80 00       	mov    0x804004,%eax
  800c04:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	57                   	push   %edi
  800c0b:	e8 1f 0f 00 00       	call   801b2f <pageref>
  800c10:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c13:	89 34 24             	mov    %esi,(%esp)
  800c16:	e8 14 0f 00 00       	call   801b2f <pageref>
		nn = thisenv->env_runs;
  800c1b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c21:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c24:	83 c4 10             	add    $0x10,%esp
  800c27:	39 cb                	cmp    %ecx,%ebx
  800c29:	74 1b                	je     800c46 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c2b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c2e:	75 cf                	jne    800bff <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c30:	8b 42 58             	mov    0x58(%edx),%eax
  800c33:	6a 01                	push   $0x1
  800c35:	50                   	push   %eax
  800c36:	53                   	push   %ebx
  800c37:	68 de 1e 80 00       	push   $0x801ede
  800c3c:	e8 13 05 00 00       	call   801154 <cprintf>
  800c41:	83 c4 10             	add    $0x10,%esp
  800c44:	eb b9                	jmp    800bff <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c46:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c49:	0f 94 c0             	sete   %al
  800c4c:	0f b6 c0             	movzbl %al,%eax
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <devpipe_write>:
{
  800c57:	f3 0f 1e fb          	endbr32 
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 28             	sub    $0x28,%esp
  800c64:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c67:	56                   	push   %esi
  800c68:	e8 a6 f6 ff ff       	call   800313 <fd2data>
  800c6d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c6f:	83 c4 10             	add    $0x10,%esp
  800c72:	bf 00 00 00 00       	mov    $0x0,%edi
  800c77:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c7a:	74 4f                	je     800ccb <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c7c:	8b 43 04             	mov    0x4(%ebx),%eax
  800c7f:	8b 0b                	mov    (%ebx),%ecx
  800c81:	8d 51 20             	lea    0x20(%ecx),%edx
  800c84:	39 d0                	cmp    %edx,%eax
  800c86:	72 14                	jb     800c9c <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800c88:	89 da                	mov    %ebx,%edx
  800c8a:	89 f0                	mov    %esi,%eax
  800c8c:	e8 61 ff ff ff       	call   800bf2 <_pipeisclosed>
  800c91:	85 c0                	test   %eax,%eax
  800c93:	75 3b                	jne    800cd0 <devpipe_write+0x79>
			sys_yield();
  800c95:	e8 fd f4 ff ff       	call   800197 <sys_yield>
  800c9a:	eb e0                	jmp    800c7c <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ca3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca6:	89 c2                	mov    %eax,%edx
  800ca8:	c1 fa 1f             	sar    $0x1f,%edx
  800cab:	89 d1                	mov    %edx,%ecx
  800cad:	c1 e9 1b             	shr    $0x1b,%ecx
  800cb0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cb3:	83 e2 1f             	and    $0x1f,%edx
  800cb6:	29 ca                	sub    %ecx,%edx
  800cb8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cbc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cc0:	83 c0 01             	add    $0x1,%eax
  800cc3:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cc6:	83 c7 01             	add    $0x1,%edi
  800cc9:	eb ac                	jmp    800c77 <devpipe_write+0x20>
	return i;
  800ccb:	8b 45 10             	mov    0x10(%ebp),%eax
  800cce:	eb 05                	jmp    800cd5 <devpipe_write+0x7e>
				return 0;
  800cd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <devpipe_read>:
{
  800cdd:	f3 0f 1e fb          	endbr32 
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 18             	sub    $0x18,%esp
  800cea:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800ced:	57                   	push   %edi
  800cee:	e8 20 f6 ff ff       	call   800313 <fd2data>
  800cf3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cf5:	83 c4 10             	add    $0x10,%esp
  800cf8:	be 00 00 00 00       	mov    $0x0,%esi
  800cfd:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d00:	75 14                	jne    800d16 <devpipe_read+0x39>
	return i;
  800d02:	8b 45 10             	mov    0x10(%ebp),%eax
  800d05:	eb 02                	jmp    800d09 <devpipe_read+0x2c>
				return i;
  800d07:	89 f0                	mov    %esi,%eax
}
  800d09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    
			sys_yield();
  800d11:	e8 81 f4 ff ff       	call   800197 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d16:	8b 03                	mov    (%ebx),%eax
  800d18:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d1b:	75 18                	jne    800d35 <devpipe_read+0x58>
			if (i > 0)
  800d1d:	85 f6                	test   %esi,%esi
  800d1f:	75 e6                	jne    800d07 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d21:	89 da                	mov    %ebx,%edx
  800d23:	89 f8                	mov    %edi,%eax
  800d25:	e8 c8 fe ff ff       	call   800bf2 <_pipeisclosed>
  800d2a:	85 c0                	test   %eax,%eax
  800d2c:	74 e3                	je     800d11 <devpipe_read+0x34>
				return 0;
  800d2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d33:	eb d4                	jmp    800d09 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d35:	99                   	cltd   
  800d36:	c1 ea 1b             	shr    $0x1b,%edx
  800d39:	01 d0                	add    %edx,%eax
  800d3b:	83 e0 1f             	and    $0x1f,%eax
  800d3e:	29 d0                	sub    %edx,%eax
  800d40:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d48:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d4b:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d4e:	83 c6 01             	add    $0x1,%esi
  800d51:	eb aa                	jmp    800cfd <devpipe_read+0x20>

00800d53 <pipe>:
{
  800d53:	f3 0f 1e fb          	endbr32 
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	56                   	push   %esi
  800d5b:	53                   	push   %ebx
  800d5c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d62:	50                   	push   %eax
  800d63:	e8 ca f5 ff ff       	call   800332 <fd_alloc>
  800d68:	89 c3                	mov    %eax,%ebx
  800d6a:	83 c4 10             	add    $0x10,%esp
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	0f 88 23 01 00 00    	js     800e98 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d75:	83 ec 04             	sub    $0x4,%esp
  800d78:	68 07 04 00 00       	push   $0x407
  800d7d:	ff 75 f4             	pushl  -0xc(%ebp)
  800d80:	6a 00                	push   $0x0
  800d82:	e8 3b f4 ff ff       	call   8001c2 <sys_page_alloc>
  800d87:	89 c3                	mov    %eax,%ebx
  800d89:	83 c4 10             	add    $0x10,%esp
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	0f 88 04 01 00 00    	js     800e98 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800d94:	83 ec 0c             	sub    $0xc,%esp
  800d97:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d9a:	50                   	push   %eax
  800d9b:	e8 92 f5 ff ff       	call   800332 <fd_alloc>
  800da0:	89 c3                	mov    %eax,%ebx
  800da2:	83 c4 10             	add    $0x10,%esp
  800da5:	85 c0                	test   %eax,%eax
  800da7:	0f 88 db 00 00 00    	js     800e88 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dad:	83 ec 04             	sub    $0x4,%esp
  800db0:	68 07 04 00 00       	push   $0x407
  800db5:	ff 75 f0             	pushl  -0x10(%ebp)
  800db8:	6a 00                	push   $0x0
  800dba:	e8 03 f4 ff ff       	call   8001c2 <sys_page_alloc>
  800dbf:	89 c3                	mov    %eax,%ebx
  800dc1:	83 c4 10             	add    $0x10,%esp
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	0f 88 bc 00 00 00    	js     800e88 <pipe+0x135>
	va = fd2data(fd0);
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	ff 75 f4             	pushl  -0xc(%ebp)
  800dd2:	e8 3c f5 ff ff       	call   800313 <fd2data>
  800dd7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd9:	83 c4 0c             	add    $0xc,%esp
  800ddc:	68 07 04 00 00       	push   $0x407
  800de1:	50                   	push   %eax
  800de2:	6a 00                	push   $0x0
  800de4:	e8 d9 f3 ff ff       	call   8001c2 <sys_page_alloc>
  800de9:	89 c3                	mov    %eax,%ebx
  800deb:	83 c4 10             	add    $0x10,%esp
  800dee:	85 c0                	test   %eax,%eax
  800df0:	0f 88 82 00 00 00    	js     800e78 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df6:	83 ec 0c             	sub    $0xc,%esp
  800df9:	ff 75 f0             	pushl  -0x10(%ebp)
  800dfc:	e8 12 f5 ff ff       	call   800313 <fd2data>
  800e01:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e08:	50                   	push   %eax
  800e09:	6a 00                	push   $0x0
  800e0b:	56                   	push   %esi
  800e0c:	6a 00                	push   $0x0
  800e0e:	e8 d7 f3 ff ff       	call   8001ea <sys_page_map>
  800e13:	89 c3                	mov    %eax,%ebx
  800e15:	83 c4 20             	add    $0x20,%esp
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	78 4e                	js     800e6a <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e1c:	a1 20 30 80 00       	mov    0x803020,%eax
  800e21:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e24:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e29:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e30:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e33:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e38:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e3f:	83 ec 0c             	sub    $0xc,%esp
  800e42:	ff 75 f4             	pushl  -0xc(%ebp)
  800e45:	e8 b5 f4 ff ff       	call   8002ff <fd2num>
  800e4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e4f:	83 c4 04             	add    $0x4,%esp
  800e52:	ff 75 f0             	pushl  -0x10(%ebp)
  800e55:	e8 a5 f4 ff ff       	call   8002ff <fd2num>
  800e5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e68:	eb 2e                	jmp    800e98 <pipe+0x145>
	sys_page_unmap(0, va);
  800e6a:	83 ec 08             	sub    $0x8,%esp
  800e6d:	56                   	push   %esi
  800e6e:	6a 00                	push   $0x0
  800e70:	e8 9f f3 ff ff       	call   800214 <sys_page_unmap>
  800e75:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e78:	83 ec 08             	sub    $0x8,%esp
  800e7b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e7e:	6a 00                	push   $0x0
  800e80:	e8 8f f3 ff ff       	call   800214 <sys_page_unmap>
  800e85:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e88:	83 ec 08             	sub    $0x8,%esp
  800e8b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8e:	6a 00                	push   $0x0
  800e90:	e8 7f f3 ff ff       	call   800214 <sys_page_unmap>
  800e95:	83 c4 10             	add    $0x10,%esp
}
  800e98:	89 d8                	mov    %ebx,%eax
  800e9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    

00800ea1 <pipeisclosed>:
{
  800ea1:	f3 0f 1e fb          	endbr32 
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eae:	50                   	push   %eax
  800eaf:	ff 75 08             	pushl  0x8(%ebp)
  800eb2:	e8 d1 f4 ff ff       	call   800388 <fd_lookup>
  800eb7:	83 c4 10             	add    $0x10,%esp
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	78 18                	js     800ed6 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800ebe:	83 ec 0c             	sub    $0xc,%esp
  800ec1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec4:	e8 4a f4 ff ff       	call   800313 <fd2data>
  800ec9:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ece:	e8 1f fd ff ff       	call   800bf2 <_pipeisclosed>
  800ed3:	83 c4 10             	add    $0x10,%esp
}
  800ed6:	c9                   	leave  
  800ed7:	c3                   	ret    

00800ed8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ed8:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800edc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee1:	c3                   	ret    

00800ee2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ee2:	f3 0f 1e fb          	endbr32 
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800eec:	68 f6 1e 80 00       	push   $0x801ef6
  800ef1:	ff 75 0c             	pushl  0xc(%ebp)
  800ef4:	e8 c5 07 00 00       	call   8016be <strcpy>
	return 0;
}
  800ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  800efe:	c9                   	leave  
  800eff:	c3                   	ret    

00800f00 <devcons_write>:
{
  800f00:	f3 0f 1e fb          	endbr32 
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	57                   	push   %edi
  800f08:	56                   	push   %esi
  800f09:	53                   	push   %ebx
  800f0a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f10:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f15:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f1b:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f1e:	73 31                	jae    800f51 <devcons_write+0x51>
		m = n - tot;
  800f20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f23:	29 f3                	sub    %esi,%ebx
  800f25:	83 fb 7f             	cmp    $0x7f,%ebx
  800f28:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f2d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f30:	83 ec 04             	sub    $0x4,%esp
  800f33:	53                   	push   %ebx
  800f34:	89 f0                	mov    %esi,%eax
  800f36:	03 45 0c             	add    0xc(%ebp),%eax
  800f39:	50                   	push   %eax
  800f3a:	57                   	push   %edi
  800f3b:	e8 36 09 00 00       	call   801876 <memmove>
		sys_cputs(buf, m);
  800f40:	83 c4 08             	add    $0x8,%esp
  800f43:	53                   	push   %ebx
  800f44:	57                   	push   %edi
  800f45:	e8 ad f1 ff ff       	call   8000f7 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f4a:	01 de                	add    %ebx,%esi
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	eb ca                	jmp    800f1b <devcons_write+0x1b>
}
  800f51:	89 f0                	mov    %esi,%eax
  800f53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f56:	5b                   	pop    %ebx
  800f57:	5e                   	pop    %esi
  800f58:	5f                   	pop    %edi
  800f59:	5d                   	pop    %ebp
  800f5a:	c3                   	ret    

00800f5b <devcons_read>:
{
  800f5b:	f3 0f 1e fb          	endbr32 
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	83 ec 08             	sub    $0x8,%esp
  800f65:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f6e:	74 21                	je     800f91 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800f70:	e8 ac f1 ff ff       	call   800121 <sys_cgetc>
  800f75:	85 c0                	test   %eax,%eax
  800f77:	75 07                	jne    800f80 <devcons_read+0x25>
		sys_yield();
  800f79:	e8 19 f2 ff ff       	call   800197 <sys_yield>
  800f7e:	eb f0                	jmp    800f70 <devcons_read+0x15>
	if (c < 0)
  800f80:	78 0f                	js     800f91 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800f82:	83 f8 04             	cmp    $0x4,%eax
  800f85:	74 0c                	je     800f93 <devcons_read+0x38>
	*(char*)vbuf = c;
  800f87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8a:	88 02                	mov    %al,(%edx)
	return 1;
  800f8c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f91:	c9                   	leave  
  800f92:	c3                   	ret    
		return 0;
  800f93:	b8 00 00 00 00       	mov    $0x0,%eax
  800f98:	eb f7                	jmp    800f91 <devcons_read+0x36>

00800f9a <cputchar>:
{
  800f9a:	f3 0f 1e fb          	endbr32 
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa7:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800faa:	6a 01                	push   $0x1
  800fac:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800faf:	50                   	push   %eax
  800fb0:	e8 42 f1 ff ff       	call   8000f7 <sys_cputs>
}
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    

00800fba <getchar>:
{
  800fba:	f3 0f 1e fb          	endbr32 
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800fc4:	6a 01                	push   $0x1
  800fc6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc9:	50                   	push   %eax
  800fca:	6a 00                	push   $0x0
  800fcc:	e8 3a f6 ff ff       	call   80060b <read>
	if (r < 0)
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	78 06                	js     800fde <getchar+0x24>
	if (r < 1)
  800fd8:	74 06                	je     800fe0 <getchar+0x26>
	return c;
  800fda:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fde:	c9                   	leave  
  800fdf:	c3                   	ret    
		return -E_EOF;
  800fe0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fe5:	eb f7                	jmp    800fde <getchar+0x24>

00800fe7 <iscons>:
{
  800fe7:	f3 0f 1e fb          	endbr32 
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff4:	50                   	push   %eax
  800ff5:	ff 75 08             	pushl  0x8(%ebp)
  800ff8:	e8 8b f3 ff ff       	call   800388 <fd_lookup>
  800ffd:	83 c4 10             	add    $0x10,%esp
  801000:	85 c0                	test   %eax,%eax
  801002:	78 11                	js     801015 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801004:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801007:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80100d:	39 10                	cmp    %edx,(%eax)
  80100f:	0f 94 c0             	sete   %al
  801012:	0f b6 c0             	movzbl %al,%eax
}
  801015:	c9                   	leave  
  801016:	c3                   	ret    

00801017 <opencons>:
{
  801017:	f3 0f 1e fb          	endbr32 
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801021:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801024:	50                   	push   %eax
  801025:	e8 08 f3 ff ff       	call   800332 <fd_alloc>
  80102a:	83 c4 10             	add    $0x10,%esp
  80102d:	85 c0                	test   %eax,%eax
  80102f:	78 3a                	js     80106b <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801031:	83 ec 04             	sub    $0x4,%esp
  801034:	68 07 04 00 00       	push   $0x407
  801039:	ff 75 f4             	pushl  -0xc(%ebp)
  80103c:	6a 00                	push   $0x0
  80103e:	e8 7f f1 ff ff       	call   8001c2 <sys_page_alloc>
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	78 21                	js     80106b <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80104a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801053:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801058:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	50                   	push   %eax
  801063:	e8 97 f2 ff ff       	call   8002ff <fd2num>
  801068:	83 c4 10             	add    $0x10,%esp
}
  80106b:	c9                   	leave  
  80106c:	c3                   	ret    

0080106d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80106d:	f3 0f 1e fb          	endbr32 
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	56                   	push   %esi
  801075:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801076:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801079:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80107f:	e8 eb f0 ff ff       	call   80016f <sys_getenvid>
  801084:	83 ec 0c             	sub    $0xc,%esp
  801087:	ff 75 0c             	pushl  0xc(%ebp)
  80108a:	ff 75 08             	pushl  0x8(%ebp)
  80108d:	56                   	push   %esi
  80108e:	50                   	push   %eax
  80108f:	68 04 1f 80 00       	push   $0x801f04
  801094:	e8 bb 00 00 00       	call   801154 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801099:	83 c4 18             	add    $0x18,%esp
  80109c:	53                   	push   %ebx
  80109d:	ff 75 10             	pushl  0x10(%ebp)
  8010a0:	e8 5a 00 00 00       	call   8010ff <vcprintf>
	cprintf("\n");
  8010a5:	c7 04 24 ef 1e 80 00 	movl   $0x801eef,(%esp)
  8010ac:	e8 a3 00 00 00       	call   801154 <cprintf>
  8010b1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010b4:	cc                   	int3   
  8010b5:	eb fd                	jmp    8010b4 <_panic+0x47>

008010b7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010b7:	f3 0f 1e fb          	endbr32 
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	53                   	push   %ebx
  8010bf:	83 ec 04             	sub    $0x4,%esp
  8010c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010c5:	8b 13                	mov    (%ebx),%edx
  8010c7:	8d 42 01             	lea    0x1(%edx),%eax
  8010ca:	89 03                	mov    %eax,(%ebx)
  8010cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010cf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010d3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010d8:	74 09                	je     8010e3 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010da:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e1:	c9                   	leave  
  8010e2:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010e3:	83 ec 08             	sub    $0x8,%esp
  8010e6:	68 ff 00 00 00       	push   $0xff
  8010eb:	8d 43 08             	lea    0x8(%ebx),%eax
  8010ee:	50                   	push   %eax
  8010ef:	e8 03 f0 ff ff       	call   8000f7 <sys_cputs>
		b->idx = 0;
  8010f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	eb db                	jmp    8010da <putch+0x23>

008010ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010ff:	f3 0f 1e fb          	endbr32 
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80110c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801113:	00 00 00 
	b.cnt = 0;
  801116:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80111d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801120:	ff 75 0c             	pushl  0xc(%ebp)
  801123:	ff 75 08             	pushl  0x8(%ebp)
  801126:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80112c:	50                   	push   %eax
  80112d:	68 b7 10 80 00       	push   $0x8010b7
  801132:	e8 80 01 00 00       	call   8012b7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801137:	83 c4 08             	add    $0x8,%esp
  80113a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801140:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801146:	50                   	push   %eax
  801147:	e8 ab ef ff ff       	call   8000f7 <sys_cputs>

	return b.cnt;
}
  80114c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801152:	c9                   	leave  
  801153:	c3                   	ret    

00801154 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801154:	f3 0f 1e fb          	endbr32 
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80115e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801161:	50                   	push   %eax
  801162:	ff 75 08             	pushl  0x8(%ebp)
  801165:	e8 95 ff ff ff       	call   8010ff <vcprintf>
	va_end(ap);

	return cnt;
}
  80116a:	c9                   	leave  
  80116b:	c3                   	ret    

0080116c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	57                   	push   %edi
  801170:	56                   	push   %esi
  801171:	53                   	push   %ebx
  801172:	83 ec 1c             	sub    $0x1c,%esp
  801175:	89 c7                	mov    %eax,%edi
  801177:	89 d6                	mov    %edx,%esi
  801179:	8b 45 08             	mov    0x8(%ebp),%eax
  80117c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117f:	89 d1                	mov    %edx,%ecx
  801181:	89 c2                	mov    %eax,%edx
  801183:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801186:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801189:	8b 45 10             	mov    0x10(%ebp),%eax
  80118c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80118f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801192:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801199:	39 c2                	cmp    %eax,%edx
  80119b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80119e:	72 3e                	jb     8011de <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011a0:	83 ec 0c             	sub    $0xc,%esp
  8011a3:	ff 75 18             	pushl  0x18(%ebp)
  8011a6:	83 eb 01             	sub    $0x1,%ebx
  8011a9:	53                   	push   %ebx
  8011aa:	50                   	push   %eax
  8011ab:	83 ec 08             	sub    $0x8,%esp
  8011ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ba:	e8 b1 09 00 00       	call   801b70 <__udivdi3>
  8011bf:	83 c4 18             	add    $0x18,%esp
  8011c2:	52                   	push   %edx
  8011c3:	50                   	push   %eax
  8011c4:	89 f2                	mov    %esi,%edx
  8011c6:	89 f8                	mov    %edi,%eax
  8011c8:	e8 9f ff ff ff       	call   80116c <printnum>
  8011cd:	83 c4 20             	add    $0x20,%esp
  8011d0:	eb 13                	jmp    8011e5 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011d2:	83 ec 08             	sub    $0x8,%esp
  8011d5:	56                   	push   %esi
  8011d6:	ff 75 18             	pushl  0x18(%ebp)
  8011d9:	ff d7                	call   *%edi
  8011db:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011de:	83 eb 01             	sub    $0x1,%ebx
  8011e1:	85 db                	test   %ebx,%ebx
  8011e3:	7f ed                	jg     8011d2 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011e5:	83 ec 08             	sub    $0x8,%esp
  8011e8:	56                   	push   %esi
  8011e9:	83 ec 04             	sub    $0x4,%esp
  8011ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f8:	e8 83 0a 00 00       	call   801c80 <__umoddi3>
  8011fd:	83 c4 14             	add    $0x14,%esp
  801200:	0f be 80 27 1f 80 00 	movsbl 0x801f27(%eax),%eax
  801207:	50                   	push   %eax
  801208:	ff d7                	call   *%edi
}
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801210:	5b                   	pop    %ebx
  801211:	5e                   	pop    %esi
  801212:	5f                   	pop    %edi
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801215:	83 fa 01             	cmp    $0x1,%edx
  801218:	7f 13                	jg     80122d <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80121a:	85 d2                	test   %edx,%edx
  80121c:	74 1c                	je     80123a <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80121e:	8b 10                	mov    (%eax),%edx
  801220:	8d 4a 04             	lea    0x4(%edx),%ecx
  801223:	89 08                	mov    %ecx,(%eax)
  801225:	8b 02                	mov    (%edx),%eax
  801227:	ba 00 00 00 00       	mov    $0x0,%edx
  80122c:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80122d:	8b 10                	mov    (%eax),%edx
  80122f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801232:	89 08                	mov    %ecx,(%eax)
  801234:	8b 02                	mov    (%edx),%eax
  801236:	8b 52 04             	mov    0x4(%edx),%edx
  801239:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80123a:	8b 10                	mov    (%eax),%edx
  80123c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80123f:	89 08                	mov    %ecx,(%eax)
  801241:	8b 02                	mov    (%edx),%eax
  801243:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801248:	c3                   	ret    

00801249 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801249:	83 fa 01             	cmp    $0x1,%edx
  80124c:	7f 0f                	jg     80125d <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80124e:	85 d2                	test   %edx,%edx
  801250:	74 18                	je     80126a <getint+0x21>
		return va_arg(*ap, long);
  801252:	8b 10                	mov    (%eax),%edx
  801254:	8d 4a 04             	lea    0x4(%edx),%ecx
  801257:	89 08                	mov    %ecx,(%eax)
  801259:	8b 02                	mov    (%edx),%eax
  80125b:	99                   	cltd   
  80125c:	c3                   	ret    
		return va_arg(*ap, long long);
  80125d:	8b 10                	mov    (%eax),%edx
  80125f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801262:	89 08                	mov    %ecx,(%eax)
  801264:	8b 02                	mov    (%edx),%eax
  801266:	8b 52 04             	mov    0x4(%edx),%edx
  801269:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80126a:	8b 10                	mov    (%eax),%edx
  80126c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80126f:	89 08                	mov    %ecx,(%eax)
  801271:	8b 02                	mov    (%edx),%eax
  801273:	99                   	cltd   
}
  801274:	c3                   	ret    

00801275 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801275:	f3 0f 1e fb          	endbr32 
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80127f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801283:	8b 10                	mov    (%eax),%edx
  801285:	3b 50 04             	cmp    0x4(%eax),%edx
  801288:	73 0a                	jae    801294 <sprintputch+0x1f>
		*b->buf++ = ch;
  80128a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80128d:	89 08                	mov    %ecx,(%eax)
  80128f:	8b 45 08             	mov    0x8(%ebp),%eax
  801292:	88 02                	mov    %al,(%edx)
}
  801294:	5d                   	pop    %ebp
  801295:	c3                   	ret    

00801296 <printfmt>:
{
  801296:	f3 0f 1e fb          	endbr32 
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012a3:	50                   	push   %eax
  8012a4:	ff 75 10             	pushl  0x10(%ebp)
  8012a7:	ff 75 0c             	pushl  0xc(%ebp)
  8012aa:	ff 75 08             	pushl  0x8(%ebp)
  8012ad:	e8 05 00 00 00       	call   8012b7 <vprintfmt>
}
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	c9                   	leave  
  8012b6:	c3                   	ret    

008012b7 <vprintfmt>:
{
  8012b7:	f3 0f 1e fb          	endbr32 
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	57                   	push   %edi
  8012bf:	56                   	push   %esi
  8012c0:	53                   	push   %ebx
  8012c1:	83 ec 2c             	sub    $0x2c,%esp
  8012c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012c7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012ca:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012cd:	e9 86 02 00 00       	jmp    801558 <vprintfmt+0x2a1>
		padc = ' ';
  8012d2:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012d6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012dd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012e4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012eb:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012f0:	8d 47 01             	lea    0x1(%edi),%eax
  8012f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f6:	0f b6 17             	movzbl (%edi),%edx
  8012f9:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012fc:	3c 55                	cmp    $0x55,%al
  8012fe:	0f 87 df 02 00 00    	ja     8015e3 <vprintfmt+0x32c>
  801304:	0f b6 c0             	movzbl %al,%eax
  801307:	3e ff 24 85 60 20 80 	notrack jmp *0x802060(,%eax,4)
  80130e:	00 
  80130f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801312:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801316:	eb d8                	jmp    8012f0 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801318:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80131b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80131f:	eb cf                	jmp    8012f0 <vprintfmt+0x39>
  801321:	0f b6 d2             	movzbl %dl,%edx
  801324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801327:	b8 00 00 00 00       	mov    $0x0,%eax
  80132c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80132f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801332:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801336:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801339:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80133c:	83 f9 09             	cmp    $0x9,%ecx
  80133f:	77 52                	ja     801393 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  801341:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801344:	eb e9                	jmp    80132f <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801346:	8b 45 14             	mov    0x14(%ebp),%eax
  801349:	8d 50 04             	lea    0x4(%eax),%edx
  80134c:	89 55 14             	mov    %edx,0x14(%ebp)
  80134f:	8b 00                	mov    (%eax),%eax
  801351:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801354:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801357:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80135b:	79 93                	jns    8012f0 <vprintfmt+0x39>
				width = precision, precision = -1;
  80135d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801360:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801363:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80136a:	eb 84                	jmp    8012f0 <vprintfmt+0x39>
  80136c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80136f:	85 c0                	test   %eax,%eax
  801371:	ba 00 00 00 00       	mov    $0x0,%edx
  801376:	0f 49 d0             	cmovns %eax,%edx
  801379:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80137c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80137f:	e9 6c ff ff ff       	jmp    8012f0 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801387:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80138e:	e9 5d ff ff ff       	jmp    8012f0 <vprintfmt+0x39>
  801393:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801396:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801399:	eb bc                	jmp    801357 <vprintfmt+0xa0>
			lflag++;
  80139b:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80139e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013a1:	e9 4a ff ff ff       	jmp    8012f0 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a9:	8d 50 04             	lea    0x4(%eax),%edx
  8013ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8013af:	83 ec 08             	sub    $0x8,%esp
  8013b2:	56                   	push   %esi
  8013b3:	ff 30                	pushl  (%eax)
  8013b5:	ff d3                	call   *%ebx
			break;
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	e9 96 01 00 00       	jmp    801555 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8013bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c2:	8d 50 04             	lea    0x4(%eax),%edx
  8013c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c8:	8b 00                	mov    (%eax),%eax
  8013ca:	99                   	cltd   
  8013cb:	31 d0                	xor    %edx,%eax
  8013cd:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013cf:	83 f8 0f             	cmp    $0xf,%eax
  8013d2:	7f 20                	jg     8013f4 <vprintfmt+0x13d>
  8013d4:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  8013db:	85 d2                	test   %edx,%edx
  8013dd:	74 15                	je     8013f4 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8013df:	52                   	push   %edx
  8013e0:	68 bd 1e 80 00       	push   $0x801ebd
  8013e5:	56                   	push   %esi
  8013e6:	53                   	push   %ebx
  8013e7:	e8 aa fe ff ff       	call   801296 <printfmt>
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	e9 61 01 00 00       	jmp    801555 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8013f4:	50                   	push   %eax
  8013f5:	68 3f 1f 80 00       	push   $0x801f3f
  8013fa:	56                   	push   %esi
  8013fb:	53                   	push   %ebx
  8013fc:	e8 95 fe ff ff       	call   801296 <printfmt>
  801401:	83 c4 10             	add    $0x10,%esp
  801404:	e9 4c 01 00 00       	jmp    801555 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  801409:	8b 45 14             	mov    0x14(%ebp),%eax
  80140c:	8d 50 04             	lea    0x4(%eax),%edx
  80140f:	89 55 14             	mov    %edx,0x14(%ebp)
  801412:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  801414:	85 c9                	test   %ecx,%ecx
  801416:	b8 38 1f 80 00       	mov    $0x801f38,%eax
  80141b:	0f 45 c1             	cmovne %ecx,%eax
  80141e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801421:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801425:	7e 06                	jle    80142d <vprintfmt+0x176>
  801427:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80142b:	75 0d                	jne    80143a <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  80142d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801430:	89 c7                	mov    %eax,%edi
  801432:	03 45 e0             	add    -0x20(%ebp),%eax
  801435:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801438:	eb 57                	jmp    801491 <vprintfmt+0x1da>
  80143a:	83 ec 08             	sub    $0x8,%esp
  80143d:	ff 75 d8             	pushl  -0x28(%ebp)
  801440:	ff 75 cc             	pushl  -0x34(%ebp)
  801443:	e8 4f 02 00 00       	call   801697 <strnlen>
  801448:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80144b:	29 c2                	sub    %eax,%edx
  80144d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801450:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801453:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801457:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80145a:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80145c:	85 db                	test   %ebx,%ebx
  80145e:	7e 10                	jle    801470 <vprintfmt+0x1b9>
					putch(padc, putdat);
  801460:	83 ec 08             	sub    $0x8,%esp
  801463:	56                   	push   %esi
  801464:	57                   	push   %edi
  801465:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801468:	83 eb 01             	sub    $0x1,%ebx
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	eb ec                	jmp    80145c <vprintfmt+0x1a5>
  801470:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801473:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801476:	85 d2                	test   %edx,%edx
  801478:	b8 00 00 00 00       	mov    $0x0,%eax
  80147d:	0f 49 c2             	cmovns %edx,%eax
  801480:	29 c2                	sub    %eax,%edx
  801482:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801485:	eb a6                	jmp    80142d <vprintfmt+0x176>
					putch(ch, putdat);
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	56                   	push   %esi
  80148b:	52                   	push   %edx
  80148c:	ff d3                	call   *%ebx
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801494:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801496:	83 c7 01             	add    $0x1,%edi
  801499:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80149d:	0f be d0             	movsbl %al,%edx
  8014a0:	85 d2                	test   %edx,%edx
  8014a2:	74 42                	je     8014e6 <vprintfmt+0x22f>
  8014a4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014a8:	78 06                	js     8014b0 <vprintfmt+0x1f9>
  8014aa:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014ae:	78 1e                	js     8014ce <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8014b0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014b4:	74 d1                	je     801487 <vprintfmt+0x1d0>
  8014b6:	0f be c0             	movsbl %al,%eax
  8014b9:	83 e8 20             	sub    $0x20,%eax
  8014bc:	83 f8 5e             	cmp    $0x5e,%eax
  8014bf:	76 c6                	jbe    801487 <vprintfmt+0x1d0>
					putch('?', putdat);
  8014c1:	83 ec 08             	sub    $0x8,%esp
  8014c4:	56                   	push   %esi
  8014c5:	6a 3f                	push   $0x3f
  8014c7:	ff d3                	call   *%ebx
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	eb c3                	jmp    801491 <vprintfmt+0x1da>
  8014ce:	89 cf                	mov    %ecx,%edi
  8014d0:	eb 0e                	jmp    8014e0 <vprintfmt+0x229>
				putch(' ', putdat);
  8014d2:	83 ec 08             	sub    $0x8,%esp
  8014d5:	56                   	push   %esi
  8014d6:	6a 20                	push   $0x20
  8014d8:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8014da:	83 ef 01             	sub    $0x1,%edi
  8014dd:	83 c4 10             	add    $0x10,%esp
  8014e0:	85 ff                	test   %edi,%edi
  8014e2:	7f ee                	jg     8014d2 <vprintfmt+0x21b>
  8014e4:	eb 6f                	jmp    801555 <vprintfmt+0x29e>
  8014e6:	89 cf                	mov    %ecx,%edi
  8014e8:	eb f6                	jmp    8014e0 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8014ea:	89 ca                	mov    %ecx,%edx
  8014ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8014ef:	e8 55 fd ff ff       	call   801249 <getint>
  8014f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8014fa:	85 d2                	test   %edx,%edx
  8014fc:	78 0b                	js     801509 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8014fe:	89 d1                	mov    %edx,%ecx
  801500:	89 c2                	mov    %eax,%edx
			base = 10;
  801502:	b8 0a 00 00 00       	mov    $0xa,%eax
  801507:	eb 32                	jmp    80153b <vprintfmt+0x284>
				putch('-', putdat);
  801509:	83 ec 08             	sub    $0x8,%esp
  80150c:	56                   	push   %esi
  80150d:	6a 2d                	push   $0x2d
  80150f:	ff d3                	call   *%ebx
				num = -(long long) num;
  801511:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801514:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801517:	f7 da                	neg    %edx
  801519:	83 d1 00             	adc    $0x0,%ecx
  80151c:	f7 d9                	neg    %ecx
  80151e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801521:	b8 0a 00 00 00       	mov    $0xa,%eax
  801526:	eb 13                	jmp    80153b <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  801528:	89 ca                	mov    %ecx,%edx
  80152a:	8d 45 14             	lea    0x14(%ebp),%eax
  80152d:	e8 e3 fc ff ff       	call   801215 <getuint>
  801532:	89 d1                	mov    %edx,%ecx
  801534:	89 c2                	mov    %eax,%edx
			base = 10;
  801536:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  80153b:	83 ec 0c             	sub    $0xc,%esp
  80153e:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801542:	57                   	push   %edi
  801543:	ff 75 e0             	pushl  -0x20(%ebp)
  801546:	50                   	push   %eax
  801547:	51                   	push   %ecx
  801548:	52                   	push   %edx
  801549:	89 f2                	mov    %esi,%edx
  80154b:	89 d8                	mov    %ebx,%eax
  80154d:	e8 1a fc ff ff       	call   80116c <printnum>
			break;
  801552:	83 c4 20             	add    $0x20,%esp
{
  801555:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801558:	83 c7 01             	add    $0x1,%edi
  80155b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80155f:	83 f8 25             	cmp    $0x25,%eax
  801562:	0f 84 6a fd ff ff    	je     8012d2 <vprintfmt+0x1b>
			if (ch == '\0')
  801568:	85 c0                	test   %eax,%eax
  80156a:	0f 84 93 00 00 00    	je     801603 <vprintfmt+0x34c>
			putch(ch, putdat);
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	56                   	push   %esi
  801574:	50                   	push   %eax
  801575:	ff d3                	call   *%ebx
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	eb dc                	jmp    801558 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  80157c:	89 ca                	mov    %ecx,%edx
  80157e:	8d 45 14             	lea    0x14(%ebp),%eax
  801581:	e8 8f fc ff ff       	call   801215 <getuint>
  801586:	89 d1                	mov    %edx,%ecx
  801588:	89 c2                	mov    %eax,%edx
			base = 8;
  80158a:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80158f:	eb aa                	jmp    80153b <vprintfmt+0x284>
			putch('0', putdat);
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	56                   	push   %esi
  801595:	6a 30                	push   $0x30
  801597:	ff d3                	call   *%ebx
			putch('x', putdat);
  801599:	83 c4 08             	add    $0x8,%esp
  80159c:	56                   	push   %esi
  80159d:	6a 78                	push   $0x78
  80159f:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8015a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a4:	8d 50 04             	lea    0x4(%eax),%edx
  8015a7:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8015aa:	8b 10                	mov    (%eax),%edx
  8015ac:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015b1:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8015b4:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015b9:	eb 80                	jmp    80153b <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8015bb:	89 ca                	mov    %ecx,%edx
  8015bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8015c0:	e8 50 fc ff ff       	call   801215 <getuint>
  8015c5:	89 d1                	mov    %edx,%ecx
  8015c7:	89 c2                	mov    %eax,%edx
			base = 16;
  8015c9:	b8 10 00 00 00       	mov    $0x10,%eax
  8015ce:	e9 68 ff ff ff       	jmp    80153b <vprintfmt+0x284>
			putch(ch, putdat);
  8015d3:	83 ec 08             	sub    $0x8,%esp
  8015d6:	56                   	push   %esi
  8015d7:	6a 25                	push   $0x25
  8015d9:	ff d3                	call   *%ebx
			break;
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	e9 72 ff ff ff       	jmp    801555 <vprintfmt+0x29e>
			putch('%', putdat);
  8015e3:	83 ec 08             	sub    $0x8,%esp
  8015e6:	56                   	push   %esi
  8015e7:	6a 25                	push   $0x25
  8015e9:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	89 f8                	mov    %edi,%eax
  8015f0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015f4:	74 05                	je     8015fb <vprintfmt+0x344>
  8015f6:	83 e8 01             	sub    $0x1,%eax
  8015f9:	eb f5                	jmp    8015f0 <vprintfmt+0x339>
  8015fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015fe:	e9 52 ff ff ff       	jmp    801555 <vprintfmt+0x29e>
}
  801603:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5f                   	pop    %edi
  801609:	5d                   	pop    %ebp
  80160a:	c3                   	ret    

0080160b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80160b:	f3 0f 1e fb          	endbr32 
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	83 ec 18             	sub    $0x18,%esp
  801615:	8b 45 08             	mov    0x8(%ebp),%eax
  801618:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80161b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80161e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801622:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801625:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80162c:	85 c0                	test   %eax,%eax
  80162e:	74 26                	je     801656 <vsnprintf+0x4b>
  801630:	85 d2                	test   %edx,%edx
  801632:	7e 22                	jle    801656 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801634:	ff 75 14             	pushl  0x14(%ebp)
  801637:	ff 75 10             	pushl  0x10(%ebp)
  80163a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80163d:	50                   	push   %eax
  80163e:	68 75 12 80 00       	push   $0x801275
  801643:	e8 6f fc ff ff       	call   8012b7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801648:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80164b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80164e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801651:	83 c4 10             	add    $0x10,%esp
}
  801654:	c9                   	leave  
  801655:	c3                   	ret    
		return -E_INVAL;
  801656:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80165b:	eb f7                	jmp    801654 <vsnprintf+0x49>

0080165d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80165d:	f3 0f 1e fb          	endbr32 
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801667:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80166a:	50                   	push   %eax
  80166b:	ff 75 10             	pushl  0x10(%ebp)
  80166e:	ff 75 0c             	pushl  0xc(%ebp)
  801671:	ff 75 08             	pushl  0x8(%ebp)
  801674:	e8 92 ff ff ff       	call   80160b <vsnprintf>
	va_end(ap);

	return rc;
}
  801679:	c9                   	leave  
  80167a:	c3                   	ret    

0080167b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80167b:	f3 0f 1e fb          	endbr32 
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801685:	b8 00 00 00 00       	mov    $0x0,%eax
  80168a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80168e:	74 05                	je     801695 <strlen+0x1a>
		n++;
  801690:	83 c0 01             	add    $0x1,%eax
  801693:	eb f5                	jmp    80168a <strlen+0xf>
	return n;
}
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801697:	f3 0f 1e fb          	endbr32 
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a9:	39 d0                	cmp    %edx,%eax
  8016ab:	74 0d                	je     8016ba <strnlen+0x23>
  8016ad:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016b1:	74 05                	je     8016b8 <strnlen+0x21>
		n++;
  8016b3:	83 c0 01             	add    $0x1,%eax
  8016b6:	eb f1                	jmp    8016a9 <strnlen+0x12>
  8016b8:	89 c2                	mov    %eax,%edx
	return n;
}
  8016ba:	89 d0                	mov    %edx,%eax
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    

008016be <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016be:	f3 0f 1e fb          	endbr32 
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	53                   	push   %ebx
  8016c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016d5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016d8:	83 c0 01             	add    $0x1,%eax
  8016db:	84 d2                	test   %dl,%dl
  8016dd:	75 f2                	jne    8016d1 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8016df:	89 c8                	mov    %ecx,%eax
  8016e1:	5b                   	pop    %ebx
  8016e2:	5d                   	pop    %ebp
  8016e3:	c3                   	ret    

008016e4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016e4:	f3 0f 1e fb          	endbr32 
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	53                   	push   %ebx
  8016ec:	83 ec 10             	sub    $0x10,%esp
  8016ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016f2:	53                   	push   %ebx
  8016f3:	e8 83 ff ff ff       	call   80167b <strlen>
  8016f8:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016fb:	ff 75 0c             	pushl  0xc(%ebp)
  8016fe:	01 d8                	add    %ebx,%eax
  801700:	50                   	push   %eax
  801701:	e8 b8 ff ff ff       	call   8016be <strcpy>
	return dst;
}
  801706:	89 d8                	mov    %ebx,%eax
  801708:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170b:	c9                   	leave  
  80170c:	c3                   	ret    

0080170d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80170d:	f3 0f 1e fb          	endbr32 
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	56                   	push   %esi
  801715:	53                   	push   %ebx
  801716:	8b 75 08             	mov    0x8(%ebp),%esi
  801719:	8b 55 0c             	mov    0xc(%ebp),%edx
  80171c:	89 f3                	mov    %esi,%ebx
  80171e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801721:	89 f0                	mov    %esi,%eax
  801723:	39 d8                	cmp    %ebx,%eax
  801725:	74 11                	je     801738 <strncpy+0x2b>
		*dst++ = *src;
  801727:	83 c0 01             	add    $0x1,%eax
  80172a:	0f b6 0a             	movzbl (%edx),%ecx
  80172d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801730:	80 f9 01             	cmp    $0x1,%cl
  801733:	83 da ff             	sbb    $0xffffffff,%edx
  801736:	eb eb                	jmp    801723 <strncpy+0x16>
	}
	return ret;
}
  801738:	89 f0                	mov    %esi,%eax
  80173a:	5b                   	pop    %ebx
  80173b:	5e                   	pop    %esi
  80173c:	5d                   	pop    %ebp
  80173d:	c3                   	ret    

0080173e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80173e:	f3 0f 1e fb          	endbr32 
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	56                   	push   %esi
  801746:	53                   	push   %ebx
  801747:	8b 75 08             	mov    0x8(%ebp),%esi
  80174a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174d:	8b 55 10             	mov    0x10(%ebp),%edx
  801750:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801752:	85 d2                	test   %edx,%edx
  801754:	74 21                	je     801777 <strlcpy+0x39>
  801756:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80175a:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80175c:	39 c2                	cmp    %eax,%edx
  80175e:	74 14                	je     801774 <strlcpy+0x36>
  801760:	0f b6 19             	movzbl (%ecx),%ebx
  801763:	84 db                	test   %bl,%bl
  801765:	74 0b                	je     801772 <strlcpy+0x34>
			*dst++ = *src++;
  801767:	83 c1 01             	add    $0x1,%ecx
  80176a:	83 c2 01             	add    $0x1,%edx
  80176d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801770:	eb ea                	jmp    80175c <strlcpy+0x1e>
  801772:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801774:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801777:	29 f0                	sub    %esi,%eax
}
  801779:	5b                   	pop    %ebx
  80177a:	5e                   	pop    %esi
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    

0080177d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80177d:	f3 0f 1e fb          	endbr32 
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801787:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80178a:	0f b6 01             	movzbl (%ecx),%eax
  80178d:	84 c0                	test   %al,%al
  80178f:	74 0c                	je     80179d <strcmp+0x20>
  801791:	3a 02                	cmp    (%edx),%al
  801793:	75 08                	jne    80179d <strcmp+0x20>
		p++, q++;
  801795:	83 c1 01             	add    $0x1,%ecx
  801798:	83 c2 01             	add    $0x1,%edx
  80179b:	eb ed                	jmp    80178a <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80179d:	0f b6 c0             	movzbl %al,%eax
  8017a0:	0f b6 12             	movzbl (%edx),%edx
  8017a3:	29 d0                	sub    %edx,%eax
}
  8017a5:	5d                   	pop    %ebp
  8017a6:	c3                   	ret    

008017a7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017a7:	f3 0f 1e fb          	endbr32 
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	53                   	push   %ebx
  8017af:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b5:	89 c3                	mov    %eax,%ebx
  8017b7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017ba:	eb 06                	jmp    8017c2 <strncmp+0x1b>
		n--, p++, q++;
  8017bc:	83 c0 01             	add    $0x1,%eax
  8017bf:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017c2:	39 d8                	cmp    %ebx,%eax
  8017c4:	74 16                	je     8017dc <strncmp+0x35>
  8017c6:	0f b6 08             	movzbl (%eax),%ecx
  8017c9:	84 c9                	test   %cl,%cl
  8017cb:	74 04                	je     8017d1 <strncmp+0x2a>
  8017cd:	3a 0a                	cmp    (%edx),%cl
  8017cf:	74 eb                	je     8017bc <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d1:	0f b6 00             	movzbl (%eax),%eax
  8017d4:	0f b6 12             	movzbl (%edx),%edx
  8017d7:	29 d0                	sub    %edx,%eax
}
  8017d9:	5b                   	pop    %ebx
  8017da:	5d                   	pop    %ebp
  8017db:	c3                   	ret    
		return 0;
  8017dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e1:	eb f6                	jmp    8017d9 <strncmp+0x32>

008017e3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017e3:	f3 0f 1e fb          	endbr32 
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f1:	0f b6 10             	movzbl (%eax),%edx
  8017f4:	84 d2                	test   %dl,%dl
  8017f6:	74 09                	je     801801 <strchr+0x1e>
		if (*s == c)
  8017f8:	38 ca                	cmp    %cl,%dl
  8017fa:	74 0a                	je     801806 <strchr+0x23>
	for (; *s; s++)
  8017fc:	83 c0 01             	add    $0x1,%eax
  8017ff:	eb f0                	jmp    8017f1 <strchr+0xe>
			return (char *) s;
	return 0;
  801801:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801806:	5d                   	pop    %ebp
  801807:	c3                   	ret    

00801808 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801808:	f3 0f 1e fb          	endbr32 
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	8b 45 08             	mov    0x8(%ebp),%eax
  801812:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801816:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801819:	38 ca                	cmp    %cl,%dl
  80181b:	74 09                	je     801826 <strfind+0x1e>
  80181d:	84 d2                	test   %dl,%dl
  80181f:	74 05                	je     801826 <strfind+0x1e>
	for (; *s; s++)
  801821:	83 c0 01             	add    $0x1,%eax
  801824:	eb f0                	jmp    801816 <strfind+0xe>
			break;
	return (char *) s;
}
  801826:	5d                   	pop    %ebp
  801827:	c3                   	ret    

00801828 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801828:	f3 0f 1e fb          	endbr32 
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	57                   	push   %edi
  801830:	56                   	push   %esi
  801831:	53                   	push   %ebx
  801832:	8b 55 08             	mov    0x8(%ebp),%edx
  801835:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  801838:	85 c9                	test   %ecx,%ecx
  80183a:	74 33                	je     80186f <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80183c:	89 d0                	mov    %edx,%eax
  80183e:	09 c8                	or     %ecx,%eax
  801840:	a8 03                	test   $0x3,%al
  801842:	75 23                	jne    801867 <memset+0x3f>
		c &= 0xFF;
  801844:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801848:	89 d8                	mov    %ebx,%eax
  80184a:	c1 e0 08             	shl    $0x8,%eax
  80184d:	89 df                	mov    %ebx,%edi
  80184f:	c1 e7 18             	shl    $0x18,%edi
  801852:	89 de                	mov    %ebx,%esi
  801854:	c1 e6 10             	shl    $0x10,%esi
  801857:	09 f7                	or     %esi,%edi
  801859:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  80185b:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80185e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  801860:	89 d7                	mov    %edx,%edi
  801862:	fc                   	cld    
  801863:	f3 ab                	rep stos %eax,%es:(%edi)
  801865:	eb 08                	jmp    80186f <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801867:	89 d7                	mov    %edx,%edi
  801869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186c:	fc                   	cld    
  80186d:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  80186f:	89 d0                	mov    %edx,%eax
  801871:	5b                   	pop    %ebx
  801872:	5e                   	pop    %esi
  801873:	5f                   	pop    %edi
  801874:	5d                   	pop    %ebp
  801875:	c3                   	ret    

00801876 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801876:	f3 0f 1e fb          	endbr32 
  80187a:	55                   	push   %ebp
  80187b:	89 e5                	mov    %esp,%ebp
  80187d:	57                   	push   %edi
  80187e:	56                   	push   %esi
  80187f:	8b 45 08             	mov    0x8(%ebp),%eax
  801882:	8b 75 0c             	mov    0xc(%ebp),%esi
  801885:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801888:	39 c6                	cmp    %eax,%esi
  80188a:	73 32                	jae    8018be <memmove+0x48>
  80188c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80188f:	39 c2                	cmp    %eax,%edx
  801891:	76 2b                	jbe    8018be <memmove+0x48>
		s += n;
		d += n;
  801893:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801896:	89 fe                	mov    %edi,%esi
  801898:	09 ce                	or     %ecx,%esi
  80189a:	09 d6                	or     %edx,%esi
  80189c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018a2:	75 0e                	jne    8018b2 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018a4:	83 ef 04             	sub    $0x4,%edi
  8018a7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018aa:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018ad:	fd                   	std    
  8018ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b0:	eb 09                	jmp    8018bb <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018b2:	83 ef 01             	sub    $0x1,%edi
  8018b5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018b8:	fd                   	std    
  8018b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018bb:	fc                   	cld    
  8018bc:	eb 1a                	jmp    8018d8 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018be:	89 c2                	mov    %eax,%edx
  8018c0:	09 ca                	or     %ecx,%edx
  8018c2:	09 f2                	or     %esi,%edx
  8018c4:	f6 c2 03             	test   $0x3,%dl
  8018c7:	75 0a                	jne    8018d3 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018c9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018cc:	89 c7                	mov    %eax,%edi
  8018ce:	fc                   	cld    
  8018cf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d1:	eb 05                	jmp    8018d8 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8018d3:	89 c7                	mov    %eax,%edi
  8018d5:	fc                   	cld    
  8018d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d8:	5e                   	pop    %esi
  8018d9:	5f                   	pop    %edi
  8018da:	5d                   	pop    %ebp
  8018db:	c3                   	ret    

008018dc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018dc:	f3 0f 1e fb          	endbr32 
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018e6:	ff 75 10             	pushl  0x10(%ebp)
  8018e9:	ff 75 0c             	pushl  0xc(%ebp)
  8018ec:	ff 75 08             	pushl  0x8(%ebp)
  8018ef:	e8 82 ff ff ff       	call   801876 <memmove>
}
  8018f4:	c9                   	leave  
  8018f5:	c3                   	ret    

008018f6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018f6:	f3 0f 1e fb          	endbr32 
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	56                   	push   %esi
  8018fe:	53                   	push   %ebx
  8018ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801902:	8b 55 0c             	mov    0xc(%ebp),%edx
  801905:	89 c6                	mov    %eax,%esi
  801907:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80190a:	39 f0                	cmp    %esi,%eax
  80190c:	74 1c                	je     80192a <memcmp+0x34>
		if (*s1 != *s2)
  80190e:	0f b6 08             	movzbl (%eax),%ecx
  801911:	0f b6 1a             	movzbl (%edx),%ebx
  801914:	38 d9                	cmp    %bl,%cl
  801916:	75 08                	jne    801920 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801918:	83 c0 01             	add    $0x1,%eax
  80191b:	83 c2 01             	add    $0x1,%edx
  80191e:	eb ea                	jmp    80190a <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801920:	0f b6 c1             	movzbl %cl,%eax
  801923:	0f b6 db             	movzbl %bl,%ebx
  801926:	29 d8                	sub    %ebx,%eax
  801928:	eb 05                	jmp    80192f <memcmp+0x39>
	}

	return 0;
  80192a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192f:	5b                   	pop    %ebx
  801930:	5e                   	pop    %esi
  801931:	5d                   	pop    %ebp
  801932:	c3                   	ret    

00801933 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801933:	f3 0f 1e fb          	endbr32 
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	8b 45 08             	mov    0x8(%ebp),%eax
  80193d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801940:	89 c2                	mov    %eax,%edx
  801942:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801945:	39 d0                	cmp    %edx,%eax
  801947:	73 09                	jae    801952 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801949:	38 08                	cmp    %cl,(%eax)
  80194b:	74 05                	je     801952 <memfind+0x1f>
	for (; s < ends; s++)
  80194d:	83 c0 01             	add    $0x1,%eax
  801950:	eb f3                	jmp    801945 <memfind+0x12>
			break;
	return (void *) s;
}
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801954:	f3 0f 1e fb          	endbr32 
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	57                   	push   %edi
  80195c:	56                   	push   %esi
  80195d:	53                   	push   %ebx
  80195e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801961:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801964:	eb 03                	jmp    801969 <strtol+0x15>
		s++;
  801966:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801969:	0f b6 01             	movzbl (%ecx),%eax
  80196c:	3c 20                	cmp    $0x20,%al
  80196e:	74 f6                	je     801966 <strtol+0x12>
  801970:	3c 09                	cmp    $0x9,%al
  801972:	74 f2                	je     801966 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801974:	3c 2b                	cmp    $0x2b,%al
  801976:	74 2a                	je     8019a2 <strtol+0x4e>
	int neg = 0;
  801978:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80197d:	3c 2d                	cmp    $0x2d,%al
  80197f:	74 2b                	je     8019ac <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801981:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801987:	75 0f                	jne    801998 <strtol+0x44>
  801989:	80 39 30             	cmpb   $0x30,(%ecx)
  80198c:	74 28                	je     8019b6 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80198e:	85 db                	test   %ebx,%ebx
  801990:	b8 0a 00 00 00       	mov    $0xa,%eax
  801995:	0f 44 d8             	cmove  %eax,%ebx
  801998:	b8 00 00 00 00       	mov    $0x0,%eax
  80199d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019a0:	eb 46                	jmp    8019e8 <strtol+0x94>
		s++;
  8019a2:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019a5:	bf 00 00 00 00       	mov    $0x0,%edi
  8019aa:	eb d5                	jmp    801981 <strtol+0x2d>
		s++, neg = 1;
  8019ac:	83 c1 01             	add    $0x1,%ecx
  8019af:	bf 01 00 00 00       	mov    $0x1,%edi
  8019b4:	eb cb                	jmp    801981 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019ba:	74 0e                	je     8019ca <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019bc:	85 db                	test   %ebx,%ebx
  8019be:	75 d8                	jne    801998 <strtol+0x44>
		s++, base = 8;
  8019c0:	83 c1 01             	add    $0x1,%ecx
  8019c3:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019c8:	eb ce                	jmp    801998 <strtol+0x44>
		s += 2, base = 16;
  8019ca:	83 c1 02             	add    $0x2,%ecx
  8019cd:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019d2:	eb c4                	jmp    801998 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019d4:	0f be d2             	movsbl %dl,%edx
  8019d7:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019da:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019dd:	7d 3a                	jge    801a19 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019df:	83 c1 01             	add    $0x1,%ecx
  8019e2:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019e6:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019e8:	0f b6 11             	movzbl (%ecx),%edx
  8019eb:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019ee:	89 f3                	mov    %esi,%ebx
  8019f0:	80 fb 09             	cmp    $0x9,%bl
  8019f3:	76 df                	jbe    8019d4 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8019f5:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019f8:	89 f3                	mov    %esi,%ebx
  8019fa:	80 fb 19             	cmp    $0x19,%bl
  8019fd:	77 08                	ja     801a07 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019ff:	0f be d2             	movsbl %dl,%edx
  801a02:	83 ea 57             	sub    $0x57,%edx
  801a05:	eb d3                	jmp    8019da <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801a07:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a0a:	89 f3                	mov    %esi,%ebx
  801a0c:	80 fb 19             	cmp    $0x19,%bl
  801a0f:	77 08                	ja     801a19 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a11:	0f be d2             	movsbl %dl,%edx
  801a14:	83 ea 37             	sub    $0x37,%edx
  801a17:	eb c1                	jmp    8019da <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a19:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a1d:	74 05                	je     801a24 <strtol+0xd0>
		*endptr = (char *) s;
  801a1f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a22:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a24:	89 c2                	mov    %eax,%edx
  801a26:	f7 da                	neg    %edx
  801a28:	85 ff                	test   %edi,%edi
  801a2a:	0f 45 c2             	cmovne %edx,%eax
}
  801a2d:	5b                   	pop    %ebx
  801a2e:	5e                   	pop    %esi
  801a2f:	5f                   	pop    %edi
  801a30:	5d                   	pop    %ebp
  801a31:	c3                   	ret    

00801a32 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a32:	f3 0f 1e fb          	endbr32 
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	56                   	push   %esi
  801a3a:	53                   	push   %ebx
  801a3b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  801a44:	85 c0                	test   %eax,%eax
  801a46:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a4b:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801a4e:	83 ec 0c             	sub    $0xc,%esp
  801a51:	50                   	push   %eax
  801a52:	e8 82 e8 ff ff       	call   8002d9 <sys_ipc_recv>
	if (f < 0) {
  801a57:	83 c4 10             	add    $0x10,%esp
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	78 2b                	js     801a89 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801a5e:	85 f6                	test   %esi,%esi
  801a60:	74 0a                	je     801a6c <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801a62:	a1 04 40 80 00       	mov    0x804004,%eax
  801a67:	8b 40 74             	mov    0x74(%eax),%eax
  801a6a:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801a6c:	85 db                	test   %ebx,%ebx
  801a6e:	74 0a                	je     801a7a <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801a70:	a1 04 40 80 00       	mov    0x804004,%eax
  801a75:	8b 40 78             	mov    0x78(%eax),%eax
  801a78:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  801a7a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5e                   	pop    %esi
  801a87:	5d                   	pop    %ebp
  801a88:	c3                   	ret    
		if (from_env_store != NULL) {
  801a89:	85 f6                	test   %esi,%esi
  801a8b:	74 06                	je     801a93 <ipc_recv+0x61>
			*from_env_store = 0;
  801a8d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801a93:	85 db                	test   %ebx,%ebx
  801a95:	74 eb                	je     801a82 <ipc_recv+0x50>
			*perm_store = 0;
  801a97:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a9d:	eb e3                	jmp    801a82 <ipc_recv+0x50>

00801a9f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a9f:	f3 0f 1e fb          	endbr32 
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	57                   	push   %edi
  801aa7:	56                   	push   %esi
  801aa8:	53                   	push   %ebx
  801aa9:	83 ec 0c             	sub    $0xc,%esp
  801aac:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aaf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  801ab5:	85 db                	test   %ebx,%ebx
  801ab7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801abc:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801abf:	ff 75 14             	pushl  0x14(%ebp)
  801ac2:	53                   	push   %ebx
  801ac3:	56                   	push   %esi
  801ac4:	57                   	push   %edi
  801ac5:	e8 e6 e7 ff ff       	call   8002b0 <sys_ipc_try_send>
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	85 c0                	test   %eax,%eax
  801acf:	79 19                	jns    801aea <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  801ad1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ad4:	74 e9                	je     801abf <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  801ad6:	83 ec 04             	sub    $0x4,%esp
  801ad9:	68 20 22 80 00       	push   $0x802220
  801ade:	6a 48                	push   $0x48
  801ae0:	68 42 22 80 00       	push   $0x802242
  801ae5:	e8 83 f5 ff ff       	call   80106d <_panic>
		}
	}
}
  801aea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aed:	5b                   	pop    %ebx
  801aee:	5e                   	pop    %esi
  801aef:	5f                   	pop    %edi
  801af0:	5d                   	pop    %ebp
  801af1:	c3                   	ret    

00801af2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801af2:	f3 0f 1e fb          	endbr32 
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801afc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b01:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b04:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b0a:	8b 52 50             	mov    0x50(%edx),%edx
  801b0d:	39 ca                	cmp    %ecx,%edx
  801b0f:	74 11                	je     801b22 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801b11:	83 c0 01             	add    $0x1,%eax
  801b14:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b19:	75 e6                	jne    801b01 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b20:	eb 0b                	jmp    801b2d <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b22:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b25:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b2a:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b2f:	f3 0f 1e fb          	endbr32 
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b39:	89 c2                	mov    %eax,%edx
  801b3b:	c1 ea 16             	shr    $0x16,%edx
  801b3e:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b45:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b4a:	f6 c1 01             	test   $0x1,%cl
  801b4d:	74 1c                	je     801b6b <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b4f:	c1 e8 0c             	shr    $0xc,%eax
  801b52:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b59:	a8 01                	test   $0x1,%al
  801b5b:	74 0e                	je     801b6b <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b5d:	c1 e8 0c             	shr    $0xc,%eax
  801b60:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b67:	ef 
  801b68:	0f b7 d2             	movzwl %dx,%edx
}
  801b6b:	89 d0                	mov    %edx,%eax
  801b6d:	5d                   	pop    %ebp
  801b6e:	c3                   	ret    
  801b6f:	90                   	nop

00801b70 <__udivdi3>:
  801b70:	f3 0f 1e fb          	endbr32 
  801b74:	55                   	push   %ebp
  801b75:	57                   	push   %edi
  801b76:	56                   	push   %esi
  801b77:	53                   	push   %ebx
  801b78:	83 ec 1c             	sub    $0x1c,%esp
  801b7b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b7f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b83:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b87:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b8b:	85 d2                	test   %edx,%edx
  801b8d:	75 19                	jne    801ba8 <__udivdi3+0x38>
  801b8f:	39 f3                	cmp    %esi,%ebx
  801b91:	76 4d                	jbe    801be0 <__udivdi3+0x70>
  801b93:	31 ff                	xor    %edi,%edi
  801b95:	89 e8                	mov    %ebp,%eax
  801b97:	89 f2                	mov    %esi,%edx
  801b99:	f7 f3                	div    %ebx
  801b9b:	89 fa                	mov    %edi,%edx
  801b9d:	83 c4 1c             	add    $0x1c,%esp
  801ba0:	5b                   	pop    %ebx
  801ba1:	5e                   	pop    %esi
  801ba2:	5f                   	pop    %edi
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    
  801ba5:	8d 76 00             	lea    0x0(%esi),%esi
  801ba8:	39 f2                	cmp    %esi,%edx
  801baa:	76 14                	jbe    801bc0 <__udivdi3+0x50>
  801bac:	31 ff                	xor    %edi,%edi
  801bae:	31 c0                	xor    %eax,%eax
  801bb0:	89 fa                	mov    %edi,%edx
  801bb2:	83 c4 1c             	add    $0x1c,%esp
  801bb5:	5b                   	pop    %ebx
  801bb6:	5e                   	pop    %esi
  801bb7:	5f                   	pop    %edi
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    
  801bba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bc0:	0f bd fa             	bsr    %edx,%edi
  801bc3:	83 f7 1f             	xor    $0x1f,%edi
  801bc6:	75 48                	jne    801c10 <__udivdi3+0xa0>
  801bc8:	39 f2                	cmp    %esi,%edx
  801bca:	72 06                	jb     801bd2 <__udivdi3+0x62>
  801bcc:	31 c0                	xor    %eax,%eax
  801bce:	39 eb                	cmp    %ebp,%ebx
  801bd0:	77 de                	ja     801bb0 <__udivdi3+0x40>
  801bd2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd7:	eb d7                	jmp    801bb0 <__udivdi3+0x40>
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be0:	89 d9                	mov    %ebx,%ecx
  801be2:	85 db                	test   %ebx,%ebx
  801be4:	75 0b                	jne    801bf1 <__udivdi3+0x81>
  801be6:	b8 01 00 00 00       	mov    $0x1,%eax
  801beb:	31 d2                	xor    %edx,%edx
  801bed:	f7 f3                	div    %ebx
  801bef:	89 c1                	mov    %eax,%ecx
  801bf1:	31 d2                	xor    %edx,%edx
  801bf3:	89 f0                	mov    %esi,%eax
  801bf5:	f7 f1                	div    %ecx
  801bf7:	89 c6                	mov    %eax,%esi
  801bf9:	89 e8                	mov    %ebp,%eax
  801bfb:	89 f7                	mov    %esi,%edi
  801bfd:	f7 f1                	div    %ecx
  801bff:	89 fa                	mov    %edi,%edx
  801c01:	83 c4 1c             	add    $0x1c,%esp
  801c04:	5b                   	pop    %ebx
  801c05:	5e                   	pop    %esi
  801c06:	5f                   	pop    %edi
  801c07:	5d                   	pop    %ebp
  801c08:	c3                   	ret    
  801c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c10:	89 f9                	mov    %edi,%ecx
  801c12:	b8 20 00 00 00       	mov    $0x20,%eax
  801c17:	29 f8                	sub    %edi,%eax
  801c19:	d3 e2                	shl    %cl,%edx
  801c1b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c1f:	89 c1                	mov    %eax,%ecx
  801c21:	89 da                	mov    %ebx,%edx
  801c23:	d3 ea                	shr    %cl,%edx
  801c25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c29:	09 d1                	or     %edx,%ecx
  801c2b:	89 f2                	mov    %esi,%edx
  801c2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c31:	89 f9                	mov    %edi,%ecx
  801c33:	d3 e3                	shl    %cl,%ebx
  801c35:	89 c1                	mov    %eax,%ecx
  801c37:	d3 ea                	shr    %cl,%edx
  801c39:	89 f9                	mov    %edi,%ecx
  801c3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c3f:	89 eb                	mov    %ebp,%ebx
  801c41:	d3 e6                	shl    %cl,%esi
  801c43:	89 c1                	mov    %eax,%ecx
  801c45:	d3 eb                	shr    %cl,%ebx
  801c47:	09 de                	or     %ebx,%esi
  801c49:	89 f0                	mov    %esi,%eax
  801c4b:	f7 74 24 08          	divl   0x8(%esp)
  801c4f:	89 d6                	mov    %edx,%esi
  801c51:	89 c3                	mov    %eax,%ebx
  801c53:	f7 64 24 0c          	mull   0xc(%esp)
  801c57:	39 d6                	cmp    %edx,%esi
  801c59:	72 15                	jb     801c70 <__udivdi3+0x100>
  801c5b:	89 f9                	mov    %edi,%ecx
  801c5d:	d3 e5                	shl    %cl,%ebp
  801c5f:	39 c5                	cmp    %eax,%ebp
  801c61:	73 04                	jae    801c67 <__udivdi3+0xf7>
  801c63:	39 d6                	cmp    %edx,%esi
  801c65:	74 09                	je     801c70 <__udivdi3+0x100>
  801c67:	89 d8                	mov    %ebx,%eax
  801c69:	31 ff                	xor    %edi,%edi
  801c6b:	e9 40 ff ff ff       	jmp    801bb0 <__udivdi3+0x40>
  801c70:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c73:	31 ff                	xor    %edi,%edi
  801c75:	e9 36 ff ff ff       	jmp    801bb0 <__udivdi3+0x40>
  801c7a:	66 90                	xchg   %ax,%ax
  801c7c:	66 90                	xchg   %ax,%ax
  801c7e:	66 90                	xchg   %ax,%ax

00801c80 <__umoddi3>:
  801c80:	f3 0f 1e fb          	endbr32 
  801c84:	55                   	push   %ebp
  801c85:	57                   	push   %edi
  801c86:	56                   	push   %esi
  801c87:	53                   	push   %ebx
  801c88:	83 ec 1c             	sub    $0x1c,%esp
  801c8b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c8f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c93:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801c97:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	75 19                	jne    801cb8 <__umoddi3+0x38>
  801c9f:	39 df                	cmp    %ebx,%edi
  801ca1:	76 5d                	jbe    801d00 <__umoddi3+0x80>
  801ca3:	89 f0                	mov    %esi,%eax
  801ca5:	89 da                	mov    %ebx,%edx
  801ca7:	f7 f7                	div    %edi
  801ca9:	89 d0                	mov    %edx,%eax
  801cab:	31 d2                	xor    %edx,%edx
  801cad:	83 c4 1c             	add    $0x1c,%esp
  801cb0:	5b                   	pop    %ebx
  801cb1:	5e                   	pop    %esi
  801cb2:	5f                   	pop    %edi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    
  801cb5:	8d 76 00             	lea    0x0(%esi),%esi
  801cb8:	89 f2                	mov    %esi,%edx
  801cba:	39 d8                	cmp    %ebx,%eax
  801cbc:	76 12                	jbe    801cd0 <__umoddi3+0x50>
  801cbe:	89 f0                	mov    %esi,%eax
  801cc0:	89 da                	mov    %ebx,%edx
  801cc2:	83 c4 1c             	add    $0x1c,%esp
  801cc5:	5b                   	pop    %ebx
  801cc6:	5e                   	pop    %esi
  801cc7:	5f                   	pop    %edi
  801cc8:	5d                   	pop    %ebp
  801cc9:	c3                   	ret    
  801cca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd0:	0f bd e8             	bsr    %eax,%ebp
  801cd3:	83 f5 1f             	xor    $0x1f,%ebp
  801cd6:	75 50                	jne    801d28 <__umoddi3+0xa8>
  801cd8:	39 d8                	cmp    %ebx,%eax
  801cda:	0f 82 e0 00 00 00    	jb     801dc0 <__umoddi3+0x140>
  801ce0:	89 d9                	mov    %ebx,%ecx
  801ce2:	39 f7                	cmp    %esi,%edi
  801ce4:	0f 86 d6 00 00 00    	jbe    801dc0 <__umoddi3+0x140>
  801cea:	89 d0                	mov    %edx,%eax
  801cec:	89 ca                	mov    %ecx,%edx
  801cee:	83 c4 1c             	add    $0x1c,%esp
  801cf1:	5b                   	pop    %ebx
  801cf2:	5e                   	pop    %esi
  801cf3:	5f                   	pop    %edi
  801cf4:	5d                   	pop    %ebp
  801cf5:	c3                   	ret    
  801cf6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cfd:	8d 76 00             	lea    0x0(%esi),%esi
  801d00:	89 fd                	mov    %edi,%ebp
  801d02:	85 ff                	test   %edi,%edi
  801d04:	75 0b                	jne    801d11 <__umoddi3+0x91>
  801d06:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0b:	31 d2                	xor    %edx,%edx
  801d0d:	f7 f7                	div    %edi
  801d0f:	89 c5                	mov    %eax,%ebp
  801d11:	89 d8                	mov    %ebx,%eax
  801d13:	31 d2                	xor    %edx,%edx
  801d15:	f7 f5                	div    %ebp
  801d17:	89 f0                	mov    %esi,%eax
  801d19:	f7 f5                	div    %ebp
  801d1b:	89 d0                	mov    %edx,%eax
  801d1d:	31 d2                	xor    %edx,%edx
  801d1f:	eb 8c                	jmp    801cad <__umoddi3+0x2d>
  801d21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d28:	89 e9                	mov    %ebp,%ecx
  801d2a:	ba 20 00 00 00       	mov    $0x20,%edx
  801d2f:	29 ea                	sub    %ebp,%edx
  801d31:	d3 e0                	shl    %cl,%eax
  801d33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d37:	89 d1                	mov    %edx,%ecx
  801d39:	89 f8                	mov    %edi,%eax
  801d3b:	d3 e8                	shr    %cl,%eax
  801d3d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d41:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d45:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d49:	09 c1                	or     %eax,%ecx
  801d4b:	89 d8                	mov    %ebx,%eax
  801d4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d51:	89 e9                	mov    %ebp,%ecx
  801d53:	d3 e7                	shl    %cl,%edi
  801d55:	89 d1                	mov    %edx,%ecx
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d5f:	d3 e3                	shl    %cl,%ebx
  801d61:	89 c7                	mov    %eax,%edi
  801d63:	89 d1                	mov    %edx,%ecx
  801d65:	89 f0                	mov    %esi,%eax
  801d67:	d3 e8                	shr    %cl,%eax
  801d69:	89 e9                	mov    %ebp,%ecx
  801d6b:	89 fa                	mov    %edi,%edx
  801d6d:	d3 e6                	shl    %cl,%esi
  801d6f:	09 d8                	or     %ebx,%eax
  801d71:	f7 74 24 08          	divl   0x8(%esp)
  801d75:	89 d1                	mov    %edx,%ecx
  801d77:	89 f3                	mov    %esi,%ebx
  801d79:	f7 64 24 0c          	mull   0xc(%esp)
  801d7d:	89 c6                	mov    %eax,%esi
  801d7f:	89 d7                	mov    %edx,%edi
  801d81:	39 d1                	cmp    %edx,%ecx
  801d83:	72 06                	jb     801d8b <__umoddi3+0x10b>
  801d85:	75 10                	jne    801d97 <__umoddi3+0x117>
  801d87:	39 c3                	cmp    %eax,%ebx
  801d89:	73 0c                	jae    801d97 <__umoddi3+0x117>
  801d8b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801d8f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801d93:	89 d7                	mov    %edx,%edi
  801d95:	89 c6                	mov    %eax,%esi
  801d97:	89 ca                	mov    %ecx,%edx
  801d99:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d9e:	29 f3                	sub    %esi,%ebx
  801da0:	19 fa                	sbb    %edi,%edx
  801da2:	89 d0                	mov    %edx,%eax
  801da4:	d3 e0                	shl    %cl,%eax
  801da6:	89 e9                	mov    %ebp,%ecx
  801da8:	d3 eb                	shr    %cl,%ebx
  801daa:	d3 ea                	shr    %cl,%edx
  801dac:	09 d8                	or     %ebx,%eax
  801dae:	83 c4 1c             	add    $0x1c,%esp
  801db1:	5b                   	pop    %ebx
  801db2:	5e                   	pop    %esi
  801db3:	5f                   	pop    %edi
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    
  801db6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dbd:	8d 76 00             	lea    0x0(%esi),%esi
  801dc0:	29 fe                	sub    %edi,%esi
  801dc2:	19 c3                	sbb    %eax,%ebx
  801dc4:	89 f2                	mov    %esi,%edx
  801dc6:	89 d9                	mov    %ebx,%ecx
  801dc8:	e9 1d ff ff ff       	jmp    801cea <__umoddi3+0x6a>
