
obj/user/pingpong：     文件格式 elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 9a 0e 00 00       	call   800edb <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 ea 0a 00 00       	call   800b39 <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 a0 15 80 00       	push   $0x8015a0
  800059:	e8 4b 01 00 00       	call   8001a9 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 21 11 00 00       	call   80118d <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 a7 10 00 00       	call   801126 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 b0 0a 00 00       	call   800b39 <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 b6 15 80 00       	push   $0x8015b6
  800091:	e8 13 01 00 00       	call   8001a9 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 df 10 00 00       	call   80118d <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  8000c9:	e8 6b 0a 00 00       	call   800b39 <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	c1 e0 07             	shl    $0x7,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010a:	6a 00                	push   $0x0
  80010c:	e8 e7 09 00 00       	call   800af8 <sys_env_destroy>
}
  800111:	83 c4 10             	add    $0x10,%esp
  800114:	c9                   	leave  
  800115:	c3                   	ret    

00800116 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	53                   	push   %ebx
  80011a:	83 ec 04             	sub    $0x4,%esp
  80011d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800120:	8b 13                	mov    (%ebx),%edx
  800122:	8d 42 01             	lea    0x1(%edx),%eax
  800125:	89 03                	mov    %eax,(%ebx)
  800127:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800133:	75 1a                	jne    80014f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800135:	83 ec 08             	sub    $0x8,%esp
  800138:	68 ff 00 00 00       	push   $0xff
  80013d:	8d 43 08             	lea    0x8(%ebx),%eax
  800140:	50                   	push   %eax
  800141:	e8 75 09 00 00       	call   800abb <sys_cputs>
		b->idx = 0;
  800146:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800153:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800161:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800168:	00 00 00 
	b.cnt = 0;
  80016b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800172:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800175:	ff 75 0c             	pushl  0xc(%ebp)
  800178:	ff 75 08             	pushl  0x8(%ebp)
  80017b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800181:	50                   	push   %eax
  800182:	68 16 01 80 00       	push   $0x800116
  800187:	e8 54 01 00 00       	call   8002e0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018c:	83 c4 08             	add    $0x8,%esp
  80018f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800195:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019b:	50                   	push   %eax
  80019c:	e8 1a 09 00 00       	call   800abb <sys_cputs>

	return b.cnt;
}
  8001a1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b2:	50                   	push   %eax
  8001b3:	ff 75 08             	pushl  0x8(%ebp)
  8001b6:	e8 9d ff ff ff       	call   800158 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	57                   	push   %edi
  8001c1:	56                   	push   %esi
  8001c2:	53                   	push   %ebx
  8001c3:	83 ec 1c             	sub    $0x1c,%esp
  8001c6:	89 c7                	mov    %eax,%edi
  8001c8:	89 d6                	mov    %edx,%esi
  8001ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001de:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e4:	39 d3                	cmp    %edx,%ebx
  8001e6:	72 05                	jb     8001ed <printnum+0x30>
  8001e8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001eb:	77 45                	ja     800232 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ed:	83 ec 0c             	sub    $0xc,%esp
  8001f0:	ff 75 18             	pushl  0x18(%ebp)
  8001f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f9:	53                   	push   %ebx
  8001fa:	ff 75 10             	pushl  0x10(%ebp)
  8001fd:	83 ec 08             	sub    $0x8,%esp
  800200:	ff 75 e4             	pushl  -0x1c(%ebp)
  800203:	ff 75 e0             	pushl  -0x20(%ebp)
  800206:	ff 75 dc             	pushl  -0x24(%ebp)
  800209:	ff 75 d8             	pushl  -0x28(%ebp)
  80020c:	e8 ef 10 00 00       	call   801300 <__udivdi3>
  800211:	83 c4 18             	add    $0x18,%esp
  800214:	52                   	push   %edx
  800215:	50                   	push   %eax
  800216:	89 f2                	mov    %esi,%edx
  800218:	89 f8                	mov    %edi,%eax
  80021a:	e8 9e ff ff ff       	call   8001bd <printnum>
  80021f:	83 c4 20             	add    $0x20,%esp
  800222:	eb 18                	jmp    80023c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	56                   	push   %esi
  800228:	ff 75 18             	pushl  0x18(%ebp)
  80022b:	ff d7                	call   *%edi
  80022d:	83 c4 10             	add    $0x10,%esp
  800230:	eb 03                	jmp    800235 <printnum+0x78>
  800232:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800235:	83 eb 01             	sub    $0x1,%ebx
  800238:	85 db                	test   %ebx,%ebx
  80023a:	7f e8                	jg     800224 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023c:	83 ec 08             	sub    $0x8,%esp
  80023f:	56                   	push   %esi
  800240:	83 ec 04             	sub    $0x4,%esp
  800243:	ff 75 e4             	pushl  -0x1c(%ebp)
  800246:	ff 75 e0             	pushl  -0x20(%ebp)
  800249:	ff 75 dc             	pushl  -0x24(%ebp)
  80024c:	ff 75 d8             	pushl  -0x28(%ebp)
  80024f:	e8 dc 11 00 00       	call   801430 <__umoddi3>
  800254:	83 c4 14             	add    $0x14,%esp
  800257:	0f be 80 d3 15 80 00 	movsbl 0x8015d3(%eax),%eax
  80025e:	50                   	push   %eax
  80025f:	ff d7                	call   *%edi
}
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026f:	83 fa 01             	cmp    $0x1,%edx
  800272:	7e 0e                	jle    800282 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 08             	lea    0x8(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	8b 52 04             	mov    0x4(%edx),%edx
  800280:	eb 22                	jmp    8002a4 <getuint+0x38>
	else if (lflag)
  800282:	85 d2                	test   %edx,%edx
  800284:	74 10                	je     800296 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800286:	8b 10                	mov    (%eax),%edx
  800288:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 02                	mov    (%edx),%eax
  80028f:	ba 00 00 00 00       	mov    $0x0,%edx
  800294:	eb 0e                	jmp    8002a4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800296:	8b 10                	mov    (%eax),%edx
  800298:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029b:	89 08                	mov    %ecx,(%eax)
  80029d:	8b 02                	mov    (%edx),%eax
  80029f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ac:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b5:	73 0a                	jae    8002c1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ba:	89 08                	mov    %ecx,(%eax)
  8002bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bf:	88 02                	mov    %al,(%edx)
}
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cc:	50                   	push   %eax
  8002cd:	ff 75 10             	pushl  0x10(%ebp)
  8002d0:	ff 75 0c             	pushl  0xc(%ebp)
  8002d3:	ff 75 08             	pushl  0x8(%ebp)
  8002d6:	e8 05 00 00 00       	call   8002e0 <vprintfmt>
	va_end(ap);
}
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	c9                   	leave  
  8002df:	c3                   	ret    

