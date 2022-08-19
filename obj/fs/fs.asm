
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 1c 1c 00 00       	call   801c4d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <inb>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800033:	89 c2                	mov    %eax,%edx
  800035:	ec                   	in     (%dx),%al
	return data;
}
  800036:	c3                   	ret    

00800037 <insl>:
	return data;
}

static inline void
insl(int port, void *addr, int cnt)
{
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
	asm volatile("cld\n\trepne\n\tinsl"
  80003b:	89 d7                	mov    %edx,%edi
  80003d:	89 c2                	mov    %eax,%edx
  80003f:	fc                   	cld    
  800040:	f2 6d                	repnz insl (%dx),%es:(%edi)
		     : "=D" (addr), "=c" (cnt)
		     : "d" (port), "0" (addr), "1" (cnt)
		     : "memory", "cc");
}
  800042:	5f                   	pop    %edi
  800043:	5d                   	pop    %ebp
  800044:	c3                   	ret    

00800045 <outb>:

static inline void
outb(int port, uint8_t data)
{
  800045:	89 c1                	mov    %eax,%ecx
  800047:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800049:	89 ca                	mov    %ecx,%edx
  80004b:	ee                   	out    %al,(%dx)
}
  80004c:	c3                   	ret    

0080004d <outsl>:
		     : "cc");
}

static inline void
outsl(int port, const void *addr, int cnt)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	56                   	push   %esi
	asm volatile("cld\n\trepne\n\toutsl"
  800051:	89 d6                	mov    %edx,%esi
  800053:	89 c2                	mov    %eax,%edx
  800055:	fc                   	cld    
  800056:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
		     : "=S" (addr), "=c" (cnt)
		     : "d" (port), "0" (addr), "1" (cnt)
		     : "cc");
}
  800058:	5e                   	pop    %esi
  800059:	5d                   	pop    %ebp
  80005a:	c3                   	ret    

0080005b <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  80005b:	55                   	push   %ebp
  80005c:	89 e5                	mov    %esp,%ebp
  80005e:	53                   	push   %ebx
  80005f:	83 ec 04             	sub    $0x4,%esp
  800062:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800064:	b8 f7 01 00 00       	mov    $0x1f7,%eax
  800069:	e8 c5 ff ff ff       	call   800033 <inb>
  80006e:	89 c2                	mov    %eax,%edx
  800070:	83 e2 c0             	and    $0xffffffc0,%edx
  800073:	80 fa 40             	cmp    $0x40,%dl
  800076:	75 ec                	jne    800064 <ide_wait_ready+0x9>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800078:	ba 00 00 00 00       	mov    $0x0,%edx
	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80007d:	84 db                	test   %bl,%bl
  80007f:	74 0a                	je     80008b <ide_wait_ready+0x30>
  800081:	a8 21                	test   $0x21,%al
  800083:	0f 95 c2             	setne  %dl
  800086:	0f b6 d2             	movzbl %dl,%edx
  800089:	f7 da                	neg    %edx
}
  80008b:	89 d0                	mov    %edx,%eax
  80008d:	83 c4 04             	add    $0x4,%esp
  800090:	5b                   	pop    %ebx
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    

00800093 <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  800093:	f3 0f 1e fb          	endbr32 
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	53                   	push   %ebx
  80009b:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  80009e:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a3:	e8 b3 ff ff ff       	call   80005b <ide_wait_ready>

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));
  8000a8:	ba f0 00 00 00       	mov    $0xf0,%edx
  8000ad:	b8 f6 01 00 00       	mov    $0x1f6,%eax
  8000b2:	e8 8e ff ff ff       	call   800045 <outb>

	// check for Device 1 to be ready for a while
	for (x = 0;
  8000b7:	bb 00 00 00 00       	mov    $0x0,%ebx
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  8000bc:	b8 f7 01 00 00       	mov    $0x1f7,%eax
  8000c1:	e8 6d ff ff ff       	call   800033 <inb>
  8000c6:	a8 a1                	test   $0xa1,%al
  8000c8:	74 0b                	je     8000d5 <ide_probe_disk1+0x42>
	     x++)
  8000ca:	83 c3 01             	add    $0x1,%ebx
	for (x = 0;
  8000cd:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
  8000d3:	75 e7                	jne    8000bc <ide_probe_disk1+0x29>
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));
  8000d5:	ba e0 00 00 00       	mov    $0xe0,%edx
  8000da:	b8 f6 01 00 00       	mov    $0x1f6,%eax
  8000df:	e8 61 ff ff ff       	call   800045 <outb>

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000e4:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  8000ea:	0f 9e c3             	setle  %bl
  8000ed:	83 ec 08             	sub    $0x8,%esp
  8000f0:	0f b6 c3             	movzbl %bl,%eax
  8000f3:	50                   	push   %eax
  8000f4:	68 80 3a 80 00       	push   $0x803a80
  8000f9:	e8 a2 1c 00 00       	call   801da0 <cprintf>
	return (x < 1000);
}
  8000fe:	89 d8                	mov    %ebx,%eax
  800100:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800103:	c9                   	leave  
  800104:	c3                   	ret    

00800105 <ide_set_disk>:

void
ide_set_disk(int d)
{
  800105:	f3 0f 1e fb          	endbr32 
  800109:	55                   	push   %ebp
  80010a:	89 e5                	mov    %esp,%ebp
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  800112:	83 f8 01             	cmp    $0x1,%eax
  800115:	77 07                	ja     80011e <ide_set_disk+0x19>
		panic("bad disk number");
	diskno = d;
  800117:	a3 00 50 80 00       	mov    %eax,0x805000
}
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    
		panic("bad disk number");
  80011e:	83 ec 04             	sub    $0x4,%esp
  800121:	68 97 3a 80 00       	push   $0x803a97
  800126:	6a 3a                	push   $0x3a
  800128:	68 a7 3a 80 00       	push   $0x803aa7
  80012d:	e8 87 1b 00 00       	call   801cb9 <_panic>

