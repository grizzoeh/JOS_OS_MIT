
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	f3 0f 1e fb          	endbr32 
  80003d:	55                   	push   %ebp
  80003e:	89 e5                	mov    %esp,%ebp
  800040:	56                   	push   %esi
  800041:	53                   	push   %ebx
  800042:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800045:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800048:	e8 19 01 00 00       	call   800166 <sys_getenvid>
	if (id >= 0)
  80004d:	85 c0                	test   %eax,%eax
  80004f:	78 12                	js     800063 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800051:	25 ff 03 00 00       	and    $0x3ff,%eax
  800056:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800059:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800063:	85 db                	test   %ebx,%ebx
  800065:	7e 07                	jle    80006e <libmain+0x35>
		binaryname = argv[0];
  800067:	8b 06                	mov    (%esi),%eax
  800069:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006e:	83 ec 08             	sub    $0x8,%esp
  800071:	56                   	push   %esi
  800072:	53                   	push   %ebx
  800073:	e8 bb ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800078:	e8 0a 00 00 00       	call   800087 <exit>
}
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800083:	5b                   	pop    %ebx
  800084:	5e                   	pop    %esi
  800085:	5d                   	pop    %ebp
  800086:	c3                   	ret    

00800087 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800087:	f3 0f 1e fb          	endbr32 
  80008b:	55                   	push   %ebp
  80008c:	89 e5                	mov    %esp,%ebp
  80008e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800091:	e8 53 04 00 00       	call   8004e9 <close_all>
	sys_env_destroy(0);
  800096:	83 ec 0c             	sub    $0xc,%esp
  800099:	6a 00                	push   $0x0
  80009b:	e8 a0 00 00 00       	call   800140 <sys_env_destroy>
}
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	c9                   	leave  
  8000a4:	c3                   	ret    

008000a5 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a5:	55                   	push   %ebp
  8000a6:	89 e5                	mov    %esp,%ebp
  8000a8:	57                   	push   %edi
  8000a9:	56                   	push   %esi
  8000aa:	53                   	push   %ebx
  8000ab:	83 ec 1c             	sub    $0x1c,%esp
  8000ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000b4:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000bc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000bf:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c8:	74 04                	je     8000ce <syscall+0x29>
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f 08                	jg     8000d6 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d6:	83 ec 0c             	sub    $0xc,%esp
  8000d9:	50                   	push   %eax
  8000da:	ff 75 e0             	pushl  -0x20(%ebp)
  8000dd:	68 ea 1d 80 00       	push   $0x801dea
  8000e2:	6a 23                	push   $0x23
  8000e4:	68 07 1e 80 00       	push   $0x801e07
  8000e9:	e8 76 0f 00 00       	call   801064 <_panic>

008000ee <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000ee:	f3 0f 1e fb          	endbr32 
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000f8:	6a 00                	push   $0x0
  8000fa:	6a 00                	push   $0x0
  8000fc:	6a 00                	push   $0x0
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800104:	ba 00 00 00 00       	mov    $0x0,%edx
  800109:	b8 00 00 00 00       	mov    $0x0,%eax
  80010e:	e8 92 ff ff ff       	call   8000a5 <syscall>
}
  800113:	83 c4 10             	add    $0x10,%esp
  800116:	c9                   	leave  
  800117:	c3                   	ret    

00800118 <sys_cgetc>:

int
sys_cgetc(void)
{
  800118:	f3 0f 1e fb          	endbr32 
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800122:	6a 00                	push   $0x0
  800124:	6a 00                	push   $0x0
  800126:	6a 00                	push   $0x0
  800128:	6a 00                	push   $0x0
  80012a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012f:	ba 00 00 00 00       	mov    $0x0,%edx
  800134:	b8 01 00 00 00       	mov    $0x1,%eax
  800139:	e8 67 ff ff ff       	call   8000a5 <syscall>
}
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800140:	f3 0f 1e fb          	endbr32 
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80014a:	6a 00                	push   $0x0
  80014c:	6a 00                	push   $0x0
  80014e:	6a 00                	push   $0x0
  800150:	6a 00                	push   $0x0
  800152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800155:	ba 01 00 00 00       	mov    $0x1,%edx
  80015a:	b8 03 00 00 00       	mov    $0x3,%eax
  80015f:	e8 41 ff ff ff       	call   8000a5 <syscall>
}
  800164:	c9                   	leave  
  800165:	c3                   	ret    

00800166 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800166:	f3 0f 1e fb          	endbr32 
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800170:	6a 00                	push   $0x0
  800172:	6a 00                	push   $0x0
  800174:	6a 00                	push   $0x0
  800176:	6a 00                	push   $0x0
  800178:	b9 00 00 00 00       	mov    $0x0,%ecx
  80017d:	ba 00 00 00 00       	mov    $0x0,%edx
  800182:	b8 02 00 00 00       	mov    $0x2,%eax
  800187:	e8 19 ff ff ff       	call   8000a5 <syscall>
}
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    

0080018e <sys_yield>:

void
sys_yield(void)
{
  80018e:	f3 0f 1e fb          	endbr32 
  800192:	55                   	push   %ebp
  800193:	89 e5                	mov    %esp,%ebp
  800195:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800198:	6a 00                	push   $0x0
  80019a:	6a 00                	push   $0x0
  80019c:	6a 00                	push   $0x0
  80019e:	6a 00                	push   $0x0
  8001a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001aa:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001af:	e8 f1 fe ff ff       	call   8000a5 <syscall>
}
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001b9:	f3 0f 1e fb          	endbr32 
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001c3:	6a 00                	push   $0x0
  8001c5:	6a 00                	push   $0x0
  8001c7:	ff 75 10             	pushl  0x10(%ebp)
  8001ca:	ff 75 0c             	pushl  0xc(%ebp)
  8001cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d0:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d5:	b8 04 00 00 00       	mov    $0x4,%eax
  8001da:	e8 c6 fe ff ff       	call   8000a5 <syscall>
}
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    

008001e1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e1:	f3 0f 1e fb          	endbr32 
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001eb:	ff 75 18             	pushl  0x18(%ebp)
  8001ee:	ff 75 14             	pushl  0x14(%ebp)
  8001f1:	ff 75 10             	pushl  0x10(%ebp)
  8001f4:	ff 75 0c             	pushl  0xc(%ebp)
  8001f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001fa:	ba 01 00 00 00       	mov    $0x1,%edx
  8001ff:	b8 05 00 00 00       	mov    $0x5,%eax
  800204:	e8 9c fe ff ff       	call   8000a5 <syscall>
}
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020b:	f3 0f 1e fb          	endbr32 
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800215:	6a 00                	push   $0x0
  800217:	6a 00                	push   $0x0
  800219:	6a 00                	push   $0x0
  80021b:	ff 75 0c             	pushl  0xc(%ebp)
  80021e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800221:	ba 01 00 00 00       	mov    $0x1,%edx
  800226:	b8 06 00 00 00       	mov    $0x6,%eax
  80022b:	e8 75 fe ff ff       	call   8000a5 <syscall>
}
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800232:	f3 0f 1e fb          	endbr32 
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80023c:	6a 00                	push   $0x0
  80023e:	6a 00                	push   $0x0
  800240:	6a 00                	push   $0x0
  800242:	ff 75 0c             	pushl  0xc(%ebp)
  800245:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800248:	ba 01 00 00 00       	mov    $0x1,%edx
  80024d:	b8 08 00 00 00       	mov    $0x8,%eax
  800252:	e8 4e fe ff ff       	call   8000a5 <syscall>
}
  800257:	c9                   	leave  
  800258:	c3                   	ret    

00800259 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800259:	f3 0f 1e fb          	endbr32 
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800263:	6a 00                	push   $0x0
  800265:	6a 00                	push   $0x0
  800267:	6a 00                	push   $0x0
  800269:	ff 75 0c             	pushl  0xc(%ebp)
  80026c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80026f:	ba 01 00 00 00       	mov    $0x1,%edx
  800274:	b8 09 00 00 00       	mov    $0x9,%eax
  800279:	e8 27 fe ff ff       	call   8000a5 <syscall>
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800280:	f3 0f 1e fb          	endbr32 
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80028a:	6a 00                	push   $0x0
  80028c:	6a 00                	push   $0x0
  80028e:	6a 00                	push   $0x0
  800290:	ff 75 0c             	pushl  0xc(%ebp)
  800293:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800296:	ba 01 00 00 00       	mov    $0x1,%edx
  80029b:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002a0:	e8 00 fe ff ff       	call   8000a5 <syscall>
}
  8002a5:	c9                   	leave  
  8002a6:	c3                   	ret    

008002a7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a7:	f3 0f 1e fb          	endbr32 
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002b1:	6a 00                	push   $0x0
  8002b3:	ff 75 14             	pushl  0x14(%ebp)
  8002b6:	ff 75 10             	pushl  0x10(%ebp)
  8002b9:	ff 75 0c             	pushl  0xc(%ebp)
  8002bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002c9:	e8 d7 fd ff ff       	call   8000a5 <syscall>
}
  8002ce:	c9                   	leave  
  8002cf:	c3                   	ret    

008002d0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d0:	f3 0f 1e fb          	endbr32 
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002da:	6a 00                	push   $0x0
  8002dc:	6a 00                	push   $0x0
  8002de:	6a 00                	push   $0x0
  8002e0:	6a 00                	push   $0x0
  8002e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e5:	ba 01 00 00 00       	mov    $0x1,%edx
  8002ea:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002ef:	e8 b1 fd ff ff       	call   8000a5 <syscall>
}
  8002f4:	c9                   	leave  
  8002f5:	c3                   	ret    

008002f6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002f6:	f3 0f 1e fb          	endbr32 
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8002fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800300:	05 00 00 00 30       	add    $0x30000000,%eax
  800305:	c1 e8 0c             	shr    $0xc,%eax
}
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80030a:	f3 0f 1e fb          	endbr32 
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800314:	ff 75 08             	pushl  0x8(%ebp)
  800317:	e8 da ff ff ff       	call   8002f6 <fd2num>
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	c1 e0 0c             	shl    $0xc,%eax
  800322:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800327:	c9                   	leave  
  800328:	c3                   	ret    

00800329 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800329:	f3 0f 1e fb          	endbr32 
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800335:	89 c2                	mov    %eax,%edx
  800337:	c1 ea 16             	shr    $0x16,%edx
  80033a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800341:	f6 c2 01             	test   $0x1,%dl
  800344:	74 2d                	je     800373 <fd_alloc+0x4a>
  800346:	89 c2                	mov    %eax,%edx
  800348:	c1 ea 0c             	shr    $0xc,%edx
  80034b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800352:	f6 c2 01             	test   $0x1,%dl
  800355:	74 1c                	je     800373 <fd_alloc+0x4a>
  800357:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80035c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800361:	75 d2                	jne    800335 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800363:	8b 45 08             	mov    0x8(%ebp),%eax
  800366:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80036c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800371:	eb 0a                	jmp    80037d <fd_alloc+0x54>
			*fd_store = fd;
  800373:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800376:	89 01                	mov    %eax,(%ecx)
			return 0;
  800378:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80037f:	f3 0f 1e fb          	endbr32 
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800389:	83 f8 1f             	cmp    $0x1f,%eax
  80038c:	77 30                	ja     8003be <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80038e:	c1 e0 0c             	shl    $0xc,%eax
  800391:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800396:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80039c:	f6 c2 01             	test   $0x1,%dl
  80039f:	74 24                	je     8003c5 <fd_lookup+0x46>
  8003a1:	89 c2                	mov    %eax,%edx
  8003a3:	c1 ea 0c             	shr    $0xc,%edx
  8003a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ad:	f6 c2 01             	test   $0x1,%dl
  8003b0:	74 1a                	je     8003cc <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b5:	89 02                	mov    %eax,(%edx)
	return 0;
  8003b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003bc:	5d                   	pop    %ebp
  8003bd:	c3                   	ret    
		return -E_INVAL;
  8003be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003c3:	eb f7                	jmp    8003bc <fd_lookup+0x3d>
		return -E_INVAL;
  8003c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003ca:	eb f0                	jmp    8003bc <fd_lookup+0x3d>
  8003cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d1:	eb e9                	jmp    8003bc <fd_lookup+0x3d>

008003d3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003d3:	f3 0f 1e fb          	endbr32 
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	83 ec 08             	sub    $0x8,%esp
  8003dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e0:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8003e5:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003ea:	39 08                	cmp    %ecx,(%eax)
  8003ec:	74 33                	je     800421 <dev_lookup+0x4e>
  8003ee:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8003f1:	8b 02                	mov    (%edx),%eax
  8003f3:	85 c0                	test   %eax,%eax
  8003f5:	75 f3                	jne    8003ea <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8003f7:	a1 04 40 80 00       	mov    0x804004,%eax
  8003fc:	8b 40 48             	mov    0x48(%eax),%eax
  8003ff:	83 ec 04             	sub    $0x4,%esp
  800402:	51                   	push   %ecx
  800403:	50                   	push   %eax
  800404:	68 18 1e 80 00       	push   $0x801e18
  800409:	e8 3d 0d 00 00       	call   80114b <cprintf>
	*dev = 0;
  80040e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800411:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800417:	83 c4 10             	add    $0x10,%esp
  80041a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80041f:	c9                   	leave  
  800420:	c3                   	ret    
			*dev = devtab[i];
  800421:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800424:	89 01                	mov    %eax,(%ecx)
			return 0;
  800426:	b8 00 00 00 00       	mov    $0x0,%eax
  80042b:	eb f2                	jmp    80041f <dev_lookup+0x4c>

