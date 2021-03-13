
obj/user/faultalloc：     文件格式 elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 c0 10 80 00       	push   $0x8010c0
  800045:	e8 b1 01 00 00       	call   8001fb <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 6b 0b 00 00       	call   800bc9 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 e0 10 80 00       	push   $0x8010e0
  80006f:	6a 0e                	push   $0xe
  800071:	68 ca 10 80 00       	push   $0x8010ca
  800076:	e8 a7 00 00 00       	call   800122 <_panic>
	// cprintf("addr: %x\n", *((char*)addr+100));
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 0c 11 80 00       	push   $0x80110c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 ea 06 00 00       	call   800773 <snprintf>
	// cprintf("good\n");
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 f7 0c 00 00       	call   800d98 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 dc 10 80 00       	push   $0x8010dc
  8000ae:	e8 48 01 00 00       	call   8001fb <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 dc 10 80 00       	push   $0x8010dc
  8000c0:	e8 36 01 00 00       	call   8001fb <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  8000d5:	e8 b1 0a 00 00       	call   800b8b <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	c1 e0 07             	shl    $0x7,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800116:	6a 00                	push   $0x0
  800118:	e8 2d 0a 00 00       	call   800b4a <sys_env_destroy>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	56                   	push   %esi
  800126:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800127:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80012a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800130:	e8 56 0a 00 00       	call   800b8b <sys_getenvid>
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	ff 75 0c             	pushl  0xc(%ebp)
  80013b:	ff 75 08             	pushl  0x8(%ebp)
  80013e:	56                   	push   %esi
  80013f:	50                   	push   %eax
  800140:	68 38 11 80 00       	push   $0x801138
  800145:	e8 b1 00 00 00       	call   8001fb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80014a:	83 c4 18             	add    $0x18,%esp
  80014d:	53                   	push   %ebx
  80014e:	ff 75 10             	pushl  0x10(%ebp)
  800151:	e8 54 00 00 00       	call   8001aa <vcprintf>
	cprintf("\n");
  800156:	c7 04 24 de 10 80 00 	movl   $0x8010de,(%esp)
  80015d:	e8 99 00 00 00       	call   8001fb <cprintf>
  800162:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800165:	cc                   	int3   
  800166:	eb fd                	jmp    800165 <_panic+0x43>

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 04             	sub    $0x4,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 13                	mov    (%ebx),%edx
  800174:	8d 42 01             	lea    0x1(%edx),%eax
  800177:	89 03                	mov    %eax,(%ebx)
  800179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800180:	3d ff 00 00 00       	cmp    $0xff,%eax
  800185:	75 1a                	jne    8001a1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800187:	83 ec 08             	sub    $0x8,%esp
  80018a:	68 ff 00 00 00       	push   $0xff
  80018f:	8d 43 08             	lea    0x8(%ebx),%eax
  800192:	50                   	push   %eax
  800193:	e8 75 09 00 00       	call   800b0d <sys_cputs>
		b->idx = 0;
  800198:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ba:	00 00 00 
	b.cnt = 0;
  8001bd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ca:	ff 75 08             	pushl  0x8(%ebp)
  8001cd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d3:	50                   	push   %eax
  8001d4:	68 68 01 80 00       	push   $0x800168
  8001d9:	e8 54 01 00 00       	call   800332 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001de:	83 c4 08             	add    $0x8,%esp
  8001e1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	e8 1a 09 00 00       	call   800b0d <sys_cputs>

	return b.cnt;
}
  8001f3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    

