
obj/user/divzero：     文件格式 elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 c0 0f 80 00       	push   $0x800fc0
  800056:	e8 f0 00 00 00       	call   80014b <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  80006b:	e8 6b 0a 00 00       	call   800adb <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	c1 e0 07             	shl    $0x7,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 20 80 00       	mov    %eax,0x802008
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ac:	6a 00                	push   $0x0
  8000ae:	e8 e7 09 00 00       	call   800a9a <sys_env_destroy>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 04             	sub    $0x4,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 13                	mov    (%ebx),%edx
  8000c4:	8d 42 01             	lea    0x1(%edx),%eax
  8000c7:	89 03                	mov    %eax,(%ebx)
  8000c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d5:	75 1a                	jne    8000f1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d7:	83 ec 08             	sub    $0x8,%esp
  8000da:	68 ff 00 00 00       	push   $0xff
  8000df:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e2:	50                   	push   %eax
  8000e3:	e8 75 09 00 00       	call   800a5d <sys_cputs>
		b->idx = 0;
  8000e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ee:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800103:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010a:	00 00 00 
	b.cnt = 0;
  80010d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800114:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800117:	ff 75 0c             	pushl  0xc(%ebp)
  80011a:	ff 75 08             	pushl  0x8(%ebp)
  80011d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800123:	50                   	push   %eax
  800124:	68 b8 00 80 00       	push   $0x8000b8
  800129:	e8 54 01 00 00       	call   800282 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012e:	83 c4 08             	add    $0x8,%esp
  800131:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800137:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	e8 1a 09 00 00       	call   800a5d <sys_cputs>

	return b.cnt;
}
  800143:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800151:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800154:	50                   	push   %eax
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	e8 9d ff ff ff       	call   8000fa <vcprintf>
	va_end(ap);

	return cnt;
}
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 1c             	sub    $0x1c,%esp
  800168:	89 c7                	mov    %eax,%edi
  80016a:	89 d6                	mov    %edx,%esi
  80016c:	8b 45 08             	mov    0x8(%ebp),%eax
  80016f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800172:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800175:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800178:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80017b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800180:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800183:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800186:	39 d3                	cmp    %edx,%ebx
  800188:	72 05                	jb     80018f <printnum+0x30>
  80018a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80018d:	77 45                	ja     8001d4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	ff 75 18             	pushl  0x18(%ebp)
  800195:	8b 45 14             	mov    0x14(%ebp),%eax
  800198:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80019b:	53                   	push   %ebx
  80019c:	ff 75 10             	pushl  0x10(%ebp)
  80019f:	83 ec 08             	sub    $0x8,%esp
  8001a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ae:	e8 7d 0b 00 00       	call   800d30 <__udivdi3>
  8001b3:	83 c4 18             	add    $0x18,%esp
  8001b6:	52                   	push   %edx
  8001b7:	50                   	push   %eax
  8001b8:	89 f2                	mov    %esi,%edx
  8001ba:	89 f8                	mov    %edi,%eax
  8001bc:	e8 9e ff ff ff       	call   80015f <printnum>
  8001c1:	83 c4 20             	add    $0x20,%esp
  8001c4:	eb 18                	jmp    8001de <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	ff 75 18             	pushl  0x18(%ebp)
  8001cd:	ff d7                	call   *%edi
  8001cf:	83 c4 10             	add    $0x10,%esp
  8001d2:	eb 03                	jmp    8001d7 <printnum+0x78>
  8001d4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d7:	83 eb 01             	sub    $0x1,%ebx
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7f e8                	jg     8001c6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001de:	83 ec 08             	sub    $0x8,%esp
  8001e1:	56                   	push   %esi
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001eb:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f1:	e8 6a 0c 00 00       	call   800e60 <__umoddi3>
  8001f6:	83 c4 14             	add    $0x14,%esp
  8001f9:	0f be 80 d8 0f 80 00 	movsbl 0x800fd8(%eax),%eax
  800200:	50                   	push   %eax
  800201:	ff d7                	call   *%edi
}
  800203:	83 c4 10             	add    $0x10,%esp
  800206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5f                   	pop    %edi
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    

0080020e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800211:	83 fa 01             	cmp    $0x1,%edx
  800214:	7e 0e                	jle    800224 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800216:	8b 10                	mov    (%eax),%edx
  800218:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021b:	89 08                	mov    %ecx,(%eax)
  80021d:	8b 02                	mov    (%edx),%eax
  80021f:	8b 52 04             	mov    0x4(%edx),%edx
  800222:	eb 22                	jmp    800246 <getuint+0x38>
	else if (lflag)
  800224:	85 d2                	test   %edx,%edx
  800226:	74 10                	je     800238 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800228:	8b 10                	mov    (%eax),%edx
  80022a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022d:	89 08                	mov    %ecx,(%eax)
  80022f:	8b 02                	mov    (%edx),%eax
  800231:	ba 00 00 00 00       	mov    $0x0,%edx
  800236:	eb 0e                	jmp    800246 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800238:	8b 10                	mov    (%eax),%edx
  80023a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023d:	89 08                	mov    %ecx,(%eax)
  80023f:	8b 02                	mov    (%edx),%eax
  800241:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80024e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800252:	8b 10                	mov    (%eax),%edx
  800254:	3b 50 04             	cmp    0x4(%eax),%edx
  800257:	73 0a                	jae    800263 <sprintputch+0x1b>
		*b->buf++ = ch;
  800259:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025c:	89 08                	mov    %ecx,(%eax)
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	88 02                	mov    %al,(%edx)
}
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    

00800265 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80026b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80026e:	50                   	push   %eax
  80026f:	ff 75 10             	pushl  0x10(%ebp)
  800272:	ff 75 0c             	pushl  0xc(%ebp)
  800275:	ff 75 08             	pushl  0x8(%ebp)
  800278:	e8 05 00 00 00       	call   800282 <vprintfmt>
	va_end(ap);
}
  80027d:	83 c4 10             	add    $0x10,%esp
  800280:	c9                   	leave  
  800281:	c3                   	ret    