0080042d <fd_close>:
{
  80042d:	f3 0f 1e fb          	endbr32 
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	57                   	push   %edi
  800435:	56                   	push   %esi
  800436:	53                   	push   %ebx
  800437:	83 ec 28             	sub    $0x28,%esp
  80043a:	8b 75 08             	mov    0x8(%ebp),%esi
  80043d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800440:	56                   	push   %esi
  800441:	e8 b0 fe ff ff       	call   8002f6 <fd2num>
  800446:	83 c4 08             	add    $0x8,%esp
  800449:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80044c:	52                   	push   %edx
  80044d:	50                   	push   %eax
  80044e:	e8 2c ff ff ff       	call   80037f <fd_lookup>
  800453:	89 c3                	mov    %eax,%ebx
  800455:	83 c4 10             	add    $0x10,%esp
  800458:	85 c0                	test   %eax,%eax
  80045a:	78 05                	js     800461 <fd_close+0x34>
	    || fd != fd2)
  80045c:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80045f:	74 16                	je     800477 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800461:	89 f8                	mov    %edi,%eax
  800463:	84 c0                	test   %al,%al
  800465:	b8 00 00 00 00       	mov    $0x0,%eax
  80046a:	0f 44 d8             	cmove  %eax,%ebx
}
  80046d:	89 d8                	mov    %ebx,%eax
  80046f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800472:	5b                   	pop    %ebx
  800473:	5e                   	pop    %esi
  800474:	5f                   	pop    %edi
  800475:	5d                   	pop    %ebp
  800476:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80047d:	50                   	push   %eax
  80047e:	ff 36                	pushl  (%esi)
  800480:	e8 4e ff ff ff       	call   8003d3 <dev_lookup>
  800485:	89 c3                	mov    %eax,%ebx
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	85 c0                	test   %eax,%eax
  80048c:	78 1a                	js     8004a8 <fd_close+0x7b>
		if (dev->dev_close)
  80048e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800491:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800494:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800499:	85 c0                	test   %eax,%eax
  80049b:	74 0b                	je     8004a8 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80049d:	83 ec 0c             	sub    $0xc,%esp
  8004a0:	56                   	push   %esi
  8004a1:	ff d0                	call   *%eax
  8004a3:	89 c3                	mov    %eax,%ebx
  8004a5:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	56                   	push   %esi
  8004ac:	6a 00                	push   $0x0
  8004ae:	e8 58 fd ff ff       	call   80020b <sys_page_unmap>
	return r;
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	eb b5                	jmp    80046d <fd_close+0x40>

008004b8 <close>:

int
close(int fdnum)
{
  8004b8:	f3 0f 1e fb          	endbr32 
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c5:	50                   	push   %eax
  8004c6:	ff 75 08             	pushl  0x8(%ebp)
  8004c9:	e8 b1 fe ff ff       	call   80037f <fd_lookup>
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	79 02                	jns    8004d7 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004d5:	c9                   	leave  
  8004d6:	c3                   	ret    
		return fd_close(fd, 1);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	6a 01                	push   $0x1
  8004dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8004df:	e8 49 ff ff ff       	call   80042d <fd_close>
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	eb ec                	jmp    8004d5 <close+0x1d>

008004e9 <close_all>:

void
close_all(void)
{
  8004e9:	f3 0f 1e fb          	endbr32 
  8004ed:	55                   	push   %ebp
  8004ee:	89 e5                	mov    %esp,%ebp
  8004f0:	53                   	push   %ebx
  8004f1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8004f4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8004f9:	83 ec 0c             	sub    $0xc,%esp
  8004fc:	53                   	push   %ebx
  8004fd:	e8 b6 ff ff ff       	call   8004b8 <close>
	for (i = 0; i < MAXFD; i++)
  800502:	83 c3 01             	add    $0x1,%ebx
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	83 fb 20             	cmp    $0x20,%ebx
  80050b:	75 ec                	jne    8004f9 <close_all+0x10>
}
  80050d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800510:	c9                   	leave  
  800511:	c3                   	ret    

00800512 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800512:	f3 0f 1e fb          	endbr32 
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	57                   	push   %edi
  80051a:	56                   	push   %esi
  80051b:	53                   	push   %ebx
  80051c:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80051f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800522:	50                   	push   %eax
  800523:	ff 75 08             	pushl  0x8(%ebp)
  800526:	e8 54 fe ff ff       	call   80037f <fd_lookup>
  80052b:	89 c3                	mov    %eax,%ebx
  80052d:	83 c4 10             	add    $0x10,%esp
  800530:	85 c0                	test   %eax,%eax
  800532:	0f 88 81 00 00 00    	js     8005b9 <dup+0xa7>
		return r;
	close(newfdnum);
  800538:	83 ec 0c             	sub    $0xc,%esp
  80053b:	ff 75 0c             	pushl  0xc(%ebp)
  80053e:	e8 75 ff ff ff       	call   8004b8 <close>

	newfd = INDEX2FD(newfdnum);
  800543:	8b 75 0c             	mov    0xc(%ebp),%esi
  800546:	c1 e6 0c             	shl    $0xc,%esi
  800549:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80054f:	83 c4 04             	add    $0x4,%esp
  800552:	ff 75 e4             	pushl  -0x1c(%ebp)
  800555:	e8 b0 fd ff ff       	call   80030a <fd2data>
  80055a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80055c:	89 34 24             	mov    %esi,(%esp)
  80055f:	e8 a6 fd ff ff       	call   80030a <fd2data>
  800564:	83 c4 10             	add    $0x10,%esp
  800567:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800569:	89 d8                	mov    %ebx,%eax
  80056b:	c1 e8 16             	shr    $0x16,%eax
  80056e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800575:	a8 01                	test   $0x1,%al
  800577:	74 11                	je     80058a <dup+0x78>
  800579:	89 d8                	mov    %ebx,%eax
  80057b:	c1 e8 0c             	shr    $0xc,%eax
  80057e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800585:	f6 c2 01             	test   $0x1,%dl
  800588:	75 39                	jne    8005c3 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80058a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80058d:	89 d0                	mov    %edx,%eax
  80058f:	c1 e8 0c             	shr    $0xc,%eax
  800592:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800599:	83 ec 0c             	sub    $0xc,%esp
  80059c:	25 07 0e 00 00       	and    $0xe07,%eax
  8005a1:	50                   	push   %eax
  8005a2:	56                   	push   %esi
  8005a3:	6a 00                	push   $0x0
  8005a5:	52                   	push   %edx
  8005a6:	6a 00                	push   $0x0
  8005a8:	e8 34 fc ff ff       	call   8001e1 <sys_page_map>
  8005ad:	89 c3                	mov    %eax,%ebx
  8005af:	83 c4 20             	add    $0x20,%esp
  8005b2:	85 c0                	test   %eax,%eax
  8005b4:	78 31                	js     8005e7 <dup+0xd5>
		goto err;

	return newfdnum;
  8005b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005b9:	89 d8                	mov    %ebx,%eax
  8005bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005be:	5b                   	pop    %ebx
  8005bf:	5e                   	pop    %esi
  8005c0:	5f                   	pop    %edi
  8005c1:	5d                   	pop    %ebp
  8005c2:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005c3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ca:	83 ec 0c             	sub    $0xc,%esp
  8005cd:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d2:	50                   	push   %eax
  8005d3:	57                   	push   %edi
  8005d4:	6a 00                	push   $0x0
  8005d6:	53                   	push   %ebx
  8005d7:	6a 00                	push   $0x0
  8005d9:	e8 03 fc ff ff       	call   8001e1 <sys_page_map>
  8005de:	89 c3                	mov    %eax,%ebx
  8005e0:	83 c4 20             	add    $0x20,%esp
  8005e3:	85 c0                	test   %eax,%eax
  8005e5:	79 a3                	jns    80058a <dup+0x78>
	sys_page_unmap(0, newfd);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	56                   	push   %esi
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 19 fc ff ff       	call   80020b <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005f2:	83 c4 08             	add    $0x8,%esp
  8005f5:	57                   	push   %edi
  8005f6:	6a 00                	push   $0x0
  8005f8:	e8 0e fc ff ff       	call   80020b <sys_page_unmap>
	return r;
  8005fd:	83 c4 10             	add    $0x10,%esp
  800600:	eb b7                	jmp    8005b9 <dup+0xa7>

00800602 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800602:	f3 0f 1e fb          	endbr32 
  800606:	55                   	push   %ebp
  800607:	89 e5                	mov    %esp,%ebp
  800609:	53                   	push   %ebx
  80060a:	83 ec 1c             	sub    $0x1c,%esp
  80060d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800610:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800613:	50                   	push   %eax
  800614:	53                   	push   %ebx
  800615:	e8 65 fd ff ff       	call   80037f <fd_lookup>
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	85 c0                	test   %eax,%eax
  80061f:	78 3f                	js     800660 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800627:	50                   	push   %eax
  800628:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80062b:	ff 30                	pushl  (%eax)
  80062d:	e8 a1 fd ff ff       	call   8003d3 <dev_lookup>
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	85 c0                	test   %eax,%eax
  800637:	78 27                	js     800660 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800639:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80063c:	8b 42 08             	mov    0x8(%edx),%eax
  80063f:	83 e0 03             	and    $0x3,%eax
  800642:	83 f8 01             	cmp    $0x1,%eax
  800645:	74 1e                	je     800665 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800647:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80064a:	8b 40 08             	mov    0x8(%eax),%eax
  80064d:	85 c0                	test   %eax,%eax
  80064f:	74 35                	je     800686 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800651:	83 ec 04             	sub    $0x4,%esp
  800654:	ff 75 10             	pushl  0x10(%ebp)
  800657:	ff 75 0c             	pushl  0xc(%ebp)
  80065a:	52                   	push   %edx
  80065b:	ff d0                	call   *%eax
  80065d:	83 c4 10             	add    $0x10,%esp
}
  800660:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800663:	c9                   	leave  
  800664:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800665:	a1 04 40 80 00       	mov    0x804004,%eax
  80066a:	8b 40 48             	mov    0x48(%eax),%eax
  80066d:	83 ec 04             	sub    $0x4,%esp
  800670:	53                   	push   %ebx
  800671:	50                   	push   %eax
  800672:	68 59 1e 80 00       	push   $0x801e59
  800677:	e8 cf 0a 00 00       	call   80114b <cprintf>
		return -E_INVAL;
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800684:	eb da                	jmp    800660 <read+0x5e>
		return -E_NOT_SUPP;
  800686:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80068b:	eb d3                	jmp    800660 <read+0x5e>

0080068d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80068d:	f3 0f 1e fb          	endbr32 
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
  800694:	57                   	push   %edi
  800695:	56                   	push   %esi
  800696:	53                   	push   %ebx
  800697:	83 ec 0c             	sub    $0xc,%esp
  80069a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80069d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006a5:	eb 02                	jmp    8006a9 <readn+0x1c>
  8006a7:	01 c3                	add    %eax,%ebx
  8006a9:	39 f3                	cmp    %esi,%ebx
  8006ab:	73 21                	jae    8006ce <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ad:	83 ec 04             	sub    $0x4,%esp
  8006b0:	89 f0                	mov    %esi,%eax
  8006b2:	29 d8                	sub    %ebx,%eax
  8006b4:	50                   	push   %eax
  8006b5:	89 d8                	mov    %ebx,%eax
  8006b7:	03 45 0c             	add    0xc(%ebp),%eax
  8006ba:	50                   	push   %eax
  8006bb:	57                   	push   %edi
  8006bc:	e8 41 ff ff ff       	call   800602 <read>
		if (m < 0)
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	85 c0                	test   %eax,%eax
  8006c6:	78 04                	js     8006cc <readn+0x3f>
			return m;
		if (m == 0)
  8006c8:	75 dd                	jne    8006a7 <readn+0x1a>
  8006ca:	eb 02                	jmp    8006ce <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006cc:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006ce:	89 d8                	mov    %ebx,%eax
  8006d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d3:	5b                   	pop    %ebx
  8006d4:	5e                   	pop    %esi
  8006d5:	5f                   	pop    %edi
  8006d6:	5d                   	pop    %ebp
  8006d7:	c3                   	ret    

008006d8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006d8:	f3 0f 1e fb          	endbr32 
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	53                   	push   %ebx
  8006e0:	83 ec 1c             	sub    $0x1c,%esp
  8006e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006e9:	50                   	push   %eax
  8006ea:	53                   	push   %ebx
  8006eb:	e8 8f fc ff ff       	call   80037f <fd_lookup>
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	78 3a                	js     800731 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006fd:	50                   	push   %eax
  8006fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800701:	ff 30                	pushl  (%eax)
  800703:	e8 cb fc ff ff       	call   8003d3 <dev_lookup>
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	85 c0                	test   %eax,%eax
  80070d:	78 22                	js     800731 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80070f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800712:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800716:	74 1e                	je     800736 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800718:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80071b:	8b 52 0c             	mov    0xc(%edx),%edx
  80071e:	85 d2                	test   %edx,%edx
  800720:	74 35                	je     800757 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800722:	83 ec 04             	sub    $0x4,%esp
  800725:	ff 75 10             	pushl  0x10(%ebp)
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	50                   	push   %eax
  80072c:	ff d2                	call   *%edx
  80072e:	83 c4 10             	add    $0x10,%esp
}
  800731:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800734:	c9                   	leave  
  800735:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800736:	a1 04 40 80 00       	mov    0x804004,%eax
  80073b:	8b 40 48             	mov    0x48(%eax),%eax
  80073e:	83 ec 04             	sub    $0x4,%esp
  800741:	53                   	push   %ebx
  800742:	50                   	push   %eax
  800743:	68 75 1e 80 00       	push   $0x801e75
  800748:	e8 fe 09 00 00       	call   80114b <cprintf>
		return -E_INVAL;
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800755:	eb da                	jmp    800731 <write+0x59>
		return -E_NOT_SUPP;
  800757:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80075c:	eb d3                	jmp    800731 <write+0x59>

