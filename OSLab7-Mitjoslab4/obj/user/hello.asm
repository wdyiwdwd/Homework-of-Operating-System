
obj/user/hello：     文件格式 elf32-i386


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
  80002c:	e8 5e 00 00 00       	call   80008f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i;
	for (i = 1; i <= 5; ++i) {
  800038:	bb 01 00 00 00       	mov    $0x1,%ebx
		int pid = pfork(i);
  80003d:	83 ec 0c             	sub    $0xc,%esp
  800040:	53                   	push   %ebx
  800041:	e8 76 0f 00 00       	call   800fbc <pfork>
		if (pid == 0) {
  800046:	83 c4 10             	add    $0x10,%esp
  800049:	85 c0                	test   %eax,%eax
  80004b:	75 33                	jne    800080 <umain+0x4d>
			cprintf("child %x is now living!\n", i);
  80004d:	83 ec 08             	sub    $0x8,%esp
  800050:	53                   	push   %ebx
  800051:	68 60 14 80 00       	push   $0x801460
  800056:	e8 1f 01 00 00       	call   80017a <cprintf>
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	be 05 00 00 00       	mov    $0x5,%esi
			int j;
			for (j = 0; j < 5; ++j) {
				cprintf("child %x is yielding!\n", i);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	53                   	push   %ebx
  800067:	68 79 14 80 00       	push   $0x801479
  80006c:	e8 09 01 00 00       	call   80017a <cprintf>
				sys_yield();
  800071:	e8 b3 0a 00 00       	call   800b29 <sys_yield>
	for (i = 1; i <= 5; ++i) {
		int pid = pfork(i);
		if (pid == 0) {
			cprintf("child %x is now living!\n", i);
			int j;
			for (j = 0; j < 5; ++j) {
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	83 ee 01             	sub    $0x1,%esi
  80007c:	75 e5                	jne    800063 <umain+0x30>
  80007e:	eb 08                	jmp    800088 <umain+0x55>

void
umain(int argc, char **argv)
{
	int i;
	for (i = 1; i <= 5; ++i) {
  800080:	83 c3 01             	add    $0x1,%ebx
  800083:	83 fb 06             	cmp    $0x6,%ebx
  800086:	75 b5                	jne    80003d <umain+0xa>
				sys_yield();
			}
			break;
		}
	}
}
  800088:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008b:	5b                   	pop    %ebx
  80008c:	5e                   	pop    %esi
  80008d:	5d                   	pop    %ebp
  80008e:	c3                   	ret    

0080008f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80008f:	55                   	push   %ebp
  800090:	89 e5                	mov    %esp,%ebp
  800092:	56                   	push   %esi
  800093:	53                   	push   %ebx
  800094:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800097:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  80009a:	e8 6b 0a 00 00       	call   800b0a <sys_getenvid>
  80009f:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a4:	c1 e0 07             	shl    $0x7,%eax
  8000a7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ac:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b1:	85 db                	test   %ebx,%ebx
  8000b3:	7e 07                	jle    8000bc <libmain+0x2d>
		binaryname = argv[0];
  8000b5:	8b 06                	mov    (%esi),%eax
  8000b7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000bc:	83 ec 08             	sub    $0x8,%esp
  8000bf:	56                   	push   %esi
  8000c0:	53                   	push   %ebx
  8000c1:	e8 6d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c6:	e8 0a 00 00 00       	call   8000d5 <exit>
}
  8000cb:	83 c4 10             	add    $0x10,%esp
  8000ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    

008000d5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000db:	6a 00                	push   $0x0
  8000dd:	e8 e7 09 00 00       	call   800ac9 <sys_env_destroy>
}
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	c9                   	leave  
  8000e6:	c3                   	ret    

008000e7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 04             	sub    $0x4,%esp
  8000ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000f1:	8b 13                	mov    (%ebx),%edx
  8000f3:	8d 42 01             	lea    0x1(%edx),%eax
  8000f6:	89 03                	mov    %eax,(%ebx)
  8000f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000fb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ff:	3d ff 00 00 00       	cmp    $0xff,%eax
  800104:	75 1a                	jne    800120 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800106:	83 ec 08             	sub    $0x8,%esp
  800109:	68 ff 00 00 00       	push   $0xff
  80010e:	8d 43 08             	lea    0x8(%ebx),%eax
  800111:	50                   	push   %eax
  800112:	e8 75 09 00 00       	call   800a8c <sys_cputs>
		b->idx = 0;
  800117:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80011d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800120:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800124:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800127:	c9                   	leave  
  800128:	c3                   	ret    

00800129 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800132:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800139:	00 00 00 
	b.cnt = 0;
  80013c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800143:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800146:	ff 75 0c             	pushl  0xc(%ebp)
  800149:	ff 75 08             	pushl  0x8(%ebp)
  80014c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800152:	50                   	push   %eax
  800153:	68 e7 00 80 00       	push   $0x8000e7
  800158:	e8 54 01 00 00       	call   8002b1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015d:	83 c4 08             	add    $0x8,%esp
  800160:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800166:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	e8 1a 09 00 00       	call   800a8c <sys_cputs>

	return b.cnt;
}
  800172:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800178:	c9                   	leave  
  800179:	c3                   	ret    

0080017a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800180:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800183:	50                   	push   %eax
  800184:	ff 75 08             	pushl  0x8(%ebp)
  800187:	e8 9d ff ff ff       	call   800129 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    

0080018e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	57                   	push   %edi
  800192:	56                   	push   %esi
  800193:	53                   	push   %ebx
  800194:	83 ec 1c             	sub    $0x1c,%esp
  800197:	89 c7                	mov    %eax,%edi
  800199:	89 d6                	mov    %edx,%esi
  80019b:	8b 45 08             	mov    0x8(%ebp),%eax
  80019e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001af:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001b2:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001b5:	39 d3                	cmp    %edx,%ebx
  8001b7:	72 05                	jb     8001be <printnum+0x30>
  8001b9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001bc:	77 45                	ja     800203 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001be:	83 ec 0c             	sub    $0xc,%esp
  8001c1:	ff 75 18             	pushl  0x18(%ebp)
  8001c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c7:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001ca:	53                   	push   %ebx
  8001cb:	ff 75 10             	pushl  0x10(%ebp)
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001da:	ff 75 d8             	pushl  -0x28(%ebp)
  8001dd:	e8 ee 0f 00 00       	call   8011d0 <__udivdi3>
  8001e2:	83 c4 18             	add    $0x18,%esp
  8001e5:	52                   	push   %edx
  8001e6:	50                   	push   %eax
  8001e7:	89 f2                	mov    %esi,%edx
  8001e9:	89 f8                	mov    %edi,%eax
  8001eb:	e8 9e ff ff ff       	call   80018e <printnum>
  8001f0:	83 c4 20             	add    $0x20,%esp
  8001f3:	eb 18                	jmp    80020d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f5:	83 ec 08             	sub    $0x8,%esp
  8001f8:	56                   	push   %esi
  8001f9:	ff 75 18             	pushl  0x18(%ebp)
  8001fc:	ff d7                	call   *%edi
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	eb 03                	jmp    800206 <printnum+0x78>
  800203:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800206:	83 eb 01             	sub    $0x1,%ebx
  800209:	85 db                	test   %ebx,%ebx
  80020b:	7f e8                	jg     8001f5 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80020d:	83 ec 08             	sub    $0x8,%esp
  800210:	56                   	push   %esi
  800211:	83 ec 04             	sub    $0x4,%esp
  800214:	ff 75 e4             	pushl  -0x1c(%ebp)
  800217:	ff 75 e0             	pushl  -0x20(%ebp)
  80021a:	ff 75 dc             	pushl  -0x24(%ebp)
  80021d:	ff 75 d8             	pushl  -0x28(%ebp)
  800220:	e8 db 10 00 00       	call   801300 <__umoddi3>
  800225:	83 c4 14             	add    $0x14,%esp
  800228:	0f be 80 9a 14 80 00 	movsbl 0x80149a(%eax),%eax
  80022f:	50                   	push   %eax
  800230:	ff d7                	call   *%edi
}
  800232:	83 c4 10             	add    $0x10,%esp
  800235:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800238:	5b                   	pop    %ebx
  800239:	5e                   	pop    %esi
  80023a:	5f                   	pop    %edi
  80023b:	5d                   	pop    %ebp
  80023c:	c3                   	ret    

0080023d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800240:	83 fa 01             	cmp    $0x1,%edx
  800243:	7e 0e                	jle    800253 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800245:	8b 10                	mov    (%eax),%edx
  800247:	8d 4a 08             	lea    0x8(%edx),%ecx
  80024a:	89 08                	mov    %ecx,(%eax)
  80024c:	8b 02                	mov    (%edx),%eax
  80024e:	8b 52 04             	mov    0x4(%edx),%edx
  800251:	eb 22                	jmp    800275 <getuint+0x38>
	else if (lflag)
  800253:	85 d2                	test   %edx,%edx
  800255:	74 10                	je     800267 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800257:	8b 10                	mov    (%eax),%edx
  800259:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025c:	89 08                	mov    %ecx,(%eax)
  80025e:	8b 02                	mov    (%edx),%eax
  800260:	ba 00 00 00 00       	mov    $0x0,%edx
  800265:	eb 0e                	jmp    800275 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800267:	8b 10                	mov    (%eax),%edx
  800269:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026c:	89 08                	mov    %ecx,(%eax)
  80026e:	8b 02                	mov    (%edx),%eax
  800270:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800281:	8b 10                	mov    (%eax),%edx
  800283:	3b 50 04             	cmp    0x4(%eax),%edx
  800286:	73 0a                	jae    800292 <sprintputch+0x1b>
		*b->buf++ = ch;
  800288:	8d 4a 01             	lea    0x1(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 45 08             	mov    0x8(%ebp),%eax
  800290:	88 02                	mov    %al,(%edx)
}
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    

