
obj/user/forktree：     文件格式 elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 1a 0b 00 00       	call   800b5c <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 c0 14 80 00       	push   $0x8014c0
  80004c:	e8 7b 01 00 00       	call   8001cc <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 db 06 00 00       	call   80075e <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 d1 14 80 00       	push   $0x8014d1
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 9f 06 00 00       	call   800744 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 51 0e 00 00       	call   800efe <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 65 00 00 00       	call   800127 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 d0 14 80 00       	push   $0x8014d0
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  8000ec:	e8 6b 0a 00 00       	call   800b5c <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	c1 e0 07             	shl    $0x7,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x2d>
		binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	e8 b4 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800118:	e8 0a 00 00 00       	call   800127 <exit>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80012d:	6a 00                	push   $0x0
  80012f:	e8 e7 09 00 00       	call   800b1b <sys_env_destroy>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	53                   	push   %ebx
  80013d:	83 ec 04             	sub    $0x4,%esp
  800140:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800143:	8b 13                	mov    (%ebx),%edx
  800145:	8d 42 01             	lea    0x1(%edx),%eax
  800148:	89 03                	mov    %eax,(%ebx)
  80014a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800151:	3d ff 00 00 00       	cmp    $0xff,%eax
  800156:	75 1a                	jne    800172 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800158:	83 ec 08             	sub    $0x8,%esp
  80015b:	68 ff 00 00 00       	push   $0xff
  800160:	8d 43 08             	lea    0x8(%ebx),%eax
  800163:	50                   	push   %eax
  800164:	e8 75 09 00 00       	call   800ade <sys_cputs>
		b->idx = 0;
  800169:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80016f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800172:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800179:	c9                   	leave  
  80017a:	c3                   	ret    

0080017b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800184:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018b:	00 00 00 
	b.cnt = 0;
  80018e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800195:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800198:	ff 75 0c             	pushl  0xc(%ebp)
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a4:	50                   	push   %eax
  8001a5:	68 39 01 80 00       	push   $0x800139
  8001aa:	e8 54 01 00 00       	call   800303 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001af:	83 c4 08             	add    $0x8,%esp
  8001b2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001be:	50                   	push   %eax
  8001bf:	e8 1a 09 00 00       	call   800ade <sys_cputs>

	return b.cnt;
}
  8001c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d5:	50                   	push   %eax
  8001d6:	ff 75 08             	pushl  0x8(%ebp)
  8001d9:	e8 9d ff ff ff       	call   80017b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 1c             	sub    $0x1c,%esp
  8001e9:	89 c7                	mov    %eax,%edi
  8001eb:	89 d6                	mov    %edx,%esi
  8001ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800201:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800204:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800207:	39 d3                	cmp    %edx,%ebx
  800209:	72 05                	jb     800210 <printnum+0x30>
  80020b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80020e:	77 45                	ja     800255 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	8b 45 14             	mov    0x14(%ebp),%eax
  800219:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80021c:	53                   	push   %ebx
  80021d:	ff 75 10             	pushl  0x10(%ebp)
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	ff 75 e4             	pushl  -0x1c(%ebp)
  800226:	ff 75 e0             	pushl  -0x20(%ebp)
  800229:	ff 75 dc             	pushl  -0x24(%ebp)
  80022c:	ff 75 d8             	pushl  -0x28(%ebp)
  80022f:	e8 fc 0f 00 00       	call   801230 <__udivdi3>
  800234:	83 c4 18             	add    $0x18,%esp
  800237:	52                   	push   %edx
  800238:	50                   	push   %eax
  800239:	89 f2                	mov    %esi,%edx
  80023b:	89 f8                	mov    %edi,%eax
  80023d:	e8 9e ff ff ff       	call   8001e0 <printnum>
  800242:	83 c4 20             	add    $0x20,%esp
  800245:	eb 18                	jmp    80025f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	ff 75 18             	pushl  0x18(%ebp)
  80024e:	ff d7                	call   *%edi
  800250:	83 c4 10             	add    $0x10,%esp
  800253:	eb 03                	jmp    800258 <printnum+0x78>
  800255:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800258:	83 eb 01             	sub    $0x1,%ebx
  80025b:	85 db                	test   %ebx,%ebx
  80025d:	7f e8                	jg     800247 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025f:	83 ec 08             	sub    $0x8,%esp
  800262:	56                   	push   %esi
  800263:	83 ec 04             	sub    $0x4,%esp
  800266:	ff 75 e4             	pushl  -0x1c(%ebp)
  800269:	ff 75 e0             	pushl  -0x20(%ebp)
  80026c:	ff 75 dc             	pushl  -0x24(%ebp)
  80026f:	ff 75 d8             	pushl  -0x28(%ebp)
  800272:	e8 e9 10 00 00       	call   801360 <__umoddi3>
  800277:	83 c4 14             	add    $0x14,%esp
  80027a:	0f be 80 e0 14 80 00 	movsbl 0x8014e0(%eax),%eax
  800281:	50                   	push   %eax
  800282:	ff d7                	call   *%edi
}
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028a:	5b                   	pop    %ebx
  80028b:	5e                   	pop    %esi
  80028c:	5f                   	pop    %edi
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800292:	83 fa 01             	cmp    $0x1,%edx
  800295:	7e 0e                	jle    8002a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800297:	8b 10                	mov    (%eax),%edx
  800299:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029c:	89 08                	mov    %ecx,(%eax)
  80029e:	8b 02                	mov    (%edx),%eax
  8002a0:	8b 52 04             	mov    0x4(%edx),%edx
  8002a3:	eb 22                	jmp    8002c7 <getuint+0x38>
	else if (lflag)
  8002a5:	85 d2                	test   %edx,%edx
  8002a7:	74 10                	je     8002b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a9:	8b 10                	mov    (%eax),%edx
  8002ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ae:	89 08                	mov    %ecx,(%eax)
  8002b0:	8b 02                	mov    (%edx),%eax
  8002b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b7:	eb 0e                	jmp    8002c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d8:	73 0a                	jae    8002e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	88 02                	mov    %al,(%edx)
}
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ef:	50                   	push   %eax
  8002f0:	ff 75 10             	pushl  0x10(%ebp)
  8002f3:	ff 75 0c             	pushl  0xc(%ebp)
  8002f6:	ff 75 08             	pushl  0x8(%ebp)
  8002f9:	e8 05 00 00 00       	call   800303 <vprintfmt>
	va_end(ap);
}
  8002fe:	83 c4 10             	add    $0x10,%esp
  800301:	c9                   	leave  
  800302:	c3                   	ret    