0080075e <seek>:

int
seek(int fdnum, off_t offset)
{
  80075e:	f3 0f 1e fb          	endbr32 
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800768:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076b:	50                   	push   %eax
  80076c:	ff 75 08             	pushl  0x8(%ebp)
  80076f:	e8 0b fc ff ff       	call   80037f <fd_lookup>
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	85 c0                	test   %eax,%eax
  800779:	78 0e                	js     800789 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80077b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80077e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800781:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800784:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800789:	c9                   	leave  
  80078a:	c3                   	ret    

0080078b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80078b:	f3 0f 1e fb          	endbr32 
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	53                   	push   %ebx
  800793:	83 ec 1c             	sub    $0x1c,%esp
  800796:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800799:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80079c:	50                   	push   %eax
  80079d:	53                   	push   %ebx
  80079e:	e8 dc fb ff ff       	call   80037f <fd_lookup>
  8007a3:	83 c4 10             	add    $0x10,%esp
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	78 37                	js     8007e1 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007aa:	83 ec 08             	sub    $0x8,%esp
  8007ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007b0:	50                   	push   %eax
  8007b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b4:	ff 30                	pushl  (%eax)
  8007b6:	e8 18 fc ff ff       	call   8003d3 <dev_lookup>
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	85 c0                	test   %eax,%eax
  8007c0:	78 1f                	js     8007e1 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007c9:	74 1b                	je     8007e6 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ce:	8b 52 18             	mov    0x18(%edx),%edx
  8007d1:	85 d2                	test   %edx,%edx
  8007d3:	74 32                	je     800807 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007d5:	83 ec 08             	sub    $0x8,%esp
  8007d8:	ff 75 0c             	pushl  0xc(%ebp)
  8007db:	50                   	push   %eax
  8007dc:	ff d2                	call   *%edx
  8007de:	83 c4 10             	add    $0x10,%esp
}
  8007e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e4:	c9                   	leave  
  8007e5:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007e6:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007eb:	8b 40 48             	mov    0x48(%eax),%eax
  8007ee:	83 ec 04             	sub    $0x4,%esp
  8007f1:	53                   	push   %ebx
  8007f2:	50                   	push   %eax
  8007f3:	68 38 1e 80 00       	push   $0x801e38
  8007f8:	e8 4e 09 00 00       	call   80114b <cprintf>
		return -E_INVAL;
  8007fd:	83 c4 10             	add    $0x10,%esp
  800800:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800805:	eb da                	jmp    8007e1 <ftruncate+0x56>
		return -E_NOT_SUPP;
  800807:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80080c:	eb d3                	jmp    8007e1 <ftruncate+0x56>

0080080e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80080e:	f3 0f 1e fb          	endbr32 
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	83 ec 1c             	sub    $0x1c,%esp
  800819:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80081c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80081f:	50                   	push   %eax
  800820:	ff 75 08             	pushl  0x8(%ebp)
  800823:	e8 57 fb ff ff       	call   80037f <fd_lookup>
  800828:	83 c4 10             	add    $0x10,%esp
  80082b:	85 c0                	test   %eax,%eax
  80082d:	78 4b                	js     80087a <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800835:	50                   	push   %eax
  800836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800839:	ff 30                	pushl  (%eax)
  80083b:	e8 93 fb ff ff       	call   8003d3 <dev_lookup>
  800840:	83 c4 10             	add    $0x10,%esp
  800843:	85 c0                	test   %eax,%eax
  800845:	78 33                	js     80087a <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800847:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80084e:	74 2f                	je     80087f <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800850:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800853:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80085a:	00 00 00 
	stat->st_isdir = 0;
  80085d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800864:	00 00 00 
	stat->st_dev = dev;
  800867:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80086d:	83 ec 08             	sub    $0x8,%esp
  800870:	53                   	push   %ebx
  800871:	ff 75 f0             	pushl  -0x10(%ebp)
  800874:	ff 50 14             	call   *0x14(%eax)
  800877:	83 c4 10             	add    $0x10,%esp
}
  80087a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087d:	c9                   	leave  
  80087e:	c3                   	ret    
		return -E_NOT_SUPP;
  80087f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800884:	eb f4                	jmp    80087a <fstat+0x6c>

00800886 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800886:	f3 0f 1e fb          	endbr32 
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	56                   	push   %esi
  80088e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	6a 00                	push   $0x0
  800894:	ff 75 08             	pushl  0x8(%ebp)
  800897:	e8 20 02 00 00       	call   800abc <open>
  80089c:	89 c3                	mov    %eax,%ebx
  80089e:	83 c4 10             	add    $0x10,%esp
  8008a1:	85 c0                	test   %eax,%eax
  8008a3:	78 1b                	js     8008c0 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	ff 75 0c             	pushl  0xc(%ebp)
  8008ab:	50                   	push   %eax
  8008ac:	e8 5d ff ff ff       	call   80080e <fstat>
  8008b1:	89 c6                	mov    %eax,%esi
	close(fd);
  8008b3:	89 1c 24             	mov    %ebx,(%esp)
  8008b6:	e8 fd fb ff ff       	call   8004b8 <close>
	return r;
  8008bb:	83 c4 10             	add    $0x10,%esp
  8008be:	89 f3                	mov    %esi,%ebx
}
  8008c0:	89 d8                	mov    %ebx,%eax
  8008c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
  8008ce:	89 c6                	mov    %eax,%esi
  8008d0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008d2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008d9:	74 27                	je     800902 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008db:	6a 07                	push   $0x7
  8008dd:	68 00 50 80 00       	push   $0x805000
  8008e2:	56                   	push   %esi
  8008e3:	ff 35 00 40 80 00    	pushl  0x804000
  8008e9:	e8 a8 11 00 00       	call   801a96 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008ee:	83 c4 0c             	add    $0xc,%esp
  8008f1:	6a 00                	push   $0x0
  8008f3:	53                   	push   %ebx
  8008f4:	6a 00                	push   $0x0
  8008f6:	e8 2e 11 00 00       	call   801a29 <ipc_recv>
}
  8008fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008fe:	5b                   	pop    %ebx
  8008ff:	5e                   	pop    %esi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800902:	83 ec 0c             	sub    $0xc,%esp
  800905:	6a 01                	push   $0x1
  800907:	e8 dd 11 00 00       	call   801ae9 <ipc_find_env>
  80090c:	a3 00 40 80 00       	mov    %eax,0x804000
  800911:	83 c4 10             	add    $0x10,%esp
  800914:	eb c5                	jmp    8008db <fsipc+0x12>

00800916 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800916:	f3 0f 1e fb          	endbr32 
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	8b 40 0c             	mov    0xc(%eax),%eax
  800926:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80092b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800933:	ba 00 00 00 00       	mov    $0x0,%edx
  800938:	b8 02 00 00 00       	mov    $0x2,%eax
  80093d:	e8 87 ff ff ff       	call   8008c9 <fsipc>
}
  800942:	c9                   	leave  
  800943:	c3                   	ret    

