
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	f3 0f 1e fb          	endbr32 
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  80004d:	e8 19 01 00 00       	call   80016b <sys_getenvid>
	if (id >= 0)
  800052:	85 c0                	test   %eax,%eax
  800054:	78 12                	js     800068 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800056:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800063:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800068:	85 db                	test   %ebx,%ebx
  80006a:	7e 07                	jle    800073 <libmain+0x35>
		binaryname = argv[0];
  80006c:	8b 06                	mov    (%esi),%eax
  80006e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800073:	83 ec 08             	sub    $0x8,%esp
  800076:	56                   	push   %esi
  800077:	53                   	push   %ebx
  800078:	e8 b6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007d:	e8 0a 00 00 00       	call   80008c <exit>
}
  800082:	83 c4 10             	add    $0x10,%esp
  800085:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800088:	5b                   	pop    %ebx
  800089:	5e                   	pop    %esi
  80008a:	5d                   	pop    %ebp
  80008b:	c3                   	ret    

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	f3 0f 1e fb          	endbr32 
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 53 04 00 00       	call   8004ee <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 a0 00 00 00       	call   800145 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
  8000b0:	83 ec 1c             	sub    $0x1c,%esp
  8000b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000b9:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000c1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c4:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000c9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000cd:	74 04                	je     8000d3 <syscall+0x29>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7f 08                	jg     8000db <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000db:	83 ec 0c             	sub    $0xc,%esp
  8000de:	50                   	push   %eax
  8000df:	ff 75 e0             	pushl  -0x20(%ebp)
  8000e2:	68 ea 1d 80 00       	push   $0x801dea
  8000e7:	6a 23                	push   $0x23
  8000e9:	68 07 1e 80 00       	push   $0x801e07
  8000ee:	e8 76 0f 00 00       	call   801069 <_panic>

008000f3 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000f3:	f3 0f 1e fb          	endbr32 
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000fd:	6a 00                	push   $0x0
  8000ff:	6a 00                	push   $0x0
  800101:	6a 00                	push   $0x0
  800103:	ff 75 0c             	pushl  0xc(%ebp)
  800106:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800109:	ba 00 00 00 00       	mov    $0x0,%edx
  80010e:	b8 00 00 00 00       	mov    $0x0,%eax
  800113:	e8 92 ff ff ff       	call   8000aa <syscall>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	c9                   	leave  
  80011c:	c3                   	ret    

0080011d <sys_cgetc>:

int
sys_cgetc(void)
{
  80011d:	f3 0f 1e fb          	endbr32 
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800127:	6a 00                	push   $0x0
  800129:	6a 00                	push   $0x0
  80012b:	6a 00                	push   $0x0
  80012d:	6a 00                	push   $0x0
  80012f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 01 00 00 00       	mov    $0x1,%eax
  80013e:	e8 67 ff ff ff       	call   8000aa <syscall>
}
  800143:	c9                   	leave  
  800144:	c3                   	ret    

00800145 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800145:	f3 0f 1e fb          	endbr32 
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80014f:	6a 00                	push   $0x0
  800151:	6a 00                	push   $0x0
  800153:	6a 00                	push   $0x0
  800155:	6a 00                	push   $0x0
  800157:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015a:	ba 01 00 00 00       	mov    $0x1,%edx
  80015f:	b8 03 00 00 00       	mov    $0x3,%eax
  800164:	e8 41 ff ff ff       	call   8000aa <syscall>
}
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016b:	f3 0f 1e fb          	endbr32 
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800175:	6a 00                	push   $0x0
  800177:	6a 00                	push   $0x0
  800179:	6a 00                	push   $0x0
  80017b:	6a 00                	push   $0x0
  80017d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800182:	ba 00 00 00 00       	mov    $0x0,%edx
  800187:	b8 02 00 00 00       	mov    $0x2,%eax
  80018c:	e8 19 ff ff ff       	call   8000aa <syscall>
}
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <sys_yield>:

void
sys_yield(void)
{
  800193:	f3 0f 1e fb          	endbr32 
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80019d:	6a 00                	push   $0x0
  80019f:	6a 00                	push   $0x0
  8001a1:	6a 00                	push   $0x0
  8001a3:	6a 00                	push   $0x0
  8001a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8001af:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001b4:	e8 f1 fe ff ff       	call   8000aa <syscall>
}
  8001b9:	83 c4 10             	add    $0x10,%esp
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001be:	f3 0f 1e fb          	endbr32 
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001c8:	6a 00                	push   $0x0
  8001ca:	6a 00                	push   $0x0
  8001cc:	ff 75 10             	pushl  0x10(%ebp)
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d5:	ba 01 00 00 00       	mov    $0x1,%edx
  8001da:	b8 04 00 00 00       	mov    $0x4,%eax
  8001df:	e8 c6 fe ff ff       	call   8000aa <syscall>
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e6:	f3 0f 1e fb          	endbr32 
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001f0:	ff 75 18             	pushl  0x18(%ebp)
  8001f3:	ff 75 14             	pushl  0x14(%ebp)
  8001f6:	ff 75 10             	pushl  0x10(%ebp)
  8001f9:	ff 75 0c             	pushl  0xc(%ebp)
  8001fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ff:	ba 01 00 00 00       	mov    $0x1,%edx
  800204:	b8 05 00 00 00       	mov    $0x5,%eax
  800209:	e8 9c fe ff ff       	call   8000aa <syscall>
}
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800210:	f3 0f 1e fb          	endbr32 
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80021a:	6a 00                	push   $0x0
  80021c:	6a 00                	push   $0x0
  80021e:	6a 00                	push   $0x0
  800220:	ff 75 0c             	pushl  0xc(%ebp)
  800223:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800226:	ba 01 00 00 00       	mov    $0x1,%edx
  80022b:	b8 06 00 00 00       	mov    $0x6,%eax
  800230:	e8 75 fe ff ff       	call   8000aa <syscall>
}
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	f3 0f 1e fb          	endbr32 
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800241:	6a 00                	push   $0x0
  800243:	6a 00                	push   $0x0
  800245:	6a 00                	push   $0x0
  800247:	ff 75 0c             	pushl  0xc(%ebp)
  80024a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024d:	ba 01 00 00 00       	mov    $0x1,%edx
  800252:	b8 08 00 00 00       	mov    $0x8,%eax
  800257:	e8 4e fe ff ff       	call   8000aa <syscall>
}
  80025c:	c9                   	leave  
  80025d:	c3                   	ret    

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	f3 0f 1e fb          	endbr32 
  800262:	55                   	push   %ebp
  800263:	89 e5                	mov    %esp,%ebp
  800265:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800268:	6a 00                	push   $0x0
  80026a:	6a 00                	push   $0x0
  80026c:	6a 00                	push   $0x0
  80026e:	ff 75 0c             	pushl  0xc(%ebp)
  800271:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800274:	ba 01 00 00 00       	mov    $0x1,%edx
  800279:	b8 09 00 00 00       	mov    $0x9,%eax
  80027e:	e8 27 fe ff ff       	call   8000aa <syscall>
}
  800283:	c9                   	leave  
  800284:	c3                   	ret    

00800285 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800285:	f3 0f 1e fb          	endbr32 
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80028f:	6a 00                	push   $0x0
  800291:	6a 00                	push   $0x0
  800293:	6a 00                	push   $0x0
  800295:	ff 75 0c             	pushl  0xc(%ebp)
  800298:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029b:	ba 01 00 00 00       	mov    $0x1,%edx
  8002a0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002a5:	e8 00 fe ff ff       	call   8000aa <syscall>
}
  8002aa:	c9                   	leave  
  8002ab:	c3                   	ret    

008002ac <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ac:	f3 0f 1e fb          	endbr32 
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002b6:	6a 00                	push   $0x0
  8002b8:	ff 75 14             	pushl  0x14(%ebp)
  8002bb:	ff 75 10             	pushl  0x10(%ebp)
  8002be:	ff 75 0c             	pushl  0xc(%ebp)
  8002c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ce:	e8 d7 fd ff ff       	call   8000aa <syscall>
}
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d5:	f3 0f 1e fb          	endbr32 
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002df:	6a 00                	push   $0x0
  8002e1:	6a 00                	push   $0x0
  8002e3:	6a 00                	push   $0x0
  8002e5:	6a 00                	push   $0x0
  8002e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ea:	ba 01 00 00 00       	mov    $0x1,%edx
  8002ef:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002f4:	e8 b1 fd ff ff       	call   8000aa <syscall>
}
  8002f9:	c9                   	leave  
  8002fa:	c3                   	ret    

008002fb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002fb:	f3 0f 1e fb          	endbr32 
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800302:	8b 45 08             	mov    0x8(%ebp),%eax
  800305:	05 00 00 00 30       	add    $0x30000000,%eax
  80030a:	c1 e8 0c             	shr    $0xc,%eax
}
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80030f:	f3 0f 1e fb          	endbr32 
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 da ff ff ff       	call   8002fb <fd2num>
  800321:	83 c4 10             	add    $0x10,%esp
  800324:	c1 e0 0c             	shl    $0xc,%eax
  800327:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80032e:	f3 0f 1e fb          	endbr32 
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80033a:	89 c2                	mov    %eax,%edx
  80033c:	c1 ea 16             	shr    $0x16,%edx
  80033f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800346:	f6 c2 01             	test   $0x1,%dl
  800349:	74 2d                	je     800378 <fd_alloc+0x4a>
  80034b:	89 c2                	mov    %eax,%edx
  80034d:	c1 ea 0c             	shr    $0xc,%edx
  800350:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800357:	f6 c2 01             	test   $0x1,%dl
  80035a:	74 1c                	je     800378 <fd_alloc+0x4a>
  80035c:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800361:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800366:	75 d2                	jne    80033a <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800368:	8b 45 08             	mov    0x8(%ebp),%eax
  80036b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800371:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800376:	eb 0a                	jmp    800382 <fd_alloc+0x54>
			*fd_store = fd;
  800378:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80037d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800384:	f3 0f 1e fb          	endbr32 
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80038e:	83 f8 1f             	cmp    $0x1f,%eax
  800391:	77 30                	ja     8003c3 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800393:	c1 e0 0c             	shl    $0xc,%eax
  800396:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80039b:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003a1:	f6 c2 01             	test   $0x1,%dl
  8003a4:	74 24                	je     8003ca <fd_lookup+0x46>
  8003a6:	89 c2                	mov    %eax,%edx
  8003a8:	c1 ea 0c             	shr    $0xc,%edx
  8003ab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b2:	f6 c2 01             	test   $0x1,%dl
  8003b5:	74 1a                	je     8003d1 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ba:	89 02                	mov    %eax,(%edx)
	return 0;
  8003bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    
		return -E_INVAL;
  8003c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003c8:	eb f7                	jmp    8003c1 <fd_lookup+0x3d>
		return -E_INVAL;
  8003ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003cf:	eb f0                	jmp    8003c1 <fd_lookup+0x3d>
  8003d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d6:	eb e9                	jmp    8003c1 <fd_lookup+0x3d>

008003d8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003d8:	f3 0f 1e fb          	endbr32 
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	83 ec 08             	sub    $0x8,%esp
  8003e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e5:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8003ea:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003ef:	39 08                	cmp    %ecx,(%eax)
  8003f1:	74 33                	je     800426 <dev_lookup+0x4e>
  8003f3:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8003f6:	8b 02                	mov    (%edx),%eax
  8003f8:	85 c0                	test   %eax,%eax
  8003fa:	75 f3                	jne    8003ef <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8003fc:	a1 04 40 80 00       	mov    0x804004,%eax
  800401:	8b 40 48             	mov    0x48(%eax),%eax
  800404:	83 ec 04             	sub    $0x4,%esp
  800407:	51                   	push   %ecx
  800408:	50                   	push   %eax
  800409:	68 18 1e 80 00       	push   $0x801e18
  80040e:	e8 3d 0d 00 00       	call   801150 <cprintf>
	*dev = 0;
  800413:	8b 45 0c             	mov    0xc(%ebp),%eax
  800416:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800424:	c9                   	leave  
  800425:	c3                   	ret    
			*dev = devtab[i];
  800426:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800429:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042b:	b8 00 00 00 00       	mov    $0x0,%eax
  800430:	eb f2                	jmp    800424 <dev_lookup+0x4c>

