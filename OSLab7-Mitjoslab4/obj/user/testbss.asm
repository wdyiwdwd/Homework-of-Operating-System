
obj/user/testbss：     文件格式 elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 40 10 80 00       	push   $0x801040
  80003e:	e8 ca 01 00 00       	call   80020d <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 bb 10 80 00       	push   $0x8010bb
  80005b:	6a 11                	push   $0x11
  80005d:	68 d8 10 80 00       	push   $0x8010d8
  800062:	e8 cd 00 00 00       	call   800134 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800067:	83 c0 01             	add    $0x1,%eax
  80006a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006f:	75 da                	jne    80004b <umain+0x18>
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800076:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 ef                	jne    800076 <umain+0x43>
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  80008c:	3b 04 85 20 20 80 00 	cmp    0x802020(,%eax,4),%eax
  800093:	74 12                	je     8000a7 <umain+0x74>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800095:	50                   	push   %eax
  800096:	68 60 10 80 00       	push   $0x801060
  80009b:	6a 16                	push   $0x16
  80009d:	68 d8 10 80 00       	push   $0x8010d8
  8000a2:	e8 8d 00 00 00       	call   800134 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 db                	jne    80008c <umain+0x59>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 88 10 80 00       	push   $0x801088
  8000b9:	e8 4f 01 00 00       	call   80020d <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 e7 10 80 00       	push   $0x8010e7
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 d8 10 80 00       	push   $0x8010d8
  8000d7:	e8 58 00 00 00       	call   800134 <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  8000e7:	e8 b1 0a 00 00       	call   800b9d <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	c1 e0 07             	shl    $0x7,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 20 20 c0 00       	mov    %eax,0xc02020
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
		binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	e8 20 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800113:	e8 0a 00 00 00       	call   800122 <exit>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800128:	6a 00                	push   $0x0
  80012a:	e8 2d 0a 00 00       	call   800b5c <sys_env_destroy>
}
  80012f:	83 c4 10             	add    $0x10,%esp
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800139:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800142:	e8 56 0a 00 00       	call   800b9d <sys_getenvid>
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	ff 75 0c             	pushl  0xc(%ebp)
  80014d:	ff 75 08             	pushl  0x8(%ebp)
  800150:	56                   	push   %esi
  800151:	50                   	push   %eax
  800152:	68 08 11 80 00       	push   $0x801108
  800157:	e8 b1 00 00 00       	call   80020d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015c:	83 c4 18             	add    $0x18,%esp
  80015f:	53                   	push   %ebx
  800160:	ff 75 10             	pushl  0x10(%ebp)
  800163:	e8 54 00 00 00       	call   8001bc <vcprintf>
	cprintf("\n");
  800168:	c7 04 24 d6 10 80 00 	movl   $0x8010d6,(%esp)
  80016f:	e8 99 00 00 00       	call   80020d <cprintf>
  800174:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800177:	cc                   	int3   
  800178:	eb fd                	jmp    800177 <_panic+0x43>

0080017a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	53                   	push   %ebx
  80017e:	83 ec 04             	sub    $0x4,%esp
  800181:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800184:	8b 13                	mov    (%ebx),%edx
  800186:	8d 42 01             	lea    0x1(%edx),%eax
  800189:	89 03                	mov    %eax,(%ebx)
  80018b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800192:	3d ff 00 00 00       	cmp    $0xff,%eax
  800197:	75 1a                	jne    8001b3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800199:	83 ec 08             	sub    $0x8,%esp
  80019c:	68 ff 00 00 00       	push   $0xff
  8001a1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a4:	50                   	push   %eax
  8001a5:	e8 75 09 00 00       	call   800b1f <sys_cputs>
		b->idx = 0;
  8001aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cc:	00 00 00 
	b.cnt = 0;
  8001cf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d9:	ff 75 0c             	pushl  0xc(%ebp)
  8001dc:	ff 75 08             	pushl  0x8(%ebp)
  8001df:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e5:	50                   	push   %eax
  8001e6:	68 7a 01 80 00       	push   $0x80017a
  8001eb:	e8 54 01 00 00       	call   800344 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f0:	83 c4 08             	add    $0x8,%esp
  8001f3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ff:	50                   	push   %eax
  800200:	e8 1a 09 00 00       	call   800b1f <sys_cputs>

	return b.cnt;
}
  800205:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020b:	c9                   	leave  
  80020c:	c3                   	ret    

0080020d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
  800210:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800213:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800216:	50                   	push   %eax
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	e8 9d ff ff ff       	call   8001bc <vcprintf>
	va_end(ap);

	return cnt;
}
  80021f:	c9                   	leave  
  800220:	c3                   	ret    

00800221 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 1c             	sub    $0x1c,%esp
  80022a:	89 c7                	mov    %eax,%edi
  80022c:	89 d6                	mov    %edx,%esi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	8b 55 0c             	mov    0xc(%ebp),%edx
  800234:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800237:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80023d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800242:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800245:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800248:	39 d3                	cmp    %edx,%ebx
  80024a:	72 05                	jb     800251 <printnum+0x30>
  80024c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024f:	77 45                	ja     800296 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800251:	83 ec 0c             	sub    $0xc,%esp
  800254:	ff 75 18             	pushl  0x18(%ebp)
  800257:	8b 45 14             	mov    0x14(%ebp),%eax
  80025a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80025d:	53                   	push   %ebx
  80025e:	ff 75 10             	pushl  0x10(%ebp)
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	ff 75 e4             	pushl  -0x1c(%ebp)
  800267:	ff 75 e0             	pushl  -0x20(%ebp)
  80026a:	ff 75 dc             	pushl  -0x24(%ebp)
  80026d:	ff 75 d8             	pushl  -0x28(%ebp)
  800270:	e8 3b 0b 00 00       	call   800db0 <__udivdi3>
  800275:	83 c4 18             	add    $0x18,%esp
  800278:	52                   	push   %edx
  800279:	50                   	push   %eax
  80027a:	89 f2                	mov    %esi,%edx
  80027c:	89 f8                	mov    %edi,%eax
  80027e:	e8 9e ff ff ff       	call   800221 <printnum>
  800283:	83 c4 20             	add    $0x20,%esp
  800286:	eb 18                	jmp    8002a0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800288:	83 ec 08             	sub    $0x8,%esp
  80028b:	56                   	push   %esi
  80028c:	ff 75 18             	pushl  0x18(%ebp)
  80028f:	ff d7                	call   *%edi
  800291:	83 c4 10             	add    $0x10,%esp
  800294:	eb 03                	jmp    800299 <printnum+0x78>
  800296:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800299:	83 eb 01             	sub    $0x1,%ebx
  80029c:	85 db                	test   %ebx,%ebx
  80029e:	7f e8                	jg     800288 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	56                   	push   %esi
  8002a4:	83 ec 04             	sub    $0x4,%esp
  8002a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ad:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b3:	e8 28 0c 00 00       	call   800ee0 <__umoddi3>
  8002b8:	83 c4 14             	add    $0x14,%esp
  8002bb:	0f be 80 2c 11 80 00 	movsbl 0x80112c(%eax),%eax
  8002c2:	50                   	push   %eax
  8002c3:	ff d7                	call   *%edi
}
  8002c5:	83 c4 10             	add    $0x10,%esp
  8002c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d3:	83 fa 01             	cmp    $0x1,%edx
  8002d6:	7e 0e                	jle    8002e6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	8b 52 04             	mov    0x4(%edx),%edx
  8002e4:	eb 22                	jmp    800308 <getuint+0x38>
	else if (lflag)
  8002e6:	85 d2                	test   %edx,%edx
  8002e8:	74 10                	je     8002fa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 02                	mov    (%edx),%eax
  8002f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f8:	eb 0e                	jmp    800308 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002fa:	8b 10                	mov    (%eax),%edx
  8002fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 02                	mov    (%edx),%eax
  800303:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800310:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800314:	8b 10                	mov    (%eax),%edx
  800316:	3b 50 04             	cmp    0x4(%eax),%edx
  800319:	73 0a                	jae    800325 <sprintputch+0x1b>
		*b->buf++ = ch;
  80031b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80031e:	89 08                	mov    %ecx,(%eax)
  800320:	8b 45 08             	mov    0x8(%ebp),%eax
  800323:	88 02                	mov    %al,(%edx)
}
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    

