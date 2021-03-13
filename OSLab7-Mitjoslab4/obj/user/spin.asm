
obj/user/spin：     文件格式 elf32-i386


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

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 a0 14 80 00       	push   $0x8014a0
  80003f:	e8 5c 01 00 00       	call   8001a0 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 89 0e 00 00       	call   800ed2 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 18 15 80 00       	push   $0x801518
  800058:	e8 43 01 00 00       	call   8001a0 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 c8 14 80 00       	push   $0x8014c8
  80006c:	e8 2f 01 00 00       	call   8001a0 <cprintf>
	sys_yield();
  800071:	e8 d9 0a 00 00       	call   800b4f <sys_yield>
	sys_yield();
  800076:	e8 d4 0a 00 00       	call   800b4f <sys_yield>
	sys_yield();
  80007b:	e8 cf 0a 00 00       	call   800b4f <sys_yield>
	sys_yield();
  800080:	e8 ca 0a 00 00       	call   800b4f <sys_yield>
	sys_yield();
  800085:	e8 c5 0a 00 00       	call   800b4f <sys_yield>
	sys_yield();
  80008a:	e8 c0 0a 00 00       	call   800b4f <sys_yield>
	sys_yield();
  80008f:	e8 bb 0a 00 00       	call   800b4f <sys_yield>
	sys_yield();
  800094:	e8 b6 0a 00 00       	call   800b4f <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 f0 14 80 00 	movl   $0x8014f0,(%esp)
  8000a0:	e8 fb 00 00 00       	call   8001a0 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 42 0a 00 00       	call   800aef <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
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
  8000c0:	e8 6b 0a 00 00       	call   800b30 <sys_getenvid>
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
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

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
  800103:	e8 e7 09 00 00       	call   800aef <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	53                   	push   %ebx
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800117:	8b 13                	mov    (%ebx),%edx
  800119:	8d 42 01             	lea    0x1(%edx),%eax
  80011c:	89 03                	mov    %eax,(%ebx)
  80011e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800121:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800125:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012a:	75 1a                	jne    800146 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80012c:	83 ec 08             	sub    $0x8,%esp
  80012f:	68 ff 00 00 00       	push   $0xff
  800134:	8d 43 08             	lea    0x8(%ebx),%eax
  800137:	50                   	push   %eax
  800138:	e8 75 09 00 00       	call   800ab2 <sys_cputs>
		b->idx = 0;
  80013d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800143:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800146:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80014a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800158:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015f:	00 00 00 
	b.cnt = 0;
  800162:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800169:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016c:	ff 75 0c             	pushl  0xc(%ebp)
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800178:	50                   	push   %eax
  800179:	68 0d 01 80 00       	push   $0x80010d
  80017e:	e8 54 01 00 00       	call   8002d7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800183:	83 c4 08             	add    $0x8,%esp
  800186:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	e8 1a 09 00 00       	call   800ab2 <sys_cputs>

	return b.cnt;
}
  800198:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a9:	50                   	push   %eax
  8001aa:	ff 75 08             	pushl  0x8(%ebp)
  8001ad:	e8 9d ff ff ff       	call   80014f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	83 ec 1c             	sub    $0x1c,%esp
  8001bd:	89 c7                	mov    %eax,%edi
  8001bf:	89 d6                	mov    %edx,%esi
  8001c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001d8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001db:	39 d3                	cmp    %edx,%ebx
  8001dd:	72 05                	jb     8001e4 <printnum+0x30>
  8001df:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e2:	77 45                	ja     800229 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 18             	pushl  0x18(%ebp)
  8001ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ed:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f0:	53                   	push   %ebx
  8001f1:	ff 75 10             	pushl  0x10(%ebp)
  8001f4:	83 ec 08             	sub    $0x8,%esp
  8001f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fd:	ff 75 dc             	pushl  -0x24(%ebp)
  800200:	ff 75 d8             	pushl  -0x28(%ebp)
  800203:	e8 f8 0f 00 00       	call   801200 <__udivdi3>
  800208:	83 c4 18             	add    $0x18,%esp
  80020b:	52                   	push   %edx
  80020c:	50                   	push   %eax
  80020d:	89 f2                	mov    %esi,%edx
  80020f:	89 f8                	mov    %edi,%eax
  800211:	e8 9e ff ff ff       	call   8001b4 <printnum>
  800216:	83 c4 20             	add    $0x20,%esp
  800219:	eb 18                	jmp    800233 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021b:	83 ec 08             	sub    $0x8,%esp
  80021e:	56                   	push   %esi
  80021f:	ff 75 18             	pushl  0x18(%ebp)
  800222:	ff d7                	call   *%edi
  800224:	83 c4 10             	add    $0x10,%esp
  800227:	eb 03                	jmp    80022c <printnum+0x78>
  800229:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022c:	83 eb 01             	sub    $0x1,%ebx
  80022f:	85 db                	test   %ebx,%ebx
  800231:	7f e8                	jg     80021b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800233:	83 ec 08             	sub    $0x8,%esp
  800236:	56                   	push   %esi
  800237:	83 ec 04             	sub    $0x4,%esp
  80023a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023d:	ff 75 e0             	pushl  -0x20(%ebp)
  800240:	ff 75 dc             	pushl  -0x24(%ebp)
  800243:	ff 75 d8             	pushl  -0x28(%ebp)
  800246:	e8 e5 10 00 00       	call   801330 <__umoddi3>
  80024b:	83 c4 14             	add    $0x14,%esp
  80024e:	0f be 80 40 15 80 00 	movsbl 0x801540(%eax),%eax
  800255:	50                   	push   %eax
  800256:	ff d7                	call   *%edi
}
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800266:	83 fa 01             	cmp    $0x1,%edx
  800269:	7e 0e                	jle    800279 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80026b:	8b 10                	mov    (%eax),%edx
  80026d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800270:	89 08                	mov    %ecx,(%eax)
  800272:	8b 02                	mov    (%edx),%eax
  800274:	8b 52 04             	mov    0x4(%edx),%edx
  800277:	eb 22                	jmp    80029b <getuint+0x38>
	else if (lflag)
  800279:	85 d2                	test   %edx,%edx
  80027b:	74 10                	je     80028d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80027d:	8b 10                	mov    (%eax),%edx
  80027f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800282:	89 08                	mov    %ecx,(%eax)
  800284:	8b 02                	mov    (%edx),%eax
  800286:	ba 00 00 00 00       	mov    $0x0,%edx
  80028b:	eb 0e                	jmp    80029b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80028d:	8b 10                	mov    (%eax),%edx
  80028f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800292:	89 08                	mov    %ecx,(%eax)
  800294:	8b 02                	mov    (%edx),%eax
  800296:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a7:	8b 10                	mov    (%eax),%edx
  8002a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ac:	73 0a                	jae    8002b8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ae:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b6:	88 02                	mov    %al,(%edx)
}
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c3:	50                   	push   %eax
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ca:	ff 75 08             	pushl  0x8(%ebp)
  8002cd:	e8 05 00 00 00       	call   8002d7 <vprintfmt>
	va_end(ap);
}
  8002d2:	83 c4 10             	add    $0x10,%esp
  8002d5:	c9                   	leave  
  8002d6:	c3                   	ret    

