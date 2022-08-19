
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 27 00 00 00       	call   800058 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003d:	68 15 03 80 00       	push   $0x800315
  800042:	6a 00                	push   $0x0
  800044:	e8 56 02 00 00       	call   80029f <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800049:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800050:	00 00 00 
}
  800053:	83 c4 10             	add    $0x10,%esp
  800056:	c9                   	leave  
  800057:	c3                   	ret    

00800058 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800058:	f3 0f 1e fb          	endbr32 
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800064:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800067:	e8 19 01 00 00       	call   800185 <sys_getenvid>
	if (id >= 0)
  80006c:	85 c0                	test   %eax,%eax
  80006e:	78 12                	js     800082 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x35>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	f3 0f 1e fb          	endbr32 
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b0:	e8 79 04 00 00       	call   80052e <close_all>
	sys_env_destroy(0);
  8000b5:	83 ec 0c             	sub    $0xc,%esp
  8000b8:	6a 00                	push   $0x0
  8000ba:	e8 a0 00 00 00       	call   80015f <sys_env_destroy>
}
  8000bf:	83 c4 10             	add    $0x10,%esp
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
  8000ca:	83 ec 1c             	sub    $0x1c,%esp
  8000cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000d3:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000db:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000de:	8b 75 14             	mov    0x14(%ebp),%esi
  8000e1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000e3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000e7:	74 04                	je     8000ed <syscall+0x29>
  8000e9:	85 c0                	test   %eax,%eax
  8000eb:	7f 08                	jg     8000f5 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	50                   	push   %eax
  8000f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8000fc:	68 8a 1e 80 00       	push   $0x801e8a
  800101:	6a 23                	push   $0x23
  800103:	68 a7 1e 80 00       	push   $0x801ea7
  800108:	e8 9c 0f 00 00       	call   8010a9 <_panic>

0080010d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  80010d:	f3 0f 1e fb          	endbr32 
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800117:	6a 00                	push   $0x0
  800119:	6a 00                	push   $0x0
  80011b:	6a 00                	push   $0x0
  80011d:	ff 75 0c             	pushl  0xc(%ebp)
  800120:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800123:	ba 00 00 00 00       	mov    $0x0,%edx
  800128:	b8 00 00 00 00       	mov    $0x0,%eax
  80012d:	e8 92 ff ff ff       	call   8000c4 <syscall>
}
  800132:	83 c4 10             	add    $0x10,%esp
  800135:	c9                   	leave  
  800136:	c3                   	ret    

00800137 <sys_cgetc>:

int
sys_cgetc(void)
{
  800137:	f3 0f 1e fb          	endbr32 
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800141:	6a 00                	push   $0x0
  800143:	6a 00                	push   $0x0
  800145:	6a 00                	push   $0x0
  800147:	6a 00                	push   $0x0
  800149:	b9 00 00 00 00       	mov    $0x0,%ecx
  80014e:	ba 00 00 00 00       	mov    $0x0,%edx
  800153:	b8 01 00 00 00       	mov    $0x1,%eax
  800158:	e8 67 ff ff ff       	call   8000c4 <syscall>
}
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80015f:	f3 0f 1e fb          	endbr32 
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800169:	6a 00                	push   $0x0
  80016b:	6a 00                	push   $0x0
  80016d:	6a 00                	push   $0x0
  80016f:	6a 00                	push   $0x0
  800171:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800174:	ba 01 00 00 00       	mov    $0x1,%edx
  800179:	b8 03 00 00 00       	mov    $0x3,%eax
  80017e:	e8 41 ff ff ff       	call   8000c4 <syscall>
}
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800185:	f3 0f 1e fb          	endbr32 
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80018f:	6a 00                	push   $0x0
  800191:	6a 00                	push   $0x0
  800193:	6a 00                	push   $0x0
  800195:	6a 00                	push   $0x0
  800197:	b9 00 00 00 00       	mov    $0x0,%ecx
  80019c:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a1:	b8 02 00 00 00       	mov    $0x2,%eax
  8001a6:	e8 19 ff ff ff       	call   8000c4 <syscall>
}
  8001ab:	c9                   	leave  
  8001ac:	c3                   	ret    

008001ad <sys_yield>:

void
sys_yield(void)
{
  8001ad:	f3 0f 1e fb          	endbr32 
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001b7:	6a 00                	push   $0x0
  8001b9:	6a 00                	push   $0x0
  8001bb:	6a 00                	push   $0x0
  8001bd:	6a 00                	push   $0x0
  8001bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001ce:	e8 f1 fe ff ff       	call   8000c4 <syscall>
}
  8001d3:	83 c4 10             	add    $0x10,%esp
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001d8:	f3 0f 1e fb          	endbr32 
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001e2:	6a 00                	push   $0x0
  8001e4:	6a 00                	push   $0x0
  8001e6:	ff 75 10             	pushl  0x10(%ebp)
  8001e9:	ff 75 0c             	pushl  0xc(%ebp)
  8001ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ef:	ba 01 00 00 00       	mov    $0x1,%edx
  8001f4:	b8 04 00 00 00       	mov    $0x4,%eax
  8001f9:	e8 c6 fe ff ff       	call   8000c4 <syscall>
}
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800200:	f3 0f 1e fb          	endbr32 
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80020a:	ff 75 18             	pushl  0x18(%ebp)
  80020d:	ff 75 14             	pushl  0x14(%ebp)
  800210:	ff 75 10             	pushl  0x10(%ebp)
  800213:	ff 75 0c             	pushl  0xc(%ebp)
  800216:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800219:	ba 01 00 00 00       	mov    $0x1,%edx
  80021e:	b8 05 00 00 00       	mov    $0x5,%eax
  800223:	e8 9c fe ff ff       	call   8000c4 <syscall>
}
  800228:	c9                   	leave  
  800229:	c3                   	ret    

0080022a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80022a:	f3 0f 1e fb          	endbr32 
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800234:	6a 00                	push   $0x0
  800236:	6a 00                	push   $0x0
  800238:	6a 00                	push   $0x0
  80023a:	ff 75 0c             	pushl  0xc(%ebp)
  80023d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800240:	ba 01 00 00 00       	mov    $0x1,%edx
  800245:	b8 06 00 00 00       	mov    $0x6,%eax
  80024a:	e8 75 fe ff ff       	call   8000c4 <syscall>
}
  80024f:	c9                   	leave  
  800250:	c3                   	ret    

00800251 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800251:	f3 0f 1e fb          	endbr32 
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80025b:	6a 00                	push   $0x0
  80025d:	6a 00                	push   $0x0
  80025f:	6a 00                	push   $0x0
  800261:	ff 75 0c             	pushl  0xc(%ebp)
  800264:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800267:	ba 01 00 00 00       	mov    $0x1,%edx
  80026c:	b8 08 00 00 00       	mov    $0x8,%eax
  800271:	e8 4e fe ff ff       	call   8000c4 <syscall>
}
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800278:	f3 0f 1e fb          	endbr32 
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800282:	6a 00                	push   $0x0
  800284:	6a 00                	push   $0x0
  800286:	6a 00                	push   $0x0
  800288:	ff 75 0c             	pushl  0xc(%ebp)
  80028b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028e:	ba 01 00 00 00       	mov    $0x1,%edx
  800293:	b8 09 00 00 00       	mov    $0x9,%eax
  800298:	e8 27 fe ff ff       	call   8000c4 <syscall>
}
  80029d:	c9                   	leave  
  80029e:	c3                   	ret    

0080029f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80029f:	f3 0f 1e fb          	endbr32 
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8002a9:	6a 00                	push   $0x0
  8002ab:	6a 00                	push   $0x0
  8002ad:	6a 00                	push   $0x0
  8002af:	ff 75 0c             	pushl  0xc(%ebp)
  8002b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b5:	ba 01 00 00 00       	mov    $0x1,%edx
  8002ba:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bf:	e8 00 fe ff ff       	call   8000c4 <syscall>
}
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002c6:	f3 0f 1e fb          	endbr32 
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002d0:	6a 00                	push   $0x0
  8002d2:	ff 75 14             	pushl  0x14(%ebp)
  8002d5:	ff 75 10             	pushl  0x10(%ebp)
  8002d8:	ff 75 0c             	pushl  0xc(%ebp)
  8002db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002de:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e8:	e8 d7 fd ff ff       	call   8000c4 <syscall>
}
  8002ed:	c9                   	leave  
  8002ee:	c3                   	ret    

008002ef <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002ef:	f3 0f 1e fb          	endbr32 
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002f9:	6a 00                	push   $0x0
  8002fb:	6a 00                	push   $0x0
  8002fd:	6a 00                	push   $0x0
  8002ff:	6a 00                	push   $0x0
  800301:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800304:	ba 01 00 00 00       	mov    $0x1,%edx
  800309:	b8 0d 00 00 00       	mov    $0xd,%eax
  80030e:	e8 b1 fd ff ff       	call   8000c4 <syscall>
}
  800313:	c9                   	leave  
  800314:	c3                   	ret    

00800315 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800315:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800316:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80031b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80031d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  800320:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  800325:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  800329:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80032d:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  80032f:	83 c4 08             	add    $0x8,%esp
	popal
  800332:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  800333:	83 c4 04             	add    $0x4,%esp
	popfl
  800336:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  800337:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80033a:	c3                   	ret    

0080033b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80033b:	f3 0f 1e fb          	endbr32 
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800342:	8b 45 08             	mov    0x8(%ebp),%eax
  800345:	05 00 00 00 30       	add    $0x30000000,%eax
  80034a:	c1 e8 0c             	shr    $0xc,%eax
}
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80034f:	f3 0f 1e fb          	endbr32 
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800359:	ff 75 08             	pushl  0x8(%ebp)
  80035c:	e8 da ff ff ff       	call   80033b <fd2num>
  800361:	83 c4 10             	add    $0x10,%esp
  800364:	c1 e0 0c             	shl    $0xc,%eax
  800367:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036c:	c9                   	leave  
  80036d:	c3                   	ret    

0080036e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036e:	f3 0f 1e fb          	endbr32 
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80037a:	89 c2                	mov    %eax,%edx
  80037c:	c1 ea 16             	shr    $0x16,%edx
  80037f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800386:	f6 c2 01             	test   $0x1,%dl
  800389:	74 2d                	je     8003b8 <fd_alloc+0x4a>
  80038b:	89 c2                	mov    %eax,%edx
  80038d:	c1 ea 0c             	shr    $0xc,%edx
  800390:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800397:	f6 c2 01             	test   $0x1,%dl
  80039a:	74 1c                	je     8003b8 <fd_alloc+0x4a>
  80039c:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003a1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003a6:	75 d2                	jne    80037a <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8003b1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003b6:	eb 0a                	jmp    8003c2 <fd_alloc+0x54>
			*fd_store = fd;
  8003b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003bb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003c2:	5d                   	pop    %ebp
  8003c3:	c3                   	ret    

008003c4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c4:	f3 0f 1e fb          	endbr32 
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ce:	83 f8 1f             	cmp    $0x1f,%eax
  8003d1:	77 30                	ja     800403 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d3:	c1 e0 0c             	shl    $0xc,%eax
  8003d6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003db:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003e1:	f6 c2 01             	test   $0x1,%dl
  8003e4:	74 24                	je     80040a <fd_lookup+0x46>
  8003e6:	89 c2                	mov    %eax,%edx
  8003e8:	c1 ea 0c             	shr    $0xc,%edx
  8003eb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f2:	f6 c2 01             	test   $0x1,%dl
  8003f5:	74 1a                	je     800411 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fa:	89 02                	mov    %eax,(%edx)
	return 0;
  8003fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800401:	5d                   	pop    %ebp
  800402:	c3                   	ret    
		return -E_INVAL;
  800403:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800408:	eb f7                	jmp    800401 <fd_lookup+0x3d>
		return -E_INVAL;
  80040a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040f:	eb f0                	jmp    800401 <fd_lookup+0x3d>
  800411:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800416:	eb e9                	jmp    800401 <fd_lookup+0x3d>

00800418 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800418:	f3 0f 1e fb          	endbr32 
  80041c:	55                   	push   %ebp
  80041d:	89 e5                	mov    %esp,%ebp
  80041f:	83 ec 08             	sub    $0x8,%esp
  800422:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800425:	ba 34 1f 80 00       	mov    $0x801f34,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80042a:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80042f:	39 08                	cmp    %ecx,(%eax)
  800431:	74 33                	je     800466 <dev_lookup+0x4e>
  800433:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800436:	8b 02                	mov    (%edx),%eax
  800438:	85 c0                	test   %eax,%eax
  80043a:	75 f3                	jne    80042f <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043c:	a1 04 40 80 00       	mov    0x804004,%eax
  800441:	8b 40 48             	mov    0x48(%eax),%eax
  800444:	83 ec 04             	sub    $0x4,%esp
  800447:	51                   	push   %ecx
  800448:	50                   	push   %eax
  800449:	68 b8 1e 80 00       	push   $0x801eb8
  80044e:	e8 3d 0d 00 00       	call   801190 <cprintf>
	*dev = 0;
  800453:	8b 45 0c             	mov    0xc(%ebp),%eax
  800456:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045c:	83 c4 10             	add    $0x10,%esp
  80045f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800464:	c9                   	leave  
  800465:	c3                   	ret    
			*dev = devtab[i];
  800466:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800469:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046b:	b8 00 00 00 00       	mov    $0x0,%eax
  800470:	eb f2                	jmp    800464 <dev_lookup+0x4c>