00800303 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	57                   	push   %edi
  800307:	56                   	push   %esi
  800308:	53                   	push   %ebx
  800309:	83 ec 2c             	sub    $0x2c,%esp
  80030c:	8b 75 08             	mov    0x8(%ebp),%esi
  80030f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800312:	8b 7d 10             	mov    0x10(%ebp),%edi
  800315:	eb 1d                	jmp    800334 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800317:	85 c0                	test   %eax,%eax
  800319:	75 0f                	jne    80032a <vprintfmt+0x27>
				csa = 0x0700;
  80031b:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  800322:	07 00 00 
				return;
  800325:	e9 c4 03 00 00       	jmp    8006ee <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  80032a:	83 ec 08             	sub    $0x8,%esp
  80032d:	53                   	push   %ebx
  80032e:	50                   	push   %eax
  80032f:	ff d6                	call   *%esi
  800331:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800334:	83 c7 01             	add    $0x1,%edi
  800337:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80033b:	83 f8 25             	cmp    $0x25,%eax
  80033e:	75 d7                	jne    800317 <vprintfmt+0x14>
  800340:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800344:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80034b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800352:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
  80035e:	eb 07                	jmp    800367 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800360:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800363:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8d 47 01             	lea    0x1(%edi),%eax
  80036a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036d:	0f b6 07             	movzbl (%edi),%eax
  800370:	0f b6 c8             	movzbl %al,%ecx
  800373:	83 e8 23             	sub    $0x23,%eax
  800376:	3c 55                	cmp    $0x55,%al
  800378:	0f 87 55 03 00 00    	ja     8006d3 <vprintfmt+0x3d0>
  80037e:	0f b6 c0             	movzbl %al,%eax
  800381:	ff 24 85 a0 15 80 00 	jmp    *0x8015a0(,%eax,4)
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80038f:	eb d6                	jmp    800367 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800394:	b8 00 00 00 00       	mov    $0x0,%eax
  800399:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80039c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003a3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003a6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003a9:	83 fa 09             	cmp    $0x9,%edx
  8003ac:	77 39                	ja     8003e7 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ae:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b1:	eb e9                	jmp    80039c <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003bc:	8b 00                	mov    (%eax),%eax
  8003be:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c4:	eb 27                	jmp    8003ed <vprintfmt+0xea>
  8003c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c9:	85 c0                	test   %eax,%eax
  8003cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d0:	0f 49 c8             	cmovns %eax,%ecx
  8003d3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d9:	eb 8c                	jmp    800367 <vprintfmt+0x64>
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003de:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e5:	eb 80                	jmp    800367 <vprintfmt+0x64>
  8003e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003ea:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ed:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f1:	0f 89 70 ff ff ff    	jns    800367 <vprintfmt+0x64>
				width = precision, precision = -1;
  8003f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800404:	e9 5e ff ff ff       	jmp    800367 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800409:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040f:	e9 53 ff ff ff       	jmp    800367 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	53                   	push   %ebx
  800421:	ff 30                	pushl  (%eax)
  800423:	ff d6                	call   *%esi
			break;
  800425:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80042b:	e9 04 ff ff ff       	jmp    800334 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 50 04             	lea    0x4(%eax),%edx
  800436:	89 55 14             	mov    %edx,0x14(%ebp)
  800439:	8b 00                	mov    (%eax),%eax
  80043b:	99                   	cltd   
  80043c:	31 d0                	xor    %edx,%eax
  80043e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800440:	83 f8 08             	cmp    $0x8,%eax
  800443:	7f 0b                	jg     800450 <vprintfmt+0x14d>
  800445:	8b 14 85 00 17 80 00 	mov    0x801700(,%eax,4),%edx
  80044c:	85 d2                	test   %edx,%edx
  80044e:	75 18                	jne    800468 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  800450:	50                   	push   %eax
  800451:	68 f8 14 80 00       	push   $0x8014f8
  800456:	53                   	push   %ebx
  800457:	56                   	push   %esi
  800458:	e8 89 fe ff ff       	call   8002e6 <printfmt>
  80045d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800463:	e9 cc fe ff ff       	jmp    800334 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  800468:	52                   	push   %edx
  800469:	68 01 15 80 00       	push   $0x801501
  80046e:	53                   	push   %ebx
  80046f:	56                   	push   %esi
  800470:	e8 71 fe ff ff       	call   8002e6 <printfmt>
  800475:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047b:	e9 b4 fe ff ff       	jmp    800334 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 50 04             	lea    0x4(%eax),%edx
  800486:	89 55 14             	mov    %edx,0x14(%ebp)
  800489:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80048b:	85 ff                	test   %edi,%edi
  80048d:	b8 f1 14 80 00       	mov    $0x8014f1,%eax
  800492:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800495:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800499:	0f 8e 94 00 00 00    	jle    800533 <vprintfmt+0x230>
  80049f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a3:	0f 84 98 00 00 00    	je     800541 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	ff 75 d0             	pushl  -0x30(%ebp)
  8004af:	57                   	push   %edi
  8004b0:	e8 c1 02 00 00       	call   800776 <strnlen>
  8004b5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b8:	29 c1                	sub    %eax,%ecx
  8004ba:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004bd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ca:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cc:	eb 0f                	jmp    8004dd <vprintfmt+0x1da>
					putch(padc, putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	53                   	push   %ebx
  8004d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	83 ef 01             	sub    $0x1,%edi
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 ff                	test   %edi,%edi
  8004df:	7f ed                	jg     8004ce <vprintfmt+0x1cb>
  8004e1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e7:	85 c9                	test   %ecx,%ecx
  8004e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ee:	0f 49 c1             	cmovns %ecx,%eax
  8004f1:	29 c1                	sub    %eax,%ecx
  8004f3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fc:	89 cb                	mov    %ecx,%ebx
  8004fe:	eb 4d                	jmp    80054d <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800500:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800504:	74 1b                	je     800521 <vprintfmt+0x21e>
  800506:	0f be c0             	movsbl %al,%eax
  800509:	83 e8 20             	sub    $0x20,%eax
  80050c:	83 f8 5e             	cmp    $0x5e,%eax
  80050f:	76 10                	jbe    800521 <vprintfmt+0x21e>
					putch('?', putdat);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	ff 75 0c             	pushl  0xc(%ebp)
  800517:	6a 3f                	push   $0x3f
  800519:	ff 55 08             	call   *0x8(%ebp)
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	eb 0d                	jmp    80052e <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800521:	83 ec 08             	sub    $0x8,%esp
  800524:	ff 75 0c             	pushl  0xc(%ebp)
  800527:	52                   	push   %edx
  800528:	ff 55 08             	call   *0x8(%ebp)
  80052b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052e:	83 eb 01             	sub    $0x1,%ebx
  800531:	eb 1a                	jmp    80054d <vprintfmt+0x24a>
  800533:	89 75 08             	mov    %esi,0x8(%ebp)
  800536:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800539:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053f:	eb 0c                	jmp    80054d <vprintfmt+0x24a>
  800541:	89 75 08             	mov    %esi,0x8(%ebp)
  800544:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800547:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054d:	83 c7 01             	add    $0x1,%edi
  800550:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800554:	0f be d0             	movsbl %al,%edx
  800557:	85 d2                	test   %edx,%edx
  800559:	74 23                	je     80057e <vprintfmt+0x27b>
  80055b:	85 f6                	test   %esi,%esi
  80055d:	78 a1                	js     800500 <vprintfmt+0x1fd>
  80055f:	83 ee 01             	sub    $0x1,%esi
  800562:	79 9c                	jns    800500 <vprintfmt+0x1fd>
  800564:	89 df                	mov    %ebx,%edi
  800566:	8b 75 08             	mov    0x8(%ebp),%esi
  800569:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056c:	eb 18                	jmp    800586 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	53                   	push   %ebx
  800572:	6a 20                	push   $0x20
  800574:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800576:	83 ef 01             	sub    $0x1,%edi
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	eb 08                	jmp    800586 <vprintfmt+0x283>
  80057e:	89 df                	mov    %ebx,%edi
  800580:	8b 75 08             	mov    0x8(%ebp),%esi
  800583:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800586:	85 ff                	test   %edi,%edi
  800588:	7f e4                	jg     80056e <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058d:	e9 a2 fd ff ff       	jmp    800334 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800592:	83 fa 01             	cmp    $0x1,%edx
  800595:	7e 16                	jle    8005ad <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 50 08             	lea    0x8(%eax),%edx
  80059d:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a0:	8b 50 04             	mov    0x4(%eax),%edx
  8005a3:	8b 00                	mov    (%eax),%eax
  8005a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ab:	eb 32                	jmp    8005df <vprintfmt+0x2dc>
	else if (lflag)
  8005ad:	85 d2                	test   %edx,%edx
  8005af:	74 18                	je     8005c9 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 04             	lea    0x4(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bf:	89 c1                	mov    %eax,%ecx
  8005c1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c7:	eb 16                	jmp    8005df <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8d 50 04             	lea    0x4(%eax),%edx
  8005cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d2:	8b 00                	mov    (%eax),%eax
  8005d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d7:	89 c1                	mov    %eax,%ecx
  8005d9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005dc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005df:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ea:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ee:	79 74                	jns    800664 <vprintfmt+0x361>
				putch('-', putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	53                   	push   %ebx
  8005f4:	6a 2d                	push   $0x2d
  8005f6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005fe:	f7 d8                	neg    %eax
  800600:	83 d2 00             	adc    $0x0,%edx
  800603:	f7 da                	neg    %edx
  800605:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800608:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80060d:	eb 55                	jmp    800664 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80060f:	8d 45 14             	lea    0x14(%ebp),%eax
  800612:	e8 78 fc ff ff       	call   80028f <getuint>
			base = 10;
  800617:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80061c:	eb 46                	jmp    800664 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  80061e:	8d 45 14             	lea    0x14(%ebp),%eax
  800621:	e8 69 fc ff ff       	call   80028f <getuint>
      base = 8;
  800626:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80062b:	eb 37                	jmp    800664 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 30                	push   $0x30
  800633:	ff d6                	call   *%esi
			putch('x', putdat);
  800635:	83 c4 08             	add    $0x8,%esp
  800638:	53                   	push   %ebx
  800639:	6a 78                	push   $0x78
  80063b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 50 04             	lea    0x4(%eax),%edx
  800643:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800646:	8b 00                	mov    (%eax),%eax
  800648:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80064d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800650:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800655:	eb 0d                	jmp    800664 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800657:	8d 45 14             	lea    0x14(%ebp),%eax
  80065a:	e8 30 fc ff ff       	call   80028f <getuint>
			base = 16;
  80065f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800664:	83 ec 0c             	sub    $0xc,%esp
  800667:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80066b:	57                   	push   %edi
  80066c:	ff 75 e0             	pushl  -0x20(%ebp)
  80066f:	51                   	push   %ecx
  800670:	52                   	push   %edx
  800671:	50                   	push   %eax
  800672:	89 da                	mov    %ebx,%edx
  800674:	89 f0                	mov    %esi,%eax
  800676:	e8 65 fb ff ff       	call   8001e0 <printnum>
			break;
  80067b:	83 c4 20             	add    $0x20,%esp
  80067e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800681:	e9 ae fc ff ff       	jmp    800334 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	51                   	push   %ecx
  80068b:	ff d6                	call   *%esi
			break;
  80068d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800690:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800693:	e9 9c fc ff ff       	jmp    800334 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800698:	83 fa 01             	cmp    $0x1,%edx
  80069b:	7e 0d                	jle    8006aa <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8d 50 08             	lea    0x8(%eax),%edx
  8006a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a6:	8b 00                	mov    (%eax),%eax
  8006a8:	eb 1c                	jmp    8006c6 <vprintfmt+0x3c3>
	else if (lflag)
  8006aa:	85 d2                	test   %edx,%edx
  8006ac:	74 0d                	je     8006bb <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8d 50 04             	lea    0x4(%eax),%edx
  8006b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b7:	8b 00                	mov    (%eax),%eax
  8006b9:	eb 0b                	jmp    8006c6 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8d 50 04             	lea    0x4(%eax),%edx
  8006c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c4:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  8006c6:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  8006ce:	e9 61 fc ff ff       	jmp    800334 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	53                   	push   %ebx
  8006d7:	6a 25                	push   $0x25
  8006d9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006db:	83 c4 10             	add    $0x10,%esp
  8006de:	eb 03                	jmp    8006e3 <vprintfmt+0x3e0>
  8006e0:	83 ef 01             	sub    $0x1,%edi
  8006e3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e7:	75 f7                	jne    8006e0 <vprintfmt+0x3dd>
  8006e9:	e9 46 fc ff ff       	jmp    800334 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  8006ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f1:	5b                   	pop    %ebx
  8006f2:	5e                   	pop    %esi
  8006f3:	5f                   	pop    %edi
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	83 ec 18             	sub    $0x18,%esp
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800702:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800705:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800709:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800713:	85 c0                	test   %eax,%eax
  800715:	74 26                	je     80073d <vsnprintf+0x47>
  800717:	85 d2                	test   %edx,%edx
  800719:	7e 22                	jle    80073d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071b:	ff 75 14             	pushl  0x14(%ebp)
  80071e:	ff 75 10             	pushl  0x10(%ebp)
  800721:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800724:	50                   	push   %eax
  800725:	68 c9 02 80 00       	push   $0x8002c9
  80072a:	e8 d4 fb ff ff       	call   800303 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800732:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800735:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	eb 05                	jmp    800742 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074d:	50                   	push   %eax
  80074e:	ff 75 10             	pushl  0x10(%ebp)
  800751:	ff 75 0c             	pushl  0xc(%ebp)
  800754:	ff 75 08             	pushl  0x8(%ebp)
  800757:	e8 9a ff ff ff       	call   8006f6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    

0080075e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800764:	b8 00 00 00 00       	mov    $0x0,%eax
  800769:	eb 03                	jmp    80076e <strlen+0x10>
		n++;
  80076b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800772:	75 f7                	jne    80076b <strlen+0xd>
		n++;
	return n;
}
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077f:	ba 00 00 00 00       	mov    $0x0,%edx
  800784:	eb 03                	jmp    800789 <strnlen+0x13>
		n++;
  800786:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800789:	39 c2                	cmp    %eax,%edx
  80078b:	74 08                	je     800795 <strnlen+0x1f>
  80078d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800791:	75 f3                	jne    800786 <strnlen+0x10>
  800793:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a1:	89 c2                	mov    %eax,%edx
  8007a3:	83 c2 01             	add    $0x1,%edx
  8007a6:	83 c1 01             	add    $0x1,%ecx
  8007a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b0:	84 db                	test   %bl,%bl
  8007b2:	75 ef                	jne    8007a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b4:	5b                   	pop    %ebx
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007be:	53                   	push   %ebx
  8007bf:	e8 9a ff ff ff       	call   80075e <strlen>
  8007c4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ca:	01 d8                	add    %ebx,%eax
  8007cc:	50                   	push   %eax
  8007cd:	e8 c5 ff ff ff       	call   800797 <strcpy>
	return dst;
}
  8007d2:	89 d8                	mov    %ebx,%eax
  8007d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	56                   	push   %esi
  8007dd:	53                   	push   %ebx
  8007de:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e4:	89 f3                	mov    %esi,%ebx
  8007e6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e9:	89 f2                	mov    %esi,%edx
  8007eb:	eb 0f                	jmp    8007fc <strncpy+0x23>
		*dst++ = *src;
  8007ed:	83 c2 01             	add    $0x1,%edx
  8007f0:	0f b6 01             	movzbl (%ecx),%eax
  8007f3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f6:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fc:	39 da                	cmp    %ebx,%edx
  8007fe:	75 ed                	jne    8007ed <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800800:	89 f0                	mov    %esi,%eax
  800802:	5b                   	pop    %ebx
  800803:	5e                   	pop    %esi
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	56                   	push   %esi
  80080a:	53                   	push   %ebx
  80080b:	8b 75 08             	mov    0x8(%ebp),%esi
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800811:	8b 55 10             	mov    0x10(%ebp),%edx
  800814:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800816:	85 d2                	test   %edx,%edx
  800818:	74 21                	je     80083b <strlcpy+0x35>
  80081a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081e:	89 f2                	mov    %esi,%edx
  800820:	eb 09                	jmp    80082b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800822:	83 c2 01             	add    $0x1,%edx
  800825:	83 c1 01             	add    $0x1,%ecx
  800828:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082b:	39 c2                	cmp    %eax,%edx
  80082d:	74 09                	je     800838 <strlcpy+0x32>
  80082f:	0f b6 19             	movzbl (%ecx),%ebx
  800832:	84 db                	test   %bl,%bl
  800834:	75 ec                	jne    800822 <strlcpy+0x1c>
  800836:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800838:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083b:	29 f0                	sub    %esi,%eax
}
  80083d:	5b                   	pop    %ebx
  80083e:	5e                   	pop    %esi
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084a:	eb 06                	jmp    800852 <strcmp+0x11>
		p++, q++;
  80084c:	83 c1 01             	add    $0x1,%ecx
  80084f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800852:	0f b6 01             	movzbl (%ecx),%eax
  800855:	84 c0                	test   %al,%al
  800857:	74 04                	je     80085d <strcmp+0x1c>
  800859:	3a 02                	cmp    (%edx),%al
  80085b:	74 ef                	je     80084c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085d:	0f b6 c0             	movzbl %al,%eax
  800860:	0f b6 12             	movzbl (%edx),%edx
  800863:	29 d0                	sub    %edx,%eax
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	89 c3                	mov    %eax,%ebx
  800873:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800876:	eb 06                	jmp    80087e <strncmp+0x17>
		n--, p++, q++;
  800878:	83 c0 01             	add    $0x1,%eax
  80087b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087e:	39 d8                	cmp    %ebx,%eax
  800880:	74 15                	je     800897 <strncmp+0x30>
  800882:	0f b6 08             	movzbl (%eax),%ecx
  800885:	84 c9                	test   %cl,%cl
  800887:	74 04                	je     80088d <strncmp+0x26>
  800889:	3a 0a                	cmp    (%edx),%cl
  80088b:	74 eb                	je     800878 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088d:	0f b6 00             	movzbl (%eax),%eax
  800890:	0f b6 12             	movzbl (%edx),%edx
  800893:	29 d0                	sub    %edx,%eax
  800895:	eb 05                	jmp    80089c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089c:	5b                   	pop    %ebx
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a9:	eb 07                	jmp    8008b2 <strchr+0x13>
		if (*s == c)
  8008ab:	38 ca                	cmp    %cl,%dl
  8008ad:	74 0f                	je     8008be <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008af:	83 c0 01             	add    $0x1,%eax
  8008b2:	0f b6 10             	movzbl (%eax),%edx
  8008b5:	84 d2                	test   %dl,%dl
  8008b7:	75 f2                	jne    8008ab <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ca:	eb 03                	jmp    8008cf <strfind+0xf>
  8008cc:	83 c0 01             	add    $0x1,%eax
  8008cf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	74 04                	je     8008da <strfind+0x1a>
  8008d6:	84 d2                	test   %dl,%dl
  8008d8:	75 f2                	jne    8008cc <strfind+0xc>
			break;
	return (char *) s;
}
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	57                   	push   %edi
  8008e0:	56                   	push   %esi
  8008e1:	53                   	push   %ebx
  8008e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e8:	85 c9                	test   %ecx,%ecx
  8008ea:	74 36                	je     800922 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ec:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f2:	75 28                	jne    80091c <memset+0x40>
  8008f4:	f6 c1 03             	test   $0x3,%cl
  8008f7:	75 23                	jne    80091c <memset+0x40>
		c &= 0xFF;
  8008f9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fd:	89 d3                	mov    %edx,%ebx
  8008ff:	c1 e3 08             	shl    $0x8,%ebx
  800902:	89 d6                	mov    %edx,%esi
  800904:	c1 e6 18             	shl    $0x18,%esi
  800907:	89 d0                	mov    %edx,%eax
  800909:	c1 e0 10             	shl    $0x10,%eax
  80090c:	09 f0                	or     %esi,%eax
  80090e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800910:	89 d8                	mov    %ebx,%eax
  800912:	09 d0                	or     %edx,%eax
  800914:	c1 e9 02             	shr    $0x2,%ecx
  800917:	fc                   	cld    
  800918:	f3 ab                	rep stos %eax,%es:(%edi)
  80091a:	eb 06                	jmp    800922 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091f:	fc                   	cld    
  800920:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800922:	89 f8                	mov    %edi,%eax
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5f                   	pop    %edi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 75 0c             	mov    0xc(%ebp),%esi
  800934:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800937:	39 c6                	cmp    %eax,%esi
  800939:	73 35                	jae    800970 <memmove+0x47>
  80093b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093e:	39 d0                	cmp    %edx,%eax
  800940:	73 2e                	jae    800970 <memmove+0x47>
		s += n;
		d += n;
  800942:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800945:	89 d6                	mov    %edx,%esi
  800947:	09 fe                	or     %edi,%esi
  800949:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094f:	75 13                	jne    800964 <memmove+0x3b>
  800951:	f6 c1 03             	test   $0x3,%cl
  800954:	75 0e                	jne    800964 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800956:	83 ef 04             	sub    $0x4,%edi
  800959:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095c:	c1 e9 02             	shr    $0x2,%ecx
  80095f:	fd                   	std    
  800960:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800962:	eb 09                	jmp    80096d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800964:	83 ef 01             	sub    $0x1,%edi
  800967:	8d 72 ff             	lea    -0x1(%edx),%esi
  80096a:	fd                   	std    
  80096b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096d:	fc                   	cld    
  80096e:	eb 1d                	jmp    80098d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800970:	89 f2                	mov    %esi,%edx
  800972:	09 c2                	or     %eax,%edx
  800974:	f6 c2 03             	test   $0x3,%dl
  800977:	75 0f                	jne    800988 <memmove+0x5f>
  800979:	f6 c1 03             	test   $0x3,%cl
  80097c:	75 0a                	jne    800988 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80097e:	c1 e9 02             	shr    $0x2,%ecx
  800981:	89 c7                	mov    %eax,%edi
  800983:	fc                   	cld    
  800984:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800986:	eb 05                	jmp    80098d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800988:	89 c7                	mov    %eax,%edi
  80098a:	fc                   	cld    
  80098b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098d:	5e                   	pop    %esi
  80098e:	5f                   	pop    %edi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800994:	ff 75 10             	pushl  0x10(%ebp)
  800997:	ff 75 0c             	pushl  0xc(%ebp)
  80099a:	ff 75 08             	pushl  0x8(%ebp)
  80099d:	e8 87 ff ff ff       	call   800929 <memmove>
}
  8009a2:	c9                   	leave  
  8009a3:	c3                   	ret    