00800132 <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  800132:	f3 0f 1e fb          	endbr32 
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
  80013c:	83 ec 0c             	sub    $0xc,%esp
  80013f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800142:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800145:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  800148:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  80014e:	0f 87 84 00 00 00    	ja     8001d8 <ide_read+0xa6>

	ide_wait_ready(0);
  800154:	b8 00 00 00 00       	mov    $0x0,%eax
  800159:	e8 fd fe ff ff       	call   80005b <ide_wait_ready>

	outb(0x1F2, nsecs);
  80015e:	89 f0                	mov    %esi,%eax
  800160:	0f b6 d0             	movzbl %al,%edx
  800163:	b8 f2 01 00 00       	mov    $0x1f2,%eax
  800168:	e8 d8 fe ff ff       	call   800045 <outb>
	outb(0x1F3, secno & 0xFF);
  80016d:	89 f8                	mov    %edi,%eax
  80016f:	0f b6 d0             	movzbl %al,%edx
  800172:	b8 f3 01 00 00       	mov    $0x1f3,%eax
  800177:	e8 c9 fe ff ff       	call   800045 <outb>
	outb(0x1F4, (secno >> 8) & 0xFF);
  80017c:	89 f8                	mov    %edi,%eax
  80017e:	0f b6 d4             	movzbl %ah,%edx
  800181:	b8 f4 01 00 00       	mov    $0x1f4,%eax
  800186:	e8 ba fe ff ff       	call   800045 <outb>
	outb(0x1F5, (secno >> 16) & 0xFF);
  80018b:	89 fa                	mov    %edi,%edx
  80018d:	c1 ea 10             	shr    $0x10,%edx
  800190:	0f b6 d2             	movzbl %dl,%edx
  800193:	b8 f5 01 00 00       	mov    $0x1f5,%eax
  800198:	e8 a8 fe ff ff       	call   800045 <outb>
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  80019d:	0f b6 15 00 50 80 00 	movzbl 0x805000,%edx
  8001a4:	c1 e2 04             	shl    $0x4,%edx
  8001a7:	83 e2 10             	and    $0x10,%edx
  8001aa:	c1 ef 18             	shr    $0x18,%edi
  8001ad:	83 e7 0f             	and    $0xf,%edi
  8001b0:	09 fa                	or     %edi,%edx
  8001b2:	83 ca e0             	or     $0xffffffe0,%edx
  8001b5:	0f b6 d2             	movzbl %dl,%edx
  8001b8:	b8 f6 01 00 00       	mov    $0x1f6,%eax
  8001bd:	e8 83 fe ff ff       	call   800045 <outb>
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector
  8001c2:	ba 20 00 00 00       	mov    $0x20,%edx
  8001c7:	b8 f7 01 00 00       	mov    $0x1f7,%eax
  8001cc:	e8 74 fe ff ff       	call   800045 <outb>
  8001d1:	c1 e6 09             	shl    $0x9,%esi
  8001d4:	01 de                	add    %ebx,%esi

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  8001d6:	eb 2d                	jmp    800205 <ide_read+0xd3>
	assert(nsecs <= 256);
  8001d8:	68 b0 3a 80 00       	push   $0x803ab0
  8001dd:	68 bd 3a 80 00       	push   $0x803abd
  8001e2:	6a 44                	push   $0x44
  8001e4:	68 a7 3a 80 00       	push   $0x803aa7
  8001e9:	e8 cb 1a 00 00       	call   801cb9 <_panic>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
  8001ee:	b9 80 00 00 00       	mov    $0x80,%ecx
  8001f3:	89 da                	mov    %ebx,%edx
  8001f5:	b8 f0 01 00 00       	mov    $0x1f0,%eax
  8001fa:	e8 38 fe ff ff       	call   800037 <insl>
	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  8001ff:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800205:	39 f3                	cmp    %esi,%ebx
  800207:	74 10                	je     800219 <ide_read+0xe7>
		if ((r = ide_wait_ready(1)) < 0)
  800209:	b8 01 00 00 00       	mov    $0x1,%eax
  80020e:	e8 48 fe ff ff       	call   80005b <ide_wait_ready>
  800213:	85 c0                	test   %eax,%eax
  800215:	79 d7                	jns    8001ee <ide_read+0xbc>
  800217:	eb 05                	jmp    80021e <ide_read+0xec>
	}

	return 0;
  800219:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80021e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800221:	5b                   	pop    %ebx
  800222:	5e                   	pop    %esi
  800223:	5f                   	pop    %edi
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  800226:	f3 0f 1e fb          	endbr32 
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	8b 7d 08             	mov    0x8(%ebp),%edi
  800236:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800239:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  80023c:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800242:	0f 87 84 00 00 00    	ja     8002cc <ide_write+0xa6>

	ide_wait_ready(0);
  800248:	b8 00 00 00 00       	mov    $0x0,%eax
  80024d:	e8 09 fe ff ff       	call   80005b <ide_wait_ready>

	outb(0x1F2, nsecs);
  800252:	89 f0                	mov    %esi,%eax
  800254:	0f b6 d0             	movzbl %al,%edx
  800257:	b8 f2 01 00 00       	mov    $0x1f2,%eax
  80025c:	e8 e4 fd ff ff       	call   800045 <outb>
	outb(0x1F3, secno & 0xFF);
  800261:	89 f8                	mov    %edi,%eax
  800263:	0f b6 d0             	movzbl %al,%edx
  800266:	b8 f3 01 00 00       	mov    $0x1f3,%eax
  80026b:	e8 d5 fd ff ff       	call   800045 <outb>
	outb(0x1F4, (secno >> 8) & 0xFF);
  800270:	89 f8                	mov    %edi,%eax
  800272:	0f b6 d4             	movzbl %ah,%edx
  800275:	b8 f4 01 00 00       	mov    $0x1f4,%eax
  80027a:	e8 c6 fd ff ff       	call   800045 <outb>
	outb(0x1F5, (secno >> 16) & 0xFF);
  80027f:	89 fa                	mov    %edi,%edx
  800281:	c1 ea 10             	shr    $0x10,%edx
  800284:	0f b6 d2             	movzbl %dl,%edx
  800287:	b8 f5 01 00 00       	mov    $0x1f5,%eax
  80028c:	e8 b4 fd ff ff       	call   800045 <outb>
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800291:	0f b6 15 00 50 80 00 	movzbl 0x805000,%edx
  800298:	c1 e2 04             	shl    $0x4,%edx
  80029b:	83 e2 10             	and    $0x10,%edx
  80029e:	c1 ef 18             	shr    $0x18,%edi
  8002a1:	83 e7 0f             	and    $0xf,%edi
  8002a4:	09 fa                	or     %edi,%edx
  8002a6:	83 ca e0             	or     $0xffffffe0,%edx
  8002a9:	0f b6 d2             	movzbl %dl,%edx
  8002ac:	b8 f6 01 00 00       	mov    $0x1f6,%eax
  8002b1:	e8 8f fd ff ff       	call   800045 <outb>
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector
  8002b6:	ba 30 00 00 00       	mov    $0x30,%edx
  8002bb:	b8 f7 01 00 00       	mov    $0x1f7,%eax
  8002c0:	e8 80 fd ff ff       	call   800045 <outb>
  8002c5:	c1 e6 09             	shl    $0x9,%esi
  8002c8:	01 de                	add    %ebx,%esi

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  8002ca:	eb 2d                	jmp    8002f9 <ide_write+0xd3>
	assert(nsecs <= 256);
  8002cc:	68 b0 3a 80 00       	push   $0x803ab0
  8002d1:	68 bd 3a 80 00       	push   $0x803abd
  8002d6:	6a 5d                	push   $0x5d
  8002d8:	68 a7 3a 80 00       	push   $0x803aa7
  8002dd:	e8 d7 19 00 00       	call   801cb9 <_panic>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
  8002e2:	b9 80 00 00 00       	mov    $0x80,%ecx
  8002e7:	89 da                	mov    %ebx,%edx
  8002e9:	b8 f0 01 00 00       	mov    $0x1f0,%eax
  8002ee:	e8 5a fd ff ff       	call   80004d <outsl>
	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  8002f3:	81 c3 00 02 00 00    	add    $0x200,%ebx
  8002f9:	39 f3                	cmp    %esi,%ebx
  8002fb:	74 10                	je     80030d <ide_write+0xe7>
		if ((r = ide_wait_ready(1)) < 0)
  8002fd:	b8 01 00 00 00       	mov    $0x1,%eax
  800302:	e8 54 fd ff ff       	call   80005b <ide_wait_ready>
  800307:	85 c0                	test   %eax,%eax
  800309:	79 d7                	jns    8002e2 <ide_write+0xbc>
  80030b:	eb 05                	jmp    800312 <ide_write+0xec>
	}

	return 0;
  80030d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800312:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  80031a:	f3 0f 1e fb          	endbr32 
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800326:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t) addr - DISKMAP) / BLKSIZE;
  800328:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80032e:	89 c6                	mov    %eax,%esi
  800330:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void *) DISKMAP || addr >= (void *) (DISKMAP + DISKSIZE))
  800333:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800338:	0f 87 8f 00 00 00    	ja     8003cd <bc_pgfault+0xb3>
		      utf->utf_eip,
		      addr,
		      utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  80033e:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800343:	85 c0                	test   %eax,%eax
  800345:	74 09                	je     800350 <bc_pgfault+0x36>
  800347:	39 70 04             	cmp    %esi,0x4(%eax)
  80034a:	0f 86 98 00 00 00    	jbe    8003e8 <bc_pgfault+0xce>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	if ((r = sys_page_alloc(0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800350:	83 ec 04             	sub    $0x4,%esp
  800353:	6a 07                	push   $0x7
  800355:	53                   	push   %ebx
  800356:	6a 00                	push   $0x0
  800358:	e8 35 24 00 00       	call   802792 <sys_page_alloc>
  80035d:	83 c4 10             	add    $0x10,%esp
  800360:	85 c0                	test   %eax,%eax
  800362:	0f 88 92 00 00 00    	js     8003fa <bc_pgfault+0xe0>
		panic("bc_pgfault: sys_page_alloc: %e", r);

	if ((r = ide_read(blockno * BLKSECTS, addr, BLKSECTS)) < 0)
  800368:	83 ec 04             	sub    $0x4,%esp
  80036b:	6a 08                	push   $0x8
  80036d:	53                   	push   %ebx
  80036e:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800375:	50                   	push   %eax
  800376:	e8 b7 fd ff ff       	call   800132 <ide_read>
  80037b:	83 c4 10             	add    $0x10,%esp
  80037e:	85 c0                	test   %eax,%eax
  800380:	0f 88 86 00 00 00    	js     80040c <bc_pgfault+0xf2>
		panic("bc_pgfault: ide_read: %e", r);

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) <
  800386:	89 d8                	mov    %ebx,%eax
  800388:	c1 e8 0c             	shr    $0xc,%eax
  80038b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800392:	83 ec 0c             	sub    $0xc,%esp
  800395:	25 07 0e 00 00       	and    $0xe07,%eax
  80039a:	50                   	push   %eax
  80039b:	53                   	push   %ebx
  80039c:	6a 00                	push   $0x0
  80039e:	53                   	push   %ebx
  80039f:	6a 00                	push   $0x0
  8003a1:	e8 14 24 00 00       	call   8027ba <sys_page_map>
  8003a6:	83 c4 20             	add    $0x20,%esp
  8003a9:	85 c0                	test   %eax,%eax
  8003ab:	78 71                	js     80041e <bc_pgfault+0x104>
		panic("in bc_pgfault, sys_page_map: %e", r);

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  8003ad:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  8003b4:	74 10                	je     8003c6 <bc_pgfault+0xac>
  8003b6:	83 ec 0c             	sub    $0xc,%esp
  8003b9:	56                   	push   %esi
  8003ba:	e8 2b 05 00 00       	call   8008ea <block_is_free>
  8003bf:	83 c4 10             	add    $0x10,%esp
  8003c2:	84 c0                	test   %al,%al
  8003c4:	75 6a                	jne    800430 <bc_pgfault+0x116>
		panic("reading free block %08x\n", blockno);
}
  8003c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003c9:	5b                   	pop    %ebx
  8003ca:	5e                   	pop    %esi
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  8003cd:	83 ec 08             	sub    $0x8,%esp
  8003d0:	ff 72 04             	pushl  0x4(%edx)
  8003d3:	53                   	push   %ebx
  8003d4:	ff 72 28             	pushl  0x28(%edx)
  8003d7:	68 d4 3a 80 00       	push   $0x803ad4
  8003dc:	6a 26                	push   $0x26
  8003de:	68 b0 3b 80 00       	push   $0x803bb0
  8003e3:	e8 d1 18 00 00       	call   801cb9 <_panic>
		panic("reading non-existent block %08x\n", blockno);
  8003e8:	56                   	push   %esi
  8003e9:	68 04 3b 80 00       	push   $0x803b04
  8003ee:	6a 2d                	push   $0x2d
  8003f0:	68 b0 3b 80 00       	push   $0x803bb0
  8003f5:	e8 bf 18 00 00       	call   801cb9 <_panic>
		panic("bc_pgfault: sys_page_alloc: %e", r);
  8003fa:	50                   	push   %eax
  8003fb:	68 28 3b 80 00       	push   $0x803b28
  800400:	6a 36                	push   $0x36
  800402:	68 b0 3b 80 00       	push   $0x803bb0
  800407:	e8 ad 18 00 00       	call   801cb9 <_panic>
		panic("bc_pgfault: ide_read: %e", r);
  80040c:	50                   	push   %eax
  80040d:	68 b8 3b 80 00       	push   $0x803bb8
  800412:	6a 39                	push   $0x39
  800414:	68 b0 3b 80 00       	push   $0x803bb0
  800419:	e8 9b 18 00 00       	call   801cb9 <_panic>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80041e:	50                   	push   %eax
  80041f:	68 48 3b 80 00       	push   $0x803b48
  800424:	6a 3f                	push   $0x3f
  800426:	68 b0 3b 80 00       	push   $0x803bb0
  80042b:	e8 89 18 00 00       	call   801cb9 <_panic>
		panic("reading free block %08x\n", blockno);
  800430:	56                   	push   %esi
  800431:	68 d1 3b 80 00       	push   $0x803bd1
  800436:	6a 45                	push   $0x45
  800438:	68 b0 3b 80 00       	push   $0x803bb0
  80043d:	e8 77 18 00 00       	call   801cb9 <_panic>

00800442 <diskaddr>:
{
  800442:	f3 0f 1e fb          	endbr32 
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  80044f:	85 c0                	test   %eax,%eax
  800451:	74 19                	je     80046c <diskaddr+0x2a>
  800453:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800459:	85 d2                	test   %edx,%edx
  80045b:	74 05                	je     800462 <diskaddr+0x20>
  80045d:	39 42 04             	cmp    %eax,0x4(%edx)
  800460:	76 0a                	jbe    80046c <diskaddr+0x2a>
	return (char *) (DISKMAP + blockno * BLKSIZE);
  800462:	05 00 00 01 00       	add    $0x10000,%eax
  800467:	c1 e0 0c             	shl    $0xc,%eax
}
  80046a:	c9                   	leave  
  80046b:	c3                   	ret    
		panic("bad block number %08x in diskaddr", blockno);
  80046c:	50                   	push   %eax
  80046d:	68 68 3b 80 00       	push   $0x803b68
  800472:	6a 09                	push   $0x9
  800474:	68 b0 3b 80 00       	push   $0x803bb0
  800479:	e8 3b 18 00 00       	call   801cb9 <_panic>

0080047e <va_is_mapped>:
{
  80047e:	f3 0f 1e fb          	endbr32 
  800482:	55                   	push   %ebp
  800483:	89 e5                	mov    %esp,%ebp
  800485:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  800488:	89 d0                	mov    %edx,%eax
  80048a:	c1 e8 16             	shr    $0x16,%eax
  80048d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  800494:	b8 00 00 00 00       	mov    $0x0,%eax
  800499:	f6 c1 01             	test   $0x1,%cl
  80049c:	74 0d                	je     8004ab <va_is_mapped+0x2d>
  80049e:	c1 ea 0c             	shr    $0xc,%edx
  8004a1:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8004a8:	83 e0 01             	and    $0x1,%eax
  8004ab:	83 e0 01             	and    $0x1,%eax
}
  8004ae:	5d                   	pop    %ebp
  8004af:	c3                   	ret    

008004b0 <va_is_dirty>:
{
  8004b0:	f3 0f 1e fb          	endbr32 
  8004b4:	55                   	push   %ebp
  8004b5:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8004b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ba:	c1 e8 0c             	shr    $0xc,%eax
  8004bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8004c4:	c1 e8 06             	shr    $0x6,%eax
  8004c7:	83 e0 01             	and    $0x1,%eax
}
  8004ca:	5d                   	pop    %ebp
  8004cb:	c3                   	ret    

008004cc <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  8004cc:	f3 0f 1e fb          	endbr32 
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	56                   	push   %esi
  8004d4:	53                   	push   %ebx
  8004d5:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	uint32_t blockno = ((uint32_t) addr - DISKMAP) / BLKSIZE;
  8004d8:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	if (addr < (void *) DISKMAP || addr >= (void *) (DISKMAP + DISKSIZE))
  8004de:	81 fe ff ff ff bf    	cmp    $0xbfffffff,%esi
  8004e4:	77 1e                	ja     800504 <flush_block+0x38>
		panic("flush_block of bad va %08x", addr);

	// LAB 5: Your code here.
	addr = (void *) ROUNDDOWN(addr, BLKSIZE);
  8004e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8004eb:	89 c3                	mov    %eax,%ebx
	if (va_is_mapped(addr) && va_is_dirty(addr)) {
  8004ed:	83 ec 0c             	sub    $0xc,%esp
  8004f0:	50                   	push   %eax
  8004f1:	e8 88 ff ff ff       	call   80047e <va_is_mapped>
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	84 c0                	test   %al,%al
  8004fb:	75 19                	jne    800516 <flush_block+0x4a>
		if ((r = (int) sys_page_map(0, addr, 0, addr, PTE_SYSCALL)) < 0)
			panic("flush_block: sys_page_map: %e", r);
		if ((r = (int) ide_write(blockno * BLKSECTS, addr, BLKSECTS)) < 0)
			panic("flush_block: ide_write: %e", r);
	}
}
  8004fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800500:	5b                   	pop    %ebx
  800501:	5e                   	pop    %esi
  800502:	5d                   	pop    %ebp
  800503:	c3                   	ret    
		panic("flush_block of bad va %08x", addr);
  800504:	50                   	push   %eax
  800505:	68 ea 3b 80 00       	push   $0x803bea
  80050a:	6a 57                	push   $0x57
  80050c:	68 b0 3b 80 00       	push   $0x803bb0
  800511:	e8 a3 17 00 00       	call   801cb9 <_panic>
	if (va_is_mapped(addr) && va_is_dirty(addr)) {
  800516:	83 ec 0c             	sub    $0xc,%esp
  800519:	53                   	push   %ebx
  80051a:	e8 91 ff ff ff       	call   8004b0 <va_is_dirty>
  80051f:	83 c4 10             	add    $0x10,%esp
  800522:	84 c0                	test   %al,%al
  800524:	74 d7                	je     8004fd <flush_block+0x31>
		if ((r = (int) sys_page_map(0, addr, 0, addr, PTE_SYSCALL)) < 0)
  800526:	83 ec 0c             	sub    $0xc,%esp
  800529:	68 07 0e 00 00       	push   $0xe07
  80052e:	53                   	push   %ebx
  80052f:	6a 00                	push   $0x0
  800531:	53                   	push   %ebx
  800532:	6a 00                	push   $0x0
  800534:	e8 81 22 00 00       	call   8027ba <sys_page_map>
  800539:	83 c4 20             	add    $0x20,%esp
  80053c:	85 c0                	test   %eax,%eax
  80053e:	78 2b                	js     80056b <flush_block+0x9f>
		if ((r = (int) ide_write(blockno * BLKSECTS, addr, BLKSECTS)) < 0)
  800540:	83 ec 04             	sub    $0x4,%esp
  800543:	6a 08                	push   $0x8
  800545:	53                   	push   %ebx
	uint32_t blockno = ((uint32_t) addr - DISKMAP) / BLKSIZE;
  800546:	c1 ee 0c             	shr    $0xc,%esi
		if ((r = (int) ide_write(blockno * BLKSECTS, addr, BLKSECTS)) < 0)
  800549:	c1 e6 03             	shl    $0x3,%esi
  80054c:	56                   	push   %esi
  80054d:	e8 d4 fc ff ff       	call   800226 <ide_write>
  800552:	83 c4 10             	add    $0x10,%esp
  800555:	85 c0                	test   %eax,%eax
  800557:	79 a4                	jns    8004fd <flush_block+0x31>
			panic("flush_block: ide_write: %e", r);
  800559:	50                   	push   %eax
  80055a:	68 23 3c 80 00       	push   $0x803c23
  80055f:	6a 5f                	push   $0x5f
  800561:	68 b0 3b 80 00       	push   $0x803bb0
  800566:	e8 4e 17 00 00       	call   801cb9 <_panic>
			panic("flush_block: sys_page_map: %e", r);
  80056b:	50                   	push   %eax
  80056c:	68 05 3c 80 00       	push   $0x803c05
  800571:	6a 5d                	push   $0x5d
  800573:	68 b0 3b 80 00       	push   $0x803bb0
  800578:	e8 3c 17 00 00       	call   801cb9 <_panic>

0080057d <check_bc>:

// Test that the block cache works, by smashing the superblock and
// reading it back.
static void
check_bc(void)
{
  80057d:	55                   	push   %ebp
  80057e:	89 e5                	mov    %esp,%ebp
  800580:	53                   	push   %ebx
  800581:	81 ec 20 01 00 00    	sub    $0x120,%esp
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800587:	6a 01                	push   $0x1
  800589:	e8 b4 fe ff ff       	call   800442 <diskaddr>
  80058e:	83 c4 0c             	add    $0xc,%esp
  800591:	68 08 01 00 00       	push   $0x108
  800596:	50                   	push   %eax
  800597:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80059d:	50                   	push   %eax
  80059e:	e8 1f 1f 00 00       	call   8024c2 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8005a3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005aa:	e8 93 fe ff ff       	call   800442 <diskaddr>
  8005af:	83 c4 08             	add    $0x8,%esp
  8005b2:	68 3e 3c 80 00       	push   $0x803c3e
  8005b7:	50                   	push   %eax
  8005b8:	e8 4d 1d 00 00       	call   80230a <strcpy>
	flush_block(diskaddr(1));
  8005bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005c4:	e8 79 fe ff ff       	call   800442 <diskaddr>
  8005c9:	89 04 24             	mov    %eax,(%esp)
  8005cc:	e8 fb fe ff ff       	call   8004cc <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  8005d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005d8:	e8 65 fe ff ff       	call   800442 <diskaddr>
  8005dd:	89 04 24             	mov    %eax,(%esp)
  8005e0:	e8 99 fe ff ff       	call   80047e <va_is_mapped>
  8005e5:	83 c4 10             	add    $0x10,%esp
  8005e8:	84 c0                	test   %al,%al
  8005ea:	0f 84 b0 01 00 00    	je     8007a0 <check_bc+0x223>
	assert(!va_is_dirty(diskaddr(1)));
  8005f0:	83 ec 0c             	sub    $0xc,%esp
  8005f3:	6a 01                	push   $0x1
  8005f5:	e8 48 fe ff ff       	call   800442 <diskaddr>
  8005fa:	89 04 24             	mov    %eax,(%esp)
  8005fd:	e8 ae fe ff ff       	call   8004b0 <va_is_dirty>
  800602:	83 c4 10             	add    $0x10,%esp
  800605:	84 c0                	test   %al,%al
  800607:	0f 85 a9 01 00 00    	jne    8007b6 <check_bc+0x239>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80060d:	83 ec 0c             	sub    $0xc,%esp
  800610:	6a 01                	push   $0x1
  800612:	e8 2b fe ff ff       	call   800442 <diskaddr>
  800617:	83 c4 08             	add    $0x8,%esp
  80061a:	50                   	push   %eax
  80061b:	6a 00                	push   $0x0
  80061d:	e8 c2 21 00 00       	call   8027e4 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800622:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800629:	e8 14 fe ff ff       	call   800442 <diskaddr>
  80062e:	89 04 24             	mov    %eax,(%esp)
  800631:	e8 48 fe ff ff       	call   80047e <va_is_mapped>
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	84 c0                	test   %al,%al
  80063b:	0f 85 8b 01 00 00    	jne    8007cc <check_bc+0x24f>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800641:	83 ec 0c             	sub    $0xc,%esp
  800644:	6a 01                	push   $0x1
  800646:	e8 f7 fd ff ff       	call   800442 <diskaddr>
  80064b:	83 c4 08             	add    $0x8,%esp
  80064e:	68 3e 3c 80 00       	push   $0x803c3e
  800653:	50                   	push   %eax
  800654:	e8 70 1d 00 00       	call   8023c9 <strcmp>
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	85 c0                	test   %eax,%eax
  80065e:	0f 85 7e 01 00 00    	jne    8007e2 <check_bc+0x265>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800664:	83 ec 0c             	sub    $0xc,%esp
  800667:	6a 01                	push   $0x1
  800669:	e8 d4 fd ff ff       	call   800442 <diskaddr>
  80066e:	83 c4 0c             	add    $0xc,%esp
  800671:	68 08 01 00 00       	push   $0x108
  800676:	8d 9d f0 fe ff ff    	lea    -0x110(%ebp),%ebx
  80067c:	53                   	push   %ebx
  80067d:	50                   	push   %eax
  80067e:	e8 3f 1e 00 00       	call   8024c2 <memmove>
	flush_block(diskaddr(1));
  800683:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80068a:	e8 b3 fd ff ff       	call   800442 <diskaddr>
  80068f:	89 04 24             	mov    %eax,(%esp)
  800692:	e8 35 fe ff ff       	call   8004cc <flush_block>

	// Now repeat the same experiment, but pass an unaligned address to
	// flush_block.

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800697:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80069e:	e8 9f fd ff ff       	call   800442 <diskaddr>
  8006a3:	83 c4 0c             	add    $0xc,%esp
  8006a6:	68 08 01 00 00       	push   $0x108
  8006ab:	50                   	push   %eax
  8006ac:	53                   	push   %ebx
  8006ad:	e8 10 1e 00 00       	call   8024c2 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8006b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006b9:	e8 84 fd ff ff       	call   800442 <diskaddr>
  8006be:	83 c4 08             	add    $0x8,%esp
  8006c1:	68 3e 3c 80 00       	push   $0x803c3e
  8006c6:	50                   	push   %eax
  8006c7:	e8 3e 1c 00 00       	call   80230a <strcpy>

	// Pass an unaligned address to flush_block.
	flush_block(diskaddr(1) + 20);
  8006cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006d3:	e8 6a fd ff ff       	call   800442 <diskaddr>
  8006d8:	83 c0 14             	add    $0x14,%eax
  8006db:	89 04 24             	mov    %eax,(%esp)
  8006de:	e8 e9 fd ff ff       	call   8004cc <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  8006e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006ea:	e8 53 fd ff ff       	call   800442 <diskaddr>
  8006ef:	89 04 24             	mov    %eax,(%esp)
  8006f2:	e8 87 fd ff ff       	call   80047e <va_is_mapped>
  8006f7:	83 c4 10             	add    $0x10,%esp
  8006fa:	84 c0                	test   %al,%al
  8006fc:	0f 84 f6 00 00 00    	je     8007f8 <check_bc+0x27b>
	// Skip the !va_is_dirty() check because it makes the bug somewhat
	// obscure and hence harder to debug.
	// assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800702:	83 ec 0c             	sub    $0xc,%esp
  800705:	6a 01                	push   $0x1
  800707:	e8 36 fd ff ff       	call   800442 <diskaddr>
  80070c:	83 c4 08             	add    $0x8,%esp
  80070f:	50                   	push   %eax
  800710:	6a 00                	push   $0x0
  800712:	e8 cd 20 00 00       	call   8027e4 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800717:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80071e:	e8 1f fd ff ff       	call   800442 <diskaddr>
  800723:	89 04 24             	mov    %eax,(%esp)
  800726:	e8 53 fd ff ff       	call   80047e <va_is_mapped>
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	84 c0                	test   %al,%al
  800730:	0f 85 db 00 00 00    	jne    800811 <check_bc+0x294>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800736:	83 ec 0c             	sub    $0xc,%esp
  800739:	6a 01                	push   $0x1
  80073b:	e8 02 fd ff ff       	call   800442 <diskaddr>
  800740:	83 c4 08             	add    $0x8,%esp
  800743:	68 3e 3c 80 00       	push   $0x803c3e
  800748:	50                   	push   %eax
  800749:	e8 7b 1c 00 00       	call   8023c9 <strcmp>
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	85 c0                	test   %eax,%eax
  800753:	0f 85 d1 00 00 00    	jne    80082a <check_bc+0x2ad>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800759:	83 ec 0c             	sub    $0xc,%esp
  80075c:	6a 01                	push   $0x1
  80075e:	e8 df fc ff ff       	call   800442 <diskaddr>
  800763:	83 c4 0c             	add    $0xc,%esp
  800766:	68 08 01 00 00       	push   $0x108
  80076b:	8d 95 f0 fe ff ff    	lea    -0x110(%ebp),%edx
  800771:	52                   	push   %edx
  800772:	50                   	push   %eax
  800773:	e8 4a 1d 00 00       	call   8024c2 <memmove>
	flush_block(diskaddr(1));
  800778:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80077f:	e8 be fc ff ff       	call   800442 <diskaddr>
  800784:	89 04 24             	mov    %eax,(%esp)
  800787:	e8 40 fd ff ff       	call   8004cc <flush_block>

	cprintf("block cache is good\n");
  80078c:	c7 04 24 7a 3c 80 00 	movl   $0x803c7a,(%esp)
  800793:	e8 08 16 00 00       	call   801da0 <cprintf>
}
  800798:	83 c4 10             	add    $0x10,%esp
  80079b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    
	assert(va_is_mapped(diskaddr(1)));
  8007a0:	68 60 3c 80 00       	push   $0x803c60
  8007a5:	68 bd 3a 80 00       	push   $0x803abd
  8007aa:	6a 70                	push   $0x70
  8007ac:	68 b0 3b 80 00       	push   $0x803bb0
  8007b1:	e8 03 15 00 00       	call   801cb9 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  8007b6:	68 45 3c 80 00       	push   $0x803c45
  8007bb:	68 bd 3a 80 00       	push   $0x803abd
  8007c0:	6a 71                	push   $0x71
  8007c2:	68 b0 3b 80 00       	push   $0x803bb0
  8007c7:	e8 ed 14 00 00       	call   801cb9 <_panic>
	assert(!va_is_mapped(diskaddr(1)));
  8007cc:	68 5f 3c 80 00       	push   $0x803c5f
  8007d1:	68 bd 3a 80 00       	push   $0x803abd
  8007d6:	6a 75                	push   $0x75
  8007d8:	68 b0 3b 80 00       	push   $0x803bb0
  8007dd:	e8 d7 14 00 00       	call   801cb9 <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8007e2:	68 8c 3b 80 00       	push   $0x803b8c
  8007e7:	68 bd 3a 80 00       	push   $0x803abd
  8007ec:	6a 78                	push   $0x78
  8007ee:	68 b0 3b 80 00       	push   $0x803bb0
  8007f3:	e8 c1 14 00 00       	call   801cb9 <_panic>
	assert(va_is_mapped(diskaddr(1)));
  8007f8:	68 60 3c 80 00       	push   $0x803c60
  8007fd:	68 bd 3a 80 00       	push   $0x803abd
  800802:	68 89 00 00 00       	push   $0x89
  800807:	68 b0 3b 80 00       	push   $0x803bb0
  80080c:	e8 a8 14 00 00       	call   801cb9 <_panic>
	assert(!va_is_mapped(diskaddr(1)));
  800811:	68 5f 3c 80 00       	push   $0x803c5f
  800816:	68 bd 3a 80 00       	push   $0x803abd
  80081b:	68 91 00 00 00       	push   $0x91
  800820:	68 b0 3b 80 00       	push   $0x803bb0
  800825:	e8 8f 14 00 00       	call   801cb9 <_panic>
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  80082a:	68 8c 3b 80 00       	push   $0x803b8c
  80082f:	68 bd 3a 80 00       	push   $0x803abd
  800834:	68 94 00 00 00       	push   $0x94
  800839:	68 b0 3b 80 00       	push   $0x803bb0
  80083e:	e8 76 14 00 00       	call   801cb9 <_panic>

00800843 <bc_init>:

void
bc_init(void)
{
  800843:	f3 0f 1e fb          	endbr32 
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	81 ec 24 01 00 00    	sub    $0x124,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  800850:	68 1a 03 80 00       	push   $0x80031a
  800855:	e8 75 20 00 00       	call   8028cf <set_pgfault_handler>
	check_bc();
  80085a:	e8 1e fd ff ff       	call   80057d <check_bc>

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  80085f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800866:	e8 d7 fb ff ff       	call   800442 <diskaddr>
  80086b:	83 c4 0c             	add    $0xc,%esp
  80086e:	68 08 01 00 00       	push   $0x108
  800873:	50                   	push   %eax
  800874:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80087a:	50                   	push   %eax
  80087b:	e8 42 1c 00 00       	call   8024c2 <memmove>
}
  800880:	83 c4 10             	add    $0x10,%esp
  800883:	c9                   	leave  
  800884:	c3                   	ret    

00800885 <skip_slash>:

// Skip over slashes.
static const char *
skip_slash(const char *p)
{
	while (*p == '/')
  800885:	80 38 2f             	cmpb   $0x2f,(%eax)
  800888:	75 05                	jne    80088f <skip_slash+0xa>
		p++;
  80088a:	83 c0 01             	add    $0x1,%eax
  80088d:	eb f6                	jmp    800885 <skip_slash>
	return p;
}
  80088f:	c3                   	ret    

00800890 <check_super>:
{
  800890:	f3 0f 1e fb          	endbr32 
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  80089a:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80089f:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8008a5:	75 1b                	jne    8008c2 <check_super+0x32>
	if (super->s_nblocks > DISKSIZE / BLKSIZE)
  8008a7:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8008ae:	77 26                	ja     8008d6 <check_super+0x46>
	cprintf("superblock is good\n");
  8008b0:	83 ec 0c             	sub    $0xc,%esp
  8008b3:	68 cd 3c 80 00       	push   $0x803ccd
  8008b8:	e8 e3 14 00 00       	call   801da0 <cprintf>
}
  8008bd:	83 c4 10             	add    $0x10,%esp
  8008c0:	c9                   	leave  
  8008c1:	c3                   	ret    
		panic("bad file system magic number");
  8008c2:	83 ec 04             	sub    $0x4,%esp
  8008c5:	68 8f 3c 80 00       	push   $0x803c8f
  8008ca:	6a 12                	push   $0x12
  8008cc:	68 ac 3c 80 00       	push   $0x803cac
  8008d1:	e8 e3 13 00 00       	call   801cb9 <_panic>
		panic("file system is too large");
  8008d6:	83 ec 04             	sub    $0x4,%esp
  8008d9:	68 b4 3c 80 00       	push   $0x803cb4
  8008de:	6a 15                	push   $0x15
  8008e0:	68 ac 3c 80 00       	push   $0x803cac
  8008e5:	e8 cf 13 00 00       	call   801cb9 <_panic>

008008ea <block_is_free>:
{
  8008ea:	f3 0f 1e fb          	endbr32 
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	53                   	push   %ebx
  8008f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8008f5:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8008fa:	85 c0                	test   %eax,%eax
  8008fc:	74 27                	je     800925 <block_is_free+0x3b>
		return 0;
  8008fe:	ba 00 00 00 00       	mov    $0x0,%edx
	if (super == 0 || blockno >= super->s_nblocks)
  800903:	39 48 04             	cmp    %ecx,0x4(%eax)
  800906:	76 18                	jbe    800920 <block_is_free+0x36>
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  800908:	89 cb                	mov    %ecx,%ebx
  80090a:	c1 eb 05             	shr    $0x5,%ebx
  80090d:	b8 01 00 00 00       	mov    $0x1,%eax
  800912:	d3 e0                	shl    %cl,%eax
  800914:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  80091a:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  80091d:	0f 95 c2             	setne  %dl
}
  800920:	89 d0                	mov    %edx,%eax
  800922:	5b                   	pop    %ebx
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    
		return 0;
  800925:	ba 00 00 00 00       	mov    $0x0,%edx
  80092a:	eb f4                	jmp    800920 <block_is_free+0x36>

0080092c <free_block>:
{
  80092c:	f3 0f 1e fb          	endbr32 
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	53                   	push   %ebx
  800934:	83 ec 04             	sub    $0x4,%esp
  800937:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (blockno == 0)
  80093a:	85 c9                	test   %ecx,%ecx
  80093c:	74 1a                	je     800958 <free_block+0x2c>
	bitmap[blockno / 32] |= 1 << (blockno % 32);
  80093e:	89 cb                	mov    %ecx,%ebx
  800940:	c1 eb 05             	shr    $0x5,%ebx
  800943:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800949:	b8 01 00 00 00       	mov    $0x1,%eax
  80094e:	d3 e0                	shl    %cl,%eax
  800950:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800953:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800956:	c9                   	leave  
  800957:	c3                   	ret    
		panic("attempt to free zero block");
  800958:	83 ec 04             	sub    $0x4,%esp
  80095b:	68 e1 3c 80 00       	push   $0x803ce1
  800960:	6a 30                	push   $0x30
  800962:	68 ac 3c 80 00       	push   $0x803cac
  800967:	e8 4d 13 00 00       	call   801cb9 <_panic>

0080096c <alloc_block>:
{
  80096c:	f3 0f 1e fb          	endbr32 
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	57                   	push   %edi
  800974:	56                   	push   %esi
  800975:	53                   	push   %ebx
  800976:	83 ec 0c             	sub    $0xc,%esp
	for (int i = 0; i < super->s_nblocks; i++) {
  800979:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80097e:	8b 70 04             	mov    0x4(%eax),%esi
  800981:	bb 00 00 00 00       	mov    $0x0,%ebx
  800986:	89 df                	mov    %ebx,%edi
  800988:	39 f3                	cmp    %esi,%ebx
  80098a:	74 56                	je     8009e2 <alloc_block+0x76>
		if (block_is_free(i)) {
  80098c:	83 ec 0c             	sub    $0xc,%esp
  80098f:	53                   	push   %ebx
  800990:	e8 55 ff ff ff       	call   8008ea <block_is_free>
  800995:	83 c4 10             	add    $0x10,%esp
  800998:	84 c0                	test   %al,%al
  80099a:	75 05                	jne    8009a1 <alloc_block+0x35>
	for (int i = 0; i < super->s_nblocks; i++) {
  80099c:	83 c3 01             	add    $0x1,%ebx
  80099f:	eb e5                	jmp    800986 <alloc_block+0x1a>
			bitmap[i / 32] &= ~(1 << (i % 32));
  8009a1:	8d 43 1f             	lea    0x1f(%ebx),%eax
  8009a4:	85 db                	test   %ebx,%ebx
  8009a6:	0f 49 c3             	cmovns %ebx,%eax
  8009a9:	c1 f8 05             	sar    $0x5,%eax
  8009ac:	8b 35 04 a0 80 00    	mov    0x80a004,%esi
  8009b2:	89 da                	mov    %ebx,%edx
  8009b4:	c1 fa 1f             	sar    $0x1f,%edx
  8009b7:	c1 ea 1b             	shr    $0x1b,%edx
  8009ba:	8d 0c 13             	lea    (%ebx,%edx,1),%ecx
  8009bd:	83 e1 1f             	and    $0x1f,%ecx
  8009c0:	29 d1                	sub    %edx,%ecx
  8009c2:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
  8009c7:	d3 c2                	rol    %cl,%edx
  8009c9:	21 14 86             	and    %edx,(%esi,%eax,4)
			flush_block(diskaddr(i));
  8009cc:	83 ec 0c             	sub    $0xc,%esp
  8009cf:	57                   	push   %edi
  8009d0:	e8 6d fa ff ff       	call   800442 <diskaddr>
  8009d5:	89 04 24             	mov    %eax,(%esp)
  8009d8:	e8 ef fa ff ff       	call   8004cc <flush_block>
			return i;
  8009dd:	83 c4 10             	add    $0x10,%esp
  8009e0:	eb 05                	jmp    8009e7 <alloc_block+0x7b>
	return -E_NO_DISK;
  8009e2:	bb f7 ff ff ff       	mov    $0xfffffff7,%ebx
}
  8009e7:	89 d8                	mov    %ebx,%eax
  8009e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009ec:	5b                   	pop    %ebx
  8009ed:	5e                   	pop    %esi
  8009ee:	5f                   	pop    %edi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <file_block_walk>:
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	57                   	push   %edi
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	83 ec 0c             	sub    $0xc,%esp
  8009fa:	89 c6                	mov    %eax,%esi
  8009fc:	89 d3                	mov    %edx,%ebx
  8009fe:	89 cf                	mov    %ecx,%edi
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
	if (filebno < NDIRECT) {
  800a03:	83 fa 09             	cmp    $0x9,%edx
  800a06:	76 7f                	jbe    800a87 <file_block_walk+0x96>
	if (filebno < NDIRECT + NINDIRECT) {
  800a08:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  800a0e:	0f 87 83 00 00 00    	ja     800a97 <file_block_walk+0xa6>
		if (f->f_indirect == 0) {
  800a14:	83 be b0 00 00 00 00 	cmpl   $0x0,0xb0(%esi)
  800a1b:	75 46                	jne    800a63 <file_block_walk+0x72>
			if (!alloc) {
  800a1d:	84 c0                	test   %al,%al
  800a1f:	74 7d                	je     800a9e <file_block_walk+0xad>
			f->f_indirect = alloc_block();
  800a21:	e8 46 ff ff ff       	call   80096c <alloc_block>
  800a26:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
			if (f->f_indirect == -E_NO_DISK) {
  800a2c:	83 f8 f7             	cmp    $0xfffffff7,%eax
  800a2f:	74 74                	je     800aa5 <file_block_walk+0xb4>
			memset(diskaddr(f->f_indirect), 0, BLKSIZE);
  800a31:	83 ec 0c             	sub    $0xc,%esp
  800a34:	50                   	push   %eax
  800a35:	e8 08 fa ff ff       	call   800442 <diskaddr>
  800a3a:	83 c4 0c             	add    $0xc,%esp
  800a3d:	68 00 10 00 00       	push   $0x1000
  800a42:	6a 00                	push   $0x0
  800a44:	50                   	push   %eax
  800a45:	e8 2a 1a 00 00       	call   802474 <memset>
			flush_block(diskaddr(f->f_indirect));
  800a4a:	83 c4 04             	add    $0x4,%esp
  800a4d:	ff b6 b0 00 00 00    	pushl  0xb0(%esi)
  800a53:	e8 ea f9 ff ff       	call   800442 <diskaddr>
  800a58:	89 04 24             	mov    %eax,(%esp)
  800a5b:	e8 6c fa ff ff       	call   8004cc <flush_block>
  800a60:	83 c4 10             	add    $0x10,%esp
		uint32_t *indirect_block_address = diskaddr(f->f_indirect);
  800a63:	83 ec 0c             	sub    $0xc,%esp
  800a66:	ff b6 b0 00 00 00    	pushl  0xb0(%esi)
  800a6c:	e8 d1 f9 ff ff       	call   800442 <diskaddr>
		*ppdiskbno = &(indirect_block_address[filebno - NDIRECT]);
  800a71:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800a75:	89 07                	mov    %eax,(%edi)
		return 0;
  800a77:	83 c4 10             	add    $0x10,%esp
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    
		*ppdiskbno = &f->f_direct[filebno];
  800a87:	8d 84 96 88 00 00 00 	lea    0x88(%esi,%edx,4),%eax
  800a8e:	89 01                	mov    %eax,(%ecx)
		return 0;
  800a90:	b8 00 00 00 00       	mov    $0x0,%eax
  800a95:	eb e8                	jmp    800a7f <file_block_walk+0x8e>
	return -E_INVAL;
  800a97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a9c:	eb e1                	jmp    800a7f <file_block_walk+0x8e>
				return -E_NOT_FOUND;
  800a9e:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800aa3:	eb da                	jmp    800a7f <file_block_walk+0x8e>
				return -E_NO_DISK;
  800aa5:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  800aaa:	eb d3                	jmp    800a7f <file_block_walk+0x8e>

00800aac <file_free_block>:

// Remove a block from file f.  If it's not there, just silently succeed.
// Returns 0 on success, < 0 on error.
static int
file_free_block(struct File *f, uint32_t filebno)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	83 ec 24             	sub    $0x24,%esp
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800ab2:	6a 00                	push   $0x0
  800ab4:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800ab7:	e8 35 ff ff ff       	call   8009f1 <file_block_walk>
  800abc:	83 c4 10             	add    $0x10,%esp
  800abf:	85 c0                	test   %eax,%eax
  800ac1:	78 0e                	js     800ad1 <file_free_block+0x25>
		return r;
	if (*ptr) {
  800ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ac6:	8b 10                	mov    (%eax),%edx
		free_block(*ptr);
		*ptr = 0;
	}
	return 0;
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (*ptr) {
  800acd:	85 d2                	test   %edx,%edx
  800acf:	75 02                	jne    800ad3 <file_free_block+0x27>
}
  800ad1:	c9                   	leave  
  800ad2:	c3                   	ret    
		free_block(*ptr);
  800ad3:	83 ec 0c             	sub    $0xc,%esp
  800ad6:	52                   	push   %edx
  800ad7:	e8 50 fe ff ff       	call   80092c <free_block>
		*ptr = 0;
  800adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800adf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800ae5:	83 c4 10             	add    $0x10,%esp
	return 0;
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  800aed:	eb e2                	jmp    800ad1 <file_free_block+0x25>

00800aef <file_truncate_blocks>:
// (Remember to clear the f->f_indirect pointer so you'll know
// whether it's valid!)
// Do not change f->f_size.
static void
file_truncate_blocks(struct File *f, off_t newsize)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
  800af5:	83 ec 1c             	sub    $0x1c,%esp
  800af8:	89 c7                	mov    %eax,%edi
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800afa:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800b00:	8d b0 fe 1f 00 00    	lea    0x1ffe(%eax),%esi
  800b06:	05 ff 0f 00 00       	add    $0xfff,%eax
  800b0b:	0f 49 f0             	cmovns %eax,%esi
  800b0e:	c1 fe 0c             	sar    $0xc,%esi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800b11:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800b17:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800b1d:	0f 48 d0             	cmovs  %eax,%edx
  800b20:	c1 fa 0c             	sar    $0xc,%edx
  800b23:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800b26:	89 d3                	mov    %edx,%ebx
  800b28:	eb 03                	jmp    800b2d <file_truncate_blocks+0x3e>
  800b2a:	83 c3 01             	add    $0x1,%ebx
  800b2d:	39 f3                	cmp    %esi,%ebx
  800b2f:	73 20                	jae    800b51 <file_truncate_blocks+0x62>
		if ((r = file_free_block(f, bno)) < 0)
  800b31:	89 da                	mov    %ebx,%edx
  800b33:	89 f8                	mov    %edi,%eax
  800b35:	e8 72 ff ff ff       	call   800aac <file_free_block>
  800b3a:	85 c0                	test   %eax,%eax
  800b3c:	79 ec                	jns    800b2a <file_truncate_blocks+0x3b>
			cprintf("warning: file_free_block: %e", r);
  800b3e:	83 ec 08             	sub    $0x8,%esp
  800b41:	50                   	push   %eax
  800b42:	68 fc 3c 80 00       	push   $0x803cfc
  800b47:	e8 54 12 00 00       	call   801da0 <cprintf>
  800b4c:	83 c4 10             	add    $0x10,%esp
  800b4f:	eb d9                	jmp    800b2a <file_truncate_blocks+0x3b>

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800b51:	83 7d e4 0a          	cmpl   $0xa,-0x1c(%ebp)
  800b55:	77 0a                	ja     800b61 <file_truncate_blocks+0x72>
  800b57:	8b 87 b0 00 00 00    	mov    0xb0(%edi),%eax
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	75 08                	jne    800b69 <file_truncate_blocks+0x7a>
		free_block(f->f_indirect);
		f->f_indirect = 0;
	}
}
  800b61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    
		free_block(f->f_indirect);
  800b69:	83 ec 0c             	sub    $0xc,%esp
  800b6c:	50                   	push   %eax
  800b6d:	e8 ba fd ff ff       	call   80092c <free_block>
		f->f_indirect = 0;
  800b72:	c7 87 b0 00 00 00 00 	movl   $0x0,0xb0(%edi)
  800b79:	00 00 00 
  800b7c:	83 c4 10             	add    $0x10,%esp
}
  800b7f:	eb e0                	jmp    800b61 <file_truncate_blocks+0x72>

00800b81 <check_bitmap>:
{
  800b81:	f3 0f 1e fb          	endbr32 
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800b8a:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800b8f:	8b 70 04             	mov    0x4(%eax),%esi
  800b92:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b97:	89 d8                	mov    %ebx,%eax
  800b99:	c1 e0 0f             	shl    $0xf,%eax
  800b9c:	39 c6                	cmp    %eax,%esi
  800b9e:	76 2e                	jbe    800bce <check_bitmap+0x4d>
		assert(!block_is_free(2 + i));
  800ba0:	83 ec 0c             	sub    $0xc,%esp
  800ba3:	8d 43 02             	lea    0x2(%ebx),%eax
  800ba6:	50                   	push   %eax
  800ba7:	e8 3e fd ff ff       	call   8008ea <block_is_free>
  800bac:	83 c4 10             	add    $0x10,%esp
  800baf:	84 c0                	test   %al,%al
  800bb1:	75 05                	jne    800bb8 <check_bitmap+0x37>
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800bb3:	83 c3 01             	add    $0x1,%ebx
  800bb6:	eb df                	jmp    800b97 <check_bitmap+0x16>
		assert(!block_is_free(2 + i));
  800bb8:	68 19 3d 80 00       	push   $0x803d19
  800bbd:	68 bd 3a 80 00       	push   $0x803abd
  800bc2:	6a 59                	push   $0x59
  800bc4:	68 ac 3c 80 00       	push   $0x803cac
  800bc9:	e8 eb 10 00 00       	call   801cb9 <_panic>
	assert(!block_is_free(0));
  800bce:	83 ec 0c             	sub    $0xc,%esp
  800bd1:	6a 00                	push   $0x0
  800bd3:	e8 12 fd ff ff       	call   8008ea <block_is_free>
  800bd8:	83 c4 10             	add    $0x10,%esp
  800bdb:	84 c0                	test   %al,%al
  800bdd:	75 28                	jne    800c07 <check_bitmap+0x86>
	assert(!block_is_free(1));
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	6a 01                	push   $0x1
  800be4:	e8 01 fd ff ff       	call   8008ea <block_is_free>
  800be9:	83 c4 10             	add    $0x10,%esp
  800bec:	84 c0                	test   %al,%al
  800bee:	75 2d                	jne    800c1d <check_bitmap+0x9c>
	cprintf("bitmap is good\n");
  800bf0:	83 ec 0c             	sub    $0xc,%esp
  800bf3:	68 53 3d 80 00       	push   $0x803d53
  800bf8:	e8 a3 11 00 00       	call   801da0 <cprintf>
}
  800bfd:	83 c4 10             	add    $0x10,%esp
  800c00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    
	assert(!block_is_free(0));
  800c07:	68 2f 3d 80 00       	push   $0x803d2f
  800c0c:	68 bd 3a 80 00       	push   $0x803abd
  800c11:	6a 5c                	push   $0x5c
  800c13:	68 ac 3c 80 00       	push   $0x803cac
  800c18:	e8 9c 10 00 00       	call   801cb9 <_panic>
	assert(!block_is_free(1));
  800c1d:	68 41 3d 80 00       	push   $0x803d41
  800c22:	68 bd 3a 80 00       	push   $0x803abd
  800c27:	6a 5d                	push   $0x5d
  800c29:	68 ac 3c 80 00       	push   $0x803cac
  800c2e:	e8 86 10 00 00       	call   801cb9 <_panic>

00800c33 <fs_init>:
{
  800c33:	f3 0f 1e fb          	endbr32 
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	83 ec 08             	sub    $0x8,%esp
	if (ide_probe_disk1())
  800c3d:	e8 51 f4 ff ff       	call   800093 <ide_probe_disk1>
  800c42:	84 c0                	test   %al,%al
  800c44:	74 41                	je     800c87 <fs_init+0x54>
		ide_set_disk(1);
  800c46:	83 ec 0c             	sub    $0xc,%esp
  800c49:	6a 01                	push   $0x1
  800c4b:	e8 b5 f4 ff ff       	call   800105 <ide_set_disk>
  800c50:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800c53:	e8 eb fb ff ff       	call   800843 <bc_init>
	super = diskaddr(1);
  800c58:	83 ec 0c             	sub    $0xc,%esp
  800c5b:	6a 01                	push   $0x1
  800c5d:	e8 e0 f7 ff ff       	call   800442 <diskaddr>
  800c62:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800c67:	e8 24 fc ff ff       	call   800890 <check_super>
	bitmap = diskaddr(2);
  800c6c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800c73:	e8 ca f7 ff ff       	call   800442 <diskaddr>
  800c78:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  800c7d:	e8 ff fe ff ff       	call   800b81 <check_bitmap>
}
  800c82:	83 c4 10             	add    $0x10,%esp
  800c85:	c9                   	leave  
  800c86:	c3                   	ret    
		ide_set_disk(0);
  800c87:	83 ec 0c             	sub    $0xc,%esp
  800c8a:	6a 00                	push   $0x0
  800c8c:	e8 74 f4 ff ff       	call   800105 <ide_set_disk>
  800c91:	83 c4 10             	add    $0x10,%esp
  800c94:	eb bd                	jmp    800c53 <fs_init+0x20>

00800c96 <file_get_block>:
{
  800c96:	f3 0f 1e fb          	endbr32 
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	83 ec 24             	sub    $0x24,%esp
	if ((r = file_block_walk(f, filebno, &pdiskbno, true)) < 0)
  800ca0:	6a 01                	push   $0x1
  800ca2:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800ca5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cab:	e8 41 fd ff ff       	call   8009f1 <file_block_walk>
  800cb0:	83 c4 10             	add    $0x10,%esp
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	78 67                	js     800d1e <file_get_block+0x88>
	if (*pdiskbno == 0) {
  800cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cba:	83 38 00             	cmpl   $0x0,(%eax)
  800cbd:	75 45                	jne    800d04 <file_get_block+0x6e>
		*pdiskbno = alloc_block();
  800cbf:	e8 a8 fc ff ff       	call   80096c <alloc_block>
  800cc4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cc7:	89 02                	mov    %eax,(%edx)
		if (*pdiskbno == -E_NO_DISK) {
  800cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ccc:	8b 00                	mov    (%eax),%eax
  800cce:	83 f8 f7             	cmp    $0xfffffff7,%eax
  800cd1:	74 4d                	je     800d20 <file_get_block+0x8a>
		memset(diskaddr(*pdiskbno), 0, BLKSIZE);
  800cd3:	83 ec 0c             	sub    $0xc,%esp
  800cd6:	50                   	push   %eax
  800cd7:	e8 66 f7 ff ff       	call   800442 <diskaddr>
  800cdc:	83 c4 0c             	add    $0xc,%esp
  800cdf:	68 00 10 00 00       	push   $0x1000
  800ce4:	6a 00                	push   $0x0
  800ce6:	50                   	push   %eax
  800ce7:	e8 88 17 00 00       	call   802474 <memset>
		flush_block(diskaddr(*pdiskbno));
  800cec:	83 c4 04             	add    $0x4,%esp
  800cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf2:	ff 30                	pushl  (%eax)
  800cf4:	e8 49 f7 ff ff       	call   800442 <diskaddr>
  800cf9:	89 04 24             	mov    %eax,(%esp)
  800cfc:	e8 cb f7 ff ff       	call   8004cc <flush_block>
  800d01:	83 c4 10             	add    $0x10,%esp
	*blk = diskaddr(*pdiskbno);
  800d04:	83 ec 0c             	sub    $0xc,%esp
  800d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d0a:	ff 30                	pushl  (%eax)
  800d0c:	e8 31 f7 ff ff       	call   800442 <diskaddr>
  800d11:	8b 55 10             	mov    0x10(%ebp),%edx
  800d14:	89 02                	mov    %eax,(%edx)
	return 0;
  800d16:	83 c4 10             	add    $0x10,%esp
  800d19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d1e:	c9                   	leave  
  800d1f:	c3                   	ret    
			return -E_NO_DISK;
  800d20:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  800d25:	eb f7                	jmp    800d1e <file_get_block+0x88>

00800d27 <dir_lookup>:
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 3c             	sub    $0x3c,%esp
  800d30:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800d33:	89 d6                	mov    %edx,%esi
  800d35:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
	assert((dir->f_size % BLKSIZE) == 0);
  800d38:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800d3e:	89 c2                	mov    %eax,%edx
  800d40:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  800d46:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800d49:	75 5f                	jne    800daa <dir_lookup+0x83>
	nblock = dir->f_size / BLKSIZE;
  800d4b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800d51:	85 c0                	test   %eax,%eax
  800d53:	0f 48 c2             	cmovs  %edx,%eax
  800d56:	c1 f8 0c             	sar    $0xc,%eax
  800d59:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (i = 0; i < nblock; i++) {
  800d5c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800d5f:	39 4d d0             	cmp    %ecx,-0x30(%ebp)
  800d62:	74 6f                	je     800dd3 <dir_lookup+0xac>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800d64:	83 ec 04             	sub    $0x4,%esp
  800d67:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d6a:	50                   	push   %eax
  800d6b:	ff 75 d0             	pushl  -0x30(%ebp)
  800d6e:	ff 75 c8             	pushl  -0x38(%ebp)
  800d71:	e8 20 ff ff ff       	call   800c96 <file_get_block>
  800d76:	83 c4 10             	add    $0x10,%esp
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	78 4e                	js     800dcb <dir_lookup+0xa4>
  800d7d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800d80:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
			if (strcmp(f[j].f_name, name) == 0) {
  800d86:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800d89:	83 ec 08             	sub    $0x8,%esp
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
  800d8e:	e8 36 16 00 00       	call   8023c9 <strcmp>
  800d93:	83 c4 10             	add    $0x10,%esp
  800d96:	85 c0                	test   %eax,%eax
  800d98:	74 29                	je     800dc3 <dir_lookup+0x9c>
  800d9a:	81 c3 00 01 00 00    	add    $0x100,%ebx
		for (j = 0; j < BLKFILES; j++)
  800da0:	39 fb                	cmp    %edi,%ebx
  800da2:	75 e2                	jne    800d86 <dir_lookup+0x5f>
	for (i = 0; i < nblock; i++) {
  800da4:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
  800da8:	eb b2                	jmp    800d5c <dir_lookup+0x35>
	assert((dir->f_size % BLKSIZE) == 0);
  800daa:	68 63 3d 80 00       	push   $0x803d63
  800daf:	68 bd 3a 80 00       	push   $0x803abd
  800db4:	68 dc 00 00 00       	push   $0xdc
  800db9:	68 ac 3c 80 00       	push   $0x803cac
  800dbe:	e8 f6 0e 00 00       	call   801cb9 <_panic>
				*file = &f[j];
  800dc3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800dc6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800dc9:	89 11                	mov    %edx,(%ecx)
}
  800dcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    
	return -E_NOT_FOUND;
  800dd3:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800dd8:	eb f1                	jmp    800dcb <dir_lookup+0xa4>

00800dda <walk_path>:
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	57                   	push   %edi
  800dde:	56                   	push   %esi
  800ddf:	53                   	push   %ebx
  800de0:	81 ec ac 00 00 00    	sub    $0xac,%esp
  800de6:	89 d7                	mov    %edx,%edi
  800de8:	89 95 4c ff ff ff    	mov    %edx,-0xb4(%ebp)
  800dee:	89 8d 50 ff ff ff    	mov    %ecx,-0xb0(%ebp)
	path = skip_slash(path);
  800df4:	e8 8c fa ff ff       	call   800885 <skip_slash>
  800df9:	89 c6                	mov    %eax,%esi
	f = &super->s_root;
  800dfb:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800e00:	83 c0 08             	add    $0x8,%eax
  800e03:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
	name[0] = 0;
  800e09:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)
	if (pdir)
  800e10:	85 ff                	test   %edi,%edi
  800e12:	74 06                	je     800e1a <walk_path+0x40>
		*pdir = 0;
  800e14:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	*pf = 0;
  800e1a:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800e20:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	dir = 0;
  800e26:	c7 85 54 ff ff ff 00 	movl   $0x0,-0xac(%ebp)
  800e2d:	00 00 00 
	while (*path != '\0') {
  800e30:	eb 68                	jmp    800e9a <walk_path+0xc0>
			path++;
  800e32:	83 c3 01             	add    $0x1,%ebx
		while (*path != '/' && *path != '\0')
  800e35:	0f b6 03             	movzbl (%ebx),%eax
  800e38:	3c 2f                	cmp    $0x2f,%al
  800e3a:	74 04                	je     800e40 <walk_path+0x66>
  800e3c:	84 c0                	test   %al,%al
  800e3e:	75 f2                	jne    800e32 <walk_path+0x58>
		if (path - p >= MAXNAMELEN)
  800e40:	89 df                	mov    %ebx,%edi
  800e42:	29 f7                	sub    %esi,%edi
  800e44:	83 ff 7f             	cmp    $0x7f,%edi
  800e47:	0f 8f d8 00 00 00    	jg     800f25 <walk_path+0x14b>
		memmove(name, p, path - p);
  800e4d:	83 ec 04             	sub    $0x4,%esp
  800e50:	57                   	push   %edi
  800e51:	56                   	push   %esi
  800e52:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800e58:	50                   	push   %eax
  800e59:	e8 64 16 00 00       	call   8024c2 <memmove>
		name[path - p] = '\0';
  800e5e:	c6 84 3d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%edi,1)
  800e65:	00 
		path = skip_slash(path);
  800e66:	89 d8                	mov    %ebx,%eax
  800e68:	e8 18 fa ff ff       	call   800885 <skip_slash>
  800e6d:	89 c6                	mov    %eax,%esi
		if (dir->f_type != FTYPE_DIR)
  800e6f:	83 c4 10             	add    $0x10,%esp
  800e72:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800e78:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800e7f:	0f 85 a7 00 00 00    	jne    800f2c <walk_path+0x152>
		if ((r = dir_lookup(dir, name, &f)) < 0) {
  800e85:	8d 8d 64 ff ff ff    	lea    -0x9c(%ebp),%ecx
  800e8b:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  800e91:	e8 91 fe ff ff       	call   800d27 <dir_lookup>
  800e96:	85 c0                	test   %eax,%eax
  800e98:	78 15                	js     800eaf <walk_path+0xd5>
	while (*path != '\0') {
  800e9a:	80 3e 00             	cmpb   $0x0,(%esi)
  800e9d:	74 57                	je     800ef6 <walk_path+0x11c>
		dir = f;
  800e9f:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  800ea5:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
		while (*path != '/' && *path != '\0')
  800eab:	89 f3                	mov    %esi,%ebx
  800ead:	eb 86                	jmp    800e35 <walk_path+0x5b>
  800eaf:	89 c3                	mov    %eax,%ebx
			if (r == -E_NOT_FOUND && *path == '\0') {
  800eb1:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800eb4:	75 65                	jne    800f1b <walk_path+0x141>
  800eb6:	80 3e 00             	cmpb   $0x0,(%esi)
  800eb9:	75 60                	jne    800f1b <walk_path+0x141>
				if (pdir)
  800ebb:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	74 08                	je     800ecd <walk_path+0xf3>
					*pdir = dir;
  800ec5:	8b 8d 54 ff ff ff    	mov    -0xac(%ebp),%ecx
  800ecb:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800ecd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800ed1:	74 15                	je     800ee8 <walk_path+0x10e>
					strcpy(lastelem, name);
  800ed3:	83 ec 08             	sub    $0x8,%esp
  800ed6:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800edc:	50                   	push   %eax
  800edd:	ff 75 08             	pushl  0x8(%ebp)
  800ee0:	e8 25 14 00 00       	call   80230a <strcpy>
  800ee5:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800ee8:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800eee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800ef4:	eb 25                	jmp    800f1b <walk_path+0x141>
	if (pdir)
  800ef6:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800efc:	85 c0                	test   %eax,%eax
  800efe:	74 08                	je     800f08 <walk_path+0x12e>
		*pdir = dir;
  800f00:	8b 8d 54 ff ff ff    	mov    -0xac(%ebp),%ecx
  800f06:	89 08                	mov    %ecx,(%eax)
	*pf = f;
  800f08:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  800f0e:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  800f14:	89 02                	mov    %eax,(%edx)
	return 0;
  800f16:	bb 00 00 00 00       	mov    $0x0,%ebx
}
  800f1b:	89 d8                	mov    %ebx,%eax
  800f1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f20:	5b                   	pop    %ebx
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    
			return -E_BAD_PATH;
  800f25:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800f2a:	eb ef                	jmp    800f1b <walk_path+0x141>
			return -E_NOT_FOUND;
  800f2c:	bb f5 ff ff ff       	mov    $0xfffffff5,%ebx
  800f31:	eb e8                	jmp    800f1b <walk_path+0x141>

00800f33 <dir_alloc_file>:
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	57                   	push   %edi
  800f37:	56                   	push   %esi
  800f38:	53                   	push   %ebx
  800f39:	83 ec 2c             	sub    $0x2c,%esp
  800f3c:	89 c6                	mov    %eax,%esi
  800f3e:	89 55 d0             	mov    %edx,-0x30(%ebp)
	assert((dir->f_size % BLKSIZE) == 0);
  800f41:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800f47:	89 c3                	mov    %eax,%ebx
  800f49:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
  800f4f:	75 4c                	jne    800f9d <dir_alloc_file+0x6a>
	nblock = dir->f_size / BLKSIZE;
  800f51:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800f57:	85 c0                	test   %eax,%eax
  800f59:	0f 48 c2             	cmovs  %edx,%eax
  800f5c:	c1 f8 0c             	sar    $0xc,%eax
  800f5f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800f62:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800f65:	8d 7d e4             	lea    -0x1c(%ebp),%edi
	for (i = 0; i < nblock; i++) {
  800f68:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
  800f6b:	74 5b                	je     800fc8 <dir_alloc_file+0x95>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800f6d:	83 ec 04             	sub    $0x4,%esp
  800f70:	57                   	push   %edi
  800f71:	53                   	push   %ebx
  800f72:	56                   	push   %esi
  800f73:	e8 1e fd ff ff       	call   800c96 <file_get_block>
  800f78:	83 c4 10             	add    $0x10,%esp
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	78 41                	js     800fc0 <dir_alloc_file+0x8d>
  800f7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f82:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
			if (f[j].f_name[0] == '\0') {
  800f88:	89 c1                	mov    %eax,%ecx
  800f8a:	80 38 00             	cmpb   $0x0,(%eax)
  800f8d:	74 27                	je     800fb6 <dir_alloc_file+0x83>
  800f8f:	05 00 01 00 00       	add    $0x100,%eax
		for (j = 0; j < BLKFILES; j++)
  800f94:	39 d0                	cmp    %edx,%eax
  800f96:	75 f0                	jne    800f88 <dir_alloc_file+0x55>
	for (i = 0; i < nblock; i++) {
  800f98:	83 c3 01             	add    $0x1,%ebx
  800f9b:	eb cb                	jmp    800f68 <dir_alloc_file+0x35>
	assert((dir->f_size % BLKSIZE) == 0);
  800f9d:	68 63 3d 80 00       	push   $0x803d63
  800fa2:	68 bd 3a 80 00       	push   $0x803abd
  800fa7:	68 f5 00 00 00       	push   $0xf5
  800fac:	68 ac 3c 80 00       	push   $0x803cac
  800fb1:	e8 03 0d 00 00       	call   801cb9 <_panic>
				*file = &f[j];
  800fb6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800fb9:	89 08                	mov    %ecx,(%eax)
				return 0;
  800fbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc3:	5b                   	pop    %ebx
  800fc4:	5e                   	pop    %esi
  800fc5:	5f                   	pop    %edi
  800fc6:	5d                   	pop    %ebp
  800fc7:	c3                   	ret    
	dir->f_size += BLKSIZE;
  800fc8:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  800fcf:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  800fd2:	83 ec 04             	sub    $0x4,%esp
  800fd5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fd8:	50                   	push   %eax
  800fd9:	ff 75 cc             	pushl  -0x34(%ebp)
  800fdc:	56                   	push   %esi
  800fdd:	e8 b4 fc ff ff       	call   800c96 <file_get_block>
  800fe2:	83 c4 10             	add    $0x10,%esp
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	78 d7                	js     800fc0 <dir_alloc_file+0x8d>
	*file = &f[0];
  800fe9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fec:	8b 7d d0             	mov    -0x30(%ebp),%edi
  800fef:	89 07                	mov    %eax,(%edi)
	return 0;
  800ff1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff6:	eb c8                	jmp    800fc0 <dir_alloc_file+0x8d>

00800ff8 <file_open>:
{
  800ff8:	f3 0f 1e fb          	endbr32 
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  801002:	6a 00                	push   $0x0
  801004:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801007:	ba 00 00 00 00       	mov    $0x0,%edx
  80100c:	8b 45 08             	mov    0x8(%ebp),%eax
  80100f:	e8 c6 fd ff ff       	call   800dda <walk_path>
}
  801014:	c9                   	leave  
  801015:	c3                   	ret    

00801016 <file_read>:
{
  801016:	f3 0f 1e fb          	endbr32 
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	57                   	push   %edi
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
  801020:	83 ec 2c             	sub    $0x2c,%esp
  801023:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801026:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801029:	8b 4d 14             	mov    0x14(%ebp),%ecx
	if (offset >= f->f_size)
  80102c:	8b 45 08             	mov    0x8(%ebp),%eax
  80102f:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  801035:	b8 00 00 00 00       	mov    $0x0,%eax
	if (offset >= f->f_size)
  80103a:	39 ca                	cmp    %ecx,%edx
  80103c:	7e 7e                	jle    8010bc <file_read+0xa6>
	count = MIN(count, f->f_size - offset);
  80103e:	29 ca                	sub    %ecx,%edx
  801040:	39 da                	cmp    %ebx,%edx
  801042:	89 d8                	mov    %ebx,%eax
  801044:	0f 46 c2             	cmovbe %edx,%eax
  801047:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (pos = offset; pos < offset + count;) {
  80104a:	89 cb                	mov    %ecx,%ebx
  80104c:	01 c1                	add    %eax,%ecx
  80104e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  801051:	89 de                	mov    %ebx,%esi
  801053:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  801056:	76 61                	jbe    8010b9 <file_read+0xa3>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  801058:	83 ec 04             	sub    $0x4,%esp
  80105b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80105e:	50                   	push   %eax
  80105f:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  801065:	85 db                	test   %ebx,%ebx
  801067:	0f 49 c3             	cmovns %ebx,%eax
  80106a:	c1 f8 0c             	sar    $0xc,%eax
  80106d:	50                   	push   %eax
  80106e:	ff 75 08             	pushl  0x8(%ebp)
  801071:	e8 20 fc ff ff       	call   800c96 <file_get_block>
  801076:	83 c4 10             	add    $0x10,%esp
  801079:	85 c0                	test   %eax,%eax
  80107b:	78 3f                	js     8010bc <file_read+0xa6>
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  80107d:	89 da                	mov    %ebx,%edx
  80107f:	c1 fa 1f             	sar    $0x1f,%edx
  801082:	c1 ea 14             	shr    $0x14,%edx
  801085:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  801088:	25 ff 0f 00 00       	and    $0xfff,%eax
  80108d:	29 d0                	sub    %edx,%eax
  80108f:	ba 00 10 00 00       	mov    $0x1000,%edx
  801094:	29 c2                	sub    %eax,%edx
  801096:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801099:	29 f1                	sub    %esi,%ecx
  80109b:	89 ce                	mov    %ecx,%esi
  80109d:	39 ca                	cmp    %ecx,%edx
  80109f:	0f 46 f2             	cmovbe %edx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  8010a2:	83 ec 04             	sub    $0x4,%esp
  8010a5:	56                   	push   %esi
  8010a6:	03 45 e4             	add    -0x1c(%ebp),%eax
  8010a9:	50                   	push   %eax
  8010aa:	57                   	push   %edi
  8010ab:	e8 12 14 00 00       	call   8024c2 <memmove>
		pos += bn;
  8010b0:	01 f3                	add    %esi,%ebx
		buf += bn;
  8010b2:	01 f7                	add    %esi,%edi
  8010b4:	83 c4 10             	add    $0x10,%esp
  8010b7:	eb 98                	jmp    801051 <file_read+0x3b>
	return count;
  8010b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  8010bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010bf:	5b                   	pop    %ebx
  8010c0:	5e                   	pop    %esi
  8010c1:	5f                   	pop    %edi
  8010c2:	5d                   	pop    %ebp
  8010c3:	c3                   	ret    

008010c4 <file_set_size>:

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  8010c4:	f3 0f 1e fb          	endbr32 
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	56                   	push   %esi
  8010cc:	53                   	push   %ebx
  8010cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8010d0:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (f->f_size > newsize)
  8010d3:	39 b3 80 00 00 00    	cmp    %esi,0x80(%ebx)
  8010d9:	7f 1b                	jg     8010f6 <file_set_size+0x32>
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  8010db:	89 b3 80 00 00 00    	mov    %esi,0x80(%ebx)
	flush_block(f);
  8010e1:	83 ec 0c             	sub    $0xc,%esp
  8010e4:	53                   	push   %ebx
  8010e5:	e8 e2 f3 ff ff       	call   8004cc <flush_block>
	return 0;
}
  8010ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f2:	5b                   	pop    %ebx
  8010f3:	5e                   	pop    %esi
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    
		file_truncate_blocks(f, newsize);
  8010f6:	89 f2                	mov    %esi,%edx
  8010f8:	89 d8                	mov    %ebx,%eax
  8010fa:	e8 f0 f9 ff ff       	call   800aef <file_truncate_blocks>
  8010ff:	eb da                	jmp    8010db <file_set_size+0x17>

00801101 <file_write>:
{
  801101:	f3 0f 1e fb          	endbr32 
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	57                   	push   %edi
  801109:	56                   	push   %esi
  80110a:	53                   	push   %ebx
  80110b:	83 ec 2c             	sub    $0x2c,%esp
  80110e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801111:	8b 5d 14             	mov    0x14(%ebp),%ebx
	if (offset + count > f->f_size)
  801114:	89 d8                	mov    %ebx,%eax
  801116:	03 45 10             	add    0x10(%ebp),%eax
  801119:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80111c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80111f:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  801125:	77 68                	ja     80118f <file_write+0x8e>
	for (pos = offset; pos < offset + count;) {
  801127:	89 de                	mov    %ebx,%esi
  801129:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  80112c:	76 74                	jbe    8011a2 <file_write+0xa1>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  80112e:	83 ec 04             	sub    $0x4,%esp
  801131:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801134:	50                   	push   %eax
  801135:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  80113b:	85 db                	test   %ebx,%ebx
  80113d:	0f 49 c3             	cmovns %ebx,%eax
  801140:	c1 f8 0c             	sar    $0xc,%eax
  801143:	50                   	push   %eax
  801144:	ff 75 08             	pushl  0x8(%ebp)
  801147:	e8 4a fb ff ff       	call   800c96 <file_get_block>
  80114c:	83 c4 10             	add    $0x10,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	78 52                	js     8011a5 <file_write+0xa4>
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  801153:	89 da                	mov    %ebx,%edx
  801155:	c1 fa 1f             	sar    $0x1f,%edx
  801158:	c1 ea 14             	shr    $0x14,%edx
  80115b:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  80115e:	25 ff 0f 00 00       	and    $0xfff,%eax
  801163:	29 d0                	sub    %edx,%eax
  801165:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80116a:	29 c1                	sub    %eax,%ecx
  80116c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80116f:	29 f2                	sub    %esi,%edx
  801171:	39 d1                	cmp    %edx,%ecx
  801173:	89 d6                	mov    %edx,%esi
  801175:	0f 46 f1             	cmovbe %ecx,%esi
		memmove(blk + pos % BLKSIZE, buf, bn);
  801178:	83 ec 04             	sub    $0x4,%esp
  80117b:	56                   	push   %esi
  80117c:	57                   	push   %edi
  80117d:	03 45 e4             	add    -0x1c(%ebp),%eax
  801180:	50                   	push   %eax
  801181:	e8 3c 13 00 00       	call   8024c2 <memmove>
		pos += bn;
  801186:	01 f3                	add    %esi,%ebx
		buf += bn;
  801188:	01 f7                	add    %esi,%edi
  80118a:	83 c4 10             	add    $0x10,%esp
  80118d:	eb 98                	jmp    801127 <file_write+0x26>
		if ((r = file_set_size(f, offset + count)) < 0)
  80118f:	83 ec 08             	sub    $0x8,%esp
  801192:	50                   	push   %eax
  801193:	51                   	push   %ecx
  801194:	e8 2b ff ff ff       	call   8010c4 <file_set_size>
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	85 c0                	test   %eax,%eax
  80119e:	79 87                	jns    801127 <file_write+0x26>
  8011a0:	eb 03                	jmp    8011a5 <file_write+0xa4>
	return count;
  8011a2:	8b 45 10             	mov    0x10(%ebp),%eax
}
  8011a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a8:	5b                   	pop    %ebx
  8011a9:	5e                   	pop    %esi
  8011aa:	5f                   	pop    %edi
  8011ab:	5d                   	pop    %ebp
  8011ac:	c3                   	ret    

008011ad <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  8011ad:	f3 0f 1e fb          	endbr32 
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	56                   	push   %esi
  8011b5:	53                   	push   %ebx
  8011b6:	83 ec 10             	sub    $0x10,%esp
  8011b9:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  8011bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c1:	eb 03                	jmp    8011c6 <file_flush+0x19>
  8011c3:	83 c3 01             	add    $0x1,%ebx
  8011c6:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  8011cc:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  8011d2:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  8011d8:	0f 49 c2             	cmovns %edx,%eax
  8011db:	c1 f8 0c             	sar    $0xc,%eax
  8011de:	39 d8                	cmp    %ebx,%eax
  8011e0:	7e 3b                	jle    80121d <file_flush+0x70>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  8011e2:	83 ec 0c             	sub    $0xc,%esp
  8011e5:	6a 00                	push   $0x0
  8011e7:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  8011ea:	89 da                	mov    %ebx,%edx
  8011ec:	89 f0                	mov    %esi,%eax
  8011ee:	e8 fe f7 ff ff       	call   8009f1 <file_block_walk>
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	78 c9                	js     8011c3 <file_flush+0x16>
		    pdiskbno == NULL || *pdiskbno == 0)
  8011fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	74 c2                	je     8011c3 <file_flush+0x16>
		    pdiskbno == NULL || *pdiskbno == 0)
  801201:	8b 00                	mov    (%eax),%eax
  801203:	85 c0                	test   %eax,%eax
  801205:	74 bc                	je     8011c3 <file_flush+0x16>
			continue;
		flush_block(diskaddr(*pdiskbno));
  801207:	83 ec 0c             	sub    $0xc,%esp
  80120a:	50                   	push   %eax
  80120b:	e8 32 f2 ff ff       	call   800442 <diskaddr>
  801210:	89 04 24             	mov    %eax,(%esp)
  801213:	e8 b4 f2 ff ff       	call   8004cc <flush_block>
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	eb a6                	jmp    8011c3 <file_flush+0x16>
	}
	flush_block(f);
  80121d:	83 ec 0c             	sub    $0xc,%esp
  801220:	56                   	push   %esi
  801221:	e8 a6 f2 ff ff       	call   8004cc <flush_block>
	if (f->f_indirect)
  801226:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	85 c0                	test   %eax,%eax
  801231:	75 07                	jne    80123a <file_flush+0x8d>
		flush_block(diskaddr(f->f_indirect));
}
  801233:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801236:	5b                   	pop    %ebx
  801237:	5e                   	pop    %esi
  801238:	5d                   	pop    %ebp
  801239:	c3                   	ret    
		flush_block(diskaddr(f->f_indirect));
  80123a:	83 ec 0c             	sub    $0xc,%esp
  80123d:	50                   	push   %eax
  80123e:	e8 ff f1 ff ff       	call   800442 <diskaddr>
  801243:	89 04 24             	mov    %eax,(%esp)
  801246:	e8 81 f2 ff ff       	call   8004cc <flush_block>
  80124b:	83 c4 10             	add    $0x10,%esp
}
  80124e:	eb e3                	jmp    801233 <file_flush+0x86>

00801250 <file_create>:
{
  801250:	f3 0f 1e fb          	endbr32 
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	81 ec a4 00 00 00    	sub    $0xa4,%esp
	if ((r = walk_path(path, &dir, &f, name)) == 0)
  80125d:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
  801263:	50                   	push   %eax
  801264:	8d 8d 70 ff ff ff    	lea    -0x90(%ebp),%ecx
  80126a:	8d 95 74 ff ff ff    	lea    -0x8c(%ebp),%edx
  801270:	8b 45 08             	mov    0x8(%ebp),%eax
  801273:	e8 62 fb ff ff       	call   800dda <walk_path>
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	74 58                	je     8012d7 <file_create+0x87>
	if (r != -E_NOT_FOUND || dir == 0)
  80127f:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801282:	75 51                	jne    8012d5 <file_create+0x85>
  801284:	8b 8d 74 ff ff ff    	mov    -0x8c(%ebp),%ecx
  80128a:	85 c9                	test   %ecx,%ecx
  80128c:	74 47                	je     8012d5 <file_create+0x85>
	if ((r = dir_alloc_file(dir, &f)) < 0)
  80128e:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
  801294:	89 c8                	mov    %ecx,%eax
  801296:	e8 98 fc ff ff       	call   800f33 <dir_alloc_file>
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 36                	js     8012d5 <file_create+0x85>
	strcpy(f->f_name, name);
  80129f:	83 ec 08             	sub    $0x8,%esp
  8012a2:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
  8012a8:	50                   	push   %eax
  8012a9:	ff b5 70 ff ff ff    	pushl  -0x90(%ebp)
  8012af:	e8 56 10 00 00       	call   80230a <strcpy>
	*pf = f;
  8012b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b7:	8b 95 70 ff ff ff    	mov    -0x90(%ebp),%edx
  8012bd:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  8012bf:	83 c4 04             	add    $0x4,%esp
  8012c2:	ff b5 74 ff ff ff    	pushl  -0x8c(%ebp)
  8012c8:	e8 e0 fe ff ff       	call   8011ad <file_flush>
	return 0;
  8012cd:	83 c4 10             	add    $0x10,%esp
  8012d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d5:	c9                   	leave  
  8012d6:	c3                   	ret    
		return -E_FILE_EXISTS;
  8012d7:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  8012dc:	eb f7                	jmp    8012d5 <file_create+0x85>

008012de <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  8012de:	f3 0f 1e fb          	endbr32 
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	53                   	push   %ebx
  8012e6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  8012e9:	bb 01 00 00 00       	mov    $0x1,%ebx
  8012ee:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8012f3:	39 58 04             	cmp    %ebx,0x4(%eax)
  8012f6:	76 19                	jbe    801311 <fs_sync+0x33>
		flush_block(diskaddr(i));
  8012f8:	83 ec 0c             	sub    $0xc,%esp
  8012fb:	53                   	push   %ebx
  8012fc:	e8 41 f1 ff ff       	call   800442 <diskaddr>
  801301:	89 04 24             	mov    %eax,(%esp)
  801304:	e8 c3 f1 ff ff       	call   8004cc <flush_block>
	for (i = 1; i < super->s_nblocks; i++)
  801309:	83 c3 01             	add    $0x1,%ebx
  80130c:	83 c4 10             	add    $0x10,%esp
  80130f:	eb dd                	jmp    8012ee <fs_sync+0x10>
}
  801311:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801314:	c9                   	leave  
  801315:	c3                   	ret    

00801316 <outw>:
{
  801316:	89 c1                	mov    %eax,%ecx
  801318:	89 d0                	mov    %edx,%eax
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80131a:	89 ca                	mov    %ecx,%edx
  80131c:	66 ef                	out    %ax,(%dx)
}
  80131e:	c3                   	ret    

0080131f <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  80131f:	f3 0f 1e fb          	endbr32 
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  801329:	e8 b0 ff ff ff       	call   8012de <fs_sync>
	return 0;
}
  80132e:	b8 00 00 00 00       	mov    $0x0,%eax
  801333:	c9                   	leave  
  801334:	c3                   	ret    

00801335 <serve_init>:
{
  801335:	f3 0f 1e fb          	endbr32 
  801339:	ba 60 50 80 00       	mov    $0x805060,%edx
	uintptr_t va = FILEVA;
  80133e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801343:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  801348:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd *) va;
  80134a:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  80134d:	81 c1 00 10 00 00    	add    $0x1000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801353:	83 c0 01             	add    $0x1,%eax
  801356:	83 c2 10             	add    $0x10,%edx
  801359:	3d 00 04 00 00       	cmp    $0x400,%eax
  80135e:	75 e8                	jne    801348 <serve_init+0x13>
}
  801360:	c3                   	ret    

00801361 <openfile_alloc>:
{
  801361:	f3 0f 1e fb          	endbr32 
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	57                   	push   %edi
  801369:	56                   	push   %esi
  80136a:	53                   	push   %ebx
  80136b:	83 ec 0c             	sub    $0xc,%esp
  80136e:	8b 7d 08             	mov    0x8(%ebp),%edi
	for (i = 0; i < MAXOPEN; i++) {
  801371:	bb 00 00 00 00       	mov    $0x0,%ebx
  801376:	89 de                	mov    %ebx,%esi
  801378:	c1 e6 04             	shl    $0x4,%esi
		switch (pageref(opentab[i].o_fd)) {
  80137b:	83 ec 0c             	sub    $0xc,%esp
  80137e:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
  801384:	e8 4f 1f 00 00       	call   8032d8 <pageref>
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	74 17                	je     8013a7 <openfile_alloc+0x46>
  801390:	83 f8 01             	cmp    $0x1,%eax
  801393:	74 30                	je     8013c5 <openfile_alloc+0x64>
	for (i = 0; i < MAXOPEN; i++) {
  801395:	83 c3 01             	add    $0x1,%ebx
  801398:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80139e:	75 d6                	jne    801376 <openfile_alloc+0x15>
	return -E_MAX_OPEN;
  8013a0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8013a5:	eb 4f                	jmp    8013f6 <openfile_alloc+0x95>
			if ((r = sys_page_alloc(0,
  8013a7:	83 ec 04             	sub    $0x4,%esp
  8013aa:	6a 07                	push   $0x7
			                        opentab[i].o_fd,
  8013ac:	89 d8                	mov    %ebx,%eax
  8013ae:	c1 e0 04             	shl    $0x4,%eax
			if ((r = sys_page_alloc(0,
  8013b1:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8013b7:	6a 00                	push   $0x0
  8013b9:	e8 d4 13 00 00       	call   802792 <sys_page_alloc>
  8013be:	83 c4 10             	add    $0x10,%esp
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	78 31                	js     8013f6 <openfile_alloc+0x95>
			opentab[i].o_fileid += MAXOPEN;
  8013c5:	c1 e3 04             	shl    $0x4,%ebx
  8013c8:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  8013cf:	04 00 00 
			*o = &opentab[i];
  8013d2:	81 c6 60 50 80 00    	add    $0x805060,%esi
  8013d8:	89 37                	mov    %esi,(%edi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8013da:	83 ec 04             	sub    $0x4,%esp
  8013dd:	68 00 10 00 00       	push   $0x1000
  8013e2:	6a 00                	push   $0x0
  8013e4:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  8013ea:	e8 85 10 00 00       	call   802474 <memset>
			return (*o)->o_fileid;
  8013ef:	8b 07                	mov    (%edi),%eax
  8013f1:	8b 00                	mov    (%eax),%eax
  8013f3:	83 c4 10             	add    $0x10,%esp
}
  8013f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f9:	5b                   	pop    %ebx
  8013fa:	5e                   	pop    %esi
  8013fb:	5f                   	pop    %edi
  8013fc:	5d                   	pop    %ebp
  8013fd:	c3                   	ret    

008013fe <openfile_lookup>:
{
  8013fe:	f3 0f 1e fb          	endbr32 
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
  801405:	57                   	push   %edi
  801406:	56                   	push   %esi
  801407:	53                   	push   %ebx
  801408:	83 ec 18             	sub    $0x18,%esp
  80140b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	o = &opentab[fileid % MAXOPEN];
  80140e:	89 fb                	mov    %edi,%ebx
  801410:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801416:	89 de                	mov    %ebx,%esi
  801418:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80141b:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
	o = &opentab[fileid % MAXOPEN];
  801421:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801427:	e8 ac 1e 00 00       	call   8032d8 <pageref>
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	83 f8 01             	cmp    $0x1,%eax
  801432:	7e 1d                	jle    801451 <openfile_lookup+0x53>
  801434:	c1 e3 04             	shl    $0x4,%ebx
  801437:	39 bb 60 50 80 00    	cmp    %edi,0x805060(%ebx)
  80143d:	75 19                	jne    801458 <openfile_lookup+0x5a>
	*po = o;
  80143f:	8b 45 10             	mov    0x10(%ebp),%eax
  801442:	89 30                	mov    %esi,(%eax)
	return 0;
  801444:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801449:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80144c:	5b                   	pop    %ebx
  80144d:	5e                   	pop    %esi
  80144e:	5f                   	pop    %edi
  80144f:	5d                   	pop    %ebp
  801450:	c3                   	ret    
		return -E_INVAL;
  801451:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801456:	eb f1                	jmp    801449 <openfile_lookup+0x4b>
  801458:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80145d:	eb ea                	jmp    801449 <openfile_lookup+0x4b>

0080145f <serve_set_size>:
{
  80145f:	f3 0f 1e fb          	endbr32 
  801463:	55                   	push   %ebp
  801464:	89 e5                	mov    %esp,%ebp
  801466:	53                   	push   %ebx
  801467:	83 ec 18             	sub    $0x18,%esp
  80146a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80146d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801470:	50                   	push   %eax
  801471:	ff 33                	pushl  (%ebx)
  801473:	ff 75 08             	pushl  0x8(%ebp)
  801476:	e8 83 ff ff ff       	call   8013fe <openfile_lookup>
  80147b:	83 c4 10             	add    $0x10,%esp
  80147e:	85 c0                	test   %eax,%eax
  801480:	78 14                	js     801496 <serve_set_size+0x37>
	return file_set_size(o->o_file, req->req_size);
  801482:	83 ec 08             	sub    $0x8,%esp
  801485:	ff 73 04             	pushl  0x4(%ebx)
  801488:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148b:	ff 70 04             	pushl  0x4(%eax)
  80148e:	e8 31 fc ff ff       	call   8010c4 <file_set_size>
  801493:	83 c4 10             	add    $0x10,%esp
}
  801496:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801499:	c9                   	leave  
  80149a:	c3                   	ret    

0080149b <serve_read>:
{
  80149b:	f3 0f 1e fb          	endbr32 
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	53                   	push   %ebx
  8014a3:	83 ec 18             	sub    $0x18,%esp
  8014a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &open_file)) < 0) {
  8014a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ac:	50                   	push   %eax
  8014ad:	ff 33                	pushl  (%ebx)
  8014af:	ff 75 08             	pushl  0x8(%ebp)
  8014b2:	e8 47 ff ff ff       	call   8013fe <openfile_lookup>
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 25                	js     8014e3 <serve_read+0x48>
	                   open_file->o_fd->fd_offset)) < 0) {
  8014be:	8b 45 f4             	mov    -0xc(%ebp),%eax
	if ((r = file_read(open_file->o_file,
  8014c1:	8b 50 0c             	mov    0xc(%eax),%edx
  8014c4:	ff 72 04             	pushl  0x4(%edx)
  8014c7:	ff 73 04             	pushl  0x4(%ebx)
  8014ca:	53                   	push   %ebx
  8014cb:	ff 70 04             	pushl  0x4(%eax)
  8014ce:	e8 43 fb ff ff       	call   801016 <file_read>
  8014d3:	83 c4 10             	add    $0x10,%esp
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 09                	js     8014e3 <serve_read+0x48>
	open_file->o_fd->fd_offset += r;
  8014da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014dd:	8b 52 0c             	mov    0xc(%edx),%edx
  8014e0:	01 42 04             	add    %eax,0x4(%edx)
}
  8014e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e6:	c9                   	leave  
  8014e7:	c3                   	ret    

008014e8 <serve_write>:
{
  8014e8:	f3 0f 1e fb          	endbr32 
  8014ec:	55                   	push   %ebp
  8014ed:	89 e5                	mov    %esp,%ebp
  8014ef:	53                   	push   %ebx
  8014f0:	83 ec 18             	sub    $0x18,%esp
  8014f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &open_file)) < 0) {
  8014f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f9:	50                   	push   %eax
  8014fa:	ff 33                	pushl  (%ebx)
  8014fc:	ff 75 08             	pushl  0x8(%ebp)
  8014ff:	e8 fa fe ff ff       	call   8013fe <openfile_lookup>
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	85 c0                	test   %eax,%eax
  801509:	78 28                	js     801533 <serve_write+0x4b>
	                    open_file->o_fd->fd_offset)) < 0) {
  80150b:	8b 45 f4             	mov    -0xc(%ebp),%eax
	if ((r = file_write(open_file->o_file,
  80150e:	8b 50 0c             	mov    0xc(%eax),%edx
  801511:	ff 72 04             	pushl  0x4(%edx)
  801514:	ff 73 04             	pushl  0x4(%ebx)
	                    req->req_buf,
  801517:	83 c3 08             	add    $0x8,%ebx
	if ((r = file_write(open_file->o_file,
  80151a:	53                   	push   %ebx
  80151b:	ff 70 04             	pushl  0x4(%eax)
  80151e:	e8 de fb ff ff       	call   801101 <file_write>
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	85 c0                	test   %eax,%eax
  801528:	78 09                	js     801533 <serve_write+0x4b>
	open_file->o_fd->fd_offset += r;
  80152a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80152d:	8b 52 0c             	mov    0xc(%edx),%edx
  801530:	01 42 04             	add    %eax,0x4(%edx)
}
  801533:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801536:	c9                   	leave  
  801537:	c3                   	ret    

00801538 <serve_stat>:
{
  801538:	f3 0f 1e fb          	endbr32 
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	53                   	push   %ebx
  801540:	83 ec 18             	sub    $0x18,%esp
  801543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801546:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	ff 33                	pushl  (%ebx)
  80154c:	ff 75 08             	pushl  0x8(%ebp)
  80154f:	e8 aa fe ff ff       	call   8013fe <openfile_lookup>
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	85 c0                	test   %eax,%eax
  801559:	78 3f                	js     80159a <serve_stat+0x62>
	strcpy(ret->ret_name, o->o_file->f_name);
  80155b:	83 ec 08             	sub    $0x8,%esp
  80155e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801561:	ff 70 04             	pushl  0x4(%eax)
  801564:	53                   	push   %ebx
  801565:	e8 a0 0d 00 00       	call   80230a <strcpy>
	ret->ret_size = o->o_file->f_size;
  80156a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80156d:	8b 50 04             	mov    0x4(%eax),%edx
  801570:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801576:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  80157c:	8b 40 04             	mov    0x4(%eax),%eax
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801589:	0f 94 c0             	sete   %al
  80158c:	0f b6 c0             	movzbl %al,%eax
  80158f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801595:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80159a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    

0080159f <serve_flush>:
{
  80159f:	f3 0f 1e fb          	endbr32 
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8015a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ac:	50                   	push   %eax
  8015ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b0:	ff 30                	pushl  (%eax)
  8015b2:	ff 75 08             	pushl  0x8(%ebp)
  8015b5:	e8 44 fe ff ff       	call   8013fe <openfile_lookup>
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	78 16                	js     8015d7 <serve_flush+0x38>
	file_flush(o->o_file);
  8015c1:	83 ec 0c             	sub    $0xc,%esp
  8015c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c7:	ff 70 04             	pushl  0x4(%eax)
  8015ca:	e8 de fb ff ff       	call   8011ad <file_flush>
	return 0;
  8015cf:	83 c4 10             	add    $0x10,%esp
  8015d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015d7:	c9                   	leave  
  8015d8:	c3                   	ret    

008015d9 <serve_open>:
{
  8015d9:	f3 0f 1e fb          	endbr32 
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	53                   	push   %ebx
  8015e1:	81 ec 18 04 00 00    	sub    $0x418,%esp
  8015e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	memmove(path, req->req_path, MAXPATHLEN);
  8015ea:	68 00 04 00 00       	push   $0x400
  8015ef:	53                   	push   %ebx
  8015f0:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8015f6:	50                   	push   %eax
  8015f7:	e8 c6 0e 00 00       	call   8024c2 <memmove>
	path[MAXPATHLEN - 1] = 0;
  8015fc:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
	if ((r = openfile_alloc(&o)) < 0) {
  801600:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801606:	89 04 24             	mov    %eax,(%esp)
  801609:	e8 53 fd ff ff       	call   801361 <openfile_alloc>
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	85 c0                	test   %eax,%eax
  801613:	0f 88 f0 00 00 00    	js     801709 <serve_open+0x130>
	if (req->req_omode & O_CREAT) {
  801619:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801620:	74 33                	je     801655 <serve_open+0x7c>
		if ((r = file_create(path, &f)) < 0) {
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801632:	50                   	push   %eax
  801633:	e8 18 fc ff ff       	call   801250 <file_create>
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	79 37                	jns    801676 <serve_open+0x9d>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  80163f:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801646:	0f 85 bd 00 00 00    	jne    801709 <serve_open+0x130>
  80164c:	83 f8 f3             	cmp    $0xfffffff3,%eax
  80164f:	0f 85 b4 00 00 00    	jne    801709 <serve_open+0x130>
		if ((r = file_open(path, &f)) < 0) {
  801655:	83 ec 08             	sub    $0x8,%esp
  801658:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80165e:	50                   	push   %eax
  80165f:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801665:	50                   	push   %eax
  801666:	e8 8d f9 ff ff       	call   800ff8 <file_open>
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	85 c0                	test   %eax,%eax
  801670:	0f 88 93 00 00 00    	js     801709 <serve_open+0x130>
	if (req->req_omode & O_TRUNC) {
  801676:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  80167d:	74 17                	je     801696 <serve_open+0xbd>
		if ((r = file_set_size(f, 0)) < 0) {
  80167f:	83 ec 08             	sub    $0x8,%esp
  801682:	6a 00                	push   $0x0
  801684:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  80168a:	e8 35 fa ff ff       	call   8010c4 <file_set_size>
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	78 73                	js     801709 <serve_open+0x130>
	if ((r = file_open(path, &f)) < 0) {
  801696:	83 ec 08             	sub    $0x8,%esp
  801699:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80169f:	50                   	push   %eax
  8016a0:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8016a6:	50                   	push   %eax
  8016a7:	e8 4c f9 ff ff       	call   800ff8 <file_open>
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 56                	js     801709 <serve_open+0x130>
	o->o_file = f;
  8016b3:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8016b9:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8016bf:	89 50 04             	mov    %edx,0x4(%eax)
	o->o_fd->fd_file.id = o->o_fileid;
  8016c2:	8b 50 0c             	mov    0xc(%eax),%edx
  8016c5:	8b 08                	mov    (%eax),%ecx
  8016c7:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8016ca:	8b 48 0c             	mov    0xc(%eax),%ecx
  8016cd:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  8016d3:	83 e2 03             	and    $0x3,%edx
  8016d6:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  8016d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016dc:	8b 15 64 90 80 00    	mov    0x809064,%edx
  8016e2:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  8016e4:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8016ea:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  8016f0:	89 50 08             	mov    %edx,0x8(%eax)
	*pg_store = o->o_fd;
  8016f3:	8b 50 0c             	mov    0xc(%eax),%edx
  8016f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8016f9:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P | PTE_U | PTE_W | PTE_SHARE;
  8016fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8016fe:	c7 00 07 04 00 00    	movl   $0x407,(%eax)
	return 0;
  801704:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801709:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170c:	c9                   	leave  
  80170d:	c3                   	ret    

0080170e <serve>:
	[FSREQ_SYNC] = serve_sync
};

void
serve(void)
{
  80170e:	f3 0f 1e fb          	endbr32 
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	56                   	push   %esi
  801716:	53                   	push   %ebx
  801717:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80171a:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  80171d:	8d 75 f4             	lea    -0xc(%ebp),%esi
  801720:	e9 82 00 00 00       	jmp    8017a7 <serve+0x99>
			cprintf("Invalid request from %08x: no argument page\n",
			        whom);
			continue;  // just leave it hanging...
		}

		pg = NULL;
  801725:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  80172c:	83 f8 01             	cmp    $0x1,%eax
  80172f:	74 23                	je     801754 <serve+0x46>
			r = serve_open(whom, (struct Fsreq_open *) fsreq, &pg, &perm);
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  801731:	83 f8 08             	cmp    $0x8,%eax
  801734:	77 36                	ja     80176c <serve+0x5e>
  801736:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  80173d:	85 d2                	test   %edx,%edx
  80173f:	74 2b                	je     80176c <serve+0x5e>
			r = handlers[req](whom, fsreq);
  801741:	83 ec 08             	sub    $0x8,%esp
  801744:	ff 35 44 50 80 00    	pushl  0x805044
  80174a:	ff 75 f4             	pushl  -0xc(%ebp)
  80174d:	ff d2                	call   *%edx
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	eb 31                	jmp    801785 <serve+0x77>
			r = serve_open(whom, (struct Fsreq_open *) fsreq, &pg, &perm);
  801754:	53                   	push   %ebx
  801755:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801758:	50                   	push   %eax
  801759:	ff 35 44 50 80 00    	pushl  0x805044
  80175f:	ff 75 f4             	pushl  -0xc(%ebp)
  801762:	e8 72 fe ff ff       	call   8015d9 <serve_open>
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	eb 19                	jmp    801785 <serve+0x77>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  80176c:	83 ec 04             	sub    $0x4,%esp
  80176f:	ff 75 f4             	pushl  -0xc(%ebp)
  801772:	50                   	push   %eax
  801773:	68 b0 3d 80 00       	push   $0x803db0
  801778:	e8 23 06 00 00       	call   801da0 <cprintf>
  80177d:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  801780:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801785:	ff 75 f0             	pushl  -0x10(%ebp)
  801788:	ff 75 ec             	pushl  -0x14(%ebp)
  80178b:	50                   	push   %eax
  80178c:	ff 75 f4             	pushl  -0xc(%ebp)
  80178f:	e8 41 12 00 00       	call   8029d5 <ipc_send>
		sys_page_unmap(0, fsreq);
  801794:	83 c4 08             	add    $0x8,%esp
  801797:	ff 35 44 50 80 00    	pushl  0x805044
  80179d:	6a 00                	push   $0x0
  80179f:	e8 40 10 00 00       	call   8027e4 <sys_page_unmap>
  8017a4:	83 c4 10             	add    $0x10,%esp
		perm = 0;
  8017a7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  8017ae:	83 ec 04             	sub    $0x4,%esp
  8017b1:	53                   	push   %ebx
  8017b2:	ff 35 44 50 80 00    	pushl  0x805044
  8017b8:	56                   	push   %esi
  8017b9:	e8 aa 11 00 00       	call   802968 <ipc_recv>
		if (!(perm & PTE_P)) {
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  8017c5:	0f 85 5a ff ff ff    	jne    801725 <serve+0x17>
			cprintf("Invalid request from %08x: no argument page\n",
  8017cb:	83 ec 08             	sub    $0x8,%esp
  8017ce:	ff 75 f4             	pushl  -0xc(%ebp)
  8017d1:	68 80 3d 80 00       	push   $0x803d80
  8017d6:	e8 c5 05 00 00       	call   801da0 <cprintf>
			continue;  // just leave it hanging...
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	eb c7                	jmp    8017a7 <serve+0x99>

008017e0 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8017e0:	f3 0f 1e fb          	endbr32 
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  8017ea:	c7 05 60 90 80 00 d3 	movl   $0x803dd3,0x809060
  8017f1:	3d 80 00 
	cprintf("FS is running\n");
  8017f4:	68 d6 3d 80 00       	push   $0x803dd6
  8017f9:	e8 a2 05 00 00       	call   801da0 <cprintf>

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
  8017fe:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801803:	b8 00 8a 00 00       	mov    $0x8a00,%eax
  801808:	e8 09 fb ff ff       	call   801316 <outw>
	cprintf("FS can do I/O\n");
  80180d:	c7 04 24 e5 3d 80 00 	movl   $0x803de5,(%esp)
  801814:	e8 87 05 00 00       	call   801da0 <cprintf>

	serve_init();
  801819:	e8 17 fb ff ff       	call   801335 <serve_init>
	fs_init();
  80181e:	e8 10 f4 ff ff       	call   800c33 <fs_init>
	fs_test();
  801823:	e8 05 00 00 00       	call   80182d <fs_test>
	serve();
  801828:	e8 e1 fe ff ff       	call   80170e <serve>

0080182d <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  80182d:	f3 0f 1e fb          	endbr32 
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	53                   	push   %ebx
  801835:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801838:	6a 07                	push   $0x7
  80183a:	68 00 10 00 00       	push   $0x1000
  80183f:	6a 00                	push   $0x0
  801841:	e8 4c 0f 00 00       	call   802792 <sys_page_alloc>
  801846:	83 c4 10             	add    $0x10,%esp
  801849:	85 c0                	test   %eax,%eax
  80184b:	0f 88 68 02 00 00    	js     801ab9 <fs_test+0x28c>
		panic("sys_page_alloc: %e", r);
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801851:	83 ec 04             	sub    $0x4,%esp
  801854:	68 00 10 00 00       	push   $0x1000
  801859:	ff 35 04 a0 80 00    	pushl  0x80a004
  80185f:	68 00 10 00 00       	push   $0x1000
  801864:	e8 59 0c 00 00       	call   8024c2 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  801869:	e8 fe f0 ff ff       	call   80096c <alloc_block>
  80186e:	83 c4 10             	add    $0x10,%esp
  801871:	85 c0                	test   %eax,%eax
  801873:	0f 88 52 02 00 00    	js     801acb <fs_test+0x29e>
		panic("alloc_block: %e", r);
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801879:	8d 50 1f             	lea    0x1f(%eax),%edx
  80187c:	0f 49 d0             	cmovns %eax,%edx
  80187f:	c1 fa 05             	sar    $0x5,%edx
  801882:	89 c3                	mov    %eax,%ebx
  801884:	c1 fb 1f             	sar    $0x1f,%ebx
  801887:	c1 eb 1b             	shr    $0x1b,%ebx
  80188a:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  80188d:	83 e1 1f             	and    $0x1f,%ecx
  801890:	29 d9                	sub    %ebx,%ecx
  801892:	b8 01 00 00 00       	mov    $0x1,%eax
  801897:	d3 e0                	shl    %cl,%eax
  801899:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  8018a0:	0f 84 37 02 00 00    	je     801add <fs_test+0x2b0>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8018a6:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  8018ac:	85 04 91             	test   %eax,(%ecx,%edx,4)
  8018af:	0f 85 3e 02 00 00    	jne    801af3 <fs_test+0x2c6>
	cprintf("alloc_block is good\n");
  8018b5:	83 ec 0c             	sub    $0xc,%esp
  8018b8:	68 3c 3e 80 00       	push   $0x803e3c
  8018bd:	e8 de 04 00 00       	call   801da0 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  8018c2:	83 c4 08             	add    $0x8,%esp
  8018c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c8:	50                   	push   %eax
  8018c9:	68 51 3e 80 00       	push   $0x803e51
  8018ce:	e8 25 f7 ff ff       	call   800ff8 <file_open>
  8018d3:	83 c4 10             	add    $0x10,%esp
  8018d6:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8018d9:	74 08                	je     8018e3 <fs_test+0xb6>
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	0f 88 26 02 00 00    	js     801b09 <fs_test+0x2dc>
		panic("file_open /not-found: %e", r);
	else if (r == 0)
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	0f 84 30 02 00 00    	je     801b1b <fs_test+0x2ee>
		panic("file_open /not-found succeeded!");
	if ((r = file_open("/newmotd", &f)) < 0)
  8018eb:	83 ec 08             	sub    $0x8,%esp
  8018ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f1:	50                   	push   %eax
  8018f2:	68 75 3e 80 00       	push   $0x803e75
  8018f7:	e8 fc f6 ff ff       	call   800ff8 <file_open>
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	85 c0                	test   %eax,%eax
  801901:	0f 88 28 02 00 00    	js     801b2f <fs_test+0x302>
		panic("file_open /newmotd: %e", r);
	cprintf("file_open is good\n");
  801907:	83 ec 0c             	sub    $0xc,%esp
  80190a:	68 95 3e 80 00       	push   $0x803e95
  80190f:	e8 8c 04 00 00       	call   801da0 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801914:	83 c4 0c             	add    $0xc,%esp
  801917:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80191a:	50                   	push   %eax
  80191b:	6a 00                	push   $0x0
  80191d:	ff 75 f4             	pushl  -0xc(%ebp)
  801920:	e8 71 f3 ff ff       	call   800c96 <file_get_block>
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	85 c0                	test   %eax,%eax
  80192a:	0f 88 11 02 00 00    	js     801b41 <fs_test+0x314>
		panic("file_get_block: %e", r);
	if (strcmp(blk, msg) != 0)
  801930:	83 ec 08             	sub    $0x8,%esp
  801933:	68 dc 3f 80 00       	push   $0x803fdc
  801938:	ff 75 f0             	pushl  -0x10(%ebp)
  80193b:	e8 89 0a 00 00       	call   8023c9 <strcmp>
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	85 c0                	test   %eax,%eax
  801945:	0f 85 08 02 00 00    	jne    801b53 <fs_test+0x326>
		panic("file_get_block returned wrong data");
	cprintf("file_get_block is good\n");
  80194b:	83 ec 0c             	sub    $0xc,%esp
  80194e:	68 bb 3e 80 00       	push   $0x803ebb
  801953:	e8 48 04 00 00       	call   801da0 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801958:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195b:	0f b6 10             	movzbl (%eax),%edx
  80195e:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801960:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801963:	c1 e8 0c             	shr    $0xc,%eax
  801966:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	a8 40                	test   $0x40,%al
  801972:	0f 84 ef 01 00 00    	je     801b67 <fs_test+0x33a>
	file_flush(f);
  801978:	83 ec 0c             	sub    $0xc,%esp
  80197b:	ff 75 f4             	pushl  -0xc(%ebp)
  80197e:	e8 2a f8 ff ff       	call   8011ad <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801983:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801986:	c1 e8 0c             	shr    $0xc,%eax
  801989:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801990:	83 c4 10             	add    $0x10,%esp
  801993:	a8 40                	test   $0x40,%al
  801995:	0f 85 e2 01 00 00    	jne    801b7d <fs_test+0x350>
	cprintf("file_flush is good\n");
  80199b:	83 ec 0c             	sub    $0xc,%esp
  80199e:	68 ef 3e 80 00       	push   $0x803eef
  8019a3:	e8 f8 03 00 00       	call   801da0 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8019a8:	83 c4 08             	add    $0x8,%esp
  8019ab:	6a 00                	push   $0x0
  8019ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b0:	e8 0f f7 ff ff       	call   8010c4 <file_set_size>
  8019b5:	83 c4 10             	add    $0x10,%esp
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	0f 88 d3 01 00 00    	js     801b93 <fs_test+0x366>
		panic("file_set_size: %e", r);
	assert(f->f_direct[0] == 0);
  8019c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c3:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8019ca:	0f 85 d5 01 00 00    	jne    801ba5 <fs_test+0x378>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8019d0:	c1 e8 0c             	shr    $0xc,%eax
  8019d3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019da:	a8 40                	test   $0x40,%al
  8019dc:	0f 85 d9 01 00 00    	jne    801bbb <fs_test+0x38e>
	cprintf("file_truncate is good\n");
  8019e2:	83 ec 0c             	sub    $0xc,%esp
  8019e5:	68 43 3f 80 00       	push   $0x803f43
  8019ea:	e8 b1 03 00 00       	call   801da0 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8019ef:	c7 04 24 dc 3f 80 00 	movl   $0x803fdc,(%esp)
  8019f6:	e8 cc 08 00 00       	call   8022c7 <strlen>
  8019fb:	83 c4 08             	add    $0x8,%esp
  8019fe:	50                   	push   %eax
  8019ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801a02:	e8 bd f6 ff ff       	call   8010c4 <file_set_size>
  801a07:	83 c4 10             	add    $0x10,%esp
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	0f 88 bf 01 00 00    	js     801bd1 <fs_test+0x3a4>
		panic("file_set_size 2: %e", r);
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a15:	89 c2                	mov    %eax,%edx
  801a17:	c1 ea 0c             	shr    $0xc,%edx
  801a1a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a21:	f6 c2 40             	test   $0x40,%dl
  801a24:	0f 85 b9 01 00 00    	jne    801be3 <fs_test+0x3b6>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801a2a:	83 ec 04             	sub    $0x4,%esp
  801a2d:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801a30:	52                   	push   %edx
  801a31:	6a 00                	push   $0x0
  801a33:	50                   	push   %eax
  801a34:	e8 5d f2 ff ff       	call   800c96 <file_get_block>
  801a39:	83 c4 10             	add    $0x10,%esp
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	0f 88 b5 01 00 00    	js     801bf9 <fs_test+0x3cc>
		panic("file_get_block 2: %e", r);
	strcpy(blk, msg);
  801a44:	83 ec 08             	sub    $0x8,%esp
  801a47:	68 dc 3f 80 00       	push   $0x803fdc
  801a4c:	ff 75 f0             	pushl  -0x10(%ebp)
  801a4f:	e8 b6 08 00 00       	call   80230a <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a57:	c1 e8 0c             	shr    $0xc,%eax
  801a5a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	a8 40                	test   $0x40,%al
  801a66:	0f 84 9f 01 00 00    	je     801c0b <fs_test+0x3de>
	file_flush(f);
  801a6c:	83 ec 0c             	sub    $0xc,%esp
  801a6f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a72:	e8 36 f7 ff ff       	call   8011ad <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a7a:	c1 e8 0c             	shr    $0xc,%eax
  801a7d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	a8 40                	test   $0x40,%al
  801a89:	0f 85 92 01 00 00    	jne    801c21 <fs_test+0x3f4>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a92:	c1 e8 0c             	shr    $0xc,%eax
  801a95:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a9c:	a8 40                	test   $0x40,%al
  801a9e:	0f 85 93 01 00 00    	jne    801c37 <fs_test+0x40a>
	cprintf("file rewrite is good\n");
  801aa4:	83 ec 0c             	sub    $0xc,%esp
  801aa7:	68 83 3f 80 00       	push   $0x803f83
  801aac:	e8 ef 02 00 00       	call   801da0 <cprintf>
}
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  801ab9:	50                   	push   %eax
  801aba:	68 f4 3d 80 00       	push   $0x803df4
  801abf:	6a 12                	push   $0x12
  801ac1:	68 07 3e 80 00       	push   $0x803e07
  801ac6:	e8 ee 01 00 00       	call   801cb9 <_panic>
		panic("alloc_block: %e", r);
  801acb:	50                   	push   %eax
  801acc:	68 11 3e 80 00       	push   $0x803e11
  801ad1:	6a 17                	push   $0x17
  801ad3:	68 07 3e 80 00       	push   $0x803e07
  801ad8:	e8 dc 01 00 00       	call   801cb9 <_panic>
	assert(bits[r/32] & (1 << (r%32)));
  801add:	68 21 3e 80 00       	push   $0x803e21
  801ae2:	68 bd 3a 80 00       	push   $0x803abd
  801ae7:	6a 19                	push   $0x19
  801ae9:	68 07 3e 80 00       	push   $0x803e07
  801aee:	e8 c6 01 00 00       	call   801cb9 <_panic>
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801af3:	68 9c 3f 80 00       	push   $0x803f9c
  801af8:	68 bd 3a 80 00       	push   $0x803abd
  801afd:	6a 1b                	push   $0x1b
  801aff:	68 07 3e 80 00       	push   $0x803e07
  801b04:	e8 b0 01 00 00       	call   801cb9 <_panic>
		panic("file_open /not-found: %e", r);
  801b09:	50                   	push   %eax
  801b0a:	68 5c 3e 80 00       	push   $0x803e5c
  801b0f:	6a 1f                	push   $0x1f
  801b11:	68 07 3e 80 00       	push   $0x803e07
  801b16:	e8 9e 01 00 00       	call   801cb9 <_panic>
		panic("file_open /not-found succeeded!");
  801b1b:	83 ec 04             	sub    $0x4,%esp
  801b1e:	68 bc 3f 80 00       	push   $0x803fbc
  801b23:	6a 21                	push   $0x21
  801b25:	68 07 3e 80 00       	push   $0x803e07
  801b2a:	e8 8a 01 00 00       	call   801cb9 <_panic>
		panic("file_open /newmotd: %e", r);
  801b2f:	50                   	push   %eax
  801b30:	68 7e 3e 80 00       	push   $0x803e7e
  801b35:	6a 23                	push   $0x23
  801b37:	68 07 3e 80 00       	push   $0x803e07
  801b3c:	e8 78 01 00 00       	call   801cb9 <_panic>
		panic("file_get_block: %e", r);
  801b41:	50                   	push   %eax
  801b42:	68 a8 3e 80 00       	push   $0x803ea8
  801b47:	6a 27                	push   $0x27
  801b49:	68 07 3e 80 00       	push   $0x803e07
  801b4e:	e8 66 01 00 00       	call   801cb9 <_panic>
		panic("file_get_block returned wrong data");
  801b53:	83 ec 04             	sub    $0x4,%esp
  801b56:	68 04 40 80 00       	push   $0x804004
  801b5b:	6a 29                	push   $0x29
  801b5d:	68 07 3e 80 00       	push   $0x803e07
  801b62:	e8 52 01 00 00       	call   801cb9 <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801b67:	68 d4 3e 80 00       	push   $0x803ed4
  801b6c:	68 bd 3a 80 00       	push   $0x803abd
  801b71:	6a 2d                	push   $0x2d
  801b73:	68 07 3e 80 00       	push   $0x803e07
  801b78:	e8 3c 01 00 00       	call   801cb9 <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801b7d:	68 d3 3e 80 00       	push   $0x803ed3
  801b82:	68 bd 3a 80 00       	push   $0x803abd
  801b87:	6a 2f                	push   $0x2f
  801b89:	68 07 3e 80 00       	push   $0x803e07
  801b8e:	e8 26 01 00 00       	call   801cb9 <_panic>
		panic("file_set_size: %e", r);
  801b93:	50                   	push   %eax
  801b94:	68 03 3f 80 00       	push   $0x803f03
  801b99:	6a 33                	push   $0x33
  801b9b:	68 07 3e 80 00       	push   $0x803e07
  801ba0:	e8 14 01 00 00       	call   801cb9 <_panic>
	assert(f->f_direct[0] == 0);
  801ba5:	68 15 3f 80 00       	push   $0x803f15
  801baa:	68 bd 3a 80 00       	push   $0x803abd
  801baf:	6a 34                	push   $0x34
  801bb1:	68 07 3e 80 00       	push   $0x803e07
  801bb6:	e8 fe 00 00 00       	call   801cb9 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801bbb:	68 29 3f 80 00       	push   $0x803f29
  801bc0:	68 bd 3a 80 00       	push   $0x803abd
  801bc5:	6a 35                	push   $0x35
  801bc7:	68 07 3e 80 00       	push   $0x803e07
  801bcc:	e8 e8 00 00 00       	call   801cb9 <_panic>
		panic("file_set_size 2: %e", r);
  801bd1:	50                   	push   %eax
  801bd2:	68 5a 3f 80 00       	push   $0x803f5a
  801bd7:	6a 39                	push   $0x39
  801bd9:	68 07 3e 80 00       	push   $0x803e07
  801bde:	e8 d6 00 00 00       	call   801cb9 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801be3:	68 29 3f 80 00       	push   $0x803f29
  801be8:	68 bd 3a 80 00       	push   $0x803abd
  801bed:	6a 3a                	push   $0x3a
  801bef:	68 07 3e 80 00       	push   $0x803e07
  801bf4:	e8 c0 00 00 00       	call   801cb9 <_panic>
		panic("file_get_block 2: %e", r);
  801bf9:	50                   	push   %eax
  801bfa:	68 6e 3f 80 00       	push   $0x803f6e
  801bff:	6a 3c                	push   $0x3c
  801c01:	68 07 3e 80 00       	push   $0x803e07
  801c06:	e8 ae 00 00 00       	call   801cb9 <_panic>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801c0b:	68 d4 3e 80 00       	push   $0x803ed4
  801c10:	68 bd 3a 80 00       	push   $0x803abd
  801c15:	6a 3e                	push   $0x3e
  801c17:	68 07 3e 80 00       	push   $0x803e07
  801c1c:	e8 98 00 00 00       	call   801cb9 <_panic>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801c21:	68 d3 3e 80 00       	push   $0x803ed3
  801c26:	68 bd 3a 80 00       	push   $0x803abd
  801c2b:	6a 40                	push   $0x40
  801c2d:	68 07 3e 80 00       	push   $0x803e07
  801c32:	e8 82 00 00 00       	call   801cb9 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801c37:	68 29 3f 80 00       	push   $0x803f29
  801c3c:	68 bd 3a 80 00       	push   $0x803abd
  801c41:	6a 41                	push   $0x41
  801c43:	68 07 3e 80 00       	push   $0x803e07
  801c48:	e8 6c 00 00 00       	call   801cb9 <_panic>

00801c4d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801c4d:	f3 0f 1e fb          	endbr32 
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	56                   	push   %esi
  801c55:	53                   	push   %ebx
  801c56:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c59:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  801c5c:	e8 de 0a 00 00       	call   80273f <sys_getenvid>
	if (id >= 0)
  801c61:	85 c0                	test   %eax,%eax
  801c63:	78 12                	js     801c77 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  801c65:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c6a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c6d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c72:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801c77:	85 db                	test   %ebx,%ebx
  801c79:	7e 07                	jle    801c82 <libmain+0x35>
		binaryname = argv[0];
  801c7b:	8b 06                	mov    (%esi),%eax
  801c7d:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801c82:	83 ec 08             	sub    $0x8,%esp
  801c85:	56                   	push   %esi
  801c86:	53                   	push   %ebx
  801c87:	e8 54 fb ff ff       	call   8017e0 <umain>

	// exit gracefully
	exit();
  801c8c:	e8 0a 00 00 00       	call   801c9b <exit>
}
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c97:	5b                   	pop    %ebx
  801c98:	5e                   	pop    %esi
  801c99:	5d                   	pop    %ebp
  801c9a:	c3                   	ret    

00801c9b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801c9b:	f3 0f 1e fb          	endbr32 
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801ca5:	e8 ae 0f 00 00       	call   802c58 <close_all>
	sys_env_destroy(0);
  801caa:	83 ec 0c             	sub    $0xc,%esp
  801cad:	6a 00                	push   $0x0
  801caf:	e8 65 0a 00 00       	call   802719 <sys_env_destroy>
}
  801cb4:	83 c4 10             	add    $0x10,%esp
  801cb7:	c9                   	leave  
  801cb8:	c3                   	ret    

00801cb9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801cb9:	f3 0f 1e fb          	endbr32 
  801cbd:	55                   	push   %ebp
  801cbe:	89 e5                	mov    %esp,%ebp
  801cc0:	56                   	push   %esi
  801cc1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801cc2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801cc5:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801ccb:	e8 6f 0a 00 00       	call   80273f <sys_getenvid>
  801cd0:	83 ec 0c             	sub    $0xc,%esp
  801cd3:	ff 75 0c             	pushl  0xc(%ebp)
  801cd6:	ff 75 08             	pushl  0x8(%ebp)
  801cd9:	56                   	push   %esi
  801cda:	50                   	push   %eax
  801cdb:	68 34 40 80 00       	push   $0x804034
  801ce0:	e8 bb 00 00 00       	call   801da0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ce5:	83 c4 18             	add    $0x18,%esp
  801ce8:	53                   	push   %ebx
  801ce9:	ff 75 10             	pushl  0x10(%ebp)
  801cec:	e8 5a 00 00 00       	call   801d4b <vcprintf>
	cprintf("\n");
  801cf1:	c7 04 24 43 3c 80 00 	movl   $0x803c43,(%esp)
  801cf8:	e8 a3 00 00 00       	call   801da0 <cprintf>
  801cfd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d00:	cc                   	int3   
  801d01:	eb fd                	jmp    801d00 <_panic+0x47>

00801d03 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801d03:	f3 0f 1e fb          	endbr32 
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	53                   	push   %ebx
  801d0b:	83 ec 04             	sub    $0x4,%esp
  801d0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801d11:	8b 13                	mov    (%ebx),%edx
  801d13:	8d 42 01             	lea    0x1(%edx),%eax
  801d16:	89 03                	mov    %eax,(%ebx)
  801d18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d1b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801d1f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801d24:	74 09                	je     801d2f <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801d26:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801d2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d2d:	c9                   	leave  
  801d2e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801d2f:	83 ec 08             	sub    $0x8,%esp
  801d32:	68 ff 00 00 00       	push   $0xff
  801d37:	8d 43 08             	lea    0x8(%ebx),%eax
  801d3a:	50                   	push   %eax
  801d3b:	e8 87 09 00 00       	call   8026c7 <sys_cputs>
		b->idx = 0;
  801d40:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801d46:	83 c4 10             	add    $0x10,%esp
  801d49:	eb db                	jmp    801d26 <putch+0x23>

00801d4b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801d4b:	f3 0f 1e fb          	endbr32 
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801d58:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801d5f:	00 00 00 
	b.cnt = 0;
  801d62:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801d69:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801d6c:	ff 75 0c             	pushl  0xc(%ebp)
  801d6f:	ff 75 08             	pushl  0x8(%ebp)
  801d72:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801d78:	50                   	push   %eax
  801d79:	68 03 1d 80 00       	push   $0x801d03
  801d7e:	e8 80 01 00 00       	call   801f03 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801d83:	83 c4 08             	add    $0x8,%esp
  801d86:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801d8c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801d92:	50                   	push   %eax
  801d93:	e8 2f 09 00 00       	call   8026c7 <sys_cputs>

	return b.cnt;
}
  801d98:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    

00801da0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801da0:	f3 0f 1e fb          	endbr32 
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801daa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801dad:	50                   	push   %eax
  801dae:	ff 75 08             	pushl  0x8(%ebp)
  801db1:	e8 95 ff ff ff       	call   801d4b <vcprintf>
	va_end(ap);

	return cnt;
}
  801db6:	c9                   	leave  
  801db7:	c3                   	ret    

00801db8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	57                   	push   %edi
  801dbc:	56                   	push   %esi
  801dbd:	53                   	push   %ebx
  801dbe:	83 ec 1c             	sub    $0x1c,%esp
  801dc1:	89 c7                	mov    %eax,%edi
  801dc3:	89 d6                	mov    %edx,%esi
  801dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dcb:	89 d1                	mov    %edx,%ecx
  801dcd:	89 c2                	mov    %eax,%edx
  801dcf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801dd2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801dd5:	8b 45 10             	mov    0x10(%ebp),%eax
  801dd8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801ddb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801dde:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801de5:	39 c2                	cmp    %eax,%edx
  801de7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801dea:	72 3e                	jb     801e2a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801dec:	83 ec 0c             	sub    $0xc,%esp
  801def:	ff 75 18             	pushl  0x18(%ebp)
  801df2:	83 eb 01             	sub    $0x1,%ebx
  801df5:	53                   	push   %ebx
  801df6:	50                   	push   %eax
  801df7:	83 ec 08             	sub    $0x8,%esp
  801dfa:	ff 75 e4             	pushl  -0x1c(%ebp)
  801dfd:	ff 75 e0             	pushl  -0x20(%ebp)
  801e00:	ff 75 dc             	pushl  -0x24(%ebp)
  801e03:	ff 75 d8             	pushl  -0x28(%ebp)
  801e06:	e8 15 1a 00 00       	call   803820 <__udivdi3>
  801e0b:	83 c4 18             	add    $0x18,%esp
  801e0e:	52                   	push   %edx
  801e0f:	50                   	push   %eax
  801e10:	89 f2                	mov    %esi,%edx
  801e12:	89 f8                	mov    %edi,%eax
  801e14:	e8 9f ff ff ff       	call   801db8 <printnum>
  801e19:	83 c4 20             	add    $0x20,%esp
  801e1c:	eb 13                	jmp    801e31 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801e1e:	83 ec 08             	sub    $0x8,%esp
  801e21:	56                   	push   %esi
  801e22:	ff 75 18             	pushl  0x18(%ebp)
  801e25:	ff d7                	call   *%edi
  801e27:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801e2a:	83 eb 01             	sub    $0x1,%ebx
  801e2d:	85 db                	test   %ebx,%ebx
  801e2f:	7f ed                	jg     801e1e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801e31:	83 ec 08             	sub    $0x8,%esp
  801e34:	56                   	push   %esi
  801e35:	83 ec 04             	sub    $0x4,%esp
  801e38:	ff 75 e4             	pushl  -0x1c(%ebp)
  801e3b:	ff 75 e0             	pushl  -0x20(%ebp)
  801e3e:	ff 75 dc             	pushl  -0x24(%ebp)
  801e41:	ff 75 d8             	pushl  -0x28(%ebp)
  801e44:	e8 e7 1a 00 00       	call   803930 <__umoddi3>
  801e49:	83 c4 14             	add    $0x14,%esp
  801e4c:	0f be 80 57 40 80 00 	movsbl 0x804057(%eax),%eax
  801e53:	50                   	push   %eax
  801e54:	ff d7                	call   *%edi
}
  801e56:	83 c4 10             	add    $0x10,%esp
  801e59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e5c:	5b                   	pop    %ebx
  801e5d:	5e                   	pop    %esi
  801e5e:	5f                   	pop    %edi
  801e5f:	5d                   	pop    %ebp
  801e60:	c3                   	ret    

00801e61 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e61:	83 fa 01             	cmp    $0x1,%edx
  801e64:	7f 13                	jg     801e79 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801e66:	85 d2                	test   %edx,%edx
  801e68:	74 1c                	je     801e86 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  801e6a:	8b 10                	mov    (%eax),%edx
  801e6c:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e6f:	89 08                	mov    %ecx,(%eax)
  801e71:	8b 02                	mov    (%edx),%eax
  801e73:	ba 00 00 00 00       	mov    $0x0,%edx
  801e78:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  801e79:	8b 10                	mov    (%eax),%edx
  801e7b:	8d 4a 08             	lea    0x8(%edx),%ecx
  801e7e:	89 08                	mov    %ecx,(%eax)
  801e80:	8b 02                	mov    (%edx),%eax
  801e82:	8b 52 04             	mov    0x4(%edx),%edx
  801e85:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  801e86:	8b 10                	mov    (%eax),%edx
  801e88:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e8b:	89 08                	mov    %ecx,(%eax)
  801e8d:	8b 02                	mov    (%edx),%eax
  801e8f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801e94:	c3                   	ret    

00801e95 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e95:	83 fa 01             	cmp    $0x1,%edx
  801e98:	7f 0f                	jg     801ea9 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  801e9a:	85 d2                	test   %edx,%edx
  801e9c:	74 18                	je     801eb6 <getint+0x21>
		return va_arg(*ap, long);
  801e9e:	8b 10                	mov    (%eax),%edx
  801ea0:	8d 4a 04             	lea    0x4(%edx),%ecx
  801ea3:	89 08                	mov    %ecx,(%eax)
  801ea5:	8b 02                	mov    (%edx),%eax
  801ea7:	99                   	cltd   
  801ea8:	c3                   	ret    
		return va_arg(*ap, long long);
  801ea9:	8b 10                	mov    (%eax),%edx
  801eab:	8d 4a 08             	lea    0x8(%edx),%ecx
  801eae:	89 08                	mov    %ecx,(%eax)
  801eb0:	8b 02                	mov    (%edx),%eax
  801eb2:	8b 52 04             	mov    0x4(%edx),%edx
  801eb5:	c3                   	ret    
	else
		return va_arg(*ap, int);
  801eb6:	8b 10                	mov    (%eax),%edx
  801eb8:	8d 4a 04             	lea    0x4(%edx),%ecx
  801ebb:	89 08                	mov    %ecx,(%eax)
  801ebd:	8b 02                	mov    (%edx),%eax
  801ebf:	99                   	cltd   
}
  801ec0:	c3                   	ret    

00801ec1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801ec1:	f3 0f 1e fb          	endbr32 
  801ec5:	55                   	push   %ebp
  801ec6:	89 e5                	mov    %esp,%ebp
  801ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801ecb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801ecf:	8b 10                	mov    (%eax),%edx
  801ed1:	3b 50 04             	cmp    0x4(%eax),%edx
  801ed4:	73 0a                	jae    801ee0 <sprintputch+0x1f>
		*b->buf++ = ch;
  801ed6:	8d 4a 01             	lea    0x1(%edx),%ecx
  801ed9:	89 08                	mov    %ecx,(%eax)
  801edb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ede:	88 02                	mov    %al,(%edx)
}
  801ee0:	5d                   	pop    %ebp
  801ee1:	c3                   	ret    

00801ee2 <printfmt>:
{
  801ee2:	f3 0f 1e fb          	endbr32 
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801eec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801eef:	50                   	push   %eax
  801ef0:	ff 75 10             	pushl  0x10(%ebp)
  801ef3:	ff 75 0c             	pushl  0xc(%ebp)
  801ef6:	ff 75 08             	pushl  0x8(%ebp)
  801ef9:	e8 05 00 00 00       	call   801f03 <vprintfmt>
}
  801efe:	83 c4 10             	add    $0x10,%esp
  801f01:	c9                   	leave  
  801f02:	c3                   	ret    

00801f03 <vprintfmt>:
{
  801f03:	f3 0f 1e fb          	endbr32 
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	57                   	push   %edi
  801f0b:	56                   	push   %esi
  801f0c:	53                   	push   %ebx
  801f0d:	83 ec 2c             	sub    $0x2c,%esp
  801f10:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801f13:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f16:	8b 7d 10             	mov    0x10(%ebp),%edi
  801f19:	e9 86 02 00 00       	jmp    8021a4 <vprintfmt+0x2a1>
		padc = ' ';
  801f1e:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801f22:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801f29:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801f30:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801f37:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801f3c:	8d 47 01             	lea    0x1(%edi),%eax
  801f3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f42:	0f b6 17             	movzbl (%edi),%edx
  801f45:	8d 42 dd             	lea    -0x23(%edx),%eax
  801f48:	3c 55                	cmp    $0x55,%al
  801f4a:	0f 87 df 02 00 00    	ja     80222f <vprintfmt+0x32c>
  801f50:	0f b6 c0             	movzbl %al,%eax
  801f53:	3e ff 24 85 a0 41 80 	notrack jmp *0x8041a0(,%eax,4)
  801f5a:	00 
  801f5b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801f5e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801f62:	eb d8                	jmp    801f3c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801f64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f67:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801f6b:	eb cf                	jmp    801f3c <vprintfmt+0x39>
  801f6d:	0f b6 d2             	movzbl %dl,%edx
  801f70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801f73:	b8 00 00 00 00       	mov    $0x0,%eax
  801f78:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801f7b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801f7e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801f82:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801f85:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801f88:	83 f9 09             	cmp    $0x9,%ecx
  801f8b:	77 52                	ja     801fdf <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  801f8d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801f90:	eb e9                	jmp    801f7b <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801f92:	8b 45 14             	mov    0x14(%ebp),%eax
  801f95:	8d 50 04             	lea    0x4(%eax),%edx
  801f98:	89 55 14             	mov    %edx,0x14(%ebp)
  801f9b:	8b 00                	mov    (%eax),%eax
  801f9d:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801fa0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801fa3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801fa7:	79 93                	jns    801f3c <vprintfmt+0x39>
				width = precision, precision = -1;
  801fa9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801fac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801faf:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801fb6:	eb 84                	jmp    801f3c <vprintfmt+0x39>
  801fb8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fbb:	85 c0                	test   %eax,%eax
  801fbd:	ba 00 00 00 00       	mov    $0x0,%edx
  801fc2:	0f 49 d0             	cmovns %eax,%edx
  801fc5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801fc8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801fcb:	e9 6c ff ff ff       	jmp    801f3c <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801fd0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801fd3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801fda:	e9 5d ff ff ff       	jmp    801f3c <vprintfmt+0x39>
  801fdf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801fe2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801fe5:	eb bc                	jmp    801fa3 <vprintfmt+0xa0>
			lflag++;
  801fe7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801fea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801fed:	e9 4a ff ff ff       	jmp    801f3c <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  801ff2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ff5:	8d 50 04             	lea    0x4(%eax),%edx
  801ff8:	89 55 14             	mov    %edx,0x14(%ebp)
  801ffb:	83 ec 08             	sub    $0x8,%esp
  801ffe:	56                   	push   %esi
  801fff:	ff 30                	pushl  (%eax)
  802001:	ff d3                	call   *%ebx
			break;
  802003:	83 c4 10             	add    $0x10,%esp
  802006:	e9 96 01 00 00       	jmp    8021a1 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  80200b:	8b 45 14             	mov    0x14(%ebp),%eax
  80200e:	8d 50 04             	lea    0x4(%eax),%edx
  802011:	89 55 14             	mov    %edx,0x14(%ebp)
  802014:	8b 00                	mov    (%eax),%eax
  802016:	99                   	cltd   
  802017:	31 d0                	xor    %edx,%eax
  802019:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80201b:	83 f8 0f             	cmp    $0xf,%eax
  80201e:	7f 20                	jg     802040 <vprintfmt+0x13d>
  802020:	8b 14 85 00 43 80 00 	mov    0x804300(,%eax,4),%edx
  802027:	85 d2                	test   %edx,%edx
  802029:	74 15                	je     802040 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  80202b:	52                   	push   %edx
  80202c:	68 cf 3a 80 00       	push   $0x803acf
  802031:	56                   	push   %esi
  802032:	53                   	push   %ebx
  802033:	e8 aa fe ff ff       	call   801ee2 <printfmt>
  802038:	83 c4 10             	add    $0x10,%esp
  80203b:	e9 61 01 00 00       	jmp    8021a1 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  802040:	50                   	push   %eax
  802041:	68 6f 40 80 00       	push   $0x80406f
  802046:	56                   	push   %esi
  802047:	53                   	push   %ebx
  802048:	e8 95 fe ff ff       	call   801ee2 <printfmt>
  80204d:	83 c4 10             	add    $0x10,%esp
  802050:	e9 4c 01 00 00       	jmp    8021a1 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  802055:	8b 45 14             	mov    0x14(%ebp),%eax
  802058:	8d 50 04             	lea    0x4(%eax),%edx
  80205b:	89 55 14             	mov    %edx,0x14(%ebp)
  80205e:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  802060:	85 c9                	test   %ecx,%ecx
  802062:	b8 68 40 80 00       	mov    $0x804068,%eax
  802067:	0f 45 c1             	cmovne %ecx,%eax
  80206a:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80206d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  802071:	7e 06                	jle    802079 <vprintfmt+0x176>
  802073:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  802077:	75 0d                	jne    802086 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  802079:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80207c:	89 c7                	mov    %eax,%edi
  80207e:	03 45 e0             	add    -0x20(%ebp),%eax
  802081:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802084:	eb 57                	jmp    8020dd <vprintfmt+0x1da>
  802086:	83 ec 08             	sub    $0x8,%esp
  802089:	ff 75 d8             	pushl  -0x28(%ebp)
  80208c:	ff 75 cc             	pushl  -0x34(%ebp)
  80208f:	e8 4f 02 00 00       	call   8022e3 <strnlen>
  802094:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802097:	29 c2                	sub    %eax,%edx
  802099:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80209c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80209f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8020a3:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8020a6:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8020a8:	85 db                	test   %ebx,%ebx
  8020aa:	7e 10                	jle    8020bc <vprintfmt+0x1b9>
					putch(padc, putdat);
  8020ac:	83 ec 08             	sub    $0x8,%esp
  8020af:	56                   	push   %esi
  8020b0:	57                   	push   %edi
  8020b1:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8020b4:	83 eb 01             	sub    $0x1,%ebx
  8020b7:	83 c4 10             	add    $0x10,%esp
  8020ba:	eb ec                	jmp    8020a8 <vprintfmt+0x1a5>
  8020bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020bf:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8020c2:	85 d2                	test   %edx,%edx
  8020c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c9:	0f 49 c2             	cmovns %edx,%eax
  8020cc:	29 c2                	sub    %eax,%edx
  8020ce:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8020d1:	eb a6                	jmp    802079 <vprintfmt+0x176>
					putch(ch, putdat);
  8020d3:	83 ec 08             	sub    $0x8,%esp
  8020d6:	56                   	push   %esi
  8020d7:	52                   	push   %edx
  8020d8:	ff d3                	call   *%ebx
  8020da:	83 c4 10             	add    $0x10,%esp
  8020dd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8020e0:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8020e2:	83 c7 01             	add    $0x1,%edi
  8020e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8020e9:	0f be d0             	movsbl %al,%edx
  8020ec:	85 d2                	test   %edx,%edx
  8020ee:	74 42                	je     802132 <vprintfmt+0x22f>
  8020f0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8020f4:	78 06                	js     8020fc <vprintfmt+0x1f9>
  8020f6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8020fa:	78 1e                	js     80211a <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8020fc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  802100:	74 d1                	je     8020d3 <vprintfmt+0x1d0>
  802102:	0f be c0             	movsbl %al,%eax
  802105:	83 e8 20             	sub    $0x20,%eax
  802108:	83 f8 5e             	cmp    $0x5e,%eax
  80210b:	76 c6                	jbe    8020d3 <vprintfmt+0x1d0>
					putch('?', putdat);
  80210d:	83 ec 08             	sub    $0x8,%esp
  802110:	56                   	push   %esi
  802111:	6a 3f                	push   $0x3f
  802113:	ff d3                	call   *%ebx
  802115:	83 c4 10             	add    $0x10,%esp
  802118:	eb c3                	jmp    8020dd <vprintfmt+0x1da>
  80211a:	89 cf                	mov    %ecx,%edi
  80211c:	eb 0e                	jmp    80212c <vprintfmt+0x229>
				putch(' ', putdat);
  80211e:	83 ec 08             	sub    $0x8,%esp
  802121:	56                   	push   %esi
  802122:	6a 20                	push   $0x20
  802124:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  802126:	83 ef 01             	sub    $0x1,%edi
  802129:	83 c4 10             	add    $0x10,%esp
  80212c:	85 ff                	test   %edi,%edi
  80212e:	7f ee                	jg     80211e <vprintfmt+0x21b>
  802130:	eb 6f                	jmp    8021a1 <vprintfmt+0x29e>
  802132:	89 cf                	mov    %ecx,%edi
  802134:	eb f6                	jmp    80212c <vprintfmt+0x229>
			num = getint(&ap, lflag);
  802136:	89 ca                	mov    %ecx,%edx
  802138:	8d 45 14             	lea    0x14(%ebp),%eax
  80213b:	e8 55 fd ff ff       	call   801e95 <getint>
  802140:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802143:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  802146:	85 d2                	test   %edx,%edx
  802148:	78 0b                	js     802155 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  80214a:	89 d1                	mov    %edx,%ecx
  80214c:	89 c2                	mov    %eax,%edx
			base = 10;
  80214e:	b8 0a 00 00 00       	mov    $0xa,%eax
  802153:	eb 32                	jmp    802187 <vprintfmt+0x284>
				putch('-', putdat);
  802155:	83 ec 08             	sub    $0x8,%esp
  802158:	56                   	push   %esi
  802159:	6a 2d                	push   $0x2d
  80215b:	ff d3                	call   *%ebx
				num = -(long long) num;
  80215d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  802160:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  802163:	f7 da                	neg    %edx
  802165:	83 d1 00             	adc    $0x0,%ecx
  802168:	f7 d9                	neg    %ecx
  80216a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80216d:	b8 0a 00 00 00       	mov    $0xa,%eax
  802172:	eb 13                	jmp    802187 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  802174:	89 ca                	mov    %ecx,%edx
  802176:	8d 45 14             	lea    0x14(%ebp),%eax
  802179:	e8 e3 fc ff ff       	call   801e61 <getuint>
  80217e:	89 d1                	mov    %edx,%ecx
  802180:	89 c2                	mov    %eax,%edx
			base = 10;
  802182:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  802187:	83 ec 0c             	sub    $0xc,%esp
  80218a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80218e:	57                   	push   %edi
  80218f:	ff 75 e0             	pushl  -0x20(%ebp)
  802192:	50                   	push   %eax
  802193:	51                   	push   %ecx
  802194:	52                   	push   %edx
  802195:	89 f2                	mov    %esi,%edx
  802197:	89 d8                	mov    %ebx,%eax
  802199:	e8 1a fc ff ff       	call   801db8 <printnum>
			break;
  80219e:	83 c4 20             	add    $0x20,%esp
{
  8021a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8021a4:	83 c7 01             	add    $0x1,%edi
  8021a7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8021ab:	83 f8 25             	cmp    $0x25,%eax
  8021ae:	0f 84 6a fd ff ff    	je     801f1e <vprintfmt+0x1b>
			if (ch == '\0')
  8021b4:	85 c0                	test   %eax,%eax
  8021b6:	0f 84 93 00 00 00    	je     80224f <vprintfmt+0x34c>
			putch(ch, putdat);
  8021bc:	83 ec 08             	sub    $0x8,%esp
  8021bf:	56                   	push   %esi
  8021c0:	50                   	push   %eax
  8021c1:	ff d3                	call   *%ebx
  8021c3:	83 c4 10             	add    $0x10,%esp
  8021c6:	eb dc                	jmp    8021a4 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8021c8:	89 ca                	mov    %ecx,%edx
  8021ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8021cd:	e8 8f fc ff ff       	call   801e61 <getuint>
  8021d2:	89 d1                	mov    %edx,%ecx
  8021d4:	89 c2                	mov    %eax,%edx
			base = 8;
  8021d6:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8021db:	eb aa                	jmp    802187 <vprintfmt+0x284>
			putch('0', putdat);
  8021dd:	83 ec 08             	sub    $0x8,%esp
  8021e0:	56                   	push   %esi
  8021e1:	6a 30                	push   $0x30
  8021e3:	ff d3                	call   *%ebx
			putch('x', putdat);
  8021e5:	83 c4 08             	add    $0x8,%esp
  8021e8:	56                   	push   %esi
  8021e9:	6a 78                	push   $0x78
  8021eb:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8021ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8021f0:	8d 50 04             	lea    0x4(%eax),%edx
  8021f3:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8021f6:	8b 10                	mov    (%eax),%edx
  8021f8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8021fd:	83 c4 10             	add    $0x10,%esp
			base = 16;
  802200:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  802205:	eb 80                	jmp    802187 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  802207:	89 ca                	mov    %ecx,%edx
  802209:	8d 45 14             	lea    0x14(%ebp),%eax
  80220c:	e8 50 fc ff ff       	call   801e61 <getuint>
  802211:	89 d1                	mov    %edx,%ecx
  802213:	89 c2                	mov    %eax,%edx
			base = 16;
  802215:	b8 10 00 00 00       	mov    $0x10,%eax
  80221a:	e9 68 ff ff ff       	jmp    802187 <vprintfmt+0x284>
			putch(ch, putdat);
  80221f:	83 ec 08             	sub    $0x8,%esp
  802222:	56                   	push   %esi
  802223:	6a 25                	push   $0x25
  802225:	ff d3                	call   *%ebx
			break;
  802227:	83 c4 10             	add    $0x10,%esp
  80222a:	e9 72 ff ff ff       	jmp    8021a1 <vprintfmt+0x29e>
			putch('%', putdat);
  80222f:	83 ec 08             	sub    $0x8,%esp
  802232:	56                   	push   %esi
  802233:	6a 25                	push   $0x25
  802235:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  802237:	83 c4 10             	add    $0x10,%esp
  80223a:	89 f8                	mov    %edi,%eax
  80223c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  802240:	74 05                	je     802247 <vprintfmt+0x344>
  802242:	83 e8 01             	sub    $0x1,%eax
  802245:	eb f5                	jmp    80223c <vprintfmt+0x339>
  802247:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80224a:	e9 52 ff ff ff       	jmp    8021a1 <vprintfmt+0x29e>
}
  80224f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802252:	5b                   	pop    %ebx
  802253:	5e                   	pop    %esi
  802254:	5f                   	pop    %edi
  802255:	5d                   	pop    %ebp
  802256:	c3                   	ret    

00802257 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802257:	f3 0f 1e fb          	endbr32 
  80225b:	55                   	push   %ebp
  80225c:	89 e5                	mov    %esp,%ebp
  80225e:	83 ec 18             	sub    $0x18,%esp
  802261:	8b 45 08             	mov    0x8(%ebp),%eax
  802264:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  802267:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80226a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80226e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802271:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  802278:	85 c0                	test   %eax,%eax
  80227a:	74 26                	je     8022a2 <vsnprintf+0x4b>
  80227c:	85 d2                	test   %edx,%edx
  80227e:	7e 22                	jle    8022a2 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802280:	ff 75 14             	pushl  0x14(%ebp)
  802283:	ff 75 10             	pushl  0x10(%ebp)
  802286:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802289:	50                   	push   %eax
  80228a:	68 c1 1e 80 00       	push   $0x801ec1
  80228f:	e8 6f fc ff ff       	call   801f03 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802294:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802297:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80229a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229d:	83 c4 10             	add    $0x10,%esp
}
  8022a0:	c9                   	leave  
  8022a1:	c3                   	ret    
		return -E_INVAL;
  8022a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8022a7:	eb f7                	jmp    8022a0 <vsnprintf+0x49>

008022a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8022a9:	f3 0f 1e fb          	endbr32 
  8022ad:	55                   	push   %ebp
  8022ae:	89 e5                	mov    %esp,%ebp
  8022b0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8022b3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8022b6:	50                   	push   %eax
  8022b7:	ff 75 10             	pushl  0x10(%ebp)
  8022ba:	ff 75 0c             	pushl  0xc(%ebp)
  8022bd:	ff 75 08             	pushl  0x8(%ebp)
  8022c0:	e8 92 ff ff ff       	call   802257 <vsnprintf>
	va_end(ap);

	return rc;
}
  8022c5:	c9                   	leave  
  8022c6:	c3                   	ret    

008022c7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8022c7:	f3 0f 1e fb          	endbr32 
  8022cb:	55                   	push   %ebp
  8022cc:	89 e5                	mov    %esp,%ebp
  8022ce:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8022d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8022da:	74 05                	je     8022e1 <strlen+0x1a>
		n++;
  8022dc:	83 c0 01             	add    $0x1,%eax
  8022df:	eb f5                	jmp    8022d6 <strlen+0xf>
	return n;
}
  8022e1:	5d                   	pop    %ebp
  8022e2:	c3                   	ret    

008022e3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8022e3:	f3 0f 1e fb          	endbr32 
  8022e7:	55                   	push   %ebp
  8022e8:	89 e5                	mov    %esp,%ebp
  8022ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8022f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8022f5:	39 d0                	cmp    %edx,%eax
  8022f7:	74 0d                	je     802306 <strnlen+0x23>
  8022f9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8022fd:	74 05                	je     802304 <strnlen+0x21>
		n++;
  8022ff:	83 c0 01             	add    $0x1,%eax
  802302:	eb f1                	jmp    8022f5 <strnlen+0x12>
  802304:	89 c2                	mov    %eax,%edx
	return n;
}
  802306:	89 d0                	mov    %edx,%eax
  802308:	5d                   	pop    %ebp
  802309:	c3                   	ret    

0080230a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80230a:	f3 0f 1e fb          	endbr32 
  80230e:	55                   	push   %ebp
  80230f:	89 e5                	mov    %esp,%ebp
  802311:	53                   	push   %ebx
  802312:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802315:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802318:	b8 00 00 00 00       	mov    $0x0,%eax
  80231d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  802321:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  802324:	83 c0 01             	add    $0x1,%eax
  802327:	84 d2                	test   %dl,%dl
  802329:	75 f2                	jne    80231d <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80232b:	89 c8                	mov    %ecx,%eax
  80232d:	5b                   	pop    %ebx
  80232e:	5d                   	pop    %ebp
  80232f:	c3                   	ret    

00802330 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802330:	f3 0f 1e fb          	endbr32 
  802334:	55                   	push   %ebp
  802335:	89 e5                	mov    %esp,%ebp
  802337:	53                   	push   %ebx
  802338:	83 ec 10             	sub    $0x10,%esp
  80233b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80233e:	53                   	push   %ebx
  80233f:	e8 83 ff ff ff       	call   8022c7 <strlen>
  802344:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  802347:	ff 75 0c             	pushl  0xc(%ebp)
  80234a:	01 d8                	add    %ebx,%eax
  80234c:	50                   	push   %eax
  80234d:	e8 b8 ff ff ff       	call   80230a <strcpy>
	return dst;
}
  802352:	89 d8                	mov    %ebx,%eax
  802354:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802357:	c9                   	leave  
  802358:	c3                   	ret    

00802359 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802359:	f3 0f 1e fb          	endbr32 
  80235d:	55                   	push   %ebp
  80235e:	89 e5                	mov    %esp,%ebp
  802360:	56                   	push   %esi
  802361:	53                   	push   %ebx
  802362:	8b 75 08             	mov    0x8(%ebp),%esi
  802365:	8b 55 0c             	mov    0xc(%ebp),%edx
  802368:	89 f3                	mov    %esi,%ebx
  80236a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80236d:	89 f0                	mov    %esi,%eax
  80236f:	39 d8                	cmp    %ebx,%eax
  802371:	74 11                	je     802384 <strncpy+0x2b>
		*dst++ = *src;
  802373:	83 c0 01             	add    $0x1,%eax
  802376:	0f b6 0a             	movzbl (%edx),%ecx
  802379:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80237c:	80 f9 01             	cmp    $0x1,%cl
  80237f:	83 da ff             	sbb    $0xffffffff,%edx
  802382:	eb eb                	jmp    80236f <strncpy+0x16>
	}
	return ret;
}
  802384:	89 f0                	mov    %esi,%eax
  802386:	5b                   	pop    %ebx
  802387:	5e                   	pop    %esi
  802388:	5d                   	pop    %ebp
  802389:	c3                   	ret    

0080238a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80238a:	f3 0f 1e fb          	endbr32 
  80238e:	55                   	push   %ebp
  80238f:	89 e5                	mov    %esp,%ebp
  802391:	56                   	push   %esi
  802392:	53                   	push   %ebx
  802393:	8b 75 08             	mov    0x8(%ebp),%esi
  802396:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802399:	8b 55 10             	mov    0x10(%ebp),%edx
  80239c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80239e:	85 d2                	test   %edx,%edx
  8023a0:	74 21                	je     8023c3 <strlcpy+0x39>
  8023a2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8023a6:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8023a8:	39 c2                	cmp    %eax,%edx
  8023aa:	74 14                	je     8023c0 <strlcpy+0x36>
  8023ac:	0f b6 19             	movzbl (%ecx),%ebx
  8023af:	84 db                	test   %bl,%bl
  8023b1:	74 0b                	je     8023be <strlcpy+0x34>
			*dst++ = *src++;
  8023b3:	83 c1 01             	add    $0x1,%ecx
  8023b6:	83 c2 01             	add    $0x1,%edx
  8023b9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8023bc:	eb ea                	jmp    8023a8 <strlcpy+0x1e>
  8023be:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8023c0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8023c3:	29 f0                	sub    %esi,%eax
}
  8023c5:	5b                   	pop    %ebx
  8023c6:	5e                   	pop    %esi
  8023c7:	5d                   	pop    %ebp
  8023c8:	c3                   	ret    

008023c9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8023c9:	f3 0f 1e fb          	endbr32 
  8023cd:	55                   	push   %ebp
  8023ce:	89 e5                	mov    %esp,%ebp
  8023d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8023d6:	0f b6 01             	movzbl (%ecx),%eax
  8023d9:	84 c0                	test   %al,%al
  8023db:	74 0c                	je     8023e9 <strcmp+0x20>
  8023dd:	3a 02                	cmp    (%edx),%al
  8023df:	75 08                	jne    8023e9 <strcmp+0x20>
		p++, q++;
  8023e1:	83 c1 01             	add    $0x1,%ecx
  8023e4:	83 c2 01             	add    $0x1,%edx
  8023e7:	eb ed                	jmp    8023d6 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8023e9:	0f b6 c0             	movzbl %al,%eax
  8023ec:	0f b6 12             	movzbl (%edx),%edx
  8023ef:	29 d0                	sub    %edx,%eax
}
  8023f1:	5d                   	pop    %ebp
  8023f2:	c3                   	ret    

008023f3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8023f3:	f3 0f 1e fb          	endbr32 
  8023f7:	55                   	push   %ebp
  8023f8:	89 e5                	mov    %esp,%ebp
  8023fa:	53                   	push   %ebx
  8023fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  802401:	89 c3                	mov    %eax,%ebx
  802403:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  802406:	eb 06                	jmp    80240e <strncmp+0x1b>
		n--, p++, q++;
  802408:	83 c0 01             	add    $0x1,%eax
  80240b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80240e:	39 d8                	cmp    %ebx,%eax
  802410:	74 16                	je     802428 <strncmp+0x35>
  802412:	0f b6 08             	movzbl (%eax),%ecx
  802415:	84 c9                	test   %cl,%cl
  802417:	74 04                	je     80241d <strncmp+0x2a>
  802419:	3a 0a                	cmp    (%edx),%cl
  80241b:	74 eb                	je     802408 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80241d:	0f b6 00             	movzbl (%eax),%eax
  802420:	0f b6 12             	movzbl (%edx),%edx
  802423:	29 d0                	sub    %edx,%eax
}
  802425:	5b                   	pop    %ebx
  802426:	5d                   	pop    %ebp
  802427:	c3                   	ret    
		return 0;
  802428:	b8 00 00 00 00       	mov    $0x0,%eax
  80242d:	eb f6                	jmp    802425 <strncmp+0x32>

0080242f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80242f:	f3 0f 1e fb          	endbr32 
  802433:	55                   	push   %ebp
  802434:	89 e5                	mov    %esp,%ebp
  802436:	8b 45 08             	mov    0x8(%ebp),%eax
  802439:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80243d:	0f b6 10             	movzbl (%eax),%edx
  802440:	84 d2                	test   %dl,%dl
  802442:	74 09                	je     80244d <strchr+0x1e>
		if (*s == c)
  802444:	38 ca                	cmp    %cl,%dl
  802446:	74 0a                	je     802452 <strchr+0x23>
	for (; *s; s++)
  802448:	83 c0 01             	add    $0x1,%eax
  80244b:	eb f0                	jmp    80243d <strchr+0xe>
			return (char *) s;
	return 0;
  80244d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802452:	5d                   	pop    %ebp
  802453:	c3                   	ret    

00802454 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802454:	f3 0f 1e fb          	endbr32 
  802458:	55                   	push   %ebp
  802459:	89 e5                	mov    %esp,%ebp
  80245b:	8b 45 08             	mov    0x8(%ebp),%eax
  80245e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802462:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  802465:	38 ca                	cmp    %cl,%dl
  802467:	74 09                	je     802472 <strfind+0x1e>
  802469:	84 d2                	test   %dl,%dl
  80246b:	74 05                	je     802472 <strfind+0x1e>
	for (; *s; s++)
  80246d:	83 c0 01             	add    $0x1,%eax
  802470:	eb f0                	jmp    802462 <strfind+0xe>
			break;
	return (char *) s;
}
  802472:	5d                   	pop    %ebp
  802473:	c3                   	ret    

00802474 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802474:	f3 0f 1e fb          	endbr32 
  802478:	55                   	push   %ebp
  802479:	89 e5                	mov    %esp,%ebp
  80247b:	57                   	push   %edi
  80247c:	56                   	push   %esi
  80247d:	53                   	push   %ebx
  80247e:	8b 55 08             	mov    0x8(%ebp),%edx
  802481:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  802484:	85 c9                	test   %ecx,%ecx
  802486:	74 33                	je     8024bb <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802488:	89 d0                	mov    %edx,%eax
  80248a:	09 c8                	or     %ecx,%eax
  80248c:	a8 03                	test   $0x3,%al
  80248e:	75 23                	jne    8024b3 <memset+0x3f>
		c &= 0xFF;
  802490:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802494:	89 d8                	mov    %ebx,%eax
  802496:	c1 e0 08             	shl    $0x8,%eax
  802499:	89 df                	mov    %ebx,%edi
  80249b:	c1 e7 18             	shl    $0x18,%edi
  80249e:	89 de                	mov    %ebx,%esi
  8024a0:	c1 e6 10             	shl    $0x10,%esi
  8024a3:	09 f7                	or     %esi,%edi
  8024a5:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  8024a7:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8024aa:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8024ac:	89 d7                	mov    %edx,%edi
  8024ae:	fc                   	cld    
  8024af:	f3 ab                	rep stos %eax,%es:(%edi)
  8024b1:	eb 08                	jmp    8024bb <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8024b3:	89 d7                	mov    %edx,%edi
  8024b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024b8:	fc                   	cld    
  8024b9:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8024bb:	89 d0                	mov    %edx,%eax
  8024bd:	5b                   	pop    %ebx
  8024be:	5e                   	pop    %esi
  8024bf:	5f                   	pop    %edi
  8024c0:	5d                   	pop    %ebp
  8024c1:	c3                   	ret    

008024c2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8024c2:	f3 0f 1e fb          	endbr32 
  8024c6:	55                   	push   %ebp
  8024c7:	89 e5                	mov    %esp,%ebp
  8024c9:	57                   	push   %edi
  8024ca:	56                   	push   %esi
  8024cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ce:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8024d4:	39 c6                	cmp    %eax,%esi
  8024d6:	73 32                	jae    80250a <memmove+0x48>
  8024d8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8024db:	39 c2                	cmp    %eax,%edx
  8024dd:	76 2b                	jbe    80250a <memmove+0x48>
		s += n;
		d += n;
  8024df:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8024e2:	89 fe                	mov    %edi,%esi
  8024e4:	09 ce                	or     %ecx,%esi
  8024e6:	09 d6                	or     %edx,%esi
  8024e8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8024ee:	75 0e                	jne    8024fe <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8024f0:	83 ef 04             	sub    $0x4,%edi
  8024f3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8024f6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8024f9:	fd                   	std    
  8024fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8024fc:	eb 09                	jmp    802507 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8024fe:	83 ef 01             	sub    $0x1,%edi
  802501:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  802504:	fd                   	std    
  802505:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802507:	fc                   	cld    
  802508:	eb 1a                	jmp    802524 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80250a:	89 c2                	mov    %eax,%edx
  80250c:	09 ca                	or     %ecx,%edx
  80250e:	09 f2                	or     %esi,%edx
  802510:	f6 c2 03             	test   $0x3,%dl
  802513:	75 0a                	jne    80251f <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  802515:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  802518:	89 c7                	mov    %eax,%edi
  80251a:	fc                   	cld    
  80251b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80251d:	eb 05                	jmp    802524 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  80251f:	89 c7                	mov    %eax,%edi
  802521:	fc                   	cld    
  802522:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802524:	5e                   	pop    %esi
  802525:	5f                   	pop    %edi
  802526:	5d                   	pop    %ebp
  802527:	c3                   	ret    

00802528 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  802528:	f3 0f 1e fb          	endbr32 
  80252c:	55                   	push   %ebp
  80252d:	89 e5                	mov    %esp,%ebp
  80252f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  802532:	ff 75 10             	pushl  0x10(%ebp)
  802535:	ff 75 0c             	pushl  0xc(%ebp)
  802538:	ff 75 08             	pushl  0x8(%ebp)
  80253b:	e8 82 ff ff ff       	call   8024c2 <memmove>
}
  802540:	c9                   	leave  
  802541:	c3                   	ret    

00802542 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802542:	f3 0f 1e fb          	endbr32 
  802546:	55                   	push   %ebp
  802547:	89 e5                	mov    %esp,%ebp
  802549:	56                   	push   %esi
  80254a:	53                   	push   %ebx
  80254b:	8b 45 08             	mov    0x8(%ebp),%eax
  80254e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802551:	89 c6                	mov    %eax,%esi
  802553:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802556:	39 f0                	cmp    %esi,%eax
  802558:	74 1c                	je     802576 <memcmp+0x34>
		if (*s1 != *s2)
  80255a:	0f b6 08             	movzbl (%eax),%ecx
  80255d:	0f b6 1a             	movzbl (%edx),%ebx
  802560:	38 d9                	cmp    %bl,%cl
  802562:	75 08                	jne    80256c <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  802564:	83 c0 01             	add    $0x1,%eax
  802567:	83 c2 01             	add    $0x1,%edx
  80256a:	eb ea                	jmp    802556 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  80256c:	0f b6 c1             	movzbl %cl,%eax
  80256f:	0f b6 db             	movzbl %bl,%ebx
  802572:	29 d8                	sub    %ebx,%eax
  802574:	eb 05                	jmp    80257b <memcmp+0x39>
	}

	return 0;
  802576:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80257b:	5b                   	pop    %ebx
  80257c:	5e                   	pop    %esi
  80257d:	5d                   	pop    %ebp
  80257e:	c3                   	ret    

0080257f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80257f:	f3 0f 1e fb          	endbr32 
  802583:	55                   	push   %ebp
  802584:	89 e5                	mov    %esp,%ebp
  802586:	8b 45 08             	mov    0x8(%ebp),%eax
  802589:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80258c:	89 c2                	mov    %eax,%edx
  80258e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802591:	39 d0                	cmp    %edx,%eax
  802593:	73 09                	jae    80259e <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  802595:	38 08                	cmp    %cl,(%eax)
  802597:	74 05                	je     80259e <memfind+0x1f>
	for (; s < ends; s++)
  802599:	83 c0 01             	add    $0x1,%eax
  80259c:	eb f3                	jmp    802591 <memfind+0x12>
			break;
	return (void *) s;
}
  80259e:	5d                   	pop    %ebp
  80259f:	c3                   	ret    

008025a0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8025a0:	f3 0f 1e fb          	endbr32 
  8025a4:	55                   	push   %ebp
  8025a5:	89 e5                	mov    %esp,%ebp
  8025a7:	57                   	push   %edi
  8025a8:	56                   	push   %esi
  8025a9:	53                   	push   %ebx
  8025aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8025ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8025b0:	eb 03                	jmp    8025b5 <strtol+0x15>
		s++;
  8025b2:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8025b5:	0f b6 01             	movzbl (%ecx),%eax
  8025b8:	3c 20                	cmp    $0x20,%al
  8025ba:	74 f6                	je     8025b2 <strtol+0x12>
  8025bc:	3c 09                	cmp    $0x9,%al
  8025be:	74 f2                	je     8025b2 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  8025c0:	3c 2b                	cmp    $0x2b,%al
  8025c2:	74 2a                	je     8025ee <strtol+0x4e>
	int neg = 0;
  8025c4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8025c9:	3c 2d                	cmp    $0x2d,%al
  8025cb:	74 2b                	je     8025f8 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8025cd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8025d3:	75 0f                	jne    8025e4 <strtol+0x44>
  8025d5:	80 39 30             	cmpb   $0x30,(%ecx)
  8025d8:	74 28                	je     802602 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8025da:	85 db                	test   %ebx,%ebx
  8025dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8025e1:	0f 44 d8             	cmove  %eax,%ebx
  8025e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8025e9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8025ec:	eb 46                	jmp    802634 <strtol+0x94>
		s++;
  8025ee:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8025f1:	bf 00 00 00 00       	mov    $0x0,%edi
  8025f6:	eb d5                	jmp    8025cd <strtol+0x2d>
		s++, neg = 1;
  8025f8:	83 c1 01             	add    $0x1,%ecx
  8025fb:	bf 01 00 00 00       	mov    $0x1,%edi
  802600:	eb cb                	jmp    8025cd <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802602:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  802606:	74 0e                	je     802616 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  802608:	85 db                	test   %ebx,%ebx
  80260a:	75 d8                	jne    8025e4 <strtol+0x44>
		s++, base = 8;
  80260c:	83 c1 01             	add    $0x1,%ecx
  80260f:	bb 08 00 00 00       	mov    $0x8,%ebx
  802614:	eb ce                	jmp    8025e4 <strtol+0x44>
		s += 2, base = 16;
  802616:	83 c1 02             	add    $0x2,%ecx
  802619:	bb 10 00 00 00       	mov    $0x10,%ebx
  80261e:	eb c4                	jmp    8025e4 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  802620:	0f be d2             	movsbl %dl,%edx
  802623:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  802626:	3b 55 10             	cmp    0x10(%ebp),%edx
  802629:	7d 3a                	jge    802665 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  80262b:	83 c1 01             	add    $0x1,%ecx
  80262e:	0f af 45 10          	imul   0x10(%ebp),%eax
  802632:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  802634:	0f b6 11             	movzbl (%ecx),%edx
  802637:	8d 72 d0             	lea    -0x30(%edx),%esi
  80263a:	89 f3                	mov    %esi,%ebx
  80263c:	80 fb 09             	cmp    $0x9,%bl
  80263f:	76 df                	jbe    802620 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  802641:	8d 72 9f             	lea    -0x61(%edx),%esi
  802644:	89 f3                	mov    %esi,%ebx
  802646:	80 fb 19             	cmp    $0x19,%bl
  802649:	77 08                	ja     802653 <strtol+0xb3>
			dig = *s - 'a' + 10;
  80264b:	0f be d2             	movsbl %dl,%edx
  80264e:	83 ea 57             	sub    $0x57,%edx
  802651:	eb d3                	jmp    802626 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  802653:	8d 72 bf             	lea    -0x41(%edx),%esi
  802656:	89 f3                	mov    %esi,%ebx
  802658:	80 fb 19             	cmp    $0x19,%bl
  80265b:	77 08                	ja     802665 <strtol+0xc5>
			dig = *s - 'A' + 10;
  80265d:	0f be d2             	movsbl %dl,%edx
  802660:	83 ea 37             	sub    $0x37,%edx
  802663:	eb c1                	jmp    802626 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  802665:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802669:	74 05                	je     802670 <strtol+0xd0>
		*endptr = (char *) s;
  80266b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80266e:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  802670:	89 c2                	mov    %eax,%edx
  802672:	f7 da                	neg    %edx
  802674:	85 ff                	test   %edi,%edi
  802676:	0f 45 c2             	cmovne %edx,%eax
}
  802679:	5b                   	pop    %ebx
  80267a:	5e                   	pop    %esi
  80267b:	5f                   	pop    %edi
  80267c:	5d                   	pop    %ebp
  80267d:	c3                   	ret    

0080267e <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80267e:	55                   	push   %ebp
  80267f:	89 e5                	mov    %esp,%ebp
  802681:	57                   	push   %edi
  802682:	56                   	push   %esi
  802683:	53                   	push   %ebx
  802684:	83 ec 1c             	sub    $0x1c,%esp
  802687:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80268a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80268d:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80268f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802692:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802695:	8b 7d 10             	mov    0x10(%ebp),%edi
  802698:	8b 75 14             	mov    0x14(%ebp),%esi
  80269b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80269d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8026a1:	74 04                	je     8026a7 <syscall+0x29>
  8026a3:	85 c0                	test   %eax,%eax
  8026a5:	7f 08                	jg     8026af <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8026a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026aa:	5b                   	pop    %ebx
  8026ab:	5e                   	pop    %esi
  8026ac:	5f                   	pop    %edi
  8026ad:	5d                   	pop    %ebp
  8026ae:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8026af:	83 ec 0c             	sub    $0xc,%esp
  8026b2:	50                   	push   %eax
  8026b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8026b6:	68 5f 43 80 00       	push   $0x80435f
  8026bb:	6a 23                	push   $0x23
  8026bd:	68 7c 43 80 00       	push   $0x80437c
  8026c2:	e8 f2 f5 ff ff       	call   801cb9 <_panic>

008026c7 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8026c7:	f3 0f 1e fb          	endbr32 
  8026cb:	55                   	push   %ebp
  8026cc:	89 e5                	mov    %esp,%ebp
  8026ce:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8026d1:	6a 00                	push   $0x0
  8026d3:	6a 00                	push   $0x0
  8026d5:	6a 00                	push   $0x0
  8026d7:	ff 75 0c             	pushl  0xc(%ebp)
  8026da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8026e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8026e7:	e8 92 ff ff ff       	call   80267e <syscall>
}
  8026ec:	83 c4 10             	add    $0x10,%esp
  8026ef:	c9                   	leave  
  8026f0:	c3                   	ret    

008026f1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8026f1:	f3 0f 1e fb          	endbr32 
  8026f5:	55                   	push   %ebp
  8026f6:	89 e5                	mov    %esp,%ebp
  8026f8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8026fb:	6a 00                	push   $0x0
  8026fd:	6a 00                	push   $0x0
  8026ff:	6a 00                	push   $0x0
  802701:	6a 00                	push   $0x0
  802703:	b9 00 00 00 00       	mov    $0x0,%ecx
  802708:	ba 00 00 00 00       	mov    $0x0,%edx
  80270d:	b8 01 00 00 00       	mov    $0x1,%eax
  802712:	e8 67 ff ff ff       	call   80267e <syscall>
}
  802717:	c9                   	leave  
  802718:	c3                   	ret    

00802719 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802719:	f3 0f 1e fb          	endbr32 
  80271d:	55                   	push   %ebp
  80271e:	89 e5                	mov    %esp,%ebp
  802720:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  802723:	6a 00                	push   $0x0
  802725:	6a 00                	push   $0x0
  802727:	6a 00                	push   $0x0
  802729:	6a 00                	push   $0x0
  80272b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80272e:	ba 01 00 00 00       	mov    $0x1,%edx
  802733:	b8 03 00 00 00       	mov    $0x3,%eax
  802738:	e8 41 ff ff ff       	call   80267e <syscall>
}
  80273d:	c9                   	leave  
  80273e:	c3                   	ret    

0080273f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80273f:	f3 0f 1e fb          	endbr32 
  802743:	55                   	push   %ebp
  802744:	89 e5                	mov    %esp,%ebp
  802746:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  802749:	6a 00                	push   $0x0
  80274b:	6a 00                	push   $0x0
  80274d:	6a 00                	push   $0x0
  80274f:	6a 00                	push   $0x0
  802751:	b9 00 00 00 00       	mov    $0x0,%ecx
  802756:	ba 00 00 00 00       	mov    $0x0,%edx
  80275b:	b8 02 00 00 00       	mov    $0x2,%eax
  802760:	e8 19 ff ff ff       	call   80267e <syscall>
}
  802765:	c9                   	leave  
  802766:	c3                   	ret    

00802767 <sys_yield>:

void
sys_yield(void)
{
  802767:	f3 0f 1e fb          	endbr32 
  80276b:	55                   	push   %ebp
  80276c:	89 e5                	mov    %esp,%ebp
  80276e:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  802771:	6a 00                	push   $0x0
  802773:	6a 00                	push   $0x0
  802775:	6a 00                	push   $0x0
  802777:	6a 00                	push   $0x0
  802779:	b9 00 00 00 00       	mov    $0x0,%ecx
  80277e:	ba 00 00 00 00       	mov    $0x0,%edx
  802783:	b8 0b 00 00 00       	mov    $0xb,%eax
  802788:	e8 f1 fe ff ff       	call   80267e <syscall>
}
  80278d:	83 c4 10             	add    $0x10,%esp
  802790:	c9                   	leave  
  802791:	c3                   	ret    

00802792 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802792:	f3 0f 1e fb          	endbr32 
  802796:	55                   	push   %ebp
  802797:	89 e5                	mov    %esp,%ebp
  802799:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80279c:	6a 00                	push   $0x0
  80279e:	6a 00                	push   $0x0
  8027a0:	ff 75 10             	pushl  0x10(%ebp)
  8027a3:	ff 75 0c             	pushl  0xc(%ebp)
  8027a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8027a9:	ba 01 00 00 00       	mov    $0x1,%edx
  8027ae:	b8 04 00 00 00       	mov    $0x4,%eax
  8027b3:	e8 c6 fe ff ff       	call   80267e <syscall>
}
  8027b8:	c9                   	leave  
  8027b9:	c3                   	ret    

008027ba <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8027ba:	f3 0f 1e fb          	endbr32 
  8027be:	55                   	push   %ebp
  8027bf:	89 e5                	mov    %esp,%ebp
  8027c1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8027c4:	ff 75 18             	pushl  0x18(%ebp)
  8027c7:	ff 75 14             	pushl  0x14(%ebp)
  8027ca:	ff 75 10             	pushl  0x10(%ebp)
  8027cd:	ff 75 0c             	pushl  0xc(%ebp)
  8027d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8027d3:	ba 01 00 00 00       	mov    $0x1,%edx
  8027d8:	b8 05 00 00 00       	mov    $0x5,%eax
  8027dd:	e8 9c fe ff ff       	call   80267e <syscall>
}
  8027e2:	c9                   	leave  
  8027e3:	c3                   	ret    

008027e4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8027e4:	f3 0f 1e fb          	endbr32 
  8027e8:	55                   	push   %ebp
  8027e9:	89 e5                	mov    %esp,%ebp
  8027eb:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8027ee:	6a 00                	push   $0x0
  8027f0:	6a 00                	push   $0x0
  8027f2:	6a 00                	push   $0x0
  8027f4:	ff 75 0c             	pushl  0xc(%ebp)
  8027f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8027fa:	ba 01 00 00 00       	mov    $0x1,%edx
  8027ff:	b8 06 00 00 00       	mov    $0x6,%eax
  802804:	e8 75 fe ff ff       	call   80267e <syscall>
}
  802809:	c9                   	leave  
  80280a:	c3                   	ret    

0080280b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80280b:	f3 0f 1e fb          	endbr32 
  80280f:	55                   	push   %ebp
  802810:	89 e5                	mov    %esp,%ebp
  802812:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  802815:	6a 00                	push   $0x0
  802817:	6a 00                	push   $0x0
  802819:	6a 00                	push   $0x0
  80281b:	ff 75 0c             	pushl  0xc(%ebp)
  80281e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802821:	ba 01 00 00 00       	mov    $0x1,%edx
  802826:	b8 08 00 00 00       	mov    $0x8,%eax
  80282b:	e8 4e fe ff ff       	call   80267e <syscall>
}
  802830:	c9                   	leave  
  802831:	c3                   	ret    

00802832 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802832:	f3 0f 1e fb          	endbr32 
  802836:	55                   	push   %ebp
  802837:	89 e5                	mov    %esp,%ebp
  802839:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80283c:	6a 00                	push   $0x0
  80283e:	6a 00                	push   $0x0
  802840:	6a 00                	push   $0x0
  802842:	ff 75 0c             	pushl  0xc(%ebp)
  802845:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802848:	ba 01 00 00 00       	mov    $0x1,%edx
  80284d:	b8 09 00 00 00       	mov    $0x9,%eax
  802852:	e8 27 fe ff ff       	call   80267e <syscall>
}
  802857:	c9                   	leave  
  802858:	c3                   	ret    

00802859 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802859:	f3 0f 1e fb          	endbr32 
  80285d:	55                   	push   %ebp
  80285e:	89 e5                	mov    %esp,%ebp
  802860:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  802863:	6a 00                	push   $0x0
  802865:	6a 00                	push   $0x0
  802867:	6a 00                	push   $0x0
  802869:	ff 75 0c             	pushl  0xc(%ebp)
  80286c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80286f:	ba 01 00 00 00       	mov    $0x1,%edx
  802874:	b8 0a 00 00 00       	mov    $0xa,%eax
  802879:	e8 00 fe ff ff       	call   80267e <syscall>
}
  80287e:	c9                   	leave  
  80287f:	c3                   	ret    

00802880 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802880:	f3 0f 1e fb          	endbr32 
  802884:	55                   	push   %ebp
  802885:	89 e5                	mov    %esp,%ebp
  802887:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80288a:	6a 00                	push   $0x0
  80288c:	ff 75 14             	pushl  0x14(%ebp)
  80288f:	ff 75 10             	pushl  0x10(%ebp)
  802892:	ff 75 0c             	pushl  0xc(%ebp)
  802895:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802898:	ba 00 00 00 00       	mov    $0x0,%edx
  80289d:	b8 0c 00 00 00       	mov    $0xc,%eax
  8028a2:	e8 d7 fd ff ff       	call   80267e <syscall>
}
  8028a7:	c9                   	leave  
  8028a8:	c3                   	ret    

008028a9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8028a9:	f3 0f 1e fb          	endbr32 
  8028ad:	55                   	push   %ebp
  8028ae:	89 e5                	mov    %esp,%ebp
  8028b0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8028b3:	6a 00                	push   $0x0
  8028b5:	6a 00                	push   $0x0
  8028b7:	6a 00                	push   $0x0
  8028b9:	6a 00                	push   $0x0
  8028bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8028be:	ba 01 00 00 00       	mov    $0x1,%edx
  8028c3:	b8 0d 00 00 00       	mov    $0xd,%eax
  8028c8:	e8 b1 fd ff ff       	call   80267e <syscall>
}
  8028cd:	c9                   	leave  
  8028ce:	c3                   	ret    

