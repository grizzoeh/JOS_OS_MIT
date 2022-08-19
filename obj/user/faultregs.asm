
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 b8 05 00 00       	call   8005e9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 51 24 80 00       	push   $0x802451
  800049:	68 20 24 80 00       	push   $0x802420
  80004e:	e8 e9 06 00 00       	call   80073c <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 30 24 80 00       	push   $0x802430
  80005c:	68 34 24 80 00       	push   $0x802434
  800061:	e8 d6 06 00 00       	call   80073c <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	0f 84 2e 02 00 00    	je     8002a1 <check_regs+0x26e>
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 48 24 80 00       	push   $0x802448
  80007b:	e8 bc 06 00 00       	call   80073c <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800088:	ff 73 04             	pushl  0x4(%ebx)
  80008b:	ff 76 04             	pushl  0x4(%esi)
  80008e:	68 52 24 80 00       	push   $0x802452
  800093:	68 34 24 80 00       	push   $0x802434
  800098:	e8 9f 06 00 00       	call   80073c <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a3:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a6:	0f 84 0f 02 00 00    	je     8002bb <check_regs+0x288>
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 48 24 80 00       	push   $0x802448
  8000b4:	e8 83 06 00 00       	call   80073c <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c1:	ff 73 08             	pushl  0x8(%ebx)
  8000c4:	ff 76 08             	pushl  0x8(%esi)
  8000c7:	68 56 24 80 00       	push   $0x802456
  8000cc:	68 34 24 80 00       	push   $0x802434
  8000d1:	e8 66 06 00 00       	call   80073c <cprintf>
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dc:	39 46 08             	cmp    %eax,0x8(%esi)
  8000df:	0f 84 eb 01 00 00    	je     8002d0 <check_regs+0x29d>
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	68 48 24 80 00       	push   $0x802448
  8000ed:	e8 4a 06 00 00       	call   80073c <cprintf>
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fa:	ff 73 10             	pushl  0x10(%ebx)
  8000fd:	ff 76 10             	pushl  0x10(%esi)
  800100:	68 5a 24 80 00       	push   $0x80245a
  800105:	68 34 24 80 00       	push   $0x802434
  80010a:	e8 2d 06 00 00       	call   80073c <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8b 43 10             	mov    0x10(%ebx),%eax
  800115:	39 46 10             	cmp    %eax,0x10(%esi)
  800118:	0f 84 c7 01 00 00    	je     8002e5 <check_regs+0x2b2>
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 48 24 80 00       	push   $0x802448
  800126:	e8 11 06 00 00       	call   80073c <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800133:	ff 73 14             	pushl  0x14(%ebx)
  800136:	ff 76 14             	pushl  0x14(%esi)
  800139:	68 5e 24 80 00       	push   $0x80245e
  80013e:	68 34 24 80 00       	push   $0x802434
  800143:	e8 f4 05 00 00       	call   80073c <cprintf>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8b 43 14             	mov    0x14(%ebx),%eax
  80014e:	39 46 14             	cmp    %eax,0x14(%esi)
  800151:	0f 84 a3 01 00 00    	je     8002fa <check_regs+0x2c7>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 48 24 80 00       	push   $0x802448
  80015f:	e8 d8 05 00 00       	call   80073c <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016c:	ff 73 18             	pushl  0x18(%ebx)
  80016f:	ff 76 18             	pushl  0x18(%esi)
  800172:	68 62 24 80 00       	push   $0x802462
  800177:	68 34 24 80 00       	push   $0x802434
  80017c:	e8 bb 05 00 00       	call   80073c <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8b 43 18             	mov    0x18(%ebx),%eax
  800187:	39 46 18             	cmp    %eax,0x18(%esi)
  80018a:	0f 84 7f 01 00 00    	je     80030f <check_regs+0x2dc>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 48 24 80 00       	push   $0x802448
  800198:	e8 9f 05 00 00       	call   80073c <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a5:	ff 73 1c             	pushl  0x1c(%ebx)
  8001a8:	ff 76 1c             	pushl  0x1c(%esi)
  8001ab:	68 66 24 80 00       	push   $0x802466
  8001b0:	68 34 24 80 00       	push   $0x802434
  8001b5:	e8 82 05 00 00       	call   80073c <cprintf>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c0:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c3:	0f 84 5b 01 00 00    	je     800324 <check_regs+0x2f1>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	68 48 24 80 00       	push   $0x802448
  8001d1:	e8 66 05 00 00       	call   80073c <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001de:	ff 73 20             	pushl  0x20(%ebx)
  8001e1:	ff 76 20             	pushl  0x20(%esi)
  8001e4:	68 6a 24 80 00       	push   $0x80246a
  8001e9:	68 34 24 80 00       	push   $0x802434
  8001ee:	e8 49 05 00 00       	call   80073c <cprintf>
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8b 43 20             	mov    0x20(%ebx),%eax
  8001f9:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fc:	0f 84 37 01 00 00    	je     800339 <check_regs+0x306>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	68 48 24 80 00       	push   $0x802448
  80020a:	e8 2d 05 00 00       	call   80073c <cprintf>
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800217:	ff 73 24             	pushl  0x24(%ebx)
  80021a:	ff 76 24             	pushl  0x24(%esi)
  80021d:	68 6e 24 80 00       	push   $0x80246e
  800222:	68 34 24 80 00       	push   $0x802434
  800227:	e8 10 05 00 00       	call   80073c <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8b 43 24             	mov    0x24(%ebx),%eax
  800232:	39 46 24             	cmp    %eax,0x24(%esi)
  800235:	0f 84 13 01 00 00    	je     80034e <check_regs+0x31b>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	68 48 24 80 00       	push   $0x802448
  800243:	e8 f4 04 00 00       	call   80073c <cprintf>
	CHECK(esp, esp);
  800248:	ff 73 28             	pushl  0x28(%ebx)
  80024b:	ff 76 28             	pushl  0x28(%esi)
  80024e:	68 75 24 80 00       	push   $0x802475
  800253:	68 34 24 80 00       	push   $0x802434
  800258:	e8 df 04 00 00       	call   80073c <cprintf>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	8b 43 28             	mov    0x28(%ebx),%eax
  800263:	39 46 28             	cmp    %eax,0x28(%esi)
  800266:	0f 84 53 01 00 00    	je     8003bf <check_regs+0x38c>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	68 48 24 80 00       	push   $0x802448
  800274:	e8 c3 04 00 00       	call   80073c <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff 75 0c             	pushl  0xc(%ebp)
  80027f:	68 79 24 80 00       	push   $0x802479
  800284:	e8 b3 04 00 00       	call   80073c <cprintf>
  800289:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	68 48 24 80 00       	push   $0x802448
  800294:	e8 a3 04 00 00       	call   80073c <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	e9 16 01 00 00       	jmp    8003b7 <check_regs+0x384>
	CHECK(edi, regs.reg_edi);
  8002a1:	83 ec 0c             	sub    $0xc,%esp
  8002a4:	68 44 24 80 00       	push   $0x802444
  8002a9:	e8 8e 04 00 00       	call   80073c <cprintf>
  8002ae:	83 c4 10             	add    $0x10,%esp
	int mismatch = 0;
  8002b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b6:	e9 cd fd ff ff       	jmp    800088 <check_regs+0x55>
	CHECK(esi, regs.reg_esi);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	68 44 24 80 00       	push   $0x802444
  8002c3:	e8 74 04 00 00       	call   80073c <cprintf>
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	e9 f1 fd ff ff       	jmp    8000c1 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	68 44 24 80 00       	push   $0x802444
  8002d8:	e8 5f 04 00 00       	call   80073c <cprintf>
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	e9 15 fe ff ff       	jmp    8000fa <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e5:	83 ec 0c             	sub    $0xc,%esp
  8002e8:	68 44 24 80 00       	push   $0x802444
  8002ed:	e8 4a 04 00 00       	call   80073c <cprintf>
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	e9 39 fe ff ff       	jmp    800133 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	68 44 24 80 00       	push   $0x802444
  800302:	e8 35 04 00 00       	call   80073c <cprintf>
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	e9 5d fe ff ff       	jmp    80016c <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	68 44 24 80 00       	push   $0x802444
  800317:	e8 20 04 00 00       	call   80073c <cprintf>
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	e9 81 fe ff ff       	jmp    8001a5 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	68 44 24 80 00       	push   $0x802444
  80032c:	e8 0b 04 00 00       	call   80073c <cprintf>
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	e9 a5 fe ff ff       	jmp    8001de <check_regs+0x1ab>
	CHECK(eip, eip);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	68 44 24 80 00       	push   $0x802444
  800341:	e8 f6 03 00 00       	call   80073c <cprintf>
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	e9 c9 fe ff ff       	jmp    800217 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 44 24 80 00       	push   $0x802444
  800356:	e8 e1 03 00 00       	call   80073c <cprintf>
	CHECK(esp, esp);
  80035b:	ff 73 28             	pushl  0x28(%ebx)
  80035e:	ff 76 28             	pushl  0x28(%esi)
  800361:	68 75 24 80 00       	push   $0x802475
  800366:	68 34 24 80 00       	push   $0x802434
  80036b:	e8 cc 03 00 00       	call   80073c <cprintf>
  800370:	83 c4 20             	add    $0x20,%esp
  800373:	8b 43 28             	mov    0x28(%ebx),%eax
  800376:	39 46 28             	cmp    %eax,0x28(%esi)
  800379:	0f 85 ed fe ff ff    	jne    80026c <check_regs+0x239>
  80037f:	83 ec 0c             	sub    $0xc,%esp
  800382:	68 44 24 80 00       	push   $0x802444
  800387:	e8 b0 03 00 00       	call   80073c <cprintf>
	cprintf("Registers %s ", testname);
  80038c:	83 c4 08             	add    $0x8,%esp
  80038f:	ff 75 0c             	pushl  0xc(%ebp)
  800392:	68 79 24 80 00       	push   $0x802479
  800397:	e8 a0 03 00 00       	call   80073c <cprintf>
	if (!mismatch)
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	85 ff                	test   %edi,%edi
  8003a1:	0f 85 e5 fe ff ff    	jne    80028c <check_regs+0x259>
		cprintf("OK\n");
  8003a7:	83 ec 0c             	sub    $0xc,%esp
  8003aa:	68 44 24 80 00       	push   $0x802444
  8003af:	e8 88 03 00 00       	call   80073c <cprintf>
  8003b4:	83 c4 10             	add    $0x10,%esp
}
  8003b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ba:	5b                   	pop    %ebx
  8003bb:	5e                   	pop    %esi
  8003bc:	5f                   	pop    %edi
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    
	CHECK(esp, esp);
  8003bf:	83 ec 0c             	sub    $0xc,%esp
  8003c2:	68 44 24 80 00       	push   $0x802444
  8003c7:	e8 70 03 00 00       	call   80073c <cprintf>
	cprintf("Registers %s ", testname);
  8003cc:	83 c4 08             	add    $0x8,%esp
  8003cf:	ff 75 0c             	pushl  0xc(%ebp)
  8003d2:	68 79 24 80 00       	push   $0x802479
  8003d7:	e8 60 03 00 00       	call   80073c <cprintf>
  8003dc:	83 c4 10             	add    $0x10,%esp
  8003df:	e9 a8 fe ff ff       	jmp    80028c <check_regs+0x259>

008003e4 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003e4:	f3 0f 1e fb          	endbr32 
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	83 ec 08             	sub    $0x8,%esp
  8003ee:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003f1:	8b 10                	mov    (%eax),%edx
  8003f3:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003f9:	0f 85 a3 00 00 00    	jne    8004a2 <pgfault+0xbe>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003ff:	8b 50 08             	mov    0x8(%eax),%edx
  800402:	89 15 40 40 80 00    	mov    %edx,0x804040
  800408:	8b 50 0c             	mov    0xc(%eax),%edx
  80040b:	89 15 44 40 80 00    	mov    %edx,0x804044
  800411:	8b 50 10             	mov    0x10(%eax),%edx
  800414:	89 15 48 40 80 00    	mov    %edx,0x804048
  80041a:	8b 50 14             	mov    0x14(%eax),%edx
  80041d:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  800423:	8b 50 18             	mov    0x18(%eax),%edx
  800426:	89 15 50 40 80 00    	mov    %edx,0x804050
  80042c:	8b 50 1c             	mov    0x1c(%eax),%edx
  80042f:	89 15 54 40 80 00    	mov    %edx,0x804054
  800435:	8b 50 20             	mov    0x20(%eax),%edx
  800438:	89 15 58 40 80 00    	mov    %edx,0x804058
  80043e:	8b 50 24             	mov    0x24(%eax),%edx
  800441:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800447:	8b 50 28             	mov    0x28(%eax),%edx
  80044a:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags & ~FL_RF;
  800450:	8b 50 2c             	mov    0x2c(%eax),%edx
  800453:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800459:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  80045f:	8b 40 30             	mov    0x30(%eax),%eax
  800462:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	68 9f 24 80 00       	push   $0x80249f
  80046f:	68 ad 24 80 00       	push   $0x8024ad
  800474:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800479:	ba 98 24 80 00       	mov    $0x802498,%edx
  80047e:	b8 80 40 80 00       	mov    $0x804080,%eax
  800483:	e8 ab fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800488:	83 c4 0c             	add    $0xc,%esp
  80048b:	6a 07                	push   $0x7
  80048d:	68 00 00 40 00       	push   $0x400000
  800492:	6a 00                	push   $0x0
  800494:	e8 95 0c 00 00       	call   80112e <sys_page_alloc>
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	85 c0                	test   %eax,%eax
  80049e:	78 1a                	js     8004ba <pgfault+0xd6>
		panic("sys_page_alloc: %e", r);
}
  8004a0:	c9                   	leave  
  8004a1:	c3                   	ret    
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8004a2:	83 ec 0c             	sub    $0xc,%esp
  8004a5:	ff 70 28             	pushl  0x28(%eax)
  8004a8:	52                   	push   %edx
  8004a9:	68 e0 24 80 00       	push   $0x8024e0
  8004ae:	6a 50                	push   $0x50
  8004b0:	68 87 24 80 00       	push   $0x802487
  8004b5:	e8 9b 01 00 00       	call   800655 <_panic>
		panic("sys_page_alloc: %e", r);
  8004ba:	50                   	push   %eax
  8004bb:	68 b4 24 80 00       	push   $0x8024b4
  8004c0:	6a 5c                	push   $0x5c
  8004c2:	68 87 24 80 00       	push   $0x802487
  8004c7:	e8 89 01 00 00       	call   800655 <_panic>

008004cc <umain>:

void
umain(int argc, char **argv)
{
  8004cc:	f3 0f 1e fb          	endbr32 
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  8004d6:	68 e4 03 80 00       	push   $0x8003e4
  8004db:	e8 8b 0d 00 00       	call   80126b <set_pgfault_handler>

	asm volatile(
  8004e0:	50                   	push   %eax
  8004e1:	9c                   	pushf  
  8004e2:	58                   	pop    %eax
  8004e3:	0d d5 08 00 00       	or     $0x8d5,%eax
  8004e8:	50                   	push   %eax
  8004e9:	9d                   	popf   
  8004ea:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  8004ef:	8d 05 2a 05 80 00    	lea    0x80052a,%eax
  8004f5:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004fa:	58                   	pop    %eax
  8004fb:	89 3d 80 40 80 00    	mov    %edi,0x804080
  800501:	89 35 84 40 80 00    	mov    %esi,0x804084
  800507:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  80050d:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  800513:	89 15 94 40 80 00    	mov    %edx,0x804094
  800519:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  80051f:	a3 9c 40 80 00       	mov    %eax,0x80409c
  800524:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  80052a:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800531:	00 00 00 
  800534:	89 3d 00 40 80 00    	mov    %edi,0x804000
  80053a:	89 35 04 40 80 00    	mov    %esi,0x804004
  800540:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  800546:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  80054c:	89 15 14 40 80 00    	mov    %edx,0x804014
  800552:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800558:	a3 1c 40 80 00       	mov    %eax,0x80401c
  80055d:	89 25 28 40 80 00    	mov    %esp,0x804028
  800563:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800569:	8b 35 84 40 80 00    	mov    0x804084,%esi
  80056f:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  800575:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  80057b:	8b 15 94 40 80 00    	mov    0x804094,%edx
  800581:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800587:	a1 9c 40 80 00       	mov    0x80409c,%eax
  80058c:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  800592:	50                   	push   %eax
  800593:	9c                   	pushf  
  800594:	58                   	pop    %eax
  800595:	a3 24 40 80 00       	mov    %eax,0x804024
  80059a:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80059b:	83 c4 10             	add    $0x10,%esp
  80059e:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  8005a5:	75 30                	jne    8005d7 <umain+0x10b>
		cprintf("EIP after page-fault MISMATCH\n");
	after.eip = before.eip;
  8005a7:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  8005ac:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	68 c7 24 80 00       	push   $0x8024c7
  8005b9:	68 d8 24 80 00       	push   $0x8024d8
  8005be:	b9 00 40 80 00       	mov    $0x804000,%ecx
  8005c3:	ba 98 24 80 00       	mov    $0x802498,%edx
  8005c8:	b8 80 40 80 00       	mov    $0x804080,%eax
  8005cd:	e8 61 fa ff ff       	call   800033 <check_regs>
}
  8005d2:	83 c4 10             	add    $0x10,%esp
  8005d5:	c9                   	leave  
  8005d6:	c3                   	ret    
		cprintf("EIP after page-fault MISMATCH\n");
  8005d7:	83 ec 0c             	sub    $0xc,%esp
  8005da:	68 14 25 80 00       	push   $0x802514
  8005df:	e8 58 01 00 00       	call   80073c <cprintf>
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	eb be                	jmp    8005a7 <umain+0xdb>

008005e9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005e9:	f3 0f 1e fb          	endbr32 
  8005ed:	55                   	push   %ebp
  8005ee:	89 e5                	mov    %esp,%ebp
  8005f0:	56                   	push   %esi
  8005f1:	53                   	push   %ebx
  8005f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8005f8:	e8 de 0a 00 00       	call   8010db <sys_getenvid>
	if (id >= 0)
  8005fd:	85 c0                	test   %eax,%eax
  8005ff:	78 12                	js     800613 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800601:	25 ff 03 00 00       	and    $0x3ff,%eax
  800606:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800609:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80060e:	a3 b0 40 80 00       	mov    %eax,0x8040b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800613:	85 db                	test   %ebx,%ebx
  800615:	7e 07                	jle    80061e <libmain+0x35>
		binaryname = argv[0];
  800617:	8b 06                	mov    (%esi),%eax
  800619:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	56                   	push   %esi
  800622:	53                   	push   %ebx
  800623:	e8 a4 fe ff ff       	call   8004cc <umain>

	// exit gracefully
	exit();
  800628:	e8 0a 00 00 00       	call   800637 <exit>
}
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800633:	5b                   	pop    %ebx
  800634:	5e                   	pop    %esi
  800635:	5d                   	pop    %ebp
  800636:	c3                   	ret    

