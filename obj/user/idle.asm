
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003d:	c7 05 00 30 80 00 e0 	movl   $0x801de0,0x803000
  800044:	1d 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800047:	e8 57 01 00 00       	call   8001a3 <sys_yield>
  80004c:	eb f9                	jmp    800047 <umain+0x14>

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	f3 0f 1e fb          	endbr32 
  800052:	55                   	push   %ebp
  800053:	89 e5                	mov    %esp,%ebp
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  80005d:	e8 19 01 00 00       	call   80017b <sys_getenvid>
	if (id >= 0)
  800062:	85 c0                	test   %eax,%eax
  800064:	78 12                	js     800078 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800066:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800073:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800078:	85 db                	test   %ebx,%ebx
  80007a:	7e 07                	jle    800083 <libmain+0x35>
		binaryname = argv[0];
  80007c:	8b 06                	mov    (%esi),%eax
  80007e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800083:	83 ec 08             	sub    $0x8,%esp
  800086:	56                   	push   %esi
  800087:	53                   	push   %ebx
  800088:	e8 a6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008d:	e8 0a 00 00 00       	call   80009c <exit>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800098:	5b                   	pop    %ebx
  800099:	5e                   	pop    %esi
  80009a:	5d                   	pop    %ebp
  80009b:	c3                   	ret    

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	f3 0f 1e fb          	endbr32 
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a6:	e8 53 04 00 00       	call   8004fe <close_all>
	sys_env_destroy(0);
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	6a 00                	push   $0x0
  8000b0:	e8 a0 00 00 00       	call   800155 <sys_env_destroy>
}
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	c9                   	leave  
  8000b9:	c3                   	ret    

008000ba <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	57                   	push   %edi
  8000be:	56                   	push   %esi
  8000bf:	53                   	push   %ebx
  8000c0:	83 ec 1c             	sub    $0x1c,%esp
  8000c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000c9:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000d1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000d4:	8b 75 14             	mov    0x14(%ebp),%esi
  8000d7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000dd:	74 04                	je     8000e3 <syscall+0x29>
  8000df:	85 c0                	test   %eax,%eax
  8000e1:	7f 08                	jg     8000eb <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	50                   	push   %eax
  8000ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8000f2:	68 ef 1d 80 00       	push   $0x801def
  8000f7:	6a 23                	push   $0x23
  8000f9:	68 0c 1e 80 00       	push   $0x801e0c
  8000fe:	e8 76 0f 00 00       	call   801079 <_panic>

00800103 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800103:	f3 0f 1e fb          	endbr32 
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80010d:	6a 00                	push   $0x0
  80010f:	6a 00                	push   $0x0
  800111:	6a 00                	push   $0x0
  800113:	ff 75 0c             	pushl  0xc(%ebp)
  800116:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800119:	ba 00 00 00 00       	mov    $0x0,%edx
  80011e:	b8 00 00 00 00       	mov    $0x0,%eax
  800123:	e8 92 ff ff ff       	call   8000ba <syscall>
}
  800128:	83 c4 10             	add    $0x10,%esp
  80012b:	c9                   	leave  
  80012c:	c3                   	ret    

0080012d <sys_cgetc>:

int
sys_cgetc(void)
{
  80012d:	f3 0f 1e fb          	endbr32 
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800137:	6a 00                	push   $0x0
  800139:	6a 00                	push   $0x0
  80013b:	6a 00                	push   $0x0
  80013d:	6a 00                	push   $0x0
  80013f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800144:	ba 00 00 00 00       	mov    $0x0,%edx
  800149:	b8 01 00 00 00       	mov    $0x1,%eax
  80014e:	e8 67 ff ff ff       	call   8000ba <syscall>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800155:	f3 0f 1e fb          	endbr32 
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80015f:	6a 00                	push   $0x0
  800161:	6a 00                	push   $0x0
  800163:	6a 00                	push   $0x0
  800165:	6a 00                	push   $0x0
  800167:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016a:	ba 01 00 00 00       	mov    $0x1,%edx
  80016f:	b8 03 00 00 00       	mov    $0x3,%eax
  800174:	e8 41 ff ff ff       	call   8000ba <syscall>
}
  800179:	c9                   	leave  
  80017a:	c3                   	ret    

0080017b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80017b:	f3 0f 1e fb          	endbr32 
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800185:	6a 00                	push   $0x0
  800187:	6a 00                	push   $0x0
  800189:	6a 00                	push   $0x0
  80018b:	6a 00                	push   $0x0
  80018d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800192:	ba 00 00 00 00       	mov    $0x0,%edx
  800197:	b8 02 00 00 00       	mov    $0x2,%eax
  80019c:	e8 19 ff ff ff       	call   8000ba <syscall>
}
  8001a1:	c9                   	leave  
  8001a2:	c3                   	ret    

008001a3 <sys_yield>:

void
sys_yield(void)
{
  8001a3:	f3 0f 1e fb          	endbr32 
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001ad:	6a 00                	push   $0x0
  8001af:	6a 00                	push   $0x0
  8001b1:	6a 00                	push   $0x0
  8001b3:	6a 00                	push   $0x0
  8001b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8001bf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001c4:	e8 f1 fe ff ff       	call   8000ba <syscall>
}
  8001c9:	83 c4 10             	add    $0x10,%esp
  8001cc:	c9                   	leave  
  8001cd:	c3                   	ret    

008001ce <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001ce:	f3 0f 1e fb          	endbr32 
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001d8:	6a 00                	push   $0x0
  8001da:	6a 00                	push   $0x0
  8001dc:	ff 75 10             	pushl  0x10(%ebp)
  8001df:	ff 75 0c             	pushl  0xc(%ebp)
  8001e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e5:	ba 01 00 00 00       	mov    $0x1,%edx
  8001ea:	b8 04 00 00 00       	mov    $0x4,%eax
  8001ef:	e8 c6 fe ff ff       	call   8000ba <syscall>
}
  8001f4:	c9                   	leave  
  8001f5:	c3                   	ret    

008001f6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001f6:	f3 0f 1e fb          	endbr32 
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800200:	ff 75 18             	pushl  0x18(%ebp)
  800203:	ff 75 14             	pushl  0x14(%ebp)
  800206:	ff 75 10             	pushl  0x10(%ebp)
  800209:	ff 75 0c             	pushl  0xc(%ebp)
  80020c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020f:	ba 01 00 00 00       	mov    $0x1,%edx
  800214:	b8 05 00 00 00       	mov    $0x5,%eax
  800219:	e8 9c fe ff ff       	call   8000ba <syscall>
}
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800220:	f3 0f 1e fb          	endbr32 
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80022a:	6a 00                	push   $0x0
  80022c:	6a 00                	push   $0x0
  80022e:	6a 00                	push   $0x0
  800230:	ff 75 0c             	pushl  0xc(%ebp)
  800233:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800236:	ba 01 00 00 00       	mov    $0x1,%edx
  80023b:	b8 06 00 00 00       	mov    $0x6,%eax
  800240:	e8 75 fe ff ff       	call   8000ba <syscall>
}
  800245:	c9                   	leave  
  800246:	c3                   	ret    

00800247 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800247:	f3 0f 1e fb          	endbr32 
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800251:	6a 00                	push   $0x0
  800253:	6a 00                	push   $0x0
  800255:	6a 00                	push   $0x0
  800257:	ff 75 0c             	pushl  0xc(%ebp)
  80025a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025d:	ba 01 00 00 00       	mov    $0x1,%edx
  800262:	b8 08 00 00 00       	mov    $0x8,%eax
  800267:	e8 4e fe ff ff       	call   8000ba <syscall>
}
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026e:	f3 0f 1e fb          	endbr32 
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800278:	6a 00                	push   $0x0
  80027a:	6a 00                	push   $0x0
  80027c:	6a 00                	push   $0x0
  80027e:	ff 75 0c             	pushl  0xc(%ebp)
  800281:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800284:	ba 01 00 00 00       	mov    $0x1,%edx
  800289:	b8 09 00 00 00       	mov    $0x9,%eax
  80028e:	e8 27 fe ff ff       	call   8000ba <syscall>
}
  800293:	c9                   	leave  
  800294:	c3                   	ret    

00800295 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800295:	f3 0f 1e fb          	endbr32 
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80029f:	6a 00                	push   $0x0
  8002a1:	6a 00                	push   $0x0
  8002a3:	6a 00                	push   $0x0
  8002a5:	ff 75 0c             	pushl  0xc(%ebp)
  8002a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ab:	ba 01 00 00 00       	mov    $0x1,%edx
  8002b0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b5:	e8 00 fe ff ff       	call   8000ba <syscall>
}
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002bc:	f3 0f 1e fb          	endbr32 
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002c6:	6a 00                	push   $0x0
  8002c8:	ff 75 14             	pushl  0x14(%ebp)
  8002cb:	ff 75 10             	pushl  0x10(%ebp)
  8002ce:	ff 75 0c             	pushl  0xc(%ebp)
  8002d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002de:	e8 d7 fd ff ff       	call   8000ba <syscall>
}
  8002e3:	c9                   	leave  
  8002e4:	c3                   	ret    

008002e5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002e5:	f3 0f 1e fb          	endbr32 
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002ef:	6a 00                	push   $0x0
  8002f1:	6a 00                	push   $0x0
  8002f3:	6a 00                	push   $0x0
  8002f5:	6a 00                	push   $0x0
  8002f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002fa:	ba 01 00 00 00       	mov    $0x1,%edx
  8002ff:	b8 0d 00 00 00       	mov    $0xd,%eax
  800304:	e8 b1 fd ff ff       	call   8000ba <syscall>
}
  800309:	c9                   	leave  
  80030a:	c3                   	ret    

0080030b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80030b:	f3 0f 1e fb          	endbr32 
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	05 00 00 00 30       	add    $0x30000000,%eax
  80031a:	c1 e8 0c             	shr    $0xc,%eax
}
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80031f:	f3 0f 1e fb          	endbr32 
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800329:	ff 75 08             	pushl  0x8(%ebp)
  80032c:	e8 da ff ff ff       	call   80030b <fd2num>
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	c1 e0 0c             	shl    $0xc,%eax
  800337:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    

0080033e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80033e:	f3 0f 1e fb          	endbr32 
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80034a:	89 c2                	mov    %eax,%edx
  80034c:	c1 ea 16             	shr    $0x16,%edx
  80034f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800356:	f6 c2 01             	test   $0x1,%dl
  800359:	74 2d                	je     800388 <fd_alloc+0x4a>
  80035b:	89 c2                	mov    %eax,%edx
  80035d:	c1 ea 0c             	shr    $0xc,%edx
  800360:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800367:	f6 c2 01             	test   $0x1,%dl
  80036a:	74 1c                	je     800388 <fd_alloc+0x4a>
  80036c:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800371:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800376:	75 d2                	jne    80034a <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800378:	8b 45 08             	mov    0x8(%ebp),%eax
  80037b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800381:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800386:	eb 0a                	jmp    800392 <fd_alloc+0x54>
			*fd_store = fd;
  800388:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80038d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800392:	5d                   	pop    %ebp
  800393:	c3                   	ret    

00800394 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800394:	f3 0f 1e fb          	endbr32 
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80039e:	83 f8 1f             	cmp    $0x1f,%eax
  8003a1:	77 30                	ja     8003d3 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003a3:	c1 e0 0c             	shl    $0xc,%eax
  8003a6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ab:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003b1:	f6 c2 01             	test   $0x1,%dl
  8003b4:	74 24                	je     8003da <fd_lookup+0x46>
  8003b6:	89 c2                	mov    %eax,%edx
  8003b8:	c1 ea 0c             	shr    $0xc,%edx
  8003bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c2:	f6 c2 01             	test   $0x1,%dl
  8003c5:	74 1a                	je     8003e1 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ca:	89 02                	mov    %eax,(%edx)
	return 0;
  8003cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003d1:	5d                   	pop    %ebp
  8003d2:	c3                   	ret    
		return -E_INVAL;
  8003d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d8:	eb f7                	jmp    8003d1 <fd_lookup+0x3d>
		return -E_INVAL;
  8003da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003df:	eb f0                	jmp    8003d1 <fd_lookup+0x3d>
  8003e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003e6:	eb e9                	jmp    8003d1 <fd_lookup+0x3d>

008003e8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003e8:	f3 0f 1e fb          	endbr32 
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	83 ec 08             	sub    $0x8,%esp
  8003f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f5:	ba 98 1e 80 00       	mov    $0x801e98,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8003fa:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003ff:	39 08                	cmp    %ecx,(%eax)
  800401:	74 33                	je     800436 <dev_lookup+0x4e>
  800403:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800406:	8b 02                	mov    (%edx),%eax
  800408:	85 c0                	test   %eax,%eax
  80040a:	75 f3                	jne    8003ff <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80040c:	a1 04 40 80 00       	mov    0x804004,%eax
  800411:	8b 40 48             	mov    0x48(%eax),%eax
  800414:	83 ec 04             	sub    $0x4,%esp
  800417:	51                   	push   %ecx
  800418:	50                   	push   %eax
  800419:	68 1c 1e 80 00       	push   $0x801e1c
  80041e:	e8 3d 0d 00 00       	call   801160 <cprintf>
	*dev = 0;
  800423:	8b 45 0c             	mov    0xc(%ebp),%eax
  800426:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80042c:	83 c4 10             	add    $0x10,%esp
  80042f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800434:	c9                   	leave  
  800435:	c3                   	ret    
			*dev = devtab[i];
  800436:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800439:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043b:	b8 00 00 00 00       	mov    $0x0,%eax
  800440:	eb f2                	jmp    800434 <dev_lookup+0x4c>

