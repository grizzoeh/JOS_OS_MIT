
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 1a 00 00 00       	call   80004b <libmain>
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
  80003a:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  80003d:	6a 01                	push   $0x1
  80003f:	6a 01                	push   $0x1
  800041:	e8 ba 00 00 00       	call   800100 <sys_cputs>
}
  800046:	83 c4 10             	add    $0x10,%esp
  800049:	c9                   	leave  
  80004a:	c3                   	ret    

0080004b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004b:	f3 0f 1e fb          	endbr32 
  80004f:	55                   	push   %ebp
  800050:	89 e5                	mov    %esp,%ebp
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800057:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  80005a:	e8 19 01 00 00       	call   800178 <sys_getenvid>
	if (id >= 0)
  80005f:	85 c0                	test   %eax,%eax
  800061:	78 12                	js     800075 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 db                	test   %ebx,%ebx
  800077:	7e 07                	jle    800080 <libmain+0x35>
		binaryname = argv[0];
  800079:	8b 06                	mov    (%esi),%eax
  80007b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800080:	83 ec 08             	sub    $0x8,%esp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	e8 a9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008a:	e8 0a 00 00 00       	call   800099 <exit>
}
  80008f:	83 c4 10             	add    $0x10,%esp
  800092:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800095:	5b                   	pop    %ebx
  800096:	5e                   	pop    %esi
  800097:	5d                   	pop    %ebp
  800098:	c3                   	ret    

00800099 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800099:	f3 0f 1e fb          	endbr32 
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a3:	e8 53 04 00 00       	call   8004fb <close_all>
	sys_env_destroy(0);
  8000a8:	83 ec 0c             	sub    $0xc,%esp
  8000ab:	6a 00                	push   $0x0
  8000ad:	e8 a0 00 00 00       	call   800152 <sys_env_destroy>
}
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	c9                   	leave  
  8000b6:	c3                   	ret    

008000b7 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
  8000bd:	83 ec 1c             	sub    $0x1c,%esp
  8000c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000c3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000c6:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000d1:	8b 75 14             	mov    0x14(%ebp),%esi
  8000d4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000da:	74 04                	je     8000e0 <syscall+0x29>
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	7f 08                	jg     8000e8 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5f                   	pop    %edi
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e8:	83 ec 0c             	sub    $0xc,%esp
  8000eb:	50                   	push   %eax
  8000ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8000ef:	68 ea 1d 80 00       	push   $0x801dea
  8000f4:	6a 23                	push   $0x23
  8000f6:	68 07 1e 80 00       	push   $0x801e07
  8000fb:	e8 76 0f 00 00       	call   801076 <_panic>

00800100 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800100:	f3 0f 1e fb          	endbr32 
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80010a:	6a 00                	push   $0x0
  80010c:	6a 00                	push   $0x0
  80010e:	6a 00                	push   $0x0
  800110:	ff 75 0c             	pushl  0xc(%ebp)
  800113:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800116:	ba 00 00 00 00       	mov    $0x0,%edx
  80011b:	b8 00 00 00 00       	mov    $0x0,%eax
  800120:	e8 92 ff ff ff       	call   8000b7 <syscall>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <sys_cgetc>:

int
sys_cgetc(void)
{
  80012a:	f3 0f 1e fb          	endbr32 
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800134:	6a 00                	push   $0x0
  800136:	6a 00                	push   $0x0
  800138:	6a 00                	push   $0x0
  80013a:	6a 00                	push   $0x0
  80013c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 01 00 00 00       	mov    $0x1,%eax
  80014b:	e8 67 ff ff ff       	call   8000b7 <syscall>
}
  800150:	c9                   	leave  
  800151:	c3                   	ret    

00800152 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800152:	f3 0f 1e fb          	endbr32 
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80015c:	6a 00                	push   $0x0
  80015e:	6a 00                	push   $0x0
  800160:	6a 00                	push   $0x0
  800162:	6a 00                	push   $0x0
  800164:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800167:	ba 01 00 00 00       	mov    $0x1,%edx
  80016c:	b8 03 00 00 00       	mov    $0x3,%eax
  800171:	e8 41 ff ff ff       	call   8000b7 <syscall>
}
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800178:	f3 0f 1e fb          	endbr32 
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800182:	6a 00                	push   $0x0
  800184:	6a 00                	push   $0x0
  800186:	6a 00                	push   $0x0
  800188:	6a 00                	push   $0x0
  80018a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80018f:	ba 00 00 00 00       	mov    $0x0,%edx
  800194:	b8 02 00 00 00       	mov    $0x2,%eax
  800199:	e8 19 ff ff ff       	call   8000b7 <syscall>
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <sys_yield>:

void
sys_yield(void)
{
  8001a0:	f3 0f 1e fb          	endbr32 
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001aa:	6a 00                	push   $0x0
  8001ac:	6a 00                	push   $0x0
  8001ae:	6a 00                	push   $0x0
  8001b0:	6a 00                	push   $0x0
  8001b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001bc:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001c1:	e8 f1 fe ff ff       	call   8000b7 <syscall>
}
  8001c6:	83 c4 10             	add    $0x10,%esp
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001cb:	f3 0f 1e fb          	endbr32 
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001d5:	6a 00                	push   $0x0
  8001d7:	6a 00                	push   $0x0
  8001d9:	ff 75 10             	pushl  0x10(%ebp)
  8001dc:	ff 75 0c             	pushl  0xc(%ebp)
  8001df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e2:	ba 01 00 00 00       	mov    $0x1,%edx
  8001e7:	b8 04 00 00 00       	mov    $0x4,%eax
  8001ec:	e8 c6 fe ff ff       	call   8000b7 <syscall>
}
  8001f1:	c9                   	leave  
  8001f2:	c3                   	ret    

008001f3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001f3:	f3 0f 1e fb          	endbr32 
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001fd:	ff 75 18             	pushl  0x18(%ebp)
  800200:	ff 75 14             	pushl  0x14(%ebp)
  800203:	ff 75 10             	pushl  0x10(%ebp)
  800206:	ff 75 0c             	pushl  0xc(%ebp)
  800209:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020c:	ba 01 00 00 00       	mov    $0x1,%edx
  800211:	b8 05 00 00 00       	mov    $0x5,%eax
  800216:	e8 9c fe ff ff       	call   8000b7 <syscall>
}
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    

0080021d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80021d:	f3 0f 1e fb          	endbr32 
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800227:	6a 00                	push   $0x0
  800229:	6a 00                	push   $0x0
  80022b:	6a 00                	push   $0x0
  80022d:	ff 75 0c             	pushl  0xc(%ebp)
  800230:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800233:	ba 01 00 00 00       	mov    $0x1,%edx
  800238:	b8 06 00 00 00       	mov    $0x6,%eax
  80023d:	e8 75 fe ff ff       	call   8000b7 <syscall>
}
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800244:	f3 0f 1e fb          	endbr32 
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80024e:	6a 00                	push   $0x0
  800250:	6a 00                	push   $0x0
  800252:	6a 00                	push   $0x0
  800254:	ff 75 0c             	pushl  0xc(%ebp)
  800257:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025a:	ba 01 00 00 00       	mov    $0x1,%edx
  80025f:	b8 08 00 00 00       	mov    $0x8,%eax
  800264:	e8 4e fe ff ff       	call   8000b7 <syscall>
}
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026b:	f3 0f 1e fb          	endbr32 
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800275:	6a 00                	push   $0x0
  800277:	6a 00                	push   $0x0
  800279:	6a 00                	push   $0x0
  80027b:	ff 75 0c             	pushl  0xc(%ebp)
  80027e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800281:	ba 01 00 00 00       	mov    $0x1,%edx
  800286:	b8 09 00 00 00       	mov    $0x9,%eax
  80028b:	e8 27 fe ff ff       	call   8000b7 <syscall>
}
  800290:	c9                   	leave  
  800291:	c3                   	ret    

00800292 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800292:	f3 0f 1e fb          	endbr32 
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80029c:	6a 00                	push   $0x0
  80029e:	6a 00                	push   $0x0
  8002a0:	6a 00                	push   $0x0
  8002a2:	ff 75 0c             	pushl  0xc(%ebp)
  8002a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a8:	ba 01 00 00 00       	mov    $0x1,%edx
  8002ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b2:	e8 00 fe ff ff       	call   8000b7 <syscall>
}
  8002b7:	c9                   	leave  
  8002b8:	c3                   	ret    

008002b9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b9:	f3 0f 1e fb          	endbr32 
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002c3:	6a 00                	push   $0x0
  8002c5:	ff 75 14             	pushl  0x14(%ebp)
  8002c8:	ff 75 10             	pushl  0x10(%ebp)
  8002cb:	ff 75 0c             	pushl  0xc(%ebp)
  8002ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002db:	e8 d7 fd ff ff       	call   8000b7 <syscall>
}
  8002e0:	c9                   	leave  
  8002e1:	c3                   	ret    

008002e2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002e2:	f3 0f 1e fb          	endbr32 
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002ec:	6a 00                	push   $0x0
  8002ee:	6a 00                	push   $0x0
  8002f0:	6a 00                	push   $0x0
  8002f2:	6a 00                	push   $0x0
  8002f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f7:	ba 01 00 00 00       	mov    $0x1,%edx
  8002fc:	b8 0d 00 00 00       	mov    $0xd,%eax
  800301:	e8 b1 fd ff ff       	call   8000b7 <syscall>
}
  800306:	c9                   	leave  
  800307:	c3                   	ret    

00800308 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800308:	f3 0f 1e fb          	endbr32 
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80030f:	8b 45 08             	mov    0x8(%ebp),%eax
  800312:	05 00 00 00 30       	add    $0x30000000,%eax
  800317:	c1 e8 0c             	shr    $0xc,%eax
}
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80031c:	f3 0f 1e fb          	endbr32 
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800326:	ff 75 08             	pushl  0x8(%ebp)
  800329:	e8 da ff ff ff       	call   800308 <fd2num>
  80032e:	83 c4 10             	add    $0x10,%esp
  800331:	c1 e0 0c             	shl    $0xc,%eax
  800334:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800339:	c9                   	leave  
  80033a:	c3                   	ret    

0080033b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80033b:	f3 0f 1e fb          	endbr32 
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800347:	89 c2                	mov    %eax,%edx
  800349:	c1 ea 16             	shr    $0x16,%edx
  80034c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800353:	f6 c2 01             	test   $0x1,%dl
  800356:	74 2d                	je     800385 <fd_alloc+0x4a>
  800358:	89 c2                	mov    %eax,%edx
  80035a:	c1 ea 0c             	shr    $0xc,%edx
  80035d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800364:	f6 c2 01             	test   $0x1,%dl
  800367:	74 1c                	je     800385 <fd_alloc+0x4a>
  800369:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80036e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800373:	75 d2                	jne    800347 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80037e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800383:	eb 0a                	jmp    80038f <fd_alloc+0x54>
			*fd_store = fd;
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	89 01                	mov    %eax,(%ecx)
			return 0;
  80038a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800391:	f3 0f 1e fb          	endbr32 
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80039b:	83 f8 1f             	cmp    $0x1f,%eax
  80039e:	77 30                	ja     8003d0 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003a0:	c1 e0 0c             	shl    $0xc,%eax
  8003a3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003a8:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003ae:	f6 c2 01             	test   $0x1,%dl
  8003b1:	74 24                	je     8003d7 <fd_lookup+0x46>
  8003b3:	89 c2                	mov    %eax,%edx
  8003b5:	c1 ea 0c             	shr    $0xc,%edx
  8003b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003bf:	f6 c2 01             	test   $0x1,%dl
  8003c2:	74 1a                	je     8003de <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003c7:	89 02                	mov    %eax,(%edx)
	return 0;
  8003c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003ce:	5d                   	pop    %ebp
  8003cf:	c3                   	ret    
		return -E_INVAL;
  8003d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d5:	eb f7                	jmp    8003ce <fd_lookup+0x3d>
		return -E_INVAL;
  8003d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003dc:	eb f0                	jmp    8003ce <fd_lookup+0x3d>
  8003de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003e3:	eb e9                	jmp    8003ce <fd_lookup+0x3d>

008003e5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003e5:	f3 0f 1e fb          	endbr32 
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f2:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8003f7:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003fc:	39 08                	cmp    %ecx,(%eax)
  8003fe:	74 33                	je     800433 <dev_lookup+0x4e>
  800400:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800403:	8b 02                	mov    (%edx),%eax
  800405:	85 c0                	test   %eax,%eax
  800407:	75 f3                	jne    8003fc <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800409:	a1 04 40 80 00       	mov    0x804004,%eax
  80040e:	8b 40 48             	mov    0x48(%eax),%eax
  800411:	83 ec 04             	sub    $0x4,%esp
  800414:	51                   	push   %ecx
  800415:	50                   	push   %eax
  800416:	68 18 1e 80 00       	push   $0x801e18
  80041b:	e8 3d 0d 00 00       	call   80115d <cprintf>
	*dev = 0;
  800420:	8b 45 0c             	mov    0xc(%ebp),%eax
  800423:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800431:	c9                   	leave  
  800432:	c3                   	ret    
			*dev = devtab[i];
  800433:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800436:	89 01                	mov    %eax,(%ecx)
			return 0;
  800438:	b8 00 00 00 00       	mov    $0x0,%eax
  80043d:	eb f2                	jmp    800431 <dev_lookup+0x4c>

