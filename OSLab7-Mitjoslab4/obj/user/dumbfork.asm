
obj/user/dumbfork：     文件格式 elf32-i386


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
  80002c:	e8 d9 01 00 00       	call   80020a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	// sys_page_alloc(envid_t envid, void *va, int perm)
	// sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
	// sys_page_unmap(envid_t envid, void *va)
	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 bf 0c 00 00       	call   800d09 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 80 11 80 00       	push   $0x801180
  800057:	6a 22                	push   $0x22
  800059:	68 93 11 80 00       	push   $0x801193
  80005e:	e8 ff 01 00 00       	call   800262 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 d6 0c 00 00       	call   800d4c <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 a3 11 80 00       	push   $0x8011a3
  800083:	6a 24                	push   $0x24
  800085:	68 93 11 80 00       	push   $0x801193
  80008a:	e8 d3 01 00 00       	call   800262 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 f6 09 00 00       	call   800a98 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 dd 0c 00 00       	call   800d8e <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 b4 11 80 00       	push   $0x8011b4
  8000be:	6a 27                	push   $0x27
  8000c0:	68 93 11 80 00       	push   $0x801193
  8000c5:	e8 98 01 00 00       	call   800262 <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 18             	sub    $0x18,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
  8000e2:	89 c6                	mov    %eax,%esi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	cprintf("envid: %x\n", envid);
  8000e4:	50                   	push   %eax
  8000e5:	68 c7 11 80 00       	push   $0x8011c7
  8000ea:	e8 4c 02 00 00       	call   80033b <cprintf>
	if (envid < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 db                	test   %ebx,%ebx
  8000f4:	79 12                	jns    800108 <dumbfork+0x37>
		panic("sys_exofork: %e", envid);
  8000f6:	53                   	push   %ebx
  8000f7:	68 d2 11 80 00       	push   $0x8011d2
  8000fc:	6a 3a                	push   $0x3a
  8000fe:	68 93 11 80 00       	push   $0x801193
  800103:	e8 5a 01 00 00       	call   800262 <_panic>
	if (envid == 0) {
  800108:	85 db                	test   %ebx,%ebx
  80010a:	75 1e                	jne    80012a <dumbfork+0x59>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  80010c:	e8 ba 0b 00 00       	call   800ccb <sys_getenvid>
  800111:	25 ff 03 00 00       	and    $0x3ff,%eax
  800116:	c1 e0 07             	shl    $0x7,%eax
  800119:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011e:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800123:	b8 00 00 00 00       	mov    $0x0,%eax
  800128:	eb 70                	jmp    80019a <dumbfork+0xc9>
	}

	cprintf("parent\n");
  80012a:	83 ec 0c             	sub    $0xc,%esp
  80012d:	68 e2 11 80 00       	push   $0x8011e2
  800132:	e8 04 02 00 00       	call   80033b <cprintf>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800137:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	eb 14                	jmp    800157 <dumbfork+0x86>
		duppage(envid, addr);
  800143:	83 ec 08             	sub    $0x8,%esp
  800146:	52                   	push   %edx
  800147:	56                   	push   %esi
  800148:	e8 e6 fe ff ff       	call   800033 <duppage>

	cprintf("parent\n");
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80014d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800154:	83 c4 10             	add    $0x10,%esp
  800157:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80015a:	81 fa 0c 20 80 00    	cmp    $0x80200c,%edx
  800160:	72 e1                	jb     800143 <dumbfork+0x72>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800162:	83 ec 08             	sub    $0x8,%esp
  800165:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800168:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80016d:	50                   	push   %eax
  80016e:	53                   	push   %ebx
  80016f:	e8 bf fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800174:	83 c4 08             	add    $0x8,%esp
  800177:	6a 02                	push   $0x2
  800179:	53                   	push   %ebx
  80017a:	e8 51 0c 00 00       	call   800dd0 <sys_env_set_status>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <dumbfork+0xc7>
		panic("sys_env_set_status: %e", r);
  800186:	50                   	push   %eax
  800187:	68 ea 11 80 00       	push   $0x8011ea
  80018c:	6a 50                	push   $0x50
  80018e:	68 93 11 80 00       	push   $0x801193
  800193:	e8 ca 00 00 00       	call   800262 <_panic>

	return envid;
  800198:	89 d8                	mov    %ebx,%eax
}
  80019a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80019d:	5b                   	pop    %ebx
  80019e:	5e                   	pop    %esi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001aa:	e8 22 ff ff ff       	call   8000d1 <dumbfork>
  8001af:	89 c6                	mov    %eax,%esi
	cprintf("who am i: %x\n", who);
  8001b1:	83 ec 08             	sub    $0x8,%esp
  8001b4:	50                   	push   %eax
  8001b5:	68 01 12 80 00       	push   $0x801201
  8001ba:	e8 7c 01 00 00       	call   80033b <cprintf>
  8001bf:	83 c4 10             	add    $0x10,%esp
  8001c2:	85 f6                	test   %esi,%esi
  8001c4:	bf 16 12 80 00       	mov    $0x801216,%edi
  8001c9:	b8 0f 12 80 00       	mov    $0x80120f,%eax
  8001ce:	0f 45 f8             	cmovne %eax,%edi
	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d6:	eb 1a                	jmp    8001f2 <umain+0x51>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001d8:	83 ec 04             	sub    $0x4,%esp
  8001db:	57                   	push   %edi
  8001dc:	53                   	push   %ebx
  8001dd:	68 1c 12 80 00       	push   $0x80121c
  8001e2:	e8 54 01 00 00       	call   80033b <cprintf>
		sys_yield();
  8001e7:	e8 fe 0a 00 00       	call   800cea <sys_yield>

	// fork a child process
	who = dumbfork();
	cprintf("who am i: %x\n", who);
	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001ec:	83 c3 01             	add    $0x1,%ebx
  8001ef:	83 c4 10             	add    $0x10,%esp
  8001f2:	85 f6                	test   %esi,%esi
  8001f4:	74 07                	je     8001fd <umain+0x5c>
  8001f6:	83 fb 09             	cmp    $0x9,%ebx
  8001f9:	7e dd                	jle    8001d8 <umain+0x37>
  8001fb:	eb 05                	jmp    800202 <umain+0x61>
  8001fd:	83 fb 13             	cmp    $0x13,%ebx
  800200:	7e d6                	jle    8001d8 <umain+0x37>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800202:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800205:	5b                   	pop    %ebx
  800206:	5e                   	pop    %esi
  800207:	5f                   	pop    %edi
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    

0080020a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800212:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800215:	e8 b1 0a 00 00       	call   800ccb <sys_getenvid>
  80021a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80021f:	c1 e0 07             	shl    $0x7,%eax
  800222:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800227:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80022c:	85 db                	test   %ebx,%ebx
  80022e:	7e 07                	jle    800237 <libmain+0x2d>
		binaryname = argv[0];
  800230:	8b 06                	mov    (%esi),%eax
  800232:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800237:	83 ec 08             	sub    $0x8,%esp
  80023a:	56                   	push   %esi
  80023b:	53                   	push   %ebx
  80023c:	e8 60 ff ff ff       	call   8001a1 <umain>

	// exit gracefully
	exit();
  800241:	e8 0a 00 00 00       	call   800250 <exit>
}
  800246:	83 c4 10             	add    $0x10,%esp
  800249:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80024c:	5b                   	pop    %ebx
  80024d:	5e                   	pop    %esi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800256:	6a 00                	push   $0x0
  800258:	e8 2d 0a 00 00       	call   800c8a <sys_env_destroy>
}
  80025d:	83 c4 10             	add    $0x10,%esp
  800260:	c9                   	leave  
  800261:	c3                   	ret    

00800262 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800262:	55                   	push   %ebp
  800263:	89 e5                	mov    %esp,%ebp
  800265:	56                   	push   %esi
  800266:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800267:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80026a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800270:	e8 56 0a 00 00       	call   800ccb <sys_getenvid>
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	ff 75 0c             	pushl  0xc(%ebp)
  80027b:	ff 75 08             	pushl  0x8(%ebp)
  80027e:	56                   	push   %esi
  80027f:	50                   	push   %eax
  800280:	68 38 12 80 00       	push   $0x801238
  800285:	e8 b1 00 00 00       	call   80033b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80028a:	83 c4 18             	add    $0x18,%esp
  80028d:	53                   	push   %ebx
  80028e:	ff 75 10             	pushl  0x10(%ebp)
  800291:	e8 54 00 00 00       	call   8002ea <vcprintf>
	cprintf("\n");
  800296:	c7 04 24 2c 12 80 00 	movl   $0x80122c,(%esp)
  80029d:	e8 99 00 00 00       	call   80033b <cprintf>
  8002a2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002a5:	cc                   	int3   
  8002a6:	eb fd                	jmp    8002a5 <_panic+0x43>