00800442 <fd_close>:
{
  800442:	f3 0f 1e fb          	endbr32 
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	57                   	push   %edi
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	83 ec 28             	sub    $0x28,%esp
  80044f:	8b 75 08             	mov    0x8(%ebp),%esi
  800452:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800455:	56                   	push   %esi
  800456:	e8 b0 fe ff ff       	call   80030b <fd2num>
  80045b:	83 c4 08             	add    $0x8,%esp
  80045e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800461:	52                   	push   %edx
  800462:	50                   	push   %eax
  800463:	e8 2c ff ff ff       	call   800394 <fd_lookup>
  800468:	89 c3                	mov    %eax,%ebx
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	85 c0                	test   %eax,%eax
  80046f:	78 05                	js     800476 <fd_close+0x34>
	    || fd != fd2)
  800471:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800474:	74 16                	je     80048c <fd_close+0x4a>
		return (must_exist ? r : 0);
  800476:	89 f8                	mov    %edi,%eax
  800478:	84 c0                	test   %al,%al
  80047a:	b8 00 00 00 00       	mov    $0x0,%eax
  80047f:	0f 44 d8             	cmove  %eax,%ebx
}
  800482:	89 d8                	mov    %ebx,%eax
  800484:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800487:	5b                   	pop    %ebx
  800488:	5e                   	pop    %esi
  800489:	5f                   	pop    %edi
  80048a:	5d                   	pop    %ebp
  80048b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80048c:	83 ec 08             	sub    $0x8,%esp
  80048f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800492:	50                   	push   %eax
  800493:	ff 36                	pushl  (%esi)
  800495:	e8 4e ff ff ff       	call   8003e8 <dev_lookup>
  80049a:	89 c3                	mov    %eax,%ebx
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	78 1a                	js     8004bd <fd_close+0x7b>
		if (dev->dev_close)
  8004a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004a9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004ae:	85 c0                	test   %eax,%eax
  8004b0:	74 0b                	je     8004bd <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004b2:	83 ec 0c             	sub    $0xc,%esp
  8004b5:	56                   	push   %esi
  8004b6:	ff d0                	call   *%eax
  8004b8:	89 c3                	mov    %eax,%ebx
  8004ba:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	56                   	push   %esi
  8004c1:	6a 00                	push   $0x0
  8004c3:	e8 58 fd ff ff       	call   800220 <sys_page_unmap>
	return r;
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	eb b5                	jmp    800482 <fd_close+0x40>

008004cd <close>:

int
close(int fdnum)
{
  8004cd:	f3 0f 1e fb          	endbr32 
  8004d1:	55                   	push   %ebp
  8004d2:	89 e5                	mov    %esp,%ebp
  8004d4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004da:	50                   	push   %eax
  8004db:	ff 75 08             	pushl  0x8(%ebp)
  8004de:	e8 b1 fe ff ff       	call   800394 <fd_lookup>
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	85 c0                	test   %eax,%eax
  8004e8:	79 02                	jns    8004ec <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    
		return fd_close(fd, 1);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	6a 01                	push   $0x1
  8004f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8004f4:	e8 49 ff ff ff       	call   800442 <fd_close>
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb ec                	jmp    8004ea <close+0x1d>

008004fe <close_all>:

void
close_all(void)
{
  8004fe:	f3 0f 1e fb          	endbr32 
  800502:	55                   	push   %ebp
  800503:	89 e5                	mov    %esp,%ebp
  800505:	53                   	push   %ebx
  800506:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800509:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80050e:	83 ec 0c             	sub    $0xc,%esp
  800511:	53                   	push   %ebx
  800512:	e8 b6 ff ff ff       	call   8004cd <close>
	for (i = 0; i < MAXFD; i++)
  800517:	83 c3 01             	add    $0x1,%ebx
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	83 fb 20             	cmp    $0x20,%ebx
  800520:	75 ec                	jne    80050e <close_all+0x10>
}
  800522:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800525:	c9                   	leave  
  800526:	c3                   	ret    

00800527 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800527:	f3 0f 1e fb          	endbr32 
  80052b:	55                   	push   %ebp
  80052c:	89 e5                	mov    %esp,%ebp
  80052e:	57                   	push   %edi
  80052f:	56                   	push   %esi
  800530:	53                   	push   %ebx
  800531:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800534:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800537:	50                   	push   %eax
  800538:	ff 75 08             	pushl  0x8(%ebp)
  80053b:	e8 54 fe ff ff       	call   800394 <fd_lookup>
  800540:	89 c3                	mov    %eax,%ebx
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	85 c0                	test   %eax,%eax
  800547:	0f 88 81 00 00 00    	js     8005ce <dup+0xa7>
		return r;
	close(newfdnum);
  80054d:	83 ec 0c             	sub    $0xc,%esp
  800550:	ff 75 0c             	pushl  0xc(%ebp)
  800553:	e8 75 ff ff ff       	call   8004cd <close>

	newfd = INDEX2FD(newfdnum);
  800558:	8b 75 0c             	mov    0xc(%ebp),%esi
  80055b:	c1 e6 0c             	shl    $0xc,%esi
  80055e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800564:	83 c4 04             	add    $0x4,%esp
  800567:	ff 75 e4             	pushl  -0x1c(%ebp)
  80056a:	e8 b0 fd ff ff       	call   80031f <fd2data>
  80056f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800571:	89 34 24             	mov    %esi,(%esp)
  800574:	e8 a6 fd ff ff       	call   80031f <fd2data>
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80057e:	89 d8                	mov    %ebx,%eax
  800580:	c1 e8 16             	shr    $0x16,%eax
  800583:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80058a:	a8 01                	test   $0x1,%al
  80058c:	74 11                	je     80059f <dup+0x78>
  80058e:	89 d8                	mov    %ebx,%eax
  800590:	c1 e8 0c             	shr    $0xc,%eax
  800593:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80059a:	f6 c2 01             	test   $0x1,%dl
  80059d:	75 39                	jne    8005d8 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80059f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005a2:	89 d0                	mov    %edx,%eax
  8005a4:	c1 e8 0c             	shr    $0xc,%eax
  8005a7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ae:	83 ec 0c             	sub    $0xc,%esp
  8005b1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b6:	50                   	push   %eax
  8005b7:	56                   	push   %esi
  8005b8:	6a 00                	push   $0x0
  8005ba:	52                   	push   %edx
  8005bb:	6a 00                	push   $0x0
  8005bd:	e8 34 fc ff ff       	call   8001f6 <sys_page_map>
  8005c2:	89 c3                	mov    %eax,%ebx
  8005c4:	83 c4 20             	add    $0x20,%esp
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	78 31                	js     8005fc <dup+0xd5>
		goto err;

	return newfdnum;
  8005cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005ce:	89 d8                	mov    %ebx,%eax
  8005d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005d3:	5b                   	pop    %ebx
  8005d4:	5e                   	pop    %esi
  8005d5:	5f                   	pop    %edi
  8005d6:	5d                   	pop    %ebp
  8005d7:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e7:	50                   	push   %eax
  8005e8:	57                   	push   %edi
  8005e9:	6a 00                	push   $0x0
  8005eb:	53                   	push   %ebx
  8005ec:	6a 00                	push   $0x0
  8005ee:	e8 03 fc ff ff       	call   8001f6 <sys_page_map>
  8005f3:	89 c3                	mov    %eax,%ebx
  8005f5:	83 c4 20             	add    $0x20,%esp
  8005f8:	85 c0                	test   %eax,%eax
  8005fa:	79 a3                	jns    80059f <dup+0x78>
	sys_page_unmap(0, newfd);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	56                   	push   %esi
  800600:	6a 00                	push   $0x0
  800602:	e8 19 fc ff ff       	call   800220 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800607:	83 c4 08             	add    $0x8,%esp
  80060a:	57                   	push   %edi
  80060b:	6a 00                	push   $0x0
  80060d:	e8 0e fc ff ff       	call   800220 <sys_page_unmap>
	return r;
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	eb b7                	jmp    8005ce <dup+0xa7>

00800617 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800617:	f3 0f 1e fb          	endbr32 
  80061b:	55                   	push   %ebp
  80061c:	89 e5                	mov    %esp,%ebp
  80061e:	53                   	push   %ebx
  80061f:	83 ec 1c             	sub    $0x1c,%esp
  800622:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800625:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800628:	50                   	push   %eax
  800629:	53                   	push   %ebx
  80062a:	e8 65 fd ff ff       	call   800394 <fd_lookup>
  80062f:	83 c4 10             	add    $0x10,%esp
  800632:	85 c0                	test   %eax,%eax
  800634:	78 3f                	js     800675 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80063c:	50                   	push   %eax
  80063d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800640:	ff 30                	pushl  (%eax)
  800642:	e8 a1 fd ff ff       	call   8003e8 <dev_lookup>
  800647:	83 c4 10             	add    $0x10,%esp
  80064a:	85 c0                	test   %eax,%eax
  80064c:	78 27                	js     800675 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80064e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800651:	8b 42 08             	mov    0x8(%edx),%eax
  800654:	83 e0 03             	and    $0x3,%eax
  800657:	83 f8 01             	cmp    $0x1,%eax
  80065a:	74 1e                	je     80067a <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80065c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80065f:	8b 40 08             	mov    0x8(%eax),%eax
  800662:	85 c0                	test   %eax,%eax
  800664:	74 35                	je     80069b <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800666:	83 ec 04             	sub    $0x4,%esp
  800669:	ff 75 10             	pushl  0x10(%ebp)
  80066c:	ff 75 0c             	pushl  0xc(%ebp)
  80066f:	52                   	push   %edx
  800670:	ff d0                	call   *%eax
  800672:	83 c4 10             	add    $0x10,%esp
}
  800675:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800678:	c9                   	leave  
  800679:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067a:	a1 04 40 80 00       	mov    0x804004,%eax
  80067f:	8b 40 48             	mov    0x48(%eax),%eax
  800682:	83 ec 04             	sub    $0x4,%esp
  800685:	53                   	push   %ebx
  800686:	50                   	push   %eax
  800687:	68 5d 1e 80 00       	push   $0x801e5d
  80068c:	e8 cf 0a 00 00       	call   801160 <cprintf>
		return -E_INVAL;
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800699:	eb da                	jmp    800675 <read+0x5e>
		return -E_NOT_SUPP;
  80069b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006a0:	eb d3                	jmp    800675 <read+0x5e>

008006a2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006a2:	f3 0f 1e fb          	endbr32 
  8006a6:	55                   	push   %ebp
  8006a7:	89 e5                	mov    %esp,%ebp
  8006a9:	57                   	push   %edi
  8006aa:	56                   	push   %esi
  8006ab:	53                   	push   %ebx
  8006ac:	83 ec 0c             	sub    $0xc,%esp
  8006af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ba:	eb 02                	jmp    8006be <readn+0x1c>
  8006bc:	01 c3                	add    %eax,%ebx
  8006be:	39 f3                	cmp    %esi,%ebx
  8006c0:	73 21                	jae    8006e3 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c2:	83 ec 04             	sub    $0x4,%esp
  8006c5:	89 f0                	mov    %esi,%eax
  8006c7:	29 d8                	sub    %ebx,%eax
  8006c9:	50                   	push   %eax
  8006ca:	89 d8                	mov    %ebx,%eax
  8006cc:	03 45 0c             	add    0xc(%ebp),%eax
  8006cf:	50                   	push   %eax
  8006d0:	57                   	push   %edi
  8006d1:	e8 41 ff ff ff       	call   800617 <read>
		if (m < 0)
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	85 c0                	test   %eax,%eax
  8006db:	78 04                	js     8006e1 <readn+0x3f>
			return m;
		if (m == 0)
  8006dd:	75 dd                	jne    8006bc <readn+0x1a>
  8006df:	eb 02                	jmp    8006e3 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e1:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006e3:	89 d8                	mov    %ebx,%eax
  8006e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e8:	5b                   	pop    %ebx
  8006e9:	5e                   	pop    %esi
  8006ea:	5f                   	pop    %edi
  8006eb:	5d                   	pop    %ebp
  8006ec:	c3                   	ret    

008006ed <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006ed:	f3 0f 1e fb          	endbr32 
  8006f1:	55                   	push   %ebp
  8006f2:	89 e5                	mov    %esp,%ebp
  8006f4:	53                   	push   %ebx
  8006f5:	83 ec 1c             	sub    $0x1c,%esp
  8006f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006fe:	50                   	push   %eax
  8006ff:	53                   	push   %ebx
  800700:	e8 8f fc ff ff       	call   800394 <fd_lookup>
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	85 c0                	test   %eax,%eax
  80070a:	78 3a                	js     800746 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800716:	ff 30                	pushl  (%eax)
  800718:	e8 cb fc ff ff       	call   8003e8 <dev_lookup>
  80071d:	83 c4 10             	add    $0x10,%esp
  800720:	85 c0                	test   %eax,%eax
  800722:	78 22                	js     800746 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800724:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800727:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80072b:	74 1e                	je     80074b <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80072d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800730:	8b 52 0c             	mov    0xc(%edx),%edx
  800733:	85 d2                	test   %edx,%edx
  800735:	74 35                	je     80076c <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800737:	83 ec 04             	sub    $0x4,%esp
  80073a:	ff 75 10             	pushl  0x10(%ebp)
  80073d:	ff 75 0c             	pushl  0xc(%ebp)
  800740:	50                   	push   %eax
  800741:	ff d2                	call   *%edx
  800743:	83 c4 10             	add    $0x10,%esp
}
  800746:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800749:	c9                   	leave  
  80074a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074b:	a1 04 40 80 00       	mov    0x804004,%eax
  800750:	8b 40 48             	mov    0x48(%eax),%eax
  800753:	83 ec 04             	sub    $0x4,%esp
  800756:	53                   	push   %ebx
  800757:	50                   	push   %eax
  800758:	68 79 1e 80 00       	push   $0x801e79
  80075d:	e8 fe 09 00 00       	call   801160 <cprintf>
		return -E_INVAL;
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076a:	eb da                	jmp    800746 <write+0x59>
		return -E_NOT_SUPP;
  80076c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800771:	eb d3                	jmp    800746 <write+0x59>