00800944 <devfile_flush>:
{
  800944:	f3 0f 1e fb          	endbr32 
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 40 0c             	mov    0xc(%eax),%eax
  800954:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
  80095e:	b8 06 00 00 00       	mov    $0x6,%eax
  800963:	e8 61 ff ff ff       	call   8008c9 <fsipc>
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <devfile_stat>:
{
  80096a:	f3 0f 1e fb          	endbr32 
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	53                   	push   %ebx
  800972:	83 ec 04             	sub    $0x4,%esp
  800975:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	8b 40 0c             	mov    0xc(%eax),%eax
  80097e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800983:	ba 00 00 00 00       	mov    $0x0,%edx
  800988:	b8 05 00 00 00       	mov    $0x5,%eax
  80098d:	e8 37 ff ff ff       	call   8008c9 <fsipc>
  800992:	85 c0                	test   %eax,%eax
  800994:	78 2c                	js     8009c2 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800996:	83 ec 08             	sub    $0x8,%esp
  800999:	68 00 50 80 00       	push   $0x805000
  80099e:	53                   	push   %ebx
  80099f:	e8 11 0d 00 00       	call   8016b5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009a4:	a1 80 50 80 00       	mov    0x805080,%eax
  8009a9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009af:	a1 84 50 80 00       	mov    0x805084,%eax
  8009b4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ba:	83 c4 10             	add    $0x10,%esp
  8009bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c5:	c9                   	leave  
  8009c6:	c3                   	ret    

008009c7 <devfile_write>:
{
  8009c7:	f3 0f 1e fb          	endbr32 
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	57                   	push   %edi
  8009cf:	56                   	push   %esi
  8009d0:	53                   	push   %ebx
  8009d1:	83 ec 0c             	sub    $0xc,%esp
  8009d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e0:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8009ea:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  8009ef:	85 db                	test   %ebx,%ebx
  8009f1:	74 3b                	je     800a2e <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8009f3:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8009f9:	89 f8                	mov    %edi,%eax
  8009fb:	0f 46 c3             	cmovbe %ebx,%eax
  8009fe:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  800a03:	83 ec 04             	sub    $0x4,%esp
  800a06:	50                   	push   %eax
  800a07:	56                   	push   %esi
  800a08:	68 08 50 80 00       	push   $0x805008
  800a0d:	e8 5b 0e 00 00       	call   80186d <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800a12:	ba 00 00 00 00       	mov    $0x0,%edx
  800a17:	b8 04 00 00 00       	mov    $0x4,%eax
  800a1c:	e8 a8 fe ff ff       	call   8008c9 <fsipc>
  800a21:	83 c4 10             	add    $0x10,%esp
  800a24:	85 c0                	test   %eax,%eax
  800a26:	78 06                	js     800a2e <devfile_write+0x67>
		buf_aux += r;
  800a28:	01 c6                	add    %eax,%esi
		n -= r;
  800a2a:	29 c3                	sub    %eax,%ebx
  800a2c:	eb c1                	jmp    8009ef <devfile_write+0x28>
}
  800a2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a31:	5b                   	pop    %ebx
  800a32:	5e                   	pop    %esi
  800a33:	5f                   	pop    %edi
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <devfile_read>:
{
  800a36:	f3 0f 1e fb          	endbr32 
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	56                   	push   %esi
  800a3e:	53                   	push   %ebx
  800a3f:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	8b 40 0c             	mov    0xc(%eax),%eax
  800a48:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a4d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a53:	ba 00 00 00 00       	mov    $0x0,%edx
  800a58:	b8 03 00 00 00       	mov    $0x3,%eax
  800a5d:	e8 67 fe ff ff       	call   8008c9 <fsipc>
  800a62:	89 c3                	mov    %eax,%ebx
  800a64:	85 c0                	test   %eax,%eax
  800a66:	78 1f                	js     800a87 <devfile_read+0x51>
	assert(r <= n);
  800a68:	39 f0                	cmp    %esi,%eax
  800a6a:	77 24                	ja     800a90 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a6c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a71:	7f 33                	jg     800aa6 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a73:	83 ec 04             	sub    $0x4,%esp
  800a76:	50                   	push   %eax
  800a77:	68 00 50 80 00       	push   $0x805000
  800a7c:	ff 75 0c             	pushl  0xc(%ebp)
  800a7f:	e8 e9 0d 00 00       	call   80186d <memmove>
	return r;
  800a84:	83 c4 10             	add    $0x10,%esp
}
  800a87:	89 d8                	mov    %ebx,%eax
  800a89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    
	assert(r <= n);
  800a90:	68 a4 1e 80 00       	push   $0x801ea4
  800a95:	68 ab 1e 80 00       	push   $0x801eab
  800a9a:	6a 7c                	push   $0x7c
  800a9c:	68 c0 1e 80 00       	push   $0x801ec0
  800aa1:	e8 be 05 00 00       	call   801064 <_panic>
	assert(r <= PGSIZE);
  800aa6:	68 cb 1e 80 00       	push   $0x801ecb
  800aab:	68 ab 1e 80 00       	push   $0x801eab
  800ab0:	6a 7d                	push   $0x7d
  800ab2:	68 c0 1e 80 00       	push   $0x801ec0
  800ab7:	e8 a8 05 00 00       	call   801064 <_panic>

00800abc <open>:
{
  800abc:	f3 0f 1e fb          	endbr32 
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
  800ac5:	83 ec 1c             	sub    $0x1c,%esp
  800ac8:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800acb:	56                   	push   %esi
  800acc:	e8 a1 0b 00 00       	call   801672 <strlen>
  800ad1:	83 c4 10             	add    $0x10,%esp
  800ad4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ad9:	7f 6c                	jg     800b47 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800adb:	83 ec 0c             	sub    $0xc,%esp
  800ade:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae1:	50                   	push   %eax
  800ae2:	e8 42 f8 ff ff       	call   800329 <fd_alloc>
  800ae7:	89 c3                	mov    %eax,%ebx
  800ae9:	83 c4 10             	add    $0x10,%esp
  800aec:	85 c0                	test   %eax,%eax
  800aee:	78 3c                	js     800b2c <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800af0:	83 ec 08             	sub    $0x8,%esp
  800af3:	56                   	push   %esi
  800af4:	68 00 50 80 00       	push   $0x805000
  800af9:	e8 b7 0b 00 00       	call   8016b5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800afe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b01:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b06:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b09:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0e:	e8 b6 fd ff ff       	call   8008c9 <fsipc>
  800b13:	89 c3                	mov    %eax,%ebx
  800b15:	83 c4 10             	add    $0x10,%esp
  800b18:	85 c0                	test   %eax,%eax
  800b1a:	78 19                	js     800b35 <open+0x79>
	return fd2num(fd);
  800b1c:	83 ec 0c             	sub    $0xc,%esp
  800b1f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b22:	e8 cf f7 ff ff       	call   8002f6 <fd2num>
  800b27:	89 c3                	mov    %eax,%ebx
  800b29:	83 c4 10             	add    $0x10,%esp
}
  800b2c:	89 d8                	mov    %ebx,%eax
  800b2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    
		fd_close(fd, 0);
  800b35:	83 ec 08             	sub    $0x8,%esp
  800b38:	6a 00                	push   $0x0
  800b3a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b3d:	e8 eb f8 ff ff       	call   80042d <fd_close>
		return r;
  800b42:	83 c4 10             	add    $0x10,%esp
  800b45:	eb e5                	jmp    800b2c <open+0x70>
		return -E_BAD_PATH;
  800b47:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b4c:	eb de                	jmp    800b2c <open+0x70>

00800b4e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b4e:	f3 0f 1e fb          	endbr32 
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b58:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5d:	b8 08 00 00 00       	mov    $0x8,%eax
  800b62:	e8 62 fd ff ff       	call   8008c9 <fsipc>
}
  800b67:	c9                   	leave  
  800b68:	c3                   	ret    

00800b69 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b69:	f3 0f 1e fb          	endbr32 
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
  800b72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b75:	83 ec 0c             	sub    $0xc,%esp
  800b78:	ff 75 08             	pushl  0x8(%ebp)
  800b7b:	e8 8a f7 ff ff       	call   80030a <fd2data>
  800b80:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b82:	83 c4 08             	add    $0x8,%esp
  800b85:	68 d7 1e 80 00       	push   $0x801ed7
  800b8a:	53                   	push   %ebx
  800b8b:	e8 25 0b 00 00       	call   8016b5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b90:	8b 46 04             	mov    0x4(%esi),%eax
  800b93:	2b 06                	sub    (%esi),%eax
  800b95:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b9b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ba2:	00 00 00 
	stat->st_dev = &devpipe;
  800ba5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bac:	30 80 00 
	return 0;
}
  800baf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bbb:	f3 0f 1e fb          	endbr32 
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bc9:	53                   	push   %ebx
  800bca:	6a 00                	push   $0x0
  800bcc:	e8 3a f6 ff ff       	call   80020b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bd1:	89 1c 24             	mov    %ebx,(%esp)
  800bd4:	e8 31 f7 ff ff       	call   80030a <fd2data>
  800bd9:	83 c4 08             	add    $0x8,%esp
  800bdc:	50                   	push   %eax
  800bdd:	6a 00                	push   $0x0
  800bdf:	e8 27 f6 ff ff       	call   80020b <sys_page_unmap>
}
  800be4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <_pipeisclosed>:
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 1c             	sub    $0x1c,%esp
  800bf2:	89 c7                	mov    %eax,%edi
  800bf4:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bf6:	a1 04 40 80 00       	mov    0x804004,%eax
  800bfb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bfe:	83 ec 0c             	sub    $0xc,%esp
  800c01:	57                   	push   %edi
  800c02:	e8 1f 0f 00 00       	call   801b26 <pageref>
  800c07:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c0a:	89 34 24             	mov    %esi,(%esp)
  800c0d:	e8 14 0f 00 00       	call   801b26 <pageref>
		nn = thisenv->env_runs;
  800c12:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c18:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c1b:	83 c4 10             	add    $0x10,%esp
  800c1e:	39 cb                	cmp    %ecx,%ebx
  800c20:	74 1b                	je     800c3d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c22:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c25:	75 cf                	jne    800bf6 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c27:	8b 42 58             	mov    0x58(%edx),%eax
  800c2a:	6a 01                	push   $0x1
  800c2c:	50                   	push   %eax
  800c2d:	53                   	push   %ebx
  800c2e:	68 de 1e 80 00       	push   $0x801ede
  800c33:	e8 13 05 00 00       	call   80114b <cprintf>
  800c38:	83 c4 10             	add    $0x10,%esp
  800c3b:	eb b9                	jmp    800bf6 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c3d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c40:	0f 94 c0             	sete   %al
  800c43:	0f b6 c0             	movzbl %al,%eax
}
  800c46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <devpipe_write>:
{
  800c4e:	f3 0f 1e fb          	endbr32 
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 28             	sub    $0x28,%esp
  800c5b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c5e:	56                   	push   %esi
  800c5f:	e8 a6 f6 ff ff       	call   80030a <fd2data>
  800c64:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c66:	83 c4 10             	add    $0x10,%esp
  800c69:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c71:	74 4f                	je     800cc2 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c73:	8b 43 04             	mov    0x4(%ebx),%eax
  800c76:	8b 0b                	mov    (%ebx),%ecx
  800c78:	8d 51 20             	lea    0x20(%ecx),%edx
  800c7b:	39 d0                	cmp    %edx,%eax
  800c7d:	72 14                	jb     800c93 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800c7f:	89 da                	mov    %ebx,%edx
  800c81:	89 f0                	mov    %esi,%eax
  800c83:	e8 61 ff ff ff       	call   800be9 <_pipeisclosed>
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	75 3b                	jne    800cc7 <devpipe_write+0x79>
			sys_yield();
  800c8c:	e8 fd f4 ff ff       	call   80018e <sys_yield>
  800c91:	eb e0                	jmp    800c73 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c9a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c9d:	89 c2                	mov    %eax,%edx
  800c9f:	c1 fa 1f             	sar    $0x1f,%edx
  800ca2:	89 d1                	mov    %edx,%ecx
  800ca4:	c1 e9 1b             	shr    $0x1b,%ecx
  800ca7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800caa:	83 e2 1f             	and    $0x1f,%edx
  800cad:	29 ca                	sub    %ecx,%edx
  800caf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cb3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cb7:	83 c0 01             	add    $0x1,%eax
  800cba:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cbd:	83 c7 01             	add    $0x1,%edi
  800cc0:	eb ac                	jmp    800c6e <devpipe_write+0x20>
	return i;
  800cc2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc5:	eb 05                	jmp    800ccc <devpipe_write+0x7e>
				return 0;
  800cc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <devpipe_read>:
{
  800cd4:	f3 0f 1e fb          	endbr32 
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	83 ec 18             	sub    $0x18,%esp
  800ce1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800ce4:	57                   	push   %edi
  800ce5:	e8 20 f6 ff ff       	call   80030a <fd2data>
  800cea:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cec:	83 c4 10             	add    $0x10,%esp
  800cef:	be 00 00 00 00       	mov    $0x0,%esi
  800cf4:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cf7:	75 14                	jne    800d0d <devpipe_read+0x39>
	return i;
  800cf9:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfc:	eb 02                	jmp    800d00 <devpipe_read+0x2c>
				return i;
  800cfe:	89 f0                	mov    %esi,%eax
}
  800d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    
			sys_yield();
  800d08:	e8 81 f4 ff ff       	call   80018e <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d0d:	8b 03                	mov    (%ebx),%eax
  800d0f:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d12:	75 18                	jne    800d2c <devpipe_read+0x58>
			if (i > 0)
  800d14:	85 f6                	test   %esi,%esi
  800d16:	75 e6                	jne    800cfe <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d18:	89 da                	mov    %ebx,%edx
  800d1a:	89 f8                	mov    %edi,%eax
  800d1c:	e8 c8 fe ff ff       	call   800be9 <_pipeisclosed>
  800d21:	85 c0                	test   %eax,%eax
  800d23:	74 e3                	je     800d08 <devpipe_read+0x34>
				return 0;
  800d25:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2a:	eb d4                	jmp    800d00 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d2c:	99                   	cltd   
  800d2d:	c1 ea 1b             	shr    $0x1b,%edx
  800d30:	01 d0                	add    %edx,%eax
  800d32:	83 e0 1f             	and    $0x1f,%eax
  800d35:	29 d0                	sub    %edx,%eax
  800d37:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d42:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d45:	83 c6 01             	add    $0x1,%esi
  800d48:	eb aa                	jmp    800cf4 <devpipe_read+0x20>

00800d4a <pipe>:
{
  800d4a:	f3 0f 1e fb          	endbr32 
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
  800d53:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d56:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d59:	50                   	push   %eax
  800d5a:	e8 ca f5 ff ff       	call   800329 <fd_alloc>
  800d5f:	89 c3                	mov    %eax,%ebx
  800d61:	83 c4 10             	add    $0x10,%esp
  800d64:	85 c0                	test   %eax,%eax
  800d66:	0f 88 23 01 00 00    	js     800e8f <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d6c:	83 ec 04             	sub    $0x4,%esp
  800d6f:	68 07 04 00 00       	push   $0x407
  800d74:	ff 75 f4             	pushl  -0xc(%ebp)
  800d77:	6a 00                	push   $0x0
  800d79:	e8 3b f4 ff ff       	call   8001b9 <sys_page_alloc>
  800d7e:	89 c3                	mov    %eax,%ebx
  800d80:	83 c4 10             	add    $0x10,%esp
  800d83:	85 c0                	test   %eax,%eax
  800d85:	0f 88 04 01 00 00    	js     800e8f <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d91:	50                   	push   %eax
  800d92:	e8 92 f5 ff ff       	call   800329 <fd_alloc>
  800d97:	89 c3                	mov    %eax,%ebx
  800d99:	83 c4 10             	add    $0x10,%esp
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	0f 88 db 00 00 00    	js     800e7f <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da4:	83 ec 04             	sub    $0x4,%esp
  800da7:	68 07 04 00 00       	push   $0x407
  800dac:	ff 75 f0             	pushl  -0x10(%ebp)
  800daf:	6a 00                	push   $0x0
  800db1:	e8 03 f4 ff ff       	call   8001b9 <sys_page_alloc>
  800db6:	89 c3                	mov    %eax,%ebx
  800db8:	83 c4 10             	add    $0x10,%esp
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	0f 88 bc 00 00 00    	js     800e7f <pipe+0x135>
	va = fd2data(fd0);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc9:	e8 3c f5 ff ff       	call   80030a <fd2data>
  800dce:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd0:	83 c4 0c             	add    $0xc,%esp
  800dd3:	68 07 04 00 00       	push   $0x407
  800dd8:	50                   	push   %eax
  800dd9:	6a 00                	push   $0x0
  800ddb:	e8 d9 f3 ff ff       	call   8001b9 <sys_page_alloc>
  800de0:	89 c3                	mov    %eax,%ebx
  800de2:	83 c4 10             	add    $0x10,%esp
  800de5:	85 c0                	test   %eax,%eax
  800de7:	0f 88 82 00 00 00    	js     800e6f <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ded:	83 ec 0c             	sub    $0xc,%esp
  800df0:	ff 75 f0             	pushl  -0x10(%ebp)
  800df3:	e8 12 f5 ff ff       	call   80030a <fd2data>
  800df8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dff:	50                   	push   %eax
  800e00:	6a 00                	push   $0x0
  800e02:	56                   	push   %esi
  800e03:	6a 00                	push   $0x0
  800e05:	e8 d7 f3 ff ff       	call   8001e1 <sys_page_map>
  800e0a:	89 c3                	mov    %eax,%ebx
  800e0c:	83 c4 20             	add    $0x20,%esp
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	78 4e                	js     800e61 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e13:	a1 20 30 80 00       	mov    0x803020,%eax
  800e18:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e1b:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e20:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e27:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e2a:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e36:	83 ec 0c             	sub    $0xc,%esp
  800e39:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3c:	e8 b5 f4 ff ff       	call   8002f6 <fd2num>
  800e41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e44:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e46:	83 c4 04             	add    $0x4,%esp
  800e49:	ff 75 f0             	pushl  -0x10(%ebp)
  800e4c:	e8 a5 f4 ff ff       	call   8002f6 <fd2num>
  800e51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e54:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e57:	83 c4 10             	add    $0x10,%esp
  800e5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5f:	eb 2e                	jmp    800e8f <pipe+0x145>
	sys_page_unmap(0, va);
  800e61:	83 ec 08             	sub    $0x8,%esp
  800e64:	56                   	push   %esi
  800e65:	6a 00                	push   $0x0
  800e67:	e8 9f f3 ff ff       	call   80020b <sys_page_unmap>
  800e6c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e6f:	83 ec 08             	sub    $0x8,%esp
  800e72:	ff 75 f0             	pushl  -0x10(%ebp)
  800e75:	6a 00                	push   $0x0
  800e77:	e8 8f f3 ff ff       	call   80020b <sys_page_unmap>
  800e7c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e7f:	83 ec 08             	sub    $0x8,%esp
  800e82:	ff 75 f4             	pushl  -0xc(%ebp)
  800e85:	6a 00                	push   $0x0
  800e87:	e8 7f f3 ff ff       	call   80020b <sys_page_unmap>
  800e8c:	83 c4 10             	add    $0x10,%esp
}
  800e8f:	89 d8                	mov    %ebx,%eax
  800e91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    

00800e98 <pipeisclosed>:
{
  800e98:	f3 0f 1e fb          	endbr32 
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ea2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea5:	50                   	push   %eax
  800ea6:	ff 75 08             	pushl  0x8(%ebp)
  800ea9:	e8 d1 f4 ff ff       	call   80037f <fd_lookup>
  800eae:	83 c4 10             	add    $0x10,%esp
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	78 18                	js     800ecd <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800eb5:	83 ec 0c             	sub    $0xc,%esp
  800eb8:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebb:	e8 4a f4 ff ff       	call   80030a <fd2data>
  800ec0:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ec5:	e8 1f fd ff ff       	call   800be9 <_pipeisclosed>
  800eca:	83 c4 10             	add    $0x10,%esp
}
  800ecd:	c9                   	leave  
  800ece:	c3                   	ret    

00800ecf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ecf:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800ed3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed8:	c3                   	ret    

00800ed9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ed9:	f3 0f 1e fb          	endbr32 
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ee3:	68 f6 1e 80 00       	push   $0x801ef6
  800ee8:	ff 75 0c             	pushl  0xc(%ebp)
  800eeb:	e8 c5 07 00 00       	call   8016b5 <strcpy>
	return 0;
}
  800ef0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <devcons_write>:
{
  800ef7:	f3 0f 1e fb          	endbr32 
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f07:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f0c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f12:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f15:	73 31                	jae    800f48 <devcons_write+0x51>
		m = n - tot;
  800f17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1a:	29 f3                	sub    %esi,%ebx
  800f1c:	83 fb 7f             	cmp    $0x7f,%ebx
  800f1f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f24:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f27:	83 ec 04             	sub    $0x4,%esp
  800f2a:	53                   	push   %ebx
  800f2b:	89 f0                	mov    %esi,%eax
  800f2d:	03 45 0c             	add    0xc(%ebp),%eax
  800f30:	50                   	push   %eax
  800f31:	57                   	push   %edi
  800f32:	e8 36 09 00 00       	call   80186d <memmove>
		sys_cputs(buf, m);
  800f37:	83 c4 08             	add    $0x8,%esp
  800f3a:	53                   	push   %ebx
  800f3b:	57                   	push   %edi
  800f3c:	e8 ad f1 ff ff       	call   8000ee <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f41:	01 de                	add    %ebx,%esi
  800f43:	83 c4 10             	add    $0x10,%esp
  800f46:	eb ca                	jmp    800f12 <devcons_write+0x1b>
}
  800f48:	89 f0                	mov    %esi,%eax
  800f4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5f                   	pop    %edi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    