008001fb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800201:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800204:	50                   	push   %eax
  800205:	ff 75 08             	pushl  0x8(%ebp)
  800208:	e8 9d ff ff ff       	call   8001aa <vcprintf>
	va_end(ap);

	return cnt;
}
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	57                   	push   %edi
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	83 ec 1c             	sub    $0x1c,%esp
  800218:	89 c7                	mov    %eax,%edi
  80021a:	89 d6                	mov    %edx,%esi
  80021c:	8b 45 08             	mov    0x8(%ebp),%eax
  80021f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800222:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800225:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800228:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80022b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800230:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800233:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800236:	39 d3                	cmp    %edx,%ebx
  800238:	72 05                	jb     80023f <printnum+0x30>
  80023a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023d:	77 45                	ja     800284 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	ff 75 18             	pushl  0x18(%ebp)
  800245:	8b 45 14             	mov    0x14(%ebp),%eax
  800248:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80024b:	53                   	push   %ebx
  80024c:	ff 75 10             	pushl  0x10(%ebp)
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	ff 75 e4             	pushl  -0x1c(%ebp)
  800255:	ff 75 e0             	pushl  -0x20(%ebp)
  800258:	ff 75 dc             	pushl  -0x24(%ebp)
  80025b:	ff 75 d8             	pushl  -0x28(%ebp)
  80025e:	e8 cd 0b 00 00       	call   800e30 <__udivdi3>
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	52                   	push   %edx
  800267:	50                   	push   %eax
  800268:	89 f2                	mov    %esi,%edx
  80026a:	89 f8                	mov    %edi,%eax
  80026c:	e8 9e ff ff ff       	call   80020f <printnum>
  800271:	83 c4 20             	add    $0x20,%esp
  800274:	eb 18                	jmp    80028e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800276:	83 ec 08             	sub    $0x8,%esp
  800279:	56                   	push   %esi
  80027a:	ff 75 18             	pushl  0x18(%ebp)
  80027d:	ff d7                	call   *%edi
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	eb 03                	jmp    800287 <printnum+0x78>
  800284:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800287:	83 eb 01             	sub    $0x1,%ebx
  80028a:	85 db                	test   %ebx,%ebx
  80028c:	7f e8                	jg     800276 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	56                   	push   %esi
  800292:	83 ec 04             	sub    $0x4,%esp
  800295:	ff 75 e4             	pushl  -0x1c(%ebp)
  800298:	ff 75 e0             	pushl  -0x20(%ebp)
  80029b:	ff 75 dc             	pushl  -0x24(%ebp)
  80029e:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a1:	e8 ba 0c 00 00       	call   800f60 <__umoddi3>
  8002a6:	83 c4 14             	add    $0x14,%esp
  8002a9:	0f be 80 5b 11 80 00 	movsbl 0x80115b(%eax),%eax
  8002b0:	50                   	push   %eax
  8002b1:	ff d7                	call   *%edi
}
  8002b3:	83 c4 10             	add    $0x10,%esp
  8002b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b9:	5b                   	pop    %ebx
  8002ba:	5e                   	pop    %esi
  8002bb:	5f                   	pop    %edi
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c1:	83 fa 01             	cmp    $0x1,%edx
  8002c4:	7e 0e                	jle    8002d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	8b 52 04             	mov    0x4(%edx),%edx
  8002d2:	eb 22                	jmp    8002f6 <getuint+0x38>
	else if (lflag)
  8002d4:	85 d2                	test   %edx,%edx
  8002d6:	74 10                	je     8002e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e6:	eb 0e                	jmp    8002f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800302:	8b 10                	mov    (%eax),%edx
  800304:	3b 50 04             	cmp    0x4(%eax),%edx
  800307:	73 0a                	jae    800313 <sprintputch+0x1b>
		*b->buf++ = ch;
  800309:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030c:	89 08                	mov    %ecx,(%eax)
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	88 02                	mov    %al,(%edx)
}
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80031b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031e:	50                   	push   %eax
  80031f:	ff 75 10             	pushl  0x10(%ebp)
  800322:	ff 75 0c             	pushl  0xc(%ebp)
  800325:	ff 75 08             	pushl  0x8(%ebp)
  800328:	e8 05 00 00 00       	call   800332 <vprintfmt>
	va_end(ap);
}
  80032d:	83 c4 10             	add    $0x10,%esp
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
  800338:	83 ec 2c             	sub    $0x2c,%esp
  80033b:	8b 75 08             	mov    0x8(%ebp),%esi
  80033e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800341:	8b 7d 10             	mov    0x10(%ebp),%edi
  800344:	eb 1d                	jmp    800363 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800346:	85 c0                	test   %eax,%eax
  800348:	75 0f                	jne    800359 <vprintfmt+0x27>
				csa = 0x0700;
  80034a:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  800351:	07 00 00 
				return;
  800354:	e9 c4 03 00 00       	jmp    80071d <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800359:	83 ec 08             	sub    $0x8,%esp
  80035c:	53                   	push   %ebx
  80035d:	50                   	push   %eax
  80035e:	ff d6                	call   *%esi
  800360:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800363:	83 c7 01             	add    $0x1,%edi
  800366:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80036a:	83 f8 25             	cmp    $0x25,%eax
  80036d:	75 d7                	jne    800346 <vprintfmt+0x14>
  80036f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800373:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80037a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800381:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800388:	ba 00 00 00 00       	mov    $0x0,%edx
  80038d:	eb 07                	jmp    800396 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800392:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8d 47 01             	lea    0x1(%edi),%eax
  800399:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039c:	0f b6 07             	movzbl (%edi),%eax
  80039f:	0f b6 c8             	movzbl %al,%ecx
  8003a2:	83 e8 23             	sub    $0x23,%eax
  8003a5:	3c 55                	cmp    $0x55,%al
  8003a7:	0f 87 55 03 00 00    	ja     800702 <vprintfmt+0x3d0>
  8003ad:	0f b6 c0             	movzbl %al,%eax
  8003b0:	ff 24 85 20 12 80 00 	jmp    *0x801220(,%eax,4)
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ba:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003be:	eb d6                	jmp    800396 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003cb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ce:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003d2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003d5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d8:	83 fa 09             	cmp    $0x9,%edx
  8003db:	77 39                	ja     800416 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003dd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e0:	eb e9                	jmp    8003cb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e5:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003eb:	8b 00                	mov    (%eax),%eax
  8003ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f3:	eb 27                	jmp    80041c <vprintfmt+0xea>
  8003f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f8:	85 c0                	test   %eax,%eax
  8003fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ff:	0f 49 c8             	cmovns %eax,%ecx
  800402:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800408:	eb 8c                	jmp    800396 <vprintfmt+0x64>
  80040a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800414:	eb 80                	jmp    800396 <vprintfmt+0x64>
  800416:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800419:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80041c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800420:	0f 89 70 ff ff ff    	jns    800396 <vprintfmt+0x64>
				width = precision, precision = -1;
  800426:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800429:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800433:	e9 5e ff ff ff       	jmp    800396 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800438:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043e:	e9 53 ff ff ff       	jmp    800396 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 50 04             	lea    0x4(%eax),%edx
  800449:	89 55 14             	mov    %edx,0x14(%ebp)
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	53                   	push   %ebx
  800450:	ff 30                	pushl  (%eax)
  800452:	ff d6                	call   *%esi
			break;
  800454:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80045a:	e9 04 ff ff ff       	jmp    800363 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045f:	8b 45 14             	mov    0x14(%ebp),%eax
  800462:	8d 50 04             	lea    0x4(%eax),%edx
  800465:	89 55 14             	mov    %edx,0x14(%ebp)
  800468:	8b 00                	mov    (%eax),%eax
  80046a:	99                   	cltd   
  80046b:	31 d0                	xor    %edx,%eax
  80046d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046f:	83 f8 08             	cmp    $0x8,%eax
  800472:	7f 0b                	jg     80047f <vprintfmt+0x14d>
  800474:	8b 14 85 80 13 80 00 	mov    0x801380(,%eax,4),%edx
  80047b:	85 d2                	test   %edx,%edx
  80047d:	75 18                	jne    800497 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  80047f:	50                   	push   %eax
  800480:	68 73 11 80 00       	push   $0x801173
  800485:	53                   	push   %ebx
  800486:	56                   	push   %esi
  800487:	e8 89 fe ff ff       	call   800315 <printfmt>
  80048c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800492:	e9 cc fe ff ff       	jmp    800363 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  800497:	52                   	push   %edx
  800498:	68 7c 11 80 00       	push   $0x80117c
  80049d:	53                   	push   %ebx
  80049e:	56                   	push   %esi
  80049f:	e8 71 fe ff ff       	call   800315 <printfmt>
  8004a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004aa:	e9 b4 fe ff ff       	jmp    800363 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004af:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b2:	8d 50 04             	lea    0x4(%eax),%edx
  8004b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ba:	85 ff                	test   %edi,%edi
  8004bc:	b8 6c 11 80 00       	mov    $0x80116c,%eax
  8004c1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c8:	0f 8e 94 00 00 00    	jle    800562 <vprintfmt+0x230>
  8004ce:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d2:	0f 84 98 00 00 00    	je     800570 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	ff 75 d0             	pushl  -0x30(%ebp)
  8004de:	57                   	push   %edi
  8004df:	e8 c1 02 00 00       	call   8007a5 <strnlen>
  8004e4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e7:	29 c1                	sub    %eax,%ecx
  8004e9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004ec:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ef:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	eb 0f                	jmp    80050c <vprintfmt+0x1da>
					putch(padc, putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	53                   	push   %ebx
  800501:	ff 75 e0             	pushl  -0x20(%ebp)
  800504:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800506:	83 ef 01             	sub    $0x1,%edi
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	85 ff                	test   %edi,%edi
  80050e:	7f ed                	jg     8004fd <vprintfmt+0x1cb>
  800510:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800513:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800516:	85 c9                	test   %ecx,%ecx
  800518:	b8 00 00 00 00       	mov    $0x0,%eax
  80051d:	0f 49 c1             	cmovns %ecx,%eax
  800520:	29 c1                	sub    %eax,%ecx
  800522:	89 75 08             	mov    %esi,0x8(%ebp)
  800525:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800528:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052b:	89 cb                	mov    %ecx,%ebx
  80052d:	eb 4d                	jmp    80057c <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800533:	74 1b                	je     800550 <vprintfmt+0x21e>
  800535:	0f be c0             	movsbl %al,%eax
  800538:	83 e8 20             	sub    $0x20,%eax
  80053b:	83 f8 5e             	cmp    $0x5e,%eax
  80053e:	76 10                	jbe    800550 <vprintfmt+0x21e>
					putch('?', putdat);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	ff 75 0c             	pushl  0xc(%ebp)
  800546:	6a 3f                	push   $0x3f
  800548:	ff 55 08             	call   *0x8(%ebp)
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	eb 0d                	jmp    80055d <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	ff 75 0c             	pushl  0xc(%ebp)
  800556:	52                   	push   %edx
  800557:	ff 55 08             	call   *0x8(%ebp)
  80055a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055d:	83 eb 01             	sub    $0x1,%ebx
  800560:	eb 1a                	jmp    80057c <vprintfmt+0x24a>
  800562:	89 75 08             	mov    %esi,0x8(%ebp)
  800565:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800568:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056e:	eb 0c                	jmp    80057c <vprintfmt+0x24a>
  800570:	89 75 08             	mov    %esi,0x8(%ebp)
  800573:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800576:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800579:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057c:	83 c7 01             	add    $0x1,%edi
  80057f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800583:	0f be d0             	movsbl %al,%edx
  800586:	85 d2                	test   %edx,%edx
  800588:	74 23                	je     8005ad <vprintfmt+0x27b>
  80058a:	85 f6                	test   %esi,%esi
  80058c:	78 a1                	js     80052f <vprintfmt+0x1fd>
  80058e:	83 ee 01             	sub    $0x1,%esi
  800591:	79 9c                	jns    80052f <vprintfmt+0x1fd>
  800593:	89 df                	mov    %ebx,%edi
  800595:	8b 75 08             	mov    0x8(%ebp),%esi
  800598:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059b:	eb 18                	jmp    8005b5 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	53                   	push   %ebx
  8005a1:	6a 20                	push   $0x20
  8005a3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a5:	83 ef 01             	sub    $0x1,%edi
  8005a8:	83 c4 10             	add    $0x10,%esp
  8005ab:	eb 08                	jmp    8005b5 <vprintfmt+0x283>
  8005ad:	89 df                	mov    %ebx,%edi
  8005af:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b5:	85 ff                	test   %edi,%edi
  8005b7:	7f e4                	jg     80059d <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bc:	e9 a2 fd ff ff       	jmp    800363 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c1:	83 fa 01             	cmp    $0x1,%edx
  8005c4:	7e 16                	jle    8005dc <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 08             	lea    0x8(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cf:	8b 50 04             	mov    0x4(%eax),%edx
  8005d2:	8b 00                	mov    (%eax),%eax
  8005d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005da:	eb 32                	jmp    80060e <vprintfmt+0x2dc>
	else if (lflag)
  8005dc:	85 d2                	test   %edx,%edx
  8005de:	74 18                	je     8005f8 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 50 04             	lea    0x4(%eax),%edx
  8005e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	89 c1                	mov    %eax,%ecx
  8005f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f6:	eb 16                	jmp    80060e <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 50 04             	lea    0x4(%eax),%edx
  8005fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800601:	8b 00                	mov    (%eax),%eax
  800603:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800606:	89 c1                	mov    %eax,%ecx
  800608:	c1 f9 1f             	sar    $0x1f,%ecx
  80060b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800611:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800614:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800619:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061d:	79 74                	jns    800693 <vprintfmt+0x361>
				putch('-', putdat);
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	53                   	push   %ebx
  800623:	6a 2d                	push   $0x2d
  800625:	ff d6                	call   *%esi
				num = -(long long) num;
  800627:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80062d:	f7 d8                	neg    %eax
  80062f:	83 d2 00             	adc    $0x0,%edx
  800632:	f7 da                	neg    %edx
  800634:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800637:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80063c:	eb 55                	jmp    800693 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063e:	8d 45 14             	lea    0x14(%ebp),%eax
  800641:	e8 78 fc ff ff       	call   8002be <getuint>
			base = 10;
  800646:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80064b:	eb 46                	jmp    800693 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  80064d:	8d 45 14             	lea    0x14(%ebp),%eax
  800650:	e8 69 fc ff ff       	call   8002be <getuint>
      base = 8;
  800655:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80065a:	eb 37                	jmp    800693 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	53                   	push   %ebx
  800660:	6a 30                	push   $0x30
  800662:	ff d6                	call   *%esi
			putch('x', putdat);
  800664:	83 c4 08             	add    $0x8,%esp
  800667:	53                   	push   %ebx
  800668:	6a 78                	push   $0x78
  80066a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 50 04             	lea    0x4(%eax),%edx
  800672:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800675:	8b 00                	mov    (%eax),%eax
  800677:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80067c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80067f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800684:	eb 0d                	jmp    800693 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800686:	8d 45 14             	lea    0x14(%ebp),%eax
  800689:	e8 30 fc ff ff       	call   8002be <getuint>
			base = 16;
  80068e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800693:	83 ec 0c             	sub    $0xc,%esp
  800696:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80069a:	57                   	push   %edi
  80069b:	ff 75 e0             	pushl  -0x20(%ebp)
  80069e:	51                   	push   %ecx
  80069f:	52                   	push   %edx
  8006a0:	50                   	push   %eax
  8006a1:	89 da                	mov    %ebx,%edx
  8006a3:	89 f0                	mov    %esi,%eax
  8006a5:	e8 65 fb ff ff       	call   80020f <printnum>
			break;
  8006aa:	83 c4 20             	add    $0x20,%esp
  8006ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b0:	e9 ae fc ff ff       	jmp    800363 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	51                   	push   %ecx
  8006ba:	ff d6                	call   *%esi
			break;
  8006bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006c2:	e9 9c fc ff ff       	jmp    800363 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c7:	83 fa 01             	cmp    $0x1,%edx
  8006ca:	7e 0d                	jle    8006d9 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8d 50 08             	lea    0x8(%eax),%edx
  8006d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d5:	8b 00                	mov    (%eax),%eax
  8006d7:	eb 1c                	jmp    8006f5 <vprintfmt+0x3c3>
	else if (lflag)
  8006d9:	85 d2                	test   %edx,%edx
  8006db:	74 0d                	je     8006ea <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 50 04             	lea    0x4(%eax),%edx
  8006e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e6:	8b 00                	mov    (%eax),%eax
  8006e8:	eb 0b                	jmp    8006f5 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8d 50 04             	lea    0x4(%eax),%edx
  8006f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f3:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  8006f5:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  8006fd:	e9 61 fc ff ff       	jmp    800363 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	6a 25                	push   $0x25
  800708:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	eb 03                	jmp    800712 <vprintfmt+0x3e0>
  80070f:	83 ef 01             	sub    $0x1,%edi
  800712:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800716:	75 f7                	jne    80070f <vprintfmt+0x3dd>
  800718:	e9 46 fc ff ff       	jmp    800363 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  80071d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800720:	5b                   	pop    %ebx
  800721:	5e                   	pop    %esi
  800722:	5f                   	pop    %edi
  800723:	5d                   	pop    %ebp
  800724:	c3                   	ret    

00800725 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	83 ec 18             	sub    $0x18,%esp
  80072b:	8b 45 08             	mov    0x8(%ebp),%eax
  80072e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800731:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800734:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800738:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800742:	85 c0                	test   %eax,%eax
  800744:	74 26                	je     80076c <vsnprintf+0x47>
  800746:	85 d2                	test   %edx,%edx
  800748:	7e 22                	jle    80076c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074a:	ff 75 14             	pushl  0x14(%ebp)
  80074d:	ff 75 10             	pushl  0x10(%ebp)
  800750:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	68 f8 02 80 00       	push   $0x8002f8
  800759:	e8 d4 fb ff ff       	call   800332 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80075e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800761:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800764:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800767:	83 c4 10             	add    $0x10,%esp
  80076a:	eb 05                	jmp    800771 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80076c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800771:	c9                   	leave  
  800772:	c3                   	ret    

00800773 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800779:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80077c:	50                   	push   %eax
  80077d:	ff 75 10             	pushl  0x10(%ebp)
  800780:	ff 75 0c             	pushl  0xc(%ebp)
  800783:	ff 75 08             	pushl  0x8(%ebp)
  800786:	e8 9a ff ff ff       	call   800725 <vsnprintf>
	va_end(ap);

	return rc;
}
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800793:	b8 00 00 00 00       	mov    $0x0,%eax
  800798:	eb 03                	jmp    80079d <strlen+0x10>
		n++;
  80079a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80079d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a1:	75 f7                	jne    80079a <strlen+0xd>
		n++;
	return n;
}
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ab:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b3:	eb 03                	jmp    8007b8 <strnlen+0x13>
		n++;
  8007b5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b8:	39 c2                	cmp    %eax,%edx
  8007ba:	74 08                	je     8007c4 <strnlen+0x1f>
  8007bc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007c0:	75 f3                	jne    8007b5 <strnlen+0x10>
  8007c2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d0:	89 c2                	mov    %eax,%edx
  8007d2:	83 c2 01             	add    $0x1,%edx
  8007d5:	83 c1 01             	add    $0x1,%ecx
  8007d8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007dc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007df:	84 db                	test   %bl,%bl
  8007e1:	75 ef                	jne    8007d2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007e3:	5b                   	pop    %ebx
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	53                   	push   %ebx
  8007ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ed:	53                   	push   %ebx
  8007ee:	e8 9a ff ff ff       	call   80078d <strlen>
  8007f3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f6:	ff 75 0c             	pushl  0xc(%ebp)
  8007f9:	01 d8                	add    %ebx,%eax
  8007fb:	50                   	push   %eax
  8007fc:	e8 c5 ff ff ff       	call   8007c6 <strcpy>
	return dst;
}
  800801:	89 d8                	mov    %ebx,%eax
  800803:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800806:	c9                   	leave  
  800807:	c3                   	ret    