00800773 <seek>:

int
seek(int fdnum, off_t offset)
{
  800773:	f3 0f 1e fb          	endbr32 
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80077d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800780:	50                   	push   %eax
  800781:	ff 75 08             	pushl  0x8(%ebp)
  800784:	e8 0b fc ff ff       	call   800394 <fd_lookup>
  800789:	83 c4 10             	add    $0x10,%esp
  80078c:	85 c0                	test   %eax,%eax
  80078e:	78 0e                	js     80079e <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800790:	8b 55 0c             	mov    0xc(%ebp),%edx
  800793:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800796:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800799:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007a0:	f3 0f 1e fb          	endbr32 
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	53                   	push   %ebx
  8007a8:	83 ec 1c             	sub    $0x1c,%esp
  8007ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b1:	50                   	push   %eax
  8007b2:	53                   	push   %ebx
  8007b3:	e8 dc fb ff ff       	call   800394 <fd_lookup>
  8007b8:	83 c4 10             	add    $0x10,%esp
  8007bb:	85 c0                	test   %eax,%eax
  8007bd:	78 37                	js     8007f6 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c5:	50                   	push   %eax
  8007c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c9:	ff 30                	pushl  (%eax)
  8007cb:	e8 18 fc ff ff       	call   8003e8 <dev_lookup>
  8007d0:	83 c4 10             	add    $0x10,%esp
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	78 1f                	js     8007f6 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007da:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007de:	74 1b                	je     8007fb <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007e3:	8b 52 18             	mov    0x18(%edx),%edx
  8007e6:	85 d2                	test   %edx,%edx
  8007e8:	74 32                	je     80081c <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007ea:	83 ec 08             	sub    $0x8,%esp
  8007ed:	ff 75 0c             	pushl  0xc(%ebp)
  8007f0:	50                   	push   %eax
  8007f1:	ff d2                	call   *%edx
  8007f3:	83 c4 10             	add    $0x10,%esp
}
  8007f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007fb:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800800:	8b 40 48             	mov    0x48(%eax),%eax
  800803:	83 ec 04             	sub    $0x4,%esp
  800806:	53                   	push   %ebx
  800807:	50                   	push   %eax
  800808:	68 3c 1e 80 00       	push   $0x801e3c
  80080d:	e8 4e 09 00 00       	call   801160 <cprintf>
		return -E_INVAL;
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081a:	eb da                	jmp    8007f6 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80081c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800821:	eb d3                	jmp    8007f6 <ftruncate+0x56>

00800823 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800823:	f3 0f 1e fb          	endbr32 
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	83 ec 1c             	sub    $0x1c,%esp
  80082e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800831:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800834:	50                   	push   %eax
  800835:	ff 75 08             	pushl  0x8(%ebp)
  800838:	e8 57 fb ff ff       	call   800394 <fd_lookup>
  80083d:	83 c4 10             	add    $0x10,%esp
  800840:	85 c0                	test   %eax,%eax
  800842:	78 4b                	js     80088f <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800844:	83 ec 08             	sub    $0x8,%esp
  800847:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80084a:	50                   	push   %eax
  80084b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084e:	ff 30                	pushl  (%eax)
  800850:	e8 93 fb ff ff       	call   8003e8 <dev_lookup>
  800855:	83 c4 10             	add    $0x10,%esp
  800858:	85 c0                	test   %eax,%eax
  80085a:	78 33                	js     80088f <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80085c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800863:	74 2f                	je     800894 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800865:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800868:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80086f:	00 00 00 
	stat->st_isdir = 0;
  800872:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800879:	00 00 00 
	stat->st_dev = dev;
  80087c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800882:	83 ec 08             	sub    $0x8,%esp
  800885:	53                   	push   %ebx
  800886:	ff 75 f0             	pushl  -0x10(%ebp)
  800889:	ff 50 14             	call   *0x14(%eax)
  80088c:	83 c4 10             	add    $0x10,%esp
}
  80088f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800892:	c9                   	leave  
  800893:	c3                   	ret    
		return -E_NOT_SUPP;
  800894:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800899:	eb f4                	jmp    80088f <fstat+0x6c>

0080089b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80089b:	f3 0f 1e fb          	endbr32 
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008a4:	83 ec 08             	sub    $0x8,%esp
  8008a7:	6a 00                	push   $0x0
  8008a9:	ff 75 08             	pushl  0x8(%ebp)
  8008ac:	e8 20 02 00 00       	call   800ad1 <open>
  8008b1:	89 c3                	mov    %eax,%ebx
  8008b3:	83 c4 10             	add    $0x10,%esp
  8008b6:	85 c0                	test   %eax,%eax
  8008b8:	78 1b                	js     8008d5 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008ba:	83 ec 08             	sub    $0x8,%esp
  8008bd:	ff 75 0c             	pushl  0xc(%ebp)
  8008c0:	50                   	push   %eax
  8008c1:	e8 5d ff ff ff       	call   800823 <fstat>
  8008c6:	89 c6                	mov    %eax,%esi
	close(fd);
  8008c8:	89 1c 24             	mov    %ebx,(%esp)
  8008cb:	e8 fd fb ff ff       	call   8004cd <close>
	return r;
  8008d0:	83 c4 10             	add    $0x10,%esp
  8008d3:	89 f3                	mov    %esi,%ebx
}
  8008d5:	89 d8                	mov    %ebx,%eax
  8008d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008da:	5b                   	pop    %ebx
  8008db:	5e                   	pop    %esi
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	56                   	push   %esi
  8008e2:	53                   	push   %ebx
  8008e3:	89 c6                	mov    %eax,%esi
  8008e5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008e7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008ee:	74 27                	je     800917 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008f0:	6a 07                	push   $0x7
  8008f2:	68 00 50 80 00       	push   $0x805000
  8008f7:	56                   	push   %esi
  8008f8:	ff 35 00 40 80 00    	pushl  0x804000
  8008fe:	e8 a8 11 00 00       	call   801aab <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800903:	83 c4 0c             	add    $0xc,%esp
  800906:	6a 00                	push   $0x0
  800908:	53                   	push   %ebx
  800909:	6a 00                	push   $0x0
  80090b:	e8 2e 11 00 00       	call   801a3e <ipc_recv>
}
  800910:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800913:	5b                   	pop    %ebx
  800914:	5e                   	pop    %esi
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800917:	83 ec 0c             	sub    $0xc,%esp
  80091a:	6a 01                	push   $0x1
  80091c:	e8 dd 11 00 00       	call   801afe <ipc_find_env>
  800921:	a3 00 40 80 00       	mov    %eax,0x804000
  800926:	83 c4 10             	add    $0x10,%esp
  800929:	eb c5                	jmp    8008f0 <fsipc+0x12>

0080092b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80092b:	f3 0f 1e fb          	endbr32 
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	8b 40 0c             	mov    0xc(%eax),%eax
  80093b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800940:	8b 45 0c             	mov    0xc(%ebp),%eax
  800943:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800948:	ba 00 00 00 00       	mov    $0x0,%edx
  80094d:	b8 02 00 00 00       	mov    $0x2,%eax
  800952:	e8 87 ff ff ff       	call   8008de <fsipc>
}
  800957:	c9                   	leave  
  800958:	c3                   	ret    

00800959 <devfile_flush>:
{
  800959:	f3 0f 1e fb          	endbr32 
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
  800966:	8b 40 0c             	mov    0xc(%eax),%eax
  800969:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	b8 06 00 00 00       	mov    $0x6,%eax
  800978:	e8 61 ff ff ff       	call   8008de <fsipc>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <devfile_stat>:
{
  80097f:	f3 0f 1e fb          	endbr32 
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	53                   	push   %ebx
  800987:	83 ec 04             	sub    $0x4,%esp
  80098a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 40 0c             	mov    0xc(%eax),%eax
  800993:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800998:	ba 00 00 00 00       	mov    $0x0,%edx
  80099d:	b8 05 00 00 00       	mov    $0x5,%eax
  8009a2:	e8 37 ff ff ff       	call   8008de <fsipc>
  8009a7:	85 c0                	test   %eax,%eax
  8009a9:	78 2c                	js     8009d7 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009ab:	83 ec 08             	sub    $0x8,%esp
  8009ae:	68 00 50 80 00       	push   $0x805000
  8009b3:	53                   	push   %ebx
  8009b4:	e8 11 0d 00 00       	call   8016ca <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b9:	a1 80 50 80 00       	mov    0x805080,%eax
  8009be:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c4:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009cf:	83 c4 10             	add    $0x10,%esp
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <devfile_write>:
{
  8009dc:	f3 0f 1e fb          	endbr32 
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	57                   	push   %edi
  8009e4:	56                   	push   %esi
  8009e5:	53                   	push   %ebx
  8009e6:	83 ec 0c             	sub    $0xc,%esp
  8009e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f5:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8009ff:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  800a04:	85 db                	test   %ebx,%ebx
  800a06:	74 3b                	je     800a43 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a08:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800a0e:	89 f8                	mov    %edi,%eax
  800a10:	0f 46 c3             	cmovbe %ebx,%eax
  800a13:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  800a18:	83 ec 04             	sub    $0x4,%esp
  800a1b:	50                   	push   %eax
  800a1c:	56                   	push   %esi
  800a1d:	68 08 50 80 00       	push   $0x805008
  800a22:	e8 5b 0e 00 00       	call   801882 <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800a27:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2c:	b8 04 00 00 00       	mov    $0x4,%eax
  800a31:	e8 a8 fe ff ff       	call   8008de <fsipc>
  800a36:	83 c4 10             	add    $0x10,%esp
  800a39:	85 c0                	test   %eax,%eax
  800a3b:	78 06                	js     800a43 <devfile_write+0x67>
		buf_aux += r;
  800a3d:	01 c6                	add    %eax,%esi
		n -= r;
  800a3f:	29 c3                	sub    %eax,%ebx
  800a41:	eb c1                	jmp    800a04 <devfile_write+0x28>
}
  800a43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a46:	5b                   	pop    %ebx
  800a47:	5e                   	pop    %esi
  800a48:	5f                   	pop    %edi
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <devfile_read>:
{
  800a4b:	f3 0f 1e fb          	endbr32 
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	56                   	push   %esi
  800a53:	53                   	push   %ebx
  800a54:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a57:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a5d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a62:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a68:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a72:	e8 67 fe ff ff       	call   8008de <fsipc>
  800a77:	89 c3                	mov    %eax,%ebx
  800a79:	85 c0                	test   %eax,%eax
  800a7b:	78 1f                	js     800a9c <devfile_read+0x51>
	assert(r <= n);
  800a7d:	39 f0                	cmp    %esi,%eax
  800a7f:	77 24                	ja     800aa5 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a81:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a86:	7f 33                	jg     800abb <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a88:	83 ec 04             	sub    $0x4,%esp
  800a8b:	50                   	push   %eax
  800a8c:	68 00 50 80 00       	push   $0x805000
  800a91:	ff 75 0c             	pushl  0xc(%ebp)
  800a94:	e8 e9 0d 00 00       	call   801882 <memmove>
	return r;
  800a99:	83 c4 10             	add    $0x10,%esp
}
  800a9c:	89 d8                	mov    %ebx,%eax
  800a9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    
	assert(r <= n);
  800aa5:	68 a8 1e 80 00       	push   $0x801ea8
  800aaa:	68 af 1e 80 00       	push   $0x801eaf
  800aaf:	6a 7c                	push   $0x7c
  800ab1:	68 c4 1e 80 00       	push   $0x801ec4
  800ab6:	e8 be 05 00 00       	call   801079 <_panic>
	assert(r <= PGSIZE);
  800abb:	68 cf 1e 80 00       	push   $0x801ecf
  800ac0:	68 af 1e 80 00       	push   $0x801eaf
  800ac5:	6a 7d                	push   $0x7d
  800ac7:	68 c4 1e 80 00       	push   $0x801ec4
  800acc:	e8 a8 05 00 00       	call   801079 <_panic>

00800ad1 <open>:
{
  800ad1:	f3 0f 1e fb          	endbr32 
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	56                   	push   %esi
  800ad9:	53                   	push   %ebx
  800ada:	83 ec 1c             	sub    $0x1c,%esp
  800add:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ae0:	56                   	push   %esi
  800ae1:	e8 a1 0b 00 00       	call   801687 <strlen>
  800ae6:	83 c4 10             	add    $0x10,%esp
  800ae9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aee:	7f 6c                	jg     800b5c <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800af0:	83 ec 0c             	sub    $0xc,%esp
  800af3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af6:	50                   	push   %eax
  800af7:	e8 42 f8 ff ff       	call   80033e <fd_alloc>
  800afc:	89 c3                	mov    %eax,%ebx
  800afe:	83 c4 10             	add    $0x10,%esp
  800b01:	85 c0                	test   %eax,%eax
  800b03:	78 3c                	js     800b41 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b05:	83 ec 08             	sub    $0x8,%esp
  800b08:	56                   	push   %esi
  800b09:	68 00 50 80 00       	push   $0x805000
  800b0e:	e8 b7 0b 00 00       	call   8016ca <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b16:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b23:	e8 b6 fd ff ff       	call   8008de <fsipc>
  800b28:	89 c3                	mov    %eax,%ebx
  800b2a:	83 c4 10             	add    $0x10,%esp
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	78 19                	js     800b4a <open+0x79>
	return fd2num(fd);
  800b31:	83 ec 0c             	sub    $0xc,%esp
  800b34:	ff 75 f4             	pushl  -0xc(%ebp)
  800b37:	e8 cf f7 ff ff       	call   80030b <fd2num>
  800b3c:	89 c3                	mov    %eax,%ebx
  800b3e:	83 c4 10             	add    $0x10,%esp
}
  800b41:	89 d8                	mov    %ebx,%eax
  800b43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    
		fd_close(fd, 0);
  800b4a:	83 ec 08             	sub    $0x8,%esp
  800b4d:	6a 00                	push   $0x0
  800b4f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b52:	e8 eb f8 ff ff       	call   800442 <fd_close>
		return r;
  800b57:	83 c4 10             	add    $0x10,%esp
  800b5a:	eb e5                	jmp    800b41 <open+0x70>
		return -E_BAD_PATH;
  800b5c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b61:	eb de                	jmp    800b41 <open+0x70>

00800b63 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b63:	f3 0f 1e fb          	endbr32 
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b72:	b8 08 00 00 00       	mov    $0x8,%eax
  800b77:	e8 62 fd ff ff       	call   8008de <fsipc>
}
  800b7c:	c9                   	leave  
  800b7d:	c3                   	ret    

00800b7e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b7e:	f3 0f 1e fb          	endbr32 
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b8a:	83 ec 0c             	sub    $0xc,%esp
  800b8d:	ff 75 08             	pushl  0x8(%ebp)
  800b90:	e8 8a f7 ff ff       	call   80031f <fd2data>
  800b95:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b97:	83 c4 08             	add    $0x8,%esp
  800b9a:	68 db 1e 80 00       	push   $0x801edb
  800b9f:	53                   	push   %ebx
  800ba0:	e8 25 0b 00 00       	call   8016ca <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ba5:	8b 46 04             	mov    0x4(%esi),%eax
  800ba8:	2b 06                	sub    (%esi),%eax
  800baa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bb0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bb7:	00 00 00 
	stat->st_dev = &devpipe;
  800bba:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bc1:	30 80 00 
	return 0;
}
  800bc4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5d                   	pop    %ebp
  800bcf:	c3                   	ret    