00800637 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800637:	f3 0f 1e fb          	endbr32 
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
  80063e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800641:	e8 b1 0e 00 00       	call   8014f7 <close_all>
	sys_env_destroy(0);
  800646:	83 ec 0c             	sub    $0xc,%esp
  800649:	6a 00                	push   $0x0
  80064b:	e8 65 0a 00 00       	call   8010b5 <sys_env_destroy>
}
  800650:	83 c4 10             	add    $0x10,%esp
  800653:	c9                   	leave  
  800654:	c3                   	ret    

00800655 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800655:	f3 0f 1e fb          	endbr32 
  800659:	55                   	push   %ebp
  80065a:	89 e5                	mov    %esp,%ebp
  80065c:	56                   	push   %esi
  80065d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80065e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800661:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800667:	e8 6f 0a 00 00       	call   8010db <sys_getenvid>
  80066c:	83 ec 0c             	sub    $0xc,%esp
  80066f:	ff 75 0c             	pushl  0xc(%ebp)
  800672:	ff 75 08             	pushl  0x8(%ebp)
  800675:	56                   	push   %esi
  800676:	50                   	push   %eax
  800677:	68 40 25 80 00       	push   $0x802540
  80067c:	e8 bb 00 00 00       	call   80073c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800681:	83 c4 18             	add    $0x18,%esp
  800684:	53                   	push   %ebx
  800685:	ff 75 10             	pushl  0x10(%ebp)
  800688:	e8 5a 00 00 00       	call   8006e7 <vcprintf>
	cprintf("\n");
  80068d:	c7 04 24 50 24 80 00 	movl   $0x802450,(%esp)
  800694:	e8 a3 00 00 00       	call   80073c <cprintf>
  800699:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80069c:	cc                   	int3   
  80069d:	eb fd                	jmp    80069c <_panic+0x47>

0080069f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80069f:	f3 0f 1e fb          	endbr32 
  8006a3:	55                   	push   %ebp
  8006a4:	89 e5                	mov    %esp,%ebp
  8006a6:	53                   	push   %ebx
  8006a7:	83 ec 04             	sub    $0x4,%esp
  8006aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006ad:	8b 13                	mov    (%ebx),%edx
  8006af:	8d 42 01             	lea    0x1(%edx),%eax
  8006b2:	89 03                	mov    %eax,(%ebx)
  8006b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006bb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006c0:	74 09                	je     8006cb <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8006c2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c9:	c9                   	leave  
  8006ca:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	68 ff 00 00 00       	push   $0xff
  8006d3:	8d 43 08             	lea    0x8(%ebx),%eax
  8006d6:	50                   	push   %eax
  8006d7:	e8 87 09 00 00       	call   801063 <sys_cputs>
		b->idx = 0;
  8006dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	eb db                	jmp    8006c2 <putch+0x23>

008006e7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006e7:	f3 0f 1e fb          	endbr32 
  8006eb:	55                   	push   %ebp
  8006ec:	89 e5                	mov    %esp,%ebp
  8006ee:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006fb:	00 00 00 
	b.cnt = 0;
  8006fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800705:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800708:	ff 75 0c             	pushl  0xc(%ebp)
  80070b:	ff 75 08             	pushl  0x8(%ebp)
  80070e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800714:	50                   	push   %eax
  800715:	68 9f 06 80 00       	push   $0x80069f
  80071a:	e8 80 01 00 00       	call   80089f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80071f:	83 c4 08             	add    $0x8,%esp
  800722:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800728:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80072e:	50                   	push   %eax
  80072f:	e8 2f 09 00 00       	call   801063 <sys_cputs>

	return b.cnt;
}
  800734:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    

0080073c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80073c:	f3 0f 1e fb          	endbr32 
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800746:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800749:	50                   	push   %eax
  80074a:	ff 75 08             	pushl  0x8(%ebp)
  80074d:	e8 95 ff ff ff       	call   8006e7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800752:	c9                   	leave  
  800753:	c3                   	ret    

00800754 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	57                   	push   %edi
  800758:	56                   	push   %esi
  800759:	53                   	push   %ebx
  80075a:	83 ec 1c             	sub    $0x1c,%esp
  80075d:	89 c7                	mov    %eax,%edi
  80075f:	89 d6                	mov    %edx,%esi
  800761:	8b 45 08             	mov    0x8(%ebp),%eax
  800764:	8b 55 0c             	mov    0xc(%ebp),%edx
  800767:	89 d1                	mov    %edx,%ecx
  800769:	89 c2                	mov    %eax,%edx
  80076b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800771:	8b 45 10             	mov    0x10(%ebp),%eax
  800774:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800777:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80077a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800781:	39 c2                	cmp    %eax,%edx
  800783:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800786:	72 3e                	jb     8007c6 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800788:	83 ec 0c             	sub    $0xc,%esp
  80078b:	ff 75 18             	pushl  0x18(%ebp)
  80078e:	83 eb 01             	sub    $0x1,%ebx
  800791:	53                   	push   %ebx
  800792:	50                   	push   %eax
  800793:	83 ec 08             	sub    $0x8,%esp
  800796:	ff 75 e4             	pushl  -0x1c(%ebp)
  800799:	ff 75 e0             	pushl  -0x20(%ebp)
  80079c:	ff 75 dc             	pushl  -0x24(%ebp)
  80079f:	ff 75 d8             	pushl  -0x28(%ebp)
  8007a2:	e8 09 1a 00 00       	call   8021b0 <__udivdi3>
  8007a7:	83 c4 18             	add    $0x18,%esp
  8007aa:	52                   	push   %edx
  8007ab:	50                   	push   %eax
  8007ac:	89 f2                	mov    %esi,%edx
  8007ae:	89 f8                	mov    %edi,%eax
  8007b0:	e8 9f ff ff ff       	call   800754 <printnum>
  8007b5:	83 c4 20             	add    $0x20,%esp
  8007b8:	eb 13                	jmp    8007cd <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007ba:	83 ec 08             	sub    $0x8,%esp
  8007bd:	56                   	push   %esi
  8007be:	ff 75 18             	pushl  0x18(%ebp)
  8007c1:	ff d7                	call   *%edi
  8007c3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8007c6:	83 eb 01             	sub    $0x1,%ebx
  8007c9:	85 db                	test   %ebx,%ebx
  8007cb:	7f ed                	jg     8007ba <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007cd:	83 ec 08             	sub    $0x8,%esp
  8007d0:	56                   	push   %esi
  8007d1:	83 ec 04             	sub    $0x4,%esp
  8007d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8007da:	ff 75 dc             	pushl  -0x24(%ebp)
  8007dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8007e0:	e8 db 1a 00 00       	call   8022c0 <__umoddi3>
  8007e5:	83 c4 14             	add    $0x14,%esp
  8007e8:	0f be 80 63 25 80 00 	movsbl 0x802563(%eax),%eax
  8007ef:	50                   	push   %eax
  8007f0:	ff d7                	call   *%edi
}
  8007f2:	83 c4 10             	add    $0x10,%esp
  8007f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f8:	5b                   	pop    %ebx
  8007f9:	5e                   	pop    %esi
  8007fa:	5f                   	pop    %edi
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007fd:	83 fa 01             	cmp    $0x1,%edx
  800800:	7f 13                	jg     800815 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800802:	85 d2                	test   %edx,%edx
  800804:	74 1c                	je     800822 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800806:	8b 10                	mov    (%eax),%edx
  800808:	8d 4a 04             	lea    0x4(%edx),%ecx
  80080b:	89 08                	mov    %ecx,(%eax)
  80080d:	8b 02                	mov    (%edx),%eax
  80080f:	ba 00 00 00 00       	mov    $0x0,%edx
  800814:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800815:	8b 10                	mov    (%eax),%edx
  800817:	8d 4a 08             	lea    0x8(%edx),%ecx
  80081a:	89 08                	mov    %ecx,(%eax)
  80081c:	8b 02                	mov    (%edx),%eax
  80081e:	8b 52 04             	mov    0x4(%edx),%edx
  800821:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800822:	8b 10                	mov    (%eax),%edx
  800824:	8d 4a 04             	lea    0x4(%edx),%ecx
  800827:	89 08                	mov    %ecx,(%eax)
  800829:	8b 02                	mov    (%edx),%eax
  80082b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800830:	c3                   	ret    

00800831 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800831:	83 fa 01             	cmp    $0x1,%edx
  800834:	7f 0f                	jg     800845 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800836:	85 d2                	test   %edx,%edx
  800838:	74 18                	je     800852 <getint+0x21>
		return va_arg(*ap, long);
  80083a:	8b 10                	mov    (%eax),%edx
  80083c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80083f:	89 08                	mov    %ecx,(%eax)
  800841:	8b 02                	mov    (%edx),%eax
  800843:	99                   	cltd   
  800844:	c3                   	ret    
		return va_arg(*ap, long long);
  800845:	8b 10                	mov    (%eax),%edx
  800847:	8d 4a 08             	lea    0x8(%edx),%ecx
  80084a:	89 08                	mov    %ecx,(%eax)
  80084c:	8b 02                	mov    (%edx),%eax
  80084e:	8b 52 04             	mov    0x4(%edx),%edx
  800851:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800852:	8b 10                	mov    (%eax),%edx
  800854:	8d 4a 04             	lea    0x4(%edx),%ecx
  800857:	89 08                	mov    %ecx,(%eax)
  800859:	8b 02                	mov    (%edx),%eax
  80085b:	99                   	cltd   
}
  80085c:	c3                   	ret    

0080085d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80085d:	f3 0f 1e fb          	endbr32 
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800867:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80086b:	8b 10                	mov    (%eax),%edx
  80086d:	3b 50 04             	cmp    0x4(%eax),%edx
  800870:	73 0a                	jae    80087c <sprintputch+0x1f>
		*b->buf++ = ch;
  800872:	8d 4a 01             	lea    0x1(%edx),%ecx
  800875:	89 08                	mov    %ecx,(%eax)
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	88 02                	mov    %al,(%edx)
}
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <printfmt>:
{
  80087e:	f3 0f 1e fb          	endbr32 
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800888:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80088b:	50                   	push   %eax
  80088c:	ff 75 10             	pushl  0x10(%ebp)
  80088f:	ff 75 0c             	pushl  0xc(%ebp)
  800892:	ff 75 08             	pushl  0x8(%ebp)
  800895:	e8 05 00 00 00       	call   80089f <vprintfmt>
}
  80089a:	83 c4 10             	add    $0x10,%esp
  80089d:	c9                   	leave  
  80089e:	c3                   	ret    