00800282 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 2c             	sub    $0x2c,%esp
  80028b:	8b 75 08             	mov    0x8(%ebp),%esi
  80028e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800291:	8b 7d 10             	mov    0x10(%ebp),%edi
  800294:	eb 1d                	jmp    8002b3 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800296:	85 c0                	test   %eax,%eax
  800298:	75 0f                	jne    8002a9 <vprintfmt+0x27>
				csa = 0x0700;
  80029a:	c7 05 0c 20 80 00 00 	movl   $0x700,0x80200c
  8002a1:	07 00 00 
				return;
  8002a4:	e9 c4 03 00 00       	jmp    80066d <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	53                   	push   %ebx
  8002ad:	50                   	push   %eax
  8002ae:	ff d6                	call   *%esi
  8002b0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b3:	83 c7 01             	add    $0x1,%edi
  8002b6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ba:	83 f8 25             	cmp    $0x25,%eax
  8002bd:	75 d7                	jne    800296 <vprintfmt+0x14>
  8002bf:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ca:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002d1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dd:	eb 07                	jmp    8002e6 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002df:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e6:	8d 47 01             	lea    0x1(%edi),%eax
  8002e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ec:	0f b6 07             	movzbl (%edi),%eax
  8002ef:	0f b6 c8             	movzbl %al,%ecx
  8002f2:	83 e8 23             	sub    $0x23,%eax
  8002f5:	3c 55                	cmp    $0x55,%al
  8002f7:	0f 87 55 03 00 00    	ja     800652 <vprintfmt+0x3d0>
  8002fd:	0f b6 c0             	movzbl %al,%eax
  800300:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  800307:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80030a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030e:	eb d6                	jmp    8002e6 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800310:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800313:	b8 00 00 00 00       	mov    $0x0,%eax
  800318:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80031b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800322:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800325:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800328:	83 fa 09             	cmp    $0x9,%edx
  80032b:	77 39                	ja     800366 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80032d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800330:	eb e9                	jmp    80031b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800332:	8b 45 14             	mov    0x14(%ebp),%eax
  800335:	8d 48 04             	lea    0x4(%eax),%ecx
  800338:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80033b:	8b 00                	mov    (%eax),%eax
  80033d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800343:	eb 27                	jmp    80036c <vprintfmt+0xea>
  800345:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800348:	85 c0                	test   %eax,%eax
  80034a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034f:	0f 49 c8             	cmovns %eax,%ecx
  800352:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800358:	eb 8c                	jmp    8002e6 <vprintfmt+0x64>
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80035d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800364:	eb 80                	jmp    8002e6 <vprintfmt+0x64>
  800366:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800369:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80036c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800370:	0f 89 70 ff ff ff    	jns    8002e6 <vprintfmt+0x64>
				width = precision, precision = -1;
  800376:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800379:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800383:	e9 5e ff ff ff       	jmp    8002e6 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800388:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80038e:	e9 53 ff ff ff       	jmp    8002e6 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	8d 50 04             	lea    0x4(%eax),%edx
  800399:	89 55 14             	mov    %edx,0x14(%ebp)
  80039c:	83 ec 08             	sub    $0x8,%esp
  80039f:	53                   	push   %ebx
  8003a0:	ff 30                	pushl  (%eax)
  8003a2:	ff d6                	call   *%esi
			break;
  8003a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003aa:	e9 04 ff ff ff       	jmp    8002b3 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003af:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b2:	8d 50 04             	lea    0x4(%eax),%edx
  8003b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b8:	8b 00                	mov    (%eax),%eax
  8003ba:	99                   	cltd   
  8003bb:	31 d0                	xor    %edx,%eax
  8003bd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003bf:	83 f8 08             	cmp    $0x8,%eax
  8003c2:	7f 0b                	jg     8003cf <vprintfmt+0x14d>
  8003c4:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  8003cb:	85 d2                	test   %edx,%edx
  8003cd:	75 18                	jne    8003e7 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  8003cf:	50                   	push   %eax
  8003d0:	68 f0 0f 80 00       	push   $0x800ff0
  8003d5:	53                   	push   %ebx
  8003d6:	56                   	push   %esi
  8003d7:	e8 89 fe ff ff       	call   800265 <printfmt>
  8003dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e2:	e9 cc fe ff ff       	jmp    8002b3 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8003e7:	52                   	push   %edx
  8003e8:	68 f9 0f 80 00       	push   $0x800ff9
  8003ed:	53                   	push   %ebx
  8003ee:	56                   	push   %esi
  8003ef:	e8 71 fe ff ff       	call   800265 <printfmt>
  8003f4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fa:	e9 b4 fe ff ff       	jmp    8002b3 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800402:	8d 50 04             	lea    0x4(%eax),%edx
  800405:	89 55 14             	mov    %edx,0x14(%ebp)
  800408:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80040a:	85 ff                	test   %edi,%edi
  80040c:	b8 e9 0f 80 00       	mov    $0x800fe9,%eax
  800411:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800414:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800418:	0f 8e 94 00 00 00    	jle    8004b2 <vprintfmt+0x230>
  80041e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800422:	0f 84 98 00 00 00    	je     8004c0 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	ff 75 d0             	pushl  -0x30(%ebp)
  80042e:	57                   	push   %edi
  80042f:	e8 c1 02 00 00       	call   8006f5 <strnlen>
  800434:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800437:	29 c1                	sub    %eax,%ecx
  800439:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80043c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800443:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800446:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800449:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80044b:	eb 0f                	jmp    80045c <vprintfmt+0x1da>
					putch(padc, putdat);
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	53                   	push   %ebx
  800451:	ff 75 e0             	pushl  -0x20(%ebp)
  800454:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800456:	83 ef 01             	sub    $0x1,%edi
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 ff                	test   %edi,%edi
  80045e:	7f ed                	jg     80044d <vprintfmt+0x1cb>
  800460:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800463:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800466:	85 c9                	test   %ecx,%ecx
  800468:	b8 00 00 00 00       	mov    $0x0,%eax
  80046d:	0f 49 c1             	cmovns %ecx,%eax
  800470:	29 c1                	sub    %eax,%ecx
  800472:	89 75 08             	mov    %esi,0x8(%ebp)
  800475:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800478:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80047b:	89 cb                	mov    %ecx,%ebx
  80047d:	eb 4d                	jmp    8004cc <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80047f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800483:	74 1b                	je     8004a0 <vprintfmt+0x21e>
  800485:	0f be c0             	movsbl %al,%eax
  800488:	83 e8 20             	sub    $0x20,%eax
  80048b:	83 f8 5e             	cmp    $0x5e,%eax
  80048e:	76 10                	jbe    8004a0 <vprintfmt+0x21e>
					putch('?', putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	ff 75 0c             	pushl  0xc(%ebp)
  800496:	6a 3f                	push   $0x3f
  800498:	ff 55 08             	call   *0x8(%ebp)
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	eb 0d                	jmp    8004ad <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	ff 75 0c             	pushl  0xc(%ebp)
  8004a6:	52                   	push   %edx
  8004a7:	ff 55 08             	call   *0x8(%ebp)
  8004aa:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ad:	83 eb 01             	sub    $0x1,%ebx
  8004b0:	eb 1a                	jmp    8004cc <vprintfmt+0x24a>
  8004b2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004bb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004be:	eb 0c                	jmp    8004cc <vprintfmt+0x24a>
  8004c0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004cc:	83 c7 01             	add    $0x1,%edi
  8004cf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d3:	0f be d0             	movsbl %al,%edx
  8004d6:	85 d2                	test   %edx,%edx
  8004d8:	74 23                	je     8004fd <vprintfmt+0x27b>
  8004da:	85 f6                	test   %esi,%esi
  8004dc:	78 a1                	js     80047f <vprintfmt+0x1fd>
  8004de:	83 ee 01             	sub    $0x1,%esi
  8004e1:	79 9c                	jns    80047f <vprintfmt+0x1fd>
  8004e3:	89 df                	mov    %ebx,%edi
  8004e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004eb:	eb 18                	jmp    800505 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	53                   	push   %ebx
  8004f1:	6a 20                	push   $0x20
  8004f3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f5:	83 ef 01             	sub    $0x1,%edi
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	eb 08                	jmp    800505 <vprintfmt+0x283>
  8004fd:	89 df                	mov    %ebx,%edi
  8004ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800502:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800505:	85 ff                	test   %edi,%edi
  800507:	7f e4                	jg     8004ed <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050c:	e9 a2 fd ff ff       	jmp    8002b3 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800511:	83 fa 01             	cmp    $0x1,%edx
  800514:	7e 16                	jle    80052c <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 50 08             	lea    0x8(%eax),%edx
  80051c:	89 55 14             	mov    %edx,0x14(%ebp)
  80051f:	8b 50 04             	mov    0x4(%eax),%edx
  800522:	8b 00                	mov    (%eax),%eax
  800524:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800527:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052a:	eb 32                	jmp    80055e <vprintfmt+0x2dc>
	else if (lflag)
  80052c:	85 d2                	test   %edx,%edx
  80052e:	74 18                	je     800548 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8d 50 04             	lea    0x4(%eax),%edx
  800536:	89 55 14             	mov    %edx,0x14(%ebp)
  800539:	8b 00                	mov    (%eax),%eax
  80053b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053e:	89 c1                	mov    %eax,%ecx
  800540:	c1 f9 1f             	sar    $0x1f,%ecx
  800543:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800546:	eb 16                	jmp    80055e <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8d 50 04             	lea    0x4(%eax),%edx
  80054e:	89 55 14             	mov    %edx,0x14(%ebp)
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800556:	89 c1                	mov    %eax,%ecx
  800558:	c1 f9 1f             	sar    $0x1f,%ecx
  80055b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800561:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800564:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800569:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80056d:	79 74                	jns    8005e3 <vprintfmt+0x361>
				putch('-', putdat);
  80056f:	83 ec 08             	sub    $0x8,%esp
  800572:	53                   	push   %ebx
  800573:	6a 2d                	push   $0x2d
  800575:	ff d6                	call   *%esi
				num = -(long long) num;
  800577:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80057a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80057d:	f7 d8                	neg    %eax
  80057f:	83 d2 00             	adc    $0x0,%edx
  800582:	f7 da                	neg    %edx
  800584:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800587:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80058c:	eb 55                	jmp    8005e3 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058e:	8d 45 14             	lea    0x14(%ebp),%eax
  800591:	e8 78 fc ff ff       	call   80020e <getuint>
			base = 10;
  800596:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80059b:	eb 46                	jmp    8005e3 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  80059d:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a0:	e8 69 fc ff ff       	call   80020e <getuint>
      base = 8;
  8005a5:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8005aa:	eb 37                	jmp    8005e3 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	53                   	push   %ebx
  8005b0:	6a 30                	push   $0x30
  8005b2:	ff d6                	call   *%esi
			putch('x', putdat);
  8005b4:	83 c4 08             	add    $0x8,%esp
  8005b7:	53                   	push   %ebx
  8005b8:	6a 78                	push   $0x78
  8005ba:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 50 04             	lea    0x4(%eax),%edx
  8005c2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005c5:	8b 00                	mov    (%eax),%eax
  8005c7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005cc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005cf:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005d4:	eb 0d                	jmp    8005e3 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d9:	e8 30 fc ff ff       	call   80020e <getuint>
			base = 16;
  8005de:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005ea:	57                   	push   %edi
  8005eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ee:	51                   	push   %ecx
  8005ef:	52                   	push   %edx
  8005f0:	50                   	push   %eax
  8005f1:	89 da                	mov    %ebx,%edx
  8005f3:	89 f0                	mov    %esi,%eax
  8005f5:	e8 65 fb ff ff       	call   80015f <printnum>
			break;
  8005fa:	83 c4 20             	add    $0x20,%esp
  8005fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800600:	e9 ae fc ff ff       	jmp    8002b3 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	51                   	push   %ecx
  80060a:	ff d6                	call   *%esi
			break;
  80060c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800612:	e9 9c fc ff ff       	jmp    8002b3 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800617:	83 fa 01             	cmp    $0x1,%edx
  80061a:	7e 0d                	jle    800629 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 08             	lea    0x8(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	8b 00                	mov    (%eax),%eax
  800627:	eb 1c                	jmp    800645 <vprintfmt+0x3c3>
	else if (lflag)
  800629:	85 d2                	test   %edx,%edx
  80062b:	74 0d                	je     80063a <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 50 04             	lea    0x4(%eax),%edx
  800633:	89 55 14             	mov    %edx,0x14(%ebp)
  800636:	8b 00                	mov    (%eax),%eax
  800638:	eb 0b                	jmp    800645 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  800645:	a3 0c 20 80 00       	mov    %eax,0x80200c
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  80064d:	e9 61 fc ff ff       	jmp    8002b3 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	53                   	push   %ebx
  800656:	6a 25                	push   $0x25
  800658:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065a:	83 c4 10             	add    $0x10,%esp
  80065d:	eb 03                	jmp    800662 <vprintfmt+0x3e0>
  80065f:	83 ef 01             	sub    $0x1,%edi
  800662:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800666:	75 f7                	jne    80065f <vprintfmt+0x3dd>
  800668:	e9 46 fc ff ff       	jmp    8002b3 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  80066d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800670:	5b                   	pop    %ebx
  800671:	5e                   	pop    %esi
  800672:	5f                   	pop    %edi
  800673:	5d                   	pop    %ebp
  800674:	c3                   	ret    

00800675 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800675:	55                   	push   %ebp
  800676:	89 e5                	mov    %esp,%ebp
  800678:	83 ec 18             	sub    $0x18,%esp
  80067b:	8b 45 08             	mov    0x8(%ebp),%eax
  80067e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800681:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800684:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800688:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800692:	85 c0                	test   %eax,%eax
  800694:	74 26                	je     8006bc <vsnprintf+0x47>
  800696:	85 d2                	test   %edx,%edx
  800698:	7e 22                	jle    8006bc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069a:	ff 75 14             	pushl  0x14(%ebp)
  80069d:	ff 75 10             	pushl  0x10(%ebp)
  8006a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a3:	50                   	push   %eax
  8006a4:	68 48 02 80 00       	push   $0x800248
  8006a9:	e8 d4 fb ff ff       	call   800282 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	eb 05                	jmp    8006c1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c1:	c9                   	leave  
  8006c2:	c3                   	ret    

008006c3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006cc:	50                   	push   %eax
  8006cd:	ff 75 10             	pushl  0x10(%ebp)
  8006d0:	ff 75 0c             	pushl  0xc(%ebp)
  8006d3:	ff 75 08             	pushl  0x8(%ebp)
  8006d6:	e8 9a ff ff ff       	call   800675 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006db:	c9                   	leave  
  8006dc:	c3                   	ret    

008006dd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e8:	eb 03                	jmp    8006ed <strlen+0x10>
		n++;
  8006ea:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ed:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f1:	75 f7                	jne    8006ea <strlen+0xd>
		n++;
	return n;
}
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800703:	eb 03                	jmp    800708 <strnlen+0x13>
		n++;
  800705:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800708:	39 c2                	cmp    %eax,%edx
  80070a:	74 08                	je     800714 <strnlen+0x1f>
  80070c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800710:	75 f3                	jne    800705 <strnlen+0x10>
  800712:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	53                   	push   %ebx
  80071a:	8b 45 08             	mov    0x8(%ebp),%eax
  80071d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800720:	89 c2                	mov    %eax,%edx
  800722:	83 c2 01             	add    $0x1,%edx
  800725:	83 c1 01             	add    $0x1,%ecx
  800728:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80072c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80072f:	84 db                	test   %bl,%bl
  800731:	75 ef                	jne    800722 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800733:	5b                   	pop    %ebx
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	53                   	push   %ebx
  80073a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073d:	53                   	push   %ebx
  80073e:	e8 9a ff ff ff       	call   8006dd <strlen>
  800743:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800746:	ff 75 0c             	pushl  0xc(%ebp)
  800749:	01 d8                	add    %ebx,%eax
  80074b:	50                   	push   %eax
  80074c:	e8 c5 ff ff ff       	call   800716 <strcpy>
	return dst;
}
  800751:	89 d8                	mov    %ebx,%eax
  800753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800756:	c9                   	leave  
  800757:	c3                   	ret    