00800294 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80029a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029d:	50                   	push   %eax
  80029e:	ff 75 10             	pushl  0x10(%ebp)
  8002a1:	ff 75 0c             	pushl  0xc(%ebp)
  8002a4:	ff 75 08             	pushl  0x8(%ebp)
  8002a7:	e8 05 00 00 00       	call   8002b1 <vprintfmt>
	va_end(ap);
}
  8002ac:	83 c4 10             	add    $0x10,%esp
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 2c             	sub    $0x2c,%esp
  8002ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8002bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c3:	eb 1d                	jmp    8002e2 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  8002c5:	85 c0                	test   %eax,%eax
  8002c7:	75 0f                	jne    8002d8 <vprintfmt+0x27>
				csa = 0x0700;
  8002c9:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  8002d0:	07 00 00 
				return;
  8002d3:	e9 c4 03 00 00       	jmp    80069c <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  8002d8:	83 ec 08             	sub    $0x8,%esp
  8002db:	53                   	push   %ebx
  8002dc:	50                   	push   %eax
  8002dd:	ff d6                	call   *%esi
  8002df:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e2:	83 c7 01             	add    $0x1,%edi
  8002e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002e9:	83 f8 25             	cmp    $0x25,%eax
  8002ec:	75 d7                	jne    8002c5 <vprintfmt+0x14>
  8002ee:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002f2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002f9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800300:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800307:	ba 00 00 00 00       	mov    $0x0,%edx
  80030c:	eb 07                	jmp    800315 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800311:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800315:	8d 47 01             	lea    0x1(%edi),%eax
  800318:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80031b:	0f b6 07             	movzbl (%edi),%eax
  80031e:	0f b6 c8             	movzbl %al,%ecx
  800321:	83 e8 23             	sub    $0x23,%eax
  800324:	3c 55                	cmp    $0x55,%al
  800326:	0f 87 55 03 00 00    	ja     800681 <vprintfmt+0x3d0>
  80032c:	0f b6 c0             	movzbl %al,%eax
  80032f:	ff 24 85 60 15 80 00 	jmp    *0x801560(,%eax,4)
  800336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800339:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80033d:	eb d6                	jmp    800315 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800342:	b8 00 00 00 00       	mov    $0x0,%eax
  800347:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80034a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80034d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800351:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800354:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800357:	83 fa 09             	cmp    $0x9,%edx
  80035a:	77 39                	ja     800395 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80035c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80035f:	eb e9                	jmp    80034a <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800361:	8b 45 14             	mov    0x14(%ebp),%eax
  800364:	8d 48 04             	lea    0x4(%eax),%ecx
  800367:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80036a:	8b 00                	mov    (%eax),%eax
  80036c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800372:	eb 27                	jmp    80039b <vprintfmt+0xea>
  800374:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800377:	85 c0                	test   %eax,%eax
  800379:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037e:	0f 49 c8             	cmovns %eax,%ecx
  800381:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800387:	eb 8c                	jmp    800315 <vprintfmt+0x64>
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80038c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800393:	eb 80                	jmp    800315 <vprintfmt+0x64>
  800395:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800398:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80039b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80039f:	0f 89 70 ff ff ff    	jns    800315 <vprintfmt+0x64>
				width = precision, precision = -1;
  8003a5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ab:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b2:	e9 5e ff ff ff       	jmp    800315 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003bd:	e9 53 ff ff ff       	jmp    800315 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8d 50 04             	lea    0x4(%eax),%edx
  8003c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cb:	83 ec 08             	sub    $0x8,%esp
  8003ce:	53                   	push   %ebx
  8003cf:	ff 30                	pushl  (%eax)
  8003d1:	ff d6                	call   *%esi
			break;
  8003d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d9:	e9 04 ff ff ff       	jmp    8002e2 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003de:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e1:	8d 50 04             	lea    0x4(%eax),%edx
  8003e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e7:	8b 00                	mov    (%eax),%eax
  8003e9:	99                   	cltd   
  8003ea:	31 d0                	xor    %edx,%eax
  8003ec:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ee:	83 f8 08             	cmp    $0x8,%eax
  8003f1:	7f 0b                	jg     8003fe <vprintfmt+0x14d>
  8003f3:	8b 14 85 c0 16 80 00 	mov    0x8016c0(,%eax,4),%edx
  8003fa:	85 d2                	test   %edx,%edx
  8003fc:	75 18                	jne    800416 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  8003fe:	50                   	push   %eax
  8003ff:	68 b2 14 80 00       	push   $0x8014b2
  800404:	53                   	push   %ebx
  800405:	56                   	push   %esi
  800406:	e8 89 fe ff ff       	call   800294 <printfmt>
  80040b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800411:	e9 cc fe ff ff       	jmp    8002e2 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  800416:	52                   	push   %edx
  800417:	68 bb 14 80 00       	push   $0x8014bb
  80041c:	53                   	push   %ebx
  80041d:	56                   	push   %esi
  80041e:	e8 71 fe ff ff       	call   800294 <printfmt>
  800423:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800429:	e9 b4 fe ff ff       	jmp    8002e2 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800439:	85 ff                	test   %edi,%edi
  80043b:	b8 ab 14 80 00       	mov    $0x8014ab,%eax
  800440:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800443:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800447:	0f 8e 94 00 00 00    	jle    8004e1 <vprintfmt+0x230>
  80044d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800451:	0f 84 98 00 00 00    	je     8004ef <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	ff 75 d0             	pushl  -0x30(%ebp)
  80045d:	57                   	push   %edi
  80045e:	e8 c1 02 00 00       	call   800724 <strnlen>
  800463:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800466:	29 c1                	sub    %eax,%ecx
  800468:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80046b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800472:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800475:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800478:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	eb 0f                	jmp    80048b <vprintfmt+0x1da>
					putch(padc, putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	53                   	push   %ebx
  800480:	ff 75 e0             	pushl  -0x20(%ebp)
  800483:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800485:	83 ef 01             	sub    $0x1,%edi
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	85 ff                	test   %edi,%edi
  80048d:	7f ed                	jg     80047c <vprintfmt+0x1cb>
  80048f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800492:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800495:	85 c9                	test   %ecx,%ecx
  800497:	b8 00 00 00 00       	mov    $0x0,%eax
  80049c:	0f 49 c1             	cmovns %ecx,%eax
  80049f:	29 c1                	sub    %eax,%ecx
  8004a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004aa:	89 cb                	mov    %ecx,%ebx
  8004ac:	eb 4d                	jmp    8004fb <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ae:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b2:	74 1b                	je     8004cf <vprintfmt+0x21e>
  8004b4:	0f be c0             	movsbl %al,%eax
  8004b7:	83 e8 20             	sub    $0x20,%eax
  8004ba:	83 f8 5e             	cmp    $0x5e,%eax
  8004bd:	76 10                	jbe    8004cf <vprintfmt+0x21e>
					putch('?', putdat);
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	ff 75 0c             	pushl  0xc(%ebp)
  8004c5:	6a 3f                	push   $0x3f
  8004c7:	ff 55 08             	call   *0x8(%ebp)
  8004ca:	83 c4 10             	add    $0x10,%esp
  8004cd:	eb 0d                	jmp    8004dc <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	ff 75 0c             	pushl  0xc(%ebp)
  8004d5:	52                   	push   %edx
  8004d6:	ff 55 08             	call   *0x8(%ebp)
  8004d9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004dc:	83 eb 01             	sub    $0x1,%ebx
  8004df:	eb 1a                	jmp    8004fb <vprintfmt+0x24a>
  8004e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ed:	eb 0c                	jmp    8004fb <vprintfmt+0x24a>
  8004ef:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fb:	83 c7 01             	add    $0x1,%edi
  8004fe:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800502:	0f be d0             	movsbl %al,%edx
  800505:	85 d2                	test   %edx,%edx
  800507:	74 23                	je     80052c <vprintfmt+0x27b>
  800509:	85 f6                	test   %esi,%esi
  80050b:	78 a1                	js     8004ae <vprintfmt+0x1fd>
  80050d:	83 ee 01             	sub    $0x1,%esi
  800510:	79 9c                	jns    8004ae <vprintfmt+0x1fd>
  800512:	89 df                	mov    %ebx,%edi
  800514:	8b 75 08             	mov    0x8(%ebp),%esi
  800517:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051a:	eb 18                	jmp    800534 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	53                   	push   %ebx
  800520:	6a 20                	push   $0x20
  800522:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800524:	83 ef 01             	sub    $0x1,%edi
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	eb 08                	jmp    800534 <vprintfmt+0x283>
  80052c:	89 df                	mov    %ebx,%edi
  80052e:	8b 75 08             	mov    0x8(%ebp),%esi
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800534:	85 ff                	test   %edi,%edi
  800536:	7f e4                	jg     80051c <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800538:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053b:	e9 a2 fd ff ff       	jmp    8002e2 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800540:	83 fa 01             	cmp    $0x1,%edx
  800543:	7e 16                	jle    80055b <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 08             	lea    0x8(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 50 04             	mov    0x4(%eax),%edx
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800556:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800559:	eb 32                	jmp    80058d <vprintfmt+0x2dc>
	else if (lflag)
  80055b:	85 d2                	test   %edx,%edx
  80055d:	74 18                	je     800577 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8d 50 04             	lea    0x4(%eax),%edx
  800565:	89 55 14             	mov    %edx,0x14(%ebp)
  800568:	8b 00                	mov    (%eax),%eax
  80056a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056d:	89 c1                	mov    %eax,%ecx
  80056f:	c1 f9 1f             	sar    $0x1f,%ecx
  800572:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800575:	eb 16                	jmp    80058d <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 50 04             	lea    0x4(%eax),%edx
  80057d:	89 55 14             	mov    %edx,0x14(%ebp)
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800585:	89 c1                	mov    %eax,%ecx
  800587:	c1 f9 1f             	sar    $0x1f,%ecx
  80058a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80058d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800590:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800593:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800598:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059c:	79 74                	jns    800612 <vprintfmt+0x361>
				putch('-', putdat);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	53                   	push   %ebx
  8005a2:	6a 2d                	push   $0x2d
  8005a4:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ac:	f7 d8                	neg    %eax
  8005ae:	83 d2 00             	adc    $0x0,%edx
  8005b1:	f7 da                	neg    %edx
  8005b3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005bb:	eb 55                	jmp    800612 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c0:	e8 78 fc ff ff       	call   80023d <getuint>
			base = 10;
  8005c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ca:	eb 46                	jmp    800612 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  8005cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cf:	e8 69 fc ff ff       	call   80023d <getuint>
      base = 8;
  8005d4:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8005d9:	eb 37                	jmp    800612 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	53                   	push   %ebx
  8005df:	6a 30                	push   $0x30
  8005e1:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e3:	83 c4 08             	add    $0x8,%esp
  8005e6:	53                   	push   %ebx
  8005e7:	6a 78                	push   $0x78
  8005e9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 50 04             	lea    0x4(%eax),%edx
  8005f1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005f4:	8b 00                	mov    (%eax),%eax
  8005f6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005fb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005fe:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800603:	eb 0d                	jmp    800612 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800605:	8d 45 14             	lea    0x14(%ebp),%eax
  800608:	e8 30 fc ff ff       	call   80023d <getuint>
			base = 16;
  80060d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800612:	83 ec 0c             	sub    $0xc,%esp
  800615:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800619:	57                   	push   %edi
  80061a:	ff 75 e0             	pushl  -0x20(%ebp)
  80061d:	51                   	push   %ecx
  80061e:	52                   	push   %edx
  80061f:	50                   	push   %eax
  800620:	89 da                	mov    %ebx,%edx
  800622:	89 f0                	mov    %esi,%eax
  800624:	e8 65 fb ff ff       	call   80018e <printnum>
			break;
  800629:	83 c4 20             	add    $0x20,%esp
  80062c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80062f:	e9 ae fc ff ff       	jmp    8002e2 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	51                   	push   %ecx
  800639:	ff d6                	call   *%esi
			break;
  80063b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800641:	e9 9c fc ff ff       	jmp    8002e2 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800646:	83 fa 01             	cmp    $0x1,%edx
  800649:	7e 0d                	jle    800658 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8d 50 08             	lea    0x8(%eax),%edx
  800651:	89 55 14             	mov    %edx,0x14(%ebp)
  800654:	8b 00                	mov    (%eax),%eax
  800656:	eb 1c                	jmp    800674 <vprintfmt+0x3c3>
	else if (lflag)
  800658:	85 d2                	test   %edx,%edx
  80065a:	74 0d                	je     800669 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8d 50 04             	lea    0x4(%eax),%edx
  800662:	89 55 14             	mov    %edx,0x14(%ebp)
  800665:	8b 00                	mov    (%eax),%eax
  800667:	eb 0b                	jmp    800674 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8d 50 04             	lea    0x4(%eax),%edx
  80066f:	89 55 14             	mov    %edx,0x14(%ebp)
  800672:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  800674:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800679:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  80067c:	e9 61 fc ff ff       	jmp    8002e2 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	6a 25                	push   $0x25
  800687:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800689:	83 c4 10             	add    $0x10,%esp
  80068c:	eb 03                	jmp    800691 <vprintfmt+0x3e0>
  80068e:	83 ef 01             	sub    $0x1,%edi
  800691:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800695:	75 f7                	jne    80068e <vprintfmt+0x3dd>
  800697:	e9 46 fc ff ff       	jmp    8002e2 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  80069c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80069f:	5b                   	pop    %ebx
  8006a0:	5e                   	pop    %esi
  8006a1:	5f                   	pop    %edi
  8006a2:	5d                   	pop    %ebp
  8006a3:	c3                   	ret    

008006a4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	83 ec 18             	sub    $0x18,%esp
  8006aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c1:	85 c0                	test   %eax,%eax
  8006c3:	74 26                	je     8006eb <vsnprintf+0x47>
  8006c5:	85 d2                	test   %edx,%edx
  8006c7:	7e 22                	jle    8006eb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c9:	ff 75 14             	pushl  0x14(%ebp)
  8006cc:	ff 75 10             	pushl  0x10(%ebp)
  8006cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d2:	50                   	push   %eax
  8006d3:	68 77 02 80 00       	push   $0x800277
  8006d8:	e8 d4 fb ff ff       	call   8002b1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	eb 05                	jmp    8006f0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006fb:	50                   	push   %eax
  8006fc:	ff 75 10             	pushl  0x10(%ebp)
  8006ff:	ff 75 0c             	pushl  0xc(%ebp)
  800702:	ff 75 08             	pushl  0x8(%ebp)
  800705:	e8 9a ff ff ff       	call   8006a4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80070a:	c9                   	leave  
  80070b:	c3                   	ret    

0080070c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
  800717:	eb 03                	jmp    80071c <strlen+0x10>
		n++;
  800719:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80071c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800720:	75 f7                	jne    800719 <strlen+0xd>
		n++;
	return n;
}
  800722:	5d                   	pop    %ebp
  800723:	c3                   	ret    

00800724 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072d:	ba 00 00 00 00       	mov    $0x0,%edx
  800732:	eb 03                	jmp    800737 <strnlen+0x13>
		n++;
  800734:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800737:	39 c2                	cmp    %eax,%edx
  800739:	74 08                	je     800743 <strnlen+0x1f>
  80073b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80073f:	75 f3                	jne    800734 <strnlen+0x10>
  800741:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	53                   	push   %ebx
  800749:	8b 45 08             	mov    0x8(%ebp),%eax
  80074c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80074f:	89 c2                	mov    %eax,%edx
  800751:	83 c2 01             	add    $0x1,%edx
  800754:	83 c1 01             	add    $0x1,%ecx
  800757:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80075b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80075e:	84 db                	test   %bl,%bl
  800760:	75 ef                	jne    800751 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800762:	5b                   	pop    %ebx
  800763:	5d                   	pop    %ebp
  800764:	c3                   	ret    

00800765 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	53                   	push   %ebx
  800769:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076c:	53                   	push   %ebx
  80076d:	e8 9a ff ff ff       	call   80070c <strlen>
  800772:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800775:	ff 75 0c             	pushl  0xc(%ebp)
  800778:	01 d8                	add    %ebx,%eax
  80077a:	50                   	push   %eax
  80077b:	e8 c5 ff ff ff       	call   800745 <strcpy>
	return dst;
}
  800780:	89 d8                	mov    %ebx,%eax
  800782:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800785:	c9                   	leave  
  800786:	c3                   	ret    