00800808 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	8b 75 08             	mov    0x8(%ebp),%esi
  800810:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800813:	89 f3                	mov    %esi,%ebx
  800815:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800818:	89 f2                	mov    %esi,%edx
  80081a:	eb 0f                	jmp    80082b <strncpy+0x23>
		*dst++ = *src;
  80081c:	83 c2 01             	add    $0x1,%edx
  80081f:	0f b6 01             	movzbl (%ecx),%eax
  800822:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800825:	80 39 01             	cmpb   $0x1,(%ecx)
  800828:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082b:	39 da                	cmp    %ebx,%edx
  80082d:	75 ed                	jne    80081c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80082f:	89 f0                	mov    %esi,%eax
  800831:	5b                   	pop    %ebx
  800832:	5e                   	pop    %esi
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	56                   	push   %esi
  800839:	53                   	push   %ebx
  80083a:	8b 75 08             	mov    0x8(%ebp),%esi
  80083d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800840:	8b 55 10             	mov    0x10(%ebp),%edx
  800843:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800845:	85 d2                	test   %edx,%edx
  800847:	74 21                	je     80086a <strlcpy+0x35>
  800849:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80084d:	89 f2                	mov    %esi,%edx
  80084f:	eb 09                	jmp    80085a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800851:	83 c2 01             	add    $0x1,%edx
  800854:	83 c1 01             	add    $0x1,%ecx
  800857:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80085a:	39 c2                	cmp    %eax,%edx
  80085c:	74 09                	je     800867 <strlcpy+0x32>
  80085e:	0f b6 19             	movzbl (%ecx),%ebx
  800861:	84 db                	test   %bl,%bl
  800863:	75 ec                	jne    800851 <strlcpy+0x1c>
  800865:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800867:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80086a:	29 f0                	sub    %esi,%eax
}
  80086c:	5b                   	pop    %ebx
  80086d:	5e                   	pop    %esi
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800876:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800879:	eb 06                	jmp    800881 <strcmp+0x11>
		p++, q++;
  80087b:	83 c1 01             	add    $0x1,%ecx
  80087e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800881:	0f b6 01             	movzbl (%ecx),%eax
  800884:	84 c0                	test   %al,%al
  800886:	74 04                	je     80088c <strcmp+0x1c>
  800888:	3a 02                	cmp    (%edx),%al
  80088a:	74 ef                	je     80087b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088c:	0f b6 c0             	movzbl %al,%eax
  80088f:	0f b6 12             	movzbl (%edx),%edx
  800892:	29 d0                	sub    %edx,%eax
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	53                   	push   %ebx
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a0:	89 c3                	mov    %eax,%ebx
  8008a2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a5:	eb 06                	jmp    8008ad <strncmp+0x17>
		n--, p++, q++;
  8008a7:	83 c0 01             	add    $0x1,%eax
  8008aa:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ad:	39 d8                	cmp    %ebx,%eax
  8008af:	74 15                	je     8008c6 <strncmp+0x30>
  8008b1:	0f b6 08             	movzbl (%eax),%ecx
  8008b4:	84 c9                	test   %cl,%cl
  8008b6:	74 04                	je     8008bc <strncmp+0x26>
  8008b8:	3a 0a                	cmp    (%edx),%cl
  8008ba:	74 eb                	je     8008a7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bc:	0f b6 00             	movzbl (%eax),%eax
  8008bf:	0f b6 12             	movzbl (%edx),%edx
  8008c2:	29 d0                	sub    %edx,%eax
  8008c4:	eb 05                	jmp    8008cb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008cb:	5b                   	pop    %ebx
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d8:	eb 07                	jmp    8008e1 <strchr+0x13>
		if (*s == c)
  8008da:	38 ca                	cmp    %cl,%dl
  8008dc:	74 0f                	je     8008ed <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008de:	83 c0 01             	add    $0x1,%eax
  8008e1:	0f b6 10             	movzbl (%eax),%edx
  8008e4:	84 d2                	test   %dl,%dl
  8008e6:	75 f2                	jne    8008da <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f9:	eb 03                	jmp    8008fe <strfind+0xf>
  8008fb:	83 c0 01             	add    $0x1,%eax
  8008fe:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800901:	38 ca                	cmp    %cl,%dl
  800903:	74 04                	je     800909 <strfind+0x1a>
  800905:	84 d2                	test   %dl,%dl
  800907:	75 f2                	jne    8008fb <strfind+0xc>
			break;
	return (char *) s;
}
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	57                   	push   %edi
  80090f:	56                   	push   %esi
  800910:	53                   	push   %ebx
  800911:	8b 7d 08             	mov    0x8(%ebp),%edi
  800914:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800917:	85 c9                	test   %ecx,%ecx
  800919:	74 36                	je     800951 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800921:	75 28                	jne    80094b <memset+0x40>
  800923:	f6 c1 03             	test   $0x3,%cl
  800926:	75 23                	jne    80094b <memset+0x40>
		c &= 0xFF;
  800928:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092c:	89 d3                	mov    %edx,%ebx
  80092e:	c1 e3 08             	shl    $0x8,%ebx
  800931:	89 d6                	mov    %edx,%esi
  800933:	c1 e6 18             	shl    $0x18,%esi
  800936:	89 d0                	mov    %edx,%eax
  800938:	c1 e0 10             	shl    $0x10,%eax
  80093b:	09 f0                	or     %esi,%eax
  80093d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80093f:	89 d8                	mov    %ebx,%eax
  800941:	09 d0                	or     %edx,%eax
  800943:	c1 e9 02             	shr    $0x2,%ecx
  800946:	fc                   	cld    
  800947:	f3 ab                	rep stos %eax,%es:(%edi)
  800949:	eb 06                	jmp    800951 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094e:	fc                   	cld    
  80094f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800951:	89 f8                	mov    %edi,%eax
  800953:	5b                   	pop    %ebx
  800954:	5e                   	pop    %esi
  800955:	5f                   	pop    %edi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	57                   	push   %edi
  80095c:	56                   	push   %esi
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	8b 75 0c             	mov    0xc(%ebp),%esi
  800963:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800966:	39 c6                	cmp    %eax,%esi
  800968:	73 35                	jae    80099f <memmove+0x47>
  80096a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096d:	39 d0                	cmp    %edx,%eax
  80096f:	73 2e                	jae    80099f <memmove+0x47>
		s += n;
		d += n;
  800971:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800974:	89 d6                	mov    %edx,%esi
  800976:	09 fe                	or     %edi,%esi
  800978:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097e:	75 13                	jne    800993 <memmove+0x3b>
  800980:	f6 c1 03             	test   $0x3,%cl
  800983:	75 0e                	jne    800993 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800985:	83 ef 04             	sub    $0x4,%edi
  800988:	8d 72 fc             	lea    -0x4(%edx),%esi
  80098b:	c1 e9 02             	shr    $0x2,%ecx
  80098e:	fd                   	std    
  80098f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800991:	eb 09                	jmp    80099c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800993:	83 ef 01             	sub    $0x1,%edi
  800996:	8d 72 ff             	lea    -0x1(%edx),%esi
  800999:	fd                   	std    
  80099a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099c:	fc                   	cld    
  80099d:	eb 1d                	jmp    8009bc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099f:	89 f2                	mov    %esi,%edx
  8009a1:	09 c2                	or     %eax,%edx
  8009a3:	f6 c2 03             	test   $0x3,%dl
  8009a6:	75 0f                	jne    8009b7 <memmove+0x5f>
  8009a8:	f6 c1 03             	test   $0x3,%cl
  8009ab:	75 0a                	jne    8009b7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009ad:	c1 e9 02             	shr    $0x2,%ecx
  8009b0:	89 c7                	mov    %eax,%edi
  8009b2:	fc                   	cld    
  8009b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b5:	eb 05                	jmp    8009bc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b7:	89 c7                	mov    %eax,%edi
  8009b9:	fc                   	cld    
  8009ba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009bc:	5e                   	pop    %esi
  8009bd:	5f                   	pop    %edi
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009c3:	ff 75 10             	pushl  0x10(%ebp)
  8009c6:	ff 75 0c             	pushl  0xc(%ebp)
  8009c9:	ff 75 08             	pushl  0x8(%ebp)
  8009cc:	e8 87 ff ff ff       	call   800958 <memmove>
}
  8009d1:	c9                   	leave  
  8009d2:	c3                   	ret    

