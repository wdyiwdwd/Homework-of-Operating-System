
obj/user/faultreadkernel：     文件格式 elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80003f:	68 c0 0f 80 00       	push   $0x800fc0
  800044:	e8 f0 00 00 00       	call   800139 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800059:	e8 6b 0a 00 00       	call   800ac9 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	c1 e0 07             	shl    $0x7,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 e7 09 00 00       	call   800a88 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	53                   	push   %ebx
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b0:	8b 13                	mov    (%ebx),%edx
  8000b2:	8d 42 01             	lea    0x1(%edx),%eax
  8000b5:	89 03                	mov    %eax,(%ebx)
  8000b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c3:	75 1a                	jne    8000df <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000c5:	83 ec 08             	sub    $0x8,%esp
  8000c8:	68 ff 00 00 00       	push   $0xff
  8000cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d0:	50                   	push   %eax
  8000d1:	e8 75 09 00 00       	call   800a4b <sys_cputs>
		b->idx = 0;
  8000d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    

008000e8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000f8:	00 00 00 
	b.cnt = 0;
  8000fb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800102:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800105:	ff 75 0c             	pushl  0xc(%ebp)
  800108:	ff 75 08             	pushl  0x8(%ebp)
  80010b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800111:	50                   	push   %eax
  800112:	68 a6 00 80 00       	push   $0x8000a6
  800117:	e8 54 01 00 00       	call   800270 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011c:	83 c4 08             	add    $0x8,%esp
  80011f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800125:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 1a 09 00 00       	call   800a4b <sys_cputs>

	return b.cnt;
}
  800131:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80013f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800142:	50                   	push   %eax
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	e8 9d ff ff ff       	call   8000e8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
  800153:	83 ec 1c             	sub    $0x1c,%esp
  800156:	89 c7                	mov    %eax,%edi
  800158:	89 d6                	mov    %edx,%esi
  80015a:	8b 45 08             	mov    0x8(%ebp),%eax
  80015d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800160:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800163:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800166:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800169:	bb 00 00 00 00       	mov    $0x0,%ebx
  80016e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800171:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800174:	39 d3                	cmp    %edx,%ebx
  800176:	72 05                	jb     80017d <printnum+0x30>
  800178:	39 45 10             	cmp    %eax,0x10(%ebp)
  80017b:	77 45                	ja     8001c2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	ff 75 18             	pushl  0x18(%ebp)
  800183:	8b 45 14             	mov    0x14(%ebp),%eax
  800186:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800189:	53                   	push   %ebx
  80018a:	ff 75 10             	pushl  0x10(%ebp)
  80018d:	83 ec 08             	sub    $0x8,%esp
  800190:	ff 75 e4             	pushl  -0x1c(%ebp)
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	ff 75 dc             	pushl  -0x24(%ebp)
  800199:	ff 75 d8             	pushl  -0x28(%ebp)
  80019c:	e8 7f 0b 00 00       	call   800d20 <__udivdi3>
  8001a1:	83 c4 18             	add    $0x18,%esp
  8001a4:	52                   	push   %edx
  8001a5:	50                   	push   %eax
  8001a6:	89 f2                	mov    %esi,%edx
  8001a8:	89 f8                	mov    %edi,%eax
  8001aa:	e8 9e ff ff ff       	call   80014d <printnum>
  8001af:	83 c4 20             	add    $0x20,%esp
  8001b2:	eb 18                	jmp    8001cc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	56                   	push   %esi
  8001b8:	ff 75 18             	pushl  0x18(%ebp)
  8001bb:	ff d7                	call   *%edi
  8001bd:	83 c4 10             	add    $0x10,%esp
  8001c0:	eb 03                	jmp    8001c5 <printnum+0x78>
  8001c2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c5:	83 eb 01             	sub    $0x1,%ebx
  8001c8:	85 db                	test   %ebx,%ebx
  8001ca:	7f e8                	jg     8001b4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	83 ec 04             	sub    $0x4,%esp
  8001d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001dc:	ff 75 d8             	pushl  -0x28(%ebp)
  8001df:	e8 6c 0c 00 00       	call   800e50 <__umoddi3>
  8001e4:	83 c4 14             	add    $0x14,%esp
  8001e7:	0f be 80 f1 0f 80 00 	movsbl 0x800ff1(%eax),%eax
  8001ee:	50                   	push   %eax
  8001ef:	ff d7                	call   *%edi
}
  8001f1:	83 c4 10             	add    $0x10,%esp
  8001f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f7:	5b                   	pop    %ebx
  8001f8:	5e                   	pop    %esi
  8001f9:	5f                   	pop    %edi
  8001fa:	5d                   	pop    %ebp
  8001fb:	c3                   	ret    

008001fc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8001ff:	83 fa 01             	cmp    $0x1,%edx
  800202:	7e 0e                	jle    800212 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800204:	8b 10                	mov    (%eax),%edx
  800206:	8d 4a 08             	lea    0x8(%edx),%ecx
  800209:	89 08                	mov    %ecx,(%eax)
  80020b:	8b 02                	mov    (%edx),%eax
  80020d:	8b 52 04             	mov    0x4(%edx),%edx
  800210:	eb 22                	jmp    800234 <getuint+0x38>
	else if (lflag)
  800212:	85 d2                	test   %edx,%edx
  800214:	74 10                	je     800226 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800216:	8b 10                	mov    (%eax),%edx
  800218:	8d 4a 04             	lea    0x4(%edx),%ecx
  80021b:	89 08                	mov    %ecx,(%eax)
  80021d:	8b 02                	mov    (%edx),%eax
  80021f:	ba 00 00 00 00       	mov    $0x0,%edx
  800224:	eb 0e                	jmp    800234 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800226:	8b 10                	mov    (%eax),%edx
  800228:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022b:	89 08                	mov    %ecx,(%eax)
  80022d:	8b 02                	mov    (%edx),%eax
  80022f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800240:	8b 10                	mov    (%eax),%edx
  800242:	3b 50 04             	cmp    0x4(%eax),%edx
  800245:	73 0a                	jae    800251 <sprintputch+0x1b>
		*b->buf++ = ch;
  800247:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024a:	89 08                	mov    %ecx,(%eax)
  80024c:	8b 45 08             	mov    0x8(%ebp),%eax
  80024f:	88 02                	mov    %al,(%edx)
}
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    