00800f52 <devcons_read>:
{
  800f52:	f3 0f 1e fb          	endbr32 
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
  800f59:	83 ec 08             	sub    $0x8,%esp
  800f5c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f61:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f65:	74 21                	je     800f88 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800f67:	e8 ac f1 ff ff       	call   800118 <sys_cgetc>
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	75 07                	jne    800f77 <devcons_read+0x25>
		sys_yield();
  800f70:	e8 19 f2 ff ff       	call   80018e <sys_yield>
  800f75:	eb f0                	jmp    800f67 <devcons_read+0x15>
	if (c < 0)
  800f77:	78 0f                	js     800f88 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800f79:	83 f8 04             	cmp    $0x4,%eax
  800f7c:	74 0c                	je     800f8a <devcons_read+0x38>
	*(char*)vbuf = c;
  800f7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f81:	88 02                	mov    %al,(%edx)
	return 1;
  800f83:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f88:	c9                   	leave  
  800f89:	c3                   	ret    
		return 0;
  800f8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f8f:	eb f7                	jmp    800f88 <devcons_read+0x36>

00800f91 <cputchar>:
{
  800f91:	f3 0f 1e fb          	endbr32 
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800fa1:	6a 01                	push   $0x1
  800fa3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa6:	50                   	push   %eax
  800fa7:	e8 42 f1 ff ff       	call   8000ee <sys_cputs>
}
  800fac:	83 c4 10             	add    $0x10,%esp
  800faf:	c9                   	leave  
  800fb0:	c3                   	ret    

00800fb1 <getchar>:
{
  800fb1:	f3 0f 1e fb          	endbr32 
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800fbb:	6a 01                	push   $0x1
  800fbd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc0:	50                   	push   %eax
  800fc1:	6a 00                	push   $0x0
  800fc3:	e8 3a f6 ff ff       	call   800602 <read>
	if (r < 0)
  800fc8:	83 c4 10             	add    $0x10,%esp
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	78 06                	js     800fd5 <getchar+0x24>
	if (r < 1)
  800fcf:	74 06                	je     800fd7 <getchar+0x26>
	return c;
  800fd1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    
		return -E_EOF;
  800fd7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fdc:	eb f7                	jmp    800fd5 <getchar+0x24>

00800fde <iscons>:
{
  800fde:	f3 0f 1e fb          	endbr32 
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800feb:	50                   	push   %eax
  800fec:	ff 75 08             	pushl  0x8(%ebp)
  800fef:	e8 8b f3 ff ff       	call   80037f <fd_lookup>
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	78 11                	js     80100c <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  800ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801004:	39 10                	cmp    %edx,(%eax)
  801006:	0f 94 c0             	sete   %al
  801009:	0f b6 c0             	movzbl %al,%eax
}
  80100c:	c9                   	leave  
  80100d:	c3                   	ret    

0080100e <opencons>:
{
  80100e:	f3 0f 1e fb          	endbr32 
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801018:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80101b:	50                   	push   %eax
  80101c:	e8 08 f3 ff ff       	call   800329 <fd_alloc>
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	85 c0                	test   %eax,%eax
  801026:	78 3a                	js     801062 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801028:	83 ec 04             	sub    $0x4,%esp
  80102b:	68 07 04 00 00       	push   $0x407
  801030:	ff 75 f4             	pushl  -0xc(%ebp)
  801033:	6a 00                	push   $0x0
  801035:	e8 7f f1 ff ff       	call   8001b9 <sys_page_alloc>
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	85 c0                	test   %eax,%eax
  80103f:	78 21                	js     801062 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801041:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801044:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80104a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80104c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801056:	83 ec 0c             	sub    $0xc,%esp
  801059:	50                   	push   %eax
  80105a:	e8 97 f2 ff ff       	call   8002f6 <fd2num>
  80105f:	83 c4 10             	add    $0x10,%esp
}
  801062:	c9                   	leave  
  801063:	c3                   	ret    

00801064 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801064:	f3 0f 1e fb          	endbr32 
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	56                   	push   %esi
  80106c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80106d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801070:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801076:	e8 eb f0 ff ff       	call   800166 <sys_getenvid>
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	ff 75 0c             	pushl  0xc(%ebp)
  801081:	ff 75 08             	pushl  0x8(%ebp)
  801084:	56                   	push   %esi
  801085:	50                   	push   %eax
  801086:	68 04 1f 80 00       	push   $0x801f04
  80108b:	e8 bb 00 00 00       	call   80114b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801090:	83 c4 18             	add    $0x18,%esp
  801093:	53                   	push   %ebx
  801094:	ff 75 10             	pushl  0x10(%ebp)
  801097:	e8 5a 00 00 00       	call   8010f6 <vcprintf>
	cprintf("\n");
  80109c:	c7 04 24 ef 1e 80 00 	movl   $0x801eef,(%esp)
  8010a3:	e8 a3 00 00 00       	call   80114b <cprintf>
  8010a8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010ab:	cc                   	int3   
  8010ac:	eb fd                	jmp    8010ab <_panic+0x47>

008010ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010ae:	f3 0f 1e fb          	endbr32 
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	53                   	push   %ebx
  8010b6:	83 ec 04             	sub    $0x4,%esp
  8010b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010bc:	8b 13                	mov    (%ebx),%edx
  8010be:	8d 42 01             	lea    0x1(%edx),%eax
  8010c1:	89 03                	mov    %eax,(%ebx)
  8010c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010ca:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010cf:	74 09                	je     8010da <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010d1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d8:	c9                   	leave  
  8010d9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010da:	83 ec 08             	sub    $0x8,%esp
  8010dd:	68 ff 00 00 00       	push   $0xff
  8010e2:	8d 43 08             	lea    0x8(%ebx),%eax
  8010e5:	50                   	push   %eax
  8010e6:	e8 03 f0 ff ff       	call   8000ee <sys_cputs>
		b->idx = 0;
  8010eb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010f1:	83 c4 10             	add    $0x10,%esp
  8010f4:	eb db                	jmp    8010d1 <putch+0x23>

008010f6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010f6:	f3 0f 1e fb          	endbr32 
  8010fa:	55                   	push   %ebp
  8010fb:	89 e5                	mov    %esp,%ebp
  8010fd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801103:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80110a:	00 00 00 
	b.cnt = 0;
  80110d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801114:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801117:	ff 75 0c             	pushl  0xc(%ebp)
  80111a:	ff 75 08             	pushl  0x8(%ebp)
  80111d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801123:	50                   	push   %eax
  801124:	68 ae 10 80 00       	push   $0x8010ae
  801129:	e8 80 01 00 00       	call   8012ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80112e:	83 c4 08             	add    $0x8,%esp
  801131:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801137:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80113d:	50                   	push   %eax
  80113e:	e8 ab ef ff ff       	call   8000ee <sys_cputs>

	return b.cnt;
}
  801143:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801149:	c9                   	leave  
  80114a:	c3                   	ret    

0080114b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80114b:	f3 0f 1e fb          	endbr32 
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801155:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801158:	50                   	push   %eax
  801159:	ff 75 08             	pushl  0x8(%ebp)
  80115c:	e8 95 ff ff ff       	call   8010f6 <vcprintf>
	va_end(ap);

	return cnt;
}
  801161:	c9                   	leave  
  801162:	c3                   	ret    

00801163 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	57                   	push   %edi
  801167:	56                   	push   %esi
  801168:	53                   	push   %ebx
  801169:	83 ec 1c             	sub    $0x1c,%esp
  80116c:	89 c7                	mov    %eax,%edi
  80116e:	89 d6                	mov    %edx,%esi
  801170:	8b 45 08             	mov    0x8(%ebp),%eax
  801173:	8b 55 0c             	mov    0xc(%ebp),%edx
  801176:	89 d1                	mov    %edx,%ecx
  801178:	89 c2                	mov    %eax,%edx
  80117a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80117d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801180:	8b 45 10             	mov    0x10(%ebp),%eax
  801183:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801186:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801189:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801190:	39 c2                	cmp    %eax,%edx
  801192:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801195:	72 3e                	jb     8011d5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801197:	83 ec 0c             	sub    $0xc,%esp
  80119a:	ff 75 18             	pushl  0x18(%ebp)
  80119d:	83 eb 01             	sub    $0x1,%ebx
  8011a0:	53                   	push   %ebx
  8011a1:	50                   	push   %eax
  8011a2:	83 ec 08             	sub    $0x8,%esp
  8011a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b1:	e8 ba 09 00 00       	call   801b70 <__udivdi3>
  8011b6:	83 c4 18             	add    $0x18,%esp
  8011b9:	52                   	push   %edx
  8011ba:	50                   	push   %eax
  8011bb:	89 f2                	mov    %esi,%edx
  8011bd:	89 f8                	mov    %edi,%eax
  8011bf:	e8 9f ff ff ff       	call   801163 <printnum>
  8011c4:	83 c4 20             	add    $0x20,%esp
  8011c7:	eb 13                	jmp    8011dc <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011c9:	83 ec 08             	sub    $0x8,%esp
  8011cc:	56                   	push   %esi
  8011cd:	ff 75 18             	pushl  0x18(%ebp)
  8011d0:	ff d7                	call   *%edi
  8011d2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011d5:	83 eb 01             	sub    $0x1,%ebx
  8011d8:	85 db                	test   %ebx,%ebx
  8011da:	7f ed                	jg     8011c9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011dc:	83 ec 08             	sub    $0x8,%esp
  8011df:	56                   	push   %esi
  8011e0:	83 ec 04             	sub    $0x4,%esp
  8011e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8011e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ef:	e8 8c 0a 00 00       	call   801c80 <__umoddi3>
  8011f4:	83 c4 14             	add    $0x14,%esp
  8011f7:	0f be 80 27 1f 80 00 	movsbl 0x801f27(%eax),%eax
  8011fe:	50                   	push   %eax
  8011ff:	ff d7                	call   *%edi
}
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801207:	5b                   	pop    %ebx
  801208:	5e                   	pop    %esi
  801209:	5f                   	pop    %edi
  80120a:	5d                   	pop    %ebp
  80120b:	c3                   	ret    

0080120c <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80120c:	83 fa 01             	cmp    $0x1,%edx
  80120f:	7f 13                	jg     801224 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801211:	85 d2                	test   %edx,%edx
  801213:	74 1c                	je     801231 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  801215:	8b 10                	mov    (%eax),%edx
  801217:	8d 4a 04             	lea    0x4(%edx),%ecx
  80121a:	89 08                	mov    %ecx,(%eax)
  80121c:	8b 02                	mov    (%edx),%eax
  80121e:	ba 00 00 00 00       	mov    $0x0,%edx
  801223:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  801224:	8b 10                	mov    (%eax),%edx
  801226:	8d 4a 08             	lea    0x8(%edx),%ecx
  801229:	89 08                	mov    %ecx,(%eax)
  80122b:	8b 02                	mov    (%edx),%eax
  80122d:	8b 52 04             	mov    0x4(%edx),%edx
  801230:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  801231:	8b 10                	mov    (%eax),%edx
  801233:	8d 4a 04             	lea    0x4(%edx),%ecx
  801236:	89 08                	mov    %ecx,(%eax)
  801238:	8b 02                	mov    (%edx),%eax
  80123a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80123f:	c3                   	ret    

