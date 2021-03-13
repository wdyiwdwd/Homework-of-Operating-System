
obj/user/faultregs：     文件格式 elf32-i386


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
  80002c:	e8 60 05 00 00       	call   800591 <libmain>
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
  800044:	68 d1 15 80 00       	push   $0x8015d1
  800049:	68 a0 15 80 00       	push   $0x8015a0
  80004e:	e8 6f 06 00 00       	call   8006c2 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 b0 15 80 00       	push   $0x8015b0
  80005c:	68 b4 15 80 00       	push   $0x8015b4
  800061:	e8 5c 06 00 00       	call   8006c2 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 c4 15 80 00       	push   $0x8015c4
  800077:	e8 46 06 00 00       	call   8006c2 <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 c8 15 80 00       	push   $0x8015c8
  80008e:	e8 2f 06 00 00       	call   8006c2 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 d2 15 80 00       	push   $0x8015d2
  8000a6:	68 b4 15 80 00       	push   $0x8015b4
  8000ab:	e8 12 06 00 00       	call   8006c2 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 c4 15 80 00       	push   $0x8015c4
  8000c3:	e8 fa 05 00 00       	call   8006c2 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 c8 15 80 00       	push   $0x8015c8
  8000d5:	e8 e8 05 00 00       	call   8006c2 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 d6 15 80 00       	push   $0x8015d6
  8000ed:	68 b4 15 80 00       	push   $0x8015b4
  8000f2:	e8 cb 05 00 00       	call   8006c2 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 c4 15 80 00       	push   $0x8015c4
  80010a:	e8 b3 05 00 00       	call   8006c2 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 c8 15 80 00       	push   $0x8015c8
  80011c:	e8 a1 05 00 00       	call   8006c2 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 da 15 80 00       	push   $0x8015da
  800134:	68 b4 15 80 00       	push   $0x8015b4
  800139:	e8 84 05 00 00       	call   8006c2 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 c4 15 80 00       	push   $0x8015c4
  800151:	e8 6c 05 00 00       	call   8006c2 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 c8 15 80 00       	push   $0x8015c8
  800163:	e8 5a 05 00 00       	call   8006c2 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 de 15 80 00       	push   $0x8015de
  80017b:	68 b4 15 80 00       	push   $0x8015b4
  800180:	e8 3d 05 00 00       	call   8006c2 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 c4 15 80 00       	push   $0x8015c4
  800198:	e8 25 05 00 00       	call   8006c2 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 c8 15 80 00       	push   $0x8015c8
  8001aa:	e8 13 05 00 00       	call   8006c2 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 e2 15 80 00       	push   $0x8015e2
  8001c2:	68 b4 15 80 00       	push   $0x8015b4
  8001c7:	e8 f6 04 00 00       	call   8006c2 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 c4 15 80 00       	push   $0x8015c4
  8001df:	e8 de 04 00 00       	call   8006c2 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 c8 15 80 00       	push   $0x8015c8
  8001f1:	e8 cc 04 00 00       	call   8006c2 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 e6 15 80 00       	push   $0x8015e6
  800209:	68 b4 15 80 00       	push   $0x8015b4
  80020e:	e8 af 04 00 00       	call   8006c2 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 c4 15 80 00       	push   $0x8015c4
  800226:	e8 97 04 00 00       	call   8006c2 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 c8 15 80 00       	push   $0x8015c8
  800238:	e8 85 04 00 00       	call   8006c2 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 ea 15 80 00       	push   $0x8015ea
  800250:	68 b4 15 80 00       	push   $0x8015b4
  800255:	e8 68 04 00 00       	call   8006c2 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 c4 15 80 00       	push   $0x8015c4
  80026d:	e8 50 04 00 00       	call   8006c2 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 c8 15 80 00       	push   $0x8015c8
  80027f:	e8 3e 04 00 00       	call   8006c2 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 ee 15 80 00       	push   $0x8015ee
  800297:	68 b4 15 80 00       	push   $0x8015b4
  80029c:	e8 21 04 00 00       	call   8006c2 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 c4 15 80 00       	push   $0x8015c4
  8002b4:	e8 09 04 00 00       	call   8006c2 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 f5 15 80 00       	push   $0x8015f5
  8002c4:	68 b4 15 80 00       	push   $0x8015b4
  8002c9:	e8 f4 03 00 00       	call   8006c2 <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 c8 15 80 00       	push   $0x8015c8
  8002e3:	e8 da 03 00 00       	call   8006c2 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 f5 15 80 00       	push   $0x8015f5
  8002f3:	68 b4 15 80 00       	push   $0x8015b4
  8002f8:	e8 c5 03 00 00       	call   8006c2 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 c4 15 80 00       	push   $0x8015c4
  800312:	e8 ab 03 00 00       	call   8006c2 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 f9 15 80 00       	push   $0x8015f9
  800322:	e8 9b 03 00 00       	call   8006c2 <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 c8 15 80 00       	push   $0x8015c8
  800338:	e8 85 03 00 00       	call   8006c2 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 f9 15 80 00       	push   $0x8015f9
  800348:	e8 75 03 00 00       	call   8006c2 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 c4 15 80 00       	push   $0x8015c4
  80035a:	e8 63 03 00 00       	call   8006c2 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 c8 15 80 00       	push   $0x8015c8
  80036c:	e8 51 03 00 00       	call   8006c2 <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 c4 15 80 00       	push   $0x8015c4
  80037e:	e8 3f 03 00 00       	call   8006c2 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 f9 15 80 00       	push   $0x8015f9
  80038e:	e8 2f 03 00 00       	call   8006c2 <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 60 16 80 00       	push   $0x801660
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 07 16 80 00       	push   $0x801607
  8003c6:	e8 1e 02 00 00       	call   8005e9 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 60 20 80 00    	mov    %edx,0x802060
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 64 20 80 00    	mov    %edx,0x802064
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 68 20 80 00    	mov    %edx,0x802068
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 70 20 80 00    	mov    %edx,0x802070
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 74 20 80 00    	mov    %edx,0x802074
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 78 20 80 00    	mov    %edx,0x802078
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  800425:	8b 40 30             	mov    0x30(%eax),%eax
  800428:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	68 1f 16 80 00       	push   $0x80161f
  800435:	68 2d 16 80 00       	push   $0x80162d
  80043a:	b9 60 20 80 00       	mov    $0x802060,%ecx
  80043f:	ba 18 16 80 00       	mov    $0x801618,%edx
  800444:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800449:	e8 e5 fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80044e:	83 c4 0c             	add    $0xc,%esp
  800451:	6a 07                	push   $0x7
  800453:	68 00 00 40 00       	push   $0x400000
  800458:	6a 00                	push   $0x0
  80045a:	e8 31 0c 00 00       	call   801090 <sys_page_alloc>
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	85 c0                	test   %eax,%eax
  800464:	79 12                	jns    800478 <pgfault+0xd8>
		panic("sys_page_alloc: %e", r);
  800466:	50                   	push   %eax
  800467:	68 34 16 80 00       	push   $0x801634
  80046c:	6a 5c                	push   $0x5c
  80046e:	68 07 16 80 00       	push   $0x801607
  800473:	e8 71 01 00 00       	call   8005e9 <_panic>
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <umain>:

void
umain(int argc, char **argv)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800480:	68 a0 03 80 00       	push   $0x8003a0
  800485:	e8 d5 0d 00 00       	call   80125f <set_pgfault_handler>

	__asm __volatile(
  80048a:	50                   	push   %eax
  80048b:	9c                   	pushf  
  80048c:	58                   	pop    %eax
  80048d:	0d d5 08 00 00       	or     $0x8d5,%eax
  800492:	50                   	push   %eax
  800493:	9d                   	popf   
  800494:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  800499:	8d 05 d4 04 80 00    	lea    0x8004d4,%eax
  80049f:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004a4:	58                   	pop    %eax
  8004a5:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004ab:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004b1:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  8004b7:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  8004bd:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8004c3:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  8004c9:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  8004ce:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  8004d4:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004db:	00 00 00 
  8004de:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004e4:	89 35 24 20 80 00    	mov    %esi,0x802024
  8004ea:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8004f0:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8004f6:	89 15 34 20 80 00    	mov    %edx,0x802034
  8004fc:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800502:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800507:	89 25 48 20 80 00    	mov    %esp,0x802048
  80050d:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800513:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  800519:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  80051f:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  800525:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  80052b:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  800531:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  800536:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  80053c:	50                   	push   %eax
  80053d:	9c                   	pushf  
  80053e:	58                   	pop    %eax
  80053f:	a3 44 20 80 00       	mov    %eax,0x802044
  800544:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80054f:	74 10                	je     800561 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	68 94 16 80 00       	push   $0x801694
  800559:	e8 64 01 00 00       	call   8006c2 <cprintf>
  80055e:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800561:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  800566:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	68 47 16 80 00       	push   $0x801647
  800573:	68 58 16 80 00       	push   $0x801658
  800578:	b9 20 20 80 00       	mov    $0x802020,%ecx
  80057d:	ba 18 16 80 00       	mov    $0x801618,%edx
  800582:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800587:	e8 a7 fa ff ff       	call   800033 <check_regs>
}
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	c9                   	leave  
  800590:	c3                   	ret    

00800591 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800599:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  80059c:	e8 b1 0a 00 00       	call   801052 <sys_getenvid>
  8005a1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005a6:	c1 e0 07             	shl    $0x7,%eax
  8005a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005ae:	a3 cc 20 80 00       	mov    %eax,0x8020cc
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b3:	85 db                	test   %ebx,%ebx
  8005b5:	7e 07                	jle    8005be <libmain+0x2d>
		binaryname = argv[0];
  8005b7:	8b 06                	mov    (%esi),%eax
  8005b9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	56                   	push   %esi
  8005c2:	53                   	push   %ebx
  8005c3:	e8 b2 fe ff ff       	call   80047a <umain>

	// exit gracefully
	exit();
  8005c8:	e8 0a 00 00 00       	call   8005d7 <exit>
}
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d3:	5b                   	pop    %ebx
  8005d4:	5e                   	pop    %esi
  8005d5:	5d                   	pop    %ebp
  8005d6:	c3                   	ret    