00800bd0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bd0:	f3 0f 1e fb          	endbr32 
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	53                   	push   %ebx
  800bd8:	83 ec 0c             	sub    $0xc,%esp
  800bdb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bde:	53                   	push   %ebx
  800bdf:	6a 00                	push   $0x0
  800be1:	e8 3a f6 ff ff       	call   800220 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800be6:	89 1c 24             	mov    %ebx,(%esp)
  800be9:	e8 31 f7 ff ff       	call   80031f <fd2data>
  800bee:	83 c4 08             	add    $0x8,%esp
  800bf1:	50                   	push   %eax
  800bf2:	6a 00                	push   $0x0
  800bf4:	e8 27 f6 ff ff       	call   800220 <sys_page_unmap>
}
  800bf9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bfc:	c9                   	leave  
  800bfd:	c3                   	ret    

00800bfe <_pipeisclosed>:
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	83 ec 1c             	sub    $0x1c,%esp
  800c07:	89 c7                	mov    %eax,%edi
  800c09:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c0b:	a1 04 40 80 00       	mov    0x804004,%eax
  800c10:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c13:	83 ec 0c             	sub    $0xc,%esp
  800c16:	57                   	push   %edi
  800c17:	e8 1f 0f 00 00       	call   801b3b <pageref>
  800c1c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c1f:	89 34 24             	mov    %esi,(%esp)
  800c22:	e8 14 0f 00 00       	call   801b3b <pageref>
		nn = thisenv->env_runs;
  800c27:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c2d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c30:	83 c4 10             	add    $0x10,%esp
  800c33:	39 cb                	cmp    %ecx,%ebx
  800c35:	74 1b                	je     800c52 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c37:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c3a:	75 cf                	jne    800c0b <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c3c:	8b 42 58             	mov    0x58(%edx),%eax
  800c3f:	6a 01                	push   $0x1
  800c41:	50                   	push   %eax
  800c42:	53                   	push   %ebx
  800c43:	68 e2 1e 80 00       	push   $0x801ee2
  800c48:	e8 13 05 00 00       	call   801160 <cprintf>
  800c4d:	83 c4 10             	add    $0x10,%esp
  800c50:	eb b9                	jmp    800c0b <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c52:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c55:	0f 94 c0             	sete   %al
  800c58:	0f b6 c0             	movzbl %al,%eax
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <devpipe_write>:
{
  800c63:	f3 0f 1e fb          	endbr32 
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 28             	sub    $0x28,%esp
  800c70:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c73:	56                   	push   %esi
  800c74:	e8 a6 f6 ff ff       	call   80031f <fd2data>
  800c79:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c7b:	83 c4 10             	add    $0x10,%esp
  800c7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c83:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c86:	74 4f                	je     800cd7 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c88:	8b 43 04             	mov    0x4(%ebx),%eax
  800c8b:	8b 0b                	mov    (%ebx),%ecx
  800c8d:	8d 51 20             	lea    0x20(%ecx),%edx
  800c90:	39 d0                	cmp    %edx,%eax
  800c92:	72 14                	jb     800ca8 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800c94:	89 da                	mov    %ebx,%edx
  800c96:	89 f0                	mov    %esi,%eax
  800c98:	e8 61 ff ff ff       	call   800bfe <_pipeisclosed>
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	75 3b                	jne    800cdc <devpipe_write+0x79>
			sys_yield();
  800ca1:	e8 fd f4 ff ff       	call   8001a3 <sys_yield>
  800ca6:	eb e0                	jmp    800c88 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ca8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cab:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800caf:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cb2:	89 c2                	mov    %eax,%edx
  800cb4:	c1 fa 1f             	sar    $0x1f,%edx
  800cb7:	89 d1                	mov    %edx,%ecx
  800cb9:	c1 e9 1b             	shr    $0x1b,%ecx
  800cbc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cbf:	83 e2 1f             	and    $0x1f,%edx
  800cc2:	29 ca                	sub    %ecx,%edx
  800cc4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cc8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ccc:	83 c0 01             	add    $0x1,%eax
  800ccf:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cd2:	83 c7 01             	add    $0x1,%edi
  800cd5:	eb ac                	jmp    800c83 <devpipe_write+0x20>
	return i;
  800cd7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cda:	eb 05                	jmp    800ce1 <devpipe_write+0x7e>
				return 0;
  800cdc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <devpipe_read>:
{
  800ce9:	f3 0f 1e fb          	endbr32 
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	83 ec 18             	sub    $0x18,%esp
  800cf6:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cf9:	57                   	push   %edi
  800cfa:	e8 20 f6 ff ff       	call   80031f <fd2data>
  800cff:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d01:	83 c4 10             	add    $0x10,%esp
  800d04:	be 00 00 00 00       	mov    $0x0,%esi
  800d09:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d0c:	75 14                	jne    800d22 <devpipe_read+0x39>
	return i;
  800d0e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d11:	eb 02                	jmp    800d15 <devpipe_read+0x2c>
				return i;
  800d13:	89 f0                	mov    %esi,%eax
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    
			sys_yield();
  800d1d:	e8 81 f4 ff ff       	call   8001a3 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d22:	8b 03                	mov    (%ebx),%eax
  800d24:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d27:	75 18                	jne    800d41 <devpipe_read+0x58>
			if (i > 0)
  800d29:	85 f6                	test   %esi,%esi
  800d2b:	75 e6                	jne    800d13 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d2d:	89 da                	mov    %ebx,%edx
  800d2f:	89 f8                	mov    %edi,%eax
  800d31:	e8 c8 fe ff ff       	call   800bfe <_pipeisclosed>
  800d36:	85 c0                	test   %eax,%eax
  800d38:	74 e3                	je     800d1d <devpipe_read+0x34>
				return 0;
  800d3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3f:	eb d4                	jmp    800d15 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d41:	99                   	cltd   
  800d42:	c1 ea 1b             	shr    $0x1b,%edx
  800d45:	01 d0                	add    %edx,%eax
  800d47:	83 e0 1f             	and    $0x1f,%eax
  800d4a:	29 d0                	sub    %edx,%eax
  800d4c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d54:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d57:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d5a:	83 c6 01             	add    $0x1,%esi
  800d5d:	eb aa                	jmp    800d09 <devpipe_read+0x20>

00800d5f <pipe>:
{
  800d5f:	f3 0f 1e fb          	endbr32 
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d6e:	50                   	push   %eax
  800d6f:	e8 ca f5 ff ff       	call   80033e <fd_alloc>
  800d74:	89 c3                	mov    %eax,%ebx
  800d76:	83 c4 10             	add    $0x10,%esp
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	0f 88 23 01 00 00    	js     800ea4 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d81:	83 ec 04             	sub    $0x4,%esp
  800d84:	68 07 04 00 00       	push   $0x407
  800d89:	ff 75 f4             	pushl  -0xc(%ebp)
  800d8c:	6a 00                	push   $0x0
  800d8e:	e8 3b f4 ff ff       	call   8001ce <sys_page_alloc>
  800d93:	89 c3                	mov    %eax,%ebx
  800d95:	83 c4 10             	add    $0x10,%esp
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	0f 88 04 01 00 00    	js     800ea4 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800da6:	50                   	push   %eax
  800da7:	e8 92 f5 ff ff       	call   80033e <fd_alloc>
  800dac:	89 c3                	mov    %eax,%ebx
  800dae:	83 c4 10             	add    $0x10,%esp
  800db1:	85 c0                	test   %eax,%eax
  800db3:	0f 88 db 00 00 00    	js     800e94 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db9:	83 ec 04             	sub    $0x4,%esp
  800dbc:	68 07 04 00 00       	push   $0x407
  800dc1:	ff 75 f0             	pushl  -0x10(%ebp)
  800dc4:	6a 00                	push   $0x0
  800dc6:	e8 03 f4 ff ff       	call   8001ce <sys_page_alloc>
  800dcb:	89 c3                	mov    %eax,%ebx
  800dcd:	83 c4 10             	add    $0x10,%esp
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	0f 88 bc 00 00 00    	js     800e94 <pipe+0x135>
	va = fd2data(fd0);
  800dd8:	83 ec 0c             	sub    $0xc,%esp
  800ddb:	ff 75 f4             	pushl  -0xc(%ebp)
  800dde:	e8 3c f5 ff ff       	call   80031f <fd2data>
  800de3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de5:	83 c4 0c             	add    $0xc,%esp
  800de8:	68 07 04 00 00       	push   $0x407
  800ded:	50                   	push   %eax
  800dee:	6a 00                	push   $0x0
  800df0:	e8 d9 f3 ff ff       	call   8001ce <sys_page_alloc>
  800df5:	89 c3                	mov    %eax,%ebx
  800df7:	83 c4 10             	add    $0x10,%esp
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	0f 88 82 00 00 00    	js     800e84 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e02:	83 ec 0c             	sub    $0xc,%esp
  800e05:	ff 75 f0             	pushl  -0x10(%ebp)
  800e08:	e8 12 f5 ff ff       	call   80031f <fd2data>
  800e0d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e14:	50                   	push   %eax
  800e15:	6a 00                	push   $0x0
  800e17:	56                   	push   %esi
  800e18:	6a 00                	push   $0x0
  800e1a:	e8 d7 f3 ff ff       	call   8001f6 <sys_page_map>
  800e1f:	89 c3                	mov    %eax,%ebx
  800e21:	83 c4 20             	add    $0x20,%esp
  800e24:	85 c0                	test   %eax,%eax
  800e26:	78 4e                	js     800e76 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e28:	a1 20 30 80 00       	mov    0x803020,%eax
  800e2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e30:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e35:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e3c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e3f:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e44:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e4b:	83 ec 0c             	sub    $0xc,%esp
  800e4e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e51:	e8 b5 f4 ff ff       	call   80030b <fd2num>
  800e56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e59:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e5b:	83 c4 04             	add    $0x4,%esp
  800e5e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e61:	e8 a5 f4 ff ff       	call   80030b <fd2num>
  800e66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e69:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e6c:	83 c4 10             	add    $0x10,%esp
  800e6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e74:	eb 2e                	jmp    800ea4 <pipe+0x145>
	sys_page_unmap(0, va);
  800e76:	83 ec 08             	sub    $0x8,%esp
  800e79:	56                   	push   %esi
  800e7a:	6a 00                	push   $0x0
  800e7c:	e8 9f f3 ff ff       	call   800220 <sys_page_unmap>
  800e81:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e84:	83 ec 08             	sub    $0x8,%esp
  800e87:	ff 75 f0             	pushl  -0x10(%ebp)
  800e8a:	6a 00                	push   $0x0
  800e8c:	e8 8f f3 ff ff       	call   800220 <sys_page_unmap>
  800e91:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e94:	83 ec 08             	sub    $0x8,%esp
  800e97:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9a:	6a 00                	push   $0x0
  800e9c:	e8 7f f3 ff ff       	call   800220 <sys_page_unmap>
  800ea1:	83 c4 10             	add    $0x10,%esp
}
  800ea4:	89 d8                	mov    %ebx,%eax
  800ea6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea9:	5b                   	pop    %ebx
  800eaa:	5e                   	pop    %esi
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <pipeisclosed>:
{
  800ead:	f3 0f 1e fb          	endbr32 
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eba:	50                   	push   %eax
  800ebb:	ff 75 08             	pushl  0x8(%ebp)
  800ebe:	e8 d1 f4 ff ff       	call   800394 <fd_lookup>
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	78 18                	js     800ee2 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800eca:	83 ec 0c             	sub    $0xc,%esp
  800ecd:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed0:	e8 4a f4 ff ff       	call   80031f <fd2data>
  800ed5:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eda:	e8 1f fd ff ff       	call   800bfe <_pipeisclosed>
  800edf:	83 c4 10             	add    $0x10,%esp
}
  800ee2:	c9                   	leave  
  800ee3:	c3                   	ret    

00800ee4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ee4:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800ee8:	b8 00 00 00 00       	mov    $0x0,%eax
  800eed:	c3                   	ret    

00800eee <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eee:	f3 0f 1e fb          	endbr32 
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ef8:	68 fa 1e 80 00       	push   $0x801efa
  800efd:	ff 75 0c             	pushl  0xc(%ebp)
  800f00:	e8 c5 07 00 00       	call   8016ca <strcpy>
	return 0;
}
  800f05:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0a:	c9                   	leave  
  800f0b:	c3                   	ret    

00800f0c <devcons_write>:
{
  800f0c:	f3 0f 1e fb          	endbr32 
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	57                   	push   %edi
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx
  800f16:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f1c:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f21:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f27:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f2a:	73 31                	jae    800f5d <devcons_write+0x51>
		m = n - tot;
  800f2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2f:	29 f3                	sub    %esi,%ebx
  800f31:	83 fb 7f             	cmp    $0x7f,%ebx
  800f34:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f39:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f3c:	83 ec 04             	sub    $0x4,%esp
  800f3f:	53                   	push   %ebx
  800f40:	89 f0                	mov    %esi,%eax
  800f42:	03 45 0c             	add    0xc(%ebp),%eax
  800f45:	50                   	push   %eax
  800f46:	57                   	push   %edi
  800f47:	e8 36 09 00 00       	call   801882 <memmove>
		sys_cputs(buf, m);
  800f4c:	83 c4 08             	add    $0x8,%esp
  800f4f:	53                   	push   %ebx
  800f50:	57                   	push   %edi
  800f51:	e8 ad f1 ff ff       	call   800103 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f56:	01 de                	add    %ebx,%esi
  800f58:	83 c4 10             	add    $0x10,%esp
  800f5b:	eb ca                	jmp    800f27 <devcons_write+0x1b>
}
  800f5d:	89 f0                	mov    %esi,%eax
  800f5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f62:	5b                   	pop    %ebx
  800f63:	5e                   	pop    %esi
  800f64:	5f                   	pop    %edi
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <devcons_read>:
{
  800f67:	f3 0f 1e fb          	endbr32 
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	83 ec 08             	sub    $0x8,%esp
  800f71:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f7a:	74 21                	je     800f9d <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800f7c:	e8 ac f1 ff ff       	call   80012d <sys_cgetc>
  800f81:	85 c0                	test   %eax,%eax
  800f83:	75 07                	jne    800f8c <devcons_read+0x25>
		sys_yield();
  800f85:	e8 19 f2 ff ff       	call   8001a3 <sys_yield>
  800f8a:	eb f0                	jmp    800f7c <devcons_read+0x15>
	if (c < 0)
  800f8c:	78 0f                	js     800f9d <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800f8e:	83 f8 04             	cmp    $0x4,%eax
  800f91:	74 0c                	je     800f9f <devcons_read+0x38>
	*(char*)vbuf = c;
  800f93:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f96:	88 02                	mov    %al,(%edx)
	return 1;
  800f98:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f9d:	c9                   	leave  
  800f9e:	c3                   	ret    
		return 0;
  800f9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa4:	eb f7                	jmp    800f9d <devcons_read+0x36>

00800fa6 <cputchar>:
{
  800fa6:	f3 0f 1e fb          	endbr32 
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb3:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800fb6:	6a 01                	push   $0x1
  800fb8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fbb:	50                   	push   %eax
  800fbc:	e8 42 f1 ff ff       	call   800103 <sys_cputs>
}
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	c9                   	leave  
  800fc5:	c3                   	ret    

00800fc6 <getchar>:
{
  800fc6:	f3 0f 1e fb          	endbr32 
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800fd0:	6a 01                	push   $0x1
  800fd2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd5:	50                   	push   %eax
  800fd6:	6a 00                	push   $0x0
  800fd8:	e8 3a f6 ff ff       	call   800617 <read>
	if (r < 0)
  800fdd:	83 c4 10             	add    $0x10,%esp
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	78 06                	js     800fea <getchar+0x24>
	if (r < 1)
  800fe4:	74 06                	je     800fec <getchar+0x26>
	return c;
  800fe6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fea:	c9                   	leave  
  800feb:	c3                   	ret    
		return -E_EOF;
  800fec:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800ff1:	eb f7                	jmp    800fea <getchar+0x24>

00800ff3 <iscons>:
{
  800ff3:	f3 0f 1e fb          	endbr32 
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ffd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801000:	50                   	push   %eax
  801001:	ff 75 08             	pushl  0x8(%ebp)
  801004:	e8 8b f3 ff ff       	call   800394 <fd_lookup>
  801009:	83 c4 10             	add    $0x10,%esp
  80100c:	85 c0                	test   %eax,%eax
  80100e:	78 11                	js     801021 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801010:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801013:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801019:	39 10                	cmp    %edx,(%eax)
  80101b:	0f 94 c0             	sete   %al
  80101e:	0f b6 c0             	movzbl %al,%eax
}
  801021:	c9                   	leave  
  801022:	c3                   	ret    

00801023 <opencons>:
{
  801023:	f3 0f 1e fb          	endbr32 
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80102d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801030:	50                   	push   %eax
  801031:	e8 08 f3 ff ff       	call   80033e <fd_alloc>
  801036:	83 c4 10             	add    $0x10,%esp
  801039:	85 c0                	test   %eax,%eax
  80103b:	78 3a                	js     801077 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80103d:	83 ec 04             	sub    $0x4,%esp
  801040:	68 07 04 00 00       	push   $0x407
  801045:	ff 75 f4             	pushl  -0xc(%ebp)
  801048:	6a 00                	push   $0x0
  80104a:	e8 7f f1 ff ff       	call   8001ce <sys_page_alloc>
  80104f:	83 c4 10             	add    $0x10,%esp
  801052:	85 c0                	test   %eax,%eax
  801054:	78 21                	js     801077 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801056:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801059:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80105f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801061:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801064:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	50                   	push   %eax
  80106f:	e8 97 f2 ff ff       	call   80030b <fd2num>
  801074:	83 c4 10             	add    $0x10,%esp
}
  801077:	c9                   	leave  
  801078:	c3                   	ret    

00801079 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801079:	f3 0f 1e fb          	endbr32 
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	56                   	push   %esi
  801081:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801082:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801085:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80108b:	e8 eb f0 ff ff       	call   80017b <sys_getenvid>
  801090:	83 ec 0c             	sub    $0xc,%esp
  801093:	ff 75 0c             	pushl  0xc(%ebp)
  801096:	ff 75 08             	pushl  0x8(%ebp)
  801099:	56                   	push   %esi
  80109a:	50                   	push   %eax
  80109b:	68 08 1f 80 00       	push   $0x801f08
  8010a0:	e8 bb 00 00 00       	call   801160 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010a5:	83 c4 18             	add    $0x18,%esp
  8010a8:	53                   	push   %ebx
  8010a9:	ff 75 10             	pushl  0x10(%ebp)
  8010ac:	e8 5a 00 00 00       	call   80110b <vcprintf>
	cprintf("\n");
  8010b1:	c7 04 24 f3 1e 80 00 	movl   $0x801ef3,(%esp)
  8010b8:	e8 a3 00 00 00       	call   801160 <cprintf>
  8010bd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010c0:	cc                   	int3   
  8010c1:	eb fd                	jmp    8010c0 <_panic+0x47>

008010c3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010c3:	f3 0f 1e fb          	endbr32 
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	53                   	push   %ebx
  8010cb:	83 ec 04             	sub    $0x4,%esp
  8010ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010d1:	8b 13                	mov    (%ebx),%edx
  8010d3:	8d 42 01             	lea    0x1(%edx),%eax
  8010d6:	89 03                	mov    %eax,(%ebx)
  8010d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010db:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010df:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010e4:	74 09                	je     8010ef <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010e6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ed:	c9                   	leave  
  8010ee:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010ef:	83 ec 08             	sub    $0x8,%esp
  8010f2:	68 ff 00 00 00       	push   $0xff
  8010f7:	8d 43 08             	lea    0x8(%ebx),%eax
  8010fa:	50                   	push   %eax
  8010fb:	e8 03 f0 ff ff       	call   800103 <sys_cputs>
		b->idx = 0;
  801100:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	eb db                	jmp    8010e6 <putch+0x23>

0080110b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80110b:	f3 0f 1e fb          	endbr32 
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801118:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80111f:	00 00 00 
	b.cnt = 0;
  801122:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801129:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80112c:	ff 75 0c             	pushl  0xc(%ebp)
  80112f:	ff 75 08             	pushl  0x8(%ebp)
  801132:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801138:	50                   	push   %eax
  801139:	68 c3 10 80 00       	push   $0x8010c3
  80113e:	e8 80 01 00 00       	call   8012c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801143:	83 c4 08             	add    $0x8,%esp
  801146:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80114c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801152:	50                   	push   %eax
  801153:	e8 ab ef ff ff       	call   800103 <sys_cputs>

	return b.cnt;
}
  801158:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80115e:	c9                   	leave  
  80115f:	c3                   	ret    

00801160 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801160:	f3 0f 1e fb          	endbr32 
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80116a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80116d:	50                   	push   %eax
  80116e:	ff 75 08             	pushl  0x8(%ebp)
  801171:	e8 95 ff ff ff       	call   80110b <vcprintf>
	va_end(ap);

	return cnt;
}
  801176:	c9                   	leave  
  801177:	c3                   	ret    

00801178 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	57                   	push   %edi
  80117c:	56                   	push   %esi
  80117d:	53                   	push   %ebx
  80117e:	83 ec 1c             	sub    $0x1c,%esp
  801181:	89 c7                	mov    %eax,%edi
  801183:	89 d6                	mov    %edx,%esi
  801185:	8b 45 08             	mov    0x8(%ebp),%eax
  801188:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118b:	89 d1                	mov    %edx,%ecx
  80118d:	89 c2                	mov    %eax,%edx
  80118f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801192:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801195:	8b 45 10             	mov    0x10(%ebp),%eax
  801198:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80119b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80119e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011a5:	39 c2                	cmp    %eax,%edx
  8011a7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011aa:	72 3e                	jb     8011ea <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011ac:	83 ec 0c             	sub    $0xc,%esp
  8011af:	ff 75 18             	pushl  0x18(%ebp)
  8011b2:	83 eb 01             	sub    $0x1,%ebx
  8011b5:	53                   	push   %ebx
  8011b6:	50                   	push   %eax
  8011b7:	83 ec 08             	sub    $0x8,%esp
  8011ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c0:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c3:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c6:	e8 b5 09 00 00       	call   801b80 <__udivdi3>
  8011cb:	83 c4 18             	add    $0x18,%esp
  8011ce:	52                   	push   %edx
  8011cf:	50                   	push   %eax
  8011d0:	89 f2                	mov    %esi,%edx
  8011d2:	89 f8                	mov    %edi,%eax
  8011d4:	e8 9f ff ff ff       	call   801178 <printnum>
  8011d9:	83 c4 20             	add    $0x20,%esp
  8011dc:	eb 13                	jmp    8011f1 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011de:	83 ec 08             	sub    $0x8,%esp
  8011e1:	56                   	push   %esi
  8011e2:	ff 75 18             	pushl  0x18(%ebp)
  8011e5:	ff d7                	call   *%edi
  8011e7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011ea:	83 eb 01             	sub    $0x1,%ebx
  8011ed:	85 db                	test   %ebx,%ebx
  8011ef:	7f ed                	jg     8011de <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011f1:	83 ec 08             	sub    $0x8,%esp
  8011f4:	56                   	push   %esi
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8011fe:	ff 75 dc             	pushl  -0x24(%ebp)
  801201:	ff 75 d8             	pushl  -0x28(%ebp)
  801204:	e8 87 0a 00 00       	call   801c90 <__umoddi3>
  801209:	83 c4 14             	add    $0x14,%esp
  80120c:	0f be 80 2b 1f 80 00 	movsbl 0x801f2b(%eax),%eax
  801213:	50                   	push   %eax
  801214:	ff d7                	call   *%edi
}
  801216:	83 c4 10             	add    $0x10,%esp
  801219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121c:	5b                   	pop    %ebx
  80121d:	5e                   	pop    %esi
  80121e:	5f                   	pop    %edi
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801221:	83 fa 01             	cmp    $0x1,%edx
  801224:	7f 13                	jg     801239 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801226:	85 d2                	test   %edx,%edx
  801228:	74 1c                	je     801246 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80122a:	8b 10                	mov    (%eax),%edx
  80122c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80122f:	89 08                	mov    %ecx,(%eax)
  801231:	8b 02                	mov    (%edx),%eax
  801233:	ba 00 00 00 00       	mov    $0x0,%edx
  801238:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  801239:	8b 10                	mov    (%eax),%edx
  80123b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80123e:	89 08                	mov    %ecx,(%eax)
  801240:	8b 02                	mov    (%edx),%eax
  801242:	8b 52 04             	mov    0x4(%edx),%edx
  801245:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  801246:	8b 10                	mov    (%eax),%edx
  801248:	8d 4a 04             	lea    0x4(%edx),%ecx
  80124b:	89 08                	mov    %ecx,(%eax)
  80124d:	8b 02                	mov    (%edx),%eax
  80124f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801254:	c3                   	ret    