008009a4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009af:	89 c6                	mov    %eax,%esi
  8009b1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b4:	eb 1a                	jmp    8009d0 <memcmp+0x2c>
		if (*s1 != *s2)
  8009b6:	0f b6 08             	movzbl (%eax),%ecx
  8009b9:	0f b6 1a             	movzbl (%edx),%ebx
  8009bc:	38 d9                	cmp    %bl,%cl
  8009be:	74 0a                	je     8009ca <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c0:	0f b6 c1             	movzbl %cl,%eax
  8009c3:	0f b6 db             	movzbl %bl,%ebx
  8009c6:	29 d8                	sub    %ebx,%eax
  8009c8:	eb 0f                	jmp    8009d9 <memcmp+0x35>
		s1++, s2++;
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d0:	39 f0                	cmp    %esi,%eax
  8009d2:	75 e2                	jne    8009b6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d9:	5b                   	pop    %ebx
  8009da:	5e                   	pop    %esi
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	53                   	push   %ebx
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e4:	89 c1                	mov    %eax,%ecx
  8009e6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ed:	eb 0a                	jmp    8009f9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ef:	0f b6 10             	movzbl (%eax),%edx
  8009f2:	39 da                	cmp    %ebx,%edx
  8009f4:	74 07                	je     8009fd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f6:	83 c0 01             	add    $0x1,%eax
  8009f9:	39 c8                	cmp    %ecx,%eax
  8009fb:	72 f2                	jb     8009ef <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fd:	5b                   	pop    %ebx
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0c:	eb 03                	jmp    800a11 <strtol+0x11>
		s++;
  800a0e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a11:	0f b6 01             	movzbl (%ecx),%eax
  800a14:	3c 20                	cmp    $0x20,%al
  800a16:	74 f6                	je     800a0e <strtol+0xe>
  800a18:	3c 09                	cmp    $0x9,%al
  800a1a:	74 f2                	je     800a0e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1c:	3c 2b                	cmp    $0x2b,%al
  800a1e:	75 0a                	jne    800a2a <strtol+0x2a>
		s++;
  800a20:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a23:	bf 00 00 00 00       	mov    $0x0,%edi
  800a28:	eb 11                	jmp    800a3b <strtol+0x3b>
  800a2a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2f:	3c 2d                	cmp    $0x2d,%al
  800a31:	75 08                	jne    800a3b <strtol+0x3b>
		s++, neg = 1;
  800a33:	83 c1 01             	add    $0x1,%ecx
  800a36:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a41:	75 15                	jne    800a58 <strtol+0x58>
  800a43:	80 39 30             	cmpb   $0x30,(%ecx)
  800a46:	75 10                	jne    800a58 <strtol+0x58>
  800a48:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4c:	75 7c                	jne    800aca <strtol+0xca>
		s += 2, base = 16;
  800a4e:	83 c1 02             	add    $0x2,%ecx
  800a51:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a56:	eb 16                	jmp    800a6e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a58:	85 db                	test   %ebx,%ebx
  800a5a:	75 12                	jne    800a6e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a61:	80 39 30             	cmpb   $0x30,(%ecx)
  800a64:	75 08                	jne    800a6e <strtol+0x6e>
		s++, base = 8;
  800a66:	83 c1 01             	add    $0x1,%ecx
  800a69:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a73:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a76:	0f b6 11             	movzbl (%ecx),%edx
  800a79:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7c:	89 f3                	mov    %esi,%ebx
  800a7e:	80 fb 09             	cmp    $0x9,%bl
  800a81:	77 08                	ja     800a8b <strtol+0x8b>
			dig = *s - '0';
  800a83:	0f be d2             	movsbl %dl,%edx
  800a86:	83 ea 30             	sub    $0x30,%edx
  800a89:	eb 22                	jmp    800aad <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a8b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8e:	89 f3                	mov    %esi,%ebx
  800a90:	80 fb 19             	cmp    $0x19,%bl
  800a93:	77 08                	ja     800a9d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a95:	0f be d2             	movsbl %dl,%edx
  800a98:	83 ea 57             	sub    $0x57,%edx
  800a9b:	eb 10                	jmp    800aad <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a9d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa0:	89 f3                	mov    %esi,%ebx
  800aa2:	80 fb 19             	cmp    $0x19,%bl
  800aa5:	77 16                	ja     800abd <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa7:	0f be d2             	movsbl %dl,%edx
  800aaa:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aad:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab0:	7d 0b                	jge    800abd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab2:	83 c1 01             	add    $0x1,%ecx
  800ab5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abb:	eb b9                	jmp    800a76 <strtol+0x76>

	if (endptr)
  800abd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac1:	74 0d                	je     800ad0 <strtol+0xd0>
		*endptr = (char *) s;
  800ac3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac6:	89 0e                	mov    %ecx,(%esi)
  800ac8:	eb 06                	jmp    800ad0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aca:	85 db                	test   %ebx,%ebx
  800acc:	74 98                	je     800a66 <strtol+0x66>
  800ace:	eb 9e                	jmp    800a6e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad0:	89 c2                	mov    %eax,%edx
  800ad2:	f7 da                	neg    %edx
  800ad4:	85 ff                	test   %edi,%edi
  800ad6:	0f 45 c2             	cmovne %edx,%eax
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aec:	8b 55 08             	mov    0x8(%ebp),%edx
  800aef:	89 c3                	mov    %eax,%ebx
  800af1:	89 c7                	mov    %eax,%edi
  800af3:	89 c6                	mov    %eax,%esi
  800af5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <sys_cgetc>:

int
sys_cgetc(void)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	ba 00 00 00 00       	mov    $0x0,%edx
  800b07:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0c:	89 d1                	mov    %edx,%ecx
  800b0e:	89 d3                	mov    %edx,%ebx
  800b10:	89 d7                	mov    %edx,%edi
  800b12:	89 d6                	mov    %edx,%esi
  800b14:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
  800b21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b29:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b31:	89 cb                	mov    %ecx,%ebx
  800b33:	89 cf                	mov    %ecx,%edi
  800b35:	89 ce                	mov    %ecx,%esi
  800b37:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b39:	85 c0                	test   %eax,%eax
  800b3b:	7e 17                	jle    800b54 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3d:	83 ec 0c             	sub    $0xc,%esp
  800b40:	50                   	push   %eax
  800b41:	6a 03                	push   $0x3
  800b43:	68 24 17 80 00       	push   $0x801724
  800b48:	6a 23                	push   $0x23
  800b4a:	68 41 17 80 00       	push   $0x801741
  800b4f:	e8 f5 05 00 00       	call   801149 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6c:	89 d1                	mov    %edx,%ecx
  800b6e:	89 d3                	mov    %edx,%ebx
  800b70:	89 d7                	mov    %edx,%edi
  800b72:	89 d6                	mov    %edx,%esi
  800b74:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_yield>:

void
sys_yield(void)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b8b:	89 d1                	mov    %edx,%ecx
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	89 d7                	mov    %edx,%edi
  800b91:	89 d6                	mov    %edx,%esi
  800b93:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	be 00 00 00 00       	mov    $0x0,%esi
  800ba8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb6:	89 f7                	mov    %esi,%edi
  800bb8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bba:	85 c0                	test   %eax,%eax
  800bbc:	7e 17                	jle    800bd5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbe:	83 ec 0c             	sub    $0xc,%esp
  800bc1:	50                   	push   %eax
  800bc2:	6a 04                	push   $0x4
  800bc4:	68 24 17 80 00       	push   $0x801724
  800bc9:	6a 23                	push   $0x23
  800bcb:	68 41 17 80 00       	push   $0x801741
  800bd0:	e8 74 05 00 00       	call   801149 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	b8 05 00 00 00       	mov    $0x5,%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	7e 17                	jle    800c17 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c00:	83 ec 0c             	sub    $0xc,%esp
  800c03:	50                   	push   %eax
  800c04:	6a 05                	push   $0x5
  800c06:	68 24 17 80 00       	push   $0x801724
  800c0b:	6a 23                	push   $0x23
  800c0d:	68 41 17 80 00       	push   $0x801741
  800c12:	e8 32 05 00 00       	call   801149 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
  800c25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c35:	8b 55 08             	mov    0x8(%ebp),%edx
  800c38:	89 df                	mov    %ebx,%edi
  800c3a:	89 de                	mov    %ebx,%esi
  800c3c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	7e 17                	jle    800c59 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c42:	83 ec 0c             	sub    $0xc,%esp
  800c45:	50                   	push   %eax
  800c46:	6a 06                	push   $0x6
  800c48:	68 24 17 80 00       	push   $0x801724
  800c4d:	6a 23                	push   $0x23
  800c4f:	68 41 17 80 00       	push   $0x801741
  800c54:	e8 f0 04 00 00       	call   801149 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7a:	89 df                	mov    %ebx,%edi
  800c7c:	89 de                	mov    %ebx,%esi
  800c7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7e 17                	jle    800c9b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c84:	83 ec 0c             	sub    $0xc,%esp
  800c87:	50                   	push   %eax
  800c88:	6a 08                	push   $0x8
  800c8a:	68 24 17 80 00       	push   $0x801724
  800c8f:	6a 23                	push   $0x23
  800c91:	68 41 17 80 00       	push   $0x801741
  800c96:	e8 ae 04 00 00       	call   801149 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb1:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	89 df                	mov    %ebx,%edi
  800cbe:	89 de                	mov    %ebx,%esi
  800cc0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	7e 17                	jle    800cdd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc6:	83 ec 0c             	sub    $0xc,%esp
  800cc9:	50                   	push   %eax
  800cca:	6a 09                	push   $0x9
  800ccc:	68 24 17 80 00       	push   $0x801724
  800cd1:	6a 23                	push   $0x23
  800cd3:	68 41 17 80 00       	push   $0x801741
  800cd8:	e8 6c 04 00 00       	call   801149 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ceb:	be 00 00 00 00       	mov    $0x0,%esi
  800cf0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d01:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d16:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	89 cb                	mov    %ecx,%ebx
  800d20:	89 cf                	mov    %ecx,%edi
  800d22:	89 ce                	mov    %ecx,%esi
  800d24:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 17                	jle    800d41 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	83 ec 0c             	sub    $0xc,%esp
  800d2d:	50                   	push   %eax
  800d2e:	6a 0c                	push   $0xc
  800d30:	68 24 17 80 00       	push   $0x801724
  800d35:	6a 23                	push   $0x23
  800d37:	68 41 17 80 00       	push   $0x801741
  800d3c:	e8 08 04 00 00       	call   801149 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <sys_change_pr>:

int
sys_change_pr(int pr)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	57                   	push   %edi
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d54:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	89 cb                	mov    %ecx,%ebx
  800d5e:	89 cf                	mov    %ecx,%edi
  800d60:	89 ce                	mov    %ecx,%esi
  800d62:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
	// cprintf("1\n");
	void *addr = (void*) (pn*PGSIZE);
  800d70:	89 d3                	mov    %edx,%ebx
  800d72:	c1 e3 0c             	shl    $0xc,%ebx
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800d75:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d7c:	f6 c1 02             	test   $0x2,%cl
  800d7f:	75 0c                	jne    800d8d <duppage+0x24>
  800d81:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d88:	f6 c6 08             	test   $0x8,%dh
  800d8b:	74 5b                	je     800de8 <duppage+0x7f>
		if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800d8d:	83 ec 0c             	sub    $0xc,%esp
  800d90:	68 05 08 00 00       	push   $0x805
  800d95:	53                   	push   %ebx
  800d96:	50                   	push   %eax
  800d97:	53                   	push   %ebx
  800d98:	6a 00                	push   $0x0
  800d9a:	e8 3e fe ff ff       	call   800bdd <sys_page_map>
  800d9f:	83 c4 20             	add    $0x20,%esp
  800da2:	85 c0                	test   %eax,%eax
  800da4:	79 14                	jns    800dba <duppage+0x51>
			panic("2");
  800da6:	83 ec 04             	sub    $0x4,%esp
  800da9:	68 4f 17 80 00       	push   $0x80174f
  800dae:	6a 49                	push   $0x49
  800db0:	68 51 17 80 00       	push   $0x801751
  800db5:	e8 8f 03 00 00       	call   801149 <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800dba:	83 ec 0c             	sub    $0xc,%esp
  800dbd:	68 05 08 00 00       	push   $0x805
  800dc2:	53                   	push   %ebx
  800dc3:	6a 00                	push   $0x0
  800dc5:	53                   	push   %ebx
  800dc6:	6a 00                	push   $0x0
  800dc8:	e8 10 fe ff ff       	call   800bdd <sys_page_map>
  800dcd:	83 c4 20             	add    $0x20,%esp
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	79 26                	jns    800dfa <duppage+0x91>
			panic("3");
  800dd4:	83 ec 04             	sub    $0x4,%esp
  800dd7:	68 5c 17 80 00       	push   $0x80175c
  800ddc:	6a 4b                	push   $0x4b
  800dde:	68 51 17 80 00       	push   $0x801751
  800de3:	e8 61 03 00 00       	call   801149 <_panic>
	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800de8:	83 ec 0c             	sub    $0xc,%esp
  800deb:	6a 05                	push   $0x5
  800ded:	53                   	push   %ebx
  800dee:	50                   	push   %eax
  800def:	53                   	push   %ebx
  800df0:	6a 00                	push   $0x0
  800df2:	e8 e6 fd ff ff       	call   800bdd <sys_page_map>
  800df7:	83 c4 20             	add    $0x20,%esp
	// cprintf("2\n");
	return 0;
	panic("duppage not implemented");
}
  800dfa:	b8 00 00 00 00       	mov    $0x0,%eax
  800dff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e02:	c9                   	leave  
  800e03:	c3                   	ret    

00800e04 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	53                   	push   %ebx
  800e08:	83 ec 04             	sub    $0x4,%esp
  800e0b:	8b 55 08             	mov    0x8(%ebp),%edx
	// panic("pgfault");
	void *addr = (void *) utf->utf_fault_va;
  800e0e:	8b 02                	mov    (%edx),%eax
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e10:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e14:	74 2e                	je     800e44 <pgfault+0x40>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e16:	89 c2                	mov    %eax,%edx
  800e18:	c1 ea 16             	shr    $0x16,%edx
  800e1b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e22:	f6 c2 01             	test   $0x1,%dl
  800e25:	74 1d                	je     800e44 <pgfault+0x40>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e27:	89 c2                	mov    %eax,%edx
  800e29:	c1 ea 0c             	shr    $0xc,%edx
  800e2c:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e33:	f6 c1 01             	test   $0x1,%cl
  800e36:	74 0c                	je     800e44 <pgfault+0x40>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e38:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e3f:	f6 c6 08             	test   $0x8,%dh
  800e42:	75 14                	jne    800e58 <pgfault+0x54>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800e44:	83 ec 04             	sub    $0x4,%esp
  800e47:	68 5e 17 80 00       	push   $0x80175e
  800e4c:	6a 20                	push   $0x20
  800e4e:	68 51 17 80 00       	push   $0x801751
  800e53:	e8 f1 02 00 00       	call   801149 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800e58:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e5d:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800e5f:	83 ec 04             	sub    $0x4,%esp
  800e62:	6a 07                	push   $0x7
  800e64:	68 00 f0 7f 00       	push   $0x7ff000
  800e69:	6a 00                	push   $0x0
  800e6b:	e8 2a fd ff ff       	call   800b9a <sys_page_alloc>
  800e70:	83 c4 10             	add    $0x10,%esp
  800e73:	85 c0                	test   %eax,%eax
  800e75:	79 14                	jns    800e8b <pgfault+0x87>
		panic("sys_page_alloc");
  800e77:	83 ec 04             	sub    $0x4,%esp
  800e7a:	68 70 17 80 00       	push   $0x801770
  800e7f:	6a 2c                	push   $0x2c
  800e81:	68 51 17 80 00       	push   $0x801751
  800e86:	e8 be 02 00 00       	call   801149 <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  800e8b:	83 ec 04             	sub    $0x4,%esp
  800e8e:	68 00 10 00 00       	push   $0x1000
  800e93:	53                   	push   %ebx
  800e94:	68 00 f0 7f 00       	push   $0x7ff000
  800e99:	e8 f3 fa ff ff       	call   800991 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800e9e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ea5:	53                   	push   %ebx
  800ea6:	6a 00                	push   $0x0
  800ea8:	68 00 f0 7f 00       	push   $0x7ff000
  800ead:	6a 00                	push   $0x0
  800eaf:	e8 29 fd ff ff       	call   800bdd <sys_page_map>
  800eb4:	83 c4 20             	add    $0x20,%esp
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	79 14                	jns    800ecf <pgfault+0xcb>
		panic("sys_page_map");
  800ebb:	83 ec 04             	sub    $0x4,%esp
  800ebe:	68 7f 17 80 00       	push   $0x80177f
  800ec3:	6a 2f                	push   $0x2f
  800ec5:	68 51 17 80 00       	push   $0x801751
  800eca:	e8 7a 02 00 00       	call   801149 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800ecf:	83 ec 08             	sub    $0x8,%esp
  800ed2:	68 00 f0 7f 00       	push   $0x7ff000
  800ed7:	6a 00                	push   $0x0
  800ed9:	e8 41 fd ff ff       	call   800c1f <sys_page_unmap>
  800ede:	83 c4 10             	add    $0x10,%esp
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	79 14                	jns    800ef9 <pgfault+0xf5>
		panic("sys_page_unmap");
  800ee5:	83 ec 04             	sub    $0x4,%esp
  800ee8:	68 8c 17 80 00       	push   $0x80178c
  800eed:	6a 31                	push   $0x31
  800eef:	68 51 17 80 00       	push   $0x801751
  800ef4:	e8 50 02 00 00       	call   801149 <_panic>
	return;
}
  800ef9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800efc:	c9                   	leave  
  800efd:	c3                   	ret    