008028cf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8028cf:	f3 0f 1e fb          	endbr32 
  8028d3:	55                   	push   %ebp
  8028d4:	89 e5                	mov    %esp,%ebp
  8028d6:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  8028d9:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  8028e0:	74 0a                	je     8028ec <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8028e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8028e5:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  8028ea:	c9                   	leave  
  8028eb:	c3                   	ret    
		if (sys_page_alloc(0,
  8028ec:	83 ec 04             	sub    $0x4,%esp
  8028ef:	6a 07                	push   $0x7
  8028f1:	68 00 f0 bf ee       	push   $0xeebff000
  8028f6:	6a 00                	push   $0x0
  8028f8:	e8 95 fe ff ff       	call   802792 <sys_page_alloc>
  8028fd:	83 c4 10             	add    $0x10,%esp
  802900:	85 c0                	test   %eax,%eax
  802902:	78 2a                	js     80292e <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  802904:	83 ec 08             	sub    $0x8,%esp
  802907:	68 42 29 80 00       	push   $0x802942
  80290c:	6a 00                	push   $0x0
  80290e:	e8 46 ff ff ff       	call   802859 <sys_env_set_pgfault_upcall>
  802913:	83 c4 10             	add    $0x10,%esp
  802916:	85 c0                	test   %eax,%eax
  802918:	79 c8                	jns    8028e2 <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  80291a:	83 ec 04             	sub    $0x4,%esp
  80291d:	68 c0 43 80 00       	push   $0x8043c0
  802922:	6a 25                	push   $0x25
  802924:	68 07 44 80 00       	push   $0x804407
  802929:	e8 8b f3 ff ff       	call   801cb9 <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  80292e:	83 ec 04             	sub    $0x4,%esp
  802931:	68 8c 43 80 00       	push   $0x80438c
  802936:	6a 21                	push   $0x21
  802938:	68 07 44 80 00       	push   $0x804407
  80293d:	e8 77 f3 ff ff       	call   801cb9 <_panic>

00802942 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802942:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802943:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  802948:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80294a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  80294d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  802952:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  802956:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80295a:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  80295c:	83 c4 08             	add    $0x8,%esp
	popal
  80295f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  802960:	83 c4 04             	add    $0x4,%esp
	popfl
  802963:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  802964:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802967:	c3                   	ret    

00802968 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802968:	f3 0f 1e fb          	endbr32 
  80296c:	55                   	push   %ebp
  80296d:	89 e5                	mov    %esp,%ebp
  80296f:	56                   	push   %esi
  802970:	53                   	push   %ebx
  802971:	8b 75 08             	mov    0x8(%ebp),%esi
  802974:	8b 45 0c             	mov    0xc(%ebp),%eax
  802977:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  80297a:	85 c0                	test   %eax,%eax
  80297c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802981:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  802984:	83 ec 0c             	sub    $0xc,%esp
  802987:	50                   	push   %eax
  802988:	e8 1c ff ff ff       	call   8028a9 <sys_ipc_recv>
	if (f < 0) {
  80298d:	83 c4 10             	add    $0x10,%esp
  802990:	85 c0                	test   %eax,%eax
  802992:	78 2b                	js     8029bf <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  802994:	85 f6                	test   %esi,%esi
  802996:	74 0a                	je     8029a2 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  802998:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80299d:	8b 40 74             	mov    0x74(%eax),%eax
  8029a0:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  8029a2:	85 db                	test   %ebx,%ebx
  8029a4:	74 0a                	je     8029b0 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  8029a6:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8029ab:	8b 40 78             	mov    0x78(%eax),%eax
  8029ae:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  8029b0:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8029b5:	8b 40 70             	mov    0x70(%eax),%eax
}
  8029b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029bb:	5b                   	pop    %ebx
  8029bc:	5e                   	pop    %esi
  8029bd:	5d                   	pop    %ebp
  8029be:	c3                   	ret    
		if (from_env_store != NULL) {
  8029bf:	85 f6                	test   %esi,%esi
  8029c1:	74 06                	je     8029c9 <ipc_recv+0x61>
			*from_env_store = 0;
  8029c3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  8029c9:	85 db                	test   %ebx,%ebx
  8029cb:	74 eb                	je     8029b8 <ipc_recv+0x50>
			*perm_store = 0;
  8029cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8029d3:	eb e3                	jmp    8029b8 <ipc_recv+0x50>

008029d5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8029d5:	f3 0f 1e fb          	endbr32 
  8029d9:	55                   	push   %ebp
  8029da:	89 e5                	mov    %esp,%ebp
  8029dc:	57                   	push   %edi
  8029dd:	56                   	push   %esi
  8029de:	53                   	push   %ebx
  8029df:	83 ec 0c             	sub    $0xc,%esp
  8029e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8029e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8029e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  8029eb:	85 db                	test   %ebx,%ebx
  8029ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8029f2:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8029f5:	ff 75 14             	pushl  0x14(%ebp)
  8029f8:	53                   	push   %ebx
  8029f9:	56                   	push   %esi
  8029fa:	57                   	push   %edi
  8029fb:	e8 80 fe ff ff       	call   802880 <sys_ipc_try_send>
  802a00:	83 c4 10             	add    $0x10,%esp
  802a03:	85 c0                	test   %eax,%eax
  802a05:	79 19                	jns    802a20 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  802a07:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802a0a:	74 e9                	je     8029f5 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  802a0c:	83 ec 04             	sub    $0x4,%esp
  802a0f:	68 18 44 80 00       	push   $0x804418
  802a14:	6a 48                	push   $0x48
  802a16:	68 3a 44 80 00       	push   $0x80443a
  802a1b:	e8 99 f2 ff ff       	call   801cb9 <_panic>
		}
	}
}
  802a20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a23:	5b                   	pop    %ebx
  802a24:	5e                   	pop    %esi
  802a25:	5f                   	pop    %edi
  802a26:	5d                   	pop    %ebp
  802a27:	c3                   	ret    