008002d7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	57                   	push   %edi
  8002db:	56                   	push   %esi
  8002dc:	53                   	push   %ebx
  8002dd:	83 ec 2c             	sub    $0x2c,%esp
  8002e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e9:	eb 1d                	jmp    800308 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	75 0f                	jne    8002fe <vprintfmt+0x27>
				csa = 0x0700;
  8002ef:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  8002f6:	07 00 00 
				return;
  8002f9:	e9 c4 03 00 00       	jmp    8006c2 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  8002fe:	83 ec 08             	sub    $0x8,%esp
  800301:	53                   	push   %ebx
  800302:	50                   	push   %eax
  800303:	ff d6                	call   *%esi
  800305:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800308:	83 c7 01             	add    $0x1,%edi
  80030b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80030f:	83 f8 25             	cmp    $0x25,%eax
  800312:	75 d7                	jne    8002eb <vprintfmt+0x14>
  800314:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800318:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80031f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800326:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80032d:	ba 00 00 00 00       	mov    $0x0,%edx
  800332:	eb 07                	jmp    80033b <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800334:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800337:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8d 47 01             	lea    0x1(%edi),%eax
  80033e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800341:	0f b6 07             	movzbl (%edi),%eax
  800344:	0f b6 c8             	movzbl %al,%ecx
  800347:	83 e8 23             	sub    $0x23,%eax
  80034a:	3c 55                	cmp    $0x55,%al
  80034c:	0f 87 55 03 00 00    	ja     8006a7 <vprintfmt+0x3d0>
  800352:	0f b6 c0             	movzbl %al,%eax
  800355:	ff 24 85 00 16 80 00 	jmp    *0x801600(,%eax,4)
  80035c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800363:	eb d6                	jmp    80033b <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800368:	b8 00 00 00 00       	mov    $0x0,%eax
  80036d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800370:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800373:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800377:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80037a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80037d:	83 fa 09             	cmp    $0x9,%edx
  800380:	77 39                	ja     8003bb <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800382:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800385:	eb e9                	jmp    800370 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800387:	8b 45 14             	mov    0x14(%ebp),%eax
  80038a:	8d 48 04             	lea    0x4(%eax),%ecx
  80038d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800390:	8b 00                	mov    (%eax),%eax
  800392:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800398:	eb 27                	jmp    8003c1 <vprintfmt+0xea>
  80039a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80039d:	85 c0                	test   %eax,%eax
  80039f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a4:	0f 49 c8             	cmovns %eax,%ecx
  8003a7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ad:	eb 8c                	jmp    80033b <vprintfmt+0x64>
  8003af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b9:	eb 80                	jmp    80033b <vprintfmt+0x64>
  8003bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003be:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c5:	0f 89 70 ff ff ff    	jns    80033b <vprintfmt+0x64>
				width = precision, precision = -1;
  8003cb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d8:	e9 5e ff ff ff       	jmp    80033b <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003dd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e3:	e9 53 ff ff ff       	jmp    80033b <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	8d 50 04             	lea    0x4(%eax),%edx
  8003ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f1:	83 ec 08             	sub    $0x8,%esp
  8003f4:	53                   	push   %ebx
  8003f5:	ff 30                	pushl  (%eax)
  8003f7:	ff d6                	call   *%esi
			break;
  8003f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ff:	e9 04 ff ff ff       	jmp    800308 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800404:	8b 45 14             	mov    0x14(%ebp),%eax
  800407:	8d 50 04             	lea    0x4(%eax),%edx
  80040a:	89 55 14             	mov    %edx,0x14(%ebp)
  80040d:	8b 00                	mov    (%eax),%eax
  80040f:	99                   	cltd   
  800410:	31 d0                	xor    %edx,%eax
  800412:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800414:	83 f8 08             	cmp    $0x8,%eax
  800417:	7f 0b                	jg     800424 <vprintfmt+0x14d>
  800419:	8b 14 85 60 17 80 00 	mov    0x801760(,%eax,4),%edx
  800420:	85 d2                	test   %edx,%edx
  800422:	75 18                	jne    80043c <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  800424:	50                   	push   %eax
  800425:	68 58 15 80 00       	push   $0x801558
  80042a:	53                   	push   %ebx
  80042b:	56                   	push   %esi
  80042c:	e8 89 fe ff ff       	call   8002ba <printfmt>
  800431:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800434:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800437:	e9 cc fe ff ff       	jmp    800308 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  80043c:	52                   	push   %edx
  80043d:	68 61 15 80 00       	push   $0x801561
  800442:	53                   	push   %ebx
  800443:	56                   	push   %esi
  800444:	e8 71 fe ff ff       	call   8002ba <printfmt>
  800449:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044f:	e9 b4 fe ff ff       	jmp    800308 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80045f:	85 ff                	test   %edi,%edi
  800461:	b8 51 15 80 00       	mov    $0x801551,%eax
  800466:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800469:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046d:	0f 8e 94 00 00 00    	jle    800507 <vprintfmt+0x230>
  800473:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800477:	0f 84 98 00 00 00    	je     800515 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	ff 75 d0             	pushl  -0x30(%ebp)
  800483:	57                   	push   %edi
  800484:	e8 c1 02 00 00       	call   80074a <strnlen>
  800489:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048c:	29 c1                	sub    %eax,%ecx
  80048e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800491:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800494:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800498:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a0:	eb 0f                	jmp    8004b1 <vprintfmt+0x1da>
					putch(padc, putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	53                   	push   %ebx
  8004a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ab:	83 ef 01             	sub    $0x1,%edi
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	85 ff                	test   %edi,%edi
  8004b3:	7f ed                	jg     8004a2 <vprintfmt+0x1cb>
  8004b5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004bb:	85 c9                	test   %ecx,%ecx
  8004bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c2:	0f 49 c1             	cmovns %ecx,%eax
  8004c5:	29 c1                	sub    %eax,%ecx
  8004c7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ca:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d0:	89 cb                	mov    %ecx,%ebx
  8004d2:	eb 4d                	jmp    800521 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d8:	74 1b                	je     8004f5 <vprintfmt+0x21e>
  8004da:	0f be c0             	movsbl %al,%eax
  8004dd:	83 e8 20             	sub    $0x20,%eax
  8004e0:	83 f8 5e             	cmp    $0x5e,%eax
  8004e3:	76 10                	jbe    8004f5 <vprintfmt+0x21e>
					putch('?', putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	ff 75 0c             	pushl  0xc(%ebp)
  8004eb:	6a 3f                	push   $0x3f
  8004ed:	ff 55 08             	call   *0x8(%ebp)
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	eb 0d                	jmp    800502 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  8004f5:	83 ec 08             	sub    $0x8,%esp
  8004f8:	ff 75 0c             	pushl  0xc(%ebp)
  8004fb:	52                   	push   %edx
  8004fc:	ff 55 08             	call   *0x8(%ebp)
  8004ff:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800502:	83 eb 01             	sub    $0x1,%ebx
  800505:	eb 1a                	jmp    800521 <vprintfmt+0x24a>
  800507:	89 75 08             	mov    %esi,0x8(%ebp)
  80050a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800510:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800513:	eb 0c                	jmp    800521 <vprintfmt+0x24a>
  800515:	89 75 08             	mov    %esi,0x8(%ebp)
  800518:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800521:	83 c7 01             	add    $0x1,%edi
  800524:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800528:	0f be d0             	movsbl %al,%edx
  80052b:	85 d2                	test   %edx,%edx
  80052d:	74 23                	je     800552 <vprintfmt+0x27b>
  80052f:	85 f6                	test   %esi,%esi
  800531:	78 a1                	js     8004d4 <vprintfmt+0x1fd>
  800533:	83 ee 01             	sub    $0x1,%esi
  800536:	79 9c                	jns    8004d4 <vprintfmt+0x1fd>
  800538:	89 df                	mov    %ebx,%edi
  80053a:	8b 75 08             	mov    0x8(%ebp),%esi
  80053d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800540:	eb 18                	jmp    80055a <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	53                   	push   %ebx
  800546:	6a 20                	push   $0x20
  800548:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054a:	83 ef 01             	sub    $0x1,%edi
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	eb 08                	jmp    80055a <vprintfmt+0x283>
  800552:	89 df                	mov    %ebx,%edi
  800554:	8b 75 08             	mov    0x8(%ebp),%esi
  800557:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80055a:	85 ff                	test   %edi,%edi
  80055c:	7f e4                	jg     800542 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800561:	e9 a2 fd ff ff       	jmp    800308 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800566:	83 fa 01             	cmp    $0x1,%edx
  800569:	7e 16                	jle    800581 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8d 50 08             	lea    0x8(%eax),%edx
  800571:	89 55 14             	mov    %edx,0x14(%ebp)
  800574:	8b 50 04             	mov    0x4(%eax),%edx
  800577:	8b 00                	mov    (%eax),%eax
  800579:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057f:	eb 32                	jmp    8005b3 <vprintfmt+0x2dc>
	else if (lflag)
  800581:	85 d2                	test   %edx,%edx
  800583:	74 18                	je     80059d <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8d 50 04             	lea    0x4(%eax),%edx
  80058b:	89 55 14             	mov    %edx,0x14(%ebp)
  80058e:	8b 00                	mov    (%eax),%eax
  800590:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800593:	89 c1                	mov    %eax,%ecx
  800595:	c1 f9 1f             	sar    $0x1f,%ecx
  800598:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80059b:	eb 16                	jmp    8005b3 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8d 50 04             	lea    0x4(%eax),%edx
  8005a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a6:	8b 00                	mov    (%eax),%eax
  8005a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ab:	89 c1                	mov    %eax,%ecx
  8005ad:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005be:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c2:	79 74                	jns    800638 <vprintfmt+0x361>
				putch('-', putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	53                   	push   %ebx
  8005c8:	6a 2d                	push   $0x2d
  8005ca:	ff d6                	call   *%esi
				num = -(long long) num;
  8005cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d2:	f7 d8                	neg    %eax
  8005d4:	83 d2 00             	adc    $0x0,%edx
  8005d7:	f7 da                	neg    %edx
  8005d9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005dc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e1:	eb 55                	jmp    800638 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e6:	e8 78 fc ff ff       	call   800263 <getuint>
			base = 10;
  8005eb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f0:	eb 46                	jmp    800638 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  8005f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f5:	e8 69 fc ff ff       	call   800263 <getuint>
      base = 8;
  8005fa:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8005ff:	eb 37                	jmp    800638 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	6a 30                	push   $0x30
  800607:	ff d6                	call   *%esi
			putch('x', putdat);
  800609:	83 c4 08             	add    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 78                	push   $0x78
  80060f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 50 04             	lea    0x4(%eax),%edx
  800617:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80061a:	8b 00                	mov    (%eax),%eax
  80061c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800621:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800624:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800629:	eb 0d                	jmp    800638 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80062b:	8d 45 14             	lea    0x14(%ebp),%eax
  80062e:	e8 30 fc ff ff       	call   800263 <getuint>
			base = 16;
  800633:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800638:	83 ec 0c             	sub    $0xc,%esp
  80063b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80063f:	57                   	push   %edi
  800640:	ff 75 e0             	pushl  -0x20(%ebp)
  800643:	51                   	push   %ecx
  800644:	52                   	push   %edx
  800645:	50                   	push   %eax
  800646:	89 da                	mov    %ebx,%edx
  800648:	89 f0                	mov    %esi,%eax
  80064a:	e8 65 fb ff ff       	call   8001b4 <printnum>
			break;
  80064f:	83 c4 20             	add    $0x20,%esp
  800652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800655:	e9 ae fc ff ff       	jmp    800308 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	51                   	push   %ecx
  80065f:	ff d6                	call   *%esi
			break;
  800661:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800667:	e9 9c fc ff ff       	jmp    800308 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066c:	83 fa 01             	cmp    $0x1,%edx
  80066f:	7e 0d                	jle    80067e <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8d 50 08             	lea    0x8(%eax),%edx
  800677:	89 55 14             	mov    %edx,0x14(%ebp)
  80067a:	8b 00                	mov    (%eax),%eax
  80067c:	eb 1c                	jmp    80069a <vprintfmt+0x3c3>
	else if (lflag)
  80067e:	85 d2                	test   %edx,%edx
  800680:	74 0d                	je     80068f <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 50 04             	lea    0x4(%eax),%edx
  800688:	89 55 14             	mov    %edx,0x14(%ebp)
  80068b:	8b 00                	mov    (%eax),%eax
  80068d:	eb 0b                	jmp    80069a <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8d 50 04             	lea    0x4(%eax),%edx
  800695:	89 55 14             	mov    %edx,0x14(%ebp)
  800698:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  80069a:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  8006a2:	e9 61 fc ff ff       	jmp    800308 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 25                	push   $0x25
  8006ad:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	eb 03                	jmp    8006b7 <vprintfmt+0x3e0>
  8006b4:	83 ef 01             	sub    $0x1,%edi
  8006b7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006bb:	75 f7                	jne    8006b4 <vprintfmt+0x3dd>
  8006bd:	e9 46 fc ff ff       	jmp    800308 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  8006c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c5:	5b                   	pop    %ebx
  8006c6:	5e                   	pop    %esi
  8006c7:	5f                   	pop    %edi
  8006c8:	5d                   	pop    %ebp
  8006c9:	c3                   	ret    

008006ca <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	83 ec 18             	sub    $0x18,%esp
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006dd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	74 26                	je     800711 <vsnprintf+0x47>
  8006eb:	85 d2                	test   %edx,%edx
  8006ed:	7e 22                	jle    800711 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ef:	ff 75 14             	pushl  0x14(%ebp)
  8006f2:	ff 75 10             	pushl  0x10(%ebp)
  8006f5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f8:	50                   	push   %eax
  8006f9:	68 9d 02 80 00       	push   $0x80029d
  8006fe:	e8 d4 fb ff ff       	call   8002d7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800703:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800706:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800709:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	eb 05                	jmp    800716 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800711:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800716:	c9                   	leave  
  800717:	c3                   	ret    

00800718 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800721:	50                   	push   %eax
  800722:	ff 75 10             	pushl  0x10(%ebp)
  800725:	ff 75 0c             	pushl  0xc(%ebp)
  800728:	ff 75 08             	pushl  0x8(%ebp)
  80072b:	e8 9a ff ff ff       	call   8006ca <vsnprintf>
	va_end(ap);

	return rc;
}
  800730:	c9                   	leave  
  800731:	c3                   	ret    

00800732 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800738:	b8 00 00 00 00       	mov    $0x0,%eax
  80073d:	eb 03                	jmp    800742 <strlen+0x10>
		n++;
  80073f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800742:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800746:	75 f7                	jne    80073f <strlen+0xd>
		n++;
	return n;
}
  800748:	5d                   	pop    %ebp
  800749:	c3                   	ret    

0080074a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800750:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800753:	ba 00 00 00 00       	mov    $0x0,%edx
  800758:	eb 03                	jmp    80075d <strnlen+0x13>
		n++;
  80075a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075d:	39 c2                	cmp    %eax,%edx
  80075f:	74 08                	je     800769 <strnlen+0x1f>
  800761:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800765:	75 f3                	jne    80075a <strnlen+0x10>
  800767:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	53                   	push   %ebx
  80076f:	8b 45 08             	mov    0x8(%ebp),%eax
  800772:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800775:	89 c2                	mov    %eax,%edx
  800777:	83 c2 01             	add    $0x1,%edx
  80077a:	83 c1 01             	add    $0x1,%ecx
  80077d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800781:	88 5a ff             	mov    %bl,-0x1(%edx)
  800784:	84 db                	test   %bl,%bl
  800786:	75 ef                	jne    800777 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800788:	5b                   	pop    %ebx
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	53                   	push   %ebx
  80078f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800792:	53                   	push   %ebx
  800793:	e8 9a ff ff ff       	call   800732 <strlen>
  800798:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80079b:	ff 75 0c             	pushl  0xc(%ebp)
  80079e:	01 d8                	add    %ebx,%eax
  8007a0:	50                   	push   %eax
  8007a1:	e8 c5 ff ff ff       	call   80076b <strcpy>
	return dst;
}
  8007a6:	89 d8                	mov    %ebx,%eax
  8007a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ab:	c9                   	leave  
  8007ac:	c3                   	ret    