00800472 <fd_close>:
{
  800472:	f3 0f 1e fb          	endbr32 
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	57                   	push   %edi
  80047a:	56                   	push   %esi
  80047b:	53                   	push   %ebx
  80047c:	83 ec 28             	sub    $0x28,%esp
  80047f:	8b 75 08             	mov    0x8(%ebp),%esi
  800482:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800485:	56                   	push   %esi
  800486:	e8 b0 fe ff ff       	call   80033b <fd2num>
  80048b:	83 c4 08             	add    $0x8,%esp
  80048e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800491:	52                   	push   %edx
  800492:	50                   	push   %eax
  800493:	e8 2c ff ff ff       	call   8003c4 <fd_lookup>
  800498:	89 c3                	mov    %eax,%ebx
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	85 c0                	test   %eax,%eax
  80049f:	78 05                	js     8004a6 <fd_close+0x34>
	    || fd != fd2)
  8004a1:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004a4:	74 16                	je     8004bc <fd_close+0x4a>
		return (must_exist ? r : 0);
  8004a6:	89 f8                	mov    %edi,%eax
  8004a8:	84 c0                	test   %al,%al
  8004aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004af:	0f 44 d8             	cmove  %eax,%ebx
}
  8004b2:	89 d8                	mov    %ebx,%eax
  8004b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b7:	5b                   	pop    %ebx
  8004b8:	5e                   	pop    %esi
  8004b9:	5f                   	pop    %edi
  8004ba:	5d                   	pop    %ebp
  8004bb:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004c2:	50                   	push   %eax
  8004c3:	ff 36                	pushl  (%esi)
  8004c5:	e8 4e ff ff ff       	call   800418 <dev_lookup>
  8004ca:	89 c3                	mov    %eax,%ebx
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	78 1a                	js     8004ed <fd_close+0x7b>
		if (dev->dev_close)
  8004d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004d9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	74 0b                	je     8004ed <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004e2:	83 ec 0c             	sub    $0xc,%esp
  8004e5:	56                   	push   %esi
  8004e6:	ff d0                	call   *%eax
  8004e8:	89 c3                	mov    %eax,%ebx
  8004ea:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	56                   	push   %esi
  8004f1:	6a 00                	push   $0x0
  8004f3:	e8 32 fd ff ff       	call   80022a <sys_page_unmap>
	return r;
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	eb b5                	jmp    8004b2 <fd_close+0x40>

008004fd <close>:

int
close(int fdnum)
{
  8004fd:	f3 0f 1e fb          	endbr32 
  800501:	55                   	push   %ebp
  800502:	89 e5                	mov    %esp,%ebp
  800504:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800507:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80050a:	50                   	push   %eax
  80050b:	ff 75 08             	pushl  0x8(%ebp)
  80050e:	e8 b1 fe ff ff       	call   8003c4 <fd_lookup>
  800513:	83 c4 10             	add    $0x10,%esp
  800516:	85 c0                	test   %eax,%eax
  800518:	79 02                	jns    80051c <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80051a:	c9                   	leave  
  80051b:	c3                   	ret    
		return fd_close(fd, 1);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	6a 01                	push   $0x1
  800521:	ff 75 f4             	pushl  -0xc(%ebp)
  800524:	e8 49 ff ff ff       	call   800472 <fd_close>
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	eb ec                	jmp    80051a <close+0x1d>

0080052e <close_all>:

void
close_all(void)
{
  80052e:	f3 0f 1e fb          	endbr32 
  800532:	55                   	push   %ebp
  800533:	89 e5                	mov    %esp,%ebp
  800535:	53                   	push   %ebx
  800536:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800539:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80053e:	83 ec 0c             	sub    $0xc,%esp
  800541:	53                   	push   %ebx
  800542:	e8 b6 ff ff ff       	call   8004fd <close>
	for (i = 0; i < MAXFD; i++)
  800547:	83 c3 01             	add    $0x1,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	83 fb 20             	cmp    $0x20,%ebx
  800550:	75 ec                	jne    80053e <close_all+0x10>
}
  800552:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800555:	c9                   	leave  
  800556:	c3                   	ret    

00800557 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800557:	f3 0f 1e fb          	endbr32 
  80055b:	55                   	push   %ebp
  80055c:	89 e5                	mov    %esp,%ebp
  80055e:	57                   	push   %edi
  80055f:	56                   	push   %esi
  800560:	53                   	push   %ebx
  800561:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800564:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800567:	50                   	push   %eax
  800568:	ff 75 08             	pushl  0x8(%ebp)
  80056b:	e8 54 fe ff ff       	call   8003c4 <fd_lookup>
  800570:	89 c3                	mov    %eax,%ebx
  800572:	83 c4 10             	add    $0x10,%esp
  800575:	85 c0                	test   %eax,%eax
  800577:	0f 88 81 00 00 00    	js     8005fe <dup+0xa7>
		return r;
	close(newfdnum);
  80057d:	83 ec 0c             	sub    $0xc,%esp
  800580:	ff 75 0c             	pushl  0xc(%ebp)
  800583:	e8 75 ff ff ff       	call   8004fd <close>

	newfd = INDEX2FD(newfdnum);
  800588:	8b 75 0c             	mov    0xc(%ebp),%esi
  80058b:	c1 e6 0c             	shl    $0xc,%esi
  80058e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800594:	83 c4 04             	add    $0x4,%esp
  800597:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059a:	e8 b0 fd ff ff       	call   80034f <fd2data>
  80059f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005a1:	89 34 24             	mov    %esi,(%esp)
  8005a4:	e8 a6 fd ff ff       	call   80034f <fd2data>
  8005a9:	83 c4 10             	add    $0x10,%esp
  8005ac:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005ae:	89 d8                	mov    %ebx,%eax
  8005b0:	c1 e8 16             	shr    $0x16,%eax
  8005b3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005ba:	a8 01                	test   $0x1,%al
  8005bc:	74 11                	je     8005cf <dup+0x78>
  8005be:	89 d8                	mov    %ebx,%eax
  8005c0:	c1 e8 0c             	shr    $0xc,%eax
  8005c3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ca:	f6 c2 01             	test   $0x1,%dl
  8005cd:	75 39                	jne    800608 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d2:	89 d0                	mov    %edx,%eax
  8005d4:	c1 e8 0c             	shr    $0xc,%eax
  8005d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005de:	83 ec 0c             	sub    $0xc,%esp
  8005e1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e6:	50                   	push   %eax
  8005e7:	56                   	push   %esi
  8005e8:	6a 00                	push   $0x0
  8005ea:	52                   	push   %edx
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 0e fc ff ff       	call   800200 <sys_page_map>
  8005f2:	89 c3                	mov    %eax,%ebx
  8005f4:	83 c4 20             	add    $0x20,%esp
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	78 31                	js     80062c <dup+0xd5>
		goto err;

	return newfdnum;
  8005fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005fe:	89 d8                	mov    %ebx,%eax
  800600:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800603:	5b                   	pop    %ebx
  800604:	5e                   	pop    %esi
  800605:	5f                   	pop    %edi
  800606:	5d                   	pop    %ebp
  800607:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800608:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060f:	83 ec 0c             	sub    $0xc,%esp
  800612:	25 07 0e 00 00       	and    $0xe07,%eax
  800617:	50                   	push   %eax
  800618:	57                   	push   %edi
  800619:	6a 00                	push   $0x0
  80061b:	53                   	push   %ebx
  80061c:	6a 00                	push   $0x0
  80061e:	e8 dd fb ff ff       	call   800200 <sys_page_map>
  800623:	89 c3                	mov    %eax,%ebx
  800625:	83 c4 20             	add    $0x20,%esp
  800628:	85 c0                	test   %eax,%eax
  80062a:	79 a3                	jns    8005cf <dup+0x78>
	sys_page_unmap(0, newfd);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	56                   	push   %esi
  800630:	6a 00                	push   $0x0
  800632:	e8 f3 fb ff ff       	call   80022a <sys_page_unmap>
	sys_page_unmap(0, nva);
  800637:	83 c4 08             	add    $0x8,%esp
  80063a:	57                   	push   %edi
  80063b:	6a 00                	push   $0x0
  80063d:	e8 e8 fb ff ff       	call   80022a <sys_page_unmap>
	return r;
  800642:	83 c4 10             	add    $0x10,%esp
  800645:	eb b7                	jmp    8005fe <dup+0xa7>

00800647 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800647:	f3 0f 1e fb          	endbr32 
  80064b:	55                   	push   %ebp
  80064c:	89 e5                	mov    %esp,%ebp
  80064e:	53                   	push   %ebx
  80064f:	83 ec 1c             	sub    $0x1c,%esp
  800652:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800655:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800658:	50                   	push   %eax
  800659:	53                   	push   %ebx
  80065a:	e8 65 fd ff ff       	call   8003c4 <fd_lookup>
  80065f:	83 c4 10             	add    $0x10,%esp
  800662:	85 c0                	test   %eax,%eax
  800664:	78 3f                	js     8006a5 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80066c:	50                   	push   %eax
  80066d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800670:	ff 30                	pushl  (%eax)
  800672:	e8 a1 fd ff ff       	call   800418 <dev_lookup>
  800677:	83 c4 10             	add    $0x10,%esp
  80067a:	85 c0                	test   %eax,%eax
  80067c:	78 27                	js     8006a5 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80067e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800681:	8b 42 08             	mov    0x8(%edx),%eax
  800684:	83 e0 03             	and    $0x3,%eax
  800687:	83 f8 01             	cmp    $0x1,%eax
  80068a:	74 1e                	je     8006aa <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80068c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068f:	8b 40 08             	mov    0x8(%eax),%eax
  800692:	85 c0                	test   %eax,%eax
  800694:	74 35                	je     8006cb <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800696:	83 ec 04             	sub    $0x4,%esp
  800699:	ff 75 10             	pushl  0x10(%ebp)
  80069c:	ff 75 0c             	pushl  0xc(%ebp)
  80069f:	52                   	push   %edx
  8006a0:	ff d0                	call   *%eax
  8006a2:	83 c4 10             	add    $0x10,%esp
}
  8006a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006a8:	c9                   	leave  
  8006a9:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8006af:	8b 40 48             	mov    0x48(%eax),%eax
  8006b2:	83 ec 04             	sub    $0x4,%esp
  8006b5:	53                   	push   %ebx
  8006b6:	50                   	push   %eax
  8006b7:	68 f9 1e 80 00       	push   $0x801ef9
  8006bc:	e8 cf 0a 00 00       	call   801190 <cprintf>
		return -E_INVAL;
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c9:	eb da                	jmp    8006a5 <read+0x5e>
		return -E_NOT_SUPP;
  8006cb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006d0:	eb d3                	jmp    8006a5 <read+0x5e>

008006d2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006d2:	f3 0f 1e fb          	endbr32 
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	57                   	push   %edi
  8006da:	56                   	push   %esi
  8006db:	53                   	push   %ebx
  8006dc:	83 ec 0c             	sub    $0xc,%esp
  8006df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ea:	eb 02                	jmp    8006ee <readn+0x1c>
  8006ec:	01 c3                	add    %eax,%ebx
  8006ee:	39 f3                	cmp    %esi,%ebx
  8006f0:	73 21                	jae    800713 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f2:	83 ec 04             	sub    $0x4,%esp
  8006f5:	89 f0                	mov    %esi,%eax
  8006f7:	29 d8                	sub    %ebx,%eax
  8006f9:	50                   	push   %eax
  8006fa:	89 d8                	mov    %ebx,%eax
  8006fc:	03 45 0c             	add    0xc(%ebp),%eax
  8006ff:	50                   	push   %eax
  800700:	57                   	push   %edi
  800701:	e8 41 ff ff ff       	call   800647 <read>
		if (m < 0)
  800706:	83 c4 10             	add    $0x10,%esp
  800709:	85 c0                	test   %eax,%eax
  80070b:	78 04                	js     800711 <readn+0x3f>
			return m;
		if (m == 0)
  80070d:	75 dd                	jne    8006ec <readn+0x1a>
  80070f:	eb 02                	jmp    800713 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800711:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800713:	89 d8                	mov    %ebx,%eax
  800715:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800718:	5b                   	pop    %ebx
  800719:	5e                   	pop    %esi
  80071a:	5f                   	pop    %edi
  80071b:	5d                   	pop    %ebp
  80071c:	c3                   	ret    

0080071d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80071d:	f3 0f 1e fb          	endbr32 
  800721:	55                   	push   %ebp
  800722:	89 e5                	mov    %esp,%ebp
  800724:	53                   	push   %ebx
  800725:	83 ec 1c             	sub    $0x1c,%esp
  800728:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80072b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80072e:	50                   	push   %eax
  80072f:	53                   	push   %ebx
  800730:	e8 8f fc ff ff       	call   8003c4 <fd_lookup>
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	85 c0                	test   %eax,%eax
  80073a:	78 3a                	js     800776 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800742:	50                   	push   %eax
  800743:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800746:	ff 30                	pushl  (%eax)
  800748:	e8 cb fc ff ff       	call   800418 <dev_lookup>
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	85 c0                	test   %eax,%eax
  800752:	78 22                	js     800776 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800754:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800757:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80075b:	74 1e                	je     80077b <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800760:	8b 52 0c             	mov    0xc(%edx),%edx
  800763:	85 d2                	test   %edx,%edx
  800765:	74 35                	je     80079c <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800767:	83 ec 04             	sub    $0x4,%esp
  80076a:	ff 75 10             	pushl  0x10(%ebp)
  80076d:	ff 75 0c             	pushl  0xc(%ebp)
  800770:	50                   	push   %eax
  800771:	ff d2                	call   *%edx
  800773:	83 c4 10             	add    $0x10,%esp
}
  800776:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800779:	c9                   	leave  
  80077a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80077b:	a1 04 40 80 00       	mov    0x804004,%eax
  800780:	8b 40 48             	mov    0x48(%eax),%eax
  800783:	83 ec 04             	sub    $0x4,%esp
  800786:	53                   	push   %ebx
  800787:	50                   	push   %eax
  800788:	68 15 1f 80 00       	push   $0x801f15
  80078d:	e8 fe 09 00 00       	call   801190 <cprintf>
		return -E_INVAL;
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079a:	eb da                	jmp    800776 <write+0x59>
		return -E_NOT_SUPP;
  80079c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007a1:	eb d3                	jmp    800776 <write+0x59>