008005d7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005d7:	55                   	push   %ebp
  8005d8:	89 e5                	mov    %esp,%ebp
  8005da:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8005dd:	6a 00                	push   $0x0
  8005df:	e8 2d 0a 00 00       	call   801011 <sys_env_destroy>
}
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	c9                   	leave  
  8005e8:	c3                   	ret    

008005e9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005e9:	55                   	push   %ebp
  8005ea:	89 e5                	mov    %esp,%ebp
  8005ec:	56                   	push   %esi
  8005ed:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005ee:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005f1:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8005f7:	e8 56 0a 00 00       	call   801052 <sys_getenvid>
  8005fc:	83 ec 0c             	sub    $0xc,%esp
  8005ff:	ff 75 0c             	pushl  0xc(%ebp)
  800602:	ff 75 08             	pushl  0x8(%ebp)
  800605:	56                   	push   %esi
  800606:	50                   	push   %eax
  800607:	68 c0 16 80 00       	push   $0x8016c0
  80060c:	e8 b1 00 00 00       	call   8006c2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800611:	83 c4 18             	add    $0x18,%esp
  800614:	53                   	push   %ebx
  800615:	ff 75 10             	pushl  0x10(%ebp)
  800618:	e8 54 00 00 00       	call   800671 <vcprintf>
	cprintf("\n");
  80061d:	c7 04 24 d0 15 80 00 	movl   $0x8015d0,(%esp)
  800624:	e8 99 00 00 00       	call   8006c2 <cprintf>
  800629:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80062c:	cc                   	int3   
  80062d:	eb fd                	jmp    80062c <_panic+0x43>

0080062f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	53                   	push   %ebx
  800633:	83 ec 04             	sub    $0x4,%esp
  800636:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800639:	8b 13                	mov    (%ebx),%edx
  80063b:	8d 42 01             	lea    0x1(%edx),%eax
  80063e:	89 03                	mov    %eax,(%ebx)
  800640:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800643:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800647:	3d ff 00 00 00       	cmp    $0xff,%eax
  80064c:	75 1a                	jne    800668 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	68 ff 00 00 00       	push   $0xff
  800656:	8d 43 08             	lea    0x8(%ebx),%eax
  800659:	50                   	push   %eax
  80065a:	e8 75 09 00 00       	call   800fd4 <sys_cputs>
		b->idx = 0;
  80065f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800665:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800668:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80066c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80066f:	c9                   	leave  
  800670:	c3                   	ret    

00800671 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800671:	55                   	push   %ebp
  800672:	89 e5                	mov    %esp,%ebp
  800674:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80067a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800681:	00 00 00 
	b.cnt = 0;
  800684:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80068b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80068e:	ff 75 0c             	pushl  0xc(%ebp)
  800691:	ff 75 08             	pushl  0x8(%ebp)
  800694:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80069a:	50                   	push   %eax
  80069b:	68 2f 06 80 00       	push   $0x80062f
  8006a0:	e8 54 01 00 00       	call   8007f9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006a5:	83 c4 08             	add    $0x8,%esp
  8006a8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006ae:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006b4:	50                   	push   %eax
  8006b5:	e8 1a 09 00 00       	call   800fd4 <sys_cputs>

	return b.cnt;
}
  8006ba:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006c0:	c9                   	leave  
  8006c1:	c3                   	ret    

008006c2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006c8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006cb:	50                   	push   %eax
  8006cc:	ff 75 08             	pushl  0x8(%ebp)
  8006cf:	e8 9d ff ff ff       	call   800671 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006d4:	c9                   	leave  
  8006d5:	c3                   	ret    

008006d6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	57                   	push   %edi
  8006da:	56                   	push   %esi
  8006db:	53                   	push   %ebx
  8006dc:	83 ec 1c             	sub    $0x1c,%esp
  8006df:	89 c7                	mov    %eax,%edi
  8006e1:	89 d6                	mov    %edx,%esi
  8006e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8006f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006fa:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006fd:	39 d3                	cmp    %edx,%ebx
  8006ff:	72 05                	jb     800706 <printnum+0x30>
  800701:	39 45 10             	cmp    %eax,0x10(%ebp)
  800704:	77 45                	ja     80074b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800706:	83 ec 0c             	sub    $0xc,%esp
  800709:	ff 75 18             	pushl  0x18(%ebp)
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800712:	53                   	push   %ebx
  800713:	ff 75 10             	pushl  0x10(%ebp)
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	ff 75 e4             	pushl  -0x1c(%ebp)
  80071c:	ff 75 e0             	pushl  -0x20(%ebp)
  80071f:	ff 75 dc             	pushl  -0x24(%ebp)
  800722:	ff 75 d8             	pushl  -0x28(%ebp)
  800725:	e8 d6 0b 00 00       	call   801300 <__udivdi3>
  80072a:	83 c4 18             	add    $0x18,%esp
  80072d:	52                   	push   %edx
  80072e:	50                   	push   %eax
  80072f:	89 f2                	mov    %esi,%edx
  800731:	89 f8                	mov    %edi,%eax
  800733:	e8 9e ff ff ff       	call   8006d6 <printnum>
  800738:	83 c4 20             	add    $0x20,%esp
  80073b:	eb 18                	jmp    800755 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	56                   	push   %esi
  800741:	ff 75 18             	pushl  0x18(%ebp)
  800744:	ff d7                	call   *%edi
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	eb 03                	jmp    80074e <printnum+0x78>
  80074b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80074e:	83 eb 01             	sub    $0x1,%ebx
  800751:	85 db                	test   %ebx,%ebx
  800753:	7f e8                	jg     80073d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800755:	83 ec 08             	sub    $0x8,%esp
  800758:	56                   	push   %esi
  800759:	83 ec 04             	sub    $0x4,%esp
  80075c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80075f:	ff 75 e0             	pushl  -0x20(%ebp)
  800762:	ff 75 dc             	pushl  -0x24(%ebp)
  800765:	ff 75 d8             	pushl  -0x28(%ebp)
  800768:	e8 c3 0c 00 00       	call   801430 <__umoddi3>
  80076d:	83 c4 14             	add    $0x14,%esp
  800770:	0f be 80 e3 16 80 00 	movsbl 0x8016e3(%eax),%eax
  800777:	50                   	push   %eax
  800778:	ff d7                	call   *%edi
}
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800780:	5b                   	pop    %ebx
  800781:	5e                   	pop    %esi
  800782:	5f                   	pop    %edi
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800788:	83 fa 01             	cmp    $0x1,%edx
  80078b:	7e 0e                	jle    80079b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80078d:	8b 10                	mov    (%eax),%edx
  80078f:	8d 4a 08             	lea    0x8(%edx),%ecx
  800792:	89 08                	mov    %ecx,(%eax)
  800794:	8b 02                	mov    (%edx),%eax
  800796:	8b 52 04             	mov    0x4(%edx),%edx
  800799:	eb 22                	jmp    8007bd <getuint+0x38>
	else if (lflag)
  80079b:	85 d2                	test   %edx,%edx
  80079d:	74 10                	je     8007af <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80079f:	8b 10                	mov    (%eax),%edx
  8007a1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007a4:	89 08                	mov    %ecx,(%eax)
  8007a6:	8b 02                	mov    (%edx),%eax
  8007a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ad:	eb 0e                	jmp    8007bd <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007af:	8b 10                	mov    (%eax),%edx
  8007b1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b4:	89 08                	mov    %ecx,(%eax)
  8007b6:	8b 02                	mov    (%edx),%eax
  8007b8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007c9:	8b 10                	mov    (%eax),%edx
  8007cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8007ce:	73 0a                	jae    8007da <sprintputch+0x1b>
		*b->buf++ = ch;
  8007d0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007d3:	89 08                	mov    %ecx,(%eax)
  8007d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d8:	88 02                	mov    %al,(%edx)
}
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007e2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007e5:	50                   	push   %eax
  8007e6:	ff 75 10             	pushl  0x10(%ebp)
  8007e9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ec:	ff 75 08             	pushl  0x8(%ebp)
  8007ef:	e8 05 00 00 00       	call   8007f9 <vprintfmt>
	va_end(ap);
}
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    

