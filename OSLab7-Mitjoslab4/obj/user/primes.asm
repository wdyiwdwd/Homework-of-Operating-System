
obj/user/primes：     文件格式 elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 5a 11 00 00       	call   8011a6 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 20 80 00       	mov    0x802004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 c0 15 80 00       	push   $0x8015c0
  800060:	e8 c4 01 00 00       	call   800229 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 f1 0e 00 00       	call   800f5b <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 c2 18 80 00       	push   $0x8018c2
  800079:	6a 1a                	push   $0x1a
  80007b:	68 cc 15 80 00       	push   $0x8015cc
  800080:	e8 cb 00 00 00       	call   800150 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 0d 11 00 00       	call   8011a6 <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 5d 11 00 00       	call   80120d <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 9c 0e 00 00       	call   800f5b <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 c2 18 80 00       	push   $0x8018c2
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 cc 15 80 00       	push   $0x8015cc
  8000d2:	e8 79 00 00 00       	call   800150 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 1d 11 00 00       	call   80120d <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800103:	e8 b1 0a 00 00       	call   800bb9 <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	c1 e0 07             	shl    $0x7,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800144:	6a 00                	push   $0x0
  800146:	e8 2d 0a 00 00       	call   800b78 <sys_env_destroy>
}
  80014b:	83 c4 10             	add    $0x10,%esp
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800155:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800158:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80015e:	e8 56 0a 00 00       	call   800bb9 <sys_getenvid>
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	ff 75 0c             	pushl  0xc(%ebp)
  800169:	ff 75 08             	pushl  0x8(%ebp)
  80016c:	56                   	push   %esi
  80016d:	50                   	push   %eax
  80016e:	68 e4 15 80 00       	push   $0x8015e4
  800173:	e8 b1 00 00 00       	call   800229 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800178:	83 c4 18             	add    $0x18,%esp
  80017b:	53                   	push   %ebx
  80017c:	ff 75 10             	pushl  0x10(%ebp)
  80017f:	e8 54 00 00 00       	call   8001d8 <vcprintf>
	cprintf("\n");
  800184:	c7 04 24 07 16 80 00 	movl   $0x801607,(%esp)
  80018b:	e8 99 00 00 00       	call   800229 <cprintf>
  800190:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800193:	cc                   	int3   
  800194:	eb fd                	jmp    800193 <_panic+0x43>

00800196 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	53                   	push   %ebx
  80019a:	83 ec 04             	sub    $0x4,%esp
  80019d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a0:	8b 13                	mov    (%ebx),%edx
  8001a2:	8d 42 01             	lea    0x1(%edx),%eax
  8001a5:	89 03                	mov    %eax,(%ebx)
  8001a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b3:	75 1a                	jne    8001cf <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b5:	83 ec 08             	sub    $0x8,%esp
  8001b8:	68 ff 00 00 00       	push   $0xff
  8001bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c0:	50                   	push   %eax
  8001c1:	e8 75 09 00 00       	call   800b3b <sys_cputs>
		b->idx = 0;
  8001c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e8:	00 00 00 
	b.cnt = 0;
  8001eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f5:	ff 75 0c             	pushl  0xc(%ebp)
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800201:	50                   	push   %eax
  800202:	68 96 01 80 00       	push   $0x800196
  800207:	e8 54 01 00 00       	call   800360 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020c:	83 c4 08             	add    $0x8,%esp
  80020f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800215:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 1a 09 00 00       	call   800b3b <sys_cputs>

	return b.cnt;
}
  800221:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800232:	50                   	push   %eax
  800233:	ff 75 08             	pushl  0x8(%ebp)
  800236:	e8 9d ff ff ff       	call   8001d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023b:	c9                   	leave  
  80023c:	c3                   	ret    

0080023d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	57                   	push   %edi
  800241:	56                   	push   %esi
  800242:	53                   	push   %ebx
  800243:	83 ec 1c             	sub    $0x1c,%esp
  800246:	89 c7                	mov    %eax,%edi
  800248:	89 d6                	mov    %edx,%esi
  80024a:	8b 45 08             	mov    0x8(%ebp),%eax
  80024d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800250:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800253:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800256:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800259:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800261:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800264:	39 d3                	cmp    %edx,%ebx
  800266:	72 05                	jb     80026d <printnum+0x30>
  800268:	39 45 10             	cmp    %eax,0x10(%ebp)
  80026b:	77 45                	ja     8002b2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026d:	83 ec 0c             	sub    $0xc,%esp
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	8b 45 14             	mov    0x14(%ebp),%eax
  800276:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800279:	53                   	push   %ebx
  80027a:	ff 75 10             	pushl  0x10(%ebp)
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	ff 75 e4             	pushl  -0x1c(%ebp)
  800283:	ff 75 e0             	pushl  -0x20(%ebp)
  800286:	ff 75 dc             	pushl  -0x24(%ebp)
  800289:	ff 75 d8             	pushl  -0x28(%ebp)
  80028c:	e8 9f 10 00 00       	call   801330 <__udivdi3>
  800291:	83 c4 18             	add    $0x18,%esp
  800294:	52                   	push   %edx
  800295:	50                   	push   %eax
  800296:	89 f2                	mov    %esi,%edx
  800298:	89 f8                	mov    %edi,%eax
  80029a:	e8 9e ff ff ff       	call   80023d <printnum>
  80029f:	83 c4 20             	add    $0x20,%esp
  8002a2:	eb 18                	jmp    8002bc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	56                   	push   %esi
  8002a8:	ff 75 18             	pushl  0x18(%ebp)
  8002ab:	ff d7                	call   *%edi
  8002ad:	83 c4 10             	add    $0x10,%esp
  8002b0:	eb 03                	jmp    8002b5 <printnum+0x78>
  8002b2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b5:	83 eb 01             	sub    $0x1,%ebx
  8002b8:	85 db                	test   %ebx,%ebx
  8002ba:	7f e8                	jg     8002a4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bc:	83 ec 08             	sub    $0x8,%esp
  8002bf:	56                   	push   %esi
  8002c0:	83 ec 04             	sub    $0x4,%esp
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cf:	e8 8c 11 00 00       	call   801460 <__umoddi3>
  8002d4:	83 c4 14             	add    $0x14,%esp
  8002d7:	0f be 80 09 16 80 00 	movsbl 0x801609(%eax),%eax
  8002de:	50                   	push   %eax
  8002df:	ff d7                	call   *%edi
}
  8002e1:	83 c4 10             	add    $0x10,%esp
  8002e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e7:	5b                   	pop    %ebx
  8002e8:	5e                   	pop    %esi
  8002e9:	5f                   	pop    %edi
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ef:	83 fa 01             	cmp    $0x1,%edx
  8002f2:	7e 0e                	jle    800302 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f4:	8b 10                	mov    (%eax),%edx
  8002f6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f9:	89 08                	mov    %ecx,(%eax)
  8002fb:	8b 02                	mov    (%edx),%eax
  8002fd:	8b 52 04             	mov    0x4(%edx),%edx
  800300:	eb 22                	jmp    800324 <getuint+0x38>
	else if (lflag)
  800302:	85 d2                	test   %edx,%edx
  800304:	74 10                	je     800316 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800306:	8b 10                	mov    (%eax),%edx
  800308:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030b:	89 08                	mov    %ecx,(%eax)
  80030d:	8b 02                	mov    (%edx),%eax
  80030f:	ba 00 00 00 00       	mov    $0x0,%edx
  800314:	eb 0e                	jmp    800324 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800316:	8b 10                	mov    (%eax),%edx
  800318:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031b:	89 08                	mov    %ecx,(%eax)
  80031d:	8b 02                	mov    (%edx),%eax
  80031f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800330:	8b 10                	mov    (%eax),%edx
  800332:	3b 50 04             	cmp    0x4(%eax),%edx
  800335:	73 0a                	jae    800341 <sprintputch+0x1b>
		*b->buf++ = ch;
  800337:	8d 4a 01             	lea    0x1(%edx),%ecx
  80033a:	89 08                	mov    %ecx,(%eax)
  80033c:	8b 45 08             	mov    0x8(%ebp),%eax
  80033f:	88 02                	mov    %al,(%edx)
}
  800341:	5d                   	pop    %ebp
  800342:	c3                   	ret    

00800343 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800349:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034c:	50                   	push   %eax
  80034d:	ff 75 10             	pushl  0x10(%ebp)
  800350:	ff 75 0c             	pushl  0xc(%ebp)
  800353:	ff 75 08             	pushl  0x8(%ebp)
  800356:	e8 05 00 00 00       	call   800360 <vprintfmt>
	va_end(ap);
}
  80035b:	83 c4 10             	add    $0x10,%esp
  80035e:	c9                   	leave  
  80035f:	c3                   	ret    