00800758 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	56                   	push   %esi
  80075c:	53                   	push   %ebx
  80075d:	8b 75 08             	mov    0x8(%ebp),%esi
  800760:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800763:	89 f3                	mov    %esi,%ebx
  800765:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800768:	89 f2                	mov    %esi,%edx
  80076a:	eb 0f                	jmp    80077b <strncpy+0x23>
		*dst++ = *src;
  80076c:	83 c2 01             	add    $0x1,%edx
  80076f:	0f b6 01             	movzbl (%ecx),%eax
  800772:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800775:	80 39 01             	cmpb   $0x1,(%ecx)
  800778:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077b:	39 da                	cmp    %ebx,%edx
  80077d:	75 ed                	jne    80076c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80077f:	89 f0                	mov    %esi,%eax
  800781:	5b                   	pop    %ebx
  800782:	5e                   	pop    %esi
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	56                   	push   %esi
  800789:	53                   	push   %ebx
  80078a:	8b 75 08             	mov    0x8(%ebp),%esi
  80078d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800790:	8b 55 10             	mov    0x10(%ebp),%edx
  800793:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800795:	85 d2                	test   %edx,%edx
  800797:	74 21                	je     8007ba <strlcpy+0x35>
  800799:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80079d:	89 f2                	mov    %esi,%edx
  80079f:	eb 09                	jmp    8007aa <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a1:	83 c2 01             	add    $0x1,%edx
  8007a4:	83 c1 01             	add    $0x1,%ecx
  8007a7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007aa:	39 c2                	cmp    %eax,%edx
  8007ac:	74 09                	je     8007b7 <strlcpy+0x32>
  8007ae:	0f b6 19             	movzbl (%ecx),%ebx
  8007b1:	84 db                	test   %bl,%bl
  8007b3:	75 ec                	jne    8007a1 <strlcpy+0x1c>
  8007b5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ba:	29 f0                	sub    %esi,%eax
}
  8007bc:	5b                   	pop    %ebx
  8007bd:	5e                   	pop    %esi
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c9:	eb 06                	jmp    8007d1 <strcmp+0x11>
		p++, q++;
  8007cb:	83 c1 01             	add    $0x1,%ecx
  8007ce:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d1:	0f b6 01             	movzbl (%ecx),%eax
  8007d4:	84 c0                	test   %al,%al
  8007d6:	74 04                	je     8007dc <strcmp+0x1c>
  8007d8:	3a 02                	cmp    (%edx),%al
  8007da:	74 ef                	je     8007cb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007dc:	0f b6 c0             	movzbl %al,%eax
  8007df:	0f b6 12             	movzbl (%edx),%edx
  8007e2:	29 d0                	sub    %edx,%eax
}
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	53                   	push   %ebx
  8007ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f0:	89 c3                	mov    %eax,%ebx
  8007f2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f5:	eb 06                	jmp    8007fd <strncmp+0x17>
		n--, p++, q++;
  8007f7:	83 c0 01             	add    $0x1,%eax
  8007fa:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007fd:	39 d8                	cmp    %ebx,%eax
  8007ff:	74 15                	je     800816 <strncmp+0x30>
  800801:	0f b6 08             	movzbl (%eax),%ecx
  800804:	84 c9                	test   %cl,%cl
  800806:	74 04                	je     80080c <strncmp+0x26>
  800808:	3a 0a                	cmp    (%edx),%cl
  80080a:	74 eb                	je     8007f7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080c:	0f b6 00             	movzbl (%eax),%eax
  80080f:	0f b6 12             	movzbl (%edx),%edx
  800812:	29 d0                	sub    %edx,%eax
  800814:	eb 05                	jmp    80081b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80081b:	5b                   	pop    %ebx
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800828:	eb 07                	jmp    800831 <strchr+0x13>
		if (*s == c)
  80082a:	38 ca                	cmp    %cl,%dl
  80082c:	74 0f                	je     80083d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80082e:	83 c0 01             	add    $0x1,%eax
  800831:	0f b6 10             	movzbl (%eax),%edx
  800834:	84 d2                	test   %dl,%dl
  800836:	75 f2                	jne    80082a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800838:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800849:	eb 03                	jmp    80084e <strfind+0xf>
  80084b:	83 c0 01             	add    $0x1,%eax
  80084e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800851:	38 ca                	cmp    %cl,%dl
  800853:	74 04                	je     800859 <strfind+0x1a>
  800855:	84 d2                	test   %dl,%dl
  800857:	75 f2                	jne    80084b <strfind+0xc>
			break;
	return (char *) s;
}
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	57                   	push   %edi
  80085f:	56                   	push   %esi
  800860:	53                   	push   %ebx
  800861:	8b 7d 08             	mov    0x8(%ebp),%edi
  800864:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800867:	85 c9                	test   %ecx,%ecx
  800869:	74 36                	je     8008a1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800871:	75 28                	jne    80089b <memset+0x40>
  800873:	f6 c1 03             	test   $0x3,%cl
  800876:	75 23                	jne    80089b <memset+0x40>
		c &= 0xFF;
  800878:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80087c:	89 d3                	mov    %edx,%ebx
  80087e:	c1 e3 08             	shl    $0x8,%ebx
  800881:	89 d6                	mov    %edx,%esi
  800883:	c1 e6 18             	shl    $0x18,%esi
  800886:	89 d0                	mov    %edx,%eax
  800888:	c1 e0 10             	shl    $0x10,%eax
  80088b:	09 f0                	or     %esi,%eax
  80088d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80088f:	89 d8                	mov    %ebx,%eax
  800891:	09 d0                	or     %edx,%eax
  800893:	c1 e9 02             	shr    $0x2,%ecx
  800896:	fc                   	cld    
  800897:	f3 ab                	rep stos %eax,%es:(%edi)
  800899:	eb 06                	jmp    8008a1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089e:	fc                   	cld    
  80089f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a1:	89 f8                	mov    %edi,%eax
  8008a3:	5b                   	pop    %ebx
  8008a4:	5e                   	pop    %esi
  8008a5:	5f                   	pop    %edi
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	57                   	push   %edi
  8008ac:	56                   	push   %esi
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b6:	39 c6                	cmp    %eax,%esi
  8008b8:	73 35                	jae    8008ef <memmove+0x47>
  8008ba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008bd:	39 d0                	cmp    %edx,%eax
  8008bf:	73 2e                	jae    8008ef <memmove+0x47>
		s += n;
		d += n;
  8008c1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c4:	89 d6                	mov    %edx,%esi
  8008c6:	09 fe                	or     %edi,%esi
  8008c8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ce:	75 13                	jne    8008e3 <memmove+0x3b>
  8008d0:	f6 c1 03             	test   $0x3,%cl
  8008d3:	75 0e                	jne    8008e3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d5:	83 ef 04             	sub    $0x4,%edi
  8008d8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008db:	c1 e9 02             	shr    $0x2,%ecx
  8008de:	fd                   	std    
  8008df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e1:	eb 09                	jmp    8008ec <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e3:	83 ef 01             	sub    $0x1,%edi
  8008e6:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008e9:	fd                   	std    
  8008ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ec:	fc                   	cld    
  8008ed:	eb 1d                	jmp    80090c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ef:	89 f2                	mov    %esi,%edx
  8008f1:	09 c2                	or     %eax,%edx
  8008f3:	f6 c2 03             	test   $0x3,%dl
  8008f6:	75 0f                	jne    800907 <memmove+0x5f>
  8008f8:	f6 c1 03             	test   $0x3,%cl
  8008fb:	75 0a                	jne    800907 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008fd:	c1 e9 02             	shr    $0x2,%ecx
  800900:	89 c7                	mov    %eax,%edi
  800902:	fc                   	cld    
  800903:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800905:	eb 05                	jmp    80090c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800907:	89 c7                	mov    %eax,%edi
  800909:	fc                   	cld    
  80090a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80090c:	5e                   	pop    %esi
  80090d:	5f                   	pop    %edi
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800913:	ff 75 10             	pushl  0x10(%ebp)
  800916:	ff 75 0c             	pushl  0xc(%ebp)
  800919:	ff 75 08             	pushl  0x8(%ebp)
  80091c:	e8 87 ff ff ff       	call   8008a8 <memmove>
}
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092e:	89 c6                	mov    %eax,%esi
  800930:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800933:	eb 1a                	jmp    80094f <memcmp+0x2c>
		if (*s1 != *s2)
  800935:	0f b6 08             	movzbl (%eax),%ecx
  800938:	0f b6 1a             	movzbl (%edx),%ebx
  80093b:	38 d9                	cmp    %bl,%cl
  80093d:	74 0a                	je     800949 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80093f:	0f b6 c1             	movzbl %cl,%eax
  800942:	0f b6 db             	movzbl %bl,%ebx
  800945:	29 d8                	sub    %ebx,%eax
  800947:	eb 0f                	jmp    800958 <memcmp+0x35>
		s1++, s2++;
  800949:	83 c0 01             	add    $0x1,%eax
  80094c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094f:	39 f0                	cmp    %esi,%eax
  800951:	75 e2                	jne    800935 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800958:	5b                   	pop    %ebx
  800959:	5e                   	pop    %esi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	53                   	push   %ebx
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800963:	89 c1                	mov    %eax,%ecx
  800965:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800968:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096c:	eb 0a                	jmp    800978 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80096e:	0f b6 10             	movzbl (%eax),%edx
  800971:	39 da                	cmp    %ebx,%edx
  800973:	74 07                	je     80097c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	39 c8                	cmp    %ecx,%eax
  80097a:	72 f2                	jb     80096e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80097c:	5b                   	pop    %ebx
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	57                   	push   %edi
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800988:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098b:	eb 03                	jmp    800990 <strtol+0x11>
		s++;
  80098d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800990:	0f b6 01             	movzbl (%ecx),%eax
  800993:	3c 20                	cmp    $0x20,%al
  800995:	74 f6                	je     80098d <strtol+0xe>
  800997:	3c 09                	cmp    $0x9,%al
  800999:	74 f2                	je     80098d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80099b:	3c 2b                	cmp    $0x2b,%al
  80099d:	75 0a                	jne    8009a9 <strtol+0x2a>
		s++;
  80099f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a7:	eb 11                	jmp    8009ba <strtol+0x3b>
  8009a9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ae:	3c 2d                	cmp    $0x2d,%al
  8009b0:	75 08                	jne    8009ba <strtol+0x3b>
		s++, neg = 1;
  8009b2:	83 c1 01             	add    $0x1,%ecx
  8009b5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ba:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c0:	75 15                	jne    8009d7 <strtol+0x58>
  8009c2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c5:	75 10                	jne    8009d7 <strtol+0x58>
  8009c7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009cb:	75 7c                	jne    800a49 <strtol+0xca>
		s += 2, base = 16;
  8009cd:	83 c1 02             	add    $0x2,%ecx
  8009d0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d5:	eb 16                	jmp    8009ed <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009d7:	85 db                	test   %ebx,%ebx
  8009d9:	75 12                	jne    8009ed <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009db:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e0:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e3:	75 08                	jne    8009ed <strtol+0x6e>
		s++, base = 8;
  8009e5:	83 c1 01             	add    $0x1,%ecx
  8009e8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f5:	0f b6 11             	movzbl (%ecx),%edx
  8009f8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009fb:	89 f3                	mov    %esi,%ebx
  8009fd:	80 fb 09             	cmp    $0x9,%bl
  800a00:	77 08                	ja     800a0a <strtol+0x8b>
			dig = *s - '0';
  800a02:	0f be d2             	movsbl %dl,%edx
  800a05:	83 ea 30             	sub    $0x30,%edx
  800a08:	eb 22                	jmp    800a2c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a0a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a0d:	89 f3                	mov    %esi,%ebx
  800a0f:	80 fb 19             	cmp    $0x19,%bl
  800a12:	77 08                	ja     800a1c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a14:	0f be d2             	movsbl %dl,%edx
  800a17:	83 ea 57             	sub    $0x57,%edx
  800a1a:	eb 10                	jmp    800a2c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a1c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a1f:	89 f3                	mov    %esi,%ebx
  800a21:	80 fb 19             	cmp    $0x19,%bl
  800a24:	77 16                	ja     800a3c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a26:	0f be d2             	movsbl %dl,%edx
  800a29:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a2c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a2f:	7d 0b                	jge    800a3c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a31:	83 c1 01             	add    $0x1,%ecx
  800a34:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a38:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a3a:	eb b9                	jmp    8009f5 <strtol+0x76>

	if (endptr)
  800a3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a40:	74 0d                	je     800a4f <strtol+0xd0>
		*endptr = (char *) s;
  800a42:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a45:	89 0e                	mov    %ecx,(%esi)
  800a47:	eb 06                	jmp    800a4f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a49:	85 db                	test   %ebx,%ebx
  800a4b:	74 98                	je     8009e5 <strtol+0x66>
  800a4d:	eb 9e                	jmp    8009ed <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a4f:	89 c2                	mov    %eax,%edx
  800a51:	f7 da                	neg    %edx
  800a53:	85 ff                	test   %edi,%edi
  800a55:	0f 45 c2             	cmovne %edx,%eax
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
  800a68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6e:	89 c3                	mov    %eax,%ebx
  800a70:	89 c7                	mov    %eax,%edi
  800a72:	89 c6                	mov    %eax,%esi
  800a74:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5f                   	pop    %edi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	57                   	push   %edi
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a81:	ba 00 00 00 00       	mov    $0x0,%edx
  800a86:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8b:	89 d1                	mov    %edx,%ecx
  800a8d:	89 d3                	mov    %edx,%ebx
  800a8f:	89 d7                	mov    %edx,%edi
  800a91:	89 d6                	mov    %edx,%esi
  800a93:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	57                   	push   %edi
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
  800aa0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa8:	b8 03 00 00 00       	mov    $0x3,%eax
  800aad:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab0:	89 cb                	mov    %ecx,%ebx
  800ab2:	89 cf                	mov    %ecx,%edi
  800ab4:	89 ce                	mov    %ecx,%esi
  800ab6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ab8:	85 c0                	test   %eax,%eax
  800aba:	7e 17                	jle    800ad3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abc:	83 ec 0c             	sub    $0xc,%esp
  800abf:	50                   	push   %eax
  800ac0:	6a 03                	push   $0x3
  800ac2:	68 24 12 80 00       	push   $0x801224
  800ac7:	6a 23                	push   $0x23
  800ac9:	68 41 12 80 00       	push   $0x801241
  800ace:	e8 15 02 00 00       	call   800ce8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae6:	b8 02 00 00 00       	mov    $0x2,%eax
  800aeb:	89 d1                	mov    %edx,%ecx
  800aed:	89 d3                	mov    %edx,%ebx
  800aef:	89 d7                	mov    %edx,%edi
  800af1:	89 d6                	mov    %edx,%esi
  800af3:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_yield>:

void
sys_yield(void)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b00:	ba 00 00 00 00       	mov    $0x0,%edx
  800b05:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b0a:	89 d1                	mov    %edx,%ecx
  800b0c:	89 d3                	mov    %edx,%ebx
  800b0e:	89 d7                	mov    %edx,%edi
  800b10:	89 d6                	mov    %edx,%esi
  800b12:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
  800b1f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	be 00 00 00 00       	mov    $0x0,%esi
  800b27:	b8 04 00 00 00       	mov    $0x4,%eax
  800b2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b35:	89 f7                	mov    %esi,%edi
  800b37:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b39:	85 c0                	test   %eax,%eax
  800b3b:	7e 17                	jle    800b54 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3d:	83 ec 0c             	sub    $0xc,%esp
  800b40:	50                   	push   %eax
  800b41:	6a 04                	push   $0x4
  800b43:	68 24 12 80 00       	push   $0x801224
  800b48:	6a 23                	push   $0x23
  800b4a:	68 41 12 80 00       	push   $0x801241
  800b4f:	e8 94 01 00 00       	call   800ce8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800b65:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b73:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b76:	8b 75 18             	mov    0x18(%ebp),%esi
  800b79:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7b:	85 c0                	test   %eax,%eax
  800b7d:	7e 17                	jle    800b96 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7f:	83 ec 0c             	sub    $0xc,%esp
  800b82:	50                   	push   %eax
  800b83:	6a 05                	push   $0x5
  800b85:	68 24 12 80 00       	push   $0x801224
  800b8a:	6a 23                	push   $0x23
  800b8c:	68 41 12 80 00       	push   $0x801241
  800b91:	e8 52 01 00 00       	call   800ce8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bac:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	89 df                	mov    %ebx,%edi
  800bb9:	89 de                	mov    %ebx,%esi
  800bbb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	7e 17                	jle    800bd8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc1:	83 ec 0c             	sub    $0xc,%esp
  800bc4:	50                   	push   %eax
  800bc5:	6a 06                	push   $0x6
  800bc7:	68 24 12 80 00       	push   $0x801224
  800bcc:	6a 23                	push   $0x23
  800bce:	68 41 12 80 00       	push   $0x801241
  800bd3:	e8 10 01 00 00       	call   800ce8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    