008007f9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	57                   	push   %edi
  8007fd:	56                   	push   %esi
  8007fe:	53                   	push   %ebx
  8007ff:	83 ec 2c             	sub    $0x2c,%esp
  800802:	8b 75 08             	mov    0x8(%ebp),%esi
  800805:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800808:	8b 7d 10             	mov    0x10(%ebp),%edi
  80080b:	eb 1d                	jmp    80082a <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80080d:	85 c0                	test   %eax,%eax
  80080f:	75 0f                	jne    800820 <vprintfmt+0x27>
				csa = 0x0700;
  800811:	c7 05 d0 20 80 00 00 	movl   $0x700,0x8020d0
  800818:	07 00 00 
				return;
  80081b:	e9 c4 03 00 00       	jmp    800be4 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800820:	83 ec 08             	sub    $0x8,%esp
  800823:	53                   	push   %ebx
  800824:	50                   	push   %eax
  800825:	ff d6                	call   *%esi
  800827:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80082a:	83 c7 01             	add    $0x1,%edi
  80082d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800831:	83 f8 25             	cmp    $0x25,%eax
  800834:	75 d7                	jne    80080d <vprintfmt+0x14>
  800836:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80083a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800841:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800848:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80084f:	ba 00 00 00 00       	mov    $0x0,%edx
  800854:	eb 07                	jmp    80085d <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800856:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800859:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085d:	8d 47 01             	lea    0x1(%edi),%eax
  800860:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800863:	0f b6 07             	movzbl (%edi),%eax
  800866:	0f b6 c8             	movzbl %al,%ecx
  800869:	83 e8 23             	sub    $0x23,%eax
  80086c:	3c 55                	cmp    $0x55,%al
  80086e:	0f 87 55 03 00 00    	ja     800bc9 <vprintfmt+0x3d0>
  800874:	0f b6 c0             	movzbl %al,%eax
  800877:	ff 24 85 a0 17 80 00 	jmp    *0x8017a0(,%eax,4)
  80087e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800881:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800885:	eb d6                	jmp    80085d <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800887:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088a:	b8 00 00 00 00       	mov    $0x0,%eax
  80088f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800892:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800895:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800899:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80089c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80089f:	83 fa 09             	cmp    $0x9,%edx
  8008a2:	77 39                	ja     8008dd <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008a4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008a7:	eb e9                	jmp    800892 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ac:	8d 48 04             	lea    0x4(%eax),%ecx
  8008af:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008b2:	8b 00                	mov    (%eax),%eax
  8008b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008ba:	eb 27                	jmp    8008e3 <vprintfmt+0xea>
  8008bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008bf:	85 c0                	test   %eax,%eax
  8008c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c6:	0f 49 c8             	cmovns %eax,%ecx
  8008c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008cf:	eb 8c                	jmp    80085d <vprintfmt+0x64>
  8008d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008d4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008db:	eb 80                	jmp    80085d <vprintfmt+0x64>
  8008dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008e0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008e3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008e7:	0f 89 70 ff ff ff    	jns    80085d <vprintfmt+0x64>
				width = precision, precision = -1;
  8008ed:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008f3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008fa:	e9 5e ff ff ff       	jmp    80085d <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008ff:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800902:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800905:	e9 53 ff ff ff       	jmp    80085d <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80090a:	8b 45 14             	mov    0x14(%ebp),%eax
  80090d:	8d 50 04             	lea    0x4(%eax),%edx
  800910:	89 55 14             	mov    %edx,0x14(%ebp)
  800913:	83 ec 08             	sub    $0x8,%esp
  800916:	53                   	push   %ebx
  800917:	ff 30                	pushl  (%eax)
  800919:	ff d6                	call   *%esi
			break;
  80091b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800921:	e9 04 ff ff ff       	jmp    80082a <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800926:	8b 45 14             	mov    0x14(%ebp),%eax
  800929:	8d 50 04             	lea    0x4(%eax),%edx
  80092c:	89 55 14             	mov    %edx,0x14(%ebp)
  80092f:	8b 00                	mov    (%eax),%eax
  800931:	99                   	cltd   
  800932:	31 d0                	xor    %edx,%eax
  800934:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800936:	83 f8 08             	cmp    $0x8,%eax
  800939:	7f 0b                	jg     800946 <vprintfmt+0x14d>
  80093b:	8b 14 85 00 19 80 00 	mov    0x801900(,%eax,4),%edx
  800942:	85 d2                	test   %edx,%edx
  800944:	75 18                	jne    80095e <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  800946:	50                   	push   %eax
  800947:	68 fb 16 80 00       	push   $0x8016fb
  80094c:	53                   	push   %ebx
  80094d:	56                   	push   %esi
  80094e:	e8 89 fe ff ff       	call   8007dc <printfmt>
  800953:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800956:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800959:	e9 cc fe ff ff       	jmp    80082a <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80095e:	52                   	push   %edx
  80095f:	68 04 17 80 00       	push   $0x801704
  800964:	53                   	push   %ebx
  800965:	56                   	push   %esi
  800966:	e8 71 fe ff ff       	call   8007dc <printfmt>
  80096b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800971:	e9 b4 fe ff ff       	jmp    80082a <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800976:	8b 45 14             	mov    0x14(%ebp),%eax
  800979:	8d 50 04             	lea    0x4(%eax),%edx
  80097c:	89 55 14             	mov    %edx,0x14(%ebp)
  80097f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800981:	85 ff                	test   %edi,%edi
  800983:	b8 f4 16 80 00       	mov    $0x8016f4,%eax
  800988:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80098b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80098f:	0f 8e 94 00 00 00    	jle    800a29 <vprintfmt+0x230>
  800995:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800999:	0f 84 98 00 00 00    	je     800a37 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80099f:	83 ec 08             	sub    $0x8,%esp
  8009a2:	ff 75 d0             	pushl  -0x30(%ebp)
  8009a5:	57                   	push   %edi
  8009a6:	e8 c1 02 00 00       	call   800c6c <strnlen>
  8009ab:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009ae:	29 c1                	sub    %eax,%ecx
  8009b0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009b3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009b6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009bd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009c0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c2:	eb 0f                	jmp    8009d3 <vprintfmt+0x1da>
					putch(padc, putdat);
  8009c4:	83 ec 08             	sub    $0x8,%esp
  8009c7:	53                   	push   %ebx
  8009c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8009cb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009cd:	83 ef 01             	sub    $0x1,%edi
  8009d0:	83 c4 10             	add    $0x10,%esp
  8009d3:	85 ff                	test   %edi,%edi
  8009d5:	7f ed                	jg     8009c4 <vprintfmt+0x1cb>
  8009d7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009da:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009dd:	85 c9                	test   %ecx,%ecx
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e4:	0f 49 c1             	cmovns %ecx,%eax
  8009e7:	29 c1                	sub    %eax,%ecx
  8009e9:	89 75 08             	mov    %esi,0x8(%ebp)
  8009ec:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009ef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009f2:	89 cb                	mov    %ecx,%ebx
  8009f4:	eb 4d                	jmp    800a43 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009fa:	74 1b                	je     800a17 <vprintfmt+0x21e>
  8009fc:	0f be c0             	movsbl %al,%eax
  8009ff:	83 e8 20             	sub    $0x20,%eax
  800a02:	83 f8 5e             	cmp    $0x5e,%eax
  800a05:	76 10                	jbe    800a17 <vprintfmt+0x21e>
					putch('?', putdat);
  800a07:	83 ec 08             	sub    $0x8,%esp
  800a0a:	ff 75 0c             	pushl  0xc(%ebp)
  800a0d:	6a 3f                	push   $0x3f
  800a0f:	ff 55 08             	call   *0x8(%ebp)
  800a12:	83 c4 10             	add    $0x10,%esp
  800a15:	eb 0d                	jmp    800a24 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800a17:	83 ec 08             	sub    $0x8,%esp
  800a1a:	ff 75 0c             	pushl  0xc(%ebp)
  800a1d:	52                   	push   %edx
  800a1e:	ff 55 08             	call   *0x8(%ebp)
  800a21:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a24:	83 eb 01             	sub    $0x1,%ebx
  800a27:	eb 1a                	jmp    800a43 <vprintfmt+0x24a>
  800a29:	89 75 08             	mov    %esi,0x8(%ebp)
  800a2c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a2f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a32:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a35:	eb 0c                	jmp    800a43 <vprintfmt+0x24a>
  800a37:	89 75 08             	mov    %esi,0x8(%ebp)
  800a3a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a3d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a40:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a43:	83 c7 01             	add    $0x1,%edi
  800a46:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a4a:	0f be d0             	movsbl %al,%edx
  800a4d:	85 d2                	test   %edx,%edx
  800a4f:	74 23                	je     800a74 <vprintfmt+0x27b>
  800a51:	85 f6                	test   %esi,%esi
  800a53:	78 a1                	js     8009f6 <vprintfmt+0x1fd>
  800a55:	83 ee 01             	sub    $0x1,%esi
  800a58:	79 9c                	jns    8009f6 <vprintfmt+0x1fd>
  800a5a:	89 df                	mov    %ebx,%edi
  800a5c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a62:	eb 18                	jmp    800a7c <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a64:	83 ec 08             	sub    $0x8,%esp
  800a67:	53                   	push   %ebx
  800a68:	6a 20                	push   $0x20
  800a6a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a6c:	83 ef 01             	sub    $0x1,%edi
  800a6f:	83 c4 10             	add    $0x10,%esp
  800a72:	eb 08                	jmp    800a7c <vprintfmt+0x283>
  800a74:	89 df                	mov    %ebx,%edi
  800a76:	8b 75 08             	mov    0x8(%ebp),%esi
  800a79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7c:	85 ff                	test   %edi,%edi
  800a7e:	7f e4                	jg     800a64 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a80:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a83:	e9 a2 fd ff ff       	jmp    80082a <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a88:	83 fa 01             	cmp    $0x1,%edx
  800a8b:	7e 16                	jle    800aa3 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  800a8d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a90:	8d 50 08             	lea    0x8(%eax),%edx
  800a93:	89 55 14             	mov    %edx,0x14(%ebp)
  800a96:	8b 50 04             	mov    0x4(%eax),%edx
  800a99:	8b 00                	mov    (%eax),%eax
  800a9b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a9e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aa1:	eb 32                	jmp    800ad5 <vprintfmt+0x2dc>
	else if (lflag)
  800aa3:	85 d2                	test   %edx,%edx
  800aa5:	74 18                	je     800abf <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  800aa7:	8b 45 14             	mov    0x14(%ebp),%eax
  800aaa:	8d 50 04             	lea    0x4(%eax),%edx
  800aad:	89 55 14             	mov    %edx,0x14(%ebp)
  800ab0:	8b 00                	mov    (%eax),%eax
  800ab2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ab5:	89 c1                	mov    %eax,%ecx
  800ab7:	c1 f9 1f             	sar    $0x1f,%ecx
  800aba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800abd:	eb 16                	jmp    800ad5 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800abf:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac2:	8d 50 04             	lea    0x4(%eax),%edx
  800ac5:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac8:	8b 00                	mov    (%eax),%eax
  800aca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800acd:	89 c1                	mov    %eax,%ecx
  800acf:	c1 f9 1f             	sar    $0x1f,%ecx
  800ad2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ad8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800adb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ae0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ae4:	79 74                	jns    800b5a <vprintfmt+0x361>
				putch('-', putdat);
  800ae6:	83 ec 08             	sub    $0x8,%esp
  800ae9:	53                   	push   %ebx
  800aea:	6a 2d                	push   $0x2d
  800aec:	ff d6                	call   *%esi
				num = -(long long) num;
  800aee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800af1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800af4:	f7 d8                	neg    %eax
  800af6:	83 d2 00             	adc    $0x0,%edx
  800af9:	f7 da                	neg    %edx
  800afb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800afe:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b03:	eb 55                	jmp    800b5a <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b05:	8d 45 14             	lea    0x14(%ebp),%eax
  800b08:	e8 78 fc ff ff       	call   800785 <getuint>
			base = 10;
  800b0d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b12:	eb 46                	jmp    800b5a <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800b14:	8d 45 14             	lea    0x14(%ebp),%eax
  800b17:	e8 69 fc ff ff       	call   800785 <getuint>
      base = 8;
  800b1c:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800b21:	eb 37                	jmp    800b5a <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800b23:	83 ec 08             	sub    $0x8,%esp
  800b26:	53                   	push   %ebx
  800b27:	6a 30                	push   $0x30
  800b29:	ff d6                	call   *%esi
			putch('x', putdat);
  800b2b:	83 c4 08             	add    $0x8,%esp
  800b2e:	53                   	push   %ebx
  800b2f:	6a 78                	push   $0x78
  800b31:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b33:	8b 45 14             	mov    0x14(%ebp),%eax
  800b36:	8d 50 04             	lea    0x4(%eax),%edx
  800b39:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b3c:	8b 00                	mov    (%eax),%eax
  800b3e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b43:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b46:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b4b:	eb 0d                	jmp    800b5a <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b4d:	8d 45 14             	lea    0x14(%ebp),%eax
  800b50:	e8 30 fc ff ff       	call   800785 <getuint>
			base = 16;
  800b55:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b61:	57                   	push   %edi
  800b62:	ff 75 e0             	pushl  -0x20(%ebp)
  800b65:	51                   	push   %ecx
  800b66:	52                   	push   %edx
  800b67:	50                   	push   %eax
  800b68:	89 da                	mov    %ebx,%edx
  800b6a:	89 f0                	mov    %esi,%eax
  800b6c:	e8 65 fb ff ff       	call   8006d6 <printnum>
			break;
  800b71:	83 c4 20             	add    $0x20,%esp
  800b74:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b77:	e9 ae fc ff ff       	jmp    80082a <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b7c:	83 ec 08             	sub    $0x8,%esp
  800b7f:	53                   	push   %ebx
  800b80:	51                   	push   %ecx
  800b81:	ff d6                	call   *%esi
			break;
  800b83:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b86:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b89:	e9 9c fc ff ff       	jmp    80082a <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b8e:	83 fa 01             	cmp    $0x1,%edx
  800b91:	7e 0d                	jle    800ba0 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  800b93:	8b 45 14             	mov    0x14(%ebp),%eax
  800b96:	8d 50 08             	lea    0x8(%eax),%edx
  800b99:	89 55 14             	mov    %edx,0x14(%ebp)
  800b9c:	8b 00                	mov    (%eax),%eax
  800b9e:	eb 1c                	jmp    800bbc <vprintfmt+0x3c3>
	else if (lflag)
  800ba0:	85 d2                	test   %edx,%edx
  800ba2:	74 0d                	je     800bb1 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  800ba4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba7:	8d 50 04             	lea    0x4(%eax),%edx
  800baa:	89 55 14             	mov    %edx,0x14(%ebp)
  800bad:	8b 00                	mov    (%eax),%eax
  800baf:	eb 0b                	jmp    800bbc <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  800bb1:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb4:	8d 50 04             	lea    0x4(%eax),%edx
  800bb7:	89 55 14             	mov    %edx,0x14(%ebp)
  800bba:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  800bbc:	a3 d0 20 80 00       	mov    %eax,0x8020d0
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bc1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  800bc4:	e9 61 fc ff ff       	jmp    80082a <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bc9:	83 ec 08             	sub    $0x8,%esp
  800bcc:	53                   	push   %ebx
  800bcd:	6a 25                	push   $0x25
  800bcf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bd1:	83 c4 10             	add    $0x10,%esp
  800bd4:	eb 03                	jmp    800bd9 <vprintfmt+0x3e0>
  800bd6:	83 ef 01             	sub    $0x1,%edi
  800bd9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800bdd:	75 f7                	jne    800bd6 <vprintfmt+0x3dd>
  800bdf:	e9 46 fc ff ff       	jmp    80082a <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800be4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	83 ec 18             	sub    $0x18,%esp
  800bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bf8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bfb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bff:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c02:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c09:	85 c0                	test   %eax,%eax
  800c0b:	74 26                	je     800c33 <vsnprintf+0x47>
  800c0d:	85 d2                	test   %edx,%edx
  800c0f:	7e 22                	jle    800c33 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c11:	ff 75 14             	pushl  0x14(%ebp)
  800c14:	ff 75 10             	pushl  0x10(%ebp)
  800c17:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c1a:	50                   	push   %eax
  800c1b:	68 bf 07 80 00       	push   $0x8007bf
  800c20:	e8 d4 fb ff ff       	call   8007f9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c25:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c28:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c2e:	83 c4 10             	add    $0x10,%esp
  800c31:	eb 05                	jmp    800c38 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c38:	c9                   	leave  
  800c39:	c3                   	ret    

