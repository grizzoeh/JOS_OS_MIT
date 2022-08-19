
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 38 00 00 00       	call   800069 <libmain>
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
  80003a:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003d:	6a 07                	push   $0x7
  80003f:	68 00 f0 bf ee       	push   $0xeebff000
  800044:	6a 00                	push   $0x0
  800046:	e8 9e 01 00 00       	call   8001e9 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	68 20 00 10 f0       	push   $0xf0100020
  800053:	6a 00                	push   $0x0
  800055:	e8 56 02 00 00       	call   8002b0 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80005a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800061:	00 00 00 
}
  800064:	83 c4 10             	add    $0x10,%esp
  800067:	c9                   	leave  
  800068:	c3                   	ret    

00800069 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800069:	f3 0f 1e fb          	endbr32 
  80006d:	55                   	push   %ebp
  80006e:	89 e5                	mov    %esp,%ebp
  800070:	56                   	push   %esi
  800071:	53                   	push   %ebx
  800072:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800075:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800078:	e8 19 01 00 00       	call   800196 <sys_getenvid>
	if (id >= 0)
  80007d:	85 c0                	test   %eax,%eax
  80007f:	78 12                	js     800093 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800081:	25 ff 03 00 00       	and    $0x3ff,%eax
  800086:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800089:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800093:	85 db                	test   %ebx,%ebx
  800095:	7e 07                	jle    80009e <libmain+0x35>
		binaryname = argv[0];
  800097:	8b 06                	mov    (%esi),%eax
  800099:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009e:	83 ec 08             	sub    $0x8,%esp
  8000a1:	56                   	push   %esi
  8000a2:	53                   	push   %ebx
  8000a3:	e8 8b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 0a 00 00 00       	call   8000b7 <exit>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b7:	f3 0f 1e fb          	endbr32 
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c1:	e8 53 04 00 00       	call   800519 <close_all>
	sys_env_destroy(0);
  8000c6:	83 ec 0c             	sub    $0xc,%esp
  8000c9:	6a 00                	push   $0x0
  8000cb:	e8 a0 00 00 00       	call   800170 <sys_env_destroy>
}
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	c9                   	leave  
  8000d4:	c3                   	ret    

008000d5 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	57                   	push   %edi
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	83 ec 1c             	sub    $0x1c,%esp
  8000de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000e4:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ec:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000ef:	8b 75 14             	mov    0x14(%ebp),%esi
  8000f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000f8:	74 04                	je     8000fe <syscall+0x29>
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	7f 08                	jg     800106 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800101:	5b                   	pop    %ebx
  800102:	5e                   	pop    %esi
  800103:	5f                   	pop    %edi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	ff 75 e0             	pushl  -0x20(%ebp)
  80010d:	68 0a 1e 80 00       	push   $0x801e0a
  800112:	6a 23                	push   $0x23
  800114:	68 27 1e 80 00       	push   $0x801e27
  800119:	e8 76 0f 00 00       	call   801094 <_panic>

0080011e <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  80011e:	f3 0f 1e fb          	endbr32 
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800128:	6a 00                	push   $0x0
  80012a:	6a 00                	push   $0x0
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 0c             	pushl  0xc(%ebp)
  800131:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 00 00 00 00       	mov    $0x0,%eax
  80013e:	e8 92 ff ff ff       	call   8000d5 <syscall>
}
  800143:	83 c4 10             	add    $0x10,%esp
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <sys_cgetc>:

int
sys_cgetc(void)
{
  800148:	f3 0f 1e fb          	endbr32 
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800152:	6a 00                	push   $0x0
  800154:	6a 00                	push   $0x0
  800156:	6a 00                	push   $0x0
  800158:	6a 00                	push   $0x0
  80015a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	b8 01 00 00 00       	mov    $0x1,%eax
  800169:	e8 67 ff ff ff       	call   8000d5 <syscall>
}
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800170:	f3 0f 1e fb          	endbr32 
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80017a:	6a 00                	push   $0x0
  80017c:	6a 00                	push   $0x0
  80017e:	6a 00                	push   $0x0
  800180:	6a 00                	push   $0x0
  800182:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800185:	ba 01 00 00 00       	mov    $0x1,%edx
  80018a:	b8 03 00 00 00       	mov    $0x3,%eax
  80018f:	e8 41 ff ff ff       	call   8000d5 <syscall>
}
  800194:	c9                   	leave  
  800195:	c3                   	ret    

00800196 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800196:	f3 0f 1e fb          	endbr32 
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001a0:	6a 00                	push   $0x0
  8001a2:	6a 00                	push   $0x0
  8001a4:	6a 00                	push   $0x0
  8001a6:	6a 00                	push   $0x0
  8001a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b2:	b8 02 00 00 00       	mov    $0x2,%eax
  8001b7:	e8 19 ff ff ff       	call   8000d5 <syscall>
}
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <sys_yield>:

void
sys_yield(void)
{
  8001be:	f3 0f 1e fb          	endbr32 
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001c8:	6a 00                	push   $0x0
  8001ca:	6a 00                	push   $0x0
  8001cc:	6a 00                	push   $0x0
  8001ce:	6a 00                	push   $0x0
  8001d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001da:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001df:	e8 f1 fe ff ff       	call   8000d5 <syscall>
}
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    

008001e9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001e9:	f3 0f 1e fb          	endbr32 
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001f3:	6a 00                	push   $0x0
  8001f5:	6a 00                	push   $0x0
  8001f7:	ff 75 10             	pushl  0x10(%ebp)
  8001fa:	ff 75 0c             	pushl  0xc(%ebp)
  8001fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800200:	ba 01 00 00 00       	mov    $0x1,%edx
  800205:	b8 04 00 00 00       	mov    $0x4,%eax
  80020a:	e8 c6 fe ff ff       	call   8000d5 <syscall>
}
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800211:	f3 0f 1e fb          	endbr32 
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80021b:	ff 75 18             	pushl  0x18(%ebp)
  80021e:	ff 75 14             	pushl  0x14(%ebp)
  800221:	ff 75 10             	pushl  0x10(%ebp)
  800224:	ff 75 0c             	pushl  0xc(%ebp)
  800227:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80022a:	ba 01 00 00 00       	mov    $0x1,%edx
  80022f:	b8 05 00 00 00       	mov    $0x5,%eax
  800234:	e8 9c fe ff ff       	call   8000d5 <syscall>
}
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80023b:	f3 0f 1e fb          	endbr32 
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800245:	6a 00                	push   $0x0
  800247:	6a 00                	push   $0x0
  800249:	6a 00                	push   $0x0
  80024b:	ff 75 0c             	pushl  0xc(%ebp)
  80024e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800251:	ba 01 00 00 00       	mov    $0x1,%edx
  800256:	b8 06 00 00 00       	mov    $0x6,%eax
  80025b:	e8 75 fe ff ff       	call   8000d5 <syscall>
}
  800260:	c9                   	leave  
  800261:	c3                   	ret    

00800262 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800262:	f3 0f 1e fb          	endbr32 
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80026c:	6a 00                	push   $0x0
  80026e:	6a 00                	push   $0x0
  800270:	6a 00                	push   $0x0
  800272:	ff 75 0c             	pushl  0xc(%ebp)
  800275:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800278:	ba 01 00 00 00       	mov    $0x1,%edx
  80027d:	b8 08 00 00 00       	mov    $0x8,%eax
  800282:	e8 4e fe ff ff       	call   8000d5 <syscall>
}
  800287:	c9                   	leave  
  800288:	c3                   	ret    

00800289 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800289:	f3 0f 1e fb          	endbr32 
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800293:	6a 00                	push   $0x0
  800295:	6a 00                	push   $0x0
  800297:	6a 00                	push   $0x0
  800299:	ff 75 0c             	pushl  0xc(%ebp)
  80029c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029f:	ba 01 00 00 00       	mov    $0x1,%edx
  8002a4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a9:	e8 27 fe ff ff       	call   8000d5 <syscall>
}
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b0:	f3 0f 1e fb          	endbr32 
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8002ba:	6a 00                	push   $0x0
  8002bc:	6a 00                	push   $0x0
  8002be:	6a 00                	push   $0x0
  8002c0:	ff 75 0c             	pushl  0xc(%ebp)
  8002c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c6:	ba 01 00 00 00       	mov    $0x1,%edx
  8002cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002d0:	e8 00 fe ff ff       	call   8000d5 <syscall>
}
  8002d5:	c9                   	leave  
  8002d6:	c3                   	ret    

008002d7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002d7:	f3 0f 1e fb          	endbr32 
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002e1:	6a 00                	push   $0x0
  8002e3:	ff 75 14             	pushl  0x14(%ebp)
  8002e6:	ff 75 10             	pushl  0x10(%ebp)
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f9:	e8 d7 fd ff ff       	call   8000d5 <syscall>
}
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800300:	f3 0f 1e fb          	endbr32 
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80030a:	6a 00                	push   $0x0
  80030c:	6a 00                	push   $0x0
  80030e:	6a 00                	push   $0x0
  800310:	6a 00                	push   $0x0
  800312:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800315:	ba 01 00 00 00       	mov    $0x1,%edx
  80031a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031f:	e8 b1 fd ff ff       	call   8000d5 <syscall>
}
  800324:	c9                   	leave  
  800325:	c3                   	ret    

00800326 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800326:	f3 0f 1e fb          	endbr32 
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
  800330:	05 00 00 00 30       	add    $0x30000000,%eax
  800335:	c1 e8 0c             	shr    $0xc,%eax
}
  800338:	5d                   	pop    %ebp
  800339:	c3                   	ret    

0080033a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80033a:	f3 0f 1e fb          	endbr32 
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800344:	ff 75 08             	pushl  0x8(%ebp)
  800347:	e8 da ff ff ff       	call   800326 <fd2num>
  80034c:	83 c4 10             	add    $0x10,%esp
  80034f:	c1 e0 0c             	shl    $0xc,%eax
  800352:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800357:	c9                   	leave  
  800358:	c3                   	ret    

00800359 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800359:	f3 0f 1e fb          	endbr32 
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800365:	89 c2                	mov    %eax,%edx
  800367:	c1 ea 16             	shr    $0x16,%edx
  80036a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800371:	f6 c2 01             	test   $0x1,%dl
  800374:	74 2d                	je     8003a3 <fd_alloc+0x4a>
  800376:	89 c2                	mov    %eax,%edx
  800378:	c1 ea 0c             	shr    $0xc,%edx
  80037b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800382:	f6 c2 01             	test   $0x1,%dl
  800385:	74 1c                	je     8003a3 <fd_alloc+0x4a>
  800387:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80038c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800391:	75 d2                	jne    800365 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800393:	8b 45 08             	mov    0x8(%ebp),%eax
  800396:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80039c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003a1:	eb 0a                	jmp    8003ad <fd_alloc+0x54>
			*fd_store = fd;
  8003a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003af:	f3 0f 1e fb          	endbr32 
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003b9:	83 f8 1f             	cmp    $0x1f,%eax
  8003bc:	77 30                	ja     8003ee <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003be:	c1 e0 0c             	shl    $0xc,%eax
  8003c1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003c6:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003cc:	f6 c2 01             	test   $0x1,%dl
  8003cf:	74 24                	je     8003f5 <fd_lookup+0x46>
  8003d1:	89 c2                	mov    %eax,%edx
  8003d3:	c1 ea 0c             	shr    $0xc,%edx
  8003d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003dd:	f6 c2 01             	test   $0x1,%dl
  8003e0:	74 1a                	je     8003fc <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e5:	89 02                	mov    %eax,(%edx)
	return 0;
  8003e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    
		return -E_INVAL;
  8003ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003f3:	eb f7                	jmp    8003ec <fd_lookup+0x3d>
		return -E_INVAL;
  8003f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003fa:	eb f0                	jmp    8003ec <fd_lookup+0x3d>
  8003fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800401:	eb e9                	jmp    8003ec <fd_lookup+0x3d>

00800403 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800403:	f3 0f 1e fb          	endbr32 
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	83 ec 08             	sub    $0x8,%esp
  80040d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800410:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800415:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80041a:	39 08                	cmp    %ecx,(%eax)
  80041c:	74 33                	je     800451 <dev_lookup+0x4e>
  80041e:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800421:	8b 02                	mov    (%edx),%eax
  800423:	85 c0                	test   %eax,%eax
  800425:	75 f3                	jne    80041a <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800427:	a1 04 40 80 00       	mov    0x804004,%eax
  80042c:	8b 40 48             	mov    0x48(%eax),%eax
  80042f:	83 ec 04             	sub    $0x4,%esp
  800432:	51                   	push   %ecx
  800433:	50                   	push   %eax
  800434:	68 38 1e 80 00       	push   $0x801e38
  800439:	e8 3d 0d 00 00       	call   80117b <cprintf>
	*dev = 0;
  80043e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800441:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800447:	83 c4 10             	add    $0x10,%esp
  80044a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80044f:	c9                   	leave  
  800450:	c3                   	ret    
			*dev = devtab[i];
  800451:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800454:	89 01                	mov    %eax,(%ecx)
			return 0;
  800456:	b8 00 00 00 00       	mov    $0x0,%eax
  80045b:	eb f2                	jmp    80044f <dev_lookup+0x4c>

0080045d <fd_close>:
{
  80045d:	f3 0f 1e fb          	endbr32 
  800461:	55                   	push   %ebp
  800462:	89 e5                	mov    %esp,%ebp
  800464:	57                   	push   %edi
  800465:	56                   	push   %esi
  800466:	53                   	push   %ebx
  800467:	83 ec 28             	sub    $0x28,%esp
  80046a:	8b 75 08             	mov    0x8(%ebp),%esi
  80046d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800470:	56                   	push   %esi
  800471:	e8 b0 fe ff ff       	call   800326 <fd2num>
  800476:	83 c4 08             	add    $0x8,%esp
  800479:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80047c:	52                   	push   %edx
  80047d:	50                   	push   %eax
  80047e:	e8 2c ff ff ff       	call   8003af <fd_lookup>
  800483:	89 c3                	mov    %eax,%ebx
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	85 c0                	test   %eax,%eax
  80048a:	78 05                	js     800491 <fd_close+0x34>
	    || fd != fd2)
  80048c:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80048f:	74 16                	je     8004a7 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800491:	89 f8                	mov    %edi,%eax
  800493:	84 c0                	test   %al,%al
  800495:	b8 00 00 00 00       	mov    $0x0,%eax
  80049a:	0f 44 d8             	cmove  %eax,%ebx
}
  80049d:	89 d8                	mov    %ebx,%eax
  80049f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a2:	5b                   	pop    %ebx
  8004a3:	5e                   	pop    %esi
  8004a4:	5f                   	pop    %edi
  8004a5:	5d                   	pop    %ebp
  8004a6:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004ad:	50                   	push   %eax
  8004ae:	ff 36                	pushl  (%esi)
  8004b0:	e8 4e ff ff ff       	call   800403 <dev_lookup>
  8004b5:	89 c3                	mov    %eax,%ebx
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	78 1a                	js     8004d8 <fd_close+0x7b>
		if (dev->dev_close)
  8004be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c1:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004c4:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	74 0b                	je     8004d8 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004cd:	83 ec 0c             	sub    $0xc,%esp
  8004d0:	56                   	push   %esi
  8004d1:	ff d0                	call   *%eax
  8004d3:	89 c3                	mov    %eax,%ebx
  8004d5:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	56                   	push   %esi
  8004dc:	6a 00                	push   $0x0
  8004de:	e8 58 fd ff ff       	call   80023b <sys_page_unmap>
	return r;
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	eb b5                	jmp    80049d <fd_close+0x40>