008007a3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007a3:	f3 0f 1e fb          	endbr32 
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007b0:	50                   	push   %eax
  8007b1:	ff 75 08             	pushl  0x8(%ebp)
  8007b4:	e8 0b fc ff ff       	call   8003c4 <fd_lookup>
  8007b9:	83 c4 10             	add    $0x10,%esp
  8007bc:	85 c0                	test   %eax,%eax
  8007be:	78 0e                	js     8007ce <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8007c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d0:	f3 0f 1e fb          	endbr32 
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	53                   	push   %ebx
  8007d8:	83 ec 1c             	sub    $0x1c,%esp
  8007db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007e1:	50                   	push   %eax
  8007e2:	53                   	push   %ebx
  8007e3:	e8 dc fb ff ff       	call   8003c4 <fd_lookup>
  8007e8:	83 c4 10             	add    $0x10,%esp
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	78 37                	js     800826 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ef:	83 ec 08             	sub    $0x8,%esp
  8007f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f5:	50                   	push   %eax
  8007f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f9:	ff 30                	pushl  (%eax)
  8007fb:	e8 18 fc ff ff       	call   800418 <dev_lookup>
  800800:	83 c4 10             	add    $0x10,%esp
  800803:	85 c0                	test   %eax,%eax
  800805:	78 1f                	js     800826 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800807:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80080e:	74 1b                	je     80082b <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800810:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800813:	8b 52 18             	mov    0x18(%edx),%edx
  800816:	85 d2                	test   %edx,%edx
  800818:	74 32                	je     80084c <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	ff 75 0c             	pushl  0xc(%ebp)
  800820:	50                   	push   %eax
  800821:	ff d2                	call   *%edx
  800823:	83 c4 10             	add    $0x10,%esp
}
  800826:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800829:	c9                   	leave  
  80082a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80082b:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800830:	8b 40 48             	mov    0x48(%eax),%eax
  800833:	83 ec 04             	sub    $0x4,%esp
  800836:	53                   	push   %ebx
  800837:	50                   	push   %eax
  800838:	68 d8 1e 80 00       	push   $0x801ed8
  80083d:	e8 4e 09 00 00       	call   801190 <cprintf>
		return -E_INVAL;
  800842:	83 c4 10             	add    $0x10,%esp
  800845:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084a:	eb da                	jmp    800826 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80084c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800851:	eb d3                	jmp    800826 <ftruncate+0x56>

00800853 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800853:	f3 0f 1e fb          	endbr32 
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	53                   	push   %ebx
  80085b:	83 ec 1c             	sub    $0x1c,%esp
  80085e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800861:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800864:	50                   	push   %eax
  800865:	ff 75 08             	pushl  0x8(%ebp)
  800868:	e8 57 fb ff ff       	call   8003c4 <fd_lookup>
  80086d:	83 c4 10             	add    $0x10,%esp
  800870:	85 c0                	test   %eax,%eax
  800872:	78 4b                	js     8008bf <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800874:	83 ec 08             	sub    $0x8,%esp
  800877:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80087a:	50                   	push   %eax
  80087b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80087e:	ff 30                	pushl  (%eax)
  800880:	e8 93 fb ff ff       	call   800418 <dev_lookup>
  800885:	83 c4 10             	add    $0x10,%esp
  800888:	85 c0                	test   %eax,%eax
  80088a:	78 33                	js     8008bf <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80088c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800893:	74 2f                	je     8008c4 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800895:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800898:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80089f:	00 00 00 
	stat->st_isdir = 0;
  8008a2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008a9:	00 00 00 
	stat->st_dev = dev;
  8008ac:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008b2:	83 ec 08             	sub    $0x8,%esp
  8008b5:	53                   	push   %ebx
  8008b6:	ff 75 f0             	pushl  -0x10(%ebp)
  8008b9:	ff 50 14             	call   *0x14(%eax)
  8008bc:	83 c4 10             	add    $0x10,%esp
}
  8008bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c2:	c9                   	leave  
  8008c3:	c3                   	ret    
		return -E_NOT_SUPP;
  8008c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008c9:	eb f4                	jmp    8008bf <fstat+0x6c>

008008cb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008cb:	f3 0f 1e fb          	endbr32 
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	56                   	push   %esi
  8008d3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008d4:	83 ec 08             	sub    $0x8,%esp
  8008d7:	6a 00                	push   $0x0
  8008d9:	ff 75 08             	pushl  0x8(%ebp)
  8008dc:	e8 20 02 00 00       	call   800b01 <open>
  8008e1:	89 c3                	mov    %eax,%ebx
  8008e3:	83 c4 10             	add    $0x10,%esp
  8008e6:	85 c0                	test   %eax,%eax
  8008e8:	78 1b                	js     800905 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008ea:	83 ec 08             	sub    $0x8,%esp
  8008ed:	ff 75 0c             	pushl  0xc(%ebp)
  8008f0:	50                   	push   %eax
  8008f1:	e8 5d ff ff ff       	call   800853 <fstat>
  8008f6:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f8:	89 1c 24             	mov    %ebx,(%esp)
  8008fb:	e8 fd fb ff ff       	call   8004fd <close>
	return r;
  800900:	83 c4 10             	add    $0x10,%esp
  800903:	89 f3                	mov    %esi,%ebx
}
  800905:	89 d8                	mov    %ebx,%eax
  800907:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80090a:	5b                   	pop    %ebx
  80090b:	5e                   	pop    %esi
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	56                   	push   %esi
  800912:	53                   	push   %ebx
  800913:	89 c6                	mov    %eax,%esi
  800915:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800917:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80091e:	74 27                	je     800947 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800920:	6a 07                	push   $0x7
  800922:	68 00 50 80 00       	push   $0x805000
  800927:	56                   	push   %esi
  800928:	ff 35 00 40 80 00    	pushl  0x804000
  80092e:	e8 1b 12 00 00       	call   801b4e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800933:	83 c4 0c             	add    $0xc,%esp
  800936:	6a 00                	push   $0x0
  800938:	53                   	push   %ebx
  800939:	6a 00                	push   $0x0
  80093b:	e8 a1 11 00 00       	call   801ae1 <ipc_recv>
}
  800940:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800947:	83 ec 0c             	sub    $0xc,%esp
  80094a:	6a 01                	push   $0x1
  80094c:	e8 50 12 00 00       	call   801ba1 <ipc_find_env>
  800951:	a3 00 40 80 00       	mov    %eax,0x804000
  800956:	83 c4 10             	add    $0x10,%esp
  800959:	eb c5                	jmp    800920 <fsipc+0x12>

0080095b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80095b:	f3 0f 1e fb          	endbr32 
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 40 0c             	mov    0xc(%eax),%eax
  80096b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800970:	8b 45 0c             	mov    0xc(%ebp),%eax
  800973:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800978:	ba 00 00 00 00       	mov    $0x0,%edx
  80097d:	b8 02 00 00 00       	mov    $0x2,%eax
  800982:	e8 87 ff ff ff       	call   80090e <fsipc>
}
  800987:	c9                   	leave  
  800988:	c3                   	ret    

00800989 <devfile_flush>:
{
  800989:	f3 0f 1e fb          	endbr32 
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 40 0c             	mov    0xc(%eax),%eax
  800999:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80099e:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a3:	b8 06 00 00 00       	mov    $0x6,%eax
  8009a8:	e8 61 ff ff ff       	call   80090e <fsipc>
}
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    

008009af <devfile_stat>:
{
  8009af:	f3 0f 1e fb          	endbr32 
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	53                   	push   %ebx
  8009b7:	83 ec 04             	sub    $0x4,%esp
  8009ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d2:	e8 37 ff ff ff       	call   80090e <fsipc>
  8009d7:	85 c0                	test   %eax,%eax
  8009d9:	78 2c                	js     800a07 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009db:	83 ec 08             	sub    $0x8,%esp
  8009de:	68 00 50 80 00       	push   $0x805000
  8009e3:	53                   	push   %ebx
  8009e4:	e8 11 0d 00 00       	call   8016fa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009e9:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ee:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f4:	a1 84 50 80 00       	mov    0x805084,%eax
  8009f9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ff:	83 c4 10             	add    $0x10,%esp
  800a02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    

00800a0c <devfile_write>:
{
  800a0c:	f3 0f 1e fb          	endbr32 
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	57                   	push   %edi
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
  800a16:	83 ec 0c             	sub    $0xc,%esp
  800a19:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8b 40 0c             	mov    0xc(%eax),%eax
  800a25:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a2f:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  800a34:	85 db                	test   %ebx,%ebx
  800a36:	74 3b                	je     800a73 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a38:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800a3e:	89 f8                	mov    %edi,%eax
  800a40:	0f 46 c3             	cmovbe %ebx,%eax
  800a43:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  800a48:	83 ec 04             	sub    $0x4,%esp
  800a4b:	50                   	push   %eax
  800a4c:	56                   	push   %esi
  800a4d:	68 08 50 80 00       	push   $0x805008
  800a52:	e8 5b 0e 00 00       	call   8018b2 <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800a57:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5c:	b8 04 00 00 00       	mov    $0x4,%eax
  800a61:	e8 a8 fe ff ff       	call   80090e <fsipc>
  800a66:	83 c4 10             	add    $0x10,%esp
  800a69:	85 c0                	test   %eax,%eax
  800a6b:	78 06                	js     800a73 <devfile_write+0x67>
		buf_aux += r;
  800a6d:	01 c6                	add    %eax,%esi
		n -= r;
  800a6f:	29 c3                	sub    %eax,%ebx
  800a71:	eb c1                	jmp    800a34 <devfile_write+0x28>
}
  800a73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5f                   	pop    %edi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <devfile_read>:
{
  800a7b:	f3 0f 1e fb          	endbr32 
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a92:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a98:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9d:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa2:	e8 67 fe ff ff       	call   80090e <fsipc>
  800aa7:	89 c3                	mov    %eax,%ebx
  800aa9:	85 c0                	test   %eax,%eax
  800aab:	78 1f                	js     800acc <devfile_read+0x51>
	assert(r <= n);
  800aad:	39 f0                	cmp    %esi,%eax
  800aaf:	77 24                	ja     800ad5 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800ab1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab6:	7f 33                	jg     800aeb <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ab8:	83 ec 04             	sub    $0x4,%esp
  800abb:	50                   	push   %eax
  800abc:	68 00 50 80 00       	push   $0x805000
  800ac1:	ff 75 0c             	pushl  0xc(%ebp)
  800ac4:	e8 e9 0d 00 00       	call   8018b2 <memmove>
	return r;
  800ac9:	83 c4 10             	add    $0x10,%esp
}
  800acc:	89 d8                	mov    %ebx,%eax
  800ace:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    
	assert(r <= n);
  800ad5:	68 44 1f 80 00       	push   $0x801f44
  800ada:	68 4b 1f 80 00       	push   $0x801f4b
  800adf:	6a 7c                	push   $0x7c
  800ae1:	68 60 1f 80 00       	push   $0x801f60
  800ae6:	e8 be 05 00 00       	call   8010a9 <_panic>
	assert(r <= PGSIZE);
  800aeb:	68 6b 1f 80 00       	push   $0x801f6b
  800af0:	68 4b 1f 80 00       	push   $0x801f4b
  800af5:	6a 7d                	push   $0x7d
  800af7:	68 60 1f 80 00       	push   $0x801f60
  800afc:	e8 a8 05 00 00       	call   8010a9 <_panic>

00800b01 <open>:
{
  800b01:	f3 0f 1e fb          	endbr32 
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	83 ec 1c             	sub    $0x1c,%esp
  800b0d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b10:	56                   	push   %esi
  800b11:	e8 a1 0b 00 00       	call   8016b7 <strlen>
  800b16:	83 c4 10             	add    $0x10,%esp
  800b19:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b1e:	7f 6c                	jg     800b8c <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800b20:	83 ec 0c             	sub    $0xc,%esp
  800b23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b26:	50                   	push   %eax
  800b27:	e8 42 f8 ff ff       	call   80036e <fd_alloc>
  800b2c:	89 c3                	mov    %eax,%ebx
  800b2e:	83 c4 10             	add    $0x10,%esp
  800b31:	85 c0                	test   %eax,%eax
  800b33:	78 3c                	js     800b71 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800b35:	83 ec 08             	sub    $0x8,%esp
  800b38:	56                   	push   %esi
  800b39:	68 00 50 80 00       	push   $0x805000
  800b3e:	e8 b7 0b 00 00       	call   8016fa <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b46:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b53:	e8 b6 fd ff ff       	call   80090e <fsipc>
  800b58:	89 c3                	mov    %eax,%ebx
  800b5a:	83 c4 10             	add    $0x10,%esp
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	78 19                	js     800b7a <open+0x79>
	return fd2num(fd);
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	ff 75 f4             	pushl  -0xc(%ebp)
  800b67:	e8 cf f7 ff ff       	call   80033b <fd2num>
  800b6c:	89 c3                	mov    %eax,%ebx
  800b6e:	83 c4 10             	add    $0x10,%esp
}
  800b71:	89 d8                	mov    %ebx,%eax
  800b73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    
		fd_close(fd, 0);
  800b7a:	83 ec 08             	sub    $0x8,%esp
  800b7d:	6a 00                	push   $0x0
  800b7f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b82:	e8 eb f8 ff ff       	call   800472 <fd_close>
		return r;
  800b87:	83 c4 10             	add    $0x10,%esp
  800b8a:	eb e5                	jmp    800b71 <open+0x70>
		return -E_BAD_PATH;
  800b8c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b91:	eb de                	jmp    800b71 <open+0x70>

00800b93 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b93:	f3 0f 1e fb          	endbr32 
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba7:	e8 62 fd ff ff       	call   80090e <fsipc>
}
  800bac:	c9                   	leave  
  800bad:	c3                   	ret    