008002a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	53                   	push   %ebx
  8002ac:	83 ec 04             	sub    $0x4,%esp
  8002af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002b2:	8b 13                	mov    (%ebx),%edx
  8002b4:	8d 42 01             	lea    0x1(%edx),%eax
  8002b7:	89 03                	mov    %eax,(%ebx)
  8002b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002c5:	75 1a                	jne    8002e1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002c7:	83 ec 08             	sub    $0x8,%esp
  8002ca:	68 ff 00 00 00       	push   $0xff
  8002cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8002d2:	50                   	push   %eax
  8002d3:	e8 75 09 00 00       	call   800c4d <sys_cputs>
		b->idx = 0;
  8002d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002de:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002e1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002e8:	c9                   	leave  
  8002e9:	c3                   	ret    

008002ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002fa:	00 00 00 
	b.cnt = 0;
  8002fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800304:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800307:	ff 75 0c             	pushl  0xc(%ebp)
  80030a:	ff 75 08             	pushl  0x8(%ebp)
  80030d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800313:	50                   	push   %eax
  800314:	68 a8 02 80 00       	push   $0x8002a8
  800319:	e8 54 01 00 00       	call   800472 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80031e:	83 c4 08             	add    $0x8,%esp
  800321:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800327:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80032d:	50                   	push   %eax
  80032e:	e8 1a 09 00 00       	call   800c4d <sys_cputs>

	return b.cnt;
}
  800333:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800339:	c9                   	leave  
  80033a:	c3                   	ret    

0080033b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800341:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800344:	50                   	push   %eax
  800345:	ff 75 08             	pushl  0x8(%ebp)
  800348:	e8 9d ff ff ff       	call   8002ea <vcprintf>
	va_end(ap);

	return cnt;
}
  80034d:	c9                   	leave  
  80034e:	c3                   	ret    

0080034f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	57                   	push   %edi
  800353:	56                   	push   %esi
  800354:	53                   	push   %ebx
  800355:	83 ec 1c             	sub    $0x1c,%esp
  800358:	89 c7                	mov    %eax,%edi
  80035a:	89 d6                	mov    %edx,%esi
  80035c:	8b 45 08             	mov    0x8(%ebp),%eax
  80035f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800362:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800365:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800368:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80036b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800370:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800373:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800376:	39 d3                	cmp    %edx,%ebx
  800378:	72 05                	jb     80037f <printnum+0x30>
  80037a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80037d:	77 45                	ja     8003c4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80037f:	83 ec 0c             	sub    $0xc,%esp
  800382:	ff 75 18             	pushl  0x18(%ebp)
  800385:	8b 45 14             	mov    0x14(%ebp),%eax
  800388:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80038b:	53                   	push   %ebx
  80038c:	ff 75 10             	pushl  0x10(%ebp)
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	ff 75 e4             	pushl  -0x1c(%ebp)
  800395:	ff 75 e0             	pushl  -0x20(%ebp)
  800398:	ff 75 dc             	pushl  -0x24(%ebp)
  80039b:	ff 75 d8             	pushl  -0x28(%ebp)
  80039e:	e8 3d 0b 00 00       	call   800ee0 <__udivdi3>
  8003a3:	83 c4 18             	add    $0x18,%esp
  8003a6:	52                   	push   %edx
  8003a7:	50                   	push   %eax
  8003a8:	89 f2                	mov    %esi,%edx
  8003aa:	89 f8                	mov    %edi,%eax
  8003ac:	e8 9e ff ff ff       	call   80034f <printnum>
  8003b1:	83 c4 20             	add    $0x20,%esp
  8003b4:	eb 18                	jmp    8003ce <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003b6:	83 ec 08             	sub    $0x8,%esp
  8003b9:	56                   	push   %esi
  8003ba:	ff 75 18             	pushl  0x18(%ebp)
  8003bd:	ff d7                	call   *%edi
  8003bf:	83 c4 10             	add    $0x10,%esp
  8003c2:	eb 03                	jmp    8003c7 <printnum+0x78>
  8003c4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003c7:	83 eb 01             	sub    $0x1,%ebx
  8003ca:	85 db                	test   %ebx,%ebx
  8003cc:	7f e8                	jg     8003b6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ce:	83 ec 08             	sub    $0x8,%esp
  8003d1:	56                   	push   %esi
  8003d2:	83 ec 04             	sub    $0x4,%esp
  8003d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8003db:	ff 75 dc             	pushl  -0x24(%ebp)
  8003de:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e1:	e8 2a 0c 00 00       	call   801010 <__umoddi3>
  8003e6:	83 c4 14             	add    $0x14,%esp
  8003e9:	0f be 80 5c 12 80 00 	movsbl 0x80125c(%eax),%eax
  8003f0:	50                   	push   %eax
  8003f1:	ff d7                	call   *%edi
}
  8003f3:	83 c4 10             	add    $0x10,%esp
  8003f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003f9:	5b                   	pop    %ebx
  8003fa:	5e                   	pop    %esi
  8003fb:	5f                   	pop    %edi
  8003fc:	5d                   	pop    %ebp
  8003fd:	c3                   	ret    

008003fe <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800401:	83 fa 01             	cmp    $0x1,%edx
  800404:	7e 0e                	jle    800414 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800406:	8b 10                	mov    (%eax),%edx
  800408:	8d 4a 08             	lea    0x8(%edx),%ecx
  80040b:	89 08                	mov    %ecx,(%eax)
  80040d:	8b 02                	mov    (%edx),%eax
  80040f:	8b 52 04             	mov    0x4(%edx),%edx
  800412:	eb 22                	jmp    800436 <getuint+0x38>
	else if (lflag)
  800414:	85 d2                	test   %edx,%edx
  800416:	74 10                	je     800428 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800418:	8b 10                	mov    (%eax),%edx
  80041a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80041d:	89 08                	mov    %ecx,(%eax)
  80041f:	8b 02                	mov    (%edx),%eax
  800421:	ba 00 00 00 00       	mov    $0x0,%edx
  800426:	eb 0e                	jmp    800436 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800428:	8b 10                	mov    (%eax),%edx
  80042a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80042d:	89 08                	mov    %ecx,(%eax)
  80042f:	8b 02                	mov    (%edx),%eax
  800431:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800436:	5d                   	pop    %ebp
  800437:	c3                   	ret    

00800438 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800438:	55                   	push   %ebp
  800439:	89 e5                	mov    %esp,%ebp
  80043b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80043e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800442:	8b 10                	mov    (%eax),%edx
  800444:	3b 50 04             	cmp    0x4(%eax),%edx
  800447:	73 0a                	jae    800453 <sprintputch+0x1b>
		*b->buf++ = ch;
  800449:	8d 4a 01             	lea    0x1(%edx),%ecx
  80044c:	89 08                	mov    %ecx,(%eax)
  80044e:	8b 45 08             	mov    0x8(%ebp),%eax
  800451:	88 02                	mov    %al,(%edx)
}
  800453:	5d                   	pop    %ebp
  800454:	c3                   	ret    

00800455 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800455:	55                   	push   %ebp
  800456:	89 e5                	mov    %esp,%ebp
  800458:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80045b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80045e:	50                   	push   %eax
  80045f:	ff 75 10             	pushl  0x10(%ebp)
  800462:	ff 75 0c             	pushl  0xc(%ebp)
  800465:	ff 75 08             	pushl  0x8(%ebp)
  800468:	e8 05 00 00 00       	call   800472 <vprintfmt>
	va_end(ap);
}
  80046d:	83 c4 10             	add    $0x10,%esp
  800470:	c9                   	leave  
  800471:	c3                   	ret    