008009d3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	56                   	push   %esi
  8009d7:	53                   	push   %ebx
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009de:	89 c6                	mov    %eax,%esi
  8009e0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e3:	eb 1a                	jmp    8009ff <memcmp+0x2c>
		if (*s1 != *s2)
  8009e5:	0f b6 08             	movzbl (%eax),%ecx
  8009e8:	0f b6 1a             	movzbl (%edx),%ebx
  8009eb:	38 d9                	cmp    %bl,%cl
  8009ed:	74 0a                	je     8009f9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ef:	0f b6 c1             	movzbl %cl,%eax
  8009f2:	0f b6 db             	movzbl %bl,%ebx
  8009f5:	29 d8                	sub    %ebx,%eax
  8009f7:	eb 0f                	jmp    800a08 <memcmp+0x35>
		s1++, s2++;
  8009f9:	83 c0 01             	add    $0x1,%eax
  8009fc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ff:	39 f0                	cmp    %esi,%eax
  800a01:	75 e2                	jne    8009e5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	5b                   	pop    %ebx
  800a09:	5e                   	pop    %esi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	53                   	push   %ebx
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a13:	89 c1                	mov    %eax,%ecx
  800a15:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a18:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1c:	eb 0a                	jmp    800a28 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1e:	0f b6 10             	movzbl (%eax),%edx
  800a21:	39 da                	cmp    %ebx,%edx
  800a23:	74 07                	je     800a2c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a25:	83 c0 01             	add    $0x1,%eax
  800a28:	39 c8                	cmp    %ecx,%eax
  800a2a:	72 f2                	jb     800a1e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a2c:	5b                   	pop    %ebx
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	57                   	push   %edi
  800a33:	56                   	push   %esi
  800a34:	53                   	push   %ebx
  800a35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a38:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3b:	eb 03                	jmp    800a40 <strtol+0x11>
		s++;
  800a3d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a40:	0f b6 01             	movzbl (%ecx),%eax
  800a43:	3c 20                	cmp    $0x20,%al
  800a45:	74 f6                	je     800a3d <strtol+0xe>
  800a47:	3c 09                	cmp    $0x9,%al
  800a49:	74 f2                	je     800a3d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a4b:	3c 2b                	cmp    $0x2b,%al
  800a4d:	75 0a                	jne    800a59 <strtol+0x2a>
		s++;
  800a4f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a52:	bf 00 00 00 00       	mov    $0x0,%edi
  800a57:	eb 11                	jmp    800a6a <strtol+0x3b>
  800a59:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a5e:	3c 2d                	cmp    $0x2d,%al
  800a60:	75 08                	jne    800a6a <strtol+0x3b>
		s++, neg = 1;
  800a62:	83 c1 01             	add    $0x1,%ecx
  800a65:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a70:	75 15                	jne    800a87 <strtol+0x58>
  800a72:	80 39 30             	cmpb   $0x30,(%ecx)
  800a75:	75 10                	jne    800a87 <strtol+0x58>
  800a77:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a7b:	75 7c                	jne    800af9 <strtol+0xca>
		s += 2, base = 16;
  800a7d:	83 c1 02             	add    $0x2,%ecx
  800a80:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a85:	eb 16                	jmp    800a9d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a87:	85 db                	test   %ebx,%ebx
  800a89:	75 12                	jne    800a9d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a8b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a90:	80 39 30             	cmpb   $0x30,(%ecx)
  800a93:	75 08                	jne    800a9d <strtol+0x6e>
		s++, base = 8;
  800a95:	83 c1 01             	add    $0x1,%ecx
  800a98:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa5:	0f b6 11             	movzbl (%ecx),%edx
  800aa8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aab:	89 f3                	mov    %esi,%ebx
  800aad:	80 fb 09             	cmp    $0x9,%bl
  800ab0:	77 08                	ja     800aba <strtol+0x8b>
			dig = *s - '0';
  800ab2:	0f be d2             	movsbl %dl,%edx
  800ab5:	83 ea 30             	sub    $0x30,%edx
  800ab8:	eb 22                	jmp    800adc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aba:	8d 72 9f             	lea    -0x61(%edx),%esi
  800abd:	89 f3                	mov    %esi,%ebx
  800abf:	80 fb 19             	cmp    $0x19,%bl
  800ac2:	77 08                	ja     800acc <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ac4:	0f be d2             	movsbl %dl,%edx
  800ac7:	83 ea 57             	sub    $0x57,%edx
  800aca:	eb 10                	jmp    800adc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800acc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800acf:	89 f3                	mov    %esi,%ebx
  800ad1:	80 fb 19             	cmp    $0x19,%bl
  800ad4:	77 16                	ja     800aec <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ad6:	0f be d2             	movsbl %dl,%edx
  800ad9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800adc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800adf:	7d 0b                	jge    800aec <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ae1:	83 c1 01             	add    $0x1,%ecx
  800ae4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aea:	eb b9                	jmp    800aa5 <strtol+0x76>

	if (endptr)
  800aec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af0:	74 0d                	je     800aff <strtol+0xd0>
		*endptr = (char *) s;
  800af2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af5:	89 0e                	mov    %ecx,(%esi)
  800af7:	eb 06                	jmp    800aff <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af9:	85 db                	test   %ebx,%ebx
  800afb:	74 98                	je     800a95 <strtol+0x66>
  800afd:	eb 9e                	jmp    800a9d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aff:	89 c2                	mov    %eax,%edx
  800b01:	f7 da                	neg    %edx
  800b03:	85 ff                	test   %edi,%edi
  800b05:	0f 45 c2             	cmovne %edx,%eax
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b13:	b8 00 00 00 00       	mov    $0x0,%eax
  800b18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1e:	89 c3                	mov    %eax,%ebx
  800b20:	89 c7                	mov    %eax,%edi
  800b22:	89 c6                	mov    %eax,%esi
  800b24:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b31:	ba 00 00 00 00       	mov    $0x0,%edx
  800b36:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3b:	89 d1                	mov    %edx,%ecx
  800b3d:	89 d3                	mov    %edx,%ebx
  800b3f:	89 d7                	mov    %edx,%edi
  800b41:	89 d6                	mov    %edx,%esi
  800b43:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
  800b50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b58:	b8 03 00 00 00       	mov    $0x3,%eax
  800b5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b60:	89 cb                	mov    %ecx,%ebx
  800b62:	89 cf                	mov    %ecx,%edi
  800b64:	89 ce                	mov    %ecx,%esi
  800b66:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b68:	85 c0                	test   %eax,%eax
  800b6a:	7e 17                	jle    800b83 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6c:	83 ec 0c             	sub    $0xc,%esp
  800b6f:	50                   	push   %eax
  800b70:	6a 03                	push   $0x3
  800b72:	68 a4 13 80 00       	push   $0x8013a4
  800b77:	6a 23                	push   $0x23
  800b79:	68 c1 13 80 00       	push   $0x8013c1
  800b7e:	e8 9f f5 ff ff       	call   800122 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b91:	ba 00 00 00 00       	mov    $0x0,%edx
  800b96:	b8 02 00 00 00       	mov    $0x2,%eax
  800b9b:	89 d1                	mov    %edx,%ecx
  800b9d:	89 d3                	mov    %edx,%ebx
  800b9f:	89 d7                	mov    %edx,%edi
  800ba1:	89 d6                	mov    %edx,%esi
  800ba3:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <sys_yield>:

void
sys_yield(void)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bba:	89 d1                	mov    %edx,%ecx
  800bbc:	89 d3                	mov    %edx,%ebx
  800bbe:	89 d7                	mov    %edx,%edi
  800bc0:	89 d6                	mov    %edx,%esi
  800bc2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd2:	be 00 00 00 00       	mov    $0x0,%esi
  800bd7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800be2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be5:	89 f7                	mov    %esi,%edi
  800be7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be9:	85 c0                	test   %eax,%eax
  800beb:	7e 17                	jle    800c04 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bed:	83 ec 0c             	sub    $0xc,%esp
  800bf0:	50                   	push   %eax
  800bf1:	6a 04                	push   $0x4
  800bf3:	68 a4 13 80 00       	push   $0x8013a4
  800bf8:	6a 23                	push   $0x23
  800bfa:	68 c1 13 80 00       	push   $0x8013c1
  800bff:	e8 1e f5 ff ff       	call   800122 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c07:	5b                   	pop    %ebx
  800c08:	5e                   	pop    %esi
  800c09:	5f                   	pop    %edi
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    

00800c0c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	57                   	push   %edi
  800c10:	56                   	push   %esi
  800c11:	53                   	push   %ebx
  800c12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c15:	b8 05 00 00 00       	mov    $0x5,%eax
  800c1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c23:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c26:	8b 75 18             	mov    0x18(%ebp),%esi
  800c29:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2b:	85 c0                	test   %eax,%eax
  800c2d:	7e 17                	jle    800c46 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2f:	83 ec 0c             	sub    $0xc,%esp
  800c32:	50                   	push   %eax
  800c33:	6a 05                	push   $0x5
  800c35:	68 a4 13 80 00       	push   $0x8013a4
  800c3a:	6a 23                	push   $0x23
  800c3c:	68 c1 13 80 00       	push   $0x8013c1
  800c41:	e8 dc f4 ff ff       	call   800122 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5f                   	pop    %edi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
  800c54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	89 df                	mov    %ebx,%edi
  800c69:	89 de                	mov    %ebx,%esi
  800c6b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6d:	85 c0                	test   %eax,%eax
  800c6f:	7e 17                	jle    800c88 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c71:	83 ec 0c             	sub    $0xc,%esp
  800c74:	50                   	push   %eax
  800c75:	6a 06                	push   $0x6
  800c77:	68 a4 13 80 00       	push   $0x8013a4
  800c7c:	6a 23                	push   $0x23
  800c7e:	68 c1 13 80 00       	push   $0x8013c1
  800c83:	e8 9a f4 ff ff       	call   800122 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	57                   	push   %edi
  800c94:	56                   	push   %esi
  800c95:	53                   	push   %ebx
  800c96:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9e:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	89 df                	mov    %ebx,%edi
  800cab:	89 de                	mov    %ebx,%esi
  800cad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	7e 17                	jle    800cca <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	50                   	push   %eax
  800cb7:	6a 08                	push   $0x8
  800cb9:	68 a4 13 80 00       	push   $0x8013a4
  800cbe:	6a 23                	push   $0x23
  800cc0:	68 c1 13 80 00       	push   $0x8013c1
  800cc5:	e8 58 f4 ff ff       	call   800122 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
  800cd8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce0:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	89 df                	mov    %ebx,%edi
  800ced:	89 de                	mov    %ebx,%esi
  800cef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	7e 17                	jle    800d0c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf5:	83 ec 0c             	sub    $0xc,%esp
  800cf8:	50                   	push   %eax
  800cf9:	6a 09                	push   $0x9
  800cfb:	68 a4 13 80 00       	push   $0x8013a4
  800d00:	6a 23                	push   $0x23
  800d02:	68 c1 13 80 00       	push   $0x8013c1
  800d07:	e8 16 f4 ff ff       	call   800122 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1a:	be 00 00 00 00       	mov    $0x0,%esi
  800d1f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d30:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	57                   	push   %edi
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
  800d3d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d40:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d45:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4d:	89 cb                	mov    %ecx,%ebx
  800d4f:	89 cf                	mov    %ecx,%edi
  800d51:	89 ce                	mov    %ecx,%esi
  800d53:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d55:	85 c0                	test   %eax,%eax
  800d57:	7e 17                	jle    800d70 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d59:	83 ec 0c             	sub    $0xc,%esp
  800d5c:	50                   	push   %eax
  800d5d:	6a 0c                	push   $0xc
  800d5f:	68 a4 13 80 00       	push   $0x8013a4
  800d64:	6a 23                	push   $0x23
  800d66:	68 c1 13 80 00       	push   $0x8013c1
  800d6b:	e8 b2 f3 ff ff       	call   800122 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_change_pr>:

int
sys_change_pr(int pr)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d83:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	89 cb                	mov    %ecx,%ebx
  800d8d:	89 cf                	mov    %ecx,%edi
  800d8f:	89 ce                	mov    %ecx,%esi
  800d91:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	83 ec 08             	sub    $0x8,%esp
	// int r;

	if (_pgfault_handler == 0) {
  800d9e:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800da5:	75 2c                	jne    800dd3 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800da7:	83 ec 04             	sub    $0x4,%esp
  800daa:	6a 07                	push   $0x7
  800dac:	68 00 f0 bf ee       	push   $0xeebff000
  800db1:	6a 00                	push   $0x0
  800db3:	e8 11 fe ff ff       	call   800bc9 <sys_page_alloc>
  800db8:	83 c4 10             	add    $0x10,%esp
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	79 14                	jns    800dd3 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  800dbf:	83 ec 04             	sub    $0x4,%esp
  800dc2:	68 d0 13 80 00       	push   $0x8013d0
  800dc7:	6a 21                	push   $0x21
  800dc9:	68 34 14 80 00       	push   $0x801434
  800dce:	e8 4f f3 ff ff       	call   800122 <_panic>
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd6:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800ddb:	83 ec 08             	sub    $0x8,%esp
  800dde:	68 07 0e 80 00       	push   $0x800e07
  800de3:	6a 00                	push   $0x0
  800de5:	e8 e8 fe ff ff       	call   800cd2 <sys_env_set_pgfault_upcall>
  800dea:	83 c4 10             	add    $0x10,%esp
  800ded:	85 c0                	test   %eax,%eax
  800def:	79 14                	jns    800e05 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800df1:	83 ec 04             	sub    $0x4,%esp
  800df4:	68 fc 13 80 00       	push   $0x8013fc
  800df9:	6a 26                	push   $0x26
  800dfb:	68 34 14 80 00       	push   $0x801434
  800e00:	e8 1d f3 ff ff       	call   800122 <_panic>
}
  800e05:	c9                   	leave  
  800e06:	c3                   	ret    

