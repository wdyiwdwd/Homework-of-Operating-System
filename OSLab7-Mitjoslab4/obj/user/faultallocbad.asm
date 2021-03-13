
obj/user/faultallocbad：     文件格式 elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800045:	e8 9c 01 00 00       	call   8001e6 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 56 0b 00 00       	call   800bb4 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 e0 10 80 00       	push   $0x8010e0
  80006f:	6a 0f                	push   $0xf
  800071:	68 ca 10 80 00       	push   $0x8010ca
  800076:	e8 92 00 00 00       	call   80010d <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 0c 11 80 00       	push   $0x80110c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 d5 06 00 00       	call   80075e <snprintf>
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
  80009c:	e8 e2 0c 00 00       	call   800d83 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 48 0a 00 00       	call   800af8 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  8000c0:	e8 b1 0a 00 00       	call   800b76 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	c1 e0 07             	shl    $0x7,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800101:	6a 00                	push   $0x0
  800103:	e8 2d 0a 00 00       	call   800b35 <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800112:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800115:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80011b:	e8 56 0a 00 00       	call   800b76 <sys_getenvid>
  800120:	83 ec 0c             	sub    $0xc,%esp
  800123:	ff 75 0c             	pushl  0xc(%ebp)
  800126:	ff 75 08             	pushl  0x8(%ebp)
  800129:	56                   	push   %esi
  80012a:	50                   	push   %eax
  80012b:	68 38 11 80 00       	push   $0x801138
  800130:	e8 b1 00 00 00       	call   8001e6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800135:	83 c4 18             	add    $0x18,%esp
  800138:	53                   	push   %ebx
  800139:	ff 75 10             	pushl  0x10(%ebp)
  80013c:	e8 54 00 00 00       	call   800195 <vcprintf>
	cprintf("\n");
  800141:	c7 04 24 c8 10 80 00 	movl   $0x8010c8,(%esp)
  800148:	e8 99 00 00 00       	call   8001e6 <cprintf>
  80014d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800150:	cc                   	int3   
  800151:	eb fd                	jmp    800150 <_panic+0x43>

00800153 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	53                   	push   %ebx
  800157:	83 ec 04             	sub    $0x4,%esp
  80015a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015d:	8b 13                	mov    (%ebx),%edx
  80015f:	8d 42 01             	lea    0x1(%edx),%eax
  800162:	89 03                	mov    %eax,(%ebx)
  800164:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800167:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800170:	75 1a                	jne    80018c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800172:	83 ec 08             	sub    $0x8,%esp
  800175:	68 ff 00 00 00       	push   $0xff
  80017a:	8d 43 08             	lea    0x8(%ebx),%eax
  80017d:	50                   	push   %eax
  80017e:	e8 75 09 00 00       	call   800af8 <sys_cputs>
		b->idx = 0;
  800183:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800189:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80018c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800190:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800193:	c9                   	leave  
  800194:	c3                   	ret    

00800195 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80019e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a5:	00 00 00 
	b.cnt = 0;
  8001a8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001af:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b2:	ff 75 0c             	pushl  0xc(%ebp)
  8001b5:	ff 75 08             	pushl  0x8(%ebp)
  8001b8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001be:	50                   	push   %eax
  8001bf:	68 53 01 80 00       	push   $0x800153
  8001c4:	e8 54 01 00 00       	call   80031d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c9:	83 c4 08             	add    $0x8,%esp
  8001cc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	e8 1a 09 00 00       	call   800af8 <sys_cputs>

	return b.cnt;
}
  8001de:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ec:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 9d ff ff ff       	call   800195 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001f8:	c9                   	leave  
  8001f9:	c3                   	ret    