00800360 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	53                   	push   %ebx
  800366:	83 ec 2c             	sub    $0x2c,%esp
  800369:	8b 75 08             	mov    0x8(%ebp),%esi
  80036c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800372:	eb 1d                	jmp    800391 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800374:	85 c0                	test   %eax,%eax
  800376:	75 0f                	jne    800387 <vprintfmt+0x27>
				csa = 0x0700;
  800378:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80037f:	07 00 00 
				return;
  800382:	e9 c4 03 00 00       	jmp    80074b <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800387:	83 ec 08             	sub    $0x8,%esp
  80038a:	53                   	push   %ebx
  80038b:	50                   	push   %eax
  80038c:	ff d6                	call   *%esi
  80038e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800391:	83 c7 01             	add    $0x1,%edi
  800394:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800398:	83 f8 25             	cmp    $0x25,%eax
  80039b:	75 d7                	jne    800374 <vprintfmt+0x14>
  80039d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003af:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bb:	eb 07                	jmp    8003c4 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8d 47 01             	lea    0x1(%edi),%eax
  8003c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ca:	0f b6 07             	movzbl (%edi),%eax
  8003cd:	0f b6 c8             	movzbl %al,%ecx
  8003d0:	83 e8 23             	sub    $0x23,%eax
  8003d3:	3c 55                	cmp    $0x55,%al
  8003d5:	0f 87 55 03 00 00    	ja     800730 <vprintfmt+0x3d0>
  8003db:	0f b6 c0             	movzbl %al,%eax
  8003de:	ff 24 85 c0 16 80 00 	jmp    *0x8016c0(,%eax,4)
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ec:	eb d6                	jmp    8003c4 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003fc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800400:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800403:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800406:	83 fa 09             	cmp    $0x9,%edx
  800409:	77 39                	ja     800444 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040e:	eb e9                	jmp    8003f9 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800410:	8b 45 14             	mov    0x14(%ebp),%eax
  800413:	8d 48 04             	lea    0x4(%eax),%ecx
  800416:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800419:	8b 00                	mov    (%eax),%eax
  80041b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800421:	eb 27                	jmp    80044a <vprintfmt+0xea>
  800423:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800426:	85 c0                	test   %eax,%eax
  800428:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042d:	0f 49 c8             	cmovns %eax,%ecx
  800430:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800433:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800436:	eb 8c                	jmp    8003c4 <vprintfmt+0x64>
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800442:	eb 80                	jmp    8003c4 <vprintfmt+0x64>
  800444:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800447:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80044a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044e:	0f 89 70 ff ff ff    	jns    8003c4 <vprintfmt+0x64>
				width = precision, precision = -1;
  800454:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800457:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800461:	e9 5e ff ff ff       	jmp    8003c4 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800466:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80046c:	e9 53 ff ff ff       	jmp    8003c4 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	8d 50 04             	lea    0x4(%eax),%edx
  800477:	89 55 14             	mov    %edx,0x14(%ebp)
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	53                   	push   %ebx
  80047e:	ff 30                	pushl  (%eax)
  800480:	ff d6                	call   *%esi
			break;
  800482:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800488:	e9 04 ff ff ff       	jmp    800391 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8d 50 04             	lea    0x4(%eax),%edx
  800493:	89 55 14             	mov    %edx,0x14(%ebp)
  800496:	8b 00                	mov    (%eax),%eax
  800498:	99                   	cltd   
  800499:	31 d0                	xor    %edx,%eax
  80049b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049d:	83 f8 08             	cmp    $0x8,%eax
  8004a0:	7f 0b                	jg     8004ad <vprintfmt+0x14d>
  8004a2:	8b 14 85 20 18 80 00 	mov    0x801820(,%eax,4),%edx
  8004a9:	85 d2                	test   %edx,%edx
  8004ab:	75 18                	jne    8004c5 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  8004ad:	50                   	push   %eax
  8004ae:	68 21 16 80 00       	push   $0x801621
  8004b3:	53                   	push   %ebx
  8004b4:	56                   	push   %esi
  8004b5:	e8 89 fe ff ff       	call   800343 <printfmt>
  8004ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c0:	e9 cc fe ff ff       	jmp    800391 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8004c5:	52                   	push   %edx
  8004c6:	68 2a 16 80 00       	push   $0x80162a
  8004cb:	53                   	push   %ebx
  8004cc:	56                   	push   %esi
  8004cd:	e8 71 fe ff ff       	call   800343 <printfmt>
  8004d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d8:	e9 b4 fe ff ff       	jmp    800391 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e0:	8d 50 04             	lea    0x4(%eax),%edx
  8004e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e8:	85 ff                	test   %edi,%edi
  8004ea:	b8 1a 16 80 00       	mov    $0x80161a,%eax
  8004ef:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f6:	0f 8e 94 00 00 00    	jle    800590 <vprintfmt+0x230>
  8004fc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800500:	0f 84 98 00 00 00    	je     80059e <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	ff 75 d0             	pushl  -0x30(%ebp)
  80050c:	57                   	push   %edi
  80050d:	e8 c1 02 00 00       	call   8007d3 <strnlen>
  800512:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800515:	29 c1                	sub    %eax,%ecx
  800517:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800521:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800524:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800527:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800529:	eb 0f                	jmp    80053a <vprintfmt+0x1da>
					putch(padc, putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	53                   	push   %ebx
  80052f:	ff 75 e0             	pushl  -0x20(%ebp)
  800532:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800534:	83 ef 01             	sub    $0x1,%edi
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	85 ff                	test   %edi,%edi
  80053c:	7f ed                	jg     80052b <vprintfmt+0x1cb>
  80053e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800541:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800544:	85 c9                	test   %ecx,%ecx
  800546:	b8 00 00 00 00       	mov    $0x0,%eax
  80054b:	0f 49 c1             	cmovns %ecx,%eax
  80054e:	29 c1                	sub    %eax,%ecx
  800550:	89 75 08             	mov    %esi,0x8(%ebp)
  800553:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800556:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800559:	89 cb                	mov    %ecx,%ebx
  80055b:	eb 4d                	jmp    8005aa <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800561:	74 1b                	je     80057e <vprintfmt+0x21e>
  800563:	0f be c0             	movsbl %al,%eax
  800566:	83 e8 20             	sub    $0x20,%eax
  800569:	83 f8 5e             	cmp    $0x5e,%eax
  80056c:	76 10                	jbe    80057e <vprintfmt+0x21e>
					putch('?', putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	ff 75 0c             	pushl  0xc(%ebp)
  800574:	6a 3f                	push   $0x3f
  800576:	ff 55 08             	call   *0x8(%ebp)
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	eb 0d                	jmp    80058b <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  80057e:	83 ec 08             	sub    $0x8,%esp
  800581:	ff 75 0c             	pushl  0xc(%ebp)
  800584:	52                   	push   %edx
  800585:	ff 55 08             	call   *0x8(%ebp)
  800588:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058b:	83 eb 01             	sub    $0x1,%ebx
  80058e:	eb 1a                	jmp    8005aa <vprintfmt+0x24a>
  800590:	89 75 08             	mov    %esi,0x8(%ebp)
  800593:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800596:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800599:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059c:	eb 0c                	jmp    8005aa <vprintfmt+0x24a>
  80059e:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005aa:	83 c7 01             	add    $0x1,%edi
  8005ad:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b1:	0f be d0             	movsbl %al,%edx
  8005b4:	85 d2                	test   %edx,%edx
  8005b6:	74 23                	je     8005db <vprintfmt+0x27b>
  8005b8:	85 f6                	test   %esi,%esi
  8005ba:	78 a1                	js     80055d <vprintfmt+0x1fd>
  8005bc:	83 ee 01             	sub    $0x1,%esi
  8005bf:	79 9c                	jns    80055d <vprintfmt+0x1fd>
  8005c1:	89 df                	mov    %ebx,%edi
  8005c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c9:	eb 18                	jmp    8005e3 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	6a 20                	push   $0x20
  8005d1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d3:	83 ef 01             	sub    $0x1,%edi
  8005d6:	83 c4 10             	add    $0x10,%esp
  8005d9:	eb 08                	jmp    8005e3 <vprintfmt+0x283>
  8005db:	89 df                	mov    %ebx,%edi
  8005dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e3:	85 ff                	test   %edi,%edi
  8005e5:	7f e4                	jg     8005cb <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ea:	e9 a2 fd ff ff       	jmp    800391 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ef:	83 fa 01             	cmp    $0x1,%edx
  8005f2:	7e 16                	jle    80060a <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 08             	lea    0x8(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fd:	8b 50 04             	mov    0x4(%eax),%edx
  800600:	8b 00                	mov    (%eax),%eax
  800602:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800605:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800608:	eb 32                	jmp    80063c <vprintfmt+0x2dc>
	else if (lflag)
  80060a:	85 d2                	test   %edx,%edx
  80060c:	74 18                	je     800626 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 50 04             	lea    0x4(%eax),%edx
  800614:	89 55 14             	mov    %edx,0x14(%ebp)
  800617:	8b 00                	mov    (%eax),%eax
  800619:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061c:	89 c1                	mov    %eax,%ecx
  80061e:	c1 f9 1f             	sar    $0x1f,%ecx
  800621:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800624:	eb 16                	jmp    80063c <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 50 04             	lea    0x4(%eax),%edx
  80062c:	89 55 14             	mov    %edx,0x14(%ebp)
  80062f:	8b 00                	mov    (%eax),%eax
  800631:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800634:	89 c1                	mov    %eax,%ecx
  800636:	c1 f9 1f             	sar    $0x1f,%ecx
  800639:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80063c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800642:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800647:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064b:	79 74                	jns    8006c1 <vprintfmt+0x361>
				putch('-', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	6a 2d                	push   $0x2d
  800653:	ff d6                	call   *%esi
				num = -(long long) num;
  800655:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800658:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80065b:	f7 d8                	neg    %eax
  80065d:	83 d2 00             	adc    $0x0,%edx
  800660:	f7 da                	neg    %edx
  800662:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800665:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80066a:	eb 55                	jmp    8006c1 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066c:	8d 45 14             	lea    0x14(%ebp),%eax
  80066f:	e8 78 fc ff ff       	call   8002ec <getuint>
			base = 10;
  800674:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800679:	eb 46                	jmp    8006c1 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 69 fc ff ff       	call   8002ec <getuint>
      base = 8;
  800683:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800688:	eb 37                	jmp    8006c1 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	53                   	push   %ebx
  80068e:	6a 30                	push   $0x30
  800690:	ff d6                	call   *%esi
			putch('x', putdat);
  800692:	83 c4 08             	add    $0x8,%esp
  800695:	53                   	push   %ebx
  800696:	6a 78                	push   $0x78
  800698:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8d 50 04             	lea    0x4(%eax),%edx
  8006a0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a3:	8b 00                	mov    (%eax),%eax
  8006a5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006aa:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ad:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b2:	eb 0d                	jmp    8006c1 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b7:	e8 30 fc ff ff       	call   8002ec <getuint>
			base = 16;
  8006bc:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c1:	83 ec 0c             	sub    $0xc,%esp
  8006c4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c8:	57                   	push   %edi
  8006c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cc:	51                   	push   %ecx
  8006cd:	52                   	push   %edx
  8006ce:	50                   	push   %eax
  8006cf:	89 da                	mov    %ebx,%edx
  8006d1:	89 f0                	mov    %esi,%eax
  8006d3:	e8 65 fb ff ff       	call   80023d <printnum>
			break;
  8006d8:	83 c4 20             	add    $0x20,%esp
  8006db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006de:	e9 ae fc ff ff       	jmp    800391 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	53                   	push   %ebx
  8006e7:	51                   	push   %ecx
  8006e8:	ff d6                	call   *%esi
			break;
  8006ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f0:	e9 9c fc ff ff       	jmp    800391 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f5:	83 fa 01             	cmp    $0x1,%edx
  8006f8:	7e 0d                	jle    800707 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8d 50 08             	lea    0x8(%eax),%edx
  800700:	89 55 14             	mov    %edx,0x14(%ebp)
  800703:	8b 00                	mov    (%eax),%eax
  800705:	eb 1c                	jmp    800723 <vprintfmt+0x3c3>
	else if (lflag)
  800707:	85 d2                	test   %edx,%edx
  800709:	74 0d                	je     800718 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  80070b:	8b 45 14             	mov    0x14(%ebp),%eax
  80070e:	8d 50 04             	lea    0x4(%eax),%edx
  800711:	89 55 14             	mov    %edx,0x14(%ebp)
  800714:	8b 00                	mov    (%eax),%eax
  800716:	eb 0b                	jmp    800723 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8d 50 04             	lea    0x4(%eax),%edx
  80071e:	89 55 14             	mov    %edx,0x14(%ebp)
  800721:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  800723:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800728:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  80072b:	e9 61 fc ff ff       	jmp    800391 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	53                   	push   %ebx
  800734:	6a 25                	push   $0x25
  800736:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	eb 03                	jmp    800740 <vprintfmt+0x3e0>
  80073d:	83 ef 01             	sub    $0x1,%edi
  800740:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800744:	75 f7                	jne    80073d <vprintfmt+0x3dd>
  800746:	e9 46 fc ff ff       	jmp    800391 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  80074b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074e:	5b                   	pop    %ebx
  80074f:	5e                   	pop    %esi
  800750:	5f                   	pop    %edi
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	83 ec 18             	sub    $0x18,%esp
  800759:	8b 45 08             	mov    0x8(%ebp),%eax
  80075c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800762:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800766:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800769:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800770:	85 c0                	test   %eax,%eax
  800772:	74 26                	je     80079a <vsnprintf+0x47>
  800774:	85 d2                	test   %edx,%edx
  800776:	7e 22                	jle    80079a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800778:	ff 75 14             	pushl  0x14(%ebp)
  80077b:	ff 75 10             	pushl  0x10(%ebp)
  80077e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800781:	50                   	push   %eax
  800782:	68 26 03 80 00       	push   $0x800326
  800787:	e8 d4 fb ff ff       	call   800360 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800792:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800795:	83 c4 10             	add    $0x10,%esp
  800798:	eb 05                	jmp    80079f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079f:	c9                   	leave  
  8007a0:	c3                   	ret    

008007a1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007aa:	50                   	push   %eax
  8007ab:	ff 75 10             	pushl  0x10(%ebp)
  8007ae:	ff 75 0c             	pushl  0xc(%ebp)
  8007b1:	ff 75 08             	pushl  0x8(%ebp)
  8007b4:	e8 9a ff ff ff       	call   800753 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c6:	eb 03                	jmp    8007cb <strlen+0x10>
		n++;
  8007c8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cf:	75 f7                	jne    8007c8 <strlen+0xd>
		n++;
	return n;
}
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e1:	eb 03                	jmp    8007e6 <strnlen+0x13>
		n++;
  8007e3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e6:	39 c2                	cmp    %eax,%edx
  8007e8:	74 08                	je     8007f2 <strnlen+0x1f>
  8007ea:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ee:	75 f3                	jne    8007e3 <strnlen+0x10>
  8007f0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	53                   	push   %ebx
  8007f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fe:	89 c2                	mov    %eax,%edx
  800800:	83 c2 01             	add    $0x1,%edx
  800803:	83 c1 01             	add    $0x1,%ecx
  800806:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80080a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080d:	84 db                	test   %bl,%bl
  80080f:	75 ef                	jne    800800 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800811:	5b                   	pop    %ebx
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	53                   	push   %ebx
  800818:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081b:	53                   	push   %ebx
  80081c:	e8 9a ff ff ff       	call   8007bb <strlen>
  800821:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800824:	ff 75 0c             	pushl  0xc(%ebp)
  800827:	01 d8                	add    %ebx,%eax
  800829:	50                   	push   %eax
  80082a:	e8 c5 ff ff ff       	call   8007f4 <strcpy>
	return dst;
}
  80082f:	89 d8                	mov    %ebx,%eax
  800831:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800834:	c9                   	leave  
  800835:	c3                   	ret    

00800836 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	56                   	push   %esi
  80083a:	53                   	push   %ebx
  80083b:	8b 75 08             	mov    0x8(%ebp),%esi
  80083e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800841:	89 f3                	mov    %esi,%ebx
  800843:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800846:	89 f2                	mov    %esi,%edx
  800848:	eb 0f                	jmp    800859 <strncpy+0x23>
		*dst++ = *src;
  80084a:	83 c2 01             	add    $0x1,%edx
  80084d:	0f b6 01             	movzbl (%ecx),%eax
  800850:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800853:	80 39 01             	cmpb   $0x1,(%ecx)
  800856:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800859:	39 da                	cmp    %ebx,%edx
  80085b:	75 ed                	jne    80084a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085d:	89 f0                	mov    %esi,%eax
  80085f:	5b                   	pop    %ebx
  800860:	5e                   	pop    %esi
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	56                   	push   %esi
  800867:	53                   	push   %ebx
  800868:	8b 75 08             	mov    0x8(%ebp),%esi
  80086b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086e:	8b 55 10             	mov    0x10(%ebp),%edx
  800871:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800873:	85 d2                	test   %edx,%edx
  800875:	74 21                	je     800898 <strlcpy+0x35>
  800877:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80087b:	89 f2                	mov    %esi,%edx
  80087d:	eb 09                	jmp    800888 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087f:	83 c2 01             	add    $0x1,%edx
  800882:	83 c1 01             	add    $0x1,%ecx
  800885:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800888:	39 c2                	cmp    %eax,%edx
  80088a:	74 09                	je     800895 <strlcpy+0x32>
  80088c:	0f b6 19             	movzbl (%ecx),%ebx
  80088f:	84 db                	test   %bl,%bl
  800891:	75 ec                	jne    80087f <strlcpy+0x1c>
  800893:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800895:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800898:	29 f0                	sub    %esi,%eax
}
  80089a:	5b                   	pop    %ebx
  80089b:	5e                   	pop    %esi
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a7:	eb 06                	jmp    8008af <strcmp+0x11>
		p++, q++;
  8008a9:	83 c1 01             	add    $0x1,%ecx
  8008ac:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008af:	0f b6 01             	movzbl (%ecx),%eax
  8008b2:	84 c0                	test   %al,%al
  8008b4:	74 04                	je     8008ba <strcmp+0x1c>
  8008b6:	3a 02                	cmp    (%edx),%al
  8008b8:	74 ef                	je     8008a9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ba:	0f b6 c0             	movzbl %al,%eax
  8008bd:	0f b6 12             	movzbl (%edx),%edx
  8008c0:	29 d0                	sub    %edx,%eax
}
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	53                   	push   %ebx
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ce:	89 c3                	mov    %eax,%ebx
  8008d0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d3:	eb 06                	jmp    8008db <strncmp+0x17>
		n--, p++, q++;
  8008d5:	83 c0 01             	add    $0x1,%eax
  8008d8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008db:	39 d8                	cmp    %ebx,%eax
  8008dd:	74 15                	je     8008f4 <strncmp+0x30>
  8008df:	0f b6 08             	movzbl (%eax),%ecx
  8008e2:	84 c9                	test   %cl,%cl
  8008e4:	74 04                	je     8008ea <strncmp+0x26>
  8008e6:	3a 0a                	cmp    (%edx),%cl
  8008e8:	74 eb                	je     8008d5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ea:	0f b6 00             	movzbl (%eax),%eax
  8008ed:	0f b6 12             	movzbl (%edx),%edx
  8008f0:	29 d0                	sub    %edx,%eax
  8008f2:	eb 05                	jmp    8008f9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f9:	5b                   	pop    %ebx
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800906:	eb 07                	jmp    80090f <strchr+0x13>
		if (*s == c)
  800908:	38 ca                	cmp    %cl,%dl
  80090a:	74 0f                	je     80091b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090c:	83 c0 01             	add    $0x1,%eax
  80090f:	0f b6 10             	movzbl (%eax),%edx
  800912:	84 d2                	test   %dl,%dl
  800914:	75 f2                	jne    800908 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800927:	eb 03                	jmp    80092c <strfind+0xf>
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092f:	38 ca                	cmp    %cl,%dl
  800931:	74 04                	je     800937 <strfind+0x1a>
  800933:	84 d2                	test   %dl,%dl
  800935:	75 f2                	jne    800929 <strfind+0xc>
			break;
	return (char *) s;
}
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	57                   	push   %edi
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800942:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800945:	85 c9                	test   %ecx,%ecx
  800947:	74 36                	je     80097f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800949:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094f:	75 28                	jne    800979 <memset+0x40>
  800951:	f6 c1 03             	test   $0x3,%cl
  800954:	75 23                	jne    800979 <memset+0x40>
		c &= 0xFF;
  800956:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095a:	89 d3                	mov    %edx,%ebx
  80095c:	c1 e3 08             	shl    $0x8,%ebx
  80095f:	89 d6                	mov    %edx,%esi
  800961:	c1 e6 18             	shl    $0x18,%esi
  800964:	89 d0                	mov    %edx,%eax
  800966:	c1 e0 10             	shl    $0x10,%eax
  800969:	09 f0                	or     %esi,%eax
  80096b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80096d:	89 d8                	mov    %ebx,%eax
  80096f:	09 d0                	or     %edx,%eax
  800971:	c1 e9 02             	shr    $0x2,%ecx
  800974:	fc                   	cld    
  800975:	f3 ab                	rep stos %eax,%es:(%edi)
  800977:	eb 06                	jmp    80097f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800979:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097c:	fc                   	cld    
  80097d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097f:	89 f8                	mov    %edi,%eax
  800981:	5b                   	pop    %ebx
  800982:	5e                   	pop    %esi
  800983:	5f                   	pop    %edi
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	57                   	push   %edi
  80098a:	56                   	push   %esi
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800991:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800994:	39 c6                	cmp    %eax,%esi
  800996:	73 35                	jae    8009cd <memmove+0x47>
  800998:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099b:	39 d0                	cmp    %edx,%eax
  80099d:	73 2e                	jae    8009cd <memmove+0x47>
		s += n;
		d += n;
  80099f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a2:	89 d6                	mov    %edx,%esi
  8009a4:	09 fe                	or     %edi,%esi
  8009a6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ac:	75 13                	jne    8009c1 <memmove+0x3b>
  8009ae:	f6 c1 03             	test   $0x3,%cl
  8009b1:	75 0e                	jne    8009c1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b3:	83 ef 04             	sub    $0x4,%edi
  8009b6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b9:	c1 e9 02             	shr    $0x2,%ecx
  8009bc:	fd                   	std    
  8009bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bf:	eb 09                	jmp    8009ca <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c1:	83 ef 01             	sub    $0x1,%edi
  8009c4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c7:	fd                   	std    
  8009c8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ca:	fc                   	cld    
  8009cb:	eb 1d                	jmp    8009ea <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cd:	89 f2                	mov    %esi,%edx
  8009cf:	09 c2                	or     %eax,%edx
  8009d1:	f6 c2 03             	test   $0x3,%dl
  8009d4:	75 0f                	jne    8009e5 <memmove+0x5f>
  8009d6:	f6 c1 03             	test   $0x3,%cl
  8009d9:	75 0a                	jne    8009e5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009db:	c1 e9 02             	shr    $0x2,%ecx
  8009de:	89 c7                	mov    %eax,%edi
  8009e0:	fc                   	cld    
  8009e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e3:	eb 05                	jmp    8009ea <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e5:	89 c7                	mov    %eax,%edi
  8009e7:	fc                   	cld    
  8009e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ea:	5e                   	pop    %esi
  8009eb:	5f                   	pop    %edi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f1:	ff 75 10             	pushl  0x10(%ebp)
  8009f4:	ff 75 0c             	pushl  0xc(%ebp)
  8009f7:	ff 75 08             	pushl  0x8(%ebp)
  8009fa:	e8 87 ff ff ff       	call   800986 <memmove>
}
  8009ff:	c9                   	leave  
  800a00:	c3                   	ret    