00800327 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80032d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800330:	50                   	push   %eax
  800331:	ff 75 10             	pushl  0x10(%ebp)
  800334:	ff 75 0c             	pushl  0xc(%ebp)
  800337:	ff 75 08             	pushl  0x8(%ebp)
  80033a:	e8 05 00 00 00       	call   800344 <vprintfmt>
	va_end(ap);
}
  80033f:	83 c4 10             	add    $0x10,%esp
  800342:	c9                   	leave  
  800343:	c3                   	ret    

00800344 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	57                   	push   %edi
  800348:	56                   	push   %esi
  800349:	53                   	push   %ebx
  80034a:	83 ec 2c             	sub    $0x2c,%esp
  80034d:	8b 75 08             	mov    0x8(%ebp),%esi
  800350:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800353:	8b 7d 10             	mov    0x10(%ebp),%edi
  800356:	eb 1d                	jmp    800375 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800358:	85 c0                	test   %eax,%eax
  80035a:	75 0f                	jne    80036b <vprintfmt+0x27>
				csa = 0x0700;
  80035c:	c7 05 24 20 c0 00 00 	movl   $0x700,0xc02024
  800363:	07 00 00 
				return;
  800366:	e9 c4 03 00 00       	jmp    80072f <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  80036b:	83 ec 08             	sub    $0x8,%esp
  80036e:	53                   	push   %ebx
  80036f:	50                   	push   %eax
  800370:	ff d6                	call   *%esi
  800372:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800375:	83 c7 01             	add    $0x1,%edi
  800378:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80037c:	83 f8 25             	cmp    $0x25,%eax
  80037f:	75 d7                	jne    800358 <vprintfmt+0x14>
  800381:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800385:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80038c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800393:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80039a:	ba 00 00 00 00       	mov    $0x0,%edx
  80039f:	eb 07                	jmp    8003a8 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8d 47 01             	lea    0x1(%edi),%eax
  8003ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ae:	0f b6 07             	movzbl (%edi),%eax
  8003b1:	0f b6 c8             	movzbl %al,%ecx
  8003b4:	83 e8 23             	sub    $0x23,%eax
  8003b7:	3c 55                	cmp    $0x55,%al
  8003b9:	0f 87 55 03 00 00    	ja     800714 <vprintfmt+0x3d0>
  8003bf:	0f b6 c0             	movzbl %al,%eax
  8003c2:	ff 24 85 00 12 80 00 	jmp    *0x801200(,%eax,4)
  8003c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003cc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003d0:	eb d6                	jmp    8003a8 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003da:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003dd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003ea:	83 fa 09             	cmp    $0x9,%edx
  8003ed:	77 39                	ja     800428 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ef:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f2:	eb e9                	jmp    8003dd <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003fa:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fd:	8b 00                	mov    (%eax),%eax
  8003ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800405:	eb 27                	jmp    80042e <vprintfmt+0xea>
  800407:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040a:	85 c0                	test   %eax,%eax
  80040c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800411:	0f 49 c8             	cmovns %eax,%ecx
  800414:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041a:	eb 8c                	jmp    8003a8 <vprintfmt+0x64>
  80041c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800426:	eb 80                	jmp    8003a8 <vprintfmt+0x64>
  800428:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80042b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80042e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800432:	0f 89 70 ff ff ff    	jns    8003a8 <vprintfmt+0x64>
				width = precision, precision = -1;
  800438:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80043b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800445:	e9 5e ff ff ff       	jmp    8003a8 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80044a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800450:	e9 53 ff ff ff       	jmp    8003a8 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8d 50 04             	lea    0x4(%eax),%edx
  80045b:	89 55 14             	mov    %edx,0x14(%ebp)
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	53                   	push   %ebx
  800462:	ff 30                	pushl  (%eax)
  800464:	ff d6                	call   *%esi
			break;
  800466:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80046c:	e9 04 ff ff ff       	jmp    800375 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	8d 50 04             	lea    0x4(%eax),%edx
  800477:	89 55 14             	mov    %edx,0x14(%ebp)
  80047a:	8b 00                	mov    (%eax),%eax
  80047c:	99                   	cltd   
  80047d:	31 d0                	xor    %edx,%eax
  80047f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800481:	83 f8 08             	cmp    $0x8,%eax
  800484:	7f 0b                	jg     800491 <vprintfmt+0x14d>
  800486:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  80048d:	85 d2                	test   %edx,%edx
  80048f:	75 18                	jne    8004a9 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  800491:	50                   	push   %eax
  800492:	68 44 11 80 00       	push   $0x801144
  800497:	53                   	push   %ebx
  800498:	56                   	push   %esi
  800499:	e8 89 fe ff ff       	call   800327 <printfmt>
  80049e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a4:	e9 cc fe ff ff       	jmp    800375 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8004a9:	52                   	push   %edx
  8004aa:	68 4d 11 80 00       	push   $0x80114d
  8004af:	53                   	push   %ebx
  8004b0:	56                   	push   %esi
  8004b1:	e8 71 fe ff ff       	call   800327 <printfmt>
  8004b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004bc:	e9 b4 fe ff ff       	jmp    800375 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8d 50 04             	lea    0x4(%eax),%edx
  8004c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ca:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004cc:	85 ff                	test   %edi,%edi
  8004ce:	b8 3d 11 80 00       	mov    $0x80113d,%eax
  8004d3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004da:	0f 8e 94 00 00 00    	jle    800574 <vprintfmt+0x230>
  8004e0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e4:	0f 84 98 00 00 00    	je     800582 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	ff 75 d0             	pushl  -0x30(%ebp)
  8004f0:	57                   	push   %edi
  8004f1:	e8 c1 02 00 00       	call   8007b7 <strnlen>
  8004f6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f9:	29 c1                	sub    %eax,%ecx
  8004fb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004fe:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800501:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800505:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800508:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80050b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050d:	eb 0f                	jmp    80051e <vprintfmt+0x1da>
					putch(padc, putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	53                   	push   %ebx
  800513:	ff 75 e0             	pushl  -0x20(%ebp)
  800516:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800518:	83 ef 01             	sub    $0x1,%edi
  80051b:	83 c4 10             	add    $0x10,%esp
  80051e:	85 ff                	test   %edi,%edi
  800520:	7f ed                	jg     80050f <vprintfmt+0x1cb>
  800522:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800525:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800528:	85 c9                	test   %ecx,%ecx
  80052a:	b8 00 00 00 00       	mov    $0x0,%eax
  80052f:	0f 49 c1             	cmovns %ecx,%eax
  800532:	29 c1                	sub    %eax,%ecx
  800534:	89 75 08             	mov    %esi,0x8(%ebp)
  800537:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053d:	89 cb                	mov    %ecx,%ebx
  80053f:	eb 4d                	jmp    80058e <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800541:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800545:	74 1b                	je     800562 <vprintfmt+0x21e>
  800547:	0f be c0             	movsbl %al,%eax
  80054a:	83 e8 20             	sub    $0x20,%eax
  80054d:	83 f8 5e             	cmp    $0x5e,%eax
  800550:	76 10                	jbe    800562 <vprintfmt+0x21e>
					putch('?', putdat);
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	ff 75 0c             	pushl  0xc(%ebp)
  800558:	6a 3f                	push   $0x3f
  80055a:	ff 55 08             	call   *0x8(%ebp)
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	eb 0d                	jmp    80056f <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	ff 75 0c             	pushl  0xc(%ebp)
  800568:	52                   	push   %edx
  800569:	ff 55 08             	call   *0x8(%ebp)
  80056c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056f:	83 eb 01             	sub    $0x1,%ebx
  800572:	eb 1a                	jmp    80058e <vprintfmt+0x24a>
  800574:	89 75 08             	mov    %esi,0x8(%ebp)
  800577:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80057a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800580:	eb 0c                	jmp    80058e <vprintfmt+0x24a>
  800582:	89 75 08             	mov    %esi,0x8(%ebp)
  800585:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800588:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058e:	83 c7 01             	add    $0x1,%edi
  800591:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800595:	0f be d0             	movsbl %al,%edx
  800598:	85 d2                	test   %edx,%edx
  80059a:	74 23                	je     8005bf <vprintfmt+0x27b>
  80059c:	85 f6                	test   %esi,%esi
  80059e:	78 a1                	js     800541 <vprintfmt+0x1fd>
  8005a0:	83 ee 01             	sub    $0x1,%esi
  8005a3:	79 9c                	jns    800541 <vprintfmt+0x1fd>
  8005a5:	89 df                	mov    %ebx,%edi
  8005a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8005aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ad:	eb 18                	jmp    8005c7 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	53                   	push   %ebx
  8005b3:	6a 20                	push   $0x20
  8005b5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b7:	83 ef 01             	sub    $0x1,%edi
  8005ba:	83 c4 10             	add    $0x10,%esp
  8005bd:	eb 08                	jmp    8005c7 <vprintfmt+0x283>
  8005bf:	89 df                	mov    %ebx,%edi
  8005c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c7:	85 ff                	test   %edi,%edi
  8005c9:	7f e4                	jg     8005af <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ce:	e9 a2 fd ff ff       	jmp    800375 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d3:	83 fa 01             	cmp    $0x1,%edx
  8005d6:	7e 16                	jle    8005ee <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8d 50 08             	lea    0x8(%eax),%edx
  8005de:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e1:	8b 50 04             	mov    0x4(%eax),%edx
  8005e4:	8b 00                	mov    (%eax),%eax
  8005e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ec:	eb 32                	jmp    800620 <vprintfmt+0x2dc>
	else if (lflag)
  8005ee:	85 d2                	test   %edx,%edx
  8005f0:	74 18                	je     80060a <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 04             	lea    0x4(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	8b 00                	mov    (%eax),%eax
  8005fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800600:	89 c1                	mov    %eax,%ecx
  800602:	c1 f9 1f             	sar    $0x1f,%ecx
  800605:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800608:	eb 16                	jmp    800620 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8d 50 04             	lea    0x4(%eax),%edx
  800610:	89 55 14             	mov    %edx,0x14(%ebp)
  800613:	8b 00                	mov    (%eax),%eax
  800615:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800618:	89 c1                	mov    %eax,%ecx
  80061a:	c1 f9 1f             	sar    $0x1f,%ecx
  80061d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800620:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800623:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800626:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80062b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062f:	79 74                	jns    8006a5 <vprintfmt+0x361>
				putch('-', putdat);
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	6a 2d                	push   $0x2d
  800637:	ff d6                	call   *%esi
				num = -(long long) num;
  800639:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063f:	f7 d8                	neg    %eax
  800641:	83 d2 00             	adc    $0x0,%edx
  800644:	f7 da                	neg    %edx
  800646:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800649:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80064e:	eb 55                	jmp    8006a5 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800650:	8d 45 14             	lea    0x14(%ebp),%eax
  800653:	e8 78 fc ff ff       	call   8002d0 <getuint>
			base = 10;
  800658:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80065d:	eb 46                	jmp    8006a5 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  80065f:	8d 45 14             	lea    0x14(%ebp),%eax
  800662:	e8 69 fc ff ff       	call   8002d0 <getuint>
      base = 8;
  800667:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80066c:	eb 37                	jmp    8006a5 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	53                   	push   %ebx
  800672:	6a 30                	push   $0x30
  800674:	ff d6                	call   *%esi
			putch('x', putdat);
  800676:	83 c4 08             	add    $0x8,%esp
  800679:	53                   	push   %ebx
  80067a:	6a 78                	push   $0x78
  80067c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 04             	lea    0x4(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800687:	8b 00                	mov    (%eax),%eax
  800689:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800691:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800696:	eb 0d                	jmp    8006a5 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800698:	8d 45 14             	lea    0x14(%ebp),%eax
  80069b:	e8 30 fc ff ff       	call   8002d0 <getuint>
			base = 16;
  8006a0:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a5:	83 ec 0c             	sub    $0xc,%esp
  8006a8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ac:	57                   	push   %edi
  8006ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b0:	51                   	push   %ecx
  8006b1:	52                   	push   %edx
  8006b2:	50                   	push   %eax
  8006b3:	89 da                	mov    %ebx,%edx
  8006b5:	89 f0                	mov    %esi,%eax
  8006b7:	e8 65 fb ff ff       	call   800221 <printnum>
			break;
  8006bc:	83 c4 20             	add    $0x20,%esp
  8006bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c2:	e9 ae fc ff ff       	jmp    800375 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c7:	83 ec 08             	sub    $0x8,%esp
  8006ca:	53                   	push   %ebx
  8006cb:	51                   	push   %ecx
  8006cc:	ff d6                	call   *%esi
			break;
  8006ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d4:	e9 9c fc ff ff       	jmp    800375 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d9:	83 fa 01             	cmp    $0x1,%edx
  8006dc:	7e 0d                	jle    8006eb <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 50 08             	lea    0x8(%eax),%edx
  8006e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e7:	8b 00                	mov    (%eax),%eax
  8006e9:	eb 1c                	jmp    800707 <vprintfmt+0x3c3>
	else if (lflag)
  8006eb:	85 d2                	test   %edx,%edx
  8006ed:	74 0d                	je     8006fc <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8d 50 04             	lea    0x4(%eax),%edx
  8006f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f8:	8b 00                	mov    (%eax),%eax
  8006fa:	eb 0b                	jmp    800707 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8d 50 04             	lea    0x4(%eax),%edx
  800702:	89 55 14             	mov    %edx,0x14(%ebp)
  800705:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  800707:	a3 24 20 c0 00       	mov    %eax,0xc02024
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  80070f:	e9 61 fc ff ff       	jmp    800375 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 25                	push   $0x25
  80071a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	eb 03                	jmp    800724 <vprintfmt+0x3e0>
  800721:	83 ef 01             	sub    $0x1,%edi
  800724:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800728:	75 f7                	jne    800721 <vprintfmt+0x3dd>
  80072a:	e9 46 fc ff ff       	jmp    800375 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  80072f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800732:	5b                   	pop    %ebx
  800733:	5e                   	pop    %esi
  800734:	5f                   	pop    %edi
  800735:	5d                   	pop    %ebp
  800736:	c3                   	ret    

00800737 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	83 ec 18             	sub    $0x18,%esp
  80073d:	8b 45 08             	mov    0x8(%ebp),%eax
  800740:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800743:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800746:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800754:	85 c0                	test   %eax,%eax
  800756:	74 26                	je     80077e <vsnprintf+0x47>
  800758:	85 d2                	test   %edx,%edx
  80075a:	7e 22                	jle    80077e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075c:	ff 75 14             	pushl  0x14(%ebp)
  80075f:	ff 75 10             	pushl  0x10(%ebp)
  800762:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800765:	50                   	push   %eax
  800766:	68 0a 03 80 00       	push   $0x80030a
  80076b:	e8 d4 fb ff ff       	call   800344 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800770:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800773:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800776:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	eb 05                	jmp    800783 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80077e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078e:	50                   	push   %eax
  80078f:	ff 75 10             	pushl  0x10(%ebp)
  800792:	ff 75 0c             	pushl  0xc(%ebp)
  800795:	ff 75 08             	pushl  0x8(%ebp)
  800798:	e8 9a ff ff ff       	call   800737 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007aa:	eb 03                	jmp    8007af <strlen+0x10>
		n++;
  8007ac:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007af:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b3:	75 f7                	jne    8007ac <strlen+0xd>
		n++;
	return n;
}
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c5:	eb 03                	jmp    8007ca <strnlen+0x13>
		n++;
  8007c7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ca:	39 c2                	cmp    %eax,%edx
  8007cc:	74 08                	je     8007d6 <strnlen+0x1f>
  8007ce:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007d2:	75 f3                	jne    8007c7 <strnlen+0x10>
  8007d4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e2:	89 c2                	mov    %eax,%edx
  8007e4:	83 c2 01             	add    $0x1,%edx
  8007e7:	83 c1 01             	add    $0x1,%ecx
  8007ea:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ee:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f1:	84 db                	test   %bl,%bl
  8007f3:	75 ef                	jne    8007e4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f5:	5b                   	pop    %ebx
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ff:	53                   	push   %ebx
  800800:	e8 9a ff ff ff       	call   80079f <strlen>
  800805:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800808:	ff 75 0c             	pushl  0xc(%ebp)
  80080b:	01 d8                	add    %ebx,%eax
  80080d:	50                   	push   %eax
  80080e:	e8 c5 ff ff ff       	call   8007d8 <strcpy>
	return dst;
}
  800813:	89 d8                	mov    %ebx,%eax
  800815:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800818:	c9                   	leave  
  800819:	c3                   	ret    

0080081a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 75 08             	mov    0x8(%ebp),%esi
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800825:	89 f3                	mov    %esi,%ebx
  800827:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082a:	89 f2                	mov    %esi,%edx
  80082c:	eb 0f                	jmp    80083d <strncpy+0x23>
		*dst++ = *src;
  80082e:	83 c2 01             	add    $0x1,%edx
  800831:	0f b6 01             	movzbl (%ecx),%eax
  800834:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800837:	80 39 01             	cmpb   $0x1,(%ecx)
  80083a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083d:	39 da                	cmp    %ebx,%edx
  80083f:	75 ed                	jne    80082e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800841:	89 f0                	mov    %esi,%eax
  800843:	5b                   	pop    %ebx
  800844:	5e                   	pop    %esi
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	56                   	push   %esi
  80084b:	53                   	push   %ebx
  80084c:	8b 75 08             	mov    0x8(%ebp),%esi
  80084f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800852:	8b 55 10             	mov    0x10(%ebp),%edx
  800855:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800857:	85 d2                	test   %edx,%edx
  800859:	74 21                	je     80087c <strlcpy+0x35>
  80085b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80085f:	89 f2                	mov    %esi,%edx
  800861:	eb 09                	jmp    80086c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800863:	83 c2 01             	add    $0x1,%edx
  800866:	83 c1 01             	add    $0x1,%ecx
  800869:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80086c:	39 c2                	cmp    %eax,%edx
  80086e:	74 09                	je     800879 <strlcpy+0x32>
  800870:	0f b6 19             	movzbl (%ecx),%ebx
  800873:	84 db                	test   %bl,%bl
  800875:	75 ec                	jne    800863 <strlcpy+0x1c>
  800877:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800879:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087c:	29 f0                	sub    %esi,%eax
}
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088b:	eb 06                	jmp    800893 <strcmp+0x11>
		p++, q++;
  80088d:	83 c1 01             	add    $0x1,%ecx
  800890:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800893:	0f b6 01             	movzbl (%ecx),%eax
  800896:	84 c0                	test   %al,%al
  800898:	74 04                	je     80089e <strcmp+0x1c>
  80089a:	3a 02                	cmp    (%edx),%al
  80089c:	74 ef                	je     80088d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089e:	0f b6 c0             	movzbl %al,%eax
  8008a1:	0f b6 12             	movzbl (%edx),%edx
  8008a4:	29 d0                	sub    %edx,%eax
}
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	53                   	push   %ebx
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b2:	89 c3                	mov    %eax,%ebx
  8008b4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b7:	eb 06                	jmp    8008bf <strncmp+0x17>
		n--, p++, q++;
  8008b9:	83 c0 01             	add    $0x1,%eax
  8008bc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008bf:	39 d8                	cmp    %ebx,%eax
  8008c1:	74 15                	je     8008d8 <strncmp+0x30>
  8008c3:	0f b6 08             	movzbl (%eax),%ecx
  8008c6:	84 c9                	test   %cl,%cl
  8008c8:	74 04                	je     8008ce <strncmp+0x26>
  8008ca:	3a 0a                	cmp    (%edx),%cl
  8008cc:	74 eb                	je     8008b9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ce:	0f b6 00             	movzbl (%eax),%eax
  8008d1:	0f b6 12             	movzbl (%edx),%edx
  8008d4:	29 d0                	sub    %edx,%eax
  8008d6:	eb 05                	jmp    8008dd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008dd:	5b                   	pop    %ebx
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ea:	eb 07                	jmp    8008f3 <strchr+0x13>
		if (*s == c)
  8008ec:	38 ca                	cmp    %cl,%dl
  8008ee:	74 0f                	je     8008ff <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f0:	83 c0 01             	add    $0x1,%eax
  8008f3:	0f b6 10             	movzbl (%eax),%edx
  8008f6:	84 d2                	test   %dl,%dl
  8008f8:	75 f2                	jne    8008ec <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090b:	eb 03                	jmp    800910 <strfind+0xf>
  80090d:	83 c0 01             	add    $0x1,%eax
  800910:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800913:	38 ca                	cmp    %cl,%dl
  800915:	74 04                	je     80091b <strfind+0x1a>
  800917:	84 d2                	test   %dl,%dl
  800919:	75 f2                	jne    80090d <strfind+0xc>
			break;
	return (char *) s;
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	57                   	push   %edi
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	8b 7d 08             	mov    0x8(%ebp),%edi
  800926:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800929:	85 c9                	test   %ecx,%ecx
  80092b:	74 36                	je     800963 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800933:	75 28                	jne    80095d <memset+0x40>
  800935:	f6 c1 03             	test   $0x3,%cl
  800938:	75 23                	jne    80095d <memset+0x40>
		c &= 0xFF;
  80093a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093e:	89 d3                	mov    %edx,%ebx
  800940:	c1 e3 08             	shl    $0x8,%ebx
  800943:	89 d6                	mov    %edx,%esi
  800945:	c1 e6 18             	shl    $0x18,%esi
  800948:	89 d0                	mov    %edx,%eax
  80094a:	c1 e0 10             	shl    $0x10,%eax
  80094d:	09 f0                	or     %esi,%eax
  80094f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800951:	89 d8                	mov    %ebx,%eax
  800953:	09 d0                	or     %edx,%eax
  800955:	c1 e9 02             	shr    $0x2,%ecx
  800958:	fc                   	cld    
  800959:	f3 ab                	rep stos %eax,%es:(%edi)
  80095b:	eb 06                	jmp    800963 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800960:	fc                   	cld    
  800961:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800963:	89 f8                	mov    %edi,%eax
  800965:	5b                   	pop    %ebx
  800966:	5e                   	pop    %esi
  800967:	5f                   	pop    %edi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	57                   	push   %edi
  80096e:	56                   	push   %esi
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	8b 75 0c             	mov    0xc(%ebp),%esi
  800975:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800978:	39 c6                	cmp    %eax,%esi
  80097a:	73 35                	jae    8009b1 <memmove+0x47>
  80097c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097f:	39 d0                	cmp    %edx,%eax
  800981:	73 2e                	jae    8009b1 <memmove+0x47>
		s += n;
		d += n;
  800983:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800986:	89 d6                	mov    %edx,%esi
  800988:	09 fe                	or     %edi,%esi
  80098a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800990:	75 13                	jne    8009a5 <memmove+0x3b>
  800992:	f6 c1 03             	test   $0x3,%cl
  800995:	75 0e                	jne    8009a5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800997:	83 ef 04             	sub    $0x4,%edi
  80099a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099d:	c1 e9 02             	shr    $0x2,%ecx
  8009a0:	fd                   	std    
  8009a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a3:	eb 09                	jmp    8009ae <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a5:	83 ef 01             	sub    $0x1,%edi
  8009a8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009ab:	fd                   	std    
  8009ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ae:	fc                   	cld    
  8009af:	eb 1d                	jmp    8009ce <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b1:	89 f2                	mov    %esi,%edx
  8009b3:	09 c2                	or     %eax,%edx
  8009b5:	f6 c2 03             	test   $0x3,%dl
  8009b8:	75 0f                	jne    8009c9 <memmove+0x5f>
  8009ba:	f6 c1 03             	test   $0x3,%cl
  8009bd:	75 0a                	jne    8009c9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
  8009c2:	89 c7                	mov    %eax,%edi
  8009c4:	fc                   	cld    
  8009c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c7:	eb 05                	jmp    8009ce <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c9:	89 c7                	mov    %eax,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d5:	ff 75 10             	pushl  0x10(%ebp)
  8009d8:	ff 75 0c             	pushl  0xc(%ebp)
  8009db:	ff 75 08             	pushl  0x8(%ebp)
  8009de:	e8 87 ff ff ff       	call   80096a <memmove>
}
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f0:	89 c6                	mov    %eax,%esi
  8009f2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f5:	eb 1a                	jmp    800a11 <memcmp+0x2c>
		if (*s1 != *s2)
  8009f7:	0f b6 08             	movzbl (%eax),%ecx
  8009fa:	0f b6 1a             	movzbl (%edx),%ebx
  8009fd:	38 d9                	cmp    %bl,%cl
  8009ff:	74 0a                	je     800a0b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a01:	0f b6 c1             	movzbl %cl,%eax
  800a04:	0f b6 db             	movzbl %bl,%ebx
  800a07:	29 d8                	sub    %ebx,%eax
  800a09:	eb 0f                	jmp    800a1a <memcmp+0x35>
		s1++, s2++;
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a11:	39 f0                	cmp    %esi,%eax
  800a13:	75 e2                	jne    8009f7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	53                   	push   %ebx
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a25:	89 c1                	mov    %eax,%ecx
  800a27:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2e:	eb 0a                	jmp    800a3a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a30:	0f b6 10             	movzbl (%eax),%edx
  800a33:	39 da                	cmp    %ebx,%edx
  800a35:	74 07                	je     800a3e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a37:	83 c0 01             	add    $0x1,%eax
  800a3a:	39 c8                	cmp    %ecx,%eax
  800a3c:	72 f2                	jb     800a30 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a3e:	5b                   	pop    %ebx
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	57                   	push   %edi
  800a45:	56                   	push   %esi
  800a46:	53                   	push   %ebx
  800a47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4d:	eb 03                	jmp    800a52 <strtol+0x11>
		s++;
  800a4f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a52:	0f b6 01             	movzbl (%ecx),%eax
  800a55:	3c 20                	cmp    $0x20,%al
  800a57:	74 f6                	je     800a4f <strtol+0xe>
  800a59:	3c 09                	cmp    $0x9,%al
  800a5b:	74 f2                	je     800a4f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a5d:	3c 2b                	cmp    $0x2b,%al
  800a5f:	75 0a                	jne    800a6b <strtol+0x2a>
		s++;
  800a61:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a64:	bf 00 00 00 00       	mov    $0x0,%edi
  800a69:	eb 11                	jmp    800a7c <strtol+0x3b>
  800a6b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a70:	3c 2d                	cmp    $0x2d,%al
  800a72:	75 08                	jne    800a7c <strtol+0x3b>
		s++, neg = 1;
  800a74:	83 c1 01             	add    $0x1,%ecx
  800a77:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a82:	75 15                	jne    800a99 <strtol+0x58>
  800a84:	80 39 30             	cmpb   $0x30,(%ecx)
  800a87:	75 10                	jne    800a99 <strtol+0x58>
  800a89:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a8d:	75 7c                	jne    800b0b <strtol+0xca>
		s += 2, base = 16;
  800a8f:	83 c1 02             	add    $0x2,%ecx
  800a92:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a97:	eb 16                	jmp    800aaf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a99:	85 db                	test   %ebx,%ebx
  800a9b:	75 12                	jne    800aaf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa2:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa5:	75 08                	jne    800aaf <strtol+0x6e>
		s++, base = 8;
  800aa7:	83 c1 01             	add    $0x1,%ecx
  800aaa:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab7:	0f b6 11             	movzbl (%ecx),%edx
  800aba:	8d 72 d0             	lea    -0x30(%edx),%esi
  800abd:	89 f3                	mov    %esi,%ebx
  800abf:	80 fb 09             	cmp    $0x9,%bl
  800ac2:	77 08                	ja     800acc <strtol+0x8b>
			dig = *s - '0';
  800ac4:	0f be d2             	movsbl %dl,%edx
  800ac7:	83 ea 30             	sub    $0x30,%edx
  800aca:	eb 22                	jmp    800aee <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800acc:	8d 72 9f             	lea    -0x61(%edx),%esi
  800acf:	89 f3                	mov    %esi,%ebx
  800ad1:	80 fb 19             	cmp    $0x19,%bl
  800ad4:	77 08                	ja     800ade <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ad6:	0f be d2             	movsbl %dl,%edx
  800ad9:	83 ea 57             	sub    $0x57,%edx
  800adc:	eb 10                	jmp    800aee <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ade:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae1:	89 f3                	mov    %esi,%ebx
  800ae3:	80 fb 19             	cmp    $0x19,%bl
  800ae6:	77 16                	ja     800afe <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ae8:	0f be d2             	movsbl %dl,%edx
  800aeb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aee:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af1:	7d 0b                	jge    800afe <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800af3:	83 c1 01             	add    $0x1,%ecx
  800af6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800afa:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800afc:	eb b9                	jmp    800ab7 <strtol+0x76>

	if (endptr)
  800afe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b02:	74 0d                	je     800b11 <strtol+0xd0>
		*endptr = (char *) s;
  800b04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b07:	89 0e                	mov    %ecx,(%esi)
  800b09:	eb 06                	jmp    800b11 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0b:	85 db                	test   %ebx,%ebx
  800b0d:	74 98                	je     800aa7 <strtol+0x66>
  800b0f:	eb 9e                	jmp    800aaf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b11:	89 c2                	mov    %eax,%edx
  800b13:	f7 da                	neg    %edx
  800b15:	85 ff                	test   %edi,%edi
  800b17:	0f 45 c2             	cmovne %edx,%eax
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b30:	89 c3                	mov    %eax,%ebx
  800b32:	89 c7                	mov    %eax,%edi
  800b34:	89 c6                	mov    %eax,%esi
  800b36:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	ba 00 00 00 00       	mov    $0x0,%edx
  800b48:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4d:	89 d1                	mov    %edx,%ecx
  800b4f:	89 d3                	mov    %edx,%ebx
  800b51:	89 d7                	mov    %edx,%edi
  800b53:	89 d6                	mov    %edx,%esi
  800b55:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	89 cb                	mov    %ecx,%ebx
  800b74:	89 cf                	mov    %ecx,%edi
  800b76:	89 ce                	mov    %ecx,%esi
  800b78:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7a:	85 c0                	test   %eax,%eax
  800b7c:	7e 17                	jle    800b95 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	50                   	push   %eax
  800b82:	6a 03                	push   $0x3
  800b84:	68 84 13 80 00       	push   $0x801384
  800b89:	6a 23                	push   $0x23
  800b8b:	68 a1 13 80 00       	push   $0x8013a1
  800b90:	e8 9f f5 ff ff       	call   800134 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	b8 02 00 00 00       	mov    $0x2,%eax
  800bad:	89 d1                	mov    %edx,%ecx
  800baf:	89 d3                	mov    %edx,%ebx
  800bb1:	89 d7                	mov    %edx,%edi
  800bb3:	89 d6                	mov    %edx,%esi
  800bb5:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_yield>:

void
sys_yield(void)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bcc:	89 d1                	mov    %edx,%ecx
  800bce:	89 d3                	mov    %edx,%ebx
  800bd0:	89 d7                	mov    %edx,%edi
  800bd2:	89 d6                	mov    %edx,%esi
  800bd4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	be 00 00 00 00       	mov    $0x0,%esi
  800be9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf7:	89 f7                	mov    %esi,%edi
  800bf9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 04                	push   $0x4
  800c05:	68 84 13 80 00       	push   $0x801384
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 a1 13 80 00       	push   $0x8013a1
  800c11:	e8 1e f5 ff ff       	call   800134 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c38:	8b 75 18             	mov    0x18(%ebp),%esi
  800c3b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 17                	jle    800c58 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 05                	push   $0x5
  800c47:	68 84 13 80 00       	push   $0x801384
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 a1 13 80 00       	push   $0x8013a1
  800c53:	e8 dc f4 ff ff       	call   800134 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 df                	mov    %ebx,%edi
  800c7b:	89 de                	mov    %ebx,%esi
  800c7d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 06                	push   $0x6
  800c89:	68 84 13 80 00       	push   $0x801384
  800c8e:	6a 23                	push   $0x23
  800c90:	68 a1 13 80 00       	push   $0x8013a1
  800c95:	e8 9a f4 ff ff       	call   800134 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb0:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 df                	mov    %ebx,%edi
  800cbd:	89 de                	mov    %ebx,%esi
  800cbf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 17                	jle    800cdc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 08                	push   $0x8
  800ccb:	68 84 13 80 00       	push   $0x801384
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 a1 13 80 00       	push   $0x8013a1
  800cd7:	e8 58 f4 ff ff       	call   800134 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf2:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	89 df                	mov    %ebx,%edi
  800cff:	89 de                	mov    %ebx,%esi
  800d01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 17                	jle    800d1e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 09                	push   $0x9
  800d0d:	68 84 13 80 00       	push   $0x801384
  800d12:	6a 23                	push   $0x23
  800d14:	68 a1 13 80 00       	push   $0x8013a1
  800d19:	e8 16 f4 ff ff       	call   800134 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2c:	be 00 00 00 00       	mov    $0x0,%esi
  800d31:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d42:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	57                   	push   %edi
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
  800d4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d57:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	89 cb                	mov    %ecx,%ebx
  800d61:	89 cf                	mov    %ecx,%edi
  800d63:	89 ce                	mov    %ecx,%esi
  800d65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d67:	85 c0                	test   %eax,%eax
  800d69:	7e 17                	jle    800d82 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	50                   	push   %eax
  800d6f:	6a 0c                	push   $0xc
  800d71:	68 84 13 80 00       	push   $0x801384
  800d76:	6a 23                	push   $0x23
  800d78:	68 a1 13 80 00       	push   $0x8013a1
  800d7d:	e8 b2 f3 ff ff       	call   800134 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_change_pr>:

int
sys_change_pr(int pr)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d95:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	89 cb                	mov    %ecx,%ebx
  800d9f:	89 cf                	mov    %ecx,%edi
  800da1:	89 ce                	mov    %ecx,%esi
  800da3:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    
  800daa:	66 90                	xchg   %ax,%ax
  800dac:	66 90                	xchg   %ax,%ax
  800dae:	66 90                	xchg   %ax,%ax

00800db0 <__udivdi3>:
  800db0:	55                   	push   %ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 1c             	sub    $0x1c,%esp
  800db7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800dbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800dbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800dc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800dc7:	85 f6                	test   %esi,%esi
  800dc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800dcd:	89 ca                	mov    %ecx,%edx
  800dcf:	89 f8                	mov    %edi,%eax
  800dd1:	75 3d                	jne    800e10 <__udivdi3+0x60>
  800dd3:	39 cf                	cmp    %ecx,%edi
  800dd5:	0f 87 c5 00 00 00    	ja     800ea0 <__udivdi3+0xf0>
  800ddb:	85 ff                	test   %edi,%edi
  800ddd:	89 fd                	mov    %edi,%ebp
  800ddf:	75 0b                	jne    800dec <__udivdi3+0x3c>
  800de1:	b8 01 00 00 00       	mov    $0x1,%eax
  800de6:	31 d2                	xor    %edx,%edx
  800de8:	f7 f7                	div    %edi
  800dea:	89 c5                	mov    %eax,%ebp
  800dec:	89 c8                	mov    %ecx,%eax
  800dee:	31 d2                	xor    %edx,%edx
  800df0:	f7 f5                	div    %ebp
  800df2:	89 c1                	mov    %eax,%ecx
  800df4:	89 d8                	mov    %ebx,%eax
  800df6:	89 cf                	mov    %ecx,%edi
  800df8:	f7 f5                	div    %ebp
  800dfa:	89 c3                	mov    %eax,%ebx
  800dfc:	89 d8                	mov    %ebx,%eax
  800dfe:	89 fa                	mov    %edi,%edx
  800e00:	83 c4 1c             	add    $0x1c,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
  800e08:	90                   	nop
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	39 ce                	cmp    %ecx,%esi
  800e12:	77 74                	ja     800e88 <__udivdi3+0xd8>
  800e14:	0f bd fe             	bsr    %esi,%edi
  800e17:	83 f7 1f             	xor    $0x1f,%edi
  800e1a:	0f 84 98 00 00 00    	je     800eb8 <__udivdi3+0x108>
  800e20:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e25:	89 f9                	mov    %edi,%ecx
  800e27:	89 c5                	mov    %eax,%ebp
  800e29:	29 fb                	sub    %edi,%ebx
  800e2b:	d3 e6                	shl    %cl,%esi
  800e2d:	89 d9                	mov    %ebx,%ecx
  800e2f:	d3 ed                	shr    %cl,%ebp
  800e31:	89 f9                	mov    %edi,%ecx
  800e33:	d3 e0                	shl    %cl,%eax
  800e35:	09 ee                	or     %ebp,%esi
  800e37:	89 d9                	mov    %ebx,%ecx
  800e39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e3d:	89 d5                	mov    %edx,%ebp
  800e3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e43:	d3 ed                	shr    %cl,%ebp
  800e45:	89 f9                	mov    %edi,%ecx
  800e47:	d3 e2                	shl    %cl,%edx
  800e49:	89 d9                	mov    %ebx,%ecx
  800e4b:	d3 e8                	shr    %cl,%eax
  800e4d:	09 c2                	or     %eax,%edx
  800e4f:	89 d0                	mov    %edx,%eax
  800e51:	89 ea                	mov    %ebp,%edx
  800e53:	f7 f6                	div    %esi
  800e55:	89 d5                	mov    %edx,%ebp
  800e57:	89 c3                	mov    %eax,%ebx
  800e59:	f7 64 24 0c          	mull   0xc(%esp)
  800e5d:	39 d5                	cmp    %edx,%ebp
  800e5f:	72 10                	jb     800e71 <__udivdi3+0xc1>
  800e61:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e65:	89 f9                	mov    %edi,%ecx
  800e67:	d3 e6                	shl    %cl,%esi
  800e69:	39 c6                	cmp    %eax,%esi
  800e6b:	73 07                	jae    800e74 <__udivdi3+0xc4>
  800e6d:	39 d5                	cmp    %edx,%ebp
  800e6f:	75 03                	jne    800e74 <__udivdi3+0xc4>
  800e71:	83 eb 01             	sub    $0x1,%ebx
  800e74:	31 ff                	xor    %edi,%edi
  800e76:	89 d8                	mov    %ebx,%eax
  800e78:	89 fa                	mov    %edi,%edx
  800e7a:	83 c4 1c             	add    $0x1c,%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
  800e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e88:	31 ff                	xor    %edi,%edi
  800e8a:	31 db                	xor    %ebx,%ebx
  800e8c:	89 d8                	mov    %ebx,%eax
  800e8e:	89 fa                	mov    %edi,%edx
  800e90:	83 c4 1c             	add    $0x1c,%esp
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5f                   	pop    %edi
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    
  800e98:	90                   	nop
  800e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	89 d8                	mov    %ebx,%eax
  800ea2:	f7 f7                	div    %edi
  800ea4:	31 ff                	xor    %edi,%edi
  800ea6:	89 c3                	mov    %eax,%ebx
  800ea8:	89 d8                	mov    %ebx,%eax
  800eaa:	89 fa                	mov    %edi,%edx
  800eac:	83 c4 1c             	add    $0x1c,%esp
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    
  800eb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb8:	39 ce                	cmp    %ecx,%esi
  800eba:	72 0c                	jb     800ec8 <__udivdi3+0x118>
  800ebc:	31 db                	xor    %ebx,%ebx
  800ebe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ec2:	0f 87 34 ff ff ff    	ja     800dfc <__udivdi3+0x4c>
  800ec8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ecd:	e9 2a ff ff ff       	jmp    800dfc <__udivdi3+0x4c>
  800ed2:	66 90                	xchg   %ax,%ax
  800ed4:	66 90                	xchg   %ax,%ax
  800ed6:	66 90                	xchg   %ax,%ax
  800ed8:	66 90                	xchg   %ax,%ax
  800eda:	66 90                	xchg   %ax,%ax
  800edc:	66 90                	xchg   %ax,%ax
  800ede:	66 90                	xchg   %ax,%ax