008004e8 <close>:

int
close(int fdnum)
{
  8004e8:	f3 0f 1e fb          	endbr32 
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f5:	50                   	push   %eax
  8004f6:	ff 75 08             	pushl  0x8(%ebp)
  8004f9:	e8 b1 fe ff ff       	call   8003af <fd_lookup>
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	85 c0                	test   %eax,%eax
  800503:	79 02                	jns    800507 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800505:	c9                   	leave  
  800506:	c3                   	ret    
		return fd_close(fd, 1);
  800507:	83 ec 08             	sub    $0x8,%esp
  80050a:	6a 01                	push   $0x1
  80050c:	ff 75 f4             	pushl  -0xc(%ebp)
  80050f:	e8 49 ff ff ff       	call   80045d <fd_close>
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	eb ec                	jmp    800505 <close+0x1d>

00800519 <close_all>:

void
close_all(void)
{
  800519:	f3 0f 1e fb          	endbr32 
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	53                   	push   %ebx
  800521:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800524:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800529:	83 ec 0c             	sub    $0xc,%esp
  80052c:	53                   	push   %ebx
  80052d:	e8 b6 ff ff ff       	call   8004e8 <close>
	for (i = 0; i < MAXFD; i++)
  800532:	83 c3 01             	add    $0x1,%ebx
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	83 fb 20             	cmp    $0x20,%ebx
  80053b:	75 ec                	jne    800529 <close_all+0x10>
}
  80053d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800540:	c9                   	leave  
  800541:	c3                   	ret    

00800542 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800542:	f3 0f 1e fb          	endbr32 
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  800549:	57                   	push   %edi
  80054a:	56                   	push   %esi
  80054b:	53                   	push   %ebx
  80054c:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800552:	50                   	push   %eax
  800553:	ff 75 08             	pushl  0x8(%ebp)
  800556:	e8 54 fe ff ff       	call   8003af <fd_lookup>
  80055b:	89 c3                	mov    %eax,%ebx
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	0f 88 81 00 00 00    	js     8005e9 <dup+0xa7>
		return r;
	close(newfdnum);
  800568:	83 ec 0c             	sub    $0xc,%esp
  80056b:	ff 75 0c             	pushl  0xc(%ebp)
  80056e:	e8 75 ff ff ff       	call   8004e8 <close>

	newfd = INDEX2FD(newfdnum);
  800573:	8b 75 0c             	mov    0xc(%ebp),%esi
  800576:	c1 e6 0c             	shl    $0xc,%esi
  800579:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80057f:	83 c4 04             	add    $0x4,%esp
  800582:	ff 75 e4             	pushl  -0x1c(%ebp)
  800585:	e8 b0 fd ff ff       	call   80033a <fd2data>
  80058a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80058c:	89 34 24             	mov    %esi,(%esp)
  80058f:	e8 a6 fd ff ff       	call   80033a <fd2data>
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800599:	89 d8                	mov    %ebx,%eax
  80059b:	c1 e8 16             	shr    $0x16,%eax
  80059e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a5:	a8 01                	test   $0x1,%al
  8005a7:	74 11                	je     8005ba <dup+0x78>
  8005a9:	89 d8                	mov    %ebx,%eax
  8005ab:	c1 e8 0c             	shr    $0xc,%eax
  8005ae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b5:	f6 c2 01             	test   $0x1,%dl
  8005b8:	75 39                	jne    8005f3 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005bd:	89 d0                	mov    %edx,%eax
  8005bf:	c1 e8 0c             	shr    $0xc,%eax
  8005c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c9:	83 ec 0c             	sub    $0xc,%esp
  8005cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d1:	50                   	push   %eax
  8005d2:	56                   	push   %esi
  8005d3:	6a 00                	push   $0x0
  8005d5:	52                   	push   %edx
  8005d6:	6a 00                	push   $0x0
  8005d8:	e8 34 fc ff ff       	call   800211 <sys_page_map>
  8005dd:	89 c3                	mov    %eax,%ebx
  8005df:	83 c4 20             	add    $0x20,%esp
  8005e2:	85 c0                	test   %eax,%eax
  8005e4:	78 31                	js     800617 <dup+0xd5>
		goto err;

	return newfdnum;
  8005e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005e9:	89 d8                	mov    %ebx,%eax
  8005eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005ee:	5b                   	pop    %ebx
  8005ef:	5e                   	pop    %esi
  8005f0:	5f                   	pop    %edi
  8005f1:	5d                   	pop    %ebp
  8005f2:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fa:	83 ec 0c             	sub    $0xc,%esp
  8005fd:	25 07 0e 00 00       	and    $0xe07,%eax
  800602:	50                   	push   %eax
  800603:	57                   	push   %edi
  800604:	6a 00                	push   $0x0
  800606:	53                   	push   %ebx
  800607:	6a 00                	push   $0x0
  800609:	e8 03 fc ff ff       	call   800211 <sys_page_map>
  80060e:	89 c3                	mov    %eax,%ebx
  800610:	83 c4 20             	add    $0x20,%esp
  800613:	85 c0                	test   %eax,%eax
  800615:	79 a3                	jns    8005ba <dup+0x78>
	sys_page_unmap(0, newfd);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	56                   	push   %esi
  80061b:	6a 00                	push   $0x0
  80061d:	e8 19 fc ff ff       	call   80023b <sys_page_unmap>
	sys_page_unmap(0, nva);
  800622:	83 c4 08             	add    $0x8,%esp
  800625:	57                   	push   %edi
  800626:	6a 00                	push   $0x0
  800628:	e8 0e fc ff ff       	call   80023b <sys_page_unmap>
	return r;
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	eb b7                	jmp    8005e9 <dup+0xa7>

00800632 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800632:	f3 0f 1e fb          	endbr32 
  800636:	55                   	push   %ebp
  800637:	89 e5                	mov    %esp,%ebp
  800639:	53                   	push   %ebx
  80063a:	83 ec 1c             	sub    $0x1c,%esp
  80063d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800640:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800643:	50                   	push   %eax
  800644:	53                   	push   %ebx
  800645:	e8 65 fd ff ff       	call   8003af <fd_lookup>
  80064a:	83 c4 10             	add    $0x10,%esp
  80064d:	85 c0                	test   %eax,%eax
  80064f:	78 3f                	js     800690 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800657:	50                   	push   %eax
  800658:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065b:	ff 30                	pushl  (%eax)
  80065d:	e8 a1 fd ff ff       	call   800403 <dev_lookup>
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	85 c0                	test   %eax,%eax
  800667:	78 27                	js     800690 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800669:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066c:	8b 42 08             	mov    0x8(%edx),%eax
  80066f:	83 e0 03             	and    $0x3,%eax
  800672:	83 f8 01             	cmp    $0x1,%eax
  800675:	74 1e                	je     800695 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800677:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80067a:	8b 40 08             	mov    0x8(%eax),%eax
  80067d:	85 c0                	test   %eax,%eax
  80067f:	74 35                	je     8006b6 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800681:	83 ec 04             	sub    $0x4,%esp
  800684:	ff 75 10             	pushl  0x10(%ebp)
  800687:	ff 75 0c             	pushl  0xc(%ebp)
  80068a:	52                   	push   %edx
  80068b:	ff d0                	call   *%eax
  80068d:	83 c4 10             	add    $0x10,%esp
}
  800690:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800693:	c9                   	leave  
  800694:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800695:	a1 04 40 80 00       	mov    0x804004,%eax
  80069a:	8b 40 48             	mov    0x48(%eax),%eax
  80069d:	83 ec 04             	sub    $0x4,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	50                   	push   %eax
  8006a2:	68 79 1e 80 00       	push   $0x801e79
  8006a7:	e8 cf 0a 00 00       	call   80117b <cprintf>
		return -E_INVAL;
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b4:	eb da                	jmp    800690 <read+0x5e>
		return -E_NOT_SUPP;
  8006b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006bb:	eb d3                	jmp    800690 <read+0x5e>

008006bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006bd:	f3 0f 1e fb          	endbr32 
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	57                   	push   %edi
  8006c5:	56                   	push   %esi
  8006c6:	53                   	push   %ebx
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d5:	eb 02                	jmp    8006d9 <readn+0x1c>
  8006d7:	01 c3                	add    %eax,%ebx
  8006d9:	39 f3                	cmp    %esi,%ebx
  8006db:	73 21                	jae    8006fe <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006dd:	83 ec 04             	sub    $0x4,%esp
  8006e0:	89 f0                	mov    %esi,%eax
  8006e2:	29 d8                	sub    %ebx,%eax
  8006e4:	50                   	push   %eax
  8006e5:	89 d8                	mov    %ebx,%eax
  8006e7:	03 45 0c             	add    0xc(%ebp),%eax
  8006ea:	50                   	push   %eax
  8006eb:	57                   	push   %edi
  8006ec:	e8 41 ff ff ff       	call   800632 <read>
		if (m < 0)
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	85 c0                	test   %eax,%eax
  8006f6:	78 04                	js     8006fc <readn+0x3f>
			return m;
		if (m == 0)
  8006f8:	75 dd                	jne    8006d7 <readn+0x1a>
  8006fa:	eb 02                	jmp    8006fe <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006fc:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006fe:	89 d8                	mov    %ebx,%eax
  800700:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800703:	5b                   	pop    %ebx
  800704:	5e                   	pop    %esi
  800705:	5f                   	pop    %edi
  800706:	5d                   	pop    %ebp
  800707:	c3                   	ret    

00800708 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800708:	f3 0f 1e fb          	endbr32 
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	53                   	push   %ebx
  800710:	83 ec 1c             	sub    $0x1c,%esp
  800713:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800716:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800719:	50                   	push   %eax
  80071a:	53                   	push   %ebx
  80071b:	e8 8f fc ff ff       	call   8003af <fd_lookup>
  800720:	83 c4 10             	add    $0x10,%esp
  800723:	85 c0                	test   %eax,%eax
  800725:	78 3a                	js     800761 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	ff 30                	pushl  (%eax)
  800733:	e8 cb fc ff ff       	call   800403 <dev_lookup>
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 22                	js     800761 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800746:	74 1e                	je     800766 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800748:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80074b:	8b 52 0c             	mov    0xc(%edx),%edx
  80074e:	85 d2                	test   %edx,%edx
  800750:	74 35                	je     800787 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800752:	83 ec 04             	sub    $0x4,%esp
  800755:	ff 75 10             	pushl  0x10(%ebp)
  800758:	ff 75 0c             	pushl  0xc(%ebp)
  80075b:	50                   	push   %eax
  80075c:	ff d2                	call   *%edx
  80075e:	83 c4 10             	add    $0x10,%esp
}
  800761:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800764:	c9                   	leave  
  800765:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800766:	a1 04 40 80 00       	mov    0x804004,%eax
  80076b:	8b 40 48             	mov    0x48(%eax),%eax
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	53                   	push   %ebx
  800772:	50                   	push   %eax
  800773:	68 95 1e 80 00       	push   $0x801e95
  800778:	e8 fe 09 00 00       	call   80117b <cprintf>
		return -E_INVAL;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800785:	eb da                	jmp    800761 <write+0x59>
		return -E_NOT_SUPP;
  800787:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80078c:	eb d3                	jmp    800761 <write+0x59>

0080078e <seek>:

int
seek(int fdnum, off_t offset)
{
  80078e:	f3 0f 1e fb          	endbr32 
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800798:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80079b:	50                   	push   %eax
  80079c:	ff 75 08             	pushl  0x8(%ebp)
  80079f:	e8 0b fc ff ff       	call   8003af <fd_lookup>
  8007a4:	83 c4 10             	add    $0x10,%esp
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	78 0e                	js     8007b9 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bb:	f3 0f 1e fb          	endbr32 
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	83 ec 1c             	sub    $0x1c,%esp
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	53                   	push   %ebx
  8007ce:	e8 dc fb ff ff       	call   8003af <fd_lookup>
  8007d3:	83 c4 10             	add    $0x10,%esp
  8007d6:	85 c0                	test   %eax,%eax
  8007d8:	78 37                	js     800811 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007da:	83 ec 08             	sub    $0x8,%esp
  8007dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e0:	50                   	push   %eax
  8007e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e4:	ff 30                	pushl  (%eax)
  8007e6:	e8 18 fc ff ff       	call   800403 <dev_lookup>
  8007eb:	83 c4 10             	add    $0x10,%esp
  8007ee:	85 c0                	test   %eax,%eax
  8007f0:	78 1f                	js     800811 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f9:	74 1b                	je     800816 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007fe:	8b 52 18             	mov    0x18(%edx),%edx
  800801:	85 d2                	test   %edx,%edx
  800803:	74 32                	je     800837 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800805:	83 ec 08             	sub    $0x8,%esp
  800808:	ff 75 0c             	pushl  0xc(%ebp)
  80080b:	50                   	push   %eax
  80080c:	ff d2                	call   *%edx
  80080e:	83 c4 10             	add    $0x10,%esp
}
  800811:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800814:	c9                   	leave  
  800815:	c3                   	ret    
			thisenv->env_id, fdnum);
  800816:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80081b:	8b 40 48             	mov    0x48(%eax),%eax
  80081e:	83 ec 04             	sub    $0x4,%esp
  800821:	53                   	push   %ebx
  800822:	50                   	push   %eax
  800823:	68 58 1e 80 00       	push   $0x801e58
  800828:	e8 4e 09 00 00       	call   80117b <cprintf>
		return -E_INVAL;
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800835:	eb da                	jmp    800811 <ftruncate+0x56>
		return -E_NOT_SUPP;
  800837:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80083c:	eb d3                	jmp    800811 <ftruncate+0x56>

0080083e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083e:	f3 0f 1e fb          	endbr32 
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	53                   	push   %ebx
  800846:	83 ec 1c             	sub    $0x1c,%esp
  800849:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80084c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084f:	50                   	push   %eax
  800850:	ff 75 08             	pushl  0x8(%ebp)
  800853:	e8 57 fb ff ff       	call   8003af <fd_lookup>
  800858:	83 c4 10             	add    $0x10,%esp
  80085b:	85 c0                	test   %eax,%eax
  80085d:	78 4b                	js     8008aa <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085f:	83 ec 08             	sub    $0x8,%esp
  800862:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800865:	50                   	push   %eax
  800866:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800869:	ff 30                	pushl  (%eax)
  80086b:	e8 93 fb ff ff       	call   800403 <dev_lookup>
  800870:	83 c4 10             	add    $0x10,%esp
  800873:	85 c0                	test   %eax,%eax
  800875:	78 33                	js     8008aa <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800877:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80087e:	74 2f                	je     8008af <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800880:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800883:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80088a:	00 00 00 
	stat->st_isdir = 0;
  80088d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800894:	00 00 00 
	stat->st_dev = dev;
  800897:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80089d:	83 ec 08             	sub    $0x8,%esp
  8008a0:	53                   	push   %ebx
  8008a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a4:	ff 50 14             	call   *0x14(%eax)
  8008a7:	83 c4 10             	add    $0x10,%esp
}
  8008aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ad:	c9                   	leave  
  8008ae:	c3                   	ret    
		return -E_NOT_SUPP;
  8008af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008b4:	eb f4                	jmp    8008aa <fstat+0x6c>