008002e0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 2c             	sub    $0x2c,%esp
  8002e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ef:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f2:	eb 1d                	jmp    800311 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	75 0f                	jne    800307 <vprintfmt+0x27>
				csa = 0x0700;
  8002f8:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  8002ff:	07 00 00 
				return;
  800302:	e9 c4 03 00 00       	jmp    8006cb <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	53                   	push   %ebx
  80030b:	50                   	push   %eax
  80030c:	ff d6                	call   *%esi
  80030e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800311:	83 c7 01             	add    $0x1,%edi
  800314:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800318:	83 f8 25             	cmp    $0x25,%eax
  80031b:	75 d7                	jne    8002f4 <vprintfmt+0x14>
  80031d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800321:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800328:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800336:	ba 00 00 00 00       	mov    $0x0,%edx
  80033b:	eb 07                	jmp    800344 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800340:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8d 47 01             	lea    0x1(%edi),%eax
  800347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034a:	0f b6 07             	movzbl (%edi),%eax
  80034d:	0f b6 c8             	movzbl %al,%ecx
  800350:	83 e8 23             	sub    $0x23,%eax
  800353:	3c 55                	cmp    $0x55,%al
  800355:	0f 87 55 03 00 00    	ja     8006b0 <vprintfmt+0x3d0>
  80035b:	0f b6 c0             	movzbl %al,%eax
  80035e:	ff 24 85 a0 16 80 00 	jmp    *0x8016a0(,%eax,4)
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036c:	eb d6                	jmp    800344 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800371:	b8 00 00 00 00       	mov    $0x0,%eax
  800376:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800379:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800380:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800383:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800386:	83 fa 09             	cmp    $0x9,%edx
  800389:	77 39                	ja     8003c4 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038e:	eb e9                	jmp    800379 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 48 04             	lea    0x4(%eax),%ecx
  800396:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800399:	8b 00                	mov    (%eax),%eax
  80039b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a1:	eb 27                	jmp    8003ca <vprintfmt+0xea>
  8003a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ad:	0f 49 c8             	cmovns %eax,%ecx
  8003b0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b6:	eb 8c                	jmp    800344 <vprintfmt+0x64>
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c2:	eb 80                	jmp    800344 <vprintfmt+0x64>
  8003c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ce:	0f 89 70 ff ff ff    	jns    800344 <vprintfmt+0x64>
				width = precision, precision = -1;
  8003d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e1:	e9 5e ff ff ff       	jmp    800344 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ec:	e9 53 ff ff ff       	jmp    800344 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 50 04             	lea    0x4(%eax),%edx
  8003f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fa:	83 ec 08             	sub    $0x8,%esp
  8003fd:	53                   	push   %ebx
  8003fe:	ff 30                	pushl  (%eax)
  800400:	ff d6                	call   *%esi
			break;
  800402:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800408:	e9 04 ff ff ff       	jmp    800311 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 50 04             	lea    0x4(%eax),%edx
  800413:	89 55 14             	mov    %edx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	99                   	cltd   
  800419:	31 d0                	xor    %edx,%eax
  80041b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041d:	83 f8 08             	cmp    $0x8,%eax
  800420:	7f 0b                	jg     80042d <vprintfmt+0x14d>
  800422:	8b 14 85 00 18 80 00 	mov    0x801800(,%eax,4),%edx
  800429:	85 d2                	test   %edx,%edx
  80042b:	75 18                	jne    800445 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  80042d:	50                   	push   %eax
  80042e:	68 eb 15 80 00       	push   $0x8015eb
  800433:	53                   	push   %ebx
  800434:	56                   	push   %esi
  800435:	e8 89 fe ff ff       	call   8002c3 <printfmt>
  80043a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800440:	e9 cc fe ff ff       	jmp    800311 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  800445:	52                   	push   %edx
  800446:	68 f4 15 80 00       	push   $0x8015f4
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 71 fe ff ff       	call   8002c3 <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800458:	e9 b4 fe ff ff       	jmp    800311 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 50 04             	lea    0x4(%eax),%edx
  800463:	89 55 14             	mov    %edx,0x14(%ebp)
  800466:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800468:	85 ff                	test   %edi,%edi
  80046a:	b8 e4 15 80 00       	mov    $0x8015e4,%eax
  80046f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800472:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800476:	0f 8e 94 00 00 00    	jle    800510 <vprintfmt+0x230>
  80047c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800480:	0f 84 98 00 00 00    	je     80051e <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	ff 75 d0             	pushl  -0x30(%ebp)
  80048c:	57                   	push   %edi
  80048d:	e8 c1 02 00 00       	call   800753 <strnlen>
  800492:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800495:	29 c1                	sub    %eax,%ecx
  800497:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80049a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	eb 0f                	jmp    8004ba <vprintfmt+0x1da>
					putch(padc, putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	53                   	push   %ebx
  8004af:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b4:	83 ef 01             	sub    $0x1,%edi
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 ff                	test   %edi,%edi
  8004bc:	7f ed                	jg     8004ab <vprintfmt+0x1cb>
  8004be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c4:	85 c9                	test   %ecx,%ecx
  8004c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cb:	0f 49 c1             	cmovns %ecx,%eax
  8004ce:	29 c1                	sub    %eax,%ecx
  8004d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d9:	89 cb                	mov    %ecx,%ebx
  8004db:	eb 4d                	jmp    80052a <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e1:	74 1b                	je     8004fe <vprintfmt+0x21e>
  8004e3:	0f be c0             	movsbl %al,%eax
  8004e6:	83 e8 20             	sub    $0x20,%eax
  8004e9:	83 f8 5e             	cmp    $0x5e,%eax
  8004ec:	76 10                	jbe    8004fe <vprintfmt+0x21e>
					putch('?', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	ff 75 0c             	pushl  0xc(%ebp)
  8004f4:	6a 3f                	push   $0x3f
  8004f6:	ff 55 08             	call   *0x8(%ebp)
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb 0d                	jmp    80050b <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	ff 75 0c             	pushl  0xc(%ebp)
  800504:	52                   	push   %edx
  800505:	ff 55 08             	call   *0x8(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050b:	83 eb 01             	sub    $0x1,%ebx
  80050e:	eb 1a                	jmp    80052a <vprintfmt+0x24a>
  800510:	89 75 08             	mov    %esi,0x8(%ebp)
  800513:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800516:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800519:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051c:	eb 0c                	jmp    80052a <vprintfmt+0x24a>
  80051e:	89 75 08             	mov    %esi,0x8(%ebp)
  800521:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800524:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800527:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052a:	83 c7 01             	add    $0x1,%edi
  80052d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800531:	0f be d0             	movsbl %al,%edx
  800534:	85 d2                	test   %edx,%edx
  800536:	74 23                	je     80055b <vprintfmt+0x27b>
  800538:	85 f6                	test   %esi,%esi
  80053a:	78 a1                	js     8004dd <vprintfmt+0x1fd>
  80053c:	83 ee 01             	sub    $0x1,%esi
  80053f:	79 9c                	jns    8004dd <vprintfmt+0x1fd>
  800541:	89 df                	mov    %ebx,%edi
  800543:	8b 75 08             	mov    0x8(%ebp),%esi
  800546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800549:	eb 18                	jmp    800563 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	6a 20                	push   $0x20
  800551:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800553:	83 ef 01             	sub    $0x1,%edi
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb 08                	jmp    800563 <vprintfmt+0x283>
  80055b:	89 df                	mov    %ebx,%edi
  80055d:	8b 75 08             	mov    0x8(%ebp),%esi
  800560:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800563:	85 ff                	test   %edi,%edi
  800565:	7f e4                	jg     80054b <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056a:	e9 a2 fd ff ff       	jmp    800311 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056f:	83 fa 01             	cmp    $0x1,%edx
  800572:	7e 16                	jle    80058a <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 08             	lea    0x8(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 50 04             	mov    0x4(%eax),%edx
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800585:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800588:	eb 32                	jmp    8005bc <vprintfmt+0x2dc>
	else if (lflag)
  80058a:	85 d2                	test   %edx,%edx
  80058c:	74 18                	je     8005a6 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 50 04             	lea    0x4(%eax),%edx
  800594:	89 55 14             	mov    %edx,0x14(%ebp)
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059c:	89 c1                	mov    %eax,%ecx
  80059e:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a4:	eb 16                	jmp    8005bc <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b4:	89 c1                	mov    %eax,%ecx
  8005b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005cb:	79 74                	jns    800641 <vprintfmt+0x361>
				putch('-', putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	53                   	push   %ebx
  8005d1:	6a 2d                	push   $0x2d
  8005d3:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005db:	f7 d8                	neg    %eax
  8005dd:	83 d2 00             	adc    $0x0,%edx
  8005e0:	f7 da                	neg    %edx
  8005e2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ea:	eb 55                	jmp    800641 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ef:	e8 78 fc ff ff       	call   80026c <getuint>
			base = 10;
  8005f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f9:	eb 46                	jmp    800641 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  8005fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fe:	e8 69 fc ff ff       	call   80026c <getuint>
      base = 8;
  800603:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800608:	eb 37                	jmp    800641 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 30                	push   $0x30
  800610:	ff d6                	call   *%esi
			putch('x', putdat);
  800612:	83 c4 08             	add    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 78                	push   $0x78
  800618:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800623:	8b 00                	mov    (%eax),%eax
  800625:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800632:	eb 0d                	jmp    800641 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800634:	8d 45 14             	lea    0x14(%ebp),%eax
  800637:	e8 30 fc ff ff       	call   80026c <getuint>
			base = 16;
  80063c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800641:	83 ec 0c             	sub    $0xc,%esp
  800644:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800648:	57                   	push   %edi
  800649:	ff 75 e0             	pushl  -0x20(%ebp)
  80064c:	51                   	push   %ecx
  80064d:	52                   	push   %edx
  80064e:	50                   	push   %eax
  80064f:	89 da                	mov    %ebx,%edx
  800651:	89 f0                	mov    %esi,%eax
  800653:	e8 65 fb ff ff       	call   8001bd <printnum>
			break;
  800658:	83 c4 20             	add    $0x20,%esp
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065e:	e9 ae fc ff ff       	jmp    800311 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	51                   	push   %ecx
  800668:	ff d6                	call   *%esi
			break;
  80066a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800670:	e9 9c fc ff ff       	jmp    800311 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800675:	83 fa 01             	cmp    $0x1,%edx
  800678:	7e 0d                	jle    800687 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 50 08             	lea    0x8(%eax),%edx
  800680:	89 55 14             	mov    %edx,0x14(%ebp)
  800683:	8b 00                	mov    (%eax),%eax
  800685:	eb 1c                	jmp    8006a3 <vprintfmt+0x3c3>
	else if (lflag)
  800687:	85 d2                	test   %edx,%edx
  800689:	74 0d                	je     800698 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8d 50 04             	lea    0x4(%eax),%edx
  800691:	89 55 14             	mov    %edx,0x14(%ebp)
  800694:	8b 00                	mov    (%eax),%eax
  800696:	eb 0b                	jmp    8006a3 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  8006a3:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  8006ab:	e9 61 fc ff ff       	jmp    800311 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b0:	83 ec 08             	sub    $0x8,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	6a 25                	push   $0x25
  8006b6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	eb 03                	jmp    8006c0 <vprintfmt+0x3e0>
  8006bd:	83 ef 01             	sub    $0x1,%edi
  8006c0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c4:	75 f7                	jne    8006bd <vprintfmt+0x3dd>
  8006c6:	e9 46 fc ff ff       	jmp    800311 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  8006cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ce:	5b                   	pop    %ebx
  8006cf:	5e                   	pop    %esi
  8006d0:	5f                   	pop    %edi
  8006d1:	5d                   	pop    %ebp
  8006d2:	c3                   	ret    

008006d3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	83 ec 18             	sub    $0x18,%esp
  8006d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f0:	85 c0                	test   %eax,%eax
  8006f2:	74 26                	je     80071a <vsnprintf+0x47>
  8006f4:	85 d2                	test   %edx,%edx
  8006f6:	7e 22                	jle    80071a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f8:	ff 75 14             	pushl  0x14(%ebp)
  8006fb:	ff 75 10             	pushl  0x10(%ebp)
  8006fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800701:	50                   	push   %eax
  800702:	68 a6 02 80 00       	push   $0x8002a6
  800707:	e8 d4 fb ff ff       	call   8002e0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800712:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800715:	83 c4 10             	add    $0x10,%esp
  800718:	eb 05                	jmp    80071f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071f:	c9                   	leave  
  800720:	c3                   	ret    

00800721 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800721:	55                   	push   %ebp
  800722:	89 e5                	mov    %esp,%ebp
  800724:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800727:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072a:	50                   	push   %eax
  80072b:	ff 75 10             	pushl  0x10(%ebp)
  80072e:	ff 75 0c             	pushl  0xc(%ebp)
  800731:	ff 75 08             	pushl  0x8(%ebp)
  800734:	e8 9a ff ff ff       	call   8006d3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800739:	c9                   	leave  
  80073a:	c3                   	ret    

0080073b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800741:	b8 00 00 00 00       	mov    $0x0,%eax
  800746:	eb 03                	jmp    80074b <strlen+0x10>
		n++;
  800748:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074f:	75 f7                	jne    800748 <strlen+0xd>
		n++;
	return n;
}
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800759:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075c:	ba 00 00 00 00       	mov    $0x0,%edx
  800761:	eb 03                	jmp    800766 <strnlen+0x13>
		n++;
  800763:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800766:	39 c2                	cmp    %eax,%edx
  800768:	74 08                	je     800772 <strnlen+0x1f>
  80076a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80076e:	75 f3                	jne    800763 <strnlen+0x10>
  800770:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	53                   	push   %ebx
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077e:	89 c2                	mov    %eax,%edx
  800780:	83 c2 01             	add    $0x1,%edx
  800783:	83 c1 01             	add    $0x1,%ecx
  800786:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80078d:	84 db                	test   %bl,%bl
  80078f:	75 ef                	jne    800780 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800791:	5b                   	pop    %ebx
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	53                   	push   %ebx
  800798:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079b:	53                   	push   %ebx
  80079c:	e8 9a ff ff ff       	call   80073b <strlen>
  8007a1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a4:	ff 75 0c             	pushl  0xc(%ebp)
  8007a7:	01 d8                	add    %ebx,%eax
  8007a9:	50                   	push   %eax
  8007aa:	e8 c5 ff ff ff       	call   800774 <strcpy>
	return dst;
}
  8007af:	89 d8                	mov    %ebx,%eax
  8007b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	56                   	push   %esi
  8007ba:	53                   	push   %ebx
  8007bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c1:	89 f3                	mov    %esi,%ebx
  8007c3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c6:	89 f2                	mov    %esi,%edx
  8007c8:	eb 0f                	jmp    8007d9 <strncpy+0x23>
		*dst++ = *src;
  8007ca:	83 c2 01             	add    $0x1,%edx
  8007cd:	0f b6 01             	movzbl (%ecx),%eax
  8007d0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d9:	39 da                	cmp    %ebx,%edx
  8007db:	75 ed                	jne    8007ca <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007dd:	89 f0                	mov    %esi,%eax
  8007df:	5b                   	pop    %ebx
  8007e0:	5e                   	pop    %esi
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	56                   	push   %esi
  8007e7:	53                   	push   %ebx
  8007e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ee:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f3:	85 d2                	test   %edx,%edx
  8007f5:	74 21                	je     800818 <strlcpy+0x35>
  8007f7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fb:	89 f2                	mov    %esi,%edx
  8007fd:	eb 09                	jmp    800808 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ff:	83 c2 01             	add    $0x1,%edx
  800802:	83 c1 01             	add    $0x1,%ecx
  800805:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800808:	39 c2                	cmp    %eax,%edx
  80080a:	74 09                	je     800815 <strlcpy+0x32>
  80080c:	0f b6 19             	movzbl (%ecx),%ebx
  80080f:	84 db                	test   %bl,%bl
  800811:	75 ec                	jne    8007ff <strlcpy+0x1c>
  800813:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800815:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800818:	29 f0                	sub    %esi,%eax
}
  80081a:	5b                   	pop    %ebx
  80081b:	5e                   	pop    %esi
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800824:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800827:	eb 06                	jmp    80082f <strcmp+0x11>
		p++, q++;
  800829:	83 c1 01             	add    $0x1,%ecx
  80082c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80082f:	0f b6 01             	movzbl (%ecx),%eax
  800832:	84 c0                	test   %al,%al
  800834:	74 04                	je     80083a <strcmp+0x1c>
  800836:	3a 02                	cmp    (%edx),%al
  800838:	74 ef                	je     800829 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083a:	0f b6 c0             	movzbl %al,%eax
  80083d:	0f b6 12             	movzbl (%edx),%edx
  800840:	29 d0                	sub    %edx,%eax
}
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	53                   	push   %ebx
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084e:	89 c3                	mov    %eax,%ebx
  800850:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800853:	eb 06                	jmp    80085b <strncmp+0x17>
		n--, p++, q++;
  800855:	83 c0 01             	add    $0x1,%eax
  800858:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085b:	39 d8                	cmp    %ebx,%eax
  80085d:	74 15                	je     800874 <strncmp+0x30>
  80085f:	0f b6 08             	movzbl (%eax),%ecx
  800862:	84 c9                	test   %cl,%cl
  800864:	74 04                	je     80086a <strncmp+0x26>
  800866:	3a 0a                	cmp    (%edx),%cl
  800868:	74 eb                	je     800855 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086a:	0f b6 00             	movzbl (%eax),%eax
  80086d:	0f b6 12             	movzbl (%edx),%edx
  800870:	29 d0                	sub    %edx,%eax
  800872:	eb 05                	jmp    800879 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800874:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800879:	5b                   	pop    %ebx
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800886:	eb 07                	jmp    80088f <strchr+0x13>
		if (*s == c)
  800888:	38 ca                	cmp    %cl,%dl
  80088a:	74 0f                	je     80089b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088c:	83 c0 01             	add    $0x1,%eax
  80088f:	0f b6 10             	movzbl (%eax),%edx
  800892:	84 d2                	test   %dl,%dl
  800894:	75 f2                	jne    800888 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a7:	eb 03                	jmp    8008ac <strfind+0xf>
  8008a9:	83 c0 01             	add    $0x1,%eax
  8008ac:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008af:	38 ca                	cmp    %cl,%dl
  8008b1:	74 04                	je     8008b7 <strfind+0x1a>
  8008b3:	84 d2                	test   %dl,%dl
  8008b5:	75 f2                	jne    8008a9 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	57                   	push   %edi
  8008bd:	56                   	push   %esi
  8008be:	53                   	push   %ebx
  8008bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c5:	85 c9                	test   %ecx,%ecx
  8008c7:	74 36                	je     8008ff <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008cf:	75 28                	jne    8008f9 <memset+0x40>
  8008d1:	f6 c1 03             	test   $0x3,%cl
  8008d4:	75 23                	jne    8008f9 <memset+0x40>
		c &= 0xFF;
  8008d6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008da:	89 d3                	mov    %edx,%ebx
  8008dc:	c1 e3 08             	shl    $0x8,%ebx
  8008df:	89 d6                	mov    %edx,%esi
  8008e1:	c1 e6 18             	shl    $0x18,%esi
  8008e4:	89 d0                	mov    %edx,%eax
  8008e6:	c1 e0 10             	shl    $0x10,%eax
  8008e9:	09 f0                	or     %esi,%eax
  8008eb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ed:	89 d8                	mov    %ebx,%eax
  8008ef:	09 d0                	or     %edx,%eax
  8008f1:	c1 e9 02             	shr    $0x2,%ecx
  8008f4:	fc                   	cld    
  8008f5:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f7:	eb 06                	jmp    8008ff <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008fc:	fc                   	cld    
  8008fd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ff:	89 f8                	mov    %edi,%eax
  800901:	5b                   	pop    %ebx
  800902:	5e                   	pop    %esi
  800903:	5f                   	pop    %edi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	57                   	push   %edi
  80090a:	56                   	push   %esi
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800911:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800914:	39 c6                	cmp    %eax,%esi
  800916:	73 35                	jae    80094d <memmove+0x47>
  800918:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091b:	39 d0                	cmp    %edx,%eax
  80091d:	73 2e                	jae    80094d <memmove+0x47>
		s += n;
		d += n;
  80091f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800922:	89 d6                	mov    %edx,%esi
  800924:	09 fe                	or     %edi,%esi
  800926:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092c:	75 13                	jne    800941 <memmove+0x3b>
  80092e:	f6 c1 03             	test   $0x3,%cl
  800931:	75 0e                	jne    800941 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800933:	83 ef 04             	sub    $0x4,%edi
  800936:	8d 72 fc             	lea    -0x4(%edx),%esi
  800939:	c1 e9 02             	shr    $0x2,%ecx
  80093c:	fd                   	std    
  80093d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093f:	eb 09                	jmp    80094a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800941:	83 ef 01             	sub    $0x1,%edi
  800944:	8d 72 ff             	lea    -0x1(%edx),%esi
  800947:	fd                   	std    
  800948:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094a:	fc                   	cld    
  80094b:	eb 1d                	jmp    80096a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094d:	89 f2                	mov    %esi,%edx
  80094f:	09 c2                	or     %eax,%edx
  800951:	f6 c2 03             	test   $0x3,%dl
  800954:	75 0f                	jne    800965 <memmove+0x5f>
  800956:	f6 c1 03             	test   $0x3,%cl
  800959:	75 0a                	jne    800965 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095b:	c1 e9 02             	shr    $0x2,%ecx
  80095e:	89 c7                	mov    %eax,%edi
  800960:	fc                   	cld    
  800961:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800963:	eb 05                	jmp    80096a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800965:	89 c7                	mov    %eax,%edi
  800967:	fc                   	cld    
  800968:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096a:	5e                   	pop    %esi
  80096b:	5f                   	pop    %edi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800971:	ff 75 10             	pushl  0x10(%ebp)
  800974:	ff 75 0c             	pushl  0xc(%ebp)
  800977:	ff 75 08             	pushl  0x8(%ebp)
  80097a:	e8 87 ff ff ff       	call   800906 <memmove>
}
  80097f:	c9                   	leave  
  800980:	c3                   	ret    