00800253 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800259:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025c:	50                   	push   %eax
  80025d:	ff 75 10             	pushl  0x10(%ebp)
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	ff 75 08             	pushl  0x8(%ebp)
  800266:	e8 05 00 00 00       	call   800270 <vprintfmt>
	va_end(ap);
}
  80026b:	83 c4 10             	add    $0x10,%esp
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 2c             	sub    $0x2c,%esp
  800279:	8b 75 08             	mov    0x8(%ebp),%esi
  80027c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80027f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800282:	eb 1d                	jmp    8002a1 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800284:	85 c0                	test   %eax,%eax
  800286:	75 0f                	jne    800297 <vprintfmt+0x27>
				csa = 0x0700;
  800288:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80028f:	07 00 00 
				return;
  800292:	e9 c4 03 00 00       	jmp    80065b <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800297:	83 ec 08             	sub    $0x8,%esp
  80029a:	53                   	push   %ebx
  80029b:	50                   	push   %eax
  80029c:	ff d6                	call   *%esi
  80029e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a1:	83 c7 01             	add    $0x1,%edi
  8002a4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002a8:	83 f8 25             	cmp    $0x25,%eax
  8002ab:	75 d7                	jne    800284 <vprintfmt+0x14>
  8002ad:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002b1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002b8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002bf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cb:	eb 07                	jmp    8002d4 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d4:	8d 47 01             	lea    0x1(%edi),%eax
  8002d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002da:	0f b6 07             	movzbl (%edi),%eax
  8002dd:	0f b6 c8             	movzbl %al,%ecx
  8002e0:	83 e8 23             	sub    $0x23,%eax
  8002e3:	3c 55                	cmp    $0x55,%al
  8002e5:	0f 87 55 03 00 00    	ja     800640 <vprintfmt+0x3d0>
  8002eb:	0f b6 c0             	movzbl %al,%eax
  8002ee:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8002f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002f8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002fc:	eb d6                	jmp    8002d4 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800301:	b8 00 00 00 00       	mov    $0x0,%eax
  800306:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800309:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80030c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800310:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800313:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800316:	83 fa 09             	cmp    $0x9,%edx
  800319:	77 39                	ja     800354 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80031b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80031e:	eb e9                	jmp    800309 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800320:	8b 45 14             	mov    0x14(%ebp),%eax
  800323:	8d 48 04             	lea    0x4(%eax),%ecx
  800326:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800329:	8b 00                	mov    (%eax),%eax
  80032b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800331:	eb 27                	jmp    80035a <vprintfmt+0xea>
  800333:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800336:	85 c0                	test   %eax,%eax
  800338:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033d:	0f 49 c8             	cmovns %eax,%ecx
  800340:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800343:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800346:	eb 8c                	jmp    8002d4 <vprintfmt+0x64>
  800348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80034b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800352:	eb 80                	jmp    8002d4 <vprintfmt+0x64>
  800354:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800357:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80035a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035e:	0f 89 70 ff ff ff    	jns    8002d4 <vprintfmt+0x64>
				width = precision, precision = -1;
  800364:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800367:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800371:	e9 5e ff ff ff       	jmp    8002d4 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800376:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80037c:	e9 53 ff ff ff       	jmp    8002d4 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800381:	8b 45 14             	mov    0x14(%ebp),%eax
  800384:	8d 50 04             	lea    0x4(%eax),%edx
  800387:	89 55 14             	mov    %edx,0x14(%ebp)
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	53                   	push   %ebx
  80038e:	ff 30                	pushl  (%eax)
  800390:	ff d6                	call   *%esi
			break;
  800392:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800398:	e9 04 ff ff ff       	jmp    8002a1 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8d 50 04             	lea    0x4(%eax),%edx
  8003a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a6:	8b 00                	mov    (%eax),%eax
  8003a8:	99                   	cltd   
  8003a9:	31 d0                	xor    %edx,%eax
  8003ab:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ad:	83 f8 08             	cmp    $0x8,%eax
  8003b0:	7f 0b                	jg     8003bd <vprintfmt+0x14d>
  8003b2:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  8003b9:	85 d2                	test   %edx,%edx
  8003bb:	75 18                	jne    8003d5 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  8003bd:	50                   	push   %eax
  8003be:	68 09 10 80 00       	push   $0x801009
  8003c3:	53                   	push   %ebx
  8003c4:	56                   	push   %esi
  8003c5:	e8 89 fe ff ff       	call   800253 <printfmt>
  8003ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d0:	e9 cc fe ff ff       	jmp    8002a1 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8003d5:	52                   	push   %edx
  8003d6:	68 12 10 80 00       	push   $0x801012
  8003db:	53                   	push   %ebx
  8003dc:	56                   	push   %esi
  8003dd:	e8 71 fe ff ff       	call   800253 <printfmt>
  8003e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e8:	e9 b4 fe ff ff       	jmp    8002a1 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 50 04             	lea    0x4(%eax),%edx
  8003f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f8:	85 ff                	test   %edi,%edi
  8003fa:	b8 02 10 80 00       	mov    $0x801002,%eax
  8003ff:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800402:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800406:	0f 8e 94 00 00 00    	jle    8004a0 <vprintfmt+0x230>
  80040c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800410:	0f 84 98 00 00 00    	je     8004ae <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	ff 75 d0             	pushl  -0x30(%ebp)
  80041c:	57                   	push   %edi
  80041d:	e8 c1 02 00 00       	call   8006e3 <strnlen>
  800422:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800425:	29 c1                	sub    %eax,%ecx
  800427:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80042a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800431:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800434:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800437:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800439:	eb 0f                	jmp    80044a <vprintfmt+0x1da>
					putch(padc, putdat);
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	53                   	push   %ebx
  80043f:	ff 75 e0             	pushl  -0x20(%ebp)
  800442:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800444:	83 ef 01             	sub    $0x1,%edi
  800447:	83 c4 10             	add    $0x10,%esp
  80044a:	85 ff                	test   %edi,%edi
  80044c:	7f ed                	jg     80043b <vprintfmt+0x1cb>
  80044e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800451:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800454:	85 c9                	test   %ecx,%ecx
  800456:	b8 00 00 00 00       	mov    $0x0,%eax
  80045b:	0f 49 c1             	cmovns %ecx,%eax
  80045e:	29 c1                	sub    %eax,%ecx
  800460:	89 75 08             	mov    %esi,0x8(%ebp)
  800463:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800466:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800469:	89 cb                	mov    %ecx,%ebx
  80046b:	eb 4d                	jmp    8004ba <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80046d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800471:	74 1b                	je     80048e <vprintfmt+0x21e>
  800473:	0f be c0             	movsbl %al,%eax
  800476:	83 e8 20             	sub    $0x20,%eax
  800479:	83 f8 5e             	cmp    $0x5e,%eax
  80047c:	76 10                	jbe    80048e <vprintfmt+0x21e>
					putch('?', putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	ff 75 0c             	pushl  0xc(%ebp)
  800484:	6a 3f                	push   $0x3f
  800486:	ff 55 08             	call   *0x8(%ebp)
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	eb 0d                	jmp    80049b <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	ff 75 0c             	pushl  0xc(%ebp)
  800494:	52                   	push   %edx
  800495:	ff 55 08             	call   *0x8(%ebp)
  800498:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049b:	83 eb 01             	sub    $0x1,%ebx
  80049e:	eb 1a                	jmp    8004ba <vprintfmt+0x24a>
  8004a0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ac:	eb 0c                	jmp    8004ba <vprintfmt+0x24a>
  8004ae:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ba:	83 c7 01             	add    $0x1,%edi
  8004bd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c1:	0f be d0             	movsbl %al,%edx
  8004c4:	85 d2                	test   %edx,%edx
  8004c6:	74 23                	je     8004eb <vprintfmt+0x27b>
  8004c8:	85 f6                	test   %esi,%esi
  8004ca:	78 a1                	js     80046d <vprintfmt+0x1fd>
  8004cc:	83 ee 01             	sub    $0x1,%esi
  8004cf:	79 9c                	jns    80046d <vprintfmt+0x1fd>
  8004d1:	89 df                	mov    %ebx,%edi
  8004d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d9:	eb 18                	jmp    8004f3 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	53                   	push   %ebx
  8004df:	6a 20                	push   $0x20
  8004e1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e3:	83 ef 01             	sub    $0x1,%edi
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	eb 08                	jmp    8004f3 <vprintfmt+0x283>
  8004eb:	89 df                	mov    %ebx,%edi
  8004ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f3:	85 ff                	test   %edi,%edi
  8004f5:	7f e4                	jg     8004db <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004fa:	e9 a2 fd ff ff       	jmp    8002a1 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004ff:	83 fa 01             	cmp    $0x1,%edx
  800502:	7e 16                	jle    80051a <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	8d 50 08             	lea    0x8(%eax),%edx
  80050a:	89 55 14             	mov    %edx,0x14(%ebp)
  80050d:	8b 50 04             	mov    0x4(%eax),%edx
  800510:	8b 00                	mov    (%eax),%eax
  800512:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800515:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800518:	eb 32                	jmp    80054c <vprintfmt+0x2dc>
	else if (lflag)
  80051a:	85 d2                	test   %edx,%edx
  80051c:	74 18                	je     800536 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8d 50 04             	lea    0x4(%eax),%edx
  800524:	89 55 14             	mov    %edx,0x14(%ebp)
  800527:	8b 00                	mov    (%eax),%eax
  800529:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052c:	89 c1                	mov    %eax,%ecx
  80052e:	c1 f9 1f             	sar    $0x1f,%ecx
  800531:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800534:	eb 16                	jmp    80054c <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800536:	8b 45 14             	mov    0x14(%ebp),%eax
  800539:	8d 50 04             	lea    0x4(%eax),%edx
  80053c:	89 55 14             	mov    %edx,0x14(%ebp)
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800544:	89 c1                	mov    %eax,%ecx
  800546:	c1 f9 1f             	sar    $0x1f,%ecx
  800549:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80054c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80054f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800552:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800557:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80055b:	79 74                	jns    8005d1 <vprintfmt+0x361>
				putch('-', putdat);
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	53                   	push   %ebx
  800561:	6a 2d                	push   $0x2d
  800563:	ff d6                	call   *%esi
				num = -(long long) num;
  800565:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800568:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80056b:	f7 d8                	neg    %eax
  80056d:	83 d2 00             	adc    $0x0,%edx
  800570:	f7 da                	neg    %edx
  800572:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800575:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80057a:	eb 55                	jmp    8005d1 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80057c:	8d 45 14             	lea    0x14(%ebp),%eax
  80057f:	e8 78 fc ff ff       	call   8001fc <getuint>
			base = 10;
  800584:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800589:	eb 46                	jmp    8005d1 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  80058b:	8d 45 14             	lea    0x14(%ebp),%eax
  80058e:	e8 69 fc ff ff       	call   8001fc <getuint>
      base = 8;
  800593:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800598:	eb 37                	jmp    8005d1 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	53                   	push   %ebx
  80059e:	6a 30                	push   $0x30
  8005a0:	ff d6                	call   *%esi
			putch('x', putdat);
  8005a2:	83 c4 08             	add    $0x8,%esp
  8005a5:	53                   	push   %ebx
  8005a6:	6a 78                	push   $0x78
  8005a8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ad:	8d 50 04             	lea    0x4(%eax),%edx
  8005b0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005b3:	8b 00                	mov    (%eax),%eax
  8005b5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005ba:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005bd:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005c2:	eb 0d                	jmp    8005d1 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c7:	e8 30 fc ff ff       	call   8001fc <getuint>
			base = 16;
  8005cc:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005d1:	83 ec 0c             	sub    $0xc,%esp
  8005d4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005d8:	57                   	push   %edi
  8005d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8005dc:	51                   	push   %ecx
  8005dd:	52                   	push   %edx
  8005de:	50                   	push   %eax
  8005df:	89 da                	mov    %ebx,%edx
  8005e1:	89 f0                	mov    %esi,%eax
  8005e3:	e8 65 fb ff ff       	call   80014d <printnum>
			break;
  8005e8:	83 c4 20             	add    $0x20,%esp
  8005eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ee:	e9 ae fc ff ff       	jmp    8002a1 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	53                   	push   %ebx
  8005f7:	51                   	push   %ecx
  8005f8:	ff d6                	call   *%esi
			break;
  8005fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800600:	e9 9c fc ff ff       	jmp    8002a1 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800605:	83 fa 01             	cmp    $0x1,%edx
  800608:	7e 0d                	jle    800617 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8d 50 08             	lea    0x8(%eax),%edx
  800610:	89 55 14             	mov    %edx,0x14(%ebp)
  800613:	8b 00                	mov    (%eax),%eax
  800615:	eb 1c                	jmp    800633 <vprintfmt+0x3c3>
	else if (lflag)
  800617:	85 d2                	test   %edx,%edx
  800619:	74 0d                	je     800628 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 50 04             	lea    0x4(%eax),%edx
  800621:	89 55 14             	mov    %edx,0x14(%ebp)
  800624:	8b 00                	mov    (%eax),%eax
  800626:	eb 0b                	jmp    800633 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  800633:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800638:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  80063b:	e9 61 fc ff ff       	jmp    8002a1 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	6a 25                	push   $0x25
  800646:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800648:	83 c4 10             	add    $0x10,%esp
  80064b:	eb 03                	jmp    800650 <vprintfmt+0x3e0>
  80064d:	83 ef 01             	sub    $0x1,%edi
  800650:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800654:	75 f7                	jne    80064d <vprintfmt+0x3dd>
  800656:	e9 46 fc ff ff       	jmp    8002a1 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  80065b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065e:	5b                   	pop    %ebx
  80065f:	5e                   	pop    %esi
  800660:	5f                   	pop    %edi
  800661:	5d                   	pop    %ebp
  800662:	c3                   	ret    

00800663 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800663:	55                   	push   %ebp
  800664:	89 e5                	mov    %esp,%ebp
  800666:	83 ec 18             	sub    $0x18,%esp
  800669:	8b 45 08             	mov    0x8(%ebp),%eax
  80066c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80066f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800672:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800676:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800679:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800680:	85 c0                	test   %eax,%eax
  800682:	74 26                	je     8006aa <vsnprintf+0x47>
  800684:	85 d2                	test   %edx,%edx
  800686:	7e 22                	jle    8006aa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800688:	ff 75 14             	pushl  0x14(%ebp)
  80068b:	ff 75 10             	pushl  0x10(%ebp)
  80068e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800691:	50                   	push   %eax
  800692:	68 36 02 80 00       	push   $0x800236
  800697:	e8 d4 fb ff ff       	call   800270 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80069c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80069f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a5:	83 c4 10             	add    $0x10,%esp
  8006a8:	eb 05                	jmp    8006af <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006af:	c9                   	leave  
  8006b0:	c3                   	ret    

008006b1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b1:	55                   	push   %ebp
  8006b2:	89 e5                	mov    %esp,%ebp
  8006b4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006b7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ba:	50                   	push   %eax
  8006bb:	ff 75 10             	pushl  0x10(%ebp)
  8006be:	ff 75 0c             	pushl  0xc(%ebp)
  8006c1:	ff 75 08             	pushl  0x8(%ebp)
  8006c4:	e8 9a ff ff ff       	call   800663 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006c9:	c9                   	leave  
  8006ca:	c3                   	ret    

008006cb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d6:	eb 03                	jmp    8006db <strlen+0x10>
		n++;
  8006d8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006db:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006df:	75 f7                	jne    8006d8 <strlen+0xd>
		n++;
	return n;
}
  8006e1:	5d                   	pop    %ebp
  8006e2:	c3                   	ret    