008001fa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	57                   	push   %edi
  8001fe:	56                   	push   %esi
  8001ff:	53                   	push   %ebx
  800200:	83 ec 1c             	sub    $0x1c,%esp
  800203:	89 c7                	mov    %eax,%edi
  800205:	89 d6                	mov    %edx,%esi
  800207:	8b 45 08             	mov    0x8(%ebp),%eax
  80020a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80020d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800210:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800213:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800216:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80021e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800221:	39 d3                	cmp    %edx,%ebx
  800223:	72 05                	jb     80022a <printnum+0x30>
  800225:	39 45 10             	cmp    %eax,0x10(%ebp)
  800228:	77 45                	ja     80026f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022a:	83 ec 0c             	sub    $0xc,%esp
  80022d:	ff 75 18             	pushl  0x18(%ebp)
  800230:	8b 45 14             	mov    0x14(%ebp),%eax
  800233:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800236:	53                   	push   %ebx
  800237:	ff 75 10             	pushl  0x10(%ebp)
  80023a:	83 ec 08             	sub    $0x8,%esp
  80023d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800240:	ff 75 e0             	pushl  -0x20(%ebp)
  800243:	ff 75 dc             	pushl  -0x24(%ebp)
  800246:	ff 75 d8             	pushl  -0x28(%ebp)
  800249:	e8 d2 0b 00 00       	call   800e20 <__udivdi3>
  80024e:	83 c4 18             	add    $0x18,%esp
  800251:	52                   	push   %edx
  800252:	50                   	push   %eax
  800253:	89 f2                	mov    %esi,%edx
  800255:	89 f8                	mov    %edi,%eax
  800257:	e8 9e ff ff ff       	call   8001fa <printnum>
  80025c:	83 c4 20             	add    $0x20,%esp
  80025f:	eb 18                	jmp    800279 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	56                   	push   %esi
  800265:	ff 75 18             	pushl  0x18(%ebp)
  800268:	ff d7                	call   *%edi
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	eb 03                	jmp    800272 <printnum+0x78>
  80026f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800272:	83 eb 01             	sub    $0x1,%ebx
  800275:	85 db                	test   %ebx,%ebx
  800277:	7f e8                	jg     800261 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800279:	83 ec 08             	sub    $0x8,%esp
  80027c:	56                   	push   %esi
  80027d:	83 ec 04             	sub    $0x4,%esp
  800280:	ff 75 e4             	pushl  -0x1c(%ebp)
  800283:	ff 75 e0             	pushl  -0x20(%ebp)
  800286:	ff 75 dc             	pushl  -0x24(%ebp)
  800289:	ff 75 d8             	pushl  -0x28(%ebp)
  80028c:	e8 bf 0c 00 00       	call   800f50 <__umoddi3>
  800291:	83 c4 14             	add    $0x14,%esp
  800294:	0f be 80 5b 11 80 00 	movsbl 0x80115b(%eax),%eax
  80029b:	50                   	push   %eax
  80029c:	ff d7                	call   *%edi
}
  80029e:	83 c4 10             	add    $0x10,%esp
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ac:	83 fa 01             	cmp    $0x1,%edx
  8002af:	7e 0e                	jle    8002bf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b1:	8b 10                	mov    (%eax),%edx
  8002b3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b6:	89 08                	mov    %ecx,(%eax)
  8002b8:	8b 02                	mov    (%edx),%eax
  8002ba:	8b 52 04             	mov    0x4(%edx),%edx
  8002bd:	eb 22                	jmp    8002e1 <getuint+0x38>
	else if (lflag)
  8002bf:	85 d2                	test   %edx,%edx
  8002c1:	74 10                	je     8002d3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c3:	8b 10                	mov    (%eax),%edx
  8002c5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c8:	89 08                	mov    %ecx,(%eax)
  8002ca:	8b 02                	mov    (%edx),%eax
  8002cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d1:	eb 0e                	jmp    8002e1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d8:	89 08                	mov    %ecx,(%eax)
  8002da:	8b 02                	mov    (%edx),%eax
  8002dc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f2:	73 0a                	jae    8002fe <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fc:	88 02                	mov    %al,(%edx)
}
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800306:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800309:	50                   	push   %eax
  80030a:	ff 75 10             	pushl  0x10(%ebp)
  80030d:	ff 75 0c             	pushl  0xc(%ebp)
  800310:	ff 75 08             	pushl  0x8(%ebp)
  800313:	e8 05 00 00 00       	call   80031d <vprintfmt>
	va_end(ap);
}
  800318:	83 c4 10             	add    $0x10,%esp
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 2c             	sub    $0x2c,%esp
  800326:	8b 75 08             	mov    0x8(%ebp),%esi
  800329:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80032f:	eb 1d                	jmp    80034e <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800331:	85 c0                	test   %eax,%eax
  800333:	75 0f                	jne    800344 <vprintfmt+0x27>
				csa = 0x0700;
  800335:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80033c:	07 00 00 
				return;
  80033f:	e9 c4 03 00 00       	jmp    800708 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	53                   	push   %ebx
  800348:	50                   	push   %eax
  800349:	ff d6                	call   *%esi
  80034b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034e:	83 c7 01             	add    $0x1,%edi
  800351:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800355:	83 f8 25             	cmp    $0x25,%eax
  800358:	75 d7                	jne    800331 <vprintfmt+0x14>
  80035a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800365:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800373:	ba 00 00 00 00       	mov    $0x0,%edx
  800378:	eb 07                	jmp    800381 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8d 47 01             	lea    0x1(%edi),%eax
  800384:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800387:	0f b6 07             	movzbl (%edi),%eax
  80038a:	0f b6 c8             	movzbl %al,%ecx
  80038d:	83 e8 23             	sub    $0x23,%eax
  800390:	3c 55                	cmp    $0x55,%al
  800392:	0f 87 55 03 00 00    	ja     8006ed <vprintfmt+0x3d0>
  800398:	0f b6 c0             	movzbl %al,%eax
  80039b:	ff 24 85 20 12 80 00 	jmp    *0x801220(,%eax,4)
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a9:	eb d6                	jmp    800381 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003bd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c3:	83 fa 09             	cmp    $0x9,%edx
  8003c6:	77 39                	ja     800401 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003cb:	eb e9                	jmp    8003b6 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d6:	8b 00                	mov    (%eax),%eax
  8003d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003de:	eb 27                	jmp    800407 <vprintfmt+0xea>
  8003e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ea:	0f 49 c8             	cmovns %eax,%ecx
  8003ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f3:	eb 8c                	jmp    800381 <vprintfmt+0x64>
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ff:	eb 80                	jmp    800381 <vprintfmt+0x64>
  800401:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800404:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800407:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040b:	0f 89 70 ff ff ff    	jns    800381 <vprintfmt+0x64>
				width = precision, precision = -1;
  800411:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800414:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800417:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041e:	e9 5e ff ff ff       	jmp    800381 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800423:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800429:	e9 53 ff ff ff       	jmp    800381 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	83 ec 08             	sub    $0x8,%esp
  80043a:	53                   	push   %ebx
  80043b:	ff 30                	pushl  (%eax)
  80043d:	ff d6                	call   *%esi
			break;
  80043f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800445:	e9 04 ff ff ff       	jmp    80034e <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	8d 50 04             	lea    0x4(%eax),%edx
  800450:	89 55 14             	mov    %edx,0x14(%ebp)
  800453:	8b 00                	mov    (%eax),%eax
  800455:	99                   	cltd   
  800456:	31 d0                	xor    %edx,%eax
  800458:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045a:	83 f8 08             	cmp    $0x8,%eax
  80045d:	7f 0b                	jg     80046a <vprintfmt+0x14d>
  80045f:	8b 14 85 80 13 80 00 	mov    0x801380(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	75 18                	jne    800482 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  80046a:	50                   	push   %eax
  80046b:	68 73 11 80 00       	push   $0x801173
  800470:	53                   	push   %ebx
  800471:	56                   	push   %esi
  800472:	e8 89 fe ff ff       	call   800300 <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047d:	e9 cc fe ff ff       	jmp    80034e <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  800482:	52                   	push   %edx
  800483:	68 7c 11 80 00       	push   $0x80117c
  800488:	53                   	push   %ebx
  800489:	56                   	push   %esi
  80048a:	e8 71 fe ff ff       	call   800300 <printfmt>
  80048f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800495:	e9 b4 fe ff ff       	jmp    80034e <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 50 04             	lea    0x4(%eax),%edx
  8004a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a5:	85 ff                	test   %edi,%edi
  8004a7:	b8 6c 11 80 00       	mov    $0x80116c,%eax
  8004ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b3:	0f 8e 94 00 00 00    	jle    80054d <vprintfmt+0x230>
  8004b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004bd:	0f 84 98 00 00 00    	je     80055b <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c9:	57                   	push   %edi
  8004ca:	e8 c1 02 00 00       	call   800790 <strnlen>
  8004cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d2:	29 c1                	sub    %eax,%ecx
  8004d4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	eb 0f                	jmp    8004f7 <vprintfmt+0x1da>
					putch(padc, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	83 ef 01             	sub    $0x1,%edi
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	85 ff                	test   %edi,%edi
  8004f9:	7f ed                	jg     8004e8 <vprintfmt+0x1cb>
  8004fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800501:	85 c9                	test   %ecx,%ecx
  800503:	b8 00 00 00 00       	mov    $0x0,%eax
  800508:	0f 49 c1             	cmovns %ecx,%eax
  80050b:	29 c1                	sub    %eax,%ecx
  80050d:	89 75 08             	mov    %esi,0x8(%ebp)
  800510:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800516:	89 cb                	mov    %ecx,%ebx
  800518:	eb 4d                	jmp    800567 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051e:	74 1b                	je     80053b <vprintfmt+0x21e>
  800520:	0f be c0             	movsbl %al,%eax
  800523:	83 e8 20             	sub    $0x20,%eax
  800526:	83 f8 5e             	cmp    $0x5e,%eax
  800529:	76 10                	jbe    80053b <vprintfmt+0x21e>
					putch('?', putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	ff 75 0c             	pushl  0xc(%ebp)
  800531:	6a 3f                	push   $0x3f
  800533:	ff 55 08             	call   *0x8(%ebp)
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	eb 0d                	jmp    800548 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	ff 75 0c             	pushl  0xc(%ebp)
  800541:	52                   	push   %edx
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800548:	83 eb 01             	sub    $0x1,%ebx
  80054b:	eb 1a                	jmp    800567 <vprintfmt+0x24a>
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800559:	eb 0c                	jmp    800567 <vprintfmt+0x24a>
  80055b:	89 75 08             	mov    %esi,0x8(%ebp)
  80055e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800561:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800564:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800567:	83 c7 01             	add    $0x1,%edi
  80056a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056e:	0f be d0             	movsbl %al,%edx
  800571:	85 d2                	test   %edx,%edx
  800573:	74 23                	je     800598 <vprintfmt+0x27b>
  800575:	85 f6                	test   %esi,%esi
  800577:	78 a1                	js     80051a <vprintfmt+0x1fd>
  800579:	83 ee 01             	sub    $0x1,%esi
  80057c:	79 9c                	jns    80051a <vprintfmt+0x1fd>
  80057e:	89 df                	mov    %ebx,%edi
  800580:	8b 75 08             	mov    0x8(%ebp),%esi
  800583:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800586:	eb 18                	jmp    8005a0 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	53                   	push   %ebx
  80058c:	6a 20                	push   $0x20
  80058e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800590:	83 ef 01             	sub    $0x1,%edi
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	eb 08                	jmp    8005a0 <vprintfmt+0x283>
  800598:	89 df                	mov    %ebx,%edi
  80059a:	8b 75 08             	mov    0x8(%ebp),%esi
  80059d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a0:	85 ff                	test   %edi,%edi
  8005a2:	7f e4                	jg     800588 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a7:	e9 a2 fd ff ff       	jmp    80034e <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ac:	83 fa 01             	cmp    $0x1,%edx
  8005af:	7e 16                	jle    8005c7 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 08             	lea    0x8(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ba:	8b 50 04             	mov    0x4(%eax),%edx
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c5:	eb 32                	jmp    8005f9 <vprintfmt+0x2dc>
	else if (lflag)
  8005c7:	85 d2                	test   %edx,%edx
  8005c9:	74 18                	je     8005e3 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 04             	lea    0x4(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d9:	89 c1                	mov    %eax,%ecx
  8005db:	c1 f9 1f             	sar    $0x1f,%ecx
  8005de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e1:	eb 16                	jmp    8005f9 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 50 04             	lea    0x4(%eax),%edx
  8005e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f1:	89 c1                	mov    %eax,%ecx
  8005f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800604:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800608:	79 74                	jns    80067e <vprintfmt+0x361>
				putch('-', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 2d                	push   $0x2d
  800610:	ff d6                	call   *%esi
				num = -(long long) num;
  800612:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800615:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800618:	f7 d8                	neg    %eax
  80061a:	83 d2 00             	adc    $0x0,%edx
  80061d:	f7 da                	neg    %edx
  80061f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800622:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800627:	eb 55                	jmp    80067e <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800629:	8d 45 14             	lea    0x14(%ebp),%eax
  80062c:	e8 78 fc ff ff       	call   8002a9 <getuint>
			base = 10;
  800631:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800636:	eb 46                	jmp    80067e <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800638:	8d 45 14             	lea    0x14(%ebp),%eax
  80063b:	e8 69 fc ff ff       	call   8002a9 <getuint>
      base = 8;
  800640:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800645:	eb 37                	jmp    80067e <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	53                   	push   %ebx
  80064b:	6a 30                	push   $0x30
  80064d:	ff d6                	call   *%esi
			putch('x', putdat);
  80064f:	83 c4 08             	add    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	6a 78                	push   $0x78
  800655:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 50 04             	lea    0x4(%eax),%edx
  80065d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800660:	8b 00                	mov    (%eax),%eax
  800662:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800667:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80066f:	eb 0d                	jmp    80067e <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800671:	8d 45 14             	lea    0x14(%ebp),%eax
  800674:	e8 30 fc ff ff       	call   8002a9 <getuint>
			base = 16;
  800679:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067e:	83 ec 0c             	sub    $0xc,%esp
  800681:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800685:	57                   	push   %edi
  800686:	ff 75 e0             	pushl  -0x20(%ebp)
  800689:	51                   	push   %ecx
  80068a:	52                   	push   %edx
  80068b:	50                   	push   %eax
  80068c:	89 da                	mov    %ebx,%edx
  80068e:	89 f0                	mov    %esi,%eax
  800690:	e8 65 fb ff ff       	call   8001fa <printnum>
			break;
  800695:	83 c4 20             	add    $0x20,%esp
  800698:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069b:	e9 ae fc ff ff       	jmp    80034e <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a0:	83 ec 08             	sub    $0x8,%esp
  8006a3:	53                   	push   %ebx
  8006a4:	51                   	push   %ecx
  8006a5:	ff d6                	call   *%esi
			break;
  8006a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ad:	e9 9c fc ff ff       	jmp    80034e <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b2:	83 fa 01             	cmp    $0x1,%edx
  8006b5:	7e 0d                	jle    8006c4 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8d 50 08             	lea    0x8(%eax),%edx
  8006bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c0:	8b 00                	mov    (%eax),%eax
  8006c2:	eb 1c                	jmp    8006e0 <vprintfmt+0x3c3>
	else if (lflag)
  8006c4:	85 d2                	test   %edx,%edx
  8006c6:	74 0d                	je     8006d5 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d1:	8b 00                	mov    (%eax),%eax
  8006d3:	eb 0b                	jmp    8006e0 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8d 50 04             	lea    0x4(%eax),%edx
  8006db:	89 55 14             	mov    %edx,0x14(%ebp)
  8006de:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  8006e0:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  8006e8:	e9 61 fc ff ff       	jmp    80034e <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	53                   	push   %ebx
  8006f1:	6a 25                	push   $0x25
  8006f3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	eb 03                	jmp    8006fd <vprintfmt+0x3e0>
  8006fa:	83 ef 01             	sub    $0x1,%edi
  8006fd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800701:	75 f7                	jne    8006fa <vprintfmt+0x3dd>
  800703:	e9 46 fc ff ff       	jmp    80034e <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800708:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070b:	5b                   	pop    %ebx
  80070c:	5e                   	pop    %esi
  80070d:	5f                   	pop    %edi
  80070e:	5d                   	pop    %ebp
  80070f:	c3                   	ret    

00800710 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	83 ec 18             	sub    $0x18,%esp
  800716:	8b 45 08             	mov    0x8(%ebp),%eax
  800719:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800723:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800726:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072d:	85 c0                	test   %eax,%eax
  80072f:	74 26                	je     800757 <vsnprintf+0x47>
  800731:	85 d2                	test   %edx,%edx
  800733:	7e 22                	jle    800757 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800735:	ff 75 14             	pushl  0x14(%ebp)
  800738:	ff 75 10             	pushl  0x10(%ebp)
  80073b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073e:	50                   	push   %eax
  80073f:	68 e3 02 80 00       	push   $0x8002e3
  800744:	e8 d4 fb ff ff       	call   80031d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800749:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	eb 05                	jmp    80075c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800757:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    

0080075e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800764:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800767:	50                   	push   %eax
  800768:	ff 75 10             	pushl  0x10(%ebp)
  80076b:	ff 75 0c             	pushl  0xc(%ebp)
  80076e:	ff 75 08             	pushl  0x8(%ebp)
  800771:	e8 9a ff ff ff       	call   800710 <vsnprintf>
	va_end(ap);

	return rc;
}
  800776:	c9                   	leave  
  800777:	c3                   	ret    

00800778 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077e:	b8 00 00 00 00       	mov    $0x0,%eax
  800783:	eb 03                	jmp    800788 <strlen+0x10>
		n++;
  800785:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800788:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078c:	75 f7                	jne    800785 <strlen+0xd>
		n++;
	return n;
}
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800796:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800799:	ba 00 00 00 00       	mov    $0x0,%edx
  80079e:	eb 03                	jmp    8007a3 <strnlen+0x13>
		n++;
  8007a0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a3:	39 c2                	cmp    %eax,%edx
  8007a5:	74 08                	je     8007af <strnlen+0x1f>
  8007a7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ab:	75 f3                	jne    8007a0 <strnlen+0x10>
  8007ad:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	53                   	push   %ebx
  8007b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bb:	89 c2                	mov    %eax,%edx
  8007bd:	83 c2 01             	add    $0x1,%edx
  8007c0:	83 c1 01             	add    $0x1,%ecx
  8007c3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ca:	84 db                	test   %bl,%bl
  8007cc:	75 ef                	jne    8007bd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ce:	5b                   	pop    %ebx
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	53                   	push   %ebx
  8007d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d8:	53                   	push   %ebx
  8007d9:	e8 9a ff ff ff       	call   800778 <strlen>
  8007de:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e1:	ff 75 0c             	pushl  0xc(%ebp)
  8007e4:	01 d8                	add    %ebx,%eax
  8007e6:	50                   	push   %eax
  8007e7:	e8 c5 ff ff ff       	call   8007b1 <strcpy>
	return dst;
}
  8007ec:	89 d8                	mov    %ebx,%eax
  8007ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f1:	c9                   	leave  
  8007f2:	c3                   	ret    

008007f3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	56                   	push   %esi
  8007f7:	53                   	push   %ebx
  8007f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fe:	89 f3                	mov    %esi,%ebx
  800800:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800803:	89 f2                	mov    %esi,%edx
  800805:	eb 0f                	jmp    800816 <strncpy+0x23>
		*dst++ = *src;
  800807:	83 c2 01             	add    $0x1,%edx
  80080a:	0f b6 01             	movzbl (%ecx),%eax
  80080d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800810:	80 39 01             	cmpb   $0x1,(%ecx)
  800813:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800816:	39 da                	cmp    %ebx,%edx
  800818:	75 ed                	jne    800807 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081a:	89 f0                	mov    %esi,%eax
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	56                   	push   %esi
  800824:	53                   	push   %ebx
  800825:	8b 75 08             	mov    0x8(%ebp),%esi
  800828:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082b:	8b 55 10             	mov    0x10(%ebp),%edx
  80082e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800830:	85 d2                	test   %edx,%edx
  800832:	74 21                	je     800855 <strlcpy+0x35>
  800834:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800838:	89 f2                	mov    %esi,%edx
  80083a:	eb 09                	jmp    800845 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80083c:	83 c2 01             	add    $0x1,%edx
  80083f:	83 c1 01             	add    $0x1,%ecx
  800842:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800845:	39 c2                	cmp    %eax,%edx
  800847:	74 09                	je     800852 <strlcpy+0x32>
  800849:	0f b6 19             	movzbl (%ecx),%ebx
  80084c:	84 db                	test   %bl,%bl
  80084e:	75 ec                	jne    80083c <strlcpy+0x1c>
  800850:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800852:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800855:	29 f0                	sub    %esi,%eax
}
  800857:	5b                   	pop    %ebx
  800858:	5e                   	pop    %esi
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800861:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800864:	eb 06                	jmp    80086c <strcmp+0x11>
		p++, q++;
  800866:	83 c1 01             	add    $0x1,%ecx
  800869:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80086c:	0f b6 01             	movzbl (%ecx),%eax
  80086f:	84 c0                	test   %al,%al
  800871:	74 04                	je     800877 <strcmp+0x1c>
  800873:	3a 02                	cmp    (%edx),%al
  800875:	74 ef                	je     800866 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800877:	0f b6 c0             	movzbl %al,%eax
  80087a:	0f b6 12             	movzbl (%edx),%edx
  80087d:	29 d0                	sub    %edx,%eax
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	53                   	push   %ebx
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088b:	89 c3                	mov    %eax,%ebx
  80088d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800890:	eb 06                	jmp    800898 <strncmp+0x17>
		n--, p++, q++;
  800892:	83 c0 01             	add    $0x1,%eax
  800895:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800898:	39 d8                	cmp    %ebx,%eax
  80089a:	74 15                	je     8008b1 <strncmp+0x30>
  80089c:	0f b6 08             	movzbl (%eax),%ecx
  80089f:	84 c9                	test   %cl,%cl
  8008a1:	74 04                	je     8008a7 <strncmp+0x26>
  8008a3:	3a 0a                	cmp    (%edx),%cl
  8008a5:	74 eb                	je     800892 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a7:	0f b6 00             	movzbl (%eax),%eax
  8008aa:	0f b6 12             	movzbl (%edx),%edx
  8008ad:	29 d0                	sub    %edx,%eax
  8008af:	eb 05                	jmp    8008b6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b6:	5b                   	pop    %ebx
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c3:	eb 07                	jmp    8008cc <strchr+0x13>
		if (*s == c)
  8008c5:	38 ca                	cmp    %cl,%dl
  8008c7:	74 0f                	je     8008d8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c9:	83 c0 01             	add    $0x1,%eax
  8008cc:	0f b6 10             	movzbl (%eax),%edx
  8008cf:	84 d2                	test   %dl,%dl
  8008d1:	75 f2                	jne    8008c5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e4:	eb 03                	jmp    8008e9 <strfind+0xf>
  8008e6:	83 c0 01             	add    $0x1,%eax
  8008e9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ec:	38 ca                	cmp    %cl,%dl
  8008ee:	74 04                	je     8008f4 <strfind+0x1a>
  8008f0:	84 d2                	test   %dl,%dl
  8008f2:	75 f2                	jne    8008e6 <strfind+0xc>
			break;
	return (char *) s;
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	57                   	push   %edi
  8008fa:	56                   	push   %esi
  8008fb:	53                   	push   %ebx
  8008fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800902:	85 c9                	test   %ecx,%ecx
  800904:	74 36                	je     80093c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800906:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090c:	75 28                	jne    800936 <memset+0x40>
  80090e:	f6 c1 03             	test   $0x3,%cl
  800911:	75 23                	jne    800936 <memset+0x40>
		c &= 0xFF;
  800913:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800917:	89 d3                	mov    %edx,%ebx
  800919:	c1 e3 08             	shl    $0x8,%ebx
  80091c:	89 d6                	mov    %edx,%esi
  80091e:	c1 e6 18             	shl    $0x18,%esi
  800921:	89 d0                	mov    %edx,%eax
  800923:	c1 e0 10             	shl    $0x10,%eax
  800926:	09 f0                	or     %esi,%eax
  800928:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80092a:	89 d8                	mov    %ebx,%eax
  80092c:	09 d0                	or     %edx,%eax
  80092e:	c1 e9 02             	shr    $0x2,%ecx
  800931:	fc                   	cld    
  800932:	f3 ab                	rep stos %eax,%es:(%edi)
  800934:	eb 06                	jmp    80093c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800936:	8b 45 0c             	mov    0xc(%ebp),%eax
  800939:	fc                   	cld    
  80093a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093c:	89 f8                	mov    %edi,%eax
  80093e:	5b                   	pop    %ebx
  80093f:	5e                   	pop    %esi
  800940:	5f                   	pop    %edi
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	57                   	push   %edi
  800947:	56                   	push   %esi
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800951:	39 c6                	cmp    %eax,%esi
  800953:	73 35                	jae    80098a <memmove+0x47>
  800955:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800958:	39 d0                	cmp    %edx,%eax
  80095a:	73 2e                	jae    80098a <memmove+0x47>
		s += n;
		d += n;
  80095c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095f:	89 d6                	mov    %edx,%esi
  800961:	09 fe                	or     %edi,%esi
  800963:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800969:	75 13                	jne    80097e <memmove+0x3b>
  80096b:	f6 c1 03             	test   $0x3,%cl
  80096e:	75 0e                	jne    80097e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800970:	83 ef 04             	sub    $0x4,%edi
  800973:	8d 72 fc             	lea    -0x4(%edx),%esi
  800976:	c1 e9 02             	shr    $0x2,%ecx
  800979:	fd                   	std    
  80097a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097c:	eb 09                	jmp    800987 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80097e:	83 ef 01             	sub    $0x1,%edi
  800981:	8d 72 ff             	lea    -0x1(%edx),%esi
  800984:	fd                   	std    
  800985:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800987:	fc                   	cld    
  800988:	eb 1d                	jmp    8009a7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098a:	89 f2                	mov    %esi,%edx
  80098c:	09 c2                	or     %eax,%edx
  80098e:	f6 c2 03             	test   $0x3,%dl
  800991:	75 0f                	jne    8009a2 <memmove+0x5f>
  800993:	f6 c1 03             	test   $0x3,%cl
  800996:	75 0a                	jne    8009a2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800998:	c1 e9 02             	shr    $0x2,%ecx
  80099b:	89 c7                	mov    %eax,%edi
  80099d:	fc                   	cld    
  80099e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a0:	eb 05                	jmp    8009a7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a2:	89 c7                	mov    %eax,%edi
  8009a4:	fc                   	cld    
  8009a5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a7:	5e                   	pop    %esi
  8009a8:	5f                   	pop    %edi
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ae:	ff 75 10             	pushl  0x10(%ebp)
  8009b1:	ff 75 0c             	pushl  0xc(%ebp)
  8009b4:	ff 75 08             	pushl  0x8(%ebp)
  8009b7:	e8 87 ff ff ff       	call   800943 <memmove>
}
  8009bc:	c9                   	leave  
  8009bd:	c3                   	ret    

008009be <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c9:	89 c6                	mov    %eax,%esi
  8009cb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ce:	eb 1a                	jmp    8009ea <memcmp+0x2c>
		if (*s1 != *s2)
  8009d0:	0f b6 08             	movzbl (%eax),%ecx
  8009d3:	0f b6 1a             	movzbl (%edx),%ebx
  8009d6:	38 d9                	cmp    %bl,%cl
  8009d8:	74 0a                	je     8009e4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009da:	0f b6 c1             	movzbl %cl,%eax
  8009dd:	0f b6 db             	movzbl %bl,%ebx
  8009e0:	29 d8                	sub    %ebx,%eax
  8009e2:	eb 0f                	jmp    8009f3 <memcmp+0x35>
		s1++, s2++;
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ea:	39 f0                	cmp    %esi,%eax
  8009ec:	75 e2                	jne    8009d0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f3:	5b                   	pop    %ebx
  8009f4:	5e                   	pop    %esi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	53                   	push   %ebx
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009fe:	89 c1                	mov    %eax,%ecx
  800a00:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a03:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a07:	eb 0a                	jmp    800a13 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a09:	0f b6 10             	movzbl (%eax),%edx
  800a0c:	39 da                	cmp    %ebx,%edx
  800a0e:	74 07                	je     800a17 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a10:	83 c0 01             	add    $0x1,%eax
  800a13:	39 c8                	cmp    %ecx,%eax
  800a15:	72 f2                	jb     800a09 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a17:	5b                   	pop    %ebx
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	57                   	push   %edi
  800a1e:	56                   	push   %esi
  800a1f:	53                   	push   %ebx
  800a20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a26:	eb 03                	jmp    800a2b <strtol+0x11>
		s++;
  800a28:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2b:	0f b6 01             	movzbl (%ecx),%eax
  800a2e:	3c 20                	cmp    $0x20,%al
  800a30:	74 f6                	je     800a28 <strtol+0xe>
  800a32:	3c 09                	cmp    $0x9,%al
  800a34:	74 f2                	je     800a28 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a36:	3c 2b                	cmp    $0x2b,%al
  800a38:	75 0a                	jne    800a44 <strtol+0x2a>
		s++;
  800a3a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a3d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a42:	eb 11                	jmp    800a55 <strtol+0x3b>
  800a44:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a49:	3c 2d                	cmp    $0x2d,%al
  800a4b:	75 08                	jne    800a55 <strtol+0x3b>
		s++, neg = 1;
  800a4d:	83 c1 01             	add    $0x1,%ecx
  800a50:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a55:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a5b:	75 15                	jne    800a72 <strtol+0x58>
  800a5d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a60:	75 10                	jne    800a72 <strtol+0x58>
  800a62:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a66:	75 7c                	jne    800ae4 <strtol+0xca>
		s += 2, base = 16;
  800a68:	83 c1 02             	add    $0x2,%ecx
  800a6b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a70:	eb 16                	jmp    800a88 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a72:	85 db                	test   %ebx,%ebx
  800a74:	75 12                	jne    800a88 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a76:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a7b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a7e:	75 08                	jne    800a88 <strtol+0x6e>
		s++, base = 8;
  800a80:	83 c1 01             	add    $0x1,%ecx
  800a83:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a88:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a90:	0f b6 11             	movzbl (%ecx),%edx
  800a93:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a96:	89 f3                	mov    %esi,%ebx
  800a98:	80 fb 09             	cmp    $0x9,%bl
  800a9b:	77 08                	ja     800aa5 <strtol+0x8b>
			dig = *s - '0';
  800a9d:	0f be d2             	movsbl %dl,%edx
  800aa0:	83 ea 30             	sub    $0x30,%edx
  800aa3:	eb 22                	jmp    800ac7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aa5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa8:	89 f3                	mov    %esi,%ebx
  800aaa:	80 fb 19             	cmp    $0x19,%bl
  800aad:	77 08                	ja     800ab7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aaf:	0f be d2             	movsbl %dl,%edx
  800ab2:	83 ea 57             	sub    $0x57,%edx
  800ab5:	eb 10                	jmp    800ac7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ab7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aba:	89 f3                	mov    %esi,%ebx
  800abc:	80 fb 19             	cmp    $0x19,%bl
  800abf:	77 16                	ja     800ad7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac1:	0f be d2             	movsbl %dl,%edx
  800ac4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ac7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aca:	7d 0b                	jge    800ad7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800acc:	83 c1 01             	add    $0x1,%ecx
  800acf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ad5:	eb b9                	jmp    800a90 <strtol+0x76>

	if (endptr)
  800ad7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800adb:	74 0d                	je     800aea <strtol+0xd0>
		*endptr = (char *) s;
  800add:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae0:	89 0e                	mov    %ecx,(%esi)
  800ae2:	eb 06                	jmp    800aea <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae4:	85 db                	test   %ebx,%ebx
  800ae6:	74 98                	je     800a80 <strtol+0x66>
  800ae8:	eb 9e                	jmp    800a88 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aea:	89 c2                	mov    %eax,%edx
  800aec:	f7 da                	neg    %edx
  800aee:	85 ff                	test   %edi,%edi
  800af0:	0f 45 c2             	cmovne %edx,%eax
}
  800af3:	5b                   	pop    %ebx
  800af4:	5e                   	pop    %esi
  800af5:	5f                   	pop    %edi
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    