00800be0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bee:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf9:	89 df                	mov    %ebx,%edi
  800bfb:	89 de                	mov    %ebx,%esi
  800bfd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bff:	85 c0                	test   %eax,%eax
  800c01:	7e 17                	jle    800c1a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	50                   	push   %eax
  800c07:	6a 08                	push   $0x8
  800c09:	68 24 12 80 00       	push   $0x801224
  800c0e:	6a 23                	push   $0x23
  800c10:	68 41 12 80 00       	push   $0x801241
  800c15:	e8 ce 00 00 00       	call   800ce8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c30:	b8 09 00 00 00       	mov    $0x9,%eax
  800c35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c38:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3b:	89 df                	mov    %ebx,%edi
  800c3d:	89 de                	mov    %ebx,%esi
  800c3f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	7e 17                	jle    800c5c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	83 ec 0c             	sub    $0xc,%esp
  800c48:	50                   	push   %eax
  800c49:	6a 09                	push   $0x9
  800c4b:	68 24 12 80 00       	push   $0x801224
  800c50:	6a 23                	push   $0x23
  800c52:	68 41 12 80 00       	push   $0x801241
  800c57:	e8 8c 00 00 00       	call   800ce8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	be 00 00 00 00       	mov    $0x0,%esi
  800c6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c80:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c95:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	89 cb                	mov    %ecx,%ebx
  800c9f:	89 cf                	mov    %ecx,%edi
  800ca1:	89 ce                	mov    %ecx,%esi
  800ca3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	7e 17                	jle    800cc0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	83 ec 0c             	sub    $0xc,%esp
  800cac:	50                   	push   %eax
  800cad:	6a 0c                	push   $0xc
  800caf:	68 24 12 80 00       	push   $0x801224
  800cb4:	6a 23                	push   $0x23
  800cb6:	68 41 12 80 00       	push   $0x801241
  800cbb:	e8 28 00 00 00       	call   800ce8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_change_pr>:

int
sys_change_pr(int pr)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 cb                	mov    %ecx,%ebx
  800cdd:	89 cf                	mov    %ecx,%edi
  800cdf:	89 ce                	mov    %ecx,%esi
  800ce1:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ced:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cf0:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800cf6:	e8 e0 fd ff ff       	call   800adb <sys_getenvid>
  800cfb:	83 ec 0c             	sub    $0xc,%esp
  800cfe:	ff 75 0c             	pushl  0xc(%ebp)
  800d01:	ff 75 08             	pushl  0x8(%ebp)
  800d04:	56                   	push   %esi
  800d05:	50                   	push   %eax
  800d06:	68 50 12 80 00       	push   $0x801250
  800d0b:	e8 3b f4 ff ff       	call   80014b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d10:	83 c4 18             	add    $0x18,%esp
  800d13:	53                   	push   %ebx
  800d14:	ff 75 10             	pushl  0x10(%ebp)
  800d17:	e8 de f3 ff ff       	call   8000fa <vcprintf>
	cprintf("\n");
  800d1c:	c7 04 24 cc 0f 80 00 	movl   $0x800fcc,(%esp)
  800d23:	e8 23 f4 ff ff       	call   80014b <cprintf>
  800d28:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d2b:	cc                   	int3   
  800d2c:	eb fd                	jmp    800d2b <_panic+0x43>
  800d2e:	66 90                	xchg   %ax,%ax