00801255 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801255:	83 fa 01             	cmp    $0x1,%edx
  801258:	7f 0f                	jg     801269 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80125a:	85 d2                	test   %edx,%edx
  80125c:	74 18                	je     801276 <getint+0x21>
		return va_arg(*ap, long);
  80125e:	8b 10                	mov    (%eax),%edx
  801260:	8d 4a 04             	lea    0x4(%edx),%ecx
  801263:	89 08                	mov    %ecx,(%eax)
  801265:	8b 02                	mov    (%edx),%eax
  801267:	99                   	cltd   
  801268:	c3                   	ret    
		return va_arg(*ap, long long);
  801269:	8b 10                	mov    (%eax),%edx
  80126b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80126e:	89 08                	mov    %ecx,(%eax)
  801270:	8b 02                	mov    (%edx),%eax
  801272:	8b 52 04             	mov    0x4(%edx),%edx
  801275:	c3                   	ret    
	else
		return va_arg(*ap, int);
  801276:	8b 10                	mov    (%eax),%edx
  801278:	8d 4a 04             	lea    0x4(%edx),%ecx
  80127b:	89 08                	mov    %ecx,(%eax)
  80127d:	8b 02                	mov    (%edx),%eax
  80127f:	99                   	cltd   
}
  801280:	c3                   	ret    