00800472 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800472:	55                   	push   %ebp
  800473:	89 e5                	mov    %esp,%ebp
  800475:	57                   	push   %edi
  800476:	56                   	push   %esi
  800477:	53                   	push   %ebx
  800478:	83 ec 2c             	sub    $0x2c,%esp
  80047b:	8b 75 08             	mov    0x8(%ebp),%esi
  80047e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800481:	8b 7d 10             	mov    0x10(%ebp),%edi
  800484:	eb 1d                	jmp    8004a3 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800486:	85 c0                	test   %eax,%eax
  800488:	75 0f                	jne    800499 <vprintfmt+0x27>
				csa = 0x0700;
  80048a:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  800491:	07 00 00 
				return;
  800494:	e9 c4 03 00 00       	jmp    80085d <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	53                   	push   %ebx
  80049d:	50                   	push   %eax
  80049e:	ff d6                	call   *%esi
  8004a0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004a3:	83 c7 01             	add    $0x1,%edi
  8004a6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004aa:	83 f8 25             	cmp    $0x25,%eax
  8004ad:	75 d7                	jne    800486 <vprintfmt+0x14>
  8004af:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004b3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004ba:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004c1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004cd:	eb 07                	jmp    8004d6 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004d2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d6:	8d 47 01             	lea    0x1(%edi),%eax
  8004d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004dc:	0f b6 07             	movzbl (%edi),%eax
  8004df:	0f b6 c8             	movzbl %al,%ecx
  8004e2:	83 e8 23             	sub    $0x23,%eax
  8004e5:	3c 55                	cmp    $0x55,%al
  8004e7:	0f 87 55 03 00 00    	ja     800842 <vprintfmt+0x3d0>
  8004ed:	0f b6 c0             	movzbl %al,%eax
  8004f0:	ff 24 85 20 13 80 00 	jmp    *0x801320(,%eax,4)
  8004f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004fa:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004fe:	eb d6                	jmp    8004d6 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800503:	b8 00 00 00 00       	mov    $0x0,%eax
  800508:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80050b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80050e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800512:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800515:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800518:	83 fa 09             	cmp    $0x9,%edx
  80051b:	77 39                	ja     800556 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80051d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800520:	eb e9                	jmp    80050b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 48 04             	lea    0x4(%eax),%ecx
  800528:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80052b:	8b 00                	mov    (%eax),%eax
  80052d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800533:	eb 27                	jmp    80055c <vprintfmt+0xea>
  800535:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800538:	85 c0                	test   %eax,%eax
  80053a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80053f:	0f 49 c8             	cmovns %eax,%ecx
  800542:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800545:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800548:	eb 8c                	jmp    8004d6 <vprintfmt+0x64>
  80054a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80054d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800554:	eb 80                	jmp    8004d6 <vprintfmt+0x64>
  800556:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800559:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80055c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800560:	0f 89 70 ff ff ff    	jns    8004d6 <vprintfmt+0x64>
				width = precision, precision = -1;
  800566:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800569:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800573:	e9 5e ff ff ff       	jmp    8004d6 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800578:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80057e:	e9 53 ff ff ff       	jmp    8004d6 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 50 04             	lea    0x4(%eax),%edx
  800589:	89 55 14             	mov    %edx,0x14(%ebp)
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	53                   	push   %ebx
  800590:	ff 30                	pushl  (%eax)
  800592:	ff d6                	call   *%esi
			break;
  800594:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800597:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80059a:	e9 04 ff ff ff       	jmp    8004a3 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8d 50 04             	lea    0x4(%eax),%edx
  8005a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a8:	8b 00                	mov    (%eax),%eax
  8005aa:	99                   	cltd   
  8005ab:	31 d0                	xor    %edx,%eax
  8005ad:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005af:	83 f8 08             	cmp    $0x8,%eax
  8005b2:	7f 0b                	jg     8005bf <vprintfmt+0x14d>
  8005b4:	8b 14 85 80 14 80 00 	mov    0x801480(,%eax,4),%edx
  8005bb:	85 d2                	test   %edx,%edx
  8005bd:	75 18                	jne    8005d7 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  8005bf:	50                   	push   %eax
  8005c0:	68 74 12 80 00       	push   $0x801274
  8005c5:	53                   	push   %ebx
  8005c6:	56                   	push   %esi
  8005c7:	e8 89 fe ff ff       	call   800455 <printfmt>
  8005cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005d2:	e9 cc fe ff ff       	jmp    8004a3 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8005d7:	52                   	push   %edx
  8005d8:	68 7d 12 80 00       	push   $0x80127d
  8005dd:	53                   	push   %ebx
  8005de:	56                   	push   %esi
  8005df:	e8 71 fe ff ff       	call   800455 <printfmt>
  8005e4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ea:	e9 b4 fe ff ff       	jmp    8004a3 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 50 04             	lea    0x4(%eax),%edx
  8005f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005fa:	85 ff                	test   %edi,%edi
  8005fc:	b8 6d 12 80 00       	mov    $0x80126d,%eax
  800601:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800604:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800608:	0f 8e 94 00 00 00    	jle    8006a2 <vprintfmt+0x230>
  80060e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800612:	0f 84 98 00 00 00    	je     8006b0 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	ff 75 d0             	pushl  -0x30(%ebp)
  80061e:	57                   	push   %edi
  80061f:	e8 c1 02 00 00       	call   8008e5 <strnlen>
  800624:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800627:	29 c1                	sub    %eax,%ecx
  800629:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80062c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80062f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800633:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800636:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800639:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80063b:	eb 0f                	jmp    80064c <vprintfmt+0x1da>
					putch(padc, putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	53                   	push   %ebx
  800641:	ff 75 e0             	pushl  -0x20(%ebp)
  800644:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800646:	83 ef 01             	sub    $0x1,%edi
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	85 ff                	test   %edi,%edi
  80064e:	7f ed                	jg     80063d <vprintfmt+0x1cb>
  800650:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800653:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800656:	85 c9                	test   %ecx,%ecx
  800658:	b8 00 00 00 00       	mov    $0x0,%eax
  80065d:	0f 49 c1             	cmovns %ecx,%eax
  800660:	29 c1                	sub    %eax,%ecx
  800662:	89 75 08             	mov    %esi,0x8(%ebp)
  800665:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800668:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80066b:	89 cb                	mov    %ecx,%ebx
  80066d:	eb 4d                	jmp    8006bc <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80066f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800673:	74 1b                	je     800690 <vprintfmt+0x21e>
  800675:	0f be c0             	movsbl %al,%eax
  800678:	83 e8 20             	sub    $0x20,%eax
  80067b:	83 f8 5e             	cmp    $0x5e,%eax
  80067e:	76 10                	jbe    800690 <vprintfmt+0x21e>
					putch('?', putdat);
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	ff 75 0c             	pushl  0xc(%ebp)
  800686:	6a 3f                	push   $0x3f
  800688:	ff 55 08             	call   *0x8(%ebp)
  80068b:	83 c4 10             	add    $0x10,%esp
  80068e:	eb 0d                	jmp    80069d <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	ff 75 0c             	pushl  0xc(%ebp)
  800696:	52                   	push   %edx
  800697:	ff 55 08             	call   *0x8(%ebp)
  80069a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069d:	83 eb 01             	sub    $0x1,%ebx
  8006a0:	eb 1a                	jmp    8006bc <vprintfmt+0x24a>
  8006a2:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ab:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ae:	eb 0c                	jmp    8006bc <vprintfmt+0x24a>
  8006b0:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006bc:	83 c7 01             	add    $0x1,%edi
  8006bf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006c3:	0f be d0             	movsbl %al,%edx
  8006c6:	85 d2                	test   %edx,%edx
  8006c8:	74 23                	je     8006ed <vprintfmt+0x27b>
  8006ca:	85 f6                	test   %esi,%esi
  8006cc:	78 a1                	js     80066f <vprintfmt+0x1fd>
  8006ce:	83 ee 01             	sub    $0x1,%esi
  8006d1:	79 9c                	jns    80066f <vprintfmt+0x1fd>
  8006d3:	89 df                	mov    %ebx,%edi
  8006d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006db:	eb 18                	jmp    8006f5 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	53                   	push   %ebx
  8006e1:	6a 20                	push   $0x20
  8006e3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e5:	83 ef 01             	sub    $0x1,%edi
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	eb 08                	jmp    8006f5 <vprintfmt+0x283>
  8006ed:	89 df                	mov    %ebx,%edi
  8006ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f5:	85 ff                	test   %edi,%edi
  8006f7:	7f e4                	jg     8006dd <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006fc:	e9 a2 fd ff ff       	jmp    8004a3 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800701:	83 fa 01             	cmp    $0x1,%edx
  800704:	7e 16                	jle    80071c <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 08             	lea    0x8(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)
  80070f:	8b 50 04             	mov    0x4(%eax),%edx
  800712:	8b 00                	mov    (%eax),%eax
  800714:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800717:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80071a:	eb 32                	jmp    80074e <vprintfmt+0x2dc>
	else if (lflag)
  80071c:	85 d2                	test   %edx,%edx
  80071e:	74 18                	je     800738 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  800720:	8b 45 14             	mov    0x14(%ebp),%eax
  800723:	8d 50 04             	lea    0x4(%eax),%edx
  800726:	89 55 14             	mov    %edx,0x14(%ebp)
  800729:	8b 00                	mov    (%eax),%eax
  80072b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072e:	89 c1                	mov    %eax,%ecx
  800730:	c1 f9 1f             	sar    $0x1f,%ecx
  800733:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800736:	eb 16                	jmp    80074e <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800738:	8b 45 14             	mov    0x14(%ebp),%eax
  80073b:	8d 50 04             	lea    0x4(%eax),%edx
  80073e:	89 55 14             	mov    %edx,0x14(%ebp)
  800741:	8b 00                	mov    (%eax),%eax
  800743:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800746:	89 c1                	mov    %eax,%ecx
  800748:	c1 f9 1f             	sar    $0x1f,%ecx
  80074b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80074e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800751:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800754:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800759:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80075d:	79 74                	jns    8007d3 <vprintfmt+0x361>
				putch('-', putdat);
  80075f:	83 ec 08             	sub    $0x8,%esp
  800762:	53                   	push   %ebx
  800763:	6a 2d                	push   $0x2d
  800765:	ff d6                	call   *%esi
				num = -(long long) num;
  800767:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80076a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80076d:	f7 d8                	neg    %eax
  80076f:	83 d2 00             	adc    $0x0,%edx
  800772:	f7 da                	neg    %edx
  800774:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800777:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80077c:	eb 55                	jmp    8007d3 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80077e:	8d 45 14             	lea    0x14(%ebp),%eax
  800781:	e8 78 fc ff ff       	call   8003fe <getuint>
			base = 10;
  800786:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80078b:	eb 46                	jmp    8007d3 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  80078d:	8d 45 14             	lea    0x14(%ebp),%eax
  800790:	e8 69 fc ff ff       	call   8003fe <getuint>
      base = 8;
  800795:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80079a:	eb 37                	jmp    8007d3 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  80079c:	83 ec 08             	sub    $0x8,%esp
  80079f:	53                   	push   %ebx
  8007a0:	6a 30                	push   $0x30
  8007a2:	ff d6                	call   *%esi
			putch('x', putdat);
  8007a4:	83 c4 08             	add    $0x8,%esp
  8007a7:	53                   	push   %ebx
  8007a8:	6a 78                	push   $0x78
  8007aa:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8007af:	8d 50 04             	lea    0x4(%eax),%edx
  8007b2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007b5:	8b 00                	mov    (%eax),%eax
  8007b7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007bc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007bf:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007c4:	eb 0d                	jmp    8007d3 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c9:	e8 30 fc ff ff       	call   8003fe <getuint>
			base = 16;
  8007ce:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007d3:	83 ec 0c             	sub    $0xc,%esp
  8007d6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007da:	57                   	push   %edi
  8007db:	ff 75 e0             	pushl  -0x20(%ebp)
  8007de:	51                   	push   %ecx
  8007df:	52                   	push   %edx
  8007e0:	50                   	push   %eax
  8007e1:	89 da                	mov    %ebx,%edx
  8007e3:	89 f0                	mov    %esi,%eax
  8007e5:	e8 65 fb ff ff       	call   80034f <printnum>
			break;
  8007ea:	83 c4 20             	add    $0x20,%esp
  8007ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007f0:	e9 ae fc ff ff       	jmp    8004a3 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007f5:	83 ec 08             	sub    $0x8,%esp
  8007f8:	53                   	push   %ebx
  8007f9:	51                   	push   %ecx
  8007fa:	ff d6                	call   *%esi
			break;
  8007fc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800802:	e9 9c fc ff ff       	jmp    8004a3 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800807:	83 fa 01             	cmp    $0x1,%edx
  80080a:	7e 0d                	jle    800819 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  80080c:	8b 45 14             	mov    0x14(%ebp),%eax
  80080f:	8d 50 08             	lea    0x8(%eax),%edx
  800812:	89 55 14             	mov    %edx,0x14(%ebp)
  800815:	8b 00                	mov    (%eax),%eax
  800817:	eb 1c                	jmp    800835 <vprintfmt+0x3c3>
	else if (lflag)
  800819:	85 d2                	test   %edx,%edx
  80081b:	74 0d                	je     80082a <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  80081d:	8b 45 14             	mov    0x14(%ebp),%eax
  800820:	8d 50 04             	lea    0x4(%eax),%edx
  800823:	89 55 14             	mov    %edx,0x14(%ebp)
  800826:	8b 00                	mov    (%eax),%eax
  800828:	eb 0b                	jmp    800835 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  80082a:	8b 45 14             	mov    0x14(%ebp),%eax
  80082d:	8d 50 04             	lea    0x4(%eax),%edx
  800830:	89 55 14             	mov    %edx,0x14(%ebp)
  800833:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  800835:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  80083d:	e9 61 fc ff ff       	jmp    8004a3 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	53                   	push   %ebx
  800846:	6a 25                	push   $0x25
  800848:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80084a:	83 c4 10             	add    $0x10,%esp
  80084d:	eb 03                	jmp    800852 <vprintfmt+0x3e0>
  80084f:	83 ef 01             	sub    $0x1,%edi
  800852:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800856:	75 f7                	jne    80084f <vprintfmt+0x3dd>
  800858:	e9 46 fc ff ff       	jmp    8004a3 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  80085d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800860:	5b                   	pop    %ebx
  800861:	5e                   	pop    %esi
  800862:	5f                   	pop    %edi
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	83 ec 18             	sub    $0x18,%esp
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800871:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800874:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800878:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80087b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800882:	85 c0                	test   %eax,%eax
  800884:	74 26                	je     8008ac <vsnprintf+0x47>
  800886:	85 d2                	test   %edx,%edx
  800888:	7e 22                	jle    8008ac <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80088a:	ff 75 14             	pushl  0x14(%ebp)
  80088d:	ff 75 10             	pushl  0x10(%ebp)
  800890:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800893:	50                   	push   %eax
  800894:	68 38 04 80 00       	push   $0x800438
  800899:	e8 d4 fb ff ff       	call   800472 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80089e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008a1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a7:	83 c4 10             	add    $0x10,%esp
  8008aa:	eb 05                	jmp    8008b1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008b1:	c9                   	leave  
  8008b2:	c3                   	ret    

008008b3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008b9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008bc:	50                   	push   %eax
  8008bd:	ff 75 10             	pushl  0x10(%ebp)
  8008c0:	ff 75 0c             	pushl  0xc(%ebp)
  8008c3:	ff 75 08             	pushl  0x8(%ebp)
  8008c6:	e8 9a ff ff ff       	call   800865 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    

008008cd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d8:	eb 03                	jmp    8008dd <strlen+0x10>
		n++;
  8008da:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008dd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008e1:	75 f7                	jne    8008da <strlen+0xd>
		n++;
	return n;
}
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8008f3:	eb 03                	jmp    8008f8 <strnlen+0x13>
		n++;
  8008f5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f8:	39 c2                	cmp    %eax,%edx
  8008fa:	74 08                	je     800904 <strnlen+0x1f>
  8008fc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800900:	75 f3                	jne    8008f5 <strnlen+0x10>
  800902:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	53                   	push   %ebx
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800910:	89 c2                	mov    %eax,%edx
  800912:	83 c2 01             	add    $0x1,%edx
  800915:	83 c1 01             	add    $0x1,%ecx
  800918:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80091c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80091f:	84 db                	test   %bl,%bl
  800921:	75 ef                	jne    800912 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800923:	5b                   	pop    %ebx
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	53                   	push   %ebx
  80092a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80092d:	53                   	push   %ebx
  80092e:	e8 9a ff ff ff       	call   8008cd <strlen>
  800933:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800936:	ff 75 0c             	pushl  0xc(%ebp)
  800939:	01 d8                	add    %ebx,%eax
  80093b:	50                   	push   %eax
  80093c:	e8 c5 ff ff ff       	call   800906 <strcpy>
	return dst;
}
  800941:	89 d8                	mov    %ebx,%eax
  800943:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800946:	c9                   	leave  
  800947:	c3                   	ret    