008007ad <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	56                   	push   %esi
  8007b1:	53                   	push   %ebx
  8007b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b8:	89 f3                	mov    %esi,%ebx
  8007ba:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bd:	89 f2                	mov    %esi,%edx
  8007bf:	eb 0f                	jmp    8007d0 <strncpy+0x23>
		*dst++ = *src;
  8007c1:	83 c2 01             	add    $0x1,%edx
  8007c4:	0f b6 01             	movzbl (%ecx),%eax
  8007c7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ca:	80 39 01             	cmpb   $0x1,(%ecx)
  8007cd:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d0:	39 da                	cmp    %ebx,%edx
  8007d2:	75 ed                	jne    8007c1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d4:	89 f0                	mov    %esi,%eax
  8007d6:	5b                   	pop    %ebx
  8007d7:	5e                   	pop    %esi
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	56                   	push   %esi
  8007de:	53                   	push   %ebx
  8007df:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e5:	8b 55 10             	mov    0x10(%ebp),%edx
  8007e8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ea:	85 d2                	test   %edx,%edx
  8007ec:	74 21                	je     80080f <strlcpy+0x35>
  8007ee:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007f2:	89 f2                	mov    %esi,%edx
  8007f4:	eb 09                	jmp    8007ff <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f6:	83 c2 01             	add    $0x1,%edx
  8007f9:	83 c1 01             	add    $0x1,%ecx
  8007fc:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ff:	39 c2                	cmp    %eax,%edx
  800801:	74 09                	je     80080c <strlcpy+0x32>
  800803:	0f b6 19             	movzbl (%ecx),%ebx
  800806:	84 db                	test   %bl,%bl
  800808:	75 ec                	jne    8007f6 <strlcpy+0x1c>
  80080a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80080c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80080f:	29 f0                	sub    %esi,%eax
}
  800811:	5b                   	pop    %ebx
  800812:	5e                   	pop    %esi
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80081e:	eb 06                	jmp    800826 <strcmp+0x11>
		p++, q++;
  800820:	83 c1 01             	add    $0x1,%ecx
  800823:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800826:	0f b6 01             	movzbl (%ecx),%eax
  800829:	84 c0                	test   %al,%al
  80082b:	74 04                	je     800831 <strcmp+0x1c>
  80082d:	3a 02                	cmp    (%edx),%al
  80082f:	74 ef                	je     800820 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800831:	0f b6 c0             	movzbl %al,%eax
  800834:	0f b6 12             	movzbl (%edx),%edx
  800837:	29 d0                	sub    %edx,%eax
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	8b 45 08             	mov    0x8(%ebp),%eax
  800842:	8b 55 0c             	mov    0xc(%ebp),%edx
  800845:	89 c3                	mov    %eax,%ebx
  800847:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80084a:	eb 06                	jmp    800852 <strncmp+0x17>
		n--, p++, q++;
  80084c:	83 c0 01             	add    $0x1,%eax
  80084f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800852:	39 d8                	cmp    %ebx,%eax
  800854:	74 15                	je     80086b <strncmp+0x30>
  800856:	0f b6 08             	movzbl (%eax),%ecx
  800859:	84 c9                	test   %cl,%cl
  80085b:	74 04                	je     800861 <strncmp+0x26>
  80085d:	3a 0a                	cmp    (%edx),%cl
  80085f:	74 eb                	je     80084c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800861:	0f b6 00             	movzbl (%eax),%eax
  800864:	0f b6 12             	movzbl (%edx),%edx
  800867:	29 d0                	sub    %edx,%eax
  800869:	eb 05                	jmp    800870 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80086b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800870:	5b                   	pop    %ebx
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 45 08             	mov    0x8(%ebp),%eax
  800879:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80087d:	eb 07                	jmp    800886 <strchr+0x13>
		if (*s == c)
  80087f:	38 ca                	cmp    %cl,%dl
  800881:	74 0f                	je     800892 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800883:	83 c0 01             	add    $0x1,%eax
  800886:	0f b6 10             	movzbl (%eax),%edx
  800889:	84 d2                	test   %dl,%dl
  80088b:	75 f2                	jne    80087f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80088d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089e:	eb 03                	jmp    8008a3 <strfind+0xf>
  8008a0:	83 c0 01             	add    $0x1,%eax
  8008a3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008a6:	38 ca                	cmp    %cl,%dl
  8008a8:	74 04                	je     8008ae <strfind+0x1a>
  8008aa:	84 d2                	test   %dl,%dl
  8008ac:	75 f2                	jne    8008a0 <strfind+0xc>
			break;
	return (char *) s;
}
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	57                   	push   %edi
  8008b4:	56                   	push   %esi
  8008b5:	53                   	push   %ebx
  8008b6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008bc:	85 c9                	test   %ecx,%ecx
  8008be:	74 36                	je     8008f6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c6:	75 28                	jne    8008f0 <memset+0x40>
  8008c8:	f6 c1 03             	test   $0x3,%cl
  8008cb:	75 23                	jne    8008f0 <memset+0x40>
		c &= 0xFF;
  8008cd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d1:	89 d3                	mov    %edx,%ebx
  8008d3:	c1 e3 08             	shl    $0x8,%ebx
  8008d6:	89 d6                	mov    %edx,%esi
  8008d8:	c1 e6 18             	shl    $0x18,%esi
  8008db:	89 d0                	mov    %edx,%eax
  8008dd:	c1 e0 10             	shl    $0x10,%eax
  8008e0:	09 f0                	or     %esi,%eax
  8008e2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008e4:	89 d8                	mov    %ebx,%eax
  8008e6:	09 d0                	or     %edx,%eax
  8008e8:	c1 e9 02             	shr    $0x2,%ecx
  8008eb:	fc                   	cld    
  8008ec:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ee:	eb 06                	jmp    8008f6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f3:	fc                   	cld    
  8008f4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f6:	89 f8                	mov    %edi,%eax
  8008f8:	5b                   	pop    %ebx
  8008f9:	5e                   	pop    %esi
  8008fa:	5f                   	pop    %edi
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	57                   	push   %edi
  800901:	56                   	push   %esi
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	8b 75 0c             	mov    0xc(%ebp),%esi
  800908:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80090b:	39 c6                	cmp    %eax,%esi
  80090d:	73 35                	jae    800944 <memmove+0x47>
  80090f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800912:	39 d0                	cmp    %edx,%eax
  800914:	73 2e                	jae    800944 <memmove+0x47>
		s += n;
		d += n;
  800916:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800919:	89 d6                	mov    %edx,%esi
  80091b:	09 fe                	or     %edi,%esi
  80091d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800923:	75 13                	jne    800938 <memmove+0x3b>
  800925:	f6 c1 03             	test   $0x3,%cl
  800928:	75 0e                	jne    800938 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80092a:	83 ef 04             	sub    $0x4,%edi
  80092d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800930:	c1 e9 02             	shr    $0x2,%ecx
  800933:	fd                   	std    
  800934:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800936:	eb 09                	jmp    800941 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800938:	83 ef 01             	sub    $0x1,%edi
  80093b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80093e:	fd                   	std    
  80093f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800941:	fc                   	cld    
  800942:	eb 1d                	jmp    800961 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800944:	89 f2                	mov    %esi,%edx
  800946:	09 c2                	or     %eax,%edx
  800948:	f6 c2 03             	test   $0x3,%dl
  80094b:	75 0f                	jne    80095c <memmove+0x5f>
  80094d:	f6 c1 03             	test   $0x3,%cl
  800950:	75 0a                	jne    80095c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800952:	c1 e9 02             	shr    $0x2,%ecx
  800955:	89 c7                	mov    %eax,%edi
  800957:	fc                   	cld    
  800958:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095a:	eb 05                	jmp    800961 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80095c:	89 c7                	mov    %eax,%edi
  80095e:	fc                   	cld    
  80095f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800961:	5e                   	pop    %esi
  800962:	5f                   	pop    %edi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800968:	ff 75 10             	pushl  0x10(%ebp)
  80096b:	ff 75 0c             	pushl  0xc(%ebp)
  80096e:	ff 75 08             	pushl  0x8(%ebp)
  800971:	e8 87 ff ff ff       	call   8008fd <memmove>
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	56                   	push   %esi
  80097c:	53                   	push   %ebx
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	8b 55 0c             	mov    0xc(%ebp),%edx
  800983:	89 c6                	mov    %eax,%esi
  800985:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800988:	eb 1a                	jmp    8009a4 <memcmp+0x2c>
		if (*s1 != *s2)
  80098a:	0f b6 08             	movzbl (%eax),%ecx
  80098d:	0f b6 1a             	movzbl (%edx),%ebx
  800990:	38 d9                	cmp    %bl,%cl
  800992:	74 0a                	je     80099e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800994:	0f b6 c1             	movzbl %cl,%eax
  800997:	0f b6 db             	movzbl %bl,%ebx
  80099a:	29 d8                	sub    %ebx,%eax
  80099c:	eb 0f                	jmp    8009ad <memcmp+0x35>
		s1++, s2++;
  80099e:	83 c0 01             	add    $0x1,%eax
  8009a1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a4:	39 f0                	cmp    %esi,%eax
  8009a6:	75 e2                	jne    80098a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ad:	5b                   	pop    %ebx
  8009ae:	5e                   	pop    %esi
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	53                   	push   %ebx
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009b8:	89 c1                	mov    %eax,%ecx
  8009ba:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009bd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c1:	eb 0a                	jmp    8009cd <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c3:	0f b6 10             	movzbl (%eax),%edx
  8009c6:	39 da                	cmp    %ebx,%edx
  8009c8:	74 07                	je     8009d1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	39 c8                	cmp    %ecx,%eax
  8009cf:	72 f2                	jb     8009c3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d1:	5b                   	pop    %ebx
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	57                   	push   %edi
  8009d8:	56                   	push   %esi
  8009d9:	53                   	push   %ebx
  8009da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e0:	eb 03                	jmp    8009e5 <strtol+0x11>
		s++;
  8009e2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e5:	0f b6 01             	movzbl (%ecx),%eax
  8009e8:	3c 20                	cmp    $0x20,%al
  8009ea:	74 f6                	je     8009e2 <strtol+0xe>
  8009ec:	3c 09                	cmp    $0x9,%al
  8009ee:	74 f2                	je     8009e2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f0:	3c 2b                	cmp    $0x2b,%al
  8009f2:	75 0a                	jne    8009fe <strtol+0x2a>
		s++;
  8009f4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f7:	bf 00 00 00 00       	mov    $0x0,%edi
  8009fc:	eb 11                	jmp    800a0f <strtol+0x3b>
  8009fe:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a03:	3c 2d                	cmp    $0x2d,%al
  800a05:	75 08                	jne    800a0f <strtol+0x3b>
		s++, neg = 1;
  800a07:	83 c1 01             	add    $0x1,%ecx
  800a0a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a0f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a15:	75 15                	jne    800a2c <strtol+0x58>
  800a17:	80 39 30             	cmpb   $0x30,(%ecx)
  800a1a:	75 10                	jne    800a2c <strtol+0x58>
  800a1c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a20:	75 7c                	jne    800a9e <strtol+0xca>
		s += 2, base = 16;
  800a22:	83 c1 02             	add    $0x2,%ecx
  800a25:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a2a:	eb 16                	jmp    800a42 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a2c:	85 db                	test   %ebx,%ebx
  800a2e:	75 12                	jne    800a42 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a30:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a35:	80 39 30             	cmpb   $0x30,(%ecx)
  800a38:	75 08                	jne    800a42 <strtol+0x6e>
		s++, base = 8;
  800a3a:	83 c1 01             	add    $0x1,%ecx
  800a3d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
  800a47:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a4a:	0f b6 11             	movzbl (%ecx),%edx
  800a4d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a50:	89 f3                	mov    %esi,%ebx
  800a52:	80 fb 09             	cmp    $0x9,%bl
  800a55:	77 08                	ja     800a5f <strtol+0x8b>
			dig = *s - '0';
  800a57:	0f be d2             	movsbl %dl,%edx
  800a5a:	83 ea 30             	sub    $0x30,%edx
  800a5d:	eb 22                	jmp    800a81 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a5f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a62:	89 f3                	mov    %esi,%ebx
  800a64:	80 fb 19             	cmp    $0x19,%bl
  800a67:	77 08                	ja     800a71 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a69:	0f be d2             	movsbl %dl,%edx
  800a6c:	83 ea 57             	sub    $0x57,%edx
  800a6f:	eb 10                	jmp    800a81 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a71:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a74:	89 f3                	mov    %esi,%ebx
  800a76:	80 fb 19             	cmp    $0x19,%bl
  800a79:	77 16                	ja     800a91 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a7b:	0f be d2             	movsbl %dl,%edx
  800a7e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a81:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a84:	7d 0b                	jge    800a91 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a86:	83 c1 01             	add    $0x1,%ecx
  800a89:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a8d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a8f:	eb b9                	jmp    800a4a <strtol+0x76>

	if (endptr)
  800a91:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a95:	74 0d                	je     800aa4 <strtol+0xd0>
		*endptr = (char *) s;
  800a97:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9a:	89 0e                	mov    %ecx,(%esi)
  800a9c:	eb 06                	jmp    800aa4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9e:	85 db                	test   %ebx,%ebx
  800aa0:	74 98                	je     800a3a <strtol+0x66>
  800aa2:	eb 9e                	jmp    800a42 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aa4:	89 c2                	mov    %eax,%edx
  800aa6:	f7 da                	neg    %edx
  800aa8:	85 ff                	test   %edi,%edi
  800aaa:	0f 45 c2             	cmovne %edx,%eax
}
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab8:	b8 00 00 00 00       	mov    $0x0,%eax
  800abd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac3:	89 c3                	mov    %eax,%ebx
  800ac5:	89 c7                	mov    %eax,%edi
  800ac7:	89 c6                	mov    %eax,%esi
  800ac9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800acb:	5b                   	pop    %ebx
  800acc:	5e                   	pop    %esi
  800acd:	5f                   	pop    %edi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad6:	ba 00 00 00 00       	mov    $0x0,%edx
  800adb:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae0:	89 d1                	mov    %edx,%ecx
  800ae2:	89 d3                	mov    %edx,%ebx
  800ae4:	89 d7                	mov    %edx,%edi
  800ae6:	89 d6                	mov    %edx,%esi
  800ae8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
  800af5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800afd:	b8 03 00 00 00       	mov    $0x3,%eax
  800b02:	8b 55 08             	mov    0x8(%ebp),%edx
  800b05:	89 cb                	mov    %ecx,%ebx
  800b07:	89 cf                	mov    %ecx,%edi
  800b09:	89 ce                	mov    %ecx,%esi
  800b0b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b0d:	85 c0                	test   %eax,%eax
  800b0f:	7e 17                	jle    800b28 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b11:	83 ec 0c             	sub    $0xc,%esp
  800b14:	50                   	push   %eax
  800b15:	6a 03                	push   $0x3
  800b17:	68 84 17 80 00       	push   $0x801784
  800b1c:	6a 23                	push   $0x23
  800b1e:	68 a1 17 80 00       	push   $0x8017a1
  800b23:	e8 f5 05 00 00       	call   80111d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b36:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b40:	89 d1                	mov    %edx,%ecx
  800b42:	89 d3                	mov    %edx,%ebx
  800b44:	89 d7                	mov    %edx,%edi
  800b46:	89 d6                	mov    %edx,%esi
  800b48:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <sys_yield>:

void
sys_yield(void)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b55:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b5f:	89 d1                	mov    %edx,%ecx
  800b61:	89 d3                	mov    %edx,%ebx
  800b63:	89 d7                	mov    %edx,%edi
  800b65:	89 d6                	mov    %edx,%esi
  800b67:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b77:	be 00 00 00 00       	mov    $0x0,%esi
  800b7c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8a:	89 f7                	mov    %esi,%edi
  800b8c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b8e:	85 c0                	test   %eax,%eax
  800b90:	7e 17                	jle    800ba9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b92:	83 ec 0c             	sub    $0xc,%esp
  800b95:	50                   	push   %eax
  800b96:	6a 04                	push   $0x4
  800b98:	68 84 17 80 00       	push   $0x801784
  800b9d:	6a 23                	push   $0x23
  800b9f:	68 a1 17 80 00       	push   $0x8017a1
  800ba4:	e8 74 05 00 00       	call   80111d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bba:	b8 05 00 00 00       	mov    $0x5,%eax
  800bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bcb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	7e 17                	jle    800beb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd4:	83 ec 0c             	sub    $0xc,%esp
  800bd7:	50                   	push   %eax
  800bd8:	6a 05                	push   $0x5
  800bda:	68 84 17 80 00       	push   $0x801784
  800bdf:	6a 23                	push   $0x23
  800be1:	68 a1 17 80 00       	push   $0x8017a1
  800be6:	e8 32 05 00 00       	call   80111d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800beb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c01:	b8 06 00 00 00       	mov    $0x6,%eax
  800c06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c09:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0c:	89 df                	mov    %ebx,%edi
  800c0e:	89 de                	mov    %ebx,%esi
  800c10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c12:	85 c0                	test   %eax,%eax
  800c14:	7e 17                	jle    800c2d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c16:	83 ec 0c             	sub    $0xc,%esp
  800c19:	50                   	push   %eax
  800c1a:	6a 06                	push   $0x6
  800c1c:	68 84 17 80 00       	push   $0x801784
  800c21:	6a 23                	push   $0x23
  800c23:	68 a1 17 80 00       	push   $0x8017a1
  800c28:	e8 f0 04 00 00       	call   80111d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c43:	b8 08 00 00 00       	mov    $0x8,%eax
  800c48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4e:	89 df                	mov    %ebx,%edi
  800c50:	89 de                	mov    %ebx,%esi
  800c52:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c54:	85 c0                	test   %eax,%eax
  800c56:	7e 17                	jle    800c6f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c58:	83 ec 0c             	sub    $0xc,%esp
  800c5b:	50                   	push   %eax
  800c5c:	6a 08                	push   $0x8
  800c5e:	68 84 17 80 00       	push   $0x801784
  800c63:	6a 23                	push   $0x23
  800c65:	68 a1 17 80 00       	push   $0x8017a1
  800c6a:	e8 ae 04 00 00       	call   80111d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	57                   	push   %edi
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
  800c7d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c85:	b8 09 00 00 00       	mov    $0x9,%eax
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	89 df                	mov    %ebx,%edi
  800c92:	89 de                	mov    %ebx,%esi
  800c94:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c96:	85 c0                	test   %eax,%eax
  800c98:	7e 17                	jle    800cb1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9a:	83 ec 0c             	sub    $0xc,%esp
  800c9d:	50                   	push   %eax
  800c9e:	6a 09                	push   $0x9
  800ca0:	68 84 17 80 00       	push   $0x801784
  800ca5:	6a 23                	push   $0x23
  800ca7:	68 a1 17 80 00       	push   $0x8017a1
  800cac:	e8 6c 04 00 00       	call   80111d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbf:	be 00 00 00 00       	mov    $0x0,%esi
  800cc4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cea:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	89 cb                	mov    %ecx,%ebx
  800cf4:	89 cf                	mov    %ecx,%edi
  800cf6:	89 ce                	mov    %ecx,%esi
  800cf8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 17                	jle    800d15 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	83 ec 0c             	sub    $0xc,%esp
  800d01:	50                   	push   %eax
  800d02:	6a 0c                	push   $0xc
  800d04:	68 84 17 80 00       	push   $0x801784
  800d09:	6a 23                	push   $0x23
  800d0b:	68 a1 17 80 00       	push   $0x8017a1
  800d10:	e8 08 04 00 00       	call   80111d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_change_pr>:

int
sys_change_pr(int pr)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d23:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d28:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	89 cb                	mov    %ecx,%ebx
  800d32:	89 cf                	mov    %ecx,%edi
  800d34:	89 ce                	mov    %ecx,%esi
  800d36:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	53                   	push   %ebx
  800d41:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
	// cprintf("1\n");
	void *addr = (void*) (pn*PGSIZE);
  800d44:	89 d3                	mov    %edx,%ebx
  800d46:	c1 e3 0c             	shl    $0xc,%ebx
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800d49:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d50:	f6 c1 02             	test   $0x2,%cl
  800d53:	75 0c                	jne    800d61 <duppage+0x24>
  800d55:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d5c:	f6 c6 08             	test   $0x8,%dh
  800d5f:	74 5b                	je     800dbc <duppage+0x7f>
		if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800d61:	83 ec 0c             	sub    $0xc,%esp
  800d64:	68 05 08 00 00       	push   $0x805
  800d69:	53                   	push   %ebx
  800d6a:	50                   	push   %eax
  800d6b:	53                   	push   %ebx
  800d6c:	6a 00                	push   $0x0
  800d6e:	e8 3e fe ff ff       	call   800bb1 <sys_page_map>
  800d73:	83 c4 20             	add    $0x20,%esp
  800d76:	85 c0                	test   %eax,%eax
  800d78:	79 14                	jns    800d8e <duppage+0x51>
			panic("2");
  800d7a:	83 ec 04             	sub    $0x4,%esp
  800d7d:	68 af 17 80 00       	push   $0x8017af
  800d82:	6a 49                	push   $0x49
  800d84:	68 b1 17 80 00       	push   $0x8017b1
  800d89:	e8 8f 03 00 00       	call   80111d <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800d8e:	83 ec 0c             	sub    $0xc,%esp
  800d91:	68 05 08 00 00       	push   $0x805
  800d96:	53                   	push   %ebx
  800d97:	6a 00                	push   $0x0
  800d99:	53                   	push   %ebx
  800d9a:	6a 00                	push   $0x0
  800d9c:	e8 10 fe ff ff       	call   800bb1 <sys_page_map>
  800da1:	83 c4 20             	add    $0x20,%esp
  800da4:	85 c0                	test   %eax,%eax
  800da6:	79 26                	jns    800dce <duppage+0x91>
			panic("3");
  800da8:	83 ec 04             	sub    $0x4,%esp
  800dab:	68 bc 17 80 00       	push   $0x8017bc
  800db0:	6a 4b                	push   $0x4b
  800db2:	68 b1 17 80 00       	push   $0x8017b1
  800db7:	e8 61 03 00 00       	call   80111d <_panic>
	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800dbc:	83 ec 0c             	sub    $0xc,%esp
  800dbf:	6a 05                	push   $0x5
  800dc1:	53                   	push   %ebx
  800dc2:	50                   	push   %eax
  800dc3:	53                   	push   %ebx
  800dc4:	6a 00                	push   $0x0
  800dc6:	e8 e6 fd ff ff       	call   800bb1 <sys_page_map>
  800dcb:	83 c4 20             	add    $0x20,%esp
	// cprintf("2\n");
	return 0;
	panic("duppage not implemented");
}
  800dce:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dd6:	c9                   	leave  
  800dd7:	c3                   	ret    

00800dd8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	53                   	push   %ebx
  800ddc:	83 ec 04             	sub    $0x4,%esp
  800ddf:	8b 55 08             	mov    0x8(%ebp),%edx
	// panic("pgfault");
	void *addr = (void *) utf->utf_fault_va;
  800de2:	8b 02                	mov    (%edx),%eax
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800de4:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800de8:	74 2e                	je     800e18 <pgfault+0x40>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800dea:	89 c2                	mov    %eax,%edx
  800dec:	c1 ea 16             	shr    $0x16,%edx
  800def:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800df6:	f6 c2 01             	test   $0x1,%dl
  800df9:	74 1d                	je     800e18 <pgfault+0x40>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800dfb:	89 c2                	mov    %eax,%edx
  800dfd:	c1 ea 0c             	shr    $0xc,%edx
  800e00:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e07:	f6 c1 01             	test   $0x1,%cl
  800e0a:	74 0c                	je     800e18 <pgfault+0x40>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e0c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e13:	f6 c6 08             	test   $0x8,%dh
  800e16:	75 14                	jne    800e2c <pgfault+0x54>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800e18:	83 ec 04             	sub    $0x4,%esp
  800e1b:	68 be 17 80 00       	push   $0x8017be
  800e20:	6a 20                	push   $0x20
  800e22:	68 b1 17 80 00       	push   $0x8017b1
  800e27:	e8 f1 02 00 00       	call   80111d <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800e2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e31:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800e33:	83 ec 04             	sub    $0x4,%esp
  800e36:	6a 07                	push   $0x7
  800e38:	68 00 f0 7f 00       	push   $0x7ff000
  800e3d:	6a 00                	push   $0x0
  800e3f:	e8 2a fd ff ff       	call   800b6e <sys_page_alloc>
  800e44:	83 c4 10             	add    $0x10,%esp
  800e47:	85 c0                	test   %eax,%eax
  800e49:	79 14                	jns    800e5f <pgfault+0x87>
		panic("sys_page_alloc");
  800e4b:	83 ec 04             	sub    $0x4,%esp
  800e4e:	68 d0 17 80 00       	push   $0x8017d0
  800e53:	6a 2c                	push   $0x2c
  800e55:	68 b1 17 80 00       	push   $0x8017b1
  800e5a:	e8 be 02 00 00       	call   80111d <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  800e5f:	83 ec 04             	sub    $0x4,%esp
  800e62:	68 00 10 00 00       	push   $0x1000
  800e67:	53                   	push   %ebx
  800e68:	68 00 f0 7f 00       	push   $0x7ff000
  800e6d:	e8 f3 fa ff ff       	call   800965 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800e72:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e79:	53                   	push   %ebx
  800e7a:	6a 00                	push   $0x0
  800e7c:	68 00 f0 7f 00       	push   $0x7ff000
  800e81:	6a 00                	push   $0x0
  800e83:	e8 29 fd ff ff       	call   800bb1 <sys_page_map>
  800e88:	83 c4 20             	add    $0x20,%esp
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	79 14                	jns    800ea3 <pgfault+0xcb>
		panic("sys_page_map");
  800e8f:	83 ec 04             	sub    $0x4,%esp
  800e92:	68 df 17 80 00       	push   $0x8017df
  800e97:	6a 2f                	push   $0x2f
  800e99:	68 b1 17 80 00       	push   $0x8017b1
  800e9e:	e8 7a 02 00 00       	call   80111d <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800ea3:	83 ec 08             	sub    $0x8,%esp
  800ea6:	68 00 f0 7f 00       	push   $0x7ff000
  800eab:	6a 00                	push   $0x0
  800ead:	e8 41 fd ff ff       	call   800bf3 <sys_page_unmap>
  800eb2:	83 c4 10             	add    $0x10,%esp
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	79 14                	jns    800ecd <pgfault+0xf5>
		panic("sys_page_unmap");
  800eb9:	83 ec 04             	sub    $0x4,%esp
  800ebc:	68 ec 17 80 00       	push   $0x8017ec
  800ec1:	6a 31                	push   $0x31
  800ec3:	68 b1 17 80 00       	push   $0x8017b1
  800ec8:	e8 50 02 00 00       	call   80111d <_panic>
	return;
}
  800ecd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed0:	c9                   	leave  
  800ed1:	c3                   	ret    