00800a01 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0c:	89 c6                	mov    %eax,%esi
  800a0e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a11:	eb 1a                	jmp    800a2d <memcmp+0x2c>
		if (*s1 != *s2)
  800a13:	0f b6 08             	movzbl (%eax),%ecx
  800a16:	0f b6 1a             	movzbl (%edx),%ebx
  800a19:	38 d9                	cmp    %bl,%cl
  800a1b:	74 0a                	je     800a27 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1d:	0f b6 c1             	movzbl %cl,%eax
  800a20:	0f b6 db             	movzbl %bl,%ebx
  800a23:	29 d8                	sub    %ebx,%eax
  800a25:	eb 0f                	jmp    800a36 <memcmp+0x35>
		s1++, s2++;
  800a27:	83 c0 01             	add    $0x1,%eax
  800a2a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2d:	39 f0                	cmp    %esi,%eax
  800a2f:	75 e2                	jne    800a13 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a36:	5b                   	pop    %ebx
  800a37:	5e                   	pop    %esi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	53                   	push   %ebx
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a41:	89 c1                	mov    %eax,%ecx
  800a43:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a46:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4a:	eb 0a                	jmp    800a56 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4c:	0f b6 10             	movzbl (%eax),%edx
  800a4f:	39 da                	cmp    %ebx,%edx
  800a51:	74 07                	je     800a5a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a53:	83 c0 01             	add    $0x1,%eax
  800a56:	39 c8                	cmp    %ecx,%eax
  800a58:	72 f2                	jb     800a4c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5a:	5b                   	pop    %ebx
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a69:	eb 03                	jmp    800a6e <strtol+0x11>
		s++;
  800a6b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6e:	0f b6 01             	movzbl (%ecx),%eax
  800a71:	3c 20                	cmp    $0x20,%al
  800a73:	74 f6                	je     800a6b <strtol+0xe>
  800a75:	3c 09                	cmp    $0x9,%al
  800a77:	74 f2                	je     800a6b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a79:	3c 2b                	cmp    $0x2b,%al
  800a7b:	75 0a                	jne    800a87 <strtol+0x2a>
		s++;
  800a7d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a80:	bf 00 00 00 00       	mov    $0x0,%edi
  800a85:	eb 11                	jmp    800a98 <strtol+0x3b>
  800a87:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8c:	3c 2d                	cmp    $0x2d,%al
  800a8e:	75 08                	jne    800a98 <strtol+0x3b>
		s++, neg = 1;
  800a90:	83 c1 01             	add    $0x1,%ecx
  800a93:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a98:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9e:	75 15                	jne    800ab5 <strtol+0x58>
  800aa0:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa3:	75 10                	jne    800ab5 <strtol+0x58>
  800aa5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa9:	75 7c                	jne    800b27 <strtol+0xca>
		s += 2, base = 16;
  800aab:	83 c1 02             	add    $0x2,%ecx
  800aae:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab3:	eb 16                	jmp    800acb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab5:	85 db                	test   %ebx,%ebx
  800ab7:	75 12                	jne    800acb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abe:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac1:	75 08                	jne    800acb <strtol+0x6e>
		s++, base = 8;
  800ac3:	83 c1 01             	add    $0x1,%ecx
  800ac6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800acb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad3:	0f b6 11             	movzbl (%ecx),%edx
  800ad6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad9:	89 f3                	mov    %esi,%ebx
  800adb:	80 fb 09             	cmp    $0x9,%bl
  800ade:	77 08                	ja     800ae8 <strtol+0x8b>
			dig = *s - '0';
  800ae0:	0f be d2             	movsbl %dl,%edx
  800ae3:	83 ea 30             	sub    $0x30,%edx
  800ae6:	eb 22                	jmp    800b0a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aeb:	89 f3                	mov    %esi,%ebx
  800aed:	80 fb 19             	cmp    $0x19,%bl
  800af0:	77 08                	ja     800afa <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af2:	0f be d2             	movsbl %dl,%edx
  800af5:	83 ea 57             	sub    $0x57,%edx
  800af8:	eb 10                	jmp    800b0a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800afa:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afd:	89 f3                	mov    %esi,%ebx
  800aff:	80 fb 19             	cmp    $0x19,%bl
  800b02:	77 16                	ja     800b1a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b04:	0f be d2             	movsbl %dl,%edx
  800b07:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b0a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0d:	7d 0b                	jge    800b1a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b0f:	83 c1 01             	add    $0x1,%ecx
  800b12:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b16:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b18:	eb b9                	jmp    800ad3 <strtol+0x76>

	if (endptr)
  800b1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1e:	74 0d                	je     800b2d <strtol+0xd0>
		*endptr = (char *) s;
  800b20:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b23:	89 0e                	mov    %ecx,(%esi)
  800b25:	eb 06                	jmp    800b2d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b27:	85 db                	test   %ebx,%ebx
  800b29:	74 98                	je     800ac3 <strtol+0x66>
  800b2b:	eb 9e                	jmp    800acb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b2d:	89 c2                	mov    %eax,%edx
  800b2f:	f7 da                	neg    %edx
  800b31:	85 ff                	test   %edi,%edi
  800b33:	0f 45 c2             	cmovne %edx,%eax
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b41:	b8 00 00 00 00       	mov    $0x0,%eax
  800b46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b49:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4c:	89 c3                	mov    %eax,%ebx
  800b4e:	89 c7                	mov    %eax,%edi
  800b50:	89 c6                	mov    %eax,%esi
  800b52:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b64:	b8 01 00 00 00       	mov    $0x1,%eax
  800b69:	89 d1                	mov    %edx,%ecx
  800b6b:	89 d3                	mov    %edx,%ebx
  800b6d:	89 d7                	mov    %edx,%edi
  800b6f:	89 d6                	mov    %edx,%esi
  800b71:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
  800b7e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b86:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8e:	89 cb                	mov    %ecx,%ebx
  800b90:	89 cf                	mov    %ecx,%edi
  800b92:	89 ce                	mov    %ecx,%esi
  800b94:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b96:	85 c0                	test   %eax,%eax
  800b98:	7e 17                	jle    800bb1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	50                   	push   %eax
  800b9e:	6a 03                	push   $0x3
  800ba0:	68 44 18 80 00       	push   $0x801844
  800ba5:	6a 23                	push   $0x23
  800ba7:	68 61 18 80 00       	push   $0x801861
  800bac:	e8 9f f5 ff ff       	call   800150 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc4:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc9:	89 d1                	mov    %edx,%ecx
  800bcb:	89 d3                	mov    %edx,%ebx
  800bcd:	89 d7                	mov    %edx,%edi
  800bcf:	89 d6                	mov    %edx,%esi
  800bd1:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800bd3:	5b                   	pop    %ebx
  800bd4:	5e                   	pop    %esi
  800bd5:	5f                   	pop    %edi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <sys_yield>:

void
sys_yield(void)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bde:	ba 00 00 00 00       	mov    $0x0,%edx
  800be3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800be8:	89 d1                	mov    %edx,%ecx
  800bea:	89 d3                	mov    %edx,%ebx
  800bec:	89 d7                	mov    %edx,%edi
  800bee:	89 d6                	mov    %edx,%esi
  800bf0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c00:	be 00 00 00 00       	mov    $0x0,%esi
  800c05:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c13:	89 f7                	mov    %esi,%edi
  800c15:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c17:	85 c0                	test   %eax,%eax
  800c19:	7e 17                	jle    800c32 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1b:	83 ec 0c             	sub    $0xc,%esp
  800c1e:	50                   	push   %eax
  800c1f:	6a 04                	push   $0x4
  800c21:	68 44 18 80 00       	push   $0x801844
  800c26:	6a 23                	push   $0x23
  800c28:	68 61 18 80 00       	push   $0x801861
  800c2d:	e8 1e f5 ff ff       	call   800150 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
  800c40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c43:	b8 05 00 00 00       	mov    $0x5,%eax
  800c48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c51:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c54:	8b 75 18             	mov    0x18(%ebp),%esi
  800c57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	7e 17                	jle    800c74 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	50                   	push   %eax
  800c61:	6a 05                	push   $0x5
  800c63:	68 44 18 80 00       	push   $0x801844
  800c68:	6a 23                	push   $0x23
  800c6a:	68 61 18 80 00       	push   $0x801861
  800c6f:	e8 dc f4 ff ff       	call   800150 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
  800c82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c85:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c92:	8b 55 08             	mov    0x8(%ebp),%edx
  800c95:	89 df                	mov    %ebx,%edi
  800c97:	89 de                	mov    %ebx,%esi
  800c99:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	7e 17                	jle    800cb6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	50                   	push   %eax
  800ca3:	6a 06                	push   $0x6
  800ca5:	68 44 18 80 00       	push   $0x801844
  800caa:	6a 23                	push   $0x23
  800cac:	68 61 18 80 00       	push   $0x801861
  800cb1:	e8 9a f4 ff ff       	call   800150 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccc:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	89 df                	mov    %ebx,%edi
  800cd9:	89 de                	mov    %ebx,%esi
  800cdb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	7e 17                	jle    800cf8 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce1:	83 ec 0c             	sub    $0xc,%esp
  800ce4:	50                   	push   %eax
  800ce5:	6a 08                	push   $0x8
  800ce7:	68 44 18 80 00       	push   $0x801844
  800cec:	6a 23                	push   $0x23
  800cee:	68 61 18 80 00       	push   $0x801861
  800cf3:	e8 58 f4 ff ff       	call   800150 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
  800d06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	89 df                	mov    %ebx,%edi
  800d1b:	89 de                	mov    %ebx,%esi
  800d1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	7e 17                	jle    800d3a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	50                   	push   %eax
  800d27:	6a 09                	push   $0x9
  800d29:	68 44 18 80 00       	push   $0x801844
  800d2e:	6a 23                	push   $0x23
  800d30:	68 61 18 80 00       	push   $0x801861
  800d35:	e8 16 f4 ff ff       	call   800150 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d48:	be 00 00 00 00       	mov    $0x0,%esi
  800d4d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d55:	8b 55 08             	mov    0x8(%ebp),%edx
  800d58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d5e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	57                   	push   %edi
  800d69:	56                   	push   %esi
  800d6a:	53                   	push   %ebx
  800d6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d73:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	89 cb                	mov    %ecx,%ebx
  800d7d:	89 cf                	mov    %ecx,%edi
  800d7f:	89 ce                	mov    %ecx,%esi
  800d81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d83:	85 c0                	test   %eax,%eax
  800d85:	7e 17                	jle    800d9e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d87:	83 ec 0c             	sub    $0xc,%esp
  800d8a:	50                   	push   %eax
  800d8b:	6a 0c                	push   $0xc
  800d8d:	68 44 18 80 00       	push   $0x801844
  800d92:	6a 23                	push   $0x23
  800d94:	68 61 18 80 00       	push   $0x801861
  800d99:	e8 b2 f3 ff ff       	call   800150 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_change_pr>:

int
sys_change_pr(int pr)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dac:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 cb                	mov    %ecx,%ebx
  800dbb:	89 cf                	mov    %ecx,%edi
  800dbd:	89 ce                	mov    %ecx,%esi
  800dbf:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 04             	sub    $0x4,%esp
	int r;
	// LAB 4: Your code here.
	// cprintf("1\n");
	void *addr = (void*) (pn*PGSIZE);
  800dcd:	89 d3                	mov    %edx,%ebx
  800dcf:	c1 e3 0c             	shl    $0xc,%ebx
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800dd2:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800dd9:	f6 c1 02             	test   $0x2,%cl
  800ddc:	75 0c                	jne    800dea <duppage+0x24>
  800dde:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800de5:	f6 c6 08             	test   $0x8,%dh
  800de8:	74 5b                	je     800e45 <duppage+0x7f>
		if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800dea:	83 ec 0c             	sub    $0xc,%esp
  800ded:	68 05 08 00 00       	push   $0x805
  800df2:	53                   	push   %ebx
  800df3:	50                   	push   %eax
  800df4:	53                   	push   %ebx
  800df5:	6a 00                	push   $0x0
  800df7:	e8 3e fe ff ff       	call   800c3a <sys_page_map>
  800dfc:	83 c4 20             	add    $0x20,%esp
  800dff:	85 c0                	test   %eax,%eax
  800e01:	79 14                	jns    800e17 <duppage+0x51>
			panic("2");
  800e03:	83 ec 04             	sub    $0x4,%esp
  800e06:	68 6f 18 80 00       	push   $0x80186f
  800e0b:	6a 49                	push   $0x49
  800e0d:	68 71 18 80 00       	push   $0x801871
  800e12:	e8 39 f3 ff ff       	call   800150 <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800e17:	83 ec 0c             	sub    $0xc,%esp
  800e1a:	68 05 08 00 00       	push   $0x805
  800e1f:	53                   	push   %ebx
  800e20:	6a 00                	push   $0x0
  800e22:	53                   	push   %ebx
  800e23:	6a 00                	push   $0x0
  800e25:	e8 10 fe ff ff       	call   800c3a <sys_page_map>
  800e2a:	83 c4 20             	add    $0x20,%esp
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	79 26                	jns    800e57 <duppage+0x91>
			panic("3");
  800e31:	83 ec 04             	sub    $0x4,%esp
  800e34:	68 7c 18 80 00       	push   $0x80187c
  800e39:	6a 4b                	push   $0x4b
  800e3b:	68 71 18 80 00       	push   $0x801871
  800e40:	e8 0b f3 ff ff       	call   800150 <_panic>
	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800e45:	83 ec 0c             	sub    $0xc,%esp
  800e48:	6a 05                	push   $0x5
  800e4a:	53                   	push   %ebx
  800e4b:	50                   	push   %eax
  800e4c:	53                   	push   %ebx
  800e4d:	6a 00                	push   $0x0
  800e4f:	e8 e6 fd ff ff       	call   800c3a <sys_page_map>
  800e54:	83 c4 20             	add    $0x20,%esp
	// cprintf("2\n");
	return 0;
	panic("duppage not implemented");
}
  800e57:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e5f:	c9                   	leave  
  800e60:	c3                   	ret    

00800e61 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	53                   	push   %ebx
  800e65:	83 ec 04             	sub    $0x4,%esp
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
	// panic("pgfault");
	void *addr = (void *) utf->utf_fault_va;
  800e6b:	8b 02                	mov    (%edx),%eax
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e6d:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e71:	74 2e                	je     800ea1 <pgfault+0x40>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e73:	89 c2                	mov    %eax,%edx
  800e75:	c1 ea 16             	shr    $0x16,%edx
  800e78:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e7f:	f6 c2 01             	test   $0x1,%dl
  800e82:	74 1d                	je     800ea1 <pgfault+0x40>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e84:	89 c2                	mov    %eax,%edx
  800e86:	c1 ea 0c             	shr    $0xc,%edx
  800e89:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
  800e90:	f6 c1 01             	test   $0x1,%cl
  800e93:	74 0c                	je     800ea1 <pgfault+0x40>
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e95:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint: 
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e9c:	f6 c6 08             	test   $0x8,%dh
  800e9f:	75 14                	jne    800eb5 <pgfault+0x54>
			(err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800ea1:	83 ec 04             	sub    $0x4,%esp
  800ea4:	68 7e 18 80 00       	push   $0x80187e
  800ea9:	6a 20                	push   $0x20
  800eab:	68 71 18 80 00       	push   $0x801871
  800eb0:	e8 9b f2 ff ff       	call   800150 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800eb5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eba:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800ebc:	83 ec 04             	sub    $0x4,%esp
  800ebf:	6a 07                	push   $0x7
  800ec1:	68 00 f0 7f 00       	push   $0x7ff000
  800ec6:	6a 00                	push   $0x0
  800ec8:	e8 2a fd ff ff       	call   800bf7 <sys_page_alloc>
  800ecd:	83 c4 10             	add    $0x10,%esp
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	79 14                	jns    800ee8 <pgfault+0x87>
		panic("sys_page_alloc");
  800ed4:	83 ec 04             	sub    $0x4,%esp
  800ed7:	68 90 18 80 00       	push   $0x801890
  800edc:	6a 2c                	push   $0x2c
  800ede:	68 71 18 80 00       	push   $0x801871
  800ee3:	e8 68 f2 ff ff       	call   800150 <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  800ee8:	83 ec 04             	sub    $0x4,%esp
  800eeb:	68 00 10 00 00       	push   $0x1000
  800ef0:	53                   	push   %ebx
  800ef1:	68 00 f0 7f 00       	push   $0x7ff000
  800ef6:	e8 f3 fa ff ff       	call   8009ee <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800efb:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f02:	53                   	push   %ebx
  800f03:	6a 00                	push   $0x0
  800f05:	68 00 f0 7f 00       	push   $0x7ff000
  800f0a:	6a 00                	push   $0x0
  800f0c:	e8 29 fd ff ff       	call   800c3a <sys_page_map>
  800f11:	83 c4 20             	add    $0x20,%esp
  800f14:	85 c0                	test   %eax,%eax
  800f16:	79 14                	jns    800f2c <pgfault+0xcb>
		panic("sys_page_map");
  800f18:	83 ec 04             	sub    $0x4,%esp
  800f1b:	68 9f 18 80 00       	push   $0x80189f
  800f20:	6a 2f                	push   $0x2f
  800f22:	68 71 18 80 00       	push   $0x801871
  800f27:	e8 24 f2 ff ff       	call   800150 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  800f2c:	83 ec 08             	sub    $0x8,%esp
  800f2f:	68 00 f0 7f 00       	push   $0x7ff000
  800f34:	6a 00                	push   $0x0
  800f36:	e8 41 fd ff ff       	call   800c7c <sys_page_unmap>
  800f3b:	83 c4 10             	add    $0x10,%esp
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	79 14                	jns    800f56 <pgfault+0xf5>
		panic("sys_page_unmap");
  800f42:	83 ec 04             	sub    $0x4,%esp
  800f45:	68 ac 18 80 00       	push   $0x8018ac
  800f4a:	6a 31                	push   $0x31
  800f4c:	68 71 18 80 00       	push   $0x801871
  800f51:	e8 fa f1 ff ff       	call   800150 <_panic>
	return;
}
  800f56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f59:	c9                   	leave  
  800f5a:	c3                   	ret    