00800c3a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c40:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c43:	50                   	push   %eax
  800c44:	ff 75 10             	pushl  0x10(%ebp)
  800c47:	ff 75 0c             	pushl  0xc(%ebp)
  800c4a:	ff 75 08             	pushl  0x8(%ebp)
  800c4d:	e8 9a ff ff ff       	call   800bec <vsnprintf>
	va_end(ap);

	return rc;
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5f:	eb 03                	jmp    800c64 <strlen+0x10>
		n++;
  800c61:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c64:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c68:	75 f7                	jne    800c61 <strlen+0xd>
		n++;
	return n;
}
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    

00800c6c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c72:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c75:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7a:	eb 03                	jmp    800c7f <strnlen+0x13>
		n++;
  800c7c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c7f:	39 c2                	cmp    %eax,%edx
  800c81:	74 08                	je     800c8b <strnlen+0x1f>
  800c83:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c87:	75 f3                	jne    800c7c <strnlen+0x10>
  800c89:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	53                   	push   %ebx
  800c91:	8b 45 08             	mov    0x8(%ebp),%eax
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c97:	89 c2                	mov    %eax,%edx
  800c99:	83 c2 01             	add    $0x1,%edx
  800c9c:	83 c1 01             	add    $0x1,%ecx
  800c9f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ca3:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ca6:	84 db                	test   %bl,%bl
  800ca8:	75 ef                	jne    800c99 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800caa:	5b                   	pop    %ebx
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	53                   	push   %ebx
  800cb1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cb4:	53                   	push   %ebx
  800cb5:	e8 9a ff ff ff       	call   800c54 <strlen>
  800cba:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800cbd:	ff 75 0c             	pushl  0xc(%ebp)
  800cc0:	01 d8                	add    %ebx,%eax
  800cc2:	50                   	push   %eax
  800cc3:	e8 c5 ff ff ff       	call   800c8d <strcpy>
	return dst;
}
  800cc8:	89 d8                	mov    %ebx,%eax
  800cca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ccd:	c9                   	leave  
  800cce:	c3                   	ret    