0080089f <vprintfmt>:
{
  80089f:	f3 0f 1e fb          	endbr32 
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	57                   	push   %edi
  8008a7:	56                   	push   %esi
  8008a8:	53                   	push   %ebx
  8008a9:	83 ec 2c             	sub    $0x2c,%esp
  8008ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008b5:	e9 86 02 00 00       	jmp    800b40 <vprintfmt+0x2a1>
		padc = ' ';
  8008ba:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8008be:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8008c5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8008cc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8008d3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8008d8:	8d 47 01             	lea    0x1(%edi),%eax
  8008db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008de:	0f b6 17             	movzbl (%edi),%edx
  8008e1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8008e4:	3c 55                	cmp    $0x55,%al
  8008e6:	0f 87 df 02 00 00    	ja     800bcb <vprintfmt+0x32c>
  8008ec:	0f b6 c0             	movzbl %al,%eax
  8008ef:	3e ff 24 85 a0 26 80 	notrack jmp *0x8026a0(,%eax,4)
  8008f6:	00 
  8008f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8008fa:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8008fe:	eb d8                	jmp    8008d8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800900:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800903:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800907:	eb cf                	jmp    8008d8 <vprintfmt+0x39>
  800909:	0f b6 d2             	movzbl %dl,%edx
  80090c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80090f:	b8 00 00 00 00       	mov    $0x0,%eax
  800914:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800917:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80091a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80091e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800921:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800924:	83 f9 09             	cmp    $0x9,%ecx
  800927:	77 52                	ja     80097b <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800929:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80092c:	eb e9                	jmp    800917 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80092e:	8b 45 14             	mov    0x14(%ebp),%eax
  800931:	8d 50 04             	lea    0x4(%eax),%edx
  800934:	89 55 14             	mov    %edx,0x14(%ebp)
  800937:	8b 00                	mov    (%eax),%eax
  800939:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80093c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80093f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800943:	79 93                	jns    8008d8 <vprintfmt+0x39>
				width = precision, precision = -1;
  800945:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800948:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80094b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800952:	eb 84                	jmp    8008d8 <vprintfmt+0x39>
  800954:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800957:	85 c0                	test   %eax,%eax
  800959:	ba 00 00 00 00       	mov    $0x0,%edx
  80095e:	0f 49 d0             	cmovns %eax,%edx
  800961:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800964:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800967:	e9 6c ff ff ff       	jmp    8008d8 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80096c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80096f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800976:	e9 5d ff ff ff       	jmp    8008d8 <vprintfmt+0x39>
  80097b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80097e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800981:	eb bc                	jmp    80093f <vprintfmt+0xa0>
			lflag++;
  800983:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800986:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800989:	e9 4a ff ff ff       	jmp    8008d8 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80098e:	8b 45 14             	mov    0x14(%ebp),%eax
  800991:	8d 50 04             	lea    0x4(%eax),%edx
  800994:	89 55 14             	mov    %edx,0x14(%ebp)
  800997:	83 ec 08             	sub    $0x8,%esp
  80099a:	56                   	push   %esi
  80099b:	ff 30                	pushl  (%eax)
  80099d:	ff d3                	call   *%ebx
			break;
  80099f:	83 c4 10             	add    $0x10,%esp
  8009a2:	e9 96 01 00 00       	jmp    800b3d <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8009a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009aa:	8d 50 04             	lea    0x4(%eax),%edx
  8009ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b0:	8b 00                	mov    (%eax),%eax
  8009b2:	99                   	cltd   
  8009b3:	31 d0                	xor    %edx,%eax
  8009b5:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009b7:	83 f8 0f             	cmp    $0xf,%eax
  8009ba:	7f 20                	jg     8009dc <vprintfmt+0x13d>
  8009bc:	8b 14 85 00 28 80 00 	mov    0x802800(,%eax,4),%edx
  8009c3:	85 d2                	test   %edx,%edx
  8009c5:	74 15                	je     8009dc <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8009c7:	52                   	push   %edx
  8009c8:	68 bd 29 80 00       	push   $0x8029bd
  8009cd:	56                   	push   %esi
  8009ce:	53                   	push   %ebx
  8009cf:	e8 aa fe ff ff       	call   80087e <printfmt>
  8009d4:	83 c4 10             	add    $0x10,%esp
  8009d7:	e9 61 01 00 00       	jmp    800b3d <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8009dc:	50                   	push   %eax
  8009dd:	68 7b 25 80 00       	push   $0x80257b
  8009e2:	56                   	push   %esi
  8009e3:	53                   	push   %ebx
  8009e4:	e8 95 fe ff ff       	call   80087e <printfmt>
  8009e9:	83 c4 10             	add    $0x10,%esp
  8009ec:	e9 4c 01 00 00       	jmp    800b3d <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8009f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f4:	8d 50 04             	lea    0x4(%eax),%edx
  8009f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8009fa:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8009fc:	85 c9                	test   %ecx,%ecx
  8009fe:	b8 74 25 80 00       	mov    $0x802574,%eax
  800a03:	0f 45 c1             	cmovne %ecx,%eax
  800a06:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800a09:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a0d:	7e 06                	jle    800a15 <vprintfmt+0x176>
  800a0f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800a13:	75 0d                	jne    800a22 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a15:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a18:	89 c7                	mov    %eax,%edi
  800a1a:	03 45 e0             	add    -0x20(%ebp),%eax
  800a1d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a20:	eb 57                	jmp    800a79 <vprintfmt+0x1da>
  800a22:	83 ec 08             	sub    $0x8,%esp
  800a25:	ff 75 d8             	pushl  -0x28(%ebp)
  800a28:	ff 75 cc             	pushl  -0x34(%ebp)
  800a2b:	e8 4f 02 00 00       	call   800c7f <strnlen>
  800a30:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800a33:	29 c2                	sub    %eax,%edx
  800a35:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a38:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a3b:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800a3f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800a42:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800a44:	85 db                	test   %ebx,%ebx
  800a46:	7e 10                	jle    800a58 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800a48:	83 ec 08             	sub    $0x8,%esp
  800a4b:	56                   	push   %esi
  800a4c:	57                   	push   %edi
  800a4d:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800a50:	83 eb 01             	sub    $0x1,%ebx
  800a53:	83 c4 10             	add    $0x10,%esp
  800a56:	eb ec                	jmp    800a44 <vprintfmt+0x1a5>
  800a58:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a5b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800a5e:	85 d2                	test   %edx,%edx
  800a60:	b8 00 00 00 00       	mov    $0x0,%eax
  800a65:	0f 49 c2             	cmovns %edx,%eax
  800a68:	29 c2                	sub    %eax,%edx
  800a6a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a6d:	eb a6                	jmp    800a15 <vprintfmt+0x176>
					putch(ch, putdat);
  800a6f:	83 ec 08             	sub    $0x8,%esp
  800a72:	56                   	push   %esi
  800a73:	52                   	push   %edx
  800a74:	ff d3                	call   *%ebx
  800a76:	83 c4 10             	add    $0x10,%esp
  800a79:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a7c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a7e:	83 c7 01             	add    $0x1,%edi
  800a81:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a85:	0f be d0             	movsbl %al,%edx
  800a88:	85 d2                	test   %edx,%edx
  800a8a:	74 42                	je     800ace <vprintfmt+0x22f>
  800a8c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a90:	78 06                	js     800a98 <vprintfmt+0x1f9>
  800a92:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800a96:	78 1e                	js     800ab6 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800a98:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800a9c:	74 d1                	je     800a6f <vprintfmt+0x1d0>
  800a9e:	0f be c0             	movsbl %al,%eax
  800aa1:	83 e8 20             	sub    $0x20,%eax
  800aa4:	83 f8 5e             	cmp    $0x5e,%eax
  800aa7:	76 c6                	jbe    800a6f <vprintfmt+0x1d0>
					putch('?', putdat);
  800aa9:	83 ec 08             	sub    $0x8,%esp
  800aac:	56                   	push   %esi
  800aad:	6a 3f                	push   $0x3f
  800aaf:	ff d3                	call   *%ebx
  800ab1:	83 c4 10             	add    $0x10,%esp
  800ab4:	eb c3                	jmp    800a79 <vprintfmt+0x1da>
  800ab6:	89 cf                	mov    %ecx,%edi
  800ab8:	eb 0e                	jmp    800ac8 <vprintfmt+0x229>
				putch(' ', putdat);
  800aba:	83 ec 08             	sub    $0x8,%esp
  800abd:	56                   	push   %esi
  800abe:	6a 20                	push   $0x20
  800ac0:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800ac2:	83 ef 01             	sub    $0x1,%edi
  800ac5:	83 c4 10             	add    $0x10,%esp
  800ac8:	85 ff                	test   %edi,%edi
  800aca:	7f ee                	jg     800aba <vprintfmt+0x21b>
  800acc:	eb 6f                	jmp    800b3d <vprintfmt+0x29e>
  800ace:	89 cf                	mov    %ecx,%edi
  800ad0:	eb f6                	jmp    800ac8 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800ad2:	89 ca                	mov    %ecx,%edx
  800ad4:	8d 45 14             	lea    0x14(%ebp),%eax
  800ad7:	e8 55 fd ff ff       	call   800831 <getint>
  800adc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800adf:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800ae2:	85 d2                	test   %edx,%edx
  800ae4:	78 0b                	js     800af1 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800ae6:	89 d1                	mov    %edx,%ecx
  800ae8:	89 c2                	mov    %eax,%edx
			base = 10;
  800aea:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aef:	eb 32                	jmp    800b23 <vprintfmt+0x284>
				putch('-', putdat);
  800af1:	83 ec 08             	sub    $0x8,%esp
  800af4:	56                   	push   %esi
  800af5:	6a 2d                	push   $0x2d
  800af7:	ff d3                	call   *%ebx
				num = -(long long) num;
  800af9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800afc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800aff:	f7 da                	neg    %edx
  800b01:	83 d1 00             	adc    $0x0,%ecx
  800b04:	f7 d9                	neg    %ecx
  800b06:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800b09:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b0e:	eb 13                	jmp    800b23 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800b10:	89 ca                	mov    %ecx,%edx
  800b12:	8d 45 14             	lea    0x14(%ebp),%eax
  800b15:	e8 e3 fc ff ff       	call   8007fd <getuint>
  800b1a:	89 d1                	mov    %edx,%ecx
  800b1c:	89 c2                	mov    %eax,%edx
			base = 10;
  800b1e:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800b23:	83 ec 0c             	sub    $0xc,%esp
  800b26:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800b2a:	57                   	push   %edi
  800b2b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b2e:	50                   	push   %eax
  800b2f:	51                   	push   %ecx
  800b30:	52                   	push   %edx
  800b31:	89 f2                	mov    %esi,%edx
  800b33:	89 d8                	mov    %ebx,%eax
  800b35:	e8 1a fc ff ff       	call   800754 <printnum>
			break;
  800b3a:	83 c4 20             	add    $0x20,%esp
{
  800b3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b40:	83 c7 01             	add    $0x1,%edi
  800b43:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800b47:	83 f8 25             	cmp    $0x25,%eax
  800b4a:	0f 84 6a fd ff ff    	je     8008ba <vprintfmt+0x1b>
			if (ch == '\0')
  800b50:	85 c0                	test   %eax,%eax
  800b52:	0f 84 93 00 00 00    	je     800beb <vprintfmt+0x34c>
			putch(ch, putdat);
  800b58:	83 ec 08             	sub    $0x8,%esp
  800b5b:	56                   	push   %esi
  800b5c:	50                   	push   %eax
  800b5d:	ff d3                	call   *%ebx
  800b5f:	83 c4 10             	add    $0x10,%esp
  800b62:	eb dc                	jmp    800b40 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800b64:	89 ca                	mov    %ecx,%edx
  800b66:	8d 45 14             	lea    0x14(%ebp),%eax
  800b69:	e8 8f fc ff ff       	call   8007fd <getuint>
  800b6e:	89 d1                	mov    %edx,%ecx
  800b70:	89 c2                	mov    %eax,%edx
			base = 8;
  800b72:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b77:	eb aa                	jmp    800b23 <vprintfmt+0x284>
			putch('0', putdat);
  800b79:	83 ec 08             	sub    $0x8,%esp
  800b7c:	56                   	push   %esi
  800b7d:	6a 30                	push   $0x30
  800b7f:	ff d3                	call   *%ebx
			putch('x', putdat);
  800b81:	83 c4 08             	add    $0x8,%esp
  800b84:	56                   	push   %esi
  800b85:	6a 78                	push   $0x78
  800b87:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800b89:	8b 45 14             	mov    0x14(%ebp),%eax
  800b8c:	8d 50 04             	lea    0x4(%eax),%edx
  800b8f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800b92:	8b 10                	mov    (%eax),%edx
  800b94:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800b99:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800b9c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800ba1:	eb 80                	jmp    800b23 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800ba3:	89 ca                	mov    %ecx,%edx
  800ba5:	8d 45 14             	lea    0x14(%ebp),%eax
  800ba8:	e8 50 fc ff ff       	call   8007fd <getuint>
  800bad:	89 d1                	mov    %edx,%ecx
  800baf:	89 c2                	mov    %eax,%edx
			base = 16;
  800bb1:	b8 10 00 00 00       	mov    $0x10,%eax
  800bb6:	e9 68 ff ff ff       	jmp    800b23 <vprintfmt+0x284>
			putch(ch, putdat);
  800bbb:	83 ec 08             	sub    $0x8,%esp
  800bbe:	56                   	push   %esi
  800bbf:	6a 25                	push   $0x25
  800bc1:	ff d3                	call   *%ebx
			break;
  800bc3:	83 c4 10             	add    $0x10,%esp
  800bc6:	e9 72 ff ff ff       	jmp    800b3d <vprintfmt+0x29e>
			putch('%', putdat);
  800bcb:	83 ec 08             	sub    $0x8,%esp
  800bce:	56                   	push   %esi
  800bcf:	6a 25                	push   $0x25
  800bd1:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bd3:	83 c4 10             	add    $0x10,%esp
  800bd6:	89 f8                	mov    %edi,%eax
  800bd8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800bdc:	74 05                	je     800be3 <vprintfmt+0x344>
  800bde:	83 e8 01             	sub    $0x1,%eax
  800be1:	eb f5                	jmp    800bd8 <vprintfmt+0x339>
  800be3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800be6:	e9 52 ff ff ff       	jmp    800b3d <vprintfmt+0x29e>
}
  800beb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bf3:	f3 0f 1e fb          	endbr32 
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	83 ec 18             	sub    $0x18,%esp
  800bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800c00:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c03:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c06:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c0a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c0d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c14:	85 c0                	test   %eax,%eax
  800c16:	74 26                	je     800c3e <vsnprintf+0x4b>
  800c18:	85 d2                	test   %edx,%edx
  800c1a:	7e 22                	jle    800c3e <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c1c:	ff 75 14             	pushl  0x14(%ebp)
  800c1f:	ff 75 10             	pushl  0x10(%ebp)
  800c22:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c25:	50                   	push   %eax
  800c26:	68 5d 08 80 00       	push   $0x80085d
  800c2b:	e8 6f fc ff ff       	call   80089f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c30:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c33:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c39:	83 c4 10             	add    $0x10,%esp
}
  800c3c:	c9                   	leave  
  800c3d:	c3                   	ret    
		return -E_INVAL;
  800c3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c43:	eb f7                	jmp    800c3c <vsnprintf+0x49>

00800c45 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c45:	f3 0f 1e fb          	endbr32 
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c4f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c52:	50                   	push   %eax
  800c53:	ff 75 10             	pushl  0x10(%ebp)
  800c56:	ff 75 0c             	pushl  0xc(%ebp)
  800c59:	ff 75 08             	pushl  0x8(%ebp)
  800c5c:	e8 92 ff ff ff       	call   800bf3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c61:	c9                   	leave  
  800c62:	c3                   	ret    

00800c63 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c63:	f3 0f 1e fb          	endbr32 
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c72:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c76:	74 05                	je     800c7d <strlen+0x1a>
		n++;
  800c78:	83 c0 01             	add    $0x1,%eax
  800c7b:	eb f5                	jmp    800c72 <strlen+0xf>
	return n;
}
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c7f:	f3 0f 1e fb          	endbr32 
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c89:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c91:	39 d0                	cmp    %edx,%eax
  800c93:	74 0d                	je     800ca2 <strnlen+0x23>
  800c95:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c99:	74 05                	je     800ca0 <strnlen+0x21>
		n++;
  800c9b:	83 c0 01             	add    $0x1,%eax
  800c9e:	eb f1                	jmp    800c91 <strnlen+0x12>
  800ca0:	89 c2                	mov    %eax,%edx
	return n;
}
  800ca2:	89 d0                	mov    %edx,%eax
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ca6:	f3 0f 1e fb          	endbr32 
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	53                   	push   %ebx
  800cae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800cbd:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800cc0:	83 c0 01             	add    $0x1,%eax
  800cc3:	84 d2                	test   %dl,%dl
  800cc5:	75 f2                	jne    800cb9 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800cc7:	89 c8                	mov    %ecx,%eax
  800cc9:	5b                   	pop    %ebx
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ccc:	f3 0f 1e fb          	endbr32 
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 10             	sub    $0x10,%esp
  800cd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cda:	53                   	push   %ebx
  800cdb:	e8 83 ff ff ff       	call   800c63 <strlen>
  800ce0:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800ce3:	ff 75 0c             	pushl  0xc(%ebp)
  800ce6:	01 d8                	add    %ebx,%eax
  800ce8:	50                   	push   %eax
  800ce9:	e8 b8 ff ff ff       	call   800ca6 <strcpy>
	return dst;
}
  800cee:	89 d8                	mov    %ebx,%eax
  800cf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cf3:	c9                   	leave  
  800cf4:	c3                   	ret    

00800cf5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cf5:	f3 0f 1e fb          	endbr32 
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
  800cfe:	8b 75 08             	mov    0x8(%ebp),%esi
  800d01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d04:	89 f3                	mov    %esi,%ebx
  800d06:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d09:	89 f0                	mov    %esi,%eax
  800d0b:	39 d8                	cmp    %ebx,%eax
  800d0d:	74 11                	je     800d20 <strncpy+0x2b>
		*dst++ = *src;
  800d0f:	83 c0 01             	add    $0x1,%eax
  800d12:	0f b6 0a             	movzbl (%edx),%ecx
  800d15:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d18:	80 f9 01             	cmp    $0x1,%cl
  800d1b:	83 da ff             	sbb    $0xffffffff,%edx
  800d1e:	eb eb                	jmp    800d0b <strncpy+0x16>
	}
	return ret;
}
  800d20:	89 f0                	mov    %esi,%eax
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d26:	f3 0f 1e fb          	endbr32 
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	8b 75 08             	mov    0x8(%ebp),%esi
  800d32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d35:	8b 55 10             	mov    0x10(%ebp),%edx
  800d38:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d3a:	85 d2                	test   %edx,%edx
  800d3c:	74 21                	je     800d5f <strlcpy+0x39>
  800d3e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d42:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800d44:	39 c2                	cmp    %eax,%edx
  800d46:	74 14                	je     800d5c <strlcpy+0x36>
  800d48:	0f b6 19             	movzbl (%ecx),%ebx
  800d4b:	84 db                	test   %bl,%bl
  800d4d:	74 0b                	je     800d5a <strlcpy+0x34>
			*dst++ = *src++;
  800d4f:	83 c1 01             	add    $0x1,%ecx
  800d52:	83 c2 01             	add    $0x1,%edx
  800d55:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d58:	eb ea                	jmp    800d44 <strlcpy+0x1e>
  800d5a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800d5c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d5f:	29 f0                	sub    %esi,%eax
}
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d65:	f3 0f 1e fb          	endbr32 
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d6f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d72:	0f b6 01             	movzbl (%ecx),%eax
  800d75:	84 c0                	test   %al,%al
  800d77:	74 0c                	je     800d85 <strcmp+0x20>
  800d79:	3a 02                	cmp    (%edx),%al
  800d7b:	75 08                	jne    800d85 <strcmp+0x20>
		p++, q++;
  800d7d:	83 c1 01             	add    $0x1,%ecx
  800d80:	83 c2 01             	add    $0x1,%edx
  800d83:	eb ed                	jmp    800d72 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d85:	0f b6 c0             	movzbl %al,%eax
  800d88:	0f b6 12             	movzbl (%edx),%edx
  800d8b:	29 d0                	sub    %edx,%eax
}
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d8f:	f3 0f 1e fb          	endbr32 
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	53                   	push   %ebx
  800d97:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9d:	89 c3                	mov    %eax,%ebx
  800d9f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800da2:	eb 06                	jmp    800daa <strncmp+0x1b>
		n--, p++, q++;
  800da4:	83 c0 01             	add    $0x1,%eax
  800da7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800daa:	39 d8                	cmp    %ebx,%eax
  800dac:	74 16                	je     800dc4 <strncmp+0x35>
  800dae:	0f b6 08             	movzbl (%eax),%ecx
  800db1:	84 c9                	test   %cl,%cl
  800db3:	74 04                	je     800db9 <strncmp+0x2a>
  800db5:	3a 0a                	cmp    (%edx),%cl
  800db7:	74 eb                	je     800da4 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800db9:	0f b6 00             	movzbl (%eax),%eax
  800dbc:	0f b6 12             	movzbl (%edx),%edx
  800dbf:	29 d0                	sub    %edx,%eax
}
  800dc1:	5b                   	pop    %ebx
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    
		return 0;
  800dc4:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc9:	eb f6                	jmp    800dc1 <strncmp+0x32>

00800dcb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dcb:	f3 0f 1e fb          	endbr32 
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800dd9:	0f b6 10             	movzbl (%eax),%edx
  800ddc:	84 d2                	test   %dl,%dl
  800dde:	74 09                	je     800de9 <strchr+0x1e>
		if (*s == c)
  800de0:	38 ca                	cmp    %cl,%dl
  800de2:	74 0a                	je     800dee <strchr+0x23>
	for (; *s; s++)
  800de4:	83 c0 01             	add    $0x1,%eax
  800de7:	eb f0                	jmp    800dd9 <strchr+0xe>
			return (char *) s;
	return 0;
  800de9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800df0:	f3 0f 1e fb          	endbr32 
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800dfe:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e01:	38 ca                	cmp    %cl,%dl
  800e03:	74 09                	je     800e0e <strfind+0x1e>
  800e05:	84 d2                	test   %dl,%dl
  800e07:	74 05                	je     800e0e <strfind+0x1e>
	for (; *s; s++)
  800e09:	83 c0 01             	add    $0x1,%eax
  800e0c:	eb f0                	jmp    800dfe <strfind+0xe>
			break;
	return (char *) s;
}
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e10:	f3 0f 1e fb          	endbr32 
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
  800e1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800e20:	85 c9                	test   %ecx,%ecx
  800e22:	74 33                	je     800e57 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e24:	89 d0                	mov    %edx,%eax
  800e26:	09 c8                	or     %ecx,%eax
  800e28:	a8 03                	test   $0x3,%al
  800e2a:	75 23                	jne    800e4f <memset+0x3f>
		c &= 0xFF;
  800e2c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e30:	89 d8                	mov    %ebx,%eax
  800e32:	c1 e0 08             	shl    $0x8,%eax
  800e35:	89 df                	mov    %ebx,%edi
  800e37:	c1 e7 18             	shl    $0x18,%edi
  800e3a:	89 de                	mov    %ebx,%esi
  800e3c:	c1 e6 10             	shl    $0x10,%esi
  800e3f:	09 f7                	or     %esi,%edi
  800e41:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800e43:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e46:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800e48:	89 d7                	mov    %edx,%edi
  800e4a:	fc                   	cld    
  800e4b:	f3 ab                	rep stos %eax,%es:(%edi)
  800e4d:	eb 08                	jmp    800e57 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e4f:	89 d7                	mov    %edx,%edi
  800e51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e54:	fc                   	cld    
  800e55:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800e57:	89 d0                	mov    %edx,%eax
  800e59:	5b                   	pop    %ebx
  800e5a:	5e                   	pop    %esi
  800e5b:	5f                   	pop    %edi
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    

