
obj/user/fairness：     文件格式 elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
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
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 dc 0a 00 00       	call   800b1c <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 20 80 00 80 	cmpl   $0xeec00080,0x802004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 cb 0c 00 00       	call   800d29 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 00 11 80 00       	push   $0x801100
  80006a:	e8 1d 01 00 00       	call   80018c <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 11 11 80 00       	push   $0x801111
  800083:	e8 04 01 00 00       	call   80018c <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 f4 0c 00 00       	call   800d90 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  8000ac:	e8 6b 0a 00 00       	call   800b1c <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	c1 e0 07             	shl    $0x7,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	e8 e7 09 00 00       	call   800adb <sys_env_destroy>
}
  8000f4:	83 c4 10             	add    $0x10,%esp
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 04             	sub    $0x4,%esp
  800100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800103:	8b 13                	mov    (%ebx),%edx
  800105:	8d 42 01             	lea    0x1(%edx),%eax
  800108:	89 03                	mov    %eax,(%ebx)
  80010a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800111:	3d ff 00 00 00       	cmp    $0xff,%eax
  800116:	75 1a                	jne    800132 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800118:	83 ec 08             	sub    $0x8,%esp
  80011b:	68 ff 00 00 00       	push   $0xff
  800120:	8d 43 08             	lea    0x8(%ebx),%eax
  800123:	50                   	push   %eax
  800124:	e8 75 09 00 00       	call   800a9e <sys_cputs>
		b->idx = 0;
  800129:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80012f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800132:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800136:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800144:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014b:	00 00 00 
	b.cnt = 0;
  80014e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800155:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800158:	ff 75 0c             	pushl  0xc(%ebp)
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800164:	50                   	push   %eax
  800165:	68 f9 00 80 00       	push   $0x8000f9
  80016a:	e8 54 01 00 00       	call   8002c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016f:	83 c4 08             	add    $0x8,%esp
  800172:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800178:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017e:	50                   	push   %eax
  80017f:	e8 1a 09 00 00       	call   800a9e <sys_cputs>

	return b.cnt;
}
  800184:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800192:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800195:	50                   	push   %eax
  800196:	ff 75 08             	pushl  0x8(%ebp)
  800199:	e8 9d ff ff ff       	call   80013b <vcprintf>
	va_end(ap);

	return cnt;
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 1c             	sub    $0x1c,%esp
  8001a9:	89 c7                	mov    %eax,%edi
  8001ab:	89 d6                	mov    %edx,%esi
  8001ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c7:	39 d3                	cmp    %edx,%ebx
  8001c9:	72 05                	jb     8001d0 <printnum+0x30>
  8001cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ce:	77 45                	ja     800215 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	ff 75 18             	pushl  0x18(%ebp)
  8001d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8001d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dc:	53                   	push   %ebx
  8001dd:	ff 75 10             	pushl  0x10(%ebp)
  8001e0:	83 ec 08             	sub    $0x8,%esp
  8001e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ef:	e8 7c 0c 00 00       	call   800e70 <__udivdi3>
  8001f4:	83 c4 18             	add    $0x18,%esp
  8001f7:	52                   	push   %edx
  8001f8:	50                   	push   %eax
  8001f9:	89 f2                	mov    %esi,%edx
  8001fb:	89 f8                	mov    %edi,%eax
  8001fd:	e8 9e ff ff ff       	call   8001a0 <printnum>
  800202:	83 c4 20             	add    $0x20,%esp
  800205:	eb 18                	jmp    80021f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800207:	83 ec 08             	sub    $0x8,%esp
  80020a:	56                   	push   %esi
  80020b:	ff 75 18             	pushl  0x18(%ebp)
  80020e:	ff d7                	call   *%edi
  800210:	83 c4 10             	add    $0x10,%esp
  800213:	eb 03                	jmp    800218 <printnum+0x78>
  800215:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800218:	83 eb 01             	sub    $0x1,%ebx
  80021b:	85 db                	test   %ebx,%ebx
  80021d:	7f e8                	jg     800207 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021f:	83 ec 08             	sub    $0x8,%esp
  800222:	56                   	push   %esi
  800223:	83 ec 04             	sub    $0x4,%esp
  800226:	ff 75 e4             	pushl  -0x1c(%ebp)
  800229:	ff 75 e0             	pushl  -0x20(%ebp)
  80022c:	ff 75 dc             	pushl  -0x24(%ebp)
  80022f:	ff 75 d8             	pushl  -0x28(%ebp)
  800232:	e8 69 0d 00 00       	call   800fa0 <__umoddi3>
  800237:	83 c4 14             	add    $0x14,%esp
  80023a:	0f be 80 32 11 80 00 	movsbl 0x801132(%eax),%eax
  800241:	50                   	push   %eax
  800242:	ff d7                	call   *%edi
}
  800244:	83 c4 10             	add    $0x10,%esp
  800247:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5f                   	pop    %edi
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800252:	83 fa 01             	cmp    $0x1,%edx
  800255:	7e 0e                	jle    800265 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800257:	8b 10                	mov    (%eax),%edx
  800259:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025c:	89 08                	mov    %ecx,(%eax)
  80025e:	8b 02                	mov    (%edx),%eax
  800260:	8b 52 04             	mov    0x4(%edx),%edx
  800263:	eb 22                	jmp    800287 <getuint+0x38>
	else if (lflag)
  800265:	85 d2                	test   %edx,%edx
  800267:	74 10                	je     800279 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800269:	8b 10                	mov    (%eax),%edx
  80026b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026e:	89 08                	mov    %ecx,(%eax)
  800270:	8b 02                	mov    (%edx),%eax
  800272:	ba 00 00 00 00       	mov    $0x0,%edx
  800277:	eb 0e                	jmp    800287 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027e:	89 08                	mov    %ecx,(%eax)
  800280:	8b 02                	mov    (%edx),%eax
  800282:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800293:	8b 10                	mov    (%eax),%edx
  800295:	3b 50 04             	cmp    0x4(%eax),%edx
  800298:	73 0a                	jae    8002a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029d:	89 08                	mov    %ecx,(%eax)
  80029f:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a2:	88 02                	mov    %al,(%edx)
}
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002af:	50                   	push   %eax
  8002b0:	ff 75 10             	pushl  0x10(%ebp)
  8002b3:	ff 75 0c             	pushl  0xc(%ebp)
  8002b6:	ff 75 08             	pushl  0x8(%ebp)
  8002b9:	e8 05 00 00 00       	call   8002c3 <vprintfmt>
	va_end(ap);
}
  8002be:	83 c4 10             	add    $0x10,%esp
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	57                   	push   %edi
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	83 ec 2c             	sub    $0x2c,%esp
  8002cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8002cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d5:	eb 1d                	jmp    8002f4 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	75 0f                	jne    8002ea <vprintfmt+0x27>
				csa = 0x0700;
  8002db:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  8002e2:	07 00 00 
				return;
  8002e5:	e9 c4 03 00 00       	jmp    8006ae <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  8002ea:	83 ec 08             	sub    $0x8,%esp
  8002ed:	53                   	push   %ebx
  8002ee:	50                   	push   %eax
  8002ef:	ff d6                	call   *%esi
  8002f1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f4:	83 c7 01             	add    $0x1,%edi
  8002f7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002fb:	83 f8 25             	cmp    $0x25,%eax
  8002fe:	75 d7                	jne    8002d7 <vprintfmt+0x14>
  800300:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800304:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80030b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800312:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
  80031e:	eb 07                	jmp    800327 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800320:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800323:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800327:	8d 47 01             	lea    0x1(%edi),%eax
  80032a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032d:	0f b6 07             	movzbl (%edi),%eax
  800330:	0f b6 c8             	movzbl %al,%ecx
  800333:	83 e8 23             	sub    $0x23,%eax
  800336:	3c 55                	cmp    $0x55,%al
  800338:	0f 87 55 03 00 00    	ja     800693 <vprintfmt+0x3d0>
  80033e:	0f b6 c0             	movzbl %al,%eax
  800341:	ff 24 85 00 12 80 00 	jmp    *0x801200(,%eax,4)
  800348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80034f:	eb d6                	jmp    800327 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800354:	b8 00 00 00 00       	mov    $0x0,%eax
  800359:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800363:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800366:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800369:	83 fa 09             	cmp    $0x9,%edx
  80036c:	77 39                	ja     8003a7 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800371:	eb e9                	jmp    80035c <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800373:	8b 45 14             	mov    0x14(%ebp),%eax
  800376:	8d 48 04             	lea    0x4(%eax),%ecx
  800379:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80037c:	8b 00                	mov    (%eax),%eax
  80037e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800384:	eb 27                	jmp    8003ad <vprintfmt+0xea>
  800386:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800389:	85 c0                	test   %eax,%eax
  80038b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800390:	0f 49 c8             	cmovns %eax,%ecx
  800393:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800399:	eb 8c                	jmp    800327 <vprintfmt+0x64>
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a5:	eb 80                	jmp    800327 <vprintfmt+0x64>
  8003a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003aa:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b1:	0f 89 70 ff ff ff    	jns    800327 <vprintfmt+0x64>
				width = precision, precision = -1;
  8003b7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003bd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c4:	e9 5e ff ff ff       	jmp    800327 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003cf:	e9 53 ff ff ff       	jmp    800327 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 50 04             	lea    0x4(%eax),%edx
  8003da:	89 55 14             	mov    %edx,0x14(%ebp)
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	53                   	push   %ebx
  8003e1:	ff 30                	pushl  (%eax)
  8003e3:	ff d6                	call   *%esi
			break;
  8003e5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003eb:	e9 04 ff ff ff       	jmp    8002f4 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 50 04             	lea    0x4(%eax),%edx
  8003f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f9:	8b 00                	mov    (%eax),%eax
  8003fb:	99                   	cltd   
  8003fc:	31 d0                	xor    %edx,%eax
  8003fe:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800400:	83 f8 08             	cmp    $0x8,%eax
  800403:	7f 0b                	jg     800410 <vprintfmt+0x14d>
  800405:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  80040c:	85 d2                	test   %edx,%edx
  80040e:	75 18                	jne    800428 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  800410:	50                   	push   %eax
  800411:	68 4a 11 80 00       	push   $0x80114a
  800416:	53                   	push   %ebx
  800417:	56                   	push   %esi
  800418:	e8 89 fe ff ff       	call   8002a6 <printfmt>
  80041d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800423:	e9 cc fe ff ff       	jmp    8002f4 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  800428:	52                   	push   %edx
  800429:	68 53 11 80 00       	push   $0x801153
  80042e:	53                   	push   %ebx
  80042f:	56                   	push   %esi
  800430:	e8 71 fe ff ff       	call   8002a6 <printfmt>
  800435:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043b:	e9 b4 fe ff ff       	jmp    8002f4 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80044b:	85 ff                	test   %edi,%edi
  80044d:	b8 43 11 80 00       	mov    $0x801143,%eax
  800452:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800455:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800459:	0f 8e 94 00 00 00    	jle    8004f3 <vprintfmt+0x230>
  80045f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800463:	0f 84 98 00 00 00    	je     800501 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	ff 75 d0             	pushl  -0x30(%ebp)
  80046f:	57                   	push   %edi
  800470:	e8 c1 02 00 00       	call   800736 <strnlen>
  800475:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800478:	29 c1                	sub    %eax,%ecx
  80047a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80047d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800480:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800484:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800487:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80048a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048c:	eb 0f                	jmp    80049d <vprintfmt+0x1da>
					putch(padc, putdat);
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	53                   	push   %ebx
  800492:	ff 75 e0             	pushl  -0x20(%ebp)
  800495:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800497:	83 ef 01             	sub    $0x1,%edi
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	85 ff                	test   %edi,%edi
  80049f:	7f ed                	jg     80048e <vprintfmt+0x1cb>
  8004a1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a7:	85 c9                	test   %ecx,%ecx
  8004a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ae:	0f 49 c1             	cmovns %ecx,%eax
  8004b1:	29 c1                	sub    %eax,%ecx
  8004b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004bc:	89 cb                	mov    %ecx,%ebx
  8004be:	eb 4d                	jmp    80050d <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004c0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c4:	74 1b                	je     8004e1 <vprintfmt+0x21e>
  8004c6:	0f be c0             	movsbl %al,%eax
  8004c9:	83 e8 20             	sub    $0x20,%eax
  8004cc:	83 f8 5e             	cmp    $0x5e,%eax
  8004cf:	76 10                	jbe    8004e1 <vprintfmt+0x21e>
					putch('?', putdat);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	ff 75 0c             	pushl  0xc(%ebp)
  8004d7:	6a 3f                	push   $0x3f
  8004d9:	ff 55 08             	call   *0x8(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
  8004df:	eb 0d                	jmp    8004ee <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	ff 75 0c             	pushl  0xc(%ebp)
  8004e7:	52                   	push   %edx
  8004e8:	ff 55 08             	call   *0x8(%ebp)
  8004eb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ee:	83 eb 01             	sub    $0x1,%ebx
  8004f1:	eb 1a                	jmp    80050d <vprintfmt+0x24a>
  8004f3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ff:	eb 0c                	jmp    80050d <vprintfmt+0x24a>
  800501:	89 75 08             	mov    %esi,0x8(%ebp)
  800504:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800507:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050d:	83 c7 01             	add    $0x1,%edi
  800510:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800514:	0f be d0             	movsbl %al,%edx
  800517:	85 d2                	test   %edx,%edx
  800519:	74 23                	je     80053e <vprintfmt+0x27b>
  80051b:	85 f6                	test   %esi,%esi
  80051d:	78 a1                	js     8004c0 <vprintfmt+0x1fd>
  80051f:	83 ee 01             	sub    $0x1,%esi
  800522:	79 9c                	jns    8004c0 <vprintfmt+0x1fd>
  800524:	89 df                	mov    %ebx,%edi
  800526:	8b 75 08             	mov    0x8(%ebp),%esi
  800529:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052c:	eb 18                	jmp    800546 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	53                   	push   %ebx
  800532:	6a 20                	push   $0x20
  800534:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800536:	83 ef 01             	sub    $0x1,%edi
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	eb 08                	jmp    800546 <vprintfmt+0x283>
  80053e:	89 df                	mov    %ebx,%edi
  800540:	8b 75 08             	mov    0x8(%ebp),%esi
  800543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800546:	85 ff                	test   %edi,%edi
  800548:	7f e4                	jg     80052e <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054d:	e9 a2 fd ff ff       	jmp    8002f4 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800552:	83 fa 01             	cmp    $0x1,%edx
  800555:	7e 16                	jle    80056d <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8d 50 08             	lea    0x8(%eax),%edx
  80055d:	89 55 14             	mov    %edx,0x14(%ebp)
  800560:	8b 50 04             	mov    0x4(%eax),%edx
  800563:	8b 00                	mov    (%eax),%eax
  800565:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800568:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056b:	eb 32                	jmp    80059f <vprintfmt+0x2dc>
	else if (lflag)
  80056d:	85 d2                	test   %edx,%edx
  80056f:	74 18                	je     800589 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 04             	lea    0x4(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057f:	89 c1                	mov    %eax,%ecx
  800581:	c1 f9 1f             	sar    $0x1f,%ecx
  800584:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800587:	eb 16                	jmp    80059f <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8d 50 04             	lea    0x4(%eax),%edx
  80058f:	89 55 14             	mov    %edx,0x14(%ebp)
  800592:	8b 00                	mov    (%eax),%eax
  800594:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800597:	89 c1                	mov    %eax,%ecx
  800599:	c1 f9 1f             	sar    $0x1f,%ecx
  80059c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005aa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ae:	79 74                	jns    800624 <vprintfmt+0x361>
				putch('-', putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	53                   	push   %ebx
  8005b4:	6a 2d                	push   $0x2d
  8005b6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005be:	f7 d8                	neg    %eax
  8005c0:	83 d2 00             	adc    $0x0,%edx
  8005c3:	f7 da                	neg    %edx
  8005c5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005cd:	eb 55                	jmp    800624 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d2:	e8 78 fc ff ff       	call   80024f <getuint>
			base = 10;
  8005d7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005dc:	eb 46                	jmp    800624 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  8005de:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e1:	e8 69 fc ff ff       	call   80024f <getuint>
      base = 8;
  8005e6:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8005eb:	eb 37                	jmp    800624 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	53                   	push   %ebx
  8005f1:	6a 30                	push   $0x30
  8005f3:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f5:	83 c4 08             	add    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	6a 78                	push   $0x78
  8005fb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8d 50 04             	lea    0x4(%eax),%edx
  800603:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800606:	8b 00                	mov    (%eax),%eax
  800608:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80060d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800610:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800615:	eb 0d                	jmp    800624 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800617:	8d 45 14             	lea    0x14(%ebp),%eax
  80061a:	e8 30 fc ff ff       	call   80024f <getuint>
			base = 16;
  80061f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800624:	83 ec 0c             	sub    $0xc,%esp
  800627:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80062b:	57                   	push   %edi
  80062c:	ff 75 e0             	pushl  -0x20(%ebp)
  80062f:	51                   	push   %ecx
  800630:	52                   	push   %edx
  800631:	50                   	push   %eax
  800632:	89 da                	mov    %ebx,%edx
  800634:	89 f0                	mov    %esi,%eax
  800636:	e8 65 fb ff ff       	call   8001a0 <printnum>
			break;
  80063b:	83 c4 20             	add    $0x20,%esp
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800641:	e9 ae fc ff ff       	jmp    8002f4 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	51                   	push   %ecx
  80064b:	ff d6                	call   *%esi
			break;
  80064d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800650:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800653:	e9 9c fc ff ff       	jmp    8002f4 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800658:	83 fa 01             	cmp    $0x1,%edx
  80065b:	7e 0d                	jle    80066a <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8d 50 08             	lea    0x8(%eax),%edx
  800663:	89 55 14             	mov    %edx,0x14(%ebp)
  800666:	8b 00                	mov    (%eax),%eax
  800668:	eb 1c                	jmp    800686 <vprintfmt+0x3c3>
	else if (lflag)
  80066a:	85 d2                	test   %edx,%edx
  80066c:	74 0d                	je     80067b <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	8d 50 04             	lea    0x4(%eax),%edx
  800674:	89 55 14             	mov    %edx,0x14(%ebp)
  800677:	8b 00                	mov    (%eax),%eax
  800679:	eb 0b                	jmp    800686 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8d 50 04             	lea    0x4(%eax),%edx
  800681:	89 55 14             	mov    %edx,0x14(%ebp)
  800684:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  800686:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  80068e:	e9 61 fc ff ff       	jmp    8002f4 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	6a 25                	push   $0x25
  800699:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	eb 03                	jmp    8006a3 <vprintfmt+0x3e0>
  8006a0:	83 ef 01             	sub    $0x1,%edi
  8006a3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a7:	75 f7                	jne    8006a0 <vprintfmt+0x3dd>
  8006a9:	e9 46 fc ff ff       	jmp    8002f4 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  8006ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b1:	5b                   	pop    %ebx
  8006b2:	5e                   	pop    %esi
  8006b3:	5f                   	pop    %edi
  8006b4:	5d                   	pop    %ebp
  8006b5:	c3                   	ret    

008006b6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b6:	55                   	push   %ebp
  8006b7:	89 e5                	mov    %esp,%ebp
  8006b9:	83 ec 18             	sub    $0x18,%esp
  8006bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d3:	85 c0                	test   %eax,%eax
  8006d5:	74 26                	je     8006fd <vsnprintf+0x47>
  8006d7:	85 d2                	test   %edx,%edx
  8006d9:	7e 22                	jle    8006fd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006db:	ff 75 14             	pushl  0x14(%ebp)
  8006de:	ff 75 10             	pushl  0x10(%ebp)
  8006e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e4:	50                   	push   %eax
  8006e5:	68 89 02 80 00       	push   $0x800289
  8006ea:	e8 d4 fb ff ff       	call   8002c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f8:	83 c4 10             	add    $0x10,%esp
  8006fb:	eb 05                	jmp    800702 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800702:	c9                   	leave  
  800703:	c3                   	ret    

00800704 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070d:	50                   	push   %eax
  80070e:	ff 75 10             	pushl  0x10(%ebp)
  800711:	ff 75 0c             	pushl  0xc(%ebp)
  800714:	ff 75 08             	pushl  0x8(%ebp)
  800717:	e8 9a ff ff ff       	call   8006b6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071c:	c9                   	leave  
  80071d:	c3                   	ret    

0080071e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800724:	b8 00 00 00 00       	mov    $0x0,%eax
  800729:	eb 03                	jmp    80072e <strlen+0x10>
		n++;
  80072b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80072e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800732:	75 f7                	jne    80072b <strlen+0xd>
		n++;
	return n;
}
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073f:	ba 00 00 00 00       	mov    $0x0,%edx
  800744:	eb 03                	jmp    800749 <strnlen+0x13>
		n++;
  800746:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800749:	39 c2                	cmp    %eax,%edx
  80074b:	74 08                	je     800755 <strnlen+0x1f>
  80074d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800751:	75 f3                	jne    800746 <strnlen+0x10>
  800753:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	53                   	push   %ebx
  80075b:	8b 45 08             	mov    0x8(%ebp),%eax
  80075e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800761:	89 c2                	mov    %eax,%edx
  800763:	83 c2 01             	add    $0x1,%edx
  800766:	83 c1 01             	add    $0x1,%ecx
  800769:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80076d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800770:	84 db                	test   %bl,%bl
  800772:	75 ef                	jne    800763 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800774:	5b                   	pop    %ebx
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	53                   	push   %ebx
  80077b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077e:	53                   	push   %ebx
  80077f:	e8 9a ff ff ff       	call   80071e <strlen>
  800784:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800787:	ff 75 0c             	pushl  0xc(%ebp)
  80078a:	01 d8                	add    %ebx,%eax
  80078c:	50                   	push   %eax
  80078d:	e8 c5 ff ff ff       	call   800757 <strcpy>
	return dst;
}
  800792:	89 d8                	mov    %ebx,%eax
  800794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	56                   	push   %esi
  80079d:	53                   	push   %ebx
  80079e:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a4:	89 f3                	mov    %esi,%ebx
  8007a6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a9:	89 f2                	mov    %esi,%edx
  8007ab:	eb 0f                	jmp    8007bc <strncpy+0x23>
		*dst++ = *src;
  8007ad:	83 c2 01             	add    $0x1,%edx
  8007b0:	0f b6 01             	movzbl (%ecx),%eax
  8007b3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b6:	80 39 01             	cmpb   $0x1,(%ecx)
  8007b9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bc:	39 da                	cmp    %ebx,%edx
  8007be:	75 ed                	jne    8007ad <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c0:	89 f0                	mov    %esi,%eax
  8007c2:	5b                   	pop    %ebx
  8007c3:	5e                   	pop    %esi
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	56                   	push   %esi
  8007ca:	53                   	push   %ebx
  8007cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d6:	85 d2                	test   %edx,%edx
  8007d8:	74 21                	je     8007fb <strlcpy+0x35>
  8007da:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007de:	89 f2                	mov    %esi,%edx
  8007e0:	eb 09                	jmp    8007eb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e2:	83 c2 01             	add    $0x1,%edx
  8007e5:	83 c1 01             	add    $0x1,%ecx
  8007e8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007eb:	39 c2                	cmp    %eax,%edx
  8007ed:	74 09                	je     8007f8 <strlcpy+0x32>
  8007ef:	0f b6 19             	movzbl (%ecx),%ebx
  8007f2:	84 db                	test   %bl,%bl
  8007f4:	75 ec                	jne    8007e2 <strlcpy+0x1c>
  8007f6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007fb:	29 f0                	sub    %esi,%eax
}
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800807:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080a:	eb 06                	jmp    800812 <strcmp+0x11>
		p++, q++;
  80080c:	83 c1 01             	add    $0x1,%ecx
  80080f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800812:	0f b6 01             	movzbl (%ecx),%eax
  800815:	84 c0                	test   %al,%al
  800817:	74 04                	je     80081d <strcmp+0x1c>
  800819:	3a 02                	cmp    (%edx),%al
  80081b:	74 ef                	je     80080c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081d:	0f b6 c0             	movzbl %al,%eax
  800820:	0f b6 12             	movzbl (%edx),%edx
  800823:	29 d0                	sub    %edx,%eax
}
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800831:	89 c3                	mov    %eax,%ebx
  800833:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800836:	eb 06                	jmp    80083e <strncmp+0x17>
		n--, p++, q++;
  800838:	83 c0 01             	add    $0x1,%eax
  80083b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083e:	39 d8                	cmp    %ebx,%eax
  800840:	74 15                	je     800857 <strncmp+0x30>
  800842:	0f b6 08             	movzbl (%eax),%ecx
  800845:	84 c9                	test   %cl,%cl
  800847:	74 04                	je     80084d <strncmp+0x26>
  800849:	3a 0a                	cmp    (%edx),%cl
  80084b:	74 eb                	je     800838 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084d:	0f b6 00             	movzbl (%eax),%eax
  800850:	0f b6 12             	movzbl (%edx),%edx
  800853:	29 d0                	sub    %edx,%eax
  800855:	eb 05                	jmp    80085c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800857:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085c:	5b                   	pop    %ebx
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800869:	eb 07                	jmp    800872 <strchr+0x13>
		if (*s == c)
  80086b:	38 ca                	cmp    %cl,%dl
  80086d:	74 0f                	je     80087e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80086f:	83 c0 01             	add    $0x1,%eax
  800872:	0f b6 10             	movzbl (%eax),%edx
  800875:	84 d2                	test   %dl,%dl
  800877:	75 f2                	jne    80086b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800879:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088a:	eb 03                	jmp    80088f <strfind+0xf>
  80088c:	83 c0 01             	add    $0x1,%eax
  80088f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800892:	38 ca                	cmp    %cl,%dl
  800894:	74 04                	je     80089a <strfind+0x1a>
  800896:	84 d2                	test   %dl,%dl
  800898:	75 f2                	jne    80088c <strfind+0xc>
			break;
	return (char *) s;
}
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	57                   	push   %edi
  8008a0:	56                   	push   %esi
  8008a1:	53                   	push   %ebx
  8008a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a8:	85 c9                	test   %ecx,%ecx
  8008aa:	74 36                	je     8008e2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ac:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b2:	75 28                	jne    8008dc <memset+0x40>
  8008b4:	f6 c1 03             	test   $0x3,%cl
  8008b7:	75 23                	jne    8008dc <memset+0x40>
		c &= 0xFF;
  8008b9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008bd:	89 d3                	mov    %edx,%ebx
  8008bf:	c1 e3 08             	shl    $0x8,%ebx
  8008c2:	89 d6                	mov    %edx,%esi
  8008c4:	c1 e6 18             	shl    $0x18,%esi
  8008c7:	89 d0                	mov    %edx,%eax
  8008c9:	c1 e0 10             	shl    $0x10,%eax
  8008cc:	09 f0                	or     %esi,%eax
  8008ce:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d0:	89 d8                	mov    %ebx,%eax
  8008d2:	09 d0                	or     %edx,%eax
  8008d4:	c1 e9 02             	shr    $0x2,%ecx
  8008d7:	fc                   	cld    
  8008d8:	f3 ab                	rep stos %eax,%es:(%edi)
  8008da:	eb 06                	jmp    8008e2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008df:	fc                   	cld    
  8008e0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e2:	89 f8                	mov    %edi,%eax
  8008e4:	5b                   	pop    %ebx
  8008e5:	5e                   	pop    %esi
  8008e6:	5f                   	pop    %edi
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	57                   	push   %edi
  8008ed:	56                   	push   %esi
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f7:	39 c6                	cmp    %eax,%esi
  8008f9:	73 35                	jae    800930 <memmove+0x47>
  8008fb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fe:	39 d0                	cmp    %edx,%eax
  800900:	73 2e                	jae    800930 <memmove+0x47>
		s += n;
		d += n;
  800902:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800905:	89 d6                	mov    %edx,%esi
  800907:	09 fe                	or     %edi,%esi
  800909:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090f:	75 13                	jne    800924 <memmove+0x3b>
  800911:	f6 c1 03             	test   $0x3,%cl
  800914:	75 0e                	jne    800924 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800916:	83 ef 04             	sub    $0x4,%edi
  800919:	8d 72 fc             	lea    -0x4(%edx),%esi
  80091c:	c1 e9 02             	shr    $0x2,%ecx
  80091f:	fd                   	std    
  800920:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800922:	eb 09                	jmp    80092d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800924:	83 ef 01             	sub    $0x1,%edi
  800927:	8d 72 ff             	lea    -0x1(%edx),%esi
  80092a:	fd                   	std    
  80092b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092d:	fc                   	cld    
  80092e:	eb 1d                	jmp    80094d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800930:	89 f2                	mov    %esi,%edx
  800932:	09 c2                	or     %eax,%edx
  800934:	f6 c2 03             	test   $0x3,%dl
  800937:	75 0f                	jne    800948 <memmove+0x5f>
  800939:	f6 c1 03             	test   $0x3,%cl
  80093c:	75 0a                	jne    800948 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80093e:	c1 e9 02             	shr    $0x2,%ecx
  800941:	89 c7                	mov    %eax,%edi
  800943:	fc                   	cld    
  800944:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800946:	eb 05                	jmp    80094d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800948:	89 c7                	mov    %eax,%edi
  80094a:	fc                   	cld    
  80094b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094d:	5e                   	pop    %esi
  80094e:	5f                   	pop    %edi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800954:	ff 75 10             	pushl  0x10(%ebp)
  800957:	ff 75 0c             	pushl  0xc(%ebp)
  80095a:	ff 75 08             	pushl  0x8(%ebp)
  80095d:	e8 87 ff ff ff       	call   8008e9 <memmove>
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096f:	89 c6                	mov    %eax,%esi
  800971:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800974:	eb 1a                	jmp    800990 <memcmp+0x2c>
		if (*s1 != *s2)
  800976:	0f b6 08             	movzbl (%eax),%ecx
  800979:	0f b6 1a             	movzbl (%edx),%ebx
  80097c:	38 d9                	cmp    %bl,%cl
  80097e:	74 0a                	je     80098a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800980:	0f b6 c1             	movzbl %cl,%eax
  800983:	0f b6 db             	movzbl %bl,%ebx
  800986:	29 d8                	sub    %ebx,%eax
  800988:	eb 0f                	jmp    800999 <memcmp+0x35>
		s1++, s2++;
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800990:	39 f0                	cmp    %esi,%eax
  800992:	75 e2                	jne    800976 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800999:	5b                   	pop    %ebx
  80099a:	5e                   	pop    %esi
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a4:	89 c1                	mov    %eax,%ecx
  8009a6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ad:	eb 0a                	jmp    8009b9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009af:	0f b6 10             	movzbl (%eax),%edx
  8009b2:	39 da                	cmp    %ebx,%edx
  8009b4:	74 07                	je     8009bd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b6:	83 c0 01             	add    $0x1,%eax
  8009b9:	39 c8                	cmp    %ecx,%eax
  8009bb:	72 f2                	jb     8009af <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009bd:	5b                   	pop    %ebx
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	57                   	push   %edi
  8009c4:	56                   	push   %esi
  8009c5:	53                   	push   %ebx
  8009c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cc:	eb 03                	jmp    8009d1 <strtol+0x11>
		s++;
  8009ce:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d1:	0f b6 01             	movzbl (%ecx),%eax
  8009d4:	3c 20                	cmp    $0x20,%al
  8009d6:	74 f6                	je     8009ce <strtol+0xe>
  8009d8:	3c 09                	cmp    $0x9,%al
  8009da:	74 f2                	je     8009ce <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009dc:	3c 2b                	cmp    $0x2b,%al
  8009de:	75 0a                	jne    8009ea <strtol+0x2a>
		s++;
  8009e0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e3:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e8:	eb 11                	jmp    8009fb <strtol+0x3b>
  8009ea:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ef:	3c 2d                	cmp    $0x2d,%al
  8009f1:	75 08                	jne    8009fb <strtol+0x3b>
		s++, neg = 1;
  8009f3:	83 c1 01             	add    $0x1,%ecx
  8009f6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a01:	75 15                	jne    800a18 <strtol+0x58>
  800a03:	80 39 30             	cmpb   $0x30,(%ecx)
  800a06:	75 10                	jne    800a18 <strtol+0x58>
  800a08:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a0c:	75 7c                	jne    800a8a <strtol+0xca>
		s += 2, base = 16;
  800a0e:	83 c1 02             	add    $0x2,%ecx
  800a11:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a16:	eb 16                	jmp    800a2e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a18:	85 db                	test   %ebx,%ebx
  800a1a:	75 12                	jne    800a2e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a21:	80 39 30             	cmpb   $0x30,(%ecx)
  800a24:	75 08                	jne    800a2e <strtol+0x6e>
		s++, base = 8;
  800a26:	83 c1 01             	add    $0x1,%ecx
  800a29:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a33:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a36:	0f b6 11             	movzbl (%ecx),%edx
  800a39:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a3c:	89 f3                	mov    %esi,%ebx
  800a3e:	80 fb 09             	cmp    $0x9,%bl
  800a41:	77 08                	ja     800a4b <strtol+0x8b>
			dig = *s - '0';
  800a43:	0f be d2             	movsbl %dl,%edx
  800a46:	83 ea 30             	sub    $0x30,%edx
  800a49:	eb 22                	jmp    800a6d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a4b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a4e:	89 f3                	mov    %esi,%ebx
  800a50:	80 fb 19             	cmp    $0x19,%bl
  800a53:	77 08                	ja     800a5d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a55:	0f be d2             	movsbl %dl,%edx
  800a58:	83 ea 57             	sub    $0x57,%edx
  800a5b:	eb 10                	jmp    800a6d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a5d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a60:	89 f3                	mov    %esi,%ebx
  800a62:	80 fb 19             	cmp    $0x19,%bl
  800a65:	77 16                	ja     800a7d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a67:	0f be d2             	movsbl %dl,%edx
  800a6a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a6d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a70:	7d 0b                	jge    800a7d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a72:	83 c1 01             	add    $0x1,%ecx
  800a75:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a79:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a7b:	eb b9                	jmp    800a36 <strtol+0x76>

	if (endptr)
  800a7d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a81:	74 0d                	je     800a90 <strtol+0xd0>
		*endptr = (char *) s;
  800a83:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a86:	89 0e                	mov    %ecx,(%esi)
  800a88:	eb 06                	jmp    800a90 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8a:	85 db                	test   %ebx,%ebx
  800a8c:	74 98                	je     800a26 <strtol+0x66>
  800a8e:	eb 9e                	jmp    800a2e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a90:	89 c2                	mov    %eax,%edx
  800a92:	f7 da                	neg    %edx
  800a94:	85 ff                	test   %edi,%edi
  800a96:	0f 45 c2             	cmovne %edx,%eax
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa4:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aac:	8b 55 08             	mov    0x8(%ebp),%edx
  800aaf:	89 c3                	mov    %eax,%ebx
  800ab1:	89 c7                	mov    %eax,%edi
  800ab3:	89 c6                	mov    %eax,%esi
  800ab5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <sys_cgetc>:

int
sys_cgetc(void)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac7:	b8 01 00 00 00       	mov    $0x1,%eax
  800acc:	89 d1                	mov    %edx,%ecx
  800ace:	89 d3                	mov    %edx,%ebx
  800ad0:	89 d7                	mov    %edx,%edi
  800ad2:	89 d6                	mov    %edx,%esi
  800ad4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae9:	b8 03 00 00 00       	mov    $0x3,%eax
  800aee:	8b 55 08             	mov    0x8(%ebp),%edx
  800af1:	89 cb                	mov    %ecx,%ebx
  800af3:	89 cf                	mov    %ecx,%edi
  800af5:	89 ce                	mov    %ecx,%esi
  800af7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800af9:	85 c0                	test   %eax,%eax
  800afb:	7e 17                	jle    800b14 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afd:	83 ec 0c             	sub    $0xc,%esp
  800b00:	50                   	push   %eax
  800b01:	6a 03                	push   $0x3
  800b03:	68 84 13 80 00       	push   $0x801384
  800b08:	6a 23                	push   $0x23
  800b0a:	68 a1 13 80 00       	push   $0x8013a1
  800b0f:	e8 0b 03 00 00       	call   800e1f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2c:	89 d1                	mov    %edx,%ecx
  800b2e:	89 d3                	mov    %edx,%ebx
  800b30:	89 d7                	mov    %edx,%edi
  800b32:	89 d6                	mov    %edx,%esi
  800b34:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_yield>:

void
sys_yield(void)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
  800b46:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b4b:	89 d1                	mov    %edx,%ecx
  800b4d:	89 d3                	mov    %edx,%ebx
  800b4f:	89 d7                	mov    %edx,%edi
  800b51:	89 d6                	mov    %edx,%esi
  800b53:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
  800b60:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b63:	be 00 00 00 00       	mov    $0x0,%esi
  800b68:	b8 04 00 00 00       	mov    $0x4,%eax
  800b6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b70:	8b 55 08             	mov    0x8(%ebp),%edx
  800b73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b76:	89 f7                	mov    %esi,%edi
  800b78:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7a:	85 c0                	test   %eax,%eax
  800b7c:	7e 17                	jle    800b95 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	50                   	push   %eax
  800b82:	6a 04                	push   $0x4
  800b84:	68 84 13 80 00       	push   $0x801384
  800b89:	6a 23                	push   $0x23
  800b8b:	68 a1 13 80 00       	push   $0x8013a1
  800b90:	e8 8a 02 00 00       	call   800e1f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	7e 17                	jle    800bd7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc0:	83 ec 0c             	sub    $0xc,%esp
  800bc3:	50                   	push   %eax
  800bc4:	6a 05                	push   $0x5
  800bc6:	68 84 13 80 00       	push   $0x801384
  800bcb:	6a 23                	push   $0x23
  800bcd:	68 a1 13 80 00       	push   $0x8013a1
  800bd2:	e8 48 02 00 00       	call   800e1f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bed:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf8:	89 df                	mov    %ebx,%edi
  800bfa:	89 de                	mov    %ebx,%esi
  800bfc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	7e 17                	jle    800c19 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c02:	83 ec 0c             	sub    $0xc,%esp
  800c05:	50                   	push   %eax
  800c06:	6a 06                	push   $0x6
  800c08:	68 84 13 80 00       	push   $0x801384
  800c0d:	6a 23                	push   $0x23
  800c0f:	68 a1 13 80 00       	push   $0x8013a1
  800c14:	e8 06 02 00 00       	call   800e1f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3a:	89 df                	mov    %ebx,%edi
  800c3c:	89 de                	mov    %ebx,%esi
  800c3e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c40:	85 c0                	test   %eax,%eax
  800c42:	7e 17                	jle    800c5b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c44:	83 ec 0c             	sub    $0xc,%esp
  800c47:	50                   	push   %eax
  800c48:	6a 08                	push   $0x8
  800c4a:	68 84 13 80 00       	push   $0x801384
  800c4f:	6a 23                	push   $0x23
  800c51:	68 a1 13 80 00       	push   $0x8013a1
  800c56:	e8 c4 01 00 00       	call   800e1f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c71:	b8 09 00 00 00       	mov    $0x9,%eax
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	89 df                	mov    %ebx,%edi
  800c7e:	89 de                	mov    %ebx,%esi
  800c80:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c82:	85 c0                	test   %eax,%eax
  800c84:	7e 17                	jle    800c9d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	50                   	push   %eax
  800c8a:	6a 09                	push   $0x9
  800c8c:	68 84 13 80 00       	push   $0x801384
  800c91:	6a 23                	push   $0x23
  800c93:	68 a1 13 80 00       	push   $0x8013a1
  800c98:	e8 82 01 00 00       	call   800e1f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	be 00 00 00 00       	mov    $0x0,%esi
  800cb0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	89 cb                	mov    %ecx,%ebx
  800ce0:	89 cf                	mov    %ecx,%edi
  800ce2:	89 ce                	mov    %ecx,%esi
  800ce4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7e 17                	jle    800d01 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cea:	83 ec 0c             	sub    $0xc,%esp
  800ced:	50                   	push   %eax
  800cee:	6a 0c                	push   $0xc
  800cf0:	68 84 13 80 00       	push   $0x801384
  800cf5:	6a 23                	push   $0x23
  800cf7:	68 a1 13 80 00       	push   $0x8013a1
  800cfc:	e8 1e 01 00 00       	call   800e1f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_change_pr>:

int
sys_change_pr(int pr)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d14:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	89 cb                	mov    %ecx,%ebx
  800d1e:	89 cf                	mov    %ecx,%edi
  800d20:	89 ce                	mov    %ecx,%esi
  800d22:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
  800d2e:	8b 75 08             	mov    0x8(%ebp),%esi
  800d31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d34:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  800d37:	85 f6                	test   %esi,%esi
  800d39:	74 06                	je     800d41 <ipc_recv+0x18>
  800d3b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  800d41:	85 db                	test   %ebx,%ebx
  800d43:	74 06                	je     800d4b <ipc_recv+0x22>
  800d45:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800d52:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	50                   	push   %eax
  800d59:	e8 6a ff ff ff       	call   800cc8 <sys_ipc_recv>
	if (ret) return ret;
  800d5e:	83 c4 10             	add    $0x10,%esp
  800d61:	85 c0                	test   %eax,%eax
  800d63:	75 24                	jne    800d89 <ipc_recv+0x60>
	if (from_env_store)
  800d65:	85 f6                	test   %esi,%esi
  800d67:	74 0a                	je     800d73 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  800d69:	a1 04 20 80 00       	mov    0x802004,%eax
  800d6e:	8b 40 74             	mov    0x74(%eax),%eax
  800d71:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  800d73:	85 db                	test   %ebx,%ebx
  800d75:	74 0a                	je     800d81 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  800d77:	a1 04 20 80 00       	mov    0x802004,%eax
  800d7c:	8b 40 78             	mov    0x78(%eax),%eax
  800d7f:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  800d81:	a1 04 20 80 00       	mov    0x802004,%eax
  800d86:	8b 40 70             	mov    0x70(%eax),%eax
}
  800d89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5d                   	pop    %ebp
  800d8f:	c3                   	ret    