00800ccf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	8b 75 08             	mov    0x8(%ebp),%esi
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	89 f3                	mov    %esi,%ebx
  800cdc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cdf:	89 f2                	mov    %esi,%edx
  800ce1:	eb 0f                	jmp    800cf2 <strncpy+0x23>
		*dst++ = *src;
  800ce3:	83 c2 01             	add    $0x1,%edx
  800ce6:	0f b6 01             	movzbl (%ecx),%eax
  800ce9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cec:	80 39 01             	cmpb   $0x1,(%ecx)
  800cef:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cf2:	39 da                	cmp    %ebx,%edx
  800cf4:	75 ed                	jne    800ce3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cf6:	89 f0                	mov    %esi,%eax
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	8b 75 08             	mov    0x8(%ebp),%esi
  800d04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d07:	8b 55 10             	mov    0x10(%ebp),%edx
  800d0a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d0c:	85 d2                	test   %edx,%edx
  800d0e:	74 21                	je     800d31 <strlcpy+0x35>
  800d10:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d14:	89 f2                	mov    %esi,%edx
  800d16:	eb 09                	jmp    800d21 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d18:	83 c2 01             	add    $0x1,%edx
  800d1b:	83 c1 01             	add    $0x1,%ecx
  800d1e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d21:	39 c2                	cmp    %eax,%edx
  800d23:	74 09                	je     800d2e <strlcpy+0x32>
  800d25:	0f b6 19             	movzbl (%ecx),%ebx
  800d28:	84 db                	test   %bl,%bl
  800d2a:	75 ec                	jne    800d18 <strlcpy+0x1c>
  800d2c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d2e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d31:	29 f0                	sub    %esi,%eax
}
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d40:	eb 06                	jmp    800d48 <strcmp+0x11>
		p++, q++;
  800d42:	83 c1 01             	add    $0x1,%ecx
  800d45:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d48:	0f b6 01             	movzbl (%ecx),%eax
  800d4b:	84 c0                	test   %al,%al
  800d4d:	74 04                	je     800d53 <strcmp+0x1c>
  800d4f:	3a 02                	cmp    (%edx),%al
  800d51:	74 ef                	je     800d42 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d53:	0f b6 c0             	movzbl %al,%eax
  800d56:	0f b6 12             	movzbl (%edx),%edx
  800d59:	29 d0                	sub    %edx,%eax
}
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	53                   	push   %ebx
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
  800d64:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d67:	89 c3                	mov    %eax,%ebx
  800d69:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d6c:	eb 06                	jmp    800d74 <strncmp+0x17>
		n--, p++, q++;
  800d6e:	83 c0 01             	add    $0x1,%eax
  800d71:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d74:	39 d8                	cmp    %ebx,%eax
  800d76:	74 15                	je     800d8d <strncmp+0x30>
  800d78:	0f b6 08             	movzbl (%eax),%ecx
  800d7b:	84 c9                	test   %cl,%cl
  800d7d:	74 04                	je     800d83 <strncmp+0x26>
  800d7f:	3a 0a                	cmp    (%edx),%cl
  800d81:	74 eb                	je     800d6e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d83:	0f b6 00             	movzbl (%eax),%eax
  800d86:	0f b6 12             	movzbl (%edx),%edx
  800d89:	29 d0                	sub    %edx,%eax
  800d8b:	eb 05                	jmp    800d92 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d8d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d92:	5b                   	pop    %ebx
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d9f:	eb 07                	jmp    800da8 <strchr+0x13>
		if (*s == c)
  800da1:	38 ca                	cmp    %cl,%dl
  800da3:	74 0f                	je     800db4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800da5:	83 c0 01             	add    $0x1,%eax
  800da8:	0f b6 10             	movzbl (%eax),%edx
  800dab:	84 d2                	test   %dl,%dl
  800dad:	75 f2                	jne    800da1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800daf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800dc0:	eb 03                	jmp    800dc5 <strfind+0xf>
  800dc2:	83 c0 01             	add    $0x1,%eax
  800dc5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800dc8:	38 ca                	cmp    %cl,%dl
  800dca:	74 04                	je     800dd0 <strfind+0x1a>
  800dcc:	84 d2                	test   %dl,%dl
  800dce:	75 f2                	jne    800dc2 <strfind+0xc>
			break;
	return (char *) s;
}
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ddb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800dde:	85 c9                	test   %ecx,%ecx
  800de0:	74 36                	je     800e18 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800de2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800de8:	75 28                	jne    800e12 <memset+0x40>
  800dea:	f6 c1 03             	test   $0x3,%cl
  800ded:	75 23                	jne    800e12 <memset+0x40>
		c &= 0xFF;
  800def:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800df3:	89 d3                	mov    %edx,%ebx
  800df5:	c1 e3 08             	shl    $0x8,%ebx
  800df8:	89 d6                	mov    %edx,%esi
  800dfa:	c1 e6 18             	shl    $0x18,%esi
  800dfd:	89 d0                	mov    %edx,%eax
  800dff:	c1 e0 10             	shl    $0x10,%eax
  800e02:	09 f0                	or     %esi,%eax
  800e04:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e06:	89 d8                	mov    %ebx,%eax
  800e08:	09 d0                	or     %edx,%eax
  800e0a:	c1 e9 02             	shr    $0x2,%ecx
  800e0d:	fc                   	cld    
  800e0e:	f3 ab                	rep stos %eax,%es:(%edi)
  800e10:	eb 06                	jmp    800e18 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e15:	fc                   	cld    
  800e16:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e18:	89 f8                	mov    %edi,%eax
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	8b 45 08             	mov    0x8(%ebp),%eax
  800e27:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e2d:	39 c6                	cmp    %eax,%esi
  800e2f:	73 35                	jae    800e66 <memmove+0x47>
  800e31:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e34:	39 d0                	cmp    %edx,%eax
  800e36:	73 2e                	jae    800e66 <memmove+0x47>
		s += n;
		d += n;
  800e38:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e3b:	89 d6                	mov    %edx,%esi
  800e3d:	09 fe                	or     %edi,%esi
  800e3f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e45:	75 13                	jne    800e5a <memmove+0x3b>
  800e47:	f6 c1 03             	test   $0x3,%cl
  800e4a:	75 0e                	jne    800e5a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e4c:	83 ef 04             	sub    $0x4,%edi
  800e4f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e52:	c1 e9 02             	shr    $0x2,%ecx
  800e55:	fd                   	std    
  800e56:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e58:	eb 09                	jmp    800e63 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e5a:	83 ef 01             	sub    $0x1,%edi
  800e5d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e60:	fd                   	std    
  800e61:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e63:	fc                   	cld    
  800e64:	eb 1d                	jmp    800e83 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e66:	89 f2                	mov    %esi,%edx
  800e68:	09 c2                	or     %eax,%edx
  800e6a:	f6 c2 03             	test   $0x3,%dl
  800e6d:	75 0f                	jne    800e7e <memmove+0x5f>
  800e6f:	f6 c1 03             	test   $0x3,%cl
  800e72:	75 0a                	jne    800e7e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e74:	c1 e9 02             	shr    $0x2,%ecx
  800e77:	89 c7                	mov    %eax,%edi
  800e79:	fc                   	cld    
  800e7a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e7c:	eb 05                	jmp    800e83 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e7e:	89 c7                	mov    %eax,%edi
  800e80:	fc                   	cld    
  800e81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e83:	5e                   	pop    %esi
  800e84:	5f                   	pop    %edi
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    

00800e87 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e8a:	ff 75 10             	pushl  0x10(%ebp)
  800e8d:	ff 75 0c             	pushl  0xc(%ebp)
  800e90:	ff 75 08             	pushl  0x8(%ebp)
  800e93:	e8 87 ff ff ff       	call   800e1f <memmove>
}
  800e98:	c9                   	leave  
  800e99:	c3                   	ret    

00800e9a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	56                   	push   %esi
  800e9e:	53                   	push   %ebx
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea5:	89 c6                	mov    %eax,%esi
  800ea7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eaa:	eb 1a                	jmp    800ec6 <memcmp+0x2c>
		if (*s1 != *s2)
  800eac:	0f b6 08             	movzbl (%eax),%ecx
  800eaf:	0f b6 1a             	movzbl (%edx),%ebx
  800eb2:	38 d9                	cmp    %bl,%cl
  800eb4:	74 0a                	je     800ec0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800eb6:	0f b6 c1             	movzbl %cl,%eax
  800eb9:	0f b6 db             	movzbl %bl,%ebx
  800ebc:	29 d8                	sub    %ebx,%eax
  800ebe:	eb 0f                	jmp    800ecf <memcmp+0x35>
		s1++, s2++;
  800ec0:	83 c0 01             	add    $0x1,%eax
  800ec3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ec6:	39 f0                	cmp    %esi,%eax
  800ec8:	75 e2                	jne    800eac <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800eca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	53                   	push   %ebx
  800ed7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800eda:	89 c1                	mov    %eax,%ecx
  800edc:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800edf:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ee3:	eb 0a                	jmp    800eef <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ee5:	0f b6 10             	movzbl (%eax),%edx
  800ee8:	39 da                	cmp    %ebx,%edx
  800eea:	74 07                	je     800ef3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eec:	83 c0 01             	add    $0x1,%eax
  800eef:	39 c8                	cmp    %ecx,%eax
  800ef1:	72 f2                	jb     800ee5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ef3:	5b                   	pop    %ebx
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    

00800ef6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	57                   	push   %edi
  800efa:	56                   	push   %esi
  800efb:	53                   	push   %ebx
  800efc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f02:	eb 03                	jmp    800f07 <strtol+0x11>
		s++;
  800f04:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f07:	0f b6 01             	movzbl (%ecx),%eax
  800f0a:	3c 20                	cmp    $0x20,%al
  800f0c:	74 f6                	je     800f04 <strtol+0xe>
  800f0e:	3c 09                	cmp    $0x9,%al
  800f10:	74 f2                	je     800f04 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f12:	3c 2b                	cmp    $0x2b,%al
  800f14:	75 0a                	jne    800f20 <strtol+0x2a>
		s++;
  800f16:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f19:	bf 00 00 00 00       	mov    $0x0,%edi
  800f1e:	eb 11                	jmp    800f31 <strtol+0x3b>
  800f20:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f25:	3c 2d                	cmp    $0x2d,%al
  800f27:	75 08                	jne    800f31 <strtol+0x3b>
		s++, neg = 1;
  800f29:	83 c1 01             	add    $0x1,%ecx
  800f2c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f31:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f37:	75 15                	jne    800f4e <strtol+0x58>
  800f39:	80 39 30             	cmpb   $0x30,(%ecx)
  800f3c:	75 10                	jne    800f4e <strtol+0x58>
  800f3e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f42:	75 7c                	jne    800fc0 <strtol+0xca>
		s += 2, base = 16;
  800f44:	83 c1 02             	add    $0x2,%ecx
  800f47:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f4c:	eb 16                	jmp    800f64 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f4e:	85 db                	test   %ebx,%ebx
  800f50:	75 12                	jne    800f64 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f52:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f57:	80 39 30             	cmpb   $0x30,(%ecx)
  800f5a:	75 08                	jne    800f64 <strtol+0x6e>
		s++, base = 8;
  800f5c:	83 c1 01             	add    $0x1,%ecx
  800f5f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f64:	b8 00 00 00 00       	mov    $0x0,%eax
  800f69:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f6c:	0f b6 11             	movzbl (%ecx),%edx
  800f6f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f72:	89 f3                	mov    %esi,%ebx
  800f74:	80 fb 09             	cmp    $0x9,%bl
  800f77:	77 08                	ja     800f81 <strtol+0x8b>
			dig = *s - '0';
  800f79:	0f be d2             	movsbl %dl,%edx
  800f7c:	83 ea 30             	sub    $0x30,%edx
  800f7f:	eb 22                	jmp    800fa3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f81:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f84:	89 f3                	mov    %esi,%ebx
  800f86:	80 fb 19             	cmp    $0x19,%bl
  800f89:	77 08                	ja     800f93 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f8b:	0f be d2             	movsbl %dl,%edx
  800f8e:	83 ea 57             	sub    $0x57,%edx
  800f91:	eb 10                	jmp    800fa3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f93:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f96:	89 f3                	mov    %esi,%ebx
  800f98:	80 fb 19             	cmp    $0x19,%bl
  800f9b:	77 16                	ja     800fb3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f9d:	0f be d2             	movsbl %dl,%edx
  800fa0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800fa3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800fa6:	7d 0b                	jge    800fb3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800fa8:	83 c1 01             	add    $0x1,%ecx
  800fab:	0f af 45 10          	imul   0x10(%ebp),%eax
  800faf:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800fb1:	eb b9                	jmp    800f6c <strtol+0x76>

	if (endptr)
  800fb3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fb7:	74 0d                	je     800fc6 <strtol+0xd0>
		*endptr = (char *) s;
  800fb9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fbc:	89 0e                	mov    %ecx,(%esi)
  800fbe:	eb 06                	jmp    800fc6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fc0:	85 db                	test   %ebx,%ebx
  800fc2:	74 98                	je     800f5c <strtol+0x66>
  800fc4:	eb 9e                	jmp    800f64 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800fc6:	89 c2                	mov    %eax,%edx
  800fc8:	f7 da                	neg    %edx
  800fca:	85 ff                	test   %edi,%edi
  800fcc:	0f 45 c2             	cmovne %edx,%eax
}
  800fcf:	5b                   	pop    %ebx
  800fd0:	5e                   	pop    %esi
  800fd1:	5f                   	pop    %edi
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    