00800981 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	56                   	push   %esi
  800985:	53                   	push   %ebx
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098c:	89 c6                	mov    %eax,%esi
  80098e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800991:	eb 1a                	jmp    8009ad <memcmp+0x2c>
		if (*s1 != *s2)
  800993:	0f b6 08             	movzbl (%eax),%ecx
  800996:	0f b6 1a             	movzbl (%edx),%ebx
  800999:	38 d9                	cmp    %bl,%cl
  80099b:	74 0a                	je     8009a7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80099d:	0f b6 c1             	movzbl %cl,%eax
  8009a0:	0f b6 db             	movzbl %bl,%ebx
  8009a3:	29 d8                	sub    %ebx,%eax
  8009a5:	eb 0f                	jmp    8009b6 <memcmp+0x35>
		s1++, s2++;
  8009a7:	83 c0 01             	add    $0x1,%eax
  8009aa:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ad:	39 f0                	cmp    %esi,%eax
  8009af:	75 e2                	jne    800993 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b6:	5b                   	pop    %ebx
  8009b7:	5e                   	pop    %esi
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	53                   	push   %ebx
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c1:	89 c1                	mov    %eax,%ecx
  8009c3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ca:	eb 0a                	jmp    8009d6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cc:	0f b6 10             	movzbl (%eax),%edx
  8009cf:	39 da                	cmp    %ebx,%edx
  8009d1:	74 07                	je     8009da <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d3:	83 c0 01             	add    $0x1,%eax
  8009d6:	39 c8                	cmp    %ecx,%eax
  8009d8:	72 f2                	jb     8009cc <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009da:	5b                   	pop    %ebx
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	57                   	push   %edi
  8009e1:	56                   	push   %esi
  8009e2:	53                   	push   %ebx
  8009e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e9:	eb 03                	jmp    8009ee <strtol+0x11>
		s++;
  8009eb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ee:	0f b6 01             	movzbl (%ecx),%eax
  8009f1:	3c 20                	cmp    $0x20,%al
  8009f3:	74 f6                	je     8009eb <strtol+0xe>
  8009f5:	3c 09                	cmp    $0x9,%al
  8009f7:	74 f2                	je     8009eb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f9:	3c 2b                	cmp    $0x2b,%al
  8009fb:	75 0a                	jne    800a07 <strtol+0x2a>
		s++;
  8009fd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a00:	bf 00 00 00 00       	mov    $0x0,%edi
  800a05:	eb 11                	jmp    800a18 <strtol+0x3b>
  800a07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0c:	3c 2d                	cmp    $0x2d,%al
  800a0e:	75 08                	jne    800a18 <strtol+0x3b>
		s++, neg = 1;
  800a10:	83 c1 01             	add    $0x1,%ecx
  800a13:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a18:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1e:	75 15                	jne    800a35 <strtol+0x58>
  800a20:	80 39 30             	cmpb   $0x30,(%ecx)
  800a23:	75 10                	jne    800a35 <strtol+0x58>
  800a25:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a29:	75 7c                	jne    800aa7 <strtol+0xca>
		s += 2, base = 16;
  800a2b:	83 c1 02             	add    $0x2,%ecx
  800a2e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a33:	eb 16                	jmp    800a4b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a35:	85 db                	test   %ebx,%ebx
  800a37:	75 12                	jne    800a4b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a39:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a41:	75 08                	jne    800a4b <strtol+0x6e>
		s++, base = 8;
  800a43:	83 c1 01             	add    $0x1,%ecx
  800a46:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a50:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a53:	0f b6 11             	movzbl (%ecx),%edx
  800a56:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a59:	89 f3                	mov    %esi,%ebx
  800a5b:	80 fb 09             	cmp    $0x9,%bl
  800a5e:	77 08                	ja     800a68 <strtol+0x8b>
			dig = *s - '0';
  800a60:	0f be d2             	movsbl %dl,%edx
  800a63:	83 ea 30             	sub    $0x30,%edx
  800a66:	eb 22                	jmp    800a8a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a68:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6b:	89 f3                	mov    %esi,%ebx
  800a6d:	80 fb 19             	cmp    $0x19,%bl
  800a70:	77 08                	ja     800a7a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a72:	0f be d2             	movsbl %dl,%edx
  800a75:	83 ea 57             	sub    $0x57,%edx
  800a78:	eb 10                	jmp    800a8a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a7a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7d:	89 f3                	mov    %esi,%ebx
  800a7f:	80 fb 19             	cmp    $0x19,%bl
  800a82:	77 16                	ja     800a9a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a84:	0f be d2             	movsbl %dl,%edx
  800a87:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8d:	7d 0b                	jge    800a9a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a8f:	83 c1 01             	add    $0x1,%ecx
  800a92:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a96:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a98:	eb b9                	jmp    800a53 <strtol+0x76>

	if (endptr)
  800a9a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a9e:	74 0d                	je     800aad <strtol+0xd0>
		*endptr = (char *) s;
  800aa0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa3:	89 0e                	mov    %ecx,(%esi)
  800aa5:	eb 06                	jmp    800aad <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa7:	85 db                	test   %ebx,%ebx
  800aa9:	74 98                	je     800a43 <strtol+0x66>
  800aab:	eb 9e                	jmp    800a4b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aad:	89 c2                	mov    %eax,%edx
  800aaf:	f7 da                	neg    %edx
  800ab1:	85 ff                	test   %edi,%edi
  800ab3:	0f 45 c2             	cmovne %edx,%eax
}
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	57                   	push   %edi
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac9:	8b 55 08             	mov    0x8(%ebp),%edx
  800acc:	89 c3                	mov    %eax,%ebx
  800ace:	89 c7                	mov    %eax,%edi
  800ad0:	89 c6                	mov    %eax,%esi
  800ad2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	57                   	push   %edi
  800add:	56                   	push   %esi
  800ade:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800adf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae9:	89 d1                	mov    %edx,%ecx
  800aeb:	89 d3                	mov    %edx,%ebx
  800aed:	89 d7                	mov    %edx,%edi
  800aef:	89 d6                	mov    %edx,%esi
  800af1:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af3:	5b                   	pop    %ebx
  800af4:	5e                   	pop    %esi
  800af5:	5f                   	pop    %edi
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    