008006e3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f1:	eb 03                	jmp    8006f6 <strnlen+0x13>
		n++;
  8006f3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f6:	39 c2                	cmp    %eax,%edx
  8006f8:	74 08                	je     800702 <strnlen+0x1f>
  8006fa:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006fe:	75 f3                	jne    8006f3 <strnlen+0x10>
  800700:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800702:	5d                   	pop    %ebp
  800703:	c3                   	ret    

00800704 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	53                   	push   %ebx
  800708:	8b 45 08             	mov    0x8(%ebp),%eax
  80070b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80070e:	89 c2                	mov    %eax,%edx
  800710:	83 c2 01             	add    $0x1,%edx
  800713:	83 c1 01             	add    $0x1,%ecx
  800716:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80071a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80071d:	84 db                	test   %bl,%bl
  80071f:	75 ef                	jne    800710 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800721:	5b                   	pop    %ebx
  800722:	5d                   	pop    %ebp
  800723:	c3                   	ret    

00800724 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	53                   	push   %ebx
  800728:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80072b:	53                   	push   %ebx
  80072c:	e8 9a ff ff ff       	call   8006cb <strlen>
  800731:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800734:	ff 75 0c             	pushl  0xc(%ebp)
  800737:	01 d8                	add    %ebx,%eax
  800739:	50                   	push   %eax
  80073a:	e8 c5 ff ff ff       	call   800704 <strcpy>
	return dst;
}
  80073f:	89 d8                	mov    %ebx,%eax
  800741:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800744:	c9                   	leave  
  800745:	c3                   	ret    