00800fd4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	57                   	push   %edi
  800fd8:	56                   	push   %esi
  800fd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fda:	b8 00 00 00 00       	mov    $0x0,%eax
  800fdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe5:	89 c3                	mov    %eax,%ebx
  800fe7:	89 c7                	mov    %eax,%edi
  800fe9:	89 c6                	mov    %eax,%esi
  800feb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fed:	5b                   	pop    %ebx
  800fee:	5e                   	pop    %esi
  800fef:	5f                   	pop    %edi
  800ff0:	5d                   	pop    %ebp
  800ff1:	c3                   	ret    

00800ff2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	57                   	push   %edi
  800ff6:	56                   	push   %esi
  800ff7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ffd:	b8 01 00 00 00       	mov    $0x1,%eax
  801002:	89 d1                	mov    %edx,%ecx
  801004:	89 d3                	mov    %edx,%ebx
  801006:	89 d7                	mov    %edx,%edi
  801008:	89 d6                	mov    %edx,%esi
  80100a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80100c:	5b                   	pop    %ebx
  80100d:	5e                   	pop    %esi
  80100e:	5f                   	pop    %edi
  80100f:	5d                   	pop    %ebp
  801010:	c3                   	ret    

00801011 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	57                   	push   %edi
  801015:	56                   	push   %esi
  801016:	53                   	push   %ebx
  801017:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101f:	b8 03 00 00 00       	mov    $0x3,%eax
  801024:	8b 55 08             	mov    0x8(%ebp),%edx
  801027:	89 cb                	mov    %ecx,%ebx
  801029:	89 cf                	mov    %ecx,%edi
  80102b:	89 ce                	mov    %ecx,%esi
  80102d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80102f:	85 c0                	test   %eax,%eax
  801031:	7e 17                	jle    80104a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801033:	83 ec 0c             	sub    $0xc,%esp
  801036:	50                   	push   %eax
  801037:	6a 03                	push   $0x3
  801039:	68 24 19 80 00       	push   $0x801924
  80103e:	6a 23                	push   $0x23
  801040:	68 41 19 80 00       	push   $0x801941
  801045:	e8 9f f5 ff ff       	call   8005e9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80104a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104d:	5b                   	pop    %ebx
  80104e:	5e                   	pop    %esi
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801058:	ba 00 00 00 00       	mov    $0x0,%edx
  80105d:	b8 02 00 00 00       	mov    $0x2,%eax
  801062:	89 d1                	mov    %edx,%ecx
  801064:	89 d3                	mov    %edx,%ebx
  801066:	89 d7                	mov    %edx,%edi
  801068:	89 d6                	mov    %edx,%esi
  80106a:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  80106c:	5b                   	pop    %ebx
  80106d:	5e                   	pop    %esi
  80106e:	5f                   	pop    %edi
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    

00801071 <sys_yield>:

void
sys_yield(void)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	57                   	push   %edi
  801075:	56                   	push   %esi
  801076:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801077:	ba 00 00 00 00       	mov    $0x0,%edx
  80107c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801081:	89 d1                	mov    %edx,%ecx
  801083:	89 d3                	mov    %edx,%ebx
  801085:	89 d7                	mov    %edx,%edi
  801087:	89 d6                	mov    %edx,%esi
  801089:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801099:	be 00 00 00 00       	mov    $0x0,%esi
  80109e:	b8 04 00 00 00       	mov    $0x4,%eax
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ac:	89 f7                	mov    %esi,%edi
  8010ae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	7e 17                	jle    8010cb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b4:	83 ec 0c             	sub    $0xc,%esp
  8010b7:	50                   	push   %eax
  8010b8:	6a 04                	push   $0x4
  8010ba:	68 24 19 80 00       	push   $0x801924
  8010bf:	6a 23                	push   $0x23
  8010c1:	68 41 19 80 00       	push   $0x801941
  8010c6:	e8 1e f5 ff ff       	call   8005e9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ce:	5b                   	pop    %ebx
  8010cf:	5e                   	pop    %esi
  8010d0:	5f                   	pop    %edi
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	57                   	push   %edi
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
  8010d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010dc:	b8 05 00 00 00       	mov    $0x5,%eax
  8010e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ea:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ed:	8b 75 18             	mov    0x18(%ebp),%esi
  8010f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	7e 17                	jle    80110d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f6:	83 ec 0c             	sub    $0xc,%esp
  8010f9:	50                   	push   %eax
  8010fa:	6a 05                	push   $0x5
  8010fc:	68 24 19 80 00       	push   $0x801924
  801101:	6a 23                	push   $0x23
  801103:	68 41 19 80 00       	push   $0x801941
  801108:	e8 dc f4 ff ff       	call   8005e9 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80110d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801110:	5b                   	pop    %ebx
  801111:	5e                   	pop    %esi
  801112:	5f                   	pop    %edi
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	57                   	push   %edi
  801119:	56                   	push   %esi
  80111a:	53                   	push   %ebx
  80111b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801123:	b8 06 00 00 00       	mov    $0x6,%eax
  801128:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112b:	8b 55 08             	mov    0x8(%ebp),%edx
  80112e:	89 df                	mov    %ebx,%edi
  801130:	89 de                	mov    %ebx,%esi
  801132:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801134:	85 c0                	test   %eax,%eax
  801136:	7e 17                	jle    80114f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801138:	83 ec 0c             	sub    $0xc,%esp
  80113b:	50                   	push   %eax
  80113c:	6a 06                	push   $0x6
  80113e:	68 24 19 80 00       	push   $0x801924
  801143:	6a 23                	push   $0x23
  801145:	68 41 19 80 00       	push   $0x801941
  80114a:	e8 9a f4 ff ff       	call   8005e9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80114f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801152:	5b                   	pop    %ebx
  801153:	5e                   	pop    %esi
  801154:	5f                   	pop    %edi
  801155:	5d                   	pop    %ebp
  801156:	c3                   	ret    

00801157 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	57                   	push   %edi
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801160:	bb 00 00 00 00       	mov    $0x0,%ebx
  801165:	b8 08 00 00 00       	mov    $0x8,%eax
  80116a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116d:	8b 55 08             	mov    0x8(%ebp),%edx
  801170:	89 df                	mov    %ebx,%edi
  801172:	89 de                	mov    %ebx,%esi
  801174:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801176:	85 c0                	test   %eax,%eax
  801178:	7e 17                	jle    801191 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117a:	83 ec 0c             	sub    $0xc,%esp
  80117d:	50                   	push   %eax
  80117e:	6a 08                	push   $0x8
  801180:	68 24 19 80 00       	push   $0x801924
  801185:	6a 23                	push   $0x23
  801187:	68 41 19 80 00       	push   $0x801941
  80118c:	e8 58 f4 ff ff       	call   8005e9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801194:	5b                   	pop    %ebx
  801195:	5e                   	pop    %esi
  801196:	5f                   	pop    %edi
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    

00801199 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	57                   	push   %edi
  80119d:	56                   	push   %esi
  80119e:	53                   	push   %ebx
  80119f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a7:	b8 09 00 00 00       	mov    $0x9,%eax
  8011ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011af:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b2:	89 df                	mov    %ebx,%edi
  8011b4:	89 de                	mov    %ebx,%esi
  8011b6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011b8:	85 c0                	test   %eax,%eax
  8011ba:	7e 17                	jle    8011d3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011bc:	83 ec 0c             	sub    $0xc,%esp
  8011bf:	50                   	push   %eax
  8011c0:	6a 09                	push   $0x9
  8011c2:	68 24 19 80 00       	push   $0x801924
  8011c7:	6a 23                	push   $0x23
  8011c9:	68 41 19 80 00       	push   $0x801941
  8011ce:	e8 16 f4 ff ff       	call   8005e9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d6:	5b                   	pop    %ebx
  8011d7:	5e                   	pop    %esi
  8011d8:	5f                   	pop    %edi
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    

