
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	f3 0f 1e fb          	endbr32 
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800049:	e8 19 01 00 00       	call   800167 <sys_getenvid>
	if (id >= 0)
  80004e:	85 c0                	test   %eax,%eax
  800050:	78 12                	js     800064 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x35>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	f3 0f 1e fb          	endbr32 
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800092:	e8 53 04 00 00       	call   8004ea <close_all>
	sys_env_destroy(0);
  800097:	83 ec 0c             	sub    $0xc,%esp
  80009a:	6a 00                	push   $0x0
  80009c:	e8 a0 00 00 00       	call   800141 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
  8000ac:	83 ec 1c             	sub    $0x1c,%esp
  8000af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000b5:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c0:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000c5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c9:	74 04                	je     8000cf <syscall+0x29>
  8000cb:	85 c0                	test   %eax,%eax
  8000cd:	7f 08                	jg     8000d7 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	50                   	push   %eax
  8000db:	ff 75 e0             	pushl  -0x20(%ebp)
  8000de:	68 ea 1d 80 00       	push   $0x801dea
  8000e3:	6a 23                	push   $0x23
  8000e5:	68 07 1e 80 00       	push   $0x801e07
  8000ea:	e8 76 0f 00 00       	call   801065 <_panic>

008000ef <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000ef:	f3 0f 1e fb          	endbr32 
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000f9:	6a 00                	push   $0x0
  8000fb:	6a 00                	push   $0x0
  8000fd:	6a 00                	push   $0x0
  8000ff:	ff 75 0c             	pushl  0xc(%ebp)
  800102:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800105:	ba 00 00 00 00       	mov    $0x0,%edx
  80010a:	b8 00 00 00 00       	mov    $0x0,%eax
  80010f:	e8 92 ff ff ff       	call   8000a6 <syscall>
}
  800114:	83 c4 10             	add    $0x10,%esp
  800117:	c9                   	leave  
  800118:	c3                   	ret    

00800119 <sys_cgetc>:

int
sys_cgetc(void)
{
  800119:	f3 0f 1e fb          	endbr32 
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800123:	6a 00                	push   $0x0
  800125:	6a 00                	push   $0x0
  800127:	6a 00                	push   $0x0
  800129:	6a 00                	push   $0x0
  80012b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 01 00 00 00       	mov    $0x1,%eax
  80013a:	e8 67 ff ff ff       	call   8000a6 <syscall>
}
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800141:	f3 0f 1e fb          	endbr32 
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80014b:	6a 00                	push   $0x0
  80014d:	6a 00                	push   $0x0
  80014f:	6a 00                	push   $0x0
  800151:	6a 00                	push   $0x0
  800153:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800156:	ba 01 00 00 00       	mov    $0x1,%edx
  80015b:	b8 03 00 00 00       	mov    $0x3,%eax
  800160:	e8 41 ff ff ff       	call   8000a6 <syscall>
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800167:	f3 0f 1e fb          	endbr32 
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800171:	6a 00                	push   $0x0
  800173:	6a 00                	push   $0x0
  800175:	6a 00                	push   $0x0
  800177:	6a 00                	push   $0x0
  800179:	b9 00 00 00 00       	mov    $0x0,%ecx
  80017e:	ba 00 00 00 00       	mov    $0x0,%edx
  800183:	b8 02 00 00 00       	mov    $0x2,%eax
  800188:	e8 19 ff ff ff       	call   8000a6 <syscall>
}
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    

0080018f <sys_yield>:

void
sys_yield(void)
{
  80018f:	f3 0f 1e fb          	endbr32 
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800199:	6a 00                	push   $0x0
  80019b:	6a 00                	push   $0x0
  80019d:	6a 00                	push   $0x0
  80019f:	6a 00                	push   $0x0
  8001a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ab:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001b0:	e8 f1 fe ff ff       	call   8000a6 <syscall>
}
  8001b5:	83 c4 10             	add    $0x10,%esp
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    

008001ba <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001ba:	f3 0f 1e fb          	endbr32 
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001c4:	6a 00                	push   $0x0
  8001c6:	6a 00                	push   $0x0
  8001c8:	ff 75 10             	pushl  0x10(%ebp)
  8001cb:	ff 75 0c             	pushl  0xc(%ebp)
  8001ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d1:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d6:	b8 04 00 00 00       	mov    $0x4,%eax
  8001db:	e8 c6 fe ff ff       	call   8000a6 <syscall>
}
  8001e0:	c9                   	leave  
  8001e1:	c3                   	ret    

008001e2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e2:	f3 0f 1e fb          	endbr32 
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001ec:	ff 75 18             	pushl  0x18(%ebp)
  8001ef:	ff 75 14             	pushl  0x14(%ebp)
  8001f2:	ff 75 10             	pushl  0x10(%ebp)
  8001f5:	ff 75 0c             	pushl  0xc(%ebp)
  8001f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001fb:	ba 01 00 00 00       	mov    $0x1,%edx
  800200:	b8 05 00 00 00       	mov    $0x5,%eax
  800205:	e8 9c fe ff ff       	call   8000a6 <syscall>
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020c:	f3 0f 1e fb          	endbr32 
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800216:	6a 00                	push   $0x0
  800218:	6a 00                	push   $0x0
  80021a:	6a 00                	push   $0x0
  80021c:	ff 75 0c             	pushl  0xc(%ebp)
  80021f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800222:	ba 01 00 00 00       	mov    $0x1,%edx
  800227:	b8 06 00 00 00       	mov    $0x6,%eax
  80022c:	e8 75 fe ff ff       	call   8000a6 <syscall>
}
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800233:	f3 0f 1e fb          	endbr32 
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80023d:	6a 00                	push   $0x0
  80023f:	6a 00                	push   $0x0
  800241:	6a 00                	push   $0x0
  800243:	ff 75 0c             	pushl  0xc(%ebp)
  800246:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800249:	ba 01 00 00 00       	mov    $0x1,%edx
  80024e:	b8 08 00 00 00       	mov    $0x8,%eax
  800253:	e8 4e fe ff ff       	call   8000a6 <syscall>
}
  800258:	c9                   	leave  
  800259:	c3                   	ret    

0080025a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025a:	f3 0f 1e fb          	endbr32 
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800264:	6a 00                	push   $0x0
  800266:	6a 00                	push   $0x0
  800268:	6a 00                	push   $0x0
  80026a:	ff 75 0c             	pushl  0xc(%ebp)
  80026d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800270:	ba 01 00 00 00       	mov    $0x1,%edx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	e8 27 fe ff ff       	call   8000a6 <syscall>
}
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800281:	f3 0f 1e fb          	endbr32 
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80028b:	6a 00                	push   $0x0
  80028d:	6a 00                	push   $0x0
  80028f:	6a 00                	push   $0x0
  800291:	ff 75 0c             	pushl  0xc(%ebp)
  800294:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800297:	ba 01 00 00 00       	mov    $0x1,%edx
  80029c:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002a1:	e8 00 fe ff ff       	call   8000a6 <syscall>
}
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a8:	f3 0f 1e fb          	endbr32 
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002b2:	6a 00                	push   $0x0
  8002b4:	ff 75 14             	pushl  0x14(%ebp)
  8002b7:	ff 75 10             	pushl  0x10(%ebp)
  8002ba:	ff 75 0c             	pushl  0xc(%ebp)
  8002bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ca:	e8 d7 fd ff ff       	call   8000a6 <syscall>
}
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d1:	f3 0f 1e fb          	endbr32 
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002db:	6a 00                	push   $0x0
  8002dd:	6a 00                	push   $0x0
  8002df:	6a 00                	push   $0x0
  8002e1:	6a 00                	push   $0x0
  8002e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e6:	ba 01 00 00 00       	mov    $0x1,%edx
  8002eb:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002f0:	e8 b1 fd ff ff       	call   8000a6 <syscall>
}
  8002f5:	c9                   	leave  
  8002f6:	c3                   	ret    

008002f7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002f7:	f3 0f 1e fb          	endbr32 
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	05 00 00 00 30       	add    $0x30000000,%eax
  800306:	c1 e8 0c             	shr    $0xc,%eax
}
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80030b:	f3 0f 1e fb          	endbr32 
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800315:	ff 75 08             	pushl  0x8(%ebp)
  800318:	e8 da ff ff ff       	call   8002f7 <fd2num>
  80031d:	83 c4 10             	add    $0x10,%esp
  800320:	c1 e0 0c             	shl    $0xc,%eax
  800323:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800328:	c9                   	leave  
  800329:	c3                   	ret    

0080032a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80032a:	f3 0f 1e fb          	endbr32 
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800336:	89 c2                	mov    %eax,%edx
  800338:	c1 ea 16             	shr    $0x16,%edx
  80033b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800342:	f6 c2 01             	test   $0x1,%dl
  800345:	74 2d                	je     800374 <fd_alloc+0x4a>
  800347:	89 c2                	mov    %eax,%edx
  800349:	c1 ea 0c             	shr    $0xc,%edx
  80034c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800353:	f6 c2 01             	test   $0x1,%dl
  800356:	74 1c                	je     800374 <fd_alloc+0x4a>
  800358:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80035d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800362:	75 d2                	jne    800336 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800364:	8b 45 08             	mov    0x8(%ebp),%eax
  800367:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80036d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800372:	eb 0a                	jmp    80037e <fd_alloc+0x54>
			*fd_store = fd;
  800374:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800377:	89 01                	mov    %eax,(%ecx)
			return 0;
  800379:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800380:	f3 0f 1e fb          	endbr32 
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80038a:	83 f8 1f             	cmp    $0x1f,%eax
  80038d:	77 30                	ja     8003bf <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80038f:	c1 e0 0c             	shl    $0xc,%eax
  800392:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800397:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80039d:	f6 c2 01             	test   $0x1,%dl
  8003a0:	74 24                	je     8003c6 <fd_lookup+0x46>
  8003a2:	89 c2                	mov    %eax,%edx
  8003a4:	c1 ea 0c             	shr    $0xc,%edx
  8003a7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ae:	f6 c2 01             	test   $0x1,%dl
  8003b1:	74 1a                	je     8003cd <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b6:	89 02                	mov    %eax,(%edx)
	return 0;
  8003b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    
		return -E_INVAL;
  8003bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003c4:	eb f7                	jmp    8003bd <fd_lookup+0x3d>
		return -E_INVAL;
  8003c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003cb:	eb f0                	jmp    8003bd <fd_lookup+0x3d>
  8003cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d2:	eb e9                	jmp    8003bd <fd_lookup+0x3d>

008003d4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003d4:	f3 0f 1e fb          	endbr32 
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	83 ec 08             	sub    $0x8,%esp
  8003de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e1:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8003e6:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003eb:	39 08                	cmp    %ecx,(%eax)
  8003ed:	74 33                	je     800422 <dev_lookup+0x4e>
  8003ef:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8003f2:	8b 02                	mov    (%edx),%eax
  8003f4:	85 c0                	test   %eax,%eax
  8003f6:	75 f3                	jne    8003eb <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8003f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8003fd:	8b 40 48             	mov    0x48(%eax),%eax
  800400:	83 ec 04             	sub    $0x4,%esp
  800403:	51                   	push   %ecx
  800404:	50                   	push   %eax
  800405:	68 18 1e 80 00       	push   $0x801e18
  80040a:	e8 3d 0d 00 00       	call   80114c <cprintf>
	*dev = 0;
  80040f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800412:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800418:	83 c4 10             	add    $0x10,%esp
  80041b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800420:	c9                   	leave  
  800421:	c3                   	ret    
			*dev = devtab[i];
  800422:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800425:	89 01                	mov    %eax,(%ecx)
			return 0;
  800427:	b8 00 00 00 00       	mov    $0x0,%eax
  80042c:	eb f2                	jmp    800420 <dev_lookup+0x4c>

0080042e <fd_close>:
{
  80042e:	f3 0f 1e fb          	endbr32 
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	57                   	push   %edi
  800436:	56                   	push   %esi
  800437:	53                   	push   %ebx
  800438:	83 ec 28             	sub    $0x28,%esp
  80043b:	8b 75 08             	mov    0x8(%ebp),%esi
  80043e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800441:	56                   	push   %esi
  800442:	e8 b0 fe ff ff       	call   8002f7 <fd2num>
  800447:	83 c4 08             	add    $0x8,%esp
  80044a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80044d:	52                   	push   %edx
  80044e:	50                   	push   %eax
  80044f:	e8 2c ff ff ff       	call   800380 <fd_lookup>
  800454:	89 c3                	mov    %eax,%ebx
  800456:	83 c4 10             	add    $0x10,%esp
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 05                	js     800462 <fd_close+0x34>
	    || fd != fd2)
  80045d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800460:	74 16                	je     800478 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800462:	89 f8                	mov    %edi,%eax
  800464:	84 c0                	test   %al,%al
  800466:	b8 00 00 00 00       	mov    $0x0,%eax
  80046b:	0f 44 d8             	cmove  %eax,%ebx
}
  80046e:	89 d8                	mov    %ebx,%eax
  800470:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800473:	5b                   	pop    %ebx
  800474:	5e                   	pop    %esi
  800475:	5f                   	pop    %edi
  800476:	5d                   	pop    %ebp
  800477:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80047e:	50                   	push   %eax
  80047f:	ff 36                	pushl  (%esi)
  800481:	e8 4e ff ff ff       	call   8003d4 <dev_lookup>
  800486:	89 c3                	mov    %eax,%ebx
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	85 c0                	test   %eax,%eax
  80048d:	78 1a                	js     8004a9 <fd_close+0x7b>
		if (dev->dev_close)
  80048f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800492:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800495:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80049a:	85 c0                	test   %eax,%eax
  80049c:	74 0b                	je     8004a9 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80049e:	83 ec 0c             	sub    $0xc,%esp
  8004a1:	56                   	push   %esi
  8004a2:	ff d0                	call   *%eax
  8004a4:	89 c3                	mov    %eax,%ebx
  8004a6:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	56                   	push   %esi
  8004ad:	6a 00                	push   $0x0
  8004af:	e8 58 fd ff ff       	call   80020c <sys_page_unmap>
	return r;
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	eb b5                	jmp    80046e <fd_close+0x40>