0080043f <fd_close>:
{
  80043f:	f3 0f 1e fb          	endbr32 
  800443:	55                   	push   %ebp
  800444:	89 e5                	mov    %esp,%ebp
  800446:	57                   	push   %edi
  800447:	56                   	push   %esi
  800448:	53                   	push   %ebx
  800449:	83 ec 28             	sub    $0x28,%esp
  80044c:	8b 75 08             	mov    0x8(%ebp),%esi
  80044f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800452:	56                   	push   %esi
  800453:	e8 b0 fe ff ff       	call   800308 <fd2num>
  800458:	83 c4 08             	add    $0x8,%esp
  80045b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80045e:	52                   	push   %edx
  80045f:	50                   	push   %eax
  800460:	e8 2c ff ff ff       	call   800391 <fd_lookup>
  800465:	89 c3                	mov    %eax,%ebx
  800467:	83 c4 10             	add    $0x10,%esp
  80046a:	85 c0                	test   %eax,%eax
  80046c:	78 05                	js     800473 <fd_close+0x34>
	    || fd != fd2)
  80046e:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800471:	74 16                	je     800489 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800473:	89 f8                	mov    %edi,%eax
  800475:	84 c0                	test   %al,%al
  800477:	b8 00 00 00 00       	mov    $0x0,%eax
  80047c:	0f 44 d8             	cmove  %eax,%ebx
}
  80047f:	89 d8                	mov    %ebx,%eax
  800481:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800484:	5b                   	pop    %ebx
  800485:	5e                   	pop    %esi
  800486:	5f                   	pop    %edi
  800487:	5d                   	pop    %ebp
  800488:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80048f:	50                   	push   %eax
  800490:	ff 36                	pushl  (%esi)
  800492:	e8 4e ff ff ff       	call   8003e5 <dev_lookup>
  800497:	89 c3                	mov    %eax,%ebx
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	85 c0                	test   %eax,%eax
  80049e:	78 1a                	js     8004ba <fd_close+0x7b>
		if (dev->dev_close)
  8004a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a3:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	74 0b                	je     8004ba <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004af:	83 ec 0c             	sub    $0xc,%esp
  8004b2:	56                   	push   %esi
  8004b3:	ff d0                	call   *%eax
  8004b5:	89 c3                	mov    %eax,%ebx
  8004b7:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	56                   	push   %esi
  8004be:	6a 00                	push   $0x0
  8004c0:	e8 58 fd ff ff       	call   80021d <sys_page_unmap>
	return r;
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	eb b5                	jmp    80047f <fd_close+0x40>

008004ca <close>:

int
close(int fdnum)
{
  8004ca:	f3 0f 1e fb          	endbr32 
  8004ce:	55                   	push   %ebp
  8004cf:	89 e5                	mov    %esp,%ebp
  8004d1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d7:	50                   	push   %eax
  8004d8:	ff 75 08             	pushl  0x8(%ebp)
  8004db:	e8 b1 fe ff ff       	call   800391 <fd_lookup>
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	79 02                	jns    8004e9 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004e7:	c9                   	leave  
  8004e8:	c3                   	ret    
		return fd_close(fd, 1);
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	6a 01                	push   $0x1
  8004ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8004f1:	e8 49 ff ff ff       	call   80043f <fd_close>
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb ec                	jmp    8004e7 <close+0x1d>

008004fb <close_all>:

void
close_all(void)
{
  8004fb:	f3 0f 1e fb          	endbr32 
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	53                   	push   %ebx
  800503:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800506:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80050b:	83 ec 0c             	sub    $0xc,%esp
  80050e:	53                   	push   %ebx
  80050f:	e8 b6 ff ff ff       	call   8004ca <close>
	for (i = 0; i < MAXFD; i++)
  800514:	83 c3 01             	add    $0x1,%ebx
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	83 fb 20             	cmp    $0x20,%ebx
  80051d:	75 ec                	jne    80050b <close_all+0x10>
}
  80051f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800522:	c9                   	leave  
  800523:	c3                   	ret    

00800524 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800524:	f3 0f 1e fb          	endbr32 
  800528:	55                   	push   %ebp
  800529:	89 e5                	mov    %esp,%ebp
  80052b:	57                   	push   %edi
  80052c:	56                   	push   %esi
  80052d:	53                   	push   %ebx
  80052e:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800531:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800534:	50                   	push   %eax
  800535:	ff 75 08             	pushl  0x8(%ebp)
  800538:	e8 54 fe ff ff       	call   800391 <fd_lookup>
  80053d:	89 c3                	mov    %eax,%ebx
  80053f:	83 c4 10             	add    $0x10,%esp
  800542:	85 c0                	test   %eax,%eax
  800544:	0f 88 81 00 00 00    	js     8005cb <dup+0xa7>
		return r;
	close(newfdnum);
  80054a:	83 ec 0c             	sub    $0xc,%esp
  80054d:	ff 75 0c             	pushl  0xc(%ebp)
  800550:	e8 75 ff ff ff       	call   8004ca <close>

	newfd = INDEX2FD(newfdnum);
  800555:	8b 75 0c             	mov    0xc(%ebp),%esi
  800558:	c1 e6 0c             	shl    $0xc,%esi
  80055b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800561:	83 c4 04             	add    $0x4,%esp
  800564:	ff 75 e4             	pushl  -0x1c(%ebp)
  800567:	e8 b0 fd ff ff       	call   80031c <fd2data>
  80056c:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80056e:	89 34 24             	mov    %esi,(%esp)
  800571:	e8 a6 fd ff ff       	call   80031c <fd2data>
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80057b:	89 d8                	mov    %ebx,%eax
  80057d:	c1 e8 16             	shr    $0x16,%eax
  800580:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800587:	a8 01                	test   $0x1,%al
  800589:	74 11                	je     80059c <dup+0x78>
  80058b:	89 d8                	mov    %ebx,%eax
  80058d:	c1 e8 0c             	shr    $0xc,%eax
  800590:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800597:	f6 c2 01             	test   $0x1,%dl
  80059a:	75 39                	jne    8005d5 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80059c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80059f:	89 d0                	mov    %edx,%eax
  8005a1:	c1 e8 0c             	shr    $0xc,%eax
  8005a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ab:	83 ec 0c             	sub    $0xc,%esp
  8005ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b3:	50                   	push   %eax
  8005b4:	56                   	push   %esi
  8005b5:	6a 00                	push   $0x0
  8005b7:	52                   	push   %edx
  8005b8:	6a 00                	push   $0x0
  8005ba:	e8 34 fc ff ff       	call   8001f3 <sys_page_map>
  8005bf:	89 c3                	mov    %eax,%ebx
  8005c1:	83 c4 20             	add    $0x20,%esp
  8005c4:	85 c0                	test   %eax,%eax
  8005c6:	78 31                	js     8005f9 <dup+0xd5>
		goto err;

	return newfdnum;
  8005c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005cb:	89 d8                	mov    %ebx,%eax
  8005cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005d0:	5b                   	pop    %ebx
  8005d1:	5e                   	pop    %esi
  8005d2:	5f                   	pop    %edi
  8005d3:	5d                   	pop    %ebp
  8005d4:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005dc:	83 ec 0c             	sub    $0xc,%esp
  8005df:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e4:	50                   	push   %eax
  8005e5:	57                   	push   %edi
  8005e6:	6a 00                	push   $0x0
  8005e8:	53                   	push   %ebx
  8005e9:	6a 00                	push   $0x0
  8005eb:	e8 03 fc ff ff       	call   8001f3 <sys_page_map>
  8005f0:	89 c3                	mov    %eax,%ebx
  8005f2:	83 c4 20             	add    $0x20,%esp
  8005f5:	85 c0                	test   %eax,%eax
  8005f7:	79 a3                	jns    80059c <dup+0x78>
	sys_page_unmap(0, newfd);
  8005f9:	83 ec 08             	sub    $0x8,%esp
  8005fc:	56                   	push   %esi
  8005fd:	6a 00                	push   $0x0
  8005ff:	e8 19 fc ff ff       	call   80021d <sys_page_unmap>
	sys_page_unmap(0, nva);
  800604:	83 c4 08             	add    $0x8,%esp
  800607:	57                   	push   %edi
  800608:	6a 00                	push   $0x0
  80060a:	e8 0e fc ff ff       	call   80021d <sys_page_unmap>
	return r;
  80060f:	83 c4 10             	add    $0x10,%esp
  800612:	eb b7                	jmp    8005cb <dup+0xa7>

00800614 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800614:	f3 0f 1e fb          	endbr32 
  800618:	55                   	push   %ebp
  800619:	89 e5                	mov    %esp,%ebp
  80061b:	53                   	push   %ebx
  80061c:	83 ec 1c             	sub    $0x1c,%esp
  80061f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800622:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800625:	50                   	push   %eax
  800626:	53                   	push   %ebx
  800627:	e8 65 fd ff ff       	call   800391 <fd_lookup>
  80062c:	83 c4 10             	add    $0x10,%esp
  80062f:	85 c0                	test   %eax,%eax
  800631:	78 3f                	js     800672 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800639:	50                   	push   %eax
  80063a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80063d:	ff 30                	pushl  (%eax)
  80063f:	e8 a1 fd ff ff       	call   8003e5 <dev_lookup>
  800644:	83 c4 10             	add    $0x10,%esp
  800647:	85 c0                	test   %eax,%eax
  800649:	78 27                	js     800672 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80064b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80064e:	8b 42 08             	mov    0x8(%edx),%eax
  800651:	83 e0 03             	and    $0x3,%eax
  800654:	83 f8 01             	cmp    $0x1,%eax
  800657:	74 1e                	je     800677 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800659:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80065c:	8b 40 08             	mov    0x8(%eax),%eax
  80065f:	85 c0                	test   %eax,%eax
  800661:	74 35                	je     800698 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800663:	83 ec 04             	sub    $0x4,%esp
  800666:	ff 75 10             	pushl  0x10(%ebp)
  800669:	ff 75 0c             	pushl  0xc(%ebp)
  80066c:	52                   	push   %edx
  80066d:	ff d0                	call   *%eax
  80066f:	83 c4 10             	add    $0x10,%esp
}
  800672:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800675:	c9                   	leave  
  800676:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800677:	a1 04 40 80 00       	mov    0x804004,%eax
  80067c:	8b 40 48             	mov    0x48(%eax),%eax
  80067f:	83 ec 04             	sub    $0x4,%esp
  800682:	53                   	push   %ebx
  800683:	50                   	push   %eax
  800684:	68 59 1e 80 00       	push   $0x801e59
  800689:	e8 cf 0a 00 00       	call   80115d <cprintf>
		return -E_INVAL;
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800696:	eb da                	jmp    800672 <read+0x5e>
		return -E_NOT_SUPP;
  800698:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80069d:	eb d3                	jmp    800672 <read+0x5e>

0080069f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80069f:	f3 0f 1e fb          	endbr32 
  8006a3:	55                   	push   %ebp
  8006a4:	89 e5                	mov    %esp,%ebp
  8006a6:	57                   	push   %edi
  8006a7:	56                   	push   %esi
  8006a8:	53                   	push   %ebx
  8006a9:	83 ec 0c             	sub    $0xc,%esp
  8006ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006af:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b7:	eb 02                	jmp    8006bb <readn+0x1c>
  8006b9:	01 c3                	add    %eax,%ebx
  8006bb:	39 f3                	cmp    %esi,%ebx
  8006bd:	73 21                	jae    8006e0 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006bf:	83 ec 04             	sub    $0x4,%esp
  8006c2:	89 f0                	mov    %esi,%eax
  8006c4:	29 d8                	sub    %ebx,%eax
  8006c6:	50                   	push   %eax
  8006c7:	89 d8                	mov    %ebx,%eax
  8006c9:	03 45 0c             	add    0xc(%ebp),%eax
  8006cc:	50                   	push   %eax
  8006cd:	57                   	push   %edi
  8006ce:	e8 41 ff ff ff       	call   800614 <read>
		if (m < 0)
  8006d3:	83 c4 10             	add    $0x10,%esp
  8006d6:	85 c0                	test   %eax,%eax
  8006d8:	78 04                	js     8006de <readn+0x3f>
			return m;
		if (m == 0)
  8006da:	75 dd                	jne    8006b9 <readn+0x1a>
  8006dc:	eb 02                	jmp    8006e0 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006de:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006e0:	89 d8                	mov    %ebx,%eax
  8006e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e5:	5b                   	pop    %ebx
  8006e6:	5e                   	pop    %esi
  8006e7:	5f                   	pop    %edi
  8006e8:	5d                   	pop    %ebp
  8006e9:	c3                   	ret    

008006ea <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006ea:	f3 0f 1e fb          	endbr32 
  8006ee:	55                   	push   %ebp
  8006ef:	89 e5                	mov    %esp,%ebp
  8006f1:	53                   	push   %ebx
  8006f2:	83 ec 1c             	sub    $0x1c,%esp
  8006f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006fb:	50                   	push   %eax
  8006fc:	53                   	push   %ebx
  8006fd:	e8 8f fc ff ff       	call   800391 <fd_lookup>
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	85 c0                	test   %eax,%eax
  800707:	78 3a                	js     800743 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80070f:	50                   	push   %eax
  800710:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800713:	ff 30                	pushl  (%eax)
  800715:	e8 cb fc ff ff       	call   8003e5 <dev_lookup>
  80071a:	83 c4 10             	add    $0x10,%esp
  80071d:	85 c0                	test   %eax,%eax
  80071f:	78 22                	js     800743 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800724:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800728:	74 1e                	je     800748 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80072a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80072d:	8b 52 0c             	mov    0xc(%edx),%edx
  800730:	85 d2                	test   %edx,%edx
  800732:	74 35                	je     800769 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800734:	83 ec 04             	sub    $0x4,%esp
  800737:	ff 75 10             	pushl  0x10(%ebp)
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	50                   	push   %eax
  80073e:	ff d2                	call   *%edx
  800740:	83 c4 10             	add    $0x10,%esp
}
  800743:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800746:	c9                   	leave  
  800747:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800748:	a1 04 40 80 00       	mov    0x804004,%eax
  80074d:	8b 40 48             	mov    0x48(%eax),%eax
  800750:	83 ec 04             	sub    $0x4,%esp
  800753:	53                   	push   %ebx
  800754:	50                   	push   %eax
  800755:	68 75 1e 80 00       	push   $0x801e75
  80075a:	e8 fe 09 00 00       	call   80115d <cprintf>
		return -E_INVAL;
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800767:	eb da                	jmp    800743 <write+0x59>
		return -E_NOT_SUPP;
  800769:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80076e:	eb d3                	jmp    800743 <write+0x59>