00800948 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	56                   	push   %esi
  80094c:	53                   	push   %ebx
  80094d:	8b 75 08             	mov    0x8(%ebp),%esi
  800950:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800953:	89 f3                	mov    %esi,%ebx
  800955:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800958:	89 f2                	mov    %esi,%edx
  80095a:	eb 0f                	jmp    80096b <strncpy+0x23>
		*dst++ = *src;
  80095c:	83 c2 01             	add    $0x1,%edx
  80095f:	0f b6 01             	movzbl (%ecx),%eax
  800962:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800965:	80 39 01             	cmpb   $0x1,(%ecx)
  800968:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80096b:	39 da                	cmp    %ebx,%edx
  80096d:	75 ed                	jne    80095c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80096f:	89 f0                	mov    %esi,%eax
  800971:	5b                   	pop    %ebx
  800972:	5e                   	pop    %esi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	56                   	push   %esi
  800979:	53                   	push   %ebx
  80097a:	8b 75 08             	mov    0x8(%ebp),%esi
  80097d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800980:	8b 55 10             	mov    0x10(%ebp),%edx
  800983:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800985:	85 d2                	test   %edx,%edx
  800987:	74 21                	je     8009aa <strlcpy+0x35>
  800989:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80098d:	89 f2                	mov    %esi,%edx
  80098f:	eb 09                	jmp    80099a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800991:	83 c2 01             	add    $0x1,%edx
  800994:	83 c1 01             	add    $0x1,%ecx
  800997:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80099a:	39 c2                	cmp    %eax,%edx
  80099c:	74 09                	je     8009a7 <strlcpy+0x32>
  80099e:	0f b6 19             	movzbl (%ecx),%ebx
  8009a1:	84 db                	test   %bl,%bl
  8009a3:	75 ec                	jne    800991 <strlcpy+0x1c>
  8009a5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009a7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009aa:	29 f0                	sub    %esi,%eax
}
  8009ac:	5b                   	pop    %ebx
  8009ad:	5e                   	pop    %esi
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009b9:	eb 06                	jmp    8009c1 <strcmp+0x11>
		p++, q++;
  8009bb:	83 c1 01             	add    $0x1,%ecx
  8009be:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009c1:	0f b6 01             	movzbl (%ecx),%eax
  8009c4:	84 c0                	test   %al,%al
  8009c6:	74 04                	je     8009cc <strcmp+0x1c>
  8009c8:	3a 02                	cmp    (%edx),%al
  8009ca:	74 ef                	je     8009bb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009cc:	0f b6 c0             	movzbl %al,%eax
  8009cf:	0f b6 12             	movzbl (%edx),%edx
  8009d2:	29 d0                	sub    %edx,%eax
}
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	53                   	push   %ebx
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e0:	89 c3                	mov    %eax,%ebx
  8009e2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009e5:	eb 06                	jmp    8009ed <strncmp+0x17>
		n--, p++, q++;
  8009e7:	83 c0 01             	add    $0x1,%eax
  8009ea:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009ed:	39 d8                	cmp    %ebx,%eax
  8009ef:	74 15                	je     800a06 <strncmp+0x30>
  8009f1:	0f b6 08             	movzbl (%eax),%ecx
  8009f4:	84 c9                	test   %cl,%cl
  8009f6:	74 04                	je     8009fc <strncmp+0x26>
  8009f8:	3a 0a                	cmp    (%edx),%cl
  8009fa:	74 eb                	je     8009e7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009fc:	0f b6 00             	movzbl (%eax),%eax
  8009ff:	0f b6 12             	movzbl (%edx),%edx
  800a02:	29 d0                	sub    %edx,%eax
  800a04:	eb 05                	jmp    800a0b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a0b:	5b                   	pop    %ebx
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a18:	eb 07                	jmp    800a21 <strchr+0x13>
		if (*s == c)
  800a1a:	38 ca                	cmp    %cl,%dl
  800a1c:	74 0f                	je     800a2d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a1e:	83 c0 01             	add    $0x1,%eax
  800a21:	0f b6 10             	movzbl (%eax),%edx
  800a24:	84 d2                	test   %dl,%dl
  800a26:	75 f2                	jne    800a1a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a39:	eb 03                	jmp    800a3e <strfind+0xf>
  800a3b:	83 c0 01             	add    $0x1,%eax
  800a3e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a41:	38 ca                	cmp    %cl,%dl
  800a43:	74 04                	je     800a49 <strfind+0x1a>
  800a45:	84 d2                	test   %dl,%dl
  800a47:	75 f2                	jne    800a3b <strfind+0xc>
			break;
	return (char *) s;
}
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	57                   	push   %edi
  800a4f:	56                   	push   %esi
  800a50:	53                   	push   %ebx
  800a51:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a54:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a57:	85 c9                	test   %ecx,%ecx
  800a59:	74 36                	je     800a91 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a5b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a61:	75 28                	jne    800a8b <memset+0x40>
  800a63:	f6 c1 03             	test   $0x3,%cl
  800a66:	75 23                	jne    800a8b <memset+0x40>
		c &= 0xFF;
  800a68:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a6c:	89 d3                	mov    %edx,%ebx
  800a6e:	c1 e3 08             	shl    $0x8,%ebx
  800a71:	89 d6                	mov    %edx,%esi
  800a73:	c1 e6 18             	shl    $0x18,%esi
  800a76:	89 d0                	mov    %edx,%eax
  800a78:	c1 e0 10             	shl    $0x10,%eax
  800a7b:	09 f0                	or     %esi,%eax
  800a7d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a7f:	89 d8                	mov    %ebx,%eax
  800a81:	09 d0                	or     %edx,%eax
  800a83:	c1 e9 02             	shr    $0x2,%ecx
  800a86:	fc                   	cld    
  800a87:	f3 ab                	rep stos %eax,%es:(%edi)
  800a89:	eb 06                	jmp    800a91 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8e:	fc                   	cld    
  800a8f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a91:	89 f8                	mov    %edi,%eax
  800a93:	5b                   	pop    %ebx
  800a94:	5e                   	pop    %esi
  800a95:	5f                   	pop    %edi
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	57                   	push   %edi
  800a9c:	56                   	push   %esi
  800a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa6:	39 c6                	cmp    %eax,%esi
  800aa8:	73 35                	jae    800adf <memmove+0x47>
  800aaa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aad:	39 d0                	cmp    %edx,%eax
  800aaf:	73 2e                	jae    800adf <memmove+0x47>
		s += n;
		d += n;
  800ab1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab4:	89 d6                	mov    %edx,%esi
  800ab6:	09 fe                	or     %edi,%esi
  800ab8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800abe:	75 13                	jne    800ad3 <memmove+0x3b>
  800ac0:	f6 c1 03             	test   $0x3,%cl
  800ac3:	75 0e                	jne    800ad3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ac5:	83 ef 04             	sub    $0x4,%edi
  800ac8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800acb:	c1 e9 02             	shr    $0x2,%ecx
  800ace:	fd                   	std    
  800acf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad1:	eb 09                	jmp    800adc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ad3:	83 ef 01             	sub    $0x1,%edi
  800ad6:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ad9:	fd                   	std    
  800ada:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800adc:	fc                   	cld    
  800add:	eb 1d                	jmp    800afc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800adf:	89 f2                	mov    %esi,%edx
  800ae1:	09 c2                	or     %eax,%edx
  800ae3:	f6 c2 03             	test   $0x3,%dl
  800ae6:	75 0f                	jne    800af7 <memmove+0x5f>
  800ae8:	f6 c1 03             	test   $0x3,%cl
  800aeb:	75 0a                	jne    800af7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800aed:	c1 e9 02             	shr    $0x2,%ecx
  800af0:	89 c7                	mov    %eax,%edi
  800af2:	fc                   	cld    
  800af3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af5:	eb 05                	jmp    800afc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800af7:	89 c7                	mov    %eax,%edi
  800af9:	fc                   	cld    
  800afa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b03:	ff 75 10             	pushl  0x10(%ebp)
  800b06:	ff 75 0c             	pushl  0xc(%ebp)
  800b09:	ff 75 08             	pushl  0x8(%ebp)
  800b0c:	e8 87 ff ff ff       	call   800a98 <memmove>
}
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1e:	89 c6                	mov    %eax,%esi
  800b20:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b23:	eb 1a                	jmp    800b3f <memcmp+0x2c>
		if (*s1 != *s2)
  800b25:	0f b6 08             	movzbl (%eax),%ecx
  800b28:	0f b6 1a             	movzbl (%edx),%ebx
  800b2b:	38 d9                	cmp    %bl,%cl
  800b2d:	74 0a                	je     800b39 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b2f:	0f b6 c1             	movzbl %cl,%eax
  800b32:	0f b6 db             	movzbl %bl,%ebx
  800b35:	29 d8                	sub    %ebx,%eax
  800b37:	eb 0f                	jmp    800b48 <memcmp+0x35>
		s1++, s2++;
  800b39:	83 c0 01             	add    $0x1,%eax
  800b3c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3f:	39 f0                	cmp    %esi,%eax
  800b41:	75 e2                	jne    800b25 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	53                   	push   %ebx
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b53:	89 c1                	mov    %eax,%ecx
  800b55:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b58:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b5c:	eb 0a                	jmp    800b68 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b5e:	0f b6 10             	movzbl (%eax),%edx
  800b61:	39 da                	cmp    %ebx,%edx
  800b63:	74 07                	je     800b6c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b65:	83 c0 01             	add    $0x1,%eax
  800b68:	39 c8                	cmp    %ecx,%eax
  800b6a:	72 f2                	jb     800b5e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	57                   	push   %edi
  800b73:	56                   	push   %esi
  800b74:	53                   	push   %ebx
  800b75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7b:	eb 03                	jmp    800b80 <strtol+0x11>
		s++;
  800b7d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b80:	0f b6 01             	movzbl (%ecx),%eax
  800b83:	3c 20                	cmp    $0x20,%al
  800b85:	74 f6                	je     800b7d <strtol+0xe>
  800b87:	3c 09                	cmp    $0x9,%al
  800b89:	74 f2                	je     800b7d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b8b:	3c 2b                	cmp    $0x2b,%al
  800b8d:	75 0a                	jne    800b99 <strtol+0x2a>
		s++;
  800b8f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b92:	bf 00 00 00 00       	mov    $0x0,%edi
  800b97:	eb 11                	jmp    800baa <strtol+0x3b>
  800b99:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b9e:	3c 2d                	cmp    $0x2d,%al
  800ba0:	75 08                	jne    800baa <strtol+0x3b>
		s++, neg = 1;
  800ba2:	83 c1 01             	add    $0x1,%ecx
  800ba5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800baa:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bb0:	75 15                	jne    800bc7 <strtol+0x58>
  800bb2:	80 39 30             	cmpb   $0x30,(%ecx)
  800bb5:	75 10                	jne    800bc7 <strtol+0x58>
  800bb7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bbb:	75 7c                	jne    800c39 <strtol+0xca>
		s += 2, base = 16;
  800bbd:	83 c1 02             	add    $0x2,%ecx
  800bc0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc5:	eb 16                	jmp    800bdd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bc7:	85 db                	test   %ebx,%ebx
  800bc9:	75 12                	jne    800bdd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bcb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd0:	80 39 30             	cmpb   $0x30,(%ecx)
  800bd3:	75 08                	jne    800bdd <strtol+0x6e>
		s++, base = 8;
  800bd5:	83 c1 01             	add    $0x1,%ecx
  800bd8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800be2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800be5:	0f b6 11             	movzbl (%ecx),%edx
  800be8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800beb:	89 f3                	mov    %esi,%ebx
  800bed:	80 fb 09             	cmp    $0x9,%bl
  800bf0:	77 08                	ja     800bfa <strtol+0x8b>
			dig = *s - '0';
  800bf2:	0f be d2             	movsbl %dl,%edx
  800bf5:	83 ea 30             	sub    $0x30,%edx
  800bf8:	eb 22                	jmp    800c1c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bfa:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bfd:	89 f3                	mov    %esi,%ebx
  800bff:	80 fb 19             	cmp    $0x19,%bl
  800c02:	77 08                	ja     800c0c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c04:	0f be d2             	movsbl %dl,%edx
  800c07:	83 ea 57             	sub    $0x57,%edx
  800c0a:	eb 10                	jmp    800c1c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c0c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c0f:	89 f3                	mov    %esi,%ebx
  800c11:	80 fb 19             	cmp    $0x19,%bl
  800c14:	77 16                	ja     800c2c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c16:	0f be d2             	movsbl %dl,%edx
  800c19:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c1c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c1f:	7d 0b                	jge    800c2c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c21:	83 c1 01             	add    $0x1,%ecx
  800c24:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c28:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c2a:	eb b9                	jmp    800be5 <strtol+0x76>

	if (endptr)
  800c2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c30:	74 0d                	je     800c3f <strtol+0xd0>
		*endptr = (char *) s;
  800c32:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c35:	89 0e                	mov    %ecx,(%esi)
  800c37:	eb 06                	jmp    800c3f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c39:	85 db                	test   %ebx,%ebx
  800c3b:	74 98                	je     800bd5 <strtol+0x66>
  800c3d:	eb 9e                	jmp    800bdd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c3f:	89 c2                	mov    %eax,%edx
  800c41:	f7 da                	neg    %edx
  800c43:	85 ff                	test   %edi,%edi
  800c45:	0f 45 c2             	cmovne %edx,%eax
}
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c53:	b8 00 00 00 00       	mov    $0x0,%eax
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	89 c3                	mov    %eax,%ebx
  800c60:	89 c7                	mov    %eax,%edi
  800c62:	89 c6                	mov    %eax,%esi
  800c64:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c71:	ba 00 00 00 00       	mov    $0x0,%edx
  800c76:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7b:	89 d1                	mov    %edx,%ecx
  800c7d:	89 d3                	mov    %edx,%ebx
  800c7f:	89 d7                	mov    %edx,%edi
  800c81:	89 d6                	mov    %edx,%esi
  800c83:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c93:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c98:	b8 03 00 00 00       	mov    $0x3,%eax
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	89 cb                	mov    %ecx,%ebx
  800ca2:	89 cf                	mov    %ecx,%edi
  800ca4:	89 ce                	mov    %ecx,%esi
  800ca6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	7e 17                	jle    800cc3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	6a 03                	push   $0x3
  800cb2:	68 a4 14 80 00       	push   $0x8014a4
  800cb7:	6a 23                	push   $0x23
  800cb9:	68 c1 14 80 00       	push   $0x8014c1
  800cbe:	e8 9f f5 ff ff       	call   800262 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd6:	b8 02 00 00 00       	mov    $0x2,%eax
  800cdb:	89 d1                	mov    %edx,%ecx
  800cdd:	89 d3                	mov    %edx,%ebx
  800cdf:	89 d7                	mov    %edx,%edi
  800ce1:	89 d6                	mov    %edx,%esi
  800ce3:	cd 30                	int    $0x30
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	// cprintf("lib/syscall.c: %x\n", ret);
	return ret;
}
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_yield>:

void
sys_yield(void)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cfa:	89 d1                	mov    %edx,%ecx
  800cfc:	89 d3                	mov    %edx,%ebx
  800cfe:	89 d7                	mov    %edx,%edi
  800d00:	89 d6                	mov    %edx,%esi
  800d02:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d12:	be 00 00 00 00       	mov    $0x0,%esi
  800d17:	b8 04 00 00 00       	mov    $0x4,%eax
  800d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d25:	89 f7                	mov    %esi,%edi
  800d27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7e 17                	jle    800d44 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	50                   	push   %eax
  800d31:	6a 04                	push   $0x4
  800d33:	68 a4 14 80 00       	push   $0x8014a4
  800d38:	6a 23                	push   $0x23
  800d3a:	68 c1 14 80 00       	push   $0x8014c1
  800d3f:	e8 1e f5 ff ff       	call   800262 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	b8 05 00 00 00       	mov    $0x5,%eax
  800d5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d63:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d66:	8b 75 18             	mov    0x18(%ebp),%esi
  800d69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	7e 17                	jle    800d86 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	50                   	push   %eax
  800d73:	6a 05                	push   $0x5
  800d75:	68 a4 14 80 00       	push   $0x8014a4
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 c1 14 80 00       	push   $0x8014c1
  800d81:	e8 dc f4 ff ff       	call   800262 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9c:	b8 06 00 00 00       	mov    $0x6,%eax
  800da1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	89 df                	mov    %ebx,%edi
  800da9:	89 de                	mov    %ebx,%esi
  800dab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dad:	85 c0                	test   %eax,%eax
  800daf:	7e 17                	jle    800dc8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	50                   	push   %eax
  800db5:	6a 06                	push   $0x6
  800db7:	68 a4 14 80 00       	push   $0x8014a4
  800dbc:	6a 23                	push   $0x23
  800dbe:	68 c1 14 80 00       	push   $0x8014c1
  800dc3:	e8 9a f4 ff ff       	call   800262 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
  800dd6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dde:	b8 08 00 00 00       	mov    $0x8,%eax
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	8b 55 08             	mov    0x8(%ebp),%edx
  800de9:	89 df                	mov    %ebx,%edi
  800deb:	89 de                	mov    %ebx,%esi
  800ded:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800def:	85 c0                	test   %eax,%eax
  800df1:	7e 17                	jle    800e0a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	50                   	push   %eax
  800df7:	6a 08                	push   $0x8
  800df9:	68 a4 14 80 00       	push   $0x8014a4
  800dfe:	6a 23                	push   $0x23
  800e00:	68 c1 14 80 00       	push   $0x8014c1
  800e05:	e8 58 f4 ff ff       	call   800262 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e20:	b8 09 00 00 00       	mov    $0x9,%eax
  800e25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	89 df                	mov    %ebx,%edi
  800e2d:	89 de                	mov    %ebx,%esi
  800e2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e31:	85 c0                	test   %eax,%eax
  800e33:	7e 17                	jle    800e4c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e35:	83 ec 0c             	sub    $0xc,%esp
  800e38:	50                   	push   %eax
  800e39:	6a 09                	push   $0x9
  800e3b:	68 a4 14 80 00       	push   $0x8014a4
  800e40:	6a 23                	push   $0x23
  800e42:	68 c1 14 80 00       	push   $0x8014c1
  800e47:	e8 16 f4 ff ff       	call   800262 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5a:	be 00 00 00 00       	mov    $0x0,%esi
  800e5f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e67:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e70:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e72:	5b                   	pop    %ebx
  800e73:	5e                   	pop    %esi
  800e74:	5f                   	pop    %edi
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	57                   	push   %edi
  800e7b:	56                   	push   %esi
  800e7c:	53                   	push   %ebx
  800e7d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e80:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e85:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8d:	89 cb                	mov    %ecx,%ebx
  800e8f:	89 cf                	mov    %ecx,%edi
  800e91:	89 ce                	mov    %ecx,%esi
  800e93:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e95:	85 c0                	test   %eax,%eax
  800e97:	7e 17                	jle    800eb0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e99:	83 ec 0c             	sub    $0xc,%esp
  800e9c:	50                   	push   %eax
  800e9d:	6a 0c                	push   $0xc
  800e9f:	68 a4 14 80 00       	push   $0x8014a4
  800ea4:	6a 23                	push   $0x23
  800ea6:	68 c1 14 80 00       	push   $0x8014c1
  800eab:	e8 b2 f3 ff ff       	call   800262 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb3:	5b                   	pop    %ebx
  800eb4:	5e                   	pop    %esi
  800eb5:	5f                   	pop    %edi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    