008004b9 <close>:

int
close(int fdnum)
{
  8004b9:	f3 0f 1e fb          	endbr32 
  8004bd:	55                   	push   %ebp
  8004be:	89 e5                	mov    %esp,%ebp
  8004c0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c6:	50                   	push   %eax
  8004c7:	ff 75 08             	pushl  0x8(%ebp)
  8004ca:	e8 b1 fe ff ff       	call   800380 <fd_lookup>
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	85 c0                	test   %eax,%eax
  8004d4:	79 02                	jns    8004d8 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004d6:	c9                   	leave  
  8004d7:	c3                   	ret    
		return fd_close(fd, 1);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	6a 01                	push   $0x1
  8004dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8004e0:	e8 49 ff ff ff       	call   80042e <fd_close>
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	eb ec                	jmp    8004d6 <close+0x1d>

008004ea <close_all>:

void
close_all(void)
{
  8004ea:	f3 0f 1e fb          	endbr32 
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	53                   	push   %ebx
  8004f2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8004f5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8004fa:	83 ec 0c             	sub    $0xc,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	e8 b6 ff ff ff       	call   8004b9 <close>
	for (i = 0; i < MAXFD; i++)
  800503:	83 c3 01             	add    $0x1,%ebx
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	83 fb 20             	cmp    $0x20,%ebx
  80050c:	75 ec                	jne    8004fa <close_all+0x10>
}
  80050e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800511:	c9                   	leave  
  800512:	c3                   	ret    

00800513 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800513:	f3 0f 1e fb          	endbr32 
  800517:	55                   	push   %ebp
  800518:	89 e5                	mov    %esp,%ebp
  80051a:	57                   	push   %edi
  80051b:	56                   	push   %esi
  80051c:	53                   	push   %ebx
  80051d:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800520:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800523:	50                   	push   %eax
  800524:	ff 75 08             	pushl  0x8(%ebp)
  800527:	e8 54 fe ff ff       	call   800380 <fd_lookup>
  80052c:	89 c3                	mov    %eax,%ebx
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	85 c0                	test   %eax,%eax
  800533:	0f 88 81 00 00 00    	js     8005ba <dup+0xa7>
		return r;
	close(newfdnum);
  800539:	83 ec 0c             	sub    $0xc,%esp
  80053c:	ff 75 0c             	pushl  0xc(%ebp)
  80053f:	e8 75 ff ff ff       	call   8004b9 <close>

	newfd = INDEX2FD(newfdnum);
  800544:	8b 75 0c             	mov    0xc(%ebp),%esi
  800547:	c1 e6 0c             	shl    $0xc,%esi
  80054a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800550:	83 c4 04             	add    $0x4,%esp
  800553:	ff 75 e4             	pushl  -0x1c(%ebp)
  800556:	e8 b0 fd ff ff       	call   80030b <fd2data>
  80055b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80055d:	89 34 24             	mov    %esi,(%esp)
  800560:	e8 a6 fd ff ff       	call   80030b <fd2data>
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80056a:	89 d8                	mov    %ebx,%eax
  80056c:	c1 e8 16             	shr    $0x16,%eax
  80056f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800576:	a8 01                	test   $0x1,%al
  800578:	74 11                	je     80058b <dup+0x78>
  80057a:	89 d8                	mov    %ebx,%eax
  80057c:	c1 e8 0c             	shr    $0xc,%eax
  80057f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800586:	f6 c2 01             	test   $0x1,%dl
  800589:	75 39                	jne    8005c4 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80058b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80058e:	89 d0                	mov    %edx,%eax
  800590:	c1 e8 0c             	shr    $0xc,%eax
  800593:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80059a:	83 ec 0c             	sub    $0xc,%esp
  80059d:	25 07 0e 00 00       	and    $0xe07,%eax
  8005a2:	50                   	push   %eax
  8005a3:	56                   	push   %esi
  8005a4:	6a 00                	push   $0x0
  8005a6:	52                   	push   %edx
  8005a7:	6a 00                	push   $0x0
  8005a9:	e8 34 fc ff ff       	call   8001e2 <sys_page_map>
  8005ae:	89 c3                	mov    %eax,%ebx
  8005b0:	83 c4 20             	add    $0x20,%esp
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	78 31                	js     8005e8 <dup+0xd5>
		goto err;

	return newfdnum;
  8005b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005ba:	89 d8                	mov    %ebx,%eax
  8005bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005bf:	5b                   	pop    %ebx
  8005c0:	5e                   	pop    %esi
  8005c1:	5f                   	pop    %edi
  8005c2:	5d                   	pop    %ebp
  8005c3:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005cb:	83 ec 0c             	sub    $0xc,%esp
  8005ce:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d3:	50                   	push   %eax
  8005d4:	57                   	push   %edi
  8005d5:	6a 00                	push   $0x0
  8005d7:	53                   	push   %ebx
  8005d8:	6a 00                	push   $0x0
  8005da:	e8 03 fc ff ff       	call   8001e2 <sys_page_map>
  8005df:	89 c3                	mov    %eax,%ebx
  8005e1:	83 c4 20             	add    $0x20,%esp
  8005e4:	85 c0                	test   %eax,%eax
  8005e6:	79 a3                	jns    80058b <dup+0x78>
	sys_page_unmap(0, newfd);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	56                   	push   %esi
  8005ec:	6a 00                	push   $0x0
  8005ee:	e8 19 fc ff ff       	call   80020c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005f3:	83 c4 08             	add    $0x8,%esp
  8005f6:	57                   	push   %edi
  8005f7:	6a 00                	push   $0x0
  8005f9:	e8 0e fc ff ff       	call   80020c <sys_page_unmap>
	return r;
  8005fe:	83 c4 10             	add    $0x10,%esp
  800601:	eb b7                	jmp    8005ba <dup+0xa7>

00800603 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800603:	f3 0f 1e fb          	endbr32 
  800607:	55                   	push   %ebp
  800608:	89 e5                	mov    %esp,%ebp
  80060a:	53                   	push   %ebx
  80060b:	83 ec 1c             	sub    $0x1c,%esp
  80060e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800611:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800614:	50                   	push   %eax
  800615:	53                   	push   %ebx
  800616:	e8 65 fd ff ff       	call   800380 <fd_lookup>
  80061b:	83 c4 10             	add    $0x10,%esp
  80061e:	85 c0                	test   %eax,%eax
  800620:	78 3f                	js     800661 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800628:	50                   	push   %eax
  800629:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80062c:	ff 30                	pushl  (%eax)
  80062e:	e8 a1 fd ff ff       	call   8003d4 <dev_lookup>
  800633:	83 c4 10             	add    $0x10,%esp
  800636:	85 c0                	test   %eax,%eax
  800638:	78 27                	js     800661 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80063a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80063d:	8b 42 08             	mov    0x8(%edx),%eax
  800640:	83 e0 03             	and    $0x3,%eax
  800643:	83 f8 01             	cmp    $0x1,%eax
  800646:	74 1e                	je     800666 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800648:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80064b:	8b 40 08             	mov    0x8(%eax),%eax
  80064e:	85 c0                	test   %eax,%eax
  800650:	74 35                	je     800687 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800652:	83 ec 04             	sub    $0x4,%esp
  800655:	ff 75 10             	pushl  0x10(%ebp)
  800658:	ff 75 0c             	pushl  0xc(%ebp)
  80065b:	52                   	push   %edx
  80065c:	ff d0                	call   *%eax
  80065e:	83 c4 10             	add    $0x10,%esp
}
  800661:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800664:	c9                   	leave  
  800665:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800666:	a1 04 40 80 00       	mov    0x804004,%eax
  80066b:	8b 40 48             	mov    0x48(%eax),%eax
  80066e:	83 ec 04             	sub    $0x4,%esp
  800671:	53                   	push   %ebx
  800672:	50                   	push   %eax
  800673:	68 59 1e 80 00       	push   $0x801e59
  800678:	e8 cf 0a 00 00       	call   80114c <cprintf>
		return -E_INVAL;
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800685:	eb da                	jmp    800661 <read+0x5e>
		return -E_NOT_SUPP;
  800687:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80068c:	eb d3                	jmp    800661 <read+0x5e>

0080068e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80068e:	f3 0f 1e fb          	endbr32 
  800692:	55                   	push   %ebp
  800693:	89 e5                	mov    %esp,%ebp
  800695:	57                   	push   %edi
  800696:	56                   	push   %esi
  800697:	53                   	push   %ebx
  800698:	83 ec 0c             	sub    $0xc,%esp
  80069b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80069e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006a6:	eb 02                	jmp    8006aa <readn+0x1c>
  8006a8:	01 c3                	add    %eax,%ebx
  8006aa:	39 f3                	cmp    %esi,%ebx
  8006ac:	73 21                	jae    8006cf <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ae:	83 ec 04             	sub    $0x4,%esp
  8006b1:	89 f0                	mov    %esi,%eax
  8006b3:	29 d8                	sub    %ebx,%eax
  8006b5:	50                   	push   %eax
  8006b6:	89 d8                	mov    %ebx,%eax
  8006b8:	03 45 0c             	add    0xc(%ebp),%eax
  8006bb:	50                   	push   %eax
  8006bc:	57                   	push   %edi
  8006bd:	e8 41 ff ff ff       	call   800603 <read>
		if (m < 0)
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	85 c0                	test   %eax,%eax
  8006c7:	78 04                	js     8006cd <readn+0x3f>
			return m;
		if (m == 0)
  8006c9:	75 dd                	jne    8006a8 <readn+0x1a>
  8006cb:	eb 02                	jmp    8006cf <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006cd:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006cf:	89 d8                	mov    %ebx,%eax
  8006d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d4:	5b                   	pop    %ebx
  8006d5:	5e                   	pop    %esi
  8006d6:	5f                   	pop    %edi
  8006d7:	5d                   	pop    %ebp
  8006d8:	c3                   	ret    

008006d9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006d9:	f3 0f 1e fb          	endbr32 
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	53                   	push   %ebx
  8006e1:	83 ec 1c             	sub    $0x1c,%esp
  8006e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006ea:	50                   	push   %eax
  8006eb:	53                   	push   %ebx
  8006ec:	e8 8f fc ff ff       	call   800380 <fd_lookup>
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	85 c0                	test   %eax,%eax
  8006f6:	78 3a                	js     800732 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f8:	83 ec 08             	sub    $0x8,%esp
  8006fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006fe:	50                   	push   %eax
  8006ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800702:	ff 30                	pushl  (%eax)
  800704:	e8 cb fc ff ff       	call   8003d4 <dev_lookup>
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	85 c0                	test   %eax,%eax
  80070e:	78 22                	js     800732 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800710:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800713:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800717:	74 1e                	je     800737 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800719:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80071c:	8b 52 0c             	mov    0xc(%edx),%edx
  80071f:	85 d2                	test   %edx,%edx
  800721:	74 35                	je     800758 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800723:	83 ec 04             	sub    $0x4,%esp
  800726:	ff 75 10             	pushl  0x10(%ebp)
  800729:	ff 75 0c             	pushl  0xc(%ebp)
  80072c:	50                   	push   %eax
  80072d:	ff d2                	call   *%edx
  80072f:	83 c4 10             	add    $0x10,%esp
}
  800732:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800735:	c9                   	leave  
  800736:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800737:	a1 04 40 80 00       	mov    0x804004,%eax
  80073c:	8b 40 48             	mov    0x48(%eax),%eax
  80073f:	83 ec 04             	sub    $0x4,%esp
  800742:	53                   	push   %ebx
  800743:	50                   	push   %eax
  800744:	68 75 1e 80 00       	push   $0x801e75
  800749:	e8 fe 09 00 00       	call   80114c <cprintf>
		return -E_INVAL;
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800756:	eb da                	jmp    800732 <write+0x59>
		return -E_NOT_SUPP;
  800758:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80075d:	eb d3                	jmp    800732 <write+0x59>

0080075f <seek>:

int
seek(int fdnum, off_t offset)
{
  80075f:	f3 0f 1e fb          	endbr32 
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800769:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076c:	50                   	push   %eax
  80076d:	ff 75 08             	pushl  0x8(%ebp)
  800770:	e8 0b fc ff ff       	call   800380 <fd_lookup>
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	85 c0                	test   %eax,%eax
  80077a:	78 0e                	js     80078a <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80077c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80077f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800782:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800785:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80078a:	c9                   	leave  
  80078b:	c3                   	ret    

0080078c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80078c:	f3 0f 1e fb          	endbr32 
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	53                   	push   %ebx
  800794:	83 ec 1c             	sub    $0x1c,%esp
  800797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80079a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80079d:	50                   	push   %eax
  80079e:	53                   	push   %ebx
  80079f:	e8 dc fb ff ff       	call   800380 <fd_lookup>
  8007a4:	83 c4 10             	add    $0x10,%esp
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	78 37                	js     8007e2 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ab:	83 ec 08             	sub    $0x8,%esp
  8007ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007b1:	50                   	push   %eax
  8007b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b5:	ff 30                	pushl  (%eax)
  8007b7:	e8 18 fc ff ff       	call   8003d4 <dev_lookup>
  8007bc:	83 c4 10             	add    $0x10,%esp
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	78 1f                	js     8007e2 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ca:	74 1b                	je     8007e7 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007cf:	8b 52 18             	mov    0x18(%edx),%edx
  8007d2:	85 d2                	test   %edx,%edx
  8007d4:	74 32                	je     800808 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007d6:	83 ec 08             	sub    $0x8,%esp
  8007d9:	ff 75 0c             	pushl  0xc(%ebp)
  8007dc:	50                   	push   %eax
  8007dd:	ff d2                	call   *%edx
  8007df:	83 c4 10             	add    $0x10,%esp
}
  8007e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e5:	c9                   	leave  
  8007e6:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007e7:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007ec:	8b 40 48             	mov    0x48(%eax),%eax
  8007ef:	83 ec 04             	sub    $0x4,%esp
  8007f2:	53                   	push   %ebx
  8007f3:	50                   	push   %eax
  8007f4:	68 38 1e 80 00       	push   $0x801e38
  8007f9:	e8 4e 09 00 00       	call   80114c <cprintf>
		return -E_INVAL;
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800806:	eb da                	jmp    8007e2 <ftruncate+0x56>
		return -E_NOT_SUPP;
  800808:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80080d:	eb d3                	jmp    8007e2 <ftruncate+0x56>

0080080f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80080f:	f3 0f 1e fb          	endbr32 
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	53                   	push   %ebx
  800817:	83 ec 1c             	sub    $0x1c,%esp
  80081a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80081d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800820:	50                   	push   %eax
  800821:	ff 75 08             	pushl  0x8(%ebp)
  800824:	e8 57 fb ff ff       	call   800380 <fd_lookup>
  800829:	83 c4 10             	add    $0x10,%esp
  80082c:	85 c0                	test   %eax,%eax
  80082e:	78 4b                	js     80087b <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800836:	50                   	push   %eax
  800837:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083a:	ff 30                	pushl  (%eax)
  80083c:	e8 93 fb ff ff       	call   8003d4 <dev_lookup>
  800841:	83 c4 10             	add    $0x10,%esp
  800844:	85 c0                	test   %eax,%eax
  800846:	78 33                	js     80087b <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800848:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80084f:	74 2f                	je     800880 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800851:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800854:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80085b:	00 00 00 
	stat->st_isdir = 0;
  80085e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800865:	00 00 00 
	stat->st_dev = dev;
  800868:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	53                   	push   %ebx
  800872:	ff 75 f0             	pushl  -0x10(%ebp)
  800875:	ff 50 14             	call   *0x14(%eax)
  800878:	83 c4 10             	add    $0x10,%esp
}
  80087b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087e:	c9                   	leave  
  80087f:	c3                   	ret    
		return -E_NOT_SUPP;
  800880:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800885:	eb f4                	jmp    80087b <fstat+0x6c>

00800887 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800887:	f3 0f 1e fb          	endbr32 
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800890:	83 ec 08             	sub    $0x8,%esp
  800893:	6a 00                	push   $0x0
  800895:	ff 75 08             	pushl  0x8(%ebp)
  800898:	e8 20 02 00 00       	call   800abd <open>
  80089d:	89 c3                	mov    %eax,%ebx
  80089f:	83 c4 10             	add    $0x10,%esp
  8008a2:	85 c0                	test   %eax,%eax
  8008a4:	78 1b                	js     8008c1 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008a6:	83 ec 08             	sub    $0x8,%esp
  8008a9:	ff 75 0c             	pushl  0xc(%ebp)
  8008ac:	50                   	push   %eax
  8008ad:	e8 5d ff ff ff       	call   80080f <fstat>
  8008b2:	89 c6                	mov    %eax,%esi
	close(fd);
  8008b4:	89 1c 24             	mov    %ebx,(%esp)
  8008b7:	e8 fd fb ff ff       	call   8004b9 <close>
	return r;
  8008bc:	83 c4 10             	add    $0x10,%esp
  8008bf:	89 f3                	mov    %esi,%ebx
}
  8008c1:	89 d8                	mov    %ebx,%eax
  8008c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	56                   	push   %esi
  8008ce:	53                   	push   %ebx
  8008cf:	89 c6                	mov    %eax,%esi
  8008d1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008d3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008da:	74 27                	je     800903 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008dc:	6a 07                	push   $0x7
  8008de:	68 00 50 80 00       	push   $0x805000
  8008e3:	56                   	push   %esi
  8008e4:	ff 35 00 40 80 00    	pushl  0x804000
  8008ea:	e8 a8 11 00 00       	call   801a97 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008ef:	83 c4 0c             	add    $0xc,%esp
  8008f2:	6a 00                	push   $0x0
  8008f4:	53                   	push   %ebx
  8008f5:	6a 00                	push   $0x0
  8008f7:	e8 2e 11 00 00       	call   801a2a <ipc_recv>
}
  8008fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800903:	83 ec 0c             	sub    $0xc,%esp
  800906:	6a 01                	push   $0x1
  800908:	e8 dd 11 00 00       	call   801aea <ipc_find_env>
  80090d:	a3 00 40 80 00       	mov    %eax,0x804000
  800912:	83 c4 10             	add    $0x10,%esp
  800915:	eb c5                	jmp    8008dc <fsipc+0x12>

00800917 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800917:	f3 0f 1e fb          	endbr32 
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8b 40 0c             	mov    0xc(%eax),%eax
  800927:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80092c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800934:	ba 00 00 00 00       	mov    $0x0,%edx
  800939:	b8 02 00 00 00       	mov    $0x2,%eax
  80093e:	e8 87 ff ff ff       	call   8008ca <fsipc>
}
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <devfile_flush>:
{
  800945:	f3 0f 1e fb          	endbr32 
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 40 0c             	mov    0xc(%eax),%eax
  800955:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80095a:	ba 00 00 00 00       	mov    $0x0,%edx
  80095f:	b8 06 00 00 00       	mov    $0x6,%eax
  800964:	e8 61 ff ff ff       	call   8008ca <fsipc>
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <devfile_stat>:
{
  80096b:	f3 0f 1e fb          	endbr32 
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	53                   	push   %ebx
  800973:	83 ec 04             	sub    $0x4,%esp
  800976:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 40 0c             	mov    0xc(%eax),%eax
  80097f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800984:	ba 00 00 00 00       	mov    $0x0,%edx
  800989:	b8 05 00 00 00       	mov    $0x5,%eax
  80098e:	e8 37 ff ff ff       	call   8008ca <fsipc>
  800993:	85 c0                	test   %eax,%eax
  800995:	78 2c                	js     8009c3 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800997:	83 ec 08             	sub    $0x8,%esp
  80099a:	68 00 50 80 00       	push   $0x805000
  80099f:	53                   	push   %ebx
  8009a0:	e8 11 0d 00 00       	call   8016b6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009a5:	a1 80 50 80 00       	mov    0x805080,%eax
  8009aa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b0:	a1 84 50 80 00       	mov    0x805084,%eax
  8009b5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009bb:	83 c4 10             	add    $0x10,%esp
  8009be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c6:	c9                   	leave  
  8009c7:	c3                   	ret    

008009c8 <devfile_write>:
{
  8009c8:	f3 0f 1e fb          	endbr32 
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	57                   	push   %edi
  8009d0:	56                   	push   %esi
  8009d1:	53                   	push   %ebx
  8009d2:	83 ec 0c             	sub    $0xc,%esp
  8009d5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e1:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8009eb:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  8009f0:	85 db                	test   %ebx,%ebx
  8009f2:	74 3b                	je     800a2f <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8009f4:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  8009fa:	89 f8                	mov    %edi,%eax
  8009fc:	0f 46 c3             	cmovbe %ebx,%eax
  8009ff:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  800a04:	83 ec 04             	sub    $0x4,%esp
  800a07:	50                   	push   %eax
  800a08:	56                   	push   %esi
  800a09:	68 08 50 80 00       	push   $0x805008
  800a0e:	e8 5b 0e 00 00       	call   80186e <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800a13:	ba 00 00 00 00       	mov    $0x0,%edx
  800a18:	b8 04 00 00 00       	mov    $0x4,%eax
  800a1d:	e8 a8 fe ff ff       	call   8008ca <fsipc>
  800a22:	83 c4 10             	add    $0x10,%esp
  800a25:	85 c0                	test   %eax,%eax
  800a27:	78 06                	js     800a2f <devfile_write+0x67>
		buf_aux += r;
  800a29:	01 c6                	add    %eax,%esi
		n -= r;
  800a2b:	29 c3                	sub    %eax,%ebx
  800a2d:	eb c1                	jmp    8009f0 <devfile_write+0x28>
}
  800a2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	5f                   	pop    %edi
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <devfile_read>:
{
  800a37:	f3 0f 1e fb          	endbr32 
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	8b 40 0c             	mov    0xc(%eax),%eax
  800a49:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a4e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a54:	ba 00 00 00 00       	mov    $0x0,%edx
  800a59:	b8 03 00 00 00       	mov    $0x3,%eax
  800a5e:	e8 67 fe ff ff       	call   8008ca <fsipc>
  800a63:	89 c3                	mov    %eax,%ebx
  800a65:	85 c0                	test   %eax,%eax
  800a67:	78 1f                	js     800a88 <devfile_read+0x51>
	assert(r <= n);
  800a69:	39 f0                	cmp    %esi,%eax
  800a6b:	77 24                	ja     800a91 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a6d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a72:	7f 33                	jg     800aa7 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a74:	83 ec 04             	sub    $0x4,%esp
  800a77:	50                   	push   %eax
  800a78:	68 00 50 80 00       	push   $0x805000
  800a7d:	ff 75 0c             	pushl  0xc(%ebp)
  800a80:	e8 e9 0d 00 00       	call   80186e <memmove>
	return r;
  800a85:	83 c4 10             	add    $0x10,%esp
}
  800a88:	89 d8                	mov    %ebx,%eax
  800a8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    
	assert(r <= n);
  800a91:	68 a4 1e 80 00       	push   $0x801ea4
  800a96:	68 ab 1e 80 00       	push   $0x801eab
  800a9b:	6a 7c                	push   $0x7c
  800a9d:	68 c0 1e 80 00       	push   $0x801ec0
  800aa2:	e8 be 05 00 00       	call   801065 <_panic>
	assert(r <= PGSIZE);
  800aa7:	68 cb 1e 80 00       	push   $0x801ecb
  800aac:	68 ab 1e 80 00       	push   $0x801eab
  800ab1:	6a 7d                	push   $0x7d
  800ab3:	68 c0 1e 80 00       	push   $0x801ec0
  800ab8:	e8 a8 05 00 00       	call   801065 <_panic>

00800abd <open>:
{
  800abd:	f3 0f 1e fb          	endbr32 
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
  800ac6:	83 ec 1c             	sub    $0x1c,%esp
  800ac9:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800acc:	56                   	push   %esi
  800acd:	e8 a1 0b 00 00       	call   801673 <strlen>
  800ad2:	83 c4 10             	add    $0x10,%esp
  800ad5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ada:	7f 6c                	jg     800b48 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae2:	50                   	push   %eax
  800ae3:	e8 42 f8 ff ff       	call   80032a <fd_alloc>
  800ae8:	89 c3                	mov    %eax,%ebx
  800aea:	83 c4 10             	add    $0x10,%esp
  800aed:	85 c0                	test   %eax,%eax
  800aef:	78 3c                	js     800b2d <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800af1:	83 ec 08             	sub    $0x8,%esp
  800af4:	56                   	push   %esi
  800af5:	68 00 50 80 00       	push   $0x805000
  800afa:	e8 b7 0b 00 00       	call   8016b6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b02:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b07:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b0a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0f:	e8 b6 fd ff ff       	call   8008ca <fsipc>
  800b14:	89 c3                	mov    %eax,%ebx
  800b16:	83 c4 10             	add    $0x10,%esp
  800b19:	85 c0                	test   %eax,%eax
  800b1b:	78 19                	js     800b36 <open+0x79>
	return fd2num(fd);
  800b1d:	83 ec 0c             	sub    $0xc,%esp
  800b20:	ff 75 f4             	pushl  -0xc(%ebp)
  800b23:	e8 cf f7 ff ff       	call   8002f7 <fd2num>
  800b28:	89 c3                	mov    %eax,%ebx
  800b2a:	83 c4 10             	add    $0x10,%esp
}
  800b2d:	89 d8                	mov    %ebx,%eax
  800b2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    
		fd_close(fd, 0);
  800b36:	83 ec 08             	sub    $0x8,%esp
  800b39:	6a 00                	push   $0x0
  800b3b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b3e:	e8 eb f8 ff ff       	call   80042e <fd_close>
		return r;
  800b43:	83 c4 10             	add    $0x10,%esp
  800b46:	eb e5                	jmp    800b2d <open+0x70>
		return -E_BAD_PATH;
  800b48:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b4d:	eb de                	jmp    800b2d <open+0x70>

00800b4f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b4f:	f3 0f 1e fb          	endbr32 
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b59:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b63:	e8 62 fd ff ff       	call   8008ca <fsipc>
}
  800b68:	c9                   	leave  
  800b69:	c3                   	ret    

00800b6a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b6a:	f3 0f 1e fb          	endbr32 
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b76:	83 ec 0c             	sub    $0xc,%esp
  800b79:	ff 75 08             	pushl  0x8(%ebp)
  800b7c:	e8 8a f7 ff ff       	call   80030b <fd2data>
  800b81:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b83:	83 c4 08             	add    $0x8,%esp
  800b86:	68 d7 1e 80 00       	push   $0x801ed7
  800b8b:	53                   	push   %ebx
  800b8c:	e8 25 0b 00 00       	call   8016b6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b91:	8b 46 04             	mov    0x4(%esi),%eax
  800b94:	2b 06                	sub    (%esi),%eax
  800b96:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b9c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ba3:	00 00 00 
	stat->st_dev = &devpipe;
  800ba6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bad:	30 80 00 
	return 0;
}
  800bb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bbc:	f3 0f 1e fb          	endbr32 
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	53                   	push   %ebx
  800bc4:	83 ec 0c             	sub    $0xc,%esp
  800bc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bca:	53                   	push   %ebx
  800bcb:	6a 00                	push   $0x0
  800bcd:	e8 3a f6 ff ff       	call   80020c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bd2:	89 1c 24             	mov    %ebx,(%esp)
  800bd5:	e8 31 f7 ff ff       	call   80030b <fd2data>
  800bda:	83 c4 08             	add    $0x8,%esp
  800bdd:	50                   	push   %eax
  800bde:	6a 00                	push   $0x0
  800be0:	e8 27 f6 ff ff       	call   80020c <sys_page_unmap>
}
  800be5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be8:	c9                   	leave  
  800be9:	c3                   	ret    