00800ee0 <__umoddi3>:
  800ee0:	55                   	push   %ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 1c             	sub    $0x1c,%esp
  800ee7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800eeb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800eef:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ef3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ef7:	85 d2                	test   %edx,%edx
  800ef9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800efd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f01:	89 f3                	mov    %esi,%ebx
  800f03:	89 3c 24             	mov    %edi,(%esp)
  800f06:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f0a:	75 1c                	jne    800f28 <__umoddi3+0x48>
  800f0c:	39 f7                	cmp    %esi,%edi
  800f0e:	76 50                	jbe    800f60 <__umoddi3+0x80>
  800f10:	89 c8                	mov    %ecx,%eax
  800f12:	89 f2                	mov    %esi,%edx
  800f14:	f7 f7                	div    %edi
  800f16:	89 d0                	mov    %edx,%eax
  800f18:	31 d2                	xor    %edx,%edx
  800f1a:	83 c4 1c             	add    $0x1c,%esp
  800f1d:	5b                   	pop    %ebx
  800f1e:	5e                   	pop    %esi
  800f1f:	5f                   	pop    %edi
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    
  800f22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f28:	39 f2                	cmp    %esi,%edx
  800f2a:	89 d0                	mov    %edx,%eax
  800f2c:	77 52                	ja     800f80 <__umoddi3+0xa0>
  800f2e:	0f bd ea             	bsr    %edx,%ebp
  800f31:	83 f5 1f             	xor    $0x1f,%ebp
  800f34:	75 5a                	jne    800f90 <__umoddi3+0xb0>
  800f36:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f3a:	0f 82 e0 00 00 00    	jb     801020 <__umoddi3+0x140>
  800f40:	39 0c 24             	cmp    %ecx,(%esp)
  800f43:	0f 86 d7 00 00 00    	jbe    801020 <__umoddi3+0x140>
  800f49:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f4d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f51:	83 c4 1c             	add    $0x1c,%esp
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    
  800f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f60:	85 ff                	test   %edi,%edi
  800f62:	89 fd                	mov    %edi,%ebp
  800f64:	75 0b                	jne    800f71 <__umoddi3+0x91>
  800f66:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6b:	31 d2                	xor    %edx,%edx
  800f6d:	f7 f7                	div    %edi
  800f6f:	89 c5                	mov    %eax,%ebp
  800f71:	89 f0                	mov    %esi,%eax
  800f73:	31 d2                	xor    %edx,%edx
  800f75:	f7 f5                	div    %ebp
  800f77:	89 c8                	mov    %ecx,%eax
  800f79:	f7 f5                	div    %ebp
  800f7b:	89 d0                	mov    %edx,%eax
  800f7d:	eb 99                	jmp    800f18 <__umoddi3+0x38>
  800f7f:	90                   	nop
  800f80:	89 c8                	mov    %ecx,%eax
  800f82:	89 f2                	mov    %esi,%edx
  800f84:	83 c4 1c             	add    $0x1c,%esp
  800f87:	5b                   	pop    %ebx
  800f88:	5e                   	pop    %esi
  800f89:	5f                   	pop    %edi
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    
  800f8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f90:	8b 34 24             	mov    (%esp),%esi
  800f93:	bf 20 00 00 00       	mov    $0x20,%edi
  800f98:	89 e9                	mov    %ebp,%ecx
  800f9a:	29 ef                	sub    %ebp,%edi
  800f9c:	d3 e0                	shl    %cl,%eax
  800f9e:	89 f9                	mov    %edi,%ecx
  800fa0:	89 f2                	mov    %esi,%edx
  800fa2:	d3 ea                	shr    %cl,%edx
  800fa4:	89 e9                	mov    %ebp,%ecx
  800fa6:	09 c2                	or     %eax,%edx
  800fa8:	89 d8                	mov    %ebx,%eax
  800faa:	89 14 24             	mov    %edx,(%esp)
  800fad:	89 f2                	mov    %esi,%edx
  800faf:	d3 e2                	shl    %cl,%edx
  800fb1:	89 f9                	mov    %edi,%ecx
  800fb3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fb7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fbb:	d3 e8                	shr    %cl,%eax
  800fbd:	89 e9                	mov    %ebp,%ecx
  800fbf:	89 c6                	mov    %eax,%esi
  800fc1:	d3 e3                	shl    %cl,%ebx
  800fc3:	89 f9                	mov    %edi,%ecx
  800fc5:	89 d0                	mov    %edx,%eax
  800fc7:	d3 e8                	shr    %cl,%eax
  800fc9:	89 e9                	mov    %ebp,%ecx
  800fcb:	09 d8                	or     %ebx,%eax
  800fcd:	89 d3                	mov    %edx,%ebx
  800fcf:	89 f2                	mov    %esi,%edx
  800fd1:	f7 34 24             	divl   (%esp)
  800fd4:	89 d6                	mov    %edx,%esi
  800fd6:	d3 e3                	shl    %cl,%ebx
  800fd8:	f7 64 24 04          	mull   0x4(%esp)
  800fdc:	39 d6                	cmp    %edx,%esi
  800fde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fe2:	89 d1                	mov    %edx,%ecx
  800fe4:	89 c3                	mov    %eax,%ebx
  800fe6:	72 08                	jb     800ff0 <__umoddi3+0x110>
  800fe8:	75 11                	jne    800ffb <__umoddi3+0x11b>
  800fea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800fee:	73 0b                	jae    800ffb <__umoddi3+0x11b>
  800ff0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800ff4:	1b 14 24             	sbb    (%esp),%edx
  800ff7:	89 d1                	mov    %edx,%ecx
  800ff9:	89 c3                	mov    %eax,%ebx
  800ffb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800fff:	29 da                	sub    %ebx,%edx
  801001:	19 ce                	sbb    %ecx,%esi
  801003:	89 f9                	mov    %edi,%ecx
  801005:	89 f0                	mov    %esi,%eax
  801007:	d3 e0                	shl    %cl,%eax
  801009:	89 e9                	mov    %ebp,%ecx
  80100b:	d3 ea                	shr    %cl,%edx
  80100d:	89 e9                	mov    %ebp,%ecx
  80100f:	d3 ee                	shr    %cl,%esi
  801011:	09 d0                	or     %edx,%eax
  801013:	89 f2                	mov    %esi,%edx
  801015:	83 c4 1c             	add    $0x1c,%esp
  801018:	5b                   	pop    %ebx
  801019:	5e                   	pop    %esi
  80101a:	5f                   	pop    %edi
  80101b:	5d                   	pop    %ebp
  80101c:	c3                   	ret    
  80101d:	8d 76 00             	lea    0x0(%esi),%esi
  801020:	29 f9                	sub    %edi,%ecx
  801022:	19 d6                	sbb    %edx,%esi
  801024:	89 74 24 04          	mov    %esi,0x4(%esp)
  801028:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80102c:	e9 18 ff ff ff       	jmp    800f49 <__umoddi3+0x69>