00800eb8 <sys_change_pr>:

int
sys_change_pr(int pr)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	57                   	push   %edi
  800ebc:	56                   	push   %esi
  800ebd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ec8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecb:	89 cb                	mov    %ecx,%ebx
  800ecd:	89 cf                	mov    %ecx,%edi
  800ecf:	89 ce                	mov    %ecx,%esi
  800ed1:	cd 30                	int    $0x30

int
sys_change_pr(int pr)
{
	return syscall(SYS_change_pr, 0, pr, 0, 0, 0, 0);
}
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5f                   	pop    %edi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    
  800ed8:	66 90                	xchg   %ax,%ax
  800eda:	66 90                	xchg   %ax,%ax
  800edc:	66 90                	xchg   %ax,%ax
  800ede:	66 90                	xchg   %ax,%ax

00800ee0 <__udivdi3>:
  800ee0:	55                   	push   %ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 1c             	sub    $0x1c,%esp
  800ee7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800eeb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800eef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800ef3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ef7:	85 f6                	test   %esi,%esi
  800ef9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800efd:	89 ca                	mov    %ecx,%edx
  800eff:	89 f8                	mov    %edi,%eax
  800f01:	75 3d                	jne    800f40 <__udivdi3+0x60>
  800f03:	39 cf                	cmp    %ecx,%edi
  800f05:	0f 87 c5 00 00 00    	ja     800fd0 <__udivdi3+0xf0>
  800f0b:	85 ff                	test   %edi,%edi
  800f0d:	89 fd                	mov    %edi,%ebp
  800f0f:	75 0b                	jne    800f1c <__udivdi3+0x3c>
  800f11:	b8 01 00 00 00       	mov    $0x1,%eax
  800f16:	31 d2                	xor    %edx,%edx
  800f18:	f7 f7                	div    %edi
  800f1a:	89 c5                	mov    %eax,%ebp
  800f1c:	89 c8                	mov    %ecx,%eax
  800f1e:	31 d2                	xor    %edx,%edx
  800f20:	f7 f5                	div    %ebp
  800f22:	89 c1                	mov    %eax,%ecx
  800f24:	89 d8                	mov    %ebx,%eax
  800f26:	89 cf                	mov    %ecx,%edi
  800f28:	f7 f5                	div    %ebp
  800f2a:	89 c3                	mov    %eax,%ebx
  800f2c:	89 d8                	mov    %ebx,%eax
  800f2e:	89 fa                	mov    %edi,%edx
  800f30:	83 c4 1c             	add    $0x1c,%esp
  800f33:	5b                   	pop    %ebx
  800f34:	5e                   	pop    %esi
  800f35:	5f                   	pop    %edi
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    
  800f38:	90                   	nop
  800f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f40:	39 ce                	cmp    %ecx,%esi
  800f42:	77 74                	ja     800fb8 <__udivdi3+0xd8>
  800f44:	0f bd fe             	bsr    %esi,%edi
  800f47:	83 f7 1f             	xor    $0x1f,%edi
  800f4a:	0f 84 98 00 00 00    	je     800fe8 <__udivdi3+0x108>
  800f50:	bb 20 00 00 00       	mov    $0x20,%ebx
  800f55:	89 f9                	mov    %edi,%ecx
  800f57:	89 c5                	mov    %eax,%ebp
  800f59:	29 fb                	sub    %edi,%ebx
  800f5b:	d3 e6                	shl    %cl,%esi
  800f5d:	89 d9                	mov    %ebx,%ecx
  800f5f:	d3 ed                	shr    %cl,%ebp
  800f61:	89 f9                	mov    %edi,%ecx
  800f63:	d3 e0                	shl    %cl,%eax
  800f65:	09 ee                	or     %ebp,%esi
  800f67:	89 d9                	mov    %ebx,%ecx
  800f69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f6d:	89 d5                	mov    %edx,%ebp
  800f6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f73:	d3 ed                	shr    %cl,%ebp
  800f75:	89 f9                	mov    %edi,%ecx
  800f77:	d3 e2                	shl    %cl,%edx
  800f79:	89 d9                	mov    %ebx,%ecx
  800f7b:	d3 e8                	shr    %cl,%eax
  800f7d:	09 c2                	or     %eax,%edx
  800f7f:	89 d0                	mov    %edx,%eax
  800f81:	89 ea                	mov    %ebp,%edx
  800f83:	f7 f6                	div    %esi
  800f85:	89 d5                	mov    %edx,%ebp
  800f87:	89 c3                	mov    %eax,%ebx
  800f89:	f7 64 24 0c          	mull   0xc(%esp)
  800f8d:	39 d5                	cmp    %edx,%ebp
  800f8f:	72 10                	jb     800fa1 <__udivdi3+0xc1>
  800f91:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f95:	89 f9                	mov    %edi,%ecx
  800f97:	d3 e6                	shl    %cl,%esi
  800f99:	39 c6                	cmp    %eax,%esi
  800f9b:	73 07                	jae    800fa4 <__udivdi3+0xc4>
  800f9d:	39 d5                	cmp    %edx,%ebp
  800f9f:	75 03                	jne    800fa4 <__udivdi3+0xc4>
  800fa1:	83 eb 01             	sub    $0x1,%ebx
  800fa4:	31 ff                	xor    %edi,%edi
  800fa6:	89 d8                	mov    %ebx,%eax
  800fa8:	89 fa                	mov    %edi,%edx
  800faa:	83 c4 1c             	add    $0x1c,%esp
  800fad:	5b                   	pop    %ebx
  800fae:	5e                   	pop    %esi
  800faf:	5f                   	pop    %edi
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    
  800fb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fb8:	31 ff                	xor    %edi,%edi
  800fba:	31 db                	xor    %ebx,%ebx
  800fbc:	89 d8                	mov    %ebx,%eax
  800fbe:	89 fa                	mov    %edi,%edx
  800fc0:	83 c4 1c             	add    $0x1c,%esp
  800fc3:	5b                   	pop    %ebx
  800fc4:	5e                   	pop    %esi
  800fc5:	5f                   	pop    %edi
  800fc6:	5d                   	pop    %ebp
  800fc7:	c3                   	ret    
  800fc8:	90                   	nop
  800fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fd0:	89 d8                	mov    %ebx,%eax
  800fd2:	f7 f7                	div    %edi
  800fd4:	31 ff                	xor    %edi,%edi
  800fd6:	89 c3                	mov    %eax,%ebx
  800fd8:	89 d8                	mov    %ebx,%eax
  800fda:	89 fa                	mov    %edi,%edx
  800fdc:	83 c4 1c             	add    $0x1c,%esp
  800fdf:	5b                   	pop    %ebx
  800fe0:	5e                   	pop    %esi
  800fe1:	5f                   	pop    %edi
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    
  800fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fe8:	39 ce                	cmp    %ecx,%esi
  800fea:	72 0c                	jb     800ff8 <__udivdi3+0x118>
  800fec:	31 db                	xor    %ebx,%ebx
  800fee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ff2:	0f 87 34 ff ff ff    	ja     800f2c <__udivdi3+0x4c>
  800ff8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ffd:	e9 2a ff ff ff       	jmp    800f2c <__udivdi3+0x4c>
  801002:	66 90                	xchg   %ax,%ax
  801004:	66 90                	xchg   %ax,%ax
  801006:	66 90                	xchg   %ax,%ax
  801008:	66 90                	xchg   %ax,%ax
  80100a:	66 90                	xchg   %ax,%ax
  80100c:	66 90                	xchg   %ax,%ax
  80100e:	66 90                	xchg   %ax,%ax

