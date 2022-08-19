
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 58 06 00 00       	call   800689 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 ff 0c 00 00       	call   800d46 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 72 13 00 00       	call   8013cb <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 10 13 00 00       	call   801378 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 92 12 00 00       	call   80130b <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	f3 0f 1e fb          	endbr32 
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	57                   	push   %edi
  800086:	56                   	push   %esi
  800087:	53                   	push   %ebx
  800088:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008e:	ba 00 00 00 00       	mov    $0x0,%edx
  800093:	b8 20 24 80 00       	mov    $0x802420,%eax
  800098:	e8 96 ff ff ff       	call   800033 <xopen>
  80009d:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000a0:	74 08                	je     8000aa <umain+0x2c>
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	0f 88 e9 03 00 00    	js     800493 <umain+0x415>
		panic("serve_open /not-found: %e", r);
	else if (r >= 0)
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	0f 89 f3 03 00 00    	jns    8004a5 <umain+0x427>
		panic("serve_open /not-found succeeded!");

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b7:	b8 55 24 80 00       	mov    $0x802455,%eax
  8000bc:	e8 72 ff ff ff       	call   800033 <xopen>
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	0f 88 f0 03 00 00    	js     8004b9 <umain+0x43b>
		panic("serve_open /newmotd: %e", r);
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000c9:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000d0:	0f 85 f5 03 00 00    	jne    8004cb <umain+0x44d>
  8000d6:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  8000dd:	0f 85 e8 03 00 00    	jne    8004cb <umain+0x44d>
  8000e3:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  8000ea:	0f 85 db 03 00 00    	jne    8004cb <umain+0x44d>
		panic("serve_open did not fill struct Fd correctly\n");
	cprintf("serve_open is good\n");
  8000f0:	83 ec 0c             	sub    $0xc,%esp
  8000f3:	68 76 24 80 00       	push   $0x802476
  8000f8:	e8 df 06 00 00       	call   8007dc <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  8000fd:	83 c4 08             	add    $0x8,%esp
  800100:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  800106:	50                   	push   %eax
  800107:	68 00 c0 cc cc       	push   $0xccccc000
  80010c:	ff 15 1c 30 80 00    	call   *0x80301c
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	85 c0                	test   %eax,%eax
  800117:	0f 88 c2 03 00 00    	js     8004df <umain+0x461>
		panic("file_stat: %e", r);
	if (strlen(msg) != st.st_size)
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	ff 35 00 30 80 00    	pushl  0x803000
  800126:	e8 d8 0b 00 00       	call   800d03 <strlen>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800131:	0f 85 ba 03 00 00    	jne    8004f1 <umain+0x473>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
	cprintf("file_stat is good\n");
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	68 98 24 80 00       	push   $0x802498
  80013f:	e8 98 06 00 00       	call   8007dc <cprintf>

	memset(buf, 0, sizeof buf);
  800144:	83 c4 0c             	add    $0xc,%esp
  800147:	68 00 02 00 00       	push   $0x200
  80014c:	6a 00                	push   $0x0
  80014e:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800154:	53                   	push   %ebx
  800155:	e8 56 0d 00 00       	call   800eb0 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80015a:	83 c4 0c             	add    $0xc,%esp
  80015d:	68 00 02 00 00       	push   $0x200
  800162:	53                   	push   %ebx
  800163:	68 00 c0 cc cc       	push   $0xccccc000
  800168:	ff 15 10 30 80 00    	call   *0x803010
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	85 c0                	test   %eax,%eax
  800173:	0f 88 9d 03 00 00    	js     800516 <umain+0x498>
		panic("file_read: %e", r);
	if (strcmp(buf, msg) != 0)
  800179:	83 ec 08             	sub    $0x8,%esp
  80017c:	ff 35 00 30 80 00    	pushl  0x803000
  800182:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800188:	50                   	push   %eax
  800189:	e8 77 0c 00 00       	call   800e05 <strcmp>
  80018e:	83 c4 10             	add    $0x10,%esp
  800191:	85 c0                	test   %eax,%eax
  800193:	0f 85 8f 03 00 00    	jne    800528 <umain+0x4aa>
		panic("file_read returned wrong data");
	cprintf("file_read is good\n");
  800199:	83 ec 0c             	sub    $0xc,%esp
  80019c:	68 d7 24 80 00       	push   $0x8024d7
  8001a1:	e8 36 06 00 00       	call   8007dc <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8001a6:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8001ad:	ff 15 18 30 80 00    	call   *0x803018
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	85 c0                	test   %eax,%eax
  8001b8:	0f 88 7e 03 00 00    	js     80053c <umain+0x4be>
		panic("file_close: %e", r);
	cprintf("file_close is good\n");
  8001be:	83 ec 0c             	sub    $0xc,%esp
  8001c1:	68 f9 24 80 00       	push   $0x8024f9
  8001c6:	e8 11 06 00 00       	call   8007dc <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8001cb:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  8001d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d3:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  8001d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001db:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  8001e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e3:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  8001e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  8001eb:	83 c4 08             	add    $0x8,%esp
  8001ee:	68 00 c0 cc cc       	push   $0xccccc000
  8001f3:	6a 00                	push   $0x0
  8001f5:	e8 26 10 00 00       	call   801220 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  8001fa:	83 c4 0c             	add    $0xc,%esp
  8001fd:	68 00 02 00 00       	push   $0x200
  800202:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800208:	50                   	push   %eax
  800209:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80020c:	50                   	push   %eax
  80020d:	ff 15 10 30 80 00    	call   *0x803010
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800219:	0f 85 2f 03 00 00    	jne    80054e <umain+0x4d0>
		panic("serve_read does not handle stale fileids correctly: %e", r);
	cprintf("stale fileid is good\n");
  80021f:	83 ec 0c             	sub    $0xc,%esp
  800222:	68 0d 25 80 00       	push   $0x80250d
  800227:	e8 b0 05 00 00       	call   8007dc <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  80022c:	ba 02 01 00 00       	mov    $0x102,%edx
  800231:	b8 23 25 80 00       	mov    $0x802523,%eax
  800236:	e8 f8 fd ff ff       	call   800033 <xopen>
  80023b:	83 c4 10             	add    $0x10,%esp
  80023e:	85 c0                	test   %eax,%eax
  800240:	0f 88 1a 03 00 00    	js     800560 <umain+0x4e2>
		panic("serve_open /new-file: %e", r);

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800246:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	ff 35 00 30 80 00    	pushl  0x803000
  800255:	e8 a9 0a 00 00       	call   800d03 <strlen>
  80025a:	83 c4 0c             	add    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	ff 35 00 30 80 00    	pushl  0x803000
  800264:	68 00 c0 cc cc       	push   $0xccccc000
  800269:	ff d3                	call   *%ebx
  80026b:	89 c3                	mov    %eax,%ebx
  80026d:	83 c4 04             	add    $0x4,%esp
  800270:	ff 35 00 30 80 00    	pushl  0x803000
  800276:	e8 88 0a 00 00       	call   800d03 <strlen>
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	39 d8                	cmp    %ebx,%eax
  800280:	0f 85 ec 02 00 00    	jne    800572 <umain+0x4f4>
		panic("file_write: %e", r);
	cprintf("file_write is good\n");
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	68 55 25 80 00       	push   $0x802555
  80028e:	e8 49 05 00 00       	call   8007dc <cprintf>

	FVA->fd_offset = 0;
  800293:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  80029a:	00 00 00 
	memset(buf, 0, sizeof buf);
  80029d:	83 c4 0c             	add    $0xc,%esp
  8002a0:	68 00 02 00 00       	push   $0x200
  8002a5:	6a 00                	push   $0x0
  8002a7:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8002ad:	53                   	push   %ebx
  8002ae:	e8 fd 0b 00 00       	call   800eb0 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8002b3:	83 c4 0c             	add    $0xc,%esp
  8002b6:	68 00 02 00 00       	push   $0x200
  8002bb:	53                   	push   %ebx
  8002bc:	68 00 c0 cc cc       	push   $0xccccc000
  8002c1:	ff 15 10 30 80 00    	call   *0x803010
  8002c7:	89 c3                	mov    %eax,%ebx
  8002c9:	83 c4 10             	add    $0x10,%esp
  8002cc:	85 c0                	test   %eax,%eax
  8002ce:	0f 88 b0 02 00 00    	js     800584 <umain+0x506>
		panic("file_read after file_write: %e", r);
	if (r != strlen(msg))
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	ff 35 00 30 80 00    	pushl  0x803000
  8002dd:	e8 21 0a 00 00       	call   800d03 <strlen>
  8002e2:	83 c4 10             	add    $0x10,%esp
  8002e5:	39 d8                	cmp    %ebx,%eax
  8002e7:	0f 85 a9 02 00 00    	jne    800596 <umain+0x518>
		panic("file_read after file_write returned wrong length: %d", r);
	if (strcmp(buf, msg) != 0)
  8002ed:	83 ec 08             	sub    $0x8,%esp
  8002f0:	ff 35 00 30 80 00    	pushl  0x803000
  8002f6:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8002fc:	50                   	push   %eax
  8002fd:	e8 03 0b 00 00       	call   800e05 <strcmp>
  800302:	83 c4 10             	add    $0x10,%esp
  800305:	85 c0                	test   %eax,%eax
  800307:	0f 85 9b 02 00 00    	jne    8005a8 <umain+0x52a>
		panic("file_read after file_write returned wrong data");
	cprintf("file_read after file_write is good\n");
  80030d:	83 ec 0c             	sub    $0xc,%esp
  800310:	68 1c 27 80 00       	push   $0x80271c
  800315:	e8 c2 04 00 00       	call   8007dc <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80031a:	83 c4 08             	add    $0x8,%esp
  80031d:	6a 00                	push   $0x0
  80031f:	68 20 24 80 00       	push   $0x802420
  800324:	e8 a5 18 00 00       	call   801bce <open>
  800329:	83 c4 10             	add    $0x10,%esp
  80032c:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80032f:	74 08                	je     800339 <umain+0x2bb>
  800331:	85 c0                	test   %eax,%eax
  800333:	0f 88 83 02 00 00    	js     8005bc <umain+0x53e>
		panic("open /not-found: %e", r);
	else if (r >= 0)
  800339:	85 c0                	test   %eax,%eax
  80033b:	0f 89 8d 02 00 00    	jns    8005ce <umain+0x550>
		panic("open /not-found succeeded!");

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	6a 00                	push   $0x0
  800346:	68 55 24 80 00       	push   $0x802455
  80034b:	e8 7e 18 00 00       	call   801bce <open>
  800350:	83 c4 10             	add    $0x10,%esp
  800353:	85 c0                	test   %eax,%eax
  800355:	0f 88 87 02 00 00    	js     8005e2 <umain+0x564>
		panic("open /newmotd: %e", r);
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  80035b:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  80035e:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  800365:	0f 85 89 02 00 00    	jne    8005f4 <umain+0x576>
  80036b:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800372:	0f 85 7c 02 00 00    	jne    8005f4 <umain+0x576>
  800378:	8b 98 08 00 00 d0    	mov    -0x2ffffff8(%eax),%ebx
  80037e:	85 db                	test   %ebx,%ebx
  800380:	0f 85 6e 02 00 00    	jne    8005f4 <umain+0x576>
		panic("open did not fill struct Fd correctly\n");
	cprintf("open is good\n");
  800386:	83 ec 0c             	sub    $0xc,%esp
  800389:	68 7c 24 80 00       	push   $0x80247c
  80038e:	e8 49 04 00 00       	call   8007dc <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  800393:	83 c4 08             	add    $0x8,%esp
  800396:	68 01 01 00 00       	push   $0x101
  80039b:	68 84 25 80 00       	push   $0x802584
  8003a0:	e8 29 18 00 00       	call   801bce <open>
  8003a5:	89 c7                	mov    %eax,%edi
  8003a7:	83 c4 10             	add    $0x10,%esp
  8003aa:	85 c0                	test   %eax,%eax
  8003ac:	0f 88 56 02 00 00    	js     800608 <umain+0x58a>
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
  8003b2:	83 ec 04             	sub    $0x4,%esp
  8003b5:	68 00 02 00 00       	push   $0x200
  8003ba:	6a 00                	push   $0x0
  8003bc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003c2:	50                   	push   %eax
  8003c3:	e8 e8 0a 00 00       	call   800eb0 <memset>
  8003c8:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8003cb:	89 de                	mov    %ebx,%esi
		*(int*)buf = i;
  8003cd:	89 b5 4c fd ff ff    	mov    %esi,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8003d3:	83 ec 04             	sub    $0x4,%esp
  8003d6:	68 00 02 00 00       	push   $0x200
  8003db:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003e1:	50                   	push   %eax
  8003e2:	57                   	push   %edi
  8003e3:	e8 02 14 00 00       	call   8017ea <write>
  8003e8:	83 c4 10             	add    $0x10,%esp
  8003eb:	85 c0                	test   %eax,%eax
  8003ed:	0f 88 27 02 00 00    	js     80061a <umain+0x59c>
  8003f3:	81 c6 00 02 00 00    	add    $0x200,%esi
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8003f9:	81 fe 00 e0 01 00    	cmp    $0x1e000,%esi
  8003ff:	75 cc                	jne    8003cd <umain+0x34f>
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800401:	83 ec 0c             	sub    $0xc,%esp
  800404:	57                   	push   %edi
  800405:	e8 c0 11 00 00       	call   8015ca <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80040a:	83 c4 08             	add    $0x8,%esp
  80040d:	6a 00                	push   $0x0
  80040f:	68 84 25 80 00       	push   $0x802584
  800414:	e8 b5 17 00 00       	call   801bce <open>
  800419:	89 c6                	mov    %eax,%esi
  80041b:	83 c4 10             	add    $0x10,%esp
  80041e:	85 c0                	test   %eax,%eax
  800420:	0f 88 0a 02 00 00    	js     800630 <umain+0x5b2>
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800426:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
		*(int*)buf = i;
  80042c:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800432:	83 ec 04             	sub    $0x4,%esp
  800435:	68 00 02 00 00       	push   $0x200
  80043a:	57                   	push   %edi
  80043b:	56                   	push   %esi
  80043c:	e8 5e 13 00 00       	call   80179f <readn>
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	85 c0                	test   %eax,%eax
  800446:	0f 88 f6 01 00 00    	js     800642 <umain+0x5c4>
			panic("read /big@%d: %e", i, r);
		if (r != sizeof(buf))
  80044c:	3d 00 02 00 00       	cmp    $0x200,%eax
  800451:	0f 85 01 02 00 00    	jne    800658 <umain+0x5da>
			panic("read /big from %d returned %d < %d bytes",
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  800457:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  80045d:	39 d8                	cmp    %ebx,%eax
  80045f:	0f 85 0e 02 00 00    	jne    800673 <umain+0x5f5>
  800465:	81 c3 00 02 00 00    	add    $0x200,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80046b:	81 fb 00 e0 01 00    	cmp    $0x1e000,%ebx
  800471:	75 b9                	jne    80042c <umain+0x3ae>
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800473:	83 ec 0c             	sub    $0xc,%esp
  800476:	56                   	push   %esi
  800477:	e8 4e 11 00 00       	call   8015ca <close>
	cprintf("large file is good\n");
  80047c:	c7 04 24 c9 25 80 00 	movl   $0x8025c9,(%esp)
  800483:	e8 54 03 00 00       	call   8007dc <cprintf>
}
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048e:	5b                   	pop    %ebx
  80048f:	5e                   	pop    %esi
  800490:	5f                   	pop    %edi
  800491:	5d                   	pop    %ebp
  800492:	c3                   	ret    
		panic("serve_open /not-found: %e", r);
  800493:	50                   	push   %eax
  800494:	68 2b 24 80 00       	push   $0x80242b
  800499:	6a 20                	push   $0x20
  80049b:	68 45 24 80 00       	push   $0x802445
  8004a0:	e8 50 02 00 00       	call   8006f5 <_panic>
		panic("serve_open /not-found succeeded!");
  8004a5:	83 ec 04             	sub    $0x4,%esp
  8004a8:	68 e0 25 80 00       	push   $0x8025e0
  8004ad:	6a 22                	push   $0x22
  8004af:	68 45 24 80 00       	push   $0x802445
  8004b4:	e8 3c 02 00 00       	call   8006f5 <_panic>
		panic("serve_open /newmotd: %e", r);
  8004b9:	50                   	push   %eax
  8004ba:	68 5e 24 80 00       	push   $0x80245e
  8004bf:	6a 25                	push   $0x25
  8004c1:	68 45 24 80 00       	push   $0x802445
  8004c6:	e8 2a 02 00 00       	call   8006f5 <_panic>
		panic("serve_open did not fill struct Fd correctly\n");
  8004cb:	83 ec 04             	sub    $0x4,%esp
  8004ce:	68 04 26 80 00       	push   $0x802604
  8004d3:	6a 27                	push   $0x27
  8004d5:	68 45 24 80 00       	push   $0x802445
  8004da:	e8 16 02 00 00       	call   8006f5 <_panic>
		panic("file_stat: %e", r);
  8004df:	50                   	push   %eax
  8004e0:	68 8a 24 80 00       	push   $0x80248a
  8004e5:	6a 2b                	push   $0x2b
  8004e7:	68 45 24 80 00       	push   $0x802445
  8004ec:	e8 04 02 00 00       	call   8006f5 <_panic>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8004f1:	83 ec 0c             	sub    $0xc,%esp
  8004f4:	ff 35 00 30 80 00    	pushl  0x803000
  8004fa:	e8 04 08 00 00       	call   800d03 <strlen>
  8004ff:	89 04 24             	mov    %eax,(%esp)
  800502:	ff 75 cc             	pushl  -0x34(%ebp)
  800505:	68 34 26 80 00       	push   $0x802634
  80050a:	6a 2d                	push   $0x2d
  80050c:	68 45 24 80 00       	push   $0x802445
  800511:	e8 df 01 00 00       	call   8006f5 <_panic>
		panic("file_read: %e", r);
  800516:	50                   	push   %eax
  800517:	68 ab 24 80 00       	push   $0x8024ab
  80051c:	6a 32                	push   $0x32
  80051e:	68 45 24 80 00       	push   $0x802445
  800523:	e8 cd 01 00 00       	call   8006f5 <_panic>
		panic("file_read returned wrong data");
  800528:	83 ec 04             	sub    $0x4,%esp
  80052b:	68 b9 24 80 00       	push   $0x8024b9
  800530:	6a 34                	push   $0x34
  800532:	68 45 24 80 00       	push   $0x802445
  800537:	e8 b9 01 00 00       	call   8006f5 <_panic>
		panic("file_close: %e", r);
  80053c:	50                   	push   %eax
  80053d:	68 ea 24 80 00       	push   $0x8024ea
  800542:	6a 38                	push   $0x38
  800544:	68 45 24 80 00       	push   $0x802445
  800549:	e8 a7 01 00 00       	call   8006f5 <_panic>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  80054e:	50                   	push   %eax
  80054f:	68 5c 26 80 00       	push   $0x80265c
  800554:	6a 43                	push   $0x43
  800556:	68 45 24 80 00       	push   $0x802445
  80055b:	e8 95 01 00 00       	call   8006f5 <_panic>
		panic("serve_open /new-file: %e", r);
  800560:	50                   	push   %eax
  800561:	68 2d 25 80 00       	push   $0x80252d
  800566:	6a 48                	push   $0x48
  800568:	68 45 24 80 00       	push   $0x802445
  80056d:	e8 83 01 00 00       	call   8006f5 <_panic>
		panic("file_write: %e", r);
  800572:	53                   	push   %ebx
  800573:	68 46 25 80 00       	push   $0x802546
  800578:	6a 4b                	push   $0x4b
  80057a:	68 45 24 80 00       	push   $0x802445
  80057f:	e8 71 01 00 00       	call   8006f5 <_panic>
		panic("file_read after file_write: %e", r);
  800584:	50                   	push   %eax
  800585:	68 94 26 80 00       	push   $0x802694
  80058a:	6a 51                	push   $0x51
  80058c:	68 45 24 80 00       	push   $0x802445
  800591:	e8 5f 01 00 00       	call   8006f5 <_panic>
		panic("file_read after file_write returned wrong length: %d", r);
  800596:	53                   	push   %ebx
  800597:	68 b4 26 80 00       	push   $0x8026b4
  80059c:	6a 53                	push   $0x53
  80059e:	68 45 24 80 00       	push   $0x802445
  8005a3:	e8 4d 01 00 00       	call   8006f5 <_panic>
		panic("file_read after file_write returned wrong data");
  8005a8:	83 ec 04             	sub    $0x4,%esp
  8005ab:	68 ec 26 80 00       	push   $0x8026ec
  8005b0:	6a 55                	push   $0x55
  8005b2:	68 45 24 80 00       	push   $0x802445
  8005b7:	e8 39 01 00 00       	call   8006f5 <_panic>
		panic("open /not-found: %e", r);
  8005bc:	50                   	push   %eax
  8005bd:	68 31 24 80 00       	push   $0x802431
  8005c2:	6a 5a                	push   $0x5a
  8005c4:	68 45 24 80 00       	push   $0x802445
  8005c9:	e8 27 01 00 00       	call   8006f5 <_panic>
		panic("open /not-found succeeded!");
  8005ce:	83 ec 04             	sub    $0x4,%esp
  8005d1:	68 69 25 80 00       	push   $0x802569
  8005d6:	6a 5c                	push   $0x5c
  8005d8:	68 45 24 80 00       	push   $0x802445
  8005dd:	e8 13 01 00 00       	call   8006f5 <_panic>
		panic("open /newmotd: %e", r);
  8005e2:	50                   	push   %eax
  8005e3:	68 64 24 80 00       	push   $0x802464
  8005e8:	6a 5f                	push   $0x5f
  8005ea:	68 45 24 80 00       	push   $0x802445
  8005ef:	e8 01 01 00 00       	call   8006f5 <_panic>
		panic("open did not fill struct Fd correctly\n");
  8005f4:	83 ec 04             	sub    $0x4,%esp
  8005f7:	68 40 27 80 00       	push   $0x802740
  8005fc:	6a 62                	push   $0x62
  8005fe:	68 45 24 80 00       	push   $0x802445
  800603:	e8 ed 00 00 00       	call   8006f5 <_panic>
		panic("creat /big: %e", f);
  800608:	50                   	push   %eax
  800609:	68 89 25 80 00       	push   $0x802589
  80060e:	6a 67                	push   $0x67
  800610:	68 45 24 80 00       	push   $0x802445
  800615:	e8 db 00 00 00       	call   8006f5 <_panic>
			panic("write /big@%d: %e", i, r);
  80061a:	83 ec 0c             	sub    $0xc,%esp
  80061d:	50                   	push   %eax
  80061e:	56                   	push   %esi
  80061f:	68 98 25 80 00       	push   $0x802598
  800624:	6a 6c                	push   $0x6c
  800626:	68 45 24 80 00       	push   $0x802445
  80062b:	e8 c5 00 00 00       	call   8006f5 <_panic>
		panic("open /big: %e", f);
  800630:	50                   	push   %eax
  800631:	68 aa 25 80 00       	push   $0x8025aa
  800636:	6a 71                	push   $0x71
  800638:	68 45 24 80 00       	push   $0x802445
  80063d:	e8 b3 00 00 00       	call   8006f5 <_panic>
			panic("read /big@%d: %e", i, r);
  800642:	83 ec 0c             	sub    $0xc,%esp
  800645:	50                   	push   %eax
  800646:	53                   	push   %ebx
  800647:	68 b8 25 80 00       	push   $0x8025b8
  80064c:	6a 75                	push   $0x75
  80064e:	68 45 24 80 00       	push   $0x802445
  800653:	e8 9d 00 00 00       	call   8006f5 <_panic>
			panic("read /big from %d returned %d < %d bytes",
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	68 00 02 00 00       	push   $0x200
  800660:	50                   	push   %eax
  800661:	53                   	push   %ebx
  800662:	68 68 27 80 00       	push   $0x802768
  800667:	6a 77                	push   $0x77
  800669:	68 45 24 80 00       	push   $0x802445
  80066e:	e8 82 00 00 00       	call   8006f5 <_panic>
			panic("read /big from %d returned bad data %d",
  800673:	83 ec 0c             	sub    $0xc,%esp
  800676:	50                   	push   %eax
  800677:	53                   	push   %ebx
  800678:	68 94 27 80 00       	push   $0x802794
  80067d:	6a 7a                	push   $0x7a
  80067f:	68 45 24 80 00       	push   $0x802445
  800684:	e8 6c 00 00 00       	call   8006f5 <_panic>

00800689 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800689:	f3 0f 1e fb          	endbr32 
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	56                   	push   %esi
  800691:	53                   	push   %ebx
  800692:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800695:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800698:	e8 de 0a 00 00       	call   80117b <sys_getenvid>
	if (id >= 0)
  80069d:	85 c0                	test   %eax,%eax
  80069f:	78 12                	js     8006b3 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8006a1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8006a6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8006a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8006ae:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8006b3:	85 db                	test   %ebx,%ebx
  8006b5:	7e 07                	jle    8006be <libmain+0x35>
		binaryname = argv[0];
  8006b7:	8b 06                	mov    (%esi),%eax
  8006b9:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	56                   	push   %esi
  8006c2:	53                   	push   %ebx
  8006c3:	e8 b6 f9 ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  8006c8:	e8 0a 00 00 00       	call   8006d7 <exit>
}
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006d3:	5b                   	pop    %ebx
  8006d4:	5e                   	pop    %esi
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8006d7:	f3 0f 1e fb          	endbr32 
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8006e1:	e8 15 0f 00 00       	call   8015fb <close_all>
	sys_env_destroy(0);
  8006e6:	83 ec 0c             	sub    $0xc,%esp
  8006e9:	6a 00                	push   $0x0
  8006eb:	e8 65 0a 00 00       	call   801155 <sys_env_destroy>
}
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	c9                   	leave  
  8006f4:	c3                   	ret    