00800e5e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e5e:	f3 0f 1e fb          	endbr32 
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	57                   	push   %edi
  800e66:	56                   	push   %esi
  800e67:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e6d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e70:	39 c6                	cmp    %eax,%esi
  800e72:	73 32                	jae    800ea6 <memmove+0x48>
  800e74:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e77:	39 c2                	cmp    %eax,%edx
  800e79:	76 2b                	jbe    800ea6 <memmove+0x48>
		s += n;
		d += n;
  800e7b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e7e:	89 fe                	mov    %edi,%esi
  800e80:	09 ce                	or     %ecx,%esi
  800e82:	09 d6                	or     %edx,%esi
  800e84:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e8a:	75 0e                	jne    800e9a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e8c:	83 ef 04             	sub    $0x4,%edi
  800e8f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e92:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800e95:	fd                   	std    
  800e96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e98:	eb 09                	jmp    800ea3 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e9a:	83 ef 01             	sub    $0x1,%edi
  800e9d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ea0:	fd                   	std    
  800ea1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ea3:	fc                   	cld    
  800ea4:	eb 1a                	jmp    800ec0 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ea6:	89 c2                	mov    %eax,%edx
  800ea8:	09 ca                	or     %ecx,%edx
  800eaa:	09 f2                	or     %esi,%edx
  800eac:	f6 c2 03             	test   $0x3,%dl
  800eaf:	75 0a                	jne    800ebb <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800eb1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800eb4:	89 c7                	mov    %eax,%edi
  800eb6:	fc                   	cld    
  800eb7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eb9:	eb 05                	jmp    800ec0 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800ebb:	89 c7                	mov    %eax,%edi
  800ebd:	fc                   	cld    
  800ebe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ec4:	f3 0f 1e fb          	endbr32 
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ece:	ff 75 10             	pushl  0x10(%ebp)
  800ed1:	ff 75 0c             	pushl  0xc(%ebp)
  800ed4:	ff 75 08             	pushl  0x8(%ebp)
  800ed7:	e8 82 ff ff ff       	call   800e5e <memmove>
}
  800edc:	c9                   	leave  
  800edd:	c3                   	ret    

00800ede <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ede:	f3 0f 1e fb          	endbr32 
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	56                   	push   %esi
  800ee6:	53                   	push   %ebx
  800ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eea:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eed:	89 c6                	mov    %eax,%esi
  800eef:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ef2:	39 f0                	cmp    %esi,%eax
  800ef4:	74 1c                	je     800f12 <memcmp+0x34>
		if (*s1 != *s2)
  800ef6:	0f b6 08             	movzbl (%eax),%ecx
  800ef9:	0f b6 1a             	movzbl (%edx),%ebx
  800efc:	38 d9                	cmp    %bl,%cl
  800efe:	75 08                	jne    800f08 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800f00:	83 c0 01             	add    $0x1,%eax
  800f03:	83 c2 01             	add    $0x1,%edx
  800f06:	eb ea                	jmp    800ef2 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800f08:	0f b6 c1             	movzbl %cl,%eax
  800f0b:	0f b6 db             	movzbl %bl,%ebx
  800f0e:	29 d8                	sub    %ebx,%eax
  800f10:	eb 05                	jmp    800f17 <memcmp+0x39>
	}

	return 0;
  800f12:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f17:	5b                   	pop    %ebx
  800f18:	5e                   	pop    %esi
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    

00800f1b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f1b:	f3 0f 1e fb          	endbr32 
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	8b 45 08             	mov    0x8(%ebp),%eax
  800f25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f28:	89 c2                	mov    %eax,%edx
  800f2a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f2d:	39 d0                	cmp    %edx,%eax
  800f2f:	73 09                	jae    800f3a <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f31:	38 08                	cmp    %cl,(%eax)
  800f33:	74 05                	je     800f3a <memfind+0x1f>
	for (; s < ends; s++)
  800f35:	83 c0 01             	add    $0x1,%eax
  800f38:	eb f3                	jmp    800f2d <memfind+0x12>
			break;
	return (void *) s;
}
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f3c:	f3 0f 1e fb          	endbr32 
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
  800f46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f49:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f4c:	eb 03                	jmp    800f51 <strtol+0x15>
		s++;
  800f4e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800f51:	0f b6 01             	movzbl (%ecx),%eax
  800f54:	3c 20                	cmp    $0x20,%al
  800f56:	74 f6                	je     800f4e <strtol+0x12>
  800f58:	3c 09                	cmp    $0x9,%al
  800f5a:	74 f2                	je     800f4e <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800f5c:	3c 2b                	cmp    $0x2b,%al
  800f5e:	74 2a                	je     800f8a <strtol+0x4e>
	int neg = 0;
  800f60:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800f65:	3c 2d                	cmp    $0x2d,%al
  800f67:	74 2b                	je     800f94 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f69:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f6f:	75 0f                	jne    800f80 <strtol+0x44>
  800f71:	80 39 30             	cmpb   $0x30,(%ecx)
  800f74:	74 28                	je     800f9e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f76:	85 db                	test   %ebx,%ebx
  800f78:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f7d:	0f 44 d8             	cmove  %eax,%ebx
  800f80:	b8 00 00 00 00       	mov    $0x0,%eax
  800f85:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800f88:	eb 46                	jmp    800fd0 <strtol+0x94>
		s++;
  800f8a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800f8d:	bf 00 00 00 00       	mov    $0x0,%edi
  800f92:	eb d5                	jmp    800f69 <strtol+0x2d>
		s++, neg = 1;
  800f94:	83 c1 01             	add    $0x1,%ecx
  800f97:	bf 01 00 00 00       	mov    $0x1,%edi
  800f9c:	eb cb                	jmp    800f69 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f9e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800fa2:	74 0e                	je     800fb2 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800fa4:	85 db                	test   %ebx,%ebx
  800fa6:	75 d8                	jne    800f80 <strtol+0x44>
		s++, base = 8;
  800fa8:	83 c1 01             	add    $0x1,%ecx
  800fab:	bb 08 00 00 00       	mov    $0x8,%ebx
  800fb0:	eb ce                	jmp    800f80 <strtol+0x44>
		s += 2, base = 16;
  800fb2:	83 c1 02             	add    $0x2,%ecx
  800fb5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fba:	eb c4                	jmp    800f80 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800fbc:	0f be d2             	movsbl %dl,%edx
  800fbf:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800fc2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800fc5:	7d 3a                	jge    801001 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800fc7:	83 c1 01             	add    $0x1,%ecx
  800fca:	0f af 45 10          	imul   0x10(%ebp),%eax
  800fce:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800fd0:	0f b6 11             	movzbl (%ecx),%edx
  800fd3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fd6:	89 f3                	mov    %esi,%ebx
  800fd8:	80 fb 09             	cmp    $0x9,%bl
  800fdb:	76 df                	jbe    800fbc <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800fdd:	8d 72 9f             	lea    -0x61(%edx),%esi
  800fe0:	89 f3                	mov    %esi,%ebx
  800fe2:	80 fb 19             	cmp    $0x19,%bl
  800fe5:	77 08                	ja     800fef <strtol+0xb3>
			dig = *s - 'a' + 10;
  800fe7:	0f be d2             	movsbl %dl,%edx
  800fea:	83 ea 57             	sub    $0x57,%edx
  800fed:	eb d3                	jmp    800fc2 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800fef:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ff2:	89 f3                	mov    %esi,%ebx
  800ff4:	80 fb 19             	cmp    $0x19,%bl
  800ff7:	77 08                	ja     801001 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ff9:	0f be d2             	movsbl %dl,%edx
  800ffc:	83 ea 37             	sub    $0x37,%edx
  800fff:	eb c1                	jmp    800fc2 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801001:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801005:	74 05                	je     80100c <strtol+0xd0>
		*endptr = (char *) s;
  801007:	8b 75 0c             	mov    0xc(%ebp),%esi
  80100a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  80100c:	89 c2                	mov    %eax,%edx
  80100e:	f7 da                	neg    %edx
  801010:	85 ff                	test   %edi,%edi
  801012:	0f 45 c2             	cmovne %edx,%eax
}
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	57                   	push   %edi
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
  801020:	83 ec 1c             	sub    $0x1c,%esp
  801023:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801026:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801029:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80102b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80102e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801031:	8b 7d 10             	mov    0x10(%ebp),%edi
  801034:	8b 75 14             	mov    0x14(%ebp),%esi
  801037:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801039:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80103d:	74 04                	je     801043 <syscall+0x29>
  80103f:	85 c0                	test   %eax,%eax
  801041:	7f 08                	jg     80104b <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  801043:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801046:	5b                   	pop    %ebx
  801047:	5e                   	pop    %esi
  801048:	5f                   	pop    %edi
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80104b:	83 ec 0c             	sub    $0xc,%esp
  80104e:	50                   	push   %eax
  80104f:	ff 75 e0             	pushl  -0x20(%ebp)
  801052:	68 5f 28 80 00       	push   $0x80285f
  801057:	6a 23                	push   $0x23
  801059:	68 7c 28 80 00       	push   $0x80287c
  80105e:	e8 f2 f5 ff ff       	call   800655 <_panic>

00801063 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  801063:	f3 0f 1e fb          	endbr32 
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80106d:	6a 00                	push   $0x0
  80106f:	6a 00                	push   $0x0
  801071:	6a 00                	push   $0x0
  801073:	ff 75 0c             	pushl  0xc(%ebp)
  801076:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801079:	ba 00 00 00 00       	mov    $0x0,%edx
  80107e:	b8 00 00 00 00       	mov    $0x0,%eax
  801083:	e8 92 ff ff ff       	call   80101a <syscall>
}
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	c9                   	leave  
  80108c:	c3                   	ret    

0080108d <sys_cgetc>:

int
sys_cgetc(void)
{
  80108d:	f3 0f 1e fb          	endbr32 
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801097:	6a 00                	push   $0x0
  801099:	6a 00                	push   $0x0
  80109b:	6a 00                	push   $0x0
  80109d:	6a 00                	push   $0x0
  80109f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ae:	e8 67 ff ff ff       	call   80101a <syscall>
}
  8010b3:	c9                   	leave  
  8010b4:	c3                   	ret    

008010b5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010b5:	f3 0f 1e fb          	endbr32 
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8010bf:	6a 00                	push   $0x0
  8010c1:	6a 00                	push   $0x0
  8010c3:	6a 00                	push   $0x0
  8010c5:	6a 00                	push   $0x0
  8010c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ca:	ba 01 00 00 00       	mov    $0x1,%edx
  8010cf:	b8 03 00 00 00       	mov    $0x3,%eax
  8010d4:	e8 41 ff ff ff       	call   80101a <syscall>
}
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010db:	f3 0f 1e fb          	endbr32 
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8010e5:	6a 00                	push   $0x0
  8010e7:	6a 00                	push   $0x0
  8010e9:	6a 00                	push   $0x0
  8010eb:	6a 00                	push   $0x0
  8010ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f7:	b8 02 00 00 00       	mov    $0x2,%eax
  8010fc:	e8 19 ff ff ff       	call   80101a <syscall>
}
  801101:	c9                   	leave  
  801102:	c3                   	ret    

00801103 <sys_yield>:

void
sys_yield(void)
{
  801103:	f3 0f 1e fb          	endbr32 
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80110d:	6a 00                	push   $0x0
  80110f:	6a 00                	push   $0x0
  801111:	6a 00                	push   $0x0
  801113:	6a 00                	push   $0x0
  801115:	b9 00 00 00 00       	mov    $0x0,%ecx
  80111a:	ba 00 00 00 00       	mov    $0x0,%edx
  80111f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801124:	e8 f1 fe ff ff       	call   80101a <syscall>
}
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	c9                   	leave  
  80112d:	c3                   	ret    

0080112e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80112e:	f3 0f 1e fb          	endbr32 
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801138:	6a 00                	push   $0x0
  80113a:	6a 00                	push   $0x0
  80113c:	ff 75 10             	pushl  0x10(%ebp)
  80113f:	ff 75 0c             	pushl  0xc(%ebp)
  801142:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801145:	ba 01 00 00 00       	mov    $0x1,%edx
  80114a:	b8 04 00 00 00       	mov    $0x4,%eax
  80114f:	e8 c6 fe ff ff       	call   80101a <syscall>
}
  801154:	c9                   	leave  
  801155:	c3                   	ret    

00801156 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801156:	f3 0f 1e fb          	endbr32 
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801160:	ff 75 18             	pushl  0x18(%ebp)
  801163:	ff 75 14             	pushl  0x14(%ebp)
  801166:	ff 75 10             	pushl  0x10(%ebp)
  801169:	ff 75 0c             	pushl  0xc(%ebp)
  80116c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116f:	ba 01 00 00 00       	mov    $0x1,%edx
  801174:	b8 05 00 00 00       	mov    $0x5,%eax
  801179:	e8 9c fe ff ff       	call   80101a <syscall>
}
  80117e:	c9                   	leave  
  80117f:	c3                   	ret    

00801180 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801180:	f3 0f 1e fb          	endbr32 
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80118a:	6a 00                	push   $0x0
  80118c:	6a 00                	push   $0x0
  80118e:	6a 00                	push   $0x0
  801190:	ff 75 0c             	pushl  0xc(%ebp)
  801193:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801196:	ba 01 00 00 00       	mov    $0x1,%edx
  80119b:	b8 06 00 00 00       	mov    $0x6,%eax
  8011a0:	e8 75 fe ff ff       	call   80101a <syscall>
}
  8011a5:	c9                   	leave  
  8011a6:	c3                   	ret    

008011a7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011a7:	f3 0f 1e fb          	endbr32 
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8011b1:	6a 00                	push   $0x0
  8011b3:	6a 00                	push   $0x0
  8011b5:	6a 00                	push   $0x0
  8011b7:	ff 75 0c             	pushl  0xc(%ebp)
  8011ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011bd:	ba 01 00 00 00       	mov    $0x1,%edx
  8011c2:	b8 08 00 00 00       	mov    $0x8,%eax
  8011c7:	e8 4e fe ff ff       	call   80101a <syscall>
}
  8011cc:	c9                   	leave  
  8011cd:	c3                   	ret    

008011ce <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011ce:	f3 0f 1e fb          	endbr32 
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  8011d8:	6a 00                	push   $0x0
  8011da:	6a 00                	push   $0x0
  8011dc:	6a 00                	push   $0x0
  8011de:	ff 75 0c             	pushl  0xc(%ebp)
  8011e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e4:	ba 01 00 00 00       	mov    $0x1,%edx
  8011e9:	b8 09 00 00 00       	mov    $0x9,%eax
  8011ee:	e8 27 fe ff ff       	call   80101a <syscall>
}
  8011f3:	c9                   	leave  
  8011f4:	c3                   	ret    

008011f5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011f5:	f3 0f 1e fb          	endbr32 
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8011ff:	6a 00                	push   $0x0
  801201:	6a 00                	push   $0x0
  801203:	6a 00                	push   $0x0
  801205:	ff 75 0c             	pushl  0xc(%ebp)
  801208:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120b:	ba 01 00 00 00       	mov    $0x1,%edx
  801210:	b8 0a 00 00 00       	mov    $0xa,%eax
  801215:	e8 00 fe ff ff       	call   80101a <syscall>
}
  80121a:	c9                   	leave  
  80121b:	c3                   	ret    

0080121c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80121c:	f3 0f 1e fb          	endbr32 
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801226:	6a 00                	push   $0x0
  801228:	ff 75 14             	pushl  0x14(%ebp)
  80122b:	ff 75 10             	pushl  0x10(%ebp)
  80122e:	ff 75 0c             	pushl  0xc(%ebp)
  801231:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801234:	ba 00 00 00 00       	mov    $0x0,%edx
  801239:	b8 0c 00 00 00       	mov    $0xc,%eax
  80123e:	e8 d7 fd ff ff       	call   80101a <syscall>
}
  801243:	c9                   	leave  
  801244:	c3                   	ret    

00801245 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801245:	f3 0f 1e fb          	endbr32 
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80124f:	6a 00                	push   $0x0
  801251:	6a 00                	push   $0x0
  801253:	6a 00                	push   $0x0
  801255:	6a 00                	push   $0x0
  801257:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80125a:	ba 01 00 00 00       	mov    $0x1,%edx
  80125f:	b8 0d 00 00 00       	mov    $0xd,%eax
  801264:	e8 b1 fd ff ff       	call   80101a <syscall>
}
  801269:	c9                   	leave  
  80126a:	c3                   	ret    