00800432 <fd_close>:
{
  800432:	f3 0f 1e fb          	endbr32 
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	57                   	push   %edi
  80043a:	56                   	push   %esi
  80043b:	53                   	push   %ebx
  80043c:	83 ec 28             	sub    $0x28,%esp
  80043f:	8b 75 08             	mov    0x8(%ebp),%esi
  800442:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800445:	56                   	push   %esi
  800446:	e8 b0 fe ff ff       	call   8002fb <fd2num>
  80044b:	83 c4 08             	add    $0x8,%esp
  80044e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800451:	52                   	push   %edx
  800452:	50                   	push   %eax
  800453:	e8 2c ff ff ff       	call   800384 <fd_lookup>
  800458:	89 c3                	mov    %eax,%ebx
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	85 c0                	test   %eax,%eax
  80045f:	78 05                	js     800466 <fd_close+0x34>
	    || fd != fd2)
  800461:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800464:	74 16                	je     80047c <fd_close+0x4a>
		return (must_exist ? r : 0);
  800466:	89 f8                	mov    %edi,%eax
  800468:	84 c0                	test   %al,%al
  80046a:	b8 00 00 00 00       	mov    $0x0,%eax
  80046f:	0f 44 d8             	cmove  %eax,%ebx
}
  800472:	89 d8                	mov    %ebx,%eax
  800474:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800477:	5b                   	pop    %ebx
  800478:	5e                   	pop    %esi
  800479:	5f                   	pop    %edi
  80047a:	5d                   	pop    %ebp
  80047b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800482:	50                   	push   %eax
  800483:	ff 36                	pushl  (%esi)
  800485:	e8 4e ff ff ff       	call   8003d8 <dev_lookup>
  80048a:	89 c3                	mov    %eax,%ebx
  80048c:	83 c4 10             	add    $0x10,%esp
  80048f:	85 c0                	test   %eax,%eax
  800491:	78 1a                	js     8004ad <fd_close+0x7b>
		if (dev->dev_close)
  800493:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800496:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800499:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	74 0b                	je     8004ad <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004a2:	83 ec 0c             	sub    $0xc,%esp
  8004a5:	56                   	push   %esi
  8004a6:	ff d0                	call   *%eax
  8004a8:	89 c3                	mov    %eax,%ebx
  8004aa:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	56                   	push   %esi
  8004b1:	6a 00                	push   $0x0
  8004b3:	e8 58 fd ff ff       	call   800210 <sys_page_unmap>
	return r;
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	eb b5                	jmp    800472 <fd_close+0x40>

008004bd <close>:

int
close(int fdnum)
{
  8004bd:	f3 0f 1e fb          	endbr32 
  8004c1:	55                   	push   %ebp
  8004c2:	89 e5                	mov    %esp,%ebp
  8004c4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ca:	50                   	push   %eax
  8004cb:	ff 75 08             	pushl  0x8(%ebp)
  8004ce:	e8 b1 fe ff ff       	call   800384 <fd_lookup>
  8004d3:	83 c4 10             	add    $0x10,%esp
  8004d6:	85 c0                	test   %eax,%eax
  8004d8:	79 02                	jns    8004dc <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004da:	c9                   	leave  
  8004db:	c3                   	ret    
		return fd_close(fd, 1);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	6a 01                	push   $0x1
  8004e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8004e4:	e8 49 ff ff ff       	call   800432 <fd_close>
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	eb ec                	jmp    8004da <close+0x1d>

008004ee <close_all>:

void
close_all(void)
{
  8004ee:	f3 0f 1e fb          	endbr32 
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	53                   	push   %ebx
  8004f6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8004f9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8004fe:	83 ec 0c             	sub    $0xc,%esp
  800501:	53                   	push   %ebx
  800502:	e8 b6 ff ff ff       	call   8004bd <close>
	for (i = 0; i < MAXFD; i++)
  800507:	83 c3 01             	add    $0x1,%ebx
  80050a:	83 c4 10             	add    $0x10,%esp
  80050d:	83 fb 20             	cmp    $0x20,%ebx
  800510:	75 ec                	jne    8004fe <close_all+0x10>
}
  800512:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800515:	c9                   	leave  
  800516:	c3                   	ret    

00800517 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800517:	f3 0f 1e fb          	endbr32 
  80051b:	55                   	push   %ebp
  80051c:	89 e5                	mov    %esp,%ebp
  80051e:	57                   	push   %edi
  80051f:	56                   	push   %esi
  800520:	53                   	push   %ebx
  800521:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800524:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800527:	50                   	push   %eax
  800528:	ff 75 08             	pushl  0x8(%ebp)
  80052b:	e8 54 fe ff ff       	call   800384 <fd_lookup>
  800530:	89 c3                	mov    %eax,%ebx
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	85 c0                	test   %eax,%eax
  800537:	0f 88 81 00 00 00    	js     8005be <dup+0xa7>
		return r;
	close(newfdnum);
  80053d:	83 ec 0c             	sub    $0xc,%esp
  800540:	ff 75 0c             	pushl  0xc(%ebp)
  800543:	e8 75 ff ff ff       	call   8004bd <close>

	newfd = INDEX2FD(newfdnum);
  800548:	8b 75 0c             	mov    0xc(%ebp),%esi
  80054b:	c1 e6 0c             	shl    $0xc,%esi
  80054e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800554:	83 c4 04             	add    $0x4,%esp
  800557:	ff 75 e4             	pushl  -0x1c(%ebp)
  80055a:	e8 b0 fd ff ff       	call   80030f <fd2data>
  80055f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800561:	89 34 24             	mov    %esi,(%esp)
  800564:	e8 a6 fd ff ff       	call   80030f <fd2data>
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80056e:	89 d8                	mov    %ebx,%eax
  800570:	c1 e8 16             	shr    $0x16,%eax
  800573:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80057a:	a8 01                	test   $0x1,%al
  80057c:	74 11                	je     80058f <dup+0x78>
  80057e:	89 d8                	mov    %ebx,%eax
  800580:	c1 e8 0c             	shr    $0xc,%eax
  800583:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80058a:	f6 c2 01             	test   $0x1,%dl
  80058d:	75 39                	jne    8005c8 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80058f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800592:	89 d0                	mov    %edx,%eax
  800594:	c1 e8 0c             	shr    $0xc,%eax
  800597:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80059e:	83 ec 0c             	sub    $0xc,%esp
  8005a1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005a6:	50                   	push   %eax
  8005a7:	56                   	push   %esi
  8005a8:	6a 00                	push   $0x0
  8005aa:	52                   	push   %edx
  8005ab:	6a 00                	push   $0x0
  8005ad:	e8 34 fc ff ff       	call   8001e6 <sys_page_map>
  8005b2:	89 c3                	mov    %eax,%ebx
  8005b4:	83 c4 20             	add    $0x20,%esp
  8005b7:	85 c0                	test   %eax,%eax
  8005b9:	78 31                	js     8005ec <dup+0xd5>
		goto err;

	return newfdnum;
  8005bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005be:	89 d8                	mov    %ebx,%eax
  8005c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005c3:	5b                   	pop    %ebx
  8005c4:	5e                   	pop    %esi
  8005c5:	5f                   	pop    %edi
  8005c6:	5d                   	pop    %ebp
  8005c7:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d7:	50                   	push   %eax
  8005d8:	57                   	push   %edi
  8005d9:	6a 00                	push   $0x0
  8005db:	53                   	push   %ebx
  8005dc:	6a 00                	push   $0x0
  8005de:	e8 03 fc ff ff       	call   8001e6 <sys_page_map>
  8005e3:	89 c3                	mov    %eax,%ebx
  8005e5:	83 c4 20             	add    $0x20,%esp
  8005e8:	85 c0                	test   %eax,%eax
  8005ea:	79 a3                	jns    80058f <dup+0x78>
	sys_page_unmap(0, newfd);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	56                   	push   %esi
  8005f0:	6a 00                	push   $0x0
  8005f2:	e8 19 fc ff ff       	call   800210 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005f7:	83 c4 08             	add    $0x8,%esp
  8005fa:	57                   	push   %edi
  8005fb:	6a 00                	push   $0x0
  8005fd:	e8 0e fc ff ff       	call   800210 <sys_page_unmap>
	return r;
  800602:	83 c4 10             	add    $0x10,%esp
  800605:	eb b7                	jmp    8005be <dup+0xa7>

00800607 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800607:	f3 0f 1e fb          	endbr32 
  80060b:	55                   	push   %ebp
  80060c:	89 e5                	mov    %esp,%ebp
  80060e:	53                   	push   %ebx
  80060f:	83 ec 1c             	sub    $0x1c,%esp
  800612:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800615:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800618:	50                   	push   %eax
  800619:	53                   	push   %ebx
  80061a:	e8 65 fd ff ff       	call   800384 <fd_lookup>
  80061f:	83 c4 10             	add    $0x10,%esp
  800622:	85 c0                	test   %eax,%eax
  800624:	78 3f                	js     800665 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80062c:	50                   	push   %eax
  80062d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800630:	ff 30                	pushl  (%eax)
  800632:	e8 a1 fd ff ff       	call   8003d8 <dev_lookup>
  800637:	83 c4 10             	add    $0x10,%esp
  80063a:	85 c0                	test   %eax,%eax
  80063c:	78 27                	js     800665 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80063e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800641:	8b 42 08             	mov    0x8(%edx),%eax
  800644:	83 e0 03             	and    $0x3,%eax
  800647:	83 f8 01             	cmp    $0x1,%eax
  80064a:	74 1e                	je     80066a <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80064c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80064f:	8b 40 08             	mov    0x8(%eax),%eax
  800652:	85 c0                	test   %eax,%eax
  800654:	74 35                	je     80068b <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800656:	83 ec 04             	sub    $0x4,%esp
  800659:	ff 75 10             	pushl  0x10(%ebp)
  80065c:	ff 75 0c             	pushl  0xc(%ebp)
  80065f:	52                   	push   %edx
  800660:	ff d0                	call   *%eax
  800662:	83 c4 10             	add    $0x10,%esp
}
  800665:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800668:	c9                   	leave  
  800669:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066a:	a1 04 40 80 00       	mov    0x804004,%eax
  80066f:	8b 40 48             	mov    0x48(%eax),%eax
  800672:	83 ec 04             	sub    $0x4,%esp
  800675:	53                   	push   %ebx
  800676:	50                   	push   %eax
  800677:	68 59 1e 80 00       	push   $0x801e59
  80067c:	e8 cf 0a 00 00       	call   801150 <cprintf>
		return -E_INVAL;
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800689:	eb da                	jmp    800665 <read+0x5e>
		return -E_NOT_SUPP;
  80068b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800690:	eb d3                	jmp    800665 <read+0x5e>

00800692 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800692:	f3 0f 1e fb          	endbr32 
  800696:	55                   	push   %ebp
  800697:	89 e5                	mov    %esp,%ebp
  800699:	57                   	push   %edi
  80069a:	56                   	push   %esi
  80069b:	53                   	push   %ebx
  80069c:	83 ec 0c             	sub    $0xc,%esp
  80069f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006a2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006aa:	eb 02                	jmp    8006ae <readn+0x1c>
  8006ac:	01 c3                	add    %eax,%ebx
  8006ae:	39 f3                	cmp    %esi,%ebx
  8006b0:	73 21                	jae    8006d3 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006b2:	83 ec 04             	sub    $0x4,%esp
  8006b5:	89 f0                	mov    %esi,%eax
  8006b7:	29 d8                	sub    %ebx,%eax
  8006b9:	50                   	push   %eax
  8006ba:	89 d8                	mov    %ebx,%eax
  8006bc:	03 45 0c             	add    0xc(%ebp),%eax
  8006bf:	50                   	push   %eax
  8006c0:	57                   	push   %edi
  8006c1:	e8 41 ff ff ff       	call   800607 <read>
		if (m < 0)
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	85 c0                	test   %eax,%eax
  8006cb:	78 04                	js     8006d1 <readn+0x3f>
			return m;
		if (m == 0)
  8006cd:	75 dd                	jne    8006ac <readn+0x1a>
  8006cf:	eb 02                	jmp    8006d3 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d1:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006d3:	89 d8                	mov    %ebx,%eax
  8006d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d8:	5b                   	pop    %ebx
  8006d9:	5e                   	pop    %esi
  8006da:	5f                   	pop    %edi
  8006db:	5d                   	pop    %ebp
  8006dc:	c3                   	ret    

008006dd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006dd:	f3 0f 1e fb          	endbr32 
  8006e1:	55                   	push   %ebp
  8006e2:	89 e5                	mov    %esp,%ebp
  8006e4:	53                   	push   %ebx
  8006e5:	83 ec 1c             	sub    $0x1c,%esp
  8006e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006ee:	50                   	push   %eax
  8006ef:	53                   	push   %ebx
  8006f0:	e8 8f fc ff ff       	call   800384 <fd_lookup>
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	78 3a                	js     800736 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800706:	ff 30                	pushl  (%eax)
  800708:	e8 cb fc ff ff       	call   8003d8 <dev_lookup>
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	85 c0                	test   %eax,%eax
  800712:	78 22                	js     800736 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800714:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800717:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80071b:	74 1e                	je     80073b <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80071d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800720:	8b 52 0c             	mov    0xc(%edx),%edx
  800723:	85 d2                	test   %edx,%edx
  800725:	74 35                	je     80075c <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800727:	83 ec 04             	sub    $0x4,%esp
  80072a:	ff 75 10             	pushl  0x10(%ebp)
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	50                   	push   %eax
  800731:	ff d2                	call   *%edx
  800733:	83 c4 10             	add    $0x10,%esp
}
  800736:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800739:	c9                   	leave  
  80073a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073b:	a1 04 40 80 00       	mov    0x804004,%eax
  800740:	8b 40 48             	mov    0x48(%eax),%eax
  800743:	83 ec 04             	sub    $0x4,%esp
  800746:	53                   	push   %ebx
  800747:	50                   	push   %eax
  800748:	68 75 1e 80 00       	push   $0x801e75
  80074d:	e8 fe 09 00 00       	call   801150 <cprintf>
		return -E_INVAL;
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075a:	eb da                	jmp    800736 <write+0x59>
		return -E_NOT_SUPP;
  80075c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800761:	eb d3                	jmp    800736 <write+0x59>