00802a28 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802a28:	f3 0f 1e fb          	endbr32 
  802a2c:	55                   	push   %ebp
  802a2d:	89 e5                	mov    %esp,%ebp
  802a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802a32:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802a37:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802a3a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802a40:	8b 52 50             	mov    0x50(%edx),%edx
  802a43:	39 ca                	cmp    %ecx,%edx
  802a45:	74 11                	je     802a58 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802a47:	83 c0 01             	add    $0x1,%eax
  802a4a:	3d 00 04 00 00       	cmp    $0x400,%eax
  802a4f:	75 e6                	jne    802a37 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802a51:	b8 00 00 00 00       	mov    $0x0,%eax
  802a56:	eb 0b                	jmp    802a63 <ipc_find_env+0x3b>
			return envs[i].env_id;
  802a58:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802a5b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802a60:	8b 40 48             	mov    0x48(%eax),%eax
}
  802a63:	5d                   	pop    %ebp
  802a64:	c3                   	ret    

00802a65 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802a65:	f3 0f 1e fb          	endbr32 
  802a69:	55                   	push   %ebp
  802a6a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  802a6f:	05 00 00 00 30       	add    $0x30000000,%eax
  802a74:	c1 e8 0c             	shr    $0xc,%eax
}
  802a77:	5d                   	pop    %ebp
  802a78:	c3                   	ret    