00800ed2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
  800ed8:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800edb:	68 d8 0d 80 00       	push   $0x800dd8
  800ee0:	e8 7e 02 00 00       	call   801163 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ee5:	b8 07 00 00 00       	mov    $0x7,%eax
  800eea:	cd 30                	int    $0x30

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800eec:	83 c4 10             	add    $0x10,%esp
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	75 21                	jne    800f14 <fork+0x42>
		// panic("child");
		thisenv = &envs[ENVX(sys_getenvid())];
  800ef3:	e8 38 fc ff ff       	call   800b30 <sys_getenvid>
  800ef8:	25 ff 03 00 00       	and    $0x3ff,%eax
  800efd:	c1 e0 07             	shl    $0x7,%eax
  800f00:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f05:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0f:	e9 c6 00 00 00       	jmp    800fda <fork+0x108>
  800f14:	89 c6                	mov    %eax,%esi
  800f16:	89 c7                	mov    %eax,%edi
	}
	// cprintf("sys_exofork: %x\n", envid);
	if (envid < 0)
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	79 12                	jns    800f2e <fork+0x5c>
		panic("sys_exofork: %e", envid);
  800f1c:	50                   	push   %eax
  800f1d:	68 fb 17 80 00       	push   $0x8017fb
  800f22:	6a 71                	push   $0x71
  800f24:	68 b1 17 80 00       	push   $0x8017b1
  800f29:	e8 ef 01 00 00       	call   80111d <_panic>
  800f2e:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800f33:	89 d8                	mov    %ebx,%eax
  800f35:	c1 e8 16             	shr    $0x16,%eax
  800f38:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f3f:	a8 01                	test   $0x1,%al
  800f41:	74 22                	je     800f65 <fork+0x93>
  800f43:	89 da                	mov    %ebx,%edx
  800f45:	c1 ea 0c             	shr    $0xc,%edx
  800f48:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f4f:	a8 01                	test   $0x1,%al
  800f51:	74 12                	je     800f65 <fork+0x93>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800f53:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f5a:	a8 04                	test   $0x4,%al
  800f5c:	74 07                	je     800f65 <fork+0x93>
			// cprintf("envid: %x, PGNUM: %x, addr: %x\n", envid, PGNUM(addr), addr);
			// if (addr!=0x802000) {
			duppage(envid, PGNUM(addr));
  800f5e:	89 f8                	mov    %edi,%eax
  800f60:	e8 d8 fd ff ff       	call   800d3d <duppage>
	}
	// cprintf("sys_exofork: %x\n", envid);
	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f65:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f6b:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f71:	75 c0                	jne    800f33 <fork+0x61>
			// cprintf("%x\n", uvpt[PGNUM(addr)]);
		}
	// panic("faint");


	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800f73:	83 ec 04             	sub    $0x4,%esp
  800f76:	6a 07                	push   $0x7
  800f78:	68 00 f0 bf ee       	push   $0xeebff000
  800f7d:	56                   	push   %esi
  800f7e:	e8 eb fb ff ff       	call   800b6e <sys_page_alloc>
  800f83:	83 c4 10             	add    $0x10,%esp
  800f86:	85 c0                	test   %eax,%eax
  800f88:	79 17                	jns    800fa1 <fork+0xcf>
		panic("1");
  800f8a:	83 ec 04             	sub    $0x4,%esp
  800f8d:	68 0b 18 80 00       	push   $0x80180b
  800f92:	68 82 00 00 00       	push   $0x82
  800f97:	68 b1 17 80 00       	push   $0x8017b1
  800f9c:	e8 7c 01 00 00       	call   80111d <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fa1:	83 ec 08             	sub    $0x8,%esp
  800fa4:	68 d2 11 80 00       	push   $0x8011d2
  800fa9:	56                   	push   %esi
  800faa:	e8 c8 fc ff ff       	call   800c77 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  800faf:	83 c4 08             	add    $0x8,%esp
  800fb2:	6a 02                	push   $0x2
  800fb4:	56                   	push   %esi
  800fb5:	e8 7b fc ff ff       	call   800c35 <sys_env_set_status>
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	79 17                	jns    800fd8 <fork+0x106>
		panic("sys_env_set_status");
  800fc1:	83 ec 04             	sub    $0x4,%esp
  800fc4:	68 0d 18 80 00       	push   $0x80180d
  800fc9:	68 87 00 00 00       	push   $0x87
  800fce:	68 b1 17 80 00       	push   $0x8017b1
  800fd3:	e8 45 01 00 00       	call   80111d <_panic>

	return envid;
  800fd8:	89 f0                	mov    %esi,%eax
	panic("fork not implemented");
}
  800fda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdd:	5b                   	pop    %ebx
  800fde:	5e                   	pop    %esi
  800fdf:	5f                   	pop    %edi
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    

00800fe2 <pfork>:

envid_t
pfork(int pr)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	57                   	push   %edi
  800fe6:	56                   	push   %esi
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800feb:	68 d8 0d 80 00       	push   $0x800dd8
  800ff0:	e8 6e 01 00 00       	call   801163 <set_pgfault_handler>
  800ff5:	b8 07 00 00 00       	mov    $0x7,%eax
  800ffa:	cd 30                	int    $0x30

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	75 2f                	jne    801032 <pfork+0x50>
		thisenv = &envs[ENVX(sys_getenvid())];
  801003:	e8 28 fb ff ff       	call   800b30 <sys_getenvid>
  801008:	25 ff 03 00 00       	and    $0x3ff,%eax
  80100d:	c1 e0 07             	shl    $0x7,%eax
  801010:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801015:	a3 04 20 80 00       	mov    %eax,0x802004
		sys_change_pr(pr);
  80101a:	83 ec 0c             	sub    $0xc,%esp
  80101d:	ff 75 08             	pushl  0x8(%ebp)
  801020:	e8 f8 fc ff ff       	call   800d1d <sys_change_pr>
		return 0;
  801025:	83 c4 10             	add    $0x10,%esp
  801028:	b8 00 00 00 00       	mov    $0x0,%eax
  80102d:	e9 c9 00 00 00       	jmp    8010fb <pfork+0x119>
  801032:	89 c6                	mov    %eax,%esi
  801034:	89 c7                	mov    %eax,%edi
	}

	if (envid < 0)
  801036:	85 c0                	test   %eax,%eax
  801038:	79 15                	jns    80104f <pfork+0x6d>
		panic("sys_exofork: %e", envid);
  80103a:	50                   	push   %eax
  80103b:	68 fb 17 80 00       	push   $0x8017fb
  801040:	68 9c 00 00 00       	push   $0x9c
  801045:	68 b1 17 80 00       	push   $0x8017b1
  80104a:	e8 ce 00 00 00       	call   80111d <_panic>
  80104f:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  801054:	89 d8                	mov    %ebx,%eax
  801056:	c1 e8 16             	shr    $0x16,%eax
  801059:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801060:	a8 01                	test   $0x1,%al
  801062:	74 22                	je     801086 <pfork+0xa4>
  801064:	89 da                	mov    %ebx,%edx
  801066:	c1 ea 0c             	shr    $0xc,%edx
  801069:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801070:	a8 01                	test   $0x1,%al
  801072:	74 12                	je     801086 <pfork+0xa4>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  801074:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80107b:	a8 04                	test   $0x4,%al
  80107d:	74 07                	je     801086 <pfork+0xa4>
			duppage(envid, PGNUM(addr));
  80107f:	89 f8                	mov    %edi,%eax
  801081:	e8 b7 fc ff ff       	call   800d3d <duppage>
	}

	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801086:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80108c:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801092:	75 c0                	jne    801054 <pfork+0x72>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801094:	83 ec 04             	sub    $0x4,%esp
  801097:	6a 07                	push   $0x7
  801099:	68 00 f0 bf ee       	push   $0xeebff000
  80109e:	56                   	push   %esi
  80109f:	e8 ca fa ff ff       	call   800b6e <sys_page_alloc>
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	79 17                	jns    8010c2 <pfork+0xe0>
		panic("1");
  8010ab:	83 ec 04             	sub    $0x4,%esp
  8010ae:	68 0b 18 80 00       	push   $0x80180b
  8010b3:	68 a5 00 00 00       	push   $0xa5
  8010b8:	68 b1 17 80 00       	push   $0x8017b1
  8010bd:	e8 5b 00 00 00       	call   80111d <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010c2:	83 ec 08             	sub    $0x8,%esp
  8010c5:	68 d2 11 80 00       	push   $0x8011d2
  8010ca:	56                   	push   %esi
  8010cb:	e8 a7 fb ff ff       	call   800c77 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8010d0:	83 c4 08             	add    $0x8,%esp
  8010d3:	6a 02                	push   $0x2
  8010d5:	56                   	push   %esi
  8010d6:	e8 5a fb ff ff       	call   800c35 <sys_env_set_status>
  8010db:	83 c4 10             	add    $0x10,%esp
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	79 17                	jns    8010f9 <pfork+0x117>
		panic("sys_env_set_status");
  8010e2:	83 ec 04             	sub    $0x4,%esp
  8010e5:	68 0d 18 80 00       	push   $0x80180d
  8010ea:	68 aa 00 00 00       	push   $0xaa
  8010ef:	68 b1 17 80 00       	push   $0x8017b1
  8010f4:	e8 24 00 00 00       	call   80111d <_panic>

	return envid;
  8010f9:	89 f0                	mov    %esi,%eax
	panic("fork not implemented");
}
  8010fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fe:	5b                   	pop    %ebx
  8010ff:	5e                   	pop    %esi
  801100:	5f                   	pop    %edi
  801101:	5d                   	pop    %ebp
  801102:	c3                   	ret    