0080126b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80126b:	f3 0f 1e fb          	endbr32 
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801275:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  80127c:	74 0a                	je     801288 <set_pgfault_handler+0x1d>
			      "SYS_ENV_SET_PGFAULT_UPCALL FAILED");
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80127e:	8b 45 08             	mov    0x8(%ebp),%eax
  801281:	a3 b4 40 80 00       	mov    %eax,0x8040b4
}
  801286:	c9                   	leave  
  801287:	c3                   	ret    
		if (sys_page_alloc(0,
  801288:	83 ec 04             	sub    $0x4,%esp
  80128b:	6a 07                	push   $0x7
  80128d:	68 00 f0 bf ee       	push   $0xeebff000
  801292:	6a 00                	push   $0x0
  801294:	e8 95 fe ff ff       	call   80112e <sys_page_alloc>
  801299:	83 c4 10             	add    $0x10,%esp
  80129c:	85 c0                	test   %eax,%eax
  80129e:	78 2a                	js     8012ca <set_pgfault_handler+0x5f>
		if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0) {
  8012a0:	83 ec 08             	sub    $0x8,%esp
  8012a3:	68 de 12 80 00       	push   $0x8012de
  8012a8:	6a 00                	push   $0x0
  8012aa:	e8 46 ff ff ff       	call   8011f5 <sys_env_set_pgfault_upcall>
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	79 c8                	jns    80127e <set_pgfault_handler+0x13>
			panic("ERROR ON SYS_ENV_SET_PGFAULT_UPCALL: "
  8012b6:	83 ec 04             	sub    $0x4,%esp
  8012b9:	68 c0 28 80 00       	push   $0x8028c0
  8012be:	6a 25                	push   $0x25
  8012c0:	68 07 29 80 00       	push   $0x802907
  8012c5:	e8 8b f3 ff ff       	call   800655 <_panic>
			panic("ERROR ON SET_PGFAULT_HANDLER: SYS_PAGE_ALLOC "
  8012ca:	83 ec 04             	sub    $0x4,%esp
  8012cd:	68 8c 28 80 00       	push   $0x80288c
  8012d2:	6a 21                	push   $0x21
  8012d4:	68 07 29 80 00       	push   $0x802907
  8012d9:	e8 77 f3 ff ff       	call   800655 <_panic>

008012de <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012de:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012df:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  8012e4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012e6:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  8012e9:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  8012ee:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %ebx
  8012f2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8012f6:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  8012f8:	83 c4 08             	add    $0x8,%esp
	popal
  8012fb:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  8012fc:	83 c4 04             	add    $0x4,%esp
	popfl
  8012ff:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  801300:	8b 24 24             	mov    (%esp),%esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  801303:	c3                   	ret    

00801304 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801304:	f3 0f 1e fb          	endbr32 
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80130b:	8b 45 08             	mov    0x8(%ebp),%eax
  80130e:	05 00 00 00 30       	add    $0x30000000,%eax
  801313:	c1 e8 0c             	shr    $0xc,%eax
}
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801318:	f3 0f 1e fb          	endbr32 
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  801322:	ff 75 08             	pushl  0x8(%ebp)
  801325:	e8 da ff ff ff       	call   801304 <fd2num>
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	c1 e0 0c             	shl    $0xc,%eax
  801330:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801335:	c9                   	leave  
  801336:	c3                   	ret    

00801337 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801337:	f3 0f 1e fb          	endbr32 
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801343:	89 c2                	mov    %eax,%edx
  801345:	c1 ea 16             	shr    $0x16,%edx
  801348:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80134f:	f6 c2 01             	test   $0x1,%dl
  801352:	74 2d                	je     801381 <fd_alloc+0x4a>
  801354:	89 c2                	mov    %eax,%edx
  801356:	c1 ea 0c             	shr    $0xc,%edx
  801359:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801360:	f6 c2 01             	test   $0x1,%dl
  801363:	74 1c                	je     801381 <fd_alloc+0x4a>
  801365:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80136a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80136f:	75 d2                	jne    801343 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801371:	8b 45 08             	mov    0x8(%ebp),%eax
  801374:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80137a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80137f:	eb 0a                	jmp    80138b <fd_alloc+0x54>
			*fd_store = fd;
  801381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801384:	89 01                	mov    %eax,(%ecx)
			return 0;
  801386:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80138b:	5d                   	pop    %ebp
  80138c:	c3                   	ret    

0080138d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80138d:	f3 0f 1e fb          	endbr32 
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801397:	83 f8 1f             	cmp    $0x1f,%eax
  80139a:	77 30                	ja     8013cc <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80139c:	c1 e0 0c             	shl    $0xc,%eax
  80139f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013a4:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8013aa:	f6 c2 01             	test   $0x1,%dl
  8013ad:	74 24                	je     8013d3 <fd_lookup+0x46>
  8013af:	89 c2                	mov    %eax,%edx
  8013b1:	c1 ea 0c             	shr    $0xc,%edx
  8013b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013bb:	f6 c2 01             	test   $0x1,%dl
  8013be:	74 1a                	je     8013da <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c3:	89 02                	mov    %eax,(%edx)
	return 0;
  8013c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    
		return -E_INVAL;
  8013cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d1:	eb f7                	jmp    8013ca <fd_lookup+0x3d>
		return -E_INVAL;
  8013d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d8:	eb f0                	jmp    8013ca <fd_lookup+0x3d>
  8013da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013df:	eb e9                	jmp    8013ca <fd_lookup+0x3d>

008013e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013e1:	f3 0f 1e fb          	endbr32 
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	83 ec 08             	sub    $0x8,%esp
  8013eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ee:	ba 94 29 80 00       	mov    $0x802994,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013f3:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8013f8:	39 08                	cmp    %ecx,(%eax)
  8013fa:	74 33                	je     80142f <dev_lookup+0x4e>
  8013fc:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8013ff:	8b 02                	mov    (%edx),%eax
  801401:	85 c0                	test   %eax,%eax
  801403:	75 f3                	jne    8013f8 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801405:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80140a:	8b 40 48             	mov    0x48(%eax),%eax
  80140d:	83 ec 04             	sub    $0x4,%esp
  801410:	51                   	push   %ecx
  801411:	50                   	push   %eax
  801412:	68 18 29 80 00       	push   $0x802918
  801417:	e8 20 f3 ff ff       	call   80073c <cprintf>
	*dev = 0;
  80141c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80142d:	c9                   	leave  
  80142e:	c3                   	ret    
			*dev = devtab[i];
  80142f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801432:	89 01                	mov    %eax,(%ecx)
			return 0;
  801434:	b8 00 00 00 00       	mov    $0x0,%eax
  801439:	eb f2                	jmp    80142d <dev_lookup+0x4c>

0080143b <fd_close>:
{
  80143b:	f3 0f 1e fb          	endbr32 
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	57                   	push   %edi
  801443:	56                   	push   %esi
  801444:	53                   	push   %ebx
  801445:	83 ec 28             	sub    $0x28,%esp
  801448:	8b 75 08             	mov    0x8(%ebp),%esi
  80144b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80144e:	56                   	push   %esi
  80144f:	e8 b0 fe ff ff       	call   801304 <fd2num>
  801454:	83 c4 08             	add    $0x8,%esp
  801457:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80145a:	52                   	push   %edx
  80145b:	50                   	push   %eax
  80145c:	e8 2c ff ff ff       	call   80138d <fd_lookup>
  801461:	89 c3                	mov    %eax,%ebx
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	85 c0                	test   %eax,%eax
  801468:	78 05                	js     80146f <fd_close+0x34>
	    || fd != fd2)
  80146a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80146d:	74 16                	je     801485 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80146f:	89 f8                	mov    %edi,%eax
  801471:	84 c0                	test   %al,%al
  801473:	b8 00 00 00 00       	mov    $0x0,%eax
  801478:	0f 44 d8             	cmove  %eax,%ebx
}
  80147b:	89 d8                	mov    %ebx,%eax
  80147d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801480:	5b                   	pop    %ebx
  801481:	5e                   	pop    %esi
  801482:	5f                   	pop    %edi
  801483:	5d                   	pop    %ebp
  801484:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801485:	83 ec 08             	sub    $0x8,%esp
  801488:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80148b:	50                   	push   %eax
  80148c:	ff 36                	pushl  (%esi)
  80148e:	e8 4e ff ff ff       	call   8013e1 <dev_lookup>
  801493:	89 c3                	mov    %eax,%ebx
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 1a                	js     8014b6 <fd_close+0x7b>
		if (dev->dev_close)
  80149c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80149f:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8014a2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	74 0b                	je     8014b6 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8014ab:	83 ec 0c             	sub    $0xc,%esp
  8014ae:	56                   	push   %esi
  8014af:	ff d0                	call   *%eax
  8014b1:	89 c3                	mov    %eax,%ebx
  8014b3:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8014b6:	83 ec 08             	sub    $0x8,%esp
  8014b9:	56                   	push   %esi
  8014ba:	6a 00                	push   $0x0
  8014bc:	e8 bf fc ff ff       	call   801180 <sys_page_unmap>
	return r;
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	eb b5                	jmp    80147b <fd_close+0x40>

008014c6 <close>:

int
close(int fdnum)
{
  8014c6:	f3 0f 1e fb          	endbr32 
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d3:	50                   	push   %eax
  8014d4:	ff 75 08             	pushl  0x8(%ebp)
  8014d7:	e8 b1 fe ff ff       	call   80138d <fd_lookup>
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	79 02                	jns    8014e5 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    
		return fd_close(fd, 1);
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	6a 01                	push   $0x1
  8014ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ed:	e8 49 ff ff ff       	call   80143b <fd_close>
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	eb ec                	jmp    8014e3 <close+0x1d>

008014f7 <close_all>:

void
close_all(void)
{
  8014f7:	f3 0f 1e fb          	endbr32 
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	53                   	push   %ebx
  8014ff:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801502:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801507:	83 ec 0c             	sub    $0xc,%esp
  80150a:	53                   	push   %ebx
  80150b:	e8 b6 ff ff ff       	call   8014c6 <close>
	for (i = 0; i < MAXFD; i++)
  801510:	83 c3 01             	add    $0x1,%ebx
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	83 fb 20             	cmp    $0x20,%ebx
  801519:	75 ec                	jne    801507 <close_all+0x10>
}
  80151b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151e:	c9                   	leave  
  80151f:	c3                   	ret    

00801520 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801520:	f3 0f 1e fb          	endbr32 
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	57                   	push   %edi
  801528:	56                   	push   %esi
  801529:	53                   	push   %ebx
  80152a:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80152d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801530:	50                   	push   %eax
  801531:	ff 75 08             	pushl  0x8(%ebp)
  801534:	e8 54 fe ff ff       	call   80138d <fd_lookup>
  801539:	89 c3                	mov    %eax,%ebx
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	85 c0                	test   %eax,%eax
  801540:	0f 88 81 00 00 00    	js     8015c7 <dup+0xa7>
		return r;
	close(newfdnum);
  801546:	83 ec 0c             	sub    $0xc,%esp
  801549:	ff 75 0c             	pushl  0xc(%ebp)
  80154c:	e8 75 ff ff ff       	call   8014c6 <close>

	newfd = INDEX2FD(newfdnum);
  801551:	8b 75 0c             	mov    0xc(%ebp),%esi
  801554:	c1 e6 0c             	shl    $0xc,%esi
  801557:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80155d:	83 c4 04             	add    $0x4,%esp
  801560:	ff 75 e4             	pushl  -0x1c(%ebp)
  801563:	e8 b0 fd ff ff       	call   801318 <fd2data>
  801568:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80156a:	89 34 24             	mov    %esi,(%esp)
  80156d:	e8 a6 fd ff ff       	call   801318 <fd2data>
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801577:	89 d8                	mov    %ebx,%eax
  801579:	c1 e8 16             	shr    $0x16,%eax
  80157c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801583:	a8 01                	test   $0x1,%al
  801585:	74 11                	je     801598 <dup+0x78>
  801587:	89 d8                	mov    %ebx,%eax
  801589:	c1 e8 0c             	shr    $0xc,%eax
  80158c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801593:	f6 c2 01             	test   $0x1,%dl
  801596:	75 39                	jne    8015d1 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801598:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80159b:	89 d0                	mov    %edx,%eax
  80159d:	c1 e8 0c             	shr    $0xc,%eax
  8015a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015a7:	83 ec 0c             	sub    $0xc,%esp
  8015aa:	25 07 0e 00 00       	and    $0xe07,%eax
  8015af:	50                   	push   %eax
  8015b0:	56                   	push   %esi
  8015b1:	6a 00                	push   $0x0
  8015b3:	52                   	push   %edx
  8015b4:	6a 00                	push   $0x0
  8015b6:	e8 9b fb ff ff       	call   801156 <sys_page_map>
  8015bb:	89 c3                	mov    %eax,%ebx
  8015bd:	83 c4 20             	add    $0x20,%esp
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	78 31                	js     8015f5 <dup+0xd5>
		goto err;

	return newfdnum;
  8015c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015c7:	89 d8                	mov    %ebx,%eax
  8015c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015cc:	5b                   	pop    %ebx
  8015cd:	5e                   	pop    %esi
  8015ce:	5f                   	pop    %edi
  8015cf:	5d                   	pop    %ebp
  8015d0:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015d1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015d8:	83 ec 0c             	sub    $0xc,%esp
  8015db:	25 07 0e 00 00       	and    $0xe07,%eax
  8015e0:	50                   	push   %eax
  8015e1:	57                   	push   %edi
  8015e2:	6a 00                	push   $0x0
  8015e4:	53                   	push   %ebx
  8015e5:	6a 00                	push   $0x0
  8015e7:	e8 6a fb ff ff       	call   801156 <sys_page_map>
  8015ec:	89 c3                	mov    %eax,%ebx
  8015ee:	83 c4 20             	add    $0x20,%esp
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	79 a3                	jns    801598 <dup+0x78>
	sys_page_unmap(0, newfd);
  8015f5:	83 ec 08             	sub    $0x8,%esp
  8015f8:	56                   	push   %esi
  8015f9:	6a 00                	push   $0x0
  8015fb:	e8 80 fb ff ff       	call   801180 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801600:	83 c4 08             	add    $0x8,%esp
  801603:	57                   	push   %edi
  801604:	6a 00                	push   $0x0
  801606:	e8 75 fb ff ff       	call   801180 <sys_page_unmap>
	return r;
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	eb b7                	jmp    8015c7 <dup+0xa7>

00801610 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801610:	f3 0f 1e fb          	endbr32 
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	53                   	push   %ebx
  801618:	83 ec 1c             	sub    $0x1c,%esp
  80161b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80161e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801621:	50                   	push   %eax
  801622:	53                   	push   %ebx
  801623:	e8 65 fd ff ff       	call   80138d <fd_lookup>
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 3f                	js     80166e <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801635:	50                   	push   %eax
  801636:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801639:	ff 30                	pushl  (%eax)
  80163b:	e8 a1 fd ff ff       	call   8013e1 <dev_lookup>
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	85 c0                	test   %eax,%eax
  801645:	78 27                	js     80166e <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801647:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80164a:	8b 42 08             	mov    0x8(%edx),%eax
  80164d:	83 e0 03             	and    $0x3,%eax
  801650:	83 f8 01             	cmp    $0x1,%eax
  801653:	74 1e                	je     801673 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801655:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801658:	8b 40 08             	mov    0x8(%eax),%eax
  80165b:	85 c0                	test   %eax,%eax
  80165d:	74 35                	je     801694 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80165f:	83 ec 04             	sub    $0x4,%esp
  801662:	ff 75 10             	pushl  0x10(%ebp)
  801665:	ff 75 0c             	pushl  0xc(%ebp)
  801668:	52                   	push   %edx
  801669:	ff d0                	call   *%eax
  80166b:	83 c4 10             	add    $0x10,%esp
}
  80166e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801671:	c9                   	leave  
  801672:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801673:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801678:	8b 40 48             	mov    0x48(%eax),%eax
  80167b:	83 ec 04             	sub    $0x4,%esp
  80167e:	53                   	push   %ebx
  80167f:	50                   	push   %eax
  801680:	68 59 29 80 00       	push   $0x802959
  801685:	e8 b2 f0 ff ff       	call   80073c <cprintf>
		return -E_INVAL;
  80168a:	83 c4 10             	add    $0x10,%esp
  80168d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801692:	eb da                	jmp    80166e <read+0x5e>
		return -E_NOT_SUPP;
  801694:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801699:	eb d3                	jmp    80166e <read+0x5e>

0080169b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80169b:	f3 0f 1e fb          	endbr32 
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	57                   	push   %edi
  8016a3:	56                   	push   %esi
  8016a4:	53                   	push   %ebx
  8016a5:	83 ec 0c             	sub    $0xc,%esp
  8016a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016ab:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016b3:	eb 02                	jmp    8016b7 <readn+0x1c>
  8016b5:	01 c3                	add    %eax,%ebx
  8016b7:	39 f3                	cmp    %esi,%ebx
  8016b9:	73 21                	jae    8016dc <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016bb:	83 ec 04             	sub    $0x4,%esp
  8016be:	89 f0                	mov    %esi,%eax
  8016c0:	29 d8                	sub    %ebx,%eax
  8016c2:	50                   	push   %eax
  8016c3:	89 d8                	mov    %ebx,%eax
  8016c5:	03 45 0c             	add    0xc(%ebp),%eax
  8016c8:	50                   	push   %eax
  8016c9:	57                   	push   %edi
  8016ca:	e8 41 ff ff ff       	call   801610 <read>
		if (m < 0)
  8016cf:	83 c4 10             	add    $0x10,%esp
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	78 04                	js     8016da <readn+0x3f>
			return m;
		if (m == 0)
  8016d6:	75 dd                	jne    8016b5 <readn+0x1a>
  8016d8:	eb 02                	jmp    8016dc <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016da:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8016dc:	89 d8                	mov    %ebx,%eax
  8016de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e1:	5b                   	pop    %ebx
  8016e2:	5e                   	pop    %esi
  8016e3:	5f                   	pop    %edi
  8016e4:	5d                   	pop    %ebp
  8016e5:	c3                   	ret    

008016e6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016e6:	f3 0f 1e fb          	endbr32 
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	53                   	push   %ebx
  8016ee:	83 ec 1c             	sub    $0x1c,%esp
  8016f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f7:	50                   	push   %eax
  8016f8:	53                   	push   %ebx
  8016f9:	e8 8f fc ff ff       	call   80138d <fd_lookup>
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	85 c0                	test   %eax,%eax
  801703:	78 3a                	js     80173f <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801705:	83 ec 08             	sub    $0x8,%esp
  801708:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170b:	50                   	push   %eax
  80170c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170f:	ff 30                	pushl  (%eax)
  801711:	e8 cb fc ff ff       	call   8013e1 <dev_lookup>
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	85 c0                	test   %eax,%eax
  80171b:	78 22                	js     80173f <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80171d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801720:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801724:	74 1e                	je     801744 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801726:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801729:	8b 52 0c             	mov    0xc(%edx),%edx
  80172c:	85 d2                	test   %edx,%edx
  80172e:	74 35                	je     801765 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801730:	83 ec 04             	sub    $0x4,%esp
  801733:	ff 75 10             	pushl  0x10(%ebp)
  801736:	ff 75 0c             	pushl  0xc(%ebp)
  801739:	50                   	push   %eax
  80173a:	ff d2                	call   *%edx
  80173c:	83 c4 10             	add    $0x10,%esp
}
  80173f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801742:	c9                   	leave  
  801743:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801744:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801749:	8b 40 48             	mov    0x48(%eax),%eax
  80174c:	83 ec 04             	sub    $0x4,%esp
  80174f:	53                   	push   %ebx
  801750:	50                   	push   %eax
  801751:	68 75 29 80 00       	push   $0x802975
  801756:	e8 e1 ef ff ff       	call   80073c <cprintf>
		return -E_INVAL;
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801763:	eb da                	jmp    80173f <write+0x59>
		return -E_NOT_SUPP;
  801765:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80176a:	eb d3                	jmp    80173f <write+0x59>

0080176c <seek>:

int
seek(int fdnum, off_t offset)
{
  80176c:	f3 0f 1e fb          	endbr32 
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801776:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801779:	50                   	push   %eax
  80177a:	ff 75 08             	pushl  0x8(%ebp)
  80177d:	e8 0b fc ff ff       	call   80138d <fd_lookup>
  801782:	83 c4 10             	add    $0x10,%esp
  801785:	85 c0                	test   %eax,%eax
  801787:	78 0e                	js     801797 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801789:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801792:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801797:	c9                   	leave  
  801798:	c3                   	ret    

00801799 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801799:	f3 0f 1e fb          	endbr32 
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	53                   	push   %ebx
  8017a1:	83 ec 1c             	sub    $0x1c,%esp
  8017a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017aa:	50                   	push   %eax
  8017ab:	53                   	push   %ebx
  8017ac:	e8 dc fb ff ff       	call   80138d <fd_lookup>
  8017b1:	83 c4 10             	add    $0x10,%esp
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	78 37                	js     8017ef <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b8:	83 ec 08             	sub    $0x8,%esp
  8017bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017be:	50                   	push   %eax
  8017bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c2:	ff 30                	pushl  (%eax)
  8017c4:	e8 18 fc ff ff       	call   8013e1 <dev_lookup>
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	78 1f                	js     8017ef <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017d7:	74 1b                	je     8017f4 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8017d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017dc:	8b 52 18             	mov    0x18(%edx),%edx
  8017df:	85 d2                	test   %edx,%edx
  8017e1:	74 32                	je     801815 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017e3:	83 ec 08             	sub    $0x8,%esp
  8017e6:	ff 75 0c             	pushl  0xc(%ebp)
  8017e9:	50                   	push   %eax
  8017ea:	ff d2                	call   *%edx
  8017ec:	83 c4 10             	add    $0x10,%esp
}
  8017ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f2:	c9                   	leave  
  8017f3:	c3                   	ret    
			thisenv->env_id, fdnum);
  8017f4:	a1 b0 40 80 00       	mov    0x8040b0,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017f9:	8b 40 48             	mov    0x48(%eax),%eax
  8017fc:	83 ec 04             	sub    $0x4,%esp
  8017ff:	53                   	push   %ebx
  801800:	50                   	push   %eax
  801801:	68 38 29 80 00       	push   $0x802938
  801806:	e8 31 ef ff ff       	call   80073c <cprintf>
		return -E_INVAL;
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801813:	eb da                	jmp    8017ef <ftruncate+0x56>
		return -E_NOT_SUPP;
  801815:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80181a:	eb d3                	jmp    8017ef <ftruncate+0x56>