00800d90 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	57                   	push   %edi
  800d94:	56                   	push   %esi
  800d95:	53                   	push   %ebx
  800d96:	83 ec 0c             	sub    $0xc,%esp
  800d99:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  800da2:	85 db                	test   %ebx,%ebx
  800da4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800da9:	0f 44 d8             	cmove  %eax,%ebx
  800dac:	eb 1c                	jmp    800dca <ipc_send+0x3a>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  800dae:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800db1:	74 12                	je     800dc5 <ipc_send+0x35>
  800db3:	50                   	push   %eax
  800db4:	68 af 13 80 00       	push   $0x8013af
  800db9:	6a 36                	push   $0x36
  800dbb:	68 c6 13 80 00       	push   $0x8013c6
  800dc0:	e8 5a 00 00 00       	call   800e1f <_panic>
		sys_yield();
  800dc5:	e8 71 fd ff ff       	call   800b3b <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  800dca:	ff 75 14             	pushl  0x14(%ebp)
  800dcd:	53                   	push   %ebx
  800dce:	56                   	push   %esi
  800dcf:	57                   	push   %edi
  800dd0:	e8 d0 fe ff ff       	call   800ca5 <sys_ipc_try_send>
		if (ret == 0) break;
  800dd5:	83 c4 10             	add    $0x10,%esp
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	75 d2                	jne    800dae <ipc_send+0x1e>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
		sys_yield();
	}
}
  800ddc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddf:	5b                   	pop    %ebx
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800dea:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800def:	89 c2                	mov    %eax,%edx
  800df1:	c1 e2 07             	shl    $0x7,%edx
  800df4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800dfa:	8b 52 50             	mov    0x50(%edx),%edx
  800dfd:	39 ca                	cmp    %ecx,%edx
  800dff:	75 0d                	jne    800e0e <ipc_find_env+0x2a>
			return envs[i].env_id;
  800e01:	c1 e0 07             	shl    $0x7,%eax
  800e04:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e09:	8b 40 48             	mov    0x48(%eax),%eax
  800e0c:	eb 0f                	jmp    800e1d <ipc_find_env+0x39>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e0e:	83 c0 01             	add    $0x1,%eax
  800e11:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e16:	75 d7                	jne    800def <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800e24:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e27:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e2d:	e8 ea fc ff ff       	call   800b1c <sys_getenvid>
  800e32:	83 ec 0c             	sub    $0xc,%esp
  800e35:	ff 75 0c             	pushl  0xc(%ebp)
  800e38:	ff 75 08             	pushl  0x8(%ebp)
  800e3b:	56                   	push   %esi
  800e3c:	50                   	push   %eax
  800e3d:	68 d0 13 80 00       	push   $0x8013d0
  800e42:	e8 45 f3 ff ff       	call   80018c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e47:	83 c4 18             	add    $0x18,%esp
  800e4a:	53                   	push   %ebx
  800e4b:	ff 75 10             	pushl  0x10(%ebp)
  800e4e:	e8 e8 f2 ff ff       	call   80013b <vcprintf>
	cprintf("\n");
  800e53:	c7 04 24 0f 11 80 00 	movl   $0x80110f,(%esp)
  800e5a:	e8 2d f3 ff ff       	call   80018c <cprintf>
  800e5f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e62:	cc                   	int3   
  800e63:	eb fd                	jmp    800e62 <_panic+0x43>
  800e65:	66 90                	xchg   %ax,%ax
  800e67:	66 90                	xchg   %ax,%ax
  800e69:	66 90                	xchg   %ax,%ax
  800e6b:	66 90                	xchg   %ax,%ax
  800e6d:	66 90                	xchg   %ax,%ax
  800e6f:	90                   	nop