00800746 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	56                   	push   %esi
  80074a:	53                   	push   %ebx
  80074b:	8b 75 08             	mov    0x8(%ebp),%esi
  80074e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800751:	89 f3                	mov    %esi,%ebx
  800753:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800756:	89 f2                	mov    %esi,%edx
  800758:	eb 0f                	jmp    800769 <strncpy+0x23>
		*dst++ = *src;
  80075a:	83 c2 01             	add    $0x1,%edx
  80075d:	0f b6 01             	movzbl (%ecx),%eax
  800760:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800763:	80 39 01             	cmpb   $0x1,(%ecx)
  800766:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800769:	39 da                	cmp    %ebx,%edx
  80076b:	75 ed                	jne    80075a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80076d:	89 f0                	mov    %esi,%eax
  80076f:	5b                   	pop    %ebx
  800770:	5e                   	pop    %esi
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	56                   	push   %esi
  800777:	53                   	push   %ebx
  800778:	8b 75 08             	mov    0x8(%ebp),%esi
  80077b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077e:	8b 55 10             	mov    0x10(%ebp),%edx
  800781:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800783:	85 d2                	test   %edx,%edx
  800785:	74 21                	je     8007a8 <strlcpy+0x35>
  800787:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80078b:	89 f2                	mov    %esi,%edx
  80078d:	eb 09                	jmp    800798 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80078f:	83 c2 01             	add    $0x1,%edx
  800792:	83 c1 01             	add    $0x1,%ecx
  800795:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800798:	39 c2                	cmp    %eax,%edx
  80079a:	74 09                	je     8007a5 <strlcpy+0x32>
  80079c:	0f b6 19             	movzbl (%ecx),%ebx
  80079f:	84 db                	test   %bl,%bl
  8007a1:	75 ec                	jne    80078f <strlcpy+0x1c>
  8007a3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007a5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007a8:	29 f0                	sub    %esi,%eax
}
  8007aa:	5b                   	pop    %ebx
  8007ab:	5e                   	pop    %esi
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007b7:	eb 06                	jmp    8007bf <strcmp+0x11>
		p++, q++;
  8007b9:	83 c1 01             	add    $0x1,%ecx
  8007bc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007bf:	0f b6 01             	movzbl (%ecx),%eax
  8007c2:	84 c0                	test   %al,%al
  8007c4:	74 04                	je     8007ca <strcmp+0x1c>
  8007c6:	3a 02                	cmp    (%edx),%al
  8007c8:	74 ef                	je     8007b9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ca:	0f b6 c0             	movzbl %al,%eax
  8007cd:	0f b6 12             	movzbl (%edx),%edx
  8007d0:	29 d0                	sub    %edx,%eax
}
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	53                   	push   %ebx
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007de:	89 c3                	mov    %eax,%ebx
  8007e0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007e3:	eb 06                	jmp    8007eb <strncmp+0x17>
		n--, p++, q++;
  8007e5:	83 c0 01             	add    $0x1,%eax
  8007e8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007eb:	39 d8                	cmp    %ebx,%eax
  8007ed:	74 15                	je     800804 <strncmp+0x30>
  8007ef:	0f b6 08             	movzbl (%eax),%ecx
  8007f2:	84 c9                	test   %cl,%cl
  8007f4:	74 04                	je     8007fa <strncmp+0x26>
  8007f6:	3a 0a                	cmp    (%edx),%cl
  8007f8:	74 eb                	je     8007e5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fa:	0f b6 00             	movzbl (%eax),%eax
  8007fd:	0f b6 12             	movzbl (%edx),%edx
  800800:	29 d0                	sub    %edx,%eax
  800802:	eb 05                	jmp    800809 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800804:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800809:	5b                   	pop    %ebx
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	8b 45 08             	mov    0x8(%ebp),%eax
  800812:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800816:	eb 07                	jmp    80081f <strchr+0x13>
		if (*s == c)
  800818:	38 ca                	cmp    %cl,%dl
  80081a:	74 0f                	je     80082b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80081c:	83 c0 01             	add    $0x1,%eax
  80081f:	0f b6 10             	movzbl (%eax),%edx
  800822:	84 d2                	test   %dl,%dl
  800824:	75 f2                	jne    800818 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800837:	eb 03                	jmp    80083c <strfind+0xf>
  800839:	83 c0 01             	add    $0x1,%eax
  80083c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80083f:	38 ca                	cmp    %cl,%dl
  800841:	74 04                	je     800847 <strfind+0x1a>
  800843:	84 d2                	test   %dl,%dl
  800845:	75 f2                	jne    800839 <strfind+0xc>
			break;
	return (char *) s;
}
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	57                   	push   %edi
  80084d:	56                   	push   %esi
  80084e:	53                   	push   %ebx
  80084f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800852:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800855:	85 c9                	test   %ecx,%ecx
  800857:	74 36                	je     80088f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800859:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80085f:	75 28                	jne    800889 <memset+0x40>
  800861:	f6 c1 03             	test   $0x3,%cl
  800864:	75 23                	jne    800889 <memset+0x40>
		c &= 0xFF;
  800866:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80086a:	89 d3                	mov    %edx,%ebx
  80086c:	c1 e3 08             	shl    $0x8,%ebx
  80086f:	89 d6                	mov    %edx,%esi
  800871:	c1 e6 18             	shl    $0x18,%esi
  800874:	89 d0                	mov    %edx,%eax
  800876:	c1 e0 10             	shl    $0x10,%eax
  800879:	09 f0                	or     %esi,%eax
  80087b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80087d:	89 d8                	mov    %ebx,%eax
  80087f:	09 d0                	or     %edx,%eax
  800881:	c1 e9 02             	shr    $0x2,%ecx
  800884:	fc                   	cld    
  800885:	f3 ab                	rep stos %eax,%es:(%edi)
  800887:	eb 06                	jmp    80088f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800889:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088c:	fc                   	cld    
  80088d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80088f:	89 f8                	mov    %edi,%eax
  800891:	5b                   	pop    %ebx
  800892:	5e                   	pop    %esi
  800893:	5f                   	pop    %edi
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	57                   	push   %edi
  80089a:	56                   	push   %esi
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008a4:	39 c6                	cmp    %eax,%esi
  8008a6:	73 35                	jae    8008dd <memmove+0x47>
  8008a8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ab:	39 d0                	cmp    %edx,%eax
  8008ad:	73 2e                	jae    8008dd <memmove+0x47>
		s += n;
		d += n;
  8008af:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b2:	89 d6                	mov    %edx,%esi
  8008b4:	09 fe                	or     %edi,%esi
  8008b6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008bc:	75 13                	jne    8008d1 <memmove+0x3b>
  8008be:	f6 c1 03             	test   $0x3,%cl
  8008c1:	75 0e                	jne    8008d1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008c3:	83 ef 04             	sub    $0x4,%edi
  8008c6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c9:	c1 e9 02             	shr    $0x2,%ecx
  8008cc:	fd                   	std    
  8008cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008cf:	eb 09                	jmp    8008da <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008d1:	83 ef 01             	sub    $0x1,%edi
  8008d4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008d7:	fd                   	std    
  8008d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008da:	fc                   	cld    
  8008db:	eb 1d                	jmp    8008fa <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008dd:	89 f2                	mov    %esi,%edx
  8008df:	09 c2                	or     %eax,%edx
  8008e1:	f6 c2 03             	test   $0x3,%dl
  8008e4:	75 0f                	jne    8008f5 <memmove+0x5f>
  8008e6:	f6 c1 03             	test   $0x3,%cl
  8008e9:	75 0a                	jne    8008f5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008eb:	c1 e9 02             	shr    $0x2,%ecx
  8008ee:	89 c7                	mov    %eax,%edi
  8008f0:	fc                   	cld    
  8008f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f3:	eb 05                	jmp    8008fa <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f5:	89 c7                	mov    %eax,%edi
  8008f7:	fc                   	cld    
  8008f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008fa:	5e                   	pop    %esi
  8008fb:	5f                   	pop    %edi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800901:	ff 75 10             	pushl  0x10(%ebp)
  800904:	ff 75 0c             	pushl  0xc(%ebp)
  800907:	ff 75 08             	pushl  0x8(%ebp)
  80090a:	e8 87 ff ff ff       	call   800896 <memmove>
}
  80090f:	c9                   	leave  
  800910:	c3                   	ret    