00800787 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	56                   	push   %esi
  80078b:	53                   	push   %ebx
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800792:	89 f3                	mov    %esi,%ebx
  800794:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800797:	89 f2                	mov    %esi,%edx
  800799:	eb 0f                	jmp    8007aa <strncpy+0x23>
		*dst++ = *src;
  80079b:	83 c2 01             	add    $0x1,%edx
  80079e:	0f b6 01             	movzbl (%ecx),%eax
  8007a1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007a7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007aa:	39 da                	cmp    %ebx,%edx
  8007ac:	75 ed                	jne    80079b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ae:	89 f0                	mov    %esi,%eax
  8007b0:	5b                   	pop    %ebx
  8007b1:	5e                   	pop    %esi
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	56                   	push   %esi
  8007b8:	53                   	push   %ebx
  8007b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bf:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c4:	85 d2                	test   %edx,%edx
  8007c6:	74 21                	je     8007e9 <strlcpy+0x35>
  8007c8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007cc:	89 f2                	mov    %esi,%edx
  8007ce:	eb 09                	jmp    8007d9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d0:	83 c2 01             	add    $0x1,%edx
  8007d3:	83 c1 01             	add    $0x1,%ecx
  8007d6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d9:	39 c2                	cmp    %eax,%edx
  8007db:	74 09                	je     8007e6 <strlcpy+0x32>
  8007dd:	0f b6 19             	movzbl (%ecx),%ebx
  8007e0:	84 db                	test   %bl,%bl
  8007e2:	75 ec                	jne    8007d0 <strlcpy+0x1c>
  8007e4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007e6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e9:	29 f0                	sub    %esi,%eax
}
  8007eb:	5b                   	pop    %ebx
  8007ec:	5e                   	pop    %esi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f8:	eb 06                	jmp    800800 <strcmp+0x11>
		p++, q++;
  8007fa:	83 c1 01             	add    $0x1,%ecx
  8007fd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800800:	0f b6 01             	movzbl (%ecx),%eax
  800803:	84 c0                	test   %al,%al
  800805:	74 04                	je     80080b <strcmp+0x1c>
  800807:	3a 02                	cmp    (%edx),%al
  800809:	74 ef                	je     8007fa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080b:	0f b6 c0             	movzbl %al,%eax
  80080e:	0f b6 12             	movzbl (%edx),%edx
  800811:	29 d0                	sub    %edx,%eax
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081f:	89 c3                	mov    %eax,%ebx
  800821:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800824:	eb 06                	jmp    80082c <strncmp+0x17>
		n--, p++, q++;
  800826:	83 c0 01             	add    $0x1,%eax
  800829:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80082c:	39 d8                	cmp    %ebx,%eax
  80082e:	74 15                	je     800845 <strncmp+0x30>
  800830:	0f b6 08             	movzbl (%eax),%ecx
  800833:	84 c9                	test   %cl,%cl
  800835:	74 04                	je     80083b <strncmp+0x26>
  800837:	3a 0a                	cmp    (%edx),%cl
  800839:	74 eb                	je     800826 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083b:	0f b6 00             	movzbl (%eax),%eax
  80083e:	0f b6 12             	movzbl (%edx),%edx
  800841:	29 d0                	sub    %edx,%eax
  800843:	eb 05                	jmp    80084a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80084a:	5b                   	pop    %ebx
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800857:	eb 07                	jmp    800860 <strchr+0x13>
		if (*s == c)
  800859:	38 ca                	cmp    %cl,%dl
  80085b:	74 0f                	je     80086c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80085d:	83 c0 01             	add    $0x1,%eax
  800860:	0f b6 10             	movzbl (%eax),%edx
  800863:	84 d2                	test   %dl,%dl
  800865:	75 f2                	jne    800859 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800867:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800878:	eb 03                	jmp    80087d <strfind+0xf>
  80087a:	83 c0 01             	add    $0x1,%eax
  80087d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800880:	38 ca                	cmp    %cl,%dl
  800882:	74 04                	je     800888 <strfind+0x1a>
  800884:	84 d2                	test   %dl,%dl
  800886:	75 f2                	jne    80087a <strfind+0xc>
			break;
	return (char *) s;
}
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	57                   	push   %edi
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
  800890:	8b 7d 08             	mov    0x8(%ebp),%edi
  800893:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800896:	85 c9                	test   %ecx,%ecx
  800898:	74 36                	je     8008d0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80089a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a0:	75 28                	jne    8008ca <memset+0x40>
  8008a2:	f6 c1 03             	test   $0x3,%cl
  8008a5:	75 23                	jne    8008ca <memset+0x40>
		c &= 0xFF;
  8008a7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ab:	89 d3                	mov    %edx,%ebx
  8008ad:	c1 e3 08             	shl    $0x8,%ebx
  8008b0:	89 d6                	mov    %edx,%esi
  8008b2:	c1 e6 18             	shl    $0x18,%esi
  8008b5:	89 d0                	mov    %edx,%eax
  8008b7:	c1 e0 10             	shl    $0x10,%eax
  8008ba:	09 f0                	or     %esi,%eax
  8008bc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008be:	89 d8                	mov    %ebx,%eax
  8008c0:	09 d0                	or     %edx,%eax
  8008c2:	c1 e9 02             	shr    $0x2,%ecx
  8008c5:	fc                   	cld    
  8008c6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c8:	eb 06                	jmp    8008d0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cd:	fc                   	cld    
  8008ce:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d0:	89 f8                	mov    %edi,%eax
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5f                   	pop    %edi
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	57                   	push   %edi
  8008db:	56                   	push   %esi
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e5:	39 c6                	cmp    %eax,%esi
  8008e7:	73 35                	jae    80091e <memmove+0x47>
  8008e9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ec:	39 d0                	cmp    %edx,%eax
  8008ee:	73 2e                	jae    80091e <memmove+0x47>
		s += n;
		d += n;
  8008f0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f3:	89 d6                	mov    %edx,%esi
  8008f5:	09 fe                	or     %edi,%esi
  8008f7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008fd:	75 13                	jne    800912 <memmove+0x3b>
  8008ff:	f6 c1 03             	test   $0x3,%cl
  800902:	75 0e                	jne    800912 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800904:	83 ef 04             	sub    $0x4,%edi
  800907:	8d 72 fc             	lea    -0x4(%edx),%esi
  80090a:	c1 e9 02             	shr    $0x2,%ecx
  80090d:	fd                   	std    
  80090e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800910:	eb 09                	jmp    80091b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800912:	83 ef 01             	sub    $0x1,%edi
  800915:	8d 72 ff             	lea    -0x1(%edx),%esi
  800918:	fd                   	std    
  800919:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80091b:	fc                   	cld    
  80091c:	eb 1d                	jmp    80093b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091e:	89 f2                	mov    %esi,%edx
  800920:	09 c2                	or     %eax,%edx
  800922:	f6 c2 03             	test   $0x3,%dl
  800925:	75 0f                	jne    800936 <memmove+0x5f>
  800927:	f6 c1 03             	test   $0x3,%cl
  80092a:	75 0a                	jne    800936 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80092c:	c1 e9 02             	shr    $0x2,%ecx
  80092f:	89 c7                	mov    %eax,%edi
  800931:	fc                   	cld    
  800932:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800934:	eb 05                	jmp    80093b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800936:	89 c7                	mov    %eax,%edi
  800938:	fc                   	cld    
  800939:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80093b:	5e                   	pop    %esi
  80093c:	5f                   	pop    %edi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800942:	ff 75 10             	pushl  0x10(%ebp)
  800945:	ff 75 0c             	pushl  0xc(%ebp)
  800948:	ff 75 08             	pushl  0x8(%ebp)
  80094b:	e8 87 ff ff ff       	call   8008d7 <memmove>
}
  800950:	c9                   	leave  
  800951:	c3                   	ret    