00800efe <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800f07:	68 04 0e 80 00       	push   $0x800e04
  800f0c:	e8 7e 02 00 00       	call   80118f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f11:	b8 07 00 00 00       	mov    $0x7,%eax
  800f16:	cd 30                	int    $0x30

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800f18:	83 c4 10             	add    $0x10,%esp
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	75 21                	jne    800f40 <fork+0x42>
		// panic("child");
		thisenv = &envs[ENVX(sys_getenvid())];
  800f1f:	e8 38 fc ff ff       	call   800b5c <sys_getenvid>
  800f24:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f29:	c1 e0 07             	shl    $0x7,%eax
  800f2c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f31:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3b:	e9 c6 00 00 00       	jmp    801006 <fork+0x108>
  800f40:	89 c6                	mov    %eax,%esi
  800f42:	89 c7                	mov    %eax,%edi
	}
	// cprintf("sys_exofork: %x\n", envid);
	if (envid < 0)
  800f44:	85 c0                	test   %eax,%eax
  800f46:	79 12                	jns    800f5a <fork+0x5c>
		panic("sys_exofork: %e", envid);
  800f48:	50                   	push   %eax
  800f49:	68 9b 17 80 00       	push   $0x80179b
  800f4e:	6a 71                	push   $0x71
  800f50:	68 51 17 80 00       	push   $0x801751
  800f55:	e8 ef 01 00 00       	call   801149 <_panic>
  800f5a:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800f5f:	89 d8                	mov    %ebx,%eax
  800f61:	c1 e8 16             	shr    $0x16,%eax
  800f64:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f6b:	a8 01                	test   $0x1,%al
  800f6d:	74 22                	je     800f91 <fork+0x93>
  800f6f:	89 da                	mov    %ebx,%edx
  800f71:	c1 ea 0c             	shr    $0xc,%edx
  800f74:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f7b:	a8 01                	test   $0x1,%al
  800f7d:	74 12                	je     800f91 <fork+0x93>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800f7f:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f86:	a8 04                	test   $0x4,%al
  800f88:	74 07                	je     800f91 <fork+0x93>
			// cprintf("envid: %x, PGNUM: %x, addr: %x\n", envid, PGNUM(addr), addr);
			// if (addr!=0x802000) {
			duppage(envid, PGNUM(addr));
  800f8a:	89 f8                	mov    %edi,%eax
  800f8c:	e8 d8 fd ff ff       	call   800d69 <duppage>
	}
	// cprintf("sys_exofork: %x\n", envid);
	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f91:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f97:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f9d:	75 c0                	jne    800f5f <fork+0x61>
			// cprintf("%x\n", uvpt[PGNUM(addr)]);
		}
	// panic("faint");


	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800f9f:	83 ec 04             	sub    $0x4,%esp
  800fa2:	6a 07                	push   $0x7
  800fa4:	68 00 f0 bf ee       	push   $0xeebff000
  800fa9:	56                   	push   %esi
  800faa:	e8 eb fb ff ff       	call   800b9a <sys_page_alloc>
  800faf:	83 c4 10             	add    $0x10,%esp
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	79 17                	jns    800fcd <fork+0xcf>
		panic("1");
  800fb6:	83 ec 04             	sub    $0x4,%esp
  800fb9:	68 ab 17 80 00       	push   $0x8017ab
  800fbe:	68 82 00 00 00       	push   $0x82
  800fc3:	68 51 17 80 00       	push   $0x801751
  800fc8:	e8 7c 01 00 00       	call   801149 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fcd:	83 ec 08             	sub    $0x8,%esp
  800fd0:	68 fe 11 80 00       	push   $0x8011fe
  800fd5:	56                   	push   %esi
  800fd6:	e8 c8 fc ff ff       	call   800ca3 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  800fdb:	83 c4 08             	add    $0x8,%esp
  800fde:	6a 02                	push   $0x2
  800fe0:	56                   	push   %esi
  800fe1:	e8 7b fc ff ff       	call   800c61 <sys_env_set_status>
  800fe6:	83 c4 10             	add    $0x10,%esp
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	79 17                	jns    801004 <fork+0x106>
		panic("sys_env_set_status");
  800fed:	83 ec 04             	sub    $0x4,%esp
  800ff0:	68 ad 17 80 00       	push   $0x8017ad
  800ff5:	68 87 00 00 00       	push   $0x87
  800ffa:	68 51 17 80 00       	push   $0x801751
  800fff:	e8 45 01 00 00       	call   801149 <_panic>

	return envid;
  801004:	89 f0                	mov    %esi,%eax
	panic("fork not implemented");
}
  801006:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801009:	5b                   	pop    %ebx
  80100a:	5e                   	pop    %esi
  80100b:	5f                   	pop    %edi
  80100c:	5d                   	pop    %ebp
  80100d:	c3                   	ret    

0080100e <pfork>:

envid_t
pfork(int pr)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
  801014:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  801017:	68 04 0e 80 00       	push   $0x800e04
  80101c:	e8 6e 01 00 00       	call   80118f <set_pgfault_handler>
  801021:	b8 07 00 00 00       	mov    $0x7,%eax
  801026:	cd 30                	int    $0x30

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	85 c0                	test   %eax,%eax
  80102d:	75 2f                	jne    80105e <pfork+0x50>
		thisenv = &envs[ENVX(sys_getenvid())];
  80102f:	e8 28 fb ff ff       	call   800b5c <sys_getenvid>
  801034:	25 ff 03 00 00       	and    $0x3ff,%eax
  801039:	c1 e0 07             	shl    $0x7,%eax
  80103c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801041:	a3 04 20 80 00       	mov    %eax,0x802004
		sys_change_pr(pr);
  801046:	83 ec 0c             	sub    $0xc,%esp
  801049:	ff 75 08             	pushl  0x8(%ebp)
  80104c:	e8 f8 fc ff ff       	call   800d49 <sys_change_pr>
		return 0;
  801051:	83 c4 10             	add    $0x10,%esp
  801054:	b8 00 00 00 00       	mov    $0x0,%eax
  801059:	e9 c9 00 00 00       	jmp    801127 <pfork+0x119>
  80105e:	89 c6                	mov    %eax,%esi
  801060:	89 c7                	mov    %eax,%edi
	}

	if (envid < 0)
  801062:	85 c0                	test   %eax,%eax
  801064:	79 15                	jns    80107b <pfork+0x6d>
		panic("sys_exofork: %e", envid);
  801066:	50                   	push   %eax
  801067:	68 9b 17 80 00       	push   $0x80179b
  80106c:	68 9c 00 00 00       	push   $0x9c
  801071:	68 51 17 80 00       	push   $0x801751
  801076:	e8 ce 00 00 00       	call   801149 <_panic>
  80107b:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  801080:	89 d8                	mov    %ebx,%eax
  801082:	c1 e8 16             	shr    $0x16,%eax
  801085:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80108c:	a8 01                	test   $0x1,%al
  80108e:	74 22                	je     8010b2 <pfork+0xa4>
  801090:	89 da                	mov    %ebx,%edx
  801092:	c1 ea 0c             	shr    $0xc,%edx
  801095:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80109c:	a8 01                	test   $0x1,%al
  80109e:	74 12                	je     8010b2 <pfork+0xa4>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  8010a0:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8010a7:	a8 04                	test   $0x4,%al
  8010a9:	74 07                	je     8010b2 <pfork+0xa4>
			duppage(envid, PGNUM(addr));
  8010ab:	89 f8                	mov    %edi,%eax
  8010ad:	e8 b7 fc ff ff       	call   800d69 <duppage>
	}

	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  8010b2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010b8:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010be:	75 c0                	jne    801080 <pfork+0x72>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8010c0:	83 ec 04             	sub    $0x4,%esp
  8010c3:	6a 07                	push   $0x7
  8010c5:	68 00 f0 bf ee       	push   $0xeebff000
  8010ca:	56                   	push   %esi
  8010cb:	e8 ca fa ff ff       	call   800b9a <sys_page_alloc>
  8010d0:	83 c4 10             	add    $0x10,%esp
  8010d3:	85 c0                	test   %eax,%eax
  8010d5:	79 17                	jns    8010ee <pfork+0xe0>
		panic("1");
  8010d7:	83 ec 04             	sub    $0x4,%esp
  8010da:	68 ab 17 80 00       	push   $0x8017ab
  8010df:	68 a5 00 00 00       	push   $0xa5
  8010e4:	68 51 17 80 00       	push   $0x801751
  8010e9:	e8 5b 00 00 00       	call   801149 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010ee:	83 ec 08             	sub    $0x8,%esp
  8010f1:	68 fe 11 80 00       	push   $0x8011fe
  8010f6:	56                   	push   %esi
  8010f7:	e8 a7 fb ff ff       	call   800ca3 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8010fc:	83 c4 08             	add    $0x8,%esp
  8010ff:	6a 02                	push   $0x2
  801101:	56                   	push   %esi
  801102:	e8 5a fb ff ff       	call   800c61 <sys_env_set_status>
  801107:	83 c4 10             	add    $0x10,%esp
  80110a:	85 c0                	test   %eax,%eax
  80110c:	79 17                	jns    801125 <pfork+0x117>
		panic("sys_env_set_status");
  80110e:	83 ec 04             	sub    $0x4,%esp
  801111:	68 ad 17 80 00       	push   $0x8017ad
  801116:	68 aa 00 00 00       	push   $0xaa
  80111b:	68 51 17 80 00       	push   $0x801751
  801120:	e8 24 00 00 00       	call   801149 <_panic>

	return envid;
  801125:	89 f0                	mov    %esi,%eax
	panic("fork not implemented");
}
  801127:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112a:	5b                   	pop    %ebx
  80112b:	5e                   	pop    %esi
  80112c:	5f                   	pop    %edi
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    