00800911 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	56                   	push   %esi
  800915:	53                   	push   %ebx
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091c:	89 c6                	mov    %eax,%esi
  80091e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800921:	eb 1a                	jmp    80093d <memcmp+0x2c>
		if (*s1 != *s2)
  800923:	0f b6 08             	movzbl (%eax),%ecx
  800926:	0f b6 1a             	movzbl (%edx),%ebx
  800929:	38 d9                	cmp    %bl,%cl
  80092b:	74 0a                	je     800937 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80092d:	0f b6 c1             	movzbl %cl,%eax
  800930:	0f b6 db             	movzbl %bl,%ebx
  800933:	29 d8                	sub    %ebx,%eax
  800935:	eb 0f                	jmp    800946 <memcmp+0x35>
		s1++, s2++;
  800937:	83 c0 01             	add    $0x1,%eax
  80093a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093d:	39 f0                	cmp    %esi,%eax
  80093f:	75 e2                	jne    800923 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800941:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800946:	5b                   	pop    %ebx
  800947:	5e                   	pop    %esi
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800951:	89 c1                	mov    %eax,%ecx
  800953:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800956:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80095a:	eb 0a                	jmp    800966 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80095c:	0f b6 10             	movzbl (%eax),%edx
  80095f:	39 da                	cmp    %ebx,%edx
  800961:	74 07                	je     80096a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800963:	83 c0 01             	add    $0x1,%eax
  800966:	39 c8                	cmp    %ecx,%eax
  800968:	72 f2                	jb     80095c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80096a:	5b                   	pop    %ebx
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	57                   	push   %edi
  800971:	56                   	push   %esi
  800972:	53                   	push   %ebx
  800973:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800976:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800979:	eb 03                	jmp    80097e <strtol+0x11>
		s++;
  80097b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097e:	0f b6 01             	movzbl (%ecx),%eax
  800981:	3c 20                	cmp    $0x20,%al
  800983:	74 f6                	je     80097b <strtol+0xe>
  800985:	3c 09                	cmp    $0x9,%al
  800987:	74 f2                	je     80097b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800989:	3c 2b                	cmp    $0x2b,%al
  80098b:	75 0a                	jne    800997 <strtol+0x2a>
		s++;
  80098d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800990:	bf 00 00 00 00       	mov    $0x0,%edi
  800995:	eb 11                	jmp    8009a8 <strtol+0x3b>
  800997:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80099c:	3c 2d                	cmp    $0x2d,%al
  80099e:	75 08                	jne    8009a8 <strtol+0x3b>
		s++, neg = 1;
  8009a0:	83 c1 01             	add    $0x1,%ecx
  8009a3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ae:	75 15                	jne    8009c5 <strtol+0x58>
  8009b0:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b3:	75 10                	jne    8009c5 <strtol+0x58>
  8009b5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009b9:	75 7c                	jne    800a37 <strtol+0xca>
		s += 2, base = 16;
  8009bb:	83 c1 02             	add    $0x2,%ecx
  8009be:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c3:	eb 16                	jmp    8009db <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009c5:	85 db                	test   %ebx,%ebx
  8009c7:	75 12                	jne    8009db <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009c9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ce:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d1:	75 08                	jne    8009db <strtol+0x6e>
		s++, base = 8;
  8009d3:	83 c1 01             	add    $0x1,%ecx
  8009d6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e3:	0f b6 11             	movzbl (%ecx),%edx
  8009e6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009e9:	89 f3                	mov    %esi,%ebx
  8009eb:	80 fb 09             	cmp    $0x9,%bl
  8009ee:	77 08                	ja     8009f8 <strtol+0x8b>
			dig = *s - '0';
  8009f0:	0f be d2             	movsbl %dl,%edx
  8009f3:	83 ea 30             	sub    $0x30,%edx
  8009f6:	eb 22                	jmp    800a1a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009f8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009fb:	89 f3                	mov    %esi,%ebx
  8009fd:	80 fb 19             	cmp    $0x19,%bl
  800a00:	77 08                	ja     800a0a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a02:	0f be d2             	movsbl %dl,%edx
  800a05:	83 ea 57             	sub    $0x57,%edx
  800a08:	eb 10                	jmp    800a1a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a0a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a0d:	89 f3                	mov    %esi,%ebx
  800a0f:	80 fb 19             	cmp    $0x19,%bl
  800a12:	77 16                	ja     800a2a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a14:	0f be d2             	movsbl %dl,%edx
  800a17:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a1a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a1d:	7d 0b                	jge    800a2a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a1f:	83 c1 01             	add    $0x1,%ecx
  800a22:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a26:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a28:	eb b9                	jmp    8009e3 <strtol+0x76>

	if (endptr)
  800a2a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a2e:	74 0d                	je     800a3d <strtol+0xd0>
		*endptr = (char *) s;
  800a30:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a33:	89 0e                	mov    %ecx,(%esi)
  800a35:	eb 06                	jmp    800a3d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a37:	85 db                	test   %ebx,%ebx
  800a39:	74 98                	je     8009d3 <strtol+0x66>
  800a3b:	eb 9e                	jmp    8009db <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a3d:	89 c2                	mov    %eax,%edx
  800a3f:	f7 da                	neg    %edx
  800a41:	85 ff                	test   %edi,%edi
  800a43:	0f 45 c2             	cmovne %edx,%eax
}
  800a46:	5b                   	pop    %ebx
  800a47:	5e                   	pop    %esi
  800a48:	5f                   	pop    %edi
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	57                   	push   %edi
  800a4f:	56                   	push   %esi
  800a50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a51:	b8 00 00 00 00       	mov    $0x0,%eax
  800a56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a59:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5c:	89 c3                	mov    %eax,%ebx
  800a5e:	89 c7                	mov    %eax,%edi
  800a60:	89 c6                	mov    %eax,%esi
  800a62:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a64:	5b                   	pop    %ebx
  800a65:	5e                   	pop    %esi
  800a66:	5f                   	pop    %edi
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	57                   	push   %edi
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a74:	b8 01 00 00 00       	mov    $0x1,%eax
  800a79:	89 d1                	mov    %edx,%ecx
  800a7b:	89 d3                	mov    %edx,%ebx
  800a7d:	89 d7                	mov    %edx,%edi
  800a7f:	89 d6                	mov    %edx,%esi
  800a81:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a83:	5b                   	pop    %ebx
  800a84:	5e                   	pop    %esi
  800a85:	5f                   	pop    %edi
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	57                   	push   %edi
  800a8c:	56                   	push   %esi
  800a8d:	53                   	push   %ebx
  800a8e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a91:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a96:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9e:	89 cb                	mov    %ecx,%ebx
  800aa0:	89 cf                	mov    %ecx,%edi
  800aa2:	89 ce                	mov    %ecx,%esi
  800aa4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aa6:	85 c0                	test   %eax,%eax
  800aa8:	7e 17                	jle    800ac1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aaa:	83 ec 0c             	sub    $0xc,%esp
  800aad:	50                   	push   %eax
  800aae:	6a 03                	push   $0x3
  800ab0:	68 44 12 80 00       	push   $0x801244
  800ab5:	6a 23                	push   $0x23
  800ab7:	68 61 12 80 00       	push   $0x801261
  800abc:	e8 15 02 00 00       	call   800cd6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	57                   	push   %edi
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad4:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad9:	89 d1                	mov    %edx,%ecx
  800adb:	89 d3                	mov    %edx,%ebx
  800add:	89 d7                	mov    %edx,%edi
  800adf:	89 d6                	mov    %edx,%esi
  800ae1:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5f                   	pop    %edi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <sys_yield>:

void
sys_yield(void)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aee:	ba 00 00 00 00       	mov    $0x0,%edx
  800af3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800af8:	89 d1                	mov    %edx,%ecx
  800afa:	89 d3                	mov    %edx,%ebx
  800afc:	89 d7                	mov    %edx,%edi
  800afe:	89 d6                	mov    %edx,%esi
  800b00:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
  800b0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b10:	be 00 00 00 00       	mov    $0x0,%esi
  800b15:	b8 04 00 00 00       	mov    $0x4,%eax
  800b1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b23:	89 f7                	mov    %esi,%edi
  800b25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b27:	85 c0                	test   %eax,%eax
  800b29:	7e 17                	jle    800b42 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2b:	83 ec 0c             	sub    $0xc,%esp
  800b2e:	50                   	push   %eax
  800b2f:	6a 04                	push   $0x4
  800b31:	68 44 12 80 00       	push   $0x801244
  800b36:	6a 23                	push   $0x23
  800b38:	68 61 12 80 00       	push   $0x801261
  800b3d:	e8 94 01 00 00       	call   800cd6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800b53:	b8 05 00 00 00       	mov    $0x5,%eax
  800b58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b61:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b64:	8b 75 18             	mov    0x18(%ebp),%esi
  800b67:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b69:	85 c0                	test   %eax,%eax
  800b6b:	7e 17                	jle    800b84 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6d:	83 ec 0c             	sub    $0xc,%esp
  800b70:	50                   	push   %eax
  800b71:	6a 05                	push   $0x5
  800b73:	68 44 12 80 00       	push   $0x801244
  800b78:	6a 23                	push   $0x23
  800b7a:	68 61 12 80 00       	push   $0x801261
  800b7f:	e8 52 01 00 00       	call   800cd6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b87:	5b                   	pop    %ebx
  800b88:	5e                   	pop    %esi
  800b89:	5f                   	pop    %edi
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	57                   	push   %edi
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
  800b92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b9a:	b8 06 00 00 00       	mov    $0x6,%eax
  800b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba5:	89 df                	mov    %ebx,%edi
  800ba7:	89 de                	mov    %ebx,%esi
  800ba9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bab:	85 c0                	test   %eax,%eax
  800bad:	7e 17                	jle    800bc6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	50                   	push   %eax
  800bb3:	6a 06                	push   $0x6
  800bb5:	68 44 12 80 00       	push   $0x801244
  800bba:	6a 23                	push   $0x23
  800bbc:	68 61 12 80 00       	push   $0x801261
  800bc1:	e8 10 01 00 00       	call   800cd6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bdc:	b8 08 00 00 00       	mov    $0x8,%eax
  800be1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	89 df                	mov    %ebx,%edi
  800be9:	89 de                	mov    %ebx,%esi
  800beb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bed:	85 c0                	test   %eax,%eax
  800bef:	7e 17                	jle    800c08 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	50                   	push   %eax
  800bf5:	6a 08                	push   $0x8
  800bf7:	68 44 12 80 00       	push   $0x801244
  800bfc:	6a 23                	push   $0x23
  800bfe:	68 61 12 80 00       	push   $0x801261
  800c03:	e8 ce 00 00 00       	call   800cd6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1e:	b8 09 00 00 00       	mov    $0x9,%eax
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	89 df                	mov    %ebx,%edi
  800c2b:	89 de                	mov    %ebx,%esi
  800c2d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2f:	85 c0                	test   %eax,%eax
  800c31:	7e 17                	jle    800c4a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	50                   	push   %eax
  800c37:	6a 09                	push   $0x9
  800c39:	68 44 12 80 00       	push   $0x801244
  800c3e:	6a 23                	push   $0x23
  800c40:	68 61 12 80 00       	push   $0x801261
  800c45:	e8 8c 00 00 00       	call   800cd6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c58:	be 00 00 00 00       	mov    $0x0,%esi
  800c5d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c6e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c83:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	89 cb                	mov    %ecx,%ebx
  800c8d:	89 cf                	mov    %ecx,%edi
  800c8f:	89 ce                	mov    %ecx,%esi
  800c91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7e 17                	jle    800cae <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c97:	83 ec 0c             	sub    $0xc,%esp
  800c9a:	50                   	push   %eax
  800c9b:	6a 0c                	push   $0xc
  800c9d:	68 44 12 80 00       	push   $0x801244
  800ca2:	6a 23                	push   $0x23
  800ca4:	68 61 12 80 00       	push   $0x801261
  800ca9:	e8 28 00 00 00       	call   800cd6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_change_pr>:

int
sys_change_pr(int pr)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc9:	89 cb                	mov    %ecx,%ebx
  800ccb:	89 cf                	mov    %ecx,%edi
  800ccd:	89 ce                	mov    %ecx,%esi
  800ccf:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800cdb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cde:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ce4:	e8 e0 fd ff ff       	call   800ac9 <sys_getenvid>
  800ce9:	83 ec 0c             	sub    $0xc,%esp
  800cec:	ff 75 0c             	pushl  0xc(%ebp)
  800cef:	ff 75 08             	pushl  0x8(%ebp)
  800cf2:	56                   	push   %esi
  800cf3:	50                   	push   %eax
  800cf4:	68 70 12 80 00       	push   $0x801270
  800cf9:	e8 3b f4 ff ff       	call   800139 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cfe:	83 c4 18             	add    $0x18,%esp
  800d01:	53                   	push   %ebx
  800d02:	ff 75 10             	pushl  0x10(%ebp)
  800d05:	e8 de f3 ff ff       	call   8000e8 <vcprintf>
	cprintf("\n");
  800d0a:	c7 04 24 94 12 80 00 	movl   $0x801294,(%esp)
  800d11:	e8 23 f4 ff ff       	call   800139 <cprintf>
  800d16:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d19:	cc                   	int3   
  800d1a:	eb fd                	jmp    800d19 <_panic+0x43>
  800d1c:	66 90                	xchg   %ax,%ax
  800d1e:	66 90                	xchg   %ax,%ax

00800d20 <__udivdi3>:
  800d20:	55                   	push   %ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 1c             	sub    $0x1c,%esp
  800d27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d37:	85 f6                	test   %esi,%esi
  800d39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d3d:	89 ca                	mov    %ecx,%edx
  800d3f:	89 f8                	mov    %edi,%eax
  800d41:	75 3d                	jne    800d80 <__udivdi3+0x60>
  800d43:	39 cf                	cmp    %ecx,%edi
  800d45:	0f 87 c5 00 00 00    	ja     800e10 <__udivdi3+0xf0>
  800d4b:	85 ff                	test   %edi,%edi
  800d4d:	89 fd                	mov    %edi,%ebp
  800d4f:	75 0b                	jne    800d5c <__udivdi3+0x3c>
  800d51:	b8 01 00 00 00       	mov    $0x1,%eax
  800d56:	31 d2                	xor    %edx,%edx
  800d58:	f7 f7                	div    %edi
  800d5a:	89 c5                	mov    %eax,%ebp
  800d5c:	89 c8                	mov    %ecx,%eax
  800d5e:	31 d2                	xor    %edx,%edx
  800d60:	f7 f5                	div    %ebp
  800d62:	89 c1                	mov    %eax,%ecx
  800d64:	89 d8                	mov    %ebx,%eax
  800d66:	89 cf                	mov    %ecx,%edi
  800d68:	f7 f5                	div    %ebp
  800d6a:	89 c3                	mov    %eax,%ebx
  800d6c:	89 d8                	mov    %ebx,%eax
  800d6e:	89 fa                	mov    %edi,%edx
  800d70:	83 c4 1c             	add    $0x1c,%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    
  800d78:	90                   	nop
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	39 ce                	cmp    %ecx,%esi
  800d82:	77 74                	ja     800df8 <__udivdi3+0xd8>
  800d84:	0f bd fe             	bsr    %esi,%edi
  800d87:	83 f7 1f             	xor    $0x1f,%edi
  800d8a:	0f 84 98 00 00 00    	je     800e28 <__udivdi3+0x108>
  800d90:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d95:	89 f9                	mov    %edi,%ecx
  800d97:	89 c5                	mov    %eax,%ebp
  800d99:	29 fb                	sub    %edi,%ebx
  800d9b:	d3 e6                	shl    %cl,%esi
  800d9d:	89 d9                	mov    %ebx,%ecx
  800d9f:	d3 ed                	shr    %cl,%ebp
  800da1:	89 f9                	mov    %edi,%ecx
  800da3:	d3 e0                	shl    %cl,%eax
  800da5:	09 ee                	or     %ebp,%esi
  800da7:	89 d9                	mov    %ebx,%ecx
  800da9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dad:	89 d5                	mov    %edx,%ebp
  800daf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800db3:	d3 ed                	shr    %cl,%ebp
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	d3 e2                	shl    %cl,%edx
  800db9:	89 d9                	mov    %ebx,%ecx
  800dbb:	d3 e8                	shr    %cl,%eax
  800dbd:	09 c2                	or     %eax,%edx
  800dbf:	89 d0                	mov    %edx,%eax
  800dc1:	89 ea                	mov    %ebp,%edx
  800dc3:	f7 f6                	div    %esi
  800dc5:	89 d5                	mov    %edx,%ebp
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	f7 64 24 0c          	mull   0xc(%esp)
  800dcd:	39 d5                	cmp    %edx,%ebp
  800dcf:	72 10                	jb     800de1 <__udivdi3+0xc1>
  800dd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	d3 e6                	shl    %cl,%esi
  800dd9:	39 c6                	cmp    %eax,%esi
  800ddb:	73 07                	jae    800de4 <__udivdi3+0xc4>
  800ddd:	39 d5                	cmp    %edx,%ebp
  800ddf:	75 03                	jne    800de4 <__udivdi3+0xc4>
  800de1:	83 eb 01             	sub    $0x1,%ebx
  800de4:	31 ff                	xor    %edi,%edi
  800de6:	89 d8                	mov    %ebx,%eax
  800de8:	89 fa                	mov    %edi,%edx
  800dea:	83 c4 1c             	add    $0x1c,%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    
  800df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df8:	31 ff                	xor    %edi,%edi
  800dfa:	31 db                	xor    %ebx,%ebx
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
  800e10:	89 d8                	mov    %ebx,%eax
  800e12:	f7 f7                	div    %edi
  800e14:	31 ff                	xor    %edi,%edi
  800e16:	89 c3                	mov    %eax,%ebx
  800e18:	89 d8                	mov    %ebx,%eax
  800e1a:	89 fa                	mov    %edi,%edx
  800e1c:	83 c4 1c             	add    $0x1c,%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	39 ce                	cmp    %ecx,%esi
  800e2a:	72 0c                	jb     800e38 <__udivdi3+0x118>
  800e2c:	31 db                	xor    %ebx,%ebx
  800e2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e32:	0f 87 34 ff ff ff    	ja     800d6c <__udivdi3+0x4c>
  800e38:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e3d:	e9 2a ff ff ff       	jmp    800d6c <__udivdi3+0x4c>
  800e42:	66 90                	xchg   %ax,%ax
  800e44:	66 90                	xchg   %ax,%ax
  800e46:	66 90                	xchg   %ax,%ax
  800e48:	66 90                	xchg   %ax,%ax
  800e4a:	66 90                	xchg   %ax,%ax
  800e4c:	66 90                	xchg   %ax,%ax
  800e4e:	66 90                	xchg   %ax,%ax