00800af8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	57                   	push   %edi
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
  800afe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b01:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b06:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0e:	89 cb                	mov    %ecx,%ebx
  800b10:	89 cf                	mov    %ecx,%edi
  800b12:	89 ce                	mov    %ecx,%esi
  800b14:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b16:	85 c0                	test   %eax,%eax
  800b18:	7e 17                	jle    800b31 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1a:	83 ec 0c             	sub    $0xc,%esp
  800b1d:	50                   	push   %eax
  800b1e:	6a 03                	push   $0x3
  800b20:	68 24 18 80 00       	push   $0x801824
  800b25:	6a 23                	push   $0x23
  800b27:	68 41 18 80 00       	push   $0x801841
  800b2c:	e8 eb 06 00 00       	call   80121c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b44:	b8 02 00 00 00       	mov    $0x2,%eax
  800b49:	89 d1                	mov    %edx,%ecx
  800b4b:	89 d3                	mov    %edx,%ebx
  800b4d:	89 d7                	mov    %edx,%edi
  800b4f:	89 d6                	mov    %edx,%esi
  800b51:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_yield>:

void
sys_yield(void)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b63:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b68:	89 d1                	mov    %edx,%ecx
  800b6a:	89 d3                	mov    %edx,%ebx
  800b6c:	89 d7                	mov    %edx,%edi
  800b6e:	89 d6                	mov    %edx,%esi
  800b70:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5f                   	pop    %edi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	57                   	push   %edi
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
  800b7d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	be 00 00 00 00       	mov    $0x0,%esi
  800b85:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b93:	89 f7                	mov    %esi,%edi
  800b95:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b97:	85 c0                	test   %eax,%eax
  800b99:	7e 17                	jle    800bb2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	50                   	push   %eax
  800b9f:	6a 04                	push   $0x4
  800ba1:	68 24 18 80 00       	push   $0x801824
  800ba6:	6a 23                	push   $0x23
  800ba8:	68 41 18 80 00       	push   $0x801841
  800bad:	e8 6a 06 00 00       	call   80121c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd4:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	7e 17                	jle    800bf4 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	50                   	push   %eax
  800be1:	6a 05                	push   $0x5
  800be3:	68 24 18 80 00       	push   $0x801824
  800be8:	6a 23                	push   $0x23
  800bea:	68 41 18 80 00       	push   $0x801841
  800bef:	e8 28 06 00 00       	call   80121c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	89 df                	mov    %ebx,%edi
  800c17:	89 de                	mov    %ebx,%esi
  800c19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 17                	jle    800c36 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	50                   	push   %eax
  800c23:	6a 06                	push   $0x6
  800c25:	68 24 18 80 00       	push   $0x801824
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 41 18 80 00       	push   $0x801841
  800c31:	e8 e6 05 00 00       	call   80121c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c47:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	89 df                	mov    %ebx,%edi
  800c59:	89 de                	mov    %ebx,%esi
  800c5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	7e 17                	jle    800c78 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	6a 08                	push   $0x8
  800c67:	68 24 18 80 00       	push   $0x801824
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 41 18 80 00       	push   $0x801841
  800c73:	e8 a4 05 00 00       	call   80121c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8e:	b8 09 00 00 00       	mov    $0x9,%eax
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 df                	mov    %ebx,%edi
  800c9b:	89 de                	mov    %ebx,%esi
  800c9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	7e 17                	jle    800cba <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 09                	push   $0x9
  800ca9:	68 24 18 80 00       	push   $0x801824
  800cae:	6a 23                	push   $0x23
  800cb0:	68 41 18 80 00       	push   $0x801841
  800cb5:	e8 62 05 00 00       	call   80121c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc8:	be 00 00 00 00       	mov    $0x0,%esi
  800ccd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cde:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	89 cb                	mov    %ecx,%ebx
  800cfd:	89 cf                	mov    %ecx,%edi
  800cff:	89 ce                	mov    %ecx,%esi
  800d01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 17                	jle    800d1e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 0c                	push   $0xc
  800d0d:	68 24 18 80 00       	push   $0x801824
  800d12:	6a 23                	push   $0x23
  800d14:	68 41 18 80 00       	push   $0x801841
  800d19:	e8 fe 04 00 00       	call   80121c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_change_pr>:

int
sys_change_pr(int pr)
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
  800d2c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d31:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	89 cb                	mov    %ecx,%ebx
  800d3b:	89 cf                	mov    %ecx,%edi
  800d3d:	89 ce                	mov    %ecx,%esi
  800d3f:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	53                   	push   %ebx
  800d4a:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
	// cprintf("1\n");
	void *addr = (void*) (pn*PGSIZE);
  800d4d:	89 d3                	mov    %edx,%ebx
  800d4f:	c1 e3 0c             	shl    $0xc,%ebx
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800d52:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d59:	f6 c1 02             	test   $0x2,%cl
  800d5c:	75 0c                	jne    800d6a <duppage+0x24>
  800d5e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d65:	f6 c6 08             	test   $0x8,%dh
  800d68:	74 5b                	je     800dc5 <duppage+0x7f>
		if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800d6a:	83 ec 0c             	sub    $0xc,%esp
  800d6d:	68 05 08 00 00       	push   $0x805
  800d72:	53                   	push   %ebx
  800d73:	50                   	push   %eax
  800d74:	53                   	push   %ebx
  800d75:	6a 00                	push   $0x0
  800d77:	e8 3e fe ff ff       	call   800bba <sys_page_map>
  800d7c:	83 c4 20             	add    $0x20,%esp
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	79 14                	jns    800d97 <duppage+0x51>
			panic("2");
  800d83:	83 ec 04             	sub    $0x4,%esp
  800d86:	68 4f 18 80 00       	push   $0x80184f
  800d8b:	6a 49                	push   $0x49
  800d8d:	68 51 18 80 00       	push   $0x801851
  800d92:	e8 85 04 00 00       	call   80121c <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	68 05 08 00 00       	push   $0x805
  800d9f:	53                   	push   %ebx
  800da0:	6a 00                	push   $0x0
  800da2:	53                   	push   %ebx
  800da3:	6a 00                	push   $0x0
  800da5:	e8 10 fe ff ff       	call   800bba <sys_page_map>
  800daa:	83 c4 20             	add    $0x20,%esp
  800dad:	85 c0                	test   %eax,%eax
  800daf:	79 26                	jns    800dd7 <duppage+0x91>
			panic("3");
  800db1:	83 ec 04             	sub    $0x4,%esp
  800db4:	68 5c 18 80 00       	push   $0x80185c
  800db9:	6a 4b                	push   $0x4b
  800dbb:	68 51 18 80 00       	push   $0x801851
  800dc0:	e8 57 04 00 00       	call   80121c <_panic>
	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800dc5:	83 ec 0c             	sub    $0xc,%esp
  800dc8:	6a 05                	push   $0x5
  800dca:	53                   	push   %ebx
  800dcb:	50                   	push   %eax
  800dcc:	53                   	push   %ebx
  800dcd:	6a 00                	push   $0x0
  800dcf:	e8 e6 fd ff ff       	call   800bba <sys_page_map>
  800dd4:	83 c4 20             	add    $0x20,%esp
	// cprintf("2\n");
	return 0;
	panic("duppage not implemented");
}
  800dd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ddc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ddf:	c9                   	leave  
  800de0:	c3                   	ret    