00800763 <seek>:

int
seek(int fdnum, off_t offset)
{
  800763:	f3 0f 1e fb          	endbr32 
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80076d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800770:	50                   	push   %eax
  800771:	ff 75 08             	pushl  0x8(%ebp)
  800774:	e8 0b fc ff ff       	call   800384 <fd_lookup>
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	85 c0                	test   %eax,%eax
  80077e:	78 0e                	js     80078e <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800780:	8b 55 0c             	mov    0xc(%ebp),%edx
  800783:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800786:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800789:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800790:	f3 0f 1e fb          	endbr32 
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	53                   	push   %ebx
  800798:	83 ec 1c             	sub    $0x1c,%esp
  80079b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80079e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007a1:	50                   	push   %eax
  8007a2:	53                   	push   %ebx
  8007a3:	e8 dc fb ff ff       	call   800384 <fd_lookup>
  8007a8:	83 c4 10             	add    $0x10,%esp
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	78 37                	js     8007e6 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007af:	83 ec 08             	sub    $0x8,%esp
  8007b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007b5:	50                   	push   %eax
  8007b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b9:	ff 30                	pushl  (%eax)
  8007bb:	e8 18 fc ff ff       	call   8003d8 <dev_lookup>
  8007c0:	83 c4 10             	add    $0x10,%esp
  8007c3:	85 c0                	test   %eax,%eax
  8007c5:	78 1f                	js     8007e6 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ce:	74 1b                	je     8007eb <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007d3:	8b 52 18             	mov    0x18(%edx),%edx
  8007d6:	85 d2                	test   %edx,%edx
  8007d8:	74 32                	je     80080c <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007da:	83 ec 08             	sub    $0x8,%esp
  8007dd:	ff 75 0c             	pushl  0xc(%ebp)
  8007e0:	50                   	push   %eax
  8007e1:	ff d2                	call   *%edx
  8007e3:	83 c4 10             	add    $0x10,%esp
}
  8007e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e9:	c9                   	leave  
  8007ea:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007eb:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f0:	8b 40 48             	mov    0x48(%eax),%eax
  8007f3:	83 ec 04             	sub    $0x4,%esp
  8007f6:	53                   	push   %ebx
  8007f7:	50                   	push   %eax
  8007f8:	68 38 1e 80 00       	push   $0x801e38
  8007fd:	e8 4e 09 00 00       	call   801150 <cprintf>
		return -E_INVAL;
  800802:	83 c4 10             	add    $0x10,%esp
  800805:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80080a:	eb da                	jmp    8007e6 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80080c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800811:	eb d3                	jmp    8007e6 <ftruncate+0x56>

00800813 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800813:	f3 0f 1e fb          	endbr32 
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	53                   	push   %ebx
  80081b:	83 ec 1c             	sub    $0x1c,%esp
  80081e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800821:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800824:	50                   	push   %eax
  800825:	ff 75 08             	pushl  0x8(%ebp)
  800828:	e8 57 fb ff ff       	call   800384 <fd_lookup>
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	85 c0                	test   %eax,%eax
  800832:	78 4b                	js     80087f <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083a:	50                   	push   %eax
  80083b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083e:	ff 30                	pushl  (%eax)
  800840:	e8 93 fb ff ff       	call   8003d8 <dev_lookup>
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	85 c0                	test   %eax,%eax
  80084a:	78 33                	js     80087f <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80084c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800853:	74 2f                	je     800884 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800855:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800858:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80085f:	00 00 00 
	stat->st_isdir = 0;
  800862:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800869:	00 00 00 
	stat->st_dev = dev;
  80086c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800872:	83 ec 08             	sub    $0x8,%esp
  800875:	53                   	push   %ebx
  800876:	ff 75 f0             	pushl  -0x10(%ebp)
  800879:	ff 50 14             	call   *0x14(%eax)
  80087c:	83 c4 10             	add    $0x10,%esp
}
  80087f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800882:	c9                   	leave  
  800883:	c3                   	ret    
		return -E_NOT_SUPP;
  800884:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800889:	eb f4                	jmp    80087f <fstat+0x6c>

0080088b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80088b:	f3 0f 1e fb          	endbr32 
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	56                   	push   %esi
  800893:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800894:	83 ec 08             	sub    $0x8,%esp
  800897:	6a 00                	push   $0x0
  800899:	ff 75 08             	pushl  0x8(%ebp)
  80089c:	e8 20 02 00 00       	call   800ac1 <open>
  8008a1:	89 c3                	mov    %eax,%ebx
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	85 c0                	test   %eax,%eax
  8008a8:	78 1b                	js     8008c5 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008aa:	83 ec 08             	sub    $0x8,%esp
  8008ad:	ff 75 0c             	pushl  0xc(%ebp)
  8008b0:	50                   	push   %eax
  8008b1:	e8 5d ff ff ff       	call   800813 <fstat>
  8008b6:	89 c6                	mov    %eax,%esi
	close(fd);
  8008b8:	89 1c 24             	mov    %ebx,(%esp)
  8008bb:	e8 fd fb ff ff       	call   8004bd <close>
	return r;
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	89 f3                	mov    %esi,%ebx
}
  8008c5:	89 d8                	mov    %ebx,%eax
  8008c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ca:	5b                   	pop    %ebx
  8008cb:	5e                   	pop    %esi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	56                   	push   %esi
  8008d2:	53                   	push   %ebx
  8008d3:	89 c6                	mov    %eax,%esi
  8008d5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008d7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008de:	74 27                	je     800907 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008e0:	6a 07                	push   $0x7
  8008e2:	68 00 50 80 00       	push   $0x805000
  8008e7:	56                   	push   %esi
  8008e8:	ff 35 00 40 80 00    	pushl  0x804000
  8008ee:	e8 a8 11 00 00       	call   801a9b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008f3:	83 c4 0c             	add    $0xc,%esp
  8008f6:	6a 00                	push   $0x0
  8008f8:	53                   	push   %ebx
  8008f9:	6a 00                	push   $0x0
  8008fb:	e8 2e 11 00 00       	call   801a2e <ipc_recv>
}
  800900:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800903:	5b                   	pop    %ebx
  800904:	5e                   	pop    %esi
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800907:	83 ec 0c             	sub    $0xc,%esp
  80090a:	6a 01                	push   $0x1
  80090c:	e8 dd 11 00 00       	call   801aee <ipc_find_env>
  800911:	a3 00 40 80 00       	mov    %eax,0x804000
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	eb c5                	jmp    8008e0 <fsipc+0x12>

0080091b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80091b:	f3 0f 1e fb          	endbr32 
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 40 0c             	mov    0xc(%eax),%eax
  80092b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800930:	8b 45 0c             	mov    0xc(%ebp),%eax
  800933:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800938:	ba 00 00 00 00       	mov    $0x0,%edx
  80093d:	b8 02 00 00 00       	mov    $0x2,%eax
  800942:	e8 87 ff ff ff       	call   8008ce <fsipc>
}
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <devfile_flush>:
{
  800949:	f3 0f 1e fb          	endbr32 
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800953:	8b 45 08             	mov    0x8(%ebp),%eax
  800956:	8b 40 0c             	mov    0xc(%eax),%eax
  800959:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80095e:	ba 00 00 00 00       	mov    $0x0,%edx
  800963:	b8 06 00 00 00       	mov    $0x6,%eax
  800968:	e8 61 ff ff ff       	call   8008ce <fsipc>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <devfile_stat>:
{
  80096f:	f3 0f 1e fb          	endbr32 
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	53                   	push   %ebx
  800977:	83 ec 04             	sub    $0x4,%esp
  80097a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	8b 40 0c             	mov    0xc(%eax),%eax
  800983:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800988:	ba 00 00 00 00       	mov    $0x0,%edx
  80098d:	b8 05 00 00 00       	mov    $0x5,%eax
  800992:	e8 37 ff ff ff       	call   8008ce <fsipc>
  800997:	85 c0                	test   %eax,%eax
  800999:	78 2c                	js     8009c7 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80099b:	83 ec 08             	sub    $0x8,%esp
  80099e:	68 00 50 80 00       	push   $0x805000
  8009a3:	53                   	push   %ebx
  8009a4:	e8 11 0d 00 00       	call   8016ba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009a9:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ae:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b4:	a1 84 50 80 00       	mov    0x805084,%eax
  8009b9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009bf:	83 c4 10             	add    $0x10,%esp
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ca:	c9                   	leave  
  8009cb:	c3                   	ret    

008009cc <devfile_write>:
{
  8009cc:	f3 0f 1e fb          	endbr32 
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	57                   	push   %edi
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	83 ec 0c             	sub    $0xc,%esp
  8009d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e5:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  8009ea:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8009ef:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  8009f4:	85 db                	test   %ebx,%ebx
  8009f6:	74 3b                	je     800a33 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8009f8:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8009fe:	89 f8                	mov    %edi,%eax
  800a00:	0f 46 c3             	cmovbe %ebx,%eax
  800a03:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  800a08:	83 ec 04             	sub    $0x4,%esp
  800a0b:	50                   	push   %eax
  800a0c:	56                   	push   %esi
  800a0d:	68 08 50 80 00       	push   $0x805008
  800a12:	e8 5b 0e 00 00       	call   801872 <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800a17:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1c:	b8 04 00 00 00       	mov    $0x4,%eax
  800a21:	e8 a8 fe ff ff       	call   8008ce <fsipc>
  800a26:	83 c4 10             	add    $0x10,%esp
  800a29:	85 c0                	test   %eax,%eax
  800a2b:	78 06                	js     800a33 <devfile_write+0x67>
		buf_aux += r;
  800a2d:	01 c6                	add    %eax,%esi
		n -= r;
  800a2f:	29 c3                	sub    %eax,%ebx
  800a31:	eb c1                	jmp    8009f4 <devfile_write+0x28>
}
  800a33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5f                   	pop    %edi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <devfile_read>:
{
  800a3b:	f3 0f 1e fb          	endbr32 
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	56                   	push   %esi
  800a43:	53                   	push   %ebx
  800a44:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a52:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a58:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a62:	e8 67 fe ff ff       	call   8008ce <fsipc>
  800a67:	89 c3                	mov    %eax,%ebx
  800a69:	85 c0                	test   %eax,%eax
  800a6b:	78 1f                	js     800a8c <devfile_read+0x51>
	assert(r <= n);
  800a6d:	39 f0                	cmp    %esi,%eax
  800a6f:	77 24                	ja     800a95 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a71:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a76:	7f 33                	jg     800aab <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a78:	83 ec 04             	sub    $0x4,%esp
  800a7b:	50                   	push   %eax
  800a7c:	68 00 50 80 00       	push   $0x805000
  800a81:	ff 75 0c             	pushl  0xc(%ebp)
  800a84:	e8 e9 0d 00 00       	call   801872 <memmove>
	return r;
  800a89:	83 c4 10             	add    $0x10,%esp
}
  800a8c:	89 d8                	mov    %ebx,%eax
  800a8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    
	assert(r <= n);
  800a95:	68 a4 1e 80 00       	push   $0x801ea4
  800a9a:	68 ab 1e 80 00       	push   $0x801eab
  800a9f:	6a 7c                	push   $0x7c
  800aa1:	68 c0 1e 80 00       	push   $0x801ec0
  800aa6:	e8 be 05 00 00       	call   801069 <_panic>
	assert(r <= PGSIZE);
  800aab:	68 cb 1e 80 00       	push   $0x801ecb
  800ab0:	68 ab 1e 80 00       	push   $0x801eab
  800ab5:	6a 7d                	push   $0x7d
  800ab7:	68 c0 1e 80 00       	push   $0x801ec0
  800abc:	e8 a8 05 00 00       	call   801069 <_panic>

00800ac1 <open>:
{
  800ac1:	f3 0f 1e fb          	endbr32 
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
  800aca:	83 ec 1c             	sub    $0x1c,%esp
  800acd:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ad0:	56                   	push   %esi
  800ad1:	e8 a1 0b 00 00       	call   801677 <strlen>
  800ad6:	83 c4 10             	add    $0x10,%esp
  800ad9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ade:	7f 6c                	jg     800b4c <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800ae0:	83 ec 0c             	sub    $0xc,%esp
  800ae3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae6:	50                   	push   %eax
  800ae7:	e8 42 f8 ff ff       	call   80032e <fd_alloc>
  800aec:	89 c3                	mov    %eax,%ebx
  800aee:	83 c4 10             	add    $0x10,%esp
  800af1:	85 c0                	test   %eax,%eax
  800af3:	78 3c                	js     800b31 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800af5:	83 ec 08             	sub    $0x8,%esp
  800af8:	56                   	push   %esi
  800af9:	68 00 50 80 00       	push   $0x805000
  800afe:	e8 b7 0b 00 00       	call   8016ba <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b06:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b0e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b13:	e8 b6 fd ff ff       	call   8008ce <fsipc>
  800b18:	89 c3                	mov    %eax,%ebx
  800b1a:	83 c4 10             	add    $0x10,%esp
  800b1d:	85 c0                	test   %eax,%eax
  800b1f:	78 19                	js     800b3a <open+0x79>
	return fd2num(fd);
  800b21:	83 ec 0c             	sub    $0xc,%esp
  800b24:	ff 75 f4             	pushl  -0xc(%ebp)
  800b27:	e8 cf f7 ff ff       	call   8002fb <fd2num>
  800b2c:	89 c3                	mov    %eax,%ebx
  800b2e:	83 c4 10             	add    $0x10,%esp
}
  800b31:	89 d8                	mov    %ebx,%eax
  800b33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    
		fd_close(fd, 0);
  800b3a:	83 ec 08             	sub    $0x8,%esp
  800b3d:	6a 00                	push   $0x0
  800b3f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b42:	e8 eb f8 ff ff       	call   800432 <fd_close>
		return r;
  800b47:	83 c4 10             	add    $0x10,%esp
  800b4a:	eb e5                	jmp    800b31 <open+0x70>
		return -E_BAD_PATH;
  800b4c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b51:	eb de                	jmp    800b31 <open+0x70>

00800b53 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b53:	f3 0f 1e fb          	endbr32 
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b62:	b8 08 00 00 00       	mov    $0x8,%eax
  800b67:	e8 62 fd ff ff       	call   8008ce <fsipc>
}
  800b6c:	c9                   	leave  
  800b6d:	c3                   	ret    

00800b6e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b6e:	f3 0f 1e fb          	endbr32 
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b7a:	83 ec 0c             	sub    $0xc,%esp
  800b7d:	ff 75 08             	pushl  0x8(%ebp)
  800b80:	e8 8a f7 ff ff       	call   80030f <fd2data>
  800b85:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b87:	83 c4 08             	add    $0x8,%esp
  800b8a:	68 d7 1e 80 00       	push   $0x801ed7
  800b8f:	53                   	push   %ebx
  800b90:	e8 25 0b 00 00       	call   8016ba <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b95:	8b 46 04             	mov    0x4(%esi),%eax
  800b98:	2b 06                	sub    (%esi),%eax
  800b9a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ba0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ba7:	00 00 00 
	stat->st_dev = &devpipe;
  800baa:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bb1:	30 80 00 
	return 0;
}
  800bb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bc0:	f3 0f 1e fb          	endbr32 
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bce:	53                   	push   %ebx
  800bcf:	6a 00                	push   $0x0
  800bd1:	e8 3a f6 ff ff       	call   800210 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bd6:	89 1c 24             	mov    %ebx,(%esp)
  800bd9:	e8 31 f7 ff ff       	call   80030f <fd2data>
  800bde:	83 c4 08             	add    $0x8,%esp
  800be1:	50                   	push   %eax
  800be2:	6a 00                	push   $0x0
  800be4:	e8 27 f6 ff ff       	call   800210 <sys_page_unmap>
}
  800be9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bec:	c9                   	leave  
  800bed:	c3                   	ret    