00800770 <seek>:

int
seek(int fdnum, off_t offset)
{
  800770:	f3 0f 1e fb          	endbr32 
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80077a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80077d:	50                   	push   %eax
  80077e:	ff 75 08             	pushl  0x8(%ebp)
  800781:	e8 0b fc ff ff       	call   800391 <fd_lookup>
  800786:	83 c4 10             	add    $0x10,%esp
  800789:	85 c0                	test   %eax,%eax
  80078b:	78 0e                	js     80079b <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80078d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800790:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800793:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800796:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80079d:	f3 0f 1e fb          	endbr32 
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	53                   	push   %ebx
  8007a5:	83 ec 1c             	sub    $0x1c,%esp
  8007a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ae:	50                   	push   %eax
  8007af:	53                   	push   %ebx
  8007b0:	e8 dc fb ff ff       	call   800391 <fd_lookup>
  8007b5:	83 c4 10             	add    $0x10,%esp
  8007b8:	85 c0                	test   %eax,%eax
  8007ba:	78 37                	js     8007f3 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007bc:	83 ec 08             	sub    $0x8,%esp
  8007bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c2:	50                   	push   %eax
  8007c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c6:	ff 30                	pushl  (%eax)
  8007c8:	e8 18 fc ff ff       	call   8003e5 <dev_lookup>
  8007cd:	83 c4 10             	add    $0x10,%esp
  8007d0:	85 c0                	test   %eax,%eax
  8007d2:	78 1f                	js     8007f3 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007db:	74 1b                	je     8007f8 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007e0:	8b 52 18             	mov    0x18(%edx),%edx
  8007e3:	85 d2                	test   %edx,%edx
  8007e5:	74 32                	je     800819 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007e7:	83 ec 08             	sub    $0x8,%esp
  8007ea:	ff 75 0c             	pushl  0xc(%ebp)
  8007ed:	50                   	push   %eax
  8007ee:	ff d2                	call   *%edx
  8007f0:	83 c4 10             	add    $0x10,%esp
}
  8007f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007f8:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007fd:	8b 40 48             	mov    0x48(%eax),%eax
  800800:	83 ec 04             	sub    $0x4,%esp
  800803:	53                   	push   %ebx
  800804:	50                   	push   %eax
  800805:	68 38 1e 80 00       	push   $0x801e38
  80080a:	e8 4e 09 00 00       	call   80115d <cprintf>
		return -E_INVAL;
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800817:	eb da                	jmp    8007f3 <ftruncate+0x56>
		return -E_NOT_SUPP;
  800819:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80081e:	eb d3                	jmp    8007f3 <ftruncate+0x56>

00800820 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800820:	f3 0f 1e fb          	endbr32 
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	53                   	push   %ebx
  800828:	83 ec 1c             	sub    $0x1c,%esp
  80082b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80082e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800831:	50                   	push   %eax
  800832:	ff 75 08             	pushl  0x8(%ebp)
  800835:	e8 57 fb ff ff       	call   800391 <fd_lookup>
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	85 c0                	test   %eax,%eax
  80083f:	78 4b                	js     80088c <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084b:	ff 30                	pushl  (%eax)
  80084d:	e8 93 fb ff ff       	call   8003e5 <dev_lookup>
  800852:	83 c4 10             	add    $0x10,%esp
  800855:	85 c0                	test   %eax,%eax
  800857:	78 33                	js     80088c <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800859:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800860:	74 2f                	je     800891 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800862:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800865:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80086c:	00 00 00 
	stat->st_isdir = 0;
  80086f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800876:	00 00 00 
	stat->st_dev = dev;
  800879:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80087f:	83 ec 08             	sub    $0x8,%esp
  800882:	53                   	push   %ebx
  800883:	ff 75 f0             	pushl  -0x10(%ebp)
  800886:	ff 50 14             	call   *0x14(%eax)
  800889:	83 c4 10             	add    $0x10,%esp
}
  80088c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088f:	c9                   	leave  
  800890:	c3                   	ret    
		return -E_NOT_SUPP;
  800891:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800896:	eb f4                	jmp    80088c <fstat+0x6c>

00800898 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800898:	f3 0f 1e fb          	endbr32 
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	56                   	push   %esi
  8008a0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	6a 00                	push   $0x0
  8008a6:	ff 75 08             	pushl  0x8(%ebp)
  8008a9:	e8 20 02 00 00       	call   800ace <open>
  8008ae:	89 c3                	mov    %eax,%ebx
  8008b0:	83 c4 10             	add    $0x10,%esp
  8008b3:	85 c0                	test   %eax,%eax
  8008b5:	78 1b                	js     8008d2 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008b7:	83 ec 08             	sub    $0x8,%esp
  8008ba:	ff 75 0c             	pushl  0xc(%ebp)
  8008bd:	50                   	push   %eax
  8008be:	e8 5d ff ff ff       	call   800820 <fstat>
  8008c3:	89 c6                	mov    %eax,%esi
	close(fd);
  8008c5:	89 1c 24             	mov    %ebx,(%esp)
  8008c8:	e8 fd fb ff ff       	call   8004ca <close>
	return r;
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	89 f3                	mov    %esi,%ebx
}
  8008d2:	89 d8                	mov    %ebx,%eax
  8008d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008d7:	5b                   	pop    %ebx
  8008d8:	5e                   	pop    %esi
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	89 c6                	mov    %eax,%esi
  8008e2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008e4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008eb:	74 27                	je     800914 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008ed:	6a 07                	push   $0x7
  8008ef:	68 00 50 80 00       	push   $0x805000
  8008f4:	56                   	push   %esi
  8008f5:	ff 35 00 40 80 00    	pushl  0x804000
  8008fb:	e8 a8 11 00 00       	call   801aa8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800900:	83 c4 0c             	add    $0xc,%esp
  800903:	6a 00                	push   $0x0
  800905:	53                   	push   %ebx
  800906:	6a 00                	push   $0x0
  800908:	e8 2e 11 00 00       	call   801a3b <ipc_recv>
}
  80090d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800914:	83 ec 0c             	sub    $0xc,%esp
  800917:	6a 01                	push   $0x1
  800919:	e8 dd 11 00 00       	call   801afb <ipc_find_env>
  80091e:	a3 00 40 80 00       	mov    %eax,0x804000
  800923:	83 c4 10             	add    $0x10,%esp
  800926:	eb c5                	jmp    8008ed <fsipc+0x12>

00800928 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800928:	f3 0f 1e fb          	endbr32 
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	8b 40 0c             	mov    0xc(%eax),%eax
  800938:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80093d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800940:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800945:	ba 00 00 00 00       	mov    $0x0,%edx
  80094a:	b8 02 00 00 00       	mov    $0x2,%eax
  80094f:	e8 87 ff ff ff       	call   8008db <fsipc>
}
  800954:	c9                   	leave  
  800955:	c3                   	ret    

00800956 <devfile_flush>:
{
  800956:	f3 0f 1e fb          	endbr32 
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8b 40 0c             	mov    0xc(%eax),%eax
  800966:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80096b:	ba 00 00 00 00       	mov    $0x0,%edx
  800970:	b8 06 00 00 00       	mov    $0x6,%eax
  800975:	e8 61 ff ff ff       	call   8008db <fsipc>
}
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <devfile_stat>:
{
  80097c:	f3 0f 1e fb          	endbr32 
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	53                   	push   %ebx
  800984:	83 ec 04             	sub    $0x4,%esp
  800987:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 40 0c             	mov    0xc(%eax),%eax
  800990:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800995:	ba 00 00 00 00       	mov    $0x0,%edx
  80099a:	b8 05 00 00 00       	mov    $0x5,%eax
  80099f:	e8 37 ff ff ff       	call   8008db <fsipc>
  8009a4:	85 c0                	test   %eax,%eax
  8009a6:	78 2c                	js     8009d4 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009a8:	83 ec 08             	sub    $0x8,%esp
  8009ab:	68 00 50 80 00       	push   $0x805000
  8009b0:	53                   	push   %ebx
  8009b1:	e8 11 0d 00 00       	call   8016c7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b6:	a1 80 50 80 00       	mov    0x805080,%eax
  8009bb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c1:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009cc:	83 c4 10             	add    $0x10,%esp
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <devfile_write>:
{
  8009d9:	f3 0f 1e fb          	endbr32 
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	57                   	push   %edi
  8009e1:	56                   	push   %esi
  8009e2:	53                   	push   %ebx
  8009e3:	83 ec 0c             	sub    $0xc,%esp
  8009e6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f2:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  8009f7:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8009fc:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  800a01:	85 db                	test   %ebx,%ebx
  800a03:	74 3b                	je     800a40 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a05:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800a0b:	89 f8                	mov    %edi,%eax
  800a0d:	0f 46 c3             	cmovbe %ebx,%eax
  800a10:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  800a15:	83 ec 04             	sub    $0x4,%esp
  800a18:	50                   	push   %eax
  800a19:	56                   	push   %esi
  800a1a:	68 08 50 80 00       	push   $0x805008
  800a1f:	e8 5b 0e 00 00       	call   80187f <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800a24:	ba 00 00 00 00       	mov    $0x0,%edx
  800a29:	b8 04 00 00 00       	mov    $0x4,%eax
  800a2e:	e8 a8 fe ff ff       	call   8008db <fsipc>
  800a33:	83 c4 10             	add    $0x10,%esp
  800a36:	85 c0                	test   %eax,%eax
  800a38:	78 06                	js     800a40 <devfile_write+0x67>
		buf_aux += r;
  800a3a:	01 c6                	add    %eax,%esi
		n -= r;
  800a3c:	29 c3                	sub    %eax,%ebx
  800a3e:	eb c1                	jmp    800a01 <devfile_write+0x28>
}
  800a40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a43:	5b                   	pop    %ebx
  800a44:	5e                   	pop    %esi
  800a45:	5f                   	pop    %edi
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <devfile_read>:
{
  800a48:	f3 0f 1e fb          	endbr32 
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	56                   	push   %esi
  800a50:	53                   	push   %ebx
  800a51:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	8b 40 0c             	mov    0xc(%eax),%eax
  800a5a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a5f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a65:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a6f:	e8 67 fe ff ff       	call   8008db <fsipc>
  800a74:	89 c3                	mov    %eax,%ebx
  800a76:	85 c0                	test   %eax,%eax
  800a78:	78 1f                	js     800a99 <devfile_read+0x51>
	assert(r <= n);
  800a7a:	39 f0                	cmp    %esi,%eax
  800a7c:	77 24                	ja     800aa2 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a7e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a83:	7f 33                	jg     800ab8 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a85:	83 ec 04             	sub    $0x4,%esp
  800a88:	50                   	push   %eax
  800a89:	68 00 50 80 00       	push   $0x805000
  800a8e:	ff 75 0c             	pushl  0xc(%ebp)
  800a91:	e8 e9 0d 00 00       	call   80187f <memmove>
	return r;
  800a96:	83 c4 10             	add    $0x10,%esp
}
  800a99:	89 d8                	mov    %ebx,%eax
  800a9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    
	assert(r <= n);
  800aa2:	68 a4 1e 80 00       	push   $0x801ea4
  800aa7:	68 ab 1e 80 00       	push   $0x801eab
  800aac:	6a 7c                	push   $0x7c
  800aae:	68 c0 1e 80 00       	push   $0x801ec0
  800ab3:	e8 be 05 00 00       	call   801076 <_panic>
	assert(r <= PGSIZE);
  800ab8:	68 cb 1e 80 00       	push   $0x801ecb
  800abd:	68 ab 1e 80 00       	push   $0x801eab
  800ac2:	6a 7d                	push   $0x7d
  800ac4:	68 c0 1e 80 00       	push   $0x801ec0
  800ac9:	e8 a8 05 00 00       	call   801076 <_panic>

00800ace <open>:
{
  800ace:	f3 0f 1e fb          	endbr32 
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	56                   	push   %esi
  800ad6:	53                   	push   %ebx
  800ad7:	83 ec 1c             	sub    $0x1c,%esp
  800ada:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800add:	56                   	push   %esi
  800ade:	e8 a1 0b 00 00       	call   801684 <strlen>
  800ae3:	83 c4 10             	add    $0x10,%esp
  800ae6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aeb:	7f 6c                	jg     800b59 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800aed:	83 ec 0c             	sub    $0xc,%esp
  800af0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af3:	50                   	push   %eax
  800af4:	e8 42 f8 ff ff       	call   80033b <fd_alloc>
  800af9:	89 c3                	mov    %eax,%ebx
  800afb:	83 c4 10             	add    $0x10,%esp
  800afe:	85 c0                	test   %eax,%eax
  800b00:	78 3c                	js     800b3e <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b02:	83 ec 08             	sub    $0x8,%esp
  800b05:	56                   	push   %esi
  800b06:	68 00 50 80 00       	push   $0x805000
  800b0b:	e8 b7 0b 00 00       	call   8016c7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b13:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b18:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	e8 b6 fd ff ff       	call   8008db <fsipc>
  800b25:	89 c3                	mov    %eax,%ebx
  800b27:	83 c4 10             	add    $0x10,%esp
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	78 19                	js     800b47 <open+0x79>
	return fd2num(fd);
  800b2e:	83 ec 0c             	sub    $0xc,%esp
  800b31:	ff 75 f4             	pushl  -0xc(%ebp)
  800b34:	e8 cf f7 ff ff       	call   800308 <fd2num>
  800b39:	89 c3                	mov    %eax,%ebx
  800b3b:	83 c4 10             	add    $0x10,%esp
}
  800b3e:	89 d8                	mov    %ebx,%eax
  800b40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    
		fd_close(fd, 0);
  800b47:	83 ec 08             	sub    $0x8,%esp
  800b4a:	6a 00                	push   $0x0
  800b4c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4f:	e8 eb f8 ff ff       	call   80043f <fd_close>
		return r;
  800b54:	83 c4 10             	add    $0x10,%esp
  800b57:	eb e5                	jmp    800b3e <open+0x70>
		return -E_BAD_PATH;
  800b59:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b5e:	eb de                	jmp    800b3e <open+0x70>

00800b60 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b60:	f3 0f 1e fb          	endbr32 
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6f:	b8 08 00 00 00       	mov    $0x8,%eax
  800b74:	e8 62 fd ff ff       	call   8008db <fsipc>
}
  800b79:	c9                   	leave  
  800b7a:	c3                   	ret    