00800f5b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	57                   	push   %edi
  800f5f:	56                   	push   %esi
  800f60:	53                   	push   %ebx
  800f61:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800f64:	68 61 0e 80 00       	push   $0x800e61
  800f69:	e8 2e 03 00 00       	call   80129c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f6e:	b8 07 00 00 00       	mov    $0x7,%eax
  800f73:	cd 30                	int    $0x30

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800f75:	83 c4 10             	add    $0x10,%esp
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	75 21                	jne    800f9d <fork+0x42>
		// panic("child");
		thisenv = &envs[ENVX(sys_getenvid())];
  800f7c:	e8 38 fc ff ff       	call   800bb9 <sys_getenvid>
  800f81:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f86:	c1 e0 07             	shl    $0x7,%eax
  800f89:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f8e:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f93:	b8 00 00 00 00       	mov    $0x0,%eax
  800f98:	e9 c6 00 00 00       	jmp    801063 <fork+0x108>
  800f9d:	89 c6                	mov    %eax,%esi
  800f9f:	89 c7                	mov    %eax,%edi
	}
	// cprintf("sys_exofork: %x\n", envid);
	if (envid < 0)
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	79 12                	jns    800fb7 <fork+0x5c>
		panic("sys_exofork: %e", envid);
  800fa5:	50                   	push   %eax
  800fa6:	68 bb 18 80 00       	push   $0x8018bb
  800fab:	6a 71                	push   $0x71
  800fad:	68 71 18 80 00       	push   $0x801871
  800fb2:	e8 99 f1 ff ff       	call   800150 <_panic>
  800fb7:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800fbc:	89 d8                	mov    %ebx,%eax
  800fbe:	c1 e8 16             	shr    $0x16,%eax
  800fc1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc8:	a8 01                	test   $0x1,%al
  800fca:	74 22                	je     800fee <fork+0x93>
  800fcc:	89 da                	mov    %ebx,%edx
  800fce:	c1 ea 0c             	shr    $0xc,%edx
  800fd1:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800fd8:	a8 01                	test   $0x1,%al
  800fda:	74 12                	je     800fee <fork+0x93>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800fdc:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800fe3:	a8 04                	test   $0x4,%al
  800fe5:	74 07                	je     800fee <fork+0x93>
			// cprintf("envid: %x, PGNUM: %x, addr: %x\n", envid, PGNUM(addr), addr);
			// if (addr!=0x802000) {
			duppage(envid, PGNUM(addr));
  800fe7:	89 f8                	mov    %edi,%eax
  800fe9:	e8 d8 fd ff ff       	call   800dc6 <duppage>
	}
	// cprintf("sys_exofork: %x\n", envid);
	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800fee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800ff4:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800ffa:	75 c0                	jne    800fbc <fork+0x61>
			// cprintf("%x\n", uvpt[PGNUM(addr)]);
		}
	// panic("faint");


	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  800ffc:	83 ec 04             	sub    $0x4,%esp
  800fff:	6a 07                	push   $0x7
  801001:	68 00 f0 bf ee       	push   $0xeebff000
  801006:	56                   	push   %esi
  801007:	e8 eb fb ff ff       	call   800bf7 <sys_page_alloc>
  80100c:	83 c4 10             	add    $0x10,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	79 17                	jns    80102a <fork+0xcf>
		panic("1");
  801013:	83 ec 04             	sub    $0x4,%esp
  801016:	68 cb 18 80 00       	push   $0x8018cb
  80101b:	68 82 00 00 00       	push   $0x82
  801020:	68 71 18 80 00       	push   $0x801871
  801025:	e8 26 f1 ff ff       	call   800150 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80102a:	83 ec 08             	sub    $0x8,%esp
  80102d:	68 0b 13 80 00       	push   $0x80130b
  801032:	56                   	push   %esi
  801033:	e8 c8 fc ff ff       	call   800d00 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801038:	83 c4 08             	add    $0x8,%esp
  80103b:	6a 02                	push   $0x2
  80103d:	56                   	push   %esi
  80103e:	e8 7b fc ff ff       	call   800cbe <sys_env_set_status>
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	79 17                	jns    801061 <fork+0x106>
		panic("sys_env_set_status");
  80104a:	83 ec 04             	sub    $0x4,%esp
  80104d:	68 cd 18 80 00       	push   $0x8018cd
  801052:	68 87 00 00 00       	push   $0x87
  801057:	68 71 18 80 00       	push   $0x801871
  80105c:	e8 ef f0 ff ff       	call   800150 <_panic>

	return envid;
  801061:	89 f0                	mov    %esi,%eax
	panic("fork not implemented");
}
  801063:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801066:	5b                   	pop    %ebx
  801067:	5e                   	pop    %esi
  801068:	5f                   	pop    %edi
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <pfork>:

envid_t
pfork(int pr)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	57                   	push   %edi
  80106f:	56                   	push   %esi
  801070:	53                   	push   %ebx
  801071:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  801074:	68 61 0e 80 00       	push   $0x800e61
  801079:	e8 1e 02 00 00       	call   80129c <set_pgfault_handler>
  80107e:	b8 07 00 00 00       	mov    $0x7,%eax
  801083:	cd 30                	int    $0x30

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  801085:	83 c4 10             	add    $0x10,%esp
  801088:	85 c0                	test   %eax,%eax
  80108a:	75 2f                	jne    8010bb <pfork+0x50>
		thisenv = &envs[ENVX(sys_getenvid())];
  80108c:	e8 28 fb ff ff       	call   800bb9 <sys_getenvid>
  801091:	25 ff 03 00 00       	and    $0x3ff,%eax
  801096:	c1 e0 07             	shl    $0x7,%eax
  801099:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80109e:	a3 04 20 80 00       	mov    %eax,0x802004
		sys_change_pr(pr);
  8010a3:	83 ec 0c             	sub    $0xc,%esp
  8010a6:	ff 75 08             	pushl  0x8(%ebp)
  8010a9:	e8 f8 fc ff ff       	call   800da6 <sys_change_pr>
		return 0;
  8010ae:	83 c4 10             	add    $0x10,%esp
  8010b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b6:	e9 c9 00 00 00       	jmp    801184 <pfork+0x119>
  8010bb:	89 c6                	mov    %eax,%esi
  8010bd:	89 c7                	mov    %eax,%edi
	}

	if (envid < 0)
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	79 15                	jns    8010d8 <pfork+0x6d>
		panic("sys_exofork: %e", envid);
  8010c3:	50                   	push   %eax
  8010c4:	68 bb 18 80 00       	push   $0x8018bb
  8010c9:	68 9c 00 00 00       	push   $0x9c
  8010ce:	68 71 18 80 00       	push   $0x801871
  8010d3:	e8 78 f0 ff ff       	call   800150 <_panic>
  8010d8:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  8010dd:	89 d8                	mov    %ebx,%eax
  8010df:	c1 e8 16             	shr    $0x16,%eax
  8010e2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e9:	a8 01                	test   $0x1,%al
  8010eb:	74 22                	je     80110f <pfork+0xa4>
  8010ed:	89 da                	mov    %ebx,%edx
  8010ef:	c1 ea 0c             	shr    $0xc,%edx
  8010f2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8010f9:	a8 01                	test   $0x1,%al
  8010fb:	74 12                	je     80110f <pfork+0xa4>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  8010fd:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801104:	a8 04                	test   $0x4,%al
  801106:	74 07                	je     80110f <pfork+0xa4>
			duppage(envid, PGNUM(addr));
  801108:	89 f8                	mov    %edi,%eax
  80110a:	e8 b7 fc ff ff       	call   800dc6 <duppage>
	}

	if (envid < 0)
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  80110f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801115:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80111b:	75 c0                	jne    8010dd <pfork+0x72>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80111d:	83 ec 04             	sub    $0x4,%esp
  801120:	6a 07                	push   $0x7
  801122:	68 00 f0 bf ee       	push   $0xeebff000
  801127:	56                   	push   %esi
  801128:	e8 ca fa ff ff       	call   800bf7 <sys_page_alloc>
  80112d:	83 c4 10             	add    $0x10,%esp
  801130:	85 c0                	test   %eax,%eax
  801132:	79 17                	jns    80114b <pfork+0xe0>
		panic("1");
  801134:	83 ec 04             	sub    $0x4,%esp
  801137:	68 cb 18 80 00       	push   $0x8018cb
  80113c:	68 a5 00 00 00       	push   $0xa5
  801141:	68 71 18 80 00       	push   $0x801871
  801146:	e8 05 f0 ff ff       	call   800150 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80114b:	83 ec 08             	sub    $0x8,%esp
  80114e:	68 0b 13 80 00       	push   $0x80130b
  801153:	56                   	push   %esi
  801154:	e8 a7 fb ff ff       	call   800d00 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801159:	83 c4 08             	add    $0x8,%esp
  80115c:	6a 02                	push   $0x2
  80115e:	56                   	push   %esi
  80115f:	e8 5a fb ff ff       	call   800cbe <sys_env_set_status>
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	85 c0                	test   %eax,%eax
  801169:	79 17                	jns    801182 <pfork+0x117>
		panic("sys_env_set_status");
  80116b:	83 ec 04             	sub    $0x4,%esp
  80116e:	68 cd 18 80 00       	push   $0x8018cd
  801173:	68 aa 00 00 00       	push   $0xaa
  801178:	68 71 18 80 00       	push   $0x801871
  80117d:	e8 ce ef ff ff       	call   800150 <_panic>

	return envid;
  801182:	89 f0                	mov    %esi,%eax
	panic("fork not implemented");
}
  801184:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801187:	5b                   	pop    %ebx
  801188:	5e                   	pop    %esi
  801189:	5f                   	pop    %edi
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <sfork>:

// Challenge!
int
sfork(void)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801192:	68 e0 18 80 00       	push   $0x8018e0
  801197:	68 b4 00 00 00       	push   $0xb4
  80119c:	68 71 18 80 00       	push   $0x801871
  8011a1:	e8 aa ef ff ff       	call   800150 <_panic>