00801240 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801240:	83 fa 01             	cmp    $0x1,%edx
  801243:	7f 0f                	jg     801254 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  801245:	85 d2                	test   %edx,%edx
  801247:	74 18                	je     801261 <getint+0x21>
		return va_arg(*ap, long);
  801249:	8b 10                	mov    (%eax),%edx
  80124b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80124e:	89 08                	mov    %ecx,(%eax)
  801250:	8b 02                	mov    (%edx),%eax
  801252:	99                   	cltd   
  801253:	c3                   	ret    
		return va_arg(*ap, long long);
  801254:	8b 10                	mov    (%eax),%edx
  801256:	8d 4a 08             	lea    0x8(%edx),%ecx
  801259:	89 08                	mov    %ecx,(%eax)
  80125b:	8b 02                	mov    (%edx),%eax
  80125d:	8b 52 04             	mov    0x4(%edx),%edx
  801260:	c3                   	ret    
	else
		return va_arg(*ap, int);
  801261:	8b 10                	mov    (%eax),%edx
  801263:	8d 4a 04             	lea    0x4(%edx),%ecx
  801266:	89 08                	mov    %ecx,(%eax)
  801268:	8b 02                	mov    (%edx),%eax
  80126a:	99                   	cltd   
}
  80126b:	c3                   	ret    

0080126c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80126c:	f3 0f 1e fb          	endbr32 
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801276:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80127a:	8b 10                	mov    (%eax),%edx
  80127c:	3b 50 04             	cmp    0x4(%eax),%edx
  80127f:	73 0a                	jae    80128b <sprintputch+0x1f>
		*b->buf++ = ch;
  801281:	8d 4a 01             	lea    0x1(%edx),%ecx
  801284:	89 08                	mov    %ecx,(%eax)
  801286:	8b 45 08             	mov    0x8(%ebp),%eax
  801289:	88 02                	mov    %al,(%edx)
}
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <printfmt>:
{
  80128d:	f3 0f 1e fb          	endbr32 
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801297:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80129a:	50                   	push   %eax
  80129b:	ff 75 10             	pushl  0x10(%ebp)
  80129e:	ff 75 0c             	pushl  0xc(%ebp)
  8012a1:	ff 75 08             	pushl  0x8(%ebp)
  8012a4:	e8 05 00 00 00       	call   8012ae <vprintfmt>
}
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	c9                   	leave  
  8012ad:	c3                   	ret    

008012ae <vprintfmt>:
{
  8012ae:	f3 0f 1e fb          	endbr32 
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	57                   	push   %edi
  8012b6:	56                   	push   %esi
  8012b7:	53                   	push   %ebx
  8012b8:	83 ec 2c             	sub    $0x2c,%esp
  8012bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012be:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012c1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012c4:	e9 86 02 00 00       	jmp    80154f <vprintfmt+0x2a1>
		padc = ' ';
  8012c9:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012cd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012d4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012db:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012e2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012e7:	8d 47 01             	lea    0x1(%edi),%eax
  8012ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012ed:	0f b6 17             	movzbl (%edi),%edx
  8012f0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012f3:	3c 55                	cmp    $0x55,%al
  8012f5:	0f 87 df 02 00 00    	ja     8015da <vprintfmt+0x32c>
  8012fb:	0f b6 c0             	movzbl %al,%eax
  8012fe:	3e ff 24 85 60 20 80 	notrack jmp *0x802060(,%eax,4)
  801305:	00 
  801306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801309:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80130d:	eb d8                	jmp    8012e7 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80130f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801312:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801316:	eb cf                	jmp    8012e7 <vprintfmt+0x39>
  801318:	0f b6 d2             	movzbl %dl,%edx
  80131b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80131e:	b8 00 00 00 00       	mov    $0x0,%eax
  801323:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801326:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801329:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80132d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801330:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801333:	83 f9 09             	cmp    $0x9,%ecx
  801336:	77 52                	ja     80138a <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  801338:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80133b:	eb e9                	jmp    801326 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80133d:	8b 45 14             	mov    0x14(%ebp),%eax
  801340:	8d 50 04             	lea    0x4(%eax),%edx
  801343:	89 55 14             	mov    %edx,0x14(%ebp)
  801346:	8b 00                	mov    (%eax),%eax
  801348:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80134b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80134e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801352:	79 93                	jns    8012e7 <vprintfmt+0x39>
				width = precision, precision = -1;
  801354:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801357:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80135a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801361:	eb 84                	jmp    8012e7 <vprintfmt+0x39>
  801363:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801366:	85 c0                	test   %eax,%eax
  801368:	ba 00 00 00 00       	mov    $0x0,%edx
  80136d:	0f 49 d0             	cmovns %eax,%edx
  801370:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801376:	e9 6c ff ff ff       	jmp    8012e7 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80137b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80137e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801385:	e9 5d ff ff ff       	jmp    8012e7 <vprintfmt+0x39>
  80138a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80138d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801390:	eb bc                	jmp    80134e <vprintfmt+0xa0>
			lflag++;
  801392:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801398:	e9 4a ff ff ff       	jmp    8012e7 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80139d:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a0:	8d 50 04             	lea    0x4(%eax),%edx
  8013a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a6:	83 ec 08             	sub    $0x8,%esp
  8013a9:	56                   	push   %esi
  8013aa:	ff 30                	pushl  (%eax)
  8013ac:	ff d3                	call   *%ebx
			break;
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	e9 96 01 00 00       	jmp    80154c <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8013b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b9:	8d 50 04             	lea    0x4(%eax),%edx
  8013bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8013bf:	8b 00                	mov    (%eax),%eax
  8013c1:	99                   	cltd   
  8013c2:	31 d0                	xor    %edx,%eax
  8013c4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013c6:	83 f8 0f             	cmp    $0xf,%eax
  8013c9:	7f 20                	jg     8013eb <vprintfmt+0x13d>
  8013cb:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  8013d2:	85 d2                	test   %edx,%edx
  8013d4:	74 15                	je     8013eb <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8013d6:	52                   	push   %edx
  8013d7:	68 bd 1e 80 00       	push   $0x801ebd
  8013dc:	56                   	push   %esi
  8013dd:	53                   	push   %ebx
  8013de:	e8 aa fe ff ff       	call   80128d <printfmt>
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	e9 61 01 00 00       	jmp    80154c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8013eb:	50                   	push   %eax
  8013ec:	68 3f 1f 80 00       	push   $0x801f3f
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	e8 95 fe ff ff       	call   80128d <printfmt>
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	e9 4c 01 00 00       	jmp    80154c <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  801400:	8b 45 14             	mov    0x14(%ebp),%eax
  801403:	8d 50 04             	lea    0x4(%eax),%edx
  801406:	89 55 14             	mov    %edx,0x14(%ebp)
  801409:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80140b:	85 c9                	test   %ecx,%ecx
  80140d:	b8 38 1f 80 00       	mov    $0x801f38,%eax
  801412:	0f 45 c1             	cmovne %ecx,%eax
  801415:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801418:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80141c:	7e 06                	jle    801424 <vprintfmt+0x176>
  80141e:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801422:	75 0d                	jne    801431 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  801424:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801427:	89 c7                	mov    %eax,%edi
  801429:	03 45 e0             	add    -0x20(%ebp),%eax
  80142c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80142f:	eb 57                	jmp    801488 <vprintfmt+0x1da>
  801431:	83 ec 08             	sub    $0x8,%esp
  801434:	ff 75 d8             	pushl  -0x28(%ebp)
  801437:	ff 75 cc             	pushl  -0x34(%ebp)
  80143a:	e8 4f 02 00 00       	call   80168e <strnlen>
  80143f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801442:	29 c2                	sub    %eax,%edx
  801444:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801447:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80144a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80144e:	89 5d 08             	mov    %ebx,0x8(%ebp)
  801451:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  801453:	85 db                	test   %ebx,%ebx
  801455:	7e 10                	jle    801467 <vprintfmt+0x1b9>
					putch(padc, putdat);
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	56                   	push   %esi
  80145b:	57                   	push   %edi
  80145c:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80145f:	83 eb 01             	sub    $0x1,%ebx
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	eb ec                	jmp    801453 <vprintfmt+0x1a5>
  801467:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80146a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80146d:	85 d2                	test   %edx,%edx
  80146f:	b8 00 00 00 00       	mov    $0x0,%eax
  801474:	0f 49 c2             	cmovns %edx,%eax
  801477:	29 c2                	sub    %eax,%edx
  801479:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80147c:	eb a6                	jmp    801424 <vprintfmt+0x176>
					putch(ch, putdat);
  80147e:	83 ec 08             	sub    $0x8,%esp
  801481:	56                   	push   %esi
  801482:	52                   	push   %edx
  801483:	ff d3                	call   *%ebx
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80148b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80148d:	83 c7 01             	add    $0x1,%edi
  801490:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801494:	0f be d0             	movsbl %al,%edx
  801497:	85 d2                	test   %edx,%edx
  801499:	74 42                	je     8014dd <vprintfmt+0x22f>
  80149b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80149f:	78 06                	js     8014a7 <vprintfmt+0x1f9>
  8014a1:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014a5:	78 1e                	js     8014c5 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8014a7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014ab:	74 d1                	je     80147e <vprintfmt+0x1d0>
  8014ad:	0f be c0             	movsbl %al,%eax
  8014b0:	83 e8 20             	sub    $0x20,%eax
  8014b3:	83 f8 5e             	cmp    $0x5e,%eax
  8014b6:	76 c6                	jbe    80147e <vprintfmt+0x1d0>
					putch('?', putdat);
  8014b8:	83 ec 08             	sub    $0x8,%esp
  8014bb:	56                   	push   %esi
  8014bc:	6a 3f                	push   $0x3f
  8014be:	ff d3                	call   *%ebx
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	eb c3                	jmp    801488 <vprintfmt+0x1da>
  8014c5:	89 cf                	mov    %ecx,%edi
  8014c7:	eb 0e                	jmp    8014d7 <vprintfmt+0x229>
				putch(' ', putdat);
  8014c9:	83 ec 08             	sub    $0x8,%esp
  8014cc:	56                   	push   %esi
  8014cd:	6a 20                	push   $0x20
  8014cf:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8014d1:	83 ef 01             	sub    $0x1,%edi
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	85 ff                	test   %edi,%edi
  8014d9:	7f ee                	jg     8014c9 <vprintfmt+0x21b>
  8014db:	eb 6f                	jmp    80154c <vprintfmt+0x29e>
  8014dd:	89 cf                	mov    %ecx,%edi
  8014df:	eb f6                	jmp    8014d7 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8014e1:	89 ca                	mov    %ecx,%edx
  8014e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8014e6:	e8 55 fd ff ff       	call   801240 <getint>
  8014eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8014f1:	85 d2                	test   %edx,%edx
  8014f3:	78 0b                	js     801500 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8014f5:	89 d1                	mov    %edx,%ecx
  8014f7:	89 c2                	mov    %eax,%edx
			base = 10;
  8014f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014fe:	eb 32                	jmp    801532 <vprintfmt+0x284>
				putch('-', putdat);
  801500:	83 ec 08             	sub    $0x8,%esp
  801503:	56                   	push   %esi
  801504:	6a 2d                	push   $0x2d
  801506:	ff d3                	call   *%ebx
				num = -(long long) num;
  801508:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80150b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80150e:	f7 da                	neg    %edx
  801510:	83 d1 00             	adc    $0x0,%ecx
  801513:	f7 d9                	neg    %ecx
  801515:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801518:	b8 0a 00 00 00       	mov    $0xa,%eax
  80151d:	eb 13                	jmp    801532 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80151f:	89 ca                	mov    %ecx,%edx
  801521:	8d 45 14             	lea    0x14(%ebp),%eax
  801524:	e8 e3 fc ff ff       	call   80120c <getuint>
  801529:	89 d1                	mov    %edx,%ecx
  80152b:	89 c2                	mov    %eax,%edx
			base = 10;
  80152d:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  801532:	83 ec 0c             	sub    $0xc,%esp
  801535:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801539:	57                   	push   %edi
  80153a:	ff 75 e0             	pushl  -0x20(%ebp)
  80153d:	50                   	push   %eax
  80153e:	51                   	push   %ecx
  80153f:	52                   	push   %edx
  801540:	89 f2                	mov    %esi,%edx
  801542:	89 d8                	mov    %ebx,%eax
  801544:	e8 1a fc ff ff       	call   801163 <printnum>
			break;
  801549:	83 c4 20             	add    $0x20,%esp
{
  80154c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80154f:	83 c7 01             	add    $0x1,%edi
  801552:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801556:	83 f8 25             	cmp    $0x25,%eax
  801559:	0f 84 6a fd ff ff    	je     8012c9 <vprintfmt+0x1b>
			if (ch == '\0')
  80155f:	85 c0                	test   %eax,%eax
  801561:	0f 84 93 00 00 00    	je     8015fa <vprintfmt+0x34c>
			putch(ch, putdat);
  801567:	83 ec 08             	sub    $0x8,%esp
  80156a:	56                   	push   %esi
  80156b:	50                   	push   %eax
  80156c:	ff d3                	call   *%ebx
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	eb dc                	jmp    80154f <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  801573:	89 ca                	mov    %ecx,%edx
  801575:	8d 45 14             	lea    0x14(%ebp),%eax
  801578:	e8 8f fc ff ff       	call   80120c <getuint>
  80157d:	89 d1                	mov    %edx,%ecx
  80157f:	89 c2                	mov    %eax,%edx
			base = 8;
  801581:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801586:	eb aa                	jmp    801532 <vprintfmt+0x284>
			putch('0', putdat);
  801588:	83 ec 08             	sub    $0x8,%esp
  80158b:	56                   	push   %esi
  80158c:	6a 30                	push   $0x30
  80158e:	ff d3                	call   *%ebx
			putch('x', putdat);
  801590:	83 c4 08             	add    $0x8,%esp
  801593:	56                   	push   %esi
  801594:	6a 78                	push   $0x78
  801596:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  801598:	8b 45 14             	mov    0x14(%ebp),%eax
  80159b:	8d 50 04             	lea    0x4(%eax),%edx
  80159e:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8015a1:	8b 10                	mov    (%eax),%edx
  8015a3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015a8:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8015ab:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015b0:	eb 80                	jmp    801532 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8015b2:	89 ca                	mov    %ecx,%edx
  8015b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b7:	e8 50 fc ff ff       	call   80120c <getuint>
  8015bc:	89 d1                	mov    %edx,%ecx
  8015be:	89 c2                	mov    %eax,%edx
			base = 16;
  8015c0:	b8 10 00 00 00       	mov    $0x10,%eax
  8015c5:	e9 68 ff ff ff       	jmp    801532 <vprintfmt+0x284>
			putch(ch, putdat);
  8015ca:	83 ec 08             	sub    $0x8,%esp
  8015cd:	56                   	push   %esi
  8015ce:	6a 25                	push   $0x25
  8015d0:	ff d3                	call   *%ebx
			break;
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	e9 72 ff ff ff       	jmp    80154c <vprintfmt+0x29e>
			putch('%', putdat);
  8015da:	83 ec 08             	sub    $0x8,%esp
  8015dd:	56                   	push   %esi
  8015de:	6a 25                	push   $0x25
  8015e0:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	89 f8                	mov    %edi,%eax
  8015e7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015eb:	74 05                	je     8015f2 <vprintfmt+0x344>
  8015ed:	83 e8 01             	sub    $0x1,%eax
  8015f0:	eb f5                	jmp    8015e7 <vprintfmt+0x339>
  8015f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015f5:	e9 52 ff ff ff       	jmp    80154c <vprintfmt+0x29e>
}
  8015fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015fd:	5b                   	pop    %ebx
  8015fe:	5e                   	pop    %esi
  8015ff:	5f                   	pop    %edi
  801600:	5d                   	pop    %ebp
  801601:	c3                   	ret    

00801602 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801602:	f3 0f 1e fb          	endbr32 
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	83 ec 18             	sub    $0x18,%esp
  80160c:	8b 45 08             	mov    0x8(%ebp),%eax
  80160f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801612:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801615:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801619:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80161c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801623:	85 c0                	test   %eax,%eax
  801625:	74 26                	je     80164d <vsnprintf+0x4b>
  801627:	85 d2                	test   %edx,%edx
  801629:	7e 22                	jle    80164d <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80162b:	ff 75 14             	pushl  0x14(%ebp)
  80162e:	ff 75 10             	pushl  0x10(%ebp)
  801631:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801634:	50                   	push   %eax
  801635:	68 6c 12 80 00       	push   $0x80126c
  80163a:	e8 6f fc ff ff       	call   8012ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80163f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801642:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801645:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801648:	83 c4 10             	add    $0x10,%esp
}
  80164b:	c9                   	leave  
  80164c:	c3                   	ret    
		return -E_INVAL;
  80164d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801652:	eb f7                	jmp    80164b <vsnprintf+0x49>