00800af8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	57                   	push   %edi
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afe:	b8 00 00 00 00       	mov    $0x0,%eax
  800b03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b06:	8b 55 08             	mov    0x8(%ebp),%edx
  800b09:	89 c3                	mov    %eax,%ebx
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	89 c6                	mov    %eax,%esi
  800b0f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b21:	b8 01 00 00 00       	mov    $0x1,%eax
  800b26:	89 d1                	mov    %edx,%ecx
  800b28:	89 d3                	mov    %edx,%ebx
  800b2a:	89 d7                	mov    %edx,%edi
  800b2c:	89 d6                	mov    %edx,%esi
  800b2e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b43:	b8 03 00 00 00       	mov    $0x3,%eax
  800b48:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4b:	89 cb                	mov    %ecx,%ebx
  800b4d:	89 cf                	mov    %ecx,%edi
  800b4f:	89 ce                	mov    %ecx,%esi
  800b51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b53:	85 c0                	test   %eax,%eax
  800b55:	7e 17                	jle    800b6e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b57:	83 ec 0c             	sub    $0xc,%esp
  800b5a:	50                   	push   %eax
  800b5b:	6a 03                	push   $0x3
  800b5d:	68 a4 13 80 00       	push   $0x8013a4
  800b62:	6a 23                	push   $0x23
  800b64:	68 c1 13 80 00       	push   $0x8013c1
  800b69:	e8 9f f5 ff ff       	call   80010d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b81:	b8 02 00 00 00       	mov    $0x2,%eax
  800b86:	89 d1                	mov    %edx,%ecx
  800b88:	89 d3                	mov    %edx,%ebx
  800b8a:	89 d7                	mov    %edx,%edi
  800b8c:	89 d6                	mov    %edx,%esi
  800b8e:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <sys_yield>:

void
sys_yield(void)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ba5:	89 d1                	mov    %edx,%ecx
  800ba7:	89 d3                	mov    %edx,%ebx
  800ba9:	89 d7                	mov    %edx,%edi
  800bab:	89 d6                	mov    %edx,%esi
  800bad:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	be 00 00 00 00       	mov    $0x0,%esi
  800bc2:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bca:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd0:	89 f7                	mov    %esi,%edi
  800bd2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	7e 17                	jle    800bef <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd8:	83 ec 0c             	sub    $0xc,%esp
  800bdb:	50                   	push   %eax
  800bdc:	6a 04                	push   $0x4
  800bde:	68 a4 13 80 00       	push   $0x8013a4
  800be3:	6a 23                	push   $0x23
  800be5:	68 c1 13 80 00       	push   $0x8013c1
  800bea:	e8 1e f5 ff ff       	call   80010d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c00:	b8 05 00 00 00       	mov    $0x5,%eax
  800c05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c08:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c11:	8b 75 18             	mov    0x18(%ebp),%esi
  800c14:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c16:	85 c0                	test   %eax,%eax
  800c18:	7e 17                	jle    800c31 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1a:	83 ec 0c             	sub    $0xc,%esp
  800c1d:	50                   	push   %eax
  800c1e:	6a 05                	push   $0x5
  800c20:	68 a4 13 80 00       	push   $0x8013a4
  800c25:	6a 23                	push   $0x23
  800c27:	68 c1 13 80 00       	push   $0x8013c1
  800c2c:	e8 dc f4 ff ff       	call   80010d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c47:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	89 df                	mov    %ebx,%edi
  800c54:	89 de                	mov    %ebx,%esi
  800c56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	7e 17                	jle    800c73 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	50                   	push   %eax
  800c60:	6a 06                	push   $0x6
  800c62:	68 a4 13 80 00       	push   $0x8013a4
  800c67:	6a 23                	push   $0x23
  800c69:	68 c1 13 80 00       	push   $0x8013c1
  800c6e:	e8 9a f4 ff ff       	call   80010d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c89:	b8 08 00 00 00       	mov    $0x8,%eax
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	8b 55 08             	mov    0x8(%ebp),%edx
  800c94:	89 df                	mov    %ebx,%edi
  800c96:	89 de                	mov    %ebx,%esi
  800c98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	7e 17                	jle    800cb5 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	50                   	push   %eax
  800ca2:	6a 08                	push   $0x8
  800ca4:	68 a4 13 80 00       	push   $0x8013a4
  800ca9:	6a 23                	push   $0x23
  800cab:	68 c1 13 80 00       	push   $0x8013c1
  800cb0:	e8 58 f4 ff ff       	call   80010d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccb:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd6:	89 df                	mov    %ebx,%edi
  800cd8:	89 de                	mov    %ebx,%esi
  800cda:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	7e 17                	jle    800cf7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce0:	83 ec 0c             	sub    $0xc,%esp
  800ce3:	50                   	push   %eax
  800ce4:	6a 09                	push   $0x9
  800ce6:	68 a4 13 80 00       	push   $0x8013a4
  800ceb:	6a 23                	push   $0x23
  800ced:	68 c1 13 80 00       	push   $0x8013c1
  800cf2:	e8 16 f4 ff ff       	call   80010d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfa:	5b                   	pop    %ebx
  800cfb:	5e                   	pop    %esi
  800cfc:	5f                   	pop    %edi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	57                   	push   %edi
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d05:	be 00 00 00 00       	mov    $0x0,%esi
  800d0a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d12:	8b 55 08             	mov    0x8(%ebp),%edx
  800d15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d18:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d30:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	89 cb                	mov    %ecx,%ebx
  800d3a:	89 cf                	mov    %ecx,%edi
  800d3c:	89 ce                	mov    %ecx,%esi
  800d3e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d40:	85 c0                	test   %eax,%eax
  800d42:	7e 17                	jle    800d5b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 0c                	push   $0xc
  800d4a:	68 a4 13 80 00       	push   $0x8013a4
  800d4f:	6a 23                	push   $0x23
  800d51:	68 c1 13 80 00       	push   $0x8013c1
  800d56:	e8 b2 f3 ff ff       	call   80010d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_change_pr>:

int
sys_change_pr(int pr)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
  800d76:	89 cb                	mov    %ecx,%ebx
  800d78:	89 cf                	mov    %ecx,%edi
  800d7a:	89 ce                	mov    %ecx,%esi
  800d7c:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	83 ec 08             	sub    $0x8,%esp
	// int r;

	if (_pgfault_handler == 0) {
  800d89:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  800d90:	75 2c                	jne    800dbe <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800d92:	83 ec 04             	sub    $0x4,%esp
  800d95:	6a 07                	push   $0x7
  800d97:	68 00 f0 bf ee       	push   $0xeebff000
  800d9c:	6a 00                	push   $0x0
  800d9e:	e8 11 fe ff ff       	call   800bb4 <sys_page_alloc>
  800da3:	83 c4 10             	add    $0x10,%esp
  800da6:	85 c0                	test   %eax,%eax
  800da8:	79 14                	jns    800dbe <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  800daa:	83 ec 04             	sub    $0x4,%esp
  800dad:	68 d0 13 80 00       	push   $0x8013d0
  800db2:	6a 21                	push   $0x21
  800db4:	68 34 14 80 00       	push   $0x801434
  800db9:	e8 4f f3 ff ff       	call   80010d <_panic>
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc1:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800dc6:	83 ec 08             	sub    $0x8,%esp
  800dc9:	68 f2 0d 80 00       	push   $0x800df2
  800dce:	6a 00                	push   $0x0
  800dd0:	e8 e8 fe ff ff       	call   800cbd <sys_env_set_pgfault_upcall>
  800dd5:	83 c4 10             	add    $0x10,%esp
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	79 14                	jns    800df0 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800ddc:	83 ec 04             	sub    $0x4,%esp
  800ddf:	68 fc 13 80 00       	push   $0x8013fc
  800de4:	6a 26                	push   $0x26
  800de6:	68 34 14 80 00       	push   $0x801434
  800deb:	e8 1d f3 ff ff       	call   80010d <_panic>
}
  800df0:	c9                   	leave  
  800df1:	c3                   	ret    