00801281 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801281:	f3 0f 1e fb          	endbr32 
  801285:	55                   	push   %ebp
  801286:	89 e5                	mov    %esp,%ebp
  801288:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80128b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80128f:	8b 10                	mov    (%eax),%edx
  801291:	3b 50 04             	cmp    0x4(%eax),%edx
  801294:	73 0a                	jae    8012a0 <sprintputch+0x1f>
		*b->buf++ = ch;
  801296:	8d 4a 01             	lea    0x1(%edx),%ecx
  801299:	89 08                	mov    %ecx,(%eax)
  80129b:	8b 45 08             	mov    0x8(%ebp),%eax
  80129e:	88 02                	mov    %al,(%edx)
}
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <printfmt>:
{
  8012a2:	f3 0f 1e fb          	endbr32 
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012af:	50                   	push   %eax
  8012b0:	ff 75 10             	pushl  0x10(%ebp)
  8012b3:	ff 75 0c             	pushl  0xc(%ebp)
  8012b6:	ff 75 08             	pushl  0x8(%ebp)
  8012b9:	e8 05 00 00 00       	call   8012c3 <vprintfmt>
}
  8012be:	83 c4 10             	add    $0x10,%esp
  8012c1:	c9                   	leave  
  8012c2:	c3                   	ret    

008012c3 <vprintfmt>:
{
  8012c3:	f3 0f 1e fb          	endbr32 
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	57                   	push   %edi
  8012cb:	56                   	push   %esi
  8012cc:	53                   	push   %ebx
  8012cd:	83 ec 2c             	sub    $0x2c,%esp
  8012d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012d6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012d9:	e9 86 02 00 00       	jmp    801564 <vprintfmt+0x2a1>
		padc = ' ';
  8012de:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012e2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012e9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012f0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012f7:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012fc:	8d 47 01             	lea    0x1(%edi),%eax
  8012ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801302:	0f b6 17             	movzbl (%edi),%edx
  801305:	8d 42 dd             	lea    -0x23(%edx),%eax
  801308:	3c 55                	cmp    $0x55,%al
  80130a:	0f 87 df 02 00 00    	ja     8015ef <vprintfmt+0x32c>
  801310:	0f b6 c0             	movzbl %al,%eax
  801313:	3e ff 24 85 60 20 80 	notrack jmp *0x802060(,%eax,4)
  80131a:	00 
  80131b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80131e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801322:	eb d8                	jmp    8012fc <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801327:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80132b:	eb cf                	jmp    8012fc <vprintfmt+0x39>
  80132d:	0f b6 d2             	movzbl %dl,%edx
  801330:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801333:	b8 00 00 00 00       	mov    $0x0,%eax
  801338:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80133b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80133e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801342:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801345:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801348:	83 f9 09             	cmp    $0x9,%ecx
  80134b:	77 52                	ja     80139f <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  80134d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801350:	eb e9                	jmp    80133b <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801352:	8b 45 14             	mov    0x14(%ebp),%eax
  801355:	8d 50 04             	lea    0x4(%eax),%edx
  801358:	89 55 14             	mov    %edx,0x14(%ebp)
  80135b:	8b 00                	mov    (%eax),%eax
  80135d:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801363:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801367:	79 93                	jns    8012fc <vprintfmt+0x39>
				width = precision, precision = -1;
  801369:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80136c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80136f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801376:	eb 84                	jmp    8012fc <vprintfmt+0x39>
  801378:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80137b:	85 c0                	test   %eax,%eax
  80137d:	ba 00 00 00 00       	mov    $0x0,%edx
  801382:	0f 49 d0             	cmovns %eax,%edx
  801385:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80138b:	e9 6c ff ff ff       	jmp    8012fc <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801393:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80139a:	e9 5d ff ff ff       	jmp    8012fc <vprintfmt+0x39>
  80139f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013a2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8013a5:	eb bc                	jmp    801363 <vprintfmt+0xa0>
			lflag++;
  8013a7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8013aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013ad:	e9 4a ff ff ff       	jmp    8012fc <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b5:	8d 50 04             	lea    0x4(%eax),%edx
  8013b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	56                   	push   %esi
  8013bf:	ff 30                	pushl  (%eax)
  8013c1:	ff d3                	call   *%ebx
			break;
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	e9 96 01 00 00       	jmp    801561 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8013cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ce:	8d 50 04             	lea    0x4(%eax),%edx
  8013d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8013d4:	8b 00                	mov    (%eax),%eax
  8013d6:	99                   	cltd   
  8013d7:	31 d0                	xor    %edx,%eax
  8013d9:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013db:	83 f8 0f             	cmp    $0xf,%eax
  8013de:	7f 20                	jg     801400 <vprintfmt+0x13d>
  8013e0:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  8013e7:	85 d2                	test   %edx,%edx
  8013e9:	74 15                	je     801400 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8013eb:	52                   	push   %edx
  8013ec:	68 c1 1e 80 00       	push   $0x801ec1
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	e8 aa fe ff ff       	call   8012a2 <printfmt>
  8013f8:	83 c4 10             	add    $0x10,%esp
  8013fb:	e9 61 01 00 00       	jmp    801561 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  801400:	50                   	push   %eax
  801401:	68 43 1f 80 00       	push   $0x801f43
  801406:	56                   	push   %esi
  801407:	53                   	push   %ebx
  801408:	e8 95 fe ff ff       	call   8012a2 <printfmt>
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	e9 4c 01 00 00       	jmp    801561 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  801415:	8b 45 14             	mov    0x14(%ebp),%eax
  801418:	8d 50 04             	lea    0x4(%eax),%edx
  80141b:	89 55 14             	mov    %edx,0x14(%ebp)
  80141e:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  801420:	85 c9                	test   %ecx,%ecx
  801422:	b8 3c 1f 80 00       	mov    $0x801f3c,%eax
  801427:	0f 45 c1             	cmovne %ecx,%eax
  80142a:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80142d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801431:	7e 06                	jle    801439 <vprintfmt+0x176>
  801433:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801437:	75 0d                	jne    801446 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  801439:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80143c:	89 c7                	mov    %eax,%edi
  80143e:	03 45 e0             	add    -0x20(%ebp),%eax
  801441:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801444:	eb 57                	jmp    80149d <vprintfmt+0x1da>
  801446:	83 ec 08             	sub    $0x8,%esp
  801449:	ff 75 d8             	pushl  -0x28(%ebp)
  80144c:	ff 75 cc             	pushl  -0x34(%ebp)
  80144f:	e8 4f 02 00 00       	call   8016a3 <strnlen>
  801454:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801457:	29 c2                	sub    %eax,%edx
  801459:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80145c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80145f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801463:	89 5d 08             	mov    %ebx,0x8(%ebp)
  801466:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  801468:	85 db                	test   %ebx,%ebx
  80146a:	7e 10                	jle    80147c <vprintfmt+0x1b9>
					putch(padc, putdat);
  80146c:	83 ec 08             	sub    $0x8,%esp
  80146f:	56                   	push   %esi
  801470:	57                   	push   %edi
  801471:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801474:	83 eb 01             	sub    $0x1,%ebx
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	eb ec                	jmp    801468 <vprintfmt+0x1a5>
  80147c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80147f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801482:	85 d2                	test   %edx,%edx
  801484:	b8 00 00 00 00       	mov    $0x0,%eax
  801489:	0f 49 c2             	cmovns %edx,%eax
  80148c:	29 c2                	sub    %eax,%edx
  80148e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801491:	eb a6                	jmp    801439 <vprintfmt+0x176>
					putch(ch, putdat);
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	56                   	push   %esi
  801497:	52                   	push   %edx
  801498:	ff d3                	call   *%ebx
  80149a:	83 c4 10             	add    $0x10,%esp
  80149d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014a0:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014a2:	83 c7 01             	add    $0x1,%edi
  8014a5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014a9:	0f be d0             	movsbl %al,%edx
  8014ac:	85 d2                	test   %edx,%edx
  8014ae:	74 42                	je     8014f2 <vprintfmt+0x22f>
  8014b0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014b4:	78 06                	js     8014bc <vprintfmt+0x1f9>
  8014b6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014ba:	78 1e                	js     8014da <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8014bc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014c0:	74 d1                	je     801493 <vprintfmt+0x1d0>
  8014c2:	0f be c0             	movsbl %al,%eax
  8014c5:	83 e8 20             	sub    $0x20,%eax
  8014c8:	83 f8 5e             	cmp    $0x5e,%eax
  8014cb:	76 c6                	jbe    801493 <vprintfmt+0x1d0>
					putch('?', putdat);
  8014cd:	83 ec 08             	sub    $0x8,%esp
  8014d0:	56                   	push   %esi
  8014d1:	6a 3f                	push   $0x3f
  8014d3:	ff d3                	call   *%ebx
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	eb c3                	jmp    80149d <vprintfmt+0x1da>
  8014da:	89 cf                	mov    %ecx,%edi
  8014dc:	eb 0e                	jmp    8014ec <vprintfmt+0x229>
				putch(' ', putdat);
  8014de:	83 ec 08             	sub    $0x8,%esp
  8014e1:	56                   	push   %esi
  8014e2:	6a 20                	push   $0x20
  8014e4:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8014e6:	83 ef 01             	sub    $0x1,%edi
  8014e9:	83 c4 10             	add    $0x10,%esp
  8014ec:	85 ff                	test   %edi,%edi
  8014ee:	7f ee                	jg     8014de <vprintfmt+0x21b>
  8014f0:	eb 6f                	jmp    801561 <vprintfmt+0x29e>
  8014f2:	89 cf                	mov    %ecx,%edi
  8014f4:	eb f6                	jmp    8014ec <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8014f6:	89 ca                	mov    %ecx,%edx
  8014f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8014fb:	e8 55 fd ff ff       	call   801255 <getint>
  801500:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801503:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  801506:	85 d2                	test   %edx,%edx
  801508:	78 0b                	js     801515 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  80150a:	89 d1                	mov    %edx,%ecx
  80150c:	89 c2                	mov    %eax,%edx
			base = 10;
  80150e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801513:	eb 32                	jmp    801547 <vprintfmt+0x284>
				putch('-', putdat);
  801515:	83 ec 08             	sub    $0x8,%esp
  801518:	56                   	push   %esi
  801519:	6a 2d                	push   $0x2d
  80151b:	ff d3                	call   *%ebx
				num = -(long long) num;
  80151d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801520:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801523:	f7 da                	neg    %edx
  801525:	83 d1 00             	adc    $0x0,%ecx
  801528:	f7 d9                	neg    %ecx
  80152a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80152d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801532:	eb 13                	jmp    801547 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  801534:	89 ca                	mov    %ecx,%edx
  801536:	8d 45 14             	lea    0x14(%ebp),%eax
  801539:	e8 e3 fc ff ff       	call   801221 <getuint>
  80153e:	89 d1                	mov    %edx,%ecx
  801540:	89 c2                	mov    %eax,%edx
			base = 10;
  801542:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  801547:	83 ec 0c             	sub    $0xc,%esp
  80154a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80154e:	57                   	push   %edi
  80154f:	ff 75 e0             	pushl  -0x20(%ebp)
  801552:	50                   	push   %eax
  801553:	51                   	push   %ecx
  801554:	52                   	push   %edx
  801555:	89 f2                	mov    %esi,%edx
  801557:	89 d8                	mov    %ebx,%eax
  801559:	e8 1a fc ff ff       	call   801178 <printnum>
			break;
  80155e:	83 c4 20             	add    $0x20,%esp
{
  801561:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801564:	83 c7 01             	add    $0x1,%edi
  801567:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80156b:	83 f8 25             	cmp    $0x25,%eax
  80156e:	0f 84 6a fd ff ff    	je     8012de <vprintfmt+0x1b>
			if (ch == '\0')
  801574:	85 c0                	test   %eax,%eax
  801576:	0f 84 93 00 00 00    	je     80160f <vprintfmt+0x34c>
			putch(ch, putdat);
  80157c:	83 ec 08             	sub    $0x8,%esp
  80157f:	56                   	push   %esi
  801580:	50                   	push   %eax
  801581:	ff d3                	call   *%ebx
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	eb dc                	jmp    801564 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  801588:	89 ca                	mov    %ecx,%edx
  80158a:	8d 45 14             	lea    0x14(%ebp),%eax
  80158d:	e8 8f fc ff ff       	call   801221 <getuint>
  801592:	89 d1                	mov    %edx,%ecx
  801594:	89 c2                	mov    %eax,%edx
			base = 8;
  801596:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80159b:	eb aa                	jmp    801547 <vprintfmt+0x284>
			putch('0', putdat);
  80159d:	83 ec 08             	sub    $0x8,%esp
  8015a0:	56                   	push   %esi
  8015a1:	6a 30                	push   $0x30
  8015a3:	ff d3                	call   *%ebx
			putch('x', putdat);
  8015a5:	83 c4 08             	add    $0x8,%esp
  8015a8:	56                   	push   %esi
  8015a9:	6a 78                	push   $0x78
  8015ab:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8015ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b0:	8d 50 04             	lea    0x4(%eax),%edx
  8015b3:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8015b6:	8b 10                	mov    (%eax),%edx
  8015b8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015bd:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8015c0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015c5:	eb 80                	jmp    801547 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8015c7:	89 ca                	mov    %ecx,%edx
  8015c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8015cc:	e8 50 fc ff ff       	call   801221 <getuint>
  8015d1:	89 d1                	mov    %edx,%ecx
  8015d3:	89 c2                	mov    %eax,%edx
			base = 16;
  8015d5:	b8 10 00 00 00       	mov    $0x10,%eax
  8015da:	e9 68 ff ff ff       	jmp    801547 <vprintfmt+0x284>
			putch(ch, putdat);
  8015df:	83 ec 08             	sub    $0x8,%esp
  8015e2:	56                   	push   %esi
  8015e3:	6a 25                	push   $0x25
  8015e5:	ff d3                	call   *%ebx
			break;
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	e9 72 ff ff ff       	jmp    801561 <vprintfmt+0x29e>
			putch('%', putdat);
  8015ef:	83 ec 08             	sub    $0x8,%esp
  8015f2:	56                   	push   %esi
  8015f3:	6a 25                	push   $0x25
  8015f5:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	89 f8                	mov    %edi,%eax
  8015fc:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801600:	74 05                	je     801607 <vprintfmt+0x344>
  801602:	83 e8 01             	sub    $0x1,%eax
  801605:	eb f5                	jmp    8015fc <vprintfmt+0x339>
  801607:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80160a:	e9 52 ff ff ff       	jmp    801561 <vprintfmt+0x29e>
}
  80160f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801612:	5b                   	pop    %ebx
  801613:	5e                   	pop    %esi
  801614:	5f                   	pop    %edi
  801615:	5d                   	pop    %ebp
  801616:	c3                   	ret    

00801617 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801617:	f3 0f 1e fb          	endbr32 
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	83 ec 18             	sub    $0x18,%esp
  801621:	8b 45 08             	mov    0x8(%ebp),%eax
  801624:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801627:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80162a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80162e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801631:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801638:	85 c0                	test   %eax,%eax
  80163a:	74 26                	je     801662 <vsnprintf+0x4b>
  80163c:	85 d2                	test   %edx,%edx
  80163e:	7e 22                	jle    801662 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801640:	ff 75 14             	pushl  0x14(%ebp)
  801643:	ff 75 10             	pushl  0x10(%ebp)
  801646:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801649:	50                   	push   %eax
  80164a:	68 81 12 80 00       	push   $0x801281
  80164f:	e8 6f fc ff ff       	call   8012c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801654:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801657:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80165a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165d:	83 c4 10             	add    $0x10,%esp
}
  801660:	c9                   	leave  
  801661:	c3                   	ret    
		return -E_INVAL;
  801662:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801667:	eb f7                	jmp    801660 <vsnprintf+0x49>