008008b6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b6:	f3 0f 1e fb          	endbr32 
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	56                   	push   %esi
  8008be:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008bf:	83 ec 08             	sub    $0x8,%esp
  8008c2:	6a 00                	push   $0x0
  8008c4:	ff 75 08             	pushl  0x8(%ebp)
  8008c7:	e8 20 02 00 00       	call   800aec <open>
  8008cc:	89 c3                	mov    %eax,%ebx
  8008ce:	83 c4 10             	add    $0x10,%esp
  8008d1:	85 c0                	test   %eax,%eax
  8008d3:	78 1b                	js     8008f0 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008d5:	83 ec 08             	sub    $0x8,%esp
  8008d8:	ff 75 0c             	pushl  0xc(%ebp)
  8008db:	50                   	push   %eax
  8008dc:	e8 5d ff ff ff       	call   80083e <fstat>
  8008e1:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e3:	89 1c 24             	mov    %ebx,(%esp)
  8008e6:	e8 fd fb ff ff       	call   8004e8 <close>
	return r;
  8008eb:	83 c4 10             	add    $0x10,%esp
  8008ee:	89 f3                	mov    %esi,%ebx
}
  8008f0:	89 d8                	mov    %ebx,%eax
  8008f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f5:	5b                   	pop    %ebx
  8008f6:	5e                   	pop    %esi
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	56                   	push   %esi
  8008fd:	53                   	push   %ebx
  8008fe:	89 c6                	mov    %eax,%esi
  800900:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800902:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800909:	74 27                	je     800932 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80090b:	6a 07                	push   $0x7
  80090d:	68 00 50 80 00       	push   $0x805000
  800912:	56                   	push   %esi
  800913:	ff 35 00 40 80 00    	pushl  0x804000
  800919:	e8 a8 11 00 00       	call   801ac6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80091e:	83 c4 0c             	add    $0xc,%esp
  800921:	6a 00                	push   $0x0
  800923:	53                   	push   %ebx
  800924:	6a 00                	push   $0x0
  800926:	e8 2e 11 00 00       	call   801a59 <ipc_recv>
}
  80092b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80092e:	5b                   	pop    %ebx
  80092f:	5e                   	pop    %esi
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800932:	83 ec 0c             	sub    $0xc,%esp
  800935:	6a 01                	push   $0x1
  800937:	e8 dd 11 00 00       	call   801b19 <ipc_find_env>
  80093c:	a3 00 40 80 00       	mov    %eax,0x804000
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	eb c5                	jmp    80090b <fsipc+0x12>

00800946 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800946:	f3 0f 1e fb          	endbr32 
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 40 0c             	mov    0xc(%eax),%eax
  800956:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800963:	ba 00 00 00 00       	mov    $0x0,%edx
  800968:	b8 02 00 00 00       	mov    $0x2,%eax
  80096d:	e8 87 ff ff ff       	call   8008f9 <fsipc>
}
  800972:	c9                   	leave  
  800973:	c3                   	ret    

00800974 <devfile_flush>:
{
  800974:	f3 0f 1e fb          	endbr32 
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 40 0c             	mov    0xc(%eax),%eax
  800984:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 06 00 00 00       	mov    $0x6,%eax
  800993:	e8 61 ff ff ff       	call   8008f9 <fsipc>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <devfile_stat>:
{
  80099a:	f3 0f 1e fb          	endbr32 
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	53                   	push   %ebx
  8009a2:	83 ec 04             	sub    $0x4,%esp
  8009a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ae:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8009bd:	e8 37 ff ff ff       	call   8008f9 <fsipc>
  8009c2:	85 c0                	test   %eax,%eax
  8009c4:	78 2c                	js     8009f2 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c6:	83 ec 08             	sub    $0x8,%esp
  8009c9:	68 00 50 80 00       	push   $0x805000
  8009ce:	53                   	push   %ebx
  8009cf:	e8 11 0d 00 00       	call   8016e5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d4:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009df:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ea:	83 c4 10             	add    $0x10,%esp
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <devfile_write>:
{
  8009f7:	f3 0f 1e fb          	endbr32 
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	57                   	push   %edi
  8009ff:	56                   	push   %esi
  800a00:	53                   	push   %ebx
  800a01:	83 ec 0c             	sub    $0xc,%esp
  800a04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a10:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a1a:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  800a1f:	85 db                	test   %ebx,%ebx
  800a21:	74 3b                	je     800a5e <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a23:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800a29:	89 f8                	mov    %edi,%eax
  800a2b:	0f 46 c3             	cmovbe %ebx,%eax
  800a2e:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  800a33:	83 ec 04             	sub    $0x4,%esp
  800a36:	50                   	push   %eax
  800a37:	56                   	push   %esi
  800a38:	68 08 50 80 00       	push   $0x805008
  800a3d:	e8 5b 0e 00 00       	call   80189d <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800a42:	ba 00 00 00 00       	mov    $0x0,%edx
  800a47:	b8 04 00 00 00       	mov    $0x4,%eax
  800a4c:	e8 a8 fe ff ff       	call   8008f9 <fsipc>
  800a51:	83 c4 10             	add    $0x10,%esp
  800a54:	85 c0                	test   %eax,%eax
  800a56:	78 06                	js     800a5e <devfile_write+0x67>
		buf_aux += r;
  800a58:	01 c6                	add    %eax,%esi
		n -= r;
  800a5a:	29 c3                	sub    %eax,%ebx
  800a5c:	eb c1                	jmp    800a1f <devfile_write+0x28>
}
  800a5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5f                   	pop    %edi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <devfile_read>:
{
  800a66:	f3 0f 1e fb          	endbr32 
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	8b 40 0c             	mov    0xc(%eax),%eax
  800a78:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a7d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a83:	ba 00 00 00 00       	mov    $0x0,%edx
  800a88:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8d:	e8 67 fe ff ff       	call   8008f9 <fsipc>
  800a92:	89 c3                	mov    %eax,%ebx
  800a94:	85 c0                	test   %eax,%eax
  800a96:	78 1f                	js     800ab7 <devfile_read+0x51>
	assert(r <= n);
  800a98:	39 f0                	cmp    %esi,%eax
  800a9a:	77 24                	ja     800ac0 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a9c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa1:	7f 33                	jg     800ad6 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa3:	83 ec 04             	sub    $0x4,%esp
  800aa6:	50                   	push   %eax
  800aa7:	68 00 50 80 00       	push   $0x805000
  800aac:	ff 75 0c             	pushl  0xc(%ebp)
  800aaf:	e8 e9 0d 00 00       	call   80189d <memmove>
	return r;
  800ab4:	83 c4 10             	add    $0x10,%esp
}
  800ab7:	89 d8                	mov    %ebx,%eax
  800ab9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    
	assert(r <= n);
  800ac0:	68 c4 1e 80 00       	push   $0x801ec4
  800ac5:	68 cb 1e 80 00       	push   $0x801ecb
  800aca:	6a 7c                	push   $0x7c
  800acc:	68 e0 1e 80 00       	push   $0x801ee0
  800ad1:	e8 be 05 00 00       	call   801094 <_panic>
	assert(r <= PGSIZE);
  800ad6:	68 eb 1e 80 00       	push   $0x801eeb
  800adb:	68 cb 1e 80 00       	push   $0x801ecb
  800ae0:	6a 7d                	push   $0x7d
  800ae2:	68 e0 1e 80 00       	push   $0x801ee0
  800ae7:	e8 a8 05 00 00       	call   801094 <_panic>

00800aec <open>:
{
  800aec:	f3 0f 1e fb          	endbr32 
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
  800af5:	83 ec 1c             	sub    $0x1c,%esp
  800af8:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800afb:	56                   	push   %esi
  800afc:	e8 a1 0b 00 00       	call   8016a2 <strlen>
  800b01:	83 c4 10             	add    $0x10,%esp
  800b04:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b09:	7f 6c                	jg     800b77 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b0b:	83 ec 0c             	sub    $0xc,%esp
  800b0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b11:	50                   	push   %eax
  800b12:	e8 42 f8 ff ff       	call   800359 <fd_alloc>
  800b17:	89 c3                	mov    %eax,%ebx
  800b19:	83 c4 10             	add    $0x10,%esp
  800b1c:	85 c0                	test   %eax,%eax
  800b1e:	78 3c                	js     800b5c <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b20:	83 ec 08             	sub    $0x8,%esp
  800b23:	56                   	push   %esi
  800b24:	68 00 50 80 00       	push   $0x805000
  800b29:	e8 b7 0b 00 00       	call   8016e5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b31:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b36:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b39:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3e:	e8 b6 fd ff ff       	call   8008f9 <fsipc>
  800b43:	89 c3                	mov    %eax,%ebx
  800b45:	83 c4 10             	add    $0x10,%esp
  800b48:	85 c0                	test   %eax,%eax
  800b4a:	78 19                	js     800b65 <open+0x79>
	return fd2num(fd);
  800b4c:	83 ec 0c             	sub    $0xc,%esp
  800b4f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b52:	e8 cf f7 ff ff       	call   800326 <fd2num>
  800b57:	89 c3                	mov    %eax,%ebx
  800b59:	83 c4 10             	add    $0x10,%esp
}
  800b5c:	89 d8                	mov    %ebx,%eax
  800b5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    
		fd_close(fd, 0);
  800b65:	83 ec 08             	sub    $0x8,%esp
  800b68:	6a 00                	push   $0x0
  800b6a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6d:	e8 eb f8 ff ff       	call   80045d <fd_close>
		return r;
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	eb e5                	jmp    800b5c <open+0x70>
		return -E_BAD_PATH;
  800b77:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b7c:	eb de                	jmp    800b5c <open+0x70>

00800b7e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b7e:	f3 0f 1e fb          	endbr32 
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800b92:	e8 62 fd ff ff       	call   8008f9 <fsipc>
}
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    

00800b99 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b99:	f3 0f 1e fb          	endbr32 
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	ff 75 08             	pushl  0x8(%ebp)
  800bab:	e8 8a f7 ff ff       	call   80033a <fd2data>
  800bb0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bb2:	83 c4 08             	add    $0x8,%esp
  800bb5:	68 f7 1e 80 00       	push   $0x801ef7
  800bba:	53                   	push   %ebx
  800bbb:	e8 25 0b 00 00       	call   8016e5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bc0:	8b 46 04             	mov    0x4(%esi),%eax
  800bc3:	2b 06                	sub    (%esi),%eax
  800bc5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bcb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bd2:	00 00 00 
	stat->st_dev = &devpipe;
  800bd5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bdc:	30 80 00 
	return 0;
}
  800bdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800be4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800beb:	f3 0f 1e fb          	endbr32 
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	53                   	push   %ebx
  800bf3:	83 ec 0c             	sub    $0xc,%esp
  800bf6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bf9:	53                   	push   %ebx
  800bfa:	6a 00                	push   $0x0
  800bfc:	e8 3a f6 ff ff       	call   80023b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c01:	89 1c 24             	mov    %ebx,(%esp)
  800c04:	e8 31 f7 ff ff       	call   80033a <fd2data>
  800c09:	83 c4 08             	add    $0x8,%esp
  800c0c:	50                   	push   %eax
  800c0d:	6a 00                	push   $0x0
  800c0f:	e8 27 f6 ff ff       	call   80023b <sys_page_unmap>
}
  800c14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c17:	c9                   	leave  
  800c18:	c3                   	ret    