00800de1 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	53                   	push   %ebx
  800de5:	83 ec 04             	sub    $0x4,%esp
  800de8:	8b 55 08             	mov    0x8(%ebp),%edx
	// panic("pgfault");
	void *addr = (void *) utf->utf_fault_va;
  800deb:	8b 02                	mov    (%edx),%eax
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800ded:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800df1:	74 2e                	je     800e21 <pgfault+0x40>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800df3:	89 c2                	mov    %eax,%edx
  800df5:	c1 ea 16             	shr    $0x16,%edx
  800df8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dff:	f6 c2 01             	test   $0x1,%dl
  800e02:	74 1d                	je     800e21 <pgfault+0x40>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e04:	89 c2                	mov    %eax,%edx
  800e06:	c1 ea 0c             	shr    $0xc,%edx
  800e09:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e10:	f6 c1 01             	test   $0x1,%cl
  800e13:	74 0c                	je     800e21 <pgfault+0x40>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e15:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e1c:	f6 c6 08             	test   $0x8,%dh
  800e1f:	75 14                	jne    800e35 <pgfault+0x54>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800e21:	83 ec 04             	sub    $0x4,%esp
  800e24:	68 5e 18 80 00       	push   $0x80185e
  800e29:	6a 20                	push   $0x20
  800e2b:	68 51 18 80 00       	push   $0x801851
  800e30:	e8 e7 03 00 00       	call   80121c <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800e35:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e3a:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800e3c:	83 ec 04             	sub    $0x4,%esp
  800e3f:	6a 07                	push   $0x7
  800e41:	68 00 f0 7f 00       	push   $0x7ff000
  800e46:	6a 00                	push   $0x0
  800e48:	e8 2a fd ff ff       	call   800b77 <sys_page_alloc>
  800e4d:	83 c4 10             	add    $0x10,%esp
  800e50:	85 c0                	test   %eax,%eax
  800e52:	79 14                	jns    800e68 <pgfault+0x87>
		panic("sys_page_alloc");
  800e54:	83 ec 04             	sub    $0x4,%esp
  800e57:	68 70 18 80 00       	push   $0x801870
  800e5c:	6a 2c                	push   $0x2c
  800e5e:	68 51 18 80 00       	push   $0x801851
  800e63:	e8 b4 03 00 00       	call   80121c <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  800e68:	83 ec 04             	sub    $0x4,%esp
  800e6b:	68 00 10 00 00       	push   $0x1000
  800e70:	53                   	push   %ebx
  800e71:	68 00 f0 7f 00       	push   $0x7ff000
  800e76:	e8 f3 fa ff ff       	call   80096e <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800e7b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e82:	53                   	push   %ebx
  800e83:	6a 00                	push   $0x0
  800e85:	68 00 f0 7f 00       	push   $0x7ff000
  800e8a:	6a 00                	push   $0x0
  800e8c:	e8 29 fd ff ff       	call   800bba <sys_page_map>
  800e91:	83 c4 20             	add    $0x20,%esp
  800e94:	85 c0                	test   %eax,%eax
  800e96:	79 14                	jns    800eac <pgfault+0xcb>
		panic("sys_page_map");
  800e98:	83 ec 04             	sub    $0x4,%esp
  800e9b:	68 7f 18 80 00       	push   $0x80187f
  800ea0:	6a 2f                	push   $0x2f
  800ea2:	68 51 18 80 00       	push   $0x801851
  800ea7:	e8 70 03 00 00       	call   80121c <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800eac:	83 ec 08             	sub    $0x8,%esp
  800eaf:	68 00 f0 7f 00       	push   $0x7ff000
  800eb4:	6a 00                	push   $0x0
  800eb6:	e8 41 fd ff ff       	call   800bfc <sys_page_unmap>
  800ebb:	83 c4 10             	add    $0x10,%esp
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	79 14                	jns    800ed6 <pgfault+0xf5>
		panic("sys_page_unmap");
  800ec2:	83 ec 04             	sub    $0x4,%esp
  800ec5:	68 8c 18 80 00       	push   $0x80188c
  800eca:	6a 31                	push   $0x31
  800ecc:	68 51 18 80 00       	push   $0x801851
  800ed1:	e8 46 03 00 00       	call   80121c <_panic>
	return;
}
  800ed6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed9:	c9                   	leave  
  800eda:	c3                   	ret    