00800d30 <__udivdi3>:
  800d30:	55                   	push   %ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 1c             	sub    $0x1c,%esp
  800d37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d47:	85 f6                	test   %esi,%esi
  800d49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d4d:	89 ca                	mov    %ecx,%edx
  800d4f:	89 f8                	mov    %edi,%eax
  800d51:	75 3d                	jne    800d90 <__udivdi3+0x60>
  800d53:	39 cf                	cmp    %ecx,%edi
  800d55:	0f 87 c5 00 00 00    	ja     800e20 <__udivdi3+0xf0>
  800d5b:	85 ff                	test   %edi,%edi
  800d5d:	89 fd                	mov    %edi,%ebp
  800d5f:	75 0b                	jne    800d6c <__udivdi3+0x3c>
  800d61:	b8 01 00 00 00       	mov    $0x1,%eax
  800d66:	31 d2                	xor    %edx,%edx
  800d68:	f7 f7                	div    %edi
  800d6a:	89 c5                	mov    %eax,%ebp
  800d6c:	89 c8                	mov    %ecx,%eax
  800d6e:	31 d2                	xor    %edx,%edx
  800d70:	f7 f5                	div    %ebp
  800d72:	89 c1                	mov    %eax,%ecx
  800d74:	89 d8                	mov    %ebx,%eax
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	f7 f5                	div    %ebp
  800d7a:	89 c3                	mov    %eax,%ebx
  800d7c:	89 d8                	mov    %ebx,%eax
  800d7e:	89 fa                	mov    %edi,%edx
  800d80:	83 c4 1c             	add    $0x1c,%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    
  800d88:	90                   	nop
  800d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d90:	39 ce                	cmp    %ecx,%esi
  800d92:	77 74                	ja     800e08 <__udivdi3+0xd8>
  800d94:	0f bd fe             	bsr    %esi,%edi
  800d97:	83 f7 1f             	xor    $0x1f,%edi
  800d9a:	0f 84 98 00 00 00    	je     800e38 <__udivdi3+0x108>
  800da0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800da5:	89 f9                	mov    %edi,%ecx
  800da7:	89 c5                	mov    %eax,%ebp
  800da9:	29 fb                	sub    %edi,%ebx
  800dab:	d3 e6                	shl    %cl,%esi
  800dad:	89 d9                	mov    %ebx,%ecx
  800daf:	d3 ed                	shr    %cl,%ebp
  800db1:	89 f9                	mov    %edi,%ecx
  800db3:	d3 e0                	shl    %cl,%eax
  800db5:	09 ee                	or     %ebp,%esi
  800db7:	89 d9                	mov    %ebx,%ecx
  800db9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dbd:	89 d5                	mov    %edx,%ebp
  800dbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800dc3:	d3 ed                	shr    %cl,%ebp
  800dc5:	89 f9                	mov    %edi,%ecx
  800dc7:	d3 e2                	shl    %cl,%edx
  800dc9:	89 d9                	mov    %ebx,%ecx
  800dcb:	d3 e8                	shr    %cl,%eax
  800dcd:	09 c2                	or     %eax,%edx
  800dcf:	89 d0                	mov    %edx,%eax
  800dd1:	89 ea                	mov    %ebp,%edx
  800dd3:	f7 f6                	div    %esi
  800dd5:	89 d5                	mov    %edx,%ebp
  800dd7:	89 c3                	mov    %eax,%ebx
  800dd9:	f7 64 24 0c          	mull   0xc(%esp)
  800ddd:	39 d5                	cmp    %edx,%ebp
  800ddf:	72 10                	jb     800df1 <__udivdi3+0xc1>
  800de1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800de5:	89 f9                	mov    %edi,%ecx
  800de7:	d3 e6                	shl    %cl,%esi
  800de9:	39 c6                	cmp    %eax,%esi
  800deb:	73 07                	jae    800df4 <__udivdi3+0xc4>
  800ded:	39 d5                	cmp    %edx,%ebp
  800def:	75 03                	jne    800df4 <__udivdi3+0xc4>
  800df1:	83 eb 01             	sub    $0x1,%ebx
  800df4:	31 ff                	xor    %edi,%edi
  800df6:	89 d8                	mov    %ebx,%eax
  800df8:	89 fa                	mov    %edi,%edx
  800dfa:	83 c4 1c             	add    $0x1c,%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    
  800e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e08:	31 ff                	xor    %edi,%edi
  800e0a:	31 db                	xor    %ebx,%ebx
  800e0c:	89 d8                	mov    %ebx,%eax
  800e0e:	89 fa                	mov    %edi,%edx
  800e10:	83 c4 1c             	add    $0x1c,%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    
  800e18:	90                   	nop
  800e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e20:	89 d8                	mov    %ebx,%eax
  800e22:	f7 f7                	div    %edi
  800e24:	31 ff                	xor    %edi,%edi
  800e26:	89 c3                	mov    %eax,%ebx
  800e28:	89 d8                	mov    %ebx,%eax
  800e2a:	89 fa                	mov    %edi,%edx
  800e2c:	83 c4 1c             	add    $0x1c,%esp
  800e2f:	5b                   	pop    %ebx
  800e30:	5e                   	pop    %esi
  800e31:	5f                   	pop    %edi
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    
  800e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e38:	39 ce                	cmp    %ecx,%esi
  800e3a:	72 0c                	jb     800e48 <__udivdi3+0x118>
  800e3c:	31 db                	xor    %ebx,%ebx
  800e3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e42:	0f 87 34 ff ff ff    	ja     800d7c <__udivdi3+0x4c>
  800e48:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e4d:	e9 2a ff ff ff       	jmp    800d7c <__udivdi3+0x4c>
  800e52:	66 90                	xchg   %ax,%ax
  800e54:	66 90                	xchg   %ax,%ax
  800e56:	66 90                	xchg   %ax,%ax
  800e58:	66 90                	xchg   %ax,%ax
  800e5a:	66 90                	xchg   %ax,%ax
  800e5c:	66 90                	xchg   %ax,%ax
  800e5e:	66 90                	xchg   %ax,%ax