00800df2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800df2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800df3:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  800df8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dfa:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx #trap-time eip
  800dfd:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)
  800e01:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax #trap-time esp-4
  800e06:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)
  800e0a:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp
  800e0c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800e0f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp #eip
  800e10:	83 c4 04             	add    $0x4,%esp
	popfl
  800e13:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e14:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e15:	c3                   	ret    
  800e16:	66 90                	xchg   %ax,%ax
  800e18:	66 90                	xchg   %ax,%ax
  800e1a:	66 90                	xchg   %ax,%ax
  800e1c:	66 90                	xchg   %ax,%ax
  800e1e:	66 90                	xchg   %ax,%ax

00800e20 <__udivdi3>:
  800e20:	55                   	push   %ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
  800e24:	83 ec 1c             	sub    $0x1c,%esp
  800e27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e37:	85 f6                	test   %esi,%esi
  800e39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e3d:	89 ca                	mov    %ecx,%edx
  800e3f:	89 f8                	mov    %edi,%eax
  800e41:	75 3d                	jne    800e80 <__udivdi3+0x60>
  800e43:	39 cf                	cmp    %ecx,%edi
  800e45:	0f 87 c5 00 00 00    	ja     800f10 <__udivdi3+0xf0>
  800e4b:	85 ff                	test   %edi,%edi
  800e4d:	89 fd                	mov    %edi,%ebp
  800e4f:	75 0b                	jne    800e5c <__udivdi3+0x3c>
  800e51:	b8 01 00 00 00       	mov    $0x1,%eax
  800e56:	31 d2                	xor    %edx,%edx
  800e58:	f7 f7                	div    %edi
  800e5a:	89 c5                	mov    %eax,%ebp
  800e5c:	89 c8                	mov    %ecx,%eax
  800e5e:	31 d2                	xor    %edx,%edx
  800e60:	f7 f5                	div    %ebp
  800e62:	89 c1                	mov    %eax,%ecx
  800e64:	89 d8                	mov    %ebx,%eax
  800e66:	89 cf                	mov    %ecx,%edi
  800e68:	f7 f5                	div    %ebp
  800e6a:	89 c3                	mov    %eax,%ebx
  800e6c:	89 d8                	mov    %ebx,%eax
  800e6e:	89 fa                	mov    %edi,%edx
  800e70:	83 c4 1c             	add    $0x1c,%esp
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    
  800e78:	90                   	nop
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	39 ce                	cmp    %ecx,%esi
  800e82:	77 74                	ja     800ef8 <__udivdi3+0xd8>
  800e84:	0f bd fe             	bsr    %esi,%edi
  800e87:	83 f7 1f             	xor    $0x1f,%edi
  800e8a:	0f 84 98 00 00 00    	je     800f28 <__udivdi3+0x108>
  800e90:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e95:	89 f9                	mov    %edi,%ecx
  800e97:	89 c5                	mov    %eax,%ebp
  800e99:	29 fb                	sub    %edi,%ebx
  800e9b:	d3 e6                	shl    %cl,%esi
  800e9d:	89 d9                	mov    %ebx,%ecx
  800e9f:	d3 ed                	shr    %cl,%ebp
  800ea1:	89 f9                	mov    %edi,%ecx
  800ea3:	d3 e0                	shl    %cl,%eax
  800ea5:	09 ee                	or     %ebp,%esi
  800ea7:	89 d9                	mov    %ebx,%ecx
  800ea9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ead:	89 d5                	mov    %edx,%ebp
  800eaf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800eb3:	d3 ed                	shr    %cl,%ebp
  800eb5:	89 f9                	mov    %edi,%ecx
  800eb7:	d3 e2                	shl    %cl,%edx
  800eb9:	89 d9                	mov    %ebx,%ecx
  800ebb:	d3 e8                	shr    %cl,%eax
  800ebd:	09 c2                	or     %eax,%edx
  800ebf:	89 d0                	mov    %edx,%eax
  800ec1:	89 ea                	mov    %ebp,%edx
  800ec3:	f7 f6                	div    %esi
  800ec5:	89 d5                	mov    %edx,%ebp
  800ec7:	89 c3                	mov    %eax,%ebx
  800ec9:	f7 64 24 0c          	mull   0xc(%esp)
  800ecd:	39 d5                	cmp    %edx,%ebp
  800ecf:	72 10                	jb     800ee1 <__udivdi3+0xc1>
  800ed1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ed5:	89 f9                	mov    %edi,%ecx
  800ed7:	d3 e6                	shl    %cl,%esi
  800ed9:	39 c6                	cmp    %eax,%esi
  800edb:	73 07                	jae    800ee4 <__udivdi3+0xc4>
  800edd:	39 d5                	cmp    %edx,%ebp
  800edf:	75 03                	jne    800ee4 <__udivdi3+0xc4>
  800ee1:	83 eb 01             	sub    $0x1,%ebx
  800ee4:	31 ff                	xor    %edi,%edi
  800ee6:	89 d8                	mov    %ebx,%eax
  800ee8:	89 fa                	mov    %edi,%edx
  800eea:	83 c4 1c             	add    $0x1c,%esp
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5f                   	pop    %edi
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    
  800ef2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ef8:	31 ff                	xor    %edi,%edi
  800efa:	31 db                	xor    %ebx,%ebx
  800efc:	89 d8                	mov    %ebx,%eax
  800efe:	89 fa                	mov    %edi,%edx
  800f00:	83 c4 1c             	add    $0x1c,%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    
  800f08:	90                   	nop
  800f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f10:	89 d8                	mov    %ebx,%eax
  800f12:	f7 f7                	div    %edi
  800f14:	31 ff                	xor    %edi,%edi
  800f16:	89 c3                	mov    %eax,%ebx
  800f18:	89 d8                	mov    %ebx,%eax
  800f1a:	89 fa                	mov    %edi,%edx
  800f1c:	83 c4 1c             	add    $0x1c,%esp
  800f1f:	5b                   	pop    %ebx
  800f20:	5e                   	pop    %esi
  800f21:	5f                   	pop    %edi
  800f22:	5d                   	pop    %ebp
  800f23:	c3                   	ret    
  800f24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f28:	39 ce                	cmp    %ecx,%esi
  800f2a:	72 0c                	jb     800f38 <__udivdi3+0x118>
  800f2c:	31 db                	xor    %ebx,%ebx
  800f2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f32:	0f 87 34 ff ff ff    	ja     800e6c <__udivdi3+0x4c>
  800f38:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f3d:	e9 2a ff ff ff       	jmp    800e6c <__udivdi3+0x4c>
  800f42:	66 90                	xchg   %ax,%ax
  800f44:	66 90                	xchg   %ax,%ax
  800f46:	66 90                	xchg   %ax,%ax
  800f48:	66 90                	xchg   %ax,%ax
  800f4a:	66 90                	xchg   %ax,%ax
  800f4c:	66 90                	xchg   %ax,%ax
  800f4e:	66 90                	xchg   %ax,%ax