00800b7b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b7b:	f3 0f 1e fb          	endbr32 
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b87:	83 ec 0c             	sub    $0xc,%esp
  800b8a:	ff 75 08             	pushl  0x8(%ebp)
  800b8d:	e8 8a f7 ff ff       	call   80031c <fd2data>
  800b92:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b94:	83 c4 08             	add    $0x8,%esp
  800b97:	68 d7 1e 80 00       	push   $0x801ed7
  800b9c:	53                   	push   %ebx
  800b9d:	e8 25 0b 00 00       	call   8016c7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ba2:	8b 46 04             	mov    0x4(%esi),%eax
  800ba5:	2b 06                	sub    (%esi),%eax
  800ba7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bb4:	00 00 00 
	stat->st_dev = &devpipe;
  800bb7:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bbe:	30 80 00 
	return 0;
}
  800bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bcd:	f3 0f 1e fb          	endbr32 
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	53                   	push   %ebx
  800bd5:	83 ec 0c             	sub    $0xc,%esp
  800bd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bdb:	53                   	push   %ebx
  800bdc:	6a 00                	push   $0x0
  800bde:	e8 3a f6 ff ff       	call   80021d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800be3:	89 1c 24             	mov    %ebx,(%esp)
  800be6:	e8 31 f7 ff ff       	call   80031c <fd2data>
  800beb:	83 c4 08             	add    $0x8,%esp
  800bee:	50                   	push   %eax
  800bef:	6a 00                	push   $0x0
  800bf1:	e8 27 f6 ff ff       	call   80021d <sys_page_unmap>
}
  800bf6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf9:	c9                   	leave  
  800bfa:	c3                   	ret    

00800bfb <_pipeisclosed>:
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 1c             	sub    $0x1c,%esp
  800c04:	89 c7                	mov    %eax,%edi
  800c06:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c08:	a1 04 40 80 00       	mov    0x804004,%eax
  800c0d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c10:	83 ec 0c             	sub    $0xc,%esp
  800c13:	57                   	push   %edi
  800c14:	e8 1f 0f 00 00       	call   801b38 <pageref>
  800c19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c1c:	89 34 24             	mov    %esi,(%esp)
  800c1f:	e8 14 0f 00 00       	call   801b38 <pageref>
		nn = thisenv->env_runs;
  800c24:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c2a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c2d:	83 c4 10             	add    $0x10,%esp
  800c30:	39 cb                	cmp    %ecx,%ebx
  800c32:	74 1b                	je     800c4f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c34:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c37:	75 cf                	jne    800c08 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c39:	8b 42 58             	mov    0x58(%edx),%eax
  800c3c:	6a 01                	push   $0x1
  800c3e:	50                   	push   %eax
  800c3f:	53                   	push   %ebx
  800c40:	68 de 1e 80 00       	push   $0x801ede
  800c45:	e8 13 05 00 00       	call   80115d <cprintf>
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	eb b9                	jmp    800c08 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c4f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c52:	0f 94 c0             	sete   %al
  800c55:	0f b6 c0             	movzbl %al,%eax
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <devpipe_write>:
{
  800c60:	f3 0f 1e fb          	endbr32 
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	83 ec 28             	sub    $0x28,%esp
  800c6d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c70:	56                   	push   %esi
  800c71:	e8 a6 f6 ff ff       	call   80031c <fd2data>
  800c76:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c78:	83 c4 10             	add    $0x10,%esp
  800c7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c80:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c83:	74 4f                	je     800cd4 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c85:	8b 43 04             	mov    0x4(%ebx),%eax
  800c88:	8b 0b                	mov    (%ebx),%ecx
  800c8a:	8d 51 20             	lea    0x20(%ecx),%edx
  800c8d:	39 d0                	cmp    %edx,%eax
  800c8f:	72 14                	jb     800ca5 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800c91:	89 da                	mov    %ebx,%edx
  800c93:	89 f0                	mov    %esi,%eax
  800c95:	e8 61 ff ff ff       	call   800bfb <_pipeisclosed>
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	75 3b                	jne    800cd9 <devpipe_write+0x79>
			sys_yield();
  800c9e:	e8 fd f4 ff ff       	call   8001a0 <sys_yield>
  800ca3:	eb e0                	jmp    800c85 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ca5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cac:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800caf:	89 c2                	mov    %eax,%edx
  800cb1:	c1 fa 1f             	sar    $0x1f,%edx
  800cb4:	89 d1                	mov    %edx,%ecx
  800cb6:	c1 e9 1b             	shr    $0x1b,%ecx
  800cb9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cbc:	83 e2 1f             	and    $0x1f,%edx
  800cbf:	29 ca                	sub    %ecx,%edx
  800cc1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cc5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cc9:	83 c0 01             	add    $0x1,%eax
  800ccc:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800ccf:	83 c7 01             	add    $0x1,%edi
  800cd2:	eb ac                	jmp    800c80 <devpipe_write+0x20>
	return i;
  800cd4:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd7:	eb 05                	jmp    800cde <devpipe_write+0x7e>
				return 0;
  800cd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <devpipe_read>:
{
  800ce6:	f3 0f 1e fb          	endbr32 
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 18             	sub    $0x18,%esp
  800cf3:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cf6:	57                   	push   %edi
  800cf7:	e8 20 f6 ff ff       	call   80031c <fd2data>
  800cfc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cfe:	83 c4 10             	add    $0x10,%esp
  800d01:	be 00 00 00 00       	mov    $0x0,%esi
  800d06:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d09:	75 14                	jne    800d1f <devpipe_read+0x39>
	return i;
  800d0b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d0e:	eb 02                	jmp    800d12 <devpipe_read+0x2c>
				return i;
  800d10:	89 f0                	mov    %esi,%eax
}
  800d12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    
			sys_yield();
  800d1a:	e8 81 f4 ff ff       	call   8001a0 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d1f:	8b 03                	mov    (%ebx),%eax
  800d21:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d24:	75 18                	jne    800d3e <devpipe_read+0x58>
			if (i > 0)
  800d26:	85 f6                	test   %esi,%esi
  800d28:	75 e6                	jne    800d10 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d2a:	89 da                	mov    %ebx,%edx
  800d2c:	89 f8                	mov    %edi,%eax
  800d2e:	e8 c8 fe ff ff       	call   800bfb <_pipeisclosed>
  800d33:	85 c0                	test   %eax,%eax
  800d35:	74 e3                	je     800d1a <devpipe_read+0x34>
				return 0;
  800d37:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3c:	eb d4                	jmp    800d12 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d3e:	99                   	cltd   
  800d3f:	c1 ea 1b             	shr    $0x1b,%edx
  800d42:	01 d0                	add    %edx,%eax
  800d44:	83 e0 1f             	and    $0x1f,%eax
  800d47:	29 d0                	sub    %edx,%eax
  800d49:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d51:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d54:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d57:	83 c6 01             	add    $0x1,%esi
  800d5a:	eb aa                	jmp    800d06 <devpipe_read+0x20>

00800d5c <pipe>:
{
  800d5c:	f3 0f 1e fb          	endbr32 
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d6b:	50                   	push   %eax
  800d6c:	e8 ca f5 ff ff       	call   80033b <fd_alloc>
  800d71:	89 c3                	mov    %eax,%ebx
  800d73:	83 c4 10             	add    $0x10,%esp
  800d76:	85 c0                	test   %eax,%eax
  800d78:	0f 88 23 01 00 00    	js     800ea1 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7e:	83 ec 04             	sub    $0x4,%esp
  800d81:	68 07 04 00 00       	push   $0x407
  800d86:	ff 75 f4             	pushl  -0xc(%ebp)
  800d89:	6a 00                	push   $0x0
  800d8b:	e8 3b f4 ff ff       	call   8001cb <sys_page_alloc>
  800d90:	89 c3                	mov    %eax,%ebx
  800d92:	83 c4 10             	add    $0x10,%esp
  800d95:	85 c0                	test   %eax,%eax
  800d97:	0f 88 04 01 00 00    	js     800ea1 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800d9d:	83 ec 0c             	sub    $0xc,%esp
  800da0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800da3:	50                   	push   %eax
  800da4:	e8 92 f5 ff ff       	call   80033b <fd_alloc>
  800da9:	89 c3                	mov    %eax,%ebx
  800dab:	83 c4 10             	add    $0x10,%esp
  800dae:	85 c0                	test   %eax,%eax
  800db0:	0f 88 db 00 00 00    	js     800e91 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db6:	83 ec 04             	sub    $0x4,%esp
  800db9:	68 07 04 00 00       	push   $0x407
  800dbe:	ff 75 f0             	pushl  -0x10(%ebp)
  800dc1:	6a 00                	push   $0x0
  800dc3:	e8 03 f4 ff ff       	call   8001cb <sys_page_alloc>
  800dc8:	89 c3                	mov    %eax,%ebx
  800dca:	83 c4 10             	add    $0x10,%esp
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	0f 88 bc 00 00 00    	js     800e91 <pipe+0x135>
	va = fd2data(fd0);
  800dd5:	83 ec 0c             	sub    $0xc,%esp
  800dd8:	ff 75 f4             	pushl  -0xc(%ebp)
  800ddb:	e8 3c f5 ff ff       	call   80031c <fd2data>
  800de0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de2:	83 c4 0c             	add    $0xc,%esp
  800de5:	68 07 04 00 00       	push   $0x407
  800dea:	50                   	push   %eax
  800deb:	6a 00                	push   $0x0
  800ded:	e8 d9 f3 ff ff       	call   8001cb <sys_page_alloc>
  800df2:	89 c3                	mov    %eax,%ebx
  800df4:	83 c4 10             	add    $0x10,%esp
  800df7:	85 c0                	test   %eax,%eax
  800df9:	0f 88 82 00 00 00    	js     800e81 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dff:	83 ec 0c             	sub    $0xc,%esp
  800e02:	ff 75 f0             	pushl  -0x10(%ebp)
  800e05:	e8 12 f5 ff ff       	call   80031c <fd2data>
  800e0a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e11:	50                   	push   %eax
  800e12:	6a 00                	push   $0x0
  800e14:	56                   	push   %esi
  800e15:	6a 00                	push   $0x0
  800e17:	e8 d7 f3 ff ff       	call   8001f3 <sys_page_map>
  800e1c:	89 c3                	mov    %eax,%ebx
  800e1e:	83 c4 20             	add    $0x20,%esp
  800e21:	85 c0                	test   %eax,%eax
  800e23:	78 4e                	js     800e73 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e25:	a1 20 30 80 00       	mov    0x803020,%eax
  800e2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e2d:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e32:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e39:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e3c:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e41:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e48:	83 ec 0c             	sub    $0xc,%esp
  800e4b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e4e:	e8 b5 f4 ff ff       	call   800308 <fd2num>
  800e53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e56:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e58:	83 c4 04             	add    $0x4,%esp
  800e5b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e5e:	e8 a5 f4 ff ff       	call   800308 <fd2num>
  800e63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e66:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e69:	83 c4 10             	add    $0x10,%esp
  800e6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e71:	eb 2e                	jmp    800ea1 <pipe+0x145>
	sys_page_unmap(0, va);
  800e73:	83 ec 08             	sub    $0x8,%esp
  800e76:	56                   	push   %esi
  800e77:	6a 00                	push   $0x0
  800e79:	e8 9f f3 ff ff       	call   80021d <sys_page_unmap>
  800e7e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e81:	83 ec 08             	sub    $0x8,%esp
  800e84:	ff 75 f0             	pushl  -0x10(%ebp)
  800e87:	6a 00                	push   $0x0
  800e89:	e8 8f f3 ff ff       	call   80021d <sys_page_unmap>
  800e8e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e91:	83 ec 08             	sub    $0x8,%esp
  800e94:	ff 75 f4             	pushl  -0xc(%ebp)
  800e97:	6a 00                	push   $0x0
  800e99:	e8 7f f3 ff ff       	call   80021d <sys_page_unmap>
  800e9e:	83 c4 10             	add    $0x10,%esp
}
  800ea1:	89 d8                	mov    %ebx,%eax
  800ea3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea6:	5b                   	pop    %ebx
  800ea7:	5e                   	pop    %esi
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <pipeisclosed>:
{
  800eaa:	f3 0f 1e fb          	endbr32 
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb7:	50                   	push   %eax
  800eb8:	ff 75 08             	pushl  0x8(%ebp)
  800ebb:	e8 d1 f4 ff ff       	call   800391 <fd_lookup>
  800ec0:	83 c4 10             	add    $0x10,%esp
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	78 18                	js     800edf <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800ec7:	83 ec 0c             	sub    $0xc,%esp
  800eca:	ff 75 f4             	pushl  -0xc(%ebp)
  800ecd:	e8 4a f4 ff ff       	call   80031c <fd2data>
  800ed2:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed7:	e8 1f fd ff ff       	call   800bfb <_pipeisclosed>
  800edc:	83 c4 10             	add    $0x10,%esp
}
  800edf:	c9                   	leave  
  800ee0:	c3                   	ret    

00800ee1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ee1:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800ee5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eea:	c3                   	ret    

00800eeb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eeb:	f3 0f 1e fb          	endbr32 
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ef5:	68 f6 1e 80 00       	push   $0x801ef6
  800efa:	ff 75 0c             	pushl  0xc(%ebp)
  800efd:	e8 c5 07 00 00       	call   8016c7 <strcpy>
	return 0;
}
  800f02:	b8 00 00 00 00       	mov    $0x0,%eax
  800f07:	c9                   	leave  
  800f08:	c3                   	ret    