0080181c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80181c:	f3 0f 1e fb          	endbr32 
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	53                   	push   %ebx
  801824:	83 ec 1c             	sub    $0x1c,%esp
  801827:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182d:	50                   	push   %eax
  80182e:	ff 75 08             	pushl  0x8(%ebp)
  801831:	e8 57 fb ff ff       	call   80138d <fd_lookup>
  801836:	83 c4 10             	add    $0x10,%esp
  801839:	85 c0                	test   %eax,%eax
  80183b:	78 4b                	js     801888 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183d:	83 ec 08             	sub    $0x8,%esp
  801840:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801843:	50                   	push   %eax
  801844:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801847:	ff 30                	pushl  (%eax)
  801849:	e8 93 fb ff ff       	call   8013e1 <dev_lookup>
  80184e:	83 c4 10             	add    $0x10,%esp
  801851:	85 c0                	test   %eax,%eax
  801853:	78 33                	js     801888 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801855:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801858:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80185c:	74 2f                	je     80188d <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80185e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801861:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801868:	00 00 00 
	stat->st_isdir = 0;
  80186b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801872:	00 00 00 
	stat->st_dev = dev;
  801875:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80187b:	83 ec 08             	sub    $0x8,%esp
  80187e:	53                   	push   %ebx
  80187f:	ff 75 f0             	pushl  -0x10(%ebp)
  801882:	ff 50 14             	call   *0x14(%eax)
  801885:	83 c4 10             	add    $0x10,%esp
}
  801888:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188b:	c9                   	leave  
  80188c:	c3                   	ret    
		return -E_NOT_SUPP;
  80188d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801892:	eb f4                	jmp    801888 <fstat+0x6c>

00801894 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801894:	f3 0f 1e fb          	endbr32 
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	56                   	push   %esi
  80189c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80189d:	83 ec 08             	sub    $0x8,%esp
  8018a0:	6a 00                	push   $0x0
  8018a2:	ff 75 08             	pushl  0x8(%ebp)
  8018a5:	e8 20 02 00 00       	call   801aca <open>
  8018aa:	89 c3                	mov    %eax,%ebx
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 1b                	js     8018ce <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8018b3:	83 ec 08             	sub    $0x8,%esp
  8018b6:	ff 75 0c             	pushl  0xc(%ebp)
  8018b9:	50                   	push   %eax
  8018ba:	e8 5d ff ff ff       	call   80181c <fstat>
  8018bf:	89 c6                	mov    %eax,%esi
	close(fd);
  8018c1:	89 1c 24             	mov    %ebx,(%esp)
  8018c4:	e8 fd fb ff ff       	call   8014c6 <close>
	return r;
  8018c9:	83 c4 10             	add    $0x10,%esp
  8018cc:	89 f3                	mov    %esi,%ebx
}
  8018ce:	89 d8                	mov    %ebx,%eax
  8018d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d3:	5b                   	pop    %ebx
  8018d4:	5e                   	pop    %esi
  8018d5:	5d                   	pop    %ebp
  8018d6:	c3                   	ret    

008018d7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	56                   	push   %esi
  8018db:	53                   	push   %ebx
  8018dc:	89 c6                	mov    %eax,%esi
  8018de:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018e0:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  8018e7:	74 27                	je     801910 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018e9:	6a 07                	push   $0x7
  8018eb:	68 00 50 80 00       	push   $0x805000
  8018f0:	56                   	push   %esi
  8018f1:	ff 35 ac 40 80 00    	pushl  0x8040ac
  8018f7:	e8 e3 07 00 00       	call   8020df <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018fc:	83 c4 0c             	add    $0xc,%esp
  8018ff:	6a 00                	push   $0x0
  801901:	53                   	push   %ebx
  801902:	6a 00                	push   $0x0
  801904:	e8 69 07 00 00       	call   802072 <ipc_recv>
}
  801909:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190c:	5b                   	pop    %ebx
  80190d:	5e                   	pop    %esi
  80190e:	5d                   	pop    %ebp
  80190f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801910:	83 ec 0c             	sub    $0xc,%esp
  801913:	6a 01                	push   $0x1
  801915:	e8 18 08 00 00       	call   802132 <ipc_find_env>
  80191a:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	eb c5                	jmp    8018e9 <fsipc+0x12>

00801924 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801924:	f3 0f 1e fb          	endbr32 
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80192e:	8b 45 08             	mov    0x8(%ebp),%eax
  801931:	8b 40 0c             	mov    0xc(%eax),%eax
  801934:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801939:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801941:	ba 00 00 00 00       	mov    $0x0,%edx
  801946:	b8 02 00 00 00       	mov    $0x2,%eax
  80194b:	e8 87 ff ff ff       	call   8018d7 <fsipc>
}
  801950:	c9                   	leave  
  801951:	c3                   	ret    

00801952 <devfile_flush>:
{
  801952:	f3 0f 1e fb          	endbr32 
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80195c:	8b 45 08             	mov    0x8(%ebp),%eax
  80195f:	8b 40 0c             	mov    0xc(%eax),%eax
  801962:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801967:	ba 00 00 00 00       	mov    $0x0,%edx
  80196c:	b8 06 00 00 00       	mov    $0x6,%eax
  801971:	e8 61 ff ff ff       	call   8018d7 <fsipc>
}
  801976:	c9                   	leave  
  801977:	c3                   	ret    

00801978 <devfile_stat>:
{
  801978:	f3 0f 1e fb          	endbr32 
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	53                   	push   %ebx
  801980:	83 ec 04             	sub    $0x4,%esp
  801983:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801986:	8b 45 08             	mov    0x8(%ebp),%eax
  801989:	8b 40 0c             	mov    0xc(%eax),%eax
  80198c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801991:	ba 00 00 00 00       	mov    $0x0,%edx
  801996:	b8 05 00 00 00       	mov    $0x5,%eax
  80199b:	e8 37 ff ff ff       	call   8018d7 <fsipc>
  8019a0:	85 c0                	test   %eax,%eax
  8019a2:	78 2c                	js     8019d0 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019a4:	83 ec 08             	sub    $0x8,%esp
  8019a7:	68 00 50 80 00       	push   $0x805000
  8019ac:	53                   	push   %ebx
  8019ad:	e8 f4 f2 ff ff       	call   800ca6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019b2:	a1 80 50 80 00       	mov    0x805080,%eax
  8019b7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019bd:	a1 84 50 80 00       	mov    0x805084,%eax
  8019c2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019c8:	83 c4 10             	add    $0x10,%esp
  8019cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d3:	c9                   	leave  
  8019d4:	c3                   	ret    

008019d5 <devfile_write>:
{
  8019d5:	f3 0f 1e fb          	endbr32 
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	57                   	push   %edi
  8019dd:	56                   	push   %esi
  8019de:	53                   	push   %ebx
  8019df:	83 ec 0c             	sub    $0xc,%esp
  8019e2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ee:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  8019f3:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8019f8:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  8019fd:	85 db                	test   %ebx,%ebx
  8019ff:	74 3b                	je     801a3c <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a01:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801a07:	89 f8                	mov    %edi,%eax
  801a09:	0f 46 c3             	cmovbe %ebx,%eax
  801a0c:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  801a11:	83 ec 04             	sub    $0x4,%esp
  801a14:	50                   	push   %eax
  801a15:	56                   	push   %esi
  801a16:	68 08 50 80 00       	push   $0x805008
  801a1b:	e8 3e f4 ff ff       	call   800e5e <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a20:	ba 00 00 00 00       	mov    $0x0,%edx
  801a25:	b8 04 00 00 00       	mov    $0x4,%eax
  801a2a:	e8 a8 fe ff ff       	call   8018d7 <fsipc>
  801a2f:	83 c4 10             	add    $0x10,%esp
  801a32:	85 c0                	test   %eax,%eax
  801a34:	78 06                	js     801a3c <devfile_write+0x67>
		buf_aux += r;
  801a36:	01 c6                	add    %eax,%esi
		n -= r;
  801a38:	29 c3                	sub    %eax,%ebx
  801a3a:	eb c1                	jmp    8019fd <devfile_write+0x28>
}
  801a3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a3f:	5b                   	pop    %ebx
  801a40:	5e                   	pop    %esi
  801a41:	5f                   	pop    %edi
  801a42:	5d                   	pop    %ebp
  801a43:	c3                   	ret    

00801a44 <devfile_read>:
{
  801a44:	f3 0f 1e fb          	endbr32 
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	56                   	push   %esi
  801a4c:	53                   	push   %ebx
  801a4d:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a50:	8b 45 08             	mov    0x8(%ebp),%eax
  801a53:	8b 40 0c             	mov    0xc(%eax),%eax
  801a56:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a5b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a61:	ba 00 00 00 00       	mov    $0x0,%edx
  801a66:	b8 03 00 00 00       	mov    $0x3,%eax
  801a6b:	e8 67 fe ff ff       	call   8018d7 <fsipc>
  801a70:	89 c3                	mov    %eax,%ebx
  801a72:	85 c0                	test   %eax,%eax
  801a74:	78 1f                	js     801a95 <devfile_read+0x51>
	assert(r <= n);
  801a76:	39 f0                	cmp    %esi,%eax
  801a78:	77 24                	ja     801a9e <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801a7a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a7f:	7f 33                	jg     801ab4 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a81:	83 ec 04             	sub    $0x4,%esp
  801a84:	50                   	push   %eax
  801a85:	68 00 50 80 00       	push   $0x805000
  801a8a:	ff 75 0c             	pushl  0xc(%ebp)
  801a8d:	e8 cc f3 ff ff       	call   800e5e <memmove>
	return r;
  801a92:	83 c4 10             	add    $0x10,%esp
}
  801a95:	89 d8                	mov    %ebx,%eax
  801a97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9a:	5b                   	pop    %ebx
  801a9b:	5e                   	pop    %esi
  801a9c:	5d                   	pop    %ebp
  801a9d:	c3                   	ret    
	assert(r <= n);
  801a9e:	68 a4 29 80 00       	push   $0x8029a4
  801aa3:	68 ab 29 80 00       	push   $0x8029ab
  801aa8:	6a 7c                	push   $0x7c
  801aaa:	68 c0 29 80 00       	push   $0x8029c0
  801aaf:	e8 a1 eb ff ff       	call   800655 <_panic>
	assert(r <= PGSIZE);
  801ab4:	68 cb 29 80 00       	push   $0x8029cb
  801ab9:	68 ab 29 80 00       	push   $0x8029ab
  801abe:	6a 7d                	push   $0x7d
  801ac0:	68 c0 29 80 00       	push   $0x8029c0
  801ac5:	e8 8b eb ff ff       	call   800655 <_panic>

00801aca <open>:
{
  801aca:	f3 0f 1e fb          	endbr32 
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	56                   	push   %esi
  801ad2:	53                   	push   %ebx
  801ad3:	83 ec 1c             	sub    $0x1c,%esp
  801ad6:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801ad9:	56                   	push   %esi
  801ada:	e8 84 f1 ff ff       	call   800c63 <strlen>
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ae7:	7f 6c                	jg     801b55 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801ae9:	83 ec 0c             	sub    $0xc,%esp
  801aec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aef:	50                   	push   %eax
  801af0:	e8 42 f8 ff ff       	call   801337 <fd_alloc>
  801af5:	89 c3                	mov    %eax,%ebx
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	85 c0                	test   %eax,%eax
  801afc:	78 3c                	js     801b3a <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801afe:	83 ec 08             	sub    $0x8,%esp
  801b01:	56                   	push   %esi
  801b02:	68 00 50 80 00       	push   $0x805000
  801b07:	e8 9a f1 ff ff       	call   800ca6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0f:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b14:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b17:	b8 01 00 00 00       	mov    $0x1,%eax
  801b1c:	e8 b6 fd ff ff       	call   8018d7 <fsipc>
  801b21:	89 c3                	mov    %eax,%ebx
  801b23:	83 c4 10             	add    $0x10,%esp
  801b26:	85 c0                	test   %eax,%eax
  801b28:	78 19                	js     801b43 <open+0x79>
	return fd2num(fd);
  801b2a:	83 ec 0c             	sub    $0xc,%esp
  801b2d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b30:	e8 cf f7 ff ff       	call   801304 <fd2num>
  801b35:	89 c3                	mov    %eax,%ebx
  801b37:	83 c4 10             	add    $0x10,%esp
}
  801b3a:	89 d8                	mov    %ebx,%eax
  801b3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b3f:	5b                   	pop    %ebx
  801b40:	5e                   	pop    %esi
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    
		fd_close(fd, 0);
  801b43:	83 ec 08             	sub    $0x8,%esp
  801b46:	6a 00                	push   $0x0
  801b48:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4b:	e8 eb f8 ff ff       	call   80143b <fd_close>
		return r;
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	eb e5                	jmp    801b3a <open+0x70>
		return -E_BAD_PATH;
  801b55:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801b5a:	eb de                	jmp    801b3a <open+0x70>

00801b5c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b5c:	f3 0f 1e fb          	endbr32 
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b66:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6b:	b8 08 00 00 00       	mov    $0x8,%eax
  801b70:	e8 62 fd ff ff       	call   8018d7 <fsipc>
}
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b77:	f3 0f 1e fb          	endbr32 
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	56                   	push   %esi
  801b7f:	53                   	push   %ebx
  801b80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b83:	83 ec 0c             	sub    $0xc,%esp
  801b86:	ff 75 08             	pushl  0x8(%ebp)
  801b89:	e8 8a f7 ff ff       	call   801318 <fd2data>
  801b8e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b90:	83 c4 08             	add    $0x8,%esp
  801b93:	68 d7 29 80 00       	push   $0x8029d7
  801b98:	53                   	push   %ebx
  801b99:	e8 08 f1 ff ff       	call   800ca6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b9e:	8b 46 04             	mov    0x4(%esi),%eax
  801ba1:	2b 06                	sub    (%esi),%eax
  801ba3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ba9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bb0:	00 00 00 
	stat->st_dev = &devpipe;
  801bb3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801bba:	30 80 00 
	return 0;
}
  801bbd:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc5:	5b                   	pop    %ebx
  801bc6:	5e                   	pop    %esi
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    

00801bc9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bc9:	f3 0f 1e fb          	endbr32 
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	53                   	push   %ebx
  801bd1:	83 ec 0c             	sub    $0xc,%esp
  801bd4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bd7:	53                   	push   %ebx
  801bd8:	6a 00                	push   $0x0
  801bda:	e8 a1 f5 ff ff       	call   801180 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bdf:	89 1c 24             	mov    %ebx,(%esp)
  801be2:	e8 31 f7 ff ff       	call   801318 <fd2data>
  801be7:	83 c4 08             	add    $0x8,%esp
  801bea:	50                   	push   %eax
  801beb:	6a 00                	push   $0x0
  801bed:	e8 8e f5 ff ff       	call   801180 <sys_page_unmap>
}
  801bf2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    

00801bf7 <_pipeisclosed>:
{
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	57                   	push   %edi
  801bfb:	56                   	push   %esi
  801bfc:	53                   	push   %ebx
  801bfd:	83 ec 1c             	sub    $0x1c,%esp
  801c00:	89 c7                	mov    %eax,%edi
  801c02:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c04:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801c09:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c0c:	83 ec 0c             	sub    $0xc,%esp
  801c0f:	57                   	push   %edi
  801c10:	e8 5a 05 00 00       	call   80216f <pageref>
  801c15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c18:	89 34 24             	mov    %esi,(%esp)
  801c1b:	e8 4f 05 00 00       	call   80216f <pageref>
		nn = thisenv->env_runs;
  801c20:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801c26:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c29:	83 c4 10             	add    $0x10,%esp
  801c2c:	39 cb                	cmp    %ecx,%ebx
  801c2e:	74 1b                	je     801c4b <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c30:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c33:	75 cf                	jne    801c04 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c35:	8b 42 58             	mov    0x58(%edx),%eax
  801c38:	6a 01                	push   $0x1
  801c3a:	50                   	push   %eax
  801c3b:	53                   	push   %ebx
  801c3c:	68 de 29 80 00       	push   $0x8029de
  801c41:	e8 f6 ea ff ff       	call   80073c <cprintf>
  801c46:	83 c4 10             	add    $0x10,%esp
  801c49:	eb b9                	jmp    801c04 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c4b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c4e:	0f 94 c0             	sete   %al
  801c51:	0f b6 c0             	movzbl %al,%eax
}
  801c54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c57:	5b                   	pop    %ebx
  801c58:	5e                   	pop    %esi
  801c59:	5f                   	pop    %edi
  801c5a:	5d                   	pop    %ebp
  801c5b:	c3                   	ret    