008006f5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8006f5:	f3 0f 1e fb          	endbr32 
  8006f9:	55                   	push   %ebp
  8006fa:	89 e5                	mov    %esp,%ebp
  8006fc:	56                   	push   %esi
  8006fd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8006fe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800701:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800707:	e8 6f 0a 00 00       	call   80117b <sys_getenvid>
  80070c:	83 ec 0c             	sub    $0xc,%esp
  80070f:	ff 75 0c             	pushl  0xc(%ebp)
  800712:	ff 75 08             	pushl  0x8(%ebp)
  800715:	56                   	push   %esi
  800716:	50                   	push   %eax
  800717:	68 ec 27 80 00       	push   $0x8027ec
  80071c:	e8 bb 00 00 00       	call   8007dc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800721:	83 c4 18             	add    $0x18,%esp
  800724:	53                   	push   %ebx
  800725:	ff 75 10             	pushl  0x10(%ebp)
  800728:	e8 5a 00 00 00       	call   800787 <vcprintf>
	cprintf("\n");
  80072d:	c7 04 24 4f 2c 80 00 	movl   $0x802c4f,(%esp)
  800734:	e8 a3 00 00 00       	call   8007dc <cprintf>
  800739:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80073c:	cc                   	int3   
  80073d:	eb fd                	jmp    80073c <_panic+0x47>

0080073f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80073f:	f3 0f 1e fb          	endbr32 
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	53                   	push   %ebx
  800747:	83 ec 04             	sub    $0x4,%esp
  80074a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80074d:	8b 13                	mov    (%ebx),%edx
  80074f:	8d 42 01             	lea    0x1(%edx),%eax
  800752:	89 03                	mov    %eax,(%ebx)
  800754:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800757:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80075b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800760:	74 09                	je     80076b <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800762:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800766:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800769:	c9                   	leave  
  80076a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	68 ff 00 00 00       	push   $0xff
  800773:	8d 43 08             	lea    0x8(%ebx),%eax
  800776:	50                   	push   %eax
  800777:	e8 87 09 00 00       	call   801103 <sys_cputs>
		b->idx = 0;
  80077c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	eb db                	jmp    800762 <putch+0x23>

00800787 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800787:	f3 0f 1e fb          	endbr32 
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800794:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80079b:	00 00 00 
	b.cnt = 0;
  80079e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8007a5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8007a8:	ff 75 0c             	pushl  0xc(%ebp)
  8007ab:	ff 75 08             	pushl  0x8(%ebp)
  8007ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007b4:	50                   	push   %eax
  8007b5:	68 3f 07 80 00       	push   $0x80073f
  8007ba:	e8 80 01 00 00       	call   80093f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8007bf:	83 c4 08             	add    $0x8,%esp
  8007c2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8007c8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8007ce:	50                   	push   %eax
  8007cf:	e8 2f 09 00 00       	call   801103 <sys_cputs>

	return b.cnt;
}
  8007d4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8007dc:	f3 0f 1e fb          	endbr32 
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8007e6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8007e9:	50                   	push   %eax
  8007ea:	ff 75 08             	pushl  0x8(%ebp)
  8007ed:	e8 95 ff ff ff       	call   800787 <vcprintf>
	va_end(ap);

	return cnt;
}
  8007f2:	c9                   	leave  
  8007f3:	c3                   	ret    

008007f4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	57                   	push   %edi
  8007f8:	56                   	push   %esi
  8007f9:	53                   	push   %ebx
  8007fa:	83 ec 1c             	sub    $0x1c,%esp
  8007fd:	89 c7                	mov    %eax,%edi
  8007ff:	89 d6                	mov    %edx,%esi
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
  800807:	89 d1                	mov    %edx,%ecx
  800809:	89 c2                	mov    %eax,%edx
  80080b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80080e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800811:	8b 45 10             	mov    0x10(%ebp),%eax
  800814:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800817:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80081a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800821:	39 c2                	cmp    %eax,%edx
  800823:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800826:	72 3e                	jb     800866 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800828:	83 ec 0c             	sub    $0xc,%esp
  80082b:	ff 75 18             	pushl  0x18(%ebp)
  80082e:	83 eb 01             	sub    $0x1,%ebx
  800831:	53                   	push   %ebx
  800832:	50                   	push   %eax
  800833:	83 ec 08             	sub    $0x8,%esp
  800836:	ff 75 e4             	pushl  -0x1c(%ebp)
  800839:	ff 75 e0             	pushl  -0x20(%ebp)
  80083c:	ff 75 dc             	pushl  -0x24(%ebp)
  80083f:	ff 75 d8             	pushl  -0x28(%ebp)
  800842:	e8 79 19 00 00       	call   8021c0 <__udivdi3>
  800847:	83 c4 18             	add    $0x18,%esp
  80084a:	52                   	push   %edx
  80084b:	50                   	push   %eax
  80084c:	89 f2                	mov    %esi,%edx
  80084e:	89 f8                	mov    %edi,%eax
  800850:	e8 9f ff ff ff       	call   8007f4 <printnum>
  800855:	83 c4 20             	add    $0x20,%esp
  800858:	eb 13                	jmp    80086d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	56                   	push   %esi
  80085e:	ff 75 18             	pushl  0x18(%ebp)
  800861:	ff d7                	call   *%edi
  800863:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800866:	83 eb 01             	sub    $0x1,%ebx
  800869:	85 db                	test   %ebx,%ebx
  80086b:	7f ed                	jg     80085a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80086d:	83 ec 08             	sub    $0x8,%esp
  800870:	56                   	push   %esi
  800871:	83 ec 04             	sub    $0x4,%esp
  800874:	ff 75 e4             	pushl  -0x1c(%ebp)
  800877:	ff 75 e0             	pushl  -0x20(%ebp)
  80087a:	ff 75 dc             	pushl  -0x24(%ebp)
  80087d:	ff 75 d8             	pushl  -0x28(%ebp)
  800880:	e8 4b 1a 00 00       	call   8022d0 <__umoddi3>
  800885:	83 c4 14             	add    $0x14,%esp
  800888:	0f be 80 0f 28 80 00 	movsbl 0x80280f(%eax),%eax
  80088f:	50                   	push   %eax
  800890:	ff d7                	call   *%edi
}
  800892:	83 c4 10             	add    $0x10,%esp
  800895:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5f                   	pop    %edi
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80089d:	83 fa 01             	cmp    $0x1,%edx
  8008a0:	7f 13                	jg     8008b5 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008a2:	85 d2                	test   %edx,%edx
  8008a4:	74 1c                	je     8008c2 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8008a6:	8b 10                	mov    (%eax),%edx
  8008a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8008ab:	89 08                	mov    %ecx,(%eax)
  8008ad:	8b 02                	mov    (%edx),%eax
  8008af:	ba 00 00 00 00       	mov    $0x0,%edx
  8008b4:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8008b5:	8b 10                	mov    (%eax),%edx
  8008b7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8008ba:	89 08                	mov    %ecx,(%eax)
  8008bc:	8b 02                	mov    (%edx),%eax
  8008be:	8b 52 04             	mov    0x4(%edx),%edx
  8008c1:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8008c2:	8b 10                	mov    (%eax),%edx
  8008c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8008c7:	89 08                	mov    %ecx,(%eax)
  8008c9:	8b 02                	mov    (%edx),%eax
  8008cb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8008d0:	c3                   	ret    

008008d1 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008d1:	83 fa 01             	cmp    $0x1,%edx
  8008d4:	7f 0f                	jg     8008e5 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8008d6:	85 d2                	test   %edx,%edx
  8008d8:	74 18                	je     8008f2 <getint+0x21>
		return va_arg(*ap, long);
  8008da:	8b 10                	mov    (%eax),%edx
  8008dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8008df:	89 08                	mov    %ecx,(%eax)
  8008e1:	8b 02                	mov    (%edx),%eax
  8008e3:	99                   	cltd   
  8008e4:	c3                   	ret    
		return va_arg(*ap, long long);
  8008e5:	8b 10                	mov    (%eax),%edx
  8008e7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8008ea:	89 08                	mov    %ecx,(%eax)
  8008ec:	8b 02                	mov    (%edx),%eax
  8008ee:	8b 52 04             	mov    0x4(%edx),%edx
  8008f1:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8008f2:	8b 10                	mov    (%eax),%edx
  8008f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8008f7:	89 08                	mov    %ecx,(%eax)
  8008f9:	8b 02                	mov    (%edx),%eax
  8008fb:	99                   	cltd   
}
  8008fc:	c3                   	ret    

008008fd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8008fd:	f3 0f 1e fb          	endbr32 
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800907:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80090b:	8b 10                	mov    (%eax),%edx
  80090d:	3b 50 04             	cmp    0x4(%eax),%edx
  800910:	73 0a                	jae    80091c <sprintputch+0x1f>
		*b->buf++ = ch;
  800912:	8d 4a 01             	lea    0x1(%edx),%ecx
  800915:	89 08                	mov    %ecx,(%eax)
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	88 02                	mov    %al,(%edx)
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <printfmt>:
{
  80091e:	f3 0f 1e fb          	endbr32 
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800928:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80092b:	50                   	push   %eax
  80092c:	ff 75 10             	pushl  0x10(%ebp)
  80092f:	ff 75 0c             	pushl  0xc(%ebp)
  800932:	ff 75 08             	pushl  0x8(%ebp)
  800935:	e8 05 00 00 00       	call   80093f <vprintfmt>
}
  80093a:	83 c4 10             	add    $0x10,%esp
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    