00800952 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095d:	89 c6                	mov    %eax,%esi
  80095f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800962:	eb 1a                	jmp    80097e <memcmp+0x2c>
		if (*s1 != *s2)
  800964:	0f b6 08             	movzbl (%eax),%ecx
  800967:	0f b6 1a             	movzbl (%edx),%ebx
  80096a:	38 d9                	cmp    %bl,%cl
  80096c:	74 0a                	je     800978 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80096e:	0f b6 c1             	movzbl %cl,%eax
  800971:	0f b6 db             	movzbl %bl,%ebx
  800974:	29 d8                	sub    %ebx,%eax
  800976:	eb 0f                	jmp    800987 <memcmp+0x35>
		s1++, s2++;
  800978:	83 c0 01             	add    $0x1,%eax
  80097b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097e:	39 f0                	cmp    %esi,%eax
  800980:	75 e2                	jne    800964 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800982:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800992:	89 c1                	mov    %eax,%ecx
  800994:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800997:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099b:	eb 0a                	jmp    8009a7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80099d:	0f b6 10             	movzbl (%eax),%edx
  8009a0:	39 da                	cmp    %ebx,%edx
  8009a2:	74 07                	je     8009ab <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a4:	83 c0 01             	add    $0x1,%eax
  8009a7:	39 c8                	cmp    %ecx,%eax
  8009a9:	72 f2                	jb     80099d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ab:	5b                   	pop    %ebx
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	57                   	push   %edi
  8009b2:	56                   	push   %esi
  8009b3:	53                   	push   %ebx
  8009b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ba:	eb 03                	jmp    8009bf <strtol+0x11>
		s++;
  8009bc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009bf:	0f b6 01             	movzbl (%ecx),%eax
  8009c2:	3c 20                	cmp    $0x20,%al
  8009c4:	74 f6                	je     8009bc <strtol+0xe>
  8009c6:	3c 09                	cmp    $0x9,%al
  8009c8:	74 f2                	je     8009bc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ca:	3c 2b                	cmp    $0x2b,%al
  8009cc:	75 0a                	jne    8009d8 <strtol+0x2a>
		s++;
  8009ce:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d6:	eb 11                	jmp    8009e9 <strtol+0x3b>
  8009d8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009dd:	3c 2d                	cmp    $0x2d,%al
  8009df:	75 08                	jne    8009e9 <strtol+0x3b>
		s++, neg = 1;
  8009e1:	83 c1 01             	add    $0x1,%ecx
  8009e4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ef:	75 15                	jne    800a06 <strtol+0x58>
  8009f1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f4:	75 10                	jne    800a06 <strtol+0x58>
  8009f6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009fa:	75 7c                	jne    800a78 <strtol+0xca>
		s += 2, base = 16;
  8009fc:	83 c1 02             	add    $0x2,%ecx
  8009ff:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a04:	eb 16                	jmp    800a1c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a06:	85 db                	test   %ebx,%ebx
  800a08:	75 12                	jne    800a1c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a0a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a0f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a12:	75 08                	jne    800a1c <strtol+0x6e>
		s++, base = 8;
  800a14:	83 c1 01             	add    $0x1,%ecx
  800a17:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a21:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a24:	0f b6 11             	movzbl (%ecx),%edx
  800a27:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a2a:	89 f3                	mov    %esi,%ebx
  800a2c:	80 fb 09             	cmp    $0x9,%bl
  800a2f:	77 08                	ja     800a39 <strtol+0x8b>
			dig = *s - '0';
  800a31:	0f be d2             	movsbl %dl,%edx
  800a34:	83 ea 30             	sub    $0x30,%edx
  800a37:	eb 22                	jmp    800a5b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a39:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a3c:	89 f3                	mov    %esi,%ebx
  800a3e:	80 fb 19             	cmp    $0x19,%bl
  800a41:	77 08                	ja     800a4b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a43:	0f be d2             	movsbl %dl,%edx
  800a46:	83 ea 57             	sub    $0x57,%edx
  800a49:	eb 10                	jmp    800a5b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a4b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a4e:	89 f3                	mov    %esi,%ebx
  800a50:	80 fb 19             	cmp    $0x19,%bl
  800a53:	77 16                	ja     800a6b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a55:	0f be d2             	movsbl %dl,%edx
  800a58:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a5b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a5e:	7d 0b                	jge    800a6b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a60:	83 c1 01             	add    $0x1,%ecx
  800a63:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a67:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a69:	eb b9                	jmp    800a24 <strtol+0x76>

	if (endptr)
  800a6b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6f:	74 0d                	je     800a7e <strtol+0xd0>
		*endptr = (char *) s;
  800a71:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a74:	89 0e                	mov    %ecx,(%esi)
  800a76:	eb 06                	jmp    800a7e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a78:	85 db                	test   %ebx,%ebx
  800a7a:	74 98                	je     800a14 <strtol+0x66>
  800a7c:	eb 9e                	jmp    800a1c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a7e:	89 c2                	mov    %eax,%edx
  800a80:	f7 da                	neg    %edx
  800a82:	85 ff                	test   %edi,%edi
  800a84:	0f 45 c2             	cmovne %edx,%eax
}
  800a87:	5b                   	pop    %ebx
  800a88:	5e                   	pop    %esi
  800a89:	5f                   	pop    %edi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	57                   	push   %edi
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
  800a97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9d:	89 c3                	mov    %eax,%ebx
  800a9f:	89 c7                	mov    %eax,%edi
  800aa1:	89 c6                	mov    %eax,%esi
  800aa3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <sys_cgetc>:

int
sys_cgetc(void)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aba:	89 d1                	mov    %edx,%ecx
  800abc:	89 d3                	mov    %edx,%ebx
  800abe:	89 d7                	mov    %edx,%edi
  800ac0:	89 d6                	mov    %edx,%esi
  800ac2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	57                   	push   %edi
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
  800acf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad7:	b8 03 00 00 00       	mov    $0x3,%eax
  800adc:	8b 55 08             	mov    0x8(%ebp),%edx
  800adf:	89 cb                	mov    %ecx,%ebx
  800ae1:	89 cf                	mov    %ecx,%edi
  800ae3:	89 ce                	mov    %ecx,%esi
  800ae5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ae7:	85 c0                	test   %eax,%eax
  800ae9:	7e 17                	jle    800b02 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aeb:	83 ec 0c             	sub    $0xc,%esp
  800aee:	50                   	push   %eax
  800aef:	6a 03                	push   $0x3
  800af1:	68 e4 16 80 00       	push   $0x8016e4
  800af6:	6a 23                	push   $0x23
  800af8:	68 01 17 80 00       	push   $0x801701
  800afd:	e8 f5 05 00 00       	call   8010f7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 02 00 00 00       	mov    $0x2,%eax
  800b1a:	89 d1                	mov    %edx,%ecx
  800b1c:	89 d3                	mov    %edx,%ebx
  800b1e:	89 d7                	mov    %edx,%edi
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <sys_yield>:

void
sys_yield(void)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b34:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b39:	89 d1                	mov    %edx,%ecx
  800b3b:	89 d3                	mov    %edx,%ebx
  800b3d:	89 d7                	mov    %edx,%edi
  800b3f:	89 d6                	mov    %edx,%esi
  800b41:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5f                   	pop    %edi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b51:	be 00 00 00 00       	mov    $0x0,%esi
  800b56:	b8 04 00 00 00       	mov    $0x4,%eax
  800b5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b64:	89 f7                	mov    %esi,%edi
  800b66:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b68:	85 c0                	test   %eax,%eax
  800b6a:	7e 17                	jle    800b83 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6c:	83 ec 0c             	sub    $0xc,%esp
  800b6f:	50                   	push   %eax
  800b70:	6a 04                	push   $0x4
  800b72:	68 e4 16 80 00       	push   $0x8016e4
  800b77:	6a 23                	push   $0x23
  800b79:	68 01 17 80 00       	push   $0x801701
  800b7e:	e8 74 05 00 00       	call   8010f7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b94:	b8 05 00 00 00       	mov    $0x5,%eax
  800b99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba5:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800baa:	85 c0                	test   %eax,%eax
  800bac:	7e 17                	jle    800bc5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bae:	83 ec 0c             	sub    $0xc,%esp
  800bb1:	50                   	push   %eax
  800bb2:	6a 05                	push   $0x5
  800bb4:	68 e4 16 80 00       	push   $0x8016e4
  800bb9:	6a 23                	push   $0x23
  800bbb:	68 01 17 80 00       	push   $0x801701
  800bc0:	e8 32 05 00 00       	call   8010f7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bdb:	b8 06 00 00 00       	mov    $0x6,%eax
  800be0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be3:	8b 55 08             	mov    0x8(%ebp),%edx
  800be6:	89 df                	mov    %ebx,%edi
  800be8:	89 de                	mov    %ebx,%esi
  800bea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bec:	85 c0                	test   %eax,%eax
  800bee:	7e 17                	jle    800c07 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf0:	83 ec 0c             	sub    $0xc,%esp
  800bf3:	50                   	push   %eax
  800bf4:	6a 06                	push   $0x6
  800bf6:	68 e4 16 80 00       	push   $0x8016e4
  800bfb:	6a 23                	push   $0x23
  800bfd:	68 01 17 80 00       	push   $0x801701
  800c02:	e8 f0 04 00 00       	call   8010f7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c25:	8b 55 08             	mov    0x8(%ebp),%edx
  800c28:	89 df                	mov    %ebx,%edi
  800c2a:	89 de                	mov    %ebx,%esi
  800c2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2e:	85 c0                	test   %eax,%eax
  800c30:	7e 17                	jle    800c49 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c32:	83 ec 0c             	sub    $0xc,%esp
  800c35:	50                   	push   %eax
  800c36:	6a 08                	push   $0x8
  800c38:	68 e4 16 80 00       	push   $0x8016e4
  800c3d:	6a 23                	push   $0x23
  800c3f:	68 01 17 80 00       	push   $0x801701
  800c44:	e8 ae 04 00 00       	call   8010f7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6a:	89 df                	mov    %ebx,%edi
  800c6c:	89 de                	mov    %ebx,%esi
  800c6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c70:	85 c0                	test   %eax,%eax
  800c72:	7e 17                	jle    800c8b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c74:	83 ec 0c             	sub    $0xc,%esp
  800c77:	50                   	push   %eax
  800c78:	6a 09                	push   $0x9
  800c7a:	68 e4 16 80 00       	push   $0x8016e4
  800c7f:	6a 23                	push   $0x23
  800c81:	68 01 17 80 00       	push   $0x801701
  800c86:	e8 6c 04 00 00       	call   8010f7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c99:	be 00 00 00 00       	mov    $0x0,%esi
  800c9e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cac:	8b 7d 14             	mov    0x14(%ebp),%edi
  800caf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	89 cb                	mov    %ecx,%ebx
  800cce:	89 cf                	mov    %ecx,%edi
  800cd0:	89 ce                	mov    %ecx,%esi
  800cd2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	7e 17                	jle    800cef <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd8:	83 ec 0c             	sub    $0xc,%esp
  800cdb:	50                   	push   %eax
  800cdc:	6a 0c                	push   $0xc
  800cde:	68 e4 16 80 00       	push   $0x8016e4
  800ce3:	6a 23                	push   $0x23
  800ce5:	68 01 17 80 00       	push   $0x801701
  800cea:	e8 08 04 00 00       	call   8010f7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <sys_change_pr>:

int
sys_change_pr(int pr)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d02:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	89 cb                	mov    %ecx,%ebx
  800d0c:	89 cf                	mov    %ecx,%edi
  800d0e:	89 ce                	mov    %ecx,%esi
  800d10:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	53                   	push   %ebx
  800d1b:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
	// cprintf("1\n");
	void *addr = (void*) (pn*PGSIZE);
  800d1e:	89 d3                	mov    %edx,%ebx
  800d20:	c1 e3 0c             	shl    $0xc,%ebx
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800d23:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d2a:	f6 c1 02             	test   $0x2,%cl
  800d2d:	75 0c                	jne    800d3b <duppage+0x24>
  800d2f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d36:	f6 c6 08             	test   $0x8,%dh
  800d39:	74 5b                	je     800d96 <duppage+0x7f>
		if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800d3b:	83 ec 0c             	sub    $0xc,%esp
  800d3e:	68 05 08 00 00       	push   $0x805
  800d43:	53                   	push   %ebx
  800d44:	50                   	push   %eax
  800d45:	53                   	push   %ebx
  800d46:	6a 00                	push   $0x0
  800d48:	e8 3e fe ff ff       	call   800b8b <sys_page_map>
  800d4d:	83 c4 20             	add    $0x20,%esp
  800d50:	85 c0                	test   %eax,%eax
  800d52:	79 14                	jns    800d68 <duppage+0x51>
			panic("2");
  800d54:	83 ec 04             	sub    $0x4,%esp
  800d57:	68 0f 17 80 00       	push   $0x80170f
  800d5c:	6a 49                	push   $0x49
  800d5e:	68 11 17 80 00       	push   $0x801711
  800d63:	e8 8f 03 00 00       	call   8010f7 <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800d68:	83 ec 0c             	sub    $0xc,%esp
  800d6b:	68 05 08 00 00       	push   $0x805
  800d70:	53                   	push   %ebx
  800d71:	6a 00                	push   $0x0
  800d73:	53                   	push   %ebx
  800d74:	6a 00                	push   $0x0
  800d76:	e8 10 fe ff ff       	call   800b8b <sys_page_map>
  800d7b:	83 c4 20             	add    $0x20,%esp
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	79 26                	jns    800da8 <duppage+0x91>
			panic("3");
  800d82:	83 ec 04             	sub    $0x4,%esp
  800d85:	68 1c 17 80 00       	push   $0x80171c
  800d8a:	6a 4b                	push   $0x4b
  800d8c:	68 11 17 80 00       	push   $0x801711
  800d91:	e8 61 03 00 00       	call   8010f7 <_panic>
	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800d96:	83 ec 0c             	sub    $0xc,%esp
  800d99:	6a 05                	push   $0x5
  800d9b:	53                   	push   %ebx
  800d9c:	50                   	push   %eax
  800d9d:	53                   	push   %ebx
  800d9e:	6a 00                	push   $0x0
  800da0:	e8 e6 fd ff ff       	call   800b8b <sys_page_map>
  800da5:	83 c4 20             	add    $0x20,%esp
	// cprintf("2\n");
	return 0;
	panic("duppage not implemented");
}
  800da8:	b8 00 00 00 00       	mov    $0x0,%eax
  800dad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800db0:	c9                   	leave  
  800db1:	c3                   	ret    