00800bae <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bae:	f3 0f 1e fb          	endbr32 
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bba:	83 ec 0c             	sub    $0xc,%esp
  800bbd:	ff 75 08             	pushl  0x8(%ebp)
  800bc0:	e8 8a f7 ff ff       	call   80034f <fd2data>
  800bc5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bc7:	83 c4 08             	add    $0x8,%esp
  800bca:	68 77 1f 80 00       	push   $0x801f77
  800bcf:	53                   	push   %ebx
  800bd0:	e8 25 0b 00 00       	call   8016fa <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bd5:	8b 46 04             	mov    0x4(%esi),%eax
  800bd8:	2b 06                	sub    (%esi),%eax
  800bda:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800be0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800be7:	00 00 00 
	stat->st_dev = &devpipe;
  800bea:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bf1:	30 80 00 
	return 0;
}
  800bf4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c00:	f3 0f 1e fb          	endbr32 
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	53                   	push   %ebx
  800c08:	83 ec 0c             	sub    $0xc,%esp
  800c0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c0e:	53                   	push   %ebx
  800c0f:	6a 00                	push   $0x0
  800c11:	e8 14 f6 ff ff       	call   80022a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c16:	89 1c 24             	mov    %ebx,(%esp)
  800c19:	e8 31 f7 ff ff       	call   80034f <fd2data>
  800c1e:	83 c4 08             	add    $0x8,%esp
  800c21:	50                   	push   %eax
  800c22:	6a 00                	push   $0x0
  800c24:	e8 01 f6 ff ff       	call   80022a <sys_page_unmap>
}
  800c29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c2c:	c9                   	leave  
  800c2d:	c3                   	ret    

00800c2e <_pipeisclosed>:
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 1c             	sub    $0x1c,%esp
  800c37:	89 c7                	mov    %eax,%edi
  800c39:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c3b:	a1 04 40 80 00       	mov    0x804004,%eax
  800c40:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c43:	83 ec 0c             	sub    $0xc,%esp
  800c46:	57                   	push   %edi
  800c47:	e8 92 0f 00 00       	call   801bde <pageref>
  800c4c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c4f:	89 34 24             	mov    %esi,(%esp)
  800c52:	e8 87 0f 00 00       	call   801bde <pageref>
		nn = thisenv->env_runs;
  800c57:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c5d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c60:	83 c4 10             	add    $0x10,%esp
  800c63:	39 cb                	cmp    %ecx,%ebx
  800c65:	74 1b                	je     800c82 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c67:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c6a:	75 cf                	jne    800c3b <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c6c:	8b 42 58             	mov    0x58(%edx),%eax
  800c6f:	6a 01                	push   $0x1
  800c71:	50                   	push   %eax
  800c72:	53                   	push   %ebx
  800c73:	68 7e 1f 80 00       	push   $0x801f7e
  800c78:	e8 13 05 00 00       	call   801190 <cprintf>
  800c7d:	83 c4 10             	add    $0x10,%esp
  800c80:	eb b9                	jmp    800c3b <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c82:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c85:	0f 94 c0             	sete   %al
  800c88:	0f b6 c0             	movzbl %al,%eax
}
  800c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <devpipe_write>:
{
  800c93:	f3 0f 1e fb          	endbr32 
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 28             	sub    $0x28,%esp
  800ca0:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800ca3:	56                   	push   %esi
  800ca4:	e8 a6 f6 ff ff       	call   80034f <fd2data>
  800ca9:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cab:	83 c4 10             	add    $0x10,%esp
  800cae:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cb6:	74 4f                	je     800d07 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cb8:	8b 43 04             	mov    0x4(%ebx),%eax
  800cbb:	8b 0b                	mov    (%ebx),%ecx
  800cbd:	8d 51 20             	lea    0x20(%ecx),%edx
  800cc0:	39 d0                	cmp    %edx,%eax
  800cc2:	72 14                	jb     800cd8 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800cc4:	89 da                	mov    %ebx,%edx
  800cc6:	89 f0                	mov    %esi,%eax
  800cc8:	e8 61 ff ff ff       	call   800c2e <_pipeisclosed>
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	75 3b                	jne    800d0c <devpipe_write+0x79>
			sys_yield();
  800cd1:	e8 d7 f4 ff ff       	call   8001ad <sys_yield>
  800cd6:	eb e0                	jmp    800cb8 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cdf:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ce2:	89 c2                	mov    %eax,%edx
  800ce4:	c1 fa 1f             	sar    $0x1f,%edx
  800ce7:	89 d1                	mov    %edx,%ecx
  800ce9:	c1 e9 1b             	shr    $0x1b,%ecx
  800cec:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cef:	83 e2 1f             	and    $0x1f,%edx
  800cf2:	29 ca                	sub    %ecx,%edx
  800cf4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cf8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cfc:	83 c0 01             	add    $0x1,%eax
  800cff:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800d02:	83 c7 01             	add    $0x1,%edi
  800d05:	eb ac                	jmp    800cb3 <devpipe_write+0x20>
	return i;
  800d07:	8b 45 10             	mov    0x10(%ebp),%eax
  800d0a:	eb 05                	jmp    800d11 <devpipe_write+0x7e>
				return 0;
  800d0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <devpipe_read>:
{
  800d19:	f3 0f 1e fb          	endbr32 
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	83 ec 18             	sub    $0x18,%esp
  800d26:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800d29:	57                   	push   %edi
  800d2a:	e8 20 f6 ff ff       	call   80034f <fd2data>
  800d2f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800d31:	83 c4 10             	add    $0x10,%esp
  800d34:	be 00 00 00 00       	mov    $0x0,%esi
  800d39:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d3c:	75 14                	jne    800d52 <devpipe_read+0x39>
	return i;
  800d3e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d41:	eb 02                	jmp    800d45 <devpipe_read+0x2c>
				return i;
  800d43:	89 f0                	mov    %esi,%eax
}
  800d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    
			sys_yield();
  800d4d:	e8 5b f4 ff ff       	call   8001ad <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d52:	8b 03                	mov    (%ebx),%eax
  800d54:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d57:	75 18                	jne    800d71 <devpipe_read+0x58>
			if (i > 0)
  800d59:	85 f6                	test   %esi,%esi
  800d5b:	75 e6                	jne    800d43 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d5d:	89 da                	mov    %ebx,%edx
  800d5f:	89 f8                	mov    %edi,%eax
  800d61:	e8 c8 fe ff ff       	call   800c2e <_pipeisclosed>
  800d66:	85 c0                	test   %eax,%eax
  800d68:	74 e3                	je     800d4d <devpipe_read+0x34>
				return 0;
  800d6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6f:	eb d4                	jmp    800d45 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d71:	99                   	cltd   
  800d72:	c1 ea 1b             	shr    $0x1b,%edx
  800d75:	01 d0                	add    %edx,%eax
  800d77:	83 e0 1f             	and    $0x1f,%eax
  800d7a:	29 d0                	sub    %edx,%eax
  800d7c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d84:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d87:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d8a:	83 c6 01             	add    $0x1,%esi
  800d8d:	eb aa                	jmp    800d39 <devpipe_read+0x20>

00800d8f <pipe>:
{
  800d8f:	f3 0f 1e fb          	endbr32 
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
  800d98:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d9e:	50                   	push   %eax
  800d9f:	e8 ca f5 ff ff       	call   80036e <fd_alloc>
  800da4:	89 c3                	mov    %eax,%ebx
  800da6:	83 c4 10             	add    $0x10,%esp
  800da9:	85 c0                	test   %eax,%eax
  800dab:	0f 88 23 01 00 00    	js     800ed4 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db1:	83 ec 04             	sub    $0x4,%esp
  800db4:	68 07 04 00 00       	push   $0x407
  800db9:	ff 75 f4             	pushl  -0xc(%ebp)
  800dbc:	6a 00                	push   $0x0
  800dbe:	e8 15 f4 ff ff       	call   8001d8 <sys_page_alloc>
  800dc3:	89 c3                	mov    %eax,%ebx
  800dc5:	83 c4 10             	add    $0x10,%esp
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	0f 88 04 01 00 00    	js     800ed4 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800dd0:	83 ec 0c             	sub    $0xc,%esp
  800dd3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dd6:	50                   	push   %eax
  800dd7:	e8 92 f5 ff ff       	call   80036e <fd_alloc>
  800ddc:	89 c3                	mov    %eax,%ebx
  800dde:	83 c4 10             	add    $0x10,%esp
  800de1:	85 c0                	test   %eax,%eax
  800de3:	0f 88 db 00 00 00    	js     800ec4 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de9:	83 ec 04             	sub    $0x4,%esp
  800dec:	68 07 04 00 00       	push   $0x407
  800df1:	ff 75 f0             	pushl  -0x10(%ebp)
  800df4:	6a 00                	push   $0x0
  800df6:	e8 dd f3 ff ff       	call   8001d8 <sys_page_alloc>
  800dfb:	89 c3                	mov    %eax,%ebx
  800dfd:	83 c4 10             	add    $0x10,%esp
  800e00:	85 c0                	test   %eax,%eax
  800e02:	0f 88 bc 00 00 00    	js     800ec4 <pipe+0x135>
	va = fd2data(fd0);
  800e08:	83 ec 0c             	sub    $0xc,%esp
  800e0b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e0e:	e8 3c f5 ff ff       	call   80034f <fd2data>
  800e13:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e15:	83 c4 0c             	add    $0xc,%esp
  800e18:	68 07 04 00 00       	push   $0x407
  800e1d:	50                   	push   %eax
  800e1e:	6a 00                	push   $0x0
  800e20:	e8 b3 f3 ff ff       	call   8001d8 <sys_page_alloc>
  800e25:	89 c3                	mov    %eax,%ebx
  800e27:	83 c4 10             	add    $0x10,%esp
  800e2a:	85 c0                	test   %eax,%eax
  800e2c:	0f 88 82 00 00 00    	js     800eb4 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e32:	83 ec 0c             	sub    $0xc,%esp
  800e35:	ff 75 f0             	pushl  -0x10(%ebp)
  800e38:	e8 12 f5 ff ff       	call   80034f <fd2data>
  800e3d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e44:	50                   	push   %eax
  800e45:	6a 00                	push   $0x0
  800e47:	56                   	push   %esi
  800e48:	6a 00                	push   $0x0
  800e4a:	e8 b1 f3 ff ff       	call   800200 <sys_page_map>
  800e4f:	89 c3                	mov    %eax,%ebx
  800e51:	83 c4 20             	add    $0x20,%esp
  800e54:	85 c0                	test   %eax,%eax
  800e56:	78 4e                	js     800ea6 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e58:	a1 20 30 80 00       	mov    0x803020,%eax
  800e5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e60:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e62:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e65:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e6c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e6f:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e74:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e7b:	83 ec 0c             	sub    $0xc,%esp
  800e7e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e81:	e8 b5 f4 ff ff       	call   80033b <fd2num>
  800e86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e89:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e8b:	83 c4 04             	add    $0x4,%esp
  800e8e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e91:	e8 a5 f4 ff ff       	call   80033b <fd2num>
  800e96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e99:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e9c:	83 c4 10             	add    $0x10,%esp
  800e9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea4:	eb 2e                	jmp    800ed4 <pipe+0x145>
	sys_page_unmap(0, va);
  800ea6:	83 ec 08             	sub    $0x8,%esp
  800ea9:	56                   	push   %esi
  800eaa:	6a 00                	push   $0x0
  800eac:	e8 79 f3 ff ff       	call   80022a <sys_page_unmap>
  800eb1:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800eb4:	83 ec 08             	sub    $0x8,%esp
  800eb7:	ff 75 f0             	pushl  -0x10(%ebp)
  800eba:	6a 00                	push   $0x0
  800ebc:	e8 69 f3 ff ff       	call   80022a <sys_page_unmap>
  800ec1:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800ec4:	83 ec 08             	sub    $0x8,%esp
  800ec7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eca:	6a 00                	push   $0x0
  800ecc:	e8 59 f3 ff ff       	call   80022a <sys_page_unmap>
  800ed1:	83 c4 10             	add    $0x10,%esp
}
  800ed4:	89 d8                	mov    %ebx,%eax
  800ed6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed9:	5b                   	pop    %ebx
  800eda:	5e                   	pop    %esi
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    

00800edd <pipeisclosed>:
{
  800edd:	f3 0f 1e fb          	endbr32 
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ee7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eea:	50                   	push   %eax
  800eeb:	ff 75 08             	pushl  0x8(%ebp)
  800eee:	e8 d1 f4 ff ff       	call   8003c4 <fd_lookup>
  800ef3:	83 c4 10             	add    $0x10,%esp
  800ef6:	85 c0                	test   %eax,%eax
  800ef8:	78 18                	js     800f12 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800efa:	83 ec 0c             	sub    $0xc,%esp
  800efd:	ff 75 f4             	pushl  -0xc(%ebp)
  800f00:	e8 4a f4 ff ff       	call   80034f <fd2data>
  800f05:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f0a:	e8 1f fd ff ff       	call   800c2e <_pipeisclosed>
  800f0f:	83 c4 10             	add    $0x10,%esp
}
  800f12:	c9                   	leave  
  800f13:	c3                   	ret    

00800f14 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f14:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800f18:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1d:	c3                   	ret    

00800f1e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f1e:	f3 0f 1e fb          	endbr32 
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f28:	68 96 1f 80 00       	push   $0x801f96
  800f2d:	ff 75 0c             	pushl  0xc(%ebp)
  800f30:	e8 c5 07 00 00       	call   8016fa <strcpy>
	return 0;
}
  800f35:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3a:	c9                   	leave  
  800f3b:	c3                   	ret    