00800e50 <__umoddi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e67:	85 d2                	test   %edx,%edx
  800e69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e71:	89 f3                	mov    %esi,%ebx
  800e73:	89 3c 24             	mov    %edi,(%esp)
  800e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e7a:	75 1c                	jne    800e98 <__umoddi3+0x48>
  800e7c:	39 f7                	cmp    %esi,%edi
  800e7e:	76 50                	jbe    800ed0 <__umoddi3+0x80>
  800e80:	89 c8                	mov    %ecx,%eax
  800e82:	89 f2                	mov    %esi,%edx
  800e84:	f7 f7                	div    %edi
  800e86:	89 d0                	mov    %edx,%eax
  800e88:	31 d2                	xor    %edx,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	39 f2                	cmp    %esi,%edx
  800e9a:	89 d0                	mov    %edx,%eax
  800e9c:	77 52                	ja     800ef0 <__umoddi3+0xa0>
  800e9e:	0f bd ea             	bsr    %edx,%ebp
  800ea1:	83 f5 1f             	xor    $0x1f,%ebp
  800ea4:	75 5a                	jne    800f00 <__umoddi3+0xb0>
  800ea6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eaa:	0f 82 e0 00 00 00    	jb     800f90 <__umoddi3+0x140>
  800eb0:	39 0c 24             	cmp    %ecx,(%esp)
  800eb3:	0f 86 d7 00 00 00    	jbe    800f90 <__umoddi3+0x140>
  800eb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ebd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ec1:	83 c4 1c             	add    $0x1c,%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	85 ff                	test   %edi,%edi
  800ed2:	89 fd                	mov    %edi,%ebp
  800ed4:	75 0b                	jne    800ee1 <__umoddi3+0x91>
  800ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	f7 f7                	div    %edi
  800edf:	89 c5                	mov    %eax,%ebp
  800ee1:	89 f0                	mov    %esi,%eax
  800ee3:	31 d2                	xor    %edx,%edx
  800ee5:	f7 f5                	div    %ebp
  800ee7:	89 c8                	mov    %ecx,%eax
  800ee9:	f7 f5                	div    %ebp
  800eeb:	89 d0                	mov    %edx,%eax
  800eed:	eb 99                	jmp    800e88 <__umoddi3+0x38>
  800eef:	90                   	nop
  800ef0:	89 c8                	mov    %ecx,%eax
  800ef2:	89 f2                	mov    %esi,%edx
  800ef4:	83 c4 1c             	add    $0x1c,%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    
  800efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f00:	8b 34 24             	mov    (%esp),%esi
  800f03:	bf 20 00 00 00       	mov    $0x20,%edi
  800f08:	89 e9                	mov    %ebp,%ecx
  800f0a:	29 ef                	sub    %ebp,%edi
  800f0c:	d3 e0                	shl    %cl,%eax
  800f0e:	89 f9                	mov    %edi,%ecx
  800f10:	89 f2                	mov    %esi,%edx
  800f12:	d3 ea                	shr    %cl,%edx
  800f14:	89 e9                	mov    %ebp,%ecx
  800f16:	09 c2                	or     %eax,%edx
  800f18:	89 d8                	mov    %ebx,%eax
  800f1a:	89 14 24             	mov    %edx,(%esp)
  800f1d:	89 f2                	mov    %esi,%edx
  800f1f:	d3 e2                	shl    %cl,%edx
  800f21:	89 f9                	mov    %edi,%ecx
  800f23:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f2b:	d3 e8                	shr    %cl,%eax
  800f2d:	89 e9                	mov    %ebp,%ecx
  800f2f:	89 c6                	mov    %eax,%esi
  800f31:	d3 e3                	shl    %cl,%ebx
  800f33:	89 f9                	mov    %edi,%ecx
  800f35:	89 d0                	mov    %edx,%eax
  800f37:	d3 e8                	shr    %cl,%eax
  800f39:	89 e9                	mov    %ebp,%ecx
  800f3b:	09 d8                	or     %ebx,%eax
  800f3d:	89 d3                	mov    %edx,%ebx
  800f3f:	89 f2                	mov    %esi,%edx
  800f41:	f7 34 24             	divl   (%esp)
  800f44:	89 d6                	mov    %edx,%esi
  800f46:	d3 e3                	shl    %cl,%ebx
  800f48:	f7 64 24 04          	mull   0x4(%esp)
  800f4c:	39 d6                	cmp    %edx,%esi
  800f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f52:	89 d1                	mov    %edx,%ecx
  800f54:	89 c3                	mov    %eax,%ebx
  800f56:	72 08                	jb     800f60 <__umoddi3+0x110>
  800f58:	75 11                	jne    800f6b <__umoddi3+0x11b>
  800f5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f5e:	73 0b                	jae    800f6b <__umoddi3+0x11b>
  800f60:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f64:	1b 14 24             	sbb    (%esp),%edx
  800f67:	89 d1                	mov    %edx,%ecx
  800f69:	89 c3                	mov    %eax,%ebx
  800f6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f6f:	29 da                	sub    %ebx,%edx
  800f71:	19 ce                	sbb    %ecx,%esi
  800f73:	89 f9                	mov    %edi,%ecx
  800f75:	89 f0                	mov    %esi,%eax
  800f77:	d3 e0                	shl    %cl,%eax
  800f79:	89 e9                	mov    %ebp,%ecx
  800f7b:	d3 ea                	shr    %cl,%edx
  800f7d:	89 e9                	mov    %ebp,%ecx
  800f7f:	d3 ee                	shr    %cl,%esi
  800f81:	09 d0                	or     %edx,%eax
  800f83:	89 f2                	mov    %esi,%edx
  800f85:	83 c4 1c             	add    $0x1c,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi
  800f90:	29 f9                	sub    %edi,%ecx
  800f92:	19 d6                	sbb    %edx,%esi
  800f94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f9c:	e9 18 ff ff ff       	jmp    800eb9 <__umoddi3+0x69>