00800bee <_pipeisclosed>:
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 1c             	sub    $0x1c,%esp
  800bf7:	89 c7                	mov    %eax,%edi
  800bf9:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bfb:	a1 04 40 80 00       	mov    0x804004,%eax
  800c00:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	57                   	push   %edi
  800c07:	e8 1f 0f 00 00       	call   801b2b <pageref>
  800c0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c0f:	89 34 24             	mov    %esi,(%esp)
  800c12:	e8 14 0f 00 00       	call   801b2b <pageref>
		nn = thisenv->env_runs;
  800c17:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c1d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	39 cb                	cmp    %ecx,%ebx
  800c25:	74 1b                	je     800c42 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c27:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c2a:	75 cf                	jne    800bfb <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c2c:	8b 42 58             	mov    0x58(%edx),%eax
  800c2f:	6a 01                	push   $0x1
  800c31:	50                   	push   %eax
  800c32:	53                   	push   %ebx
  800c33:	68 de 1e 80 00       	push   $0x801ede
  800c38:	e8 13 05 00 00       	call   801150 <cprintf>
  800c3d:	83 c4 10             	add    $0x10,%esp
  800c40:	eb b9                	jmp    800bfb <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c42:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c45:	0f 94 c0             	sete   %al
  800c48:	0f b6 c0             	movzbl %al,%eax
}
  800c4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <devpipe_write>:
{
  800c53:	f3 0f 1e fb          	endbr32 
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 28             	sub    $0x28,%esp
  800c60:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c63:	56                   	push   %esi
  800c64:	e8 a6 f6 ff ff       	call   80030f <fd2data>
  800c69:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c6b:	83 c4 10             	add    $0x10,%esp
  800c6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c73:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c76:	74 4f                	je     800cc7 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c78:	8b 43 04             	mov    0x4(%ebx),%eax
  800c7b:	8b 0b                	mov    (%ebx),%ecx
  800c7d:	8d 51 20             	lea    0x20(%ecx),%edx
  800c80:	39 d0                	cmp    %edx,%eax
  800c82:	72 14                	jb     800c98 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800c84:	89 da                	mov    %ebx,%edx
  800c86:	89 f0                	mov    %esi,%eax
  800c88:	e8 61 ff ff ff       	call   800bee <_pipeisclosed>
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	75 3b                	jne    800ccc <devpipe_write+0x79>
			sys_yield();
  800c91:	e8 fd f4 ff ff       	call   800193 <sys_yield>
  800c96:	eb e0                	jmp    800c78 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c9f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca2:	89 c2                	mov    %eax,%edx
  800ca4:	c1 fa 1f             	sar    $0x1f,%edx
  800ca7:	89 d1                	mov    %edx,%ecx
  800ca9:	c1 e9 1b             	shr    $0x1b,%ecx
  800cac:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800caf:	83 e2 1f             	and    $0x1f,%edx
  800cb2:	29 ca                	sub    %ecx,%edx
  800cb4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cb8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cbc:	83 c0 01             	add    $0x1,%eax
  800cbf:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cc2:	83 c7 01             	add    $0x1,%edi
  800cc5:	eb ac                	jmp    800c73 <devpipe_write+0x20>
	return i;
  800cc7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cca:	eb 05                	jmp    800cd1 <devpipe_write+0x7e>
				return 0;
  800ccc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <devpipe_read>:
{
  800cd9:	f3 0f 1e fb          	endbr32 
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
  800ce3:	83 ec 18             	sub    $0x18,%esp
  800ce6:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800ce9:	57                   	push   %edi
  800cea:	e8 20 f6 ff ff       	call   80030f <fd2data>
  800cef:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cf1:	83 c4 10             	add    $0x10,%esp
  800cf4:	be 00 00 00 00       	mov    $0x0,%esi
  800cf9:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cfc:	75 14                	jne    800d12 <devpipe_read+0x39>
	return i;
  800cfe:	8b 45 10             	mov    0x10(%ebp),%eax
  800d01:	eb 02                	jmp    800d05 <devpipe_read+0x2c>
				return i;
  800d03:	89 f0                	mov    %esi,%eax
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    
			sys_yield();
  800d0d:	e8 81 f4 ff ff       	call   800193 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d12:	8b 03                	mov    (%ebx),%eax
  800d14:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d17:	75 18                	jne    800d31 <devpipe_read+0x58>
			if (i > 0)
  800d19:	85 f6                	test   %esi,%esi
  800d1b:	75 e6                	jne    800d03 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d1d:	89 da                	mov    %ebx,%edx
  800d1f:	89 f8                	mov    %edi,%eax
  800d21:	e8 c8 fe ff ff       	call   800bee <_pipeisclosed>
  800d26:	85 c0                	test   %eax,%eax
  800d28:	74 e3                	je     800d0d <devpipe_read+0x34>
				return 0;
  800d2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2f:	eb d4                	jmp    800d05 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d31:	99                   	cltd   
  800d32:	c1 ea 1b             	shr    $0x1b,%edx
  800d35:	01 d0                	add    %edx,%eax
  800d37:	83 e0 1f             	and    $0x1f,%eax
  800d3a:	29 d0                	sub    %edx,%eax
  800d3c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d47:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d4a:	83 c6 01             	add    $0x1,%esi
  800d4d:	eb aa                	jmp    800cf9 <devpipe_read+0x20>

00800d4f <pipe>:
{
  800d4f:	f3 0f 1e fb          	endbr32 
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d5e:	50                   	push   %eax
  800d5f:	e8 ca f5 ff ff       	call   80032e <fd_alloc>
  800d64:	89 c3                	mov    %eax,%ebx
  800d66:	83 c4 10             	add    $0x10,%esp
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	0f 88 23 01 00 00    	js     800e94 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d71:	83 ec 04             	sub    $0x4,%esp
  800d74:	68 07 04 00 00       	push   $0x407
  800d79:	ff 75 f4             	pushl  -0xc(%ebp)
  800d7c:	6a 00                	push   $0x0
  800d7e:	e8 3b f4 ff ff       	call   8001be <sys_page_alloc>
  800d83:	89 c3                	mov    %eax,%ebx
  800d85:	83 c4 10             	add    $0x10,%esp
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	0f 88 04 01 00 00    	js     800e94 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d96:	50                   	push   %eax
  800d97:	e8 92 f5 ff ff       	call   80032e <fd_alloc>
  800d9c:	89 c3                	mov    %eax,%ebx
  800d9e:	83 c4 10             	add    $0x10,%esp
  800da1:	85 c0                	test   %eax,%eax
  800da3:	0f 88 db 00 00 00    	js     800e84 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da9:	83 ec 04             	sub    $0x4,%esp
  800dac:	68 07 04 00 00       	push   $0x407
  800db1:	ff 75 f0             	pushl  -0x10(%ebp)
  800db4:	6a 00                	push   $0x0
  800db6:	e8 03 f4 ff ff       	call   8001be <sys_page_alloc>
  800dbb:	89 c3                	mov    %eax,%ebx
  800dbd:	83 c4 10             	add    $0x10,%esp
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	0f 88 bc 00 00 00    	js     800e84 <pipe+0x135>
	va = fd2data(fd0);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	ff 75 f4             	pushl  -0xc(%ebp)
  800dce:	e8 3c f5 ff ff       	call   80030f <fd2data>
  800dd3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd5:	83 c4 0c             	add    $0xc,%esp
  800dd8:	68 07 04 00 00       	push   $0x407
  800ddd:	50                   	push   %eax
  800dde:	6a 00                	push   $0x0
  800de0:	e8 d9 f3 ff ff       	call   8001be <sys_page_alloc>
  800de5:	89 c3                	mov    %eax,%ebx
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	0f 88 82 00 00 00    	js     800e74 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df2:	83 ec 0c             	sub    $0xc,%esp
  800df5:	ff 75 f0             	pushl  -0x10(%ebp)
  800df8:	e8 12 f5 ff ff       	call   80030f <fd2data>
  800dfd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e04:	50                   	push   %eax
  800e05:	6a 00                	push   $0x0
  800e07:	56                   	push   %esi
  800e08:	6a 00                	push   $0x0
  800e0a:	e8 d7 f3 ff ff       	call   8001e6 <sys_page_map>
  800e0f:	89 c3                	mov    %eax,%ebx
  800e11:	83 c4 20             	add    $0x20,%esp
  800e14:	85 c0                	test   %eax,%eax
  800e16:	78 4e                	js     800e66 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e18:	a1 20 30 80 00       	mov    0x803020,%eax
  800e1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e20:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e25:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e2c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e2f:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e34:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e3b:	83 ec 0c             	sub    $0xc,%esp
  800e3e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e41:	e8 b5 f4 ff ff       	call   8002fb <fd2num>
  800e46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e49:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e4b:	83 c4 04             	add    $0x4,%esp
  800e4e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e51:	e8 a5 f4 ff ff       	call   8002fb <fd2num>
  800e56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e59:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e5c:	83 c4 10             	add    $0x10,%esp
  800e5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e64:	eb 2e                	jmp    800e94 <pipe+0x145>
	sys_page_unmap(0, va);
  800e66:	83 ec 08             	sub    $0x8,%esp
  800e69:	56                   	push   %esi
  800e6a:	6a 00                	push   $0x0
  800e6c:	e8 9f f3 ff ff       	call   800210 <sys_page_unmap>
  800e71:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e74:	83 ec 08             	sub    $0x8,%esp
  800e77:	ff 75 f0             	pushl  -0x10(%ebp)
  800e7a:	6a 00                	push   $0x0
  800e7c:	e8 8f f3 ff ff       	call   800210 <sys_page_unmap>
  800e81:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e84:	83 ec 08             	sub    $0x8,%esp
  800e87:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8a:	6a 00                	push   $0x0
  800e8c:	e8 7f f3 ff ff       	call   800210 <sys_page_unmap>
  800e91:	83 c4 10             	add    $0x10,%esp
}
  800e94:	89 d8                	mov    %ebx,%eax
  800e96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e99:	5b                   	pop    %ebx
  800e9a:	5e                   	pop    %esi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <pipeisclosed>:
{
  800e9d:	f3 0f 1e fb          	endbr32 
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ea7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eaa:	50                   	push   %eax
  800eab:	ff 75 08             	pushl  0x8(%ebp)
  800eae:	e8 d1 f4 ff ff       	call   800384 <fd_lookup>
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	78 18                	js     800ed2 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800eba:	83 ec 0c             	sub    $0xc,%esp
  800ebd:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec0:	e8 4a f4 ff ff       	call   80030f <fd2data>
  800ec5:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eca:	e8 1f fd ff ff       	call   800bee <_pipeisclosed>
  800ecf:	83 c4 10             	add    $0x10,%esp
}
  800ed2:	c9                   	leave  
  800ed3:	c3                   	ret    

00800ed4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ed4:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800ed8:	b8 00 00 00 00       	mov    $0x0,%eax
  800edd:	c3                   	ret    

00800ede <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ede:	f3 0f 1e fb          	endbr32 
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ee8:	68 f6 1e 80 00       	push   $0x801ef6
  800eed:	ff 75 0c             	pushl  0xc(%ebp)
  800ef0:	e8 c5 07 00 00       	call   8016ba <strcpy>
	return 0;
}
  800ef5:	b8 00 00 00 00       	mov    $0x0,%eax
  800efa:	c9                   	leave  
  800efb:	c3                   	ret    

00800efc <devcons_write>:
{
  800efc:	f3 0f 1e fb          	endbr32 
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
  800f06:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f0c:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f11:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f17:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f1a:	73 31                	jae    800f4d <devcons_write+0x51>
		m = n - tot;
  800f1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1f:	29 f3                	sub    %esi,%ebx
  800f21:	83 fb 7f             	cmp    $0x7f,%ebx
  800f24:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f29:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f2c:	83 ec 04             	sub    $0x4,%esp
  800f2f:	53                   	push   %ebx
  800f30:	89 f0                	mov    %esi,%eax
  800f32:	03 45 0c             	add    0xc(%ebp),%eax
  800f35:	50                   	push   %eax
  800f36:	57                   	push   %edi
  800f37:	e8 36 09 00 00       	call   801872 <memmove>
		sys_cputs(buf, m);
  800f3c:	83 c4 08             	add    $0x8,%esp
  800f3f:	53                   	push   %ebx
  800f40:	57                   	push   %edi
  800f41:	e8 ad f1 ff ff       	call   8000f3 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f46:	01 de                	add    %ebx,%esi
  800f48:	83 c4 10             	add    $0x10,%esp
  800f4b:	eb ca                	jmp    800f17 <devcons_write+0x1b>
}
  800f4d:	89 f0                	mov    %esi,%eax
  800f4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f52:	5b                   	pop    %ebx
  800f53:	5e                   	pop    %esi
  800f54:	5f                   	pop    %edi
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    

00800f57 <devcons_read>:
{
  800f57:	f3 0f 1e fb          	endbr32 
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	83 ec 08             	sub    $0x8,%esp
  800f61:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f66:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f6a:	74 21                	je     800f8d <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800f6c:	e8 ac f1 ff ff       	call   80011d <sys_cgetc>
  800f71:	85 c0                	test   %eax,%eax
  800f73:	75 07                	jne    800f7c <devcons_read+0x25>
		sys_yield();
  800f75:	e8 19 f2 ff ff       	call   800193 <sys_yield>
  800f7a:	eb f0                	jmp    800f6c <devcons_read+0x15>
	if (c < 0)
  800f7c:	78 0f                	js     800f8d <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800f7e:	83 f8 04             	cmp    $0x4,%eax
  800f81:	74 0c                	je     800f8f <devcons_read+0x38>
	*(char*)vbuf = c;
  800f83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f86:	88 02                	mov    %al,(%edx)
	return 1;
  800f88:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f8d:	c9                   	leave  
  800f8e:	c3                   	ret    
		return 0;
  800f8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f94:	eb f7                	jmp    800f8d <devcons_read+0x36>

00800f96 <cputchar>:
{
  800f96:	f3 0f 1e fb          	endbr32 
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa3:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800fa6:	6a 01                	push   $0x1
  800fa8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fab:	50                   	push   %eax
  800fac:	e8 42 f1 ff ff       	call   8000f3 <sys_cputs>
}
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	c9                   	leave  
  800fb5:	c3                   	ret    

00800fb6 <getchar>:
{
  800fb6:	f3 0f 1e fb          	endbr32 
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800fc0:	6a 01                	push   $0x1
  800fc2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc5:	50                   	push   %eax
  800fc6:	6a 00                	push   $0x0
  800fc8:	e8 3a f6 ff ff       	call   800607 <read>
	if (r < 0)
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 06                	js     800fda <getchar+0x24>
	if (r < 1)
  800fd4:	74 06                	je     800fdc <getchar+0x26>
	return c;
  800fd6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fda:	c9                   	leave  
  800fdb:	c3                   	ret    
		return -E_EOF;
  800fdc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fe1:	eb f7                	jmp    800fda <getchar+0x24>

00800fe3 <iscons>:
{
  800fe3:	f3 0f 1e fb          	endbr32 
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff0:	50                   	push   %eax
  800ff1:	ff 75 08             	pushl  0x8(%ebp)
  800ff4:	e8 8b f3 ff ff       	call   800384 <fd_lookup>
  800ff9:	83 c4 10             	add    $0x10,%esp
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	78 11                	js     801011 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801000:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801003:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801009:	39 10                	cmp    %edx,(%eax)
  80100b:	0f 94 c0             	sete   %al
  80100e:	0f b6 c0             	movzbl %al,%eax
}
  801011:	c9                   	leave  
  801012:	c3                   	ret    

00801013 <opencons>:
{
  801013:	f3 0f 1e fb          	endbr32 
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80101d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801020:	50                   	push   %eax
  801021:	e8 08 f3 ff ff       	call   80032e <fd_alloc>
  801026:	83 c4 10             	add    $0x10,%esp
  801029:	85 c0                	test   %eax,%eax
  80102b:	78 3a                	js     801067 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80102d:	83 ec 04             	sub    $0x4,%esp
  801030:	68 07 04 00 00       	push   $0x407
  801035:	ff 75 f4             	pushl  -0xc(%ebp)
  801038:	6a 00                	push   $0x0
  80103a:	e8 7f f1 ff ff       	call   8001be <sys_page_alloc>
  80103f:	83 c4 10             	add    $0x10,%esp
  801042:	85 c0                	test   %eax,%eax
  801044:	78 21                	js     801067 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801046:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801049:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80104f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801051:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801054:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	50                   	push   %eax
  80105f:	e8 97 f2 ff ff       	call   8002fb <fd2num>
  801064:	83 c4 10             	add    $0x10,%esp
}
  801067:	c9                   	leave  
  801068:	c3                   	ret    

00801069 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801069:	f3 0f 1e fb          	endbr32 
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	56                   	push   %esi
  801071:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801072:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801075:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80107b:	e8 eb f0 ff ff       	call   80016b <sys_getenvid>
  801080:	83 ec 0c             	sub    $0xc,%esp
  801083:	ff 75 0c             	pushl  0xc(%ebp)
  801086:	ff 75 08             	pushl  0x8(%ebp)
  801089:	56                   	push   %esi
  80108a:	50                   	push   %eax
  80108b:	68 04 1f 80 00       	push   $0x801f04
  801090:	e8 bb 00 00 00       	call   801150 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801095:	83 c4 18             	add    $0x18,%esp
  801098:	53                   	push   %ebx
  801099:	ff 75 10             	pushl  0x10(%ebp)
  80109c:	e8 5a 00 00 00       	call   8010fb <vcprintf>
	cprintf("\n");
  8010a1:	c7 04 24 ef 1e 80 00 	movl   $0x801eef,(%esp)
  8010a8:	e8 a3 00 00 00       	call   801150 <cprintf>
  8010ad:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010b0:	cc                   	int3   
  8010b1:	eb fd                	jmp    8010b0 <_panic+0x47>

008010b3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010b3:	f3 0f 1e fb          	endbr32 
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	53                   	push   %ebx
  8010bb:	83 ec 04             	sub    $0x4,%esp
  8010be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010c1:	8b 13                	mov    (%ebx),%edx
  8010c3:	8d 42 01             	lea    0x1(%edx),%eax
  8010c6:	89 03                	mov    %eax,(%ebx)
  8010c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010cb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010cf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010d4:	74 09                	je     8010df <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010d6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010dd:	c9                   	leave  
  8010de:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010df:	83 ec 08             	sub    $0x8,%esp
  8010e2:	68 ff 00 00 00       	push   $0xff
  8010e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8010ea:	50                   	push   %eax
  8010eb:	e8 03 f0 ff ff       	call   8000f3 <sys_cputs>
		b->idx = 0;
  8010f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	eb db                	jmp    8010d6 <putch+0x23>

008010fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010fb:	f3 0f 1e fb          	endbr32 
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801108:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80110f:	00 00 00 
	b.cnt = 0;
  801112:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801119:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80111c:	ff 75 0c             	pushl  0xc(%ebp)
  80111f:	ff 75 08             	pushl  0x8(%ebp)
  801122:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801128:	50                   	push   %eax
  801129:	68 b3 10 80 00       	push   $0x8010b3
  80112e:	e8 80 01 00 00       	call   8012b3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801133:	83 c4 08             	add    $0x8,%esp
  801136:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80113c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801142:	50                   	push   %eax
  801143:	e8 ab ef ff ff       	call   8000f3 <sys_cputs>

	return b.cnt;
}
  801148:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80114e:	c9                   	leave  
  80114f:	c3                   	ret    

00801150 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801150:	f3 0f 1e fb          	endbr32 
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80115a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80115d:	50                   	push   %eax
  80115e:	ff 75 08             	pushl  0x8(%ebp)
  801161:	e8 95 ff ff ff       	call   8010fb <vcprintf>
	va_end(ap);

	return cnt;
}
  801166:	c9                   	leave  
  801167:	c3                   	ret    

00801168 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	57                   	push   %edi
  80116c:	56                   	push   %esi
  80116d:	53                   	push   %ebx
  80116e:	83 ec 1c             	sub    $0x1c,%esp
  801171:	89 c7                	mov    %eax,%edi
  801173:	89 d6                	mov    %edx,%esi
  801175:	8b 45 08             	mov    0x8(%ebp),%eax
  801178:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117b:	89 d1                	mov    %edx,%ecx
  80117d:	89 c2                	mov    %eax,%edx
  80117f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801182:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801185:	8b 45 10             	mov    0x10(%ebp),%eax
  801188:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80118b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80118e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801195:	39 c2                	cmp    %eax,%edx
  801197:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80119a:	72 3e                	jb     8011da <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80119c:	83 ec 0c             	sub    $0xc,%esp
  80119f:	ff 75 18             	pushl  0x18(%ebp)
  8011a2:	83 eb 01             	sub    $0x1,%ebx
  8011a5:	53                   	push   %ebx
  8011a6:	50                   	push   %eax
  8011a7:	83 ec 08             	sub    $0x8,%esp
  8011aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b6:	e8 b5 09 00 00       	call   801b70 <__udivdi3>
  8011bb:	83 c4 18             	add    $0x18,%esp
  8011be:	52                   	push   %edx
  8011bf:	50                   	push   %eax
  8011c0:	89 f2                	mov    %esi,%edx
  8011c2:	89 f8                	mov    %edi,%eax
  8011c4:	e8 9f ff ff ff       	call   801168 <printnum>
  8011c9:	83 c4 20             	add    $0x20,%esp
  8011cc:	eb 13                	jmp    8011e1 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	56                   	push   %esi
  8011d2:	ff 75 18             	pushl  0x18(%ebp)
  8011d5:	ff d7                	call   *%edi
  8011d7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011da:	83 eb 01             	sub    $0x1,%ebx
  8011dd:	85 db                	test   %ebx,%ebx
  8011df:	7f ed                	jg     8011ce <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	56                   	push   %esi
  8011e5:	83 ec 04             	sub    $0x4,%esp
  8011e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f4:	e8 87 0a 00 00       	call   801c80 <__umoddi3>
  8011f9:	83 c4 14             	add    $0x14,%esp
  8011fc:	0f be 80 27 1f 80 00 	movsbl 0x801f27(%eax),%eax
  801203:	50                   	push   %eax
  801204:	ff d7                	call   *%edi
}
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120c:	5b                   	pop    %ebx
  80120d:	5e                   	pop    %esi
  80120e:	5f                   	pop    %edi
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    