00800f09 <devcons_write>:
{
  800f09:	f3 0f 1e fb          	endbr32 
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	57                   	push   %edi
  800f11:	56                   	push   %esi
  800f12:	53                   	push   %ebx
  800f13:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f19:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f1e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f24:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f27:	73 31                	jae    800f5a <devcons_write+0x51>
		m = n - tot;
  800f29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2c:	29 f3                	sub    %esi,%ebx
  800f2e:	83 fb 7f             	cmp    $0x7f,%ebx
  800f31:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f36:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f39:	83 ec 04             	sub    $0x4,%esp
  800f3c:	53                   	push   %ebx
  800f3d:	89 f0                	mov    %esi,%eax
  800f3f:	03 45 0c             	add    0xc(%ebp),%eax
  800f42:	50                   	push   %eax
  800f43:	57                   	push   %edi
  800f44:	e8 36 09 00 00       	call   80187f <memmove>
		sys_cputs(buf, m);
  800f49:	83 c4 08             	add    $0x8,%esp
  800f4c:	53                   	push   %ebx
  800f4d:	57                   	push   %edi
  800f4e:	e8 ad f1 ff ff       	call   800100 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f53:	01 de                	add    %ebx,%esi
  800f55:	83 c4 10             	add    $0x10,%esp
  800f58:	eb ca                	jmp    800f24 <devcons_write+0x1b>
}
  800f5a:	89 f0                	mov    %esi,%eax
  800f5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5f:	5b                   	pop    %ebx
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <devcons_read>:
{
  800f64:	f3 0f 1e fb          	endbr32 
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	83 ec 08             	sub    $0x8,%esp
  800f6e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f73:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f77:	74 21                	je     800f9a <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800f79:	e8 ac f1 ff ff       	call   80012a <sys_cgetc>
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	75 07                	jne    800f89 <devcons_read+0x25>
		sys_yield();
  800f82:	e8 19 f2 ff ff       	call   8001a0 <sys_yield>
  800f87:	eb f0                	jmp    800f79 <devcons_read+0x15>
	if (c < 0)
  800f89:	78 0f                	js     800f9a <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800f8b:	83 f8 04             	cmp    $0x4,%eax
  800f8e:	74 0c                	je     800f9c <devcons_read+0x38>
	*(char*)vbuf = c;
  800f90:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f93:	88 02                	mov    %al,(%edx)
	return 1;
  800f95:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f9a:	c9                   	leave  
  800f9b:	c3                   	ret    
		return 0;
  800f9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa1:	eb f7                	jmp    800f9a <devcons_read+0x36>

00800fa3 <cputchar>:
{
  800fa3:	f3 0f 1e fb          	endbr32 
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fad:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb0:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800fb3:	6a 01                	push   $0x1
  800fb5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb8:	50                   	push   %eax
  800fb9:	e8 42 f1 ff ff       	call   800100 <sys_cputs>
}
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	c9                   	leave  
  800fc2:	c3                   	ret    

00800fc3 <getchar>:
{
  800fc3:	f3 0f 1e fb          	endbr32 
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800fcd:	6a 01                	push   $0x1
  800fcf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd2:	50                   	push   %eax
  800fd3:	6a 00                	push   $0x0
  800fd5:	e8 3a f6 ff ff       	call   800614 <read>
	if (r < 0)
  800fda:	83 c4 10             	add    $0x10,%esp
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	78 06                	js     800fe7 <getchar+0x24>
	if (r < 1)
  800fe1:	74 06                	je     800fe9 <getchar+0x26>
	return c;
  800fe3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fe7:	c9                   	leave  
  800fe8:	c3                   	ret    
		return -E_EOF;
  800fe9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fee:	eb f7                	jmp    800fe7 <getchar+0x24>

00800ff0 <iscons>:
{
  800ff0:	f3 0f 1e fb          	endbr32 
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ffa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffd:	50                   	push   %eax
  800ffe:	ff 75 08             	pushl  0x8(%ebp)
  801001:	e8 8b f3 ff ff       	call   800391 <fd_lookup>
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	78 11                	js     80101e <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80100d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801010:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801016:	39 10                	cmp    %edx,(%eax)
  801018:	0f 94 c0             	sete   %al
  80101b:	0f b6 c0             	movzbl %al,%eax
}
  80101e:	c9                   	leave  
  80101f:	c3                   	ret    

00801020 <opencons>:
{
  801020:	f3 0f 1e fb          	endbr32 
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80102a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102d:	50                   	push   %eax
  80102e:	e8 08 f3 ff ff       	call   80033b <fd_alloc>
  801033:	83 c4 10             	add    $0x10,%esp
  801036:	85 c0                	test   %eax,%eax
  801038:	78 3a                	js     801074 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80103a:	83 ec 04             	sub    $0x4,%esp
  80103d:	68 07 04 00 00       	push   $0x407
  801042:	ff 75 f4             	pushl  -0xc(%ebp)
  801045:	6a 00                	push   $0x0
  801047:	e8 7f f1 ff ff       	call   8001cb <sys_page_alloc>
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	78 21                	js     801074 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801053:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801056:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80105c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80105e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801061:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801068:	83 ec 0c             	sub    $0xc,%esp
  80106b:	50                   	push   %eax
  80106c:	e8 97 f2 ff ff       	call   800308 <fd2num>
  801071:	83 c4 10             	add    $0x10,%esp
}
  801074:	c9                   	leave  
  801075:	c3                   	ret    

00801076 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801076:	f3 0f 1e fb          	endbr32 
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	56                   	push   %esi
  80107e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80107f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801082:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801088:	e8 eb f0 ff ff       	call   800178 <sys_getenvid>
  80108d:	83 ec 0c             	sub    $0xc,%esp
  801090:	ff 75 0c             	pushl  0xc(%ebp)
  801093:	ff 75 08             	pushl  0x8(%ebp)
  801096:	56                   	push   %esi
  801097:	50                   	push   %eax
  801098:	68 04 1f 80 00       	push   $0x801f04
  80109d:	e8 bb 00 00 00       	call   80115d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010a2:	83 c4 18             	add    $0x18,%esp
  8010a5:	53                   	push   %ebx
  8010a6:	ff 75 10             	pushl  0x10(%ebp)
  8010a9:	e8 5a 00 00 00       	call   801108 <vcprintf>
	cprintf("\n");
  8010ae:	c7 04 24 ef 1e 80 00 	movl   $0x801eef,(%esp)
  8010b5:	e8 a3 00 00 00       	call   80115d <cprintf>
  8010ba:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010bd:	cc                   	int3   
  8010be:	eb fd                	jmp    8010bd <_panic+0x47>

008010c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010c0:	f3 0f 1e fb          	endbr32 
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	53                   	push   %ebx
  8010c8:	83 ec 04             	sub    $0x4,%esp
  8010cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010ce:	8b 13                	mov    (%ebx),%edx
  8010d0:	8d 42 01             	lea    0x1(%edx),%eax
  8010d3:	89 03                	mov    %eax,(%ebx)
  8010d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010dc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010e1:	74 09                	je     8010ec <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010e3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ea:	c9                   	leave  
  8010eb:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010ec:	83 ec 08             	sub    $0x8,%esp
  8010ef:	68 ff 00 00 00       	push   $0xff
  8010f4:	8d 43 08             	lea    0x8(%ebx),%eax
  8010f7:	50                   	push   %eax
  8010f8:	e8 03 f0 ff ff       	call   800100 <sys_cputs>
		b->idx = 0;
  8010fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801103:	83 c4 10             	add    $0x10,%esp
  801106:	eb db                	jmp    8010e3 <putch+0x23>

00801108 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801108:	f3 0f 1e fb          	endbr32 
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801115:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80111c:	00 00 00 
	b.cnt = 0;
  80111f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801126:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801129:	ff 75 0c             	pushl  0xc(%ebp)
  80112c:	ff 75 08             	pushl  0x8(%ebp)
  80112f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801135:	50                   	push   %eax
  801136:	68 c0 10 80 00       	push   $0x8010c0
  80113b:	e8 80 01 00 00       	call   8012c0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801140:	83 c4 08             	add    $0x8,%esp
  801143:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801149:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80114f:	50                   	push   %eax
  801150:	e8 ab ef ff ff       	call   800100 <sys_cputs>

	return b.cnt;
}
  801155:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80115b:	c9                   	leave  
  80115c:	c3                   	ret    

0080115d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80115d:	f3 0f 1e fb          	endbr32 
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801167:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80116a:	50                   	push   %eax
  80116b:	ff 75 08             	pushl  0x8(%ebp)
  80116e:	e8 95 ff ff ff       	call   801108 <vcprintf>
	va_end(ap);

	return cnt;
}
  801173:	c9                   	leave  
  801174:	c3                   	ret    

00801175 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	57                   	push   %edi
  801179:	56                   	push   %esi
  80117a:	53                   	push   %ebx
  80117b:	83 ec 1c             	sub    $0x1c,%esp
  80117e:	89 c7                	mov    %eax,%edi
  801180:	89 d6                	mov    %edx,%esi
  801182:	8b 45 08             	mov    0x8(%ebp),%eax
  801185:	8b 55 0c             	mov    0xc(%ebp),%edx
  801188:	89 d1                	mov    %edx,%ecx
  80118a:	89 c2                	mov    %eax,%edx
  80118c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80118f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801192:	8b 45 10             	mov    0x10(%ebp),%eax
  801195:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801198:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80119b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011a2:	39 c2                	cmp    %eax,%edx
  8011a4:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011a7:	72 3e                	jb     8011e7 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011a9:	83 ec 0c             	sub    $0xc,%esp
  8011ac:	ff 75 18             	pushl  0x18(%ebp)
  8011af:	83 eb 01             	sub    $0x1,%ebx
  8011b2:	53                   	push   %ebx
  8011b3:	50                   	push   %eax
  8011b4:	83 ec 08             	sub    $0x8,%esp
  8011b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8011bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c3:	e8 b8 09 00 00       	call   801b80 <__udivdi3>
  8011c8:	83 c4 18             	add    $0x18,%esp
  8011cb:	52                   	push   %edx
  8011cc:	50                   	push   %eax
  8011cd:	89 f2                	mov    %esi,%edx
  8011cf:	89 f8                	mov    %edi,%eax
  8011d1:	e8 9f ff ff ff       	call   801175 <printnum>
  8011d6:	83 c4 20             	add    $0x20,%esp
  8011d9:	eb 13                	jmp    8011ee <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011db:	83 ec 08             	sub    $0x8,%esp
  8011de:	56                   	push   %esi
  8011df:	ff 75 18             	pushl  0x18(%ebp)
  8011e2:	ff d7                	call   *%edi
  8011e4:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011e7:	83 eb 01             	sub    $0x1,%ebx
  8011ea:	85 db                	test   %ebx,%ebx
  8011ec:	7f ed                	jg     8011db <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011ee:	83 ec 08             	sub    $0x8,%esp
  8011f1:	56                   	push   %esi
  8011f2:	83 ec 04             	sub    $0x4,%esp
  8011f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8011fb:	ff 75 dc             	pushl  -0x24(%ebp)
  8011fe:	ff 75 d8             	pushl  -0x28(%ebp)
  801201:	e8 8a 0a 00 00       	call   801c90 <__umoddi3>
  801206:	83 c4 14             	add    $0x14,%esp
  801209:	0f be 80 27 1f 80 00 	movsbl 0x801f27(%eax),%eax
  801210:	50                   	push   %eax
  801211:	ff d7                	call   *%edi
}
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801219:	5b                   	pop    %ebx
  80121a:	5e                   	pop    %esi
  80121b:	5f                   	pop    %edi
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    