00800bea <_pipeisclosed>:
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	83 ec 1c             	sub    $0x1c,%esp
  800bf3:	89 c7                	mov    %eax,%edi
  800bf5:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bf7:	a1 04 40 80 00       	mov    0x804004,%eax
  800bfc:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	57                   	push   %edi
  800c03:	e8 1f 0f 00 00       	call   801b27 <pageref>
  800c08:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c0b:	89 34 24             	mov    %esi,(%esp)
  800c0e:	e8 14 0f 00 00       	call   801b27 <pageref>
		nn = thisenv->env_runs;
  800c13:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c19:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c1c:	83 c4 10             	add    $0x10,%esp
  800c1f:	39 cb                	cmp    %ecx,%ebx
  800c21:	74 1b                	je     800c3e <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c23:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c26:	75 cf                	jne    800bf7 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c28:	8b 42 58             	mov    0x58(%edx),%eax
  800c2b:	6a 01                	push   $0x1
  800c2d:	50                   	push   %eax
  800c2e:	53                   	push   %ebx
  800c2f:	68 de 1e 80 00       	push   $0x801ede
  800c34:	e8 13 05 00 00       	call   80114c <cprintf>
  800c39:	83 c4 10             	add    $0x10,%esp
  800c3c:	eb b9                	jmp    800bf7 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c3e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c41:	0f 94 c0             	sete   %al
  800c44:	0f b6 c0             	movzbl %al,%eax
}
  800c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <devpipe_write>:
{
  800c4f:	f3 0f 1e fb          	endbr32 
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 28             	sub    $0x28,%esp
  800c5c:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c5f:	56                   	push   %esi
  800c60:	e8 a6 f6 ff ff       	call   80030b <fd2data>
  800c65:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c67:	83 c4 10             	add    $0x10,%esp
  800c6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c72:	74 4f                	je     800cc3 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c74:	8b 43 04             	mov    0x4(%ebx),%eax
  800c77:	8b 0b                	mov    (%ebx),%ecx
  800c79:	8d 51 20             	lea    0x20(%ecx),%edx
  800c7c:	39 d0                	cmp    %edx,%eax
  800c7e:	72 14                	jb     800c94 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800c80:	89 da                	mov    %ebx,%edx
  800c82:	89 f0                	mov    %esi,%eax
  800c84:	e8 61 ff ff ff       	call   800bea <_pipeisclosed>
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	75 3b                	jne    800cc8 <devpipe_write+0x79>
			sys_yield();
  800c8d:	e8 fd f4 ff ff       	call   80018f <sys_yield>
  800c92:	eb e0                	jmp    800c74 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c9b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c9e:	89 c2                	mov    %eax,%edx
  800ca0:	c1 fa 1f             	sar    $0x1f,%edx
  800ca3:	89 d1                	mov    %edx,%ecx
  800ca5:	c1 e9 1b             	shr    $0x1b,%ecx
  800ca8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cab:	83 e2 1f             	and    $0x1f,%edx
  800cae:	29 ca                	sub    %ecx,%edx
  800cb0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cb4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cb8:	83 c0 01             	add    $0x1,%eax
  800cbb:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cbe:	83 c7 01             	add    $0x1,%edi
  800cc1:	eb ac                	jmp    800c6f <devpipe_write+0x20>
	return i;
  800cc3:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc6:	eb 05                	jmp    800ccd <devpipe_write+0x7e>
				return 0;
  800cc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ccd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <devpipe_read>:
{
  800cd5:	f3 0f 1e fb          	endbr32 
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 18             	sub    $0x18,%esp
  800ce2:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800ce5:	57                   	push   %edi
  800ce6:	e8 20 f6 ff ff       	call   80030b <fd2data>
  800ceb:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800ced:	83 c4 10             	add    $0x10,%esp
  800cf0:	be 00 00 00 00       	mov    $0x0,%esi
  800cf5:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cf8:	75 14                	jne    800d0e <devpipe_read+0x39>
	return i;
  800cfa:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfd:	eb 02                	jmp    800d01 <devpipe_read+0x2c>
				return i;
  800cff:	89 f0                	mov    %esi,%eax
}
  800d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    
			sys_yield();
  800d09:	e8 81 f4 ff ff       	call   80018f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d0e:	8b 03                	mov    (%ebx),%eax
  800d10:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d13:	75 18                	jne    800d2d <devpipe_read+0x58>
			if (i > 0)
  800d15:	85 f6                	test   %esi,%esi
  800d17:	75 e6                	jne    800cff <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d19:	89 da                	mov    %ebx,%edx
  800d1b:	89 f8                	mov    %edi,%eax
  800d1d:	e8 c8 fe ff ff       	call   800bea <_pipeisclosed>
  800d22:	85 c0                	test   %eax,%eax
  800d24:	74 e3                	je     800d09 <devpipe_read+0x34>
				return 0;
  800d26:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2b:	eb d4                	jmp    800d01 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d2d:	99                   	cltd   
  800d2e:	c1 ea 1b             	shr    $0x1b,%edx
  800d31:	01 d0                	add    %edx,%eax
  800d33:	83 e0 1f             	and    $0x1f,%eax
  800d36:	29 d0                	sub    %edx,%eax
  800d38:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d43:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d46:	83 c6 01             	add    $0x1,%esi
  800d49:	eb aa                	jmp    800cf5 <devpipe_read+0x20>

00800d4b <pipe>:
{
  800d4b:	f3 0f 1e fb          	endbr32 
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d5a:	50                   	push   %eax
  800d5b:	e8 ca f5 ff ff       	call   80032a <fd_alloc>
  800d60:	89 c3                	mov    %eax,%ebx
  800d62:	83 c4 10             	add    $0x10,%esp
  800d65:	85 c0                	test   %eax,%eax
  800d67:	0f 88 23 01 00 00    	js     800e90 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d6d:	83 ec 04             	sub    $0x4,%esp
  800d70:	68 07 04 00 00       	push   $0x407
  800d75:	ff 75 f4             	pushl  -0xc(%ebp)
  800d78:	6a 00                	push   $0x0
  800d7a:	e8 3b f4 ff ff       	call   8001ba <sys_page_alloc>
  800d7f:	89 c3                	mov    %eax,%ebx
  800d81:	83 c4 10             	add    $0x10,%esp
  800d84:	85 c0                	test   %eax,%eax
  800d86:	0f 88 04 01 00 00    	js     800e90 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800d8c:	83 ec 0c             	sub    $0xc,%esp
  800d8f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d92:	50                   	push   %eax
  800d93:	e8 92 f5 ff ff       	call   80032a <fd_alloc>
  800d98:	89 c3                	mov    %eax,%ebx
  800d9a:	83 c4 10             	add    $0x10,%esp
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	0f 88 db 00 00 00    	js     800e80 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da5:	83 ec 04             	sub    $0x4,%esp
  800da8:	68 07 04 00 00       	push   $0x407
  800dad:	ff 75 f0             	pushl  -0x10(%ebp)
  800db0:	6a 00                	push   $0x0
  800db2:	e8 03 f4 ff ff       	call   8001ba <sys_page_alloc>
  800db7:	89 c3                	mov    %eax,%ebx
  800db9:	83 c4 10             	add    $0x10,%esp
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	0f 88 bc 00 00 00    	js     800e80 <pipe+0x135>
	va = fd2data(fd0);
  800dc4:	83 ec 0c             	sub    $0xc,%esp
  800dc7:	ff 75 f4             	pushl  -0xc(%ebp)
  800dca:	e8 3c f5 ff ff       	call   80030b <fd2data>
  800dcf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd1:	83 c4 0c             	add    $0xc,%esp
  800dd4:	68 07 04 00 00       	push   $0x407
  800dd9:	50                   	push   %eax
  800dda:	6a 00                	push   $0x0
  800ddc:	e8 d9 f3 ff ff       	call   8001ba <sys_page_alloc>
  800de1:	89 c3                	mov    %eax,%ebx
  800de3:	83 c4 10             	add    $0x10,%esp
  800de6:	85 c0                	test   %eax,%eax
  800de8:	0f 88 82 00 00 00    	js     800e70 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dee:	83 ec 0c             	sub    $0xc,%esp
  800df1:	ff 75 f0             	pushl  -0x10(%ebp)
  800df4:	e8 12 f5 ff ff       	call   80030b <fd2data>
  800df9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e00:	50                   	push   %eax
  800e01:	6a 00                	push   $0x0
  800e03:	56                   	push   %esi
  800e04:	6a 00                	push   $0x0
  800e06:	e8 d7 f3 ff ff       	call   8001e2 <sys_page_map>
  800e0b:	89 c3                	mov    %eax,%ebx
  800e0d:	83 c4 20             	add    $0x20,%esp
  800e10:	85 c0                	test   %eax,%eax
  800e12:	78 4e                	js     800e62 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e14:	a1 20 30 80 00       	mov    0x803020,%eax
  800e19:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e1c:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e21:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e28:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e2b:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e30:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3d:	e8 b5 f4 ff ff       	call   8002f7 <fd2num>
  800e42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e45:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e47:	83 c4 04             	add    $0x4,%esp
  800e4a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e4d:	e8 a5 f4 ff ff       	call   8002f7 <fd2num>
  800e52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e55:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e58:	83 c4 10             	add    $0x10,%esp
  800e5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e60:	eb 2e                	jmp    800e90 <pipe+0x145>
	sys_page_unmap(0, va);
  800e62:	83 ec 08             	sub    $0x8,%esp
  800e65:	56                   	push   %esi
  800e66:	6a 00                	push   $0x0
  800e68:	e8 9f f3 ff ff       	call   80020c <sys_page_unmap>
  800e6d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e70:	83 ec 08             	sub    $0x8,%esp
  800e73:	ff 75 f0             	pushl  -0x10(%ebp)
  800e76:	6a 00                	push   $0x0
  800e78:	e8 8f f3 ff ff       	call   80020c <sys_page_unmap>
  800e7d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e80:	83 ec 08             	sub    $0x8,%esp
  800e83:	ff 75 f4             	pushl  -0xc(%ebp)
  800e86:	6a 00                	push   $0x0
  800e88:	e8 7f f3 ff ff       	call   80020c <sys_page_unmap>
  800e8d:	83 c4 10             	add    $0x10,%esp
}
  800e90:	89 d8                	mov    %ebx,%eax
  800e92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <pipeisclosed>:
{
  800e99:	f3 0f 1e fb          	endbr32 
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ea3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea6:	50                   	push   %eax
  800ea7:	ff 75 08             	pushl  0x8(%ebp)
  800eaa:	e8 d1 f4 ff ff       	call   800380 <fd_lookup>
  800eaf:	83 c4 10             	add    $0x10,%esp
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	78 18                	js     800ece <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800eb6:	83 ec 0c             	sub    $0xc,%esp
  800eb9:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebc:	e8 4a f4 ff ff       	call   80030b <fd2data>
  800ec1:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ec6:	e8 1f fd ff ff       	call   800bea <_pipeisclosed>
  800ecb:	83 c4 10             	add    $0x10,%esp
}
  800ece:	c9                   	leave  
  800ecf:	c3                   	ret    

00800ed0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ed0:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800ed4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed9:	c3                   	ret    

00800eda <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eda:	f3 0f 1e fb          	endbr32 
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ee4:	68 f6 1e 80 00       	push   $0x801ef6
  800ee9:	ff 75 0c             	pushl  0xc(%ebp)
  800eec:	e8 c5 07 00 00       	call   8016b6 <strcpy>
	return 0;
}
  800ef1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef6:	c9                   	leave  
  800ef7:	c3                   	ret    