0080093f <vprintfmt>:
{
  80093f:	f3 0f 1e fb          	endbr32 
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	57                   	push   %edi
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	83 ec 2c             	sub    $0x2c,%esp
  80094c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80094f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800952:	8b 7d 10             	mov    0x10(%ebp),%edi
  800955:	e9 86 02 00 00       	jmp    800be0 <vprintfmt+0x2a1>
		padc = ' ';
  80095a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80095e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800965:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80096c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800973:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800978:	8d 47 01             	lea    0x1(%edi),%eax
  80097b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80097e:	0f b6 17             	movzbl (%edi),%edx
  800981:	8d 42 dd             	lea    -0x23(%edx),%eax
  800984:	3c 55                	cmp    $0x55,%al
  800986:	0f 87 df 02 00 00    	ja     800c6b <vprintfmt+0x32c>
  80098c:	0f b6 c0             	movzbl %al,%eax
  80098f:	3e ff 24 85 60 29 80 	notrack jmp *0x802960(,%eax,4)
  800996:	00 
  800997:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80099a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80099e:	eb d8                	jmp    800978 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8009a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009a3:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8009a7:	eb cf                	jmp    800978 <vprintfmt+0x39>
  8009a9:	0f b6 d2             	movzbl %dl,%edx
  8009ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8009af:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8009b7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8009ba:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8009be:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8009c1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8009c4:	83 f9 09             	cmp    $0x9,%ecx
  8009c7:	77 52                	ja     800a1b <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8009c9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8009cc:	eb e9                	jmp    8009b7 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8009ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d1:	8d 50 04             	lea    0x4(%eax),%edx
  8009d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8009d7:	8b 00                	mov    (%eax),%eax
  8009d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8009dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8009df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009e3:	79 93                	jns    800978 <vprintfmt+0x39>
				width = precision, precision = -1;
  8009e5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009eb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8009f2:	eb 84                	jmp    800978 <vprintfmt+0x39>
  8009f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009f7:	85 c0                	test   %eax,%eax
  8009f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fe:	0f 49 d0             	cmovns %eax,%edx
  800a01:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800a04:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800a07:	e9 6c ff ff ff       	jmp    800978 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800a0c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800a0f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800a16:	e9 5d ff ff ff       	jmp    800978 <vprintfmt+0x39>
  800a1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a1e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800a21:	eb bc                	jmp    8009df <vprintfmt+0xa0>
			lflag++;
  800a23:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800a26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800a29:	e9 4a ff ff ff       	jmp    800978 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800a2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a31:	8d 50 04             	lea    0x4(%eax),%edx
  800a34:	89 55 14             	mov    %edx,0x14(%ebp)
  800a37:	83 ec 08             	sub    $0x8,%esp
  800a3a:	56                   	push   %esi
  800a3b:	ff 30                	pushl  (%eax)
  800a3d:	ff d3                	call   *%ebx
			break;
  800a3f:	83 c4 10             	add    $0x10,%esp
  800a42:	e9 96 01 00 00       	jmp    800bdd <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800a47:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4a:	8d 50 04             	lea    0x4(%eax),%edx
  800a4d:	89 55 14             	mov    %edx,0x14(%ebp)
  800a50:	8b 00                	mov    (%eax),%eax
  800a52:	99                   	cltd   
  800a53:	31 d0                	xor    %edx,%eax
  800a55:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a57:	83 f8 0f             	cmp    $0xf,%eax
  800a5a:	7f 20                	jg     800a7c <vprintfmt+0x13d>
  800a5c:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  800a63:	85 d2                	test   %edx,%edx
  800a65:	74 15                	je     800a7c <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800a67:	52                   	push   %edx
  800a68:	68 1d 2c 80 00       	push   $0x802c1d
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	e8 aa fe ff ff       	call   80091e <printfmt>
  800a74:	83 c4 10             	add    $0x10,%esp
  800a77:	e9 61 01 00 00       	jmp    800bdd <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800a7c:	50                   	push   %eax
  800a7d:	68 27 28 80 00       	push   $0x802827
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	e8 95 fe ff ff       	call   80091e <printfmt>
  800a89:	83 c4 10             	add    $0x10,%esp
  800a8c:	e9 4c 01 00 00       	jmp    800bdd <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800a91:	8b 45 14             	mov    0x14(%ebp),%eax
  800a94:	8d 50 04             	lea    0x4(%eax),%edx
  800a97:	89 55 14             	mov    %edx,0x14(%ebp)
  800a9a:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800a9c:	85 c9                	test   %ecx,%ecx
  800a9e:	b8 20 28 80 00       	mov    $0x802820,%eax
  800aa3:	0f 45 c1             	cmovne %ecx,%eax
  800aa6:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800aa9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800aad:	7e 06                	jle    800ab5 <vprintfmt+0x176>
  800aaf:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800ab3:	75 0d                	jne    800ac2 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800ab5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ab8:	89 c7                	mov    %eax,%edi
  800aba:	03 45 e0             	add    -0x20(%ebp),%eax
  800abd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ac0:	eb 57                	jmp    800b19 <vprintfmt+0x1da>
  800ac2:	83 ec 08             	sub    $0x8,%esp
  800ac5:	ff 75 d8             	pushl  -0x28(%ebp)
  800ac8:	ff 75 cc             	pushl  -0x34(%ebp)
  800acb:	e8 4f 02 00 00       	call   800d1f <strnlen>
  800ad0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800ad3:	29 c2                	sub    %eax,%edx
  800ad5:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800ad8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800adb:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800adf:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800ae2:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800ae4:	85 db                	test   %ebx,%ebx
  800ae6:	7e 10                	jle    800af8 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800ae8:	83 ec 08             	sub    $0x8,%esp
  800aeb:	56                   	push   %esi
  800aec:	57                   	push   %edi
  800aed:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800af0:	83 eb 01             	sub    $0x1,%ebx
  800af3:	83 c4 10             	add    $0x10,%esp
  800af6:	eb ec                	jmp    800ae4 <vprintfmt+0x1a5>
  800af8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800afb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800afe:	85 d2                	test   %edx,%edx
  800b00:	b8 00 00 00 00       	mov    $0x0,%eax
  800b05:	0f 49 c2             	cmovns %edx,%eax
  800b08:	29 c2                	sub    %eax,%edx
  800b0a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b0d:	eb a6                	jmp    800ab5 <vprintfmt+0x176>
					putch(ch, putdat);
  800b0f:	83 ec 08             	sub    $0x8,%esp
  800b12:	56                   	push   %esi
  800b13:	52                   	push   %edx
  800b14:	ff d3                	call   *%ebx
  800b16:	83 c4 10             	add    $0x10,%esp
  800b19:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b1c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b1e:	83 c7 01             	add    $0x1,%edi
  800b21:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800b25:	0f be d0             	movsbl %al,%edx
  800b28:	85 d2                	test   %edx,%edx
  800b2a:	74 42                	je     800b6e <vprintfmt+0x22f>
  800b2c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b30:	78 06                	js     800b38 <vprintfmt+0x1f9>
  800b32:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800b36:	78 1e                	js     800b56 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800b38:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800b3c:	74 d1                	je     800b0f <vprintfmt+0x1d0>
  800b3e:	0f be c0             	movsbl %al,%eax
  800b41:	83 e8 20             	sub    $0x20,%eax
  800b44:	83 f8 5e             	cmp    $0x5e,%eax
  800b47:	76 c6                	jbe    800b0f <vprintfmt+0x1d0>
					putch('?', putdat);
  800b49:	83 ec 08             	sub    $0x8,%esp
  800b4c:	56                   	push   %esi
  800b4d:	6a 3f                	push   $0x3f
  800b4f:	ff d3                	call   *%ebx
  800b51:	83 c4 10             	add    $0x10,%esp
  800b54:	eb c3                	jmp    800b19 <vprintfmt+0x1da>
  800b56:	89 cf                	mov    %ecx,%edi
  800b58:	eb 0e                	jmp    800b68 <vprintfmt+0x229>
				putch(' ', putdat);
  800b5a:	83 ec 08             	sub    $0x8,%esp
  800b5d:	56                   	push   %esi
  800b5e:	6a 20                	push   $0x20
  800b60:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800b62:	83 ef 01             	sub    $0x1,%edi
  800b65:	83 c4 10             	add    $0x10,%esp
  800b68:	85 ff                	test   %edi,%edi
  800b6a:	7f ee                	jg     800b5a <vprintfmt+0x21b>
  800b6c:	eb 6f                	jmp    800bdd <vprintfmt+0x29e>
  800b6e:	89 cf                	mov    %ecx,%edi
  800b70:	eb f6                	jmp    800b68 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800b72:	89 ca                	mov    %ecx,%edx
  800b74:	8d 45 14             	lea    0x14(%ebp),%eax
  800b77:	e8 55 fd ff ff       	call   8008d1 <getint>
  800b7c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b7f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800b82:	85 d2                	test   %edx,%edx
  800b84:	78 0b                	js     800b91 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800b86:	89 d1                	mov    %edx,%ecx
  800b88:	89 c2                	mov    %eax,%edx
			base = 10;
  800b8a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b8f:	eb 32                	jmp    800bc3 <vprintfmt+0x284>
				putch('-', putdat);
  800b91:	83 ec 08             	sub    $0x8,%esp
  800b94:	56                   	push   %esi
  800b95:	6a 2d                	push   $0x2d
  800b97:	ff d3                	call   *%ebx
				num = -(long long) num;
  800b99:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b9c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b9f:	f7 da                	neg    %edx
  800ba1:	83 d1 00             	adc    $0x0,%ecx
  800ba4:	f7 d9                	neg    %ecx
  800ba6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800ba9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bae:	eb 13                	jmp    800bc3 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800bb0:	89 ca                	mov    %ecx,%edx
  800bb2:	8d 45 14             	lea    0x14(%ebp),%eax
  800bb5:	e8 e3 fc ff ff       	call   80089d <getuint>
  800bba:	89 d1                	mov    %edx,%ecx
  800bbc:	89 c2                	mov    %eax,%edx
			base = 10;
  800bbe:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800bca:	57                   	push   %edi
  800bcb:	ff 75 e0             	pushl  -0x20(%ebp)
  800bce:	50                   	push   %eax
  800bcf:	51                   	push   %ecx
  800bd0:	52                   	push   %edx
  800bd1:	89 f2                	mov    %esi,%edx
  800bd3:	89 d8                	mov    %ebx,%eax
  800bd5:	e8 1a fc ff ff       	call   8007f4 <printnum>
			break;
  800bda:	83 c4 20             	add    $0x20,%esp
{
  800bdd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800be0:	83 c7 01             	add    $0x1,%edi
  800be3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800be7:	83 f8 25             	cmp    $0x25,%eax
  800bea:	0f 84 6a fd ff ff    	je     80095a <vprintfmt+0x1b>
			if (ch == '\0')
  800bf0:	85 c0                	test   %eax,%eax
  800bf2:	0f 84 93 00 00 00    	je     800c8b <vprintfmt+0x34c>
			putch(ch, putdat);
  800bf8:	83 ec 08             	sub    $0x8,%esp
  800bfb:	56                   	push   %esi
  800bfc:	50                   	push   %eax
  800bfd:	ff d3                	call   *%ebx
  800bff:	83 c4 10             	add    $0x10,%esp
  800c02:	eb dc                	jmp    800be0 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800c04:	89 ca                	mov    %ecx,%edx
  800c06:	8d 45 14             	lea    0x14(%ebp),%eax
  800c09:	e8 8f fc ff ff       	call   80089d <getuint>
  800c0e:	89 d1                	mov    %edx,%ecx
  800c10:	89 c2                	mov    %eax,%edx
			base = 8;
  800c12:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800c17:	eb aa                	jmp    800bc3 <vprintfmt+0x284>
			putch('0', putdat);
  800c19:	83 ec 08             	sub    $0x8,%esp
  800c1c:	56                   	push   %esi
  800c1d:	6a 30                	push   $0x30
  800c1f:	ff d3                	call   *%ebx
			putch('x', putdat);
  800c21:	83 c4 08             	add    $0x8,%esp
  800c24:	56                   	push   %esi
  800c25:	6a 78                	push   $0x78
  800c27:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800c29:	8b 45 14             	mov    0x14(%ebp),%eax
  800c2c:	8d 50 04             	lea    0x4(%eax),%edx
  800c2f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800c32:	8b 10                	mov    (%eax),%edx
  800c34:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800c39:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800c3c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800c41:	eb 80                	jmp    800bc3 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800c43:	89 ca                	mov    %ecx,%edx
  800c45:	8d 45 14             	lea    0x14(%ebp),%eax
  800c48:	e8 50 fc ff ff       	call   80089d <getuint>
  800c4d:	89 d1                	mov    %edx,%ecx
  800c4f:	89 c2                	mov    %eax,%edx
			base = 16;
  800c51:	b8 10 00 00 00       	mov    $0x10,%eax
  800c56:	e9 68 ff ff ff       	jmp    800bc3 <vprintfmt+0x284>
			putch(ch, putdat);
  800c5b:	83 ec 08             	sub    $0x8,%esp
  800c5e:	56                   	push   %esi
  800c5f:	6a 25                	push   $0x25
  800c61:	ff d3                	call   *%ebx
			break;
  800c63:	83 c4 10             	add    $0x10,%esp
  800c66:	e9 72 ff ff ff       	jmp    800bdd <vprintfmt+0x29e>
			putch('%', putdat);
  800c6b:	83 ec 08             	sub    $0x8,%esp
  800c6e:	56                   	push   %esi
  800c6f:	6a 25                	push   $0x25
  800c71:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c73:	83 c4 10             	add    $0x10,%esp
  800c76:	89 f8                	mov    %edi,%eax
  800c78:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800c7c:	74 05                	je     800c83 <vprintfmt+0x344>
  800c7e:	83 e8 01             	sub    $0x1,%eax
  800c81:	eb f5                	jmp    800c78 <vprintfmt+0x339>
  800c83:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c86:	e9 52 ff ff ff       	jmp    800bdd <vprintfmt+0x29e>
}
  800c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c93:	f3 0f 1e fb          	endbr32 
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	83 ec 18             	sub    $0x18,%esp
  800c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ca3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ca6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800caa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	74 26                	je     800cde <vsnprintf+0x4b>
  800cb8:	85 d2                	test   %edx,%edx
  800cba:	7e 22                	jle    800cde <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cbc:	ff 75 14             	pushl  0x14(%ebp)
  800cbf:	ff 75 10             	pushl  0x10(%ebp)
  800cc2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cc5:	50                   	push   %eax
  800cc6:	68 fd 08 80 00       	push   $0x8008fd
  800ccb:	e8 6f fc ff ff       	call   80093f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cd3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd9:	83 c4 10             	add    $0x10,%esp
}
  800cdc:	c9                   	leave  
  800cdd:	c3                   	ret    
		return -E_INVAL;
  800cde:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ce3:	eb f7                	jmp    800cdc <vsnprintf+0x49>

00800ce5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ce5:	f3 0f 1e fb          	endbr32 
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cf2:	50                   	push   %eax
  800cf3:	ff 75 10             	pushl  0x10(%ebp)
  800cf6:	ff 75 0c             	pushl  0xc(%ebp)
  800cf9:	ff 75 08             	pushl  0x8(%ebp)
  800cfc:	e8 92 ff ff ff       	call   800c93 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d01:	c9                   	leave  
  800d02:	c3                   	ret    

00800d03 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d03:	f3 0f 1e fb          	endbr32 
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d12:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d16:	74 05                	je     800d1d <strlen+0x1a>
		n++;
  800d18:	83 c0 01             	add    $0x1,%eax
  800d1b:	eb f5                	jmp    800d12 <strlen+0xf>
	return n;
}
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d1f:	f3 0f 1e fb          	endbr32 
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d29:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d31:	39 d0                	cmp    %edx,%eax
  800d33:	74 0d                	je     800d42 <strnlen+0x23>
  800d35:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d39:	74 05                	je     800d40 <strnlen+0x21>
		n++;
  800d3b:	83 c0 01             	add    $0x1,%eax
  800d3e:	eb f1                	jmp    800d31 <strnlen+0x12>
  800d40:	89 c2                	mov    %eax,%edx
	return n;
}
  800d42:	89 d0                	mov    %edx,%eax
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d46:	f3 0f 1e fb          	endbr32 
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	53                   	push   %ebx
  800d4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d54:	b8 00 00 00 00       	mov    $0x0,%eax
  800d59:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800d5d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800d60:	83 c0 01             	add    $0x1,%eax
  800d63:	84 d2                	test   %dl,%dl
  800d65:	75 f2                	jne    800d59 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800d67:	89 c8                	mov    %ecx,%eax
  800d69:	5b                   	pop    %ebx
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d6c:	f3 0f 1e fb          	endbr32 
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	53                   	push   %ebx
  800d74:	83 ec 10             	sub    $0x10,%esp
  800d77:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d7a:	53                   	push   %ebx
  800d7b:	e8 83 ff ff ff       	call   800d03 <strlen>
  800d80:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800d83:	ff 75 0c             	pushl  0xc(%ebp)
  800d86:	01 d8                	add    %ebx,%eax
  800d88:	50                   	push   %eax
  800d89:	e8 b8 ff ff ff       	call   800d46 <strcpy>
	return dst;
}
  800d8e:	89 d8                	mov    %ebx,%eax
  800d90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d93:	c9                   	leave  
  800d94:	c3                   	ret    

00800d95 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d95:	f3 0f 1e fb          	endbr32 
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
  800d9e:	8b 75 08             	mov    0x8(%ebp),%esi
  800da1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da4:	89 f3                	mov    %esi,%ebx
  800da6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800da9:	89 f0                	mov    %esi,%eax
  800dab:	39 d8                	cmp    %ebx,%eax
  800dad:	74 11                	je     800dc0 <strncpy+0x2b>
		*dst++ = *src;
  800daf:	83 c0 01             	add    $0x1,%eax
  800db2:	0f b6 0a             	movzbl (%edx),%ecx
  800db5:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800db8:	80 f9 01             	cmp    $0x1,%cl
  800dbb:	83 da ff             	sbb    $0xffffffff,%edx
  800dbe:	eb eb                	jmp    800dab <strncpy+0x16>
	}
	return ret;
}
  800dc0:	89 f0                	mov    %esi,%eax
  800dc2:	5b                   	pop    %ebx
  800dc3:	5e                   	pop    %esi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dc6:	f3 0f 1e fb          	endbr32 
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	56                   	push   %esi
  800dce:	53                   	push   %ebx
  800dcf:	8b 75 08             	mov    0x8(%ebp),%esi
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd5:	8b 55 10             	mov    0x10(%ebp),%edx
  800dd8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dda:	85 d2                	test   %edx,%edx
  800ddc:	74 21                	je     800dff <strlcpy+0x39>
  800dde:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800de2:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800de4:	39 c2                	cmp    %eax,%edx
  800de6:	74 14                	je     800dfc <strlcpy+0x36>
  800de8:	0f b6 19             	movzbl (%ecx),%ebx
  800deb:	84 db                	test   %bl,%bl
  800ded:	74 0b                	je     800dfa <strlcpy+0x34>
			*dst++ = *src++;
  800def:	83 c1 01             	add    $0x1,%ecx
  800df2:	83 c2 01             	add    $0x1,%edx
  800df5:	88 5a ff             	mov    %bl,-0x1(%edx)
  800df8:	eb ea                	jmp    800de4 <strlcpy+0x1e>
  800dfa:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800dfc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dff:	29 f0                	sub    %esi,%eax
}
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e05:	f3 0f 1e fb          	endbr32 
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e12:	0f b6 01             	movzbl (%ecx),%eax
  800e15:	84 c0                	test   %al,%al
  800e17:	74 0c                	je     800e25 <strcmp+0x20>
  800e19:	3a 02                	cmp    (%edx),%al
  800e1b:	75 08                	jne    800e25 <strcmp+0x20>
		p++, q++;
  800e1d:	83 c1 01             	add    $0x1,%ecx
  800e20:	83 c2 01             	add    $0x1,%edx
  800e23:	eb ed                	jmp    800e12 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e25:	0f b6 c0             	movzbl %al,%eax
  800e28:	0f b6 12             	movzbl (%edx),%edx
  800e2b:	29 d0                	sub    %edx,%eax
}
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e2f:	f3 0f 1e fb          	endbr32 
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	53                   	push   %ebx
  800e37:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3d:	89 c3                	mov    %eax,%ebx
  800e3f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e42:	eb 06                	jmp    800e4a <strncmp+0x1b>
		n--, p++, q++;
  800e44:	83 c0 01             	add    $0x1,%eax
  800e47:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800e4a:	39 d8                	cmp    %ebx,%eax
  800e4c:	74 16                	je     800e64 <strncmp+0x35>
  800e4e:	0f b6 08             	movzbl (%eax),%ecx
  800e51:	84 c9                	test   %cl,%cl
  800e53:	74 04                	je     800e59 <strncmp+0x2a>
  800e55:	3a 0a                	cmp    (%edx),%cl
  800e57:	74 eb                	je     800e44 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e59:	0f b6 00             	movzbl (%eax),%eax
  800e5c:	0f b6 12             	movzbl (%edx),%edx
  800e5f:	29 d0                	sub    %edx,%eax
}
  800e61:	5b                   	pop    %ebx
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    
		return 0;
  800e64:	b8 00 00 00 00       	mov    $0x0,%eax
  800e69:	eb f6                	jmp    800e61 <strncmp+0x32>