008011a6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	56                   	push   %esi
  8011aa:	53                   	push   %ebx
  8011ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  8011b4:	85 f6                	test   %esi,%esi
  8011b6:	74 06                	je     8011be <ipc_recv+0x18>
  8011b8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  8011be:	85 db                	test   %ebx,%ebx
  8011c0:	74 06                	je     8011c8 <ipc_recv+0x22>
  8011c2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8011cf:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  8011d2:	83 ec 0c             	sub    $0xc,%esp
  8011d5:	50                   	push   %eax
  8011d6:	e8 8a fb ff ff       	call   800d65 <sys_ipc_recv>
	if (ret) return ret;
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	75 24                	jne    801206 <ipc_recv+0x60>
	if (from_env_store)
  8011e2:	85 f6                	test   %esi,%esi
  8011e4:	74 0a                	je     8011f0 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  8011e6:	a1 04 20 80 00       	mov    0x802004,%eax
  8011eb:	8b 40 74             	mov    0x74(%eax),%eax
  8011ee:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  8011f0:	85 db                	test   %ebx,%ebx
  8011f2:	74 0a                	je     8011fe <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  8011f4:	a1 04 20 80 00       	mov    0x802004,%eax
  8011f9:	8b 40 78             	mov    0x78(%eax),%eax
  8011fc:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8011fe:	a1 04 20 80 00       	mov    0x802004,%eax
  801203:	8b 40 70             	mov    0x70(%eax),%eax
}
  801206:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801209:	5b                   	pop    %ebx
  80120a:	5e                   	pop    %esi
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	57                   	push   %edi
  801211:	56                   	push   %esi
  801212:	53                   	push   %ebx
  801213:	83 ec 0c             	sub    $0xc,%esp
  801216:	8b 7d 08             	mov    0x8(%ebp),%edi
  801219:	8b 75 0c             	mov    0xc(%ebp),%esi
  80121c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  80121f:	85 db                	test   %ebx,%ebx
  801221:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801226:	0f 44 d8             	cmove  %eax,%ebx
  801229:	eb 1c                	jmp    801247 <ipc_send+0x3a>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  80122b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80122e:	74 12                	je     801242 <ipc_send+0x35>
  801230:	50                   	push   %eax
  801231:	68 f6 18 80 00       	push   $0x8018f6
  801236:	6a 36                	push   $0x36
  801238:	68 0d 19 80 00       	push   $0x80190d
  80123d:	e8 0e ef ff ff       	call   800150 <_panic>
		sys_yield();
  801242:	e8 91 f9 ff ff       	call   800bd8 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801247:	ff 75 14             	pushl  0x14(%ebp)
  80124a:	53                   	push   %ebx
  80124b:	56                   	push   %esi
  80124c:	57                   	push   %edi
  80124d:	e8 f0 fa ff ff       	call   800d42 <sys_ipc_try_send>
		if (ret == 0) break;
  801252:	83 c4 10             	add    $0x10,%esp
  801255:	85 c0                	test   %eax,%eax
  801257:	75 d2                	jne    80122b <ipc_send+0x1e>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
		sys_yield();
	}
}
  801259:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125c:	5b                   	pop    %ebx
  80125d:	5e                   	pop    %esi
  80125e:	5f                   	pop    %edi
  80125f:	5d                   	pop    %ebp
  801260:	c3                   	ret    

00801261 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801267:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80126c:	89 c2                	mov    %eax,%edx
  80126e:	c1 e2 07             	shl    $0x7,%edx
  801271:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801277:	8b 52 50             	mov    0x50(%edx),%edx
  80127a:	39 ca                	cmp    %ecx,%edx
  80127c:	75 0d                	jne    80128b <ipc_find_env+0x2a>
			return envs[i].env_id;
  80127e:	c1 e0 07             	shl    $0x7,%eax
  801281:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801286:	8b 40 48             	mov    0x48(%eax),%eax
  801289:	eb 0f                	jmp    80129a <ipc_find_env+0x39>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80128b:	83 c0 01             	add    $0x1,%eax
  80128e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801293:	75 d7                	jne    80126c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801295:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	83 ec 08             	sub    $0x8,%esp
	// int r;

	if (_pgfault_handler == 0) {
  8012a2:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8012a9:	75 2c                	jne    8012d7 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 4: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8012ab:	83 ec 04             	sub    $0x4,%esp
  8012ae:	6a 07                	push   $0x7
  8012b0:	68 00 f0 bf ee       	push   $0xeebff000
  8012b5:	6a 00                	push   $0x0
  8012b7:	e8 3b f9 ff ff       	call   800bf7 <sys_page_alloc>
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	79 14                	jns    8012d7 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  8012c3:	83 ec 04             	sub    $0x4,%esp
  8012c6:	68 18 19 80 00       	push   $0x801918
  8012cb:	6a 21                	push   $0x21
  8012cd:	68 7c 19 80 00       	push   $0x80197c
  8012d2:	e8 79 ee ff ff       	call   800150 <_panic>
	}
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012da:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8012df:	83 ec 08             	sub    $0x8,%esp
  8012e2:	68 0b 13 80 00       	push   $0x80130b
  8012e7:	6a 00                	push   $0x0
  8012e9:	e8 12 fa ff ff       	call   800d00 <sys_env_set_pgfault_upcall>
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	79 14                	jns    801309 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8012f5:	83 ec 04             	sub    $0x4,%esp
  8012f8:	68 44 19 80 00       	push   $0x801944
  8012fd:	6a 26                	push   $0x26
  8012ff:	68 7c 19 80 00       	push   $0x80197c
  801304:	e8 47 ee ff ff       	call   800150 <_panic>
}
  801309:	c9                   	leave  
  80130a:	c3                   	ret    

0080130b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80130b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80130c:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801311:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801313:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %edx #trap-time eip
  801316:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4, 0x30(%esp)
  80131a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax #trap-time esp-4
  80131f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx, (%eax)
  801323:	89 10                	mov    %edx,(%eax)
	addl $0x8, %esp
  801325:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801328:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp #eip
  801329:	83 c4 04             	add    $0x4,%esp
	popfl
  80132c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80132d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80132e:	c3                   	ret    
  80132f:	90                   	nop

00801330 <__udivdi3>:
  801330:	55                   	push   %ebp
  801331:	57                   	push   %edi
  801332:	56                   	push   %esi
  801333:	53                   	push   %ebx
  801334:	83 ec 1c             	sub    $0x1c,%esp
  801337:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80133b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80133f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801343:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801347:	85 f6                	test   %esi,%esi
  801349:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80134d:	89 ca                	mov    %ecx,%edx
  80134f:	89 f8                	mov    %edi,%eax
  801351:	75 3d                	jne    801390 <__udivdi3+0x60>
  801353:	39 cf                	cmp    %ecx,%edi
  801355:	0f 87 c5 00 00 00    	ja     801420 <__udivdi3+0xf0>
  80135b:	85 ff                	test   %edi,%edi
  80135d:	89 fd                	mov    %edi,%ebp
  80135f:	75 0b                	jne    80136c <__udivdi3+0x3c>
  801361:	b8 01 00 00 00       	mov    $0x1,%eax
  801366:	31 d2                	xor    %edx,%edx
  801368:	f7 f7                	div    %edi
  80136a:	89 c5                	mov    %eax,%ebp
  80136c:	89 c8                	mov    %ecx,%eax
  80136e:	31 d2                	xor    %edx,%edx
  801370:	f7 f5                	div    %ebp
  801372:	89 c1                	mov    %eax,%ecx
  801374:	89 d8                	mov    %ebx,%eax
  801376:	89 cf                	mov    %ecx,%edi
  801378:	f7 f5                	div    %ebp
  80137a:	89 c3                	mov    %eax,%ebx
  80137c:	89 d8                	mov    %ebx,%eax
  80137e:	89 fa                	mov    %edi,%edx
  801380:	83 c4 1c             	add    $0x1c,%esp
  801383:	5b                   	pop    %ebx
  801384:	5e                   	pop    %esi
  801385:	5f                   	pop    %edi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    
  801388:	90                   	nop
  801389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801390:	39 ce                	cmp    %ecx,%esi
  801392:	77 74                	ja     801408 <__udivdi3+0xd8>
  801394:	0f bd fe             	bsr    %esi,%edi
  801397:	83 f7 1f             	xor    $0x1f,%edi
  80139a:	0f 84 98 00 00 00    	je     801438 <__udivdi3+0x108>
  8013a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8013a5:	89 f9                	mov    %edi,%ecx
  8013a7:	89 c5                	mov    %eax,%ebp
  8013a9:	29 fb                	sub    %edi,%ebx
  8013ab:	d3 e6                	shl    %cl,%esi
  8013ad:	89 d9                	mov    %ebx,%ecx
  8013af:	d3 ed                	shr    %cl,%ebp
  8013b1:	89 f9                	mov    %edi,%ecx
  8013b3:	d3 e0                	shl    %cl,%eax
  8013b5:	09 ee                	or     %ebp,%esi
  8013b7:	89 d9                	mov    %ebx,%ecx
  8013b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013bd:	89 d5                	mov    %edx,%ebp
  8013bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013c3:	d3 ed                	shr    %cl,%ebp
  8013c5:	89 f9                	mov    %edi,%ecx
  8013c7:	d3 e2                	shl    %cl,%edx
  8013c9:	89 d9                	mov    %ebx,%ecx
  8013cb:	d3 e8                	shr    %cl,%eax
  8013cd:	09 c2                	or     %eax,%edx
  8013cf:	89 d0                	mov    %edx,%eax
  8013d1:	89 ea                	mov    %ebp,%edx
  8013d3:	f7 f6                	div    %esi
  8013d5:	89 d5                	mov    %edx,%ebp
  8013d7:	89 c3                	mov    %eax,%ebx
  8013d9:	f7 64 24 0c          	mull   0xc(%esp)
  8013dd:	39 d5                	cmp    %edx,%ebp
  8013df:	72 10                	jb     8013f1 <__udivdi3+0xc1>
  8013e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8013e5:	89 f9                	mov    %edi,%ecx
  8013e7:	d3 e6                	shl    %cl,%esi
  8013e9:	39 c6                	cmp    %eax,%esi
  8013eb:	73 07                	jae    8013f4 <__udivdi3+0xc4>
  8013ed:	39 d5                	cmp    %edx,%ebp
  8013ef:	75 03                	jne    8013f4 <__udivdi3+0xc4>
  8013f1:	83 eb 01             	sub    $0x1,%ebx
  8013f4:	31 ff                	xor    %edi,%edi
  8013f6:	89 d8                	mov    %ebx,%eax
  8013f8:	89 fa                	mov    %edi,%edx
  8013fa:	83 c4 1c             	add    $0x1c,%esp
  8013fd:	5b                   	pop    %ebx
  8013fe:	5e                   	pop    %esi
  8013ff:	5f                   	pop    %edi
  801400:	5d                   	pop    %ebp
  801401:	c3                   	ret    
  801402:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801408:	31 ff                	xor    %edi,%edi
  80140a:	31 db                	xor    %ebx,%ebx
  80140c:	89 d8                	mov    %ebx,%eax
  80140e:	89 fa                	mov    %edi,%edx
  801410:	83 c4 1c             	add    $0x1c,%esp
  801413:	5b                   	pop    %ebx
  801414:	5e                   	pop    %esi
  801415:	5f                   	pop    %edi
  801416:	5d                   	pop    %ebp
  801417:	c3                   	ret    
  801418:	90                   	nop
  801419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801420:	89 d8                	mov    %ebx,%eax
  801422:	f7 f7                	div    %edi
  801424:	31 ff                	xor    %edi,%edi
  801426:	89 c3                	mov    %eax,%ebx
  801428:	89 d8                	mov    %ebx,%eax
  80142a:	89 fa                	mov    %edi,%edx
  80142c:	83 c4 1c             	add    $0x1c,%esp
  80142f:	5b                   	pop    %ebx
  801430:	5e                   	pop    %esi
  801431:	5f                   	pop    %edi
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    
  801434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801438:	39 ce                	cmp    %ecx,%esi
  80143a:	72 0c                	jb     801448 <__udivdi3+0x118>
  80143c:	31 db                	xor    %ebx,%ebx
  80143e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801442:	0f 87 34 ff ff ff    	ja     80137c <__udivdi3+0x4c>
  801448:	bb 01 00 00 00       	mov    $0x1,%ebx
  80144d:	e9 2a ff ff ff       	jmp    80137c <__udivdi3+0x4c>
  801452:	66 90                	xchg   %ax,%ax
  801454:	66 90                	xchg   %ax,%ax
  801456:	66 90                	xchg   %ax,%ax
  801458:	66 90                	xchg   %ax,%ax
  80145a:	66 90                	xchg   %ax,%ax
  80145c:	66 90                	xchg   %ax,%ax
  80145e:	66 90                	xchg   %ax,%ax