00800edb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	57                   	push   %edi
  800edf:	56                   	push   %esi
  800ee0:	53                   	push   %ebx
  800ee1:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800ee4:	68 e1 0d 80 00       	push   $0x800de1
  800ee9:	e8 74 03 00 00       	call   801262 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800eee:	b8 07 00 00 00       	mov    $0x7,%eax
  800ef3:	cd 30                	int    $0x30

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800ef5:	83 c4 10             	add    $0x10,%esp
  800ef8:	85 c0                	test   %eax,%eax
  800efa:	75 21                	jne    800f1d <fork+0x42>
		// panic("child");
		thisenv = &envs[ENVX(sys_getenvid())];
  800efc:	e8 38 fc ff ff       	call   800b39 <sys_getenvid>
  800f01:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f06:	c1 e0 07             	shl    $0x7,%eax
  800f09:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f0e:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f13:	b8 00 00 00 00       	mov    $0x0,%eax
  800f18:	e9 c6 00 00 00       	jmp    800fe3 <fork+0x108>
  800f1d:	89 c6                	mov    %eax,%esi
  800f1f:	89 c7                	mov    %eax,%edi
	}
	// cprintf("sys_exofork: %x\n", envid);
	if (envid < 0)
  800f21:	85 c0                	test   %eax,%eax
  800f23:	79 12                	jns    800f37 <fork+0x5c>
		panic("sys_exofork: %e", envid);
  800f25:	50                   	push   %eax
  800f26:	68 9b 18 80 00       	push   $0x80189b
  800f2b:	6a 71                	push   $0x71
  800f2d:	68 51 18 80 00       	push   $0x801851
  800f32:	e8 e5 02 00 00       	call   80121c <_panic>
  800f37:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800f3c:	89 d8                	mov    %ebx,%eax
  800f3e:	c1 e8 16             	shr    $0x16,%eax
  800f41:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f48:	a8 01                	test   $0x1,%al
  800f4a:	74 22                	je     800f6e <fork+0x93>
  800f4c:	89 da                	mov    %ebx,%edx
  800f4e:	c1 ea 0c             	shr    $0xc,%edx
  800f51:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f58:	a8 01                	test   $0x1,%al
  800f5a:	74 12                	je     800f6e <fork+0x93>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800f5c:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f63:	a8 04                	test   $0x4,%al
  800f65:	74 07                	je     800f6e <fork+0x93>
			// cprintf("envid: %x, PGNUM: %x, addr: %x\n", envid, PGNUM(addr), addr);
			// if (addr!=0x802000) {
			duppage(envid, PGNUM(addr));
  800f67:	89 f8                	mov    %edi,%eax
  800f69:	e8 d8 fd ff ff       	call   800d46 <duppage>
	}
	// cprintf("sys_exofork: %x\n", envid);
	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f6e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f74:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f7a:	75 c0                	jne    800f3c <fork+0x61>
			// cprintf("%x\n", uvpt[PGNUM(addr)]);
		}
	// panic("faint");


	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800f7c:	83 ec 04             	sub    $0x4,%esp
  800f7f:	6a 07                	push   $0x7
  800f81:	68 00 f0 bf ee       	push   $0xeebff000
  800f86:	56                   	push   %esi
  800f87:	e8 eb fb ff ff       	call   800b77 <sys_page_alloc>
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	79 17                	jns    800faa <fork+0xcf>
		panic("1");
  800f93:	83 ec 04             	sub    $0x4,%esp
  800f96:	68 ab 18 80 00       	push   $0x8018ab
  800f9b:	68 82 00 00 00       	push   $0x82
  800fa0:	68 51 18 80 00       	push   $0x801851
  800fa5:	e8 72 02 00 00       	call   80121c <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800faa:	83 ec 08             	sub    $0x8,%esp
  800fad:	68 d1 12 80 00       	push   $0x8012d1
  800fb2:	56                   	push   %esi
  800fb3:	e8 c8 fc ff ff       	call   800c80 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  800fb8:	83 c4 08             	add    $0x8,%esp
  800fbb:	6a 02                	push   $0x2
  800fbd:	56                   	push   %esi
  800fbe:	e8 7b fc ff ff       	call   800c3e <sys_env_set_status>
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	79 17                	jns    800fe1 <fork+0x106>
		panic("sys_env_set_status");
  800fca:	83 ec 04             	sub    $0x4,%esp
  800fcd:	68 ad 18 80 00       	push   $0x8018ad
  800fd2:	68 87 00 00 00       	push   $0x87
  800fd7:	68 51 18 80 00       	push   $0x801851
  800fdc:	e8 3b 02 00 00       	call   80121c <_panic>

	return envid;
  800fe1:	89 f0                	mov    %esi,%eax
	panic("fork not implemented");
}
  800fe3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe6:	5b                   	pop    %ebx
  800fe7:	5e                   	pop    %esi
  800fe8:	5f                   	pop    %edi
  800fe9:	5d                   	pop    %ebp
  800fea:	c3                   	ret    

00800feb <pfork>:

envid_t
pfork(int pr)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	57                   	push   %edi
  800fef:	56                   	push   %esi
  800ff0:	53                   	push   %ebx
  800ff1:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800ff4:	68 e1 0d 80 00       	push   $0x800de1
  800ff9:	e8 64 02 00 00       	call   801262 <set_pgfault_handler>
  800ffe:	b8 07 00 00 00       	mov    $0x7,%eax
  801003:	cd 30                	int    $0x30

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	75 2f                	jne    80103b <pfork+0x50>
		thisenv = &envs[ENVX(sys_getenvid())];
  80100c:	e8 28 fb ff ff       	call   800b39 <sys_getenvid>
  801011:	25 ff 03 00 00       	and    $0x3ff,%eax
  801016:	c1 e0 07             	shl    $0x7,%eax
  801019:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80101e:	a3 04 20 80 00       	mov    %eax,0x802004
		sys_change_pr(pr);
  801023:	83 ec 0c             	sub    $0xc,%esp
  801026:	ff 75 08             	pushl  0x8(%ebp)
  801029:	e8 f8 fc ff ff       	call   800d26 <sys_change_pr>
		return 0;
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	b8 00 00 00 00       	mov    $0x0,%eax
  801036:	e9 c9 00 00 00       	jmp    801104 <pfork+0x119>
  80103b:	89 c6                	mov    %eax,%esi
  80103d:	89 c7                	mov    %eax,%edi
	}

	if (envid < 0)
  80103f:	85 c0                	test   %eax,%eax
  801041:	79 15                	jns    801058 <pfork+0x6d>
		panic("sys_exofork: %e", envid);
  801043:	50                   	push   %eax
  801044:	68 9b 18 80 00       	push   $0x80189b
  801049:	68 9c 00 00 00       	push   $0x9c
  80104e:	68 51 18 80 00       	push   $0x801851
  801053:	e8 c4 01 00 00       	call   80121c <_panic>
  801058:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  80105d:	89 d8                	mov    %ebx,%eax
  80105f:	c1 e8 16             	shr    $0x16,%eax
  801062:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801069:	a8 01                	test   $0x1,%al
  80106b:	74 22                	je     80108f <pfork+0xa4>
  80106d:	89 da                	mov    %ebx,%edx
  80106f:	c1 ea 0c             	shr    $0xc,%edx
  801072:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801079:	a8 01                	test   $0x1,%al
  80107b:	74 12                	je     80108f <pfork+0xa4>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  80107d:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801084:	a8 04                	test   $0x4,%al
  801086:	74 07                	je     80108f <pfork+0xa4>
			duppage(envid, PGNUM(addr));
  801088:	89 f8                	mov    %edi,%eax
  80108a:	e8 b7 fc ff ff       	call   800d46 <duppage>
	}

	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  80108f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801095:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80109b:	75 c0                	jne    80105d <pfork+0x72>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80109d:	83 ec 04             	sub    $0x4,%esp
  8010a0:	6a 07                	push   $0x7
  8010a2:	68 00 f0 bf ee       	push   $0xeebff000
  8010a7:	56                   	push   %esi
  8010a8:	e8 ca fa ff ff       	call   800b77 <sys_page_alloc>
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	79 17                	jns    8010cb <pfork+0xe0>
		panic("1");
  8010b4:	83 ec 04             	sub    $0x4,%esp
  8010b7:	68 ab 18 80 00       	push   $0x8018ab
  8010bc:	68 a5 00 00 00       	push   $0xa5
  8010c1:	68 51 18 80 00       	push   $0x801851
  8010c6:	e8 51 01 00 00       	call   80121c <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010cb:	83 ec 08             	sub    $0x8,%esp
  8010ce:	68 d1 12 80 00       	push   $0x8012d1
  8010d3:	56                   	push   %esi
  8010d4:	e8 a7 fb ff ff       	call   800c80 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8010d9:	83 c4 08             	add    $0x8,%esp
  8010dc:	6a 02                	push   $0x2
  8010de:	56                   	push   %esi
  8010df:	e8 5a fb ff ff       	call   800c3e <sys_env_set_status>
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	79 17                	jns    801102 <pfork+0x117>
		panic("sys_env_set_status");
  8010eb:	83 ec 04             	sub    $0x4,%esp
  8010ee:	68 ad 18 80 00       	push   $0x8018ad
  8010f3:	68 aa 00 00 00       	push   $0xaa
  8010f8:	68 51 18 80 00       	push   $0x801851
  8010fd:	e8 1a 01 00 00       	call   80121c <_panic>

	return envid;
  801102:	89 f0                	mov    %esi,%eax
	panic("fork not implemented");
}
  801104:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801107:	5b                   	pop    %ebx
  801108:	5e                   	pop    %esi
  801109:	5f                   	pop    %edi
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    