00800e07 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e07:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e08:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  800e0d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e0f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx #trap-time eip
  800e12:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)
  800e16:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax #trap-time esp-4
  800e1b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)
  800e1f:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp
  800e21:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800e24:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp #eip
  800e25:	83 c4 04             	add    $0x4,%esp
	popfl
  800e28:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e29:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e2a:	c3                   	ret    
  800e2b:	66 90                	xchg   %ax,%ax
  800e2d:	66 90                	xchg   %ax,%ax
  800e2f:	90                   	nop

00800e30 <__udivdi3>:
  800e30:	55                   	push   %ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 1c             	sub    $0x1c,%esp
  800e37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e47:	85 f6                	test   %esi,%esi
  800e49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e4d:	89 ca                	mov    %ecx,%edx
  800e4f:	89 f8                	mov    %edi,%eax
  800e51:	75 3d                	jne    800e90 <__udivdi3+0x60>
  800e53:	39 cf                	cmp    %ecx,%edi
  800e55:	0f 87 c5 00 00 00    	ja     800f20 <__udivdi3+0xf0>
  800e5b:	85 ff                	test   %edi,%edi
  800e5d:	89 fd                	mov    %edi,%ebp
  800e5f:	75 0b                	jne    800e6c <__udivdi3+0x3c>
  800e61:	b8 01 00 00 00       	mov    $0x1,%eax
  800e66:	31 d2                	xor    %edx,%edx
  800e68:	f7 f7                	div    %edi
  800e6a:	89 c5                	mov    %eax,%ebp
  800e6c:	89 c8                	mov    %ecx,%eax
  800e6e:	31 d2                	xor    %edx,%edx
  800e70:	f7 f5                	div    %ebp
  800e72:	89 c1                	mov    %eax,%ecx
  800e74:	89 d8                	mov    %ebx,%eax
  800e76:	89 cf                	mov    %ecx,%edi
  800e78:	f7 f5                	div    %ebp
  800e7a:	89 c3                	mov    %eax,%ebx
  800e7c:	89 d8                	mov    %ebx,%eax
  800e7e:	89 fa                	mov    %edi,%edx
  800e80:	83 c4 1c             	add    $0x1c,%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    
  800e88:	90                   	nop
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	39 ce                	cmp    %ecx,%esi
  800e92:	77 74                	ja     800f08 <__udivdi3+0xd8>
  800e94:	0f bd fe             	bsr    %esi,%edi
  800e97:	83 f7 1f             	xor    $0x1f,%edi
  800e9a:	0f 84 98 00 00 00    	je     800f38 <__udivdi3+0x108>
  800ea0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800ea5:	89 f9                	mov    %edi,%ecx
  800ea7:	89 c5                	mov    %eax,%ebp
  800ea9:	29 fb                	sub    %edi,%ebx
  800eab:	d3 e6                	shl    %cl,%esi
  800ead:	89 d9                	mov    %ebx,%ecx
  800eaf:	d3 ed                	shr    %cl,%ebp
  800eb1:	89 f9                	mov    %edi,%ecx
  800eb3:	d3 e0                	shl    %cl,%eax
  800eb5:	09 ee                	or     %ebp,%esi
  800eb7:	89 d9                	mov    %ebx,%ecx
  800eb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ebd:	89 d5                	mov    %edx,%ebp
  800ebf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ec3:	d3 ed                	shr    %cl,%ebp
  800ec5:	89 f9                	mov    %edi,%ecx
  800ec7:	d3 e2                	shl    %cl,%edx
  800ec9:	89 d9                	mov    %ebx,%ecx
  800ecb:	d3 e8                	shr    %cl,%eax
  800ecd:	09 c2                	or     %eax,%edx
  800ecf:	89 d0                	mov    %edx,%eax
  800ed1:	89 ea                	mov    %ebp,%edx
  800ed3:	f7 f6                	div    %esi
  800ed5:	89 d5                	mov    %edx,%ebp
  800ed7:	89 c3                	mov    %eax,%ebx
  800ed9:	f7 64 24 0c          	mull   0xc(%esp)
  800edd:	39 d5                	cmp    %edx,%ebp
  800edf:	72 10                	jb     800ef1 <__udivdi3+0xc1>
  800ee1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ee5:	89 f9                	mov    %edi,%ecx
  800ee7:	d3 e6                	shl    %cl,%esi
  800ee9:	39 c6                	cmp    %eax,%esi
  800eeb:	73 07                	jae    800ef4 <__udivdi3+0xc4>
  800eed:	39 d5                	cmp    %edx,%ebp
  800eef:	75 03                	jne    800ef4 <__udivdi3+0xc4>
  800ef1:	83 eb 01             	sub    $0x1,%ebx
  800ef4:	31 ff                	xor    %edi,%edi
  800ef6:	89 d8                	mov    %ebx,%eax
  800ef8:	89 fa                	mov    %edi,%edx
  800efa:	83 c4 1c             	add    $0x1c,%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    
  800f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f08:	31 ff                	xor    %edi,%edi
  800f0a:	31 db                	xor    %ebx,%ebx
  800f0c:	89 d8                	mov    %ebx,%eax
  800f0e:	89 fa                	mov    %edi,%edx
  800f10:	83 c4 1c             	add    $0x1c,%esp
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	5f                   	pop    %edi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    
  800f18:	90                   	nop
  800f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f20:	89 d8                	mov    %ebx,%eax
  800f22:	f7 f7                	div    %edi
  800f24:	31 ff                	xor    %edi,%edi
  800f26:	89 c3                	mov    %eax,%ebx
  800f28:	89 d8                	mov    %ebx,%eax
  800f2a:	89 fa                	mov    %edi,%edx
  800f2c:	83 c4 1c             	add    $0x1c,%esp
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    
  800f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f38:	39 ce                	cmp    %ecx,%esi
  800f3a:	72 0c                	jb     800f48 <__udivdi3+0x118>
  800f3c:	31 db                	xor    %ebx,%ebx
  800f3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f42:	0f 87 34 ff ff ff    	ja     800e7c <__udivdi3+0x4c>
  800f48:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f4d:	e9 2a ff ff ff       	jmp    800e7c <__udivdi3+0x4c>
  800f52:	66 90                	xchg   %ax,%ax
  800f54:	66 90                	xchg   %ax,%ax
  800f56:	66 90                	xchg   %ax,%ax
  800f58:	66 90                	xchg   %ax,%ax
  800f5a:	66 90                	xchg   %ax,%ax
  800f5c:	66 90                	xchg   %ax,%ax
  800f5e:	66 90                	xchg   %ax,%ax