00800e6b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e6b:	f3 0f 1e fb          	endbr32 
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	8b 45 08             	mov    0x8(%ebp),%eax
  800e75:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e79:	0f b6 10             	movzbl (%eax),%edx
  800e7c:	84 d2                	test   %dl,%dl
  800e7e:	74 09                	je     800e89 <strchr+0x1e>
		if (*s == c)
  800e80:	38 ca                	cmp    %cl,%dl
  800e82:	74 0a                	je     800e8e <strchr+0x23>
	for (; *s; s++)
  800e84:	83 c0 01             	add    $0x1,%eax
  800e87:	eb f0                	jmp    800e79 <strchr+0xe>
			return (char *) s;
	return 0;
  800e89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e90:	f3 0f 1e fb          	endbr32 
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e9e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ea1:	38 ca                	cmp    %cl,%dl
  800ea3:	74 09                	je     800eae <strfind+0x1e>
  800ea5:	84 d2                	test   %dl,%dl
  800ea7:	74 05                	je     800eae <strfind+0x1e>
	for (; *s; s++)
  800ea9:	83 c0 01             	add    $0x1,%eax
  800eac:	eb f0                	jmp    800e9e <strfind+0xe>
			break;
	return (char *) s;
}
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eb0:	f3 0f 1e fb          	endbr32 
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	57                   	push   %edi
  800eb8:	56                   	push   %esi
  800eb9:	53                   	push   %ebx
  800eba:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800ec0:	85 c9                	test   %ecx,%ecx
  800ec2:	74 33                	je     800ef7 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ec4:	89 d0                	mov    %edx,%eax
  800ec6:	09 c8                	or     %ecx,%eax
  800ec8:	a8 03                	test   $0x3,%al
  800eca:	75 23                	jne    800eef <memset+0x3f>
		c &= 0xFF;
  800ecc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ed0:	89 d8                	mov    %ebx,%eax
  800ed2:	c1 e0 08             	shl    $0x8,%eax
  800ed5:	89 df                	mov    %ebx,%edi
  800ed7:	c1 e7 18             	shl    $0x18,%edi
  800eda:	89 de                	mov    %ebx,%esi
  800edc:	c1 e6 10             	shl    $0x10,%esi
  800edf:	09 f7                	or     %esi,%edi
  800ee1:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800ee3:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ee6:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800ee8:	89 d7                	mov    %edx,%edi
  800eea:	fc                   	cld    
  800eeb:	f3 ab                	rep stos %eax,%es:(%edi)
  800eed:	eb 08                	jmp    800ef7 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eef:	89 d7                	mov    %edx,%edi
  800ef1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef4:	fc                   	cld    
  800ef5:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800ef7:	89 d0                	mov    %edx,%eax
  800ef9:	5b                   	pop    %ebx
  800efa:	5e                   	pop    %esi
  800efb:	5f                   	pop    %edi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800efe:	f3 0f 1e fb          	endbr32 
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	57                   	push   %edi
  800f06:	56                   	push   %esi
  800f07:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f10:	39 c6                	cmp    %eax,%esi
  800f12:	73 32                	jae    800f46 <memmove+0x48>
  800f14:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f17:	39 c2                	cmp    %eax,%edx
  800f19:	76 2b                	jbe    800f46 <memmove+0x48>
		s += n;
		d += n;
  800f1b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f1e:	89 fe                	mov    %edi,%esi
  800f20:	09 ce                	or     %ecx,%esi
  800f22:	09 d6                	or     %edx,%esi
  800f24:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f2a:	75 0e                	jne    800f3a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f2c:	83 ef 04             	sub    $0x4,%edi
  800f2f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f32:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800f35:	fd                   	std    
  800f36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f38:	eb 09                	jmp    800f43 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f3a:	83 ef 01             	sub    $0x1,%edi
  800f3d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800f40:	fd                   	std    
  800f41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f43:	fc                   	cld    
  800f44:	eb 1a                	jmp    800f60 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f46:	89 c2                	mov    %eax,%edx
  800f48:	09 ca                	or     %ecx,%edx
  800f4a:	09 f2                	or     %esi,%edx
  800f4c:	f6 c2 03             	test   $0x3,%dl
  800f4f:	75 0a                	jne    800f5b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f51:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800f54:	89 c7                	mov    %eax,%edi
  800f56:	fc                   	cld    
  800f57:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f59:	eb 05                	jmp    800f60 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800f5b:	89 c7                	mov    %eax,%edi
  800f5d:	fc                   	cld    
  800f5e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f64:	f3 0f 1e fb          	endbr32 
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f6e:	ff 75 10             	pushl  0x10(%ebp)
  800f71:	ff 75 0c             	pushl  0xc(%ebp)
  800f74:	ff 75 08             	pushl  0x8(%ebp)
  800f77:	e8 82 ff ff ff       	call   800efe <memmove>
}
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f7e:	f3 0f 1e fb          	endbr32 
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	56                   	push   %esi
  800f86:	53                   	push   %ebx
  800f87:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8d:	89 c6                	mov    %eax,%esi
  800f8f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f92:	39 f0                	cmp    %esi,%eax
  800f94:	74 1c                	je     800fb2 <memcmp+0x34>
		if (*s1 != *s2)
  800f96:	0f b6 08             	movzbl (%eax),%ecx
  800f99:	0f b6 1a             	movzbl (%edx),%ebx
  800f9c:	38 d9                	cmp    %bl,%cl
  800f9e:	75 08                	jne    800fa8 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800fa0:	83 c0 01             	add    $0x1,%eax
  800fa3:	83 c2 01             	add    $0x1,%edx
  800fa6:	eb ea                	jmp    800f92 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800fa8:	0f b6 c1             	movzbl %cl,%eax
  800fab:	0f b6 db             	movzbl %bl,%ebx
  800fae:	29 d8                	sub    %ebx,%eax
  800fb0:	eb 05                	jmp    800fb7 <memcmp+0x39>
	}

	return 0;
  800fb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fb7:	5b                   	pop    %ebx
  800fb8:	5e                   	pop    %esi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    

00800fbb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fbb:	f3 0f 1e fb          	endbr32 
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800fc8:	89 c2                	mov    %eax,%edx
  800fca:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fcd:	39 d0                	cmp    %edx,%eax
  800fcf:	73 09                	jae    800fda <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fd1:	38 08                	cmp    %cl,(%eax)
  800fd3:	74 05                	je     800fda <memfind+0x1f>
	for (; s < ends; s++)
  800fd5:	83 c0 01             	add    $0x1,%eax
  800fd8:	eb f3                	jmp    800fcd <memfind+0x12>
			break;
	return (void *) s;
}
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fdc:	f3 0f 1e fb          	endbr32 
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	57                   	push   %edi
  800fe4:	56                   	push   %esi
  800fe5:	53                   	push   %ebx
  800fe6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fec:	eb 03                	jmp    800ff1 <strtol+0x15>
		s++;
  800fee:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ff1:	0f b6 01             	movzbl (%ecx),%eax
  800ff4:	3c 20                	cmp    $0x20,%al
  800ff6:	74 f6                	je     800fee <strtol+0x12>
  800ff8:	3c 09                	cmp    $0x9,%al
  800ffa:	74 f2                	je     800fee <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ffc:	3c 2b                	cmp    $0x2b,%al
  800ffe:	74 2a                	je     80102a <strtol+0x4e>
	int neg = 0;
  801000:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801005:	3c 2d                	cmp    $0x2d,%al
  801007:	74 2b                	je     801034 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801009:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80100f:	75 0f                	jne    801020 <strtol+0x44>
  801011:	80 39 30             	cmpb   $0x30,(%ecx)
  801014:	74 28                	je     80103e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801016:	85 db                	test   %ebx,%ebx
  801018:	b8 0a 00 00 00       	mov    $0xa,%eax
  80101d:	0f 44 d8             	cmove  %eax,%ebx
  801020:	b8 00 00 00 00       	mov    $0x0,%eax
  801025:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801028:	eb 46                	jmp    801070 <strtol+0x94>
		s++;
  80102a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80102d:	bf 00 00 00 00       	mov    $0x0,%edi
  801032:	eb d5                	jmp    801009 <strtol+0x2d>
		s++, neg = 1;
  801034:	83 c1 01             	add    $0x1,%ecx
  801037:	bf 01 00 00 00       	mov    $0x1,%edi
  80103c:	eb cb                	jmp    801009 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80103e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801042:	74 0e                	je     801052 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801044:	85 db                	test   %ebx,%ebx
  801046:	75 d8                	jne    801020 <strtol+0x44>
		s++, base = 8;
  801048:	83 c1 01             	add    $0x1,%ecx
  80104b:	bb 08 00 00 00       	mov    $0x8,%ebx
  801050:	eb ce                	jmp    801020 <strtol+0x44>
		s += 2, base = 16;
  801052:	83 c1 02             	add    $0x2,%ecx
  801055:	bb 10 00 00 00       	mov    $0x10,%ebx
  80105a:	eb c4                	jmp    801020 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80105c:	0f be d2             	movsbl %dl,%edx
  80105f:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801062:	3b 55 10             	cmp    0x10(%ebp),%edx
  801065:	7d 3a                	jge    8010a1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801067:	83 c1 01             	add    $0x1,%ecx
  80106a:	0f af 45 10          	imul   0x10(%ebp),%eax
  80106e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801070:	0f b6 11             	movzbl (%ecx),%edx
  801073:	8d 72 d0             	lea    -0x30(%edx),%esi
  801076:	89 f3                	mov    %esi,%ebx
  801078:	80 fb 09             	cmp    $0x9,%bl
  80107b:	76 df                	jbe    80105c <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  80107d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801080:	89 f3                	mov    %esi,%ebx
  801082:	80 fb 19             	cmp    $0x19,%bl
  801085:	77 08                	ja     80108f <strtol+0xb3>
			dig = *s - 'a' + 10;
  801087:	0f be d2             	movsbl %dl,%edx
  80108a:	83 ea 57             	sub    $0x57,%edx
  80108d:	eb d3                	jmp    801062 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  80108f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801092:	89 f3                	mov    %esi,%ebx
  801094:	80 fb 19             	cmp    $0x19,%bl
  801097:	77 08                	ja     8010a1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801099:	0f be d2             	movsbl %dl,%edx
  80109c:	83 ea 37             	sub    $0x37,%edx
  80109f:	eb c1                	jmp    801062 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  8010a1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010a5:	74 05                	je     8010ac <strtol+0xd0>
		*endptr = (char *) s;
  8010a7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010aa:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8010ac:	89 c2                	mov    %eax,%edx
  8010ae:	f7 da                	neg    %edx
  8010b0:	85 ff                	test   %edi,%edi
  8010b2:	0f 45 c2             	cmovne %edx,%eax
}
  8010b5:	5b                   	pop    %ebx
  8010b6:	5e                   	pop    %esi
  8010b7:	5f                   	pop    %edi
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    

008010ba <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	57                   	push   %edi
  8010be:	56                   	push   %esi
  8010bf:	53                   	push   %ebx
  8010c0:	83 ec 1c             	sub    $0x1c,%esp
  8010c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8010c9:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010d1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8010d4:	8b 75 14             	mov    0x14(%ebp),%esi
  8010d7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010dd:	74 04                	je     8010e3 <syscall+0x29>
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	7f 08                	jg     8010eb <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8010e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e6:	5b                   	pop    %ebx
  8010e7:	5e                   	pop    %esi
  8010e8:	5f                   	pop    %edi
  8010e9:	5d                   	pop    %ebp
  8010ea:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010eb:	83 ec 0c             	sub    $0xc,%esp
  8010ee:	50                   	push   %eax
  8010ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8010f2:	68 1f 2b 80 00       	push   $0x802b1f
  8010f7:	6a 23                	push   $0x23
  8010f9:	68 3c 2b 80 00       	push   $0x802b3c
  8010fe:	e8 f2 f5 ff ff       	call   8006f5 <_panic>

00801103 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  801103:	f3 0f 1e fb          	endbr32 
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80110d:	6a 00                	push   $0x0
  80110f:	6a 00                	push   $0x0
  801111:	6a 00                	push   $0x0
  801113:	ff 75 0c             	pushl  0xc(%ebp)
  801116:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801119:	ba 00 00 00 00       	mov    $0x0,%edx
  80111e:	b8 00 00 00 00       	mov    $0x0,%eax
  801123:	e8 92 ff ff ff       	call   8010ba <syscall>
}
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	c9                   	leave  
  80112c:	c3                   	ret    

0080112d <sys_cgetc>:

int
sys_cgetc(void)
{
  80112d:	f3 0f 1e fb          	endbr32 
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801137:	6a 00                	push   $0x0
  801139:	6a 00                	push   $0x0
  80113b:	6a 00                	push   $0x0
  80113d:	6a 00                	push   $0x0
  80113f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801144:	ba 00 00 00 00       	mov    $0x0,%edx
  801149:	b8 01 00 00 00       	mov    $0x1,%eax
  80114e:	e8 67 ff ff ff       	call   8010ba <syscall>
}
  801153:	c9                   	leave  
  801154:	c3                   	ret    

00801155 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801155:	f3 0f 1e fb          	endbr32 
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80115f:	6a 00                	push   $0x0
  801161:	6a 00                	push   $0x0
  801163:	6a 00                	push   $0x0
  801165:	6a 00                	push   $0x0
  801167:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116a:	ba 01 00 00 00       	mov    $0x1,%edx
  80116f:	b8 03 00 00 00       	mov    $0x3,%eax
  801174:	e8 41 ff ff ff       	call   8010ba <syscall>
}
  801179:	c9                   	leave  
  80117a:	c3                   	ret    

0080117b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80117b:	f3 0f 1e fb          	endbr32 
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801185:	6a 00                	push   $0x0
  801187:	6a 00                	push   $0x0
  801189:	6a 00                	push   $0x0
  80118b:	6a 00                	push   $0x0
  80118d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801192:	ba 00 00 00 00       	mov    $0x0,%edx
  801197:	b8 02 00 00 00       	mov    $0x2,%eax
  80119c:	e8 19 ff ff ff       	call   8010ba <syscall>
}
  8011a1:	c9                   	leave  
  8011a2:	c3                   	ret    

008011a3 <sys_yield>:

void
sys_yield(void)
{
  8011a3:	f3 0f 1e fb          	endbr32 
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8011ad:	6a 00                	push   $0x0
  8011af:	6a 00                	push   $0x0
  8011b1:	6a 00                	push   $0x0
  8011b3:	6a 00                	push   $0x0
  8011b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8011bf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011c4:	e8 f1 fe ff ff       	call   8010ba <syscall>
}
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	c9                   	leave  
  8011cd:	c3                   	ret    

008011ce <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011ce:	f3 0f 1e fb          	endbr32 
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8011d8:	6a 00                	push   $0x0
  8011da:	6a 00                	push   $0x0
  8011dc:	ff 75 10             	pushl  0x10(%ebp)
  8011df:	ff 75 0c             	pushl  0xc(%ebp)
  8011e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e5:	ba 01 00 00 00       	mov    $0x1,%edx
  8011ea:	b8 04 00 00 00       	mov    $0x4,%eax
  8011ef:	e8 c6 fe ff ff       	call   8010ba <syscall>
}
  8011f4:	c9                   	leave  
  8011f5:	c3                   	ret    

008011f6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011f6:	f3 0f 1e fb          	endbr32 
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801200:	ff 75 18             	pushl  0x18(%ebp)
  801203:	ff 75 14             	pushl  0x14(%ebp)
  801206:	ff 75 10             	pushl  0x10(%ebp)
  801209:	ff 75 0c             	pushl  0xc(%ebp)
  80120c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120f:	ba 01 00 00 00       	mov    $0x1,%edx
  801214:	b8 05 00 00 00       	mov    $0x5,%eax
  801219:	e8 9c fe ff ff       	call   8010ba <syscall>
}
  80121e:	c9                   	leave  
  80121f:	c3                   	ret    

00801220 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801220:	f3 0f 1e fb          	endbr32 
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80122a:	6a 00                	push   $0x0
  80122c:	6a 00                	push   $0x0
  80122e:	6a 00                	push   $0x0
  801230:	ff 75 0c             	pushl  0xc(%ebp)
  801233:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801236:	ba 01 00 00 00       	mov    $0x1,%edx
  80123b:	b8 06 00 00 00       	mov    $0x6,%eax
  801240:	e8 75 fe ff ff       	call   8010ba <syscall>
}
  801245:	c9                   	leave  
  801246:	c3                   	ret    

00801247 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801247:	f3 0f 1e fb          	endbr32 
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801251:	6a 00                	push   $0x0
  801253:	6a 00                	push   $0x0
  801255:	6a 00                	push   $0x0
  801257:	ff 75 0c             	pushl  0xc(%ebp)
  80125a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80125d:	ba 01 00 00 00       	mov    $0x1,%edx
  801262:	b8 08 00 00 00       	mov    $0x8,%eax
  801267:	e8 4e fe ff ff       	call   8010ba <syscall>
}
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80126e:	f3 0f 1e fb          	endbr32 
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  801278:	6a 00                	push   $0x0
  80127a:	6a 00                	push   $0x0
  80127c:	6a 00                	push   $0x0
  80127e:	ff 75 0c             	pushl  0xc(%ebp)
  801281:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801284:	ba 01 00 00 00       	mov    $0x1,%edx
  801289:	b8 09 00 00 00       	mov    $0x9,%eax
  80128e:	e8 27 fe ff ff       	call   8010ba <syscall>
}
  801293:	c9                   	leave  
  801294:	c3                   	ret    

00801295 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801295:	f3 0f 1e fb          	endbr32 
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80129f:	6a 00                	push   $0x0
  8012a1:	6a 00                	push   $0x0
  8012a3:	6a 00                	push   $0x0
  8012a5:	ff 75 0c             	pushl  0xc(%ebp)
  8012a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ab:	ba 01 00 00 00       	mov    $0x1,%edx
  8012b0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012b5:	e8 00 fe ff ff       	call   8010ba <syscall>
}
  8012ba:	c9                   	leave  
  8012bb:	c3                   	ret    

008012bc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012bc:	f3 0f 1e fb          	endbr32 
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8012c6:	6a 00                	push   $0x0
  8012c8:	ff 75 14             	pushl  0x14(%ebp)
  8012cb:	ff 75 10             	pushl  0x10(%ebp)
  8012ce:	ff 75 0c             	pushl  0xc(%ebp)
  8012d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012de:	e8 d7 fd ff ff       	call   8010ba <syscall>
}
  8012e3:	c9                   	leave  
  8012e4:	c3                   	ret    