00801654 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801654:	f3 0f 1e fb          	endbr32 
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80165e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801661:	50                   	push   %eax
  801662:	ff 75 10             	pushl  0x10(%ebp)
  801665:	ff 75 0c             	pushl  0xc(%ebp)
  801668:	ff 75 08             	pushl  0x8(%ebp)
  80166b:	e8 92 ff ff ff       	call   801602 <vsnprintf>
	va_end(ap);

	return rc;
}
  801670:	c9                   	leave  
  801671:	c3                   	ret    

00801672 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801672:	f3 0f 1e fb          	endbr32 
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80167c:	b8 00 00 00 00       	mov    $0x0,%eax
  801681:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801685:	74 05                	je     80168c <strlen+0x1a>
		n++;
  801687:	83 c0 01             	add    $0x1,%eax
  80168a:	eb f5                	jmp    801681 <strlen+0xf>
	return n;
}
  80168c:	5d                   	pop    %ebp
  80168d:	c3                   	ret    

0080168e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80168e:	f3 0f 1e fb          	endbr32 
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801698:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80169b:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a0:	39 d0                	cmp    %edx,%eax
  8016a2:	74 0d                	je     8016b1 <strnlen+0x23>
  8016a4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016a8:	74 05                	je     8016af <strnlen+0x21>
		n++;
  8016aa:	83 c0 01             	add    $0x1,%eax
  8016ad:	eb f1                	jmp    8016a0 <strnlen+0x12>
  8016af:	89 c2                	mov    %eax,%edx
	return n;
}
  8016b1:	89 d0                	mov    %edx,%eax
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016b5:	f3 0f 1e fb          	endbr32 
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	53                   	push   %ebx
  8016bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016cc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016cf:	83 c0 01             	add    $0x1,%eax
  8016d2:	84 d2                	test   %dl,%dl
  8016d4:	75 f2                	jne    8016c8 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8016d6:	89 c8                	mov    %ecx,%eax
  8016d8:	5b                   	pop    %ebx
  8016d9:	5d                   	pop    %ebp
  8016da:	c3                   	ret    

008016db <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016db:	f3 0f 1e fb          	endbr32 
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	53                   	push   %ebx
  8016e3:	83 ec 10             	sub    $0x10,%esp
  8016e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016e9:	53                   	push   %ebx
  8016ea:	e8 83 ff ff ff       	call   801672 <strlen>
  8016ef:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016f2:	ff 75 0c             	pushl  0xc(%ebp)
  8016f5:	01 d8                	add    %ebx,%eax
  8016f7:	50                   	push   %eax
  8016f8:	e8 b8 ff ff ff       	call   8016b5 <strcpy>
	return dst;
}
  8016fd:	89 d8                	mov    %ebx,%eax
  8016ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801702:	c9                   	leave  
  801703:	c3                   	ret    

00801704 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801704:	f3 0f 1e fb          	endbr32 
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	56                   	push   %esi
  80170c:	53                   	push   %ebx
  80170d:	8b 75 08             	mov    0x8(%ebp),%esi
  801710:	8b 55 0c             	mov    0xc(%ebp),%edx
  801713:	89 f3                	mov    %esi,%ebx
  801715:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801718:	89 f0                	mov    %esi,%eax
  80171a:	39 d8                	cmp    %ebx,%eax
  80171c:	74 11                	je     80172f <strncpy+0x2b>
		*dst++ = *src;
  80171e:	83 c0 01             	add    $0x1,%eax
  801721:	0f b6 0a             	movzbl (%edx),%ecx
  801724:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801727:	80 f9 01             	cmp    $0x1,%cl
  80172a:	83 da ff             	sbb    $0xffffffff,%edx
  80172d:	eb eb                	jmp    80171a <strncpy+0x16>
	}
	return ret;
}
  80172f:	89 f0                	mov    %esi,%eax
  801731:	5b                   	pop    %ebx
  801732:	5e                   	pop    %esi
  801733:	5d                   	pop    %ebp
  801734:	c3                   	ret    

00801735 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801735:	f3 0f 1e fb          	endbr32 
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	56                   	push   %esi
  80173d:	53                   	push   %ebx
  80173e:	8b 75 08             	mov    0x8(%ebp),%esi
  801741:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801744:	8b 55 10             	mov    0x10(%ebp),%edx
  801747:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801749:	85 d2                	test   %edx,%edx
  80174b:	74 21                	je     80176e <strlcpy+0x39>
  80174d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801751:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801753:	39 c2                	cmp    %eax,%edx
  801755:	74 14                	je     80176b <strlcpy+0x36>
  801757:	0f b6 19             	movzbl (%ecx),%ebx
  80175a:	84 db                	test   %bl,%bl
  80175c:	74 0b                	je     801769 <strlcpy+0x34>
			*dst++ = *src++;
  80175e:	83 c1 01             	add    $0x1,%ecx
  801761:	83 c2 01             	add    $0x1,%edx
  801764:	88 5a ff             	mov    %bl,-0x1(%edx)
  801767:	eb ea                	jmp    801753 <strlcpy+0x1e>
  801769:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80176b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80176e:	29 f0                	sub    %esi,%eax
}
  801770:	5b                   	pop    %ebx
  801771:	5e                   	pop    %esi
  801772:	5d                   	pop    %ebp
  801773:	c3                   	ret    

00801774 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801774:	f3 0f 1e fb          	endbr32 
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80177e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801781:	0f b6 01             	movzbl (%ecx),%eax
  801784:	84 c0                	test   %al,%al
  801786:	74 0c                	je     801794 <strcmp+0x20>
  801788:	3a 02                	cmp    (%edx),%al
  80178a:	75 08                	jne    801794 <strcmp+0x20>
		p++, q++;
  80178c:	83 c1 01             	add    $0x1,%ecx
  80178f:	83 c2 01             	add    $0x1,%edx
  801792:	eb ed                	jmp    801781 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801794:	0f b6 c0             	movzbl %al,%eax
  801797:	0f b6 12             	movzbl (%edx),%edx
  80179a:	29 d0                	sub    %edx,%eax
}
  80179c:	5d                   	pop    %ebp
  80179d:	c3                   	ret    

0080179e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80179e:	f3 0f 1e fb          	endbr32 
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	53                   	push   %ebx
  8017a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ac:	89 c3                	mov    %eax,%ebx
  8017ae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017b1:	eb 06                	jmp    8017b9 <strncmp+0x1b>
		n--, p++, q++;
  8017b3:	83 c0 01             	add    $0x1,%eax
  8017b6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017b9:	39 d8                	cmp    %ebx,%eax
  8017bb:	74 16                	je     8017d3 <strncmp+0x35>
  8017bd:	0f b6 08             	movzbl (%eax),%ecx
  8017c0:	84 c9                	test   %cl,%cl
  8017c2:	74 04                	je     8017c8 <strncmp+0x2a>
  8017c4:	3a 0a                	cmp    (%edx),%cl
  8017c6:	74 eb                	je     8017b3 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c8:	0f b6 00             	movzbl (%eax),%eax
  8017cb:	0f b6 12             	movzbl (%edx),%edx
  8017ce:	29 d0                	sub    %edx,%eax
}
  8017d0:	5b                   	pop    %ebx
  8017d1:	5d                   	pop    %ebp
  8017d2:	c3                   	ret    
		return 0;
  8017d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d8:	eb f6                	jmp    8017d0 <strncmp+0x32>

008017da <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017da:	f3 0f 1e fb          	endbr32 
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e8:	0f b6 10             	movzbl (%eax),%edx
  8017eb:	84 d2                	test   %dl,%dl
  8017ed:	74 09                	je     8017f8 <strchr+0x1e>
		if (*s == c)
  8017ef:	38 ca                	cmp    %cl,%dl
  8017f1:	74 0a                	je     8017fd <strchr+0x23>
	for (; *s; s++)
  8017f3:	83 c0 01             	add    $0x1,%eax
  8017f6:	eb f0                	jmp    8017e8 <strchr+0xe>
			return (char *) s;
	return 0;
  8017f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017ff:	f3 0f 1e fb          	endbr32 
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	8b 45 08             	mov    0x8(%ebp),%eax
  801809:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80180d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801810:	38 ca                	cmp    %cl,%dl
  801812:	74 09                	je     80181d <strfind+0x1e>
  801814:	84 d2                	test   %dl,%dl
  801816:	74 05                	je     80181d <strfind+0x1e>
	for (; *s; s++)
  801818:	83 c0 01             	add    $0x1,%eax
  80181b:	eb f0                	jmp    80180d <strfind+0xe>
			break;
	return (char *) s;
}
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    

0080181f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80181f:	f3 0f 1e fb          	endbr32 
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	57                   	push   %edi
  801827:	56                   	push   %esi
  801828:	53                   	push   %ebx
  801829:	8b 55 08             	mov    0x8(%ebp),%edx
  80182c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80182f:	85 c9                	test   %ecx,%ecx
  801831:	74 33                	je     801866 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801833:	89 d0                	mov    %edx,%eax
  801835:	09 c8                	or     %ecx,%eax
  801837:	a8 03                	test   $0x3,%al
  801839:	75 23                	jne    80185e <memset+0x3f>
		c &= 0xFF;
  80183b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80183f:	89 d8                	mov    %ebx,%eax
  801841:	c1 e0 08             	shl    $0x8,%eax
  801844:	89 df                	mov    %ebx,%edi
  801846:	c1 e7 18             	shl    $0x18,%edi
  801849:	89 de                	mov    %ebx,%esi
  80184b:	c1 e6 10             	shl    $0x10,%esi
  80184e:	09 f7                	or     %esi,%edi
  801850:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  801852:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801855:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  801857:	89 d7                	mov    %edx,%edi
  801859:	fc                   	cld    
  80185a:	f3 ab                	rep stos %eax,%es:(%edi)
  80185c:	eb 08                	jmp    801866 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80185e:	89 d7                	mov    %edx,%edi
  801860:	8b 45 0c             	mov    0xc(%ebp),%eax
  801863:	fc                   	cld    
  801864:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  801866:	89 d0                	mov    %edx,%eax
  801868:	5b                   	pop    %ebx
  801869:	5e                   	pop    %esi
  80186a:	5f                   	pop    %edi
  80186b:	5d                   	pop    %ebp
  80186c:	c3                   	ret    