00802a79 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802a79:	f3 0f 1e fb          	endbr32 
  802a7d:	55                   	push   %ebp
  802a7e:	89 e5                	mov    %esp,%ebp
  802a80:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  802a83:	ff 75 08             	pushl  0x8(%ebp)
  802a86:	e8 da ff ff ff       	call   802a65 <fd2num>
  802a8b:	83 c4 10             	add    $0x10,%esp
  802a8e:	c1 e0 0c             	shl    $0xc,%eax
  802a91:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802a96:	c9                   	leave  
  802a97:	c3                   	ret    

00802a98 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802a98:	f3 0f 1e fb          	endbr32 
  802a9c:	55                   	push   %ebp
  802a9d:	89 e5                	mov    %esp,%ebp
  802a9f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802aa4:	89 c2                	mov    %eax,%edx
  802aa6:	c1 ea 16             	shr    $0x16,%edx
  802aa9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802ab0:	f6 c2 01             	test   $0x1,%dl
  802ab3:	74 2d                	je     802ae2 <fd_alloc+0x4a>
  802ab5:	89 c2                	mov    %eax,%edx
  802ab7:	c1 ea 0c             	shr    $0xc,%edx
  802aba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802ac1:	f6 c2 01             	test   $0x1,%dl
  802ac4:	74 1c                	je     802ae2 <fd_alloc+0x4a>
  802ac6:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  802acb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802ad0:	75 d2                	jne    802aa4 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  802ad5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  802adb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  802ae0:	eb 0a                	jmp    802aec <fd_alloc+0x54>
			*fd_store = fd;
  802ae2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802ae5:	89 01                	mov    %eax,(%ecx)
			return 0;
  802ae7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802aec:	5d                   	pop    %ebp
  802aed:	c3                   	ret    