00800e60 <__umoddi3>:
  800e60:	55                   	push   %ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
  800e64:	83 ec 1c             	sub    $0x1c,%esp
  800e67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e77:	85 d2                	test   %edx,%edx
  800e79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e81:	89 f3                	mov    %esi,%ebx
  800e83:	89 3c 24             	mov    %edi,(%esp)
  800e86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e8a:	75 1c                	jne    800ea8 <__umoddi3+0x48>
  800e8c:	39 f7                	cmp    %esi,%edi
  800e8e:	76 50                	jbe    800ee0 <__umoddi3+0x80>
  800e90:	89 c8                	mov    %ecx,%eax
  800e92:	89 f2                	mov    %esi,%edx
  800e94:	f7 f7                	div    %edi
  800e96:	89 d0                	mov    %edx,%eax
  800e98:	31 d2                	xor    %edx,%edx
  800e9a:	83 c4 1c             	add    $0x1c,%esp
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    
  800ea2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ea8:	39 f2                	cmp    %esi,%edx
  800eaa:	89 d0                	mov    %edx,%eax
  800eac:	77 52                	ja     800f00 <__umoddi3+0xa0>
  800eae:	0f bd ea             	bsr    %edx,%ebp
  800eb1:	83 f5 1f             	xor    $0x1f,%ebp
  800eb4:	75 5a                	jne    800f10 <__umoddi3+0xb0>
  800eb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eba:	0f 82 e0 00 00 00    	jb     800fa0 <__umoddi3+0x140>
  800ec0:	39 0c 24             	cmp    %ecx,(%esp)
  800ec3:	0f 86 d7 00 00 00    	jbe    800fa0 <__umoddi3+0x140>
  800ec9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ecd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ed1:	83 c4 1c             	add    $0x1c,%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    
  800ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	85 ff                	test   %edi,%edi
  800ee2:	89 fd                	mov    %edi,%ebp
  800ee4:	75 0b                	jne    800ef1 <__umoddi3+0x91>
  800ee6:	b8 01 00 00 00       	mov    $0x1,%eax
  800eeb:	31 d2                	xor    %edx,%edx
  800eed:	f7 f7                	div    %edi
  800eef:	89 c5                	mov    %eax,%ebp
  800ef1:	89 f0                	mov    %esi,%eax
  800ef3:	31 d2                	xor    %edx,%edx
  800ef5:	f7 f5                	div    %ebp
  800ef7:	89 c8                	mov    %ecx,%eax
  800ef9:	f7 f5                	div    %ebp
  800efb:	89 d0                	mov    %edx,%eax
  800efd:	eb 99                	jmp    800e98 <__umoddi3+0x38>
  800eff:	90                   	nop
  800f00:	89 c8                	mov    %ecx,%eax
  800f02:	89 f2                	mov    %esi,%edx
  800f04:	83 c4 1c             	add    $0x1c,%esp
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	5f                   	pop    %edi
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    
  800f0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f10:	8b 34 24             	mov    (%esp),%esi
  800f13:	bf 20 00 00 00       	mov    $0x20,%edi
  800f18:	89 e9                	mov    %ebp,%ecx
  800f1a:	29 ef                	sub    %ebp,%edi
  800f1c:	d3 e0                	shl    %cl,%eax
  800f1e:	89 f9                	mov    %edi,%ecx
  800f20:	89 f2                	mov    %esi,%edx
  800f22:	d3 ea                	shr    %cl,%edx
  800f24:	89 e9                	mov    %ebp,%ecx
  800f26:	09 c2                	or     %eax,%edx
  800f28:	89 d8                	mov    %ebx,%eax
  800f2a:	89 14 24             	mov    %edx,(%esp)
  800f2d:	89 f2                	mov    %esi,%edx
  800f2f:	d3 e2                	shl    %cl,%edx
  800f31:	89 f9                	mov    %edi,%ecx
  800f33:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f3b:	d3 e8                	shr    %cl,%eax
  800f3d:	89 e9                	mov    %ebp,%ecx
  800f3f:	89 c6                	mov    %eax,%esi
  800f41:	d3 e3                	shl    %cl,%ebx
  800f43:	89 f9                	mov    %edi,%ecx
  800f45:	89 d0                	mov    %edx,%eax
  800f47:	d3 e8                	shr    %cl,%eax
  800f49:	89 e9                	mov    %ebp,%ecx
  800f4b:	09 d8                	or     %ebx,%eax
  800f4d:	89 d3                	mov    %edx,%ebx
  800f4f:	89 f2                	mov    %esi,%edx
  800f51:	f7 34 24             	divl   (%esp)
  800f54:	89 d6                	mov    %edx,%esi
  800f56:	d3 e3                	shl    %cl,%ebx
  800f58:	f7 64 24 04          	mull   0x4(%esp)
  800f5c:	39 d6                	cmp    %edx,%esi
  800f5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f62:	89 d1                	mov    %edx,%ecx
  800f64:	89 c3                	mov    %eax,%ebx
  800f66:	72 08                	jb     800f70 <__umoddi3+0x110>
  800f68:	75 11                	jne    800f7b <__umoddi3+0x11b>
  800f6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f6e:	73 0b                	jae    800f7b <__umoddi3+0x11b>
  800f70:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f74:	1b 14 24             	sbb    (%esp),%edx
  800f77:	89 d1                	mov    %edx,%ecx
  800f79:	89 c3                	mov    %eax,%ebx
  800f7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f7f:	29 da                	sub    %ebx,%edx
  800f81:	19 ce                	sbb    %ecx,%esi
  800f83:	89 f9                	mov    %edi,%ecx
  800f85:	89 f0                	mov    %esi,%eax
  800f87:	d3 e0                	shl    %cl,%eax
  800f89:	89 e9                	mov    %ebp,%ecx
  800f8b:	d3 ea                	shr    %cl,%edx
  800f8d:	89 e9                	mov    %ebp,%ecx
  800f8f:	d3 ee                	shr    %cl,%esi
  800f91:	09 d0                	or     %edx,%eax
  800f93:	89 f2                	mov    %esi,%edx
  800f95:	83 c4 1c             	add    $0x1c,%esp
  800f98:	5b                   	pop    %ebx
  800f99:	5e                   	pop    %esi
  800f9a:	5f                   	pop    %edi
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    
  800f9d:	8d 76 00             	lea    0x0(%esi),%esi
  800fa0:	29 f9                	sub    %edi,%ecx
  800fa2:	19 d6                	sbb    %edx,%esi
  800fa4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fa8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fac:	e9 18 ff ff ff       	jmp    800ec9 <__umoddi3+0x69>