00800db2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	53                   	push   %ebx
  800db6:	83 ec 04             	sub    $0x4,%esp
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
	// panic("pgfault");
	void *addr = (void *) utf->utf_fault_va;
  800dbc:	8b 02                	mov    (%edx),%eax
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800dbe:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800dc2:	74 2e                	je     800df2 <pgfault+0x40>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800dc4:	89 c2                	mov    %eax,%edx
  800dc6:	c1 ea 16             	shr    $0x16,%edx
  800dc9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dd0:	f6 c2 01             	test   $0x1,%dl
  800dd3:	74 1d                	je     800df2 <pgfault+0x40>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800dd5:	89 c2                	mov    %eax,%edx
  800dd7:	c1 ea 0c             	shr    $0xc,%edx
  800dda:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800de1:	f6 c1 01             	test   $0x1,%cl
  800de4:	74 0c                	je     800df2 <pgfault+0x40>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800de6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800ded:	f6 c6 08             	test   $0x8,%dh
  800df0:	75 14                	jne    800e06 <pgfault+0x54>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800df2:	83 ec 04             	sub    $0x4,%esp
  800df5:	68 1e 17 80 00       	push   $0x80171e
  800dfa:	6a 20                	push   $0x20
  800dfc:	68 11 17 80 00       	push   $0x801711
  800e01:	e8 f1 02 00 00       	call   8010f7 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800e06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e0b:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800e0d:	83 ec 04             	sub    $0x4,%esp
  800e10:	6a 07                	push   $0x7
  800e12:	68 00 f0 7f 00       	push   $0x7ff000
  800e17:	6a 00                	push   $0x0
  800e19:	e8 2a fd ff ff       	call   800b48 <sys_page_alloc>
  800e1e:	83 c4 10             	add    $0x10,%esp
  800e21:	85 c0                	test   %eax,%eax
  800e23:	79 14                	jns    800e39 <pgfault+0x87>
		panic("sys_page_alloc");
  800e25:	83 ec 04             	sub    $0x4,%esp
  800e28:	68 30 17 80 00       	push   $0x801730
  800e2d:	6a 2c                	push   $0x2c
  800e2f:	68 11 17 80 00       	push   $0x801711
  800e34:	e8 be 02 00 00       	call   8010f7 <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  800e39:	83 ec 04             	sub    $0x4,%esp
  800e3c:	68 00 10 00 00       	push   $0x1000
  800e41:	53                   	push   %ebx
  800e42:	68 00 f0 7f 00       	push   $0x7ff000
  800e47:	e8 f3 fa ff ff       	call   80093f <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800e4c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e53:	53                   	push   %ebx
  800e54:	6a 00                	push   $0x0
  800e56:	68 00 f0 7f 00       	push   $0x7ff000
  800e5b:	6a 00                	push   $0x0
  800e5d:	e8 29 fd ff ff       	call   800b8b <sys_page_map>
  800e62:	83 c4 20             	add    $0x20,%esp
  800e65:	85 c0                	test   %eax,%eax
  800e67:	79 14                	jns    800e7d <pgfault+0xcb>
		panic("sys_page_map");
  800e69:	83 ec 04             	sub    $0x4,%esp
  800e6c:	68 3f 17 80 00       	push   $0x80173f
  800e71:	6a 2f                	push   $0x2f
  800e73:	68 11 17 80 00       	push   $0x801711
  800e78:	e8 7a 02 00 00       	call   8010f7 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800e7d:	83 ec 08             	sub    $0x8,%esp
  800e80:	68 00 f0 7f 00       	push   $0x7ff000
  800e85:	6a 00                	push   $0x0
  800e87:	e8 41 fd ff ff       	call   800bcd <sys_page_unmap>
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	79 14                	jns    800ea7 <pgfault+0xf5>
		panic("sys_page_unmap");
  800e93:	83 ec 04             	sub    $0x4,%esp
  800e96:	68 4c 17 80 00       	push   $0x80174c
  800e9b:	6a 31                	push   $0x31
  800e9d:	68 11 17 80 00       	push   $0x801711
  800ea2:	e8 50 02 00 00       	call   8010f7 <_panic>
	return;
}
  800ea7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    

00800eac <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	57                   	push   %edi
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
  800eb2:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800eb5:	68 b2 0d 80 00       	push   $0x800db2
  800eba:	e8 7e 02 00 00       	call   80113d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ebf:	b8 07 00 00 00       	mov    $0x7,%eax
  800ec4:	cd 30                	int    $0x30

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800ec6:	83 c4 10             	add    $0x10,%esp
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	75 21                	jne    800eee <fork+0x42>
		// panic("child");
		thisenv = &envs[ENVX(sys_getenvid())];
  800ecd:	e8 38 fc ff ff       	call   800b0a <sys_getenvid>
  800ed2:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed7:	c1 e0 07             	shl    $0x7,%eax
  800eda:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800edf:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800ee4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee9:	e9 c6 00 00 00       	jmp    800fb4 <fork+0x108>
  800eee:	89 c6                	mov    %eax,%esi
  800ef0:	89 c7                	mov    %eax,%edi
	}
	// cprintf("sys_exofork: %x\n", envid);
	if (envid < 0)
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	79 12                	jns    800f08 <fork+0x5c>
		panic("sys_exofork: %e", envid);
  800ef6:	50                   	push   %eax
  800ef7:	68 5b 17 80 00       	push   $0x80175b
  800efc:	6a 71                	push   $0x71
  800efe:	68 11 17 80 00       	push   $0x801711
  800f03:	e8 ef 01 00 00       	call   8010f7 <_panic>
  800f08:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800f0d:	89 d8                	mov    %ebx,%eax
  800f0f:	c1 e8 16             	shr    $0x16,%eax
  800f12:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f19:	a8 01                	test   $0x1,%al
  800f1b:	74 22                	je     800f3f <fork+0x93>
  800f1d:	89 da                	mov    %ebx,%edx
  800f1f:	c1 ea 0c             	shr    $0xc,%edx
  800f22:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f29:	a8 01                	test   $0x1,%al
  800f2b:	74 12                	je     800f3f <fork+0x93>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800f2d:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f34:	a8 04                	test   $0x4,%al
  800f36:	74 07                	je     800f3f <fork+0x93>
			// cprintf("envid: %x, PGNUM: %x, addr: %x\n", envid, PGNUM(addr), addr);
			// if (addr!=0x802000) {
			duppage(envid, PGNUM(addr));
  800f38:	89 f8                	mov    %edi,%eax
  800f3a:	e8 d8 fd ff ff       	call   800d17 <duppage>
	}
	// cprintf("sys_exofork: %x\n", envid);
	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f3f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f45:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f4b:	75 c0                	jne    800f0d <fork+0x61>
			// cprintf("%x\n", uvpt[PGNUM(addr)]);
		}
	// panic("faint");


	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800f4d:	83 ec 04             	sub    $0x4,%esp
  800f50:	6a 07                	push   $0x7
  800f52:	68 00 f0 bf ee       	push   $0xeebff000
  800f57:	56                   	push   %esi
  800f58:	e8 eb fb ff ff       	call   800b48 <sys_page_alloc>
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	79 17                	jns    800f7b <fork+0xcf>
		panic("1");
  800f64:	83 ec 04             	sub    $0x4,%esp
  800f67:	68 6b 17 80 00       	push   $0x80176b
  800f6c:	68 82 00 00 00       	push   $0x82
  800f71:	68 11 17 80 00       	push   $0x801711
  800f76:	e8 7c 01 00 00       	call   8010f7 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800f7b:	83 ec 08             	sub    $0x8,%esp
  800f7e:	68 ac 11 80 00       	push   $0x8011ac
  800f83:	56                   	push   %esi
  800f84:	e8 c8 fc ff ff       	call   800c51 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  800f89:	83 c4 08             	add    $0x8,%esp
  800f8c:	6a 02                	push   $0x2
  800f8e:	56                   	push   %esi
  800f8f:	e8 7b fc ff ff       	call   800c0f <sys_env_set_status>
  800f94:	83 c4 10             	add    $0x10,%esp
  800f97:	85 c0                	test   %eax,%eax
  800f99:	79 17                	jns    800fb2 <fork+0x106>
		panic("sys_env_set_status");
  800f9b:	83 ec 04             	sub    $0x4,%esp
  800f9e:	68 6d 17 80 00       	push   $0x80176d
  800fa3:	68 87 00 00 00       	push   $0x87
  800fa8:	68 11 17 80 00       	push   $0x801711
  800fad:	e8 45 01 00 00       	call   8010f7 <_panic>

	return envid;
  800fb2:	89 f0                	mov    %esi,%eax
	panic("fork not implemented");
}
  800fb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb7:	5b                   	pop    %ebx
  800fb8:	5e                   	pop    %esi
  800fb9:	5f                   	pop    %edi
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <pfork>:

envid_t
pfork(int pr)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	57                   	push   %edi
  800fc0:	56                   	push   %esi
  800fc1:	53                   	push   %ebx
  800fc2:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800fc5:	68 b2 0d 80 00       	push   $0x800db2
  800fca:	e8 6e 01 00 00       	call   80113d <set_pgfault_handler>
  800fcf:	b8 07 00 00 00       	mov    $0x7,%eax
  800fd4:	cd 30                	int    $0x30

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800fd6:	83 c4 10             	add    $0x10,%esp
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	75 2f                	jne    80100c <pfork+0x50>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fdd:	e8 28 fb ff ff       	call   800b0a <sys_getenvid>
  800fe2:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fe7:	c1 e0 07             	shl    $0x7,%eax
  800fea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fef:	a3 04 20 80 00       	mov    %eax,0x802004
		sys_change_pr(pr);
  800ff4:	83 ec 0c             	sub    $0xc,%esp
  800ff7:	ff 75 08             	pushl  0x8(%ebp)
  800ffa:	e8 f8 fc ff ff       	call   800cf7 <sys_change_pr>
		return 0;
  800fff:	83 c4 10             	add    $0x10,%esp
  801002:	b8 00 00 00 00       	mov    $0x0,%eax
  801007:	e9 c9 00 00 00       	jmp    8010d5 <pfork+0x119>
  80100c:	89 c6                	mov    %eax,%esi
  80100e:	89 c7                	mov    %eax,%edi
	}

	if (envid < 0)
  801010:	85 c0                	test   %eax,%eax
  801012:	79 15                	jns    801029 <pfork+0x6d>
		panic("sys_exofork: %e", envid);
  801014:	50                   	push   %eax
  801015:	68 5b 17 80 00       	push   $0x80175b
  80101a:	68 9c 00 00 00       	push   $0x9c
  80101f:	68 11 17 80 00       	push   $0x801711
  801024:	e8 ce 00 00 00       	call   8010f7 <_panic>
  801029:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  80102e:	89 d8                	mov    %ebx,%eax
  801030:	c1 e8 16             	shr    $0x16,%eax
  801033:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80103a:	a8 01                	test   $0x1,%al
  80103c:	74 22                	je     801060 <pfork+0xa4>
  80103e:	89 da                	mov    %ebx,%edx
  801040:	c1 ea 0c             	shr    $0xc,%edx
  801043:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80104a:	a8 01                	test   $0x1,%al
  80104c:	74 12                	je     801060 <pfork+0xa4>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  80104e:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801055:	a8 04                	test   $0x4,%al
  801057:	74 07                	je     801060 <pfork+0xa4>
			duppage(envid, PGNUM(addr));
  801059:	89 f8                	mov    %edi,%eax
  80105b:	e8 b7 fc ff ff       	call   800d17 <duppage>
	}

	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801060:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801066:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80106c:	75 c0                	jne    80102e <pfork+0x72>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80106e:	83 ec 04             	sub    $0x4,%esp
  801071:	6a 07                	push   $0x7
  801073:	68 00 f0 bf ee       	push   $0xeebff000
  801078:	56                   	push   %esi
  801079:	e8 ca fa ff ff       	call   800b48 <sys_page_alloc>
  80107e:	83 c4 10             	add    $0x10,%esp
  801081:	85 c0                	test   %eax,%eax
  801083:	79 17                	jns    80109c <pfork+0xe0>
		panic("1");
  801085:	83 ec 04             	sub    $0x4,%esp
  801088:	68 6b 17 80 00       	push   $0x80176b
  80108d:	68 a5 00 00 00       	push   $0xa5
  801092:	68 11 17 80 00       	push   $0x801711
  801097:	e8 5b 00 00 00       	call   8010f7 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80109c:	83 ec 08             	sub    $0x8,%esp
  80109f:	68 ac 11 80 00       	push   $0x8011ac
  8010a4:	56                   	push   %esi
  8010a5:	e8 a7 fb ff ff       	call   800c51 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8010aa:	83 c4 08             	add    $0x8,%esp
  8010ad:	6a 02                	push   $0x2
  8010af:	56                   	push   %esi
  8010b0:	e8 5a fb ff ff       	call   800c0f <sys_env_set_status>
  8010b5:	83 c4 10             	add    $0x10,%esp
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	79 17                	jns    8010d3 <pfork+0x117>
		panic("sys_env_set_status");
  8010bc:	83 ec 04             	sub    $0x4,%esp
  8010bf:	68 6d 17 80 00       	push   $0x80176d
  8010c4:	68 aa 00 00 00       	push   $0xaa
  8010c9:	68 11 17 80 00       	push   $0x801711
  8010ce:	e8 24 00 00 00       	call   8010f7 <_panic>

	return envid;
  8010d3:	89 f0                	mov    %esi,%eax
	panic("fork not implemented");
}
  8010d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5f                   	pop    %edi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <sfork>:

// Challenge!
int
sfork(void)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010e3:	68 80 17 80 00       	push   $0x801780
  8010e8:	68 b4 00 00 00       	push   $0xb4
  8010ed:	68 11 17 80 00       	push   $0x801711
  8010f2:	e8 00 00 00 00       	call   8010f7 <_panic>

008010f7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	56                   	push   %esi
  8010fb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010fc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010ff:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801105:	e8 00 fa ff ff       	call   800b0a <sys_getenvid>
  80110a:	83 ec 0c             	sub    $0xc,%esp
  80110d:	ff 75 0c             	pushl  0xc(%ebp)
  801110:	ff 75 08             	pushl  0x8(%ebp)
  801113:	56                   	push   %esi
  801114:	50                   	push   %eax
  801115:	68 98 17 80 00       	push   $0x801798
  80111a:	e8 5b f0 ff ff       	call   80017a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80111f:	83 c4 18             	add    $0x18,%esp
  801122:	53                   	push   %ebx
  801123:	ff 75 10             	pushl  0x10(%ebp)
  801126:	e8 fe ef ff ff       	call   800129 <vcprintf>
	cprintf("\n");
  80112b:	c7 04 24 8e 14 80 00 	movl   $0x80148e,(%esp)
  801132:	e8 43 f0 ff ff       	call   80017a <cprintf>
  801137:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80113a:	cc                   	int3   
  80113b:	eb fd                	jmp    80113a <_panic+0x43>

0080113d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	83 ec 08             	sub    $0x8,%esp
	// int r;

	if (_pgfault_handler == 0) {
  801143:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  80114a:	75 2c                	jne    801178 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  80114c:	83 ec 04             	sub    $0x4,%esp
  80114f:	6a 07                	push   $0x7
  801151:	68 00 f0 bf ee       	push   $0xeebff000
  801156:	6a 00                	push   $0x0
  801158:	e8 eb f9 ff ff       	call   800b48 <sys_page_alloc>
  80115d:	83 c4 10             	add    $0x10,%esp
  801160:	85 c0                	test   %eax,%eax
  801162:	79 14                	jns    801178 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  801164:	83 ec 04             	sub    $0x4,%esp
  801167:	68 bc 17 80 00       	push   $0x8017bc
  80116c:	6a 21                	push   $0x21
  80116e:	68 20 18 80 00       	push   $0x801820
  801173:	e8 7f ff ff ff       	call   8010f7 <_panic>
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801178:	8b 45 08             	mov    0x8(%ebp),%eax
  80117b:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801180:	83 ec 08             	sub    $0x8,%esp
  801183:	68 ac 11 80 00       	push   $0x8011ac
  801188:	6a 00                	push   $0x0
  80118a:	e8 c2 fa ff ff       	call   800c51 <sys_env_set_pgfault_upcall>
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	85 c0                	test   %eax,%eax
  801194:	79 14                	jns    8011aa <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801196:	83 ec 04             	sub    $0x4,%esp
  801199:	68 e8 17 80 00       	push   $0x8017e8
  80119e:	6a 26                	push   $0x26
  8011a0:	68 20 18 80 00       	push   $0x801820
  8011a5:	e8 4d ff ff ff       	call   8010f7 <_panic>
}
  8011aa:	c9                   	leave  
  8011ab:	c3                   	ret    

008011ac <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011ac:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011ad:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8011b2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011b4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx #trap-time eip
  8011b7:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)
  8011bb:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax #trap-time esp-4
  8011c0:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)
  8011c4:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp
  8011c6:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8011c9:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp #eip
  8011ca:	83 c4 04             	add    $0x4,%esp
	popfl
  8011cd:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8011ce:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8011cf:	c3                   	ret    

008011d0 <__udivdi3>:
  8011d0:	55                   	push   %ebp
  8011d1:	57                   	push   %edi
  8011d2:	56                   	push   %esi
  8011d3:	53                   	push   %ebx
  8011d4:	83 ec 1c             	sub    $0x1c,%esp
  8011d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8011db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8011df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8011e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8011e7:	85 f6                	test   %esi,%esi
  8011e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011ed:	89 ca                	mov    %ecx,%edx
  8011ef:	89 f8                	mov    %edi,%eax
  8011f1:	75 3d                	jne    801230 <__udivdi3+0x60>
  8011f3:	39 cf                	cmp    %ecx,%edi
  8011f5:	0f 87 c5 00 00 00    	ja     8012c0 <__udivdi3+0xf0>
  8011fb:	85 ff                	test   %edi,%edi
  8011fd:	89 fd                	mov    %edi,%ebp
  8011ff:	75 0b                	jne    80120c <__udivdi3+0x3c>
  801201:	b8 01 00 00 00       	mov    $0x1,%eax
  801206:	31 d2                	xor    %edx,%edx
  801208:	f7 f7                	div    %edi
  80120a:	89 c5                	mov    %eax,%ebp
  80120c:	89 c8                	mov    %ecx,%eax
  80120e:	31 d2                	xor    %edx,%edx
  801210:	f7 f5                	div    %ebp
  801212:	89 c1                	mov    %eax,%ecx
  801214:	89 d8                	mov    %ebx,%eax
  801216:	89 cf                	mov    %ecx,%edi
  801218:	f7 f5                	div    %ebp
  80121a:	89 c3                	mov    %eax,%ebx
  80121c:	89 d8                	mov    %ebx,%eax
  80121e:	89 fa                	mov    %edi,%edx
  801220:	83 c4 1c             	add    $0x1c,%esp
  801223:	5b                   	pop    %ebx
  801224:	5e                   	pop    %esi
  801225:	5f                   	pop    %edi
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    
  801228:	90                   	nop
  801229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801230:	39 ce                	cmp    %ecx,%esi
  801232:	77 74                	ja     8012a8 <__udivdi3+0xd8>
  801234:	0f bd fe             	bsr    %esi,%edi
  801237:	83 f7 1f             	xor    $0x1f,%edi
  80123a:	0f 84 98 00 00 00    	je     8012d8 <__udivdi3+0x108>
  801240:	bb 20 00 00 00       	mov    $0x20,%ebx
  801245:	89 f9                	mov    %edi,%ecx
  801247:	89 c5                	mov    %eax,%ebp
  801249:	29 fb                	sub    %edi,%ebx
  80124b:	d3 e6                	shl    %cl,%esi
  80124d:	89 d9                	mov    %ebx,%ecx
  80124f:	d3 ed                	shr    %cl,%ebp
  801251:	89 f9                	mov    %edi,%ecx
  801253:	d3 e0                	shl    %cl,%eax
  801255:	09 ee                	or     %ebp,%esi
  801257:	89 d9                	mov    %ebx,%ecx
  801259:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80125d:	89 d5                	mov    %edx,%ebp
  80125f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801263:	d3 ed                	shr    %cl,%ebp
  801265:	89 f9                	mov    %edi,%ecx
  801267:	d3 e2                	shl    %cl,%edx
  801269:	89 d9                	mov    %ebx,%ecx
  80126b:	d3 e8                	shr    %cl,%eax
  80126d:	09 c2                	or     %eax,%edx
  80126f:	89 d0                	mov    %edx,%eax
  801271:	89 ea                	mov    %ebp,%edx
  801273:	f7 f6                	div    %esi
  801275:	89 d5                	mov    %edx,%ebp
  801277:	89 c3                	mov    %eax,%ebx
  801279:	f7 64 24 0c          	mull   0xc(%esp)
  80127d:	39 d5                	cmp    %edx,%ebp
  80127f:	72 10                	jb     801291 <__udivdi3+0xc1>
  801281:	8b 74 24 08          	mov    0x8(%esp),%esi
  801285:	89 f9                	mov    %edi,%ecx
  801287:	d3 e6                	shl    %cl,%esi
  801289:	39 c6                	cmp    %eax,%esi
  80128b:	73 07                	jae    801294 <__udivdi3+0xc4>
  80128d:	39 d5                	cmp    %edx,%ebp
  80128f:	75 03                	jne    801294 <__udivdi3+0xc4>
  801291:	83 eb 01             	sub    $0x1,%ebx
  801294:	31 ff                	xor    %edi,%edi
  801296:	89 d8                	mov    %ebx,%eax
  801298:	89 fa                	mov    %edi,%edx
  80129a:	83 c4 1c             	add    $0x1c,%esp
  80129d:	5b                   	pop    %ebx
  80129e:	5e                   	pop    %esi
  80129f:	5f                   	pop    %edi
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    
  8012a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012a8:	31 ff                	xor    %edi,%edi
  8012aa:	31 db                	xor    %ebx,%ebx
  8012ac:	89 d8                	mov    %ebx,%eax
  8012ae:	89 fa                	mov    %edi,%edx
  8012b0:	83 c4 1c             	add    $0x1c,%esp
  8012b3:	5b                   	pop    %ebx
  8012b4:	5e                   	pop    %esi
  8012b5:	5f                   	pop    %edi
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    
  8012b8:	90                   	nop
  8012b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012c0:	89 d8                	mov    %ebx,%eax
  8012c2:	f7 f7                	div    %edi
  8012c4:	31 ff                	xor    %edi,%edi
  8012c6:	89 c3                	mov    %eax,%ebx
  8012c8:	89 d8                	mov    %ebx,%eax
  8012ca:	89 fa                	mov    %edi,%edx
  8012cc:	83 c4 1c             	add    $0x1c,%esp
  8012cf:	5b                   	pop    %ebx
  8012d0:	5e                   	pop    %esi
  8012d1:	5f                   	pop    %edi
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    
  8012d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012d8:	39 ce                	cmp    %ecx,%esi
  8012da:	72 0c                	jb     8012e8 <__udivdi3+0x118>
  8012dc:	31 db                	xor    %ebx,%ebx
  8012de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8012e2:	0f 87 34 ff ff ff    	ja     80121c <__udivdi3+0x4c>
  8012e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8012ed:	e9 2a ff ff ff       	jmp    80121c <__udivdi3+0x4c>
  8012f2:	66 90                	xchg   %ax,%ax
  8012f4:	66 90                	xchg   %ax,%ax
  8012f6:	66 90                	xchg   %ax,%ax
  8012f8:	66 90                	xchg   %ax,%ax
  8012fa:	66 90                	xchg   %ax,%ax
  8012fc:	66 90                	xchg   %ax,%ax
  8012fe:	66 90                	xchg   %ax,%ax