008012e5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012e5:	f3 0f 1e fb          	endbr32 
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8012ef:	6a 00                	push   $0x0
  8012f1:	6a 00                	push   $0x0
  8012f3:	6a 00                	push   $0x0
  8012f5:	6a 00                	push   $0x0
  8012f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012fa:	ba 01 00 00 00       	mov    $0x1,%edx
  8012ff:	b8 0d 00 00 00       	mov    $0xd,%eax
  801304:	e8 b1 fd ff ff       	call   8010ba <syscall>
}
  801309:	c9                   	leave  
  80130a:	c3                   	ret    

0080130b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80130b:	f3 0f 1e fb          	endbr32 
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	56                   	push   %esi
  801313:	53                   	push   %ebx
  801314:	8b 75 08             	mov    0x8(%ebp),%esi
  801317:	8b 45 0c             	mov    0xc(%ebp),%eax
  80131a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	if (pg == NULL) {
		pg = (void *) -1;
  80131d:	85 c0                	test   %eax,%eax
  80131f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801324:	0f 44 c2             	cmove  %edx,%eax
	}

	int f = sys_ipc_recv(pg);
  801327:	83 ec 0c             	sub    $0xc,%esp
  80132a:	50                   	push   %eax
  80132b:	e8 b5 ff ff ff       	call   8012e5 <sys_ipc_recv>
	if (f < 0) {
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	78 2b                	js     801362 <ipc_recv+0x57>
			*perm_store = 0;
		}
		return f;
	}

	if (from_env_store != NULL) {
  801337:	85 f6                	test   %esi,%esi
  801339:	74 0a                	je     801345 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  80133b:	a1 04 40 80 00       	mov    0x804004,%eax
  801340:	8b 40 74             	mov    0x74(%eax),%eax
  801343:	89 06                	mov    %eax,(%esi)
	}
	if (perm_store != NULL) {
  801345:	85 db                	test   %ebx,%ebx
  801347:	74 0a                	je     801353 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  801349:	a1 04 40 80 00       	mov    0x804004,%eax
  80134e:	8b 40 78             	mov    0x78(%eax),%eax
  801351:	89 03                	mov    %eax,(%ebx)
	}

	return thisenv->env_ipc_value;
  801353:	a1 04 40 80 00       	mov    0x804004,%eax
  801358:	8b 40 70             	mov    0x70(%eax),%eax
}
  80135b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135e:	5b                   	pop    %ebx
  80135f:	5e                   	pop    %esi
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    
		if (from_env_store != NULL) {
  801362:	85 f6                	test   %esi,%esi
  801364:	74 06                	je     80136c <ipc_recv+0x61>
			*from_env_store = 0;
  801366:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  80136c:	85 db                	test   %ebx,%ebx
  80136e:	74 eb                	je     80135b <ipc_recv+0x50>
			*perm_store = 0;
  801370:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801376:	eb e3                	jmp    80135b <ipc_recv+0x50>

00801378 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801378:	f3 0f 1e fb          	endbr32 
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	57                   	push   %edi
  801380:	56                   	push   %esi
  801381:	53                   	push   %ebx
  801382:	83 ec 0c             	sub    $0xc,%esp
  801385:	8b 7d 08             	mov    0x8(%ebp),%edi
  801388:	8b 75 0c             	mov    0xc(%ebp),%esi
  80138b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) -1;
  80138e:	85 db                	test   %ebx,%ebx
  801390:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801395:	0f 44 d8             	cmove  %eax,%ebx
	}

	int f;

	while ((f = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801398:	ff 75 14             	pushl  0x14(%ebp)
  80139b:	53                   	push   %ebx
  80139c:	56                   	push   %esi
  80139d:	57                   	push   %edi
  80139e:	e8 19 ff ff ff       	call   8012bc <sys_ipc_try_send>
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	79 19                	jns    8013c3 <ipc_send+0x4b>
		if (f != -E_IPC_NOT_RECV) {
  8013aa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013ad:	74 e9                	je     801398 <ipc_send+0x20>
			panic("ipc_send: sys_ipc_try_send failed");
  8013af:	83 ec 04             	sub    $0x4,%esp
  8013b2:	68 4c 2b 80 00       	push   $0x802b4c
  8013b7:	6a 48                	push   $0x48
  8013b9:	68 6e 2b 80 00       	push   $0x802b6e
  8013be:	e8 32 f3 ff ff       	call   8006f5 <_panic>
		}
	}
}
  8013c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c6:	5b                   	pop    %ebx
  8013c7:	5e                   	pop    %esi
  8013c8:	5f                   	pop    %edi
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    

008013cb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013cb:	f3 0f 1e fb          	endbr32 
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013d5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013da:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013dd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013e3:	8b 52 50             	mov    0x50(%edx),%edx
  8013e6:	39 ca                	cmp    %ecx,%edx
  8013e8:	74 11                	je     8013fb <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8013ea:	83 c0 01             	add    $0x1,%eax
  8013ed:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013f2:	75 e6                	jne    8013da <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8013f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f9:	eb 0b                	jmp    801406 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8013fb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013fe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801403:	8b 40 48             	mov    0x48(%eax),%eax
}
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    

00801408 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801408:	f3 0f 1e fb          	endbr32 
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80140f:	8b 45 08             	mov    0x8(%ebp),%eax
  801412:	05 00 00 00 30       	add    $0x30000000,%eax
  801417:	c1 e8 0c             	shr    $0xc,%eax
}
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80141c:	f3 0f 1e fb          	endbr32 
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  801426:	ff 75 08             	pushl  0x8(%ebp)
  801429:	e8 da ff ff ff       	call   801408 <fd2num>
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	c1 e0 0c             	shl    $0xc,%eax
  801434:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801439:	c9                   	leave  
  80143a:	c3                   	ret    

0080143b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80143b:	f3 0f 1e fb          	endbr32 
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801447:	89 c2                	mov    %eax,%edx
  801449:	c1 ea 16             	shr    $0x16,%edx
  80144c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801453:	f6 c2 01             	test   $0x1,%dl
  801456:	74 2d                	je     801485 <fd_alloc+0x4a>
  801458:	89 c2                	mov    %eax,%edx
  80145a:	c1 ea 0c             	shr    $0xc,%edx
  80145d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801464:	f6 c2 01             	test   $0x1,%dl
  801467:	74 1c                	je     801485 <fd_alloc+0x4a>
  801469:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80146e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801473:	75 d2                	jne    801447 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801475:	8b 45 08             	mov    0x8(%ebp),%eax
  801478:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80147e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801483:	eb 0a                	jmp    80148f <fd_alloc+0x54>
			*fd_store = fd;
  801485:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801488:	89 01                	mov    %eax,(%ecx)
			return 0;
  80148a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80148f:	5d                   	pop    %ebp
  801490:	c3                   	ret    

00801491 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801491:	f3 0f 1e fb          	endbr32 
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80149b:	83 f8 1f             	cmp    $0x1f,%eax
  80149e:	77 30                	ja     8014d0 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014a0:	c1 e0 0c             	shl    $0xc,%eax
  8014a3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014a8:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8014ae:	f6 c2 01             	test   $0x1,%dl
  8014b1:	74 24                	je     8014d7 <fd_lookup+0x46>
  8014b3:	89 c2                	mov    %eax,%edx
  8014b5:	c1 ea 0c             	shr    $0xc,%edx
  8014b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014bf:	f6 c2 01             	test   $0x1,%dl
  8014c2:	74 1a                	je     8014de <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014c7:	89 02                	mov    %eax,(%edx)
	return 0;
  8014c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    
		return -E_INVAL;
  8014d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d5:	eb f7                	jmp    8014ce <fd_lookup+0x3d>
		return -E_INVAL;
  8014d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014dc:	eb f0                	jmp    8014ce <fd_lookup+0x3d>
  8014de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014e3:	eb e9                	jmp    8014ce <fd_lookup+0x3d>

008014e5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014e5:	f3 0f 1e fb          	endbr32 
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	83 ec 08             	sub    $0x8,%esp
  8014ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014f2:	ba f4 2b 80 00       	mov    $0x802bf4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014f7:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
  8014fc:	39 08                	cmp    %ecx,(%eax)
  8014fe:	74 33                	je     801533 <dev_lookup+0x4e>
  801500:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801503:	8b 02                	mov    (%edx),%eax
  801505:	85 c0                	test   %eax,%eax
  801507:	75 f3                	jne    8014fc <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801509:	a1 04 40 80 00       	mov    0x804004,%eax
  80150e:	8b 40 48             	mov    0x48(%eax),%eax
  801511:	83 ec 04             	sub    $0x4,%esp
  801514:	51                   	push   %ecx
  801515:	50                   	push   %eax
  801516:	68 78 2b 80 00       	push   $0x802b78
  80151b:	e8 bc f2 ff ff       	call   8007dc <cprintf>
	*dev = 0;
  801520:	8b 45 0c             	mov    0xc(%ebp),%eax
  801523:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801531:	c9                   	leave  
  801532:	c3                   	ret    
			*dev = devtab[i];
  801533:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801536:	89 01                	mov    %eax,(%ecx)
			return 0;
  801538:	b8 00 00 00 00       	mov    $0x0,%eax
  80153d:	eb f2                	jmp    801531 <dev_lookup+0x4c>

0080153f <fd_close>:
{
  80153f:	f3 0f 1e fb          	endbr32 
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	57                   	push   %edi
  801547:	56                   	push   %esi
  801548:	53                   	push   %ebx
  801549:	83 ec 28             	sub    $0x28,%esp
  80154c:	8b 75 08             	mov    0x8(%ebp),%esi
  80154f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801552:	56                   	push   %esi
  801553:	e8 b0 fe ff ff       	call   801408 <fd2num>
  801558:	83 c4 08             	add    $0x8,%esp
  80155b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80155e:	52                   	push   %edx
  80155f:	50                   	push   %eax
  801560:	e8 2c ff ff ff       	call   801491 <fd_lookup>
  801565:	89 c3                	mov    %eax,%ebx
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 05                	js     801573 <fd_close+0x34>
	    || fd != fd2)
  80156e:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801571:	74 16                	je     801589 <fd_close+0x4a>
		return (must_exist ? r : 0);
  801573:	89 f8                	mov    %edi,%eax
  801575:	84 c0                	test   %al,%al
  801577:	b8 00 00 00 00       	mov    $0x0,%eax
  80157c:	0f 44 d8             	cmove  %eax,%ebx
}
  80157f:	89 d8                	mov    %ebx,%eax
  801581:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801584:	5b                   	pop    %ebx
  801585:	5e                   	pop    %esi
  801586:	5f                   	pop    %edi
  801587:	5d                   	pop    %ebp
  801588:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80158f:	50                   	push   %eax
  801590:	ff 36                	pushl  (%esi)
  801592:	e8 4e ff ff ff       	call   8014e5 <dev_lookup>
  801597:	89 c3                	mov    %eax,%ebx
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	85 c0                	test   %eax,%eax
  80159e:	78 1a                	js     8015ba <fd_close+0x7b>
		if (dev->dev_close)
  8015a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015a3:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8015a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	74 0b                	je     8015ba <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8015af:	83 ec 0c             	sub    $0xc,%esp
  8015b2:	56                   	push   %esi
  8015b3:	ff d0                	call   *%eax
  8015b5:	89 c3                	mov    %eax,%ebx
  8015b7:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8015ba:	83 ec 08             	sub    $0x8,%esp
  8015bd:	56                   	push   %esi
  8015be:	6a 00                	push   $0x0
  8015c0:	e8 5b fc ff ff       	call   801220 <sys_page_unmap>
	return r;
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	eb b5                	jmp    80157f <fd_close+0x40>

008015ca <close>:

int
close(int fdnum)
{
  8015ca:	f3 0f 1e fb          	endbr32 
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d7:	50                   	push   %eax
  8015d8:	ff 75 08             	pushl  0x8(%ebp)
  8015db:	e8 b1 fe ff ff       	call   801491 <fd_lookup>
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	79 02                	jns    8015e9 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8015e7:	c9                   	leave  
  8015e8:	c3                   	ret    
		return fd_close(fd, 1);
  8015e9:	83 ec 08             	sub    $0x8,%esp
  8015ec:	6a 01                	push   $0x1
  8015ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f1:	e8 49 ff ff ff       	call   80153f <fd_close>
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	eb ec                	jmp    8015e7 <close+0x1d>

008015fb <close_all>:

void
close_all(void)
{
  8015fb:	f3 0f 1e fb          	endbr32 
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	53                   	push   %ebx
  801603:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801606:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80160b:	83 ec 0c             	sub    $0xc,%esp
  80160e:	53                   	push   %ebx
  80160f:	e8 b6 ff ff ff       	call   8015ca <close>
	for (i = 0; i < MAXFD; i++)
  801614:	83 c3 01             	add    $0x1,%ebx
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	83 fb 20             	cmp    $0x20,%ebx
  80161d:	75 ec                	jne    80160b <close_all+0x10>
}
  80161f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801622:	c9                   	leave  
  801623:	c3                   	ret    

00801624 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801624:	f3 0f 1e fb          	endbr32 
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	57                   	push   %edi
  80162c:	56                   	push   %esi
  80162d:	53                   	push   %ebx
  80162e:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801631:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801634:	50                   	push   %eax
  801635:	ff 75 08             	pushl  0x8(%ebp)
  801638:	e8 54 fe ff ff       	call   801491 <fd_lookup>
  80163d:	89 c3                	mov    %eax,%ebx
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	85 c0                	test   %eax,%eax
  801644:	0f 88 81 00 00 00    	js     8016cb <dup+0xa7>
		return r;
	close(newfdnum);
  80164a:	83 ec 0c             	sub    $0xc,%esp
  80164d:	ff 75 0c             	pushl  0xc(%ebp)
  801650:	e8 75 ff ff ff       	call   8015ca <close>

	newfd = INDEX2FD(newfdnum);
  801655:	8b 75 0c             	mov    0xc(%ebp),%esi
  801658:	c1 e6 0c             	shl    $0xc,%esi
  80165b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801661:	83 c4 04             	add    $0x4,%esp
  801664:	ff 75 e4             	pushl  -0x1c(%ebp)
  801667:	e8 b0 fd ff ff       	call   80141c <fd2data>
  80166c:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80166e:	89 34 24             	mov    %esi,(%esp)
  801671:	e8 a6 fd ff ff       	call   80141c <fd2data>
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80167b:	89 d8                	mov    %ebx,%eax
  80167d:	c1 e8 16             	shr    $0x16,%eax
  801680:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801687:	a8 01                	test   $0x1,%al
  801689:	74 11                	je     80169c <dup+0x78>
  80168b:	89 d8                	mov    %ebx,%eax
  80168d:	c1 e8 0c             	shr    $0xc,%eax
  801690:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801697:	f6 c2 01             	test   $0x1,%dl
  80169a:	75 39                	jne    8016d5 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80169c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80169f:	89 d0                	mov    %edx,%eax
  8016a1:	c1 e8 0c             	shr    $0xc,%eax
  8016a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016ab:	83 ec 0c             	sub    $0xc,%esp
  8016ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8016b3:	50                   	push   %eax
  8016b4:	56                   	push   %esi
  8016b5:	6a 00                	push   $0x0
  8016b7:	52                   	push   %edx
  8016b8:	6a 00                	push   $0x0
  8016ba:	e8 37 fb ff ff       	call   8011f6 <sys_page_map>
  8016bf:	89 c3                	mov    %eax,%ebx
  8016c1:	83 c4 20             	add    $0x20,%esp
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 31                	js     8016f9 <dup+0xd5>
		goto err;

	return newfdnum;
  8016c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016cb:	89 d8                	mov    %ebx,%eax
  8016cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d0:	5b                   	pop    %ebx
  8016d1:	5e                   	pop    %esi
  8016d2:	5f                   	pop    %edi
  8016d3:	5d                   	pop    %ebp
  8016d4:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016dc:	83 ec 0c             	sub    $0xc,%esp
  8016df:	25 07 0e 00 00       	and    $0xe07,%eax
  8016e4:	50                   	push   %eax
  8016e5:	57                   	push   %edi
  8016e6:	6a 00                	push   $0x0
  8016e8:	53                   	push   %ebx
  8016e9:	6a 00                	push   $0x0
  8016eb:	e8 06 fb ff ff       	call   8011f6 <sys_page_map>
  8016f0:	89 c3                	mov    %eax,%ebx
  8016f2:	83 c4 20             	add    $0x20,%esp
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	79 a3                	jns    80169c <dup+0x78>
	sys_page_unmap(0, newfd);
  8016f9:	83 ec 08             	sub    $0x8,%esp
  8016fc:	56                   	push   %esi
  8016fd:	6a 00                	push   $0x0
  8016ff:	e8 1c fb ff ff       	call   801220 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801704:	83 c4 08             	add    $0x8,%esp
  801707:	57                   	push   %edi
  801708:	6a 00                	push   $0x0
  80170a:	e8 11 fb ff ff       	call   801220 <sys_page_unmap>
	return r;
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	eb b7                	jmp    8016cb <dup+0xa7>

00801714 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801714:	f3 0f 1e fb          	endbr32 
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	53                   	push   %ebx
  80171c:	83 ec 1c             	sub    $0x1c,%esp
  80171f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801722:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801725:	50                   	push   %eax
  801726:	53                   	push   %ebx
  801727:	e8 65 fd ff ff       	call   801491 <fd_lookup>
  80172c:	83 c4 10             	add    $0x10,%esp
  80172f:	85 c0                	test   %eax,%eax
  801731:	78 3f                	js     801772 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801733:	83 ec 08             	sub    $0x8,%esp
  801736:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801739:	50                   	push   %eax
  80173a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173d:	ff 30                	pushl  (%eax)
  80173f:	e8 a1 fd ff ff       	call   8014e5 <dev_lookup>
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	85 c0                	test   %eax,%eax
  801749:	78 27                	js     801772 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80174b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80174e:	8b 42 08             	mov    0x8(%edx),%eax
  801751:	83 e0 03             	and    $0x3,%eax
  801754:	83 f8 01             	cmp    $0x1,%eax
  801757:	74 1e                	je     801777 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801759:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175c:	8b 40 08             	mov    0x8(%eax),%eax
  80175f:	85 c0                	test   %eax,%eax
  801761:	74 35                	je     801798 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801763:	83 ec 04             	sub    $0x4,%esp
  801766:	ff 75 10             	pushl  0x10(%ebp)
  801769:	ff 75 0c             	pushl  0xc(%ebp)
  80176c:	52                   	push   %edx
  80176d:	ff d0                	call   *%eax
  80176f:	83 c4 10             	add    $0x10,%esp
}
  801772:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801775:	c9                   	leave  
  801776:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801777:	a1 04 40 80 00       	mov    0x804004,%eax
  80177c:	8b 40 48             	mov    0x48(%eax),%eax
  80177f:	83 ec 04             	sub    $0x4,%esp
  801782:	53                   	push   %ebx
  801783:	50                   	push   %eax
  801784:	68 b9 2b 80 00       	push   $0x802bb9
  801789:	e8 4e f0 ff ff       	call   8007dc <cprintf>
		return -E_INVAL;
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801796:	eb da                	jmp    801772 <read+0x5e>
		return -E_NOT_SUPP;
  801798:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80179d:	eb d3                	jmp    801772 <read+0x5e>