00800e70 <__udivdi3>:
  800e70:	55                   	push   %ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 1c             	sub    $0x1c,%esp
  800e77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e87:	85 f6                	test   %esi,%esi
  800e89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e8d:	89 ca                	mov    %ecx,%edx
  800e8f:	89 f8                	mov    %edi,%eax
  800e91:	75 3d                	jne    800ed0 <__udivdi3+0x60>
  800e93:	39 cf                	cmp    %ecx,%edi
  800e95:	0f 87 c5 00 00 00    	ja     800f60 <__udivdi3+0xf0>
  800e9b:	85 ff                	test   %edi,%edi
  800e9d:	89 fd                	mov    %edi,%ebp
  800e9f:	75 0b                	jne    800eac <__udivdi3+0x3c>
  800ea1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea6:	31 d2                	xor    %edx,%edx
  800ea8:	f7 f7                	div    %edi
  800eaa:	89 c5                	mov    %eax,%ebp
  800eac:	89 c8                	mov    %ecx,%eax
  800eae:	31 d2                	xor    %edx,%edx
  800eb0:	f7 f5                	div    %ebp
  800eb2:	89 c1                	mov    %eax,%ecx
  800eb4:	89 d8                	mov    %ebx,%eax
  800eb6:	89 cf                	mov    %ecx,%edi
  800eb8:	f7 f5                	div    %ebp
  800eba:	89 c3                	mov    %eax,%ebx
  800ebc:	89 d8                	mov    %ebx,%eax
  800ebe:	89 fa                	mov    %edi,%edx
  800ec0:	83 c4 1c             	add    $0x1c,%esp
  800ec3:	5b                   	pop    %ebx
  800ec4:	5e                   	pop    %esi
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    
  800ec8:	90                   	nop
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	39 ce                	cmp    %ecx,%esi
  800ed2:	77 74                	ja     800f48 <__udivdi3+0xd8>
  800ed4:	0f bd fe             	bsr    %esi,%edi
  800ed7:	83 f7 1f             	xor    $0x1f,%edi
  800eda:	0f 84 98 00 00 00    	je     800f78 <__udivdi3+0x108>
  800ee0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800ee5:	89 f9                	mov    %edi,%ecx
  800ee7:	89 c5                	mov    %eax,%ebp
  800ee9:	29 fb                	sub    %edi,%ebx
  800eeb:	d3 e6                	shl    %cl,%esi
  800eed:	89 d9                	mov    %ebx,%ecx
  800eef:	d3 ed                	shr    %cl,%ebp
  800ef1:	89 f9                	mov    %edi,%ecx
  800ef3:	d3 e0                	shl    %cl,%eax
  800ef5:	09 ee                	or     %ebp,%esi
  800ef7:	89 d9                	mov    %ebx,%ecx
  800ef9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800efd:	89 d5                	mov    %edx,%ebp
  800eff:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f03:	d3 ed                	shr    %cl,%ebp
  800f05:	89 f9                	mov    %edi,%ecx
  800f07:	d3 e2                	shl    %cl,%edx
  800f09:	89 d9                	mov    %ebx,%ecx
  800f0b:	d3 e8                	shr    %cl,%eax
  800f0d:	09 c2                	or     %eax,%edx
  800f0f:	89 d0                	mov    %edx,%eax
  800f11:	89 ea                	mov    %ebp,%edx
  800f13:	f7 f6                	div    %esi
  800f15:	89 d5                	mov    %edx,%ebp
  800f17:	89 c3                	mov    %eax,%ebx
  800f19:	f7 64 24 0c          	mull   0xc(%esp)
  800f1d:	39 d5                	cmp    %edx,%ebp
  800f1f:	72 10                	jb     800f31 <__udivdi3+0xc1>
  800f21:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f25:	89 f9                	mov    %edi,%ecx
  800f27:	d3 e6                	shl    %cl,%esi
  800f29:	39 c6                	cmp    %eax,%esi
  800f2b:	73 07                	jae    800f34 <__udivdi3+0xc4>
  800f2d:	39 d5                	cmp    %edx,%ebp
  800f2f:	75 03                	jne    800f34 <__udivdi3+0xc4>
  800f31:	83 eb 01             	sub    $0x1,%ebx
  800f34:	31 ff                	xor    %edi,%edi
  800f36:	89 d8                	mov    %ebx,%eax
  800f38:	89 fa                	mov    %edi,%edx
  800f3a:	83 c4 1c             	add    $0x1c,%esp
  800f3d:	5b                   	pop    %ebx
  800f3e:	5e                   	pop    %esi
  800f3f:	5f                   	pop    %edi
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    
  800f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f48:	31 ff                	xor    %edi,%edi
  800f4a:	31 db                	xor    %ebx,%ebx
  800f4c:	89 d8                	mov    %ebx,%eax
  800f4e:	89 fa                	mov    %edi,%edx
  800f50:	83 c4 1c             	add    $0x1c,%esp
  800f53:	5b                   	pop    %ebx
  800f54:	5e                   	pop    %esi
  800f55:	5f                   	pop    %edi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    
  800f58:	90                   	nop
  800f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f60:	89 d8                	mov    %ebx,%eax
  800f62:	f7 f7                	div    %edi
  800f64:	31 ff                	xor    %edi,%edi
  800f66:	89 c3                	mov    %eax,%ebx
  800f68:	89 d8                	mov    %ebx,%eax
  800f6a:	89 fa                	mov    %edi,%edx
  800f6c:	83 c4 1c             	add    $0x1c,%esp
  800f6f:	5b                   	pop    %ebx
  800f70:	5e                   	pop    %esi
  800f71:	5f                   	pop    %edi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    
  800f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f78:	39 ce                	cmp    %ecx,%esi
  800f7a:	72 0c                	jb     800f88 <__udivdi3+0x118>
  800f7c:	31 db                	xor    %ebx,%ebx
  800f7e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f82:	0f 87 34 ff ff ff    	ja     800ebc <__udivdi3+0x4c>
  800f88:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f8d:	e9 2a ff ff ff       	jmp    800ebc <__udivdi3+0x4c>
  800f92:	66 90                	xchg   %ax,%ax
  800f94:	66 90                	xchg   %ax,%ax
  800f96:	66 90                	xchg   %ax,%ax
  800f98:	66 90                	xchg   %ax,%ax
  800f9a:	66 90                	xchg   %ax,%ax
  800f9c:	66 90                	xchg   %ax,%ax
  800f9e:	66 90                	xchg   %ax,%ax