00800f3c <devcons_write>:
{
  800f3c:	f3 0f 1e fb          	endbr32 
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
  800f46:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f4c:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f51:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f57:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f5a:	73 31                	jae    800f8d <devcons_write+0x51>
		m = n - tot;
  800f5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f5f:	29 f3                	sub    %esi,%ebx
  800f61:	83 fb 7f             	cmp    $0x7f,%ebx
  800f64:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f69:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f6c:	83 ec 04             	sub    $0x4,%esp
  800f6f:	53                   	push   %ebx
  800f70:	89 f0                	mov    %esi,%eax
  800f72:	03 45 0c             	add    0xc(%ebp),%eax
  800f75:	50                   	push   %eax
  800f76:	57                   	push   %edi
  800f77:	e8 36 09 00 00       	call   8018b2 <memmove>
		sys_cputs(buf, m);
  800f7c:	83 c4 08             	add    $0x8,%esp
  800f7f:	53                   	push   %ebx
  800f80:	57                   	push   %edi
  800f81:	e8 87 f1 ff ff       	call   80010d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f86:	01 de                	add    %ebx,%esi
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	eb ca                	jmp    800f57 <devcons_write+0x1b>
}
  800f8d:	89 f0                	mov    %esi,%eax
  800f8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f92:	5b                   	pop    %ebx
  800f93:	5e                   	pop    %esi
  800f94:	5f                   	pop    %edi
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    

00800f97 <devcons_read>:
{
  800f97:	f3 0f 1e fb          	endbr32 
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	83 ec 08             	sub    $0x8,%esp
  800fa1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800fa6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800faa:	74 21                	je     800fcd <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800fac:	e8 86 f1 ff ff       	call   800137 <sys_cgetc>
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	75 07                	jne    800fbc <devcons_read+0x25>
		sys_yield();
  800fb5:	e8 f3 f1 ff ff       	call   8001ad <sys_yield>
  800fba:	eb f0                	jmp    800fac <devcons_read+0x15>
	if (c < 0)
  800fbc:	78 0f                	js     800fcd <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800fbe:	83 f8 04             	cmp    $0x4,%eax
  800fc1:	74 0c                	je     800fcf <devcons_read+0x38>
	*(char*)vbuf = c;
  800fc3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc6:	88 02                	mov    %al,(%edx)
	return 1;
  800fc8:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    
		return 0;
  800fcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd4:	eb f7                	jmp    800fcd <devcons_read+0x36>

00800fd6 <cputchar>:
{
  800fd6:	f3 0f 1e fb          	endbr32 
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fe0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe3:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800fe6:	6a 01                	push   $0x1
  800fe8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800feb:	50                   	push   %eax
  800fec:	e8 1c f1 ff ff       	call   80010d <sys_cputs>
}
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	c9                   	leave  
  800ff5:	c3                   	ret    

00800ff6 <getchar>:
{
  800ff6:	f3 0f 1e fb          	endbr32 
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801000:	6a 01                	push   $0x1
  801002:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801005:	50                   	push   %eax
  801006:	6a 00                	push   $0x0
  801008:	e8 3a f6 ff ff       	call   800647 <read>
	if (r < 0)
  80100d:	83 c4 10             	add    $0x10,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	78 06                	js     80101a <getchar+0x24>
	if (r < 1)
  801014:	74 06                	je     80101c <getchar+0x26>
	return c;
  801016:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80101a:	c9                   	leave  
  80101b:	c3                   	ret    
		return -E_EOF;
  80101c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801021:	eb f7                	jmp    80101a <getchar+0x24>

00801023 <iscons>:
{
  801023:	f3 0f 1e fb          	endbr32 
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80102d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801030:	50                   	push   %eax
  801031:	ff 75 08             	pushl  0x8(%ebp)
  801034:	e8 8b f3 ff ff       	call   8003c4 <fd_lookup>
  801039:	83 c4 10             	add    $0x10,%esp
  80103c:	85 c0                	test   %eax,%eax
  80103e:	78 11                	js     801051 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801040:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801043:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801049:	39 10                	cmp    %edx,(%eax)
  80104b:	0f 94 c0             	sete   %al
  80104e:	0f b6 c0             	movzbl %al,%eax
}
  801051:	c9                   	leave  
  801052:	c3                   	ret    

00801053 <opencons>:
{
  801053:	f3 0f 1e fb          	endbr32 
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80105d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801060:	50                   	push   %eax
  801061:	e8 08 f3 ff ff       	call   80036e <fd_alloc>
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	85 c0                	test   %eax,%eax
  80106b:	78 3a                	js     8010a7 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80106d:	83 ec 04             	sub    $0x4,%esp
  801070:	68 07 04 00 00       	push   $0x407
  801075:	ff 75 f4             	pushl  -0xc(%ebp)
  801078:	6a 00                	push   $0x0
  80107a:	e8 59 f1 ff ff       	call   8001d8 <sys_page_alloc>
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	85 c0                	test   %eax,%eax
  801084:	78 21                	js     8010a7 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801086:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801089:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80108f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801091:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801094:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	50                   	push   %eax
  80109f:	e8 97 f2 ff ff       	call   80033b <fd2num>
  8010a4:	83 c4 10             	add    $0x10,%esp
}
  8010a7:	c9                   	leave  
  8010a8:	c3                   	ret    

008010a9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010a9:	f3 0f 1e fb          	endbr32 
  8010ad:	55                   	push   %ebp
  8010ae:	89 e5                	mov    %esp,%ebp
  8010b0:	56                   	push   %esi
  8010b1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010b2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010b5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010bb:	e8 c5 f0 ff ff       	call   800185 <sys_getenvid>
  8010c0:	83 ec 0c             	sub    $0xc,%esp
  8010c3:	ff 75 0c             	pushl  0xc(%ebp)
  8010c6:	ff 75 08             	pushl  0x8(%ebp)
  8010c9:	56                   	push   %esi
  8010ca:	50                   	push   %eax
  8010cb:	68 a4 1f 80 00       	push   $0x801fa4
  8010d0:	e8 bb 00 00 00       	call   801190 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010d5:	83 c4 18             	add    $0x18,%esp
  8010d8:	53                   	push   %ebx
  8010d9:	ff 75 10             	pushl  0x10(%ebp)
  8010dc:	e8 5a 00 00 00       	call   80113b <vcprintf>
	cprintf("\n");
  8010e1:	c7 04 24 8f 1f 80 00 	movl   $0x801f8f,(%esp)
  8010e8:	e8 a3 00 00 00       	call   801190 <cprintf>
  8010ed:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010f0:	cc                   	int3   
  8010f1:	eb fd                	jmp    8010f0 <_panic+0x47>

008010f3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010f3:	f3 0f 1e fb          	endbr32 
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 04             	sub    $0x4,%esp
  8010fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801101:	8b 13                	mov    (%ebx),%edx
  801103:	8d 42 01             	lea    0x1(%edx),%eax
  801106:	89 03                	mov    %eax,(%ebx)
  801108:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80110b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80110f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801114:	74 09                	je     80111f <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801116:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80111a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80111d:	c9                   	leave  
  80111e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80111f:	83 ec 08             	sub    $0x8,%esp
  801122:	68 ff 00 00 00       	push   $0xff
  801127:	8d 43 08             	lea    0x8(%ebx),%eax
  80112a:	50                   	push   %eax
  80112b:	e8 dd ef ff ff       	call   80010d <sys_cputs>
		b->idx = 0;
  801130:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	eb db                	jmp    801116 <putch+0x23>

0080113b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80113b:	f3 0f 1e fb          	endbr32 
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801148:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80114f:	00 00 00 
	b.cnt = 0;
  801152:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801159:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80115c:	ff 75 0c             	pushl  0xc(%ebp)
  80115f:	ff 75 08             	pushl  0x8(%ebp)
  801162:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801168:	50                   	push   %eax
  801169:	68 f3 10 80 00       	push   $0x8010f3
  80116e:	e8 80 01 00 00       	call   8012f3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801173:	83 c4 08             	add    $0x8,%esp
  801176:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80117c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801182:	50                   	push   %eax
  801183:	e8 85 ef ff ff       	call   80010d <sys_cputs>

	return b.cnt;
}
  801188:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80118e:	c9                   	leave  
  80118f:	c3                   	ret    

00801190 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801190:	f3 0f 1e fb          	endbr32 
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80119a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80119d:	50                   	push   %eax
  80119e:	ff 75 08             	pushl  0x8(%ebp)
  8011a1:	e8 95 ff ff ff       	call   80113b <vcprintf>
	va_end(ap);

	return cnt;
}
  8011a6:	c9                   	leave  
  8011a7:	c3                   	ret    

008011a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	57                   	push   %edi
  8011ac:	56                   	push   %esi
  8011ad:	53                   	push   %ebx
  8011ae:	83 ec 1c             	sub    $0x1c,%esp
  8011b1:	89 c7                	mov    %eax,%edi
  8011b3:	89 d6                	mov    %edx,%esi
  8011b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011bb:	89 d1                	mov    %edx,%ecx
  8011bd:	89 c2                	mov    %eax,%edx
  8011bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8011c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011ce:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011d5:	39 c2                	cmp    %eax,%edx
  8011d7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011da:	72 3e                	jb     80121a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011dc:	83 ec 0c             	sub    $0xc,%esp
  8011df:	ff 75 18             	pushl  0x18(%ebp)
  8011e2:	83 eb 01             	sub    $0x1,%ebx
  8011e5:	53                   	push   %ebx
  8011e6:	50                   	push   %eax
  8011e7:	83 ec 08             	sub    $0x8,%esp
  8011ea:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f0:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f3:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f6:	e8 25 0a 00 00       	call   801c20 <__udivdi3>
  8011fb:	83 c4 18             	add    $0x18,%esp
  8011fe:	52                   	push   %edx
  8011ff:	50                   	push   %eax
  801200:	89 f2                	mov    %esi,%edx
  801202:	89 f8                	mov    %edi,%eax
  801204:	e8 9f ff ff ff       	call   8011a8 <printnum>
  801209:	83 c4 20             	add    $0x20,%esp
  80120c:	eb 13                	jmp    801221 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80120e:	83 ec 08             	sub    $0x8,%esp
  801211:	56                   	push   %esi
  801212:	ff 75 18             	pushl  0x18(%ebp)
  801215:	ff d7                	call   *%edi
  801217:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80121a:	83 eb 01             	sub    $0x1,%ebx
  80121d:	85 db                	test   %ebx,%ebx
  80121f:	7f ed                	jg     80120e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801221:	83 ec 08             	sub    $0x8,%esp
  801224:	56                   	push   %esi
  801225:	83 ec 04             	sub    $0x4,%esp
  801228:	ff 75 e4             	pushl  -0x1c(%ebp)
  80122b:	ff 75 e0             	pushl  -0x20(%ebp)
  80122e:	ff 75 dc             	pushl  -0x24(%ebp)
  801231:	ff 75 d8             	pushl  -0x28(%ebp)
  801234:	e8 f7 0a 00 00       	call   801d30 <__umoddi3>
  801239:	83 c4 14             	add    $0x14,%esp
  80123c:	0f be 80 c7 1f 80 00 	movsbl 0x801fc7(%eax),%eax
  801243:	50                   	push   %eax
  801244:	ff d7                	call   *%edi
}
  801246:	83 c4 10             	add    $0x10,%esp
  801249:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124c:	5b                   	pop    %ebx
  80124d:	5e                   	pop    %esi
  80124e:	5f                   	pop    %edi
  80124f:	5d                   	pop    %ebp
  801250:	c3                   	ret    

00801251 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801251:	83 fa 01             	cmp    $0x1,%edx
  801254:	7f 13                	jg     801269 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801256:	85 d2                	test   %edx,%edx
  801258:	74 1c                	je     801276 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80125a:	8b 10                	mov    (%eax),%edx
  80125c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80125f:	89 08                	mov    %ecx,(%eax)
  801261:	8b 02                	mov    (%edx),%eax
  801263:	ba 00 00 00 00       	mov    $0x0,%edx
  801268:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  801269:	8b 10                	mov    (%eax),%edx
  80126b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80126e:	89 08                	mov    %ecx,(%eax)
  801270:	8b 02                	mov    (%edx),%eax
  801272:	8b 52 04             	mov    0x4(%edx),%edx
  801275:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  801276:	8b 10                	mov    (%eax),%edx
  801278:	8d 4a 04             	lea    0x4(%edx),%ecx
  80127b:	89 08                	mov    %ecx,(%eax)
  80127d:	8b 02                	mov    (%edx),%eax
  80127f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801284:	c3                   	ret    

00801285 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801285:	83 fa 01             	cmp    $0x1,%edx
  801288:	7f 0f                	jg     801299 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80128a:	85 d2                	test   %edx,%edx
  80128c:	74 18                	je     8012a6 <getint+0x21>
		return va_arg(*ap, long);
  80128e:	8b 10                	mov    (%eax),%edx
  801290:	8d 4a 04             	lea    0x4(%edx),%ecx
  801293:	89 08                	mov    %ecx,(%eax)
  801295:	8b 02                	mov    (%edx),%eax
  801297:	99                   	cltd   
  801298:	c3                   	ret    
		return va_arg(*ap, long long);
  801299:	8b 10                	mov    (%eax),%edx
  80129b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80129e:	89 08                	mov    %ecx,(%eax)
  8012a0:	8b 02                	mov    (%edx),%eax
  8012a2:	8b 52 04             	mov    0x4(%edx),%edx
  8012a5:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8012a6:	8b 10                	mov    (%eax),%edx
  8012a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8012ab:	89 08                	mov    %ecx,(%eax)
  8012ad:	8b 02                	mov    (%edx),%eax
  8012af:	99                   	cltd   
}
  8012b0:	c3                   	ret    