0080179f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80179f:	f3 0f 1e fb          	endbr32 
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	57                   	push   %edi
  8017a7:	56                   	push   %esi
  8017a8:	53                   	push   %ebx
  8017a9:	83 ec 0c             	sub    $0xc,%esp
  8017ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017af:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b7:	eb 02                	jmp    8017bb <readn+0x1c>
  8017b9:	01 c3                	add    %eax,%ebx
  8017bb:	39 f3                	cmp    %esi,%ebx
  8017bd:	73 21                	jae    8017e0 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017bf:	83 ec 04             	sub    $0x4,%esp
  8017c2:	89 f0                	mov    %esi,%eax
  8017c4:	29 d8                	sub    %ebx,%eax
  8017c6:	50                   	push   %eax
  8017c7:	89 d8                	mov    %ebx,%eax
  8017c9:	03 45 0c             	add    0xc(%ebp),%eax
  8017cc:	50                   	push   %eax
  8017cd:	57                   	push   %edi
  8017ce:	e8 41 ff ff ff       	call   801714 <read>
		if (m < 0)
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	78 04                	js     8017de <readn+0x3f>
			return m;
		if (m == 0)
  8017da:	75 dd                	jne    8017b9 <readn+0x1a>
  8017dc:	eb 02                	jmp    8017e0 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017de:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8017e0:	89 d8                	mov    %ebx,%eax
  8017e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	5f                   	pop    %edi
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017ea:	f3 0f 1e fb          	endbr32 
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	53                   	push   %ebx
  8017f2:	83 ec 1c             	sub    $0x1c,%esp
  8017f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017fb:	50                   	push   %eax
  8017fc:	53                   	push   %ebx
  8017fd:	e8 8f fc ff ff       	call   801491 <fd_lookup>
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	85 c0                	test   %eax,%eax
  801807:	78 3a                	js     801843 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801809:	83 ec 08             	sub    $0x8,%esp
  80180c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180f:	50                   	push   %eax
  801810:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801813:	ff 30                	pushl  (%eax)
  801815:	e8 cb fc ff ff       	call   8014e5 <dev_lookup>
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	85 c0                	test   %eax,%eax
  80181f:	78 22                	js     801843 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801821:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801824:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801828:	74 1e                	je     801848 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80182a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182d:	8b 52 0c             	mov    0xc(%edx),%edx
  801830:	85 d2                	test   %edx,%edx
  801832:	74 35                	je     801869 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801834:	83 ec 04             	sub    $0x4,%esp
  801837:	ff 75 10             	pushl  0x10(%ebp)
  80183a:	ff 75 0c             	pushl  0xc(%ebp)
  80183d:	50                   	push   %eax
  80183e:	ff d2                	call   *%edx
  801840:	83 c4 10             	add    $0x10,%esp
}
  801843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801846:	c9                   	leave  
  801847:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801848:	a1 04 40 80 00       	mov    0x804004,%eax
  80184d:	8b 40 48             	mov    0x48(%eax),%eax
  801850:	83 ec 04             	sub    $0x4,%esp
  801853:	53                   	push   %ebx
  801854:	50                   	push   %eax
  801855:	68 d5 2b 80 00       	push   $0x802bd5
  80185a:	e8 7d ef ff ff       	call   8007dc <cprintf>
		return -E_INVAL;
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801867:	eb da                	jmp    801843 <write+0x59>
		return -E_NOT_SUPP;
  801869:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80186e:	eb d3                	jmp    801843 <write+0x59>

00801870 <seek>:

int
seek(int fdnum, off_t offset)
{
  801870:	f3 0f 1e fb          	endbr32 
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80187a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187d:	50                   	push   %eax
  80187e:	ff 75 08             	pushl  0x8(%ebp)
  801881:	e8 0b fc ff ff       	call   801491 <fd_lookup>
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	85 c0                	test   %eax,%eax
  80188b:	78 0e                	js     80189b <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80188d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801890:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801893:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801896:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80189b:	c9                   	leave  
  80189c:	c3                   	ret    

0080189d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80189d:	f3 0f 1e fb          	endbr32 
  8018a1:	55                   	push   %ebp
  8018a2:	89 e5                	mov    %esp,%ebp
  8018a4:	53                   	push   %ebx
  8018a5:	83 ec 1c             	sub    $0x1c,%esp
  8018a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ae:	50                   	push   %eax
  8018af:	53                   	push   %ebx
  8018b0:	e8 dc fb ff ff       	call   801491 <fd_lookup>
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	78 37                	js     8018f3 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018bc:	83 ec 08             	sub    $0x8,%esp
  8018bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c2:	50                   	push   %eax
  8018c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c6:	ff 30                	pushl  (%eax)
  8018c8:	e8 18 fc ff ff       	call   8014e5 <dev_lookup>
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	78 1f                	js     8018f3 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018db:	74 1b                	je     8018f8 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8018dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e0:	8b 52 18             	mov    0x18(%edx),%edx
  8018e3:	85 d2                	test   %edx,%edx
  8018e5:	74 32                	je     801919 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018e7:	83 ec 08             	sub    $0x8,%esp
  8018ea:	ff 75 0c             	pushl  0xc(%ebp)
  8018ed:	50                   	push   %eax
  8018ee:	ff d2                	call   *%edx
  8018f0:	83 c4 10             	add    $0x10,%esp
}
  8018f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f6:	c9                   	leave  
  8018f7:	c3                   	ret    
			thisenv->env_id, fdnum);
  8018f8:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018fd:	8b 40 48             	mov    0x48(%eax),%eax
  801900:	83 ec 04             	sub    $0x4,%esp
  801903:	53                   	push   %ebx
  801904:	50                   	push   %eax
  801905:	68 98 2b 80 00       	push   $0x802b98
  80190a:	e8 cd ee ff ff       	call   8007dc <cprintf>
		return -E_INVAL;
  80190f:	83 c4 10             	add    $0x10,%esp
  801912:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801917:	eb da                	jmp    8018f3 <ftruncate+0x56>
		return -E_NOT_SUPP;
  801919:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80191e:	eb d3                	jmp    8018f3 <ftruncate+0x56>

00801920 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801920:	f3 0f 1e fb          	endbr32 
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	53                   	push   %ebx
  801928:	83 ec 1c             	sub    $0x1c,%esp
  80192b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80192e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801931:	50                   	push   %eax
  801932:	ff 75 08             	pushl  0x8(%ebp)
  801935:	e8 57 fb ff ff       	call   801491 <fd_lookup>
  80193a:	83 c4 10             	add    $0x10,%esp
  80193d:	85 c0                	test   %eax,%eax
  80193f:	78 4b                	js     80198c <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801941:	83 ec 08             	sub    $0x8,%esp
  801944:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801947:	50                   	push   %eax
  801948:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194b:	ff 30                	pushl  (%eax)
  80194d:	e8 93 fb ff ff       	call   8014e5 <dev_lookup>
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	85 c0                	test   %eax,%eax
  801957:	78 33                	js     80198c <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801959:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801960:	74 2f                	je     801991 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801962:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801965:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80196c:	00 00 00 
	stat->st_isdir = 0;
  80196f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801976:	00 00 00 
	stat->st_dev = dev;
  801979:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80197f:	83 ec 08             	sub    $0x8,%esp
  801982:	53                   	push   %ebx
  801983:	ff 75 f0             	pushl  -0x10(%ebp)
  801986:	ff 50 14             	call   *0x14(%eax)
  801989:	83 c4 10             	add    $0x10,%esp
}
  80198c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198f:	c9                   	leave  
  801990:	c3                   	ret    
		return -E_NOT_SUPP;
  801991:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801996:	eb f4                	jmp    80198c <fstat+0x6c>

00801998 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801998:	f3 0f 1e fb          	endbr32 
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	56                   	push   %esi
  8019a0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019a1:	83 ec 08             	sub    $0x8,%esp
  8019a4:	6a 00                	push   $0x0
  8019a6:	ff 75 08             	pushl  0x8(%ebp)
  8019a9:	e8 20 02 00 00       	call   801bce <open>
  8019ae:	89 c3                	mov    %eax,%ebx
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	78 1b                	js     8019d2 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8019b7:	83 ec 08             	sub    $0x8,%esp
  8019ba:	ff 75 0c             	pushl  0xc(%ebp)
  8019bd:	50                   	push   %eax
  8019be:	e8 5d ff ff ff       	call   801920 <fstat>
  8019c3:	89 c6                	mov    %eax,%esi
	close(fd);
  8019c5:	89 1c 24             	mov    %ebx,(%esp)
  8019c8:	e8 fd fb ff ff       	call   8015ca <close>
	return r;
  8019cd:	83 c4 10             	add    $0x10,%esp
  8019d0:	89 f3                	mov    %esi,%ebx
}
  8019d2:	89 d8                	mov    %ebx,%eax
  8019d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d7:	5b                   	pop    %ebx
  8019d8:	5e                   	pop    %esi
  8019d9:	5d                   	pop    %ebp
  8019da:	c3                   	ret    

008019db <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	56                   	push   %esi
  8019df:	53                   	push   %ebx
  8019e0:	89 c6                	mov    %eax,%esi
  8019e2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019e4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019eb:	74 27                	je     801a14 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019ed:	6a 07                	push   $0x7
  8019ef:	68 00 50 80 00       	push   $0x805000
  8019f4:	56                   	push   %esi
  8019f5:	ff 35 00 40 80 00    	pushl  0x804000
  8019fb:	e8 78 f9 ff ff       	call   801378 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a00:	83 c4 0c             	add    $0xc,%esp
  801a03:	6a 00                	push   $0x0
  801a05:	53                   	push   %ebx
  801a06:	6a 00                	push   $0x0
  801a08:	e8 fe f8 ff ff       	call   80130b <ipc_recv>
}
  801a0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a10:	5b                   	pop    %ebx
  801a11:	5e                   	pop    %esi
  801a12:	5d                   	pop    %ebp
  801a13:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a14:	83 ec 0c             	sub    $0xc,%esp
  801a17:	6a 01                	push   $0x1
  801a19:	e8 ad f9 ff ff       	call   8013cb <ipc_find_env>
  801a1e:	a3 00 40 80 00       	mov    %eax,0x804000
  801a23:	83 c4 10             	add    $0x10,%esp
  801a26:	eb c5                	jmp    8019ed <fsipc+0x12>

00801a28 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a28:	f3 0f 1e fb          	endbr32 
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a32:	8b 45 08             	mov    0x8(%ebp),%eax
  801a35:	8b 40 0c             	mov    0xc(%eax),%eax
  801a38:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a40:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a45:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4a:	b8 02 00 00 00       	mov    $0x2,%eax
  801a4f:	e8 87 ff ff ff       	call   8019db <fsipc>
}
  801a54:	c9                   	leave  
  801a55:	c3                   	ret    

00801a56 <devfile_flush>:
{
  801a56:	f3 0f 1e fb          	endbr32 
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a60:	8b 45 08             	mov    0x8(%ebp),%eax
  801a63:	8b 40 0c             	mov    0xc(%eax),%eax
  801a66:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a6b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a70:	b8 06 00 00 00       	mov    $0x6,%eax
  801a75:	e8 61 ff ff ff       	call   8019db <fsipc>
}
  801a7a:	c9                   	leave  
  801a7b:	c3                   	ret    

00801a7c <devfile_stat>:
{
  801a7c:	f3 0f 1e fb          	endbr32 
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	53                   	push   %ebx
  801a84:	83 ec 04             	sub    $0x4,%esp
  801a87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a90:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a95:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9a:	b8 05 00 00 00       	mov    $0x5,%eax
  801a9f:	e8 37 ff ff ff       	call   8019db <fsipc>
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	78 2c                	js     801ad4 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801aa8:	83 ec 08             	sub    $0x8,%esp
  801aab:	68 00 50 80 00       	push   $0x805000
  801ab0:	53                   	push   %ebx
  801ab1:	e8 90 f2 ff ff       	call   800d46 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ab6:	a1 80 50 80 00       	mov    0x805080,%eax
  801abb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ac1:	a1 84 50 80 00       	mov    0x805084,%eax
  801ac6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ad4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad7:	c9                   	leave  
  801ad8:	c3                   	ret    

00801ad9 <devfile_write>:
{
  801ad9:	f3 0f 1e fb          	endbr32 
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	57                   	push   %edi
  801ae1:	56                   	push   %esi
  801ae2:	53                   	push   %ebx
  801ae3:	83 ec 0c             	sub    $0xc,%esp
  801ae6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801aec:	8b 45 08             	mov    0x8(%ebp),%eax
  801aef:	8b 40 0c             	mov    0xc(%eax),%eax
  801af2:	a3 00 50 80 00       	mov    %eax,0x805000
	int r = 0;
  801af7:	b8 00 00 00 00       	mov    $0x0,%eax
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801afc:	bf f8 0f 00 00       	mov    $0xff8,%edi
	while (n > 0) {
  801b01:	85 db                	test   %ebx,%ebx
  801b03:	74 3b                	je     801b40 <devfile_write+0x67>
		fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801b05:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  801b0b:	89 f8                	mov    %edi,%eax
  801b0d:	0f 46 c3             	cmovbe %ebx,%eax
  801b10:	a3 04 50 80 00       	mov    %eax,0x805004
		memmove(fsipcbuf.write.req_buf, buf_aux, fsipcbuf.write.req_n);
  801b15:	83 ec 04             	sub    $0x4,%esp
  801b18:	50                   	push   %eax
  801b19:	56                   	push   %esi
  801b1a:	68 08 50 80 00       	push   $0x805008
  801b1f:	e8 da f3 ff ff       	call   800efe <memmove>
		if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801b24:	ba 00 00 00 00       	mov    $0x0,%edx
  801b29:	b8 04 00 00 00       	mov    $0x4,%eax
  801b2e:	e8 a8 fe ff ff       	call   8019db <fsipc>
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	85 c0                	test   %eax,%eax
  801b38:	78 06                	js     801b40 <devfile_write+0x67>
		buf_aux += r;
  801b3a:	01 c6                	add    %eax,%esi
		n -= r;
  801b3c:	29 c3                	sub    %eax,%ebx
  801b3e:	eb c1                	jmp    801b01 <devfile_write+0x28>
}
  801b40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b43:	5b                   	pop    %ebx
  801b44:	5e                   	pop    %esi
  801b45:	5f                   	pop    %edi
  801b46:	5d                   	pop    %ebp
  801b47:	c3                   	ret    

00801b48 <devfile_read>:
{
  801b48:	f3 0f 1e fb          	endbr32 
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	56                   	push   %esi
  801b50:	53                   	push   %ebx
  801b51:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b54:	8b 45 08             	mov    0x8(%ebp),%eax
  801b57:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b5f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b65:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6a:	b8 03 00 00 00       	mov    $0x3,%eax
  801b6f:	e8 67 fe ff ff       	call   8019db <fsipc>
  801b74:	89 c3                	mov    %eax,%ebx
  801b76:	85 c0                	test   %eax,%eax
  801b78:	78 1f                	js     801b99 <devfile_read+0x51>
	assert(r <= n);
  801b7a:	39 f0                	cmp    %esi,%eax
  801b7c:	77 24                	ja     801ba2 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801b7e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b83:	7f 33                	jg     801bb8 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b85:	83 ec 04             	sub    $0x4,%esp
  801b88:	50                   	push   %eax
  801b89:	68 00 50 80 00       	push   $0x805000
  801b8e:	ff 75 0c             	pushl  0xc(%ebp)
  801b91:	e8 68 f3 ff ff       	call   800efe <memmove>
	return r;
  801b96:	83 c4 10             	add    $0x10,%esp
}
  801b99:	89 d8                	mov    %ebx,%eax
  801b9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9e:	5b                   	pop    %ebx
  801b9f:	5e                   	pop    %esi
  801ba0:	5d                   	pop    %ebp
  801ba1:	c3                   	ret    
	assert(r <= n);
  801ba2:	68 04 2c 80 00       	push   $0x802c04
  801ba7:	68 0b 2c 80 00       	push   $0x802c0b
  801bac:	6a 7c                	push   $0x7c
  801bae:	68 20 2c 80 00       	push   $0x802c20
  801bb3:	e8 3d eb ff ff       	call   8006f5 <_panic>
	assert(r <= PGSIZE);
  801bb8:	68 2b 2c 80 00       	push   $0x802c2b
  801bbd:	68 0b 2c 80 00       	push   $0x802c0b
  801bc2:	6a 7d                	push   $0x7d
  801bc4:	68 20 2c 80 00       	push   $0x802c20
  801bc9:	e8 27 eb ff ff       	call   8006f5 <_panic>

00801bce <open>:
{
  801bce:	f3 0f 1e fb          	endbr32 
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	56                   	push   %esi
  801bd6:	53                   	push   %ebx
  801bd7:	83 ec 1c             	sub    $0x1c,%esp
  801bda:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801bdd:	56                   	push   %esi
  801bde:	e8 20 f1 ff ff       	call   800d03 <strlen>
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801beb:	7f 6c                	jg     801c59 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801bed:	83 ec 0c             	sub    $0xc,%esp
  801bf0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf3:	50                   	push   %eax
  801bf4:	e8 42 f8 ff ff       	call   80143b <fd_alloc>
  801bf9:	89 c3                	mov    %eax,%ebx
  801bfb:	83 c4 10             	add    $0x10,%esp
  801bfe:	85 c0                	test   %eax,%eax
  801c00:	78 3c                	js     801c3e <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801c02:	83 ec 08             	sub    $0x8,%esp
  801c05:	56                   	push   %esi
  801c06:	68 00 50 80 00       	push   $0x805000
  801c0b:	e8 36 f1 ff ff       	call   800d46 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c13:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c18:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c1b:	b8 01 00 00 00       	mov    $0x1,%eax
  801c20:	e8 b6 fd ff ff       	call   8019db <fsipc>
  801c25:	89 c3                	mov    %eax,%ebx
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	78 19                	js     801c47 <open+0x79>
	return fd2num(fd);
  801c2e:	83 ec 0c             	sub    $0xc,%esp
  801c31:	ff 75 f4             	pushl  -0xc(%ebp)
  801c34:	e8 cf f7 ff ff       	call   801408 <fd2num>
  801c39:	89 c3                	mov    %eax,%ebx
  801c3b:	83 c4 10             	add    $0x10,%esp
}
  801c3e:	89 d8                	mov    %ebx,%eax
  801c40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5d                   	pop    %ebp
  801c46:	c3                   	ret    
		fd_close(fd, 0);
  801c47:	83 ec 08             	sub    $0x8,%esp
  801c4a:	6a 00                	push   $0x0
  801c4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4f:	e8 eb f8 ff ff       	call   80153f <fd_close>
		return r;
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	eb e5                	jmp    801c3e <open+0x70>
		return -E_BAD_PATH;
  801c59:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c5e:	eb de                	jmp    801c3e <open+0x70>

00801c60 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c60:	f3 0f 1e fb          	endbr32 
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c6a:	ba 00 00 00 00       	mov    $0x0,%edx
  801c6f:	b8 08 00 00 00       	mov    $0x8,%eax
  801c74:	e8 62 fd ff ff       	call   8019db <fsipc>
}
  801c79:	c9                   	leave  
  801c7a:	c3                   	ret    

00801c7b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c7b:	f3 0f 1e fb          	endbr32 
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c87:	83 ec 0c             	sub    $0xc,%esp
  801c8a:	ff 75 08             	pushl  0x8(%ebp)
  801c8d:	e8 8a f7 ff ff       	call   80141c <fd2data>
  801c92:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c94:	83 c4 08             	add    $0x8,%esp
  801c97:	68 37 2c 80 00       	push   $0x802c37
  801c9c:	53                   	push   %ebx
  801c9d:	e8 a4 f0 ff ff       	call   800d46 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ca2:	8b 46 04             	mov    0x4(%esi),%eax
  801ca5:	2b 06                	sub    (%esi),%eax
  801ca7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cb4:	00 00 00 
	stat->st_dev = &devpipe;
  801cb7:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801cbe:	30 80 00 
	return 0;
}
  801cc1:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cc9:	5b                   	pop    %ebx
  801cca:	5e                   	pop    %esi
  801ccb:	5d                   	pop    %ebp
  801ccc:	c3                   	ret    