00800f50 <__umoddi3>:
  800f50:	55                   	push   %ebp
  800f51:	57                   	push   %edi
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
  800f54:	83 ec 1c             	sub    $0x1c,%esp
  800f57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f67:	85 d2                	test   %edx,%edx
  800f69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f71:	89 f3                	mov    %esi,%ebx
  800f73:	89 3c 24             	mov    %edi,(%esp)
  800f76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f7a:	75 1c                	jne    800f98 <__umoddi3+0x48>
  800f7c:	39 f7                	cmp    %esi,%edi
  800f7e:	76 50                	jbe    800fd0 <__umoddi3+0x80>
  800f80:	89 c8                	mov    %ecx,%eax
  800f82:	89 f2                	mov    %esi,%edx
  800f84:	f7 f7                	div    %edi
  800f86:	89 d0                	mov    %edx,%eax
  800f88:	31 d2                	xor    %edx,%edx
  800f8a:	83 c4 1c             	add    $0x1c,%esp
  800f8d:	5b                   	pop    %ebx
  800f8e:	5e                   	pop    %esi
  800f8f:	5f                   	pop    %edi
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    
  800f92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f98:	39 f2                	cmp    %esi,%edx
  800f9a:	89 d0                	mov    %edx,%eax
  800f9c:	77 52                	ja     800ff0 <__umoddi3+0xa0>
  800f9e:	0f bd ea             	bsr    %edx,%ebp
  800fa1:	83 f5 1f             	xor    $0x1f,%ebp
  800fa4:	75 5a                	jne    801000 <__umoddi3+0xb0>
  800fa6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800faa:	0f 82 e0 00 00 00    	jb     801090 <__umoddi3+0x140>
  800fb0:	39 0c 24             	cmp    %ecx,(%esp)
  800fb3:	0f 86 d7 00 00 00    	jbe    801090 <__umoddi3+0x140>
  800fb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fbd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fc1:	83 c4 1c             	add    $0x1c,%esp
  800fc4:	5b                   	pop    %ebx
  800fc5:	5e                   	pop    %esi
  800fc6:	5f                   	pop    %edi
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    
  800fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fd0:	85 ff                	test   %edi,%edi
  800fd2:	89 fd                	mov    %edi,%ebp
  800fd4:	75 0b                	jne    800fe1 <__umoddi3+0x91>
  800fd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fdb:	31 d2                	xor    %edx,%edx
  800fdd:	f7 f7                	div    %edi
  800fdf:	89 c5                	mov    %eax,%ebp
  800fe1:	89 f0                	mov    %esi,%eax
  800fe3:	31 d2                	xor    %edx,%edx
  800fe5:	f7 f5                	div    %ebp
  800fe7:	89 c8                	mov    %ecx,%eax
  800fe9:	f7 f5                	div    %ebp
  800feb:	89 d0                	mov    %edx,%eax
  800fed:	eb 99                	jmp    800f88 <__umoddi3+0x38>
  800fef:	90                   	nop
  800ff0:	89 c8                	mov    %ecx,%eax
  800ff2:	89 f2                	mov    %esi,%edx
  800ff4:	83 c4 1c             	add    $0x1c,%esp
  800ff7:	5b                   	pop    %ebx
  800ff8:	5e                   	pop    %esi
  800ff9:	5f                   	pop    %edi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    
  800ffc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801000:	8b 34 24             	mov    (%esp),%esi
  801003:	bf 20 00 00 00       	mov    $0x20,%edi
  801008:	89 e9                	mov    %ebp,%ecx
  80100a:	29 ef                	sub    %ebp,%edi
  80100c:	d3 e0                	shl    %cl,%eax
  80100e:	89 f9                	mov    %edi,%ecx
  801010:	89 f2                	mov    %esi,%edx
  801012:	d3 ea                	shr    %cl,%edx
  801014:	89 e9                	mov    %ebp,%ecx
  801016:	09 c2                	or     %eax,%edx
  801018:	89 d8                	mov    %ebx,%eax
  80101a:	89 14 24             	mov    %edx,(%esp)
  80101d:	89 f2                	mov    %esi,%edx
  80101f:	d3 e2                	shl    %cl,%edx
  801021:	89 f9                	mov    %edi,%ecx
  801023:	89 54 24 04          	mov    %edx,0x4(%esp)
  801027:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80102b:	d3 e8                	shr    %cl,%eax
  80102d:	89 e9                	mov    %ebp,%ecx
  80102f:	89 c6                	mov    %eax,%esi
  801031:	d3 e3                	shl    %cl,%ebx
  801033:	89 f9                	mov    %edi,%ecx
  801035:	89 d0                	mov    %edx,%eax
  801037:	d3 e8                	shr    %cl,%eax
  801039:	89 e9                	mov    %ebp,%ecx
  80103b:	09 d8                	or     %ebx,%eax
  80103d:	89 d3                	mov    %edx,%ebx
  80103f:	89 f2                	mov    %esi,%edx
  801041:	f7 34 24             	divl   (%esp)
  801044:	89 d6                	mov    %edx,%esi
  801046:	d3 e3                	shl    %cl,%ebx
  801048:	f7 64 24 04          	mull   0x4(%esp)
  80104c:	39 d6                	cmp    %edx,%esi
  80104e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801052:	89 d1                	mov    %edx,%ecx
  801054:	89 c3                	mov    %eax,%ebx
  801056:	72 08                	jb     801060 <__umoddi3+0x110>
  801058:	75 11                	jne    80106b <__umoddi3+0x11b>
  80105a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80105e:	73 0b                	jae    80106b <__umoddi3+0x11b>
  801060:	2b 44 24 04          	sub    0x4(%esp),%eax
  801064:	1b 14 24             	sbb    (%esp),%edx
  801067:	89 d1                	mov    %edx,%ecx
  801069:	89 c3                	mov    %eax,%ebx
  80106b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80106f:	29 da                	sub    %ebx,%edx
  801071:	19 ce                	sbb    %ecx,%esi
  801073:	89 f9                	mov    %edi,%ecx
  801075:	89 f0                	mov    %esi,%eax
  801077:	d3 e0                	shl    %cl,%eax
  801079:	89 e9                	mov    %ebp,%ecx
  80107b:	d3 ea                	shr    %cl,%edx
  80107d:	89 e9                	mov    %ebp,%ecx
  80107f:	d3 ee                	shr    %cl,%esi
  801081:	09 d0                	or     %edx,%eax
  801083:	89 f2                	mov    %esi,%edx
  801085:	83 c4 1c             	add    $0x1c,%esp
  801088:	5b                   	pop    %ebx
  801089:	5e                   	pop    %esi
  80108a:	5f                   	pop    %edi
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    
  80108d:	8d 76 00             	lea    0x0(%esi),%esi
  801090:	29 f9                	sub    %edi,%ecx
  801092:	19 d6                	sbb    %edx,%esi
  801094:	89 74 24 04          	mov    %esi,0x4(%esp)
  801098:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80109c:	e9 18 ff ff ff       	jmp    800fb9 <__umoddi3+0x69>