008011db <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	57                   	push   %edi
  8011df:	56                   	push   %esi
  8011e0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e1:	be 00 00 00 00       	mov    $0x0,%esi
  8011e6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011f4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011f7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011f9:	5b                   	pop    %ebx
  8011fa:	5e                   	pop    %esi
  8011fb:	5f                   	pop    %edi
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	57                   	push   %edi
  801202:	56                   	push   %esi
  801203:	53                   	push   %ebx
  801204:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801207:	b9 00 00 00 00       	mov    $0x0,%ecx
  80120c:	b8 0c 00 00 00       	mov    $0xc,%eax
  801211:	8b 55 08             	mov    0x8(%ebp),%edx
  801214:	89 cb                	mov    %ecx,%ebx
  801216:	89 cf                	mov    %ecx,%edi
  801218:	89 ce                	mov    %ecx,%esi
  80121a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80121c:	85 c0                	test   %eax,%eax
  80121e:	7e 17                	jle    801237 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801220:	83 ec 0c             	sub    $0xc,%esp
  801223:	50                   	push   %eax
  801224:	6a 0c                	push   $0xc
  801226:	68 24 19 80 00       	push   $0x801924
  80122b:	6a 23                	push   $0x23
  80122d:	68 41 19 80 00       	push   $0x801941
  801232:	e8 b2 f3 ff ff       	call   8005e9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801237:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123a:	5b                   	pop    %ebx
  80123b:	5e                   	pop    %esi
  80123c:	5f                   	pop    %edi
  80123d:	5d                   	pop    %ebp
  80123e:	c3                   	ret    

0080123f <sys_change_pr>:

int
sys_change_pr(int pr)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	57                   	push   %edi
  801243:	56                   	push   %esi
  801244:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801245:	b9 00 00 00 00       	mov    $0x0,%ecx
  80124a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80124f:	8b 55 08             	mov    0x8(%ebp),%edx
  801252:	89 cb                	mov    %ecx,%ebx
  801254:	89 cf                	mov    %ecx,%edi
  801256:	89 ce                	mov    %ecx,%esi
  801258:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  80125a:	5b                   	pop    %ebx
  80125b:	5e                   	pop    %esi
  80125c:	5f                   	pop    %edi
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    

0080125f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	83 ec 08             	sub    $0x8,%esp
	// int r;

	if (_pgfault_handler == 0) {
  801265:	83 3d d4 20 80 00 00 	cmpl   $0x0,0x8020d4
  80126c:	75 2c                	jne    80129a <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  80126e:	83 ec 04             	sub    $0x4,%esp
  801271:	6a 07                	push   $0x7
  801273:	68 00 f0 bf ee       	push   $0xeebff000
  801278:	6a 00                	push   $0x0
  80127a:	e8 11 fe ff ff       	call   801090 <sys_page_alloc>
  80127f:	83 c4 10             	add    $0x10,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	79 14                	jns    80129a <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  801286:	83 ec 04             	sub    $0x4,%esp
  801289:	68 50 19 80 00       	push   $0x801950
  80128e:	6a 21                	push   $0x21
  801290:	68 b4 19 80 00       	push   $0x8019b4
  801295:	e8 4f f3 ff ff       	call   8005e9 <_panic>
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80129a:	8b 45 08             	mov    0x8(%ebp),%eax
  80129d:	a3 d4 20 80 00       	mov    %eax,0x8020d4
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8012a2:	83 ec 08             	sub    $0x8,%esp
  8012a5:	68 ce 12 80 00       	push   $0x8012ce
  8012aa:	6a 00                	push   $0x0
  8012ac:	e8 e8 fe ff ff       	call   801199 <sys_env_set_pgfault_upcall>
  8012b1:	83 c4 10             	add    $0x10,%esp
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	79 14                	jns    8012cc <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8012b8:	83 ec 04             	sub    $0x4,%esp
  8012bb:	68 7c 19 80 00       	push   $0x80197c
  8012c0:	6a 26                	push   $0x26
  8012c2:	68 b4 19 80 00       	push   $0x8019b4
  8012c7:	e8 1d f3 ff ff       	call   8005e9 <_panic>
}
  8012cc:	c9                   	leave  
  8012cd:	c3                   	ret    

008012ce <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012ce:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012cf:	a1 d4 20 80 00       	mov    0x8020d4,%eax
	call *%eax
  8012d4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012d6:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx #trap-time eip
  8012d9:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)
  8012dd:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax #trap-time esp-4
  8012e2:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)
  8012e6:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp
  8012e8:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8012eb:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp #eip
  8012ec:	83 c4 04             	add    $0x4,%esp
	popfl
  8012ef:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8012f0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8012f1:	c3                   	ret    
  8012f2:	66 90                	xchg   %ax,%ax
  8012f4:	66 90                	xchg   %ax,%ax
  8012f6:	66 90                	xchg   %ax,%ax
  8012f8:	66 90                	xchg   %ax,%ax
  8012fa:	66 90                	xchg   %ax,%ax
  8012fc:	66 90                	xchg   %ax,%ax
  8012fe:	66 90                	xchg   %ax,%ax

00801300 <__udivdi3>:
  801300:	55                   	push   %ebp
  801301:	57                   	push   %edi
  801302:	56                   	push   %esi
  801303:	53                   	push   %ebx
  801304:	83 ec 1c             	sub    $0x1c,%esp
  801307:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80130b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80130f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801317:	85 f6                	test   %esi,%esi
  801319:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80131d:	89 ca                	mov    %ecx,%edx
  80131f:	89 f8                	mov    %edi,%eax
  801321:	75 3d                	jne    801360 <__udivdi3+0x60>
  801323:	39 cf                	cmp    %ecx,%edi
  801325:	0f 87 c5 00 00 00    	ja     8013f0 <__udivdi3+0xf0>
  80132b:	85 ff                	test   %edi,%edi
  80132d:	89 fd                	mov    %edi,%ebp
  80132f:	75 0b                	jne    80133c <__udivdi3+0x3c>
  801331:	b8 01 00 00 00       	mov    $0x1,%eax
  801336:	31 d2                	xor    %edx,%edx
  801338:	f7 f7                	div    %edi
  80133a:	89 c5                	mov    %eax,%ebp
  80133c:	89 c8                	mov    %ecx,%eax
  80133e:	31 d2                	xor    %edx,%edx
  801340:	f7 f5                	div    %ebp
  801342:	89 c1                	mov    %eax,%ecx
  801344:	89 d8                	mov    %ebx,%eax
  801346:	89 cf                	mov    %ecx,%edi
  801348:	f7 f5                	div    %ebp
  80134a:	89 c3                	mov    %eax,%ebx
  80134c:	89 d8                	mov    %ebx,%eax
  80134e:	89 fa                	mov    %edi,%edx
  801350:	83 c4 1c             	add    $0x1c,%esp
  801353:	5b                   	pop    %ebx
  801354:	5e                   	pop    %esi
  801355:	5f                   	pop    %edi
  801356:	5d                   	pop    %ebp
  801357:	c3                   	ret    
  801358:	90                   	nop
  801359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801360:	39 ce                	cmp    %ecx,%esi
  801362:	77 74                	ja     8013d8 <__udivdi3+0xd8>
  801364:	0f bd fe             	bsr    %esi,%edi
  801367:	83 f7 1f             	xor    $0x1f,%edi
  80136a:	0f 84 98 00 00 00    	je     801408 <__udivdi3+0x108>
  801370:	bb 20 00 00 00       	mov    $0x20,%ebx
  801375:	89 f9                	mov    %edi,%ecx
  801377:	89 c5                	mov    %eax,%ebp
  801379:	29 fb                	sub    %edi,%ebx
  80137b:	d3 e6                	shl    %cl,%esi
  80137d:	89 d9                	mov    %ebx,%ecx
  80137f:	d3 ed                	shr    %cl,%ebp
  801381:	89 f9                	mov    %edi,%ecx
  801383:	d3 e0                	shl    %cl,%eax
  801385:	09 ee                	or     %ebp,%esi
  801387:	89 d9                	mov    %ebx,%ecx
  801389:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80138d:	89 d5                	mov    %edx,%ebp
  80138f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801393:	d3 ed                	shr    %cl,%ebp
  801395:	89 f9                	mov    %edi,%ecx
  801397:	d3 e2                	shl    %cl,%edx
  801399:	89 d9                	mov    %ebx,%ecx
  80139b:	d3 e8                	shr    %cl,%eax
  80139d:	09 c2                	or     %eax,%edx
  80139f:	89 d0                	mov    %edx,%eax
  8013a1:	89 ea                	mov    %ebp,%edx
  8013a3:	f7 f6                	div    %esi
  8013a5:	89 d5                	mov    %edx,%ebp
  8013a7:	89 c3                	mov    %eax,%ebx
  8013a9:	f7 64 24 0c          	mull   0xc(%esp)
  8013ad:	39 d5                	cmp    %edx,%ebp
  8013af:	72 10                	jb     8013c1 <__udivdi3+0xc1>
  8013b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8013b5:	89 f9                	mov    %edi,%ecx
  8013b7:	d3 e6                	shl    %cl,%esi
  8013b9:	39 c6                	cmp    %eax,%esi
  8013bb:	73 07                	jae    8013c4 <__udivdi3+0xc4>
  8013bd:	39 d5                	cmp    %edx,%ebp
  8013bf:	75 03                	jne    8013c4 <__udivdi3+0xc4>
  8013c1:	83 eb 01             	sub    $0x1,%ebx
  8013c4:	31 ff                	xor    %edi,%edi
  8013c6:	89 d8                	mov    %ebx,%eax
  8013c8:	89 fa                	mov    %edi,%edx
  8013ca:	83 c4 1c             	add    $0x1c,%esp
  8013cd:	5b                   	pop    %ebx
  8013ce:	5e                   	pop    %esi
  8013cf:	5f                   	pop    %edi
  8013d0:	5d                   	pop    %ebp
  8013d1:	c3                   	ret    
  8013d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013d8:	31 ff                	xor    %edi,%edi
  8013da:	31 db                	xor    %ebx,%ebx
  8013dc:	89 d8                	mov    %ebx,%eax
  8013de:	89 fa                	mov    %edi,%edx
  8013e0:	83 c4 1c             	add    $0x1c,%esp
  8013e3:	5b                   	pop    %ebx
  8013e4:	5e                   	pop    %esi
  8013e5:	5f                   	pop    %edi
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    
  8013e8:	90                   	nop
  8013e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013f0:	89 d8                	mov    %ebx,%eax
  8013f2:	f7 f7                	div    %edi
  8013f4:	31 ff                	xor    %edi,%edi
  8013f6:	89 c3                	mov    %eax,%ebx
  8013f8:	89 d8                	mov    %ebx,%eax
  8013fa:	89 fa                	mov    %edi,%edx
  8013fc:	83 c4 1c             	add    $0x1c,%esp
  8013ff:	5b                   	pop    %ebx
  801400:	5e                   	pop    %esi
  801401:	5f                   	pop    %edi
  801402:	5d                   	pop    %ebp
  801403:	c3                   	ret    
  801404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801408:	39 ce                	cmp    %ecx,%esi
  80140a:	72 0c                	jb     801418 <__udivdi3+0x118>
  80140c:	31 db                	xor    %ebx,%ebx
  80140e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801412:	0f 87 34 ff ff ff    	ja     80134c <__udivdi3+0x4c>
  801418:	bb 01 00 00 00       	mov    $0x1,%ebx
  80141d:	e9 2a ff ff ff       	jmp    80134c <__udivdi3+0x4c>
  801422:	66 90                	xchg   %ax,%ax
  801424:	66 90                	xchg   %ax,%ax
  801426:	66 90                	xchg   %ax,%ax
  801428:	66 90                	xchg   %ax,%ax
  80142a:	66 90                	xchg   %ax,%ax
  80142c:	66 90                	xchg   %ax,%ax
  80142e:	66 90                	xchg   %ax,%ax