0080112f <sfork>:

// Challenge!
int
sfork(void)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801135:	68 c0 17 80 00       	push   $0x8017c0
  80113a:	68 b4 00 00 00       	push   $0xb4
  80113f:	68 51 17 80 00       	push   $0x801751
  801144:	e8 00 00 00 00       	call   801149 <_panic>

00801149 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	56                   	push   %esi
  80114d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80114e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801151:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801157:	e8 00 fa ff ff       	call   800b5c <sys_getenvid>
  80115c:	83 ec 0c             	sub    $0xc,%esp
  80115f:	ff 75 0c             	pushl  0xc(%ebp)
  801162:	ff 75 08             	pushl  0x8(%ebp)
  801165:	56                   	push   %esi
  801166:	50                   	push   %eax
  801167:	68 d8 17 80 00       	push   $0x8017d8
  80116c:	e8 5b f0 ff ff       	call   8001cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801171:	83 c4 18             	add    $0x18,%esp
  801174:	53                   	push   %ebx
  801175:	ff 75 10             	pushl  0x10(%ebp)
  801178:	e8 fe ef ff ff       	call   80017b <vcprintf>
	cprintf("\n");
  80117d:	c7 04 24 cf 14 80 00 	movl   $0x8014cf,(%esp)
  801184:	e8 43 f0 ff ff       	call   8001cc <cprintf>
  801189:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80118c:	cc                   	int3   
  80118d:	eb fd                	jmp    80118c <_panic+0x43>

0080118f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	83 ec 08             	sub    $0x8,%esp
	// int r;

	if (_pgfault_handler == 0) {
  801195:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  80119c:	75 2c                	jne    8011ca <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  80119e:	83 ec 04             	sub    $0x4,%esp
  8011a1:	6a 07                	push   $0x7
  8011a3:	68 00 f0 bf ee       	push   $0xeebff000
  8011a8:	6a 00                	push   $0x0
  8011aa:	e8 eb f9 ff ff       	call   800b9a <sys_page_alloc>
  8011af:	83 c4 10             	add    $0x10,%esp
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	79 14                	jns    8011ca <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  8011b6:	83 ec 04             	sub    $0x4,%esp
  8011b9:	68 fc 17 80 00       	push   $0x8017fc
  8011be:	6a 21                	push   $0x21
  8011c0:	68 60 18 80 00       	push   $0x801860
  8011c5:	e8 7f ff ff ff       	call   801149 <_panic>
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cd:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8011d2:	83 ec 08             	sub    $0x8,%esp
  8011d5:	68 fe 11 80 00       	push   $0x8011fe
  8011da:	6a 00                	push   $0x0
  8011dc:	e8 c2 fa ff ff       	call   800ca3 <sys_env_set_pgfault_upcall>
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	79 14                	jns    8011fc <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8011e8:	83 ec 04             	sub    $0x4,%esp
  8011eb:	68 28 18 80 00       	push   $0x801828
  8011f0:	6a 26                	push   $0x26
  8011f2:	68 60 18 80 00       	push   $0x801860
  8011f7:	e8 4d ff ff ff       	call   801149 <_panic>
}
  8011fc:	c9                   	leave  
  8011fd:	c3                   	ret    

008011fe <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011fe:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011ff:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801204:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801206:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx #trap-time eip
  801209:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)
  80120d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax #trap-time esp-4
  801212:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)
  801216:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp
  801218:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  80121b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp #eip
  80121c:	83 c4 04             	add    $0x4,%esp
	popfl
  80121f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801220:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801221:	c3                   	ret    
  801222:	66 90                	xchg   %ax,%ax
  801224:	66 90                	xchg   %ax,%ax
  801226:	66 90                	xchg   %ax,%ax
  801228:	66 90                	xchg   %ax,%ax
  80122a:	66 90                	xchg   %ax,%ax
  80122c:	66 90                	xchg   %ax,%ax
  80122e:	66 90                	xchg   %ax,%ax

00801230 <__udivdi3>:
  801230:	55                   	push   %ebp
  801231:	57                   	push   %edi
  801232:	56                   	push   %esi
  801233:	53                   	push   %ebx
  801234:	83 ec 1c             	sub    $0x1c,%esp
  801237:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80123b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80123f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801243:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801247:	85 f6                	test   %esi,%esi
  801249:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80124d:	89 ca                	mov    %ecx,%edx
  80124f:	89 f8                	mov    %edi,%eax
  801251:	75 3d                	jne    801290 <__udivdi3+0x60>
  801253:	39 cf                	cmp    %ecx,%edi
  801255:	0f 87 c5 00 00 00    	ja     801320 <__udivdi3+0xf0>
  80125b:	85 ff                	test   %edi,%edi
  80125d:	89 fd                	mov    %edi,%ebp
  80125f:	75 0b                	jne    80126c <__udivdi3+0x3c>
  801261:	b8 01 00 00 00       	mov    $0x1,%eax
  801266:	31 d2                	xor    %edx,%edx
  801268:	f7 f7                	div    %edi
  80126a:	89 c5                	mov    %eax,%ebp
  80126c:	89 c8                	mov    %ecx,%eax
  80126e:	31 d2                	xor    %edx,%edx
  801270:	f7 f5                	div    %ebp
  801272:	89 c1                	mov    %eax,%ecx
  801274:	89 d8                	mov    %ebx,%eax
  801276:	89 cf                	mov    %ecx,%edi
  801278:	f7 f5                	div    %ebp
  80127a:	89 c3                	mov    %eax,%ebx
  80127c:	89 d8                	mov    %ebx,%eax
  80127e:	89 fa                	mov    %edi,%edx
  801280:	83 c4 1c             	add    $0x1c,%esp
  801283:	5b                   	pop    %ebx
  801284:	5e                   	pop    %esi
  801285:	5f                   	pop    %edi
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    
  801288:	90                   	nop
  801289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801290:	39 ce                	cmp    %ecx,%esi
  801292:	77 74                	ja     801308 <__udivdi3+0xd8>
  801294:	0f bd fe             	bsr    %esi,%edi
  801297:	83 f7 1f             	xor    $0x1f,%edi
  80129a:	0f 84 98 00 00 00    	je     801338 <__udivdi3+0x108>
  8012a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8012a5:	89 f9                	mov    %edi,%ecx
  8012a7:	89 c5                	mov    %eax,%ebp
  8012a9:	29 fb                	sub    %edi,%ebx
  8012ab:	d3 e6                	shl    %cl,%esi
  8012ad:	89 d9                	mov    %ebx,%ecx
  8012af:	d3 ed                	shr    %cl,%ebp
  8012b1:	89 f9                	mov    %edi,%ecx
  8012b3:	d3 e0                	shl    %cl,%eax
  8012b5:	09 ee                	or     %ebp,%esi
  8012b7:	89 d9                	mov    %ebx,%ecx
  8012b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012bd:	89 d5                	mov    %edx,%ebp
  8012bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8012c3:	d3 ed                	shr    %cl,%ebp
  8012c5:	89 f9                	mov    %edi,%ecx
  8012c7:	d3 e2                	shl    %cl,%edx
  8012c9:	89 d9                	mov    %ebx,%ecx
  8012cb:	d3 e8                	shr    %cl,%eax
  8012cd:	09 c2                	or     %eax,%edx
  8012cf:	89 d0                	mov    %edx,%eax
  8012d1:	89 ea                	mov    %ebp,%edx
  8012d3:	f7 f6                	div    %esi
  8012d5:	89 d5                	mov    %edx,%ebp
  8012d7:	89 c3                	mov    %eax,%ebx
  8012d9:	f7 64 24 0c          	mull   0xc(%esp)
  8012dd:	39 d5                	cmp    %edx,%ebp
  8012df:	72 10                	jb     8012f1 <__udivdi3+0xc1>
  8012e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8012e5:	89 f9                	mov    %edi,%ecx
  8012e7:	d3 e6                	shl    %cl,%esi
  8012e9:	39 c6                	cmp    %eax,%esi
  8012eb:	73 07                	jae    8012f4 <__udivdi3+0xc4>
  8012ed:	39 d5                	cmp    %edx,%ebp
  8012ef:	75 03                	jne    8012f4 <__udivdi3+0xc4>
  8012f1:	83 eb 01             	sub    $0x1,%ebx
  8012f4:	31 ff                	xor    %edi,%edi
  8012f6:	89 d8                	mov    %ebx,%eax
  8012f8:	89 fa                	mov    %edi,%edx
  8012fa:	83 c4 1c             	add    $0x1c,%esp
  8012fd:	5b                   	pop    %ebx
  8012fe:	5e                   	pop    %esi
  8012ff:	5f                   	pop    %edi
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    
  801302:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801308:	31 ff                	xor    %edi,%edi
  80130a:	31 db                	xor    %ebx,%ebx
  80130c:	89 d8                	mov    %ebx,%eax
  80130e:	89 fa                	mov    %edi,%edx
  801310:	83 c4 1c             	add    $0x1c,%esp
  801313:	5b                   	pop    %ebx
  801314:	5e                   	pop    %esi
  801315:	5f                   	pop    %edi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    
  801318:	90                   	nop
  801319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801320:	89 d8                	mov    %ebx,%eax
  801322:	f7 f7                	div    %edi
  801324:	31 ff                	xor    %edi,%edi
  801326:	89 c3                	mov    %eax,%ebx
  801328:	89 d8                	mov    %ebx,%eax
  80132a:	89 fa                	mov    %edi,%edx
  80132c:	83 c4 1c             	add    $0x1c,%esp
  80132f:	5b                   	pop    %ebx
  801330:	5e                   	pop    %esi
  801331:	5f                   	pop    %edi
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    
  801334:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801338:	39 ce                	cmp    %ecx,%esi
  80133a:	72 0c                	jb     801348 <__udivdi3+0x118>
  80133c:	31 db                	xor    %ebx,%ebx
  80133e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801342:	0f 87 34 ff ff ff    	ja     80127c <__udivdi3+0x4c>
  801348:	bb 01 00 00 00       	mov    $0x1,%ebx
  80134d:	e9 2a ff ff ff       	jmp    80127c <__udivdi3+0x4c>
  801352:	66 90                	xchg   %ax,%ax
  801354:	66 90                	xchg   %ax,%ax
  801356:	66 90                	xchg   %ax,%ax
  801358:	66 90                	xchg   %ax,%ax
  80135a:	66 90                	xchg   %ax,%ax
  80135c:	66 90                	xchg   %ax,%ax
  80135e:	66 90                	xchg   %ax,%ax