008012b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8012b1:	f3 0f 1e fb          	endbr32 
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8012bb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8012bf:	8b 10                	mov    (%eax),%edx
  8012c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8012c4:	73 0a                	jae    8012d0 <sprintputch+0x1f>
		*b->buf++ = ch;
  8012c6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8012c9:	89 08                	mov    %ecx,(%eax)
  8012cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ce:	88 02                	mov    %al,(%edx)
}
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <printfmt>:
{
  8012d2:	f3 0f 1e fb          	endbr32 
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012df:	50                   	push   %eax
  8012e0:	ff 75 10             	pushl  0x10(%ebp)
  8012e3:	ff 75 0c             	pushl  0xc(%ebp)
  8012e6:	ff 75 08             	pushl  0x8(%ebp)
  8012e9:	e8 05 00 00 00       	call   8012f3 <vprintfmt>
}
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	c9                   	leave  
  8012f2:	c3                   	ret    

008012f3 <vprintfmt>:
{
  8012f3:	f3 0f 1e fb          	endbr32 
  8012f7:	55                   	push   %ebp
  8012f8:	89 e5                	mov    %esp,%ebp
  8012fa:	57                   	push   %edi
  8012fb:	56                   	push   %esi
  8012fc:	53                   	push   %ebx
  8012fd:	83 ec 2c             	sub    $0x2c,%esp
  801300:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801303:	8b 75 0c             	mov    0xc(%ebp),%esi
  801306:	8b 7d 10             	mov    0x10(%ebp),%edi
  801309:	e9 86 02 00 00       	jmp    801594 <vprintfmt+0x2a1>
		padc = ' ';
  80130e:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801312:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801319:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801320:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801327:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80132c:	8d 47 01             	lea    0x1(%edi),%eax
  80132f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801332:	0f b6 17             	movzbl (%edi),%edx
  801335:	8d 42 dd             	lea    -0x23(%edx),%eax
  801338:	3c 55                	cmp    $0x55,%al
  80133a:	0f 87 df 02 00 00    	ja     80161f <vprintfmt+0x32c>
  801340:	0f b6 c0             	movzbl %al,%eax
  801343:	3e ff 24 85 00 21 80 	notrack jmp *0x802100(,%eax,4)
  80134a:	00 
  80134b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80134e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801352:	eb d8                	jmp    80132c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801354:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801357:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80135b:	eb cf                	jmp    80132c <vprintfmt+0x39>
  80135d:	0f b6 d2             	movzbl %dl,%edx
  801360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801363:	b8 00 00 00 00       	mov    $0x0,%eax
  801368:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80136b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80136e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801372:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801375:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801378:	83 f9 09             	cmp    $0x9,%ecx
  80137b:	77 52                	ja     8013cf <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  80137d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801380:	eb e9                	jmp    80136b <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801382:	8b 45 14             	mov    0x14(%ebp),%eax
  801385:	8d 50 04             	lea    0x4(%eax),%edx
  801388:	89 55 14             	mov    %edx,0x14(%ebp)
  80138b:	8b 00                	mov    (%eax),%eax
  80138d:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801393:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801397:	79 93                	jns    80132c <vprintfmt+0x39>
				width = precision, precision = -1;
  801399:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80139c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80139f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8013a6:	eb 84                	jmp    80132c <vprintfmt+0x39>
  8013a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b2:	0f 49 d0             	cmovns %eax,%edx
  8013b5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8013b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013bb:	e9 6c ff ff ff       	jmp    80132c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8013c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8013c3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8013ca:	e9 5d ff ff ff       	jmp    80132c <vprintfmt+0x39>
  8013cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013d2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8013d5:	eb bc                	jmp    801393 <vprintfmt+0xa0>
			lflag++;
  8013d7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8013da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013dd:	e9 4a ff ff ff       	jmp    80132c <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e5:	8d 50 04             	lea    0x4(%eax),%edx
  8013e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8013eb:	83 ec 08             	sub    $0x8,%esp
  8013ee:	56                   	push   %esi
  8013ef:	ff 30                	pushl  (%eax)
  8013f1:	ff d3                	call   *%ebx
			break;
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	e9 96 01 00 00       	jmp    801591 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8013fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8013fe:	8d 50 04             	lea    0x4(%eax),%edx
  801401:	89 55 14             	mov    %edx,0x14(%ebp)
  801404:	8b 00                	mov    (%eax),%eax
  801406:	99                   	cltd   
  801407:	31 d0                	xor    %edx,%eax
  801409:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80140b:	83 f8 0f             	cmp    $0xf,%eax
  80140e:	7f 20                	jg     801430 <vprintfmt+0x13d>
  801410:	8b 14 85 60 22 80 00 	mov    0x802260(,%eax,4),%edx
  801417:	85 d2                	test   %edx,%edx
  801419:	74 15                	je     801430 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  80141b:	52                   	push   %edx
  80141c:	68 5d 1f 80 00       	push   $0x801f5d
  801421:	56                   	push   %esi
  801422:	53                   	push   %ebx
  801423:	e8 aa fe ff ff       	call   8012d2 <printfmt>
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	e9 61 01 00 00       	jmp    801591 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  801430:	50                   	push   %eax
  801431:	68 df 1f 80 00       	push   $0x801fdf
  801436:	56                   	push   %esi
  801437:	53                   	push   %ebx
  801438:	e8 95 fe ff ff       	call   8012d2 <printfmt>
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	e9 4c 01 00 00       	jmp    801591 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  801445:	8b 45 14             	mov    0x14(%ebp),%eax
  801448:	8d 50 04             	lea    0x4(%eax),%edx
  80144b:	89 55 14             	mov    %edx,0x14(%ebp)
  80144e:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  801450:	85 c9                	test   %ecx,%ecx
  801452:	b8 d8 1f 80 00       	mov    $0x801fd8,%eax
  801457:	0f 45 c1             	cmovne %ecx,%eax
  80145a:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80145d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801461:	7e 06                	jle    801469 <vprintfmt+0x176>
  801463:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801467:	75 0d                	jne    801476 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  801469:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80146c:	89 c7                	mov    %eax,%edi
  80146e:	03 45 e0             	add    -0x20(%ebp),%eax
  801471:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801474:	eb 57                	jmp    8014cd <vprintfmt+0x1da>
  801476:	83 ec 08             	sub    $0x8,%esp
  801479:	ff 75 d8             	pushl  -0x28(%ebp)
  80147c:	ff 75 cc             	pushl  -0x34(%ebp)
  80147f:	e8 4f 02 00 00       	call   8016d3 <strnlen>
  801484:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801487:	29 c2                	sub    %eax,%edx
  801489:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80148c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80148f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801493:	89 5d 08             	mov    %ebx,0x8(%ebp)
  801496:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  801498:	85 db                	test   %ebx,%ebx
  80149a:	7e 10                	jle    8014ac <vprintfmt+0x1b9>
					putch(padc, putdat);
  80149c:	83 ec 08             	sub    $0x8,%esp
  80149f:	56                   	push   %esi
  8014a0:	57                   	push   %edi
  8014a1:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8014a4:	83 eb 01             	sub    $0x1,%ebx
  8014a7:	83 c4 10             	add    $0x10,%esp
  8014aa:	eb ec                	jmp    801498 <vprintfmt+0x1a5>
  8014ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014af:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8014b2:	85 d2                	test   %edx,%edx
  8014b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b9:	0f 49 c2             	cmovns %edx,%eax
  8014bc:	29 c2                	sub    %eax,%edx
  8014be:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8014c1:	eb a6                	jmp    801469 <vprintfmt+0x176>
					putch(ch, putdat);
  8014c3:	83 ec 08             	sub    $0x8,%esp
  8014c6:	56                   	push   %esi
  8014c7:	52                   	push   %edx
  8014c8:	ff d3                	call   *%ebx
  8014ca:	83 c4 10             	add    $0x10,%esp
  8014cd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014d0:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014d2:	83 c7 01             	add    $0x1,%edi
  8014d5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014d9:	0f be d0             	movsbl %al,%edx
  8014dc:	85 d2                	test   %edx,%edx
  8014de:	74 42                	je     801522 <vprintfmt+0x22f>
  8014e0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014e4:	78 06                	js     8014ec <vprintfmt+0x1f9>
  8014e6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014ea:	78 1e                	js     80150a <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8014ec:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014f0:	74 d1                	je     8014c3 <vprintfmt+0x1d0>
  8014f2:	0f be c0             	movsbl %al,%eax
  8014f5:	83 e8 20             	sub    $0x20,%eax
  8014f8:	83 f8 5e             	cmp    $0x5e,%eax
  8014fb:	76 c6                	jbe    8014c3 <vprintfmt+0x1d0>
					putch('?', putdat);
  8014fd:	83 ec 08             	sub    $0x8,%esp
  801500:	56                   	push   %esi
  801501:	6a 3f                	push   $0x3f
  801503:	ff d3                	call   *%ebx
  801505:	83 c4 10             	add    $0x10,%esp
  801508:	eb c3                	jmp    8014cd <vprintfmt+0x1da>
  80150a:	89 cf                	mov    %ecx,%edi
  80150c:	eb 0e                	jmp    80151c <vprintfmt+0x229>
				putch(' ', putdat);
  80150e:	83 ec 08             	sub    $0x8,%esp
  801511:	56                   	push   %esi
  801512:	6a 20                	push   $0x20
  801514:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  801516:	83 ef 01             	sub    $0x1,%edi
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	85 ff                	test   %edi,%edi
  80151e:	7f ee                	jg     80150e <vprintfmt+0x21b>
  801520:	eb 6f                	jmp    801591 <vprintfmt+0x29e>
  801522:	89 cf                	mov    %ecx,%edi
  801524:	eb f6                	jmp    80151c <vprintfmt+0x229>
			num = getint(&ap, lflag);
  801526:	89 ca                	mov    %ecx,%edx
  801528:	8d 45 14             	lea    0x14(%ebp),%eax
  80152b:	e8 55 fd ff ff       	call   801285 <getint>
  801530:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801533:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  801536:	85 d2                	test   %edx,%edx
  801538:	78 0b                	js     801545 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  80153a:	89 d1                	mov    %edx,%ecx
  80153c:	89 c2                	mov    %eax,%edx
			base = 10;
  80153e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801543:	eb 32                	jmp    801577 <vprintfmt+0x284>
				putch('-', putdat);
  801545:	83 ec 08             	sub    $0x8,%esp
  801548:	56                   	push   %esi
  801549:	6a 2d                	push   $0x2d
  80154b:	ff d3                	call   *%ebx
				num = -(long long) num;
  80154d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801550:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801553:	f7 da                	neg    %edx
  801555:	83 d1 00             	adc    $0x0,%ecx
  801558:	f7 d9                	neg    %ecx
  80155a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80155d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801562:	eb 13                	jmp    801577 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  801564:	89 ca                	mov    %ecx,%edx
  801566:	8d 45 14             	lea    0x14(%ebp),%eax
  801569:	e8 e3 fc ff ff       	call   801251 <getuint>
  80156e:	89 d1                	mov    %edx,%ecx
  801570:	89 c2                	mov    %eax,%edx
			base = 10;
  801572:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  801577:	83 ec 0c             	sub    $0xc,%esp
  80157a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80157e:	57                   	push   %edi
  80157f:	ff 75 e0             	pushl  -0x20(%ebp)
  801582:	50                   	push   %eax
  801583:	51                   	push   %ecx
  801584:	52                   	push   %edx
  801585:	89 f2                	mov    %esi,%edx
  801587:	89 d8                	mov    %ebx,%eax
  801589:	e8 1a fc ff ff       	call   8011a8 <printnum>
			break;
  80158e:	83 c4 20             	add    $0x20,%esp
{
  801591:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801594:	83 c7 01             	add    $0x1,%edi
  801597:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80159b:	83 f8 25             	cmp    $0x25,%eax
  80159e:	0f 84 6a fd ff ff    	je     80130e <vprintfmt+0x1b>
			if (ch == '\0')
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	0f 84 93 00 00 00    	je     80163f <vprintfmt+0x34c>
			putch(ch, putdat);
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	56                   	push   %esi
  8015b0:	50                   	push   %eax
  8015b1:	ff d3                	call   *%ebx
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	eb dc                	jmp    801594 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8015b8:	89 ca                	mov    %ecx,%edx
  8015ba:	8d 45 14             	lea    0x14(%ebp),%eax
  8015bd:	e8 8f fc ff ff       	call   801251 <getuint>
  8015c2:	89 d1                	mov    %edx,%ecx
  8015c4:	89 c2                	mov    %eax,%edx
			base = 8;
  8015c6:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8015cb:	eb aa                	jmp    801577 <vprintfmt+0x284>
			putch('0', putdat);
  8015cd:	83 ec 08             	sub    $0x8,%esp
  8015d0:	56                   	push   %esi
  8015d1:	6a 30                	push   $0x30
  8015d3:	ff d3                	call   *%ebx
			putch('x', putdat);
  8015d5:	83 c4 08             	add    $0x8,%esp
  8015d8:	56                   	push   %esi
  8015d9:	6a 78                	push   $0x78
  8015db:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8015dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e0:	8d 50 04             	lea    0x4(%eax),%edx
  8015e3:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8015e6:	8b 10                	mov    (%eax),%edx
  8015e8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015ed:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8015f0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015f5:	eb 80                	jmp    801577 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8015f7:	89 ca                	mov    %ecx,%edx
  8015f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8015fc:	e8 50 fc ff ff       	call   801251 <getuint>
  801601:	89 d1                	mov    %edx,%ecx
  801603:	89 c2                	mov    %eax,%edx
			base = 16;
  801605:	b8 10 00 00 00       	mov    $0x10,%eax
  80160a:	e9 68 ff ff ff       	jmp    801577 <vprintfmt+0x284>
			putch(ch, putdat);
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	56                   	push   %esi
  801613:	6a 25                	push   $0x25
  801615:	ff d3                	call   *%ebx
			break;
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	e9 72 ff ff ff       	jmp    801591 <vprintfmt+0x29e>
			putch('%', putdat);
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	56                   	push   %esi
  801623:	6a 25                	push   $0x25
  801625:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	89 f8                	mov    %edi,%eax
  80162c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801630:	74 05                	je     801637 <vprintfmt+0x344>
  801632:	83 e8 01             	sub    $0x1,%eax
  801635:	eb f5                	jmp    80162c <vprintfmt+0x339>
  801637:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80163a:	e9 52 ff ff ff       	jmp    801591 <vprintfmt+0x29e>
}
  80163f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801642:	5b                   	pop    %ebx
  801643:	5e                   	pop    %esi
  801644:	5f                   	pop    %edi
  801645:	5d                   	pop    %ebp
  801646:	c3                   	ret    

00801647 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801647:	f3 0f 1e fb          	endbr32 
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	83 ec 18             	sub    $0x18,%esp
  801651:	8b 45 08             	mov    0x8(%ebp),%eax
  801654:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801657:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80165a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80165e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801661:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801668:	85 c0                	test   %eax,%eax
  80166a:	74 26                	je     801692 <vsnprintf+0x4b>
  80166c:	85 d2                	test   %edx,%edx
  80166e:	7e 22                	jle    801692 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801670:	ff 75 14             	pushl  0x14(%ebp)
  801673:	ff 75 10             	pushl  0x10(%ebp)
  801676:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801679:	50                   	push   %eax
  80167a:	68 b1 12 80 00       	push   $0x8012b1
  80167f:	e8 6f fc ff ff       	call   8012f3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801684:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801687:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80168a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168d:	83 c4 10             	add    $0x10,%esp
}
  801690:	c9                   	leave  
  801691:	c3                   	ret    
		return -E_INVAL;
  801692:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801697:	eb f7                	jmp    801690 <vsnprintf+0x49>