00801c5c <devpipe_write>:
{
  801c5c:	f3 0f 1e fb          	endbr32 
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	57                   	push   %edi
  801c64:	56                   	push   %esi
  801c65:	53                   	push   %ebx
  801c66:	83 ec 28             	sub    $0x28,%esp
  801c69:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c6c:	56                   	push   %esi
  801c6d:	e8 a6 f6 ff ff       	call   801318 <fd2data>
  801c72:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	bf 00 00 00 00       	mov    $0x0,%edi
  801c7c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c7f:	74 4f                	je     801cd0 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c81:	8b 43 04             	mov    0x4(%ebx),%eax
  801c84:	8b 0b                	mov    (%ebx),%ecx
  801c86:	8d 51 20             	lea    0x20(%ecx),%edx
  801c89:	39 d0                	cmp    %edx,%eax
  801c8b:	72 14                	jb     801ca1 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801c8d:	89 da                	mov    %ebx,%edx
  801c8f:	89 f0                	mov    %esi,%eax
  801c91:	e8 61 ff ff ff       	call   801bf7 <_pipeisclosed>
  801c96:	85 c0                	test   %eax,%eax
  801c98:	75 3b                	jne    801cd5 <devpipe_write+0x79>
			sys_yield();
  801c9a:	e8 64 f4 ff ff       	call   801103 <sys_yield>
  801c9f:	eb e0                	jmp    801c81 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ca8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cab:	89 c2                	mov    %eax,%edx
  801cad:	c1 fa 1f             	sar    $0x1f,%edx
  801cb0:	89 d1                	mov    %edx,%ecx
  801cb2:	c1 e9 1b             	shr    $0x1b,%ecx
  801cb5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cb8:	83 e2 1f             	and    $0x1f,%edx
  801cbb:	29 ca                	sub    %ecx,%edx
  801cbd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cc1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cc5:	83 c0 01             	add    $0x1,%eax
  801cc8:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801ccb:	83 c7 01             	add    $0x1,%edi
  801cce:	eb ac                	jmp    801c7c <devpipe_write+0x20>
	return i;
  801cd0:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd3:	eb 05                	jmp    801cda <devpipe_write+0x7e>
				return 0;
  801cd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5f                   	pop    %edi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    

00801ce2 <devpipe_read>:
{
  801ce2:	f3 0f 1e fb          	endbr32 
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	57                   	push   %edi
  801cea:	56                   	push   %esi
  801ceb:	53                   	push   %ebx
  801cec:	83 ec 18             	sub    $0x18,%esp
  801cef:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801cf2:	57                   	push   %edi
  801cf3:	e8 20 f6 ff ff       	call   801318 <fd2data>
  801cf8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cfa:	83 c4 10             	add    $0x10,%esp
  801cfd:	be 00 00 00 00       	mov    $0x0,%esi
  801d02:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d05:	75 14                	jne    801d1b <devpipe_read+0x39>
	return i;
  801d07:	8b 45 10             	mov    0x10(%ebp),%eax
  801d0a:	eb 02                	jmp    801d0e <devpipe_read+0x2c>
				return i;
  801d0c:	89 f0                	mov    %esi,%eax
}
  801d0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d11:	5b                   	pop    %ebx
  801d12:	5e                   	pop    %esi
  801d13:	5f                   	pop    %edi
  801d14:	5d                   	pop    %ebp
  801d15:	c3                   	ret    
			sys_yield();
  801d16:	e8 e8 f3 ff ff       	call   801103 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d1b:	8b 03                	mov    (%ebx),%eax
  801d1d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d20:	75 18                	jne    801d3a <devpipe_read+0x58>
			if (i > 0)
  801d22:	85 f6                	test   %esi,%esi
  801d24:	75 e6                	jne    801d0c <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801d26:	89 da                	mov    %ebx,%edx
  801d28:	89 f8                	mov    %edi,%eax
  801d2a:	e8 c8 fe ff ff       	call   801bf7 <_pipeisclosed>
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	74 e3                	je     801d16 <devpipe_read+0x34>
				return 0;
  801d33:	b8 00 00 00 00       	mov    $0x0,%eax
  801d38:	eb d4                	jmp    801d0e <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d3a:	99                   	cltd   
  801d3b:	c1 ea 1b             	shr    $0x1b,%edx
  801d3e:	01 d0                	add    %edx,%eax
  801d40:	83 e0 1f             	and    $0x1f,%eax
  801d43:	29 d0                	sub    %edx,%eax
  801d45:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d4d:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d50:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d53:	83 c6 01             	add    $0x1,%esi
  801d56:	eb aa                	jmp    801d02 <devpipe_read+0x20>

00801d58 <pipe>:
{
  801d58:	f3 0f 1e fb          	endbr32 
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	56                   	push   %esi
  801d60:	53                   	push   %ebx
  801d61:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d67:	50                   	push   %eax
  801d68:	e8 ca f5 ff ff       	call   801337 <fd_alloc>
  801d6d:	89 c3                	mov    %eax,%ebx
  801d6f:	83 c4 10             	add    $0x10,%esp
  801d72:	85 c0                	test   %eax,%eax
  801d74:	0f 88 23 01 00 00    	js     801e9d <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7a:	83 ec 04             	sub    $0x4,%esp
  801d7d:	68 07 04 00 00       	push   $0x407
  801d82:	ff 75 f4             	pushl  -0xc(%ebp)
  801d85:	6a 00                	push   $0x0
  801d87:	e8 a2 f3 ff ff       	call   80112e <sys_page_alloc>
  801d8c:	89 c3                	mov    %eax,%ebx
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	85 c0                	test   %eax,%eax
  801d93:	0f 88 04 01 00 00    	js     801e9d <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801d99:	83 ec 0c             	sub    $0xc,%esp
  801d9c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d9f:	50                   	push   %eax
  801da0:	e8 92 f5 ff ff       	call   801337 <fd_alloc>
  801da5:	89 c3                	mov    %eax,%ebx
  801da7:	83 c4 10             	add    $0x10,%esp
  801daa:	85 c0                	test   %eax,%eax
  801dac:	0f 88 db 00 00 00    	js     801e8d <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db2:	83 ec 04             	sub    $0x4,%esp
  801db5:	68 07 04 00 00       	push   $0x407
  801dba:	ff 75 f0             	pushl  -0x10(%ebp)
  801dbd:	6a 00                	push   $0x0
  801dbf:	e8 6a f3 ff ff       	call   80112e <sys_page_alloc>
  801dc4:	89 c3                	mov    %eax,%ebx
  801dc6:	83 c4 10             	add    $0x10,%esp
  801dc9:	85 c0                	test   %eax,%eax
  801dcb:	0f 88 bc 00 00 00    	js     801e8d <pipe+0x135>
	va = fd2data(fd0);
  801dd1:	83 ec 0c             	sub    $0xc,%esp
  801dd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd7:	e8 3c f5 ff ff       	call   801318 <fd2data>
  801ddc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dde:	83 c4 0c             	add    $0xc,%esp
  801de1:	68 07 04 00 00       	push   $0x407
  801de6:	50                   	push   %eax
  801de7:	6a 00                	push   $0x0
  801de9:	e8 40 f3 ff ff       	call   80112e <sys_page_alloc>
  801dee:	89 c3                	mov    %eax,%ebx
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	85 c0                	test   %eax,%eax
  801df5:	0f 88 82 00 00 00    	js     801e7d <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dfb:	83 ec 0c             	sub    $0xc,%esp
  801dfe:	ff 75 f0             	pushl  -0x10(%ebp)
  801e01:	e8 12 f5 ff ff       	call   801318 <fd2data>
  801e06:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e0d:	50                   	push   %eax
  801e0e:	6a 00                	push   $0x0
  801e10:	56                   	push   %esi
  801e11:	6a 00                	push   $0x0
  801e13:	e8 3e f3 ff ff       	call   801156 <sys_page_map>
  801e18:	89 c3                	mov    %eax,%ebx
  801e1a:	83 c4 20             	add    $0x20,%esp
  801e1d:	85 c0                	test   %eax,%eax
  801e1f:	78 4e                	js     801e6f <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801e21:	a1 20 30 80 00       	mov    0x803020,%eax
  801e26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e29:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801e2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e2e:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e35:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e38:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801e3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e3d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e44:	83 ec 0c             	sub    $0xc,%esp
  801e47:	ff 75 f4             	pushl  -0xc(%ebp)
  801e4a:	e8 b5 f4 ff ff       	call   801304 <fd2num>
  801e4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e52:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e54:	83 c4 04             	add    $0x4,%esp
  801e57:	ff 75 f0             	pushl  -0x10(%ebp)
  801e5a:	e8 a5 f4 ff ff       	call   801304 <fd2num>
  801e5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e62:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e65:	83 c4 10             	add    $0x10,%esp
  801e68:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e6d:	eb 2e                	jmp    801e9d <pipe+0x145>
	sys_page_unmap(0, va);
  801e6f:	83 ec 08             	sub    $0x8,%esp
  801e72:	56                   	push   %esi
  801e73:	6a 00                	push   $0x0
  801e75:	e8 06 f3 ff ff       	call   801180 <sys_page_unmap>
  801e7a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e7d:	83 ec 08             	sub    $0x8,%esp
  801e80:	ff 75 f0             	pushl  -0x10(%ebp)
  801e83:	6a 00                	push   $0x0
  801e85:	e8 f6 f2 ff ff       	call   801180 <sys_page_unmap>
  801e8a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e8d:	83 ec 08             	sub    $0x8,%esp
  801e90:	ff 75 f4             	pushl  -0xc(%ebp)
  801e93:	6a 00                	push   $0x0
  801e95:	e8 e6 f2 ff ff       	call   801180 <sys_page_unmap>
  801e9a:	83 c4 10             	add    $0x10,%esp
}
  801e9d:	89 d8                	mov    %ebx,%eax
  801e9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea2:	5b                   	pop    %ebx
  801ea3:	5e                   	pop    %esi
  801ea4:	5d                   	pop    %ebp
  801ea5:	c3                   	ret    

00801ea6 <pipeisclosed>:
{
  801ea6:	f3 0f 1e fb          	endbr32 
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb3:	50                   	push   %eax
  801eb4:	ff 75 08             	pushl  0x8(%ebp)
  801eb7:	e8 d1 f4 ff ff       	call   80138d <fd_lookup>
  801ebc:	83 c4 10             	add    $0x10,%esp
  801ebf:	85 c0                	test   %eax,%eax
  801ec1:	78 18                	js     801edb <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801ec3:	83 ec 0c             	sub    $0xc,%esp
  801ec6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec9:	e8 4a f4 ff ff       	call   801318 <fd2data>
  801ece:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed3:	e8 1f fd ff ff       	call   801bf7 <_pipeisclosed>
  801ed8:	83 c4 10             	add    $0x10,%esp
}
  801edb:	c9                   	leave  
  801edc:	c3                   	ret    

00801edd <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801edd:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee6:	c3                   	ret    

00801ee7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ee7:	f3 0f 1e fb          	endbr32 
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ef1:	68 f6 29 80 00       	push   $0x8029f6
  801ef6:	ff 75 0c             	pushl  0xc(%ebp)
  801ef9:	e8 a8 ed ff ff       	call   800ca6 <strcpy>
	return 0;
}
  801efe:	b8 00 00 00 00       	mov    $0x0,%eax
  801f03:	c9                   	leave  
  801f04:	c3                   	ret    

00801f05 <devcons_write>:
{
  801f05:	f3 0f 1e fb          	endbr32 
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	57                   	push   %edi
  801f0d:	56                   	push   %esi
  801f0e:	53                   	push   %ebx
  801f0f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f15:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f1a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f20:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f23:	73 31                	jae    801f56 <devcons_write+0x51>
		m = n - tot;
  801f25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f28:	29 f3                	sub    %esi,%ebx
  801f2a:	83 fb 7f             	cmp    $0x7f,%ebx
  801f2d:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f32:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f35:	83 ec 04             	sub    $0x4,%esp
  801f38:	53                   	push   %ebx
  801f39:	89 f0                	mov    %esi,%eax
  801f3b:	03 45 0c             	add    0xc(%ebp),%eax
  801f3e:	50                   	push   %eax
  801f3f:	57                   	push   %edi
  801f40:	e8 19 ef ff ff       	call   800e5e <memmove>
		sys_cputs(buf, m);
  801f45:	83 c4 08             	add    $0x8,%esp
  801f48:	53                   	push   %ebx
  801f49:	57                   	push   %edi
  801f4a:	e8 14 f1 ff ff       	call   801063 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f4f:	01 de                	add    %ebx,%esi
  801f51:	83 c4 10             	add    $0x10,%esp
  801f54:	eb ca                	jmp    801f20 <devcons_write+0x1b>
}
  801f56:	89 f0                	mov    %esi,%eax
  801f58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5b:	5b                   	pop    %ebx
  801f5c:	5e                   	pop    %esi
  801f5d:	5f                   	pop    %edi
  801f5e:	5d                   	pop    %ebp
  801f5f:	c3                   	ret    

00801f60 <devcons_read>:
{
  801f60:	f3 0f 1e fb          	endbr32 
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	83 ec 08             	sub    $0x8,%esp
  801f6a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f6f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f73:	74 21                	je     801f96 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801f75:	e8 13 f1 ff ff       	call   80108d <sys_cgetc>
  801f7a:	85 c0                	test   %eax,%eax
  801f7c:	75 07                	jne    801f85 <devcons_read+0x25>
		sys_yield();
  801f7e:	e8 80 f1 ff ff       	call   801103 <sys_yield>
  801f83:	eb f0                	jmp    801f75 <devcons_read+0x15>
	if (c < 0)
  801f85:	78 0f                	js     801f96 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801f87:	83 f8 04             	cmp    $0x4,%eax
  801f8a:	74 0c                	je     801f98 <devcons_read+0x38>
	*(char*)vbuf = c;
  801f8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f8f:	88 02                	mov    %al,(%edx)
	return 1;
  801f91:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801f96:	c9                   	leave  
  801f97:	c3                   	ret    
		return 0;
  801f98:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9d:	eb f7                	jmp    801f96 <devcons_read+0x36>

00801f9f <cputchar>:
{
  801f9f:	f3 0f 1e fb          	endbr32 
  801fa3:	55                   	push   %ebp
  801fa4:	89 e5                	mov    %esp,%ebp
  801fa6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fa9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fac:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801faf:	6a 01                	push   $0x1
  801fb1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fb4:	50                   	push   %eax
  801fb5:	e8 a9 f0 ff ff       	call   801063 <sys_cputs>
}
  801fba:	83 c4 10             	add    $0x10,%esp
  801fbd:	c9                   	leave  
  801fbe:	c3                   	ret    

00801fbf <getchar>:
{
  801fbf:	f3 0f 1e fb          	endbr32 
  801fc3:	55                   	push   %ebp
  801fc4:	89 e5                	mov    %esp,%ebp
  801fc6:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801fc9:	6a 01                	push   $0x1
  801fcb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fce:	50                   	push   %eax
  801fcf:	6a 00                	push   $0x0
  801fd1:	e8 3a f6 ff ff       	call   801610 <read>
	if (r < 0)
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	78 06                	js     801fe3 <getchar+0x24>
	if (r < 1)
  801fdd:	74 06                	je     801fe5 <getchar+0x26>
	return c;
  801fdf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801fe3:	c9                   	leave  
  801fe4:	c3                   	ret    
		return -E_EOF;
  801fe5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801fea:	eb f7                	jmp    801fe3 <getchar+0x24>

00801fec <iscons>:
{
  801fec:	f3 0f 1e fb          	endbr32 
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ff6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff9:	50                   	push   %eax
  801ffa:	ff 75 08             	pushl  0x8(%ebp)
  801ffd:	e8 8b f3 ff ff       	call   80138d <fd_lookup>
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	85 c0                	test   %eax,%eax
  802007:	78 11                	js     80201a <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802009:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802012:	39 10                	cmp    %edx,(%eax)
  802014:	0f 94 c0             	sete   %al
  802017:	0f b6 c0             	movzbl %al,%eax
}
  80201a:	c9                   	leave  
  80201b:	c3                   	ret    

0080201c <opencons>:
{
  80201c:	f3 0f 1e fb          	endbr32 
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802026:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802029:	50                   	push   %eax
  80202a:	e8 08 f3 ff ff       	call   801337 <fd_alloc>
  80202f:	83 c4 10             	add    $0x10,%esp
  802032:	85 c0                	test   %eax,%eax
  802034:	78 3a                	js     802070 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802036:	83 ec 04             	sub    $0x4,%esp
  802039:	68 07 04 00 00       	push   $0x407
  80203e:	ff 75 f4             	pushl  -0xc(%ebp)
  802041:	6a 00                	push   $0x0
  802043:	e8 e6 f0 ff ff       	call   80112e <sys_page_alloc>
  802048:	83 c4 10             	add    $0x10,%esp
  80204b:	85 c0                	test   %eax,%eax
  80204d:	78 21                	js     802070 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80204f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802052:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802058:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80205a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802064:	83 ec 0c             	sub    $0xc,%esp
  802067:	50                   	push   %eax
  802068:	e8 97 f2 ff ff       	call   801304 <fd2num>
  80206d:	83 c4 10             	add    $0x10,%esp
}
  802070:	c9                   	leave  
  802071:	c3                   	ret    

00802072 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802072:	f3 0f 1e fb          	endbr32 
  802076:	55                   	push   %ebp
  802077:	89 e5                	mov    %esp,%ebp
  802079:	56                   	push   %esi
  80207a:	53                   	push   %ebx
  80207b:	8b 75 08             	mov    0x8(%ebp),%esi
  80207e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802081:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  802084:	85 c0                	test   %eax,%eax
  802086:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80208b:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  80208e:	83 ec 0c             	sub    $0xc,%esp
  802091:	50                   	push   %eax
  802092:	e8 ae f1 ff ff       	call   801245 <sys_ipc_recv>
	if (f < 0) {
  802097:	83 c4 10             	add    $0x10,%esp
  80209a:	85 c0                	test   %eax,%eax
  80209c:	78 2b                	js     8020c9 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  80209e:	85 f6                	test   %esi,%esi
  8020a0:	74 0a                	je     8020ac <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  8020a2:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8020a7:	8b 40 74             	mov    0x74(%eax),%eax
  8020aa:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  8020ac:	85 db                	test   %ebx,%ebx
  8020ae:	74 0a                	je     8020ba <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  8020b0:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8020b5:	8b 40 78             	mov    0x78(%eax),%eax
  8020b8:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  8020ba:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8020bf:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020c5:	5b                   	pop    %ebx
  8020c6:	5e                   	pop    %esi
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    
		if (from_env_store != NULL) {
  8020c9:	85 f6                	test   %esi,%esi
  8020cb:	74 06                	je     8020d3 <ipc_recv+0x61>
			*from_env_store = 0;
  8020cd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  8020d3:	85 db                	test   %ebx,%ebx
  8020d5:	74 eb                	je     8020c2 <ipc_recv+0x50>
			*perm_store = 0;
  8020d7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020dd:	eb e3                	jmp    8020c2 <ipc_recv+0x50>

008020df <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020df:	f3 0f 1e fb          	endbr32 
  8020e3:	55                   	push   %ebp
  8020e4:	89 e5                	mov    %esp,%ebp
  8020e6:	57                   	push   %edi
  8020e7:	56                   	push   %esi
  8020e8:	53                   	push   %ebx
  8020e9:	83 ec 0c             	sub    $0xc,%esp
  8020ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020ef:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  8020f5:	85 db                	test   %ebx,%ebx
  8020f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8020fc:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8020ff:	ff 75 14             	pushl  0x14(%ebp)
  802102:	53                   	push   %ebx
  802103:	56                   	push   %esi
  802104:	57                   	push   %edi
  802105:	e8 12 f1 ff ff       	call   80121c <sys_ipc_try_send>
  80210a:	83 c4 10             	add    $0x10,%esp
  80210d:	85 c0                	test   %eax,%eax
  80210f:	79 19                	jns    80212a <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  802111:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802114:	74 e9                	je     8020ff <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  802116:	83 ec 04             	sub    $0x4,%esp
  802119:	68 04 2a 80 00       	push   $0x802a04
  80211e:	6a 48                	push   $0x48
  802120:	68 26 2a 80 00       	push   $0x802a26
  802125:	e8 2b e5 ff ff       	call   800655 <_panic>
		}
	}
}
  80212a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    

00802132 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802132:	f3 0f 1e fb          	endbr32 
  802136:	55                   	push   %ebp
  802137:	89 e5                	mov    %esp,%ebp
  802139:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80213c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802141:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802144:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80214a:	8b 52 50             	mov    0x50(%edx),%edx
  80214d:	39 ca                	cmp    %ecx,%edx
  80214f:	74 11                	je     802162 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802151:	83 c0 01             	add    $0x1,%eax
  802154:	3d 00 04 00 00       	cmp    $0x400,%eax
  802159:	75 e6                	jne    802141 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80215b:	b8 00 00 00 00       	mov    $0x0,%eax
  802160:	eb 0b                	jmp    80216d <ipc_find_env+0x3b>
			return envs[i].env_id;
  802162:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802165:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80216a:	8b 40 48             	mov    0x48(%eax),%eax
}
  80216d:	5d                   	pop    %ebp
  80216e:	c3                   	ret    