00801103 <sfork>:

// Challenge!
int
sfork(void)
{
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801109:	68 20 18 80 00       	push   $0x801820
  80110e:	68 b4 00 00 00       	push   $0xb4
  801113:	68 b1 17 80 00       	push   $0x8017b1
  801118:	e8 00 00 00 00       	call   80111d <_panic>

0080111d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	56                   	push   %esi
  801121:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801122:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801125:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80112b:	e8 00 fa ff ff       	call   800b30 <sys_getenvid>
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	ff 75 0c             	pushl  0xc(%ebp)
  801136:	ff 75 08             	pushl  0x8(%ebp)
  801139:	56                   	push   %esi
  80113a:	50                   	push   %eax
  80113b:	68 38 18 80 00       	push   $0x801838
  801140:	e8 5b f0 ff ff       	call   8001a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801145:	83 c4 18             	add    $0x18,%esp
  801148:	53                   	push   %ebx
  801149:	ff 75 10             	pushl  0x10(%ebp)
  80114c:	e8 fe ef ff ff       	call   80014f <vcprintf>
	cprintf("\n");
  801151:	c7 04 24 34 15 80 00 	movl   $0x801534,(%esp)
  801158:	e8 43 f0 ff ff       	call   8001a0 <cprintf>
  80115d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801160:	cc                   	int3   
  801161:	eb fd                	jmp    801160 <_panic+0x43>

00801163 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	83 ec 08             	sub    $0x8,%esp
	// int r;

	if (_pgfault_handler == 0) {
  801169:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801170:	75 2c                	jne    80119e <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801172:	83 ec 04             	sub    $0x4,%esp
  801175:	6a 07                	push   $0x7
  801177:	68 00 f0 bf ee       	push   $0xeebff000
  80117c:	6a 00                	push   $0x0
  80117e:	e8 eb f9 ff ff       	call   800b6e <sys_page_alloc>
  801183:	83 c4 10             	add    $0x10,%esp
  801186:	85 c0                	test   %eax,%eax
  801188:	79 14                	jns    80119e <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  80118a:	83 ec 04             	sub    $0x4,%esp
  80118d:	68 5c 18 80 00       	push   $0x80185c
  801192:	6a 21                	push   $0x21
  801194:	68 c0 18 80 00       	push   $0x8018c0
  801199:	e8 7f ff ff ff       	call   80111d <_panic>
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80119e:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a1:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8011a6:	83 ec 08             	sub    $0x8,%esp
  8011a9:	68 d2 11 80 00       	push   $0x8011d2
  8011ae:	6a 00                	push   $0x0
  8011b0:	e8 c2 fa ff ff       	call   800c77 <sys_env_set_pgfault_upcall>
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	85 c0                	test   %eax,%eax
  8011ba:	79 14                	jns    8011d0 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8011bc:	83 ec 04             	sub    $0x4,%esp
  8011bf:	68 88 18 80 00       	push   $0x801888
  8011c4:	6a 26                	push   $0x26
  8011c6:	68 c0 18 80 00       	push   $0x8018c0
  8011cb:	e8 4d ff ff ff       	call   80111d <_panic>
}
  8011d0:	c9                   	leave  
  8011d1:	c3                   	ret    

008011d2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011d2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011d3:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  8011d8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011da:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx #trap-time eip
  8011dd:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)
  8011e1:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax #trap-time esp-4
  8011e6:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)
  8011ea:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp
  8011ec:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8011ef:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp #eip
  8011f0:	83 c4 04             	add    $0x4,%esp
	popfl
  8011f3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8011f4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8011f5:	c3                   	ret    
  8011f6:	66 90                	xchg   %ax,%ax
  8011f8:	66 90                	xchg   %ax,%ax
  8011fa:	66 90                	xchg   %ax,%ax
  8011fc:	66 90                	xchg   %ax,%ax
  8011fe:	66 90                	xchg   %ax,%ax

00801200 <__udivdi3>:
  801200:	55                   	push   %ebp
  801201:	57                   	push   %edi
  801202:	56                   	push   %esi
  801203:	53                   	push   %ebx
  801204:	83 ec 1c             	sub    $0x1c,%esp
  801207:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80120b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80120f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801217:	85 f6                	test   %esi,%esi
  801219:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80121d:	89 ca                	mov    %ecx,%edx
  80121f:	89 f8                	mov    %edi,%eax
  801221:	75 3d                	jne    801260 <__udivdi3+0x60>
  801223:	39 cf                	cmp    %ecx,%edi
  801225:	0f 87 c5 00 00 00    	ja     8012f0 <__udivdi3+0xf0>
  80122b:	85 ff                	test   %edi,%edi
  80122d:	89 fd                	mov    %edi,%ebp
  80122f:	75 0b                	jne    80123c <__udivdi3+0x3c>
  801231:	b8 01 00 00 00       	mov    $0x1,%eax
  801236:	31 d2                	xor    %edx,%edx
  801238:	f7 f7                	div    %edi
  80123a:	89 c5                	mov    %eax,%ebp
  80123c:	89 c8                	mov    %ecx,%eax
  80123e:	31 d2                	xor    %edx,%edx
  801240:	f7 f5                	div    %ebp
  801242:	89 c1                	mov    %eax,%ecx
  801244:	89 d8                	mov    %ebx,%eax
  801246:	89 cf                	mov    %ecx,%edi
  801248:	f7 f5                	div    %ebp
  80124a:	89 c3                	mov    %eax,%ebx
  80124c:	89 d8                	mov    %ebx,%eax
  80124e:	89 fa                	mov    %edi,%edx
  801250:	83 c4 1c             	add    $0x1c,%esp
  801253:	5b                   	pop    %ebx
  801254:	5e                   	pop    %esi
  801255:	5f                   	pop    %edi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    
  801258:	90                   	nop
  801259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801260:	39 ce                	cmp    %ecx,%esi
  801262:	77 74                	ja     8012d8 <__udivdi3+0xd8>
  801264:	0f bd fe             	bsr    %esi,%edi
  801267:	83 f7 1f             	xor    $0x1f,%edi
  80126a:	0f 84 98 00 00 00    	je     801308 <__udivdi3+0x108>
  801270:	bb 20 00 00 00       	mov    $0x20,%ebx
  801275:	89 f9                	mov    %edi,%ecx
  801277:	89 c5                	mov    %eax,%ebp
  801279:	29 fb                	sub    %edi,%ebx
  80127b:	d3 e6                	shl    %cl,%esi
  80127d:	89 d9                	mov    %ebx,%ecx
  80127f:	d3 ed                	shr    %cl,%ebp
  801281:	89 f9                	mov    %edi,%ecx
  801283:	d3 e0                	shl    %cl,%eax
  801285:	09 ee                	or     %ebp,%esi
  801287:	89 d9                	mov    %ebx,%ecx
  801289:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80128d:	89 d5                	mov    %edx,%ebp
  80128f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801293:	d3 ed                	shr    %cl,%ebp
  801295:	89 f9                	mov    %edi,%ecx
  801297:	d3 e2                	shl    %cl,%edx
  801299:	89 d9                	mov    %ebx,%ecx
  80129b:	d3 e8                	shr    %cl,%eax
  80129d:	09 c2                	or     %eax,%edx
  80129f:	89 d0                	mov    %edx,%eax
  8012a1:	89 ea                	mov    %ebp,%edx
  8012a3:	f7 f6                	div    %esi
  8012a5:	89 d5                	mov    %edx,%ebp
  8012a7:	89 c3                	mov    %eax,%ebx
  8012a9:	f7 64 24 0c          	mull   0xc(%esp)
  8012ad:	39 d5                	cmp    %edx,%ebp
  8012af:	72 10                	jb     8012c1 <__udivdi3+0xc1>
  8012b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012b5:	89 f9                	mov    %edi,%ecx
  8012b7:	d3 e6                	shl    %cl,%esi
  8012b9:	39 c6                	cmp    %eax,%esi
  8012bb:	73 07                	jae    8012c4 <__udivdi3+0xc4>
  8012bd:	39 d5                	cmp    %edx,%ebp
  8012bf:	75 03                	jne    8012c4 <__udivdi3+0xc4>
  8012c1:	83 eb 01             	sub    $0x1,%ebx
  8012c4:	31 ff                	xor    %edi,%edi
  8012c6:	89 d8                	mov    %ebx,%eax
  8012c8:	89 fa                	mov    %edi,%edx
  8012ca:	83 c4 1c             	add    $0x1c,%esp
  8012cd:	5b                   	pop    %ebx
  8012ce:	5e                   	pop    %esi
  8012cf:	5f                   	pop    %edi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    
  8012d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012d8:	31 ff                	xor    %edi,%edi
  8012da:	31 db                	xor    %ebx,%ebx
  8012dc:	89 d8                	mov    %ebx,%eax
  8012de:	89 fa                	mov    %edi,%edx
  8012e0:	83 c4 1c             	add    $0x1c,%esp
  8012e3:	5b                   	pop    %ebx
  8012e4:	5e                   	pop    %esi
  8012e5:	5f                   	pop    %edi
  8012e6:	5d                   	pop    %ebp
  8012e7:	c3                   	ret    
  8012e8:	90                   	nop
  8012e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012f0:	89 d8                	mov    %ebx,%eax
  8012f2:	f7 f7                	div    %edi
  8012f4:	31 ff                	xor    %edi,%edi
  8012f6:	89 c3                	mov    %eax,%ebx
  8012f8:	89 d8                	mov    %ebx,%eax
  8012fa:	89 fa                	mov    %edi,%edx
  8012fc:	83 c4 1c             	add    $0x1c,%esp
  8012ff:	5b                   	pop    %ebx
  801300:	5e                   	pop    %esi
  801301:	5f                   	pop    %edi
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    
  801304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801308:	39 ce                	cmp    %ecx,%esi
  80130a:	72 0c                	jb     801318 <__udivdi3+0x118>
  80130c:	31 db                	xor    %ebx,%ebx
  80130e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801312:	0f 87 34 ff ff ff    	ja     80124c <__udivdi3+0x4c>
  801318:	bb 01 00 00 00       	mov    $0x1,%ebx
  80131d:	e9 2a ff ff ff       	jmp    80124c <__udivdi3+0x4c>
  801322:	66 90                	xchg   %ax,%ax
  801324:	66 90                	xchg   %ax,%ax
  801326:	66 90                	xchg   %ax,%ax
  801328:	66 90                	xchg   %ax,%ax
  80132a:	66 90                	xchg   %ax,%ax
  80132c:	66 90                	xchg   %ax,%ax
  80132e:	66 90                	xchg   %ax,%ax