00801211 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801211:	83 fa 01             	cmp    $0x1,%edx
  801214:	7f 13                	jg     801229 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801216:	85 d2                	test   %edx,%edx
  801218:	74 1c                	je     801236 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80121a:	8b 10                	mov    (%eax),%edx
  80121c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80121f:	89 08                	mov    %ecx,(%eax)
  801221:	8b 02                	mov    (%edx),%eax
  801223:	ba 00 00 00 00       	mov    $0x0,%edx
  801228:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  801229:	8b 10                	mov    (%eax),%edx
  80122b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80122e:	89 08                	mov    %ecx,(%eax)
  801230:	8b 02                	mov    (%edx),%eax
  801232:	8b 52 04             	mov    0x4(%edx),%edx
  801235:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  801236:	8b 10                	mov    (%eax),%edx
  801238:	8d 4a 04             	lea    0x4(%edx),%ecx
  80123b:	89 08                	mov    %ecx,(%eax)
  80123d:	8b 02                	mov    (%edx),%eax
  80123f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801244:	c3                   	ret    

00801245 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801245:	83 fa 01             	cmp    $0x1,%edx
  801248:	7f 0f                	jg     801259 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80124a:	85 d2                	test   %edx,%edx
  80124c:	74 18                	je     801266 <getint+0x21>
		return va_arg(*ap, long);
  80124e:	8b 10                	mov    (%eax),%edx
  801250:	8d 4a 04             	lea    0x4(%edx),%ecx
  801253:	89 08                	mov    %ecx,(%eax)
  801255:	8b 02                	mov    (%edx),%eax
  801257:	99                   	cltd   
  801258:	c3                   	ret    
		return va_arg(*ap, long long);
  801259:	8b 10                	mov    (%eax),%edx
  80125b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80125e:	89 08                	mov    %ecx,(%eax)
  801260:	8b 02                	mov    (%edx),%eax
  801262:	8b 52 04             	mov    0x4(%edx),%edx
  801265:	c3                   	ret    
	else
		return va_arg(*ap, int);
  801266:	8b 10                	mov    (%eax),%edx
  801268:	8d 4a 04             	lea    0x4(%edx),%ecx
  80126b:	89 08                	mov    %ecx,(%eax)
  80126d:	8b 02                	mov    (%edx),%eax
  80126f:	99                   	cltd   
}
  801270:	c3                   	ret    