00800ef8 <devcons_write>:
{
  800ef8:	f3 0f 1e fb          	endbr32 
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	57                   	push   %edi
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
  800f02:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f08:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f0d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f13:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f16:	73 31                	jae    800f49 <devcons_write+0x51>
		m = n - tot;
  800f18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1b:	29 f3                	sub    %esi,%ebx
  800f1d:	83 fb 7f             	cmp    $0x7f,%ebx
  800f20:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f25:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f28:	83 ec 04             	sub    $0x4,%esp
  800f2b:	53                   	push   %ebx
  800f2c:	89 f0                	mov    %esi,%eax
  800f2e:	03 45 0c             	add    0xc(%ebp),%eax
  800f31:	50                   	push   %eax
  800f32:	57                   	push   %edi
  800f33:	e8 36 09 00 00       	call   80186e <memmove>
		sys_cputs(buf, m);
  800f38:	83 c4 08             	add    $0x8,%esp
  800f3b:	53                   	push   %ebx
  800f3c:	57                   	push   %edi
  800f3d:	e8 ad f1 ff ff       	call   8000ef <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f42:	01 de                	add    %ebx,%esi
  800f44:	83 c4 10             	add    $0x10,%esp
  800f47:	eb ca                	jmp    800f13 <devcons_write+0x1b>
}
  800f49:	89 f0                	mov    %esi,%eax
  800f4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4e:	5b                   	pop    %ebx
  800f4f:	5e                   	pop    %esi
  800f50:	5f                   	pop    %edi
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    

00800f53 <devcons_read>:
{
  800f53:	f3 0f 1e fb          	endbr32 
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	83 ec 08             	sub    $0x8,%esp
  800f5d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f66:	74 21                	je     800f89 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800f68:	e8 ac f1 ff ff       	call   800119 <sys_cgetc>
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	75 07                	jne    800f78 <devcons_read+0x25>
		sys_yield();
  800f71:	e8 19 f2 ff ff       	call   80018f <sys_yield>
  800f76:	eb f0                	jmp    800f68 <devcons_read+0x15>
	if (c < 0)
  800f78:	78 0f                	js     800f89 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800f7a:	83 f8 04             	cmp    $0x4,%eax
  800f7d:	74 0c                	je     800f8b <devcons_read+0x38>
	*(char*)vbuf = c;
  800f7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f82:	88 02                	mov    %al,(%edx)
	return 1;
  800f84:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f89:	c9                   	leave  
  800f8a:	c3                   	ret    
		return 0;
  800f8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f90:	eb f7                	jmp    800f89 <devcons_read+0x36>

00800f92 <cputchar>:
{
  800f92:	f3 0f 1e fb          	endbr32 
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800fa2:	6a 01                	push   $0x1
  800fa4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa7:	50                   	push   %eax
  800fa8:	e8 42 f1 ff ff       	call   8000ef <sys_cputs>
}
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	c9                   	leave  
  800fb1:	c3                   	ret    

00800fb2 <getchar>:
{
  800fb2:	f3 0f 1e fb          	endbr32 
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800fbc:	6a 01                	push   $0x1
  800fbe:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc1:	50                   	push   %eax
  800fc2:	6a 00                	push   $0x0
  800fc4:	e8 3a f6 ff ff       	call   800603 <read>
	if (r < 0)
  800fc9:	83 c4 10             	add    $0x10,%esp
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	78 06                	js     800fd6 <getchar+0x24>
	if (r < 1)
  800fd0:	74 06                	je     800fd8 <getchar+0x26>
	return c;
  800fd2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fd6:	c9                   	leave  
  800fd7:	c3                   	ret    
		return -E_EOF;
  800fd8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fdd:	eb f7                	jmp    800fd6 <getchar+0x24>

00800fdf <iscons>:
{
  800fdf:	f3 0f 1e fb          	endbr32 
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fec:	50                   	push   %eax
  800fed:	ff 75 08             	pushl  0x8(%ebp)
  800ff0:	e8 8b f3 ff ff       	call   800380 <fd_lookup>
  800ff5:	83 c4 10             	add    $0x10,%esp
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	78 11                	js     80100d <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  800ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fff:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801005:	39 10                	cmp    %edx,(%eax)
  801007:	0f 94 c0             	sete   %al
  80100a:	0f b6 c0             	movzbl %al,%eax
}
  80100d:	c9                   	leave  
  80100e:	c3                   	ret    

0080100f <opencons>:
{
  80100f:	f3 0f 1e fb          	endbr32 
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801019:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80101c:	50                   	push   %eax
  80101d:	e8 08 f3 ff ff       	call   80032a <fd_alloc>
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	85 c0                	test   %eax,%eax
  801027:	78 3a                	js     801063 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801029:	83 ec 04             	sub    $0x4,%esp
  80102c:	68 07 04 00 00       	push   $0x407
  801031:	ff 75 f4             	pushl  -0xc(%ebp)
  801034:	6a 00                	push   $0x0
  801036:	e8 7f f1 ff ff       	call   8001ba <sys_page_alloc>
  80103b:	83 c4 10             	add    $0x10,%esp
  80103e:	85 c0                	test   %eax,%eax
  801040:	78 21                	js     801063 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801042:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801045:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80104b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80104d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801050:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801057:	83 ec 0c             	sub    $0xc,%esp
  80105a:	50                   	push   %eax
  80105b:	e8 97 f2 ff ff       	call   8002f7 <fd2num>
  801060:	83 c4 10             	add    $0x10,%esp
}
  801063:	c9                   	leave  
  801064:	c3                   	ret    

00801065 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801065:	f3 0f 1e fb          	endbr32 
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	56                   	push   %esi
  80106d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80106e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801071:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801077:	e8 eb f0 ff ff       	call   800167 <sys_getenvid>
  80107c:	83 ec 0c             	sub    $0xc,%esp
  80107f:	ff 75 0c             	pushl  0xc(%ebp)
  801082:	ff 75 08             	pushl  0x8(%ebp)
  801085:	56                   	push   %esi
  801086:	50                   	push   %eax
  801087:	68 04 1f 80 00       	push   $0x801f04
  80108c:	e8 bb 00 00 00       	call   80114c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801091:	83 c4 18             	add    $0x18,%esp
  801094:	53                   	push   %ebx
  801095:	ff 75 10             	pushl  0x10(%ebp)
  801098:	e8 5a 00 00 00       	call   8010f7 <vcprintf>
	cprintf("\n");
  80109d:	c7 04 24 ef 1e 80 00 	movl   $0x801eef,(%esp)
  8010a4:	e8 a3 00 00 00       	call   80114c <cprintf>
  8010a9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010ac:	cc                   	int3   
  8010ad:	eb fd                	jmp    8010ac <_panic+0x47>

008010af <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010af:	f3 0f 1e fb          	endbr32 
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	53                   	push   %ebx
  8010b7:	83 ec 04             	sub    $0x4,%esp
  8010ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010bd:	8b 13                	mov    (%ebx),%edx
  8010bf:	8d 42 01             	lea    0x1(%edx),%eax
  8010c2:	89 03                	mov    %eax,(%ebx)
  8010c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010cb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010d0:	74 09                	je     8010db <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010d2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010db:	83 ec 08             	sub    $0x8,%esp
  8010de:	68 ff 00 00 00       	push   $0xff
  8010e3:	8d 43 08             	lea    0x8(%ebx),%eax
  8010e6:	50                   	push   %eax
  8010e7:	e8 03 f0 ff ff       	call   8000ef <sys_cputs>
		b->idx = 0;
  8010ec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010f2:	83 c4 10             	add    $0x10,%esp
  8010f5:	eb db                	jmp    8010d2 <putch+0x23>

008010f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010f7:	f3 0f 1e fb          	endbr32 
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801104:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80110b:	00 00 00 
	b.cnt = 0;
  80110e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801115:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801118:	ff 75 0c             	pushl  0xc(%ebp)
  80111b:	ff 75 08             	pushl  0x8(%ebp)
  80111e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801124:	50                   	push   %eax
  801125:	68 af 10 80 00       	push   $0x8010af
  80112a:	e8 80 01 00 00       	call   8012af <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80112f:	83 c4 08             	add    $0x8,%esp
  801132:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801138:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80113e:	50                   	push   %eax
  80113f:	e8 ab ef ff ff       	call   8000ef <sys_cputs>

	return b.cnt;
}
  801144:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80114a:	c9                   	leave  
  80114b:	c3                   	ret    

0080114c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80114c:	f3 0f 1e fb          	endbr32 
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801156:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801159:	50                   	push   %eax
  80115a:	ff 75 08             	pushl  0x8(%ebp)
  80115d:	e8 95 ff ff ff       	call   8010f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  801162:	c9                   	leave  
  801163:	c3                   	ret    

00801164 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	57                   	push   %edi
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
  80116a:	83 ec 1c             	sub    $0x1c,%esp
  80116d:	89 c7                	mov    %eax,%edi
  80116f:	89 d6                	mov    %edx,%esi
  801171:	8b 45 08             	mov    0x8(%ebp),%eax
  801174:	8b 55 0c             	mov    0xc(%ebp),%edx
  801177:	89 d1                	mov    %edx,%ecx
  801179:	89 c2                	mov    %eax,%edx
  80117b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80117e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801181:	8b 45 10             	mov    0x10(%ebp),%eax
  801184:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801187:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80118a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801191:	39 c2                	cmp    %eax,%edx
  801193:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801196:	72 3e                	jb     8011d6 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801198:	83 ec 0c             	sub    $0xc,%esp
  80119b:	ff 75 18             	pushl  0x18(%ebp)
  80119e:	83 eb 01             	sub    $0x1,%ebx
  8011a1:	53                   	push   %ebx
  8011a2:	50                   	push   %eax
  8011a3:	83 ec 08             	sub    $0x8,%esp
  8011a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ac:	ff 75 dc             	pushl  -0x24(%ebp)
  8011af:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b2:	e8 b9 09 00 00       	call   801b70 <__udivdi3>
  8011b7:	83 c4 18             	add    $0x18,%esp
  8011ba:	52                   	push   %edx
  8011bb:	50                   	push   %eax
  8011bc:	89 f2                	mov    %esi,%edx
  8011be:	89 f8                	mov    %edi,%eax
  8011c0:	e8 9f ff ff ff       	call   801164 <printnum>
  8011c5:	83 c4 20             	add    $0x20,%esp
  8011c8:	eb 13                	jmp    8011dd <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011ca:	83 ec 08             	sub    $0x8,%esp
  8011cd:	56                   	push   %esi
  8011ce:	ff 75 18             	pushl  0x18(%ebp)
  8011d1:	ff d7                	call   *%edi
  8011d3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011d6:	83 eb 01             	sub    $0x1,%ebx
  8011d9:	85 db                	test   %ebx,%ebx
  8011db:	7f ed                	jg     8011ca <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011dd:	83 ec 08             	sub    $0x8,%esp
  8011e0:	56                   	push   %esi
  8011e1:	83 ec 04             	sub    $0x4,%esp
  8011e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f0:	e8 8b 0a 00 00       	call   801c80 <__umoddi3>
  8011f5:	83 c4 14             	add    $0x14,%esp
  8011f8:	0f be 80 27 1f 80 00 	movsbl 0x801f27(%eax),%eax
  8011ff:	50                   	push   %eax
  801200:	ff d7                	call   *%edi
}
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801208:	5b                   	pop    %ebx
  801209:	5e                   	pop    %esi
  80120a:	5f                   	pop    %edi
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80120d:	83 fa 01             	cmp    $0x1,%edx
  801210:	7f 13                	jg     801225 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801212:	85 d2                	test   %edx,%edx
  801214:	74 1c                	je     801232 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  801216:	8b 10                	mov    (%eax),%edx
  801218:	8d 4a 04             	lea    0x4(%edx),%ecx
  80121b:	89 08                	mov    %ecx,(%eax)
  80121d:	8b 02                	mov    (%edx),%eax
  80121f:	ba 00 00 00 00       	mov    $0x0,%edx
  801224:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  801225:	8b 10                	mov    (%eax),%edx
  801227:	8d 4a 08             	lea    0x8(%edx),%ecx
  80122a:	89 08                	mov    %ecx,(%eax)
  80122c:	8b 02                	mov    (%edx),%eax
  80122e:	8b 52 04             	mov    0x4(%edx),%edx
  801231:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  801232:	8b 10                	mov    (%eax),%edx
  801234:	8d 4a 04             	lea    0x4(%edx),%ecx
  801237:	89 08                	mov    %ecx,(%eax)
  801239:	8b 02                	mov    (%edx),%eax
  80123b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801240:	c3                   	ret    