0080186d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80186d:	f3 0f 1e fb          	endbr32 
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	57                   	push   %edi
  801875:	56                   	push   %esi
  801876:	8b 45 08             	mov    0x8(%ebp),%eax
  801879:	8b 75 0c             	mov    0xc(%ebp),%esi
  80187c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80187f:	39 c6                	cmp    %eax,%esi
  801881:	73 32                	jae    8018b5 <memmove+0x48>
  801883:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801886:	39 c2                	cmp    %eax,%edx
  801888:	76 2b                	jbe    8018b5 <memmove+0x48>
		s += n;
		d += n;
  80188a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80188d:	89 fe                	mov    %edi,%esi
  80188f:	09 ce                	or     %ecx,%esi
  801891:	09 d6                	or     %edx,%esi
  801893:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801899:	75 0e                	jne    8018a9 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80189b:	83 ef 04             	sub    $0x4,%edi
  80189e:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018a1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018a4:	fd                   	std    
  8018a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a7:	eb 09                	jmp    8018b2 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018a9:	83 ef 01             	sub    $0x1,%edi
  8018ac:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018af:	fd                   	std    
  8018b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b2:	fc                   	cld    
  8018b3:	eb 1a                	jmp    8018cf <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b5:	89 c2                	mov    %eax,%edx
  8018b7:	09 ca                	or     %ecx,%edx
  8018b9:	09 f2                	or     %esi,%edx
  8018bb:	f6 c2 03             	test   $0x3,%dl
  8018be:	75 0a                	jne    8018ca <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018c0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018c3:	89 c7                	mov    %eax,%edi
  8018c5:	fc                   	cld    
  8018c6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c8:	eb 05                	jmp    8018cf <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8018ca:	89 c7                	mov    %eax,%edi
  8018cc:	fc                   	cld    
  8018cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018cf:	5e                   	pop    %esi
  8018d0:	5f                   	pop    %edi
  8018d1:	5d                   	pop    %ebp
  8018d2:	c3                   	ret    

008018d3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d3:	f3 0f 1e fb          	endbr32 
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018dd:	ff 75 10             	pushl  0x10(%ebp)
  8018e0:	ff 75 0c             	pushl  0xc(%ebp)
  8018e3:	ff 75 08             	pushl  0x8(%ebp)
  8018e6:	e8 82 ff ff ff       	call   80186d <memmove>
}
  8018eb:	c9                   	leave  
  8018ec:	c3                   	ret    

008018ed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ed:	f3 0f 1e fb          	endbr32 
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	56                   	push   %esi
  8018f5:	53                   	push   %ebx
  8018f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018fc:	89 c6                	mov    %eax,%esi
  8018fe:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801901:	39 f0                	cmp    %esi,%eax
  801903:	74 1c                	je     801921 <memcmp+0x34>
		if (*s1 != *s2)
  801905:	0f b6 08             	movzbl (%eax),%ecx
  801908:	0f b6 1a             	movzbl (%edx),%ebx
  80190b:	38 d9                	cmp    %bl,%cl
  80190d:	75 08                	jne    801917 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80190f:	83 c0 01             	add    $0x1,%eax
  801912:	83 c2 01             	add    $0x1,%edx
  801915:	eb ea                	jmp    801901 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801917:	0f b6 c1             	movzbl %cl,%eax
  80191a:	0f b6 db             	movzbl %bl,%ebx
  80191d:	29 d8                	sub    %ebx,%eax
  80191f:	eb 05                	jmp    801926 <memcmp+0x39>
	}

	return 0;
  801921:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801926:	5b                   	pop    %ebx
  801927:	5e                   	pop    %esi
  801928:	5d                   	pop    %ebp
  801929:	c3                   	ret    

0080192a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80192a:	f3 0f 1e fb          	endbr32 
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	8b 45 08             	mov    0x8(%ebp),%eax
  801934:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801937:	89 c2                	mov    %eax,%edx
  801939:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80193c:	39 d0                	cmp    %edx,%eax
  80193e:	73 09                	jae    801949 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801940:	38 08                	cmp    %cl,(%eax)
  801942:	74 05                	je     801949 <memfind+0x1f>
	for (; s < ends; s++)
  801944:	83 c0 01             	add    $0x1,%eax
  801947:	eb f3                	jmp    80193c <memfind+0x12>
			break;
	return (void *) s;
}
  801949:	5d                   	pop    %ebp
  80194a:	c3                   	ret    

0080194b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80194b:	f3 0f 1e fb          	endbr32 
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	57                   	push   %edi
  801953:	56                   	push   %esi
  801954:	53                   	push   %ebx
  801955:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801958:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80195b:	eb 03                	jmp    801960 <strtol+0x15>
		s++;
  80195d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801960:	0f b6 01             	movzbl (%ecx),%eax
  801963:	3c 20                	cmp    $0x20,%al
  801965:	74 f6                	je     80195d <strtol+0x12>
  801967:	3c 09                	cmp    $0x9,%al
  801969:	74 f2                	je     80195d <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  80196b:	3c 2b                	cmp    $0x2b,%al
  80196d:	74 2a                	je     801999 <strtol+0x4e>
	int neg = 0;
  80196f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801974:	3c 2d                	cmp    $0x2d,%al
  801976:	74 2b                	je     8019a3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801978:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80197e:	75 0f                	jne    80198f <strtol+0x44>
  801980:	80 39 30             	cmpb   $0x30,(%ecx)
  801983:	74 28                	je     8019ad <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801985:	85 db                	test   %ebx,%ebx
  801987:	b8 0a 00 00 00       	mov    $0xa,%eax
  80198c:	0f 44 d8             	cmove  %eax,%ebx
  80198f:	b8 00 00 00 00       	mov    $0x0,%eax
  801994:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801997:	eb 46                	jmp    8019df <strtol+0x94>
		s++;
  801999:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80199c:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a1:	eb d5                	jmp    801978 <strtol+0x2d>
		s++, neg = 1;
  8019a3:	83 c1 01             	add    $0x1,%ecx
  8019a6:	bf 01 00 00 00       	mov    $0x1,%edi
  8019ab:	eb cb                	jmp    801978 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019ad:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019b1:	74 0e                	je     8019c1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019b3:	85 db                	test   %ebx,%ebx
  8019b5:	75 d8                	jne    80198f <strtol+0x44>
		s++, base = 8;
  8019b7:	83 c1 01             	add    $0x1,%ecx
  8019ba:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019bf:	eb ce                	jmp    80198f <strtol+0x44>
		s += 2, base = 16;
  8019c1:	83 c1 02             	add    $0x2,%ecx
  8019c4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019c9:	eb c4                	jmp    80198f <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019cb:	0f be d2             	movsbl %dl,%edx
  8019ce:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019d1:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019d4:	7d 3a                	jge    801a10 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019d6:	83 c1 01             	add    $0x1,%ecx
  8019d9:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019dd:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019df:	0f b6 11             	movzbl (%ecx),%edx
  8019e2:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019e5:	89 f3                	mov    %esi,%ebx
  8019e7:	80 fb 09             	cmp    $0x9,%bl
  8019ea:	76 df                	jbe    8019cb <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8019ec:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019ef:	89 f3                	mov    %esi,%ebx
  8019f1:	80 fb 19             	cmp    $0x19,%bl
  8019f4:	77 08                	ja     8019fe <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019f6:	0f be d2             	movsbl %dl,%edx
  8019f9:	83 ea 57             	sub    $0x57,%edx
  8019fc:	eb d3                	jmp    8019d1 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  8019fe:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a01:	89 f3                	mov    %esi,%ebx
  801a03:	80 fb 19             	cmp    $0x19,%bl
  801a06:	77 08                	ja     801a10 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a08:	0f be d2             	movsbl %dl,%edx
  801a0b:	83 ea 37             	sub    $0x37,%edx
  801a0e:	eb c1                	jmp    8019d1 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a14:	74 05                	je     801a1b <strtol+0xd0>
		*endptr = (char *) s;
  801a16:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a19:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a1b:	89 c2                	mov    %eax,%edx
  801a1d:	f7 da                	neg    %edx
  801a1f:	85 ff                	test   %edi,%edi
  801a21:	0f 45 c2             	cmovne %edx,%eax
}
  801a24:	5b                   	pop    %ebx
  801a25:	5e                   	pop    %esi
  801a26:	5f                   	pop    %edi
  801a27:	5d                   	pop    %ebp
  801a28:	c3                   	ret    

00801a29 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a29:	f3 0f 1e fb          	endbr32 
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	56                   	push   %esi
  801a31:	53                   	push   %ebx
  801a32:	8b 75 08             	mov    0x8(%ebp),%esi
  801a35:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a38:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a42:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801a45:	83 ec 0c             	sub    $0xc,%esp
  801a48:	50                   	push   %eax
  801a49:	e8 82 e8 ff ff       	call   8002d0 <sys_ipc_recv>
	if (f < 0) {
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	85 c0                	test   %eax,%eax
  801a53:	78 2b                	js     801a80 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801a55:	85 f6                	test   %esi,%esi
  801a57:	74 0a                	je     801a63 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801a59:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5e:	8b 40 74             	mov    0x74(%eax),%eax
  801a61:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801a63:	85 db                	test   %ebx,%ebx
  801a65:	74 0a                	je     801a71 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801a67:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6c:	8b 40 78             	mov    0x78(%eax),%eax
  801a6f:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  801a71:	a1 04 40 80 00       	mov    0x804004,%eax
  801a76:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7c:	5b                   	pop    %ebx
  801a7d:	5e                   	pop    %esi
  801a7e:	5d                   	pop    %ebp
  801a7f:	c3                   	ret    
		if (from_env_store != NULL) {
  801a80:	85 f6                	test   %esi,%esi
  801a82:	74 06                	je     801a8a <ipc_recv+0x61>
			*from_env_store = 0;
  801a84:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801a8a:	85 db                	test   %ebx,%ebx
  801a8c:	74 eb                	je     801a79 <ipc_recv+0x50>
			*perm_store = 0;
  801a8e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a94:	eb e3                	jmp    801a79 <ipc_recv+0x50>

00801a96 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a96:	f3 0f 1e fb          	endbr32 
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	57                   	push   %edi
  801a9e:	56                   	push   %esi
  801a9f:	53                   	push   %ebx
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aa6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aa9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  801aac:	85 db                	test   %ebx,%ebx
  801aae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ab3:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801ab6:	ff 75 14             	pushl  0x14(%ebp)
  801ab9:	53                   	push   %ebx
  801aba:	56                   	push   %esi
  801abb:	57                   	push   %edi
  801abc:	e8 e6 e7 ff ff       	call   8002a7 <sys_ipc_try_send>
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	79 19                	jns    801ae1 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  801ac8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801acb:	74 e9                	je     801ab6 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  801acd:	83 ec 04             	sub    $0x4,%esp
  801ad0:	68 20 22 80 00       	push   $0x802220
  801ad5:	6a 48                	push   $0x48
  801ad7:	68 42 22 80 00       	push   $0x802242
  801adc:	e8 83 f5 ff ff       	call   801064 <_panic>
		}
	}
}
  801ae1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae4:	5b                   	pop    %ebx
  801ae5:	5e                   	pop    %esi
  801ae6:	5f                   	pop    %edi
  801ae7:	5d                   	pop    %ebp
  801ae8:	c3                   	ret    

00801ae9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ae9:	f3 0f 1e fb          	endbr32 
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801af3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801af8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801afb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b01:	8b 52 50             	mov    0x50(%edx),%edx
  801b04:	39 ca                	cmp    %ecx,%edx
  801b06:	74 11                	je     801b19 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801b08:	83 c0 01             	add    $0x1,%eax
  801b0b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b10:	75 e6                	jne    801af8 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b12:	b8 00 00 00 00       	mov    $0x0,%eax
  801b17:	eb 0b                	jmp    801b24 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b19:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b1c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b21:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b24:	5d                   	pop    %ebp
  801b25:	c3                   	ret    

00801b26 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b26:	f3 0f 1e fb          	endbr32 
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b30:	89 c2                	mov    %eax,%edx
  801b32:	c1 ea 16             	shr    $0x16,%edx
  801b35:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b3c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b41:	f6 c1 01             	test   $0x1,%cl
  801b44:	74 1c                	je     801b62 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b46:	c1 e8 0c             	shr    $0xc,%eax
  801b49:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b50:	a8 01                	test   $0x1,%al
  801b52:	74 0e                	je     801b62 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b54:	c1 e8 0c             	shr    $0xc,%eax
  801b57:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b5e:	ef 
  801b5f:	0f b7 d2             	movzwl %dx,%edx
}
  801b62:	89 d0                	mov    %edx,%eax
  801b64:	5d                   	pop    %ebp
  801b65:	c3                   	ret    
  801b66:	66 90                	xchg   %ax,%ax
  801b68:	66 90                	xchg   %ax,%ax
  801b6a:	66 90                	xchg   %ax,%ax
  801b6c:	66 90                	xchg   %ax,%ax
  801b6e:	66 90                	xchg   %ax,%ax

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