00802aee <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802aee:	f3 0f 1e fb          	endbr32 
  802af2:	55                   	push   %ebp
  802af3:	89 e5                	mov    %esp,%ebp
  802af5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802af8:	83 f8 1f             	cmp    $0x1f,%eax
  802afb:	77 30                	ja     802b2d <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802afd:	c1 e0 0c             	shl    $0xc,%eax
  802b00:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802b05:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  802b0b:	f6 c2 01             	test   $0x1,%dl
  802b0e:	74 24                	je     802b34 <fd_lookup+0x46>
  802b10:	89 c2                	mov    %eax,%edx
  802b12:	c1 ea 0c             	shr    $0xc,%edx
  802b15:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802b1c:	f6 c2 01             	test   $0x1,%dl
  802b1f:	74 1a                	je     802b3b <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802b21:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b24:	89 02                	mov    %eax,(%edx)
	return 0;
  802b26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802b2b:	5d                   	pop    %ebp
  802b2c:	c3                   	ret    
		return -E_INVAL;
  802b2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802b32:	eb f7                	jmp    802b2b <fd_lookup+0x3d>
		return -E_INVAL;
  802b34:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802b39:	eb f0                	jmp    802b2b <fd_lookup+0x3d>
  802b3b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802b40:	eb e9                	jmp    802b2b <fd_lookup+0x3d>

00802b42 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802b42:	f3 0f 1e fb          	endbr32 
  802b46:	55                   	push   %ebp
  802b47:	89 e5                	mov    %esp,%ebp
  802b49:	83 ec 08             	sub    $0x8,%esp
  802b4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802b4f:	ba c0 44 80 00       	mov    $0x8044c0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802b54:	b8 64 90 80 00       	mov    $0x809064,%eax
		if (devtab[i]->dev_id == dev_id) {
  802b59:	39 08                	cmp    %ecx,(%eax)
  802b5b:	74 33                	je     802b90 <dev_lookup+0x4e>
  802b5d:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  802b60:	8b 02                	mov    (%edx),%eax
  802b62:	85 c0                	test   %eax,%eax
  802b64:	75 f3                	jne    802b59 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802b66:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b6b:	8b 40 48             	mov    0x48(%eax),%eax
  802b6e:	83 ec 04             	sub    $0x4,%esp
  802b71:	51                   	push   %ecx
  802b72:	50                   	push   %eax
  802b73:	68 44 44 80 00       	push   $0x804444
  802b78:	e8 23 f2 ff ff       	call   801da0 <cprintf>
	*dev = 0;
  802b7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b80:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  802b86:	83 c4 10             	add    $0x10,%esp
  802b89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802b8e:	c9                   	leave  
  802b8f:	c3                   	ret    
			*dev = devtab[i];
  802b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b93:	89 01                	mov    %eax,(%ecx)
			return 0;
  802b95:	b8 00 00 00 00       	mov    $0x0,%eax
  802b9a:	eb f2                	jmp    802b8e <dev_lookup+0x4c>

00802b9c <fd_close>:
{
  802b9c:	f3 0f 1e fb          	endbr32 
  802ba0:	55                   	push   %ebp
  802ba1:	89 e5                	mov    %esp,%ebp
  802ba3:	57                   	push   %edi
  802ba4:	56                   	push   %esi
  802ba5:	53                   	push   %ebx
  802ba6:	83 ec 28             	sub    $0x28,%esp
  802ba9:	8b 75 08             	mov    0x8(%ebp),%esi
  802bac:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802baf:	56                   	push   %esi
  802bb0:	e8 b0 fe ff ff       	call   802a65 <fd2num>
  802bb5:	83 c4 08             	add    $0x8,%esp
  802bb8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  802bbb:	52                   	push   %edx
  802bbc:	50                   	push   %eax
  802bbd:	e8 2c ff ff ff       	call   802aee <fd_lookup>
  802bc2:	89 c3                	mov    %eax,%ebx
  802bc4:	83 c4 10             	add    $0x10,%esp
  802bc7:	85 c0                	test   %eax,%eax
  802bc9:	78 05                	js     802bd0 <fd_close+0x34>
	    || fd != fd2)
  802bcb:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  802bce:	74 16                	je     802be6 <fd_close+0x4a>
		return (must_exist ? r : 0);
  802bd0:	89 f8                	mov    %edi,%eax
  802bd2:	84 c0                	test   %al,%al
  802bd4:	b8 00 00 00 00       	mov    $0x0,%eax
  802bd9:	0f 44 d8             	cmove  %eax,%ebx
}
  802bdc:	89 d8                	mov    %ebx,%eax
  802bde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802be1:	5b                   	pop    %ebx
  802be2:	5e                   	pop    %esi
  802be3:	5f                   	pop    %edi
  802be4:	5d                   	pop    %ebp
  802be5:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802be6:	83 ec 08             	sub    $0x8,%esp
  802be9:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802bec:	50                   	push   %eax
  802bed:	ff 36                	pushl  (%esi)
  802bef:	e8 4e ff ff ff       	call   802b42 <dev_lookup>
  802bf4:	89 c3                	mov    %eax,%ebx
  802bf6:	83 c4 10             	add    $0x10,%esp
  802bf9:	85 c0                	test   %eax,%eax
  802bfb:	78 1a                	js     802c17 <fd_close+0x7b>
		if (dev->dev_close)
  802bfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802c00:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  802c03:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  802c08:	85 c0                	test   %eax,%eax
  802c0a:	74 0b                	je     802c17 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  802c0c:	83 ec 0c             	sub    $0xc,%esp
  802c0f:	56                   	push   %esi
  802c10:	ff d0                	call   *%eax
  802c12:	89 c3                	mov    %eax,%ebx
  802c14:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  802c17:	83 ec 08             	sub    $0x8,%esp
  802c1a:	56                   	push   %esi
  802c1b:	6a 00                	push   $0x0
  802c1d:	e8 c2 fb ff ff       	call   8027e4 <sys_page_unmap>
	return r;
  802c22:	83 c4 10             	add    $0x10,%esp
  802c25:	eb b5                	jmp    802bdc <fd_close+0x40>

00802c27 <close>:

int
close(int fdnum)
{
  802c27:	f3 0f 1e fb          	endbr32 
  802c2b:	55                   	push   %ebp
  802c2c:	89 e5                	mov    %esp,%ebp
  802c2e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802c31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c34:	50                   	push   %eax
  802c35:	ff 75 08             	pushl  0x8(%ebp)
  802c38:	e8 b1 fe ff ff       	call   802aee <fd_lookup>
  802c3d:	83 c4 10             	add    $0x10,%esp
  802c40:	85 c0                	test   %eax,%eax
  802c42:	79 02                	jns    802c46 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  802c44:	c9                   	leave  
  802c45:	c3                   	ret    
		return fd_close(fd, 1);
  802c46:	83 ec 08             	sub    $0x8,%esp
  802c49:	6a 01                	push   $0x1
  802c4b:	ff 75 f4             	pushl  -0xc(%ebp)
  802c4e:	e8 49 ff ff ff       	call   802b9c <fd_close>
  802c53:	83 c4 10             	add    $0x10,%esp
  802c56:	eb ec                	jmp    802c44 <close+0x1d>

00802c58 <close_all>:

void
close_all(void)
{
  802c58:	f3 0f 1e fb          	endbr32 
  802c5c:	55                   	push   %ebp
  802c5d:	89 e5                	mov    %esp,%ebp
  802c5f:	53                   	push   %ebx
  802c60:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802c63:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802c68:	83 ec 0c             	sub    $0xc,%esp
  802c6b:	53                   	push   %ebx
  802c6c:	e8 b6 ff ff ff       	call   802c27 <close>
	for (i = 0; i < MAXFD; i++)
  802c71:	83 c3 01             	add    $0x1,%ebx
  802c74:	83 c4 10             	add    $0x10,%esp
  802c77:	83 fb 20             	cmp    $0x20,%ebx
  802c7a:	75 ec                	jne    802c68 <close_all+0x10>
}
  802c7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c7f:	c9                   	leave  
  802c80:	c3                   	ret    

00802c81 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802c81:	f3 0f 1e fb          	endbr32 
  802c85:	55                   	push   %ebp
  802c86:	89 e5                	mov    %esp,%ebp
  802c88:	57                   	push   %edi
  802c89:	56                   	push   %esi
  802c8a:	53                   	push   %ebx
  802c8b:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802c8e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802c91:	50                   	push   %eax
  802c92:	ff 75 08             	pushl  0x8(%ebp)
  802c95:	e8 54 fe ff ff       	call   802aee <fd_lookup>
  802c9a:	89 c3                	mov    %eax,%ebx
  802c9c:	83 c4 10             	add    $0x10,%esp
  802c9f:	85 c0                	test   %eax,%eax
  802ca1:	0f 88 81 00 00 00    	js     802d28 <dup+0xa7>
		return r;
	close(newfdnum);
  802ca7:	83 ec 0c             	sub    $0xc,%esp
  802caa:	ff 75 0c             	pushl  0xc(%ebp)
  802cad:	e8 75 ff ff ff       	call   802c27 <close>

	newfd = INDEX2FD(newfdnum);
  802cb2:	8b 75 0c             	mov    0xc(%ebp),%esi
  802cb5:	c1 e6 0c             	shl    $0xc,%esi
  802cb8:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  802cbe:	83 c4 04             	add    $0x4,%esp
  802cc1:	ff 75 e4             	pushl  -0x1c(%ebp)
  802cc4:	e8 b0 fd ff ff       	call   802a79 <fd2data>
  802cc9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802ccb:	89 34 24             	mov    %esi,(%esp)
  802cce:	e8 a6 fd ff ff       	call   802a79 <fd2data>
  802cd3:	83 c4 10             	add    $0x10,%esp
  802cd6:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802cd8:	89 d8                	mov    %ebx,%eax
  802cda:	c1 e8 16             	shr    $0x16,%eax
  802cdd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802ce4:	a8 01                	test   $0x1,%al
  802ce6:	74 11                	je     802cf9 <dup+0x78>
  802ce8:	89 d8                	mov    %ebx,%eax
  802cea:	c1 e8 0c             	shr    $0xc,%eax
  802ced:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802cf4:	f6 c2 01             	test   $0x1,%dl
  802cf7:	75 39                	jne    802d32 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802cf9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802cfc:	89 d0                	mov    %edx,%eax
  802cfe:	c1 e8 0c             	shr    $0xc,%eax
  802d01:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802d08:	83 ec 0c             	sub    $0xc,%esp
  802d0b:	25 07 0e 00 00       	and    $0xe07,%eax
  802d10:	50                   	push   %eax
  802d11:	56                   	push   %esi
  802d12:	6a 00                	push   $0x0
  802d14:	52                   	push   %edx
  802d15:	6a 00                	push   $0x0
  802d17:	e8 9e fa ff ff       	call   8027ba <sys_page_map>
  802d1c:	89 c3                	mov    %eax,%ebx
  802d1e:	83 c4 20             	add    $0x20,%esp
  802d21:	85 c0                	test   %eax,%eax
  802d23:	78 31                	js     802d56 <dup+0xd5>
		goto err;

	return newfdnum;
  802d25:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  802d28:	89 d8                	mov    %ebx,%eax
  802d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d2d:	5b                   	pop    %ebx
  802d2e:	5e                   	pop    %esi
  802d2f:	5f                   	pop    %edi
  802d30:	5d                   	pop    %ebp
  802d31:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802d32:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802d39:	83 ec 0c             	sub    $0xc,%esp
  802d3c:	25 07 0e 00 00       	and    $0xe07,%eax
  802d41:	50                   	push   %eax
  802d42:	57                   	push   %edi
  802d43:	6a 00                	push   $0x0
  802d45:	53                   	push   %ebx
  802d46:	6a 00                	push   $0x0
  802d48:	e8 6d fa ff ff       	call   8027ba <sys_page_map>
  802d4d:	89 c3                	mov    %eax,%ebx
  802d4f:	83 c4 20             	add    $0x20,%esp
  802d52:	85 c0                	test   %eax,%eax
  802d54:	79 a3                	jns    802cf9 <dup+0x78>
	sys_page_unmap(0, newfd);
  802d56:	83 ec 08             	sub    $0x8,%esp
  802d59:	56                   	push   %esi
  802d5a:	6a 00                	push   $0x0
  802d5c:	e8 83 fa ff ff       	call   8027e4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802d61:	83 c4 08             	add    $0x8,%esp
  802d64:	57                   	push   %edi
  802d65:	6a 00                	push   $0x0
  802d67:	e8 78 fa ff ff       	call   8027e4 <sys_page_unmap>
	return r;
  802d6c:	83 c4 10             	add    $0x10,%esp
  802d6f:	eb b7                	jmp    802d28 <dup+0xa7>

00802d71 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802d71:	f3 0f 1e fb          	endbr32 
  802d75:	55                   	push   %ebp
  802d76:	89 e5                	mov    %esp,%ebp
  802d78:	53                   	push   %ebx
  802d79:	83 ec 1c             	sub    $0x1c,%esp
  802d7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d82:	50                   	push   %eax
  802d83:	53                   	push   %ebx
  802d84:	e8 65 fd ff ff       	call   802aee <fd_lookup>
  802d89:	83 c4 10             	add    $0x10,%esp
  802d8c:	85 c0                	test   %eax,%eax
  802d8e:	78 3f                	js     802dcf <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d90:	83 ec 08             	sub    $0x8,%esp
  802d93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d96:	50                   	push   %eax
  802d97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d9a:	ff 30                	pushl  (%eax)
  802d9c:	e8 a1 fd ff ff       	call   802b42 <dev_lookup>
  802da1:	83 c4 10             	add    $0x10,%esp
  802da4:	85 c0                	test   %eax,%eax
  802da6:	78 27                	js     802dcf <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802da8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802dab:	8b 42 08             	mov    0x8(%edx),%eax
  802dae:	83 e0 03             	and    $0x3,%eax
  802db1:	83 f8 01             	cmp    $0x1,%eax
  802db4:	74 1e                	je     802dd4 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  802db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802db9:	8b 40 08             	mov    0x8(%eax),%eax
  802dbc:	85 c0                	test   %eax,%eax
  802dbe:	74 35                	je     802df5 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802dc0:	83 ec 04             	sub    $0x4,%esp
  802dc3:	ff 75 10             	pushl  0x10(%ebp)
  802dc6:	ff 75 0c             	pushl  0xc(%ebp)
  802dc9:	52                   	push   %edx
  802dca:	ff d0                	call   *%eax
  802dcc:	83 c4 10             	add    $0x10,%esp
}
  802dcf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802dd2:	c9                   	leave  
  802dd3:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802dd4:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802dd9:	8b 40 48             	mov    0x48(%eax),%eax
  802ddc:	83 ec 04             	sub    $0x4,%esp
  802ddf:	53                   	push   %ebx
  802de0:	50                   	push   %eax
  802de1:	68 85 44 80 00       	push   $0x804485
  802de6:	e8 b5 ef ff ff       	call   801da0 <cprintf>
		return -E_INVAL;
  802deb:	83 c4 10             	add    $0x10,%esp
  802dee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802df3:	eb da                	jmp    802dcf <read+0x5e>
		return -E_NOT_SUPP;
  802df5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802dfa:	eb d3                	jmp    802dcf <read+0x5e>

00802dfc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802dfc:	f3 0f 1e fb          	endbr32 
  802e00:	55                   	push   %ebp
  802e01:	89 e5                	mov    %esp,%ebp
  802e03:	57                   	push   %edi
  802e04:	56                   	push   %esi
  802e05:	53                   	push   %ebx
  802e06:	83 ec 0c             	sub    $0xc,%esp
  802e09:	8b 7d 08             	mov    0x8(%ebp),%edi
  802e0c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802e0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802e14:	eb 02                	jmp    802e18 <readn+0x1c>
  802e16:	01 c3                	add    %eax,%ebx
  802e18:	39 f3                	cmp    %esi,%ebx
  802e1a:	73 21                	jae    802e3d <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802e1c:	83 ec 04             	sub    $0x4,%esp
  802e1f:	89 f0                	mov    %esi,%eax
  802e21:	29 d8                	sub    %ebx,%eax
  802e23:	50                   	push   %eax
  802e24:	89 d8                	mov    %ebx,%eax
  802e26:	03 45 0c             	add    0xc(%ebp),%eax
  802e29:	50                   	push   %eax
  802e2a:	57                   	push   %edi
  802e2b:	e8 41 ff ff ff       	call   802d71 <read>
		if (m < 0)
  802e30:	83 c4 10             	add    $0x10,%esp
  802e33:	85 c0                	test   %eax,%eax
  802e35:	78 04                	js     802e3b <readn+0x3f>
			return m;
		if (m == 0)
  802e37:	75 dd                	jne    802e16 <readn+0x1a>
  802e39:	eb 02                	jmp    802e3d <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802e3b:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  802e3d:	89 d8                	mov    %ebx,%eax
  802e3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e42:	5b                   	pop    %ebx
  802e43:	5e                   	pop    %esi
  802e44:	5f                   	pop    %edi
  802e45:	5d                   	pop    %ebp
  802e46:	c3                   	ret    

00802e47 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802e47:	f3 0f 1e fb          	endbr32 
  802e4b:	55                   	push   %ebp
  802e4c:	89 e5                	mov    %esp,%ebp
  802e4e:	53                   	push   %ebx
  802e4f:	83 ec 1c             	sub    $0x1c,%esp
  802e52:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802e55:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e58:	50                   	push   %eax
  802e59:	53                   	push   %ebx
  802e5a:	e8 8f fc ff ff       	call   802aee <fd_lookup>
  802e5f:	83 c4 10             	add    $0x10,%esp
  802e62:	85 c0                	test   %eax,%eax
  802e64:	78 3a                	js     802ea0 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e66:	83 ec 08             	sub    $0x8,%esp
  802e69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e6c:	50                   	push   %eax
  802e6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e70:	ff 30                	pushl  (%eax)
  802e72:	e8 cb fc ff ff       	call   802b42 <dev_lookup>
  802e77:	83 c4 10             	add    $0x10,%esp
  802e7a:	85 c0                	test   %eax,%eax
  802e7c:	78 22                	js     802ea0 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e81:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802e85:	74 1e                	je     802ea5 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802e87:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802e8a:	8b 52 0c             	mov    0xc(%edx),%edx
  802e8d:	85 d2                	test   %edx,%edx
  802e8f:	74 35                	je     802ec6 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802e91:	83 ec 04             	sub    $0x4,%esp
  802e94:	ff 75 10             	pushl  0x10(%ebp)
  802e97:	ff 75 0c             	pushl  0xc(%ebp)
  802e9a:	50                   	push   %eax
  802e9b:	ff d2                	call   *%edx
  802e9d:	83 c4 10             	add    $0x10,%esp
}
  802ea0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ea3:	c9                   	leave  
  802ea4:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802ea5:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802eaa:	8b 40 48             	mov    0x48(%eax),%eax
  802ead:	83 ec 04             	sub    $0x4,%esp
  802eb0:	53                   	push   %ebx
  802eb1:	50                   	push   %eax
  802eb2:	68 a1 44 80 00       	push   $0x8044a1
  802eb7:	e8 e4 ee ff ff       	call   801da0 <cprintf>
		return -E_INVAL;
  802ebc:	83 c4 10             	add    $0x10,%esp
  802ebf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802ec4:	eb da                	jmp    802ea0 <write+0x59>
		return -E_NOT_SUPP;
  802ec6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802ecb:	eb d3                	jmp    802ea0 <write+0x59>

00802ecd <seek>:

int
seek(int fdnum, off_t offset)
{
  802ecd:	f3 0f 1e fb          	endbr32 
  802ed1:	55                   	push   %ebp
  802ed2:	89 e5                	mov    %esp,%ebp
  802ed4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802ed7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802eda:	50                   	push   %eax
  802edb:	ff 75 08             	pushl  0x8(%ebp)
  802ede:	e8 0b fc ff ff       	call   802aee <fd_lookup>
  802ee3:	83 c4 10             	add    $0x10,%esp
  802ee6:	85 c0                	test   %eax,%eax
  802ee8:	78 0e                	js     802ef8 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  802eea:	8b 55 0c             	mov    0xc(%ebp),%edx
  802eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ef0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802ef3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ef8:	c9                   	leave  
  802ef9:	c3                   	ret    

00802efa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802efa:	f3 0f 1e fb          	endbr32 
  802efe:	55                   	push   %ebp
  802eff:	89 e5                	mov    %esp,%ebp
  802f01:	53                   	push   %ebx
  802f02:	83 ec 1c             	sub    $0x1c,%esp
  802f05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802f08:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f0b:	50                   	push   %eax
  802f0c:	53                   	push   %ebx
  802f0d:	e8 dc fb ff ff       	call   802aee <fd_lookup>
  802f12:	83 c4 10             	add    $0x10,%esp
  802f15:	85 c0                	test   %eax,%eax
  802f17:	78 37                	js     802f50 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802f19:	83 ec 08             	sub    $0x8,%esp
  802f1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f1f:	50                   	push   %eax
  802f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f23:	ff 30                	pushl  (%eax)
  802f25:	e8 18 fc ff ff       	call   802b42 <dev_lookup>
  802f2a:	83 c4 10             	add    $0x10,%esp
  802f2d:	85 c0                	test   %eax,%eax
  802f2f:	78 1f                	js     802f50 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802f31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f34:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802f38:	74 1b                	je     802f55 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  802f3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802f3d:	8b 52 18             	mov    0x18(%edx),%edx
  802f40:	85 d2                	test   %edx,%edx
  802f42:	74 32                	je     802f76 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802f44:	83 ec 08             	sub    $0x8,%esp
  802f47:	ff 75 0c             	pushl  0xc(%ebp)
  802f4a:	50                   	push   %eax
  802f4b:	ff d2                	call   *%edx
  802f4d:	83 c4 10             	add    $0x10,%esp
}
  802f50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f53:	c9                   	leave  
  802f54:	c3                   	ret    
			thisenv->env_id, fdnum);
  802f55:	a1 0c a0 80 00       	mov    0x80a00c,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802f5a:	8b 40 48             	mov    0x48(%eax),%eax
  802f5d:	83 ec 04             	sub    $0x4,%esp
  802f60:	53                   	push   %ebx
  802f61:	50                   	push   %eax
  802f62:	68 64 44 80 00       	push   $0x804464
  802f67:	e8 34 ee ff ff       	call   801da0 <cprintf>
		return -E_INVAL;
  802f6c:	83 c4 10             	add    $0x10,%esp
  802f6f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802f74:	eb da                	jmp    802f50 <ftruncate+0x56>
		return -E_NOT_SUPP;
  802f76:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802f7b:	eb d3                	jmp    802f50 <ftruncate+0x56>

00802f7d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802f7d:	f3 0f 1e fb          	endbr32 
  802f81:	55                   	push   %ebp
  802f82:	89 e5                	mov    %esp,%ebp
  802f84:	53                   	push   %ebx
  802f85:	83 ec 1c             	sub    $0x1c,%esp
  802f88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802f8b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f8e:	50                   	push   %eax
  802f8f:	ff 75 08             	pushl  0x8(%ebp)
  802f92:	e8 57 fb ff ff       	call   802aee <fd_lookup>
  802f97:	83 c4 10             	add    $0x10,%esp
  802f9a:	85 c0                	test   %eax,%eax
  802f9c:	78 4b                	js     802fe9 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802f9e:	83 ec 08             	sub    $0x8,%esp
  802fa1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802fa4:	50                   	push   %eax
  802fa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802fa8:	ff 30                	pushl  (%eax)
  802faa:	e8 93 fb ff ff       	call   802b42 <dev_lookup>
  802faf:	83 c4 10             	add    $0x10,%esp
  802fb2:	85 c0                	test   %eax,%eax
  802fb4:	78 33                	js     802fe9 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  802fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802fb9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802fbd:	74 2f                	je     802fee <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802fbf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802fc2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802fc9:	00 00 00 
	stat->st_isdir = 0;
  802fcc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802fd3:	00 00 00 
	stat->st_dev = dev;
  802fd6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802fdc:	83 ec 08             	sub    $0x8,%esp
  802fdf:	53                   	push   %ebx
  802fe0:	ff 75 f0             	pushl  -0x10(%ebp)
  802fe3:	ff 50 14             	call   *0x14(%eax)
  802fe6:	83 c4 10             	add    $0x10,%esp
}
  802fe9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802fec:	c9                   	leave  
  802fed:	c3                   	ret    
		return -E_NOT_SUPP;
  802fee:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802ff3:	eb f4                	jmp    802fe9 <fstat+0x6c>

00802ff5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802ff5:	f3 0f 1e fb          	endbr32 
  802ff9:	55                   	push   %ebp
  802ffa:	89 e5                	mov    %esp,%ebp
  802ffc:	56                   	push   %esi
  802ffd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802ffe:	83 ec 08             	sub    $0x8,%esp
  803001:	6a 00                	push   $0x0
  803003:	ff 75 08             	pushl  0x8(%ebp)
  803006:	e8 20 02 00 00       	call   80322b <open>
  80300b:	89 c3                	mov    %eax,%ebx
  80300d:	83 c4 10             	add    $0x10,%esp
  803010:	85 c0                	test   %eax,%eax
  803012:	78 1b                	js     80302f <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  803014:	83 ec 08             	sub    $0x8,%esp
  803017:	ff 75 0c             	pushl  0xc(%ebp)
  80301a:	50                   	push   %eax
  80301b:	e8 5d ff ff ff       	call   802f7d <fstat>
  803020:	89 c6                	mov    %eax,%esi
	close(fd);
  803022:	89 1c 24             	mov    %ebx,(%esp)
  803025:	e8 fd fb ff ff       	call   802c27 <close>
	return r;
  80302a:	83 c4 10             	add    $0x10,%esp
  80302d:	89 f3                	mov    %esi,%ebx
}
  80302f:	89 d8                	mov    %ebx,%eax
  803031:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803034:	5b                   	pop    %ebx
  803035:	5e                   	pop    %esi
  803036:	5d                   	pop    %ebp
  803037:	c3                   	ret    

00803038 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  803038:	55                   	push   %ebp
  803039:	89 e5                	mov    %esp,%ebp
  80303b:	56                   	push   %esi
  80303c:	53                   	push   %ebx
  80303d:	89 c6                	mov    %eax,%esi
  80303f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  803041:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  803048:	74 27                	je     803071 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80304a:	6a 07                	push   $0x7
  80304c:	68 00 b0 80 00       	push   $0x80b000
  803051:	56                   	push   %esi
  803052:	ff 35 00 a0 80 00    	pushl  0x80a000
  803058:	e8 78 f9 ff ff       	call   8029d5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80305d:	83 c4 0c             	add    $0xc,%esp
  803060:	6a 00                	push   $0x0
  803062:	53                   	push   %ebx
  803063:	6a 00                	push   $0x0
  803065:	e8 fe f8 ff ff       	call   802968 <ipc_recv>
}
  80306a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80306d:	5b                   	pop    %ebx
  80306e:	5e                   	pop    %esi
  80306f:	5d                   	pop    %ebp
  803070:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  803071:	83 ec 0c             	sub    $0xc,%esp
  803074:	6a 01                	push   $0x1
  803076:	e8 ad f9 ff ff       	call   802a28 <ipc_find_env>
  80307b:	a3 00 a0 80 00       	mov    %eax,0x80a000
  803080:	83 c4 10             	add    $0x10,%esp
  803083:	eb c5                	jmp    80304a <fsipc+0x12>

00803085 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  803085:	f3 0f 1e fb          	endbr32 
  803089:	55                   	push   %ebp
  80308a:	89 e5                	mov    %esp,%ebp
  80308c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80308f:	8b 45 08             	mov    0x8(%ebp),%eax
  803092:	8b 40 0c             	mov    0xc(%eax),%eax
  803095:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  80309a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80309d:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8030a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8030a7:	b8 02 00 00 00       	mov    $0x2,%eax
  8030ac:	e8 87 ff ff ff       	call   803038 <fsipc>
}
  8030b1:	c9                   	leave  
  8030b2:	c3                   	ret    

008030b3 <devfile_flush>:
{
  8030b3:	f3 0f 1e fb          	endbr32 
  8030b7:	55                   	push   %ebp
  8030b8:	89 e5                	mov    %esp,%ebp
  8030ba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8030bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8030c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8030c3:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  8030c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8030cd:	b8 06 00 00 00       	mov    $0x6,%eax
  8030d2:	e8 61 ff ff ff       	call   803038 <fsipc>
}
  8030d7:	c9                   	leave  
  8030d8:	c3                   	ret    

008030d9 <devfile_stat>:
{
  8030d9:	f3 0f 1e fb          	endbr32 
  8030dd:	55                   	push   %ebp
  8030de:	89 e5                	mov    %esp,%ebp
  8030e0:	53                   	push   %ebx
  8030e1:	83 ec 04             	sub    $0x4,%esp
  8030e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8030e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8030ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8030ed:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8030f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8030f7:	b8 05 00 00 00       	mov    $0x5,%eax
  8030fc:	e8 37 ff ff ff       	call   803038 <fsipc>
  803101:	85 c0                	test   %eax,%eax
  803103:	78 2c                	js     803131 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  803105:	83 ec 08             	sub    $0x8,%esp
  803108:	68 00 b0 80 00       	push   $0x80b000
  80310d:	53                   	push   %ebx
  80310e:	e8 f7 f1 ff ff       	call   80230a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  803113:	a1 80 b0 80 00       	mov    0x80b080,%eax
  803118:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80311e:	a1 84 b0 80 00       	mov    0x80b084,%eax
  803123:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  803129:	83 c4 10             	add    $0x10,%esp
  80312c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803131:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803134:	c9                   	leave  
  803135:	c3                   	ret    

00803136 <devfile_write>:
{
  803136:	f3 0f 1e fb          	endbr32 
  80313a:	55                   	push   %ebp
  80313b:	89 e5                	mov    %esp,%ebp
  80313d:	57                   	push   %edi
  80313e:	56                   	push   %esi
  80313f:	53                   	push   %ebx
  803140:	83 ec 0c             	sub    $0xc,%esp
  803143:	8b 75 0c             	mov    0xc(%ebp),%esi
  803146:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  803149:	8b 45 08             	mov    0x8(%ebp),%eax
  80314c:	8b 40 0c             	mov    0xc(%eax),%eax
  80314f:	a3 00 b0 80 00       	mov    %eax,0x80b000
	int r = 0;
  803154:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  803159:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  80315e:	85 db                	test   %ebx,%ebx
  803160:	74 3b                	je     80319d <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  803162:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  803168:	89 f8                	mov    %edi,%eax
  80316a:	0f 46 c3             	cmovbe %ebx,%eax
  80316d:	a3 04 b0 80 00       	mov    %eax,0x80b004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  803172:	83 ec 04             	sub    $0x4,%esp
  803175:	50                   	push   %eax
  803176:	56                   	push   %esi
  803177:	68 08 b0 80 00       	push   $0x80b008
  80317c:	e8 41 f3 ff ff       	call   8024c2 <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  803181:	ba 00 00 00 00       	mov    $0x0,%edx
  803186:	b8 04 00 00 00       	mov    $0x4,%eax
  80318b:	e8 a8 fe ff ff       	call   803038 <fsipc>
  803190:	83 c4 10             	add    $0x10,%esp
  803193:	85 c0                	test   %eax,%eax
  803195:	78 06                	js     80319d <devfile_write+0x67>
		buf_aux += r;
  803197:	01 c6                	add    %eax,%esi
		n -= r;
  803199:	29 c3                	sub    %eax,%ebx
  80319b:	eb c1                	jmp    80315e <devfile_write+0x28>
}
  80319d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8031a0:	5b                   	pop    %ebx
  8031a1:	5e                   	pop    %esi
  8031a2:	5f                   	pop    %edi
  8031a3:	5d                   	pop    %ebp
  8031a4:	c3                   	ret    

008031a5 <devfile_read>:
{
  8031a5:	f3 0f 1e fb          	endbr32 
  8031a9:	55                   	push   %ebp
  8031aa:	89 e5                	mov    %esp,%ebp
  8031ac:	56                   	push   %esi
  8031ad:	53                   	push   %ebx
  8031ae:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8031b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8031b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8031b7:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  8031bc:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8031c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8031c7:	b8 03 00 00 00       	mov    $0x3,%eax
  8031cc:	e8 67 fe ff ff       	call   803038 <fsipc>
  8031d1:	89 c3                	mov    %eax,%ebx
  8031d3:	85 c0                	test   %eax,%eax
  8031d5:	78 1f                	js     8031f6 <devfile_read+0x51>
	assert(r <= n);
  8031d7:	39 f0                	cmp    %esi,%eax
  8031d9:	77 24                	ja     8031ff <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8031db:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8031e0:	7f 33                	jg     803215 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8031e2:	83 ec 04             	sub    $0x4,%esp
  8031e5:	50                   	push   %eax
  8031e6:	68 00 b0 80 00       	push   $0x80b000
  8031eb:	ff 75 0c             	pushl  0xc(%ebp)
  8031ee:	e8 cf f2 ff ff       	call   8024c2 <memmove>
	return r;
  8031f3:	83 c4 10             	add    $0x10,%esp
}
  8031f6:	89 d8                	mov    %ebx,%eax
  8031f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8031fb:	5b                   	pop    %ebx
  8031fc:	5e                   	pop    %esi
  8031fd:	5d                   	pop    %ebp
  8031fe:	c3                   	ret    
	assert(r <= n);
  8031ff:	68 d0 44 80 00       	push   $0x8044d0
  803204:	68 bd 3a 80 00       	push   $0x803abd
  803209:	6a 7c                	push   $0x7c
  80320b:	68 d7 44 80 00       	push   $0x8044d7
  803210:	e8 a4 ea ff ff       	call   801cb9 <_panic>
	assert(r <= PGSIZE);
  803215:	68 e2 44 80 00       	push   $0x8044e2
  80321a:	68 bd 3a 80 00       	push   $0x803abd
  80321f:	6a 7d                	push   $0x7d
  803221:	68 d7 44 80 00       	push   $0x8044d7
  803226:	e8 8e ea ff ff       	call   801cb9 <_panic>

0080322b <open>:
{
  80322b:	f3 0f 1e fb          	endbr32 
  80322f:	55                   	push   %ebp
  803230:	89 e5                	mov    %esp,%ebp
  803232:	56                   	push   %esi
  803233:	53                   	push   %ebx
  803234:	83 ec 1c             	sub    $0x1c,%esp
  803237:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80323a:	56                   	push   %esi
  80323b:	e8 87 f0 ff ff       	call   8022c7 <strlen>
  803240:	83 c4 10             	add    $0x10,%esp
  803243:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  803248:	7f 6c                	jg     8032b6 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80324a:	83 ec 0c             	sub    $0xc,%esp
  80324d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803250:	50                   	push   %eax
  803251:	e8 42 f8 ff ff       	call   802a98 <fd_alloc>
  803256:	89 c3                	mov    %eax,%ebx
  803258:	83 c4 10             	add    $0x10,%esp
  80325b:	85 c0                	test   %eax,%eax
  80325d:	78 3c                	js     80329b <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80325f:	83 ec 08             	sub    $0x8,%esp
  803262:	56                   	push   %esi
  803263:	68 00 b0 80 00       	push   $0x80b000
  803268:	e8 9d f0 ff ff       	call   80230a <strcpy>
	fsipcbuf.open.req_omode = mode;
  80326d:	8b 45 0c             	mov    0xc(%ebp),%eax
  803270:	a3 00 b4 80 00       	mov    %eax,0x80b400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  803275:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803278:	b8 01 00 00 00       	mov    $0x1,%eax
  80327d:	e8 b6 fd ff ff       	call   803038 <fsipc>
  803282:	89 c3                	mov    %eax,%ebx
  803284:	83 c4 10             	add    $0x10,%esp
  803287:	85 c0                	test   %eax,%eax
  803289:	78 19                	js     8032a4 <open+0x79>
	return fd2num(fd);
  80328b:	83 ec 0c             	sub    $0xc,%esp
  80328e:	ff 75 f4             	pushl  -0xc(%ebp)
  803291:	e8 cf f7 ff ff       	call   802a65 <fd2num>
  803296:	89 c3                	mov    %eax,%ebx
  803298:	83 c4 10             	add    $0x10,%esp
}
  80329b:	89 d8                	mov    %ebx,%eax
  80329d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8032a0:	5b                   	pop    %ebx
  8032a1:	5e                   	pop    %esi
  8032a2:	5d                   	pop    %ebp
  8032a3:	c3                   	ret    
		fd_close(fd, 0);
  8032a4:	83 ec 08             	sub    $0x8,%esp
  8032a7:	6a 00                	push   $0x0
  8032a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8032ac:	e8 eb f8 ff ff       	call   802b9c <fd_close>
		return r;
  8032b1:	83 c4 10             	add    $0x10,%esp
  8032b4:	eb e5                	jmp    80329b <open+0x70>
		return -E_BAD_PATH;
  8032b6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8032bb:	eb de                	jmp    80329b <open+0x70>

008032bd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8032bd:	f3 0f 1e fb          	endbr32 
  8032c1:	55                   	push   %ebp
  8032c2:	89 e5                	mov    %esp,%ebp
  8032c4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8032c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8032cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8032d1:	e8 62 fd ff ff       	call   803038 <fsipc>
}
  8032d6:	c9                   	leave  
  8032d7:	c3                   	ret    

008032d8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8032d8:	f3 0f 1e fb          	endbr32 
  8032dc:	55                   	push   %ebp
  8032dd:	89 e5                	mov    %esp,%ebp
  8032df:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8032e2:	89 c2                	mov    %eax,%edx
  8032e4:	c1 ea 16             	shr    $0x16,%edx
  8032e7:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8032ee:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8032f3:	f6 c1 01             	test   $0x1,%cl
  8032f6:	74 1c                	je     803314 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8032f8:	c1 e8 0c             	shr    $0xc,%eax
  8032fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  803302:	a8 01                	test   $0x1,%al
  803304:	74 0e                	je     803314 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803306:	c1 e8 0c             	shr    $0xc,%eax
  803309:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  803310:	ef 
  803311:	0f b7 d2             	movzwl %dx,%edx
}
  803314:	89 d0                	mov    %edx,%eax
  803316:	5d                   	pop    %ebp
  803317:	c3                   	ret    

00803318 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803318:	f3 0f 1e fb          	endbr32 
  80331c:	55                   	push   %ebp
  80331d:	89 e5                	mov    %esp,%ebp
  80331f:	56                   	push   %esi
  803320:	53                   	push   %ebx
  803321:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803324:	83 ec 0c             	sub    $0xc,%esp
  803327:	ff 75 08             	pushl  0x8(%ebp)
  80332a:	e8 4a f7 ff ff       	call   802a79 <fd2data>
  80332f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803331:	83 c4 08             	add    $0x8,%esp
  803334:	68 ee 44 80 00       	push   $0x8044ee
  803339:	53                   	push   %ebx
  80333a:	e8 cb ef ff ff       	call   80230a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80333f:	8b 46 04             	mov    0x4(%esi),%eax
  803342:	2b 06                	sub    (%esi),%eax
  803344:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80334a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803351:	00 00 00 
	stat->st_dev = &devpipe;
  803354:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  80335b:	90 80 00 
	return 0;
}
  80335e:	b8 00 00 00 00       	mov    $0x0,%eax
  803363:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803366:	5b                   	pop    %ebx
  803367:	5e                   	pop    %esi
  803368:	5d                   	pop    %ebp
  803369:	c3                   	ret    

0080336a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80336a:	f3 0f 1e fb          	endbr32 
  80336e:	55                   	push   %ebp
  80336f:	89 e5                	mov    %esp,%ebp
  803371:	53                   	push   %ebx
  803372:	83 ec 0c             	sub    $0xc,%esp
  803375:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803378:	53                   	push   %ebx
  803379:	6a 00                	push   $0x0
  80337b:	e8 64 f4 ff ff       	call   8027e4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803380:	89 1c 24             	mov    %ebx,(%esp)
  803383:	e8 f1 f6 ff ff       	call   802a79 <fd2data>
  803388:	83 c4 08             	add    $0x8,%esp
  80338b:	50                   	push   %eax
  80338c:	6a 00                	push   $0x0
  80338e:	e8 51 f4 ff ff       	call   8027e4 <sys_page_unmap>
}
  803393:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803396:	c9                   	leave  
  803397:	c3                   	ret    

00803398 <_pipeisclosed>:
{
  803398:	55                   	push   %ebp
  803399:	89 e5                	mov    %esp,%ebp
  80339b:	57                   	push   %edi
  80339c:	56                   	push   %esi
  80339d:	53                   	push   %ebx
  80339e:	83 ec 1c             	sub    $0x1c,%esp
  8033a1:	89 c7                	mov    %eax,%edi
  8033a3:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8033a5:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8033aa:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8033ad:	83 ec 0c             	sub    $0xc,%esp
  8033b0:	57                   	push   %edi
  8033b1:	e8 22 ff ff ff       	call   8032d8 <pageref>
  8033b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8033b9:	89 34 24             	mov    %esi,(%esp)
  8033bc:	e8 17 ff ff ff       	call   8032d8 <pageref>
		nn = thisenv->env_runs;
  8033c1:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8033c7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8033ca:	83 c4 10             	add    $0x10,%esp
  8033cd:	39 cb                	cmp    %ecx,%ebx
  8033cf:	74 1b                	je     8033ec <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8033d1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8033d4:	75 cf                	jne    8033a5 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8033d6:	8b 42 58             	mov    0x58(%edx),%eax
  8033d9:	6a 01                	push   $0x1
  8033db:	50                   	push   %eax
  8033dc:	53                   	push   %ebx
  8033dd:	68 f5 44 80 00       	push   $0x8044f5
  8033e2:	e8 b9 e9 ff ff       	call   801da0 <cprintf>
  8033e7:	83 c4 10             	add    $0x10,%esp
  8033ea:	eb b9                	jmp    8033a5 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8033ec:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8033ef:	0f 94 c0             	sete   %al
  8033f2:	0f b6 c0             	movzbl %al,%eax
}
  8033f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8033f8:	5b                   	pop    %ebx
  8033f9:	5e                   	pop    %esi
  8033fa:	5f                   	pop    %edi
  8033fb:	5d                   	pop    %ebp
  8033fc:	c3                   	ret    