00801241 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801241:	83 fa 01             	cmp    $0x1,%edx
  801244:	7f 0f                	jg     801255 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  801246:	85 d2                	test   %edx,%edx
  801248:	74 18                	je     801262 <getint+0x21>
		return va_arg(*ap, long);
  80124a:	8b 10                	mov    (%eax),%edx
  80124c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80124f:	89 08                	mov    %ecx,(%eax)
  801251:	8b 02                	mov    (%edx),%eax
  801253:	99                   	cltd   
  801254:	c3                   	ret    
		return va_arg(*ap, long long);
  801255:	8b 10                	mov    (%eax),%edx
  801257:	8d 4a 08             	lea    0x8(%edx),%ecx
  80125a:	89 08                	mov    %ecx,(%eax)
  80125c:	8b 02                	mov    (%edx),%eax
  80125e:	8b 52 04             	mov    0x4(%edx),%edx
  801261:	c3                   	ret    
	else
		return va_arg(*ap, int);
  801262:	8b 10                	mov    (%eax),%edx
  801264:	8d 4a 04             	lea    0x4(%edx),%ecx
  801267:	89 08                	mov    %ecx,(%eax)
  801269:	8b 02                	mov    (%edx),%eax
  80126b:	99                   	cltd   
}
  80126c:	c3                   	ret    

0080126d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80126d:	f3 0f 1e fb          	endbr32 
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801277:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80127b:	8b 10                	mov    (%eax),%edx
  80127d:	3b 50 04             	cmp    0x4(%eax),%edx
  801280:	73 0a                	jae    80128c <sprintputch+0x1f>
		*b->buf++ = ch;
  801282:	8d 4a 01             	lea    0x1(%edx),%ecx
  801285:	89 08                	mov    %ecx,(%eax)
  801287:	8b 45 08             	mov    0x8(%ebp),%eax
  80128a:	88 02                	mov    %al,(%edx)
}
  80128c:	5d                   	pop    %ebp
  80128d:	c3                   	ret    

0080128e <printfmt>:
{
  80128e:	f3 0f 1e fb          	endbr32 
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801298:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80129b:	50                   	push   %eax
  80129c:	ff 75 10             	pushl  0x10(%ebp)
  80129f:	ff 75 0c             	pushl  0xc(%ebp)
  8012a2:	ff 75 08             	pushl  0x8(%ebp)
  8012a5:	e8 05 00 00 00       	call   8012af <vprintfmt>
}
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	c9                   	leave  
  8012ae:	c3                   	ret    

008012af <vprintfmt>:
{
  8012af:	f3 0f 1e fb          	endbr32 
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	57                   	push   %edi
  8012b7:	56                   	push   %esi
  8012b8:	53                   	push   %ebx
  8012b9:	83 ec 2c             	sub    $0x2c,%esp
  8012bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012bf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012c2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012c5:	e9 86 02 00 00       	jmp    801550 <vprintfmt+0x2a1>
		padc = ' ';
  8012ca:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012ce:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012d5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012e3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012e8:	8d 47 01             	lea    0x1(%edi),%eax
  8012eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012ee:	0f b6 17             	movzbl (%edi),%edx
  8012f1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012f4:	3c 55                	cmp    $0x55,%al
  8012f6:	0f 87 df 02 00 00    	ja     8015db <vprintfmt+0x32c>
  8012fc:	0f b6 c0             	movzbl %al,%eax
  8012ff:	3e ff 24 85 60 20 80 	notrack jmp *0x802060(,%eax,4)
  801306:	00 
  801307:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80130a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80130e:	eb d8                	jmp    8012e8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801310:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801313:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801317:	eb cf                	jmp    8012e8 <vprintfmt+0x39>
  801319:	0f b6 d2             	movzbl %dl,%edx
  80131c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80131f:	b8 00 00 00 00       	mov    $0x0,%eax
  801324:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801327:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80132a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80132e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801331:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801334:	83 f9 09             	cmp    $0x9,%ecx
  801337:	77 52                	ja     80138b <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  801339:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80133c:	eb e9                	jmp    801327 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80133e:	8b 45 14             	mov    0x14(%ebp),%eax
  801341:	8d 50 04             	lea    0x4(%eax),%edx
  801344:	89 55 14             	mov    %edx,0x14(%ebp)
  801347:	8b 00                	mov    (%eax),%eax
  801349:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80134c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80134f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801353:	79 93                	jns    8012e8 <vprintfmt+0x39>
				width = precision, precision = -1;
  801355:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801358:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80135b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801362:	eb 84                	jmp    8012e8 <vprintfmt+0x39>
  801364:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801367:	85 c0                	test   %eax,%eax
  801369:	ba 00 00 00 00       	mov    $0x0,%edx
  80136e:	0f 49 d0             	cmovns %eax,%edx
  801371:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801377:	e9 6c ff ff ff       	jmp    8012e8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80137c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80137f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801386:	e9 5d ff ff ff       	jmp    8012e8 <vprintfmt+0x39>
  80138b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80138e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801391:	eb bc                	jmp    80134f <vprintfmt+0xa0>
			lflag++;
  801393:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801399:	e9 4a ff ff ff       	jmp    8012e8 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80139e:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a1:	8d 50 04             	lea    0x4(%eax),%edx
  8013a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	56                   	push   %esi
  8013ab:	ff 30                	pushl  (%eax)
  8013ad:	ff d3                	call   *%ebx
			break;
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	e9 96 01 00 00       	jmp    80154d <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8013b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ba:	8d 50 04             	lea    0x4(%eax),%edx
  8013bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c0:	8b 00                	mov    (%eax),%eax
  8013c2:	99                   	cltd   
  8013c3:	31 d0                	xor    %edx,%eax
  8013c5:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013c7:	83 f8 0f             	cmp    $0xf,%eax
  8013ca:	7f 20                	jg     8013ec <vprintfmt+0x13d>
  8013cc:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  8013d3:	85 d2                	test   %edx,%edx
  8013d5:	74 15                	je     8013ec <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8013d7:	52                   	push   %edx
  8013d8:	68 bd 1e 80 00       	push   $0x801ebd
  8013dd:	56                   	push   %esi
  8013de:	53                   	push   %ebx
  8013df:	e8 aa fe ff ff       	call   80128e <printfmt>
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	e9 61 01 00 00       	jmp    80154d <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8013ec:	50                   	push   %eax
  8013ed:	68 3f 1f 80 00       	push   $0x801f3f
  8013f2:	56                   	push   %esi
  8013f3:	53                   	push   %ebx
  8013f4:	e8 95 fe ff ff       	call   80128e <printfmt>
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	e9 4c 01 00 00       	jmp    80154d <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  801401:	8b 45 14             	mov    0x14(%ebp),%eax
  801404:	8d 50 04             	lea    0x4(%eax),%edx
  801407:	89 55 14             	mov    %edx,0x14(%ebp)
  80140a:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80140c:	85 c9                	test   %ecx,%ecx
  80140e:	b8 38 1f 80 00       	mov    $0x801f38,%eax
  801413:	0f 45 c1             	cmovne %ecx,%eax
  801416:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801419:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80141d:	7e 06                	jle    801425 <vprintfmt+0x176>
  80141f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801423:	75 0d                	jne    801432 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  801425:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801428:	89 c7                	mov    %eax,%edi
  80142a:	03 45 e0             	add    -0x20(%ebp),%eax
  80142d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801430:	eb 57                	jmp    801489 <vprintfmt+0x1da>
  801432:	83 ec 08             	sub    $0x8,%esp
  801435:	ff 75 d8             	pushl  -0x28(%ebp)
  801438:	ff 75 cc             	pushl  -0x34(%ebp)
  80143b:	e8 4f 02 00 00       	call   80168f <strnlen>
  801440:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801443:	29 c2                	sub    %eax,%edx
  801445:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801448:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80144b:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80144f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  801452:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  801454:	85 db                	test   %ebx,%ebx
  801456:	7e 10                	jle    801468 <vprintfmt+0x1b9>
					putch(padc, putdat);
  801458:	83 ec 08             	sub    $0x8,%esp
  80145b:	56                   	push   %esi
  80145c:	57                   	push   %edi
  80145d:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801460:	83 eb 01             	sub    $0x1,%ebx
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	eb ec                	jmp    801454 <vprintfmt+0x1a5>
  801468:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80146b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80146e:	85 d2                	test   %edx,%edx
  801470:	b8 00 00 00 00       	mov    $0x0,%eax
  801475:	0f 49 c2             	cmovns %edx,%eax
  801478:	29 c2                	sub    %eax,%edx
  80147a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80147d:	eb a6                	jmp    801425 <vprintfmt+0x176>
					putch(ch, putdat);
  80147f:	83 ec 08             	sub    $0x8,%esp
  801482:	56                   	push   %esi
  801483:	52                   	push   %edx
  801484:	ff d3                	call   *%ebx
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80148c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80148e:	83 c7 01             	add    $0x1,%edi
  801491:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801495:	0f be d0             	movsbl %al,%edx
  801498:	85 d2                	test   %edx,%edx
  80149a:	74 42                	je     8014de <vprintfmt+0x22f>
  80149c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014a0:	78 06                	js     8014a8 <vprintfmt+0x1f9>
  8014a2:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014a6:	78 1e                	js     8014c6 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8014a8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014ac:	74 d1                	je     80147f <vprintfmt+0x1d0>
  8014ae:	0f be c0             	movsbl %al,%eax
  8014b1:	83 e8 20             	sub    $0x20,%eax
  8014b4:	83 f8 5e             	cmp    $0x5e,%eax
  8014b7:	76 c6                	jbe    80147f <vprintfmt+0x1d0>
					putch('?', putdat);
  8014b9:	83 ec 08             	sub    $0x8,%esp
  8014bc:	56                   	push   %esi
  8014bd:	6a 3f                	push   $0x3f
  8014bf:	ff d3                	call   *%ebx
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	eb c3                	jmp    801489 <vprintfmt+0x1da>
  8014c6:	89 cf                	mov    %ecx,%edi
  8014c8:	eb 0e                	jmp    8014d8 <vprintfmt+0x229>
				putch(' ', putdat);
  8014ca:	83 ec 08             	sub    $0x8,%esp
  8014cd:	56                   	push   %esi
  8014ce:	6a 20                	push   $0x20
  8014d0:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8014d2:	83 ef 01             	sub    $0x1,%edi
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	85 ff                	test   %edi,%edi
  8014da:	7f ee                	jg     8014ca <vprintfmt+0x21b>
  8014dc:	eb 6f                	jmp    80154d <vprintfmt+0x29e>
  8014de:	89 cf                	mov    %ecx,%edi
  8014e0:	eb f6                	jmp    8014d8 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8014e2:	89 ca                	mov    %ecx,%edx
  8014e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8014e7:	e8 55 fd ff ff       	call   801241 <getint>
  8014ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8014f2:	85 d2                	test   %edx,%edx
  8014f4:	78 0b                	js     801501 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8014f6:	89 d1                	mov    %edx,%ecx
  8014f8:	89 c2                	mov    %eax,%edx
			base = 10;
  8014fa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014ff:	eb 32                	jmp    801533 <vprintfmt+0x284>
				putch('-', putdat);
  801501:	83 ec 08             	sub    $0x8,%esp
  801504:	56                   	push   %esi
  801505:	6a 2d                	push   $0x2d
  801507:	ff d3                	call   *%ebx
				num = -(long long) num;
  801509:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80150c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80150f:	f7 da                	neg    %edx
  801511:	83 d1 00             	adc    $0x0,%ecx
  801514:	f7 d9                	neg    %ecx
  801516:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801519:	b8 0a 00 00 00       	mov    $0xa,%eax
  80151e:	eb 13                	jmp    801533 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  801520:	89 ca                	mov    %ecx,%edx
  801522:	8d 45 14             	lea    0x14(%ebp),%eax
  801525:	e8 e3 fc ff ff       	call   80120d <getuint>
  80152a:	89 d1                	mov    %edx,%ecx
  80152c:	89 c2                	mov    %eax,%edx
			base = 10;
  80152e:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  801533:	83 ec 0c             	sub    $0xc,%esp
  801536:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80153a:	57                   	push   %edi
  80153b:	ff 75 e0             	pushl  -0x20(%ebp)
  80153e:	50                   	push   %eax
  80153f:	51                   	push   %ecx
  801540:	52                   	push   %edx
  801541:	89 f2                	mov    %esi,%edx
  801543:	89 d8                	mov    %ebx,%eax
  801545:	e8 1a fc ff ff       	call   801164 <printnum>
			break;
  80154a:	83 c4 20             	add    $0x20,%esp
{
  80154d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801550:	83 c7 01             	add    $0x1,%edi
  801553:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801557:	83 f8 25             	cmp    $0x25,%eax
  80155a:	0f 84 6a fd ff ff    	je     8012ca <vprintfmt+0x1b>
			if (ch == '\0')
  801560:	85 c0                	test   %eax,%eax
  801562:	0f 84 93 00 00 00    	je     8015fb <vprintfmt+0x34c>
			putch(ch, putdat);
  801568:	83 ec 08             	sub    $0x8,%esp
  80156b:	56                   	push   %esi
  80156c:	50                   	push   %eax
  80156d:	ff d3                	call   *%ebx
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	eb dc                	jmp    801550 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  801574:	89 ca                	mov    %ecx,%edx
  801576:	8d 45 14             	lea    0x14(%ebp),%eax
  801579:	e8 8f fc ff ff       	call   80120d <getuint>
  80157e:	89 d1                	mov    %edx,%ecx
  801580:	89 c2                	mov    %eax,%edx
			base = 8;
  801582:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801587:	eb aa                	jmp    801533 <vprintfmt+0x284>
			putch('0', putdat);
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	56                   	push   %esi
  80158d:	6a 30                	push   $0x30
  80158f:	ff d3                	call   *%ebx
			putch('x', putdat);
  801591:	83 c4 08             	add    $0x8,%esp
  801594:	56                   	push   %esi
  801595:	6a 78                	push   $0x78
  801597:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  801599:	8b 45 14             	mov    0x14(%ebp),%eax
  80159c:	8d 50 04             	lea    0x4(%eax),%edx
  80159f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8015a2:	8b 10                	mov    (%eax),%edx
  8015a4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015a9:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8015ac:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015b1:	eb 80                	jmp    801533 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8015b3:	89 ca                	mov    %ecx,%edx
  8015b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b8:	e8 50 fc ff ff       	call   80120d <getuint>
  8015bd:	89 d1                	mov    %edx,%ecx
  8015bf:	89 c2                	mov    %eax,%edx
			base = 16;
  8015c1:	b8 10 00 00 00       	mov    $0x10,%eax
  8015c6:	e9 68 ff ff ff       	jmp    801533 <vprintfmt+0x284>
			putch(ch, putdat);
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	56                   	push   %esi
  8015cf:	6a 25                	push   $0x25
  8015d1:	ff d3                	call   *%ebx
			break;
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	e9 72 ff ff ff       	jmp    80154d <vprintfmt+0x29e>
			putch('%', putdat);
  8015db:	83 ec 08             	sub    $0x8,%esp
  8015de:	56                   	push   %esi
  8015df:	6a 25                	push   $0x25
  8015e1:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	89 f8                	mov    %edi,%eax
  8015e8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015ec:	74 05                	je     8015f3 <vprintfmt+0x344>
  8015ee:	83 e8 01             	sub    $0x1,%eax
  8015f1:	eb f5                	jmp    8015e8 <vprintfmt+0x339>
  8015f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015f6:	e9 52 ff ff ff       	jmp    80154d <vprintfmt+0x29e>
}
  8015fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015fe:	5b                   	pop    %ebx
  8015ff:	5e                   	pop    %esi
  801600:	5f                   	pop    %edi
  801601:	5d                   	pop    %ebp
  801602:	c3                   	ret    

00801603 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801603:	f3 0f 1e fb          	endbr32 
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	83 ec 18             	sub    $0x18,%esp
  80160d:	8b 45 08             	mov    0x8(%ebp),%eax
  801610:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801613:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801616:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80161a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80161d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801624:	85 c0                	test   %eax,%eax
  801626:	74 26                	je     80164e <vsnprintf+0x4b>
  801628:	85 d2                	test   %edx,%edx
  80162a:	7e 22                	jle    80164e <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80162c:	ff 75 14             	pushl  0x14(%ebp)
  80162f:	ff 75 10             	pushl  0x10(%ebp)
  801632:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801635:	50                   	push   %eax
  801636:	68 6d 12 80 00       	push   $0x80126d
  80163b:	e8 6f fc ff ff       	call   8012af <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801640:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801643:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801646:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801649:	83 c4 10             	add    $0x10,%esp
}
  80164c:	c9                   	leave  
  80164d:	c3                   	ret    
		return -E_INVAL;
  80164e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801653:	eb f7                	jmp    80164c <vsnprintf+0x49>