00801271 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801271:	f3 0f 1e fb          	endbr32 
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80127b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80127f:	8b 10                	mov    (%eax),%edx
  801281:	3b 50 04             	cmp    0x4(%eax),%edx
  801284:	73 0a                	jae    801290 <sprintputch+0x1f>
		*b->buf++ = ch;
  801286:	8d 4a 01             	lea    0x1(%edx),%ecx
  801289:	89 08                	mov    %ecx,(%eax)
  80128b:	8b 45 08             	mov    0x8(%ebp),%eax
  80128e:	88 02                	mov    %al,(%edx)
}
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    

00801292 <printfmt>:
{
  801292:	f3 0f 1e fb          	endbr32 
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80129c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80129f:	50                   	push   %eax
  8012a0:	ff 75 10             	pushl  0x10(%ebp)
  8012a3:	ff 75 0c             	pushl  0xc(%ebp)
  8012a6:	ff 75 08             	pushl  0x8(%ebp)
  8012a9:	e8 05 00 00 00       	call   8012b3 <vprintfmt>
}
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	c9                   	leave  
  8012b2:	c3                   	ret    

008012b3 <vprintfmt>:
{
  8012b3:	f3 0f 1e fb          	endbr32 
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	57                   	push   %edi
  8012bb:	56                   	push   %esi
  8012bc:	53                   	push   %ebx
  8012bd:	83 ec 2c             	sub    $0x2c,%esp
  8012c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012c3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012c6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012c9:	e9 86 02 00 00       	jmp    801554 <vprintfmt+0x2a1>
		padc = ' ';
  8012ce:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012d2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012d9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012e0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012e7:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012ec:	8d 47 01             	lea    0x1(%edi),%eax
  8012ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f2:	0f b6 17             	movzbl (%edi),%edx
  8012f5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012f8:	3c 55                	cmp    $0x55,%al
  8012fa:	0f 87 df 02 00 00    	ja     8015df <vprintfmt+0x32c>
  801300:	0f b6 c0             	movzbl %al,%eax
  801303:	3e ff 24 85 60 20 80 	notrack jmp *0x802060(,%eax,4)
  80130a:	00 
  80130b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80130e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801312:	eb d8                	jmp    8012ec <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801317:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80131b:	eb cf                	jmp    8012ec <vprintfmt+0x39>
  80131d:	0f b6 d2             	movzbl %dl,%edx
  801320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801323:	b8 00 00 00 00       	mov    $0x0,%eax
  801328:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80132b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80132e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801332:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801335:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801338:	83 f9 09             	cmp    $0x9,%ecx
  80133b:	77 52                	ja     80138f <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  80133d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801340:	eb e9                	jmp    80132b <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801342:	8b 45 14             	mov    0x14(%ebp),%eax
  801345:	8d 50 04             	lea    0x4(%eax),%edx
  801348:	89 55 14             	mov    %edx,0x14(%ebp)
  80134b:	8b 00                	mov    (%eax),%eax
  80134d:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801353:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801357:	79 93                	jns    8012ec <vprintfmt+0x39>
				width = precision, precision = -1;
  801359:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80135c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80135f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801366:	eb 84                	jmp    8012ec <vprintfmt+0x39>
  801368:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80136b:	85 c0                	test   %eax,%eax
  80136d:	ba 00 00 00 00       	mov    $0x0,%edx
  801372:	0f 49 d0             	cmovns %eax,%edx
  801375:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80137b:	e9 6c ff ff ff       	jmp    8012ec <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801383:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80138a:	e9 5d ff ff ff       	jmp    8012ec <vprintfmt+0x39>
  80138f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801392:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801395:	eb bc                	jmp    801353 <vprintfmt+0xa0>
			lflag++;
  801397:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80139a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80139d:	e9 4a ff ff ff       	jmp    8012ec <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a5:	8d 50 04             	lea    0x4(%eax),%edx
  8013a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8013ab:	83 ec 08             	sub    $0x8,%esp
  8013ae:	56                   	push   %esi
  8013af:	ff 30                	pushl  (%eax)
  8013b1:	ff d3                	call   *%ebx
			break;
  8013b3:	83 c4 10             	add    $0x10,%esp
  8013b6:	e9 96 01 00 00       	jmp    801551 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8013bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8013be:	8d 50 04             	lea    0x4(%eax),%edx
  8013c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c4:	8b 00                	mov    (%eax),%eax
  8013c6:	99                   	cltd   
  8013c7:	31 d0                	xor    %edx,%eax
  8013c9:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013cb:	83 f8 0f             	cmp    $0xf,%eax
  8013ce:	7f 20                	jg     8013f0 <vprintfmt+0x13d>
  8013d0:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  8013d7:	85 d2                	test   %edx,%edx
  8013d9:	74 15                	je     8013f0 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8013db:	52                   	push   %edx
  8013dc:	68 bd 1e 80 00       	push   $0x801ebd
  8013e1:	56                   	push   %esi
  8013e2:	53                   	push   %ebx
  8013e3:	e8 aa fe ff ff       	call   801292 <printfmt>
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	e9 61 01 00 00       	jmp    801551 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8013f0:	50                   	push   %eax
  8013f1:	68 3f 1f 80 00       	push   $0x801f3f
  8013f6:	56                   	push   %esi
  8013f7:	53                   	push   %ebx
  8013f8:	e8 95 fe ff ff       	call   801292 <printfmt>
  8013fd:	83 c4 10             	add    $0x10,%esp
  801400:	e9 4c 01 00 00       	jmp    801551 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  801405:	8b 45 14             	mov    0x14(%ebp),%eax
  801408:	8d 50 04             	lea    0x4(%eax),%edx
  80140b:	89 55 14             	mov    %edx,0x14(%ebp)
  80140e:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  801410:	85 c9                	test   %ecx,%ecx
  801412:	b8 38 1f 80 00       	mov    $0x801f38,%eax
  801417:	0f 45 c1             	cmovne %ecx,%eax
  80141a:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80141d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801421:	7e 06                	jle    801429 <vprintfmt+0x176>
  801423:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801427:	75 0d                	jne    801436 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  801429:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80142c:	89 c7                	mov    %eax,%edi
  80142e:	03 45 e0             	add    -0x20(%ebp),%eax
  801431:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801434:	eb 57                	jmp    80148d <vprintfmt+0x1da>
  801436:	83 ec 08             	sub    $0x8,%esp
  801439:	ff 75 d8             	pushl  -0x28(%ebp)
  80143c:	ff 75 cc             	pushl  -0x34(%ebp)
  80143f:	e8 4f 02 00 00       	call   801693 <strnlen>
  801444:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801447:	29 c2                	sub    %eax,%edx
  801449:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80144c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80144f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801453:	89 5d 08             	mov    %ebx,0x8(%ebp)
  801456:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  801458:	85 db                	test   %ebx,%ebx
  80145a:	7e 10                	jle    80146c <vprintfmt+0x1b9>
					putch(padc, putdat);
  80145c:	83 ec 08             	sub    $0x8,%esp
  80145f:	56                   	push   %esi
  801460:	57                   	push   %edi
  801461:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801464:	83 eb 01             	sub    $0x1,%ebx
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	eb ec                	jmp    801458 <vprintfmt+0x1a5>
  80146c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80146f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801472:	85 d2                	test   %edx,%edx
  801474:	b8 00 00 00 00       	mov    $0x0,%eax
  801479:	0f 49 c2             	cmovns %edx,%eax
  80147c:	29 c2                	sub    %eax,%edx
  80147e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801481:	eb a6                	jmp    801429 <vprintfmt+0x176>
					putch(ch, putdat);
  801483:	83 ec 08             	sub    $0x8,%esp
  801486:	56                   	push   %esi
  801487:	52                   	push   %edx
  801488:	ff d3                	call   *%ebx
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801490:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801492:	83 c7 01             	add    $0x1,%edi
  801495:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801499:	0f be d0             	movsbl %al,%edx
  80149c:	85 d2                	test   %edx,%edx
  80149e:	74 42                	je     8014e2 <vprintfmt+0x22f>
  8014a0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014a4:	78 06                	js     8014ac <vprintfmt+0x1f9>
  8014a6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014aa:	78 1e                	js     8014ca <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8014ac:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014b0:	74 d1                	je     801483 <vprintfmt+0x1d0>
  8014b2:	0f be c0             	movsbl %al,%eax
  8014b5:	83 e8 20             	sub    $0x20,%eax
  8014b8:	83 f8 5e             	cmp    $0x5e,%eax
  8014bb:	76 c6                	jbe    801483 <vprintfmt+0x1d0>
					putch('?', putdat);
  8014bd:	83 ec 08             	sub    $0x8,%esp
  8014c0:	56                   	push   %esi
  8014c1:	6a 3f                	push   $0x3f
  8014c3:	ff d3                	call   *%ebx
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	eb c3                	jmp    80148d <vprintfmt+0x1da>
  8014ca:	89 cf                	mov    %ecx,%edi
  8014cc:	eb 0e                	jmp    8014dc <vprintfmt+0x229>
				putch(' ', putdat);
  8014ce:	83 ec 08             	sub    $0x8,%esp
  8014d1:	56                   	push   %esi
  8014d2:	6a 20                	push   $0x20
  8014d4:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8014d6:	83 ef 01             	sub    $0x1,%edi
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	85 ff                	test   %edi,%edi
  8014de:	7f ee                	jg     8014ce <vprintfmt+0x21b>
  8014e0:	eb 6f                	jmp    801551 <vprintfmt+0x29e>
  8014e2:	89 cf                	mov    %ecx,%edi
  8014e4:	eb f6                	jmp    8014dc <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8014e6:	89 ca                	mov    %ecx,%edx
  8014e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8014eb:	e8 55 fd ff ff       	call   801245 <getint>
  8014f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f3:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8014f6:	85 d2                	test   %edx,%edx
  8014f8:	78 0b                	js     801505 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8014fa:	89 d1                	mov    %edx,%ecx
  8014fc:	89 c2                	mov    %eax,%edx
			base = 10;
  8014fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  801503:	eb 32                	jmp    801537 <vprintfmt+0x284>
				putch('-', putdat);
  801505:	83 ec 08             	sub    $0x8,%esp
  801508:	56                   	push   %esi
  801509:	6a 2d                	push   $0x2d
  80150b:	ff d3                	call   *%ebx
				num = -(long long) num;
  80150d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801510:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801513:	f7 da                	neg    %edx
  801515:	83 d1 00             	adc    $0x0,%ecx
  801518:	f7 d9                	neg    %ecx
  80151a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80151d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801522:	eb 13                	jmp    801537 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  801524:	89 ca                	mov    %ecx,%edx
  801526:	8d 45 14             	lea    0x14(%ebp),%eax
  801529:	e8 e3 fc ff ff       	call   801211 <getuint>
  80152e:	89 d1                	mov    %edx,%ecx
  801530:	89 c2                	mov    %eax,%edx
			base = 10;
  801532:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  801537:	83 ec 0c             	sub    $0xc,%esp
  80153a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80153e:	57                   	push   %edi
  80153f:	ff 75 e0             	pushl  -0x20(%ebp)
  801542:	50                   	push   %eax
  801543:	51                   	push   %ecx
  801544:	52                   	push   %edx
  801545:	89 f2                	mov    %esi,%edx
  801547:	89 d8                	mov    %ebx,%eax
  801549:	e8 1a fc ff ff       	call   801168 <printnum>
			break;
  80154e:	83 c4 20             	add    $0x20,%esp
{
  801551:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801554:	83 c7 01             	add    $0x1,%edi
  801557:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80155b:	83 f8 25             	cmp    $0x25,%eax
  80155e:	0f 84 6a fd ff ff    	je     8012ce <vprintfmt+0x1b>
			if (ch == '\0')
  801564:	85 c0                	test   %eax,%eax
  801566:	0f 84 93 00 00 00    	je     8015ff <vprintfmt+0x34c>
			putch(ch, putdat);
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	56                   	push   %esi
  801570:	50                   	push   %eax
  801571:	ff d3                	call   *%ebx
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	eb dc                	jmp    801554 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  801578:	89 ca                	mov    %ecx,%edx
  80157a:	8d 45 14             	lea    0x14(%ebp),%eax
  80157d:	e8 8f fc ff ff       	call   801211 <getuint>
  801582:	89 d1                	mov    %edx,%ecx
  801584:	89 c2                	mov    %eax,%edx
			base = 8;
  801586:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80158b:	eb aa                	jmp    801537 <vprintfmt+0x284>
			putch('0', putdat);
  80158d:	83 ec 08             	sub    $0x8,%esp
  801590:	56                   	push   %esi
  801591:	6a 30                	push   $0x30
  801593:	ff d3                	call   *%ebx
			putch('x', putdat);
  801595:	83 c4 08             	add    $0x8,%esp
  801598:	56                   	push   %esi
  801599:	6a 78                	push   $0x78
  80159b:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  80159d:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a0:	8d 50 04             	lea    0x4(%eax),%edx
  8015a3:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8015a6:	8b 10                	mov    (%eax),%edx
  8015a8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015ad:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8015b0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015b5:	eb 80                	jmp    801537 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8015b7:	89 ca                	mov    %ecx,%edx
  8015b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8015bc:	e8 50 fc ff ff       	call   801211 <getuint>
  8015c1:	89 d1                	mov    %edx,%ecx
  8015c3:	89 c2                	mov    %eax,%edx
			base = 16;
  8015c5:	b8 10 00 00 00       	mov    $0x10,%eax
  8015ca:	e9 68 ff ff ff       	jmp    801537 <vprintfmt+0x284>
			putch(ch, putdat);
  8015cf:	83 ec 08             	sub    $0x8,%esp
  8015d2:	56                   	push   %esi
  8015d3:	6a 25                	push   $0x25
  8015d5:	ff d3                	call   *%ebx
			break;
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	e9 72 ff ff ff       	jmp    801551 <vprintfmt+0x29e>
			putch('%', putdat);
  8015df:	83 ec 08             	sub    $0x8,%esp
  8015e2:	56                   	push   %esi
  8015e3:	6a 25                	push   $0x25
  8015e5:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	89 f8                	mov    %edi,%eax
  8015ec:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015f0:	74 05                	je     8015f7 <vprintfmt+0x344>
  8015f2:	83 e8 01             	sub    $0x1,%eax
  8015f5:	eb f5                	jmp    8015ec <vprintfmt+0x339>
  8015f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015fa:	e9 52 ff ff ff       	jmp    801551 <vprintfmt+0x29e>
}
  8015ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801602:	5b                   	pop    %ebx
  801603:	5e                   	pop    %esi
  801604:	5f                   	pop    %edi
  801605:	5d                   	pop    %ebp
  801606:	c3                   	ret    

00801607 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801607:	f3 0f 1e fb          	endbr32 
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	83 ec 18             	sub    $0x18,%esp
  801611:	8b 45 08             	mov    0x8(%ebp),%eax
  801614:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801617:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80161a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80161e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801621:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801628:	85 c0                	test   %eax,%eax
  80162a:	74 26                	je     801652 <vsnprintf+0x4b>
  80162c:	85 d2                	test   %edx,%edx
  80162e:	7e 22                	jle    801652 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801630:	ff 75 14             	pushl  0x14(%ebp)
  801633:	ff 75 10             	pushl  0x10(%ebp)
  801636:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801639:	50                   	push   %eax
  80163a:	68 71 12 80 00       	push   $0x801271
  80163f:	e8 6f fc ff ff       	call   8012b3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801644:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801647:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80164a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80164d:	83 c4 10             	add    $0x10,%esp
}
  801650:	c9                   	leave  
  801651:	c3                   	ret    
		return -E_INVAL;
  801652:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801657:	eb f7                	jmp    801650 <vsnprintf+0x49>