00801460 <__umoddi3>:
  801460:	55                   	push   %ebp
  801461:	57                   	push   %edi
  801462:	56                   	push   %esi
  801463:	53                   	push   %ebx
  801464:	83 ec 1c             	sub    $0x1c,%esp
  801467:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80146b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80146f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801473:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801477:	85 d2                	test   %edx,%edx
  801479:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80147d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801481:	89 f3                	mov    %esi,%ebx
  801483:	89 3c 24             	mov    %edi,(%esp)
  801486:	89 74 24 04          	mov    %esi,0x4(%esp)
  80148a:	75 1c                	jne    8014a8 <__umoddi3+0x48>
  80148c:	39 f7                	cmp    %esi,%edi
  80148e:	76 50                	jbe    8014e0 <__umoddi3+0x80>
  801490:	89 c8                	mov    %ecx,%eax
  801492:	89 f2                	mov    %esi,%edx
  801494:	f7 f7                	div    %edi
  801496:	89 d0                	mov    %edx,%eax
  801498:	31 d2                	xor    %edx,%edx
  80149a:	83 c4 1c             	add    $0x1c,%esp
  80149d:	5b                   	pop    %ebx
  80149e:	5e                   	pop    %esi
  80149f:	5f                   	pop    %edi
  8014a0:	5d                   	pop    %ebp
  8014a1:	c3                   	ret    
  8014a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014a8:	39 f2                	cmp    %esi,%edx
  8014aa:	89 d0                	mov    %edx,%eax
  8014ac:	77 52                	ja     801500 <__umoddi3+0xa0>
  8014ae:	0f bd ea             	bsr    %edx,%ebp
  8014b1:	83 f5 1f             	xor    $0x1f,%ebp
  8014b4:	75 5a                	jne    801510 <__umoddi3+0xb0>
  8014b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8014ba:	0f 82 e0 00 00 00    	jb     8015a0 <__umoddi3+0x140>
  8014c0:	39 0c 24             	cmp    %ecx,(%esp)
  8014c3:	0f 86 d7 00 00 00    	jbe    8015a0 <__umoddi3+0x140>
  8014c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8014cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8014d1:	83 c4 1c             	add    $0x1c,%esp
  8014d4:	5b                   	pop    %ebx
  8014d5:	5e                   	pop    %esi
  8014d6:	5f                   	pop    %edi
  8014d7:	5d                   	pop    %ebp
  8014d8:	c3                   	ret    
  8014d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014e0:	85 ff                	test   %edi,%edi
  8014e2:	89 fd                	mov    %edi,%ebp
  8014e4:	75 0b                	jne    8014f1 <__umoddi3+0x91>
  8014e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014eb:	31 d2                	xor    %edx,%edx
  8014ed:	f7 f7                	div    %edi
  8014ef:	89 c5                	mov    %eax,%ebp
  8014f1:	89 f0                	mov    %esi,%eax
  8014f3:	31 d2                	xor    %edx,%edx
  8014f5:	f7 f5                	div    %ebp
  8014f7:	89 c8                	mov    %ecx,%eax
  8014f9:	f7 f5                	div    %ebp
  8014fb:	89 d0                	mov    %edx,%eax
  8014fd:	eb 99                	jmp    801498 <__umoddi3+0x38>
  8014ff:	90                   	nop
  801500:	89 c8                	mov    %ecx,%eax
  801502:	89 f2                	mov    %esi,%edx
  801504:	83 c4 1c             	add    $0x1c,%esp
  801507:	5b                   	pop    %ebx
  801508:	5e                   	pop    %esi
  801509:	5f                   	pop    %edi
  80150a:	5d                   	pop    %ebp
  80150b:	c3                   	ret    
  80150c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801510:	8b 34 24             	mov    (%esp),%esi
  801513:	bf 20 00 00 00       	mov    $0x20,%edi
  801518:	89 e9                	mov    %ebp,%ecx
  80151a:	29 ef                	sub    %ebp,%edi
  80151c:	d3 e0                	shl    %cl,%eax
  80151e:	89 f9                	mov    %edi,%ecx
  801520:	89 f2                	mov    %esi,%edx
  801522:	d3 ea                	shr    %cl,%edx
  801524:	89 e9                	mov    %ebp,%ecx
  801526:	09 c2                	or     %eax,%edx
  801528:	89 d8                	mov    %ebx,%eax
  80152a:	89 14 24             	mov    %edx,(%esp)
  80152d:	89 f2                	mov    %esi,%edx
  80152f:	d3 e2                	shl    %cl,%edx
  801531:	89 f9                	mov    %edi,%ecx
  801533:	89 54 24 04          	mov    %edx,0x4(%esp)
  801537:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80153b:	d3 e8                	shr    %cl,%eax
  80153d:	89 e9                	mov    %ebp,%ecx
  80153f:	89 c6                	mov    %eax,%esi
  801541:	d3 e3                	shl    %cl,%ebx
  801543:	89 f9                	mov    %edi,%ecx
  801545:	89 d0                	mov    %edx,%eax
  801547:	d3 e8                	shr    %cl,%eax
  801549:	89 e9                	mov    %ebp,%ecx
  80154b:	09 d8                	or     %ebx,%eax
  80154d:	89 d3                	mov    %edx,%ebx
  80154f:	89 f2                	mov    %esi,%edx
  801551:	f7 34 24             	divl   (%esp)
  801554:	89 d6                	mov    %edx,%esi
  801556:	d3 e3                	shl    %cl,%ebx
  801558:	f7 64 24 04          	mull   0x4(%esp)
  80155c:	39 d6                	cmp    %edx,%esi
  80155e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801562:	89 d1                	mov    %edx,%ecx
  801564:	89 c3                	mov    %eax,%ebx
  801566:	72 08                	jb     801570 <__umoddi3+0x110>
  801568:	75 11                	jne    80157b <__umoddi3+0x11b>
  80156a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80156e:	73 0b                	jae    80157b <__umoddi3+0x11b>
  801570:	2b 44 24 04          	sub    0x4(%esp),%eax
  801574:	1b 14 24             	sbb    (%esp),%edx
  801577:	89 d1                	mov    %edx,%ecx
  801579:	89 c3                	mov    %eax,%ebx
  80157b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80157f:	29 da                	sub    %ebx,%edx
  801581:	19 ce                	sbb    %ecx,%esi
  801583:	89 f9                	mov    %edi,%ecx
  801585:	89 f0                	mov    %esi,%eax
  801587:	d3 e0                	shl    %cl,%eax
  801589:	89 e9                	mov    %ebp,%ecx
  80158b:	d3 ea                	shr    %cl,%edx
  80158d:	89 e9                	mov    %ebp,%ecx
  80158f:	d3 ee                	shr    %cl,%esi
  801591:	09 d0                	or     %edx,%eax
  801593:	89 f2                	mov    %esi,%edx
  801595:	83 c4 1c             	add    $0x1c,%esp
  801598:	5b                   	pop    %ebx
  801599:	5e                   	pop    %esi
  80159a:	5f                   	pop    %edi
  80159b:	5d                   	pop    %ebp
  80159c:	c3                   	ret    
  80159d:	8d 76 00             	lea    0x0(%esi),%esi
  8015a0:	29 f9                	sub    %edi,%ecx
  8015a2:	19 d6                	sbb    %edx,%esi
  8015a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015ac:	e9 18 ff ff ff       	jmp    8014c9 <__umoddi3+0x69>