0080216f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80216f:	f3 0f 1e fb          	endbr32 
  802173:	55                   	push   %ebp
  802174:	89 e5                	mov    %esp,%ebp
  802176:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802179:	89 c2                	mov    %eax,%edx
  80217b:	c1 ea 16             	shr    $0x16,%edx
  80217e:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802185:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80218a:	f6 c1 01             	test   $0x1,%cl
  80218d:	74 1c                	je     8021ab <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80218f:	c1 e8 0c             	shr    $0xc,%eax
  802192:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802199:	a8 01                	test   $0x1,%al
  80219b:	74 0e                	je     8021ab <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80219d:	c1 e8 0c             	shr    $0xc,%eax
  8021a0:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8021a7:	ef 
  8021a8:	0f b7 d2             	movzwl %dx,%edx
}
  8021ab:	89 d0                	mov    %edx,%eax
  8021ad:	5d                   	pop    %ebp
  8021ae:	c3                   	ret    
  8021af:	90                   	nop

008021b0 <__udivdi3>:
  8021b0:	f3 0f 1e fb          	endbr32 
  8021b4:	55                   	push   %ebp
  8021b5:	57                   	push   %edi
  8021b6:	56                   	push   %esi
  8021b7:	53                   	push   %ebx
  8021b8:	83 ec 1c             	sub    $0x1c,%esp
  8021bb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021c3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021cb:	85 d2                	test   %edx,%edx
  8021cd:	75 19                	jne    8021e8 <__udivdi3+0x38>
  8021cf:	39 f3                	cmp    %esi,%ebx
  8021d1:	76 4d                	jbe    802220 <__udivdi3+0x70>
  8021d3:	31 ff                	xor    %edi,%edi
  8021d5:	89 e8                	mov    %ebp,%eax
  8021d7:	89 f2                	mov    %esi,%edx
  8021d9:	f7 f3                	div    %ebx
  8021db:	89 fa                	mov    %edi,%edx
  8021dd:	83 c4 1c             	add    $0x1c,%esp
  8021e0:	5b                   	pop    %ebx
  8021e1:	5e                   	pop    %esi
  8021e2:	5f                   	pop    %edi
  8021e3:	5d                   	pop    %ebp
  8021e4:	c3                   	ret    
  8021e5:	8d 76 00             	lea    0x0(%esi),%esi
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	76 14                	jbe    802200 <__udivdi3+0x50>
  8021ec:	31 ff                	xor    %edi,%edi
  8021ee:	31 c0                	xor    %eax,%eax
  8021f0:	89 fa                	mov    %edi,%edx
  8021f2:	83 c4 1c             	add    $0x1c,%esp
  8021f5:	5b                   	pop    %ebx
  8021f6:	5e                   	pop    %esi
  8021f7:	5f                   	pop    %edi
  8021f8:	5d                   	pop    %ebp
  8021f9:	c3                   	ret    
  8021fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802200:	0f bd fa             	bsr    %edx,%edi
  802203:	83 f7 1f             	xor    $0x1f,%edi
  802206:	75 48                	jne    802250 <__udivdi3+0xa0>
  802208:	39 f2                	cmp    %esi,%edx
  80220a:	72 06                	jb     802212 <__udivdi3+0x62>
  80220c:	31 c0                	xor    %eax,%eax
  80220e:	39 eb                	cmp    %ebp,%ebx
  802210:	77 de                	ja     8021f0 <__udivdi3+0x40>
  802212:	b8 01 00 00 00       	mov    $0x1,%eax
  802217:	eb d7                	jmp    8021f0 <__udivdi3+0x40>
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	89 d9                	mov    %ebx,%ecx
  802222:	85 db                	test   %ebx,%ebx
  802224:	75 0b                	jne    802231 <__udivdi3+0x81>
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	f7 f3                	div    %ebx
  80222f:	89 c1                	mov    %eax,%ecx
  802231:	31 d2                	xor    %edx,%edx
  802233:	89 f0                	mov    %esi,%eax
  802235:	f7 f1                	div    %ecx
  802237:	89 c6                	mov    %eax,%esi
  802239:	89 e8                	mov    %ebp,%eax
  80223b:	89 f7                	mov    %esi,%edi
  80223d:	f7 f1                	div    %ecx
  80223f:	89 fa                	mov    %edi,%edx
  802241:	83 c4 1c             	add    $0x1c,%esp
  802244:	5b                   	pop    %ebx
  802245:	5e                   	pop    %esi
  802246:	5f                   	pop    %edi
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	89 f9                	mov    %edi,%ecx
  802252:	b8 20 00 00 00       	mov    $0x20,%eax
  802257:	29 f8                	sub    %edi,%eax
  802259:	d3 e2                	shl    %cl,%edx
  80225b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80225f:	89 c1                	mov    %eax,%ecx
  802261:	89 da                	mov    %ebx,%edx
  802263:	d3 ea                	shr    %cl,%edx
  802265:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802269:	09 d1                	or     %edx,%ecx
  80226b:	89 f2                	mov    %esi,%edx
  80226d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802271:	89 f9                	mov    %edi,%ecx
  802273:	d3 e3                	shl    %cl,%ebx
  802275:	89 c1                	mov    %eax,%ecx
  802277:	d3 ea                	shr    %cl,%edx
  802279:	89 f9                	mov    %edi,%ecx
  80227b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80227f:	89 eb                	mov    %ebp,%ebx
  802281:	d3 e6                	shl    %cl,%esi
  802283:	89 c1                	mov    %eax,%ecx
  802285:	d3 eb                	shr    %cl,%ebx
  802287:	09 de                	or     %ebx,%esi
  802289:	89 f0                	mov    %esi,%eax
  80228b:	f7 74 24 08          	divl   0x8(%esp)
  80228f:	89 d6                	mov    %edx,%esi
  802291:	89 c3                	mov    %eax,%ebx
  802293:	f7 64 24 0c          	mull   0xc(%esp)
  802297:	39 d6                	cmp    %edx,%esi
  802299:	72 15                	jb     8022b0 <__udivdi3+0x100>
  80229b:	89 f9                	mov    %edi,%ecx
  80229d:	d3 e5                	shl    %cl,%ebp
  80229f:	39 c5                	cmp    %eax,%ebp
  8022a1:	73 04                	jae    8022a7 <__udivdi3+0xf7>
  8022a3:	39 d6                	cmp    %edx,%esi
  8022a5:	74 09                	je     8022b0 <__udivdi3+0x100>
  8022a7:	89 d8                	mov    %ebx,%eax
  8022a9:	31 ff                	xor    %edi,%edi
  8022ab:	e9 40 ff ff ff       	jmp    8021f0 <__udivdi3+0x40>
  8022b0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8022b3:	31 ff                	xor    %edi,%edi
  8022b5:	e9 36 ff ff ff       	jmp    8021f0 <__udivdi3+0x40>
  8022ba:	66 90                	xchg   %ax,%ax
  8022bc:	66 90                	xchg   %ax,%ax
  8022be:	66 90                	xchg   %ax,%ax

008022c0 <__umoddi3>:
  8022c0:	f3 0f 1e fb          	endbr32 
  8022c4:	55                   	push   %ebp
  8022c5:	57                   	push   %edi
  8022c6:	56                   	push   %esi
  8022c7:	53                   	push   %ebx
  8022c8:	83 ec 1c             	sub    $0x1c,%esp
  8022cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022cf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022d3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022d7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022db:	85 c0                	test   %eax,%eax
  8022dd:	75 19                	jne    8022f8 <__umoddi3+0x38>
  8022df:	39 df                	cmp    %ebx,%edi
  8022e1:	76 5d                	jbe    802340 <__umoddi3+0x80>
  8022e3:	89 f0                	mov    %esi,%eax
  8022e5:	89 da                	mov    %ebx,%edx
  8022e7:	f7 f7                	div    %edi
  8022e9:	89 d0                	mov    %edx,%eax
  8022eb:	31 d2                	xor    %edx,%edx
  8022ed:	83 c4 1c             	add    $0x1c,%esp
  8022f0:	5b                   	pop    %ebx
  8022f1:	5e                   	pop    %esi
  8022f2:	5f                   	pop    %edi
  8022f3:	5d                   	pop    %ebp
  8022f4:	c3                   	ret    
  8022f5:	8d 76 00             	lea    0x0(%esi),%esi
  8022f8:	89 f2                	mov    %esi,%edx
  8022fa:	39 d8                	cmp    %ebx,%eax
  8022fc:	76 12                	jbe    802310 <__umoddi3+0x50>
  8022fe:	89 f0                	mov    %esi,%eax
  802300:	89 da                	mov    %ebx,%edx
  802302:	83 c4 1c             	add    $0x1c,%esp
  802305:	5b                   	pop    %ebx
  802306:	5e                   	pop    %esi
  802307:	5f                   	pop    %edi
  802308:	5d                   	pop    %ebp
  802309:	c3                   	ret    
  80230a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802310:	0f bd e8             	bsr    %eax,%ebp
  802313:	83 f5 1f             	xor    $0x1f,%ebp
  802316:	75 50                	jne    802368 <__umoddi3+0xa8>
  802318:	39 d8                	cmp    %ebx,%eax
  80231a:	0f 82 e0 00 00 00    	jb     802400 <__umoddi3+0x140>
  802320:	89 d9                	mov    %ebx,%ecx
  802322:	39 f7                	cmp    %esi,%edi
  802324:	0f 86 d6 00 00 00    	jbe    802400 <__umoddi3+0x140>
  80232a:	89 d0                	mov    %edx,%eax
  80232c:	89 ca                	mov    %ecx,%edx
  80232e:	83 c4 1c             	add    $0x1c,%esp
  802331:	5b                   	pop    %ebx
  802332:	5e                   	pop    %esi
  802333:	5f                   	pop    %edi
  802334:	5d                   	pop    %ebp
  802335:	c3                   	ret    
  802336:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80233d:	8d 76 00             	lea    0x0(%esi),%esi
  802340:	89 fd                	mov    %edi,%ebp
  802342:	85 ff                	test   %edi,%edi
  802344:	75 0b                	jne    802351 <__umoddi3+0x91>
  802346:	b8 01 00 00 00       	mov    $0x1,%eax
  80234b:	31 d2                	xor    %edx,%edx
  80234d:	f7 f7                	div    %edi
  80234f:	89 c5                	mov    %eax,%ebp
  802351:	89 d8                	mov    %ebx,%eax
  802353:	31 d2                	xor    %edx,%edx
  802355:	f7 f5                	div    %ebp
  802357:	89 f0                	mov    %esi,%eax
  802359:	f7 f5                	div    %ebp
  80235b:	89 d0                	mov    %edx,%eax
  80235d:	31 d2                	xor    %edx,%edx
  80235f:	eb 8c                	jmp    8022ed <__umoddi3+0x2d>
  802361:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802368:	89 e9                	mov    %ebp,%ecx
  80236a:	ba 20 00 00 00       	mov    $0x20,%edx
  80236f:	29 ea                	sub    %ebp,%edx
  802371:	d3 e0                	shl    %cl,%eax
  802373:	89 44 24 08          	mov    %eax,0x8(%esp)
  802377:	89 d1                	mov    %edx,%ecx
  802379:	89 f8                	mov    %edi,%eax
  80237b:	d3 e8                	shr    %cl,%eax
  80237d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802381:	89 54 24 04          	mov    %edx,0x4(%esp)
  802385:	8b 54 24 04          	mov    0x4(%esp),%edx
  802389:	09 c1                	or     %eax,%ecx
  80238b:	89 d8                	mov    %ebx,%eax
  80238d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802391:	89 e9                	mov    %ebp,%ecx
  802393:	d3 e7                	shl    %cl,%edi
  802395:	89 d1                	mov    %edx,%ecx
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80239f:	d3 e3                	shl    %cl,%ebx
  8023a1:	89 c7                	mov    %eax,%edi
  8023a3:	89 d1                	mov    %edx,%ecx
  8023a5:	89 f0                	mov    %esi,%eax
  8023a7:	d3 e8                	shr    %cl,%eax
  8023a9:	89 e9                	mov    %ebp,%ecx
  8023ab:	89 fa                	mov    %edi,%edx
  8023ad:	d3 e6                	shl    %cl,%esi
  8023af:	09 d8                	or     %ebx,%eax
  8023b1:	f7 74 24 08          	divl   0x8(%esp)
  8023b5:	89 d1                	mov    %edx,%ecx
  8023b7:	89 f3                	mov    %esi,%ebx
  8023b9:	f7 64 24 0c          	mull   0xc(%esp)
  8023bd:	89 c6                	mov    %eax,%esi
  8023bf:	89 d7                	mov    %edx,%edi
  8023c1:	39 d1                	cmp    %edx,%ecx
  8023c3:	72 06                	jb     8023cb <__umoddi3+0x10b>
  8023c5:	75 10                	jne    8023d7 <__umoddi3+0x117>
  8023c7:	39 c3                	cmp    %eax,%ebx
  8023c9:	73 0c                	jae    8023d7 <__umoddi3+0x117>
  8023cb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8023cf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8023d3:	89 d7                	mov    %edx,%edi
  8023d5:	89 c6                	mov    %eax,%esi
  8023d7:	89 ca                	mov    %ecx,%edx
  8023d9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023de:	29 f3                	sub    %esi,%ebx
  8023e0:	19 fa                	sbb    %edi,%edx
  8023e2:	89 d0                	mov    %edx,%eax
  8023e4:	d3 e0                	shl    %cl,%eax
  8023e6:	89 e9                	mov    %ebp,%ecx
  8023e8:	d3 eb                	shr    %cl,%ebx
  8023ea:	d3 ea                	shr    %cl,%edx
  8023ec:	09 d8                	or     %ebx,%eax
  8023ee:	83 c4 1c             	add    $0x1c,%esp
  8023f1:	5b                   	pop    %ebx
  8023f2:	5e                   	pop    %esi
  8023f3:	5f                   	pop    %edi
  8023f4:	5d                   	pop    %ebp
  8023f5:	c3                   	ret    
  8023f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023fd:	8d 76 00             	lea    0x0(%esi),%esi
  802400:	29 fe                	sub    %edi,%esi
  802402:	19 c3                	sbb    %eax,%ebx
  802404:	89 f2                	mov    %esi,%edx
  802406:	89 d9                	mov    %ebx,%ecx
  802408:	e9 1d ff ff ff       	jmp    80232a <__umoddi3+0x6a>