00801659 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801659:	f3 0f 1e fb          	endbr32 
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801663:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801666:	50                   	push   %eax
  801667:	ff 75 10             	pushl  0x10(%ebp)
  80166a:	ff 75 0c             	pushl  0xc(%ebp)
  80166d:	ff 75 08             	pushl  0x8(%ebp)
  801670:	e8 92 ff ff ff       	call   801607 <vsnprintf>
	va_end(ap);

	return rc;
}
  801675:	c9                   	leave  
  801676:	c3                   	ret    

00801677 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801677:	f3 0f 1e fb          	endbr32 
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801681:	b8 00 00 00 00       	mov    $0x0,%eax
  801686:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80168a:	74 05                	je     801691 <strlen+0x1a>
		n++;
  80168c:	83 c0 01             	add    $0x1,%eax
  80168f:	eb f5                	jmp    801686 <strlen+0xf>
	return n;
}
  801691:	5d                   	pop    %ebp
  801692:	c3                   	ret    

00801693 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801693:	f3 0f 1e fb          	endbr32 
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80169d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a5:	39 d0                	cmp    %edx,%eax
  8016a7:	74 0d                	je     8016b6 <strnlen+0x23>
  8016a9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016ad:	74 05                	je     8016b4 <strnlen+0x21>
		n++;
  8016af:	83 c0 01             	add    $0x1,%eax
  8016b2:	eb f1                	jmp    8016a5 <strnlen+0x12>
  8016b4:	89 c2                	mov    %eax,%edx
	return n;
}
  8016b6:	89 d0                	mov    %edx,%eax
  8016b8:	5d                   	pop    %ebp
  8016b9:	c3                   	ret    

008016ba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016ba:	f3 0f 1e fb          	endbr32 
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	53                   	push   %ebx
  8016c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016cd:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016d1:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016d4:	83 c0 01             	add    $0x1,%eax
  8016d7:	84 d2                	test   %dl,%dl
  8016d9:	75 f2                	jne    8016cd <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8016db:	89 c8                	mov    %ecx,%eax
  8016dd:	5b                   	pop    %ebx
  8016de:	5d                   	pop    %ebp
  8016df:	c3                   	ret    

008016e0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016e0:	f3 0f 1e fb          	endbr32 
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	53                   	push   %ebx
  8016e8:	83 ec 10             	sub    $0x10,%esp
  8016eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016ee:	53                   	push   %ebx
  8016ef:	e8 83 ff ff ff       	call   801677 <strlen>
  8016f4:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016f7:	ff 75 0c             	pushl  0xc(%ebp)
  8016fa:	01 d8                	add    %ebx,%eax
  8016fc:	50                   	push   %eax
  8016fd:	e8 b8 ff ff ff       	call   8016ba <strcpy>
	return dst;
}
  801702:	89 d8                	mov    %ebx,%eax
  801704:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801707:	c9                   	leave  
  801708:	c3                   	ret    

00801709 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801709:	f3 0f 1e fb          	endbr32 
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	56                   	push   %esi
  801711:	53                   	push   %ebx
  801712:	8b 75 08             	mov    0x8(%ebp),%esi
  801715:	8b 55 0c             	mov    0xc(%ebp),%edx
  801718:	89 f3                	mov    %esi,%ebx
  80171a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80171d:	89 f0                	mov    %esi,%eax
  80171f:	39 d8                	cmp    %ebx,%eax
  801721:	74 11                	je     801734 <strncpy+0x2b>
		*dst++ = *src;
  801723:	83 c0 01             	add    $0x1,%eax
  801726:	0f b6 0a             	movzbl (%edx),%ecx
  801729:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80172c:	80 f9 01             	cmp    $0x1,%cl
  80172f:	83 da ff             	sbb    $0xffffffff,%edx
  801732:	eb eb                	jmp    80171f <strncpy+0x16>
	}
	return ret;
}
  801734:	89 f0                	mov    %esi,%eax
  801736:	5b                   	pop    %ebx
  801737:	5e                   	pop    %esi
  801738:	5d                   	pop    %ebp
  801739:	c3                   	ret    

0080173a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80173a:	f3 0f 1e fb          	endbr32 
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	56                   	push   %esi
  801742:	53                   	push   %ebx
  801743:	8b 75 08             	mov    0x8(%ebp),%esi
  801746:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801749:	8b 55 10             	mov    0x10(%ebp),%edx
  80174c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80174e:	85 d2                	test   %edx,%edx
  801750:	74 21                	je     801773 <strlcpy+0x39>
  801752:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801756:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801758:	39 c2                	cmp    %eax,%edx
  80175a:	74 14                	je     801770 <strlcpy+0x36>
  80175c:	0f b6 19             	movzbl (%ecx),%ebx
  80175f:	84 db                	test   %bl,%bl
  801761:	74 0b                	je     80176e <strlcpy+0x34>
			*dst++ = *src++;
  801763:	83 c1 01             	add    $0x1,%ecx
  801766:	83 c2 01             	add    $0x1,%edx
  801769:	88 5a ff             	mov    %bl,-0x1(%edx)
  80176c:	eb ea                	jmp    801758 <strlcpy+0x1e>
  80176e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801770:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801773:	29 f0                	sub    %esi,%eax
}
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801779:	f3 0f 1e fb          	endbr32 
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801783:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801786:	0f b6 01             	movzbl (%ecx),%eax
  801789:	84 c0                	test   %al,%al
  80178b:	74 0c                	je     801799 <strcmp+0x20>
  80178d:	3a 02                	cmp    (%edx),%al
  80178f:	75 08                	jne    801799 <strcmp+0x20>
		p++, q++;
  801791:	83 c1 01             	add    $0x1,%ecx
  801794:	83 c2 01             	add    $0x1,%edx
  801797:	eb ed                	jmp    801786 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801799:	0f b6 c0             	movzbl %al,%eax
  80179c:	0f b6 12             	movzbl (%edx),%edx
  80179f:	29 d0                	sub    %edx,%eax
}
  8017a1:	5d                   	pop    %ebp
  8017a2:	c3                   	ret    

008017a3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017a3:	f3 0f 1e fb          	endbr32 
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	53                   	push   %ebx
  8017ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b1:	89 c3                	mov    %eax,%ebx
  8017b3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017b6:	eb 06                	jmp    8017be <strncmp+0x1b>
		n--, p++, q++;
  8017b8:	83 c0 01             	add    $0x1,%eax
  8017bb:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017be:	39 d8                	cmp    %ebx,%eax
  8017c0:	74 16                	je     8017d8 <strncmp+0x35>
  8017c2:	0f b6 08             	movzbl (%eax),%ecx
  8017c5:	84 c9                	test   %cl,%cl
  8017c7:	74 04                	je     8017cd <strncmp+0x2a>
  8017c9:	3a 0a                	cmp    (%edx),%cl
  8017cb:	74 eb                	je     8017b8 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017cd:	0f b6 00             	movzbl (%eax),%eax
  8017d0:	0f b6 12             	movzbl (%edx),%edx
  8017d3:	29 d0                	sub    %edx,%eax
}
  8017d5:	5b                   	pop    %ebx
  8017d6:	5d                   	pop    %ebp
  8017d7:	c3                   	ret    
		return 0;
  8017d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017dd:	eb f6                	jmp    8017d5 <strncmp+0x32>

008017df <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017df:	f3 0f 1e fb          	endbr32 
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ed:	0f b6 10             	movzbl (%eax),%edx
  8017f0:	84 d2                	test   %dl,%dl
  8017f2:	74 09                	je     8017fd <strchr+0x1e>
		if (*s == c)
  8017f4:	38 ca                	cmp    %cl,%dl
  8017f6:	74 0a                	je     801802 <strchr+0x23>
	for (; *s; s++)
  8017f8:	83 c0 01             	add    $0x1,%eax
  8017fb:	eb f0                	jmp    8017ed <strchr+0xe>
			return (char *) s;
	return 0;
  8017fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801802:	5d                   	pop    %ebp
  801803:	c3                   	ret    

00801804 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801804:	f3 0f 1e fb          	endbr32 
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801812:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801815:	38 ca                	cmp    %cl,%dl
  801817:	74 09                	je     801822 <strfind+0x1e>
  801819:	84 d2                	test   %dl,%dl
  80181b:	74 05                	je     801822 <strfind+0x1e>
	for (; *s; s++)
  80181d:	83 c0 01             	add    $0x1,%eax
  801820:	eb f0                	jmp    801812 <strfind+0xe>
			break;
	return (char *) s;
}
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801824:	f3 0f 1e fb          	endbr32 
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	57                   	push   %edi
  80182c:	56                   	push   %esi
  80182d:	53                   	push   %ebx
  80182e:	8b 55 08             	mov    0x8(%ebp),%edx
  801831:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  801834:	85 c9                	test   %ecx,%ecx
  801836:	74 33                	je     80186b <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801838:	89 d0                	mov    %edx,%eax
  80183a:	09 c8                	or     %ecx,%eax
  80183c:	a8 03                	test   $0x3,%al
  80183e:	75 23                	jne    801863 <memset+0x3f>
		c &= 0xFF;
  801840:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801844:	89 d8                	mov    %ebx,%eax
  801846:	c1 e0 08             	shl    $0x8,%eax
  801849:	89 df                	mov    %ebx,%edi
  80184b:	c1 e7 18             	shl    $0x18,%edi
  80184e:	89 de                	mov    %ebx,%esi
  801850:	c1 e6 10             	shl    $0x10,%esi
  801853:	09 f7                	or     %esi,%edi
  801855:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  801857:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80185a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80185c:	89 d7                	mov    %edx,%edi
  80185e:	fc                   	cld    
  80185f:	f3 ab                	rep stos %eax,%es:(%edi)
  801861:	eb 08                	jmp    80186b <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801863:	89 d7                	mov    %edx,%edi
  801865:	8b 45 0c             	mov    0xc(%ebp),%eax
  801868:	fc                   	cld    
  801869:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  80186b:	89 d0                	mov    %edx,%eax
  80186d:	5b                   	pop    %ebx
  80186e:	5e                   	pop    %esi
  80186f:	5f                   	pop    %edi
  801870:	5d                   	pop    %ebp
  801871:	c3                   	ret    