00800c19 <_pipeisclosed>:
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
  800c1f:	83 ec 1c             	sub    $0x1c,%esp
  800c22:	89 c7                	mov    %eax,%edi
  800c24:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c26:	a1 04 40 80 00       	mov    0x804004,%eax
  800c2b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c2e:	83 ec 0c             	sub    $0xc,%esp
  800c31:	57                   	push   %edi
  800c32:	e8 1f 0f 00 00       	call   801b56 <pageref>
  800c37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c3a:	89 34 24             	mov    %esi,(%esp)
  800c3d:	e8 14 0f 00 00       	call   801b56 <pageref>
		nn = thisenv->env_runs;
  800c42:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c48:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c4b:	83 c4 10             	add    $0x10,%esp
  800c4e:	39 cb                	cmp    %ecx,%ebx
  800c50:	74 1b                	je     800c6d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c52:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c55:	75 cf                	jne    800c26 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c57:	8b 42 58             	mov    0x58(%edx),%eax
  800c5a:	6a 01                	push   $0x1
  800c5c:	50                   	push   %eax
  800c5d:	53                   	push   %ebx
  800c5e:	68 fe 1e 80 00       	push   $0x801efe
  800c63:	e8 13 05 00 00       	call   80117b <cprintf>
  800c68:	83 c4 10             	add    $0x10,%esp
  800c6b:	eb b9                	jmp    800c26 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c6d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c70:	0f 94 c0             	sete   %al
  800c73:	0f b6 c0             	movzbl %al,%eax
}
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <devpipe_write>:
{
  800c7e:	f3 0f 1e fb          	endbr32 
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 28             	sub    $0x28,%esp
  800c8b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c8e:	56                   	push   %esi
  800c8f:	e8 a6 f6 ff ff       	call   80033a <fd2data>
  800c94:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c96:	83 c4 10             	add    $0x10,%esp
  800c99:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ca1:	74 4f                	je     800cf2 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ca3:	8b 43 04             	mov    0x4(%ebx),%eax
  800ca6:	8b 0b                	mov    (%ebx),%ecx
  800ca8:	8d 51 20             	lea    0x20(%ecx),%edx
  800cab:	39 d0                	cmp    %edx,%eax
  800cad:	72 14                	jb     800cc3 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800caf:	89 da                	mov    %ebx,%edx
  800cb1:	89 f0                	mov    %esi,%eax
  800cb3:	e8 61 ff ff ff       	call   800c19 <_pipeisclosed>
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	75 3b                	jne    800cf7 <devpipe_write+0x79>
			sys_yield();
  800cbc:	e8 fd f4 ff ff       	call   8001be <sys_yield>
  800cc1:	eb e0                	jmp    800ca3 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cca:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ccd:	89 c2                	mov    %eax,%edx
  800ccf:	c1 fa 1f             	sar    $0x1f,%edx
  800cd2:	89 d1                	mov    %edx,%ecx
  800cd4:	c1 e9 1b             	shr    $0x1b,%ecx
  800cd7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cda:	83 e2 1f             	and    $0x1f,%edx
  800cdd:	29 ca                	sub    %ecx,%edx
  800cdf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ce3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ce7:	83 c0 01             	add    $0x1,%eax
  800cea:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800ced:	83 c7 01             	add    $0x1,%edi
  800cf0:	eb ac                	jmp    800c9e <devpipe_write+0x20>
	return i;
  800cf2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf5:	eb 05                	jmp    800cfc <devpipe_write+0x7e>
				return 0;
  800cf7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <devpipe_read>:
{
  800d04:	f3 0f 1e fb          	endbr32 
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 18             	sub    $0x18,%esp
  800d11:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d14:	57                   	push   %edi
  800d15:	e8 20 f6 ff ff       	call   80033a <fd2data>
  800d1a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d1c:	83 c4 10             	add    $0x10,%esp
  800d1f:	be 00 00 00 00       	mov    $0x0,%esi
  800d24:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d27:	75 14                	jne    800d3d <devpipe_read+0x39>
	return i;
  800d29:	8b 45 10             	mov    0x10(%ebp),%eax
  800d2c:	eb 02                	jmp    800d30 <devpipe_read+0x2c>
				return i;
  800d2e:	89 f0                	mov    %esi,%eax
}
  800d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    
			sys_yield();
  800d38:	e8 81 f4 ff ff       	call   8001be <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d3d:	8b 03                	mov    (%ebx),%eax
  800d3f:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d42:	75 18                	jne    800d5c <devpipe_read+0x58>
			if (i > 0)
  800d44:	85 f6                	test   %esi,%esi
  800d46:	75 e6                	jne    800d2e <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d48:	89 da                	mov    %ebx,%edx
  800d4a:	89 f8                	mov    %edi,%eax
  800d4c:	e8 c8 fe ff ff       	call   800c19 <_pipeisclosed>
  800d51:	85 c0                	test   %eax,%eax
  800d53:	74 e3                	je     800d38 <devpipe_read+0x34>
				return 0;
  800d55:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5a:	eb d4                	jmp    800d30 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d5c:	99                   	cltd   
  800d5d:	c1 ea 1b             	shr    $0x1b,%edx
  800d60:	01 d0                	add    %edx,%eax
  800d62:	83 e0 1f             	and    $0x1f,%eax
  800d65:	29 d0                	sub    %edx,%eax
  800d67:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d72:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d75:	83 c6 01             	add    $0x1,%esi
  800d78:	eb aa                	jmp    800d24 <devpipe_read+0x20>

00800d7a <pipe>:
{
  800d7a:	f3 0f 1e fb          	endbr32 
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d89:	50                   	push   %eax
  800d8a:	e8 ca f5 ff ff       	call   800359 <fd_alloc>
  800d8f:	89 c3                	mov    %eax,%ebx
  800d91:	83 c4 10             	add    $0x10,%esp
  800d94:	85 c0                	test   %eax,%eax
  800d96:	0f 88 23 01 00 00    	js     800ebf <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9c:	83 ec 04             	sub    $0x4,%esp
  800d9f:	68 07 04 00 00       	push   $0x407
  800da4:	ff 75 f4             	pushl  -0xc(%ebp)
  800da7:	6a 00                	push   $0x0
  800da9:	e8 3b f4 ff ff       	call   8001e9 <sys_page_alloc>
  800dae:	89 c3                	mov    %eax,%ebx
  800db0:	83 c4 10             	add    $0x10,%esp
  800db3:	85 c0                	test   %eax,%eax
  800db5:	0f 88 04 01 00 00    	js     800ebf <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800dbb:	83 ec 0c             	sub    $0xc,%esp
  800dbe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dc1:	50                   	push   %eax
  800dc2:	e8 92 f5 ff ff       	call   800359 <fd_alloc>
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	83 c4 10             	add    $0x10,%esp
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	0f 88 db 00 00 00    	js     800eaf <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd4:	83 ec 04             	sub    $0x4,%esp
  800dd7:	68 07 04 00 00       	push   $0x407
  800ddc:	ff 75 f0             	pushl  -0x10(%ebp)
  800ddf:	6a 00                	push   $0x0
  800de1:	e8 03 f4 ff ff       	call   8001e9 <sys_page_alloc>
  800de6:	89 c3                	mov    %eax,%ebx
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	85 c0                	test   %eax,%eax
  800ded:	0f 88 bc 00 00 00    	js     800eaf <pipe+0x135>
	va = fd2data(fd0);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	ff 75 f4             	pushl  -0xc(%ebp)
  800df9:	e8 3c f5 ff ff       	call   80033a <fd2data>
  800dfe:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e00:	83 c4 0c             	add    $0xc,%esp
  800e03:	68 07 04 00 00       	push   $0x407
  800e08:	50                   	push   %eax
  800e09:	6a 00                	push   $0x0
  800e0b:	e8 d9 f3 ff ff       	call   8001e9 <sys_page_alloc>
  800e10:	89 c3                	mov    %eax,%ebx
  800e12:	83 c4 10             	add    $0x10,%esp
  800e15:	85 c0                	test   %eax,%eax
  800e17:	0f 88 82 00 00 00    	js     800e9f <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e1d:	83 ec 0c             	sub    $0xc,%esp
  800e20:	ff 75 f0             	pushl  -0x10(%ebp)
  800e23:	e8 12 f5 ff ff       	call   80033a <fd2data>
  800e28:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e2f:	50                   	push   %eax
  800e30:	6a 00                	push   $0x0
  800e32:	56                   	push   %esi
  800e33:	6a 00                	push   $0x0
  800e35:	e8 d7 f3 ff ff       	call   800211 <sys_page_map>
  800e3a:	89 c3                	mov    %eax,%ebx
  800e3c:	83 c4 20             	add    $0x20,%esp
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	78 4e                	js     800e91 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e43:	a1 20 30 80 00       	mov    0x803020,%eax
  800e48:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e4b:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e50:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e57:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e5a:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e5f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e66:	83 ec 0c             	sub    $0xc,%esp
  800e69:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6c:	e8 b5 f4 ff ff       	call   800326 <fd2num>
  800e71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e74:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e76:	83 c4 04             	add    $0x4,%esp
  800e79:	ff 75 f0             	pushl  -0x10(%ebp)
  800e7c:	e8 a5 f4 ff ff       	call   800326 <fd2num>
  800e81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e84:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e87:	83 c4 10             	add    $0x10,%esp
  800e8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8f:	eb 2e                	jmp    800ebf <pipe+0x145>
	sys_page_unmap(0, va);
  800e91:	83 ec 08             	sub    $0x8,%esp
  800e94:	56                   	push   %esi
  800e95:	6a 00                	push   $0x0
  800e97:	e8 9f f3 ff ff       	call   80023b <sys_page_unmap>
  800e9c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e9f:	83 ec 08             	sub    $0x8,%esp
  800ea2:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea5:	6a 00                	push   $0x0
  800ea7:	e8 8f f3 ff ff       	call   80023b <sys_page_unmap>
  800eac:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800eaf:	83 ec 08             	sub    $0x8,%esp
  800eb2:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb5:	6a 00                	push   $0x0
  800eb7:	e8 7f f3 ff ff       	call   80023b <sys_page_unmap>
  800ebc:	83 c4 10             	add    $0x10,%esp
}
  800ebf:	89 d8                	mov    %ebx,%eax
  800ec1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <pipeisclosed>:
{
  800ec8:	f3 0f 1e fb          	endbr32 
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed5:	50                   	push   %eax
  800ed6:	ff 75 08             	pushl  0x8(%ebp)
  800ed9:	e8 d1 f4 ff ff       	call   8003af <fd_lookup>
  800ede:	83 c4 10             	add    $0x10,%esp
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	78 18                	js     800efd <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800ee5:	83 ec 0c             	sub    $0xc,%esp
  800ee8:	ff 75 f4             	pushl  -0xc(%ebp)
  800eeb:	e8 4a f4 ff ff       	call   80033a <fd2data>
  800ef0:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef5:	e8 1f fd ff ff       	call   800c19 <_pipeisclosed>
  800efa:	83 c4 10             	add    $0x10,%esp
}
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eff:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f03:	b8 00 00 00 00       	mov    $0x0,%eax
  800f08:	c3                   	ret    

00800f09 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f09:	f3 0f 1e fb          	endbr32 
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f13:	68 16 1f 80 00       	push   $0x801f16
  800f18:	ff 75 0c             	pushl  0xc(%ebp)
  800f1b:	e8 c5 07 00 00       	call   8016e5 <strcpy>
	return 0;
}
  800f20:	b8 00 00 00 00       	mov    $0x0,%eax
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    

00800f27 <devcons_write>:
{
  800f27:	f3 0f 1e fb          	endbr32 
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	57                   	push   %edi
  800f2f:	56                   	push   %esi
  800f30:	53                   	push   %ebx
  800f31:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f37:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f3c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f42:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f45:	73 31                	jae    800f78 <devcons_write+0x51>
		m = n - tot;
  800f47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f4a:	29 f3                	sub    %esi,%ebx
  800f4c:	83 fb 7f             	cmp    $0x7f,%ebx
  800f4f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f54:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f57:	83 ec 04             	sub    $0x4,%esp
  800f5a:	53                   	push   %ebx
  800f5b:	89 f0                	mov    %esi,%eax
  800f5d:	03 45 0c             	add    0xc(%ebp),%eax
  800f60:	50                   	push   %eax
  800f61:	57                   	push   %edi
  800f62:	e8 36 09 00 00       	call   80189d <memmove>
		sys_cputs(buf, m);
  800f67:	83 c4 08             	add    $0x8,%esp
  800f6a:	53                   	push   %ebx
  800f6b:	57                   	push   %edi
  800f6c:	e8 ad f1 ff ff       	call   80011e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f71:	01 de                	add    %ebx,%esi
  800f73:	83 c4 10             	add    $0x10,%esp
  800f76:	eb ca                	jmp    800f42 <devcons_write+0x1b>
}
  800f78:	89 f0                	mov    %esi,%eax
  800f7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7d:	5b                   	pop    %ebx
  800f7e:	5e                   	pop    %esi
  800f7f:	5f                   	pop    %edi
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    

00800f82 <devcons_read>:
{
  800f82:	f3 0f 1e fb          	endbr32 
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	83 ec 08             	sub    $0x8,%esp
  800f8c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f91:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f95:	74 21                	je     800fb8 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800f97:	e8 ac f1 ff ff       	call   800148 <sys_cgetc>
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	75 07                	jne    800fa7 <devcons_read+0x25>
		sys_yield();
  800fa0:	e8 19 f2 ff ff       	call   8001be <sys_yield>
  800fa5:	eb f0                	jmp    800f97 <devcons_read+0x15>
	if (c < 0)
  800fa7:	78 0f                	js     800fb8 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800fa9:	83 f8 04             	cmp    $0x4,%eax
  800fac:	74 0c                	je     800fba <devcons_read+0x38>
	*(char*)vbuf = c;
  800fae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fb1:	88 02                	mov    %al,(%edx)
	return 1;
  800fb3:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800fb8:	c9                   	leave  
  800fb9:	c3                   	ret    
		return 0;
  800fba:	b8 00 00 00 00       	mov    $0x0,%eax
  800fbf:	eb f7                	jmp    800fb8 <devcons_read+0x36>

00800fc1 <cputchar>:
{
  800fc1:	f3 0f 1e fb          	endbr32 
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fce:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800fd1:	6a 01                	push   $0x1
  800fd3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd6:	50                   	push   %eax
  800fd7:	e8 42 f1 ff ff       	call   80011e <sys_cputs>
}
  800fdc:	83 c4 10             	add    $0x10,%esp
  800fdf:	c9                   	leave  
  800fe0:	c3                   	ret    

00800fe1 <getchar>:
{
  800fe1:	f3 0f 1e fb          	endbr32 
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800feb:	6a 01                	push   $0x1
  800fed:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800ff0:	50                   	push   %eax
  800ff1:	6a 00                	push   $0x0
  800ff3:	e8 3a f6 ff ff       	call   800632 <read>
	if (r < 0)
  800ff8:	83 c4 10             	add    $0x10,%esp
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	78 06                	js     801005 <getchar+0x24>
	if (r < 1)
  800fff:	74 06                	je     801007 <getchar+0x26>
	return c;
  801001:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801005:	c9                   	leave  
  801006:	c3                   	ret    
		return -E_EOF;
  801007:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80100c:	eb f7                	jmp    801005 <getchar+0x24>

0080100e <iscons>:
{
  80100e:	f3 0f 1e fb          	endbr32 
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801018:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80101b:	50                   	push   %eax
  80101c:	ff 75 08             	pushl  0x8(%ebp)
  80101f:	e8 8b f3 ff ff       	call   8003af <fd_lookup>
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	78 11                	js     80103c <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80102b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801034:	39 10                	cmp    %edx,(%eax)
  801036:	0f 94 c0             	sete   %al
  801039:	0f b6 c0             	movzbl %al,%eax
}
  80103c:	c9                   	leave  
  80103d:	c3                   	ret    

0080103e <opencons>:
{
  80103e:	f3 0f 1e fb          	endbr32 
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801048:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104b:	50                   	push   %eax
  80104c:	e8 08 f3 ff ff       	call   800359 <fd_alloc>
  801051:	83 c4 10             	add    $0x10,%esp
  801054:	85 c0                	test   %eax,%eax
  801056:	78 3a                	js     801092 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801058:	83 ec 04             	sub    $0x4,%esp
  80105b:	68 07 04 00 00       	push   $0x407
  801060:	ff 75 f4             	pushl  -0xc(%ebp)
  801063:	6a 00                	push   $0x0
  801065:	e8 7f f1 ff ff       	call   8001e9 <sys_page_alloc>
  80106a:	83 c4 10             	add    $0x10,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	78 21                	js     801092 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801071:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801074:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80107a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80107c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80107f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801086:	83 ec 0c             	sub    $0xc,%esp
  801089:	50                   	push   %eax
  80108a:	e8 97 f2 ff ff       	call   800326 <fd2num>
  80108f:	83 c4 10             	add    $0x10,%esp
}
  801092:	c9                   	leave  
  801093:	c3                   	ret    

00801094 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801094:	f3 0f 1e fb          	endbr32 
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	56                   	push   %esi
  80109c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80109d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010a0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010a6:	e8 eb f0 ff ff       	call   800196 <sys_getenvid>
  8010ab:	83 ec 0c             	sub    $0xc,%esp
  8010ae:	ff 75 0c             	pushl  0xc(%ebp)
  8010b1:	ff 75 08             	pushl  0x8(%ebp)
  8010b4:	56                   	push   %esi
  8010b5:	50                   	push   %eax
  8010b6:	68 24 1f 80 00       	push   $0x801f24
  8010bb:	e8 bb 00 00 00       	call   80117b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010c0:	83 c4 18             	add    $0x18,%esp
  8010c3:	53                   	push   %ebx
  8010c4:	ff 75 10             	pushl  0x10(%ebp)
  8010c7:	e8 5a 00 00 00       	call   801126 <vcprintf>
	cprintf("\n");
  8010cc:	c7 04 24 0f 1f 80 00 	movl   $0x801f0f,(%esp)
  8010d3:	e8 a3 00 00 00       	call   80117b <cprintf>
  8010d8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010db:	cc                   	int3   
  8010dc:	eb fd                	jmp    8010db <_panic+0x47>

008010de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010de:	f3 0f 1e fb          	endbr32 
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	53                   	push   %ebx
  8010e6:	83 ec 04             	sub    $0x4,%esp
  8010e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010ec:	8b 13                	mov    (%ebx),%edx
  8010ee:	8d 42 01             	lea    0x1(%edx),%eax
  8010f1:	89 03                	mov    %eax,(%ebx)
  8010f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010ff:	74 09                	je     80110a <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801101:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801105:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801108:	c9                   	leave  
  801109:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80110a:	83 ec 08             	sub    $0x8,%esp
  80110d:	68 ff 00 00 00       	push   $0xff
  801112:	8d 43 08             	lea    0x8(%ebx),%eax
  801115:	50                   	push   %eax
  801116:	e8 03 f0 ff ff       	call   80011e <sys_cputs>
		b->idx = 0;
  80111b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801121:	83 c4 10             	add    $0x10,%esp
  801124:	eb db                	jmp    801101 <putch+0x23>

00801126 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801126:	f3 0f 1e fb          	endbr32 
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801133:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80113a:	00 00 00 
	b.cnt = 0;
  80113d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801144:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801147:	ff 75 0c             	pushl  0xc(%ebp)
  80114a:	ff 75 08             	pushl  0x8(%ebp)
  80114d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801153:	50                   	push   %eax
  801154:	68 de 10 80 00       	push   $0x8010de
  801159:	e8 80 01 00 00       	call   8012de <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80115e:	83 c4 08             	add    $0x8,%esp
  801161:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801167:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80116d:	50                   	push   %eax
  80116e:	e8 ab ef ff ff       	call   80011e <sys_cputs>

	return b.cnt;
}
  801173:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801179:	c9                   	leave  
  80117a:	c3                   	ret    

0080117b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80117b:	f3 0f 1e fb          	endbr32 
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801185:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801188:	50                   	push   %eax
  801189:	ff 75 08             	pushl  0x8(%ebp)
  80118c:	e8 95 ff ff ff       	call   801126 <vcprintf>
	va_end(ap);

	return cnt;
}
  801191:	c9                   	leave  
  801192:	c3                   	ret    