00801010 <__umoddi3>:
  801010:	55                   	push   %ebp
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
  801014:	83 ec 1c             	sub    $0x1c,%esp
  801017:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80101b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80101f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801023:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801027:	85 d2                	test   %edx,%edx
  801029:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80102d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801031:	89 f3                	mov    %esi,%ebx
  801033:	89 3c 24             	mov    %edi,(%esp)
  801036:	89 74 24 04          	mov    %esi,0x4(%esp)
  80103a:	75 1c                	jne    801058 <__umoddi3+0x48>
  80103c:	39 f7                	cmp    %esi,%edi
  80103e:	76 50                	jbe    801090 <__umoddi3+0x80>
  801040:	89 c8                	mov    %ecx,%eax
  801042:	89 f2                	mov    %esi,%edx
  801044:	f7 f7                	div    %edi
  801046:	89 d0                	mov    %edx,%eax
  801048:	31 d2                	xor    %edx,%edx
  80104a:	83 c4 1c             	add    $0x1c,%esp
  80104d:	5b                   	pop    %ebx
  80104e:	5e                   	pop    %esi
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    
  801052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801058:	39 f2                	cmp    %esi,%edx
  80105a:	89 d0                	mov    %edx,%eax
  80105c:	77 52                	ja     8010b0 <__umoddi3+0xa0>
  80105e:	0f bd ea             	bsr    %edx,%ebp
  801061:	83 f5 1f             	xor    $0x1f,%ebp
  801064:	75 5a                	jne    8010c0 <__umoddi3+0xb0>
  801066:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80106a:	0f 82 e0 00 00 00    	jb     801150 <__umoddi3+0x140>
  801070:	39 0c 24             	cmp    %ecx,(%esp)
  801073:	0f 86 d7 00 00 00    	jbe    801150 <__umoddi3+0x140>
  801079:	8b 44 24 08          	mov    0x8(%esp),%eax
  80107d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801081:	83 c4 1c             	add    $0x1c,%esp
  801084:	5b                   	pop    %ebx
  801085:	5e                   	pop    %esi
  801086:	5f                   	pop    %edi
  801087:	5d                   	pop    %ebp
  801088:	c3                   	ret    
  801089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801090:	85 ff                	test   %edi,%edi
  801092:	89 fd                	mov    %edi,%ebp
  801094:	75 0b                	jne    8010a1 <__umoddi3+0x91>
  801096:	b8 01 00 00 00       	mov    $0x1,%eax
  80109b:	31 d2                	xor    %edx,%edx
  80109d:	f7 f7                	div    %edi
  80109f:	89 c5                	mov    %eax,%ebp
  8010a1:	89 f0                	mov    %esi,%eax
  8010a3:	31 d2                	xor    %edx,%edx
  8010a5:	f7 f5                	div    %ebp
  8010a7:	89 c8                	mov    %ecx,%eax
  8010a9:	f7 f5                	div    %ebp
  8010ab:	89 d0                	mov    %edx,%eax
  8010ad:	eb 99                	jmp    801048 <__umoddi3+0x38>
  8010af:	90                   	nop
  8010b0:	89 c8                	mov    %ecx,%eax
  8010b2:	89 f2                	mov    %esi,%edx
  8010b4:	83 c4 1c             	add    $0x1c,%esp
  8010b7:	5b                   	pop    %ebx
  8010b8:	5e                   	pop    %esi
  8010b9:	5f                   	pop    %edi
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    
  8010bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c0:	8b 34 24             	mov    (%esp),%esi
  8010c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8010c8:	89 e9                	mov    %ebp,%ecx
  8010ca:	29 ef                	sub    %ebp,%edi
  8010cc:	d3 e0                	shl    %cl,%eax
  8010ce:	89 f9                	mov    %edi,%ecx
  8010d0:	89 f2                	mov    %esi,%edx
  8010d2:	d3 ea                	shr    %cl,%edx
  8010d4:	89 e9                	mov    %ebp,%ecx
  8010d6:	09 c2                	or     %eax,%edx
  8010d8:	89 d8                	mov    %ebx,%eax
  8010da:	89 14 24             	mov    %edx,(%esp)
  8010dd:	89 f2                	mov    %esi,%edx
  8010df:	d3 e2                	shl    %cl,%edx
  8010e1:	89 f9                	mov    %edi,%ecx
  8010e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8010eb:	d3 e8                	shr    %cl,%eax
  8010ed:	89 e9                	mov    %ebp,%ecx
  8010ef:	89 c6                	mov    %eax,%esi
  8010f1:	d3 e3                	shl    %cl,%ebx
  8010f3:	89 f9                	mov    %edi,%ecx
  8010f5:	89 d0                	mov    %edx,%eax
  8010f7:	d3 e8                	shr    %cl,%eax
  8010f9:	89 e9                	mov    %ebp,%ecx
  8010fb:	09 d8                	or     %ebx,%eax
  8010fd:	89 d3                	mov    %edx,%ebx
  8010ff:	89 f2                	mov    %esi,%edx
  801101:	f7 34 24             	divl   (%esp)
  801104:	89 d6                	mov    %edx,%esi
  801106:	d3 e3                	shl    %cl,%ebx
  801108:	f7 64 24 04          	mull   0x4(%esp)
  80110c:	39 d6                	cmp    %edx,%esi
  80110e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801112:	89 d1                	mov    %edx,%ecx
  801114:	89 c3                	mov    %eax,%ebx
  801116:	72 08                	jb     801120 <__umoddi3+0x110>
  801118:	75 11                	jne    80112b <__umoddi3+0x11b>
  80111a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80111e:	73 0b                	jae    80112b <__umoddi3+0x11b>
  801120:	2b 44 24 04          	sub    0x4(%esp),%eax
  801124:	1b 14 24             	sbb    (%esp),%edx
  801127:	89 d1                	mov    %edx,%ecx
  801129:	89 c3                	mov    %eax,%ebx
  80112b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80112f:	29 da                	sub    %ebx,%edx
  801131:	19 ce                	sbb    %ecx,%esi
  801133:	89 f9                	mov    %edi,%ecx
  801135:	89 f0                	mov    %esi,%eax
  801137:	d3 e0                	shl    %cl,%eax
  801139:	89 e9                	mov    %ebp,%ecx
  80113b:	d3 ea                	shr    %cl,%edx
  80113d:	89 e9                	mov    %ebp,%ecx
  80113f:	d3 ee                	shr    %cl,%esi
  801141:	09 d0                	or     %edx,%eax
  801143:	89 f2                	mov    %esi,%edx
  801145:	83 c4 1c             	add    $0x1c,%esp
  801148:	5b                   	pop    %ebx
  801149:	5e                   	pop    %esi
  80114a:	5f                   	pop    %edi
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    
  80114d:	8d 76 00             	lea    0x0(%esi),%esi
  801150:	29 f9                	sub    %edi,%ecx
  801152:	19 d6                	sbb    %edx,%esi
  801154:	89 74 24 04          	mov    %esi,0x4(%esp)
  801158:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80115c:	e9 18 ff ff ff       	jmp    801079 <__umoddi3+0x69>