00801669 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801669:	f3 0f 1e fb          	endbr32 
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801673:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801676:	50                   	push   %eax
  801677:	ff 75 10             	pushl  0x10(%ebp)
  80167a:	ff 75 0c             	pushl  0xc(%ebp)
  80167d:	ff 75 08             	pushl  0x8(%ebp)
  801680:	e8 92 ff ff ff       	call   801617 <vsnprintf>
	va_end(ap);

	return rc;
}
  801685:	c9                   	leave  
  801686:	c3                   	ret    

00801687 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801687:	f3 0f 1e fb          	endbr32 
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801691:	b8 00 00 00 00       	mov    $0x0,%eax
  801696:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80169a:	74 05                	je     8016a1 <strlen+0x1a>
		n++;
  80169c:	83 c0 01             	add    $0x1,%eax
  80169f:	eb f5                	jmp    801696 <strlen+0xf>
	return n;
}
  8016a1:	5d                   	pop    %ebp
  8016a2:	c3                   	ret    

008016a3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016a3:	f3 0f 1e fb          	endbr32 
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b5:	39 d0                	cmp    %edx,%eax
  8016b7:	74 0d                	je     8016c6 <strnlen+0x23>
  8016b9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016bd:	74 05                	je     8016c4 <strnlen+0x21>
		n++;
  8016bf:	83 c0 01             	add    $0x1,%eax
  8016c2:	eb f1                	jmp    8016b5 <strnlen+0x12>
  8016c4:	89 c2                	mov    %eax,%edx
	return n;
}
  8016c6:	89 d0                	mov    %edx,%eax
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016ca:	f3 0f 1e fb          	endbr32 
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	53                   	push   %ebx
  8016d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016dd:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016e1:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016e4:	83 c0 01             	add    $0x1,%eax
  8016e7:	84 d2                	test   %dl,%dl
  8016e9:	75 f2                	jne    8016dd <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8016eb:	89 c8                	mov    %ecx,%eax
  8016ed:	5b                   	pop    %ebx
  8016ee:	5d                   	pop    %ebp
  8016ef:	c3                   	ret    

008016f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016f0:	f3 0f 1e fb          	endbr32 
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	53                   	push   %ebx
  8016f8:	83 ec 10             	sub    $0x10,%esp
  8016fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016fe:	53                   	push   %ebx
  8016ff:	e8 83 ff ff ff       	call   801687 <strlen>
  801704:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801707:	ff 75 0c             	pushl  0xc(%ebp)
  80170a:	01 d8                	add    %ebx,%eax
  80170c:	50                   	push   %eax
  80170d:	e8 b8 ff ff ff       	call   8016ca <strcpy>
	return dst;
}
  801712:	89 d8                	mov    %ebx,%eax
  801714:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801717:	c9                   	leave  
  801718:	c3                   	ret    

00801719 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801719:	f3 0f 1e fb          	endbr32 
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	56                   	push   %esi
  801721:	53                   	push   %ebx
  801722:	8b 75 08             	mov    0x8(%ebp),%esi
  801725:	8b 55 0c             	mov    0xc(%ebp),%edx
  801728:	89 f3                	mov    %esi,%ebx
  80172a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80172d:	89 f0                	mov    %esi,%eax
  80172f:	39 d8                	cmp    %ebx,%eax
  801731:	74 11                	je     801744 <strncpy+0x2b>
		*dst++ = *src;
  801733:	83 c0 01             	add    $0x1,%eax
  801736:	0f b6 0a             	movzbl (%edx),%ecx
  801739:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80173c:	80 f9 01             	cmp    $0x1,%cl
  80173f:	83 da ff             	sbb    $0xffffffff,%edx
  801742:	eb eb                	jmp    80172f <strncpy+0x16>
	}
	return ret;
}
  801744:	89 f0                	mov    %esi,%eax
  801746:	5b                   	pop    %ebx
  801747:	5e                   	pop    %esi
  801748:	5d                   	pop    %ebp
  801749:	c3                   	ret    

0080174a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80174a:	f3 0f 1e fb          	endbr32 
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	56                   	push   %esi
  801752:	53                   	push   %ebx
  801753:	8b 75 08             	mov    0x8(%ebp),%esi
  801756:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801759:	8b 55 10             	mov    0x10(%ebp),%edx
  80175c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80175e:	85 d2                	test   %edx,%edx
  801760:	74 21                	je     801783 <strlcpy+0x39>
  801762:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801766:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801768:	39 c2                	cmp    %eax,%edx
  80176a:	74 14                	je     801780 <strlcpy+0x36>
  80176c:	0f b6 19             	movzbl (%ecx),%ebx
  80176f:	84 db                	test   %bl,%bl
  801771:	74 0b                	je     80177e <strlcpy+0x34>
			*dst++ = *src++;
  801773:	83 c1 01             	add    $0x1,%ecx
  801776:	83 c2 01             	add    $0x1,%edx
  801779:	88 5a ff             	mov    %bl,-0x1(%edx)
  80177c:	eb ea                	jmp    801768 <strlcpy+0x1e>
  80177e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801780:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801783:	29 f0                	sub    %esi,%eax
}
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801789:	f3 0f 1e fb          	endbr32 
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801793:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801796:	0f b6 01             	movzbl (%ecx),%eax
  801799:	84 c0                	test   %al,%al
  80179b:	74 0c                	je     8017a9 <strcmp+0x20>
  80179d:	3a 02                	cmp    (%edx),%al
  80179f:	75 08                	jne    8017a9 <strcmp+0x20>
		p++, q++;
  8017a1:	83 c1 01             	add    $0x1,%ecx
  8017a4:	83 c2 01             	add    $0x1,%edx
  8017a7:	eb ed                	jmp    801796 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a9:	0f b6 c0             	movzbl %al,%eax
  8017ac:	0f b6 12             	movzbl (%edx),%edx
  8017af:	29 d0                	sub    %edx,%eax
}
  8017b1:	5d                   	pop    %ebp
  8017b2:	c3                   	ret    

008017b3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017b3:	f3 0f 1e fb          	endbr32 
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	53                   	push   %ebx
  8017bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c1:	89 c3                	mov    %eax,%ebx
  8017c3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017c6:	eb 06                	jmp    8017ce <strncmp+0x1b>
		n--, p++, q++;
  8017c8:	83 c0 01             	add    $0x1,%eax
  8017cb:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017ce:	39 d8                	cmp    %ebx,%eax
  8017d0:	74 16                	je     8017e8 <strncmp+0x35>
  8017d2:	0f b6 08             	movzbl (%eax),%ecx
  8017d5:	84 c9                	test   %cl,%cl
  8017d7:	74 04                	je     8017dd <strncmp+0x2a>
  8017d9:	3a 0a                	cmp    (%edx),%cl
  8017db:	74 eb                	je     8017c8 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017dd:	0f b6 00             	movzbl (%eax),%eax
  8017e0:	0f b6 12             	movzbl (%edx),%edx
  8017e3:	29 d0                	sub    %edx,%eax
}
  8017e5:	5b                   	pop    %ebx
  8017e6:	5d                   	pop    %ebp
  8017e7:	c3                   	ret    
		return 0;
  8017e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ed:	eb f6                	jmp    8017e5 <strncmp+0x32>

008017ef <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017ef:	f3 0f 1e fb          	endbr32 
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017fd:	0f b6 10             	movzbl (%eax),%edx
  801800:	84 d2                	test   %dl,%dl
  801802:	74 09                	je     80180d <strchr+0x1e>
		if (*s == c)
  801804:	38 ca                	cmp    %cl,%dl
  801806:	74 0a                	je     801812 <strchr+0x23>
	for (; *s; s++)
  801808:	83 c0 01             	add    $0x1,%eax
  80180b:	eb f0                	jmp    8017fd <strchr+0xe>
			return (char *) s;
	return 0;
  80180d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    

00801814 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801814:	f3 0f 1e fb          	endbr32 
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	8b 45 08             	mov    0x8(%ebp),%eax
  80181e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801822:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801825:	38 ca                	cmp    %cl,%dl
  801827:	74 09                	je     801832 <strfind+0x1e>
  801829:	84 d2                	test   %dl,%dl
  80182b:	74 05                	je     801832 <strfind+0x1e>
	for (; *s; s++)
  80182d:	83 c0 01             	add    $0x1,%eax
  801830:	eb f0                	jmp    801822 <strfind+0xe>
			break;
	return (char *) s;
}
  801832:	5d                   	pop    %ebp
  801833:	c3                   	ret    