00801430 <__umoddi3>:
  801430:	55                   	push   %ebp
  801431:	57                   	push   %edi
  801432:	56                   	push   %esi
  801433:	53                   	push   %ebx
  801434:	83 ec 1c             	sub    $0x1c,%esp
  801437:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80143b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80143f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801443:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801447:	85 d2                	test   %edx,%edx
  801449:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80144d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801451:	89 f3                	mov    %esi,%ebx
  801453:	89 3c 24             	mov    %edi,(%esp)
  801456:	89 74 24 04          	mov    %esi,0x4(%esp)
  80145a:	75 1c                	jne    801478 <__umoddi3+0x48>
  80145c:	39 f7                	cmp    %esi,%edi
  80145e:	76 50                	jbe    8014b0 <__umoddi3+0x80>
  801460:	89 c8                	mov    %ecx,%eax
  801462:	89 f2                	mov    %esi,%edx
  801464:	f7 f7                	div    %edi
  801466:	89 d0                	mov    %edx,%eax
  801468:	31 d2                	xor    %edx,%edx
  80146a:	83 c4 1c             	add    $0x1c,%esp
  80146d:	5b                   	pop    %ebx
  80146e:	5e                   	pop    %esi
  80146f:	5f                   	pop    %edi
  801470:	5d                   	pop    %ebp
  801471:	c3                   	ret    
  801472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801478:	39 f2                	cmp    %esi,%edx
  80147a:	89 d0                	mov    %edx,%eax
  80147c:	77 52                	ja     8014d0 <__umoddi3+0xa0>
  80147e:	0f bd ea             	bsr    %edx,%ebp
  801481:	83 f5 1f             	xor    $0x1f,%ebp
  801484:	75 5a                	jne    8014e0 <__umoddi3+0xb0>
  801486:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80148a:	0f 82 e0 00 00 00    	jb     801570 <__umoddi3+0x140>
  801490:	39 0c 24             	cmp    %ecx,(%esp)
  801493:	0f 86 d7 00 00 00    	jbe    801570 <__umoddi3+0x140>
  801499:	8b 44 24 08          	mov    0x8(%esp),%eax
  80149d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014a1:	83 c4 1c             	add    $0x1c,%esp
  8014a4:	5b                   	pop    %ebx
  8014a5:	5e                   	pop    %esi
  8014a6:	5f                   	pop    %edi
  8014a7:	5d                   	pop    %ebp
  8014a8:	c3                   	ret    
  8014a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014b0:	85 ff                	test   %edi,%edi
  8014b2:	89 fd                	mov    %edi,%ebp
  8014b4:	75 0b                	jne    8014c1 <__umoddi3+0x91>
  8014b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014bb:	31 d2                	xor    %edx,%edx
  8014bd:	f7 f7                	div    %edi
  8014bf:	89 c5                	mov    %eax,%ebp
  8014c1:	89 f0                	mov    %esi,%eax
  8014c3:	31 d2                	xor    %edx,%edx
  8014c5:	f7 f5                	div    %ebp
  8014c7:	89 c8                	mov    %ecx,%eax
  8014c9:	f7 f5                	div    %ebp
  8014cb:	89 d0                	mov    %edx,%eax
  8014cd:	eb 99                	jmp    801468 <__umoddi3+0x38>
  8014cf:	90                   	nop
  8014d0:	89 c8                	mov    %ecx,%eax
  8014d2:	89 f2                	mov    %esi,%edx
  8014d4:	83 c4 1c             	add    $0x1c,%esp
  8014d7:	5b                   	pop    %ebx
  8014d8:	5e                   	pop    %esi
  8014d9:	5f                   	pop    %edi
  8014da:	5d                   	pop    %ebp
  8014db:	c3                   	ret    
  8014dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e0:	8b 34 24             	mov    (%esp),%esi
  8014e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8014e8:	89 e9                	mov    %ebp,%ecx
  8014ea:	29 ef                	sub    %ebp,%edi
  8014ec:	d3 e0                	shl    %cl,%eax
  8014ee:	89 f9                	mov    %edi,%ecx
  8014f0:	89 f2                	mov    %esi,%edx
  8014f2:	d3 ea                	shr    %cl,%edx
  8014f4:	89 e9                	mov    %ebp,%ecx
  8014f6:	09 c2                	or     %eax,%edx
  8014f8:	89 d8                	mov    %ebx,%eax
  8014fa:	89 14 24             	mov    %edx,(%esp)
  8014fd:	89 f2                	mov    %esi,%edx
  8014ff:	d3 e2                	shl    %cl,%edx
  801501:	89 f9                	mov    %edi,%ecx
  801503:	89 54 24 04          	mov    %edx,0x4(%esp)
  801507:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80150b:	d3 e8                	shr    %cl,%eax
  80150d:	89 e9                	mov    %ebp,%ecx
  80150f:	89 c6                	mov    %eax,%esi
  801511:	d3 e3                	shl    %cl,%ebx
  801513:	89 f9                	mov    %edi,%ecx
  801515:	89 d0                	mov    %edx,%eax
  801517:	d3 e8                	shr    %cl,%eax
  801519:	89 e9                	mov    %ebp,%ecx
  80151b:	09 d8                	or     %ebx,%eax
  80151d:	89 d3                	mov    %edx,%ebx
  80151f:	89 f2                	mov    %esi,%edx
  801521:	f7 34 24             	divl   (%esp)
  801524:	89 d6                	mov    %edx,%esi
  801526:	d3 e3                	shl    %cl,%ebx
  801528:	f7 64 24 04          	mull   0x4(%esp)
  80152c:	39 d6                	cmp    %edx,%esi
  80152e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801532:	89 d1                	mov    %edx,%ecx
  801534:	89 c3                	mov    %eax,%ebx
  801536:	72 08                	jb     801540 <__umoddi3+0x110>
  801538:	75 11                	jne    80154b <__umoddi3+0x11b>
  80153a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80153e:	73 0b                	jae    80154b <__umoddi3+0x11b>
  801540:	2b 44 24 04          	sub    0x4(%esp),%eax
  801544:	1b 14 24             	sbb    (%esp),%edx
  801547:	89 d1                	mov    %edx,%ecx
  801549:	89 c3                	mov    %eax,%ebx
  80154b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80154f:	29 da                	sub    %ebx,%edx
  801551:	19 ce                	sbb    %ecx,%esi
  801553:	89 f9                	mov    %edi,%ecx
  801555:	89 f0                	mov    %esi,%eax
  801557:	d3 e0                	shl    %cl,%eax
  801559:	89 e9                	mov    %ebp,%ecx
  80155b:	d3 ea                	shr    %cl,%edx
  80155d:	89 e9                	mov    %ebp,%ecx
  80155f:	d3 ee                	shr    %cl,%esi
  801561:	09 d0                	or     %edx,%eax
  801563:	89 f2                	mov    %esi,%edx
  801565:	83 c4 1c             	add    $0x1c,%esp
  801568:	5b                   	pop    %ebx
  801569:	5e                   	pop    %esi
  80156a:	5f                   	pop    %edi
  80156b:	5d                   	pop    %ebp
  80156c:	c3                   	ret    
  80156d:	8d 76 00             	lea    0x0(%esi),%esi
  801570:	29 f9                	sub    %edi,%ecx
  801572:	19 d6                	sbb    %edx,%esi
  801574:	89 74 24 04          	mov    %esi,0x4(%esp)
  801578:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80157c:	e9 18 ff ff ff       	jmp    801499 <__umoddi3+0x69>