00800f60 <__umoddi3>:
  800f60:	55                   	push   %ebp
  800f61:	57                   	push   %edi
  800f62:	56                   	push   %esi
  800f63:	53                   	push   %ebx
  800f64:	83 ec 1c             	sub    $0x1c,%esp
  800f67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f77:	85 d2                	test   %edx,%edx
  800f79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f81:	89 f3                	mov    %esi,%ebx
  800f83:	89 3c 24             	mov    %edi,(%esp)
  800f86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f8a:	75 1c                	jne    800fa8 <__umoddi3+0x48>
  800f8c:	39 f7                	cmp    %esi,%edi
  800f8e:	76 50                	jbe    800fe0 <__umoddi3+0x80>
  800f90:	89 c8                	mov    %ecx,%eax
  800f92:	89 f2                	mov    %esi,%edx
  800f94:	f7 f7                	div    %edi
  800f96:	89 d0                	mov    %edx,%eax
  800f98:	31 d2                	xor    %edx,%edx
  800f9a:	83 c4 1c             	add    $0x1c,%esp
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5f                   	pop    %edi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    
  800fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa8:	39 f2                	cmp    %esi,%edx
  800faa:	89 d0                	mov    %edx,%eax
  800fac:	77 52                	ja     801000 <__umoddi3+0xa0>
  800fae:	0f bd ea             	bsr    %edx,%ebp
  800fb1:	83 f5 1f             	xor    $0x1f,%ebp
  800fb4:	75 5a                	jne    801010 <__umoddi3+0xb0>
  800fb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800fba:	0f 82 e0 00 00 00    	jb     8010a0 <__umoddi3+0x140>
  800fc0:	39 0c 24             	cmp    %ecx,(%esp)
  800fc3:	0f 86 d7 00 00 00    	jbe    8010a0 <__umoddi3+0x140>
  800fc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fcd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fd1:	83 c4 1c             	add    $0x1c,%esp
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5f                   	pop    %edi
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    
  800fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fe0:	85 ff                	test   %edi,%edi
  800fe2:	89 fd                	mov    %edi,%ebp
  800fe4:	75 0b                	jne    800ff1 <__umoddi3+0x91>
  800fe6:	b8 01 00 00 00       	mov    $0x1,%eax
  800feb:	31 d2                	xor    %edx,%edx
  800fed:	f7 f7                	div    %edi
  800fef:	89 c5                	mov    %eax,%ebp
  800ff1:	89 f0                	mov    %esi,%eax
  800ff3:	31 d2                	xor    %edx,%edx
  800ff5:	f7 f5                	div    %ebp
  800ff7:	89 c8                	mov    %ecx,%eax
  800ff9:	f7 f5                	div    %ebp
  800ffb:	89 d0                	mov    %edx,%eax
  800ffd:	eb 99                	jmp    800f98 <__umoddi3+0x38>
  800fff:	90                   	nop
  801000:	89 c8                	mov    %ecx,%eax
  801002:	89 f2                	mov    %esi,%edx
  801004:	83 c4 1c             	add    $0x1c,%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    
  80100c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801010:	8b 34 24             	mov    (%esp),%esi
  801013:	bf 20 00 00 00       	mov    $0x20,%edi
  801018:	89 e9                	mov    %ebp,%ecx
  80101a:	29 ef                	sub    %ebp,%edi
  80101c:	d3 e0                	shl    %cl,%eax
  80101e:	89 f9                	mov    %edi,%ecx
  801020:	89 f2                	mov    %esi,%edx
  801022:	d3 ea                	shr    %cl,%edx
  801024:	89 e9                	mov    %ebp,%ecx
  801026:	09 c2                	or     %eax,%edx
  801028:	89 d8                	mov    %ebx,%eax
  80102a:	89 14 24             	mov    %edx,(%esp)
  80102d:	89 f2                	mov    %esi,%edx
  80102f:	d3 e2                	shl    %cl,%edx
  801031:	89 f9                	mov    %edi,%ecx
  801033:	89 54 24 04          	mov    %edx,0x4(%esp)
  801037:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80103b:	d3 e8                	shr    %cl,%eax
  80103d:	89 e9                	mov    %ebp,%ecx
  80103f:	89 c6                	mov    %eax,%esi
  801041:	d3 e3                	shl    %cl,%ebx
  801043:	89 f9                	mov    %edi,%ecx
  801045:	89 d0                	mov    %edx,%eax
  801047:	d3 e8                	shr    %cl,%eax
  801049:	89 e9                	mov    %ebp,%ecx
  80104b:	09 d8                	or     %ebx,%eax
  80104d:	89 d3                	mov    %edx,%ebx
  80104f:	89 f2                	mov    %esi,%edx
  801051:	f7 34 24             	divl   (%esp)
  801054:	89 d6                	mov    %edx,%esi
  801056:	d3 e3                	shl    %cl,%ebx
  801058:	f7 64 24 04          	mull   0x4(%esp)
  80105c:	39 d6                	cmp    %edx,%esi
  80105e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801062:	89 d1                	mov    %edx,%ecx
  801064:	89 c3                	mov    %eax,%ebx
  801066:	72 08                	jb     801070 <__umoddi3+0x110>
  801068:	75 11                	jne    80107b <__umoddi3+0x11b>
  80106a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80106e:	73 0b                	jae    80107b <__umoddi3+0x11b>
  801070:	2b 44 24 04          	sub    0x4(%esp),%eax
  801074:	1b 14 24             	sbb    (%esp),%edx
  801077:	89 d1                	mov    %edx,%ecx
  801079:	89 c3                	mov    %eax,%ebx
  80107b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80107f:	29 da                	sub    %ebx,%edx
  801081:	19 ce                	sbb    %ecx,%esi
  801083:	89 f9                	mov    %edi,%ecx
  801085:	89 f0                	mov    %esi,%eax
  801087:	d3 e0                	shl    %cl,%eax
  801089:	89 e9                	mov    %ebp,%ecx
  80108b:	d3 ea                	shr    %cl,%edx
  80108d:	89 e9                	mov    %ebp,%ecx
  80108f:	d3 ee                	shr    %cl,%esi
  801091:	09 d0                	or     %edx,%eax
  801093:	89 f2                	mov    %esi,%edx
  801095:	83 c4 1c             	add    $0x1c,%esp
  801098:	5b                   	pop    %ebx
  801099:	5e                   	pop    %esi
  80109a:	5f                   	pop    %edi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    
  80109d:	8d 76 00             	lea    0x0(%esi),%esi
  8010a0:	29 f9                	sub    %edi,%ecx
  8010a2:	19 d6                	sbb    %edx,%esi
  8010a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010ac:	e9 18 ff ff ff       	jmp    800fc9 <__umoddi3+0x69>