00800fa0 <__umoddi3>:
  800fa0:	55                   	push   %ebp
  800fa1:	57                   	push   %edi
  800fa2:	56                   	push   %esi
  800fa3:	53                   	push   %ebx
  800fa4:	83 ec 1c             	sub    $0x1c,%esp
  800fa7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800fab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800faf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800fb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fb7:	85 d2                	test   %edx,%edx
  800fb9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800fbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fc1:	89 f3                	mov    %esi,%ebx
  800fc3:	89 3c 24             	mov    %edi,(%esp)
  800fc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fca:	75 1c                	jne    800fe8 <__umoddi3+0x48>
  800fcc:	39 f7                	cmp    %esi,%edi
  800fce:	76 50                	jbe    801020 <__umoddi3+0x80>
  800fd0:	89 c8                	mov    %ecx,%eax
  800fd2:	89 f2                	mov    %esi,%edx
  800fd4:	f7 f7                	div    %edi
  800fd6:	89 d0                	mov    %edx,%eax
  800fd8:	31 d2                	xor    %edx,%edx
  800fda:	83 c4 1c             	add    $0x1c,%esp
  800fdd:	5b                   	pop    %ebx
  800fde:	5e                   	pop    %esi
  800fdf:	5f                   	pop    %edi
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    
  800fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fe8:	39 f2                	cmp    %esi,%edx
  800fea:	89 d0                	mov    %edx,%eax
  800fec:	77 52                	ja     801040 <__umoddi3+0xa0>
  800fee:	0f bd ea             	bsr    %edx,%ebp
  800ff1:	83 f5 1f             	xor    $0x1f,%ebp
  800ff4:	75 5a                	jne    801050 <__umoddi3+0xb0>
  800ff6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800ffa:	0f 82 e0 00 00 00    	jb     8010e0 <__umoddi3+0x140>
  801000:	39 0c 24             	cmp    %ecx,(%esp)
  801003:	0f 86 d7 00 00 00    	jbe    8010e0 <__umoddi3+0x140>
  801009:	8b 44 24 08          	mov    0x8(%esp),%eax
  80100d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801011:	83 c4 1c             	add    $0x1c,%esp
  801014:	5b                   	pop    %ebx
  801015:	5e                   	pop    %esi
  801016:	5f                   	pop    %edi
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    
  801019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801020:	85 ff                	test   %edi,%edi
  801022:	89 fd                	mov    %edi,%ebp
  801024:	75 0b                	jne    801031 <__umoddi3+0x91>
  801026:	b8 01 00 00 00       	mov    $0x1,%eax
  80102b:	31 d2                	xor    %edx,%edx
  80102d:	f7 f7                	div    %edi
  80102f:	89 c5                	mov    %eax,%ebp
  801031:	89 f0                	mov    %esi,%eax
  801033:	31 d2                	xor    %edx,%edx
  801035:	f7 f5                	div    %ebp
  801037:	89 c8                	mov    %ecx,%eax
  801039:	f7 f5                	div    %ebp
  80103b:	89 d0                	mov    %edx,%eax
  80103d:	eb 99                	jmp    800fd8 <__umoddi3+0x38>
  80103f:	90                   	nop
  801040:	89 c8                	mov    %ecx,%eax
  801042:	89 f2                	mov    %esi,%edx
  801044:	83 c4 1c             	add    $0x1c,%esp
  801047:	5b                   	pop    %ebx
  801048:	5e                   	pop    %esi
  801049:	5f                   	pop    %edi
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    
  80104c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801050:	8b 34 24             	mov    (%esp),%esi
  801053:	bf 20 00 00 00       	mov    $0x20,%edi
  801058:	89 e9                	mov    %ebp,%ecx
  80105a:	29 ef                	sub    %ebp,%edi
  80105c:	d3 e0                	shl    %cl,%eax
  80105e:	89 f9                	mov    %edi,%ecx
  801060:	89 f2                	mov    %esi,%edx
  801062:	d3 ea                	shr    %cl,%edx
  801064:	89 e9                	mov    %ebp,%ecx
  801066:	09 c2                	or     %eax,%edx
  801068:	89 d8                	mov    %ebx,%eax
  80106a:	89 14 24             	mov    %edx,(%esp)
  80106d:	89 f2                	mov    %esi,%edx
  80106f:	d3 e2                	shl    %cl,%edx
  801071:	89 f9                	mov    %edi,%ecx
  801073:	89 54 24 04          	mov    %edx,0x4(%esp)
  801077:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80107b:	d3 e8                	shr    %cl,%eax
  80107d:	89 e9                	mov    %ebp,%ecx
  80107f:	89 c6                	mov    %eax,%esi
  801081:	d3 e3                	shl    %cl,%ebx
  801083:	89 f9                	mov    %edi,%ecx
  801085:	89 d0                	mov    %edx,%eax
  801087:	d3 e8                	shr    %cl,%eax
  801089:	89 e9                	mov    %ebp,%ecx
  80108b:	09 d8                	or     %ebx,%eax
  80108d:	89 d3                	mov    %edx,%ebx
  80108f:	89 f2                	mov    %esi,%edx
  801091:	f7 34 24             	divl   (%esp)
  801094:	89 d6                	mov    %edx,%esi
  801096:	d3 e3                	shl    %cl,%ebx
  801098:	f7 64 24 04          	mull   0x4(%esp)
  80109c:	39 d6                	cmp    %edx,%esi
  80109e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010a2:	89 d1                	mov    %edx,%ecx
  8010a4:	89 c3                	mov    %eax,%ebx
  8010a6:	72 08                	jb     8010b0 <__umoddi3+0x110>
  8010a8:	75 11                	jne    8010bb <__umoddi3+0x11b>
  8010aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8010ae:	73 0b                	jae    8010bb <__umoddi3+0x11b>
  8010b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8010b4:	1b 14 24             	sbb    (%esp),%edx
  8010b7:	89 d1                	mov    %edx,%ecx
  8010b9:	89 c3                	mov    %eax,%ebx
  8010bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8010bf:	29 da                	sub    %ebx,%edx
  8010c1:	19 ce                	sbb    %ecx,%esi
  8010c3:	89 f9                	mov    %edi,%ecx
  8010c5:	89 f0                	mov    %esi,%eax
  8010c7:	d3 e0                	shl    %cl,%eax
  8010c9:	89 e9                	mov    %ebp,%ecx
  8010cb:	d3 ea                	shr    %cl,%edx
  8010cd:	89 e9                	mov    %ebp,%ecx
  8010cf:	d3 ee                	shr    %cl,%esi
  8010d1:	09 d0                	or     %edx,%eax
  8010d3:	89 f2                	mov    %esi,%edx
  8010d5:	83 c4 1c             	add    $0x1c,%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5f                   	pop    %edi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    
  8010dd:	8d 76 00             	lea    0x0(%esi),%esi
  8010e0:	29 f9                	sub    %edi,%ecx
  8010e2:	19 d6                	sbb    %edx,%esi
  8010e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010ec:	e9 18 ff ff ff       	jmp    801009 <__umoddi3+0x69>