0080110c <sfork>:

// Challenge!
int
sfork(void)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801112:	68 c0 18 80 00       	push   $0x8018c0
  801117:	68 b4 00 00 00       	push   $0xb4
  80111c:	68 51 18 80 00       	push   $0x801851
  801121:	e8 f6 00 00 00       	call   80121c <_panic>

00801126 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	56                   	push   %esi
  80112a:	53                   	push   %ebx
  80112b:	8b 75 08             	mov    0x8(%ebp),%esi
  80112e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801131:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801134:	85 f6                	test   %esi,%esi
  801136:	74 06                	je     80113e <ipc_recv+0x18>
  801138:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  80113e:	85 db                	test   %ebx,%ebx
  801140:	74 06                	je     801148 <ipc_recv+0x22>
  801142:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801148:	85 c0                	test   %eax,%eax
  80114a:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80114f:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801152:	83 ec 0c             	sub    $0xc,%esp
  801155:	50                   	push   %eax
  801156:	e8 8a fb ff ff       	call   800ce5 <sys_ipc_recv>
	if (ret) return ret;
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	75 24                	jne    801186 <ipc_recv+0x60>
	if (from_env_store)
  801162:	85 f6                	test   %esi,%esi
  801164:	74 0a                	je     801170 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801166:	a1 04 20 80 00       	mov    0x802004,%eax
  80116b:	8b 40 74             	mov    0x74(%eax),%eax
  80116e:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801170:	85 db                	test   %ebx,%ebx
  801172:	74 0a                	je     80117e <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801174:	a1 04 20 80 00       	mov    0x802004,%eax
  801179:	8b 40 78             	mov    0x78(%eax),%eax
  80117c:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80117e:	a1 04 20 80 00       	mov    0x802004,%eax
  801183:	8b 40 70             	mov    0x70(%eax),%eax
}
  801186:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801189:	5b                   	pop    %ebx
  80118a:	5e                   	pop    %esi
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	57                   	push   %edi
  801191:	56                   	push   %esi
  801192:	53                   	push   %ebx
  801193:	83 ec 0c             	sub    $0xc,%esp
  801196:	8b 7d 08             	mov    0x8(%ebp),%edi
  801199:	8b 75 0c             	mov    0xc(%ebp),%esi
  80119c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  80119f:	85 db                	test   %ebx,%ebx
  8011a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011a6:	0f 44 d8             	cmove  %eax,%ebx
  8011a9:	eb 1c                	jmp    8011c7 <ipc_send+0x3a>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8011ab:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011ae:	74 12                	je     8011c2 <ipc_send+0x35>
  8011b0:	50                   	push   %eax
  8011b1:	68 d6 18 80 00       	push   $0x8018d6
  8011b6:	6a 36                	push   $0x36
  8011b8:	68 ed 18 80 00       	push   $0x8018ed
  8011bd:	e8 5a 00 00 00       	call   80121c <_panic>
		sys_yield();
  8011c2:	e8 91 f9 ff ff       	call   800b58 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8011c7:	ff 75 14             	pushl  0x14(%ebp)
  8011ca:	53                   	push   %ebx
  8011cb:	56                   	push   %esi
  8011cc:	57                   	push   %edi
  8011cd:	e8 f0 fa ff ff       	call   800cc2 <sys_ipc_try_send>
		if (ret == 0) break;
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	75 d2                	jne    8011ab <ipc_send+0x1e>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
		sys_yield();
	}
}
  8011d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dc:	5b                   	pop    %ebx
  8011dd:	5e                   	pop    %esi
  8011de:	5f                   	pop    %edi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011e7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011ec:	89 c2                	mov    %eax,%edx
  8011ee:	c1 e2 07             	shl    $0x7,%edx
  8011f1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011f7:	8b 52 50             	mov    0x50(%edx),%edx
  8011fa:	39 ca                	cmp    %ecx,%edx
  8011fc:	75 0d                	jne    80120b <ipc_find_env+0x2a>
			return envs[i].env_id;
  8011fe:	c1 e0 07             	shl    $0x7,%eax
  801201:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801206:	8b 40 48             	mov    0x48(%eax),%eax
  801209:	eb 0f                	jmp    80121a <ipc_find_env+0x39>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80120b:	83 c0 01             	add    $0x1,%eax
  80120e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801213:	75 d7                	jne    8011ec <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801215:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    

0080121c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	56                   	push   %esi
  801220:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801221:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801224:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80122a:	e8 0a f9 ff ff       	call   800b39 <sys_getenvid>
  80122f:	83 ec 0c             	sub    $0xc,%esp
  801232:	ff 75 0c             	pushl  0xc(%ebp)
  801235:	ff 75 08             	pushl  0x8(%ebp)
  801238:	56                   	push   %esi
  801239:	50                   	push   %eax
  80123a:	68 f8 18 80 00       	push   $0x8018f8
  80123f:	e8 65 ef ff ff       	call   8001a9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801244:	83 c4 18             	add    $0x18,%esp
  801247:	53                   	push   %ebx
  801248:	ff 75 10             	pushl  0x10(%ebp)
  80124b:	e8 08 ef ff ff       	call   800158 <vcprintf>
	cprintf("\n");
  801250:	c7 04 24 c7 15 80 00 	movl   $0x8015c7,(%esp)
  801257:	e8 4d ef ff ff       	call   8001a9 <cprintf>
  80125c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80125f:	cc                   	int3   
  801260:	eb fd                	jmp    80125f <_panic+0x43>

00801262 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	83 ec 08             	sub    $0x8,%esp
	// int r;

	if (_pgfault_handler == 0) {
  801268:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  80126f:	75 2c                	jne    80129d <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801271:	83 ec 04             	sub    $0x4,%esp
  801274:	6a 07                	push   $0x7
  801276:	68 00 f0 bf ee       	push   $0xeebff000
  80127b:	6a 00                	push   $0x0
  80127d:	e8 f5 f8 ff ff       	call   800b77 <sys_page_alloc>
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	85 c0                	test   %eax,%eax
  801287:	79 14                	jns    80129d <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  801289:	83 ec 04             	sub    $0x4,%esp
  80128c:	68 1c 19 80 00       	push   $0x80191c
  801291:	6a 21                	push   $0x21
  801293:	68 80 19 80 00       	push   $0x801980
  801298:	e8 7f ff ff ff       	call   80121c <_panic>
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80129d:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a0:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8012a5:	83 ec 08             	sub    $0x8,%esp
  8012a8:	68 d1 12 80 00       	push   $0x8012d1
  8012ad:	6a 00                	push   $0x0
  8012af:	e8 cc f9 ff ff       	call   800c80 <sys_env_set_pgfault_upcall>
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	79 14                	jns    8012cf <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8012bb:	83 ec 04             	sub    $0x4,%esp
  8012be:	68 48 19 80 00       	push   $0x801948
  8012c3:	6a 26                	push   $0x26
  8012c5:	68 80 19 80 00       	push   $0x801980
  8012ca:	e8 4d ff ff ff       	call   80121c <_panic>
}
  8012cf:	c9                   	leave  
  8012d0:	c3                   	ret    

008012d1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012d1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012d2:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8012d7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012d9:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx #trap-time eip
  8012dc:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)
  8012e0:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax #trap-time esp-4
  8012e5:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)
  8012e9:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp
  8012eb:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8012ee:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp #eip
  8012ef:	83 c4 04             	add    $0x4,%esp
	popfl
  8012f2:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8012f3:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8012f4:	c3                   	ret    
  8012f5:	66 90                	xchg   %ax,%ax
  8012f7:	66 90                	xchg   %ax,%ax
  8012f9:	66 90                	xchg   %ax,%ax
  8012fb:	66 90                	xchg   %ax,%ax
  8012fd:	66 90                	xchg   %ax,%ax
  8012ff:	90                   	nop

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