00801360 <__umoddi3>:
  801360:	55                   	push   %ebp
  801361:	57                   	push   %edi
  801362:	56                   	push   %esi
  801363:	53                   	push   %ebx
  801364:	83 ec 1c             	sub    $0x1c,%esp
  801367:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80136b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80136f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801373:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801377:	85 d2                	test   %edx,%edx
  801379:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80137d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801381:	89 f3                	mov    %esi,%ebx
  801383:	89 3c 24             	mov    %edi,(%esp)
  801386:	89 74 24 04          	mov    %esi,0x4(%esp)
  80138a:	75 1c                	jne    8013a8 <__umoddi3+0x48>
  80138c:	39 f7                	cmp    %esi,%edi
  80138e:	76 50                	jbe    8013e0 <__umoddi3+0x80>
  801390:	89 c8                	mov    %ecx,%eax
  801392:	89 f2                	mov    %esi,%edx
  801394:	f7 f7                	div    %edi
  801396:	89 d0                	mov    %edx,%eax
  801398:	31 d2                	xor    %edx,%edx
  80139a:	83 c4 1c             	add    $0x1c,%esp
  80139d:	5b                   	pop    %ebx
  80139e:	5e                   	pop    %esi
  80139f:	5f                   	pop    %edi
  8013a0:	5d                   	pop    %ebp
  8013a1:	c3                   	ret    
  8013a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013a8:	39 f2                	cmp    %esi,%edx
  8013aa:	89 d0                	mov    %edx,%eax
  8013ac:	77 52                	ja     801400 <__umoddi3+0xa0>
  8013ae:	0f bd ea             	bsr    %edx,%ebp
  8013b1:	83 f5 1f             	xor    $0x1f,%ebp
  8013b4:	75 5a                	jne    801410 <__umoddi3+0xb0>
  8013b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8013ba:	0f 82 e0 00 00 00    	jb     8014a0 <__umoddi3+0x140>
  8013c0:	39 0c 24             	cmp    %ecx,(%esp)
  8013c3:	0f 86 d7 00 00 00    	jbe    8014a0 <__umoddi3+0x140>
  8013c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8013d1:	83 c4 1c             	add    $0x1c,%esp
  8013d4:	5b                   	pop    %ebx
  8013d5:	5e                   	pop    %esi
  8013d6:	5f                   	pop    %edi
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    
  8013d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013e0:	85 ff                	test   %edi,%edi
  8013e2:	89 fd                	mov    %edi,%ebp
  8013e4:	75 0b                	jne    8013f1 <__umoddi3+0x91>
  8013e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013eb:	31 d2                	xor    %edx,%edx
  8013ed:	f7 f7                	div    %edi
  8013ef:	89 c5                	mov    %eax,%ebp
  8013f1:	89 f0                	mov    %esi,%eax
  8013f3:	31 d2                	xor    %edx,%edx
  8013f5:	f7 f5                	div    %ebp
  8013f7:	89 c8                	mov    %ecx,%eax
  8013f9:	f7 f5                	div    %ebp
  8013fb:	89 d0                	mov    %edx,%eax
  8013fd:	eb 99                	jmp    801398 <__umoddi3+0x38>
  8013ff:	90                   	nop
  801400:	89 c8                	mov    %ecx,%eax
  801402:	89 f2                	mov    %esi,%edx
  801404:	83 c4 1c             	add    $0x1c,%esp
  801407:	5b                   	pop    %ebx
  801408:	5e                   	pop    %esi
  801409:	5f                   	pop    %edi
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    
  80140c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801410:	8b 34 24             	mov    (%esp),%esi
  801413:	bf 20 00 00 00       	mov    $0x20,%edi
  801418:	89 e9                	mov    %ebp,%ecx
  80141a:	29 ef                	sub    %ebp,%edi
  80141c:	d3 e0                	shl    %cl,%eax
  80141e:	89 f9                	mov    %edi,%ecx
  801420:	89 f2                	mov    %esi,%edx
  801422:	d3 ea                	shr    %cl,%edx
  801424:	89 e9                	mov    %ebp,%ecx
  801426:	09 c2                	or     %eax,%edx
  801428:	89 d8                	mov    %ebx,%eax
  80142a:	89 14 24             	mov    %edx,(%esp)
  80142d:	89 f2                	mov    %esi,%edx
  80142f:	d3 e2                	shl    %cl,%edx
  801431:	89 f9                	mov    %edi,%ecx
  801433:	89 54 24 04          	mov    %edx,0x4(%esp)
  801437:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80143b:	d3 e8                	shr    %cl,%eax
  80143d:	89 e9                	mov    %ebp,%ecx
  80143f:	89 c6                	mov    %eax,%esi
  801441:	d3 e3                	shl    %cl,%ebx
  801443:	89 f9                	mov    %edi,%ecx
  801445:	89 d0                	mov    %edx,%eax
  801447:	d3 e8                	shr    %cl,%eax
  801449:	89 e9                	mov    %ebp,%ecx
  80144b:	09 d8                	or     %ebx,%eax
  80144d:	89 d3                	mov    %edx,%ebx
  80144f:	89 f2                	mov    %esi,%edx
  801451:	f7 34 24             	divl   (%esp)
  801454:	89 d6                	mov    %edx,%esi
  801456:	d3 e3                	shl    %cl,%ebx
  801458:	f7 64 24 04          	mull   0x4(%esp)
  80145c:	39 d6                	cmp    %edx,%esi
  80145e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801462:	89 d1                	mov    %edx,%ecx
  801464:	89 c3                	mov    %eax,%ebx
  801466:	72 08                	jb     801470 <__umoddi3+0x110>
  801468:	75 11                	jne    80147b <__umoddi3+0x11b>
  80146a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80146e:	73 0b                	jae    80147b <__umoddi3+0x11b>
  801470:	2b 44 24 04          	sub    0x4(%esp),%eax
  801474:	1b 14 24             	sbb    (%esp),%edx
  801477:	89 d1                	mov    %edx,%ecx
  801479:	89 c3                	mov    %eax,%ebx
  80147b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80147f:	29 da                	sub    %ebx,%edx
  801481:	19 ce                	sbb    %ecx,%esi
  801483:	89 f9                	mov    %edi,%ecx
  801485:	89 f0                	mov    %esi,%eax
  801487:	d3 e0                	shl    %cl,%eax
  801489:	89 e9                	mov    %ebp,%ecx
  80148b:	d3 ea                	shr    %cl,%edx
  80148d:	89 e9                	mov    %ebp,%ecx
  80148f:	d3 ee                	shr    %cl,%esi
  801491:	09 d0                	or     %edx,%eax
  801493:	89 f2                	mov    %esi,%edx
  801495:	83 c4 1c             	add    $0x1c,%esp
  801498:	5b                   	pop    %ebx
  801499:	5e                   	pop    %esi
  80149a:	5f                   	pop    %edi
  80149b:	5d                   	pop    %ebp
  80149c:	c3                   	ret    
  80149d:	8d 76 00             	lea    0x0(%esi),%esi
  8014a0:	29 f9                	sub    %edi,%ecx
  8014a2:	19 d6                	sbb    %edx,%esi
  8014a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014ac:	e9 18 ff ff ff       	jmp    8013c9 <__umoddi3+0x69>