00801193 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	57                   	push   %edi
  801197:	56                   	push   %esi
  801198:	53                   	push   %ebx
  801199:	83 ec 1c             	sub    $0x1c,%esp
  80119c:	89 c7                	mov    %eax,%edi
  80119e:	89 d6                	mov    %edx,%esi
  8011a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a6:	89 d1                	mov    %edx,%ecx
  8011a8:	89 c2                	mov    %eax,%edx
  8011aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8011b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8011b3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011b9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011c0:	39 c2                	cmp    %eax,%edx
  8011c2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011c5:	72 3e                	jb     801205 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011c7:	83 ec 0c             	sub    $0xc,%esp
  8011ca:	ff 75 18             	pushl  0x18(%ebp)
  8011cd:	83 eb 01             	sub    $0x1,%ebx
  8011d0:	53                   	push   %ebx
  8011d1:	50                   	push   %eax
  8011d2:	83 ec 08             	sub    $0x8,%esp
  8011d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8011db:	ff 75 dc             	pushl  -0x24(%ebp)
  8011de:	ff 75 d8             	pushl  -0x28(%ebp)
  8011e1:	e8 ba 09 00 00       	call   801ba0 <__udivdi3>
  8011e6:	83 c4 18             	add    $0x18,%esp
  8011e9:	52                   	push   %edx
  8011ea:	50                   	push   %eax
  8011eb:	89 f2                	mov    %esi,%edx
  8011ed:	89 f8                	mov    %edi,%eax
  8011ef:	e8 9f ff ff ff       	call   801193 <printnum>
  8011f4:	83 c4 20             	add    $0x20,%esp
  8011f7:	eb 13                	jmp    80120c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	56                   	push   %esi
  8011fd:	ff 75 18             	pushl  0x18(%ebp)
  801200:	ff d7                	call   *%edi
  801202:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801205:	83 eb 01             	sub    $0x1,%ebx
  801208:	85 db                	test   %ebx,%ebx
  80120a:	7f ed                	jg     8011f9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80120c:	83 ec 08             	sub    $0x8,%esp
  80120f:	56                   	push   %esi
  801210:	83 ec 04             	sub    $0x4,%esp
  801213:	ff 75 e4             	pushl  -0x1c(%ebp)
  801216:	ff 75 e0             	pushl  -0x20(%ebp)
  801219:	ff 75 dc             	pushl  -0x24(%ebp)
  80121c:	ff 75 d8             	pushl  -0x28(%ebp)
  80121f:	e8 8c 0a 00 00       	call   801cb0 <__umoddi3>
  801224:	83 c4 14             	add    $0x14,%esp
  801227:	0f be 80 47 1f 80 00 	movsbl 0x801f47(%eax),%eax
  80122e:	50                   	push   %eax
  80122f:	ff d7                	call   *%edi
}
  801231:	83 c4 10             	add    $0x10,%esp
  801234:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801237:	5b                   	pop    %ebx
  801238:	5e                   	pop    %esi
  801239:	5f                   	pop    %edi
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80123c:	83 fa 01             	cmp    $0x1,%edx
  80123f:	7f 13                	jg     801254 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801241:	85 d2                	test   %edx,%edx
  801243:	74 1c                	je     801261 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  801245:	8b 10                	mov    (%eax),%edx
  801247:	8d 4a 04             	lea    0x4(%edx),%ecx
  80124a:	89 08                	mov    %ecx,(%eax)
  80124c:	8b 02                	mov    (%edx),%eax
  80124e:	ba 00 00 00 00       	mov    $0x0,%edx
  801253:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  801254:	8b 10                	mov    (%eax),%edx
  801256:	8d 4a 08             	lea    0x8(%edx),%ecx
  801259:	89 08                	mov    %ecx,(%eax)
  80125b:	8b 02                	mov    (%edx),%eax
  80125d:	8b 52 04             	mov    0x4(%edx),%edx
  801260:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  801261:	8b 10                	mov    (%eax),%edx
  801263:	8d 4a 04             	lea    0x4(%edx),%ecx
  801266:	89 08                	mov    %ecx,(%eax)
  801268:	8b 02                	mov    (%edx),%eax
  80126a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80126f:	c3                   	ret    

00801270 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801270:	83 fa 01             	cmp    $0x1,%edx
  801273:	7f 0f                	jg     801284 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  801275:	85 d2                	test   %edx,%edx
  801277:	74 18                	je     801291 <getint+0x21>
		return va_arg(*ap, long);
  801279:	8b 10                	mov    (%eax),%edx
  80127b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80127e:	89 08                	mov    %ecx,(%eax)
  801280:	8b 02                	mov    (%edx),%eax
  801282:	99                   	cltd   
  801283:	c3                   	ret    
		return va_arg(*ap, long long);
  801284:	8b 10                	mov    (%eax),%edx
  801286:	8d 4a 08             	lea    0x8(%edx),%ecx
  801289:	89 08                	mov    %ecx,(%eax)
  80128b:	8b 02                	mov    (%edx),%eax
  80128d:	8b 52 04             	mov    0x4(%edx),%edx
  801290:	c3                   	ret    
	else
		return va_arg(*ap, int);
  801291:	8b 10                	mov    (%eax),%edx
  801293:	8d 4a 04             	lea    0x4(%edx),%ecx
  801296:	89 08                	mov    %ecx,(%eax)
  801298:	8b 02                	mov    (%edx),%eax
  80129a:	99                   	cltd   
}
  80129b:	c3                   	ret    

0080129c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80129c:	f3 0f 1e fb          	endbr32 
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8012a6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8012aa:	8b 10                	mov    (%eax),%edx
  8012ac:	3b 50 04             	cmp    0x4(%eax),%edx
  8012af:	73 0a                	jae    8012bb <sprintputch+0x1f>
		*b->buf++ = ch;
  8012b1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8012b4:	89 08                	mov    %ecx,(%eax)
  8012b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b9:	88 02                	mov    %al,(%edx)
}
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <printfmt>:
{
  8012bd:	f3 0f 1e fb          	endbr32 
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012c7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012ca:	50                   	push   %eax
  8012cb:	ff 75 10             	pushl  0x10(%ebp)
  8012ce:	ff 75 0c             	pushl  0xc(%ebp)
  8012d1:	ff 75 08             	pushl  0x8(%ebp)
  8012d4:	e8 05 00 00 00       	call   8012de <vprintfmt>
}
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	c9                   	leave  
  8012dd:	c3                   	ret    