00801699 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801699:	f3 0f 1e fb          	endbr32 
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016a6:	50                   	push   %eax
  8016a7:	ff 75 10             	pushl  0x10(%ebp)
  8016aa:	ff 75 0c             	pushl  0xc(%ebp)
  8016ad:	ff 75 08             	pushl  0x8(%ebp)
  8016b0:	e8 92 ff ff ff       	call   801647 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016b7:	f3 0f 1e fb          	endbr32 
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016ca:	74 05                	je     8016d1 <strlen+0x1a>
		n++;
  8016cc:	83 c0 01             	add    $0x1,%eax
  8016cf:	eb f5                	jmp    8016c6 <strlen+0xf>
	return n;
}
  8016d1:	5d                   	pop    %ebp
  8016d2:	c3                   	ret    

008016d3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016d3:	f3 0f 1e fb          	endbr32 
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e5:	39 d0                	cmp    %edx,%eax
  8016e7:	74 0d                	je     8016f6 <strnlen+0x23>
  8016e9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016ed:	74 05                	je     8016f4 <strnlen+0x21>
		n++;
  8016ef:	83 c0 01             	add    $0x1,%eax
  8016f2:	eb f1                	jmp    8016e5 <strnlen+0x12>
  8016f4:	89 c2                	mov    %eax,%edx
	return n;
}
  8016f6:	89 d0                	mov    %edx,%eax
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016fa:	f3 0f 1e fb          	endbr32 
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	53                   	push   %ebx
  801702:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801705:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801708:	b8 00 00 00 00       	mov    $0x0,%eax
  80170d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801711:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801714:	83 c0 01             	add    $0x1,%eax
  801717:	84 d2                	test   %dl,%dl
  801719:	75 f2                	jne    80170d <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80171b:	89 c8                	mov    %ecx,%eax
  80171d:	5b                   	pop    %ebx
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801720:	f3 0f 1e fb          	endbr32 
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	53                   	push   %ebx
  801728:	83 ec 10             	sub    $0x10,%esp
  80172b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80172e:	53                   	push   %ebx
  80172f:	e8 83 ff ff ff       	call   8016b7 <strlen>
  801734:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801737:	ff 75 0c             	pushl  0xc(%ebp)
  80173a:	01 d8                	add    %ebx,%eax
  80173c:	50                   	push   %eax
  80173d:	e8 b8 ff ff ff       	call   8016fa <strcpy>
	return dst;
}
  801742:	89 d8                	mov    %ebx,%eax
  801744:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801747:	c9                   	leave  
  801748:	c3                   	ret    

00801749 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801749:	f3 0f 1e fb          	endbr32 
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	56                   	push   %esi
  801751:	53                   	push   %ebx
  801752:	8b 75 08             	mov    0x8(%ebp),%esi
  801755:	8b 55 0c             	mov    0xc(%ebp),%edx
  801758:	89 f3                	mov    %esi,%ebx
  80175a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80175d:	89 f0                	mov    %esi,%eax
  80175f:	39 d8                	cmp    %ebx,%eax
  801761:	74 11                	je     801774 <strncpy+0x2b>
		*dst++ = *src;
  801763:	83 c0 01             	add    $0x1,%eax
  801766:	0f b6 0a             	movzbl (%edx),%ecx
  801769:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80176c:	80 f9 01             	cmp    $0x1,%cl
  80176f:	83 da ff             	sbb    $0xffffffff,%edx
  801772:	eb eb                	jmp    80175f <strncpy+0x16>
	}
	return ret;
}
  801774:	89 f0                	mov    %esi,%eax
  801776:	5b                   	pop    %ebx
  801777:	5e                   	pop    %esi
  801778:	5d                   	pop    %ebp
  801779:	c3                   	ret    

0080177a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80177a:	f3 0f 1e fb          	endbr32 
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	56                   	push   %esi
  801782:	53                   	push   %ebx
  801783:	8b 75 08             	mov    0x8(%ebp),%esi
  801786:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801789:	8b 55 10             	mov    0x10(%ebp),%edx
  80178c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80178e:	85 d2                	test   %edx,%edx
  801790:	74 21                	je     8017b3 <strlcpy+0x39>
  801792:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801796:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801798:	39 c2                	cmp    %eax,%edx
  80179a:	74 14                	je     8017b0 <strlcpy+0x36>
  80179c:	0f b6 19             	movzbl (%ecx),%ebx
  80179f:	84 db                	test   %bl,%bl
  8017a1:	74 0b                	je     8017ae <strlcpy+0x34>
			*dst++ = *src++;
  8017a3:	83 c1 01             	add    $0x1,%ecx
  8017a6:	83 c2 01             	add    $0x1,%edx
  8017a9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8017ac:	eb ea                	jmp    801798 <strlcpy+0x1e>
  8017ae:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8017b0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017b3:	29 f0                	sub    %esi,%eax
}
  8017b5:	5b                   	pop    %ebx
  8017b6:	5e                   	pop    %esi
  8017b7:	5d                   	pop    %ebp
  8017b8:	c3                   	ret    

008017b9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017b9:	f3 0f 1e fb          	endbr32 
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017c6:	0f b6 01             	movzbl (%ecx),%eax
  8017c9:	84 c0                	test   %al,%al
  8017cb:	74 0c                	je     8017d9 <strcmp+0x20>
  8017cd:	3a 02                	cmp    (%edx),%al
  8017cf:	75 08                	jne    8017d9 <strcmp+0x20>
		p++, q++;
  8017d1:	83 c1 01             	add    $0x1,%ecx
  8017d4:	83 c2 01             	add    $0x1,%edx
  8017d7:	eb ed                	jmp    8017c6 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d9:	0f b6 c0             	movzbl %al,%eax
  8017dc:	0f b6 12             	movzbl (%edx),%edx
  8017df:	29 d0                	sub    %edx,%eax
}
  8017e1:	5d                   	pop    %ebp
  8017e2:	c3                   	ret    

008017e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017e3:	f3 0f 1e fb          	endbr32 
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	53                   	push   %ebx
  8017eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f1:	89 c3                	mov    %eax,%ebx
  8017f3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017f6:	eb 06                	jmp    8017fe <strncmp+0x1b>
		n--, p++, q++;
  8017f8:	83 c0 01             	add    $0x1,%eax
  8017fb:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017fe:	39 d8                	cmp    %ebx,%eax
  801800:	74 16                	je     801818 <strncmp+0x35>
  801802:	0f b6 08             	movzbl (%eax),%ecx
  801805:	84 c9                	test   %cl,%cl
  801807:	74 04                	je     80180d <strncmp+0x2a>
  801809:	3a 0a                	cmp    (%edx),%cl
  80180b:	74 eb                	je     8017f8 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80180d:	0f b6 00             	movzbl (%eax),%eax
  801810:	0f b6 12             	movzbl (%edx),%edx
  801813:	29 d0                	sub    %edx,%eax
}
  801815:	5b                   	pop    %ebx
  801816:	5d                   	pop    %ebp
  801817:	c3                   	ret    
		return 0;
  801818:	b8 00 00 00 00       	mov    $0x0,%eax
  80181d:	eb f6                	jmp    801815 <strncmp+0x32>

0080181f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80181f:	f3 0f 1e fb          	endbr32 
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	8b 45 08             	mov    0x8(%ebp),%eax
  801829:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80182d:	0f b6 10             	movzbl (%eax),%edx
  801830:	84 d2                	test   %dl,%dl
  801832:	74 09                	je     80183d <strchr+0x1e>
		if (*s == c)
  801834:	38 ca                	cmp    %cl,%dl
  801836:	74 0a                	je     801842 <strchr+0x23>
	for (; *s; s++)
  801838:	83 c0 01             	add    $0x1,%eax
  80183b:	eb f0                	jmp    80182d <strchr+0xe>
			return (char *) s;
	return 0;
  80183d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801842:	5d                   	pop    %ebp
  801843:	c3                   	ret    

00801844 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801844:	f3 0f 1e fb          	endbr32 
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	8b 45 08             	mov    0x8(%ebp),%eax
  80184e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801852:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801855:	38 ca                	cmp    %cl,%dl
  801857:	74 09                	je     801862 <strfind+0x1e>
  801859:	84 d2                	test   %dl,%dl
  80185b:	74 05                	je     801862 <strfind+0x1e>
	for (; *s; s++)
  80185d:	83 c0 01             	add    $0x1,%eax
  801860:	eb f0                	jmp    801852 <strfind+0xe>
			break;
	return (char *) s;
}
  801862:	5d                   	pop    %ebp
  801863:	c3                   	ret    

00801864 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801864:	f3 0f 1e fb          	endbr32 
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	57                   	push   %edi
  80186c:	56                   	push   %esi
  80186d:	53                   	push   %ebx
  80186e:	8b 55 08             	mov    0x8(%ebp),%edx
  801871:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  801874:	85 c9                	test   %ecx,%ecx
  801876:	74 33                	je     8018ab <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801878:	89 d0                	mov    %edx,%eax
  80187a:	09 c8                	or     %ecx,%eax
  80187c:	a8 03                	test   $0x3,%al
  80187e:	75 23                	jne    8018a3 <memset+0x3f>
		c &= 0xFF;
  801880:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801884:	89 d8                	mov    %ebx,%eax
  801886:	c1 e0 08             	shl    $0x8,%eax
  801889:	89 df                	mov    %ebx,%edi
  80188b:	c1 e7 18             	shl    $0x18,%edi
  80188e:	89 de                	mov    %ebx,%esi
  801890:	c1 e6 10             	shl    $0x10,%esi
  801893:	09 f7                	or     %esi,%edi
  801895:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  801897:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80189a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80189c:	89 d7                	mov    %edx,%edi
  80189e:	fc                   	cld    
  80189f:	f3 ab                	rep stos %eax,%es:(%edi)
  8018a1:	eb 08                	jmp    8018ab <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018a3:	89 d7                	mov    %edx,%edi
  8018a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a8:	fc                   	cld    
  8018a9:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8018ab:	89 d0                	mov    %edx,%eax
  8018ad:	5b                   	pop    %ebx
  8018ae:	5e                   	pop    %esi
  8018af:	5f                   	pop    %edi
  8018b0:	5d                   	pop    %ebp
  8018b1:	c3                   	ret    

008018b2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018b2:	f3 0f 1e fb          	endbr32 
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	57                   	push   %edi
  8018ba:	56                   	push   %esi
  8018bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018be:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018c4:	39 c6                	cmp    %eax,%esi
  8018c6:	73 32                	jae    8018fa <memmove+0x48>
  8018c8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018cb:	39 c2                	cmp    %eax,%edx
  8018cd:	76 2b                	jbe    8018fa <memmove+0x48>
		s += n;
		d += n;
  8018cf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d2:	89 fe                	mov    %edi,%esi
  8018d4:	09 ce                	or     %ecx,%esi
  8018d6:	09 d6                	or     %edx,%esi
  8018d8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018de:	75 0e                	jne    8018ee <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018e0:	83 ef 04             	sub    $0x4,%edi
  8018e3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018e6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018e9:	fd                   	std    
  8018ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ec:	eb 09                	jmp    8018f7 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018ee:	83 ef 01             	sub    $0x1,%edi
  8018f1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018f4:	fd                   	std    
  8018f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018f7:	fc                   	cld    
  8018f8:	eb 1a                	jmp    801914 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018fa:	89 c2                	mov    %eax,%edx
  8018fc:	09 ca                	or     %ecx,%edx
  8018fe:	09 f2                	or     %esi,%edx
  801900:	f6 c2 03             	test   $0x3,%dl
  801903:	75 0a                	jne    80190f <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801905:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801908:	89 c7                	mov    %eax,%edi
  80190a:	fc                   	cld    
  80190b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80190d:	eb 05                	jmp    801914 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  80190f:	89 c7                	mov    %eax,%edi
  801911:	fc                   	cld    
  801912:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801914:	5e                   	pop    %esi
  801915:	5f                   	pop    %edi
  801916:	5d                   	pop    %ebp
  801917:	c3                   	ret    