00801ccd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ccd:	f3 0f 1e fb          	endbr32 
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	53                   	push   %ebx
  801cd5:	83 ec 0c             	sub    $0xc,%esp
  801cd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cdb:	53                   	push   %ebx
  801cdc:	6a 00                	push   $0x0
  801cde:	e8 3d f5 ff ff       	call   801220 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ce3:	89 1c 24             	mov    %ebx,(%esp)
  801ce6:	e8 31 f7 ff ff       	call   80141c <fd2data>
  801ceb:	83 c4 08             	add    $0x8,%esp
  801cee:	50                   	push   %eax
  801cef:	6a 00                	push   $0x0
  801cf1:	e8 2a f5 ff ff       	call   801220 <sys_page_unmap>
}
  801cf6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    

00801cfb <_pipeisclosed>:
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	57                   	push   %edi
  801cff:	56                   	push   %esi
  801d00:	53                   	push   %ebx
  801d01:	83 ec 1c             	sub    $0x1c,%esp
  801d04:	89 c7                	mov    %eax,%edi
  801d06:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801d08:	a1 04 40 80 00       	mov    0x804004,%eax
  801d0d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d10:	83 ec 0c             	sub    $0xc,%esp
  801d13:	57                   	push   %edi
  801d14:	e8 5d 04 00 00       	call   802176 <pageref>
  801d19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d1c:	89 34 24             	mov    %esi,(%esp)
  801d1f:	e8 52 04 00 00       	call   802176 <pageref>
		nn = thisenv->env_runs;
  801d24:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d2a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d2d:	83 c4 10             	add    $0x10,%esp
  801d30:	39 cb                	cmp    %ecx,%ebx
  801d32:	74 1b                	je     801d4f <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801d34:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d37:	75 cf                	jne    801d08 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d39:	8b 42 58             	mov    0x58(%edx),%eax
  801d3c:	6a 01                	push   $0x1
  801d3e:	50                   	push   %eax
  801d3f:	53                   	push   %ebx
  801d40:	68 3e 2c 80 00       	push   $0x802c3e
  801d45:	e8 92 ea ff ff       	call   8007dc <cprintf>
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	eb b9                	jmp    801d08 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801d4f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d52:	0f 94 c0             	sete   %al
  801d55:	0f b6 c0             	movzbl %al,%eax
}
  801d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d5b:	5b                   	pop    %ebx
  801d5c:	5e                   	pop    %esi
  801d5d:	5f                   	pop    %edi
  801d5e:	5d                   	pop    %ebp
  801d5f:	c3                   	ret    

00801d60 <devpipe_write>:
{
  801d60:	f3 0f 1e fb          	endbr32 
  801d64:	55                   	push   %ebp
  801d65:	89 e5                	mov    %esp,%ebp
  801d67:	57                   	push   %edi
  801d68:	56                   	push   %esi
  801d69:	53                   	push   %ebx
  801d6a:	83 ec 28             	sub    $0x28,%esp
  801d6d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d70:	56                   	push   %esi
  801d71:	e8 a6 f6 ff ff       	call   80141c <fd2data>
  801d76:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d78:	83 c4 10             	add    $0x10,%esp
  801d7b:	bf 00 00 00 00       	mov    $0x0,%edi
  801d80:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d83:	74 4f                	je     801dd4 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d85:	8b 43 04             	mov    0x4(%ebx),%eax
  801d88:	8b 0b                	mov    (%ebx),%ecx
  801d8a:	8d 51 20             	lea    0x20(%ecx),%edx
  801d8d:	39 d0                	cmp    %edx,%eax
  801d8f:	72 14                	jb     801da5 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801d91:	89 da                	mov    %ebx,%edx
  801d93:	89 f0                	mov    %esi,%eax
  801d95:	e8 61 ff ff ff       	call   801cfb <_pipeisclosed>
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	75 3b                	jne    801dd9 <devpipe_write+0x79>
			sys_yield();
  801d9e:	e8 00 f4 ff ff       	call   8011a3 <sys_yield>
  801da3:	eb e0                	jmp    801d85 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801da5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801da8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dac:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801daf:	89 c2                	mov    %eax,%edx
  801db1:	c1 fa 1f             	sar    $0x1f,%edx
  801db4:	89 d1                	mov    %edx,%ecx
  801db6:	c1 e9 1b             	shr    $0x1b,%ecx
  801db9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dbc:	83 e2 1f             	and    $0x1f,%edx
  801dbf:	29 ca                	sub    %ecx,%edx
  801dc1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801dc5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801dc9:	83 c0 01             	add    $0x1,%eax
  801dcc:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801dcf:	83 c7 01             	add    $0x1,%edi
  801dd2:	eb ac                	jmp    801d80 <devpipe_write+0x20>
	return i;
  801dd4:	8b 45 10             	mov    0x10(%ebp),%eax
  801dd7:	eb 05                	jmp    801dde <devpipe_write+0x7e>
				return 0;
  801dd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de1:	5b                   	pop    %ebx
  801de2:	5e                   	pop    %esi
  801de3:	5f                   	pop    %edi
  801de4:	5d                   	pop    %ebp
  801de5:	c3                   	ret    

00801de6 <devpipe_read>:
{
  801de6:	f3 0f 1e fb          	endbr32 
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	57                   	push   %edi
  801dee:	56                   	push   %esi
  801def:	53                   	push   %ebx
  801df0:	83 ec 18             	sub    $0x18,%esp
  801df3:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801df6:	57                   	push   %edi
  801df7:	e8 20 f6 ff ff       	call   80141c <fd2data>
  801dfc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801dfe:	83 c4 10             	add    $0x10,%esp
  801e01:	be 00 00 00 00       	mov    $0x0,%esi
  801e06:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e09:	75 14                	jne    801e1f <devpipe_read+0x39>
	return i;
  801e0b:	8b 45 10             	mov    0x10(%ebp),%eax
  801e0e:	eb 02                	jmp    801e12 <devpipe_read+0x2c>
				return i;
  801e10:	89 f0                	mov    %esi,%eax
}
  801e12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e15:	5b                   	pop    %ebx
  801e16:	5e                   	pop    %esi
  801e17:	5f                   	pop    %edi
  801e18:	5d                   	pop    %ebp
  801e19:	c3                   	ret    
			sys_yield();
  801e1a:	e8 84 f3 ff ff       	call   8011a3 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e1f:	8b 03                	mov    (%ebx),%eax
  801e21:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e24:	75 18                	jne    801e3e <devpipe_read+0x58>
			if (i > 0)
  801e26:	85 f6                	test   %esi,%esi
  801e28:	75 e6                	jne    801e10 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801e2a:	89 da                	mov    %ebx,%edx
  801e2c:	89 f8                	mov    %edi,%eax
  801e2e:	e8 c8 fe ff ff       	call   801cfb <_pipeisclosed>
  801e33:	85 c0                	test   %eax,%eax
  801e35:	74 e3                	je     801e1a <devpipe_read+0x34>
				return 0;
  801e37:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3c:	eb d4                	jmp    801e12 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e3e:	99                   	cltd   
  801e3f:	c1 ea 1b             	shr    $0x1b,%edx
  801e42:	01 d0                	add    %edx,%eax
  801e44:	83 e0 1f             	and    $0x1f,%eax
  801e47:	29 d0                	sub    %edx,%eax
  801e49:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e51:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e54:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e57:	83 c6 01             	add    $0x1,%esi
  801e5a:	eb aa                	jmp    801e06 <devpipe_read+0x20>

00801e5c <pipe>:
{
  801e5c:	f3 0f 1e fb          	endbr32 
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	56                   	push   %esi
  801e64:	53                   	push   %ebx
  801e65:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e6b:	50                   	push   %eax
  801e6c:	e8 ca f5 ff ff       	call   80143b <fd_alloc>
  801e71:	89 c3                	mov    %eax,%ebx
  801e73:	83 c4 10             	add    $0x10,%esp
  801e76:	85 c0                	test   %eax,%eax
  801e78:	0f 88 23 01 00 00    	js     801fa1 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7e:	83 ec 04             	sub    $0x4,%esp
  801e81:	68 07 04 00 00       	push   $0x407
  801e86:	ff 75 f4             	pushl  -0xc(%ebp)
  801e89:	6a 00                	push   $0x0
  801e8b:	e8 3e f3 ff ff       	call   8011ce <sys_page_alloc>
  801e90:	89 c3                	mov    %eax,%ebx
  801e92:	83 c4 10             	add    $0x10,%esp
  801e95:	85 c0                	test   %eax,%eax
  801e97:	0f 88 04 01 00 00    	js     801fa1 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801e9d:	83 ec 0c             	sub    $0xc,%esp
  801ea0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ea3:	50                   	push   %eax
  801ea4:	e8 92 f5 ff ff       	call   80143b <fd_alloc>
  801ea9:	89 c3                	mov    %eax,%ebx
  801eab:	83 c4 10             	add    $0x10,%esp
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	0f 88 db 00 00 00    	js     801f91 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb6:	83 ec 04             	sub    $0x4,%esp
  801eb9:	68 07 04 00 00       	push   $0x407
  801ebe:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec1:	6a 00                	push   $0x0
  801ec3:	e8 06 f3 ff ff       	call   8011ce <sys_page_alloc>
  801ec8:	89 c3                	mov    %eax,%ebx
  801eca:	83 c4 10             	add    $0x10,%esp
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	0f 88 bc 00 00 00    	js     801f91 <pipe+0x135>
	va = fd2data(fd0);
  801ed5:	83 ec 0c             	sub    $0xc,%esp
  801ed8:	ff 75 f4             	pushl  -0xc(%ebp)
  801edb:	e8 3c f5 ff ff       	call   80141c <fd2data>
  801ee0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee2:	83 c4 0c             	add    $0xc,%esp
  801ee5:	68 07 04 00 00       	push   $0x407
  801eea:	50                   	push   %eax
  801eeb:	6a 00                	push   $0x0
  801eed:	e8 dc f2 ff ff       	call   8011ce <sys_page_alloc>
  801ef2:	89 c3                	mov    %eax,%ebx
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	85 c0                	test   %eax,%eax
  801ef9:	0f 88 82 00 00 00    	js     801f81 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eff:	83 ec 0c             	sub    $0xc,%esp
  801f02:	ff 75 f0             	pushl  -0x10(%ebp)
  801f05:	e8 12 f5 ff ff       	call   80141c <fd2data>
  801f0a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f11:	50                   	push   %eax
  801f12:	6a 00                	push   $0x0
  801f14:	56                   	push   %esi
  801f15:	6a 00                	push   $0x0
  801f17:	e8 da f2 ff ff       	call   8011f6 <sys_page_map>
  801f1c:	89 c3                	mov    %eax,%ebx
  801f1e:	83 c4 20             	add    $0x20,%esp
  801f21:	85 c0                	test   %eax,%eax
  801f23:	78 4e                	js     801f73 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801f25:	a1 24 30 80 00       	mov    0x803024,%eax
  801f2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f2d:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801f2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f32:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801f39:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f3c:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801f3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f41:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f48:	83 ec 0c             	sub    $0xc,%esp
  801f4b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f4e:	e8 b5 f4 ff ff       	call   801408 <fd2num>
  801f53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f56:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f58:	83 c4 04             	add    $0x4,%esp
  801f5b:	ff 75 f0             	pushl  -0x10(%ebp)
  801f5e:	e8 a5 f4 ff ff       	call   801408 <fd2num>
  801f63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f66:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f69:	83 c4 10             	add    $0x10,%esp
  801f6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f71:	eb 2e                	jmp    801fa1 <pipe+0x145>
	sys_page_unmap(0, va);
  801f73:	83 ec 08             	sub    $0x8,%esp
  801f76:	56                   	push   %esi
  801f77:	6a 00                	push   $0x0
  801f79:	e8 a2 f2 ff ff       	call   801220 <sys_page_unmap>
  801f7e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f81:	83 ec 08             	sub    $0x8,%esp
  801f84:	ff 75 f0             	pushl  -0x10(%ebp)
  801f87:	6a 00                	push   $0x0
  801f89:	e8 92 f2 ff ff       	call   801220 <sys_page_unmap>
  801f8e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801f91:	83 ec 08             	sub    $0x8,%esp
  801f94:	ff 75 f4             	pushl  -0xc(%ebp)
  801f97:	6a 00                	push   $0x0
  801f99:	e8 82 f2 ff ff       	call   801220 <sys_page_unmap>
  801f9e:	83 c4 10             	add    $0x10,%esp
}
  801fa1:	89 d8                	mov    %ebx,%eax
  801fa3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa6:	5b                   	pop    %ebx
  801fa7:	5e                   	pop    %esi
  801fa8:	5d                   	pop    %ebp
  801fa9:	c3                   	ret    

00801faa <pipeisclosed>:
{
  801faa:	f3 0f 1e fb          	endbr32 
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb7:	50                   	push   %eax
  801fb8:	ff 75 08             	pushl  0x8(%ebp)
  801fbb:	e8 d1 f4 ff ff       	call   801491 <fd_lookup>
  801fc0:	83 c4 10             	add    $0x10,%esp
  801fc3:	85 c0                	test   %eax,%eax
  801fc5:	78 18                	js     801fdf <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801fc7:	83 ec 0c             	sub    $0xc,%esp
  801fca:	ff 75 f4             	pushl  -0xc(%ebp)
  801fcd:	e8 4a f4 ff ff       	call   80141c <fd2data>
  801fd2:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd7:	e8 1f fd ff ff       	call   801cfb <_pipeisclosed>
  801fdc:	83 c4 10             	add    $0x10,%esp
}
  801fdf:	c9                   	leave  
  801fe0:	c3                   	ret    

00801fe1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fe1:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801fe5:	b8 00 00 00 00       	mov    $0x0,%eax
  801fea:	c3                   	ret    

00801feb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801feb:	f3 0f 1e fb          	endbr32 
  801fef:	55                   	push   %ebp
  801ff0:	89 e5                	mov    %esp,%ebp
  801ff2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ff5:	68 56 2c 80 00       	push   $0x802c56
  801ffa:	ff 75 0c             	pushl  0xc(%ebp)
  801ffd:	e8 44 ed ff ff       	call   800d46 <strcpy>
	return 0;
}
  802002:	b8 00 00 00 00       	mov    $0x0,%eax
  802007:	c9                   	leave  
  802008:	c3                   	ret    

00802009 <devcons_write>:
{
  802009:	f3 0f 1e fb          	endbr32 
  80200d:	55                   	push   %ebp
  80200e:	89 e5                	mov    %esp,%ebp
  802010:	57                   	push   %edi
  802011:	56                   	push   %esi
  802012:	53                   	push   %ebx
  802013:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802019:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80201e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802024:	3b 75 10             	cmp    0x10(%ebp),%esi
  802027:	73 31                	jae    80205a <devcons_write+0x51>
		m = n - tot;
  802029:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80202c:	29 f3                	sub    %esi,%ebx
  80202e:	83 fb 7f             	cmp    $0x7f,%ebx
  802031:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802036:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802039:	83 ec 04             	sub    $0x4,%esp
  80203c:	53                   	push   %ebx
  80203d:	89 f0                	mov    %esi,%eax
  80203f:	03 45 0c             	add    0xc(%ebp),%eax
  802042:	50                   	push   %eax
  802043:	57                   	push   %edi
  802044:	e8 b5 ee ff ff       	call   800efe <memmove>
		sys_cputs(buf, m);
  802049:	83 c4 08             	add    $0x8,%esp
  80204c:	53                   	push   %ebx
  80204d:	57                   	push   %edi
  80204e:	e8 b0 f0 ff ff       	call   801103 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802053:	01 de                	add    %ebx,%esi
  802055:	83 c4 10             	add    $0x10,%esp
  802058:	eb ca                	jmp    802024 <devcons_write+0x1b>
}
  80205a:	89 f0                	mov    %esi,%eax
  80205c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80205f:	5b                   	pop    %ebx
  802060:	5e                   	pop    %esi
  802061:	5f                   	pop    %edi
  802062:	5d                   	pop    %ebp
  802063:	c3                   	ret    