008012de <vprintfmt>:
{
  8012de:	f3 0f 1e fb          	endbr32 
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	57                   	push   %edi
  8012e6:	56                   	push   %esi
  8012e7:	53                   	push   %ebx
  8012e8:	83 ec 2c             	sub    $0x2c,%esp
  8012eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012f1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012f4:	e9 86 02 00 00       	jmp    80157f <vprintfmt+0x2a1>
		padc = ' ';
  8012f9:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012fd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801304:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80130b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801312:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801317:	8d 47 01             	lea    0x1(%edi),%eax
  80131a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80131d:	0f b6 17             	movzbl (%edi),%edx
  801320:	8d 42 dd             	lea    -0x23(%edx),%eax
  801323:	3c 55                	cmp    $0x55,%al
  801325:	0f 87 df 02 00 00    	ja     80160a <vprintfmt+0x32c>
  80132b:	0f b6 c0             	movzbl %al,%eax
  80132e:	3e ff 24 85 80 20 80 	notrack jmp *0x802080(,%eax,4)
  801335:	00 
  801336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801339:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80133d:	eb d8                	jmp    801317 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80133f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801342:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801346:	eb cf                	jmp    801317 <vprintfmt+0x39>
  801348:	0f b6 d2             	movzbl %dl,%edx
  80134b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80134e:	b8 00 00 00 00       	mov    $0x0,%eax
  801353:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801356:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801359:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80135d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801360:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801363:	83 f9 09             	cmp    $0x9,%ecx
  801366:	77 52                	ja     8013ba <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  801368:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80136b:	eb e9                	jmp    801356 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80136d:	8b 45 14             	mov    0x14(%ebp),%eax
  801370:	8d 50 04             	lea    0x4(%eax),%edx
  801373:	89 55 14             	mov    %edx,0x14(%ebp)
  801376:	8b 00                	mov    (%eax),%eax
  801378:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80137b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80137e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801382:	79 93                	jns    801317 <vprintfmt+0x39>
				width = precision, precision = -1;
  801384:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801387:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80138a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801391:	eb 84                	jmp    801317 <vprintfmt+0x39>
  801393:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801396:	85 c0                	test   %eax,%eax
  801398:	ba 00 00 00 00       	mov    $0x0,%edx
  80139d:	0f 49 d0             	cmovns %eax,%edx
  8013a0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8013a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013a6:	e9 6c ff ff ff       	jmp    801317 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8013ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8013ae:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8013b5:	e9 5d ff ff ff       	jmp    801317 <vprintfmt+0x39>
  8013ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013bd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8013c0:	eb bc                	jmp    80137e <vprintfmt+0xa0>
			lflag++;
  8013c2:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8013c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013c8:	e9 4a ff ff ff       	jmp    801317 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d0:	8d 50 04             	lea    0x4(%eax),%edx
  8013d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8013d6:	83 ec 08             	sub    $0x8,%esp
  8013d9:	56                   	push   %esi
  8013da:	ff 30                	pushl  (%eax)
  8013dc:	ff d3                	call   *%ebx
			break;
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	e9 96 01 00 00       	jmp    80157c <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8013e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e9:	8d 50 04             	lea    0x4(%eax),%edx
  8013ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8013ef:	8b 00                	mov    (%eax),%eax
  8013f1:	99                   	cltd   
  8013f2:	31 d0                	xor    %edx,%eax
  8013f4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013f6:	83 f8 0f             	cmp    $0xf,%eax
  8013f9:	7f 20                	jg     80141b <vprintfmt+0x13d>
  8013fb:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  801402:	85 d2                	test   %edx,%edx
  801404:	74 15                	je     80141b <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  801406:	52                   	push   %edx
  801407:	68 dd 1e 80 00       	push   $0x801edd
  80140c:	56                   	push   %esi
  80140d:	53                   	push   %ebx
  80140e:	e8 aa fe ff ff       	call   8012bd <printfmt>
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	e9 61 01 00 00       	jmp    80157c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80141b:	50                   	push   %eax
  80141c:	68 5f 1f 80 00       	push   $0x801f5f
  801421:	56                   	push   %esi
  801422:	53                   	push   %ebx
  801423:	e8 95 fe ff ff       	call   8012bd <printfmt>
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	e9 4c 01 00 00       	jmp    80157c <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  801430:	8b 45 14             	mov    0x14(%ebp),%eax
  801433:	8d 50 04             	lea    0x4(%eax),%edx
  801436:	89 55 14             	mov    %edx,0x14(%ebp)
  801439:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80143b:	85 c9                	test   %ecx,%ecx
  80143d:	b8 58 1f 80 00       	mov    $0x801f58,%eax
  801442:	0f 45 c1             	cmovne %ecx,%eax
  801445:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801448:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80144c:	7e 06                	jle    801454 <vprintfmt+0x176>
  80144e:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801452:	75 0d                	jne    801461 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  801454:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801457:	89 c7                	mov    %eax,%edi
  801459:	03 45 e0             	add    -0x20(%ebp),%eax
  80145c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80145f:	eb 57                	jmp    8014b8 <vprintfmt+0x1da>
  801461:	83 ec 08             	sub    $0x8,%esp
  801464:	ff 75 d8             	pushl  -0x28(%ebp)
  801467:	ff 75 cc             	pushl  -0x34(%ebp)
  80146a:	e8 4f 02 00 00       	call   8016be <strnlen>
  80146f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801472:	29 c2                	sub    %eax,%edx
  801474:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801477:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80147a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80147e:	89 5d 08             	mov    %ebx,0x8(%ebp)
  801481:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  801483:	85 db                	test   %ebx,%ebx
  801485:	7e 10                	jle    801497 <vprintfmt+0x1b9>
					putch(padc, putdat);
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	56                   	push   %esi
  80148b:	57                   	push   %edi
  80148c:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80148f:	83 eb 01             	sub    $0x1,%ebx
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	eb ec                	jmp    801483 <vprintfmt+0x1a5>
  801497:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80149a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80149d:	85 d2                	test   %edx,%edx
  80149f:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a4:	0f 49 c2             	cmovns %edx,%eax
  8014a7:	29 c2                	sub    %eax,%edx
  8014a9:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8014ac:	eb a6                	jmp    801454 <vprintfmt+0x176>
					putch(ch, putdat);
  8014ae:	83 ec 08             	sub    $0x8,%esp
  8014b1:	56                   	push   %esi
  8014b2:	52                   	push   %edx
  8014b3:	ff d3                	call   *%ebx
  8014b5:	83 c4 10             	add    $0x10,%esp
  8014b8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014bb:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014bd:	83 c7 01             	add    $0x1,%edi
  8014c0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014c4:	0f be d0             	movsbl %al,%edx
  8014c7:	85 d2                	test   %edx,%edx
  8014c9:	74 42                	je     80150d <vprintfmt+0x22f>
  8014cb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014cf:	78 06                	js     8014d7 <vprintfmt+0x1f9>
  8014d1:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014d5:	78 1e                	js     8014f5 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8014d7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014db:	74 d1                	je     8014ae <vprintfmt+0x1d0>
  8014dd:	0f be c0             	movsbl %al,%eax
  8014e0:	83 e8 20             	sub    $0x20,%eax
  8014e3:	83 f8 5e             	cmp    $0x5e,%eax
  8014e6:	76 c6                	jbe    8014ae <vprintfmt+0x1d0>
					putch('?', putdat);
  8014e8:	83 ec 08             	sub    $0x8,%esp
  8014eb:	56                   	push   %esi
  8014ec:	6a 3f                	push   $0x3f
  8014ee:	ff d3                	call   *%ebx
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	eb c3                	jmp    8014b8 <vprintfmt+0x1da>
  8014f5:	89 cf                	mov    %ecx,%edi
  8014f7:	eb 0e                	jmp    801507 <vprintfmt+0x229>
				putch(' ', putdat);
  8014f9:	83 ec 08             	sub    $0x8,%esp
  8014fc:	56                   	push   %esi
  8014fd:	6a 20                	push   $0x20
  8014ff:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  801501:	83 ef 01             	sub    $0x1,%edi
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	85 ff                	test   %edi,%edi
  801509:	7f ee                	jg     8014f9 <vprintfmt+0x21b>
  80150b:	eb 6f                	jmp    80157c <vprintfmt+0x29e>
  80150d:	89 cf                	mov    %ecx,%edi
  80150f:	eb f6                	jmp    801507 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  801511:	89 ca                	mov    %ecx,%edx
  801513:	8d 45 14             	lea    0x14(%ebp),%eax
  801516:	e8 55 fd ff ff       	call   801270 <getint>
  80151b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80151e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  801521:	85 d2                	test   %edx,%edx
  801523:	78 0b                	js     801530 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  801525:	89 d1                	mov    %edx,%ecx
  801527:	89 c2                	mov    %eax,%edx
			base = 10;
  801529:	b8 0a 00 00 00       	mov    $0xa,%eax
  80152e:	eb 32                	jmp    801562 <vprintfmt+0x284>
				putch('-', putdat);
  801530:	83 ec 08             	sub    $0x8,%esp
  801533:	56                   	push   %esi
  801534:	6a 2d                	push   $0x2d
  801536:	ff d3                	call   *%ebx
				num = -(long long) num;
  801538:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80153b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80153e:	f7 da                	neg    %edx
  801540:	83 d1 00             	adc    $0x0,%ecx
  801543:	f7 d9                	neg    %ecx
  801545:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801548:	b8 0a 00 00 00       	mov    $0xa,%eax
  80154d:	eb 13                	jmp    801562 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80154f:	89 ca                	mov    %ecx,%edx
  801551:	8d 45 14             	lea    0x14(%ebp),%eax
  801554:	e8 e3 fc ff ff       	call   80123c <getuint>
  801559:	89 d1                	mov    %edx,%ecx
  80155b:	89 c2                	mov    %eax,%edx
			base = 10;
  80155d:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  801562:	83 ec 0c             	sub    $0xc,%esp
  801565:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801569:	57                   	push   %edi
  80156a:	ff 75 e0             	pushl  -0x20(%ebp)
  80156d:	50                   	push   %eax
  80156e:	51                   	push   %ecx
  80156f:	52                   	push   %edx
  801570:	89 f2                	mov    %esi,%edx
  801572:	89 d8                	mov    %ebx,%eax
  801574:	e8 1a fc ff ff       	call   801193 <printnum>
			break;
  801579:	83 c4 20             	add    $0x20,%esp
{
  80157c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80157f:	83 c7 01             	add    $0x1,%edi
  801582:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801586:	83 f8 25             	cmp    $0x25,%eax
  801589:	0f 84 6a fd ff ff    	je     8012f9 <vprintfmt+0x1b>
			if (ch == '\0')
  80158f:	85 c0                	test   %eax,%eax
  801591:	0f 84 93 00 00 00    	je     80162a <vprintfmt+0x34c>
			putch(ch, putdat);
  801597:	83 ec 08             	sub    $0x8,%esp
  80159a:	56                   	push   %esi
  80159b:	50                   	push   %eax
  80159c:	ff d3                	call   *%ebx
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	eb dc                	jmp    80157f <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8015a3:	89 ca                	mov    %ecx,%edx
  8015a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a8:	e8 8f fc ff ff       	call   80123c <getuint>
  8015ad:	89 d1                	mov    %edx,%ecx
  8015af:	89 c2                	mov    %eax,%edx
			base = 8;
  8015b1:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8015b6:	eb aa                	jmp    801562 <vprintfmt+0x284>
			putch('0', putdat);
  8015b8:	83 ec 08             	sub    $0x8,%esp
  8015bb:	56                   	push   %esi
  8015bc:	6a 30                	push   $0x30
  8015be:	ff d3                	call   *%ebx
			putch('x', putdat);
  8015c0:	83 c4 08             	add    $0x8,%esp
  8015c3:	56                   	push   %esi
  8015c4:	6a 78                	push   $0x78
  8015c6:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8015c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015cb:	8d 50 04             	lea    0x4(%eax),%edx
  8015ce:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8015d1:	8b 10                	mov    (%eax),%edx
  8015d3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015d8:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8015db:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015e0:	eb 80                	jmp    801562 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8015e2:	89 ca                	mov    %ecx,%edx
  8015e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8015e7:	e8 50 fc ff ff       	call   80123c <getuint>
  8015ec:	89 d1                	mov    %edx,%ecx
  8015ee:	89 c2                	mov    %eax,%edx
			base = 16;
  8015f0:	b8 10 00 00 00       	mov    $0x10,%eax
  8015f5:	e9 68 ff ff ff       	jmp    801562 <vprintfmt+0x284>
			putch(ch, putdat);
  8015fa:	83 ec 08             	sub    $0x8,%esp
  8015fd:	56                   	push   %esi
  8015fe:	6a 25                	push   $0x25
  801600:	ff d3                	call   *%ebx
			break;
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	e9 72 ff ff ff       	jmp    80157c <vprintfmt+0x29e>
			putch('%', putdat);
  80160a:	83 ec 08             	sub    $0x8,%esp
  80160d:	56                   	push   %esi
  80160e:	6a 25                	push   $0x25
  801610:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	89 f8                	mov    %edi,%eax
  801617:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80161b:	74 05                	je     801622 <vprintfmt+0x344>
  80161d:	83 e8 01             	sub    $0x1,%eax
  801620:	eb f5                	jmp    801617 <vprintfmt+0x339>
  801622:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801625:	e9 52 ff ff ff       	jmp    80157c <vprintfmt+0x29e>
}
  80162a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162d:	5b                   	pop    %ebx
  80162e:	5e                   	pop    %esi
  80162f:	5f                   	pop    %edi
  801630:	5d                   	pop    %ebp
  801631:	c3                   	ret    

00801632 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801632:	f3 0f 1e fb          	endbr32 
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	83 ec 18             	sub    $0x18,%esp
  80163c:	8b 45 08             	mov    0x8(%ebp),%eax
  80163f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801642:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801645:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801649:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80164c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801653:	85 c0                	test   %eax,%eax
  801655:	74 26                	je     80167d <vsnprintf+0x4b>
  801657:	85 d2                	test   %edx,%edx
  801659:	7e 22                	jle    80167d <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80165b:	ff 75 14             	pushl  0x14(%ebp)
  80165e:	ff 75 10             	pushl  0x10(%ebp)
  801661:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801664:	50                   	push   %eax
  801665:	68 9c 12 80 00       	push   $0x80129c
  80166a:	e8 6f fc ff ff       	call   8012de <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80166f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801672:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801675:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801678:	83 c4 10             	add    $0x10,%esp
}
  80167b:	c9                   	leave  
  80167c:	c3                   	ret    
		return -E_INVAL;
  80167d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801682:	eb f7                	jmp    80167b <vsnprintf+0x49>

00801684 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801684:	f3 0f 1e fb          	endbr32 
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80168e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801691:	50                   	push   %eax
  801692:	ff 75 10             	pushl  0x10(%ebp)
  801695:	ff 75 0c             	pushl  0xc(%ebp)
  801698:	ff 75 08             	pushl  0x8(%ebp)
  80169b:	e8 92 ff ff ff       	call   801632 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016a0:	c9                   	leave  
  8016a1:	c3                   	ret    

008016a2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016a2:	f3 0f 1e fb          	endbr32 
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016b5:	74 05                	je     8016bc <strlen+0x1a>
		n++;
  8016b7:	83 c0 01             	add    $0x1,%eax
  8016ba:	eb f5                	jmp    8016b1 <strlen+0xf>
	return n;
}
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    

008016be <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016be:	f3 0f 1e fb          	endbr32 
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d0:	39 d0                	cmp    %edx,%eax
  8016d2:	74 0d                	je     8016e1 <strnlen+0x23>
  8016d4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016d8:	74 05                	je     8016df <strnlen+0x21>
		n++;
  8016da:	83 c0 01             	add    $0x1,%eax
  8016dd:	eb f1                	jmp    8016d0 <strnlen+0x12>
  8016df:	89 c2                	mov    %eax,%edx
	return n;
}
  8016e1:	89 d0                	mov    %edx,%eax
  8016e3:	5d                   	pop    %ebp
  8016e4:	c3                   	ret    

008016e5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016e5:	f3 0f 1e fb          	endbr32 
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	53                   	push   %ebx
  8016ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016fc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016ff:	83 c0 01             	add    $0x1,%eax
  801702:	84 d2                	test   %dl,%dl
  801704:	75 f2                	jne    8016f8 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  801706:	89 c8                	mov    %ecx,%eax
  801708:	5b                   	pop    %ebx
  801709:	5d                   	pop    %ebp
  80170a:	c3                   	ret    

0080170b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80170b:	f3 0f 1e fb          	endbr32 
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	53                   	push   %ebx
  801713:	83 ec 10             	sub    $0x10,%esp
  801716:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801719:	53                   	push   %ebx
  80171a:	e8 83 ff ff ff       	call   8016a2 <strlen>
  80171f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801722:	ff 75 0c             	pushl  0xc(%ebp)
  801725:	01 d8                	add    %ebx,%eax
  801727:	50                   	push   %eax
  801728:	e8 b8 ff ff ff       	call   8016e5 <strcpy>
	return dst;
}
  80172d:	89 d8                	mov    %ebx,%eax
  80172f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801732:	c9                   	leave  
  801733:	c3                   	ret    

00801734 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801734:	f3 0f 1e fb          	endbr32 
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	56                   	push   %esi
  80173c:	53                   	push   %ebx
  80173d:	8b 75 08             	mov    0x8(%ebp),%esi
  801740:	8b 55 0c             	mov    0xc(%ebp),%edx
  801743:	89 f3                	mov    %esi,%ebx
  801745:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801748:	89 f0                	mov    %esi,%eax
  80174a:	39 d8                	cmp    %ebx,%eax
  80174c:	74 11                	je     80175f <strncpy+0x2b>
		*dst++ = *src;
  80174e:	83 c0 01             	add    $0x1,%eax
  801751:	0f b6 0a             	movzbl (%edx),%ecx
  801754:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801757:	80 f9 01             	cmp    $0x1,%cl
  80175a:	83 da ff             	sbb    $0xffffffff,%edx
  80175d:	eb eb                	jmp    80174a <strncpy+0x16>
	}
	return ret;
}
  80175f:	89 f0                	mov    %esi,%eax
  801761:	5b                   	pop    %ebx
  801762:	5e                   	pop    %esi
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    

00801765 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801765:	f3 0f 1e fb          	endbr32 
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	56                   	push   %esi
  80176d:	53                   	push   %ebx
  80176e:	8b 75 08             	mov    0x8(%ebp),%esi
  801771:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801774:	8b 55 10             	mov    0x10(%ebp),%edx
  801777:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801779:	85 d2                	test   %edx,%edx
  80177b:	74 21                	je     80179e <strlcpy+0x39>
  80177d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801781:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801783:	39 c2                	cmp    %eax,%edx
  801785:	74 14                	je     80179b <strlcpy+0x36>
  801787:	0f b6 19             	movzbl (%ecx),%ebx
  80178a:	84 db                	test   %bl,%bl
  80178c:	74 0b                	je     801799 <strlcpy+0x34>
			*dst++ = *src++;
  80178e:	83 c1 01             	add    $0x1,%ecx
  801791:	83 c2 01             	add    $0x1,%edx
  801794:	88 5a ff             	mov    %bl,-0x1(%edx)
  801797:	eb ea                	jmp    801783 <strlcpy+0x1e>
  801799:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80179b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80179e:	29 f0                	sub    %esi,%eax
}
  8017a0:	5b                   	pop    %ebx
  8017a1:	5e                   	pop    %esi
  8017a2:	5d                   	pop    %ebp
  8017a3:	c3                   	ret    

008017a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017a4:	f3 0f 1e fb          	endbr32 
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017b1:	0f b6 01             	movzbl (%ecx),%eax
  8017b4:	84 c0                	test   %al,%al
  8017b6:	74 0c                	je     8017c4 <strcmp+0x20>
  8017b8:	3a 02                	cmp    (%edx),%al
  8017ba:	75 08                	jne    8017c4 <strcmp+0x20>
		p++, q++;
  8017bc:	83 c1 01             	add    $0x1,%ecx
  8017bf:	83 c2 01             	add    $0x1,%edx
  8017c2:	eb ed                	jmp    8017b1 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c4:	0f b6 c0             	movzbl %al,%eax
  8017c7:	0f b6 12             	movzbl (%edx),%edx
  8017ca:	29 d0                	sub    %edx,%eax
}
  8017cc:	5d                   	pop    %ebp
  8017cd:	c3                   	ret    

008017ce <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017ce:	f3 0f 1e fb          	endbr32 
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	53                   	push   %ebx
  8017d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017dc:	89 c3                	mov    %eax,%ebx
  8017de:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017e1:	eb 06                	jmp    8017e9 <strncmp+0x1b>
		n--, p++, q++;
  8017e3:	83 c0 01             	add    $0x1,%eax
  8017e6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017e9:	39 d8                	cmp    %ebx,%eax
  8017eb:	74 16                	je     801803 <strncmp+0x35>
  8017ed:	0f b6 08             	movzbl (%eax),%ecx
  8017f0:	84 c9                	test   %cl,%cl
  8017f2:	74 04                	je     8017f8 <strncmp+0x2a>
  8017f4:	3a 0a                	cmp    (%edx),%cl
  8017f6:	74 eb                	je     8017e3 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017f8:	0f b6 00             	movzbl (%eax),%eax
  8017fb:	0f b6 12             	movzbl (%edx),%edx
  8017fe:	29 d0                	sub    %edx,%eax
}
  801800:	5b                   	pop    %ebx
  801801:	5d                   	pop    %ebp
  801802:	c3                   	ret    
		return 0;
  801803:	b8 00 00 00 00       	mov    $0x0,%eax
  801808:	eb f6                	jmp    801800 <strncmp+0x32>