0080121e <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80121e:	83 fa 01             	cmp    $0x1,%edx
  801221:	7f 13                	jg     801236 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801223:	85 d2                	test   %edx,%edx
  801225:	74 1c                	je     801243 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  801227:	8b 10                	mov    (%eax),%edx
  801229:	8d 4a 04             	lea    0x4(%edx),%ecx
  80122c:	89 08                	mov    %ecx,(%eax)
  80122e:	8b 02                	mov    (%edx),%eax
  801230:	ba 00 00 00 00       	mov    $0x0,%edx
  801235:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  801236:	8b 10                	mov    (%eax),%edx
  801238:	8d 4a 08             	lea    0x8(%edx),%ecx
  80123b:	89 08                	mov    %ecx,(%eax)
  80123d:	8b 02                	mov    (%edx),%eax
  80123f:	8b 52 04             	mov    0x4(%edx),%edx
  801242:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  801243:	8b 10                	mov    (%eax),%edx
  801245:	8d 4a 04             	lea    0x4(%edx),%ecx
  801248:	89 08                	mov    %ecx,(%eax)
  80124a:	8b 02                	mov    (%edx),%eax
  80124c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801251:	c3                   	ret    

00801252 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801252:	83 fa 01             	cmp    $0x1,%edx
  801255:	7f 0f                	jg     801266 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  801257:	85 d2                	test   %edx,%edx
  801259:	74 18                	je     801273 <getint+0x21>
		return va_arg(*ap, long);
  80125b:	8b 10                	mov    (%eax),%edx
  80125d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801260:	89 08                	mov    %ecx,(%eax)
  801262:	8b 02                	mov    (%edx),%eax
  801264:	99                   	cltd   
  801265:	c3                   	ret    
		return va_arg(*ap, long long);
  801266:	8b 10                	mov    (%eax),%edx
  801268:	8d 4a 08             	lea    0x8(%edx),%ecx
  80126b:	89 08                	mov    %ecx,(%eax)
  80126d:	8b 02                	mov    (%edx),%eax
  80126f:	8b 52 04             	mov    0x4(%edx),%edx
  801272:	c3                   	ret    
	else
		return va_arg(*ap, int);
  801273:	8b 10                	mov    (%eax),%edx
  801275:	8d 4a 04             	lea    0x4(%edx),%ecx
  801278:	89 08                	mov    %ecx,(%eax)
  80127a:	8b 02                	mov    (%edx),%eax
  80127c:	99                   	cltd   
}
  80127d:	c3                   	ret    

0080127e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80127e:	f3 0f 1e fb          	endbr32 
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801288:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80128c:	8b 10                	mov    (%eax),%edx
  80128e:	3b 50 04             	cmp    0x4(%eax),%edx
  801291:	73 0a                	jae    80129d <sprintputch+0x1f>
		*b->buf++ = ch;
  801293:	8d 4a 01             	lea    0x1(%edx),%ecx
  801296:	89 08                	mov    %ecx,(%eax)
  801298:	8b 45 08             	mov    0x8(%ebp),%eax
  80129b:	88 02                	mov    %al,(%edx)
}
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    

0080129f <printfmt>:
{
  80129f:	f3 0f 1e fb          	endbr32 
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012a9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012ac:	50                   	push   %eax
  8012ad:	ff 75 10             	pushl  0x10(%ebp)
  8012b0:	ff 75 0c             	pushl  0xc(%ebp)
  8012b3:	ff 75 08             	pushl  0x8(%ebp)
  8012b6:	e8 05 00 00 00       	call   8012c0 <vprintfmt>
}
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	c9                   	leave  
  8012bf:	c3                   	ret    

008012c0 <vprintfmt>:
{
  8012c0:	f3 0f 1e fb          	endbr32 
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	57                   	push   %edi
  8012c8:	56                   	push   %esi
  8012c9:	53                   	push   %ebx
  8012ca:	83 ec 2c             	sub    $0x2c,%esp
  8012cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012d3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012d6:	e9 86 02 00 00       	jmp    801561 <vprintfmt+0x2a1>
		padc = ' ';
  8012db:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012df:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012e6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012ed:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012f4:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012f9:	8d 47 01             	lea    0x1(%edi),%eax
  8012fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012ff:	0f b6 17             	movzbl (%edi),%edx
  801302:	8d 42 dd             	lea    -0x23(%edx),%eax
  801305:	3c 55                	cmp    $0x55,%al
  801307:	0f 87 df 02 00 00    	ja     8015ec <vprintfmt+0x32c>
  80130d:	0f b6 c0             	movzbl %al,%eax
  801310:	3e ff 24 85 60 20 80 	notrack jmp *0x802060(,%eax,4)
  801317:	00 
  801318:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80131b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80131f:	eb d8                	jmp    8012f9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801321:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801324:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801328:	eb cf                	jmp    8012f9 <vprintfmt+0x39>
  80132a:	0f b6 d2             	movzbl %dl,%edx
  80132d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801330:	b8 00 00 00 00       	mov    $0x0,%eax
  801335:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801338:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80133b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80133f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801342:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801345:	83 f9 09             	cmp    $0x9,%ecx
  801348:	77 52                	ja     80139c <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  80134a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80134d:	eb e9                	jmp    801338 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80134f:	8b 45 14             	mov    0x14(%ebp),%eax
  801352:	8d 50 04             	lea    0x4(%eax),%edx
  801355:	89 55 14             	mov    %edx,0x14(%ebp)
  801358:	8b 00                	mov    (%eax),%eax
  80135a:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80135d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801360:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801364:	79 93                	jns    8012f9 <vprintfmt+0x39>
				width = precision, precision = -1;
  801366:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801369:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80136c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801373:	eb 84                	jmp    8012f9 <vprintfmt+0x39>
  801375:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801378:	85 c0                	test   %eax,%eax
  80137a:	ba 00 00 00 00       	mov    $0x0,%edx
  80137f:	0f 49 d0             	cmovns %eax,%edx
  801382:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801388:	e9 6c ff ff ff       	jmp    8012f9 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80138d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801390:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801397:	e9 5d ff ff ff       	jmp    8012f9 <vprintfmt+0x39>
  80139c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80139f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8013a2:	eb bc                	jmp    801360 <vprintfmt+0xa0>
			lflag++;
  8013a4:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8013a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013aa:	e9 4a ff ff ff       	jmp    8012f9 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013af:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b2:	8d 50 04             	lea    0x4(%eax),%edx
  8013b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8013b8:	83 ec 08             	sub    $0x8,%esp
  8013bb:	56                   	push   %esi
  8013bc:	ff 30                	pushl  (%eax)
  8013be:	ff d3                	call   *%ebx
			break;
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	e9 96 01 00 00       	jmp    80155e <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8013c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8013cb:	8d 50 04             	lea    0x4(%eax),%edx
  8013ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8013d1:	8b 00                	mov    (%eax),%eax
  8013d3:	99                   	cltd   
  8013d4:	31 d0                	xor    %edx,%eax
  8013d6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013d8:	83 f8 0f             	cmp    $0xf,%eax
  8013db:	7f 20                	jg     8013fd <vprintfmt+0x13d>
  8013dd:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  8013e4:	85 d2                	test   %edx,%edx
  8013e6:	74 15                	je     8013fd <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8013e8:	52                   	push   %edx
  8013e9:	68 bd 1e 80 00       	push   $0x801ebd
  8013ee:	56                   	push   %esi
  8013ef:	53                   	push   %ebx
  8013f0:	e8 aa fe ff ff       	call   80129f <printfmt>
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	e9 61 01 00 00       	jmp    80155e <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8013fd:	50                   	push   %eax
  8013fe:	68 3f 1f 80 00       	push   $0x801f3f
  801403:	56                   	push   %esi
  801404:	53                   	push   %ebx
  801405:	e8 95 fe ff ff       	call   80129f <printfmt>
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	e9 4c 01 00 00       	jmp    80155e <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  801412:	8b 45 14             	mov    0x14(%ebp),%eax
  801415:	8d 50 04             	lea    0x4(%eax),%edx
  801418:	89 55 14             	mov    %edx,0x14(%ebp)
  80141b:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80141d:	85 c9                	test   %ecx,%ecx
  80141f:	b8 38 1f 80 00       	mov    $0x801f38,%eax
  801424:	0f 45 c1             	cmovne %ecx,%eax
  801427:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80142a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80142e:	7e 06                	jle    801436 <vprintfmt+0x176>
  801430:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801434:	75 0d                	jne    801443 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  801436:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801439:	89 c7                	mov    %eax,%edi
  80143b:	03 45 e0             	add    -0x20(%ebp),%eax
  80143e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801441:	eb 57                	jmp    80149a <vprintfmt+0x1da>
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	ff 75 d8             	pushl  -0x28(%ebp)
  801449:	ff 75 cc             	pushl  -0x34(%ebp)
  80144c:	e8 4f 02 00 00       	call   8016a0 <strnlen>
  801451:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801454:	29 c2                	sub    %eax,%edx
  801456:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801459:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80145c:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801460:	89 5d 08             	mov    %ebx,0x8(%ebp)
  801463:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  801465:	85 db                	test   %ebx,%ebx
  801467:	7e 10                	jle    801479 <vprintfmt+0x1b9>
					putch(padc, putdat);
  801469:	83 ec 08             	sub    $0x8,%esp
  80146c:	56                   	push   %esi
  80146d:	57                   	push   %edi
  80146e:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801471:	83 eb 01             	sub    $0x1,%ebx
  801474:	83 c4 10             	add    $0x10,%esp
  801477:	eb ec                	jmp    801465 <vprintfmt+0x1a5>
  801479:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80147c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80147f:	85 d2                	test   %edx,%edx
  801481:	b8 00 00 00 00       	mov    $0x0,%eax
  801486:	0f 49 c2             	cmovns %edx,%eax
  801489:	29 c2                	sub    %eax,%edx
  80148b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80148e:	eb a6                	jmp    801436 <vprintfmt+0x176>
					putch(ch, putdat);
  801490:	83 ec 08             	sub    $0x8,%esp
  801493:	56                   	push   %esi
  801494:	52                   	push   %edx
  801495:	ff d3                	call   *%ebx
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80149d:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80149f:	83 c7 01             	add    $0x1,%edi
  8014a2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014a6:	0f be d0             	movsbl %al,%edx
  8014a9:	85 d2                	test   %edx,%edx
  8014ab:	74 42                	je     8014ef <vprintfmt+0x22f>
  8014ad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014b1:	78 06                	js     8014b9 <vprintfmt+0x1f9>
  8014b3:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014b7:	78 1e                	js     8014d7 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8014b9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014bd:	74 d1                	je     801490 <vprintfmt+0x1d0>
  8014bf:	0f be c0             	movsbl %al,%eax
  8014c2:	83 e8 20             	sub    $0x20,%eax
  8014c5:	83 f8 5e             	cmp    $0x5e,%eax
  8014c8:	76 c6                	jbe    801490 <vprintfmt+0x1d0>
					putch('?', putdat);
  8014ca:	83 ec 08             	sub    $0x8,%esp
  8014cd:	56                   	push   %esi
  8014ce:	6a 3f                	push   $0x3f
  8014d0:	ff d3                	call   *%ebx
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	eb c3                	jmp    80149a <vprintfmt+0x1da>
  8014d7:	89 cf                	mov    %ecx,%edi
  8014d9:	eb 0e                	jmp    8014e9 <vprintfmt+0x229>
				putch(' ', putdat);
  8014db:	83 ec 08             	sub    $0x8,%esp
  8014de:	56                   	push   %esi
  8014df:	6a 20                	push   $0x20
  8014e1:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8014e3:	83 ef 01             	sub    $0x1,%edi
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	85 ff                	test   %edi,%edi
  8014eb:	7f ee                	jg     8014db <vprintfmt+0x21b>
  8014ed:	eb 6f                	jmp    80155e <vprintfmt+0x29e>
  8014ef:	89 cf                	mov    %ecx,%edi
  8014f1:	eb f6                	jmp    8014e9 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8014f3:	89 ca                	mov    %ecx,%edx
  8014f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8014f8:	e8 55 fd ff ff       	call   801252 <getint>
  8014fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801500:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  801503:	85 d2                	test   %edx,%edx
  801505:	78 0b                	js     801512 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  801507:	89 d1                	mov    %edx,%ecx
  801509:	89 c2                	mov    %eax,%edx
			base = 10;
  80150b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801510:	eb 32                	jmp    801544 <vprintfmt+0x284>
				putch('-', putdat);
  801512:	83 ec 08             	sub    $0x8,%esp
  801515:	56                   	push   %esi
  801516:	6a 2d                	push   $0x2d
  801518:	ff d3                	call   *%ebx
				num = -(long long) num;
  80151a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80151d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801520:	f7 da                	neg    %edx
  801522:	83 d1 00             	adc    $0x0,%ecx
  801525:	f7 d9                	neg    %ecx
  801527:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80152a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80152f:	eb 13                	jmp    801544 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  801531:	89 ca                	mov    %ecx,%edx
  801533:	8d 45 14             	lea    0x14(%ebp),%eax
  801536:	e8 e3 fc ff ff       	call   80121e <getuint>
  80153b:	89 d1                	mov    %edx,%ecx
  80153d:	89 c2                	mov    %eax,%edx
			base = 10;
  80153f:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  801544:	83 ec 0c             	sub    $0xc,%esp
  801547:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80154b:	57                   	push   %edi
  80154c:	ff 75 e0             	pushl  -0x20(%ebp)
  80154f:	50                   	push   %eax
  801550:	51                   	push   %ecx
  801551:	52                   	push   %edx
  801552:	89 f2                	mov    %esi,%edx
  801554:	89 d8                	mov    %ebx,%eax
  801556:	e8 1a fc ff ff       	call   801175 <printnum>
			break;
  80155b:	83 c4 20             	add    $0x20,%esp
{
  80155e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801561:	83 c7 01             	add    $0x1,%edi
  801564:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801568:	83 f8 25             	cmp    $0x25,%eax
  80156b:	0f 84 6a fd ff ff    	je     8012db <vprintfmt+0x1b>
			if (ch == '\0')
  801571:	85 c0                	test   %eax,%eax
  801573:	0f 84 93 00 00 00    	je     80160c <vprintfmt+0x34c>
			putch(ch, putdat);
  801579:	83 ec 08             	sub    $0x8,%esp
  80157c:	56                   	push   %esi
  80157d:	50                   	push   %eax
  80157e:	ff d3                	call   *%ebx
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	eb dc                	jmp    801561 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  801585:	89 ca                	mov    %ecx,%edx
  801587:	8d 45 14             	lea    0x14(%ebp),%eax
  80158a:	e8 8f fc ff ff       	call   80121e <getuint>
  80158f:	89 d1                	mov    %edx,%ecx
  801591:	89 c2                	mov    %eax,%edx
			base = 8;
  801593:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801598:	eb aa                	jmp    801544 <vprintfmt+0x284>
			putch('0', putdat);
  80159a:	83 ec 08             	sub    $0x8,%esp
  80159d:	56                   	push   %esi
  80159e:	6a 30                	push   $0x30
  8015a0:	ff d3                	call   *%ebx
			putch('x', putdat);
  8015a2:	83 c4 08             	add    $0x8,%esp
  8015a5:	56                   	push   %esi
  8015a6:	6a 78                	push   $0x78
  8015a8:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8015aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ad:	8d 50 04             	lea    0x4(%eax),%edx
  8015b0:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8015b3:	8b 10                	mov    (%eax),%edx
  8015b5:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015ba:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8015bd:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015c2:	eb 80                	jmp    801544 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8015c4:	89 ca                	mov    %ecx,%edx
  8015c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8015c9:	e8 50 fc ff ff       	call   80121e <getuint>
  8015ce:	89 d1                	mov    %edx,%ecx
  8015d0:	89 c2                	mov    %eax,%edx
			base = 16;
  8015d2:	b8 10 00 00 00       	mov    $0x10,%eax
  8015d7:	e9 68 ff ff ff       	jmp    801544 <vprintfmt+0x284>
			putch(ch, putdat);
  8015dc:	83 ec 08             	sub    $0x8,%esp
  8015df:	56                   	push   %esi
  8015e0:	6a 25                	push   $0x25
  8015e2:	ff d3                	call   *%ebx
			break;
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	e9 72 ff ff ff       	jmp    80155e <vprintfmt+0x29e>
			putch('%', putdat);
  8015ec:	83 ec 08             	sub    $0x8,%esp
  8015ef:	56                   	push   %esi
  8015f0:	6a 25                	push   $0x25
  8015f2:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	89 f8                	mov    %edi,%eax
  8015f9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015fd:	74 05                	je     801604 <vprintfmt+0x344>
  8015ff:	83 e8 01             	sub    $0x1,%eax
  801602:	eb f5                	jmp    8015f9 <vprintfmt+0x339>
  801604:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801607:	e9 52 ff ff ff       	jmp    80155e <vprintfmt+0x29e>
}
  80160c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160f:	5b                   	pop    %ebx
  801610:	5e                   	pop    %esi
  801611:	5f                   	pop    %edi
  801612:	5d                   	pop    %ebp
  801613:	c3                   	ret    

00801614 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801614:	f3 0f 1e fb          	endbr32 
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	83 ec 18             	sub    $0x18,%esp
  80161e:	8b 45 08             	mov    0x8(%ebp),%eax
  801621:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801624:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801627:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80162b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80162e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801635:	85 c0                	test   %eax,%eax
  801637:	74 26                	je     80165f <vsnprintf+0x4b>
  801639:	85 d2                	test   %edx,%edx
  80163b:	7e 22                	jle    80165f <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80163d:	ff 75 14             	pushl  0x14(%ebp)
  801640:	ff 75 10             	pushl  0x10(%ebp)
  801643:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801646:	50                   	push   %eax
  801647:	68 7e 12 80 00       	push   $0x80127e
  80164c:	e8 6f fc ff ff       	call   8012c0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801651:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801654:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801657:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165a:	83 c4 10             	add    $0x10,%esp
}
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    
		return -E_INVAL;
  80165f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801664:	eb f7                	jmp    80165d <vsnprintf+0x49>