00802064 <devcons_read>:
{
  802064:	f3 0f 1e fb          	endbr32 
  802068:	55                   	push   %ebp
  802069:	89 e5                	mov    %esp,%ebp
  80206b:	83 ec 08             	sub    $0x8,%esp
  80206e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802073:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802077:	74 21                	je     80209a <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  802079:	e8 af f0 ff ff       	call   80112d <sys_cgetc>
  80207e:	85 c0                	test   %eax,%eax
  802080:	75 07                	jne    802089 <devcons_read+0x25>
		sys_yield();
  802082:	e8 1c f1 ff ff       	call   8011a3 <sys_yield>
  802087:	eb f0                	jmp    802079 <devcons_read+0x15>
	if (c < 0)
  802089:	78 0f                	js     80209a <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80208b:	83 f8 04             	cmp    $0x4,%eax
  80208e:	74 0c                	je     80209c <devcons_read+0x38>
	*(char*)vbuf = c;
  802090:	8b 55 0c             	mov    0xc(%ebp),%edx
  802093:	88 02                	mov    %al,(%edx)
	return 1;
  802095:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80209a:	c9                   	leave  
  80209b:	c3                   	ret    
		return 0;
  80209c:	b8 00 00 00 00       	mov    $0x0,%eax
  8020a1:	eb f7                	jmp    80209a <devcons_read+0x36>

008020a3 <cputchar>:
{
  8020a3:	f3 0f 1e fb          	endbr32 
  8020a7:	55                   	push   %ebp
  8020a8:	89 e5                	mov    %esp,%ebp
  8020aa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b0:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8020b3:	6a 01                	push   $0x1
  8020b5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020b8:	50                   	push   %eax
  8020b9:	e8 45 f0 ff ff       	call   801103 <sys_cputs>
}
  8020be:	83 c4 10             	add    $0x10,%esp
  8020c1:	c9                   	leave  
  8020c2:	c3                   	ret    

008020c3 <getchar>:
{
  8020c3:	f3 0f 1e fb          	endbr32 
  8020c7:	55                   	push   %ebp
  8020c8:	89 e5                	mov    %esp,%ebp
  8020ca:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8020cd:	6a 01                	push   $0x1
  8020cf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020d2:	50                   	push   %eax
  8020d3:	6a 00                	push   $0x0
  8020d5:	e8 3a f6 ff ff       	call   801714 <read>
	if (r < 0)
  8020da:	83 c4 10             	add    $0x10,%esp
  8020dd:	85 c0                	test   %eax,%eax
  8020df:	78 06                	js     8020e7 <getchar+0x24>
	if (r < 1)
  8020e1:	74 06                	je     8020e9 <getchar+0x26>
	return c;
  8020e3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8020e7:	c9                   	leave  
  8020e8:	c3                   	ret    
		return -E_EOF;
  8020e9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8020ee:	eb f7                	jmp    8020e7 <getchar+0x24>

008020f0 <iscons>:
{
  8020f0:	f3 0f 1e fb          	endbr32 
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
  8020f7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020fd:	50                   	push   %eax
  8020fe:	ff 75 08             	pushl  0x8(%ebp)
  802101:	e8 8b f3 ff ff       	call   801491 <fd_lookup>
  802106:	83 c4 10             	add    $0x10,%esp
  802109:	85 c0                	test   %eax,%eax
  80210b:	78 11                	js     80211e <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80210d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802110:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802116:	39 10                	cmp    %edx,(%eax)
  802118:	0f 94 c0             	sete   %al
  80211b:	0f b6 c0             	movzbl %al,%eax
}
  80211e:	c9                   	leave  
  80211f:	c3                   	ret    

00802120 <opencons>:
{
  802120:	f3 0f 1e fb          	endbr32 
  802124:	55                   	push   %ebp
  802125:	89 e5                	mov    %esp,%ebp
  802127:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80212a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80212d:	50                   	push   %eax
  80212e:	e8 08 f3 ff ff       	call   80143b <fd_alloc>
  802133:	83 c4 10             	add    $0x10,%esp
  802136:	85 c0                	test   %eax,%eax
  802138:	78 3a                	js     802174 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80213a:	83 ec 04             	sub    $0x4,%esp
  80213d:	68 07 04 00 00       	push   $0x407
  802142:	ff 75 f4             	pushl  -0xc(%ebp)
  802145:	6a 00                	push   $0x0
  802147:	e8 82 f0 ff ff       	call   8011ce <sys_page_alloc>
  80214c:	83 c4 10             	add    $0x10,%esp
  80214f:	85 c0                	test   %eax,%eax
  802151:	78 21                	js     802174 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  802153:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802156:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80215c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80215e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802161:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802168:	83 ec 0c             	sub    $0xc,%esp
  80216b:	50                   	push   %eax
  80216c:	e8 97 f2 ff ff       	call   801408 <fd2num>
  802171:	83 c4 10             	add    $0x10,%esp
}
  802174:	c9                   	leave  
  802175:	c3                   	ret    

00802176 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802176:	f3 0f 1e fb          	endbr32 
  80217a:	55                   	push   %ebp
  80217b:	89 e5                	mov    %esp,%ebp
  80217d:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802180:	89 c2                	mov    %eax,%edx
  802182:	c1 ea 16             	shr    $0x16,%edx
  802185:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80218c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802191:	f6 c1 01             	test   $0x1,%cl
  802194:	74 1c                	je     8021b2 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802196:	c1 e8 0c             	shr    $0xc,%eax
  802199:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021a0:	a8 01                	test   $0x1,%al
  8021a2:	74 0e                	je     8021b2 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021a4:	c1 e8 0c             	shr    $0xc,%eax
  8021a7:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8021ae:	ef 
  8021af:	0f b7 d2             	movzwl %dx,%edx
}
  8021b2:	89 d0                	mov    %edx,%eax
  8021b4:	5d                   	pop    %ebp
  8021b5:	c3                   	ret    
  8021b6:	66 90                	xchg   %ax,%ax
  8021b8:	66 90                	xchg   %ax,%ax
  8021ba:	66 90                	xchg   %ax,%ax
  8021bc:	66 90                	xchg   %ax,%ax
  8021be:	66 90                	xchg   %ax,%ax

008021c0 <__udivdi3>:
  8021c0:	f3 0f 1e fb          	endbr32 
  8021c4:	55                   	push   %ebp
  8021c5:	57                   	push   %edi
  8021c6:	56                   	push   %esi
  8021c7:	53                   	push   %ebx
  8021c8:	83 ec 1c             	sub    $0x1c,%esp
  8021cb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021d3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021db:	85 d2                	test   %edx,%edx
  8021dd:	75 19                	jne    8021f8 <__udivdi3+0x38>
  8021df:	39 f3                	cmp    %esi,%ebx
  8021e1:	76 4d                	jbe    802230 <__udivdi3+0x70>
  8021e3:	31 ff                	xor    %edi,%edi
  8021e5:	89 e8                	mov    %ebp,%eax
  8021e7:	89 f2                	mov    %esi,%edx
  8021e9:	f7 f3                	div    %ebx
  8021eb:	89 fa                	mov    %edi,%edx
  8021ed:	83 c4 1c             	add    $0x1c,%esp
  8021f0:	5b                   	pop    %ebx
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    
  8021f5:	8d 76 00             	lea    0x0(%esi),%esi
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	76 14                	jbe    802210 <__udivdi3+0x50>
  8021fc:	31 ff                	xor    %edi,%edi
  8021fe:	31 c0                	xor    %eax,%eax
  802200:	89 fa                	mov    %edi,%edx
  802202:	83 c4 1c             	add    $0x1c,%esp
  802205:	5b                   	pop    %ebx
  802206:	5e                   	pop    %esi
  802207:	5f                   	pop    %edi
  802208:	5d                   	pop    %ebp
  802209:	c3                   	ret    
  80220a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802210:	0f bd fa             	bsr    %edx,%edi
  802213:	83 f7 1f             	xor    $0x1f,%edi
  802216:	75 48                	jne    802260 <__udivdi3+0xa0>
  802218:	39 f2                	cmp    %esi,%edx
  80221a:	72 06                	jb     802222 <__udivdi3+0x62>
  80221c:	31 c0                	xor    %eax,%eax
  80221e:	39 eb                	cmp    %ebp,%ebx
  802220:	77 de                	ja     802200 <__udivdi3+0x40>
  802222:	b8 01 00 00 00       	mov    $0x1,%eax
  802227:	eb d7                	jmp    802200 <__udivdi3+0x40>
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	89 d9                	mov    %ebx,%ecx
  802232:	85 db                	test   %ebx,%ebx
  802234:	75 0b                	jne    802241 <__udivdi3+0x81>
  802236:	b8 01 00 00 00       	mov    $0x1,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	f7 f3                	div    %ebx
  80223f:	89 c1                	mov    %eax,%ecx
  802241:	31 d2                	xor    %edx,%edx
  802243:	89 f0                	mov    %esi,%eax
  802245:	f7 f1                	div    %ecx
  802247:	89 c6                	mov    %eax,%esi
  802249:	89 e8                	mov    %ebp,%eax
  80224b:	89 f7                	mov    %esi,%edi
  80224d:	f7 f1                	div    %ecx
  80224f:	89 fa                	mov    %edi,%edx
  802251:	83 c4 1c             	add    $0x1c,%esp
  802254:	5b                   	pop    %ebx
  802255:	5e                   	pop    %esi
  802256:	5f                   	pop    %edi
  802257:	5d                   	pop    %ebp
  802258:	c3                   	ret    
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	89 f9                	mov    %edi,%ecx
  802262:	b8 20 00 00 00       	mov    $0x20,%eax
  802267:	29 f8                	sub    %edi,%eax
  802269:	d3 e2                	shl    %cl,%edx
  80226b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80226f:	89 c1                	mov    %eax,%ecx
  802271:	89 da                	mov    %ebx,%edx
  802273:	d3 ea                	shr    %cl,%edx
  802275:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802279:	09 d1                	or     %edx,%ecx
  80227b:	89 f2                	mov    %esi,%edx
  80227d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802281:	89 f9                	mov    %edi,%ecx
  802283:	d3 e3                	shl    %cl,%ebx
  802285:	89 c1                	mov    %eax,%ecx
  802287:	d3 ea                	shr    %cl,%edx
  802289:	89 f9                	mov    %edi,%ecx
  80228b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80228f:	89 eb                	mov    %ebp,%ebx
  802291:	d3 e6                	shl    %cl,%esi
  802293:	89 c1                	mov    %eax,%ecx
  802295:	d3 eb                	shr    %cl,%ebx
  802297:	09 de                	or     %ebx,%esi
  802299:	89 f0                	mov    %esi,%eax
  80229b:	f7 74 24 08          	divl   0x8(%esp)
  80229f:	89 d6                	mov    %edx,%esi
  8022a1:	89 c3                	mov    %eax,%ebx
  8022a3:	f7 64 24 0c          	mull   0xc(%esp)
  8022a7:	39 d6                	cmp    %edx,%esi
  8022a9:	72 15                	jb     8022c0 <__udivdi3+0x100>
  8022ab:	89 f9                	mov    %edi,%ecx
  8022ad:	d3 e5                	shl    %cl,%ebp
  8022af:	39 c5                	cmp    %eax,%ebp
  8022b1:	73 04                	jae    8022b7 <__udivdi3+0xf7>
  8022b3:	39 d6                	cmp    %edx,%esi
  8022b5:	74 09                	je     8022c0 <__udivdi3+0x100>
  8022b7:	89 d8                	mov    %ebx,%eax
  8022b9:	31 ff                	xor    %edi,%edi
  8022bb:	e9 40 ff ff ff       	jmp    802200 <__udivdi3+0x40>
  8022c0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8022c3:	31 ff                	xor    %edi,%edi
  8022c5:	e9 36 ff ff ff       	jmp    802200 <__udivdi3+0x40>
  8022ca:	66 90                	xchg   %ax,%ax
  8022cc:	66 90                	xchg   %ax,%ax
  8022ce:	66 90                	xchg   %ax,%ax

008022d0 <__umoddi3>:
  8022d0:	f3 0f 1e fb          	endbr32 
  8022d4:	55                   	push   %ebp
  8022d5:	57                   	push   %edi
  8022d6:	56                   	push   %esi
  8022d7:	53                   	push   %ebx
  8022d8:	83 ec 1c             	sub    $0x1c,%esp
  8022db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022df:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022e3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022e7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022eb:	85 c0                	test   %eax,%eax
  8022ed:	75 19                	jne    802308 <__umoddi3+0x38>
  8022ef:	39 df                	cmp    %ebx,%edi
  8022f1:	76 5d                	jbe    802350 <__umoddi3+0x80>
  8022f3:	89 f0                	mov    %esi,%eax
  8022f5:	89 da                	mov    %ebx,%edx
  8022f7:	f7 f7                	div    %edi
  8022f9:	89 d0                	mov    %edx,%eax
  8022fb:	31 d2                	xor    %edx,%edx
  8022fd:	83 c4 1c             	add    $0x1c,%esp
  802300:	5b                   	pop    %ebx
  802301:	5e                   	pop    %esi
  802302:	5f                   	pop    %edi
  802303:	5d                   	pop    %ebp
  802304:	c3                   	ret    
  802305:	8d 76 00             	lea    0x0(%esi),%esi
  802308:	89 f2                	mov    %esi,%edx
  80230a:	39 d8                	cmp    %ebx,%eax
  80230c:	76 12                	jbe    802320 <__umoddi3+0x50>
  80230e:	89 f0                	mov    %esi,%eax
  802310:	89 da                	mov    %ebx,%edx
  802312:	83 c4 1c             	add    $0x1c,%esp
  802315:	5b                   	pop    %ebx
  802316:	5e                   	pop    %esi
  802317:	5f                   	pop    %edi
  802318:	5d                   	pop    %ebp
  802319:	c3                   	ret    
  80231a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802320:	0f bd e8             	bsr    %eax,%ebp
  802323:	83 f5 1f             	xor    $0x1f,%ebp
  802326:	75 50                	jne    802378 <__umoddi3+0xa8>
  802328:	39 d8                	cmp    %ebx,%eax
  80232a:	0f 82 e0 00 00 00    	jb     802410 <__umoddi3+0x140>
  802330:	89 d9                	mov    %ebx,%ecx
  802332:	39 f7                	cmp    %esi,%edi
  802334:	0f 86 d6 00 00 00    	jbe    802410 <__umoddi3+0x140>
  80233a:	89 d0                	mov    %edx,%eax
  80233c:	89 ca                	mov    %ecx,%edx
  80233e:	83 c4 1c             	add    $0x1c,%esp
  802341:	5b                   	pop    %ebx
  802342:	5e                   	pop    %esi
  802343:	5f                   	pop    %edi
  802344:	5d                   	pop    %ebp
  802345:	c3                   	ret    
  802346:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80234d:	8d 76 00             	lea    0x0(%esi),%esi
  802350:	89 fd                	mov    %edi,%ebp
  802352:	85 ff                	test   %edi,%edi
  802354:	75 0b                	jne    802361 <__umoddi3+0x91>
  802356:	b8 01 00 00 00       	mov    $0x1,%eax
  80235b:	31 d2                	xor    %edx,%edx
  80235d:	f7 f7                	div    %edi
  80235f:	89 c5                	mov    %eax,%ebp
  802361:	89 d8                	mov    %ebx,%eax
  802363:	31 d2                	xor    %edx,%edx
  802365:	f7 f5                	div    %ebp
  802367:	89 f0                	mov    %esi,%eax
  802369:	f7 f5                	div    %ebp
  80236b:	89 d0                	mov    %edx,%eax
  80236d:	31 d2                	xor    %edx,%edx
  80236f:	eb 8c                	jmp    8022fd <__umoddi3+0x2d>
  802371:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802378:	89 e9                	mov    %ebp,%ecx
  80237a:	ba 20 00 00 00       	mov    $0x20,%edx
  80237f:	29 ea                	sub    %ebp,%edx
  802381:	d3 e0                	shl    %cl,%eax
  802383:	89 44 24 08          	mov    %eax,0x8(%esp)
  802387:	89 d1                	mov    %edx,%ecx
  802389:	89 f8                	mov    %edi,%eax
  80238b:	d3 e8                	shr    %cl,%eax
  80238d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802391:	89 54 24 04          	mov    %edx,0x4(%esp)
  802395:	8b 54 24 04          	mov    0x4(%esp),%edx
  802399:	09 c1                	or     %eax,%ecx
  80239b:	89 d8                	mov    %ebx,%eax
  80239d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023a1:	89 e9                	mov    %ebp,%ecx
  8023a3:	d3 e7                	shl    %cl,%edi
  8023a5:	89 d1                	mov    %edx,%ecx
  8023a7:	d3 e8                	shr    %cl,%eax
  8023a9:	89 e9                	mov    %ebp,%ecx
  8023ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023af:	d3 e3                	shl    %cl,%ebx
  8023b1:	89 c7                	mov    %eax,%edi
  8023b3:	89 d1                	mov    %edx,%ecx
  8023b5:	89 f0                	mov    %esi,%eax
  8023b7:	d3 e8                	shr    %cl,%eax
  8023b9:	89 e9                	mov    %ebp,%ecx
  8023bb:	89 fa                	mov    %edi,%edx
  8023bd:	d3 e6                	shl    %cl,%esi
  8023bf:	09 d8                	or     %ebx,%eax
  8023c1:	f7 74 24 08          	divl   0x8(%esp)
  8023c5:	89 d1                	mov    %edx,%ecx
  8023c7:	89 f3                	mov    %esi,%ebx
  8023c9:	f7 64 24 0c          	mull   0xc(%esp)
  8023cd:	89 c6                	mov    %eax,%esi
  8023cf:	89 d7                	mov    %edx,%edi
  8023d1:	39 d1                	cmp    %edx,%ecx
  8023d3:	72 06                	jb     8023db <__umoddi3+0x10b>
  8023d5:	75 10                	jne    8023e7 <__umoddi3+0x117>
  8023d7:	39 c3                	cmp    %eax,%ebx
  8023d9:	73 0c                	jae    8023e7 <__umoddi3+0x117>
  8023db:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8023df:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8023e3:	89 d7                	mov    %edx,%edi
  8023e5:	89 c6                	mov    %eax,%esi
  8023e7:	89 ca                	mov    %ecx,%edx
  8023e9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023ee:	29 f3                	sub    %esi,%ebx
  8023f0:	19 fa                	sbb    %edi,%edx
  8023f2:	89 d0                	mov    %edx,%eax
  8023f4:	d3 e0                	shl    %cl,%eax
  8023f6:	89 e9                	mov    %ebp,%ecx
  8023f8:	d3 eb                	shr    %cl,%ebx
  8023fa:	d3 ea                	shr    %cl,%edx
  8023fc:	09 d8                	or     %ebx,%eax
  8023fe:	83 c4 1c             	add    $0x1c,%esp
  802401:	5b                   	pop    %ebx
  802402:	5e                   	pop    %esi
  802403:	5f                   	pop    %edi
  802404:	5d                   	pop    %ebp
  802405:	c3                   	ret    
  802406:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80240d:	8d 76 00             	lea    0x0(%esi),%esi
  802410:	29 fe                	sub    %edi,%esi
  802412:	19 c3                	sbb    %eax,%ebx
  802414:	89 f2                	mov    %esi,%edx
  802416:	89 d9                	mov    %ebx,%ecx
  802418:	e9 1d ff ff ff       	jmp    80233a <__umoddi3+0x6a>