00801300 <__umoddi3>:
  801300:	55                   	push   %ebp
  801301:	57                   	push   %edi
  801302:	56                   	push   %esi
  801303:	53                   	push   %ebx
  801304:	83 ec 1c             	sub    $0x1c,%esp
  801307:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80130b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80130f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801317:	85 d2                	test   %edx,%edx
  801319:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80131d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801321:	89 f3                	mov    %esi,%ebx
  801323:	89 3c 24             	mov    %edi,(%esp)
  801326:	89 74 24 04          	mov    %esi,0x4(%esp)
  80132a:	75 1c                	jne    801348 <__umoddi3+0x48>
  80132c:	39 f7                	cmp    %esi,%edi
  80132e:	76 50                	jbe    801380 <__umoddi3+0x80>
  801330:	89 c8                	mov    %ecx,%eax
  801332:	89 f2                	mov    %esi,%edx
  801334:	f7 f7                	div    %edi
  801336:	89 d0                	mov    %edx,%eax
  801338:	31 d2                	xor    %edx,%edx
  80133a:	83 c4 1c             	add    $0x1c,%esp
  80133d:	5b                   	pop    %ebx
  80133e:	5e                   	pop    %esi
  80133f:	5f                   	pop    %edi
  801340:	5d                   	pop    %ebp
  801341:	c3                   	ret    
  801342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801348:	39 f2                	cmp    %esi,%edx
  80134a:	89 d0                	mov    %edx,%eax
  80134c:	77 52                	ja     8013a0 <__umoddi3+0xa0>
  80134e:	0f bd ea             	bsr    %edx,%ebp
  801351:	83 f5 1f             	xor    $0x1f,%ebp
  801354:	75 5a                	jne    8013b0 <__umoddi3+0xb0>
  801356:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80135a:	0f 82 e0 00 00 00    	jb     801440 <__umoddi3+0x140>
  801360:	39 0c 24             	cmp    %ecx,(%esp)
  801363:	0f 86 d7 00 00 00    	jbe    801440 <__umoddi3+0x140>
  801369:	8b 44 24 08          	mov    0x8(%esp),%eax
  80136d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801371:	83 c4 1c             	add    $0x1c,%esp
  801374:	5b                   	pop    %ebx
  801375:	5e                   	pop    %esi
  801376:	5f                   	pop    %edi
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    
  801379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801380:	85 ff                	test   %edi,%edi
  801382:	89 fd                	mov    %edi,%ebp
  801384:	75 0b                	jne    801391 <__umoddi3+0x91>
  801386:	b8 01 00 00 00       	mov    $0x1,%eax
  80138b:	31 d2                	xor    %edx,%edx
  80138d:	f7 f7                	div    %edi
  80138f:	89 c5                	mov    %eax,%ebp
  801391:	89 f0                	mov    %esi,%eax
  801393:	31 d2                	xor    %edx,%edx
  801395:	f7 f5                	div    %ebp
  801397:	89 c8                	mov    %ecx,%eax
  801399:	f7 f5                	div    %ebp
  80139b:	89 d0                	mov    %edx,%eax
  80139d:	eb 99                	jmp    801338 <__umoddi3+0x38>
  80139f:	90                   	nop
  8013a0:	89 c8                	mov    %ecx,%eax
  8013a2:	89 f2                	mov    %esi,%edx
  8013a4:	83 c4 1c             	add    $0x1c,%esp
  8013a7:	5b                   	pop    %ebx
  8013a8:	5e                   	pop    %esi
  8013a9:	5f                   	pop    %edi
  8013aa:	5d                   	pop    %ebp
  8013ab:	c3                   	ret    
  8013ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013b0:	8b 34 24             	mov    (%esp),%esi
  8013b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8013b8:	89 e9                	mov    %ebp,%ecx
  8013ba:	29 ef                	sub    %ebp,%edi
  8013bc:	d3 e0                	shl    %cl,%eax
  8013be:	89 f9                	mov    %edi,%ecx
  8013c0:	89 f2                	mov    %esi,%edx
  8013c2:	d3 ea                	shr    %cl,%edx
  8013c4:	89 e9                	mov    %ebp,%ecx
  8013c6:	09 c2                	or     %eax,%edx
  8013c8:	89 d8                	mov    %ebx,%eax
  8013ca:	89 14 24             	mov    %edx,(%esp)
  8013cd:	89 f2                	mov    %esi,%edx
  8013cf:	d3 e2                	shl    %cl,%edx
  8013d1:	89 f9                	mov    %edi,%ecx
  8013d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013db:	d3 e8                	shr    %cl,%eax
  8013dd:	89 e9                	mov    %ebp,%ecx
  8013df:	89 c6                	mov    %eax,%esi
  8013e1:	d3 e3                	shl    %cl,%ebx
  8013e3:	89 f9                	mov    %edi,%ecx
  8013e5:	89 d0                	mov    %edx,%eax
  8013e7:	d3 e8                	shr    %cl,%eax
  8013e9:	89 e9                	mov    %ebp,%ecx
  8013eb:	09 d8                	or     %ebx,%eax
  8013ed:	89 d3                	mov    %edx,%ebx
  8013ef:	89 f2                	mov    %esi,%edx
  8013f1:	f7 34 24             	divl   (%esp)
  8013f4:	89 d6                	mov    %edx,%esi
  8013f6:	d3 e3                	shl    %cl,%ebx
  8013f8:	f7 64 24 04          	mull   0x4(%esp)
  8013fc:	39 d6                	cmp    %edx,%esi
  8013fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801402:	89 d1                	mov    %edx,%ecx
  801404:	89 c3                	mov    %eax,%ebx
  801406:	72 08                	jb     801410 <__umoddi3+0x110>
  801408:	75 11                	jne    80141b <__umoddi3+0x11b>
  80140a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80140e:	73 0b                	jae    80141b <__umoddi3+0x11b>
  801410:	2b 44 24 04          	sub    0x4(%esp),%eax
  801414:	1b 14 24             	sbb    (%esp),%edx
  801417:	89 d1                	mov    %edx,%ecx
  801419:	89 c3                	mov    %eax,%ebx
  80141b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80141f:	29 da                	sub    %ebx,%edx
  801421:	19 ce                	sbb    %ecx,%esi
  801423:	89 f9                	mov    %edi,%ecx
  801425:	89 f0                	mov    %esi,%eax
  801427:	d3 e0                	shl    %cl,%eax
  801429:	89 e9                	mov    %ebp,%ecx
  80142b:	d3 ea                	shr    %cl,%edx
  80142d:	89 e9                	mov    %ebp,%ecx
  80142f:	d3 ee                	shr    %cl,%esi
  801431:	09 d0                	or     %edx,%eax
  801433:	89 f2                	mov    %esi,%edx
  801435:	83 c4 1c             	add    $0x1c,%esp
  801438:	5b                   	pop    %ebx
  801439:	5e                   	pop    %esi
  80143a:	5f                   	pop    %edi
  80143b:	5d                   	pop    %ebp
  80143c:	c3                   	ret    
  80143d:	8d 76 00             	lea    0x0(%esi),%esi
  801440:	29 f9                	sub    %edi,%ecx
  801442:	19 d6                	sbb    %edx,%esi
  801444:	89 74 24 04          	mov    %esi,0x4(%esp)
  801448:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80144c:	e9 18 ff ff ff       	jmp    801369 <__umoddi3+0x69>