00801834 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801834:	f3 0f 1e fb          	endbr32 
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	57                   	push   %edi
  80183c:	56                   	push   %esi
  80183d:	53                   	push   %ebx
  80183e:	8b 55 08             	mov    0x8(%ebp),%edx
  801841:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  801844:	85 c9                	test   %ecx,%ecx
  801846:	74 33                	je     80187b <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801848:	89 d0                	mov    %edx,%eax
  80184a:	09 c8                	or     %ecx,%eax
  80184c:	a8 03                	test   $0x3,%al
  80184e:	75 23                	jne    801873 <memset+0x3f>
		c &= 0xFF;
  801850:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801854:	89 d8                	mov    %ebx,%eax
  801856:	c1 e0 08             	shl    $0x8,%eax
  801859:	89 df                	mov    %ebx,%edi
  80185b:	c1 e7 18             	shl    $0x18,%edi
  80185e:	89 de                	mov    %ebx,%esi
  801860:	c1 e6 10             	shl    $0x10,%esi
  801863:	09 f7                	or     %esi,%edi
  801865:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  801867:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80186a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80186c:	89 d7                	mov    %edx,%edi
  80186e:	fc                   	cld    
  80186f:	f3 ab                	rep stos %eax,%es:(%edi)
  801871:	eb 08                	jmp    80187b <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801873:	89 d7                	mov    %edx,%edi
  801875:	8b 45 0c             	mov    0xc(%ebp),%eax
  801878:	fc                   	cld    
  801879:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  80187b:	89 d0                	mov    %edx,%eax
  80187d:	5b                   	pop    %ebx
  80187e:	5e                   	pop    %esi
  80187f:	5f                   	pop    %edi
  801880:	5d                   	pop    %ebp
  801881:	c3                   	ret    

00801882 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801882:	f3 0f 1e fb          	endbr32 
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	57                   	push   %edi
  80188a:	56                   	push   %esi
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801891:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801894:	39 c6                	cmp    %eax,%esi
  801896:	73 32                	jae    8018ca <memmove+0x48>
  801898:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80189b:	39 c2                	cmp    %eax,%edx
  80189d:	76 2b                	jbe    8018ca <memmove+0x48>
		s += n;
		d += n;
  80189f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a2:	89 fe                	mov    %edi,%esi
  8018a4:	09 ce                	or     %ecx,%esi
  8018a6:	09 d6                	or     %edx,%esi
  8018a8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018ae:	75 0e                	jne    8018be <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018b0:	83 ef 04             	sub    $0x4,%edi
  8018b3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018b6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018b9:	fd                   	std    
  8018ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018bc:	eb 09                	jmp    8018c7 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018be:	83 ef 01             	sub    $0x1,%edi
  8018c1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018c4:	fd                   	std    
  8018c5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018c7:	fc                   	cld    
  8018c8:	eb 1a                	jmp    8018e4 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ca:	89 c2                	mov    %eax,%edx
  8018cc:	09 ca                	or     %ecx,%edx
  8018ce:	09 f2                	or     %esi,%edx
  8018d0:	f6 c2 03             	test   $0x3,%dl
  8018d3:	75 0a                	jne    8018df <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018d5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018d8:	89 c7                	mov    %eax,%edi
  8018da:	fc                   	cld    
  8018db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018dd:	eb 05                	jmp    8018e4 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8018df:	89 c7                	mov    %eax,%edi
  8018e1:	fc                   	cld    
  8018e2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018e4:	5e                   	pop    %esi
  8018e5:	5f                   	pop    %edi
  8018e6:	5d                   	pop    %ebp
  8018e7:	c3                   	ret    

008018e8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018e8:	f3 0f 1e fb          	endbr32 
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018f2:	ff 75 10             	pushl  0x10(%ebp)
  8018f5:	ff 75 0c             	pushl  0xc(%ebp)
  8018f8:	ff 75 08             	pushl  0x8(%ebp)
  8018fb:	e8 82 ff ff ff       	call   801882 <memmove>
}
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801902:	f3 0f 1e fb          	endbr32 
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	56                   	push   %esi
  80190a:	53                   	push   %ebx
  80190b:	8b 45 08             	mov    0x8(%ebp),%eax
  80190e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801911:	89 c6                	mov    %eax,%esi
  801913:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801916:	39 f0                	cmp    %esi,%eax
  801918:	74 1c                	je     801936 <memcmp+0x34>
		if (*s1 != *s2)
  80191a:	0f b6 08             	movzbl (%eax),%ecx
  80191d:	0f b6 1a             	movzbl (%edx),%ebx
  801920:	38 d9                	cmp    %bl,%cl
  801922:	75 08                	jne    80192c <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801924:	83 c0 01             	add    $0x1,%eax
  801927:	83 c2 01             	add    $0x1,%edx
  80192a:	eb ea                	jmp    801916 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  80192c:	0f b6 c1             	movzbl %cl,%eax
  80192f:	0f b6 db             	movzbl %bl,%ebx
  801932:	29 d8                	sub    %ebx,%eax
  801934:	eb 05                	jmp    80193b <memcmp+0x39>
	}

	return 0;
  801936:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80193b:	5b                   	pop    %ebx
  80193c:	5e                   	pop    %esi
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    

0080193f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80193f:	f3 0f 1e fb          	endbr32 
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	8b 45 08             	mov    0x8(%ebp),%eax
  801949:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80194c:	89 c2                	mov    %eax,%edx
  80194e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801951:	39 d0                	cmp    %edx,%eax
  801953:	73 09                	jae    80195e <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801955:	38 08                	cmp    %cl,(%eax)
  801957:	74 05                	je     80195e <memfind+0x1f>
	for (; s < ends; s++)
  801959:	83 c0 01             	add    $0x1,%eax
  80195c:	eb f3                	jmp    801951 <memfind+0x12>
			break;
	return (void *) s;
}
  80195e:	5d                   	pop    %ebp
  80195f:	c3                   	ret    

00801960 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801960:	f3 0f 1e fb          	endbr32 
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	57                   	push   %edi
  801968:	56                   	push   %esi
  801969:	53                   	push   %ebx
  80196a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80196d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801970:	eb 03                	jmp    801975 <strtol+0x15>
		s++;
  801972:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801975:	0f b6 01             	movzbl (%ecx),%eax
  801978:	3c 20                	cmp    $0x20,%al
  80197a:	74 f6                	je     801972 <strtol+0x12>
  80197c:	3c 09                	cmp    $0x9,%al
  80197e:	74 f2                	je     801972 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801980:	3c 2b                	cmp    $0x2b,%al
  801982:	74 2a                	je     8019ae <strtol+0x4e>
	int neg = 0;
  801984:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801989:	3c 2d                	cmp    $0x2d,%al
  80198b:	74 2b                	je     8019b8 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80198d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801993:	75 0f                	jne    8019a4 <strtol+0x44>
  801995:	80 39 30             	cmpb   $0x30,(%ecx)
  801998:	74 28                	je     8019c2 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80199a:	85 db                	test   %ebx,%ebx
  80199c:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019a1:	0f 44 d8             	cmove  %eax,%ebx
  8019a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019ac:	eb 46                	jmp    8019f4 <strtol+0x94>
		s++;
  8019ae:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8019b6:	eb d5                	jmp    80198d <strtol+0x2d>
		s++, neg = 1;
  8019b8:	83 c1 01             	add    $0x1,%ecx
  8019bb:	bf 01 00 00 00       	mov    $0x1,%edi
  8019c0:	eb cb                	jmp    80198d <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019c2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019c6:	74 0e                	je     8019d6 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019c8:	85 db                	test   %ebx,%ebx
  8019ca:	75 d8                	jne    8019a4 <strtol+0x44>
		s++, base = 8;
  8019cc:	83 c1 01             	add    $0x1,%ecx
  8019cf:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019d4:	eb ce                	jmp    8019a4 <strtol+0x44>
		s += 2, base = 16;
  8019d6:	83 c1 02             	add    $0x2,%ecx
  8019d9:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019de:	eb c4                	jmp    8019a4 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019e0:	0f be d2             	movsbl %dl,%edx
  8019e3:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019e6:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019e9:	7d 3a                	jge    801a25 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019eb:	83 c1 01             	add    $0x1,%ecx
  8019ee:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019f2:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019f4:	0f b6 11             	movzbl (%ecx),%edx
  8019f7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019fa:	89 f3                	mov    %esi,%ebx
  8019fc:	80 fb 09             	cmp    $0x9,%bl
  8019ff:	76 df                	jbe    8019e0 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801a01:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a04:	89 f3                	mov    %esi,%ebx
  801a06:	80 fb 19             	cmp    $0x19,%bl
  801a09:	77 08                	ja     801a13 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a0b:	0f be d2             	movsbl %dl,%edx
  801a0e:	83 ea 57             	sub    $0x57,%edx
  801a11:	eb d3                	jmp    8019e6 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801a13:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a16:	89 f3                	mov    %esi,%ebx
  801a18:	80 fb 19             	cmp    $0x19,%bl
  801a1b:	77 08                	ja     801a25 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a1d:	0f be d2             	movsbl %dl,%edx
  801a20:	83 ea 37             	sub    $0x37,%edx
  801a23:	eb c1                	jmp    8019e6 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a25:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a29:	74 05                	je     801a30 <strtol+0xd0>
		*endptr = (char *) s;
  801a2b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a2e:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a30:	89 c2                	mov    %eax,%edx
  801a32:	f7 da                	neg    %edx
  801a34:	85 ff                	test   %edi,%edi
  801a36:	0f 45 c2             	cmovne %edx,%eax
}
  801a39:	5b                   	pop    %ebx
  801a3a:	5e                   	pop    %esi
  801a3b:	5f                   	pop    %edi
  801a3c:	5d                   	pop    %ebp
  801a3d:	c3                   	ret    

00801a3e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a3e:	f3 0f 1e fb          	endbr32 
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	56                   	push   %esi
  801a46:	53                   	push   %ebx
  801a47:	8b 75 08             	mov    0x8(%ebp),%esi
  801a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  801a50:	85 c0                	test   %eax,%eax
  801a52:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a57:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	50                   	push   %eax
  801a5e:	e8 82 e8 ff ff       	call   8002e5 <sys_ipc_recv>
	if (f < 0) {
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	85 c0                	test   %eax,%eax
  801a68:	78 2b                	js     801a95 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801a6a:	85 f6                	test   %esi,%esi
  801a6c:	74 0a                	je     801a78 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801a6e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a73:	8b 40 74             	mov    0x74(%eax),%eax
  801a76:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801a78:	85 db                	test   %ebx,%ebx
  801a7a:	74 0a                	je     801a86 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801a7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a81:	8b 40 78             	mov    0x78(%eax),%eax
  801a84:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  801a86:	a1 04 40 80 00       	mov    0x804004,%eax
  801a8b:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a91:	5b                   	pop    %ebx
  801a92:	5e                   	pop    %esi
  801a93:	5d                   	pop    %ebp
  801a94:	c3                   	ret    
		if (from_env_store != NULL) {
  801a95:	85 f6                	test   %esi,%esi
  801a97:	74 06                	je     801a9f <ipc_recv+0x61>
			*from_env_store = 0;
  801a99:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801a9f:	85 db                	test   %ebx,%ebx
  801aa1:	74 eb                	je     801a8e <ipc_recv+0x50>
			*perm_store = 0;
  801aa3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aa9:	eb e3                	jmp    801a8e <ipc_recv+0x50>

00801aab <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aab:	f3 0f 1e fb          	endbr32 
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	57                   	push   %edi
  801ab3:	56                   	push   %esi
  801ab4:	53                   	push   %ebx
  801ab5:	83 ec 0c             	sub    $0xc,%esp
  801ab8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801abb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801abe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  801ac1:	85 db                	test   %ebx,%ebx
  801ac3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ac8:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801acb:	ff 75 14             	pushl  0x14(%ebp)
  801ace:	53                   	push   %ebx
  801acf:	56                   	push   %esi
  801ad0:	57                   	push   %edi
  801ad1:	e8 e6 e7 ff ff       	call   8002bc <sys_ipc_try_send>
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	85 c0                	test   %eax,%eax
  801adb:	79 19                	jns    801af6 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  801add:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ae0:	74 e9                	je     801acb <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  801ae2:	83 ec 04             	sub    $0x4,%esp
  801ae5:	68 20 22 80 00       	push   $0x802220
  801aea:	6a 48                	push   $0x48
  801aec:	68 42 22 80 00       	push   $0x802242
  801af1:	e8 83 f5 ff ff       	call   801079 <_panic>
		}
	}
}
  801af6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af9:	5b                   	pop    %ebx
  801afa:	5e                   	pop    %esi
  801afb:	5f                   	pop    %edi
  801afc:	5d                   	pop    %ebp
  801afd:	c3                   	ret    

00801afe <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801afe:	f3 0f 1e fb          	endbr32 
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b08:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b0d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b10:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b16:	8b 52 50             	mov    0x50(%edx),%edx
  801b19:	39 ca                	cmp    %ecx,%edx
  801b1b:	74 11                	je     801b2e <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801b1d:	83 c0 01             	add    $0x1,%eax
  801b20:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b25:	75 e6                	jne    801b0d <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b27:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2c:	eb 0b                	jmp    801b39 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b2e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b31:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b36:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b39:	5d                   	pop    %ebp
  801b3a:	c3                   	ret    

00801b3b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b3b:	f3 0f 1e fb          	endbr32 
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b45:	89 c2                	mov    %eax,%edx
  801b47:	c1 ea 16             	shr    $0x16,%edx
  801b4a:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b51:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b56:	f6 c1 01             	test   $0x1,%cl
  801b59:	74 1c                	je     801b77 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b5b:	c1 e8 0c             	shr    $0xc,%eax
  801b5e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b65:	a8 01                	test   $0x1,%al
  801b67:	74 0e                	je     801b77 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b69:	c1 e8 0c             	shr    $0xc,%eax
  801b6c:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b73:	ef 
  801b74:	0f b7 d2             	movzwl %dx,%edx
}
  801b77:	89 d0                	mov    %edx,%eax
  801b79:	5d                   	pop    %ebp
  801b7a:	c3                   	ret    
  801b7b:	66 90                	xchg   %ax,%ax
  801b7d:	66 90                	xchg   %ax,%ax
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