00801666 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801666:	f3 0f 1e fb          	endbr32 
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801670:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801673:	50                   	push   %eax
  801674:	ff 75 10             	pushl  0x10(%ebp)
  801677:	ff 75 0c             	pushl  0xc(%ebp)
  80167a:	ff 75 08             	pushl  0x8(%ebp)
  80167d:	e8 92 ff ff ff       	call   801614 <vsnprintf>
	va_end(ap);

	return rc;
}
  801682:	c9                   	leave  
  801683:	c3                   	ret    

00801684 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801684:	f3 0f 1e fb          	endbr32 
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80168e:	b8 00 00 00 00       	mov    $0x0,%eax
  801693:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801697:	74 05                	je     80169e <strlen+0x1a>
		n++;
  801699:	83 c0 01             	add    $0x1,%eax
  80169c:	eb f5                	jmp    801693 <strlen+0xf>
	return n;
}
  80169e:	5d                   	pop    %ebp
  80169f:	c3                   	ret    

008016a0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016a0:	f3 0f 1e fb          	endbr32 
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b2:	39 d0                	cmp    %edx,%eax
  8016b4:	74 0d                	je     8016c3 <strnlen+0x23>
  8016b6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016ba:	74 05                	je     8016c1 <strnlen+0x21>
		n++;
  8016bc:	83 c0 01             	add    $0x1,%eax
  8016bf:	eb f1                	jmp    8016b2 <strnlen+0x12>
  8016c1:	89 c2                	mov    %eax,%edx
	return n;
}
  8016c3:	89 d0                	mov    %edx,%eax
  8016c5:	5d                   	pop    %ebp
  8016c6:	c3                   	ret    

008016c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016c7:	f3 0f 1e fb          	endbr32 
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	53                   	push   %ebx
  8016cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8016da:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016de:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016e1:	83 c0 01             	add    $0x1,%eax
  8016e4:	84 d2                	test   %dl,%dl
  8016e6:	75 f2                	jne    8016da <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8016e8:	89 c8                	mov    %ecx,%eax
  8016ea:	5b                   	pop    %ebx
  8016eb:	5d                   	pop    %ebp
  8016ec:	c3                   	ret    

008016ed <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016ed:	f3 0f 1e fb          	endbr32 
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 10             	sub    $0x10,%esp
  8016f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016fb:	53                   	push   %ebx
  8016fc:	e8 83 ff ff ff       	call   801684 <strlen>
  801701:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801704:	ff 75 0c             	pushl  0xc(%ebp)
  801707:	01 d8                	add    %ebx,%eax
  801709:	50                   	push   %eax
  80170a:	e8 b8 ff ff ff       	call   8016c7 <strcpy>
	return dst;
}
  80170f:	89 d8                	mov    %ebx,%eax
  801711:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801714:	c9                   	leave  
  801715:	c3                   	ret    

00801716 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801716:	f3 0f 1e fb          	endbr32 
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	56                   	push   %esi
  80171e:	53                   	push   %ebx
  80171f:	8b 75 08             	mov    0x8(%ebp),%esi
  801722:	8b 55 0c             	mov    0xc(%ebp),%edx
  801725:	89 f3                	mov    %esi,%ebx
  801727:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80172a:	89 f0                	mov    %esi,%eax
  80172c:	39 d8                	cmp    %ebx,%eax
  80172e:	74 11                	je     801741 <strncpy+0x2b>
		*dst++ = *src;
  801730:	83 c0 01             	add    $0x1,%eax
  801733:	0f b6 0a             	movzbl (%edx),%ecx
  801736:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801739:	80 f9 01             	cmp    $0x1,%cl
  80173c:	83 da ff             	sbb    $0xffffffff,%edx
  80173f:	eb eb                	jmp    80172c <strncpy+0x16>
	}
	return ret;
}
  801741:	89 f0                	mov    %esi,%eax
  801743:	5b                   	pop    %ebx
  801744:	5e                   	pop    %esi
  801745:	5d                   	pop    %ebp
  801746:	c3                   	ret    

00801747 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801747:	f3 0f 1e fb          	endbr32 
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	56                   	push   %esi
  80174f:	53                   	push   %ebx
  801750:	8b 75 08             	mov    0x8(%ebp),%esi
  801753:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801756:	8b 55 10             	mov    0x10(%ebp),%edx
  801759:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80175b:	85 d2                	test   %edx,%edx
  80175d:	74 21                	je     801780 <strlcpy+0x39>
  80175f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801763:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801765:	39 c2                	cmp    %eax,%edx
  801767:	74 14                	je     80177d <strlcpy+0x36>
  801769:	0f b6 19             	movzbl (%ecx),%ebx
  80176c:	84 db                	test   %bl,%bl
  80176e:	74 0b                	je     80177b <strlcpy+0x34>
			*dst++ = *src++;
  801770:	83 c1 01             	add    $0x1,%ecx
  801773:	83 c2 01             	add    $0x1,%edx
  801776:	88 5a ff             	mov    %bl,-0x1(%edx)
  801779:	eb ea                	jmp    801765 <strlcpy+0x1e>
  80177b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80177d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801780:	29 f0                	sub    %esi,%eax
}
  801782:	5b                   	pop    %ebx
  801783:	5e                   	pop    %esi
  801784:	5d                   	pop    %ebp
  801785:	c3                   	ret    

00801786 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801786:	f3 0f 1e fb          	endbr32 
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801790:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801793:	0f b6 01             	movzbl (%ecx),%eax
  801796:	84 c0                	test   %al,%al
  801798:	74 0c                	je     8017a6 <strcmp+0x20>
  80179a:	3a 02                	cmp    (%edx),%al
  80179c:	75 08                	jne    8017a6 <strcmp+0x20>
		p++, q++;
  80179e:	83 c1 01             	add    $0x1,%ecx
  8017a1:	83 c2 01             	add    $0x1,%edx
  8017a4:	eb ed                	jmp    801793 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a6:	0f b6 c0             	movzbl %al,%eax
  8017a9:	0f b6 12             	movzbl (%edx),%edx
  8017ac:	29 d0                	sub    %edx,%eax
}
  8017ae:	5d                   	pop    %ebp
  8017af:	c3                   	ret    

008017b0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017b0:	f3 0f 1e fb          	endbr32 
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	53                   	push   %ebx
  8017b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017be:	89 c3                	mov    %eax,%ebx
  8017c0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017c3:	eb 06                	jmp    8017cb <strncmp+0x1b>
		n--, p++, q++;
  8017c5:	83 c0 01             	add    $0x1,%eax
  8017c8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017cb:	39 d8                	cmp    %ebx,%eax
  8017cd:	74 16                	je     8017e5 <strncmp+0x35>
  8017cf:	0f b6 08             	movzbl (%eax),%ecx
  8017d2:	84 c9                	test   %cl,%cl
  8017d4:	74 04                	je     8017da <strncmp+0x2a>
  8017d6:	3a 0a                	cmp    (%edx),%cl
  8017d8:	74 eb                	je     8017c5 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017da:	0f b6 00             	movzbl (%eax),%eax
  8017dd:	0f b6 12             	movzbl (%edx),%edx
  8017e0:	29 d0                	sub    %edx,%eax
}
  8017e2:	5b                   	pop    %ebx
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    
		return 0;
  8017e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ea:	eb f6                	jmp    8017e2 <strncmp+0x32>

008017ec <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017ec:	f3 0f 1e fb          	endbr32 
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017fa:	0f b6 10             	movzbl (%eax),%edx
  8017fd:	84 d2                	test   %dl,%dl
  8017ff:	74 09                	je     80180a <strchr+0x1e>
		if (*s == c)
  801801:	38 ca                	cmp    %cl,%dl
  801803:	74 0a                	je     80180f <strchr+0x23>
	for (; *s; s++)
  801805:	83 c0 01             	add    $0x1,%eax
  801808:	eb f0                	jmp    8017fa <strchr+0xe>
			return (char *) s;
	return 0;
  80180a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180f:	5d                   	pop    %ebp
  801810:	c3                   	ret    

00801811 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801811:	f3 0f 1e fb          	endbr32 
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
  80181b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80181f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801822:	38 ca                	cmp    %cl,%dl
  801824:	74 09                	je     80182f <strfind+0x1e>
  801826:	84 d2                	test   %dl,%dl
  801828:	74 05                	je     80182f <strfind+0x1e>
	for (; *s; s++)
  80182a:	83 c0 01             	add    $0x1,%eax
  80182d:	eb f0                	jmp    80181f <strfind+0xe>
			break;
	return (char *) s;
}
  80182f:	5d                   	pop    %ebp
  801830:	c3                   	ret    

00801831 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801831:	f3 0f 1e fb          	endbr32 
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
  801838:	57                   	push   %edi
  801839:	56                   	push   %esi
  80183a:	53                   	push   %ebx
  80183b:	8b 55 08             	mov    0x8(%ebp),%edx
  80183e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  801841:	85 c9                	test   %ecx,%ecx
  801843:	74 33                	je     801878 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801845:	89 d0                	mov    %edx,%eax
  801847:	09 c8                	or     %ecx,%eax
  801849:	a8 03                	test   $0x3,%al
  80184b:	75 23                	jne    801870 <memset+0x3f>
		c &= 0xFF;
  80184d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801851:	89 d8                	mov    %ebx,%eax
  801853:	c1 e0 08             	shl    $0x8,%eax
  801856:	89 df                	mov    %ebx,%edi
  801858:	c1 e7 18             	shl    $0x18,%edi
  80185b:	89 de                	mov    %ebx,%esi
  80185d:	c1 e6 10             	shl    $0x10,%esi
  801860:	09 f7                	or     %esi,%edi
  801862:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  801864:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801867:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  801869:	89 d7                	mov    %edx,%edi
  80186b:	fc                   	cld    
  80186c:	f3 ab                	rep stos %eax,%es:(%edi)
  80186e:	eb 08                	jmp    801878 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801870:	89 d7                	mov    %edx,%edi
  801872:	8b 45 0c             	mov    0xc(%ebp),%eax
  801875:	fc                   	cld    
  801876:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  801878:	89 d0                	mov    %edx,%eax
  80187a:	5b                   	pop    %ebx
  80187b:	5e                   	pop    %esi
  80187c:	5f                   	pop    %edi
  80187d:	5d                   	pop    %ebp
  80187e:	c3                   	ret    