00801872 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801872:	f3 0f 1e fb          	endbr32 
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	57                   	push   %edi
  80187a:	56                   	push   %esi
  80187b:	8b 45 08             	mov    0x8(%ebp),%eax
  80187e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801881:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801884:	39 c6                	cmp    %eax,%esi
  801886:	73 32                	jae    8018ba <memmove+0x48>
  801888:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80188b:	39 c2                	cmp    %eax,%edx
  80188d:	76 2b                	jbe    8018ba <memmove+0x48>
		s += n;
		d += n;
  80188f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801892:	89 fe                	mov    %edi,%esi
  801894:	09 ce                	or     %ecx,%esi
  801896:	09 d6                	or     %edx,%esi
  801898:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80189e:	75 0e                	jne    8018ae <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018a0:	83 ef 04             	sub    $0x4,%edi
  8018a3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018a6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018a9:	fd                   	std    
  8018aa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ac:	eb 09                	jmp    8018b7 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018ae:	83 ef 01             	sub    $0x1,%edi
  8018b1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018b4:	fd                   	std    
  8018b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b7:	fc                   	cld    
  8018b8:	eb 1a                	jmp    8018d4 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ba:	89 c2                	mov    %eax,%edx
  8018bc:	09 ca                	or     %ecx,%edx
  8018be:	09 f2                	or     %esi,%edx
  8018c0:	f6 c2 03             	test   $0x3,%dl
  8018c3:	75 0a                	jne    8018cf <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018c5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018c8:	89 c7                	mov    %eax,%edi
  8018ca:	fc                   	cld    
  8018cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018cd:	eb 05                	jmp    8018d4 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8018cf:	89 c7                	mov    %eax,%edi
  8018d1:	fc                   	cld    
  8018d2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d4:	5e                   	pop    %esi
  8018d5:	5f                   	pop    %edi
  8018d6:	5d                   	pop    %ebp
  8018d7:	c3                   	ret    

008018d8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d8:	f3 0f 1e fb          	endbr32 
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018e2:	ff 75 10             	pushl  0x10(%ebp)
  8018e5:	ff 75 0c             	pushl  0xc(%ebp)
  8018e8:	ff 75 08             	pushl  0x8(%ebp)
  8018eb:	e8 82 ff ff ff       	call   801872 <memmove>
}
  8018f0:	c9                   	leave  
  8018f1:	c3                   	ret    

008018f2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018f2:	f3 0f 1e fb          	endbr32 
  8018f6:	55                   	push   %ebp
  8018f7:	89 e5                	mov    %esp,%ebp
  8018f9:	56                   	push   %esi
  8018fa:	53                   	push   %ebx
  8018fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801901:	89 c6                	mov    %eax,%esi
  801903:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801906:	39 f0                	cmp    %esi,%eax
  801908:	74 1c                	je     801926 <memcmp+0x34>
		if (*s1 != *s2)
  80190a:	0f b6 08             	movzbl (%eax),%ecx
  80190d:	0f b6 1a             	movzbl (%edx),%ebx
  801910:	38 d9                	cmp    %bl,%cl
  801912:	75 08                	jne    80191c <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801914:	83 c0 01             	add    $0x1,%eax
  801917:	83 c2 01             	add    $0x1,%edx
  80191a:	eb ea                	jmp    801906 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  80191c:	0f b6 c1             	movzbl %cl,%eax
  80191f:	0f b6 db             	movzbl %bl,%ebx
  801922:	29 d8                	sub    %ebx,%eax
  801924:	eb 05                	jmp    80192b <memcmp+0x39>
	}

	return 0;
  801926:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192b:	5b                   	pop    %ebx
  80192c:	5e                   	pop    %esi
  80192d:	5d                   	pop    %ebp
  80192e:	c3                   	ret    

0080192f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80192f:	f3 0f 1e fb          	endbr32 
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	8b 45 08             	mov    0x8(%ebp),%eax
  801939:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80193c:	89 c2                	mov    %eax,%edx
  80193e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801941:	39 d0                	cmp    %edx,%eax
  801943:	73 09                	jae    80194e <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801945:	38 08                	cmp    %cl,(%eax)
  801947:	74 05                	je     80194e <memfind+0x1f>
	for (; s < ends; s++)
  801949:	83 c0 01             	add    $0x1,%eax
  80194c:	eb f3                	jmp    801941 <memfind+0x12>
			break;
	return (void *) s;
}
  80194e:	5d                   	pop    %ebp
  80194f:	c3                   	ret    

00801950 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801950:	f3 0f 1e fb          	endbr32 
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	57                   	push   %edi
  801958:	56                   	push   %esi
  801959:	53                   	push   %ebx
  80195a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80195d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801960:	eb 03                	jmp    801965 <strtol+0x15>
		s++;
  801962:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801965:	0f b6 01             	movzbl (%ecx),%eax
  801968:	3c 20                	cmp    $0x20,%al
  80196a:	74 f6                	je     801962 <strtol+0x12>
  80196c:	3c 09                	cmp    $0x9,%al
  80196e:	74 f2                	je     801962 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801970:	3c 2b                	cmp    $0x2b,%al
  801972:	74 2a                	je     80199e <strtol+0x4e>
	int neg = 0;
  801974:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801979:	3c 2d                	cmp    $0x2d,%al
  80197b:	74 2b                	je     8019a8 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80197d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801983:	75 0f                	jne    801994 <strtol+0x44>
  801985:	80 39 30             	cmpb   $0x30,(%ecx)
  801988:	74 28                	je     8019b2 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80198a:	85 db                	test   %ebx,%ebx
  80198c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801991:	0f 44 d8             	cmove  %eax,%ebx
  801994:	b8 00 00 00 00       	mov    $0x0,%eax
  801999:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80199c:	eb 46                	jmp    8019e4 <strtol+0x94>
		s++;
  80199e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019a1:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a6:	eb d5                	jmp    80197d <strtol+0x2d>
		s++, neg = 1;
  8019a8:	83 c1 01             	add    $0x1,%ecx
  8019ab:	bf 01 00 00 00       	mov    $0x1,%edi
  8019b0:	eb cb                	jmp    80197d <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019b6:	74 0e                	je     8019c6 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019b8:	85 db                	test   %ebx,%ebx
  8019ba:	75 d8                	jne    801994 <strtol+0x44>
		s++, base = 8;
  8019bc:	83 c1 01             	add    $0x1,%ecx
  8019bf:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019c4:	eb ce                	jmp    801994 <strtol+0x44>
		s += 2, base = 16;
  8019c6:	83 c1 02             	add    $0x2,%ecx
  8019c9:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019ce:	eb c4                	jmp    801994 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019d0:	0f be d2             	movsbl %dl,%edx
  8019d3:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019d6:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019d9:	7d 3a                	jge    801a15 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019db:	83 c1 01             	add    $0x1,%ecx
  8019de:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019e2:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019e4:	0f b6 11             	movzbl (%ecx),%edx
  8019e7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019ea:	89 f3                	mov    %esi,%ebx
  8019ec:	80 fb 09             	cmp    $0x9,%bl
  8019ef:	76 df                	jbe    8019d0 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8019f1:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019f4:	89 f3                	mov    %esi,%ebx
  8019f6:	80 fb 19             	cmp    $0x19,%bl
  8019f9:	77 08                	ja     801a03 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019fb:	0f be d2             	movsbl %dl,%edx
  8019fe:	83 ea 57             	sub    $0x57,%edx
  801a01:	eb d3                	jmp    8019d6 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801a03:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a06:	89 f3                	mov    %esi,%ebx
  801a08:	80 fb 19             	cmp    $0x19,%bl
  801a0b:	77 08                	ja     801a15 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a0d:	0f be d2             	movsbl %dl,%edx
  801a10:	83 ea 37             	sub    $0x37,%edx
  801a13:	eb c1                	jmp    8019d6 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a19:	74 05                	je     801a20 <strtol+0xd0>
		*endptr = (char *) s;
  801a1b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a1e:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a20:	89 c2                	mov    %eax,%edx
  801a22:	f7 da                	neg    %edx
  801a24:	85 ff                	test   %edi,%edi
  801a26:	0f 45 c2             	cmovne %edx,%eax
}
  801a29:	5b                   	pop    %ebx
  801a2a:	5e                   	pop    %esi
  801a2b:	5f                   	pop    %edi
  801a2c:	5d                   	pop    %ebp
  801a2d:	c3                   	ret    

00801a2e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a2e:	f3 0f 1e fb          	endbr32 
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	56                   	push   %esi
  801a36:	53                   	push   %ebx
  801a37:	8b 75 08             	mov    0x8(%ebp),%esi
  801a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  801a40:	85 c0                	test   %eax,%eax
  801a42:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a47:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	50                   	push   %eax
  801a4e:	e8 82 e8 ff ff       	call   8002d5 <sys_ipc_recv>
	if (f < 0) {
  801a53:	83 c4 10             	add    $0x10,%esp
  801a56:	85 c0                	test   %eax,%eax
  801a58:	78 2b                	js     801a85 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801a5a:	85 f6                	test   %esi,%esi
  801a5c:	74 0a                	je     801a68 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801a5e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a63:	8b 40 74             	mov    0x74(%eax),%eax
  801a66:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801a68:	85 db                	test   %ebx,%ebx
  801a6a:	74 0a                	je     801a76 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801a6c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a71:	8b 40 78             	mov    0x78(%eax),%eax
  801a74:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  801a76:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a81:	5b                   	pop    %ebx
  801a82:	5e                   	pop    %esi
  801a83:	5d                   	pop    %ebp
  801a84:	c3                   	ret    
		if (from_env_store != NULL) {
  801a85:	85 f6                	test   %esi,%esi
  801a87:	74 06                	je     801a8f <ipc_recv+0x61>
			*from_env_store = 0;
  801a89:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801a8f:	85 db                	test   %ebx,%ebx
  801a91:	74 eb                	je     801a7e <ipc_recv+0x50>
			*perm_store = 0;
  801a93:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a99:	eb e3                	jmp    801a7e <ipc_recv+0x50>

00801a9b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a9b:	f3 0f 1e fb          	endbr32 
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	57                   	push   %edi
  801aa3:	56                   	push   %esi
  801aa4:	53                   	push   %ebx
  801aa5:	83 ec 0c             	sub    $0xc,%esp
  801aa8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aab:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  801ab1:	85 db                	test   %ebx,%ebx
  801ab3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ab8:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801abb:	ff 75 14             	pushl  0x14(%ebp)
  801abe:	53                   	push   %ebx
  801abf:	56                   	push   %esi
  801ac0:	57                   	push   %edi
  801ac1:	e8 e6 e7 ff ff       	call   8002ac <sys_ipc_try_send>
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	79 19                	jns    801ae6 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  801acd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ad0:	74 e9                	je     801abb <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  801ad2:	83 ec 04             	sub    $0x4,%esp
  801ad5:	68 20 22 80 00       	push   $0x802220
  801ada:	6a 48                	push   $0x48
  801adc:	68 42 22 80 00       	push   $0x802242
  801ae1:	e8 83 f5 ff ff       	call   801069 <_panic>
		}
	}
}
  801ae6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae9:	5b                   	pop    %ebx
  801aea:	5e                   	pop    %esi
  801aeb:	5f                   	pop    %edi
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    

00801aee <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aee:	f3 0f 1e fb          	endbr32 
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801af8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801afd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b00:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b06:	8b 52 50             	mov    0x50(%edx),%edx
  801b09:	39 ca                	cmp    %ecx,%edx
  801b0b:	74 11                	je     801b1e <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801b0d:	83 c0 01             	add    $0x1,%eax
  801b10:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b15:	75 e6                	jne    801afd <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b17:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1c:	eb 0b                	jmp    801b29 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b1e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b21:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b26:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    

00801b2b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b2b:	f3 0f 1e fb          	endbr32 
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b35:	89 c2                	mov    %eax,%edx
  801b37:	c1 ea 16             	shr    $0x16,%edx
  801b3a:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b41:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b46:	f6 c1 01             	test   $0x1,%cl
  801b49:	74 1c                	je     801b67 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b4b:	c1 e8 0c             	shr    $0xc,%eax
  801b4e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b55:	a8 01                	test   $0x1,%al
  801b57:	74 0e                	je     801b67 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b59:	c1 e8 0c             	shr    $0xc,%eax
  801b5c:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b63:	ef 
  801b64:	0f b7 d2             	movzwl %dx,%edx
}
  801b67:	89 d0                	mov    %edx,%eax
  801b69:	5d                   	pop    %ebp
  801b6a:	c3                   	ret    
  801b6b:	66 90                	xchg   %ax,%ax
  801b6d:	66 90                	xchg   %ax,%ax
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