00801330 <__umoddi3>:
  801330:	55                   	push   %ebp
  801331:	57                   	push   %edi
  801332:	56                   	push   %esi
  801333:	53                   	push   %ebx
  801334:	83 ec 1c             	sub    $0x1c,%esp
  801337:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80133b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80133f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801343:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801347:	85 d2                	test   %edx,%edx
  801349:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80134d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801351:	89 f3                	mov    %esi,%ebx
  801353:	89 3c 24             	mov    %edi,(%esp)
  801356:	89 74 24 04          	mov    %esi,0x4(%esp)
  80135a:	75 1c                	jne    801378 <__umoddi3+0x48>
  80135c:	39 f7                	cmp    %esi,%edi
  80135e:	76 50                	jbe    8013b0 <__umoddi3+0x80>
  801360:	89 c8                	mov    %ecx,%eax
  801362:	89 f2                	mov    %esi,%edx
  801364:	f7 f7                	div    %edi
  801366:	89 d0                	mov    %edx,%eax
  801368:	31 d2                	xor    %edx,%edx
  80136a:	83 c4 1c             	add    $0x1c,%esp
  80136d:	5b                   	pop    %ebx
  80136e:	5e                   	pop    %esi
  80136f:	5f                   	pop    %edi
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    
  801372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801378:	39 f2                	cmp    %esi,%edx
  80137a:	89 d0                	mov    %edx,%eax
  80137c:	77 52                	ja     8013d0 <__umoddi3+0xa0>
  80137e:	0f bd ea             	bsr    %edx,%ebp
  801381:	83 f5 1f             	xor    $0x1f,%ebp
  801384:	75 5a                	jne    8013e0 <__umoddi3+0xb0>
  801386:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80138a:	0f 82 e0 00 00 00    	jb     801470 <__umoddi3+0x140>
  801390:	39 0c 24             	cmp    %ecx,(%esp)
  801393:	0f 86 d7 00 00 00    	jbe    801470 <__umoddi3+0x140>
  801399:	8b 44 24 08          	mov    0x8(%esp),%eax
  80139d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013a1:	83 c4 1c             	add    $0x1c,%esp
  8013a4:	5b                   	pop    %ebx
  8013a5:	5e                   	pop    %esi
  8013a6:	5f                   	pop    %edi
  8013a7:	5d                   	pop    %ebp
  8013a8:	c3                   	ret    
  8013a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013b0:	85 ff                	test   %edi,%edi
  8013b2:	89 fd                	mov    %edi,%ebp
  8013b4:	75 0b                	jne    8013c1 <__umoddi3+0x91>
  8013b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013bb:	31 d2                	xor    %edx,%edx
  8013bd:	f7 f7                	div    %edi
  8013bf:	89 c5                	mov    %eax,%ebp
  8013c1:	89 f0                	mov    %esi,%eax
  8013c3:	31 d2                	xor    %edx,%edx
  8013c5:	f7 f5                	div    %ebp
  8013c7:	89 c8                	mov    %ecx,%eax
  8013c9:	f7 f5                	div    %ebp
  8013cb:	89 d0                	mov    %edx,%eax
  8013cd:	eb 99                	jmp    801368 <__umoddi3+0x38>
  8013cf:	90                   	nop
  8013d0:	89 c8                	mov    %ecx,%eax
  8013d2:	89 f2                	mov    %esi,%edx
  8013d4:	83 c4 1c             	add    $0x1c,%esp
  8013d7:	5b                   	pop    %ebx
  8013d8:	5e                   	pop    %esi
  8013d9:	5f                   	pop    %edi
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    
  8013dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013e0:	8b 34 24             	mov    (%esp),%esi
  8013e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8013e8:	89 e9                	mov    %ebp,%ecx
  8013ea:	29 ef                	sub    %ebp,%edi
  8013ec:	d3 e0                	shl    %cl,%eax
  8013ee:	89 f9                	mov    %edi,%ecx
  8013f0:	89 f2                	mov    %esi,%edx
  8013f2:	d3 ea                	shr    %cl,%edx
  8013f4:	89 e9                	mov    %ebp,%ecx
  8013f6:	09 c2                	or     %eax,%edx
  8013f8:	89 d8                	mov    %ebx,%eax
  8013fa:	89 14 24             	mov    %edx,(%esp)
  8013fd:	89 f2                	mov    %esi,%edx
  8013ff:	d3 e2                	shl    %cl,%edx
  801401:	89 f9                	mov    %edi,%ecx
  801403:	89 54 24 04          	mov    %edx,0x4(%esp)
  801407:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80140b:	d3 e8                	shr    %cl,%eax
  80140d:	89 e9                	mov    %ebp,%ecx
  80140f:	89 c6                	mov    %eax,%esi
  801411:	d3 e3                	shl    %cl,%ebx
  801413:	89 f9                	mov    %edi,%ecx
  801415:	89 d0                	mov    %edx,%eax
  801417:	d3 e8                	shr    %cl,%eax
  801419:	89 e9                	mov    %ebp,%ecx
  80141b:	09 d8                	or     %ebx,%eax
  80141d:	89 d3                	mov    %edx,%ebx
  80141f:	89 f2                	mov    %esi,%edx
  801421:	f7 34 24             	divl   (%esp)
  801424:	89 d6                	mov    %edx,%esi
  801426:	d3 e3                	shl    %cl,%ebx
  801428:	f7 64 24 04          	mull   0x4(%esp)
  80142c:	39 d6                	cmp    %edx,%esi
  80142e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801432:	89 d1                	mov    %edx,%ecx
  801434:	89 c3                	mov    %eax,%ebx
  801436:	72 08                	jb     801440 <__umoddi3+0x110>
  801438:	75 11                	jne    80144b <__umoddi3+0x11b>
  80143a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80143e:	73 0b                	jae    80144b <__umoddi3+0x11b>
  801440:	2b 44 24 04          	sub    0x4(%esp),%eax
  801444:	1b 14 24             	sbb    (%esp),%edx
  801447:	89 d1                	mov    %edx,%ecx
  801449:	89 c3                	mov    %eax,%ebx
  80144b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80144f:	29 da                	sub    %ebx,%edx
  801451:	19 ce                	sbb    %ecx,%esi
  801453:	89 f9                	mov    %edi,%ecx
  801455:	89 f0                	mov    %esi,%eax
  801457:	d3 e0                	shl    %cl,%eax
  801459:	89 e9                	mov    %ebp,%ecx
  80145b:	d3 ea                	shr    %cl,%edx
  80145d:	89 e9                	mov    %ebp,%ecx
  80145f:	d3 ee                	shr    %cl,%esi
  801461:	09 d0                	or     %edx,%eax
  801463:	89 f2                	mov    %esi,%edx
  801465:	83 c4 1c             	add    $0x1c,%esp
  801468:	5b                   	pop    %ebx
  801469:	5e                   	pop    %esi
  80146a:	5f                   	pop    %edi
  80146b:	5d                   	pop    %ebp
  80146c:	c3                   	ret    
  80146d:	8d 76 00             	lea    0x0(%esi),%esi
  801470:	29 f9                	sub    %edi,%ecx
  801472:	19 d6                	sbb    %edx,%esi
  801474:	89 74 24 04          	mov    %esi,0x4(%esp)
  801478:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80147c:	e9 18 ff ff ff       	jmp    801399 <__umoddi3+0x69>