00801655 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801655:	f3 0f 1e fb          	endbr32 
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80165f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801662:	50                   	push   %eax
  801663:	ff 75 10             	pushl  0x10(%ebp)
  801666:	ff 75 0c             	pushl  0xc(%ebp)
  801669:	ff 75 08             	pushl  0x8(%ebp)
  80166c:	e8 92 ff ff ff       	call   801603 <vsnprintf>
	va_end(ap);

	return rc;
}
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801673:	f3 0f 1e fb          	endbr32 
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80167d:	b8 00 00 00 00       	mov    $0x0,%eax
  801682:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801686:	74 05                	je     80168d <strlen+0x1a>
		n++;
  801688:	83 c0 01             	add    $0x1,%eax
  80168b:	eb f5                	jmp    801682 <strlen+0xf>
	return n;
}
  80168d:	5d                   	pop    %ebp
  80168e:	c3                   	ret    

0080168f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80168f:	f3 0f 1e fb          	endbr32 
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801699:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80169c:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a1:	39 d0                	cmp    %edx,%eax
  8016a3:	74 0d                	je     8016b2 <strnlen+0x23>
  8016a5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016a9:	74 05                	je     8016b0 <strnlen+0x21>
		n++;
  8016ab:	83 c0 01             	add    $0x1,%eax
  8016ae:	eb f1                	jmp    8016a1 <strnlen+0x12>
  8016b0:	89 c2                	mov    %eax,%edx
	return n;
}
  8016b2:	89 d0                	mov    %edx,%eax
  8016b4:	5d                   	pop    %ebp
  8016b5:	c3                   	ret    

008016b6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016b6:	f3 0f 1e fb          	endbr32 
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	53                   	push   %ebx
  8016be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016cd:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016d0:	83 c0 01             	add    $0x1,%eax
  8016d3:	84 d2                	test   %dl,%dl
  8016d5:	75 f2                	jne    8016c9 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8016d7:	89 c8                	mov    %ecx,%eax
  8016d9:	5b                   	pop    %ebx
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    

008016dc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016dc:	f3 0f 1e fb          	endbr32 
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	53                   	push   %ebx
  8016e4:	83 ec 10             	sub    $0x10,%esp
  8016e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016ea:	53                   	push   %ebx
  8016eb:	e8 83 ff ff ff       	call   801673 <strlen>
  8016f0:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016f3:	ff 75 0c             	pushl  0xc(%ebp)
  8016f6:	01 d8                	add    %ebx,%eax
  8016f8:	50                   	push   %eax
  8016f9:	e8 b8 ff ff ff       	call   8016b6 <strcpy>
	return dst;
}
  8016fe:	89 d8                	mov    %ebx,%eax
  801700:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801703:	c9                   	leave  
  801704:	c3                   	ret    

00801705 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801705:	f3 0f 1e fb          	endbr32 
  801709:	55                   	push   %ebp
  80170a:	89 e5                	mov    %esp,%ebp
  80170c:	56                   	push   %esi
  80170d:	53                   	push   %ebx
  80170e:	8b 75 08             	mov    0x8(%ebp),%esi
  801711:	8b 55 0c             	mov    0xc(%ebp),%edx
  801714:	89 f3                	mov    %esi,%ebx
  801716:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801719:	89 f0                	mov    %esi,%eax
  80171b:	39 d8                	cmp    %ebx,%eax
  80171d:	74 11                	je     801730 <strncpy+0x2b>
		*dst++ = *src;
  80171f:	83 c0 01             	add    $0x1,%eax
  801722:	0f b6 0a             	movzbl (%edx),%ecx
  801725:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801728:	80 f9 01             	cmp    $0x1,%cl
  80172b:	83 da ff             	sbb    $0xffffffff,%edx
  80172e:	eb eb                	jmp    80171b <strncpy+0x16>
	}
	return ret;
}
  801730:	89 f0                	mov    %esi,%eax
  801732:	5b                   	pop    %ebx
  801733:	5e                   	pop    %esi
  801734:	5d                   	pop    %ebp
  801735:	c3                   	ret    

00801736 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801736:	f3 0f 1e fb          	endbr32 
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	56                   	push   %esi
  80173e:	53                   	push   %ebx
  80173f:	8b 75 08             	mov    0x8(%ebp),%esi
  801742:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801745:	8b 55 10             	mov    0x10(%ebp),%edx
  801748:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80174a:	85 d2                	test   %edx,%edx
  80174c:	74 21                	je     80176f <strlcpy+0x39>
  80174e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801752:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801754:	39 c2                	cmp    %eax,%edx
  801756:	74 14                	je     80176c <strlcpy+0x36>
  801758:	0f b6 19             	movzbl (%ecx),%ebx
  80175b:	84 db                	test   %bl,%bl
  80175d:	74 0b                	je     80176a <strlcpy+0x34>
			*dst++ = *src++;
  80175f:	83 c1 01             	add    $0x1,%ecx
  801762:	83 c2 01             	add    $0x1,%edx
  801765:	88 5a ff             	mov    %bl,-0x1(%edx)
  801768:	eb ea                	jmp    801754 <strlcpy+0x1e>
  80176a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80176c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80176f:	29 f0                	sub    %esi,%eax
}
  801771:	5b                   	pop    %ebx
  801772:	5e                   	pop    %esi
  801773:	5d                   	pop    %ebp
  801774:	c3                   	ret    

00801775 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801775:	f3 0f 1e fb          	endbr32 
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80177f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801782:	0f b6 01             	movzbl (%ecx),%eax
  801785:	84 c0                	test   %al,%al
  801787:	74 0c                	je     801795 <strcmp+0x20>
  801789:	3a 02                	cmp    (%edx),%al
  80178b:	75 08                	jne    801795 <strcmp+0x20>
		p++, q++;
  80178d:	83 c1 01             	add    $0x1,%ecx
  801790:	83 c2 01             	add    $0x1,%edx
  801793:	eb ed                	jmp    801782 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801795:	0f b6 c0             	movzbl %al,%eax
  801798:	0f b6 12             	movzbl (%edx),%edx
  80179b:	29 d0                	sub    %edx,%eax
}
  80179d:	5d                   	pop    %ebp
  80179e:	c3                   	ret    

0080179f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80179f:	f3 0f 1e fb          	endbr32 
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	53                   	push   %ebx
  8017a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ad:	89 c3                	mov    %eax,%ebx
  8017af:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017b2:	eb 06                	jmp    8017ba <strncmp+0x1b>
		n--, p++, q++;
  8017b4:	83 c0 01             	add    $0x1,%eax
  8017b7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017ba:	39 d8                	cmp    %ebx,%eax
  8017bc:	74 16                	je     8017d4 <strncmp+0x35>
  8017be:	0f b6 08             	movzbl (%eax),%ecx
  8017c1:	84 c9                	test   %cl,%cl
  8017c3:	74 04                	je     8017c9 <strncmp+0x2a>
  8017c5:	3a 0a                	cmp    (%edx),%cl
  8017c7:	74 eb                	je     8017b4 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c9:	0f b6 00             	movzbl (%eax),%eax
  8017cc:	0f b6 12             	movzbl (%edx),%edx
  8017cf:	29 d0                	sub    %edx,%eax
}
  8017d1:	5b                   	pop    %ebx
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    
		return 0;
  8017d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d9:	eb f6                	jmp    8017d1 <strncmp+0x32>

008017db <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017db:	f3 0f 1e fb          	endbr32 
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e9:	0f b6 10             	movzbl (%eax),%edx
  8017ec:	84 d2                	test   %dl,%dl
  8017ee:	74 09                	je     8017f9 <strchr+0x1e>
		if (*s == c)
  8017f0:	38 ca                	cmp    %cl,%dl
  8017f2:	74 0a                	je     8017fe <strchr+0x23>
	for (; *s; s++)
  8017f4:	83 c0 01             	add    $0x1,%eax
  8017f7:	eb f0                	jmp    8017e9 <strchr+0xe>
			return (char *) s;
	return 0;
  8017f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    

00801800 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801800:	f3 0f 1e fb          	endbr32 
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	8b 45 08             	mov    0x8(%ebp),%eax
  80180a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80180e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801811:	38 ca                	cmp    %cl,%dl
  801813:	74 09                	je     80181e <strfind+0x1e>
  801815:	84 d2                	test   %dl,%dl
  801817:	74 05                	je     80181e <strfind+0x1e>
	for (; *s; s++)
  801819:	83 c0 01             	add    $0x1,%eax
  80181c:	eb f0                	jmp    80180e <strfind+0xe>
			break;
	return (char *) s;
}
  80181e:	5d                   	pop    %ebp
  80181f:	c3                   	ret    

00801820 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801820:	f3 0f 1e fb          	endbr32 
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	57                   	push   %edi
  801828:	56                   	push   %esi
  801829:	53                   	push   %ebx
  80182a:	8b 55 08             	mov    0x8(%ebp),%edx
  80182d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  801830:	85 c9                	test   %ecx,%ecx
  801832:	74 33                	je     801867 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801834:	89 d0                	mov    %edx,%eax
  801836:	09 c8                	or     %ecx,%eax
  801838:	a8 03                	test   $0x3,%al
  80183a:	75 23                	jne    80185f <memset+0x3f>
		c &= 0xFF;
  80183c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801840:	89 d8                	mov    %ebx,%eax
  801842:	c1 e0 08             	shl    $0x8,%eax
  801845:	89 df                	mov    %ebx,%edi
  801847:	c1 e7 18             	shl    $0x18,%edi
  80184a:	89 de                	mov    %ebx,%esi
  80184c:	c1 e6 10             	shl    $0x10,%esi
  80184f:	09 f7                	or     %esi,%edi
  801851:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  801853:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801856:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  801858:	89 d7                	mov    %edx,%edi
  80185a:	fc                   	cld    
  80185b:	f3 ab                	rep stos %eax,%es:(%edi)
  80185d:	eb 08                	jmp    801867 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80185f:	89 d7                	mov    %edx,%edi
  801861:	8b 45 0c             	mov    0xc(%ebp),%eax
  801864:	fc                   	cld    
  801865:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  801867:	89 d0                	mov    %edx,%eax
  801869:	5b                   	pop    %ebx
  80186a:	5e                   	pop    %esi
  80186b:	5f                   	pop    %edi
  80186c:	5d                   	pop    %ebp
  80186d:	c3                   	ret    