0080180a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80180a:	f3 0f 1e fb          	endbr32 
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801818:	0f b6 10             	movzbl (%eax),%edx
  80181b:	84 d2                	test   %dl,%dl
  80181d:	74 09                	je     801828 <strchr+0x1e>
		if (*s == c)
  80181f:	38 ca                	cmp    %cl,%dl
  801821:	74 0a                	je     80182d <strchr+0x23>
	for (; *s; s++)
  801823:	83 c0 01             	add    $0x1,%eax
  801826:	eb f0                	jmp    801818 <strchr+0xe>
			return (char *) s;
	return 0;
  801828:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182d:	5d                   	pop    %ebp
  80182e:	c3                   	ret    

0080182f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80182f:	f3 0f 1e fb          	endbr32 
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	8b 45 08             	mov    0x8(%ebp),%eax
  801839:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80183d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801840:	38 ca                	cmp    %cl,%dl
  801842:	74 09                	je     80184d <strfind+0x1e>
  801844:	84 d2                	test   %dl,%dl
  801846:	74 05                	je     80184d <strfind+0x1e>
	for (; *s; s++)
  801848:	83 c0 01             	add    $0x1,%eax
  80184b:	eb f0                	jmp    80183d <strfind+0xe>
			break;
	return (char *) s;
}
  80184d:	5d                   	pop    %ebp
  80184e:	c3                   	ret    

0080184f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80184f:	f3 0f 1e fb          	endbr32 
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	57                   	push   %edi
  801857:	56                   	push   %esi
  801858:	53                   	push   %ebx
  801859:	8b 55 08             	mov    0x8(%ebp),%edx
  80185c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80185f:	85 c9                	test   %ecx,%ecx
  801861:	74 33                	je     801896 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801863:	89 d0                	mov    %edx,%eax
  801865:	09 c8                	or     %ecx,%eax
  801867:	a8 03                	test   $0x3,%al
  801869:	75 23                	jne    80188e <memset+0x3f>
		c &= 0xFF;
  80186b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80186f:	89 d8                	mov    %ebx,%eax
  801871:	c1 e0 08             	shl    $0x8,%eax
  801874:	89 df                	mov    %ebx,%edi
  801876:	c1 e7 18             	shl    $0x18,%edi
  801879:	89 de                	mov    %ebx,%esi
  80187b:	c1 e6 10             	shl    $0x10,%esi
  80187e:	09 f7                	or     %esi,%edi
  801880:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  801882:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801885:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  801887:	89 d7                	mov    %edx,%edi
  801889:	fc                   	cld    
  80188a:	f3 ab                	rep stos %eax,%es:(%edi)
  80188c:	eb 08                	jmp    801896 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80188e:	89 d7                	mov    %edx,%edi
  801890:	8b 45 0c             	mov    0xc(%ebp),%eax
  801893:	fc                   	cld    
  801894:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  801896:	89 d0                	mov    %edx,%eax
  801898:	5b                   	pop    %ebx
  801899:	5e                   	pop    %esi
  80189a:	5f                   	pop    %edi
  80189b:	5d                   	pop    %ebp
  80189c:	c3                   	ret    

0080189d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80189d:	f3 0f 1e fb          	endbr32 
  8018a1:	55                   	push   %ebp
  8018a2:	89 e5                	mov    %esp,%ebp
  8018a4:	57                   	push   %edi
  8018a5:	56                   	push   %esi
  8018a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018af:	39 c6                	cmp    %eax,%esi
  8018b1:	73 32                	jae    8018e5 <memmove+0x48>
  8018b3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018b6:	39 c2                	cmp    %eax,%edx
  8018b8:	76 2b                	jbe    8018e5 <memmove+0x48>
		s += n;
		d += n;
  8018ba:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018bd:	89 fe                	mov    %edi,%esi
  8018bf:	09 ce                	or     %ecx,%esi
  8018c1:	09 d6                	or     %edx,%esi
  8018c3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018c9:	75 0e                	jne    8018d9 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018cb:	83 ef 04             	sub    $0x4,%edi
  8018ce:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018d1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018d4:	fd                   	std    
  8018d5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d7:	eb 09                	jmp    8018e2 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018d9:	83 ef 01             	sub    $0x1,%edi
  8018dc:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018df:	fd                   	std    
  8018e0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018e2:	fc                   	cld    
  8018e3:	eb 1a                	jmp    8018ff <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e5:	89 c2                	mov    %eax,%edx
  8018e7:	09 ca                	or     %ecx,%edx
  8018e9:	09 f2                	or     %esi,%edx
  8018eb:	f6 c2 03             	test   $0x3,%dl
  8018ee:	75 0a                	jne    8018fa <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018f0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018f3:	89 c7                	mov    %eax,%edi
  8018f5:	fc                   	cld    
  8018f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018f8:	eb 05                	jmp    8018ff <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8018fa:	89 c7                	mov    %eax,%edi
  8018fc:	fc                   	cld    
  8018fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018ff:	5e                   	pop    %esi
  801900:	5f                   	pop    %edi
  801901:	5d                   	pop    %ebp
  801902:	c3                   	ret    

00801903 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801903:	f3 0f 1e fb          	endbr32 
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80190d:	ff 75 10             	pushl  0x10(%ebp)
  801910:	ff 75 0c             	pushl  0xc(%ebp)
  801913:	ff 75 08             	pushl  0x8(%ebp)
  801916:	e8 82 ff ff ff       	call   80189d <memmove>
}
  80191b:	c9                   	leave  
  80191c:	c3                   	ret    

0080191d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80191d:	f3 0f 1e fb          	endbr32 
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	56                   	push   %esi
  801925:	53                   	push   %ebx
  801926:	8b 45 08             	mov    0x8(%ebp),%eax
  801929:	8b 55 0c             	mov    0xc(%ebp),%edx
  80192c:	89 c6                	mov    %eax,%esi
  80192e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801931:	39 f0                	cmp    %esi,%eax
  801933:	74 1c                	je     801951 <memcmp+0x34>
		if (*s1 != *s2)
  801935:	0f b6 08             	movzbl (%eax),%ecx
  801938:	0f b6 1a             	movzbl (%edx),%ebx
  80193b:	38 d9                	cmp    %bl,%cl
  80193d:	75 08                	jne    801947 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80193f:	83 c0 01             	add    $0x1,%eax
  801942:	83 c2 01             	add    $0x1,%edx
  801945:	eb ea                	jmp    801931 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801947:	0f b6 c1             	movzbl %cl,%eax
  80194a:	0f b6 db             	movzbl %bl,%ebx
  80194d:	29 d8                	sub    %ebx,%eax
  80194f:	eb 05                	jmp    801956 <memcmp+0x39>
	}

	return 0;
  801951:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801956:	5b                   	pop    %ebx
  801957:	5e                   	pop    %esi
  801958:	5d                   	pop    %ebp
  801959:	c3                   	ret    

0080195a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80195a:	f3 0f 1e fb          	endbr32 
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	8b 45 08             	mov    0x8(%ebp),%eax
  801964:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801967:	89 c2                	mov    %eax,%edx
  801969:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80196c:	39 d0                	cmp    %edx,%eax
  80196e:	73 09                	jae    801979 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801970:	38 08                	cmp    %cl,(%eax)
  801972:	74 05                	je     801979 <memfind+0x1f>
	for (; s < ends; s++)
  801974:	83 c0 01             	add    $0x1,%eax
  801977:	eb f3                	jmp    80196c <memfind+0x12>
			break;
	return (void *) s;
}
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80197b:	f3 0f 1e fb          	endbr32 
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	57                   	push   %edi
  801983:	56                   	push   %esi
  801984:	53                   	push   %ebx
  801985:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801988:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80198b:	eb 03                	jmp    801990 <strtol+0x15>
		s++;
  80198d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801990:	0f b6 01             	movzbl (%ecx),%eax
  801993:	3c 20                	cmp    $0x20,%al
  801995:	74 f6                	je     80198d <strtol+0x12>
  801997:	3c 09                	cmp    $0x9,%al
  801999:	74 f2                	je     80198d <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  80199b:	3c 2b                	cmp    $0x2b,%al
  80199d:	74 2a                	je     8019c9 <strtol+0x4e>
	int neg = 0;
  80199f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8019a4:	3c 2d                	cmp    $0x2d,%al
  8019a6:	74 2b                	je     8019d3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019a8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019ae:	75 0f                	jne    8019bf <strtol+0x44>
  8019b0:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b3:	74 28                	je     8019dd <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019b5:	85 db                	test   %ebx,%ebx
  8019b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019bc:	0f 44 d8             	cmove  %eax,%ebx
  8019bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019c7:	eb 46                	jmp    801a0f <strtol+0x94>
		s++;
  8019c9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019cc:	bf 00 00 00 00       	mov    $0x0,%edi
  8019d1:	eb d5                	jmp    8019a8 <strtol+0x2d>
		s++, neg = 1;
  8019d3:	83 c1 01             	add    $0x1,%ecx
  8019d6:	bf 01 00 00 00       	mov    $0x1,%edi
  8019db:	eb cb                	jmp    8019a8 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019dd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019e1:	74 0e                	je     8019f1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019e3:	85 db                	test   %ebx,%ebx
  8019e5:	75 d8                	jne    8019bf <strtol+0x44>
		s++, base = 8;
  8019e7:	83 c1 01             	add    $0x1,%ecx
  8019ea:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019ef:	eb ce                	jmp    8019bf <strtol+0x44>
		s += 2, base = 16;
  8019f1:	83 c1 02             	add    $0x2,%ecx
  8019f4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019f9:	eb c4                	jmp    8019bf <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019fb:	0f be d2             	movsbl %dl,%edx
  8019fe:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a01:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a04:	7d 3a                	jge    801a40 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801a06:	83 c1 01             	add    $0x1,%ecx
  801a09:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a0d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a0f:	0f b6 11             	movzbl (%ecx),%edx
  801a12:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a15:	89 f3                	mov    %esi,%ebx
  801a17:	80 fb 09             	cmp    $0x9,%bl
  801a1a:	76 df                	jbe    8019fb <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801a1c:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a1f:	89 f3                	mov    %esi,%ebx
  801a21:	80 fb 19             	cmp    $0x19,%bl
  801a24:	77 08                	ja     801a2e <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a26:	0f be d2             	movsbl %dl,%edx
  801a29:	83 ea 57             	sub    $0x57,%edx
  801a2c:	eb d3                	jmp    801a01 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801a2e:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a31:	89 f3                	mov    %esi,%ebx
  801a33:	80 fb 19             	cmp    $0x19,%bl
  801a36:	77 08                	ja     801a40 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a38:	0f be d2             	movsbl %dl,%edx
  801a3b:	83 ea 37             	sub    $0x37,%edx
  801a3e:	eb c1                	jmp    801a01 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a44:	74 05                	je     801a4b <strtol+0xd0>
		*endptr = (char *) s;
  801a46:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a49:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a4b:	89 c2                	mov    %eax,%edx
  801a4d:	f7 da                	neg    %edx
  801a4f:	85 ff                	test   %edi,%edi
  801a51:	0f 45 c2             	cmovne %edx,%eax
}
  801a54:	5b                   	pop    %ebx
  801a55:	5e                   	pop    %esi
  801a56:	5f                   	pop    %edi
  801a57:	5d                   	pop    %ebp
  801a58:	c3                   	ret    

00801a59 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a59:	f3 0f 1e fb          	endbr32 
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	56                   	push   %esi
  801a61:	53                   	push   %ebx
  801a62:	8b 75 08             	mov    0x8(%ebp),%esi
  801a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a72:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801a75:	83 ec 0c             	sub    $0xc,%esp
  801a78:	50                   	push   %eax
  801a79:	e8 82 e8 ff ff       	call   800300 <sys_ipc_recv>
	if (f < 0) {
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	85 c0                	test   %eax,%eax
  801a83:	78 2b                	js     801ab0 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801a85:	85 f6                	test   %esi,%esi
  801a87:	74 0a                	je     801a93 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801a89:	a1 04 40 80 00       	mov    0x804004,%eax
  801a8e:	8b 40 74             	mov    0x74(%eax),%eax
  801a91:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801a93:	85 db                	test   %ebx,%ebx
  801a95:	74 0a                	je     801aa1 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801a97:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9c:	8b 40 78             	mov    0x78(%eax),%eax
  801a9f:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  801aa1:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa6:	8b 40 70             	mov    0x70(%eax),%eax
}
  801aa9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aac:	5b                   	pop    %ebx
  801aad:	5e                   	pop    %esi
  801aae:	5d                   	pop    %ebp
  801aaf:	c3                   	ret    
		if (from_env_store != NULL) {
  801ab0:	85 f6                	test   %esi,%esi
  801ab2:	74 06                	je     801aba <ipc_recv+0x61>
			*from_env_store = 0;
  801ab4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801aba:	85 db                	test   %ebx,%ebx
  801abc:	74 eb                	je     801aa9 <ipc_recv+0x50>
			*perm_store = 0;
  801abe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ac4:	eb e3                	jmp    801aa9 <ipc_recv+0x50>

00801ac6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ac6:	f3 0f 1e fb          	endbr32 
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	57                   	push   %edi
  801ace:	56                   	push   %esi
  801acf:	53                   	push   %ebx
  801ad0:	83 ec 0c             	sub    $0xc,%esp
  801ad3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ad6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ad9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  801adc:	85 db                	test   %ebx,%ebx
  801ade:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ae3:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801ae6:	ff 75 14             	pushl  0x14(%ebp)
  801ae9:	53                   	push   %ebx
  801aea:	56                   	push   %esi
  801aeb:	57                   	push   %edi
  801aec:	e8 e6 e7 ff ff       	call   8002d7 <sys_ipc_try_send>
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	85 c0                	test   %eax,%eax
  801af6:	79 19                	jns    801b11 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  801af8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801afb:	74 e9                	je     801ae6 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  801afd:	83 ec 04             	sub    $0x4,%esp
  801b00:	68 40 22 80 00       	push   $0x802240
  801b05:	6a 48                	push   $0x48
  801b07:	68 62 22 80 00       	push   $0x802262
  801b0c:	e8 83 f5 ff ff       	call   801094 <_panic>
		}
	}
}
  801b11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b14:	5b                   	pop    %ebx
  801b15:	5e                   	pop    %esi
  801b16:	5f                   	pop    %edi
  801b17:	5d                   	pop    %ebp
  801b18:	c3                   	ret    