008033fd <devpipe_write>:
{
  8033fd:	f3 0f 1e fb          	endbr32 
  803401:	55                   	push   %ebp
  803402:	89 e5                	mov    %esp,%ebp
  803404:	57                   	push   %edi
  803405:	56                   	push   %esi
  803406:	53                   	push   %ebx
  803407:	83 ec 28             	sub    $0x28,%esp
  80340a:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80340d:	56                   	push   %esi
  80340e:	e8 66 f6 ff ff       	call   802a79 <fd2data>
  803413:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  803415:	83 c4 10             	add    $0x10,%esp
  803418:	bf 00 00 00 00       	mov    $0x0,%edi
  80341d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803420:	74 4f                	je     803471 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803422:	8b 43 04             	mov    0x4(%ebx),%eax
  803425:	8b 0b                	mov    (%ebx),%ecx
  803427:	8d 51 20             	lea    0x20(%ecx),%edx
  80342a:	39 d0                	cmp    %edx,%eax
  80342c:	72 14                	jb     803442 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  80342e:	89 da                	mov    %ebx,%edx
  803430:	89 f0                	mov    %esi,%eax
  803432:	e8 61 ff ff ff       	call   803398 <_pipeisclosed>
  803437:	85 c0                	test   %eax,%eax
  803439:	75 3b                	jne    803476 <devpipe_write+0x79>
			sys_yield();
  80343b:	e8 27 f3 ff ff       	call   802767 <sys_yield>
  803440:	eb e0                	jmp    803422 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803442:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803445:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803449:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80344c:	89 c2                	mov    %eax,%edx
  80344e:	c1 fa 1f             	sar    $0x1f,%edx
  803451:	89 d1                	mov    %edx,%ecx
  803453:	c1 e9 1b             	shr    $0x1b,%ecx
  803456:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803459:	83 e2 1f             	and    $0x1f,%edx
  80345c:	29 ca                	sub    %ecx,%edx
  80345e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803462:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803466:	83 c0 01             	add    $0x1,%eax
  803469:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80346c:	83 c7 01             	add    $0x1,%edi
  80346f:	eb ac                	jmp    80341d <devpipe_write+0x20>
	return i;
  803471:	8b 45 10             	mov    0x10(%ebp),%eax
  803474:	eb 05                	jmp    80347b <devpipe_write+0x7e>
				return 0;
  803476:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80347b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80347e:	5b                   	pop    %ebx
  80347f:	5e                   	pop    %esi
  803480:	5f                   	pop    %edi
  803481:	5d                   	pop    %ebp
  803482:	c3                   	ret    

00803483 <devpipe_read>:
{
  803483:	f3 0f 1e fb          	endbr32 
  803487:	55                   	push   %ebp
  803488:	89 e5                	mov    %esp,%ebp
  80348a:	57                   	push   %edi
  80348b:	56                   	push   %esi
  80348c:	53                   	push   %ebx
  80348d:	83 ec 18             	sub    $0x18,%esp
  803490:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  803493:	57                   	push   %edi
  803494:	e8 e0 f5 ff ff       	call   802a79 <fd2data>
  803499:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80349b:	83 c4 10             	add    $0x10,%esp
  80349e:	be 00 00 00 00       	mov    $0x0,%esi
  8034a3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8034a6:	75 14                	jne    8034bc <devpipe_read+0x39>
	return i;
  8034a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8034ab:	eb 02                	jmp    8034af <devpipe_read+0x2c>
				return i;
  8034ad:	89 f0                	mov    %esi,%eax
}
  8034af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8034b2:	5b                   	pop    %ebx
  8034b3:	5e                   	pop    %esi
  8034b4:	5f                   	pop    %edi
  8034b5:	5d                   	pop    %ebp
  8034b6:	c3                   	ret    
			sys_yield();
  8034b7:	e8 ab f2 ff ff       	call   802767 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8034bc:	8b 03                	mov    (%ebx),%eax
  8034be:	3b 43 04             	cmp    0x4(%ebx),%eax
  8034c1:	75 18                	jne    8034db <devpipe_read+0x58>
			if (i > 0)
  8034c3:	85 f6                	test   %esi,%esi
  8034c5:	75 e6                	jne    8034ad <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8034c7:	89 da                	mov    %ebx,%edx
  8034c9:	89 f8                	mov    %edi,%eax
  8034cb:	e8 c8 fe ff ff       	call   803398 <_pipeisclosed>
  8034d0:	85 c0                	test   %eax,%eax
  8034d2:	74 e3                	je     8034b7 <devpipe_read+0x34>
				return 0;
  8034d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8034d9:	eb d4                	jmp    8034af <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8034db:	99                   	cltd   
  8034dc:	c1 ea 1b             	shr    $0x1b,%edx
  8034df:	01 d0                	add    %edx,%eax
  8034e1:	83 e0 1f             	and    $0x1f,%eax
  8034e4:	29 d0                	sub    %edx,%eax
  8034e6:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8034eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8034ee:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8034f1:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8034f4:	83 c6 01             	add    $0x1,%esi
  8034f7:	eb aa                	jmp    8034a3 <devpipe_read+0x20>

008034f9 <pipe>:
{
  8034f9:	f3 0f 1e fb          	endbr32 
  8034fd:	55                   	push   %ebp
  8034fe:	89 e5                	mov    %esp,%ebp
  803500:	56                   	push   %esi
  803501:	53                   	push   %ebx
  803502:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  803505:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803508:	50                   	push   %eax
  803509:	e8 8a f5 ff ff       	call   802a98 <fd_alloc>
  80350e:	89 c3                	mov    %eax,%ebx
  803510:	83 c4 10             	add    $0x10,%esp
  803513:	85 c0                	test   %eax,%eax
  803515:	0f 88 23 01 00 00    	js     80363e <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80351b:	83 ec 04             	sub    $0x4,%esp
  80351e:	68 07 04 00 00       	push   $0x407
  803523:	ff 75 f4             	pushl  -0xc(%ebp)
  803526:	6a 00                	push   $0x0
  803528:	e8 65 f2 ff ff       	call   802792 <sys_page_alloc>
  80352d:	89 c3                	mov    %eax,%ebx
  80352f:	83 c4 10             	add    $0x10,%esp
  803532:	85 c0                	test   %eax,%eax
  803534:	0f 88 04 01 00 00    	js     80363e <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80353a:	83 ec 0c             	sub    $0xc,%esp
  80353d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803540:	50                   	push   %eax
  803541:	e8 52 f5 ff ff       	call   802a98 <fd_alloc>
  803546:	89 c3                	mov    %eax,%ebx
  803548:	83 c4 10             	add    $0x10,%esp
  80354b:	85 c0                	test   %eax,%eax
  80354d:	0f 88 db 00 00 00    	js     80362e <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803553:	83 ec 04             	sub    $0x4,%esp
  803556:	68 07 04 00 00       	push   $0x407
  80355b:	ff 75 f0             	pushl  -0x10(%ebp)
  80355e:	6a 00                	push   $0x0
  803560:	e8 2d f2 ff ff       	call   802792 <sys_page_alloc>
  803565:	89 c3                	mov    %eax,%ebx
  803567:	83 c4 10             	add    $0x10,%esp
  80356a:	85 c0                	test   %eax,%eax
  80356c:	0f 88 bc 00 00 00    	js     80362e <pipe+0x135>
	va = fd2data(fd0);
  803572:	83 ec 0c             	sub    $0xc,%esp
  803575:	ff 75 f4             	pushl  -0xc(%ebp)
  803578:	e8 fc f4 ff ff       	call   802a79 <fd2data>
  80357d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80357f:	83 c4 0c             	add    $0xc,%esp
  803582:	68 07 04 00 00       	push   $0x407
  803587:	50                   	push   %eax
  803588:	6a 00                	push   $0x0
  80358a:	e8 03 f2 ff ff       	call   802792 <sys_page_alloc>
  80358f:	89 c3                	mov    %eax,%ebx
  803591:	83 c4 10             	add    $0x10,%esp
  803594:	85 c0                	test   %eax,%eax
  803596:	0f 88 82 00 00 00    	js     80361e <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80359c:	83 ec 0c             	sub    $0xc,%esp
  80359f:	ff 75 f0             	pushl  -0x10(%ebp)
  8035a2:	e8 d2 f4 ff ff       	call   802a79 <fd2data>
  8035a7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8035ae:	50                   	push   %eax
  8035af:	6a 00                	push   $0x0
  8035b1:	56                   	push   %esi
  8035b2:	6a 00                	push   $0x0
  8035b4:	e8 01 f2 ff ff       	call   8027ba <sys_page_map>
  8035b9:	89 c3                	mov    %eax,%ebx
  8035bb:	83 c4 20             	add    $0x20,%esp
  8035be:	85 c0                	test   %eax,%eax
  8035c0:	78 4e                	js     803610 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8035c2:	a1 80 90 80 00       	mov    0x809080,%eax
  8035c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8035ca:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8035cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8035cf:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8035d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8035d9:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8035db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8035de:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8035e5:	83 ec 0c             	sub    $0xc,%esp
  8035e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8035eb:	e8 75 f4 ff ff       	call   802a65 <fd2num>
  8035f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8035f3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8035f5:	83 c4 04             	add    $0x4,%esp
  8035f8:	ff 75 f0             	pushl  -0x10(%ebp)
  8035fb:	e8 65 f4 ff ff       	call   802a65 <fd2num>
  803600:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803603:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803606:	83 c4 10             	add    $0x10,%esp
  803609:	bb 00 00 00 00       	mov    $0x0,%ebx
  80360e:	eb 2e                	jmp    80363e <pipe+0x145>
	sys_page_unmap(0, va);
  803610:	83 ec 08             	sub    $0x8,%esp
  803613:	56                   	push   %esi
  803614:	6a 00                	push   $0x0
  803616:	e8 c9 f1 ff ff       	call   8027e4 <sys_page_unmap>
  80361b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80361e:	83 ec 08             	sub    $0x8,%esp
  803621:	ff 75 f0             	pushl  -0x10(%ebp)
  803624:	6a 00                	push   $0x0
  803626:	e8 b9 f1 ff ff       	call   8027e4 <sys_page_unmap>
  80362b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80362e:	83 ec 08             	sub    $0x8,%esp
  803631:	ff 75 f4             	pushl  -0xc(%ebp)
  803634:	6a 00                	push   $0x0
  803636:	e8 a9 f1 ff ff       	call   8027e4 <sys_page_unmap>
  80363b:	83 c4 10             	add    $0x10,%esp
}
  80363e:	89 d8                	mov    %ebx,%eax
  803640:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803643:	5b                   	pop    %ebx
  803644:	5e                   	pop    %esi
  803645:	5d                   	pop    %ebp
  803646:	c3                   	ret    

00803647 <pipeisclosed>:
{
  803647:	f3 0f 1e fb          	endbr32 
  80364b:	55                   	push   %ebp
  80364c:	89 e5                	mov    %esp,%ebp
  80364e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803651:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803654:	50                   	push   %eax
  803655:	ff 75 08             	pushl  0x8(%ebp)
  803658:	e8 91 f4 ff ff       	call   802aee <fd_lookup>
  80365d:	83 c4 10             	add    $0x10,%esp
  803660:	85 c0                	test   %eax,%eax
  803662:	78 18                	js     80367c <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  803664:	83 ec 0c             	sub    $0xc,%esp
  803667:	ff 75 f4             	pushl  -0xc(%ebp)
  80366a:	e8 0a f4 ff ff       	call   802a79 <fd2data>
  80366f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  803671:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803674:	e8 1f fd ff ff       	call   803398 <_pipeisclosed>
  803679:	83 c4 10             	add    $0x10,%esp
}
  80367c:	c9                   	leave  
  80367d:	c3                   	ret    

0080367e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80367e:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  803682:	b8 00 00 00 00       	mov    $0x0,%eax
  803687:	c3                   	ret    

00803688 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  803688:	f3 0f 1e fb          	endbr32 
  80368c:	55                   	push   %ebp
  80368d:	89 e5                	mov    %esp,%ebp
  80368f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  803692:	68 0d 45 80 00       	push   $0x80450d
  803697:	ff 75 0c             	pushl  0xc(%ebp)
  80369a:	e8 6b ec ff ff       	call   80230a <strcpy>
	return 0;
}
  80369f:	b8 00 00 00 00       	mov    $0x0,%eax
  8036a4:	c9                   	leave  
  8036a5:	c3                   	ret    

008036a6 <devcons_write>:
{
  8036a6:	f3 0f 1e fb          	endbr32 
  8036aa:	55                   	push   %ebp
  8036ab:	89 e5                	mov    %esp,%ebp
  8036ad:	57                   	push   %edi
  8036ae:	56                   	push   %esi
  8036af:	53                   	push   %ebx
  8036b0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8036b6:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8036bb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8036c1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8036c4:	73 31                	jae    8036f7 <devcons_write+0x51>
		m = n - tot;
  8036c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8036c9:	29 f3                	sub    %esi,%ebx
  8036cb:	83 fb 7f             	cmp    $0x7f,%ebx
  8036ce:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8036d3:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8036d6:	83 ec 04             	sub    $0x4,%esp
  8036d9:	53                   	push   %ebx
  8036da:	89 f0                	mov    %esi,%eax
  8036dc:	03 45 0c             	add    0xc(%ebp),%eax
  8036df:	50                   	push   %eax
  8036e0:	57                   	push   %edi
  8036e1:	e8 dc ed ff ff       	call   8024c2 <memmove>
		sys_cputs(buf, m);
  8036e6:	83 c4 08             	add    $0x8,%esp
  8036e9:	53                   	push   %ebx
  8036ea:	57                   	push   %edi
  8036eb:	e8 d7 ef ff ff       	call   8026c7 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8036f0:	01 de                	add    %ebx,%esi
  8036f2:	83 c4 10             	add    $0x10,%esp
  8036f5:	eb ca                	jmp    8036c1 <devcons_write+0x1b>
}
  8036f7:	89 f0                	mov    %esi,%eax
  8036f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8036fc:	5b                   	pop    %ebx
  8036fd:	5e                   	pop    %esi
  8036fe:	5f                   	pop    %edi
  8036ff:	5d                   	pop    %ebp
  803700:	c3                   	ret    

00803701 <devcons_read>:
{
  803701:	f3 0f 1e fb          	endbr32 
  803705:	55                   	push   %ebp
  803706:	89 e5                	mov    %esp,%ebp
  803708:	83 ec 08             	sub    $0x8,%esp
  80370b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  803710:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803714:	74 21                	je     803737 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  803716:	e8 d6 ef ff ff       	call   8026f1 <sys_cgetc>
  80371b:	85 c0                	test   %eax,%eax
  80371d:	75 07                	jne    803726 <devcons_read+0x25>
		sys_yield();
  80371f:	e8 43 f0 ff ff       	call   802767 <sys_yield>
  803724:	eb f0                	jmp    803716 <devcons_read+0x15>
	if (c < 0)
  803726:	78 0f                	js     803737 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  803728:	83 f8 04             	cmp    $0x4,%eax
  80372b:	74 0c                	je     803739 <devcons_read+0x38>
	*(char*)vbuf = c;
  80372d:	8b 55 0c             	mov    0xc(%ebp),%edx
  803730:	88 02                	mov    %al,(%edx)
	return 1;
  803732:	b8 01 00 00 00       	mov    $0x1,%eax
}
  803737:	c9                   	leave  
  803738:	c3                   	ret    
		return 0;
  803739:	b8 00 00 00 00       	mov    $0x0,%eax
  80373e:	eb f7                	jmp    803737 <devcons_read+0x36>

00803740 <cputchar>:
{
  803740:	f3 0f 1e fb          	endbr32 
  803744:	55                   	push   %ebp
  803745:	89 e5                	mov    %esp,%ebp
  803747:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80374a:	8b 45 08             	mov    0x8(%ebp),%eax
  80374d:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  803750:	6a 01                	push   $0x1
  803752:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803755:	50                   	push   %eax
  803756:	e8 6c ef ff ff       	call   8026c7 <sys_cputs>
}
  80375b:	83 c4 10             	add    $0x10,%esp
  80375e:	c9                   	leave  
  80375f:	c3                   	ret    

00803760 <getchar>:
{
  803760:	f3 0f 1e fb          	endbr32 
  803764:	55                   	push   %ebp
  803765:	89 e5                	mov    %esp,%ebp
  803767:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80376a:	6a 01                	push   $0x1
  80376c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80376f:	50                   	push   %eax
  803770:	6a 00                	push   $0x0
  803772:	e8 fa f5 ff ff       	call   802d71 <read>
	if (r < 0)
  803777:	83 c4 10             	add    $0x10,%esp
  80377a:	85 c0                	test   %eax,%eax
  80377c:	78 06                	js     803784 <getchar+0x24>
	if (r < 1)
  80377e:	74 06                	je     803786 <getchar+0x26>
	return c;
  803780:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  803784:	c9                   	leave  
  803785:	c3                   	ret    
		return -E_EOF;
  803786:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80378b:	eb f7                	jmp    803784 <getchar+0x24>

0080378d <iscons>:
{
  80378d:	f3 0f 1e fb          	endbr32 
  803791:	55                   	push   %ebp
  803792:	89 e5                	mov    %esp,%ebp
  803794:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803797:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80379a:	50                   	push   %eax
  80379b:	ff 75 08             	pushl  0x8(%ebp)
  80379e:	e8 4b f3 ff ff       	call   802aee <fd_lookup>
  8037a3:	83 c4 10             	add    $0x10,%esp
  8037a6:	85 c0                	test   %eax,%eax
  8037a8:	78 11                	js     8037bb <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8037aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037ad:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8037b3:	39 10                	cmp    %edx,(%eax)
  8037b5:	0f 94 c0             	sete   %al
  8037b8:	0f b6 c0             	movzbl %al,%eax
}
  8037bb:	c9                   	leave  
  8037bc:	c3                   	ret    

008037bd <opencons>:
{
  8037bd:	f3 0f 1e fb          	endbr32 
  8037c1:	55                   	push   %ebp
  8037c2:	89 e5                	mov    %esp,%ebp
  8037c4:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8037c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8037ca:	50                   	push   %eax
  8037cb:	e8 c8 f2 ff ff       	call   802a98 <fd_alloc>
  8037d0:	83 c4 10             	add    $0x10,%esp
  8037d3:	85 c0                	test   %eax,%eax
  8037d5:	78 3a                	js     803811 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8037d7:	83 ec 04             	sub    $0x4,%esp
  8037da:	68 07 04 00 00       	push   $0x407
  8037df:	ff 75 f4             	pushl  -0xc(%ebp)
  8037e2:	6a 00                	push   $0x0
  8037e4:	e8 a9 ef ff ff       	call   802792 <sys_page_alloc>
  8037e9:	83 c4 10             	add    $0x10,%esp
  8037ec:	85 c0                	test   %eax,%eax
  8037ee:	78 21                	js     803811 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8037f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037f3:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8037f9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8037fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037fe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803805:	83 ec 0c             	sub    $0xc,%esp
  803808:	50                   	push   %eax
  803809:	e8 57 f2 ff ff       	call   802a65 <fd2num>
  80380e:	83 c4 10             	add    $0x10,%esp
}
  803811:	c9                   	leave  
  803812:	c3                   	ret    
  803813:	66 90                	xchg   %ax,%ax
  803815:	66 90                	xchg   %ax,%ax
  803817:	66 90                	xchg   %ax,%ax
  803819:	66 90                	xchg   %ax,%ax
  80381b:	66 90                	xchg   %ax,%ax
  80381d:	66 90                	xchg   %ax,%ax
  80381f:	90                   	nop

00803820 <__udivdi3>:
  803820:	f3 0f 1e fb          	endbr32 
  803824:	55                   	push   %ebp
  803825:	57                   	push   %edi
  803826:	56                   	push   %esi
  803827:	53                   	push   %ebx
  803828:	83 ec 1c             	sub    $0x1c,%esp
  80382b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80382f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  803833:	8b 74 24 34          	mov    0x34(%esp),%esi
  803837:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80383b:	85 d2                	test   %edx,%edx
  80383d:	75 19                	jne    803858 <__udivdi3+0x38>
  80383f:	39 f3                	cmp    %esi,%ebx
  803841:	76 4d                	jbe    803890 <__udivdi3+0x70>
  803843:	31 ff                	xor    %edi,%edi
  803845:	89 e8                	mov    %ebp,%eax
  803847:	89 f2                	mov    %esi,%edx
  803849:	f7 f3                	div    %ebx
  80384b:	89 fa                	mov    %edi,%edx
  80384d:	83 c4 1c             	add    $0x1c,%esp
  803850:	5b                   	pop    %ebx
  803851:	5e                   	pop    %esi
  803852:	5f                   	pop    %edi
  803853:	5d                   	pop    %ebp
  803854:	c3                   	ret    
  803855:	8d 76 00             	lea    0x0(%esi),%esi
  803858:	39 f2                	cmp    %esi,%edx
  80385a:	76 14                	jbe    803870 <__udivdi3+0x50>
  80385c:	31 ff                	xor    %edi,%edi
  80385e:	31 c0                	xor    %eax,%eax
  803860:	89 fa                	mov    %edi,%edx
  803862:	83 c4 1c             	add    $0x1c,%esp
  803865:	5b                   	pop    %ebx
  803866:	5e                   	pop    %esi
  803867:	5f                   	pop    %edi
  803868:	5d                   	pop    %ebp
  803869:	c3                   	ret    
  80386a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803870:	0f bd fa             	bsr    %edx,%edi
  803873:	83 f7 1f             	xor    $0x1f,%edi
  803876:	75 48                	jne    8038c0 <__udivdi3+0xa0>
  803878:	39 f2                	cmp    %esi,%edx
  80387a:	72 06                	jb     803882 <__udivdi3+0x62>
  80387c:	31 c0                	xor    %eax,%eax
  80387e:	39 eb                	cmp    %ebp,%ebx
  803880:	77 de                	ja     803860 <__udivdi3+0x40>
  803882:	b8 01 00 00 00       	mov    $0x1,%eax
  803887:	eb d7                	jmp    803860 <__udivdi3+0x40>
  803889:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803890:	89 d9                	mov    %ebx,%ecx
  803892:	85 db                	test   %ebx,%ebx
  803894:	75 0b                	jne    8038a1 <__udivdi3+0x81>
  803896:	b8 01 00 00 00       	mov    $0x1,%eax
  80389b:	31 d2                	xor    %edx,%edx
  80389d:	f7 f3                	div    %ebx
  80389f:	89 c1                	mov    %eax,%ecx
  8038a1:	31 d2                	xor    %edx,%edx
  8038a3:	89 f0                	mov    %esi,%eax
  8038a5:	f7 f1                	div    %ecx
  8038a7:	89 c6                	mov    %eax,%esi
  8038a9:	89 e8                	mov    %ebp,%eax
  8038ab:	89 f7                	mov    %esi,%edi
  8038ad:	f7 f1                	div    %ecx
  8038af:	89 fa                	mov    %edi,%edx
  8038b1:	83 c4 1c             	add    $0x1c,%esp
  8038b4:	5b                   	pop    %ebx
  8038b5:	5e                   	pop    %esi
  8038b6:	5f                   	pop    %edi
  8038b7:	5d                   	pop    %ebp
  8038b8:	c3                   	ret    
  8038b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8038c0:	89 f9                	mov    %edi,%ecx
  8038c2:	b8 20 00 00 00       	mov    $0x20,%eax
  8038c7:	29 f8                	sub    %edi,%eax
  8038c9:	d3 e2                	shl    %cl,%edx
  8038cb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8038cf:	89 c1                	mov    %eax,%ecx
  8038d1:	89 da                	mov    %ebx,%edx
  8038d3:	d3 ea                	shr    %cl,%edx
  8038d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8038d9:	09 d1                	or     %edx,%ecx
  8038db:	89 f2                	mov    %esi,%edx
  8038dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8038e1:	89 f9                	mov    %edi,%ecx
  8038e3:	d3 e3                	shl    %cl,%ebx
  8038e5:	89 c1                	mov    %eax,%ecx
  8038e7:	d3 ea                	shr    %cl,%edx
  8038e9:	89 f9                	mov    %edi,%ecx
  8038eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8038ef:	89 eb                	mov    %ebp,%ebx
  8038f1:	d3 e6                	shl    %cl,%esi
  8038f3:	89 c1                	mov    %eax,%ecx
  8038f5:	d3 eb                	shr    %cl,%ebx
  8038f7:	09 de                	or     %ebx,%esi
  8038f9:	89 f0                	mov    %esi,%eax
  8038fb:	f7 74 24 08          	divl   0x8(%esp)
  8038ff:	89 d6                	mov    %edx,%esi
  803901:	89 c3                	mov    %eax,%ebx
  803903:	f7 64 24 0c          	mull   0xc(%esp)
  803907:	39 d6                	cmp    %edx,%esi
  803909:	72 15                	jb     803920 <__udivdi3+0x100>
  80390b:	89 f9                	mov    %edi,%ecx
  80390d:	d3 e5                	shl    %cl,%ebp
  80390f:	39 c5                	cmp    %eax,%ebp
  803911:	73 04                	jae    803917 <__udivdi3+0xf7>
  803913:	39 d6                	cmp    %edx,%esi
  803915:	74 09                	je     803920 <__udivdi3+0x100>
  803917:	89 d8                	mov    %ebx,%eax
  803919:	31 ff                	xor    %edi,%edi
  80391b:	e9 40 ff ff ff       	jmp    803860 <__udivdi3+0x40>
  803920:	8d 43 ff             	lea    -0x1(%ebx),%eax
  803923:	31 ff                	xor    %edi,%edi
  803925:	e9 36 ff ff ff       	jmp    803860 <__udivdi3+0x40>
  80392a:	66 90                	xchg   %ax,%ax
  80392c:	66 90                	xchg   %ax,%ax
  80392e:	66 90                	xchg   %ax,%ax

00803930 <__umoddi3>:
  803930:	f3 0f 1e fb          	endbr32 
  803934:	55                   	push   %ebp
  803935:	57                   	push   %edi
  803936:	56                   	push   %esi
  803937:	53                   	push   %ebx
  803938:	83 ec 1c             	sub    $0x1c,%esp
  80393b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80393f:	8b 74 24 30          	mov    0x30(%esp),%esi
  803943:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  803947:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80394b:	85 c0                	test   %eax,%eax
  80394d:	75 19                	jne    803968 <__umoddi3+0x38>
  80394f:	39 df                	cmp    %ebx,%edi
  803951:	76 5d                	jbe    8039b0 <__umoddi3+0x80>
  803953:	89 f0                	mov    %esi,%eax
  803955:	89 da                	mov    %ebx,%edx
  803957:	f7 f7                	div    %edi
  803959:	89 d0                	mov    %edx,%eax
  80395b:	31 d2                	xor    %edx,%edx
  80395d:	83 c4 1c             	add    $0x1c,%esp
  803960:	5b                   	pop    %ebx
  803961:	5e                   	pop    %esi
  803962:	5f                   	pop    %edi
  803963:	5d                   	pop    %ebp
  803964:	c3                   	ret    
  803965:	8d 76 00             	lea    0x0(%esi),%esi
  803968:	89 f2                	mov    %esi,%edx
  80396a:	39 d8                	cmp    %ebx,%eax
  80396c:	76 12                	jbe    803980 <__umoddi3+0x50>
  80396e:	89 f0                	mov    %esi,%eax
  803970:	89 da                	mov    %ebx,%edx
  803972:	83 c4 1c             	add    $0x1c,%esp
  803975:	5b                   	pop    %ebx
  803976:	5e                   	pop    %esi
  803977:	5f                   	pop    %edi
  803978:	5d                   	pop    %ebp
  803979:	c3                   	ret    
  80397a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803980:	0f bd e8             	bsr    %eax,%ebp
  803983:	83 f5 1f             	xor    $0x1f,%ebp
  803986:	75 50                	jne    8039d8 <__umoddi3+0xa8>
  803988:	39 d8                	cmp    %ebx,%eax
  80398a:	0f 82 e0 00 00 00    	jb     803a70 <__umoddi3+0x140>
  803990:	89 d9                	mov    %ebx,%ecx
  803992:	39 f7                	cmp    %esi,%edi
  803994:	0f 86 d6 00 00 00    	jbe    803a70 <__umoddi3+0x140>
  80399a:	89 d0                	mov    %edx,%eax
  80399c:	89 ca                	mov    %ecx,%edx
  80399e:	83 c4 1c             	add    $0x1c,%esp
  8039a1:	5b                   	pop    %ebx
  8039a2:	5e                   	pop    %esi
  8039a3:	5f                   	pop    %edi
  8039a4:	5d                   	pop    %ebp
  8039a5:	c3                   	ret    
  8039a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8039ad:	8d 76 00             	lea    0x0(%esi),%esi
  8039b0:	89 fd                	mov    %edi,%ebp
  8039b2:	85 ff                	test   %edi,%edi
  8039b4:	75 0b                	jne    8039c1 <__umoddi3+0x91>
  8039b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8039bb:	31 d2                	xor    %edx,%edx
  8039bd:	f7 f7                	div    %edi
  8039bf:	89 c5                	mov    %eax,%ebp
  8039c1:	89 d8                	mov    %ebx,%eax
  8039c3:	31 d2                	xor    %edx,%edx
  8039c5:	f7 f5                	div    %ebp
  8039c7:	89 f0                	mov    %esi,%eax
  8039c9:	f7 f5                	div    %ebp
  8039cb:	89 d0                	mov    %edx,%eax
  8039cd:	31 d2                	xor    %edx,%edx
  8039cf:	eb 8c                	jmp    80395d <__umoddi3+0x2d>
  8039d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8039d8:	89 e9                	mov    %ebp,%ecx
  8039da:	ba 20 00 00 00       	mov    $0x20,%edx
  8039df:	29 ea                	sub    %ebp,%edx
  8039e1:	d3 e0                	shl    %cl,%eax
  8039e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8039e7:	89 d1                	mov    %edx,%ecx
  8039e9:	89 f8                	mov    %edi,%eax
  8039eb:	d3 e8                	shr    %cl,%eax
  8039ed:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8039f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8039f5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8039f9:	09 c1                	or     %eax,%ecx
  8039fb:	89 d8                	mov    %ebx,%eax
  8039fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803a01:	89 e9                	mov    %ebp,%ecx
  803a03:	d3 e7                	shl    %cl,%edi
  803a05:	89 d1                	mov    %edx,%ecx
  803a07:	d3 e8                	shr    %cl,%eax
  803a09:	89 e9                	mov    %ebp,%ecx
  803a0b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803a0f:	d3 e3                	shl    %cl,%ebx
  803a11:	89 c7                	mov    %eax,%edi
  803a13:	89 d1                	mov    %edx,%ecx
  803a15:	89 f0                	mov    %esi,%eax
  803a17:	d3 e8                	shr    %cl,%eax
  803a19:	89 e9                	mov    %ebp,%ecx
  803a1b:	89 fa                	mov    %edi,%edx
  803a1d:	d3 e6                	shl    %cl,%esi
  803a1f:	09 d8                	or     %ebx,%eax
  803a21:	f7 74 24 08          	divl   0x8(%esp)
  803a25:	89 d1                	mov    %edx,%ecx
  803a27:	89 f3                	mov    %esi,%ebx
  803a29:	f7 64 24 0c          	mull   0xc(%esp)
  803a2d:	89 c6                	mov    %eax,%esi
  803a2f:	89 d7                	mov    %edx,%edi
  803a31:	39 d1                	cmp    %edx,%ecx
  803a33:	72 06                	jb     803a3b <__umoddi3+0x10b>
  803a35:	75 10                	jne    803a47 <__umoddi3+0x117>
  803a37:	39 c3                	cmp    %eax,%ebx
  803a39:	73 0c                	jae    803a47 <__umoddi3+0x117>
  803a3b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  803a3f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  803a43:	89 d7                	mov    %edx,%edi
  803a45:	89 c6                	mov    %eax,%esi
  803a47:	89 ca                	mov    %ecx,%edx
  803a49:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  803a4e:	29 f3                	sub    %esi,%ebx
  803a50:	19 fa                	sbb    %edi,%edx
  803a52:	89 d0                	mov    %edx,%eax
  803a54:	d3 e0                	shl    %cl,%eax
  803a56:	89 e9                	mov    %ebp,%ecx
  803a58:	d3 eb                	shr    %cl,%ebx
  803a5a:	d3 ea                	shr    %cl,%edx
  803a5c:	09 d8                	or     %ebx,%eax
  803a5e:	83 c4 1c             	add    $0x1c,%esp
  803a61:	5b                   	pop    %ebx
  803a62:	5e                   	pop    %esi
  803a63:	5f                   	pop    %edi
  803a64:	5d                   	pop    %ebp
  803a65:	c3                   	ret    
  803a66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803a6d:	8d 76 00             	lea    0x0(%esi),%esi
  803a70:	29 fe                	sub    %edi,%esi
  803a72:	19 c3                	sbb    %eax,%ebx
  803a74:	89 f2                	mov    %esi,%edx
  803a76:	89 d9                	mov    %ebx,%ecx
  803a78:	e9 1d ff ff ff       	jmp    80399a <__umoddi3+0x6a>