00801918 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801918:	f3 0f 1e fb          	endbr32 
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801922:	ff 75 10             	pushl  0x10(%ebp)
  801925:	ff 75 0c             	pushl  0xc(%ebp)
  801928:	ff 75 08             	pushl  0x8(%ebp)
  80192b:	e8 82 ff ff ff       	call   8018b2 <memmove>
}
  801930:	c9                   	leave  
  801931:	c3                   	ret    

00801932 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801932:	f3 0f 1e fb          	endbr32 
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	56                   	push   %esi
  80193a:	53                   	push   %ebx
  80193b:	8b 45 08             	mov    0x8(%ebp),%eax
  80193e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801941:	89 c6                	mov    %eax,%esi
  801943:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801946:	39 f0                	cmp    %esi,%eax
  801948:	74 1c                	je     801966 <memcmp+0x34>
		if (*s1 != *s2)
  80194a:	0f b6 08             	movzbl (%eax),%ecx
  80194d:	0f b6 1a             	movzbl (%edx),%ebx
  801950:	38 d9                	cmp    %bl,%cl
  801952:	75 08                	jne    80195c <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801954:	83 c0 01             	add    $0x1,%eax
  801957:	83 c2 01             	add    $0x1,%edx
  80195a:	eb ea                	jmp    801946 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  80195c:	0f b6 c1             	movzbl %cl,%eax
  80195f:	0f b6 db             	movzbl %bl,%ebx
  801962:	29 d8                	sub    %ebx,%eax
  801964:	eb 05                	jmp    80196b <memcmp+0x39>
	}

	return 0;
  801966:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80196b:	5b                   	pop    %ebx
  80196c:	5e                   	pop    %esi
  80196d:	5d                   	pop    %ebp
  80196e:	c3                   	ret    

0080196f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80196f:	f3 0f 1e fb          	endbr32 
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	8b 45 08             	mov    0x8(%ebp),%eax
  801979:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80197c:	89 c2                	mov    %eax,%edx
  80197e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801981:	39 d0                	cmp    %edx,%eax
  801983:	73 09                	jae    80198e <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801985:	38 08                	cmp    %cl,(%eax)
  801987:	74 05                	je     80198e <memfind+0x1f>
	for (; s < ends; s++)
  801989:	83 c0 01             	add    $0x1,%eax
  80198c:	eb f3                	jmp    801981 <memfind+0x12>
			break;
	return (void *) s;
}
  80198e:	5d                   	pop    %ebp
  80198f:	c3                   	ret    

00801990 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801990:	f3 0f 1e fb          	endbr32 
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	57                   	push   %edi
  801998:	56                   	push   %esi
  801999:	53                   	push   %ebx
  80199a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80199d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019a0:	eb 03                	jmp    8019a5 <strtol+0x15>
		s++;
  8019a2:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8019a5:	0f b6 01             	movzbl (%ecx),%eax
  8019a8:	3c 20                	cmp    $0x20,%al
  8019aa:	74 f6                	je     8019a2 <strtol+0x12>
  8019ac:	3c 09                	cmp    $0x9,%al
  8019ae:	74 f2                	je     8019a2 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  8019b0:	3c 2b                	cmp    $0x2b,%al
  8019b2:	74 2a                	je     8019de <strtol+0x4e>
	int neg = 0;
  8019b4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8019b9:	3c 2d                	cmp    $0x2d,%al
  8019bb:	74 2b                	je     8019e8 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019bd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019c3:	75 0f                	jne    8019d4 <strtol+0x44>
  8019c5:	80 39 30             	cmpb   $0x30,(%ecx)
  8019c8:	74 28                	je     8019f2 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019ca:	85 db                	test   %ebx,%ebx
  8019cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019d1:	0f 44 d8             	cmove  %eax,%ebx
  8019d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019dc:	eb 46                	jmp    801a24 <strtol+0x94>
		s++;
  8019de:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019e1:	bf 00 00 00 00       	mov    $0x0,%edi
  8019e6:	eb d5                	jmp    8019bd <strtol+0x2d>
		s++, neg = 1;
  8019e8:	83 c1 01             	add    $0x1,%ecx
  8019eb:	bf 01 00 00 00       	mov    $0x1,%edi
  8019f0:	eb cb                	jmp    8019bd <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019f2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019f6:	74 0e                	je     801a06 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019f8:	85 db                	test   %ebx,%ebx
  8019fa:	75 d8                	jne    8019d4 <strtol+0x44>
		s++, base = 8;
  8019fc:	83 c1 01             	add    $0x1,%ecx
  8019ff:	bb 08 00 00 00       	mov    $0x8,%ebx
  801a04:	eb ce                	jmp    8019d4 <strtol+0x44>
		s += 2, base = 16;
  801a06:	83 c1 02             	add    $0x2,%ecx
  801a09:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a0e:	eb c4                	jmp    8019d4 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801a10:	0f be d2             	movsbl %dl,%edx
  801a13:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a16:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a19:	7d 3a                	jge    801a55 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801a1b:	83 c1 01             	add    $0x1,%ecx
  801a1e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a22:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a24:	0f b6 11             	movzbl (%ecx),%edx
  801a27:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a2a:	89 f3                	mov    %esi,%ebx
  801a2c:	80 fb 09             	cmp    $0x9,%bl
  801a2f:	76 df                	jbe    801a10 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801a31:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a34:	89 f3                	mov    %esi,%ebx
  801a36:	80 fb 19             	cmp    $0x19,%bl
  801a39:	77 08                	ja     801a43 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a3b:	0f be d2             	movsbl %dl,%edx
  801a3e:	83 ea 57             	sub    $0x57,%edx
  801a41:	eb d3                	jmp    801a16 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801a43:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a46:	89 f3                	mov    %esi,%ebx
  801a48:	80 fb 19             	cmp    $0x19,%bl
  801a4b:	77 08                	ja     801a55 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a4d:	0f be d2             	movsbl %dl,%edx
  801a50:	83 ea 37             	sub    $0x37,%edx
  801a53:	eb c1                	jmp    801a16 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a59:	74 05                	je     801a60 <strtol+0xd0>
		*endptr = (char *) s;
  801a5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a5e:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a60:	89 c2                	mov    %eax,%edx
  801a62:	f7 da                	neg    %edx
  801a64:	85 ff                	test   %edi,%edi
  801a66:	0f 45 c2             	cmovne %edx,%eax
}
  801a69:	5b                   	pop    %ebx
  801a6a:	5e                   	pop    %esi
  801a6b:	5f                   	pop    %edi
  801a6c:	5d                   	pop    %ebp
  801a6d:	c3                   	ret    

00801a6e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a6e:	f3 0f 1e fb          	endbr32 
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801a78:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801a7f:	74 0a                	je     801a8b <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801a81:	8b 45 08             	mov    0x8(%ebp),%eax
  801a84:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801a89:	c9                   	leave  
  801a8a:	c3                   	ret    
		if (sys_page_alloc(0,
  801a8b:	83 ec 04             	sub    $0x4,%esp
  801a8e:	6a 07                	push   $0x7
  801a90:	68 00 f0 bf ee       	push   $0xeebff000
  801a95:	6a 00                	push   $0x0
  801a97:	e8 3c e7 ff ff       	call   8001d8 <sys_page_alloc>
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	78 2a                	js     801acd <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  801aa3:	83 ec 08             	sub    $0x8,%esp
  801aa6:	68 15 03 80 00       	push   $0x800315
  801aab:	6a 00                	push   $0x0
  801aad:	e8 ed e7 ff ff       	call   80029f <sys_env_set_pgfault_upcall>
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	79 c8                	jns    801a81 <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  801ab9:	83 ec 04             	sub    $0x4,%esp
  801abc:	68 f4 22 80 00       	push   $0x8022f4
  801ac1:	6a 25                	push   $0x25
  801ac3:	68 3b 23 80 00       	push   $0x80233b
  801ac8:	e8 dc f5 ff ff       	call   8010a9 <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  801acd:	83 ec 04             	sub    $0x4,%esp
  801ad0:	68 c0 22 80 00       	push   $0x8022c0
  801ad5:	6a 21                	push   $0x21
  801ad7:	68 3b 23 80 00       	push   $0x80233b
  801adc:	e8 c8 f5 ff ff       	call   8010a9 <_panic>

00801ae1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ae1:	f3 0f 1e fb          	endbr32 
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	56                   	push   %esi
  801ae9:	53                   	push   %ebx
  801aea:	8b 75 08             	mov    0x8(%ebp),%esi
  801aed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  801af3:	85 c0                	test   %eax,%eax
  801af5:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801afa:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801afd:	83 ec 0c             	sub    $0xc,%esp
  801b00:	50                   	push   %eax
  801b01:	e8 e9 e7 ff ff       	call   8002ef <sys_ipc_recv>
	if (f < 0) {
  801b06:	83 c4 10             	add    $0x10,%esp
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	78 2b                	js     801b38 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801b0d:	85 f6                	test   %esi,%esi
  801b0f:	74 0a                	je     801b1b <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801b11:	a1 04 40 80 00       	mov    0x804004,%eax
  801b16:	8b 40 74             	mov    0x74(%eax),%eax
  801b19:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801b1b:	85 db                	test   %ebx,%ebx
  801b1d:	74 0a                	je     801b29 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801b1f:	a1 04 40 80 00       	mov    0x804004,%eax
  801b24:	8b 40 78             	mov    0x78(%eax),%eax
  801b27:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  801b29:	a1 04 40 80 00       	mov    0x804004,%eax
  801b2e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b34:	5b                   	pop    %ebx
  801b35:	5e                   	pop    %esi
  801b36:	5d                   	pop    %ebp
  801b37:	c3                   	ret    
		if (from_env_store != NULL) {
  801b38:	85 f6                	test   %esi,%esi
  801b3a:	74 06                	je     801b42 <ipc_recv+0x61>
			*from_env_store = 0;
  801b3c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801b42:	85 db                	test   %ebx,%ebx
  801b44:	74 eb                	je     801b31 <ipc_recv+0x50>
			*perm_store = 0;
  801b46:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b4c:	eb e3                	jmp    801b31 <ipc_recv+0x50>

00801b4e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b4e:	f3 0f 1e fb          	endbr32 
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	57                   	push   %edi
  801b56:	56                   	push   %esi
  801b57:	53                   	push   %ebx
  801b58:	83 ec 0c             	sub    $0xc,%esp
  801b5b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b5e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  801b64:	85 db                	test   %ebx,%ebx
  801b66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b6b:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b6e:	ff 75 14             	pushl  0x14(%ebp)
  801b71:	53                   	push   %ebx
  801b72:	56                   	push   %esi
  801b73:	57                   	push   %edi
  801b74:	e8 4d e7 ff ff       	call   8002c6 <sys_ipc_try_send>
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	85 c0                	test   %eax,%eax
  801b7e:	79 19                	jns    801b99 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  801b80:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b83:	74 e9                	je     801b6e <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  801b85:	83 ec 04             	sub    $0x4,%esp
  801b88:	68 4c 23 80 00       	push   $0x80234c
  801b8d:	6a 48                	push   $0x48
  801b8f:	68 6e 23 80 00       	push   $0x80236e
  801b94:	e8 10 f5 ff ff       	call   8010a9 <_panic>
		}
	}
}
  801b99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9c:	5b                   	pop    %ebx
  801b9d:	5e                   	pop    %esi
  801b9e:	5f                   	pop    %edi
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    

00801ba1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ba1:	f3 0f 1e fb          	endbr32 
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bab:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bb0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bb3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bb9:	8b 52 50             	mov    0x50(%edx),%edx
  801bbc:	39 ca                	cmp    %ecx,%edx
  801bbe:	74 11                	je     801bd1 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801bc0:	83 c0 01             	add    $0x1,%eax
  801bc3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bc8:	75 e6                	jne    801bb0 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801bca:	b8 00 00 00 00       	mov    $0x0,%eax
  801bcf:	eb 0b                	jmp    801bdc <ipc_find_env+0x3b>
			return envs[i].env_id;
  801bd1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bd4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bd9:	8b 40 48             	mov    0x48(%eax),%eax
}
  801bdc:	5d                   	pop    %ebp
  801bdd:	c3                   	ret    

00801bde <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bde:	f3 0f 1e fb          	endbr32 
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801be8:	89 c2                	mov    %eax,%edx
  801bea:	c1 ea 16             	shr    $0x16,%edx
  801bed:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801bf4:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801bf9:	f6 c1 01             	test   $0x1,%cl
  801bfc:	74 1c                	je     801c1a <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801bfe:	c1 e8 0c             	shr    $0xc,%eax
  801c01:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c08:	a8 01                	test   $0x1,%al
  801c0a:	74 0e                	je     801c1a <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c0c:	c1 e8 0c             	shr    $0xc,%eax
  801c0f:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c16:	ef 
  801c17:	0f b7 d2             	movzwl %dx,%edx
}
  801c1a:	89 d0                	mov    %edx,%eax
  801c1c:	5d                   	pop    %ebp
  801c1d:	c3                   	ret    
  801c1e:	66 90                	xchg   %ax,%ax

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