00801b19 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b19:	f3 0f 1e fb          	endbr32 
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b23:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b28:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b2b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b31:	8b 52 50             	mov    0x50(%edx),%edx
  801b34:	39 ca                	cmp    %ecx,%edx
  801b36:	74 11                	je     801b49 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801b38:	83 c0 01             	add    $0x1,%eax
  801b3b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b40:	75 e6                	jne    801b28 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b42:	b8 00 00 00 00       	mov    $0x0,%eax
  801b47:	eb 0b                	jmp    801b54 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b49:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b4c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b51:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b54:	5d                   	pop    %ebp
  801b55:	c3                   	ret    

00801b56 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b56:	f3 0f 1e fb          	endbr32 
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b60:	89 c2                	mov    %eax,%edx
  801b62:	c1 ea 16             	shr    $0x16,%edx
  801b65:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b6c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b71:	f6 c1 01             	test   $0x1,%cl
  801b74:	74 1c                	je     801b92 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b76:	c1 e8 0c             	shr    $0xc,%eax
  801b79:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b80:	a8 01                	test   $0x1,%al
  801b82:	74 0e                	je     801b92 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b84:	c1 e8 0c             	shr    $0xc,%eax
  801b87:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b8e:	ef 
  801b8f:	0f b7 d2             	movzwl %dx,%edx
}
  801b92:	89 d0                	mov    %edx,%eax
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    
  801b96:	66 90                	xchg   %ax,%ax
  801b98:	66 90                	xchg   %ax,%ax
  801b9a:	66 90                	xchg   %ax,%ax
  801b9c:	66 90                	xchg   %ax,%ax
  801b9e:	66 90                	xchg   %ax,%ax

00801ba0 <__udivdi3>:
  801ba0:	f3 0f 1e fb          	endbr32 
  801ba4:	55                   	push   %ebp
  801ba5:	57                   	push   %edi
  801ba6:	56                   	push   %esi
  801ba7:	53                   	push   %ebx
  801ba8:	83 ec 1c             	sub    $0x1c,%esp
  801bab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801baf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801bb3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801bb7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801bbb:	85 d2                	test   %edx,%edx
  801bbd:	75 19                	jne    801bd8 <__udivdi3+0x38>
  801bbf:	39 f3                	cmp    %esi,%ebx
  801bc1:	76 4d                	jbe    801c10 <__udivdi3+0x70>
  801bc3:	31 ff                	xor    %edi,%edi
  801bc5:	89 e8                	mov    %ebp,%eax
  801bc7:	89 f2                	mov    %esi,%edx
  801bc9:	f7 f3                	div    %ebx
  801bcb:	89 fa                	mov    %edi,%edx
  801bcd:	83 c4 1c             	add    $0x1c,%esp
  801bd0:	5b                   	pop    %ebx
  801bd1:	5e                   	pop    %esi
  801bd2:	5f                   	pop    %edi
  801bd3:	5d                   	pop    %ebp
  801bd4:	c3                   	ret    
  801bd5:	8d 76 00             	lea    0x0(%esi),%esi
  801bd8:	39 f2                	cmp    %esi,%edx
  801bda:	76 14                	jbe    801bf0 <__udivdi3+0x50>
  801bdc:	31 ff                	xor    %edi,%edi
  801bde:	31 c0                	xor    %eax,%eax
  801be0:	89 fa                	mov    %edi,%edx
  801be2:	83 c4 1c             	add    $0x1c,%esp
  801be5:	5b                   	pop    %ebx
  801be6:	5e                   	pop    %esi
  801be7:	5f                   	pop    %edi
  801be8:	5d                   	pop    %ebp
  801be9:	c3                   	ret    
  801bea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bf0:	0f bd fa             	bsr    %edx,%edi
  801bf3:	83 f7 1f             	xor    $0x1f,%edi
  801bf6:	75 48                	jne    801c40 <__udivdi3+0xa0>
  801bf8:	39 f2                	cmp    %esi,%edx
  801bfa:	72 06                	jb     801c02 <__udivdi3+0x62>
  801bfc:	31 c0                	xor    %eax,%eax
  801bfe:	39 eb                	cmp    %ebp,%ebx
  801c00:	77 de                	ja     801be0 <__udivdi3+0x40>
  801c02:	b8 01 00 00 00       	mov    $0x1,%eax
  801c07:	eb d7                	jmp    801be0 <__udivdi3+0x40>
  801c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c10:	89 d9                	mov    %ebx,%ecx
  801c12:	85 db                	test   %ebx,%ebx
  801c14:	75 0b                	jne    801c21 <__udivdi3+0x81>
  801c16:	b8 01 00 00 00       	mov    $0x1,%eax
  801c1b:	31 d2                	xor    %edx,%edx
  801c1d:	f7 f3                	div    %ebx
  801c1f:	89 c1                	mov    %eax,%ecx
  801c21:	31 d2                	xor    %edx,%edx
  801c23:	89 f0                	mov    %esi,%eax
  801c25:	f7 f1                	div    %ecx
  801c27:	89 c6                	mov    %eax,%esi
  801c29:	89 e8                	mov    %ebp,%eax
  801c2b:	89 f7                	mov    %esi,%edi
  801c2d:	f7 f1                	div    %ecx
  801c2f:	89 fa                	mov    %edi,%edx
  801c31:	83 c4 1c             	add    $0x1c,%esp
  801c34:	5b                   	pop    %ebx
  801c35:	5e                   	pop    %esi
  801c36:	5f                   	pop    %edi
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    
  801c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c40:	89 f9                	mov    %edi,%ecx
  801c42:	b8 20 00 00 00       	mov    $0x20,%eax
  801c47:	29 f8                	sub    %edi,%eax
  801c49:	d3 e2                	shl    %cl,%edx
  801c4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c4f:	89 c1                	mov    %eax,%ecx
  801c51:	89 da                	mov    %ebx,%edx
  801c53:	d3 ea                	shr    %cl,%edx
  801c55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c59:	09 d1                	or     %edx,%ecx
  801c5b:	89 f2                	mov    %esi,%edx
  801c5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c61:	89 f9                	mov    %edi,%ecx
  801c63:	d3 e3                	shl    %cl,%ebx
  801c65:	89 c1                	mov    %eax,%ecx
  801c67:	d3 ea                	shr    %cl,%edx
  801c69:	89 f9                	mov    %edi,%ecx
  801c6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c6f:	89 eb                	mov    %ebp,%ebx
  801c71:	d3 e6                	shl    %cl,%esi
  801c73:	89 c1                	mov    %eax,%ecx
  801c75:	d3 eb                	shr    %cl,%ebx
  801c77:	09 de                	or     %ebx,%esi
  801c79:	89 f0                	mov    %esi,%eax
  801c7b:	f7 74 24 08          	divl   0x8(%esp)
  801c7f:	89 d6                	mov    %edx,%esi
  801c81:	89 c3                	mov    %eax,%ebx
  801c83:	f7 64 24 0c          	mull   0xc(%esp)
  801c87:	39 d6                	cmp    %edx,%esi
  801c89:	72 15                	jb     801ca0 <__udivdi3+0x100>
  801c8b:	89 f9                	mov    %edi,%ecx
  801c8d:	d3 e5                	shl    %cl,%ebp
  801c8f:	39 c5                	cmp    %eax,%ebp
  801c91:	73 04                	jae    801c97 <__udivdi3+0xf7>
  801c93:	39 d6                	cmp    %edx,%esi
  801c95:	74 09                	je     801ca0 <__udivdi3+0x100>
  801c97:	89 d8                	mov    %ebx,%eax
  801c99:	31 ff                	xor    %edi,%edi
  801c9b:	e9 40 ff ff ff       	jmp    801be0 <__udivdi3+0x40>
  801ca0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801ca3:	31 ff                	xor    %edi,%edi
  801ca5:	e9 36 ff ff ff       	jmp    801be0 <__udivdi3+0x40>
  801caa:	66 90                	xchg   %ax,%ax
  801cac:	66 90                	xchg   %ax,%ax
  801cae:	66 90                	xchg   %ax,%ax

00801cb0 <__umoddi3>:
  801cb0:	f3 0f 1e fb          	endbr32 
  801cb4:	55                   	push   %ebp
  801cb5:	57                   	push   %edi
  801cb6:	56                   	push   %esi
  801cb7:	53                   	push   %ebx
  801cb8:	83 ec 1c             	sub    $0x1c,%esp
  801cbb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801cbf:	8b 74 24 30          	mov    0x30(%esp),%esi
  801cc3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801cc7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	75 19                	jne    801ce8 <__umoddi3+0x38>
  801ccf:	39 df                	cmp    %ebx,%edi
  801cd1:	76 5d                	jbe    801d30 <__umoddi3+0x80>
  801cd3:	89 f0                	mov    %esi,%eax
  801cd5:	89 da                	mov    %ebx,%edx
  801cd7:	f7 f7                	div    %edi
  801cd9:	89 d0                	mov    %edx,%eax
  801cdb:	31 d2                	xor    %edx,%edx
  801cdd:	83 c4 1c             	add    $0x1c,%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5f                   	pop    %edi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    
  801ce5:	8d 76 00             	lea    0x0(%esi),%esi
  801ce8:	89 f2                	mov    %esi,%edx
  801cea:	39 d8                	cmp    %ebx,%eax
  801cec:	76 12                	jbe    801d00 <__umoddi3+0x50>
  801cee:	89 f0                	mov    %esi,%eax
  801cf0:	89 da                	mov    %ebx,%edx
  801cf2:	83 c4 1c             	add    $0x1c,%esp
  801cf5:	5b                   	pop    %ebx
  801cf6:	5e                   	pop    %esi
  801cf7:	5f                   	pop    %edi
  801cf8:	5d                   	pop    %ebp
  801cf9:	c3                   	ret    
  801cfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d00:	0f bd e8             	bsr    %eax,%ebp
  801d03:	83 f5 1f             	xor    $0x1f,%ebp
  801d06:	75 50                	jne    801d58 <__umoddi3+0xa8>
  801d08:	39 d8                	cmp    %ebx,%eax
  801d0a:	0f 82 e0 00 00 00    	jb     801df0 <__umoddi3+0x140>
  801d10:	89 d9                	mov    %ebx,%ecx
  801d12:	39 f7                	cmp    %esi,%edi
  801d14:	0f 86 d6 00 00 00    	jbe    801df0 <__umoddi3+0x140>
  801d1a:	89 d0                	mov    %edx,%eax
  801d1c:	89 ca                	mov    %ecx,%edx
  801d1e:	83 c4 1c             	add    $0x1c,%esp
  801d21:	5b                   	pop    %ebx
  801d22:	5e                   	pop    %esi
  801d23:	5f                   	pop    %edi
  801d24:	5d                   	pop    %ebp
  801d25:	c3                   	ret    
  801d26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d2d:	8d 76 00             	lea    0x0(%esi),%esi
  801d30:	89 fd                	mov    %edi,%ebp
  801d32:	85 ff                	test   %edi,%edi
  801d34:	75 0b                	jne    801d41 <__umoddi3+0x91>
  801d36:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3b:	31 d2                	xor    %edx,%edx
  801d3d:	f7 f7                	div    %edi
  801d3f:	89 c5                	mov    %eax,%ebp
  801d41:	89 d8                	mov    %ebx,%eax
  801d43:	31 d2                	xor    %edx,%edx
  801d45:	f7 f5                	div    %ebp
  801d47:	89 f0                	mov    %esi,%eax
  801d49:	f7 f5                	div    %ebp
  801d4b:	89 d0                	mov    %edx,%eax
  801d4d:	31 d2                	xor    %edx,%edx
  801d4f:	eb 8c                	jmp    801cdd <__umoddi3+0x2d>
  801d51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d58:	89 e9                	mov    %ebp,%ecx
  801d5a:	ba 20 00 00 00       	mov    $0x20,%edx
  801d5f:	29 ea                	sub    %ebp,%edx
  801d61:	d3 e0                	shl    %cl,%eax
  801d63:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d67:	89 d1                	mov    %edx,%ecx
  801d69:	89 f8                	mov    %edi,%eax
  801d6b:	d3 e8                	shr    %cl,%eax
  801d6d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d71:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d75:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d79:	09 c1                	or     %eax,%ecx
  801d7b:	89 d8                	mov    %ebx,%eax
  801d7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d81:	89 e9                	mov    %ebp,%ecx
  801d83:	d3 e7                	shl    %cl,%edi
  801d85:	89 d1                	mov    %edx,%ecx
  801d87:	d3 e8                	shr    %cl,%eax
  801d89:	89 e9                	mov    %ebp,%ecx
  801d8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d8f:	d3 e3                	shl    %cl,%ebx
  801d91:	89 c7                	mov    %eax,%edi
  801d93:	89 d1                	mov    %edx,%ecx
  801d95:	89 f0                	mov    %esi,%eax
  801d97:	d3 e8                	shr    %cl,%eax
  801d99:	89 e9                	mov    %ebp,%ecx
  801d9b:	89 fa                	mov    %edi,%edx
  801d9d:	d3 e6                	shl    %cl,%esi
  801d9f:	09 d8                	or     %ebx,%eax
  801da1:	f7 74 24 08          	divl   0x8(%esp)
  801da5:	89 d1                	mov    %edx,%ecx
  801da7:	89 f3                	mov    %esi,%ebx
  801da9:	f7 64 24 0c          	mull   0xc(%esp)
  801dad:	89 c6                	mov    %eax,%esi
  801daf:	89 d7                	mov    %edx,%edi
  801db1:	39 d1                	cmp    %edx,%ecx
  801db3:	72 06                	jb     801dbb <__umoddi3+0x10b>
  801db5:	75 10                	jne    801dc7 <__umoddi3+0x117>
  801db7:	39 c3                	cmp    %eax,%ebx
  801db9:	73 0c                	jae    801dc7 <__umoddi3+0x117>
  801dbb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801dbf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801dc3:	89 d7                	mov    %edx,%edi
  801dc5:	89 c6                	mov    %eax,%esi
  801dc7:	89 ca                	mov    %ecx,%edx
  801dc9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801dce:	29 f3                	sub    %esi,%ebx
  801dd0:	19 fa                	sbb    %edi,%edx
  801dd2:	89 d0                	mov    %edx,%eax
  801dd4:	d3 e0                	shl    %cl,%eax
  801dd6:	89 e9                	mov    %ebp,%ecx
  801dd8:	d3 eb                	shr    %cl,%ebx
  801dda:	d3 ea                	shr    %cl,%edx
  801ddc:	09 d8                	or     %ebx,%eax
  801dde:	83 c4 1c             	add    $0x1c,%esp
  801de1:	5b                   	pop    %ebx
  801de2:	5e                   	pop    %esi
  801de3:	5f                   	pop    %edi
  801de4:	5d                   	pop    %ebp
  801de5:	c3                   	ret    
  801de6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ded:	8d 76 00             	lea    0x0(%esi),%esi
  801df0:	29 fe                	sub    %edi,%esi
  801df2:	19 c3                	sbb    %eax,%ebx
  801df4:	89 f2                	mov    %esi,%edx
  801df6:	89 d9                	mov    %ebx,%ecx
  801df8:	e9 1d ff ff ff       	jmp    801d1a <__umoddi3+0x6a>