0080186e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80186e:	f3 0f 1e fb          	endbr32 
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	57                   	push   %edi
  801876:	56                   	push   %esi
  801877:	8b 45 08             	mov    0x8(%ebp),%eax
  80187a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80187d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801880:	39 c6                	cmp    %eax,%esi
  801882:	73 32                	jae    8018b6 <memmove+0x48>
  801884:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801887:	39 c2                	cmp    %eax,%edx
  801889:	76 2b                	jbe    8018b6 <memmove+0x48>
		s += n;
		d += n;
  80188b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80188e:	89 fe                	mov    %edi,%esi
  801890:	09 ce                	or     %ecx,%esi
  801892:	09 d6                	or     %edx,%esi
  801894:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80189a:	75 0e                	jne    8018aa <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80189c:	83 ef 04             	sub    $0x4,%edi
  80189f:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018a2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018a5:	fd                   	std    
  8018a6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a8:	eb 09                	jmp    8018b3 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018aa:	83 ef 01             	sub    $0x1,%edi
  8018ad:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018b0:	fd                   	std    
  8018b1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b3:	fc                   	cld    
  8018b4:	eb 1a                	jmp    8018d0 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b6:	89 c2                	mov    %eax,%edx
  8018b8:	09 ca                	or     %ecx,%edx
  8018ba:	09 f2                	or     %esi,%edx
  8018bc:	f6 c2 03             	test   $0x3,%dl
  8018bf:	75 0a                	jne    8018cb <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018c1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018c4:	89 c7                	mov    %eax,%edi
  8018c6:	fc                   	cld    
  8018c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c9:	eb 05                	jmp    8018d0 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8018cb:	89 c7                	mov    %eax,%edi
  8018cd:	fc                   	cld    
  8018ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d0:	5e                   	pop    %esi
  8018d1:	5f                   	pop    %edi
  8018d2:	5d                   	pop    %ebp
  8018d3:	c3                   	ret    

008018d4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d4:	f3 0f 1e fb          	endbr32 
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018de:	ff 75 10             	pushl  0x10(%ebp)
  8018e1:	ff 75 0c             	pushl  0xc(%ebp)
  8018e4:	ff 75 08             	pushl  0x8(%ebp)
  8018e7:	e8 82 ff ff ff       	call   80186e <memmove>
}
  8018ec:	c9                   	leave  
  8018ed:	c3                   	ret    

008018ee <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ee:	f3 0f 1e fb          	endbr32 
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	56                   	push   %esi
  8018f6:	53                   	push   %ebx
  8018f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018fd:	89 c6                	mov    %eax,%esi
  8018ff:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801902:	39 f0                	cmp    %esi,%eax
  801904:	74 1c                	je     801922 <memcmp+0x34>
		if (*s1 != *s2)
  801906:	0f b6 08             	movzbl (%eax),%ecx
  801909:	0f b6 1a             	movzbl (%edx),%ebx
  80190c:	38 d9                	cmp    %bl,%cl
  80190e:	75 08                	jne    801918 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801910:	83 c0 01             	add    $0x1,%eax
  801913:	83 c2 01             	add    $0x1,%edx
  801916:	eb ea                	jmp    801902 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801918:	0f b6 c1             	movzbl %cl,%eax
  80191b:	0f b6 db             	movzbl %bl,%ebx
  80191e:	29 d8                	sub    %ebx,%eax
  801920:	eb 05                	jmp    801927 <memcmp+0x39>
	}

	return 0;
  801922:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801927:	5b                   	pop    %ebx
  801928:	5e                   	pop    %esi
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    

0080192b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80192b:	f3 0f 1e fb          	endbr32 
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	8b 45 08             	mov    0x8(%ebp),%eax
  801935:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801938:	89 c2                	mov    %eax,%edx
  80193a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80193d:	39 d0                	cmp    %edx,%eax
  80193f:	73 09                	jae    80194a <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801941:	38 08                	cmp    %cl,(%eax)
  801943:	74 05                	je     80194a <memfind+0x1f>
	for (; s < ends; s++)
  801945:	83 c0 01             	add    $0x1,%eax
  801948:	eb f3                	jmp    80193d <memfind+0x12>
			break;
	return (void *) s;
}
  80194a:	5d                   	pop    %ebp
  80194b:	c3                   	ret    

0080194c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80194c:	f3 0f 1e fb          	endbr32 
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	57                   	push   %edi
  801954:	56                   	push   %esi
  801955:	53                   	push   %ebx
  801956:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801959:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80195c:	eb 03                	jmp    801961 <strtol+0x15>
		s++;
  80195e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801961:	0f b6 01             	movzbl (%ecx),%eax
  801964:	3c 20                	cmp    $0x20,%al
  801966:	74 f6                	je     80195e <strtol+0x12>
  801968:	3c 09                	cmp    $0x9,%al
  80196a:	74 f2                	je     80195e <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  80196c:	3c 2b                	cmp    $0x2b,%al
  80196e:	74 2a                	je     80199a <strtol+0x4e>
	int neg = 0;
  801970:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801975:	3c 2d                	cmp    $0x2d,%al
  801977:	74 2b                	je     8019a4 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801979:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80197f:	75 0f                	jne    801990 <strtol+0x44>
  801981:	80 39 30             	cmpb   $0x30,(%ecx)
  801984:	74 28                	je     8019ae <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801986:	85 db                	test   %ebx,%ebx
  801988:	b8 0a 00 00 00       	mov    $0xa,%eax
  80198d:	0f 44 d8             	cmove  %eax,%ebx
  801990:	b8 00 00 00 00       	mov    $0x0,%eax
  801995:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801998:	eb 46                	jmp    8019e0 <strtol+0x94>
		s++;
  80199a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80199d:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a2:	eb d5                	jmp    801979 <strtol+0x2d>
		s++, neg = 1;
  8019a4:	83 c1 01             	add    $0x1,%ecx
  8019a7:	bf 01 00 00 00       	mov    $0x1,%edi
  8019ac:	eb cb                	jmp    801979 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019ae:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019b2:	74 0e                	je     8019c2 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019b4:	85 db                	test   %ebx,%ebx
  8019b6:	75 d8                	jne    801990 <strtol+0x44>
		s++, base = 8;
  8019b8:	83 c1 01             	add    $0x1,%ecx
  8019bb:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019c0:	eb ce                	jmp    801990 <strtol+0x44>
		s += 2, base = 16;
  8019c2:	83 c1 02             	add    $0x2,%ecx
  8019c5:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019ca:	eb c4                	jmp    801990 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019cc:	0f be d2             	movsbl %dl,%edx
  8019cf:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019d2:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019d5:	7d 3a                	jge    801a11 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019d7:	83 c1 01             	add    $0x1,%ecx
  8019da:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019de:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019e0:	0f b6 11             	movzbl (%ecx),%edx
  8019e3:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019e6:	89 f3                	mov    %esi,%ebx
  8019e8:	80 fb 09             	cmp    $0x9,%bl
  8019eb:	76 df                	jbe    8019cc <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8019ed:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019f0:	89 f3                	mov    %esi,%ebx
  8019f2:	80 fb 19             	cmp    $0x19,%bl
  8019f5:	77 08                	ja     8019ff <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019f7:	0f be d2             	movsbl %dl,%edx
  8019fa:	83 ea 57             	sub    $0x57,%edx
  8019fd:	eb d3                	jmp    8019d2 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  8019ff:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a02:	89 f3                	mov    %esi,%ebx
  801a04:	80 fb 19             	cmp    $0x19,%bl
  801a07:	77 08                	ja     801a11 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a09:	0f be d2             	movsbl %dl,%edx
  801a0c:	83 ea 37             	sub    $0x37,%edx
  801a0f:	eb c1                	jmp    8019d2 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a11:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a15:	74 05                	je     801a1c <strtol+0xd0>
		*endptr = (char *) s;
  801a17:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a1a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a1c:	89 c2                	mov    %eax,%edx
  801a1e:	f7 da                	neg    %edx
  801a20:	85 ff                	test   %edi,%edi
  801a22:	0f 45 c2             	cmovne %edx,%eax
}
  801a25:	5b                   	pop    %ebx
  801a26:	5e                   	pop    %esi
  801a27:	5f                   	pop    %edi
  801a28:	5d                   	pop    %ebp
  801a29:	c3                   	ret    

00801a2a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a2a:	f3 0f 1e fb          	endbr32 
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	56                   	push   %esi
  801a32:	53                   	push   %ebx
  801a33:	8b 75 08             	mov    0x8(%ebp),%esi
  801a36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a43:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801a46:	83 ec 0c             	sub    $0xc,%esp
  801a49:	50                   	push   %eax
  801a4a:	e8 82 e8 ff ff       	call   8002d1 <sys_ipc_recv>
	if (f < 0) {
  801a4f:	83 c4 10             	add    $0x10,%esp
  801a52:	85 c0                	test   %eax,%eax
  801a54:	78 2b                	js     801a81 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801a56:	85 f6                	test   %esi,%esi
  801a58:	74 0a                	je     801a64 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801a5a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5f:	8b 40 74             	mov    0x74(%eax),%eax
  801a62:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801a64:	85 db                	test   %ebx,%ebx
  801a66:	74 0a                	je     801a72 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801a68:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6d:	8b 40 78             	mov    0x78(%eax),%eax
  801a70:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  801a72:	a1 04 40 80 00       	mov    0x804004,%eax
  801a77:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7d:	5b                   	pop    %ebx
  801a7e:	5e                   	pop    %esi
  801a7f:	5d                   	pop    %ebp
  801a80:	c3                   	ret    
		if (from_env_store != NULL) {
  801a81:	85 f6                	test   %esi,%esi
  801a83:	74 06                	je     801a8b <ipc_recv+0x61>
			*from_env_store = 0;
  801a85:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801a8b:	85 db                	test   %ebx,%ebx
  801a8d:	74 eb                	je     801a7a <ipc_recv+0x50>
			*perm_store = 0;
  801a8f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a95:	eb e3                	jmp    801a7a <ipc_recv+0x50>

00801a97 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a97:	f3 0f 1e fb          	endbr32 
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	57                   	push   %edi
  801a9f:	56                   	push   %esi
  801aa0:	53                   	push   %ebx
  801aa1:	83 ec 0c             	sub    $0xc,%esp
  801aa4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aa7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aaa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  801aad:	85 db                	test   %ebx,%ebx
  801aaf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ab4:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801ab7:	ff 75 14             	pushl  0x14(%ebp)
  801aba:	53                   	push   %ebx
  801abb:	56                   	push   %esi
  801abc:	57                   	push   %edi
  801abd:	e8 e6 e7 ff ff       	call   8002a8 <sys_ipc_try_send>
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	79 19                	jns    801ae2 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  801ac9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801acc:	74 e9                	je     801ab7 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  801ace:	83 ec 04             	sub    $0x4,%esp
  801ad1:	68 20 22 80 00       	push   $0x802220
  801ad6:	6a 48                	push   $0x48
  801ad8:	68 42 22 80 00       	push   $0x802242
  801add:	e8 83 f5 ff ff       	call   801065 <_panic>
		}
	}
}
  801ae2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae5:	5b                   	pop    %ebx
  801ae6:	5e                   	pop    %esi
  801ae7:	5f                   	pop    %edi
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aea:	f3 0f 1e fb          	endbr32 
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801af4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801af9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801afc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b02:	8b 52 50             	mov    0x50(%edx),%edx
  801b05:	39 ca                	cmp    %ecx,%edx
  801b07:	74 11                	je     801b1a <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801b09:	83 c0 01             	add    $0x1,%eax
  801b0c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b11:	75 e6                	jne    801af9 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b13:	b8 00 00 00 00       	mov    $0x0,%eax
  801b18:	eb 0b                	jmp    801b25 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b1a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b1d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b22:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b27:	f3 0f 1e fb          	endbr32 
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b31:	89 c2                	mov    %eax,%edx
  801b33:	c1 ea 16             	shr    $0x16,%edx
  801b36:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b3d:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b42:	f6 c1 01             	test   $0x1,%cl
  801b45:	74 1c                	je     801b63 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b47:	c1 e8 0c             	shr    $0xc,%eax
  801b4a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b51:	a8 01                	test   $0x1,%al
  801b53:	74 0e                	je     801b63 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b55:	c1 e8 0c             	shr    $0xc,%eax
  801b58:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b5f:	ef 
  801b60:	0f b7 d2             	movzwl %dx,%edx
}
  801b63:	89 d0                	mov    %edx,%eax
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    
  801b67:	66 90                	xchg   %ax,%ax
  801b69:	66 90                	xchg   %ax,%ax
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