0080187f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80187f:	f3 0f 1e fb          	endbr32 
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	57                   	push   %edi
  801887:	56                   	push   %esi
  801888:	8b 45 08             	mov    0x8(%ebp),%eax
  80188b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80188e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801891:	39 c6                	cmp    %eax,%esi
  801893:	73 32                	jae    8018c7 <memmove+0x48>
  801895:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801898:	39 c2                	cmp    %eax,%edx
  80189a:	76 2b                	jbe    8018c7 <memmove+0x48>
		s += n;
		d += n;
  80189c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80189f:	89 fe                	mov    %edi,%esi
  8018a1:	09 ce                	or     %ecx,%esi
  8018a3:	09 d6                	or     %edx,%esi
  8018a5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018ab:	75 0e                	jne    8018bb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018ad:	83 ef 04             	sub    $0x4,%edi
  8018b0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018b3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018b6:	fd                   	std    
  8018b7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b9:	eb 09                	jmp    8018c4 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018bb:	83 ef 01             	sub    $0x1,%edi
  8018be:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018c1:	fd                   	std    
  8018c2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018c4:	fc                   	cld    
  8018c5:	eb 1a                	jmp    8018e1 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c7:	89 c2                	mov    %eax,%edx
  8018c9:	09 ca                	or     %ecx,%edx
  8018cb:	09 f2                	or     %esi,%edx
  8018cd:	f6 c2 03             	test   $0x3,%dl
  8018d0:	75 0a                	jne    8018dc <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018d2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018d5:	89 c7                	mov    %eax,%edi
  8018d7:	fc                   	cld    
  8018d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018da:	eb 05                	jmp    8018e1 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8018dc:	89 c7                	mov    %eax,%edi
  8018de:	fc                   	cld    
  8018df:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018e1:	5e                   	pop    %esi
  8018e2:	5f                   	pop    %edi
  8018e3:	5d                   	pop    %ebp
  8018e4:	c3                   	ret    

008018e5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018e5:	f3 0f 1e fb          	endbr32 
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018ef:	ff 75 10             	pushl  0x10(%ebp)
  8018f2:	ff 75 0c             	pushl  0xc(%ebp)
  8018f5:	ff 75 08             	pushl  0x8(%ebp)
  8018f8:	e8 82 ff ff ff       	call   80187f <memmove>
}
  8018fd:	c9                   	leave  
  8018fe:	c3                   	ret    

008018ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ff:	f3 0f 1e fb          	endbr32 
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	56                   	push   %esi
  801907:	53                   	push   %ebx
  801908:	8b 45 08             	mov    0x8(%ebp),%eax
  80190b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80190e:	89 c6                	mov    %eax,%esi
  801910:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801913:	39 f0                	cmp    %esi,%eax
  801915:	74 1c                	je     801933 <memcmp+0x34>
		if (*s1 != *s2)
  801917:	0f b6 08             	movzbl (%eax),%ecx
  80191a:	0f b6 1a             	movzbl (%edx),%ebx
  80191d:	38 d9                	cmp    %bl,%cl
  80191f:	75 08                	jne    801929 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801921:	83 c0 01             	add    $0x1,%eax
  801924:	83 c2 01             	add    $0x1,%edx
  801927:	eb ea                	jmp    801913 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801929:	0f b6 c1             	movzbl %cl,%eax
  80192c:	0f b6 db             	movzbl %bl,%ebx
  80192f:	29 d8                	sub    %ebx,%eax
  801931:	eb 05                	jmp    801938 <memcmp+0x39>
	}

	return 0;
  801933:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801938:	5b                   	pop    %ebx
  801939:	5e                   	pop    %esi
  80193a:	5d                   	pop    %ebp
  80193b:	c3                   	ret    

0080193c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80193c:	f3 0f 1e fb          	endbr32 
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	8b 45 08             	mov    0x8(%ebp),%eax
  801946:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801949:	89 c2                	mov    %eax,%edx
  80194b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80194e:	39 d0                	cmp    %edx,%eax
  801950:	73 09                	jae    80195b <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801952:	38 08                	cmp    %cl,(%eax)
  801954:	74 05                	je     80195b <memfind+0x1f>
	for (; s < ends; s++)
  801956:	83 c0 01             	add    $0x1,%eax
  801959:	eb f3                	jmp    80194e <memfind+0x12>
			break;
	return (void *) s;
}
  80195b:	5d                   	pop    %ebp
  80195c:	c3                   	ret    

0080195d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80195d:	f3 0f 1e fb          	endbr32 
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	57                   	push   %edi
  801965:	56                   	push   %esi
  801966:	53                   	push   %ebx
  801967:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80196a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80196d:	eb 03                	jmp    801972 <strtol+0x15>
		s++;
  80196f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801972:	0f b6 01             	movzbl (%ecx),%eax
  801975:	3c 20                	cmp    $0x20,%al
  801977:	74 f6                	je     80196f <strtol+0x12>
  801979:	3c 09                	cmp    $0x9,%al
  80197b:	74 f2                	je     80196f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  80197d:	3c 2b                	cmp    $0x2b,%al
  80197f:	74 2a                	je     8019ab <strtol+0x4e>
	int neg = 0;
  801981:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801986:	3c 2d                	cmp    $0x2d,%al
  801988:	74 2b                	je     8019b5 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80198a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801990:	75 0f                	jne    8019a1 <strtol+0x44>
  801992:	80 39 30             	cmpb   $0x30,(%ecx)
  801995:	74 28                	je     8019bf <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801997:	85 db                	test   %ebx,%ebx
  801999:	b8 0a 00 00 00       	mov    $0xa,%eax
  80199e:	0f 44 d8             	cmove  %eax,%ebx
  8019a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a6:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019a9:	eb 46                	jmp    8019f1 <strtol+0x94>
		s++;
  8019ab:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019ae:	bf 00 00 00 00       	mov    $0x0,%edi
  8019b3:	eb d5                	jmp    80198a <strtol+0x2d>
		s++, neg = 1;
  8019b5:	83 c1 01             	add    $0x1,%ecx
  8019b8:	bf 01 00 00 00       	mov    $0x1,%edi
  8019bd:	eb cb                	jmp    80198a <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019bf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019c3:	74 0e                	je     8019d3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019c5:	85 db                	test   %ebx,%ebx
  8019c7:	75 d8                	jne    8019a1 <strtol+0x44>
		s++, base = 8;
  8019c9:	83 c1 01             	add    $0x1,%ecx
  8019cc:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019d1:	eb ce                	jmp    8019a1 <strtol+0x44>
		s += 2, base = 16;
  8019d3:	83 c1 02             	add    $0x2,%ecx
  8019d6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019db:	eb c4                	jmp    8019a1 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019dd:	0f be d2             	movsbl %dl,%edx
  8019e0:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019e3:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019e6:	7d 3a                	jge    801a22 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019e8:	83 c1 01             	add    $0x1,%ecx
  8019eb:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019ef:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019f1:	0f b6 11             	movzbl (%ecx),%edx
  8019f4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019f7:	89 f3                	mov    %esi,%ebx
  8019f9:	80 fb 09             	cmp    $0x9,%bl
  8019fc:	76 df                	jbe    8019dd <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8019fe:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a01:	89 f3                	mov    %esi,%ebx
  801a03:	80 fb 19             	cmp    $0x19,%bl
  801a06:	77 08                	ja     801a10 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a08:	0f be d2             	movsbl %dl,%edx
  801a0b:	83 ea 57             	sub    $0x57,%edx
  801a0e:	eb d3                	jmp    8019e3 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801a10:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a13:	89 f3                	mov    %esi,%ebx
  801a15:	80 fb 19             	cmp    $0x19,%bl
  801a18:	77 08                	ja     801a22 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a1a:	0f be d2             	movsbl %dl,%edx
  801a1d:	83 ea 37             	sub    $0x37,%edx
  801a20:	eb c1                	jmp    8019e3 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a22:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a26:	74 05                	je     801a2d <strtol+0xd0>
		*endptr = (char *) s;
  801a28:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a2b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a2d:	89 c2                	mov    %eax,%edx
  801a2f:	f7 da                	neg    %edx
  801a31:	85 ff                	test   %edi,%edi
  801a33:	0f 45 c2             	cmovne %edx,%eax
}
  801a36:	5b                   	pop    %ebx
  801a37:	5e                   	pop    %esi
  801a38:	5f                   	pop    %edi
  801a39:	5d                   	pop    %ebp
  801a3a:	c3                   	ret    

00801a3b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a3b:	f3 0f 1e fb          	endbr32 
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	56                   	push   %esi
  801a43:	53                   	push   %ebx
  801a44:	8b 75 08             	mov    0x8(%ebp),%esi
  801a47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  801a4d:	85 c0                	test   %eax,%eax
  801a4f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a54:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801a57:	83 ec 0c             	sub    $0xc,%esp
  801a5a:	50                   	push   %eax
  801a5b:	e8 82 e8 ff ff       	call   8002e2 <sys_ipc_recv>
	if (f < 0) {
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	85 c0                	test   %eax,%eax
  801a65:	78 2b                	js     801a92 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801a67:	85 f6                	test   %esi,%esi
  801a69:	74 0a                	je     801a75 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801a6b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a70:	8b 40 74             	mov    0x74(%eax),%eax
  801a73:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801a75:	85 db                	test   %ebx,%ebx
  801a77:	74 0a                	je     801a83 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801a79:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7e:	8b 40 78             	mov    0x78(%eax),%eax
  801a81:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  801a83:	a1 04 40 80 00       	mov    0x804004,%eax
  801a88:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8e:	5b                   	pop    %ebx
  801a8f:	5e                   	pop    %esi
  801a90:	5d                   	pop    %ebp
  801a91:	c3                   	ret    
		if (from_env_store != NULL) {
  801a92:	85 f6                	test   %esi,%esi
  801a94:	74 06                	je     801a9c <ipc_recv+0x61>
			*from_env_store = 0;
  801a96:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801a9c:	85 db                	test   %ebx,%ebx
  801a9e:	74 eb                	je     801a8b <ipc_recv+0x50>
			*perm_store = 0;
  801aa0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aa6:	eb e3                	jmp    801a8b <ipc_recv+0x50>

00801aa8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aa8:	f3 0f 1e fb          	endbr32 
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
  801aaf:	57                   	push   %edi
  801ab0:	56                   	push   %esi
  801ab1:	53                   	push   %ebx
  801ab2:	83 ec 0c             	sub    $0xc,%esp
  801ab5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ab8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801abb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  801abe:	85 db                	test   %ebx,%ebx
  801ac0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ac5:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801ac8:	ff 75 14             	pushl  0x14(%ebp)
  801acb:	53                   	push   %ebx
  801acc:	56                   	push   %esi
  801acd:	57                   	push   %edi
  801ace:	e8 e6 e7 ff ff       	call   8002b9 <sys_ipc_try_send>
  801ad3:	83 c4 10             	add    $0x10,%esp
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	79 19                	jns    801af3 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  801ada:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801add:	74 e9                	je     801ac8 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  801adf:	83 ec 04             	sub    $0x4,%esp
  801ae2:	68 20 22 80 00       	push   $0x802220
  801ae7:	6a 48                	push   $0x48
  801ae9:	68 42 22 80 00       	push   $0x802242
  801aee:	e8 83 f5 ff ff       	call   801076 <_panic>
		}
	}
}
  801af3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	5f                   	pop    %edi
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    

00801afb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801afb:	f3 0f 1e fb          	endbr32 
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b05:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b0a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b0d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b13:	8b 52 50             	mov    0x50(%edx),%edx
  801b16:	39 ca                	cmp    %ecx,%edx
  801b18:	74 11                	je     801b2b <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801b1a:	83 c0 01             	add    $0x1,%eax
  801b1d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b22:	75 e6                	jne    801b0a <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b24:	b8 00 00 00 00       	mov    $0x0,%eax
  801b29:	eb 0b                	jmp    801b36 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b2b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b2e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b33:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b36:	5d                   	pop    %ebp
  801b37:	c3                   	ret    

00801b38 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b38:	f3 0f 1e fb          	endbr32 
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b42:	89 c2                	mov    %eax,%edx
  801b44:	c1 ea 16             	shr    $0x16,%edx
  801b47:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b4e:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b53:	f6 c1 01             	test   $0x1,%cl
  801b56:	74 1c                	je     801b74 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b58:	c1 e8 0c             	shr    $0xc,%eax
  801b5b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b62:	a8 01                	test   $0x1,%al
  801b64:	74 0e                	je     801b74 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b66:	c1 e8 0c             	shr    $0xc,%eax
  801b69:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b70:	ef 
  801b71:	0f b7 d2             	movzwl %dx,%edx
}
  801b74:	89 d0                	mov    %edx,%eax
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    
  801b78:	66 90                	xchg   %ax,%ax
  801b7a:	66 90                	xchg   %ax,%ax
  801b7c:	66 90                	xchg   %ax,%ax
  801b7e:	66 90                	xchg   %ax,%ax

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
